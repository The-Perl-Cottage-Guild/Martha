# Martha

A sister project of _The Perl Lazarus Project_ intended to help Perl programmers build Windows GUI executables and installers, primarily for wxPerl applications on Windows.

---

## The Perl Lazarus Project

There is no direct equivalent to the Free Pascal Lazarus IDE in the Perl ecosystem.

In practice, building GUI applications for Windows in Perl requires assembling a working toolchain:

* Strawberry Perl (`perl`, DLLs, `gcc`, `gmake`, and related tools)
* wxPerl, which is currently experiencing a welcome revival
* wxGlade
* Packaging tools such as `pp`, `pp_autolink`, and `wxpar`
* An installer system such as Inno Setup

These components work, but they are not presented as a unified development and distribution workflow.

> **The Perl Lazarus Project** is an effort to:
>
> * Identify a working, modern stack for Perl GUI development on Windows
> * Provide clear and practical guidance for installing and using that stack
> * Bridge the gaps between development, packaging, testing, and distribution
> * Make it easier for Perl developers to ship complete Windows applications

---

## Quick Start

Before running Martha, set up the supported Windows Perl development stack described in the following guide:

[Developing and Distributing wxPerl Applications on Windows](https://wiki.perl-guilds.net/index.php?title=Developing_and_Distributing_wxPerl_Applications_on_Windows)

The development environment should include:

* Strawberry Perl (provides `gmake`, `gcc`, etc)
* wxPerl
* wxGlade
* PAR::Packer
* `pp`
* `pp_autolink`
* `wxpar`
* Inno Setup 6
* Git

Until Martha is distributed as a CPAN package, it must be checked out from its Git repository.

Open the **Strawberry Perl command window**, then run:

```bat
git clone <Martha repository URL>
cd Martha
perl martha.pl
