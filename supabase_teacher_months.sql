-- ============================================================
-- Run this in Supabase Dashboard → SQL Editor (your teacher project)
-- ============================================================
-- Table: teacher_months
-- Custom table for months created by the teacher (per grade).
-- Each row = one month (e.g. Grade 10 – Month 1). Content for that month
-- is stored in teacher_month_content (sessions, pdfs, quizzes, assessments).

CREATE TABLE IF NOT EXISTS public.teacher_months (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id      UUID NOT NULL,
  teacher_name   TEXT NOT NULL,
  grade          INT NOT NULL,
  month_number   INT NOT NULL,
  cover_photo_url TEXT,
  created_at     TIMESTAMPTZ DEFAULT now(),
  UNIQUE(teacher_id, grade, month_number)
);

CREATE INDEX IF NOT EXISTS idx_teacher_months_teacher_grade
  ON public.teacher_months(teacher_id, grade);

ALTER TABLE public.teacher_months ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can insert own months"
  ON public.teacher_months FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = teacher_id);

CREATE POLICY "Teachers can read own months"
  ON public.teacher_months FOR SELECT TO authenticated
  USING (auth.uid() = teacher_id);

CREATE POLICY "Teachers can update own months"
  ON public.teacher_months FOR UPDATE TO authenticated
  USING (auth.uid() = teacher_id)
  WITH CHECK (auth.uid() = teacher_id);

CREATE POLICY "Teachers can delete own months"
  ON public.teacher_months FOR DELETE TO authenticated
  USING (auth.uid() = teacher_id);
