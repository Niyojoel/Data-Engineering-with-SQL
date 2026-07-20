/* Counting job postings by it year and month of posting */

SELECT 
  EXTRACT(YEAR FROM job_posted_date) as job_posted_year,
  EXTRACT(MONTH FROM job_posted_date) as job_posted_month,
  COUNT(*) as job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
GROUP BY 
  EXTRACT(YEAR FROM job_posted_date),
  EXTRACT(MONTH FROM job_posted_date)
ORDER BY 
  job_posted_year,
  job_posted_month;
  
  
/* Using DATE_TRUNC */

SELECT 
  job_posting_date,
  DATE_TRUNC('month', job_posted_date) AS job_posted_month_rounded
FROM job_postings_fact
ORDER BY random()
LIMIT 10;


/* 
Using trunc on job counts by posted year and month
filtering the job count by year
*/

SELECT 
  DATE_TRUNC('month', job_posting_date) as job_posted_month,
  COUNT(*) as job_count
FROM job_postings_fact
WHERE
  job_title_short = 'Data Engineer' 
  AND EXTRACT(YEAR FROM job_posted_date) = 2024
GROUP BY DATE_TRUNC('month', job_posting_date)
ORDER BY job_posted_month;
  
  
/* Using at time zone */

/* Getting the time of job postings with New York location in their local time */

SELECT 
  job_title_short,
  job_location,
  job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
FROM job_postings_fact
WHERE job_location LIKE 'New York, NY';
  

SELECT 
  EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') as job_posted_hour,
  COUNT(*)
FROM job_postings_fact
WHERE job_location LIKE 'New York, NY'
GROUP BY job_posted_hour
ORDER BY job_posted_hour DESC;
  