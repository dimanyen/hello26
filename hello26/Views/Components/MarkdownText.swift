//
//  MarkdownText.swift
//  hello26
//
//  Created by dmdev on 2025/6/15.
//

import SwiftUI

// Markdown 文字渲染元件
struct MarkdownText: View {
    let text: String
    
    var body: some View {
        Text(AttributedString(attributedString))
    }
    
    private var attributedString: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        // 解析粗體語法 **text** 或 __text__
        parseBold(attributedString)
        
        // 解析斜體語法 *text* 或 _text_
        parseItalic(attributedString)
        
        // 解析程式碼語法 `text`
        parseCode(attributedString)
        
        return attributedString
    }
    
    private func parseBold(_ attributedString: NSMutableAttributedString) {
        let string = attributedString.string
        
        // 匹配 **text** 或 __text__
        let boldPattern = try! NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*|__(.*?)__")
        let matches = boldPattern.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        
        // 從後往前處理，避免索引偏移
        for match in matches.reversed() {
            let range = match.range
            
            // 找到實際內容的範圍（排除標記符號）
            let contentRange = NSRange(location: range.location + 2, length: range.length - 4)
            
            // 應用粗體樣式
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: contentRange)
            
            // 移除標記符號
            attributedString.deleteCharacters(in: NSRange(location: range.location, length: 2))
            attributedString.deleteCharacters(in: NSRange(location: range.location + range.length - 4, length: 2))
        }
    }
    
    private func parseItalic(_ attributedString: NSMutableAttributedString) {
        let string = attributedString.string
        
        // 匹配 *text* 或 _text_（但排除粗體語法）
        let italicPattern = try! NSRegularExpression(pattern: "(?<!\\*)\\*(?!\\*)(.*?)(?<!\\*)\\*(?!\\*)|(?<!_)_(?!_)(.*?)(?<!_)_(?!_)")
        let matches = italicPattern.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        
        // 從後往前處理
        for match in matches.reversed() {
            let range = match.range
            
            // 找到實際內容的範圍（排除標記符號）
            let contentRange = NSRange(location: range.location + 1, length: range.length - 2)
            
            // 應用斜體樣式
            attributedString.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 17), range: contentRange)
            
            // 移除標記符號
            attributedString.deleteCharacters(in: NSRange(location: range.location, length: 1))
            attributedString.deleteCharacters(in: NSRange(location: range.location + range.length - 2, length: 1))
        }
    }
    
    private func parseCode(_ attributedString: NSMutableAttributedString) {
        let string = attributedString.string
        
        // 匹配 `text`
        let codePattern = try! NSRegularExpression(pattern: "`([^`]+)`")
        let matches = codePattern.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        
        // 從後往前處理
        for match in matches.reversed() {
            let range = match.range
            
            // 找到實際內容的範圍（排除標記符號）
            let contentRange = NSRange(location: range.location + 1, length: range.length - 2)
            
            // 應用程式碼樣式
            attributedString.addAttribute(.font, value: UIFont.monospacedSystemFont(ofSize: 17, weight: .regular), range: contentRange)
            attributedString.addAttribute(.backgroundColor, value: UIColor.systemGray6, range: contentRange)
            
            // 移除標記符號
            attributedString.deleteCharacters(in: NSRange(location: range.location, length: 1))
            attributedString.deleteCharacters(in: NSRange(location: range.location + range.length - 2, length: 1))
        }
    }
} 