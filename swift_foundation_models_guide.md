# Swift FoundationModels 框架完整指南

## 概述

FoundationModels 是 Apple 推出的 Swift 框架，專為整合語言模型到 iOS 應用程式中而設計。本框架提供了簡潔的 API 來處理語言模型對話、結構化資料生成、工具調用和串流處理等功能。

## 基本使用

### 簡單對話

```swift
import FoundationModels
import Playgrounds

#Playground {
    let session = LanguageModelSession()
    let response = try await session.respond(to: "What's a good name for a trip to Japan? Respond only with a title")
}
```

### 批量處理

```swift
import FoundationModels
import Playgrounds

#Playground {
    let session = LanguageModelSession()
    for landmark in ModelData.shared.landmarks {
        let response = try await session.respond(to: "What's a good name for a trip to \(landmark.name)? Respond only with a title")
    }
}
```

## 結構化資料生成 (@Generable)

### 基本 Generable 結構

`@Generable` 屬性包裝器允許您定義結構化的回應格式：

```swift
@Generable
struct SearchSuggestions {
    @Guide(description: "A list of suggested search terms", .count(4))
    var searchTerms: [String]
}
```

### 使用 Generable 類型生成回應

```swift
let prompt = """
    Generate a list of suggested search terms for an app about visiting famous landmarks.
    """

let response = try await session.respond(
    to: prompt,
    generating: SearchSuggestions.self
)

print(response.content)
```

### 複合 Generable 類型

您可以組合多個 Generable 類型來創建複雜的資料結構：

```swift
@Generable struct Itinerary {
    var destination: String
    var days: Int
    var budget: Float
    var rating: Double
    var requiresVisa: Bool
    var activities: [String]
    var emergencyContact: Person
    var relatedItineraries: [Itinerary]
}
```

## 串流處理

### PartiallyGenerated 類型

```swift
@Generable struct Itinerary {
    var name: String
    var days: [Day]
}
```

### 串流部分生成

```swift
let stream = session.streamResponse(
    to: "Craft a 3-day itinerary to Mt. Fuji.",
    generating: Itinerary.self
)

for try await partial in stream {
    print(partial)
}
```

### SwiftUI 中的串流視圖

```swift
struct ItineraryView: View {
    let session: LanguageModelSession
    let dayCount: Int
    let landmarkName: String
  
    @State
    private var itinerary: Itinerary.PartiallyGenerated?
  
    var body: some View {
        //...
        Button("Start") {
            Task {
                do {
                    let prompt = """
                        Generate a \(dayCount) itinerary \
                        to \(landmarkName).
                        """
                  
                    let stream = session.streamResponse(
                        to: prompt,
                        generating: Itinerary.self
                    )
                  
                    for try await partial in stream {
                        self.itinerary = partial
                    }
                } catch {
                    print(error)  
                }
            }
        }
    }
}
```

## 重要事項：屬性順序

在 `@Generable` 結構中，屬性的順序很重要。模型會按照定義的順序生成資料：

```swift
@Generable struct Itinerary {
  
  @Guide(description: "Plans for each day")
  var days: [DayPlan]
  
  @Guide(description: "A brief summary of plans")
  var summary: String
}
```

## 工具 (Tools)

### 定義工具

```swift
import WeatherKit
import CoreLocation
import FoundationModels

struct GetWeatherTool: Tool {
    let name = "getWeather"
    let description = "Retrieve the latest weather information for a city"

    @Generable
    struct Arguments {
        @Guide(description: "The city to fetch the weather for")
        var city: String
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        let places = try await CLGeocoder().geocodeAddressString(arguments.city)
        let weather = try await WeatherService.shared.weather(for: places.first!.location!)
        let temperature = weather.currentWeather.temperature.value

        let content = GeneratedContent(properties: ["temperature": temperature])
        let output = ToolOutput(content)

        // 或者如果您的工具輸出是自然語言：
        // let output = ToolOutput("\(arguments.city)'s temperature is \(temperature) degrees.")

        return output
    }
}
```

### 將工具附加到會話

