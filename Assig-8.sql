-- Creating the ACCOUNT table
CREATE TABLE ACCOUNT (
    accno INT NOT NULL PRIMARY KEY CHECK (accno < 1000),
    open_date DATE NOT NULL,
    acctype CHAR(1) NOT NULL CHECK (acctype IN ('P', 'J')),
    balance DECIMAL(15, 2) NOT NULL
);

-- Creating the CUSTOMER table
CREATE TABLE CUSTOMER (
    cust_id INT NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    accno INT NOT NULL,
    FOREIGN KEY (accno) REFERENCES ACCOUNT(accno)
);

-- Creating the TRANSACTION table
CREATE TABLE TRANSACTION (
    trans_id INT NOT NULL PRIMARY KEY,
    trans_date DATE NOT NULL,
    accno INT NOT NULL,
    trans_type CHAR(1) NOT NULL CHECK (trans_type IN ('C', 'D')),
    amount DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (accno) REFERENCES ACCOUNT(accno)
);

-- Inserting 10 records into ACCOUNT
-- Note: '1 lakhs' equals 100,000. Some accounts have >= 100,000 to test Query A.
INSERT INTO ACCOUNT (accno, open_date, acctype, balance) VALUES
(101, '2021-01-15', 'P', 150000.00), -- Balance > 1 Lakh
(102, '2021-02-20', 'J', 50000.00),
(103, '2021-03-10', 'P', 250000.00), -- Balance > 1 Lakh
(104, '2021-04-05', 'P', 15000.00),
(105, '2021-05-12', 'J', 120000.00), -- Balance > 1 Lakh
(106, '2021-06-22', 'P', 80000.00),
(107, '2021-07-30', 'J', 95000.00),
(108, '2021-08-14', 'P', 300000.00), -- Balance > 1 Lakh
(109, '2021-09-09', 'J', 45000.00),
(110, '2021-10-01', 'P', 100000.00); -- Balance Exactly 1 Lakh

-- Inserting 10 records into CUSTOMER
INSERT INTO CUSTOMER (cust_id, name, address, accno) VALUES
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
-- Includes credits ('C') between June 25, 2022 and June 28, 2022 to test Query B.
INSERT INTO TRANSACTION (trans_id, trans_date, accno, trans_type, amount) VALUES
(1001, '2022-06-20', 101, 'C', 5000.00),
(1002, '2022-06-25', 102, 'C', 10000.00), -- Target for Query B
(1003, '2022-06-26', 103, 'D', 2000.00),  -- Date matches, but it's a Debit
(1004, '2022-06-27', 104, 'C', 15000.00), -- Target for Query B
(1005, '2022-06-28', 105, 'C', 8000.00),  -- Target for Query B
(1006, '2022-06-29', 106, 'C', 12000.00),
(1007, '2022-07-01', 107, 'D', 5000.00),
(1008, '2022-06-26', 108, 'C', 25000.00), -- Target for Query B
(1009, '2022-08-10', 109, 'D', 3000.00),
(1010, '2022-08-15', 110, 'C', 7500.00);

-- a) Find the details of customers whose minimum balance is 1 lakhs.
SELECT c.*, a.balance
FROM CUSTOMER c
JOIN ACCOUNT a ON c.accno = a.accno
WHERE a.balance >= 100000;

-- b) Find the details of amount credited within the period 25-6-2022 to 28-6- 2022.
SELECT * FROM TRANSACTION
WHERE trans_type = 'C' 
  AND trans_date BETWEEN '2022-06-25' AND '2022-06-28';
  
-- c) Write a trigger on TRANSACTION table to calculate current balance of account on which transaction is made.
DELIMITER //
CREATE TRIGGER Update_Balance_After_Transaction
AFTER INSERT ON TRANSACTION
FOR EACH ROW
BEGIN
    -- If the transaction is a credit, ADD to the balance
    IF NEW.trans_type = 'C' THEN
        UPDATE ACCOUNT 
        SET balance = balance + NEW.amount 
        WHERE accno = NEW.accno;
        
    -- If the transaction is a debit, SUBTRACT from the balance
    ELSEIF NEW.trans_type = 'D' THEN
        UPDATE ACCOUNT 
        SET balance = balance - NEW.amount 
        WHERE accno = NEW.accno;
    END IF;
END //

DELIMITER ;

