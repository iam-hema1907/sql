-- Creating the ACCOUNT table
CREATE TABLE ACCOUNT4 (
    accno INT NOT NULL PRIMARY KEY CHECK (accno < 100), -- Less than 3 digits (1-99)
    open_date DATE NOT NULL,
    acctype CHAR(1) NOT NULL CHECK (acctype IN ('P', 'J')),
    bal DECIMAL(15, 2) NOT NULL
);

-- Creating the CUSTOMER table
CREATE TABLE CUSTOMER4 (
    cust_id INT NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    accno INT NOT NULL,
    FOREIGN KEY (accno) REFERENCES ACCOUNT4(accno)
);

-- Creating the TRANSACTION table
CREATE TABLE TRANSACTION4 (
    trans_id INT NOT NULL PRIMARY KEY,
    trans_date DATE NOT NULL,
    accno INT NOT NULL,
    trans_type CHAR(1) NOT NULL CHECK (trans_type IN ('C', 'D')),
    amount DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (accno) REFERENCES ACCOUNT4(accno)
);

-- Inserting 10 records into ACCOUNT
-- Including open dates between March 25-28, 2018 (for Query A)
-- Including Joint accounts with balance < 200,000 (for Query B)
INSERT INTO ACCOUNT4 (accno, open_date, acctype, bal) VALUES
(10, '2018-01-15', 'P', 150000.00),
(11, '2018-03-25', 'J', 150000.00), -- Target for A & B (Opened 25th, Joint, < 2 Lakhs)
(12, '2018-03-26', 'P', 350000.00), -- Target for A
(13, '2018-03-28', 'J', 120000.00), -- Target for A & B (Opened 28th, Joint, < 2 Lakhs)
(14, '2018-04-12', 'P', 50000.00),
(15, '2018-06-22', 'J', 400000.00), -- Joint, but > 2 Lakhs
(16, '2018-07-30', 'J', 95000.00),  -- Target for B (Joint, < 2 Lakhs)
(17, '2018-08-14', 'P', 300000.00), 
(18, '2018-09-09', 'J', 45000.00),  -- Target for B (Joint, < 2 Lakhs)
(19, '2018-10-01', 'P', 290000.00); 

-- Inserting 10 records into CUSTOMER
INSERT INTO CUSTOMER4 (cust_id, name, address, accno) VALUES
(1, 'Alice Smith', '10 Elm St', 10),
(2, 'Bob Johnson', '20 Oak St', 11),
(3, 'Charlie Brown', '30 Pine St', 12),
(4, 'Diana Prince', '40 Maple St', 13),
(5, 'Evan Wright', '50 Cedar St', 14),
(6, 'Fiona Glenanne', '60 Birch St', 15),
(7, 'George King', '70 Ash St', 16),
(8, 'Hannah Abbott', '80 Spruce St', 17),
(9, 'Ian Somerhalder', '90 Walnut St', 18),
(10, 'Jane Doe', '100 Cherry St', 19);

-- Inserting 10 records into TRANSACTION
INSERT INTO TRANSACTION4 (trans_id, trans_date, accno, trans_type, amount) VALUES
(1001, '2018-05-10', 10, 'C', 5000.00),
(1002, '2018-05-15', 11, 'D', 1000.00), 
(1003, '2018-06-16', 12, 'C', 2000.00),  
(1004, '2018-06-18', 13, 'C', 15000.00), 
(1005, '2018-07-19', 14, 'D', 8000.00),  
(1006, '2018-08-16', 15, 'C', 12000.00), 
(1007, '2018-09-01', 16, 'D', 5000.00),
(1008, '2018-10-05', 17, 'C', 25000.00), 
(1009, '2018-11-10', 18, 'C', 3000.00),
(1010, '2018-12-15', 19, 'D', 1500.00);
-- a) Find the details of customers who have opened the accounts within the period 25-3-2018 to 28-3-2018.
SELECT c.*, a.open_date
FROM CUSTOMER4 c
JOIN ACCOUNT4 a ON c.accno = a.accno
WHERE a.open_date BETWEEN '2018-03-25' AND '2018-03-28';

--  b) Find the details of customers who have joint accounts & balance is less than 2 lakhs.
SELECT c.*, a.acctype, a.bal
FROM CUSTOMER4 c
JOIN ACCOUNT4 a ON c.accno = a.accno
WHERE a.acctype = 'J' AND a.bal < 200000;

-- c) Write a cursor on CUSTOMER table to fetch the last row.
DELIMITER //

CREATE PROCEDURE FetchLastCustomerRow()
BEGIN
    -- Variables to hold the fetched data
    DECLARE v_cust_id INT;
    DECLARE v_name VARCHAR(50);
    DECLARE v_address VARCHAR(100);
    DECLARE v_accno INT;
    
    -- Variable to handle loop termination
    DECLARE done INT DEFAULT FALSE;
    
    -- Declare the cursor (Ordered by cust_id to guarantee sequence)
    DECLARE cur CURSOR FOR 
        SELECT cust_id, name, address, accno 
        FROM CUSTOMER4 
        ORDER BY cust_id ASC;
        
    -- Declare handler for when the cursor runs out of rows
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Open the cursor
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_cust_id, v_name, v_address, v_accno;
        
        -- If no more rows, exit the loop
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Variables are overwritten on every pass. 
        -- When the loop finally exits, they contain the last record.
    END LOOP;

    CLOSE cur;

    -- Display the details of the final record fetched
    SELECT 
        v_cust_id AS Last_Cust_ID, 
        v_name AS Last_Name, 
        v_address AS Last_Address, 
        v_accno AS Last_Accno;

END //
DELIMITER ;

-- Execute the procedure to see the result
CALL FetchLastCustomerRow();