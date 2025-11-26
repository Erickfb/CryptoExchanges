#!/bin/bash

echo "🚀 CryptoExchanges Setup"
echo ""

# Check if Config.local.swift exists
if [ ! -f "Sources/App/Config.local.swift" ]; then
    echo "📝 Criando Config.local.swift..."
    cp Sources/App/Config.local.swift.example Sources/App/Config.local.swift
    echo "✅ Config.local.swift criado"
    echo ""
    echo "⚠️  IMPORTANTE: Edite Sources/App/Config.local.swift e adicione sua API key"
    echo "   Obtenha sua API key em: https://pro.coinmarketcap.com/account"
    echo ""
    echo "Para editar agora:"
    echo "   open -e Sources/App/Config.local.swift"
    echo ""
else
    echo "✅ Config.local.swift já existe"
    echo ""
fi

echo "🎉 Setup completo! Abra o projeto:"
echo "   open CryptoExchanges.xcodeproj"
