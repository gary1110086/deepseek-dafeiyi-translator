param([string]$OutputDirectory,[switch]$Test)
$ErrorActionPreference='Stop'
$taskRepoRoot=Split-Path -Parent $PSScriptRoot
$taskPackage=if($OutputDirectory){[IO.Path]::GetFullPath($OutputDirectory)}else{Join-Path $taskRepoRoot 'outputs\package'}
if((Test-Path -LiteralPath $taskPackage) -and (Get-ChildItem -LiteralPath $taskPackage -Force)) { throw 'Package output must be new or empty. Choose another OutputDirectory.' }
$taskBuild=Join-Path $taskRepoRoot ('outputs\package-build\'+[Guid]::NewGuid().ToString('N'))
& (Join-Path $PSScriptRoot 'build.ps1') -OutputDirectory $taskBuild -Test:$Test
New-Item -ItemType Directory -Force -Path $taskPackage | Out-Null
foreach($taskFile in Get-ChildItem -LiteralPath $taskBuild -File) {
    if($taskFile.Extension -eq '.dll' -or $taskFile.Name -in @('轻译.exe','轻译.exe.config','update-install.ps1')) { Copy-Item -LiteralPath $taskFile.FullName -Destination (Join-Path $taskPackage $taskFile.Name) }
}
foreach($taskFolder in @('Assets','Libraries')) { Copy-Item -LiteralPath (Join-Path $taskBuild $taskFolder) -Destination $taskPackage -Recurse }
foreach($taskFile in @('setup.ps1','安装到桌面.cmd','安装并开机启动.cmd')) { Copy-Item -LiteralPath (Join-Path $PSScriptRoot ('install\'+$taskFile)) -Destination (Join-Path $taskPackage $taskFile) }
foreach($taskFile in @('README.md','README.en.md','LICENSE','THIRD_PARTY_NOTICES.md','SECURITY.md')) { Copy-Item -LiteralPath (Join-Path $taskRepoRoot $taskFile) -Destination (Join-Path $taskPackage $taskFile) }
$taskLanguage=[IO.File]::ReadAllText((Join-Path $taskRepoRoot 'src\DaFeiYi\UI\ProductLanguage.cs'))
if($taskLanguage -notmatch 'const\s+string\s+Version\s*=\s*"([0-9]+\.[0-9]+\.[0-9]+)"') { throw 'Product version missing' }
$taskVersion=$Matches[1]
$taskManifest=[ordered]@{version=$taskVersion;files=@(Get-ChildItem -LiteralPath $taskPackage -Recurse -File | Sort-Object FullName | ForEach-Object { [ordered]@{path=$_.FullName.Substring($taskPackage.Length+1).Replace('\','/');sha256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash} })}
$taskManifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskPackage 'distribution-manifest.json') -Encoding UTF8
Write-Output ('Package: '+$taskPackage+' ('+$taskManifest.files.Count+' verified files, v'+$taskVersion+')')
