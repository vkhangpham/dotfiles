[CmdletBinding()]
param(
    [switch]$Uninstall,
    [switch]$NoStart
)

$ErrorActionPreference = 'Stop'
$configDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = Join-Path $configDir 'main.ahk'
$startupDir = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupDir 'dotfiles-autohotkey.lnk'

if ($Uninstall) {
    Remove-Item -LiteralPath $shortcutPath -Force -ErrorAction SilentlyContinue
    Write-Host "Removed startup shortcut: $shortcutPath"
    exit 0
}

if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw "AutoHotkey script not found: $scriptPath"
}

$candidates = @(
    (Join-Path $env:ProgramFiles 'AutoHotkey\v2\AutoHotkey64.exe'),
    (Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe')
)

$command = Get-Command AutoHotkey64.exe, AutoHotkey.exe -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($command) {
    $candidates += $command.Source
}

$autoHotkey = $candidates |
    Where-Object { $_ -and (Test-Path -LiteralPath $_) } |
    Select-Object -First 1

if (-not $autoHotkey) {
    throw 'AutoHotkey v2 was not found. Install it from https://www.autohotkey.com/ and rerun this script.'
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $autoHotkey
$shortcut.Arguments = '"{0}"' -f $scriptPath
$shortcut.WorkingDirectory = $configDir
$shortcut.Description = 'Dotfiles AutoHotkey v2 keymaps'
$shortcut.Save()

Write-Host "Created startup shortcut: $shortcutPath"
if (-not $NoStart) {
    Start-Process -FilePath $autoHotkey -ArgumentList ('"{0}"' -f $scriptPath)
    Write-Host 'Started AutoHotkey keymaps.'
}
