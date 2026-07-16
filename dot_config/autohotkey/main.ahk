#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

Persistent
SetTitleMatchMode(2)
SendMode("Input")
SetWorkingDir(A_ScriptDir)

global AppsIni := A_ScriptDir . "\apps.ini"
global SettingsIni := A_ScriptDir . "\settings.ini"
global LofreeScroll := ReadBool("features", "lofree_scroll", false)
global ScrollSteps := Max(1, IniRead(SettingsIni, "scroll", "steps", "7") + 0)
global ScrollDelayMs := Max(0, IniRead(SettingsIni, "scroll", "delay_ms", "4") + 0)

RegisterAppHotkeys()
RegisterScrollHotkeys()

; Match the portable parts of the macOS Karabiner layout. CapsLock sends Escape,
; but it must disable the Escape hotkey below for that instant. Otherwise the
; synthetic Escape re-triggers Escape::backtick (AHK fires hotkeys on its own
; same-level keystrokes) and CapsLock would type a backtick instead of Escape.
CapsLock:: {
    Hotkey("Escape", "Off")
    Send("{Escape}")
    Hotkey("Escape", "On")
}
Escape::Send("{vkC0}")
+Escape::Send("+{vkC0}")
#Escape::Send("#{vkC0}")
#+Escape::Send("#+{vkC0}")

; The right Command key on a Mac-style keyboard reports as Right Win on Windows.
; Remap it to Right Alt so it (a) drives the >! app-switcher hotkeys below and
; (b) can never combine into Win+L, which would lock the machine and cannot be
; blocked by a normal hotkey. A lone tap becomes a harmless Right Alt.
RWin::RAlt

; macOS-style Command key. On the Mac layout the Command key sits where the
; Windows key sits (right of Alt) and is the primary shortcut modifier: Cmd+C
; copies, Cmd+V pastes, and so on. Make the left Win key behave like Cmd by
; sending Ctrl for every combo. Physical Ctrl and Alt are left untouched, so
; ctrl=ctrl and opt=alt as on the Mac. A lone Win tap now does nothing, like
; Cmd, instead of opening the Start menu.
LWin::LCtrl

; Keep the native Win+Shift+S region screenshot. After the remap above a physical
; Win+Shift+S arrives as Ctrl+Shift+S, so open the screen-snip overlay for that
; combo. (A literal Ctrl+Shift+S also opens it, which is unused on the Mac layout.)
^+s::Run("ms-screenclip:")

ReadBool(section, key, defaultValue) {
    global SettingsIni
    fallback := defaultValue ? "1" : "0"
    value := StrLower(Trim(IniRead(SettingsIni, section, key, fallback)))
    return value = "1" || value = "true" || value = "yes" || value = "on"
}

RegisterAppHotkeys() {
    keys := "abcdefghijklmnopqrstuvwxyz0123456789"
    Loop Parse, keys {
        key := A_LoopField
        ; Right Alt is the app-switcher trigger: it sits where the Mac right
        ; Command key does, so Right Alt+key mirrors the macOS "rcmd" switcher.
        ; Add Ctrl (Right Alt+Ctrl+key) to assign the focused app to a key.
        Hotkey(">!" . key, SwitchMappedApp.Bind(key))
        Hotkey(">!+" . key, SwitchMappedApp.Bind(key))
        Hotkey("^>!" . key, AssignActiveApp.Bind(key))
        Hotkey("^>!+" . key, AssignActiveApp.Bind(key))
    }
}

ReadApp(key) {
    global AppsIni
    raw := IniRead(AppsIni, "apps", key, "")
    if raw = ""
        return false

    parts := StrSplit(raw, "|")
    if parts.Length < 3
        return false

    return {
        Name: Trim(parts[1]),
        Criteria: Trim(parts[2]),
        Command: Trim(parts[3])
    }
}

