# Martha

A sister project of _The Perl Lazarus Project_ intended to help Perl programmers build Windows GUI executables and installers, primarily for wxPerl applications on Windows.

---

## The Perl Lazarus Project

There is no direct equivalent to the Free Pascal Lazarus IDE in the Perl ecosystem.

In practice, building GUI applications for Windows in Perl requires assembling a working toolchain:

* Strawberry Perl (`perl`, DLLs, `gmake`, `gcc`, and related tools)
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

* Strawberry Perl (`perl`, DLLs, `gmake`, `gcc`, and related tools)
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
```

Martha is intended to be run from the Strawberry Perl command window so that the correct Perl interpreter, installed modules, DLL paths, compiler tools, `gmake`, and supporting commands are available.

A normal Windows Command Prompt or PowerShell session may not have the same environment unless Strawberry Perl has been configured there explicitly.

---

## Screenshots

| General Config | Makefile |
|:---:|:---:|
| <img width="500" alt="Martha General Config tab" src="https://github.com/user-attachments/assets/368f0ff9-1673-48f2-9767-7637c12e34ec" /> | <img width="500" alt="Martha Makefile tab" src="https://github.com/user-attachments/assets/fa658bde-7c00-4bd2-ba38-d142f2d6f2a2" /> |
| **Inno Setup** | **Credits** |
| <img width="500" alt="Martha Inno Setup tab" src="https://github.com/user-attachments/assets/87ef47f0-edb9-4556-b612-ff82e4118cbc" /> | <img width="500" alt="Martha Credits tab" src="https://github.com/user-attachments/assets/96b1fca4-a25a-4f37-bb4a-1c24164ce4ea" /> |

---

## Where Martha Fits

**Martha** is the packaging and deployment component of this effort.

While the broader Perl Lazarus Project defines the development stack and workflow, Martha focuses on:

> Turning a working Perl or wxPerl application into a distributable Windows executable and installer.

Martha does not attempt to replace wxGlade, an editor, or a full IDE. Instead, it provides a consistent interface around the steps that normally must be performed manually after the application itself is working.

---

## Summary

Martha assists with the creation of **distributable Perl applications for Windows**, with particular attention to wxPerl GUI applications.

It provides one project-oriented workflow for:

1. Selecting and configuring a Perl application
2. Discovering required DLLs
3. Generating and running a Makefile
4. Testing the compiled executable
5. Generating and compiling an Inno Setup script
6. Testing the completed installer
7. Saving and reopening the complete packaging project

Martha accepts Perl source files using `.pl`, `.pm`, or no filename extension.

---

## Status

**Functional and actively evolving through real-world use.**

Martha is developed alongside actual wxPerl applications. Improvements are therefore driven by practical packaging and deployment needs rather than by an idealized build process.

The current interface is organized into four tabs:

* **General Config**
* **Makefile**
* **Inno Setup**
* **Credits**

---

## Consistent Project Model

Martha uses the **General Config** tab as the single source of truth for shared project paths and executable naming.

The principal values are:

* **Source File** — the Perl application to package
* **CBIN** — the Strawberry Perl DLL directory used during dependency discovery
* **DIST** — the directory where the compiled application executable is written
* **EXE** — the executable filename
* **Built EXE Path** — derived from `DIST + EXE`
* **RELEASE** — the directory where the finished installer is written

The Makefile and Inno Setup tabs use these values rather than maintaining separate, conflicting copies.

For example:

```text
Source File:     C:\Projects\Kephra\kephra
DIST:            dist
EXE:             kephra.exe
Built EXE Path:  C:\Projects\Kephra\dist\kephra.exe
RELEASE:         release
Installer:       C:\Projects\Kephra\release\kephra-setup.exe
```
