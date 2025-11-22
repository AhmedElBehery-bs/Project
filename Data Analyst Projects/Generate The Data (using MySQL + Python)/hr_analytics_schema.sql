-- ====================================================================================================
-- HR ANALYTICS DATABASE – FULL SCHEMA (MySQL)
-- 13 Tables| 1,000 Employees
-- ====================================================================================================

DROP DATABASE IF EXISTS hr_analytics;
CREATE DATABASE hr_analytics;
USE hr_analytics;


-- ==================== 1. DIMENSION TABLES ====================

CREATE TABLE DIM_Department (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(50) NOT NULL UNIQUE,
    DepartmentHead VARCHAR(100),
    Budget DECIMAL(12,2)
);

CREATE TABLE DIM_JobRole (
    JobRoleID INT PRIMARY KEY AUTO_INCREMENT,
    JobTitle VARCHAR(100) NOT NULL UNIQUE,
    JobLevel INT CHECK (JobLevel BETWEEN 1 AND 5),
    JobFamily VARCHAR(50)
);

CREATE TABLE DIM_Location (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    City VARCHAR(50),
    Country VARCHAR(50) DEFAULT 'Egypt',
    OfficeType VARCHAR(20),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6)
);

CREATE TABLE DIM_Education (
    EducationID INT PRIMARY KEY AUTO_INCREMENT,
    EducationLevel VARCHAR(50),
    FieldOfStudy VARCHAR(100),
    Institution VARCHAR(150),
    GraduationYear INT
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

CREATE TABLE DIM_Performance (
    PerformanceID INT PRIMARY KEY AUTO_INCREMENT,
    ReviewYear INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    RatingLabel VARCHAR(20)
);

CREATE TABLE DIM_Date (
    DateKey INT PRIMARY KEY,
    FullDate DATE UNIQUE NOT NULL,
    Year INT,
    Quarter INT,
    QuarterName VARCHAR(10),
    Month INT,
    MonthName VARCHAR(20),
    MonthShort VARCHAR(3),
    DayOfWeek VARCHAR(10),
    IsWeekend TINYINT(1)
);

CREATE TABLE DIM_Employee (
    EmployeeID INT PRIMARY KEY,
    FullName VARCHAR(100),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Gender VARCHAR(20),
    DateOfBirth DATE,
    Age INT DEFAULT NULL,                    -- calculated by trigger
    HireDate DATE,
    TerminationDate DATE NULL,
    IsActive TINYINT(1) DEFAULT NULL,        -- calculated by trigger
    YearsAtCompany INT DEFAULT NULL,         -- calculated by trigger
    DepartmentID INT,
    JobRoleID INT,
    LocationID INT,
    EducationID INT,
    ManagerID INT
);

-- ==================== 2. FACT TABLES ====================

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
    YearsSinceLastPromotion INT
);

CREATE TABLE FACT_TrainingAttendance (
    AttendanceID BIGINT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    TrainingID INT,
    AttendanceDateKey INT,
    HoursAttended INT,
    FeedbackScore INT CHECK (FeedbackScore BETWEEN 1 AND 5)
);

CREATE TABLE FACT_Recruitment (
    RecruitmentID BIGINT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    SourceID INT,
    ApplicationDateKey INT,
    OfferDateKey INT,
    HireDateKey INT,
    TimeToHireDays INT,
    RecruitmentCost DECIMAL(10,2)
);

-- ==================== 3. FOREIGN KEYS ====================

ALTER TABLE DIM_Employee
    ADD CONSTRAINT fk_emp_dept FOREIGN KEY (DepartmentID) REFERENCES DIM_Department(DepartmentID),
    ADD CONSTRAINT fk_emp_job FOREIGN KEY (JobRoleID) REFERENCES DIM_JobRole(JobRoleID),
    ADD CONSTRAINT fk_emp_loc FOREIGN KEY (LocationID) REFERENCES DIM_Location(LocationID),
    ADD CONSTRAINT fk_emp_edu FOREIGN KEY (EducationID) REFERENCES DIM_Education(EducationID),
    ADD CONSTRAINT fk_emp_mgr FOREIGN KEY (ManagerID) REFERENCES DIM_Employee(EmployeeID);

