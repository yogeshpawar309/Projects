----- Employee Management System ------- 

create database Employee_Management_System;
use Employee_Management_System;

-- Table 1: Job Department 
CREATE TABLE JobDepartment ( 
    Job_ID INT PRIMARY KEY, 
    jobdept VARCHAR(50), 
    name VARCHAR(100), 
    description TEXT, 
    salaryrange VARCHAR(50) 
); 

select * from JobDepartment;

-- Table 2: Salary/Bonus 
CREATE TABLE SalaryBonus ( 
    salary_ID INT PRIMARY KEY, 
    Job_ID INT, 
    amount DECIMAL(10,2), 
    annual DECIMAL(10,2), 
    bonus DECIMAL(10,2), 
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE 
);

select * from SalaryBonus;

 -- Table 3: Employee 
CREATE TABLE Employee ( 
    emp_ID INT PRIMARY KEY, 
    firstname VARCHAR(50), 
    lastname VARCHAR(50), 
    gender VARCHAR(10), 
    age INT, 
    contact_add VARCHAR(100), 
    emp_email VARCHAR(100) UNIQUE, 
    emp_pass VARCHAR(50), 
    Job_ID INT, 
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID) 
        REFERENCES JobDepartment(Job_ID) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE 
);

select * from employee; 
 
 -- Table 4: Qualification 
CREATE TABLE Qualification ( 
    QualID INT PRIMARY KEY, 
    Emp_ID INT, 
    Position VARCHAR(50), 
    Requirements VARCHAR(255), 
    Date_In DATE, 
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID) 
        REFERENCES Employee(emp_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
); 

select * from Qualification;

 -- Table 5: Leaves 
CREATE TABLE Leaves ( 
    leave_ID INT PRIMARY KEY, 
    emp_ID INT, 
    date DATE, 
    reason TEXT, 
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE 
); 

select * from Leaves;

 -- Table 6: Payroll 
CREATE TABLE Payroll ( 
    payroll_ID INT PRIMARY KEY, 
    emp_ID INT, 
    job_ID INT, 
    salary_ID INT, 
    leave_ID INT, 
    date DATE, 
    report TEXT, 
    total_amount DECIMAL(10,2), 
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE, 
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE, 
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES 
SalaryBonus(salary_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE, 
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID) 
        ON DELETE SET NULL ON UPDATE CASCADE 
);

select * from payroll;

-------------- Analysis Questions ------------

----------- 1. EMPLOYEE INSIGHTS-------------

-- ● How many unique employees are currently in the system? 
select count(distinct emp_ID) as Unique_employees_count
from employee;

-- ● Which departments have the highest number of employees? 
select jobdept, count(*) as employee_count
from jobdepartment
group by jobdept
order by employee_count desc;

-- ● What is the average salary per department? 
select jobdept, amount as Avg_salary
from jobdepartment
left join salarybonus
on jobdepartment.job_id = salarybonus.job_id;

-- ● Who are the top 5 highest-paid employees? 
select employee.job_id,
		employee.firstname, 
		employee.lastname,
		salarybonus.amount as highest_paid_employees
from employee
left join salarybonus
on employee.job_id = salarybonus.job_id
order by highest_paid_employees desc 
limit 5;

-- ● What is the total salary expenditure across the company? 
select sum(annual) as Total_annual_salary ,
	   sum(bonus) as Total_bonus
from salarybonus;

select sum(annual + bonus) as Total_expenditure
from salarybonus;

------------------------------------------------------------------------------------------

----------- 2. JOB ROLE AND DEPARTMENT ANALYSIS --------------

-- ● How many different job roles exist in each department? 
select jobdept , count(*) as Total_job_roles
from jobdepartment
group by jobdept;

-- ● What is the average salary range per department? 
SELECT jobdept,`name`,round(avg(CAST(REPLACE(SUBSTRING_INDEX(REPLACE(salaryrange,' ',''),'-',1),'$','') AS UNSIGNED)+
        CAST(REPLACE(SUBSTRING_INDEX(REPLACE(salaryrange,' ',''),'-',-1),'$','') AS UNSIGNED)) / 2 ,2)AS Avg_Salary
FROM jobdepartment
group by jobdept,`name`;

-- ● Which job roles offer the highest salary? 
select jobdept,`name`, amount as highest_salary
from jobdepartment
left join salarybonus
on jobdepartment.job_id = salarybonus.job_id
order by highest_salary desc;

-- ● Which departments have the highest total salary allocation?
SELECT jobdept as Department ,`name`,
    SUM(amount) AS Total_Salary
FROM jobdepartment
LEFT JOIN salarybonus
on jobdepartment.job_id = salarybonus.job_id
GROUP BY jobdept,`name`
ORDER BY Total_Salary DESC
limit 1;

