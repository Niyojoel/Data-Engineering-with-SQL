CREATE OR REPLACE TABLE staging.job_postings_flat AS
SELECT 
  jpf.job_id,
  jpf.job_title_short,
  jpf.job_title,
  jpf.job_location,
  jpf.job_via,
  jpf.job_schedule_type,
  jpf.job_work_from_home,
  jpf.search_location,
  jpf.job_posted_date,
  jpf.job_no_degree_mention,
  jpf.job_health_insurance,
  jpf.job_country,
  jpf.salary_rate,
  jpf.salary_year_avg,
  jpf.salary_hour_avg,
  cd.name
FROM data_jobs.job_postings_fact as jpf
LEFT JOIN data_-jobs.company_dim as cd
  ON jpf.company_id = cd.company_id
  

SELECT COUNT(*)
FROM staging.job_postings_flat;

/* Creating a view */
CREATE OR REPLACE VIEW staging.priority_jobs_flat_view AS
SELECT 
  jpf.*
FROM staging.job_postings_flat as jpf 
LEFT JOIN staging.priority_roles as pr 
  ON jpf.job_title_short = pr.role_name
WHERE pr.priority_lvl = 1;


SELECT 
  job_title_short,
  COUNT(*) AS job_count
FROM staging.priority_jobs_flat_views
GROUP BY job_title_short
ORDER BY job_count DESC;


/* Creating temporary table */
CREATE TEMPORARY TABLE senior_jobs_flat_temp
SELECT *
FROM staging.priority_jobs_flat_view
WHERE job_title_short = 'Senior Data Engineer';

/* Deleting from a table */
DELETE FROM staging.job_postings_flat
WHERE job_posted_date < '2024/01/04';

/* Removing all Data entries in a table */
DELETE FROM staging.job_postings_flat; --psql

TRUNCATE TABLE job_postings_flat; --duckdb

/* Creating a fresh table with jobs listed after 2024/01/04 */
CREATE OR REPLACE TABLE staging.job_postings_flat AS
SELECT 
  jpf.job_id,
  jpf.job_title_short,
  jpf.job_title,
  jpf.job_location,
  jpf.job_via,
  jpf.job_schedule_type,
  jpf.job_work_from_home,
  jpf.search_location,
  jpf.job_posted_date,
  jpf.job_no_degree_mention,
  jpf.job_health_insurance,
  jpf.job_country,
  jpf.salary_rate,
  jpf.salary_year_avg,
  jpf.salary_hour_avg,
  cd.name
FROM data_jobs.job_postings_fact as jpf
LEFT JOIN data_-jobs.company_dim as cd
  ON jpf.company_id = cd.company_id
WHERE job_posted_date > '2024/01/04';

