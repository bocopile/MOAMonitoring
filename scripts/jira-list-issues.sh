#!/bin/bash
# ========================================
# JIRA 이슈 목록 조회 스크립트
# ========================================
# 사용법: ./scripts/jira-list-issues.sh [상태]
#

set -e

# .env 파일 로드
if [ ! -f .env ]; then
    echo "❌ .env 파일이 없습니다."
    exit 1
fi

source .env

STATUS="${1:-}"

echo "📋 JIRA 이슈 조회 중..."
echo "   프로젝트: $JIRA_PROJECT_KEY"
[ -n "$STATUS" ] && echo "   상태: $STATUS"
echo ""

# JQL 쿼리 구성
if [ -n "$STATUS" ]; then
    JQL="project=${JIRA_PROJECT_KEY} AND status='${STATUS}' ORDER BY created DESC"
else
    JQL="project=${JIRA_PROJECT_KEY} ORDER BY created DESC"
fi

# JIRA API 호출
RESPONSE=$(curl -s -X GET \
  -H "Content-Type: application/json" \
  -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
  --data-urlencode "jql=${JQL}" \
  --data-urlencode "maxResults=20" \
  --data-urlencode "fields=summary,status,assignee,created" \
  "${JIRA_URL}/rest/api/2/search")

# 결과 파싱 및 출력
echo "$RESPONSE" | python3 -c "
import sys
import json

data = json.load(sys.stdin)
issues = data.get('issues', [])

if not issues:
    print('📭 이슈가 없습니다.')
    sys.exit(0)

print(f\"총 {data.get('total', 0)}개 이슈 (최근 {len(issues)}개 표시)\")
print('─' * 80)

for issue in issues:
    key = issue['key']
    summary = issue['fields']['summary']
    status = issue['fields']['status']['name']
    assignee = issue['fields'].get('assignee')
    assignee_name = assignee['displayName'] if assignee else 'Unassigned'

    print(f\"🎫 {key}: {summary}\")
    print(f\"   상태: {status} | 담당자: {assignee_name}\")
    print(f\"   URL: ${JIRA_URL}/browse/{key}\")
    print()
"
