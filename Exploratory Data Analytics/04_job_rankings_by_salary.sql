/*
QUESTION
 1. What are the 5 most highest paying jobs
   - Create job_title ranking by their salary
*/

SELECT 
  job_title_short,
  MEDIAN(COALESCE(salary_year_avg, salary_hour_avg * 2500)) as median_salary,
  RANK() OVER(
    ORDER BY MEDIAN(salary_year_avg) DESC
  ) AS job_salary_rank
FROM job_postings_fact
WHERE COALESCE(salary_year_avg, salary_hour_avg * 2500) IS NOT NULL
GROUP BY job_title_short
ORDER BY median_salary DESC;
  
 
/*
 NOTE - For job posting without yearly salary but with hourly salary, we rebased them to yearly by multiplying them by 2500 hours (a yearly aggregation of a around around 7 hours workday)
 
 
*/
