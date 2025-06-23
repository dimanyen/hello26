# Hello26 - iOS 26 FoundationModels 測試專案

[English](#english) | [繁體中文](#繁體中文)

---

## 繁體中文

### 📱 專案概述

Hello26 是一個專門針對 iOS 26 的 FoundationModels 框架進行測試和演示的 SwiftUI 應用程式。本專案展示了如何使用 Apple 最新的語言模型整合技術來建立智能聊天助手，採用現代化的 MVVM 架構設計。

🎥 **[觀看 Demo 影片](https://youtube.com/shorts/qTh2TfwU1z4?feature=share)**

### 🚀 主要功能

- **智能聊天助手**：基於 FoundationModels 的 LanguageModelSession 實現
- **串流回應**：即時顯示 AI 回應，提供流暢的對話體驗
- **完整錯誤處理**：智能錯誤分類系統，支援 6 種 GenerationError 類型處理
- **重試機制**：支援錯誤重試，保存原始提示詞用於重新發送
- **快速輸入**：預設問題按鈕，方便測試不同場景
- **效能監控**：顯示首次回應時間和字元傳輸速度統計
- **Markdown 支援**：完整的 Markdown 語法渲染，包含數學公式支援
- **MVVM 架構**：採用現代化的 SwiftUI + MVVM 設計模式

### 🛠 技術特色

#### 架構設計
- **MVVM 模式**：清晰的架構分層，便於維護和擴展
- **模組化設計**：獨立的 Models、Views、ViewModels 和 Extensions
- **元件化 UI**：可重用的 UI 元件庫

#### FoundationModels 整合
- 使用 `LanguageModelSession` 進行對話管理
- 支援串流回應處理 (`streamResponse`)
- 完整的錯誤處理機制和重試功能

#### 錯誤處理系統
- **GenerationError 分類**：處理 6 種主要錯誤類型
  - `assetsUnavailable`：語言模型資源不可用
  - `decodingFailure`：回應解析失敗
  - `exceededContextWindowSize`：內容超過處理限制
  - `guardrailViolation`：觸發安全保護機制
  - `unsupportedGuide`：不支援的生成指引
  - `unsupportedLanguageOrLocale`：不支援的語言或地區設定
- **智能分類備用**：基於錯誤描述的智能分類系統
- **Swift 6 相容**：使用 `@unknown default` 確保未來相容性
- **錯誤統計功能**：在 Debug 模式下顯示詳細錯誤統計

#### 使用者介面
- **現代化設計**：使用 SwiftUI 建立美觀的聊天介面
- **Markdown 完整支援**：
  - 標題語法 (`### 標題`)
  - 粗體語法 (`**粗體**` 或 `__粗體__`)
  - 斜體語法 (`*斜體*` 或 `_斜體_`)
  - 程式碼語法 (`` `程式碼` ``)
  - 數學公式語法 (`\[ 公式 \]`)
  - 希臘字母和數學符號支援
- **響應式佈局**：適配不同螢幕尺寸的對話介面
- **流暢動畫**：訊息發送和接收的平滑動畫效果
- **自定義圓角**：支援指定角落的圓角設計

#### 效能監控
- **首次回應時間**：記錄 AI 開始回應的延遲時間
- **字元傳輸速度**：計算回應生成的字元/秒速度
- **即時顯示**：在訊息氣泡下方顯示效能資訊

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

#### Markdown 測試
- 測試標題、粗體、斜體語法
- 測試數學公式渲染功能
- 測試程式碼塊顯示效果

### 🔧 開發者功能

#### Debug 模式
在 Debug 模式下，應用程式會顯示：
- 詳細的錯誤統計資訊
- 完整的錯誤日誌記錄
- 效能統計資料和分析

#### 錯誤統計範例
```
錯誤統計
Assets Unavailable: 2
Guardrail Violation: 1
Network Error: 3
Context Window Exceeded: 1
```

### 📁 專案結構

```
hello26/
├── hello26/
│   ├── ContentView.swift              # 主要 UI 介面
│   ├── hello26App.swift               # 應用程式入口
│   ├── questions.json                 # 預設問題資料
│   │
│   ├── Models/                        # 資料模型
│   │   ├── ChatMessage.swift          # 聊天訊息模型
│   │   └── Question.swift             # 問題資料模型
│   │
│   ├── ViewModels/                    # 視圖模型（MVVM）
│   │   └── ChatViewModel.swift        # 聊天邏輯控制器
│   │
│   ├── Views/                         # 視圖元件
│   │   └── Components/
│   │       ├── MarkdownText.swift     # Markdown 渲染元件
│   │       ├── MessageBubble.swift    # 訊息氣泡元件
│   │       └── QuickInputButton.swift # 快速輸入按鈕
│   │
│   ├── Extensions/                    # 擴展功能
│   │   └── View+Extensions.swift      # SwiftUI View 擴展
│   │
│   └── Assets.xcassets/               # 應用程式資源
│       ├── AccentColor.colorset/
│       └── AppIcon.appiconset/
│
├── hello26.xcodeproj/                 # Xcode 專案檔案
└── README.md                          # 專案說明文件
```

### 🎨 UI 元件說明

#### MessageBubble
- 支援用戶和 AI 訊息的不同樣式
- 內建 Markdown 渲染功能
- 錯誤重試按鈕整合
- 效能資訊顯示

#### MarkdownText
- 完整的 Markdown 語法支援
- 數學公式渲染（LaTeX 語法）
- 自定義樣式和顏色主題
- 希臘字母和特殊符號支援

#### QuickInputButton
- 快速問題選擇功能
- 自適應寬度設計
- 一致的視覺風格

### 🔍 核心功能詳解

#### 聊天流程
1. **輸入處理**：用戶輸入或快速選擇問題
2. **訊息建立**：建立 ChatMessage 物件並加入對話列表
3. **串流回應**：呼叫 LanguageModelSession 開始串流
4. **即時更新**：即時更新 UI 顯示 AI 回應內容
5. **效能統計**：記錄回應時間和字元傳輸速度
6. **錯誤處理**：智能錯誤分類和用戶友善提示

#### 錯誤重試機制
- 保存原始提示詞
- 移除錯誤訊息
- 重新發起請求
- 維持對話連續性

### 🐛 已知問題

- FoundationModels 需要 iOS 26 或更新版本
- 某些功能可能需要在實體裝置上測試
- 網路連線品質會影響串流回應速度
- 複雜數學公式的渲染可能需要進一步優化

### 🔄 更新紀錄

- **v1.1**：新增 MVVM 架構支援
- **v1.2**：完整 Markdown 和數學公式渲染
- **v1.3**：錯誤統計和重試機制
- **v1.4**：效能監控和優化

### 🤝 貢獻

歡迎提交 Issue 和 Pull Request 來改善這個專案！

### 📄 授權

本專案採用 MIT 授權條款。

---

## English

### 📱 Project Overview

Hello26 is a SwiftUI application specifically designed to test and demonstrate the FoundationModels framework for iOS 26. This project showcases how to use Apple's latest language model integration technology to build an intelligent chat assistant with modern MVVM architecture.

🎥 **[Watch Demo Video](https://www.youtube.com/shorts/x9zVY3jQ34w)**

### 🚀 Key Features

- **Intelligent Chat Assistant**: Implemented using FoundationModels' LanguageModelSession
- **Streaming Responses**: Real-time AI response display for smooth conversation experience
- **Complete Error Handling**: Intelligent error classification system supporting 6 GenerationError types
- **Retry Mechanism**: Support for error retry with original prompt preservation
- **Quick Input**: Predefined question buttons for easy testing of different scenarios
- **Performance Monitoring**: Display first response time and character transmission speed statistics
- **Markdown Support**: Complete Markdown syntax rendering with mathematical formula support
- **MVVM Architecture**: Modern SwiftUI + MVVM design pattern implementation

### 🛠 Technical Features

#### Architecture Design
- **MVVM Pattern**: Clear architectural layering for easy maintenance and extension
- **Modular Design**: Independent Models, Views, ViewModels, and Extensions
- **Component-based UI**: Reusable UI component library

#### FoundationModels Integration
- Uses `LanguageModelSession` for conversation management
- Supports streaming response processing (`streamResponse`)
- Complete error handling mechanism with retry functionality

#### Error Handling System
- **GenerationError Classification**: Handles 6 main error types
  - `assetsUnavailable`: Language model resources unavailable
  - `decodingFailure`: Response parsing failure
  - `exceededContextWindowSize`: Content exceeds processing limits
  - `guardrailViolation`: Safety protection mechanism triggered
  - `unsupportedGuide`: Unsupported generation guide
  - `unsupportedLanguageOrLocale`: Unsupported language or locale settings
- **Intelligent Classification Backup**: Smart classification system based on error descriptions
- **Swift 6 Compatibility**: Uses `@unknown default` to ensure future compatibility
- **Error Statistics**: Detailed error statistics display in Debug mode

#### User Interface
- **Modern Design**: Beautiful chat interface built with SwiftUI
- **Complete Markdown Support**:
  - Header syntax (`### Header`)
  - Bold syntax (`**bold**` or `__bold__`)
  - Italic syntax (`*italic*` or `_italic_`)
  - Code syntax (`` `code` ``)
  - Mathematical formula syntax (`\[ formula \]`)
  - Greek letters and mathematical symbols support
- **Responsive Layout**: Chat interface adapting to different screen sizes
- **Smooth Animations**: Fluid animations for message sending and receiving
- **Custom Corner Radius**: Support for specific corner radius design

#### Performance Monitoring
- **First Response Time**: Records AI response start delay
- **Character Transmission Speed**: Calculates response generation characters/second
- **Real-time Display**: Shows performance information below message bubbles

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

#### Markdown Testing
- Test header, bold, italic syntax
- Test mathematical formula rendering
- Test code block display effects

### 🔧 Developer Features

#### Debug Mode
In Debug mode, the application displays:
- Detailed error statistics information
- Complete error logging
- Performance statistics and analysis

#### Error Statistics Example
```
Error Statistics
Assets Unavailable: 2
Guardrail Violation: 1
Network Error: 3
Context Window Exceeded: 1
```

### 📁 Project Structure

```
hello26/
├── hello26/
│   ├── ContentView.swift              # Main UI interface
│   ├── hello26App.swift               # Application entry point
│   ├── questions.json                 # Predefined question data
│   │
│   ├── Models/                        # Data models
│   │   ├── ChatMessage.swift          # Chat message model
│   │   └── Question.swift             # Question data model
│   │
│   ├── ViewModels/                    # View models (MVVM)
│   │   └── ChatViewModel.swift        # Chat logic controller
│   │
│   ├── Views/                         # View components
│   │   └── Components/
│   │       ├── MarkdownText.swift     # Markdown rendering component
│   │       ├── MessageBubble.swift    # Message bubble component
│   │       └── QuickInputButton.swift # Quick input button
│   │
│   ├── Extensions/                    # Extension functionality
│   │   └── View+Extensions.swift      # SwiftUI View extensions
│   │
│   └── Assets.xcassets/               # Application resources
│       ├── AccentColor.colorset/
│       └── AppIcon.appiconset/
│
├── hello26.xcodeproj/                 # Xcode project files
└── README.md                          # Project documentation
```

### 🎨 UI Component Description

#### MessageBubble
- Support for different styles of user and AI messages
- Built-in Markdown rendering functionality
- Error retry button integration
- Performance information display

#### MarkdownText
- Complete Markdown syntax support
- Mathematical formula rendering (LaTeX syntax)
- Custom styles and color themes
- Greek letters and special symbols support

#### QuickInputButton
- Quick question selection functionality
- Adaptive width design
- Consistent visual style

### 🔍 Core Functionality Details

#### Chat Flow
1. **Input Processing**: User input or quick question selection
2. **Message Creation**: Create ChatMessage object and add to conversation list
3. **Streaming Response**: Call LanguageModelSession to start streaming
4. **Real-time Updates**: Update UI in real-time to display AI response content
5. **Performance Statistics**: Record response time and character transmission speed
6. **Error Handling**: Intelligent error classification and user-friendly prompts

#### Error Retry Mechanism
- Save original prompt
- Remove error message
- Restart request
- Maintain conversation continuity

### 🐛 Known Issues

- FoundationModels requires iOS 26 or later
- Some features may need to be tested on physical devices
- Network connection quality affects streaming response speed
- Complex mathematical formula rendering may need further optimization

### 🔄 Update Log

- **v1.1**: Added MVVM architecture support
- **v1.2**: Complete Markdown and mathematical formula rendering
- **v1.3**: Error statistics and retry mechanism
- **v1.4**: Performance monitoring and optimization

### 🤝 Contributing

Issues and Pull Requests are welcome to improve this project!

### 📄 License

This project is licensed under the MIT License. 
