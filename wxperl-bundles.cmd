@echo off
rem ============================================================================
rem wxperl-bundles.cmd
rem
rem Human-editable bundle definitions for Install-wxPerl-Dev.cmd.
rem
rem To add a bundle:
rem   1. Add one line to :menu and :list.
rem   2. Copy a :load_* block.
rem   3. Change only the values in that block.
rem
rem Do NOT add SETLOCAL here. Variables loaded here must remain available to
rem the calling installer.
rem ============================================================================

if /I "%~1"=="menu" goto menu
if /I "%~1"=="list" goto list
if /I "%~1"=="load" goto load_dispatch
exit /b 2

:menu
echo ============================================================
echo   Choose a wxPerl development bundle
echo ============================================================
echo.
echo   1a. Tested versions - Regular Perl  [verified]
echo       Perl 5.40.2.1 / Alien 0.71 / Wx 3.008
echo.
echo   1b. Tested versions - PDL
echo       Perl PDL 5.40.2.1 / Alien 0.71 / Wx 3.008
echo.
echo   2a. Current versions - Regular Perl
echo       Perl 5.42.2.1 / Alien 0.73 / Wx 3.009
echo.
echo   2b. Current versions - PDL
echo       Perl PDL 5.42.2.1 / Alien 0.73 / Wx 3.009
exit /b 0

:list
echo.
echo Available bundles:
echo.
echo   1a  Tested Regular   5.40.2.1 / 0.71 / 3.008
echo       Default: C:\sw\perl-5.40.2.1
echo.
echo   1b  Tested PDL       5.40.2.1 / 0.71 / 3.008
echo       Default: C:\sw\pdl-5.40.2.1
echo.
echo   2a  Current Regular  5.42.2.1 / 0.73 / 3.009
echo       Default: C:\sw\perl-5.42.2.1
echo.
echo   2b  Current PDL      5.42.2.1 / 0.73 / 3.009
echo       Default: C:\sw\pdl-5.42.2.1
exit /b 0

:load_dispatch
if /I "%~2"=="1a" goto load_1a
if /I "%~2"=="1b" goto load_1b
if /I "%~2"=="2a" goto load_2a
if /I "%~2"=="2b" goto load_2b
exit /b 1

rem ============================================================================
rem 1a - Confirmed successful in the combined ZIP/cpanm installer workflow.
rem ============================================================================

:load_1a
set "PROFILE_NAME=Tested versions - Regular Perl"
set "PROFILE_STATUS=Verified successful"
set "SP_DIST_VERSION=5.40.2.1"
set "SP_CORE_VERSION=5.40.2"
set "SP_EDITION=Regular portable ZIP"
set "SP_ARCHIVE=strawberry-perl-5.40.2.1-64bit-portable.zip"
set "SP_URL=https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54021_64bit_UCRT/strawberry-perl-5.40.2.1-64bit-portable.zip"
set "ALIEN_VERSION=0.71"
set "ALIEN_URL=https://github.com/sciurius/perl-Alien-wxWidgets/releases/download/R0.71/Alien-wxWidgets-0.71.tar.gz"
set "WX_VERSION=3.008"
set "WX_URL=https://github.com/sciurius/wxPerl/releases/download/R3.008/Wx-3.008.tar.gz"
set "DEFAULT_INSTALL_DIR=C:\sw\perl-5.40.2.1"
set "REQUIRE_PDL=0"
exit /b 0

rem ============================================================================
rem 1b - Same tested Alien/Wx versions, Strawberry PDL edition.
rem ============================================================================

:load_1b
set "PROFILE_NAME=Tested versions - PDL"
set "PROFILE_STATUS=Awaiting verification"
set "SP_DIST_VERSION=5.40.2.1"
set "SP_CORE_VERSION=5.40.2"
set "SP_EDITION=PDL ZIP"
set "SP_ARCHIVE=strawberry-perl-5.40.2.1-64bit-PDL.zip"
set "SP_URL=https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54021_64bit_UCRT/strawberry-perl-5.40.2.1-64bit-PDL.zip"
set "ALIEN_VERSION=0.71"
set "ALIEN_URL=https://github.com/sciurius/perl-Alien-wxWidgets/releases/download/R0.71/Alien-wxWidgets-0.71.tar.gz"
set "WX_VERSION=3.008"
set "WX_URL=https://github.com/sciurius/wxPerl/releases/download/R3.008/Wx-3.008.tar.gz"
set "DEFAULT_INSTALL_DIR=C:\sw\pdl-5.40.2.1"
set "REQUIRE_PDL=1"
exit /b 0

rem ============================================================================
rem 2a - Current versions, regular Strawberry portable ZIP.
rem ============================================================================

:load_2a
set "PROFILE_NAME=Current versions - Regular Perl"
set "PROFILE_STATUS=Experimental"
set "SP_DIST_VERSION=5.42.2.1"
set "SP_CORE_VERSION=5.42.2"
set "SP_EDITION=Regular portable ZIP"
set "SP_ARCHIVE=strawberry-perl-5.42.2.1-64bit-portable.zip"
set "SP_URL=https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54221_64bit/strawberry-perl-5.42.2.1-64bit-portable.zip"
set "ALIEN_VERSION=0.73"
set "ALIEN_URL=https://github.com/sciurius/perl-Alien-wxWidgets/releases/download/R0.73/Alien-wxWidgets-0.73.tar.gz"
set "WX_VERSION=3.009"
set "WX_URL=https://github.com/sciurius/wxPerl/releases/download/R3.009/Wx-3.009.tar.gz"
set "DEFAULT_INSTALL_DIR=C:\sw\perl-5.42.2.1"
set "REQUIRE_PDL=0"
exit /b 0

rem ============================================================================
rem 2b - Current versions, Strawberry PDL ZIP.
rem ============================================================================

:load_2b
set "PROFILE_NAME=Current versions - PDL"
set "PROFILE_STATUS=Experimental"
set "SP_DIST_VERSION=5.42.2.1"
set "SP_CORE_VERSION=5.42.2"
set "SP_EDITION=PDL ZIP"
set "SP_ARCHIVE=strawberry-perl-5.42.2.1-64bit-PDL.zip"
set "SP_URL=https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54221_64bit/strawberry-perl-5.42.2.1-64bit-PDL.zip"
set "ALIEN_VERSION=0.73"
set "ALIEN_URL=https://github.com/sciurius/perl-Alien-wxWidgets/releases/download/R0.73/Alien-wxWidgets-0.73.tar.gz"
set "WX_VERSION=3.009"
set "WX_URL=https://github.com/sciurius/wxPerl/releases/download/R3.009/Wx-3.009.tar.gz"
set "DEFAULT_INSTALL_DIR=C:\sw\pdl-5.42.2.1"
set "REQUIRE_PDL=1"
exit /b 0

rem ============================================================================
rem Copy this block when adding another profile:
rem
rem :load_3a
rem set "PROFILE_NAME=..."
rem set "PROFILE_STATUS=Experimental"
rem set "SP_DIST_VERSION=..."
rem set "SP_CORE_VERSION=..."
rem set "SP_EDITION=Regular portable ZIP"
rem set "SP_ARCHIVE=..."
rem set "SP_URL=https://..."
rem set "ALIEN_VERSION=..."
rem set "ALIEN_URL=https://..."
rem set "WX_VERSION=..."
rem set "WX_URL=https://..."
rem set "DEFAULT_INSTALL_DIR=C:\sw\..."
rem set "REQUIRE_PDL=0"
rem exit /b 0
rem ============================================================================
