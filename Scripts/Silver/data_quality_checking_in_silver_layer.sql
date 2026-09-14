-- Quality check in silver layer

-- =======================
-- silver.crm_cust_info
-- =======================

-- check for Nulls or duplicates in primary key
-- expectation: no result

SELECT
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- check for unwanted spaces
-- expectation: no result
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- data standardization and consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECt * FROM silver.crm_cust_info;

-- =======================
-- silver.crm_cust_info
-- =======================

SELECT * FROM silver.crm_prd_info

-- check for Nulls or duplicates in primary key
-- expectation: no result
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- check for unwanted spaces
-- expectation: no result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- check for null or negative numbers
-- expectation: no results
SELECT [prd_cost]
FROM silver.crm_prd_info
WHERE [prd_cost] IS NULL OR [prd_cost] < 0

-- data standardization and consistency
SELECT DISTINCT [prd_line]
FROM silver.crm_prd_info

-- check for invalid date orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- =================================
-- [silver].[crm_sales_details]
-- =================================

-- check invalid dates
SELECT NULLIF(sls_due_dt, 0) sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0 OR LEN(sls_due_dt) != 8

-- check invalid date orders
SELECT *
FROm silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt
OR sls_ship_dt > sls_due_dt

-- check data consistency
-- sales = quantity * price
-- values must not be zero, negative or null
SELECT DISTINCT sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR
sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL OR
sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- =================================
-- [silver].[erp_cust_az12]
-- =================================
SELECT
cid,
bdate,
gen
FROM [silver].[erp_cust_az12] WHERE cid LIKE 'NAS%'

-- check date invalid
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- data consistency
SELECT DISTINCT 
gen
FROM silver.erp_cust_az12

-- =================================
-- silver.[erp_loc_a101]
-- =================================
SELECT 
cid,
cntry
FROM silver.[erp_loc_a101]

-- data standardization and consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

SELECT * FROM silver.erp_loc_a101

-- =================================
-- silver.[erp_px_cat_g1v2]
-- =================================
SELECT 
id,
cat,
subcat,
maintenance
FROM silver.erp_px_cat_g1v2;

SELECT 
DISTINCT id
FROM silver.erp_px_cat_g1v2
WHERE id NOT IN (
SELECT DISTINCT cat_id FROM silver.crm_prd_info)

-- check for unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- data standardization and consistency
SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2
ORDER BY cat;

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2
ORDER BY subcat;

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2
ORDER BY maintenance;