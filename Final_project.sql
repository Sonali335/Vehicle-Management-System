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
-- Create Customer Table
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
-- Create Vehicle Table
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










--views
-- check the popularity of service
CREATE OR REPLACE VIEW vw_service_popularity AS
SELECT 
    s.service_id,
    s.service_name,
    COUNT(a.appointment_id) AS times_booked
FROM service s
LEFT JOIN appointment a ON s.service_id = a.service_id
GROUP BY s.service_id, s.service_name
ORDER BY times_booked DESC;
select * from vw_service_popularity;
-- worker scheduled
CREATE OR REPLACE VIEW vw_worker_schedule AS
SELECT 
    w.worker_id,
    w.first_name || ' ' || w.last_name AS worker_name,
    a.appointment_id,
    TO_CHAR(a.appointment_date, 'YYYY-MM-DD') AS appointment_date,
    a.status AS appointment_status
FROM worker w
JOIN appointment a ON w.worker_id = a.worker_id;
select * from vw_worker_schedule;
-- customer appointments
CREATE OR REPLACE VIEW vw_customer_appointments AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    a.appointment_id,
    v.vehicle_id,
    s.service_name,
    TO_CHAR(a.appointment_date, 'YYYY-MM-DD') AS appointment_date,
    a.status
FROM customer c
JOIN appointment a ON c.customer_id = a.customer_id
JOIN vehicle v ON a.vehicle_id = v.vehicle_id
JOIN service s ON a.service_id = s.service_id;
select * from vw_customer_appointments;
-- inventory status
CREATE OR REPLACE VIEW inventory_stock_status AS
SELECT 
    inventory_item_id,
    supplier_id,
    quantity_in_stock,
    minimum_stock_level,
    CASE 
        WHEN quantity_in_stock < minimum_stock_level THEN 'LOW'
        ELSE 'SUFFICIENT'
    END AS stock_status
FROM inventory_item;
select * from inventory_stock_status;










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

--Insert into service_inventory
INSERT INTO service_inventory (service_record_id, inventory_item_id, quantity_used) 
VALUES (1, 1, 2); 
INSERT INTO service_inventory (service_record_id, inventory_item_id, quantity_used) 
VALUES (1, 3, 3);  
INSERT INTO service_inventory (service_record_id, inventory_item_id, quantity_used) 
VALUES (2, 2, 1);  
INSERT INTO service_inventory (service_record_id, inventory_item_id, quantity_used) 
VALUES (2, 4, 1);  
COMMIT;







-- Sequence for Customer IDs
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
-- Sequence for Supplier IDs
CREATE SEQUENCE supplier_seq START WITH 1 INCREMENT BY 1;
-- Sequence for Inventory Item IDs
CREATE SEQUENCE inventory_item_seq START WITH 1 INCREMENT BY 1;
--Sequence used to generate the log_id
CREATE SEQUENCE audit_log_seq START WITH 1 INCREMENT BY 1 NOCACHE;







--user management
--1. registration of new user
CREATE OR REPLACE PROCEDURE register_new_user(
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_address IN VARCHAR2,
    p_password_hash IN VARCHAR2,
    p_status IN VARCHAR2 DEFAULT 'Active', -- Admins have a status field
    p_role_id IN NUMBER, -- Role of the user (Admin, Customer, Worker)
    p_username IN VARCHAR2 DEFAULT NULL, -- Only for Admin
    p_service_id IN NUMBER DEFAULT NULL -- Only for Worker
) AS
    v_new_user_id NUMBER;
