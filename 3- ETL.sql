INSERT INTO dim_date (date_key, full_date, day_of_month, day_name, month_num, month_name, quarter, year, is_weekend)
SELECT
    CAST(TO_CHAR(d, 'YYYYMMDD') AS INT),
    d,
    EXTRACT(DAY FROM d)::SMALLINT,
    TO_CHAR(d, 'Day'),
    EXTRACT(MONTH FROM d)::SMALLINT,
    TO_CHAR(d, 'Month'),
    EXTRACT(QUARTER FROM d)::SMALLINT,
    EXTRACT(YEAR  FROM d)::SMALLINT,
    (EXTRACT(ISODOW FROM d) IN (6, 7))
FROM (
    SELECT generate_series(
        (SELECT LEAST(MIN("Order Date"), MIN("Ship Date"))
		FROM staging_sales),
        (SELECT GREATEST(MAX("Order Date"), MAX("Ship Date"))
		FROM staging_sales),
        INTERVAL '1 day'
    )::DATE AS d
) AS calendar;

INSERT INTO dim_customer (customer_id, customer_name, segment)
SELECT DISTINCT ON ("Customer ID") "Customer ID", "Customer Name", "Segment"
FROM staging_sales
ORDER BY "Customer ID";

INSERT INTO dim_product (product_id, product_name, category, sub_category)
SELECT DISTINCT "Product ID", "Product Name", "Category", "Sub-Category"
FROM staging_sales;

INSERT INTO dim_location (city, state, postal_code, region, country)
SELECT DISTINCT "City", "State", "Postal Code", "Region", "Country"
FROM staging_sales;

INSERT INTO dim_ship_mode (ship_mode)
SELECT DISTINCT "Ship Mode"
FROM staging_sales;

INSERT INTO fact_sales (
    row_id, order_id, order_date_key, ship_date_key,
    customer_key, product_key, location_key, ship_mode_key,
    sales, quantity, discount, profit
)
SELECT
    s."Row ID",
    s."Order ID",
    CAST(TO_CHAR(s."Order Date", 'YYYYMMDD') AS INT),
    CAST(TO_CHAR(s."Ship Date",  'YYYYMMDD') AS INT),
    dc.customer_key,
    dp.product_key,
    dl.location_key,
    dsm.ship_mode_key,
    s."Sales",
    s."Quantity",
    s."Discount",
    s."Profit"
FROM staging_sales s
JOIN dim_customer  dc  ON dc.customer_id = s."Customer ID"
JOIN dim_product   dp  ON dp.product_id = s."Product ID" AND dp.product_name = s."Product Name"
JOIN dim_location  dl  ON dl.city = s."City" AND dl.state = s."State" AND dl.postal_code = s."Postal Code"
JOIN dim_ship_mode dsm ON dsm.ship_mode = s."Ship Mode";

SELECT 'staging_sales' AS table_name, COUNT(*) AS row_count
FROM staging_sales
UNION ALL SELECT 'fact_sales', COUNT(*)
FROM fact_sales

UNION ALL SELECT 'dim_customer', COUNT(*)
FROM dim_customer

UNION ALL SELECT 'dim_product', COUNT(*)
FROM dim_product

UNION ALL SELECT 'dim_location', COUNT(*)
FROM dim_location

UNION ALL SELECT 'dim_ship_mode', COUNT(*)
FROM dim_ship_mode

UNION ALL SELECT 'dim_date', COUNT(*)
FROM dim_date;