//
//  SupabaseService.swift
//  MoodSprout
//
//  Created by Levi on 9/24/25.
//

import Foundation
import Combine
import Supabase

/// Service responsible for all Supabase operations
final class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    private let supabase: SupabaseClient
    
    private init() {
        // Supabase configuration
        let supabaseURL = URL(string: "https://syhqspuqaunaqejmckom.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN5aHFzcHVxYXVuYXFlam1ja29tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1Mzg4NTMsImV4cCI6MjA3NDExNDg1M30.MLbrfm_xUvKGJRj1rIzbZ-W2_z2DfKfYxxPqgxlDeMU"
        
        self.supabase = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    // MARK: - Mood Entry Operations
    
    func saveMood(_ mood: MoodEntry) async throws {
        let moodData = MoodData(
            id: mood.id.uuidString,
            mood_type: mood.moodType?.rawValue,
            custom_mood_id: mood.customMoodId?.uuidString,
            notes: mood.notes,
            image_url: nil,
            created_at: mood.date.ISO8601Format()
        )
        
        try await supabase
            .from("moods")
            .insert(moodData)
            .execute()
    }
    
    func fetchMoods() async throws -> [MoodEntry] {
        let response: [MoodData] = try await supabase
            .from("moods")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.compactMap { data in
            let uuid = UUID(uuidString: data.id)!
            let date = ISO8601DateFormatter().date(from: data.created_at) ?? Date()
            
            if let customMoodIdString = data.custom_mood_id,
               let customMoodId = UUID(uuidString: customMoodIdString) {
                // Custom mood entry
                return MoodEntry(id: uuid, customMoodId: customMoodId, notes: data.notes, date: date)
            } else if let moodTypeString = data.mood_type,
                      let moodType = MoodType(rawValue: moodTypeString) {
                // Predefined mood entry
                return MoodEntry(id: uuid, moodType: moodType, notes: data.notes, date: date)
            }
            return nil
        }
    }
    
    func updateMood(_ mood: MoodEntry) async throws {
        let moodData = MoodData(
            id: mood.id.uuidString,
            mood_type: mood.moodType?.rawValue,
            custom_mood_id: mood.customMoodId?.uuidString,
            notes: mood.notes,
            image_url: nil,
            created_at: mood.date.ISO8601Format()
        )
        
        try await supabase
            .from("moods")
            .update(moodData)
            .eq("id", value: mood.id.uuidString)
            .execute()
    }
    
    func deleteMood(id: UUID) async throws {
        try await supabase
            .from("moods")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Custom Mood Definition Operations
    
    func saveCustomMood(_ customMood: CustomMood) async throws {
        let customMoodData = CustomMoodData(
            id: customMood.id.uuidString,
            name: customMood.name,
            emoji: customMood.emoji,
            color: customMood.color,
            created_at: customMood.createdAt.ISO8601Format()
        )
        
        try await supabase
            .from("custom_moods")
            .insert(customMoodData)
            .execute()
    }
    
    func fetchCustomMoods() async throws -> [CustomMood] {
        let response: [CustomMoodData] = try await supabase
            .from("custom_moods")
            .select()
            .order("created_at", ascending: true)
            .execute()
            .value
        
        return response.map { data in
            CustomMood(
                id: UUID(uuidString: data.id)!,
                name: data.name,
                emoji: data.emoji,
                color: data.color,
                createdAt: ISO8601DateFormatter().date(from: data.created_at) ?? Date()
            )
        }
    }
    
    func deleteCustomMood(id: UUID) async throws {
        try await supabase
            .from("custom_moods")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Storage Operations
    
    func listBuckets() async throws -> [Bucket] {
        let response: [Bucket] = try await supabase.storage.listBuckets()
        return response
    }
    
    func listFiles(bucketName: String) async throws -> [FileObject] {
        let response: [FileObject] = try await supabase.storage.from(bucketName).list()
        return response
    }
    
    func getPublicURL(bucketName: String, path: String) -> URL? {
        do {
            let response = try supabase.storage.from(bucketName).getPublicURL(path: path)
            return response
        } catch {
            print("❌ Failed to get public URL: \(error)")
            return nil
        }
    }
    
    func downloadFile(bucketName: String, path: String) async throws -> Data {
        let response: Data = try await supabase.storage.from(bucketName).download(path: path)
        return response
    }
}

// MARK: - Supabase Data Models
struct MoodData: Codable {
    let id: String
    let mood_type: String?
    let custom_mood_id: String?
    let notes: String?
    let image_url: String?
    let created_at: String
}

struct CustomMoodData: Codable {
    let id: String
    let name: String
    let emoji: String
    let color: String
    let created_at: String
}
