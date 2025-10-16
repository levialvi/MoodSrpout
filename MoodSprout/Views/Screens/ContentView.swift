//
//  ContentView.swift
//  MoodSprout
//
//  Created by Levi on 9/24/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var moodService = MoodService.shared
    @StateObject private var imageService = ImageService.shared
    @State private var showMoodPicker: Bool = false
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Today's Mood
                TodayView()
                    .tabItem {
                        Image(systemName: "sun.max")
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
                        Image(systemName: "chart.bar")
                        Text("Overview")
                    }
                    .tag(2)
            }
            .navigationTitle("MoodSprout")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showMoodPicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
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
    
    var body: some View {
        VStack {
            if let todayMood = moodService.getTodaysMood() {
                VStack(spacing: 20) {
                    // Display mood icon/emoji
                    if let customMoodId = todayMood.customMoodId,
                       let customMood = moodService.getCustomMood(by: customMoodId) {
                        // Custom mood display
                        Text(customMood.emoji)
                            .font(.system(size: 80))
                            .frame(width: 120, height: 120)
                            .background(
                                Circle()
                                    .fill(Color(hex: customMood.color).opacity(0.2))
                            )
                    } else if let moodType = todayMood.moodType {
                        // Predefined mood display
                        SupabaseImageView(
                            imageName: moodType.imageName,
                            fallbackSystemImage: "face.smiling",
                            imageData: imageService.getImageData(for: moodType)
                        )
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    }
                    
                    Text("Today you're feeling")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    // Display mood name
                    if let customMoodId = todayMood.customMoodId,
                       let customMood = moodService.getCustomMood(by: customMoodId) {
                        Text(customMood.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: customMood.color))
                    } else if let moodType = todayMood.moodType {
                        Text(moodType.displayName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    if let notes = todayMood.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding()
            } else {
                ContentUnavailableView(
                    "No mood logged today",
                    systemImage: "face.smiling",
                    description: Text("Tap + to log how you're feeling")
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
        List {
            if moodService.moods.isEmpty {
                ContentUnavailableView(
                    "No moods yet",
                    systemImage: "calendar",
                    description: Text("Your mood history will appear here")
                )
            } else {
                ForEach(moodService.moods) { entry in
                    HStack(spacing: 16) {
                        // Display mood icon/emoji
                        if let customMoodId = entry.customMoodId,
                           let customMood = moodService.getCustomMood(by: customMoodId) {
                            // Custom mood display
                            Text(customMood.emoji)
                                .font(.system(size: 30))
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(Color(hex: customMood.color).opacity(0.2))
                                )
                        } else if let moodType = entry.moodType {
                            // Predefined mood display
                            SupabaseImageView(
                                imageName: moodType.imageName,
                                fallbackSystemImage: "face.smiling",
                                imageData: imageService.getImageData(for: moodType)
                            )
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            // Display mood name
                            if let customMoodId = entry.customMoodId,
                               let customMood = moodService.getCustomMood(by: customMoodId) {
                                Text(customMood.name)
                                    .font(.headline)
                                    .foregroundStyle(Color(hex: customMood.color))
                            } else if let moodType = entry.moodType {
                                Text(moodType.displayName)
                                    .font(.headline)
                            }
                            
                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if let notes = entry.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: moodService.deleteMood)
            }
        }
    }
}

#Preview {
    ContentView()
}