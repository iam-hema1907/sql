-- Creating the BOOKMASTER table
CREATE TABLE BOOKMASTER (
    bid INT NOT NULL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Creating the STUDENTMASTER table
CREATE TABLE STUDENTMASTER (
    stud_enrollno INT NOT NULL PRIMARY KEY,
    sname VARCHAR(50) NOT NULL,
    class VARCHAR(20) NOT NULL,
    dept VARCHAR(50) NOT NULL
);

-- Creating the ACCESSIONTABLE with CHECK constraint for avail
CREATE TABLE ACCESSIONTABLE (
    accession_no INT NOT NULL PRIMARY KEY,
    bid INT NOT NULL,
    avail CHAR(1) NOT NULL CHECK (avail IN ('T', 'F')),
    FOREIGN KEY (bid) REFERENCES BOOKMASTER(bid)
);

-- Creating the ISSUETABLE
-- Note: Since the rules state "no attributes should be null", we must provide a ret_date 
-- for every record. In a real system, an unreturned book might have a NULL return date, 
-- but we will follow the strict constraint rule provided.
CREATE TABLE ISSUETABLE (
    issueid INT NOT NULL PRIMARY KEY,
    accession_no INT NOT NULL,
    stud_enrollno INT NOT NULL,
    issuedate DATE NOT NULL,
    duedate DATE NOT NULL,
    ret_date DATE NOT NULL,
    bid INT NOT NULL,
    FOREIGN KEY (accession_no) REFERENCES ACCESSIONTABLE(accession_no),
    FOREIGN KEY (stud_enrollno) REFERENCES STUDENTMASTER(stud_enrollno),
    FOREIGN KEY (bid) REFERENCES BOOKMASTER(bid)
);

-- Inserting 10 records into BOOKMASTER
INSERT INTO BOOKMASTER (bid, title, author, price) VALUES
(1, 'Database Systems', 'Elmasri', 500.00),
(2, 'Operating Systems', 'Galvin', 450.00),
(3, 'Computer Networks', 'Tanenbaum', 600.00),
(4, 'Data Structures', 'Tenbaum', 400.00),
(5, 'Software Engineering', 'Pressman', 550.00),
(6, 'Digital Logic', 'Morris Mano', 350.00),
(7, 'Machine Learning', 'Tom Mitchell', 700.00),
(8, 'Artificial Intelligence', 'Rich Knight', 650.00),
(9, 'Theory of Computation', 'Sipser', 480.00),
(10, 'Discrete Math', 'Rosen', 520.00);

-- Inserting 10 records into STUDENTMASTER
-- Including students from 'Computer' department for Query B
INSERT INTO STUDENTMASTER (stud_enrollno, sname, class, dept) VALUES
(101, 'Alice Smith', 'SE', 'Computer'),
(102, 'Bob Johnson', 'TE', 'IT'),
(103, 'Charlie Brown', 'BE', 'Computer'),
(104, 'Diana Prince', 'SE', 'Mechanical'),
(105, 'Evan Wright', 'TE', 'Civil'),
(106, 'Fiona Glen', 'BE', 'Computer'),
(107, 'George King', 'SE', 'IT'),
(108, 'Hannah Abbott', 'TE', 'Electrical'),
(109, 'Ian Stone', 'BE', 'Computer'),
(110, 'Jane Doe', 'SE', 'Mechanical');

-- Inserting 10 records into ACCESSIONTABLE
-- Represents specific physical copies of the books
INSERT INTO ACCESSIONTABLE (accession_no, bid, avail) VALUES
(1001, 1, 'F'), -- Database Systems (Copy 1)
(1002, 1, 'T'), -- Database Systems (Copy 2)
(1003, 2, 'F'), -- Operating Systems
(1004, 3, 'F'), -- Computer Networks
(1005, 4, 'T'), -- Data Structures
(1006, 5, 'F'), -- Software Engineering
(1007, 6, 'F'), -- Digital Logic
(1008, 7, 'T'), -- Machine Learning
(1009, 8, 'F'), -- AI
(1010, 9, 'F'); -- Theory of Computation

-- Inserting 10 records into ISSUETABLE
-- Setting some ret_dates past the duedate to test the Fine calculation (Query C)
-- Intentionally issuing 'Database Systems' (bid=1) multiple times for Query A
INSERT INTO ISSUETABLE (issueid, accession_no, stud_enrollno, issuedate, duedate, ret_date, bid) VALUES
(1, 1001, 101, '2023-10-01', '2023-10-15', '2023-10-14', 1), -- Returned on time
(2, 1003, 102, '2023-10-02', '2023-10-16', '2023-10-20', 2), -- 4 days late
(3, 1004, 103, '2023-10-05', '2023-10-19', '2023-10-25', 3), -- 6 days late (Computer Dept)
(4, 1001, 104, '2023-10-20', '2023-11-04', '2023-11-02', 1), -- Database Systems issued again
(5, 1006, 106, '2023-10-22', '2023-11-06', '2023-11-06', 5), -- Returned exact due date (Computer Dept)
(6, 1007, 107, '2023-10-25', '2023-11-09', '2023-11-15', 6), -- 6 days late
(7, 1009, 109, '2023-11-01', '2023-11-15', '2023-11-20', 8), -- 5 days late (Computer Dept)
(8, 1010, 110, '2023-11-05', '2023-11-19', '2023-11-22', 9), -- 3 days late
(9, 1001, 103, '2023-11-05', '2023-11-19', '2023-11-18', 1), -- Database Systems issued a 3rd time
(10, 1004, 101, '2023-11-10', '2023-11-24', '2023-11-24', 3); -- On time

-- a) Find the name of books which is issued maximum times.
SELECT b.title, COUNT(i.issueid) AS issue_count
FROM BOOKMASTER b
JOIN ISSUETABLE i ON b.bid = i.bid
GROUP BY b.bid, b.title
ORDER BY issue_count DESC
LIMIT 1;

-- b) Find the detail information of books that are issued by computer department students.
SELECT DISTINCT b.*
FROM BOOKMASTER b
JOIN ISSUETABLE i ON b.bid = i.bid
JOIN STUDENTMASTER s ON i.stud_enrollno = s.stud_enrollno
WHERE s.dept = 'Computer';

-- c) Write a procedure to calculate the fines for the books which are not return on or before due date. no.of days = (ret_date - due_date) fine = no.of days * 10
DELIMITER //
CREATE PROCEDURE Calculate_Late_Fines()
BEGIN
    SELECT 
        issueid, 
        stud_enrollno, 
        bid, 
        duedate, 
        ret_date,
        -- Calculate the number of days late
        DATEDIFF(ret_date, duedate) AS no_of_days,
        -- Multiply the days by 10 to get the total fine
        (DATEDIFF(ret_date, duedate) * 10) AS fine
    FROM ISSUETABLE
    -- Only calculate for books where the return date is strictly AFTER the due date
    WHERE ret_date > duedate;
END //
DELIMITER ;

-- Execute the procedure to see the results
CALL Calculate_Late_Fines();