USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GetStudentReport
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50100, 'Student does not exist.', 1;

        SELECT 
            s.StudentID, 
            s.RollNumber,
            s.FirstName + ' ' + s.LastName AS FullName,
            d.DeptName,
            s.EnrollmentYear,
            COUNT(DISTINCT e.EnrollmentID) AS TotalEnrollments,
            COUNT(DISTINCT CASE WHEN e.Status = 'Active' THEN e.EnrollmentID END) AS ActiveEnrollments,
            ROUND(AVG(g.GradePoint), 2) AS CGPA,
            COUNT(DISTINCT CASE WHEN ar.Status = 'Present' THEN ar.AttendanceID END) AS TotalPresent,
            COUNT(DISTINCT ar.AttendanceID) AS TotalClasses,
            ISNULL(SUM(fp.AmountPaid), 0) AS TotalFeesPaid
        FROM Students s
        JOIN Departments d ON s.DepartmentID = d.DepartmentID
        LEFT JOIN Enrollments e ON s.StudentID = e.StudentID
        LEFT JOIN Grades g ON e.EnrollmentID = g.EnrollmentID
        LEFT JOIN AttendanceRecords ar ON s.StudentID = ar.StudentID
        LEFT JOIN FeePayments fp ON s.StudentID = fp.StudentID
        WHERE s.StudentID = @StudentID
        GROUP BY s.StudentID, s.RollNumber, s.FirstName, s.LastName, 
                 d.DeptName, s.EnrollmentYear;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO