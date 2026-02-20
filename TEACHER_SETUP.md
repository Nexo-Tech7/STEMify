# Teacher Dashboard & Student Courses – Setup Guide

## 1. Where are the server details?

The "server" is **Supabase** (database + file storage). You use **one Supabase project** for:
- Teacher sign-in/sign-up (teachers table)
- Teacher content (teacher_month_content table)
- Which students have access to which month (teacher_month_students table)
- File uploads (Storage bucket `teacher-content`)

### Where to put your Supabase URL and key

**Teacher web (teacher dashboard and sign-in):**

| File | What to set |
|------|-------------|
| `teacher web/signin.html` | Find the script block and set `SUPABASE_URL` and `SUPABASE_ANON_KEY`. |
| `teacher web/signup.html` | Same: `SUPABASE_URL` and `SUPABASE_ANON_KEY`. |
| `teacher web/teacher-dashboard.html` | At the top of the script (around line 280): set `SUPABASE_URL` and `SUPABASE_ANON_KEY`. |

**Main project (student dashboard – so students see their courses):**

| File | What to set |
|------|-------------|
| `dashboard.html` (in the **main project root**, not inside teacher web) | In the script, find `SUPABASE_URL` and `SUPABASE_ANON_KEY` (used for Courses). Set them to the **same** values as the teacher project. Then the student dashboard can read which teachers/months the student is added to and show Sessions, PDFs, Quizzes, Assessments. |

Example (same in all these files):

```javascript
const SUPABASE_URL = 'https://YOUR_PROJECT_REF.supabase.co';
const SUPABASE_ANON_KEY = 'your_anon_key_here';
```

To get them:
1. Go to [Supabase](https://supabase.com) and open your project (or create one).
2. **Settings** (left sidebar) → **API**.
3. Copy **Project URL** → use as `SUPABASE_URL`.
4. Copy **anon public** key → use as `SUPABASE_ANON_KEY`.

---

## 2. Step-by-step: what to do

### Step 1: Create a Supabase project (if you don’t have one)

1. Go to https://supabase.com and sign in.
2. **New project** → choose organization, name, database password, region.
3. Wait until the project is ready.

### Step 2: Run the SQL in your Supabase project

1. In Supabase: **SQL Editor** → **New query**.
2. Run the contents of **`teacher web/supabase_teachers_table.sql`** (creates `teachers` table for sign-up/sign-in).
3. Run the contents of **`teacher web/supabase_teacher_content.sql`** (creates `teacher_month_content` and storage policies).
4. Run the SQL that creates **`teacher_month_students`** (see file **`teacher web/supabase_teacher_month_students.sql`** – creates table and policies so teachers can add student IDs and students can see their courses).

### Step 3: Create the Storage bucket (for uploads)

1. In Supabase: **Storage** → **New bucket**.
2. Name: **`teacher-content`**.
3. **Public bucket**: ON (so file links work).
4. Create the bucket.

### Step 4: Put your Supabase details in the app

1. Open **`teacher web/signin.html`** → find `SUPABASE_URL` and `SUPABASE_ANON_KEY` in the script → replace with your project URL and anon key.
2. Open **`teacher web/signup.html`** → same replacement.
3. Open **`teacher web/teacher-dashboard.html`** → at the top of the script, same replacement.
4. Open **`dashboard.html`** (main project) → in the script where Supabase is used for courses, set the **same** `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

### Step 5: Student ID – where it comes from

- **Student ID** is created when a **student signs up in the main project** (e.g. in your main site’s sign-up flow).
- It is stored in your **main project’s** `students` table (e.g. `student_id` like `STEM-2025-123456`).
- The **teacher** does not log in to the main project. When a student pays for “Month 1”, the teacher gets the student’s ID (student tells them or you show it in an admin), and the teacher **adds that Student ID** in the teacher dashboard for that month.
- Where the teacher adds it: **Teacher dashboard** → **Add Month** → for each month click **Edit** → in the modal you’ll see **“Students with access”** → enter the Student ID (e.g. `STEM-2025-123456`) and click **Add**. That links the student to that month so the student sees it under **Courses** in their dashboard.

### Step 6: How the student sees it

- Student signs in to the **main project** (student dashboard).
- They open **Courses** in the sidebar.
- They see a list of **teachers** who have added their Student ID to at least one month.
- They click a **teacher** → they see the **months** they are subscribed to (e.g. Month 1, Month 2).
- They click a **month** → the right side switches to the **month view**: sidebar changes to **Profile, Home, Sessions, Assessments, PDFs, Quizzes**, and the main area shows the content (Sessions, PDFs, etc.) for that month.

---

## 3. Summary

| What | Where |
|------|--------|
| Supabase URL & anon key | `signin.html`, `signup.html`, `teacher-dashboard.html` (teacher web), and `dashboard.html` (main project) |
| Teachers table | Supabase, from `supabase_teachers_table.sql` |
| Teacher content + storage | Supabase, from `supabase_teacher_content.sql` |
| Student access per month | Supabase, from `supabase_teacher_month_students.sql` |
| Adding Student IDs | Teacher dashboard → Edit month → “Students with access” |
| Student sees courses | Main project → Student dashboard → Courses → Teacher → Month → Sessions / PDFs / Quizzes / Assessments |

If you use a **different Supabase account** (different project) for teachers, use that project’s URL and anon key in **all** of the places above (teacher web + main project dashboard) so that both teacher dashboard and student courses use the same database and storage.
