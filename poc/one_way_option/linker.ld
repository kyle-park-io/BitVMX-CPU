/* BitVM(X) 단방향 옵션 링커 스크립트
 * RISC-V 32비트 BitVM(X) 에뮬레이터용 메모리 레이아웃
 */

OUTPUT_ARCH(riscv)
ENTRY(_start)

/* BitVM(X) 메모리 맵 정의 - test_programs/bitvmx.ld 기반 */
MEMORY
{
    /* 코드 섹션 */
    ROM   (rx)  : ORIGIN = 0x80000000, LENGTH = 64K
    
    /* 데이터 섹션 */
    RAM   (rwx) : ORIGIN = 0xA0000000, LENGTH = 256K
    
    /* 입력 데이터 */
    INDATA (rw)  : ORIGIN = 0xA0001000, LENGTH = 4K
    
    /* 출력 데이터 */
    OUTDATA (rw) : ORIGIN = 0xA0002000, LENGTH = 4K
    
    /* 스택 */
    STACK (rw)  : ORIGIN = 0xE0000000, LENGTH = 8M
    
    /* 레지스터 영역 (에뮬레이터 전용) */
    REGS  (rw)  : ORIGIN = 0xF0000000, LENGTH = 128
}

/* 섹션 배치 정의 - test_programs/bitvmx.ld 기반 */
SECTIONS
{
    /* 엔트리 포인트 */
    .text.init : {
        *(.text.init)
    } > ROM
    
    /* 코드 섹션 */
    .text : {
        PROVIDE(__text_start = .);
        *(.text.init)
        *(.text)
        *(.text.*)
        . = ALIGN(4);
        PROVIDE(__text_end = .);
    } > ROM
    
    /* 읽기 전용 데이터 */
    .rodata : {
        PROVIDE(__rodata_start = .);
        *(.rodata)
        *(.rodata.*)
        *(.srodata)
        *(.srodata.*)
        . = ALIGN(4);
        PROVIDE(__rodata_end = .);
    } > ROM
    
    /* 초기화된 데이터 */
    .data : {
        PROVIDE(__data_start = .);
        *(.data)
        *(.data.*)
        . = ALIGN(4);
        PROVIDE(__data_end = .);
    } > RAM AT > ROM
    
    PROVIDE(__data_load_start = LOADADDR(.data));
    
    /* 초기화되지 않은 데이터 */
    .bss : {
        PROVIDE(__bss_start = .);
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
        PROVIDE(__bss_end = .);
    } > RAM
    
    /* 입력 섹션 */
    .input : {
        PROVIDE(__input_start = .);
        . = . + 4K;
        PROVIDE(__input_end = .);
    } > INDATA
    
    /* 출력 섹션 */
    .output : {
        PROVIDE(__output_start = .);
        . = . + 4K;
        PROVIDE(__output_end = .);
    } > OUTDATA
    
    /* 스택 섹션 */
    .stack : {
        PROVIDE(__stack_bottom = .);
        . = . + 8M - 4;
        PROVIDE(__stack_top = .);
    } > STACK
    
    /* 기타 섹션 제거 */
    /DISCARD/ : {
        *(.comment)
        *(.note*)
        *(.eh_frame*)
        *(.debug*)
    }
}

/* 기본 심볼 정의 */
PROVIDE(__stack_size = LENGTH(STACK)); 