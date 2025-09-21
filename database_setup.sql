-- Database setup script for Job and Task management system
-- Run this in your Supabase SQL editor

-- Create jobs table
CREATE TABLE IF NOT EXISTS public.jobs (
  id text NOT NULL,
  name text NOT NULL,
  description text NULL,
  creation_time timestamp with time zone NULL,
  status character varying(50) NULL DEFAULT 'active'::character varying,
  CONSTRAINT jobs_pkey PRIMARY KEY (id)
) TABLESPACE pg_default;

-- Create index for jobs status
CREATE INDEX IF NOT EXISTS idx_jobs_status ON public.jobs USING btree (status) TABLESPACE pg_default;

-- Add job_id column to existing tasks table (if it doesn't exist)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tasks' AND column_name = 'job_id') THEN
        ALTER TABLE public.tasks ADD COLUMN job_id character varying(50) NULL;
    END IF;
END $$;

-- Create index for tasks job_id (if it doesn't exist)
CREATE INDEX IF NOT EXISTS idx_tasks_job_id ON public.tasks USING btree (job_id) TABLESPACE pg_default;

-- Insert some sample jobs for testing
INSERT INTO public.jobs (id, name, description, creation_time, status) VALUES
('J001', 'Sample Job 1', 'This is a sample job for testing', NOW(), 'active'),
('J002', 'Sample Job 2', 'Another sample job', NOW(), 'active')
ON CONFLICT (id) DO NOTHING;
