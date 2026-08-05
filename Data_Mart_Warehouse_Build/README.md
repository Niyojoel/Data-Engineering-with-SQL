# 🏗️ Data Warehouse & Mart Build: Production ETL Pipeline.
An end-to-end data pipeline build that extract from sources (csv files on data engineering related job postings), into a normalized data warehouse with a star schema design and then build specialized data marts

---

## 🧰 Tech Stack

- 🐤 **Query Engine:** DuckDB for fast OLAP-style ETL process queries execution 
- 🧮 **Language:** SQL (ANSI-style with analytical functions)  
- 📊 **Data Model:** Star schema with fact + dimension + bridge tables  
- 🛠️ **Development:** VS Code for SQL editing + Terminal for DuckDB CLI  
- 📦 **Version Control:** Git/GitHub for versioned SQL scripts  

--- 
## 🧩 Problem & Context

Raw job posting data arrives as flat CSV files in Google Cloud Storage—not structured for analytical queries. Analysts need to answer:

  - Which skills are most in-demand over time?
  - What are hiring trends by company and location?
  - How do salary patterns vary by role and skill?

**Challenge**: To ensure consistent and reliable analytics, data teams require a central data warehouse as their single source of truth. Also  targeted data marts that pre-aggregate data for specific business functions, boosting query performance while cutting analytical complexity and resource strain are equally useful.

**Solution**: End-to-end ETL pipeline that extracts CSVs from cloud storage, normalizes them into a star schema warehouse (separating facts from dimensions), and creates specialized data marts optimized for specific use cases (flat queries, skill demand analysis, priority role tracking).
---

## 📂 Repository Structure

```text
Data_Warehouse_Mart_Build
├
├── 01_create_tables.sql         # Data warehouse tables definition
├── 02_load_schema_data.sql      # Loading in source data
├── 03_create_flat_mart.sql       # A flat mart with a flat table of job postings
├── 04_create_skills_mart.sql      # Skills marts
├── 05_create_priority_mart.sql
├── 06_update_priority_mart.sql    # Updating priority mart                      
├── 07_create_company_mart.sql    # Company mart 
├── build_mart.sql                # Complete build script for the data warehouse
└── README.md                      # You are here
```
---

The full data warehouse build process:
1. [`01_create_tables.sql`](./01_create_tables.sql) – main data warehouse schema and tables design.
2. [`02_load_schema_data.sql`](./02_load_schema_data.sql) – source data ingestion into the warehouse  
3. [`03_create_flat_mart.sql`](./03_create_flat_mart.sql) – a flat mart schema with a flat table design for job postings details
4. [`04_create_skills_mart.sql`](./04_create_skills_mart.sql) – a skills mart schema that focus on skills related to job postings 
5. [`05_create_priority_mart.sql`](./05_create_priority_mart.sql) – a priority mart schema that focus on priority of skills as specified by a company
6. [`06_update_priority_mart.sql`](./06_update_priority_mart.sql) – batch update in priority mart to sync priority roles changes
7. [`07_create_company_mart.sql`](./07_create_company_mart.sql) – a company mart that focus on company hires


## 🧩 Data Pipeline and Warehouse Design & Optimization
- **Idempotency**: The whole pipeline is designed to run sequencially from start to finish, creating a fresh build upon every batch execution without an itch via the use of `IF EXISTS` or `REPLACE` on table definitions and an added `CASCADE` clause on schemas definition.
- **Star Schema Design**: The warehouse and marts adopt the star schema design. The dimension tables are built first, followed by the brige tables and lastly the facts tables. The bridge tables link the dimension tables which are referenced on the facts tables.
- **Batch Update**: Simulating how a data warehouse or mart update - pulling in and synchronizing changes from source to target tables, can be substituted for complete rebuild process for time and resources optimization.
- **Logging**: Informative logs for every step of the pipeline build.
- **Data Sampling**: Queries to validate table data upon completing an insertion.
- **Data Integrity**: Appropriate Interity Constraints on every table including `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL` and `CHECK` for data validation.
- **Code Structure**: Proper indentation for codes readability and writing all SQL clauses, data types, fuctions and constraint in Uppercase for distinctive recognision.

