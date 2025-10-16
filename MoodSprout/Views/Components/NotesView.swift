import SwiftUI

struct NotesView: View {
    let moodType: MoodType
    var onSave: (String?) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var notes: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Selected Mood Display
                VStack(spacing: 12) {
                    Image(moodType.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    
                    Text("Mood recorded: \(moodType.displayName)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)
                
                // Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add a note (optional)")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    TextField("How are you feeling? What's on your mind?", text: $notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...8)
                        .focused($isTextFieldFocused)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Notes")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        onSave(nil)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(notes.isEmpty ? nil : notes)
                        dismiss()
                    }
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
}

#Preview {
    NotesView(moodType: .happy) { _ in }
}
