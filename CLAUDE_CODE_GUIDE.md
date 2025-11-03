# MOAO11y - Claude Code Multi-Agent 사용 가이드

## 🚀 빠른 시작

### 1. Git Hooks 활성화

```bash
# 프로젝트 루트에서 실행
for hook in .claude/hooks/*; do
  hook_name=$(basename "$hook")
  ln -sf "../../.claude/hooks/$hook_name" ".git/hooks/$hook_name"
done
```

### 2. 사용 가능한 명령어 확인

Claude Code에서 다음 명령어들을 사용할 수 있습니다:

**Observability 관련:**
- `/generate-metrics-collector` - 새 메트릭 수집기 생성
- `/setup-ci-pipeline` - CI/CD 파이프라인 설정
- `/audit-observability-config` - 관찰성 설정 검증

**JIRA 연동:**
- `/jira-create-issue` - JIRA 이슈 생성 및 브랜치 생성
- `/jira-transition` - JIRA 이슈 상태 변경

### 3. 설치된 에이전트

- **backend-architect**: 백엔드 아키텍처 설계
- **code-reviewer**: 코드 품질 검토
- **monitoring-specialist**: 모니터링/관찰성 전문가
- **test-engineer**: 테스팅 전문가

## 📋 일반적인 작업 흐름

### 새 메트릭 수집기 추가

```
You: RabbitMQ 메트릭 수집기를 추가해줘
Claude: /generate-metrics-collector를 사용하여 생성하겠습니다...
```

### 코드 리뷰 요청

```
You: 방금 작성한 코드를 리뷰해줘
Claude: code-reviewer 에이전트를 활용하여 검토...
```

### CI/CD 설정

```
You: GitHub Actions 파이프라인을 설정해줘
Claude: /setup-ci-pipeline을 실행...
```

## 🔍 설정 파일 위치

- **Gradle 설정**: `.claude/settings/gradle-config.json`
- **Observability 설정**: `.claude/settings/observability-config.json`
- **Claude Code 설정**: `.claude/settings.local.json`

## 📖 상세 가이드

전체 문서는 `.claude/README.md`를 참고하세요.

## 🎯 프로젝트 구조

```
MOAO11y/
├── MOAAgent/          # 메트릭 수집 에이전트
├── MOAServer/         # 데이터 저장/처리 서버
├── .claude/           # Claude Code 설정
│   ├── agents/        # 전문 에이전트
│   ├── commands/      # 커스텀 명령어
│   ├── hooks/         # Git Hooks
│   └── settings/      # 프로젝트 설정
└── CLAUDE.md          # 프로젝트 전체 스펙
```

## ⚡ 빌드 명령어

```bash
# 전체 빌드
./gradlew build

# 모듈별 빌드
./gradlew :MOAAgent:build
./gradlew :MOAServer:build

# 테스트
./gradlew test

# 실행
./gradlew :MOAAgent:bootRun
./gradlew :MOAServer:bootRun
```

## 🛡️ Git Hooks

### Commit-msg
- JIRA 티켓 형식 검증 (MOA-XXX)
- 티켓 존재 여부 확인
- Claude Code 서명 자동 제거

### Pre-commit
- YAML 구문 검증
- 시크릿 하드코딩 검사
- 코드 포맷팅 확인
- Observability 설정 검증

### Pre-push
- 전체 테스트 실행
- 테스트 커버리지 확인
- 보안 스캔
- 빌드 성공 검증

## 🎫 JIRA 연동

### 초기 설정
1. JIRA API Token 생성
2. GitHub Secrets 설정 (`JIRA_USER_EMAIL`, `JIRA_API_TOKEN`)
3. Git hooks 활성화

### 워크플로우
```bash
# 1. JIRA 이슈 생성 (Claude Code)
/jira-create-issue

# 2. 브랜치 생성 (자동 제안됨)
git checkout -b feature/MOA-123-add-rabbitmq-metrics

# 3. 커밋 (JIRA 티켓 필수)
git commit -m "MOA-123: Implement RabbitMQ collector"

# 4. PR 생성 (자동으로 JIRA 상태 변경)
gh pr create --title "[MOA-123] Add RabbitMQ metrics collector"
```

자세한 내용: `.claude/JIRA_INTEGRATION.md`

## 💡 팁

1. **에이전트 활용**: 복잡한 작업은 해당 전문 에이전트에게 위임
2. **명령어 사용**: 반복 작업은 커스텀 명령어로 자동화
3. **설정 참조**: observability-config.json에 프로젝트 표준 정의
4. **Hooks 신뢰**: Pre-commit/push hooks가 품질 보장

---

**문의**: MOAO11y Team
**버전**: 1.0.0
