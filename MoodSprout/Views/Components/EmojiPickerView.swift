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
            ZStack {
                LinearGradient.plantBackgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header section
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.plantGreen)
                            Text("How are you feeling today?")
                                .font(.plantHeadline)
                                .foregroundColor(.plantGreen)
                        }
                        
                        Text("Choose a mood that best represents your current state")
                            .font(.plantBody)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)
                    
                    // Mood Grid
                    ScrollView {
                        VStack(alignment: .leading, spacing: 32) {
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
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Mood Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plantGreen)
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
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(.plantGreen)
                Text("Default Moods")
                    .font(.plantSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.plantGreen)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            LazyVGrid(columns: columns, spacing: 24) {
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
            .padding(.horizontal, 16)
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
        Button {
            onTap()
        } label: {
            VStack(spacing: 8) {
                SupabaseImageView(
                    imageName: mood.imageName,
                    fallbackSystemImage: "face.smiling",
                    imageData: moodImages[mood.imageName]
                )
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(isSelected ? Color.plantGreen.opacity(0.15) : Color.plantBackground)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.plantGreen : .clear, lineWidth: 3)
                        )
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                
                Text(mood.displayName)
                    .font(.plantCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .plantGreen : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? LinearGradient.plantAccentGradient : LinearGradient.plantSoftGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.plantGreen : Color.plantGreen.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: isSelected ? Color.plantGreen.opacity(0.2) : .black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
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
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.plantGreen)
                    Text("Your Custom Moods")
                        .font(.plantSubheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.plantGreen)
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                LazyVGrid(columns: columns, spacing: 24) {
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
                .padding(.horizontal, 16)
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
        Button {
            onTap()
        } label: {
            VStack(spacing: 8) {
                if let data = mood.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color(hex: mood.color) : .clear, lineWidth: 3)
                        )
                } else {
                    Text(mood.emoji)
                        .font(.system(size: 40))
                        .frame(width: 70, height: 70)
                        .background(
                            Circle()
                                .fill(Color(hex: mood.color).opacity(isSelected ? 0.2 : 0.1))
                                .overlay(
                                    Circle()
                                        .stroke(isSelected ? Color(hex: mood.color) : .clear, lineWidth: 3)
                                )
                        )
                }
                
                Text(mood.name)
                    .font(.plantCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? Color(hex: mood.color) : .primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? LinearGradient(colors: [Color(hex: mood.color).opacity(0.2), Color(hex: mood.color).opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient.plantSoftGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color(hex: mood.color) : Color(hex: mood.color).opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: isSelected ? Color(hex: mood.color).opacity(0.2) : .black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Custom Mood Tile
struct AddCustomMoodTile: View {
    var onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.plantGreen)
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(Color.plantGreen.opacity(0.1))
                            .overlay(
                                Circle()
                                    .stroke(Color.plantGreen.opacity(0.3), lineWidth: 2)
                            )
                    )
                Text("Add")
                    .font(.plantCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.plantGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient.plantSoftGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.plantGreen.opacity(0.2), lineWidth: 1)
                    )
            )
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
