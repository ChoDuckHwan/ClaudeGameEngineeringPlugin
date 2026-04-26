# CGE PostToolUse hook: Edit/Write 후 변경된 파일 종류에 따라 후속 작업 알림.
#
# 일반화: 언어·빌드시스템 매핑은 외부 JSON에서 로드.
# - .claude/hooks/post-edit-map.json (프로젝트 부착 시점에 활성 팩들의 매핑이 병합됨)
#
# 빌드/타입체크/테스트 같은 무거운 작업은 자동 실행 X — 알림만.

$ErrorActionPreference = 'SilentlyContinue'

$input_json = [Console]::In.ReadToEnd()
if ([string]::IsNullOrEmpty($input_json)) {
    exit 0
}

try {
    $payload = $input_json | ConvertFrom-Json
    $filePath = $payload.tool_input.file_path
} catch {
    exit 0
}

if ([string]::IsNullOrEmpty($filePath)) {
    exit 0
}

$ProjectRoot = $env:CGE_PROJECT_ROOT
if ([string]::IsNullOrEmpty($ProjectRoot)) {
    $ProjectRoot = (Get-Location).Path
}

$MapFile = Join-Path $ProjectRoot '.claude\hooks\post-edit-map.json'

# 매핑 파일 없으면 무알림 (잘못된 부착 또는 의도적 비활성)
if (-not (Test-Path $MapFile)) {
    exit 0
}

$map = $null
try {
    $map = Get-Content $MapFile -Raw | ConvertFrom-Json
} catch {
    exit 0
}

# 매핑 항목들 평가 (첫 매칭 사용)
$msg = $null
foreach ($entry in $map.mappings) {
    foreach ($pattern in $entry.patterns) {
        if ($filePath -like $pattern) {
            $msg = $entry.message
            break
        }
    }
    if ($msg) { break }
}

if ($null -eq $msg) {
    exit 0
}

# Watch path 필터 (선택적)
if ($map.watch_paths) {
    $inWatch = $false
    foreach ($wp in $map.watch_paths) {
        $expanded = $wp -replace '\$\{PROJECT_ROOT\}', $ProjectRoot
        if ($filePath -like "$expanded*") { $inWatch = $true; break }
    }
    if (-not $inWatch -and -not $map.allow_outside_watch) {
        exit 0
    }
}

# JSON 시스템 메시지 주입
$payload_out = @{
    decision      = 'continue'
    systemMessage = "[PostEdit] $(Split-Path $filePath -Leaf): $msg"
} | ConvertTo-Json -Compress

Write-Output $payload_out
exit 0
