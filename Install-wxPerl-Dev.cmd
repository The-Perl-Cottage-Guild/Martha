@echo off
setlocal EnableExtensions DisableDelayedExpansion
title wxPerl Development Stack Installer

rem ============================================================================
rem Install-wxPerl-Dev.cmd
rem
rem The installation engine is intentionally separate from the bundle data.
rem To add or update a bundle, edit wxperl-bundles.cmd.
rem
rem Examples:
rem   Install-wxPerl-Dev.cmd
rem   Install-wxPerl-Dev.cmd --defaults
rem   Install-wxPerl-Dev.cmd --bundle 1b --defaults
rem   Install-wxPerl-Dev.cmd --2a --dir "D:\Perl\wxperl-current"
rem   Install-wxPerl-Dev.cmd --list
rem ============================================================================

set "SCRIPT_DIR=%~dp0"
set "BUNDLE_FILE=%SCRIPT_DIR%wxperl-bundles.cmd"
set "HELPER=%SCRIPT_DIR%wxperl-installer-helper.ps1"
set "LOGFILE=%SCRIPT_DIR%Install-wxPerl-Dev-last-run.log"
set "CACHE=%TEMP%\wxperl-dev-installer-cache"

rem Bundle-independent packaging toolchain installed for every profile.
rem Add another CPAN distribution to this single line when needed.
set "PACKAGING_MODULES=PAR::Packer App::PP::Autolink Wx::Perl::Packager"

set "BUNDLE="
set "INSTALL_DIR="
set "AUTO=0"
set "WITH_DEMO="
set "PAUSE_ON_EXIT=1"
set "LIST_ONLY=0"
set "CURRENT_STEP=initialization"

rem These values are loaded from wxperl-bundles.cmd.
call :clear_profile

> "%LOGFILE%" echo wxPerl Development Stack Installer
>>"%LOGFILE%" echo Started: %DATE% %TIME%
>>"%LOGFILE%" echo Script: %~f0

:parse_args
if "%~1"=="" goto args_done

if /I "%~1"=="--defaults" (
    set "AUTO=1"
    shift
    goto parse_args
)
if /I "%~1"=="-y" (
    set "AUTO=1"
    shift
    goto parse_args
)
if /I "%~1"=="/Y" (
    set "AUTO=1"
    shift
    goto parse_args
)
if /I "%~1"=="--bundle" (
    if "%~2"=="" goto usage_error
    set "BUNDLE=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="--1a" (
    set "BUNDLE=1a"
    shift
    goto parse_args
)
if /I "%~1"=="--1b" (
    set "BUNDLE=1b"
    shift
    goto parse_args
)
if /I "%~1"=="--2a" (
    set "BUNDLE=2a"
    shift
    goto parse_args
)
if /I "%~1"=="--2b" (
    set "BUNDLE=2b"
    shift
    goto parse_args
)
if /I "%~1"=="--dir" (
    if "%~2"=="" goto usage_error
    set "INSTALL_DIR=%~2"
    shift
    shift
    goto parse_args
)
if /I "%~1"=="--with-demo" (
    set "WITH_DEMO=1"
    shift
    goto parse_args
)
if /I "%~1"=="--no-demo" (
    set "WITH_DEMO=0"
    shift
    goto parse_args
)
if /I "%~1"=="--no-pause" (
    set "PAUSE_ON_EXIT=0"
    shift
    goto parse_args
)
if /I "%~1"=="--list" (
    set "LIST_ONLY=1"
    shift
    goto parse_args
)
if /I "%~1"=="--help" goto usage
if /I "%~1"=="/?" goto usage

echo ERROR: Unknown option: %~1
goto usage_error

:args_done
if not exist "%BUNDLE_FILE%" (
    echo ERROR: Bundle definition file was not found:
    echo   "%BUNDLE_FILE%"
    goto fail
)
if not exist "%HELPER%" (
    echo ERROR: Download/extraction helper was not found:
    echo   "%HELPER%"
    goto fail
)

if "%LIST_ONLY%"=="1" (
    call "%BUNDLE_FILE%" list
    exit /b %ERRORLEVEL%
)

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: Windows PowerShell is required for downloading and ZIP extraction.
    goto fail
)

if defined BUNDLE goto bundle_selected
if "%AUTO%"=="1" (
    set "BUNDLE=1a"
    goto bundle_selected
)

:ask_bundle
echo.
call "%BUNDLE_FILE%" menu
echo.
set "ANSWER="
set /p "ANSWER=Selection [1a]: "
if not defined ANSWER set "ANSWER=1a"
set "BUNDLE=%ANSWER%"

