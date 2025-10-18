//
//  ContentView.swift
//  MoodSprout
//
//  Created by Levi on 9/24/25.
//

import SwiftUI

// MARK: - Plant Theme Colors
extension Color {
    // Primary plant colors
    static let plantGreen = Color(hex: "4CAF50")
    static let plantGreenLight = Color(hex: "81C784")
    static let plantGreenDark = Color(hex: "388E3C")
    
    // Complementary colors for gradients
    static let plantMint = Color(hex: "A5D6A7")
    static let plantSage = Color(hex: "C8E6C9")
    static let plantCream = Color(hex: "F1F8E9")
    static let plantLime = Color(hex: "DCEDC8")
    
    // Background colors
    static let plantBackground = Color(hex: "F8F9FA")
    static let plantSurface = Color(hex: "FFFFFF")
    
    // Accent colors
    static let plantTeal = Color(hex: "4DB6AC")
    static let plantEmerald = Color(hex: "66BB6A")
    static let plantForest = Color(hex: "2E7D32")
}

// MARK: - Plant Theme Gradients
extension LinearGradient {
    static let plantGradient = LinearGradient(
        colors: [.plantGreen, .plantGreenLight, .plantMint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let plantSoftGradient = LinearGradient(
        colors: [.plantCream, .plantLime, .plantSage],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let plantAccentGradient = LinearGradient(
        colors: [.plantTeal, .plantEmerald, .plantGreen],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let plantBackgroundGradient = LinearGradient(
        colors: [.plantBackground, .plantCream, .plantLime.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Plant Theme Typography
extension Font {
    static let plantTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let plantHeadline = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let plantSubheadline = Font.system(size: 18, weight: .medium, design: .rounded)
    static let plantBody = Font.system(size: 16, weight: .regular, design: .rounded)
    static let plantCaption = Font.system(size: 14, weight: .medium, design: .rounded)
}

// MARK: - Plant Theme Spacing
struct PlantSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Plant Theme Corner Radius
struct PlantRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

struct ContentView: View {
    @StateObject private var moodService = MoodService.shared
    @StateObject private var imageService = ImageService.shared
    @State private var showMoodPicker: Bool = false
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
        ZStack {
            LinearGradient.plantBackgroundGradient.ignoresSafeArea()
                
                TabView(selection: $selectedTab) {
                    // Today's Mood
                    TodayView()
                        .tabItem {
                            Image(systemName: "leaf.fill")
                            Text("Today")
                        }
                        .tag(0)
                    
                    // History
                    HistoryView()
                        .tabItem {
                            Image(systemName: "list.bullet")
                            Text("History")
                        }
                        .tag(1)
                    
                    // Overview
                    OverviewView(moods: moodService.moods)
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("Overview")
                        }
                        .tag(2)
                }
                .accentColor(.plantGreen)
            }
            .navigationTitle("MoodSprout")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showMoodPicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.plantGreen)
                    }
                    .accessibilityLabel("Add mood")
                }
            }
            .sheet(isPresented: $showMoodPicker) {
                MoodPickerView(
                    onPickPredefined: { mood in
                        moodService.addMood(moodType: mood, notes: nil)
                        showMoodPicker = false
                    },
                    onPickCustom: { customMood in
                        moodService.addCustomMood(customMoodId: customMood.id, notes: nil)
                        showMoodPicker = false
                    },
                    moodImages: imageService.moodImages,
                    customMoods: moodService.customMoods,
                    onCreateCustomMood: { customMood in
                        moodService.createCustomMood(customMood)
                    },
                    currentCustomMoodCount: moodService.customMoods.count
                )
                .presentationDetents([.fraction(0.8), .large])
            }
            .onAppear {
                Task {
                    await imageService.loadMoodImages()
                }
            }
        }
    }
}

// MARK: - Today View
struct TodayView: View {
    @StateObject private var moodService = MoodService.shared
    @StateObject private var imageService = ImageService.shared
    @State private var showNotesEditor = false
    
