--------------------------------------------------------
--  DDL for Package Body WMS_ITEM_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ITEM_LOAD" AS
/* $Header: WMSTKILB.pls 120.13.12010000.2 2008/08/19 09:57:16 anviswan ship $ */


-- Global constant holding the package name
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'WMS_ITEM_LOAD';


PROCEDURE print_debug(p_debug_msg IN VARCHAR2)
  IS
     l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
	(p_err_msg => p_debug_msg,
	 p_module  => 'WMS_ITEM_LOAD',
	 p_level   => 4);
   END IF;

END;


PROCEDURE get_available_qty
  (p_organization_id      IN    NUMBER            ,
   p_lpn_id               IN    NUMBER            ,
   p_inventory_item_id    IN    NUMBER            ,
   p_revision             IN    VARCHAR2          ,
   p_prim_uom_code        IN    VARCHAR2          ,
   p_uom_code             IN    VARCHAR2          ,
   x_return_status        OUT   NOCOPY VARCHAR2   ,
   x_msg_count            OUT   NOCOPY NUMBER     ,
   x_msg_data             OUT   NOCOPY VARCHAR2   ,
   x_available_qty        OUT   NOCOPY NUMBER     ,
   x_total_qty            OUT   NOCOPY NUMBER)--Added for bug 5002690
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'get_available_qty';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     -- Variables used to call validate_operation API
     l_error_code             NUMBER;
     l_inspection_flag        NUMBER;
     l_load_flag              NUMBER;
     l_drop_flag              NUMBER;
     l_load_prim_quantity     NUMBER;
     l_drop_prim_quantity     NUMBER;
     l_inspect_prim_quantity  NUMBER;

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling get_available_qty with the following parameters***');
      print_debug('p_organization_id: ===> ' || p_organization_id);
      print_debug('p_lpn_id: ============> ' || p_lpn_id);
      print_debug('p_inventory_item_id: => ' || p_inventory_item_id);
      print_debug('p_revision: ==========> ' || p_revision);
      print_debug('p_prim_uom_code: =====> ' || p_prim_uom_code);
      print_debug('p_uom_code: ==========> ' || p_uom_code);
   END IF;

   -- Set the savepoint
   SAVEPOINT get_available_qty_sp;
   l_progress  := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize the output variables
   x_return_status := fnd_api.g_ret_sts_success;
   x_available_qty := 0;
   l_progress := '30';

   -- Bug# 3401739
   -- Call the ATF runtime API validate_operation to get the
   -- available quantity of item to load for the given
   -- org/LPN/item/revision.
   IF (l_debug = 1) THEN
      print_debug('Call validate_operation API for the given LPN/item/revision');
   END IF;
   wms_atf_runtime_pub_apis.validate_operation
     (x_return_status          =>  x_return_status,
      x_msg_data               =>  x_msg_data,
      x_msg_count              =>  x_msg_count,
      x_error_code             =>  l_error_code,
      x_inspection_flag        =>  l_inspection_flag,
      x_load_flag              =>  l_load_flag,
      x_drop_flag              =>  l_drop_flag,
      x_load_prim_quantity     =>  l_load_prim_quantity,
      x_drop_prim_quantity     =>  l_drop_prim_quantity,
      x_inspect_prim_quantity  =>  l_inspect_prim_quantity,
      p_source_task_id         =>  NULL,
      p_move_order_line_id     =>  NULL,
      p_inventory_item_id      =>  p_inventory_item_id,
      p_lpn_id                 =>  p_lpn_id,
      p_activity_type_id       =>  WMS_GLOBALS.G_OP_ACTIVITY_INBOUND,
      p_organization_id        =>  p_organization_id,
      p_lot_number             =>  NULL,
      p_revision               =>  p_revision);

   IF (l_debug = 1) THEN
      print_debug('Finished calling the validate_operation API');
   END IF;
   l_progress := '40';

   -- Check to see if the validate_operation API returned successfully
   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('Success returned from validate_operation API');
      END IF;
    ELSE
      IF (l_debug = 1) THEN
	 print_debug('Failure returned from validate_operation API');
	 print_debug('Error code: ' || l_error_code);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Now check to see if this move order line is allowed to be
   -- loaded and if so, how much quantity from the line is available
   IF (l_debug = 1) THEN
      print_debug('Values returned from call to validate_operation');
      print_debug('x_inspection_flag: =======> ' || l_inspection_flag);
      print_debug('x_load_flag: =============> ' || l_load_flag);
      print_debug('x_drop_flag: =============> ' || l_drop_flag);
      print_debug('x_load_prim_quantity: ====> ' || l_load_prim_quantity);
      print_debug('x_drop_prim_quantity: ====> ' || l_drop_prim_quantity);
      print_debug('x_inspect_prim_quantity: => ' || l_inspect_prim_quantity);
   END IF;

   -- Convert the available load quantity from the primary UOM
   -- to the given user inputted UOM if different
   IF (l_debug = 1) THEN
      print_debug('Call inv_um_convert to convert the load quantity');
   END IF;
   IF (p_uom_code <> p_prim_uom_code) THEN
      x_available_qty := inv_convert.inv_um_convert (p_inventory_item_id,
						     5,
						     l_load_prim_quantity,
						     p_prim_uom_code,
						     p_uom_code,
						     NULL,
						     NULL
						     );
    ELSE
      x_available_qty := l_load_prim_quantity;
   END IF;

   --bug 5002690 BEGIN
   BEGIN
      SELECT SUM(Decode(uom_code,
			p_uom_code,
			quantity,
			inv_convert.inv_um_convert (p_inventory_item_id,
						    5,
						    quantity,
						    uom_code,
						    p_uom_code,
						    NULL,
						    NULL
						    )
			))
	INTO x_total_qty
	FROM wms_lpn_contents
	WHERE inventory_item_id = p_inventory_item_id
	AND organization_id = p_organization_id
	AND parent_lpn_id = p_lpn_id
	AND Nvl(revision,'#$%') = Nvl(p_revision,'#$%');
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception querying total qty');
	 END IF;
	 x_total_qty := -1;
	 RAISE FND_API.G_EXC_ERROR;
   END;
   --bug 5002690 END

   IF (l_debug = 1) THEN
      print_debug('Total qty:'||x_total_qty);
      print_debug('Available quantity in inputted UOM is: ' || x_available_qty);
   END IF;
   l_progress  := '50';

   IF (l_debug = 1) THEN
      print_debug('***End of get_available_qty***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO get_available_qty_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting get_available_qty - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_available_qty_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting get_available_qty - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO get_available_qty_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting get_available_qty - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END get_available_qty;


PROCEDURE get_available_lot_qty
  (p_organization_id      IN    NUMBER            ,
   p_lpn_id               IN    NUMBER            ,
   p_inventory_item_id    IN    NUMBER            ,
   p_revision             IN    VARCHAR2          ,
   p_lot_number           IN    VARCHAR2          ,
   p_prim_uom_code        IN    VARCHAR2          ,
   p_uom_code             IN    VARCHAR2          ,
   x_return_status        OUT   NOCOPY VARCHAR2   ,
   x_msg_count            OUT   NOCOPY NUMBER     ,
   x_msg_data             OUT   NOCOPY VARCHAR2   ,
   x_available_lot_qty    OUT   NOCOPY NUMBER)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'get_available_lot_qty';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     -- Variables used to call validate_operation API
     l_error_code             NUMBER;
     l_inspection_flag        NUMBER;
     l_load_flag              NUMBER;
     l_drop_flag              NUMBER;
     l_load_prim_quantity     NUMBER;
     l_drop_prim_quantity     NUMBER;
     l_inspect_prim_quantity  NUMBER;

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling get_available_lot_qty with the following parameters***');
      print_debug('p_organization_id: ===> ' || p_organization_id);
      print_debug('p_lpn_id: ============> ' || p_lpn_id);
      print_debug('p_inventory_item_id: => ' || p_inventory_item_id);
      print_debug('p_revision: ==========> ' || p_revision);
      print_debug('p_lot_number: ========> ' || p_lot_number);
      print_debug('p_prim_uom_code: =====> ' || p_prim_uom_code);
      print_debug('p_uom_code: ==========> ' || p_uom_code);
   END IF;

   -- Set the savepoint
   SAVEPOINT get_available_lot_qty_sp;
   l_progress  := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize the output variables
   x_return_status := fnd_api.g_ret_sts_success;
   x_available_lot_qty := 0;
   l_progress := '30';

   -- Bug# 3401739
   -- Call the ATF runtime API validate_operation to get the
   -- available quantity of item to load for the given
   -- org/LPN/item/revision/lot.
   IF (l_debug = 1) THEN
      print_debug('Call validate_operation API for the given LPN/item/revision/lot');
   END IF;
   wms_atf_runtime_pub_apis.validate_operation
     (x_return_status          =>  x_return_status,
      x_msg_data               =>  x_msg_data,
      x_msg_count              =>  x_msg_count,
      x_error_code             =>  l_error_code,
      x_inspection_flag        =>  l_inspection_flag,
      x_load_flag              =>  l_load_flag,
      x_drop_flag              =>  l_drop_flag,
      x_load_prim_quantity     =>  l_load_prim_quantity,
      x_drop_prim_quantity     =>  l_drop_prim_quantity,
      x_inspect_prim_quantity  =>  l_inspect_prim_quantity,
      p_source_task_id         =>  NULL,
      p_move_order_line_id     =>  NULL,
      p_inventory_item_id      =>  p_inventory_item_id,
      p_lpn_id                 =>  p_lpn_id,
      p_activity_type_id       =>  WMS_GLOBALS.G_OP_ACTIVITY_INBOUND,
      p_organization_id        =>  p_organization_id,
      p_lot_number             =>  p_lot_number,
      p_revision               =>  p_revision);

   IF (l_debug = 1) THEN
      print_debug('Finished calling the validate_operation API');
   END IF;
   l_progress := '40';

   -- Check to see if the validate_operation API returned successfully
   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('Success returned from validate_operation API');
      END IF;
    ELSE
      IF (l_debug = 1) THEN
	 print_debug('Failure returned from validate_operation API');
	 print_debug('Error code: ' || l_error_code);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Now check to see if this move order line is allowed to be
   -- loaded and if so, how much quantity from the line is available
   IF (l_debug = 1) THEN
      print_debug('Values returned from call to validate_operation');
      print_debug('x_inspection_flag: =======> ' || l_inspection_flag);
      print_debug('x_load_flag: =============> ' || l_load_flag);
      print_debug('x_drop_flag: =============> ' || l_drop_flag);
      print_debug('x_load_prim_quantity: ====> ' || l_load_prim_quantity);
      print_debug('x_drop_prim_quantity: ====> ' || l_drop_prim_quantity);
      print_debug('x_inspect_prim_quantity: => ' || l_inspect_prim_quantity);
   END IF;

   -- Convert the available load quantity from the primary UOM
   -- to the given user inputted UOM if different
   IF (l_debug = 1) THEN
      print_debug('Call inv_um_convert to convert the load quantity');
   END IF;
   IF (p_uom_code <> p_prim_uom_code) THEN
      x_available_lot_qty := inv_convert.inv_um_convert (p_inventory_item_id,
							 5,
							 l_load_prim_quantity,
							 p_prim_uom_code,
							 p_uom_code,
							 NULL,
							 NULL
							 );
    ELSE
      x_available_lot_qty := l_load_prim_quantity;
   END IF;
   IF (l_debug = 1) THEN
      print_debug('Available lot quantity in inputted UOM is: ' || x_available_lot_qty);
   END IF;
   l_progress  := '50';

   IF (l_debug = 1) THEN
      print_debug('***End of get_available_lot_qty***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO get_available_lot_qty_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting get_available_lot_qty - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_available_lot_qty_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting get_available_lot_qty - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO get_available_lot_qty_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting get_available_lot_qty - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END get_available_lot_qty;



PROCEDURE pre_process_load
  (p_organization_id      IN   NUMBER             ,
   p_lpn_id               IN   NUMBER             ,
   p_inventory_item_id    IN   NUMBER             ,
   p_revision             IN   VARCHAR2           ,
   p_lot_number           IN   VARCHAR2           ,
   p_quantity             IN   NUMBER             ,
   p_uom_code             IN   VARCHAR2           ,
   --laks
   p_sec_quantity         IN   NUMBER             ,
   p_sec_uom_code         IN   VARCHAR2           ,
   p_user_id              IN   NUMBER             ,
   p_into_lpn_id          IN   NUMBER             ,
   p_serial_txn_temp_id   IN   NUMBER             ,
   p_txn_header_id        IN OUT NOCOPY NUMBER    ,
   x_return_status        OUT  NOCOPY VARCHAR2    ,
   x_msg_count            OUT  NOCOPY NUMBER      ,
   x_msg_data             OUT  NOCOPY VARCHAR2)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'pre_process_load';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_lpn_context        NUMBER;
     -- Variables used to lock the WLC (WMS_LPN_CONTENTS) records.
     -- WLC records should always exist for the given LPN if an item
     -- load on the java side has been done.
     CURSOR lock_wlc_cursor IS
	SELECT lpn_content_id
	  FROM wms_lpn_contents
	  WHERE parent_lpn_id = p_lpn_id
	  AND inventory_item_id = p_inventory_item_id
	  AND organization_id = p_organization_id
	  AND NVL(revision, '###') = NVL(p_revision, '###')
	  AND NVL(lot_number, '###') = NVL(p_lot_number, '###')
	  FOR UPDATE NOWAIT;
     record_locked        EXCEPTION;
     PRAGMA EXCEPTION_INIT(record_locked, -54);
     -- Primary load quantity variables used to convert
     -- the load transaction UOM values into primary UOM
     l_primary_load_qty   NUMBER;
     l_primary_uom_code   VARCHAR2(3);
     -- laks
     l_sec_load_qty   NUMBER;
     l_sec_uom_code   VARCHAR2(3);
     -- Move order line variables with quantity
     -- in the move order line's transaction UOM
     l_mo_line_id         NUMBER;
     l_mo_qty_avail       NUMBER;
     -- laks
     l_mo_sec_qty_avail       NUMBER;
     l_mo_uom_code        VARCHAR2(3);
     -- Variables used to check if move order lines exist
     -- and to call create_mo if necessary
     l_mo_line_count      NUMBER;
     l_mo_header_id       NUMBER;
     -- Primary UOM quantity variables used when
     -- matching move order line(s)
     l_primary_qty_avail  NUMBER;
     l_primary_qty_used   NUMBER;
     l_primary_qty_left   NUMBER;
     -- laks
     l_sec_qty_avail  NUMBER;
     l_sec_qty_used   NUMBER;
     l_sec_qty_left   NUMBER;
     -- Move order line table to store the move order line(s)
     -- used to match against the load entry values
     l_mo_lines_tb        inv_rcv_integration_apis.mo_in_tb_tp;
     l_tmp_mo_lines_tb        inv_rcv_integration_apis.mo_in_tb_tp;
     l_index              NUMBER;
     -- Cursor to get move order lines with available quantity
     -- which match the item load entry parameters
     CURSOR mo_lines_cursor IS
	SELECT mtrl.line_id,
	  mtrl.quantity - NVL(mtrl.quantity_delivered, 0),
     mtrl.uom_code,
     --laks
	  mtrl.secondary_quantity - NVL(mtrl.secondary_quantity_delivered, 0),
     mtrl.secondary_uom_code
	  FROM mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh
	  WHERE mtrl.organization_id = p_organization_id
	  AND mtrl.lpn_id = p_lpn_id
	  AND mtrl.inventory_item_id = p_inventory_item_id
	  AND NVL(mtrl.revision, '###') = NVL(p_revision, '###')
	  AND NVL(mtrl.lot_number, '###') = NVL(p_lot_number, '###')
	  AND mtrl.quantity <> NVL(mtrl.quantity_delivered, 0)
	  AND mtrl.line_status <> inv_globals.g_to_status_closed
	  AND mtrl.header_id = mtrh.header_id
	  AND mtrh.move_order_type = inv_globals.g_move_order_put_away
	  ORDER BY 2 DESC;
     -- Variables used for matching move order lines
     -- when the item is serial controlled
     l_current_serial     VARCHAR2(30);
     l_serial_quantity    NUMBER;
     l_is_new_entry       BOOLEAN;
     l_table_index        NUMBER;

     -- Cursor to get the move order lines for INV/RCV serials
     CURSOR mol_ser_csr_for_inv_rcv IS
	SELECT mtrl.line_id
	  ,    Nvl(mtrl.inspection_status,0) inspection_status
	  ,    quantity-Nvl(quantity_delivered,0) avail_qty
	  FROM mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh
	  WHERE mtrl.organization_id = p_organization_id
	  AND mtrl.lpn_id = p_lpn_id
	  AND mtrl.inventory_item_id = p_inventory_item_id
	  AND NVL(mtrl.revision, '###') = NVL(p_revision, '###')
	  AND NVL(mtrl.lot_number, '###') = NVL(p_lot_number, '###')
	  AND mtrl.quantity <> NVL(mtrl.quantity_delivered, 0)
	  AND ((l_lpn_context = 3) OR
	       (l_lpn_context = 1 AND l_mo_line_count = 0))
	  AND mtrl.line_status <> inv_globals.g_to_status_closed
	  AND mtrl.header_id = mtrh.header_id
	  AND mtrh.move_order_type = inv_globals.g_move_order_put_away
	  ORDER BY mtrl.inspection_status;

     TYPE mol_ser_tb IS TABLE OF mol_ser_csr_for_inv_rcv%ROWTYPE;
     l_mol_ser_tb mol_ser_tb;

     -- Cursor to get the move order lines for WIP serials
     CURSOR mol_ser_csr_for_wip IS
	SELECT mtrl.line_id
	  FROM mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh
	  WHERE mtrl.organization_id = p_organization_id
	  AND mtrl.lpn_id = p_lpn_id
	  AND mtrl.inventory_item_id = p_inventory_item_id
	  AND NVL(mtrl.revision, '###') = NVL(p_revision, '###')
	  AND NVL(mtrl.lot_number, '###') = NVL(p_lot_number, '###')
	  AND mtrl.quantity <> NVL(mtrl.quantity_delivered, 0)
	  AND l_lpn_context = 2
	  AND mtrl.reference_id IN (SELECT header_id
				    FROM wip_lpn_completions_serials
				    WHERE l_current_serial BETWEEN fm_serial_number AND
				    to_serial_number
				    AND NVL(lot_number, '###') = NVL(p_lot_number, '###'))
	  AND mtrl.line_status <> inv_globals.g_to_status_closed
	  AND mtrl.header_id = mtrh.header_id
	  AND mtrh.move_order_type = inv_globals.g_move_order_put_away;

     -- Cursor to get the marked serials
     CURSOR marked_serials_cursor IS
	SELECT serial_number
	  ,    Nvl(inspection_status,0) inspection_status
	  FROM mtl_serial_numbers
	  WHERE inventory_item_id = p_inventory_item_id
	  AND current_organization_id = p_organization_id
	  AND NVL(revision, '###') = NVL(p_revision, '###')
	  AND NVL(lot_number, '###') = NVL(p_lot_number, '###')
	  AND lpn_id = p_lpn_id
	  AND group_mark_id = p_serial_txn_temp_id
	  AND EXISTS (SELECT 1
		      FROM mtl_serial_numbers_temp
		      WHERE transaction_temp_id = p_serial_txn_temp_id
		      AND serial_number BETWEEN fm_serial_number AND
		      to_serial_number)
	  ORDER BY Nvl(inspection_status,0),LPAD(serial_number, 20);

     TYPE marked_serials_tb IS TABLE OF marked_serials_cursor%ROWTYPE;
     l_marked_serials_tb marked_serials_tb;

     -- Variables used to call validate_operation API
     l_inspection_flag        NUMBER;
     l_load_flag              NUMBER;
     l_drop_flag              NUMBER;
     l_load_prim_quantity     NUMBER;
     l_drop_prim_quantity     NUMBER;
     l_inspect_prim_quantity  NUMBER;
     -- laks
     l_load_sec_quantity     NUMBER;
     l_drop_sec_quantity     NUMBER;
     l_inspect_sec_quantity  NUMBER;
     l_error_code             NUMBER;
     -- Variables used to call split_mo API
     l_mo_split_tb        inv_rcv_integration_apis.mo_in_tb_tp;
     -- Variables used to call insert MMTT API
     l_return             NUMBER;
     l_txn_temp_id        NUMBER;
     l_subinv_code        VARCHAR2(10);
     l_tosubinv_code      VARCHAR2(10);
     l_locator_id         NUMBER;
     l_tolocator_id       NUMBER;
     l_cost_group_id      NUMBER;
     l_txn_src_id         NUMBER;
     l_project_id         NUMBER;
     l_task_id            NUMBER;
     l_trx_src_type_id    NUMBER;
     l_trx_type_id        NUMBER;
     l_trx_action_id      NUMBER;
     l_xfr_org_id         NUMBER := p_organization_id;
     l_trx_qty            NUMBER;
     -- Variables used to call insert MTLT API
     l_ser_trx_id         NUMBER;

     -- Cursor used to get the marked serials tied to a specific MOL.
     -- Note that in the WIP case, we are making the assumption that
     -- the fm_serial_number is always the same as the to_serial_number.
     -- It seems that for WIP LPN completions with serials, each record in
     -- WIP_LPN_COMPLETIONS_SERIALS contains one and only one serial.
     CURSOR matched_wip_serials_cursor IS
	SELECT wlcs.fm_serial_number
	  FROM wip_lpn_completions_serials wlcs, mtl_serial_numbers msn
	  WHERE l_lpn_context = 2
	  AND NVL(wlcs.lot_number, '###') = NVL(p_lot_number, '###')
	  AND wlcs.header_id IN (SELECT reference_id
				 FROM mtl_txn_request_lines
				 WHERE line_id = l_mo_line_id
				 AND organization_id = p_organization_id)
	  AND wlcs.fm_serial_number = msn.serial_number
	  AND msn.inventory_item_id = p_inventory_item_id
	  AND msn.current_organization_id = p_organization_id
	  AND NVL(msn.revision, '###') = NVL(p_revision, '###')
	  AND NVL(msn.lot_number, '###') = NVL(p_lot_number, '###')
	  AND msn.lpn_id = p_lpn_id
	  AND msn.group_mark_id = p_serial_txn_temp_id
	  AND EXISTS (SELECT 1
		      FROM mtl_serial_numbers_temp msnt
		      WHERE msnt.transaction_temp_id = p_serial_txn_temp_id
		      AND msn.serial_number BETWEEN msnt.fm_serial_number AND
		      msnt.to_serial_number);

     l_dummy NUMBER;
     l_serial_matched NUMBER;
     l_tmp NUMBER;

     --BUG 5194761
     l_cdock_flag NUMBER;
     l_ret_crossdock NUMBER;
     l_backorder_delivery_detail_id NUMBER;
     l_to_sub_code VARCHAR2(30);
     l_to_loc_id NUMBER;
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2400);
     l_tmp_index NUMBER;
     --END BUG 5194761

     TYPE serial_tb IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
     TYPE mol_serial_tb IS TABLE OF serial_tb INDEX BY BINARY_INTEGER;
     l_mol_serial_tb_b4_splt mol_serial_tb;
     l_mol_serial_tb_af_splt mol_serial_tb;

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling pre_process_load with the following parameters***');
      print_debug('p_organization_id: ====> ' || p_organization_id);
      print_debug('p_lpn_id: =============> ' || p_lpn_id);
      print_debug('p_inventory_item_id: ==> ' || p_inventory_item_id);
      print_debug('p_revision: ===========> ' || p_revision);
      print_debug('p_lot_number: =========> ' || p_lot_number);
      print_debug('p_quantity: ===========> ' || p_quantity);
      print_debug('p_uom_code: ===========> ' || p_uom_code);
      -- laks
      print_debug('p_sec_quantity: ===========> ' || p_sec_quantity);
      print_debug('p_uom_code: ===========> ' || p_sec_uom_code);
      print_debug('p_user_id: ============> ' || p_user_id);
      print_debug('p_into_lpn_id: ========> ' || p_into_lpn_id);
      print_debug('p_serial_txn_temp_id: => ' || p_serial_txn_temp_id);
      print_debug('p_txn_header_id: ======> ' || p_txn_header_id);
   END IF;

   -- Set the savepoint
   SAVEPOINT pre_process_load_sp;
   l_progress  := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '15';

   -- Set the return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '20';

   -- Lock the LPN contents record(s) to make sure
   -- nobody else is processing them
   IF (l_debug = 1) THEN
      print_debug('Lock the WLC records for the item/rev/lot/LPN combination');
   END IF;
   BEGIN
      OPEN lock_wlc_cursor;
      CLOSE lock_wlc_cursor;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF (l_debug = 1) THEN
	    print_debug('No WLC records found for given item/rev/lot/LPN combination!');
	 END IF;
	 FND_MESSAGE.SET_NAME('INV', 'INV_NO_RESULT_FOUND');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      WHEN RECORD_LOCKED THEN
	 IF (l_debug = 1) THEN
	    print_debug('WLC record not available because it is locked by someone');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_LPN_UNAVAIL');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;
   IF (l_debug = 1) THEN
      print_debug('Successfully locked the WLC records');
   END IF;
   l_progress := '25';

   -- Get a new transaction header id from the sequence
   -- if a value is not passed in
   IF (p_txn_header_id = -999) THEN
      SELECT mtl_material_transactions_s.NEXTVAL INTO p_txn_header_id FROM dual;
   END IF;
   IF (l_debug = 1) THEN
      print_debug('Transaction header ID: '  || p_txn_header_id);
   END IF;
   l_progress := '30';

   -- Get the sub, loc and context of the source LPN ID
   SELECT lpn_context, NVL(subinventory_code, '###'), NVL(locator_id, -999)
     INTO l_lpn_context, l_subinv_code, l_locator_id
     FROM wms_license_plate_numbers
     WHERE lpn_id = p_lpn_id
     AND organization_id = p_organization_id;
   IF (l_debug = 1) THEN
      print_debug('Source LPN Context: => ' || l_lpn_context);
      print_debug('Source LPN Sub: =====> ' || l_subinv_code);
      print_debug('Source LPN Loc: =====> ' || l_locator_id);
   END IF;
   l_progress := '40';

   -- Get the sub and loc of the destination LPN ID
   SELECT NVL(subinventory_code, '###'), NVL(locator_id, -999)
     INTO l_tosubinv_code, l_tolocator_id
     FROM wms_license_plate_numbers
     WHERE organization_id = p_organization_id
     AND lpn_id = p_into_lpn_id;
   IF (l_debug = 1) THEN
      print_debug('Into LPN Sub: =======> ' || l_tosubinv_code);
      print_debug('Into LPN Loc: =======> ' || l_tolocator_id);
   END IF;
   l_progress := '50';

   -- Reset the values to null if necessary
   IF (l_subinv_code = '###') THEN
      l_subinv_code := NULL;
   END IF;
   IF (l_locator_id = -999) THEN
      l_locator_id := NULL;
   END IF;
   IF (l_tosubinv_code = '###') THEN
      l_tosubinv_code := NULL;
   END IF;
   IF (l_tolocator_id = -999) THEN
      l_tolocator_id := NULL;
   END IF;
   l_progress := '60';

   -- Get the item's primary uom code
   SELECT primary_uom_code
     INTO l_primary_uom_code
     FROM mtl_system_items
     WHERE inventory_item_id = p_inventory_item_id
     AND organization_id = p_organization_id;
   IF (l_debug = 1) THEN
      print_debug('Item primary UOM code: ' || l_primary_uom_code);
   END IF;
   l_progress := '70';

   -- Convert the item load quantity into the primary quantity if necessary
   IF (p_uom_code <> l_primary_uom_code) THEN
      l_primary_load_qty :=
	inv_convert.inv_um_convert (p_inventory_item_id,
				    5,
				    p_quantity,
				    p_uom_code,
				    l_primary_uom_code,
				    NULL,
				    NULL);
    ELSE
      l_primary_load_qty := p_quantity;
   END IF;

   --laks
   l_sec_load_qty := p_sec_quantity;
   IF (l_debug = 1) THEN
      print_debug('Load quantity in primary UOM: ' || l_primary_load_qty);
      -- laks
      print_debug('Load quantity in secondary UOM: ' || l_sec_load_qty);
   END IF;
   l_progress := '80';

   -- Check if any valid move order lines exist for the item load entry
   SELECT COUNT(*)
     INTO l_mo_line_count
     FROM mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh
     WHERE mtrl.organization_id = p_organization_id
     AND mtrl.lpn_id = p_lpn_id
     AND mtrl.inventory_item_id = p_inventory_item_id
     AND NVL(mtrl.revision, '###') = NVL(p_revision, '###')
     AND NVL(mtrl.lot_number, '###') = NVL(p_lot_number, '###')
     AND mtrl.quantity <> NVL(mtrl.quantity_delivered, 0)
     AND mtrl.line_status <> inv_globals.g_to_status_closed
     AND mtrl.header_id = mtrh.header_id
     AND mtrh.move_order_type = inv_globals.g_move_order_put_away;
   IF (l_debug = 1) THEN
      print_debug('The number of MOLs found is: ' || l_mo_line_count);
   END IF;
   l_progress := '90';

   IF (l_mo_line_count = 0) THEN
      -- No move order lines were found so check the LPN context
      IF (l_lpn_context <> 1) THEN
	 -- No valid move order lines for a non-Inventory case
	 IF (l_debug = 1) THEN
	    print_debug('No valid move order lines found for non-INV LPN');
	 END IF;
	 l_progress := '100';
	 -- RCV and WIP LPN's should have valid move order lines
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_MO_NOT_FOUND');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
       ELSE
	 -- LPN is an Inventory LPN with no move order lines.
	 -- This should be the non-ATF flow since if an ATF plan was in
	 -- effect, there would have been move order lines for the
	 -- material within the INV LPN.
	 IF (l_debug = 1) THEN
	    print_debug('INV LPN with no valid move order lines');
	 END IF;

	 -- Get the project and task for the source LPN
	 SELECT NVL(project_id, -999), NVL(task_id, -999)
	   INTO l_project_id, l_task_id
	   FROM mtl_item_locations
	   WHERE inventory_location_id = l_locator_id
	   AND organization_id = p_organization_id
	   AND subinventory_code = l_subinv_code;
	 l_progress := '110';

	 -- Get the cost group ID for the item load material.
	 -- Bug# 3368741
	 -- Added the ROWNUM = 1 line and a DISTINCT keyword in case there are
	 -- multiple WLC records for the same LPN/item/rev/lot which is possible
	 -- if from different sources.
	 SELECT DISTINCT NVL(cost_group_id, -999)
	   INTO l_cost_group_id
	   FROM wms_lpn_contents
	   WHERE parent_lpn_id = p_lpn_id
	   AND inventory_item_id = p_inventory_item_id
	   AND NVL(revision, '###') = NVL(p_revision, '###')
	   AND NVL(lot_number, '###') = NVL(p_lot_number, '###')
	   AND ROWNUM = 1;
	 l_progress := '120';

	 -- Reset the values to NULL if necessary
	 IF (l_project_id = -999) THEN
	    l_project_id := NULL;
	 END IF;
	 IF (l_task_id = -999) THEN
	    l_task_id := NULL;
	 END IF;
	 IF (l_cost_group_id = -999) THEN
	    l_cost_group_id := NULL;
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('Required variable for calling create_mo');
	    print_debug('Project ID: ====> ' || l_project_id);
	    print_debug('Task ID: =======> ' || l_task_id);
	    print_debug('Cost Group ID: => ' || l_cost_group_id);
	 END IF;
	 l_progress := '130';

	 -- Call create_mo
	 IF (l_debug = 1) THEN
	    print_debug('Call the create_mo API for the given item load entry');
	 END IF;
	 wms_task_dispatch_put_away.create_mo
	   (p_org_id                         => p_organization_id,
	    p_inventory_item_id              => p_inventory_item_id,
	    p_qty                            => p_quantity,
	    p_uom                            => p_uom_code,
       -- laks
	    p_sec_qty                        => p_sec_quantity,
	    p_sec_uom                        => p_sec_uom_code,
	    p_lpn                            => p_lpn_id,
	    p_project_id                     => l_project_id,
	    p_task_id                        => l_task_id,
	    p_reference                      => NULL,
	    p_reference_type_code            => NULL,
	    p_reference_id                   => NULL,
	    p_lot_number                     => p_lot_number,
	    p_revision                       => p_revision,
	    p_header_id                      => l_mo_header_id,
	    p_sub                            => l_subinv_code,
	    p_loc                            => l_locator_id,
	    x_line_id                        => l_mo_line_id,
	    p_inspection_status              => NULL,
	    p_transaction_type_id            => 64,
	    p_transaction_source_type_id     => 4,
	    p_wms_process_flag               => NULL,
	    x_return_status                  => x_return_status,
	    x_msg_count                      => x_msg_count,
	    x_msg_data                       => x_msg_data,
	    p_from_cost_group_id             => l_cost_group_id,
	    p_transfer_org_id                => p_organization_id);

	 IF (l_debug = 1) THEN
	    print_debug('Finished calling the create_mo API');
	 END IF;
	 l_progress := '140';

	 -- Check to see if the create_mo API returned successfully
	 IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Success returned from create_mo API');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('Failure returned from create_mo API');
	    END IF;
	    FND_MESSAGE.SET_NAME('WMS', 'WMS_TD_MO_ERROR');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
	 l_progress := '150';

	 -- This newly created move order line is the only one
	 -- needed to match the item load entry
	 IF (l_debug = 1) THEN
	    print_debug('Move order line ID: ===> ' || l_mo_line_id);
	    print_debug('Move order header ID: => ' || l_mo_header_id);
	    print_debug('Primary Load Qty: =====> ' || l_primary_load_qty);
	    print_debug('Secondary Load Qty: =====> ' || l_sec_load_qty);
	 END IF;
	 l_progress := '160';
      END IF;
   END IF;
   -- End of no move order lines found logic

   -- If item is not serialized, then use mo_lines_cursor,
   -- otherwise use mo_lines_serial_cursor for matching MOLs.
   -- A value should be passed for the serial txn temp ID if the item
   -- is serial controlled.  This validation is checked on the java page
   -- prior to calling this procedure.
   IF (p_serial_txn_temp_id IS NULL) THEN
      -- Non-serial controlled item
      IF (l_debug = 1 ) THEN
	 print_debug('Non-serial controlled item');
      END IF;
      -- Open the mo_lines cursor
      l_primary_qty_left := l_primary_load_qty;
      l_sec_qty_left := l_sec_load_qty;
      l_index := 1;
      IF (l_debug = 1) THEN
	 print_debug('Open the move order lines cursor');
      END IF;
      OPEN mo_lines_cursor;
      LOOP
	 FETCH mo_lines_cursor INTO l_mo_line_id, l_mo_qty_avail, l_mo_uom_code, l_mo_sec_qty_avail, l_sec_uom_code; --laks
	 EXIT WHEN mo_lines_cursor%NOTFOUND;
	 IF (l_debug = 1) THEN
	    print_debug('Found a matching move order line');
	    print_debug('Move order line ID: =========> ' || l_mo_line_id);
	    print_debug('Move order qty available: ===> ' || l_mo_qty_avail);
	    print_debug('Move order UOM code: ========> ' || l_mo_uom_code);
       --laks
  	    print_debug('Move order sec qty available: ===> ' || l_mo_sec_qty_avail);
	    print_debug('Move order Sec UOM code: ========> ' || l_sec_uom_code);
	 END IF;
	 l_progress := '170';

	 -- Convert the MO qty available to the primary UOM if necessary
	 IF (l_mo_uom_code <> l_primary_uom_code) THEN
	    l_primary_qty_avail :=
	      inv_convert.inv_um_convert (p_inventory_item_id,
					  5,
					  l_mo_qty_avail,
					  l_mo_uom_code,
					  l_primary_uom_code,
					  NULL,
					  NULL);
	  ELSE
	    l_primary_qty_avail := l_mo_qty_avail;
	 END IF;
    --laks
    l_sec_qty_avail := l_mo_sec_qty_avail;
	 IF (l_debug = 1) THEN
	    print_debug('Primary quantity available: => ' || l_primary_qty_avail);
       --laks
       print_debug('Secondary quantity available: => ' || l_sec_qty_avail);
	 END IF;
	 l_progress := '180';

	 -- Call the ATF validate_operation API to see if this move order
	 -- line can be loaded and if so, how much quantity is available
	 -- to be loaded
	 IF (l_debug = 1) THEN
	    print_debug('Call validate_operation API for the given MOL');
	 END IF;
	 wms_atf_runtime_pub_apis.validate_operation
	   (x_return_status          =>  x_return_status,
	    x_msg_data               =>  x_msg_data,
	    x_msg_count              =>  x_msg_count,
	    x_error_code             =>  l_error_code,
	    x_inspection_flag        =>  l_inspection_flag,
	    x_load_flag              =>  l_load_flag,
	    x_drop_flag              =>  l_drop_flag,
	    x_load_prim_quantity     =>  l_load_prim_quantity,
	    x_drop_prim_quantity     =>  l_drop_prim_quantity,
	    x_inspect_prim_quantity  =>  l_inspect_prim_quantity,
	    p_source_task_id         =>  NULL,
	    p_move_order_line_id     =>  l_mo_line_id,
	    p_inventory_item_id      =>  p_inventory_item_id,
	    p_lpn_id                 =>  p_lpn_id,
	    p_activity_type_id       =>  WMS_GLOBALS.G_OP_ACTIVITY_INBOUND,
	    p_organization_id        =>  p_organization_id);

	 IF (l_debug = 1) THEN
	    print_debug('Finished calling the validate_operation API');
	 END IF;
	 l_progress := '190';

	 -- Check to see if the validate_operation API returned successfully
	 IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Success returned from validate_operation API');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('Failure returned from validate_operation API');
	       print_debug('Error code: ' || l_error_code);
	    END IF;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 -- Now check to see if this move order line is allowed to be
	 -- loaded and if so, how much quantity from the line is available
	 IF (l_debug = 1) THEN
	    print_debug('Values returned from call to validate_operation');
	    print_debug('x_inspection_flag: =======> ' || l_inspection_flag);
	    print_debug('x_load_flag: =============> ' || l_load_flag);
	    print_debug('x_drop_flag: =============> ' || l_drop_flag);
	    print_debug('x_load_prim_quantity: ====> ' || l_load_prim_quantity);
	    print_debug('x_drop_prim_quantity: ====> ' || l_drop_prim_quantity);
	    print_debug('x_inspect_prim_quantity: => ' || l_inspect_prim_quantity);
	 END IF;
	 l_primary_qty_avail := l_load_prim_quantity;

    --laks
    IF(p_sec_uom_code IS NOT NULL) THEN
        l_sec_qty_avail := inv_convert.inv_um_convert (
                             p_inventory_item_id,
                             p_lot_number,
                             p_organization_id,
                             5,
                             l_load_prim_quantity,
                             l_primary_uom_code,
                             p_sec_uom_code,
                             NULL,
                             NULL);
    END IF;


	 -- Consume loaded quantity from this MOL only if the qty available
	 -- is greater than 0
	 IF (l_primary_qty_avail > 0) THEN
	    -- Compare the primary quantity available from this
	    -- move order line with the primary quantity left to match
	    IF (l_primary_qty_avail > l_primary_qty_left) THEN
	       -- We do not need to consume all of the quantity
	       -- on this current move order line
	       l_primary_qty_used := l_primary_qty_left;
          --laks
          l_sec_qty_used := l_sec_qty_left;
	     ELSE
	       -- Consume the entire quantity for this move order line
	       l_primary_qty_used := l_primary_qty_avail;
          --laks
          l_sec_qty_used := l_sec_qty_avail;
	    END IF;
	    l_primary_qty_left := l_primary_qty_left - l_primary_qty_used;
       --laks
  	    l_sec_qty_left := l_sec_qty_left - l_sec_qty_used;
	    IF (l_debug = 1) THEN
	       print_debug('Primary quantity used: ======> ' || l_primary_qty_used);
	       print_debug('Primary quantity left: ======> ' || l_primary_qty_left);
          --laks
	       print_debug('Sec quantity used: ======> ' || l_sec_qty_used);
	       print_debug('Sec quantity left: ======> ' || l_sec_qty_left);
	    END IF;
	    l_progress := '200';

	    -- Store this move order line info in the mo line table
	    l_mo_lines_tb(l_index).prim_qty := l_primary_qty_used;
       l_mo_lines_tb(l_index).sec_qty := l_sec_qty_used;
	    l_mo_lines_tb(l_index).line_id := l_mo_line_id;
	    IF (l_debug = 1) THEN
	       print_debug('Stored the move order line entry in the table: ' || l_index);
	    END IF;
	    l_progress := '210';
	 END IF;

	 -- Check if we have finished matching the full load quantity
	 IF (l_primary_qty_left = 0) THEN
	    EXIT;
	 END IF;
	 -- Increment the table index value
	 l_index := l_index + 1;
      END LOOP;
      CLOSE mo_lines_cursor;
      IF (l_debug = 1) THEN
	 print_debug('Closed the move order lines cursor');
      END IF;
      l_progress := '220';

      -- Check that we were able to fully match the load quantity
      IF (l_primary_qty_left <> 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Unable to fully match the load quantity');
	 END IF;
	 l_progress := '230';
	 -- This case should technically not occur if the move order
	 -- lines are maintained properly.
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_MO_NOT_FOUND');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
       ELSE
	 -- Full quantity has been matched
	 IF (l_debug = 1) THEN
	    print_debug('Able to fully match the load quantity');
	 END IF;
      END IF;
   END IF;
   -- End of non-serial controlled item part for matching MOL

   -- Beginning of serial controlled item part
   IF (p_serial_txn_temp_id IS NOT NULL) THEN

      IF (l_debug = 1 ) THEN
	 print_debug('Serial controlled item');
      END IF;

      IF (l_lpn_context = 2) THEN

	 IF (l_debug = 1 ) THEN
	    print_debug('WIP Serial');
	 END IF;

	 -- Serial controlled item
	 l_serial_quantity := 0;
	 l_index := 1;
	 OPEN marked_serials_cursor;
	 LOOP
	    FETCH marked_serials_cursor INTO l_current_serial,l_dummy;
	    EXIT WHEN marked_serials_cursor%NOTFOUND;
	    IF (l_debug = 1) THEN
	       print_debug('Current serial: ' || l_current_serial);
	    END IF;
	    l_progress := '240';

	    -- For the current serial, match it against the appropriate move order line.
	    -- There should only be one move order line that matches to a
	    -- specific serial.
	    OPEN mol_ser_csr_for_wip;
	    FETCH mol_ser_csr_for_wip INTO l_mo_line_id;
	    IF (mol_ser_csr_for_wip%FOUND) THEN
	       IF (l_debug = 1) THEN
		  print_debug('Found a matching move order line');
		  print_debug('Move order line ID: => ' || l_mo_line_id);
	       END IF;
	       l_progress := '250';

	       -- Increment the matched serial quantity variable
	       l_serial_quantity := l_serial_quantity + 1;

	       l_is_new_entry := TRUE;
	       -- Check if this move order line has already been stored in
	       -- the mo line table
	       IF (l_mo_lines_tb.COUNT <> 0) THEN
		  -- Entries have already been stored in the MOL table
		  l_table_index  := l_mo_lines_tb.FIRST;
		  LOOP
		     IF (l_mo_lines_tb(l_table_index).line_id = l_mo_line_id) THEN
		     -- Increment the quantity for the same MOL entry
			l_mo_lines_tb(l_table_index).prim_qty :=
			  l_mo_lines_tb(l_table_index).prim_qty + 1;
			l_mo_lines_tb(l_table_index).line_id := l_mo_line_id;
			l_is_new_entry := FALSE;
			IF (l_debug = 1) THEN
			   print_debug('Updated the move order line entry in the table: ' ||
				       l_table_index);
			END IF;
			l_progress := '260';
			EXIT;
		     END IF;
		     EXIT WHEN l_table_index = l_mo_lines_tb.LAST;
		     l_table_index  := l_mo_lines_tb.NEXT(l_table_index);
		  END LOOP;

		  -- Check if this MOL is a new entry in the table
		  IF (l_is_new_entry) THEN
		     l_mo_lines_tb(l_index).prim_qty := 1;
		     l_mo_lines_tb(l_index).line_id := l_mo_line_id;
		     IF (l_debug = 1) THEN
			print_debug('Stored the move order line entry in the table: ' || l_index);
		     END IF;
		     l_progress := '270';
		     -- Update the index whenever we insert a new entry
		     -- into the MOL table
		  l_index := l_index + 1;
		  END IF;
		ELSE
			-- No entries entered in MOL table yet
			-- Store this move order line info in the mo line table
			l_mo_lines_tb(l_index).prim_qty := 1;
			l_mo_lines_tb(l_index).line_id := l_mo_line_id;
			IF (l_debug = 1) THEN
			   print_debug('Stored the move order line entry in the table: ' || l_index);
			END IF;
			l_progress := '280';
			-- Update the index whenever we insert a new entry
			-- into the MOL table
			l_index := l_index + 1;
	       END IF;
	       -- End of check if entries exist in l_mo_lines_tb
	     ELSE
		  -- No move order line found with the matching serial
		  IF (l_debug = 1) THEN
		     print_debug('Could not find a matching move order line: ' ||
				 l_current_serial);
		  END IF;
		  FND_MESSAGE.SET_NAME('WMS', 'WMS_MO_NOT_FOUND');
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
	    END IF;

	    -- Close the MOL serial cursor
	    CLOSE mol_ser_csr_for_wip;
	    l_progress := '290';

	 END LOOP;
	 CLOSE marked_serials_cursor;
	 IF (l_debug = 1) THEN
	    print_debug('Closed the marked_serials_cursor');
	    print_debug('Serial quantity matched: => ' || l_serial_quantity);
	    print_debug('Serial quantity loaded: ==> ' || l_primary_load_qty);
	 END IF;
	 l_progress := '300';

	 -- Check that the inputted l_primary_load_qty equals the amount
	 -- of serials that were marked for the given item/rev/lot combination
	 IF (l_primary_load_qty <> l_serial_quantity) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Unable to fully match the load quantity');
	    END IF;
	    FND_MESSAGE.SET_NAME ('WMS', 'WMS_CONT_INVALID_X_QTY');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	  ELSE
	    -- Full quantity has been matched
	    IF (l_debug = 1) THEN
	       print_debug('Able to fully match the load quantity');
	    END IF;
	 END IF;
	 l_progress := '310';
       ELSE -- IF l_lpn_context in (1,3) THEN
	 IF (l_debug = 1) THEN
	    print_debug('INV/RCV Serial');
	 END IF;

	 l_index := 1;

	 OPEN marked_serials_cursor;
	 FETCH marked_serials_cursor bulk collect INTO l_marked_serials_tb;
	 CLOSE marked_serials_cursor;

	 IF (l_debug = 1) THEN
	    print_debug('# marked serials: '||l_marked_serials_tb.COUNT);
	 END IF;

	 IF (l_primary_load_qty <> l_marked_serials_tb.COUNT) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Unable to fully match the load quantity');
	    END IF;
	    FND_MESSAGE.SET_NAME ('WMS', 'WMS_CONT_INVALID_X_QTY');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	  ELSE
	    -- Full quantity has been matched
	    IF (l_debug = 1) THEN
	       print_debug('Serials match the load quantity');
	    END IF;
	 END IF;

	 l_progress := '310.1';

	 OPEN mol_ser_csr_for_inv_rcv;
	 FETCH mol_ser_csr_for_inv_rcv bulk collect INTO l_mol_ser_tb;
	 CLOSE mol_ser_csr_for_inv_rcv;

	 IF (l_debug = 1) THEN
	    print_debug('# of MOL matched: '||l_mol_ser_tb.COUNT);
	 END IF;

	 l_progress := '310.2';

	 FOR i IN 1..l_marked_serials_tb.COUNT LOOP
	    IF (l_debug = 1) THEN
	       print_debug('l_marked_serials_tb('||i||').serial_number:'||
			   l_marked_serials_tb(i).serial_number||' inspection_status:'
			   ||l_marked_serials_tb(i).inspection_status);
	    END IF;

	    l_progress := '310.3';

	    FOR j IN 1..l_mol_ser_tb.COUNT LOOP
	       IF (l_debug = 1) THEN
		  print_debug('l_mol_ser_tb('||j||').line_id:'||
			      l_mol_ser_tb(j).line_id||' avail_qty:'
			      ||l_mol_ser_tb(j).avail_qty||' inspection_status:'
			      ||l_mol_ser_tb(j).inspection_status);
	       END IF;

	       l_progress := '310.4';

	       IF (l_marked_serials_tb(i).inspection_status = l_mol_ser_tb(j).inspection_status) THEN
		  l_is_new_entry := TRUE;

		  -- Check if this move order line has already been stored in
		  -- the mo line table
		  IF (l_mo_lines_tb.COUNT <> 0) THEN
		     -- Entries have already been stored in the MOL table
		     l_table_index  := l_mo_lines_tb.FIRST;
		     LOOP
			IF (l_mo_lines_tb(l_table_index).line_id = l_mol_ser_tb(j).line_id) THEN
			   -- Increment the quantity for the same MOL entry
			   l_mo_lines_tb(l_table_index).prim_qty := l_mo_lines_tb(l_table_index).prim_qty + 1;
			   l_is_new_entry := FALSE;
			   IF (l_debug = 1) THEN
			      print_debug('Updated the move order line entry in the table: ' ||l_table_index);
			   END IF;
			   l_progress := '310.5';
			   EXIT;
			END IF;
			EXIT WHEN l_table_index = l_mo_lines_tb.LAST;
			l_table_index  := l_mo_lines_tb.NEXT(l_table_index);
		     END LOOP;

		     -- Check if this MOL is a new entry in the table
		     IF (l_is_new_entry) THEN
			l_mo_lines_tb(l_index).prim_qty := 1;
			l_mo_lines_tb(l_index).line_id := l_mol_ser_tb(j).line_id;
			IF (l_debug = 1) THEN
			   print_debug('Stored the move order line entry in the table: ' || l_index);
			END IF;
			l_progress := '310.6';
			-- Update the index whenever we insert a new entry
			-- into the MOL table
			l_index := l_index + 1;
		     END IF;
		   ELSE
		     -- No entries entered in MOL table yet
		     -- Store this move order line info in the mo line table
		     l_mo_lines_tb(l_index).prim_qty := 1;
		     l_mo_lines_tb(l_index).line_id := l_mol_ser_tb(j).line_id;
		     IF (l_debug = 1) THEN
			print_debug('Stored the move order line entry in the table: ' || l_index);
		     END IF;
		     l_progress := '310.7';
		     -- Update the index whenever we insert a new entry
		     -- into the MOL table
		     l_index := l_index + 1;
		  END IF;--END IF (l_mo_lines_tb.COUNT <> 0) THEN

		  IF l_mol_serial_tb_b4_splt.exists(l_mol_ser_tb(j).line_id) THEN
		     l_tmp := l_mol_serial_tb_b4_splt(l_mol_ser_tb(j).line_id).COUNT + 1;
		   ELSE
		     l_tmp := 1;
		  END IF;

		  l_mol_serial_tb_b4_splt(l_mol_ser_tb(j).line_id)(l_tmp) := l_marked_serials_tb(i).serial_number;

		  l_mol_ser_tb(j).avail_qty := l_mol_ser_tb(j).avail_qty - 1;

		  IF l_mol_ser_tb(j).avail_qty <= 0 THEN
		     l_mol_ser_tb.DELETE(j);
		  END IF;

		  l_serial_matched := 1;

		  EXIT;

	       END IF;--END IF (l_marked_serials_tb(i).inspection_status = l_mol_ser_tb(j).inspection_status) THEN
	    END LOOP;--END FOR j IN 1..l_mol_ser_tb.COUNT LOOP

	    IF (l_serial_matched <> 1) THEN
	       -- No move order line found with the matching serial
	       IF (l_debug = 1) THEN
		  print_debug('Could not find a matching move order line: ' ||
			      l_marked_serials_tb(i).serial_number);
	       END IF;
	       FND_MESSAGE.SET_NAME('WMS', 'WMS_MO_NOT_FOUND');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END LOOP;--FOR i IN 1..l_marked_serials_tb.COUNT LOOP
      END IF;--END IF (l_lpn_context = 2) THEN

	 -- Call the ATF validate_operation API to see if the move order
	 -- lines matched for all serials can be loaded and if so, how much
	 -- quantity is available to be loaded
      IF (l_debug = 1) THEN
	    print_debug('Call validate_operation API for the matched MOLs');
      END IF;
      l_table_index  := l_mo_lines_tb.FIRST;
      LOOP
	 IF (l_mo_lines_tb(l_table_index).line_id = l_mo_line_id) THEN
	    print_debug('Current MOL: ' || l_mo_lines_tb(l_table_index).line_id);
	    print_debug('MOL quantity: ' || l_mo_lines_tb(l_table_index).prim_qty);
	 END IF;
	 l_progress := '320';

	 wms_atf_runtime_pub_apis.validate_operation
	   (x_return_status          =>  x_return_status,
	    x_msg_data               =>  x_msg_data,
	    x_msg_count              =>  x_msg_count,
	    x_error_code             =>  l_error_code,
	    x_inspection_flag        =>  l_inspection_flag,
	    x_load_flag              =>  l_load_flag,
	    x_drop_flag              =>  l_drop_flag,
	    x_load_prim_quantity     =>  l_load_prim_quantity,
	    x_drop_prim_quantity     =>  l_drop_prim_quantity,
	    x_inspect_prim_quantity  =>  l_inspect_prim_quantity,
	    p_source_task_id         =>  NULL,
	    p_move_order_line_id     =>  l_mo_lines_tb(l_table_index).line_id,
	    p_inventory_item_id      =>  p_inventory_item_id,
	    p_lpn_id                 =>  p_lpn_id,
	    p_activity_type_id       =>  WMS_GLOBALS.G_OP_ACTIVITY_INBOUND,
	    p_organization_id        =>  p_organization_id);

	 IF (l_debug = 1) THEN
	    print_debug('Finished calling the validate_operation API');
	 END IF;
	 l_progress := '330';

	 -- Check to see if the validate_operation API returned successfully
	 IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Success returned from validate_operation API');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('Failure returned from validate_operation API');
	       print_debug('Error code: ' || l_error_code);
	    END IF;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
	 l_progress := '340';

	 -- Now check to see if this move order line is allowed to be
	 -- loaded and if so, how much quantity from the line is available
	 IF (l_debug = 1) THEN
	    print_debug('Values returned from call to validate_operation');
	    print_debug('x_inspection_flag: =======> ' || l_inspection_flag);
	    print_debug('x_load_flag: =============> ' || l_load_flag);
	    print_debug('x_drop_flag: =============> ' || l_drop_flag);
	    print_debug('x_load_prim_quantity: ====> ' || l_load_prim_quantity);
	    print_debug('x_drop_prim_quantity: ====> ' || l_drop_prim_quantity);
	    print_debug('x_inspect_prim_quantity: => ' || l_inspect_prim_quantity);
	 END IF;

	 -- Check that the full serial quantity matched to
	 -- that move order line can be loaded
	 IF (l_load_prim_quantity < l_mo_lines_tb(l_table_index).prim_qty) THEN
	    -- The MOL matched is not available for loading all the serials
	    IF (l_debug = 1) THEN
	       print_debug('Matching MOL does not have enough valid qty for load');
	    END IF;
	    FND_MESSAGE.SET_NAME('WMS', 'WMS_MO_NOT_FOUND');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	  ELSE
	    -- The matched MOL has enough valid quantity to load all the serials
	    IF (l_debug = 1) THEN
	       print_debug('Able to fully load the serials for the matched MOL');
	    END IF;
	 END IF;
	 l_progress := '350';

	 EXIT WHEN l_table_index = l_mo_lines_tb.LAST;
	 l_table_index  := l_mo_lines_tb.NEXT(l_table_index);
      END LOOP;

   END IF;
   -- End of serial controlled item part for matching MOL

   -- Now that we have matched the item load entry with the
   -- appropriate move order lines, call split_mo to split the
   -- move order lines and create new ones for the item load entry
   IF (l_debug = 1) THEN
      print_debug('For each move order line, call the split_mo API');
   END IF;
   -- Initialize loop variables
   l_mo_split_tb.DELETE;
   l_index := l_mo_lines_tb.FIRST;
   l_progress := '360';
   LOOP
      IF (l_debug = 1) THEN
	 print_debug('Current MO line: => ' || l_mo_lines_tb(l_index).line_id);
	 print_debug('Current MO qty: ==> ' || l_mo_lines_tb(l_index).prim_qty);
      END IF;
      -- Set up the qty value to split in the input MO split table
      l_mo_split_tb(1).prim_qty := l_mo_lines_tb(l_index).prim_qty;
      --laks
      l_mo_split_tb(1).sec_qty := l_mo_lines_tb(l_index).sec_qty;
      l_mo_split_tb(1).line_id := l_mo_lines_tb(l_index).line_id;

      IF (l_debug = 1) THEN
	 print_debug('Calling split_mo API');
      END IF;
      inv_rcv_integration_apis.split_mo
	(p_orig_mol_id     =>  l_mo_lines_tb(l_index).line_id,
	 p_mo_splt_tb      =>  l_mo_split_tb,
	 p_operation_type  =>  'LOAD',
	 x_return_status   =>  x_return_status,
	 x_msg_count       =>  x_msg_count,
	 x_msg_data        =>  x_msg_data
	 );
      IF (l_debug = 1) THEN
	 print_debug('Finished calling split_mo API');
      END IF;
      l_progress := '370';

      -- Check that the call to split_mo returned successfully
      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Success returned from split_mo API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Failure returned from split_mo API');
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Update the MO lines table entry with the newly created split MO line
      IF (l_debug = 1) THEN
	 print_debug('New Split MO line: => ' || l_mo_split_tb(1).line_id);
      END IF;

      l_progress := '380';

      IF (p_serial_txn_temp_id IS NOT NULL AND l_lpn_context IN (1,3)) THEN
	 l_mol_serial_tb_af_splt(l_mo_split_tb(1).line_id) := l_mol_serial_tb_b4_splt(l_mo_lines_tb(l_index).line_id);
      END IF;

      l_mo_lines_tb(l_index).line_id := l_mo_split_tb(1).line_id;

      -- Exit if all move order lines have been split
      EXIT WHEN l_index = l_mo_lines_tb.LAST;
      l_index := l_mo_lines_tb.NEXT(l_index);
   END LOOP;
   IF (l_debug = 1) THEN
      print_debug('Finished calling split_mo for all MO lines');
   END IF;
   l_progress := '390';


   --BUG 5194761: Call crossdock API here to make sure that all the MO
   --splitting is done before inserting into dummy MMTT
   BEGIN
     SELECT NVL(crossdock_flag, 2) cdock
      INTO  l_cdock_flag
      FROM  mtl_parameters
     WHERE  organization_id = p_organization_id;
   EXCEPTION
     WHEN OTHERS THEN
       IF (l_debug = 1) THEN
        print_debug('Error getting org crossdock flag. SQLERRM:'||SQLERRM);
       END IF;
       RAISE fnd_api.g_exc_error;
   END;

   IF (l_debug = 1) THEN
     print_debug('l_cdock_flag:'||l_cdock_flag);
   END IF;

   --Make a copy of l_mo_lines_tb
   l_tmp_mo_lines_tb := l_mo_lines_tb;

   l_index := l_tmp_mo_lines_tb.FIRST;
   LOOP

      BEGIN
        SELECT backorder_delivery_detail_id
          ,    to_subinventory_code
          ,    to_locator_id
         INTO  l_backorder_delivery_detail_id
          ,    l_to_sub_code
          ,    l_to_loc_id
         FROM  mtl_txn_request_lines
        WHERE  line_id = l_tmp_mo_lines_tb(l_index).line_id;
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('Error querying MTRL. SQLERRM:'||SQLERRM);
          END IF;
          RAISE fnd_api.g_exc_error;
      END;

      IF (l_debug = 1) THEN
        print_debug('l_backorder_delivery_detail_id:'||l_backorder_delivery_detail_id);
        print_debug('l_to_sub_code:'||l_to_sub_code);
        print_debug('l_to_loc_id:'||l_to_loc_id );
      END IF;

      IF ((l_cdock_flag = 1  -- WIP, op-xdock enabled, and x-dock not happened
           AND l_lpn_context = 2
	   AND l_backorder_delivery_detail_id IS NULL)
	  OR
          (l_lpn_context = 3  -- RCV, xdock happened, but staging lane suggestion not successful
	   AND l_backorder_delivery_detail_id IS NOT NULL
           AND (l_to_sub_code IS NULL OR l_to_loc_id IS NULL))
	  ) THEN

	 IF (l_debug = 1) THEN
	    print_debug('Calling crossdock API');
	 END IF;

	 -- Call the cross dock API
	 wms_cross_dock_pvt.crossdock(
				      p_org_id                   => p_organization_id
				      , p_lpn                    => p_lpn_id
				      , x_ret                    => l_ret_crossdock
				      , x_return_status          => l_return_status
				      , x_msg_count              => l_msg_count
				      , x_msg_data               => l_msg_data
				      , p_move_order_line_id     => l_tmp_mo_lines_tb(l_index).line_id
				      ); -- added for ATF_J

	 IF (l_debug = 1) THEN
	    print_debug('Finisehd calling crossdock API');
	 END IF;

         FOR l_splitted_rec IN (SELECT line_id
                                 ,     primary_quantity
                                 FROM  mtl_txn_request_lines
                                WHERE  reference_detail_id = l_tmp_mo_lines_tb(l_index).line_id) LOOP

   	   IF (l_debug = 1) THEN
	      print_debug('Splitted Line:'||l_splitted_rec.line_id);
	      print_debug('Splitted Qty:'||l_splitted_rec.primary_quantity);
	   END IF;

           l_tmp_index := l_mo_lines_tb.LAST + 1;
           l_mo_lines_tb(l_tmp_index).line_id :=  l_splitted_rec.line_id;
           l_mo_lines_tb(l_tmp_index).prim_qty := l_splitted_rec.primary_quantity;
           l_mo_lines_tb(l_index).prim_qty := l_mo_lines_tb(l_index).prim_qty - l_splitted_rec.primary_quantity;

           BEGIN
             UPDATE mtl_txn_request_lines
              SET  reference_detail_id = NULL
             WHERE line_id = l_splitted_rec.line_id;
           EXCEPTION
             WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                print_debug('Error nulling out mtrl.ref_detail_id. SQLERRM:'||SQLERRM);
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;

         END LOOP;
      END IF;

      EXIT WHEN l_index = l_tmp_mo_lines_tb.LAST;
      l_index := l_tmp_mo_lines_tb.NEXT(l_index);
   END LOOP;
   --END BUG 5194761

   -- Now that we have split the MOLs and created new lines,
   -- we can insert dummy MMTT records tied to the newly split MOLs
   IF (l_debug = 1) THEN
      print_debug('l_tmp_mo_lines_tb.COUNT:'||l_tmp_mo_lines_tb.COUNT);
      print_debug('l_mo_lines_tb.COUNT:'||l_mo_lines_tb.COUNT);
      print_debug('For each move order line, insert a dummy MMTT record');
      print_debug('For each move order line, insert a dummy MMTT record');
   END IF;
   l_index := l_mo_lines_tb.FIRST;
   LOOP
      IF (l_debug = 1) THEN
	 print_debug('Move order line ID: => ' || l_mo_lines_tb(l_index).line_id);
	 print_debug('Primary qty used: ===> ' || l_mo_lines_tb(l_index).prim_qty);
      END IF;
      l_progress := '400';

      -- Update the wms_process_flag for each MOL used so other processes
      -- will not pick up this MOL to use.  This should only be done for
      -- receiving LPNs
      IF (l_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_RCV) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Receiving LPN so update wms_process_flag on the MOL');
	 END IF;
         BEGIN
	    UPDATE mtl_txn_request_lines
	      SET wms_process_flag = 2
	      WHERE line_id = l_mo_lines_tb(l_index).line_id
	      AND organization_id = p_organization_id;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('Exception while setting wms_process_flag for MOLs');
	       END IF;
	 END;
	 IF (l_debug = 1) THEN
	    print_debug('Successfully updated wms_process_flag for MOL');
	 END IF;
	 l_progress := '405';
      END IF;

      -- If a 'From' value is null, set it to the 'To' value and vice versa
      IF ((l_subinv_code IS NULL) AND (l_tosubinv_code IS NOT NULL)) THEN
	 l_subinv_code := l_tosubinv_code;
      END IF;
      IF ((l_locator_id IS NULL) AND (l_tolocator_id IS NOT NULL)) THEN
	 l_locator_id := l_tolocator_id;
      END IF;
      IF ((l_tosubinv_code IS NULL) AND (l_subinv_code IS NOT NULL)) THEN
	 l_tosubinv_code := l_subinv_code;
      END IF;
      IF ((l_tolocator_id IS NULL) AND (l_locator_id IS NOT NULL)) THEN
	 l_tolocator_id := l_locator_id;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('From and To sub/loc info based on LPNs used for MMTT records:');
	 print_debug('From Sub: => ' || l_subinv_code);
	 print_debug('From Loc: => ' || l_locator_id);
	 print_debug('To Sub: ===> ' || l_tosubinv_code);
	 print_debug('To Loc: ===> ' || l_tolocator_id);
      END IF;
      l_progress := '410';

      -- Set the transaction source type, type and action based on the from and to
      -- locations.  If there is a change in sub/loc, then this should be a
      -- sub xfer transaction, otherwise it will be a container split.
      IF ((l_subinv_code <> l_tosubinv_code) OR (l_locator_id <> l_tolocator_id)) THEN
	 -- Sub Xfer transaction
	 IF (l_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_RCV) THEN
	    -- For receiving, the dummy MMTT records should always
	    -- have the container split txn action type.  The call to
	    -- pack_unpack_split and suggestions_pub expects dummy
	    -- non suggestions MMTT records to be of this type for receiving.
	    l_trx_src_type_id := 13;
	    l_trx_type_id := 89;
	    l_trx_action_id := 52;
	  ELSE
	    -- For non receiving scenarios, this should be an inventory
	    -- sub transfer transaction.  For the inventory case, we will
	    -- use the dummy MMTTs and call the TM to transact them.
	    -- The TM will error out if there is a change in sub/loc but
	    -- the transaction type is not an inventory sub xfer.
	    l_trx_src_type_id := 13;
	    l_trx_type_id := 2;
	    l_trx_action_id := 2;
	 END IF;
       ELSE
	 -- Container Split transaction
	 l_trx_src_type_id := 13;
	 l_trx_type_id := 89;
	 l_trx_action_id := 52;
	 -- Null out the xfr sub/loc/org variables since there is no change
	 -- in location.  Do this only for non receiving cases since for
	 -- receiving, the pack_unpack_split API called in process_load
	 -- expects these values to be populated in the dummy MMTT records.
	 -- If these values are not nulled out in the inventory case, the
	 -- TM will error out.
	 IF (l_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_RCV) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Receiving LPN so no need to null out xfer variables');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('Non receiving LPN so null out the xfer variables');
	    END IF;
	    l_tosubinv_code := NULL;
	    l_tolocator_id := NULL;
	    l_xfr_org_id := NULL;
	 END IF;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('Transaction type info');
	 print_debug('Txn Source Type: => ' || l_trx_src_type_id);
	 print_debug('Txn Type: ========> ' || l_trx_type_id);
	 print_debug('Txn Action: ======> ' || l_trx_action_id);
	 print_debug('Transfer transaction info');
	 print_debug('Xfr Sub: =========> ' || l_tosubinv_code);
	 print_debug('Xfr Loc: =========> ' || l_tolocator_id);
	 print_debug('Xfr Org: =========> ' || l_xfr_org_id);
      END IF;
      l_progress := '415';

      -- Now get some additional info from the move order line
      SELECT NVL(txn_source_id, -999), NVL(project_id, -999), NVL(task_id, -999)
	INTO l_txn_src_id, l_project_id, l_task_id
	FROM mtl_txn_request_lines
	WHERE organization_id = p_organization_id
	AND line_id = l_mo_lines_tb(l_index).line_id;
      l_progress := '420';

      -- Reset the values to null if necessary
      IF (l_txn_src_id = -999) THEN
	 l_txn_src_id := NULL;
      END IF;
      IF (l_project_id = -999) THEN
	 l_project_id := NULL;
      END IF;
      IF (l_task_id = -999) THEN
	 l_task_id := NULL;
      END IF;

      IF l_primary_uom_code <> p_uom_code THEN
	 l_trx_qty := inv_rcv_cache.convert_qty(p_inventory_item_id => p_inventory_item_id
						,p_from_qty         => l_mo_lines_tb(l_index).prim_qty
						,p_from_uom_code    => l_primary_uom_code
						,p_to_uom_code      => p_uom_code);
       ELSE
	 l_trx_qty := l_mo_lines_tb(l_index).prim_qty;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('Additional move order line info');
	 print_debug('Txn Source ID: => ' || l_txn_src_id);
	 print_debug('Project ID: ====> ' || l_project_id);
	 print_debug('Task ID: =======> ' || l_task_id);
      END IF;
      l_progress := '430';

      -- Insert a record into MMTT
      l_return := inv_trx_util_pub.insert_line_trx
	(p_trx_hdr_id                 => p_txn_header_id,
	 p_item_id                    => p_inventory_item_id,
	 p_revision                   => p_revision,
	 p_org_id                     => p_organization_id,
	 p_trx_action_id              => l_trx_action_id,
	 p_subinv_code                => l_subinv_code,
	 p_tosubinv_code              => l_tosubinv_code,
	 p_locator_id                 => l_locator_id,
	 p_tolocator_id               => l_tolocator_id,
	 p_xfr_org_id                 => l_xfr_org_id,
	 p_trx_type_id                => l_trx_type_id,
	 p_trx_src_type_id            => l_trx_src_type_id,
	 p_trx_qty                    => l_trx_qty,
	 p_pri_qty                    => l_mo_lines_tb(l_index).prim_qty,
	 p_uom                        => p_uom_code,
    --laks
	 p_secondary_trx_qty          => l_mo_lines_tb(l_index).sec_qty,
	 p_secondary_uom              => l_sec_uom_code,
	 p_date                       => SYSDATE,
	 p_user_id                    => p_user_id,
	 p_cost_group                 => NULL,
	 p_from_lpn_id                => p_lpn_id,
	 p_cnt_lpn_id                 => NULL,
	 p_xfr_lpn_id                 => p_into_lpn_id,
	 p_trx_src_id                 => l_txn_src_id,
	 x_trx_tmp_id                 => l_txn_temp_id,
	 x_proc_msg                   => x_msg_data,
	 p_xfr_cost_group             => NULL,
	 p_project_id                 => l_project_id,
	 p_task_id                    => l_task_id,
	 p_move_order_line_id         => l_mo_lines_tb(l_index).line_id,
	 p_posting_flag               => 'N');

      IF (l_debug = 1) THEN
   	 print_debug('Successfully inserted MMTT record: ' || l_txn_temp_id);
      END IF;
      l_progress := '440';

      -- Check if the API call was successful or not
      IF (l_return <> 0) THEN
	 IF (l_debug = 1) THEN
   	    print_debug('Error occurred while calling inv_trx_util_pub.insert_line_trx');
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_progress := '450';

      -- Bug# 3251237
      -- Dummy MMTT records should have the wms_task_type set to 2 for
      -- putaway transactions.  This is needed by the inventory TM so
      -- it can bypass the call to finalize_pick_confirm.  We should call
      -- the ATF apis instead to update the move order lines.
      UPDATE mtl_material_transactions_temp
	SET wms_task_type = 2
	WHERE transaction_temp_id = l_txn_temp_id
	AND organization_id = p_organization_id;
      IF (l_debug = 1) THEN
	 print_debug('Successfully updated wms_task_type for dummy MMTT record');
      END IF;
      l_progress := '455';

      -- If lot controlled, insert a record into MTLT
      IF (p_lot_number IS NOT NULL) THEN
	 IF (l_debug = 1) THEN
   	    print_debug('Insert a record into MTLT for lot: ' || p_lot_number);
	 END IF;
	 l_return := inv_trx_util_pub.insert_lot_trx
	   (p_trx_tmp_id           => l_txn_temp_id,
	    p_user_id              => p_user_id,
	    p_lot_number           => p_lot_number,
	    p_trx_qty              => l_trx_qty,
	    p_pri_qty              => l_mo_lines_tb(l_index).prim_qty,
       --laks
       p_secondary_qty        => l_mo_lines_tb(l_index).sec_qty,
       p_secondary_uom        => l_sec_uom_code,
	    x_ser_trx_id           => l_ser_trx_id,
	    x_proc_msg             => x_msg_data);
	 IF (l_debug = 1) THEN
   	    print_debug('Successfully inserted MTLT record');
	 END IF;
	 l_progress := '460';

	 IF (l_return <> 0) THEN
	    IF (l_debug = 1) THEN
   	       print_debug('Error occurred while calling inv_trx_util_pub.insert_lot_trx');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
	 l_progress := '470';

	 -- If not serial controlled, don't need the serial txn temp ID
	 IF (p_serial_txn_temp_id IS NULL) THEN
	    -- Update the MTLT record to clear out the serial_transaction_temp_id column
	    -- since insert_lot_trx by default will insert a value for it.
	    UPDATE mtl_transaction_lots_temp
	      SET serial_transaction_temp_id = NULL
	      WHERE transaction_temp_id = l_txn_temp_id;
	    IF (l_debug = 1) THEN
	       print_debug('Cleared out the serial txn temp ID column in MTLT record');
	    END IF;
	    l_progress := '480';
	 END IF;
      END IF;

      -- If serial controlled, insert record(s) into MSNT
      IF (p_serial_txn_temp_id IS NOT NULL) THEN
	 -- If item is serial but not lot controlled, use the MMTT record's
	 -- transaction temp ID, otherwise use the value returned for the
	 -- serial transaction temp ID when inserting MTLT records
	 IF (p_lot_number IS NULL) THEN
	    l_ser_trx_id := l_txn_temp_id;
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('Serial transaction temp ID: ' || l_ser_trx_id);
	 END IF;
	 l_progress := '490';

	 l_mo_line_id := l_mo_lines_tb(l_index).line_id;

	 IF (l_lpn_context = 2) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Insert MSNT records for WIP');
	    END IF;


	    OPEN matched_wip_serials_cursor;
	    LOOP
	       FETCH matched_wip_serials_cursor INTO l_current_serial;
	       EXIT WHEN matched_wip_serials_cursor%NOTFOUND;
	       IF (l_debug = 1) THEN
		  print_debug('Insert a record into MSNT for serial: ' || l_current_serial);
	       END IF;
	       l_progress := '500';

	       l_return := inv_trx_util_pub.insert_ser_trx
		 (p_trx_tmp_id           => l_ser_trx_id,
		  p_user_id              => p_user_id,
		  p_fm_ser_num           => l_current_serial,
		  p_to_ser_num           => l_current_serial,
		  p_quantity             => 1,
		  x_proc_msg             => x_msg_data);
	       IF (l_debug = 1) THEN
		  print_debug('Successfully inserted MSNT record');
	       END IF;
	       l_progress := '510';

	       IF (l_return <> 0) THEN
		  IF (l_debug = 1) THEN
		     print_debug('Error occurred while calling inv_trx_util_pub.insert_ser_trx');
		  END IF;
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	       END IF;
	       l_progress := '520';

	    END LOOP;
	    CLOSE matched_wip_serials_cursor;
	    IF (l_debug = 1) THEN
	       print_debug('Closed the marked_serials_cursor');
	    END IF;
	    l_progress := '530';
	  ELSE --IF l_lpn_context in (3,1)
	    IF (l_debug = 1) THEN
	       print_debug('Insert MSNT records for RCV/INV');
	    END IF;
	    -- Set the move order line variable to be used in the
	    -- matched_mo_serials_cursor to get the marked serials tied to
	    -- this specific MOL
	    FOR j IN 1..l_mol_serial_tb_af_splt(l_mo_line_id).COUNT LOOP

	       l_current_serial := l_mol_serial_tb_af_splt(l_mo_line_id)(j);

	       IF (l_debug = 1) THEN
		  print_debug('Insert a record into MSNT for serial: ' || l_current_serial);
	       END IF;
	       l_progress := '540';

	       l_return := inv_trx_util_pub.insert_ser_trx
		 (p_trx_tmp_id           => l_ser_trx_id,
		  p_user_id              => p_user_id,
		  p_fm_ser_num           => l_current_serial,
		  p_to_ser_num           => l_current_serial,
		  p_quantity             => 1,
		  x_proc_msg             => x_msg_data);
	       IF (l_debug = 1) THEN
		  print_debug('Successfully inserted MSNT record');
	       END IF;
	       l_progress := '550';

	       IF (l_return <> 0) THEN
		  IF (l_debug = 1) THEN
		     print_debug('Error occurred while calling inv_trx_util_pub.insert_ser_trx');
		  END IF;
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	       END IF;
	       l_progress := '560';

	    END LOOP;
	 END IF;--IF l_lpn_context = 2 THEN
      END IF;--IF (p_serial_txn_temp_id IS NOT NULL) THEN

      -- Finished inserting all MMTT, MTLT, and MSNT records
      EXIT WHEN l_index = l_mo_lines_tb.LAST;
      l_index := l_mo_lines_tb.NEXT(l_index);
      l_progress := '580';

   END LOOP;
   IF (l_debug = 1) THEN
      print_debug('Finished inserting dummy MMTT records for all MOLs');
   END IF;
   l_progress := '590';

   IF (l_debug = 1) THEN
      print_debug('***End of pre_process_load***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO pre_process_load_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting pre_process_load - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO pre_process_load_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting pre_process_load - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO pre_process_load_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting pre_process_load - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END pre_process_load;



PROCEDURE process_load
  (p_txn_header_id        IN   NUMBER             ,
   p_serial_txn_temp_id   IN   NUMBER             ,
   p_lpn_context          IN   NUMBER             ,
   p_lpn_id		  IN   NUMBER             ,
   p_into_lpn_id          IN   NUMBER             ,
   p_organization_id      IN   NUMBER             ,
   p_user_id              IN   NUMBER             ,
   p_eqp_ins              IN   VARCHAR2           ,
   x_return_status        OUT  NOCOPY VARCHAR2    ,
   x_msg_count            OUT  NOCOPY NUMBER      ,
   x_msg_data             OUT  NOCOPY VARCHAR2)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'process_load';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     -- Variables used to call Suggestions_PUB and activate_operation_instance
     l_number_of_rows     NUMBER;
     l_crossdock          VARCHAR2(3);
     l_mo_line_id         NUMBER;
     l_error_code         NUMBER;
     l_task_execute_rec   WMS_DISPATCHED_TASKS%ROWTYPE;
     l_emp_id             NUMBER;
     -- Variables used to determine the drop type when calling Suggestions_PUB
     l_drop_type          VARCHAR2(3);
     l_txn_source_type_id NUMBER;
     l_txn_type_id        NUMBER;
     -- Cursor to get MMTT suggestions created by call to Suggestions_PUB.
     -- Make sure we don't pick up dummy pack/unpack MMTT records inserted
     -- by other transactions.  Putaway MMTT suggestions should not be
     -- of type Container Split or Inventory sub transfer.  Putaway
     -- suggestions if in inventory should be of type Move order sub transfers.
     CURSOR mmtt_suggestions_cursor IS
	SELECT transaction_temp_id
	  FROM mtl_material_transactions_temp
	  WHERE organization_id = p_organization_id
	  AND lpn_id = p_lpn_id
	  AND transaction_header_id <> p_txn_header_id
	  AND NOT (transaction_source_type_id = 13 AND
		   transaction_type_id IN (89, 2) AND
		   transaction_action_id IN (52, 2))
	  AND move_order_line_id = l_mo_line_id;
     l_mmtt_temp_id       NUMBER;
     -- Cursor to get move order lines tied to the txn header id
     -- for the dummy pack/unpack MMTT records that were inserted.
     -- These records will be of type container split or inventory
     -- sub transfer.
     CURSOR mo_lines_cursor IS
	SELECT DISTINCT move_order_line_id
	  FROM mtl_material_transactions_temp
	  WHERE organization_id = p_organization_id
	  AND transaction_header_id = p_txn_header_id
	  AND (transaction_source_type_id = 13 AND
	       transaction_type_id IN (89, 2) AND
	       transaction_action_id IN (52, 2))
	  AND move_order_line_id IS NOT NULL
	  ORDER BY move_order_line_id ASC;
     -- Variables used to call validate_operation API
     l_inspection_flag        NUMBER;
     l_load_flag              NUMBER;
     l_drop_flag              NUMBER;
     l_load_prim_quantity     NUMBER;
     l_drop_prim_quantity     NUMBER;
     l_inspect_prim_quantity  NUMBER;
     l_suggestions_created    BOOLEAN;
     -- laks
     l_load_sec_quantity     NUMBER;
     l_drop_sec_quantity     NUMBER;
     l_inspect_sec_quantity  NUMBER;
     -- Variable used for calling pack_unpack_split
     l_mo_lines_tb        inv_rcv_integration_apis.mo_in_tb_tp;
     l_index              NUMBER;
     -- Variable used to store the current receiving txn mode
     l_txn_mode_code          VARCHAR2(25);
     -- Variables used to call the Inventory TM
     l_txn_return_status      NUMBER := 0;
     -- Cursor used to get pack/unpack info for WIP LPNs.
     -- Bug# 3220020
     -- Since the transfer sub/loc fields in the dummy MMTT's are not
     -- populated anymore if there is no change in sub/loc, use an NVL
     -- and pick up the sub/loc in case the xfr sub/loc fields are empty.
     CURSOR wip_pup_cursor IS
	SELECT mmtt.transaction_temp_id,
	  mmtt.inventory_item_id,
	  mmtt.revision,
	  mmtt.subinventory_code,
	  mmtt.locator_id,
	  mmtt.transaction_quantity,
	  mmtt.transaction_uom,
     -- laks
	  mmtt.secondary_transaction_quantity,
	  mmtt.secondary_uom_code,
	  NVL(mmtt.transfer_subinventory, mmtt.subinventory_code),
	  NVL(mmtt.transfer_to_location, mmtt.locator_id),
	  mmtt.cost_group_id,
	  mmtt.lpn_id,
	  mmtt.transfer_lpn_id,
	  mtlt.lot_number,
	  mtlt.serial_transaction_temp_id
	  FROM mtl_material_transactions_temp mmtt,
	  mtl_transaction_lots_temp mtlt
	  WHERE mmtt.organization_id = p_organization_id
	  AND mmtt.transaction_header_id = p_txn_header_id
	  AND (mmtt.transaction_source_type_id = 13 AND
	       mmtt.transaction_type_id IN (89, 2) AND
	       mmtt.transaction_action_id IN (52, 2))
	  AND mmtt.transaction_temp_id = mtlt.transaction_temp_id(+);
     -- Variables used to retrieve info from wip_pup_cursor
     l_inventory_item_id      NUMBER;
     l_revision               VARCHAR2(3);
     l_subinv_code            VARCHAR2(10);
     l_locator_id             NUMBER;
     l_txn_quantity           NUMBER;
     l_txn_uom                VARCHAR2(3);
     -- laks
     l_sec_txn_quantity       NUMBER;
     l_sec_uom                VARCHAR2(3);
     l_to_subinv_code         VARCHAR2(10);
     l_to_locator_id          NUMBER;
     l_cost_group_id          NUMBER;
     l_from_lpn_id            NUMBER;
     l_to_lpn_id              NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number             VARCHAR2(80);
     l_ser_trx_id             NUMBER;
     -- Cursor used to get serial pack/unpack info for WIP LPNs
     CURSOR wip_serial_cursor IS
	SELECT fm_serial_number, to_serial_number
	  FROM mtl_serial_numbers_temp
	  WHERE transaction_temp_id = l_ser_trx_id;
     -- Variables used to retrieve info from wip_serial_cursor
     l_serial_number_ctrl_code   NUMBER;
     l_lot_control_code          NUMBER;
     l_from_serial_number        VARCHAR2(30);
     l_to_serial_number          VARCHAR2(30);
     l_prefix                    VARCHAR2(30);
     l_quantity                  NUMBER;
     l_from_number               NUMBER;
     l_to_number                 NUMBER;
     l_errorcode                 NUMBER;
     -- Variables used to call cleanup_ATF
     l_return_status             VARCHAR2(1);
     l_msg_count                 NUMBER;
     l_msg_data                  VARCHAR2(2500);
     -- Bug# 3446419
     -- Boolean variable indicating if the RCV TM was called yet or not
     l_rcv_tm_called             BOOLEAN := FALSE;
     l_consolidation_method_id   NUMBER;
     l_drop_lpn_option           NUMBER;

     --Bug 4566517
     l_into_sub VARCHAR2(10);
     l_into_loc NUMBER;

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling process_load with the following parameters***');
      print_debug('p_txn_header_id: ======> ' || p_txn_header_id);
      print_debug('p_serial_txn_temp_id: => ' || p_serial_txn_temp_id);
      print_debug('p_lpn_context: ========> ' || p_lpn_context);
      print_debug('p_lpn_id: =============> ' || p_lpn_id);
      print_debug('p_into_lpn_id: ========> ' || p_into_lpn_id);
      print_debug('p_organization_id: ====> ' || p_organization_id);
      print_debug('p_user_id: ============> ' || p_user_id);
      print_debug('p_eqp_ins: ============> ' || p_eqp_ins);
   END IF;

   -- Set the savepoint
   SAVEPOINT process_load_sp;
   l_progress  := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '15';

   -- Set the return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '20';

   -- Get the employee ID so we can populate the l_task_execute_rec
   -- properly when calling activate_operation_instance
   IF (l_debug = 1) THEN
      print_debug('Retrieve the employee ID from the user ID');
   END IF;
   BEGIN
      SELECT employee_id
	INTO l_emp_id
	FROM fnd_user
	WHERE user_id = p_user_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 IF (l_debug = 1) THEN
	    print_debug('There is no employee tied to the user');
	 END IF;
	 l_emp_id := NULL;
   END;
   IF (l_debug = 1) THEN
      print_debug('Employee ID: ' || l_emp_id);
   END IF;
   l_progress := '30';

   -- Set up the WDT record type properly with the necessary values
   l_task_execute_rec.organization_id := p_organization_id;
   l_task_execute_rec.person_id := l_emp_id;
   l_task_execute_rec.equipment_instance := p_eqp_ins;
   l_task_execute_rec.user_task_type := -1;
   l_task_execute_rec.task_type := 2;
   IF (l_debug = 1) THEN
      print_debug('Assigned the necessary values to WDT record type');
   END IF;
   l_progress := '40';

   -- Call Suggestions_PUB for each move order line that is
   -- tied to the transaction header ID passed
   IF (l_debug = 1) THEN
      print_debug('Open the move order lines cursor');
   END IF;
   l_index := 1;
   OPEN mo_lines_cursor;
   LOOP
      FETCH mo_lines_cursor INTO l_mo_line_id;
      EXIT WHEN mo_lines_cursor%NOTFOUND;
      IF (l_debug = 1) THEN
	 print_debug('Current MO line ID: ' || l_mo_line_id);
      END IF;
      l_progress := '50';

      -- Store the move order line found in a table to be used later
      -- on for INV and WIP case when we want to be able to update the
      -- MOL for the LPN ID once we are done processing the dummy MMTT
      -- pack/unpack transaction records.
      l_mo_lines_tb(l_index).line_id := l_mo_line_id;

      -- Set the drop type if this is an Inventory Item Load and the move
      -- order line was created by pre_process_load.  This will be the
      -- case if the transaction source type and transaction type is
      -- Move Order and Subinventory Transfer respectively.
      -- Otherwise just pass in a null value for p_drop_type
      IF (p_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_INV) THEN
	 SELECT NVL(transaction_source_type_id, -999),
	   NVL(transaction_type_id, -999)
	   INTO l_txn_source_type_id, l_txn_type_id
	   FROM mtl_txn_request_lines
	   WHERE line_id = l_mo_line_id;
	 IF (l_debug = 1) THEN
	    print_debug('Move Order Line values');
	    print_debug('Txn Source Type ID: => ' || l_txn_source_type_id);
	    print_debug('Txn Type ID: ========> ' || l_txn_type_id);
	 END IF;
	 l_progress := '55';

	 IF (l_txn_source_type_id = 4 AND l_txn_type_id = 64) THEN
	    l_drop_type := 'IIL';
	 END IF;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('Drop Type: ' || l_drop_type);
      END IF;

      -- Call the Suggestions_PUB API for the current MO line
      IF (l_debug = 1) THEN
	    print_debug('Call the suggestions_pub API');
      END IF;
      WMS_Task_Dispatch_put_away.suggestions_pub
	(p_lpn_id	        =>  p_lpn_id,
	 p_org_id               =>  p_organization_id,
	 p_user_id              =>  p_user_id,
	 p_eqp_ins              =>  p_eqp_ins,
	 x_number_of_rows       =>  l_number_of_rows,
	 x_return_status        =>  x_return_status,
	 x_msg_count            =>  x_msg_count,
	 x_msg_data             =>  x_msg_data,
	 x_crossdock	        =>  l_crossdock,
	 p_status               =>  4,
	 p_check_for_crossdock  => 'Y',
	 p_move_order_line_id   => l_mo_line_id,
	 p_commit               => 'N',
	 p_drop_type            => l_drop_type);

      IF (l_debug = 1) THEN
	 print_debug('Finished calling the suggestions_pub API');
      END IF;
      l_progress := '60';

      -- Check to see if the suggestions_pub API returned successfully
      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Success returned from suggestions_pub API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Failure returned from suggestions_pub API');
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- For each suggestion generated, call the ATF runtime API
      -- to activate the operation instance.  This will generate the
      -- WDT records for the given MMTT suggestion/task
      IF (l_debug = 1) THEN
	 print_debug('Open the MMTT suggestions cursor');
      END IF;
      -- Initialize the suggestion_created boolean variable
      l_suggestions_created := FALSE;
      OPEN mmtt_suggestions_cursor;
      LOOP
	 FETCH mmtt_suggestions_cursor INTO l_mmtt_temp_id;
	 EXIT WHEN mmtt_suggestions_cursor%NOTFOUND;
	 IF (l_debug = 1) THEN
	    print_debug('Current MO line ID: =========> ' || l_mo_line_id);
	    print_debug('Current MMTT suggestion ID: => ' || l_mmtt_temp_id);
	 END IF;
	 l_progress := '70';

	 -- Call the  validate_operation API to see if this MMTT suggestion
	 -- that is tied to the move order line is valid
	 IF (l_debug = 1) THEN
	    print_debug('Call validate_operation API for the given MMTT');
	 END IF;
	 wms_atf_runtime_pub_apis.validate_operation
	   (x_return_status          =>  x_return_status,
	    x_msg_data               =>  x_msg_data,
	    x_msg_count              =>  x_msg_count,
	    x_error_code             =>  l_error_code,
	    x_inspection_flag        =>  l_inspection_flag,
	    x_load_flag              =>  l_load_flag,
	    x_drop_flag              =>  l_drop_flag,
	    x_load_prim_quantity     =>  l_load_prim_quantity,
	    x_drop_prim_quantity     =>  l_drop_prim_quantity,
	    x_inspect_prim_quantity  =>  l_inspect_prim_quantity,
	    p_source_task_id         =>  l_mmtt_temp_id,
	    p_move_order_line_id     =>  l_mo_line_id,
	    p_inventory_item_id      =>  NULL,
	    p_lpn_id                 =>  p_lpn_id,
	    p_activity_type_id       =>  WMS_GLOBALS.G_OP_ACTIVITY_INBOUND,
	    p_organization_id        =>  p_organization_id);

	 IF (l_debug = 1) THEN
	    print_debug('Finished calling the validate_operation API');
	 END IF;
	 l_progress := '75';

	 -- Check to see if the validate_operation API returned successfully
	 IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Success returned from validate_operation API');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('Failure returned from validate_operation API');
	       print_debug('Error code: ' || l_error_code);
	    END IF;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 -- Now check to see if this MMTT suggestion is allowed to be loaded
	 IF (l_debug = 1) THEN
	    print_debug('Values returned from call to validate_operation');
	    print_debug('x_inspection_flag: =======> ' || l_inspection_flag);
	    print_debug('x_load_flag: =============> ' || l_load_flag);
	    print_debug('x_drop_flag: =============> ' || l_drop_flag);
	    print_debug('x_load_prim_quantity: ====> ' || l_load_prim_quantity);
	    print_debug('x_drop_prim_quantity: ====> ' || l_drop_prim_quantity);
	    print_debug('x_inspect_prim_quantity: => ' || l_inspect_prim_quantity);
	 END IF;

	 -- If the MMTT line is valid, then call activate_operation_instance.
	 -- Since we passed in an MMTT source task ID into validate_operation,
	 -- the procedure should either return No Load or Full Load for
	 -- the MMTT suggestion line.
	 IF (l_load_flag = WMS_ATF_RUNTIME_PUB_APIS.G_FULL_LOAD) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Call the activate_operation_instance API');
	    END IF;

	    -- Found a valid MMTT suggestion so set the boolean variable
	    l_suggestions_created := TRUE;

	    -- Set the current move order line ID in the WDT task record
	    l_task_execute_rec.move_order_line_id := l_mo_line_id;

	    wms_atf_runtime_pub_apis.activate_operation_instance
	      (x_return_status     =>  x_return_status,
	       x_msg_data           =>  x_msg_data,
	       x_msg_count          =>  x_msg_count,
	       x_error_code         =>  l_error_code,
	       p_source_task_id     =>  l_mmtt_temp_id,
	       p_activity_id        =>  WMS_GLOBALS.G_OP_ACTIVITY_INBOUND,
	       p_operation_type_id  =>  WMS_GLOBALS.G_OP_TYPE_LOAD,
	       p_task_execute_rec   =>  l_task_execute_rec,
	       x_consolidation_method_id => l_consolidation_method_id,
	       x_drop_lpn_option   => l_drop_lpn_option
	       );

	    IF (l_debug = 1) THEN
	       print_debug('Finished calling the activate_operation_instance API');
	    END IF;
	    l_progress := '80';

	    -- Check to see if the activate_operation_instance API returned successfully
	    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('Success returned from activate_operation_instance API');
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('Failure returned from activate_operation_instance API');
		  print_debug('Error code: ' || l_error_code);
	       END IF;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;

	 END IF;
      END LOOP;
      CLOSE mmtt_suggestions_cursor;
      IF (l_debug = 1) THEN
	 print_debug('Closed the MMTT suggestions cursor');
      END IF;
      l_progress := '90';

      -- Check that suggestions were created for the MOL
      IF (l_suggestions_created) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Suggestions were successfully created for MOL');
	 END IF;
       ELSE
	 -- Unable to load item if no valid suggestions were created
	 IF (l_debug = 1) THEN
	    print_debug('No valid suggestions created for MOL!');
	 END IF;
	 FND_MESSAGE.SET_NAME ('WMS', 'WMS_ALLOCATE_FAIL');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Increment the table index value
      l_index := l_index + 1;
   END LOOP;
   CLOSE mo_lines_cursor;
   IF (l_debug = 1) THEN
      print_debug('Closed the move order lines cursor');
   END IF;
   l_progress := '100';

   -- Receiving LPN item load txn
   IF (p_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_RCV) THEN
      -- Initialize l_mo_lines_tb.  This is used for INV and WIP cases to
      -- store the move order lines used but is not necessary for RCV.
      l_mo_lines_tb.DELETE;

      -- Call the pack_unpack_split API to create RTI records
      -- needed for processing the item load receiving transfer
      IF (l_debug = 1) THEN
	 print_debug('Processing item load for a RCV LPN');
	 print_debug('Call the pack_unpack_split API');
      END IF;

      wms_rcv_pup_pvt.pack_unpack_split
	(p_header_id       =>  p_txn_header_id  ,
	 p_call_rcv_tm     =>  fnd_api.g_false  ,
	 x_return_status   =>  x_return_status  ,
	 x_msg_count       =>  x_msg_count      ,
	 x_msg_data        =>  x_msg_data       ,
	 x_mo_lines_tb     =>  l_mo_lines_tb
	 );
      IF (l_debug = 1) THEN
	 print_debug('Finished calling the pack_unpack_split API');
      END IF;
      l_progress := '110';

      -- Check to see if the call to pack_unpack_split returned successfully
      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Success returned from pack_unpack_split API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Failure returned from pack_unpack_split API');
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_progress := '120';

      -- Finally call the Receiving TM
      IF (l_debug = 1) THEN
	 print_debug('Call the Receiving TM');
      END IF;

      -- Store the original receiving txn mode in a local variable
      l_txn_mode_code := inv_rcv_common_apis.g_po_startup_value.transaction_mode;

      -- Set the receiving txn mode to online
      inv_rcv_common_apis.g_po_startup_value.transaction_mode := 'ONLINE';
      IF (l_debug = 1) THEN
	 print_debug('Temporarily set the RCV transaction mode to ONLINE');
      END IF;
      l_progress := '130';
      --Bug 6944334
      Begin
         print_debug('updating proceesing mode in rti  for group id'||inv_rcv_common_apis.g_rcv_global_var.interface_group_id);
         UPDATE RCV_TRANSACTIONS_INTERFACE
         SET PROCESSING_MODE_CODE =  'ONLINE'
         WHERE GROUP_ID = inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
      EXCEPTION
      WHEN OTHERS THEN
        print_debug('no record found in rti to ');
      END;
      --End of Bug 6944334


      -- Call the receiving TM
      inv_rcv_mobile_process_txn.rcv_process_receive_txn
	(x_return_status   =>  x_return_status,
	 x_msg_data        =>  x_msg_data
	 );

      -- Bug# 3446419
      -- Mark the variable as TRUE to indicate that the RCV TM was called
      -- implying that a commit was done.
      l_rcv_tm_called := TRUE;

      -- Revert the receiving txn mode
      inv_rcv_common_apis.g_po_startup_value.transaction_mode := l_txn_mode_code;
      IF (l_debug = 1) THEN
	 print_debug('Reverted the RCV transaction mode to previous value');
      END IF;
      l_progress := '140';

      -- Call this to clean up the RCV globals
      -- Bug# 3251237: Always call this whether or not the TM call is
      -- successful.  Previously this would not be called in case the
      -- Rcv TM errored out since an exception would be thrown.
      inv_rcv_common_apis.rcv_clear_global;
      IF (l_debug = 1) THEN
	 print_debug('Finished calling rcv_clear_global API');
      END IF;
      l_progress := '150';

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Error calling the Receiving TM!');
	 END IF;
	 FND_MESSAGE.SET_NAME ('WMS', 'WMS_TD_TXNMGR_ERROR');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Successfully called the Receiving TM');
	 END IF;
      END IF;

   END IF;

   -- INV LPN item load txn
   IF (p_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_INV) THEN
      -- Call the INV TM to process the dummy pack/unpack MMTT records
      IF (l_debug = 1) THEN
	 print_debug('Processing item load for an INV LPN');
	 print_debug('Calling the INV TM online: ' || p_txn_header_id);
      END IF;
      -- Call the Inventory TM in online mode (1), passing in the
      -- Inventory business flow code (30)
      l_txn_return_status := inv_lpn_trx_pub.process_lpn_trx
	(p_trx_hdr_id         => p_txn_header_id,
	 p_commit             => fnd_api.g_false,
	 x_proc_msg           => x_msg_data,
	 p_proc_mode          => 1,
	 p_atomic             => fnd_api.g_true,
	 p_business_flow_code => 30);

      -- Check if the Transaction Manager was successful or not
      IF (l_debug = 1) THEN
	 print_debug ('Txn return status: ' || l_txn_return_status);
      END IF;
      l_progress := '160';

      IF (l_txn_return_status <> 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Error calling the Inventory TM');
	 END IF;
	 FND_MESSAGE.SET_NAME ('WMS', 'WMS_TD_TXNMGR_ERROR');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Success calling the Inventory TM');
	 END IF;
      END IF;
   END IF;

   -- WIP LPN item load txn
   IF (p_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_WIP) THEN
      IF (l_debug = 1) THEN
	 print_debug('Processing item load for a WIP LPN');
	 print_debug('Call the PackUnpack_Container API directly');
      END IF;

      -- Open up the wip_pup_cursor to get pack/unpack info
      OPEN wip_pup_cursor;
      LOOP
	 FETCH wip_pup_cursor INTO l_mmtt_temp_id, l_inventory_item_id,
	   l_revision, l_subinv_code, l_locator_id, l_txn_quantity,
	   l_txn_uom, l_sec_txn_quantity, l_sec_uom, l_to_subinv_code, l_to_locator_id, l_cost_group_id,
	   l_from_lpn_id, l_to_lpn_id, l_lot_number, l_ser_trx_id;
	 EXIT WHEN wip_pup_cursor%NOTFOUND;
	 IF (l_debug = 1) THEN
	    print_debug('Current item info for WIP pack/unpack operation');
	    print_debug('Transaction Temp ID: => ' || l_mmtt_temp_id);
	    print_debug('Inventory Item ID: ===> ' || l_inventory_item_id);
	    print_debug('Revision: ============> ' || l_revision);
	    print_debug('Subinventory Code: ===> ' || l_subinv_code);
	    print_debug('Locator ID: ==========> ' || l_locator_id);
	    print_debug('Transaction Qty: =====> ' || l_txn_quantity);
	    print_debug('Transaction UOM: =====> ' || l_txn_uom);
       --laks
	    print_debug('Sec Trnsn Qty:   =====> ' || l_sec_txn_quantity);
	    print_debug('Sec UOM: =============> ' || l_sec_uom);
	    print_debug('To Sub Code: =========> ' || l_to_subinv_code);
	    print_debug('To Locator ID: =======> ' || l_to_locator_id);
	    print_debug('Cost Group ID: =======> ' || l_cost_group_id);
	    print_debug('From LPN ID: =========> ' || l_from_lpn_id);
	    print_debug('To LPN ID: ===========> ' || l_to_lpn_id);
	    print_debug('Lot Number: ==========> ' || l_lot_number);
	    print_debug('Serial Txn Temp ID: ==> ' || l_ser_trx_id);
	 END IF;
	 l_progress := '170';

	 -- Get the lot and serial number control code for the item
	 SELECT serial_number_control_code, lot_control_code
	   INTO l_serial_number_ctrl_code, l_lot_control_code
	   FROM mtl_system_items
	   WHERE inventory_item_id = l_inventory_item_id
	   AND  organization_id = p_organization_id;
	 IF (l_debug = 1) THEN
	    print_debug('Serial Number Code: ' || l_serial_number_ctrl_code);
	    print_debug('Lot Control Code: ' || l_lot_control_code);
	 END IF;
	 l_progress := '180';

	 IF (l_serial_number_ctrl_code IN (1, 6)) THEN
	    -- Not serial controlled

	    -- Call the PackUnpack_Container API directly to first
	    -- unpack the item load material from the source LPN
	    IF (l_debug = 1) THEN
	       print_debug('Unpack the material from the source LPN');
	    END IF;
	    wms_container_pub.PackUnpack_Container
	      (p_api_version   	    =>  1.0,
	       p_validation_level   =>  fnd_api.g_valid_level_none,
	       x_return_status	    =>  x_return_status,
	       x_msg_count	    =>  x_msg_count,
	       x_msg_data	    =>  x_msg_data,
	       p_lpn_id		    =>  l_from_lpn_id,
	       p_content_item_id    =>  l_inventory_item_id,
	       p_revision	    =>  l_revision,
	       p_lot_number	    =>  l_lot_number,
	       p_from_serial_number =>  NULL,
	       p_to_serial_number   =>  NULL,
	       p_quantity           =>	l_txn_quantity,
	       p_uom                =>  l_txn_uom,
          -- laks
	       p_sec_quantity       =>	l_sec_txn_quantity,
	       p_sec_uom            =>  l_sec_uom,
	       p_organization_id    =>  p_organization_id,
	       p_subinventory	    =>  l_subinv_code,
	       p_locator_id	    =>  l_locator_id,
	       p_operation          =>  2,
	       p_cost_group_id      =>  l_cost_group_id);
	    IF (l_debug = 1) THEN
	       print_debug('Finished calling PackUnpack_Container for Unpack operation');
	    END IF;
	    l_progress := '190';

	    -- Check to see if the call to PackUnpack_Container returned successfully
	    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('Success returned from PackUnpack_Container API');
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('Failure returned from PackUnpack_Container API');
	       END IF;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    l_progress := '200';

	    -- Now call the PackUnpack_Container API to pack the loose
	    -- item load material into the destination LPN.
	    -- Since this is in WIP, it should be okay to just pass the
	    -- sub/loc of the source LPN when doing the pack into the
	    -- destination LPN.
	    IF (l_debug = 1) THEN
	       print_debug('Pack the material into the destination LPN');
	    END IF;
	    wms_container_pub.PackUnpack_Container
	      (p_api_version   	    =>  1.0,
	       p_validation_level   =>  fnd_api.g_valid_level_none,
	       x_return_status	    =>  x_return_status,
	       x_msg_count	    =>  x_msg_count,
	       x_msg_data	    =>  x_msg_data,
	       p_lpn_id		    =>  l_to_lpn_id,
	       p_content_item_id    =>  l_inventory_item_id,
	       p_revision	    =>  l_revision,
	       p_lot_number	    =>  l_lot_number,
	       p_from_serial_number =>  NULL,
	       p_to_serial_number   =>  NULL,
	       p_quantity           =>	l_txn_quantity,
	       p_uom                =>  l_txn_uom,
          -- laks
	       p_sec_quantity       =>	l_sec_txn_quantity,
	       p_sec_uom            =>  l_sec_uom,
	       p_organization_id    =>  p_organization_id,
	       p_subinventory	    =>  l_subinv_code,
	       p_locator_id	    =>  l_locator_id,
	       p_operation          =>  1,
	       p_cost_group_id      =>  l_cost_group_id);
	    IF (l_debug = 1) THEN
	       print_debug('Finished calling PackUnpack_Container for Pack operation');
	    END IF;
	    l_progress := '210';

	    -- Check to see if the call to PackUnpack_Container returned successfully
	    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('Success returned from PackUnpack_Container API');
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('Failure returned from PackUnpack_Container API');
	       END IF;
	       FND_MESSAGE.SET_NAME ('WMS', 'WMS_CONT_INVALID_SER');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    l_progress := '220';

	  ELSE
	    -- Serial controlled

	    -- Set the value for the serial txn temp ID
	    IF (l_ser_trx_id IS NULL) THEN
	       l_ser_trx_id := l_mmtt_temp_id;
	    END IF;

	    OPEN wip_serial_cursor;
	    LOOP
	       FETCH wip_serial_cursor INTO l_from_serial_number, l_to_serial_number;
	       EXIT WHEN wip_serial_cursor%NOTFOUND;
	       IF (l_debug = 1) THEN
		  print_debug('Current serials: ' || l_from_serial_number
			      || ' - ' || l_to_serial_number);
	       END IF;
	       l_progress := '230';

	       -- Call this API to parse the serial numbers into prefixes and numbers.
	       -- We need to call this API to get the number of serials in
	       -- the range in case the from and to serial are different.
	       IF (l_debug = 1) THEN
		  print_debug('Call inv_serial_info API to parse the serials');
	       END IF;
	       IF (NOT MTL_Serial_Check.inv_serial_info
		   (p_from_serial_number  =>  l_from_serial_number,
		    p_to_serial_number    =>  l_to_serial_number,
		    x_prefix              =>  l_prefix,
		    x_quantity            =>  l_quantity,
		    x_from_number         =>  l_from_number,
		    x_to_number           =>  l_to_number,
		    x_errorcode           =>  l_errorcode)) THEN
		  IF (l_debug = 1) THEN
		     print_debug('Could not successfully parse the serials!');
		  END IF;
		  FND_MESSAGE.SET_NAME ('WMS', 'WMS_CONT_INVALID_SER');
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	       IF (l_debug = 1) THEN
		  print_debug('Successfully parsed the serials');
		  print_debug('Prefix: ======> ' || l_prefix);
		  print_debug('Quantity: ====> ' || l_quantity);
		  print_debug('From Number: => ' || l_from_number);
		  print_debug('To Number: ===> ' || l_to_number);
		  print_debug('Error Code: ==> ' || l_errorcode);
	       END IF;
	       l_progress := '240';

	       -- Call the PackUnpack_Container API directly to first
	       -- unpack the item load serials from the source LPN.
	       -- The dummy MMTT records are always inserted with the
	       -- item's primary UOM code for the transaction UOM.
	       IF (l_debug = 1) THEN
		  print_debug('Unpack the serials from the source LPN');
	       END IF;
	       wms_container_pub.PackUnpack_Container
		 (p_api_version        =>  1.0,
		  p_validation_level   =>  fnd_api.g_valid_level_none,
		  x_return_status      =>  x_return_status,
		  x_msg_count	       =>  x_msg_count,
		  x_msg_data	       =>  x_msg_data,
		  p_lpn_id	       =>  l_from_lpn_id,
		  p_content_item_id    =>  l_inventory_item_id,
		  p_revision	       =>  l_revision,
		  p_lot_number	       =>  l_lot_number,
		  p_from_serial_number =>  l_from_serial_number,
		  p_to_serial_number   =>  l_to_serial_number,
		  p_quantity           =>  l_quantity,
		  p_uom                =>  l_txn_uom,
		  p_organization_id    =>  p_organization_id,
		  p_subinventory       =>  l_subinv_code,
		  p_locator_id	       =>  l_locator_id,
		  p_operation          =>  2,
		  p_cost_group_id      =>  l_cost_group_id);
	       IF (l_debug = 1) THEN
		  print_debug('Finished calling PackUnpack_Container for Unpack operation');
	       END IF;
	       l_progress := '250';

	       -- Check to see if the call to PackUnpack_Container returned successfully
	       IF (x_return_status = fnd_api.g_ret_sts_success) THEN
		  IF (l_debug = 1) THEN
		     print_debug('Success returned from PackUnpack_Container API');
		  END IF;
		ELSE
		  IF (l_debug = 1) THEN
		     print_debug('Failure returned from PackUnpack_Container API');
		  END IF;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	       l_progress := '260';

	       -- Now call the PackUnpack_Container API to pack the loose
	       -- item load serials into the destination LPN
	       IF (l_debug = 1) THEN
		  print_debug('Pack the serials into the destination LPN');
	       END IF;
	       wms_container_pub.PackUnpack_Container
		 (p_api_version        =>  1.0,
		  p_validation_level   =>  fnd_api.g_valid_level_none,
		  x_return_status      =>  x_return_status,
		  x_msg_count	       =>  x_msg_count,
		  x_msg_data	       =>  x_msg_data,
		  p_lpn_id	       =>  l_to_lpn_id,
		  p_content_item_id    =>  l_inventory_item_id,
		  p_revision	       =>  l_revision,
		  p_lot_number	       =>  l_lot_number,
		  p_from_serial_number =>  l_from_serial_number,
		  p_to_serial_number   =>  l_to_serial_number,
		  p_quantity           =>  l_quantity,
		  p_uom                =>  l_txn_uom,
		  p_organization_id    =>  p_organization_id,
		  p_subinventory       =>  l_subinv_code,
		  p_locator_id         =>  l_locator_id,
		  p_operation          =>  1,
		  p_cost_group_id      =>  l_cost_group_id);
	       IF (l_debug = 1) THEN
		  print_debug('Finished calling PackUnpack_Container for Pack operation');
	       END IF;
	       l_progress := '270';

	       -- Check to see if the call to PackUnpack_Container returned successfully
	       IF (x_return_status = fnd_api.g_ret_sts_success) THEN
		  IF (l_debug = 1) THEN
		     print_debug('Success returned from PackUnpack_Container API');
		  END IF;
		ELSE
		  IF (l_debug = 1) THEN
		     print_debug('Failure returned from PackUnpack_Container API');
		  END IF;
		  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	       l_progress := '280';

	    END LOOP;
	    CLOSE wip_serial_cursor;
	    IF (l_debug = 1) THEN
	       print_debug('Closed the WIP serial cursor');
	    END IF;
	    l_progress := '290';
	 END IF;
	 -- End of serial controlled part

	 -- Delete the dummy MMTT/MTLT/MSNT records once we have processed them
	 IF (l_ser_trx_id IS NOT NULL) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Delete the dummy MSNT records: ' || l_ser_trx_id);
	    END IF;
	    DELETE FROM mtl_serial_numbers_temp
	      WHERE transaction_temp_id = l_ser_trx_id;
	 END IF;

	 IF (l_lot_control_code = 2) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Delete the dummy MTLT records: ' || l_mmtt_temp_id);
	    END IF;
	    DELETE FROM mtl_transaction_lots_temp
	      WHERE transaction_temp_id = l_mmtt_temp_id;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('Delete the dummy MMTT records: ' || l_mmtt_temp_id);
	 END IF;
	 DELETE FROM mtl_material_transactions_temp
	   WHERE transaction_temp_id = l_mmtt_temp_id;

	 IF (l_debug = 1) THEN
	    print_debug('Finished deleting all dummy pack/unpack records');
	 END IF;
	 l_progress := '295';

      END LOOP;
      CLOSE wip_pup_cursor;
      -- Finished processing all MMTT records for transaction header ID
      IF (l_debug = 1) THEN
	 print_debug('Closed the WIP PUP cursor');
      END IF;
      l_progress := '300';

      -- If the Into LPN was dynamically generated, we need to update the
      -- LPN context from 5 (Defined but not used) to 2 (WIP context).
      -- This is done in the INV and RCV TM but for WIP, we do not call a TM
      -- to process the load.  We can always do this update since we will
      -- need to do another query to check the LPN context of the Into LPN.
      -- If the Into LPN was not dynamically generated, it should already
      -- have an LPN context of 2.
      IF (l_debug = 1) THEN
	 print_debug('Update the LPN context for Into LPN');
      END IF;
      BEGIN
	 UPDATE wms_license_plate_numbers
	   SET lpn_context = 2
	   WHERE lpn_id = p_into_lpn_id
	   AND organization_id = p_organization_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Exception while updating LPN context for Into LPN');
	    END IF;
      END;
      IF (l_debug = 1) THEN
	 print_debug('Successfully updated LPN context for Into LPN');
      END IF;
      l_progress := '305';

   END IF;

   -- For INV and WIP LPN item loads, we need to call complete_operation_instance
   -- for each MMTT suggestion record.  Additionally, we need to update the
   -- LPN ID for the MOL and MMTT sugestion records since they still point
   -- to the source LPN ID instead of the destination Into LPN ID.
   -- Finally, we should clear the group mark ID for the serials used if necessary.
   IF ((p_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_WIP) OR
       (p_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_INV)) THEN

      -- For each move order line that is tied to the transaction header
      -- ID, we need to update the LPN ID column to the Into LPN ID.
      IF (l_debug = 1) THEN
	 print_debug('WIP or INV LPN case');
	 print_debug('Need to update the LPN ID and complete the operations');
	 print_debug('Query the move order lines table to update the LPN ID');
      END IF;

      -- First make sure that MOLs were stored in the table
      IF (l_mo_lines_tb.COUNT = 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('No Move order lines were stored in the table!');
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_MO_NOT_FOUND');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Bug 4566517. Get the sub/loc of into lpn
      IF (p_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_INV) THEN
	 BEGIN
	    SELECT subinventory_code
	      , locator_id
	      INTO l_into_sub
	      , l_into_loc
	      FROM wms_license_plate_numbers
	      WHERE lpn_id = p_into_lpn_id;
	 EXCEPTION
	    WHEN OTHERS THEN
	       NULL;
	 END;
      END IF;
      --Bug 4566517 end.

      l_index := l_mo_lines_tb.FIRST;
      LOOP
	 l_mo_line_id := l_mo_lines_tb(l_index).line_id;
	 IF (l_debug = 1) THEN
	    print_debug('Current MO line ID: ' || l_mo_line_id);
	 END IF;
	 l_progress := '320';

	 -- Update the LPN ID in the MOL record
	 IF (l_debug = 1) THEN
	    print_debug('Update the LPN ID/SUB/LOC on MOL record');
	 END IF;
	 BEGIN
	    UPDATE mtl_txn_request_lines
	      SET lpn_id = p_into_lpn_id
	      , from_subinventory_code = Decode(p_lpn_context,
						WMS_CONTAINER_PUB.lpn_context_inv,
						l_into_sub,
						from_subinventory_code)
	      , from_locator_id = Decode(p_lpn_context,
					 WMS_CONTAINER_PUB.lpn_context_inv,
					 l_into_loc,
					 from_locator_id)
	      WHERE line_id = l_mo_line_id
	      AND organization_id = p_organization_id;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('Exception while updating LPN ID/SUB/LOC for MOL');
	       END IF;
	 END;
	 IF (l_debug = 1) THEN
	    print_debug('Successfully updated LPN ID/SUB/LOC on MOL record');
	 END IF;
	 l_progress := '330';

	 -- For each MMTT record tied to the current MOL, we need to call
	 -- the ATF runtime API complete_operation_instance.  This is not
	 -- done in the INV TM for a pack/unpack transaction.  Since we are
	 -- always processing dummy pack/unpack MMTTs for the Inventory
	 -- LPN case, we will need to call complete_operation_instance here
	 -- after the TM is called.  This is also not done for WIP LPNs
	 -- since we call the PackUnpack_Container API directly.
	 IF (l_debug = 1) THEN
	    print_debug('Open the MMTT suggestions cursor');
	 END IF;
	 OPEN mmtt_suggestions_cursor;
	 LOOP
	    FETCH mmtt_suggestions_cursor INTO l_mmtt_temp_id;
	    EXIT WHEN mmtt_suggestions_cursor%NOTFOUND;
	    IF (l_debug = 1) THEN
	       print_debug('Call complete_operation_instance for MMTT: ' || l_mmtt_temp_id);
	    END IF;
	    l_progress := '340';

	    wms_atf_runtime_pub_apis.complete_operation_instance
	      (x_return_status      =>  x_return_status,
	       x_msg_data           =>  x_msg_data,
	       x_msg_count          =>  x_msg_count,
	       x_error_code         =>  l_error_code,
	       p_source_task_id     =>  l_mmtt_temp_id,
	       p_activity_id        =>  WMS_GLOBALS.G_OP_ACTIVITY_INBOUND,
	       p_operation_type_id  =>  WMS_GLOBALS.G_OP_TYPE_LOAD);

	    IF (l_debug = 1) THEN
	       print_debug('Finished calling the complete_operation_instance API');
	    END IF;
	    l_progress := '350';

	    -- Check to see if the complete_operation_instance API returned successfully
	    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('Success returned from complete_operation_instance API');
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('Failure returned from complete_operation_instance API');
		  print_debug('Error code: ' || l_error_code);
	       END IF;
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;

	    -- Update the LPN ID and Allocated LPN ID in the MMTT record
	    IF (l_debug = 1) THEN
	       print_debug('Update the LPN ID/sub/loc on MMTT record');
	    END IF;
	    BEGIN
	       UPDATE mtl_material_transactions_temp
		 SET lpn_id = p_into_lpn_id
		 , allocated_lpn_id = p_into_lpn_id
		 , subinventory_code = Decode(p_lpn_context,
					      WMS_CONTAINER_PUB.lpn_context_inv,
					      l_into_sub,
					      subinventory_code)
		 , locator_id = Decode(p_lpn_context,
				       WMS_CONTAINER_PUB.lpn_context_inv,
				       l_into_loc,
				       locator_id)
		 WHERE transaction_temp_id = l_mmtt_temp_id
		 AND organization_id = p_organization_id;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('Exception while updating LPN ID/sub/loc for MMTT');
		  END IF;
	    END;
	    IF (l_debug = 1) THEN
	       print_debug('Successfully updated LPN ID/sub/loc on MMTT record');
	    END IF;
	    l_progress := '360';

	 END LOOP;
	 CLOSE mmtt_suggestions_cursor;
	 IF (l_debug = 1) THEN
	    print_debug('Closed the MMTT suggestions cursor');
	 END IF;
	 l_progress := '370';

	 -- Exit if all move order lines in the table have been used
	 EXIT WHEN l_index = l_mo_lines_tb.LAST;
	 l_index := l_mo_lines_tb.NEXT(l_index);

      END LOOP;
      IF (l_debug = 1) THEN
	 print_debug('Finished processing the move order lines table');
      END IF;
      l_progress := '380';

      -- Clear the serials that were marked during load if necessary
      IF (p_serial_txn_temp_id IS NOT NULL) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Clear the group mark ID for the marked serials');
	 END IF;
	 BEGIN
	    UPDATE mtl_serial_numbers
	      SET group_mark_id = NULL
	      WHERE current_organization_id = p_organization_id
	      AND group_mark_id = p_serial_txn_temp_id
	      AND EXISTS (SELECT 1
			  FROM mtl_serial_numbers_temp
			  WHERE transaction_temp_id = p_serial_txn_temp_id
			  AND serial_number BETWEEN fm_serial_number AND
			  to_serial_number);
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('Exception while clearing group mark ID');
	       END IF;
	 END;
	 l_progress := '310';
      END IF;

   END IF;
   -- Done with INV/WIP case for updating of MOL and MMTT records for the
   -- LPN ID columns, calling complete_operation_instance for MMTT suggestions
   -- and clearing the group mark ID for serials used if necessary.

   -- If a serial txn temp ID is passed, delete the temporary MSNT records
   -- used when marking serials from the java side.  This should be done
   -- for all cases, i.e. RCV, INV, and WIP.
   IF (p_serial_txn_temp_id IS NOT NULL) THEN
      IF (l_debug = 1) THEN
	 print_debug('Delete the temporary MSNT records');
      END IF;
      BEGIN
	 DELETE FROM mtl_serial_numbers_temp
	   WHERE transaction_temp_id = p_serial_txn_temp_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Exception while deleting temporary MSNT records');
	    END IF;
      END;
      l_progress := '390';
   END IF;

   IF (l_debug = 1) THEN
      print_debug('***End of process_load***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      -- Call the cleanup_ATF procedure since the call to
      -- activate_operation_instance in process_load will insert records
      -- into WDT and commit them autonomously.  A rollback will not
      -- remove those records.
      -- Bug# 3446419
      -- Also pass in a parameter indicating if the RCV TM was called or not.
      cleanup_ATF
	(p_txn_header_id    =>  p_txn_header_id,
	 p_lpn_context      =>  p_lpn_context,
	 p_lpn_id	    =>  p_lpn_id,
	 p_organization_id  =>  p_organization_id,
	 p_rcv_tm_called    =>  l_rcv_tm_called,
	 x_return_status    =>  l_return_status,
	 x_msg_count        =>  l_msg_count,
	 x_msg_data         =>  l_msg_data);

      -- Check to see if the cleanup_ATF API returned successfully
      IF (l_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Success returned from cleanup_ATF API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Failure returned from cleanup_ATF API');
	 END IF;
	 -- Nothing we can do if the cleanup API's fail.
      END IF;

      BEGIN
	 ROLLBACK TO process_load_sp;
      EXCEPTION
	 WHEN OTHERS THEN
	    -- This implies that a commit was done which should only happen
	    -- if the RCV TM was called and it errored out
	    IF (l_debug = 1) THEN
	       print_debug('Exception while rolling back to save point');
	    END IF;
      END;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting process_load - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      -- Call the cleanup_ATF procedure since the call to
      -- activate_operation_instance in process_load will insert records
      -- into WDT and commit them autonomously.  A rollback will not
      -- remove those records.
      -- Bug# 3446419
      -- Also pass in a parameter indicating if the RCV TM was called or not.
      cleanup_ATF
	(p_txn_header_id    =>  p_txn_header_id,
	 p_lpn_context      =>  p_lpn_context,
	 p_lpn_id	    =>  p_lpn_id,
	 p_organization_id  =>  p_organization_id,
	 p_rcv_tm_called    =>  l_rcv_tm_called,
	 x_return_status    =>  l_return_status,
	 x_msg_count        =>  l_msg_count,
	 x_msg_data         =>  l_msg_data);

      -- Check to see if the cleanup_ATF API returned successfully
      IF (l_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Success returned from cleanup_ATF API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Failure returned from cleanup_ATF API');
	 END IF;
	 -- Nothing we can do if the cleanup API's fail.
      END IF;

      BEGIN
	 ROLLBACK TO process_load_sp;
      EXCEPTION
	 WHEN OTHERS THEN
	    -- This implies that a commit was done which should only happen
	    -- if the RCV TM was called and it errored out
	    IF (l_debug = 1) THEN
	       print_debug('Exception while rolling back to save point');
	    END IF;
      END;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting process_load - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      -- Call the cleanup_ATF procedure since the call to
      -- activate_operation_instance in process_load will insert records
      -- into WDT and commit them autonomously.  A rollback will not
      -- remove those records.
      -- Bug# 3446419
      -- Also pass in a parameter indicating if the RCV TM was called or not.
      cleanup_ATF
	(p_txn_header_id    =>  p_txn_header_id,
	 p_lpn_context      =>  p_lpn_context,
	 p_lpn_id	    =>  p_lpn_id,
	 p_organization_id  =>  p_organization_id,
	 p_rcv_tm_called    =>  l_rcv_tm_called,
	 x_return_status    =>  l_return_status,
	 x_msg_count        =>  l_msg_count,
	 x_msg_data         =>  l_msg_data);

      -- Check to see if the cleanup_ATF API returned successfully
      IF (l_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Success returned from cleanup_ATF API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Failure returned from cleanup_ATF API');
	 END IF;
	 -- Nothing we can do if the cleanup API's fail.
      END IF;

      BEGIN
	 ROLLBACK TO process_load_sp;
      EXCEPTION
	 WHEN OTHERS THEN
	    -- This implies that a commit was done which should only happen
	    -- if the RCV TM was called and it errored out
	    IF (l_debug = 1) THEN
	       print_debug('Exception while rolling back to save point');
	    END IF;
      END;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting process_load - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END process_load;


PROCEDURE unmark_serials
  (p_serial_txn_temp_id   IN   NUMBER              ,
   p_organization_id      IN   NUMBER              ,
   p_inventory_item_id    IN   NUMBER              ,
   x_return_status        OUT  NOCOPY VARCHAR2     ,
   x_msg_count            OUT  NOCOPY NUMBER       ,
   x_msg_data             OUT  NOCOPY VARCHAR2)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'unmark_serials';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling unmark_serials with the following parameters***');
      print_debug('p_serial_txn_temp_id: => ' || p_serial_txn_temp_id);
      print_debug('p_organization_id: ====> ' || p_organization_id);
      print_debug('p_inventory_item_id: ==> ' || p_inventory_item_id);
   END IF;

   -- Set the savepoint
   SAVEPOINT unmark_serials_sp;
   l_progress  := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Set the return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- Reset the group mark ID for all marked serials
   IF (l_debug = 1) THEN
      print_debug('Clear the group mark ID for the marked serials');
   END IF;
   BEGIN
      UPDATE mtl_serial_numbers
	SET group_mark_id = NULL
	WHERE inventory_item_id = p_inventory_item_id
	AND current_organization_id = p_organization_id
	AND group_mark_id = p_serial_txn_temp_id
	AND EXISTS (SELECT 1
		    FROM mtl_serial_numbers_temp
		    WHERE transaction_temp_id = p_serial_txn_temp_id
		    AND serial_number BETWEEN fm_serial_number AND
		    to_serial_number);
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception while clearing group mark ID');
	 END IF;
   END;
   l_progress := '40';

   IF (l_debug = 1) THEN
      print_debug('Delete the temporary MSNT records');
   END IF;
   BEGIN
      DELETE FROM mtl_serial_numbers_temp
	WHERE transaction_temp_id = p_serial_txn_temp_id;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception while deleting temporary MSNT records');
	 END IF;
   END;
   l_progress := '50';

   IF (l_debug = 1) THEN
      print_debug('***End of unmark_serials***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO unmark_serials_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting unmark_serials - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO unmark_serials_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting unmark_serials - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO unmark_serials_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting unmark_serials - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END unmark_serials;


PROCEDURE cleanup_ATF
  (p_txn_header_id        IN   NUMBER              ,
   p_lpn_context          IN   NUMBER              ,
   p_lpn_id		  IN   NUMBER              ,
   p_organization_id      IN   NUMBER              ,
   p_rcv_tm_called        IN   BOOLEAN             ,
   x_return_status        OUT  NOCOPY VARCHAR2     ,
   x_msg_count            OUT  NOCOPY NUMBER       ,
   x_msg_data             OUT  NOCOPY VARCHAR2)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'cleanup_ATF';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_mmtt_temp_id       NUMBER;
     l_error_code         NUMBER;
     -- This cursor will get all of the MMTT suggestionss associated with the lpn_id passed.
     -- Cleanup should not be called if there are no WDT records.
     CURSOR mmtt_suggestions_cursor IS
	SELECT mmtt.transaction_temp_id
	  FROM mtl_material_transactions_temp mmtt,
	  mtl_txn_request_lines mtrl,
	  wms_dispatched_tasks wdt
	  WHERE mmtt.organization_id = p_organization_id
	  AND mmtt.transaction_temp_id = wdt.transaction_temp_id
	  AND wdt.task_type = 2
	  AND wdt.organization_id = p_organization_id
	  AND wdt.move_order_line_id = mtrl.line_id
	  AND mtrl.line_id = mmtt.move_order_line_id
	  AND mtrl.line_status = 7
	  AND mtrl.organization_id = p_organization_id
	  AND mtrl.lpn_id = p_lpn_id;

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling cleanup_ATF with the following parameters***');
      print_debug('p_txn_header_id: ===> ' || p_txn_header_id);
      print_debug('p_lpn_context: =====> ' || p_lpn_context);
      print_debug('p_lpn_id: ==========> ' || p_lpn_id);
      print_debug('p_organization_id: => ' || p_organization_id);
   END IF;

   -- Set the savepoint
   SAVEPOINT cleanup_ATF_sp;
   l_progress  := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Set the return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- Get all of the MMTT suggestions created so we can
   -- cleanup the operation instance for it.  Note that for the
   -- non-receiving case, the only thing that is not cleaned up
   -- properly is the insertion of WDT records.  Everything else is
   -- rolled back for the non-receiving case since no commit is done.
   -- However the autonomous commit done when calling
   -- activate_operation_instance prevents us from rolling that change back.
   -- In the receiving case, we will call the ATF runtime API
   -- cleanup_operation_instance to cleanup the data since we are unable
   -- to perform a rollback.
   OPEN mmtt_suggestions_cursor;
   LOOP
      FETCH mmtt_suggestions_cursor INTO l_mmtt_temp_id;
      EXIT WHEN mmtt_suggestions_cursor%NOTFOUND;

      IF (p_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_RCV) THEN
	 -- Receiving case so call cleanup_operation_instance
	 IF (l_debug = 1) THEN
	    print_debug('Call cleanup_operation_instance for MMTT: ' || l_mmtt_temp_id);
	 END IF;
	 l_progress := '40';

	 wms_atf_runtime_pub_apis.cleanup_operation_instance
	   (p_source_task_id     =>  l_mmtt_temp_id,
	    p_activity_type_id   =>  WMS_GLOBALS.G_OP_ACTIVITY_INBOUND,
	    x_return_status      =>  x_return_status,
	    x_msg_data           =>  x_msg_data,
	    x_msg_count          =>  x_msg_count,
	    x_error_code         =>  l_error_code);

	 IF (l_debug = 1) THEN
	    print_debug('Finished calling the cleanup_operation_instance API');
	 END IF;
	 l_progress := '50';

	 -- Check to see if the cleanup_operation_instance API returned successfully
	 IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Success returned from cleanup_operation_instance API');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('Failure returned from cleanup_operation_instance API');
	       print_debug('Error code: ' || l_error_code);
	    END IF;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
       ELSE
	 -- Non-receiving case so call delete_dispatched_task
	 IF (l_debug = 1) THEN
	    print_debug('Call delete_dispatched_task for MMTT: ' || l_mmtt_temp_id);
	 END IF;
	 l_progress := '60';

	 wms_op_runtime_pvt_apis.delete_dispatched_task
	   (p_source_task_id     =>  l_mmtt_temp_id,
	    p_wms_task_type      =>  WMS_GLOBALS.G_WMS_TASK_TYPE_PUTAWAY,
	    x_return_status      =>  x_return_status,
	    x_msg_count          =>  x_msg_count,
	    x_msg_data           =>  x_msg_data);

	 IF (l_debug = 1) THEN
	    print_debug('Finished calling the delete_dispatched_task API');
	 END IF;
	 l_progress := '70';

	 -- Check to see if the delete_dispatched_task API returned successfully
	 IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Success returned from delete_dispatched_task API');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('Failure returned from delete_dispatched_task API');
	    END IF;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;

   END LOOP;
   CLOSE mmtt_suggestions_cursor;
   IF (l_debug = 1) THEN
      print_debug('Closed the MMTT suggestions cursor');
   END IF;
   l_progress := '80';

   -- For the receiving case, we need to commit the changes done in the
   -- call to cleanup_operation_instance.  Since we do not rely on a
   -- rollback to clean up data for receiving, a commit should be okay.
   -- A commit is done already prior to calling the receiving TM.  Thus we
   -- cannot rely on rollbacks since all savepoints have been deleted.
   -- Bug# 3446419
   -- Perform the commit only if the RCV TM was called and it errored out
   -- there.  In that case, we can assume that a commit was already done.
   -- We will need to commit here for the cleanup changes to be saved.
   -- Otherwise if there was an error earlier, like in the call to
   -- wms_rcv_pup_pvt.pack_unpack_split, we can still rely on the rollback
   -- to clean up the data.  There would be no need to commit here.
   IF (p_lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_RCV AND p_rcv_tm_called) THEN
      COMMIT;
   END IF;
   l_progress := '90';

   IF (l_debug = 1) THEN
      print_debug('***End of cleanup_ATF***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO cleanup_ATF_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting cleanup_ATF - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO cleanup_ATF_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting cleanup_ATF - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO cleanup_ATF_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting cleanup_ATF - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END cleanup_ATF;


END wms_item_load;


/
