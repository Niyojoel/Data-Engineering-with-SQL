/* 
QUESTION
What are the most in demand skills for data engineer
  - Identify the top 10 in-demand skills for data engineers
  - Focus on remote jobs
*/

SELECT 
  jpf.job_title_short,
  sd.skill as job_skill,
  sd.type as skill_type
  COUNT(jpf.*) as demand_count
FROM job_postings_fact as jpf
INNER JOIN skills_job_dim as sjd
  ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim as sd 
  ON sjd.skill_id = sd.skill_id
WHERE 
  jpf.job_title_short LIKE '%Data Engineer%'
  AND jpf.job_work_from_home = TRUE /* remote jobs */
GROUP BY jpf.job_title_short, sd.skill
ORDER BY demand_count DESC
LIMIT 10;


/* 
The top ten skills for remote data engineer jobs are:
  - sql,
  - python, 
  - aws, 
  - azure, 
  - spark, 
  - airflow, 
  - snowflake, 
  - databrick, 
  - java,
  - gcp
*/