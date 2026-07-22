-- Step 1: DW - Create star schema tables
.read 01_create_tables.sql

-- Step 2: DW - Load data from CSV files to tables
.read 02_load_schema_data.sql

-- Step 3: DW - 