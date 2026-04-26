---
name: session-log
description: 세션 단절에 대비해 이번 턴의 코드 변경, 결정, 다음 작업을 SESSION_HANDOFF.md에 누적 기록합니다. 파일이 커지면 자동 회전합니다. 사용자가 "세션 저장, 핸드오프, 세션 로그, handoff, session log, 이어서 하기 위한 기록, 끊겨도 이어서, 세션 백업" 등을 언급하거나, Stop 훅으로 자동 호출됩니다.
---

# Session Log - 자동 핸드오프 기록기

## Identity
세션이 강제 종료되거나 컨텍스트가 리셋되어도 다음 세션이 곧바로 작업을 이어갈 수 있도록 `SESSION_HANDOFF.md` 를 누적 갱신하는 기록기. 잡담/단순 Q&A 턴은 건너뛰고, 실제 변화가 있었던 턴만 기록한다.

## Files & Paths

- **Active file**: `I:\FixItBots\ProjectFIB\.claude\SESSION_HANDOFF.md`
- **Archive dir**: `I:\FixItBots\ProjectFIB\.claude\handoff_archive\`
- **Memory index**: `C:\Users\duckh\.claude\projects\I--FixItBots-ProjectFIB\memory\MEMORY.md`
- **Marker (hook 내부용)**: `I:\FixItBots\ProjectFIB\.claude\.session-log-marker`

## When to RUN (substantive turn)

이 중 하나라도 해당하면 갱신:
- Edit/Write/NotebookEdit 도구로 파일이 실제로 수정됨
- 빌드/실행/테스트 결과로 새로 알게 된 사실이 있음
- 아키텍처/기획 결정을 새로 내림 (사용자가 "이렇게 가자"고 합의한 것)
- 미해결 블로커/질문이 새로 생김

## When to SKIP (trivial turn)

다음과 같으면 갱신하지 않고 종료:
- 단순 정보 조회 / 코드 읽기만 한 턴
- 사용자가 "기억해줘" / "메모리에 저장" 만 시킨 턴 (별도 메모리로 처리됨)
- 파일 변경 없는 잡담, 인사, 메타 질문
- 이전 턴과 동일한 내용을 재요청한 턴

## Update Procedure

1. **현재 활성 파일 크기 확인**
   - `SESSION_HANDOFF.md` 가 **50 KB (51200 bytes)** 를 넘으면 회전 절차 먼저 수행 (아래 Rotation 참고)

2. **활성 파일을 Read** 로 읽어 마지막 섹션 위치 파악

3. **새 턴 엔트리를 파일 끝에 append**. 형식:

   ```markdown
   ---

   ## YYYY-MM-DD HH:mm — <한 줄 작업 제목>

   **상태**: in-progress | blocked | done

   ### 변경
   - `path/to/file.cpp:120` — 무엇을 왜 바꿨는지
   - `path/to/Header.h` — 신규 추가, 역할

   ### 결정
   - 왜 이 방향을 택했는지 (대안 X 를 버린 이유 한 줄)

   ### 다음 작업
   - [ ] 우선순위 1: 구체적 다음 단계 + 예상 파일
   - [ ] 우선순위 2: ...

   ### 블로커 / 미해결
   - 컴파일 에러, 사용자 확인 필요 사항, TODO
   ```

4. **상위 헤더 갱신**: 파일 최상단의 `> 마지막 업데이트:` 라인을 현재 타임스탬프로 교체. 없으면 추가.

5. **MEMORY.md 인덱스**: 활성 핸드오프 경로가 인덱스에 없으면 한 줄 추가:
   `- [SESSION_HANDOFF.md](../../../I:/FixItBots/ProjectFIB/.claude/SESSION_HANDOFF.md) — 활성 세션 핸드오프 (자동 갱신)`

## Rotation (활성 파일 > 50 KB)

1. 아카이브 디렉터리 보장: `I:\FixItBots\ProjectFIB\.claude\handoff_archive\` 없으면 생성
2. 현재 `SESSION_HANDOFF.md` 를 `handoff_archive\SESSION_HANDOFF_YYYY-MM-DD_HHmm.md` 로 이동 (Bash `mv` 또는 PowerShell `Move-Item`)
3. 새 `SESSION_HANDOFF.md` 를 다음 템플릿으로 생성:

   ```markdown
   # Session Handoff — ProjectFIB

   > 마지막 업데이트: YYYY-MM-DD HH:mm
   > 직전 아카이브: handoff_archive/SESSION_HANDOFF_YYYY-MM-DD_HHmm.md
   > 이전 아카이브에서 이어지는 작업 요약은 아래 "Carry-over" 섹션을 참고하세요.

   ## Carry-over (직전 파일에서 가져온 미완 항목)
   - [ ] 직전 파일의 마지막 "다음 작업" 항목들을 요약 복사
   - [ ] 미해결 블로커도 함께 옮긴다

   ## Project Context (불변 정보)
   - 프로젝트 경로: `I:\FixItBots\ProjectFIB\`
   - 엔진: UE 5.5 Custom (`I:\FixItBots\UnrealEngine\`)
   - 빌드: `Engine/Build/BatchFiles/Build.bat ProjectFIBEditor Win64 Development -Project=...`
   - 주요 문서: `.claude/CLAUDE.md`, `.claude/GDD_*.md`

   ---
   ```

4. 4번 단계는 **사용자 차단 없이** 진행 — 한 턴 안에서 archive → new file → 새 엔트리 append 모두 끝낸다.

## Hook 연동

- `UserPromptSubmit` 훅이 매 턴 시작 시 marker 파일 mtime 갱신
- `Stop` 훅이 `check_handoff.ps1` 실행:
  - marker 이후 `Source/`, `Content/` 하위 파일 수정 여부 확인
  - 수정 있고 + `SESSION_HANDOFF.md` 가 marker 이후 갱신 안 됨 → block decision 반환 → Claude 가 이 스킬을 호출해 갱신
  - 수정 없거나 이미 갱신됨 → 통과

## 실행 시 자기 체크

갱신 직전 다음을 자문:
1. "이 턴이 SKIP 조건에 해당하는가?" → YES 면 끝.
2. "파일이 50KB 를 넘었는가?" → YES 면 Rotation 먼저.
3. "변경/결정/다음 작업이 명확한가?" → 모호하면 한 번 더 정리한 뒤 기록.
4. 기록 후 사용자에게 "핸드오프 갱신: <한 줄 요약>" 한 줄만 출력.
