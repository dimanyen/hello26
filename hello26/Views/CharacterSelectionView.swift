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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(characters) { character in
                    CharacterRow(
                        character: character,
                        isSelected: selectedCharacter?.id == character.id
                    ) {
                        selectedCharacter = character
                    }
                }
            }
            .navigationTitle("選擇對話角色")
            .navigationBarTitleDisplayMode(.large)
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
                
                // 選擇指示器
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    CharacterSelectionView(selectedCharacter: .constant(nil))
} 