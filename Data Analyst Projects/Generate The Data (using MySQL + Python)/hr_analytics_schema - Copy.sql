-- ====================================================================================================
-- HR ANALYTICS DATABASE – FULL SCHEMA (MySQL)
-- 13 Tables
-- ====================================================================================================

DROP DATABASE IF EXISTS hr_analytics;
CREATE DATABASE hr_analytics;
USE hr_analytics;

-- ====================================================================================================
-- 1. DIMENSION TABLES
-- ====================================================================================================

CREATE TABLE DIM_Employee (
    EmployeeID INT PRIMARY KEY,
    FullName VARCHAR(100),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Gender VARCHAR(20),
    DateOfBirth DATE,
    MaritalStatus VARCHAR(20),
    Nationality VARCHAR(50),
    HireDate DATE,
    TerminationDate DATE NULL,
    IsActive TINYINT(1) DEFAULT 1,
    EmployeePhotoURL VARCHAR(255),
    DepartmentID INT,
    JobRoleID INT,
    LocationID INT,
    EducationID INT,
    ManagerID INT,
    INDEX idx_hire (HireDate),
    INDEX idx_dept (DepartmentID),
    INDEX idx_active (IsActive)
);

CREATE TABLE DIM_Department (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(50) NOT NULL,
    DepartmentHead VARCHAR(100),
    Budget DECIMAL(12,2),
    UNIQUE KEY uq_dept_name (DepartmentName)
);

CREATE TABLE DIM_JobRole (
    JobRoleID INT PRIMARY KEY AUTO_INCREMENT,
    JobTitle VARCHAR(100) NOT NULL,
    JobLevel INT CHECK (JobLevel BETWEEN 1 AND 5),
    JobFamily VARCHAR(50),
    UNIQUE KEY uq_job_title (JobTitle)
);

CREATE TABLE DIM_Location (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    City VARCHAR(50),
    Country VARCHAR(50),
    Region VARCHAR(50),
    OfficeType VARCHAR(20),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    INDEX idx_city (City)
);

CREATE TABLE DIM_Education (
    EducationID INT PRIMARY KEY AUTO_INCREMENT,
    EducationLevel VARCHAR(50),
    FieldOfStudy VARCHAR(100),
    Institution VARCHAR(150),
    GraduationYear INT
);

CREATE TABLE DIM_Performance (
    PerformanceID INT PRIMARY KEY AUTO_INCREMENT,
    ReviewYear INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    RatingLabel VARCHAR(20),
    Comments TEXT
);

CREATE TABLE DIM_TerminationReason (
    TermReasonID INT PRIMARY KEY AUTO_INCREMENT,
    TerminationType VARCHAR(50),
    Reason VARCHAR(100),
    IsAvoidable TINYINT(1)
);

CREATE TABLE DIM_RecruitmentSource (
    SourceID INT PRIMARY KEY AUTO_INCREMENT,
    SourceName VARCHAR(50),
    CostPerHire DECIMAL(10,2)
);

CREATE TABLE DIM_Training (
    TrainingID INT PRIMARY KEY AUTO_INCREMENT,
    TrainingName VARCHAR(100),
    Provider VARCHAR(100),
    DurationHours INT,
    Cost DECIMAL(10,2),
    Certification TINYINT(1)
);

-- ====================================================================================================
-- 10. DIM_Date (2020–2030) – Will be populated later
-- ====================================================================================================
CREATE TABLE DIM_Date (
    DateKey INT PRIMARY KEY,
    FullDate DATE UNIQUE,
    Year INT,
    Quarter INT,
    QuarterName VARCHAR(10),
    Month INT,
    MonthName VARCHAR(20),
    MonthShort VARCHAR(3),
    Week INT,
    Day INT,
    DayOfWeek VARCHAR(10),
    IsWeekend TINYINT(1),
    IsHoliday TINYINT(1),
    FiscalYear INT,
    FiscalQuarter INT,
    INDEX idx_year (Year),
    INDEX idx_month (Month),
    INDEX idx_quarter (Quarter)
);

-- ====================================================================================================
-- 11. FACT TABLES
-- ====================================================================================================

CREATE TABLE FACT_EmployeeSnapshot (
    SnapshotID BIGINT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT NOT NULL,
    SnapshotDateKey INT NOT NULL,
    DepartmentID INT,
    JobRoleID INT,
    LocationID INT,
    ManagerID INT,
    MonthlySalary DECIMAL(10,2),
    Bonus DECIMAL(10,2),
    OvertimeHours DECIMAL(5,2),
    SickDays INT,
    TrainingHours INT,
    PerformanceID INT,
    DistanceFromHome INT,
    JobSatisfaction INT CHECK (JobSatisfaction BETWEEN 1 AND 4),
    WorkLifeBalance INT CHECK (WorkLifeBalance BETWEEN 1 AND 4),
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    INDEX idx_emp_date (EmployeeID, SnapshotDateKey),
    INDEX idx_date (SnapshotDateKey)
);

