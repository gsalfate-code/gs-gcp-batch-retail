# ADR-002: Cloud Functions vs Cloud Run

## Status
Accepted

## Date
2025-03-04

## Context
The pipeline needs a compute layer to execute the data simulator
and upload raw data to GCS Bronze. The trigger is a daily Cloud Scheduler
job at 02:00 AM. Execution time is under 2 minutes for 500 records.

## Decision
We use **Cloud Functions (2nd gen)** instead of Cloud Run.

## Reasons
- Execution time under 2 minutes — well within Cloud Functions 60-minute limit
- No persistent server needed — batch runs once per day
- Cloud Functions free tier: 2 million invocations/month — zero cost
- Simpler deployment — no Dockerfile, no container registry
- Native integration with Cloud Scheduler via HTTP trigger

## Alternatives Considered
### Cloud Run
- Better for long-running jobs, custom runtimes and complex dependencies
- Supports Docker containers — more control over the environment
- **Rejected because:** adds unnecessary complexity for a simple daily batch job
- Cloud Run Jobs will be used in Repo 7 (api-tourism) where multi-container
  orchestration justifies the added complexity

## Consequences
- Fast deployment and zero infrastructure management
- Limited to 60-minute execution — acceptable for current volume
- If data volume grows beyond 10,000 records/day, Cloud Run Jobs will be evaluated

## Related
- ADR-003: Console vs Terraform
- ingestion/simulator.py
- RUNBOOK-001: Pipeline SLA failure
