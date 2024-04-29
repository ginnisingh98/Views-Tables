--------------------------------------------------------
--  DDL for Package CSP_VALIDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_VALIDATE_PUB" AUTHID CURRENT_USER AS
/* $Header: cspgtvps.pls 120.2 2008/06/30 10:52:24 htank ship $ */
-- Start of Comments
-- Package name     : CSP_VALIDATE_PUB
-- File name        : cspgtvps.pls
-- Purpose          : The package includes public procedures used for CSP.
-- History          :
--   20-Dev-1999, Included Get_Avail_Qty function
--   10-Dec-1999, Vernon Lou
-- NOTE             :
-- End of Comments

g_qoh  number := null;
g_atr  number := null;

FUNCTION Get_Onhand_Qty RETURN NUMBER;

FUNCTION Get_Available_Qty RETURN NUMBER;

PROCEDURE CHECK_PART_AVAILABLE (
    P_API_VERSION_NUMBER    IN  NUMBER,
    P_INVENTORY_ITEM_ID     IN  NUMBER,
    P_ORGANIZATION_ID       IN  NUMBER,
    P_SUBINVENTORY_CODE     IN  VARCHAR2,
    P_LOCATOR_ID            IN  NUMBER,
    P_REVISION              IN  VARCHAR2,
    P_SERIAL_NUMBER         IN  VARCHAR2,
     P_LOT_NUMBER           IN  VARCHAR2,
    X_AVAILABLE_QUANTITY    OUT NOCOPY NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2
    );


FUNCTION Get_Avail_Qty (
/*  Name: get_avail_qty
    Purpose: Get the available quantity of an item at organization level, subinventory level or locator level.
             For Spares Management, avail_qty = unreserved_qty = total_onhand_qty - reserved_qty
    Author: Vernon Lou
    Date: 2-Nov-99
*/
    p_organization_id   NUMBER,
    p_subinventory_code VARCHAR2,
    p_locator_id        NUMBER,
    p_inventory_item_id NUMBER)

RETURN NUMBER;

FUNCTION Get_Avail_Qty (
/*  Name: get_avail_qty
    Purpose: Get the available quantity of an item at organization level, subinventory level or locator level.
             For Spares Management, avail_qty = unreserved_qty = total_onhand_qty - reserved_qty.
             Also handling revision

    MODIFICATION HISTORY
   -- Person     Date          Comments
   -- ---------  ------        ------------------------------------------
   -- hhaugeru   22-Jun-01     Created

   -- End of comments
    Author: Hans Haugerud
    Date: 22-Jun-01
*/
    p_organization_id   NUMBER,
    p_subinventory_code VARCHAR2,
    p_locator_id        NUMBER,
    p_inventory_item_id NUMBER,
    p_revision          VARCHAR2)

RETURN NUMBER;

-- bug # 7171956
FUNCTION Get_Avail_Qty (
/*  Name: get_avail_qty
    Purpose: Get the available quantity of an item at organization level, subinventory level or locator level.
             For Spares Management, avail_qty = unreserved_qty = total_onhand_qty - reserved_qty.
             Also handling revision
*/
    p_organization_id   NUMBER,
    p_subinventory_code VARCHAR2,
    p_locator_id        NUMBER,
    p_inventory_item_id NUMBER,
    p_revision          VARCHAR2,
    p_lot_num        VARCHAR2)

RETURN NUMBER;
-- end of bug # 7171956

END CSP_VALIDATE_PUB;

/
