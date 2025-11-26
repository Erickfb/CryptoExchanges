import Foundation

enum Logger {
    static var isEnabled = false

    static func log(_ message: String, category: Category = .general) {
        #if DEBUG
        guard isEnabled else { return }
        print("\(category.emoji) \(message)")
        #endif
    }

    static func logAPIRequest(url: String, headers: [String: String]) {
        #if DEBUG
        guard isEnabled else { return }
        print("\n🌐 === API REQUEST ===")
        print("📍 URL: \(url)")
        print("📤 Headers:")
        headers.forEach { key, value in
            if key.contains("API_KEY") || key.contains("Authorization") {
                print("   \(key): \(String(value.prefix(10)))...")
            } else {
                print("   \(key): \(value)")
            }
        }
        #endif
    }

    static func logAPIResponse(statusCode: Int, dataSize: Int) {
        #if DEBUG
        guard isEnabled else { return }
        print("\n📥 === API RESPONSE ===")
        print("📊 Status Code: \(statusCode)")
        print("📦 Response Size: \(dataSize) bytes")
        #endif
    }

    static func logJSON(_ data: Data) {
        #if DEBUG
        guard isEnabled else { return }
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("\n📄 === JSON RESPONSE ===")
            print(prettyString)
            print("=================================\n")
        }
        #endif
    }

    static func logError(_ error: Error, context: String = "") {
        #if DEBUG
        let contextInfo = context.isEmpty ? "" : " [\(context)]"
        print("❌ Error\(contextInfo): \(error.localizedDescription)")
        #endif
    }

    static func logSuccess(_ message: String) {
        #if DEBUG
        guard isEnabled else { return }
        print("✅ \(message)")
        #endif
    }

    enum Category {
        case general
        case network
        case ui
        case navigation

        var emoji: String {
            switch self {
            case .general: return "📱"
            case .network: return "🌐"
            case .ui: return "🎨"
            case .navigation: return "🧭"
            }
        }
    }
}
