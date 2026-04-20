-- Creating the master PRODUCT table with CHECK constraint for Product Type
CREATE TABLE PRODUCT (
    Maker VARCHAR(50) NOT NULL,
    Modelno INT NOT NULL PRIMARY KEY,
    Type VARCHAR(20) NOT NULL CHECK (Type IN ('PC', 'Laptop', 'Printer'))
);

-- Creating the PC table 
CREATE TABLE PC (
    Modelno INT NOT NULL PRIMARY KEY,
    Speed INT NOT NULL,       -- Speed in MHz
    RAM INT NOT NULL,         -- RAM in MB
    HD INT NOT NULL,          -- HD size in GB
    CD VARCHAR(10) NOT NULL,  -- Speed of CD reader
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Modelno) REFERENCES PRODUCT(Modelno)
);

-- Creating the LAPTOP table
CREATE TABLE LAPTOP (
    Modelno INT NOT NULL PRIMARY KEY,
    Speed INT NOT NULL,
    RAM INT NOT NULL,
    HD INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Modelno) REFERENCES PRODUCT(Modelno)
);

-- Creating the PRINTER table with CHECK constraints for Color and Type
CREATE TABLE PRINTER (
    Modelno INT NOT NULL PRIMARY KEY,
    Color CHAR(1) NOT NULL CHECK (Color IN ('T', 'F')),
    Type VARCHAR(20) NOT NULL CHECK (Type IN ('laser', 'ink-jet', 'dot-matrix', 'dry')),
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Modelno) REFERENCES PRODUCT(Modelno)
);

-- Inserting 30 products into the master PRODUCT table 
-- (10 PCs, 10 Laptops, 10 Printers)
INSERT INTO PRODUCT (Maker, Modelno, Type) VALUES
('IBM', 1001, 'PC'), ('Compaq', 1002, 'PC'), ('Dell', 1003, 'PC'),
('HP', 1004, 'PC'), ('Lenovo', 1005, 'PC'), ('Dell', 1006, 'PC'),
('Compaq', 1007, 'PC'), ('IBM', 1008, 'PC'), ('HP', 1009, 'PC'),
('Lenovo', 1010, 'PC'),

('Apple', 2001, 'Laptop'), ('Sony', 2002, 'Laptop'), ('Dell', 2003, 'Laptop'),
('HP', 2004, 'Laptop'), ('Lenovo', 2005, 'Laptop'), ('Apple', 2006, 'Laptop'),
('Asus', 2007, 'Laptop'), ('Sony', 2008, 'Laptop'), ('Acer', 2009, 'Laptop'),
('Dell', 2010, 'Laptop'),

-- Including 'Epson' producing multiple types of printers to test Query A
('Epson', 3001, 'Printer'), ('Canon', 3002, 'Printer'), ('HP', 3003, 'Printer'),
('Brother', 3004, 'Printer'), ('Epson', 3005, 'Printer'), ('Epson', 3006, 'Printer'),
('Canon', 3007, 'Printer'), ('Brother', 3008, 'Printer'), ('Xerox', 3009, 'Printer'),
('HP', 3010, 'Printer');

-- Inserting 10 records into the PC table
-- Intentionally repeating some HD sizes (e.g., 80, 120, 250) to test Query B
INSERT INTO PC (Modelno, Speed, RAM, HD, CD, Price) VALUES
(1001, 266, 64, 40, '12x', 500.00),
(1002, 300, 128, 80, '16x', 600.00),
(1003, 400, 256, 120, '24x', 800.00),
(1004, 300, 128, 80, '16x', 550.00),   -- HD 80 repeats
(1005, 500, 512, 250, '48x', 1000.00),
(1006, 266, 128, 250, '12x', 550.00),  -- HD 250 repeats
(1007, 600, 512, 500, '52x', 1200.00),
(1008, 450, 256, 120, '24x', 850.00),  -- HD 120 repeats
(1009, 800, 1024, 1000, '52x', 1500.00),
(1010, 1000, 2048, 2000, '52x', 2000.00);

-- Inserting 10 records into the LAPTOP table
-- All speeds are 250 or higher to abide by the trigger we will create
INSERT INTO LAPTOP (Modelno, Speed, RAM, HD, Price) VALUES
(2001, 300, 256, 40, 1200.00),
(2002, 400, 512, 80, 1500.00),
(2003, 350, 256, 60, 1300.00),
(2004, 500, 1024, 120, 1800.00),
(2005, 600, 2048, 250, 2200.00),
(2006, 450, 512, 80, 1600.00),
(2007, 250, 256, 40, 1100.00), 
(2008, 280, 128, 30, 950.00),
(2009, 350, 512, 60, 1250.00),
(2010, 800, 2048, 500, 2500.00);

-- Inserting 10 records into the PRINTER table
INSERT INTO PRINTER (Modelno, Color, Type, Price) VALUES
(3001, 'T', 'ink-jet', 120.00),
(3002, 'F', 'laser', 200.00),
(3003, 'T', 'laser', 450.00),
(3004, 'F', 'dot-matrix', 80.00),
(3005, 'T', 'dry', 300.00),
(3006, 'F', 'laser', 220.00), 
(3007, 'T', 'ink-jet', 150.00),
(3008, 'F', 'dot-matrix', 90.00),
(3009, 'T', 'laser', 500.00),
(3010, 'F', 'laser', 180.00);

-- a) Find the different types of printers produced by Epson.

SELECT DISTINCT pr.Type 
FROM PRINTER pr
JOIN PRODUCT p ON pr.Modelno = p.Modelno
WHERE p.Maker = 'Epson';

-- b) Find those hard disk sizes which occur in two or more PC's.


SELECT HD, COUNT(*) as PC_Count
FROM PC
GROUP BY HD
HAVING COUNT(*) >= 2;


-- c) Write a trigger on LAPTOP table such that the minimum speed should be 250MHz.

DELIMITER //

CREATE TRIGGER Enforce_Minimum_Laptop_Speed
BEFORE INSERT ON LAPTOP
FOR EACH ROW
BEGIN
    IF NEW.Speed < 250 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Laptop speed cannot be less than 250MHz.';
    END IF;
END //

DELIMITER ;

INSERT INTO PRODUCT (Maker, Modelno, Type) VALUES 
('Dell', 9991, 'Laptop'),
('HP', 9992, 'Laptop');

INSERT INTO LAPTOP (Modelno, Speed, RAM, HD, Price) 
VALUES (9991, 300, 512, 60, 1000.00);

INSERT INTO LAPTOP (Modelno, Speed, RAM, HD, Price) 
VALUES (9992, 200, 256, 40, 800.00); -- Trigerring