-- DATA CLEANING AND TRANSFORMATION


-- THIS IS ALL OF OUR DATA PRIOR TO CLEANING AND TRANSFORMATION IN SQL
SELECT * 
FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready;

-- DATA CLEANING




-- 1. REMOVING DUPLICATES

-- SCRIPT TO CHECK FOR DUPLICATES IT HAS RETURNED MULTIPLE ROWS TO BE DELETED
SELECT 
    *,
    COUNT(*) AS DuplicateCount
FROM 
    jobs_nyc_postings.jobs_nyc_postings_sql_ready
GROUP BY 
    JOB_ID, Agency, Posting_Type, Number_Of_Positions, Civil_Service_Title, 
    Job_Category, Full_Time_Part_Time_Indicator, Career_Level, 
    Salary_Range_From, Salary_Range_To, Salary_Frequency, 
    Work_Location, Posting_Date
HAVING 
    COUNT(*) > 1;
    
-- LETS SAVE ALL DUPLICATES TO BE DELETED BY THEIR UNIQUE JOB_ID Identifier, count 23. unique ID's : 712525, 715535, 704029, 636266, 708588, 709987, 705333, 696004, 615081, 713627, 709263, 699949, 709268, 688194, 612421, 679284, 702699, 627043, 715433, 714967, 697212, 628242, 710396) 
-- NOW LETS DELETE ALL DUPLICATES USING THEIR UNIQUE JOB_ID
DELETE FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready
WHERE Job_ID IN (712525, 715535, 704029, 636266, 708588, 709987, 
705333, 696004, 615081, 713627, 709263, 699949, 709268, 688194, 
612421, 679284, 702699, 627043, 715433, 714967, 697212, 628242, 710396);

-- ALL DUPLICATES HAVE BEEN REMOVED, WE CAN DOUBLE CHECK BY RUNNING THE QUERY WHICH IDENTIFIES THE DUPLICATES - IT WILL RETURN NOTHING





-- 2. HANDLE THE NULL/MISSING VALUES

-- LOOK FOR THE NULL/MISSING VALUES/OUTLIERS

SELECT *
FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready
WHERE Agency IS NULL OR Agency = ''
   OR Posting_Type IS NULL OR Posting_Type = ''
   OR Number_Of_Positions IS NULL OR Number_Of_Positions = ''
   OR Civil_Service_Title IS NULL OR Civil_Service_Title = ''
   OR Job_Category IS NULL OR Job_Category = ''
   OR Full_Time_Part_Time_Indicator IS NULL OR Full_Time_Part_Time_Indicator = ''
   OR Career_Level IS NULL OR Career_Level = ''
   OR Salary_Range_From IS NULL OR Salary_Range_From = ''
   OR Salary_Range_To IS NULL OR Salary_Range_To = ''
   OR Salary_Frequency IS NULL OR Salary_Frequency = ''
   OR Work_Location IS NULL OR Work_Location = ''
   OR Posting_Date IS NULL OR Posting_Date = '';

-- After running the query above to look for the NULL and Missing values we see that there are three rows where Salary_Range_From = '0', 
-- Instead of Removing those rows Lets will in the values for "Salary_Range_From" Column with the values from "Salary_Range_To" Column, If values are equel to 0.
-- This should be the best resolution for our purposes. 

UPDATE jobs_nyc_postings.jobs_nyc_postings_sql_ready
SET Salary_Range_From = Salary_Range_To
WHERE Salary_Range_From = 0;

-- We have updated the tree rows with the value '0' in one of the columns.
-- Now when running the previous query, no null or missing values will be returned.



-- 3. RENAME 'F' TO 'Full-Time' AND 'P' TO 'Part-Time' IN "Full_Time_Part_Time_Indicator" COLUMN

UPDATE jobs_nyc_postings.jobs_nyc_postings_sql_ready
SET Full_Time_Part_Time_Indicator = 
  CASE 
    WHEN Full_Time_Part_Time_Indicator = 'F' THEN 'Full-Time'
    WHEN Full_Time_Part_Time_Indicator = 'P' THEN 'Part Time'
  END;
  
  
  
  -- 4. UNIFY THE FREEQUENCIES IN THE "Salary_Freequency" Column and remove the column  
  
  -- FOR OUR ANALYSIS IN THE COLUMN "Salary_Freequency", WE NEED ALL VALUES TO BE 'Annual' INSTEAD OF 'Annual' / 'Hourly'. 
-- WE WILL NED TO CHANGE ALL 'HOURLY' VALUES TO 'Annual' AND MODIFY THE ROWS WHERE THOSE VALUES ARE STORED APPROPRIATELY.

-- FOR THE ROWS WHERE WE HAVE Column "Salary_Freequency" has value 'Hourly' AND  COLUMN "Full_Time_Part_Time_Indicator" HAS VALUE 'Part-Time'
-- WE WILL MULTIPLY THE VALUES IN COLUMNS "Salary_Range_From" AND "Salary_Range_To" BY THE NUMBER  1080 - THE NUMBER OF HOURS IN A YEAR FOR PART-TIME WORK WEEK (20HRS X 54 WEEKS)

