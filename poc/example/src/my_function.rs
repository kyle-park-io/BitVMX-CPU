#![no_std]
#![no_main]

// 메모리 주소 정의
const OUTPUT_ADDRESS: u32 = 0xA0002000;
const INPUT_ADDRESS: u32 = 0xA0001000;

// 계산 결과 구조체
#[repr(C)]
struct CalculationResult {
    result_value: u32, // 계산 결과
    input_hash: u32,   // 입력 해시
    status_code: u32,  // 상태 코드 (0=성공)
    checksum: u32,     // 체크섬
}

// 패닉 핸들러 (필수)
#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    unsafe {
        // 패닉 시 안전하게 종료
        core::arch::asm!(
            "li a7, 93", // SYS_EXIT
            "li a0, 1",  // exit code 1
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

// 🎯 핵심 계산 함수 (간단한 예시: 곱셈과 덧셈)
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

// 입력 데이터 읽기 (안전한 기본값 포함)
unsafe fn read_input_data() -> (u32, u32) {
    let input_ptr = INPUT_ADDRESS as *const u32;

    // 메모리에서 읽기 시도, 실패하면 기본값 사용
    let input_a = core::ptr::read_volatile(input_ptr);
    let input_b = core::ptr::read_volatile(input_ptr.add(1));

    // 입력이 0이면 기본값 사용 (동적 입력 테스트용)
    if input_a == 0 && input_b == 0 {
        (123, 456) // 테스트용 기본값
    } else {
        (input_a, input_b)
    }
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

// 메인 계산 로직 (동적 입력 사용)
fn main_calculation() -> CalculationResult {
    // 메모리에서 동적 입력 읽기
    let (input_a, input_b) = unsafe { read_input_data() };

    // 핵심 계산 수행
    let result_value = my_core_calculation(input_a, input_b);

    // 입력 해시 계산 (간단한 예시)
    let input_hash = input_a.wrapping_add(input_b).wrapping_mul(0x9e3779b9);

    // 체크섬 계산
    let checksum = result_value
        .wrapping_add(input_hash)
        .wrapping_add(0x12345678);

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
