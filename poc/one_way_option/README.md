# 🎯 BitVM(X) 단방향 옵션 시스템

> **세계에서 가장 작은 비트코인 옵션 계산기 (204바이트, 47 RISC-V 명령어)**
>
> Bitcoin Taproot에서 완전 검증 가능한 금융 파생상품 계산 시스템

## 🌟 **이게 뭔가요?**

**BitVM(X) 단방향 옵션**은 비트코인 블록체인에서 **직접 검증할 수 있는** 옵션 계산 시스템입니다.

### 💡 **핵심 아이디어**

- **📊 옵션 계산**: 현재가격과 행사가격을 비교해 콜옵션 가치를 계산
- **🔐 비트코인 검증**: 모든 계산을 Bitcoin Script로 검증 (47개 RISC-V 명령어)
- **⚡ 초소형**: 단 204바이트로 $3,000 옵션 거래 처리
- **🛡️ 무신뢰**: 중앙화된 서버 없이 순수 블록체인에서 작동

### 🎯 **실제 예시**

```
입력: BTC 현재가 $30,000, 행사가 $1
출력: $29,999 수익 (ITM 콜옵션)
결과: 6,666,666 사토시 정산
```

### 🧩 **BitVM(X) 핵심 개념** (쉬운 설명)

**BitVM(X)** 는 비트코인에서 복잡한 계산을 검증하는 혁신적인 시스템입니다.

### 🤔 **왜 BitVM(X)가 필요한가?**

1. **비트코인의 한계**
   - ⚡ 비트코인은 의도적으로 단순한 계산만 지원
   - 🚫 복잡한 수학 연산 (옵션 계산 등) 불가능
   - 💰 하지만 금융 계산은 정확성이 생명!

2. **BitVM(X)의 해결책**
   - 🖥️ **오프체인 계산**: 복잡한 계산을 외부에서 수행
   - 🔐 **온체인 검증**: 결과만 비트코인에서 검증
   - ⚔️ **챌린지-응답**: 잘못된 계산을 누구나 도전 가능

### 🔄 **작동 원리** (간단히)

```
1. 📊 옵션 계산 (오프체인)
   RISC-V 프로그램으로 옵션 가치 계산
   ↓
2. 🧩 명령어 변환
   각 RISC-V 명령어 → Bitcoin Script 변환
   ↓
3. 🔒 해시 체인 생성
   각 계산 단계의 SHA-256 해시 연결
   ↓
4. ⛓️ 비트코인 커밋
   최종 해시를 P2TR로 블록체인에 기록
   ↓
5. ⚔️ 도전 가능
   누구나 계산 오류를 발견하면 도전 가능
```

### 🎯 **실제 예시**: 우리 옵션 계산

```
입력: 현재가 70,000달러, 행사가 67,000달러
↓ (47개 RISC-V 명령어로 계산)
출력: 콜옵션 가치 = +3,000달러 (ITM)
↓ (각 명령어를 Bitcoin Script로 검증)
결과: 7175baa9616fb26580a72572fb1cfbea9252925f
```

## 🚀 **빠른 시작 (3단계)**

### 1️⃣ **의존성 설치**

```bash
# macOS
brew install riscv-gnu-toolchain

# Ubuntu/Debian
sudo apt-get install gcc-riscv64-unknown-elf

# Rust nightly
rustup install nightly
rustup target add riscv32i-unknown-none-elf
```

### 2️⃣ **원클릭 실행**

```bash
./scripts/bitvmx_option.sh all
```

### 3️⃣ **결과 확인**

````bash
cat results/bitvmx_option_report.md

> **💡 경로 독립성**: 모든 스크립트는 **어느 경로에서 실행해도** 정상 작동합니다!
>
> ```bash
> # 어느 곳에서든 실행 가능
> /path/to/BitVMX-CPU/one_way_option/scripts/quick_start.sh
> cd /tmp && /path/to/scripts/verify.sh    # 다른 디렉토리에서도 작동
> ```

````

### 🚀 **초보자용 간단 스크립트**

새로 추가된 초보자 친화적인 스크립트들을 사용하세요:

#### 빠른 시작

```bash
# 전체 실행 (초보자 추천)
./scripts/quick_start.sh

# 개별 실행
./scripts/quick_start.sh build     # 빌드만
./scripts/quick_start.sh run       # 실행만
./scripts/quick_start.sh test      # 테스트만
./scripts/quick_start.sh demo      # 데모 모드
```

#### 검증 도구

