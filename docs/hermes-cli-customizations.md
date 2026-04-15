# Hermes CLI customizations for this setup

This file is a behavior spec, not a patch.

Use it when asking Hermes to recreate this machine's local Hermes CLI customizations in another Hermes checkout.
Do not copy line numbers blindly. Inspect the target Hermes version and implement equivalent behavior.

## Source of truth

Current local Hermes source repo:
- `~/.hermes/hermes-agent`

Local repo state when this note was written:
- branch: `main`
- base commit: `e69526be`
- local uncommitted changes were present in:
  - `cli.py`
  - `tests/cli/test_cli_preloaded_skills.py`
  - `tests/cli/test_cli_status_bar.py`

Primary user-visible requirements:
1. Hermes CLI should always preload the `caveman` skill in interactive CLI sessions.
2. Footer/status bar should show the last two fields as:
   - `reason <level>`
   - `caveman <level>`
3. Footer should stop showing the old elapsed-time field.

## Required behavior

### 1. Always preload `caveman`

Interactive CLI startup should merge a default skill tuple containing `caveman` into the parsed `--skills` argument.

Required semantics:
- If user passes no `--skills`, CLI still preloads `caveman`.
- If user passes other skills, CLI appends `caveman` automatically.
- If user explicitly passes `caveman`, do not duplicate it.
- Deduplicate by normalized slug, not only exact raw string.

Implementation area in local diff:
- `cli.py`
- helper names in local diff included:
  - `_ALWAYS_PRELOADED_CLI_SKILLS`
  - `_normalize_skill_slug(...)`
  - `_merge_default_cli_skills(...)`

Call site change in local diff:
- CLI `main(...)` used merged skills before calling `build_preloaded_skills_prompt(...)`.

### 2. Footer/status bar content redesign

Footer should be driven from shared field-building logic used by both:
- plain text builder
- styled prompt_toolkit fragments

Required field layout:
- wide mode: `model | context-used/context-total - percent | reason <level> | caveman <level>`
- medium mode: `model | percent | reason <level> | caveman <level>`
- narrow mode: `model | reason <level> | caveman <level>`

Required wording:
- reasoning field label must be exactly `reason`
- caveman field label must be exactly `caveman`

Required removals:
- old elapsed duration field should no longer appear in footer text or styled fragments

Implementation areas in local diff:
- `cli.py`
- helper names in local diff included:
  - `_reasoning_status_label(...)`
  - `_status_bar_context_field(...)`
  - `_status_bar_fields(...)`
  - `_get_status_bar_snapshot(...)`
  - `_build_status_bar_text(...)`
  - `_get_status_bar_fragments(...)`

### 3. Track caveman level from session state

Footer must show current caveman level, not only whether the skill is installed.

Required supported levels:
- `lite`
- `full`
- `ultra`
- `wenyan-lite`
- `wenyan-full`
- `wenyan-ultra`

Required behavior:
- default to `full` when `caveman` is active but no explicit level is present
- show `off` when caveman is inactive
- detect activation from preloaded skills
- also detect in-session activation from synthetic user messages produced by skill invocation
- if user says `stop caveman` or `normal mode`, footer should switch caveman level to `off`

Implementation hints from local diff:
- local code parsed skill activation markers like:
  - `[SYSTEM: The user has invoked the "<skill>" skill ...]`
  - `[SYSTEM: The user launched this CLI session with the "<skill>" skill preloaded ...]`
- local code also parsed appended instruction text after:
  - `The user has provided the following instruction alongside the skill invocation:`

Helper names in local diff:
- `_extract_skill_instruction(...)`
- `_extract_caveman_level(...)`
- `_session_skill_state(...)`
- `_SKILL_ACTIVATION_PATTERNS`
- `_CAVEMAN_LEVEL_PATTERN`

### 4. Reasoning label in footer

Footer must expose reasoning level as a derived label.

Required behavior:
- if reasoning config is disabled, show `reason none`
- if reasoning config has an explicit effort, show that effort
- otherwise default to `reason medium`

Implementation area in local diff:
- `cli.py`
- helper name:
  - `_reasoning_status_label(...)`

## Tests that should move with the behavior

When recreating this customization, update and run targeted tests.

Files touched in local diff:
- `tests/cli/test_cli_preloaded_skills.py`
- `tests/cli/test_cli_status_bar.py`

Expected test coverage:

### Preloaded-skills tests
- explicit skills + default caveman merge
- no `--skills` provided, but caveman still preloads
- preloaded skill list passed to `build_preloaded_skills_prompt(...)` includes `caveman`

### Status-bar tests
- wide footer includes:
  - model
  - `used/total - percent`
  - `reason medium` (or current level)
  - `caveman full` (or current level)
- medium footer includes:
  - model
  - percent
  - `reason ...`
  - `caveman ...`
- narrow footer omits context details first, but still keeps:
  - model
  - `reason ...`
  - `caveman ...`
- duration like `15m` should no longer appear
- caveman level should change to `ultra` when session history contains a caveman invocation with `ultra`

## What future Hermes should do

If asked to reproduce this behavior in another Hermes checkout:
1. Inspect current `cli.py` status bar pipeline and current CLI startup path.
2. Re-implement the behavior above against the target version.
3. Update the focused tests so they assert behavior, not old layout.
4. Run the targeted CLI tests.
5. Prefer equivalent behavior over literal copy-paste from the old local diff.

## Non-goals

- Do not put secrets, auth tokens, or local `.env` values in the code or this file.
- Do not assume exact line numbers from the old local diff still apply upstream.
- Do not treat this file as a patch; treat it as the required outcome.
