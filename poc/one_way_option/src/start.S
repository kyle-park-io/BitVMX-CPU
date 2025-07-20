# BitVM(X) 간단한 시작 코드
# 기본적인 초기화만 수행

.section .text.init
.global _start

_start:
    # 스택 포인터만 설정
    li sp, 0xE0000000 + 0x007FFFFC
    
    # main 함수 호출
    call main
    
    # main에서 반환된 후 종료
    # a0에는 main의 반환값이 들어있음
    li a7, 93           # sys_exit
    ecall               # 시스템 콜
    
    # 무한 루프 (ecall이 실패한 경우)
1:
    j 1b 