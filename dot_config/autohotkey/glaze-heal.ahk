#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
Persistent

; GlazeWM can lose its IPC server and stop tiling while the process lives on
; (errors.log: "No common ancestor between containers"). Every 30 s, ask it a
; query; after two failed asks in a row, kill it and start it again. main.ahk
; starts this script; it has no hotkeys, so its blocking waits stall nothing.

global GlazeDir := EnvGet("USERPROFILE") . "\.local\glazewm"
global GlazeConfig := EnvGet("USERPROFILE") . "\.config\glazewm\config.yaml"
global Misses := 0

SetTimer(Heal, 30000)

Heal() {
    global GlazeDir, GlazeConfig, Misses
    wm := GlazeDir . "\glazewm.exe"
    if !FileExist(wm) || !FileExist(GlazeConfig)
        return
    if !GlazePid() {
        Misses := 0
        Start()
        return
    }
    if QueryOk() {
        Misses := 0
        return
    }
    if ++Misses < 2
        return
    Misses := 0
    if pid := GlazePid() {
        ProcessClose(pid)
        ProcessWaitClose(pid, 5)
        Sleep(3000)   ; else the new one finds port 6123 still taken (os error 10048) and quits
    }
    Start()
    TrayTip("GlazeWM stopped answering and was restarted", "AutoHotkey")
}

Start() {
    global GlazeDir, GlazeConfig
    Run(Format('"{1}\glazewm.exe" start --config "{2}"', GlazeDir, GlazeConfig), , "Hide")
}

; A frozen GlazeWM accepts the connection and never answers; give up after 5 s.
QueryOk() {
    global GlazeDir
    Run(Format('"{1}\cli\glazewm.exe" query focused', GlazeDir), , "Hide", &pid)
    h := DllCall("OpenProcess", "UInt", 0x101000, "Int", 0, "UInt", pid, "Ptr")  ; SYNCHRONIZE | QUERY_LIMITED_INFORMATION
    if !h
        return true                             ; already gone; ask again next tick
    code := 1
    if DllCall("WaitForSingleObject", "Ptr", h, "UInt", 5000) = 0
        DllCall("GetExitCodeProcess", "Ptr", h, "UInt*", &code)
    else
        ProcessClose(pid)
    DllCall("CloseHandle", "Ptr", h)
    return code = 0
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
