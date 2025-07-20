// 📁 one_way_option.rs
// 🎯 BitVM(X)용 완전한 단방향 옵션 시스템

#![no_std]
#![no_main]

// no_std 환경에서는 기본 타입을 그대로 사용

// 메모리 주소 정의
const OUTPUT_ADDRESS: u32 = 0xA0002000;
const DEBUG_ADDRESS: u32 = 0xA0001000;

// 옵션 유형 정의
#[repr(u32)]
#[derive(Clone, Copy)]
enum OptionType {
    Call = 1,
    Put = 2,
}

// 옵션 계약 구조체
#[repr(C)]
struct OptionContract {
    option_type: OptionType,
    current_price: u32,    // 현재가 (센트)
    strike_price: u32,     // 행사가 (센트)
    contract_size: u32,    // 계약 크기 (사토시)
    premium_paid: u32,     // 지불한 프리미엄 (센트)
    expiry_timestamp: u32, // 만료 시간
}

// 정산 결과 구조체
#[repr(C)]
struct SettlementResult {
    settlement_amount: u32, // 정산 금액 (사토시)
    profit_loss: u32,       // 순손익 (센트)
    is_in_money: u32,       // ITM 여부 (1=ITM, 0=OTM)
    option_type: u32,       // 옵션 유형
    intrinsic_value: u32,   // 내재가치
    execution_status: u32,  // 실행 상태 (0=성공)
}

// 시스템 콜 정의
extern "C" {
    fn sys_exit(code: u32) -> !;
}

// 시스템 콜 구현
#[inline(always)]
unsafe fn exit(code: u32) -> ! {
    core::arch::asm!(
        "li a7, 93",      // SYS_EXIT
        "mv a0, {0}",     // exit code
        "ecall",
        in(reg) code,
        options(noreturn)
    );
}

#[inline(always)]
unsafe fn write_debug_char(c: u8) {
    let debug_ptr = DEBUG_ADDRESS as *mut u32;
    core::ptr::write_volatile(debug_ptr, (c as u32) << 24);

    core::arch::asm!(
        "li a7, 116", // SYS_WRITE
        "li a0, 0",
        "ecall",
        options(nostack)
    );
}

// 패닉 핸들러
#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    unsafe {
        write_debug_char(b'P');
        write_debug_char(b'A');
        write_debug_char(b'N');
        write_debug_char(b'I');
        write_debug_char(b'C');
        write_debug_char(b'\n');
        exit(1);
    }
}

// 수학 유틸리티 함수들
fn max(a: u32, b: u32) -> u32 {
    if a > b {
        a
    } else {
        b
    }
}

fn min(a: u32, b: u32) -> u32 {
    if a < b {
        a
    } else {
        b
    }
}

// 안전한 나눗셈 (0으로 나누기 방지)
fn safe_div(numerator: u32, denominator: u32) -> u32 {
    if denominator == 0 {
        0
    } else {
        numerator / denominator
    }
}

// 콜 옵션 계산
fn calculate_call_option(contract: &OptionContract) -> SettlementResult {
    let mut result = SettlementResult {
        settlement_amount: 0,
        profit_loss: 0,
        is_in_money: 0,
        option_type: OptionType::Call as u32,
        intrinsic_value: 0,
        execution_status: 0,
    };

    // ITM 체크: 현재가 > 행사가
    if contract.current_price > contract.strike_price {
        result.is_in_money = 1;

        // 내재가치 = 현재가 - 행사가
        result.intrinsic_value = contract.current_price - contract.strike_price;

        // 정산 금액 계산 (사토시 단위로 변환)
        // settlement = (내재가치 * 계약크기) / 현재가
        let settlement_calc = (result.intrinsic_value as u64 * contract.contract_size as u64)
            / contract.current_price as u64;
        result.settlement_amount = settlement_calc as u32;

        // 순손익 계산 (프리미엄 고려 안함 - 별도 처리)
        result.profit_loss = result.intrinsic_value;
    }

    result
}

