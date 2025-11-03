#!/bin/bash
# ========================================
# JIRA 이슈 생성 스크립트
# ========================================
# 사용법: ./scripts/jira-create-issue.sh "이슈 제목" "이슈 설명" "Task|Story|Bug"
#

set -e

# .env 파일 로드
if [ ! -f .env ]; then
    echo "❌ .env 파일이 없습니다. .env.sample을 복사하여 .env를 생성하세요."
    echo "   cp .env.sample .env"
    exit 1
fi

source .env

# 파라미터 확인
if [ -z "$1" ]; then
    echo "❌ 사용법: $0 \"이슈 제목\" [\"이슈 설명\"] [이슈타입]"
    echo ""
    echo "예시:"
    echo "  $0 \"MOAAgent 메트릭 수집 구현\""
    echo "  $0 \"RabbitMQ 연동\" \"메트릭 데이터 전송을 위한 RabbitMQ 통합\""
    echo "  $0 \"버그 수정\" \"Actuator endpoint 오류\" \"Bug\""
    exit 1
fi

SUMMARY="$1"
DESCRIPTION="${2:-No description provided}"
ISSUE_TYPE="${3:-Task}"

# JIRA 환경변수 확인
if [ -z "$JIRA_URL" ] || [ -z "$JIRA_USER" ] || [ -z "$JIRA_API_TOKEN" ]; then
    echo "❌ JIRA 환경변수가 설정되지 않았습니다."
    echo "   .env 파일에서 JIRA_URL, JIRA_USER, JIRA_API_TOKEN을 확인하세요."
    exit 1
fi

echo "📝 JIRA 이슈 생성 중..."
echo "   프로젝트: $JIRA_PROJECT_KEY"
echo "   제목: $SUMMARY"
echo "   타입: $ISSUE_TYPE"
echo ""

# JIRA API 호출
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
  -d "{
    \"fields\": {
      \"project\": {\"key\": \"${JIRA_PROJECT_KEY}\"},
      \"summary\": \"${SUMMARY}\",
      \"description\": \"${DESCRIPTION}\",
      \"issuetype\": {\"name\": \"${ISSUE_TYPE}\"}
    }
  }" \
  "${JIRA_URL}/rest/api/2/issue")

# HTTP 상태 코드 추출
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 201 ]; then
    ISSUE_KEY=$(echo "$BODY" | grep -o '"key":"[^"]*"' | cut -d'"' -f4)
    echo "✅ 이슈 생성 완료!"
    echo "   이슈 키: $ISSUE_KEY"
    echo "   URL: ${JIRA_URL}/browse/${ISSUE_KEY}"
else
    echo "❌ 이슈 생성 실패 (HTTP $HTTP_CODE)"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
    exit 1
fi
