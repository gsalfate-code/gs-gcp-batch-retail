-- gold/dim_producto.sql
-- Product dimension table
-- Contains unique products with their categories

{{ config(
    materialized='table',
    schema='gold'
) }}

WITH productos AS (
    SELECT DISTINCT
        producto,
        categoria
    FROM {{ ref('stg_ventas') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['producto', 'categoria']) }}
                                AS producto_sk,
        producto                AS producto_nombre,
        categoria               AS producto_categoria,
        CURRENT_TIMESTAMP()     AS updated_at
    FROM productos
)

SELECT * FROM final
