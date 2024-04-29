--------------------------------------------------------
--  DDL for Package Body CS_ROUTING_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_ROUTING_UTL" AS
/* $Header: csurteb.pls 115.4 2000/02/29 19:46:40 pkm ship    $ */


------------------------------------------------------------------------------
--  Function	: Get_Customer_From_RequestNum
--  Usage	: Used by the Routing module to get the customer ID from the
--		  service request number
--  Description	: This function retrieves a customer ID from the
--		  CS_INCIDENTS_ALL table given a service request number.
--  Parameters	:
--	p_request_number	IN	VARCHAR2(64)	Required
--
--  Return	: NUMBER
--		  If there is no customer associated with the given service
--		  request, or the service request does not exist, this
--		  function returns NULL.
------------------------------------------------------------------------------


FUNCTION Get_Customer_From_RequestNum
( p_request_number	IN	VARCHAR2)
RETURN NUMBER IS
    p_customer_id         cs_incidents_all.customer_id%type;

    --
    -- get customer ID given a requesr number
    --
    CURSOR c_customer_id IS
      SELECT customer_id
      FROM   cs_incidents_all
      WHERE  incident_number = p_request_number;
BEGIN

    OPEN c_customer_id;
    FETCH c_customer_id INTO p_customer_id;
    IF c_customer_id%NOTFOUND THEN
       CLOSE c_customer_id;
       RETURN NULL;
    END IF;
    CLOSE c_customer_id;
    RETURN to_number(p_customer_id);
END Get_Customer_From_RequestNum;

------------------------------------------------------------------------------
--  Function	: Get_Customer_From_SerialNum
--  Usage	: Used by the Routing module to get the customer ID from the
--		  serial number
--  Description	: This function retrieves a customer ID from the
--		  CS_CUSTOMER_PRODUCTS_ALL table given a serial number of a
--		  product. If there are more than one customer associated
--		  with the given serial number, this function will return the
--		  first customer ID that it retrieves.
--  Parameters	:
--	p_serial_number		IN	VARCHAR2(30)	Required
--
--  Return	: NUMBER
--		  If the given serial number does not exist, this function
--		  returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_Customer_From_SerialNum
( p_serial_number	IN	VARCHAR2)
RETURN NUMBER IS
    p_customer_id         cs_customer_products_all.customer_id%type;

    --
    -- get customer ID given a serial number
    --
    CURSOR c_customer_id IS
      SELECT customer_id
      FROM   cs_customer_products_all
      WHERE  current_serial_number = p_serial_number;
BEGIN

    OPEN c_customer_id;
    FETCH c_customer_id INTO p_customer_id;
    IF c_customer_id%NOTFOUND THEN
       CLOSE c_customer_id;
       RETURN NULL;
    END IF;
    CLOSE c_customer_id;
    RETURN to_number(p_customer_id);
END Get_Customer_From_SerialNum;

------------------------------------------------------------------------------
--  Function	: Get_Customer_From_System_Name
--  Usage	: Used by the Routing module to get the customer ID from the
--		  system name
--  Description	: This function retrieves a customer ID from the CS_SYSTEMS_ALL_VL
--		  table given a system in the installed base.
--  Parameters	:
--	p_system_name		IN	VARCHAR2(50)	Required
--
--  Return	: NUMBER
--		  If the given system does not exist, this function returns
--		  NULL.
------------------------------------------------------------------------------

FUNCTION Get_Customer_From_System_Name
( p_system_name		IN	VARCHAR2)
RETURN NUMBER IS
    p_customer_id         cs_systems_all_vl.customer_id%type;

    --
    -- get customer ID given a system name
    --
    CURSOR c_customer_id IS
      SELECT customer_id
      FROM   cs_systems_all_vl
      WHERE  name = p_system_name;
BEGIN

    OPEN c_customer_id;
    FETCH c_customer_id INTO p_customer_id;
    IF c_customer_id%NOTFOUND THEN
       CLOSE c_customer_id;
       RETURN NULL;
    END IF;
    CLOSE c_customer_id;
    RETURN to_number(p_customer_id);
END Get_Customer_From_System_Name;

