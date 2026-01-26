-- SQL Query 1: Top job functions by cases and positions (FY2024)

USE h1b_rps;

SELECT
soc_title,
COUNT(*) AS total_cases, -- total sponsorship activity (cases)
ROUND(SUM(total_worker_positions), 0) AS total_positions, -- total headcount demand (positions)
ROUND(AVG(annual_wage), 0) AS avg_annual_wage,
ROUND(AVG(col_adjusted_wage), 0) AS avg_col_adj_wage
FROM v_wage_standardized
WHERE decision_date >= '2023-10-01'
	AND decision_date < '2025-01-01'
AND is_full_time_position = 1
AND is_willful_violator = 0
GROUP BY soc_title
HAVING COUNT(*) >= 50
ORDER BY total_positions DESC, total_cases DESC
LIMIT 15;

-- SQL Query 2A: Top H1-B sponsoring states

USE h1b_rps;

SELECT
v.state_name,
COUNT(*) AS total_cases,  -- total LCA filings
ROUND(SUM(v.total_worker_positions), 0) AS total_positions,  -- headcount demand
ROUND(AVG(v.annual_wage), 0) AS avg_nominal_wage,  -- unadjusted annual salary
    	ROUND(AVG(v.col_adjusted_wage), 0) AS avg_col_adj_wage  -- cost-of-living adjusted salary
FROM v_wage_standardized v
WHERE v.decision_date >= '2023-10-01'
AND v.decision_date < '2025-01-01'
AND v.is_full_time_position = 1
GROUP BY v.state_name
HAVING COUNT(*) > 50
ORDER BY total_positions DESC
LIMIT 15;

-- SQL Query 2B: Geographic concentration of H-1B job functions by state

USE h1b_rps;

SELECT
V.soc_title,
V.state_name,
COUNT(*) AS total_cases,  -- total sponsorship activity (cases)
ROUND(SUM(v.total_worker_positions), 0) AS total_positions,  -- total headcount demand (positions)
ROUND(AVG(v.annual_wage), 0) AS avg_nominal_wage,
ROUND(AVG(v.col_adjusted_wage), 0) AS avg_col_adj_wage
FROM v_wage_standardized v
WHERE v.decision_date >= '2023-10-01'
	AND v.decision_date <  '2025-01-01'
AND v.is_full_time_position = 1
GROUP BY v.soc_title, v.state_name
HAVING COUNT(*) >= 50
ORDER BY total_positions DESC, avg_nominal_wage DESC
LIMIT 200;

-- SQL Query 2C: Geographic concentration of H-1B job functions by city

USE h1b_rps;

SELECT
v.soc_title,
v.city_name,
v.state_name,
COUNT(*) AS total_cases, -- total sponsorship activity (cases)
ROUND(SUM(v.total_worker_positions), 0) AS total_positions, -- total headcount demand (positions)
ROUND(AVG(v.annual_wage), 0) AS avg_nominal_wage, -- Unadjusted pay as per LCA data
ROUND(AVG(v.col_adjusted_wage), 0) AS avg_col_adj_wage -- COL-adjusted pay with data from the BEA
FROM v_wage_standardized v
WHERE v.decision_date >= '2023-10-01'
AND v.decision_date <  '2025-01-01'
AND v.is_full_time_position = 1
AND v.is_willful_violator = 0
AND v.col_adjusted_wage IS NOT NULL
AND v.annual_wage IS NOT NULL
GROUP BY v.soc_title, v.city_name, v.state_name
HAVING COUNT(*) >= 25
ORDER BY total_positions DESC, avg_nominal_wage DESC
LIMIT 250;

-- SQL Query 3A: MBAN target roles: share of total H-1B market (FY2024)

USE h1b_rps;

