--Step 5: Mart - Create Priority Mart

DROP SCHEMA IF EXISTS priority_mart CASCADE;

CREATE SCHEMA priority_mart;

SELECT '--- Loading Priority Roles for Priority Mart---' AS info;

CREATE TABLE priority_mart.priority_roles (
  role_id         INTEGER     PRIMARY KEY,
  role_name       VARCHAR,
  priority_lvl    INTEGER
);

INSERT INTO priority_mart.priority_roles (
  role_id,
  role_name,
  priority_lvl
)
VALUES 
  (1, 'Data Engineer', 2),
  (2, 'Senior Data Engineer', 1),
  (3, 'Software Engineer', 3);
  

SELECT '--- Loading Priority Jobs Snapshot for Priority Mart ---' AS info;

CREATE OR REPLACE TABLE priority_mart.priority_jobs_snapshot (
  job_id            INTEGER    PRIMARY KEY,
  job_title_short   VARCHAR,
  company_name      VARCHAR,
  job_posted_date   TIMESTAMP,
  salary_year_avg   DOUBLE,
  priority_lvl      INTEGER,
  updated_at        TIMESTAMP
);

INSERT INTO priority_mart.priority_jobs_snapshot (
  job_id,
  job_title_short,
  company_name,
  job_posted_date,
  salary_year_avg,
  priority_lvl,
  updated_at
)
SELECT 
  jpf.job_id
  jpf.job_title_short,
  cd.name as company_name,
  jpf.job_posted_date,
  jpf.salary_year_avg,
  pr.priority_lvl,
  CURRENT_TIMESTAMP
FROM job_postings_fact as jpf
LEFT JOIN company_dim as cd
  ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles as pr 
  ON jpf.job_title_short = pr.role_name;
  
/* Initial load query */
SELECT 
  job_title_short
  COUNT(*) as job_count,
  MIN(priority_lvl) as priority_lvl
  MIN(updated_at) as updated_at
FROM priority_mart.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;