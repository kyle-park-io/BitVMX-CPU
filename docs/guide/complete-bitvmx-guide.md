# 🎯 BitVMX 완전 구현 가이드

> **세상에서 가장 작은 비트코인 검증 가능한 계산 시스템 구축하기**
>
> 함수 구현부터 Bitcoin Script 챌린지까지 완전한 워크플로우

## 📋 **목차**

1. [개발 환경 설정](#1-개발-환경-설정)
2. [함수 구현](#2-함수-구현)
3. [컴파일 설정](#3-컴파일-설정)
4. [빌드 시스템](#4-빌드-시스템)
5. [에뮬레이터 실행](#5-에뮬레이터-실행)
6. [프로그램 정의 설정](#6-프로그램-정의-설정)
7. [챌린지 시스템 실행](#7-챌린지-시스템-실행)
8. [Bitcoin Script 검증](#8-bitcoin-script-검증)
9. [최종 결과](#9-최종-결과)

---

## **1. 개발 환경 설정**

### 1.1 필수 도구 설치 (macOS)

```bash
# RISC-V 크로스 컴파일러 설치
brew install riscv64-elf-gcc
brew install riscv64-elf-binutils

# 설치 확인
riscv64-elf-gcc --version
# 출력: riscv64-elf-gcc (GCC) 15.1.0

# Rust nightly 및 RISC-V 타겟 설치
rustup install nightly
rustup target add riscv32i-unknown-none-elf
rustup target add riscv32im-unknown-none-elf

# 설치 확인
rustup target list --installed | grep riscv
# 출력:
# riscv32i-unknown-none-elf
# riscv32im-unknown-none-elf
```

### 1.2 프로젝트 구조 생성

```bash
# 새 프로젝트 생성
mkdir my_bitvmx_function
cd my_bitvmx_function

# 기본 구조 생성
mkdir -p src scripts build results bitcoin_scripts
```

---

## **2. 함수 구현**

### 2.1 메인 함수 파일 생성 (`src/my_function.rs`)

```rust
#![no_std]
#![no_main]

// 메모리 주소 정의
const OUTPUT_ADDRESS: u32 = 0xA0002000;
const INPUT_ADDRESS: u32 = 0xA0001000;

// 계산 결과 구조체
#[repr(C)]
struct CalculationResult {
    result_value: u32,      // 계산 결과
    input_hash: u32,        // 입력 해시
    status_code: u32,       // 상태 코드 (0=성공)
    checksum: u32,          // 체크섬
}

// 패닉 핸들러 (필수)
#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    unsafe {
        // 패닉 시 안전하게 종료
        core::arch::asm!(
            "li a7, 93",    // SYS_EXIT
            "li a0, 1",     // exit code 1
            "ecall",
            options(noreturn)
        );
    }
}

// 안전한 종료 함수
#[inline(always)]
unsafe fn exit(code: u32) -> ! {
    core::arch::asm!(
        "li a7, 93",        // SYS_EXIT
        "mv a0, {0}",       // exit code
        "ecall",
        in(reg) code,
        options(noreturn)
    );
}

// 🎯 핵심 계산 함수 (여기에 원하는 로직 구현)
fn my_core_calculation(input_a: u32, input_b: u32) -> u32 {
    // 예시: 간단한 수학 계산
    let result = input_a.wrapping_mul(input_b).wrapping_add(42);

    // 추가 검증 로직
    if input_a > 1000000 {
        result.wrapping_div(2)
    } else {
        result
    }
}

// 입력 데이터 읽기
unsafe fn read_input_data() -> (u32, u32) {
    let input_ptr = INPUT_ADDRESS as *const u32;
    let input_a = core::ptr::read_volatile(input_ptr);
    let input_b = core::ptr::read_volatile(input_ptr.add(1));
    (input_a, input_b)
}

// 결과를 메모리에 저장
unsafe fn save_result_to_memory(result: &CalculationResult) {
    let output_ptr = OUTPUT_ADDRESS as *mut u32;

    core::ptr::write_volatile(output_ptr.add(0), result.result_value);
    core::ptr::write_volatile(output_ptr.add(1), result.input_hash);
    core::ptr::write_volatile(output_ptr.add(2), result.status_code);
    core::ptr::write_volatile(output_ptr.add(3), result.checksum);

    // 매직 넘버로 완료 표시
    core::ptr::write_volatile(output_ptr.add(4), 0xDEADBEEF);
}

// 메인 계산 로직
fn main_calculation() -> CalculationResult {
    let (input_a, input_b) = unsafe { read_input_data() };

    // 핵심 계산 수행
    let result_value = my_core_calculation(input_a, input_b);

    // 입력 해시 계산 (간단한 예시)
    let input_hash = input_a.wrapping_add(input_b).wrapping_mul(0x9e3779b9);

    // 체크섬 계산
    let checksum = result_value.wrapping_add(input_hash).wrapping_add(0x12345678);

    CalculationResult {
        result_value,
        input_hash,
        status_code: 0, // 성공
        checksum,
    }
}

// 프로그램 엔트리 포인트
#[no_mangle]
pub extern "C" fn main() -> i32 {
    unsafe {
        // 계산 실행
        let result = main_calculation();

        // 결과 저장
        save_result_to_memory(&result);

        // 정상 종료
        exit(0);
    }
}
```

### 2.2 라이브러리 루트 파일 (`src/lib.rs`)

```rust
#![no_std]

pub mod my_function;
```

### 2.3 어셈블리 부트스트랩 (`src/start.S`)

```assembly
.section .text.init
.globl _start

_start:
    # 스택 포인터 설정
    lui sp, %hi(0xE0800000)
    addi sp, sp, %lo(0xE0800000)

    # main 함수 호출
    jal ra, main

    # 시스템 종료
    li a7, 93
    mv a0, zero
    ecall

.size _start, .-_start
```

---

## **3. 컴파일 설정**

### 3.1 Cargo.toml 생성

```toml
[package]
name = "my_bitvmx_function"
version = "0.1.0"
edition = "2021"

[[bin]]
name = "my_function"
path = "src/my_function.rs"

[lib]
name = "my_bitvmx_function"
path = "src/lib.rs"

[profile.release]
opt-level = "z"          # 크기 최적화
lto = true              # Link Time Optimization
codegen-units = 1       # 단일 코드 생성 유닛
panic = "abort"         # 패닉 시 즉시 종료
strip = true            # 심볼 제거

[dependencies]
# no_std 환경에서는 의존성 최소화
```

### 3.2 링커 스크립트 (`linker.ld`)

```ld
ENTRY(_start)

MEMORY
{
    ROM (rx)    : ORIGIN = 0x80000000, LENGTH = 64K     /* 코드 영역 */
    RAM (rw)    : ORIGIN = 0xA0000000, LENGTH = 256K    /* 데이터 영역 */
    INDATA (rw) : ORIGIN = 0xA0001000, LENGTH = 4K      /* 입력 데이터 */
    OUTDATA (rw): ORIGIN = 0xA0002000, LENGTH = 4K      /* 출력 데이터 */
    STACK (rw)  : ORIGIN = 0xE0000000, LENGTH = 8M      /* 스택 영역 */
    REGS (rw)   : ORIGIN = 0xF0000000, LENGTH = 128     /* 레지스터 */
}

SECTIONS
{
    .text.init : {
        *(.text.init)
    } > ROM

    .text : {
        *(.text*)
    } > ROM

    .rodata : {
        *(.rodata*)
    } > ROM

    .data : {
        *(.data*)
    } > RAM

    .bss : {
        *(.bss*)
    } > RAM

    .input : {
        . = ORIGIN(INDATA);
        . += LENGTH(INDATA);
    } > INDATA

    .output : {
        . = ORIGIN(OUTDATA);
        . += LENGTH(OUTDATA);
    } > OUTDATA

    .stack : {
        . = ORIGIN(STACK);
        . += LENGTH(STACK);
    } > STACK
}
```

---

## **4. 빌드 시스템**

### 4.1 Makefile 생성

```makefile
# 🎯 BitVMX 함수 빌드 시스템

# 컴파일러 설정
RISCV_PREFIX = riscv64-elf-
CC = $(RISCV_PREFIX)gcc
AS = $(RISCV_PREFIX)as
LD = $(RISCV_PREFIX)ld
OBJCOPY = $(RISCV_PREFIX)objcopy
SIZE = $(RISCV_PREFIX)size
READELF = $(RISCV_PREFIX)readelf

# 컴파일 플래그
ARCH_FLAGS = -march=rv32im -mabi=ilp32
CFLAGS = $(ARCH_FLAGS) -g
LDFLAGS = -m elf32lriscv -T linker.ld --nmagic --gc-sections

# 파일 정의
TARGET_NAME = my_function
BUILD_DIR = build
SRC_DIR = src

# 최종 파일들
ELF_FILE = $(BUILD_DIR)/$(TARGET_NAME).elf
BIN_FILE = $(BUILD_DIR)/$(TARGET_NAME).bin
HEX_FILE = $(BUILD_DIR)/$(TARGET_NAME).hex
MAP_FILE = $(BUILD_DIR)/$(TARGET_NAME).map

# 기본 타겟
all: $(ELF_FILE) $(BIN_FILE) $(HEX_FILE) size info

# 디렉토리 생성
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Rust 컴파일
rust-compile:
	@echo "🦀 Rust 코드 컴파일 중..."
	rustup override set nightly
	cargo +nightly rustc --release --bin $(TARGET_NAME) \
		-Z build-std=core,compiler_builtins \
		-Z build-std-features=panic_immediate_abort \
		-- --emit=obj

# 어셈블리 컴파일
$(BUILD_DIR)/start.o: $(SRC_DIR)/start.S | $(BUILD_DIR)
	@echo "⚙️ 어셈블리 시작 코드 컴파일 중..."
	$(AS) $(ARCH_FLAGS) -g -o $@ $<

# ELF 링킹
$(ELF_FILE): rust-compile $(BUILD_DIR)/start.o | $(BUILD_DIR)
	@echo "🔗 ELF 파일 생성 중..."
	$(LD) $(LDFLAGS) -Map=$(MAP_FILE) --print-memory-usage \
		-o $@ \
		$(BUILD_DIR)/start.o \
		target/riscv32i-unknown-none-elf/release/deps/$(TARGET_NAME)-*.o
	@echo "✅ ELF 파일 생성 완료: $@"

# 바이너리 생성
$(BIN_FILE): $(ELF_FILE)
	@echo "📦 바이너리 파일 생성 중..."
	$(OBJCOPY) -O binary $< $@
	@echo "✅ 바이너리 파일 생성 완료: $@"

# HEX 파일 생성
$(HEX_FILE): $(ELF_FILE)
	@echo "📋 HEX 파일 생성 중..."
	$(OBJCOPY) -O ihex $< $@
	@echo "✅ HEX 파일 생성 완료: $@"

# 크기 정보
size: $(ELF_FILE)
	@echo ""
	@echo "📊 파일 크기 정보:"
	$(SIZE) $<

# 상세 정보
info: $(ELF_FILE)
	@echo ""
	@echo "🔍 섹션 정보:"
	$(READELF) -S $< | head -20
	@echo ""
	@echo "📄 생성된 파일들:"
	ls -la $(BUILD_DIR)/

# 정리
clean:
	@echo "🧹 정리 중..."
	rm -rf $(BUILD_DIR)
	rm -rf target
	cargo clean
	@echo "✅ 정리 완료"

.PHONY: all rust-compile size info clean
```

### 4.2 빌드 실행

```bash
# 전체 빌드
make all

# 개별 작업
make clean          # 정리
make rust-compile   # Rust만 컴파일
make size          # 크기 정보
make info          # 상세 정보
```

---

## **5. 에뮬레이터 실행**

### 5.1 기본 실행 테스트

```bash
# BitVMX-CPU 루트로 이동
cd /path/to/BitVMX-CPU

# 기본 실행 (디버그 모드)
cargo run --release -p emulator execute \
    --elf "my_bitvmx_function/build/my_function.elf" \
    --debug \
    --input "0000007B0000007B"  # 예시: 123, 123

# 트레이스 모드 (해시 체인 생성)
cargo run --release -p emulator execute \
    --elf "my_bitvmx_function/build/my_function.elf" \
    --trace \
    --input "0000007B0000007B"

# Bitcoin Script 검증 포함
cargo run --release -p emulator execute \
    --elf "my_bitvmx_function/build/my_function.elf" \
    --verify \
    --trace \
    --input "0000007B0000007B"
```

---

## **6. 프로그램 정의 설정**

### 6.1 YAML 설정 파일 생성 (`my_function.yaml`)

```yaml
# 🎯 BitVMX 함수 프로그램 정의
# 챌린지 과정을 위한 설정 파일

# ELF 파일 경로
elf: 'build/my_function.elf'

# N-ary search 설정 (이진 탐색)
nary_search: 2

# 최대 실행 스텝 (예상 스텝 + 여유분)
max_steps: 128

# 입력 섹션 이름
input_section_name: '.input'

# 출력 섹션 이름
output_section_name: '.output'

# 입력 데이터 정의
inputs:
  # 증명자(Prover) 입력
  - size: 4096
    owner: 'prover'
    description: '함수 입력 파라미터'

  # 검증자(Verifier) 입력
  - size: 4096
    owner: 'verifier'
    description: '검증용 데이터'

# 출력 데이터 정의
outputs:
  - size: 4096
    address: 0xA0002000
    description: '함수 계산 결과'

# 메모리 레이아웃
memory_layout:
  rom:
    start: 0x80000000
    size: 0x10000
    description: '프로그램 코드'

  ram:
    start: 0xA0000000
    size: 0x40000
    description: '데이터 영역'

  input:
    start: 0xA0001000
    size: 0x1000
    description: '입력 데이터'

  output:
    start: 0xA0002000
    size: 0x1000
    description: '출력 데이터'

  stack:
    start: 0xE0000000
    size: 0x800000
    description: '스택'

  registers:
    start: 0xF0000000
    size: 0x80
    description: '레지스터'

# 챌린지 설정
challenge:
  timeout_rounds: 10
  timeout_per_round: 3600
  verify_all_steps: true
  verify_bitcoin_script: true
  verify_hash_chain: true
  bond_amount: 1000000
  reward_ratio: 0.5

# 메타데이터
metadata:
  name: 'My BitVMX Function'
  version: '1.0.0'
  description: 'BitVMX에서 검증 가능한 사용자 정의 함수'
  author: 'Your Name'

  # 예상 결과
  test_case:
    input_a: 123
    input_b: 123
    expected_result: 15171 # 123 * 123 + 42
```

---

## **7. 챌린지 시스템 실행**

### 7.1 프로버(Prover) 실행

```bash
# 체크포인트 디렉토리 생성
mkdir -p checkpoints

# 프로버 실행 (클레임 생성)
cargo run --release -p emulator -- prover-execute \
    --pdf "my_bitvmx_function/my_function.yaml" \
    --input "0000007B0000007B" \
    --checkpoint-prover-path "./checkpoints" \
    --command-file "./checkpoints/prover_command.txt"
```

### 7.2 검증자(Verifier) 실행

```bash
# 검증자가 프로버 클레임 검증
cargo run --release -p emulator -- verifier-check-execution \
    --pdf "my_bitvmx_function/my_function.yaml" \
    --input "0000007B0000007B" \
    --checkpoint-verifier-path "./checkpoints" \
    --claim-last-step 47 \
    --claim-last-hash "7175baa9616fb26580a72572fb1cfbea9252925f" \
    --command-file "./checkpoints/verifier_command.txt"
```

### 7.3 N-ary 탐색 라운드

```bash
# 라운드 1
cargo run --release -p emulator -- prover-get-hashes-for-round \
    --pdf "my_bitvmx_function/my_function.yaml" \
    --checkpoint-prover-path "./checkpoints" \
    --round 1 \
    --verifier-decision 0

# 검증자 세그먼트 선택
cargo run --release -p emulator -- verifier-choose-segment \
    --pdf "my_bitvmx_function/my_function.yaml" \
    --checkpoint-verifier-path "./checkpoints" \
    --round 1 \
    --hashes "hash1,hash2,hash3"

# 반복...
```

### 7.4 최종 트레이스 제공

```bash
# 프로버가 최종 실행 트레이스 제공
cargo run --release -p emulator -- prover-final-trace \
    --pdf "my_bitvmx_function/my_function.yaml" \
    --checkpoint-prover-path "./checkpoints" \
    --step 23

# 검증자가 챌린지 선택
cargo run --release -p emulator -- verifier-choose-challenge \
    --pdf "my_bitvmx_function/my_function.yaml" \
    --checkpoint-verifier-path "./checkpoints" \
    --trace "step_data" \
    --force "no"
```

---

## **8. Bitcoin Script 검증**

### 8.1 명령어 매핑 생성

```bash
# 모든 RISC-V 명령어에 대한 Bitcoin Script 생성
cargo run --release -p emulator -- instruction-mapping \
    > my_bitvmx_function/bitcoin_scripts/instruction_mapping.log
```

### 8.2 ROM 커밋 생성

```bash
# 프로그램 ROM 커밋 데이터 생성
cargo run --release -p emulator -- generate-rom-commitment \
    --elf "my_bitvmx_function/build/my_function.elf" \
    > my_bitvmx_function/bitcoin_scripts/rom_commitment.script
```

### 8.3 챌린지 스크립트 생성

각 챌린지 타입별로 Bitcoin Script가 자동 생성됩니다:

- **TraceHash**: 해시 체인 검증 스크립트
- **ProgramCounter**: PC 값 검증 스크립트
- **Opcode**: 명령어 디코딩 검증 스크립트
- **Memory**: 메모리 읽기/쓰기 검증 스크립트

---

## **9. 최종 결과**

### 9.1 생성되는 파일들

실행 완료 후 다음 파일들이 생성됩니다:

```
my_bitvmx_function/
├── build/
│   ├── my_function.elf         # 실행 가능한 ELF 파일
│   ├── my_function.bin         # 순수 바이너리 (BitVM용)
│   ├── my_function.hex         # Intel HEX 형식
│   └── my_function.map         # 메모리 맵
├── bitcoin_scripts/
│   ├── p2tr_commit.script      # P2TR 커밋 스크립트
│   ├── challenge.script        # 챌린지 스크립트
│   ├── execution_summary.script # 실행 요약 스크립트
│   ├── instruction_mapping.log # RISC-V→Bitcoin Script 매핑
│   └── rom_commitment.script   # ROM 커밋 스크립트
├── checkpoints/
│   ├── checkpoint.0.json       # 실행 체크포인트들
│   ├── prover_challenge.json   # 프로버 챌린지 로그
│   └── verifier_challenge.json # 검증자 챌린지 로그
└── results/
    ├── execution_trace.log     # 완전한 실행 트레이스
    ├── hash_chain.txt         # SHA-256 해시 체인
    ├── final_hash.txt         # 최종 해시
    ├── calculation_results.json # 계산 결과
    └── bitvmx_report.md       # 최종 리포트
```

### 9.2 최종 검증 결과

성공적으로 완료되면 다음과 같은 결과를 얻습니다:

```
🎉 BitVMX 함수 검증 완료!

📊 실행 결과:
- 바이너리 크기: XXX 바이트
- 실행 스텝: XX 단계
- Bitcoin Script 검증: XX/XX 명령어 (100%)
- 최종 해시: abcdef1234567890...

💰 계산 결과:
- 입력 A: 123
- 입력 B: 123
- 출력: 15171
- 상태: 성공

🔐 암호학적 검증:
- 해시 체인 무결성: ✅
- Bitcoin Script 검증: ✅
- 챌린지 대응 준비: ✅

⚔️ 챌린지 시나리오:
- 프로버 클레임: 커밋됨
- 검증자 검증: 통과
- 분쟁 해결: Bitcoin Script로 온체인 검증 가능
```

### 9.3 Bitcoin 블록체인 배포

생성된 스크립트를 사용하여 실제 Bitcoin 네트워크에 배포:

1. **P2TR 커밋**: `p2tr_commit.script`를 Bitcoin 트랜잭션에 포함
2. **챌린지 준비**: 분쟁 시 `challenge.script` 실행
3. **온체인 검증**: 모든 계산이 Bitcoin Script로 검증 가능

---

## 🎯 **요약**

이 가이드를 따르면:

1. **함수 구현** → Rust로 no_std 환경에서 구현
2. **RISC-V 컴파일** → 204바이트급 초소형 바이너리 생성
3. **에뮬레이터 실행** → BitVMX CPU에서 실행 및 검증
4. **해시 체인 생성** → 모든 실행 단계의 암호학적 증명
5. **챌린지 시스템** → 프로버-검증자 상호작용
6. **Bitcoin Script** → 온체인 검증 가능한 스크립트 생성
7. **완전한 검증** → 세계에서 가장 작은 검증 가능한 계산 시스템

**결과**: 비트코인 블록체인에서 **완전히 검증 가능한** 사용자 정의 함수가 완성됩니다! 🚀

---

_Generated by BitVMX Complete Implementation Guide v1.0_
