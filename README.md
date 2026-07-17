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
- Ghostty under `dot_config/ghostty/config.tmpl`
- tmux-sessionizer config under `dot_config/tmux-sessionizer/`
- custom tmux-sessionizer executable under `dot_local/bin/tmux-sessionizer`
- personal Git identity by default, with a work-only include for repos under `~/work/`
- desktop config under `dot_config/hypr/`, `dot_config/waybar/`, and `dot_config/walker/`
- Omarchy post-update reapply hook under `dot_config/omarchy/hooks/post-update`
- Hermes config under `dot_hermes/config.yaml`

### macOS
- split zsh layout under `dot_config/zsh/`
- tiny `dot_zshrc.tmpl` loader
- sanitized `dot_zshenv` for non-interactive Cargo paths
- `dot_tmux.conf` loader that points tmux at XDG config
- Ghostty's Catppuccin theme and macOS font size through an OS-aware template
- Karabiner rules, import assets, Right Command app mappings, helper scripts, and the Swift scroll-helper source
- sanitized Claude Code settings and status line under `dot_claude/`
- stable, sanitized Codex preferences under `dot_codex/config.toml`
- GitHub SSH host configuration under `dot_ssh/config`

### Windows
- AutoHotkey v2 keymaps, app-switch mappings, feature settings, and startup
  installer under `dot_config/autohotkey/`
- portable Karabiner behavior adapted to Windows conventions, including
  Caps/Escape, terminal modifiers, Right Win app switching, and opt-in Lofree
  media-key scrolling

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
- `~/.config/karabiner/automatic_backups/*`

### Scratch / machine-specific leftovers
- temporary Neovim scratch files like `test.qmd`
- Omarchy-generated backup files like `*.bak.*`
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
- `~/.config/hypr/*`
- `~/.config/waybar/*`
- `~/.config/walker/*`
- `~/.config/omarchy/hooks/post-update`
- `~/.hermes/config.yaml`

After applying shell changes, restart shell or source the relevant Omarchy Bash loader. The post-update hook re-applies the tracked Omarchy Bash and desktop configs after future `omarchy-update` runs, because Omarchy's own update pulls/reset files inside `~/.local/share/omarchy`.

### On macOS
Use the split zsh config:
- `~/.zshrc` should stay a tiny loader
- main config lives under `~/.config/zsh/`
- tmux should enter through `~/.tmux.conf`, which loads `~/.config/tmux/tmux.conf`

Secrets should come from a local untracked file:
- `~/.credentials/.env`

The `zx` launcher intentionally reads only a Z.AI-compatible key from
`~/.creds/.env`; it does not source that whole file into the shell.

The zsh env file exports a small allowlist of GUI env vars with `launchctl setenv` when present.

Karabiner restoration also needs its helpers:
- `karabiner-rcmd-map` and `karabiner-rcmd-switch` are applied to `~/.local/bin/`
- chezmoi compiles `~/.local/src/karabiner-scroll-helper/main.swift` after changes on macOS
- timestamped Karabiner backups remain local and untracked

### On Windows
Apply `dot_config/autohotkey/` to `%USERPROFILE%\.config\autohotkey`, install
AutoHotkey v2, then run:

```powershell
& "$HOME\.config\autohotkey\install.ps1"
```

See `dot_config/autohotkey/README.md` for the keymap, per-app assignment flow,
and the device-filtering limitation of the optional Lofree scroll mapping.

### On Arch WSL

WSL is a first-class chezmoi target. `.chezmoiignore` drops macOS-only files
(Karabiner), Windows-only files (AutoHotkey), and the Omarchy desktop stack
(hypr/waybar/walker/ghostty/omarchy bash) when the kernel reports Microsoft.

Bootstrap on a fresh distro:

```sh
sudo pacman -S --needed base-devel git zsh neovim tmux starship fzf ripgrep fd \
  eza bat zoxide chezmoi github-cli nodejs npm zsh-autosuggestions zsh-syntax-highlighting
chezmoi init https://github.com/vkhangpham/dotfiles.git --apply
```

The zsh split config is the shell entrypoint (same as macOS); `dot_config/zsh/init`
picks up fzf/autosuggestions/syntax-highlighting from Arch's `/usr/share` paths.

## Claude / Codex / Hermes notes

### Claude Code
Tracked file:
- `dot_claude/settings.json`

This file is sanitized.
Do not put raw auth tokens back into it.

### Codex
Tracked file:
- `dot_codex/config.toml`

This contains stable preferences and plugin enablement only. Auth, project trust,
generated marketplace revisions, app-version paths, and MCP runtime state remain local.

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
