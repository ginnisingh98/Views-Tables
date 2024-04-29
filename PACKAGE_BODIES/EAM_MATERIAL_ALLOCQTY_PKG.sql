--------------------------------------------------------
--  DDL for Package Body EAM_MATERIAL_ALLOCQTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MATERIAL_ALLOCQTY_PKG" as
/* $Header: EAMMRALB.pls 120.1.12010000.3 2009/04/10 02:47:42 jvittes ship $ */

--This function returns allocated quantity by querying from inv. tables
FUNCTION allocated_quantity(p_wip_entity_id IN NUMBER,
                              p_operation_seq_num IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_inventory_item_id IN NUMBER)
 return NUMBER
IS
   l_quantity_allocated NUMBER;
   l_line_status  NUMBER;
   l_move_order_type NUMBER;
BEGIN
     l_line_status := INV_GLOBALS.G_TO_STATUS_PREAPPROVED;
     l_move_order_type := 5;

  begin
         select sum(nvl(mtrl.quantity_detailed,0) - nvl(mtrl.quantity_delivered,0))
             into l_quantity_allocated
          from MTL_TXN_REQUEST_LINES mtrl,MTL_TXN_REQUEST_HEADERS mtrh
          where
            mtrl.TXN_SOURCE_ID = p_wip_entity_id and
            mtrl.TXN_SOURCE_LINE_ID = p_operation_seq_num and
            mtrl.organization_id = p_organization_id and
            mtrl.INVENTORY_ITEM_ID = p_inventory_item_id and
            -- preapproved status or open lines
            mtrl.line_status = l_line_status
	    and mtrl.header_id = mtrh.header_id
	    and mtrh.move_order_type=l_move_order_type
          group by mtrl.organization_id, mtrl.TXN_SOURCE_ID,
            mtrl.TXN_SOURCE_LINE_ID, mtrl.INVENTORY_ITEM_ID;
  exception
  when NO_DATA_FOUND then
    l_quantity_allocated := 0;
  end;

  return l_quantity_allocated;
END allocated_quantity;

--This function returns open quantity.If open qty is less than 0,it returns 0
FUNCTION open_quantity(p_wip_entity_id IN NUMBER,
                              p_operation_seq_num IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_inventory_item_id IN NUMBER,
			      p_required_quantity IN NUMBER,
			      p_quantity_issued IN NUMBER)
 return NUMBER
 IS
    l_quantity_allocated NUMBER;
    l_open_quantity NUMBER;
   l_line_status  NUMBER;
   l_move_order_type NUMBER;
 BEGIN

     l_line_status := INV_GLOBALS.G_TO_STATUS_PREAPPROVED;
     l_move_order_type := 5;

	  begin
	     select sum(nvl(mtrl.quantity_detailed,0) - nvl(mtrl.quantity_delivered,0))
		     into l_quantity_allocated
		  from MTL_TXN_REQUEST_LINES mtrl,MTL_TXN_REQUEST_HEADERS mtrh
		  where
		    mtrl.TXN_SOURCE_ID = p_wip_entity_id and
		    mtrl.TXN_SOURCE_LINE_ID = p_operation_seq_num and
		    mtrl.organization_id = p_organization_id and
		    mtrl.INVENTORY_ITEM_ID = p_inventory_item_id and
		    -- preapproved status or open lines
		    mtrl.line_status =l_line_status
		    and mtrl.header_id = mtrh.header_id
		    and mtrh.move_order_type=l_move_order_type
		  group by mtrl.organization_id, mtrl.TXN_SOURCE_ID,
		    mtrl.TXN_SOURCE_LINE_ID, mtrl.INVENTORY_ITEM_ID;
	  exception
	  when NO_DATA_FOUND then
	    l_quantity_allocated := 0;
	  end;

  l_open_quantity := p_required_quantity-NVL(p_quantity_issued,0)-l_quantity_allocated;

  IF(l_open_quantity<0) THEN
      l_open_quantity := 0;
  END IF;

   return l_open_quantity;

 END open_quantity;

  --This will call the function allocated_quantity to find the quantity allocated
 PROCEDURE quantity_allocated(p_wip_entity_id IN NUMBER,
                              p_operation_seq_num IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_inventory_item_id IN NUMBER,
			      x_quantity_allocated OUT NOCOPY NUMBER)
IS
BEGIN

   x_quantity_allocated := allocated_quantity(p_wip_entity_id => p_wip_entity_id,
                                                                                p_operation_Seq_num => p_operation_seq_num,
										p_organization_id => p_organization_id,
										p_inventory_item_id => p_inventory_item_id);

END quantity_allocated;

--This will call Eam_Common_Utilties_Pvt.Get_OnHand_Quant to find the on_hand_qty and available quantity
--for an inventory item
PROCEDURE get_onhand_avail_quant(p_organization_id IN NUMBER,
								p_inventory_item_id IN NUMBER,
                                                                p_subinventory_code IN  VARCHAR2 DEFAULT NULL, --12.1 source sub project
								x_onhand_quant OUT NOCOPY NUMBER,
								x_avail_quant OUT NOCOPY NUMBER)
