//
//  ContentView.swift
//  MoodSprout
//
//  Created by Levi on 9/24/25.
//

import SwiftUI

// MARK: - Plant Theme Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let plantGreen = Color(hex: "4CAF50")
    static let plantGreenLight = Color(hex: "81C784")
    static let plantBackground = Color(hex: "F8F9FA")
    static let plantSurface = Color(hex: "FFFFFF")
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
                Color.plantBackground.ignoresSafeArea()
                
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
                                            .stroke(.plantGreen.opacity(0.3), lineWidth: 4)
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
                                        .foregroundStyle(.plantGreen)
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
                                                    .fill(.plantBackground)
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
                                            .fill(.plantBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: PlantRadius.md)
                                                    .stroke(.plantGreen.opacity(0.2), lineWidth: 1, lineCap: .round, dash: [5])
                                            )
                                    )
                                }
                            }
                        }
                    }
                    .padding(PlantSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: PlantRadius.lg)
                            .fill(.plantSurface)
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
                                .fill(.plantGreen)
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

// MARK: - History View
struct HistoryView: View {
    @StateObject private var moodService = MoodService.shared
    @StateObject private var imageService = ImageService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: PlantSpacing.md) {
                if moodService.moods.isEmpty {
                    VStack(spacing: PlantSpacing.lg) {
                        PlantIcon("leaf", size: 80, color: .plantGreen.opacity(0.3))
                        
                        VStack(spacing: PlantSpacing.md) {
                            Text("No moods yet")
                                .font(.plantHeadline)
                                .foregroundColor(.plantGreen)
                            
                            Text("Your mood history will appear here")
                                .font(.plantBody)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(PlantSpacing.xl)
                } else {
                    LazyVStack(spacing: PlantSpacing.md) {
                        ForEach(moodService.moods) { entry in
                            PlantCard {
                                HStack(spacing: PlantSpacing.md) {
                                    // Mood icon/emoji
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
                                                .stroke(.plantGreen.opacity(0.3), lineWidth: 2)
                                        )
                                    }
                                    
                                    // Mood details
                                    VStack(alignment: .leading, spacing: PlantSpacing.sm) {
                                        HStack {
                                            // Mood name
                                            if let customMoodId = entry.customMoodId,
                                               let customMood = moodService.getCustomMood(by: customMoodId) {
                                                Text(customMood.name)
                                                    .font(.plantSubheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(Color(hex: customMood.color))
                                            } else if let moodType = entry.moodType {
                                                Text(moodType.displayName)
                                                    .font(.plantSubheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(.plantGreen)
                                            }
                                            
                                            Spacer()
                                            
                                            // Date
                                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.plantSmall)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        // Notes
                                        if let notes = entry.notes, !notes.isEmpty {
                                            HStack(alignment: .top, spacing: PlantSpacing.sm) {
                                                PlantIcon("note.text", size: 14, color: .plantGreen.opacity(0.7))
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
                        }
                    }
                    .padding(.horizontal, PlantSpacing.md)
                }
            }
            .padding(.top, PlantSpacing.md)
        }
        .background(Color.clear)
    }
}

#Preview {
    ContentView()
}