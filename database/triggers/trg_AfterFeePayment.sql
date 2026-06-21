USE HiSUP_DB;
GO

CREATE OR ALTER TRIGGER trg_AfterFeePayment
ON FeePayments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditLog (TableName, OperationType, RecordID, NewValue, ChangedBy)
    SELECT 
        'FeePayments',
        'INSERT',
        i.PaymentID,
        'StudentID:' + CAST(i.StudentID AS NVARCHAR) + 
        ',Amount:' + CAST(i.AmountPaid AS NVARCHAR) +
        ',Method:' + i.PaymentMethod +
        ',Date:' + CAST(i.PaymentDate AS NVARCHAR),
        SYSTEM_USER
    FROM inserted i;
END;
GO