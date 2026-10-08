
-- U.S. Unemployment Trends SQL Analysis
-- Data Source: U.S. Bureau of Labor Statistics (BLS)
-- Coverage: 50 U.S. States, 1976-2025
-- Database: US_Unemployment_Analysis.db


-- QUERY 1: Top 10 Highest Unemployment Rates (2025)

SELECT
    state,
    CAST(unemployment_rate AS REAL) AS unemployment_rate
FROM unemployment_data
WHERE CAST(year AS INTEGER) = 2025
ORDER BY unemployment_rate DESC
LIMIT 10;


-- QUERY 2: Average, Minimum, and Maximum Rates (2025)

SELECT
    ROUND(AVG(CAST(unemployment_rate AS REAL)), 2)
        AS average_rate,
    MIN(CAST(unemployment_rate AS REAL))
        AS minimum_rate,
    MAX(CAST(unemployment_rate AS REAL))
        AS maximum_rate
FROM unemployment_data
WHERE CAST(year AS INTEGER) = 2025;


-- QUERY 3: States Above Average Unemployment (2025)

SELECT
    state,
    CAST(unemployment_rate AS REAL) AS unemployment_rate
FROM unemployment_data
WHERE CAST(year AS INTEGER) = 2025
AND CAST(unemployment_rate AS REAL) > (
    SELECT AVG(CAST(unemployment_rate AS REAL))
    FROM unemployment_data
    WHERE CAST(year AS INTEGER) = 2025
)
ORDER BY unemployment_rate DESC;


-- QUERY 4: Unemployment Trends (2016-2025)

SELECT
    CAST(year AS INTEGER) AS year,
    ROUND(AVG(CAST(unemployment_rate AS REAL)), 2)
        AS average_unemployment_rate
FROM unemployment_data
WHERE CAST(year AS INTEGER) BETWEEN 2016 AND 2025
GROUP BY CAST(year AS INTEGER)
ORDER BY year;


-- QUERY 5: Year-over-Year Unemployment Changes

WITH yearly_averages AS (
    SELECT
        CAST(year AS INTEGER) AS year,
        AVG(CAST(unemployment_rate AS REAL)) AS avg_rate
    FROM unemployment_data
    GROUP BY CAST(year AS INTEGER)
)
SELECT
    year,
    ROUND(avg_rate, 2) AS unemployment_rate,
    ROUND(
        avg_rate - LAG(avg_rate) OVER (ORDER BY year),
        2
    ) AS yoy_change
FROM yearly_averages
WHERE year BETWEEN 2016 AND 2025
ORDER BY year;


-- QUERY 6: Rank States by Unemployment Rate (2025)

SELECT
    state,
    CAST(unemployment_rate AS REAL) AS unemployment_rate,
    RANK() OVER (
        ORDER BY CAST(unemployment_rate AS REAL) DESC
    ) AS unemployment_rank
FROM unemployment_data
WHERE CAST(year AS INTEGER) = 2025
ORDER BY unemployment_rank;


-- QUERY 7: Compare 2019 vs. 2025 Unemployment

SELECT
    a.state,
    CAST(a.unemployment_rate AS REAL) AS rate_2019,
    CAST(b.unemployment_rate AS REAL) AS rate_2025,
    ROUND(
        CAST(b.unemployment_rate AS REAL) -
        CAST(a.unemployment_rate AS REAL), 2
    ) AS rate_change
FROM unemployment_data a
INNER JOIN unemployment_data b
    ON a.state = b.state
WHERE CAST(a.year AS INTEGER) = 2019
AND CAST(b.year AS INTEGER) = 2025
ORDER BY rate_change DESC;


-- QUERY 8: Labor Force Segmentation (2025)

WITH labor_force_groups AS (
    SELECT
        state,
        CAST(labor_force AS INTEGER) AS labor_force,
        CAST(unemployment_rate AS REAL) AS unemployment_rate,
        CASE
            WHEN CAST(labor_force AS INTEGER) >= 5000000
                THEN 'Large'
            WHEN CAST(labor_force AS INTEGER) >= 2000000
                THEN 'Medium'
            ELSE 'Small'
        END AS labor_force_category
    FROM unemployment_data
    WHERE CAST(year AS INTEGER) = 2025
)
SELECT
    labor_force_category,
    COUNT(*) AS number_of_states,
    ROUND(AVG(unemployment_rate), 2)
        AS average_unemployment_rate
FROM labor_force_groups
GROUP BY labor_force_category
ORDER BY average_unemployment_rate DESC;
