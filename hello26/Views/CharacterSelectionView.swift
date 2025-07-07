//
//  CharacterSelectionView.swift
//  hello26
//
//  Created by dmdev on 2025/6/15.
//

import SwiftUI

struct CharacterSelectionView: View {
    @Binding var selectedCharacter: Character?
    @State private var characters = Character.defaultCharacters
    @State private var showingChatView = false
    @State private var chatCharacter: Character?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(characters) { character in
                    CharacterRow(
                        character: character,
                        isSelected: selectedCharacter?.id == character.id
                    ) {
                        // 開啟新的對話視窗
                        chatCharacter = character
                        showingChatView = true
                    }
                }
            }
            .navigationTitle("選擇對話角色")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingChatView) {
                if let character = chatCharacter {
                    ChatView(character: character)
                }
            }
        }
    }
}

struct CharacterRow: View {
    let character: Character
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 頭像
                Text(character.avatar)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    // 角色名稱
                    Text(character.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // 角色描述
                    Text(character.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // 對話指示器
                Image(systemName: "message.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// 新的對話視窗
struct ChatView: View {
    let character: Character
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ChatViewModel
    
    init(character: Character) {
        self.character = character
        self._viewModel = StateObject(wrappedValue: ChatViewModel(character: character))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 角色資訊標題列
                HStack(spacing: 12) {
                    Text(character.avatar)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("正在與 \(character.name) 對話")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(character.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                Divider()
                
                // 聊天記錄區域
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    onRetry: message.isError && message.originalPrompt != nil ? {
                                        viewModel.retryMessage(message)
                                    } : nil
                                )
                            }
                            
                            // 串流回覆顯示區域
                            if viewModel.isResponding {
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
                    .onChange(of: viewModel.messages) { oldValue, newValue in
                        if let lastMessage = newValue.last {
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
                            ForEach(viewModel.questions, id: \.title) { question in
                                QuickInputButton(
                                    title: question.title,
                                    action: { viewModel.sendQuickMessage(question.content) }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    HStack(spacing: 12) {
                        TextField("輸入您的問題...", text: $viewModel.inputText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(1...4)
                            .disabled(viewModel.isResponding)
                        
                        Button(action: viewModel.sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isResponding ? Color.gray : Color.blue)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isResponding)
                    }
                    .padding()
                }
            }
            .navigationTitle("與 \(character.name) 對話")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CharacterSelectionView(selectedCharacter: .constant(nil))
} 