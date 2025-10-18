import Foundation

enum MoodType: String, CaseIterable, Codable {
    case happy = "happy"
    case sad = "sad"
    case angry = "angry"
    case worried = "worried"
    
    var displayName: String {
        switch self {
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .worried: return "Worried"
        }
    }
    
    var imageName: String {
        switch self {
        case .happy: return "SunHappy"
        case .sad: return "SunSad"
        case .angry: return "SunAngry"
        case .worried: return "SunWorried"
        }
    }
}

// MARK: - Custom Mood Model
struct CustomMood: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let emoji: String
    let color: String // Hex color string
    let createdAt: Date
    let imageData: Data?
    
    init(id: UUID = UUID(), name: String, emoji: String, color: String, createdAt: Date = Date(), imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.createdAt = createdAt
        self.imageData = imageData
    }
}

// MARK: - Mood Entry
struct MoodEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let moodType: MoodType?
    let customMoodId: UUID?
    let notes: String?
    let date: Date
    
    // Computed property for backward compatibility
    var emoji: String {
        return moodType?.rawValue ?? ""
    }
    
    var isCustomMood: Bool {
        return customMoodId != nil
    }
    
    // Initialize with predefined mood
    init(id: UUID = UUID(), moodType: MoodType, notes: String?, date: Date) {
        self.id = id
        self.moodType = moodType
        self.customMoodId = nil
        self.notes = notes
        self.date = date
    }
    
    // Initialize with custom mood
    init(id: UUID = UUID(), customMoodId: UUID, notes: String?, date: Date) {
        self.id = id
        self.moodType = nil
        self.customMoodId = customMoodId
        self.notes = notes
        self.date = date
    }
}

final class MoodStorage {
    static let shared = MoodStorage()
    private let key = "moodsprout.entries.v1"
    private let customMoodsKey = "moodsprout.customMoods.v1"

    func load() -> [MoodEntry] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            let entries = try JSONDecoder().decode([MoodEntry].self, from: data)
            return entries.sorted { $0.date > $1.date }
        } catch {
            return []
        }
    }

    func save(_ entries: [MoodEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            // no-op for demo
        }
    }
    
    // MARK: - Custom Moods Storage
    func loadCustomMoods() -> [CustomMood] {
        guard let data = UserDefaults.standard.data(forKey: customMoodsKey) else { return [] }
        do {
            let moods = try JSONDecoder().decode([CustomMood].self, from: data)
            return moods.sorted { $0.createdAt < $1.createdAt }
        } catch {
            return []
        }
    }
    
    func saveCustomMoods(_ moods: [CustomMood]) {
        do {
            let data = try JSONEncoder().encode(moods)
            UserDefaults.standard.set(data, forKey: customMoodsKey)
        } catch {
            // no-op for demo
        }
    }
}

