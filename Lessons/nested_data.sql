/* Array or List */

SELECT ['python', 'r', 'sql'];

WITH skills AS (
  SELECT 'python' AS skill
  UNION 
  SELECT 'r'
  UNION  
  SELECT 'sql'
), skills_array AS ( 
  SELECT ARRAY_AGG(skill ORDER BY skill) AS skills
  FROM skills
)
SELECT 
  skills[1] as skill_1,
  skills[2] as skill_2,
  skills[3] as skill_3
FROM skills_array


/* Struct */
WITH skills_struct AS (
  SELECT 
    STRUCT_PACK (
     skill := 'python',
     type := 'programming'
    ) as s
)
SELECT 
  s.skill,
  s.type
FROM skills_struct;


/* Array of structs */
SELECT [
  {skill: 'python', type: 'programming'},
  {skill: 'SQL', type: 'query language'}
] as skills_structs_array


WITH skills_table AS (
  SELECT 
    'python' AS skill, 
    'programming' as type
  UNION ALL
  SELECT 'r', 'statistical language'
  UNION ALL
  SELECT 'sql', 'query language'
), skills_array_struct AS (
  SELECT 
    ARRAY_AGG (
      STRUCT_PACK (
        skill =: skill,
        type := type
      )
    ) as value
  FROM skills_table
)
SELECT 
  value[1].skill as skill_1, 
  value[2].type as skill_2,
  value[3] as skill_3
FROM skills_array_struct;


/* Map */
WITH skill_map AS (
  SELECT MAP(
    'skill': 'python'
    'type': 'programming'
  ) AS skill_type
)
SELECT 
  skill_type['skill'],
  skill_type['type']
FROM skills_map;


/* JSON */
WITH raw_skill_json as (
  SELECT
    '{"skill": "python", "type": "programming"}'::JSON as skill_json
)
SELECT 
  STRUCT_PACK(
    skill := json_extract_string(skill_json, '$.skill'),
    type := json_extract_string(skill_json, '$.type')
  )
FROM raw_skill_json


/* JSON to array of struct */
WITH raw_skills_json as (
  SELECT 
    '[
      {"skill": "python", "type": "programming"},
      {"skill": "SQL", "type": "query language"},
      {"skill": "java", "type": "programming"},
      {"skill": "r", "type": "statistical language"},
    ]'::JSON as skills_json
)
SELECT 
 ARRAY_AGG(
   STRUCT_PACK(
      skill := json_extract_string(e.value, '$.skill'),
      type := json_extract_string(e.value, '$.type')
   )
 )
FROM raw_skills_json, json_each(skills_json) as e