-- FOR THE ROWS WHERE WE HAVE Column "Salary_Freequency" has value 'Hourly' AND  COLUMN "Full_Time_Part_Time_Indicator" HAS VALUE 'Full-Time'
-- WE WILL MULTIPLY THE VALUES IN COLUMNS "Salary_Range_From" AND "Salary_Range_To" BY THE NUMBER  2160 - THE NUMBER OF HOURS IN A YEAR FOR PART-TIME WORK WEEK (40HRS X 54 WEEKS)
 
 -- All VALUES IN COLUMN "Salary_Freequency" WILL BE 'Annual'

-- THIS IS THE QUERY TO DO SO:

UPDATE jobs_nyc_postings.jobs_nyc_postings_sql_ready
SET 
    Salary_Range_From = 
        CASE 
            WHEN Full_Time_Part_Time_Indicator = 'Part-Time' THEN Salary_Range_From * 1080
            WHEN Full_Time_Part_Time_Indicator = 'Full-Time' THEN Salary_Range_From * 2160
            ELSE Salary_Range_From
        END,
    Salary_Range_To = 
        CASE 
            WHEN Full_Time_Part_Time_Indicator = 'Part-Time' THEN Salary_Range_To * 1080
            WHEN Full_Time_Part_Time_Indicator = 'Full-Time' THEN Salary_Range_To * 2160
            ELSE Salary_Range_To
        END,
    Salary_Frequency = 'Annual'
WHERE Salary_Frequency = 'Hourly';

-- THE QUERY HAS WORKED, NOW ALL SALARY FREEQUENCIES ARE UNIFIED AS ANNUAL, AND SALARY AMOUNTS HAVE BEEN UPDATED APPROPRIATELY. \
-- WE CAN DELETE "Salary_Freequency" COLUM
ALTER TABLE jobs_nyc_postings.jobs_nyc_postings_sql_ready
DROP COLUMN Salary_Frequency;


-- 5. ASSIGN ALL INDIVIDUAL SALARY RANGES INTO 11 SALARY Brackets
-- BRASKETS WILL BE DEFINED AS: Less than $ 30 000, $ 30 000 - $ 35 000, $ 35 000 - $ 45 000, $ 45 000 - $ 55 000, $ 55 000 - $ 65 000, 
-- $ 65 000 - $ 75 000, $ 75 000 - $ 85 000, $ 85 000 -$ 100 000, $ 100 000 - $ 120 000, $ 120 000 - $ 140 000, More than $ 140 000.
-- FIRST LETS CREATE AN EXTRA COLUMN CALLED "Salary_Brackets", VERIFY THE ACURACY ONCE THE COLUMN IS POPULATED WITH THE VALUES AND REMOVE "Salary_Range_From" AND "Salary_Range_TO" COLUMNS FROM THE SHEET

-- Add the new column (only run this once)
ALTER TABLE jobs_nyc_postings.jobs_nyc_postings_sql_ready ADD COLUMN Salary_Brackets VARCHAR(50);

