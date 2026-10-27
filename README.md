# SQL: Window Functions

Proyecto de portfolio para practicar funciones de ventana con ventas sintéticas: ranking, `LAG`, acumulados, medias móviles y cohortes.

![SQL CI](https://github.com/agustiininicabral/da-04-sql-window-functions/actions/workflows/ci.yml/badge.svg)

## Dataset

- `02-data/raw/sales.csv`: 3.500 pedidos.
- `02-data/raw/products.csv`: catálogo de 500 productos.
- `02-data/raw/DATA_DICTIONARY.md`: definición de campos y limitaciones.

Los datos son ficticios. El runner carga los CSV en SQLite en memoria; no requiere un servidor de base de datos ni modifica archivos originales.

## Ejecutar en Windows PowerShell

Desde la raíz del repositorio:

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements-dev.txt
python scripts/run_sql.py
python -m pytest -q
ruff format --check scripts tests
ruff check scripts tests
```

GitHub Actions ejecuta las mismas verificaciones en cada push y pull request.

## Consultas incluidas

- Q01–Q03: ingresos por categoría, margen por canal y top clientes.
- Q04: `LAG` para variación mensual MoM.
- Q05: ingreso acumulado con `SUM() OVER`.
- Q06: promedio móvil de siete fechas de pedido observadas.
- Q07: actividad mensual por cohorte de primera compra.
- Q08: `ROW_NUMBER()` para top tres clientes por país.

La media móvil usa las siete fechas observadas más recientes; si faltan fechas calendario, no representa necesariamente siete días consecutivos. El análisis de cohortes muestra actividad mensual, pero no debe confundirse con una predicción de retención.

## Resultados

Ver [05-results/report.md](05-results/report.md) para métricas, ejemplos y limitaciones. Los importes son unidades monetarias sintéticas.

## Limitaciones

- El dataset no representa una empresa real.
- Los datos de ventas no contienen `product_id`.
- El margen usa `net_revenue - cost` y no incluye gastos operativos ni de marketing.
- Las métricas de cohorte son descriptivas y dependen del horizonte de datos disponible.

## Licencia

MIT.
