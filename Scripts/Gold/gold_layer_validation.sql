SELECT cst_id, COUNT(*) FROM(
SELECT
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	cc.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 cc
ON ci.cst_key = cc.cid
)t GROUP BY cst_id HAVING COUNT(*) > 1

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' OR ci.cst_gndr IS NOT NULL THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen, 'n/a')
	END gender
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
ORDER BY 1, 2

SELECT * FROM gold.dim_customers;

SELECT DISTINCT gender FROM gold.dim_customers;

SELECT * FROM gold.dim_products;

SELECT * FROM gold.fact_sales;

SELECT * 
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE p.product_key IS NULL;

SELECT * 
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
WHERE s.customer_key IS NULL;