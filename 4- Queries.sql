SELECT
    dp.category,
    ROUND(SUM(f.sales), 2)  AS total_sales,
    ROUND(SUM(f.profit), 2) AS total_profit,
    ROUND(100.0 * SUM(f.profit) / NULLIF(SUM(f.sales), 0), 2) AS profit_margin_pct
FROM fact_sales f
JOIN dim_product dp ON dp.product_key = f.product_key
GROUP BY dp.category
ORDER BY total_sales DESC;
------------------------------------------------------------------------------------
SELECT
    dp.category, dp.sub_category,
    ROUND(SUM(f.sales), 2)  AS total_sales,
    ROUND(SUM(f.profit), 2) AS total_profit,
    CASE
        WHEN SUM(f.profit) < 0                              THEN 'Loss-Making'
        WHEN SUM(f.profit) / NULLIF(SUM(f.sales), 0) < 0.05  THEN 'Low Margin'
        WHEN SUM(f.profit) / NULLIF(SUM(f.sales), 0) < 0.15  THEN 'Healthy Margin'
        ELSE 'High Margin'
    END AS profitability_label
FROM fact_sales f
JOIN dim_product dp ON dp.product_key = f.product_key
GROUP BY dp.category, dp.sub_category
ORDER BY total_profit ASC;
------------------------------------------------------------------------------------
SELECT
    dc.customer_name, dc.segment,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.sales), 2)     AS total_sales,
    ROUND(SUM(f.profit), 2)    AS total_profit
FROM fact_sales f
JOIN dim_customer dc ON dc.customer_key = f.customer_key
GROUP BY dc.customer_name, dc.segment
ORDER BY total_profit DESC
LIMIT 10;
------------------------------------------------------------------------------------
SELECT
    dl.state, dc.segment,
    ROUND(SUM(f.sales), 2)  AS total_sales,
    ROUND(SUM(f.profit), 2) AS total_profit
FROM fact_sales f
JOIN dim_location dl ON dl.location_key = f.location_key
JOIN dim_customer dc ON dc.customer_key = f.customer_key
GROUP BY dl.state, dc.segment
ORDER BY dl.state, total_sales DESC;
------------------------------------------------------------------------------------
WITH monthly_sales AS (
    SELECT dd.year, dd.month_num, TRIM(dd.month_name) AS month_name,
           SUM(f.sales) AS total_sales, SUM(f.profit) AS total_profit
    FROM fact_sales f
    JOIN dim_date dd ON dd.date_key = f.order_date_key
    GROUP BY dd.year, dd.month_num, dd.month_name
)
SELECT * FROM monthly_sales ORDER BY year, month_num;
------------------------------------------------------------------------------------
WITH yearly_sales AS (
    SELECT dd.year, SUM(f.sales) AS total_sales
    FROM fact_sales f
    JOIN dim_date dd ON dd.date_key = f.order_date_key
    GROUP BY dd.year
)
SELECT
    year, total_sales,
    LAG(total_sales) OVER (ORDER BY year) AS prev_year_sales,
    ROUND(100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY year))
          / NULLIF(LAG(total_sales) OVER (ORDER BY year), 0), 2) AS yoy_growth_pct
FROM yearly_sales
ORDER BY year;
------------------------------------------------------------------------------------
SELECT
    CASE
        WHEN (dsd.full_date - dod.full_date) <= 2 THEN '0-2 days'
        WHEN (dsd.full_date - dod.full_date) <= 4 THEN '3-4 days'
        WHEN (dsd.full_date - dod.full_date) <= 6 THEN '5-6 days'
        ELSE '7+ days'
    END AS fulfillment_bucket,
    COUNT(*) AS num_orders,
    ROUND(AVG(f.profit), 2) AS avg_profit
FROM fact_sales f
JOIN dim_date dod ON dod.date_key = f.order_date_key
JOIN dim_date dsd ON dsd.date_key = f.ship_date_key
GROUP BY fulfillment_bucket
ORDER BY fulfillment_bucket;
------------------------------------------------------------------------------------
SELECT
    dp.product_name, dp.category,
    ROUND(SUM(f.sales), 2) AS product_total_sales
