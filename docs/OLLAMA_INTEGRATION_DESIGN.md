# Ollama 통합 설계 - MOAO11y Multi-Agent 확장

## 📋 Overview

**목적**: Ollama 로컬 LLM을 기존 Claude/GPT/Gemini 아키텍처에 통합하여 비용 최적화 및 하이브리드 Agent 구성

**Ollama 환경**:
```bash
# 사용 가능 모델
- llama3 (Meta)
- mistral (Mistral AI)
- phi3 (Microsoft)

# Endpoint
http://192.168.35.245:11434/api/generate
```

---

## 🎯 통합 전략

### 1. 계층화된 모델 선택 전략

```
비용 & 품질 계층:
┌─────────────────────────────────────────────────────┐
│ Tier 1: Premium (클라우드 - 복잡한 작업)              │
│   - Claude Sonnet 4.5: 아키텍처 설계, 복잡한 코드    │
│   - GPT-4o: 리뷰, 최적화                            │
├─────────────────────────────────────────────────────┤
│ Tier 2: Standard (클라우드 - 중간 작업)              │
│   - Gemini 1.5 Pro: 일반 개발                       │
│   - GPT-4o-mini: 테스트 생성                        │
├─────────────────────────────────────────────────────┤
│ Tier 3: Budget (로컬 Ollama - 단순 반복 작업)        │
│   - llama3: 코드 포맷팅, 주석 추가                   │
│   - mistral: 문서 생성, 번역                        │
│   - phi3: 간단한 리팩토링, 이름 변경                 │
└─────────────────────────────────────────────────────┘
```

---

## 🏗️ 아키텍처 설계

### 전체 구조

```
┌──────────────────────────────────────────────────────────┐
│                    ModelRouter                            │
│         (작업 복잡도 & 비용 기반 모델 선택)                │
└────────────┬────────────────────────────┬─────────────────┘
             │                            │
     ┌───────▼──────┐            ┌───────▼──────┐
     │ CloudProvider │            │ OllamaProvider│
     │   Manager     │            │   Manager    │
     └───────┬───────┘            └───────┬──────┘
             │                            │
    ┌────────┼────────┐          ┌────────┼────────┐
    │        │        │          │        │        │
┌───▼──┐ ┌──▼──┐ ┌──▼──┐    ┌──▼───┐ ┌──▼────┐ ┌──▼──┐
│Claude│ │ GPT │ │Gemini│   │llama3│ │mistral│ │ phi3│
└──────┘ └─────┘ └──────┘    └──────┘ └───────┘ └─────┘
```

### 디렉토리 구조 (예상)

```
.claude/scripts/
├── requirements.txt                    # 기존
├── spec_parser.py                      # 기존
├── quality_validator.py                # 기존
├── agent_state.py                      # 기존
│
├── model_selector.py                   # 수정 필요
│   └── + Ollama 모델 정보 추가
│
├── providers/                          # 신규
│   ├── __init__.py
│   ├── base_provider.py               # 추상 클래스
│   ├── anthropic_provider.py          # Claude
│   ├── openai_provider.py             # GPT
│   ├── google_provider.py             # Gemini
│   └── ollama_provider.py             # Ollama (신규)
│
├── ollama/                             # 신규 Ollama 전용
│   ├── __init__.py
│   ├── client.py                      # HTTP 클라이언트
│   ├── models.py                      # 모델 정의
│   └── streaming.py                   # 스트리밍 처리
│
└── orchestra_hybrid.py                 # 신규 (하이브리드)
```

---

## 💻 핵심 컴포넌트 설계

### 1. OllamaProvider (`providers/ollama_provider.py`)

