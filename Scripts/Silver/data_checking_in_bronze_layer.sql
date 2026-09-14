-- Quality check in bronze layer

-- =================================
-- [bronze].[crm_cust_info]
-- =================================
-- check for Nulls or duplicates in primary key
-- expectation: no result
SELECT
	cst_id,
	COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- check for unwanted spaces
-- expectation: no result
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- data standardization and consistency
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info

-- =================================
-- [bronze].[crm_prd_info]
-- =================================
SELECT * FROM [bronze].[crm_prd_info]

-- check for Nulls or duplicates in primary key
-- expectation: no result
SELECT
	prd_id,
	COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- check for unwanted spaces
-- expectation: no result
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- check for null or negative numbers
-- expectation: no results
SELECT [prd_cost]
FROM bronze.crm_prd_info
WHERE [prd_cost] IS NULL OR [prd_cost] < 0

-- data standardization and consistency
SELECT DISTINCT [prd_line]
FROM bronze.crm_prd_info

-- check for invalid date orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- =================================
-- [bronze].[crm_sales_details]
-- =================================

-- check invalid dates
SELECT NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt < 19000101 OR sls_due_dt > 20500101
OR sls_due_dt <= 0 OR LEN(sls_due_dt) != 8

-- check invalid date orders
SELECT *
FROm bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt
OR sls_ship_dt > sls_due_dt

-- check data consistency
-- sales = quantity * price
-- values must not be zero, negative or null
SELECT DISTINCT sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR
sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL OR
sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- =================================
-- [bronze].[erp_cust_az12]
-- =================================
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END AS cid,
bdate,
gen
FROM [bronze].[erp_cust_az12]

-- check date invalid
SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- data consistency
SELECT DISTINCT 
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

-- =================================
-- [bronze].[erp_loc_a101]
-- =================================
SELECT 
REPLACE(cid, '-', '') cid,
cntry
FROM [bronze].[erp_loc_a101]
WHERE REPLACE(cid, '-', '') NOT IN(
SELECT cst_key FROM silver.crm_cust_info);

-- data standardization and consistency
SELECT DISTINCT cntry AS old,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS new
FROM bronze.erp_loc_a101
ORDER BY cntry;

SELECT 
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
FROM [bronze].[erp_loc_a101]

-- =================================
-- [bronze].[erp_px_cat_g1v2]
-- =================================
SELECT 
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT 
DISTINCT id
FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (
SELECT DISTINCT cat_id FROM silver.crm_prd_info)

-- check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- data standardization and consistency
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2
ORDER BY cat;

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2
ORDER BY subcat;

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2
ORDER BY maintenance;