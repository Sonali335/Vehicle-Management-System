-- Drop tables if they already exist
BEGIN
    FOR t IN (
        SELECT table_name
        FROM user_tables
        WHERE table_name IN (
            'CUSTOMER', 'VEHICLE', 'SERVICE', 'SERVICE_RECORD', 'WORKER', 'APPOINTMENT', 
            'SERVICE_INVENTORY', 'INVENTORY_ITEM', 'ADMIN', 'PAYMENT', 'INVOICE', 'AUDIT_LOG', 
            'SUPPLIER', 'USER_ROLE'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/

-- Create User Role Table
CREATE TABLE user_role (
    role_id NUMBER PRIMARY KEY,
    role_name VARCHAR2(100),
    role_description VARCHAR2(255)
);


CREATE TABLE customer (
    customer_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(150),
    phone_number VARCHAR2(20),
    address VARCHAR2(255),
    password_hash VARCHAR2(255) NOT NULL,  
    role_id NUMBER,
    FOREIGN KEY (role_id) REFERENCES user_role(role_id)
);

CREATE TABLE vehicle (
    vehicle_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    make VARCHAR2(50),
    model VARCHAR2(50),
    year NUMBER(4),
    vin_number VARCHAR2(20),
    license_plate VARCHAR2(20),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);


-- Create Service Table
CREATE TABLE service (
    service_id NUMBER PRIMARY KEY,
    service_name VARCHAR2(100) NOT NULL,
    service_description VARCHAR2(255),
    price NUMBER(10, 2),
    duration NUMBER(5)
);


-- Create Worker Table
CREATE TABLE worker (
    worker_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(150),
    phone_number VARCHAR2(20),
    service_id NUMBER, 
    password_hash VARCHAR2(255),
    role_id NUMBER,
    FOREIGN KEY (service_id) REFERENCES service(service_id),
    FOREIGN KEY (role_id) REFERENCES user_role(role_id)
);


-- Create Service Record Table
CREATE TABLE service_record (
    service_record_id NUMBER PRIMARY KEY,
    vehicle_id NUMBER,
    service_id NUMBER,
    worker_id NUMBER,
    service_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    service_status VARCHAR2(50),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id),
    FOREIGN KEY (service_id) REFERENCES service(service_id),
    FOREIGN KEY (worker_id) REFERENCES worker(worker_id)
);

-- Create Appointment Table
CREATE TABLE appointment (
    appointment_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    vehicle_id NUMBER,
    service_id NUMBER,
    appointment_date TIMESTAMP,
    status VARCHAR2(50),
    worker_id NUMBER,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id),
    FOREIGN KEY (service_id) REFERENCES service(service_id),
    FOREIGN KEY (worker_id) REFERENCES worker(worker_id)
);

-- Create Supplier Table
CREATE TABLE supplier (
    supplier_id NUMBER PRIMARY KEY,
    supplier_name VARCHAR2(100),
    contact_person VARCHAR2(100),
    contact_email VARCHAR2(150),
    contact_phone VARCHAR2(20),
    address VARCHAR2(255)
);


CREATE TABLE inventory_item (
    inventory_item_id NUMBER PRIMARY KEY,
    supplier_id NUMBER,
    quantity_in_stock NUMBER,
    minimum_stock_level NUMBER,
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
);

-- Create Service_inventory Table
CREATE TABLE service_inventory (
    service_record_id NUMBER,
    inventory_item_id NUMBER,
    quantity_used NUMBER,
    PRIMARY KEY (service_record_id, inventory_item_id),
    FOREIGN KEY (service_record_id) REFERENCES service_record(service_record_id),
    FOREIGN KEY (inventory_item_id) REFERENCES inventory_item(inventory_item_id)
);


-- Create Admin Table
CREATE TABLE admin (
    admin_id NUMBER PRIMARY KEY,
    username VARCHAR2(100) NOT NULL,
    password_hash VARCHAR2(255) NOT NULL,
    email VARCHAR2(150),
    phone_number VARCHAR2(20),
    status VARCHAR2(50) DEFAULT 'Active',
    role_id NUMBER,  -- Role of the admin
    FOREIGN KEY (role_id) REFERENCES user_role(role_id)
);

-- Create Payment Table
CREATE TABLE payment (
    payment_id NUMBER PRIMARY KEY,
    appointment_id NUMBER,
    amount_paid NUMBER(10, 2),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR2(50),
    status VARCHAR2(50),
    FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id)
);

