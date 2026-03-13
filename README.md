# gs-gcp-batch-retail

Batch data pipeline for retail inventory management built on GCP.
Simulates daily sales data for 10 Santiago branches, transforms it through a Medallion architecture, and serves a Star Schema to Looker Studio.

![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=flat&logo=python&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-1.9-FF694B?style=flat&logo=dbt&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-GCP-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![CD](https://github.com/gsalfate-code/gs-gcp-batch-retail/actions/workflows/cd.yml/badge.svg)

---

## Architecture
```
Cloud Scheduler (02:00 AM)
        │
        ▼
Cloud Function ──► GCS Bronze (Parquet)
                        │
                        ▼
              BigQuery External Table
                        │
                        ▼
               dbt Bronze (view)
                        │
                        ▼
               dbt Silver (table)
               PII masked · Ley 21.719
                        │
                        ▼
               dbt Gold (Star Schema)
         ┌──────────────┼──────────────┐
         ▼              ▼              ▼
   dim_producto   dim_sucursal    dim_fecha
                        │
                        ▼
                  fact_ventas
                        │
                        ▼
               Looker Studio Dashboard
```

## Tech Stack

| Layer | Technology |
|---|---|
| Ingestion | Python 3.11 · Faker es_CL · PyArrow |
| Storage | Google Cloud Storage · Parquet |
| Warehouse | BigQuery · External Tables |
| Transformation | dbt 1.9 · dbt_utils |
| Orchestration | Cloud Scheduler · Cloud Functions |
| CI/CD | GitHub Actions |
| Visualization | Looker Studio |

## Pipeline

**Bronze** — External Table pointing to GCS. Raw data, no transformations. PII visible only at this layer.

**Silver** — Deduplicated, typed, and cleaned. Client names masked and RUTs hashed via `mask_pii()` macro — compliant with Chilean Ley 21.719.

**Gold** — Star Schema optimized for analytics. Partitioned and clustered fact table joined to three dimension tables.

## Data Quality

32 dbt tests across all layers — `not_null`, `unique`, `accepted_values`, and `relationships` between fact and dimensions. Pipeline stops automatically if any test fails.

## How to Run
```bash
# Generate and upload daily data
python ingestion/simulator.py

# Run transformations
cd dbt
dbt run --target dev
dbt test --target dev
```

## Project Structure
```
gs-gcp-batch-retail/
├── ingestion/
│   ├── main.py          # Cloud Functions entry point
│   ├── simulator.py     # Daily sales data generator
│   └── requirements.txt
├── dbt/
│   ├── models/
│   │   ├── bronze/      # Raw view over External Table
│   │   ├── silver/      # Cleaned, PII masked
│   │   └── gold/        # Star Schema
│   └── macros/
│       └── mask_pii.sql # Ley 21.719 compliance
├── docs/
│   ├── adr/             # Architecture Decision Records
│   └── runbooks/        # Operational procedures
└── .github/workflows/
    ├── ci.yml           # dbt tests on pull requests
    └── cd.yml           # dbt prod + deploy on schedule
```

## Key Decisions

- [ADR-001](docs/adr/ADR-001-star-schema-vs-data-vault.md) — Star Schema vs Data Vault
- [ADR-002](docs/adr/ADR-002-cloud-functions-vs-cloud-run.md) — Cloud Functions vs Cloud Run
- [ADR-003](docs/adr/ADR-003-console-vs-terraform.md) — Console vs Terraform