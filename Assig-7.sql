-- Creating the DOCTOR table
CREATE TABLE DOCTOR3 (
    Did INT NOT NULL PRIMARY KEY,
    Dname VARCHAR(50) NOT NULL,
    Daddress VARCHAR(100) NOT NULL,
    qualification VARCHAR(50) NOT NULL
);

-- Creating the PATIENTMASTER table with CHECK constraint for Gender
CREATE TABLE PATIENTMASTER3 (
    Pcode INT NOT NULL PRIMARY KEY,
    Pname VARCHAR(50) NOT NULL,
    Padd VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
    bloodgroup VARCHAR(5) NOT NULL,
    Did INT NOT NULL,
    FOREIGN KEY (Did) REFERENCES DOCTOR3(Did)
);

-- Creating the ADMITTEDPATIENT table with CHECK constraint for Ward_no
CREATE TABLE ADMITTEDPATIENT3 (
    Pcode INT NOT NULL PRIMARY KEY, 
    Entry_date DATE NOT NULL,
    Discharge_date DATE NOT NULL,
    Ward_no INT NOT NULL CHECK (Ward_no < 5),
    disease VARCHAR(50) NOT NULL,
    FOREIGN KEY (Pcode) REFERENCES PATIENTMASTER3(Pcode)
);

-- Inserting 10 records into DOCTOR
-- Including M.S., B.A.M.S., and M.B.B.S. qualifications to satisfy the queries
INSERT INTO DOCTOR3 (Did, Dname, Daddress, qualification) VALUES
(1, 'Dr. Sharma', '101 Health Ave', 'M.S.'),
(2, 'Dr. Gupta', '202 Care Blvd', 'B.A.M.S.'),
(3, 'Dr. Verma', '303 Cure St', 'M.B.B.S.'),
(4, 'Dr. Diana', '404 Pulse Rd', 'M.D.'),
(5, 'Dr. Evan', '505 Vital Way', 'M.S.'),
(6, 'Dr. Fiona', '606 Heart Ln', 'B.A.M.S.'),
(7, 'Dr. George', '707 Life Ct', 'M.B.B.S.'),
(8, 'Dr. Hannah', '808 Hope Dr', 'M.D.'),
(9, 'Dr. Ian', '909 Breath St', 'M.S.'),
(10, 'Dr. Jane', '111 Wellness Blvd', 'M.S.');

-- Inserting 10 records into PATIENTMASTER
-- Intentionally assigning multiple patients to Dr. Sharma (Did=1) for Query B
INSERT INTO PATIENTMASTER3 (Pcode, Pname, Padd, age, gender, bloodgroup, Did) VALUES
(101, 'Tom Smith', '1 Alpha St', 35, 'M', 'A+', 1),   -- Treated by M.S. (Dr. Sharma)
(102, 'Sara Jane', '2 Beta Rd', 45, 'F', 'A-', 1),   -- Treated by M.S. (Dr. Sharma)
(103, 'Mike Ross', '3 Gamma Ln', 50, 'M', 'B+', 1),   -- Treated by M.S. (Dr. Sharma)
(104, 'Nina Dobrev', '4 Delta Blvd', 28, 'F', 'AB+', 2), -- Treated by B.A.M.S. (Target for Query C)
(105, 'John Doe', '5 Epsilon Way', 60, 'M', 'O-', 3), 
(106, 'Emma Stone', '6 Zeta Ct', 38, 'F', 'A+', 6),   -- Treated by B.A.M.S. (Target for Query C)
(107, 'Luke Cage', '7 Eta Dr', 70, 'M', 'B-', 7),
(108, 'Mia Wong', '8 Theta St', 25, 'F', 'O+', 8),
(109, 'Paul Rudd', '9 Iota Rd', 40, 'M', 'AB-', 9),   -- Treated by M.S.
(110, 'Lisa Ray', '10 Kappa Ln', 55, 'F', 'A+', 10);  -- Treated by M.S.

-- Inserting 10 records into ADMITTEDPATIENT 
INSERT INTO ADMITTEDPATIENT3 (Pcode, Entry_date, Discharge_date, Ward_no, disease) VALUES
(101, '2023-01-05', '2023-01-20', 3, 'Viral Fever'),
(102, '2023-02-12', '2023-02-18', 2, 'Dengue'),
(103, '2023-03-01', '2023-03-05', 1, 'Covid-19'),     
(104, '2023-04-10', '2023-04-15', 1, 'Malaria'),
(105, '2023-05-20', '2023-05-25', 4, 'Covid-19'),
(106, '2023-06-15', '2023-07-20', 3, 'Typhoid'),
(107, '2023-07-08', '2023-07-14', 2, 'Dengue'),
(108, '2023-08-05', '2023-08-10', 3, 'Malaria'),      
(109, '2023-09-11', '2023-09-18', 4, 'Covid-19'),
(110, '2023-10-02', '2023-10-07', 2, 'Dengue');

-- a) Find details of the patients who are treated by M.S. doctors.
SELECT p.*, d.Dname, d.qualification
FROM PATIENTMASTER3 p
JOIN DOCTOR3 d ON p.Did = d.Did
WHERE d.qualification = 'M.S.';

-- b) Find the name of doctor who is treating maximum number of patients.
SELECT d.Dname, COUNT(p.Pcode) AS Total_Patients
FROM DOCTOR3 d
JOIN PATIENTMASTER3 p ON d.Did = p.Did
GROUP BY d.Did, d.Dname
ORDER BY Total_Patients DESC
LIMIT 1;

-- c) Create a view on DOCTOR & PATIENTMASTER tables. Update details of the patients who are treated by B.A.M.S. doctors to M.B.B.S doctor.
CREATE VIEW Patient_Doctor_View AS
SELECT 
    p.Pcode, p.Pname, p.age, p.gender, p.bloodgroup, p.Did AS Patient_Did, 
    d.Dname, d.qualification
FROM PATIENTMASTER3 p
JOIN DOCTOR3 d ON p.Did = d.Did;

select * from Patient_Doctor_View;

UPDATE PATIENTMASTER3 
SET Did = (SELECT Did FROM DOCTOR3 WHERE qualification = 'M.B.B.S.' LIMIT 1)
WHERE Did IN (SELECT Did FROM DOCTOR3 WHERE qualification = 'B.A.M.S.');
