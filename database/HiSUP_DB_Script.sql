-- ============================================
-- HiSUP_DB: Full Database Schema
-- This file will grow as we add more tables,
-- procedures, functions, triggers, views, etc.
-- Run this entire file in SSMS to recreate the database.
-- ============================================

CREATE DATABASE HiSUP_DB;
GO

USE HiSUP_DB;
GO

-- ============================================
-- Table: Departments
-- ============================================
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DeptName NVARCHAR(100) NOT NULL UNIQUE,
    DeptCode NVARCHAR(10) NOT NULL UNIQUE,
    EstablishedYear INT CHECK (EstablishedYear >= 1990),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- ============================================
-- Table: Students
-- ============================================
CREATE TABLE Students (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    RollNumber NVARCHAR(20) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    CNIC NVARCHAR(20) NULL,
    Phone NVARCHAR(20) NULL,
    DateOfBirth DATE NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    DepartmentID INT NOT NULL,
    EnrollmentYear INT CHECK (EnrollmentYear >= 2000),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Students_Department FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- ============================================
-- Table: Faculty
-- ============================================
CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeCode NVARCHAR(20) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Phone NVARCHAR(20) NULL,
    Designation NVARCHAR(50) CHECK (Designation IN ('Lecturer', 'Assistant Professor', 'Associate Professor', 'Professor')),
    DepartmentID INT NOT NULL,
    HireDate DATE NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Faculty_Department FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- ============================================
-- Table: Staff
-- ============================================
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeCode NVARCHAR(20) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Phone NVARCHAR(20) NULL,
    JobRole NVARCHAR(50) NOT NULL,
    DepartmentID INT NULL,
    HireDate DATE NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Staff_Department FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- ============================================
-- Table: Programs
-- ============================================
CREATE TABLE Programs (
    ProgramID INT PRIMARY KEY IDENTITY(1,1),
    ProgramName NVARCHAR(100) NOT NULL,
    ProgramCode NVARCHAR(10) NOT NULL UNIQUE,
    DepartmentID INT NOT NULL,
    DegreeLevel NVARCHAR(20) CHECK (DegreeLevel IN ('Bachelors', 'Masters', 'PhD')),
    DurationYears INT CHECK (DurationYears > 0 AND DurationYears <= 6),
    TotalCreditHours INT CHECK (TotalCreditHours > 0),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Programs_Department FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- ============================================
-- Table: Courses
-- ============================================
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseCode NVARCHAR(15) NOT NULL UNIQUE,
    CourseTitle NVARCHAR(150) NOT NULL,
    ProgramID INT NOT NULL,
    CreditHours INT CHECK (CreditHours > 0 AND CreditHours <= 6),
    PrerequisiteCourseID INT NULL,
    Semester INT CHECK (Semester BETWEEN 1 AND 8),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Courses_Program FOREIGN KEY (ProgramID)
        REFERENCES Programs(ProgramID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_Courses_Prerequisite FOREIGN KEY (PrerequisiteCourseID)
        REFERENCES Courses(CourseID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: Sections
-- ============================================
CREATE TABLE Sections (
    SectionID INT PRIMARY KEY IDENTITY(1,1),
    CourseID INT NOT NULL,
    FacultyID INT NOT NULL,
    SectionName NVARCHAR(10) NOT NULL,
    SemesterTerm NVARCHAR(20) NOT NULL,
    AcademicYear NVARCHAR(10) NOT NULL,
    MaxSeats INT CHECK (MaxSeats > 0) DEFAULT 40,
    SeatsFilled INT DEFAULT 0 CHECK (SeatsFilled >= 0),
    Schedule NVARCHAR(100) NULL,
    RoomNumber NVARCHAR(20) NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Sections_Course FOREIGN KEY (CourseID)
        REFERENCES Courses(CourseID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Sections_Faculty FOREIGN KEY (FacultyID)
        REFERENCES Faculty(FacultyID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT CHK_SeatsNotExceeded CHECK (SeatsFilled <= MaxSeats)
);
GO

-- ============================================
-- Table: Enrollments
-- ============================================
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    SectionID INT NOT NULL,
    EnrollmentDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'Dropped', 'Completed')),
    CONSTRAINT FK_Enrollments_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Enrollments_Section FOREIGN KEY (SectionID)
        REFERENCES Sections(SectionID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT UQ_Student_Section UNIQUE (StudentID, SectionID)
);
GO

-- ============================================
-- Table: Grades
-- ============================================
CREATE TABLE Grades (
    GradeID INT PRIMARY KEY IDENTITY(1,1),
    EnrollmentID INT NOT NULL UNIQUE,
    MarksObtained DECIMAL(5,2) NULL CHECK (MarksObtained >= 0 AND MarksObtained <= 100),
    LetterGrade NVARCHAR(2) NULL,
    GradePoint DECIMAL(3,2) NULL CHECK (GradePoint >= 0 AND GradePoint <= 4.0),
    GradedDate DATETIME NULL,
    GradedBy INT NULL,
    CONSTRAINT FK_Grades_Enrollment FOREIGN KEY (EnrollmentID)
        REFERENCES Enrollments(EnrollmentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Grades_Faculty FOREIGN KEY (GradedBy)
        REFERENCES Faculty(FacultyID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: AttendanceRecords
-- ============================================
CREATE TABLE AttendanceRecords (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    SectionID INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    Status NVARCHAR(10) NOT NULL CHECK (Status IN ('Present', 'Absent', 'Leave')),
    MarkedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Attendance_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Attendance_Section FOREIGN KEY (SectionID)
        REFERENCES Sections(SectionID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Attendance_Faculty FOREIGN KEY (MarkedBy)
        REFERENCES Faculty(FacultyID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT UQ_Student_Section_Date UNIQUE (StudentID, SectionID, AttendanceDate)
);
GO


-- ============================================
-- Table: FeeStructure
-- ============================================
CREATE TABLE FeeStructure (
    FeeStructureID INT PRIMARY KEY IDENTITY(1,1),
    ProgramID INT NOT NULL,
    Semester INT CHECK (Semester BETWEEN 1 AND 8),
    TuitionFee DECIMAL(10,2) NOT NULL CHECK (TuitionFee >= 0),
    ExamFee DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (ExamFee >= 0),
    LibraryFee DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (LibraryFee >= 0),
    OtherCharges DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (OtherCharges >= 0),
    TotalAmount AS (TuitionFee + ExamFee + LibraryFee + OtherCharges),
    EffectiveYear INT NOT NULL,
    CONSTRAINT FK_FeeStructure_Program FOREIGN KEY (ProgramID)
        REFERENCES Programs(ProgramID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: FeePayments
-- ============================================
CREATE TABLE FeePayments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    FeeStructureID INT NOT NULL,
    AmountPaid DECIMAL(10,2) NOT NULL CHECK (AmountPaid > 0),
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(30) CHECK (PaymentMethod IN ('Cash', 'Bank Transfer', 'Online', 'Cheque')),
    TransactionReference NVARCHAR(50) NULL,
    ProcessedBy INT NULL,
    CONSTRAINT FK_FeePayments_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_FeePayments_FeeStructure FOREIGN KEY (FeeStructureID)
        REFERENCES FeeStructure(FeeStructureID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_FeePayments_Staff FOREIGN KEY (ProcessedBy)
        REFERENCES Staff(StaffID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: LibraryItems
-- ============================================
CREATE TABLE LibraryItems (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(200) NOT NULL,
    Author NVARCHAR(150) NOT NULL,
    ISBN NVARCHAR(20) NULL UNIQUE,
    ItemType NVARCHAR(20) NOT NULL CHECK (ItemType IN ('Book', 'Journal', 'Thesis', 'Magazine')),
    TotalCopies INT NOT NULL CHECK (TotalCopies >= 0),
    CopiesAvailable INT NOT NULL CHECK (CopiesAvailable >= 0),
    Publisher NVARCHAR(100) NULL,
    PublishedYear INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT CHK_CopiesAvailable CHECK (CopiesAvailable <= TotalCopies)
);
GO

-- ============================================
-- Table: LibraryIssues
-- ============================================
CREATE TABLE LibraryIssues (
    IssueID INT PRIMARY KEY IDENTITY(1,1),
    ItemID INT NOT NULL,
    StudentID INT NOT NULL,
    IssueDate DATETIME DEFAULT GETDATE(),
    DueDate DATE NOT NULL,
    ReturnDate DATETIME NULL,
    FineAmount DECIMAL(8,2) DEFAULT 0 CHECK (FineAmount >= 0),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Issued' CHECK (Status IN ('Issued', 'Returned', 'Overdue', 'Lost')),
    CONSTRAINT FK_LibraryIssues_Item FOREIGN KEY (ItemID)
        REFERENCES LibraryItems(ItemID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_LibraryIssues_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: Hostels
-- ============================================
CREATE TABLE Hostels (
    HostelID INT PRIMARY KEY IDENTITY(1,1),
    HostelName NVARCHAR(100) NOT NULL UNIQUE,
    HostelType NVARCHAR(10) NOT NULL CHECK (HostelType IN ('Boys', 'Girls')),
    TotalRooms INT NOT NULL CHECK (TotalRooms > 0),
    RoomCapacity INT NOT NULL CHECK (RoomCapacity > 0),
    Warden NVARCHAR(100) NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- ============================================
-- Table: HostelAllotments
-- ============================================
CREATE TABLE HostelAllotments (
    AllotmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL UNIQUE,
    HostelID INT NOT NULL,
    RoomNumber NVARCHAR(10) NOT NULL,
    AllotmentDate DATETIME DEFAULT GETDATE(),
    VacateDate DATETIME NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'Vacated')),
    CONSTRAINT FK_HostelAllotments_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_HostelAllotments_Hostel FOREIGN KEY (HostelID)
        REFERENCES Hostels(HostelID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: ExamSchedule
-- ============================================
CREATE TABLE ExamSchedule (
    ExamID INT PRIMARY KEY IDENTITY(1,1),
    SectionID INT NOT NULL,
    ExamType NVARCHAR(20) NOT NULL CHECK (ExamType IN ('Midterm', 'Final', 'Quiz', 'Assignment')),
    ExamDate DATETIME NOT NULL,
    DurationMinutes INT NOT NULL CHECK (DurationMinutes > 0),
    RoomNumber NVARCHAR(20) NULL,
    TotalMarks INT NOT NULL CHECK (TotalMarks > 0),
    CONSTRAINT FK_ExamSchedule_Section FOREIGN KEY (SectionID)
        REFERENCES Sections(SectionID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: Results
-- ============================================
CREATE TABLE Results (
    ResultID INT PRIMARY KEY IDENTITY(1,1),
    ExamID INT NOT NULL,
    StudentID INT NOT NULL,
    MarksObtained DECIMAL(6,2) NOT NULL CHECK (MarksObtained >= 0),
    IsAbsent BIT DEFAULT 0,
    PublishedDate DATETIME NULL,
    CONSTRAINT FK_Results_Exam FOREIGN KEY (ExamID)
        REFERENCES ExamSchedule(ExamID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Results_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT UQ_Exam_Student UNIQUE (ExamID, StudentID)
);
GO

-- ============================================
-- Table: UserAccounts
-- ============================================
CREATE TABLE UserAccounts (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Student', 'Faculty', 'Admin', 'Finance')),
    StudentID INT NULL,
    FacultyID INT NULL,
    LastLogin DATETIME NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UserAccounts_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_UserAccounts_Faculty FOREIGN KEY (FacultyID)
        REFERENCES Faculty(FacultyID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT CHK_OneRoleLink CHECK (
        (Role = 'Student' AND StudentID IS NOT NULL AND FacultyID IS NULL) OR
        (Role = 'Faculty' AND FacultyID IS NOT NULL AND StudentID IS NULL) OR
        (Role IN ('Admin', 'Finance') AND StudentID IS NULL AND FacultyID IS NULL)
    )
);
GO

-- ============================================
-- Table: AuditLog
-- ============================================
CREATE TABLE AuditLog (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    TableName NVARCHAR(50) NOT NULL,
    OperationType NVARCHAR(10) NOT NULL CHECK (OperationType IN ('INSERT', 'UPDATE', 'DELETE')),
    RecordID INT NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    ChangedBy NVARCHAR(100) NOT NULL,
    ChangedAt DATETIME DEFAULT GETDATE()
);
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE RegisterStudent
    @RollNumber NVARCHAR(20),
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @CNIC NVARCHAR(20),
    @Phone NVARCHAR(20),
    @DateOfBirth DATE,
    @Gender NVARCHAR(10),
    @DepartmentID INT,
    @EnrollmentYear INT,
    @NewStudentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @DepartmentID NOT IN (SELECT DepartmentID FROM Departments)
        BEGIN
            THROW 50001, 'Invalid DepartmentID: department does not exist.', 1;
        END

        IF EXISTS (SELECT 1 FROM Students WHERE Email = @Email)
        BEGIN
            THROW 50002, 'A student with this email already exists.', 1;
        END

        IF EXISTS (SELECT 1 FROM Students WHERE RollNumber = @RollNumber)
        BEGIN
            THROW 50003, 'A student with this roll number already exists.', 1;
        END

        BEGIN TRANSACTION;

        INSERT INTO Students (RollNumber, FirstName, LastName, Email, CNIC, Phone, DateOfBirth, Gender, DepartmentID, EnrollmentYear)
        VALUES (@RollNumber, @FirstName, @LastName, @Email, @CNIC, @Phone, @DateOfBirth, @Gender, @DepartmentID, @EnrollmentYear);

        SET @NewStudentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE EnrollInCourse
    @StudentID INT,
    @SectionID INT,
    @NewEnrollmentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
        BEGIN
            THROW 50010, 'Student does not exist or is not active.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM Sections WHERE SectionID = @SectionID)
        BEGIN
            THROW 50011, 'Section does not exist.', 1;
        END

        IF EXISTS (SELECT 1 FROM Enrollments WHERE StudentID = @StudentID AND SectionID = @SectionID AND Status = 'Active')
        BEGIN
            THROW 50012, 'Student is already enrolled in this section.', 1;
        END

        IF EXISTS (SELECT 1 FROM Sections WHERE SectionID = @SectionID AND SeatsFilled >= MaxSeats)
        BEGIN
            THROW 50013, 'No seats available in this section.', 1;
        END

        BEGIN TRANSACTION;

        INSERT INTO Enrollments (StudentID, SectionID, Status)
        VALUES (@StudentID, @SectionID, 'Active');

        SET @NewEnrollmentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE ProcessFeePayment
    @StudentID INT,
    @FeeStructureID INT,
    @AmountPaid DECIMAL(10,2),
    @PaymentMethod NVARCHAR(30),
    @TransactionReference NVARCHAR(50) = NULL,
    @ProcessedBy INT = NULL,
    @NewPaymentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
        BEGIN
            THROW 50020, 'Student does not exist or is not active.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM FeeStructure WHERE FeeStructureID = @FeeStructureID)
        BEGIN
            THROW 50021, 'Fee structure does not exist.', 1;
        END

        IF @AmountPaid <= 0
        BEGIN
            THROW 50022, 'Payment amount must be greater than zero.', 1;
        END

        IF @PaymentMethod NOT IN ('Cash', 'Bank Transfer', 'Online', 'Cheque')
        BEGIN
            THROW 50023, 'Invalid payment method.', 1;
        END

        BEGIN TRANSACTION;

        INSERT INTO FeePayments (StudentID, FeeStructureID, AmountPaid, PaymentMethod, TransactionReference, ProcessedBy)
        VALUES (@StudentID, @FeeStructureID, @AmountPaid, @PaymentMethod, @TransactionReference, @ProcessedBy);

        SET @NewPaymentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GenerateTranscript
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
        BEGIN
            THROW 50030, 'Student does not exist.', 1;
        END

        ;WITH TranscriptCTE AS (
            SELECT
                s.StudentID,
                s.RollNumber,
                s.FirstName + ' ' + s.LastName AS StudentName,
                c.CourseCode,
                c.CourseTitle,
                c.CreditHours,
                sec.SemesterTerm,
                sec.AcademicYear,
                g.MarksObtained,
                g.LetterGrade,
                g.GradePoint
            FROM Enrollments e
            JOIN Students s ON e.StudentID = s.StudentID
            JOIN Sections sec ON e.SectionID = sec.SectionID
            JOIN Courses c ON sec.CourseID = c.CourseID
            LEFT JOIN Grades g ON g.EnrollmentID = e.EnrollmentID
            WHERE e.StudentID = @StudentID
        )
        SELECT
            StudentID,
            RollNumber,
            StudentName,
            CourseCode,
            CourseTitle,
            CreditHours,
            SemesterTerm,
            AcademicYear,
            MarksObtained,
            LetterGrade,
            GradePoint,
            (GradePoint * CreditHours) AS QualityPoints
        FROM TranscriptCTE
        ORDER BY AcademicYear, SemesterTerm;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE CalculateSemesterGPA
    @StudentID INT,
    @SemesterTerm NVARCHAR(20),
    @AcademicYear NVARCHAR(10),
    @SemesterGPA DECIMAL(3,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
        BEGIN
            THROW 50040, 'Student does not exist.', 1;
        END

        DECLARE @TotalQualityPoints DECIMAL(10,2);
        DECLARE @TotalCreditHours INT;

        SELECT
            @TotalQualityPoints = SUM(g.GradePoint * c.CreditHours),
            @TotalCreditHours = SUM(c.CreditHours)
        FROM Enrollments e
        JOIN Sections sec ON e.SectionID = sec.SectionID
        JOIN Courses c ON sec.CourseID = c.CourseID
        JOIN Grades g ON g.EnrollmentID = e.EnrollmentID
        WHERE e.StudentID = @StudentID
          AND sec.SemesterTerm = @SemesterTerm
          AND sec.AcademicYear = @AcademicYear
          AND g.GradePoint IS NOT NULL;

        IF @TotalCreditHours IS NULL OR @TotalCreditHours = 0
        BEGIN
            SET @SemesterGPA = 0;
        END
        ELSE
        BEGIN
            SET @SemesterGPA = ROUND(@TotalQualityPoints / @TotalCreditHours, 2);
        END

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE AllocateHostelRoom
    @StudentID INT,
    @HostelID INT,
    @RoomNumber NVARCHAR(10),
    @NewAllotmentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
            THROW 50060, 'Student does not exist or is not active.', 1;

        IF NOT EXISTS (SELECT 1 FROM Hostels WHERE HostelID = @HostelID)
            THROW 50061, 'Hostel does not exist.', 1;

        IF EXISTS (SELECT 1 FROM HostelAllotments WHERE StudentID = @StudentID AND Status = 'Active')
            THROW 50062, 'Student already has an active hostel allotment.', 1;

        DECLARE @TotalRooms INT, @OccupiedRooms INT;
        SELECT @TotalRooms = TotalRooms FROM Hostels WHERE HostelID = @HostelID;
        SELECT @OccupiedRooms = COUNT(DISTINCT RoomNumber) 
        FROM HostelAllotments WHERE HostelID = @HostelID AND Status = 'Active';

        IF @OccupiedRooms >= @TotalRooms
            THROW 50063, 'No rooms available in this hostel.', 1;

        BEGIN TRANSACTION;
        INSERT INTO HostelAllotments (StudentID, HostelID, RoomNumber, Status)
        VALUES (@StudentID, @HostelID, @RoomNumber, 'Active');
        SET @NewAllotmentID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

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

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE ReturnLibraryBook
    @IssueID INT,
    @ReturnDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @ReturnDate IS NULL SET @ReturnDate = GETDATE();

        IF NOT EXISTS (SELECT 1 FROM LibraryIssues WHERE IssueID = @IssueID AND Status = 'Issued')
            THROW 50080, 'Issue record not found or already returned.', 1;

        DECLARE @DueDate DATE, @ItemID INT, @Fine DECIMAL(8,2);
        SELECT @DueDate = DueDate, @ItemID = ItemID 
        FROM LibraryIssues WHERE IssueID = @IssueID;

        SET @Fine = CASE 
            WHEN @ReturnDate > @DueDate
            THEN DATEDIFF(DAY, @DueDate, @ReturnDate) * 10.00
            ELSE 0 
        END;

        BEGIN TRANSACTION;
        UPDATE LibraryIssues
        SET ReturnDate = @ReturnDate, Status = 'Returned', FineAmount = @Fine
        WHERE IssueID = @IssueID;

        UPDATE LibraryItems 
        SET CopiesAvailable = CopiesAvailable + 1 
        WHERE ItemID = @ItemID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE AddExamResult
    @ExamID INT,
    @StudentID INT,
    @MarksObtained DECIMAL(6,2),
    @IsAbsent BIT = 0,
    @NewResultID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ExamSchedule WHERE ExamID = @ExamID)
            THROW 50090, 'Exam does not exist.', 1;

        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50091, 'Student does not exist.', 1;

        DECLARE @TotalMarks INT;
        SELECT @TotalMarks = TotalMarks FROM ExamSchedule WHERE ExamID = @ExamID;

        IF @MarksObtained > @TotalMarks
            THROW 50092, 'Marks obtained cannot exceed total marks.', 1;

        BEGIN TRANSACTION;
        INSERT INTO Results (ExamID, StudentID, MarksObtained, IsAbsent, PublishedDate)
        VALUES (@ExamID, @StudentID, @MarksObtained, @IsAbsent, GETDATE());
        SET @NewResultID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GetStudentReport
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50100, 'Student does not exist.', 1;

        SELECT 
            s.StudentID, 
            s.RollNumber,
            s.FirstName + ' ' + s.LastName AS FullName,
            d.DeptName,
            s.EnrollmentYear,
            COUNT(DISTINCT e.EnrollmentID) AS TotalEnrollments,
            COUNT(DISTINCT CASE WHEN e.Status = 'Active' THEN e.EnrollmentID END) AS ActiveEnrollments,
            ROUND(AVG(g.GradePoint), 2) AS CGPA,
            COUNT(DISTINCT CASE WHEN ar.Status = 'Present' THEN ar.AttendanceID END) AS TotalPresent,
            COUNT(DISTINCT ar.AttendanceID) AS TotalClasses,
            ISNULL(SUM(fp.AmountPaid), 0) AS TotalFeesPaid
        FROM Students s
        JOIN Departments d ON s.DepartmentID = d.DepartmentID
        LEFT JOIN Enrollments e ON s.StudentID = e.StudentID
        LEFT JOIN Grades g ON e.EnrollmentID = g.EnrollmentID
        LEFT JOIN AttendanceRecords ar ON s.StudentID = ar.StudentID
        LEFT JOIN FeePayments fp ON s.StudentID = fp.StudentID
        WHERE s.StudentID = @StudentID
        GROUP BY s.StudentID, s.RollNumber, s.FirstName, s.LastName, 
                 d.DeptName, s.EnrollmentYear;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GetFacultyWorkload
    @FacultyID INT,
    @AcademicYear NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Faculty WHERE FacultyID = @FacultyID)
            THROW 50110, 'Faculty does not exist.', 1;

        SELECT 
            f.FacultyID,
            f.FirstName + ' ' + f.LastName AS FacultyName,
            f.Designation,
            d.DeptName,
            sec.AcademicYear,
            sec.SemesterTerm,
            COUNT(DISTINCT sec.SectionID) AS TotalSections,
            SUM(DISTINCT c.CreditHours) AS TotalCreditHours,
            COUNT(DISTINCT e.StudentID) AS TotalStudents
        FROM Faculty f
        JOIN Departments d ON f.DepartmentID = d.DepartmentID
        JOIN Sections sec ON f.FacultyID = sec.FacultyID
        JOIN Courses c ON sec.CourseID = c.CourseID
        LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID 
            AND e.Status = 'Active'
        WHERE f.FacultyID = @FacultyID
          AND (@AcademicYear IS NULL OR sec.AcademicYear = @AcademicYear)
        GROUP BY f.FacultyID, f.FirstName, f.LastName, f.Designation, 
                 d.DeptName, sec.AcademicYear, sec.SemesterTerm
        ORDER BY sec.AcademicYear DESC, sec.SemesterTerm;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GetDepartmentEnrollment
    @DepartmentID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            d.DepartmentID, 
            d.DeptName, 
            d.DeptCode,
            COUNT(DISTINCT s.StudentID) AS TotalStudents,
            COUNT(DISTINCT f.FacultyID) AS TotalFaculty,
            COUNT(DISTINCT p.ProgramID) AS TotalPrograms,
            COUNT(DISTINCT e.EnrollmentID) AS ActiveEnrollments
        FROM Departments d
        LEFT JOIN Students s ON d.DepartmentID = s.DepartmentID 
            AND s.IsActive = 1
        LEFT JOIN Faculty f ON d.DepartmentID = f.DepartmentID 
            AND f.IsActive = 1
        LEFT JOIN Programs p ON d.DepartmentID = p.DepartmentID 
            AND p.IsActive = 1
        LEFT JOIN Courses c ON p.ProgramID = c.ProgramID
        LEFT JOIN Sections sec ON c.CourseID = sec.CourseID
        LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID 
            AND e.Status = 'Active'
        WHERE (@DepartmentID IS NULL OR d.DepartmentID = @DepartmentID)
        GROUP BY d.DepartmentID, d.DeptName, d.DeptCode
        ORDER BY d.DeptName;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GenerateFeeSlip
    @StudentID INT,
    @Semester INT,
    @AcademicYear INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50120, 'Student does not exist.', 1;

        SELECT 
            s.RollNumber,
            s.FirstName + ' ' + s.LastName AS StudentName,
            d.DeptName,
            p.ProgramName,
            fs.Semester,
            @AcademicYear AS AcademicYear,
            fs.TuitionFee,
            fs.ExamFee,
            fs.LibraryFee,
            fs.OtherCharges,
            fs.TotalAmount AS TotalDue,
            ISNULL(SUM(fp.AmountPaid), 0) AS TotalPaid,
            fs.TotalAmount - ISNULL(SUM(fp.AmountPaid), 0) AS OutstandingBalance,
            CASE 
                WHEN fs.TotalAmount - ISNULL(SUM(fp.AmountPaid), 0) <= 0 
                THEN 'Cleared' 
                ELSE 'Pending' 
            END AS FeeStatus
        FROM Students s
        JOIN Departments d ON s.DepartmentID = d.DepartmentID
        JOIN Programs p ON d.DepartmentID = p.DepartmentID
        JOIN FeeStructure fs ON p.ProgramID = fs.ProgramID 
            AND fs.Semester = @Semester 
            AND fs.EffectiveYear = @AcademicYear
        LEFT JOIN FeePayments fp ON s.StudentID = fp.StudentID 
            AND fp.FeeStructureID = fs.FeeStructureID
        WHERE s.StudentID = @StudentID
        GROUP BY s.RollNumber, s.FirstName, s.LastName, d.DeptName, p.ProgramName,
                 fs.Semester, fs.TuitionFee, fs.ExamFee, fs.LibraryFee, 
                 fs.OtherCharges, fs.TotalAmount;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER FUNCTION fn_CalculateCGPA(@StudentID INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @CGPA DECIMAL(3,2);
    
    SELECT @CGPA = ROUND(
        SUM(g.GradePoint * c.CreditHours) / NULLIF(SUM(c.CreditHours), 0),
        2)
    FROM Enrollments e
    JOIN Sections sec ON e.SectionID = sec.SectionID
    JOIN Courses c ON sec.CourseID = c.CourseID
    JOIN Grades g ON g.EnrollmentID = e.EnrollmentID
    WHERE e.StudentID = @StudentID 
      AND g.GradePoint IS NOT NULL;

    RETURN ISNULL(@CGPA, 0.00);
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER FUNCTION fn_GetLetterGrade(@Marks DECIMAL(5,2))
RETURNS NVARCHAR(2)
AS
BEGIN
    RETURN CASE
        WHEN @Marks >= 90 THEN 'A+'
        WHEN @Marks >= 85 THEN 'A'
        WHEN @Marks >= 80 THEN 'A-'
        WHEN @Marks >= 75 THEN 'B+'
        WHEN @Marks >= 70 THEN 'B'
        WHEN @Marks >= 65 THEN 'B-'
        WHEN @Marks >= 60 THEN 'C+'
        WHEN @Marks >= 55 THEN 'C'
        WHEN @Marks >= 50 THEN 'C-'
        WHEN @Marks >= 45 THEN 'D'
        ELSE 'F'
    END;
END;
GO

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


USE HiSUP_DB;
GO

CREATE OR ALTER FUNCTION fn_GetOutstandingFee(
    @StudentID INT, 
    @FeeStructureID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalDue DECIMAL(10,2);
    DECLARE @TotalPaid DECIMAL(10,2);

    SELECT @TotalDue = TotalAmount 
    FROM FeeStructure 
    WHERE FeeStructureID = @FeeStructureID;

    SELECT @TotalPaid = ISNULL(SUM(AmountPaid), 0) 
    FROM FeePayments
    WHERE StudentID = @StudentID 
      AND FeeStructureID = @FeeStructureID;

    RETURN ISNULL(@TotalDue, 0) - ISNULL(@TotalPaid, 0);
END;
GO

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

USE HiSUP_DB;
GO

CREATE OR ALTER TRIGGER trg_AfterEnrollment
ON Enrollments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Sections
    SET SeatsFilled = SeatsFilled + 1
    WHERE SectionID IN (
        SELECT SectionID 
        FROM inserted 
        WHERE Status = 'Active'
    );
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER TRIGGER trg_AfterGradeInsert
ON Grades
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE g
    SET g.LetterGrade = dbo.fn_GetLetterGrade(i.MarksObtained)
    FROM Grades g
    JOIN inserted i ON g.GradeID = i.GradeID
    WHERE i.MarksObtained IS NOT NULL;
END;
GO

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

USE HiSUP_DB;
GO

CREATE OR ALTER TRIGGER trg_PreventDuplicateEnrollment
ON Enrollments
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check duplicate enrollment
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Enrollments e ON i.StudentID = e.StudentID 
            AND i.SectionID = e.SectionID 
            AND e.Status = 'Active'
    )
    BEGIN
        THROW 50200, 'Duplicate enrollment: student is already enrolled in this section.', 1;
        RETURN;
    END

    -- Agar duplicate nahi to actual insert karo
    INSERT INTO Enrollments (StudentID, SectionID, EnrollmentDate, Status)
    SELECT 
        StudentID, 
        SectionID, 
        ISNULL(EnrollmentDate, GETDATE()), 
        ISNULL(Status, 'Active')
    FROM inserted;
END;
GO

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

USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_StudentDashboard
AS
    SELECT 
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS FullName,
        s.Email,
        s.EnrollmentYear,
        s.IsActive,
        d.DeptName,
        d.DeptCode,
        dbo.fn_CalculateCGPA(s.StudentID) AS CGPA,
        COUNT(DISTINCT e.EnrollmentID) AS TotalEnrollments,
        COUNT(DISTINCT CASE WHEN e.Status = 'Active' 
              THEN e.EnrollmentID END) AS ActiveEnrollments
    FROM Students s
    JOIN Departments d ON s.DepartmentID = d.DepartmentID
    LEFT JOIN Enrollments e ON s.StudentID = e.StudentID
    GROUP BY s.StudentID, s.RollNumber, s.FirstName, s.LastName,
             s.Email, s.EnrollmentYear, s.IsActive,
             d.DeptName, d.DeptCode;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_FacultyCourseLoad
AS
    SELECT 
        f.FacultyID,
        f.FirstName + ' ' + f.LastName AS FacultyName,
        f.Designation,
        d.DeptName,
        sec.AcademicYear,
        sec.SemesterTerm,
        COUNT(DISTINCT sec.SectionID) AS TotalSections,
        SUM(c.CreditHours) AS TotalCreditHours,
        COUNT(DISTINCT e.StudentID) AS TotalStudents
    FROM Faculty f
    JOIN Departments d ON f.DepartmentID = d.DepartmentID
    LEFT JOIN Sections sec ON f.FacultyID = sec.FacultyID
    LEFT JOIN Courses c ON sec.CourseID = c.CourseID
    LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID 
        AND e.Status = 'Active'
    GROUP BY f.FacultyID, f.FirstName, f.LastName, 
             f.Designation, d.DeptName,
             sec.AcademicYear, sec.SemesterTerm;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_DepartmentEnrollmentSummary
AS
    SELECT 
        d.DepartmentID,
        d.DeptName,
        d.DeptCode,
        d.EstablishedYear,
        COUNT(DISTINCT s.StudentID) AS TotalStudents,
        COUNT(DISTINCT f.FacultyID) AS TotalFaculty,
        COUNT(DISTINCT p.ProgramID) AS TotalPrograms,
        COUNT(DISTINCT c.CourseID) AS TotalCourses,
        COUNT(DISTINCT e.EnrollmentID) AS ActiveEnrollments
    FROM Departments d
    LEFT JOIN Students s ON d.DepartmentID = s.DepartmentID 
        AND s.IsActive = 1
    LEFT JOIN Faculty f ON d.DepartmentID = f.DepartmentID 
        AND f.IsActive = 1
    LEFT JOIN Programs p ON d.DepartmentID = p.DepartmentID
    LEFT JOIN Courses c ON p.ProgramID = c.ProgramID 
        AND c.IsActive = 1
    LEFT JOIN Sections sec ON c.CourseID = sec.CourseID
    LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID 
        AND e.Status = 'Active'
    GROUP BY d.DepartmentID, d.DeptName, d.DeptCode, d.EstablishedYear;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_FeeDefaulters
AS
    SELECT 
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        s.Email,
        s.Phone,
        d.DeptName,
        p.ProgramName,
        fs.Semester,
        fs.EffectiveYear,
        fs.TotalAmount AS TotalDue,
        ISNULL(SUM(fp.AmountPaid), 0) AS TotalPaid,
        fs.TotalAmount - ISNULL(SUM(fp.AmountPaid), 0) AS OutstandingBalance
    FROM Students s
    JOIN Departments d ON s.DepartmentID = d.DepartmentID
    JOIN Programs p ON d.DepartmentID = p.DepartmentID
    JOIN FeeStructure fs ON p.ProgramID = fs.ProgramID
    LEFT JOIN FeePayments fp ON s.StudentID = fp.StudentID 
        AND fp.FeeStructureID = fs.FeeStructureID
    WHERE s.IsActive = 1
    GROUP BY s.StudentID, s.RollNumber, s.FirstName, s.LastName,
             s.Email, s.Phone, d.DeptName, p.ProgramName,
             fs.Semester, fs.EffectiveYear, fs.TotalAmount
    HAVING fs.TotalAmount - ISNULL(SUM(fp.AmountPaid), 0) > 0;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_AttendanceShortfall
AS
    SELECT 
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        c.CourseCode,
        c.CourseTitle,
        sec.SectionID,
        sec.SemesterTerm,
        sec.AcademicYear,
        COUNT(ar.AttendanceID) AS TotalClasses,
        SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
        SUM(CASE WHEN ar.Status = 'Absent' THEN 1 ELSE 0 END) AS AbsentCount,
        ROUND(
            CAST(SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) AS DECIMAL)
            / NULLIF(COUNT(ar.AttendanceID), 0) * 100
        , 2) AS AttendancePct
    FROM Students s
    JOIN Enrollments e ON s.StudentID = e.StudentID
    JOIN Sections sec ON e.SectionID = sec.SectionID
    JOIN Courses c ON sec.CourseID = c.CourseID
    LEFT JOIN AttendanceRecords ar ON s.StudentID = ar.StudentID 
        AND sec.SectionID = ar.SectionID
    WHERE e.Status = 'Active'
    GROUP BY s.StudentID, s.RollNumber, s.FirstName, s.LastName,
             c.CourseCode, c.CourseTitle, sec.SectionID,
             sec.SemesterTerm, sec.AcademicYear
    HAVING 
        ROUND(
            CAST(SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) AS DECIMAL)
            / NULLIF(COUNT(ar.AttendanceID), 0) * 100
        , 2) < 75;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_LibraryOverdue
AS
    SELECT 
        li.IssueID,
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        s.Email,
        s.Phone,
        litem.ItemID,
        litem.Title,
        litem.Author,
        litem.ItemType,
        li.IssueDate,
        li.DueDate,
        DATEDIFF(DAY, li.DueDate, GETDATE()) AS DaysOverdue,
        DATEDIFF(DAY, li.DueDate, GETDATE()) * 10.00 AS EstimatedFine
    FROM LibraryIssues li
    JOIN Students s ON li.StudentID = s.StudentID
    JOIN LibraryItems litem ON li.ItemID = litem.ItemID
    WHERE li.Status = 'Issued' 
      AND li.DueDate < CAST(GETDATE() AS DATE);
GO

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

USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_ResultCard
WITH SCHEMABINDING
AS
    SELECT 
        e.EnrollmentID,
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        d.DeptName,
        p.ProgramName,
        c.CourseCode,
        c.CourseTitle,
        c.CreditHours,
        sec.SemesterTerm,
        sec.AcademicYear,
        g.MarksObtained,
        g.LetterGrade,
        g.GradePoint,
        g.GradePoint * c.CreditHours AS QualityPoints
    FROM dbo.Enrollments e
    JOIN dbo.Students s ON e.StudentID = s.StudentID
    JOIN dbo.Sections sec ON e.SectionID = sec.SectionID
    JOIN dbo.Courses c ON sec.CourseID = c.CourseID
    JOIN dbo.Departments d ON s.DepartmentID = d.DepartmentID
    JOIN dbo.Programs p ON c.ProgramID = p.ProgramID
    LEFT JOIN dbo.Grades g ON g.EnrollmentID = e.EnrollmentID;
GO

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

USE HiSUP_DB;
GO

CREATE NONCLUSTERED INDEX IX_LibraryIssues_ReturnDate
ON LibraryIssues(ReturnDate)
INCLUDE (StudentID, ItemID, Status, FineAmount);
GO

USE HiSUP_DB;
GO

CREATE NONCLUSTERED INDEX IX_Enrollments_Active_Filtered
ON Enrollments(StudentID, SectionID)
INCLUDE (EnrollmentDate, Status)
WHERE Status = 'Active';
GO

USE HiSUP_DB;
GO

-- Step 1: Chaar roles banao
CREATE ROLE db_student;
CREATE ROLE db_faculty;
CREATE ROLE db_admin;
CREATE ROLE db_finance;
GO

-- Step 2: Student role -- sirf procedures execute kar sakta hai, direct table access nahi
GRANT EXECUTE ON RegisterStudent TO db_student;
GRANT EXECUTE ON EnrollInCourse TO db_student;
GRANT EXECUTE ON ProcessFeePayment TO db_student;
GRANT EXECUTE ON GenerateTranscript TO db_student;
GRANT EXECUTE ON CalculateSemesterGPA TO db_student;
GRANT EXECUTE ON MarkAttendance TO db_student;
GRANT EXECUTE ON GetStudentReport TO db_student;
GRANT EXECUTE ON GenerateFeeSlip TO db_student;
GRANT EXECUTE ON SearchCourses TO db_student;
GRANT EXECUTE ON IssueLibraryBook TO db_student;
GRANT EXECUTE ON ReturnLibraryBook TO db_student;
GRANT SELECT ON vw_StudentDashboard TO db_student;
GRANT SELECT ON vw_ResultCard TO db_student;
GRANT SELECT ON vw_AttendanceShortfall TO db_student;
GRANT SELECT ON vw_ExamTimetable TO db_student;

-- Direct table access DENY karo student ko
DENY SELECT ON Grades TO db_student;
DENY SELECT ON FeePayments TO db_student;
DENY SELECT ON Enrollments TO db_student;
GO

-- Step 3: Faculty role
GRANT EXECUTE ON MarkAttendance TO db_faculty;
GRANT EXECUTE ON AddExamResult TO db_faculty;
GRANT EXECUTE ON GetFacultyWorkload TO db_faculty;
GRANT EXECUTE ON GetStudentReport TO db_faculty;
GRANT EXECUTE ON SearchCourses TO db_faculty;
GRANT SELECT ON vw_FacultyCourseLoad TO db_faculty;
GRANT SELECT ON vw_AttendanceShortfall TO db_faculty;
GRANT SELECT ON vw_ExamTimetable TO db_faculty;
GRANT SELECT ON vw_ResultCard TO db_faculty;
GO

-- Step 4: Admin role -- sab kuch
GRANT EXECUTE ON RegisterStudent TO db_admin;
GRANT EXECUTE ON EnrollInCourse TO db_admin;
GRANT EXECUTE ON ProcessFeePayment TO db_admin;
GRANT EXECUTE ON GenerateTranscript TO db_admin;
GRANT EXECUTE ON CalculateSemesterGPA TO db_admin;
GRANT EXECUTE ON MarkAttendance TO db_admin;
GRANT EXECUTE ON AllocateHostelRoom TO db_admin;
GRANT EXECUTE ON IssueLibraryBook TO db_admin;
GRANT EXECUTE ON ReturnLibraryBook TO db_admin;
GRANT EXECUTE ON AddExamResult TO db_admin;
GRANT EXECUTE ON GetStudentReport TO db_admin;
GRANT EXECUTE ON GetFacultyWorkload TO db_admin;
GRANT EXECUTE ON GetDepartmentEnrollment TO db_admin;
GRANT EXECUTE ON GenerateFeeSlip TO db_admin;
GRANT EXECUTE ON SearchCourses TO db_admin;
GRANT SELECT ON vw_StudentDashboard TO db_admin;
GRANT SELECT ON vw_FacultyCourseLoad TO db_admin;
GRANT SELECT ON vw_DepartmentEnrollmentSummary TO db_admin;
GRANT SELECT ON vw_FeeDefaulters TO db_admin;
GRANT SELECT ON vw_AttendanceShortfall TO db_admin;
GRANT SELECT ON vw_LibraryOverdue TO db_admin;
GRANT SELECT ON vw_ExamTimetable TO db_admin;
GRANT SELECT ON vw_ResultCard TO db_admin;
GO

-- Step 5: Finance role
GRANT EXECUTE ON ProcessFeePayment TO db_finance;
GRANT EXECUTE ON GenerateFeeSlip TO db_finance;
GRANT EXECUTE ON GetStudentReport TO db_finance;
GRANT SELECT ON vw_FeeDefaulters TO db_finance;
GRANT SELECT ON vw_StudentDashboard TO db_finance;
GO

USE HiSUP_DB;
GO

-- Pehle agar pehle wali policies bani hoon to drop karo
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'EnrollmentAccessPolicy')
    DROP SECURITY POLICY EnrollmentAccessPolicy;
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'GradeAccessPolicy')
    DROP SECURITY POLICY GradeAccessPolicy;
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'FeePaymentAccessPolicy')
    DROP SECURITY POLICY FeePaymentAccessPolicy;
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'fn_StudentAccessPredicate')
    DROP FUNCTION Security.fn_StudentAccessPredicate;
GO

-- Predicate function for StudentID columns
CREATE OR ALTER FUNCTION Security.fn_StudentAccessPredicate(@StudentID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS AccessResult
    WHERE 
        IS_MEMBER('db_admin') = 1
        OR IS_MEMBER('db_finance') = 1
        OR IS_MEMBER('db_faculty') = 1
        OR (
            IS_MEMBER('db_student') = 1
            AND @StudentID = CAST(SESSION_CONTEXT(N'StudentID') AS INT)
        );
GO

-- Predicate function for Grades (EnrollmentID se StudentID check karna hoga)
CREATE OR ALTER FUNCTION Security.fn_GradeAccessPredicate(@EnrollmentID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS AccessResult
    WHERE
        IS_MEMBER('db_admin') = 1
        OR IS_MEMBER('db_finance') = 1
        OR IS_MEMBER('db_faculty') = 1
        OR (
            IS_MEMBER('db_student') = 1
            AND EXISTS (
                SELECT 1 FROM dbo.Enrollments e
                WHERE e.EnrollmentID = @EnrollmentID
                AND e.StudentID = CAST(SESSION_CONTEXT(N'StudentID') AS INT)
            )
        );
GO

-- RLS Policies
CREATE SECURITY POLICY EnrollmentAccessPolicy
ADD FILTER PREDICATE Security.fn_StudentAccessPredicate(StudentID)
ON dbo.Enrollments
WITH (STATE = ON);
GO

CREATE SECURITY POLICY GradeAccessPolicy
ADD FILTER PREDICATE Security.fn_GradeAccessPredicate(EnrollmentID)
ON dbo.Grades
WITH (STATE = ON);
GO

CREATE SECURITY POLICY FeePaymentAccessPolicy
ADD FILTER PREDICATE Security.fn_StudentAccessPredicate(StudentID)
ON dbo.FeePayments
WITH (STATE = ON);
GO

USE HiSUP_DB;
GO

-- Encrypt procedure
CREATE OR ALTER PROCEDURE UpdateStudentSensitiveInfo
    @StudentID INT,
    @CNIC NVARCHAR(20),
    @BankAccount NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        OPEN SYMMETRIC KEY HiSUP_SymKey
        DECRYPTION BY CERTIFICATE HiSUP_Cert;

        UPDATE Students
        SET 
            CNIC = CONVERT(NVARCHAR(256), 
                ENCRYPTBYKEY(KEY_GUID('HiSUP_SymKey'), @CNIC)),
            BankAccount = CONVERT(NVARCHAR(256), 
                ENCRYPTBYKEY(KEY_GUID('HiSUP_SymKey'), @BankAccount))
        WHERE StudentID = @StudentID;

        CLOSE SYMMETRIC KEY HiSUP_SymKey;
    END TRY
    BEGIN CATCH
        CLOSE SYMMETRIC KEY HiSUP_SymKey;
        THROW;
    END CATCH
END;
GO

-- Decrypt procedure
CREATE OR ALTER PROCEDURE GetStudentSensitiveInfo
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    OPEN SYMMETRIC KEY HiSUP_SymKey
    DECRYPTION BY CERTIFICATE HiSUP_Cert;

    SELECT 
        StudentID,
        RollNumber,
        FirstName + ' ' + LastName AS FullName,
        CONVERT(NVARCHAR(20), 
            DECRYPTBYKEY(CONVERT(VARBINARY(256), CNIC))) AS CNIC_Decrypted,
        CONVERT(NVARCHAR(30), 
            DECRYPTBYKEY(CONVERT(VARBINARY(256), BankAccount))) AS BankAccount_Decrypted
    FROM Students
    WHERE StudentID = @StudentID;

    CLOSE SYMMETRIC KEY HiSUP_SymKey;
END;
GO

-- Test karo
EXEC UpdateStudentSensitiveInfo 
    @StudentID = 1, 
    @CNIC = '3740512345678',
    @BankAccount = 'PK36SCBL0000001123456702';

-- Encrypted data dekho (garbled hoga)
SELECT StudentID, CNIC, BankAccount FROM Students WHERE StudentID = 1;

-- Decrypted data dekho
EXEC GetStudentSensitiveInfo @StudentID = 1;
GO

USE HiSUP_DB;
GO

-- CTE 1: Recursive CTE -- Course Prerequisites Chain
WITH RecursivePrerequisites AS (
    -- Base case: starting course
    SELECT 
        c.CourseID,
        c.CourseCode,
        c.CourseTitle,
        c.PrerequisiteCourseID,
        0 AS Level,
        CAST(c.CourseCode AS NVARCHAR(MAX)) AS PrerequisiteChain
    FROM Courses c
    WHERE c.PrerequisiteCourseID IS NULL

    UNION ALL

    -- Recursive case: courses that have prerequisites
    SELECT 
        c.CourseID,
        c.CourseCode,
        c.CourseTitle,
        c.PrerequisiteCourseID,
        rp.Level + 1,
        rp.PrerequisiteChain + N' -> ' + c.CourseCode
    FROM Courses c
    JOIN RecursivePrerequisites rp ON c.PrerequisiteCourseID = rp.CourseID
)
SELECT * FROM RecursivePrerequisites
ORDER BY Level, CourseCode;
GO

-- CTE 2: Regular CTE -- Top Student per Department
WITH StudentGPA AS (
    SELECT 
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        s.DepartmentID,
        d.DeptName,
        ROUND(SUM(g.GradePoint * c.CreditHours) / 
            NULLIF(SUM(c.CreditHours), 0), 2) AS CGPA
    FROM Students s
    JOIN Departments d ON s.DepartmentID = d.DepartmentID
    JOIN Enrollments e ON s.StudentID = e.StudentID
    JOIN Sections sec ON e.SectionID = sec.SectionID
    JOIN Courses c ON sec.CourseID = c.CourseID
    JOIN Grades g ON e.EnrollmentID = g.EnrollmentID
    WHERE g.GradePoint IS NOT NULL
    GROUP BY s.StudentID, s.RollNumber, s.FirstName, 
             s.LastName, s.DepartmentID, d.DeptName
),
RankedStudents AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY DepartmentID 
            ORDER BY CGPA DESC
        ) AS DeptRank
    FROM StudentGPA
)
SELECT 
    DeptName,
    StudentName,
    RollNumber,
    CGPA,
    DeptRank
FROM RankedStudents
WHERE DeptRank <= 3
ORDER BY DeptName, DeptRank;
GO

USE HiSUP_DB;
GO

-- Window Function 1: RANK -- Students by GPA in each department
SELECT 
    s.RollNumber,
    s.FirstName + ' ' + s.LastName AS StudentName,
    d.DeptName,
    ROUND(SUM(g.GradePoint * c.CreditHours) / 
        NULLIF(SUM(c.CreditHours), 0), 2) AS CGPA,
    RANK() OVER (
        PARTITION BY d.DepartmentID 
        ORDER BY SUM(g.GradePoint * c.CreditHours) / 
            NULLIF(SUM(c.CreditHours), 0) DESC
    ) AS DeptRank,
    DENSE_RANK() OVER (
        PARTITION BY d.DepartmentID 
        ORDER BY SUM(g.GradePoint * c.CreditHours) / 
            NULLIF(SUM(c.CreditHours), 0) DESC
    ) AS DenseDeptRank,
    ROW_NUMBER() OVER (
        PARTITION BY d.DepartmentID 
        ORDER BY SUM(g.GradePoint * c.CreditHours) / 
            NULLIF(SUM(c.CreditHours), 0) DESC
    ) AS RowNum
FROM Students s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Sections sec ON e.SectionID = sec.SectionID
JOIN Courses c ON sec.CourseID = c.CourseID
JOIN Grades g ON e.EnrollmentID = g.EnrollmentID
WHERE g.GradePoint IS NOT NULL
GROUP BY s.StudentID, s.RollNumber, s.FirstName, 
         s.LastName, d.DepartmentID, d.DeptName;
GO

-- Window Function 2: NTILE -- Divide students into 4 performance quartiles
SELECT 
    s.RollNumber,
    s.FirstName + ' ' + s.LastName AS StudentName,
    d.DeptName,
    ROUND(SUM(g.GradePoint * c.CreditHours) / 
        NULLIF(SUM(c.CreditHours), 0), 2) AS CGPA,
    NTILE(4) OVER (
        ORDER BY SUM(g.GradePoint * c.CreditHours) / 
            NULLIF(SUM(c.CreditHours), 0) DESC
    ) AS Quartile
FROM Students s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Sections sec ON e.SectionID = sec.SectionID
JOIN Courses c ON sec.CourseID = c.CourseID
JOIN Grades g ON e.EnrollmentID = g.EnrollmentID
WHERE g.GradePoint IS NOT NULL
GROUP BY s.StudentID, s.RollNumber, s.FirstName, 
         s.LastName, d.DepartmentID, d.DeptName;
GO

-- Window Function 3: LAG and LEAD -- Fee payment trend
SELECT 
    s.RollNumber,
    s.FirstName + ' ' + s.LastName AS StudentName,
    fp.PaymentDate,
    fp.AmountPaid,
    LAG(fp.AmountPaid, 1, 0) OVER (
        PARTITION BY fp.StudentID 
        ORDER BY fp.PaymentDate
    ) AS PreviousPayment,
    LEAD(fp.AmountPaid, 1, 0) OVER (
        PARTITION BY fp.StudentID 
        ORDER BY fp.PaymentDate
    ) AS NextPayment,
    SUM(fp.AmountPaid) OVER (
        PARTITION BY fp.StudentID 
        ORDER BY fp.PaymentDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal
FROM FeePayments fp
JOIN Students s ON fp.StudentID = s.StudentID
ORDER BY fp.StudentID, fp.PaymentDate;
GO

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

USE HiSUP_DB;
GO

-- MERGE: Bulk Grade Import
-- Jab grade already hai to UPDATE, nahi hai to INSERT, 
-- import mein nahi hai to DELETE

-- Step 1: Temporary staging table banao (bulk import ka data yahan aata hai)
CREATE OR ALTER PROCEDURE BulkImportGrades
    @SectionID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Staging table (real app mein CSV se fill hoti hai)
        CREATE TABLE #GradeStaging (
            StudentID INT,
            SectionID INT,
            MarksObtained DECIMAL(6,2),
            GradePoint DECIMAL(3,2)
        );

        -- Test data staging mein insert karo
        INSERT INTO #GradeStaging (StudentID, SectionID, MarksObtained, GradePoint)
        SELECT 
            e.StudentID,
            @SectionID,
            75.00,  -- Sample marks
            3.00    -- Sample grade point
        FROM Enrollments e
        WHERE e.SectionID = @SectionID 
          AND e.Status = 'Active';

        -- MERGE statement
        MERGE INTO Grades AS Target
        USING (
            SELECT 
                gs.StudentID,
                e.EnrollmentID,
                gs.MarksObtained,
                gs.GradePoint,
                dbo.fn_GetLetterGrade(gs.MarksObtained) AS LetterGrade
            FROM #GradeStaging gs
            JOIN Enrollments e ON gs.StudentID = e.StudentID 
                AND e.SectionID = gs.SectionID
        ) AS Source
        ON Target.EnrollmentID = Source.EnrollmentID

        -- Agar grade already hai to UPDATE karo
        WHEN MATCHED THEN
            UPDATE SET 
                Target.MarksObtained = Source.MarksObtained,
                Target.GradePoint = Source.GradePoint,
                Target.LetterGrade = Source.LetterGrade

        -- Agar grade nahi hai to INSERT karo
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (EnrollmentID, MarksObtained, GradePoint, LetterGrade)
            VALUES (
                Source.EnrollmentID,
                Source.MarksObtained,
                Source.GradePoint,
                Source.LetterGrade
            )

        -- Agar student staging mein nahi hai to grade DELETE karo
        WHEN NOT MATCHED BY SOURCE 
            AND Target.EnrollmentID IN (
                SELECT e.EnrollmentID 
                FROM Enrollments e 
                WHERE e.SectionID = @SectionID
            )
        THEN DELETE;

        DROP TABLE #GradeStaging;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DROP TABLE IF EXISTS #GradeStaging;
        THROW;
    END CATCH
END;
GO

-- Test karo
EXEC BulkImportGrades @SectionID = 1;

-- Result dekho
SELECT g.*, e.StudentID 
FROM Grades g
JOIN Enrollments e ON g.EnrollmentID = e.EnrollmentID
WHERE e.SectionID = 1;
GO


USE HiSUP_DB;
GO

-- SAVEPOINT: Partial Rollback in Bulk Result Upload
CREATE OR ALTER PROCEDURE BulkUploadResultsWithSavepoint
    @SectionID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ErrorCount INT = 0;
    DECLARE @SuccessCount INT = 0;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Student 1 ka result (valid)
        SAVE TRANSACTION SavePoint1;
        BEGIN TRY
            INSERT INTO Results (ExamID, StudentID, MarksObtained, IsAbsent, PublishedDate)
            SELECT TOP 1 
                es.ExamID, 
                e.StudentID, 
                75.00, 
                0, 
                GETDATE()
            FROM ExamSchedule es
            JOIN Enrollments e ON es.SectionID = e.SectionID
            WHERE es.SectionID = @SectionID 
              AND e.Status = 'Active';
            
            SET @SuccessCount = @SuccessCount + 1;
        END TRY
        BEGIN CATCH
            -- Sirf yeh ek row rollback karo, poora transaction nahi
            ROLLBACK TRANSACTION SavePoint1;
            SET @ErrorCount = @ErrorCount + 1;
        END CATCH

        -- Student 2 ka result (valid)
        SAVE TRANSACTION SavePoint2;
        BEGIN TRY
            INSERT INTO Results (ExamID, StudentID, MarksObtained, IsAbsent, PublishedDate)
            SELECT TOP 1
                es.ExamID,
                e.StudentID,
                85.00,
                0,
                GETDATE()
            FROM ExamSchedule es
            JOIN Enrollments e ON es.SectionID = e.SectionID
            WHERE es.SectionID = @SectionID
              AND e.Status = 'Active'
            ORDER BY e.StudentID DESC;

            SET @SuccessCount = @SuccessCount + 1;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION SavePoint2;
            SET @ErrorCount = @ErrorCount + 1;
        END CATCH

        COMMIT TRANSACTION;

        SELECT 
            @SuccessCount AS SuccessfulInserts,
            @ErrorCount AS FailedInserts;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Test SAVEPOINT
EXEC BulkUploadResultsWithSavepoint @SectionID = 1;
GO

-- =============================================
-- ISOLATION LEVELS TEST
-- =============================================

-- Test 1: READ COMMITTED (Default)
-- Dirty reads nahi hoti -- sirf committed data dikhta hai
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    SELECT StudentID, FirstName, LastName 
    FROM Students 
    WHERE IsActive = 1;
COMMIT TRANSACTION;
GO

-- Test 2: SERIALIZABLE (Strictest)
-- Phantom reads bhi nahi hoti -- poora range lock ho jata hai
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
    SELECT StudentID, FirstName, LastName 
    FROM Students 
    WHERE IsActive = 1;
    
    -- Doosra transaction is range mein INSERT nahi kar sakta
    -- jab tak yeh transaction complete na ho
COMMIT TRANSACTION;
GO

-- Wapas default par
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