```python
"""
Ollama Provider - 로컬 LLM 통합

특징:
- REST API 기반 통신
- 비용: 0 (로컬)
- 지연시간: 낮음 (로컬 네트워크)
- 품질: 중하 (단순 작업 전용)
"""

from typing import Optional, Dict, List
import requests
from .base_provider import BaseProvider

class OllamaProvider(BaseProvider):
    """Ollama 로컬 LLM Provider"""

    def __init__(
        self,
        base_url: str = "http://192.168.35.245:11434",
        default_model: str = "llama3",
        timeout: int = 30
    ):
        self.base_url = base_url
        self.default_model = default_model
        self.timeout = timeout

        # 모델별 특성
        self.model_specs = {
            'llama3': {
                'strength': ['code_formatting', 'comments', 'simple_refactor'],
                'weakness': ['complex_logic', 'architecture'],
                'speed': 'fast',
                'context_window': 8192
            },
            'mistral': {
                'strength': ['documentation', 'translation', 'summarization'],
                'weakness': ['code_generation', 'debugging'],
                'speed': 'medium',
                'context_window': 32768
            },
            'phi3': {
                'strength': ['variable_naming', 'simple_tasks', 'quick_edits'],
                'weakness': ['complex_code', 'large_context'],
                'speed': 'very_fast',
                'context_window': 4096
            }
        }

    def invoke(
        self,
        prompt: str,
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 2048,
        **kwargs
    ) -> Dict:
        """
        Ollama API 호출

        API Endpoint: POST /api/generate
        """
        model = model or self.default_model

        payload = {
            "model": model,
            "prompt": prompt,
            "stream": False,  # 일단 non-streaming
            "options": {
                "temperature": temperature,
                "num_predict": max_tokens,
            }
        }

        response = requests.post(
            f"{self.base_url}/api/generate",
            json=payload,
            timeout=self.timeout
        )

        if response.status_code != 200:
            raise OllamaAPIError(f"Failed: {response.status_code}")

        result = response.json()

        return {
            'content': result['response'],
            'model': model,
            'done': result['done'],
            'tokens': {
                'input': result.get('prompt_eval_count', 0),
                'output': result.get('eval_count', 0),
                'total': result.get('prompt_eval_count', 0) + result.get('eval_count', 0)
            },
            'cost': 0.0,  # 로컬이므로 비용 없음
            'latency_ms': result.get('total_duration', 0) / 1_000_000
        }

    def stream(self, prompt: str, model: Optional[str] = None, **kwargs):
        """스트리밍 응답 (실시간 출력용)"""
        model = model or self.default_model

        payload = {
            "model": model,
            "prompt": prompt,
            "stream": True,
        }

        with requests.post(
            f"{self.base_url}/api/generate",
            json=payload,
            stream=True,
            timeout=self.timeout
        ) as response:
            for line in response.iter_lines():
                if line:
                    yield json.loads(line)

    def is_available(self) -> bool:
        """Ollama 서버 상태 확인"""
        try:
            response = requests.get(
                f"{self.base_url}/api/tags",
                timeout=2
            )
            return response.status_code == 200
        except:
            return False

    def select_best_model(self, task_type: str) -> str:
        """작업 유형에 따라 최적 모델 선택"""
        task_model_map = {
            'code_formatting': 'llama3',
            'comments': 'llama3',
            'documentation': 'mistral',
            'translation': 'mistral',
            'variable_naming': 'phi3',
            'simple_refactor': 'phi3',
            'summarization': 'mistral',
        }
        return task_model_map.get(task_type, self.default_model)
```

---

### 2. Enhanced ModelSelector (`model_selector.py`)

```python
"""
Enhanced Model Selector - 하이브리드 모델 선택

전략:
1. 작업 복잡도 분석
2. 비용 제약 확인
3. Ollama 우선 (가능한 경우)
4. 품질 요구사항 충족 안되면 클라우드로 폴백
"""

class HybridModelSelector:

    # 확장된 모델 정의
    MODEL_CATALOG = {
        # Cloud Models (기존)
        'claude-sonnet-4-5': {
            'provider': 'anthropic',
            'cost_input': 3.0,
            'cost_output': 15.0,
            'tier': 'premium',
            'quality': 95,
            'latency': 'medium'
        },
        'gpt-4o': {
            'provider': 'openai',
            'cost_input': 2.5,
            'cost_output': 10.0,
            'tier': 'premium',
            'quality': 90,
            'latency': 'medium'
        },
        'gemini-1.5-pro': {
            'provider': 'google',
            'cost_input': 1.25,
            'cost_output': 5.0,
            'tier': 'standard',
            'quality': 85,
            'latency': 'fast'
        },

        # Local Ollama Models (신규)
        'llama3': {
            'provider': 'ollama',
            'cost_input': 0.0,
            'cost_output': 0.0,
            'tier': 'free',
            'quality': 60,  # 단순 작업용
            'latency': 'very_fast'
        },
        'mistral': {
            'provider': 'ollama',
            'cost_input': 0.0,
            'cost_output': 0.0,
            'tier': 'free',
            'quality': 65,
            'latency': 'fast'
        },
        'phi3': {
            'provider': 'ollama',
            'cost_input': 0.0,
            'cost_output': 0.0,
            'tier': 'free',
            'quality': 55,
            'latency': 'ultra_fast'
        }
    }

    def select_model(
        self,
        task_type: str,
        task_complexity: str,
        quality_threshold: int = 70,
        prefer_local: bool = True
    ) -> Dict:
        """
        하이브리드 모델 선택

        로직:
        1. Ollama로 처리 가능? (complexity=simple & quality_threshold 낮음)
           → Ollama 사용 (비용 0)
        2. 복잡도 높거나 품질 요구 높음?
           → 클라우드 모델 사용
        """

        # Simple 작업이면서 Ollama로 충분한 경우
        if task_complexity == 'simple' and prefer_local:
            ollama_model = self._select_ollama_model(task_type)
            if ollama_model and self.ollama_provider.is_available():
                return {
                    'model': ollama_model,
                    'provider': 'ollama',
                    'reason': 'simple_task_local',
                    'cost_estimate': 0.0
                }

        # 품질 요구사항 충족하는 최저 비용 모델
        candidates = [
            (name, spec) for name, spec in self.MODEL_CATALOG.items()
            if spec['quality'] >= quality_threshold
        ]

        # 비용순 정렬
        candidates.sort(key=lambda x: x[1]['cost_input'])

        selected = candidates[0]

        return {
            'model': selected[0],
            'provider': selected[1]['provider'],
            'reason': 'quality_threshold',
            'cost_estimate': self._estimate_cost(selected[0], 1000)
        }

    def _select_ollama_model(self, task_type: str) -> Optional[str]:
        """작업 유형에 따른 Ollama 모델 선택"""
        ollama_tasks = {
            'code_formatting': 'llama3',
            'add_comments': 'llama3',
            'variable_rename': 'phi3',
            'documentation': 'mistral',
            'translation': 'mistral',
            'summarization': 'mistral',
            'simple_refactor': 'phi3',
        }
        return ollama_tasks.get(task_type)
```

