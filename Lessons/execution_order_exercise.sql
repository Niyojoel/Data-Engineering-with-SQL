/* 
find the top 10 companies for posting jobs.
They must have above 3000 postings
Their location must be in the US
*/

/* EXPLAIN outputs the plan for query execution without executing 
   (EXPLAIN ANALYSE outputs the query execution plan after the execution*/
EXPLAIN ANALYZE
SELECT
  cd.company_name,
  COUNT(jpf.job_id) as postings_count
FROM job_posting_facts as jpf
LEFT JOIN company_dim as cd
  ON jpf.company_id = cd.company_id
WHERE jpf.job_location = 'United States'
GROUP BY cd.company_name
HAVING COUNT(jpf.job_id) > 3000
ORDER BY postings_count DESC
LIMIT 10;