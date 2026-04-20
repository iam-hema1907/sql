-- Creating the DOCTOR table
use college;
CREATE TABLE DOCTOR2 (
    Did INT NOT NULL PRIMARY KEY,
    Dname VARCHAR(50) NOT NULL,
    Daddress VARCHAR(100) NOT NULL,
    qualification VARCHAR(50) NOT NULL
);

-- Creating the PATIENTMASTER table with CHECK constraint for Gender
CREATE TABLE PATIENTMASTER2 (
    Pcode INT NOT NULL PRIMARY KEY,
    Pname VARCHAR(50) NOT NULL,
    Padd VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
    bloodgroup VARCHAR(5) NOT NULL,
    Did INT NOT NULL,
    FOREIGN KEY (Did) REFERENCES DOCTOR2(Did)
);

-- Creating the ADMITTEDPATIENT table with CHECK constraint for ward_no
CREATE TABLE ADMITTEDPATIENT2 (
    Pcode INT NOT NULL PRIMARY KEY, 
    Entry_date DATE NOT NULL,
    Discharge_date DATE NOT NULL,
    ward_no INT NOT NULL CHECK (ward_no < 5),
    disease VARCHAR(50) NOT NULL,
    FOREIGN KEY (Pcode) REFERENCES PATIENTMASTER2(Pcode)
);

-- Inserting 10 records into DOCTOR
INSERT INTO DOCTOR2 (Did, Dname, Daddress, qualification) VALUES
(1, 'Dr. Alice', '101 Health Ave', 'MBBS, M.S.'),
(2, 'Dr. Bob', '202 Care Blvd', 'MBBS, MD'),
(3, 'Dr. Charlie', '303 Cure St', 'MBBS, M.S.'),
(4, 'Dr. Diana', '404 Pulse Rd', 'MBBS, MD'),
(5, 'Dr. Evan', '505 Vital Way', 'MBBS, DCH'),
(6, 'Dr. Fiona', '606 Heart Ln', 'MBBS, M.S.'),
(7, 'Dr. George', '707 Life Ct', 'MBBS'),
(8, 'Dr. Hannah', '808 Hope Dr', 'MBBS, MD, DM'),
(9, 'Dr. Ian', '909 Breath St', 'MBBS'),
(10, 'Dr. Jane', '111 Wellness Blvd', 'MBBS, M.S.');

-- Inserting 10 records into PATIENTMASTER
INSERT INTO PATIENTMASTER2 (Pcode, Pname, Padd, age, gender, bloodgroup, Did) VALUES
(101, 'Tom Smith', '1 Alpha St', 35, 'M', 'A+', 1),  -- Age < 40, Blood group A+, Treated by M.S.
(102, 'Sara Jane', '2 Beta Rd', 45, 'F', 'A-', 2),
(103, 'Mike Ross', '3 Gamma Ln', 50, 'M', 'B+', 3),  -- Treated by M.S.
(104, 'Nina Dobrev', '4 Delta Blvd', 28, 'F', 'AB+', 4),
(105, 'John Doe', '5 Epsilon Way', 60, 'M', 'O-', 3),  -- Treated by M.S.
(106, 'Emma Stone', '6 Zeta Ct', 38, 'F', 'A', 6),    -- Age < 40, Blood group A, Treated by M.S.
(107, 'Luke Cage', '7 Eta Dr', 70, 'M', 'B-', 7),
(108, 'Mia Wong', '8 Theta St', 25, 'F', 'O+', 8),
(109, 'Paul Rudd', '9 Iota Rd', 40, 'M', 'AB-', 9),
(110, 'Lisa Ray', '10 Kappa Ln', 55, 'F', 'A+', 10);   -- Treated by M.S.

-- Inserting 10 records into ADMITTEDPATIENT 
INSERT INTO ADMITTEDPATIENT2 (Pcode, Entry_date, Discharge_date, ward_no, disease) VALUES
(101, '2023-01-05', '2023-01-20', 3, 'blood cancer'), -- Matches Query B criteria
(102, '2023-02-12', '2023-02-18', 2, 'Dengue'),
(103, '2023-03-01', '2023-03-05', 3, 'Covid-19'),     
(104, '2023-04-10', '2023-04-15', 1, 'Malaria'),
(105, '2023-05-20', '2023-05-25', 4, 'Covid-19'),
(106, '2023-06-15', '2023-07-20', 3, 'blood cancer'), -- Matches Query B criteria
(107, '2023-07-08', '2023-07-14', 2, 'Dengue'),
(108, '2023-08-05', '2023-08-10', 3, 'Malaria'),      
(109, '2023-09-11', '2023-09-18', 4, 'Covid-19'),
(110, '2023-10-02', '2023-10-07', 2, 'Dengue');

-- a) Find details of the patients who are treated by M.S. doctors.
SELECT p.*, d.Dname, d.qualification
FROM PATIENTMASTER2 p
JOIN DOCTOR2 d ON p.Did = d.Did
WHERE d.qualification LIKE '%M.S.%';

-- b) Find the details of patient who is suffered from blood cancer having age less than 40 years & blood group is A.
SELECT p.*, a.disease
FROM PATIENTMASTER2 p
JOIN ADMITTEDPATIENT2 a ON p.Pcode = a.Pcode
WHERE a.disease = 'blood cancer' 
  AND p.age < 40 
  AND p.bloodgroup LIKE 'A%';
  
  -- c) Write a cursor on PATIENTMASTER table to fetch the last record & display the rows in that table.
  
  DELIMITER //

CREATE PROCEDURE FetchLastPatientRecord()
BEGIN
    -- Variables to hold the fetched data
    DECLARE v_pcode INT;
    DECLARE v_pname VARCHAR(50);
    DECLARE v_age INT;
    DECLARE v_bloodgroup VARCHAR(5);
    
    -- Variable to handle loop termination
    DECLARE done INT DEFAULT FALSE;
    
    -- Declare the cursor (Ordering by Pcode to ensure sequential reading)
    DECLARE cur CURSOR FOR 
        SELECT Pcode, Pname, age, bloodgroup 
        FROM PATIENTMASTER2 
        ORDER BY Pcode ASC;
        
    -- Declare handler for when the cursor runs out of rows
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_pcode, v_pname, v_age, v_bloodgroup;
        
        -- If no more rows, exit the loop
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- The variables are overwritten on every pass. 
        -- When the loop finally exits, they will contain the very last record.
    END LOOP;

    CLOSE cur;

    -- Display the details of the final record fetched
    SELECT 
        v_pcode AS Last_Patient_Code, 
        v_pname AS Last_Patient_Name, 
        v_age AS Last_Patient_Age, 
        v_bloodgroup AS Last_Patient_BloodGroup;

END //

DELIMITER ;

-- Execute the procedure to see the result
CALL FetchLastPatientRecord();





