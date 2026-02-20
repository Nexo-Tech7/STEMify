-- ============================================================
-- Run this in Supabase Dashboard → SQL Editor (same teacher project)
-- ============================================================
-- Table: teacher_month_students
-- When a student pays for a month, the teacher adds the student's ID here.
-- Student ID is the one generated at student signup (e.g. STEM-2025-123456).

CREATE TABLE IF NOT EXISTS public.teacher_month_students (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id    UUID NOT NULL,
  teacher_name  TEXT NOT NULL,
  month_number  INT NOT NULL,
  student_id    TEXT NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE(teacher_id, month_number, student_id)
);

CREATE INDEX IF NOT EXISTS idx_teacher_month_students_student
  ON public.teacher_month_students(student_id);

CREATE INDEX IF NOT EXISTS idx_teacher_month_students_teacher_month
  ON public.teacher_month_students(teacher_id, month_number);

ALTER TABLE public.teacher_month_students ENABLE ROW LEVEL SECURITY;

-- Teachers can manage their own student list
CREATE POLICY "Teachers can insert own month students"
  ON public.teacher_month_students FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = teacher_id);

CREATE POLICY "Teachers can read own month students"
  ON public.teacher_month_students FOR SELECT TO authenticated
  USING (auth.uid() = teacher_id);

CREATE POLICY "Teachers can delete own month students"
  ON public.teacher_month_students FOR DELETE TO authenticated
  USING (auth.uid() = teacher_id);

-- Students (main project dashboard) read with anon key: allow public read so student can see where they are added
CREATE POLICY "Allow read for student dashboard"
  ON public.teacher_month_students FOR SELECT TO anon
  USING (true);

-- Also allow read for teacher_month_content so students can load sessions, pdfs, quizzes, assessments
CREATE POLICY "Allow read content for student dashboard"
  ON public.teacher_month_content FOR SELECT TO anon
  USING (true);
