//
//  Message.swift
//  Jarvis
//
//  Data model for chat messages
//

import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    var isLoading: Bool = false
    
    init(content: String, isFromUser: Bool) {
        self.id = UUID()
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case isFromUser
        case timestamp
    }
}