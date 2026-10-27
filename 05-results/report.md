# Reporte — SQL: Window Functions

## Pregunta de negocio

¿Cómo evolucionan los ingresos mensuales, qué categorías contribuyen más y qué patrones de recompra aparecen al observar secuencias de pedidos y cohortes de clientes?

## KPIs del dataset sintético

| KPI | Resultado |
|---|---:|
| Pedidos | 3.500 |
| Productos en catálogo | 500 |
| Clientes únicos | 877 |
| Unidades vendidas | 10.602 |
| Ingresos netos | 608.810,14 |
| Costo estimado | 364.075,27 |
| Margen bruto estimado | 244.734,87 |
| Margen sobre ingresos | 40,20% |
| Período analizado | Ene 2024 – Dic 2025 |

## Insights

1. **Infantil lidera por categoría.** Genera 105.711,81, equivalente al 17,36% de los ingresos. OTC aporta 104.438,16 y Perfumería 103.784,47. Las tres categorías suman aproximadamente 51,56% del total.
2. **El total anual es estable.** Los ingresos suman 304.482,45 en 2024 y 304.327,69 en 2025; la diferencia es de -154,76, aproximadamente -0,05%. No se observa crecimiento anual relevante en este dataset.
3. **Agosto de 2025 fue el mes de mayores ingresos.** Registró 30.039,91, seguido por mayo de 2025 con 29.938,16. Junio de 2024 fue el menor mes, con 21.599,70.
4. **Paid Social es el canal con más ingresos.** Aporta 95.217,15; Email queda cerca, con 94.856,04. La diferencia es pequeña y no demuestra que un canal sea más rentable después de costos de adquisición.
5. **La ventana mensual permite separar cambio de tendencia y nivel.** `LAG()` calcula la variación contra el mes anterior, el promedio móvil de tres meses reduce parte del ruido mensual y la suma acumulada muestra el progreso contra el total de 608.810,14.
6. **La retención por cohorte requiere interpretación cuidadosa.** El cálculo considera clientes activos en cada mes calendario después de su primera compra. Como un cliente puede saltarse un mes y regresar más tarde, los porcentajes pueden subir entre meses; no se deben interpretar como una curva necesariamente decreciente.
7. **La secuencia por cliente identifica recompra.** `ROW_NUMBER()` ordena pedidos por cliente y `LAG()` calcula la fecha anterior y los días entre compras, una base útil para análisis de frecuencia y segmentación RFM.

## Cómo leer las funciones

- `DENSE_RANK()`: ordena categorías por ingresos sin saltos en la numeración cuando hay empates.
- `LAG()`: recupera el valor de la fila anterior para calcular cambios o intervalos.
- `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`: calcula una ventana móvil de tres observaciones mensuales.
- `SUM() OVER (... UNBOUNDED PRECEDING ...)`: acumula ingresos a través del tiempo.
- `ROW_NUMBER() OVER (PARTITION BY customer_id ...)`: numera las compras de cada cliente.
- La consulta de cohortes calcula el mes inicial y los meses de actividad, y expresa los clientes activos como porcentaje del tamaño inicial.

## Recomendaciones

- Comparar períodos equivalentes y sumar una visualización de ingresos, variación mensual y promedio móvil.
- Complementar la retención con cohortes de primera compra y una definición explícita de retorno; no asumir que el cliente debe comprar todos los meses.
- Agregar `product_id` a las ventas para analizar la secuencia de compra por producto.
- Incluir costos de marketing y operativos para estimar rentabilidad real por canal.
- Añadir un análisis RFM con reglas documentadas si el objetivo es priorizar clientes para campañas.

## Riesgos y limitaciones

- Dataset sintético; las conclusiones no representan una empresa real.
- Los importes no tienen moneda real asociada.
- El costo es estimado; margen bruto no equivale a beneficio neto.
- No hay `product_id` en ventas.
- La actividad por mes calendario no implica compras mensuales continuas ni prueba causalidad.

## Reproducibilidad

Las cuatro consultas de ventana se ejecutan en SQLite en memoria y se validan con pytest. La automatización comprueba el total de ingresos, los 24 meses, el acumulado final y el 100% de retención en el mes de inicio de cada cohorte.
