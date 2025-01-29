-- 1. Find the colours of boats reserved by Albert  
SELECT DISTINCT B.color
FROM BOAT B
JOIN RSERVERS R ON B.bid = R.bid
JOIN SAILORS S ON R.sid = S.sid
WHERE S.sname = 'Albert';

-- 2. Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 103  
SELECT DISTINCT S.sid
FROM SAILORS S
LEFT JOIN RSERVERS R ON S.sid = R.sid
WHERE S.rating >= 8 OR R.bid = 103;

-- 3. Find the names of sailors who have not reserved a boat whose name contains the string “storm”.
--    Order the names in ascending order.  
SELECT DISTINCT S.sname
FROM SAILORS S
WHERE S.sid NOT IN (
    SELECT R.sid
    FROM RSERVERS R
    JOIN BOAT B ON R.bid = B.bid
    WHERE B.bname LIKE '%storm%'
)
ORDER BY S.sname ASC;

-- 4. Find the names of sailors who have reserved all boats.
SELECT S.sname
FROM SAILORS S
WHERE NOT EXISTS (
    SELECT B.bid FROM BOAT B
    WHERE NOT EXISTS (
        SELECT R.sid FROM RSERVERS R
        WHERE R.bid = B.bid AND R.sid = S.sid
    )
);

-- 5. Find the name and age of the oldest sailor.
SELECT sname, age
FROM SAILORS
WHERE age = (SELECT MAX(age) FROM SAILORS);

-- 6. For each boat which was reserved by at least 5 sailors with age >= 40, 
--    find the boat id and the average age of such sailors.
SELECT R.bid, AVG(S.age) AS avg_age
FROM RSERVERS R
JOIN SAILORS S ON R.sid = S.sid
WHERE S.age >= 40
GROUP BY R.bid
HAVING COUNT(DISTINCT R.sid) >= 5;

-- 7. Create a view that shows the names and colours of all the boats that have been reserved 
--    by a sailor with a specific rating.
CREATE VIEW Boats_By_Rating AS
SELECT DISTINCT B.bname, B.color
FROM BOAT B
JOIN RSERVERS R ON B.bid = R.bid
JOIN SAILORS S ON R.sid = S.sid
WHERE S.rating = 8;  -- Change the rating as needed

-- 8. A trigger that prevents boats from being deleted if they have active reservations.
DELIMITER //
CREATE TRIGGER Prevent_Boat_Deletion
BEFORE DELETE ON BOAT
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM RSERVERS WHERE bid = OLD.bid) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete boat with active reservations';
    END IF;
END;
//
DELIMITER ;
