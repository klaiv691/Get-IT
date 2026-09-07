-- Get-IT Stage 5 Migration
-- Restricts management operations to users whose Supabase app_metadata role
-- is explicitly set to "admin". Set that role in Supabase Auth before running
-- this migration for the account used by admin.html.

drop policy if exists "Authenticated can view all projects" on projects;
drop policy if exists "Authenticated can insert" on projects;
drop policy if exists "Authenticated can update" on projects;
drop policy if exists "Authenticated can delete" on projects;
drop policy if exists "Authenticated can view framework sections" on framework_sections;
drop policy if exists "Authenticated can insert framework sections" on framework_sections;
drop policy if exists "Authenticated can update framework sections" on framework_sections;
drop policy if exists "Authenticated can delete framework sections" on framework_sections;
drop policy if exists "Authenticated can view contact messages" on contact_messages;
drop policy if exists "Authenticated can delete contact messages" on contact_messages;
drop policy if exists "Authenticated can upload to case-studies" on storage.objects;
drop policy if exists "Authenticated can update case-studies files" on storage.objects;
drop policy if exists "Authenticated can delete case-studies files" on storage.objects;

create policy "Admins can view all projects"
on projects for select to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can insert projects"
on projects for insert to authenticated
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can update projects"
on projects for update to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can delete projects"
on projects for delete to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can view framework sections"
on framework_sections for select to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can insert framework sections"
on framework_sections for insert to authenticated
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can update framework sections"
on framework_sections for update to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can delete framework sections"
on framework_sections for delete to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can view contact messages"
on contact_messages for select to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can delete contact messages"
on contact_messages for delete to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can upload to case-studies"
on storage.objects for insert to authenticated
with check (bucket_id = 'case-studies' and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can update case-studies files"
on storage.objects for update to authenticated
using (bucket_id = 'case-studies' and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check (bucket_id = 'case-studies' and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can delete case-studies files"
on storage.objects for delete to authenticated
using (bucket_id = 'case-studies' and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

alter table contact_messages
  add constraint contact_messages_name_length check (char_length(name) between 2 and 120),
  add constraint contact_messages_email_length check (char_length(email) between 3 and 254),
  add constraint contact_messages_message_length check (char_length(message) between 5 and 5000);