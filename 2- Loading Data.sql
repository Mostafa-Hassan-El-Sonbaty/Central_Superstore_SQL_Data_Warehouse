COPY staging_sales
FROM 'F:\DEPI\Mini Projects\Mini Project 2/Central_Superstore.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

SELECT COUNT(*) AS staging_row_count
FROM staging_sales;