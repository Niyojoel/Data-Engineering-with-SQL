/* 
QUESTION
What are the highest paying skills for data engineers
  - Calculate the median salary for each skill required
  - Focus on remote position
  - Include skill demand frequency
*/


SELECT 
  jpf.job_title_short,
  sd.name as skill_name,
  /* sd.type as skill_type */
  COUNT(jpf.*) as demand_count,
  percentile_cont(0.5)
    WITHIN GROUP (ORDER BY jpf.salary_year_avg)::INTEGER as median_salary
FROM job_postings_facts as jpf
INNER JOIN skill_job_dim as sjd
  ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim as sd
  ON sjd.skill_id = sd.skill_id
 WHERE 
   jpf.job_title_short = 'Data Engineer'
   AND jpf.job_work_from_home = TRUE /* for remote jobs*/
 GROUP BY jpf.job_title_short, sd.name
 HAVING COUNT(jpf.*) > 100
 ORDER BY median_salary DESC
 LIMIT 10;
 
 
 /*
 
 The top paying in-demand skills for data engineers are:
   - rust
   - golang
   - terraform
   - spring
   - neo4j
   - gdpr
   - zoom
   - graphql
   - mongo
   - fastApi
   
 The list provide an insight into scarce data engineering in-demand skills. 
 They have the highest salary
 */