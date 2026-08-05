DROP SCHEMA IF EXISTS company_mart CASCADE;

CREATE SCHEMA company_mart;
 
 
--Creating first the Company, job location and their bridge dimension tables 

SELECT '--- Loading Company Dimension for Company Mart ---' AS info;

CREATE TABLE company_mart.company_dim (
  company_id    INTEGER   PRIMARY KEY,
  company_name  VARCHAR,
);

INSERT INTO company_mart.company_dim (
  company_id,
  company_name
)
SELECT 
  company_id,
  company_name
FROM company_dim;


SELECT '--- Loading Location Dimension for Company Mart ---' AS info;

CREATE TABLE company_mart.location_dim (
  location_id   INTEGER   PRIMARY KEY,
  job_country   VARCHAR,
  job_location  VARCHAR,
);

INSERT INTO company_mart.location_dim (
  location_id,
  job_country,
  job_location
)
SELECT 
  ROW_NUMBER() OVER(
    ORDER BY 
      job_country,
      job_location
  ) as location_id,
  job_country,
  job_location
FROM job_postings_fact 
WHERE 
  job_country IS NOT NULL
  AND job_location IS NOT NULL
GROUP BY
  job_country,
  job_location
ORDER BY 
  job_country,
  job_location;

  
SELECT '--- Loading Company Location Bridge for Company Mart ---' AS info;
 
CREATE TABLE company_mart.company_location_bridge (
  company_id        INTEGER,
  location_id       INTEGER,
  PRIMARY KEY (company_id, location_id),
  FOREIGN KEY (company_id) REFERENCES company_mart.company_dim(company_id),
  FOREIGN KEY (location_id) REFERENCES company_mart.location_dim(location_id)
);

INSERT INTO company_mart.company_location_bridge (
  company_id,
  location_id,
)
SELECT 
  ccd.company_id,
  ld.location_id,
FROM job_postings_fact as jpf 
INNER JOIN company_mart.company_dim as ccd 
  ON jpf.company_id = ccd.company_id 
INNER JOIN company_mart.location_dim as ld 
  ON jpf.job_country = ld.job_country 
  AND jpf.job_location = ld.job_location;


--Creating next the job title, job title short and their bridge dimension tables 

SELECT '--- Loading Job Title for Company Mart ---' AS 'info';

CREATE TABLE company_mart.job_title_dim (
  job_title_id    INTEGER   PRIMARY KEY,
  job_title       VARCHAR
);

INSERT INTO company_mart.job_title_dim(
  job_title_id,
  job_title
)
SELECT 
  ROW_NUMBER() OVER(
    ORDER BY job_title
  ) as job_title_id,
  job_title
FROM job_postings_fact
WHERE job_title IS NOT NULL 
GROUP BY job_title
ORDER BY job_title;


SELECT '--- Loading Job Title Short for Company Mart ---' AS 'info';

CREATE TABLE company_mart.job_title_short_dim (
  job_title_short_id    INTEGER   PRIMARY KEY,
  job_title_short       VARCHAR
);

INSERT INTO company_mart.job_title_short_dim(
  job_title_short,
  job_title_short_id
)
SELECT 
  ROW_NUMBER() OVER(
    ORDER BY job_title_short
  ) as job_title_short_id,
  job_title_short
FROM job_postings_fact
WHERE job_title_short IS NOT NULL 
GROUP BY job_title_short
ORDER BY job_title_short;


SELECT '--- Loading Job Title Bridge for Company Mart ---' AS 'info';

CREATE TABLE company_mart.job_title_bridge (
  job_title_short_id   INTEGER,
  job_title_id         INTEGER,
  PRIMARY KEY (job_title_short_id, job_title_id),
  FOREIGN KEY (job_title_short_id) REFERENCES company_mart.job_title_short_dim,
  FOREIGN KEY (job_title_id) REFERENCES company_mart.job_title_dim
);

INSERT INTO company_mart.job_title_bridge (
  job_title_short_id,
  job_title_id,
  job_posting_date
)
SELECT 
  jsd.job_title_short_id,
  jtd.job_title_id,
FROM job_postings_facts as jpf
INNER JOIN company_mart.job_title_short_dim as jsd
  ON jpf.job_title_short = jsd.job_title_short
