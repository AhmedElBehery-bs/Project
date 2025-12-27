######CHECK&TEST######

select * from dim_employee de ;

select count(*) from dim_employee de ;


SELECT COUNT(*) AS terminated_emp
FROM dim_employee de 
WHERE TerminationDate IS NOT NULL 
  AND de.TerminationDate < '2025-12-31' and de.TerminationDate > '2020-01-01' ;



######FIX######

-- First: clear ALL termination dates (start fresh)
UPDATE dim_employee
SET TerminationDate = NULL
WHERE TerminationDate IS NOT NULL;

-- Now, reassign realistic termination dates ONLY where still NULL,
UPDATE dim_employee
SET TerminationDate = (
    -- Generate a random date between HireDate and '2025-12-31'
    DATE_ADD(
        HireDate,
        INTERVAL FLOOR(
            RAND() * DATEDIFF('2025-12-31', HireDate)
        ) DAY
    )
)
WHERE EmployeeID IN (
    SELECT EmployeeID FROM (
        SELECT EmployeeID
        FROM dim_employee
        WHERE TerminationDate IS NULL
          AND HireDate <= '2025-12-31'  
        ORDER BY RAND()
        LIMIT 80  -- adjust this number for desired turnover count
    ) AS tmp
);