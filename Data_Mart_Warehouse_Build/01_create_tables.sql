DROP TABLE IF EXISTS skills_jobs_dim;
DROP TABLE IF EXISTS job_postings_fact;
DROP TABLE IF EXISTS company_dim;
DROP TABLE IF EXISTS skills_dim;

SELECT "Creating company_dim table" as info

--Creating company dimension table
CREATE TABLE company_dim (
  company_id     INTEGER   PRIMARY KEY,
  company_name   VARCHAR   NOT NULL
);

SELECT "Creating skills_dim table" as info

--Creating skills dimension table
CREATE TABLE skills_dim (
  skill_id      INTEGER   PRIMARY KEY,
  skill_name    VARCHAR   NOT NULL,
  skill_type    VARCHAR,
  CONSTRAINT skill_type_check CHECK(skill_type IN ('programming', 'query', 'statistical'))
);

SELECT "Creating skills_jobs_dim table" as info

--Creating jobs-skills bridge table
CREATE TABLE skills_job_dim (
  skill_id   INTEGER,
  job_id     INTEGER,
  CONSTRAINT skill_job_key PRIMARY KEY (skill_id, job_id),
  FOREIGN KEY (skill_id) REFERENCES skills_dim(skill_id),
  FOREIGN KEY (job_id) REFERENCES job_postings_fact(job_id)
);

SELECT "Creating job_postings_fact table" as info

--Creating job postings dimension table
CREATE TABLE job_postings_fact (
  job_id                  INTEGER   PRIMARY KEY,
  company_id              INTEGER   NOT NULL,
  job_title_short         VARCHAR   NOT NULL,
  job_title               VARCHAR   NOT NULL,
  job_location            VARCHAR,  
  job_via                 VARCHAR   NOT NULL,
  job_schedule_type       VARCHAR,
  job_work_from_home      BOOLEAN  NOT NULL,
  search_location         VARCHAR,
  job_posted_date         TIMESTAMP NOT NULL,
  job_no_degree_mention   BOOLEAN   NOT NULL ,
  job_health_insurance    BOOLEAN   NOT NULL,
  job_country             VARCHAR   NOT NULL,
  salary_rate             VARCHAR, 
  salary_year_avg         DOUBLE,
  salary_hour_avg         DOUBLE,
  FOREIGN KEY (company_id) REFERENCES company_dim(company_id),
  CONSTRAINT salary_rate_check CHECK(salary_rate IN ('Hourly', 'Weekly', 'Monthly', 'Yearly'))
);           