ALTER TABLE FACT_EmployeeSnapshot
    ADD CONSTRAINT fk_snap_emp FOREIGN KEY (EmployeeID) REFERENCES DIM_Employee(EmployeeID),
    ADD CONSTRAINT fk_snap_date FOREIGN KEY (SnapshotDateKey) REFERENCES DIM_Date(DateKey),
    ADD CONSTRAINT fk_snap_perf FOREIGN KEY (PerformanceID) REFERENCES DIM_Performance(PerformanceID);

ALTER TABLE FACT_TrainingAttendance
    ADD CONSTRAINT fk_att_emp FOREIGN KEY (EmployeeID) REFERENCES DIM_Employee(EmployeeID),
    ADD CONSTRAINT fk_att_train FOREIGN KEY (TrainingID) REFERENCES DIM_Training(TrainingID),
    ADD CONSTRAINT fk_att_date FOREIGN KEY (AttendanceDateKey) REFERENCES DIM_Date(DateKey);

ALTER TABLE FACT_Recruitment
    ADD CONSTRAINT fk_rec_emp FOREIGN KEY (EmployeeID) REFERENCES DIM_Employee(EmployeeID),
    ADD CONSTRAINT fk_rec_src FOREIGN KEY (SourceID) REFERENCES DIM_RecruitmentSource(SourceID);

-- ==================== 4. POPULATE LOOKUP TABLES ====================

INSERT INTO DIM_Department (DepartmentID, DepartmentName, DepartmentHead, Budget) VALUES
(1,'Human Resources','Fatma Ahmed',500000),(2,'IT','Omar Hassan',1200000),
(3,'Sales','Nadia Kamal',800000),(4,'Finance','Khaled Mostafa',900000),(5,'Marketing','Laila Sami',600000);

INSERT INTO DIM_JobRole (JobRoleID, JobTitle, JobLevel, JobFamily) VALUES
(1,'HR Specialist',2,'HR'),(2,'Data Analyst',3,'Analytics'),(3,'Software Engineer',4,'Tech'),
(4,'Sales Manager',4,'Sales'),(5,'Accountant',3,'Finance');

INSERT INTO DIM_Location (LocationID, City, OfficeType, Latitude, Longitude) VALUES
(1,'Cairo','HQ',30.0444,31.2357),(2,'Alexandria','Branch',31.2001,29.9187),
(3,'Giza','Branch',30.0131,31.2089),(4,'Remote','Remote',0,0);

INSERT INTO DIM_Education (EducationID, EducationLevel, FieldOfStudy, Institution, GraduationYear) VALUES
(1,'Bachelor’s','Computer Science','Cairo University',2018),
(2,'Master’s','Business Administration','AUC',2020),
(3,'Bachelor’s','Accounting','Helwan University',2019);

INSERT INTO DIM_RecruitmentSource (SourceID, SourceName, CostPerHire) VALUES
(1,'LinkedIn',1200),(2,'Referral',800),(3,'Job Portal',1000),(4,'Campus',600);

INSERT INTO DIM_Training (TrainingID, TrainingName, Provider, DurationHours, Cost, Certification) VALUES
(1,'Power BI Advanced','Microsoft',40,2500,1),(2,'SQL for Analysts','Coursera',30,800,1),
(3,'Leadership Essentials','LinkedIn',16,1200,0),(4,'Python for Data Analysis','Udemy',50,600,1);

-- 20 performance records so random 1-20 never fails
INSERT INTO DIM_Performance (PerformanceID, ReviewYear, Rating, RatingLabel) VALUES
(1,2024,5,'Excellent'),(2,2024,4,'Very Good'),(3,2024,3,'Good'),(4,2024,2,'Fair'),(5,2024,1,'Poor'),
(6,2023,5,'Excellent'),(7,2023,4,'Very Good'),(8,2023,3,'Good'),(9,2023,2,'Fair'),(10,2023,1,'Poor'),
(11,2022,5,'Excellent'),(12,2022,4,'Very Good'),(13,2022,3,'Good'),(14,2022,2,'Fair'),(15,2022,1,'Poor'),
(16,2021,5,'Excellent'),(17,2021,4,'Very Good'),(18,2021,3,'Good'),(19,2021,2,'Fair'),(20,2021,1,'Poor');

