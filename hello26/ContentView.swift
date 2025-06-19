//
//  ContentView.swift
//  hello26
//
//  Created by dmdev on 2025/6/15.
//

import SwiftUI
import FoundationModels

// 聊天訊息結構
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let firstResponseTime: Double? // 第一次回應時間（秒）
    let charactersPerSecond: Double? // 字元/秒
}

struct ContentView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isResponding: Bool = false
    @State private var session: LanguageModelSession?
    
    var body: some View {
        VStack(spacing: 0) {
            // 聊天記錄區域
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                        
                        // 串流回覆顯示區域
                        if isResponding {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("AI 助手")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Text("正在思考中")
                                            .foregroundColor(.secondary)
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages) { _ in
                    if let lastMessage = messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // 輸入區域
            VStack(spacing: 0) {
                Divider()
                
                // 快速輸入按鈕區域
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        QuickInputButton(
                            title: "你好啊",
                            action: { sendQuickMessage("你好啊") }
                        )
                        
                        QuickInputButton(
                            title: "跟我講三隻小豬的故事",
                            action: { sendQuickMessage("跟我講三隻小豬的故事") }
                        )
                        
                        QuickInputButton(
                            title: "9.11與9.9數值哪一個大",
                            action: { sendQuickMessage("9.11與9.9數值哪一個大") }
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                Divider()
                
                HStack(spacing: 12) {
                    TextField("輸入您的問題...", text: $inputText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(1...4)
                        .disabled(isResponding)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isResponding ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isResponding)
                }
                .padding()
            }
        }
        .onAppear {
            initializeSession()
        }
    }
    
    private func initializeSession() {
        if #available(iOS 26.0, *) {
            session = LanguageModelSession(
                instructions: """
                你是一個友善的 AI 助手，請用繁體中文回答問題。
                回答要友善親切。
                """
            )
        }
    }
    
    private func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !isResponding else { return }
        
        // 添加用戶訊息
        let userMessage = ChatMessage(content: trimmedText, isUser: true, timestamp: Date(), firstResponseTime: nil, charactersPerSecond: nil)
        messages.append(userMessage)
        
        // 清空輸入框
        inputText = ""
        
        // 開始串流回覆
        isResponding = true
        
        Task {
            await streamResponse(to: trimmedText)
        }
    }
    
    private func sendQuickMessage(_ message: String) {
        guard !isResponding else { return }
        
        // 添加用戶訊息
        let userMessage = ChatMessage(content: message, isUser: true, timestamp: Date(), firstResponseTime: nil, charactersPerSecond: nil)
        messages.append(userMessage)
        
        // 開始串流回覆
        isResponding = true
        
        Task {
            await streamResponse(to: message)
        }
    }
    
    @MainActor
    private func streamResponse(to prompt: String) async {
        guard let session = session else {
            isResponding = false
            return
        }
        
        // 記錄開始時間
        let startTime = Date()
        var firstResponseTime: Double?
        var isFirstResponse = true
        
        // 建立空的 AI 訊息
        let assistantMessage = ChatMessage(content: "", isUser: false, timestamp: Date(), firstResponseTime: nil, charactersPerSecond: nil)
        messages.append(assistantMessage)
        
        do {
            let stream = session.streamResponse(to: prompt)
            
            for try await response in stream {
                // 記錄第一次回應時間
                if isFirstResponse {
                    firstResponseTime = Date().timeIntervalSince(startTime)
                    isFirstResponse = false
                }
                
                // 直接更新最後一條訊息的內容
                if let lastIndex = messages.indices.last {
                    messages[lastIndex] = ChatMessage(
                        content: response,
                        isUser: false,
                        timestamp: assistantMessage.timestamp,
                        firstResponseTime: firstResponseTime,
                        charactersPerSecond: nil
                    )
                }
            }
            
            // 計算字元速度
            if let lastIndex = messages.indices.last {
                let finalContent = messages[lastIndex].content
                let totalTime = Date().timeIntervalSince(startTime)
                let charactersPerSecond = totalTime > 0 ? Double(finalContent.count) / totalTime : 0
                
                messages[lastIndex] = ChatMessage(
                    content: finalContent,
                    isUser: false,
                    timestamp: assistantMessage.timestamp,
                    firstResponseTime: firstResponseTime,
                    charactersPerSecond: charactersPerSecond
                )
            }
        } catch {
            // 處理錯誤
            if let lastIndex = messages.indices.last {
                messages[lastIndex] = ChatMessage(
                    content: "抱歉，發生錯誤：\(error.localizedDescription)",
                    isUser: false,
                    timestamp: assistantMessage.timestamp,
                    firstResponseTime: firstResponseTime,
                    charactersPerSecond: nil
                )
            }
        }
        
        isResponding = false
    }
}

// 訊息氣泡元件
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("您")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(message.content)
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
                        Text(message.content)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                            .cornerRadius(4, corners: [.topLeft, .topRight, .bottomRight])
                    }
                    
                    // 顯示回應時間和字元速度資訊在訊息框外部右下角
                    if let firstResponseTime = message.firstResponseTime {
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

// 圓角擴展
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// 快速輸入按鈕元件
struct QuickInputButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
