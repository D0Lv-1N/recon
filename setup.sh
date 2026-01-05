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

# ── Instalasi dnsx (skip jika sudah ada) ─────────────────────
install_dnsx() {
    if command_exists dnsx; then
        print_info "dnsx already installed, skipping"
    else
        print_info "Installing dnsx..."
        go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
        sudo mv ~/go/bin/dnsx /usr/local/bin/ && print_success "dnsx installed"
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

# ── Instalasi assetfinder (auto cek OS & arsitektur) ───────
install_assetfinder() {
    if command_exists assetfinder; then
        print_info "assetfinder already installed, skipping"
        return
    fi

    print_info "Installing assetfinder..."
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64*) ARCH="amd64" ;;
        aarch64*) ARCH="arm64" ;;
        *) print_error "Unsupported architecture"; exit 1 ;;
    esac

    URL="https://github.com/tomnomnom/assetfinder/releases/download/v0.1.1/assetfinder-linux-${ARCH}-0.1.1.tgz"
    print_info "Downloading assetfinder from $URL"
    curl -L -o assetfinder.tgz "$URL"
    tar -xzf assetfinder.tgz
    sudo mv assetfinder /usr/local/bin/ && print_success "assetfinder installed"
    rm -f assetfinder.tgz
}

# ── Instalasi findomain (auto cek OS & arsitektur) ───────
install_findomain() {
    if command_exists findomain; then
        print_info "findomain already installed, skipping"
        return
    fi

    print_info "Installing findomain..."
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64*) ARCH="x86_64" ;;
        aarch64*) ARCH="arm64" ;;
        i386*|i686*) ARCH="i386" ;;
        *) print_error "Unsupported architecture for findomain"; exit 1 ;;
    esac

    if [[ "$OS" == "linux" ]]; then
        URL="https://github.com/findomain/findomain/releases/latest/download/findomain-linux-${ARCH}.zip"
    elif [[ "$OS" == "macos" ]]; then
        URL="https://github.com/findomain/findomain/releases/latest/download/findomain-macos-${ARCH}.zip"
    else
        print_error "findomain not supported on $OS"
        exit 1
    fi

    print_info "Downloading findomain from $URL"
    curl -LO "$URL"
    unzip findomain*.zip
    chmod +x findomain
    sudo mv findomain /usr/local/bin/ && print_success "findomain installed"
    rm -f findomain*.zip
}

# ── Verifikasi semua tools terinstal ───────────────────────
verify_tools() {
    local missing=0
    for tool in subfinder httpx assetfinder findomain; do
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
    install_subfinder
    install_httpx
    install_assetfinder
    install_findomain
    verify_tools
    print_success "All tools installed successfully!"
    print_info "You can now run: ./recon.sh"
}

# ── Jalankan -------------------------------------------------
main "$@"
