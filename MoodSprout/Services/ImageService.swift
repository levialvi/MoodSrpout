//
//  ImageService.swift
//  MoodSprout
//
//  Created by Levi on 9/24/25.
//

import Foundation
import SwiftUI
import Combine
import Supabase

/// Service responsible for loading and caching mood images from Supabase
@MainActor
final class ImageService: ObservableObject {
    
    static let shared = ImageService()
    
    @Published var moodImages: [String: Data] = [:]
    
    private let supabaseService = SupabaseService.shared
    private let bucketName = "mood-images"
    private let imageNames = ["SunHappy", "SunSad", "SunAngry", "SunWorried"]
    
    private init() {}
    
    /// Loads all mood images from Supabase storage
    func loadMoodImages() async {
        print("🖼️ Loading mood images from Supabase...")
        
        var loadedImages: [String: Data] = [:]
        
        print("🎯 Attempting to load images from \(bucketName) bucket...")
        
        // First, try to list files in the bucket (this might also fail if permissions are restricted)
        do {
            let files = try await supabaseService.listFiles(bucketName: bucketName)
            print("📁 Files in mood-images bucket:")
            for file in files {
                print("  - \(file.name)")
            }
        } catch {
            print("❌ Failed to list files in bucket (this is OK if bucket is public): \(error)")
        }
        
        // Try to download each image
        for imageName in imageNames {
            // Try multiple extensions
            let extensions = ["png", "jpg", "jpeg", "webp"]
            var imageLoaded = false
            
            for ext in extensions {
                do {
                    let imageData = try await supabaseService.downloadFile(
                        bucketName: bucketName,
                        path: "\(imageName).\(ext)"
                    )
                    loadedImages[imageName] = imageData
                    print("✅ Loaded \(imageName) with .\(ext) extension (\(imageData.count) bytes)")
                    imageLoaded = true
                    break
                } catch {
                    print("❌ Failed to load \(imageName).\(ext): \(error)")
                }
            }
            
            if !imageLoaded {
                print("⚠️ Could not load any version of \(imageName)")
            }
        }
        
        moodImages = loadedImages
        print("🎉 Loaded \(loadedImages.count) mood images successfully")
        
        if loadedImages.isEmpty {
            print("⚠️ No images were loaded. Check that:")
            print("   1. The bucket 'mood-images' exists and is public")
            print("   2. Files are named: SunHappy.png, SunSad.png, SunAngry.png, SunWorried.png")
            print("   3. The anon key has read access to the storage bucket")
        }
    }
    
    /// Gets image data for a specific mood type
    func getImageData(for moodType: MoodType) -> Data? {
        return moodImages[moodType.imageName]
    }
}
