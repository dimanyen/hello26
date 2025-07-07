#!/bin/bash

# iOS 模擬器自動化腳本
# 用於建置和運行 hello26 專案

echo "🚀 開始建置和運行 iOS 模擬器..."

# 設定變數
PROJECT_NAME="hello26"
SCHEME_NAME="hello26"
BUNDLE_ID="com.cathaybk.hello26"
SIMULATOR_NAME="iPhone 16 Pro"
DERIVED_DATA_PATH="/Users/dmdev/Library/Developer/Xcode/DerivedData/${PROJECT_NAME}-bclcuohcuywqlheqxzfltrytjqky"

echo "📱 目標模擬器: $SIMULATOR_NAME"
echo "📦 Bundle ID: $BUNDLE_ID"

# 檢查 Xcode 開發者工具是否正確設定
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 錯誤：xcodebuild 未找到。請確保 Xcode 已正確安裝。"
    exit 1
fi

# 清理之前的建置
echo "🧹 清理之前的建置..."
xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "$SCHEME_NAME" clean

# 建置專案
echo "🔨 建置專案..."
if xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "$SCHEME_NAME" -destination "platform=iOS Simulator,name=$SIMULATOR_NAME,OS=latest" build; then
    echo "✅ 建置成功"
else
    echo "❌ 建置失敗"
    exit 1
fi

# 安裝到模擬器
echo "📦 安裝專案到模擬器..."
if xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "$SCHEME_NAME" -destination "platform=iOS Simulator,name=$SIMULATOR_NAME,OS=latest" install; then
    echo "✅ 安裝成功"
else
    echo "❌ 安裝失敗"
    exit 1
fi

# 檢查是否有模擬器在運行
SIMULATOR_STATUS=$(xcrun simctl list devices | grep "$SIMULATOR_NAME" | grep "Booted")
if [ -z "$SIMULATOR_STATUS" ]; then
    echo "🔄 啟動模擬器..."
    xcrun simctl boot "$SIMULATOR_NAME"
    sleep 3
    echo "📱 開啟模擬器 UI..."
    open -a Simulator
fi

# 安裝 App 到模擬器
echo "📲 安裝 App 到模擬器..."
APP_PATH="${DERIVED_DATA_PATH}/Build/Intermediates.noindex/ArchiveIntermediates/${PROJECT_NAME}/InstallationBuildProductsLocation/Applications/${PROJECT_NAME}.app"

if [ -d "$APP_PATH" ]; then
    if xcrun simctl install booted "$APP_PATH"; then
        echo "✅ App 安裝成功"
    else
        echo "❌ App 安裝失敗"
        exit 1
    fi
else
    echo "❌ 找不到 App 文件: $APP_PATH"
    exit 1
fi

# 啟動 App
echo "🚀 啟動 App..."
if xcrun simctl launch booted "$BUNDLE_ID"; then
    echo "✅ App 啟動成功！"
    echo "🎉 完成！你的 iOS 應用程式現在正在模擬器上運行。"
else
    echo "❌ App 啟動失敗"
    exit 1
fi 