:bundle_selected
call :clear_profile
call "%BUNDLE_FILE%" load "%BUNDLE%"
if errorlevel 1 (
    echo.
    echo Unknown bundle: %BUNDLE%
    set "BUNDLE="
    if "%AUTO%"=="1" goto usage_error
    goto ask_bundle
)

if not defined INSTALL_DIR (
    if "%AUTO%"=="1" (
        set "INSTALL_DIR=%DEFAULT_INSTALL_DIR%"
    ) else (
        echo.
        set /p "INSTALL_DIR=Strawberry Perl directory [%DEFAULT_INSTALL_DIR%]: "
        if not defined INSTALL_DIR set "INSTALL_DIR=%DEFAULT_INSTALL_DIR%"
    )
)
call :normalize_path INSTALL_DIR

if defined WITH_DEMO goto demo_selected
if "%AUTO%"=="1" (
    set "WITH_DEMO=1"
    goto demo_selected
)

echo.
set "ANSWER="
set /p "ANSWER=Also install Wx::Demo through cpanm? [Y/n]: "
if /I "%ANSWER%"=="N" (
    set "WITH_DEMO=0"
) else if /I "%ANSWER%"=="NO" (
    set "WITH_DEMO=0"
) else (
    set "WITH_DEMO=1"
)

:demo_selected
echo.
echo ============================================================
echo   Selected wxPerl bundle
echo ============================================================
echo.
echo Bundle ID             : %BUNDLE%
echo Name                  : %PROFILE_NAME%
echo Status                : %PROFILE_STATUS%
echo Strawberry Perl       : %SP_DIST_VERSION%
echo Strawberry edition    : %SP_EDITION%
echo Installation path     : %INSTALL_DIR%
echo Alien::wxWidgets      : %ALIEN_VERSION%
echo Wx / wxPerl           : %WX_VERSION%
echo Packaging tools       : PAR::Packer, App::PP::Autolink,
echo                         Wx::Perl::Packager
if "%WITH_DEMO%"=="1" echo Wx::Demo              : Yes
if "%WITH_DEMO%"=="0" echo Wx::Demo              : No
echo.
echo Alien::wxWidgets and Wx will be installed using cpanm with the
echo exact Sciurius GitHub release archive URLs stored in the bundle.
echo.

if "%AUTO%"=="1" goto confirmed
set "ANSWER="
set /p "ANSWER=Proceed with this installation? [Y/n]: "
if /I "%ANSWER%"=="N" goto cancelled
if /I "%ANSWER%"=="NO" goto cancelled

:confirmed
call :log "Bundle=%BUNDLE% %PROFILE_NAME%"
call :log "Strawberry=%SP_DIST_VERSION% %SP_EDITION% at %INSTALL_DIR%"
call :log "Alien::wxWidgets=%ALIEN_VERSION%"
call :log "Wx=%WX_VERSION%"
call :log "Packaging modules=%PACKAGING_MODULES%"
call :log "Wx::Demo=%WITH_DEMO%"

if not exist "%CACHE%" mkdir "%CACHE%" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not create cache directory:
    echo   "%CACHE%"
    goto fail
)

set "CURRENT_STEP=installing or verifying Strawberry Perl"
call :log "%CURRENT_STEP%"
call :install_strawberry
if errorlevel 1 goto fail

set "CURRENT_STEP=activating the selected Strawberry Perl environment"
call :log "%CURRENT_STEP%"
call :activate_environment
if errorlevel 1 goto fail

set "CURRENT_STEP=installing Alien::wxWidgets %ALIEN_VERSION% from the Sciurius release"
call :log "%CURRENT_STEP%"
call :install_alien
if errorlevel 1 goto fail

set "CURRENT_STEP=installing Wx %WX_VERSION% from the Sciurius release"
call :log "%CURRENT_STEP%"
call :install_wx
if errorlevel 1 goto fail

set "CURRENT_STEP=installing the application packaging toolchain"
call :log "%CURRENT_STEP%"
call :install_packaging_tools
if errorlevel 1 goto fail

if "%WITH_DEMO%"=="1" (
    set "CURRENT_STEP=installing Wx::Demo"
    call :log "%CURRENT_STEP%"
    call :install_demo
    if errorlevel 1 goto fail
)

set "CURRENT_STEP=running final verification and creating the launcher"
call :log "%CURRENT_STEP%"
call :verify_and_create_launcher
if errorlevel 1 goto fail

