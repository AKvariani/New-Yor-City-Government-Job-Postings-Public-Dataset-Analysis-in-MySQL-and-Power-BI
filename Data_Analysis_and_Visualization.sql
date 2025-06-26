-- Data Analysis Questions 
-- 1. WHAT IS THE NUMBER OF THE JOB POSTINGS ACCORDING TO THE DATASET ?

SELECT COUNT(*) AS total_rows FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready;


-- 2. WHAT IS  THE NUMBER OF THE POSITIONS BEING HIRED ACCORDING TO THE DATASET ?

SELECT 
  SUM(Number_Of_Positions)
FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready;


-- 3. WHAT ARE IS THE PERIOD OF TIME THAT THIS DATASET COVERS (THE EARLIEST AND THE LATEST DATES OF THE JOB POSTINGS) ?

SELECT CONCAT(
  'From ',
  MIN(STR_TO_DATE(Posting_Date, '%m/%d/%Y')),
  ' To ',
  MAX(STR_TO_DATE(Posting_Date, '%m/%d/%Y'))
) AS date_range
FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready
WHERE STR_TO_DATE(Posting_Date, '%m/%d/%Y') IS NOT NULL;


-- 4. HOW DID THE NUMBER OF JOB POSTINGS CHANGE OVER TIME (Monthly) IN THE DATASET ? (LINE CHART)
SELECT 
  DATE_FORMAT(STR_TO_DATE(Posting_Date, '%m/%d/%Y'), '%Y-%m') AS month,
  COUNT(*) AS number_of_job_postings
FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready
WHERE STR_TO_DATE(Posting_Date, '%m/%d/%Y') IS NOT NULL
GROUP BY month
ORDER BY STR_TO_DATE(CONCAT(month, '-01'), '%Y-%m-%d');


-- 5. HOW DID THE NUMBER POSITIONS BEING HIRED CHANGE OVER TIME (Monthly) IN THE DATASET ? (LINE CHART)

SELECT 
  DATE_FORMAT(STR_TO_DATE(Posting_Date, '%m/%d/%Y'), '%Y-%m') AS month,
  SUM(Number_Of_Positions) AS number_of_positions
FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready
WHERE STR_TO_DATE(Posting_Date, '%m/%d/%Y') IS NOT NULL
GROUP BY month
ORDER BY STR_TO_DATE(CONCAT(month, '-01'), '%Y-%m-%d');

-- 6. WHAT IS THE DISTRIBUTION OF JOBS POSTINGS / NUMBER OF POSITIONS BY THE POSTING TYPE, percentage of whole (INTERNAL/EXTERNAL)?

-- Part one  Job postings
SELECT 
  Posting_Type,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready), 2) AS percentage
FROM 
jobs_nyc_postings.jobs_nyc_postings_sql_ready
GROUP BY 
  Posting_Type;

 -- Part two number of positions 
 
 SELECT 
  Posting_Type,
  ROUND(SUM(Number_Of_Positions) * 100.0 / 
        (SELECT SUM(Number_Of_Positions) FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready), 2) AS percentage
FROM 
  jobs_nyc_postings.jobs_nyc_postings_sql_ready
GROUP BY 
  Posting_Type;
  
 -- 7. WHAT IS THE DISTRIBUTION OF THE JOBS POSTINGS /NUMBER OF POSITIONS BY THE EMPLOYMENT TYPE (FULL-TIME/PART-TIME), Percentage of whole ?

-- Part one Job Postings

SELECT 
  Full_Time_Part_Time_Indicator,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready), 2) AS percentage
FROM 
jobs_nyc_postings.jobs_nyc_postings_sql_ready
GROUP BY 
  Full_Time_Part_Time_Indicator;
  
  -- Part two Number of Positions
 SELECT 
  Full_Time_Part_Time_Indicator,
  ROUND(SUM(Number_Of_Positions) * 100.0 / 
        (SELECT SUM(Number_Of_Positions) FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready), 2) AS percentage
FROM 
  jobs_nyc_postings.jobs_nyc_postings_sql_ready
