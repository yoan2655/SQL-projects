/*------------------------------------------*/
/* -- Project of data cleaning  		 -- */
/* -- DB 'Layoffs' from Kaggle  		 -- */
/* -- 1. remove duplicates     			 -- */
/* -- 2. standardize the data 		   	 -- */
/* -- 3. Null/blanks values 		   	 -- */
/* -- 4. Remove Uncessary Columns/Rows 	 -- */
/*------------------------------------------*/

SELECT * FROM test.layoffs;
-- first of all we are goig to create a new database to secure our data in the layoffs:

create table test.layoffs_staging
like test.layoffs;

insert test.layoffs_staging
select * from test.layoffs;

select * from test.layoffs_staging;

-- 1. remove duplicates values
-- here we started to write a windows function and then, display the duplicate number in a separate query. 
-- we wanted to delete the duplicates row but we can't do it on a windows functions that's why we create a new table and from it we delete.
CREATE TABLE test.`layoffs_staging2` (
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

insert into test.layoffs_staging2
select *,
row_number () 
	over (partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) as row_num
from test.layoffs_staging
;
-- Let's check the duplicates values. 
SELECT * FROM test.layoffs_staging2
where row_num>1;

-- Ok we have some, let's delete them
delete  from test.layoffs_staging2
where row_num >1;

-- end

-- 2.sandardize the data.

-- we start to remove spaces for all the columns in text type.
DROP PROCEDURE IF EXISTS test.blanks_proc;

delimiter $$
CREATE PROCEDURE test.blanks_proc()
begin 
update test.layoffs_staging2
set company=trim(company),
	industry = trim(industry),
    location = trim(location),
    stage = trim(stage),
    country = trim(country)
;
end $$
delimiter ;

call test.blanks_proc () ;

-- let's now clean the industry colums.
-- We saw that only for airbnb company, the industry is missing. We need to update the industry for aribnb
update test.layoffs_staging2 
set industry = 'Travel'
where company = 'Airbnb';

-- we move forward to the date and format it as mm/dd/yyyy
-- let's see, before we update the date column, how it's look like.
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from test.layoffs_staging2
order by 1;

update test.layoffs_staging2
set date = str_to_date(`date`, '%m/%d/%Y');
-- check the date column.
select date from test.layoffs_staging2 ;

-- clean the country column and here we see that the united state is not clean.
select distinct country, trim(trailing '.' from country) from test.layoffs_staging2;
update test.layoffs_staging2
set country = trim(trailing '.' from country) ;
select distinct country from test.layoffs_staging2;
select  * from test.layoffs_staging2;


-- 3. blanks and null values
-- let's drop all blanks/null values into cells in all columns.


-- all null values in total_laid_off and percentage_laid_off means there are no laids off so we don't need these rows. 
-- we need to delete them.
delete 
from test.layoffs_staging2
where total_laid_off is null or percentage_laid_off is null;

select * from test.layoffs_staging2;


