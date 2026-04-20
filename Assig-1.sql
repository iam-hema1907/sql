-- Create SUPPLIER table with CHECK constraints for City and Sno format
CREATE TABLE SUPPLIER (
    Sno VARCHAR(6) NOT NULL PRIMARY KEY,
    Sname VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL 
        CHECK (City IN ('London', 'Paris', 'Rome', 'New York', 'Amsterdam')),
    CHECK (Sno REGEXP '^S[0-9]{1,4}$') -- Starts with 'S' followed by 0 to 9999
);

-- Create PARTS table
CREATE TABLE PARTS (
    Pno VARCHAR(6) NOT NULL PRIMARY KEY,
    Pname VARCHAR(50) NOT NULL,
    Color VARCHAR(20) NOT NULL,
    Weight DECIMAL(10, 2) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Create PROJECT table with CHECK constraint for City
CREATE TABLE PROJECT (
    Jno VARCHAR(6) NOT NULL PRIMARY KEY,
    Jname VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL 
        CHECK (City IN ('London', 'Paris', 'Rome', 'New York', 'Amsterdam'))
);

-- Create SPJ table (Supplier-Part-Project relation)
CREATE TABLE SPJ (
    Sno VARCHAR(6) NOT NULL,
    Pno VARCHAR(6) NOT NULL,
    Jno VARCHAR(6) NOT NULL,
    Qty INT NOT NULL,
    PRIMARY KEY (Sno, Pno, Jno),
    FOREIGN KEY (Sno) REFERENCES SUPPLIER(Sno),
    FOREIGN KEY (Pno) REFERENCES PARTS(Pno),
    FOREIGN KEY (Jno) REFERENCES PROJECT(Jno)
);

-- Inserting records into SUPPLIER
INSERT INTO SUPPLIER (Sno, Sname, address, City) VALUES
('S1', 'Smith', '20 Main St', 'London'),
('S2', 'Jones', '15 Broad St', 'Paris'),
('S3', 'Blake', '33 Rue', 'Paris'),
('S4', 'Clark', '101 First Ave', 'London'),
('S5', 'Adams', '505 Central', 'New York'),
('S6', 'Brown', '22 Oak St', 'Rome'),
('S7', 'Miller', '100 Canal', 'Amsterdam'),
('S8', 'Davis', '12 Pine St', 'London'),
('S9', 'White', '45 Elm St', 'Rome'),
('S10', 'Martin', '99 High St', 'New York');

-- Inserting records into PARTS
INSERT INTO PARTS (Pno, Pname, Color, Weight, price) VALUES
('P1', 'Nut', 'Red', 12.00, 0.50),
('P2', 'Bolt', 'Green', 17.00, 0.80),
('P3', 'Screw', 'Blue', 17.00, 0.60),
('P4', 'Screw', 'Red', 14.00, 0.65),
('P5', 'Cam', 'Blue', 12.00, 1.20),
('P6', 'Cog', 'Red', 19.00, 1.50),
('P7', 'Washer', 'Silver', 5.00, 0.10),
('P8', 'Hinge', 'Black', 25.00, 3.00),
('P9', 'Pin', 'Silver', 3.00, 0.05),
('P10', 'Spring', 'Silver', 8.00, 0.90);

-- Inserting records into PROJECT
INSERT INTO PROJECT (Jno, Jname, City) VALUES
('J1', 'Sorter', 'Paris'),
('J2', 'Display', 'Rome'),
('J3', 'OCR', 'Amsterdam'),
('J4', 'Console', 'Amsterdam'),
('J5', 'RAID', 'London'),
('J6', 'EDS', 'London'),
('J7', 'Tape', 'London'),
('J8', 'Network', 'New York'),
('J9', 'Scanner', 'Paris'),
('J10', 'Monitor', 'Rome');

-- Inserting records into SPJ
INSERT INTO SPJ (Sno, Pno, Jno, Qty) VALUES
('S1', 'P1', 'J1', 200),
('S1', 'P1', 'J4', 700),
('S2', 'P3', 'J1', 400),
('S2', 'P3', 'J2', 200),
('S2', 'P3', 'J3', 200),
('S2', 'P3', 'J4', 500),
('S2', 'P3', 'J5', 600),
('S2', 'P3', 'J6', 400),
('S2', 'P3', 'J7', 800),
('S2', 'P5', 'J2', 100),
('S3', 'P3', 'J1', 200),
('S3', 'P4', 'J2', 500),
('S4', 'P6', 'J3', 300),
('S4', 'P6', 'J7', 300),
('S5', 'P2', 'J2', 200),
('S5', 'P2', 'J4', 100),
('S5', 'P5', 'J5', 500),
('S5', 'P5', 'J7', 100),
('S5', 'P6', 'J2', 200),
('S5', 'P1', 'J4', 100),
('S5', 'P3', 'J4', 200),
('S5', 'P4', 'J4', 800),
('S5', 'P5', 'J4', 400),
('S5', 'P6', 'J4', 500);

-- a) Find all the projects which are provided 3 or more parts.
SELECT Jno
FROM SPJ
GROUP BY Jno
HAVING COUNT(DISTINCT Pno) >= 3;

-- b) Write a trigger on PROJECT table for update such that the Jname value should not be repeated.
DELIMITER //
CREATE TRIGGER Enforce_Unique_Jname_On_Update
BEFORE UPDATE ON PROJECT
FOR EACH ROW
BEGIN
    -- Check if the NEW project name already exists in the table (excluding the current row)
    IF EXISTS (SELECT 1 FROM PROJECT WHERE Jname = NEW.Jname AND Jno != NEW.Jno) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: This Jname already exists. Duplicate Jnames are not allowed.';
    END IF;
END //

DELIMITER ;


UPDATE  PROJECT set Jname = 'Sorter' where Jno = 'J3';

-- c) Find full details of all projects in Paris.
SELECT * FROM PROJECT WHERE City = 'Paris';


