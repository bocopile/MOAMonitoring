# MOAO11y — Claude Code Multi-Agent Project Specification (v3 Full Integration)

## 📘 1. 프로젝트 개요
**프로젝트명:** MOAO11y  
**베이스 언어:** Java 11 + Spring Boot + Gradle  
**목적:**
- Spring Actuator, PM2, Exporter(OS, RabbitMQ, MySQL)로 시스템 및 애플리케이션 메트릭 수집
- 수집된 데이터를 MOAServer로 전송 및 저장
- 모든 설정은 `application.yml`에서 관리하며 환경(`dev`, `stg`, `live`)에 따라 분리
- RabbitMQ 또는 Direct 전송 방식 중 선택 가능

**레포지토리:** [https://github.com/bocopile/MOAO11y](https://github.com/bocopile/MOAO11y)  
**JIRA:** [https://gjrjr4545.atlassian.net/jira/software/projects/MOA/](https://gjrjr4545.atlassian.net/jira/software/projects/MOA/)

---

## 📂 2. 프로젝트 구조
```
.MOAO11y
├── docs/                 # 아키텍처 및 설계 문서
├── MOAServer/            # 데이터 저장 및 처리
├── MOAAgent/             # 데이터 수집 에이전트
├── .claude/              # Claude Code 관련 설정
└── README.md
```

---

# ⚙️ 3. 구성 세부 내용 (Java 11 + Groovy DSL 수정 버전)

### 💻 빌드 환경
- Java Version: 11 (Adoptium / OpenJDK 11)
- Gradle Version: 8.x (Groovy DSL)
- Build Type: Multi-project build (`settings.gradle`, `build.gradle` 기반)

### 🧩 공통
- **MOAAgent**, **MOAServer**는 각각 독립적으로 빌드 가능 (`build.gradle`, `settings.gradle` 분리)
- Gradle(Groovy DSL) 기반 **개별 빌드** 및 **전체 일괄 빌드** 지원
- 모든 설정은 `application.yml`에 정의하며, 환경별 설정 파일(`application-dev.yml`, `application-stg.yml`, `application-live.yml`) 지원

**Gradle 빌드 예시**
```bash
./gradlew :MOAAgent:build
./gradlew :MOAServer:build
./gradlew buildAll
```

**settings.gradle 예시**
```groovy
rootProject.name = "MOAO11y"
include("MOAAgent", "MOAServer")
```

---

## 🤖 4. Claude Multi-Agent 구성

| Agent | 역할 | 주요 기능 |
|--------|------|-----------|
| **Coordinator** | 전체 관리 | 작업 분해, 워크플로우 제어, JIRA/GIT 관리 |
| **Backend Agent** | 서버 개발 | REST API, GraphQL, DB 작업 |
| **Frontend Agent** | 프론트엔드 | React/Vue/Angular UI |
| **QA Agent** | 테스트 | 단위/통합/E2E 테스트 |
| **Docs Agent** | 문서화 | README, API 문서, 주석 |
| **Review Agent** | 코드 품질 | 성능/보안/스타일 검토 |

---

## 🧠 AITMPL 기반 추가 세팅

### 1️⃣ Agents
- `agent/devops-observability-specialist`: Observability 설계 및 Exporter 구조 분석용
- `agent/code-reviewer-security`: 코드 품질/보안 리뷰 자동화
- `agent/documentation-generator`: API/README 자동 생성

**📥 다운로드 명령어 예시:**
```bash
npx claude-code-templates@latest --agent=devops-observability-specialist
npx claude-code-templates@latest --agent=code-reviewer-security
npx claude-code-templates@latest --agent=documentation-generator
```

### 2️⃣ Commands
- `/generate-metrics-collector`: Exporter 수집기 자동 템플릿 생성
- `/setup-ci-pipeline`: CI/CD 파이프라인 템플릿 구성
- `/audit-observability-config`: 관찰 정책 자동 검증

**📥 설치 명령어 예시:**
```bash
npx claude-code-templates@latest --command=generate-metrics-collector
npx claude-code-templates@latest --command=setup-ci-pipeline
npx claude-code-templates@latest --command=audit-observability-config
```

### 3️⃣ Plugins
- `plugin/devops-stack-observability`: Observability Stack 통합 세팅
- `plugin/springboot-microservice-template`: Spring Boot 구조 초기화 템플릿

**📥 설치 명령어 예시:**
```bash
npx claude-code-templates@latest --plugin=devops-stack-observability
npx claude-code-templates@latest --plugin=springboot-microservice-template
```

### 4️⃣ Settings
- `setting/gradle-multi-project-template`: Gradle 멀티프로젝트 템플릿
- `setting/application-yml-env-profiles`: 환경별 yml 관리 구조 자동화

**📥 설치 명령어 예시:**
```bash
npx claude-code-templates@latest --setting=gradle-multi-project-template
npx claude-code-templates@latest --setting=application-yml-env-profiles
```

### 5️⃣ Hooks
- `hook/git/pre-commit-obs-check`: 커밋 전 Exporter 설정 누락 검증
- `hook/ci/post-merge-deploy-alert`: 병합 후 배포 알림/검증 자동화

**📥 설치 명령어 예시:**
```bash
npx claude-code-templates@latest --hook=git/pre-commit-obs-check
npx claude-code-templates@latest --hook=ci/post-merge-deploy-alert
```

### 6️⃣ MCPs (Multi Code Platform)
- `mcp/github-jira-integration`: GitHub ↔ JIRA 자동 동기화
- `mcp/prometheus-grafana-dashboard`: Prometheus + Grafana 연동 대시보드 자동화

**📥 설치 명령어 예시:**
```bash
npx claude-code-templates@latest --mcp=github-jira-integration
npx claude-code-templates@latest --mcp=prometheus-grafana-dashboard
```

### 7️⃣ Skills
- `skill/pdf-report-generator`: PDF 리포트 자동 생성
- `skill/otel-trace-visualizer`: OpenTelemetry 트레이스 시각화

**📥 설치 명령어 예시:**
```bash
npx claude-code-templates@latest --skill=pdf-report-generator
npx claude-code-templates@latest --skill=otel-trace-visualizer
```

---

## 🔗 공식 다운로드 경로
[https://www.aitmpl.com/agents](https://www.aitmpl.com/agents)

모든 Agents, Commands, Plugins 등은 위 링크에서 직접 다운로드하거나 `npx claude-code-templates@latest --<type>=<name>` 형식으로 설치 가능합니다.

---

## ✅ Summary
Claude Code + AITMPL 통합 환경에서 **MOAO11y Observability Framework**의 전체 아키텍처, 멀티 에이전트 구성, 메트릭 수집 정책, Git 관리 규칙, 설치 명령어를 포함합니다.

© 2025 bocopile — MOAO11y Observability Framework


## git commit 시

각 깃 커밋마다 아래 내용이 들어가지 않도록 반드시 체크한 후 커밋 및 푸시를 진행한다.
```bash
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```