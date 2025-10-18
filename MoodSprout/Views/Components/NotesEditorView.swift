//
//  NotesEditorView.swift
//  MoodSprout
//
//  Created by Levi on 9/24/25.
//

import SwiftUI

struct NotesEditorView: View {
    let currentNotes: String?
    let moodType: MoodType?
    let customMoodId: UUID?
    let onSave: (String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var notesText: String = ""
    @StateObject private var moodService = MoodService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header with mood info
                VStack(spacing: 12) {
                    if let customMoodId = customMoodId,
                       let customMood = moodService.getCustomMood(by: customMoodId) {
                        // Custom mood display
                        if let data = customMood.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else {
                            Text(customMood.emoji)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(Color(hex: customMood.color).opacity(0.2))
                                )
                        }
                        Text("Add notes for \(customMood.name)")
                            .font(.headline)
                            .foregroundStyle(Color(hex: customMood.color))
                    } else if let moodType = moodType {
                        // Predefined mood display
                        Text("😊")
                            .font(.system(size: 40))
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color.accentColor.opacity(0.2))
                            )
                        Text("Add notes for \(moodType.displayName)")
                            .font(.headline)
                    }
                }
                .padding(.top)
                
                // Notes input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $notesText)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finalNotes = notesText.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(finalNotes.isEmpty ? nil : finalNotes)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            notesText = currentNotes ?? ""
        }
    }
}

#Preview {
    NotesEditorView(
        currentNotes: "Feeling great today!",
        moodType: .happy,
        customMoodId: nil,
        onSave: { _ in }
    )
}
