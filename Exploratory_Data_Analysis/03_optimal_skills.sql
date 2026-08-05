/* 
QUESTION
What are the most optimal skills for data engineers balancing both demand and salary
  - Create a ranking column that combines both demand count and salary
  - Focus on remote position with specified annual salary
*/

SELECT 
  jpf.job_title_short,
  sd.name as skill_name,
  COUNT(jpf.*) as demand_count,
  LN(COUNT(jpf.*))::NUMERIC(3,2) as ln_demand_count,
  percentile_cont(0.5)
    WITHIN GROUP (ORDER BY jpf.salary_year_avg)::INTEGER as median_salary,
  COUNT(jpf.*) * percentile_cont(0.5)*
    WITHIN GROUP (ORDER BY jpf.salary_year_avg)::INTEGER as optimal_score,
  (LN(COUNT(jpf.*)) * percentile_cont(0.5) 
    WITHIN GROUP (ORDER BY jpf.salary_year_avg)) / 1_000_000::NUMERIC(4,3) as ln_optimal_score
FROM job_postings_facts as jpf
INNER JOIN skill_job_dim as sjd
  ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim as sd
  ON sjd.skill_id = sd.skill_id
 WHERE 
   jpf.job_title_short = 'Data Engineer'
   AND jpf.salary_year_avg IS NOT NULL
   AND jpf.job_work_from_home = TRUE 
 GROUP BY jpf.job_title_short, sd.name
 HAVING 
   COUNT(jpf.*) > 100
 ORDER BY median_salary DESC
 LIMIT 10;
 
 
 /*
 The top paying optimal skills for data engineers include:
   - Terraform: terraform lead the list with 
   - python
   - aws
   - sql
   - aws
   - airflow
   - spark
   - snowflake
   - kafka
   - azure
   - java
   
 The list balances skill demand with skill salary to get an optimal list for data engineering skills. 
 */