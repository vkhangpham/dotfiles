#!/usr/bin/env bash
# Claude Code statusLine — styled after Starship Catppuccin Mocha

input=$(cat)

# Catppuccin Mocha palette (ANSI approximate / 24-bit truecolor)
surface0="\033[38;2;49;50;68m"       # #313244
peach="\033[38;2;250;179;135m"       # #fab387
green="\033[38;2;166;227;161m"       # #a6e3a1
teal="\033[38;2;148;226;213m"        # #94e2d5
mauve="\033[38;2;203;166;247m"       # #cba6f7
reset="\033[0m"

# --- Data from Claude Code ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten cwd: replace $HOME with ~, keep last 3 segments
if [ -n "$cwd" ]; then
  short_cwd="${cwd/#$HOME/~}"
  # Keep at most last 3 path components
  short_cwd=$(echo "$short_cwd" | awk -F'/' '{
    n=NF; if(n>3){ printf "…/"; for(i=n-2;i<=n;i++) printf "%s%s",$i,(i<n?"/":"") } else print $0
  }')
fi

# --- Git info (read from transcript path's git context, or live) ---
git_branch=""
git_status_str=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  # Build a short status indicator
  git_flags=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  modified=$(echo "$git_flags" | grep -c '^ M\| M' 2>/dev/null || true)
  untracked=$(echo "$git_flags" | grep -c '^??' 2>/dev/null || true)
  staged=$(echo "$git_flags" | grep -c '^[MADRCU]' 2>/dev/null || true)
  status_parts=""
  [ "$staged" -gt 0 ]    && status_parts="${status_parts}+${staged} "
  [ "$modified" -gt 0 ]  && status_parts="${status_parts}~${modified} "
  [ "$untracked" -gt 0 ] && status_parts="${status_parts}?${untracked} "
  git_status_str="${status_parts% }"
fi

# --- Context window ---
ctx_str=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  ctx_str="${used_int}% ctx"
fi

# --- Assemble line ---
# Format:  user  |  dir  |  branch [status]  |  model  ctx%

line=""

# Username segment (surface0 color)
line="${line}${surface0} $(whoami) ${reset}"

# Separator
line="${line}${peach}|${reset}"

# Directory segment
if [ -n "$short_cwd" ]; then
  line="${line}${peach} ${short_cwd} ${reset}"
fi

# Git branch segment
if [ -n "$git_branch" ]; then
  line="${line}${green}|${reset}"
  if [ -n "$git_status_str" ]; then
    line="${line}${green}  ${git_branch} ${git_status_str} ${reset}"
  else
    line="${line}${green}  ${git_branch} ${reset}"
  fi
fi

# Model segment
if [ -n "$model" ]; then
  line="${line}${teal}|${reset}"
  line="${line}${teal} ${model}${reset}"
fi

# Context window
if [ -n "$ctx_str" ]; then
  line="${line}${mauve} [${ctx_str}]${reset}"
fi

printf "%b\n" "$line"
