# Horror-Direction Team — 공포 연출 팀

ProjectFIB 의 시각적 공포 연출(라이팅·카메라 워크·포스트프로세스·점프스케어·환각·Sanity 시각화·4단계 사이클)을 책임지는 팀입니다. audio 가 청각, 이 팀이 시각·전체 디렉팅.

## Pattern (Tier 2 #2)

- **Primary**: Pipeline (01 → 02 → 04)
- **Producer-Reviewer**: 04 ↔ 07 (max_retry=2, 발작 유발/모션 제한 회귀 검증)
- **Parallelizable Stages**: `[06, 07, 08]` — 변경/검증/체감 테스트 독립
- **Mode**: **Sub-agent** — 시각 효과 단발 작업 위주, audio 팀과 cross-team 협업 시 Hybrid
- **Reference**: [`_patterns.md`](../_patterns.md)

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|----------|
| 01 | 기획 구체화 | `horror-design-concretizer` | opus | GDD_07/09 → 공포 연출 기술 사양 (4단계: 불안→긴장→공포→해소) |
| 02 | 아키텍트 | `horror-architect` | opus | 라이팅 매니저/포스트프로세스 볼륨/카메라 모드/Sanity 시각 컴포넌트 설계 |
| 03 | 구조 설명 | `horror-structure-explainer` | opus | 적응형 공포 흐름, Sanity→시각효과 매핑, 점프스케어 트리거 다이어그램 |
| 04 | 기능 구현 | `horror-feature-implementer` | opus | PostProcess Material, CameraShake, Light Flicker, Vignette, Hallucination 컴포넌트 구현 |
| 05 | 기능 개선 | `horror-feature-improver` | opus | 포스트프로세스 GPU 비용, Niagara 파티클 LOD, Light 동적 비용 개선 |
| 06 | 변경 리포트 | `horror-change-reporter` | sonnet | 시각 효과/카메라/라이팅 변경 영향 정리 |
| 07 | 검증원 | `horror-verifier` | opus | 모션 제한 옵션 회귀, 발작 유발 효과 (광선반복) 점검, 성능 비용 |
| 08 | 테스터 | `horror-tester` | opus | 4단계 사이클 체감 테스트, Sanity 0 환각 시각화, 1-4인 동시 점프스케어 |
| 09 | 히스토리 | `horror-history` | sonnet | 활동/플레이테스트 공포감 평가/적정 강도 조정 누적 |
| 10 | 기능 활성화 | `horror-feature-activator` | opus | PostProcess Material, CameraShake BP, Niagara 시스템, Sanity 시각 디렉터 등록 가이드 |

## 워크플로우

```
기획 (GDD_07 공포연출, GDD_09 적응형 공포·Sanity·몰입)
    │
    ▼
[01]→[02]→[04]→[06]+[07]+[08(체감)] ─▶ [05]→[03] ─▶ [10]→[09]
```

## Cross-Team 협업

- **audio 팀**: 시청각 동기 (점프스케어 = 시각+사운드)
- **player 팀**: Sanity AttributeSet → 시각 효과 강도 매핑
- **ai 팀**: 악령 등장 트리거 → 라이팅/카메라 변화
- **ui 팀**: HUD 비네팅, 환각 인디케이터
- **balance 팀**: 공포 강도 곡선 (시간/이벤트별)

## 핵심 원칙

1. **4단계 사이클 엄수**: 불안(30s-3m) → 긴장(10-30s) → 공포(3-10s) → 해소(10-30s). 무한 공포 금지
2. **모션 제한 옵션**: 모든 화면 흔들림/번쩍임에 강도 옵션
3. **발작 유발 금지**: 깜빡임 빈도 3Hz 미만 권장 (PEAT 가이드라인)
4. **Sanity 시각 매핑 표 유지**: Sanity 100/70/30/0 각 단계의 시각 변화 명시
5. **클라이언트 측 시각**: 시각 효과는 클라에서. 서버 결정 → Multicast 트리거 → 클라 시각화
6. **성능 의식**: 포스트프로세스 + Niagara + 동적 라이트 = GPU 비용 큼. 측정 필수

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"horror 팀 dry-run으로 [연출 작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 점프스케어/Sanity 시각화 신규 (성능 비용 큼 — 미리 GPU 영향 추정)
  2. 4단계 사이클 변경 (audio·player와 동기 영향)

## 관련 문서

- [GDD_07_공포연출.md](../../GDD_07_공포연출.md)
- [GDD_09_몰입강화.md](../../GDD_09_몰입강화.md) (적응형 공포 / Sanity)
- [GDD_08C_밸런스_허들_미션_공포.md](../../GDD_08C_밸런스_허들_미션_공포.md) (공포 수치)
- `Source/ProjectFIB/Camera/`, `Source/ProjectFIB/AbilitySystem/`
