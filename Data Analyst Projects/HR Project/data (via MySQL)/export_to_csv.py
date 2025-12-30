import pandas as pd
import mysql.connector
import shutil
import os

def export_hr_to_csv():
    # Enter your Connection Information
    cnx = mysql.connector.connect(
        host='localhost',
        user='root',
        password='1111',  
        database='hr_analytics'
    )
    
    # List ALL tables (add or remove if you add more later)
    tables = [
        'DIM_Date',
        'DIM_Department',
        'DIM_JobRole',
        'DIM_Location',
        'DIM_Education',
        'DIM_RecruitmentSource',
        'DIM_Training',
        'DIM_Performance',
        'DIM_Employee',
        'FACT_EmployeeSnapshot',
        'FACT_TrainingAttendance',   
        'FACT_Recruitment'           
    ]
    
    # Folder name
    folder_name = 'hr_analytics_csv'
    
    # Remove old folder if exists
    if os.path.exists(folder_name):
        shutil.rmtree(folder_name)
        print(f"Old folder '{folder_name}' removed.")
    
    # Create new folder
    os.makedirs(folder_name)
    print(f"Folder '{folder_name}' created.")
    
    # Export each table to CSV
    for table in tables:
        print(f"Exporting {table} to CSV...")
        query = f"SELECT * FROM `{table}`"  # backticks in case of special names
        df = pd.read_sql(query, cnx)
        csv_path = f"{folder_name}/{table}.csv"
        df.to_csv(csv_path, index=False)
        print(f"   → {csv_path} ({len(df)} rows)")
    
    cnx.close()
    print("\nAll done! HR Analytics data exported to 'hr_analytics_csv' folder.")

# Run it
export_hr_to_csv()