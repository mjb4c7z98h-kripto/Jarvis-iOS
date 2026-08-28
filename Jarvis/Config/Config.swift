//
//  Config.swift
//  Jarvis
//
//  Configuration file for API keys and settings
//

import Foundation

struct Config {
    // MARK: - API Configuration
    static let GEMINI_API_KEY = "YOUR_GEMINI_API_KEY_HERE"
    static let GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent"
    
    // MARK: - App Configuration
    static let APP_NAME = "Jarvis"
    static let APP_VERSION = "1.0.0"
    static let MIN_IOS_VERSION = 15.0
    
    // MARK: - Speech Configuration
    static let SPEECH_LANGUAGE = "tr-TR" // Turkish
    static let SPEECH_LOCALE = Locale(identifier: "tr_TR")
    static let SPEECH_RECOGNITION_TIMEOUT: TimeInterval = 60
    
    // MARK: - API Configuration
    static let API_TIMEOUT: TimeInterval = 30
    static let MAX_RETRIES = 3
    static let RETRY_DELAY: TimeInterval = 2
    
    // MARK: - UI Configuration
    static let CHAT_MESSAGE_MAX_WIDTH = 0.8
    static let ANIMATION_DURATION = 0.3
    static let CORNER_RADIUS = 12.0
}