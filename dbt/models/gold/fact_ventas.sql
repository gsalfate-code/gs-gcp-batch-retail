-- gold/fact_ventas.sql
-- Sales fact table
-- Central table of the Star Schema
-- Joins all dimensions

{{ config(
    materialized='table',
    schema='gold',
    partition_by={
      "field": "fecha",
      "data_type": "date",
      "granularity": "day"
    },
    cluster_by=["sucursal_sk", "producto_sk"]
) }}

WITH ventas AS (
    SELECT * FROM {{ ref('stg_ventas') }}
),

dim_producto AS (
    SELECT * FROM {{ ref('dim_producto') }}
),

dim_sucursal AS (
    SELECT * FROM {{ ref('dim_sucursal') }}
),

dim_fecha AS (
    SELECT * FROM {{ ref('dim_fecha') }}
),

final AS (
    SELECT
        v.venta_id,
        v.fecha,
        v.hora,

        -- Foreign keys to dimensions
        p.producto_sk,
        s.sucursal_sk,
        f.fecha_sk,

        -- Measures
        v.cantidad,
        v.precio_unitario,
        v.total,
        v.descuento_pct,

        -- Metadata
        v.cliente_id,
        v.ingested_at

    FROM ventas v
    LEFT JOIN dim_producto p
        ON v.producto  = p.producto_nombre
        AND v.categoria = p.producto_categoria
    LEFT JOIN dim_sucursal s
        ON v.sucursal = s.sucursal_nombre
    LEFT JOIN dim_fecha f
        ON v.fecha = f.fecha
)

SELECT * FROM final