SwitchMappedApp(key, *) {
    app := ReadApp(key)
    if app {
        if app.Criteria = "" {
            Notify("No window criteria configured for " . app.Name)
            return
        }

        try windows := WinGetList(app.Criteria)
        catch Error as err {
            Notify("Invalid window criteria for " . app.Name . ": " . err.Message)
            return
        }
        if windows.Length {
            CycleWindows(windows)
            return
        }

        if app.Command = "" {
            Notify("No launch command configured for " . app.Name)
            return
        }

        try {
            Run(app.Command)
            hwnd := WinWait(app.Criteria, , 5)
            if hwnd
                WinActivate(hwnd)
            else
                Notify("Started " . app.Name . ", but no matching window appeared")
        } catch Error as err {
            Notify("Could not start " . app.Name . ": " . err.Message)
        }
        return
    }

    windows := FindDynamicWindows(key)
    if !windows.Length {
        Notify("No mapping or running app for Right Alt+" . StrUpper(key))
        return
    }
    CycleWindows(windows)
}

AssignActiveApp(key, *) {
    global AppsIni
    hwnd := WinExist("A")
    if !hwnd {
        Notify("No active window to assign")
        return
    }

    try {
        processName := WinGetProcessName(hwnd)
        processPath := WinGetProcessPath(hwnd)
        displayName := RegExReplace(processName, "i)\.exe$")
        criteria := "ahk_exe " . processName
        command := Chr(34) . processPath . Chr(34)
        IniWrite(displayName . "|" . criteria . "|" . command, AppsIni, "apps", key)
        Notify("Assigned Right Alt+" . StrUpper(key) . " to " . displayName)
    } catch Error as err {
        Notify("Could not assign app: " . err.Message)
    }
}

FindDynamicWindows(key) {
    matches := []
    for hwnd in WinGetList() {
        try {
            processName := StrLower(WinGetProcessName(hwnd))
            title := WinGetTitle(hwnd)
            if title != "" && SubStr(processName, 1, 1) = StrLower(key)
                matches.Push(hwnd)
        }
    }
    return matches
}

CycleWindows(windows) {
    active := WinExist("A")
    target := windows[1]

    for index, hwnd in windows {
        if hwnd = active {
            target := windows[index = windows.Length ? 1 : index + 1]
            break
        }
    }

    try {
        if WinGetMinMax(target) = -1
            WinRestore(target)
        WinActivate(target)
    }
}

RegisterScrollHotkeys() {
    global LofreeScroll, SettingsIni
    if !LofreeScroll
        return

    totalDelta := Abs(IniRead(SettingsIni, "scroll", "delta", "72") + 0)
    if totalDelta = 0
        return

    for keyName in StrSplit(IniRead(SettingsIni, "scroll", "up_hotkeys", "Volume_Up"), ",") {
        keyName := Trim(keyName)
        if keyName != ""
            Hotkey(keyName, SmoothScroll.Bind(-totalDelta))
    }
    for keyName in StrSplit(IniRead(SettingsIni, "scroll", "down_hotkeys", "Volume_Down"), ",") {
        keyName := Trim(keyName)
        if keyName != ""
            Hotkey(keyName, SmoothScroll.Bind(totalDelta))
    }
}

SmoothScroll(totalDelta, *) {
    global ScrollSteps, ScrollDelayMs
    sign := totalDelta >= 0 ? 1 : -1
    magnitude := Abs(totalDelta)
    frameCount := Max(1, Min(ScrollSteps, magnitude))
    baseDelta := magnitude // frameCount
    remainder := Mod(magnitude, frameCount)

    Loop frameCount {
        stepMagnitude := baseDelta + (A_Index <= remainder ? 1 : 0)
        stepDelta := stepMagnitude * sign
        DllCall(
            "user32\mouse_event",
            "UInt", 0x0800,
            "UInt", 0,
            "UInt", 0,
            "Int", stepDelta,
            "UPtr", 0
        )
        if A_Index < frameCount && ScrollDelayMs > 0
            Sleep(ScrollDelayMs)
    }
}

Notify(message) {
    ToolTip(message)
    SetTimer(() => ToolTip(), -2500)
}
