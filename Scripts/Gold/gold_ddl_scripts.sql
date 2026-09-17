-- gold layer ddl scripts

-- Dimensional tables

-- customer table
CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	cc.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' OR ci.cst_gndr IS NOT NULL THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 cc
ON ci.cst_key = cc.cid;

-- products tables
CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,
	pi.prd_id AS product_id,
	pi.prd_key AS product_number,
	pi.prd_nm AS product_name,
	pi.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance AS maintenance,
	pi.prd_cost AS product_cost,
	pi.prd_line AS product_line,
	pi.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pi
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL; -- filter out all the historical data

-- fact tables

-- sales table
CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS order_number,
	pi.product_key AS product_key,
	ci.customer_key AS customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pi
ON sd.sls_prd_key = pi.product_number
LEFT JOIN gold.dim_customers ci
ON sd.sls_cust_id = ci.customer_id;


