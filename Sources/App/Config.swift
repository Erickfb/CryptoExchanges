import Foundation

enum Config {
    static var coinMarketCapAPIKey: String {
        if let apiKey = ProcessInfo.processInfo.environment["COINMARKETCAP_API_KEY"], !apiKey.isEmpty {
            return apiKey
        }

        #if DEBUG
        if let apiKey = Self.localAPIKey, !apiKey.isEmpty {
            return apiKey
        }
        #endif

        fatalError("""
            CoinMarketCap API Key not found!

            Quick fix:
            1. Get your key: https://pro.coinmarketcap.com/account
            2. Copy file: cp Sources/App/Config.local.swift.example Sources/App/Config.local.swift
            3. Edit file and add your key
            4. Clean Build (⇧⌘K) and Build again (⌘B)

            See API_KEY_SETUP.md for details.
            """)
    }
}