```swift
let session = LanguageModelSession(
    tools: [GetWeatherTool()],
    instructions: "Help the user with weather forecasts."
)

let response = try await session.respond(
    to: "What is the temperature in Cupertino?"
)

print(response.content)
// It's 71˚F in Cupertino!
```

## 會話管理

### 自訂指令

```swift
let session = LanguageModelSession(
    instructions: """
        You are a helpful assistant who always \
        responds in rhyme.
        """
)
```

### 多輪對話

```swift
let session = LanguageModelSession()

let firstHaiku = try await session.respond(to: "Write a haiku about fishing")
print(firstHaiku.content)
// Silent waters gleam,
// Casting lines in morning mist—
// Hope in every cast.

let secondHaiku = try await session.respond(to: "Do another one about golf")
print(secondHaiku.content)
// Silent morning dew,
// Caddies guide with gentle words—
// Paths of patience tread.

print(session.transcript) // (Prompt) Write a haiku about fishing
// (Response) Silent waters gleam...
// (Prompt) Do another one about golf
// (Response) Silent morning dew...
```

### 處理回應狀態

```swift
import SwiftUI
import FoundationModels

struct HaikuView: View {

    @State
    private var session = LanguageModelSession()

    @State
    private var haiku: String?

    var body: some View {
        if let haiku {
            Text(haiku)
        }
        Button("Go!") {
            Task {
                haiku = try await session.respond(
                    to: "Write a haiku about something you haven't yet"
                ).content
            }
        }
        // 基於 `isResponding` 控制按鈕狀態
        .disabled(session.isResponding)
    }
}
```

## 內建用例

### 使用內建用例

```swift
let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging)
)
```

### 內容標記用例 - 基本使用

```swift
@Generable
struct Result {
    let topics: [String]
}

let session = LanguageModelSession(model: SystemLanguageModel(useCase: .contentTagging))
let response = try await session.respond(to: ..., generating: Result.self)
```

### 內容標記用例 - 進階使用

```swift
@Generable
struct Top3ActionEmotionResult {
    @Guide(.maximumCount(3))
    let actions: [String]
    @Guide(.maximumCount(3))
    let emotions: [String]
}

let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging),
    instructions: "Tag the 3 most important actions and emotions in the given input text."
)
let response = try await session.respond(to: ..., generating: Top3ActionEmotionResult.self)
```

## 可用性檢查

```swift
struct AvailabilityExample: View {
    private let model = SystemLanguageModel.default

    var body: some View {
        switch model.availability {
        case .available:
            Text("Model is available").foregroundStyle(.green)
        case .unavailable(let reason):
            Text("Model is unavailable").foregroundStyle(.red)
            Text("Reason: \(reason)")
        }
    }
}
```

## 回饋機制

### 編碼回饋附件資料結構

```swift
let feedback = LanguageModelFeedbackAttachment(
  input: [
    // ...
  ],
  output: [
    // ...
  ],
  sentiment: .negative,
  issues: [
    LanguageModelFeedbackAttachment.Issue(
      category: .incorrect,
      explanation: "..."
    )
  ],
  desiredOutputExamples: [
    [
      // ...
    ]
  ]
)
let data = try JSONEncoder().encode(feedback)
```

## 最佳實踐

1. **屬性順序**：在 `@Generable` 結構中，確保屬性按照您希望模型生成的順序排列。

2. **錯誤處理**：始終使用適當的錯誤處理機制，特別是在處理非同步操作時。

3. **狀態管理**：使用 `isResponding` 屬性來管理用戶介面狀態，避免重複請求。

4. **可用性檢查**：在使用模型之前，檢查其可用性狀態。

5. **串流處理**：對於長時間的生成任務，使用串流處理來提供更好的用戶體驗。

6. **工具設計**：設計工具時，確保參數結構清晰且有適當的描述。

## 結論

FoundationModels 框架為 iOS 開發者提供了強大且易用的語言模型整合能力。通過其簡潔的 API 設計，開發者可以輕鬆地在應用程式中實現對話、結構化資料生成、工具調用等功能，為用戶提供更智能的應用體驗。