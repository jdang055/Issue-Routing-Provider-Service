-- =========================================
-- Seed mock data for Issue Routing & Provider Service System
-- =========================================

-- Clear existing data (safe for local/dev only)
TRUNCATE TABLE public.provider_issue_updates CASCADE;
TRUNCATE TABLE public.provider_issues CASCADE;

-- =========================================
-- Provider Issues (System of Record)
-- =========================================

INSERT INTO public.provider_issues (
  id,
  created_at,
  provider_name,
  provider_email,
  issue_type,
  severity,
  subject,
  description,
  source,
  status,
  assigned_team,
  acknowledged_at,
  resolved_at
) VALUES

-- RESOLVED issues
(
  '11111111-1111-1111-1111-111111111111',
  now() - interval '20 days',
  'Dr. Amelia Chen',
  'amelia.chen@clinicexample.com',
  'SCHEDULING',
  'MED',
  'Patients unable to book follow-up appointments',
  'Patients report no available slots despite open calendar.',
  'google_form',
  'RESOLVED',
  'CARE',
  now() - interval '19 days',
  now() - interval '17 days'
),
(
  '22222222-2222-2222-2222-222222222222',
  now() - interval '14 days',
  'Dr. Michael Patel',
  'michael.patel@clinicexample.com',
  'BILLING',
  'LOW',
  'Incorrect copay amounts',
  'Several patients were charged an incorrect copay.',
  'google_form',
  'RESOLVED',
  'BILLING',
  now() - interval '13 days',
  now() - interval '10 days'
),

-- IN_PROGRESS issues
(
  '33333333-3333-3333-3333-333333333333',
  now() - interval '7 days',
  'Dr. Sofia Alvarez',
  'sofia.alvarez@clinicexample.com',
  'ACCESS',
  'HIGH',
  'Unable to access provider portal',
  'Login fails with authentication error.',
  'google_form',
  'IN_PROGRESS',
  'TECH',
  now() - interval '6 days',
  NULL
),

-- ACKED issues
(
  '44444444-4444-4444-4444-444444444444',
  now() - interval '3 days',
  'Dr. Daniel Kim',
  'daniel.kim@clinicexample.com',
  'SCHEDULING',
  'MED',
  'Appointment confirmation emails not sending',
  'Patients report missing confirmation emails.',
  'google_form',
  'ACKED',
  'CARE',
  now() - interval '2 days',
  NULL
),

-- NEW issues (backlog)
(
  '55555555-5555-5555-5555-555555555555',
  now() - interval '1 day',
  'Dr. Priya Shah',
  'priya.shah@clinicexample.com',
  'BILLING',
  'MED',
  'Delayed insurance reimbursement',
  'Claims appear stuck in pending state.',
  'google_form',
  'NEW',
  'BILLING',
  NULL,
  NULL
),
(
  '66666666-6666-6666-6666-666666666666',
  now() - interval '8 hours',
  'Dr. Robert Lee',
  'robert.lee@clinicexample.com',
  'ACCESS',
  'LOW',
  'Password reset emails delayed',
  'Password reset email arrives several hours late.',
  'google_form',
  'NEW',
  'TECH',
  NULL,
  NULL
);

-- =========================================
-- Provider Issue Updates (Audit Log)
-- =========================================

INSERT INTO public.provider_issue_updates (
  issue_id,
  created_at,
  update_type,
  message,
  sent_to_provider
) VALUES

-- Issue 1 lifecycle
(
  '11111111-1111-1111-1111-111111111111',
  now() - interval '19 days',
  'STATUS_CHANGE',
  'ACKED: Issue received and assigned to CARE team.',
  false
),
(
  '11111111-1111-1111-1111-111111111111',
  now() - interval '18 days',
  'STATUS_CHANGE',
  'IN_PROGRESS: Scheduling configuration under review.',
  false
),
(
  '11111111-1111-1111-1111-111111111111',
  now() - interval '17 days',
  'STATUS_CHANGE',
  'RESOLVED: Scheduling issue fixed. Booking restored.',
  true
),

-- Issue 2 lifecycle
(
  '22222222-2222-2222-2222-222222222222',
  now() - interval '13 days',
  'STATUS_CHANGE',
  'ACKED: Billing team reviewing copay configuration.',
  false
),
(
  '22222222-2222-2222-2222-222222222222',
  now() - interval '10 days',
  'STATUS_CHANGE',
  'RESOLVED: Copay amounts corrected. Refunds issued.',
  true
),

-- Issue 3 lifecycle
(
  '33333333-3333-3333-3333-333333333333',
  now() - interval '6 days',
  'STATUS_CHANGE',
  'ACKED: Access issue escalated to technical support.',
  false
),
(
  '33333333-3333-3333-3333-333333333333',
  now() - interval '5 days',
  'STATUS_CHANGE',
  'IN_PROGRESS: Authentication logs under investigation.',
  false
),

-- Issue 4 lifecycle
(
  '44444444-4444-4444-4444-444444444444',
  now() - interval '2 days',
  'STATUS_CHANGE',
  'ACKED: Email delivery issue acknowledged.',
  false
);

-- =========================================
-- End of seed data
-- =========================================
