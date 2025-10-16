//
//  MoodService.swift
//  MoodSprout
//
//  Created by Levi on 9/24/25.
//

import Foundation
import Combine
import SwiftUI

/// Service responsible for managing mood data operations
@MainActor
final class MoodService: ObservableObject {
    static let shared = MoodService()
    
    @Published var moods: [MoodEntry] = []
    @Published var customMoods: [CustomMood] = []
    
    private let storageService = StorageService.shared
    private let supabaseService = SupabaseService.shared
    
    private init() {
        loadMoods()
        loadCustomMoods()
    }
    
    // MARK: - Mood Entry Methods
    
    /// Loads moods from local storage
    func loadMoods() {
        moods = storageService.load()
    }
    
    /// Adds a new mood entry with a predefined mood type
    func addMood(moodType: MoodType, notes: String?) {
        let today = Calendar.current.startOfDay(for: Date())
        let newEntry = MoodEntry(id: UUID(), moodType: moodType, notes: notes, date: today)
        
        // Replace existing entry for today if present
        var filtered = moods.filter { !Calendar.current.isDate($0.date, inSameDayAs: today) }
        filtered.insert(newEntry, at: 0)
        moods = filtered
        storageService.save(moods)
        
        // Sync to Supabase
        Task {
            do {
                try await supabaseService.saveMood(newEntry)
                print("✅ Mood saved to Supabase successfully")
            } catch {
                print("❌ Failed to save mood to Supabase: \(error)")
            }
        }
    }
    
    /// Adds a new mood entry with a custom mood
    func addCustomMood(customMoodId: UUID, notes: String?) {
        let today = Calendar.current.startOfDay(for: Date())
        let newEntry = MoodEntry(id: UUID(), customMoodId: customMoodId, notes: notes, date: today)
        
        // Replace existing entry for today if present
        var filtered = moods.filter { !Calendar.current.isDate($0.date, inSameDayAs: today) }
        filtered.insert(newEntry, at: 0)
        moods = filtered
        storageService.save(moods)
        
        // Sync to Supabase
        Task {
            do {
                try await supabaseService.saveMood(newEntry)
                print("✅ Custom mood saved to Supabase successfully")
            } catch {
                print("❌ Failed to save custom mood to Supabase: \(error)")
            }
        }
    }
    
    /// Updates an existing mood with notes
    func updateMoodWithNotes(moodType: MoodType, notes: String?) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Find the existing mood entry for today
        if let index = moods.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            // Update the existing entry with notes
            let updatedEntry = MoodEntry(id: moods[index].id, moodType: moodType, notes: notes, date: today)
            moods[index] = updatedEntry
            storageService.save(moods)
            
            // Sync to Supabase
            Task {
                do {
                    try await supabaseService.updateMood(updatedEntry)
                    print("✅ Mood updated with notes in Supabase successfully")
                } catch {
                    print("❌ Failed to update mood in Supabase: \(error)")
                }
            }
        }
    }
    
    /// Deletes a mood entry
    func deleteMood(at offsets: IndexSet) {
        let deletedMoods = offsets.map { moods[$0] }
        moods.remove(atOffsets: offsets)
        storageService.save(moods)
        
        // Sync deletion to Supabase
        for mood in deletedMoods {
            Task {
                do {
                    try await supabaseService.deleteMood(id: mood.id)
                    print("✅ Mood deleted from Supabase successfully")
                } catch {
                    print("❌ Failed to delete mood from Supabase: \(error)")
                }
            }
        }
    }
    
    /// Gets today's mood if it exists
    func getTodaysMood() -> MoodEntry? {
        return moods.first(where: { Calendar.current.isDateInToday($0.date) })
    }
    
    // MARK: - Custom Mood Methods
    
    /// Loads custom moods from local storage
    func loadCustomMoods() {
        customMoods = storageService.loadCustomMoods()
    }
    
    /// Creates a new custom mood
    func createCustomMood(_ customMood: CustomMood) {
        customMoods.append(customMood)
        storageService.saveCustomMoods(customMoods)
        
        // Sync to Supabase
        Task {
            do {
                try await supabaseService.saveCustomMood(customMood)
                print("✅ Custom mood definition saved to Supabase successfully")
            } catch {
                print("❌ Failed to save custom mood definition to Supabase: \(error)")
            }
        }
    }
    
    /// Deletes a custom mood
    func deleteCustomMood(_ customMood: CustomMood) {
        customMoods.removeAll { $0.id == customMood.id }
        storageService.saveCustomMoods(customMoods)
        
        // Sync deletion to Supabase
        Task {
            do {
                try await supabaseService.deleteCustomMood(id: customMood.id)
                print("✅ Custom mood definition deleted from Supabase successfully")
            } catch {
                print("❌ Failed to delete custom mood definition from Supabase: \(error)")
            }
        }
    }
    
    /// Gets a custom mood by ID
    func getCustomMood(by id: UUID) -> CustomMood? {
        return customMoods.first { $0.id == id }
    }
}
