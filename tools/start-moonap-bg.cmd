@echo off
setlocal

set "ROOT=%~dp0.."
if not exist "%ROOT%\target" mkdir "%ROOT%\target"
set "SERVER_EXE=%ROOT%\_build\native\debug\build\cmd\server\server.exe"
set "PS_CMD=$root = '%ROOT%'; $server = '%SERVER_EXE%'; if (!(Test-Path -LiteralPath $server)) { throw 'MoonAP server executable not found. Build cmd/server first.' }; $existing = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1; if ($null -ne $existing) { throw ('Port 3000 is already in use by PID ' + $existing.OwningProcess + '. Stop the old MoonAP server first.'); }; $proc = Start-Process -FilePath $server -WorkingDirectory $root -WindowStyle Hidden -PassThru; if ($null -eq $proc) { throw 'Failed to start MoonAP server process.' }; $ok = $false; for ($i = 0; $i -lt 20; $i++) { Start-Sleep -Milliseconds 500; if ($proc.HasExited) { throw ('MoonAP server exited immediately with code ' + $proc.ExitCode + '.'); }; try { $resp = Invoke-WebRequest -UseBasicParsing http://127.0.0.1:3000 -TimeoutSec 2; if ($resp.StatusCode -ge 200) { $ok = $true; break; } } catch {} }; if (-not $ok) { try { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue } catch {}; throw 'MoonAP server did not become ready on http://127.0.0.1:3000 in time.'; }; Write-Output ('MoonAP server started with PID ' + $proc.Id)"

powershell -NoProfile -ExecutionPolicy Bypass -Command "%PS_CMD%"
echo Open http://127.0.0.1:3000
