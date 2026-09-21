/* ============================================================
   PROJECT 2: HR / EMPLOYEE ATTRITION ANALYSIS
   Tool: SQL Server (SSMS) - T-SQL
   ============================================================
   What this demonstrates for your portfolio:
   - Normalized relational schema (self-referencing FK for managers)
   - Business-logic queries (attrition, tenure, span of control)
   - CTEs & subqueries
   - CASE-based bucketing (salary bands, tenure groups)
   - Aggregate + window function combos
   ============================================================ */

-- ================================
-- 0. CREATE DATABASE
-- ================================
CREATE DATABASE HRAnalytics;
GO
USE HRAnalytics;
GO

-- ================================
-- 1. SCHEMA
-- ================================
CREATE TABLE Departments (
    DepartmentID    INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName  VARCHAR(50) NOT NULL
);

CREATE TABLE Employees (
    EmployeeID      INT PRIMARY KEY IDENTITY(1,1),
    FirstName       VARCHAR(50) NOT NULL,
    LastName        VARCHAR(50) NOT NULL,
    DepartmentID    INT FOREIGN KEY REFERENCES Departments(DepartmentID),
    ManagerID       INT NULL FOREIGN KEY REFERENCES Employees(EmployeeID), -- self-referencing
    JobTitle        VARCHAR(50),
    HireDate        DATE NOT NULL,
    TerminationDate DATE NULL,  -- NULL = still employed
    Salary          DECIMAL(10,2) NOT NULL
);

CREATE TABLE PerformanceReviews (
    ReviewID        INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID      INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    ReviewDate      DATE NOT NULL,
    Rating          INT CHECK (Rating BETWEEN 1 AND 5), -- 1=poor, 5=excellent
    Comments        VARCHAR(200)
);
GO

-- ================================
-- 2. SAMPLE DATA
-- ================================

-- Departments (6)
INSERT INTO Departments (DepartmentName) VALUES
('Engineering'),('Sales'),('Marketing'),('Customer Support'),('Finance'),('HR');

-- Employees (40) - includes managers (ManagerID NULL for top-level),
-- mix of active and terminated employees, varied hire dates & salaries
INSERT INTO Employees (FirstName, LastName, DepartmentID, ManagerID, JobTitle, HireDate, TerminationDate, Salary) VALUES
-- Department heads (no manager)
('Chinedu',' Okoro',1,NULL,'Engineering Director','2019-01-10',NULL,850000),
('Aisha','Mohammed',2,NULL,'Sales Director','2019-02-15',NULL,800000),
('Tobi','Alabi',3,NULL,'Marketing Director','2019-03-20',NULL,780000),
('Ruth','Danjuma',4,NULL,'Support Director','2019-04-01',NULL,700000),
('Kunle','Ogundipe',5,NULL,'Finance Director','2019-05-12',NULL,820000),
('Patience','Obi',6,NULL,'HR Director','2019-06-01',NULL,750000),

-- Engineering team (manager = 1)
('David','Nwachukwu',1,1,'Senior Engineer','2020-01-15',NULL,520000),
('Ifeoma','Chukwu',1,1,'Software Engineer','2020-03-10',NULL,420000),
('Samuel','Adeyinka',1,1,'Software Engineer','2020-06-22','2022-09-15',410000),
('Precious','Effiong',1,1,'QA Engineer','2021-01-05',NULL,380000),
('Tunde','Fashola',1,1,'DevOps Engineer',' 2021-02-18','2023-01-20',450000),
('Zainab','Abdullahi',1,1,'Junior Engineer','2022-04-01',NULL,300000),
('Chukwuemeka','Eze',1,1,'Software Engineer','2022-07-11',NULL,415000),
('Grace','Udo',1,1,'Junior Engineer','2023-01-09',NULL,290000),

-- Sales team (manager = 2)
('Bola','Adekunle',2,2,'Sales Manager','2020-02-01',NULL,480000),
('Michael','Okonkwo',2,2,'Account Executive','2020-05-15','2021-11-30',360000),
('Hauwa','Ibrahim',2,2,'Account Executive','2020-09-10',NULL,370000),
('Emeka','Nnaji',2,2,'Sales Rep','2021-03-22',NULL,290000),
('Funmi','Bello',2,2,'Sales Rep','2021-08-14','2022-12-01',285000),
('Ahmed','Yusuf',2,2,'Sales Rep','2022-02-01',NULL,295000),
('Chiamaka','Okoli',2,2,'Account Executive','2022-06-19',NULL,365000),

