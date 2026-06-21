USE HiSUP_DB;
GO

-- Window Function 1: RANK -- Students by GPA in each department
SELECT 
    s.RollNumber,
    s.FirstName + ' ' + s.LastName AS StudentName,
    d.DeptName,
    ROUND(SUM(g.GradePoint * c.CreditHours) / 
        NULLIF(SUM(c.CreditHours), 0), 2) AS CGPA,
    RANK() OVER (
        PARTITION BY d.DepartmentID 
        ORDER BY SUM(g.GradePoint * c.CreditHours) / 
            NULLIF(SUM(c.CreditHours), 0) DESC
    ) AS DeptRank,
    DENSE_RANK() OVER (
        PARTITION BY d.DepartmentID 
        ORDER BY SUM(g.GradePoint * c.CreditHours) / 
            NULLIF(SUM(c.CreditHours), 0) DESC
    ) AS DenseDeptRank,
    ROW_NUMBER() OVER (
        PARTITION BY d.DepartmentID 
        ORDER BY SUM(g.GradePoint * c.CreditHours) / 
            NULLIF(SUM(c.CreditHours), 0) DESC
    ) AS RowNum
FROM Students s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Sections sec ON e.SectionID = sec.SectionID
JOIN Courses c ON sec.CourseID = c.CourseID
JOIN Grades g ON e.EnrollmentID = g.EnrollmentID
WHERE g.GradePoint IS NOT NULL
GROUP BY s.StudentID, s.RollNumber, s.FirstName, 
         s.LastName, d.DepartmentID, d.DeptName;
GO

-- Window Function 2: NTILE -- Divide students into 4 performance quartiles
SELECT 
    s.RollNumber,
    s.FirstName + ' ' + s.LastName AS StudentName,
    d.DeptName,
    ROUND(SUM(g.GradePoint * c.CreditHours) / 
        NULLIF(SUM(c.CreditHours), 0), 2) AS CGPA,
    NTILE(4) OVER (
        ORDER BY SUM(g.GradePoint * c.CreditHours) / 
            NULLIF(SUM(c.CreditHours), 0) DESC
    ) AS Quartile
FROM Students s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Sections sec ON e.SectionID = sec.SectionID
JOIN Courses c ON sec.CourseID = c.CourseID
JOIN Grades g ON e.EnrollmentID = g.EnrollmentID
WHERE g.GradePoint IS NOT NULL
GROUP BY s.StudentID, s.RollNumber, s.FirstName, 
         s.LastName, d.DepartmentID, d.DeptName;
GO

-- Window Function 3: LAG and LEAD -- Fee payment trend
SELECT 
    s.RollNumber,
    s.FirstName + ' ' + s.LastName AS StudentName,
    fp.PaymentDate,
    fp.AmountPaid,
    LAG(fp.AmountPaid, 1, 0) OVER (
        PARTITION BY fp.StudentID 
        ORDER BY fp.PaymentDate
    ) AS PreviousPayment,
    LEAD(fp.AmountPaid, 1, 0) OVER (
        PARTITION BY fp.StudentID 
        ORDER BY fp.PaymentDate
    ) AS NextPayment,
    SUM(fp.AmountPaid) OVER (
        PARTITION BY fp.StudentID 
        ORDER BY fp.PaymentDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal
FROM FeePayments fp
JOIN Students s ON fp.StudentID = s.StudentID
ORDER BY fp.StudentID, fp.PaymentDate;
GO