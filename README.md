# dotfiles

Personal dotfiles repo with Linux/Omarchy as the main source of truth.

## Principles

- Current local Omarchy machine is source of truth for behavior.
- macOS zsh should adapt to match that behavior where practical.
- Never commit secret keys, auth caches, session history, or runtime state.
- Hermes CLI custom source changes are documented separately and are not reproduced by dotfiles alone.

## Repo style

This repo uses `chezmoi`-style naming:
- `dot_*` -> files/directories that become hidden in `$HOME`
- `dot_config/...` -> `~/.config/...`
- `dot_local/...` -> `~/.local/...`

## What is tracked

### Linux / Omarchy
- Omarchy Bash split config under `dot_local/share/omarchy/default/bash/`
- Neovim under `dot_config/nvim/`
- tmux under `dot_config/tmux/tmux.conf`
- Git config under `dot_config/git/`
- Starship under `dot_config/starship.toml`
- Ghostty under `dot_config/ghostty/config`
- tmux-sessionizer config under `dot_config/tmux-sessionizer/`
- custom tmux-sessionizer executable under `dot_local/bin/tmux-sessionizer`
- Hermes config under `dot_hermes/config.yaml`

### macOS
- split zsh layout under `dot_config/zsh/`
- tiny `dot_zshrc.tmpl` loader
- `dot_tmux.conf` loader that points tmux at XDG config
- sanitized Claude Code settings under `dot_claude/settings.json`
- placeholder Codex config under `dot_codex/config.toml`

## What is intentionally not tracked

### Secrets / auth / runtime state
- `~/.hermes/.env`
- `~/.hermes/auth.json`
- `~/.hermes/sessions/*`
- `~/.hermes/logs/*`
- `~/.hermes/state.db*`
- `~/.claude.json`
- `~/.claude/.credentials.json`
- `~/.claude/history.jsonl`
- `~/.claude/projects/*`
- `~/.claude/file-history/*`
- `~/.claude/tasks/*`
- `~/.codex/auth.json`

### Scratch / machine-specific leftovers
- temporary Neovim scratch files like `test.qmd`
- hashed plugin-cache paths
- old tmux stack files that were replaced by XDG config

## Apply notes

### On Omarchy / Linux
Use this repo as the source for:
- `~/.local/share/omarchy/default/bash/*`
- `~/.config/nvim/*`
- `~/.config/tmux/tmux.conf`
- `~/.config/git/*`
- `~/.config/starship.toml`
- `~/.config/ghostty/config`
- `~/.config/tmux-sessionizer/tmux-sessionizer.conf`
- `~/.local/bin/tmux-sessionizer`
- `~/.hermes/config.yaml`

After applying shell changes, restart shell or source the relevant Omarchy Bash loader.

### On macOS
Use the split zsh config:
- `~/.zshrc` should stay a tiny loader
- main config lives under `~/.config/zsh/`
- tmux should enter through `~/.tmux.conf`, which loads `~/.config/tmux/tmux.conf`

Secrets should come from a local untracked file:
- `~/.credentials/.env`

The zsh env file exports a small allowlist of GUI env vars with `launchctl setenv` when present.

## Claude / Codex / Hermes notes

### Claude Code
Tracked file:
- `dot_claude/settings.json`

This file is sanitized.
Do not put raw auth tokens back into it.

### Codex
Tracked file:
- `dot_codex/config.toml`

Right now this is only a placeholder because the source machine had auth state but no real shareable Codex config file.

### Hermes
Tracked file:
- `dot_hermes/config.yaml`

This covers config, not local Hermes source modifications.

## Hermes CLI source customization note

Local Hermes CLI code changes are documented here:
- `docs/hermes-cli-customizations.md`

That file is a behavior spec for future Hermes work, not a patch.

## High-level sync history

Recent cleanup choices:
- replaced old repo tmux stack with XDG tmux config
- replaced stale Neovim layout with current local config
- moved Git to XDG config
- kept macOS zsh split into smaller files while removing the Oh My Zsh dependency
- sanitized agent config before committing
