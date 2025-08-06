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
