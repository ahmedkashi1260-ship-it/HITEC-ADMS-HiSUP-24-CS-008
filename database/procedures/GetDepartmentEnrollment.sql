USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GetDepartmentEnrollment
    @DepartmentID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            d.DepartmentID, 
            d.DeptName, 
            d.DeptCode,
            COUNT(DISTINCT s.StudentID) AS TotalStudents,
            COUNT(DISTINCT f.FacultyID) AS TotalFaculty,
            COUNT(DISTINCT p.ProgramID) AS TotalPrograms,
            COUNT(DISTINCT e.EnrollmentID) AS ActiveEnrollments
        FROM Departments d
        LEFT JOIN Students s ON d.DepartmentID = s.DepartmentID 
            AND s.IsActive = 1
        LEFT JOIN Faculty f ON d.DepartmentID = f.DepartmentID 
            AND f.IsActive = 1
        LEFT JOIN Programs p ON d.DepartmentID = p.DepartmentID 
            AND p.IsActive = 1
        LEFT JOIN Courses c ON p.ProgramID = c.ProgramID
        LEFT JOIN Sections sec ON c.CourseID = sec.CourseID
        LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID 
            AND e.Status = 'Active'
        WHERE (@DepartmentID IS NULL OR d.DepartmentID = @DepartmentID)
        GROUP BY d.DepartmentID, d.DeptName, d.DeptCode
        ORDER BY d.DeptName;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO