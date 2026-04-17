@echo off
setlocal

set "ROOT=%~dp0.."
set "CMD=cmd /d /s /c cd /d \"%ROOT%\" && tools\moon-msvc.cmd run cmd/server --target native > target\moonap-server.out.log 2> target\moonap-server.err.log"

start "MoonAP Native Server" /min %CMD%
echo MoonAP server is starting in a minimized window.
echo Open http://127.0.0.1:3000
