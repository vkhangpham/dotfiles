# Hermes skills bootstrap manifest

Generated from this machine on 2026-05-09.

Purpose: keep a lightweight, secret-free record of the Hermes skills I use, without committing the whole ~/.hermes/skills package/cache tree into dotfiles.

Important policy:
- Do not copy ~/.hermes/skills wholesale into dotfiles.
- Do not track ~/.hermes/skills/.hub, .usage.json*, .bundled_manifest, .curator_state, backup/runtime dirs, __pycache__, or nested .git dirs.
- For user-authored or locally modified skills, track real skill directories separately if they cannot be reinstalled from a public source.
- Hermes skill directories should be real directories with SKILL.md, not symlinks.
- Restart Hermes or start a fresh session after installing/updating skills.

Source counts:
- builtin: 86
- local: 59
- skills.sh: 10
- total listed by `hermes skills list --source all`: 155

## New-machine bootstrap prompt

After Hermes and this dotfiles repo are present on a new machine, start Hermes and paste:

```text
Read ~/Servers/dotfiles-review/docs/hermes-skills-bootstrap.md. Recreate my Hermes skills setup safely. Install/update built-in and hub/community skills through Hermes commands where possible. For local-only skills, do not invent content; tell me which ones need their source directories copied, published, or added to dotfiles. Do not sync secrets or runtime state. Verify each installed skill has a real directory with SKILL.md and is not a symlink.
```

## Manual bootstrap outline

1. Verify Hermes works:

   ```bash
   hermes doctor
   hermes skills list
   ```

2. Built-in skills: no direct copy needed. They should appear after installing/updating Hermes:

   ```bash
   hermes skills list --source builtin
   hermes skills check
   hermes skills update
   ```

3. Hub/community skills: search/install by name, then verify:

   ```bash
   hermes skills search <skill-name>
   hermes skills install <id-from-search>
   hermes skills list --enabled-only
   ```

4. External skills from the broader skills.sh / Vercel skills ecosystem may need durable source clones. Robust pattern:

   ```bash
   mkdir -p ~/.local/share/skill-sources
   # clone/pull source repos there, then copy real skill directories into ~/.hermes/skills/<category>/<skill>/
   ```

   Avoid relying on symlinks inside ~/.hermes/skills; Hermes may not auto-discover symlinked skill directories reliably.

5. Local-only skills: this manifest records their names and local paths, but a new machine cannot reconstruct their full content from this file alone. For any local-only skill you actually want portable, either:
   - copy the real skill directory into dotfiles under dot_hermes/skills/<category>/<skill>/, or
   - publish it/private-clone it from a durable repo, or
   - add a source URL in the skill frontmatter/manifest and use that during bootstrap.

## Install strategy by source

| Source | Meaning | Action on new machine |
| --- | --- | --- |
| builtin | Ships with Hermes | Install/update Hermes; no dotfiles copy needed |
| skills.sh | Community skill installed through skills ecosystem | Use `hermes skills search <name>` / `hermes skills install <id>` when available; otherwise use durable source clone + real directory copy |
| local | Local/user skill or non-hub skill | Needs source/content tracked separately if it must be portable |

## Skill manifest

