/* Categorizing job_title column */
  WITH title_with_lower AS (
    SELECT 
      job_title,
      LOWER(REPLACE(job_title, ' ', '_')) as title_clean
    FROM job_postings_fact;
  )
  SELECT 
    job_title,
    CASE
      WHEN title_clean LIKE '%data_engineer%' THEN 'Data Engineer'
      WHEN title_clean ILIKE '%analyst%' THEN 'Data Analyst'
      WHEN title_clean ILIKE '%scientist%' THEN 'Data Scientist'
      WHEN title_clean ILIKE '%software%' THEN 'Software Developer'
      ELSE 'Others'
    END AS job_title_category,
    job_title_short
  FROM title_with_lower
  ORDER BY random()
  LIMIT 10;
      
  