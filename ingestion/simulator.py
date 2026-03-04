import json
import random
from datetime import datetime, timedelta
from faker import Faker
from google.cloud import storage

fake = Faker("es_CL")

SUCURSALES = [
    "Santiago Centro", "Providencia", "Las Condes", "Maipu",
    "La Florida", "Pudahuel", "Nunoa", "San Bernardo",
    "Quilicura", "Puente Alto"
]

CATEGORIAS = {
    "Lacteos":     [("Leche Entera 1L", 990), ("Yogurt Natural", 650), ("Queso Gauda 500g", 2490)],
    "Panaderia":   [("Pan Molde", 1290), ("Hallulla x6", 890), ("Marraqueta x4", 590)],
    "Bebidas":     [("Coca-Cola 1.5L", 1490), ("Agua Mineral 1.5L", 690), ("Jugo Watts 1L", 990)],
    "Limpieza":    [("Detergente Omo 1kg", 3490), ("Cloro 1L", 890), ("Esponja x3", 690)],
    "Snacks":      [("Papas Fritas Lays", 990), ("Galletas Oreo", 1190), ("Chocolate Sahne", 890)],
}

def generar_ventas(n=500):
    """Genera n registros de ventas simuladas."""
    ventas = []
    fecha_hoy = datetime.now().strftime("%Y-%m-%d")

    for _ in range(n):
        categoria = random.choice(list(CATEGORIAS.keys()))
        producto, precio_base = random.choice(CATEGORIAS[categoria])
        cantidad = random.randint(1, 20)
        descuento = random.choice([0, 0, 0, 5, 10, 15])
        precio_final = round(precio_base * (1 - descuento / 100))

        ventas.append({
            "venta_id":       fake.uuid4(),
            "fecha":          fecha_hoy,
            "hora":           fake.time(),
            "sucursal":       random.choice(SUCURSALES),
            "categoria":      categoria,
            "producto":       producto,
            "cantidad":       cantidad,
            "precio_unitario": precio_final,
            "total":          precio_final * cantidad,
            "descuento_pct":  descuento,
            "cliente_id":     fake.uuid4(),
            "nombre_cliente": fake.name(),      # PII — se enmascara en Silver
            "rut_cliente":    fake.rut(),       # PII — se enmascara en Silver
        })

    return ventas

def subir_a_gcs(ventas, bucket_name, project_id):
    """Sube los datos al bucket GCS Bronze."""
    client = storage.Client(project=project_id)
    bucket = client.bucket(bucket_name)

    fecha = datetime.now().strftime("%Y/%m/%d")
    timestamp = datetime.now().strftime("%H%M%S")
    blob_name = f"bronze/ventas/{fecha}/ventas_{timestamp}.json"

    blob = bucket.blob(blob_name)
    blob.upload_from_string(
        json.dumps(ventas, ensure_ascii=False, indent=2),
        content_type="application/json"
    )

    print(f"Subidos {len(ventas)} registros a gs://{bucket_name}/{blob_name}")
    return blob_name

def main(request=None):
    """Entry point para Cloud Functions."""
    import os
    project_id  = os.environ.get("PROJECT_ID", "gs-batch-retail")
    bucket_name = os.environ.get("BUCKET_NAME", "gs-batch-retail-bronze")

    ventas = generar_ventas(n=500)
    blob_name = subir_a_gcs(ventas, bucket_name, project_id)

    return {"status": "ok", "registros": len(ventas), "archivo": blob_name}

if __name__ == "__main__":
    main()