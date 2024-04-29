--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: INVUINTS.pls 120.4 2006/06/14 00:11:59 yawang noship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVUINTS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_MGD_MVT_UTILS_PKG                                      |
--|                                                                       |
--| Mvt_Stats_Util_Info                                                   |
--| Calc_Unit_Weight                                                      |
--| Calc_Total_weight                                                     |
--| Get_Alternate_UOM                                                     |
--| Convert_alternate_Quantity                                            |
--| Convert_Territory_Code                                                |
--| Get_Commodity_Info                                                    |
--| Get_Category_Id                                                       |
--| Get_Site_Location                                                     |
--| Get_Org_Location                                                      |
--| Get_Vendor_Info                                                       |
--| Get_Cust_VAT_Number                                                   |
--| Get_Org_VAT_Number                                                    |
--| Get_Zone_Code                                                         |
--| Get_Subinv_Location                                                   |
--| Get_SO_Legal_Entity                                                   |
--| Get_Shipping_Legal_Entity                                             |
--| Get_LE_Currency                                                       |
--| Get_LE_Location                                                       |
--| Get_Weight_Precision                                                  |
--| Get_org_from_le                                                       |
--| HISTORY                                                               |
--|     04/11/2000 pseshadr        Created                                |
--|     05/26/2005 yawang        Added Get_LE_Currency for R12            |
--|                              Added Get_LE_Location for R12            |
--+======================================================================*/


--g_OPM_static_data INV_MGD_MVT_DATA_STR.array_OPM_stat_typ_transaction;

--===================
-- CONSTANTS
--===================

G_LOG_ERROR                   CONSTANT NUMBER := 5;
G_LOG_EXCEPTION               CONSTANT NUMBER := 4;
G_LOG_EVENT                   CONSTANT NUMBER := 3;
G_LOG_PROCEDURE               CONSTANT NUMBER := 2;
G_LOG_STATEMENT               CONSTANT NUMBER := 1;

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Mvt_Stats_Util_Info  PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              message text
--             p_stat_typ_transaction  IN  Stat type Usages record
--             x_movement_transaction  IN OUT  Movement Statistics Record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Utility procedure that calculates invoice info,
--             weight info, this procedure inturns calls the
--             functions and procedures described above.
--=========================================================================
PROCEDURE Mvt_Stats_Util_Info
( p_stat_typ_transaction IN
   INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- FUNCTION  : Get_Rate_Two_Uom Public
-- PARAMETERS:
--             p_item_id     Inventory Item
--             p_uom1        UOM1
--             p_uom2        UOM2
-- COMMENT   : Returns the conversion rate between the two passing in uoms
--=======================================================================
FUNCTION Get_Rate_Two_Uom
( p_item_id    NUMBER
, p_uom1       VARCHAR2
, p_uom2       VARCHAR2
)
RETURN NUMBER;

--========================================================================
-- FUNCTION : Calc_Unit_Weight PUBLIC
-- PARAMETERS:
--             p_inventory_item_id     Inventory Item
--             p_organization_id       Organization_id
--             p_stat_typ_uom_code     UOM defined in stat type usages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Returns the unit weight of an item
--
-- History   : yawang 23-APR-2002      add new parameter p_tranx_uom_code
--=======================================================================

FUNCTION Calc_Unit_Weight
( p_inventory_item_id	     NUMBER
, p_organization_id	     NUMBER
, p_stat_typ_uom_code        VARCHAR2
, p_tranx_uom_code           VARCHAR2
)
RETURN NUMBER;


/*
--========================================================================
-- FUNCTION : Calc_Total_weight PUBLIC
-- PARAMETERS:
--             p_inventory_item_id     Inventory Item
--             p_organization_id       Organization_id
--             p_weight_uom_code       UOM
--             p_weight_precision      rounding decimal digits
--             p_transaction_quantity  Quantity
--             p_transaction_uom_code  Transaction UOM
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Total weight in the UOM that is defined in
--             the set-up form in mtl stat type usages.
--             The weight is defined in the UOm that is defined
--             by the authorities for reporting.
--=======================================================================

FUNCTION Calc_Total_weight
( p_inventory_item_id	     NUMBER
, p_organization_id	     NUMBER
, p_weight_uom_code	     VARCHAR2
, p_weight_precision	     NUMBER
, p_transaction_quantity     NUMBER
, p_transaction_uom_code     VARCHAR2
, p_unit_weight              NUMBER
)
RETURN NUMBER;
*/

--========================================================================
-- FUNCTION : Get_Alternate_UOM PUBLIC
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================

FUNCTION Get_Alternate_UOM
( p_category_set_id    	   NUMBER
, p_alt_uom_rule_set_code  VARCHAR2
, p_commodity_code         VARCHAR2
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION : Convert_Alternate_Quantity PUBLIC
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================

FUNCTION Convert_alternate_Quantity
( p_transaction_quantity   NUMBER
, p_alternate_uom_code     VARCHAR2
, p_inventory_item_id	   NUMBER
, p_transaction_uom_code   VARCHAR2
)
RETURN NUMBER;

--========================================================================
-- FUNCTION : Convert_Territory_Code PUBLIC
-- PARAMETERS:
--             l_iso_code              varchar2
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Calculates and returns the ISO code given the territory code
--=======================================================================

FUNCTION Convert_Territory_Code (l_iso_code VARCHAR2)
RETURN VARCHAR2;


--========================================================================
-- PROCEDURE : Get_Commodity_Info  PUBLIC
-- PARAMETERS: x_movement_transaction  IN OUT  Movement Statistics Record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Procedure to populate the commoddity information for the item
--=======================================================================--

PROCEDURE Get_Commodity_Info
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
);

--========================================================================
-- PROCEDURE : Get_Order_Number  PUBLIC
-- PARAMETERS: p_movement_transaction  IN  Movement Statistics Record
--             x_movement_transaction  OUT Movement Statistics Record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Procedure to populate the Order Number
--=======================================================================--

PROCEDURE Get_Order_Number
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
);

