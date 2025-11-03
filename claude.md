# MOAO11y — Claude Code Multi-Agent Project Specification (v3 Full Integration)

## 📘 1. 프로젝트 개요
**프로젝트명:** MOAO11y  
**베이스 언어:** Java 11 + Spring Boot + Gradle  
**목적:**  
- Spring Actuator, PM2, Exporter(OS, RabbitMQ, MySQL)를 이용하여 시스템 및 애플리케이션 매트릭 수집  
- 수집된 데이터를 MOAServer로 전송 및 저장  
- 모든 설정은 `application.yml` 에서 관리하며 환경(`dev`, `stg`, `live`)에 따라 분리  
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

## ⚙️ 3. 구성 세부 내용

### 🧠 MOAAgent
- Spring Actuator, PM2, Exporter(OS/RabbitMQ/MySQL) 기반 매트릭 수집  
- 각 항목별 On/Off 설정 가능 (`application-agent.yml`)  
- RabbitMQ or Direct API 전송 중 하나만 선택 가능  
- 수집 주기 및 전송 주기 설정 가능  
- 수집 실패 시 재시도 로직 (기본 3회, 5초 간격)  
- 환경(`dev`, `stg`, `live`)별 분리된 설정 지원  

**예시 플로우:**
```
[Exporter/Actuator] → [MOAAgent Collector] → (RabbitMQ | Direct API)
→ [MOAServer Processor] → [Storage: CSV/MySQL]
```

---

### 🖥️ MOAServer
- MOAAgent로부터 수집 데이터 수신 및 저장  
- 저장 방식: CSV / MySQL 중 선택 가능  
- 데이터 보관 주기(`retention.period`) 동적 변경 지원  
- 중복 데이터 정제 및 통계 집계 기능 포함  
- MOAAgent와 설정 불일치 방지 로직 내장  

---

## 🤖 4. Claude Multi-Agent 구성

| Agent | 역할 | 주요 기능 |
|--------|------|-----------|
| **Coordinator** | 전체 작업 관리 | 작업 분해 및 할당, 워크플로우 제어 |
| **Backend Agent** | 서버 개발 | REST API, GraphQL, DB 작업 |
| **Frontend Agent** | 프론트엔드 개발 | React/Vue/Angular 기반 UI |
| **QA Agent** | 품질 보증 | 단위/통합/E2E 테스트 수행 |
| **Docs Agent** | 문서화 | README, API 문서, 주석 작성 |
| **Review Agent** | 코드 품질 리뷰 | 성능/보안/스타일 검토 |

