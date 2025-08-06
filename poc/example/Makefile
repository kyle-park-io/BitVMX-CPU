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
		--target riscv32im-unknown-none-elf \
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
		target/riscv32im-unknown-none-elf/release/deps/$(TARGET_NAME)-*.o
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