-- Marketing team (manager = 3)
('Wale','Adeyemi',3,3,'Marketing Manager','2020-01-20',NULL,460000),
('Ngozi','Okafor',3,3,'Content Strategist','2020-07-01',NULL,340000),
('Seun','Olawale',3,3,'Digital Marketer','2021-04-12','2023-03-18',320000),
('Blessing','Nwankwo',3,3,'Digital Marketer','2021-11-02',NULL,325000),
('Kayode','Adisa',3,3,'Graphic Designer','2022-05-16',NULL,310000),

-- Customer Support (manager = 4)
('Amina','Suleiman',4,4,'Support Team Lead','2020-03-01',NULL,400000),
('Uche','Ibe',4,4,'Support Agent','2020-08-19',NULL,260000),
('Fatimah','Lawal',4,4,'Support Agent','2021-01-25','2021-09-10',255000),
('Damilola','Ajayi',4,4,'Support Agent','2021-06-30',NULL,265000),
('Ike','Nwosu',4,4,'Support Agent','2022-03-14',NULL,270000),
('Rahmat','Bala',4,4,'Support Agent','2022-10-01','2023-06-05',260000),

-- Finance (manager = 5)
('Oluwaseun','Fagbenle',5,5,'Financial Analyst','2020-04-11',NULL,430000),
('Ekaette','Akpan',5,5,'Accountant','2020-10-05',NULL,400000),
('Bashir','Umar',5,5,'Financial Analyst','2021-09-01',NULL,425000),
('Nkechi','Eze',5,5,'Accountant','2022-08-08','2023-05-20',395000),

-- HR (manager = 6)
('Yetunde','Balogun',6,6,'HR Business Partner',' 2020-05-18',NULL,410000),
('Chuka','Onyekwere',6,6,'Recruiter','2021-02-09',NULL,350000),
('Aisha','Garba',6,6,'Recruiter','2021-10-15','2022-08-30',345000),
('Ope','Fatunde',6,6,'HR Generalist','2022-09-05',NULL,330000);
GO

-- Performance reviews (2-3 per active employee, using annual review dates)
INSERT INTO PerformanceReviews (EmployeeID, ReviewDate, Rating, Comments)
SELECT EmployeeID, '2022-06-30', 4, 'Solid performance' FROM Employees WHERE EmployeeID BETWEEN 1 AND 20;
INSERT INTO PerformanceReviews (EmployeeID, ReviewDate, Rating, Comments)
SELECT EmployeeID, '2023-06-30', 5, 'Exceeded expectations' FROM Employees WHERE EmployeeID IN (1,2,7,10,13,15,18,21,24,27,32,35,38);
INSERT INTO PerformanceReviews (EmployeeID, ReviewDate, Rating, Comments)
SELECT EmployeeID, '2023-06-30', 3, 'Meets expectations' FROM Employees WHERE EmployeeID IN (3,4,5,6,8,12,14,17,19,22,25,28,31,34,37);
INSERT INTO PerformanceReviews (EmployeeID, ReviewDate, Rating, Comments)
SELECT EmployeeID, '2023-06-30', 2, 'Needs improvement' FROM Employees WHERE EmployeeID IN (11,16,20,23,26,30,33,36);
GO

-- ================================
-- 3. ANALYSIS QUERIES
-- ================================