------------------------------------------------------------------------------
--  Function	: Get_CP_From_RequestNum
--  Usage	: Used by the Routing module to get the customer product ID
--		  from the service request number
--  Description	: This function retrieves a customer product ID from the
--		  CS_INCIDENTS_ALL table given a service request number.
--  Parameters	:
--	p_request_number	IN	VARCHAR2(64)	Required
--
--  Return	: NUMBER
--		  If there is no customer product associated with the given
--		  service request, or the service request does not exist,
--		  this function returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_CP_From_RequestNum
( p_request_number	IN	VARCHAR2)
RETURN NUMBER IS

    p_customer_product_id      cs_incidents_all.customer_product_id%type;

    --
    -- get customer product ID given a request number
    --
    CURSOR c_customer_product_id IS
      SELECT customer_product_id
      FROM   cs_incidents_all
      WHERE  incident_number = p_request_number;

BEGIN

    OPEN c_customer_product_id;
    IF c_customer_product_id%NOTFOUND THEN
       CLOSE c_customer_product_id;
       RETURN NULL;
    END IF;
    FETCH c_customer_product_id INTO p_customer_product_id;
    CLOSE c_customer_product_id;
    RETURN to_number(p_customer_product_id);

END Get_CP_From_RequestNum;

------------------------------------------------------------------------------
--  Function	: Get_CP_From_SerialNum
--  Usage	: Used by the Routing module to get the customer product ID
--		  From the serial number
--  Description	: This function retrieves a customer product ID from the
--		  CS_CUSTOMER_PRODUCTS_ALL table given a serial number of a
--		  product. If there are more than one customer product
--		  associated with the given serial number, this function will
--		  return the first customer product ID that it retrieves.
--  Parameters	:
--	p_serial_number		IN	VARCHAR2(30)	Required
--
--  Return	: NUMBER
--		  If the given serial number does not exist, this function
--		  returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_CP_From_SerialNum
( p_serial_number	IN	VARCHAR2)
RETURN NUMBER IS

    p_customer_product_id     cs_customer_products_all.customer_product_id%type;

    --
    -- get customer product ID given a serial number
    --
    CURSOR c_customer_product_id IS
      SELECT customer_product_id
      FROM   cs_customer_products_all
      WHERE  current_serial_number = p_serial_number;
BEGIN

    OPEN c_customer_product_id;
    IF c_customer_product_id%NOTFOUND THEN
       CLOSE c_customer_product_id;
       RETURN NULL;
    END IF;
    FETCH c_customer_product_id INTO p_customer_product_id;
    CLOSE c_customer_product_id;
    RETURN to_number(p_customer_product_id);
END Get_CP_From_SerialNum;

------------------------------------------------------------------------------
--  Function	: Get_Product_From_RequestNum
--  Usage	: Used by the Routing module to get the inventory item ID
--		  from the service request number
--  Description	: This function retrieves an inventory item ID from the
--		  CS_INCIDENTS_ALL table given a service request number.
--  Parameters	:
--	p_request_number	IN	VARCHAR2(64)	Required
--
--  Return	: NUMBER
--		  If there is no inventory item associated with the given
--		  service request, or the service request does not exist,
--		  this function returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_Product_From_RequestNum
( p_request_number	IN	VARCHAR2)
RETURN NUMBER IS
    p_inventory_item_id   cs_incidents_all.inventory_item_id%type;

    --
    -- get inventory item ID given a request number
    --
    CURSOR c_inventory_item_id IS
      SELECT inventory_item_id
      FROM   cs_incidents_all
      WHERE  incident_number = p_request_number;
BEGIN

    OPEN c_inventory_item_id;
    IF c_inventory_item_id%NOTFOUND THEN
       CLOSE c_inventory_item_id;
       RETURN NULL;
    END IF;
    FETCH c_inventory_item_id INTO p_inventory_item_id;
    CLOSE c_inventory_item_id;
    RETURN to_number(p_inventory_item_id);
END Get_Product_From_RequestNum;

------------------------------------------------------------------------------
--  Function	: Get_Product_From_SerialNum
--  Usage	: Used by the Routing module to get the inventory item ID
--		  from the serial number
--  Description	: This function retrieves an inventory item ID from the
--		  CS_CUSTOMER_PRODUCTS_ALL table given a serial number of a
--		  product.
--  Parameters	:
--	p_serial_number		IN	VARCHAR2(30)	Required
--
--  Return	: NUMBER
--		  If the given serial number does not exist, this function
--		  returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_Product_From_SerialNum
( p_serial_number	IN	VARCHAR2)
RETURN NUMBER IS
    p_inventory_item_id   cs_customer_products_all.inventory_item_id%type;

    --
    -- get inventory item ID given a serial number
    --
    CURSOR c_inventory_item_id IS
      SELECT inventory_item_id
      FROM   cs_customer_products_all
      WHERE  current_serial_number = p_serial_number;