echo.
echo ============================================================
echo   SUCCESS
echo ============================================================
echo.
echo Bundle installed:
echo   %BUNDLE% - %PROFILE_NAME%
echo.
echo Launcher:
echo   "%INSTALL_DIR%\wxPerl %BUNDLE% Command Prompt.cmd"
echo.
echo Required test:
echo   perl -MWx
echo.
echo Status log:
echo   "%LOGFILE%"
echo.

call :log "SUCCESS"
if "%PAUSE_ON_EXIT%"=="1" pause
exit /b 0

rem ============================================================================
rem Strawberry Perl portable ZIP installation
rem ============================================================================

:install_strawberry
echo.
echo [1/6] Strawberry Perl %SP_DIST_VERSION% - %SP_EDITION%

if exist "%INSTALL_DIR%\perl\bin\perl.exe" goto verify_existing_perl

if exist "%INSTALL_DIR%\NUL" (
    dir /b "%INSTALL_DIR%" 2>nul | findstr . >nul
    if not errorlevel 1 goto unrecognized_perl_directory
)

goto extract_perl

:verify_existing_perl
echo Found an existing Perl installation:
echo   "%INSTALL_DIR%"
call :verify_selected_perl
if not errorlevel 1 (
    echo Matching Strawberry Perl installation found; reusing it.
    exit /b 0
)
echo Existing Perl does not match the selected bundle.
goto replace_perl_prompt

:unrecognized_perl_directory
echo The selected directory is nonempty and is not a recognized installation:
echo   "%INSTALL_DIR%"

:replace_perl_prompt
if "%AUTO%"=="1" (
    echo Defaults mode will not erase this directory automatically.
    exit /b 1
)
set "ANSWER="
set /p "ANSWER=[R]emove the directory and install, or [Q]uit? [Q]: "
if /I not "%ANSWER%"=="R" exit /b 1

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%HELPER%" remove "%INSTALL_DIR%"
if errorlevel 1 exit /b 1

:extract_perl
set "SP_ZIP=%CACHE%\%SP_ARCHIVE%"
call :download "%SP_URL%" "%SP_ZIP%"
if errorlevel 1 exit /b 1

echo Extracting:
echo   "%SP_ZIP%"
echo Into:
echo   "%INSTALL_DIR%"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%HELPER%" extractzip "%SP_ZIP%" "%INSTALL_DIR%"
if errorlevel 1 (
    echo ERROR: Strawberry Perl extraction failed.
    exit /b 1
)

if exist "%INSTALL_DIR%\relocation.pl.bat" call :run_relocation
if errorlevel 1 exit /b 1

call :verify_selected_perl
if errorlevel 1 exit /b 1

echo Strawberry Perl installation complete.
exit /b 0

:run_relocation
echo Running portable Strawberry relocation...
pushd "%INSTALL_DIR%"
call relocation.pl.bat
set "RC=%ERRORLEVEL%"
popd
if not "%RC%"=="0" (
    echo ERROR: relocation.pl.bat failed with exit code %RC%.
    exit /b 1
)
exit /b 0

:verify_selected_perl
set "PERL_EXE=%INSTALL_DIR%\perl\bin\perl.exe"

if not exist "%PERL_EXE%" (
    echo ERROR: Perl executable was not found:
    echo   "%PERL_EXE%"
    exit /b 1
)

"%PERL_EXE%" -e "exit($^O eq q{MSWin32} ? 0 : 1);"
if errorlevel 1 (
    echo ERROR: The selected Perl is not native MSWin32 Perl.
    exit /b 1
)

"%PERL_EXE%" -MConfig -e "exit($Config{version} eq q{%SP_CORE_VERSION%} ? 0 : 1);"
if errorlevel 1 (
    echo ERROR: Expected Perl core version %SP_CORE_VERSION%.
    "%PERL_EXE%" -MConfig -e "print qq{Found: $Config{version}\n};"
    exit /b 1
)

if "%REQUIRE_PDL%"=="1" (
    "%PERL_EXE%" -MPDL -e "print qq{PDL $PDL::VERSION\n};"
    if errorlevel 1 (
        echo ERROR: PDL does not load from the selected PDL bundle.
        exit /b 1
    )
)

"%PERL_EXE%" -e "print qq{Perl $] at $^X\n};"
exit /b %ERRORLEVEL%

rem ============================================================================
rem Native Strawberry environment
rem ============================================================================

