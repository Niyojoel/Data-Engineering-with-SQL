/* Subquery */

/* Getting the market median salary */
SELECT 
  job_title_short,
  salary_year_avg,
  {
    SELECT percentile_cont(0.5)
    WITHIN GROUP (ORDER BY salary_year_avg)
    FROM job_postings_fact
  } AS market_median_salary
  FROM job_postings_fact
  WHERE salary_hour_avg IS NOT NULL
  LIMIT 100;

  
  /* staging only jobs that are remote and then getting median salary per job title and overall median salary as well for them */
  
  CREATE TEMPORARY TABLE remote_market_median_salary AS 
  SELECT 
    percentile_cont(0.5)
    WITHIN GROUP (ORDER BY salary_year_avg) as value
  FROM job_postings_fact
  WHERE job_work_from_home = TRUE
  
  
  SELECT 
  job_title_short,
  MEDIAN(salary_year_avg) as remote_job_median_salary, /* duckdb */
  remote_market_median_salary.value
  FROM (
    SELECT
      job_title_short,
      salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
  ) AS remote_jobs
  GROUP BY job_title_short
  LIMIT 100;


/* staging only remote job titles where the median salary is above the market median salary for them */

SELECT 
  job_title_short,
  MEDIAN(salary_year_avg) as remote_job_median_salary/* duckdb */
  remote_market_median_salary.value
  FROM (
    SELECT
      job_title_short,
      salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
  ) AS remote_jobs
  GROUP BY job_title_short
  HAVING MEDIAN(salary_year_avg) > remote_market_median_salary
  LIMIT 100;

/* Common Table Expressions - CTES */

/* The salary difference between remote jobs and onsite jobs*/
 
WITH title_median AS (
  SELECT 
    job_title_short,
    job_work_from_home,
    MEDIAN(salary_year_avg)::INTEGER as median_salary
  FROM job_postings_fact
  GROUP BY
    job_title_short,
    job_work_from_home
  WHERE job_country = "Nigeria"
)
SELECT 
  r.job_title_short,
  r.median_salary as remote_median_salary
  o.median_salary as onsite_median_salary
  (r.median_salary - o.median_salary) AS salary_diff
FROM title_median AS r 
JOIN title_median AS o
 ON r.job_title_short = o.job_title_short
WHERE 
  r.job_work_from_home IS TRUE 
  AND o.job_work_from_home IS FALSE
ORDER BY salary_diff DESC;