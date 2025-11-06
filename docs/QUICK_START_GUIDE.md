# 🚀 Orchestra 빠른 시작 가이드

> **목적**: Day 1을 30분 안에 시작할 수 있도록 실용적인 가이드 제공

**예상 시간**: 30분
**난이도**: 쉬움

---

## ⚡ 5분 체크리스트 (시작 전)

```bash
# 1. Python 버전 확인 (3.9+)
python --version  # 또는 python3 --version

# 2. Git 상태 확인
cd /Users/okestro/IdeaProjects/MOAO11y
git status

# 3. Ollama 서버 확인
curl http://192.168.35.245:11434/api/tags

# 4. 가상환경 존재 확인
ls .claude/scripts/venv  # 있으면 OK, 없으면 생성 필요

# 5. .env 파일 확인
cat .claude/scripts/.env | grep ANTHROPIC_API_KEY
```

**모두 OK?** → 다음 단계로!
**문제 있음?** → 아래 "문제 해결" 섹션 참조

---

## 📦 Step 1: 환경 설정 (10분)

### 1.1 가상환경 생성 및 활성화

```bash
# 프로젝트 루트로 이동
cd /Users/okestro/IdeaProjects/MOAO11y

# 가상환경 생성 (없는 경우)
cd .claude/scripts
python3 -m venv venv

# 가상환경 활성화
source venv/bin/activate  # macOS/Linux
# Windows: venv\Scripts\activate

# 확인: 프롬프트에 (venv) 표시되어야 함
```

### 1.2 의존성 설치

```bash
# 최신 requirements.txt 확인
cat requirements.txt

# 설치
pip install --upgrade pip
pip install -r requirements.txt

# 설치 확인
pip list | grep langgraph
pip list | grep langchain
```

**예상 출력**:
```
langgraph                 0.2.34
langchain                 0.3.7
langchain-anthropic       0.2.4
langchain-core            0.3.17
...
```

### 1.3 환경 변수 설정

```bash
# .env 파일 확인
ls .env

# 없으면 생성
cat > .env << 'EOF'
# Anthropic (Claude)
ANTHROPIC_API_KEY=sk-ant-...

# Ollama
OLLAMA_BASE_URL=http://192.168.35.245:11434

# JIRA (Optional)
JIRA_EMAIL=your@email.com
JIRA_API_TOKEN=your-token

# Slack (Optional - Week 3부터 필요)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
EOF

# .env 편집
vim .env  # 또는 code .env
```

**필수 항목**:
- `ANTHROPIC_API_KEY`: Claude API 키
- `OLLAMA_BASE_URL`: Ollama 서버 URL

**선택 항목** (나중에 설정 가능):
- JIRA 관련 (Week 3)
- Slack 관련 (Week 3)

### 1.4 Ollama 연결 테스트

```bash
# 서버 연결 확인
curl http://192.168.35.245:11434/api/tags

# 5개 모델 확인
curl http://192.168.35.245:11434/api/tags | jq '.models[].name'
```

**예상 출력**:
```
"llama3:8b"
"qwen2.5-coder:7b"
"codellama:7b"
"mistral:7b"
"phi3:mini"
```

---

## 🗂️ Step 2: 프로젝트 구조 생성 (5분)

### 2.1 Week 1 디렉토리 생성

```bash
# 루트로 이동
cd /Users/okestro/IdeaProjects/MOAO11y

# Week 1 디렉토리 생성
mkdir -p .claude/scripts/section_leaders
mkdir -p .claude/scripts/chains
mkdir -p tests/section_leaders
mkdir -p docs

# __init__.py 파일 생성
touch .claude/scripts/section_leaders/__init__.py
touch .claude/scripts/chains/__init__.py
touch tests/section_leaders/__init__.py

# 확인
tree .claude/scripts/section_leaders
tree tests/section_leaders
```

### 2.2 템플릿 파일 생성 (옵션)