---

### 3. LangGraph Hybrid Workflow

```python
"""
orchestra_hybrid.py - Ollama + Cloud 하이브리드 워크플로우

워크플로우:
1. 작업 분석 (Claude) - 복잡도 판정
2. Simple → Ollama, Complex → Cloud
3. Ollama 실패 시 자동 폴백 → Cloud
"""

def create_hybrid_workflow() -> StateGraph:
    workflow = StateGraph(AgentState)

    # 노드 정의
    workflow.add_node("analyze_task", analyze_task_node)        # Claude가 복잡도 분석
    workflow.add_node("generate_ollama", generate_ollama_node)  # Ollama로 생성
    workflow.add_node("generate_cloud", generate_cloud_node)    # Cloud로 생성
    workflow.add_node("validate", validate_code_node)           # spec-kit 검증
    workflow.add_node("review", review_code_node)               # Claude 리뷰
    workflow.add_node("finalize", finalize_node)

    # Entry point
    workflow.set_entry_point("analyze_task")

    # 조건부 라우팅: 복잡도에 따라 Ollama vs Cloud
    workflow.add_conditional_edges(
        "analyze_task",
        route_by_complexity,
        {
            "ollama": "generate_ollama",    # Simple → Ollama
            "cloud": "generate_cloud"        # Complex → Cloud
        }
    )

    # Ollama 실패 시 Cloud로 폴백
    workflow.add_conditional_edges(
        "generate_ollama",
        check_ollama_success,
        {
            "success": "validate",
            "fallback": "generate_cloud"     # 실패 → Cloud
        }
    )

    workflow.add_edge("generate_cloud", "validate")
    workflow.add_edge("validate", "review")
    workflow.add_edge("review", "finalize")
    workflow.add_edge("finalize", END)

    return workflow.compile()


def analyze_task_node(state: AgentState) -> AgentState:
    """
    Claude가 작업 복잡도 분석

    출력:
    - complexity: 'simple' | 'medium' | 'complex'
    - recommended_provider: 'ollama' | 'cloud'
    """
    claude = ChatAnthropic(model="claude-sonnet-4-5")

    prompt = f"""다음 작업의 복잡도를 분석해줘:

작업: {state['original_request']}

분석 기준:
- Simple: 단순 반복, 포맷팅, 주석 추가, 이름 변경
- Medium: 일반 로직, CRUD, 테스트 작성
- Complex: 아키텍처 설계, 복잡한 알고리즘, 최적화

JSON 형식으로 응답:
{{
  "complexity": "simple|medium|complex",
  "reason": "이유",
  "recommended_provider": "ollama|cloud"
}}
"""

    response = claude.invoke(prompt)
    analysis = json.loads(response.content)

    state['task_complexity'] = analysis['complexity']
    state['recommended_provider'] = analysis['recommended_provider']

    return state


def generate_ollama_node(state: AgentState) -> AgentState:
    """Ollama로 코드 생성 (Simple 작업)"""

    # Ollama provider 초기화
    ollama = OllamaProvider()

    # 작업 유형에 따른 모델 선택
    model = ollama.select_best_model(state.get('task_type', 'code_formatting'))

    # 간단한 프롬프트 (Ollama는 복잡한 지시 이해 제한적)
    prompt = f"""Task: {state['original_request']}

Requirements:
- Java code
- Package: com.moao11y.*
- Follow Google Java Style Guide

Generate the code:
"""

    try:
        response = ollama.invoke(prompt, model=model, temperature=0.3)

        state['current_code'] = response['content']
        state['model_used'] = f"ollama/{model}"
        state['cost'] = 0.0
        state['ollama_success'] = True

        print(f"[OLLAMA] Generated with {model} (cost: $0.00)")

    except Exception as e:
        print(f"[OLLAMA] Failed: {e}")
        state['ollama_success'] = False
        state['error'] = str(e)

    return state


def route_by_complexity(state: AgentState) -> str:
    """복잡도에 따른 라우팅"""
    complexity = state.get('task_complexity', 'complex')

    if complexity == 'simple':
        return "ollama"
    else:
        return "cloud"


def check_ollama_success(state: AgentState) -> str:
    """Ollama 성공 여부 확인"""
    if state.get('ollama_success'):
        return "success"
    else:
        print("[WORKFLOW] Ollama failed, falling back to Cloud")
        return "fallback"
```

