param([switch]$Test,[string]$OutputDirectory)
$ErrorActionPreference='Stop'
& (Join-Path $PSScriptRoot 'scripts\build.ps1') @PSBoundParameters