-- (Fix) 80 more dummy performance records so IDs 1–100 always exist when running the python code
INSERT INTO DIM_Performance (PerformanceID, ReviewYear, Rating, RatingLabel)
VALUES
(21,2024,4,'Very Good'),(22,2024,3,'Good'),(23,2024,5,'Excellent'),(24,2024,2,'Fair'),(25,2024,1,'Poor'),
(26,2023,5,'Excellent'),(27,2023,4,'Very Good'),(28,2023,3,'Good'),(29,2023,4,'Very Good'),(30,2023,5,'Excellent'),
(31,2022,3,'Good'),(32,2022,4,'Very Good'),(33,2022,5,'Excellent'),(34,2022,2,'Fair'),(35,2022,1,'Poor'),
(36,2021,5,'Excellent'),(37,2021,4,'Very Good'),(38,2021,3,'Good'),(39,2021,4,'Very Good'),(40,2021,5,'Excellent'),
(41,2025,4,'Very Good'),(42,2025,3,'Good'),(43,2025,5,'Excellent'),(44,2025,2,'Fair'),(45,2025,1,'Poor'),
(46,2024,5,'Excellent'),(47,2024,4,'Very Good'),(48,2024,3,'Good'),(49,2024,4,'Very Good'),(50,2024,5,'Excellent'),
(51,2023,3,'Good'),(52,2023,4,'Very Good'),(53,2023,5,'Excellent'),(54,2023,2,'Fair'),(55,2023,1,'Poor'),
(56,2022,5,'Excellent'),(57,2022,4,'Very Good'),(58,2022,3,'Good'),(59,2022,4,'Very Good'),(60,2022,5,'Excellent'),
(61,2021,3,'Good'),(62,2021,4,'Very Good'),(63,2021,5,'Excellent'),(64,2021,2,'Fair'),(65,2021,1,'Poor'),
(66,2025,5,'Excellent'),(67,2025,4,'Very Good'),(68,2025,3,'Good'),(69,2025,4,'Very Good'),(70,2025,5,'Excellent'),
(71,2024,3,'Good'),(72,2024,4,'Very Good'),(73,2024,5,'Excellent'),(74,2024,2,'Fair'),(75,2024,1,'Poor'),
(76,2023,5,'Excellent'),(77,2023,4,'Very Good'),(78,2023,3,'Good'),(79,2023,4,'Very Good'),(80,2023,5,'Excellent'),
(81,2022,3,'Good'),(82,2022,4,'Very Good'),(83,2022,5,'Excellent'),(84,2022,2,'Fair'),(85,2022,1,'Poor'),
(86,2021,5,'Excellent'),(87,2021,4,'Very Good'),(88,2021,3,'Good'),(89,2021,4,'Very Good'),(90,2021,5,'Excellent'),
(91,2025,4,'Very Good'),(92,2025,3,'Good'),(93,2025,5,'Excellent'),(94,2025,2,'Fair'),(95,2025,1,'Poor'),
(96,2024,5,'Excellent'),(97,2024,4,'Very Good'),(98,2024,3,'Good'),(99,2024,4,'Very Good'),(100,2024,5,'Excellent');

-- ==================== 5. DATE DIMENSION 2020-2030 ====================

DROP PROCEDURE IF EXISTS PopulateDate;
DELIMITER $$
CREATE PROCEDURE PopulateDate()
BEGIN
    DECLARE d DATE DEFAULT '2020-01-01';
    WHILE d <= '2030-12-31' DO
        INSERT IGNORE INTO DIM_Date (
            DateKey, FullDate, Year, Quarter, QuarterName,
            Month, MonthName, MonthShort, DayOfWeek, IsWeekend
        ) VALUES (
            YEAR(d)*10000 + MONTH(d)*100 + DAY(d),
            d,
            YEAR(d),
            QUARTER(d),
            CONCAT('Q', QUARTER(d)),
            MONTH(d),
            MONTHNAME(d),
            LEFT(MONTHNAME(d), 3),
            DAYNAME(d),
            IF(DAYOFWEEK(d) IN (1,7), 1, 0)
        );
        SET d = DATE_ADD(d, INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

CALL PopulateDate();


-- ==================== DONE ====================
SELECT COUNT(*) AS Employees FROM DIM_Employee;
SELECT COUNT(*) AS Snapshots FROM FACT_EmployeeSnapshot;


-- ====================================================================================================
--										~•~ TIME TO USE PYTHON ~•~ 


-- NOW WE ARE READY TO GENERATE THE DATA FOR THE EMPLOYEES USING PYTHON
	-- TO DO THIS RUN "generate_hr_data.py" File provided on this folder
-- ====================================================================================================