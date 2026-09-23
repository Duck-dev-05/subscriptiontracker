import Foundation

struct CancellationGuide {
    static let knownURLs: [String: String] = [
        "netflix": "https://www.netflix.com/cancelplan",
        "spotify": "https://www.spotify.com/account/cancel/",
        "apple one": "https://support.apple.com/en-us/HT202039",
        "apple music": "https://support.apple.com/en-us/HT202039",
        "apple tv+": "https://support.apple.com/en-us/HT202039",
        "icloud": "https://support.apple.com/en-us/HT207594",
        "amazon prime": "https://www.amazon.com/mc/pipelines/cancellation",
        "hulu": "https://secure.hulu.com/account",
        "disney+": "https://www.disneyplus.com/account/cancel-subscription",
        "hbo max": "https://auth.max.com/subscription",
        "max": "https://auth.max.com/subscription",
        "youtube premium": "https://www.youtube.com/paid_memberships",
        "chatgpt plus": "https://chat.openai.com/account",
        "adobe": "https://account.adobe.com/plans",
        "microsoft 365": "https://account.microsoft.com/services",
        "xbox game pass": "https://account.microsoft.com/services"
    ]
    
    static func url(for subscriptionName: String) -> URL {
        let normalized = subscriptionName.lowercased().trimmingCharacters(in: .whitespaces)
        
        if let directUrlString = knownURLs[normalized], let url = URL(string: directUrlString) {
            return url
        }
        
        // Fallback to Google Search
        let query = "How to cancel \(subscriptionName) subscription".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/search?q=\(query)")!
    }
}
