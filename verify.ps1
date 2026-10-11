param([string]$OutputDirectory)
$ErrorActionPreference='Stop'
& (Join-Path $PSScriptRoot 'scripts\verify.ps1') @PSBoundParameters