GROUP BY 
  Full_Time_Part_Time_Indicator;

 
 -- 8. HOW DOES THE DISTRIBUTION OF THE JOB POSTINGS LOOK LIKE BY THE LOCATION (map) ? 
 
SELECT 
  Work_Location,
  COUNT(*) AS location_count
FROM 
  jobs_nyc_postings.jobs_nyc_postings_sql_ready
GROUP BY 
  Work_Location
ORDER BY 
  location_count DESC;
 
 
 -- 9. WHAT IS THE DISTRIBUTION OF JOB POSTINGS BY THE AGENCIES (TOP 10) ?
  SELECT 
  Agency,
  COUNT(*) AS frequency
FROM 
  jobs_nyc_postings.jobs_nyc_postings_sql_ready
  GROUP BY 
  Agency
ORDER BY 
  frequency DESC
LIMIT 10;
 

-- 10. WHAT IS THE DISTRIBUTION OF THE JOB POSTING BY THE CIVIL SERVICE TITTLE ?

SELECT
  Civil_Service_Title,
  COUNT(*) AS frequency
FROM 
  jobs_nyc_postings.jobs_nyc_postings_sql_ready
  GROUP BY 
  Civil_Service_Title
ORDER BY 
  frequency DESC
LIMIT 10;
 
 -- 11.  WHAT IS THE DISTRIBUTION OF THE JOBS POSTINGS /NUMBER OF POSITIONS BY THE JOB CATEGORY ? 
 
SELECT 
    Job_Category,
    COUNT(*) AS `Number of Postings`,
    ROUND(COUNT(*) * 100.0 / (SELECT 
                    COUNT(*)
                FROM
                    jobs_nyc_postings.jobs_nyc_postings_sql_ready),
            2) AS `Percentage of Whole (Postings)`,
    SUM(Number_Of_Positions) AS `Number of Positions`,
    ROUND(SUM(Number_Of_Positions) * 100.0 / (SELECT 
                    SUM(Number_Of_Positions)
                FROM
                    jobs_nyc_postings.jobs_nyc_postings_sql_ready),
            2) AS `Percentage of Whole (Positions)`
FROM
    jobs_nyc_postings.jobs_nyc_postings_sql_ready
GROUP BY Job_Category
ORDER BY `Number of Postings` DESC;
 

 -- 12. WHAT IS THE DISTRIBUTION OF THE JOBS POSTINGS /NUMBER OF POSITIONS BY THE SALARY BRACKETS ?
 SELECT 
  
  Salary_Brackets,
  COUNT(*) AS `Number of Postings`,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM   jobs_nyc_postings.jobs_nyc_postings_sql_ready), 2) AS `Percentage of Whole (Postings)`,
  SUM(Number_Of_Positions) AS `Number of Positions`,
  ROUND(SUM(Number_Of_Positions) * 100.0 / 
        (SELECT SUM(Number_Of_Positions) FROM   jobs_nyc_postings.jobs_nyc_postings_sql_ready), 2) AS `Percentage of Whole (Positions)`
FROM 
    jobs_nyc_postings.jobs_nyc_postings_sql_ready
GROUP BY 
  Salary_Brackets
ORDER BY 
  `Salary_Brackets` ASC;
 
 
 
 -- 13. WHAT IS THE DISTRIBUTION OF THE JOBS POSTINGS /NUMBER OF POSITIONS BY THE CAREER LEVEL, as a percentage of whole ?
 
 -- Part one Job Postings
 
 SELECT 
  Career_Level,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready), 2) AS percentage
FROM 
jobs_nyc_postings.jobs_nyc_postings_sql_ready
GROUP BY 
  Career_Level;
  
  -- Part two Number of Positions
  
  SELECT 
  Career_Level,
  ROUND(SUM(Number_Of_Positions) * 100.0 / 
        (SELECT SUM(Number_Of_Positions) FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready), 2) AS percentage
FROM 
  jobs_nyc_postings.jobs_nyc_postings_sql_ready
GROUP BY 
  Career_Level;
 