// 풋 옵션 계산
fn calculate_put_option(contract: &OptionContract) -> SettlementResult {
    let mut result = SettlementResult {
        settlement_amount: 0,
        profit_loss: 0,
        is_in_money: 0,
        option_type: OptionType::Put as u32,
        intrinsic_value: 0,
        execution_status: 0,
    };

    // ITM 체크: 행사가 > 현재가
    if contract.strike_price > contract.current_price {
        result.is_in_money = 1;

        // 내재가치 = 행사가 - 현재가
        result.intrinsic_value = contract.strike_price - contract.current_price;

        // 정산 금액 계산 (사토시 단위로 변환)
        let settlement_calc = (result.intrinsic_value as u64 * contract.contract_size as u64)
            / contract.current_price as u64;
        result.settlement_amount = settlement_calc as u32;

        // 순손익 계산
        result.profit_loss = result.intrinsic_value;
    }

    result
}

// 통합 옵션 정산 함수
fn execute_option_settlement(contract: &OptionContract) -> SettlementResult {
    match contract.option_type {
        OptionType::Call => calculate_call_option(contract),
        OptionType::Put => calculate_put_option(contract),
    }
}

// 결과를 메모리에 저장
unsafe fn save_result_to_memory(result: &SettlementResult) {
    let output_ptr = OUTPUT_ADDRESS as *mut u32;

    // 결과를 순차적으로 저장 (안전한 방식)
    core::ptr::write_volatile(output_ptr.add(0), result.settlement_amount); // 정산 금액
    core::ptr::write_volatile(output_ptr.add(1), result.profit_loss); // 순손익
    core::ptr::write_volatile(output_ptr.add(2), result.is_in_money); // ITM 여부
    core::ptr::write_volatile(output_ptr.add(3), result.option_type); // 옵션 유형
    core::ptr::write_volatile(output_ptr.add(4), result.intrinsic_value); // 내재가치
    core::ptr::write_volatile(output_ptr.add(5), result.execution_status); // 실행 상태

    // 검증을 위한 입력 데이터도 저장
    core::ptr::write_volatile(output_ptr.add(6), 0xDEADBEEF); // 매직 넘버
    core::ptr::write_volatile(output_ptr.add(7), 0x12345678); // 체크섬
}

// 디버그 메시지 출력
unsafe fn print_debug_message(msg: &[u8]) {
    for &byte in msg {
        write_debug_char(byte);
    }
}

// 메인 계산 로직
fn main_calculation() -> SettlementResult {
    // 🎯 실제 시장 시나리오 1: Bull Market 콜 옵션
    let call_contract = OptionContract {
        option_type: OptionType::Call,
        current_price: 4500000,       // $45,000.00
        strike_price: 4200000,        // $42,000.00
        contract_size: 100000000,     // 1 BTC (사토시)
        premium_paid: 300000,         // $3,000.00
        expiry_timestamp: 1640995200, // 2022-01-01
    };

    // 🎯 실제 시장 시나리오 2: Bear Market 풋 옵션
    let put_contract = OptionContract {
        option_type: OptionType::Put,
        current_price: 3800000,   // $38,000.00
        strike_price: 4200000,    // $42,000.00
        contract_size: 100000000, // 1 BTC (사토시)
        premium_paid: 400000,     // $4,000.00
        expiry_timestamp: 1640995200,
    };

    // 두 시나리오를 모두 계산하고 콜 옵션 결과 반환
    let call_result = execute_option_settlement(&call_contract);
    let _put_result = execute_option_settlement(&put_contract);

    // 콜 옵션 결과를 주 결과로 반환
    call_result
}

// 프로그램 엔트리 포인트
#[no_mangle]
pub extern "C" fn main() -> i32 {
    unsafe {
        // 🧮 옵션 계산 실행 (디버그 출력 없이)
        let result = main_calculation();

        // 📤 결과 저장
        save_result_to_memory(&result);

        // 🏁 정상 종료
        exit(0);
    }
}
