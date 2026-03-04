-- bronze/stg_ventas_raw.sql
-- Reads raw data from BigQuery bronze.ventas_raw
-- Loaded from GCS Parquet files via Cloud Functions
-- Materialized as view -- always reflects latest data

{{ config(
    materialized='view',
    schema='bronze'
) }}

SELECT
    venta_id,
    fecha,
    hora,
    sucursal,
    categoria,
    producto,
    cantidad,
    precio_unitario,
    total,
    descuento_pct,
    cliente_id,
    nombre_cliente,
    rut_cliente,
    CURRENT_TIMESTAMP() AS ingested_at
FROM
    `gs-batch-retail.bronze.ventas_raw`