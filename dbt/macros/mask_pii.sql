-- macros/mask_pii.sql
-- Masks Personally Identifiable Information (PII)
-- Ley 21.719 Chile compliance
-- Usage: {{ mask_pii('nombre_cliente') }}

{% macro mask_pii(column_name) %}
    CONCAT(
        LEFT(CAST({{ column_name }} AS STRING), 2),
        '****',
        RIGHT(CAST({{ column_name }} AS STRING), 1)
    )
{% endmacro %}

{% macro hash_pii(column_name) %}
    TO_HEX(MD5(CAST({{ column_name }} AS STRING)))
{% endmacro %}