----------- 3. QUALIFICATION AND SKILLS ANALYSIS --------------

-- ● How many employees have at least one qualification listed? 
SELECT 
    employee.emp_id,
    employee.firstname,
    employee.lastname,
    qualification.Requirements,
    COUNT(qualification.Requirements) AS Total_Qualifications
FROM employee 
LEFT JOIN qualification 
    ON employee.emp_id = qualification.emp_id
GROUP BY employee.emp_id,
 employee.firstname, 
 employee.lastname,
 qualification.Requirements;

-- ● Which positions require the most qualifications? 
SELECT emp_id,
    position,Requirements,
    COUNT(Requirements) AS Total_Qualifications
FROM qualification
GROUP BY emp_id,position,Requirements;


-- ● Which employees have the highest number of qualifications?
SELECT 
    e.emp_id,
    e.firstname,
    e.lastname,
    COUNT(q.Requirements) AS Total_Qualifications
FROM employee e
LEFT JOIN qualification q
    ON e.emp_id = q.emp_id
GROUP BY e.emp_id, e.firstname, e.lastname
ORDER BY Total_Qualifications DESC;

-------------- 4. LEAVE AND ABSENCE PATTERNS ----------------

-- Which year had the most employees taking leaves? 
select
	year(`date`) as Leave_year,
    count(Distinct emp_id) as Employee_on_Leave
from leaves
group by Leave_year
order by Employee_on_Leave;


-- What is the average number of leave days taken by its employees per department? 
SELECT jobdept as Department,e.emp_id,
    DAY(l.date) AS Leave_day,
    COUNT(DISTINCT l.emp_id) AS Avg_Employee_on_Leave
FROM leaves l
JOIN employee e
    ON e.emp_id = l.emp_id
JOIN jobdepartment j
    ON e.job_id = j.job_id
GROUP BY DAY(l.date),jobdept,e.emp_id
ORDER BY emp_id asc;

-- Which employees have taken the most leaves? 
SELECT jobdept as Department,e.emp_id,
    DAY(l.date) AS Leave_day
FROM leaves l
JOIN employee e
    ON e.emp_id = l.emp_id
JOIN jobdepartment j
    ON e.job_id = j.job_id
GROUP BY DAY(l.date),jobdept,e.emp_id
ORDER BY leave_day desc
limit 2;

-- What is the total number of leave days taken company-wide? 
SELECT 
    COUNT(DISTINCT emp_id, date) AS total_leave_days
FROM leaves;

-- How do leave days correlate with payroll amounts?
SELECT round((COUNT(*) * SUM(leaves.date * payroll.total_amount) 
    - SUM(leaves.date) * SUM(payroll.total_amount)) /
SQRT((COUNT(*) * SUM(leaves.date * leaves.date) - POW(SUM(leaves.date), 2)) *
    (COUNT(*) * SUM(payroll.total_amount * payroll.total_amount) - POW(SUM(payroll.total_amount), 2))
),4) AS correlation 
from leaves
join payroll
on payroll.emp_id = leaves.emp_id;

----------- 5. PAYROLL AND COMPENSATION ANALYSIS ----------------

-- What is the total monthly payroll processed? 
Select
	YEAR(payroll.`date`) AS year_p,
    MONTH(payroll.`date`) AS month_p,
    SUM(total_amount) AS total_monthly
FROM payroll
GROUP BY 
    YEAR(payroll.`date`),
    MONTH(payroll.`date`)
ORDER BY year_p, month_p;

-- What is the average bonus given per department? 
SELECT 
    j.jobdept as Department ,
    round(AVG(s.bonus),2)AS Avg_bonus
FROM salarybonus s
LEFT JOIN jobdepartment j 
    ON s.job_id = j.job_id
GROUP BY  j.jobdept;

-- Which department receives the highest total bonuses? 
SELECT 
    j.jobdept as Department ,
    sum(s.bonus) AS total_bonus
FROM salarybonus s
LEFT JOIN jobdepartment j 
    ON s.job_id = j.job_id
GROUP BY j.jobdept
order by total_bonus Desc
limit 1;

-- What is the average value of total_amount after considering leave deductions?
SELECT firstname, lastname,jobdept,
       ROUND(AVG(net_amount), 2) AS avg_amount_after_leave
FROM (
    SELECT e.firstname, e.lastname, p.emp_ID, j.jobdept,
           (p.total_amount - (p.total_amount / 30 * COUNT(l.emp_ID))) AS net_amount
    FROM payroll p
    LEFT JOIN leaves l 
        ON p.emp_ID = l.emp_ID
    JOIN jobdepartment j
        ON p.job_ID = j.job_ID
	JOIN employee e
		ON e.emp_ID = p.emp_ID
    GROUP BY p.emp_ID, j.jobdept, p.total_amount
) t
GROUP BY firstname, lastname, jobdept;