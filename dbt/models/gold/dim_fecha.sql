-- gold/dim_fecha.sql
-- Date dimension table
-- Covers 2024-2026

{{ config(
    materialized='table',
    schema='gold'
) }}

WITH fechas AS (
    SELECT
        DATE_ADD(DATE '2024-01-01', INTERVAL n DAY) AS fecha
    FROM
        UNNEST(GENERATE_ARRAY(0, 730)) AS n
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['fecha']) }}
                                    AS fecha_sk,
        fecha,
        EXTRACT(YEAR  FROM fecha)   AS anio,
        EXTRACT(MONTH FROM fecha)   AS mes,
        EXTRACT(DAY   FROM fecha)   AS dia,
        EXTRACT(WEEK  FROM fecha)   AS semana,
        EXTRACT(DAYOFWEEK FROM fecha) AS dia_semana,
        FORMAT_DATE('%B', fecha)    AS mes_nombre,
        FORMAT_DATE('%A', fecha)    AS dia_nombre,
        CASE
            WHEN EXTRACT(DAYOFWEEK FROM fecha) IN (1, 7) THEN TRUE
            ELSE FALSE
        END                         AS es_fin_de_semana
    FROM fechas
)

SELECT * FROM final
