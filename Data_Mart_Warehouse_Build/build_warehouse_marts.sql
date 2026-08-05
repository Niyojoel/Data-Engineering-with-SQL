-- .read build_marts.sql

-- Step 1: DW - Create star schema tables
.read 01_create_tables.sql

-- Step 2: DW - Load data from CSV files to tables and validate
.read 02_load_schema/script.sql

-- Step 3: Mart - Create Flat Mart 
.read 03_create_flat_mart.sql

-- Step 4: Mart - Create Skills Mart
.read 04_create_skills_mart.sql

-- Step 5: Mart - Create Priority Roles Mart
.read 05_create_priority_mart.sql

-- Step 6: Batch Processing - Update Priority Roles Mart
.read 06_update_priority_mart.sql

-- Step 7: Mart - Create Company Mart 
.read 07_create_company_mart.sql