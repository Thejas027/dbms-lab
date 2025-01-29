CREATE TABLE EMPLOYEE (
    SSN INT PRIMARY KEY,
    Name VARCHAR(50),
    Address VARCHAR(100),
    Sex CHAR(1),
    Salary DECIMAL(10,2),
    SuperSSN INT,
    DNo INT,
    FOREIGN KEY (SuperSSN) REFERENCES EMPLOYEE(SSN) ON DELETE SET NULL,
);

CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY,
    DName VARCHAR(50),
    MgrSSN INT,
    MgrStartDate DATE,
);

CREATE TABLE DLOCATION (
    DNo INT,
    DLoc VARCHAR(50),
    PRIMARY KEY (DNo, DLoc),
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY,
    PName VARCHAR(50),
    PLocation VARCHAR(50),
    DNo INT,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

CREATE TABLE WORKS_ON (
    SSN INT,
    PNo INT,
    Hours int,
    PRIMARY KEY (SSN, PNo),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN) ON DELETE CASCADE,
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo) ON DELETE CASCADE
);


INSERT INTO EMPLOYEE VALUES
(1001, 'John Scott', 'New York', 'M', 700000, NULL, 1),
(1002, 'Emily Davis', 'Los Angeles', 'F', 500000, 1001, 1),
(1003, 'Michael Scott', 'Chicago', 'M', 650000, 1001, 2),
(1004, 'Sarah Johnson', 'San Francisco', 'F', 450000, 1003, 3),
(1005, 'Robert Brown', 'Houston', 'M', 750000, 1003, 2);

INSERT INTO DEPARTMENT VALUES
(1, 'Accounts', 1001, '2020-01-15'),
(2, 'IT', 1003, '2019-03-25'),
(3, 'HR', 1004, '2021-06-30');

INSERT INTO DLOCATION VALUES
(1, 'New York'),
(2, 'Chicago'),
(3, 'San Francisco');

INSERT INTO PROJECT VALUES
(10, 'IoT', 'Los Angeles', 2),
(20, 'AI', 'New York', 1),
(30, 'Cloud Computing', 'San Francisco', 3);

INSERT INTO WORKS_ON VALUES
(1001, 10, 20),
(1002, 10, 15),
(1003, 20, 25),
(1004, 30, 18),
(1005, 30, 22);


--1. List all project numbers for projects involving an employee whose last name is ‘Scott’.
SELECT DISTINCT P.PNo
FROM PROJECT P
JOIN WORKS_ON W ON P.PNo = W.PNo
JOIN EMPLOYEE E ON W.SSN = E.SSN
WHERE E.Name LIKE '%Scott'

UNION

SELECT DISTINCT P.PNo
FROM PROJECT P
JOIN DEPARTMENT D ON P.DNo = D.DNo
JOIN EMPLOYEE E ON D.MgrSSN = E.SSN
WHERE E.Name LIKE '%Scott';

--2. Show resulting salaries if employees working on ‘IoT’ get a 10% raise.
SELECT E.SSN, E.Name, E.Salary AS OldSalary, 
       E.Salary * 1.10 AS NewSalary
FROM EMPLOYEE E
JOIN WORKS_ON W ON E.SSN = W.SSN
JOIN PROJECT P ON W.PNo = P.PNo
WHERE P.PName = 'IoT';

--3. Find sum, max, min, and avg salary of 'Accounts' department.
SELECT SUM(E.Salary) AS Total_Salary,
       MAX(E.Salary) AS Max_Salary,
       MIN(E.Salary) AS Min_Salary,
       AVG(E.Salary) AS Avg_Salary
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
WHERE D.DName = 'Accounts';

--4. Employees working on all projects controlled by department 5 (Using NOT EXISTS).
SELECT E.Name
FROM EMPLOYEE E
WHERE NOT EXISTS (
    SELECT P.PNo FROM PROJECT P
    WHERE P.DNo = 5
    EXCEPT
    SELECT W.PNo FROM WORKS_ON W WHERE W.SSN = E.SSN
);

--5. Departments with more than 5 employees & count of employees earning > 600,000.
SELECT E.DNo, COUNT(E.SSN) AS Employee_Count
FROM EMPLOYEE E
GROUP BY E.DNo
HAVING COUNT(E.SSN) > 5;

--6. Create a view showing Employee Name, Dept Name, and Location.
CREATE VIEW EmployeeDeptInfo AS
SELECT E.Name, D.DName, DL.DLoc
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
JOIN DLOCATION DL ON D.DNo = DL.DNo;


--7. Create a trigger to prevent deletion of projects if any employee is working on them.

DELIMITER //
CREATE TRIGGER Prevent_Project_Deletion
BEFORE DELETE ON PROJECT
FOR EACH ROW
BEGIN
    DECLARE Employee_Count INT;
    SELECT COUNT(*) INTO Employee_Count
    FROM WORKS_ON
    WHERE PNo = OLD.PNo;
    
    IF Employee_Count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Deletion not allowed: Project is being worked on by employees';
    END IF;
END;
//
DELIMITER ;

