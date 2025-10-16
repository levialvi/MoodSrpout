-- Migration Script: Add Custom Moods Support
-- Run this in your Supabase SQL Editor if you already have an existing moods table
-- This script will update your database schema to support custom moods

-- Step 1: Create the custom_moods table
CREATE TABLE IF NOT EXISTS custom_moods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    emoji TEXT NOT NULL,
    color TEXT NOT NULL, -- Hex color string
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 2: Add new column to moods table
ALTER TABLE moods 
ADD COLUMN IF NOT EXISTS custom_mood_id UUID REFERENCES custom_moods(id) ON DELETE CASCADE;

-- Step 3: Make mood_type nullable (it was previously NOT NULL)
ALTER TABLE moods 
ALTER COLUMN mood_type DROP NOT NULL;

-- Step 4: Remove old CHECK constraint if it exists
ALTER TABLE moods 
DROP CONSTRAINT IF EXISTS moods_mood_type_check;

-- Step 5: Add new CHECK constraint for mood_type values
-- Including all possible values that might exist in your database
ALTER TABLE moods 
ADD CONSTRAINT moods_mood_type_check 
CHECK (mood_type IN ('happy', 'sad', 'angry', 'worried', 'anxious', 'excited', 'calm', 'frustrated', 'grateful'));

-- Step 6: Add CHECK constraint to ensure either mood_type or custom_mood_id is set
ALTER TABLE moods 
ADD CONSTRAINT moods_type_or_custom_check 
CHECK (
    (mood_type IS NOT NULL AND custom_mood_id IS NULL) OR
    (mood_type IS NULL AND custom_mood_id IS NOT NULL)
);

-- Step 7: Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_moods_custom_mood_id ON moods(custom_mood_id);
CREATE INDEX IF NOT EXISTS idx_custom_moods_created_at ON custom_moods(created_at);

-- Step 8: Enable Row Level Security for custom_moods
ALTER TABLE custom_moods ENABLE ROW LEVEL SECURITY;

-- Step 9: Create policy for custom_moods (allowing all operations for now)
-- In production, you'd want to add user authentication
CREATE POLICY "Allow all operations on custom_moods" ON custom_moods
    FOR ALL USING (true);

-- Step 10: Drop and recreate the mood_stats view to include custom moods
DROP VIEW IF EXISTS mood_stats;
CREATE VIEW mood_stats AS
SELECT 
    COALESCE(m.mood_type, cm.name) as mood_name,
    COALESCE(m.mood_type, 'custom') as mood_type,
    m.custom_mood_id,
    COUNT(*) as count,
    DATE_TRUNC('day', m.created_at) as date
FROM moods m
LEFT JOIN custom_moods cm ON m.custom_mood_id = cm.id
GROUP BY m.mood_type, cm.name, m.custom_mood_id, DATE_TRUNC('day', m.created_at)
ORDER BY date DESC;

-- Step 11: Drop and recreate the get_mood_trends function to include custom moods
DROP FUNCTION IF EXISTS get_mood_trends(INTEGER);
CREATE FUNCTION get_mood_trends(days_back INTEGER DEFAULT 30)
RETURNS TABLE (
    mood_name TEXT,
    mood_type TEXT,
    count BIGINT,
    percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(m.mood_type, cm.name) as mood_name,
        COALESCE(m.mood_type, 'custom') as mood_type,
        COUNT(*) as count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
    FROM moods m
    LEFT JOIN custom_moods cm ON m.custom_mood_id = cm.id
    WHERE m.created_at >= NOW() - INTERVAL '1 day' * days_back
    GROUP BY m.mood_type, cm.name
    ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql;

-- Step 12 (OPTIONAL): Migrate old mood types to custom moods
-- If you want to convert 'anxious', 'excited', 'calm', 'frustrated', 'grateful' to custom moods, 
-- uncomment and run the following:

/*
-- Create custom moods for the old mood types
INSERT INTO custom_moods (id, name, emoji, color, created_at)
VALUES 
    (gen_random_uuid(), 'Anxious', '😰', '#FF9500', NOW()),
    (gen_random_uuid(), 'Excited', '🤩', '#FFCC00', NOW()),
    (gen_random_uuid(), 'Calm', '😌', '#5AC8FA', NOW()),
    (gen_random_uuid(), 'Frustrated', '😤', '#FF3B30', NOW()),
    (gen_random_uuid(), 'Grateful', '🙏', '#34C759', NOW())
ON CONFLICT DO NOTHING;

-- Update mood entries to reference the new custom moods
UPDATE moods m
SET 
    custom_mood_id = cm.id,
    mood_type = NULL
FROM custom_moods cm
WHERE m.mood_type = 'anxious' AND cm.name = 'Anxious';

UPDATE moods m
SET 
    custom_mood_id = cm.id,
    mood_type = NULL
FROM custom_moods cm
WHERE m.mood_type = 'excited' AND cm.name = 'Excited';

UPDATE moods m
SET 
    custom_mood_id = cm.id,
    mood_type = NULL
FROM custom_moods cm
WHERE m.mood_type = 'calm' AND cm.name = 'Calm';

UPDATE moods m
SET 
    custom_mood_id = cm.id,
    mood_type = NULL
FROM custom_moods cm
WHERE m.mood_type = 'frustrated' AND cm.name = 'Frustrated';

UPDATE moods m
SET 
    custom_mood_id = cm.id,
    mood_type = NULL
FROM custom_moods cm
WHERE m.mood_type = 'grateful' AND cm.name = 'Grateful';
*/

-- Migration completed successfully!
-- You can now use custom moods in your MoodSprout app

-- NOTE: The app currently only uses 4 predefined mood types (happy, sad, angry, worried).
-- If you have existing mood entries with other types (anxious, excited, calm, frustrated, grateful),
-- they will continue to work, but you may want to:
-- 1. Keep them as-is (they'll still be stored but not selectable in the new UI)
-- 2. Run Step 12 above to convert them to custom moods
-- 3. Manually update them to one of the 4 core mood types

