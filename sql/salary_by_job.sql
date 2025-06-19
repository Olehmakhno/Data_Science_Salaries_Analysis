-- Середня зарплата за посадою + порівняння з загальною
WITH avg_salary_job AS (
    SELECT 
        job_title,
        ROUND(AVG(salary_in_usd), 0) AS avg_salary
    FROM salaries2025
    GROUP BY 1
),

over_avg_salary AS (
    SELECT
        ROUND(AVG(salary_in_usd), 0) AS over_avg_salary
    FROM salaries2025 
)

SELECT
    a.job_title,
    a.avg_salary,
    o.over_avg_salary,
    case
    	when a.avg_salary > o.over_avg_salary then 'Above Average'
    	when a.avg_salary = o.over_avg_salary then 'At Average'
    	else 'Below Average'
    end as comparison , 
    rank () over(order by a.avg_salary DESC) as salary_rank
FROM avg_salary_job a
CROSS JOIN over_avg_salary o
order by a.avg_salary DESC;


--Середня зарплата по experience_level + % різниця між Executive і всіма іншими
WITH exp_stats AS (
    SELECT
        experience_level,
        ROUND(AVG(salary_in_usd), 0) AS avg_salary
    FROM salaries2025
    GROUP BY experience_level
),
ex_salary AS (
    SELECT
        MAX(avg_salary) AS ex_avg_salary
    FROM exp_stats
    WHERE experience_level = 'EX'
)
SELECT
    e.experience_level,
    e.avg_salary,
    x.ex_avg_salary,
    ROUND(((x.ex_avg_salary - e.avg_salary) * 100.0 / e.avg_salary), 2) AS pct_difference
FROM exp_stats e
CROSS JOIN ex_salary x
ORDER BY e.avg_salary desc

-- Динаміка зарплат по роках (work_year)
with avg_year_salary as (
select 
	work_year,
	round(avg(salary_in_usd), 0) as avg_salary
from salaries2025
group by 1
order by 1
),

before_salary as (
select 
	work_year, 
	avg_salary,
	lag(avg_salary) over(ORDER BY work_year) as lag_salary
from avg_year_salary
)

select 
	work_year,
	avg_salary,
	round(((avg_salary-lag_salary)/lag_salary)*100, 2) as salary_change_pct
from before_salary


--ТОП-3 країни за середньою зарплатою
select 
	employee_residence, 
	round(avg(salary_in_usd), 0) as avg_salary,
	COUNT(*) as count_employees
from salaries2025
group by 1
order by 2 desc
limit 3
;

--Частка повної віддаленості (remote_ratio = 100) по посадах
with remote as (
select 
	job_title, 
	count(*) as count_job ,
	count(case 
		when remote_ratio = '100' then 1
	end) as count_remote
from salaries2025
group by 1
)

select 
	job_title, 
	count_job ,
	count_remote,
	round((count_remote/count_job)*100, 2) as remote_percentage
from remote
order by 4 desc;
