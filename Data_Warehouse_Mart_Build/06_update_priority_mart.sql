-- Step 06: Mart - update priority roles mart

SELECT '--- Updating Priority Roles for Priority Mart ---' AS info;

--Updating Data Engineer to Priority 1
UPDATE priority_mart.priority_roles
SET priority_lvl = 1
WHERE 
  role_name = 'Data Engineer'
  AND priority_lvl IS DISTINCT FROM 1;


-- Adding Data Scientist on level 3
INSERT INTO priority_mart.priority_roles (
  role_id,
  role_name,
  priority_lvl
)
VALUES (4, 'Data Scientist', 3);

-- Data Validation
SELECT * FROM priority_mart.priority_roles;


SELECT '--- Creating a Temp Source table for Priority Mart Update ---' AS info;

CREATE OR REPLACE TEMPORARY TABLE src_priority_jobs AS 
SELECT (
  jpf.job_id,
  jpf.job_title_short,
  cd.name as company_name,
  jpf.job_posted_date,
  jpf.salary_year_avg,
  pr.priority_lvl,
  current_timestamp as updated_at
)
FROM job_posting_facts as jpf
LEFT JOIN company_dim as cd 
  ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles as pr
  ON jpf.job_title_short = pr.role_name;
 

SELECT '--- Batch Updating Priority Job Snapshot for Priority Mart ---' AS info;
MERGE INTO priority_mart.priority_jobs_snapshot as tgt
USING src_priority_jobs as src
ON tgt.job_id = src.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
  UPDATE SET 
    priority_lvl = src.priority_lvl
    updated_at = src.updated_at
  
WHEN NOT MATCHED THEN
  INSERT (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
  )
  VALUES (
    src.job_id,
    src.job_title_short,
    src.company_name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at
  );
  
  WHEN NOT MATCHED BY SOURCE
  THEN DELETE;
  
  
  /* Data warehouse query */
  SELECT
    job_title_short,
    COUNT(*) as job_count,
    MIN(priority_lvl) as priority_lvl
    MIN(updated_at) as updated_at
  FROM priority_mart.priority_jobs_snapshot as pjs
  GROUP BY job_title_short
  ORDER BY job_count DESC;