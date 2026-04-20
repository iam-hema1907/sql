-- Creating the master PRODUCT table with CHECK constraint for Product Type
CREATE TABLE PRODUCT4 (
    Maker VARCHAR(50) NOT NULL,
    Modelno INT NOT NULL PRIMARY KEY,
    Type VARCHAR(20) NOT NULL CHECK (Type IN ('PC', 'Laptop', 'Printer'))
);

-- Creating the PC table 
CREATE TABLE PC4 (
    Modelno INT NOT NULL PRIMARY KEY,
    Speed INT NOT NULL,       -- Speed in MHz
    RAM INT NOT NULL,         -- RAM in MB
    HD INT NOT NULL,          -- HD size in GB
    CD VARCHAR(10) NOT NULL,  -- Speed of CD reader
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Modelno) REFERENCES PRODUCT4(Modelno)
);

-- Creating the LAPTOP table
CREATE TABLE LAPTOP4 (
    Modelno INT NOT NULL PRIMARY KEY,
    Speed INT NOT NULL,
    RAM INT NOT NULL,
    HD INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Modelno) REFERENCES PRODUCT4(Modelno)
);

-- Creating the PRINTER table with CHECK constraints for Color and Printer Type

-- Inserting 30 products into the PRODUCT table (10 PCs, 10 Laptops, 10 Printers)
INSERT INTO PRODUCT4 (Maker, Modelno, Type) VALUES
('IBM', 1001, 'PC'), ('Compaq', 1002, 'PC'), ('Dell', 1003, 'PC'),
('HP', 1004, 'PC'), ('Lenovo', 1005, 'PC'), ('Dell', 1006, 'PC'),
('Compaq', 1007, 'PC'), ('IBM', 1008, 'PC'), ('HP', 1009, 'PC'),
('Lenovo', 1010, 'PC'),

('Apple', 2001, 'Laptop'), ('Sony', 2002, 'Laptop'), ('Dell', 2003, 'Laptop'),
('HP', 2004, 'Laptop'), ('Lenovo', 2005, 'Laptop'), ('Apple', 2006, 'Laptop'),
('Asus', 2007, 'Laptop'), ('Sony', 2008, 'Laptop'), ('Acer', 2009, 'Laptop'),
('Dell', 2010, 'Laptop'),

('Epson', 3001, 'Printer'), ('Canon', 3002, 'Printer'), ('HP', 3003, 'Printer'),
('Brother', 3004, 'Printer'), ('Epson', 3005, 'Printer'), ('Epson', 3006, 'Printer'),
('Canon', 3007, 'Printer'), ('Brother', 3008, 'Printer'), ('Xerox', 3009, 'Printer'),
('HP', 3010, 'Printer');

-- Inserting 10 records into the PC table
INSERT INTO PC4 (Modelno, Speed, RAM, HD, CD, Price) VALUES
(1001, 266, 64, 40, '12x', 500.00),
(1002, 300, 128, 80, '16x', 600.00),
(1003, 400, 256, 120, '24x', 800.00),
(1004, 300, 128, 80, '16x', 550.00), 
(1005, 500, 512, 250, '48x', 1000.00),
(1006, 266, 128, 40, '12x', 550.00), 
(1007, 600, 512, 500, '52x', 1200.00),
(1008, 450, 256, 120, '24x', 850.00), 
(1009, 800, 1024, 1000, '52x', 1500.00),
(1010, 1000, 2048, 2000, '52x', 2000.00);

-- Inserting 10 records into the LAPTOP table
INSERT INTO LAPTOP4 (Modelno, Speed, RAM, HD, Price) VALUES
(2001, 300, 256, 40, 1200.00),
(2002, 400, 512, 80, 1500.00),
(2003, 350, 256, 60, 1300.00),
(2004, 500, 1024, 120, 1800.00),
(2005, 600, 2048, 250, 2200.00),
(2006, 450, 512, 80, 1600.00),
(2007, 200, 256, 40, 1100.00), -- Slowest laptop (200 MHz)
(2008, 250, 128, 30, 950.00),
(2009, 350, 512, 60, 1250.00),
(2010, 800, 2048, 500, 2500.00);

-- Inserting 10 records into the PRINTER table
INSERT INTO PRINTER4 (Modelno, Color, Type, Price) VALUES
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
-- a) Find the manufacturers of color printers.
SELECT DISTINCT p.Maker 
FROM PRODUCT4 p
JOIN PRINTER4 pr ON p.Modelno = pr.Modelno
WHERE pr.Color = 'T';

-- b) Find the laptops whose speed is slower than that of any PC.
SELECT l.Modelno, l.Speed, l.Price
FROM LAPTOP4 l
WHERE l.Speed < ANY (SELECT Speed FROM PC4);

-- c) Write a trigger on PC & LAPTOP table such that the hard disk size should be greater than 20 GB
DELIMITER //

-- Trigger for the PC Table
CREATE TRIGGER Enforce_PC_HD_Size1
BEFORE INSERT ON PC4
FOR EACH ROW
BEGIN
    IF NEW.HD <= 20 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: PC Hard Disk size must be greater than 20 GB.';
    END IF;
END //

-- Trigger for the LAPTOP Table
CREATE TRIGGER Enforce_Laptop_HD_Size1
BEFORE INSERT ON LAPTOP4
FOR EACH ROW
BEGIN
    IF NEW.HD <= 20 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Laptop Hard Disk size must be greater than 20 GB.';
    END IF;
END //
DELIMITER ;

INSERT INTO PRODUCT4 (Maker, Modelno, Type) VALUES 
('Dell', 9931, 'PC'),
('HP', 9932, 'PC');

INSERT INTO PC4 (Modelno, Speed, RAM, HD, CD, Price) 
VALUES (9931, 500, 256, 40, '12x', 500.00);

INSERT INTO PC4 (Modelno, Speed, RAM, HD, CD, Price) 
VALUES (9932, 500, 256, 10, '12x', 500.00);

show triggers;