//
//  StorageService.swift
//  MoodSprout
//
//  Created by Levi on 9/24/25.
//

import Foundation

/// Service responsible for local data persistence
final class StorageService {
    static let shared = StorageService()
    
    private let key = "moodsprout.entries.v1"
    private let customMoodsKey = "moodsprout.customMoods.v1"
    
    private init() {}
    
    /// Loads mood entries from UserDefaults
    func load() -> [MoodEntry] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            let entries = try JSONDecoder().decode([MoodEntry].self, from: data)
            return entries.sorted { $0.date > $1.date }
        } catch {
            print("❌ Failed to load moods from storage: \(error)")
            return []
        }
    }
    
    /// Saves mood entries to UserDefaults
    func save(_ entries: [MoodEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Failed to save moods to storage: \(error)")
        }
    }
    
    // MARK: - Custom Moods Storage
    
    /// Loads custom moods from UserDefaults
    func loadCustomMoods() -> [CustomMood] {
        guard let data = UserDefaults.standard.data(forKey: customMoodsKey) else { return [] }
        do {
            let moods = try JSONDecoder().decode([CustomMood].self, from: data)
            return moods.sorted { $0.createdAt < $1.createdAt }
        } catch {
            print("❌ Failed to load custom moods from storage: \(error)")
            return []
        }
    }
    
    /// Saves custom moods to UserDefaults
    func saveCustomMoods(_ moods: [CustomMood]) {
        do {
            let data = try JSONEncoder().encode(moods)
            UserDefaults.standard.set(data, forKey: customMoodsKey)
        } catch {
            print("❌ Failed to save custom moods to storage: \(error)")
        }
    }
}
