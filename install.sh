#!/usr/bin/env bash
set -e

# ─────────────────────────────────────────────
#              ЦВЕТА И СТИЛИ
# ─────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

BG_BLACK="\033[40m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"

# ─────────────────────────────────────────────
#              ПЕРЕМЕННЫЕ
# ─────────────────────────────────────────────
CICADA_URL="https://raw.githubusercontent.com/Cicadadenis/cicada_lang/refs/heads/main/cicada/cicada.py"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="cicada"
WORK_DIR="/tmp/cicada_build_$$"
VENV_DIR="$WORK_DIR/venv"
SOURCE_FILE="$WORK_DIR/cicada.py"

# ─────────────────────────────────────────────
#              ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
# ─────────────────────────────────────────────

clear_line() {
    printf "\r\033[K"
}

print_logo() {
    echo ""
    echo -e "${CYAN}${BOLD}"
    echo "   ██████╗██╗ ██████╗ █████╗ ██████╗  █████╗ "
    echo "  ██╔════╝██║██╔════╝██╔══██╗██╔══██╗██╔══██╗"
    echo "  ██║     ██║██║     ███████║██║  ██║███████║"
    echo "  ██║     ██║██║     ██╔══██║██║  ██║██╔══██║"
    echo "  ╚██████╗██║╚██████╗██║  ██║██████╔╝██║  ██║"
    echo "   ╚═════╝╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝"
    echo -e "${RESET}"
    echo -e "  ${WHITE}${BOLD}        Язык Программирования  ${CYAN}v2.0${RESET}"
    echo -e "  ${DIM}        cicada-lang · русский синтаксис${RESET}"
    echo ""
    echo -e "  ${BG_CYAN}${BLACK}${BOLD}                                              ${RESET}"
    echo -e "  ${BG_CYAN}${BLACK}${BOLD}   🦗  Добро пожаловать в установщик Cicada  ${RESET}"
    echo -e "  ${BG_CYAN}${BLACK}${BOLD}                                              ${RESET}"
    echo ""
}

print_step() {
    local step="$1"
    local total="$2"
    local label="$3"
    printf "  ${CYAN}[${step}/${total}]${RESET} ${BOLD}${label}${RESET}"
}

print_ok() {
    echo -e "  ${GREEN}✔${RESET}  $1"
}

print_warn() {
    echo -e "  ${YELLOW}⚠${RESET}  $1"
}

print_error() {
    echo ""
    echo -e "  ${RED}${BOLD}✖  Ошибка:${RESET} $1"
    echo ""
    exit 1
}

print_section() {
    echo ""
    echo -e "  ${DIM}──────────────────────────────────────────────${RESET}"
    echo -e "  ${MAGENTA}${BOLD}  $1${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────${RESET}"
    echo ""
}

spinner() {
    local pid=$1
    local label=$2
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}${frames[$i]}${RESET}  ${label}${DIM}...${RESET}"
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.1
    done
    clear_line
}

# ─────────────────────────────────────────────
#              ПРОВЕРКА ROOT
# ─────────────────────────────────────────────
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        print_error "Запустите скрипт с правами суперпользователя: ${BOLD}sudo bash install.sh"
    fi
}

# ─────────────────────────────────────────────
#              ОПРЕДЕЛЕНИЕ ОС
# ─────────────────────────────────────────────
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_ID="${ID}"
        OS_NAME="${NAME}"
    elif command -v sw_vers &>/dev/null; then
        OS_ID="macos"
        OS_NAME="macOS $(sw_vers -productVersion)"
    else
        OS_ID="unknown"
        OS_NAME="Unknown OS"
    fi
}

pkg_install() {
    case "$OS_ID" in
        ubuntu|debian|pop|linuxmint|kali)
            apt-get install -y "$@" >/dev/null 2>&1 ;;
        fedora)
            dnf install -y "$@" >/dev/null 2>&1 ;;
        centos|rhel|rocky|almalinux)
            yum install -y "$@" >/dev/null 2>&1 ;;
        arch|manjaro|endeavouros)
            pacman -S --noconfirm "$@" >/dev/null 2>&1 ;;
        opensuse*|suse)
            zypper install -y "$@" >/dev/null 2>&1 ;;
        macos)
            brew install "$@" >/dev/null 2>&1 ;;
        *)
            print_error "Неизвестный пакетный менеджер. Установите python3 вручную." ;;
    esac
}

# ─────────────────────────────────────────────
#              ШАГИ УСТАНОВКИ
# ─────────────────────────────────────────────

