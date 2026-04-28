#!/bin/bash

# Цвета
GREEN='\033[0;32m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'
BOLD='\033[1m'

clear

echo -e "${CYAN}"
cat << 'EOF'
   ██████╗██╗ ██████╗ █████╗ ██████╗  █████╗
  ██╔════╝██║██╔════╝██╔══██╗██╔══██╗██╔══██╗
  ██║     ██║██║     ███████║██║  ██║███████║
  ██║     ██║██║     ██╔══██║██║  ██║██╔══██║
  ╚██████╗██║╚██████╗██║  ██║██████╔╝██║  ██║
   ╚═════╝╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝
EOF
echo -e "${RESET}"

echo -e "  ${WHITE}${BOLD}CICADA${RESET} ${DIM}— Язык программирования на русском${RESET}"
echo ""
echo -e "  ${DIM}────────────────────────────────────────${RESET}"
echo ""

echo -e "  ${DIM}Идёт установка...${RESET}"
echo ""

# Скачиваем бинарник
sudo wget -q --show-progress \
  -O /usr/local/bin/cicada \
  https://github.com/Cicadadenis/cicada_lang/raw/refs/heads/main/cicada

if [ $? -ne 0 ]; then
  echo ""
  echo -e "  ${RED}✗ Ошибка загрузки. Проверьте интернет-соединение.${RESET}"
  exit 1
fi

# Даём права на выполнение
sudo chmod +x /usr/local/bin/cicada

echo ""
echo -e "  ${DIM}────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${GREEN}${BOLD}✓ Cicada успешно установлена!${RESET}"
echo ""
echo -e "  ${DIM}Запуск:${RESET}"
echo ""
echo -e "  ${CYAN}\$${RESET} ${WHITE}cicada${RESET}              ${DIM}# интерактивный режим${RESET}"
echo -e "  ${CYAN}\$${RESET} ${WHITE}cicada файл.cicada${RESET}  ${DIM}# запуск файла${RESET}"
echo ""
echo -e "  ${DIM}────────────────────────────────────────${RESET}"
echo -e "  ${DIM}github.com/Cicadadenis/cicada_lang${RESET}"
echo ""