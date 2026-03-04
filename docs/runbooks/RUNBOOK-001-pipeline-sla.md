# RUNBOOK-001: Pipeline Did Not Complete Before SLA

## Severity
High

## SLA
Pipeline must complete by 06:00 AM daily.
Data must be available in Gold layer for business analysts.

## Symptoms
- Looker Studio shows no data for current date
- Cloud Monitoring alert triggered
- No new files in gs://gs-batch-retail-bronze/bronze/ventas/{today}/

## Probable Causes
1. Cloud Scheduler did not trigger the Cloud Function
2. Cloud Function execution failed or timed out
3. GCS upload failed
4. BigQuery load job failed
5. dbt run failed in Silver or Gold layer

## Step-by-Step Resolution

### Step 1 — Check Cloud Scheduler
```bash
gcloud scheduler jobs describe batch-retail-daily \
  --location=us-central1
```
Look for `lastAttemptTime` and `state`. If state is PAUSED, run:
```bash
gcloud scheduler jobs resume batch-retail-daily \
  --location=us-central1
```

### Step 2 — Check Cloud Function logs
```bash
gcloud functions logs read batch-retail-ingest \
  --limit=50 \
  --region=us-central1
```
Look for ERROR or TIMEOUT messages.

### Step 3 — Check GCS
```bash
gsutil ls gs://gs-batch-retail-bronze/bronze/ventas/$(date +%Y/%m/%d)/
```
If empty, trigger the function manually:
```bash
gcloud functions call batch-retail-ingest \
  --region=us-central1
```

### Step 4 — Check BigQuery
```bash
bq show --job gs-batch-retail:$(date +%Y%m%d)
```

### Step 5 — Run dbt manually
```bash
cd dbt
dbt run --target prod
dbt test --target prod
```

## Escalation
If unresolved after 30 minutes → check GCP Status Dashboard
at https://status.cloud.google.com

## Prevention
- Cloud Monitoring alert configured at 06:00 AM if Gold table has no new rows
- Dead Letter Queue captures failed messages
