# JIRA API Token 설정 가이드

JIRA API Token을 안전하게 설정하는 방법입니다.

## ⚠️ 중요 주의사항

**절대 하지 말 것:**
- ❌ 코드에 직접 하드코딩
- ❌ Git에 커밋
- ❌ `.claude/settings/jira-config.json`에 직접 입력
- ❌ 공개 저장소에 노출

**올바른 방법:**
- ✅ GitHub Secrets 사용 (CI/CD용)
- ✅ 환경 변수 사용 (로컬 개발용)
- ✅ `.env` 파일 사용 (Git에서 제외)

---

## 🔑 Step 1: JIRA API Token 생성

1. **JIRA에 로그인**
   - URL: https://gjrjr4545.atlassian.net

2. **Profile 메뉴 접근**
   - 우측 상단 프로필 아이콘 클릭
   - "Settings" 선택

3. **API Token 생성**
   - "Security" 탭 클릭
   - "Create and manage API tokens" 선택
   - "Create API token" 버튼 클릭
   - 토큰 이름 입력 (예: "MOAO11y GitHub Integration")
   - "Create" 클릭

4. **토큰 복사**
   - ⚠️ 생성된 토큰을 **즉시 복사** (한 번만 표시됨!)
   - 안전한 곳에 임시 저장

---

## 🚀 Step 2: GitHub Actions 설정 (CI/CD용)

### 2-1. GitHub Repository Secrets 설정

```bash
# 브라우저에서 설정
https://github.com/bocopile/MOAO11y/settings/secrets/actions
```

1. **"New repository secret" 클릭**

2. **첫 번째 Secret 추가**
   - Name: `JIRA_USER_EMAIL`
   - Value: `your-email@example.com` (JIRA 로그인 이메일)
   - "Add secret" 클릭

3. **두 번째 Secret 추가**
   - Name: `JIRA_API_TOKEN`
   - Value: `복사한 API Token 붙여넣기`
   - "Add secret" 클릭

### 2-2. 설정 확인

```bash
# Secrets가 추가되면 GitHub Actions에서 자동으로 사용됨
# .github/workflows/jira-integration.yml
# .github/workflows/jira-release.yml
```

**확인 방법:**
1. Repository → Settings → Secrets and variables → Actions
2. `JIRA_USER_EMAIL`, `JIRA_API_TOKEN` 두 개가 표시되어야 함

---

## 💻 Step 3: 로컬 개발 환경 설정

### Option 1: 환경 변수 (권장)

#### macOS/Linux:

**방법 A: Shell Profile에 추가 (영구 적용)**

```bash
# ~/.zshrc 또는 ~/.bashrc 에 추가
echo 'export JIRA_USER_EMAIL="your-email@example.com"' >> ~/.zshrc
echo 'export JIRA_API_TOKEN="your-api-token"' >> ~/.zshrc

# 적용
source ~/.zshrc
```

**방법 B: 세션별 설정 (임시)**

```bash
export JIRA_USER_EMAIL="your-email@example.com"
export JIRA_API_TOKEN="your-api-token"
```

#### Windows (PowerShell):

```powershell
# 세션별
$env:JIRA_USER_EMAIL = "your-email@example.com"
$env:JIRA_API_TOKEN = "your-api-token"

# 영구 설정 (시스템 환경 변수)
[System.Environment]::SetEnvironmentVariable('JIRA_USER_EMAIL', 'your-email@example.com', 'User')
[System.Environment]::SetEnvironmentVariable('JIRA_API_TOKEN', 'your-api-token', 'User')
```

### Option 2: .env 파일 사용

**1. .env 파일 생성**

```bash
cd /Users/okestro/IdeaProjects/MOAO11y

cat > .env << 'EOF'
# JIRA Configuration
JIRA_USER_EMAIL=your-email@example.com
JIRA_API_TOKEN=your-api-token
JIRA_BASE_URL=https://gjrjr4545.atlassian.net
JIRA_PROJECT_KEY=MOA
EOF
```

**2. .gitignore에 추가** (이미 추가되어 있어야 함)

```bash
# .gitignore 확인
cat .gitignore | grep .env

# 없으면 추가
echo ".env" >> .gitignore
```

**3. 사용 방법**

```bash
# 환경 변수 로드
source .env

# 또는 스크립트에서
export $(cat .env | xargs)
```

---

## 🛠️ Step 4: jira-cli 설정 (선택사항)

jira-cli를 사용하려면 별도 설정이 필요합니다.

### 4-1. 설치

```bash
npm install -g jira-cli
```

### 4-2. 초기 설정

```bash
jira config

# 입력 정보:
# Base URL: https://gjrjr4545.atlassian.net
# Email: your-email@example.com
# API Token: [생성한 API Token 붙여넣기]
# Default Project: MOA
```

