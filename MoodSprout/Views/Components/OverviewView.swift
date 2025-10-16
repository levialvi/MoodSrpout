import SwiftUI
import Charts

struct OverviewView: View {
    let moods: [MoodEntry]
    @State private var selectedPeriod: TimePeriod = .week
    
    enum TimePeriod: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Overview Content
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedPeriod {
                        case .day:
                            DailyOverview(moods: moods)
                        case .week:
                            WeeklyOverview(moods: moods)
                        case .month:
                            MonthlyOverview(moods: moods)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Overview")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task {
                    print("🖼️ OverviewView: Loading mood images...")
                    await ImageService.shared.loadMoodImages()
                    print("🖼️ OverviewView: Images loaded: \(ImageService.shared.moodImages.count)")
                }
            }
        }
    }
}

struct DailyOverview: View {
    let moods: [MoodEntry]
    @StateObject private var imageService = ImageService.shared
    @StateObject private var moodService = MoodService.shared
    
    var todayMood: MoodEntry? {
        moods.first { Calendar.current.isDateInToday($0.date) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let mood = todayMood {
                VStack(spacing: 16) {
                    // Display mood icon/emoji
                    if let customMoodId = mood.customMoodId,
                       let customMood = moodService.getCustomMood(by: customMoodId) {
                        // Custom mood display
                        Text(customMood.emoji)
                            .font(.system(size: 60))
                            .frame(width: 100, height: 100)
                            .background(
                                Circle()
                                    .fill(Color(hex: customMood.color).opacity(0.2))
                            )
                    } else if let moodType = mood.moodType {
                        // Predefined mood display
                        SupabaseImageView(
                            imageName: moodType.imageName,
                            fallbackSystemImage: "face.smiling",
                            imageData: imageService.getImageData(for: moodType)
                        )
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    }
                    
                    Text("Today's Mood")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // Display mood name
                    if let customMoodId = mood.customMoodId,
                       let customMood = moodService.getCustomMood(by: customMoodId) {
                        Text(customMood.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: customMood.color))
                    } else if let moodType = mood.moodType {
                        Text(moodType.displayName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                    
                    if let notes = mood.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
            } else {
                ContentUnavailableView(
                    "No mood logged today",
                    systemImage: "face.smiling",
                    description: Text("Log your mood to see today's overview")
                )
            }
        }
    }
}

struct WeeklyOverview: View {
    let moods: [MoodEntry]
    @StateObject private var imageService = ImageService.shared
    @StateObject private var moodService = MoodService.shared
    
    var weekMoods: [MoodEntry] {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? now
        
        return moods.filter { mood in
            mood.date >= weekStart && mood.date < weekEnd
        }
    }
    
    var predefinedMoodCounts: [MoodType: Int] {
        Dictionary(grouping: weekMoods.compactMap { $0.moodType }, by: { $0 })
            .mapValues { $0.count }
    }
    
    var customMoodCounts: [CustomMood: Int] {
        Dictionary(grouping: weekMoods.compactMap { entry in
            guard let customMoodId = entry.customMoodId else { return nil }
            return moodService.getCustomMood(by: customMoodId)
        }.compactMap { $0 }, by: { $0 })
        .mapValues { $0.count }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if weekMoods.isEmpty {
                ContentUnavailableView(
                    "No moods this week",
                    systemImage: "calendar",
                    description: Text("Log your moods to see weekly patterns")
                )
            } else {
                // Mood Distribution
                VStack(alignment: .leading, spacing: 12) {
                    Text("This Week's Moods")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        // Predefined moods
                        ForEach(MoodType.allCases, id: \.self) { mood in
                            if let count = predefinedMoodCounts[mood], count > 0 {
                                HStack {
                                    SupabaseImageView(
                                        imageName: mood.imageName,
                                        fallbackSystemImage: "face.smiling",
                                        imageData: imageService.getImageData(for: mood)
                                    )
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(mood.displayName)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        Text("\(count) time\(count == 1 ? "" : "s")")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                            }
                        }
                        
                        // Custom moods
                        ForEach(Array(customMoodCounts.keys.sorted(by: { $0.createdAt < $1.createdAt })), id: \.id) { customMood in
                            if let count = customMoodCounts[customMood], count > 0 {
                                HStack {
                                    Text(customMood.emoji)
                                        .font(.system(size: 20))
                                        .frame(width: 30, height: 30)
                                        .background(
                                            Circle()
                                                .fill(Color(hex: customMood.color).opacity(0.2))
                                        )
                                    
                                    VStack(alignment: .leading) {
                                        Text(customMood.name)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        Text("\(count) time\(count == 1 ? "" : "s")")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
}

struct MonthlyOverview: View {
    let moods: [MoodEntry]
    @StateObject private var imageService = ImageService.shared
    @StateObject private var moodService = MoodService.shared
    
    var monthMoods: [MoodEntry] {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? now
        
        return moods.filter { mood in
            mood.date >= monthStart && mood.date < monthEnd
        }
    }
    
    var predefinedMoodCounts: [MoodType: Int] {
        Dictionary(grouping: monthMoods.compactMap { $0.moodType }, by: { $0 })
            .mapValues { $0.count }
    }
    
    var customMoodCounts: [CustomMood: Int] {
        Dictionary(grouping: monthMoods.compactMap { entry in
            guard let customMoodId = entry.customMoodId else { return nil }
            return moodService.getCustomMood(by: customMoodId)
        }.compactMap { $0 }, by: { $0 })
        .mapValues { $0.count }
    }
    
    var totalMoods: Int {
        monthMoods.count
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if monthMoods.isEmpty {
                ContentUnavailableView(
                    "No moods this month",
                    systemImage: "calendar",
                    description: Text("Log your moods to see monthly patterns")
                )
            } else {
                // Monthly Stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("This Month")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(totalMoods)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Total Moods")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(monthMoods.count / max(1, Calendar.current.component(.day, from: Date())))")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Avg per day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Top Moods
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Most Common Moods")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        // Top Moods Display
                        TopMoodsView(
                            predefinedMoodCounts: predefinedMoodCounts,
                            customMoodCounts: customMoodCounts,
                            imageService: imageService
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
}

// MARK: - Top Moods View
struct TopMoodsView: View {
    let predefinedMoodCounts: [MoodType: Int]
    let customMoodCounts: [CustomMood: Int]
    let imageService: ImageService
    
    var topMoods: [(name: String, emoji: String, color: Color, count: Int)] {
        var counts: [(name: String, emoji: String, color: Color, count: Int)] = []
        
        // Add predefined moods
        for (mood, count) in predefinedMoodCounts {
            counts.append((name: mood.displayName, emoji: "😊", color: .blue, count: count))
        }
        
        // Add custom moods
        for (customMood, count) in customMoodCounts {
            counts.append((name: customMood.name, emoji: customMood.emoji, color: Color(hex: customMood.color), count: count))
        }
        
        return counts.sorted { $0.count > $1.count }.prefix(3).map { $0 }
    }
    
    var body: some View {
        ForEach(Array(topMoods.enumerated()), id: \.offset) { index, moodData in
            HStack {
                if moodData.emoji == "😊" {
                    // Predefined mood - find the actual mood type
                    if let moodType = MoodType.allCases.first(where: { $0.displayName == moodData.name }) {
                        SupabaseImageView(
                            imageName: moodType.imageName,
                            fallbackSystemImage: "face.smiling",
                            imageData: imageService.getImageData(for: moodType)
                        )
                        .frame(width: 25, height: 25)
                        .clipShape(Circle())
                    }
                } else {
                    // Custom mood - use emoji
                    Text(moodData.emoji)
                        .font(.system(size: 16))
                        .frame(width: 25, height: 25)
                        .background(
                            Circle()
                                .fill(moodData.color.opacity(0.2))
                        )
                }
                
                Text(moodData.name)
                    .font(.caption)
                
                Spacer()
                
                Text("\(moodData.count)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

#Preview {
    OverviewView(moods: [])
}
