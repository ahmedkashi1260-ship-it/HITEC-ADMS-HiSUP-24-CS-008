USE HiSUP_DB;
GO

CREATE OR ALTER TRIGGER trg_AfterLibraryReturn
ON LibraryIssues
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Sirf tab fire karo jab Status 'Issued' se 'Returned' ho
    IF UPDATE(Status)
    BEGIN
        UPDATE li
        SET li.CopiesAvailable = li.CopiesAvailable + 1
        FROM LibraryItems li
        JOIN inserted i ON li.ItemID = i.ItemID
        JOIN deleted d ON i.IssueID = d.IssueID
        WHERE i.Status = 'Returned' 
          AND d.Status = 'Issued';
    END
END;
GO