import Foundation

enum FormatHelper {
    static func formatDate(_ dateString: String, style: DateStyle = .long) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: dateString) else {
            return dateString
        }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "pt_BR")

        switch style {
        case .short:
            displayFormatter.dateFormat = "d 'de' MMM 'de' yyyy"
        case .long:
            displayFormatter.dateFormat = "d 'de' MMMM 'de' yyyy"
        }

        return displayFormatter.string(from: date)
    }

    static func formatCurrency(_ value: Double, maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = maximumFractionDigits

        if let formatted = formatter.string(from: NSNumber(value: value)) {
            return formatted
        }

        return "$\(formatNumber(value, maximumFractionDigits: maximumFractionDigits))"
    }

    static func formatNumber(_ value: Double, maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFractionDigits

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 8

        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }

    enum DateStyle {
        case short
        case long
    }
}