```bash
# base_section_leader.py 템플릿
cat > .claude/scripts/section_leaders/base_section_leader.py << 'EOF'
"""
Base Section Leader

역할: 모든 Section Leader의 추상 클래스
"""

from abc import ABC, abstractmethod
from typing import Dict, List, Any

class BaseSectionLeader(ABC):
    """Section Leader 추상 클래스"""

    def __init__(self, name: str):
        self.name = name
        self.performers = {}
        self.chains = {}

    @abstractmethod
    def build_chains(self):
        """섹션별 체인 구성"""
        pass

    @abstractmethod
    def perform(self, task: Dict[str, Any]) -> Dict[str, Any]:
        """섹션 전체 연주 실행"""
        pass

    @abstractmethod
    def is_ready(self) -> bool:
        """섹션 준비 완료 여부"""
        pass

    def get_section_status(self) -> Dict:
        """섹션 상태 반환"""
        return {
            'name': self.name,
            'performers': list(self.performers.keys()),
            'chains': list(self.chains.keys()),
            'ready': self.is_ready()
        }

# TODO: Day 1-2에 구현 완료
EOF
```

---

## 📚 Step 3: 기존 코드 리뷰 (10분)

### 3.1 필수 파일 읽기

```bash
# 1. Agent State 이해
cat .claude/scripts/agent_state.py | head -50

# 2. 기존 Orchestra MVP 이해
cat .claude/scripts/orchestra_mvp.py | head -100

# 3. Model Selector 이해
cat .claude/scripts/model_selector.py | head -50
```

### 3.2 핵심 개념 이해

#### AgentState
```python
class AgentState(TypedDict):
    """Orchestra Agent들의 공유 상태"""
    original_request: str      # 사용자 요청
    jira_ticket: str          # JIRA 티켓
    current_code: str         # 현재 생성된 코드
    stage: str                # 현재 단계
    retry_count: int          # 재시도 횟수
    messages: List[Dict]      # 메시지 히스토리
    ...
```

#### Orchestra 기본 흐름
```python
# 1. 노드 정의
workflow.add_node("generate", generate_code_node)
workflow.add_node("validate", validate_node)
workflow.add_node("review", review_node)

# 2. 엣지 연결
workflow.set_entry_point("generate")
workflow.add_edge("generate", "validate")
workflow.add_edge("validate", "review")

# 3. 컴파일 및 실행
app = workflow.compile()
result = app.invoke(initial_state)
```

### 3.3 LangChain 문서 빠른 참조

핵심 개념만:
- `RunnableSequence`: A → B → C 순차 실행
- `RunnableParallel`: A || B || C 병렬 실행
- `ChatPromptTemplate`: 프롬프트 템플릿
- `StrOutputParser`: 문자열 출력 파싱

---

## ✍️ Step 4: Day 1 작업 시작 (5분)

### 4.1 IDE 열기

```bash
# VSCode 사용자
cd /Users/okestro/IdeaProjects/MOAO11y
code .

# IntelliJ/PyCharm 사용자
# IDE에서 프로젝트 열기
```

### 4.2 Day 1 파일 열기

```
.claude/scripts/section_leaders/base_section_leader.py
```

### 4.3 구현 시작

Day 1 Morning (오전 4시간) 작업:
1. ✅ 환경 설정 (완료)
2. ✅ 프로젝트 구조 (완료)
3. ✅ 기존 코드 리뷰 (완료)
4. ⬜ `base_section_leader.py` 구현 시작

**이제 `ORCHESTRA_4WEEK_ROADMAP.md`의 Day 1 체크리스트를 따라 진행하세요!**

---

## 🧪 Step 5: 첫 테스트 실행 (선택)

### 5.1 기존 테스트 실행

```bash
# 가상환경 활성화 확인
cd .claude/scripts
source venv/bin/activate

# 기존 테스트 실행
cd ../..
python -m pytest tests/ -v

# 예상: 일부 테스트 통과, 일부 skip
```

### 5.2 Ollama 간단 테스트

```python
# test_ollama_quick.py
from langchain_ollama import ChatOllama

def test_ollama_connection():
    """Ollama 연결 빠른 테스트"""
    llama3 = ChatOllama(
        model="llama3:8b",
        base_url="http://192.168.35.245:11434"
    )

    response = llama3.invoke("Say hello in one word")
    print(f"Ollama response: {response.content}")
    assert len(response.content) > 0

if __name__ == "__main__":
    test_ollama_connection()
    print("✓ Ollama connection OK")
```

```bash
# 실행
python test_ollama_quick.py
```

---

## 🎯 Step 6: Day 1 목표 확인

### Day 1 완료 기준
- [ ] 환경 설정 완료
- [ ] 프로젝트 구조 생성
- [ ] 기존 코드 리뷰 완료
- [ ] `base_section_leader.py` 50줄 이상 작성
- [ ] 추상 메서드 4개 정의
- [ ] 기본 테스트 1개 작성

