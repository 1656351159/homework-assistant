param([switch]$CheckOnly, [switch]$RegisterMcp)
$ErrorActionPreference = 'Stop'
function Find-NodeDir {
    $cmd = Get-Command node.exe -ErrorAction SilentlyContinue
    if ($cmd) { return (Split-Path $cmd.Source) }
    foreach ($dir in @("$env:ProgramFiles\nodejs", "$env:LOCALAPPDATA\Programs\nodejs")) {
        if (Test-Path (Join-Path $dir 'node.exe')) { return $dir }
    }
    return $null
}
function Find-Chrome {
    foreach ($key in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe','HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe')) {
        if (Test-Path $key) { $file=(Get-Item $key).GetValue(''); if ($file -and (Test-Path $file)) { return $file } }
    }
    foreach ($file in @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe", "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe")) {
        if (Test-Path $file) { return $file }
    }
    return $null
}
$nodeDir = Find-NodeDir
$chrome = Find-Chrome
if ($CheckOnly) {
    [pscustomobject]@{NodeAvailable=[bool]$nodeDir;ChromeAvailable=[bool]$chrome;CodexCliAvailable=[bool](Get-Command codex.cmd -ErrorAction SilentlyContinue)} | ConvertTo-Json
    exit 0
}
function Install-Package([string]$Id) {
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) { throw "winget unavailable. Install $Id through its official installer, then retry." }
    & winget.exe install --id $Id --exact --source winget --accept-source-agreements --accept-package-agreements --silent
    if ($LASTEXITCODE -ne 0) { throw "Installation failed: $Id ($LASTEXITCODE)." }
}
if (-not $nodeDir) { Install-Package 'OpenJS.NodeJS.LTS'; $nodeDir = Find-NodeDir }
if (-not $nodeDir) { throw 'Node.js not found after installation.' }
$node = Join-Path $nodeDir 'node.exe'
$major = [int]((& $node --version).Trim().TrimStart('v').Split('.')[0])
if ($major -lt 18) { throw 'Node.js 18+ required. Update Node.js LTS and retry.' }
if (-not $chrome) { Install-Package 'Google.Chrome'; $chrome = Find-Chrome }
if (-not $chrome) { throw 'Chrome not found after installation.' }
$env:PATH = "$nodeDir;$env:PATH"
$npx = Join-Path $nodeDir 'npx.cmd'
& $npx --yes '@playwright/mcp@0.0.83' --help
if ($LASTEXITCODE -ne 0) { throw 'Playwright MCP preparation failed. Check network access and retry.' }
if ($RegisterMcp) {
    $codex = Get-Command codex.cmd -ErrorAction SilentlyContinue
    if (-not $codex) { throw 'Codex CLI missing. Install this package as a local Codex plugin, or configure its bundled MCP through Codex settings.' }
    $name = 'homework-browser'
    & $codex.Source mcp get $name *> $null
    if ($LASTEXITCODE -eq 0) { throw 'homework-browser already exists. Inspect its configuration before replacing it; no existing server was modified.' }
    $configBase = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
    $config = Join-Path $configBase 'config.toml'
    if (Test-Path $config) { Copy-Item -LiteralPath $config -Destination ($config + '.homework-backup-' + (Get-Date -Format 'yyyyMMddHHmmss')) }
    $launcher = Join-Path $PSScriptRoot 'start-browser-mcp.ps1'
    & $codex.Source mcp add $name -- powershell.exe -NoProfile -ExecutionPolicy Bypass -File $launcher
    if ($LASTEXITCODE -ne 0) { throw 'MCP registration failed.' }
}
Write-Output 'Setup complete. MCP tools may require a new Codex task or reconnect. Verify browser_tabs and browser_snapshot before starting homework.'
