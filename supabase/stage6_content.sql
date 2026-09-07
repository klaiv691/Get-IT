-- Get-IT Stage 6 Migration
-- Adds editable public-site content for the admin workspace.
-- Run after Stage 5. Public pages use fallback copy if a record is unavailable.

create table if not exists site_content (
  content_key text primary key,
  content jsonb not null default '{}'::jsonb,
  published boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table site_content enable row level security;

create policy "Public can view published site content"
on site_content for select
using (published = true);

create policy "Admins can view all site content"
on site_content for select to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can insert site content"
on site_content for insert to authenticated
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can update site content"
on site_content for update to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can delete site content"
on site_content for delete to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

insert into site_content (content_key, content)
values
('site_settings', '{
  "brand_name": "Get-IT",
  "owner": "Twesige Marvin Clive",
  "tagline": "Enterprise IT, Cloud & Cybersecurity Services",
  "location": "Kampala, Uganda",
  "phone": "+256 785 739 120",
  "whatsapp": "256705748346",
  "email": "marvinclive16@gmail.com",
  "hours_weekdays": "9:00 AM – 6:00 PM",
  "hours_saturday": "10:00 AM – 2:00 PM",
  "hours_sunday": "Closed"
}'::jsonb),
('homepage', '{
  "hero_kicker": "Kampala, Uganda",
  "hero_title": "The technology decisions that matter, made with evidence — not guesswork.",
  "hero_body": "Get-IT inspects laptops before purchase, evaluates workstations for demanding software, and supports the Microsoft 365 systems, networks, and infrastructure behind small businesses in Kampala — every recommendation backed by a documented assessment, not a sales pitch.",
  "services_heading": "Four ways to work with Get-IT",
  "service_cards": [
    {"title":"Personal Technology","body":"Buying a second-hand laptop or troubleshooting the one you already own? I inspect devices before you pay for them, repair faults worth fixing, and set up the operating system, drivers, and maintenance routine that keep a machine reliable."},
    {"title":"Professional Workstations","body":"Architects, interior designers, and other professionals lose real hours to underpowered hardware. I evaluate workstations against the software you actually run — CAD, BIM, rendering — so a machine is judged by whether it can do the job."},
    {"title":"Business IT","body":"Small businesses need Microsoft 365 configured properly, networks that hold up during work hours, and IT decisions grounded in what the business actually needs. I advise on Microsoft 365, networking, cybersecurity basics, and ERP systems like Odoo."},
    {"title":"PC Sourcing","body":"Tell me your budget and specs and Ill find and verify matching options for you, each with condition notes and a clear recommendation — within a fixed 4–5 day search window."}
  ],
  "assessment_title": "Every recommendation starts with an assessment.",
  "assessment_body": "Before I recommend anything — a repair, a replacement, a new system — I work through the same four steps: understand what you actually need, assess the technology against that need, recommend the option that fits, and implement it properly.",
  "why_heading": "Independent, evidence-based, and built for the long term",
  "enterprise_title": "Also built for business",
  "enterprise_body": "Get-IT works with small and growing businesses on the systems that run day to day — not just the laptops on peoples desks.",
  "cta_title": "Have a device or a system that needs a second opinion?",
  "cta_body": "Book a laptop inspection, ask a workstation question, or get in touch about business IT — I usually reply within a day."
}'::jsonb),
('contact_page', '{
  "hero_title": "Lets talk about your technology.",
  "hero_body": "Whether its a laptop youre about to buy, a workstation thats slowing you down, or a business system that needs attention — heres how to reach me.",
  "sourcing_body": "Tell me your budget and specs and Ill find and verify matching options within a fixed 4–5 day window. No obligation if nothing works out.",
  "sourcing_price": "UGX 50,000 to start (UGX 25,000 to resubscribe)",
  "business_body": "For Microsoft 365, networking, cybersecurity, maintenance, or ERP projects, email a short description of what youre working with and what you need — Ill reply with next steps.",
  "service_area": "Get-IT is based in Kampala. On-site visits are available across the city for inspections, repairs, and business IT work; remote consultations and support are available for clients elsewhere in Uganda.",
  "general_body": "Not sure which category your question falls into? Send a message below and Ill get back to you — usually within a day.",
  "urgent_note": "Urgent business IT issues — message on WhatsApp any time; I respond as soon as I can outside these hours."
}'::jsonb),
('framework_page', '{
  "intro": "Every job that comes through Get-IT — a laptop inspection or a multi-system business IT project — goes through the same process: understand what you actually need, assess the technology against that need, recommend the option that fits, and implement it properly."
}'::jsonb),
('services', '{
  "items": [
    {"key":"repairs","title":"Repairs","summary":"Hardware faults diagnosed and fixed properly — not guessed at.","description":"If something isnt worth repairing, thats the recommendation youll get, not a sale."},
    {"key":"maintenance-programs","title":"Maintenance Programs","summary":"Preventive maintenance and monitoring built into a routine.","description":"Small problems get caught before they become expensive ones."},
    {"key":"technology-assessments","title":"Technology Assessments","summary":"Evidence-based assessment for laptops, workstations, and new hardware.","description":"Every assessment follows the Get-IT framework."},
    {"key":"dual-boot-os-setup","title":"Dual-Boot & OS Setup","summary":"Windows and Linux side by side, or a clean single-OS install.","description":"Drivers, updates, and licensing sorted from the start."},
    {"key":"enterprise-it","title":"Enterprise IT","summary":"Microsoft 365, networks, cybersecurity, infrastructure, and business systems.","description":"The same assessment discipline applied at business scale."}
  ]
}'::jsonb)
 on conflict (content_key) do nothing;

create or replace function set_site_content_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists site_content_updated_at on site_content;
create trigger site_content_updated_at
before update on site_content
for each row execute function set_site_content_updated_at();
