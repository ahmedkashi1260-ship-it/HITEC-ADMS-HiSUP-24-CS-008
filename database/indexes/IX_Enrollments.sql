USE HiSUP_DB;
GO

-- Index 1: Non-clustered on StudentID
CREATE NONCLUSTERED INDEX IX_Enrollments_StudentID
ON Enrollments(StudentID)
INCLUDE (SectionID, Status, EnrollmentDate);
GO

-- Index 2: Non-clustered on SectionID (CourseID tak join ke liye)
CREATE NONCLUSTERED INDEX IX_Enrollments_SectionID
ON Enrollments(SectionID)
INCLUDE (StudentID, Status);
GO