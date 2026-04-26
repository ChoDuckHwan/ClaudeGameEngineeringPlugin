# Stop hook: detect substantive turn and require SESSION_HANDOFF.md update.
# Exit 0 + JSON {"decision":"block","reason":...} -> Claude continues with the reason.
# Exit 0 + no output                              -> turn ends normally.

$ErrorActionPreference = 'SilentlyContinue'

$ProjectRoot = 'I:\FixItBots\ProjectFIB'
$Marker      = Join-Path $ProjectRoot '.claude\.session-log-marker'
$Handoff     = Join-Path $ProjectRoot '.claude\SESSION_HANDOFF.md'
$WatchDirs   = @(
    (Join-Path $ProjectRoot 'Source'),
    (Join-Path $ProjectRoot 'Content'),
    (Join-Path $ProjectRoot 'Config')
)

if (-not (Test-Path $Marker)) {
    # No marker yet (first turn). Create it for next time and pass.
    New-Item -ItemType File -Force -Path $Marker | Out-Null
    exit 0
}

$markerTime = (Get-Item $Marker).LastWriteTime

# Detect any file edited in watched dirs after the marker.
$substantive = $false
foreach ($dir in $WatchDirs) {
    if (-not (Test-Path $dir)) { continue }
    $hit = Get-ChildItem -Path $dir -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt $markerTime } |
        Select-Object -First 1
    if ($hit) { $substantive = $true; break }
}

if (-not $substantive) {
    # Refresh marker for the next turn and exit silently.
    (Get-Item $Marker).LastWriteTime = Get-Date
    exit 0
}

# Substantive turn: was the handoff updated?
$handoffUpdated = $false
if (Test-Path $Handoff) {
    $handoffTime = (Get-Item $Handoff).LastWriteTime
    if ($handoffTime -gt $markerTime) { $handoffUpdated = $true }
}

if ($handoffUpdated) {
    (Get-Item $Marker).LastWriteTime = Get-Date
    exit 0
}

# Block: ask Claude to update the handoff via the session-log skill.
$reason = @'
이번 턴에서 Source/Content/Config 하위 파일이 수정되었지만 SESSION_HANDOFF.md 가 갱신되지 않았습니다.
session-log 스킬의 Update Procedure 에 따라 다음을 수행하세요:
1) SESSION_HANDOFF.md 크기 확인 (>50KB 면 Rotation 먼저)
2) 이번 턴의 변경/결정/다음 작업/블로커를 활성 파일 끝에 append
3) 최상단 "마지막 업데이트" 타임스탬프 갱신
4) 완료 후 한 줄 요약 출력
'@

$payload = @{
    decision = 'block'
    reason   = $reason
} | ConvertTo-Json -Compress

# Refresh marker so the next Stop check has a fresh baseline.
(Get-Item $Marker).LastWriteTime = Get-Date

Write-Output $payload
exit 0
