import os
import functions_framework
from simulator import generar_ventas, subir_a_gcs


@functions_framework.http
def pipeline_trigger(request):
    """
    HTTP entry point para Cloud Functions.
    Disparado por Cloud Scheduler diariamente a las 02:00 AM.

    Responsabilidad: SOLO ingesta de datos.
    - Genera 500 ventas simuladas del día
    - Sube el archivo Parquet a GCS Bronze

    ¿Por qué no corre dbt aquí?
    Cloud Functions es un entorno liviano sin dbt instalado.
    dbt corre separado en GitHub Actions (CI/CD) o Cloud Run Jobs.
    Separar responsabilidades hace el sistema más fácil de depurar.
    """

    # Variables de entorno — configuradas en el deploy, nunca hardcodeadas
    project_id  = os.environ.get("PROJECT_ID",  "gs-batch-retail")
    bucket_name = os.environ.get("BUCKET_NAME", "gs-batch-retail-bronze")

    try:
        # Generar datos del día — 500 ventas con Faker es_CL
        ventas = generar_ventas(n=500)

        # Subir Parquet a GCS — particionado por fecha YYYY/MM/DD
        blob_name = subir_a_gcs(ventas, bucket_name, project_id)

        # Respuesta exitosa — Cloud Scheduler espera HTTP 200
        return {
            "status": "ok",
            "records": len(ventas),
            "file": blob_name,
            "message": "Ingestion completed. dbt runs via GitHub Actions."
        }, 200

    except Exception as e:
        # HTTP 500 — Cloud Scheduler reintentará automáticamente
        return {
            "status": "error",
            "message": str(e)
        }, 500