```bash
# 빠른 검증
./scripts/verify.sh

# 상세 검증
./scripts/verify.sh files    # 파일 검증
./scripts/verify.sh tests    # Rust 테스트 검증
```

#### 학습 튜토리얼

```bash
# 빠른 개념 요약
./scripts/tutorial.sh

# 기본 개념 학습
./scripts/tutorial.sh concepts

# 실행 데모
./scripts/tutorial.sh demo
```

## 📋 **상세 사용법**

### 🔧 **개별 명령어**

#### 기본 실행

```bash
# 의존성 확인
./scripts/bitvmx_option.sh deps

# 빌드만
./scripts/bitvmx_option.sh build

# 실행만 (Bitcoin Script 검증 포함)
./scripts/bitvmx_option.sh run

# 테스트만
./scripts/bitvmx_option.sh test

# 비트코인 스크립트 생성
./scripts/bitvmx_option.sh scripts

# 전체 프로세스 (권장)
./scripts/bitvmx_option.sh all
```

#### Rust 테스트

```bash
# 빠른 테스트
cargo test test_bitvmx_one_way_option_basic --release

# 완전 테스트 (Bitcoin Script 검증 포함)
cargo test test_bitvmx_one_way_option_complete --release -- --nocapture
```

### 📊 **입력 파라미터 수정**

옵션 파라미터를 변경하려면 `src/one_way_option.rs` 파일을 수정하세요:

```rust
// 현재 설정 (ITM 콜옵션)
let current_price = 300000;  // $30,000 (센트 단위)
let strike_price = 1;        // $0.01 (극단적 ITM)
let option_type = 1;         // 1=콜, 0=풋
```

## 📊 **결과 해석**

### 💰 **옵션 계산 결과**

```json
{
  "settlement_amount": 6666666, // 정산 금액 (사토시)
  "current_price": 300000, // 현재가 (센트)
  "strike_price": 1, // 행사가 (센트)
  "option_type": 1, // 옵션 유형 (1=콜)
  "profit_usd": 3000.0, // 순손익 (USD)
  "status": "ITM" // In The Money
}
```

### 🔐 **비트코인 검증**

```
✅ Bitcoin Script 검증: 47/47 명령어 (100%)
✅ 해시 체인 무결성: 47단계 확인
✅ 최종 해시: 7175baa9616fb26580a72572fb1cfbea9252925f
```

### 📦 **성능 지표**

```
⚡ 실행 시간: < 0.1초
📦 바이너리 크기: 204바이트
🧮 RISC-V 명령어: 47개
🔗 해시 연산: SHA-256 체인
```

## 📁 **파일 구조**

```
one_way_option/
├── 📋 README.md                    # 이 파일
├── 🦀 Cargo.toml                   # Rust 프로젝트 설정
├── 🔗 linker.ld                    # RISC-V 링커 스크립트
├── ⚙️ Makefile                     # 빌드 설정
│
├── 📁 src/                         # 소스 코드
│   ├── lib.rs                      # 라이브러리 루트
│   ├── one_way_option.rs           # 메인 옵션 계산 로직
│   └── start.S                     # RISC-V 어셈블리 시작 코드
│
├── 📁 scripts/                     # 실행 스크립트
│   └── bitvmx_option.sh           # 메인 실행 스크립트
│
├── 📁 build/                       # 빌드 결과물 (자동 생성)
│   ├── one_way_option.elf         # RISC-V ELF 실행파일
│   ├── one_way_option.bin         # 바이너리 파일
│   └── one_way_option.hex         # HEX 파일
│
├── 📁 results/                     # 실행 결과 (자동 생성)
│   ├── bitvmx_option_report.md    # 최종 리포트
│   ├── execution_trace.log        # 실행 트레이스
│   ├── option_results.json        # 옵션 계산 결과
│   └── hash_chain.txt            # 해시 체인
│
└── 📁 bitcoin_scripts/            # 비트코인 스크립트 (자동 생성)
    ├── p2tr_commit.script         # P2TR 커밋 스크립트
    ├── challenge.script           # 챌린지 스크립트
    └── instruction_mapping.log    # RISC-V 명령어 매핑
```

### 📂 **핵심 파일 역할 상세 설명**

#### 🔧 **빌드 시스템 파일들**

- **`linker.ld`** (링커 스크립트)
  - 📍 **역할**: RISC-V 메모리 레이아웃 정의
  - 🎯 **입력 영역**: `0xA0001000` (4KB) - 옵션 파라미터 저장
  - 💰 **출력 영역**: `0xA0002000` (4KB) - 계산 결과 저장
  - 🏠 **코드 영역**: `0x80000000` (ROM) - 프로그램 코드
  - 📚 **스택 영역**: `0xE0000000` (8MB) - 함수 호출 스택