BEGIN
    IF p_role_id = 2 THEN
        -- Register as a customer
        INSERT INTO customer (customer_id, first_name, last_name, email, phone_number, address, role_id, password_hash)
        VALUES (customer_seq.NEXTVAL, p_first_name, p_last_name, p_email, p_phone_number, p_address, p_role_id, p_password_hash);        
        v_new_user_id := customer_seq.CURRVAL;
    ELSIF p_role_id = 1 THEN
        -- Register as an admin
        INSERT INTO admin (admin_id, username, password_hash, email, phone_number, status, role_id)
        VALUES (admin_seq.NEXTVAL, p_username, p_password_hash, p_email, p_phone_number, p_status, p_role_id);
        v_new_user_id := admin_seq.CURRVAL;
    ELSIF p_role_id = 3 THEN
        -- Register as a worker
        INSERT INTO worker (worker_id, first_name, last_name, email, phone_number, password_hash, service_id, role_id)
        VALUES (worker_seq.NEXTVAL, p_first_name, p_last_name, p_email, p_phone_number, p_password_hash, p_service_id, p_role_id);
        v_new_user_id := worker_seq.CURRVAL;
    END IF;
    -- Log the registration action into the audit log
    INSERT INTO audit_log (log_id, action_type, action_details, action_date, status, user_type, role_id)
    VALUES (audit_log_seq.NEXTVAL, 'Registration', 'User registered: ' || p_email, CURRENT_TIMESTAMP, 'Active', 
            CASE 
                WHEN p_role_id = 1 THEN 'Admin'
                WHEN p_role_id = 2 THEN 'Customer'
                WHEN p_role_id = 3 THEN 'Worker'
            END, p_role_id);

    COMMIT;
END;
/

--2. For login
CREATE OR REPLACE PROCEDURE login_a_user (
    p_email IN VARCHAR2,
    p_password_hash IN VARCHAR2
) AS
    v_role_id NUMBER;
BEGIN
    -- Customer Login Check
    BEGIN
        SELECT role_id INTO v_role_id
        FROM customer
        WHERE email = p_email AND password_hash = p_password_hash;

        INSERT INTO audit_log (log_id, action_type, action_details, action_date, status, user_type, role_id)
        VALUES (audit_log_seq.NEXTVAL, 'Login', 'Customer logged in: ' || p_email, CURRENT_TIMESTAMP, 'Success', 'Customer', v_role_id);
        COMMIT;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

    -- Admin Login Check
    BEGIN
        SELECT role_id INTO v_role_id
        FROM admin
        WHERE email = p_email AND password_hash = p_password_hash;

        INSERT INTO audit_log (log_id, action_type, action_details, action_date, status, user_type, role_id)
        VALUES (audit_log_seq.NEXTVAL, 'Login', 'Admin logged in: ' || p_email, CURRENT_TIMESTAMP, 'Success', 'Admin', v_role_id);
        COMMIT;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

    -- Worker Login Check
    BEGIN
        SELECT role_id INTO v_role_id
        FROM worker
        WHERE email = p_email AND password_hash = p_password_hash;

        INSERT INTO audit_log (log_id, action_type, action_details, action_date, status, user_type, role_id)
        VALUES (audit_log_seq.NEXTVAL, 'Login', 'Worker logged in: ' || p_email, CURRENT_TIMESTAMP, 'Success', 'Worker', v_role_id);
        COMMIT;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

    -- If no user matched, log failed attempt
    INSERT INTO audit_log (log_id, action_type, action_details, action_date, status, user_type, role_id)
    VALUES (audit_log_seq.NEXTVAL, 'Login', 'Failed login attempt for: ' || p_email, CURRENT_TIMESTAMP, 'Failed', 'Customer', NULL);
    COMMIT;
END;


--3. to update user information
CREATE OR REPLACE PROCEDURE update_user_info(
    p_user_id IN NUMBER,
    p_user_type IN VARCHAR2, -- 'Customer', 'Admin', 'Worker'
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone_number IN VARCHAR2,
    p_address IN VARCHAR2
) AS
BEGIN
    IF p_user_type = 'Customer' THEN
        UPDATE customer
        SET first_name = p_first_name, last_name = p_last_name, email = p_email, 
            phone_number = p_phone_number, address = p_address
        WHERE customer_id = p_user_id;
    ELSIF p_user_type = 'Admin' THEN
        UPDATE admin
        SET username = p_first_name || ' ' || p_last_name, email = p_email, 
            phone_number = p_phone_number
        WHERE admin_id = p_user_id;
    ELSIF p_user_type = 'Worker' THEN
        UPDATE worker
        SET first_name = p_first_name, last_name = p_last_name, email = p_email, 
            phone_number = p_phone_number
        WHERE worker_id = p_user_id;
    END IF;

    -- Log the update action
    INSERT INTO audit_log (log_id, action_type, action_details, action_date, status, user_type, role_id)
    VALUES (audit_log_seq.NEXTVAL, 'Update', p_user_type || ' info updated: ' || p_email, CURRENT_TIMESTAMP, 'Active', p_user_type, NULL);
    
    COMMIT;
