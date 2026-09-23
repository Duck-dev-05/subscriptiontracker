import Foundation
import Combine

class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()
    
    @Published var rates: [String: Double] = [:]
    @Published var baseCurrency: String = UserDefaults.standard.string(forKey: "BaseCurrency") ?? "USD" {
        didSet {
            UserDefaults.standard.set(baseCurrency, forKey: "BaseCurrency")
            // Re-fetch rates when base currency changes
            fetchRates(force: true)
        }
    }
    
    let availableCurrencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "VND", "INR", "BRL", "MXN"]
    
    private let ratesCacheKey = "cachedExchangeRates"
    private let lastUpdatedKey = "exchangeRatesLastUpdated"
    
    private init() {
        loadCachedRates()
        fetchRates()
    }
    
    func fetchRates(force: Bool = false) {
        // Fetch only if older than 24 hours (unless forced)
        let lastUpdated = UserDefaults.standard.double(forKey: lastUpdatedKey)
        let now = Date().timeIntervalSince1970
        
        if !force && now - lastUpdated < 86400 && !rates.isEmpty {
            return
        }
        
        let urlString = "https://open.er-api.com/v6/latest/\(baseCurrency)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
                DispatchQueue.main.async {
                    self.rates = result.rates
                    self.saveRatesToCache(rates: result.rates)
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: self.lastUpdatedKey)
                }
            } catch {
                print("Failed to decode exchange rates: \(error)")
            }
        }.resume()
    }
    
    private func saveRatesToCache(rates: [String: Double]) {
        if let data = try? JSONEncoder().encode(rates) {
            UserDefaults.standard.set(data, forKey: ratesCacheKey)
        }
    }
    
    private func loadCachedRates() {
        if let data = UserDefaults.standard.data(forKey: ratesCacheKey),
           let cachedRates = try? JSONDecoder().decode([String: Double].self, from: data) {
            self.rates = cachedRates
        } else {
            // Fallback default rates if first launch without internet
            self.rates = ["USD": 1.0, "EUR": 0.92, "GBP": 0.79, "JPY": 150.0, "VND": 25000.0]
        }
    }
    
    /// Converts an amount from a given currency to the base currency
    func convertToBase(amount: Double, from currencyCode: String) -> Double {
        if currencyCode == baseCurrency { return amount }
        guard let rate = rates[currencyCode], rate > 0 else { return amount } // Fallback to raw amount if rate unknown
        return amount / rate
    }
    
    /// Converts a base amount to a target currency
    func convertFromBase(amount: Double, to currencyCode: String) -> Double {
        if currencyCode == baseCurrency { return amount }
        guard let rate = rates[currencyCode] else { return amount }
        return amount * rate
    }
    
    /// Get the currency symbol for a currency code
    static func symbol(for currencyCode: String) -> String {
        let locale = NSLocale(localeIdentifier: currencyCode)
        return locale.displayName(forKey: .currencySymbol, value: currencyCode) ?? currencyCode
    }
}

struct ExchangeRateResponse: Codable {
    let result: String
    let base_code: String
    let rates: [String: Double]
}
