@echo off

cd %USERPROFILE%\Work
git clone git@github.com:burncloud/wei.git
git clone git@github.com:burncloud/wei-build.git
git clone git@github.com:burncloud/wei-windows.git
git clone git@github.com:burncloud/wei-run.git
git clone git@github.com:burncloud/wei-server.git
git clone git@github.com:burncloud/wei-release.git
git clone git@github.com:burncloud/wei-updater.git
git clone git@github.com:burncloud/wei-daemon.git
git clone git@github.com:burncloud/wei-download.git
git clone git@github.com:burncloud/wei-hardware.git
git clone git@github.com:burncloud/wei-forward.git
git clone git@github.com:burncloud/wei-task.git
git clone git@github.com:burncloud/wei-docker.git
git clone git@github.com:burncloud/wei-docker-linux.git
git clone git@github.com:burncloud/wei-scheduler.git
git clone git@github.com:burncloud/wei-dfdaemon.git
git clone git@github.com:burncloud/wei-coin.git
git clone git@github.com:burncloud/wei-shell.git
git clone git@github.com:burncloud/wei-network.git
git clone git@github.com:burncloud/wei-api.git
git clone git@github.com:burncloud/wei-file.git
git clone git@github.com:burncloud/wei-disk.git
git clone git@github.com:burncloud/wei-docker-install.git
git clone git@github.com:burncloud/wei-ui.git
git clone git@github.com:burncloud/wei-ui-vue.git


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
    choco install openssl.light -y
    set "OPENSSL_DIR=C:\Program Files\OpenSSL-Win64"
    set "OPENSSL_LIB_DIR=C:\Program Files\OpenSSL-Win64\lib"
    set "OPENSSL_INCLUDE_DIR=C:\Program Files\OpenSSL-Win64\include"
    set "PATH=%PATH%;C:\Program Files\OpenSSL-Win64\bin"
    setx OPENSSL_DIR "%OPENSSL_DIR%" /M
    setx OPENSSL_LIB_DIR "%OPENSSL_LIB_DIR%" /M
    setx OPENSSL_INCLUDE_DIR "%OPENSSL_INCLUDE_DIR%" /M
    setx PATH "%PATH%" /M
)

echo Verifying Perl and OpenSSL installation...
perl --version
openssl version