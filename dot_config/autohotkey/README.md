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

- The left Win key and the left Ctrl key are swapped. Win acts as the macOS
  Command key — it sends Ctrl for every combo, so Win+C copies, Win+V pastes,
  Win+A selects all, everywhere — which matches the Mac layout where Command sits
  where the Windows key sits. Ctrl sends Win in return, so there is still a real
  Windows key on the board for the Start menu, Win+Tab, Win+arrow snapping, and
  the search binding below. Alt is untouched (opt=alt). Right Ctrl, and any other
  keyboard, still send a plain Ctrl. A lone Ctrl tap now opens the Start menu, the
  way a real Win key does, while a lone Win tap does nothing, like Cmd.
- Ctrl+Space opens Windows Search, standing in for Spotlight. Ctrl sends Win, so
  the keystroke arrives as Win+Space (natively an input-language cycle, unused
  here) and the script turns it into a real Win+S.
- Win+Shift+S opens Windows' native region screenshot UI. (Because Win sends
  Ctrl, a literal Ctrl+Shift+S also opens it. The physical Ctrl key reaches the
  same UI directly, since it now sends Win.)
- Win+Shift+C opens the Windows clipboard history. Win+V is normally that, but
  Win now sends Ctrl so Win+V pastes; this restores the history picker. (A
  literal Ctrl+Shift+C also opens it. Clipboard history must be enabled in
  Windows Settings.) This hotkey is scoped off inside a terminal, where
  Ctrl+Shift+C is the app's own copy binding.
- Inside a terminal, Cmd-style Win combos that the terminal puts on
  Ctrl+Shift are translated: Win+T new tab, Win+W close pane, Win+N new window,
  Win+F find. A physically pressed Ctrl is left alone, so shell readline keys
  (Ctrl+W delete word, Ctrl+T transpose, Ctrl+F forward char) still work — but on
  this layout that means Right Ctrl, because the left Ctrl key now sends Win. This
  is the `terminal_modifier_swap` feature; see below.
- Copy and paste in the terminal need no swap. Windows Terminal is configured
  with Ctrl+C as copy and Ctrl+V as paste, and its copy action falls through to
  the shell when nothing is selected, so Win+C copies and a bare Ctrl+C still
  sends SIGINT.
- Caps Lock sends Escape.
- Escape sends the backtick key; Shift+Escape sends tilde.
- Win+Escape and Win+Shift+Escape preserve the modifier while sending backtick.
- Right Alt+letter/number switches to or launches the app in `apps.ini`. Right
  Alt sits where the macOS right Command key does, mirroring the "rcmd" switcher.
- Right Alt+Shift+letter/number does the same thing.
- Right Alt+Ctrl+letter/number assigns the focused app to that key. This updates
  the local `apps.ini`; copy the result back into the repo when it is worth
  sharing across Windows machines.
- Right Alt+0 jumps to the app used before this one; press again to jump back.
- An unmapped Right Alt+key cycles running apps whose process starts with that
  letter.
- The right Command key on a Mac-style keyboard reports as Right Win on Windows,
  so it is remapped to Right Alt — that is what drives the switcher above. A lone
  tap acts like a normal Alt.

The seeded app commands are best-effort executable names. Windows Store apps,
portable installs, and differently named executables may need reassignment with
Right Win+Alt+key or a manual edit to `apps.ini`.

There is no Ghostty build for Windows, so the two keys that open the main
terminal on macOS (`0` and `m`) are mapped to Windows Terminal on the `archlinux`
WSL profile. `p` stays on the PowerShell profile of the same app.

## Win+L still locks the machine

Windows handles Win+L below the keyboard hook AutoHotkey installs, so the Win key
remap cannot stop it: pressing the Cmd key with `L` locks the workstation even
though the focused app only ever receives Ctrl+L. The right Command key reports
as Right Win, so Right Cmd+L (Linear) locks it too. This is a long-standing
AutoHotkey limitation, not a bug in this script — `Ctrl+Alt+Del` is unblockable
for the same reason. Fixing it takes one change outside this repo. Two options:

**1. Turn off the Win+L lock (per user, no admin, no reboot).**

```powershell
New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Force |
  New-ItemProperty -Name DisableLockWorkstation -Value 1 -PropertyType DWord -Force
```

