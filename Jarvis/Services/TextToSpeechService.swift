//
//  TextToSpeechService.swift
//  Jarvis
//
//  Service for text-to-speech
//

import Foundation
import AVFoundation

class TextToSpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking = false
    @Published var errorMessage: String?
    
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Stop previous speech if any
        synthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "tr-TR")
        utterance.rate = 0.5 // Slower speech for clarity
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(true)
            
            DispatchQueue.main.async {
                self.isSpeaking = true
            }
            
            synthesizer.speak(utterance)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Konuşma hatası: \(error.localizedDescription)"
            }
        }
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}