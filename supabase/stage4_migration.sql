-- ============================================================
-- Get-IT Phase 2 Migration
-- Adds candidate_machines to projects — records every machine
-- considered during a PC Sourcing engagement, not just the one
-- selected. Purely additive, no existing data touched.
-- ============================================================

alter table projects add column candidate_machines jsonb not null default '[]';

-- Shape: an array of objects, e.g.
-- [
--   {"manufacturer":"Dell","model":"Precision 5540","status":"selected","notes":"Met performance requirements and budget."},
--   {"manufacturer":"HP","model":"ZBook 15 G5","status":"rejected","notes":"Exceeded budget."}
-- ]
-- status is one of: selected | rejected | considered
