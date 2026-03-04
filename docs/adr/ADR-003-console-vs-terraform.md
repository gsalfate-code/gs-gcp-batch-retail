# ADR-003: GCP Console vs Terraform

## Status
Accepted

## Date
2025-03-04

## Context
This is the first repository in the portfolio. The infrastructure
is simple — one GCS bucket, one BigQuery dataset, one Cloud Function,
one Cloud Scheduler job. The team size is one person.

## Decision
We use **GCP Console + gcloud CLI** instead of Terraform for this repo.

## Reasons
- Infrastructure is simple and stable — no need for state management
- Faster to provision manually for a single developer learning the stack
- Reduces cognitive load in Repo 1 — focus on pipeline logic, not IaC
- GCP Console provides immediate visual feedback during learning phase
- All resources can be reproduced in under 10 minutes manually

## Alternatives Considered
### Terraform
- Industry standard for Infrastructure as Code
- Enables dev/staging/prod environment parity
- Reproducible infrastructure across accounts
- **Rejected for Repo 1 because:** adds complexity before core pipeline
  concepts are established
- **Terraform is introduced in Repo 3** (microbatch-fintech) where
  infrastructure complexity — Pub/Sub, multiple Cloud Functions, IAM roles —
  justifies IaC investment

## Consequences
- Infrastructure is not version-controlled in this repo
- Manual steps required if project needs to be recreated
- Acceptable tradeoff for learning purposes in Repo 1
- All subsequent repos (3-9) use Terraform with dev/staging/prod workspaces

## Related
- ADR-002:
