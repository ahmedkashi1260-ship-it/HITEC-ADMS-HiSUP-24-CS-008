USE HiSUP_DB;
GO

CREATE NONCLUSTERED INDEX IX_AttendanceRecords_StudentID_Date
ON AttendanceRecords(StudentID, AttendanceDate)
INCLUDE (SectionID, Status);
GO