:activate_environment
echo.
echo Activating:
echo   %INSTALL_DIR%\c\bin
echo   %INSTALL_DIR%\perl\site\bin
echo   %INSTALL_DIR%\perl\bin

set "PERL5LIB="
set "PERL_LOCAL_LIB_ROOT="
set "PERL_MB_OPT="
set "PERL_MM_OPT="
set "PERL_CPANM_OPT="
set "PERL5OPT="
set "HARNESS_PERL_SWITCHES="
set "PERL_CPANM_HOME=%INSTALL_DIR%\cpanm"

rem Avoid redirecting Alien::wxWidgets to an unrelated/stale wxWidgets tree.
if defined WXDIR echo Clearing inherited WXDIR=%WXDIR%
if defined WXWIN echo Clearing inherited WXWIN=%WXWIN%
if defined WX_CONFIG echo Clearing inherited WX_CONFIG=%WX_CONFIG%
if defined AWX_URL echo Clearing inherited AWX_URL=%AWX_URL%
set "WXDIR="
set "WXWIN="
set "WX_CONFIG="
set "AWX_URL="

set "PATH=%INSTALL_DIR%\c\bin;%INSTALL_DIR%\perl\site\bin;%INSTALL_DIR%\perl\bin;%PATH%"

echo.
where perl
where gmake
where tar

perl -e "exit($^O eq q{MSWin32} ? 0 : 1);"
if errorlevel 1 (
    echo ERROR: The active perl is not native Strawberry Perl.
    where perl
    exit /b 1
)

perl -MConfig -e "exit($Config{version} eq q{%SP_CORE_VERSION%} ? 0 : 1);"
if errorlevel 1 (
    echo ERROR: The wrong Strawberry Perl version is active.
    exit /b 1
)

if "%REQUIRE_PDL%"=="1" (
    perl -MPDL -e "print qq{PDL $PDL::VERSION\n};"
    if errorlevel 1 exit /b 1
)

where cpanm >nul 2>&1
if not errorlevel 1 exit /b 0

echo cpanm was not found. Installing App::cpanminus with this Strawberry Perl...
call cpan -T App::cpanminus
if errorlevel 1 (
    echo ERROR: App::cpanminus installation failed.
    exit /b 1
)

where cpanm
if errorlevel 1 exit /b 1
exit /b 0

rem ============================================================================
rem Exact Sciurius release installations through cpanm
rem ============================================================================

:install_alien
echo.
echo [2/6] Alien::wxWidgets %ALIEN_VERSION%
echo.
echo cpanm --verbose %ALIEN_URL%
echo.

call cpanm --verbose "%ALIEN_URL%"
if errorlevel 1 (
    echo ERROR: Alien::wxWidgets %ALIEN_VERSION% installation failed.
    exit /b 1
)

perl -MAlien::wxWidgets -e "print qq{Alien::wxWidgets $Alien::wxWidgets::VERSION\n}; print qq{Prefix: }, Alien::wxWidgets->prefix, qq{\n};"
if errorlevel 1 exit /b 1
exit /b 0

:install_wx
echo.
echo [3/6] Wx / wxPerl %WX_VERSION%
echo.
echo cpanm --verbose %WX_URL%
echo.

call cpanm --verbose "%WX_URL%"
if errorlevel 1 (
    echo ERROR: Wx %WX_VERSION% installation failed.
    echo The installer intentionally did not use --force or --notest.
    exit /b 1
)

perl -MWx -e "print qq{Wx $Wx::VERSION loaded; wxWidgets $Wx::wxVERSION\n};"
if errorlevel 1 exit /b 1
exit /b 0

:install_packaging_tools
echo.
echo [4/6] Application packaging toolchain
echo.
echo The following CPAN distributions are required for every bundle:
echo   PAR::Packer
echo   App::PP::Autolink
echo   Wx::Perl::Packager
echo.

for %%M in (%PACKAGING_MODULES%) do (
    echo ------------------------------------------------------------
    echo Installing %%M
    echo cpanm --verbose %%M
    call cpanm --verbose "%%M"
    if errorlevel 1 (
        echo ERROR: %%M installation failed.
        exit /b 1
    )
)

echo.
echo Verifying packaging modules...
perl -MPAR::Packer -e "print qq{PAR::Packer $PAR::Packer::VERSION loaded\n};"
if errorlevel 1 exit /b 1

perl -MApp::PP::Autolink -e "print qq{App::PP::Autolink $App::PP::Autolink::VERSION loaded\n};"
if errorlevel 1 exit /b 1

