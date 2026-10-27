# Reporte — SQL: Window Functions

## Pregunta de negocio

¿Cómo evoluciona el ingreso mensual y qué patrones descriptivos aparecen al usar funciones de ventana sobre ventas sintéticas?

## KPIs base

| KPI | Resultado |
|---|---:|
| Pedidos | 3.500 |
| Clientes únicos | 877 |
| Unidades vendidas | 10.602 |
| Ingresos netos | 608.810,14 |
| Costo estimado | 364.075,27 |
| Margen bruto estimado | 244.734,87 |
| Tasa de margen estimada | 40,20% |

## Insights del análisis temporal

1. **El mes con mayor ingreso fue agosto de 2025**, con 30.039,91; mayo de 2025 quedó cerca con 29.938,16.
2. **El menor ingreso mensual fue junio de 2024**, con 21.599,70.
3. **El mayor crecimiento MoM fue +21,23% en agosto de 2025**, frente a julio de 2025. El mayor descenso fue −25,30% en junio de 2025, frente a mayo de 2025.
4. **El acumulado mensual termina en 608.810,14**, consistente con la suma de ingresos del dataset. La prueba automatizada comprueba este invariante.
5. **La media móvil de siete observaciones suaviza variaciones diarias**, pero se calcula sobre fechas con ventas observadas, no sobre un calendario continuo.
6. **Las cohortes permiten comparar clientes activos por mes desde su primera compra.** Es una vista descriptiva; no prueba causalidad ni sustituye una definición de retención con ventanas y denominadores acordados.

## Técnicas SQL

- `LAG()`: ingreso del mes anterior y cambio porcentual MoM.
- `SUM() OVER (... UNBOUNDED PRECEDING)`: ingreso acumulado.
- `AVG() OVER (... 6 PRECEDING)`: promedio móvil de siete fechas observadas.
- `MIN()`, CTEs y `COUNT(DISTINCT)`: cohorte de primera compra y actividad mensual.
- `ROW_NUMBER() OVER (PARTITION BY country ...)`: top tres clientes por país.

## Validación

- Ocho consultas SQL con nombre se ejecutan en SQLite.
- Los tests verifican 24 meses, cambio MoM nulo para el primer mes, acumulado final y rankings por país.
- Las consultas de ventana mantienen el total de ingresos netos de 608.810,14.
- GitHub Actions ejecuta el runner y los tests en cada cambio.

## Recomendaciones

- Para medir retención, definir cohortes, horizonte y denominador antes de interpretar el porcentaje.
- Para medias móviles de días calendario, generar una tabla calendario y completar fechas sin ventas con cero.
- Añadir `product_id` a las ventas para analizar producto individual.
- Incorporar costos de adquisición para comparar rentabilidad por canal.

## Limitaciones

Los datos son sintéticos y los importes no están asociados a una moneda real. El margen es una aproximación, y los cambios MoM no implican tendencias causales.
