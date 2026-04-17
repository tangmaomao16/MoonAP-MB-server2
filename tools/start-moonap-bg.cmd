@echo off
setlocal

set "ROOT=%~dp0.."
if not exist "%ROOT%\target" mkdir "%ROOT%\target"
set "SERVER_EXE=%ROOT%\_build\native\debug\build\cmd\server\server.exe"
set "PS_CMD=$root = '%ROOT%'; $server = '%SERVER_EXE%'; if (!(Test-Path -LiteralPath $server)) { throw 'MoonAP server executable not found. Build cmd/server first.' }; $psi = New-Object System.Diagnostics.ProcessStartInfo; $psi.FileName = $server; $psi.WorkingDirectory = $root; $psi.UseShellExecute = $true; $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden; $proc = [System.Diagnostics.Process]::Start($psi); if ($null -eq $proc) { throw 'Failed to start MoonAP server process.' }; Write-Output ('MoonAP server started with PID ' + $proc.Id)"

powershell -NoProfile -ExecutionPolicy Bypass -Command "%PS_CMD%"
echo Open http://127.0.0.1:3000
