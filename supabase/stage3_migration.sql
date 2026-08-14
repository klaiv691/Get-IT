-- ============================================================
-- Get-IT Stage 3 Migration
-- Adds "PC Sourcing" as a valid category value (new service line
-- launched via the GetIT_08_PC_Sourcing flier). Run in the Supabase
-- SQL Editor — this only alters the CHECK constraint, no data is
-- touched.
-- ============================================================

alter table projects drop constraint if exists projects_category_check;

alter table projects add constraint projects_category_check check (category in (
  'Inspection','Repair','Workstation Evaluation','Enterprise','Maintenance','PC Sourcing'
));

-- If the constraint above errors saying it doesn't exist under that name,
-- find the real name first with:
--   select conname from pg_constraint where conrelid = 'projects'::regclass and contype = 'c';
-- then run: alter table projects drop constraint "<real_name>"; and re-run the add above.