END;
/


--to delete a user
CREATE OR REPLACE PROCEDURE delete_user_account(
    p_user_id IN NUMBER,
    p_user_type IN VARCHAR2 -- 'Customer', 'Admin', 'Worker'
) AS
BEGIN
    IF p_user_type = 'Customer' THEN
        DELETE FROM customer WHERE customer_id = p_user_id;
    ELSIF p_user_type = 'Admin' THEN
        DELETE FROM admin WHERE admin_id = p_user_id;
    ELSIF p_user_type = 'Worker' THEN
        DELETE FROM worker WHERE worker_id = p_user_id;
    END IF;

    -- Log the delete action
    INSERT INTO audit_log (log_id, action_type, action_details, action_date, status, user_type, role_id)
    VALUES (audit_log_seq.NEXTVAL, 'Delete', p_user_type || ' account deleted: ' || p_user_id, CURRENT_TIMESTAMP, 'Active', p_user_type, NULL);

    COMMIT;
END;
/







--service and appointment managemnet
--1. Book an appointment
CREATE OR REPLACE PROCEDURE book_appointment(
    p_customer_id IN NUMBER,
    p_vehicle_id IN NUMBER,
    p_service_id IN NUMBER,
    p_appointment_date IN TIMESTAMP,
    p_worker_id IN NUMBER
) AS
    v_appointment_exists NUMBER;
    v_worker_available NUMBER;
BEGIN
    -- Check if the customer has a valid vehicle
    SELECT COUNT(*) INTO v_appointment_exists
    FROM vehicle
    WHERE vehicle_id = p_vehicle_id AND customer_id = p_customer_id;

    IF v_appointment_exists = 0 THEN
        -- If no matching vehicle found for the customer
        RAISE_APPLICATION_ERROR(-20001, 'No vehicle found for the customer.');
    END IF;

    -- Check if the worker is already booked at the requested time
    SELECT COUNT(*) INTO v_worker_available
    FROM appointment
    WHERE worker_id = p_worker_id
      AND appointment_date = p_appointment_date
      AND status = 'Scheduled';  -- Only check for appointments with 'Scheduled' status

    IF v_worker_available > 0 THEN
        -- If worker is already booked at the requested time
        RAISE_APPLICATION_ERROR(-20002, 'Worker is not available at the requested time.');
    END IF;

    -- Insert the appointment into the appointment table
    INSERT INTO appointment (
        appointment_id, customer_id, vehicle_id, service_id, 
        appointment_date, status, worker_id
    ) 
    VALUES (
        appointment_seq.NEXTVAL, p_customer_id, p_vehicle_id, p_service_id, 
        p_appointment_date, 'Scheduled', p_worker_id
    );

    -- Log the appointment booking in the audit_log table
    INSERT INTO audit_log (
        log_id, action_type, action_details, action_date, 
        status, user_type, role_id
    )
    VALUES (
        audit_log_seq.NEXTVAL, 'Appointment Booking', 
        'Customer ' || p_customer_id || ' booked an appointment for vehicle ' || p_vehicle_id, 
        CURRENT_TIMESTAMP, 'Success', 'Customer', NULL
    );

    COMMIT;
END;
/




-- 2. Function to get the status of a specific service appointment
CREATE OR REPLACE FUNCTION get_appointment_status(
    p_appointment_id NUMBER
) RETURN VARCHAR2 AS
    v_status VARCHAR2(50);
BEGIN
    -- Retrieve the status of the given appointment
    SELECT status INTO v_status
    FROM appointment
    WHERE appointment_id = p_appointment_id;
    
    RETURN v_status;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Appointment not found';
    WHEN OTHERS THEN
        RETURN 'Error occurred while retrieving status';
END;
/


-- 3. Procedure to mark a service appointment as completed
CREATE OR REPLACE PROCEDURE complete_service_appointment(
    p_appointment_id NUMBER
) AS
BEGIN
    -- Check if the appointment exists and is in 'In Progress' status
    UPDATE appointment
    SET status = 'Completed'
    WHERE appointment_id = p_appointment_id
    AND status = 'Scheduled';
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Service appointment completed successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error completing the appointment: ' || SQLERRM);
END;
/


