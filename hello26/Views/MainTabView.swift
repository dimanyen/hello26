//
//  MainTabView.swift
//  hello26
//
//  Created by dmdev on 2025/6/15.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedCharacter: Character? = Character.defaultCharacters.first
    
    var body: some View {
        TabView {
            // 第一個Tab：聊天頁面
            ContentView(selectedCharacter: selectedCharacter)
                .id(selectedCharacter?.id ?? UUID())
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("對話")
                }
            
            // 第二個Tab：角色選擇頁面
            CharacterSelectionView(selectedCharacter: $selectedCharacter)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("角色")
                }
        }
    }
}

#Preview {
    MainTabView()
} 