@echo off

:: Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Please run this script as Administrator
    pause
    exit /b 1
)

:: Check if Chocolatey exists
if exist "%ALLUSERSPROFILE%\chocolatey" (
    echo Existing Chocolatey installation detected at '%ALLUSERSPROFILE%\chocolatey'
    set /p REMOVE_CHOCO="Do you want to remove the existing installation? (Y/N): "
    if /i "%REMOVE_CHOCO%"=="Y" (
        echo Removing existing Chocolatey installation...
        rmdir /s /q "%ALLUSERSPROFILE%\chocolatey"
        reg delete "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v ChocolateyInstall /f >nul 2>&1
        echo Existing installation removed.
    ) else (
        if /i "%REMOVE_CHOCO%"=="N" (
            echo Installation cancelled. Please remove the existing Chocolatey installation manually if needed.
            pause
            exit /b 1
        )
    )
)

where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo Installing Chocolatey...
    @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    set "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    :: Refresh environment variables
    call refreshenv >nul 2>&1
    :: Verify Chocolatey installation
    choco -v >nul 2>&1
    if %errorlevel% neq 0 (
        echo Failed to install Chocolatey. Please try again.
        pause
        exit /b 1
    )
    echo Chocolatey installed successfully.
)

where perl >nul 2>nul
if %errorlevel% neq 0 (
    echo Installing Perl...
    choco install strawberryperl -y
    set "PATH=%PATH%;C:\Strawberry\perl\bin"
    setx PATH "%PATH%"
)

where openssl >nul 2>nul
if %errorlevel% neq 0 (
    echo Installing OpenSSL...
    choco install openssl -y
    set "PATH=%PATH%;C:\Program Files\OpenSSL-Win64\bin"
    setx PATH "%PATH%"
)

echo Verifying Perl and OpenSSL installation...
perl --version
openssl version

git clone git@github.com:burncloud/wei.git
git clone git@github.com:burncloud/wei-build.git
git clone git@github.com:burncloud/wei-windows.git
git clone git@github.com:burncloud/wei-run.git
git clone git@github.com:burncloud/wei-server.git
