-- Creating the ACCOUNT table
CREATE TABLE ACCOUNT1 (
    accno INT NOT NULL PRIMARY KEY CHECK (accno < 1000),
    open_date DATE NOT NULL,
    acctype CHAR(1) NOT NULL CHECK (acctype IN ('P', 'J')),
    balance DECIMAL(15, 2) NOT NULL
);

-- Creating the CUSTOMER table
CREATE TABLE CUSTOMER1 (
    cust_id INT NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    accno INT NOT NULL,
    FOREIGN KEY (accno) REFERENCES ACCOUNT1(accno)
);

-- Creating the TRANSACTION table
CREATE TABLE TRANSACTION1 (
    trans_id INT NOT NULL PRIMARY KEY,
    trans_date DATE NOT NULL,
    accno INT NOT NULL,
    trans_type CHAR(1) NOT NULL CHECK (trans_type IN ('C', 'D')),
    amount DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (accno) REFERENCES ACCOUNT1(accno)
);

-- Inserting 10 records into ACCOUNT
-- Note: '3 lakhs' equals 300,000. Balances are mixed to test Query A.
INSERT INTO ACCOUNT1 (accno, open_date, acctype, balance) VALUES
(101, '2021-01-15', 'P', 150000.00), -- Personal, < 3 Lakhs
(102, '2021-02-20', 'J', 500000.00), -- Joint
(103, '2021-03-10', 'P', 350000.00), -- Personal, > 3 Lakhs
(104, '2021-04-05', 'P', 25000.00),  -- Personal, < 3 Lakhs
(105, '2021-05-12', 'J', 120000.00), -- Joint
(106, '2021-06-22', 'P', 80000.00),  -- Personal, < 3 Lakhs
(107, '2021-07-30', 'J', 95000.00),  -- Joint
(108, '2021-08-14', 'P', 400000.00), -- Personal, > 3 Lakhs
(109, '2021-09-09', 'J', 45000.00),  -- Joint
(110, '2021-10-01', 'P', 290000.00); -- Personal, < 3 Lakhs

-- Inserting 10 records into CUSTOMER
INSERT INTO CUSTOMER1 (cust_id, name, address, accno) VALUES
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
INSERT INTO TRANSACTION1 (trans_id, trans_date, accno, trans_type, amount) VALUES
(1001, '2022-06-20', 101, 'C', 5000.00),
(1002, '2022-06-25', 102, 'D', 10000.00), 
(1003, '2022-06-26', 103, 'D', 2000.00),  
(1004, '2022-06-27', 104, 'C', 15000.00), 
(1005, '2022-06-28', 105, 'C', 8000.00),  
(1006, '2022-06-29', 106, 'C', 12000.00),
(1007, '2022-07-01', 107, 'D', 5000.00),
(1008, '2022-07-05', 108, 'D', 25000.00), 
(1009, '2022-08-10', 109, 'C', 3000.00),
(1010, '2022-08-15', 110, 'D', 7500.00);

-- a) Find the details of customers who have personal accounts & balance is less than 3 lakhs.
SELECT c.*, a.balance, a.acctype
FROM CUSTOMER1 c
JOIN ACCOUNT1 a ON c.accno = a.accno
WHERE a.acctype = 'P' AND a.balance < 300000;

-- b) Find the details of customers who have joint accounts.
SELECT c.*, a.acctype
FROM CUSTOMER1 c
JOIN ACCOUNT1 a ON c.accno = a.accno
WHERE a.acctype = 'J';

-- c) Write a procedure on ACCOUNT & TRANSACTION table such that as user enters new transaction the balance is, updated in ACCOUNT table.
DELIMITER //
CREATE PROCEDURE Process_New_Transaction(
    IN p_trans_id INT,
    IN p_trans_date DATE,
    IN p_accno INT,
    IN p_trans_type CHAR(1),
    IN p_amount DECIMAL(15,2)
)
BEGIN
    -- 1. Insert the new record into the TRANSACTION table
    INSERT INTO TRANSACTION (trans_id, trans_date, accno, trans_type, amount)
    VALUES (p_trans_id, p_trans_date, p_accno, p_trans_type, p_amount);

    -- 2. Check if it's a Credit or Debit, and update the ACCOUNT balance accordingly
    IF p_trans_type = 'C' THEN
        UPDATE ACCOUNT 
        SET balance = balance + p_amount 
        WHERE accno = p_accno;
        
    ELSEIF p_trans_type = 'D' THEN
        UPDATE ACCOUNT 
        SET balance = balance - p_amount 
        WHERE accno = p_accno;
    END IF;
    
END //
DELIMITER ;

CALL Process_New_Transaction(1011, '2023-11-01', 101, 'C', 5000.00);