USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GetFacultyWorkload
    @FacultyID INT,
    @AcademicYear NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Faculty WHERE FacultyID = @FacultyID)
            THROW 50110, 'Faculty does not exist.', 1;

        SELECT 
            f.FacultyID,
            f.FirstName + ' ' + f.LastName AS FacultyName,
            f.Designation,
            d.DeptName,
            sec.AcademicYear,
            sec.SemesterTerm,
            COUNT(DISTINCT sec.SectionID) AS TotalSections,
            SUM(DISTINCT c.CreditHours) AS TotalCreditHours,
            COUNT(DISTINCT e.StudentID) AS TotalStudents
        FROM Faculty f
        JOIN Departments d ON f.DepartmentID = d.DepartmentID
        JOIN Sections sec ON f.FacultyID = sec.FacultyID
        JOIN Courses c ON sec.CourseID = c.CourseID
        LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID 
            AND e.Status = 'Active'
        WHERE f.FacultyID = @FacultyID
          AND (@AcademicYear IS NULL OR sec.AcademicYear = @AcademicYear)
        GROUP BY f.FacultyID, f.FirstName, f.LastName, f.Designation, 
                 d.DeptName, sec.AcademicYear, sec.SemesterTerm
        ORDER BY sec.AcademicYear DESC, sec.SemesterTerm;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO