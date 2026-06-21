USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_ExamTimetable
AS
    SELECT 
        es.ExamID,
        es.ExamType,
        es.ExamDate,
        es.DurationMinutes,
        es.RoomNumber,
        es.TotalMarks,
        c.CourseCode,
        c.CourseTitle,
        c.CreditHours,
        sec.SectionName,
        sec.SemesterTerm,
        sec.AcademicYear,
        f.FirstName + ' ' + f.LastName AS FacultyName,
        f.Designation,
        d.DeptName,
        COUNT(DISTINCT e.StudentID) AS EnrolledStudents
    FROM ExamSchedule es
    JOIN Sections sec ON es.SectionID = sec.SectionID
    JOIN Courses c ON sec.CourseID = c.CourseID
    JOIN Faculty f ON sec.FacultyID = f.FacultyID
    JOIN Departments d ON f.DepartmentID = d.DepartmentID
    LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID 
        AND e.Status = 'Active'
    GROUP BY es.ExamID, es.ExamType, es.ExamDate, es.DurationMinutes,
             es.RoomNumber, es.TotalMarks, c.CourseCode, c.CourseTitle,
             c.CreditHours, sec.SectionName, sec.SemesterTerm,
             sec.AcademicYear, f.FirstName, f.LastName,
             f.Designation, d.DeptName;
GO