# MoodSprout

A beautiful and intuitive mood tracking iOS app built with SwiftUI and Supabase.

## 📁 Project Structure

```
MoodSprout/
├── Core/
│   ├── Models/
│   │   └── MoodModels.swift              # Data models (MoodEntry, CustomMood, MoodType)
│   └── Storage/
│       └── StorageService.swift          # Local data persistence
├── Services/
│   ├── SupabaseService.swift             # Supabase API operations
│   ├── ImageService.swift                # Image loading and caching
│   └── MoodService.swift                 # Mood data management
├── Views/
│   ├── Components/
│   │   ├── SupabaseImageView.swift      # Reusable image component
│   │   ├── EmojiPickerView.swift        # Mood selection interface
│   │   ├── CustomMoodCreatorView.swift  # Custom mood creation interface
│   │   ├── NotesView.swift              # Notes input view
│   │   └── OverviewView.swift           # Mood analytics view
│   └── Screens/
│       └── ContentView.swift            # Main app interface
├── Assets.xcassets/                     # App icons and colors
└── MoodSproutApp.swift                 # App entry point
```

## 🏗️ Architecture

The app follows a clean architecture pattern with clear separation of concerns:

### **Core Layer**
- **Models**: Data structures and business logic
- **Storage**: Local data persistence using UserDefaults

### **Services Layer**
- **SupabaseService**: Handles all Supabase API operations
- **ImageService**: Manages image loading and caching from Supabase Storage
- **MoodService**: Orchestrates mood data operations

### **Views Layer**
- **Components**: Reusable UI components
- **Screens**: Main app screens and navigation

## 🚀 Features

- **Mood Tracking**: Log daily moods with 4 predefined emotion options (Happy, Sad, Angry, Worried)
- **Custom Moods**: Create and use your own custom moods with personalized emojis and colors
- **Visual Interface**: Beautiful Supabase-hosted images for predefined moods
- **History View**: Browse past mood entries (both predefined and custom)
- **Analytics**: Overview of mood patterns
- **Offline Support**: Local storage with Supabase sync
- **Modern UI**: Built with SwiftUI following iOS design guidelines

## 🛠️ Technical Stack

- **SwiftUI**: Modern declarative UI framework
- **Supabase**: Backend-as-a-Service for data and storage
- **Combine**: Reactive programming for data flow
- **UserDefaults**: Local data persistence

## 📱 Mood Types

### Predefined Moods
The app includes 4 core mood types:
- 😊 **Happy** - SunHappy.png
- 😢 **Sad** - SunSad.png  
- 😠 **Angry** - SunAngry.png
- 😰 **Worried** - SunWorried.png

### Custom Moods
Users can create up to 10 custom moods with:
- **Custom Name**: Choose any mood name (e.g., "Excited", "Anxious", "Peaceful")
- **Custom Emoji**: Select from 150+ emojis to represent the mood
- **Custom Color**: Pick from 12 color themes
- **Full Integration**: Custom moods work seamlessly with tracking, history, and analytics

## 🔧 Setup

### Database Setup
1. **Supabase Configuration**: Update the Supabase URL and API key in `SupabaseService.swift`
2. **Run Database Schema**: Execute `supabase-schema.sql` in your Supabase SQL Editor
   - For new projects: Use `supabase-schema.sql`
   - For existing projects: Use `supabase-migration-custom-moods.sql` to migrate
3. **Storage Setup**: Create a public `mood-images` bucket in Supabase Storage
4. **Image Upload**: Upload mood images with exact names: `SunHappy.png`, `SunSad.png`, `SunAngry.png`, `SunWorried.png`

### Database Schema
The app uses two main tables:
- **moods**: Stores mood entries (both predefined and custom)
- **custom_moods**: Stores custom mood definitions (name, emoji, color)

## 🎨 Design Principles

- **Clean Architecture**: Separation of concerns with distinct layers
- **Service-Oriented**: Business logic encapsulated in services
- **Reactive UI**: SwiftUI with ObservableObject for state management
- **Error Handling**: Graceful fallbacks for network and storage issues
- **Performance**: Efficient image caching and local storage

## 📊 Data Flow

1. **User Interaction** → Views trigger service methods
2. **Service Layer** → Handles business logic and API calls
3. **Storage Layer** → Persists data locally and syncs with Supabase
4. **UI Updates** → Reactive updates through @Published properties

This architecture ensures maintainability, testability, and scalability as the app grows.