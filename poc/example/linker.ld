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