-- Create Invoice Table
CREATE TABLE invoice (
    invoice_id NUMBER PRIMARY KEY,
    payment_id NUMBER,
    invoice_number VARCHAR2(50) NOT NULL,
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMBER(10, 2),
    status VARCHAR2(50),
    FOREIGN KEY (payment_id) REFERENCES payment(payment_id)
);

-- Create Audit Log Table
CREATE TABLE audit_log (
    log_id NUMBER PRIMARY KEY,
    action_type VARCHAR2(50),
    action_details VARCHAR2(255),
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR2(50),
    user_type VARCHAR2(20) CHECK (user_type IN ('Customer', 'Worker', 'Admin')),
    role_id NUMBER
    
);


CREATE SEQUENCE customer_seq START WITH 1 INCREMENT BY 1;
-- Sequence for Worker IDs
CREATE SEQUENCE worker_seq START WITH 1 INCREMENT BY 1;
-- Sequence for Admin IDs
CREATE SEQUENCE admin_seq START WITH 1 INCREMENT BY 1;
-- Sequence for Audit_log_id
CREATE SEQUENCE audit_log_seq START WITH 1 INCREMENT BY 1;
-- Sequence for vehicle id
CREATE SEQUENCE vehicle_seq START WITH 1 INCREMENT BY 1;

-- Sequence for payemnet_id
CREATE SEQUENCE seq_payment START WITH 1 INCREMENT BY 1;

--Create sequence for invoice_id
CREATE SEQUENCE seq_invoice START WITH 1 INCREMENT BY 1;

--Create sequence for appointment_id
CREATE SEQUENCE appointment_seq START WITH 1 INCREMENT BY 1;

--Create sequence for service_record_id_id
CREATE SEQUENCE service_record_seq START WITH 1 INCREMENT BY 1;

--Create sequence for service__id
CREATE SEQUENCE service_id_seq START WITH 4 INCREMENT BY 1;



--Insertion
-- Insert into User Role
INSERT INTO user_role (role_id, role_name, role_description) VALUES (1, 'Customer', 'General customer role');
INSERT INTO user_role (role_id, role_name, role_description) VALUES (2, 'Worker', 'Service worker role');
INSERT INTO user_role (role_id, role_name, role_description) VALUES (3, 'Admin', 'Administrator role');

-- add admin
INSERT INTO admin (admin_id, username, password_hash, email, phone_number, status, role_id)
VALUES (1, 'admin_1', 'admin_1', 'admin@example.com', '555-123-4567', 'Active', 3);

-- Insert into Customer
INSERT INTO customer (customer_id, first_name, last_name, email, phone_number, address, role_id, password_hash) 
VALUES (1, 'John', 'Doe', 'johndoe@email.com', '123-456-7890', '123 Main St', 1, 'pass1');
INSERT INTO customer (customer_id, first_name, last_name, email, phone_number, address, role_id, password_hash) 
VALUES (2, 'Jane', 'Smith', 'janesmith@email.com', '987-654-3210', '456 Oak St', 1, 'pass2');

-- Insert into Vehicle
INSERT INTO vehicle (vehicle_id, customer_id, make, model, year, vin_number, license_plate) 
VALUES (1, 1, 'Toyota', 'Camry', 2020, 'VIN123456789', 'ABC123');
INSERT INTO vehicle (vehicle_id, customer_id, make, model, year, vin_number, license_plate) 
VALUES (2, 2, 'Honda', 'Civic', 2019, 'VIN987654321', 'XYZ789');

-- Insert into Service
INSERT INTO service (service_id, service_name, service_description, price, duration) 
VALUES (1, 'Painter', 'Paint the vehicle', 50.00, 30);
INSERT INTO service (service_id, service_name, service_description, price, duration) 
VALUES (2, 'Mechanic', 'Servicing', 60.00, 45);
INSERT INTO service (service_id, service_name, service_description, price, duration) 
VALUES (3, 'Cleaner', 'Deep Cleaning', 40.00, 45);
INSERT INTO service (service_id, service_name, service_description, price, duration)
VALUES (service_id_seq.NEXTVAL, 'Oil Change', 'Change the oil of your vehicle', 50.00, 30);
INSERT INTO service (service_id, service_name, service_description, price, duration)
VALUES (service_id_seq.NEXTVAL, 'Tire Replacement', 'Replace old tires with new ones', 100.00, 60);