--Vehicle management
--1. add a new vehicle
CREATE OR REPLACE PROCEDURE add_vehicle (
    p_customer_id NUMBER,
    p_make VARCHAR2,
    p_model VARCHAR2,
    p_year NUMBER,
    p_vin_number VARCHAR2,
    p_license_plate VARCHAR2
) AS
    v_customer_count NUMBER;
    v_vehicle_id NUMBER;
BEGIN
    -- Check if the customer exists
    SELECT COUNT(*) INTO v_customer_count FROM customer WHERE customer_id = p_customer_id;

    IF v_customer_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Customer ID ' || p_customer_id || ' does not exist.');
        RETURN;
    END IF;

    -- Insert the vehicle
    SELECT vehicle_seq.NEXTVAL INTO v_vehicle_id FROM DUAL;

    INSERT INTO vehicle (vehicle_id, customer_id, make, model, year, vin_number, license_plate)
    VALUES (v_vehicle_id, p_customer_id, p_make, p_model, p_year, p_vin_number, p_license_plate);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Vehicle added successfully. Vehicle ID: ' || v_vehicle_id);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/


----2. Audit Log Trigger for  actions on vehicle table
CREATE OR REPLACE TRIGGER trg_audit_vehicle_changes_admin
AFTER INSERT OR UPDATE OR DELETE ON vehicle
FOR EACH ROW
DECLARE
    v_action VARCHAR2(50);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
    ELSIF DELETING THEN
        v_action := 'DELETE';
    END IF;

    INSERT INTO audit_log (
        log_id,
        action_type,
        action_details,
        action_date,
        status,
        user_type,
        role_id
    ) VALUES (
        audit_log_seq.NEXTVAL,
        v_action,
        'Admin ' || v_action || ' on VEHICLE table',
        SYSDATE,
        'Success',
        'Admin',
        1  
    );
END;
/

--3. Trigger to Ensure Vehicle License Plate Uniqueness (per Customer)
CREATE OR REPLACE TRIGGER trg_unique_plate_per_customer
BEFORE INSERT ON vehicle
FOR EACH ROW
DECLARE
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM vehicle
    WHERE license_plate = :NEW.license_plate
      AND customer_id = :NEW.customer_id
      AND vehicle_id != :NEW.vehicle_id;

    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Duplicate license plate for this customer.');
    END IF;
END;
/


--4. Prevent Deletion of Vehicle with Appointments
CREATE OR REPLACE TRIGGER trg_prevent_vehicle_delete_with_appointments
BEFORE DELETE ON vehicle
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM appointment
    WHERE vehicle_id = :OLD.vehicle_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Vehicle has appointments and cannot be deleted.');
    END IF;
END;
/


--5. Get vehicle by customer id
CREATE OR REPLACE FUNCTION get_vehicles_by_customer(
    p_customer_id IN NUMBER
) RETURN SYS_REFCURSOR AS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT * FROM vehicle
        WHERE customer_id = p_customer_id;
    RETURN v_cursor;
END;
/

--INVENTORY MANAGEMENT
--1. Procedure to Add Inventory Items
CREATE OR REPLACE PROCEDURE add_inventory_item(
    p_supplier_id NUMBER,
    p_quantity NUMBER,
    p_min_stock NUMBER
) AS
    v_new_id NUMBER;
BEGIN
    -- Generate new Inventory Item ID
    SELECT inventory_item_seq.NEXTVAL INTO v_new_id FROM dual;

    -- Insert the new inventory item
    INSERT INTO inventory_item (inventory_item_id, supplier_id, quantity_in_stock, minimum_stock_level)
    VALUES (v_new_id, p_supplier_id, p_quantity, p_min_stock);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inventory item added successfully with ID: ' || v_new_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


--2. Procedure to Update Stock Levels
CREATE OR REPLACE PROCEDURE update_stock(
    p_inventory_item_id NUMBER,
    p_new_quantity NUMBER
) AS
BEGIN
    -- Update the inventory quantity
    UPDATE inventory_item
    SET quantity_in_stock = p_new_quantity
    WHERE inventory_item_id = p_inventory_item_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Stock updated successfully for item ID: ' || p_inventory_item_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