SELECT
'MBAN Target Roles' AS role_group, --  IT Project Managers, Business Intelligence Analysts and Financial and Investment Analysts
COUNT(*) AS total_cases,
ROUND(SUM(v.total_worker_positions), 0) AS total_positions,
ROUND(AVG(v.annual_wage), 0) AS avg_nominal_wage,
ROUND(AVG(v.col_adjusted_wage), 0) AS avg_col_adj_wage,
ROUND( 
COUNT(*) * 100.0 / (
SELECT COUNT(*) 
FROM v_wage_standardized 
WHERE decision_date >= '2023-10-01' 
AND decision_date < '2025-01-01'), 2) 
AS percent_of_total_cases
FROM v_wage_standardized v
WHERE v.decision_date >= '2023-10-01'
AND v.decision_date < '2025-01-01'
AND v.is_full_time_position = 1
AND v.is_willful_violator = 0
AND v.soc_title IN (
'Information Technology Project Managers',
'Business Intelligence Analysts',
'Financial and Investment Analysts');

-- SQL Query 3B: MBAN target roles: descriptive analysis of the salaries for given roles

USE h1b_rps;

SELECT
v.soc_title,
COUNT(*) AS total_cases,
ROUND(SUM(v.total_worker_positions), 0) AS total_positions,
ROUND(AVG(v.annual_wage), 0) AS avg_nominal_wage,
ROUND(STDDEV(v.annual_wage), 0) AS std_nominal_wage,
ROUND(MIN(v.annual_wage), 0) AS min_nominal_wage,
ROUND(MAX(v.annual_wage), 0) AS max_nominal_wage,
ROUND(AVG(v.col_adjusted_wage), 0) AS avg_col_adj_wage,
ROUND(STDDEV(v.col_adjusted_wage), 0) AS std_col_adj_wage
FROM v_wage_standardized v
WHERE v.decision_date >= '2024-01-01'
AND v.decision_date <  '2025-01-01'
AND v.is_full_time_position = 1
AND v.is_willful_violator = 0
AND v.soc_title IN (
      	'Information Technology Project Managers',
      	'Business Intelligence Analysts',
      	'Financial and Investment Analysts')
GROUP BY v.soc_title
HAVING COUNT(*) >= 100
ORDER BY total_positions DESC, avg_col_adj_wage DESC;

-- SQL Query 4: Geographic concentration and wage patterns for MBAN target roles
SELECT
v.soc_title,
v.state_name,
COUNT(*) AS total_cases,
ROUND(SUM(v.total_worker_positions), 0) AS total_positions,
ROUND(AVG(v.annual_wage), 0) AS avg_nominal_wage,
ROUND(AVG(v.col_adjusted_wage), 0) AS avg_col_adj_wage
FROM v_wage_standardized v
WHERE v.decision_date >= '2022-01-01' AND v.decision_date < '2025-01-01'
AND v.soc_title IN (
'Information Technology Project Managers',
'Business Intelligence Analysts',
'Financial and Investment Analysts')
GROUP BY  v.soc_title, v.state_name
HAVING COUNT(*) >= 20
ORDER BY v.soc_title, total_positions DESC;

-- SQL Query 5: Top employers sponsoring chosen MBAN target roles
SELECT
v.employer_name,
v.soc_title,
COUNT(*) AS total_cases,
ROUND(SUM(v.total_worker_positions), 0) AS total_positions,
ROUND(AVG(v.annual_wage), 0) AS avg_nominal_wage,         
ROUND(AVG(v.col_adjusted_wage), 0) AS avg_col_adj_wage        
FROM v_wage_standardized v
WHERE v.decision_date >= '2023-10-01'
AND v.decision_date < '2025-01-01'
AND v.is_full_time_position = 1
AND v.is_willful_violator = 0
AND v.soc_title IN (
        		'Information Technology Project Managers',
        		'Business Intelligence Analysts',
        		'Financial and Investment Analysts')
GROUP BY v.employer_name, v.soc_title
HAVING COUNT(*) >= 20
ORDER BY total_positions DESC, avg_nominal_wage DESC
LIMIT 20;