| Name | Category | Source | Status | Link/source hint | Description |
| --- | --- | --- | --- | --- | --- |
| dogfood | (none) | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Exploratory QA of web apps: find bugs, evidence, reports. |
| yuanbao | (none) | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Yuanbao (元宝) groups: @mention users, query info/members. |
| caveman | .backup-caveman-install-1775906056 | skills.sh | enabled | skills.sh / Hermes search: `hermes skills search caveman` | Ultra-compressed communication mode. Cuts token usage ~75% by speaking like caveman while keeping full technical accuracy. Supports inten... |
| caveman-commit | .backup-caveman-install-1775906056 | skills.sh | enabled | skills.sh / Hermes search: `hermes skills search caveman-commit` | Ultra-compressed commit message generator. Cuts noise from commit messages while preserving intent and reasoning. Conventional Commits fo... |
| caveman-review | .backup-caveman-install-1775906056 | skills.sh | enabled | skills.sh / Hermes search: `hermes skills search caveman-review` | Ultra-compressed code review comments. Cuts noise from PR feedback while preserving the actionable signal. Each comment is one line: loca... |
| compress | .backup-caveman-install-1775906056 | skills.sh | enabled | skills.sh / Hermes search: `hermes skills search compress` | Compress natural language memory files (CLAUDE.md, todos, preferences) into caveman format to save input tokens. Preserves all technical ... |
| claude-code | autonomous-ai-agents | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Delegate coding to Claude Code CLI (features, PRs). |
| codex | autonomous-ai-agents | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Delegate coding to OpenAI Codex CLI (features, PRs). |
| hermes-agent | autonomous-ai-agents | builtin | enabled | https://github.com/NousResearch/hermes-agent | Complete guide to using and extending Hermes Agent — CLI usage, setup, configuration, spawning additional agents, gateway platforms, skil... |
| opencode | autonomous-ai-agents | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Delegate coding to OpenCode CLI (features, PR review). |
| architecture-diagram | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Dark-themed SVG architecture/cloud/infra diagrams as HTML. |
| ascii-art | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | ASCII art: pyfiglet, cowsay, boxes, image-to-ascii. |
| ascii-video | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | ASCII video: convert video/audio to colored ASCII MP4/GIF. |
| baoyu-comic | creative | builtin | enabled | https://github.com/JimLiu/baoyu-skills#baoyu-comic | Knowledge comics (知识漫画): educational, biography, tutorial. |
| baoyu-infographic | creative | builtin | enabled | https://github.com/JimLiu/baoyu-skills#baoyu-infographic | Infographics: 21 layouts x 21 styles (信息图, 可视化). |
| claude-design | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Design one-off HTML artifacts (landing, deck, prototype). |
| comfyui | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Generate images, video, and audio with ComfyUI — install, launch, manage nodes/models, run workflows with parameter injection. Uses the o... |
| design-md | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Author/validate/export Google's DESIGN.md token spec files. |
| excalidraw | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Hand-drawn Excalidraw JSON diagrams (arch, flow, seq). |
| humanizer | creative | builtin | enabled | https://github.com/blader/humanizer | Humanize text: strip AI-isms and add real voice. |
| ideation | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Generate project ideas via creative constraints. |
| manim-video | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Manim CE animations: 3Blue1Brown math/algo videos. |
| p5js | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | p5.js sketches: gen art, shaders, interactive, 3D. |
| pixel-art | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Pixel art w/ era palettes (NES, Game Boy, PICO-8). |
| popular-web-designs | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | 54 real design systems (Stripe, Linear, Vercel) as HTML/CSS. |
| pretext | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Use when building creative browser demos with @chenglou/pretext — DOM-free text layout for ASCII art, typographic flow around obstacles, ... |
| sketch | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Throwaway HTML mockups: 2-3 design variants to compare. |
| songwriting-and-ai-music | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Songwriting craft and Suno AI music prompts. |
| touchdesigner-mcp | creative | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Control a running TouchDesigner instance via twozero MCP — create operators, set parameters, wire connections, execute Python, build real... |
| jupyter-live-kernel | data-science | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Iterative Python via live Jupyter kernel (hamelnb). |
| arch-ssh-single-client-lockdown | devops | local | enabled | local path: `~/.hermes/skills/devops/arch-ssh-single-client-lockdown` | Set up OpenSSH on Arch/Omarchy for key-only login and restrict access to a single client IP with UFW, including debugging slow/hanging co... |
| chromium-profile-lock-triage | devops | local | enabled | local path: `~/.hermes/skills/devops/chromium-profile-lock-triage` | Diagnose and safely clear stale Chromium/Brave/Electron profile locks on Linux when the app refuses to open because the profile appears t... |
| kanban-orchestrator | devops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Decomposition playbook + specialist-roster conventions + anti-temptation rules for an orchestrator profile routing work through Kanban. T... |
| kanban-worker | devops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Pitfalls, examples, and edge cases for Hermes Kanban workers. The lifecycle itself is auto-injected into every worker's system prompt as ... |
| large-http-download-recovery | devops | local | enabled | local path: `~/.hermes/skills/devops/large-http-download-recovery` | Recover and complete a large HTTP(S) file download when a normal curl transfer stalled or timed out, then verify integrity against remote... |
| linux-fingerprint-support-triage | devops | local | enabled | local path: `~/.hermes/skills/devops/linux-fingerprint-support-triage` | Diagnose Linux fingerprint reader support on Arch/Omarchy systems by identifying the sensor, verifying fprintd/libfprint detection, check... |
| omarchy-blesh-theming | devops | local | enabled | local path: `~/.hermes/skills/devops/omarchy-blesh-theming` | Configure and customize ble.sh syntax-highlighting colors on Omarchy/Bash, including where Omarchy loads ble.sh from, which user config f... |
| omarchy-chezmoi-dotfiles-sync-review | devops | local | enabled | local path: `~/.hermes/skills/devops/omarchy-chezmoi-dotfiles-sync-review` | Review an existing chezmoi-style dotfiles repo against a live Omarchy machine and decide what to keep, replace, or newly track before syn... |
| omarchy-hypr-customization | devops | local | enabled | local path: `~/.hermes/skills/devops/omarchy-hypr-customization` | Customize keyboard and Hyprland behavior on Omarchy using the intended user override files instead of editing Omarchy defaults. |
| omarchy-limine-windows-boot-triage | devops | local | enabled | local path: `~/.hermes/skills/devops/omarchy-limine-windows-boot-triage` | Diagnose Windows boot failures from Limine on Omarchy/Arch, especially 'image not found' errors, by verifying the active Limine config, W... |
| omarchy-starship-prompt-customization | devops | local | enabled | local path: `~/.hermes/skills/devops/omarchy-starship-prompt-customization` | Customize Starship on Omarchy/Bash, including where Omarchy initializes Starship, how to safely replace ~/.config/starship.toml with a th... |
| primeagen-tmux-sessionizer | devops | local | enabled | local path: `~/.hermes/skills/devops/primeagen-tmux-sessionizer` | Install and configure ThePrimeagen's tmux-sessionizer (upstream script version), and avoid confusing it with the unrelated AUR package. |
| webhook-subscriptions | devops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Webhook subscriptions: event-driven agent runs. |
| himalaya | email | builtin | enabled | https://github.com/pimalaya/himalaya | Himalaya CLI: IMAP/SMTP email from terminal. |
| alpha-research | feynman | local | enabled | local path: `~/.hermes/skills/feynman/alpha-research` | Search, read, and query research papers via the `alpha` CLI (alphaXiv-backed). Use when the user asks about academic papers, wants to fin... |
| autoresearch | feynman | local | enabled | local path: `~/.hermes/skills/feynman/autoresearch` | Autonomous experiment loop that tries ideas, measures results, keeps what works, and discards what doesn't. Use when the user asks to opt... |
| contributing | feynman | local | enabled | local path: `~/.hermes/skills/feynman/contributing` | Contribute changes to the Feynman repository itself. Use when the task is to add features, fix bugs, update prompts or skills, change ins... |
| deep-research | feynman | local | enabled | local path: `~/.hermes/skills/feynman/deep-research` | Run a thorough, source-heavy investigation on any topic. Use when the user asks for deep research, a comprehensive analysis, an in-depth ... |
| docker | feynman | local | enabled | local path: `~/.hermes/skills/feynman/docker` | Execute research code inside isolated Docker containers for safe replication, experiments, and benchmarks. Use when the user selects Dock... |
| eli5 | feynman | local | enabled | local path: `~/.hermes/skills/feynman/eli5` | Explain research, papers, or technical ideas in plain English with minimal jargon, concrete analogies, and clear takeaways. Use when the ... |
| jobs | feynman | local | enabled | local path: `~/.hermes/skills/feynman/jobs` | Inspect active background research work including running processes, scheduled follow-ups, and pending tasks. Use when the user asks what... |
| literature-review | feynman | local | enabled | local path: `~/.hermes/skills/feynman/literature-review` | Run a literature review using paper search and primary-source synthesis. Use when the user asks for a lit review, paper survey, state of ... |
| modal-compute | feynman | local | enabled | local path: `~/.hermes/skills/feynman/modal-compute` | Run GPU workloads on Modal's serverless infrastructure. Use when the user needs remote GPU compute for training, inference, benchmarks, o... |
| paper-code-audit | feynman | local | enabled | local path: `~/.hermes/skills/feynman/paper-code-audit` | Compare a paper's claims against its public codebase. Use when the user asks to audit a paper, check code-claim consistency, verify repro... |
| paper-writing | feynman | local | enabled | local path: `~/.hermes/skills/feynman/paper-writing` | Turn research findings into a polished paper-style draft with sections, equations, and citations. Use when the user asks to write a paper... |
| peer-review | feynman | local | enabled | local path: `~/.hermes/skills/feynman/peer-review` | Simulate a tough but constructive peer review of an AI research artifact. Use when the user asks for a review, critique, feedback on a pa... |
| preview | feynman | local | enabled | local path: `~/.hermes/skills/feynman/preview` | Preview Markdown, LaTeX, PDF, or code artifacts in the browser or as PDF. Use when the user wants to review a written artifact, export a ... |
| replication | feynman | local | enabled | local path: `~/.hermes/skills/feynman/replication` | Plan or execute a replication of a paper, claim, or benchmark. Use when the user asks to replicate results, reproduce an experiment, veri... |
| runpod-compute | feynman | local | enabled | local path: `~/.hermes/skills/feynman/runpod-compute` | Provision and manage GPU pods on RunPod for long-running experiments. Use when the user needs persistent GPU compute with SSH access, lar... |
| session-log | feynman | local | enabled | local path: `~/.hermes/skills/feynman/session-log` | Write a durable session log capturing completed work, findings, open questions, and next steps. Use when the user asks to log progress, s... |
| session-search | feynman | local | enabled | local path: `~/.hermes/skills/feynman/session-search` | Search past Feynman session transcripts to recover prior work, conversations, and research context. Use when the user references somethin... |
| source-comparison | feynman | local | enabled | local path: `~/.hermes/skills/feynman/source-comparison` | Compare multiple sources on a topic and produce a grounded comparison matrix. Use when the user asks to compare papers, tools, approaches... |
| watch | feynman | local | enabled | local path: `~/.hermes/skills/feynman/watch` | Set up a recurring research watch on a topic, company, paper area, or product surface. Use when the user asks to monitor a field, track n... |
| minecraft-modpack-server | gaming | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Host modded Minecraft servers (CurseForge, Modrinth). |
| pokemon-player | gaming | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Play Pokemon via headless emulator + RAM reads. |
| codebase-inspection | github | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Inspect codebases w/ pygount: LOC, languages, ratios. |
| github-auth | github | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | GitHub auth setup: HTTPS tokens, SSH keys, gh CLI login. |
| github-code-review | github | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Review PRs: diffs, inline comments via gh or REST. |
| github-issues | github | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Create, triage, label, assign GitHub issues via gh or REST. |
| github-pr-workflow | github | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | GitHub PR lifecycle: branch, commit, open, CI, merge. |
| github-repo-management | github | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Clone/create/fork repos; manage remotes, releases. |
| find-nearby | leisure | local | enabled | local path: `~/.hermes/skills/leisure/find-nearby` | Find nearby places (restaurants, cafes, bars, pharmacies, etc.) using OpenStreetMap. Works with coordinates, addresses, cities, zip codes... |
| mcporter | mcp | local | enabled | https://mcporter.dev | Use the mcporter CLI to list, configure, auth, and call MCP servers/tools directly (HTTP or stdio), including ad-hoc servers, config edit... |
| native-mcp | mcp | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | MCP client: connect servers, register tools (stdio/HTTP). |
| gif-search | media | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Search/download GIFs from Tenor via curl + jq. |
| heartmula | media | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | HeartMuLa: Suno-like song generation from lyrics + tags. |
| songsee | media | builtin | enabled | https://github.com/steipete/songsee | Audio spectrograms/features (mel, chroma, MFCC) via CLI. |
| spotify | media | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Spotify: play, search, queue, manage playlists and devices. |
| youtube-content | media | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | YouTube transcripts to summaries, threads, blogs. |
| audiocraft-audio-generation | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | AudioCraft: MusicGen text-to-music, AudioGen text-to-sound. |
| axolotl | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Axolotl: YAML LLM fine-tuning (LoRA, DPO, GRPO). |
| clip | mlops | local | enabled | local path: `~/.hermes/skills/mlops/models/clip` | OpenAI's model connecting vision and language. Enables zero-shot image classification, image-text matching, and cross-modal retrieval. Tr... |
| dspy | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | DSPy: declarative LM programs, auto-optimize prompts, RAG. |
| dspy-advanced-workflow | mlops | skills.sh | enabled | skills.sh / Hermes search: `hermes skills search dspy-advanced-workflow` | Drive a complete DSPy 3.2.x project end-to-end — spec → program → metric → baseline → GEPA optimize → export → deploy. Orchestrates the o... |
| dspy-evaluation-harness | mlops | skills.sh | enabled | skills.sh / Hermes search: `hermes skills search dspy-evaluation-harness` | Build DSPy evaluation harnesses with rich-feedback metrics that are essential for GEPA optimization. Use when writing a metric function, ... |
| dspy-fundamentals | mlops | skills.sh | enabled | skills.sh / Hermes search: `hermes skills search dspy-fundamentals` | Write idiomatic DSPy 3.2.x programs — typed Signatures, dspy.Module subclasses, Predict/ChainOfThought/ReAct/ProgramOfThought, and save/l... |
| dspy-gepa-optimizer | mlops | skills.sh | enabled | skills.sh / Hermes search: `hermes skills search dspy-gepa-optimizer` | Optimize DSPy programs with dspy.GEPA — the reflective/evolutionary optimizer that is the 2026 gold standard for DSPy (beats MIPROv2 on c... |
| dspy-rlm-module | mlops | skills.sh | enabled | skills.sh / Hermes search: `hermes skills search dspy-rlm-module` | Use dspy.RLM (Recursive Language Model) for reasoning over contexts too large to fit in an LLM's working window — entire codebases, long ... |
| evaluating-llms-harness | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | lm-eval-harness: benchmark LLMs (MMLU, GSM8K, etc.). |
| fine-tuning-with-trl | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | TRL: SFT, DPO, PPO, GRPO, reward modeling for LLM RLHF. |
| gguf-quantization | mlops | local | enabled | local path: `~/.hermes/skills/mlops/inference/gguf` | GGUF format and llama.cpp quantization for efficient CPU/GPU inference. Use when deploying models on consumer hardware, Apple Silicon, or... |
| grpo-rl-training | mlops | local | enabled | local path: `~/.hermes/skills/mlops/training/grpo-rl-training` | Expert guidance for GRPO/RL fine-tuning with TRL for reasoning and task-specific model training |
| guidance | mlops | local | enabled | local path: `~/.hermes/skills/mlops/inference/guidance` | Control LLM output with regex and grammars, guarantee valid JSON/XML/code generation, enforce structured formats, and build multi-step wo... |
| huggingface-hub | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | HuggingFace hf CLI: search/download/upload models, datasets. |
| llama-cpp | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | llama.cpp local GGUF inference + HF Hub model discovery. |
| modal-serverless-gpu | mlops | local | enabled | local path: `~/.hermes/skills/mlops/cloud/modal` | Serverless GPU cloud platform for running ML workloads. Use when you need on-demand GPU access without infrastructure management, deployi... |
| obliteratus | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | OBLITERATUS: abliterate LLM refusals (diff-in-means). |
| outlines | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Outlines: structured JSON/regex/Pydantic LLM generation. |
| peft-fine-tuning | mlops | local | enabled | local path: `~/.hermes/skills/mlops/training/peft` | Parameter-efficient fine-tuning for LLMs using LoRA, QLoRA, and 25+ methods. Use when fine-tuning large models (7B-70B) with limited GPU ... |
| pytorch-fsdp | mlops | local | enabled | local path: `~/.hermes/skills/mlops/training/pytorch-fsdp` | Expert guidance for Fully Sharded Data Parallel training with PyTorch FSDP - parameter sharding, mixed precision, CPU offloading, FSDP2 |
| rlm | mlops | skills.sh | enabled | skills.sh / Hermes search: `hermes skills search rlm` | Plan and build an RLM (Recursive Language Model) with predict-rlm, or contribute to predict-rlm/RLM-GEPA itself. Interactively defines in... |
| segment-anything-model | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | SAM: zero-shot image segmentation via points, boxes, masks. |
| serving-llms-vllm | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | vLLM: high-throughput LLM serving, OpenAI API, quantization. |
| stable-diffusion-image-generation | mlops | local | enabled | local path: `~/.hermes/skills/mlops/models/stable-diffusion` | State-of-the-art text-to-image generation with Stable Diffusion models via HuggingFace Diffusers. Use when generating images from text pr... |
| unsloth | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Unsloth: 2-5x faster LoRA/QLoRA fine-tuning, less VRAM. |
| weights-and-biases | mlops | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | W&B: log ML experiments, sweeps, model registry, dashboards. |
| whisper | mlops | local | enabled | local path: `~/.hermes/skills/mlops/models/whisper` | OpenAI's general-purpose speech recognition model. Supports 99 languages, transcription, translation to English, and language identificat... |
| grounded-project-report-writing | note-taking | local | enabled | local path: `~/.hermes/skills/note-taking/grounded-project-report-writing` | Write a standalone project/experiment report grounded in repo artifacts, with a clear executive narrative, selective technical detail, an... |
| obsidian | note-taking | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Read, search, create, and edit notes in the Obsidian vault. |
| airtable | productivity | builtin | enabled | https://airtable.com/developers/web/api/introduction | Airtable REST API via curl. Records CRUD, filters, upserts. |
| google-workspace | productivity | builtin | enabled | https://github.com/NousResearch/hermes-agent | Gmail, Calendar, Drive, Docs, Sheets via gws CLI or Python. |
| linear | productivity | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Linear: manage issues, projects, teams via GraphQL + curl. |
| maps | productivity | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Geocode, POIs, routes, timezones via OpenStreetMap/OSRM. |
| nano-pdf | productivity | builtin | enabled | https://pypi.org/project/nano-pdf/ | Edit PDF text/typos/titles via nano-pdf CLI (NL prompts). |
| notion | productivity | builtin | enabled | https://developers.notion.com | Notion API via curl: pages, databases, blocks, search. |
| ocr-and-documents | productivity | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Extract text from PDFs and scanned documents. Use web_extract for remote URLs, pymupdf for local text-based PDFs, marker-pdf for OCR/scan... |
| powerpoint | productivity | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Create, read, edit .pptx decks, slides, notes, templates. |
| teams-meeting-pipeline | productivity | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Operate the Teams meeting summary pipeline via Hermes CLI — summarize meetings, inspect pipeline status, replay jobs, manage Microsoft Gr... |
| godmode | red-teaming | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Jailbreak LLMs: Parseltongue, GODMODE, ULTRAPLINIAN. |
| ade-mindset-lab-bootstrap | research | local | enabled | local path: `~/.hermes/skills/research/ade-mindset-lab-bootstrap` | Bootstrap a small git-tracked Agentic Data Engineering learning lab focused on explicit learning questions, failure taxonomy, and journal... |
| ade-query-support-oracles-and-masked-bundles | research | local | enabled | local path: `~/.hermes/skills/research/ade-query-support-oracles-and-masked-bundles` | Review an ADE query workload against a mixed bibliography bundle, patch weak query/data support with targeted fetches or query rewrites, ... |
| ade-rlm-file-backed-context | research | local | enabled | local path: `~/.hermes/skills/research/ade-rlm-file-backed-context` | Keep ADE/DSPy RLM prompts high-level by exposing bundle/query/report artifacts through REPL-mounted files instead of large input variables. |
| ade-run-review | research | local | enabled | local path: `~/.hermes/skills/research/ade-run-review` | Review an ADE experiment run by checking artifacts against the oracle, REPL/log evidence, and failure taxonomy instead of trusting evalua... |
| ade-sequential-task-ladder | research | local | enabled | local path: `~/.hermes/skills/research/ade-sequential-task-ladder` | Reframe an ADE lab into a sequential build/use/evolve/recommend ladder with explicit file-based handoff artifacts between tasks. |
| arxiv | research | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Search arXiv papers by keyword, author, category, or ID. |
| blogwatcher | research | builtin | enabled | https://github.com/JulienTant/blogwatcher-cli | Monitor blogs and RSS/Atom feeds via blogwatcher-cli tool. |
| llm-wiki | research | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Karpathy's LLM Wiki — build and maintain a persistent, interlinked markdown knowledge base. Ingest sources, query compiled knowledge, and... |
| polymarket | research | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Query Polymarket: markets, prices, orderbooks, history. |
| research-paper-writing | research | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Write ML papers for NeurIPS/ICML/ICLR: design→submit. |
| openhue | smart-home | builtin | enabled | https://www.openhue.io/cli | Control Philips Hue lights, scenes, rooms via OpenHue CLI. |
| x-article-offline-save | social-media | local | enabled | local path: `~/.hermes/skills/social-media/x-article-offline-save` | Use the browser to extract an X longform Article or normal X status post from a tweet/article URL, save a clean offline copy to Downloads... |
| xitter | social-media | local | enabled | https://github.com/Infatoshi/x-cli | Interact with X/Twitter via the x-cli terminal client using official X API credentials. Use for posting, reading timelines, searching twe... |
| xurl | social-media | builtin | enabled | https://github.com/xdevplatform/xurl | X/Twitter via xurl CLI: post, search, DM, media, v2 API. |
| debugging-hermes-tui-commands | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Debug Hermes TUI slash commands: Python, gateway, Ink UI. |
| dspy-pyodide-repl-packages | software-development | local | enabled | local path: `~/.hermes/skills/software-development/dspy-pyodide-repl-packages` | Prepare DSPy PythonInterpreter (Deno + Pyodide) with supported external libraries, cache them, and avoid false assumptions about stdlib/p... |
| dspy-rlm-parse-hardening | software-development | local | enabled | local path: `~/.hermes/skills/software-development/dspy-rlm-parse-hardening` | Harden DSPy RLM runs against malformed action outputs and AdapterParseError cascades, especially with GLM/OpenRouter. |
| extract-nested-project-to-standalone-repo | software-development | local | enabled | local path: `~/.hermes/skills/software-development/extract-nested-project-to-standalone-repo` | Move a project directory out of an enclosing workspace into its own standalone repo, then remove hidden dependencies on the parent repo a... |
| feynman-package-runtime-mismatch | software-development | local | enabled | local path: `~/.hermes/skills/software-development/feynman-package-runtime-mismatch` | Diagnose and fix Feynman package update failures caused by npm/node ABI mismatches between the Feynman bundled runtime and the user's amb... |
| hermes-agent-skill-authoring | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Author in-repo SKILL.md: frontmatter, validator, structure. |
| hermes-cli-statusbar-customization | software-development | local | enabled | local path: `~/.hermes/skills/software-development/hermes-cli-statusbar-customization` | Customize Hermes CLI's footer status bar in cli.py, including adding/removing fields and updating focused tests. |
| hermes-zai-provider-debugging | software-development | local | enabled | local path: `~/.hermes/skills/software-development/hermes-zai-provider-debugging` | Diagnose Hermes Agent failures when using the native z.ai provider, especially HTTP 400 errors caused by endpoint/model mismatches betwee... |
| lazyvim-molten-python-notebooks | software-development | local | enabled | local path: `~/.hermes/skills/software-development/lazyvim-molten-python-notebooks` | Set up molten.nvim for Python notebook-style workflows in LazyVim/Neovim, including jupytext/quarto integration and a dedicated Python ho... |
| lazyvim-plugin-conventions | software-development | local | enabled | local path: `~/.hermes/skills/software-development/lazyvim-plugin-conventions` | Maintain this user's LazyVim plugin config using their local file-layout conventions, including explorer swaps and markdown-lint overrides. |
| node-inspect-debugger | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Debug Node.js via --inspect + Chrome DevTools Protocol CLI. |
| plan | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Plan mode: write markdown plan to .hermes/plans/, no exec. |
| python-debugpy | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Debug Python: pdb REPL + debugpy remote (DAP). |
| requesting-code-review | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Pre-commit review: security scan, quality gates, auto-fix. |
| rlm-controller-runtime-audit | software-development | local | enabled | local path: `~/.hermes/skills/software-development/rlm-controller-runtime-audit` | Audit a multi-pass RLM controller when broad runs are too slow or escalations seem wasteful. Uses code-path inspection plus trajectory-lo... |
| sharepoint-dspy-enrichment-scaffold | software-development | local | enabled | local path: `~/.hermes/skills/software-development/sharepoint-dspy-enrichment-scaffold` | Extend a SharePoint/Microsoft Graph ingestion scaffold with a separate DSPy-based AI enrichment pipeline for document facts, project roll... |
| sharepoint-graph-ingestion-scaffold | software-development | local | enabled | local path: `~/.hermes/skills/software-development/sharepoint-graph-ingestion-scaffold` | Build a fast interview-ready Python scaffold for ingesting a SharePoint folder tree via Microsoft Graph into SQLite, with pagination, thr... |
| spike | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Throwaway experiments to validate an idea before build. |
| subagent-driven-development | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Execute plans via delegate_task subagents (2-stage review). |
| systematic-debugging | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | 4-phase root cause debugging: understand bugs before fixing. |
| test-driven-development | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | TDD: enforce RED-GREEN-REFACTOR, tests before code. |
| writing-plans | software-development | builtin | enabled | Hermes skills catalog: https://hermes-agent.nousresearch.com/docs/reference/skills-catalog | Write implementation plans: bite-sized tasks, paths, code. |

## Verification commands

```bash
hermes skills list --enabled-only
python - <<'PY'
from pathlib import Path
base = Path.home() / ".hermes" / "skills"
bad = []
for skill in base.rglob("SKILL.md"):
    d = skill.parent
    if d.is_symlink():
        bad.append(str(d))
print("symlinked skill dirs:", bad)
PY
```
