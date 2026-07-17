USE data_jobs;

DROP DATABASE IF EXISTS job_mart;

CREATE DATABASE IF NOT EXISTS job_mart;

SELECT * 
FROM information_schema.schemata; 

USE job_mart;

CREATE SCHEMA IF NOT EXISTS staging;

/* DROP IF EXISTS SCHEMA staging */

CREATE TABLE IF NOT EXISTS staging.preferred_roles (
  role_id INTEGER PRIMARY KEY,
  role_name VARCHAR
);

SELECT *
FROM information_schema.tables
WHERE table_catalog = 'job_mart';

INSERT INTO staging.preferred_roles (role_id, role_name)
VALUES 
  (1, 'Data Engineer'),
  (2, 'Data Science'),
  (3, 'Data Analyst');
  
SELECT *
FROM staging.preferred_roles;

ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;


/*
ALTER TABLE staging.preferred_roles
DROP COLUMN preferred_role;
*/

UPDATE staging.preferred_roles 
SET preferred_role = 
  CASE role_id = 1 OR role_id = 2 
    THEN TRUE 
  ELSE FALSE END;
  
 
-- altering preferred_role table
ALTER TABLE staging.preferred_roles
RENAME TO priority_roles

ALTER TABLE staging.priority_roles 
ALTER COLUMN role_id 
SET CONSTRAINT role_id_key PRIMARY KEY
 
ALTER TABLE staging.priority_roles 
RENAME COLUMN preferred_role TO priority_lvl

ALTER TABLE staging.priority_roles 
ALTER COLUMN priority_lvl SET DATA TYPE INTEGER;