INNER JOIN company_mart.job_title_dim as jtd 
  ON jpf.job_title = jtd.job_title 
  

--Creating next the Date_Month dimension table

SELECT '--- Loading Date Month Dimension for Company Mart ---' AS info;
 
CREATE TABLE company_mart.date_month_dim (
  month_start_date    DATE   PRIMARY KEY,
  year                INTEGER,
  month               INTEGER,
  quarter             INTEGER,
  quarter_name        VARCHAR,
  year_quater         VARCHAR
);

INSERT INTO company_mart.date_month_dim (
  month_start_date,
  year,
  month,
  quarter,
  quarter_name,
  year_quater
)
SELECT DISTINCT
  DATE_TRUNC('month', job_posting_date)::DATE as month_start_date,
  EXTRACT(YEAR FROM job_posting_date) as year,
  EXTRACT(MONTH FROM job_posting_date) as month,
  EXTRACT(QUARTER FROM job_posting_date) as quarter,
  'Q' || EXTRACT(QUARTER FROM job_posting_date)::VARCHAR as quarter_name,
  EXTRACT(YEAR FROM job_posting_date)::VARCHAR || 'Q' || EXTRACT(QUARTER FROM job_posting_date)::VARCHAR as year_quarter
FROM job_postings_fact 
ORDER BY month_start_date;


--Creating last the Company Monthly Hiring table

SELECT '--- Loading Company Monthly Hiring for Company Mart ---' AS info;
 
CREATE TABLE company_mart.company_monthly_hire_fact (
  month_hire_id             INTEGER   PRIMARY, 
  company_id                INTEGER,
  job_title_short_id        INTEGER,
  month_start_date          DATE,
  job_country               VARCHAR,
  postings_count            INTEGER,
  median_salary_year        DOUBLE,
  minimum_salary_year       DOUBLE,
  maximum_salary_year       DOUBLE,
  remote_share              DOUBLE,
  health_insurance_share    DOUBLE,
  no_degree_mention_share   DOUBLE,
  FOREIGN KEY (company_id) REFERENCES company_mart.company_dim(company_id),
  FOREIGN KEY (job_title_short_id) REFERENCES company_mart.job_title_short_dim(job_title_short_id),
  FOREIGN KEY (month_start_date) REFERENCES company_mart.date_month_dim(month_start_date),
);


INSERT INTO company_mart.company_monthly_hire_fact (
  month_hire_id,
  company_id,
  job_title_short_id,
  month_start_date,
  job_country,
  postings_count,
  median_salary_year,
  min_salary_year,
  max_salary_year,
  remote_share,
  health_insurance_share,
  no_degree_mention_share
)
WITH job_postings_prep AS (
  SELECT 
    company_id,
    job_title_short_id,
    DATE_TRUNC('month', job_posted_date)::DATE as month_start_date,
    job_country,
    COALESCE(salary_year_avg, salary_hour_avg * 2500) as salary_year_avg,
    CASE 
      WHEN job_work_from_home = TRUE 
        THEN 1.0  
        ELSE 0.0 
    END AS is_remote,
    CASE 
      WHEN job_health_insurance = TRUE 
        THEN 1.0
        ELSE 0.0
    END AS has_health_insurance,
    CASE 
      WHEN job_has_no_degree_mention = TRUE 
        THEN 1.0
        ELSE 0.0
    END AS no_degree_required
  FROM job_postings_fact as jpf
  INNER JOIN company_mart.job_title_short_dim as cjsd 
    ON jpf.job_title_short = cjsd.job_title_short 
  WHERE 
    company_id IS NOT NULL 
    AND job_country IS NOT NULL
    AND job_posted_date IS NOT NULL 
    AND (
      salary_year_avg IS NOT NULL
      OR salary_hour_avg IS NOT NULL
    )
)
SELECT 
  ROW_NUMBER() OVER(
      ORDER BY 
        company_id,
        job_title_short_id,
        month_start_date,
        job_country
  ) as month_hire_id,
  company_id,
  job_title_short_id,
  month_start_date,
  job_country,
  
  -- Posting count per group columns
  COUNT(*) as postings_count,
  MEDIAN(salary_hour_avg) as median_salary_year,
  MIN(salary_year_avg) as min_salary_year,
  MAX(salary_year_avg) as max_salary_year,
  
  -- Ratio of postings that are renote jobs per group columns
  AVG(is_remote) as remote_share,
  
  -- Ratio of postings that has health insurance per group columns
  AVG(has_health_insurance) as health_insurance_share,
  
  -- Ratio of postings that did not mention any degree per group columns
  AVG(no_degree_required) as no_degree_mention_share
