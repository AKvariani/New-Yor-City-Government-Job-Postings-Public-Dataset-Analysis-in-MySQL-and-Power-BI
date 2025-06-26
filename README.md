# New-Yor-City-Government-Job-Postings-Public-Dataset-Analysis-in-MySQL-and-Power-BI
This project uses MySQL for cleaning and analyzing NYC government job postings and Power BI for interactive dashboards with key metrics and trends.


**Project Overview**
The project is structured in four parts and aims to conduct an exploratory analysis of New York City government job postings. It leverages advanced data cleaning and transformation techniques in MySQL and presents insights through a Power BI dashboard with interactive visualizations.
________________________________________
**Source**
The database was accessed on the DATA.GOV government website, link: https://catalog.data.gov/dataset/nyc-jobs 
Accessed on 5/31/2025.
________________________________________

**1. Preparation of the CSV File for MySQL Import**
•	Columns used:

B (Agency), C (Posting Type), D (# Of Positions), F (Civil Service Title), J (Job Category), K (Full-Time/Part-Time Indicator), L (Career Level), M (Salary Range From), N (Salary Range To), O (Salary Frequency), P (Work Location), AA (Posting Date)

•	Columns removed:
A (Job ID), E (Business Title), G (Title Classification), H (Title Code No), I (Level), Q–AD (Additional job description and contact details)

•	Columns renamed:
Posting_Type, Number_Of_Positions, Civil_Service_Title, Job_Category, Full-Time_Part-Time_Indicator, Career_Level, Salary_Range_From, Salary_Range_To, Salary_Frequency, Work_Location, Posting_Date

•	File renamed to:
"Jobs_NYC_Postings_SQL_Ready"
________________________________________
**2. Data Cleaning and Transformation in MySQL**

•	Remove duplicates: Using GROUP BY, HAVING, and DELETE statements

•	Handle null/missing values: WHERE IS NULL, UPDATE, SET

•	Normalize values in Full-Time/Part-Time Indicator: Change 'F' to 'Full-Time' and 'P' to 'Part-Time'

•	Standardize salary frequency and remove the column: CASE WHEN, ALTER TABLE DROP COLUMN

•	Create salary brackets: Use 11 defined salary ranges via CASE statements

•	Group job categories into 14 main groups: Using LIKE, UPDATE, SELECT DISTINCT
________________________________________
**3. Data Analysis in MySQL**

•	Overall metrics:

•	Total job postings: COUNT(*)

•	Total number of positions: SUM(Number_Of_Positions)

•	Time range covered in dataset: MIN(Posting_Date) / MAX(Posting_Date)

•	Time-series analysis:

•	Monthly trend of job postings and positions hired: DATE_FORMAT(), GROUP BY, ORDER BY

•	Categorical distributions:

•	Posting type, employment type, location

•	Top 10 agencies and civil service titles

•	Job categories, salary brackets, career level

•	Percentages of distributions calculated using nested SELECT COUNT()/SUM() queries
________________________________________
**4. Power BI Dashboard Development**
•	KPI Cards:
o	Total job postings

o	Total positions hired

o	First posting date

•	Time-based visualizations:

o	Line charts for monthly trends in postings and positions hired

•	Distributions:

o	Pie charts for posting types, employment types, and career level

o	Maps for job posting locations

o	Bar charts for top agencies and titles

o	Tables showing breakdowns by job category and salary bracket with counts and % of total

________________________________________
**5. Project Files**

Below is a list of files included in this project. To run the analysis script, please download the files and adjust the file paths accordingly. Otherwise, a PDF version of the output results is available for review.


•	**Jobs_NYC_Postings_Original.csv** - The original raw dataset of NYC government job postings (CSV)

•	**Jobs_NYC_Postings_SQL_Ready.csv** -  Formatted CSV file prepared for MySQL import

• **Data_Cleaning_and_Transformation.sql** - MySQL script for data cleaning, normalization, and transformation

•	**Jobs_NYC_Postings_Cleaned.csv** -Exported dataset after cleaning and processing in MySQL

• **Data_Analysis_and_Visualization.sql** - MySQL script containing analysis queries used to generate insights and prepare data for visualization

• **Data_Visualisation_Queries** - Folder with Excel files exported from MySQL query results, used as source data for Power BI

• **Jobs_NYC_Final_PoweBI_Report.pbix** - Power BI project file containing the interactive dashboard and visualizations

• **Jobs_NYC_Final_PoweBI_Report.pdf** -  PDF export of the Power BI dashboard for offline viewing

• **README.pdf** - PDF version of the project README with documentation and instructions
