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

-- Creating the PRINTER table with CHECK constraints for Color and Printer Type
CREATE TABLE PRINTER (
    Modelno INT NOT NULL PRIMARY KEY,
    Color CHAR(1) NOT NULL CHECK (Color IN ('T', 'F')),
    Type VARCHAR(20) NOT NULL CHECK (Type IN ('laser', 'ink-jet', 'dot-matrix', 'dry')),
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Modelno) REFERENCES PRODUCT(Modelno)
);

-- Inserting 30 products into the PRODUCT table (10 PCs, 10 Laptops, 10 Printers)
-- Including 'Epson' producing multiple types of printers to test Query A
INSERT INTO PRODUCT (Maker, Modelno, Type) VALUES
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
-- Intentionally repeating some HD sizes (e.g., 250, 500) to test Query B
INSERT INTO PC (Modelno, Speed, RAM, HD, CD, Price) VALUES
(1001, 3000, 8000, 500, '52x', 600.00),
(1002, 2500, 4000, 250, '48x', 450.00),
(1003, 3200, 16000, 1000, '52x', 900.00),
(1004, 2800, 8000, 500, '52x', 700.00),   -- HD 500 repeats
(1005, 3500, 32000, 2000, '52x', 1500.00),
(1006, 2400, 4000, 250, '48x', 400.00),   -- HD 250 repeats
(1007, 3100, 16000, 1000, '52x', 950.00), -- HD 1000 repeats
(1008, 2900, 8000, 500, '52x', 750.00),   -- HD 500 repeats again
(1009, 3600, 32000, 2000, '52x', 1600.00),-- HD 2000 repeats
(1010, 4000, 64000, 4000, '52x', 2500.00);


-- Inserting 10 records into the LAPTOP table
INSERT INTO LAPTOP (Modelno, Speed, RAM, HD, Price) VALUES
(2001, 2500, 8000, 250, 800.00),
(2002, 2800, 16000, 500, 1200.00),
(2003, 2400, 8000, 250, 750.00),
(2004, 3000, 16000, 1000, 1400.00),
(2005, 3200, 32000, 2000, 2000.00),
(2006, 2600, 8000, 500, 1000.00),
(2007, 2200, 4000, 250, 600.00), 
(2008, 2700, 16000, 500, 1100.00),
(2009, 3100, 32000, 1000, 1800.00),
(2010, 3500, 64000, 2000, 2500.00);


-- Inserting 10 records into the PRINTER table
INSERT INTO PRINTER (Modelno, Color, Type, Price) VALUES
(3001, 'T', 'ink-jet', 150.00),
(3002, 'F', 'laser', 200.00),
(3003, 'T', 'laser', 450.00),
(3004, 'F', 'dot-matrix', 80.00),
(3005, 'T', 'dry', 300.00),
(3006, 'F', 'laser', 220.00), 
(3007, 'T', 'ink-jet', 160.00),
(3008, 'F', 'dot-matrix', 90.00),
(3009, 'T', 'laser', 500.00),
(3010, 'F', 'laser', 180.00);

-- a) Find the different types of printers produced by Epson.


SELECT DISTINCT pr.Type 
FROM PRINTER pr
JOIN PRODUCT p ON pr.Modelno = p.Modelno
WHERE p.Maker = 'Epson';

-- b) Find those hard disk sizes which occur in two or more PC's.


SELECT HD, COUNT(Modelno) AS Number_of_PCs
FROM PC
GROUP BY HD
HAVING COUNT(Modelno) >= 2;


-- c) Demonstrate the use of cursor using PRODUCT table.


DELIMITER //

CREATE PROCEDURE Cursor_Demo_Product()
BEGIN
    -- 1. Declare variables to store the data fetched by the cursor
    DECLARE v_maker VARCHAR(50);
    DECLARE v_modelno INT;
    DECLARE v_type VARCHAR(20);
    
    -- 2. Declare a flag to track when we run out of rows
    DECLARE done INT DEFAULT FALSE;
    
    -- 3. Define the cursor (Ordering by Modelno for consistency)
    DECLARE product_cursor CURSOR FOR 
        SELECT Maker, Modelno, Type 
        FROM PRODUCT 
        ORDER BY Modelno ASC;
        
    -- 4. Define what to do when the cursor hits the end of the table
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 5. Open the cursor to start reading
    OPEN product_cursor;

    -- 6. Loop through the rows
    read_loop: LOOP
        FETCH product_cursor INTO v_maker, v_modelno, v_type;
        
        -- If there are no more rows, break out of the loop
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- (In a real application, you might do complex math or updates here row-by-row)
    END LOOP;

    -- 7. Close the cursor to free up memory
    CLOSE product_cursor;

    -- 8. Display the final variables to prove the cursor iterated successfully
    SELECT 
        v_maker AS Last_Maker_Read, 
        v_modelno AS Last_Model_Read, 
        v_type AS Last_Type_Read;

END //

DELIMITER ;

-- Call the procedure to run the cursor demonstration
CALL Cursor_Demo_Product();