# MOAO11y Claude Code Multi-Agent Environment

이 디렉토리는 MOAO11y Observability Framework를 위한 Claude Code 멀티 에이전트 환경 설정을 포함합니다.

## 📁 구조

```
.claude/
├── agents/                           # 전문 에이전트 (AITMPL)
│   ├── backend-architect.md          # 백엔드 아키텍처 설계
│   ├── code-reviewer.md              # 코드 리뷰 전문가
│   ├── monitoring-specialist.md      # 모니터링/관찰성 전문가
│   └── test-engineer.md              # 테스팅 전문가
│
├── commands/                         # 커스텀 명령어
│   ├── audit-observability-config.md # 관찰성 설정 검증
│   ├── generate-metrics-collector.md # 메트릭 수집기 생성
│   ├── jira-create-issue.md          # JIRA 이슈 생성
│   ├── jira-transition.md            # JIRA 상태 전환
│   └── setup-ci-pipeline.md          # CI/CD 파이프라인 설정
│
├── hooks/                            # Git Hooks
│   ├── commit-msg                    # JIRA 티켓 검증
│   ├── pre-commit                    # 커밋 전 검증
│   └── pre-push                      # 푸시 전 테스트
│
├── settings/                         # 프로젝트 설정
│   ├── gradle-config.json            # Gradle 멀티프로젝트 설정
│   ├── jira-config.json              # JIRA 연동 설정
│   └── observability-config.json     # 관찰성 프레임워크 설정
│
└── settings.local.json               # Claude Code 로컬 설정
```

## 🤖 설치된 에이전트

### 1. Backend Architect
**파일**: `agents/backend-architect.md`
**용도**: 백엔드 아키텍처 설계 및 구조 검토
**사용법**: Task tool을 통해 호출 시 백엔드 관련 작업에 특화된 지침 제공

### 2. Code Reviewer
**파일**: `agents/code-reviewer.md`
**용도**: 코드 품질 검토 및 개선 제안
**사용법**: PR 리뷰, 코드 개선 시 활용

### 3. Monitoring Specialist
**파일**: `agents/monitoring-specialist.md`
**용도**: 모니터링 및 관찰성(Observability) 전문가
**사용법**: 메트릭 수집, 모니터링 설정, 알림 구성 시 활용

### 4. Test Engineer
**파일**: `agents/test-engineer.md`
**용도**: 테스트 전략 수립 및 구현
**사용법**: 테스트 작성, 테스트 커버리지 개선 시 활용

## 🛠️ 커스텀 명령어

### `/generate-metrics-collector`
새로운 메트릭 수집기 컴포넌트를 생성합니다.

```bash
# Claude Code에서 사용
/generate-metrics-collector
```

**기능**:
- OS, RabbitMQ, MySQL, Actuator, PM2 메트릭 수집기 생성
- Spring Boot 컴포넌트 구조 자동 생성
- 설정 파일 추가
- 테스트 코드 생성

### `/setup-ci-pipeline`
CI/CD 파이프라인 설정을 생성합니다.

```bash
# Claude Code에서 사용
/setup-ci-pipeline
```

**기능**:
- GitHub Actions 워크플로우 생성
- 빌드, 테스트, 배포 파이프라인 구성
- 환경별 배포 설정 (dev, stg, live)
- 보안 스캔 및 품질 게이트 설정

### `/audit-observability-config`
관찰성 설정을 검증하고 감사 리포트를 생성합니다.

```bash
# Claude Code에서 사용
/audit-observability-config
```

**기능**:
- application.yml 검증
- 메트릭 수집기 설정 확인
- 보안 감사
- 성능 평가
- 감사 리포트 생성

### `/jira-create-issue`
JIRA 이슈를 생성하고 Git 브랜치를 생성합니다.

```bash
# Claude Code에서 사용
/jira-create-issue
```

**기능**:
- 대화형 JIRA 이슈 생성
- 자동 브랜치 생성 제안
- JIRA 상태 업데이트 (In Progress)
- Git 브랜치 추적 설정

### `/jira-transition`
JIRA 이슈의 상태를 변경합니다.

```bash
# Claude Code에서 사용
/jira-transition MOA-123 "Code Review"
```

**기능**:
- 이슈 상태 전환
- 현재 브랜치에서 티켓 자동 인식
- JIRA 코멘트 추가
- 상태 변경 로깅

## 🎫 JIRA-GitHub 연동

### JIRA 프로젝트 정보
- **JIRA URL**: https://gjrjr4545.atlassian.net/jira/software/projects/MOA/
- **프로젝트 키**: MOA
- **GitHub Repo**: https://github.com/bocopile/MOAO11y

### 자동 상태 전환

| Git 이벤트 | JIRA 상태 변경 |
|-----------|--------------|
| 브랜치 생성 | To Do → In Progress |
| PR 생성 | In Progress → Code Review |
| PR 병합 | Code Review → Testing |
| Release | Testing → Done |

### 명명 규칙

**브랜치**: `{type}/{ticket-id}-{description}`
```bash
feature/MOA-123-add-rabbitmq-metrics
bugfix/MOA-456-fix-memory-leak
```

**커밋**: `MOA-XXX: {message}`
```bash
MOA-123: Implement RabbitMQ metrics collector
```

**PR 제목**: `[MOA-XXX] {title}`
```bash
[MOA-123] Add RabbitMQ metrics collector
```

자세한 내용은 [JIRA_INTEGRATION.md](JIRA_INTEGRATION.md)를 참고하세요.

## 🪝 Git Hooks

### Pre-commit Hook
**파일**: `hooks/pre-commit`
**자동 실행**: Git commit 전