- **`start.S`** (어셈블리 부트스트랩)
  - 🚀 **역할**: RISC-V 시스템 초기화
  - ⚙️ **기능**: 스택 포인터 설정, main() 호출, 시스템 종료
  - 🛡️ **특징**: BitVM 호환 최소 부트 루틴 (24바이트)

- **`Cargo.toml`** (Rust 프로젝트 설정)
  - 🦀 **역할**: Rust 컴파일 환경 설정
  - 📦 **특징**: `no_std` 환경 (표준 라이브러리 비활성화)
  - 🎯 **타겟**: `riscv32i-unknown-none-elf`
  - ⚡ **최적화**: 크기 우선 (`opt-level = "z"`)

- **`Makefile`** (빌드 자동화)
  - 🔨 **역할**: 크로스 컴파일 체인 관리
  - 🛠️ **도구**: `riscv64-elf-*` 툴체인 사용
  - 📋 **산출물**: ELF → BIN → HEX 변환

#### 💻 **파일 형식별 설명**

- **`.elf`** (Executable and Linkable Format)
  - 🎯 **용도**: RISC-V 에뮬레이터에서 직접 실행
  - 📊 **내용**: 헤더 + 코드 + 심볼 테이블
  - 📏 **크기**: ~1.6KB (헤더 포함)

- **`.bin`** (순수 바이너리)
  - ⚡ **용도**: BitVM에서 검증할 순수 머신 코드
  - 🎯 **크기**: 정확히 204바이트
  - 🔒 **특징**: 헤더 없는 순수 RISC-V 명령어

- **`.hex`** (Intel HEX)
  - 📋 **용도**: 펌웨어 프로그래밍, 디버깅
  - 📊 **형식**: 주소 + 데이터 + 체크섬
  - 🔍 **장점**: 텍스트 형태로 검증 가능

- **`.o`** (오브젝트 파일)
  - 🔗 **용도**: 링킹 전 중간 결과물
  - 📦 **내용**: 컴파일된 어셈블리 코드
  - ⚙️ **특징**: 재배치 가능한 코드

## 🔬 **기술적 세부사항**

### 🏗️ **아키텍처**

1. **RISC-V 32-bit**: 표준 RISC-V ISA로 컴파일
2. **Bitcoin Script**: 각 명령어를 Bitcoin Script로 변환
3. **해시 체인**: SHA-256으로 실행 무결성 보장
4. **P2TR**: Bitcoin Taproot로 온체인 커밋

### 💻 **실행 환경**

- **Target**: `riscv32i-unknown-none-elf`
- **Features**: `no_std`, `panic_immediate_abort`
- **Memory**: 고정 주소 (`0xA0002000`에 출력)
- **Stack**: 8MB 가상 스택

### 🔐 **보안 모델**

- **결정론적**: 동일 입력 → 동일 출력
- **검증 가능**: 모든 단계 Bitcoin Script 검증
- **무신뢰**: 중앙화된 오라클 불필요
- **투명성**: 완전 오픈소스

## 🎯 **사용 사례**

### 💼 **금융 상품**

- **탈중앙화 옵션**: DEX에서 옵션 거래
- **보험 상품**: 스마트 보험 계약
- **헤징**: 위험 관리 도구

### 🏢 **기업 활용**

- **정산 시스템**: 자동 옵션 정산
- **감사**: 투명한 계산 검증
- **규제 준수**: 검증 가능한 거래

### 🎓 **교육/연구**

- **BitVM 학습**: 실제 작동하는 예제
- **RISC-V 연구**: 최소 크기 구현
- **암호화폐 연구**: 새로운 검증 방식

## 🐛 **문제 해결**

### ❌ **빌드 오류**

```bash
# RISC-V 도구체인 확인
riscv64-elf-gcc --version

# Rust target 확인
rustup target list --installed | grep riscv32i
```

### ❌ **실행 오류**

```bash
# 권한 확인
chmod +x scripts/bitvmx_option.sh

# 의존성 재확인
./scripts/bitvmx_option.sh deps
```

### ❌ **테스트 실패**

```bash
# 정리 후 재빌드
cargo clean
./scripts/bitvmx_option.sh build
```

## 🔗 **관련 링크**

- **BitVM**: https://bitvm.org/
- **RISC-V**: https://riscv.org/
- **Bitcoin Taproot**: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
