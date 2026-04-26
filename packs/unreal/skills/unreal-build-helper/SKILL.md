---
name: unreal-build-helper
description: Unreal Engine 5.5 프로젝트 빌드, 컴파일, 프로젝트 파일 생성을 자동으로 처리합니다. 사용자가 빌드, 컴파일, 프로젝트 재생성, 에디터 실행을 요청할 때 자동으로 활성화됩니다.
---

# Unreal Build Helper Skill

이 스킬은 ProjectFIB Unreal Engine 5.5 프로젝트의 빌드 작업을 자동화합니다.

## 기능

### 1. 프로젝트 파일 생성
```bash
"I:\FixItBots\UnrealEngine\Engine\Build\BatchFiles\GenerateProjectFiles.bat" -project="I:\FixItBots\ProjectFIB\ProjectFIB.uproject" -game -engine
```

### 2. 에디터 빌드 (Development)
```bash
"I:\FixItBots\UnrealEngine\Engine\Build\BatchFiles\Build.bat" ProjectFIBEditor Win64 Development -Project="I:\FixItBots\ProjectFIB\ProjectFIB.uproject"
```

### 3. 게임 빌드 (Shipping)
```bash
"I:\FixItBots\UnrealEngine\Engine\Build\BatchFiles\Build.bat" ProjectFIB Win64 Shipping -Project="I:\FixItBots\ProjectFIB\ProjectFIB.uproject"
```

### 4. 디버그 빌드
```bash
"I:\FixItBots\UnrealEngine\Engine\Build\BatchFiles\Build.bat" ProjectFIBEditor Win64 DebugGame -Project="I:\FixItBots\ProjectFIB\ProjectFIB.uproject"
```

### 5. 에디터 실행
```bash
"I:\FixItBots\UnrealEngine\Engine\Binaries\Win64\UnrealEditor.exe" "I:\FixItBots\ProjectFIB\ProjectFIB.uproject"
```

## 사용 시나리오

- "프로젝트 빌드해줘"
- "에디터 컴파일 필요해"
- "프로젝트 파일 재생성"
- "Shipping 빌드 만들어줘"
- "에디터 열어줘"

## 주의사항

- 빌드 전 기존 변경사항 저장 확인
- 빌드 실패 시 에러 로그 확인
- 대용량 빌드는 시간이 오래 걸릴 수 있음

## 경로 정보

- **엔진 경로**: `I:\FixItBots\UnrealEngine\`
- **프로젝트 경로**: `I:\FixItBots\ProjectFIB\`
- **프로젝트 파일**: `ProjectFIB.uproject`
- **소스 코드**: `Source\ProjectFIB\`
