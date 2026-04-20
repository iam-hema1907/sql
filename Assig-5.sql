-- Creating the DOCTOR table
CREATE TABLE DOCTOR1 (
    Did INT NOT NULL PRIMARY KEY,
    Dname VARCHAR(50) NOT NULL,
    Daddress VARCHAR(100) NOT NULL,
    qualification VARCHAR(50) NOT NULL
);

-- Creating the PATIENTMASTER table with CHECK constraint for Gender
CREATE TABLE PATIENTMASTER1 (
    Pcode INT NOT NULL PRIMARY KEY,
    Pname VARCHAR(50) NOT NULL,
    Padd VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
    bloodgroup VARCHAR(5) NOT NULL,
    Did INT NOT NULL,
    FOREIGN KEY (Did) REFERENCES DOCTOR1(Did)
);

-- Creating the ADMITTEDPATIENT table with CHECK constraint for ward_no
CREATE TABLE ADMITTEDPATIENT1 (
    P_code INT NOT NULL PRIMARY KEY, 
    Entry_date DATE NOT NULL,
    Discharge_date DATE NOT NULL,
    ward_no INT NOT NULL CHECK (ward_no < 5),
    disease VARCHAR(50) NOT NULL,
    FOREIGN KEY (P_code) REFERENCES PATIENTMASTER1(Pcode)
);

-- Inserting 10 records into DOCTOR
INSERT INTO DOCTOR1 (Did, Dname, Daddress, qualification) VALUES
(1, 'Dr. Alice', '101 Health Ave', 'MBBS, MD'),
(2, 'Dr. Bob', '202 Care Blvd', 'MBBS, MS'),
(3, 'Dr. Charlie', '303 Cure St', 'MBBS'),
(4, 'Dr. Diana', '404 Pulse Rd', 'MBBS, MD'),
(5, 'Dr. Evan', '505 Vital Way', 'MBBS, DCH'),
(6, 'Dr. Fiona', '606 Heart Ln', 'MBBS, MS'),
(7, 'Dr. George', '707 Life Ct', 'MBBS'),
(8, 'Dr. Hannah', '808 Hope Dr', 'MBBS, MD, DM'),
(9, 'Dr. Ian', '909 Breath St', 'MBBS'),
(10, 'Dr. Jane', '111 Wellness Blvd', 'MBBS, MS');

-- Inserting 10 records into PATIENTMASTER
INSERT INTO PATIENTMASTER1 (Pcode, Pname, Padd, age, gender, bloodgroup, Did) VALUES
(101, 'Tom Smith', '1 Alpha St', 30, 'M', 'O+', 1),
(102, 'Sara Jane', '2 Beta Rd', 45, 'F', 'A-', 2),
(103, 'Mike Ross', '3 Gamma Ln', 50, 'M', 'B+', 1),
(104, 'Nina Dobrev', '4 Delta Blvd', 28, 'F', 'AB+', 4),
(105, 'John Doe', '5 Epsilon Way', 60, 'M', 'O-', 3),
(106, 'Emma Stone', '6 Zeta Ct', 35, 'F', 'A+', 6),
(107, 'Luke Cage', '7 Eta Dr', 70, 'M', 'B-', 7),
(108, 'Mia Wong', '8 Theta St', 25, 'F', 'O+', 8),
(109, 'Paul Rudd', '9 Iota Rd', 40, 'M', 'AB-', 9),
(110, 'Lisa Ray', '10 Kappa Ln', 55, 'F', 'A+', 10);

-- Inserting 10 records into ADMITTEDPATIENT 
-- Intentionally distributing diseases to test Query B (Covid: 4, Dengue: 3, Malaria: 2, Typhoid: 1)
INSERT INTO ADMITTEDPATIENT1 (P_code, Entry_date, Discharge_date, ward_no, disease) VALUES
(101, '2023-01-05', '2023-01-10', 3, 'Covid-19'),     -- Ward 3
(102, '2023-02-12', '2023-02-18', 2, 'Dengue'),
(103, '2023-03-01', '2023-03-05', 3, 'Covid-19'),     -- Ward 3
(104, '2023-04-10', '2023-04-15', 1, 'Malaria'),
(105, '2023-05-20', '2023-05-25', 4, 'Covid-19'),
(106, '2023-06-15', '2023-06-20', 3, 'Typhoid'),      -- Ward 3, Only 1 case of Typhoid
(107, '2023-07-08', '2023-07-14', 2, 'Dengue'),
(108, '2023-08-05', '2023-08-10', 3, 'Malaria'),      -- Ward 3
(109, '2023-09-11', '2023-09-18', 4, 'Covid-19'),
(110, '2023-10-02', '2023-10-07', 2, 'Dengue');
-- a) Find the details of the doctors who are treating the patients of ward no 3 & display the result along with patient name & disease.
SELECT 
    d.Did, 
    d.Dname, 
    d.Daddress, 
    d.qualification, 
    p.Pname AS Patient_Name, 
    a.disease
FROM DOCTOR1 d
JOIN PATIENTMASTER1 p ON d.Did = p.Did
JOIN ADMITTEDPATIENT1 a ON p.Pcode = a.P_code
WHERE a.ward_no = 3;

-- b) Find the name of the disease by which minimum patients are suffering.

SELECT disease
FROM ADMITTEDPATIENT
GROUP BY disease
ORDER BY COUNT(P_code) ASC
LIMIT 1;

-- c) Write a trigger on ADMITTEDPATIENT table such that the ward no value should be between 1-5.
DELIMITER //
CREATE TRIGGER Enforce_Ward_Range1
BEFORE INSERT ON ADMITTEDPATIENT1
FOR EACH ROW
BEGIN
    IF NEW.ward_no < 1 OR NEW.ward_no > 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Ward number must be between 1 and 5.';
    END IF;
END //

DELIMITER ;

INSERT INTO ADMITTEDPATIENT1 (P_code, Entry_date, Discharge_date, ward_no, disease) VALUES
(111, '2023-01-05', '2023-01-10', 8, 'Covid-19'); 