IS
     CURSOR get_material_details(organization_id NUMBER,inventory_item_id NUMBER) IS
     SELECT
	    mtlbkfv.lot_control_code,
            mtlbkfv.serial_number_control_code,
            mtlbkfv.revision_qty_control_code
       FROM mtl_system_items_b_kfv mtlbkfv
       WHERE mtlbkfv.organization_id = p_organization_id
       AND mtlbkfv.inventory_item_id = p_inventory_item_id;

      l_is_revision_control      BOOLEAN;
     l_is_lot_control           BOOLEAN;
     l_is_serial_control        BOOLEAN;
     l_qoh                      NUMBER;
     l_rqoh                     NUMBER;
     l_qr                       NUMBER;
     l_qs                       NUMBER;
     l_att                      NUMBER;
     l_atr                      NUMBER;
     l_return_status     VARCHAR2(1);
     l_msg_count          NUMBER;
     l_msg_data           VARCHAR2(1000);
     X_QOH_PROFILE_VALUE   NUMBER;      --bug 6263104
 BEGIN                                                   -- for FP reconcilation begin changes for 6263104
      X_QOH_PROFILE_VALUE := TO_NUMBER(FND_PROFILE.VALUE('EAM_REQUIREMENT_QOH_OPTION'));
                     IF (X_QOH_PROFILE_VALUE IS NULL)
                     THEN
                     X_QOH_PROFILE_VALUE := 1;
                     END IF;


			       FOR p_materials_csr IN get_material_details(p_organization_id,p_inventory_item_id)
				LOOP
					IF (p_materials_csr.revision_qty_control_code = 2) THEN
						l_is_revision_control:=TRUE;
					ELSE
						l_is_revision_control:=FALSE;
					END IF;

					IF (p_materials_csr.lot_control_code = 2) THEN
						l_is_lot_control:=TRUE;
					ELSE
						l_is_lot_control:=FALSE;
					END IF;

					IF (p_materials_csr.serial_number_control_code = 1) THEN
						l_is_serial_control:=FALSE;
					ELSE
						l_is_serial_control:=TRUE;
					END IF;

				END LOOP;

                     IF X_QOH_PROFILE_VALUE = 1 THEN       --for FP reconcilation end changes for 6263104
		       BEGIN

                              INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES
													  (  p_api_version_number     => 1.0
													   , p_init_msg_lst           => FND_API.G_TRUE
													   , x_return_status          => l_return_status
													   , x_msg_count             => l_msg_count
													   , x_msg_data              => l_msg_data
													   , p_organization_id     => p_organization_id
													   , p_inventory_item_id   => p_inventory_item_id
													   , p_tree_mode               => 2    --available to transact
													   , p_is_revision_control    => l_is_revision_control
													   , p_is_lot_control           => l_is_lot_control
													   , p_is_serial_control       => l_is_serial_control
													   , p_revision                 => NULL
													   , p_lot_number               => NULL
													   , p_subinventory_code      => p_subinventory_code
													   , p_locator_id               => NULL
													   , p_onhand_source         => inv_quantity_tree_pvt.g_all_subs
													   , x_qoh                      => l_qoh
													   , x_rqoh                    => l_rqoh
													   , x_qr                       => l_qr
													   , x_qs                      => l_qs
													   , x_att                      => l_att
													   , x_atr                     => l_atr
													   );

			IF(l_return_status <> 'S') THEN
					x_avail_quant := 0;
				       x_onhand_quant := 0;
				       RETURN;
			END IF;

	EXCEPTION
	WHEN OTHERS THEN
	       x_avail_quant := 0;
	       x_onhand_quant := 0;
	       RETURN;
	END;

	  ELSE
                                                 -- for reconciliation begin changes for 6263104
                    SELECT NVL(SUM(QUANTITY),0)
                      into l_qoh
                      FROM   MTL_SECONDARY_INVENTORIES MSS,
                             MTL_ITEM_QUANTITIES_VIEW MOQ,
                             MTL_SYSTEM_ITEMS MSI
                     WHERE  MOQ.ORGANIZATION_ID = p_organization_id
                       AND  MSI.ORGANIZATION_ID = p_organization_id
                       AND  MSS.ORGANIZATION_ID = p_organization_id
                       AND  MOQ.INVENTORY_ITEM_ID = p_inventory_item_id
                       AND  MSI.INVENTORY_ITEM_ID = MOQ.INVENTORY_ITEM_ID
                       AND  MSS.SECONDARY_INVENTORY_NAME = MOQ.SUBINVENTORY_CODE
                       AND  MSS.AVAILABILITY_TYPE = 1;


                            INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES
													  (  p_api_version_number     => 1.0
													   , p_init_msg_lst           => FND_API.G_TRUE
													   , x_return_status          => l_return_status
													   , x_msg_count             => l_msg_count
													   , x_msg_data              => l_msg_data
													   , p_organization_id     => p_organization_id
													   , p_inventory_item_id   => p_inventory_item_id
													   , p_tree_mode               => 2    --available to transact
													   , p_is_revision_control    => l_is_revision_control
													   , p_is_lot_control           => l_is_lot_control
													   , p_is_serial_control       => l_is_serial_control
													   , p_revision                 => NULL
													   , p_lot_number               => NULL
													   , p_subinventory_code      => p_subinventory_code
													   , p_locator_id               => NULL
                            										   , p_onhand_source            => inv_quantity_tree_pvt.g_nettable_only
													   , x_qoh                      => l_qoh
													   , x_rqoh                    => l_rqoh
													   , x_qr                       => l_qr
													   , x_qs                      => l_qs
													   , x_att                      => l_att
													   , x_atr                     => l_atr
													   );


                  END IF;
                                                 --for reconciliation end changes for 6263104


        x_avail_quant := l_att;
	x_onhand_quant := l_qoh;

END get_onhand_avail_quant;


 END EAM_MATERIAL_ALLOCQTY_PKG;

/
