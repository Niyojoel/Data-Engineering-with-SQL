/* Building a flat skills table with each job skill in an array */

CREATE OR REPLACE TEMP TABLE job_skills_array AS
SELECT 
  jpf.job_id,
  jpf.job_title_short,
  jpf.salary_year_avg,
  ARRAY_AGG(sd.skill_name)
FROM job_postings_fact as jpf
LEFT JOIN skills_job_dim as sjd
  ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd
  ON sd.skill_id = sjd.skill_id
GROUP BY 1, 2, 3;


/* From the perspective of a Data Analyst analyse median salary per skill */

WITH flat_skills AS (
  SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skills) as skill
  FROM job_skills_array
)
SELECT 
  skill,
  AVG(salary_year_avg) AS median_salary
FROM flat_skills
GROUP BY skill
ORDER BY median_salary DESC
LIMIT 50;


/* Building a flat skill and type table for co-workers to access job titles, salary info, skills, and type in one table */

CREATE OR REPLACE TEMP TABLE job_skills_array_structs AS
SELECT 
  jpf.job_id,
  jpf.job_title_short,
  jpf.salary_year_avg,
  ARRAY_AGG(
    STRUCT_PACK(
      skill_type := sd.type,
      skill_name := sd.skill_name
    )
  ) as skills
FROM job_postings_fact as jpf
LEFT JOIN skills_job_dim as sjd
  ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd
  ON sd.skill_id = sjd.skill_id
GROUP BY 1, 2, 3;
loooo

SELECT 
  job_id,
  job_title_short,
  salary_year_avg, 
  UNNEST(skills).skill_type as skill_type
  UNNEST(skills).skill_name as skill_name
FROM job_skills_array_structs
