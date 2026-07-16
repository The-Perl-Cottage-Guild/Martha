wxPerl Development Stack Installer — Four Bundles
=================================================

The installer offers four ZIP-based Strawberry Perl + wxPerl bundles.

    1a  Tested versions — Regular Perl
        Strawberry Perl 5.40.2.1 portable ZIP
        Alien::wxWidgets 0.71
        Wx 3.008
        Status: verified successful

    1b  Tested versions — PDL
        Strawberry Perl 5.40.2.1 PDL ZIP
        Alien::wxWidgets 0.71
        Wx 3.008
        Status: awaiting verification

    2a  Current versions — Regular Perl
        Strawberry Perl 5.42.2.1 portable ZIP
        Alien::wxWidgets 0.73
        Wx 3.009
        Status: experimental

    2b  Current versions — PDL
        Strawberry Perl 5.42.2.1 PDL ZIP
        Alien::wxWidgets 0.73
        Wx 3.009
        Status: experimental

Alien::wxWidgets and Wx are installed by cpanm using the exact Sciurius
GitHub release archive URLs defined for each bundle.


PACKAGING TOOLCHAIN — ALL BUNDLES
---------------------------------

Every bundle also installs these CPAN distributions through cpanm:

    PAR::Packer
    App::PP::Autolink
    Wx::Perl::Packager

They provide the Windows packaging commands:

    pp
    pp_autolink
    wxpar

The installer verifies that all three modules load and all three commands are
available before declaring success.

The distribution is PAR::Packer, not PAR::Package.

RUN
---

Interactive:

    Install-wxPerl-Dev.cmd

Default, unattended bundle 1a:

    Install-wxPerl-Dev.cmd --defaults

Test bundle 1b:

    Install-wxPerl-Dev.cmd --bundle 1b --defaults

Select bundle 2a and a custom location:

    Install-wxPerl-Dev.cmd --2a --dir "D:\Perl\wxperl-current"

Display the profiles without installing:

    Install-wxPerl-Dev.cmd --list

Wx::Demo is enabled by --defaults. Disable it with:

    Install-wxPerl-Dev.cmd --bundle 1b --defaults --no-demo

DEFAULT DIRECTORIES
-------------------

    1a  C:\sw\perl-5.40.2.1
    1b  C:\sw\pdl-5.40.2.1
    2a  C:\sw\perl-5.42.2.1
    2b  C:\sw\pdl-5.42.2.1

The versioned directories allow all four profiles to coexist.

HAND EXTENSION
--------------

All version data lives in:

    wxperl-bundles.cmd

The main installer contains no version-specific branches.

To add a profile:

1. Add one display line to :menu and :list.
2. Add one case to :load_dispatch.
3. Copy the template profile block at the bottom.
4. Change its archive names, URLs, versions, default directory, and PDL flag.

The shared download, extraction, relocation, cpanm, packaging-toolchain,
verification, logging, and launcher logic does not need to be copied or changed.

The bundle-independent packaging list is one line near the top of
Install-wxPerl-Dev.cmd:

    set "PACKAGING_MODULES=PAR::Packer App::PP::Autolink Wx::Perl::Packager"

ENVIRONMENT SAFETY
------------------

Before invoking cpanm, the installer:

* puts the selected Strawberry tree first on PATH;
* clears inherited local::lib settings;
* clears WXDIR, WXWIN, WX_CONFIG, and AWX_URL;
* verifies the expected native MSWin32 Perl core version;
* verifies PDL for PDL bundles.

The installer does not use --force or --notest.

SUCCESS
-------

Success requires:

    perl -MWx
    perl -MPAR::Packer
    perl -MApp::PP::Autolink
    perl -MWx::Perl::Packager
    where pp
    where pp_autolink
    where wxpar

When selected, Wx::Demo must also load. The installer then creates:

    <install directory>\wxPerl <bundle> Command Prompt.cmd

and records the installed profile in:

    <install directory>\wxperl-bundle.txt

PowerShell is used only for downloading and ZIP extraction. No 7-Zip
installation is required.
