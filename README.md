# 🏪 Central Superstore - SQL Data Warehouse & Business Analytics

> A PostgreSQL star-schema data warehouse built end-to-end from a raw retail extract, normalized, indexed, and queried for real business insights.

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?logo=postgresql&logoColor=white)]()
[![SQL](https://img.shields.io/badge/SQL-Advanced-orange)]()
[![Status](https://img.shields.io/badge/Status-Complete-success)]()

---

## 📌 Overview

This project transforms a flat, denormalized retail dataset **2,323 order line items** from the Central US region (2013–2017) into a clean, query-ready **star schema data warehouse**. A full analytics layer is built on top to analyze sales trends, customer segmentation, profitability breakdowns, and operational KPIs.

---

## 🗂️ Star Schema Design

The database relies on a centralized fact table connected to 5 dimensional tables and a staging table for raw data processing. 





| Table | Type | Rows | Description |
|---|---|---|---|
| `staging_sales` | Raw landing table | 2,323 | Unprocessed denormalized CSV data |
| `dim_date` | Dimension | ~1,460 | Calendar breakdown supporting role-playing (Order/Ship dates) |
| `dim_customer` | Dimension | 629 | Customer details and segmentation |
| `dim_product` | Dimension | 1,326 | Product hierarchies (Category/Sub-category) |
| `dim_location` | Dimension | 195 | Geographic data (City/State/Region/Postal) |
| `dim_ship_mode` | Dimension | 4 | Shipping method definitions |
| `fact_sales` | Fact | 2,323 | Transactional metrics (Sales, Quantity, Discount, Profit) |

**7 tables total** fully normalized, surrogate-keyed, and indexed.

---

## 📁 Project Structure

| File | What it does |
|---|---|
| `1- Setting up.sql` | Builds staging + dimension + fact tables, with PK/FK constraints and performance indexes |
| `2- Loading Data.sql` | Bulk-loads the raw CSV into staging via `COPY` |
| `3- ETL.sql` | Transforms staging data into the star schema (dimensions + fact) |
| `4- Queries.sql` | 18 analytical queries, 2 views, 1 stored procedure, 1 table function, and a query-optimization example |

---

✨ Analytics & SQL Techniques
The 04_queries.sql file demonstrates advanced SQL data analysis, featuring:

📊 18 Analytical Queries: Covering profitability metrics, Yo-Y sales trends, customer behavior, and shipping fulfillment times.

🔗 Multi-table JOINs: Across all dimensions and the central fact table.

🧩 CTEs: Utilized for staged trend analysis (monthly/yearly) and ranked top-N lookups.

🪄 CASE Expressions: Generating profitability tiers, customer segments, and discount bands.

🔍 Subqueries: Both correlated and scalar for outlier detection (e.g., above-average sales).

📈 Window Functions: Implementation of LAG(), ROW_NUMBER(), and running totals.

👁️ Views: Abstractions like vw_monthly_sales_summary and vw_customer_profitability.

⚙️ Stored Procedure: sp_kpi_report(start_date, end_date) for dynamically generating KPI summaries.

🧮 Table Function: sp_top_n_products(category, n) to return customized top-performing products.

🚀 Query Optimization: Strategic indexing and performance profiling using EXPLAIN ANALYZE.

🚀 Quick Start Guide

1- Clone the repository and initialize the database:
createdb central_superstore

2- Execute the scripts in sequence (ensure you update the CSV path inside 02_load_data.sql before running it):
psql -d central_superstore -f 01_schema.sql
psql -d central_superstore -f 02_load_data.sql
psql -d central_superstore -f 03_etl.sql
psql -d central_superstore -f 04_queries.sql

3- Test the built-in routines directly in your SQL client:
-- Generate a KPI report for 2016
CALL sp_kpi_report('2016-01-01', '2016-12-31');

-- Get the top 5 most profitable tech products
SELECT * FROM sp_top_n_products('Technology', 5);

## 🧠 Key Insight Examples

- **Technology** carries the healthiest profit margin (~19–20%)
- **Furniture**, especially the Tables sub-category, slips into net losses once heavy discounting is applied
- A small number of **repeat customers** drive a disproportionate share of total profit
