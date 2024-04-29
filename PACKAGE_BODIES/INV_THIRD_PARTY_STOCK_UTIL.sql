--------------------------------------------------------
--  DDL for Package Body INV_THIRD_PARTY_STOCK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_THIRD_PARTY_STOCK_UTIL" AS
-- $Header: INVUTPSB.pls 120.4 2008/02/20 18:19:34 athammin ship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVUTPSB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Consignment Utilities Package                                      |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Get_Org_Id                                                        |
--|     Set_OU_Context                                                    |
--|     Get_Primary_UOM                                                   |
--|     Get_UOM_Code                                                      |
--|     Get_Location                                                      |
--|     Get_Vendor_Info                                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     10/01/02 Prabha Seshadri Created                                  |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_THIRD_PARTY_STOCK_UTIL';
g_user_id              NUMBER       := FND_PROFILE.value('USER_ID');
g_appl_id              NUMBER;
g_pgm_appl_id          NUMBER       := FND_PROFILE.value('RESP_APPL_ID');

TYPE ctx_value_rec_type IS RECORD (org_id NUMBER, resp_id NUMBER);
TYPE ctx_tbl_type IS TABLE OF ctx_value_rec_type INDEX BY BINARY_INTEGER;
g_context_tbl          ctx_tbl_type;


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- FUNCTION  : Get_Org_id                PUBLIC
-- PARAMETERS: p_vendor_site_id          Vendor Site
-- COMMENT   : Return the OU  assocociated with the inventory orgn
--========================================================================

FUNCTION Get_Org_id(p_vendor_site_id IN NUMBER)
RETURN NUMBER
IS
  l_org_id NUMBER;
BEGIN
   SELECT
     NVL(org_id,-99)
   INTO
      l_org_id
   FROM
      po_vendor_sites_all
   WHERE vendor_site_id = p_vendor_site_id;

   RETURN l_org_id;

END Get_Org_id;

--========================================================================
-- PROCEDURE  : Set_OU_Context   PUBLIC
-- PARAMETERS : p_org_id          Operating Unit
-- COMMENT    : Set the OU context
--========================================================================

PROCEDURE Set_OU_Context
( p_org_id         IN NUMBER
)
IS
l_debug            NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


BEGIN

  IF (l_debug = 1)
  THEN
    INV_LOG_UTIL.trace
    ( '>> In Set_OU_Context(p_org_id): '||p_org_id
    ,'INV_THIRD_PARTY_STOCK_UTIL' , 9
    );
  END IF;

/*
  MO_GLOBAL.Init('PO');
  MO_GLOBAL.set_policy_context('S',p_org_id);
*/

   DBMS_APPLICATION_INFO.SET_CLIENT_INFO(p_org_id);
   MO_GLOBAL.set_policy_context('S',p_org_id);

EXCEPTION

  WHEN OTHERS THEN
    -- set message on the stack and raise failure
    FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_SET_OU_CXT');
    FND_MSG_PUB.Add;
    RAISE;

END Set_OU_Context;


--========================================================================
-- FUNCTION  : Get_Primary_UOM     PUBLIC
-- PARAMETERS: p_inventory_item_id Item
--             p_organization_id   Inventory Organization
-- COMMENT   : This function  returns the primary UOM of the item
--========================================================================

FUNCTION Get_Primary_UOM
( p_inventory_item_id   IN NUMBER
, p_organization_id     IN NUMBER
)
RETURN VARCHAR2
IS
l_uom VARCHAR2(25);
BEGIN

  SELECT
    primary_unit_of_measure
  INTO
    l_uom
  FROM
    mtl_system_items
  WHERE  inventory_item_id  = p_inventory_item_id
  AND    organization_id    = p_organization_id;

  RETURN l_uom;

END Get_Primary_UOM;

--========================================================================
-- FUNCTION  : Get_UOM_Code       PUBLIC
-- PARAMETERS: p_unit_of_measure  Unit of Measure
--             p_vendor_name      Vendor
--             p_vendor_site_code Site
-- COMMENT   : This function  returns the UOM code for the item
--========================================================================

FUNCTION Get_UOM_Code
( p_unit_of_measure     IN VARCHAR2
, p_vendor_name         IN VARCHAR2
, p_vendor_site_code    IN VARCHAR2
)
RETURN VARCHAR2
IS
l_uom_code VARCHAR2(25);
BEGIN

  SELECT
    uom_code
  INTO
    l_uom_code
  FROM
    mtl_units_of_measure
  WHERE  unit_of_measure  = p_unit_of_measure;

  RETURN l_uom_code;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.Set_Name('INV', 'INV_CONS_SUP_NO_UOM_CODE');
    FND_MESSAGE.Set_Token('SuppName',p_vendor_name);
    FND_MESSAGE.Set_Token('SiteCode',p_vendor_site_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

END Get_UOM_Code;


--========================================================================
-- FUNCTION  : Get_Location      PUBLIC
-- PARAMETERS: p_organization_id Inventory Organization
-- COMMENT   : This procedure will return the Location of the  Inventory Orgn
--========================================================================

FUNCTION Get_Location
( p_organization_id     IN NUMBER
)
RETURN NUMBER
IS
l_location_id  NUMBER;
BEGIN

  SELECT
    location_id
  INTO
    l_location_id
  FROM
    hr_all_organization_units
  WHERE  organization_id = p_organization_id;

  RETURN l_location_id;
EXCEPTION                            -- Bug 6828643 Changes Start
  WHEN NO_DATA_FOUND THEN
      SELECT    haou.location_id
      INTO      l_location_id
      FROM      hr_all_organization_units haou,
		hr_operating_units hou
      WHERE     haou.organization_id = hou.organization_id;

      RETURN l_location_id;          -- Bug 6828643 Changes End
END Get_Location;

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
)
IS
BEGIN

   -- Get the vendor site code and vendor name

  SELECT
    pov.vendor_name
  , povs.vendor_site_code
  INTO
    x_vendor_name
  , x_vendor_site_code
  FROM
    po_vendors pov
  , po_vendor_sites_all povs
  WHERE pov.vendor_id       = povs.vendor_id
    AND povs.vendor_site_id = p_vendor_site_id;


END Get_Vendor_Info;


END INV_THIRD_PARTY_STOCK_UTIL;

/
