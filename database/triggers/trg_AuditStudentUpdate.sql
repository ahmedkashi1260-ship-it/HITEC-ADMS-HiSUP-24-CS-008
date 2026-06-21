USE HiSUP_DB;
GO

CREATE OR ALTER TRIGGER trg_AuditStudentUpdate
ON Students
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditLog (TableName, OperationType, RecordID, OldValue, NewValue, ChangedBy)
    SELECT 
        'Students',
        'UPDATE',
        i.StudentID,
        'Email:' + d.Email + 
        ',Phone:' + ISNULL(d.Phone, 'NULL') +
        ',IsActive:' + CAST(d.IsActive AS NVARCHAR),
        'Email:' + i.Email + 
        ',Phone:' + ISNULL(i.Phone, 'NULL') +
        ',IsActive:' + CAST(i.IsActive AS NVARCHAR),
        SYSTEM_USER
    FROM inserted i
    JOIN deleted d ON i.StudentID = d.StudentID;
END;
GO