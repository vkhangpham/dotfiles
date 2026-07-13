#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

Persistent
SetTitleMatchMode(2)
SendMode("Input")
SetWorkingDir(A_ScriptDir)

global AppsIni := A_ScriptDir . "\apps.ini"
global SettingsIni := A_ScriptDir . "\settings.ini"
global TerminalModifierSwap := ReadBool("features", "terminal_modifier_swap", true)
global LofreeScroll := ReadBool("features", "lofree_scroll", false)
global ScrollSteps := Max(1, IniRead(SettingsIni, "scroll", "steps", "7") + 0)
global ScrollDelayMs := Max(0, IniRead(SettingsIni, "scroll", "delay_ms", "4") + 0)

RegisterAppHotkeys()
RegisterScrollHotkeys()

; Match the portable parts of the macOS Karabiner layout.
CapsLock::Send("{Escape}")
Escape::Send("{vkC0}")
+Escape::Send("+{vkC0}")
#Escape::Send("#{vkC0}")
#+Escape::Send("#+{vkC0}")

; Right Win is reserved for the app switcher and does nothing by itself.
RWin::return

; Windows already uses Win+Shift+S for the region screenshot UI. Preserve it
; even inside terminals where left Win and left Ctrl are otherwise swapped.
#HotIf TerminalModifierSwap && IsTerminalActive()
$<#+s::Send("#+s")
$<#c::Send("^+c")
$<#v::Send("^+v")
$<^c::Send("^c")
$<^v::Send("^v")
LWin::LCtrl
LCtrl::LWin
#HotIf

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
        Hotkey(">#" . key, SwitchMappedApp.Bind(key))
        Hotkey(">#+" . key, SwitchMappedApp.Bind(key))
        Hotkey(">#!" . key, AssignActiveApp.Bind(key))
        Hotkey(">#!+" . key, AssignActiveApp.Bind(key))
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
        Notify("No mapping or running app for Right Win+" . StrUpper(key))
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
        Notify("Assigned Right Win+" . StrUpper(key) . " to " . displayName)
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

IsTerminalActive() {
    static terminalProcesses := Map(
        "alacritty.exe", true,
        "cmd.exe", true,
        "conemu64.exe", true,
        "conhost.exe", true,
        "ghostty.exe", true,
        "hyper.exe", true,
        "kitty.exe", true,
        "mintty.exe", true,
        "powershell.exe", true,
        "pwsh.exe", true,
        "rio.exe", true,
        "tabby.exe", true,
        "warp.exe", true,
        "wezterm-gui.exe", true,
        "windowsterminal.exe", true
    )

    try return terminalProcesses.Has(StrLower(WinGetProcessName("A")))
    return false
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
