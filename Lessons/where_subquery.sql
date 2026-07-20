/* To extract rows with matches in the target (intercept between source and target) */
SELECT *
FROM range(10) as src(key)
WHERE EXISTS (
  SELECT 1
  FROM range(8) as tgt(key)
  WHERE tgt.key = src.key
);


/* To extract rows with no matches in the target (exclusive entry in source not present in target) */
SELECT *
FROM range(10) as src(key)
WHERE NOT EXISTS (
  SELECT 1
  FROM range(8) as tgt(key)
  WHERE tgt.key = src.key
);


/* Filtering rows with no listed skills */

SELECT *
FROM job_postings_fact as tgt
WHERE NOT EXISTS (
  SELECT 1
  FROM skill_job_dim as src
  WHERE tgt.job_id = src.job_id
)
ORDER BY job_id;





