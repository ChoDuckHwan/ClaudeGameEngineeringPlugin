# CGE Stop Hook: 변경이 있었지만 SESSION_HANDOFF.md 가 갱신 안 됐으면 block.
# 부착 시 ${PROJECT_ROOT}로 자동 치환됨.
#
# 일반화 사항:
# - 경로 변수화 (CGE_PROJECT_ROOT 환경변수 또는 인수)
# - watch dirs는 _project_profile.json에서 읽음 (없으면 기본값)

$ErrorActionPreference = 'SilentlyContinue'

$ProjectRoot = $env:CGE_PROJECT_ROOT
if ([string]::IsNullOrEmpty($ProjectRoot)) {
    $ProjectRoot = (Get-Location).Path
}

$Marker  = Join-Path $ProjectRoot '.claude\.session-log-marker'
$Handoff = Join-Path $ProjectRoot '.claude\SESSION_HANDOFF.md'
$Profile = Join-Path $ProjectRoot '.claude\_project_profile.json'

# Watch dirs 결정
$WatchDirs = @()
if (Test-Path $Profile) {
    try {
        $profileData = Get-Content $Profile -Raw | ConvertFrom-Json
        if ($profileData.watch_dirs) {
            $WatchDirs = $profileData.watch_dirs | ForEach-Object { Join-Path $ProjectRoot $_ }
        }
    } catch {}
}

# 기본값 (프로파일에 명시 안 됐으면)
if ($WatchDirs.Count -eq 0) {
    $defaults = @('Source', 'src', 'app', 'lib', 'Content', 'Config')
    foreach ($d in $defaults) {
        $full = Join-Path $ProjectRoot $d
        if (Test-Path $full) { $WatchDirs += $full }
    }
}

if (-not (Test-Path $Marker)) {
    New-Item -ItemType File -Force -Path $Marker | Out-Null
    exit 0
}

$markerTime = (Get-Item $Marker).LastWriteTime

# substantive change 감지
$substantive = $false
foreach ($dir in $WatchDirs) {
    if (-not (Test-Path $dir)) { continue }
    $hit = Get-ChildItem -Path $dir -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt $markerTime } |
        Select-Object -First 1
    if ($hit) { $substantive = $true; break }
}

if (-not $substantive) {
    (Get-Item $Marker).LastWriteTime = Get-Date
    exit 0
}

# Handoff 갱신 여부
$handoffUpdated = $false
if (Test-Path $Handoff) {
    $handoffTime = (Get-Item $Handoff).LastWriteTime
    if ($handoffTime -gt $markerTime) { $handoffUpdated = $true }
}

if ($handoffUpdated) {
    (Get-Item $Marker).LastWriteTime = Get-Date
    exit 0
}

# Block: session-log 호출 요청
$reason = @"
이번 턴에서 watched 디렉토리(${WatchDirs}) 하위 파일이 수정되었지만 SESSION_HANDOFF.md 가 갱신되지 않았습니다.
session-log 스킬의 Update Procedure 에 따라 다음을 수행하세요:
1) SESSION_HANDOFF.md 크기 확인 (>50KB 면 Rotation 먼저)
2) 이번 턴의 변경/결정/다음 작업/블로커를 활성 파일 끝에 append
3) 최상단 "마지막 업데이트" 타임스탬프 갱신
4) 완료 후 한 줄 요약 출력
"@

$payload = @{
    decision = 'block'
    reason   = $reason
} | ConvertTo-Json -Compress

(Get-Item $Marker).LastWriteTime = Get-Date

Write-Output $payload
exit 0
