
CREATE TABLE retail (
    invoice        VARCHAR(20),
    stockcode      VARCHAR(20),
    description    TEXT,
    quantity       INT,
    invoicedate    TIMESTAMP,
    price          NUMERIC(10,2),
    customer_id    INT,
    country        VARCHAR(50)
);


/* =========================
   2. BASIC DATA QUALITY CHECKS
   ========================= */

-- Q: How many records are available for analysis?
SELECT COUNT(*) AS total_rows FROM retail;

-- Q: Are there invalid or noisy records that can distort revenue?
SELECT *
FROM retail
WHERE quantity <= 0
   OR price <= 0
   OR stockcode IS NULL
   OR invoicedate IS NULL;


/* =========================
   3. CORE METRIC VIEW
   ========================= */

-- Standardized transactional revenue view
CREATE OR REPLACE VIEW sales_base AS
SELECT
    invoice,
    stockcode,
    description,
    quantity,
    price,
    quantity * price AS revenue,
    DATE(invoicedate) AS sale_date,
    customer_id,
    country
FROM retail
WHERE quantity > 0 AND price > 0;




/* ------------------------------------------------------------
   Q1. Which SKUs drive 80% of revenue? (ABC Analysis)
   DECISION:
   Focus inventory availability & pricing effort on A-class SKUs
   ------------------------------------------------------------ */

WITH sku_revenue AS (
    SELECT
        stockcode,
        description,
        SUM(revenue) AS total_revenue
    FROM sales_base
    GROUP BY stockcode, description
),
ranked AS (
    SELECT *,
           SUM(total_revenue) OVER () AS grand_total,
           SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS running_revenue
    FROM sku_revenue
)
SELECT
    stockcode,
    description,
    total_revenue,
    ROUND(100 * running_revenue / grand_total, 2) AS cumulative_pct,
    CASE
        WHEN running_revenue / grand_total <= 0.80 THEN 'A'
        WHEN running_revenue / grand_total <= 0.95 THEN 'B'
        ELSE 'C'
    END AS abc_class
FROM ranked
ORDER BY total_revenue DESC;


/* ------------------------------------------------------------
   Q2. What is the daily demand velocity per SKU?
   DECISION:
   Identify fast-moving vs slow-moving items for replenishment
   ------------------------------------------------------------ */

SELECT
    stockcode,
    description,
    ROUND(SUM(quantity) / COUNT(DISTINCT sale_date), 2) AS avg_daily_demand
FROM sales_base
GROUP BY stockcode, description
ORDER BY avg_daily_demand DESC;


/* ------------------------------------------------------------
   Q3. Which products are at high risk of stock-out?
   (Demand volatility proxy)
   DECISION:
   Increase safety stock for volatile-demand SKUs
   ------------------------------------------------------------ */

WITH daily_sales AS (
    SELECT
        stockcode,
        sale_date,
        SUM(quantity) AS daily_qty
    FROM sales_base
    GROUP BY stockcode, sale_date
),
stats AS (
    SELECT
        stockcode,
        AVG(daily_qty) AS avg_qty,
        STDDEV(daily_qty) AS demand_volatility
    FROM daily_sales
    GROUP BY stockcode
)
SELECT
    stockcode,
    avg_qty,
    demand_volatility,
    ROUND(demand_volatility / NULLIF(avg_qty,0), 2) AS risk_ratio
FROM stats
ORDER BY risk_ratio DESC;


/* ------------------------------------------------------------
   Q4. Which SKUs show strong price sensitivity?
   DECISION:
   Avoid price hikes on elastic products
   ------------------------------------------------------------ */

SELECT
    stockcode,
    description,
    CORR(price, quantity) AS price_demand_correlation
FROM sales_base
GROUP BY stockcode, description
HAVING COUNT(*) > 30
ORDER BY price_demand_correlation;


/* ------------------------------------------------------------
   Q5. Where are we potentially losing revenue due to stock-outs?
   (Inferred via demand gaps)
   DECISION:
   Prioritize restocking high-revenue SKUs with frequent gaps
   ------------------------------------------------------------ */

WITH daily AS (
    SELECT
        stockcode,
        sale_date,
        SUM(quantity) AS qty
    FROM sales_base
    GROUP BY stockcode, sale_date
),
gaps AS (
    SELECT
        stockcode,
        sale_date,
        LAG(sale_date) OVER (PARTITION BY stockcode ORDER BY sale_date) AS prev_day
    FROM daily
)
SELECT
    stockcode,
    COUNT(*) AS suspected_stockout_events
FROM gaps
WHERE sale_date - prev_day > 2
GROUP BY stockcode
ORDER BY suspected_stockout_events DESC;


/* ------------------------------------------------------------
   Q6. Which customers generate the majority of revenue?
   DECISION:
   Protect high-value customers with service guarantees
   ------------------------------------------------------------ */

SELECT
    customer_id,
    SUM(revenue) AS customer_revenue
FROM sales_base
GROUP BY customer_id
ORDER BY customer_revenue DESC
LIMIT 20;


/* ------------------------------------------------------------
   Q7. Revenue concentration risk by country
   DECISION:
   Identify geographic dependency risks
   ------------------------------------------------------------ */

SELECT
    country,
    SUM(revenue) AS total_revenue,
    ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS pct_share
FROM sales_base
GROUP BY country
ORDER BY total_revenue DESC;


/* ------------------------------------------------------------
   Q8. Low-performing SKUs for delisting consideration
   DECISION:
   Reduce catalog clutter & operational cost
   ------------------------------------------------------------ */

SELECT
    stockcode,
    description,
    SUM(quantity) AS total_units_sold,
    SUM(revenue) AS total_revenue
FROM sales_base
GROUP BY stockcode, description
HAVING SUM(quantity) < 50
ORDER BY total_revenue ASC;


/* =========================
   END OF ANALYSIS
   ========================= */
