# ====== IMPORTS ======
import random
from datetime import datetime, timedelta
import mysql.connector

# ====== CONSTANTS ======
EGYPTIAN_DOMAINS = [
    "gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "icloud.com"
]

# ====== MAIN LOGIC ======
def main():
    # Database
    cnx = mysql.connector.connect(
        host='localhost', user='root', password='1111', database='hr_analytics'
    )
    cursor = cnx.cursor()

    # Load names
    names = load_egyptian_names()
    first_male_names = names.first_male
    first_female_names = names.first_female
    last_names = names.last

    used_emails = set()  # This is For unique emails 

    # === Insert 1000 employees ===
    for i in range(1, 1001):
        gender = random.choice(['Male', 'Female'])
        first = random.choice(first_male_names if gender == 'Male' else first_female_names)
        last = random.choice(last_names)
        full = f"{first} {last}"
        email = realistic_email(first, last, used_emails)
        
        dob = datetime(1980 + random.randint(0,20), random.randint(1,12), random.randint(1,28))
        hire = datetime(2015 + random.randint(0,10), random.randint(1,12), random.randint(1,28))
        term = hire + timedelta(days=random.randint(0, 2000)) if random.random() < 0.3 else None
        is_active = 0 if term else 1

        manager_id = random.randint(1, 50) if i > 50 else None

        sql = """
        INSERT INTO DIM_Employee 
        (EmployeeID, FullName, FirstName, LastName, Email, Gender, DateOfBirth, HireDate, TerminationDate, IsActive,
        DepartmentID, JobRoleID, LocationID, EducationID, ManagerID)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        cursor.execute(sql, (i, full, first, last, email, gender, dob.date(), hire.date(),
              term.date() if term else None, is_active,
              random.randint(1,5), random.randint(1,5), random.randint(1,4),
              random.randint(1,3), manager_id))



    # === Monthly Snapshots (2020–2025) ===
    print("Generating monthly snapshots...")
    for emp_id in range(1, 1001):
        # To Fetch employee's actual HireDate and TerminationDate
        cursor.execute("""
            SELECT HireDate, TerminationDate 
            FROM DIM_Employee 
            WHERE EmployeeID = %s
        """, (emp_id,))
        result = cursor.fetchone()
        if not result:
            continue
        hire_date, term_date = result

        # Determine snapshot window
        start_snap = max(hire_date, datetime(2020, 1, 1).date())
        end_snap = term_date if term_date else datetime(2025, 12, 31).date()
        end_snap = min(end_snap, datetime(2025, 12, 31).date())  # Cap at 2025

        if start_snap > end_snap:
            continue  # Skip if hired after 2025 or terminated before 2020

        # Generate first day of each month in range
        current = datetime(start_snap.year, start_snap.month, 1).date()
        end_limit = datetime(end_snap.year, end_snap.month, 1).date()

        while current <= end_limit:
            date_key = int(current.strftime('%Y%m%d'))

            # Generate realistic monthly metrics
            salary = round(random.uniform(5000, 25000), 2)
            cursor.execute("""
                INSERT INTO FACT_EmployeeSnapshot 
                (EmployeeID, SnapshotDateKey, DepartmentID, JobRoleID, LocationID, ManagerID,
                MonthlySalary, Bonus, OvertimeHours, SickDays, TrainingHours, PerformanceID,
                DistanceFromHome, JobSatisfaction, WorkLifeBalance, YearsInCurrentRole, YearsSinceLastPromotion)
                SELECT %s, %s, DepartmentID, JobRoleID, LocationID, ManagerID,
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                FROM DIM_Employee WHERE EmployeeID = %s
            """, (
                emp_id, date_key, salary, round(salary * random.uniform(0.05, 0.15), 2),
                random.uniform(0, 20), random.randint(0, 5), random.randint(0, 40),
                random.randint(1, 100), random.randint(1, 50), random.randint(1, 4),
                random.randint(1, 4), random.randint(0, 5), random.randint(0, 3), emp_id
            ))

            # Then we Move to next month
            if current.month == 12:
                current = current.replace(year=current.year + 1, month=1)
            else:
                current = current.replace(month=current.month + 1)

    cnx.commit()
    print("1,000 employees + snapshots inserted!")
    cnx.close()




#                               ==================================== BACKEND ====================================

# ====== Generate Realistic Emails ======
def realistic_email(first, last, used_set):
    first = first.split()[0].lower()
    last = last.split()[-1].lower()
    formats = [
        f"{first}.{last}",
        f"{first}{last}",
        f"{first}_{last}",
        f"{first[0]}{last}",
        f"{first}{last[0]}",
    ]
    domain = random.choice(EGYPTIAN_DOMAINS)
    
    for base in formats:
        email = f"{base}@{domain}"
        if email not in used_set:
            used_set.add(email)
            return email

    # Fallback with number
    counter = 1
    base = f"{first}.{last}"
    while True:
        email = f"{base}{counter}@{domain}"
        if email not in used_set:
            used_set.add(email)
            return email
        counter += 1



# ====== Names Database ======
class _EgyptianNames:
    def __init__(self):
        self.first_male = self._first_male_names()
        self.first_female = self._first_female_names()
        self.last = self._last_names()

    def _first_male_names(self):
        return [
        # Male (100+)
        "Ahmed", "Mohamed", "Mahmoud", "Ali", "Omar", "Youssef", "Karim", "Hassan", "Hussein",
        "Ibrahim", "Tarek", "Amr", "Khaled", "Mostafa", "Abdelrahman", "Yasser", "Samir",
        "Hany", "Adel", "Nabil", "Sayed", "Wael", "Walid", "Fahmy", "Ramy", "Sherif", "Essam",
        "Maged", "Ayman", "Moustafa", "Hisham", "Ziad", "Tamer", "Sami", "Gamal", "Ashraf",
        "Hatem", "Reda", "Mazen", "Bassem", "Emad", "Osama", "Rafat", "Nader", "Fouad", "Ezzat",
        "Ahmad", "Abdullah", "Saad", "Saeed", "Salam", "Shawky", "Sobhy", "Talaat", "Wagih",
        "Zakaria", "Zayed", "Zain", "Zakariya", "Raafat", "Raed", "Raouf", "Rashad", "Rasheed",
        "Salah", "Sameh", "Samy", "Sayed", "Shady", "Shafik", "Sharif", "Tawfik", "Yahya",
        "Yasin", "Yehia", "Zakaria", "Ziad", "Zuhair", "Abdelaziz", "Abdelhameed", "Abdelhamid",
        "Abdelkareem", "Abdellatif", "Abdelmonem", "Abdelnabi", "Abdelsalam", "Abdelwahab",
        "Bakr", "Diaa", "Ehab", "Fathy", "Hafez", "Hazem", "Helmy", "Hossam", "Ismail",
        "Kareem", "Maher", "Mamdouh", "Mansour", "Medhat", "Mokhtar", "Montasser", "Mounir",
        "Naguib", "Nasser", "Othman", "Qasim", "Ragab", "Rizk", "Saif", "Seif", "Shams",
        "Taher", "Wael", "Waleed", "Younes", "Zakaria"]

    def _first_female_names(self):
        return [
        # Female (100+)    
        "Fatima", "Aisha", "Mariam", "Nour", "Layla", "Yasmin", "Hana", "Nada", "Sara",
        "Menna", "Shaimaa", "Dina", "Nourhan", "Salma", "Rania", "Noha", "Manal", "Heba",
        "Mona", "Nagwa", "Samira", "Amina", "Zeinab", "Safia", "Amira", "Ghada", "Riham",
        "Eman", "Rasha", "Nesma", "Hind", "Farida", "Sawsan", "Lobna", "Mai", "Asmaa",
        "Nadia", "Inas", "Randa", "Faten", "Nihal", "Rawan", "Hanan", "Shaymaa", "Dalia",
        "Sabah", "Hala", "Aya", "Jannah", "Jana", "Lina", "Noor", "Malak", "Yara", "Nouran",
        "Rahma", "Reem", "Somaia", "Wafaa", "Warda", "Yomna", "Zainab", "Zahra", "Zubaida",
        "Amal", "Azza", "Basma", "Buthaina", "Dunya", "Ebtisam", "Eman", "Enas", "Farah",
        "Ghina", "Habiba", "Hanan", "Haneen", "Hoda", "Iman", "Iqbal", "Jamila", "Kawkab",
        "Khadija", "Lama", "Layan", "Maha", "Maram", "Maysa", "Mervat", "Mona", "Nadia",
        "Najwa", "Nashwa", "Nawal", "Nouran", "Ragaa", "Rahaf", "Randa", "Rehab", "Rola",
        "Sahar", "Sajida", "Sameera", "Sara", "Shorouk", "Suhair", "Suhaila", "Tahani",
        "Widad", "Yasmeen", "Zainab", "Zeina", "Zohra", "Zain", "Nayera", "Salwa", "Fawzia",
        "Nivin", "Sondos", "Mervat", "Amira", "Doaa", "Raneem", "Alia", "Intisar", "Nermeen"]
    
    def _last_names(self):
        return [
        # Common Muslim surnames
        "Abdelaziz", "Abdelrahman", "Abdelsalam", "Abdelhakim", "Abdelfattah", "Abdelnasser",
        "Abdelkader", "Abdelsayed", "Abdelmeguid", "Abdelghani", "Abdelwahab", "Abdelhalim",
        "Abdelmonem", "Abdellatif", "Abdelnabi", "Abdelkareem", "Abdelhamid", "Abdelhameed",
        "Hassan", "Hussein", "Mohamed", "Ahmed", "Mahmoud", "Ali", "Ibrahim", "Khalil",
        "Sayed", "Fouad", "Gomaa", "Elsayed", "Elshafei", "Elbaz", "Elnaggar", "Elmasry",
        "Eltawil", "Elgendy", "Elkholy", "Elbanna", "Elhennawy", "Elgindy", "Elbeshbishy",
        "Elgammal", "Elhamy", "Elkaramany", "Elkafrawy", "Elmaghraby", "Elmorshedy", "Elmorsi",
        "Elshenawy", "Elzayat", "Elzahaby", "Elkhateeb", "Elkady", "Elzomor", "Elghobashy",
        "Elsheikh", "Elbesh", "Eldeeb", "Elhadidi", "Elhaddad", "Elkhouly", "Elleithy",
        "Elmaaty", "Elmansy", "Elmesmary", "Elrefaey", "Elsherbiny", "Elsonbati", "Elwakil",
        "Elzohairy", "Samir", "Tawfik", "Zaki", "Nassar", "Wahba", "Hafez", "Gad", "Rashad",
        "Shaker", "Soliman", "Talaat", "Zaydan", "Mekawy", "Morsy", "Nabil", "Fahmy", "Rizk",
        "Saeed", "Shawky", "Tarek", "Wagih", "Youssef", "Zarif", "Zayed", "Badawy", "Barakat",
        "Dawood", "Fathy", "Farag", "Hanna", "Kamal", "Mansour", "Nagy", "Sobhy", "Tadros",
        "Wassef", "Yacoub", "Zekry", "Ashraf", "Gamil", "Hefny", "Helmy", "Khattab", "Labib",
        "Makram", "Moussa", "Naeem", "Nosseir", "Qassem", "Ragab", "Saad", "Sadek", "Sallam",
        "Sharaf", "Shehata", "Sleiman", "Tamim", "Zayan", "Zohny", "Zidan", "Zekry", "Zogby",

        # Coptic & Christian-origin surnames
        "Abdelmalek", "Atiya", "Boulos", "Butros", "Dawoud", "Ebeid", "Fahim", "George",
        "Girgis", "Habib", "Hanna", "Ibrahim", "Iskander", "Khalil", "Kyrollos", "Malak",
        "Mikhail", "Moftah", "Nakhla", "Nasr", "Philo", "Rizkallah", "Said", "Selim", "Wassef",
        "Wadie", "Youssef", "Zakhary", "Zakaria", "Abraam", "Antoun", "Bahgat", "Basily",
        "Bishay", "Boutros", "Dawoud", "Elias", "Faragallah", "Gabriel", "Henein", "Kyrillos",
        "Makary", "Mina", "Mokhtar", "Nabil", "Nashed", "Rafla", "Rizk", "Sargious", "Takla",
        "Wagih", "Youssef", "Agmy", "Barsoum", "Coptic", "Ezzat", "Heneidy", "Malak", "Mikhael",
        "Neseem", "Shenouda", "Theodor", "Wissa", "Zakaria", "Zakariya",

        # Regional & occupational surnames (Delta, Upper Egypt, etc.)
        "Abdelsalam", "Abu el-Ela", "Abu Zeid", "Alaa el-Din", "Badr", "Desouki", "El-Alfi",
        "El-Araby", "El-Assal", "El-Bahnasawy", "El-Demerdash", "El-Din", "El-Fakharany",
        "El-Gammal", "El-Gohary", "El-Hadidy", "El-Hennawy", "El-Kerdany", "El-Khayyat",
        "El-Kordy", "El-Mahdy", "El-Masry", "El-Messiry", "El-Mohandes", "El-Nahas", "El-Omari",
        "El-Qasabi", "El-Rashidy", "El-Sawy", "El-Sebaey", "El-Sherbiny", "El-Tabei", "El-Taher",
        "El-Wakil", "El-Zanaty", "Fouad", "Haggag", "Hammad", "Helal", "Kassem", "Mahrous",
        "Mansy", "Masoud", "Metwally", "Nour el-Din", "Qandil", "Rady", "Ramadan", "Saqr",
        "Shams el-Din", "Siddiq", "Tawfiq", "Wagdy", "Zaghloul", "Zayed", "Zeidan", "Zohny"]



def load_egyptian_names():
    return _EgyptianNames()


if __name__ == "__main__":
    main()
















