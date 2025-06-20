//
//  Question.swift
//  hello26
//
//  Created by dmdev on 2025/6/15.
//

import Foundation

// 問題結構
struct Question: Codable {
    let title: String
    let content: String
}

// 問題列表結構
struct QuestionList: Codable {
    let questions: [Question]
} 