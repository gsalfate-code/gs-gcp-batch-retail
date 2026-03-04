# Lessons Learned — gs-gcp-batch-retail

## What Went Well
- Star Schema proved to be the right choice — Looker Studio connected
  naturally without extra transformation layers
- Faker es_CL generated realistic Chilean data — RUT, names, prices in CLP
- Partitioning BigQuery by date reduced query costs significantly
- ADRs forced me to think before coding — better decisions overall

## What I Would Do Differently
- Set up Cloud Monitoring alerts before running the pipeline, not after
- Define dbt tests before writing models — test-driven development
- Create the GCS bucket with lifecycle policies from day one
  to auto-delete Bronze files older than 90 days

## Surprises
- Cloud Functions cold start adds ~2 seconds to first execution
- BigQuery clustering by sucursal cut query time by 60% on branch reports
- Faker es_CL has native RUT generation — no custom logic needed

## What I Learned
- Difference between partitioning (by date) and clustering (by category/branch)
- How dbt macros work — mask_pii reusable across all Silver models
- Git Flow discipline — feature branches make rollback much easier
- Why ADRs matter — future me will thank present me

## Next Steps
- Repo 2 introduces Great Expectations for data quality validation
- Repo 3 introduces Terraform, Pub/Sub and Lambda Architecture