    var body: some View {
        ZStack {
            LinearGradient.plantSoftGradient.ignoresSafeArea()
            
            ScrollView {
            VStack(spacing: PlantSpacing.xl) {
                if let todayMood = moodService.getTodaysMood() {
                    // Main mood card
                    VStack(spacing: PlantSpacing.lg) {
                        // Header with plant icon
                        HStack {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.plantGreen)
                            Text("Today's Mood")
                                .font(.plantHeadline)
                                .foregroundColor(.plantGreen)
                            Spacer()
                        }
                        
                        // Mood display section
                        VStack(spacing: PlantSpacing.lg) {
                            // Display mood icon/emoji - make it clickable
                            Button {
                                showNotesEditor = true
                            } label: {
                                if let customMoodId = todayMood.customMoodId,
                                   let customMood = moodService.getCustomMood(by: customMoodId) {
                                    // Custom mood display
                                    if let data = customMood.imageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 140, height: 140)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(hex: customMood.color).opacity(0.3), lineWidth: 4)
                                            )
                                    } else {
                                        Text(customMood.emoji)
                                            .font(.system(size: 80))
                                            .frame(width: 140, height: 140)
                                            .background(
                                                Circle()
                                                    .fill(Color(hex: customMood.color).opacity(0.15))
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color(hex: customMood.color).opacity(0.3), lineWidth: 3)
                                                    )
                                            )
                                    }
                                } else if let moodType = todayMood.moodType {
                                    // Predefined mood display
                                    SupabaseImageView(
                                        imageName: moodType.imageName,
                                        fallbackSystemImage: "face.smiling",
                                        imageData: imageService.getImageData(for: moodType)
                                    )
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.plantGreen.opacity(0.3), lineWidth: 4)
                                    )
                                }
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.2), value: showNotesEditor)
                            
                            // Mood name and description
                            VStack(spacing: PlantSpacing.sm) {
                                Text("You're feeling")
                                    .font(.plantSubheadline)
                                    .foregroundColor(.secondary)
                                
                                if let customMoodId = todayMood.customMoodId,
                                   let customMood = moodService.getCustomMood(by: customMoodId) {
                                    Text(customMood.name)
                                        .font(.plantTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(hex: customMood.color))
                                } else if let moodType = todayMood.moodType {
                                    Text(moodType.displayName)
                                        .font(.plantTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.plantGreen)
                                }
                            }
                            
                            // Notes section
                            VStack(spacing: PlantSpacing.md) {
                                if let notes = todayMood.notes, !notes.isEmpty {
                                    VStack(alignment: .leading, spacing: PlantSpacing.sm) {
                                        HStack {
                                            Image(systemName: "note.text")
                                                .font(.system(size: 16))
                                                .foregroundColor(.plantGreen)
                                            Text("Notes")
                                                .font(.plantCaption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.plantGreen)
                                            Spacer()
                                        }
                                        
                                        Text(notes)
                                            .font(.plantBody)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(PlantSpacing.md)
                                            .background(
                                                RoundedRectangle(cornerRadius: PlantRadius.md)
                                                    .fill(Color.plantBackground)
                                            )
                                    }
                                } else {
                                    VStack(spacing: PlantSpacing.sm) {
                                        Image(systemName: "note.text.badge.plus")
                                            .font(.system(size: 24))
                                            .foregroundColor(.plantGreen.opacity(0.6))
                                        Text("Tap the mood above to add notes")
                                            .font(.plantCaption)
                                            .foregroundColor(.secondary)
                                            .italic()
                                    }
                                    .padding(PlantSpacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: PlantRadius.md)
                                            .fill(Color.plantBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: PlantRadius.md)
                                                    .stroke(Color.plantGreen.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                    .padding(PlantSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: PlantRadius.lg)
                            .fill(LinearGradient.plantSoftGradient)
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, PlantSpacing.md)
                    
                } else {
                    // No mood state
                    VStack(spacing: PlantSpacing.lg) {
                        Image(systemName: "leaf")
                            .font(.system(size: 80))
                            .foregroundColor(.plantGreen.opacity(0.3))
                        
                        VStack(spacing: PlantSpacing.md) {
                            Text("No mood logged today")
                                .font(.plantHeadline)
                                .foregroundColor(.plantGreen)
                            
                            Text("Start your day by logging how you're feeling")
                                .font(.plantBody)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Log Your Mood") {
                            // This will be handled by the parent view
                        }
                        .font(.plantBody)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PlantSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: PlantRadius.md)
                                .fill(Color.plantGreen)
                        )
                        .padding(.horizontal, PlantSpacing.xl)
                    }
                    .padding(PlantSpacing.xl)
                }
            }
            .padding(.top, PlantSpacing.md)
        }
        .background(Color.clear)
        .sheet(isPresented: $showNotesEditor) {
            if let todayMood = moodService.getTodaysMood() {
                NotesEditorView(
                    currentNotes: todayMood.notes,
                    moodType: todayMood.moodType,
                    customMoodId: todayMood.customMoodId,
                    onSave: { notes in
                        if let moodType = todayMood.moodType {
                            moodService.updateMoodWithNotes(moodType: moodType, notes: notes)
                        } else if let customMoodId = todayMood.customMoodId {
                            moodService.updateCustomMoodWithNotes(customMoodId: customMoodId, notes: notes)
                        }
                    }
                )
            }
        }
        }
    }
}

// MARK: - History View
struct HistoryView: View {
    @StateObject private var moodService = MoodService.shared
    @StateObject private var imageService = ImageService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if moodService.moods.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "leaf")
                            .font(.system(size: 80))
                            .foregroundColor(Color.plantGreen.opacity(0.3))
                        
                        VStack(spacing: 16) {
                            Text("No moods yet")
                                .font(.plantHeadline)
                                .foregroundColor(Color.plantGreen)
                            
                            Text("Your mood history will appear here")
                                .font(.plantBody)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(32)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(moodService.moods) { entry in
                            MoodEntryView(entry: entry, moodService: moodService, imageService: imageService)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 16)
        }
        .background(Color.clear)
    }
}

// MARK: - Mood Entry View
struct MoodEntryView: View {
    let entry: MoodEntry
    let moodService: MoodService
    let imageService: ImageService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                // Mood icon/emoji
                MoodIconView(entry: entry, moodService: moodService, imageService: imageService)
                
                // Mood details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // Mood name
                        Text(moodName)
                            .font(.plantSubheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(moodColor)
                        
                        Spacer()
                        
                        // Date
                        Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.plantCaption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Notes
                    if let notes = entry.notes, !notes.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "note.text")
                                .font(.system(size: 14))
                                .foregroundColor(Color.plantGreen.opacity(0.7))
                            Text(notes)
                                .font(.plantCaption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            Spacer()
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient.plantSoftGradient)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private var moodName: String {
        if let customMoodId = entry.customMoodId,
           let customMood = moodService.getCustomMood(by: customMoodId) {
            return customMood.name
        } else if let moodType = entry.moodType {
            return moodType.displayName
        }
        return "Unknown"
    }
    
    private var moodColor: Color {
        if let customMoodId = entry.customMoodId,
           let customMood = moodService.getCustomMood(by: customMoodId) {
            return Color(hex: customMood.color)
        } else {
            return Color.plantGreen
        }
    }
}

// MARK: - Mood Icon View
struct MoodIconView: View {
    let entry: MoodEntry
    let moodService: MoodService
    let imageService: ImageService
    
    var body: some View {
        if let customMoodId = entry.customMoodId,
           let customMood = moodService.getCustomMood(by: customMoodId) {
            // Custom mood display
            if let data = customMood.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(hex: customMood.color).opacity(0.3), lineWidth: 2)
                    )
            } else {
                Text(customMood.emoji)
                    .font(.system(size: 32))
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color(hex: customMood.color).opacity(0.15))
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: customMood.color).opacity(0.3), lineWidth: 2)
                            )
                    )
            }
        } else if let moodType = entry.moodType {
            // Predefined mood display
            SupabaseImageView(
                imageName: moodType.imageName,
                fallbackSystemImage: "face.smiling",
                imageData: imageService.getImageData(for: moodType)
            )
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.plantGreen.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

#Preview {
    ContentView()
}