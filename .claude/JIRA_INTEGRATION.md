# JIRA-GitHub Integration Guide

MOAO11y 프로젝트의 JIRA와 GitHub 연동 가이드입니다.

## 📋 개요

- **JIRA 프로젝트**: MOA (MOAO11y)
- **JIRA URL**: https://gjrjr4545.atlassian.net/jira/software/projects/MOA/
- **GitHub Repository**: https://github.com/bocopile/MOAO11y
- **프로젝트 키**: MOA

## 🔧 초기 설정

### 1. JIRA API Token 생성

1. JIRA에 로그인
2. Profile → Settings → Security → API tokens
3. "Create API token" 클릭
4. 토큰 이름 입력 (예: "GitHub Integration")
5. 생성된 토큰 복사 (한 번만 표시됨!)

### 2. GitHub Secrets 설정

Repository Settings → Secrets and variables → Actions에서 추가:

```
JIRA_USER_EMAIL: your-email@example.com
JIRA_API_TOKEN: your-generated-api-token
```

### 3. Git Hooks 활성화

```bash
cd /Users/okestro/IdeaProjects/MOAO11y

# Commit message hook (JIRA 티켓 검증)
ln -sf ../../.claude/hooks/commit-msg .git/hooks/commit-msg

# 또는 모든 hooks 한번에
for hook in .claude/hooks/*; do
  hook_name=$(basename "$hook")
  ln -sf "../../.claude/hooks/$hook_name" ".git/hooks/$hook_name"
done
```

### 4. jira-cli 설치 (선택사항)

```bash
npm install -g jira-cli

# 설정
jira config

# 입력 정보:
# - Base URL: https://gjrjr4545.atlassian.net
# - Email: your-email@example.com
# - API Token: your-api-token
# - Default Project: MOA
```

## 🎯 워크플로우

### 1. 이슈 생성 및 작업 시작

```bash
# Claude Code에서 JIRA 이슈 생성
/jira-create-issue

# 또는 jira-cli 사용
jira issue create \
  --project MOA \
  --type Task \
  --summary "Add RabbitMQ metrics collector" \
  --priority Medium

# 브랜치 생성 (MOA-123이 발급됐다고 가정)
git checkout -b feature/MOA-123-add-rabbitmq-metrics
git push -u origin feature/MOA-123-add-rabbitmq-metrics

# ✅ JIRA 상태 자동 변경: "To Do" → "In Progress"
```

### 2. 커밋 작성

커밋 메시지에 반드시 JIRA 티켓 포함:

```bash
# ✅ 올바른 형식
git commit -m "MOA-123: Implement RabbitMQ metrics collector"
git commit -m "[MOA-123] Add unit tests for collector"

# ❌ 잘못된 형식 (hook이 차단)
git commit -m "Add metrics collector"

# Hook 우회 (권장하지 않음)
git commit -m "Quick fix" --no-verify
```

**Commit Message Hook 검증 내용:**
- JIRA 티켓 형식 확인 (MOA-\d+)
- 티켓 존재 여부 확인 (jira-cli 설치 시)
- Claude Code 서명 자동 제거

### 3. Pull Request 생성

```bash
# PR 제목에 JIRA 티켓 포함
gh pr create \
  --title "[MOA-123] Add RabbitMQ metrics collector" \
  --body "Implements metrics collection from RabbitMQ management API"

# ✅ JIRA 상태 자동 변경: "In Progress" → "Code Review"
# ✅ JIRA에 PR 링크 코멘트 자동 추가
```

**GitHub Actions가 자동 실행:**
- JIRA 티켓 상태를 "Code Review"로 변경
- JIRA에 PR 정보 코멘트 추가
- PR 제목/브랜치명에서 JIRA 티켓 검증

### 4. Code Review 및 Merge

```bash
# PR 리뷰 완료 후 merge
gh pr merge 123 --squash

# ✅ JIRA 상태 자동 변경: "Code Review" → "Testing"
# ✅ JIRA에 merge 정보 코멘트 추가
```

### 5. Release 배포

```bash
# Release 태그 생성
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 또는 GitHub에서 Release 생성
gh release create v1.0.0 --title "v1.0.0" --notes "Release notes"

# ✅ 자동 실행:
# - 해당 릴리즈에 포함된 모든 JIRA 이슈 추출
# - 이슈 상태를 "Done"으로 변경
# - JIRA에 버전 생성
# - 이슈에 Fix Version 설정
# - Release Notes 생성
```

## 🤖 사용 가능한 Commands

### `/jira-create-issue`

새로운 JIRA 이슈를 생성하고 선택적으로 Git 브랜치도 생성합니다.

```
You: /jira-create-issue
Claude: 어떤 타입의 이슈를 생성하시겠습니까?
        - Story
        - Task
        - Bug
        - Epic
```

**기능:**
- 대화형 이슈 생성
- 자동 브랜치 생성 제안
- JIRA 상태 업데이트

### `/jira-transition`

JIRA 이슈의 상태를 변경합니다.

