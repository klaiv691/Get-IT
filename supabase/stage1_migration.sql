-- ============================================================
-- Get-IT Stage 1 Migration
-- Run this in the Supabase SQL Editor. Safe: `projects` currently
-- has 0 rows, so this drops and recreates it against the new schema.
-- ============================================================

drop table if exists projects cascade;

create table projects (
  id                  uuid primary key default gen_random_uuid(),
  ticket_no           bigint generated always as identity,
  title               text not null,
  slug                text not null unique,
  category            text not null check (category in (
                        'Inspection','Repair','Workstation Evaluation','Enterprise','Maintenance'
                      )),
  client_type         text not null check (client_type in (
                        'Student','Architect','Interior Designer','Small Business','Individual'
                      )),
  device_manufacturer text,
  device_model        text,
  problem             text,
  checklist           text[] not null default '{}',
  work_performed      text,
  outcome             text,
  recommendation      text,
  framework_topics    text[] not null default '{}',
  featured_image      text,
  images              text[] not null default '{}',
  tags                text[] not null default '{}',
  date                date not null,
  featured            boolean not null default false,
  published           boolean not null default false,
  created_at          timestamptz not null default now()
);

create index projects_slug_idx on projects (slug);
create index projects_published_idx on projects (published);
create index projects_featured_idx on projects (featured);
create index projects_category_idx on projects (category);

alter table projects enable row level security;

create policy "Public can view published projects"
on projects for select
using (published = true);

create policy "Authenticated can view all projects"
on projects for select to authenticated
using (true);

create policy "Authenticated can insert"
on projects for insert to authenticated
with check (true);

create policy "Authenticated can update"
on projects for update to authenticated
using (true);

create policy "Authenticated can delete"
on projects for delete to authenticated
using (true);

-- ============================================================
-- Contact form target table (Stage 2 will build the form)
-- ============================================================

create table contact_messages (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  email       text not null,
  phone       text,
  service     text,
  message     text not null,
  read        boolean not null default false,
  created_at  timestamptz not null default now()
);

alter table contact_messages enable row level security;

create policy "Anyone can submit a contact message"
on contact_messages for insert to anon
with check (true);

create policy "Authenticated can view contact messages"
on contact_messages for select to authenticated
using (true);

create policy "Authenticated can delete contact messages"
on contact_messages for delete to authenticated
using (true);

-- ============================================================
-- Storage RLS for the case-studies bucket.
-- Run this AFTER creating the bucket via the dashboard UI:
--   Storage -> New bucket -> name exactly "case-studies" -> Public bucket: ON
-- ============================================================

create policy "Public read access to case-studies"
on storage.objects for select to public
using (bucket_id = 'case-studies');

create policy "Authenticated can upload to case-studies"
on storage.objects for insert to authenticated
with check (bucket_id = 'case-studies');

create policy "Authenticated can update case-studies files"
on storage.objects for update to authenticated
using (bucket_id = 'case-studies');

create policy "Authenticated can delete case-studies files"
on storage.objects for delete to authenticated
using (bucket_id = 'case-studies');
