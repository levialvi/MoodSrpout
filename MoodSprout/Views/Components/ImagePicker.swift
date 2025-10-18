//
//  ImagePicker.swift
//  MoodSprout
//
//  A SwiftUI wrapper around UIImagePickerController with editing enabled
//  so users can crop after selecting a photo.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var allowsEditing: Bool = true
    var onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = allowsEditing
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let key: UIImagePickerController.InfoKey = parent.allowsEditing ? .editedImage : .originalImage
            if let image = info[key] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }
    }
}


