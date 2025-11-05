# MOAO11y - Multi-Agent Orchestrated Observability Framework

> AI 에이전트들이 자율적으로 협업하는 환경 기반 Observability Framework

## 개요

MOAO11y는 Spring Actuator, PM2, 다양한 Exporter를 이용하여 시스템 및 애플리케이션 메트릭을 수집하고 저장하는 프레임워크입니다. Claude Code의 Multi-Agent 협업 방식을 적용하여 효율적인 개발 환경을 구축했습니다.

## 주요 기능

- **메트릭 수집**: Spring Actuator, Node Exporter, RabbitMQ Exporter, MySQL Exporter, PM2, cAdvisor
- **데이터 전송**: RabbitMQ 또는 Direct API 방식 선택 가능
- **데이터 저장**: MySQL 또는 CSV 파일 저장 지원
- **환경 분리**: dev, stg, live 환경별 설정 관리
- **Multi-Agent 개발**: Writer, Reviewer, QA, Docs Agent가 협업하여 개발

## 프로젝트 구조

```
MOAO11y/
├── .claude/                   # Claude Code Multi-Agent 환경 설정
│   ├── agents/               # Agent별 규칙 및 가이드
│   │   ├── backend.md
│   │   ├── qa.md
│   │   ├── docs.md
│   │   └── review.md
│   ├── specs/                # 품질 기준 및 스펙
│   │   ├── quality-gates.spec.yml
│   │   ├── moaagent.spec.yml
│   │   └── moaserver.spec.yml
│   ├── workflows/            # 개발 워크플로우
│   │   ├── development.yml
│   │   ├── testing.yml
│   │   ├── deployment.yml
│   │   └── multi-agent-orchestration.yml
│   ├── config/               # Agent 설정
│   │   ├── state.json
│   │   ├── error-handling.yml
│   │   └── token-management.yml
│   └── scripts/              # 자동화 스크립트
│       ├── setup-worktrees.sh
│       ├── cleanup-worktrees.sh
│       ├── parallel-test.sh
│       └── auto-detect-specs.sh
├── MOAAgent/                 # 메트릭 수집 에이전트
└── MOAServer/                # 메트릭 저장 및 처리 서버
```

## 기술 스택

- **언어**: Java 11
- **프레임워크**: Spring Boot 2.7.x
- **빌드 도구**: Gradle 8.x (Groovy DSL)
- **데이터베이스**: MySQL 8.0 (선택), CSV (선택)
- **메시지 큐**: RabbitMQ (선택)

## 시작하기

### 필수 요구사항

- Java 11
- Gradle 8.x
- MySQL 8.0 (선택)
- RabbitMQ (선택)

### 설치

```bash
git clone https://github.com/bocopile/MOAO11y.git
cd MOAO11y
./gradlew build
```

### 실행

#### MOAAgent 실행

```bash
# Dev 환경
./gradlew :MOAAgent:bootRun --args='--spring.profiles.active=dev'

# Stg 환경
./gradlew :MOAAgent:bootRun --args='--spring.profiles.active=stg'

# Live 환경
./gradlew :MOAAgent:bootRun --args='--spring.profiles.active=live'
```

#### MOAServer 실행

```bash
# Dev 환경
./gradlew :MOAServer:bootRun --args='--spring.profiles.active=dev'

# Stg 환경
./gradlew :MOAServer:bootRun --args='--spring.profiles.active=stg'

# Live 환경
./gradlew :MOAServer:bootRun --args='--spring.profiles.active=live'
```

## 설정

### MOAAgent 설정

`MOAAgent/src/main/resources/application.yml` 참조

주요 설정:
- 수집 주기: `moao11y.agent.collectors.interval`
- 전송 방식: `moao11y.agent.sender.type` (rabbitmq | direct)
- 재시도 정책: `moao11y.agent.sender.retry`

### MOAServer 설정

`MOAServer/src/main/resources/application.yml` 참조

주요 설정:
- 저장 방식: `moao11y.server.storage.type` (mysql | csv)
- 수신 방식: `moao11y.server.receiver.type` (rabbitmq | direct)
- 보관 기간: `moao11y.server.retention.period`

## Multi-Agent 개발 환경

### Agent 역할

- **Writer Agent**: 코드 작성 및 구현
- **Reviewer Agent**: 코드 리뷰 및 품질 검증
- **QA Agent**: 테스트 자동화
- **Docs Agent**: 문서화

### Git Worktrees 사용

```bash
# Worktrees 설정
./.claude/scripts/setup-worktrees.sh MOA-123 writer reviewer qa docs

# Writer 작업
cd ../MOAO11y-writer
claude

# Reviewer 작업 (병렬)
cd ../MOAO11y-reviewer
claude

# 정리
./.claude/scripts/cleanup-worktrees.sh all
```

### 병렬 테스트

```bash
# 병렬 테스트 실행
./.claude/scripts/parallel-test.sh
```

## 빌드 & 테스트

```bash
# 전체 빌드
./gradlew buildAll

# 전체 테스트
./gradlew testAll

# 개별 모듈 빌드
./gradlew :MOAAgent:build
./gradlew :MOAServer:build

# 개별 모듈 테스트
./gradlew :MOAAgent:test
./gradlew :MOAServer:test
```

## API 문서

- MOAAgent: `http://localhost:8081/actuator`
- MOAServer: `http://localhost:8080/actuator`

## 모니터링

- Prometheus Metrics: `/actuator/prometheus`
- Health Check: `/actuator/health`

## 기여하기

1. 이 저장소를 Fork합니다
2. Feature 브랜치 생성 (`git checkout -b feature/MOA-XXX-description`)
3. 변경 사항 커밋 (`git commit -m 'feat: Add some feature'`)
4. 브랜치 Push (`git push origin feature/MOA-XXX-description`)
5. Pull Request 생성

### 개발 가이드

- [Backend Agent 가이드](.claude/agents/backend.md)
- [QA Agent 가이드](.claude/agents/qa.md)
- [Docs Agent 가이드](.claude/agents/docs.md)
- [Review Agent 가이드](.claude/agents/review.md)

### 워크플로우

- [Development Workflow](.claude/workflows/development.yml)
- [Testing Workflow](.claude/workflows/testing.yml)
- [Deployment Workflow](.claude/workflows/deployment.yml)
- [Multi-Agent Orchestration](.claude/workflows/multi-agent-orchestration.yml)

## 라이선스

MIT License

## 링크

- **GitHub**: https://github.com/bocopile/MOAO11y
- **JIRA**: https://gjrjr4545.atlassian.net/jira/software/projects/MOA/
- **문서**: [CLAUDE.md](CLAUDE.md)

---

© 2025 bocopile — MOAO11y Multi-Agent Orchestrated Observability Framework
