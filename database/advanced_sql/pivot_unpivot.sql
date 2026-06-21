USE HiSUP_DB;
GO

-- PIVOT: Semester-wise attendance matrix
-- Har student ke liye har semester ki attendance percentage ek column mein
SELECT *
FROM (
    SELECT 
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        sec.SemesterTerm,
        CAST(
            ROUND(
                CAST(SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) AS DECIMAL)
                / NULLIF(COUNT(ar.AttendanceID), 0) * 100
            , 2) AS DECIMAL(5,2)
        ) AS AttendancePct
    FROM Students s
    JOIN Enrollments e ON s.StudentID = e.StudentID
    JOIN Sections sec ON e.SectionID = sec.SectionID
    LEFT JOIN AttendanceRecords ar ON s.StudentID = ar.StudentID 
        AND sec.SectionID = ar.SectionID
    WHERE e.Status = 'Active'
    GROUP BY s.StudentID, s.RollNumber, s.FirstName, 
             s.LastName, sec.SemesterTerm
) AS SourceData
PIVOT (
    AVG(AttendancePct)
    FOR SemesterTerm IN ([Fall-2024], [Spring-2025], [Fall-2025])
) AS PivotTable
ORDER BY RollNumber;
GO

-- UNPIVOT: PIVOT result ko wapas rows mein convert karo
SELECT RollNumber, StudentName, SemesterTerm, AttendancePct
FROM (
    SELECT *
    FROM (
        SELECT 
            s.RollNumber,
            s.FirstName + ' ' + s.LastName AS StudentName,
            sec.SemesterTerm,
            CAST(
                ROUND(
                    CAST(SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) AS DECIMAL)
                    / NULLIF(COUNT(ar.AttendanceID), 0) * 100
                , 2) AS DECIMAL(5,2)
            ) AS AttendancePct
        FROM Students s
        JOIN Enrollments e ON s.StudentID = e.StudentID
        JOIN Sections sec ON e.SectionID = sec.SectionID
        LEFT JOIN AttendanceRecords ar ON s.StudentID = ar.StudentID 
            AND sec.SectionID = ar.SectionID
        WHERE e.Status = 'Active'
        GROUP BY s.StudentID, s.RollNumber, s.FirstName, 
                 s.LastName, sec.SemesterTerm
    ) AS SourceData
    PIVOT (
        AVG(AttendancePct)
        FOR SemesterTerm IN ([Fall-2024], [Spring-2025], [Fall-2025])
    ) AS PivotTable
) AS PivotResult
UNPIVOT (
    AttendancePct
    FOR SemesterTerm IN ([Fall-2024], [Spring-2025], [Fall-2025])
) AS UnpivotTable
ORDER BY RollNumber, SemesterTerm;
GO