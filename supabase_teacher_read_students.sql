-- ============================================================
-- Run this in Supabase Dashboard → SQL Editor (same project that has "students" and "teacher_month_students")
-- ============================================================
-- This policy lets teachers read basic profile data (name, email, school, etc.)
-- only for students who are subscribed to them in teacher_month_students.
-- Students continue to see only their own row (existing RLS).

CREATE POLICY "Teachers can view subscribed students"
  ON public.students FOR SELECT TO authenticated
  USING (
    student_id IN (
      SELECT student_id FROM public.teacher_month_students WHERE teacher_id = auth.uid()
    )
  );
