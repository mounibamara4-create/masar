-- مسار: قاعدة بيانات الحسابات
-- شغّل هذا الملف مرة واحدة من Supabase: SQL Editor > New query > الصق > Run

-- جدول واحد يحفظ بيانات كل مستخدم (الحالة، الوجبات، الصور) كوثائق JSON
create table if not exists public.docs (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  key        text        not null,
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);

-- السماح للمستخدمين المسجّلين فقط بالوصول عبر الـ API (الزوار بلا حساب لا يصلون إطلاقًا)
revoke all on public.docs from anon;
grant select, insert, update, delete on public.docs to authenticated;

-- كل مستخدم يرى ويعدّل صفوفه هو فقط
alter table public.docs enable row level security;

drop policy if exists "docs_select_own" on public.docs;
drop policy if exists "docs_insert_own" on public.docs;
drop policy if exists "docs_update_own" on public.docs;
drop policy if exists "docs_delete_own" on public.docs;

create policy "docs_select_own" on public.docs for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "docs_insert_own" on public.docs for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "docs_update_own" on public.docs for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "docs_delete_own" on public.docs for delete to authenticated
  using ((select auth.uid()) = user_id);