step_python() {
    # Python3
    print_step "1" "7" "Проверка....."
    if command -v python3 &>/dev/null; then
        PY_VER=$(python3 --version 2>&1 | awk '{print $2}')
        clear_line
    else
        printf "\n"
        (pkg_install python3 2>/dev/null) &
        spinner $! "Проверка....."
        command -v python3 &>/dev/null || print_error "Не удалось установить Python 3"
    fi

    # pip
    print_step "2" "7" "Проверка....."
    if python3 -m pip --version &>/dev/null; then
        clear_line
    else
        printf "\n"
        (pkg_install python3-pip 2>/dev/null || python3 -m ensurepip --upgrade >/dev/null 2>&1) &
        spinner $! "Проверка....."
        python3 -m pip --version &>/dev/null || print_error "Не удалось установить pip"
    fi

    # venv модуль
    print_step "3" "7" "Проверка....."
    if python3 -m venv --help &>/dev/null; then
        clear_line
    else
        printf "\n"
        (pkg_install python3-venv 2>/dev/null) &
        spinner $! "Проверка....."
        python3 -m venv --help &>/dev/null || print_error "Не удалось установить venv"
    fi
}

step_download() {
    print_section "Загрузка исходного кода"

    mkdir -p "$WORK_DIR"

    print_step "4" "7" "Загрузка cicada"
    (
        if command -v curl &>/dev/null; then
            curl -fsSL "$CICADA_URL" -o "$SOURCE_FILE"
        elif command -v wget &>/dev/null; then
            wget -q "$CICADA_URL" -O "$SOURCE_FILE"
        else
            print_error "Установите curl или wget для загрузки файлов"
        fi
    ) &
    spinner $! "Загрузка cicada"

    if [[ ! -f "$SOURCE_FILE" ]] || [[ ! -s "$SOURCE_FILE" ]]; then
        print_error "Не удалось загрузить cicada с GitHub"
    fi

    clear_line
    print_ok "cicada загружен"
}

step_venv() {
    # Создание venv
    print_step "5" "7" "Подготовка....."
    (python3 -m venv "$VENV_DIR" >/dev/null 2>&1) &
    spinner $! "Подготовка....."
    clear_line

    # Установка PyInstaller
    print_step "5" "7" "Установка...."
    (
        "$VENV_DIR/bin/pip" install --upgrade pip >/dev/null 2>&1
        "$VENV_DIR/bin/pip" install pyinstaller requests >/dev/null 2>&1
    ) &
    spinner $! "Установка....."
    clear_line
}

step_build() {
    # Сборка бинарника
    print_step "6" "7" "Компиляция бинарника"
    (
        cd "$WORK_DIR"
        "$VENV_DIR/bin/pyinstaller" \
            --onefile \
            --name "$BINARY_NAME" \
            --distpath "$WORK_DIR/dist" \
            --workpath "$WORK_DIR/build" \
            --specpath "$WORK_DIR" \
            --clean \
            "$SOURCE_FILE" >/dev/null 2>&1
    ) &
    spinner $! "Компиляция бинарника Cicada"

    BINARY_PATH="$WORK_DIR/dist/$BINARY_NAME"
    if [[ ! -f "$BINARY_PATH" ]]; then
        print_error "Компиляция завершилась с ошибкой. Бинарник не создан."
    fi

    clear_line
    print_ok "Бинарник успешно скомпилирован"
}

step_install() {
    print_section "Установка в систему"

    print_step "7" "7" "Перемещение в $INSTALL_DIR"
    mv "$BINARY_PATH" "$INSTALL_DIR/$BINARY_NAME" >/dev/null 2>&1
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
    clear_line
    print_ok "Бинарник установлен в ${BOLD}$INSTALL_DIR/$BINARY_NAME${RESET}"
}

step_cleanup() {
    (rm -rf "$WORK_DIR" >/dev/null 2>&1) &
    spinner $! "Очистка временных файлов"
    clear_line
    print_ok "Временные файлы удалены"
}

print_success() {
    echo ""
    echo -e "  ${BG_BLACK}${GREEN}${BOLD}                                              ${RESET}"
    echo -e "  ${BG_BLACK}${GREEN}${BOLD}   ✅  Cicada успешно установлена!            ${RESET}"
    echo -e "  ${BG_BLACK}${GREEN}${BOLD}                                              ${RESET}"
    echo ""
    echo -e "  ${CYAN}${BOLD}Как запустить:${RESET}"
    echo ""
    echo -e "  ${WHITE}  cicada${RESET}                  ${DIM}# Интерактивный режим${RESET}"
    echo -e "  ${WHITE}  cicada скрипт.cicada${RESET}    ${DIM}# Запуск файла${RESET}"
    echo ""
    echo -e "  ${CYAN}${BOLD}Разработчик:${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────${RESET}"
    echo -e "  ${DIM}  @ Creator: Cicada3301 ${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────${RESET}"
    echo ""
}

# ─────────────────────────────────────────────
#              ТОЧКА ВХОДА
# ─────────────────────────────────────────────

trap 'echo ""; print_error "Установка прервана пользователем"' INT

print_logo
detect_os
echo -e "  ${DIM}  Система: ${OS_NAME}${RESET}"
echo ""

check_root

step_python
step_download
step_venv
step_build
step_install
step_cleanup
print_success
