SELECT * 
FROM layoffs_copy_2




--Find the year range (which is 2020-2023)
SELECT 
    DISTINCT YEAR(`date`) AS 'Year'
FROM 
    layoffs_copy_2
ORDER BY 1;


--Find the date range
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_copy_2



-- Check for the pandemic layoffs in 1 day
-- The beginning and end of the pandemic (2020-03  and  2022-04)
SELECT 
    company,
    `date`,
    MAX(total_laid_off) AS max_laid_off_in_a_day
FROM 
    layoffs_copy_2
WHERE  
    `date` BETWEEN '2020-03-01' AND '2022-04-01'
GROUP BY 
    company, `date`
ORDER BY 3 DESC;




-- The highest number of daily layoffs in 4 years
SELECT company,
    `date`,
     MAX(total_laid_off) AS max_laid_off_in_a_day
FROM
     layoffs_copy_2
GROUP BY
     company, `date`
ORDER BY 3 DESC;


--The most layoffs during the pandemic period
SELECT
    company,
    `date`,
    SUM(total_laid_off) AS total_laid_off_in_a_day
FROM 
    layoffs_copy_2
WHERE
    `date` BETWEEN '2020-03-01' AND '2022-04-01'
GROUP BY
    company, `date`
ORDER BY 3 DESC;



--The most layoffs in the 4 years period 
SELECT 
    company,
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_copy_2
GROUP BY
    company
ORDER BY 2 DESC;



-- Total layoffs and their distribution during the pandemic period
    SELECT 
        company, 
        `date`, 
        total_laid_off AS total_laid_off_by_period,
        SUM(total_laid_off) OVER (PARTITION BY company) AS total_laid_off_by_company
    FROM 
        layoffs_copy_2
    WHERE 
        `date` BETWEEN '2020-03-01' AND '2022-04-01'
    ORDER BY 
        total_laid_off_by_company DESC,
        company;    




-- Which industry had the most layoffs?
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_copy_2
GROUP BY industry
ORDER BY 2 DESC;


-- Which industries had the most layoffs
SELECT 
    industry,
    SUM(total_laid_off) AS total,
	SUM(total_laid_off) / (SELECT SUM(total_laid_off) FROM layoffs_copy_2) * 100 AS percentage
FROM 
    layoffs_copy_2
WHERE
    industry IS NOT NULL
GROUP BY 
    industry
ORDER BY 3 DESC;




-- Which countries had the most layoffs
SELECT 
    country,
    SUM(total_laid_off) AS total_laid_off,
    SUM(total_laid_off) / (SELECT SUM(total_laid_off) FROM layoffs_copy_2) * 100 AS 'percentage(%)'
FROM
    layoffs_copy_2
GROUP BY
    country
ORDER BY 2 DESC;



-- Yearly layoffs
-- 2023-03-06 is the most recent date, so 2023's values is just the first 2 months!
SELECT 
    YEAR(`date`),
    SUM(total_laid_off) AS total_layoffs
FROM
    layoffs_copy_2
GROUP BY
    YEAR(`date`)
ORDER BY 
    total_layoffs DESC




-- Total layoffs per month and rolling total
WITH Rolling_Total AS (
SELECT 
    SUBSTRING(`date`, 1, 7) AS year_and_month,
  -- (string before delimeter ',')  SUBSTRING(`date`, 1, CHARINDEX(',', `date`) -1) AS year_and_month,
  -- (string after delimeter ',')   SUBSTRING(`date`, CHARINDEX(',', `date`) +1, LEN(`date`)) AS year_and_month,
    SUM(total_laid_off) AS total_off
FROM 
    layoffs_copy_2
WHERE
    SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY
    year_and_month
ORDER BY 1
)

SELECT 
    year_and_month,
    total_off,
    SUM(total_off) OVER (ORDER BY year_and_month)
FROM 
    Rolling_Total;





-- Top 5 companies by layoffs per year
WITH Company_Year AS (
SELECT company, YEAR(`date`) AS 'year', SUM(total_laid_off) AS total
FROM layoffs_copy_2
WHERE YEAR(`date`) IS NOT NULL AND
total_laid_off IS NOT NULL
GROUP BY company, YEAR(`date`)
), Company_year_rank AS(

SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total DESC) AS Ranking
FROM Company_Year
)

SELECT *
FROM Company_year_rank
WHERE Ranking <= 5;

