-- Ventanas: ranking por ingresos
SELECT category,
       SUM(net_revenue) AS revenue,
       RANK() OVER (ORDER BY SUM(net_revenue) DESC) AS revenue_rank
FROM sales
GROUP BY category;

-- Promedio móvil 7 días (si hubiera granularidad diaria)
-- Ejemplo conceptual (depende del motor y calendario):
-- AVG(daily_revenue) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
