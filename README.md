# 🏪 Central Superstore — SQL Data Warehouse & Business Analytics

> A PostgreSQL star-schema data warehouse built end-to-end from a raw retail
> extract — normalized, indexed, and queried for real business insight.

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?logo=postgresql&logoColor=white)]()
[![SQL](https://img.shields.io/badge/SQL-Advanced-orange)]()
[![Status](https://img.shields.io/badge/Status-Complete-success)]()

---

## 📌 Overview

This project transforms a flat, denormalized retail dataset — **2,323 order
line items** from the Central US region (2013–2017) — into a clean,
query-ready **star schema data warehouse**, then builds a full analytics
layer on top of it: trend analysis, customer segmentation, profitability
breakdowns, and operational KPIs.

Built as part of **DEPI's Professional Data Analyst Track — Mini-Project 2**.

---

## 🗂️ Star Schema Design
                     dim_date (order_date_key)
                          │
                          dim_customer ─────── fact_sales ─────── dim_product
                          │ │
                          dim_location dim_ship_mode
                          │
                          dim_date (ship_date_key) ← role-playing dimension

| Table | Type | Rows |
|---|---|---|
| `staging_sales` | Raw landing table | 2,323 |
| `dim_date` | Dimension | ~1,460 |
| `dim_customer` | Dimension | 629 |
| `dim_product` | Dimension | 1,326 |
| `dim_location` | Dimension | 195 |
| `dim_ship_mode` | Dimension | 4 |
| `fact_sales` | Fact | 2,323 |

**7 tables total** — fully normalized, surrogate-keyed, and indexed.

---

## 📁 Project Structure

| File | What it does |
|---|---|
| `01_schema.sql` | Builds staging + dimension + fact tables, with PK/FK constraints and performance indexes |
| `02_load_data.sql` | Bulk-loads the raw CSV into staging via `COPY` |
| `03_etl.sql` | Transforms staging data into the star schema (dimensions + fact) |
| `04_queries.sql` | 18 analytical queries, 2 views, 1 stored procedure, 1 table function, and a query-optimization example |

---

## ✨ What's Inside `04_queries.sql`

- 📊 **18 analytical queries** — profitability, sales trends, customer behavior, shipping performance
- 🔗 **Multi-table JOINs** across every dimension
- 🧩 **CTEs** for monthly/yearly/quarterly trend analysis and ranked top-N lookups
- 🪄 **CASE expressions** for profitability tiers, customer segments, and discount bands
- 🔍 **Subqueries** (correlated & scalar) for above-average and outlier detection
- 📈 **Window functions** — `LAG()`, `ROW_NUMBER()`, running totals
- 👁️ **Views** — `vw_monthly_sales_summary`, `vw_customer_profitability`
- ⚙️ **Stored procedure** — `sp_kpi_report(start_date, end_date)` for on-demand KPI summaries
- 🧮 **Table function** — `sp_top_n_products(category, n)`
- 🚀 **Query optimization** — indexing strategy + `EXPLAIN ANALYZE` walkthrough

---

## 🚀 How to Run

```bash
createdb central_superstore
psql -d central_superstore -f 01_schema.sql
psql -d central_superstore -f 02_load_data.sql    # ⚠️ update the CSV path inside first
psql -d central_superstore -f 03_etl.sql
psql -d central_superstore -f 04_queries.sql
```

Then try the stored routines directly:
```sql
CALL sp_kpi_report('2016-01-01', '2016-12-31');
SELECT * FROM sp_top_n_products('Technology', 5);
```

---

## 🧠 Key Insight Examples

- **Technology** carries the healthiest profit margin (~19–20%)
- **Furniture**, especially the Tables sub-category, slips into net losses once heavy discounting is applied
- A small number of **repeat customers** drive a disproportionate share of total profit