FROM fact_sales f
JOIN dim_product dp ON dp.product_key = f.product_key
GROUP BY dp.product_name, dp.category
HAVING SUM(f.sales) > (
    SELECT AVG(sub.product_sales)
    FROM (SELECT product_key, SUM(sales) AS product_sales FROM fact_sales GROUP BY product_key) sub
)
ORDER BY product_total_sales DESC;
------------------------------------------------------------------------------------
WITH ranked_products AS (
    SELECT dp.category, dp.product_name, SUM(f.profit) AS total_profit,
           ROW_NUMBER() OVER (PARTITION BY dp.category ORDER BY SUM(f.profit) DESC) AS rnk
    FROM fact_sales f
    JOIN dim_product dp ON dp.product_key = f.product_key
    GROUP BY dp.category, dp.product_name
)
SELECT category, product_name, ROUND(total_profit, 2) AS total_profit
FROM ranked_products
WHERE rnk <= 3
ORDER BY category, rnk;
------------------------------------------------------------------------------------
SELECT
    dc.customer_name,
    ROUND(SUM(f.sales), 2) AS lifetime_sales,
    CASE
        WHEN SUM(f.sales) >= 5000 THEN 'Platinum'
        WHEN SUM(f.sales) >= 2000 THEN 'Gold'
        WHEN SUM(f.sales) >= 500  THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM fact_sales f
JOIN dim_customer dc ON dc.customer_key = f.customer_key
GROUP BY dc.customer_name
ORDER BY lifetime_sales DESC;
------------------------------------------------------------------------------------
SELECT
    dc.customer_name,
    ROUND(AVG(f.discount), 3) AS avg_customer_discount
FROM fact_sales f
JOIN dim_customer dc ON dc.customer_key = f.customer_key
GROUP BY dc.customer_name
HAVING AVG(f.discount) > (SELECT AVG(discount) FROM fact_sales)
ORDER BY avg_customer_discount DESC;
------------------------------------------------------------------------------------
WITH customer_orders AS (
    SELECT dc.customer_key, dc.customer_name,
           COUNT(DISTINCT f.order_id) AS num_orders, SUM(f.profit) AS total_profit
    FROM fact_sales f
    JOIN dim_customer dc ON dc.customer_key = f.customer_key
    GROUP BY dc.customer_key, dc.customer_name
)
SELECT
    CASE WHEN num_orders > 1 THEN 'Repeat Customer' ELSE 'One-Time Customer' END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(SUM(total_profit), 2) AS total_profit_contribution,
    ROUND(AVG(total_profit), 2) AS avg_profit_per_customer
FROM customer_orders
GROUP BY customer_type;
------------------------------------------------------------------------------------
WITH monthly AS (
    SELECT dd.year, dd.month_num, SUM(f.sales) AS month_sales
    FROM fact_sales f
    JOIN dim_date dd ON dd.date_key = f.order_date_key
    GROUP BY dd.year, dd.month_num
)
SELECT year, month_num, month_sales,
       ROUND(SUM(month_sales) OVER (ORDER BY year, month_num), 2) AS running_total_sales
FROM monthly
ORDER BY year, month_num;
------------------------------------------------------------------------------------
SELECT
    dsm.ship_mode,
    COUNT(*) AS num_line_items,
    ROUND(AVG(dsd.full_date - dod.full_date), 1) AS avg_days_to_ship,
    ROUND(SUM(f.profit), 2) AS total_profit
FROM fact_sales f
JOIN dim_ship_mode dsm ON dsm.ship_mode_key = f.ship_mode_key
JOIN dim_date dod ON dod.date_key = f.order_date_key
JOIN dim_date dsd ON dsd.date_key = f.ship_date_key
GROUP BY dsm.ship_mode
ORDER BY total_profit DESC;
------------------------------------------------------------------------------------
WITH discount_buckets AS (
    SELECT
        CASE
            WHEN discount = 0     THEN 'No Discount'
            WHEN discount <= 0.20 THEN 'Low (0-20%)'
            WHEN discount <= 0.50 THEN 'Medium (21-50%)'
            ELSE 'High (>50%)'
        END AS discount_band,
        sales, profit
    FROM fact_sales
)
SELECT
    discount_band,
    COUNT(*) AS num_line_items,
    ROUND(SUM(sales), 2)  AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM discount_buckets
GROUP BY discount_band
ORDER BY total_profit ASC;
------------------------------------------------------------------------------------
SELECT
    dp.product_name, f.sales, f.discount, f.profit,
    CASE WHEN f.profit < 0 THEN 'Loss' ELSE 'Profit' END AS outcome
