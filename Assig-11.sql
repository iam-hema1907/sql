 -- Creating the ACCOUNT table
CREATE TABLE ACCOUNT3 (
    accno INT NOT NULL PRIMARY KEY CHECK (accno < 1000), -- Less than 4 digits
    open_date DATE NOT NULL,
    acctype CHAR(1) NOT NULL CHECK (acctype IN ('P', 'J')),
    bal DECIMAL(15, 2) NOT NULL
);

-- Creating the CUSTOMER table
CREATE TABLE CUSTOMER3 (
    cust_id INT NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    accno INT NOT NULL,
    FOREIGN KEY (accno) REFERENCES ACCOUNT3(accno)
);

-- Creating the TRANSACTION table
CREATE TABLE TRANSACTION3 (
    trans_id INT NOT NULL PRIMARY KEY,
    trans_date DATE NOT NULL,
    accno INT NOT NULL,
    trans_type CHAR(1) NOT NULL CHECK (trans_type IN ('C', 'D')),
    amount DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (accno) REFERENCES ACCOUNT3(accno)
);

-- Inserting 10 records into ACCOUNT
-- Including open dates between March 25-28, 2022 (for Query A)
-- Including Joint accounts with balance < 300,000 (for Query B)
INSERT INTO ACCOUNT3 (accno, open_date, acctype, bal) VALUES
(101, '2022-01-15', 'P', 150000.00),
(102, '2022-03-25', 'J', 250000.00), -- Target for A & B (Opened 25th, Joint, < 3 Lakhs)
(103, '2022-03-26', 'P', 350000.00), -- Target for A
(104, '2022-03-28', 'J', 120000.00), -- Target for A & B (Opened 28th, Joint, < 3 Lakhs)
(105, '2022-04-12', 'P', 50000.00),
(106, '2022-06-22', 'J', 400000.00), -- Joint, but > 3 Lakhs
(107, '2022-07-30', 'J', 95000.00),  -- Target for B (Joint, < 3 Lakhs)
(108, '2022-08-14', 'P', 300000.00), 
(109, '2022-09-09', 'J', 45000.00),  -- Target for B (Joint, < 3 Lakhs)
(110, '2022-10-01', 'P', 290000.00); 

-- Inserting 10 records into CUSTOMER
INSERT INTO CUSTOMER3 (cust_id, name, address, accno) VALUES
(1, 'Alice Smith', '10 Elm St', 101),
(2, 'Bob Johnson', '20 Oak St', 102),
(3, 'Charlie Brown', '30 Pine St', 103),
(4, 'Diana Prince', '40 Maple St', 104),
(5, 'Evan Wright', '50 Cedar St', 105),
(6, 'Fiona Glenanne', '60 Birch St', 106),
(7, 'George King', '70 Ash St', 107),
(8, 'Hannah Abbott', '80 Spruce St', 108),
(9, 'Ian Somerhalder', '90 Walnut St', 109),
(10, 'Jane Doe', '100 Cherry St', 110);

-- Inserting 10 records into TRANSACTION
INSERT INTO TRANSACTION3 (trans_id, trans_date, accno, trans_type, amount) VALUES
(1001, '2022-05-10', 101, 'C', 5000.00),
(1002, '2022-05-15', 102, 'D', 1000.00), 
(1003, '2022-06-16', 103, 'C', 2000.00),  
(1004, '2022-06-18', 104, 'C', 15000.00), 
(1005, '2022-07-19', 105, 'D', 8000.00),  
(1006, '2022-08-16', 106, 'C', 12000.00), 
(1007, '2022-09-01', 107, 'D', 5000.00),
(1008, '2022-10-05', 108, 'C', 25000.00), 
(1009, '2022-11-10', 109, 'C', 3000.00),
(1010, '2022-12-15', 110, 'D', 1500.00);
 -- a) Find the details of customers who have opened the accounts within the period 25-3-2022 to 28-3-2022.
SELECT c.*, a.open_date
FROM CUSTOMER3 c
JOIN ACCOUNT3 a ON c.accno = a.accno
WHERE a.open_date BETWEEN '2022-03-25' AND '2022-03-28';

-- b) Find the details of customers who have joint accounts & balance is less than 3 lakhs.
SELECT c.*, a.acctype, a.bal
FROM CUSTOMER3 c
JOIN ACCOUNT3 a ON c.accno = a.accno
WHERE a.acctype = 'J' AND a.bal < 300000;

-- c) Write a cursor on CUSTOMER table to fetch the last row.
DELIMITER //
CREATE PROCEDURE FetchLastCustomer1()
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
        FROM CUSTOMER3 
        ORDER BY cust_id ASC;
        
    -- Declare handler for when the cursor runs out of rows
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_cust_id, v_name, v_address, v_accno;
        
        -- If no more rows, exit the loop
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- The variables are overwritten on every pass. 
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
CALL FetchLastCustomer1();