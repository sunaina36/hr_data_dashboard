--CREATING THE DATABASE AND USING IT
CREATE DATABASE hr
USE hr;

--VIEWING THE TABLE hr_data FROM THE DATABASE
SELECT * 
FROM hr_data;

--VIEWING THE termdate COLUMN 
SELECT termdate
FROM hr_data
ORDER BY termdate DESC;

--CONVERTING THE VALUES of termdate IN DATETIME AND FORMATING IT...CONVERTING THE termdate to yyyy-MM-dd
UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');

--CHANGING THE DATATYPE OF THE COLUMN from NVARCHAR TO DATE
ALTER table hr_data
ALTER COLUMN termdate DATE;

--ADDING THE NEW COLUMN age
ALTER table hr_data
ADD age INT;

--CALCULATING THE AGE THROUGH BIRTHDATE
UPDATE hr_data 
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

--VIEWING THE AGE COLUMN
SELECT age
FROM hr_data;

--COUNTING THE NUMBER OF ROWS IN TABLE
SELECT COUNT(*)
FROM hr_data;

--QUESTIONS TO ANSWER FROM DATA

--1) WHAT"S THE AGE DISTRIBUTION IN COMPANY?
-- age distribution
SELECT MIN(age) AS youngest, MAX(age) AS oldest
FROM hr_data;

SELECT age_group ,
COUNT(*) AS mycount
FROM
(SELECT CASE
	WHEN age >=21 AND age <=30 THEN '21 to 30'
	WHEN age >=31 AND age <=40 THEN '31 to 40'
	WHEN age >=41 AND age <=50 THEN '41 to 50'
	ELSE '50+'
	END AS age_group
FROM hr_data
WHERE termdate IS NULL) AS subquery
GROUP BY age_group
ORDER BY age_group

--age distribution by gender
SELECT age_group , gender,
COUNT(*) AS mycount
FROM
(SELECT CASE
	WHEN age >=21 AND age <=30 THEN '21 to 30'
	WHEN age >=31 AND age <=40 THEN '31 to 40'
	WHEN age >=41 AND age <=50 THEN '41 to 50'
	ELSE '50+'
	END AS age_group, gender
FROM hr_data
WHERE termdate IS NULL) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender


--2) WHAT's THE GENDER BREAKDOWN IN COMPANY?
SELECT gender, COUNT(gender)
FROM hr_data
WHERE termdate IS NULL
GROUP BY gender
ORDER BY GENDER;

--3) HOW DOES GENDER VARY ACROSS DEPARTMENT AND JOB TITLE?
--BY DEPARTMENT
SELECT department, gender, COUNT(gender)
FROM hr_data
WHERE termdate IS NULL
GROUP BY DEPARTMENT, gender 
ORDER BY DEPARTMENT, GENDER ASC;

--BY JOB TITLE
SELECT department,jobtitle, gender, COUNT(gender)
FROM hr_data
WHERE termdate IS NULL
GROUP BY DEPARTMENT, jobtitle, gender 
ORDER BY DEPARTMENT, jobtitle, GENDER ASC;

--4) WHAT'S THE RACE DISTRIBUTION IN COMPANY?
SELECT race, COUNT(id) as race_count
FROM hr_data
WHERE termdate IS NULL
GROUP BY race
ORDER BY race_count DESC;

--5) WHAT'S THE AVERAGE LENGTH OF EMPLOYMENT IN COMPANY?
SELECT 
AVG(DATEDIFF(year, hire_date, termdate)) as tenure
FROM hr_data
WHERE termdate IS NOT NULL AND termdate <= GETDATE();

--6) WHICH DEPARTMENT HAS HIGHEST TURNOVER RATE?
--get total count
--get terinated count
--terinated count/ total count
SELECT department, 
 total_count, 
terminated_count,
ROUND((CAST(terminated_count AS FLOAT)/total_count), 2)*100 AS turnover_rate
FROM
    (SELECT department, 
	COUNT(*) AS total_count,
	SUM(CASE
		WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 ELSE 0
		END
		) AS terminated_count
	FROM hr_data
	GROUP BY department
	) AS subquery
ORDER BY turnover_rate DESC;

--7) WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT?
SELECT department,
AVG(DATEDIFF(year, hire_date, termdate)) as tenure
FROM hr_data
WHERE termdate IS NOT NULL AND termdate <= GETDATE()
GROUP BY department
ORDER BY tenure DESC;

--8) HOW MANY EMPLOYEES WORK REMOTELY FOR EACH DEPARTMENT?
SELECT location, count(*) as count
FROM hr_data
WHERE termdate IS NULL
GROUP BY location;

--9) WHAT'S THE DISTRIBUTION OF EMPLOYEES ACROSS DIFFERENT STATES?
SELECT location_state, COUNT(location_state) as state_count
FROM hr_data
WHERE termdate IS NULL
GROUP BY location_state
ORDER BY state_count DESC;

--10) HOW ARE JOB TITLES DISTRIBUTED IN THE COMPANY?
SELECT jobtitle, COUNT(jobtitle) as count
FROM hr_data
WHERE termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;

--11) HOW HAVE EMPLOYEE HIRE COUNTS VARIED OVER TIME?
--CALCULATE HIRES
--CALCULATE TERMINATION
--(HIRES - TERMINATION)/HIRES PERCENT HIRE CHANGE
SELECT hire_year,
hires,
terminations,
hires - terminations AS net_change,
ROUND(CAST(hires - terminations AS FLOAT)/hires,2)* 100 AS percent_hire_change
FROM
    (SELECT YEAR(hire_date) as hire_year,
	COUNT(*) AS hires,
	SUM(CASE
			WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 ELSE 0
			END
			) AS terminations
	FROM hr_data
	GROUP BY YEAR(hire_date)
	) AS subquery
ORDER BY percent_hire_change ASC;

