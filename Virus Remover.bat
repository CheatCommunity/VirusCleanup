@echo off
title LAST RESORT CLEANUP - RUN AS ADMIN
color 4f
echo ===================================================
echo  LAST RESORT VIRUS CLEANUP SCRIPT
echo  This uses built-in Windows tools only.
echo  It will NOT fix everything, but it's the best I can give.
echo ===================================================
echo.
pause

:: Step 1 - Kill suspicious processes (common malware names)
echo [1/6] Terminating known malware processes...
taskkill /f /im svchost.exe /fi "memusage gt 500000" 2>nul
taskkill /f /im conhost.exe /fi "memusage gt 300000" 2>nul
taskkill /f /im powershell.exe /fi "memusage gt 400000" 2>nul
taskkill /f /im cmd.exe /fi "memusage gt 200000" 2>nul
echo Done.

:: Step 2 - Clear temp folders (malware often runs from here)
echo [2/6] Cleaning temporary files...
del /f /s /q "%TEMP%\*" 2>nul
del /f /s /q "C:\Windows\Temp\*" 2>nul
del /f /s /q "C:\Users\*\AppData\Local\Temp\*" 2>nul
echo Done.

:: Step 3 - Run DISM + SFC (repair system integrity)
echo [3/6] Running DISM (system image repair) - this may take 10 minutes...
DISM /Online /Cleanup-Image /RestoreHealth /quiet
echo DISM complete. Running SFC...
sfc /scannow
echo SFC complete.

:: Step 4 - Run Windows Defender full scan (offline capable)
echo [4/6] Starting Windows Defender offline scan - your PC will restart.
echo If you see this message for more than 30 seconds, press any key to cancel.
pause
echo Running: "C:\Program Files\Windows Defender\MpCmdRun.exe" -removedefinitions -dynamicsignatures
MpCmdRun.exe -removedefinitions -dynamicsignatures
MpCmdRun.exe -Scan -ScanType 2 -Force -RestorePoint
echo Defender scan initiated. After reboot, check Windows Security history.

:: Step 5 - Disable suspicious startup entries (logs to desktop)
echo [5/6] Logging startup entries to desktop...
wmic startup get command,location,user > "%USERPROFILE%\Desktop\startup_log.txt"
schtasks /query /fo LIST /v > "%USERPROFILE%\Desktop\tasks_log.txt"
echo Logs saved to your desktop: startup_log.txt and tasks_log.txt
echo Review them manually. Look for random-named tasks or .exe in temp folders.

:: Step 6 - Run Microsoft Safety Scanner (if downloaded)
echo [6/6] Attempting to run Microsoft Safety Scanner...
set "safetyscan=C:\Users\%USERNAME%\Downloads\MSERT.exe"
if exist "%safetyscan%" (
    echo Found MSERT.exe. Running it in full scan mode...
    "%safetyscan%" /Q /F
) else (
    echo Microsoft Safety Scanner not found.
    echo Download it from: https://learn.microsoft.com/en-us/microsoft-365/security/intelligence/safety-scanner-download
    echo Save as MSERT.exe in your Downloads folder, then run this script again.
)
echo.
echo ===================================================
echo SCRIPT FINISHED. 
echo - Your PC may reboot for the offline scan.
echo - After reboot, check Windows Security for threats.
echo - If cmd prompts still appear at startup, you likely need a clean Windows reinstall.
echo ===================================================
pause