**검사 항목**:
- ✅ YAML 구문 검증
- ✅ 하드코딩된 시크릿 검사
- ✅ 코드 포맷팅 확인
- ✅ 관찰성 설정 검증
- ✅ Claude Code 서명 제거 (CLAUDE.md 규칙)

### Pre-push Hook
**파일**: `hooks/pre-push`
**자동 실행**: Git push 전

**검사 항목**:
- ✅ 전체 테스트 실행
- ✅ 테스트 커버리지 확인
- ✅ 보안 검사
- ✅ 빌드 성공 확인

### Hooks 활성화

Git hooks는 `.claude/hooks/`에 있지만 Git이 인식하려면 `.git/hooks/`에 링크해야 합니다:

```bash
# Pre-commit hook 활성화
ln -sf ../../.claude/hooks/pre-commit .git/hooks/pre-commit

# Pre-push hook 활성화
ln -sf ../../.claude/hooks/pre-push .git/hooks/pre-push
```

또는 한번에:

```bash
# .claude/hooks/의 모든 hook을 .git/hooks/로 링크
for hook in .claude/hooks/*; do
  hook_name=$(basename "$hook")
  ln -sf "../../.claude/hooks/$hook_name" ".git/hooks/$hook_name"
done
```

## ⚙️ 설정 파일

### gradle-config.json
Gradle 멀티프로젝트 설정 정보를 포함합니다.

**주요 설정**:
- 프로젝트 구조 (MOAAgent, MOAServer)
- 빌드 명령어
- 환경 설정 (dev, stg, live)

### observability-config.json
관찰성 프레임워크 설정을 정의합니다.

**주요 설정**:
- 메트릭 수집기 활성화/비활성화
- 데이터 전송 모드 (RabbitMQ / Direct)
- 스토리지 정책
- 알림 규칙

### settings.local.json
Claude Code 로컬 권한 설정입니다.

**현재 권한**:
```json
{
  "permissions": {
    "allow": [
      "Bash(test:*)",
      "Bash(mkdir:*)",
      "Bash(npx claude-code-templates@latest:*)"
    ]
  }
}
```

## 📖 사용 예시

### 1. 새 메트릭 수집기 추가

```
사용자: MySQL 슬로우 쿼리 메트릭 수집기를 추가해줘
Claude: /generate-metrics-collector

[대화형으로 수집기 타입 선택 및 생성]
```

### 2. CI/CD 파이프라인 설정

```
사용자: GitHub Actions로 CI/CD 파이프라인 설정해줘
Claude: /setup-ci-pipeline

[GitHub Actions 워크플로우 파일 생성]
```

### 3. 관찰성 설정 검증

```
사용자: 현재 관찰성 설정이 제대로 되어있는지 확인해줘
Claude: /audit-observability-config

[설정 검증 및 리포트 생성]
```

### 4. 코드 리뷰 요청

```
사용자: 방금 작성한 MetricsCollector 클래스를 리뷰해줘
Claude: [code-reviewer 에이전트 활용하여 리뷰 수행]
```

## 🔄 워크플로우 예시

### 새 기능 개발

1. **계획**: Backend Architect 에이전트로 구조 설계
2. **구현**: 코드 작성 (필요시 generate-metrics-collector 사용)
3. **테스트**: Test Engineer 에이전트로 테스트 작성
4. **리뷰**: Code Reviewer 에이전트로 품질 검증
5. **커밋**: Pre-commit hook이 자동 검증
6. **푸시**: Pre-push hook이 테스트 실행
7. **배포**: CI/CD 파이프라인 자동 실행

## 🎯 프로젝트 특화 기능

### Observability Focus
MOAO11y는 관찰성에 특화된 프로젝트이므로:
- Monitoring Specialist 에이전트 우선 활용
- observability-config.json 설정 참조
- 메트릭 수집/저장/전송에 집중

### Multi-Module Gradle
- MOAAgent, MOAServer 독립 빌드 지원
- gradle-config.json에 모듈 정보 정의
- 환경별 설정 분리 (dev/stg/live)

### 보안
- Pre-commit hook이 시크릿 하드코딩 방지
- 환경 변수 사용 강제
- CLAUDE.md 규칙 자동 적용

## 📚 추가 리소스

- **MOAO11y 프로젝트**: `/Users/okestro/IdeaProjects/MOAO11y`
- **CLAUDE.md**: 프로젝트 전체 스펙 문서
- **AITMPL**: https://aitmpl.com
- **Claude Code Docs**: https://docs.claude.com/claude-code

## 🤝 기여

새로운 에이전트나 명령어를 추가하려면:

1. **에이전트**: AITMPL에서 다운로드 또는 직접 작성
   ```bash
   npx claude-code-templates@latest --agent=<agent-name>
   ```

2. **명령어**: `.claude/commands/` 에 `.md` 파일 작성
   ```bash
   touch .claude/commands/my-command.md
   # /my-command로 사용 가능
   ```

3. **Hooks**: `.claude/hooks/` 에 스크립트 작성 후 실행 권한 부여
   ```bash
   chmod +x .claude/hooks/my-hook
   ```

## ⚠️ 주의사항

1. **Git Commit 시**: Claude Code 서명이 자동 제거됩니다 (CLAUDE.md 규칙)
2. **Hooks 활성화**: 반드시 `.git/hooks/`로 심볼릭 링크 필요
3. **로컬 설정**: 이 설정은 프로젝트별이며 글로벌 설정이 아닙니다
4. **권한**: `settings.local.json`에서 허용된 명령어만 실행 가능

---

**버전**: 1.0.0
**업데이트**: 2025-11-03
**관리**: MOAO11y Team
