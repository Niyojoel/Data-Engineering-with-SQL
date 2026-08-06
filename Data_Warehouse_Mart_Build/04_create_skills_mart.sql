-- Step 04: Mart - Create Skills Mart

DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA skills_mart;


SELECT '--- Loading Skills Dim table for Skills Mart ---' AS info;

CREATE TABLE skills_mart.skills_dim (
  skill_id    INTEGER   PRIMARY KEY,
  skill_name  VARCHAR,
  skill_type  VARCHAR CHECK(skill_type IN ('programming', 'query', 'statistical'))
);

INSERT INTO skills_mart.skills_dim
SELECT 
  skill_id,
  skill_name,
  skill_type
FROM skills_dim;


SELECT '--- Loading Date Month Dim table for Skills Mart ---' AS info;

CREATE TABLE skills_mart.date_month_dim (
  month_start_date    DATE    PRIMARY KEY,
  year                INTEGER,
  month               INTEGER,
  quater              INTEGER,
  quater_name         VARCHAR,
  year_quater         VARCHAR
);

INSERT INTO skills_mart.date_month_dim (
  month_start_date,
  year,
  month,
  quater,
  quater_name,
  year_quater
)
SELECT DISTINCT
  DATE_TRUNC('month', job_posted_date) AS month_start_date,
  EXTRACT(YEAR FROM job_posted_date) AS year,
  EXTRACT(MONTH FROM job_posted_date) AS month,
  EXTRACT(QUARTER FROM job_posted_date) AS quater,
  'Q' || EXTRACT(QUATER FROM job_posted_date)::VARCHAR as quater_name,
  EXTRACT(YEAR FROM job_posted_date)::VARCHAR || '-Q' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR as year_quater
FROM job_postings_fact
ORDER BY month_start_date;


SELECT '--- Loading Skills Demand Monthly Fact for Skills Mart ---' AS info;

CREATE TABLE skills_mart.skill_demand_monthly_fact (
  skill_id                          INTEGER,
  month_start_date                  DATE,
  job_title_short                   VARCHAR,
  postings_count                    INTEGER,
  remote_postings_count             INTEGER,
  health_insurance_postings_count   INTEGER,
  no_degree_mention_postings_count  INTEGER,
  PRIMARY KEY (skill_id, month_start_date, job_title_short),
  FOREIGN KEY (skill_id) REFERENCES skills_mart.skills_dim(skill_id),
  FOREIGN KEY (month_start_date) REFERENCES skills_mart.date_month_dim(month_start_date)
);

INSERT INTO skills_mart.skill_demand_monthly_fact (
  skill_id,
  month_start_date,
  job_title_short,
  postings_count,
  remote_postings_count,
  health_insurance_postings_count,
  no_degree_mention_postings_count
)
WITH job_postings_prep AS (
  SELECT
    sjd.skill_id,
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    jpf.job_title_short,
    CASE 
      WHEN jpf.job_work_from_home = TRUE 1 
      ELSE 0 
    END AS is_remote,
    CASE 
      WHEN jpf.job_health_insurance = TRUE 1 
      ELSE 0 
    END AS has_health_insurance,
    CASE 
      WHEN jpf.job_no_degree_required = TRUE 1 
      ELSE 0 
    END AS no_degree_mentioned
  FROM job_postings_fact as jpf
  INNER JOIN skills_job_dim as sjd
    ON jpf.job_id = sjd.job_id
)
SELECT
  skill_id,
  month_start_date,
  job_title_short,
  COUNT(*) AS postings_count,
  SUM(is_remote) AS remote_postings_count,
  SUM(has_health_insurance) AS health_insurance_postings_count,
  SUM(no_degree_mentioned) AS no_degree_postings_count
FROM job_postings_prep
GROUP BY ALL
ORDER BY 1, 2, 3;



--Data Validation

-- Quering the count of the loaded tables
SELECT
  'Skills Dim' as table_name,
  COUNT(*) as record_count
FROM skills_mart.skills_dim
UNION ALL
SELECT 
  'Date Month Dim',
  COUNT(*)
FROM skills_mart.date_month_dim
UNION ALL
SELECT 
  'Skill Demand Fact',
  COUNT(*)
FROM skills_mart.skill_demand_monthly_fact;


-- Sampling loaded table data

SELECT '--- Skills Dimension Sample ---' AS info;
SELECT * FROM skills_mart.skills_dim LIMIT 5;

SELECT '--- Date Month Dimension Sample ---' AS info;
SELECT * FROM skills_mart.date_month_dim LIMIT 5;

SELECT '--- Skill Demand Monthly Fact Dimension Sample ---' AS info;
SELECT * FROM skills_mart.skill_demand_monthly_fact LIMIT 5;