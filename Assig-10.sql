-- Creating the ACCOUNT table
CREATE TABLE ACCOUNT2 (
    accno INT NOT NULL PRIMARY KEY CHECK (accno < 1000), -- Less than 4 digits
    open_date DATE NOT NULL,
    acctype CHAR(1) NOT NULL CHECK (acctype IN ('P', 'J')),
    balance DECIMAL(15, 2) NOT NULL
);

-- Creating the CUSTOMER table
CREATE TABLE CUSTOMER2 (
    cust_id INT NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    accno INT NOT NULL,
    FOREIGN KEY (accno) REFERENCES ACCOUNT2(accno)
);

-- Creating the TRANSACTION table
CREATE TABLE TRANSACTION2 (
    trans_id INT NOT NULL PRIMARY KEY,
    trans_date DATE NOT NULL,
    accno INT NOT NULL,
    trans_type CHAR(1) NOT NULL CHECK (trans_type IN ('C', 'D')),
    amount DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (accno) REFERENCES ACCOUNT2(accno)
);

-- Inserting 10 records into ACCOUNT
-- Including balances <= 800 to test the trigger later
INSERT INTO ACCOUNT2 (accno, open_date, acctype, balance) VALUES
(101, '2021-01-15', 'P', 15000.00),
(102, '2021-02-20', 'J', 50000.00),
(103, '2021-03-10', 'J', 25000.00), -- Target for Query A
(104, '2021-04-05', 'P', 1500.00),
(105, '2021-05-12', 'P', 500.00),   -- Balance <= 800 (for trigger test)
(106, '2021-06-22', 'J', 80000.00),
(107, '2021-07-30', 'P', 800.00),   -- Balance = 800 (for trigger test)
(108, '2021-08-14', 'P', 30000.00), 
(109, '2021-09-09', 'J', 45000.00),  
(110, '2021-10-01', 'P', 29000.00); 

-- Inserting 10 records into CUSTOMER
-- Note: Customers 3 and 4 share Account 103 to demonstrate a Joint Account
INSERT INTO CUSTOMER2 (cust_id, name, address, accno) VALUES
(1, 'Alice Smith', '10 Elm St', 101),
(2, 'Bob Johnson', '20 Oak St', 102),
(3, 'Charlie Brown', '30 Pine St', 103), -- Owner 1 of Acc 103
(4, 'Diana Prince', '40 Maple St', 103), -- Owner 2 of Acc 103
(5, 'Evan Wright', '50 Cedar St', 105),
(6, 'Fiona Glenanne', '60 Birch St', 106),
(7, 'George King', '70 Ash St', 107),
(8, 'Hannah Abbott', '80 Spruce St', 108),
(9, 'Ian Somerhalder', '90 Walnut St', 109),
(10, 'Jane Doe', '100 Cherry St', 110);

-- Inserting 10 records into TRANSACTION
-- Includes credits ('C') between March 15 and March 18, 2022 to test Query B
INSERT INTO TRANSACTION2 (trans_id, trans_date, accno, trans_type, amount) VALUES
(1001, '2022-03-10', 103, 'D', 1000.00),  -- Target for Query A
(1002, '2022-03-15', 103, 'C', 5000.00),  -- Target for Queries A & B
(1003, '2022-03-16', 101, 'C', 2000.00),  -- Target for Query B
(1004, '2022-03-18', 102, 'C', 15000.00), -- Target for Query B
(1005, '2022-03-19', 104, 'C', 8000.00),  -- Date outside range
(1006, '2022-03-16', 106, 'D', 12000.00), -- Matches date, but is a Debit
(1007, '2022-04-01', 107, 'C', 5000.00),
(1008, '2022-05-05', 108, 'D', 2500.00), 
(1009, '2022-06-10', 109, 'C', 3000.00),
(1010, '2022-07-15', 110, 'D', 1500.00);

-- a) Find the details of all transactions performed on account number 103. Also specify the name/names of cutomers who owns that account.
SELECT t.trans_id, t.trans_date, t.trans_type, t.amount, c.name AS Owner_Name
FROM TRANSACTION2 t
JOIN CUSTOMER2 c ON t.accno = c.accno
WHERE t.accno = 103;

-- b) Find the details of amount credited within the period 15 -3-2022 to 18 -3 -2022.
SELECT * FROM TRANSACTION2
WHERE trans_type = 'C' 
  AND trans_date BETWEEN '2022-03-15' AND '2022-03-18';
  
-- c) Write a trigger on insert on ACCOUNT table such that the account which is having balance less than or equal to 800 should not be debited
DELIMITER //
CREATE TRIGGER Prevent_Low_Balance_Debit1
BEFORE INSERT ON TRANSACTION2
FOR EACH ROW
BEGIN
    DECLARE current_balance DECIMAL(15,2);
    -- Only check rules if the incoming transaction is a Debit
    IF NEW.trans_type = 'D' THEN
        -- Fetch the current balance of the account
        SELECT balance INTO current_balance 
        FROM ACCOUNT2 
        WHERE accno = NEW.accno;
        
        -- If balance is 800 or less, block the insert
        IF current_balance <= 800 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Error: Account balance is 800 or less. Debit not allowed.';
        END IF;
    END IF;
END //
DELIMITER ;

INSERT INTO TRANSACTION2 (trans_id, trans_date, accno, trans_type, amount) 
VALUES (9999, '2023-11-01', 107, 'D', 1200.00);


