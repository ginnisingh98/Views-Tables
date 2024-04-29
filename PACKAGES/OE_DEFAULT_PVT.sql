--------------------------------------------------------
--  DDL for Package OE_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVDEFS.pls 120.1 2005/09/20 07:32:49 ksurendr noship $ */


--R12 CC Encryption
--Global variable to store the instrument id for the credit
--card returned by the payments API

g_default_instrument_id NUMBER DEFAULT NULL;
g_default_instr_assignment_id NUMBER DEFAULT NULL;

----------------------------------------------------------------
-- DEFAULTING FUNCTIONS FOR ATTRIBUTES ON ORDER HEADER
----------------------------------------------------------------

FUNCTION Get_Tax_Exempt_Number
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_CC_Expiration_Date
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_CC_Holder_Name
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Credit_Card_Number
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Tax_Exempt_Reason
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Tax_Exemption_Details
         ( p_database_object_name       IN  VARCHAR2
          ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_SOB_Currency_Code
         ( p_database_object_name  IN  VARCHAR2
          ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2;


----------------------------------------------------------------
-- DEFAULTING FUNCTIONS FOR ATTRIBUTES ON ORDER LINE
----------------------------------------------------------------

FUNCTION Get_Tax_Code
         ( p_database_object_name  IN  VARCHAR2
          ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Commitment_From_Agreement
         ( p_database_object_name  IN  VARCHAR2
          ,p_attribute_code   IN  VARCHAR2)
RETURN NUMBER;

FUNCTION Get_Accounting_Rule_Duration
         ( p_database_object_name  IN  VARCHAR2
          ,p_attribute_code   IN  VARCHAR2)
RETURN NUMBER;

-- QUOTING changes
-- Returns ID of the primary location with site use of 'SOLD_TO'
-- for the customer on order header.
-- Used in seeded defaulting rule for 'Customer Location' field
FUNCTION Get_Primary_Customer_Location
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Receipt_Method
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN NUMBER;

-- Bug 3581592
-- Default deliver to via the API instead of Related Record rule as there
-- is a performance issue with oe_ak_sold_to_orgs_v if primary deliver to
-- is fetched via the view.
FUNCTION Get_Primary_Deliver_To
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2;

END OE_Default_Pvt;


 

/
