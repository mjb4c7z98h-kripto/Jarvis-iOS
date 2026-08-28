//
//  SpeechService.swift
//  Jarvis
//
//  Service for speech recognition
//

import Foundation
import Speech
import AVFoundation

class SpeechService: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var errorMessage: String?
    @Published var isMuted = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Config.SPEECH_LOCALE)
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override init() {
        super.init()
        requestMicrophonePermission()
        speechRecognizer?.delegate = self
    }
    
    func requestMicrophonePermission() {
        AVAudioApplication.requestRecordPermission { granted in
            if !granted {
                DispatchQueue.main.async {
                    self.errorMessage = "Mikrofon izni reddedildi"
                }
            }
        }
    }
    
    func startListening() {
        if isListening {
            stopListening()
            return
        }
        
        guard !isMuted else {
            errorMessage = "Mikrofon kapalı"
            return
        }
        
        recognizedText = ""
        errorMessage = nil
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.requiresOnDeviceRecognition = false
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.recognizedText = result.bestTranscription.formattedString
                    }
                    
                    if result.isFinal {
                        self.stopListening()
                    }
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Tanıma hatası: \(error.localizedDescription)"
                    }
                    self.stopListening()
                }
            }
            
            DispatchQueue.main.async {
                self.isListening = true
            }
            
        } catch {
            errorMessage = "Ses motoru hatası: \(error.localizedDescription)"
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        DispatchQueue.main.async {
            self.isListening = false
        }
    }
    
    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            stopListening()
        }
    }
}