BEGIN

    OPEN c_inventory_item_id;
    IF c_inventory_item_id%NOTFOUND THEN
       CLOSE c_inventory_item_id;
       RETURN NULL;
    END IF;
    FETCH c_inventory_item_id INTO p_inventory_item_id;
    CLOSE c_inventory_item_id;
    RETURN to_number(p_inventory_item_id);
END Get_Product_From_SerialNum;

------------------------------------------------------------------------------
--  Function	: Get_Owner_Of_Request
--  Usage	: Used by the Routing module to get the service request owner
--  Description	: This function retrieves the employee ID from the
--		  CS_INCIDENTS_ALL table given a service request number.
--  Parameters	:
--	p_request_number	IN	VARCHAR2(64)	Required
--
--  Return	: NUMBER
--		  If the given service request does not exist, this function
--		  returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_Owner_Of_Request
( p_request_number	IN	VARCHAR2)
RETURN NUMBER IS

    p_employee_id             cs_incidents_all.employee_id%type;

    --
    -- get owner given a request number
    --
    CURSOR c_employee_id IS
      SELECT employee_id
      FROM   cs_incidents_all
      WHERE  incident_number = p_request_number;
BEGIN

    OPEN c_employee_id;
    FETCH c_employee_id INTO p_employee_id;
    IF c_employee_id%NOTFOUND THEN
       CLOSE c_employee_id;
       RETURN NULL;
    END IF;
    RETURN p_employee_id;

END Get_Owner_Of_Request;

------------------------------------------------------------------------------
--  Function    : Get_Employees_From_SR_Type
--  Usage       : Used by the Routing module to get the employee list
--  Description : This function retrieves the employee list from the
--                CS_GROUP_LEVEL_ASSIGNS table given a service request type.
--  Parameters  :
--      p_incident_number   IN   NUMBER         Required
--      x_emp_tbl           OUT  emp_tbl_type
--
--  Return      : NUMBER
--                This function returns the number of employees assigned to
--                the given system type (0 if there is no employee
--                assigned to
--                the customer).
------------------------------------------------------------------------------
FUNCTION Get_Employees_From_SR_Type
( p_incident_number   IN   NUMBER,
  x_emp_tbl           OUT  emp_tbl_type)
RETURN NUMBER IS

    v_total_num_of_emps    NUMBER:=0;
    v_current_id           cs_group_level_assigns.role_person_id%type;
    v_incident_type_id     cs_incidents_all.incident_type_id%type;

    --
    -- get service request type given an incident ID
    --
    CURSOR c_incident_type_id IS
      SELECT incident_type_id
      FROM   cs_incidents_all
      WHERE  incident_number = p_incident_number;

    --
    -- get a list of employees that is responsible to a service request type
    --
    CURSOR c_employees IS
      SELECT DISTINCT cgla.role_person_id
      FROM   cs_group_level_assigns cgla
      WHERE  (cgla.sr_type_id = v_incident_type_id AND
              cgla.role_person_orig_system = 'PER')
      UNION
      SELECT DISTINCT paf.person_id
      FROM cs_group_level_assigns cgla,
           per_assignments_f paf
      WHERE (cgla.sr_type_id = v_incident_type_id AND
            cgla.role_person_orig_system = 'POS' AND
            paf.position_id = cgla.role_person_id);

BEGIN

    OPEN c_incident_type_id;
    FETCH c_incident_type_id INTO v_incident_type_id;
    IF c_incident_type_id%NOTFOUND THEN
       CLOSE c_incident_type_id;
       RETURN v_total_num_of_emps;
    END IF;

    OPEN c_employees;
    LOOP

      FETCH c_employees INTO v_current_id;
      IF c_employees%NOTFOUND THEN
         CLOSE c_employees;
         return v_total_num_of_emps;
      ELSE
         x_emp_tbl(v_total_num_of_emps) := v_current_id;
      END IF;
      v_total_num_of_emps := v_total_num_of_emps + 1;

    END LOOP;

END Get_Employees_From_SR_Type;

END CS_Routing_UTL;


/
