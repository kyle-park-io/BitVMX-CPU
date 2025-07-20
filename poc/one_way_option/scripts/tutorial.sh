#!/bin/bash

# 🎓 BitVM(X) 단방향 옵션 - 튜토리얼 스크립트
# 초보자를 위한 단계별 학습 가이드

set -e

# 경로 독립성 구현 - 어느 위치에서 실행해도 작동
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║${NC}              🎓 BitVM(X) 학습 튜토리얼                ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}            비트코인 옵션의 새로운 세계로             ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                단계별 완전 가이드                     ${WHITE}║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📁 학습 위치: $PROJECT_DIR${NC}"
    echo ""
}

quick_summary() {
    print_header
    echo -e "${PURPLE}[TUTORIAL]${NC} ⚡ BitVM(X) 옵션 빠른 요약"
    echo ""
    
    echo -e "${GREEN}🎯 핵심 개념:${NC}"
    echo -e "  • BitVM(X): 비트코인에서 복잡한 계산 검증"
    echo -e "  • 옵션: 미래에 사거나 팔 수 있는 권리"
    echo -e "  • 우리 시스템: 204바이트로 옵션 계산"
    echo ""
    
    echo -e "${GREEN}🚀 실행 방법:${NC}"
    echo -e "  1. ${CYAN}$PROJECT_DIR/scripts/quick_start.sh${NC}        # 원클릭 실행"
    echo -e "  2. ${CYAN}$PROJECT_DIR/scripts/verify.sh${NC}             # 결과 검증"
    echo -e "  3. ${CYAN}cat $PROJECT_DIR/results/option_results.json${NC} # 결과 확인"
    echo ""
    
    echo -e "${GREEN}🎓 학습 포인트:${NC}"
    echo -e "  • 세계 최소 크기 (204바이트)"
    echo -e "  • 완전 검증 가능 (47/47 명령어)"
    echo -e "  • 실전 사용 가능"
    echo ""
}

show_basic_concepts() {
    print_header
    echo -e "${CYAN}[LESSON]${NC} 🎯 BitVM(X) 기본 개념"
    echo ""
    
    echo -e "${WHITE}BitVM(X)는 비트코인에서 복잡한 계산을 검증할 수 있게 해주는 기술입니다.${NC}"
    echo ""
    
    echo -e "${YELLOW}기존 방식의 문제점:${NC}"
    echo -e "  • 비트코인은 단순한 거래만 처리 가능"
    echo -e "  • 복잡한 금융 계산은 중앙화된 서버 필요"
    echo -e "  • 신뢰 문제 발생"
    echo ""
    
    echo -e "${GREEN}BitVM(X)의 해결책:${NC}"
    echo -e "  • 복잡한 계산을 오프체인에서 실행"
    echo -e "  • 결과를 비트코인에서 검증"
    echo -e "  • 100% 탈중앙화"
    echo ""
    
    echo -e "${GREEN}[TIP]${NC} 마치 수학 시험에서 답만 제출하고, 선생님이 검산으로 확인하는 것과 같습니다!"
    echo ""
    
    echo -e "${YELLOW}💰 옵션이란?${NC}"
    echo -e "  • 콜옵션: 미래에 특정 가격으로 살 수 있는 권리"
    echo -e "  • 풋옵션: 미래에 특정 가격으로 팔 수 있는 권리"
    echo -e "  • ITM (In The Money): 수익이 나는 상태"
    echo -e "  • OTM (Out of The Money): 손실이 나는 상태"
    echo ""
    
    echo -e "${GREEN}🏗️ 우리 시스템:${NC}"
    echo -e "  • 입력: BTC 현재가 $30,000, 행사가 $0.01"
    echo -e "  • 처리: 204바이트 RISC-V 프로그램 (47단계)"
    echo -e "  • 검증: 각 단계를 Bitcoin Script로 검증"
    echo -e "  • 출력: 6,666,666 사토시 정산 (ITM 콜옵션)"
    echo ""
}

