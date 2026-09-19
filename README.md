# SQL Data Warehouse

A complete **SQL Server data warehouse project** built using a modern **Bronze → Silver → Gold** architecture. The project demonstrates how raw CRM and ERP data can be ingested, cleaned, transformed, integrated, and modeled into a business-ready dimensional warehouse for analytics.

## 📌 Project Overview

This project builds a data warehouse from raw CSV files originating from two source systems:

- **CRM** — customer, product, and sales data
- **ERP** — customer demographics, location, and product category data

The data is processed through three layers:

```text
Raw CSV Files
     │
     ▼
┌─────────────┐
│   BRONZE    │  Raw data
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   SILVER    │  Cleaned & standardized data
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    GOLD     │  Business-ready data
└──────┬──────┘
       │
       ▼
 Analytics & Reporting
```

The final Gold layer follows a **Star Schema** consisting of customer and product dimensions connected to a sales fact.

---

## 🏗️ Architecture

### Bronze Layer

The Bronze layer stores raw data loaded from the source CSV files with minimal transformation.

**CRM**

- `crm_cust_info`
- `crm_prd_info`
- `crm_sales_details`

**ERP**

- `erp_cust_az12`
- `erp_loc_a101`
- `erp_px_cat_g1v2`

### Silver Layer

The Silver layer cleans and standardizes the Bronze data.

Key transformations include:

- Removing duplicates
- Handling NULL and missing values
- Trimming unnecessary whitespace
- Standardizing categorical values
- Validating dates
- Converting data types
- Standardizing identifiers
- Preparing data for integration

### Gold Layer

The Gold layer contains business-ready views designed for analytics.

| Object | Type | Purpose |
|---|---|---|
| `dim_customers` | Dimension | Customer attributes |
| `dim_products` | Dimension | Product and category attributes |
| `fact_sales` | Fact | Sales transactions and measures |

---

## ⭐ Gold Layer Star Schema

```text
                    ┌──────────────────┐
                    │  dim_customers   │
                    │──────────────────│
                    │ customer_key     │
                    │ customer_id      │
                    │ customer_number  │
                    │ first_name       │
                    │ last_name        │
                    │ country          │
                    │ gender           │
                    │ marital_status   │
                    └────────┬─────────┘
                             │
                             │
                             ▼
                    ┌──────────────────┐
                    │    fact_sales    │
                    │──────────────────│
                    │ order_number     │
                    │ product_key     │
                    │ customer_key    │
                    │ order_date      │
                    │ shipping_date   │
                    │ due_date        │
                    │ sales_amount    │
                    │ quantity        │
                    │ price           │
                    └────────┬─────────┘
                             ▲
                             │
                             │
                    ┌────────┴─────────┐
                    │  dim_products   │
                    │─────────────────│
                    │ product_key     │
                    │ product_id      │
                    │ product_number  │
                    │ product_name    │
                    │ category        │
                    │ subcategory     │
                    │ maintenance     │
                    │ cost            │
                    │ product_line    │
                    └─────────────────┘
```

---

## 🔄 ETL / Data Flow

### 1. Extract

Raw CRM and ERP CSV files are used as the source data.

### 2. Load — Bronze

Source data is loaded into the Bronze layer with the original structure preserved as much as practical.

### 3. Transform — Silver

SQL transformations are applied to:

- Clean data
- Standardize values
- Resolve data quality issues
- Validate relationships
- Prepare integrated datasets

### 4. Transform & Model — Gold

The cleaned Silver data is transformed into analytical dimensions and facts.

```text
CRM ───────────────┐
                   ├──► Bronze ──► Silver ──► Gold
ERP ───────────────┘                         │
                                             ▼
                                      Star Schema
                                             │
                                             ▼
                                      Analytics
```

---

## 🗃️ Source Data

### CRM

| Dataset | Description |
|---|---|
| `cust_info.csv` | Customer master information |
| `prd_info.csv` | Product master information |
| `sales_details.csv` | Sales transaction information |

### ERP

| Dataset | Description |
|---|---|
| `cust_az12.csv` | Customer demographic information |
| `loc_a101.csv` | Customer location information |
| `px_cat_g1v2.csv` | Product category information |

---

## 📊 Analytical Model

### `dim_customers`

Provides a unified customer view by integrating CRM customer information with ERP demographic and location data.

### `dim_products`

Provides a unified product view by combining CRM product information with ERP category and subcategory information.

### `fact_sales`

Contains sales transactions and measurable business metrics such as:

- Sales amount
- Quantity
- Price
- Order date
- Shipping date
- Due date

---

## 🧹 Data Quality

Data quality checks and transformations are performed primarily in the Silver layer.

Examples include:

- Duplicate detection and removal
- NULL value handling
- Whitespace cleanup
- Gender and marital-status standardization
- Country standardization
- Date validation
- Numeric validation
- Source identifier normalization
- Cross-system data integration

---

## 🛠️ Technologies

- **SQL Server**
- **T-SQL**
- **SQL Server Management Studio (SSMS)**
- **CSV**
- **Git / GitHub**
- **Data Warehousing**
- **Dimensional Modeling**
- **ETL / ELT concepts**

---

## 📚 Documentation

A detailed data catalog is available here:

📖 [`Docs/data_catalog.md`](Docs/data_catalog.md)

The catalog documents:

- Source datasets
- Bronze tables
- Silver tables
- Gold dimensions
- Gold fact
- Column definitions
- Data transformations
- Data lineage
- Warehouse relationships

---

## ⭐ Project Purpose

This project was created as a hands-on implementation of **SQL data warehousing and data engineering concepts**, from raw source data ingestion through transformation and dimensional modeling to analytics-ready data.
