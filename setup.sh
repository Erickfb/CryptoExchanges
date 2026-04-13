#!/bin/bash

set -e

BOLD="\033[1m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RESET="\033[0m"

echo ""
echo -e "${BOLD}CryptoExchanges — Setup${RESET}"
echo "─────────────────────────────────────────"

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}Arquivo .env não encontrado. Criando...${RESET}"
    echo "COINMARKETCAP_API_KEY=" > "$ENV_FILE"
    echo -e "${GREEN}.env criado${RESET}"
fi

API_KEY=$(grep -E '^COINMARKETCAP_API_KEY=' "$ENV_FILE" | cut -d '=' -f2- | tr -d '[:space:]')

if [ -z "$API_KEY" ]; then
    echo ""
    echo -e "${RED}ERRO: COINMARKETCAP_API_KEY não está definida no .env${RESET}"
    echo ""
    echo "  1. Obtenha sua key em: https://pro.coinmarketcap.com/account"
    echo "  2. Edite o arquivo .env:"
    echo ""
    echo "       COINMARKETCAP_API_KEY=sua_chave_aqui"
    echo ""
    echo "  3. Execute novamente: ./setup.sh"
    echo ""
    exit 1
fi

echo -e "${GREEN}COINMARKETCAP_API_KEY encontrada no .env${RESET}"

chmod +x scripts/load_env.sh

echo ""
echo "Executando xcodegen generate..."
echo ""

if ! command -v xcodegen &> /dev/null; then
    echo -e "${RED}ERRO: xcodegen não está instalado.${RESET}"
    echo "  Instale via Homebrew: brew install xcodegen"
    exit 1
fi

xcodegen generate

echo ""
echo -e "${GREEN}Projeto gerado com sucesso!${RESET}"
echo ""
echo "Abra o projeto:"
echo "   open CryptoExchanges.xcodeproj"
echo ""
