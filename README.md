# HR Attrition Analysis (SQL Server / T-SQL)

## Overview
A relational database and analysis project modeling an internal HR system — departments, employees (with manager hierarchy), and performance reviews. The project focuses on the kind of attrition and workforce analytics questions an HR/People Analytics team would ask.

## Business Questions Answered
- Which departments have the highest employee attrition rate?
- How does average tenure differ between active and terminated employees?
- Is there a relationship between salary level and performance rating?
- How many direct reports does each manager have (span of control)?
- At what point in an employee's tenure are they most likely to leave?
- Who are the active, high-performing employees worth prioritizing for retention?

## Tech Stack
- SQL Server (T-SQL)
- SQL Server Management Studio (SSMS)

## Database Schema
Three tables, including a self-referencing relationship for reporting lines:

| Table | Description |
|---|---|
| `Departments` | Department list |
| `Employees` | Employee record: department, manager (self-FK), hire/termination date, salary |
| `PerformanceReviews` | Review ratings (1–5) tied to an employee, one or more per year |

**Relationships:** `Employees.DepartmentID → Departments`, `Employees.ManagerID → Employees.EmployeeID` (self-referencing), `PerformanceReviews.EmployeeID → Employees`.

## Key SQL Techniques Used
- Self-referencing `JOIN` to model manager/direct-report hierarchy
- CTEs for tenure and salary-band bucketing logic
- `CASE` statements for segmenting employees (salary bands, tenure buckets)
- `HAVING` clause for filtering aggregated results (top performers)
- Window function `RANK()` for ranking departments by average salary
- Correlated subquery for year-over-year termination counts
- Handling open-ended date ranges with `COALESCE(TerminationDate, GETDATE())`

## How to Run
1. Open `02_hr_attrition_analysis.sql` in SQL Server Management Studio.
2. Execute the full script (F5) — it creates the `HRAnalytics` database, builds the schema, and loads sample data.
3. Run each query in Section 3 individually to see the analysis output.

## Sample Insight
The tenure-bucket query shows attrition is concentrated in the 12–24 month range, suggesting a "second-year dip" — useful for deciding where to focus retention efforts (e.g., career development conversations timed around month 12).

## Possible Extensions
- Connect to Power BI/Tableau for an HR attrition dashboard
- Swap in a real dataset like the [IBM HR Analytics Attrition dataset](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset)
- Add an `ExitInterviews` table to analyze stated reasons for leaving alongside the quantitative attrition patterns
