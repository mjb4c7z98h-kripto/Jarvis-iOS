//
//  ContentView.swift
//  Jarvis
//
//  Main chat interface
//

import SwiftUI

struct ContentView: View {
    @StateObject private var geminiService = GeminiService()
    @StateObject private var speechService = SpeechService()
    @StateObject private var textToSpeechService = TextToSpeechService()
    
    @State private var messages: [Message] = []
    @State private var inputText = ""
    @State private var isComposing = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("🤖 Jarvis")
                        .font(.system(size: 28, weight: .bold))
                    
                    if let error = geminiService.errorMessage {
                        Text(error)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    if speechService.isListening {
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.red)
                                    .frame(width: 3, height: CGFloat(8 + index * 4))
                                    .animation(
                                        Animation.easeInOut(duration: 0.5)
                                            .repeatForever()
                                            .delay(Double(index) * 0.1),
                                        value: speechService.isListening
                                    )
                            }
                            Text("Dinleniyor...")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.9))
                .shadow(radius: 2)
                
                // Messages
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            if messages.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "bubble.left")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray.opacity(0.5))
                                    
                                    Text("Selamm! Bana bir soru sor veya konuş")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.gray)
                                    
                                    Text("Sesli komut: 🎤 Yazı: ⌨️")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .padding(32)
                            } else {
                                ForEach(messages) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                }
                            }
                        }
                        .padding(12)
                        .onChange(of: messages) { _ in
                            if let lastMessage = messages.last {
                                withAnimation {
                                    scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Input Area
                VStack(spacing: 12) {
                    // Recognized text display
                    if !speechService.recognizedText.isEmpty {
                        Text(speechService.recognizedText)
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            .lineLimit(2)
                    }
                    
                    // Input field
                    HStack(spacing: 8) {
                        TextField("Mesajınızı yazın...", text: $inputText)
                            .font(.system(size: 16))
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(Config.CORNER_RADIUS)
                            .disabled(geminiService.isLoading)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || geminiService.isLoading)
                    }
                    .padding(12)
                    
                    // Control buttons
                    HStack(spacing: 12) {
                        // Microphone button
                        Button(action: toggleMicrophone) {
                            Image(systemName: speechService.isMuted ? "mic.slash.fill" : (speechService.isListening ? "mic.fill" : "mic"))
                                .font(.system(size: 18))
                                .foregroundColor(speechService.isListening ? .red : (speechService.isMuted ? .gray : .blue))
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(Config.CORNER_RADIUS)
                        }
                        
                        // Use recognized text button
                        if !speechService.recognizedText.isEmpty {
                            Button(action: useRecognizedText) {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle")
                                    Text("Kullan")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.green)
                                .cornerRadius(Config.CORNER_RADIUS)
                            }
                        }
                        
                        // Clear button
                        if !messages.isEmpty {
                            Button(action: clearChat) {
                                Image(systemName: "trash")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(Config.CORNER_RADIUS)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                }
                .background(Color.white.opacity(0.95))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIKeyboardWillShow)) { _ in
            isComposing = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIKeyboardWillHide)) { _ in
            isComposing = false
        }
    }
    
    // MARK: - Methods
    
    private func toggleMicrophone() {
        if speechService.isMuted {
            speechService.toggleMute()
        } else {
            speechService.startListening()
        }
    }
    
    private func useRecognizedText() {
        inputText = speechService.recognizedText
        speechService.recognizedText = ""
        sendMessage()
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty && !geminiService.isLoading else { return }
        
        // Add user message
        var userMessage = Message(content: text, isFromUser: true)
        messages.append(userMessage)
        inputText = ""
        speechService.stopListening()
        speechService.recognizedText = ""
        
        // Add loading message
        var loadingMessage = Message(content: "...", isFromUser: false)
        loadingMessage.isLoading = true
        messages.append(loadingMessage)
        
        // Send to Gemini
        Task {
            if let response = await geminiService.sendMessage(text) {
                // Remove loading message
                messages.removeLast()
                
                // Add response
                messages.append(Message(content: response, isFromUser: false))
                
                // Speak response
                textToSpeechService.speak(response)
            } else {
                // Remove loading message
                messages.removeLast()
                
                // Add error message
                let errorMsg = geminiService.errorMessage ?? "Bilinmeyen hata"
                messages.append(Message(content: "❌ \(errorMsg)", isFromUser: false))
            }
        }
    }
    
    private func clearChat() {
        messages.removeAll()
        speechService.recognizedText = ""
    }
}