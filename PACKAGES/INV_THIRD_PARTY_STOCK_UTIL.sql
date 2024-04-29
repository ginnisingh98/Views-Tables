--------------------------------------------------------
--  DDL for Package INV_THIRD_PARTY_STOCK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_THIRD_PARTY_STOCK_UTIL" AUTHID CURRENT_USER AS
-- $Header: INVUTPSS.pls 120.1 2005/06/28 12:31:37 pseshadr noship $ --
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVUTPSS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Consignment Utilities Package                                     |
--| HISTORY                                                               |
--|     09/30/2002 pseshadr       Created                                 |
--+========================================================================


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE  : Set_OU_Context           PUBLIC
-- PARAMETERS:
--             p_org_id    Operating Unit
-- COMMENT   : Set the OU context
--========================================================================
PROCEDURE Set_OU_Context
( p_org_id         IN NUMBER
);

--========================================================================
-- FUNCTION  : Get_Org_id                PUBLIC
-- PARAMETERS: p_vendor_site_id          Vendor site
-- COMMENT   : Return the operating unit
--========================================================================
FUNCTION Get_Org_id
( p_vendor_site_id IN NUMBER
)
RETURN NUMBER ;

--========================================================================
-- FUNCTION : Get_Primary_UOM            PUBLIC
-- PARAMETERS: p_inventory_item_id       Item
--             p_organization_id         Inv. organization
-- COMMENT   : This function returns the primary UOM of the item
--========================================================================
FUNCTION Get_Primary_UOM
( p_inventory_item_id   IN NUMBER
, p_organization_id     IN NUMBER
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION  : Get_UOM_Code            PUBLIC
-- PARAMETERS: p_unit_of_measure       UOM
--             p_vendor_name           Vendor
--             p_vendor_site_code      Site
-- COMMENT   : This function returns the UOM code for the item
--========================================================================
FUNCTION Get_UOM_Code
( p_unit_of_measure     IN VARCHAR2
, p_vendor_name         IN VARCHAR2
, p_vendor_site_code    IN VARCHAR2
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION  : Get_Location       PUBLIC
-- PARAMETERS: p_organization_id  Inventory Orgn
-- COMMENT   : This function  returns the Location of the  Inventory Orgn
--========================================================================
FUNCTION Get_Location
( p_organization_id     IN NUMBER
)
RETURN NUMBER;

--========================================================================
-- PROCEDURE  : Get_Vendor_Info       PUBLIC
-- PARAMETERS:
--             p_vendor_site_id  Vendor Site Id
--             x_vendor_name     Vendor Name
--             x_vendor_site_code Vendor Site Code
-- COMMENT   : Returns vendor name and vendor site code
--========================================================================
PROCEDURE Get_Vendor_Info
( p_vendor_site_id      IN NUMBER
, x_vendor_name        OUT NOCOPY VARCHAR2
, x_vendor_site_code   OUT NOCOPY VARCHAR2
);


END INV_THIRD_PARTY_STOCK_UTIL;

 

/
