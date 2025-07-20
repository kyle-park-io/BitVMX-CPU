# BitVM(X) 단방향 옵션 Makefile
# RISC-V 32비트 크로스 컴파일 설정

# 도구체인 설정
PREFIX = riscv64-elf-
CC = $(PREFIX)gcc
AS = $(PREFIX)as
LD = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
OBJDUMP = $(PREFIX)objdump
READELF = $(PREFIX)readelf
SIZE = $(PREFIX)size

# 프로젝트 설정
PROJECT_NAME = one_way_option
BUILD_DIR = build
SRC_DIR = src

# RISC-V 32비트 컴파일 플래그
CFLAGS = -march=rv32im \
         -mabi=ilp32 \
         -O2 \
         -nostdlib \
         -nostartfiles \
         -fno-common \
         -ffunction-sections \
         -fdata-sections \
         -Wall \
         -Wextra \
         -g

# 어셈블리 플래그
ASFLAGS = -march=rv32im \
          -mabi=ilp32 \
          -g

# 링커 플래그
LDFLAGS = -m elf32lriscv \
          -T linker.ld \
          --nmagic \
          --gc-sections \
          -Map=$(BUILD_DIR)/$(PROJECT_NAME).map \
          --print-memory-usage

# 파일 정의
ASM_SRC = $(SRC_DIR)/start.S
RUST_OBJ = $(shell find target/riscv32i-unknown-none-elf/release/deps -name "$(PROJECT_NAME)-*.o" -type f | head -1)
ELF_FILE = $(BUILD_DIR)/$(PROJECT_NAME).elf
BIN_FILE = $(BUILD_DIR)/$(PROJECT_NAME).bin
HEX_FILE = $(BUILD_DIR)/$(PROJECT_NAME).hex
ASM_OBJ = $(BUILD_DIR)/start.o

# 기본 타겟
all: $(ELF_FILE) $(BIN_FILE) $(HEX_FILE) info

# 빌드 디렉토리 생성
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Rust 코드 컴파일 (오브젝트 파일만 생성)
rust-build:
	@echo "🦀 Rust 코드 컴파일 중..."
	rustup override set nightly
	cargo +nightly rustc --release --bin $(PROJECT_NAME) \
		-Z build-std=core,compiler_builtins \
		-Z build-std-features=panic_immediate_abort \
		-- --emit=obj

# 어셈블리 시작 코드 컴파일
$(ASM_OBJ): $(ASM_SRC) | $(BUILD_DIR)
	@echo "⚙️ 어셈블리 시작 코드 컴파일 중..."
	$(AS) $(ASFLAGS) -o $@ $<

# ELF 파일 생성 (Rust + 어셈블리)
$(ELF_FILE): rust-build $(ASM_OBJ) linker.ld | $(BUILD_DIR)
	@echo "🔗 ELF 파일 생성 중..."
	$(LD) $(LDFLAGS) \
		-o $@ \
		$(ASM_OBJ) \
		$(RUST_OBJ)
	@echo "✅ ELF 파일 생성 완료: $@"

# 바이너리 파일 생성
$(BIN_FILE): $(ELF_FILE)
	@echo "📦 바이너리 파일 생성 중..."
	$(OBJCOPY) -O binary $< $@
	@echo "✅ 바이너리 파일 생성 완료: $@"

# Intel HEX 파일 생성
$(HEX_FILE): $(ELF_FILE)
	@echo "📋 HEX 파일 생성 중..."
	$(OBJCOPY) -O ihex $< $@
	@echo "✅ HEX 파일 생성 완료: $@"

# 파일 정보 출력
info: $(ELF_FILE)
	@echo ""
	@echo "📊 파일 크기 정보:"
	$(SIZE) $(ELF_FILE)
	@echo ""
	@echo "🔍 섹션 정보:"
	$(READELF) -S $(ELF_FILE) | head -20
	@echo ""
	@echo "📄 생성된 파일들:"
	@ls -la $(BUILD_DIR)/

# 디스어셈블리 생성
disasm: $(ELF_FILE)
	@echo "🔍 디스어셈블리 생성 중..."
	$(OBJDUMP) -d $(ELF_FILE) > $(BUILD_DIR)/$(PROJECT_NAME).s
	@echo "✅ 디스어셈블리 생성 완료: $(BUILD_DIR)/$(PROJECT_NAME).s"

# BitVM(X) 에뮬레이터에서 실행
run: $(ELF_FILE)
	@echo "🚀 BitVM(X) 에뮬레이터에서 실행 중..."
	cd ../emulator && cargo run execute --elf-path ../one_way_option_complete/$(ELF_FILE)

# 실행 트레이스 생성
trace: $(ELF_FILE)
	@echo "📝 실행 트레이스 생성 중..."
	cd ../emulator && cargo run execute --elf-path ../one_way_option_complete/$(ELF_FILE) --trace > ../one_way_option_complete/$(BUILD_DIR)/trace.log
	@echo "✅ 실행 트레이스 생성 완료: $(BUILD_DIR)/trace.log"

# 해시 생성
hash: $(ELF_FILE)
	@echo "🔐 BitVM(X) 해시 생성 중..."
	cd ../emulator && cargo run execute --elf-path ../one_way_option_complete/$(ELF_FILE) --output-hash > ../one_way_option_complete/$(BUILD_DIR)/hashes.json
	@echo "✅ 해시 생성 완료: $(BUILD_DIR)/hashes.json"

# 전체 BitVM(X) 프로세스 실행
bitvmx: $(ELF_FILE)
	@echo "🎯 완전한 BitVM(X) 프로세스 실행 중..."
	@$(MAKE) run
	@$(MAKE) trace  
	@$(MAKE) hash
	@echo "🎉 BitVM(X) 프로세스 완료!"

# 정리
clean:
	@echo "🧹 정리 중..."
	rm -rf $(BUILD_DIR)
	rm -rf target
	cargo clean
	@echo "✅ 정리 완료"

# 깊은 정리
clean-all: clean
	@echo "🧹 전체 정리 중..."
	rustup override unset
	@echo "✅ 전체 정리 완료"

# 개발 환경 설정
setup:
	@echo "🔧 개발 환경 설정 중..."
	rustup toolchain install nightly
	rustup override set nightly
	rustup target add riscv32i-unknown-none-elf --toolchain nightly
	@echo "✅ 개발 환경 설정 완료"

# 헬프 메시지
help:
	@echo "📚 BitVM(X) 단방향 옵션 빌드 시스템"
	@echo ""
	@echo "주요 타겟:"
	@echo "  all      - 전체 빌드 (ELF, BIN, HEX)"
	@echo "  run      - BitVM(X) 에뮬레이터에서 실행"
	@echo "  trace    - 실행 트레이스 생성"
	@echo "  hash     - BitVM(X) 해시 생성"
	@echo "  bitvmx   - 완전한 BitVM(X) 프로세스"
	@echo "  disasm   - 디스어셈블리 생성"
	@echo "  info     - 파일 정보 출력"
	@echo "  clean    - 정리"
	@echo "  setup    - 개발 환경 설정"
	@echo "  help     - 이 메시지"

# Phony 타겟
.PHONY: all rust-build run trace hash bitvmx disasm info clean clean-all setup help

# 기본 타겟
.DEFAULT_GOAL := all 