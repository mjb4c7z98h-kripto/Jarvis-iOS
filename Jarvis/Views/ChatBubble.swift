//
//  ChatBubble.swift
//  Jarvis
//
//  Chat message bubble component
//

import SwiftUI

struct ChatBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(message.isFromUser ? .white : .black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isFromUser ? Color.blue : Color.gray.opacity(0.2))
                    .cornerRadius(Config.CORNER_RADIUS)
                
                if message.isLoading {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 6, height: 6)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.1),
                                    value: message.isLoading
                                )
                        }
                    }
                    .padding(.horizontal, 12)
                }
                
                Text(message.timestamp, style: .time)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
            }
            
            if !message.isFromUser {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}