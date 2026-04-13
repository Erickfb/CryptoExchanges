#!/bin/bash

ENV_FILE="${SRCROOT}/.env"
OUTPUT_FILE="${SRCROOT}/Sources/App/Config.Generated.swift"

if [ ! -f "$ENV_FILE" ]; then
    echo "error: Arquivo .env não encontrado em ${SRCROOT}/.env"
    echo "error: Crie o arquivo .env e adicione: COINMARKETCAP_API_KEY=sua_chave_aqui"
    echo "error: Obtenha sua key em: https://pro.coinmarketcap.com/account"
    exit 1
fi

API_KEY=$(grep -E '^COINMARKETCAP_API_KEY=' "$ENV_FILE" | cut -d '=' -f2- | tr -d '[:space:]')

if [ -z "$API_KEY" ]; then
    echo "error: COINMARKETCAP_API_KEY não está definida ou está vazia no arquivo .env"
    echo "error: Edite o arquivo .env e adicione: COINMARKETCAP_API_KEY=sua_chave_aqui"
    echo "error: Obtenha sua key em: https://pro.coinmarketcap.com/account"
    exit 1
fi

cat > "$OUTPUT_FILE" << EOF
import Foundation

extension Config {
    static let _apiKey: String = "${API_KEY}"
}
EOF
