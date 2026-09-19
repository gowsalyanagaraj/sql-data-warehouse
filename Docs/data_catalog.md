# Data Catalog

## SQL Data Warehouse

This document provides a data catalog for the SQL Server data warehouse, covering the source datasets and the Bronze, Silver, and Gold layers.

The warehouse follows a **Bronze → Silver → Gold** architecture:

- **Bronze:** Raw source data loaded with minimal/no transformation.
- **Silver:** Cleaned, standardized, validated, and enriched data.
- **Gold:** Business-ready dimensional model designed for analytics using a star schema.

---

## 1. Source Data

The warehouse integrates data from two source systems:

- **CRM** – Customer, product, and sales transaction data.
- **ERP** – Customer demographic, location, and product category data.

### 1.1 CRM Source Files

| File | Description |
|---|---|
| `cust_info.csv` | Customer master information |
| `prd_info.csv` | Product master information and product history |
| `sales_details.csv` | Sales transaction information |

### 1.2 ERP Source Files

| File | Description |
|---|---|
| `cust_az12.csv` | Customer demographic information |
| `loc_a101.csv` | Customer country/location information |
| `px_cat_g1v2.csv` | Product category and subcategory information |

---

# 2. Bronze Layer

The Bronze layer stores source data in SQL Server with the source structure preserved as closely as possible.

## 2.1 `bronze.crm_cust_info`

**Source:** `cust_info.csv`  
**Purpose:** Stores raw CRM customer master data.

| Column | Data Type | Description |
|---|---|---|
| `cst_id` | INT | Unique customer identifier from the CRM system |
| `cst_key` | NVARCHAR | Customer business key |
| `cst_firstname` | NVARCHAR | Customer first name |
| `cst_lastname` | NVARCHAR | Customer last name |
| `cst_marital_status` | NVARCHAR | Customer marital status |
| `cst_gndr` | NVARCHAR | Customer gender |
| `cst_create_date` | DATE | Date the customer record was created |

---

## 2.2 `bronze.crm_prd_info`

**Source:** `prd_info.csv`  
**Purpose:** Stores raw CRM product master data.

| Column | Data Type | Description |
|---|---|---|
| `prd_id` | INT | Unique product identifier |
| `prd_key` | NVARCHAR | Product business key |
| `prd_nm` | NVARCHAR | Product name |
| `prd_cost` | INT | Product cost |
| `prd_line` | NVARCHAR | Product line/category code |
| `prd_start_dt` | DATE | Product validity start date |
| `prd_end_dt` | DATE | Product validity end date |

---

## 2.3 `bronze.crm_sales_details`

**Source:** `sales_details.csv`  
**Purpose:** Stores raw CRM sales transactions.

| Column | Data Type | Description |
|---|---|---|
| `sls_ord_num` | NVARCHAR | Sales order number |
| `sls_prd_key` | NVARCHAR | Product business key associated with the sale |
| `sls_cust_id` | INT | Customer identifier associated with the sale |
| `sls_order_dt` | DATE/INT | Order date |
| `sls_ship_dt` | DATE/INT | Shipping date |
| `sls_due_dt` | DATE/INT | Due date |
| `sls_sales` | DECIMAL | Sales amount |
| `sls_quantity` | INT | Quantity sold |
| `sls_price` | DECIMAL | Selling price per unit |

---

## 2.4 `bronze.erp_cust_az12`

**Source:** `cust_az12.csv`  
**Purpose:** Stores raw ERP customer demographic data.

| Column | Data Type | Description |
|---|---|---|
| `cid` | NVARCHAR | Customer identifier from the ERP system |
| `bdate` | DATE | Customer birth date |
| `gen` | NVARCHAR | Customer gender |

---

## 2.5 `bronze.erp_loc_a101`

**Source:** `loc_a101.csv`  
**Purpose:** Stores raw ERP customer location information.