Sign out and back in. Win+L then does nothing at the OS level and the script's
Ctrl+L reaches the app. The cost is that the keyboard lock shortcut is gone
entirely, including from the Ctrl+Alt+Del screen and the Start menu user tile;
`rundll32.exe user32.dll,LockWorkStation` may also be refused under this policy.
Undo with `Remove-ItemProperty` on the same value. A corporate GPO can re-apply
its own setting on top of this.

**2. Swap the keys in the keyboard driver instead (machine-wide, admin, reboot).**

```powershell
$map = [byte[]](0,0,0,0, 0,0,0,0, 3,0,0,0, 0x1D,0x00,0x5B,0xE0, 0x5B,0xE0,0x1D,0x00, 0,0,0,0)
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' `
  -Name 'Scancode Map' -Value $map -Type Binary
```

Reboot. The Cmd key becomes a real Ctrl and the Ctrl key a real Win before any
hook runs, so Win+L can never fire from the Cmd key, and Win+L from the Ctrl key
still locks the machine on purpose. This applies to every attached keyboard and
every user on the machine. It also replaces the script's own remap, so
`LWin::LCtrl` and `LCtrl::LWin` in `main.ahk` must be deleted, and with them the
`terminal_modifier_swap` feature: the driver rewrites the scancode, so the script
can no longer tell a Cmd press from a Ctrl press. Undo with
`Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' -Name 'Scancode Map'`
and a reboot.

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

## Terminal modifier swap

`LWin::LCtrl` makes Win behave like Command everywhere, which is right for GUI
apps but collides inside a terminal: on macOS, Cmd+W closes a tab while Ctrl+W
deletes a word, and after the remap both arrive as Ctrl+W.

Windows Terminal puts its window and tab commands on Ctrl+Shift+*key*, so while a
terminal is focused the Cmd-style press is translated to that form. The two are
told apart by physical key state — `LWin::LCtrl` is a hook-based remap, so a
physically held LWin is still visible to `GetKeyState(..., "P")` even though the
modifier reaching the app is Ctrl.

That test lives in the `#HotIf` context rather than inside the handlers, which
matters: with it there, a real Ctrl press leaves the hotkeys unarmed and the
keystroke reaches the terminal natively. Handling the pass-through inside a
handler would mean re-sending Ctrl+*key*, which AHK's own hook catches as the
same hotkey and loops forever.

The Ctrl side of that pass-through moved when the left Ctrl key became Win: the
readline keys now come from Right Ctrl or another keyboard. If that trade is
wrong for how you use the terminal, set `terminal_modifier_swap=0` — then Cmd+W
deletes a word like Ctrl+W and the terminal's own Ctrl+Shift+W closes the pane.

## Tuning

- Disable terminal modifier swapping with `terminal_modifier_swap=0`.
- Add another terminal process name to the `TerminalProcesses` map built by
  `BuildTerminalProcesses()` in `main.ahk`. Comparison is case-insensitive; it
  ships with `WindowsTerminal.exe`, `wt.exe`, and `OpenConsole.exe`.
- Change scroll direction, distance, steps, or delay in `settings.ini`.
- Reload after edits by double-clicking `main.ahk` or rerunning `install.ps1`.

Validation on 2026-08-03 (second Windows machine) ran `AutoHotkey64.exe
/validate` on `main.ahk` for a clean parse, installed the startup shortcut, and
confirmed the script stays resident with no load-time error dialog. The
`terminal_modifier_swap` keys, Right Win app switching, and the Lofree media
events were **not** key-tested, because verifying them needs real physical
keypresses that a scripted session cannot produce — synthetic input does not
register as physical, which is exactly what the LWin test reads. Try Win+T and
Ctrl+W in Windows Terminal first; if either misbehaves, set
`terminal_modifier_swap=0` and rerun `install.ps1`.

Validation on 2026-07-13 used AutoHotkey v2.0.26 on Windows 11. The tracked
script loaded successfully, the startup shortcut launched the durable config,
and an external-input smoke test confirmed Caps Lock to Escape and Escape to
backtick. Right Win app switching, the Lofree media events, and terminal-specific
modifier behavior still need hands-on validation with the relevant physical
keyboard and terminal apps.
