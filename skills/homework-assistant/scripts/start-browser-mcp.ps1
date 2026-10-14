param([switch]$CheckOnly, [ValidateSet('Codex','WorkBuddy')][string]$Client='Codex')
$ErrorActionPreference = 'Stop'
$nodeCmd = Get-Command node.exe -ErrorAction SilentlyContinue
$nodeDir = if ($nodeCmd) { Split-Path $nodeCmd.Source } else { Join-Path $env:ProgramFiles 'nodejs' }
$npx = Join-Path $nodeDir 'npx.cmd'
if (-not (Test-Path $npx)) { throw 'Run setup-codex.ps1 before starting the MCP server.' }
$profile = Join-Path $env:LOCALAPPDATA ($Client + 'Homework\browser-profile')
if ($CheckOnly) { [pscustomobject]@{NpxAvailable=$true;ProfilePath=$profile;Package='@playwright/mcp@0.0.83'} | ConvertTo-Json; exit 0 }
$env:PATH = "$nodeDir;$env:PATH"
$chrome = $null
foreach ($key in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe','HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe')) {
    if (Test-Path $key) { $file=(Get-Item $key).GetValue(''); if ($file -and (Test-Path $file)) { $chrome=$file; break } }
}
if ($chrome) { & $npx --yes '@playwright/mcp@0.0.83' --browser chrome --executable-path $chrome --user-data-dir $profile }
else { & $npx --yes '@playwright/mcp@0.0.83' --browser chrome --user-data-dir $profile }
exit $LASTEXITCODE
