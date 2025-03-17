
CREATE OR REPLACE PROCEDURE HANDLE_CUSTOMER_SERVICE AS
    v_customer_id CUSTOMER.Customer_id%TYPE;
    v_first_name CUSTOMER.First_name%TYPE;
    v_last_name CUSTOMER.Last_name%TYPE;
    v_email CUSTOMER.Email%TYPE;
    v_phone CUSTOMER.Phone%TYPE;
    v_address CUSTOMER.Address%TYPE;
    
    v_vehicle_id VEHICLE.Vehicle_id%TYPE;
    v_license_plate VEHICLE.License_plate%TYPE;
    v_model VEHICLE.Model%TYPE;
    v_make VEHICLE.Make%TYPE;
    v_year VEHICLE.Year%TYPE;
    
    v_service_id SERVICE.Service_id%TYPE;
    v_service_type SERVICE.Service_type%TYPE;
    
    v_appointment_id APPOINTMENT.Appointment_id%TYPE;
    v_status APPOINTMENT.Status%TYPE := 'Scheduled';

    -- Variables for checking existing records
    v_existing_customer CUSTOMER.Customer_id%TYPE;
    v_existing_vehicle VEHICLE.Vehicle_id%TYPE;
    v_existing_service SERVICE.Service_id%TYPE;
BEGIN
    -- Ask for Customer ID
    DBMS_OUTPUT.PUT_LINE('Enter Customer ID:');
    v_customer_id := &CUSTOMER_ID;

    -- Check if customer exists
    BEGIN
        SELECT Customer_id INTO v_existing_customer FROM CUSTOMER WHERE Customer_id = v_customer_id;
        DBMS_OUTPUT.PUT_LINE('Customer Found: Proceeding...');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Customer not found. Enter new customer details.');
            
            -- Collect new customer details
            DBMS_OUTPUT.PUT_LINE('Enter First Name:');
            v_first_name := '&FIRST_NAME';
            
            DBMS_OUTPUT.PUT_LINE('Enter Last Name:');
            v_last_name := '&LAST_NAME';

            DBMS_OUTPUT.PUT_LINE('Enter Email:');
            v_email := '&EMAIL';

            DBMS_OUTPUT.PUT_LINE('Enter Phone:');
            v_phone := '&PHONE';

            DBMS_OUTPUT.PUT_LINE('Enter Address:');
            v_address := '&ADDRESS';

            -- Assign a new customer ID and insert into table
            SELECT NVL(MAX(Customer_id), 0) + 1 INTO v_customer_id FROM CUSTOMER;
            INSERT INTO CUSTOMER VALUES (v_customer_id, v_first_name, v_last_name, v_email, v_phone, v_address);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('New Customer Added with ID: ' || v_customer_id);
    END;

    -- Ask for Vehicle ID
    DBMS_OUTPUT.PUT_LINE('Enter Vehicle ID:');
    v_vehicle_id := &VEHICLE_ID;

    -- Check if vehicle exists
    BEGIN
        SELECT Vehicle_id INTO v_existing_vehicle FROM VEHICLE WHERE Vehicle_id = v_vehicle_id;
        DBMS_OUTPUT.PUT_LINE('Vehicle Found: Proceeding...');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Vehicle not found. Enter new vehicle details.');

            -- Collect new vehicle details
            DBMS_OUTPUT.PUT_LINE('Enter License Plate:');
            v_license_plate := '&LICENSE_PLATE';

            DBMS_OUTPUT.PUT_LINE('Enter Model:');
            v_model := '&MODEL';

            DBMS_OUTPUT.PUT_LINE('Enter Make:');
            v_make := '&MAKE';

            DBMS_OUTPUT.PUT_LINE('Enter Year:');
            v_year := '&YEAR';

            -- Assign a new vehicle ID and insert into table
            SELECT NVL(MAX(Vehicle_id), 0) + 1 INTO v_vehicle_id FROM VEHICLE;
            INSERT INTO VEHICLE VALUES (v_vehicle_id, v_license_plate, v_model, v_make, v_year, v_customer_id);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('New Vehicle Added with ID: ' || v_vehicle_id);
    END;

    -- Ask for Service Type
    DBMS_OUTPUT.PUT_LINE('Enter Service Type:');
    v_service_type := '&SERVICE_TYPE';

    -- Check if service exists
    BEGIN
        SELECT Service_id INTO v_existing_service FROM SERVICE WHERE Service_type = v_service_type;
        v_service_id := v_existing_service;
        DBMS_OUTPUT.PUT_LINE('Service Found: Proceeding...');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Service not found. Please enter a valid service.');
            RETURN;
    END;

    -- Insert appointment
    SELECT NVL(MAX(Appointment_id), 0) + 1 INTO v_appointment_id FROM APPOINTMENT;
    INSERT INTO APPOINTMENT VALUES (v_appointment_id, v_customer_id, v_vehicle_id, v_service_id, SYSDATE, v_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Appointment Created Successfully with ID: ' || v_appointment_id);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

