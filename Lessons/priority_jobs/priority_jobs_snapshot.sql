CREATE OR REPLACE TABLE main.priority_jobs_snapshot (
  job_id  INTEGER CONSTRAINT job_id_key PRIMARY KEY,
  job_title_short  VARCHAR(50),
  company_name   VARCHAR(50),
  job_posted_date   TIMESTAMP,
  salary_year_avg   DOUBLE,
  priority_lvl  INTEGER,
  updated_at  TIMESTAMP
);

INSERT INTO main.priority_jobs_snapshot (
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
FROM data_jobs.job_postings_fact as jpf
LEFT JOIN data_jobs.company_dim as cd
  ON jpf.company_id = cd.company_id
INNER JOIN staging.priority_roles as pr 
  ON jpf.job_title_short = pr.role_name;
  
/* Initial load query */
SELECT 
  job_title_short
  COUNT(*) as job_count,
  MIN(priority_lvl) as priority_lvl
  MIN(updated_at) as updated_at
FROM main.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;