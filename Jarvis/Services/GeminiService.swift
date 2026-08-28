//
//  GeminiService.swift
//  Jarvis
//
//  Service for communicating with Gemini API
//

import Foundation

class GeminiService: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = Config.GEMINI_API_KEY
    private let apiUrl = Config.GEMINI_API_URL
    private let session = URLSession.shared
    
    func sendMessage(_ message: String) async -> String? {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        guard !apiKey.contains("YOUR_") else {
            let error = "API anahtarı yapılandırılmadı. Config.swift'de GEMINI_API_KEY'i ayarla."
            DispatchQueue.main.async {
                self.errorMessage = error
            }
            return nil
        }
        
        let urlString = "\(apiUrl)?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Geçersiz URL"
            }
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = Config.API_TIMEOUT
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": message]
                    ]
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "İstek oluşturulamadı"
            }
            return nil
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Sunucu hatası"
                }
                return nil
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorText = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
                DispatchQueue.main.async {
                    self.errorMessage = "API Hatası (\(httpResponse.statusCode)): \(errorText)"
                }
                return nil
            }
            
            let decoder = JSONDecoder()
            let geminiResponse = try decoder.decode(GeminiResponse.self, from: data)
            return geminiResponse.extractedText
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Bağlantı hatası: \(error.localizedDescription)"
            }
            return nil
        }
    }
}