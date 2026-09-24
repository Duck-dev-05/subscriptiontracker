import Foundation
import GoogleSignIn

class GmailScannerService {
    static let shared = GmailScannerService()
    
    // MARK: - Gmail API Structures
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
    
    // MARK: - Gemini API Structures
    struct GeminiRequest: Codable {
        let contents: [GeminiContent]
    }
    struct GeminiContent: Codable {
        let parts: [GeminiPart]
    }
    struct GeminiPart: Codable {
        let text: String
    }
    struct GeminiResponse: Codable {
        let candidates: [GeminiCandidate]?
    }
    struct GeminiCandidate: Codable {
        let content: GeminiContent?
    }
    
    struct ParsedSubscription: Codable {
        let name: String
        let price: Double
        let category: String
        let colorHex: String
        let emoji: String
    }
    
    enum ScannerError: Error {
        case notAuthenticated
        case invalidURL
        case noData
        case apiError(String)
    }
    
    // 👉 ADD YOUR GEMINI API KEY HERE
    private let geminiApiKey = "AQ.Ab8RN6KIPOXUUZ2f5Q7HvAYmXr9jYp3oSLHW4T0IFhHuXIVI7w"
    
    func scanForSubscriptions(completion: @escaping (Result<[Subscription], Error>) -> Void) {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            completion(.failure(ScannerError.notAuthenticated))
            return
        }
        
        let accessToken = user.accessToken.tokenString
        // Specifically target Gmail categories where receipts and subscriptions usually land 
        // to avoid pulling in unrelated generic "All Mail" newsletters.
        let rawQuery = "{category:purchases category:updates category:promotions} (subject:receipt OR subject:invoice OR subject:renewal OR \"subscription\")"
        let query = rawQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://gmail.googleapis.com/gmail/v1/users/me/messages?q=\(query)&maxResults=25"
        
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
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion(.failure(ScannerError.apiError("Gmail API returned status code \(httpResponse.statusCode).")))
                return
            }
            
            do {
                let listResponse = try JSONDecoder().decode(MessageListResponse.self, from: data)
                guard let messageStubs = listResponse.messages, !messageStubs.isEmpty else {
                    completion(.success([]))
                    return
                }
                
                let group = DispatchGroup()
                var collectedSnippets: [String] = []
                let maxToFetch = min(messageStubs.count, 25)
                
                for i in 0..<maxToFetch {
                    group.enter()
                    self.fetchMessageDetail(id: messageStubs[i].id, accessToken: accessToken) { detail in
                        if let detail = detail {
                            collectedSnippets.append(detail.snippet)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    let combinedSnippets = collectedSnippets.enumerated().map { "Email \($0.offset + 1): \($0.element)" }.joined(separator: "\n")
                    
                    if combinedSnippets.isEmpty {
                        completion(.success([]))
                    } else {
                        // Send snippets to Gemini for dynamic parsing
                        self.extractSubscriptionsWithGemini(snippets: combinedSnippets, completion: completion)
                    }
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
    
    private func extractSubscriptionsWithGemini(snippets: String, completion: @escaping (Result<[Subscription], Error>) -> Void) {
        if geminiApiKey == "YOUR_GEMINI_API_KEY_HERE" {
            print("⚠️ Gemini API Key is missing. Falling back to empty array.")
            completion(.failure(ScannerError.apiError("Missing Gemini API Key.")))
            return
        }
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(geminiApiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(ScannerError.invalidURL))
            return
        }
        
        let prompt = """
        You are an expert data extractor. I have a list of email snippets representing receipts or subscriptions.
        Extract all subscription services found.
        Return ONLY a valid JSON array of objects, with NO markdown formatting, NO backticks.
        Each object must have:
        - "name": String (Name of the service)
        - "price": Double (The monthly cost. Guess if not explicitly stated, but 0.0 if unknown)
        - "category": String (Must be exactly one of: "streaming", "music", "gaming", "cloud", "software", "other")
        - "colorHex": String (A suitable hex color code for the brand, e.g., "E50914" for Netflix)
        - "emoji": String (A single fitting emoji, e.g. "🎬" for Netflix)
        
        Email snippets:
        \(snippets)
        """
        
        let requestBody = GeminiRequest(contents: [GeminiContent(parts: [GeminiPart(text: prompt)])])
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(ScannerError.noData)) }
                return
            }
            
            do {
                let geminiResp = try JSONDecoder().decode(GeminiResponse.self, from: data)
                guard let text = geminiResp.candidates?.first?.content?.parts.first?.text else {
                    DispatchQueue.main.async { completion(.success([])) }
                    return
                }
                
                // Clean the text in case Gemini wraps it in markdown (e.g. ```json ... ```)
                let cleanedText = text.replacingOccurrences(of: "```json", with: "")
                                      .replacingOccurrences(of: "```", with: "")
                                      .trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let jsonData = cleanedText.data(using: .utf8) else {
                    DispatchQueue.main.async { completion(.success([])) }
                    return
                }
                
                let parsedSubs = try JSONDecoder().decode([ParsedSubscription].self, from: jsonData)
                
                var finalSubs: [Subscription] = []
                var seenNames = Set<String>()
                
                for p in parsedSubs {
                    // Deduplicate by name
                    let normalizedName = p.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if seenNames.contains(normalizedName) { continue }
                    seenNames.insert(normalizedName)
                    
                    let cat: SubscriptionCategory
                    switch p.category.lowercased() {
                    case "streaming": cat = .streaming
                    case "music": cat = .music
                    case "gaming": cat = .gaming
                    case "cloud": cat = .cloud
                    case "software": cat = .productivity
                    case "productivity": cat = .productivity
                    default: cat = .other
                    }
                    
                    let sub = Subscription(
                        name: p.name,
                        price: p.price,
                        billingCycle: .monthly,
                        nextBillingDate: Date().addingTimeInterval(86400 * 30),
                        colorHex: p.colorHex,
                        category: cat,
                        icon: p.emoji
                    )
                    finalSubs.append(sub)
                }
                DispatchQueue.main.async { completion(.success(finalSubs)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
