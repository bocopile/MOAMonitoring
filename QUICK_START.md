# MOAO11y Quick Start Guide

## 🚀 빠른 시작 (5분 완료)

### 1단계: JIRA API Token 발급 (2분)

1. https://id.atlassian.com/manage-profile/security/api-tokens 접속
2. **"Create API token"** 클릭
3. 토큰 이름: `MOAO11y-local-dev`
4. 생성된 토큰 즉시 복사 (다시 볼 수 없음!)

### 2단계: 환경 설정 (1분)

```bash
# .env 파일 열기
vim .env  # 또는 code .env (VSCode)

# 아래 3개 항목만 수정
JIRA_USER=your-email@example.com          # ← 본인 이메일
JIRA_API_TOKEN=ATBBxxx...                 # ← 방금 복사한 토큰
SPRING_PROFILES_ACTIVE=dev                # ← dev/stg/live 선택
```

### 3단계: 연결 테스트 (1분)

```bash
# .env 로드
source .env

# JIRA 연결 확인
curl -s -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
  "${JIRA_URL}/rest/api/2/myself" | python3 -m json.tool

# 성공 시 본인 계정 정보가 JSON으로 출력됨
```

### 4단계: 첫 이슈 생성 (1분)

```bash
# 테스트 이슈 생성
./scripts/jira-create-issue.sh "MOAO11y 환경 설정 완료" "로컬 개발 환경 구성 테스트"

# 출력 예시:
# ✅ 이슈 생성 완료!
#    이슈 키: MOA-15
#    URL: https://gjrjr4545.atlassian.net/browse/MOA-15
```

---

## 📋 자주 사용하는 명령어

### JIRA 이슈 관리
```bash
# 이슈 생성
./scripts/jira-create-issue.sh "작업 제목"

# 진행 중인 이슈 확인
./scripts/jira-list-issues.sh "In Progress"

# 작업 시작
./scripts/jira-transition-issue.sh MOA-15 "In Progress"

# 작업 완료
./scripts/jira-transition-issue.sh MOA-15 "Done"
```

### 프로젝트 빌드
```bash
# MOAAgent 빌드
./gradlew :MOAAgent:build

# MOAServer 빌드
./gradlew :MOAServer:build

# 전체 빌드
./gradlew buildAll
```

### 애플리케이션 실행
```bash
# 개발 환경으로 실행
./gradlew :MOAAgent:bootRun --args='--spring.profiles.active=dev'
./gradlew :MOAServer:bootRun --args='--spring.profiles.active=dev'
```

---

## 🛠️ 트러블슈팅

### "command not found: ./scripts/..."
```bash
chmod +x scripts/*.sh
```

### "JIRA 인증 실패 (401)"
```bash
# .env 파일 확인
cat .env | grep JIRA_

# API Token 재발급 필요
# → https://id.atlassian.com/manage-profile/security/api-tokens
```

### ".env 파일 로드가 안됨"
```bash
# 수동 로드
export $(cat .env | grep -v '^#' | xargs)

# 또는 direnv 사용 (자동 로드)
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
direnv allow
```

---

## 📚 상세 문서

- **환경 설정**: [`docs/ENV_SETUP_GUIDE.md`](docs/ENV_SETUP_GUIDE.md)
- **JIRA 스크립트**: [`scripts/README.md`](scripts/README.md)
- **프로젝트 구조**: [`CLAUDE.md`](CLAUDE.md)

---

## 💡 다음 단계

1. [ ] JIRA 프로젝트 대시보드 확인: https://gjrjr4545.atlassian.net/jira/software/projects/MOA/
2. [ ] MOAAgent 개발 시작
3. [ ] MOAServer API 설계
4. [ ] 첫 스프린트 계획 수립

---

**문제가 있나요?**
- GitHub Issues: https://github.com/bocopile/MOAO11y/issues
- JIRA Project: https://gjrjr4545.atlassian.net/jira/software/projects/MOA/
