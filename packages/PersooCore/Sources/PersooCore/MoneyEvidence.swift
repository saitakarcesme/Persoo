import Foundation

/// Explicit numeric money mentions only. Unsupported/ambiguous formats are not guessed.
public struct MoneyEvidence: Hashable, Sendable {
    public let amountMinor: Int
    public let currency: String
    public static func extract(from text: String) -> Set<MoneyEvidence> {
        let currency = #"(EUR|euros?|€|USD|dollars?|dolar|\$|GBP|pounds?|£|TRY|TL|lira|₺)(?![A-Za-z])"#
        let number = #"(?<![\d.,])(-?\d+(?:[.,]\d{1,2})?)(?![\d.,])"#
        var found = Set<MoneyEvidence>()
        for (pattern, amountGroup, currencyGroup) in [(number + #"\s*"# + currency, 1, 2), (currency + #"\s*"# + number, 2, 1)] {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { continue }
            for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                guard let a = Range(match.range(at: amountGroup), in: text), let c = Range(match.range(at: currencyGroup), in: text),
                      let decimal = Decimal(string: String(text[a]).replacingOccurrences(of: ",", with: "."), locale: Locale(identifier: "en_US_POSIX")) else { continue }
                let minor = NSDecimalNumber(decimal: decimal * 100)
                guard minor.compare(NSDecimalNumber(value: 100_000_000_000)) != .orderedDescending,
                      minor.compare(NSDecimalNumber(value: -100_000_000_000)) != .orderedAscending else { continue }
                let word = text[c].lowercased()
                let code: String
                switch word {
                case "eur", "euro", "euros", "€": code = "EUR"
                case "usd", "dollar", "dollars", "dolar", "$": code = "USD"
                case "gbp", "pound", "pounds", "£": code = "GBP"
                default: code = "TRY"
                }
                found.insert(.init(amountMinor: minor.intValue, currency: code))
            }
        }
        return found
    }
}
