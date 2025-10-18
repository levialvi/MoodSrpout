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
            ZStack {
                LinearGradient.plantSoftGradient.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header with mood info
                    VStack(spacing: 24) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 24))
                                .foregroundColor(.plantGreen)
                            Text("Add Notes")
                                .font(.plantHeadline)
                                .foregroundColor(.plantGreen)
                            Spacer()
                        }
                        
                        VStack(spacing: 16) {
                            if let customMoodId = customMoodId,
                               let customMood = moodService.getCustomMood(by: customMoodId) {
                                // Custom mood display
                                if let data = customMood.imageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color(hex: customMood.color).opacity(0.3), lineWidth: 3)
                                        )
                                } else {
                                    Text(customMood.emoji)
                                        .font(.system(size: 50))
                                        .frame(width: 80, height: 80)
                                        .background(
                                            Circle()
                                                .fill(Color(hex: customMood.color).opacity(0.15))
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color(hex: customMood.color).opacity(0.3), lineWidth: 3)
                                                )
                                        )
                                }
                                Text("Add notes for \(customMood.name)")
                                    .font(.plantSubheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(hex: customMood.color))
                            } else if let moodType = moodType {
                                // Predefined mood display
                                Text("😊")
                                    .font(.system(size: 50))
                                    .frame(width: 80, height: 80)
                                    .background(
                                        Circle()
                                            .fill(Color.plantGreen.opacity(0.15))
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.plantGreen.opacity(0.3), lineWidth: 3)
                                            )
                                    )
                                Text("Add notes for \(moodType.displayName)")
                                    .font(.plantSubheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.plantGreen)
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient.plantSoftGradient)
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
                    
                    // Notes input
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.system(size: 18))
                                .foregroundColor(.plantGreen)
                            Text("Your Notes")
                                .font(.plantSubheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.plantGreen)
                            Spacer()
                        }
                        
                        TextEditor(text: $notesText)
                            .frame(minHeight: 140)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.plantBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.plantGreen.opacity(0.2), lineWidth: 1)
                            )
                            .font(.plantBody)
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Add Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plantGreen)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finalNotes = notesText.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(finalNotes.isEmpty ? nil : finalNotes)
                        dismiss()
                    }
                    .font(.plantBody)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.plantGreen)
                    )
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