--========================================================================
-- FUNCTION : Get_Category_Id  PUBLIC
-- PARAMETERS: p_movement_transaction  IN  Movement Statistics Record
--             p_stat_typ_transaction  IN  Stat type Usages record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Function that returns the category id for an item
--=======================================================================--

FUNCTION Get_Category_Id
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_stat_typ_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
)
RETURN NUMBER;

--========================================================================
-- FUNCTION : Get_Site_Location        PUBLIC
-- PARAMETERS: p_site_use_id           Site id
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Function that returns the territory code where the site
--             is located.
--=======================================================================--

FUNCTION Get_Site_Location
( p_site_use_id  IN NUMBER
)
RETURN VARCHAR2;


--========================================================================
-- FUNCTION : Get_Org_Location         PUBLIC
-- PARAMETERS: p_warehouse_id          warehouse id
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Function that returns the territory code where the warehouse
--             is located.
--=======================================================================--

FUNCTION Get_Org_Location
( p_warehouse_id  IN NUMBER
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION : Get_Vendor_Location      PUBLIC
-- PARAMETERS: p_vendor_site_id        Vendor Site
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Function that returns the territory code where the vendor site
--             is located.
--=======================================================================--

FUNCTION Get_vendor_Location
( p_vendor_site_id  IN NUMBER
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION : Get_Zone_Code            PUBLIC
-- PARAMETERS: p_territory_code        territory code
--             p_zone_code             zone code
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Function that returns the zone code if the zone code
--             and territory code matches and entry in country assignments
--=======================================================================--

FUNCTION Get_Zone_Code
( p_territory_code IN VARCHAR2
, p_zone_code      IN VARCHAR2
, p_trans_date     IN VARCHAR2
)
RETURN VARCHAR2;


--========================================================================
-- PROCEDURE : Get_Vendor_Info  PUBLIC
-- PARAMETERS: x_movement_transaction  IN OUT  Movement Statistics Record
--
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Procedure to populate the  vendor info
--=========================================================================

PROCEDURE Get_Vendor_Info
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
);

--========================================================================
-- FUNCTION : Get_Cust_VAT_Number
-- PARAMETERS: p_site_use_id      IN  NUMBER site use id
--========================================================================
FUNCTION Get_Cust_VAT_Number
( p_site_use_id  NUMBER)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION : Get_Org_VAT_Number
-- PARAMETERS: p_entity_org_id      IN  NUMBER legal entity id
--========================================================================
FUNCTION Get_Org_VAT_Number
( p_entity_org_id IN NUMBER
, p_date          IN DATE)
RETURN VARCHAR2;

--========================================================================
-- PROCEDURE : Log_Initialize             PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize;

--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
);

