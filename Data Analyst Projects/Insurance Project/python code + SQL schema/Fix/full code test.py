# ====== Generate Insurance 001 db.py (Merged & Fixed Version) ======
import random
from datetime import datetime, timedelta
import string
import mysql.connector
from faker import Faker
from decimal import Decimal

# ====== SETUP ======
fake = Faker('en_US')
Faker.seed(42)
random.seed(42)

PRODUCT_CATEGORIES = ['Auto', 'Home', 'Life', 'Health']
VEHICLE_MAKES = ['Toyota', 'Honda', 'Ford', 'Chevrolet', 'Nissan', 'BMW', 'Mercedes', 'Hyundai', 'Kia', 'Volkswagen']
PROPERTY_TYPES = ['Single-Family', 'Condo', 'Townhouse', 'Apartment', 'Multi-Family']
US_STATES = ['CA', 'TX', 'FL', 'NY', 'PA', 'IL', 'OH', 'GA', 'NC', 'MI']

# Fixed today date (consistent with your original)
today = datetime(2025, 12, 20).date()

# Years and weights
years = list(range(2017, 2026))

# Improved year weights for policy dates – milder growth, prevents huge 2025 spike
year_weights = [1.1, 1.31, 1.43, 1.9, 1.8, 2.5, 2.1, 2.3, 2.5]

# Claim severity factors (higher = worse year → higher payouts/approvals)
claim_severity_factors = {
    2017: 0.95,
    2018: 0.90,
    2019: 0.95,
    2020: 1.10,   
    2021: 1.05,
    2022: 1.00,
    2023: 0.85,
    2024: 0.78,
    2025: 0.70    
}

premium_inflation_base_year = 2017

def weighted_date(start_year=2017, end_year=2025):
    year = random.choices(years, weights=year_weights)[0]
    month = random.randint(1, 12)
    day = random.randint(1, 28)  # Safe for all months
    return datetime(year, month, day).date()

