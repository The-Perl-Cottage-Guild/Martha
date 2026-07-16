[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('download', 'extractzip', 'remove')]
    [string] $Action,

    [Parameter(Position = 1)]
    [string] $Arg1,

    [Parameter(Position = 2)]
    [string] $Arg2
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

try {
    [Net.ServicePointManager]::SecurityProtocol =
        [Net.ServicePointManager]::SecurityProtocol -bor
        [Net.SecurityProtocolType]::Tls12
} catch {
}

$Headers = @{ 'User-Agent' = 'wxPerl-Four-Bundle-Installer' }

switch ($Action) {
    'download' {
        if (-not $Arg1 -or -not $Arg2) {
            throw 'download requires a URL and destination path.'
        }

        $Destination = [IO.Path]::GetFullPath($Arg2)
        $Parent = [IO.Path]::GetDirectoryName($Destination)

        if ($Parent -and -not [IO.Directory]::Exists($Parent)) {
            [IO.Directory]::CreateDirectory($Parent) | Out-Null
        }

        $Partial = "$Destination.partial"
        Remove-Item -LiteralPath $Partial -Force -ErrorAction SilentlyContinue

        Write-Host "Downloading $Arg1"
        Invoke-WebRequest -Uri $Arg1 -Headers $Headers -OutFile $Partial

        if (-not [IO.File]::Exists($Partial) -or
            (Get-Item -LiteralPath $Partial).Length -eq 0) {
            throw 'The downloaded file is empty.'
        }

        Move-Item -LiteralPath $Partial -Destination $Destination -Force
        Write-Host "Download complete: $Destination"
    }

    'extractzip' {
        if (-not $Arg1 -or -not $Arg2) {
            throw 'extractzip requires an archive and destination path.'
        }

        Add-Type -AssemblyName System.IO.Compression.FileSystem

        $Archive = [IO.Path]::GetFullPath($Arg1)
        $Destination = [IO.Path]::GetFullPath($Arg2)

        if (-not [IO.File]::Exists($Archive)) {
            throw "Archive not found: $Archive"
        }

        if ([IO.Directory]::Exists($Destination)) {
            $Existing = @(Get-ChildItem -LiteralPath $Destination -Force)
            if ($Existing.Count -gt 0) {
                throw "Destination is not empty: $Destination"
            }
            [IO.Directory]::Delete($Destination)
        }

        $Parent = [IO.Path]::GetDirectoryName($Destination)
        if ($Parent -and -not [IO.Directory]::Exists($Parent)) {
            [IO.Directory]::CreateDirectory($Parent) | Out-Null
        }

        $Stage = "$Destination.__extract_$PID"
        if ([IO.Directory]::Exists($Stage)) {
            [IO.Directory]::Delete($Stage, $true)
        }
        [IO.Directory]::CreateDirectory($Stage) | Out-Null

        try {
            [IO.Compression.ZipFile]::ExtractToDirectory($Archive, $Stage)
            $Top = @(Get-ChildItem -LiteralPath $Stage -Force)

            if ($Top.Count -eq 1 -and $Top[0].PSIsContainer) {
                Move-Item -LiteralPath $Top[0].FullName -Destination $Destination
                [IO.Directory]::Delete($Stage, $true)
            } else {
                Move-Item -LiteralPath $Stage -Destination $Destination
            }

            Write-Host "Extraction complete: $Destination"
        }
        catch {
            if ([IO.Directory]::Exists($Stage)) {
                [IO.Directory]::Delete($Stage, $true)
            }
            throw
        }
    }

    'remove' {
        if (-not $Arg1) {
            throw 'remove requires a directory path.'
        }

        $Target = [IO.Path]::GetFullPath($Arg1)
        if ([IO.Directory]::Exists($Target)) {
            [IO.Directory]::Delete($Target, $true)
        }
    }
}
