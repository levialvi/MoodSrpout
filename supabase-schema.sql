-- MoodSprout Supabase Schema
-- Run this in your Supabase SQL Editor

-- Create custom_moods table for user-defined moods
CREATE TABLE IF NOT EXISTS custom_moods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    emoji TEXT NOT NULL,
    color TEXT NOT NULL, -- Hex color string
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create moods table (updated to support both predefined and custom moods)
CREATE TABLE IF NOT EXISTS moods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mood_type TEXT CHECK (mood_type IN ('happy', 'sad', 'angry', 'worried')),
    custom_mood_id UUID REFERENCES custom_moods(id) ON DELETE CASCADE,
    notes TEXT,
    image_url TEXT, -- For storing image URLs if you want to upload images to Supabase Storage
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- Ensure either mood_type or custom_mood_id is set, but not both
    CHECK (
        (mood_type IS NOT NULL AND custom_mood_id IS NULL) OR
        (mood_type IS NULL AND custom_mood_id IS NOT NULL)
    )
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_moods_created_at ON moods(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_moods_mood_type ON moods(mood_type);
CREATE INDEX IF NOT EXISTS idx_moods_custom_mood_id ON moods(custom_mood_id);
CREATE INDEX IF NOT EXISTS idx_custom_moods_created_at ON custom_moods(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_moods ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (for now - no authentication)
-- In production, you'd want to add user authentication
CREATE POLICY "Allow all operations on moods" ON moods
    FOR ALL USING (true);

CREATE POLICY "Allow all operations on custom_moods" ON custom_moods
    FOR ALL USING (true);

-- Optional: Create a view for mood statistics (updated to include custom moods)
CREATE OR REPLACE VIEW mood_stats AS
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

-- Optional: Create a function to get mood trends (updated to include custom moods)
CREATE OR REPLACE FUNCTION get_mood_trends(days_back INTEGER DEFAULT 30)
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
