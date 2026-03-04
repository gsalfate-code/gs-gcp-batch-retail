# ADR-001: Star Schema vs Data Vault 2.0

## Status
Accepted

## Date
2025-03-04

## Context
This pipeline serves a retail supermarket with 10 branches.
The primary consumers are business analysts and Looker Studio dashboards.
The data model needs to support daily sales reporting, inventory analysis,
and branch performance comparisons.

## Decision
We use **Star Schema (Kimball)** instead of Data Vault 2.0.

## Reasons
- Star Schema is optimized for analytical queries — simple JOINs, fast aggregations
- Looker Studio connects naturally to Star Schema without extra transformation layers
- Business analysts can query the model directly without deep technical knowledge
- Data volume (500 records/day, 10 branches) does not justify Data Vault complexity
- Development speed: Star Schema delivers value in days, Data Vault in weeks

## Alternatives Considered
### Data Vault 2.0
- Better for auditing, historical tracking and enterprise integrations
- Handles schema changes more gracefully
- **Rejected because:** overkill for current volume and consumer profile

## Consequences
- Simpler queries and faster dashboard performance
- Less flexibility for schema changes — acceptable for stable retail domain
- Data Vault 2.0 will be evaluated in Chapter 2 when volume and complexity increase

## Related
- RUNBOOK-001: Pipeline SLA failure
- dbt models: gold/dim_producto, gold/dim_sucursal, gold/dim_fecha, gold/fact_ventas