```bash
# 현재 브랜치에서 티켓 자동 인식
/jira-transition "In Progress"

# 특정 티켓 지정
/jira-transition MOA-456 "Testing"

# 코멘트와 함께
/jira-transition MOA-789 "Done" --comment "Verified in production"
```

## 🔄 자동 상태 전환

| Git 이벤트 | JIRA 상태 변경 | Trigger |
|-----------|--------------|---------|
| 브랜치 생성 | To Do → In Progress | `.github/workflows/jira-integration.yml` |
| PR 생성 | In Progress → Code Review | PR opened 이벤트 |
| PR 병합 | Code Review → Testing | PR merged 이벤트 |
| Release 배포 | Testing → Done | Release published 이벤트 |

## 📐 명명 규칙

### 브랜치명

```
{type}/{ticket-id}-{short-description}
```

**Examples:**
```bash
feature/MOA-123-add-rabbitmq-metrics
bugfix/MOA-456-fix-memory-leak
hotfix/MOA-789-critical-security-fix
refactor/MOA-101-optimize-collector
docs/MOA-202-update-api-docs
test/MOA-303-add-integration-tests
```

### 커밋 메시지

```
MOA-XXX: {commit message}
```

**Examples:**
```bash
MOA-123: Implement RabbitMQ metrics collector
MOA-123: Add unit tests for collector
MOA-123: Update documentation
```

### PR 제목

```
[MOA-XXX] {PR title}
```

**Examples:**
```bash
[MOA-123] Add RabbitMQ metrics collector
[MOA-456] Fix memory leak in data processor
[MOA-789] Critical security patch
```

## 🔍 JIRA 티켓 검증

### Pre-commit Hook

**위치**: `.claude/hooks/commit-msg`

**검증 항목:**
- ✅ 커밋 메시지에 MOA-\d+ 형식 포함 확인
- ✅ JIRA 티켓 존재 여부 확인 (jira-cli 있을 경우)
- ✅ 권장 형식 가이드 제공
- ✅ Claude Code 서명 자동 제거

**제외 패턴:**
- `Merge ...`
- `Revert ...`
- `Initial commit`
- `WIP ...`

### GitHub Actions 검증

**위치**: `.github/workflows/jira-integration.yml`

**검증 항목:**
- ✅ PR 제목 또는 브랜치명에 JIRA 티켓 포함 확인
- ✅ 검증 실패 시 PR check 실패

## 🛠️ 설정 파일

### `.claude/settings/jira-config.json`

JIRA 연동 설정을 포함합니다:

```json
{
  "jira": {
    "baseUrl": "https://gjrjr4545.atlassian.net",
    "project": {
      "key": "MOA",
      "name": "MOAO11y"
    }
  },
  "integration": {
    "enabled": true,
    "autoTransition": true,
    "requireJiraTicket": true
  }
}
```

## 📊 JIRA 워크플로우

```
┌─────────┐   브랜치 생성   ┌────────────┐   PR 생성   ┌─────────────┐
│  To Do  │ ─────────────→ │ In Progress│ ──────────→ │ Code Review │
└─────────┘                └────────────┘             └─────────────┘
                                                              │
                                                          PR 병합
                                                              ↓
┌─────────┐   Release    ┌─────────┐
│  Done   │ ←──────────  │ Testing │
└─────────┘              └─────────┘
```

## 🚨 문제 해결

### 커밋이 거부됨

```bash
❌ Commit message validation failed!
```

**해결:**
- 커밋 메시지에 `MOA-XXX` 형식으로 티켓 추가
- 또는 `--no-verify` 플래그 사용 (권장하지 않음)

### JIRA 상태 전환 실패

**원인:**
- API Token 만료/잘못됨
- GitHub Secrets 미설정
- JIRA 권한 부족

**해결:**
1. JIRA API Token 재생성
2. GitHub Secrets 업데이트
3. JIRA 프로젝트 권한 확인

### GitHub Actions 실패

**확인 사항:**
- Actions → 해당 워크플로우 로그 확인
- `JIRA_USER_EMAIL`, `JIRA_API_TOKEN` Secrets 설정 확인
- JIRA 티켓이 실제로 존재하는지 확인

## 📚 추가 리소스

- **JIRA REST API**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/
- **GitHub Actions**: `.github/workflows/jira-*.yml`
- **Commands**: `.claude/commands/jira-*.md`
- **Hooks**: `.claude/hooks/commit-msg`
- **Config**: `.claude/settings/jira-config.json`

## 💡 Best Practices

1. **항상 JIRA 티켓 생성 후 작업 시작**
2. **브랜치명에 티켓 ID 포함**
3. **커밋 메시지에 티켓 ID 명시**
4. **PR 제목에 티켓 ID 포함**
5. **작업 완료 시 JIRA 상태 확인**
6. **Release 시 모든 티켓이 Done 상태인지 확인**

## 🔐 보안

- API Token은 절대 코드에 포함하지 않기
- GitHub Secrets로 관리
- Token은 정기적으로 갱신
- 최소 권한 원칙 적용

---

**버전**: 1.0.0
**업데이트**: 2025-11-03
**관리**: MOAO11y Team
