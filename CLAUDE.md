# MOAO11y — Claude Code Multi-Agent Orchestration

> **Orchestration Vibe**: AI 에이전트들이 자율적으로 협업하는 환경
> **Project**: Observability Framework (Java 11 + Spring Boot + Gradle)

---

## 🎯 Global Rules

### 프로젝트 정체성
- **프로젝트명**: MOAO11y
- **목적**: Spring Actuator, PM2, Exporter를 이용한 시스템/애플리케이션 메트릭 수집 및 저장
- **기술 스택**: Java 11, Spring Boot, Gradle (Groovy DSL)
- **구조**: Multi-project (MOAAgent, MOAServer)

### 코딩 표준
```yaml
language: Java 11
framework: Spring Boot 2.x
build_tool: Gradle 8.x (Groovy DSL)
code_style:
  - Google Java Style Guide
  - 들여쓰기: 4 spaces
  - 라인 길이: 120자
  - 패키지 구조: domain-driven
naming_convention:
  classes: PascalCase
  methods: camelCase
  constants: UPPER_SNAKE_CASE
  packages: lowercase
```

### 필수 준수 사항

#### 1. 환경 분리
- `dev`, `stg`, `live` 환경 엄격히 분리
- 모든 설정은 `application-{env}.yml`로 관리
- 절대 하드코딩 금지

#### 2. 에러 처리
```java
// ✅ 올바른 예외 처리
try {
    collectMetrics();
} catch (CollectionException e) {
    logger.error("Metric collection failed: {}", e.getMessage(), e);
    retryWithBackoff(3, 5000); // 3회, 5초 간격
    throw new MetricCollectionException("Failed after retries", e);
}

// ❌ 절대 금지
catch (Exception e) {
    // 빈 catch 블록 또는 단순 로그만
}
```

#### 3. 로깅 규칙
```java
// JSON 형식 로그 (timestamp, level, module, message, traceId)
log.info("Metric collected: type={}, value={}, timestamp={}",
    type, value, timestamp);
// 민감 정보 로그 금지: password, token, api-key
```

#### 4. Git Commit Convention
```bash
# AI가 작성한 코드
feat(agent): Add RabbitMQ metrics collector

- Implement RabbitMQExporter integration
- Add queue depth monitoring
- Add consumer count tracking

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude <noreply@anthropic.com>

# 사람이 작성한 코드
feat(server): Update retention policy

- Change default retention from 7 to 14 days
- Add dynamic configuration reload
```

#### 5. 보안 원칙
- 모든 외부 입력 검증 필수
- SQL Injection 방지: PreparedStatement 사용
- API Key는 환경변수로만 관리
- `.gitignore`에 민감 정보 등록

---

## 🤖 Multi-Agent 협업 구조

### Agent 역할 분담
```
Coordinator (지휘자)
    ├── Backend Agent     → MOAAgent/MOAServer 개발
    ├── QA Agent          → 테스트 & 품질 검증
    ├── Docs Agent        → 문서화
    └── Review Agent      → 코드 리뷰 & 보안
```

### 협업 프로토콜

#### 1. 작업 시작 전
- [ ] JIRA 티켓 확인 (`MOA-XXX`)
- [ ] 현재 브랜치 확인 (`feature/MOA-XXX-description`)
- [ ] spec 파일 확인 (`.claude/specs/*.spec.yml`)

#### 2. 개발 중
- [ ] Definition of Done 체크
- [ ] 기존 코드 파괴 금지 (`preserve_existing`)
- [ ] 요청 범위 이탈 금지 (`no_extras`)

#### 3. 완료 시
- [ ] 모든 테스트 통과
- [ ] 코드 리뷰 통과
- [ ] 문서 업데이트 완료

---

## 🎼 Orchestration 설정

### 통신 방식
- **Agent 간 통신**: `.claude/workflows/` 정의 참조
- **상태 공유**: `.claude/config/state.json`
- **에러 전파**: `.claude/config/error-handling.yml`

### AI 루프 감지 & 개입
```yaml
loop_detection:
  enabled: true
  patterns:
    - "같은 에러 3회 이상 반복"
    - "10분 이상 진전 없음"
    - "'죄송합니다' 5회 이상"
  action:
    - alert_human: true
    - pause_workflow: true
    - log_context: true
```

