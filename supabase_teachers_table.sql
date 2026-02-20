-- ============================================================
-- Run this in Supabase Dashboard → SQL Editor → New query
-- ============================================================
-- Creates the "teachers" table so teacher sign-up data is stored.

-- 1) Create the teachers table
-- If you get an error about auth.users, use the version below (comment this block and uncomment the next).
CREATE TABLE IF NOT EXISTS public.teachers (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  email         TEXT NOT NULL,
  school        TEXT,
  subject       TEXT,
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- Alternative if REFERENCES auth.users fails (run this instead of the block above):
-- CREATE TABLE IF NOT EXISTS public.teachers (
--   id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   user_id       UUID NOT NULL UNIQUE,
--   name          TEXT NOT NULL,
--   email         TEXT NOT NULL,
--   school        TEXT,
--   subject       TEXT,
--   created_at    TIMESTAMPTZ DEFAULT now()
-- );

-- 2) Optional: create an index for fast lookups by user_id (for sign-in)
CREATE INDEX IF NOT EXISTS idx_teachers_user_id ON public.teachers(user_id);

-- 3) Enable Row Level Security (RLS)
ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;

-- 4) Policy: authenticated users can insert their own teacher row (user_id = auth.uid())
CREATE POLICY "Users can insert own teacher row"
  ON public.teachers
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- 5) Policy: users can read their own teacher row
CREATE POLICY "Users can read own teacher row"
  ON public.teachers
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- 6) Policy: users can update their own teacher row (optional, for profile edits later)
CREATE POLICY "Users can update own teacher row"
  ON public.teachers
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Done. After running this, teacher sign-up will save rows into "teachers".