### 오늘의 핵심 산출물
```
.claude/scripts/section_leaders/base_section_leader.py (100줄 목표)
├── BaseSectionLeader 클래스
├── __init__ 메서드
├── build_chains() 추상 메서드
├── perform() 추상 메서드
├── is_ready() 추상 메서드
├── harmonize() 메서드
└── get_section_status() 메서드

tests/section_leaders/test_base_section_leader.py (50줄 목표)
├── 기본 구조 테스트
└── 추상 메서드 테스트
```

---

## ❓ 문제 해결 (Troubleshooting)

### Q1: Python 버전이 낮음 (< 3.9)
```bash
# pyenv 설치 (macOS)
brew install pyenv

# Python 3.11 설치
pyenv install 3.11.0
pyenv global 3.11.0

# 확인
python --version
```

### Q2: pip install 실패
```bash
# pip 업그레이드
pip install --upgrade pip

# 개별 설치 시도
pip install langgraph
pip install langchain
pip install langchain-anthropic

# 캐시 삭제 후 재시도
pip cache purge
pip install -r requirements.txt
```

### Q3: Ollama 서버 연결 안됨
```bash
# 서버 상태 확인
curl http://192.168.35.245:11434/api/tags

# 실패 시 대체 URL 시도
export OLLAMA_BASE_URL=http://localhost:11434
curl $OLLAMA_BASE_URL/api/tags

# 로컬에서 Ollama 실행 (옵션)
ollama serve
```

### Q4: ANTHROPIC_API_KEY 없음
```bash
# API 키 발급
# 1. https://console.anthropic.com/ 접속
# 2. API Keys → Create Key
# 3. 키 복사

# .env에 추가
echo "ANTHROPIC_API_KEY=sk-ant-your-key-here" >> .claude/scripts/.env
```

### Q5: Import 에러
```bash
# PYTHONPATH 설정
export PYTHONPATH=/Users/okestro/IdeaProjects/MOAO11y:$PYTHONPATH

# 또는 개발 모드로 설치
cd /Users/okestro/IdeaProjects/MOAO11y
pip install -e .
```

### Q6: pytest 실행 안됨
```bash
# pytest 설치
pip install pytest pytest-cov

# 설치 확인
pytest --version
```

---

## 📖 추가 참고 자료

### 프로젝트 문서
- `ORCHESTRA_4WEEK_ROADMAP.md`: 전체 로드맵
- `WEEK_BY_WEEK_CHECKLIST.md`: 일일 체크리스트
- `VALIDATION_CRITERIA.md`: 검증 기준

### 외부 문서
- [LangChain 공식 문서](https://python.langchain.com/docs/get_started/introduction)
- [LangGraph 공식 문서](https://langchain-ai.github.io/langgraph/)
- [Ollama API](https://github.com/ollama/ollama/blob/main/docs/api.md)

### 예제 코드
- `.claude/scripts/orchestra_mvp.py`: 기본 워크플로우
- `.claude/scripts/agent_state.py`: State 관리

---

## 🎊 준비 완료!

모든 단계를 완료했다면:

```
✅ 환경 설정 완료
✅ 프로젝트 구조 생성
✅ 기존 코드 이해
✅ Day 1 작업 준비 완료

이제 본격적으로 시작하세요!
```

### 다음 단계

1. **오늘 (Day 1 오후)**
   - `base_section_leader.py` 완성
   - 테스트 작성 시작

2. **내일 (Day 2)**
   - 테스트 완성
   - 문서 작성
   - Day 1-2 회고

3. **이번 주 (Week 1)**
   - Backend Section Leader 구현 (Day 3-4)
   - QA Section Leader 구현 (Day 5)
   - Docs Section Leader 구현 (Day 6)
   - 통합 및 검증 (Day 7)

**화이팅! 🚀**

---

## 💡 Tip: 매일 시작할 때

```bash
# 하루 시작 루틴 (5분)
cd /Users/okestro/IdeaProjects/MOAO11y/.claude/scripts
source venv/bin/activate
git status
git pull

# 오늘의 체크리스트 확인
cat ../../docs/WEEK_BY_WEEK_CHECKLIST.md | grep "Day X"

# 작업 시작!
```

---

**마지막 업데이트**: 2025-01-06
**버전**: 1.0.0
**예상 소요**: 30분

🚀 Let's start the journey!
