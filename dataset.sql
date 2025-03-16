-- Drop all the tables if already exist
BEGIN
    FOR table_rec IN (SELECT table_name FROM user_tables WHERE table_name IN (
        'PAYMENT', 'TRANSACTION', 'INVOICE', 'SERVICE_PARTS', 'SERVICE_RECORD', 
        'APPOINTMENT', 'VEHICLE', 'SERVICE', 'CUSTOMER', 'INVENTORY_ITEM', 'USER_ACCOUNT'))
    LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || table_rec.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/

-- CUSTOMER Table
CREATE TABLE CUSTOMER (
    Customer_id INT PRIMARY KEY,
    First_name VARCHAR2(50),
    Last_name VARCHAR2(50),
    Email VARCHAR2(100),
    Phone VARCHAR2(20),
    Address CLOB
);

-- VEHICLE Table
CREATE TABLE VEHICLE (
    Vehicle_id INT PRIMARY KEY,
    License_plate VARCHAR2(20),
    Model VARCHAR2(50),
    Make VARCHAR2(50),
    Year INT,
    Customer_id INT,
    FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(Customer_id)
);

-- SERVICE Table
CREATE TABLE SERVICE (
    Service_id INT PRIMARY KEY,
    Service_type VARCHAR2(50),
    Description CLOB,
    Duration INT
);

-- SERVICE_RECORD Table
CREATE TABLE SERVICE_RECORD (
    Service_record_id INT PRIMARY KEY,
    Vehicle_id INT,
    Service_id INT,
    Service_date DATE,
    Mileage INT,
    Service_notes CLOB,
    FOREIGN KEY (Vehicle_id) REFERENCES VEHICLE(Vehicle_id),
    FOREIGN KEY (Service_id) REFERENCES SERVICE(Service_id)
);

-- INVENTORY_ITEM Table
CREATE TABLE INVENTORY_ITEM (
    Inventory_item_id INT PRIMARY KEY,
    Item_name VARCHAR2(100),
    Reorder_level INT
);

-- SERVICE_PARTS Table
CREATE TABLE SERVICE_PARTS (
    Service_part_id INT PRIMARY KEY,
    Service_record_id INT,
    Inventory_item_id INT,
    Quantity_used INT,
    FOREIGN KEY (Service_record_id) REFERENCES SERVICE_RECORD(Service_record_id),
    FOREIGN KEY (Inventory_item_id) REFERENCES INVENTORY_ITEM(Inventory_item_id)
);

-- APPOINTMENT Table
CREATE TABLE APPOINTMENT (
    Appointment_id INT PRIMARY KEY,
    Customer_id INT,
    Vehicle_id INT,
    Service_id INT,
    Appointment_date DATE,
    Status VARCHAR2(50),
    FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(Customer_id),
    FOREIGN KEY (Vehicle_id) REFERENCES VEHICLE(Vehicle_id),
    FOREIGN KEY (Service_id) REFERENCES SERVICE(Service_id)
);

-- INVOICE Table
CREATE TABLE INVOICE (
    Invoice_id INT PRIMARY KEY,
    Appointment_id INT,
    Total_amount NUMBER(10,2),
    Service_date DATE,
    Due_date DATE,
    Status VARCHAR2(50),
    FOREIGN KEY (Appointment_id) REFERENCES APPOINTMENT(Appointment_id)
);

-- TRANSACTION Table
CREATE TABLE TRANSACTION (
    Transaction_id INT PRIMARY KEY,
    Invoice_id INT,
    Inventory_item_id INT,
    Quantity_changed INT,
    Transaction_date DATE,
    Transaction_type VARCHAR2(50),
    FOREIGN KEY (Invoice_id) REFERENCES INVOICE(Invoice_id),
    FOREIGN KEY (Inventory_item_id) REFERENCES INVENTORY_ITEM(Inventory_item_id)
);

-- PAYMENT Table
CREATE TABLE PAYMENT (
    Payment_id INT PRIMARY KEY,
    Payment_date DATE,
    Amount NUMBER(10,2),
    Payment_method VARCHAR2(50),
    Payment_status VARCHAR2(50),
    Invoice_id INT,
    FOREIGN KEY (Invoice_id) REFERENCES INVOICE(Invoice_id)
);

-- USER Table
CREATE TABLE USER_ACCOUNT (
    User_id INT PRIMARY KEY,
    Username VARCHAR2(50),
    Password VARCHAR2(255),
    Role VARCHAR2(50),
    Email VARCHAR2(100)
);

-- Insert sample customers
INSERT INTO CUSTOMER (Customer_id, First_name, Last_name, Email, Phone, Address) 
VALUES (1, 'John', 'Doe', 'john.doe@example.com', '555-1234', '123 Main St, Toronto');

INSERT INTO CUSTOMER (Customer_id, First_name, Last_name, Email, Phone, Address) 
VALUES (2, 'Jane', 'Smith', 'jane.smith@example.com', '555-5678', '456 Elm St, Mississauga');

INSERT INTO CUSTOMER (Customer_id, First_name, Last_name, Email, Phone, Address) 
VALUES (3, 'Michael', 'Brown', 'michael.brown@example.com', '555-8765', '789 Oak St, Brampton');

-- Insert user accounts (Admin & Mechanics)
INSERT INTO USER_ACCOUNT (User_id, Username, Password, Role, Email) 
VALUES (1, 'admin', 'admin@123', 'Admin', 'admin@example.com');

INSERT INTO USER_ACCOUNT (User_id, Username, Password, Role, Email) 
VALUES (2, 'mechanic1', 'mech@123', 'Mechanic', 'mechanic1@example.com');

INSERT INTO USER_ACCOUNT (User_id, Username, Password, Role, Email) 
VALUES (3, 'mechanic2', 'mech@123', 'Mechanic', 'mechanic2@example.com');

-- Insert available services
INSERT INTO SERVICE (Service_id, Service_type, Description, Duration) 
VALUES (1, 'Oil Change', 'Complete oil and filter replacement', 60);

INSERT INTO SERVICE (Service_id, Service_type, Description, Duration) 
VALUES (2, 'Brake Inspection', 'Brake pad and disc check-up', 45);

INSERT INTO SERVICE (Service_id, Service_type, Description, Duration) 
VALUES (3, 'Engine Diagnosis', 'Engine performance check and tuning', 90);

INSERT INTO SERVICE (Service_id, Service_type, Description, Duration) 
VALUES (4, 'Tire Rotation', 'Tire rotation and air pressure check', 30);

INSERT INTO SERVICE (Service_id, Service_type, Description, Duration) 
VALUES (5, 'Battery Replacement', 'Battery check and replacement if needed', 20);

-- Insert inventory items (Spare parts)
INSERT INTO INVENTORY_ITEM (Inventory_item_id, Item_name, Reorder_level) 
VALUES (1, 'Engine Oil', 10);

INSERT INTO INVENTORY_ITEM (Inventory_item_id, Item_name, Reorder_level) 
VALUES (2, 'Brake Pads', 15);

INSERT INTO INVENTORY_ITEM (Inventory_item_id, Item_name, Reorder_level) 
VALUES (3, 'Air Filter', 20);

INSERT INTO INVENTORY_ITEM (Inventory_item_id, Item_name, Reorder_level) 
VALUES (4, 'Car Battery', 5);

INSERT INTO INVENTORY_ITEM (Inventory_item_id, Item_name, Reorder_level) 
VALUES (5, 'Spark Plugs', 25);

INSERT INTO INVENTORY_ITEM (Inventory_item_id, Item_name, Reorder_level) 
VALUES (6, 'Tires', 8);

-- Commit the changes
COMMIT;

