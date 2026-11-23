param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('start', 'snapshot', 'collect')]
    [string] $Action,

    [ValidateSet('before-activation', 'before-alien', 'before-wx', 'alien', 'wx')]
    [string] $Stage
)

$ErrorActionPreference = 'Stop'

if ($Action -eq 'start') {
    $directory = Join-Path ([IO.Path]::GetTempPath()) ('martha-wxperl-' + [Guid]::NewGuid().ToString('N'))
    [IO.Directory]::CreateDirectory($directory).FullName
    return
}

$directory = $env:MARTHA_TRACE_DIR

if ($Action -eq 'collect') {
    $console = Join-Path $directory "$Stage-console.log"
    $number = 0
    $root = [IO.Path]::GetFullPath((Join-Path $env:PERL_CPANM_HOME 'work')).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    $workDirectories = foreach ($line in [IO.File]::ReadLines($console)) {
        if ($line -match '^Work directory is (.+)$') {
            $path = [IO.Path]::GetFullPath($Matches[1].Trim())
            if ($path.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { $path }
        }
    }
    foreach ($path in ($workDirectories | Select-Object -Unique)) {
        $log = Join-Path $path 'build.log'
        if (Test-Path -LiteralPath $log -PathType Leaf) {
            $number++
            Copy-Item -LiteralPath $log -Destination (Join-Path $directory "$Stage-cpanm-$number.log")
        }
    }
    $workDirectories | Select-Object -Unique |
        Out-File -LiteralPath (Join-Path $directory "$Stage-work-paths.txt") -Encoding utf8
    return
}

$report = @(
    "Snapshot: $Stage ($(Get-Date -Format o))"
    "Script: $env:MARTHA_TRACE_SCRIPT"
    "Working directory: $((Get-Location).Path)"
    "Bundle: $env:BUNDLE; Strawberry: $env:SP_DIST_VERSION; Alien: $env:ALIEN_VERSION; Wx: $env:WX_VERSION"
    "Output capture: cpanm stdout and stderr redirected to phase log; desktop session retained"
    "Install directory: $env:INSTALL_DIR; defaults: $env:AUTO; demo: $env:WITH_DEMO; pause: $env:PAUSE_ON_EXIT"
    "Strawberry URL: $env:SP_URL"
    "Alien URL: $env:ALIEN_URL"
    "Wx URL: $env:WX_URL"
    "Desktop session: $env:SESSIONNAME; interactive: $([Environment]::UserInteractive)"
    "Relocation script present: $(Test-Path -LiteralPath (Join-Path $env:INSTALL_DIR 'relocation.pl.bat') -PathType Leaf)"
    "Portable shell present: $(Test-Path -LiteralPath (Join-Path $env:INSTALL_DIR 'portableshell.bat') -PathType Leaf)"
    foreach ($name in @('PATH', 'HOME', 'USERPROFILE', 'PERL5LIB', 'PERL5OPT', 'PERL_LOCAL_LIB_ROOT',
                       'PERL_MM_OPT', 'PERL_MB_OPT', 'PERL_CPANM_HOME', 'WXDIR', 'WXWIN', 'WX_CONFIG',
                       'MSYSTEM', 'MINGW_PREFIX')) {
        "$name=$([Environment]::GetEnvironmentVariable($name))"
    }
    foreach ($name in @('PERL_CPANM_OPT', 'AWX_URL', 'HARNESS_PERL_SWITCHES')) {
        "$name present: $([bool][Environment]::GetEnvironmentVariable($name))"
    }
    foreach ($tool in @('perl', 'cpanm', 'gcc', 'g++', 'gmake', 'tar')) {
        "where $tool"
        & $env:ComSpec /d /v:off /c "where.exe $tool 2>nul"
        if ($LASTEXITCODE -ne 0) { 'Not found' }
    }
    if ($Stage -eq 'before-activation') {
        $git = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue
        if ($git) {
            $previous = $ErrorActionPreference
            try {
                $ErrorActionPreference = 'Continue'
                $commit = & $git.Source -C $PSScriptRoot rev-parse HEAD 2>$null
                if ($LASTEXITCODE -eq 0) { "Git revision: $commit" }
            } finally { $ErrorActionPreference = $previous }
        }
        foreach ($file in @($env:MARTHA_TRACE_SCRIPT, (Join-Path $PSScriptRoot 'wxperl-bundles.cmd'))) {
            "SHA-256 $([IO.Path]::GetFileName($file)): $((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash)"
        }
    } else {
        & perl -MConfig -e 'print qq{executable=$^X\nversion=$^V\n}; for (qw(archname prefix siteprefix installsitelib installsitearch cc make)) { print qq{$_=$Config{$_}\n} }'
        & gcc --version
        & gmake --version
    }
)
$report | Out-File -LiteralPath (Join-Path $directory "$Stage.txt") -Encoding utf8
