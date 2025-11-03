#!/bin/bash
# ========================================
# JIRA 이슈 상태 전환 스크립트
# ========================================
# 사용법: ./scripts/jira-transition-issue.sh MOA-123 "Done"
#

set -e

# .env 파일 로드
if [ ! -f .env ]; then
    echo "❌ .env 파일이 없습니다."
    exit 1
fi

source .env

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "❌ 사용법: $0 <이슈키> <상태>"
    echo ""
    echo "예시:"
    echo "  $0 MOA-123 \"In Progress\""
    echo "  $0 MOA-123 \"Done\""
    echo ""
    echo "주요 상태: To Do, In Progress, Done"
    exit 1
fi

ISSUE_KEY="$1"
TARGET_STATUS="$2"

echo "🔄 이슈 상태 전환 중..."
echo "   이슈: $ISSUE_KEY"
echo "   목표 상태: $TARGET_STATUS"
echo ""

# 1. 가능한 전환 목록 조회
TRANSITIONS=$(curl -s -X GET \
  -H "Content-Type: application/json" \
  -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
  "${JIRA_URL}/rest/api/2/issue/${ISSUE_KEY}/transitions")

# 2. 목표 상태에 해당하는 transition ID 찾기
TRANSITION_ID=$(echo "$TRANSITIONS" | python3 -c "
import sys
import json

data = json.load(sys.stdin)
transitions = data.get('transitions', [])
target = '${TARGET_STATUS}'

for t in transitions:
    if t['to']['name'].lower() == target.lower():
        print(t['id'])
        sys.exit(0)

print('ERROR: 상태를 찾을 수 없습니다.', file=sys.stderr)
print('사용 가능한 상태:', file=sys.stderr)
for t in transitions:
    print(f\"  - {t['to']['name']}\", file=sys.stderr)
sys.exit(1)
")

if [ $? -ne 0 ]; then
    exit 1
fi

# 3. 상태 전환 실행
curl -s -X POST \
  -H "Content-Type: application/json" \
  -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
  -d "{\"transition\": {\"id\": \"${TRANSITION_ID}\"}}" \
  "${JIRA_URL}/rest/api/2/issue/${ISSUE_KEY}/transitions"

echo "✅ 상태 전환 완료!"
echo "   URL: ${JIRA_URL}/browse/${ISSUE_KEY}"
