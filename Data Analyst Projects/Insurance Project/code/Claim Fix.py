import random
from datetime import datetime, timedelta
import mysql.connector
from faker import Faker

# ====== SETUP ======
fake = Faker('en_US')
Faker.seed(42)
random.seed(42)

# Your database credentials
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '1111',
    'database': 'insurance_project_001'
}

# Simulated "today" - must match what you used in the main script
today = datetime(2025, 12, 20).date()

# Milder growth - this prevents massive claim concentration in 2025
# 2025 gets only ~2.6x more policies than 2017 (instead of 3x+)
year_weights = [1.0, 1.2, 1.4, 1.6, 1.8, 2.0, 2.2, 2.4, 2.5]

claim_severity_factors = {
    2017: 0.95,
    2018: 0.90,
    2019: 0.95,
    2020: 1.10,   
    2021: 1.05,
    2022: 1.00,
    2023: 0.85,
    2024: 0.78,
    2025: 0.65    
}

# ====== CONNECT AND CLEAR CLAIMS ======
print("Connecting to database...")
cnx = mysql.connector.connect(**DB_CONFIG)
cursor = cnx.cursor()

print("Clearing existing claims...")

print("Temporarily disabling foreign key checks...")
cursor.execute("SET FOREIGN_KEY_CHECKS = 0")  

cursor.execute("TRUNCATE TABLE Claims")       

cursor.execute("SET FOREIGN_KEY_CHECKS = 1")  
print("Foreign key checks re-enabled.")

# ====== FETCH VALID POLICIES ======
print("Fetching valid policies...")
cursor.execute("""
    SELECT PolicyID, StartDate
    FROM Policies
    WHERE StartDate <= %s
""", (today,))
valid_policies = cursor.fetchall()

if not valid_policies:
    print("ERROR: No policies found! Run the full script first.")
    cnx.close()
    exit()

print(f"Found {len(valid_policies):,} valid policies. Starting claim insertion...")

# ====== INSERT 20,000 CLAIMS ======
claims_inserted = 0
target_claims = 20000

while claims_inserted < target_claims:
    policy_id, policy_start_date = random.choice(valid_policies)
    
    # Incident date: after policy start, before or on today
    try:
        incident_date = fake.date_between(start_date=policy_start_date, end_date=today)
    except ValueError:
        incident_date = policy_start_date
    
    incident_year = incident_date.year
    claim_date = incident_date + timedelta(days=random.randint(0, 60))
    if claim_date > today:
        claim_date = today
    
    # Severity for the incident year
    severity = claim_severity_factors.get(incident_year, 0.90)
    
    # Requested amount - realistic range
    requested = round(random.uniform(1500, 60000), 2)
    
    # Approval: ~65% base, slightly higher in bad years
    base_approval_prob = 0.65
    approval_prob = base_approval_prob * severity
    approval_prob = min(0.85, approval_prob)  # Never over 85%
    
    if random.random() > approval_prob:
        approved = 0.0
        status = 'Denied'
    else:
        # Payout ratio: 40–65% base, adjusted by severity but capped
        base_ratio = random.uniform(0.40, 0.65)
        final_ratio = base_ratio * severity
        final_ratio = min(0.75, final_ratio)  # Never pay more than 75% of requested
        
        approved = requested * final_ratio
        approved = round(approved, 2)
        
        status = 'Approved'
        if random.random() < 0.75:
            status = 'Settled'
    
    fraud_flag = 1 if random.random() < 0.015 else 0  # Boolean as int for MySQL
    
    # Insert claim
    cursor.execute("""
        INSERT INTO Claims 
        (ClaimID, PolicyID, ClaimDate, IncidentDate, IncidentDescription,
         ClaimAmountRequested, ClaimAmountApproved, ClaimStatus, FraudFlag)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        claims_inserted + 1,
        policy_id,
        claim_date,
        incident_date,
        fake.paragraph(nb_sentences=2),
        requested,
        approved,
        status,
        fraud_flag
    ))
    
    claims_inserted += 1
    if claims_inserted % 2000 == 0:
        print(f"   {claims_inserted:,} / {target_claims:,} claims inserted...")

# ====== FINALIZE ======
cnx.commit()
print(f"\nDone! {claims_inserted:,} claims inserted successfully.")
print("You can now query your loss ratio table - it should be realistic and under 100% in all years.")

cnx.close()


