-- QUERY: Q01 Category revenue ranking
WITH category_revenue AS (
    SELECT category, ROUND(SUM(CAST(net_revenue AS REAL)), 2) AS revenue
    FROM sales
    GROUP BY category
)
SELECT category,
       revenue,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_pct
FROM category_revenue
ORDER BY revenue_rank, category;

-- QUERY: Q02 Monthly revenue trend, lag, rolling average, and running total
WITH monthly AS (
    SELECT strftime('%Y-%m', order_date) AS month,
           ROUND(SUM(CAST(net_revenue AS REAL)), 2) AS revenue
    FROM sales
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT month,
       revenue,
       LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS month_over_month_change,
       ROUND(
           100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
           / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
           2
       ) AS month_over_month_pct,
       ROUND(AVG(revenue) OVER (
           ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 2) AS rolling_3_month_avg,
       ROUND(SUM(revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)
           AS cumulative_revenue
FROM monthly
ORDER BY month;

-- QUERY: Q03 Customer order sequence and days between purchases
WITH customer_orders AS (
    SELECT customer_id,
           order_id,
           order_date,
           CAST(net_revenue AS REAL) AS net_revenue,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id ORDER BY order_date, order_id
           ) AS order_number,
           LAG(order_date) OVER (
               PARTITION BY customer_id ORDER BY order_date, order_id
           ) AS previous_order_date
    FROM sales
)
SELECT customer_id,
       order_id,
       order_date,
       order_number,
       previous_order_date,
       CAST(julianday(order_date) - julianday(previous_order_date) AS INTEGER)
           AS days_since_previous_order,
       ROUND(net_revenue, 2) AS net_revenue
FROM customer_orders
ORDER BY customer_id, order_number;

-- QUERY: Q04 Monthly cohort retention
WITH first_purchase AS (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM sales
    GROUP BY customer_id
),
customer_activity AS (
    SELECT DISTINCT customer_id, strftime('%Y-%m', order_date) AS activity_month
    FROM sales
),
cohort_activity AS (
    SELECT strftime('%Y-%m', first_order_date) AS cohort_month,
           activity_month,
           CAST(strftime('%Y', activity_month || '-01') AS INTEGER) * 12
               + CAST(strftime('%m', activity_month || '-01') AS INTEGER)
               - CAST(strftime('%Y', first_order_date) AS INTEGER) * 12
               - CAST(strftime('%m', first_order_date) AS INTEGER) AS month_offset,
           customer_activity.customer_id
    FROM customer_activity
    JOIN first_purchase USING (customer_id)
    WHERE activity_month >= strftime('%Y-%m', first_order_date)
),
retention_counts AS (
    SELECT cohort_month,
           activity_month,
           month_offset,
           COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_activity
    GROUP BY cohort_month, activity_month, month_offset
),
retention_with_size AS (
    SELECT cohort_month,
           activity_month,
           month_offset,
           active_customers,
           MAX(CASE WHEN month_offset = 0 THEN active_customers END)
               OVER (PARTITION BY cohort_month) AS cohort_size
    FROM retention_counts
)
SELECT cohort_month,
       activity_month,
       month_offset,
       cohort_size,
       active_customers,
       ROUND(100.0 * active_customers / NULLIF(cohort_size, 0), 2) AS retention_pct
FROM retention_with_size
ORDER BY cohort_month, month_offset;
