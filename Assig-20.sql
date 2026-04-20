-- Creating the DOCTOR table
CREATE TABLE DOCTOR (
    Did INT NOT NULL PRIMARY KEY,
    Dname VARCHAR(50) NOT NULL,
    Daddress VARCHAR(100) NOT NULL,
    qualification VARCHAR(50) NOT NULL
);

-- Creating the PATIENTMASTER table with CHECK constraint for Gender
CREATE TABLE PATIENTMASTER (
    Pcode INT NOT NULL PRIMARY KEY,
    Pname VARCHAR(50) NOT NULL,
    Padd VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
    bloodgroup VARCHAR(5) NOT NULL,
    Did INT NOT NULL,
    FOREIGN KEY (Did) REFERENCES DOCTOR(Did)
);

-- Creating the ADMITTEDPATIENT table with CHECK constraint for Ward No
CREATE TABLE ADMITTEDPATIENT (
    Pcode INT NOT NULL PRIMARY KEY, 
    Entry_date DATE NOT NULL,
    Discharge_date DATE NOT NULL,
    wardno INT NOT NULL CHECK (wardno < 10), -- Assuming "less than 10"
    disease VARCHAR(50) NOT NULL,
    FOREIGN KEY (Pcode) REFERENCES PATIENTMASTER(Pcode)
);

-- Inserting 10 records into DOCTOR
INSERT INTO DOCTOR (Did, Dname, Daddress, qualification) VALUES
(1, 'Dr. Smith', '10 Main St', 'MBBS, MD'),
(2, 'Dr. Jones', '22 Oak Ave', 'MBBS, MS'),
(3, 'Dr. Williams', '5 Pine Rd', 'MBBS'),
(4, 'Dr. Brown', '12 Elm St', 'MBBS, MD'),
(5, 'Dr. Davis', '77 Cedar Ln', 'MBBS, DCH'),
(6, 'Dr. Miller', '89 Birch Blvd', 'MBBS, MS'),
(7, 'Dr. Wilson', '101 Maple Dr', 'MBBS'),
(8, 'Dr. Moore', '34 Ash St', 'MBBS, MD, DM'),
(9, 'Dr. Taylor', '56 Spruce Way', 'MBBS'),
(10, 'Dr. Anderson', '90 Walnut Ct', 'MBBS, MS');

-- Inserting 10 records into PATIENTMASTER
INSERT INTO PATIENTMASTER (Pcode, Pname, Padd, age, gender, bloodgroup, Did) VALUES
(101, 'Alice Green', '1 Apple St', 30, 'F', 'O+', 1),
(102, 'Bob White', '2 Berry Rd', 45, 'M', 'A-', 2),
(103, 'Charlie Black', '3 Cherry Ln', 50, 'M', 'B+', 1),
(104, 'Diana Prince', '4 Date Blvd', 28, 'F', 'AB+', 4),
(105, 'Evan Stone', '5 Elder Way', 60, 'M', 'O-', 3),
(106, 'Fiona Glen', '6 Fig Ct', 35, 'F', 'A+', 6),
(107, 'George King', '7 Grape Dr', 70, 'M', 'B-', 7),
(108, 'Hannah Abbott', '8 Hazel St', 25, 'F', 'O+', 8),
(109, 'Ian Somer', '9 Ivy Rd', 40, 'M', 'AB-', 9),
(110, 'Jane Doe', '10 Juniper Ln', 55, 'F', 'A+', 10);

-- Inserting 10 records into ADMITTEDPATIENT 
-- Including Entry Dates in March 2022 to test Query A
-- Including 'TB' as a disease to test Query B
INSERT INTO ADMITTEDPATIENT (Pcode, Entry_date, Discharge_date, wardno, disease) VALUES
(101, '2022-03-01', '2022-03-10', 1, 'Viral Fever'), -- Outside range
(102, '2022-03-05', '2022-03-15', 2, 'TB'),          -- Matches Query A & B
(103, '2022-03-10', '2022-03-20', 4, 'Pneumonia'),   -- Matches Query A
(104, '2022-03-15', '2022-03-18', 3, 'Appendicitis'),-- Matches Query A
(105, '2022-03-24', '2022-04-02', 4, 'Covid-19'),    -- Matches Query A
(106, '2022-03-26', '2022-04-05', 1, 'TB'),          -- Outside range, Matches Query B
(107, '2022-04-01', '2022-04-10', 2, 'Typhoid'),
(108, '2022-02-28', '2022-03-04', 3, 'Food Poisoning'), 
(109, '2022-03-20', '2022-03-27', 4, 'Dengue'),      -- Matches Query A
(110, '2022-05-01', '2022-05-15', 2, 'TB');          -- Matches Query B

-- a) Find the details of patient who are admitted within the period 03/03/22 to 25/03/22.


SELECT p.*, a.Entry_date, a.disease
FROM PATIENTMASTER p
JOIN ADMITTEDPATIENT a ON p.Pcode = a.Pcode
WHERE a.Entry_date BETWEEN '2022-03-03' AND '2022-03-25';

-- b) Find the names of doctors who are treating TB patients.


SELECT DISTINCT d.Dname 
FROM DOCTOR d
JOIN PATIENTMASTER p ON d.Did = p.Did
JOIN ADMITTEDPATIENT a ON p.Pcode = a.Pcode
WHERE a.disease = 'TB';


-- c) Write a procedure on ADMITTEDPATIENT table such as to calculate the bill of all patients currently admitted in the hospital.


DELIMITER //

CREATE PROCEDURE Calculate_Patient_Bills()
BEGIN
    SELECT 
        a.Pcode,
        p.Pname,
        a.Entry_date,
        a.Discharge_date,
        a.disease,
        -- Calculate total days (minimum 1 day)
        GREATEST(DATEDIFF(a.Discharge_date, a.Entry_date), 1) AS no_of_days,
        
        -- Formula: Days * 800
        (GREATEST(DATEDIFF(a.Discharge_date, a.Entry_date), 1) * 800) AS Total_Bill_Rs
        
    FROM ADMITTEDPATIENT a
    JOIN PATIENTMASTER p ON a.Pcode = p.Pcode;
END //

DELIMITER ;

-- Execute the procedure to see the results
CALL Calculate_Patient_Bills();