CREATE TABLE FACT_TrainingAttendance (
    AttendanceID BIGINT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    TrainingID INT,
    AttendanceDateKey INT,
    HoursAttended INT,
    FeedbackScore INT CHECK (FeedbackScore BETWEEN 1 AND 5),
    INDEX idx_emp_train (EmployeeID, TrainingID)
);

CREATE TABLE FACT_Recruitment (
    RecruitmentID BIGINT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    SourceID INT,
    ApplicationDateKey INT,
    OfferDateKey INT,
    HireDateKey INT,
    TimeToHireDays INT,
    RecruitmentCost DECIMAL(10,2),
    INDEX idx_hire (HireDateKey)
);


-- ====================================================================================================
-- FOREIGN KEYS (we only add this after all tables exist)
-- ====================================================================================================

ALTER TABLE DIM_Employee
    ADD CONSTRAINT fk_emp_dept FOREIGN KEY (DepartmentID) REFERENCES DIM_Department(DepartmentID),
    ADD CONSTRAINT fk_emp_job FOREIGN KEY (JobRoleID) REFERENCES DIM_JobRole(JobRoleID),
    ADD CONSTRAINT fk_emp_loc FOREIGN KEY (LocationID) REFERENCES DIM_Location(LocationID),
    ADD CONSTRAINT fk_emp_edu FOREIGN KEY (EducationID) REFERENCES DIM_Education(EducationID),
    ADD CONSTRAINT fk_emp_mgr FOREIGN KEY (ManagerID) REFERENCES DIM_Employee(EmployeeID);

ALTER TABLE FACT_EmployeeSnapshot
    ADD CONSTRAINT fk_snap_emp FOREIGN KEY (EmployeeID) REFERENCES DIM_Employee(EmployeeID),
    ADD CONSTRAINT fk_snap_date FOREIGN KEY (SnapshotDateKey) REFERENCES DIM_Date(DateKey),
    ADD CONSTRAINT fk_snap_dept FOREIGN KEY (DepartmentID) REFERENCES DIM_Department(DepartmentID),
    ADD CONSTRAINT fk_snap_job FOREIGN KEY (JobRoleID) REFERENCES DIM_JobRole(JobRoleID),
    ADD CONSTRAINT fk_snap_loc FOREIGN KEY (LocationID) REFERENCES DIM_Location(LocationID),
    ADD CONSTRAINT fk_snap_mgr FOREIGN KEY (ManagerID) REFERENCES DIM_Employee(EmployeeID),
    ADD CONSTRAINT fk_snap_perf FOREIGN KEY (PerformanceID) REFERENCES DIM_Performance(PerformanceID);

ALTER TABLE FACT_TrainingAttendance
    ADD CONSTRAINT fk_att_emp FOREIGN KEY (EmployeeID) REFERENCES DIM_Employee(EmployeeID),
    ADD CONSTRAINT fk_att_train FOREIGN KEY (TrainingID) REFERENCES DIM_Training(TrainingID),
    ADD CONSTRAINT fk_att_date FOREIGN KEY (AttendanceDateKey) REFERENCES DIM_Date(DateKey);

ALTER TABLE FACT_Recruitment
    ADD CONSTRAINT fk_rec_emp FOREIGN KEY (EmployeeID) REFERENCES DIM_Employee(EmployeeID),
    ADD CONSTRAINT fk_rec_src FOREIGN KEY (SourceID) REFERENCES DIM_RecruitmentSource(SourceID),
    ADD CONSTRAINT fk_rec_app_date FOREIGN KEY (ApplicationDateKey) REFERENCES DIM_Date(DateKey),
    ADD CONSTRAINT fk_rec_offer_date FOREIGN KEY (OfferDateKey) REFERENCES DIM_Date(DateKey),
    ADD CONSTRAINT fk_rec_hire_date FOREIGN KEY (HireDateKey) REFERENCES DIM_Date(DateKey);

-- ====================================================================================================
-- SAMPLE DATA 		(Note: Run after this script)
-- ====================================================================================================

-- Departments
INSERT INTO DIM_Department (DepartmentName, DepartmentHead, Budget) VALUES
('Human Resources', 'Fatma Ahmed', 500000),
('IT', 'Omar Hassan', 1200000),
('Sales', 'Nadia Kamal', 800000),
('Finance', 'Khaled Mostafa', 900000),
('Marketing', 'Laila Sami', 600000);

-- Job Roles
INSERT INTO DIM_JobRole (JobTitle, JobLevel, JobFamily) VALUES
('HR Specialist', 2, 'HR'),
('Data Analyst', 3, 'Analytics'),
('Software Engineer', 4, 'Tech'),
('Sales Manager', 4, 'Sales'),
('Accountant', 3, 'Finance');