| Column | Data Type | Description |
|---|---|---|
| `cid` | NVARCHAR | Customer identifier |
| `cntry` | NVARCHAR | Customer country |

---

## 2.6 `bronze.erp_px_cat_g1v2`

**Source:** `px_cat_g1v2.csv`  
**Purpose:** Stores raw ERP product category information.

| Column | Data Type | Description |
|---|---|---|
| `id` | NVARCHAR | Product/category identifier |
| `cat` | NVARCHAR | Product category |
| `subcat` | NVARCHAR | Product subcategory |
| `maintenance` | NVARCHAR | Product maintenance classification |

---

# 3. Silver Layer

The Silver layer contains cleansed and standardized data. Typical processing includes duplicate removal, trimming spaces, standardizing categorical values, handling invalid/missing values, converting data types, and deriving additional attributes.

All Silver tables also contain:

- `dw_create_date` – Warehouse record creation timestamp used for technical/audit purposes.

## 3.1 `silver.crm_cust_info`

**Purpose:** Cleaned and standardized CRM customer data.

| Column | Description |
|---|---|
| `cst_id` | Customer identifier |
| `cst_key` | Customer business key |
| `cst_firstname` | Standardized first name |
| `cst_lastname` | Standardized last name |
| `cst_marital_status` | Standardized marital status |
| `cst_gndr` | Standardized gender |
| `cst_create_date` | Customer creation date |
| `dw_create_date` | Warehouse record creation timestamp |

### Data Quality / Transformation Rules

- Removes duplicate customer records.
- Trims unnecessary whitespace.
- Standardizes marital status values.
- Standardizes gender values.
- Retains the most relevant/latest customer record where duplicates exist.

---

## 3.2 `silver.crm_prd_info`

**Purpose:** Cleaned and standardized CRM product information.

| Column | Description |
|---|---|
| `prd_id` | Product identifier |
| `prd_key` | Product business key |
| `prd_nm` | Product name |
| `prd_cost` | Product cost |
| `prd_line` | Standardized product line |
| `prd_start_dt` | Product validity start date |
| `prd_end_dt` | Product validity end date |
| `dw_create_date` | Warehouse record creation timestamp |

### Data Quality / Transformation Rules

- Trims product attributes.
- Handles missing product costs.
- Standardizes product line values.
- Converts date fields to appropriate date types.
- Derives product validity periods where required.

---

## 3.3 `silver.crm_sales_details`

**Purpose:** Cleaned CRM sales transaction data.

| Column | Description |
|---|---|
| `sls_ord_num` | Sales order number |
| `sls_prd_key` | Product business key |
| `sls_cust_id` | Customer identifier |
| `sls_order_dt` | Order date |
| `sls_ship_dt` | Shipping date |
| `sls_due_dt` | Due date |
| `sls_sales` | Sales amount |
| `sls_quantity` | Quantity sold |
| `sls_price` | Selling price |
| `dw_create_date` | Warehouse record creation timestamp |

### Data Quality / Transformation Rules

- Converts integer/date representations into valid dates.
- Handles invalid or missing dates.
- Validates sales, quantity, and price values.
- Corrects inconsistent sales calculations where required.
- Uses the sales transaction as the central transactional dataset.

---

## 3.4 `silver.erp_cust_az12`

**Purpose:** Cleaned ERP customer demographic data.

| Column | Description |
|---|---|
| `cid` | Customer identifier |
| `bdate` | Customer birth date |
| `gen` | Standardized gender |
| `dw_create_date` | Warehouse record creation timestamp |

### Data Quality / Transformation Rules

- Standardizes ERP customer identifiers.
- Removes invalid/future birth dates.
- Standardizes gender values.
- Handles missing demographic information.

---

## 3.5 `silver.erp_loc_a101`

**Purpose:** Cleaned ERP customer location data.

| Column | Description |
|---|---|
| `cid` | Customer identifier |
| `cntry` | Standardized country |
| `dw_create_date` | Warehouse record creation timestamp |

