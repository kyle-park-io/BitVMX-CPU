#!/bin/bash

# 🎯 BitVM(X) 단방향 옵션 - 빠른 시작 스크립트
# 초보자도 쉽게 사용할 수 있는 간단한 실행 스크립트

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
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║${NC}                ${PURPLE}🎯 BitVM(X) 빠른 시작${NC}                    ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}              ${YELLOW}세계 최소 비트코인 옵션 계산기${NC}              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                     ${GREEN}204 바이트, 47 스텝${NC}                      ${WHITE}║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}�� 실행 위치: $PROJECT_DIR${NC}"
    echo ""
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    echo -e "${WHITE}사용법:${NC}"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/quick_start.sh${NC}           # 전체 실행"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/quick_start.sh build${NC}     # 빌드만"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/quick_start.sh run${NC}       # 실행만"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/quick_start.sh test${NC}      # 테스트만"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/quick_start.sh demo${NC}      # 데모 모드"
    echo -e "  ${CYAN}[어느 경로에서든] ./scripts/quick_start.sh help${NC}      # 도움말"
    echo ""
    echo -e "${YELLOW}💡 어느 경로에서 실행해도 정상 작동합니다!${NC}"
    echo ""
}

check_dependencies() {
    print_info "의존성 확인 중..."
    
    if ! command -v cargo &> /dev/null; then
        print_error "Rust가 설치되지 않았습니다."
        echo -e "  ${CYAN}설치: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh${NC}"
        exit 1
    fi
    
    if ! command -v riscv64-elf-gcc &> /dev/null; then
        print_error "RISC-V 도구체인이 설치되지 않았습니다."
        echo -e "  ${CYAN}macOS: brew install riscv-gnu-toolchain${NC}"
        echo -e "  ${CYAN}Ubuntu: sudo apt-get install gcc-riscv64-unknown-elf${NC}"
        exit 1
    fi
    
    print_info "✅ 기본 의존성 확인 완료"
}

# 메인 실행
case "${1:-}" in
    "help"|"-h"|"--help")
        print_header
        show_usage
        ;;
    "build")
        print_header
        check_dependencies
        print_info "🔨 빌드 시작..."
        "$PROJECT_DIR/scripts/bitvmx_option.sh" build
        ;;
    "run")
        print_header
        print_info "🚀 실행 시작..."
        if [ ! -f "$PROJECT_DIR/build/one_way_option.elf" ]; then
            print_error "빌드 파일이 없습니다. 먼저 빌드합니다..."
            "$PROJECT_DIR/scripts/bitvmx_option.sh" build
        fi
        "$PROJECT_DIR/scripts/bitvmx_option.sh" run
        ;;
    "test")
        print_header
        check_dependencies
        print_info "🧪 테스트 시작..."
        cargo test test_bitvmx_one_way_option_basic --release
        ;;
    "demo")
        print_header
        check_dependencies
        print_info "🎮 데모 시작..."
        "$PROJECT_DIR/scripts/bitvmx_option.sh" all
        ;;
    "")
        print_header
        check_dependencies
        print_info "🌟 전체 실행 시작..."
        "$PROJECT_DIR/scripts/bitvmx_option.sh" all
        print_info "✅ 실행 완료!"
        echo ""
        print_info "📊 결과 확인:"
        if [ -f "$PROJECT_DIR/results/option_results.json" ]; then
            echo -e "  ${CYAN}cat $PROJECT_DIR/results/option_results.json${NC}"
        fi
        if [ -f "$PROJECT_DIR/results/bitvmx_option_report.md" ]; then
            echo -e "  ${CYAN}cat $PROJECT_DIR/results/bitvmx_option_report.md${NC}"
        fi
        ;;
    *)
        print_header
        print_error "알 수 없는 명령어: $1"
        show_usage
        exit 1
        ;;
esac
