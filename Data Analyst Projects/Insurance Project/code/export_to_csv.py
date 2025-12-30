import pandas as pd
import mysql.connector
import shutil

def export_to_csv():
    cnx = mysql.connector.connect(
        host='localhost',
        user='root',
        password='1111',
        database='insurance_project_001'
    )
    
    tables = [
        'Branches', 'Agents', 'Products', 'Customers', 'Policies',
        'AutoPolicyDetails', 'HomePolicyDetails', 'LifePolicyDetails', 'HealthPolicyDetails',
        'Claims', 'Payments'
    ]
    
    # Create a folder
    import os
    

    if os.path.exists('insurance_dataset_csv'):
        shutil.rmtree('insurance_dataset_csv')
        print(f"Existing folder 'insurance_dataset_csv' removed.")
        

    os.makedirs('insurance_dataset_csv')
    print(f"Folder 'insurance_dataset_csv' created.")
    
    for table in tables:
        print(f"Exporting {table} to CSV...")
        query = f"SELECT * FROM {table}"
        df = pd.read_sql(query, cnx)
        df.to_csv(f"insurance_dataset_csv/{table}.csv", index=False)
    
    cnx.close()
    print("All tables exported to 'insurance_dataset_csv' folder!")

# Call this after your main() or run separately
export_to_csv()