create table person (
      driver_id VARCHAR(20) PRIMARY KEY,
      name VARCHAR(100),
      address VARCHAR(100)
);

CREATE table car(
      regno VARCHAR(20) PRIMARY KEY,
      model VARCHAR(50),
      year int
);

CREATE TABLE accident(
      report_number int PRIMARY KEY ,
      acc_date date,
      location VARCHAR(255),

);

CREATE TABLE owns (
      driver_id VARCHAR(20),
      regno VARCHAR(20),
      PRIMARY KEY(driver_id , regno),
      FOREIGN KEY(driver_id) REFERENCES person (driver_id) on Delete CASCADE,
      FOREIGN KEY(regno) REFERENCES car(regno) on Delete CASCADE
);

CREATE TABLE participated(
      driver_id VARCHAR(20),
      regno VARCHAR(20),
      report_number int , 
      damage_amt int,
      PRIMARY KEY(driver_id , regno , report_number),
      FOREIGN KEY(driver_id) REFERENCES person(driver_id) on Delete CASCADE,
      FOREIGN KEY(regno) REFERENCES car(regno) on Delete CASCADE,
      FOREIGN KEY(report_number) REFERENCES accident(report_number) on Delete CASCADE
);

INSERT INTO PERSON VALUES
('D001', 'John Doe', '123 Elm St'),
('D002', 'Alice Brown', '456 Pine St'),
('D003', 'Bob Smith', '789 Oak St'),
('D004', 'Charlie Smith', '321 Maple St'),
('D005', 'David Lee', '654 Cedar St');

INSERT INTO CAR VALUES
('KA09MA1234', 'Toyota Corolla', 2019),
('KA09MB5678', 'Honda Civic', 2020),
('KA09MC9876', 'Mazda 3', 2021),
('KA09MD3456', 'Ford Mustang', 2018),
('KA09ME6543', 'Nissan Altima', 2022);

INSERT INTO ACCIDENT VALUES
(101, '2021-05-10', 'Downtown'),
(102, '2021-08-15', 'Highway 25'),
(103, '2020-12-05', 'Market Street'),
(104, '2022-01-20', 'Airport Road'),
(105, '2021-11-10', 'City Center');


INSERT INTO OWNS VALUES
('D001', 'KA09MA1234'),
('D002', 'KA09MB5678'),
('D003', 'KA09MC9876'),
('D004', 'KA09MD3456'),
('D005', 'KA09ME6543');

INSERT INTO PARTICIPATED VALUES
('D001', 'KA09MA1234', 101, 5000),
('D002', 'KA09MB5678', 102, 3000),
('D003', 'KA09MC9876', 103, 7000),
('D004', 'KA09MD3456', 104, 4000),
('D005', 'KA09ME6543', 105, 6000);


-- find the total number  of people  who owned cars that were involved in accidents in 2021.
SELECT COUNT(DISTINCT o.driver_id) as total_owners
from owns o
join participated p on o.driver_id = p.driver_id
join accident a on a.report_number = p.report_number
WHERE year(acc_date)  = 2021;


--2 Find the number of accidents in which cars belonging to "Smith" were involved.
SELECT COUNT(DISTINCT pt.report_number) as accident_count
from participated pt 
join owns o on o.driver_id = pt.driver_id
join person p on p.driver_id = o.driver_id
where p.name like "%smith%";

--3 Add a new accident to the database.
INSERT INTO  accident (report_number , acc_date , location) VALUES (109 , "2024-11-11" , "london")


--4.Delete the Mazda belonging to "Smith".
Delete from car  where regno in (select owns.regno from regno join person on person.driver_id = owns.driver_id where person.name like  "%smith%" and owns.regno in (
      select regno from car where model = "mazda"
))


--5 Update the damage amount for car with license number "KA09MA1234" in the accident.
update participated set damage_amt = 90000
where regno = "KA09MA1234" and regno= 101;

--6 Create a view that shows models and year of cars that were involved in accidents
CREATE VIEW accidentCar as SELECT c.model , c.year from car as c join participated p on p.regno = c.regno;

--7 Create a trigger to prevent a driver from participating in more than 3 accidents in a year.

DELIMITER $$

create trigger prevent_more_than_3_accident
BEFORE INSERT on participated
for each ROW
BEGIN
      DECLARE accident_count int;


      SELECT COUNT(*) into accident_count
      from participated 
      JOIN ACCIDENT ON PARTICIPATED.report_number = ACCIDENT.report_number
      WHERE PARTICIPATED.driver_id = NEW.driver_id AND YEAR(ACCIDENT.acc_date) = YEAR(CURDATE());

    IF accident_count >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver cannot participate in more than 3 accidents in a year.';
    END IF;
END$$

DELIMITER ;