//
//  GeminiResponse.swift
//  Jarvis
//
//  Data model for Gemini API response
//

import Foundation

struct GeminiResponse: Codable {
    let candidates: [Candidate]
    
    struct Candidate: Codable {
        let content: ContentBlock
        let finishReason: String
        
        enum CodingKeys: String, CodingKey {
            case content
            case finishReason = "finish_reason"
        }
    }
    
    struct ContentBlock: Codable {
        let parts: [Part]
        let role: String
    }
    
    struct Part: Codable {
        let text: String
    }
    
    var extractedText: String? {
        guard let firstCandidate = candidates.first else { return nil }
        return firstCandidate.content.parts.first?.text
    }
}