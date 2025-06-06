-- Data Cleaning
/* 
1.Remove DUPLICATES
2.Standardize the DATA (seeing spelling errors)
3.Working with NULL values and BLANK values
4.Removing any COLUMNS/ROWS that is uneccesery  
*/

USE world_layoffs;



-- Actuall DATA
SELECT * 
FROM layoffs;



-- Creating DUPLICATE TABLE and Inserting the DATA into that TABLE

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;



-- > IDENTIFYING AND DELETING DUPLICATES
/* 
	Right click on layoffs_staging table
	Select copy to clickboard option
    Then click on create_statement option
    Paste it in SQLfile\Create 1 extra row with row_num and layoffs_staging2 table
*/

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicates_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1; 


-- Creating new table and inserting new column row_num in it

CREATE TABLE `layoffs_staging2` (
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

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


-- Deleting dupicates

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

DELETE FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;



-- 2.STANDARDIZING THE DATA

-- Using UPDATE query to update the data
-- Removing WHITE SPACES using TRIM function

SELECT DISTINCT company
FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


-- Finding and correcting spelling errors
-- In industry column

SELECT * 
FROM layoffs_staging2;

SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT DISTINCT industry 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- In country column

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country DESC;

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Triming the word/letter/number/symbol
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country = 'Unites States';


-- Changing date format

SELECT * 
FROM layoffs_staging2;

SELECT `date` 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- Changing data type

ALTER TABLE layoffs_staging2
MODIFY `date` DATE;



-- 3.FILLING NULL AND BLANK VALUES

SELECT * 
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;



-- Deleting unwanted ROWS and COLUMNS

SELECT * 
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- 4.REMOVING UNECESSARY COLUMNS AND ROWS

-- DELETING unwanted ROWS

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Deleting unwanted COLUMNS

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

