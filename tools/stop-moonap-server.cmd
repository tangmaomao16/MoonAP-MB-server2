@echo off
setlocal

for /f "tokens=5" %%P in ('netstat -ano ^| findstr /r /c:":3000 .*LISTENING"') do (
  taskkill /pid %%P /f >nul 2>nul
  echo Stopped MoonAP server process %%P.
  exit /b 0
)

echo No MoonAP server is listening on port 3000.
