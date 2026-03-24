# gs-gcp-batch-retail

## El Problema

Los encargados de cada sucursal no tenían visibilidad de las ventas del día hasta el día siguiente. Las decisiones de reposición, promociones y asignación de personal se tomaban con datos de ayer — o de hace dos días si el reporte llegaba tarde. Con 10 sucursales en Santiago generando cientos de transacciones diarias, la brecha entre lo que ocurría y lo que se sabía era siempre de al menos 24 horas.

## La Solución

Un pipeline que consolida las ventas de las 10 sucursales cada noche y las entrega en un dashboard a las 6 AM. El gerente lo abre y ve en segundos cuánto vendió cada sucursal, qué categorías lideraron y cuál fue el ticket promedio — sin esperar reportes, sin Excel, sin llamar a nadie.

Construido sobre GCP con arquitectura Medallion y Star Schema. Corre automáticamente cada noche. Sin intervención manual.

![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=flat&logo=python&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-1.9-FF694B?style=flat&logo=dbt&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-GCP-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![CD](https://github.com/gsalfate-code/gs-gcp-batch-retail/actions/workflows/cd.yml/badge.svg)

**[→ Dashboard en Vivo](https://lookerstudio.google.com/reporting/4f604ddb-b113-45b1-8f53-f900b24261f3)** — actualizado diariamente a las 02:00 AM hora Santiago.

---

## Arquitectura

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

## Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Ingesta | Python 3.11 · Faker es_CL · PyArrow |
| Almacenamiento | Google Cloud Storage · Parquet |
| Warehouse | BigQuery · External Tables |
| Transformación | dbt 1.9 · dbt_utils |
| Orquestación | Cloud Scheduler · Cloud Functions |
| CI/CD | GitHub Actions |
| Visualización | Looker Studio |

## Pipeline

**Bronze** — External Table sobre GCS. Datos crudos sin transformaciones. PII visible solo en esta capa.

**Silver** — Deduplicado, tipado y limpio. Nombres de clientes enmascarados y RUTs hasheados con macro `mask_pii()` — cumplimiento Ley 21.719.

**Gold** — Star Schema optimizado para analytics. Tabla de hechos unida a tres dimensiones.

## Calidad de Datos

32 tests dbt en todas las capas — `not_null`, `unique`, `accepted_values` y `relationships` entre fact y dimensiones. El pipeline se detiene automáticamente si algún test falla.

## Cómo Ejecutar

    # Generar y subir datos diarios
    python ingestion/simulator.py

    # Ejecutar transformaciones
    cd dbt
    dbt run --target dev
    dbt test --target dev

## Estructura del Proyecto

    gs-gcp-batch-retail/
    ├── ingestion/
    │   ├── main.py          # Entry point Cloud Functions
    │   ├── simulator.py     # Generador de ventas diarias
    │   └── requirements.txt
    ├── dbt/
    │   ├── models/
    │   │   ├── bronze/      # Vista sobre External Table
    │   │   ├── silver/      # Limpio, PII enmascarado
    │   │   └── gold/        # Star Schema
    │   └── macros/
    │       └── mask_pii.sql # Cumplimiento Ley 21.719
    ├── docs/
    │   ├── adr/             # Architecture Decision Records
    │   └── runbooks/        # Procedimientos operacionales
    └── .github/workflows/
        ├── ci.yml           # dbt tests en pull requests
        └── cd.yml           # dbt prod + deploy en schedule

## Decisiones de Arquitectura

- [ADR-001](docs/adr/ADR-001-star-schema-vs-data-vault.md) — Star Schema vs Data Vault
- [ADR-002](docs/adr/ADR-002-cloud-functions-vs-cloud-run.md) — Cloud Functions vs Cloud Run
- [ADR-003](docs/adr/ADR-003-console-vs-terraform.md) — Consola vs Terraform