### 토큰 관리
```yaml
token_strategy:
  simple_tasks:      # 반복/단순 작업
    - "코드 포매팅"
    - "테스트 케이스 생성"
    - "문서 주석 추가"
    agent: gemini-cli  # 무료/저렴

  complex_tasks:     # 중요/복잡 작업
    - "아키텍처 설계"
    - "복잡한 버그 수정"
    - "성능 최적화"
    agent: claude-code  # 고품질

  daily_limit: 50000
  alert_threshold: 0.8  # 80% 사용 시 알림
```

---

## 📋 Quality Assurance (spec-kit 통합)

### Definition of Done
상세 내용: `.claude/specs/quality-gates.spec.yml` 참조

```yaml
must_fix:
  - "컴파일 에러 0개"
  - "모든 테스트 통과"
  - "코드 커버리지 > 80%"
  - "SonarQube Quality Gate 통과"

preserve_existing:
  - "기존 API 시그니처 변경 금지"
  - "동작하는 기능 수정 금지"
  - "기존 테스트 삭제/수정 금지"
  - "하위 호환성 100% 유지"

no_extras:
  - "요청하지 않은 파일 수정 금지"
  - "기존 코드 스타일 유지"
  - "새로운 의존성 추가 금지"
  - "불필요한 리팩토링 금지"

performance:
  - "메트릭 수집 오버헤드 < 1% CPU"
  - "메모리 사용량 < 512MB"
  - "API 응답시간 < 200ms"
```

---

## 🌿 Branch & Workflow

### Branch 전략
```
main (항상 배포 가능)
 ↑
stg (통합 테스트)
 ↑
feature/MOA-XXX-description (개발)
```

### 작업 흐름
```
1. JIRA 백로그 확인
2. feature 브랜치 생성
3. Agent들이 협업하여 개발
4. QA Agent 자동 테스트
5. Review Agent 코드 리뷰
6. stg 병합 → 통합 테스트
7. main 병합 → 배포
```

---

## 🔗 MCP Integration

### 연동 서비스
- **GitHub**: https://github.com/bocopile/MOAO11y
- **JIRA**: https://gjrjr4545.atlassian.net/jira/software/projects/MOA/
- **Slack**: Build/Deploy 알림

### MCP Tools
```yaml
mcp_tools:
  - github-jira-sync       # JIRA ↔ GitHub 자동 동기화
  - prometheus-grafana     # Observability 대시보드
  - slack-notification     # 빌드/배포 알림
```

---

## 📚 참조 문서

### Agent별 상세 규칙
- Backend: `.claude/agents/backend.md`
- QA: `.claude/agents/qa.md`
- Docs: `.claude/agents/docs.md`
- Review: `.claude/agents/review.md`

### Spec 파일
- Quality Gates: `.claude/specs/quality-gates.spec.yml`
- MOAAgent Spec: `.claude/specs/moaagent.spec.yml`
- MOAServer Spec: `.claude/specs/moaserver.spec.yml`

### 워크플로우
- Development: `.claude/workflows/development.yml`
- Testing: `.claude/workflows/testing.yml`
- Deployment: `.claude/workflows/deployment.yml`

---

## ⚠️ 중요 알림

### AI가 절대 하면 안 되는 것
1. ❌ 문제 회피: 어려운 문제를 만나면 해결하지 않고 대안 제시
2. ❌ 기존 기능 파괴: 새 기능 추가하면서 원래 잘 돌던 로직 무단 수정
3. ❌ 범위 이탈: 요청하지 않은 기능 추가 또는 불필요한 리팩토링
4. ❌ 일관성 무시: 매번 다른 스타일과 패턴으로 코드 생성
5. ❌ 품질 기준 무시: 테스트 실패를 무시하고 진행

### Human Intervention 필요 시점
- 아키텍처 변경 결정
- 보안 정책 수정
- 성능 트레이드오프 판단
- 기술 스택 변경
- 라이선스 이슈

---

## 🎯 Success Metrics

### 개발 생산성
- Feature 개발 시간 75% 단축 목표
- AI 개입 횟수 80% 감소 목표
- 테스트 커버리지 80% 이상 유지

### 코드 품질
- SonarQube Quality Gate 100% 통과
- 버그 발생률 <1%
- 기술 부채 지수 <5%

---

© 2025 bocopile — MOAO11y Claude Code Multi-Agent Environment