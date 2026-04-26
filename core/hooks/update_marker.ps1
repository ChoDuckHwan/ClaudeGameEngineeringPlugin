# CGE UserPromptSubmit hook: marker mtime 갱신 (매 턴 시작 시).
#
# Stop 훅이 비교할 baseline timestamp를 새로 고침.

$ErrorActionPreference = 'SilentlyContinue'

$ProjectRoot = $env:CGE_PROJECT_ROOT
if ([string]::IsNullOrEmpty($ProjectRoot)) {
    $ProjectRoot = (Get-Location).Path
}

$Marker = Join-Path $ProjectRoot '.claude\.session-log-marker'

if (Test-Path $Marker) {
    (Get-Item $Marker).LastWriteTime = Get-Date
} else {
    # 첫 부착 직후
    $dir = Split-Path $Marker -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    New-Item -ItemType File -Force -Path $Marker | Out-Null
}

exit 0
