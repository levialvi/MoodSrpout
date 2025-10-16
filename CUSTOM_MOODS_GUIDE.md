# Custom Moods Feature Guide

## Overview

MoodSprout now supports custom moods! Users can create their own personalized moods with custom names, emojis, and colors, alongside the existing predefined moods (Happy, Sad, Angry, Worried).

## What's New

### 1. **Custom Mood Creation**
- Tap the "Create Custom Mood" button in the mood picker
- Choose a name for your mood (e.g., "Excited", "Anxious", "Peaceful", "Energized")
- Select from 150+ emojis to represent your mood
- Pick from 12 color themes to personalize the look
- Preview your custom mood before saving

### 2. **Seamless Integration**
- Custom moods appear in the mood picker alongside predefined moods
- All existing features work with custom moods:
  - Daily mood tracking
  - History view
  - Analytics and overview
  - Notes and journal entries
  - Supabase cloud sync

### 3. **Visual Design**
- Custom moods display with their chosen emoji and color
- Color-coded throughout the app for easy recognition
- Clean separation between predefined and custom moods in the picker

## Implementation Details

### Architecture Changes

#### Models (`MoodModels.swift`)
- Added `CustomMood` struct with properties:
  - `id`: Unique identifier
  - `name`: User-defined mood name
  - `emoji`: Selected emoji character
  - `color`: Hex color string
  - `createdAt`: Creation timestamp

- Updated `MoodEntry` to support both predefined and custom moods:
  - Now has optional `moodType` and `customMoodId` fields
  - Only one is populated at a time (enforced by initializers)

#### Storage (`MoodModels.swift`)
- Added `loadCustomMoods()` and `saveCustomMoods()` methods
- Custom moods stored separately in UserDefaults
- Persists across app launches

#### Services

**MoodService.swift**
- Added `customMoods` published property
- New methods:
  - `addCustomMood(customMoodId:notes:)` - Log a custom mood entry
  - `createCustomMood(_:)` - Create new custom mood definition
  - `deleteCustomMood(_:)` - Remove custom mood
  - `getCustomMood(by:)` - Retrieve custom mood by ID

**SupabaseService.swift**
- Updated to sync both predefined and custom moods
- New `custom_moods` table operations:
  - `saveCustomMood(_:)` - Upload custom mood definition
  - `fetchCustomMoods()` - Download custom moods
  - `deleteCustomMood(id:)` - Delete from cloud
- Updated `moods` table to support `custom_mood_id` field

#### Views

**CustomMoodCreatorView.swift** (NEW)
- Beautiful form-based interface for creating custom moods
- Emoji picker sheet with 150+ emojis organized in a grid
- Color selector with 12 predefined color options
- Live preview of the mood as you design it
- Validation to ensure mood name is provided

**MoodPickerView (EmojiPickerView.swift)**
- Updated to show both predefined and custom moods
- Sections: "Default Moods" and "Your Custom Moods"
- "Create Custom Mood" button at the bottom
- Proper callbacks for both mood types

**ContentView.swift**
- Updated `TodayView` to display custom mood emoji and color
- Updated `HistoryView` to show custom moods in history
- Wire up custom mood callbacks in mood picker sheet

### Database Schema

#### New Table: `custom_moods`
```sql
CREATE TABLE custom_moods (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    emoji TEXT NOT NULL,
    color TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE
);
```

#### Updated Table: `moods`
```sql
CREATE TABLE moods (
    id UUID PRIMARY KEY,
    mood_type TEXT,                    -- Now optional
    custom_mood_id UUID,                -- New field
    notes TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    -- Constraint: Either mood_type OR custom_mood_id must be set
    CHECK (
        (mood_type IS NOT NULL AND custom_mood_id IS NULL) OR
        (mood_type IS NULL AND custom_mood_id IS NOT NULL)
    )
);
```

## Setup Instructions

### For New Projects
1. Run `supabase-schema.sql` in your Supabase SQL Editor
2. The schema includes both `moods` and `custom_moods` tables
3. Start using custom moods immediately

### For Existing Projects
1. Run `supabase-migration-custom-moods.sql` in your Supabase SQL Editor
2. This safely migrates your existing data:
   - Adds `custom_moods` table
   - Adds `custom_mood_id` column to `moods`
   - Makes `mood_type` nullable
   - Updates constraints and indexes
   - Updates views and functions
3. All existing mood entries remain intact

## User Experience Flow

### Creating a Custom Mood
1. Tap the "+" button in the app
2. Scroll to the bottom of the mood picker
3. Tap "Create Custom Mood"
4. Enter a mood name
5. Tap "Choose Emoji" and select an emoji
6. Scroll through colors and tap to select
7. Preview your mood
8. Tap "Save"

### Using a Custom Mood
1. Tap the "+" button to log a mood
2. Your custom moods appear in the "Your Custom Moods" section
3. Tap any custom mood to log it
4. Add notes if desired
5. The mood is saved and synced

### Viewing Custom Moods
- **Today Tab**: Shows custom mood emoji and name with custom color
- **History Tab**: Custom moods listed with emoji and color-coded name
- **Overview Tab**: Custom moods included in statistics

## Code Examples

### Creating a Custom Mood
```swift
let customMood = CustomMood(
    name: "Energized",
    emoji: "⚡",
    color: "#FF9500"
)
moodService.createCustomMood(customMood)
```

### Logging a Custom Mood Entry
```swift
moodService.addCustomMood(
    customMoodId: customMood.id,
    notes: "Great workout this morning!"
)
```

### Retrieving a Custom Mood
```swift
if let customMoodId = moodEntry.customMoodId {
    let customMood = moodService.getCustomMood(by: customMoodId)
    // Use customMood.name, customMood.emoji, customMood.color
}
```

## Color Palette

The app provides 12 carefully selected colors:
- Blue (#007AFF)
- Purple (#AF52DE)
- Pink (#FF2D55)
- Red (#FF3B30)
- Orange (#FF9500)
- Yellow (#FFCC00)
- Green (#34C759)
- Teal (#5AC8FA)
- Indigo (#5856D6)
- Mint (#00C7BE)
- Cyan (#32ADE6)
- Brown (#A2845E)

## Technical Highlights

### Type Safety
- Strong typing with Swift structs and enums
- Compile-time safety for mood types
- Optional handling for backward compatibility

### Data Consistency
- Database constraints ensure data integrity
- Either mood_type OR custom_mood_id (never both)
- Foreign key relationship for referential integrity

### Offline Support
- Custom moods cached locally in UserDefaults
- Syncs with Supabase when online
- Graceful fallbacks for network issues

### Performance
- Efficient lookups by UUID
- Indexed database columns
- Minimal memory footprint

## Future Enhancements

Potential features for future updates:
- Edit existing custom moods
- Reorder custom moods
- Share custom moods with other users
- Import/export custom mood sets
- Custom mood categories
- Mood streaks for custom moods
- Search and filter by custom moods

## Troubleshooting

### Custom moods not syncing?
- Check your Supabase connection
- Verify the `custom_moods` table exists
- Run the migration script if upgrading

### Custom moods not appearing?
- Ensure `loadCustomMoods()` is called on app launch
- Check UserDefaults for local storage
- Verify the custom mood was saved successfully

### Colors not displaying correctly?
- Verify hex color strings are valid
- Check the `Color(hex:)` extension is working
- Ensure color values are properly formatted

## Support

For issues or questions about custom moods:
1. Check the console logs for error messages
2. Verify database schema is up to date
3. Ensure Supabase policies allow operations
4. Review this guide for proper usage

---

**Happy Mood Tracking! 🌱**

