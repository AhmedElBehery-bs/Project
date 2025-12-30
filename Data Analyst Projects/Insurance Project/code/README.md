# Code Folder – SQL & Python Tools for Insurance Dataset Generation

This folder contains all the Python scripts and SQL schema needed to generate or regenerate the full insurance database in MySQL. This is the "SQL version" for advanced users who want to customize the data or run it in a database environment.

**Note**: For most users, the CSV files in the `data/` folder are sufficient and easier — no setup required. Use this folder only if you want to recreate the database from scratch or fix specific issues like the loss ratio.

## Overview

- `Insurance Schema.sql`: Full MySQL schema (CREATE TABLE statements) for the database.
- `Generate Insurance 001 db.py`: Main Python script to populate the database with realistic data (50k customers, 120k policies, etc.).
- `Claim Fix.py`: Standalone script to regenerate and adjust claims data (fixes loss ratio issues by tying claims to policy volume and applying year-specific severity).
- `export_to_csv.py`: Utility to export all tables from MySQL to CSV files (for Power BI import).

The generated data includes realistic correlations (income → credit → risk), company growth (more recent policies), agent-branch links, and controlled loss ratios (~60–90% with fluctuations and a 2020 spike).

## Prerequisites

- **MySQL Server**: Installed and running (e.g., MySQL 8.0+). Download from https://dev.mysql.com/downloads/.
- **Python 3.8+**: With these libraries:
  - `pip install mysql-connector-python faker pandas`
- Access to the files in this folder.

## Setup

1. **Create the Database**:
   - Open MySQL Workbench or command line.
   - Run: `CREATE DATABASE insurance_project_001;`
   - Copy-paste the contents of `Insurance Schema.sql` into MySQL and execute it. This creates all 13 tables with proper relationships.

2. **Configure Database Credentials**:
   - In all Python scripts (`Generate Insurance 001 db.py`, `Claim Fix.py`, `export_to_csv.py`), update the connection details if needed:
     ```python
     cnx = mysql.connector.connect(
         host='localhost',
         user='root',
         password='your_password',  # Change to your actual MySQL password
         database='insurance_project_001'
     )