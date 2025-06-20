# Hello26 - iOS 26 FoundationModels 測試專案

[English](#english) | [繁體中文](#繁體中文)

---

## 繁體中文

### 📱 專案概述

Hello26 是一個專門針對 iOS 26 的 FoundationModels 框架進行測試和演示的 SwiftUI 應用程式。本專案展示了如何使用 Apple 最新的語言模型整合技術來建立智能聊天助手。

🎥 **[觀看 Demo 影片](https://www.youtube.com/shorts/x9zVY3jQ34w)**

### 🚀 主要功能

- **智能聊天助手**：基於 FoundationModels 的 LanguageModelSession 實現
- **串流回應**：即時顯示 AI 回應，提供流暢的對話體驗
- **錯誤處理**：完整的錯誤分類和友善錯誤訊息系統
- **重試機制**：支援錯誤重試，保存原始提示詞
- **快速輸入**：預設問題按鈕，方便測試不同場景
- **效能監控**：顯示回應時間和字元速度統計
- **開發者模式**：Debug 模式下顯示錯誤統計資訊

### 🛠 技術特色

#### FoundationModels 整合
- 使用 `LanguageModelSession` 進行對話管理
- 支援串流回應處理
- 完整的錯誤處理機制

#### 錯誤處理系統
- **GenerationError 分類**：處理 6 種主要錯誤類型
  - `assetsUnavailable`：資源不可用
  - `decodingFailure`：回應解析失敗
  - `exceededContextWindowSize`：內容超過處理限制
  - `guardrailViolation`：觸發安全保護機制
  - `unsupportedGuide`：不支援的生成指引
  - `unsupportedLanguageOrLocale`：不支援的語言或地區設定
- **智能分類備用**：基於錯誤描述的智能分類系統
- **Swift 6 相容**：使用 `@unknown default` 確保未來相容性

#### 使用者介面
- **現代化設計**：使用 SwiftUI 建立美觀的聊天介面
- **Markdown 支援**：支援粗體、斜體、程式碼等格式
- **響應式佈局**：適配不同螢幕尺寸
- **動畫效果**：流暢的訊息動畫和載入效果

### 📋 系統需求

- **iOS 版本**：iOS 26.0 或更新版本
- **Xcode 版本**：Xcode 16.0 或更新版本
- **Swift 版本**：Swift 6.0
- **裝置**：iPhone 或 iPad（支援 FoundationModels）

### 🚀 快速開始

1. **克隆專案**
   ```bash
   git clone [repository-url]
   cd hello26
   ```

2. **開啟專案**
   ```bash
   open hello26.xcodeproj
   ```

3. **選擇目標裝置**
   - 選擇支援 iOS 26 的模擬器或實體裝置
   - 確保裝置支援 FoundationModels

4. **建置和執行**
   - 按 `Cmd + R` 建置並執行專案
   - 或點擊 Xcode 的執行按鈕

### 🧪 測試功能

#### 預設測試問題
專案包含 4 個預設的測試問題：

1. **邏輯推理測試**：國際象棋騎士路徑問題
2. **程式除錯測試**：Python 程式碼除錯
3. **創意思考測試**：AI + BCI 產品構想
4. **數學能力測試**：投資報酬率計算

#### 錯誤測試
- 嘗試輸入過長的內容測試 `exceededContextWindowSize`
- 使用不當內容測試 `guardrailViolation`
- 測試網路連線中斷的錯誤處理

### 🔧 開發者功能

#### Debug 模式
在 Debug 模式下，應用程式會顯示：
- 錯誤統計資訊
- 詳細的錯誤日誌
- 效能統計資料

#### 錯誤統計
```
錯誤統計
Assets Unavailable: 2
Guardrail Violation: 1
Network Error: 3
```

### 📁 專案結構

```
hello26/
├── hello26/
│   ├── ContentView.swift          # 主要 UI 和邏輯
│   ├── hello26App.swift          # 應用程式入口
│   └── questions.json            # 預設問題資料
├── hello26.xcodeproj/            # Xcode 專案檔案
└── README.md                     # 專案說明文件
```

### 🐛 已知問題

- FoundationModels 需要 iOS 26 或更新版本
- 某些功能可能需要在支援的裝置上測試
- 網路連線品質會影響回應速度

### 🤝 貢獻

歡迎提交 Issue 和 Pull Request 來改善這個專案！

### 📄 授權

本專案採用 MIT 授權條款。

---

## English

### 📱 Project Overview

Hello26 is a SwiftUI application specifically designed to test and demonstrate the FoundationModels framework for iOS 26. This project showcases how to use Apple's latest language model integration technology to build an intelligent chat assistant.

🎥 **[Watch Demo Video](https://www.youtube.com/shorts/x9zVY3jQ34w)**

### �� Key Features

- **Intelligent Chat Assistant**: Implemented using FoundationModels' LanguageModelSession
- **Streaming Responses**: Real-time AI response display for smooth conversation experience
- **Error Handling**: Comprehensive error classification and user-friendly error message system
- **Retry Mechanism**: Support for error retry with original prompt preservation
- **Quick Input**: Predefined question buttons for easy testing of different scenarios
- **Performance Monitoring**: Display response time and character speed statistics
- **Developer Mode**: Error statistics display in Debug mode

### 🛠 Technical Features

#### FoundationModels Integration
- Uses `LanguageModelSession` for conversation management
- Supports streaming response processing
- Complete error handling mechanism

#### Error Handling System
- **GenerationError Classification**: Handles 6 main error types
  - `assetsUnavailable`: Resources unavailable
  - `decodingFailure`: Response parsing failure
  - `exceededContextWindowSize`: Content exceeds processing limits
  - `guardrailViolation`: Safety protection mechanism triggered
  - `unsupportedGuide`: Unsupported generation guide
  - `unsupportedLanguageOrLocale`: Unsupported language or locale settings
- **Intelligent Classification Backup**: Smart classification system based on error descriptions
- **Swift 6 Compatibility**: Uses `@unknown default` to ensure future compatibility

#### User Interface
- **Modern Design**: Beautiful chat interface built with SwiftUI
- **Markdown Support**: Supports bold, italic, code, and other formats
- **Responsive Layout**: Adapts to different screen sizes
- **Animation Effects**: Smooth message animations and loading effects

### 📋 System Requirements

- **iOS Version**: iOS 26.0 or later
- **Xcode Version**: Xcode 16.0 or later
- **Swift Version**: Swift 6.0
- **Device**: iPhone or iPad (with FoundationModels support)

### 🚀 Quick Start

1. **Clone the Project**
   ```bash
   git clone [repository-url]
   cd hello26
   ```

2. **Open the Project**
   ```bash
   open hello26.xcodeproj
   ```

3. **Select Target Device**
   - Choose a simulator or physical device supporting iOS 26
   - Ensure the device supports FoundationModels

4. **Build and Run**
   - Press `Cmd + R` to build and run the project
   - Or click the run button in Xcode

### 🧪 Testing Features

#### Predefined Test Questions
The project includes 4 predefined test questions:

1. **Logic Reasoning Test**: Chess knight path problem
2. **Code Debugging Test**: Python code debugging
3. **Creative Thinking Test**: AI + BCI product concept
4. **Mathematical Ability Test**: Investment return calculation

#### Error Testing
- Try inputting overly long content to test `exceededContextWindowSize`
- Use inappropriate content to test `guardrailViolation`
- Test error handling for network connection interruptions

### 🔧 Developer Features

#### Debug Mode
In Debug mode, the application displays:
- Error statistics information
- Detailed error logs
- Performance statistics

#### Error Statistics
```
Error Statistics
Assets Unavailable: 2
Guardrail Violation: 1
Network Error: 3
```

### 📁 Project Structure

```
hello26/
├── hello26/
│   ├── ContentView.swift          # Main UI and logic
│   ├── hello26App.swift          # Application entry point
│   └── questions.json            # Predefined question data
├── hello26.xcodeproj/            # Xcode project files
└── README.md                     # Project documentation
```

### 🐛 Known Issues

- FoundationModels requires iOS 26 or later
- Some features may need to be tested on supported devices
- Network connection quality affects response speed

### 🤝 Contributing

Issues and Pull Requests are welcome to improve this project!

### 📄 License

This project is licensed under the MIT License. 