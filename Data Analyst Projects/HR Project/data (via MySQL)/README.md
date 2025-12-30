# HR Analytics Database Setup Guide (using SQL)

This README provides step-by-step instructions to set up the HR Analytics database using the provided files. You can choose the MySQL version for a full relational database experience or export to CSV for simpler portability (optional).

## Prerequisites

- **MySQL**: Installed and running (e.g., MySQL Community Server 8.0+). You'll need a user with privileges to create databases (default: user='root', password='1111' — change in the scripts if needed).
- **Python 3.8+**: Installed with required libraries: `pip install pandas mysql-connector-python`
- **MySQL Workbench** (optional): For running SQL scripts visually.

## Overview of Files

- `hr_analytics_schema.sql`: Full SQL script to create the database schema (tables, relationships, and sample lookup data).
- `generate_hr_data.py`: Python script to generate 1,000 realistic employees and ~75,000 monthly snapshots.
- `export_to_csv.py`: Python script to export the database to CSV files (for easy sharing or Power BI use without MySQL).

## Option 1: Create and Use the MySQL Database (Recommended for Full Experience)

This sets up a complete relational database with star schema, ready for Power BI or queries.

1. **Run the Schema Script**:
   - Open MySQL Workbench (or command line: `mysql -u root -p`).
   - Create the database if not done: `CREATE DATABASE hr_analytics;`
   - Copy-paste the entire `hr_analytics_schema.sql` into a query tab and run it.
   - This creates 13 tables, inserts sample lookup data (departments, job roles, etc.), and populates the date dimension (2020–2030).

2. **Generate Data**:
   - Open `generate_hr_data.py` in a text editor.
   - Update the connection details (host, user, password) if needed.
   - Run the script: `python generate_hr_data.py`
   - This inserts:
     - 1,000 employees with realistic Egyptian names, ages, hire/termination dates (2015–2025).
     - ~75,000 monthly snapshots (salary, performance, etc.) from 2020 to 2025.
   - Output: "1,000 employees + 72,000 snapshots inserted!"

3. **Use the Database**:
   - Connect in Power BI: Get Data → MySQL → localhost / hr_analytics.
   - Or query in Workbench: e.g., `SELECT COUNT(*) FROM DIM_Employee;` → 1000.
   - All tables are related (star schema) for easy analysis.

## Option 2: Export to CSV (Optional – For Portability)

If you want to share the data without MySQL (e.g., for Excel or Power BI without database setup):

1. Run the database setup above first (to have data to export).

2. Open `export_to_csv.py` in a text editor.
   - Update connection details (host, user, password) if needed.
   - Run: `python export_to_csv.py`
   - This creates a folder `hr_analytics_csv` with 12 CSV files (one per table).
   - Output: "All done! HR Analytics data exported to 'hr_analytics_csv' folder."

3. Use the CSVs:
   - In Power BI: Get Data → Folder → select `hr_analytics_csv` → load all files.
   - In Excel: Open each CSV for manual review.
   - Note: CSVs are static — re-run the script to refresh from MySQL.

## What Each File Does

- `hr_analytics_schema.sql`: Creates the database structure (tables, keys, triggers) and inserts initial lookup data (e.g., departments, job roles). No employees yet — that's for the Python generator.
- `generate_hr_data.py`: Populates the DIM_Employee table with 1,000 fake but realistic employees (names, DOB, hire/termination dates). Then generates monthly snapshots in FACT_EmployeeSnapshot (salaries, bonuses, etc.). Uses random logic to simulate real HR data.
- `export_to_csv.py`: Connects to the populated MySQL database and exports each table to a separate CSV file in a new folder. Cleans up old folders for fresh exports.

If you run into issues (e.g., connection errors), double-check your MySQL user/password and that the database exists.

Feedback or questions? Please Open an issue on GitHub.