-- Creating the BOOKMASTER table
CREATE TABLE BOOKMASTER2 (
    bid INT NOT NULL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Creating the STUDENTMASTER table
CREATE TABLE STUDENTMASTER2 (
    stud_enrollno INT NOT NULL PRIMARY KEY,
    sname VARCHAR(50) NOT NULL,
    class VARCHAR(20) NOT NULL,
    dept VARCHAR(50) NOT NULL
);

-- Creating the ACCESSIONTABLE with CHECK constraint for avail
CREATE TABLE ACCESSIONTABLE2 (
    accession_no INT NOT NULL PRIMARY KEY,
    bid INT NOT NULL,
    avail CHAR(1) NOT NULL CHECK (avail IN ('T', 'F')),
    FOREIGN KEY (bid) REFERENCES BOOKMASTER2(bid)
);

-- Creating the ISSUETABLE
-- Note: The rules state "The values of any attributes should not be null". 
-- Therefore, a ret_date must be provided for every record to satisfy the strict constraint.
CREATE TABLE ISSUETABLE2 (
    issueid INT NOT NULL PRIMARY KEY,
    accession_no INT NOT NULL,
    stud_enrollno INT NOT NULL,
    issuedate DATE NOT NULL,
    duedate DATE NOT NULL,
    ret_date DATE NOT NULL,
    bid INT NOT NULL,
    FOREIGN KEY (accession_no) REFERENCES ACCESSIONTABLE2(accession_no),
    FOREIGN KEY (stud_enrollno) REFERENCES STUDENTMASTER2(stud_enrollno),
    FOREIGN KEY (bid) REFERENCES BOOKMASTER2(bid)
);

-- Inserting 10 records into BOOKMASTER
-- Intentionally including "E.Navathe" as an author for Query C
INSERT INTO BOOKMASTER2 (bid, title, author, price) VALUES
(1, 'Database Systems', 'E.Navathe', 650.00),
(2, 'Operating Systems', 'Galvin', 450.00),
(3, 'Computer Networks', 'Tanenbaum', 600.00),
(4, 'Data Structures', 'Tenbaum', 400.00),
(5, 'Software Engineering', 'Pressman', 550.00),
(6, 'Digital Logic', 'Morris Mano', 350.00),
(7, 'Machine Learning', 'Tom Mitchell', 700.00),
(8, 'Artificial Intelligence', 'Rich Knight', 650.00),
(9, 'Theory of Computation', 'Sipser', 480.00),
(10, 'Discrete Mathematics', 'Rosen', 520.00);

-- Inserting 10 records into STUDENTMASTER
INSERT INTO STUDENTMASTER2 (stud_enrollno, sname, class, dept) VALUES
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
-- Representing specific physical copies of the books
-- Providing multiple copies of 'E.Navathe' to test Query C properly
INSERT INTO ACCESSIONTABLE2 (accession_no, bid, avail) VALUES
(1001, 1, 'T'), -- E.Navathe (Available)
(1002, 1, 'F'), -- E.Navathe (Issued)
(1003, 1, 'T'), -- E.Navathe (Available)
(1004, 2, 'F'), -- Operating Systems
(1005, 3, 'T'), -- Computer Networks
(1006, 4, 'F'), -- Data Structures
(1007, 5, 'T'), -- Software Engineering
(1008, 6, 'F'), -- Digital Logic
(1009, 7, 'F'), -- Machine Learning
(1010, 8, 'T'); -- Artificial Intelligence

-- Inserting 10 records into ISSUETABLE
-- Some students are issuing multiple books to test Query B
INSERT INTO ISSUETABLE2 (issueid, accession_no, stud_enrollno, issuedate, duedate, ret_date, bid) VALUES
(1, 1002, 101, '2023-10-01', '2023-10-15', '2023-10-14', 1), 
(2, 1004, 102, '2023-10-05', '2023-10-19', '2023-10-20', 2), 
(3, 1006, 103, '2023-10-10', '2023-10-24', '2023-10-25', 4), 
(4, 1008, 103, '2023-10-15', '2023-10-29', '2023-10-28', 6), -- Charlie Brown issues a 2nd book
(5, 1009, 106, '2023-10-18', '2023-11-02', '2023-11-01', 7), 
(6, 1001, 107, '2023-10-20', '2023-11-04', '2023-11-05', 1), 
(7, 1003, 109, '2023-10-25', '2023-11-09', '2023-11-10', 1), 
(8, 1005, 110, '2023-11-01', '2023-11-15', '2023-11-12', 3), 
(9, 1007, 101, '2023-11-05', '2023-11-19', '2023-11-18', 5), -- Alice Smith issues a 2nd book
(10, 1010, 102, '2023-11-10', '2023-11-24', '2023-11-24', 8); -- Bob Johnson issues a 2nd book

-- a) Write a procedure for giving the detail information of books available in the library.
DELIMITER //
CREATE PROCEDURE Get_Available_Books()
BEGIN
    SELECT 
        a.accession_no, 
        b.bid, 
        b.title, 
        b.author, 
        b.price
    FROM BOOKMASTER2 b
    JOIN ACCESSIONTABLE2 a ON b.bid = a.bid
    WHERE a.avail = 'T';
END //
DELIMITER ;
-- To execute the procedure and see the results:
CALL Get_Available_Books();


-- b) Find the number of books issued by each student.
SELECT 
    s.stud_enrollno, 
    s.sname, 
    COUNT(i.issueid) AS Number_of_Books_Issued
FROM STUDENTMASTER2 s
JOIN ISSUETABLE2 i ON s.stud_enrollno = i.stud_enrollno
GROUP BY s.stud_enrollno, s.sname
ORDER BY Number_of_Books_Issued DESC;

-- a) Find the number of books available in the library & written by “E.Navathe".
SELECT COUNT(a.accession_no) AS Available_Navathe_Books
FROM BOOKMASTER2 b
JOIN ACCESSIONTABLE2 a ON b.bid = a.bid
WHERE b.author = 'E.Navathe' 
  AND a.avail = 'T';