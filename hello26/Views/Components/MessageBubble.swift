//
//  MessageBubble.swift
//  hello26
//
//  Created by dmdev on 2025/6/15.
//

import SwiftUI

// 訊息氣泡元件
struct MessageBubble: View {
    let message: ChatMessage
    let onRetry: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("您")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    MarkdownText(text: message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .cornerRadius(4, corners: [.topLeft, .topRight, .bottomLeft])
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI 助手")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ZStack(alignment: .bottomTrailing) {
                        MarkdownText(text: message.content)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(message.isError ? Color.red.opacity(0.1) : Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                            .cornerRadius(4, corners: [.topLeft, .topRight, .bottomRight])
                    }
                    
                    // 錯誤訊息的重試按鈕
                    if message.isError, let onRetry = onRetry {
                        HStack {
                            Spacer()
                            
                            Button(action: onRetry) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 12))
                                    Text("重試")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 4)
                    }
                    
                    // 顯示回應時間和字元速度資訊在訊息框外部右下角
                    if let firstResponseTime = message.firstResponseTime, !message.isError {
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                if let charactersPerSecond = message.charactersPerSecond {
                                    Text(String(format: "%.1f 字元/s", charactersPerSecond))
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemBackground).opacity(0.8))
                                        .cornerRadius(4)
                                }
                                
                                Text(String(format: "%.2fs", firstResponseTime))
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemBackground).opacity(0.8))
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
} 