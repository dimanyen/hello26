//
//  ChatMessage.swift
//  hello26
//
//  Created by dmdev on 2025/6/15.
//

import Foundation

// 聊天訊息結構
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let firstResponseTime: Double? // 第一次回應時間（秒）
    let charactersPerSecond: Double? // 字元/秒
    let isError: Bool // 是否為錯誤訊息
    let originalPrompt: String? // 原始提示詞（用於重試）
} 