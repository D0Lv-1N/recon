#!/usr/bin/env bash
set -euo pipefail

# ── Warna untuk output ─────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ── Fungsi cetak ─────────────────────────────────────────────
print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Cek apakah perintah tersedia ─────────────────────────────
command_exists() { command -v "$1" >/dev/null 2>&1; }

# ── Pastikan Go terinstal ───────────────────────────────────
check_go() {
    if command_exists go; then
        print_success "Go already installed"
    else
        print_warning "Go not found. Please install from https://go.dev/doc/install"
        exit 1
    fi
}

# ── Instalasi subfinder (skip jika sudah ada) ─────────────────
install_subfinder() {
    if command_exists subfinder; then
        print_info "subfinder already installed, skipping"
    else
        print_info "Installing subfinder..."
        go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        sudo mv ~/go/bin/subfinder /usr/local/bin/ && print_success "subfinder installed"
    fi
}


# ── Instalasi httpx (skip jika sudah ada) ─────────────────────
install_httpx() {
    if command_exists httpx; then
        print_info "httpx already installed, skipping"
    else
        print_info "Installing httpx..."
        go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
        sudo mv ~/go/bin/httpx /usr/local/bin/ && print_success "httpx installed"
    fi
}

install_notify() {
    if command -v notify >/dev/null 2>&1; then
        print_info "notify already installed, skipping"
    else
        print_info "Installing notify..."
        go install -v github.com/projectdiscovery/notify/cmd/notify@latest
        sudo mv ~/go/bin/notify /usr/local/bin/ && print_success "notify installed"
    fi
}


# ── Verifikasi semua tools terinstal ───────────────────────
verify_tools() {
    local missing=0
    for tool in subfinder assetfinder findomain dnsx httpx notify; do
        if ! command_exists "$tool"; then
            print_error "$tool not installed"
            missing=1
        else
            print_success "$tool installed"
        fi
    done
    if [[ $missing -eq 1 ]]; then
        exit 1
    fi
}

# ── Fungsi utama ───────────────────────────────────────────
main() {
    echo "=== Reconnaissance Tools Setup ==="
    detect_os() {
        case "$OSTYPE" in
            linux*) OS="linux" ;;
            darwin*) OS="macos" ;;
            msys*|cygwin*) OS="windows" ;;
            *) print_error "Unsupported OS: $OSTYPE"; exit 1 ;;
        esac
        print_info "Detected OS: $OS"
    }
    detect_os
    check_go
    install_notify
    install_subfinder
    install_httpx
    verify_tools
    print_success "All tools installed successfully!"
    print_info "You can now run: ./recon.sh"
}

# ── Jalankan -------------------------------------------------
main "$@"
