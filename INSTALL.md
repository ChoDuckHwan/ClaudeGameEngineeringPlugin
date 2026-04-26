# Install Guide

## 방법 A: Claude Code Marketplace (권장)

```bash
/plugin marketplace add ChoDuckHwan/ClaudeGameEngineeringPlugin
/plugin install ClaudeGameEngineeringPlugin@ChoDuckHwan
```

## 방법 B: 직접 클론

```bash
git clone https://github.com/ChoDuckHwan/ClaudeGameEngineeringPlugin.git
# Windows
xcopy ClaudeGameEngineeringPlugin %USERPROFILE%\.claude\plugins\cge\ /E /I
# Linux/macOS
cp -r ClaudeGameEngineeringPlugin ~/.claude/plugins/cge/
```

## 부착

설치 후 프로젝트 디렉토리에서:

```bash
/cge bootstrap
```

5-Phase 자동 진행 (Phase 4는 사용자 승인 필요).

## 환경 요구

- Claude Code (latest)
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=2` (Agent Team 사용 시)
- PowerShell 5.1+ (Windows) / Bash (Linux·macOS)

## 후속 명령

```bash
/cge list                    # 활성 자산 확인
/cge install pack <name>     # 추가 팩 부착
/cge uninstall <type> <id>   # 자산 제거
/cge sync-lessons            # 다른 프로젝트 노하우 흡수
```

## 문제 해결

- **부착 실패**: `_meta/HISTORY.md` 참고
- **충돌**: `/cge list available` 후 수동 결정
- **새 엔지니어링 추가**: [docs/engineering-slot-guide.md](docs/engineering-slot-guide.md)