-- Insert into Worker
INSERT INTO worker (worker_id, first_name, last_name, email, phone_number, service_id, password_hash, role_id) 
VALUES (1, 'Mike', 'Johnson', 'mikej@email.com', '111-222-3333', 1, 'work_1', 2);
INSERT INTO worker (worker_id, first_name, last_name, email, phone_number, service_id, password_hash, role_id) 
VALUES (2, 'Sarah', 'Connor', 'sarahc@email.com', '444-555-6666', 2, 'work_2', 2);
INSERT INTO worker (worker_id, first_name, last_name, email, phone_number, service_id, password_hash, role_id) 
VALUES (3, 'Annie', 'Mill', 'anniem@email.com', '888-555-1111', 3, 'work_3', 2);

-- Insert into Supplier
INSERT INTO supplier (supplier_id, supplier_name, contact_person, contact_email, contact_phone, address) 
VALUES (1, 'AutoParts Ltd.', 'Tom Benson', 'tom@autoparts.com', '555-123-4567', '789 Industrial Rd');
INSERT INTO supplier (supplier_id, supplier_name, contact_person, contact_email, contact_phone, address) 
VALUES (2, 'QuickFix Supplies', 'Emma Davis', 'emma@quickfix.com', '555-987-6543', '321 Mechanic Ave');
INSERT INTO supplier (supplier_id, supplier_name, contact_person, contact_email, contact_phone, address)
VALUES (101, 'Auto Parts Co.', 'John Doe', 'john.doe@autoparts.com', '555-1234', '123 Auto St, City');
INSERT INTO supplier (supplier_id, supplier_name, contact_person, contact_email, contact_phone, address)
VALUES (102, 'Car Fixers Inc.', 'Jane Smith', 'jane.smith@carfixers.com', '555-5678', '456 Fix Rd, City');
INSERT INTO supplier (supplier_id, supplier_name, contact_person, contact_email, contact_phone, address)
VALUES (103, 'Spare Parts Ltd.', 'Robert Brown', 'robert.brown@spareparts.com', '555-8765', '789 Spare Ave, City');

-- Insert into Inventory Item
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level) 
VALUES (1, 1, 50, 10);  -- Oil filters
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level) 
VALUES (2, 1, 30, 5);  -- Brake pads
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level) 
VALUES (3, 2, 40, 8);  -- Engine oil
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level) 
VALUES (4, 2, 25, 6);  -- Air filters
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
VALUES (inventory_item_seq.NEXTVAL, 101, 50, 10); -- Supplier ID 1
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
VALUES (inventory_item_seq.NEXTVAL, 102, 30, 5);  -- Supplier ID 2
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
VALUES (inventory_item_seq.NEXTVAL, 103, 100, 20); -- Supplier ID 3
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
VALUES (inventory_item_seq.NEXTVAL, 101, 5, 2); -- Low stock item
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
VALUES (inventory_item_seq.NEXTVAL, 102, 75, 15); -- Supplier ID 4
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
VALUES (inventory_item_seq.NEXTVAL, 103, 40, 8);
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
VALUES (inventory_item_seq.NEXTVAL, 103, 90, 30);
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
VALUES (inventory_item_seq.NEXTVAL,103, 20, 5);
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
VALUES (inventory_item_seq.NEXTVAL, 101, 10, 3);
INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
VALUES (inventory_item_seq.NEXTVAL, 102, 200, 50);

-- Insert into Service Record (This must be done before service_inventory)
INSERT INTO service_record (service_record_id, vehicle_id, service_id, worker_id, service_date, service_status) 
VALUES (1, 1, 1, 1, CURRENT_TIMESTAMP, 'Completed');

INSERT INTO service_record (service_record_id, vehicle_id, service_id, worker_id, service_date, service_status) 
VALUES (2, 2, 2, 2, CURRENT_TIMESTAMP, 'Completed');

-- Now insert into Service Inventory (Linking inventory items to service records)
INSERT INTO service_inventory (service_record_id, inventory_item_id, quantity_used) 
VALUES (1, 1, 2);  -- Oil filters used in service record 1

INSERT INTO service_inventory (service_record_id, inventory_item_id, quantity_used) 
VALUES (1, 3, 3);  -- Engine oil used in service record 1

INSERT INTO service_inventory (service_record_id, inventory_item_id, quantity_used) 
VALUES (2, 2, 1);  -- Brake pads used in service record 2

INSERT INTO service_inventory (service_record_id, inventory_item_id, quantity_used) 
VALUES (2, 4, 1);  -- Air filter used in service record 2



COMMIT;
