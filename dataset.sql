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
    role_id NUMBER, 
    FOREIGN KEY (role_id) REFERENCES user_role(role_id)
);
ALTER TABLE customer
ADD password_hash VARCHAR2(255) NOT NULL;
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
    FOREIGN KEY (service_id) REFERENCES service(service_id)
);
ALTER TABLE worker ADD (
    password_hash VARCHAR2(255), 
    role_id NUMBER
);

ALTER TABLE worker ADD CONSTRAINT fk_worker_role FOREIGN KEY (role_id) REFERENCES user_role(role_id);

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
    user_id NUMBER,
    action_type VARCHAR2(50),
    action_details VARCHAR2(255),
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR2(50),
    FOREIGN KEY (user_id) REFERENCES admin(admin_id)
);
ALTER TABLE audit_log ADD (
    user_type VARCHAR2(20) CHECK (user_type IN ('Customer', 'Worker', 'Admin')), 
    role_id NUMBER
);

ALTER TABLE audit_log ADD CONSTRAINT fk_auditlog_role FOREIGN KEY (role_id) REFERENCES user_role(role_id) ON DELETE CASCADE;





