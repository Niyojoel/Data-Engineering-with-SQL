SELECT UNNEST ([1,1,2,4])
UNION ALL
SELECT UNNEST ([2,1,2,3]);


CREATE TEMPORARY TABLE jobs_2023 AS
SELECT * EXCLUDE (job_id, jon_posted_date)
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2023;

SELECT * FROM jobs_2023;


CREATE TEMPORARY TABLE jobs_2024 AS
SELECT * EXCLUDE (job_id, jon_posted_date)
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2024;


/* Unique Jobs that appear in 2023 and 2024*/
SELECT * FROM jobs_2023
UNION 
SELECT * FROM jobs_2024

/* Same jobs appearing in both years */
SELECT * FROM jobs_2023
INTERSECT
SELECT * FROM jobs_2024;

/* Jobs appearing in 2023 but not in 2024 */
SELECT * FROM jobs_2023
EXCEPT
SELECT * FROM jobs_2024;

/* Job postings remaining in 2023 after removing match with 2024*/
SELECT * FROM jobs_2023
EXCEPT ALL
SELECT * FROM jobs_2024;


SELECT
  'jobs_2023' as table_name,
  COUNT(*) as record_count
FROM jobs_2023 
UNION 
SELECT 
  'jobs_2024' as table_name,
  COUNT(*)
FROM jobs_2024

