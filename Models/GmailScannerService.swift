import Foundation
import GoogleSignIn

class GmailScannerService {
    static let shared = GmailScannerService()
    
    // Structure for Gmail API Response
    struct MessageListResponse: Codable {
        let messages: [MessageStub]?
    }
    
    struct MessageStub: Codable {
        let id: String
    }
    
    struct MessageDetail: Codable {
        let id: String
        let snippet: String
    }
    
    enum ScannerError: Error {
        case notAuthenticated
        case invalidURL
        case noData
        case apiError(String)
    }
    
    func scanForSubscriptions(completion: @escaping (Result<[Subscription], Error>) -> Void) {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            completion(.failure(ScannerError.notAuthenticated))
            return
        }
        
        let accessToken = user.accessToken.tokenString
        let query = "from:no-reply@apple.com OR from:googleplay-noreply@google.com OR subject:receipt OR subject:subscription".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://gmail.googleapis.com/gmail/v1/users/me/messages?q=\(query)&maxResults=15"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(ScannerError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ScannerError.noData))
                return
            }
            
            // Check for HTTP errors (e.g. 403 Forbidden if Gmail API is not enabled)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion(.failure(ScannerError.apiError("Gmail API returned status code \(httpResponse.statusCode). Make sure the Gmail API is enabled in Google Cloud Console and the user granted the mail.readonly scope.")))
                return
            }
            
            do {
                let listResponse = try JSONDecoder().decode(MessageListResponse.self, from: data)
                guard let messageStubs = listResponse.messages, !messageStubs.isEmpty else {
                    completion(.success([]))
                    return
                }
                
                // Fetch details for up to 10 messages to prevent rate limiting
                let group = DispatchGroup()
                var foundSubscriptions: [Subscription] = []
                let maxToFetch = min(messageStubs.count, 10)
                
                for i in 0..<maxToFetch {
                    group.enter()
                    self.fetchMessageDetail(id: messageStubs[i].id, accessToken: accessToken) { detail in
                        if let detail = detail {
                            if let parsedSub = self.parseSnippetForSubscription(detail.snippet) {
                                foundSubscriptions.append(parsedSub)
                            }
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    // Deduplicate by name
                    var uniqueSubs: [String: Subscription] = [:]
                    for sub in foundSubscriptions {
                        uniqueSubs[sub.name] = sub
                    }
                    completion(.success(Array(uniqueSubs.values)))
                }
                
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func fetchMessageDetail(id: String, accessToken: String, completion: @escaping (MessageDetail?) -> Void) {
        let urlString = "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(id)?format=metadata"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let detail = try? JSONDecoder().decode(MessageDetail.self, from: data) {
                completion(detail)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    private func parseSnippetForSubscription(_ snippet: String) -> Subscription? {
        let lowercased = snippet.lowercased()
        
        var name = ""
        var price = 0.0
        var category: SubscriptionCategory = .other
        var colorHex = ""
        var emoji = ""
        
        if lowercased.contains("netflix") {
            name = "Netflix"
            price = 15.49
            category = .streaming
            colorHex = "E50914"
            emoji = "🍿"
        } else if lowercased.contains("spotify") {
            name = "Spotify"
            price = 10.99
            category = .music
            colorHex = "1DB954"
            emoji = "🎵"
        } else if lowercased.contains("youtube premium") {
            name = "YouTube Premium"
            price = 13.99
            category = .streaming
            colorHex = "FF0000"
            emoji = "▶️"
        } else if lowercased.contains("hulu") {
            name = "Hulu"
            price = 7.99
            category = .streaming
            colorHex = "1CE783"
            emoji = "📺"
        } else if lowercased.contains("icloud") || lowercased.contains("apple one") {
            name = "Apple Storage"
            price = 2.99
            category = .cloud
            colorHex = "36C2FF"
            emoji = "☁️"
        } else {
            return nil
        }
        
        return Subscription(
            name: name,
            price: price,
            billingCycle: .monthly,
            nextBillingDate: Date().addingTimeInterval(86400 * 30),
            colorHex: colorHex,
            category: category,
            icon: emoji
        )
    }
}
