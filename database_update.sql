-- Add new columns to tasks table for timer persistence
-- Run this SQL script in your Supabase SQL editor

-- Add accumulated_seconds column
ALTER TABLE public.tasks 
ADD COLUMN IF NOT EXISTS accumulated_seconds INTEGER NULL DEFAULT 0;

-- Add last_pause_time column  
ALTER TABLE public.tasks 
ADD COLUMN IF NOT EXISTS last_pause_time TIMESTAMP WITH TIME ZONE NULL;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_tasks_accumulated_seconds ON public.tasks USING btree (accumulated_seconds) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_tasks_last_pause_time ON public.tasks USING btree (last_pause_time) TABLESPACE pg_default;

-- Update existing tasks to have default values
UPDATE public.tasks 
SET accumulated_seconds = 0 
WHERE accumulated_seconds IS NULL;

-- Verify the changes
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'tasks' 
AND table_schema = 'public'
ORDER BY ordinal_position;
