-- ====================================================================================================
-- INSURANCE ANALYTICS DATABASE (001) – Database (MySQL)
-- 13 Tables | 50 Agents | 50000 Custoemrs
-- ====================================================================================================

DROP DATABASE IF EXISTS insurance_project_001;
CREATE DATABASE insurance_project_001;
USE insurance_project_001;


-- ==================== 1. CREATE THE TABLES ====================

-- 1. Customers Table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Gender VARCHAR(20),
    AddressLine1 VARCHAR(100),
    AddressLine2 VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    Country VARCHAR(50) DEFAULT 'USA',
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100),
    Occupation VARCHAR(50),
    AnnualIncome DECIMAL(15,2),
    MaritalStatus VARCHAR(20),
    NumberOfDependents INT,
    CreditScore INT,
    ChurnProbability DECIMAL(5,4),
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP,  		-- tells MySQL "If I don't specify a value for this column when inserting, use the current timestamp right now."
    LastUpdateDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP		-- like "RegistrationDate" but the key difference is: "ON UPDATE CURRENT_TIMESTAMP" Every time the row is updated (using an UPDATE statement), MySQL automatically changes this column to the new current timestamp — even if you don't mention LastUpdateDate in your UPDATE query.
);

-- 2. Agents Table
CREATE TABLE Agents (
    AgentID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100),
    AgencyName VARCHAR(100),
    LicenseNumber VARCHAR(50),
    HireDate DATE,
    CommissionRate DECIMAL(5,4) DEFAULT 0.1000,
    Region VARCHAR(50),
    PerformanceRating INT CHECK (PerformanceRating BETWEEN 1 AND 5),  	-- This is a constraint (a rule) that MySQL enforces automatically every time you insert or update data in this column. - The rule says: The value in PerformanceRating must be between 1 and 5, inclusive. - Allowed values: 1, 2, 3, 4, or 5
    ActiveStatus BOOLEAN DEFAULT true
    );

-- 3. Branches Table
CREATE TABLE Branches (
    BranchID INT AUTO_INCREMENT PRIMARY KEY,
    BranchName VARCHAR(100) NOT NULL,
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    ManagerID INT,
    OpeningDate DATE,
    EmployeeCount INT,
    FOREIGN KEY (ManagerID) REFERENCES Agents(AgentID) ON DELETE SET null	-- *IMPORTANT* ON DELETE SET NULL: Instead of blocking the deletion or cascading it (deleting the whole branch), it automatically sets the ManagerID to NULL in all affected branches. - so... Branches aren't deleted just because a manager is removed.
);


ALTER TABLE Agents 
ADD BranchID INT NULL,
ADD FOREIGN KEY (BranchID) REFERENCES Branches(BranchID) ON DELETE SET NULL;

-- 4. Products Table
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    ProductCategory VARCHAR(50) NOT NULL, -- e.g., Auto, Home, Life, Health
    Description TEXT,
    BasePremium DECIMAL(15,2),
    CoverageLimit DECIMAL(15,2),
    DeductibleOptions VARCHAR(100),
    IsActive BOOLEAN DEFAULT TRUE,
    LaunchDate DATE
);

-- 5. Policies Table (Core table)
CREATE TABLE Policies (
    PolicyID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    AgentID INT,
    BranchID INT,
    ProductID INT NOT NULL,
    PolicyNumber VARCHAR(50) UNIQUE NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    PremiumAmount DECIMAL(15,2) NOT NULL,
    CoverageAmount DECIMAL(15,2),
    Deductible DECIMAL(15,2),
    PolicyStatus VARCHAR(20) DEFAULT 'Active', -- Active, Expired, Cancelled, Renewed  - if null then 'Active'
    RenewalDate DATE,
    RiskScore DECIMAL(5,2),
    UnderwritingNotes TEXT,
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastModifiedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE,		-- if deleted the whole row will be deleted 	- But Why this logic? _the customer is the main thing on these row... policies without customer is useless... an "orphan" policies pointing to non-existent customers. - Risk: Accidental deletion of a single parent record (e.g., a customer) can trigger a chain reaction, deleting many child records (policies, and potentially claims/payments if further cascaded). This could lead to unintended data loss, especially in large datasets.
    FOREIGN KEY (AgentID) REFERENCES Agents(AgentID) ON DELETE SET NULL,
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID) ON DELETE SET NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE RESTRICT			-- Insurance products (e.g., "Auto Liability", "Homeowners") are core offerings. Existing policies are based on these products and reference their terms (coverage limits, base premiums, etc.). - Deleting a product would orphan policies or make historical data meaningless — you couldn't accurately report on past business, premiums by product, or compliance.
);

