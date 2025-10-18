//
//  EmojiPickerView.swift
//  MoodSprout
//
//  Created by Levi on 9/24/25.
//

import SwiftUI

struct MoodPickerView: View {
    var onPickPredefined: (MoodType) -> Void
    var onPickCustom: (CustomMood) -> Void
    var moodImages: [String: Data]
    var customMoods: [CustomMood]
    var onCreateCustomMood: (CustomMood) -> Void
    var currentCustomMoodCount: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMoodType: MoodType?
    @State private var selectedCustomMoodId: UUID?
    @State private var showCustomMoodCreator: Bool = false

    private let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("How are you feeling today?")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.top)
                
                // Mood Grid
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Predefined Moods Section
                        PredefinedMoodsSection(
                            selectedMoodType: $selectedMoodType,
                            selectedCustomMoodId: $selectedCustomMoodId,
                            onPickPredefined: onPickPredefined,
                            moodImages: moodImages,
                            columns: columns
                        )
                        
                        // Custom Moods Section
                        CustomMoodsSection(
                            customMoods: customMoods,
                            selectedMoodType: $selectedMoodType,
                            selectedCustomMoodId: $selectedCustomMoodId,
                            onPickCustom: onPickCustom,
                            columns: columns,
                            currentCustomMoodCount: currentCustomMoodCount,
                            onTapAdd: {
                                if currentCustomMoodCount < 10 {
                                    showCustomMoodCreator = true
                                }
                            }
                        )
                        
                    }
                    .padding(.top)
                }
                
                Spacer()
            }
            .navigationTitle("Mood Tracker")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showCustomMoodCreator) {
                CustomMoodCreatorView(
                    onSave: { customMood in
                        onCreateCustomMood(customMood)
                    },
                    currentCustomMoodCount: currentCustomMoodCount
                )
            }
        }
    }
}

// MARK: - Predefined Moods Section
struct PredefinedMoodsSection: View {
    @Binding var selectedMoodType: MoodType?
    @Binding var selectedCustomMoodId: UUID?
    var onPickPredefined: (MoodType) -> Void
    var moodImages: [String: Data]
    let columns: [GridItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Default Moods")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(MoodType.allCases, id: \.self) { mood in
                    PredefinedMoodButton(
                        mood: mood,
                        isSelected: selectedMoodType == mood,
                        moodImages: moodImages,
                        onTap: {
                            selectedMoodType = mood
                            selectedCustomMoodId = nil
                            onPickPredefined(mood)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Predefined Mood Button
struct PredefinedMoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    var moodImages: [String: Data]
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                SupabaseImageView(
                    imageName: mood.imageName,
                    fallbackSystemImage: "face.smiling",
                    imageData: moodImages[mood.imageName]
                )
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                )
                
                Text(mood.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Moods Section
struct CustomMoodsSection: View {
    let customMoods: [CustomMood]
    @Binding var selectedMoodType: MoodType?
    @Binding var selectedCustomMoodId: UUID?
    var onPickCustom: (CustomMood) -> Void
    let columns: [GridItem]
    let currentCustomMoodCount: Int
    var onTapAdd: () -> Void
    
    var body: some View {
        if !customMoods.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Custom Moods")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    if currentCustomMoodCount < 10 {
                        AddCustomMoodTile(onTap: onTapAdd)
                    }
                    ForEach(customMoods) { mood in
                        CustomMoodButton(
                            mood: mood,
                            isSelected: selectedCustomMoodId == mood.id,
                            onTap: {
                                selectedMoodType = nil
                                selectedCustomMoodId = mood.id
                                onPickCustom(mood)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Custom Mood Button
struct CustomMoodButton: View {
    let mood: CustomMood
    let isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                if let data = mood.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } else {
                    Text(mood.emoji)
                        .font(.system(size: 40))
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color(hex: mood.color).opacity(0.2))
                        )
                }
                
                Text(mood.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: mood.color).opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(hex: mood.color) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Custom Mood Tile
struct AddCustomMoodTile: View {
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                    )
                Text("Add")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.1))
            )
            .foregroundStyle(Color.accentColor)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add custom mood")
    }
}


#Preview {
    MoodPickerView(
        onPickPredefined: { _ in },
        onPickCustom: { _ in },
        moodImages: [:],
        customMoods: [],
        onCreateCustomMood: { _ in },
        currentCustomMoodCount: 0
    )
}