### Data Quality / Transformation Rules

- Standardizes customer identifiers.
- Trims country values.
- Standardizes country naming/abbreviations.
- Handles missing country values.

---

## 3.6 `silver.erp_px_cat_g1v2`

**Purpose:** Cleaned ERP product category data.

| Column | Description |
|---|---|
| `id` | Product/category identifier |
| `cat` | Product category |
| `subcat` | Product subcategory |
| `maintenance` | Maintenance classification |
| `dw_create_date` | Warehouse record creation timestamp |

### Data Quality / Transformation Rules

- Trims category attributes.
- Standardizes category and subcategory values.
- Handles missing or inconsistent category information.

---

# 4. Gold Layer

The Gold layer provides business-ready views designed for reporting and analytics.

The model follows a **Star Schema**:

```text
                 ┌─────────────────┐
                 │  dim_customers  │
                 └────────┬────────┘
                          │
                          │
┌─────────────────┐       │       ┌─────────────────┐
│  dim_products   │───────┼───────│   fact_sales    │
└─────────────────┘       │       └─────────────────┘
                          │
                          │
                    Sales Analytics
```

---

## 4.1 `gold.dim_customers`

**Type:** Dimension View  
**Purpose:** Provides a unified customer dimension by combining CRM customer information with ERP demographic and location data.

| Column | Description |
|---|---|
| `customer_key` | Surrogate key used by the warehouse |
| `customer_id` | Original CRM customer identifier |
| `customer_number` | Customer business key |
| `first_name` | Customer first name |
| `last_name` | Customer last name |
| `country` | Customer country |
| `marital_status` | Customer marital status |
| `gender` | Standardized customer gender |
| `create_date` | Customer record creation date |

### Source Tables

- `silver.crm_cust_info`
- `silver.erp_cust_az12`
- `silver.erp_loc_a101`

### Key Characteristics

- Uses a warehouse surrogate key.
- Integrates customer information from CRM and ERP.
- Provides a single customer entity for analytical queries.

---

## 4.2 `gold.dim_products`

**Type:** Dimension View  
**Purpose:** Provides a unified product dimension combining CRM product information with ERP category information.

| Column | Description |
|---|---|
| `product_key` | Surrogate key used by the warehouse |
| `product_id` | Original product identifier |
| `product_number` | Product business key |
| `product_name` | Product name |
| `category_id` | Product category identifier |
| `category` | Product category |
| `subcategory` | Product subcategory |
| `maintenance` | Product maintenance classification |
| `cost` | Product cost |
| `product_line` | Product line |
| `start_date` | Product validity start date |

### Source Tables

- `silver.crm_prd_info`
- `silver.erp_px_cat_g1v2`

### Key Characteristics

- Uses a warehouse surrogate key.
- Integrates CRM product attributes with ERP category information.
- Represents the analytical product master.

---

## 4.3 `gold.fact_sales`

**Type:** Fact View  
**Grain:** One row per sales transaction/order-product combination.

**Purpose:** Stores measurable sales transactions and links them to customer and product dimensions.

| Column | Description |
|---|---|
| `order_number` | Sales order number |
| `product_key` | Foreign key to `gold.dim_products` |
| `customer_key` | Foreign key to `gold.dim_customers` |
| `order_date` | Date the order was placed |
| `shipping_date` | Date the order was shipped |
| `due_date` | Expected/due date |
| `sales_amount` | Total sales amount |
| `quantity` | Quantity sold |
| `price` | Selling price |

### Source Table

- `silver.crm_sales_details`

### Dimension Relationships

| Foreign Key | References |
|---|---|
| `product_key` | `gold.dim_products.product_key` |
| `customer_key` | `gold.dim_customers.customer_key` |

---

# 5. Gold Layer Business Model

The Gold layer supports three major analytical areas:

### Customer Analytics

Uses `gold.dim_customers` and `gold.fact_sales` to analyze:

- Customer purchasing activity
- Sales by customer
- Customer demographics
- Customer country
- Customer order history

### Product Analytics

Uses `gold.dim_products` and `gold.fact_sales` to analyze:

- Product performance
- Product sales
- Quantity sold
- Product categories
- Product subcategories
- Product cost and pricing

### Sales Analytics

Uses `gold.fact_sales` to analyze:

- Sales revenue
- Order volume
- Quantity sold
- Sales trends
- Shipping and fulfillment dates
- Customer/product performance

---

# 6. Data Lineage

```text
CRM CSV Files
│
├── cust_info.csv ────────────────┐
├── prd_info.csv ────────────────┐│
└── sales_details.csv ─────────┐ ││
                               │ ││
ERP CSV Files                  │ ││
│                              │ ││
├── cust_az12.csv ─────────────┤ ││
├── loc_a101.csv ──────────────┤ ││
└── px_cat_g1v2.csv ───────────┤ ││
                               ↓ ↓↓
                         ┌─────────────┐
                         │   BRONZE    │
                         │ Raw Tables  │
                         └──────┬──────┘
                                │
                                ↓
                         ┌─────────────┐
                         │   SILVER    │
                         │ Cleaned &   │
                         │ Standardized│
                         └──────┬──────┘
                                │
                                ↓
                         ┌─────────────┐
                         │    GOLD     │
                         │ Star Schema │
                         └──────┬──────┘
                                │
                    ┌───────────┼───────────┐
                    ↓           ↓           ↓
             Customer      Product       Sales
             Analytics     Analytics    Analytics
```

---

# 7. Data Classification

| Layer | Data Type | Primary Users | Purpose |
|---|---|---|---|
| Bronze | Raw / source-aligned | Data Engineers | Data ingestion and traceability |
| Silver | Cleaned / standardized | Data Engineers, Analysts | Data preparation and integration |
| Gold | Business-ready | Analysts, BI users | Reporting and analytics |

---

# 8. Key Data Warehouse Concepts

### Surrogate Keys

The Gold dimension tables use warehouse-generated surrogate keys rather than relying directly on source-system identifiers.

### Fact and Dimension Model

- **Dimensions:** `dim_customers`, `dim_products`
- **Fact:** `fact_sales`

### Data Quality

Data quality is addressed primarily in the Silver layer through:

- Duplicate detection/removal
- Null and missing-value handling
- Whitespace cleanup
- Standardization of categorical values
- Date validation
- Numeric validation
- Cross-source integration

### Data Lineage

The warehouse maintains a clear flow from:

**Source CSV → Bronze → Silver → Gold → Analytics**

---

# 9. Summary

| Object | Layer | Type | Purpose |
|---|---|---|---|
| `crm_cust_info` | Bronze | Table | Raw CRM customer data |
| `crm_prd_info` | Bronze | Table | Raw CRM product data |
| `crm_sales_details` | Bronze | Table | Raw CRM sales data |
| `erp_cust_az12` | Bronze | Table | Raw ERP customer demographics |
| `erp_loc_a101` | Bronze | Table | Raw ERP customer location |
| `erp_px_cat_g1v2` | Bronze | Table | Raw ERP product categories |
| `crm_cust_info` | Silver | Table | Cleaned CRM customer data |
| `crm_prd_info` | Silver | Table | Cleaned CRM product data |
| `crm_sales_details` | Silver | Table | Cleaned CRM sales data |
| `erp_cust_az12` | Silver | Table | Cleaned ERP customer demographics |
| `erp_loc_a101` | Silver | Table | Cleaned ERP location data |
| `erp_px_cat_g1v2` | Silver | Table | Cleaned ERP category data |
| `dim_customers` | Gold | View | Business-ready customer dimension |
| `dim_products` | Gold | View | Business-ready product dimension |
| `fact_sales` | Gold | View | Business-ready sales fact |

---