perl -MWx::Perl::Packager -e "print qq{Wx::Perl::Packager $Wx::Perl::Packager::VERSION loaded\n};"
if errorlevel 1 exit /b 1

echo.
echo Verifying packaging commands...
where pp
if errorlevel 1 (
    echo ERROR: pp was not installed.
    exit /b 1
)

where pp_autolink
if errorlevel 1 (
    echo ERROR: pp_autolink was not installed.
    exit /b 1
)

where wxpar
if errorlevel 1 (
    echo ERROR: wxpar was not installed.
    exit /b 1
)

exit /b 0

:install_demo
echo.
echo [5/6] Wx::Demo
echo.
echo cpanm --verbose Wx::Demo
echo.

call cpanm --verbose Wx::Demo
if errorlevel 1 (
    echo ERROR: Wx::Demo installation failed.
    exit /b 1
)

perl -MWx::Demo -e "print qq{Wx::Demo $Wx::Demo::VERSION loaded\n};"
if errorlevel 1 exit /b 1
exit /b 0

rem ============================================================================
rem Verification, marker, and reusable launcher
rem ============================================================================

:verify_and_create_launcher
echo.
echo [6/6] Final verification
echo.
echo Running:
echo   perl -MWx
echo.

perl -MWx -e "print qq{SUCCESS: Wx $Wx::VERSION loaded from $INC{q{Wx.pm}}\n}; print qq{wxWidgets $Wx::wxVERSION\n};"
if errorlevel 1 (
    echo ERROR: perl -MWx failed.
    exit /b 1
)

perl -MPAR::Packer -MApp::PP::Autolink -MWx::Perl::Packager -e "print qq{SUCCESS: packaging modules loaded\n};"
if errorlevel 1 (
    echo ERROR: One or more packaging modules failed to load.
    exit /b 1
)

where pp >nul 2>&1
if errorlevel 1 exit /b 1
where pp_autolink >nul 2>&1
if errorlevel 1 exit /b 1
where wxpar >nul 2>&1
if errorlevel 1 exit /b 1

if "%WITH_DEMO%"=="1" (
    perl -MWx::Demo -e "print qq{SUCCESS: Wx::Demo $Wx::Demo::VERSION loaded\n};"
    if errorlevel 1 exit /b 1
)

set "MARKER=%INSTALL_DIR%\wxperl-bundle.txt"
> "%MARKER%" echo Bundle: %BUNDLE%
>>"%MARKER%" echo Name: %PROFILE_NAME%
>>"%MARKER%" echo Status: %PROFILE_STATUS%
>>"%MARKER%" echo Strawberry Perl distribution: %SP_DIST_VERSION%
>>"%MARKER%" echo Strawberry edition: %SP_EDITION%
>>"%MARKER%" echo Alien::wxWidgets: %ALIEN_VERSION%
>>"%MARKER%" echo Wx: %WX_VERSION%
>>"%MARKER%" echo Packaging modules: %PACKAGING_MODULES%
>>"%MARKER%" echo Installed: %DATE% %TIME%

set "ENV_SCRIPT=%INSTALL_DIR%\wxperl-setenv.cmd"
> "%ENV_SCRIPT%" echo @echo off
>>"%ENV_SCRIPT%" echo set "PERL5LIB="
>>"%ENV_SCRIPT%" echo set "PERL_LOCAL_LIB_ROOT="
>>"%ENV_SCRIPT%" echo set "PERL_MB_OPT="
>>"%ENV_SCRIPT%" echo set "PERL_MM_OPT="
>>"%ENV_SCRIPT%" echo set "PERL_CPANM_OPT="
>>"%ENV_SCRIPT%" echo set "PERL5OPT="
>>"%ENV_SCRIPT%" echo set "HARNESS_PERL_SWITCHES="
>>"%ENV_SCRIPT%" echo set "PERL_CPANM_HOME=%INSTALL_DIR%\cpanm"
>>"%ENV_SCRIPT%" echo set "WXDIR="
>>"%ENV_SCRIPT%" echo set "WXWIN="
>>"%ENV_SCRIPT%" echo set "WX_CONFIG="
>>"%ENV_SCRIPT%" echo set "AWX_URL="
>>"%ENV_SCRIPT%" echo set "PATH=%INSTALL_DIR%\c\bin;%INSTALL_DIR%\perl\site\bin;%INSTALL_DIR%\perl\bin;%%PATH%%"