show_usage() {
    echo -e "${WHITE}사용법:${NC}"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/tutorial.sh${NC}              # 빠른 요약"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/tutorial.sh quick${NC}        # 빠른 요약"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/tutorial.sh concepts${NC}     # 개념 설명"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/tutorial.sh demo${NC}         # 실행 데모"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/tutorial.sh help${NC}         # 도움말"
    echo ""
    echo -e "${YELLOW}💡 어느 경로에서 실행해도 정상 작동합니다!${NC}"
    echo ""
}

run_demo() {
    print_header
    echo -e "${PURPLE}[TUTORIAL]${NC} 🎮 실행 데모"
    echo ""
    
    echo -e "${WHITE}BitVM(X) 옵션 시스템을 실제로 실행해보겠습니다!${NC}"
    echo ""
    
    echo -e "${YELLOW}📊 현재 설정:${NC}"
    echo -e "  • BTC 현재가: $30,000"
    echo -e "  • 행사가격: $0.01 (극단적 ITM)"
    echo -e "  • 옵션 유형: 콜옵션"
    echo -e "  • 예상 결과: 엄청난 수익!"
    echo ""
    
    read -p "🚀 실행하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${GREEN}🌟 전체 실행을 시작합니다...${NC}"
        "$PROJECT_DIR/scripts/quick_start.sh"
        echo ""
        echo -e "${GREEN}[TIP]${NC} 🎉 축하합니다! BitVM(X) 옵션 실행이 완료되었습니다!"
        echo -e "${GREEN}[TIP]${NC} 결과 확인:"
        echo -e "  ${CYAN}cat $PROJECT_DIR/results/option_results.json${NC}"
        echo -e "  ${CYAN}cat $PROJECT_DIR/results/bitvmx_option_report.md${NC}"
    else
        echo -e "${GREEN}[TIP]${NC} 나중에 준비되면 실행해보세요!"
        echo -e "  ${CYAN}$PROJECT_DIR/scripts/quick_start.sh${NC}"
    fi
}

show_next_steps() {
    print_header
    echo -e "${PURPLE}[TUTORIAL]${NC} 🎯 다음 단계"
    echo ""
    
    echo -e "${GREEN}🔧 실습 단계:${NC}"
    echo -e "  1. ${CYAN}$PROJECT_DIR/scripts/tutorial.sh demo${NC}      # 실행 데모"
    echo -e "  2. ${CYAN}$PROJECT_DIR/scripts/quick_start.sh${NC}        # 직접 실행"
    echo -e "  3. ${CYAN}$PROJECT_DIR/scripts/verify.sh${NC}             # 결과 검증"
    echo ""
    
    echo -e "${GREEN}📚 파라미터 변경:${NC}"
    echo -e "  • 파일: ${CYAN}$PROJECT_DIR/src/one_way_option.rs${NC}"
    echo -e "  • current_price: 현재가 (센트 단위)"
    echo -e "  • strike_price: 행사가 (센트 단위)"
    echo -e "  • option_type: 1=콜, 0=풋"
    echo ""
    
    echo -e "${GREEN}🎓 고급 학습:${NC}"
    echo -e "  • RISC-V 어셈블리 언어"
    echo -e "  • Bitcoin Script 심화"
    echo -e "  • 암호학 해시 함수"
    echo -e "  • Taproot와 Schnorr 서명"
    echo ""
}

# 메인 실행
case "${1:-quick}" in
    "quick"|"")
        quick_summary
        ;;
    "concepts")
        show_basic_concepts
        ;;
    "demo")
        run_demo
        ;;
    "next")
        show_next_steps
        ;;
    "help"|"-h"|"--help")
        print_header
        show_usage
        ;;
    *)
        print_header
        echo -e "${RED}[ERROR] 알 수 없는 명령어: $1${NC}"
        show_usage
        exit 1
        ;;
esac
