CREATE TABLE STUDENT (
    regno VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    major VARCHAR(50),
    bdate DATE
);

CREATE TABLE COURSE (
    course# INT PRIMARY KEY,
    cname VARCHAR(50),
    dept VARCHAR(50)
);

CREATE TABLE ENROLL (
    regno VARCHAR(20),
    course# INT,
    sem INT,
    marks INT,
    PRIMARY KEY (regno, course#),
    FOREIGN KEY (regno) REFERENCES STUDENT(regno) ON DELETE CASCADE,
    FOREIGN KEY (course#) REFERENCES COURSE(course#) ON DELETE CASCADE
);

CREATE TABLE TEXT (
    book-ISBN INT PRIMARY KEY,
    book-title VARCHAR(100),
    publisher VARCHAR(50),
    author VARCHAR(50)
);

CREATE TABLE BOOK_ADOPTION (
    course# INT,
    sem INT,
    book-ISBN INT,
    PRIMARY KEY (course#, book-ISBN),
    FOREIGN KEY (course#) REFERENCES COURSE(course#) ON DELETE CASCADE,
    FOREIGN KEY (book-ISBN) REFERENCES TEXT(book-ISBN) ON DELETE CASCADE
);


INSERT INTO STUDENT VALUES
('S101', 'Alice', 'CS', '2000-05-10'),
('S102', 'Bob', 'CS', '2001-06-15'),
('S103', 'Charlie', 'IT', '1999-07-20'),
('S104', 'David', 'ECE', '2002-03-30'),
('S105', 'Eve', 'CS', '2001-09-25');

INSERT INTO COURSE VALUES
(101, 'DBMS', 'CS'),
(102, 'Data Structures', 'CS'),
(103, 'Operating Systems', 'IT'),
(104, 'Microprocessors', 'ECE'),
(105, 'Computer Networks', 'CS');

INSERT INTO ENROLL VALUES
('S101', 101, 1, 85),
('S102', 101, 1, 90),
('S103', 103, 2, 78),
('S104', 104, 3, 88),
('S105', 105, 2, 92);

INSERT INTO TEXT VALUES
(1111, 'Database Systems', 'Pearson', 'Elmasri'),
(2222, 'Data Structures and Algorithms', 'McGraw Hill', 'Cormen'),
(3333, 'Operating Systems Concepts', 'Wiley', 'Silberschatz'),
(4444, 'Microprocessor Design', 'Pearson', 'John Uffenbeck'),
(5555, 'Computer Networking', 'Addison-Wesley', 'Kurose');

INSERT INTO BOOK_ADOPTION VALUES
(101, 1, 1111),
(102, 2, 2222),
(103, 2, 3333),
(104, 3, 4444),
(105, 2, 5555);


--1. Add a new text book and adopt it for a department.
INSERT INTO TEXT VALUES (6666, 'Artificial Intelligence', 'O’Reilly', 'Russell & Norvig');

INSERT INTO BOOK_ADOPTION VALUES (101, 1, 6666);

--2. List of text books (Course #, Book-ISBN, Book-title) for CS department courses using more than two books.
SELECT BA.course#, BA.book-ISBN, T.book-title
FROM BOOK_ADOPTION BA
JOIN COURSE C ON BA.course# = C.course#
JOIN TEXT T ON BA.book-ISBN = T.book-ISBN
WHERE C.dept = 'CS'
GROUP BY BA.course#
HAVING COUNT(BA.book-ISBN) > 2
ORDER BY T.book-title;

--3. Departments where all adopted books are published by a specific publisher.
SELECT C.dept
FROM COURSE C
JOIN BOOK_ADOPTION BA ON C.course# = BA.course#
JOIN TEXT T ON BA.book-ISBN = T.book-ISBN
GROUP BY C.dept
HAVING COUNT(DISTINCT T.publisher) = 1;

--4. List students who scored maximum marks in 'DBMS' course
SELECT S.regno, S.name, E.marks
FROM STUDENT S
JOIN ENROLL E ON S.regno = E.regno
JOIN COURSE C ON E.course# = C.course#
WHERE C.cname = 'DBMS' AND E.marks = (SELECT MAX(marks) FROM ENROLL WHERE course# = 101);

--5. Create a view to display all courses opted by a student along with marks obtained.
CREATE VIEW StudentCourses AS
SELECT S.regno, S.name, C.course#, C.cname, E.marks
FROM STUDENT S
JOIN ENROLL E ON S.regno = E.regno
JOIN COURSE C ON E.course# = C.course#;

--6. Create a trigger to prevent enrollment if marks prerequisite is less than 40.
DELIMITER //
CREATE TRIGGER Prevent_Low_Marks_Enrollment
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN
    IF NEW.marks < 40 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Enrollment not allowed, marks prerequisite is less than 40';
    END IF;
END;
//
DELIMITER ;
