# RUNBOOK-002: Open Food Facts API Not Responding

## Severity
Medium

## Symptoms
- Cloud Function logs show connection timeout or HTTP 5xx
- Bronze layer has no product metadata for current date
- Silver model `stg_productos` has null values in product fields

## Probable Causes
1. Open Food Facts API is down (check https://status.openfoodfacts.org)
2. Network issue from Cloud Function
3. Rate limiting — too many requests

## Step-by-Step Resolution

### Step 1 — Check API status
Visit https://status.openfoodfacts.org
If API is down, wait and retry in 30 minutes.

### Step 2 — Test connectivity from Cloud Shell
```bash
curl -s https://world.openfoodfacts.org/api/v2/product/737628064502.json \
  | python3 -m json.tool | head -20
```
If no response, the issue is on their side.

### Step 3 — Run simulator without API
The simulator has a fallback mode using only Faker data:
```bash
cd ingestion
python simulator.py --no-api
```
This generates synthetic product data without calling Open Food Facts.

### Step 4 — Re-trigger pipeline
```bash
gcloud functions call batch-retail-ingest \
  --region=us-central1 \
  --data='{"fallback": true}'
```

## Prevention
- Simulator always has Faker fallback — API failure never blocks the pipeline
- Retry logic with exponential backoff configured in Cloud Function