FROM job_postings_prep
GROUP BY 
  company_id,
  job_title_short_id,
  month_start_date,
  job_country
ORDER BY 
  company_id,
  job_title_short_id,
  month_start_date,
  job_country;
  


-- Data Validation

-- Querying the counts of loaded tables

SELECT 
  'Company Dimension', 
  COUNT(*)
FROM company_mart.company_dim 
UNION ALL
SELECT 
  'Location Dimension', 
  COUNT(*)
FROM company_mart.location_dim 
UNION ALL
SELECT 
  'Company Location Bridge', 
  COUNT(*)
FROM company_mart.company_location_bridge
UNION ALL
SELECT 
  'Job Title Dimension' AS table_name, 
  COUNT(*) as record_count 
FROM company_mart.job_title_dim
UNION ALL
SELECT 
  'Job Title Short Dimension', 
  COUNT(*)
FROM company_mart.job_title_short_dim
UNION ALL  
SELECT 
  'Job Title Bridge', 
  COUNT(*)
FROM company_mart.job_title_bridge
UNION ALL
SELECT 
  'Date Month Dimension', 
  COUNT(*)
FROM company_mart.date_month_dim 
UNION ALL
SELECT 
  'Company Monthly Hiring Fact', 
  COUNT(*)
FROM company_mart.company_monthly_hire_fact; 
   
 
-- Sampling data in loaded tables

SELECT '--- Company Dimension Sample ---' AS info;
SELECT * FROM company_mart.company_dim LIMIT 5;

SELECT '--- Location Dimension Sample ---' AS info;
SELECT * FROM company_mart.location_dim LIMIT 5;

SELECT '--- Company Location Bridge Sample ---' AS info;
SELECT 
  clb.location_id,
  clb.company_id,
  cd.company_name,
  ld.job_country,
  ld.job_location
FROM company_mart.company_location_bridge as clb
INNER JOIN company_mart.company_dim as ccd 
  ON clb.company.id = ccd.company.id 
INNER JOIN company_mart.location_dim as ld 
  ON clb.location_id = ld.location_id
LIMIT 5;

SELECT '--- Job Title Dimension Sample ---' AS info;
SELECT * FROM company_mart.job_title_dim LIMIT 5;

SELECT '--- Job Title Short Dimension Sample ---' AS info;
SELECT * FROM company_mart.job_title_short_dim LIMIT 5;

SELECT '--- Job Title Bridge Sample ---' AS info;
SELECT 
  jtb.job_title_id,
  jtb.job_title_short_id,
  jtd.job_title,
  jsd.job_title_short
FROM company_mart.job_title_bridge as jtb 
INNER JOIN company_mart.job_title_dim as jtd 
  ON jtb.job_title_id = jtd.job_title_id 
INNER JOIN company_mart.job_title_short_dim as jsd 
  ON jtb.job_title_short_id = jsd.job_title_short_id
LIMIT 5;

SELECT '--- Date Month Dimension Sample ---' AS info;
SELECT * FROM company_mart.date_month_dim LIMIT 5;



SELECT '--- Company Hire Sample ---' AS info;
SELECT 
  cmh.*,
  ccd.company_name,
  jsd.job_title_short,
  dmd.year_quater,
  dmd.month
FROM company_mart.company_monthly_hire_fact as cmh 
LEFT JOIN company_mart.company_dim as ccd 
  ON cmh.company_id = ccd.company_id 
LEFT JOIN company_mart.job_title_short_dim as jsd 
  ON cmh.job_title_short_id = jsd.job_title_short_id
LEFT JOIN company_mart.date_month_dim as dmd 
  ON cmh.month_start_date = dmd.month_start_date
LIMIT 5;