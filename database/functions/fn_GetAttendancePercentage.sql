USE HiSUP_DB;
GO

CREATE OR ALTER FUNCTION fn_GetAttendancePercentage(
    @StudentID INT, 
    @SectionID INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Total INT;
    DECLARE @Present INT;

    SELECT @Total = COUNT(*) 
    FROM AttendanceRecords
    WHERE StudentID = @StudentID 
      AND SectionID = @SectionID;

    SELECT @Present = COUNT(*) 
    FROM AttendanceRecords
    WHERE StudentID = @StudentID 
      AND SectionID = @SectionID 
      AND Status = 'Present';

    RETURN CASE 
        WHEN ISNULL(@Total, 0) = 0 THEN 0
        ELSE ROUND(CAST(@Present AS DECIMAL) / @Total * 100, 2)
    END;
END;
GO