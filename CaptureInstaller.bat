powershell -window hidden -command ""
@Echo Off
Mode 80,3 & color 0A

Set NETdownloadLink=https://download.visualstudio.microsoft.com/download/pr/c6a74d6b-576c-4ab0-bf55-d46d45610730/f70d2252c9f452c2eb679b8041846466/windowsdesktop-runtime-5.0.1-win-x64.exe
Set CAPTUREdownloadlink=https://cdn.discordapp.com/attachments/759195945044017234/797269630196383824/AUCapture-WPF_Framework_Dependant.exe
set NET5HASH=a7f9fc194371e125de609c709b52b1ac
set CAPTUREHASH=3b6ca3c441b402f57b6ed932fd2d1809

REM Color stuff -----
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
  set "DEL=%%a"
) 
REM -----------

cmd /c "dotnet --list-runtimes" > "%TEMP%\desktopRuntimes.txt"
find "Microsoft.WindowsDesktop.App 5.0.1" %TEMP%\desktopRuntimes.txt && (
  del "%TEMP%\desktopRuntimes.txt"
  REM .Net Runtime Already installed
  goto checkForCapture
  
) || (
  del "%TEMP%\desktopRuntimes.txt"
  REM .Runtime Not installed
  goto checkSumNetRuntime
)

REM ―――――― Check Sums
:checkSumNetRuntime
set "RECEIVED=" & for /F "skip=1 delims=" %%H in ('
    2^> nul CertUtil -hashfile "%TEMP%\windowsdesktop-runtime-5.0.1-win-x64.exe" md5
') do if not defined RECEIVED set "RECEIVED=%%H"
if "%NET5HASH%"=="%RECEIVED%" (
    REM Correct hash
    goto launchNetRuntime
) else (  
    REM Wrong Hash
    goto installNetRuntime
)

:checkSumCapture
>nul set "RECEIVED=" & for /F "skip=1 delims=" %%H in ('
    2^> nul CertUtil -hashfile "AutoMuteUs_Capture.exe" md5
') do if not defined RECEIVED set "RECEIVED=%%H"
if "%CAPTUREHASH%"=="%RECEIVED%" (
    REM Correct hash
    goto launchCapture
) else (  
    REM Wrong Hash
    goto installCapture
)
REM ――――――――――――――――――

:installNetRuntime
cls
echo off
cls
@powershell -window normal -command ""
call :colorEcho 0A "        ---Downloading .NET 5 Desktop Runtime Installer (dependency)---"
echo.
echo.
curl -# "%NETdownloadLink%" -o "%TEMP%\windowsdesktop-runtime-5.0.1-win-x64.exe"
@powershell -window hidden -command ""
goto checkSumNetRuntime

:launchNetRuntime
powershell -window hidden -command ""
curl -LJs "https://github.com/Wolfhound905/CaptureInstaller/releases/download/v1.0.0/resetvars.vbs" -o "%TEMP%\resetvars.vbs"
start "" "%TEMP%\windowsdesktop-runtime-5.0.1-win-x64.exe"
goto detectIfdoneInstall

:detectIfdoneInstall
cmd /c "dotnet --list-runtimes" > "%TEMP%\desktopRuntimes.txt"
find "Microsoft.WindowsDesktop.App 5.0.1" %TEMP%\desktopRuntimes.txt && (
  REM .NET 5 is done installing
  del "%TEMP%\desktopRuntimes.txt"
  taskkill /im "windowsdesktop-runtime-5.0.1-win-x64.exe" /f
  del "%TEMP%\windowsdesktop-runtime-5.0.1-win-x64.exe"
  del "%TEMP%\resetvars.vbs"
  goto checkForCapture
) || (
  REM Repeat install check
  del "%TEMP%\desktopRuntimes.txt"
  Timeout 2
  %TEMP%\resetvars.vbs
  call "%TEMP%\CaptureInstaller.bat"
  tasklist.exe | findstr "windowsdesktop-runtime-5." > nul
  if errorlevel 1 ( 
    goto EOF
  )
  goto detectIfdoneInstall
)

:checkForCapture
if EXIST "AutoMuteUs_Capture.exe" ( goto checkSumCapture )
if not EXIST "AutoMuteUs_Capture.exe" ( goto installCapture )
:installCapture
cls
echo off
cls
@powershell -window normal -command ""
call :colorEcho 0A "                      ---Downloading AutoMuteUs Capture---"
echo.
echo.
curl -# "%CAPTUREdownloadLink%" -o "%~dp0AutoMuteUs_Capture.exe"
goto checkSumCapture

:launchCapture
start "%~dp0" "AutoMuteUs_Capture.exe"
del "%~f0"
goto EOF

REM Color Stuff ----
:colorEcho
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1i
REM --------

:EOF
