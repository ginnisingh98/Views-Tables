--------------------------------------------------------
--  DDL for Package EAM_MATERIAL_ALLOCQTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MATERIAL_ALLOCQTY_PKG" AUTHID CURRENT_USER as
/* $Header: EAMMRALS.pls 120.1 2007/11/29 03:23:28 mashah ship $ */


--This function returns allocated quantity by querying from inv. tables
FUNCTION allocated_quantity(p_wip_entity_id IN NUMBER,
                              p_operation_seq_num IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_inventory_item_id IN NUMBER)
 return NUMBER;

--This function returns open quantity.If open qty is less than 0,it returns 0
 FUNCTION open_quantity(p_wip_entity_id IN NUMBER,
                              p_operation_seq_num IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_inventory_item_id IN NUMBER,
			      p_required_quantity IN NUMBER,
			      p_quantity_issued IN NUMBER)
 return NUMBER;

 --This will call the function allocated_quantity to find the quantity allocated
 PROCEDURE quantity_allocated(p_wip_entity_id IN NUMBER,
                              p_operation_seq_num IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_inventory_item_id IN NUMBER,
			      x_quantity_allocated OUT NOCOPY NUMBER);

--This will call Eam_Common_Utilties_Pvt.Get_OnHand_Quant to find the on_hand_qty and available quantity
--for an inventory item
PROCEDURE get_onhand_avail_quant(p_organization_id IN NUMBER,
								p_inventory_item_id IN NUMBER,
                                                                p_subinventory_code IN  VARCHAR2 DEFAULT NULL, --12.1 source sub project
								x_onhand_quant OUT NOCOPY NUMBER,
								x_avail_quant OUT NOCOPY NUMBER);


 END EAM_MATERIAL_ALLOCQTY_PKG;

/
