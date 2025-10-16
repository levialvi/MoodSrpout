//
//  SupabaseImageView.swift
//  MoodSprout
//
//  Created by Levi on 9/24/25.
//

import SwiftUI

/// A view that displays images from Supabase storage with fallback to SF Symbols
struct SupabaseImageView: View {
    let imageName: String
    let fallbackSystemImage: String
    let imageData: Data?
    
    init(imageName: String, fallbackSystemImage: String, imageData: Data?) {
        self.imageName = imageName
        self.fallbackSystemImage = fallbackSystemImage
        self.imageData = imageData
    }
    
    var body: some View {
        Group {
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onAppear {
                        print("🖼️ Displaying Supabase image: \(imageName) (\(imageData.count) bytes)")
                    }
            } else {
                Image(systemName: fallbackSystemImage)
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                    .onAppear {
                        print("⚠️ Using fallback image for: \(imageName), imageData is nil: \(imageData == nil)")
                    }
            }
        }
    }
}

#Preview {
    SupabaseImageView(
        imageName: "SunHappy",
        fallbackSystemImage: "face.smiling",
        imageData: nil
    )
}