> 💡 Claude Agents는 SubOrchestrator 프로젝트([https://github.com/bocopile/SubOrchestrator](https://github.com/bocopile/SubOrchestrator))를 기반으로 동작함.

---

## 🧭 5. MCP (Multi Code Platform) 설정
- GitHub : https://github.com/bocopile/MOAO11y  
- JIRA : https://gjrjr4545.atlassian.net/jira/software/projects/MOA/  
- CI/CD : GitHub → Jenkins → Nexus → Docker Registry  
- Slack Notification : Build/Deploy 시점별 알림  

---

## 🔁 6. 작업 진행 절차

### 1) 해야 할 일 분석
- 작업 리스트 작성 → JIRA 백로그 등록  
- 각 작업 우선순위 지정

### 2) 작업 시작
- 백로그 상태: “해야 할 일” → “진행중”  
- `stg` 브랜치 기준 신규 브랜치 생성  
- 기능 완료 후 “테스트 진행 중” → Stage 병합  

### 3) 통합 테스트
- `stage` 브랜치에서 전체 테스트 수행  
- 이상 없을 시 `main` 병합 PR 생성  
- 문제 발견 시 백로그 상태 “진행중”으로 회귀  

---

## 🌿 7. Branch Naming Convention

- `feature/{jira-key}-{short-desc}` → 신규 기능  
- `fix/{jira-key}-{short-desc}` → 버그 수정  
- `hotfix/{jira-key}-{short-desc}` → 긴급 수정  
- `docs/{short-desc}` → 문서 변경  
- `infra/{short-desc}` → 인프라 변경  

**머지 규칙:**  
- feature → stg → main 순으로 병합  
- Reviewer 2명 승인 필수  
- main은 항상 배포 가능한 상태 유지  

---

## 📈 8. Metrics Collection Specification

### 1️⃣ 수집 계층
| 계층 | 대상 | 목적 |
|------|------|------|
| Application Layer | Spring Actuator | 요청 수, 에러율, 스레드, GC |
| System Layer | Node Exporter | CPU, Memory, Disk, Network |
| MQ Layer | RabbitMQ Exporter | Queue, Consumer, Rate |
| DB Layer | MySQL Exporter | 쿼리량, 연결 수, 느린 쿼리 |
| Process Layer | PM2 | Uptime, Restart, Resource |

### 2️⃣ 세부 지표
#### Application (Actuator)
- health.status, http.server.requests.count, jvm.memory.used, jvm.gc.pause

#### System (Node Exporter)
- node_cpu_seconds_total, node_memory_Active_bytes, node_load1

#### RabbitMQ
- rabbitmq_queue_messages_ready, rabbitmq_channel_consumers

#### MySQL
- mysql_global_status_questions, mysql_global_status_threads_connected

#### PM2
- pm2_process_uptime, pm2_process_memory, pm2_restart_count

### 3️⃣ 정책
| 항목 | 기본값 | 설명 |
|------|---------|------|
| 수집 주기 | 30s | Exporter 데이터 수집 주기 |
| 전송 주기 | 60s | Agent → Server 전송 |
| 보관 기간 | 7일 | 데이터 보관 |
| 압축 | GZIP | 전송 시 데이터 압축 |

### 4️⃣ 확장 포인트
- Redis, Kafka, Nginx, Custom Exporter 지원  

---

## 🔍 9. Observability Policy

- 로그 포맷: JSON (timestamp, level, module, message, traceId)  
- 로그 수준: INFO(기본), DEBUG(개발), ERROR(운영)  
- Exporter 구성:
  - Node Exporter: OS metrics
  - RabbitMQ Exporter: MQ metrics
  - MySQL Exporter: DB metrics
- Prometheus endpoint: `/metrics`  
- Tracing: OpenTelemetry + Jaeger  
- 로그 수집: Loki  
- 시각화: Grafana  
- Alert: Grafana AlertManager → Slack/Webhook  

---

## 🧩 10. Gitignore 정책

```gitignore
# Java / Spring Boot
*.class
*.jar
*.war
hs_err_pid*
*.log
logs/
spring.log

# Gradle
.gradle/
build/
!gradle/wrapper/gradle-wrapper.jar

# IDE
.idea/
*.iml
.vscode/

# OS
.DS_Store
Thumbs.db

# Environment & secrets
.env
.env.*
*.pem
*.key
*.crt
application-*.yml

# Docker
.docker/
docker/tmp/
docker/data/

# Claude Code
.claude/output/
.claude/tmp/
.claude/logs/
*_generated.*

# Build artifacts
out/
target/
tmp/
*.zip

# Test Reports
/reports/
/coverage/
/jacoco/

# Infra / Terraform
infra/.terraform/
infra/terraform.tfstate*
*.tfvars

# NodeJS
node_modules/

# Data
*.csv
*.json
*.db
*.sql
exported_data/
collected_metrics/
data/
```

---

## ✅ 11. Summary

이 문서는 Claude Code Multi-Agent 환경에서 **MOAO11y Observability Framework**의  
전체 아키텍처, 에이전트 구조, 메트릭 정책, 브랜치 전략, 관찰 정책 및 Git 관리 규칙을 정의합니다.

© 2025 bocopile — MOAO11y Observability Framework
