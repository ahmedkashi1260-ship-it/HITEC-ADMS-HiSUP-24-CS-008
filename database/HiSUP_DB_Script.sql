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