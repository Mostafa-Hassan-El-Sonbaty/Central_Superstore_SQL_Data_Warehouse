# 🏪 Central Superstore - SQL Data Warehouse & Business Analytics

> An end-to-end PostgreSQL data warehouse project that transforms raw retail data into a structured **star-schema analytical model**, enabling business reporting, customer analysis, profitability analysis, and performance optimization.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql\&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-orange)
![Data Warehouse](https://img.shields.io/badge/Data%20Warehouse-Star%20Schema-blue)
![Status](https://img.shields.io/badge/Status-Complete-success)

---

## 📌 Project Overview

**Central Superstore** is an end-to-end SQL Data Warehouse and Business Analytics project built using **PostgreSQL**.

The project starts with a raw, denormalized retail dataset containing **2,323 order line items** from the Central US region covering **2013–2017**.

The raw data is transformed through staging and ETL into a structured **star schema** with a central sales fact table and five supporting dimensions.

On top of the warehouse, an analytical SQL layer provides business insights into:

* Sales performance and trends
* Profitability
* Customer behavior and segmentation
* Product performance
* Discount impact
* Shipping performance
* Year-over-year growth
* Top-performing products
* Operational KPIs

---

## 🏗️ Data Warehouse Architecture

The warehouse follows a **star schema** design.

```text
                         ┌───────────────┐
                         │   dim_date    │
                         └───────┬───────┘
                                 │
                                 │
┌────────────────┐       ┌───────▼────────┐       ┌─────────────────┐
│ dim_customer   │──────▶│                │◀──────│  dim_product    │
└────────────────┘       │   fact_sales   │       └─────────────────┘
                         │                │
┌────────────────┐       └───────┬────────┘       ┌─────────────────┐
│ dim_location   │───────────────┤                │ dim_ship_mode   │
└────────────────┘               │                └─────────────────┘
                                 │
                                 ▼
                         Sales Transactions
```

### Grain

The grain of `fact_sales` is:

> **One row per order line item.**

This allows transactional metrics such as Sales, Quantity, Discount, and Profit to be analyzed across different business dimensions.

---

## 🗂️ Database Schema

| Table           | Type      |   Rows | Description                                                           |
| --------------- | --------- | -----: | --------------------------------------------------------------------- |
| `staging_sales` | Staging   |  2,323 | Raw denormalized CSV data                                             |
| `dim_date`      | Dimension | ~1,460 | Calendar attributes used for order and ship dates                     |
| `dim_customer`  | Dimension |    629 | Customer details and segmentation attributes                          |
| `dim_product`   | Dimension |  1,326 | Product hierarchy including category and sub-category                 |
| `dim_location`  | Dimension |    195 | Geographic information including city, state, region, and postal code |
| `dim_ship_mode` | Dimension |      4 | Shipping method definitions                                           |
| `fact_sales`    | Fact      |  2,323 | Sales transactions and measurable business metrics                    |

**Total: 7 tables**

The analytical model uses **surrogate keys, primary/foreign key constraints, and indexes** to support reliable relationships and efficient querying.

---

## 🔄 ETL Pipeline

The project follows a simple warehouse pipeline:

```text
Raw CSV
   │
   ▼
Staging Table
   │
   │  Data Cleaning
   │  Deduplication
   │  Transformation
   │  Key Generation
   ▼
Dimension Tables
   │
   ▼
Fact Table
   │
   ▼
Analytical Queries
   │
   ├── Views
   ├── KPI Reports
   ├── Table Functions
   └── Performance Analysis
```

### ETL Process

1. Load the raw CSV into `staging_sales`.
2. Clean and standardize the source data.
3. Extract unique business entities into dimension tables.
4. Generate surrogate keys for dimensions.
5. Resolve dimension keys for each transaction.
6. Load transactional metrics into `fact_sales`.
7. Apply indexes and constraints.
8. Build the analytical SQL layer.

---

## 📁 Project Structure

```text
Central-Superstore/
│
├── 01_schema.sql
├── 02_load_data.sql
├── 03_etl.sql
├── 04_queries.sql
│
├── data/
│   └── superstore.csv
│
└── README.md
```

### SQL Scripts

| File                   | Purpose                                                                                |
| ---------------------- | -------------------------------------------------------------------------------------- |
| `1- Setting up.sql`    | Creates staging, dimension, and fact tables with PK/FK constraints and indexes         |
| `2- Loading Data.sql`  | Loads the raw CSV data into the staging table using PostgreSQL `COPY`                  |
| `3- ETL.sql`           | Transforms staging data and populates the dimensional model                            |
| `4- Queries.sql`       | Contains analytical queries, views, routines, functions, and optimization examples     |

---

# 📊 Analytics & SQL Techniques

The analytical layer demonstrates advanced SQL techniques used in real-world data analysis and data warehousing.

### 📈 Business Analysis

**18 analytical queries** covering:

* Sales and profit analysis
* Year-over-year sales trends
* Monthly performance
* Customer behavior
* Product performance
* Profitability analysis
* Discount impact
* Shipping fulfillment time
* Outlier detection
* Top-N analysis

### 🔗 Multi-Table JOINs

Queries combine the central fact table with multiple dimensions to answer business questions across:

* Customers
* Products
* Locations
* Dates
* Shipping methods

### 🧩 Common Table Expressions

CTEs are used to break complex analytical logic into readable stages, including:

* Monthly and yearly trend analysis
* Ranked results
* Top-N analysis
* Intermediate calculations

### CASE Expressions

`CASE` logic is used to create analytical classifications such as:

* Profitability tiers
* Customer segments
* Discount bands

### 🔍 Subqueries

Both scalar and correlated subqueries are used for analysis such as:

* Above-average sales
* Outlier identification
* Comparative analysis

### 📊 Window Functions

The project demonstrates:

* `LAG()` for period-over-period comparisons
* `ROW_NUMBER()` for ranking
* Running totals
* Partitioned analytical calculations

---

# 👁️ SQL Views

The project includes reusable analytical views that simplify reporting.

### `vw_monthly_sales_summary`

Provides monthly sales performance for easier trend analysis and reporting.

### `vw_customer_profitability`

Provides customer-level profitability metrics for identifying valuable and potentially unprofitable customer segments.

---

# ⚙️ Stored Procedure

### `sp_kpi_report(start_date, end_date)`

Generates a KPI summary for a user-defined date range.

Example:

```sql
CALL sp_kpi_report(
    '2016-01-01',
    '2016-12-31'
);
```

This lets you run KPI reports without rewriting the underlying analytical query.

---

# 🧮 Table Function

### `fn_top_n_products(category, n)`

Returns the top-performing products for a selected category.

Example:

```sql
SELECT *
FROM fn_top_n_products('Technology', 5);
```

> The function name uses the `fn_` prefix to distinguish it from the stored procedure.

---

# 🚀 Query Optimization

The project also demonstrates basic SQL performance analysis using:

```sql
EXPLAIN ANALYZE
```

Indexes are created on important keys and frequently queried attributes to improve query performance.

The optimization example compares query execution behavior before and after indexing.

---

# 💡 Key Business Insights

The analysis produced several notable findings from the dataset:

### 🖥️ Technology Profitability

Technology demonstrates the strongest overall profit margin, approximately **19–20%** in the analyzed data.

### 🪑 Furniture & Discounting

Furniture, particularly the **Tables** sub-category, shows profitability pressure when higher discounts are applied, with some transactions resulting in net losses.

### 👥 Customer Profit Concentration

A relatively small group of repeat customers contributes a disproportionate share of total profit, highlighting the importance of customer-level profitability analysis.

> These insights are derived from the project's analytical queries and should be interpreted within the scope of the dataset.

---

# 🛠️ Tech Stack

| Technology            | Usage                             |
| --------------------- | --------------------------------- |
| **PostgreSQL 16**     | Database & analytical engine      |
| **SQL**               | Data transformation and analytics |
| **Star Schema**       | Data warehouse architecture       |
| **CTEs**              | Complex query organization        |
| **Window Functions**  | Advanced analytics                |
| **Views**             | Reusable reporting layers         |
| **Stored Procedures** | Parameterized KPI reporting       |
| **Table Functions**   | Reusable Top-N analysis           |
| **EXPLAIN ANALYZE**   | Query performance analysis        |

---

# 🚀 Quick Start

## 1. Create the Database

```bash
createdb central_superstore
```

Or from PostgreSQL:

```sql
CREATE DATABASE central_superstore;
```

---

## 2. Run the SQL Scripts

Execute the scripts in the following order:

```bash
psql -d central_superstore -f 01_schema.sql
psql -d central_superstore -f 02_load_data.sql
psql -d central_superstore -f 03_etl.sql
psql -d central_superstore -f 04_queries.sql
```

> Before running `02_load_data.sql`, update the CSV file path used by the PostgreSQL `COPY` command.

---

## 3. Test the Analytical Layer

Generate a KPI report:

```sql
CALL sp_kpi_report(
    '2016-01-01',
    '2016-12-31'
);
```

Get the top 5 products in Technology:

```sql
SELECT *
FROM fn_top_n_products(
    'Technology',
    5
);
```

---

# 📌 What This Project Demonstrates

This project demonstrates practical experience with:

* Designing a relational data warehouse
* Building a star-schema dimensional model
* Working with staging tables
* ETL and data transformation
* Primary and foreign key relationships
* Surrogate keys
* SQL data cleaning
* Advanced analytical SQL
* Customer and product analysis
* KPI reporting
* Reusable SQL views and functions
* Query optimization
* Performance profiling

---

# 🎯 Business Use Case

A retail business could use this warehouse to answer questions such as:

* How are sales and profit changing over time?
* Which product categories generate the most profit?
* Which customers contribute the most profit?
* How does discounting affect profitability?
* Which products are underperforming?
* Which regions generate the highest revenue?
* How long does each shipping method take?
* Which products should be prioritized within each category?
* How does current performance compare with previous periods?

---

# 📜 Project Status

**Status:** ✅ Complete

The project currently includes:

* ✅ PostgreSQL data warehouse
* ✅ Star schema
* ✅ Staging layer
* ✅ ETL pipeline
* ✅ 18 analytical queries
* ✅ Analytical views
* ✅ Stored procedure
* ✅ Table function
* ✅ Query optimization example
* ✅ Business insights
**Mostafa Hassan**

BIS Student | Data Analytics & Business Intelligence

Focused on **SQL, Data Analytics, Business Intelligence, and Data Warehousing**.
