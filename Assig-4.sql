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
    P_code INT NOT NULL PRIMARY KEY, 
    Entry_date DATE NOT NULL,
    Discharge_date DATE NOT NULL,
    ward_no INT NOT NULL CHECK (ward_no < 5),
    disease VARCHAR(50) NOT NULL,
    FOREIGN KEY (P_code) REFERENCES PATIENTMASTER(Pcode)
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
-- (Including dates between Aug 13, 2022 and Aug 28, 2022 to test Query B)
INSERT INTO ADMITTEDPATIENT (P_code, Entry_date, Discharge_date, ward_no, disease) VALUES
(101, '2022-08-01', '2022-08-05', 1, 'Viral Fever'),
(102, '2022-08-10', '2022-08-15', 2, 'Fracture'),     -- Discharged within range
(103, '2022-08-12', '2022-08-20', 4, 'Pneumonia'),    -- Discharged within range & Ward 4
(104, '2022-08-15', '2022-08-18', 3, 'Appendicitis'), -- Discharged within range
(105, '2022-07-25', '2022-08-02', 4, 'Covid-19'),     -- Ward 4
(106, '2022-08-20', '2022-08-25', 1, 'Malaria'),      -- Discharged within range
(107, '2022-08-26', '2022-08-30', 2, 'Typhoid'),
(108, '2022-08-05', '2022-08-08', 3, 'Food Poisoning'),
(109, '2022-08-22', '2022-08-27', 4, 'Dengue'),       -- Discharged within range & Ward 4
(110, '2022-09-01', '2022-09-05', 2, 'Asthma');

-- a) Find the details of doctors who are treating the patient of ward no 4.
SELECT DISTINCT d.*
FROM DOCTOR d
JOIN PATIENTMASTER p ON d.Did = p.Did
JOIN ADMITTEDPATIENT a ON p.Pcode = a.P_code
WHERE a.ward_no = 4;

-- b) Find the details of patient who are discharged within the period 13/08/22 to 28/08/22.
SELECT p.*
FROM PATIENTMASTER p
JOIN ADMITTEDPATIENT a ON p.Pcode = a.P_code
WHERE a.Discharge_date BETWEEN '2022-08-13' AND '2022-08-28';

-- c) Write a procedure on ADMITTEDPATIENT table such as to calculate bill of all discharged patients. The charges per day for a ward is Ward no. * 100. e.g. For ward no 3 charges/day are 300Rs.
 DELIMITER //
CREATE PROCEDURE Calculate_Discharge_Bills()
BEGIN
    SELECT 
        a.P_code,
        p.Pname,
        a.Entry_date,
        a.Discharge_date,
        a.ward_no,
        -- Calculate total days (minimum 1 day if discharged same day)
        GREATEST(DATEDIFF(a.Discharge_date, a.Entry_date), 1) AS Days_Admitted,
        
        -- Formula: Days * (Ward_no * 100)
        (GREATEST(DATEDIFF(a.Discharge_date, a.Entry_date), 1) * (a.ward_no * 100)) AS Total_Bill_Rs
        
    FROM ADMITTEDPATIENT a
    JOIN PATIENTMASTER p ON a.P_code = p.Pcode
    -- Ensuring we only calculate for patients who actually have a discharge date
    WHERE a.Discharge_date IS NOT NULL; 
END //

DELIMITER ;

-- Execute the procedure to see the results
CALL Calculate_Discharge_Bills();