----
## 📌 Brief of Skills Application
- **Code Organisation**: `WITH` CTEs for code organisation and reusing queries on the `skills_mart.skill_demand_monthly_fact` and `company_mart.company_monthly_hire_fact`.
- **Data Flagging**: Data categorization and transformation (from boolean to dummies) using multiple `CASE` expressions to derive value for fields like `is_remote`, `has_health_insurance` and `job_no_degree_required` on the `skills_mart.skill_demand_monthly_fact` and `company_mart.company_monthly_hire_fact` tables.
- **Date Extraction**: Unique selection with `DISTINCT` clause on specific date parts extracts using `DATE_TRUNC` and `EXTRACT` functions to populate the `skills_mart.date_month_dim` and `company_mart.date_month_dim` tables.
- **Aggregations**: Using `SUM`, `COUNT`, `AVG`, `MIN` and `MAX` on group query result.
- **Multiple Joins**: Multiple table `INNER JOIN` and `LEFT JOINS` within and across schemas to perform selection insert into other tables.
- **Other**: Filtering with exclusive `WHERE` conditions, using `ORDER BY` expression to order query result


### Main Warehouse 
- **Schema Composition**: By order of table execution, the main schema relations includes:
  > - `company_dim`  
  > - `skills_dim`  
  > - `skills_job_dim`  
  > - `job_postings_fact`  

- **Initail Load Execution**: Used the duckdb `READ_CSV` function with `AUTO_DETECT` option to load source csv files into the warehouse.


## Flat Mart
- **Schema Composition**: The `flat_mart` schema relations include:
  > - `job_postings` 

- **Wide Table Design**: All relevant fields or attributes are united into a single wide design on the `job_postings` table.
- **Table Syncing**: `CREATE OR REPLACE` clause to create fresh table on every batch process.
- **Multiple Join**: Multi-table `LEFT JOIN` across `job_postings_fact`, `company_dim`, `skills_job_dim` and `skills_dim` to construct a consolidated `job_postings` table.


## Skills Mart
- **Schema Composition**: Following the order of table execution, the `skills_mart` schema relations includes:   
  > - `skills_dim`  
  > - `date_month_dim`  
  > - `skill_demand_monthly_fact`  

- **Date Extraction**: Unique selection with `DISTINCT` clause on specific date parts extracts using `DATE_TRUNC` and `EXTRACT` functions to populate the `date_month_dim` table.
- **Aggregations**: `SUM` and `COUNT` aggregation by `skill_id`, `job_title_short` and `month_start_date` groupings with `ORDER BY` application to build the `skill_demand_monthly_fact` table.


## Priority Mart
- **Schema Composition**: Following the order of table execution, the `priority_mart` schema relations includes: 
  > - `priority_roles`  
  > - `priority_job_snapshot`   

- **Cross-Schema Joins**: Cross-schema table `LEFT JOIN` of `job_postings_fact` to `company_dim` from `main` schema and an `INNER JOIN` to `priority_roles` to implement a selection insert into the `priority_job_snapshot` table.
- **Batch Update**: Simulating how a data warehouse or mart update - pulling in and synchronizing changes from source to target tables, can be substituted for complete rebuild process for time and resources optimization using the `UPDATE`, `INSERT` and `DELETE` or `MERGE` data manipulation expressions.
- **Temporary tables**: Creating a `TEMP TABLE` for query for table data reuse and code organization


## Company Mart
- **Schema Composition**: By table execution order, the `company_mart` schema relations includes:
  > - `company_dim`
  > - `location_dim`
  > - `company_location_bridge`  
  > - `job_title_dim`  
  > - `job_title_short_dim`  
  > - `job_title_bridge`  
  > - `company_monthly_hire_fact`

- **Unique Id Generation** Using `ROW_NUMBER` with  `ORDER BY` expression to generate unique ids on the `location_dim`, `job_title_dim` and `job_title_short_dim` table.
- **Multiple Cross-schema Joins**: Multiple Cross-schema `INNER JOIN` among `job_postings_fact` from the `main` schema to the `company_mart` schema firstly to `company_dim` and `location_dim` tables to perform selection insert into the `company_location_bridge` table and also to `job_title_dim` and `job_title_short_dim` tables to populate the `job_title_bridge` table.
- **Aggregations**: Calculating `median_salary`, `minimum_salary` and `maximun_salary` after grouping by `company_id`, `job_title_short_id`, `month_start_date` and `job_country` on the `company_monthly_hire_fact` table.
 -----