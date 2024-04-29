--------------------------------------------------------
--  DDL for Package INV_MATERIAL_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MATERIAL_STATUS_PKG" AUTHID CURRENT_USER as
/* $Header: INVMSPVS.pls 120.1.12010000.3 2008/11/06 01:16:57 musinha ship $ */

Function status_assigned(p_status_id IN NUMBER) return Boolean;

Function get_default_locator_status(
                           p_organization_id     IN NUMBER,
                           p_sub_code            IN VARCHAR2
                           ) return NUMBER;

PROCEDURE  Initialize_status_rec(px_status_rec
                                 IN OUT NOCOPY INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type );

Procedure Insert_status_history(
       p_status_rec  IN INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type );

--INVCONV kkillams
FUNCTION VALIDATE_MTSTATUS(
p_old_status_id         mtl_material_statuses.status_id%TYPE,
p_new_status_id         mtl_material_statuses.status_id%TYPE ,
p_subinventory_code     mtl_onhand_quantities_detail.subinventory_code%TYPE,
p_locator_id            mtl_onhand_quantities_detail.locator_id%TYPE,
p_organization_id       mtl_secondary_inventories.organization_id%TYPE,
p_inventory_item_id     mtl_onhand_quantities_detail.inventory_item_id%TYPE
)RETURN BOOLEAN;

/* bug 6866429: Overloaded Method */
FUNCTION VALIDATE_MTSTATUS(
p_old_status_id         mtl_material_statuses.status_id%TYPE,
p_new_status_id         mtl_material_statuses.status_id%TYPE ,
p_subinventory_code     mtl_onhand_quantities_detail.subinventory_code%TYPE,
p_locator_id            mtl_onhand_quantities_detail.locator_id%TYPE,
p_organization_id       mtl_secondary_inventories.organization_id%TYPE,
p_inventory_item_id     mtl_onhand_quantities_detail.inventory_item_id%TYPE,
p_lot_number            mtl_onhand_quantities_detail.lot_number%TYPE /* bug 6866429 */
)RETURN BOOLEAN;

/* ER 7530736: Overloaded Method */
FUNCTION validate_mtstatus(
p_old_status_id         mtl_material_statuses.status_id%TYPE,
p_new_status_id         mtl_material_statuses.status_id%TYPE ,
p_subinventory_code     mtl_onhand_quantities_detail.subinventory_code%TYPE,
p_locator_id            mtl_onhand_quantities_detail.locator_id%TYPE,
p_organization_id       mtl_secondary_inventories.organization_id%TYPE,
p_inventory_item_id     mtl_onhand_quantities_detail.inventory_item_id%TYPE,
p_lot_number            mtl_onhand_quantities_detail.lot_number%TYPE, /* bug 6837479 */
p_dummy_param           NUMBER
)RETURN BOOLEAN;

PROCEDURE SET_MS_FLAGS(
 p_status_id                MTL_MATERIAL_STATUSES.STATUS_ID%TYPE
,p_org_id                   MTL_SECONDARY_INVENTORIES.ORGANIZATION_ID%TYPE
,p_inventory_item_id        MTL_LOT_NUMBERS.INVENTORY_ITEM_ID%TYPE DEFAULT NULL
,p_secondary_inventory_name MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE DEFAULT NULL
,p_lot_number               MTL_LOT_NUMBERS.LOT_NUMBER%TYPE DEFAULT NULL
,p_inventory_location_id    MTL_ITEM_LOCATIONS.INVENTORY_LOCATION_ID%TYPE DEFAULT NULL
,p_serial_number            MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE DEFAULT NULL
);

--END INVCONV kkillams

END INV_MATERIAL_STATUS_PKG;

/
