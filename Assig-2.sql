CREATE DATABASE mca;
use mca;
-- Creating the PRODUCT table with CHECK constraint for Type

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
    CD VARCHAR(10) NOT NULL,  -- Speed of CD reader (e.g., '12x')
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

-- Inserting 30 products into PRODUCT table (10 PCs, 10 Laptops, 10 Printers)
INSERT INTO PRODUCT (Maker, Modelno, Type) VALUES
('IBM', 1001, 'PC'), ('Compaq', 1002, 'PC'), ('Dell', 1003, 'PC'),
('HP', 1004, 'PC'), ('Lenovo', 1005, 'PC'), ('IBM', 1006, 'PC'),
('Compaq', 1007, 'PC'), ('Dell', 1008, 'PC'), ('HP', 1009, 'PC'),
('Lenovo', 1010, 'PC'),

('Apple', 2001, 'Laptop'), ('Sony', 2002, 'Laptop'), ('Apple', 2003, 'Laptop'),
('Sony', 2004, 'Laptop'), ('Razer', 2005, 'Laptop'), ('Dell', 2006, 'Laptop'),
('HP', 2007, 'Laptop'), ('Lenovo', 2008, 'Laptop'), ('Asus', 2009, 'Laptop'),
('Asus', 2010, 'Laptop'),

('Epson', 3001, 'Printer'), ('Canon', 3002, 'Printer'), ('HP', 3003, 'Printer'),
('Brother', 3004, 'Printer'), ('Epson', 3005, 'Printer'), ('Canon', 3006, 'Printer'),
('HP', 3007, 'Printer'), ('Brother', 3008, 'Printer'), ('Samsung', 3009, 'Printer'),
('Xerox', 3010, 'Printer');

-- Inserting 10 records into PC table
INSERT INTO PC (Modelno, Speed, RAM, HD, CD, Price) VALUES
(1001, 133, 64, 2, '8x', 450.00),
(1002, 160, 128, 4, '12x', 600.00),
(1003, 200, 256, 8, '16x', 800.00),
(1004, 150, 128, 5, '10x', 550.00),
(1005, 300, 512, 10, '24x', 1200.00),
(1006, 166, 256, 6, '12x', 700.00),
(1007, 400, 1024, 20, '32x', 1500.00),
(1008, 120, 64, 2, '8x', 400.00),
(1009, 233, 512, 10, '16x', 950.00),
(1010, 500, 2048, 40, '48x', 2000.00);

-- Inserting 10 records into LAPTOP table
INSERT INTO LAPTOP (Modelno, Speed, RAM, HD, Price) VALUES
(2001, 200, 512, 10, 1500.00),
(2002, 160, 256, 8, 1100.00),
(2003, 300, 1024, 20, 2200.00),
(2004, 250, 512, 15, 1400.00),
(2005, 450, 2048, 50, 3500.00), -- Most expensive laptop
(2006, 233, 512, 12, 1250.00),
(2007, 166, 256, 6, 900.00),
(2008, 350, 1024, 25, 1800.00),
(2009, 400, 2048, 40, 2400.00),
(2010, 133, 128, 4, 750.00);

-- Inserting 10 records into PRINTER table
INSERT INTO PRINTER (Modelno, Color, Type, Price) VALUES
(3001, 'T', 'ink-jet', 150.00),
(3002, 'F', 'laser', 250.00),
(3003, 'T', 'laser', 400.00),
(3004, 'F', 'dot-matrix', 100.00),
(3005, 'T', 'dry', 300.00),
(3006, 'T', 'ink-jet', 180.00),
(3007, 'F', 'laser', 220.00),
(3008, 'F', 'dot-matrix', 90.00),
(3009, 'T', 'laser', 450.00),
(3010, 'T', 'dry', 350.00);

-- a) Find PC models having a speed of at least 160 MHz.
SELECT Modelno, Speed, Price FROM PC WHERE Speed >= 160;

-- b) Find those manufacturers that sell Laptops, but not PC's.
SELECT DISTINCT Maker 
FROM PRODUCT 
WHERE Type = 'Laptop' 
AND Maker NOT IN (
    SELECT Maker 
    FROM PRODUCT 
    WHERE Type = 'PC'
);


-- c) Write a procedure to find the manufacturer who has produced the most expensive laptop.
-- Creating the procedure (MySQL format)
DELIMITER //


CREATE PROCEDURE FindMostExpensiveLaptopMaker()
BEGIN
    SELECT p.Maker, l.Price
    FROM PRODUCT p
    JOIN LAPTOP l ON p.Modelno = l.Modelno
    ORDER BY l.Price DESC
    LIMIT 1;
END //

DELIMITER ;

-- Execute the procedure
CALL FindMostExpensiveLaptopMaker();






