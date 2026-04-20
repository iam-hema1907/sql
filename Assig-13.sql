-- Creating the BOOKMASTER table
CREATE TABLE BOOKMASTER1 (
    bid INT NOT NULL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Creating the STUDENTMASTER table
CREATE TABLE STUDENTMASTER1 (
    stud_enrollno INT NOT NULL PRIMARY KEY,
    sname VARCHAR(50) NOT NULL,
    class VARCHAR(20) NOT NULL,
    dept VARCHAR(50) NOT NULL
);

-- Creating the ACCESSIONTABLE with CHECK constraint for avail
CREATE TABLE ACCESSIONTABLE1 (
    accession_no INT NOT NULL PRIMARY KEY,
    bid INT NOT NULL,
    avail CHAR(1) NOT NULL CHECK (avail IN ('T', 'F')),
    FOREIGN KEY (bid) REFERENCES BOOKMASTER1(bid)
);

-- Creating the ISSUETABLE
-- Note: Since the prompt strictly states "no attributes should be null", 
-- a ret_date must be provided for every record to satisfy the constraint.
CREATE TABLE ISSUETABLE1 (
    issueid INT NOT NULL PRIMARY KEY,
    accession_no INT NOT NULL,
    stud_enrollno INT NOT NULL,
    issuedate DATE NOT NULL,
    duedate DATE NOT NULL,
    ret_date DATE NOT NULL,
    bid INT NOT NULL,
    FOREIGN KEY (accession_no) REFERENCES ACCESSIONTABLE1(accession_no),
    FOREIGN KEY (stud_enrollno) REFERENCES STUDENTMASTER1(stud_enrollno),
    FOREIGN KEY (bid) REFERENCES BOOKMASTER1(bid)
);

-- Inserting 10 records into BOOKMASTER
-- Intentionally including bid = 100 for Query B
INSERT INTO BOOKMASTER1 (bid, title, author, price) VALUES
(100, 'Database Concepts', 'Korth', 500.00),
(101, 'Operating Systems', 'Galvin', 450.00),
(102, 'Computer Networks', 'Tanenbaum', 600.00),
(103, 'Data Structures', 'Tenbaum', 400.00),
(104, 'Software Engineering', 'Pressman', 550.00),
(105, 'Digital Logic', 'Morris Mano', 350.00),
(106, 'Machine Learning', 'Tom Mitchell', 700.00),
(107, 'Artificial Intelligence', 'Rich Knight', 650.00),
(108, 'Theory of Computation', 'Sipser', 480.00),
(109, 'Discrete Mathematics', 'Rosen', 520.00);

-- Inserting 10 records into STUDENTMASTER
INSERT INTO STUDENTMASTER1 (stud_enrollno, sname, class, dept) VALUES
(1, 'Alice Smith', 'SE', 'Computer'),
(2, 'Bob Johnson', 'TE', 'IT'),
(3, 'Charlie Brown', 'BE', 'Computer'),
(4, 'Diana Prince', 'SE', 'Mechanical'),
(5, 'Evan Wright', 'TE', 'Civil'),
(6, 'Fiona Glen', 'BE', 'Computer'),
(7, 'George King', 'SE', 'IT'),
(8, 'Hannah Abbott', 'TE', 'Electrical'),
(9, 'Ian Stone', 'BE', 'Computer'),
(10, 'Jane Doe', 'SE', 'Mechanical');

-- Inserting 10 records into ACCESSIONTABLE
-- Represents specific physical copies of the books
-- Includes multiple copies of bid = 100 to test the View in Query B
INSERT INTO ACCESSIONTABLE1 (accession_no, bid, avail) VALUES
(1001, 100, 'F'), -- Database Concepts (Copy 1)
(1002, 100, 'T'), -- Database Concepts (Copy 2)
(1003, 100, 'T'), -- Database Concepts (Copy 3)
(1004, 101, 'F'), -- Operating Systems
(1005, 102, 'T'), -- Computer Networks
(1006, 103, 'F'), -- Data Structures
(1007, 104, 'F'), -- Software Engineering
(1008, 105, 'T'), -- Digital Logic
(1009, 106, 'F'), -- Machine Learning
(1010, 107, 'F'); -- Artificial Intelligence

-- Inserting 10 records into ISSUETABLE
-- Including specific issue dates to test the BETWEEN clause in Query A
INSERT INTO ISSUETABLE1 (issueid, accession_no, stud_enrollno, issuedate, duedate, ret_date, bid) VALUES
(1, 1001, 1, '2023-09-01', '2023-09-15', '2023-09-14', 100), 
(2, 1004, 2, '2023-09-05', '2023-09-19', '2023-09-20', 101), 
(3, 1006, 3, '2023-09-10', '2023-09-24', '2023-09-25', 103), 
(4, 1007, 4, '2023-09-15', '2023-09-29', '2023-09-28', 104), -- Target for Query A
(5, 1009, 6, '2023-09-18', '2023-10-02', '2023-10-01', 106), -- Target for Query A
(6, 1010, 7, '2023-09-20', '2023-10-04', '2023-10-05', 107), -- Target for Query A
(7, 1001, 9, '2023-09-25', '2023-10-09', '2023-10-10', 100), 
(8, 1004, 10, '2023-10-01', '2023-10-15', '2023-10-12', 101), 
(9, 1006, 1, '2023-10-05', '2023-10-19', '2023-10-18', 103), 
(10, 1007, 2, '2023-10-10', '2023-10-24', '2023-10-24', 104);

-- a) Find the detail information of the students who have issued books Between two given dates.
SELECT DISTINCT s.*
FROM STUDENTMASTER1 s
JOIN ISSUETABLE1 i ON s.stud_enrollno = i.stud_enrollno
WHERE i.issuedate BETWEEN '2023-09-12' AND '2023-09-22';

-- b) Create a view that display all the accession information for a book having bid = 100
CREATE VIEW View_Accession_Bid_1001 AS
SELECT * FROM ACCESSIONTABLE1
WHERE bid = 100;

-- c) Write a cursor to fetch first record from view in (b).
DELIMITER //

CREATE PROCEDURE Fetch_First_Record_From_View11()
BEGIN
    -- Variables to hold the fetched data
    DECLARE v_accession_no INT;
    DECLARE v_bid INT;
    DECLARE v_avail CHAR(1);
    
    -- Variable to handle if the view is empty
    DECLARE done INT DEFAULT FALSE;
    
    -- Declare the cursor pulling from the View created in Query B
    DECLARE cur CURSOR FOR 
        SELECT accession_no, bid, avail 
        FROM View_Accession_Bid_100
        ORDER BY accession_no ASC; -- Ensuring predictable order
        
    -- Declare handler for when the cursor runs out of rows
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Open the cursor
    OPEN cur;

    -- Fetch the first record into the variables
    FETCH cur INTO v_accession_no, v_bid, v_avail;
    
    -- Display the fetched record (if one exists)
    IF NOT done THEN
        SELECT 
            v_accession_no AS First_Accession_No, 
            v_bid AS Book_ID, 
            v_avail AS Availability;
    ELSE
        SELECT 'No records found' AS Message;
    END IF;

    -- Close the cursor
    CLOSE cur;
END //
DELIMITER ;

-- Execute the procedure to see the result
CALL Fetch_First_Record_From_View11();