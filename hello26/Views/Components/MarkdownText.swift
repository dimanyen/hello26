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
        
        // 解析標題語法 ### text
        parseHeaders(attributedString)
        
        // 解析數學公式語法 \[ ... \]
        parseMathFormulas(attributedString)
        
        // 解析粗體語法 **text** 或 __text__
        parseBold(attributedString)
        
        // 解析斜體語法 *text* 或 _text_
        parseItalic(attributedString)
        
        // 解析程式碼語法 ```text```
        parseCode(attributedString)
        
        return attributedString
    }
    
    private func parseHeaders(_ attributedString: NSMutableAttributedString) {
        let string = attributedString.string
        
        // 匹配 ### text（三級標題）
        let headerPattern = try! NSRegularExpression(pattern: "^### (.+)$", options: .anchorsMatchLines)
        let matches = headerPattern.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        
        // 從後往前處理，避免索引偏移
        for match in matches.reversed() {
            let range = match.range
            let headerRange = match.range(at: 1) // 標題內容的範圍
            
            // 應用標題樣式
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: headerRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: headerRange)
            
            // 移除 ### 標記符號
            let prefixRange = NSRange(location: range.location, length: 4) // "### "
            attributedString.deleteCharacters(in: prefixRange)
        }
    }
    
    private func parseMathFormulas(_ attributedString: NSMutableAttributedString) {
        let string = attributedString.string
        
        // 匹配 \[ ... \] 數學公式
        let mathPattern = try! NSRegularExpression(pattern: "\\\\\\[([\\s\\S]*?)\\\\\\]")
        let matches = mathPattern.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        
        // 從後往前處理
        for match in matches.reversed() {
            let range = match.range
            let formulaRange = match.range(at: 1) // 公式內容的範圍
            
            // 獲取公式內容並處理 \text{} 語法
            var formulaContent = (string as NSString).substring(with: formulaRange)
            formulaContent = processTextCommands(formulaContent)
            
            // 替換原有內容
            let contentRange = NSRange(location: range.location + 2, length: range.length - 4) // 排除 \[ 和 \]
            attributedString.replaceCharacters(in: contentRange, with: formulaContent)
            
            // 重新計算內容範圍
            let newContentRange = NSRange(location: range.location + 2, length: formulaContent.count)
            
            // 應用數學公式樣式
            attributedString.addAttribute(.font, value: UIFont.monospacedSystemFont(ofSize: 16, weight: .medium), range: newContentRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: newContentRange)
            attributedString.addAttribute(.backgroundColor, value: UIColor.systemGray6.withAlphaComponent(0.3), range: newContentRange)
            
            // 移除 \[ 和 \] 標記符號
            attributedString.deleteCharacters(in: NSRange(location: range.location, length: 2))
            attributedString.deleteCharacters(in: NSRange(location: range.location + formulaContent.count, length: 2))
        }
    }
    
    private func processTextCommands(_ formula: String) -> String {
        var processedFormula = formula
        
        // 處理 \text{內容} 語法
        let textPattern = try! NSRegularExpression(pattern: "\\\\text\\{([^}]+)\\}")
        let textRange = NSRange(location: 0, length: processedFormula.count)
        
        processedFormula = textPattern.stringByReplacingMatches(
            in: processedFormula,
            options: [],
            range: textRange,
            withTemplate: "$1"  // 只保留花括號內的內容
        )
        
        // 處理 \boxed{內容} 語法
        let boxedPattern = try! NSRegularExpression(pattern: "\\\\boxed\\{([^}]+)\\}")
        let boxedRange = NSRange(location: 0, length: processedFormula.count)
        
        processedFormula = boxedPattern.stringByReplacingMatches(
            in: processedFormula,
            options: [],
            range: boxedRange,
            withTemplate: "[$1]"  // 用方括號包圍內容來表示框住的效果
        )
        
        // 處理空格語法
        processedFormula = processedFormula.replacingOccurrences(of: "\\,", with: " ")      // 小空格
        
        // 處理各種數學符號
        processedFormula = processedFormula.replacingOccurrences(of: "\\times", with: "×")  // 乘法
        processedFormula = processedFormula.replacingOccurrences(of: "\\div", with: "÷")    // 除法
        processedFormula = processedFormula.replacingOccurrences(of: "\\cdot", with: "·")   // 中點乘法
        processedFormula = processedFormula.replacingOccurrences(of: "\\pm", with: "±")     // 正負號
        processedFormula = processedFormula.replacingOccurrences(of: "\\mp", with: "∓")     // 負正號
        processedFormula = processedFormula.replacingOccurrences(of: "\\le", with: "≤")     // 小於等於
        processedFormula = processedFormula.replacingOccurrences(of: "\\leq", with: "≤")    // 小於等於（另一種寫法）
        processedFormula = processedFormula.replacingOccurrences(of: "\\ge", with: "≥")     // 大於等於
        processedFormula = processedFormula.replacingOccurrences(of: "\\geq", with: "≥")    // 大於等於（另一種寫法）
        processedFormula = processedFormula.replacingOccurrences(of: "\\ne", with: "≠")     // 不等於
        processedFormula = processedFormula.replacingOccurrences(of: "\\neq", with: "≠")    // 不等於（另一種寫法）
        processedFormula = processedFormula.replacingOccurrences(of: "\\approx", with: "≈") // 約等於
        processedFormula = processedFormula.replacingOccurrences(of: "\\sum", with: "Σ")    // 求和
        processedFormula = processedFormula.replacingOccurrences(of: "\\prod", with: "Π")   // 連乘
        processedFormula = processedFormula.replacingOccurrences(of: "\\int", with: "∫")    // 積分
        processedFormula = processedFormula.replacingOccurrences(of: "\\infty", with: "∞")  // 無窮大
        processedFormula = processedFormula.replacingOccurrences(of: "\\sqrt", with: "√")   // 根號
        processedFormula = processedFormula.replacingOccurrences(of: "\\bullet", with: "•") // 實心圓點
        
        // 處理希臘字母
        processedFormula = processedFormula.replacingOccurrences(of: "\\alpha", with: "α")
        processedFormula = processedFormula.replacingOccurrences(of: "\\beta", with: "β")
        processedFormula = processedFormula.replacingOccurrences(of: "\\gamma", with: "γ")
        processedFormula = processedFormula.replacingOccurrences(of: "\\delta", with: "δ")
        processedFormula = processedFormula.replacingOccurrences(of: "\\epsilon", with: "ε")
        processedFormula = processedFormula.replacingOccurrences(of: "\\theta", with: "θ")
        processedFormula = processedFormula.replacingOccurrences(of: "\\lambda", with: "λ")
        processedFormula = processedFormula.replacingOccurrences(of: "\\mu", with: "μ")
        processedFormula = processedFormula.replacingOccurrences(of: "\\pi", with: "π")
        processedFormula = processedFormula.replacingOccurrences(of: "\\sigma", with: "σ")
        processedFormula = processedFormula.replacingOccurrences(of: "\\phi", with: "φ")
        processedFormula = processedFormula.replacingOccurrences(of: "\\omega", with: "ω")
        
        return processedFormula
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
        
        // 匹配 ```text ... ```（三個反引號包圍的程式碼區塊）
        let codePattern = try! NSRegularExpression(pattern: "```([\\s\\S]*?)```", options: [])
        let matches = codePattern.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        
        // 從後往前處理
        for match in matches.reversed() {
            let range = match.range
            let codeRange = match.range(at: 1) // 程式碼內容的範圍
            
            // 獲取程式碼內容
            let codeContent = (string as NSString).substring(with: codeRange)
            
            // 替換原有內容（移除三個反引號）
            let contentRange = NSRange(location: range.location + 3, length: range.length - 6) // 排除前後的 ```
            attributedString.replaceCharacters(in: contentRange, with: codeContent)
            
            // 重新計算內容範圍
            let newContentRange = NSRange(location: range.location + 3, length: codeContent.count)
            
            // 應用程式碼樣式
            attributedString.addAttribute(.font, value: UIFont.monospacedSystemFont(ofSize: 15, weight: .regular), range: newContentRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: newContentRange)
            attributedString.addAttribute(.backgroundColor, value: UIColor.systemGray6.withAlphaComponent(0.8), range: newContentRange)
            
            // 移除前後的三個反引號標記符號
            attributedString.deleteCharacters(in: NSRange(location: range.location, length: 3))
            attributedString.deleteCharacters(in: NSRange(location: range.location + codeContent.count, length: 3))
        }
    }
} 