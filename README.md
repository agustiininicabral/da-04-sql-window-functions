# SQL: Window Functions

Proyecto de portfolio de Data Analytics centrado en funciones de ventana: ranking, comparaciones mes a mes, promedios móviles, secuencias de compra y retención por cohorte.

![SQL CI](https://github.com/agustiininicabral/da-04-sql-window-functions/actions/workflows/ci.yml/badge.svg)

## Dataset

- `02-data/raw/sales.csv`: 3.500 pedidos sintéticos entre enero de 2024 y diciembre de 2025.
- `02-data/raw/products.csv`: catálogo sintético de 500 productos.
- `02-data/raw/DATA_DICTIONARY.md`: columnas, granularidad y limitaciones.

Los importes son unidades monetarias ficticias; no representan una moneda real ni resultados de una empresa.

## Requisitos y ejecución en Windows

Requiere Python 3.12. Desde PowerShell, en la raíz del repositorio:

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements-dev.txt
python scripts/run_sql.py
python -m pytest -q
ruff format --check scripts tests
ruff check scripts tests
```

El ejecutor crea tablas temporales en SQLite en memoria, carga los CSV y corre las consultas de `03-work/sql/02_window_examples.sql`. No necesita servidor de base de datos ni modifica los archivos originales. GitHub Actions corre las mismas validaciones en cada push y pull request.

## Consultas de ventana incluidas

1. **Ranking por categoría:** `DENSE_RANK()` y participación porcentual sobre el total.
2. **Tendencia mensual:** `LAG()`, variación absoluta y porcentual, promedio móvil de tres meses y acumulado.
3. **Secuencia por cliente:** `ROW_NUMBER()`, fecha de compra anterior y días entre pedidos con `LAG()`.
4. **Retención por cohorte:** primer mes de compra, mes de actividad, offset mensual, tamaño de cohorte y porcentaje de retención.

## Resultados

El análisis con cifras verificadas está en [05-results/report.md](05-results/report.md). Las consultas se prueban automáticamente para detectar errores de ejecución, verificar los totales y validar que las cohortes comiencen con 100% de clientes activos en el mes inicial.

## Estructura

- `01-requirements/`: alcance e hipótesis.
- `02-data/raw/`: datos originales y diccionario.
- `03-work/sql/`: consultas SQL.
- `scripts/run_sql.py`: ejecutor reproducible.
- `tests/test_sql_runner.py`: pruebas automatizadas.
- `05-results/report.md`: KPIs, insights y limitaciones.

## Limitaciones

Los datos son sintéticos. El archivo de ventas no incluye `product_id`, así que no permite analizar retención por producto ni vincular una compra a un SKU. La retención mide presencia del cliente en un mes calendario; un cliente puede regresar después de saltarse un mes, por lo que la curva no tiene por qué ser estrictamente decreciente.

## Licencia

MIT.