--========================================================================
-- FUNCTION : Get_Subinv_Location      PUBLIC
-- PARAMETERS: p_warehouse_id          warehouse id
--             p_subinv_code           subinventory code
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Function that returns the territory code where the subinventory
--             is located.
--=======================================================================--

FUNCTION Get_Subinv_Location
( p_warehouse_id  IN NUMBER
, p_subinv_code   IN VARCHAR2
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION  : Get_SO_Legal_Entity      PUBLIC
-- PARAMETERS: p_order_line_id          order line id
--
-- VERSION   : current version          1.0
--             initial version          1.0
-- COMMENT   : Function that returns the legal entity where this sales order
--             is created.
--=======================================================================--

FUNCTION Get_SO_Legal_Entity
( p_order_line_id  IN NUMBER
)
RETURN NUMBER;

--========================================================================
-- FUNCTION  : Get_Shipping_Legal_Entity  PUBLIC
-- PARAMETERS: p_warehouse_id             warehouse id
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns the legal entity where this sales order
--             is ship released.
--=======================================================================--

FUNCTION Get_Shipping_Legal_Entity
( p_warehouse_id  IN NUMBER
)
RETURN NUMBER;

--========================================================================
-- FUNCTION  : Get_LE_Currency  PUBLIC
-- PARAMETERS: p_le_id          legal entity id
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns the functional currency of a given
--             legal entity.
--=======================================================================--

FUNCTION Get_LE_Currency
( p_le_id  IN NUMBER
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION  : Get_LE_Location     PUBLIC
-- PARAMETERS: p_le_id             legal entity id
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns the country location of a given
--             legal entity.
--=======================================================================--

FUNCTION Get_LE_Location
( p_le_id  IN NUMBER
)
RETURN VARCHAR2;

--========================================================================
-- PROCEDURE  : Get_Weight_Precision       PUBLIC
-- PARAMETERS: p_legal_entity_id       IN   legal entity  id
--             p_zone_code             IN   zone code
--             p_usage_type            IN   usage type
--             p_stat_type             IN   stat type
--             x_weight_precision      OUT  weight precision
--             x_rep_rounding          OUT  reporting rounding method
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns the weight precision defined on
--             parameter form
--=======================================================================--

PROCEDURE Get_Weight_Precision
( p_legal_entity_id  IN NUMBER
, p_zone_code        IN VARCHAR2
, p_usage_type       IN VARCHAR2
, p_stat_type        IN VARCHAR2
, x_weight_precision OUT NOCOPY NUMBER
, x_rep_rounding     OUT NOCOPY VARCHAR2
)
;


--========================================================================
-- FUNCTION  : Round_Number  PUBLIC
-- PARAMETERS: p_number                   number to be rounded
--             p_precision                the precision to be rounded to
--             p_rounding_method          rounding method
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns a rounded number
--=======================================================================--
FUNCTION Round_Number
( p_number          IN NUMBER
, p_precision       IN NUMBER
, p_rounding_method IN VARCHAR2
)
RETURN NUMBER;

--========================================================================
-- FUNCTION  : Get_Org_From_Le            PUBLIC
-- PARAMETERS: p_le_id                    legal entity id
--
-- VERSION   : current version            1.0
--             initial version            1.0
-- COMMENT   : Function that returns a rounded number
--=======================================================================--
FUNCTION Get_Org_From_Le
( p_le_id          IN NUMBER
)
RETURN NUMBER;


END INV_MGD_MVT_UTILS_PKG;

 

/
