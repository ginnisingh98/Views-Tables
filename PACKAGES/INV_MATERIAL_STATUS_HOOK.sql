--------------------------------------------------------
--  DDL for Package INV_MATERIAL_STATUS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MATERIAL_STATUS_HOOK" AUTHID CURRENT_USER AS
/* $Header: INVMSHKS.pls 120.0.12010000.2 2009/04/27 22:50:14 musinha noship $ */
   PROCEDURE validate_rsv_matstatus (p_old_status_id         IN mtl_material_statuses.status_id%TYPE,
                                     p_new_status_id         IN mtl_material_statuses.status_id%TYPE ,
                                     p_subinventory_code     IN mtl_onhand_quantities_detail.subinventory_code%TYPE,
                                     p_locator_id            IN mtl_onhand_quantities_detail.locator_id%TYPE,
                                     p_organization_id       IN mtl_secondary_inventories.organization_id%TYPE,
                                     p_inventory_item_id     IN mtl_onhand_quantities_detail.inventory_item_id%TYPE,
                                     p_lot_number            IN mtl_onhand_quantities_detail.lot_number%TYPE,
                                     x_ret_status            IN OUT NOCOPY BOOLEAN);

END INV_MATERIAL_STATUS_HOOK;

/
