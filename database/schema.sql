-- =========================================================
-- Issue Routing / Provider Service - Database Schema (Postgres)
-- Works for Supabase
-- =========================================================

-- 1) Extensions
create extension if not exists "uuid-ossp";

-- 2) Enums (keep these if you want strict allowed values)
do $$ begin
  create type issue_type_enum as enum (
    'SCHEDULING',
    'BILLING',
    'CLINICAL',
    'TECHNICAL',
    'OPERATIONS',
    'OTHER'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type severity_enum as enum ('LOW', 'MED', 'HIGH', 'CRITICAL');
exception when duplicate_object then null; end $$;

do $$ begin
  create type issue_status_enum as enum ('NEW', 'IN_PROGRESS', 'RESOLVED', 'CLOSED');
exception when duplicate_object then null; end $$;

do $$ begin
  create type issue_source_enum as enum ('google_form', 'email', 'call', 'internal', 'other');
exception when duplicate_object then null; end $$;

do $$ begin
  create type assigned_team_enum as enum ('CARE', 'SCHEDULING', 'BILLING', 'TECH', 'OPS', 'UNKNOWN');
exception when duplicate_object then null; end $$;

-- =========================================================
-- TABLE: provider_issues
-- Main issue record (matches your n8n payload fields)
-- =========================================================
create table if not exists public.provider_issues (
  id uuid primary key default uuid_generate_v4(),
  created_at timestamptz not null default now(),

  provider_name text not null,
  provider_email text not null,

  issue_type issue_type_enum not null default 'OTHER',
  severity severity_enum not null default 'LOW',

  subject text not null,
  description text not null,

  source issue_source_enum not null default 'google_form',

  status issue_status_enum not null default 'NEW',
  assigned_team assigned_team_enum not null default 'UNKNOWN',
  assigned_to text null,

  acknowledged_at timestamptz null,
  resolved_at timestamptz null
);

-- Helpful indexes
create index if not exists idx_provider_issues_created_at on public.provider_issues (created_at desc);
create index if not exists idx_provider_issues_status on public.provider_issues (status);
create index if not exists idx_provider_issues_assigned_team on public.provider_issues (assigned_team);
create index if not exists idx_provider_issues_provider_email on public.provider_issues (provider_email);

-- =========================================================
-- TABLE: provider_issue_updates
-- Audit log of status changes / internal notes / provider notifications
-- =========================================================
create table if not exists public.provider_issue_updates (
  id uuid primary key default uuid_generate_v4(),
  created_at timestamptz not null default now(),

  issue_id uuid not null references public.provider_issues(id) on delete cascade,

  old_status issue_status_enum null,
  new_status issue_status_enum not null,

  message text null,

  notify_provider boolean not null default false,
  notified_at timestamptz null,

  updated_by text null
);

create index if not exists idx_provider_issue_updates_issue_id on public.provider_issue_updates (issue_id);
create index if not exists idx_provider_issue_updates_created_at on public.provider_issue_updates (created_at desc);

-- =========================================================
-- TABLE: appointments
-- Basic provider appointments (used for KPI + response time calculations)
-- =========================================================
create table if not exists public.appointments (
  id uuid primary key default uuid_generate_v4(),
  created_at timestamptz not null default now(),

  provider_email text not null,
  provider_name text null,

  patient_id uuid null,
  appointment_at timestamptz not null,

  status text not null default 'SCHEDULED', -- keep text to stay flexible ('SCHEDULED','COMPLETED','CANCELLED','NO_SHOW')
  completed_at timestamptz null,

  response_time_minutes integer null -- optional: if you calculate time-to-confirm
);

create index if not exists idx_appointments_provider_email on public.appointments (provider_email);
create index if not exists idx_appointments_appointment_at on public.appointments (appointment_at desc);
create index if not exists idx_appointments_status on public.appointments (status);

-- =========================================================
-- TABLE: patient_feedback
-- Patient satisfaction table (ties into provider KPIs)
-- =========================================================
create table if not exists public.patient_feedback (
  id uuid primary key default uuid_generate_v4(),
  created_at timestamptz not null default now(),

  appointment_id uuid null references public.appointments(id) on delete set null,

  provider_email text not null,
  provider_name text null,

  rating numeric(2,1) not null check (rating >= 1.0 and rating <= 5.0),
  comment text null,

  source text not null default 'post_visit_form' -- flexible
);

create index if not exists idx_patient_feedback_provider_email on public.patient_feedback (provider_email);
create index if not exists idx_patient_feedback_created_at on public.patient_feedback (created_at desc);
create index if not exists idx_patient_feedback_rating on public.patient_feedback (rating);

-- =========================================================
-- OPTIONAL: a view that shows latest status per issue (nice for dashboards)
-- =========================================================
create or replace view public.provider_issues_with_latest_update as
select
  i.*,
  u.new_status as last_update_status,
  u.message as last_update_message,
  u.created_at as last_update_at
from public.provider_issues i
left join lateral (
  select *
  from public.provider_issue_updates u
  where u.issue_id = i.id
  order by u.created_at desc
  limit 1
) u on true;
