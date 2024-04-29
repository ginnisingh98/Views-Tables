--------------------------------------------------------
--  DDL for Package Body INV_SELECT_INVENTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SELECT_INVENTORY_PKG" AS
/* $Header: INVPCKLB.pls 120.2.12010000.2 2009/09/23 18:32:28 kbavadek ship $ */

  /*##############################################################
  # NAME
  #	get_source_info
  # SYNOPSIS
  #	proc   get_source_info
  # DESCRIPTION
  #      This procedure is used to get the source info from diff tables
  #      based on the source type id.For now we added only for
  #      sales orders.
  ###############################################################*/

  PROCEDURE get_source_info (V_source_type_id IN NUMBER,V_source_line_id IN NUMBER,V_source_id IN NUMBER,
                             X_header_no OUT NOCOPY VARCHAR2, X_line_no OUT NOCOPY NUMBER,
                             X_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_order IS
      SELECT a.line_number, b.order_number
      FROM   oe_order_lines_all a, oe_order_headers_all b
      WHERE  a.header_id = b.header_id
             AND a.line_id = V_source_line_id;

    CURSOR Cur_get_wip_entity IS
      SELECT entity_type
      FROM   wip_entities
      WHERE  wip_entity_id = V_source_id;
    X_wip_entity_type	NUMBER;

    CURSOR Cur_get_batch IS
      SELECT a.batch_no, b.line_no
      FROM   gme_batch_header a, gme_material_details b
      WHERE  a.batch_id = b.batch_id
             AND b.material_detail_id = V_source_line_id;
  BEGIN
    X_return_status := FND_API.G_RET_STS_SUCCESS;
    --Getting the source number from order header Getting the source line number from order lines
    IF (V_source_type_id = INV_GLOBALS.G_SOURCETYPE_SALESORDER) THEN
      OPEN Cur_get_order;
      FETCH Cur_get_order INTO X_line_no, X_header_no;
      CLOSE Cur_get_order;
    ELSIF (V_source_type_id = 8) THEN
      OPEN Cur_get_order;
      FETCH Cur_get_order INTO X_line_no, X_header_no;
      CLOSE Cur_get_order;
    END IF;

    --Getting the source number from batch header Getting the source line number from batch lines
    IF (V_source_type_id = INV_GLOBALS.G_SOURCETYPE_WIP) THEN
      OPEN Cur_get_wip_entity;
      FETCH Cur_get_wip_entity INTO X_wip_entity_type;
      CLOSE Cur_get_wip_entity;
      IF (X_wip_entity_type = 10) THEN
        OPEN Cur_get_batch;
        FETCH Cur_get_batch INTO X_header_no, X_line_no;
        CLOSE Cur_get_batch;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('INV_SELECT_INVENTORY_PKG', 'get_source_info');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END get_source_info;

  /*##############################################################
  # NAME
  #	get_details
  # SYNOPSIS
  #	proc   get_details
  # DESCRIPTION
  #      This procedure is used to insert the data from mmtt table
  #      when select available inventory button is pressed.
  ###############################################################*/

  PROCEDURE get_details (V_move_order_line_id IN NUMBER, X_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    X_return_status := FND_API.G_RET_STS_SUCCESS;
    INSERT INTO mtl_available_inventory_temp
               (transaction_temp_id,source_line_id,move_order_line_id,organization_id,inventory_item_id,
                transaction_source_type_id,transaction_action_id,lot_number,subinventory_code,lot_created,
                lot_expiration_date,grade_code,locator_id,onhand_qty,secondary_onhand_qty,reason_id,
                transaction_qty,secondary_transaction_qty,transaction_uom,secondary_uom,revision,order_by)

   	  SELECT trans.transaction_temp_id,trans.source_line_id,trans.move_order_line_id,
		 trans.organization_id,trans.inventory_item_id,
   	  	 trans.transaction_source_type_id,trans.transaction_action_id,
	         lots.lot_number,trans.subinventory_code,mln.creation_date,
   		 mln.expiration_date,lots.grade_code,trans.locator_id,
 	         0 onhand_quantity,0 secondary_onhand_qty,lots.reason_id,
        	 decode(lots.transaction_quantity,null,trans.transaction_quantity,lots.transaction_quantity),
		 decode(lots.secondary_quantity,null,trans.secondary_transaction_quantity,lots.secondary_quantity),
	         trans.transaction_uom,trans.secondary_uom_code,trans.revision,1
	  FROM   mtl_material_transactions_temp trans, mtl_transaction_lots_temp lots, mtl_lot_numbers mln
	  WHERE  trans.move_order_line_id = V_move_order_line_id
	         AND trans.organization_id  = mln.organization_id (+)
        	 AND trans.inventory_item_id  = mln.inventory_item_id (+)
	         AND trans.transaction_temp_id  = lots.transaction_temp_id (+)
                 AND decode(lots.lot_number,null,'-99999',lots.lot_number) = decode(mln.lot_number,null,'-99999',mln.lot_number);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('INV_SELECT_INVENTORY_PKG', 'get_details');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END get_details;

  /*##############################################################
  # NAME
  #	get_available_inventory
  # SYNOPSIS
  #	proc   get_available_inventory
  # DESCRIPTION
  #      This procedure is used to get the data from wms rules engine
  #      and insert the same into temp table
  ###############################################################*/

  PROCEDURE get_available_inventory (p_mo_line_id            IN NUMBER
   				   , x_return_status         OUT NOCOPY VARCHAR2
   				   , x_msg_count             OUT NOCOPY NUMBER
   				   , x_msg_data              OUT NOCOPY VARCHAR2) IS

  l_reservations        inv_reservation_global.mtl_reservation_tbl_type;
  l_return_status       VARCHAR2(50);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(250);
  l_found               NUMBER  ; -- Fix for Bu#8910862

  BEGIN
      gmi_reservation_util.println('PROCEDURE get availabe inventory');
      wms_engine_pvt.create_suggestions
         ( p_api_version         => 1.0
          ,x_return_status       => l_return_status
          ,x_msg_count           => l_msg_count
          ,x_msg_data            => l_msg_data
          ,p_transaction_temp_id => p_mo_line_id
          ,p_reservations        => l_reservations
          ,p_simulation_mode     => 10
          );

      gmi_reservation_util.println('Get Avail: rows back '
                    ||WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl.COUNT);
      gmi_reservation_util.println('Get Avail: inserting the data into the temp');
      --FOR ALL i IN 1..WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl.COUNT

      FOR i IN 1..WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl.COUNT
      LOOP
        -- Fix for Bug#8910862.Check if suggestion already exists
       BEGIN

          select 1
          into   l_found
          from   mtl_available_inventory_temp
          where (revision = WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).revision or
                           WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).revision is null )
          and   (lot_number = WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).lot_number or
                            WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).lot_number is null)
          and   (subinventory_code = WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).subinventory_code or
                           WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).subinventory_code is null )
          and   (locator_id = WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).locator_id or
                           WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).locator_id is null )
          and   (lpn_id = WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).lpn_id or
                           WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).lpn_id is null )
          and   (serial_number = WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).serial_number or
                           WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).serial_number is null )
          and   (grade_code = WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).grade_code or
                          WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).grade_code is null) ;

          gmi_reservation_util.println(' Suggestion already exists') ;

        EXCEPTION

          WHEN NO_DATA_FOUND THEN
            gmi_reservation_util.println(' New Suggestion ') ;
            gmi_reservation_util.println('fetch the rows, 2nd qty '
                    ||WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).secondary_onhand_qty);
            gmi_reservation_util.println('fetch the rows, grade_code '
                    ||WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).grade_code);

           INSERT INTO mtl_available_inventory_temp
           (  revision
             , lot_number
             , lot_expiration_date
             , subinventory_code
             , locator_id
             , cost_group_id
             , transaction_uom
             , lpn_id
             , serial_number
             , onhand_qty
             , secondary_onhand_qty
             , grade_code
             , consist_string
             , order_by_string
             )
        	Values
             (
              WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).revision
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).lot_number
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).lot_expiration_date
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).subinventory_code
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).locator_id
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).cost_group_id
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).transaction_uom
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).lpn_id
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).serial_number
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).onhand_qty
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).secondary_onhand_qty
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).grade_code
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).consist_string
              ,WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl(i).order_by_string
            );

          WHEN OTHERS THEN NULL ;

          END ;
      END LOOP;
      --commit;

  END get_available_inventory;



END INV_SELECT_INVENTORY_PKG;

/