-- Locations
INSERT INTO DIM_Location (City, Country, Region, OfficeType, Latitude, Longitude) VALUES
('Cairo', 'Egypt', 'MENA', 'HQ', 30.0444, 31.2357),
('Alexandria', 'Egypt', 'MENA', 'Branch', 31.2001, 29.9187),
('Giza', 'Egypt', 'MENA', 'Branch', 30.0131, 31.2089),
('Remote', 'Egypt', 'MENA', 'Remote', 0, 0);

-- Education
INSERT INTO DIM_Education (EducationLevel, FieldOfStudy, Institution, GraduationYear) VALUES
('Bachelor’s', 'Computer Science', 'Cairo University', 2018),
('Master’s', 'Business Administration', 'AUC', 2020),
('Bachelor’s', 'Accounting', 'Helwan University', 2019);

-- Recruitment Sources
INSERT INTO DIM_RecruitmentSource (SourceName, CostPerHire) VALUES
('LinkedIn', 1200), ('Referral', 800), ('Job Portal', 1000), ('Campus', 600);




-- Performance reviews (20+ rows so random 1-20 always works)
INSERT INTO DIM_Performance (PerformanceID, ReviewYear, Rating, RatingLabel)
VALUES
(1, 2024, 5, 'Excellent'),(2, 2024, 4, 'Very Good'),(3, 2024, 3, 'Good'),(4, 2024, 2, 'Fair'),(5, 2024, 1, 'Poor'),
(6, 2023, 5, 'Excellent'),(7, 2023, 4, 'Very Good'),(8, 2023, 3, 'Good'),(9, 2023, 2, 'Fair'),(10, 2023, 1, 'Poor'),
(11, 2022, 5, 'Excellent'),(12, 2022, 4, 'Very Good'),(13, 2022, 3, 'Good'),(14, 2022, 2, 'Fair'),(15, 2022, 1, 'Poor'),
(16, 2021, 5, 'Excellent'),(17, 2021, 4, 'Very Good'),(18, 2021, 3, 'Good'),(19, 2021, 2, 'Fair'),(20, 2021, 1, 'Poor');

-- 2. A few training programs
INSERT INTO DIM_Training (TrainingID, TrainingName, Provider, DurationHours, Cost, Certification)
VALUES
(1,'Power BI Advanced','Microsoft',40,2500,1),
(2,'SQL for Analysts','Coursera',30,800,1),
(3,'Leadership Essentials','LinkedIn',16,1200,0),
(4,'Python for Data Analysis','Udemy',50,600,1);

-- 3. Termination reasons
INSERT INTO DIM_TerminationReason (TermReasonID, TerminationType, Reason, IsAvoidable)
VALUES
(1,'Voluntary','Better opportunity',1),
(2,'Voluntary','Relocation',0),
(3,'Involuntary','Performance',0),
(4,'Involuntary','Layoff',0),
(5,'Voluntary','Retirement',0);

-- 4. Recruitment sources (already inserted earlier, but just in case)
INSERT IGNORE INTO DIM_RecruitmentSource (SourceID, SourceName, CostPerHire)
VALUES (1,'LinkedIn',1200),(2,'Referral',800),(3,'Job Portal',1000),(4,'Campus',600);


-- ====================================================================================================
-- Populate DIM_Date (2020–2030)		(Note: run it on a new script file if it didn't work)
-- ====================================================================================================

DELIMITER $$
CREATE PROCEDURE PopulateDateDimension()
BEGIN
    DECLARE v_date DATE DEFAULT '2020-01-01';
    DECLARE v_end DATE DEFAULT '2030-12-31';

    WHILE v_date <= v_end DO
        INSERT INTO DIM_Date (
            DateKey, FullDate, Year, Quarter, QuarterName,
            Month, MonthName, MonthShort, Week, Day,
            DayOfWeek, IsWeekend, IsHoliday, FiscalYear, FiscalQuarter
        ) VALUES (
            YEAR(v_date)*10000 + MONTH(v_date)*100 + DAY(v_date),
            v_date,
            YEAR(v_date),
            QUARTER(v_date),
            CONCAT('Q', QUARTER(v_date)),
            MONTH(v_date),
            MONTHNAME(v_date),
            LEFT(MONTHNAME(v_date), 3),
            WEEK(v_date, 1),
            DAY(v_date),
            DAYNAME(v_date),
            IF(DAYOFWEEK(v_date) IN (1,7), 1, 0),
            0,
            IF(MONTH(v_date) >= 7, YEAR(v_date) + 1, YEAR(v_date)),
            IF(MONTH(v_date) >= 7, QUARTER(v_date)-2, QUARTER(v_date)+2)
        );
        SET v_date = DATE_ADD(v_date, INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

CALL PopulateDateDimension();


-- ====================================================================================================
--										~•~ TIME TO USE PYTHON ~•~ 


-- NOW WE ARE READY TO GENERATE THE DATA FOR THE EMPLOYEES USING PYTHON
	-- TO DO THIS RUN "generate_hr_data.py" File provided on this folder
-- ====================================================================================================