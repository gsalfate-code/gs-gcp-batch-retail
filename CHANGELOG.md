# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]

### Added
- Initial project structure
- Data simulator with Faker es_CL (500 daily sales records)
- Medallion architecture: Bronze / Silver / Gold
- Star Schema model: dim_producto, dim_sucursal, dim_fecha, fact_ventas
- PII masking macro (mask_pii) — Ley 21.719 compliance
- ADR-001: Star Schema vs Data Vault
- ADR-002: Cloud Functions vs Cloud Run
- ADR-003: Console vs Terraform
- Runbooks: SLA, API failure, dbt test failure
