-- silver/stg_ventas.sql
-- Cleans, deduplicates and masks PII from Bronze layer
-- Ley 21.719 Chile compliance applied here
-- Materialized as table -- transformations are expensive

{{ config(
    materialized='table',
    schema='silver',
    partition_by={
      "field": "fecha",
      "data_type": "date",
      "granularity": "day"
    },
    cluster_by=["sucursal", "categoria"]
) }}

WITH source AS (
    SELECT * FROM {{ ref('stg_ventas_raw') }}
),

deduplicated AS (
    SELECT *
    FROM source
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY venta_id
        ORDER BY ingested_at DESC
    ) = 1
),

cleaned AS (
    SELECT
        venta_id,
        CAST(fecha AS DATE)                     AS fecha,
        hora,
        TRIM(UPPER(sucursal))                   AS sucursal,
        TRIM(UPPER(categoria))                  AS categoria,
        TRIM(producto)                          AS producto,
        cantidad,
        precio_unitario,
        total,
        descuento_pct,
        cliente_id,

        -- PII masking — Ley 21.719
        {{ mask_pii('nombre_cliente') }}        AS nombre_cliente,
        {{ hash_pii('rut_cliente') }}           AS rut_cliente,
        ingested_at

    FROM deduplicated
    WHERE
        venta_id        IS NOT NULL
        AND fecha       IS NOT NULL
        AND total       > 0
        AND cantidad    > 0
        AND sucursal    IS NOT NULL
)

SELECT * FROM cleaned
