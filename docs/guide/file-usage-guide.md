# 📁 BitVMX 프로젝트 파일 사용 가이드

이 문서는 BitVMX 프로젝트에서 생성된 모든 파일들의 **용도**와 **사용 시점**을 정리한 가이드입니다.

## 📋 목차

1. [프로젝트 구조 개요](#프로젝트-구조-개요)
2. [소스 코드 파일](#소스-코드-파일)
3. [빌드 시스템 파일](#빌드-시스템-파일)
4. [실행 관련 파일](#실행-관련-파일)
5. [Bitcoin Script 파일](#bitcoin-script-파일)
6. [자동화 스크립트](#자동화-스크립트)
7. [문서 및 리포트](#문서-및-리포트)
8. [파일 생성 타임라인](#파일-생성-타임라인)

---

## 🏗️ 프로젝트 구조 개요

```
BitVMX-CPU/
├── docs/guide/                     # 📚 문서
│   ├── complete-bitvmx-guide.md    # 완전한 구현 가이드
│   └── file-usage-guide.md
├── poc/
│   ├── one_way_option/             # 🎯 옵션 계산 POC
│   └── example/                    # 🧮 동적 입력 계산 예제
└── emulator/                       # 🖥️ RISC-V 에뮬레이터
```

---

## 💻 소스 코드 파일

### `poc/example/src/my_function.rs`

- **용도**: 메인 계산 로직 구현 (동적 입력 지원)
- **언제 사용**:
  - 개발 단계: 비즈니스 로직 구현
  - 빌드 단계: Rust 컴파일러가 바이너리로 변환
  - 실행 단계: RISC-V 에뮬레이터에서 실행
- **핵심 기능**:
  ```rust
  // 동적 입력 읽기
  fn read_input_data() -> (u32, u32)
  // 핵심 계산: input_a * input_b + 42
  fn my_core_calculation(a: u32, b: u32) -> u32
  ```

### `poc/example/src/start.S`

- **용도**: RISC-V 부트스트랩 어셈블리 코드
- **언제 사용**:
  - 빌드 단계: 프로그램 진입점 설정
  - 실행 단계: 스택 포인터 초기화 후 main 함수 호출
- **핵심 역할**: 메모리 초기화 및 Rust 코드 진입

### `poc/example/src/lib.rs`

- **용도**: Rust 라이브러리 루트 파일 (현재 빈 파일)
- **언제 사용**: Cargo 빌드 시스템이 참조

---

## 🔧 빌드 시스템 파일

### `poc/example/Cargo.toml`

- **용도**: Rust 프로젝트 설정 및 의존성 관리
- **언제 사용**:
  - 개발 단계: 프로젝트 메타데이터 정의
  - 빌드 단계: `cargo build` 시 참조
- **핵심 설정**:
  ```toml
  [workspace]  # 독립 패키지 선언
  [[bin]]      # 바이너리 타겟 정의
  [profile.release]  # 최적화 설정
  ```

### `poc/example/Makefile`

- **용도**: 크로스 컴파일 및 ELF 파일 생성 자동화
- **언제 사용**:
  - 빌드 단계: `make all` 명령으로 전체 빌드
  - 정리 단계: `make clean` 명령으로 빌드 파일 삭제
- **빌드 과정**:
  1. Rust 코드 → RISC-V 오브젝트 파일
  2. 어셈블리 코드 컴파일
  3. 링킹으로 ELF 파일 생성
  4. 바이너리/HEX 파일 변환

### `poc/example/linker.ld`

- **용도**: RISC-V 메모리 레이아웃 정의
- **언제 사용**:
  - 빌드 단계: 링커가 메모리 섹션 배치 시 참조
- **정의하는 영역**:
  ```
  ROM:    0x80000000 (64KB)   - 프로그램 코드
  RAM:    0xA0000000 (256KB)  - 데이터 영역
  INPUT:  0xA0001000 (4KB)    - 입력 데이터
  OUTPUT: 0xA0002000 (4KB)    - 출력 결과
  STACK:  0xE0000000 (8MB)    - 함수 스택
  ```

---

## 🎮 실행 관련 파일

### `poc/example/my_function.yaml`

- **용도**: BitVMX 에뮬레이터 실행 설정
- **언제 사용**:
  - 에뮬레이터 실행 시: 프로그램 특성 정의
  - 챌린지 과정: 검증 파라미터 설정
- **주요 설정**:
  - 메모리 레이아웃 매핑
  - 입출력 섹션 정의
  - 챌린지 타임아웃 및 검증 옵션

### `poc/example/build/` 폴더

#### `my_function.elf`

- **용도**: 실행 가능한 RISC-V 바이너리
- **언제 사용**:
  - 에뮬레이터 실행: `--elf` 파라미터로 지정
  - 분석 도구: `readelf`, `objdump` 등으로 분석
- **생성 과정**: `make all` → 링킹 완료

#### `my_function.bin`

- **용도**: 순수 바이너리 데이터 (216바이트)
- **언제 사용**:
  - 크기 측정: 실제 프로그램 크기 확인
  - 임베디드 배포: 펌웨어 형태로 배포 시

#### `my_function.hex`

- **용도**: Intel HEX 포맷 바이너리
- **언제 사용**:
  - 하드웨어 플래시: FPGA나 마이크로컨트롤러에 업로드
  - 디버깅: 16진수 형태로 코드 검사

#### `my_function.map`

- **용도**: 메모리 맵 및 심볼 정보
- **언제 사용**:
  - 디버깅: 함수 주소와 메모리 사용량 확인
  - 최적화: 메모리 효율성 분석

---

## ₿ Bitcoin Script 파일

### `poc/example/bitcoin_scripts/instruction_mapping.log`

- **용도**: RISC-V 명령어별 Bitcoin Script 매핑
- **언제 사용**:
  - 챌린지 단계: 각 명령어의 Bitcoin Script 검증
  - 개발 참고: 지원되는 명령어 확인
- **크기**: 223KB (수천 개 명령어 매핑)

### `poc/example/bitcoin_scripts/p2tr_commit.script`

- **용도**: P2TR (Pay-to-Taproot) 커밋 스크립트
- **언제 사용**:
  - 온체인 커밋: 계산 결과 해시를 비트코인에 커밋
  - 검증 단계: 최종 해시 일치 여부 확인
- **동작**: SHA256 해시 비교 후 성공/실패 반환

### `poc/example/bitcoin_scripts/challenge.script`

- **용도**: 실행 단계별 챌린지 검증
- **언제 사용**:
  - 분쟁 해결: 프로버와 베리파이어 간 단계별 검증
  - N-ary Search: 잘못된 실행 단계 찾기
- **동작**: 해시 체인 무결성 검증

### `poc/example/bitcoin_scripts/execution_summary.script`

- **용도**: 실행 요약 정보 및 메타데이터
- **언제 사용**:
  - 문서화: 실행 결과 요약
  - 참조: 프로그램 특성 확인
- **포함 정보**: 바이너리 크기, 스텝 수, 입출력 예시

### `poc/example/bitcoin_scripts/rom_commitment.script`

- **용도**: ROM (프로그램 코드) 무결성 커밋
- **언제 사용**:
  - 초기 설정: 프로그램 코드가 변조되지 않았음을 증명
  - 챌린지 시작: 실행할 프로그램의 해시 커밋
- **크기**: 9.6KB (상세한 검증 로직)

---

## 🤖 자동화 스크립트

### `poc/example/scripts/run_example.sh`

- **용도**: 전체 BitVMX 워크플로우 자동화
- **언제 사용**:
  - 개발 중: `./scripts/run_example.sh build` (빌드만)
  - 테스트: `./scripts/run_example.sh run` (실행만)
  - 배포: `./scripts/run_example.sh all` (전체 과정)
- **기능별 사용**:

  ```bash
  # 의존성 확인
  ./scripts/run_example.sh deps

  # 빌드만 실행
  ./scripts/run_example.sh build

  # 에뮬레이터 실행
  ./scripts/run_example.sh run

  # Bitcoin Script 생성
  ./scripts/run_example.sh scripts

  # 리포트 생성
  ./scripts/run_example.sh report

  # 전체 과정
  ./scripts/run_example.sh all
  ```

---

## 📊 문서 및 리포트

### `docs/guide/complete-bitvmx-guide.md`

- **용도**: BitVMX 함수 구현 완전 가이드
- **언제 사용**:
  - 학습: BitVMX 개념과 구현 방법 학습
  - 개발: 새로운 함수 구현 시 참조
  - 온보딩: 새 개발자 교육
- **내용**: 9단계 구현 가이드 + 실제 명령어

### `poc/example/results/example_report.md`

- **용도**: 실행 결과 종합 리포트
- **언제 사용**:
  - 검증: 실행 결과 확인
  - 문서화: 프로젝트 결과 공유
  - 디버깅: 성능 메트릭 분석
- **포함 정보**:
  - 실행 통계 (바이너리 크기, 스텝 수)
  - 계산 결과 (입력, 출력, 상태)
  - 암호학적 검증 (해시 체인)
  - 성능 메트릭 (메모리 효율성)

---

## ⏰ 파일 생성 타임라인

### 1️⃣ **초기 프로젝트 설정 단계**

```
1. Cargo.toml        # Rust 프로젝트 초기화
2. src/lib.rs        # 라이브러리 루트
3. src/start.S       # 어셈블리 부트스트랩
4. linker.ld         # 메모리 레이아웃
5. Makefile          # 빌드 시스템
```

### 2️⃣ **핵심 로직 구현 단계**

```
6. src/my_function.rs    # 메인 계산 로직
7. my_function.yaml      # 에뮬레이터 설정
```

### 3️⃣ **빌드 단계** (`make all`)

```
8. build/start.o         # 어셈블리 오브젝트
9. target/*/deps/*.o     # Rust 오브젝트
10. build/my_function.elf # 실행 파일
11. build/my_function.bin # 바이너리
12. build/my_function.hex # HEX 파일
13. build/my_function.map # 메모리 맵
```

### 4️⃣ **Bitcoin Script 생성 단계**

```
14. bitcoin_scripts/instruction_mapping.log  # 명령어 매핑
15. bitcoin_scripts/p2tr_commit.script       # P2TR 커밋
16. bitcoin_scripts/challenge.script         # 챌린지
17. bitcoin_scripts/execution_summary.script # 실행 요약
18. bitcoin_scripts/rom_commitment.script    # ROM 커밋
```

### 5️⃣ **자동화 및 문서화 단계**

```
19. scripts/run_example.sh           # 자동화 스크립트
20. results/example_report.md        # 실행 리포트
21. docs/guide/complete-bitvmx-guide.md  # 구현 가이드
22. docs/guide/file-usage-guide.md   # 이 파일
```

---

## 🎯 사용 시나리오별 파일 그룹

### **🔧 개발할 때 수정하는 파일**

- `src/my_function.rs` - 비즈니스 로직
- `my_function.yaml` - 실행 설정
- `Cargo.toml` - 의존성 (필요시)

### **🏗️ 빌드할 때 사용하는 파일**

- `Makefile` - 빌드 명령
- `linker.ld` - 메모리 레이아웃
- `src/start.S` - 부트스트랩

### **🚀 실행할 때 필요한 파일**

- `build/my_function.elf` - 실행 바이너리
- `my_function.yaml` - 에뮬레이터 설정

### **₿ 비트코인 검증할 때 사용하는 파일**

- `bitcoin_scripts/*.script` - 모든 스크립트
- `bitcoin_scripts/instruction_mapping.log` - 명령어 매핑

### **📊 결과 확인할 때 보는 파일**

- `results/example_report.md` - 실행 리포트
- `build/my_function.map` - 메모리 사용량

### **🤖 자동화할 때 실행하는 파일**

- `scripts/run_example.sh` - 전체 워크플로우

---

## 💡 **팁: 파일별 우선순위**

### **🔥 매우 중요 (핵심 파일)**

1. `src/my_function.rs` - 실제 로직
2. `build/my_function.elf` - 실행 파일
3. `scripts/run_example.sh` - 자동화

### **⚠️ 중요 (설정 파일)**

4. `my_function.yaml` - 실행 설정
5. `Makefile` - 빌드 시스템
6. `linker.ld` - 메모리 레이아웃

### **📝 참고용 (문서/리포트)**

7. `docs/guide/*.md` - 가이드 문서
8. `results/*.md` - 실행 결과
9. `bitcoin_scripts/*.script` - 검증 스크립트

---

이제 **언제 어떤 파일을 봐야 하는지** 명확하게 알 수 있습니다! 🎉

각 파일의 **생성 시점**, **사용 목적**, **수정 시기**를 이해하면 BitVMX 개발이 훨씬 쉬워집니다.