FROM fact_sales f
JOIN dim_product dp ON dp.product_key = f.product_key
WHERE dp.category = 'Furniture' AND f.profit < 0
ORDER BY f.profit ASC
LIMIT 20;
------------------------------------------------------------------------------------
SELECT state, avg_order_profit
FROM (
    SELECT dl.state, ROUND(AVG(f.profit), 2) AS avg_order_profit
    FROM fact_sales f
    JOIN dim_location dl ON dl.location_key = f.location_key
    GROUP BY dl.state
) state_profit
WHERE avg_order_profit < 0
ORDER BY avg_order_profit ASC;
------------------------------------------------------------------------------------
WITH quarterly AS (
    SELECT dd.year, dd.quarter, SUM(f.sales) AS q_sales, SUM(f.profit) AS q_profit
    FROM fact_sales f
    JOIN dim_date dd ON dd.date_key = f.order_date_key
    GROUP BY dd.year, dd.quarter
)
SELECT year, quarter, ROUND(q_sales, 2) AS q_sales, ROUND(q_profit, 2) AS q_profit,
       ROUND(100.0 * q_profit / NULLIF(q_sales, 0), 2) AS q_margin_pct
FROM quarterly
ORDER BY year, quarter;
------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_monthly_sales_summary AS
SELECT
    dd.year, dd.month_num, TRIM(dd.month_name) AS month_name, dp.category,
    ROUND(SUM(f.sales), 2)  AS total_sales,
    ROUND(SUM(f.profit), 2) AS total_profit,
    ROUND(100.0 * SUM(f.profit) / NULLIF(SUM(f.sales), 0), 2) AS profit_margin_pct,
    COUNT(DISTINCT f.order_id) AS num_orders
FROM fact_sales f
JOIN dim_date dd    ON dd.date_key = f.order_date_key
JOIN dim_product dp ON dp.product_key = f.product_key
GROUP BY dd.year, dd.month_num, dd.month_name, dp.category;
------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_customer_profitability AS
SELECT
    dc.customer_id, dc.customer_name, dc.segment,
    COUNT(DISTINCT f.order_id) AS total_orders,
    ROUND(SUM(f.sales), 2)  AS lifetime_sales,
    ROUND(SUM(f.profit), 2) AS lifetime_profit,
    CASE
        WHEN SUM(f.sales) >= 5000 THEN 'Platinum'
        WHEN SUM(f.sales) >= 2000 THEN 'Gold'
        WHEN SUM(f.sales) >= 500  THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM fact_sales f
JOIN dim_customer dc ON dc.customer_key = f.customer_key
GROUP BY dc.customer_id, dc.customer_name, dc.segment;
------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_kpi_report(DATE, DATE);
CREATE OR REPLACE PROCEDURE sp_kpi_report(p_start_date DATE, p_end_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales NUMERIC(14,2); v_total_profit NUMERIC(14,2);
    v_order_count INT; v_margin_pct NUMERIC(6,2); v_avg_order_val NUMERIC(14,2);
BEGIN
    SELECT ROUND(SUM(f.sales), 2), ROUND(SUM(f.profit), 2), COUNT(DISTINCT f.order_id)
    INTO v_total_sales, v_total_profit, v_order_count
    FROM fact_sales f
    JOIN dim_date dd ON dd.date_key = f.order_date_key
    WHERE dd.full_date BETWEEN p_start_date AND p_end_date;

    v_margin_pct    := ROUND(100.0 * v_total_profit / NULLIF(v_total_sales, 0), 2);
    v_avg_order_val := ROUND(v_total_sales / NULLIF(v_order_count, 0), 2);

    RAISE NOTICE 'KPI Report % to %', p_start_date, p_end_date;
    RAISE NOTICE 'Total Sales: %', v_total_sales;
    RAISE NOTICE 'Total Profit: %', v_total_profit;
    RAISE NOTICE 'Profit Margin %%: %', v_margin_pct;
    RAISE NOTICE 'Order Count: %', v_order_count;
    RAISE NOTICE 'Avg Order Value: %', v_avg_order_val;
END;
$$;
------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS sp_top_n_products(VARCHAR, INT);
CREATE OR REPLACE FUNCTION sp_top_n_products(p_category VARCHAR, p_n INT)
RETURNS TABLE (product_name VARCHAR, total_sales NUMERIC, total_profit NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT dp.product_name, ROUND(SUM(f.sales), 2), ROUND(SUM(f.profit), 2)
    FROM fact_sales f
    JOIN dim_product dp ON dp.product_key = f.product_key
    WHERE dp.category = p_category
    GROUP BY dp.product_name
    ORDER BY SUM(f.profit) DESC
    LIMIT p_n;
END;
$$;
------------------------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT dp.category, SUM(f.sales)
FROM fact_sales f
JOIN dim_product dp ON dp.product_key = f.product_key
GROUP BY dp.category;

CALL sp_kpi_report('2016-01-01', '2016-12-31');
SELECT *
FROM sp_top_n_products('Technology', 5);