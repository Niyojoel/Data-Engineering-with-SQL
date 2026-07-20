/* CASE is used to categorize data, handle missing data, aggregation etc */

/* Classifying salary into categories */
SELECT 
  job_title_short,
  salary_hour_avg,
  CASE 
    WHEN salary_hour_avg IS NULL THEN 'Missing'
    WHEN salary_hour_avg < 25 THEN 'Low'
    WHEN salary_hour_avg < 50 THEN 'Medium'
    ELSE 'High' 
  END AS salary_category
  FROM job_postings_fact
  LIMIT 10;
  
  
  /* Categorizing job_title column */
  SELECT 
    job_title,
    CASE
      WHEN job_title ILIKE '%Data Engineer%' THEN 'Data Engineer'
      WHEN job_title ILIKE '%Analyst%' THEN 'Data Analyst'
      WHEN job_title ILIKE '%Scientist%' THEN 'Data Scientist'
      WHEN job_title ILIKE '%Software%' THEN 'Software Developer'
      ELSE 'Others'
    END AS job_title_category,
    job_title_short
  FROM job_postings_fact
  ORDER BY random()
  LIMIT 10;
      
  
  /* Aggregating salary median by salary buckets (less than or greater than 100_000) */
  
  SELECT 
    job_title_short,
    COUNT(*) as posting_count,
    MEDIAN(
      CASE 
        WHEN salary_year_avg < 100_000 THEN salary_year_avg
      END
    ) as median_low_salary,
    MEDIAN(
      CASE 
        WHEN salary_year_avg < 100_000 THEN salary_year_avg
      END
    ) as median_high_salary
  FROM job_postings_fact
  WHERE salary_year_avg IS NOT NULL 
  GROUP BY job_title_short;
      
      
  /* Standardizing salary_hour_avg to yearly and Categorizing them */
  WITH salaries AS (
    SELECT 
      job_title_short
      salary_hour_avg,
      salary_year_avg,
      CASE 
        WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
        WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
        ELSE NULL
      END AS standardized_salary
    FROM job_postings_fact
  )
  SELECT 
    *,
    CASE 
      WHEN standardized_salary IS NULL THEN 'Missing'
      WHEN standardized_salary < 75_000 THEN 'Low'
      WHEN standardized_salary < 100_000 THEN 'Medium'
      ELSE 'High'
    END AS salary_category
  FROM salaries
  LIMIT 10;