-- 6. AutoPolicyDetails Table
CREATE TABLE AutoPolicyDetails (
    AutoDetailID INT AUTO_INCREMENT PRIMARY KEY,
    PolicyID INT NOT NULL,
    VehicleMake VARCHAR(50),
    VehicleModel VARCHAR(50),
    VehicleYear INT,
    VIN VARCHAR(17),
    LicensePlate VARCHAR(20),
    DriverLicenseNumber VARCHAR(50),
    Mileage INT,
    UsageType VARCHAR(20),
    GarageAddress VARCHAR(200),
    SafetyFeatures VARCHAR(200),
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID) ON DELETE CASCADE
);

-- 7. HomePolicyDetails Table
CREATE TABLE HomePolicyDetails (
    HomeDetailID INT AUTO_INCREMENT PRIMARY KEY,
    PolicyID INT NOT NULL,
    PropertyAddress VARCHAR(200),
    PropertyType VARCHAR(50),
    PropertyValue DECIMAL(15,2),
    SquareFootage INT,
    YearBuilt INT,
    ConstructionType VARCHAR(50),
    RoofType VARCHAR(50),
    SecuritySystem BOOLEAN,
    FloodZone BOOLEAN,
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID) ON DELETE CASCADE
);

-- 8. LifePolicyDetails Table
CREATE TABLE LifePolicyDetails (
    LifeDetailID INT AUTO_INCREMENT PRIMARY KEY,
    PolicyID INT NOT NULL,
    BeneficiaryFirstName VARCHAR(50),
    BeneficiaryLastName VARCHAR(50),
    BeneficiaryRelationship VARCHAR(50),
    TermLength INT,
    SmokerStatus BOOLEAN,
    HealthRating VARCHAR(20),
    MedicalExamDate DATE,
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID) ON DELETE CASCADE
);

-- 9. HealthPolicyDetails Table
CREATE TABLE HealthPolicyDetails (
    HealthDetailID INT AUTO_INCREMENT PRIMARY KEY,
    PolicyID INT NOT NULL,
    CoverageType VARCHAR(50),
    PreExistingConditions TEXT,
    NetworkType VARCHAR(50),
    CopayAmount DECIMAL(15,2),
    OutOfPocketMax DECIMAL(15,2),
    PrescriptionCoverage BOOLEAN,
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID) ON DELETE CASCADE
);

-- 10. Claims Table
CREATE TABLE Claims (
    ClaimID INT AUTO_INCREMENT PRIMARY KEY,
    PolicyID INT NOT NULL,
    ClaimDate DATE NOT NULL,
    IncidentDate DATE,
    IncidentDescription TEXT,
    ClaimAmountRequested DECIMAL(15,2),
    ClaimAmountApproved DECIMAL(15,2),
    DeductibleApplied DECIMAL(15,2),
    ClaimStatus VARCHAR(20) DEFAULT 'Pending', -- Pending, Approved, Denied, Settled
    AdjusterID INT,
    RejectionReason TEXT,
    PayoutDate DATE,
    FraudFlag BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID) ON DELETE CASCADE,
    FOREIGN KEY (AdjusterID) REFERENCES Agents(AgentID) ON DELETE SET NULL
);

-- 11. Payments Table
CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    PolicyID INT,
    ClaimID INT,
    PaymentType VARCHAR(20) NOT NULL, -- Premium, Payout, Refund
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(15,2) NOT NULL,
    PaymentMethod VARCHAR(50),
    TransactionID VARCHAR(50),
    Status VARCHAR(20) DEFAULT 'Successful',
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID) ON DELETE SET NULL,
    FOREIGN KEY (ClaimID) REFERENCES Claims(ClaimID) ON DELETE SET NULL
);

-- 12. Audits Table (for change tracking)
CREATE TABLE Audits (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    TableName VARCHAR(50) NOT NULL,
    RecordID INT NOT NULL,
    ActionType VARCHAR(20) NOT NULL, -- Insert, Update, Delete
    ActionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    UserID INT,
    OldValue TEXT,
    NewValue TEXT
);

-- 13. RiskAssessments Table (smart analytics)
CREATE TABLE RiskAssessments (
    AssessmentID INT AUTO_INCREMENT PRIMARY KEY,
    PolicyID INT,
    CustomerID INT,
    AssessmentDate DATE NOT NULL,
    RiskCategory VARCHAR(50),
    ProbabilityOfClaim DECIMAL(5,4),
    PredictedClaimAmount DECIMAL(15,2),
    Factors TEXT,
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID) ON DELETE CASCADE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

