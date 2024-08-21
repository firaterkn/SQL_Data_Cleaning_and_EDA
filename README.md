# Overview

This project focuses on analyzing layoffs data to uncover trends and insights, particularly during the COVID-19 pandemic period. The raw data was cleaned and processed using MySQL to ensure its reliability before performing an exploratory data analysis (EDA) to answer key business questions.

# The Questions 

The questions to be answered in the project are below:

1. Which company had the most layoffs during the pandemic period?
2. Which industry experienced the highest number of layoffs?
3. What was the distribution of layoffs across different countries?
4. How did layoffs trend over the years from 2020 to 2023?
5. Which companies have made the most layoffs over the years?
6. How many total layoffs per month?


# Tools Used

**MySQL:** For the data obtaining cleaning, processing, and analysis.
**Visual Studio Code:** For writing and editing SQL.
**Git and GitHub:** For version control and project management.

# Data Preparation and Cleanup

The raw data underwent several cleaning steps to make it suitable for analysis

**1. Copy Raw Data**

The data was copied in case it was necessary to return to the original data later.

``` SQL
CREATE TABLE layoffs_copy
LIKE layoffs;

-- Copy the content of the raw data
INSERT INTO layoffs_copy
SELECT *
FROM layoffs;

```

**2. Removing Duplicates**

Identified and removed duplicate records to ensure data accuracy.
  
``` SQL
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

```

**3. Standardizing Data**

Corrected misspelled entries, standardized formats, and trimmed unnecessary spaces.

``` SQL
-- Check the industry column for misspelling
SELECT DISTINCT(industry)
FROM layoffs_copy_2
ORDER BY 1;

UPDATE layoffs_copy_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
```

``` SQL
-- The dtype of the date column is text, convert it to the date format
UPDATE layoffs_copy_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- if the format is 'dd-mm-yyyy' use STR_TO_DATE(`date`, '%d/%m/%Y')


-- After having the date format, finally convert it into the date dtype
ALTER TABLE layoffs_copy_2
MODIFY COLUMN `date` DATE;
```

``` SQL
-- Remove leftmost and rightmost spaces
UPDATE layoffs_copy_2
SET company = TRIM(company);
```

**4. Handling NULL Values**

Replaced or removed records with missing data in critical columns.

``` SQL
-- If both total_laid_off and percentage_laid_off columns are NULL
-- data is pretty useless
DELETE
FROM layoffs_copy_2
WHERE (total_laid_off IS NULL OR total_laid_off = '') AND
(percentage_laid_off IS NULL OR percentage_laid_off = '');


-- Replace the industry column's blank values with NULL
UPDATE layoffs_copy_2
SET industry = NULL
WHERE industry = '';

```

``` SQL
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

```

# The Analysis

# 1. Which company had the most layoffs during the pandemic period?

### Visusalize Data


```SQL
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

```

# Result

![Visual](https://github.com/firaterkn/SQL_Data_Cleaning_and_EDA/blob/main/2_Exploratory_Data_Analysis/Max_laid_off_in_a_day.PNG)

# Insights About the Graph

- As seen in the image, Booking.com made the most daily layoffs by laying off 4.3k people in one day on July 30, 2020.
  
- Another thing to note is that Uber laid off a total of 6.7k people in May.


# 2. Which industry experienced the highest number of layoffs??

### Visusalize Data


```SQL
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_copy_2
GROUP BY industry
ORDER BY 2 DESC
LIMIT 5;
```

# Result

![Visual](https://github.com/firaterkn/SQL_Data_Cleaning_and_EDA/blob/main/2_Exploratory_Data_Analysis/Max_laid_off_in_a_day.PNG)

# Insights About the Graph

- As seen in the image, Booking.com made the most daily layoffs by laying off 4.3k people in one day on July 30, 2020.
  
- Another thing to note is that Uber laid off a total of 6.7k people in May.

















