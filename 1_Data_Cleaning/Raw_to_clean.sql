SELECT *
FROM layoffs;


-- THIS PART INCLUDES:

-- 1. Remove duplicates
-- 2. Standardize the data
-- 3. Check NULL or blank values
-- 4. Remove any columns or rows




-- Copy raw data columns
CREATE TABLE layoffs_copy
LIKE layoffs;

-- Copy the content of the raw data
INSERT INTO layoffs_copy
SELECT *
FROM layoffs;


-- Find the duplicates using CTE and Window Function
WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER 
(PARTITION BY company, `location`, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_copy
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;


/* Remove the duplicates in MSS or PostgreSQL, but in MySQL it doesn't work

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER 
(PARTITION BY company, `location`, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_copy
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

*/


-- Create new table and add 1 extra row named row_num
CREATE TABLE `layoffs_copy_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Fill the table
INSERT INTO layoffs_copy_2
SELECT *,
ROW_NUMBER() OVER 
(PARTITION BY company, `location`, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_copy;

-- Delete if row_num > 1 (means duplicate)
DELETE
FROM layoffs_copy_2
WHERE row_num > 1;



-- Remove leftmost and rightmost spaces
UPDATE layoffs_copy_2
SET company = TRIM(company);


-- Check the industry column for misspelling
SELECT DISTINCT(industry)
FROM layoffs_copy_2
ORDER BY 1;

UPDATE layoffs_copy_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- Check the location column
SELECT DISTINCT(`location`)
FROM layoffs_copy_2
ORDER BY 1;
-- Nothing wrong with location column




-- Check the country column
SELECT DISTINCT(country)
FROM layoffs_copy_2
ORDER BY 1;

UPDATE layoffs_copy_2
SET country = 'United States'
WHERE industry LIKE 'United States%';


-- The dtype of the date column is text, convert it to the date format
UPDATE layoffs_copy_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- if the format is 'dd-mm-yyyy' use STR_TO_DATE(`date`, '%d/%m/%Y')


-- After having the date format, finally convert it into the date dtype
ALTER TABLE layoffs_copy_2
MODIFY COLUMN `date` DATE;



-- If both total_laid_off and percentage_laid_off columns are NULL data
-- is pretty useless
DELETE
FROM layoffs_copy_2
WHERE (total_laid_off IS NULL OR total_laid_off = '') AND
(percentage_laid_off IS NULL OR percentage_laid_off = '');


-- Replace the industry column's blank values with NULL
UPDATE layoffs_copy_2
SET industry = NULL
WHERE industry = '';



-- Find all the NULL industry values
SELECT *
FROM layoffs_copy_2
WHERE industry IS NULL;


-- We might fill the NULL industry values, if we find same company name
UPDATE layoffs_copy_2 c1
JOIN layoffs_copy_2 c2
ON c1.company = c2.company 
SET c1.industry = c2.industry
WHERE c1.industry IS NULL AND
c2.industry IS NOT NULL;


-- Finally, drop the row_num column that we used for the duplicate values.
ALTER TABLE layoffs_copy_2
DROP COLUMN row_num;
