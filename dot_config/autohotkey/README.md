# AutoHotkey v2 keymaps

This is the Windows counterpart to the macOS Karabiner setup. It keeps the
portable behavior aligned while using Windows-native conventions where the
platform differs.

## Install

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Apply this repo so the directory is at
   `%USERPROFILE%\.config\autohotkey`.
3. In PowerShell, run:

   ```powershell
   & "$HOME\.config\autohotkey\install.ps1"
   ```

The installer creates a shortcut in the current user's Startup folder and
starts `main.ahk`. Re-running it safely replaces the running script because the
script uses `#SingleInstance Force`.

To remove only the startup shortcut:

```powershell
& "$HOME\.config\autohotkey\install.ps1" -Uninstall
```

## Key behavior

- Caps Lock sends Escape.
- Escape sends the backtick key; Shift+Escape sends tilde.
- Win+Escape and Win+Shift+Escape preserve the modifier while sending backtick.
- Win+Shift+S uses Windows' native region screenshot UI.
- In known terminal emulators, physical left Win and left Ctrl are swapped.
  Physical left Win+C/V sends terminal copy/paste; physical left Ctrl+C/V keeps
  the control-key behavior used by shells.
- Right Win+letter/number switches to or launches the app in `apps.ini`.
- Right Win+Shift+letter/number does the same thing.
- Right Win+Alt+letter/number assigns the focused app to that key. This updates
  the local `apps.ini`; copy the result back into the repo when it is worth
  sharing across Windows machines.
- An unmapped Right Win key cycles running apps whose process starts with that
  letter.

The seeded app commands are best-effort executable names. Windows Store apps,
portable installs, and differently named executables may need reassignment with
Right Win+Alt+key or a manual edit to `apps.ini`.

## Lofree media-key scrolling

`settings.ini` includes an opt-in version of the smooth, reversed scroll used
by the macOS Lofree Flow 2 touch bar. Set `lofree_scroll=1` to map Volume Up to
a -72 wheel delta and Volume Down to +72, split across seven small events. The
signs intentionally match the existing Karabiner helper.

This is disabled by default because plain AutoHotkey can see the media key but
cannot reliably tell which physical keyboard sent it. Enabling it therefore
captures the same keys from every attached keyboard. Brightness media keys also
vary by keyboard driver; use AutoHotkey's Key History and add any recognized key
names to `up_hotkeys` or `down_hotkeys`. Device-specific filtering would require
an additional input driver or interception library.

## Tuning

- Disable terminal modifier swapping with `terminal_modifier_swap=0`.
- Add another terminal process name to the `terminalProcesses` map in
  `main.ahk`.
- Change scroll direction, distance, steps, or delay in `settings.ini`.
- Reload after edits by double-clicking `main.ahk` or rerunning `install.ps1`.

Validation on 2026-07-13 used AutoHotkey v2.0.26 on Windows 11. The tracked
script loaded successfully, the startup shortcut launched the durable config,
and an external-input smoke test confirmed Caps Lock to Escape and Escape to
backtick. Right Win app switching, the Lofree media events, and terminal-specific
modifier behavior still need hands-on validation with the relevant physical
keyboard and terminal apps.
