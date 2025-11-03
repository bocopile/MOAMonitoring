# JIRA 연동 스크립트

로컬에서 JIRA 백로그를 관리할 수 있는 간단한 Shell 스크립트 모음입니다.

## 사전 준비

1. `.env` 파일 설정 완료
2. `python3` 설치 (JSON 파싱용)
3. `curl` 설치 (기본 제공)

자세한 설정 방법은 [`docs/ENV_SETUP_GUIDE.md`](../docs/ENV_SETUP_GUIDE.md)를 참조하세요.

## 스크립트 목록

### 1. 이슈 생성 (`jira-create-issue.sh`)

새로운 JIRA 이슈를 생성합니다.

```bash
# 기본 사용
./scripts/jira-create-issue.sh "MOAAgent 초기 구조 설계"

# 설명 포함
./scripts/jira-create-issue.sh "RabbitMQ 연동" "메트릭 전송을 위한 RabbitMQ Producer 구현"

# 이슈 타입 지정
./scripts/jira-create-issue.sh "Actuator endpoint 오류" "health 체크 실패" "Bug"
```

**파라미터:**
- `$1`: 이슈 제목 (필수)
- `$2`: 이슈 설명 (선택, 기본값: "No description provided")
- `$3`: 이슈 타입 (선택, 기본값: "Task", 옵션: Task|Story|Bug)

**출력 예시:**
```
📝 JIRA 이슈 생성 중...
   프로젝트: MOA
   제목: MOAAgent 초기 구조 설계
   타입: Task

✅ 이슈 생성 완료!
   이슈 키: MOA-15
   URL: https://gjrjr4545.atlassian.net/browse/MOA-15
```

---

### 2. 이슈 목록 조회 (`jira-list-issues.sh`)

프로젝트의 이슈 목록을 조회합니다.

```bash
# 전체 이슈 조회 (최근 20개)
./scripts/jira-list-issues.sh

# 특정 상태 조회
./scripts/jira-list-issues.sh "In Progress"
./scripts/jira-list-issues.sh "Done"
./scripts/jira-list-issues.sh "To Do"
```

**파라미터:**
- `$1`: 상태 필터 (선택)

**출력 예시:**
```
📋 JIRA 이슈 조회 중...
   프로젝트: MOA
   상태: In Progress

총 5개 이슈 (최근 5개 표시)
────────────────────────────────────────────────────────────────────────────────
🎫 MOA-15: MOAAgent 초기 구조 설계
   상태: In Progress | 담당자: 홍길동
   URL: https://gjrjr4545.atlassian.net/browse/MOA-15

🎫 MOA-14: RabbitMQ 연동
   상태: In Progress | 담당자: Unassigned
   URL: https://gjrjr4545.atlassian.net/browse/MOA-14
```

---

### 3. 이슈 상태 전환 (`jira-transition-issue.sh`)

이슈의 상태를 변경합니다 (To Do → In Progress → Done).

```bash
# 이슈를 "In Progress"로 변경
./scripts/jira-transition-issue.sh MOA-15 "In Progress"

# 이슈를 "Done"으로 완료 처리
./scripts/jira-transition-issue.sh MOA-15 "Done"

# 다시 "To Do"로 되돌리기
./scripts/jira-transition-issue.sh MOA-15 "To Do"
```

**파라미터:**
- `$1`: 이슈 키 (필수, 예: MOA-15)
- `$2`: 목표 상태 (필수, 예: "In Progress", "Done")

**출력 예시:**
```
🔄 이슈 상태 전환 중...
   이슈: MOA-15
   목표 상태: Done

✅ 상태 전환 완료!
   URL: https://gjrjr4545.atlassian.net/browse/MOA-15
```

---

## 일반적인 워크플로우

### 1️⃣ 새 작업 시작
```bash
# 1. 이슈 생성
./scripts/jira-create-issue.sh "Spring Actuator 통합"

# 2. 출력된 이슈 키(예: MOA-20) 확인
# 3. 작업 시작 시 상태 변경
./scripts/jira-transition-issue.sh MOA-20 "In Progress"
```

### 2️⃣ 진행 중인 작업 확인
```bash
# 내가 진행 중인 이슈 확인
./scripts/jira-list-issues.sh "In Progress"
```

### 3️⃣ 작업 완료
```bash
# 이슈 완료 처리
./scripts/jira-transition-issue.sh MOA-20 "Done"
```

---

## 트러블슈팅

### 권한 오류 발생 시
```bash
chmod +x scripts/*.sh
```

### Python JSON 파싱 오류
```bash
# python3 설치 확인
python3 --version

# macOS의 경우
brew install python3
```

### JIRA 인증 실패
```bash
# .env 파일 확인
cat .env | grep JIRA

# API 연결 테스트
curl -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
  "${JIRA_URL}/rest/api/2/myself"
```

---

## 고급 사용법

### 환경변수 직접 사용
```bash
# .env 로드 후 직접 curl 사용
source .env

curl -X GET \
  -H "Content-Type: application/json" \
  -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
  "${JIRA_URL}/rest/api/2/issue/MOA-15"
```

### 배치 작업
```bash
# 여러 이슈 한번에 생성
for task in "Task A" "Task B" "Task C"; do
  ./scripts/jira-create-issue.sh "$task"
  sleep 1
done
```

---

## 참고 자료

- [JIRA REST API v2 Documentation](https://developer.atlassian.com/cloud/jira/platform/rest/v2/intro/)
- [JQL (JIRA Query Language)](https://www.atlassian.com/software/jira/guides/expand-jira/jql)
- 프로젝트 대시보드: https://gjrjr4545.atlassian.net/jira/software/projects/MOA/
