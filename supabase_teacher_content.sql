-- ============================================================
-- Run this in Supabase Dashboard → SQL Editor (your teacher project)
-- ============================================================
-- 1) Table: teacher_month_content
--    Stores teacher name + sessions, pdfs, quizzes, assessments per month.
--    Sessions/PDFs/Assessments: uploaded files → stored as URLs (links).
--    Quizzes: stored as links only.

CREATE TABLE IF NOT EXISTS public.teacher_month_content (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id    UUID NOT NULL,
  teacher_name  TEXT NOT NULL,
  month_number  INT NOT NULL,
  sessions      JSONB DEFAULT '[]',
  pdfs          JSONB DEFAULT '[]',
  quizzes       JSONB DEFAULT '[]',
  assessments   JSONB DEFAULT '[]',
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE(teacher_id, month_number)
);

-- Each array item: { "id": "uuid", "name": "display name", "url": "https://..." }

CREATE INDEX IF NOT EXISTS idx_teacher_month_content_lookup
  ON public.teacher_month_content(teacher_id, month_number);

ALTER TABLE public.teacher_month_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can insert own content"
  ON public.teacher_month_content FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = teacher_id);

CREATE POLICY "Teachers can read own content"
  ON public.teacher_month_content FOR SELECT TO authenticated
  USING (auth.uid() = teacher_id);

CREATE POLICY "Teachers can update own content"
  ON public.teacher_month_content FOR UPDATE TO authenticated
  USING (auth.uid() = teacher_id)
  WITH CHECK (auth.uid() = teacher_id);

-- 2) Storage bucket for uploaded files (Sessions, PDFs, Assessments)
--    First create the bucket in Dashboard: Storage → New bucket →
--    Name: teacher-content, Public: ON, File size limit: 50 MB (optional).
--    Then run the policies below.

-- Storage policies (create bucket "teacher-content" in Dashboard first if this fails):
-- Path format in app: {teacher_id}/month_{n}/sessions|pdfs|assessments/{filename}

-- Allow authenticated users to upload under their own folder (first folder = teacher_id)
CREATE POLICY "Teachers can upload own content"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'teacher-content'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Anyone can read (public bucket)
CREATE POLICY "Anyone can read teacher content"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'teacher-content');

-- Teachers can update/delete their own files
CREATE POLICY "Teachers can update own content"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'teacher-content'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Teachers can delete own content"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'teacher-content'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
