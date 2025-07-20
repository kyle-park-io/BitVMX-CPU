//! BitVM(X) 단방향 옵션 라이브러리
//!
//! 이 라이브러리는 BitVM(X) 환경에서 실행되는 단방향 옵션 계산을 제공합니다.

#![no_std]

/// 옵션 유형 정의
#[repr(u32)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum OptionType {
    Call = 1,
    Put = 2,
}

/// 옵션 계약 구조체
#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct OptionContract {
    pub option_type: OptionType,
    pub current_price: u32,    // 현재가 (센트)
    pub strike_price: u32,     // 행사가 (센트)
    pub contract_size: u32,    // 계약 크기 (사토시)
    pub premium_paid: u32,     // 지불한 프리미엄 (센트)
    pub expiry_timestamp: u32, // 만료 시간
}

/// 정산 결과 구조체
#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct SettlementResult {
    pub settlement_amount: u32, // 정산 금액 (사토시)
    pub profit_loss: u32,       // 순손익 (센트)
    pub is_in_money: u32,       // ITM 여부 (1=ITM, 0=OTM)
    pub option_type: u32,       // 옵션 유형
    pub intrinsic_value: u32,   // 내재가치
    pub execution_status: u32,  // 실행 상태 (0=성공)
}

/// BitVM(X) 메모리 주소 상수
pub mod memory {
    pub const OUTPUT_ADDRESS: u32 = 0xA0002000;
    pub const DEBUG_ADDRESS: u32 = 0xA0001000;
    pub const INPUT_ADDRESS: u32 = 0xA0001000;
}

/// 수학 유틸리티 함수들
pub mod math {
    /// 두 값 중 큰 값 반환
    pub fn max(a: u32, b: u32) -> u32 {
        if a > b {
            a
        } else {
            b
        }
    }

    /// 두 값 중 작은 값 반환
    pub fn min(a: u32, b: u32) -> u32 {
        if a < b {
            a
        } else {
            b
        }
    }

    /// 안전한 나눗셈 (0으로 나누기 방지)
    pub fn safe_div(numerator: u32, denominator: u32) -> u32 {
        if denominator == 0 {
            0
        } else {
            numerator / denominator
        }
    }
}
