USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE IssueLibraryBook
    @StudentID INT,
    @ItemID INT,
    @DueDate DATE,
    @NewIssueID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
            THROW 50070, 'Student does not exist or is not active.', 1;

        IF NOT EXISTS (SELECT 1 FROM LibraryItems WHERE ItemID = @ItemID)
            THROW 50071, 'Library item does not exist.', 1;

        IF NOT EXISTS (SELECT 1 FROM LibraryItems WHERE ItemID = @ItemID AND CopiesAvailable > 0)
            THROW 50072, 'No copies available for this item.', 1;

        BEGIN TRANSACTION;
        INSERT INTO LibraryIssues (ItemID, StudentID, DueDate, Status)
        VALUES (@ItemID, @StudentID, @DueDate, 'Issued');
        SET @NewIssueID = SCOPE_IDENTITY();

        UPDATE LibraryItems 
        SET CopiesAvailable = CopiesAvailable - 1 
        WHERE ItemID = @ItemID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO