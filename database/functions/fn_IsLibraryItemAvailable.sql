USE HiSUP_DB;
GO

CREATE OR ALTER FUNCTION fn_IsLibraryItemAvailable(@ItemID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Available INT;
    
    SELECT @Available = CopiesAvailable 
    FROM LibraryItems 
    WHERE ItemID = @ItemID;

    RETURN CASE 
        WHEN ISNULL(@Available, 0) > 0 THEN 1 
        ELSE 0 
    END;
END;
GO