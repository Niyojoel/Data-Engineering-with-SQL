 /* Standardizing salary_hour_avg to yearly and Categorizing them */
 
  SELECT 
    job_title_short
    salary_hour_avg,
    salary_year_avg,
    COALESCE(salary_year_avg, salary_hour_avg*2080) AS standardized_salary,
    CASE 
      WHEN COALESCE(salary_year_avg, salary_hour_avg*2080) IS NULL THEN 'Missing'
      WHEN COALESCE(salary_year_avg, salary_hour_avg*2080) < 75_000 THEN 'Low'
      WHEN COALESCE(salary_year_avg, salary_hour_avg*2080) < 100_000 THEN 'Medium'
      ELSE 'High'
    END AS salary_category
  FROM job_postings_fact
  LIMIT 10;