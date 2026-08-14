-- ============================================================
-- Get-IT Stage 2 Migration
-- Run this in the Supabase SQL Editor. Adds the framework_sections
-- table used by framework.html. Safe to run independently of Stage 1
-- (does not touch the projects or contact_messages tables).
-- ============================================================

create table framework_sections (
  id           uuid primary key default gen_random_uuid(),
  section_key  text not null unique,
  section_type text not null check (section_type in ('core','module')),
  title        text not null,
  body         text,
  sort_order   int not null default 0,
  published    boolean not null default false,
  created_at   timestamptz not null default now()
);

create index framework_sections_type_idx on framework_sections (section_type);
create index framework_sections_published_idx on framework_sections (published);

alter table framework_sections enable row level security;

create policy "Public can view published framework sections"
on framework_sections for select
using (published = true);

create policy "Authenticated can view all framework sections"
on framework_sections for select to authenticated
using (true);

create policy "Authenticated can insert framework sections"
on framework_sections for insert to authenticated
with check (true);

create policy "Authenticated can update framework sections"
on framework_sections for update to authenticated
using (true);

create policy "Authenticated can delete framework sections"
on framework_sections for delete to authenticated
using (true);

-- ============================================================
-- Content editing convention (no admin UI for this table — edit rows
-- directly via Supabase's Table Editor):
--
-- Core steps (section_type='core'), sort_order 1-4:
--   section_key: understand | assess | recommend | implement
--
-- Service modules (section_type='module'):
--   section_key should reuse a token from the checklist/framework_topics
--   vocabulary (e.g. microsoft365, networking, security,
--   preventive_maintenance) so framework.html can auto-match related
--   case studies via their framework_topics[] column.
--
-- Set published=true for any row you want visible on the live site.
-- ============================================================