-- 3. Trigger for Low Inventory Alerts  
CREATE OR REPLACE TRIGGER trg_low_stock_alert
AFTER UPDATE ON inventory_item
FOR EACH ROW
WHEN (NEW.quantity_in_stock < NEW.minimum_stock_level)
BEGIN
    INSERT INTO audit_log (log_id, action_type, action_details, action_date, status,user_type,role_id)
    VALUES (
        audit_log_seq.NEXTVAL,  
        'LOW_STOCK_ALERT',
        'Inventory Item ID ' || :NEW.inventory_item_id || ' is below minimum stock level!',
         SYSDATE,
        'Active',
        'Customer', 
        NULL 
    );

    DBMS_OUTPUT.PUT_LINE('ALERT: Inventory Item ID ' || :NEW.inventory_item_id || ' is running low on stock!');
END;
/

  
-- 4.  Function to Check Stock Levels  
CREATE OR REPLACE FUNCTION check_stock_level(
    p_inventory_item_id NUMBER
) RETURN NUMBER AS
    v_stock NUMBER;
BEGIN
    SELECT quantity_in_stock INTO v_stock
    FROM inventory_item
    WHERE inventory_item_id = p_inventory_item_id;

    RETURN v_stock;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1; -- Item not found
    WHEN OTHERS THEN
        RETURN -2; -- Error occurred
END;
/
 

--Payment Management
--1. Stored Procedure to Add a New Payment
CREATE OR REPLACE PROCEDURE add_payment (
    p_appointment_id NUMBER,
    p_amount_paid NUMBER,
    p_payment_method VARCHAR2
) AS
    v_payment_id NUMBER;
BEGIN
    -- Insert payment record
    INSERT INTO payment (payment_id, appointment_id, amount_paid, payment_date, payment_method, status)
    VALUES (SEQ_PAYMENT.NEXTVAL, p_appointment_id, p_amount_paid, SYSDATE, p_payment_method, 'Completed')
    RETURNING payment_id INTO v_payment_id;
    DBMS_OUTPUT.PUT_LINE('Payment is done!');
    COMMIT;
END;
/

--2. Function to Get Total Payments for a Customer
CREATE OR REPLACE FUNCTION get_total_payments (p_customer_id NUMBER) RETURN NUMBER IS
    v_total NUMBER := 0;
BEGIN
    SELECT NVL(SUM(p.amount_paid), 0)
    INTO v_total
    FROM payment p
    JOIN appointment a ON p.appointment_id = a.appointment_id
    WHERE a.customer_id = p_customer_id;

    RETURN v_total;
END;
/


--3.Trigger to Automatically Create an Invoice When a Payment is Added
CREATE OR REPLACE TRIGGER trg_create_invoice
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
    INSERT INTO invoice (invoice_id, payment_id, invoice_number, issue_date, total_amount, status)
    VALUES (SEQ_INVOICE.NEXTVAL, :NEW.payment_id, 'INV-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || :NEW.payment_id, SYSDATE, :NEW.amount_paid, 'Unpaid');
    DBMS_OUTPUT.PUT_LINE('Invoice generated successfully');
END;
/

--4.Stored Procedure to Update Payment Status
CREATE OR REPLACE PROCEDURE update_payment_status (
    p_payment_id NUMBER,
    p_new_status VARCHAR2
) AS
BEGIN
    UPDATE payment
    SET status = p_new_status
    WHERE payment_id = p_payment_id;

    COMMIT;
END;
/


--5 .Trigger to Log Payment Status Changes
CREATE OR REPLACE TRIGGER trg_log_payment_update
AFTER UPDATE OF status ON payment
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (log_id, action_type, action_details, action_date, status, user_type, role_id)
    VALUES (AUDIT_LOG_SEQ.NEXTVAL, 'Payment Update',
            'Payment ID ' || :OLD.payment_id || ' changed from ' || :OLD.status || ' to ' || :NEW.status,
            SYSDATE, 'Logged', 'Admin', NULL);
            DBMS_OUTPUT.PUT_LINE('Payment is updated successfully');
END;
/

--6. Stored Procedure to Refund a Payment
CREATE OR REPLACE PROCEDURE refund_payment (
    p_payment_id NUMBER
) AS
BEGIN
    -- Update payment status
    UPDATE payment
    SET status = 'Refunded'
    WHERE payment_id = p_payment_id;

    -- Update invoice status
    UPDATE invoice
    SET status = 'Cancelled'
    WHERE payment_id = p_payment_id;

    COMMIT;
END;
/