set "LAUNCHER=%INSTALL_DIR%\wxPerl %BUNDLE% Command Prompt.cmd"
> "%LAUNCHER%" echo @echo off
>>"%LAUNCHER%" echo call "%ENV_SCRIPT%"
>>"%LAUNCHER%" echo title wxPerl %BUNDLE% - %PROFILE_NAME%
>>"%LAUNCHER%" echo echo wxPerl bundle %BUNDLE% - %PROFILE_NAME%
>>"%LAUNCHER%" echo echo.
>>"%LAUNCHER%" echo where perl
if "%REQUIRE_PDL%"=="1" >>"%LAUNCHER%" echo perl -MPDL -e "print qq{PDL $PDL::VERSION\n};"
>>"%LAUNCHER%" echo perl -MWx -e "print qq{Wx $Wx::VERSION; wxWidgets $Wx::wxVERSION\n};"
>>"%LAUNCHER%" echo perl -MPAR::Packer -MApp::PP::Autolink -MWx::Perl::Packager -e "print qq{Packaging modules loaded\n};"
>>"%LAUNCHER%" echo where pp
>>"%LAUNCHER%" echo where pp_autolink
>>"%LAUNCHER%" echo where wxpar
if "%WITH_DEMO%"=="1" >>"%LAUNCHER%" echo perl -MWx::Demo -e "print qq{Wx::Demo $Wx::Demo::VERSION\n};"
>>"%LAUNCHER%" echo echo.
>>"%LAUNCHER%" echo cmd /k

exit /b 0

rem ============================================================================
rem Utility routines
rem ============================================================================

:clear_profile
set "PROFILE_NAME="
set "PROFILE_STATUS="
set "SP_DIST_VERSION="
set "SP_CORE_VERSION="
set "SP_EDITION="
set "SP_ARCHIVE="
set "SP_URL="
set "ALIEN_VERSION="
set "ALIEN_URL="
set "WX_VERSION="
set "WX_URL="
set "DEFAULT_INSTALL_DIR="
set "REQUIRE_PDL=0"
exit /b 0

:download
set "DL_URL=%~1"
set "DL_FILE=%~2"

if exist "%DL_FILE%" (
    for %%S in ("%DL_FILE%") do if %%~zS GTR 0 (
        echo Using cached archive:
        echo   "%DL_FILE%"
        exit /b 0
    )
)

echo Downloading:
echo   %DL_URL%
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%HELPER%" download "%DL_URL%" "%DL_FILE%"
if errorlevel 1 exit /b 1
exit /b 0

:normalize_path
set "NP_NAME=%~1"
call set "NP_VALUE=%%%NP_NAME%%%"
if "%NP_VALUE:~-1%"=="\" set "NP_VALUE=%NP_VALUE:~0,-1%"
set "%NP_NAME%=%NP_VALUE%"
exit /b 0

:log
>>"%LOGFILE%" echo [%DATE% %TIME%] %~1
exit /b 0

:usage
echo.
echo Usage:
echo   %~nx0
echo   %~nx0 --defaults
echo   %~nx0 --bundle 1b --defaults
echo   %~nx0 --2a --dir "D:\Perl\wxperl-current"
echo   %~nx0 --list
echo.
echo Options:
echo   --bundle ID          Select 1a, 1b, 2a, or 2b
echo   --1a --1b --2a --2b Short bundle-selection aliases
echo   --defaults, -y, /Y   Accept defaults; selects 1a when no bundle is given
echo   --dir PATH           Select the Strawberry installation directory
echo   --with-demo          Install Wx::Demo
echo   --no-demo            Do not install Wx::Demo
echo   --list               Display all bundle definitions
echo   --no-pause           Do not pause before exit
echo   --help, /?           Show this help
echo.
call "%BUNDLE_FILE%" list
exit /b 0

:usage_error
call :usage
if "%PAUSE_ON_EXIT%"=="1" pause
exit /b 2

:cancelled
call :log "Cancelled by user"
echo Installation cancelled.
if "%PAUSE_ON_EXIT%"=="1" pause
exit /b 1

:fail
call :log "FAILED during: %CURRENT_STEP%"
echo.
echo ============================================================
echo   INSTALLATION DID NOT COMPLETE
echo ============================================================
echo.
echo Failed during:
echo   %CURRENT_STEP%
echo.
echo Status log:
echo   "%LOGFILE%"
if defined PERL_CPANM_HOME (
    echo.
    echo Detailed cpanm work files:
    echo   "%PERL_CPANM_HOME%\work"
)
echo.
echo The window will remain open so the error can be read.
if "%PAUSE_ON_EXIT%"=="1" pause
exit /b 1
