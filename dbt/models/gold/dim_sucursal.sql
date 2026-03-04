-- gold/dim_sucursal.sql
-- Branch dimension table
-- Contains unique branches

{{ config(
    materialized='table',
    schema='gold'
) }}

WITH sucursales AS (
    SELECT DISTINCT
        sucursal
    FROM {{ ref('stg_ventas') }}
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['sucursal']) }}
                                AS sucursal_sk,
        sucursal                AS sucursal_nombre,
        'Santiago'              AS ciudad,
        'Chile'                 AS pais,
        CURRENT_TIMESTAMP()     AS updated_at
    FROM sucursales
)

SELECT * FROM final