---

## 📊 작업별 모델 매핑 전략

### 작업 분류 및 모델 할당

```yaml
# Simple Tasks → Ollama (비용 0)
simple_tasks:
  code_formatting:
    model: llama3
    example: "코드 들여쓰기 및 스타일 통일"

  add_comments:
    model: llama3
    example: "메서드에 주석 추가"

  variable_rename:
    model: phi3
    example: "변수명을 camelCase로 변경"

  generate_getter_setter:
    model: phi3
    example: "getter/setter 자동 생성"

  documentation:
    model: mistral
    example: "README 작성, JavaDoc 생성"

  translation:
    model: mistral
    example: "문서 한영 번역"

# Medium Tasks → Gemini / GPT-4o-mini
medium_tasks:
  crud_implementation:
    model: gemini-1.5-pro

  unit_test_generation:
    model: gpt-4o-mini

  simple_refactoring:
    model: gemini-1.5-pro

# Complex Tasks → Claude / GPT-4o
complex_tasks:
  architecture_design:
    model: claude-sonnet-4-5

  complex_algorithm:
    model: claude-sonnet-4-5

  code_review:
    model: claude-sonnet-4-5

  performance_optimization:
    model: gpt-4o
```

---

## 🔄 Failover & Fallback 전략

```
┌─────────────────────────────────────────┐
│         작업 요청                        │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│  복잡도 분석 (Claude)                    │
│  - Simple / Medium / Complex             │
└─────────────┬───────────────────────────┘
              │
        ┌─────┴─────┐
        ▼           ▼
    [Simple]    [Complex]
        │           │
        ▼           ▼
  ┌─────────┐  ┌─────────┐
  │ Ollama  │  │  Cloud  │
  │ (로컬)  │  │ (Claude)│
  └────┬────┘  └─────────┘
       │
       ├──[Success]──► Validation
       │
       └──[Failed]───► Fallback to Cloud
```

### Fallback 조건
1. **Ollama 서버 다운**: 즉시 Cloud로 전환
2. **응답 시간 초과**: 30초 이상 → Cloud
3. **품질 검증 실패**: spec-kit 검증 실패 → Cloud로 재생성
4. **에러 발생**: 3회 재시도 후 Cloud

---

## 💰 비용 최적화 시뮬레이션

### 시나리오 1: Ollama 미사용 (현재)
```
일일 작업 (100개):
- Simple (30개) × Gemini Flash = $0.075 × 30 = $2.25
- Medium (50개) × Gemini Pro = $1.25 × 50 = $62.50
- Complex (20개) × Claude = $3.00 × 20 = $60.00

Total: $124.75/day
월 비용: $3,742.50
```

### 시나리오 2: Ollama 활용 (하이브리드)
```
일일 작업 (100개):
- Simple (30개) × Ollama = $0.00 × 30 = $0.00 ✅
- Medium (50개) × Gemini Pro = $1.25 × 50 = $62.50
- Complex (20개) × Claude = $3.00 × 20 = $60.00

Total: $122.50/day
월 비용: $3,675.00

절감액: $67.50/월 (1.8% 절감)
```