# ====== HELPER FUNCTIONS ======
def realistic_email(first, last, used_set):
    first = first.lower()
    last = last.lower()
    domains = ["gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "aol.com", "protonmail.com", "icloud.com"]
    formats = [
        f"{first}.{last}",
        f"{first}{last}",
        f"{first}_{last}",
        f"{first[0]}{last}",
        f"{first}{last}{random.randint(10,99)}",
        f"{first}.{last}{random.randint(1,999)}"
    ]
    random.shuffle(formats)
    domain = random.choice(domains)

    for base in formats:
        email = f"{base}@{domain}"
        if email not in used_set:
            used_set.add(email)
            return email

    counter = 1
    while True:
        email = f"{first}.{last}{counter}@{domain}"
        if email not in used_set:
            used_set.add(email)
            return email
        counter += 1

def realistic_policy_number(used_set):
    while True:
        prefix = random.choice(['POL', 'INS', 'COV', 'PRM'])
        number = random.randint(1000000, 9999999)
        policy_num = f"{prefix}-{number}"
        if policy_num not in used_set:
            used_set.add(policy_num)
            return policy_num

# ====== MAIN FUNCTION ======
def main():
    # Database connection
    cnx = mysql.connector.connect(
        host='localhost',
        user='root',
        password='1111',
        database='insurance_project_test'
    )
    cursor = cnx.cursor()

    used_emails = set()
    used_policy_numbers = set()
    agent_by_branch = [[] for _ in range(51)]  # Index 0 unused

    # === Branches (50) ===
    print("Inserting Branches...")
    for i in range(1, 51):
        cursor.execute("""
            INSERT INTO Branches (BranchID, BranchName, Address, City, State, ZipCode, OpeningDate, EmployeeCount)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            i, f"{fake.city()} Branch", fake.street_address(), fake.city(),
            random.choice(US_STATES), fake.zipcode(),
            fake.date_between(start_date='-20y', end_date='-5y'),
            random.randint(15, 80)
        ))

    # === Agents (500) ===
    print("Inserting Agents...")
    for i in range(1, 501):
        branch_id = random.randint(1, 50)
        agent_by_branch[branch_id].append(i)
        hire_date = fake.date_between(start_date='-15y', end_date=today)
        phone = f"({fake.numerify('###')}) {fake.numerify('###')}-{fake.numerify('####')}"
        cursor.execute("""
            INSERT INTO Agents (AgentID, FirstName, LastName, PhoneNumber, Email, AgencyName, LicenseNumber, HireDate, CommissionRate, Region, PerformanceRating, ActiveStatus, BranchID)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            i, fake.first_name(), fake.last_name(), phone, fake.unique.company_email(),
            fake.company(), ''.join(random.choices(string.digits, k=8)), hire_date,
            round(random.uniform(0.05, 0.15), 4), random.choice(US_STATES),
            random.randint(1, 5), random.random() > 0.1, branch_id
        ))

    # === Products (20) ===
    print("Inserting Products...")
    for i in range(1, 21):
        category = random.choice(PRODUCT_CATEGORIES)
        cursor.execute("""
            INSERT INTO Products (ProductID, ProductName, ProductCategory, Description, BasePremium, CoverageLimit, IsActive, LaunchDate)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            i, f"{category} {random.choice(['Standard', 'Premium', 'Basic', 'Elite', 'Plus'])} Plan",
            category, fake.text(max_nb_chars=200),
            round(random.uniform(300, 3000), 2), round(random.uniform(50000, 1000000), 2),
            True, fake.date_between(start_date='-10y', end_date='-1y')
        ))

    # === Customers (50,000) ===
    print("Inserting 50,000 Customers...")
    for i in range(1, 50001):
        gender = random.choices(['Female', 'Male', 'Non-Binary'], weights=[39.93, 46.18, 13.89])[0]
        first = fake.first_name_male() if gender == 'Male' else fake.first_name_female() if gender == 'Female' else fake.first_name()
        last = fake.last_name()
        email = realistic_email(first, last, used_emails)
        phone = f"({fake.numerify('###')}) {fake.numerify('###')}-{fake.numerify('####')}"
        dob = fake.date_of_birth(minimum_age=18, maximum_age=85)
        registration = weighted_date()

        income = round(random.uniform(30000, 200000), 2)
        base_from_income = int(income / 200)
        variation = random.randint(-120, 180)
        credit_score = 300 + base_from_income + variation
        credit_score = max(300, min(850, credit_score))
        if income > 150000:
            credit_score = max(credit_score, random.randint(680, 850))
        elif income < 50000:
            credit_score = min(credit_score, random.randint(300, 740))

        cursor.execute("""
            INSERT INTO Customers 
            (CustomerID, FirstName, LastName, DateOfBirth, Gender, AddressLine1, City, State, ZipCode, Country, PhoneNumber, Email, AnnualIncome, MaritalStatus, NumberOfDependents, CreditScore, ChurnProbability, RegistrationDate)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            i, first, last, dob, gender, fake.street_address(), fake.city(),
            random.choice(US_STATES), fake.zipcode(), 'USA', phone, email,
            income, random.choice(['Single', 'Married', 'Divorced', 'Widowed']),
            random.randint(0, 5), credit_score, round(random.uniform(0.0, 0.4), 4), registration
        ))

    # === Policies (120,000) ===
    print("Inserting 120,000 Policies...")
    for i in range(1, 120001):
        customer_id = random.randint(1, 50000)
        product_id = random.randint(1, 20)
        branch_id = random.randint(1, 50)
        if random.random() < 0.8 and agent_by_branch[branch_id]:
            agent_id = random.choice(agent_by_branch[branch_id])
        else:
            agent_id = random.randint(1, 500)

        cursor.execute("SELECT ProductCategory, BasePremium FROM Products WHERE ProductID = %s", (product_id,))
        result = cursor.fetchone()
        if not result:
            continue
        category, base_premium_decimal = result
        base_premium = float(base_premium_decimal)

        start_date = weighted_date()
        end_date = start_date + timedelta(days=365) if category in ['Auto', 'Home', 'Health'] else start_date + timedelta(days=365*random.choice([10, 20, 30]))

        year = start_date.year
        inflation_factor = 1 + (year - premium_inflation_base_year) * 0.03
        premium = base_premium * random.uniform(0.7, 1.8) * inflation_factor
        coverage = premium * random.uniform(50, 300)
        deductible = round(random.choice([250, 500, 1000, 2000, 5000]), 2)

        policy_number = realistic_policy_number(used_policy_numbers)

        status = random.choices(['Active', 'Expired', 'Cancelled', 'Renewed'], weights=[0.6, 0.2, 0.1, 0.1])[0]

        cursor.execute("""
            INSERT INTO Policies 
            (PolicyID, CustomerID, AgentID, BranchID, ProductID, PolicyNumber, StartDate, EndDate, PremiumAmount, CoverageAmount, Deductible, PolicyStatus, RiskScore, CreatedDate)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            i, customer_id, agent_id, branch_id, product_id, policy_number,
            start_date, end_date, round(premium, 2), round(coverage, 2), deductible,
            status, round(random.uniform(10, 90), 2), datetime.now()
        ))

        # Product-specific details
        if category == 'Auto':
            cursor.execute("""
                INSERT INTO AutoPolicyDetails (PolicyID, VehicleMake, VehicleModel, VehicleYear, VIN, LicensePlate, Mileage, UsageType)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (i, random.choice(VEHICLE_MAKES), fake.word().capitalize(),
                  random.randint(2010, 2025), ''.join(random.choices(string.ascii_uppercase + string.digits, k=17)),
                  fake.license_plate(), random.randint(5000, 150000), random.choice(['Personal', 'Commercial'])))
        elif category == 'Home':
            cursor.execute("""
                INSERT INTO HomePolicyDetails (PolicyID, PropertyAddress, PropertyType, PropertyValue, SquareFootage, YearBuilt, ConstructionType, SecuritySystem, FloodZone)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (i, fake.street_address() + ", " + fake.city(), random.choice(PROPERTY_TYPES),
                  round(random.uniform(150000, 800000), 2), random.randint(800, 5000),
                  random.randint(1950, 2025), random.choice(['Wood', 'Brick', 'Concrete', 'Steel']),
                  random.choice([True, False]), random.choice([True, False])))
        elif category == 'Life':
            cursor.execute("""
                INSERT INTO LifePolicyDetails (PolicyID, BeneficiaryFirstName, BeneficiaryLastName, BeneficiaryRelationship, TermLength, SmokerStatus, HealthRating)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (i, fake.first_name(), fake.last_name(),
                  random.choice(['Spouse', 'Child', 'Parent', 'Sibling']),
                  random.choice([10, 20, 30]), random.choice([True, False]),
                  random.choice(['Excellent', 'Good', 'Fair', 'Poor'])))
        elif category == 'Health':
            cursor.execute("""
                INSERT INTO HealthPolicyDetails (PolicyID, CoverageType, NetworkType, CopayAmount, OutOfPocketMax, PrescriptionCoverage)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (i, random.choice(['Individual', 'Family']), random.choice(['HMO', 'PPO', 'EPO']),
                  round(random.uniform(20, 100), 2), round(random.uniform(3000, 12000), 2),
                  random.choice([True, False])))

    # === Claims (20,000) – IMPROVED VERSION ===
    print("Inserting 20,000 Claims (improved realism)...")
    cursor.execute("""
        SELECT PolicyID, StartDate
        FROM Policies
        WHERE StartDate <= %s
    """, (today,))
    valid_policies = cursor.fetchall()

    if not valid_policies:
        print("No valid policies found for claims!")
    else:
        claims_inserted = 0
        target = 20000
        while claims_inserted < target:
            policy_id, policy_start_date = random.choice(valid_policies)

            # Safe incident date
            try:
                incident_date = fake.date_between(start_date=policy_start_date, end_date=today)
            except ValueError:
                incident_date = policy_start_date

            incident_year = incident_date.year

            # Claim date: 0–60 days after incident, capped at today
            claim_date = incident_date + timedelta(days=random.randint(0, 60))
            if claim_date > today:
                claim_date = today

            severity = claim_severity_factors.get(incident_year, 0.90)
            requested = round(random.uniform(1500, 60000), 2)

            # Approval probability: base 65%, slightly higher in bad years, capped
            approval_prob = min(0.85, 0.65 * severity)

            if random.random() > approval_prob:
                approved = 0.0
                status = 'Denied'
            else:
                ratio = min(0.75, random.uniform(0.40, 0.65) * severity)
                approved = round(requested * ratio, 2)
                status = 'Settled' if random.random() < 0.75 else 'Approved'

            fraud_flag = 1 if random.random() < 0.015 else 0

            cursor.execute("""
                INSERT INTO Claims 
                (ClaimID, PolicyID, ClaimDate, IncidentDate, IncidentDescription,
                 ClaimAmountRequested, ClaimAmountApproved, ClaimStatus, FraudFlag)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                claims_inserted + 1, policy_id, claim_date, incident_date,
                fake.paragraph(nb_sentences=2), requested, approved, status, fraud_flag
            ))

            claims_inserted += 1
            if claims_inserted % 2000 == 0:
                print(f"   {claims_inserted:,} / {target:,} claims inserted...")

    # === Payments (300,000) ===
    print("Inserting 300,000 Payments...")
    for i in range(1, 300001):
        if random.random() < 0.8:  # Premium payment
            policy_id = random.randint(1, 120000)
            claim_id = None
            payment_type = 'Premium'
            amount = round(random.uniform(100, 5000), 2)
        else:  # Payout
            claim_id = random.randint(1, 20000)
            policy_id = None
            payment_type = 'Payout'
            amount = round(random.uniform(500, 50000), 2)

        payment_date = fake.date_between(start_date='-7y', end_date='today')

        cursor.execute("""
            INSERT INTO Payments (PaymentID, PolicyID, ClaimID, PaymentType, PaymentDate, Amount, PaymentMethod, Status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            i, policy_id, claim_id, payment_type, payment_date, amount,
            random.choice(['Credit Card', 'Bank Transfer', 'Check', 'Auto-Debit']),
            'Successful'
        ))

    cnx.commit()
    print("Insurance database successfully populated with realistic data!")
    cnx.close()

if __name__ == "__main__":
    main()
