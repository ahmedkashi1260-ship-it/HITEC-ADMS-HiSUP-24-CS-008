USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_FacultyCourseLoad
AS
    SELECT 
        f.FacultyID,
        f.FirstName + ' ' + f.LastName AS FacultyName,
        f.Designation,
        d.DeptName,
        sec.AcademicYear,
        sec.SemesterTerm,
        COUNT(DISTINCT sec.SectionID) AS TotalSections,
        SUM(c.CreditHours) AS TotalCreditHours,
        COUNT(DISTINCT e.StudentID) AS TotalStudents
    FROM Faculty f
    JOIN Departments d ON f.DepartmentID = d.DepartmentID
    LEFT JOIN Sections sec ON f.FacultyID = sec.FacultyID
    LEFT JOIN Courses c ON sec.CourseID = c.CourseID
    LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID 
        AND e.Status = 'Active'
    GROUP BY f.FacultyID, f.FirstName, f.LastName, 
             f.Designation, d.DeptName,
             sec.AcademicYear, sec.SemesterTerm;
GO