### 시나리오 3: Ollama 적극 활용
```
일일 작업 (100개):
- Simple (30개) × Ollama = $0.00 ✅
- Medium (50개):
  - 30개 × Ollama (단순한 것들) = $0.00 ✅
  - 20개 × Gemini = $25.00
- Complex (20개) × Claude = $60.00

Total: $85.00/day
월 비용: $2,550.00

절감액: $1,192.50/월 (31.8% 절감) 🎯
```

---

## 🚀 구현 로드맵

### Phase 1: Ollama Provider 구현 (1주)
```
1. OllamaProvider 클래스
   - HTTP 클라이언트
   - 모델 관리
   - 에러 핸들링

2. 테스트
   - 연결 테스트
   - 모델별 성능 측정
   - 실패 시나리오 테스트
```

### Phase 2: ModelSelector 확장 (1주)
```
1. HybridModelSelector 구현
   - Ollama 모델 추가
   - 복잡도 기반 선택 로직
   - Fallback 메커니즘

2. 비용 추적
   - Ollama vs Cloud 사용량
   - 절감액 계산
```

### Phase 3: LangGraph 통합 (1주)
```
1. orchestra_hybrid.py
   - analyze_task_node
   - generate_ollama_node
   - Conditional routing

2. 통합 테스트
   - Simple 작업 → Ollama
   - Complex 작업 → Cloud
   - Failover 시나리오
```

### Phase 4: 프로덕션 준비 (1주)
```
1. 모니터링
   - 성공률 추적
   - 응답 시간 측정
   - 비용 절감 리포트

2. 문서화
   - Ollama 설정 가이드
   - 모델 선택 가이드
   - 트러블슈팅
```

---

## ⚠️ 주의사항 및 제약

### Ollama의 한계
1. **품질**: 클라우드 모델보다 낮음
   - 복잡한 로직 생성 부적합
   - 아키텍처 설계 불가능

2. **컨텍스트 윈도우**: 제한적
   - llama3: 8K tokens
   - phi3: 4K tokens (매우 작음)
   - 큰 파일 처리 불가

3. **안정성**: 로컬 서버 의존
   - 서버 다운 시 서비스 중단
   - 네트워크 이슈 영향

### 권장 사용 패턴
```python
# ✅ 좋은 사용 (Simple 작업)
tasks_for_ollama = [
    "Add comments to this method",
    "Format this code to Google Style",
    "Rename variables to camelCase",
    "Generate getter/setter",
    "Write JavaDoc for this class",
]

# ❌ 나쁜 사용 (Complex 작업)
tasks_not_for_ollama = [
    "Design microservice architecture",
    "Optimize this algorithm",
    "Review security vulnerabilities",
    "Refactor entire module",
    "Generate complex business logic",
]
```

---

## 📝 설정 파일 예시

### `.env` 확장
```bash
# Ollama 설정
OLLAMA_BASE_URL=http://192.168.35.245:11434
OLLAMA_DEFAULT_MODEL=llama3
OLLAMA_TIMEOUT=30
OLLAMA_ENABLED=true

# Failover 설정
OLLAMA_FALLBACK_ENABLED=true
OLLAMA_MAX_RETRIES=3

# 비용 최적화
PREFER_LOCAL_MODELS=true
QUALITY_THRESHOLD=70  # 70점 이상 필요하면 Cloud
```

### `requirements.txt` 추가
```python
# 기존 의존성 유지...

# Ollama 통합 (추가 라이브러리 불필요 - requests만 사용)
# requests==2.32.3  # 이미 있음
```

---

## 🎯 결론

### 추천 접근법

**단계별 도입**:
1. ✅ **Phase 1**: Simple 작업만 Ollama (위험 낮음)
2. ✅ **Phase 2**: 성공률 80% 이상이면 Medium 일부도 Ollama
3. ⚠️ **Phase 3**: Complex는 항상 Cloud (품질 보장)

**핵심 원칙**:
```
"Ollama First, Cloud Fallback"

1. 모든 작업을 일단 Ollama로 시도
2. 실패 시 자동으로 Cloud로 폴백
3. 비용 0으로 최대한 처리
4. 품질 요구사항은 절대 타협 안함
```

### 기대 효과
- 💰 비용: 20-30% 절감
- 🚀 속도: Simple 작업 2-3배 빠름 (로컬)
- 🔒 보안: 민감 정보 로컬 처리
- 📈 확장성: 로컬 GPU 추가로 무한 확장

---

**설계 작성일**: 2025-11-05
**실제 구현 시작**: Sprint 2 이후 권장
**예상 구현 기간**: 4주
