--------------------------------------------------------
--  DDL for Package OE_DEFAULT_TOLERANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_TOLERANCE" AUTHID CURRENT_USER AS
/* $Header: OEXDCISS.pls 120.0 2005/06/01 00:58:20 appldev noship $ */

--  Start of Comments
--  API name    OE_Default_Tolerance
--  Type        Public
--  Version     Current version = 1.0
--              Initial version = 1.0


--  Check For Holds


FUNCTION Under_Ship_Tol_From_Item
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Under_Ship_Tol_From_Customer
(
    p_database_object_name  IN  VARCHAR2
    ,p_attribute_code       IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Under_Ship_Tol_From_Site
(
    p_database_object_name  IN  VARCHAR2
    ,p_attribute_code       IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Under_Ship_Tol_From_Cust_Item
(
    p_database_object_name  IN  VARCHAR2
    ,p_attribute_code       IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Under_Ship_Tol_From_Site_Item
(
    p_database_object_name  IN  VARCHAR2
    ,p_attribute_code       IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Over_Ship_Tol_From_Item
(
	p_database_object_name	IN	VARCHAR2
	,p_attribute_code		IN	VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Over_Ship_Tol_From_Customer
(
    p_database_object_name  IN  VARCHAR2
    ,p_attribute_code       IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Over_Ship_Tol_From_Site
(
    p_database_object_name  IN  VARCHAR2
    ,p_attribute_code       IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Over_Ship_Tol_From_Cust_Item
(
    p_database_object_name  IN  VARCHAR2
    ,p_attribute_code       IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Over_Ship_Tol_From_Site_Item
(
    p_database_object_name  IN  VARCHAR2
    ,p_attribute_code       IN  VARCHAR2
)
RETURN VARCHAR2;

END OE_Default_Tolerance;


 

/
