/* 
Getting metadata info about a database
information_schema:
  - collection of read only views that contains all schema metadata inside a database
  - it contain schema metadata on tables, columns, views, table_constraints, key_column_usage etc…
 */

select 
  table_name, 
  column_name, 
  data_type
FROM information_schema.columns
WHERE table_catalog = 'data_jobs';


SELECT *
FROM information_schema.tables;

SELECT *
FROM infromation_schema.table_constraints
WHERE table_catalog = 'data_jobs';

/* using PRAGMA (sqlite and duckdb) */
PRAGMA show_tables; /* for connected database */

PRAGMA show_tables_extended; /* includes other database in the database manager */

/* structure info on a table using DESCRIBE (duckdb) */
DESCRIBE job_posting_facts;
