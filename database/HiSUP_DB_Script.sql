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