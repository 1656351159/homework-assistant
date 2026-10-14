param([string]$McpConfigPath, [switch]$CheckOnly, [switch]$SkipDependencies)
$ErrorActionPreference='Stop'
$launcher=Join-Path $PSScriptRoot 'start-browser-mcp.ps1'
$entry=[ordered]@{type='stdio';command='powershell.exe';args=@('-NoProfile','-ExecutionPolicy','Bypass','-File',$launcher,'-Client','WorkBuddy')}
if ($CheckOnly) {
    [pscustomobject]@{Client='WorkBuddy';ConfigPathProvided=[bool]$McpConfigPath;ConfigExists=([bool]$McpConfigPath -and (Test-Path -LiteralPath $McpConfigPath));LauncherExists=(Test-Path -LiteralPath $launcher)} | ConvertTo-Json
    exit 0
}
if (-not $SkipDependencies) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'setup-codex.ps1')
    if($LASTEXITCODE -ne 0){throw 'Browser runtime preparation failed.'}
}
$name='homework-browser'
if ($McpConfigPath) {
    if (-not (Test-Path -LiteralPath $McpConfigPath -PathType Leaf)) { throw 'Supply an existing MCP configuration path confirmed through WorkBuddy settings; no guessed configuration was created.' }
    $resolved=(Resolve-Path -LiteralPath $McpConfigPath).Path
    $doc=Get-Content -LiteralPath $resolved -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $doc -or $doc -is [array] -or $doc -is [string] -or $doc -is [ValueType]) { throw 'Expected a JSON configuration object.' }
    if(-not $doc.PSObject.Properties['mcpServers']){$doc | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([pscustomobject]@{})}
    if (-not $doc.mcpServers -or $doc.mcpServers -is [array] -or $doc.mcpServers -is [string] -or $doc.mcpServers -is [ValueType]) { throw 'Expected an mcpServers object.' }
    $existing=$doc.mcpServers.PSObject.Properties[$name]
    if($existing){
        if (($existing.Value | ConvertTo-Json -Depth 20 -Compress) -ne ($entry | ConvertTo-Json -Depth 20 -Compress)) { throw 'Different homework-browser entry already exists; inspect it before replacement.' }
        Write-Output 'Matching MCP configuration already present; no changes made.'
        exit 0
    }
    Copy-Item -LiteralPath $resolved -Destination ($resolved+'.homework-backup-'+(Get-Date -Format 'yyyyMMddHHmmss'))
    $doc.mcpServers | Add-Member -NotePropertyName $name -NotePropertyValue ([pscustomobject]$entry)
    [System.IO.File]::WriteAllText($resolved,($doc | ConvertTo-Json -Depth 100),[System.Text.UTF8Encoding]::new($false))
    Write-Output 'MCP entry merged; existing settings preserved. Reconnect and verify browser tools in WorkBuddy.'
} else {
    $folder=Join-Path (Split-Path $PSScriptRoot) 'generated'
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
    $out=Join-Path $folder 'workbuddy-mcp.json'
    $doc=@{mcpServers=@{$name=$entry}}
    [System.IO.File]::WriteAllText($out,($doc | ConvertTo-Json -Depth 20),[System.Text.UTF8Encoding]::new($false))
    Write-Output "MCP import configuration generated: $out. Add through WorkBuddy custom connector settings, or rerun with its confirmed configuration path. Registration is not yet verified."
}