### 4-3. 설정 파일 위치

```bash
# macOS/Linux
~/.jira-cli/config.json

# Windows
%USERPROFILE%\.jira-cli\config.json
```

### 4-4. 테스트

```bash
# JIRA 연결 테스트
jira issue view MOA-1

# 이슈 생성 테스트
jira issue create \
  --project MOA \
  --type Task \
  --summary "Test issue from CLI" \
  --priority Low
```

---

## ✅ Step 5: 설정 확인

### 5-1. 환경 변수 확인

```bash
# macOS/Linux
echo $JIRA_USER_EMAIL
echo $JIRA_API_TOKEN

# 설정되어 있으면 값이 출력됨
```

### 5-2. GitHub Secrets 확인

```bash
# GitHub CLI 사용
gh secret list

# 또는 웹에서 확인
# https://github.com/bocopile/MOAO11y/settings/secrets/actions
```

### 5-3. 연결 테스트

```bash
# JIRA API 테스트 (curl 사용)
curl -X GET \
  -H "Content-Type: application/json" \
  -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
  "https://gjrjr4545.atlassian.net/rest/api/3/myself"

# 성공 시 사용자 정보 JSON 응답
```

---

## 🔧 Git Hooks에서 사용

Git hooks는 환경 변수를 자동으로 읽습니다.

**`.claude/hooks/commit-msg`**:
```bash
# jira-cli가 설치되어 있고 설정되어 있으면 자동으로 티켓 검증
if command -v jira &> /dev/null; then
    jira issue view "$JIRA_TICKET" &> /dev/null
fi
```

설정이 없어도 hook은 동작하지만, 티켓 검증은 스킵됩니다.

---

## 📋 설정 체크리스트

### GitHub Actions (CI/CD)
- [ ] JIRA API Token 생성 완료
- [ ] GitHub Repository Secrets에 `JIRA_USER_EMAIL` 추가
- [ ] GitHub Repository Secrets에 `JIRA_API_TOKEN` 추가
- [ ] Secrets 목록에서 확인 완료

### 로컬 개발
- [ ] 환경 변수 설정 (`JIRA_USER_EMAIL`, `JIRA_API_TOKEN`)
- [ ] 또는 `.env` 파일 생성
- [ ] `.gitignore`에 `.env` 추가 확인
- [ ] 환경 변수 로드 확인

### jira-cli (선택)
- [ ] jira-cli 설치
- [ ] `jira config` 실행 완료
- [ ] 연결 테스트 성공

---

## 🚨 문제 해결

### "401 Unauthorized" 오류

**원인:**
- 잘못된 이메일 또는 API Token
- Token 만료

**해결:**
1. JIRA에서 새 API Token 생성
2. GitHub Secrets 업데이트
3. 환경 변수 재설정

### Git Hook이 JIRA 티켓을 찾지 못함

**원인:**
- jira-cli 미설치
- 환경 변수 미설정

**해결:**
```bash
# 1. jira-cli 설치
npm install -g jira-cli

# 2. 설정
jira config

# 3. 테스트
jira issue view MOA-1
```

### GitHub Actions 실패

**확인 사항:**
1. Secrets이 올바르게 설정되었는지
2. JIRA API Token이 유효한지
3. Actions 로그 확인

```bash
# Actions 페이지에서 로그 확인
https://github.com/bocopile/MOAO11y/actions
```

---

## 🔐 보안 Best Practices

### DO ✅
- API Token을 안전한 곳에 보관
- 정기적으로 Token 갱신 (3-6개월)
- 최소 권한 원칙 적용
- GitHub Secrets 사용

### DON'T ❌
- Token을 코드에 하드코딩
- Token을 Git에 커밋
- Token을 다른 사람과 공유
- Token을 공개 채널에 노출

---

## 📚 참고 자료

- **JIRA API Docs**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/
- **GitHub Secrets**: https://docs.github.com/en/actions/security-guides/encrypted-secrets
- **jira-cli**: https://github.com/ankitpokhrel/jira-cli

---

## 💡 요약

### GitHub Actions용
```bash
GitHub Repository → Settings → Secrets and variables → Actions
→ Add: JIRA_USER_EMAIL
→ Add: JIRA_API_TOKEN
```

### 로컬 개발용
```bash
# Option 1: 환경 변수
export JIRA_USER_EMAIL="your-email@example.com"
export JIRA_API_TOKEN="your-token"

# Option 2: .env 파일
echo 'JIRA_USER_EMAIL=your-email@example.com' > .env
echo 'JIRA_API_TOKEN=your-token' >> .env
```

**중요**: 절대 코드나 설정 파일에 직접 넣지 마세요!

---

**버전**: 1.0.0
**업데이트**: 2025-11-03
**관리**: MOAO11y Team
