CREATE TABLE Customer (
    cust INT PRIMARY KEY,
    cname VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE Orders (
    Order INT PRIMARY KEY,
    odate DATE,
    cust INT,
    order_amt INT,
    FOREIGN KEY (cust) REFERENCES Customer(cust) ON DELETE CASCADE
);

CREATE TABLE Item (
    Item# INT PRIMARY KEY,
    unitprice INT
);

CREATE TABLE Order_item (
    Order# INT,
    Item# INT,
    qty INT,
    PRIMARY KEY (Order#, Item#),
    FOREIGN KEY (Order#) REFERENCES `Order`(Order#) ON DELETE CASCADE,
    FOREIGN KEY (Item#) REFERENCES Item(Item#)
);

CREATE TABLE Warehouse (
    Warehouse# INT PRIMARY KEY,
    city VARCHAR(50)
);

CREATE TABLE Shipment (
    Order# INT,
    Warehouse# INT,
    ship_date DATE,
    PRIMARY KEY (Order#, Warehouse#),
    FOREIGN KEY (Order#) REFERENCES `Order`(Order#) ON DELETE CASCADE,
    FOREIGN KEY (Warehouse#) REFERENCES Warehouse(Warehouse#)
);

INSERT INTO Customer VALUES
(1, 'Kumar', 'Delhi'),
(2, 'Raj', 'Mumbai'),
(3, 'Amit', 'Kolkata'),
(4, 'Neha', 'Chennai'),
(5, 'Pooja', 'Bangalore');

INSERT INTO Orders VALUES
(101, '2024-01-01', 1, 5000),
(102, '2024-01-05', 2, 7000),
(103, '2024-02-10', 3, 4500),
(104, '2024-03-15', 4, 8000),
(105, '2024-04-20', 5, 6000);

INSERT INTO Item VALUES
(1, 100),
(2, 200),
(3, 150),
(4, 300),
(5, 250);

INSERT INTO Order_item VALUES
(101, 1, 10),
(102, 2, 5),
(103, 3, 7),
(104, 4, 8),
(105, 5, 4);

INSERT INTO Warehouse VALUES
(1, 'Delhi'),
(2, 'Mumbai'),
(3, 'Kolkata'),
(4, 'Chennai'),
(5, 'Bangalore');

INSERT INTO Shipment VALUES
(101, 1, '2024-01-02'),
(102, 2, '2024-01-06'),
(103, 3, '2024-02-11'),
(104, 4, '2024-03-16'),
(105, 5, '2024-04-21');

--1. List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
SELECT Order#, ship_date
FROM Shipment
WHERE Warehouse# = 2;

--2. List the Warehouse information from which the Customer named "Kumar" was supplied his orders.
SELECT DISTINCT S.Warehouse#, W.city
FROM Shipment S
JOIN `Order` O ON S.Order# = O.Order#
JOIN Customer C ON O.Cust# = C.Cust#
JOIN Warehouse W ON S.Warehouse# = W.Warehouse#
WHERE C.cname = 'Kumar';

--3. Produce a listing: Cname, #ofOrders, Avg_Order_Amt.
SELECT C.cname, COUNT(O.Order#) AS total_orders, AVG(O.order_amt) AS avg_order_amt
FROM Customer C
LEFT JOIN `Order` O ON C.Cust# = O.Cust#
GROUP BY C.cname;

--4. Delete all orders for customer named "Kumar".
Delete from orders where cust = (select cust from customer wehre cname = "kumar") 


--5. Find the item with the maximum unit price.
SELECT Item#, unitprice
FROM Item
WHERE unitprice = (SELECT MAX(unitprice) FROM Item);

--6. A trigger that updates order_amt based on quantity and unit price of order_item.
DELIMITER //
CREATE TRIGGER Update_Order_Amount
BEFORE INSERT ON Order_item
FOR EACH ROW
BEGIN
    DECLARE total_amount INT;
    
    -- Calculate total order amount
    SELECT SUM(OI.qty * I.unitprice) INTO total_amount
    FROM Order_item OI
    JOIN Item I ON OI.Item# = I.Item#
    WHERE OI.Order# = NEW.Order#;

    -- Update order amount
    UPDATE `Order`
    SET order_amt = total_amount
    WHERE Order# = NEW.Order#;
END;
//
DELIMITER ;


--7. Create a view to display orderID and shipment date of all orders shipped from a warehouse 5.
CREATE VIEW OrderShipmentView AS
SELECT Order#, ship_date
FROM Shipment
WHERE Warehouse# = 5;
