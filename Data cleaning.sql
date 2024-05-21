/*------------------------------------------*/
/* -- Project of data cleaning  		 -- */
/* -- DB 'Layoffs' from Kaggle  		 -- */
/* -- 1. remove duplicates     			 -- */
/* -- 2. standardize the data 		   	 -- */
/* -- 3. Null/blanks values 		   	 -- */
/* -- 4. Remove Unnecessary Columns/Rows -- */
/*------------------------------------------*/

/* -- 1. remove duplicates     			 -- */

-- using cte function & row_number
-- we get 1 if single row or >1 if duplicates row
with duplicate_cte as 
(
select *, 
row_number () over (
	partition by company, location, industry,total_laid_off, percentage_laid_off, date, stage, country,funds_raised_millions) as row_num
from layoffs.layoffs_staging
)
-- looking at the table if exist any duplicates values --
select *
from duplicate_cte
where row_num>1
;
-- we check the duplicate displayed in the previous query if it's effectively a duplicate
select * from layoffs.layoffs_staging
where company='oyster';


with duplicate_cte as 
(
select *, 
row_number () over (
	partition by company, location, industry,total_laid_off, percentage_laid_off, date, stage, country,funds_raised_millions) as row_num
from layoffs.layoffs_staging
)
delete 
from duplicate_cte
where row_num>1
;

CREATE TABLE layoffs.`layoffs_staging2` (
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

insert into layoffs.layoffs_staging2
select *, 
row_number () over (
	partition by company, location, industry,total_laid_off, percentage_laid_off, date, stage, country,funds_raised_millions) as row_num
from layoffs.layoffs_staging;

select * from layoffs.layoffs_staging2
where row_num = 2;

delete 
from layoffs.layoffs_staging2
where row_num>1;

-- standardize data

select company, trim(company)
from layoffs.layoffs_staging2;
