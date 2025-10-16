//
//  CustomMoodCreatorView.swift
//  MoodSprout
//
//  Created by AI Assistant
//

import SwiftUI

struct CustomMoodCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var moodName: String = ""
    @State private var selectedEmoji: String = "😊"
    @State private var selectedColor: Color = .blue
    @State private var showEmojiPicker: Bool = false
    
    var onSave: (CustomMood) -> Void
    var currentCustomMoodCount: Int = 0
    private let maxCustomMoods = 10
    
    // Common emojis for moods
    private let availableEmojis = [
        "😊", "😃", "😄", "😁", "😆", "😅", "🤣", "😂",
        "🙂", "🙃", "😉", "😇", "🥰", "😍", "🤩", "😘",
        "😗", "😚", "😙", "😋", "😛", "😜", "🤪", "😝",
        "🤑", "🤗", "🤭", "🤫", "🤔", "🤐", "🤨", "😐",
        "😑", "😶", "😏", "😒", "🙄", "😬", "🤥", "😌",
        "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢",
        "🤮", "🤧", "🥵", "🥶", "😶‍🌫️", "🥴", "😵", "🤯",
        "🤠", "🥳", "😎", "🤓", "🧐", "😕", "😟", "🙁",
        "☹️", "😮", "😯", "😲", "😳", "🥺", "😦", "😧",
        "😨", "😰", "😥", "😢", "😭", "😱", "😖", "😣",
        "😞", "😓", "😩", "😫", "🥱", "😤", "😡", "😠",
        "🤬", "😈", "👿", "💀", "☠️", "💩", "🤡", "👹",
        "👺", "👻", "👽", "👾", "🤖", "😺", "😸", "😹",
        "😻", "😼", "😽", "🙀", "😿", "😾", "🙈", "🙉",
        "🙊", "💋", "💌", "💘", "💝", "💖", "💗", "💓",
        "💞", "💕", "💟", "❣️", "💔", "❤️", "🧡", "💛",
        "💚", "💙", "💜", "🤎", "🖤", "🤍", "💯", "💢",
        "💥", "💫", "💦", "💨", "🕳️", "💣", "💬", "🗨️",
        "🗯️", "💭", "💤", "⭐", "🌟", "✨", "🔥", "💥"
    ]
    
    // Color options
    private let colorOptions: [(name: String, color: Color)] = [
        ("Blue", .blue),
        ("Purple", .purple),
        ("Pink", .pink),
        ("Red", .red),
        ("Orange", .orange),
        ("Yellow", .yellow),
        ("Green", .green),
        ("Teal", .teal),
        ("Indigo", .indigo),
        ("Mint", .mint),
        ("Cyan", .cyan),
        ("Brown", .brown)
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // Show limit reached message if at max
                if currentCustomMoodCount >= maxCustomMoods {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Custom Mood Limit Reached")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("You can create up to \(maxCustomMoods) custom moods. Delete an existing custom mood to create a new one.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    Section {
                        TextField("Mood Name", text: $moodName)
                            .font(.body)
                    } header: {
                        Text("Name")
                    } footer: {
                        Text("Give your mood a name (e.g., Excited, Anxious, Peaceful)")
                    }
                }
                
                if currentCustomMoodCount < maxCustomMoods {
                    Section {
                        Button {
                            showEmojiPicker = true
                        } label: {
                            HStack {
                                Text("Choose Emoji")
                                Spacer()
                                Text(selectedEmoji)
                                    .font(.system(size: 40))
                            }
                        }
                    } header: {
                        Text("Emoji")
                    } footer: {
                        Text("Select an emoji that represents this mood")
                    }
                    
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(colorOptions, id: \.name) { option in
                                    Button {
                                        selectedColor = option.color
                                    } label: {
                                        VStack(spacing: 4) {
                                            Circle()
                                                .fill(option.color)
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Circle()
                                                        .stroke(selectedColor == option.color ? Color.primary : Color.clear, lineWidth: 3)
                                                )
                                            Text(option.name)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    } header: {
                        Text("Color")
                    } footer: {
                        Text("Choose a color theme for this mood")
                    }
                    
                    Section {
                        VStack(spacing: 16) {
                            Text(selectedEmoji)
                                .font(.system(size: 60))
                                .frame(width: 100, height: 100)
                                .background(
                                    Circle()
                                        .fill(selectedColor.opacity(0.2))
                                )
                            
                            Text(moodName.isEmpty ? "Preview" : moodName)
                                .font(.headline)
                                .foregroundStyle(moodName.isEmpty ? .secondary : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    } header: {
                        Text("Preview")
                    }
                }
            }
            .navigationTitle("Create Custom Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCustomMood()
                    }
                    .disabled(moodName.isEmpty || currentCustomMoodCount >= maxCustomMoods)
                }
            }
            .sheet(isPresented: $showEmojiPicker) {
                EmojiPickerSheet(selectedEmoji: $selectedEmoji, availableEmojis: availableEmojis)
            }
        }
    }
    
    private func saveCustomMood() {
        let colorHex = selectedColor.toHex()
        let customMood = CustomMood(
            name: moodName,
            emoji: selectedEmoji,
            color: colorHex
        )
        onSave(customMood)
        dismiss()
    }
}

// MARK: - Emoji Picker Sheet
struct EmojiPickerSheet: View {
    @Binding var selectedEmoji: String
    let availableEmojis: [String]
    @Environment(\.dismiss) private var dismiss
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 6)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(availableEmojis, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                            dismiss()
                        } label: {
                            Text(emoji)
                                .font(.system(size: 35))
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(selectedEmoji == emoji ? Color.accentColor.opacity(0.2) : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#0000FF" }
        
        let r = Float(components[0])
        let g = Float(components[safe: 1] ?? 0)
        let b = Float(components[safe: 2] ?? 0)
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
    
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
            (a, r, g, b) = (255, 0, 0, 255)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    CustomMoodCreatorView(onSave: { _ in }, currentCustomMoodCount: 0)
}

