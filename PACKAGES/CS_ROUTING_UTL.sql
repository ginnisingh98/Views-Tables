--------------------------------------------------------
--  DDL for Package CS_ROUTING_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_ROUTING_UTL" AUTHID CURRENT_USER AS
/* $Header: csurtes.pls 115.3 2000/02/29 19:46:42 pkm ship    $ */

------------------------------------------------------------------------------
--  Type	: emp_tbl_type
--  Usage	: Used by the Service Routing functions to return a group
--		  of employee IDs
--  Description	: This pre-defined table type stores a collection of employee
--		  IDs.
------------------------------------------------------------------------------

TYPE emp_tbl_type IS TABLE OF PER_ALL_PEOPLE_F.PERSON_ID%TYPE
  INDEX BY BINARY_INTEGER;

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
( p_request_number	IN	VARCHAR2
)
RETURN NUMBER;

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
( p_serial_number	IN	VARCHAR2
)
RETURN NUMBER;

------------------------------------------------------------------------------
--  Function	: Get_Customer_From_System_Name
--  Usage	: Used by the Routing module to get the customer ID from the
--		  system name
--  Description: This function retrieves a customer ID from the CS_SYSTEMS_ALL
--		  table given a system in the installed base.
--  Parameters	:
--	p_system_name		IN	VARCHAR2(50)	Required
--
--  Return	: NUMBER
--		  If the given system does not exist, this function returns
--		  NULL.
------------------------------------------------------------------------------

FUNCTION Get_Customer_From_System_Name
( p_system_name		IN	VARCHAR2
)
RETURN NUMBER;

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
( p_request_number	IN	VARCHAR2
)
RETURN NUMBER;

------------------------------------------------------------------------------
--  Function	: Get_CP_From_SerialNum
--  Usage	: Used by the Routing module to get the customer product ID
--		  from the serial number
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
( p_serial_number	IN	VARCHAR2
)
RETURN NUMBER;

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
( p_request_number	IN	VARCHAR2
)
RETURN NUMBER;

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
( p_serial_number	IN	VARCHAR2
)
RETURN NUMBER;

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
( p_request_number	IN	VARCHAR2
)
RETURN NUMBER;

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
( p_incident_number         IN   NUMBER,
  x_emp_tbl                 OUT  emp_tbl_type
)
RETURN NUMBER;



END CS_Routing_UTL;

 

/
