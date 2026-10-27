-- SQL basics included for comparison with windowed analysis.
-- QUERY: Q01 Top categories by net revenue
SELECT category, ROUND(SUM(CAST(net_revenue AS REAL)), 2) AS revenue
FROM sales
GROUP BY category
ORDER BY revenue DESC;

-- QUERY: Q02 Estimated gross margin by channel
SELECT channel,
       ROUND(SUM(CAST(net_revenue AS REAL)), 2) AS revenue,
       ROUND(SUM(CAST(net_revenue AS REAL) - CAST(cost AS REAL)), 2) AS gross_margin
FROM sales
GROUP BY channel
ORDER BY gross_margin DESC;

-- QUERY: Q03 Top customers by cumulative net revenue
SELECT customer_id,
       ROUND(SUM(CAST(net_revenue AS REAL)), 2) AS revenue_lifetime_proxy,
       COUNT(*) AS orders
FROM sales
GROUP BY customer_id
ORDER BY revenue_lifetime_proxy DESC
LIMIT 20;