-- 3.1 Attrition rate by department
SELECT
    d.DepartmentName,
    COUNT(*) AS TotalEmployeesEver,
    SUM(CASE WHEN e.TerminationDate IS NOT NULL THEN 1 ELSE 0 END) AS Terminated,
    ROUND(
        SUM(CASE WHEN e.TerminationDate IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS AttritionRatePct
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName
ORDER BY AttritionRatePct DESC;

-- 3.2 Average tenure (in months) - active vs terminated employees
SELECT
    CASE WHEN TerminationDate IS NULL THEN 'Active' ELSE 'Terminated' END AS EmployeeStatus,
    AVG(DATEDIFF(MONTH, HireDate, COALESCE(TerminationDate, GETDATE()))) AS AvgTenureMonths
FROM Employees
GROUP BY CASE WHEN TerminationDate IS NULL THEN 'Active' ELSE 'Terminated' END;

-- 3.3 Salary bands vs average performance rating
WITH SalaryBands AS (
    SELECT
        e.EmployeeID,
        e.Salary,
        CASE
            WHEN e.Salary < 300000 THEN '1. Under 300k'
            WHEN e.Salary BETWEEN 300000 AND 449999 THEN '2. 300k-449k'
            WHEN e.Salary BETWEEN 450000 AND 699999 THEN '3. 450k-699k'
            ELSE '4. 700k+'
        END AS SalaryBand
    FROM Employees e
)
SELECT
    sb.SalaryBand,
    COUNT(DISTINCT sb.EmployeeID) AS NumEmployees,
    ROUND(AVG(CAST(pr.Rating AS FLOAT)), 2) AS AvgRating
FROM SalaryBands sb
JOIN PerformanceReviews pr ON sb.EmployeeID = pr.EmployeeID
GROUP BY sb.SalaryBand
ORDER BY sb.SalaryBand;

-- 3.4 Manager span of control (number of direct reports per manager)
SELECT
    m.EmployeeID AS ManagerID,
    m.FirstName + ' ' + m.LastName AS ManagerName,
    COUNT(e.EmployeeID) AS DirectReports
FROM Employees m
JOIN Employees e ON e.ManagerID = m.EmployeeID
GROUP BY m.EmployeeID, m.FirstName, m.LastName
ORDER BY DirectReports DESC;

-- 3.5 Attrition rate by tenure bucket (how early do people leave?)
WITH TenureBuckets AS (
    SELECT
        EmployeeID,
        TerminationDate,
        DATEDIFF(MONTH, HireDate, COALESCE(TerminationDate, GETDATE())) AS TenureMonths,
        CASE
            WHEN DATEDIFF(MONTH, HireDate, COALESCE(TerminationDate, GETDATE())) < 12 THEN '0-12 months'
            WHEN DATEDIFF(MONTH, HireDate, COALESCE(TerminationDate, GETDATE())) BETWEEN 12 AND 24 THEN '12-24 months'
            ELSE '24+ months'
        END AS TenureBucket
    FROM Employees
)
SELECT
    TenureBucket,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN TerminationDate IS NOT NULL THEN 1 ELSE 0 END) AS Terminated,
    ROUND(SUM(CASE WHEN TerminationDate IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS AttritionRatePct
FROM TenureBuckets
GROUP BY TenureBucket
ORDER BY TenureBucket;

-- 3.6 Top performers who are still active (retention priority list)
SELECT
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    d.DepartmentName,
    e.JobTitle,
    e.Salary,
    ROUND(AVG(CAST(pr.Rating AS FLOAT)), 2) AS AvgRating
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN PerformanceReviews pr ON e.EmployeeID = pr.EmployeeID
WHERE e.TerminationDate IS NULL
GROUP BY e.EmployeeID, e.FirstName, e.LastName, d.DepartmentName, e.JobTitle, e.Salary
HAVING AVG(CAST(pr.Rating AS FLOAT)) >= 4
ORDER BY AvgRating DESC, e.Salary DESC;

-- 3.7 Headcount over time (active employees by hire year vs terminations)
SELECT
    YEAR(HireDate) AS HireYear,
    COUNT(*) AS Hires,
    (SELECT COUNT(*) FROM Employees e2 WHERE YEAR(e2.TerminationDate) = YEAR(e1.HireDate)) AS TerminationsSameYear
FROM Employees e1
GROUP BY YEAR(HireDate)
ORDER BY HireYear;

-- 3.8 Rank departments by average salary (window function)
SELECT
    d.DepartmentName,
    ROUND(AVG(e.Salary), 2) AS AvgSalary,
    RANK() OVER (ORDER BY AVG(e.Salary) DESC) AS SalaryRank
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.TerminationDate IS NULL
GROUP BY d.DepartmentName;