-- Update the Salary_Brackets column based on salary range logic
UPDATE jobs_nyc_postings.jobs_nyc_postings_sql_ready
SET Salary_Brackets = 
    CASE
        -- Exact fits: both FROM and TO fall within one bracket
        WHEN Salary_Range_From < 30000 AND Salary_Range_To <= 30000 THEN 'Less than $ 30 000'
        WHEN Salary_Range_From >= 30000 AND Salary_Range_To <= 35000 THEN '$ 30 000 - $ 35 000'
        WHEN Salary_Range_From >= 35000 AND Salary_Range_To <= 45000 THEN '$ 35 000 - $ 45 000'
        WHEN Salary_Range_From >= 45000 AND Salary_Range_To <= 55000 THEN '$ 45 000 - $ 55 000'
        WHEN Salary_Range_From >= 55000 AND Salary_Range_To <= 65000 THEN '$ 55 000 - $ 65 000'
        WHEN Salary_Range_From >= 65000 AND Salary_Range_To <= 75000 THEN '$ 65 000 - $ 75 000'
        WHEN Salary_Range_From >= 75000 AND Salary_Range_To <= 85000 THEN '$ 75 000 - $ 85 000'
        WHEN Salary_Range_From >= 85000 AND Salary_Range_To <= 100000 THEN '$ 85 000 -$ 100 000'
        WHEN Salary_Range_From >= 100000 AND Salary_Range_To <= 120000 THEN '$ 100 000 - $ 120 000'
        WHEN Salary_Range_From >= 120000 AND Salary_Range_To <= 140000 THEN '$ 120 000 - $ 140 000'
        WHEN Salary_Range_From > 140000 THEN 'More than $ 140 000'

        -- Overlapping ranges: choose the bracket with most overlap
        WHEN Salary_Range_From < 30000 AND Salary_Range_To > 30000 AND Salary_Range_To <= 35000 THEN '$ 30 000 - $ 35 000'
        WHEN Salary_Range_From < 35000 AND Salary_Range_To > 35000 AND Salary_Range_To <= 45000 THEN '$ 35 000 - $ 45 000'
        WHEN Salary_Range_From < 45000 AND Salary_Range_To > 45000 AND Salary_Range_To <= 55000 THEN '$ 45 000 - $ 55 000'
        WHEN Salary_Range_From < 55000 AND Salary_Range_To > 55000 AND Salary_Range_To <= 65000 THEN '$ 55 000 - $ 65 000'
        WHEN Salary_Range_From < 65000 AND Salary_Range_To > 65000 AND Salary_Range_To <= 75000 THEN '$ 65 000 - $ 75 000'
        WHEN Salary_Range_From < 75000 AND Salary_Range_To > 75000 AND Salary_Range_To <= 85000 THEN '$ 75 000 - $ 85 000'
        WHEN Salary_Range_From < 85000 AND Salary_Range_To > 85000 AND Salary_Range_To <= 100000 THEN '$ 85 000 -$ 100 000'
        WHEN Salary_Range_From < 100000 AND Salary_Range_To > 100000 AND Salary_Range_To <= 120000 THEN '$ 100 000 - $ 120 000'
        WHEN Salary_Range_From < 120000 AND Salary_Range_To > 120000 AND Salary_Range_To <= 140000 THEN '$ 120 000 - $ 140 000'
        WHEN Salary_Range_From < 140000 AND Salary_Range_To > 140000 THEN 'More than $ 140 000'

        -- Fallback: if range spans multiple brackets widely
        ELSE 'More than $ 140 000'
    END;
    
    -- SO FAR THE NEW COLUMNS AND ASSIGNED VALUES LOOK GOOD, NOW WE CAN DELETE THE COLUMNS "Salary_Range_From" AND "Salary_Range_To" AS WE WON'T NEED THEM
    
    ALTER TABLE jobs_nyc_postings.jobs_nyc_postings_sql_ready
DROP COLUMN Salary_Range_From,
DROP COLUMN Salary_Range_To;


-- 6. Consolidate Job Categories into 14 main categories: 'Administration & Human Resources', 'Building Operations & Maintanence', 'Communications & Intergovermental Affairs', 
-- 'Constituent Services and Community Programs', 'Engineering, Architecture, and Planning', 'Finanace, Accounting, and Procurement', 'Green Jobs',
-- 'Health', 'Legal Affairs' 'Mental Health', 'Policy, Research, and Analysis', 'Public Safety, Inspections, & Enforcement' 'Social Services', 'Technology, Data, and Innovation'.

-- There are way more than 13 values in the "Job_Category" Column, if the value contains one of the 13 values mentioned above, it will be shoretened to be same as one of the 13 mentioned above.


UPDATE jobs_nyc_postings.jobs_nyc_postings_sql_ready
SET Job_Category = 
  CASE
    WHEN Job_Category LIKE 'Administration & Human Resources%' THEN 'Administration & Human Resources'
    WHEN Job_Category LIKE 'Building Operations & Maintenance%' THEN 'Building Operations & Maintanence'
    WHEN Job_Category LIKE 'Communications & Intergovernmental Affairs%' THEN 'Communications & Intergovernmental Affairs'
    WHEN Job_Category LIKE 'Constituent Services & Community Programs%' THEN 'Constituent Services and Community Programs'
    WHEN Job_Category LIKE 'Engineering, Architecture, & Planning%' THEN 'Engineering, Architecture, and Planning'
    WHEN Job_Category LIKE 'Finance, Accounting, & Procurement%' THEN 'Finace, Accounting, and Procurement'
    WHEN Job_Category LIKE 'Green Jobs%' THEN 'Green Jobs'
    WHEN Job_Category LIKE 'Health%' THEN 'Health'
    WHEN Job_Category LIKE 'Legal Affairs%' THEN 'Legal Affairs'
    WHEN Job_Category LIKE 'Mental Health%' THEN 'Mental Health'
    WHEN Job_Category LIKE 'Policy, Research & Analysis%' THEN 'Policy, Research, and Analysis'
    WHEN Job_Category LIKE 'Public Safety, Inspections, & Enforcement%' THEN 'Public Safety, Inspections, & Enforcement'
    WHEN Job_Category LIKE 'Social Services%' THEN 'Social Services'
    WHEN Job_Category LIKE 'Technology, Data & Innovation%' THEN 'Technology, Data & Innovation'
    ELSE Job_Category  -- keep original if it doesn’t match
  END;


-- Now Lets check if we have 14 unique values in our 'Job_Category' Column
  SELECT DISTINCT Job_Category 
FROM jobs_nyc_postings.jobs_nyc_postings_sql_ready;

-- YES, so we successfuly consolidated all of our values









 
