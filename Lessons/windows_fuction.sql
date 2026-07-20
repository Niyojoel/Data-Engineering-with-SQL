/* Using window function to calculate median salary of job listing per job_title_short and company_id */
SELECT 
  job_id,
  job_title_short,
  salary_year_avg,
  company_id,
  MEDIAN(salary_year_avg) OVER(
    PARTITION BY job_title_short, company_id
  )
FROM job_postings_fact
WHERE 
  salary_year_avg IS NOT NULL
  AND job_title_short = 'Data Engineer'
ORDER BY random()
LIMIT 10;


/* ORDER BY */

/* Ranking jobs by salary hour avg in descending order */
SELECT 
  job_id,
  job_title_short,
  salary_year_hour,
  RANK() OVER(
    ORDER BY salary_hour_avg DESC
  ) AS rank_hourly_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;


/* Calculating the running average of salary hour avg by job title partition, ordered by job_posted_date */
SELECT 
  job_posted_date,
  job_title_short,
  salary_year_hour,
  --could be SUM for cumsum partitioned by job_title_short, or MIN, MAX, MEDIAN etc
  AVG(salary_hour_avg) OVER(
    PARTITION BY job_title_short
    ORDER BY job_posted_date
  ) AS running_avg_hourly
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY
  job_title_short,
  job_posted_date
LIMIT 10;
  

/* Ranking jobs by Partitions */
SELECT 
  job_id,
  job_title_short,
  salary_year_hour,
  RANK() OVER(
    PARTITION job_title_short
    ORDER BY salary_hour_avg DESC
  ) AS rank_hourly_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY 
  salary_year_avg DESC,
  job_title_short
LIMIT 10;


/* Adding row number to a table */
SELECT
  *,
  ROW_NUMBER() OVER(
    ORDER BY job_posted_date
  ) AS row_num
FROM job_postings_fact
ORDER BY row_num
LIMIT 10;


/* LEADING and LAGGING to create previous and next salary*/

SELECT 
  job_id,
  company_id,
  job_title,
  job_title_short,
  job_posted_date
  salary_year_avg,
  LAG(salary_year_avg) 
    OVER (
      PARTITION company_id
      ORDER BY job_posted_date
    ) as previous_salary,
    salary_year_avg - LAG(salary_year_avg) 
    OVER (
      PARTITION company_id
      ORDER BY job_posted_date
    ) as salary_change
  FROM job_postings_fact
  WHERE salary_year_avg IS NOT NULL
  ORDER BY company_id, job_posted_date
  LIMIT 60;
  