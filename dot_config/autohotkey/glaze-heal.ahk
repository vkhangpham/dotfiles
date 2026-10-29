#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
Persistent

; GlazeWM breaks at random (glzr-io/glazewm#1186, "No common ancestor between
; containers"): it stops tiling and opens a "Window has no workspace" popup on
; every focus change. This script restarts it and puts each window back on its
; desktop. main.ahk starts it; it has no hotkeys, so its blocking waits stall
; nothing.
;
; Every 2 s: close the popups, and restart on a new "No common ancestor" or
; "Window has no workspace" line in errors.log.
; Every 30 s: save each window's desktop, and restart after two failed queries
; in a row.

global GlazeDir := EnvGet("USERPROFILE") . "\.local\glazewm"
global GlazeConfig := EnvGet("USERPROFILE") . "\.config\glazewm\config.yaml"
global ErrorsLog := EnvGet("USERPROFILE") . "\.glzr\glazewm\errors.log"
global QueryOut := A_Temp . "\glaze-heal-workspaces.json"
global Misses := 0
global LogSize := LogLength()
global Desktops := Map()   ; window handle -> desktop name, from the last good query

SetTimer(WatchErrors, 2000)
SetTimer(Heal, 30000)

WatchErrors() {
    global LogSize
    while WinExist("Non-fatal error ahk_exe glazewm.exe")
        WinClose()
    size := LogLength()
    if size <= LogSize {
        LogSize := size
        return
    }
    try text := FileRead(ErrorsLog)
    catch
        return
    fresh := SubStr(text, LogSize + 1)
    LogSize := size
    if InStr(fresh, "No common ancestor") || InStr(fresh, "Window has no workspace")
        Restart()
}

Heal() {
    global GlazeDir, GlazeConfig, Misses
    if !FileExist(GlazeDir . "\glazewm.exe") || !FileExist(GlazeConfig)
        return
    if !GlazePid() {
        Restart()
        return
    }
    if json := QueryWorkspaces() {
        Misses := 0
        SaveDesktops(json)
        return
    }
    if ++Misses >= 2
        Restart()
}

Restart() {
    global Misses, LogSize
    Misses := 0
    if pid := GlazePid() {
        ProcessClose(pid)
        ProcessWaitClose(pid, 5)
        Sleep(3000)   ; else the new one finds port 6123 still taken (os error 10048) and quits
    }
    Unhide()
    Start()
    Loop 10 {         ; give it up to 10 s to come up
        Sleep(1000)
        if json := QueryWorkspaces() {
            RestoreDesktops(json)
            break
        }
    }
    LogSize := LogLength()
    TrayTip("GlazeWM broke and was restarted", "AutoHotkey")
}

; Show every window the last good query saw, so the new GlazeWM finds the ones
; that sat hidden on another desktop. Uncloak too, for a window hidden under
; hide_method: 'cloak'. Only GlazeWM's own windows: the shell cloaks some of its
; windows on purpose.
Unhide() {
    global Desktops
    views := 0
    try {
        sp := ComObject("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{6D5140C1-7436-11CE-8034-00AA006009FA}")
        iid := Buffer(16)
        DllCall("ole32\CLSIDFromString", "Str", "{1841C6D7-4F9D-42C0-AF41-8747538F10E5}", "Ptr", iid, "HRESULT")
        ComCall(3, sp, "Ptr", iid, "Ptr", iid, "Ptr*", &views)   ; IServiceProvider::QueryService
    }
    for handle in Desktops {
        hwnd := handle + 0
        if !DllCall("IsWindow", "Ptr", hwnd)
            continue
        if !DllCall("IsWindowVisible", "Ptr", hwnd)
            DllCall("ShowWindowAsync", "Ptr", hwnd, "Int", 8)       ; SW_SHOWNA
        cloaked := 0
        DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 14, "UInt*", &cloaked, "UInt", 4)
        if cloaked && views {
            try {
                ComCall(6, views, "Ptr", hwnd, "Ptr*", &view := 0)  ; GetViewForHwnd
                ComCall(12, view, "Int", 1, "Int", 0)               ; SetCloak(1, 0)
                ObjRelease(view)
            }
        }
    }
    if views
        ObjRelease(views)
}

Start() {
    global GlazeDir, GlazeConfig
    Run(Format('"{1}\glazewm.exe" start --config "{2}"', GlazeDir, GlazeConfig), , "Hide")
}

; Each window's handle and its desktop, from `query workspaces`.
WindowsByDesktop(json) {
    found := []
    for part in StrSplit(json, '{"type":"workspace"') {
        if !RegExMatch(part, '^,"id":"[^"]+","name":"([^"]+)"', &ws)
            continue
        pos := 1
        while pos := RegExMatch(part, '\{"type":"window","id":"([0-9a-f-]+)".*?"handle":(\d+),"title"', &w, pos) {
            found.Push({Id: w[1], Handle: w[2], Desktop: ws[1]})
            pos += w.Len
        }
    }
    return found
}

SaveDesktops(json) {
    global Desktops
    saved := Map()
    for w in WindowsByDesktop(json)
        saved[w.Handle] := w.Desktop
    if saved.Count
        Desktops := saved
}

; A restarted GlazeWM puts every window on the desktop in front. Move each one
; back where the last good query saw it.
RestoreDesktops(json) {
    global Desktops, GlazeDir
    for w in WindowsByDesktop(json) {
        if Desktops.Has(w.Handle) && Desktops[w.Handle] != w.Desktop
            RunWait(Format('"{1}\cli\glazewm.exe" command --id {2} move --workspace {3}'
                , GlazeDir, w.Id, Desktops[w.Handle]), , "Hide")
    }
}

; The JSON of `query workspaces`, or "" when GlazeWM refuses or hangs (5 s).
QueryWorkspaces() {
    global GlazeDir, QueryOut
    try FileDelete(QueryOut)
    Run(Format('{1} /c ""{2}\cli\glazewm.exe" query workspaces > "{3}""', A_ComSpec, GlazeDir, QueryOut), , "Hide", &pid)
    if ProcessWaitClose(pid, 5) {      ; returns the PID while it still runs
        ProcessClose(pid)
        return ""
    }
    try json := FileRead(QueryOut)
    catch
        return ""
    return InStr(json, '"success":true') ? json : ""
}

LogLength() {
    global ErrorsLog
    try return FileGetSize(ErrorsLog)
    return 0
}

; The PID of the window manager itself. The CLI is also named glazewm.exe, so
; match on the full path.
GlazePid() {
    global GlazeDir
    wm := GlazeDir . "\glazewm.exe"
    for p in ComObjGet("winmgmts:").ExecQuery("SELECT ProcessId, ExecutablePath FROM Win32_Process WHERE Name = 'glazewm.exe'")
        if p.ExecutablePath = wm
            return p.ProcessId
    return 0
}
