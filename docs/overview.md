# System Overview

This system automates the intake, routing, tracking, and resolution of
provider-reported operational issues for a Clinical Operations team.

## Components
- Google Forms: Provider intake and internal Ops updates
- n8n: Workflow orchestration
- Supabase (Postgres): System of record
- Gmail: Provider and Ops notifications

## Core Workflows
1. Provider Feedback Intake
2. Issue Status Update (Ops)
3. Weekly Ops Summary

## Data Flow
Provider → Google Form → n8n → Database → Email → Reporting

## Design Principles
- Single source of truth (provider_issues)
- Immutable audit log (provider_issue_updates)
- Idempotent processing
- Safe fallback routing
