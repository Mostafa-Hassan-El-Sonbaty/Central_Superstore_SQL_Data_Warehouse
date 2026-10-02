DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_location CASCADE;
DROP TABLE IF EXISTS dim_ship_mode CASCADE;
DROP TABLE IF EXISTS staging_sales CASCADE;

CREATE TABLE staging_sales (
    "Row ID"        INT,
    "Order ID"      VARCHAR(20),
    "Order Date"    DATE,
    "Ship Date"     DATE,
    "Ship Mode"     VARCHAR(30),
    "Customer ID"   VARCHAR(20),
    "Customer Name" VARCHAR(100),
    "Segment"       VARCHAR(30),
    "Country"       VARCHAR(50),
    "City"          VARCHAR(50),
    "State"         VARCHAR(50),
    "Postal Code"   INT,
    "Region"        VARCHAR(30),
    "Product ID"    VARCHAR(30),
    "Category"      VARCHAR(30),
    "Sub-Category"  VARCHAR(30),
    "Product Name"  VARCHAR(255),
    "Sales"         NUMERIC(12,4),
    "Quantity"      INT,
    "Discount"      NUMERIC(6,4),
    "Profit"        NUMERIC(12,4)
);

CREATE TABLE dim_date (
    date_key        INT PRIMARY KEY,
    full_date       DATE NOT NULL UNIQUE,
    day_of_month    SMALLINT NOT NULL,
    day_name        VARCHAR(10) NOT NULL,
    month_num       SMALLINT NOT NULL,
    month_name      VARCHAR(10) NOT NULL,
    quarter         SMALLINT NOT NULL,
    year            SMALLINT NOT NULL,
    is_weekend      BOOLEAN NOT NULL
);

CREATE TABLE dim_customer (
    customer_key    SERIAL PRIMARY KEY,
    customer_id     VARCHAR(20) NOT NULL UNIQUE,
    customer_name   VARCHAR(100) NOT NULL,
    segment         VARCHAR(30) NOT NULL
);

CREATE TABLE dim_product (
    product_key     SERIAL PRIMARY KEY,
    product_id      VARCHAR(30) NOT NULL,
    product_name    VARCHAR(255) NOT NULL,
    category        VARCHAR(30) NOT NULL,
    sub_category    VARCHAR(30) NOT NULL,
    CONSTRAINT uq_product UNIQUE (product_id, product_name)
);

CREATE TABLE dim_location (
    location_key    SERIAL PRIMARY KEY,
    city            VARCHAR(50) NOT NULL,
    state           VARCHAR(50) NOT NULL,
    postal_code     INT NOT NULL,
    region          VARCHAR(30) NOT NULL,
    country         VARCHAR(50) NOT NULL,
    CONSTRAINT uq_location UNIQUE (city, state, postal_code)
);

CREATE TABLE dim_ship_mode (
    ship_mode_key   SERIAL PRIMARY KEY,
    ship_mode       VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE fact_sales (
    fact_id             SERIAL PRIMARY KEY,
    row_id              INT NOT NULL,
    order_id            VARCHAR(20) NOT NULL,
    order_date_key      INT NOT NULL REFERENCES dim_date(date_key),
    ship_date_key       INT NOT NULL REFERENCES dim_date(date_key),
    customer_key        INT NOT NULL REFERENCES dim_customer(customer_key),
    product_key         INT NOT NULL REFERENCES dim_product(product_key),
    location_key        INT NOT NULL REFERENCES dim_location(location_key),
    ship_mode_key       INT NOT NULL REFERENCES dim_ship_mode(ship_mode_key),
    sales               NUMERIC(12,4) NOT NULL,
    quantity            INT NOT NULL,
    discount            NUMERIC(6,4) NOT NULL,
    profit              NUMERIC(12,4) NOT NULL
);

CREATE INDEX idx_fact_order_date
ON fact_sales(order_date_key);

CREATE INDEX idx_fact_ship_date
ON fact_sales(ship_date_key);

CREATE INDEX idx_fact_customer
ON fact_sales(customer_key);

CREATE INDEX idx_fact_product
ON fact_sales(product_key);

CREATE INDEX idx_fact_location
ON fact_sales(location_key);

CREATE INDEX idx_fact_ship_mode
ON fact_sales(ship_mode_key);

CREATE INDEX idx_fact_order_id
ON fact_sales(order_id);

CREATE INDEX idx_dim_product_cat
ON dim_product(category, sub_category);

CREATE INDEX idx_dim_location_state
ON dim_location(state);

CREATE INDEX idx_dim_customer_segment
ON dim_customer(segment);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;