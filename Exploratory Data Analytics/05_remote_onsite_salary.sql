/* QUESTION
  Perform a comparative analysis of remote and onsite jobs per job title
    - Calculate the difference between remote and onsite jobs
    - 

The salary difference between remote jobs and onsite jobs*/
 
WITH title_median AS (
  SELECT 
    job_title_short,
    job_work_from_home,
    MEDIAN(salary_year_avg)::INTEGER as median_salary
  FROM job_postings_fact
  GROUP BY
    job_title_short,
    job_work_from_home
  WHERE job_country = "United States"
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