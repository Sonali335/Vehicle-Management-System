SET SERVEROUTPUT ON;

-- Procedure to check if customer exists
CREATE OR REPLACE FUNCTION check_customer_exists(p_cust_id IN NUMBER) RETURN BOOLEAN IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Customer WHERE cust_id = p_cust_id;
    IF v_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
/

-- Procedure to add a new customer
CREATE OR REPLACE PROCEDURE add_new_customer(p_name IN VARCHAR2, p_phone IN VARCHAR2) IS
    v_cust_id NUMBER;
BEGIN
    -- Insert customer into the Customer table
    INSERT INTO Customer (cust_id, name, phone)
    VALUES (CUSTOMER_SEQ.NEXTVAL, p_name, p_phone);

    -- Get the customer ID
    SELECT CUSTOMER_SEQ.CURRVAL INTO v_cust_id FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('New customer added successfully. Customer ID: ' || v_cust_id);
END;
/

-- Procedure to add a new vehicle for a customer
CREATE OR REPLACE PROCEDURE add_new_vehicle(p_cust_id IN NUMBER, p_company IN VARCHAR2, p_plate_no IN VARCHAR2, p_model IN VARCHAR2) IS
BEGIN
    -- Insert the vehicle into the Vehicle table
    INSERT INTO Vehicle (v_id, cust_id, company, plate_no, model)
    VALUES (VEHICLE_SEQ.NEXTVAL, p_cust_id, p_company, p_plate_no, p_model);
    DBMS_OUTPUT.PUT_LINE('New vehicle added successfully for customer ID: ' || p_cust_id);
END;
/

-- Procedure to show existing vehicles for a customer
CREATE OR REPLACE PROCEDURE show_existing_vehicles(p_cust_id IN NUMBER) IS
BEGIN
    FOR rec IN (SELECT v_id, company, plate_no, model FROM Vehicle WHERE cust_id = p_cust_id) LOOP
        DBMS_OUTPUT.PUT_LINE('Vehicle ID: ' || rec.v_id || ' - Company: ' || rec.company || ' - Plate No: ' || rec.plate_no || ' - Model: ' || rec.model);
    END LOOP;
END;
/

-- Procedure to select a service for a vehicle
CREATE OR REPLACE PROCEDURE select_service(p_vehicle_id IN NUMBER) IS
    v_service_choice NUMBER;
    v_service_desc VARCHAR2(50);
    v_price NUMBER;
BEGIN
    -- Ask for service type
    DBMS_OUTPUT.PUT_LINE('Select Service Type:');
    DBMS_OUTPUT.PUT_LINE('1 - Painting');
    DBMS_OUTPUT.PUT_LINE('2 - Washing');
    DBMS_OUTPUT.PUT_LINE('3 - Servicing');
    v_service_choice := &service_choice;

    -- Determine the service description and fetch the price
    CASE v_service_choice
        WHEN 1 THEN
            v_service_desc := 'Painting';
        WHEN 2 THEN
            v_service_desc := 'Washing';
        WHEN 3 THEN
            v_service_desc := 'Servicing';
        ELSE
            v_service_desc := 'Invalid Selection';
    END CASE;

    IF v_service_desc != 'Invalid Selection' THEN
        -- Get the service price from the SERVICE_TYPE table (assumed table exists with prices)
        SELECT price INTO v_price FROM SERVICE_TYPE WHERE description = v_service_desc;

        -- Insert service record
        INSERT INTO Service (serv_id, v_id, description, price)
        VALUES (SERVICE_SEQ.NEXTVAL, p_vehicle_id, v_service_desc, v_price);

        DBMS_OUTPUT.PUT_LINE('Service selected: ' || v_service_desc || ' with price: ' || v_price);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Invalid selection, please restart.');
    END IF;

    COMMIT;
END;
/

-- Main procedure to handle customer, vehicle, and service logic
CREATE OR REPLACE PROCEDURE handle_customer_service IS
    v_cust_id NUMBER;
    v_exists BOOLEAN;
    v_name VARCHAR2(255);
    v_phone VARCHAR2(50);
    v_company VARCHAR2(255);
    v_plate_no VARCHAR2(50);
    v_model VARCHAR2(255);
    v_vehicle_id NUMBER;
    v_choice NUMBER;
BEGIN
    -- Ask for Customer ID
    DBMS_OUTPUT.PUT_LINE('Enter Customer ID:');
    v_cust_id := &cust_id; -- Taking input dynamically

    -- Check if customer exists using the function
    v_exists := check_customer_exists(v_cust_id);

    IF v_exists THEN
        DBMS_OUTPUT.PUT_LINE('Customer exists. Fetching assigned vehicles:');
        -- Show existing vehicles for the customer
        show_existing_vehicles(v_cust_id);

        -- Ask if the customer wants to add a new vehicle
        DBMS_OUTPUT.PUT_LINE('Do you want to add a new vehicle? (1 for Yes, 0 for No)');
        v_choice := &choice;

        IF v_choice = 1 THEN
            -- Take new vehicle details
            DBMS_OUTPUT.PUT_LINE('Enter New Vehicle Details:');
            DBMS_OUTPUT.PUT_LINE('Company:');
            v_company := '&company';
            DBMS_OUTPUT.PUT_LINE('Plate Number:');
            v_plate_no := '&plate_no';
            DBMS_OUTPUT.PUT_LINE('Model:');
            v_model := '&model';

            -- Add new vehicle
            add_new_vehicle(v_cust_id, v_company, v_plate_no, v_model);
        ELSE
            -- Ask for vehicle selection if no new vehicle is added
            DBMS_OUTPUT.PUT_LINE('Enter the Vehicle ID for service:');
            v_vehicle_id := &vehicle_id;

            -- Ask for service selection
            select_service(v_vehicle_id);
        END IF;

    ELSE
        -- Customer does not exist, register new customer
        DBMS_OUTPUT.PUT_LINE('Customer not found. Registering new customer.');
        DBMS_OUTPUT.PUT_LINE('Enter Customer Name:');
        v_name := '&cust_name';
        DBMS_OUTPUT.PUT_LINE('Enter Customer Phone:');
        v_phone := '&cust_phone';

        -- Add new customer
        add_new_customer(v_name, v_phone);

        -- Ask for vehicle details
        DBMS_OUTPUT.PUT_LINE('Enter Vehicle Details:');
        DBMS_OUTPUT.PUT_LINE('Company:');
        v_company := '&company';
        DBMS_OUTPUT.PUT_LINE('Plate Number:');
        v_plate_no := '&plate_no';
        DBMS_OUTPUT.PUT_LINE('Model:');
        v_model := '&model';

        -- Add new vehicle
        add_new_vehicle(v_cust_id, v_company, v_plate_no, v_model);

        -- Ask for service selection
        DBMS_OUTPUT.PUT_LINE('Enter the Vehicle ID for service:');
        v_vehicle_id := &vehicle_id;

        -- Ask for service selection
        select_service(v_vehicle_id);
    END IF;

END;
/
