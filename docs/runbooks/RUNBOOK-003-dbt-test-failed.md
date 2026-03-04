# RUNBOOK-003: dbt Test Failed in Silver Layer

## Severity
High

## Symptoms
- GitHub Actions cd.yml fails at dbt test step
- Cloud Monitoring alert: Gold layer not updated
- Looker Studio shows stale data

## Probable Causes
1. Null values in required fields (not_null test)
2. Duplicate records in source data (unique test)
3. Unexpected values in categorical fields (accepted_values test)
4. Schema change in Bronze layer

## Step-by-Step Resolution

### Step 1 — Identify failing test
```bash
cd dbt
dbt test --target prod 2>&1 | grep FAIL
```

### Step 2 — Check the data
```sql
-- Run in BigQuery console
SELECT *
FROM silver.stg_ventas
WHERE venta_id IS NULL
   OR total <= 0
LIMIT 20;
```

### Step 3 — Check Bronze source
```bash
gsutil cat gs://gs-batch-retail-bronze/bronze/ventas/$(date +%Y/%m/%d)/*.json \
  | python3 -m json.tool | head -50
```

### Step 4 — Fix and rerun
If data issue is in simulator:
```bash
cd ingestion
python simulator.py --validate
```
Then rerun dbt:
```bash
dbt run --select silver --target prod
dbt test --select silver --target prod
```

## Prevention
- Great Expectations validates Bronze data before dbt runs
- dbt tests run on every PR via ci.yml
- Silver models have not_null and unique tests on all key fields
