//
//  ChatViewModel.swift
//  hello26
//
//  Created by dmdev on 2025/6/15.
//

import SwiftUI
import FoundationModels
import Combine

/*
 LanguageModelSession.GenerationError 錯誤類型說明：
 
 根據實際的 GenerationError 枚舉定義：
 
 - assetsUnavailable: 語言模型所需的資源目前無法使用
 - decodingFailure: 回應解析失敗
 - exceededContextWindowSize: 問題內容超過了模型的處理限制
 - guardrailViolation: 問題內容觸發了安全保護機制
 - unsupportedGuide: 使用了不支援的生成指引
 - unsupportedLanguageOrLocale: 模型不支援要求的語言或地區設定
 
 每種錯誤類型都提供友善的錯誤訊息、具體的解決建議，並包含詳細的錯誤資訊。
 對於非 GenerationError 類型的錯誤，使用智能分類系統進行處理。
 
 注意：使用 @unknown default 來處理未來可能新增的錯誤類型，確保 Swift 6 相容性。
 */

/*
 錯誤處理說明：
 
 本應用程式使用智能錯誤分類系統，基於錯誤描述來識別和處理各種錯誤類型：
 
 - 內容過濾錯誤：當錯誤描述包含 "content" 和 "filter" 時
 - 模型不可用：當錯誤描述包含 "model" 和 "unavailable" 時
 - 網路錯誤：當錯誤描述包含 "network" 或 "connection" 時
 - 配額超限：當錯誤描述包含 "quota" 或 "limit" 時
 - 伺服器錯誤：當錯誤描述包含 "server" 或 "service" 時
 - 超時錯誤：當錯誤描述包含 "timeout" 或 "timed out" 時
 
 每種錯誤類型都提供友善的錯誤訊息和具體的解決建議。
 */

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isResponding: Bool = false
    @Published var questions: [Question] = []
    
    private var session: LanguageModelSession?
    private let character: Character?
    
    init(character: Character? = nil) {
        self.character = character
        initializeSession()
        loadQuestions()
    }
    
    // MARK: - 初始化方法
    
    private func initializeSession() {
        if #available(iOS 26.0, *) {
            let instructions = character?.systemPrompt ?? """
                你是一個友善的 AI 助手，請用繁體中文回答問題。
                回答要友善親切。
                """
            
            session = LanguageModelSession(instructions: instructions)
        }
    }
    
    private func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let questionList = try JSONDecoder().decode(QuestionList.self, from: data)
            questions = questionList.questions
        } catch {
            // 靜默處理錯誤
        }
    }
    
    // MARK: - 公開方法
    
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !isResponding else { return }
        
        // 添加用戶訊息
        let userMessage = ChatMessage(
            content: trimmedText,
            isUser: true,
            timestamp: Date(),
            firstResponseTime: nil,
            charactersPerSecond: nil,
            isError: false,
            originalPrompt: nil
        )
        messages.append(userMessage)
        
        // 清空輸入框
        inputText = ""
        
        // 開始串流回覆
        isResponding = true
        
        Task {
            await streamResponse(to: trimmedText)
        }
    }
    
    func sendQuickMessage(_ message: String) {
        guard !isResponding else { return }
        
        // 添加用戶訊息
        let userMessage = ChatMessage(
            content: message,
            isUser: true,
            timestamp: Date(),
            firstResponseTime: nil,
            charactersPerSecond: nil,
            isError: false,
            originalPrompt: nil
        )
        messages.append(userMessage)
        
        // 開始串流回覆
        isResponding = true
        
        Task {
            await streamResponse(to: message)
        }
    }
    
    func retryMessage(_ message: ChatMessage) {
        guard let originalPrompt = message.originalPrompt, !isResponding else { return }
        
        // 移除錯誤訊息
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages.remove(at: index)
        }
        
        // 開始串流回覆
        isResponding = true
        
        Task {
            await streamResponse(to: originalPrompt)
        }
    }
    
    // MARK: - 私有方法
    
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
        let assistantMessage = ChatMessage(
            content: "",
            isUser: false,
            timestamp: Date(),
            firstResponseTime: nil,
            charactersPerSecond: nil,
            isError: false,
            originalPrompt: nil
        )
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
                        charactersPerSecond: nil,
                        isError: false,
                        originalPrompt: nil
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
                    charactersPerSecond: charactersPerSecond,
                    isError: false,
                    originalPrompt: nil
                )
            }
        } catch {
            // 處理錯誤
            let errorMessage = getErrorMessage(for: error)
            
            // 更新錯誤訊息到聊天記錄
            if let lastIndex = messages.indices.last {
                messages[lastIndex] = ChatMessage(
                    content: errorMessage,
                    isUser: false,
                    timestamp: assistantMessage.timestamp,
                    firstResponseTime: firstResponseTime,
                    charactersPerSecond: nil,
                    isError: true,
                    originalPrompt: prompt // 保存原始提示詞用於重試
                )
            }
        }
        
        isResponding = false
    }
    
    private func getErrorMessage(for error: Error) -> String {
        // 檢查是否為 FoundationModels 的 GenerationError
        if let generationError = error as? LanguageModelSession.GenerationError {
            switch generationError {
            case .assetsUnavailable:
                return "抱歉，語言模型所需的資源目前無法使用。\n\n💡 建議：\n• 請稍後再試\n• 檢查您的網路連線\n• 如果問題持續，請聯繫客服\n\n詳細資訊：\(error.localizedDescription)"
                
            case .decodingFailure:
                return "抱歉，回應解析失敗。\n\n💡 建議：\n• 請稍後再試\n• 嘗試重新表述您的問題\n• 如果問題持續，請聯繫客服\n\n詳細資訊：\(error.localizedDescription)"
                
            case .exceededContextWindowSize:
                return "抱歉，問題內容超過了模型的處理限制。\n\n💡 建議：\n• 嘗試簡化您的問題\n• 將複雜問題分解為多個簡單問題\n• 減少問題的長度\n\n詳細資訊：\(error.localizedDescription)"
                
            case .guardrailViolation:
                return "抱歉，您的問題內容觸發了安全保護機制。\n\n💡 建議：\n• 嘗試重新表述您的問題\n• 避免使用可能被誤判為不當內容的詞彙\n• 使用更中性的表達方式\n\n詳細資訊：\(error.localizedDescription)"
                
            case .unsupportedGuide:
                return "抱歉，使用了不支援的生成指引。\n\n💡 建議：\n• 請稍後再試\n• 嘗試使用不同的表達方式\n• 如果問題持續，請聯繫客服\n\n詳細資訊：\(error.localizedDescription)"
                
            case .unsupportedLanguageOrLocale:
                return "抱歉，模型不支援您要求的語言或地區設定。\n\n💡 建議：\n• 嘗試使用繁體中文或英文\n• 檢查您的語言設定\n• 如果問題持續，請聯繫客服\n\n詳細資訊：\(error.localizedDescription)"
                
            @unknown default:
                return "抱歉，發生未知的語言模型錯誤。\n\n💡 建議：\n• 請稍後再試\n• 重新啟動應用程式\n• 如果問題持續，請聯繫客服\n\n詳細資訊：\(error.localizedDescription)"
            }
        } else {
            // 處理其他類型的錯誤，使用錯誤描述進行智能分類
            let errorDescription = error.localizedDescription.lowercased()
            
            if errorDescription.contains("content") && errorDescription.contains("filter") {
                return "抱歉，您的問題內容被過濾系統阻擋。\n\n💡 建議：\n• 嘗試重新表述您的問題\n• 避免使用可能被誤判為不當內容的詞彙\n• 使用更中性的表達方式"
            } else if errorDescription.contains("model") && errorDescription.contains("unavailable") {
                return "抱歉，語言模型目前無法使用。\n\n💡 建議：\n• 請稍後再試\n• 檢查您的網路連線\n• 如果問題持續，請聯繫客服"
            } else if errorDescription.contains("network") || errorDescription.contains("connection") {
                return "網路連線發生問題。\n\n💡 建議：\n• 檢查您的網路連線\n• 嘗試切換 WiFi 或行動網路\n• 確認網路設定是否正確"
            } else if errorDescription.contains("quota") || errorDescription.contains("limit") {
                return "已達到使用配額上限。\n\n💡 建議：\n• 請稍後再試\n• 考慮升級您的使用方案\n• 檢查您的使用量統計"
            } else if errorDescription.contains("server") || errorDescription.contains("service") {
                return "伺服器發生錯誤。\n\n💡 建議：\n• 請稍後再試\n• 如果問題持續，請聯繫客服\n• 檢查服務狀態頁面"
            } else if errorDescription.contains("timeout") || errorDescription.contains("timed out") {
                return "回應超時。\n\n💡 建議：\n• 請稍後再試\n• 嘗試簡化您的問題\n• 檢查網路連線速度"
            } else {
                // 處理其他類型的錯誤
                return "抱歉，發生錯誤：\(error.localizedDescription)\n\n💡 建議：\n• 請稍後再試\n• 重新啟動應用程式\n• 如果問題持續，請聯繫客服"
            }
        }
    }
} 