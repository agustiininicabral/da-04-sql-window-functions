-- SQL window functions: SQLite / PostgreSQL compatible.
-- The moving average is over the seven most recent observed order dates,
-- not necessarily seven consecutive calendar days.

-- QUERY: Q04 Monthly revenue with month-over-month change
WITH monthly AS (
    SELECT substr(order_date, 1, 7) AS month,
           ROUND(SUM(CAST(net_revenue AS REAL)), 2) AS revenue
    FROM sales
    GROUP BY substr(order_date, 1, 7)
),
lagged AS (
    SELECT month,
           revenue,
           LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly
)
SELECT month,
       revenue,
       previous_month_revenue,
       CASE
           WHEN previous_month_revenue IS NULL OR previous_month_revenue = 0 THEN NULL
           ELSE ROUND(
               (revenue - previous_month_revenue) * 100.0 / previous_month_revenue,
               2
           )
       END AS mom_change_pct
FROM lagged
ORDER BY month;

-- QUERY: Q05 Monthly revenue running total
WITH monthly AS (
    SELECT substr(order_date, 1, 7) AS month,
           ROUND(SUM(CAST(net_revenue AS REAL)), 2) AS revenue
    FROM sales
    GROUP BY substr(order_date, 1, 7)
)
SELECT month,
       revenue,
       ROUND(
           SUM(revenue) OVER (
               ORDER BY month
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ),
           2
       ) AS cumulative_revenue
FROM monthly
ORDER BY month;

-- QUERY: Q06 Seven-observed-date moving average of daily revenue
WITH daily AS (
    SELECT order_date,
           ROUND(SUM(CAST(net_revenue AS REAL)), 2) AS daily_revenue
    FROM sales
    GROUP BY order_date
)
SELECT order_date,
       daily_revenue,
       ROUND(
           AVG(daily_revenue) OVER (
               ORDER BY order_date
               ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
           ),
           2
       ) AS moving_average_7_observed_dates
FROM daily
ORDER BY order_date;

-- QUERY: Q07 Monthly cohort activity proxy
WITH first_month AS (
    SELECT customer_id,
           MIN(substr(order_date, 1, 7)) AS cohort_month
    FROM sales
    GROUP BY customer_id
),
customer_months AS (
    SELECT DISTINCT customer_id, substr(order_date, 1, 7) AS activity_month
    FROM sales
),
cohort_activity AS (
    SELECT first_month.cohort_month,
           customer_months.activity_month,
           customer_months.customer_id,
           (
               CAST(substr(customer_months.activity_month, 1, 4) AS INTEGER) * 12
               + CAST(substr(customer_months.activity_month, 6, 2) AS INTEGER)
           ) - (
               CAST(substr(first_month.cohort_month, 1, 4) AS INTEGER) * 12
               + CAST(substr(first_month.cohort_month, 6, 2) AS INTEGER)
           ) AS month_number
    FROM first_month
    INNER JOIN customer_months
        ON customer_months.customer_id = first_month.customer_id
)
SELECT cohort_month,
       activity_month,
       month_number,
       COUNT(DISTINCT customer_id) AS active_customers
FROM cohort_activity
GROUP BY cohort_month, activity_month, month_number
ORDER BY cohort_month, month_number;

-- QUERY: Q08 Top three customers by revenue within each country
WITH customer_country AS (
    SELECT country,
           customer_id,
           ROUND(SUM(CAST(net_revenue AS REAL)), 2) AS revenue
    FROM sales
    GROUP BY country, customer_id
),
ranked AS (
    SELECT country,
           customer_id,
           revenue,
           ROW_NUMBER() OVER (
               PARTITION BY country
               ORDER BY revenue DESC, customer_id
           ) AS country_rank
    FROM customer_country
)
SELECT country, customer_id, revenue, country_rank
FROM ranked
WHERE country_rank <= 3
ORDER BY country, country_rank;
