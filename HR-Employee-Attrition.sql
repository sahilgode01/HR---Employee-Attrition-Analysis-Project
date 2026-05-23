create database HR_Employee_Attrition;
alter table hr_emp_attrition drop column MyUnknownColumn;
select * from hr_emp_attrition;

-- Display the first 10 rows from the table
select * from hr_emp_attrition limit 10;

-- Find the total number of employees in the company
select count(employeecount) as Total_Employees from hr_emp_attrition;

-- List all unique departments
select distinct department from hr_emp_attrition;

-- show how many employees have left the company and how many are still working
select attrition, count(*) as status1 from hr_emp_attrition group by attrition;

-- Retrieve the list of employees who work overtime
select * from hr_emp_attrition where overtime = 'Yes';

-- Find average monthly income of all employees
select avg(monthlyincome) from hr_emp_attrition;

-- Identify employees whose number of companies worked is missing (Null)
select * from hr_emp_attrition where NumCompaniesWorked = '0';

-- Find the employees with the maximum monthly income
select * from hr_emp_attrition where monthlyincome = (select max(MonthlyIncome) from hr_emp_attrition);

-- Count the number of employees by gender
select Gender, count(employeecount) from hr_emp_attrition group by gender;

-- List all the employees who have just joined (YearsAtCompany = 0)
select * from hr_emp_attrition where YearsAtCompany = '0';

-- Calculate the attrition rate % by departments
select department, count(*) as Total_Employees, count(case when attrition = 'Yes' then 1 end) as employees_left,
round(count(case when attrition = 'Yes' then 1 end) * 100.0 / count(*), 2) 
as attrition_rate_percentage 
from hr_emp_attrition group by department;

-- List the top 10 employees with the highest total working years
select * from hr_emp_attrition order by TotalWorkingYears desc limit 10;

-- Group employees into tenure categories (<1yr, 1-3yr, 4-6yr, 7+yr) and count employees in each
select count(*) as employeecount,
case 
	when Totalworkingyears < 1 then '<1 year'
    when Totalworkingyears between 1 and 3 then '1-3 years'
    when Totalworkingyears between 4 and 6 then '4-6 years'
    else '7+ years'
end as Tenure_category
from hr_emp_attrition 
group by Tenure_category;
	
-- Find the average monthly income by job level and attribition status
select  JobLevel, round(avg(monthlyincome), 2) as avg_Monthly_income, Attrition from hr_emp_attrition group by JobLevel, attrition order by JobLevel;

-- Identify the top 5 Job roles with the highest number of employees who left 
select jobrole, count(*) as employees_left from hr_emp_attrition 
where attrition = 'Yes' group by jobrole order by employees_left desc limit 5;

-- List employees who left the company within their first year
select * from hr_emp_attrition where TotalWorkingYears = 1 or TotalWorkingYears < 1;

-- Calculate each employees approximate new monthly compensation after applying their salary hike percentage
select EmployeeNumber, MonthlyIncome, PercentSalaryHike, 
MonthlyIncome + (Monthlyincome * Percentsalaryhike / 100)
as New_Monthly_Compensation from hr_emp_attrition;

-- Count Employees Grouped  by overtime status and attrition
select count(employeecount), overtime, attrition from hr_emp_attrition group by overtime, attrition order by overtime;

-- Display the top 10 employees who attended the most training sessions last year
select * from hr_emp_attrition order by TrainingTimesLastYear desc limit 10;

-- Rank employees by total working years (most experienced = rank 1)
select *, rank() over(order by Totalworkingyears desc) as rn from hr_emp_attrition;

-- For each department, find the employees whose monthly income is in the top 25% of that department
select * from 
(select *, Ntile(4) over(partition by department order by monthlyincome desc)
as income_group from hr_emp_attrition) as temp where income_group = 1;

-- Divide employees into 10 income deciles and find attrition rate for each decile
select Income_Decile, count(*) as Total_Employees,
count(case when attrition = 'Yes' then 1 end) as employees_Left,
round(count(case when attrition = 'Yes' then 1 end) * 100.0 / count(*), 2) as attrition_rate 
from (select Ntile(10) over(order by MonthlyIncome) as Income_Decile, attrition from hr_emp_attrition) as temp
group by income_decile order by income_decile;

-- Create a simple risk score based on tenure, performance, overtime, and work-life balance and list the top 50 high risk employees
SELECT 
	EmployeeNumber,
    JobRole,
    TotalWorkingYears,
    PerformanceRating,
    OverTime,
    WorkLifeBalance,
    (CASE WHEN TotalWorkingYears < 3 THEN 2
		ELSE 0
	END
	+
	CASE WHEN PerformanceRating <= 2 THEN 2
		ELSE 0
	END
	+
	CASE WHEN OverTime = 'Yes' THEN 2
		ELSE 0
	END
	+
	CASE WHEN WorkLifeBalance <= 2 THEN 2
		ELSE 0
	END) AS Risk_Score
FROM hr_emp_attrition
ORDER BY Risk_Score DESC
LIMIT 50;

-- Create a summary view showing, for each department and job level total employees,
-- number of leavers, attrition rate and average monthly income
create view summary_of_department_attrition as
select department, joblevel, count(*) as total_employees, 
count(case when attrition = 'Yes' then 1 end) as Number_of_Leavers,
round(count(case when attrition = 'Yes' then 1 end) * 100.0 / count(*), 2) as attrition_rate,
round(avg(monthlyincome), 2) as avg_monthlyincome 
from hr_emp_attrition group by department, JobLevel order by department, joblevel;

select * from summary_of_department_attrition;




