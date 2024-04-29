--------------------------------------------------------
--  DDL for Package Body INV_RCV_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_AVAILABILITY" AS
/* $Header: INVRCVAB.pls 120.4 2006/06/05 22:50:31 mankuma noship $*/

PROCEDURE print_debug(p_err_msg VARCHAR2
		      ,p_module IN VARCHAR2 := ' '
		      ,p_level NUMBER := 4)
  IS
     l_debug NUMBER;
BEGIN
   l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg
      ,p_module => 'inv_rcv_availability'
      ,p_level => p_level);
END;

PROCEDURE get_available_supply_demand(
				      x_return_status             OUT NOCOPY    VARCHAR2,
				      x_msg_count                 OUT NOCOPY    NUMBER,
				      x_msg_data                  OUT NOCOPY    VARCHAR2,
				      x_available_quantity        OUT NOCOPY    NUMBER,
				      x_source_uom_code           OUT NOCOPY    VARCHAR2,
				      x_source_primary_uom_code   OUT NOCOPY    VARCHAR2,
				      p_supply_demand_code        IN            NUMBER,
				      p_organization_id           IN            NUMBER,
				      p_item_id                   IN            NUMBER,
				      p_revision                  IN            VARCHAR2,
				      p_lot_number                IN            VARCHAR2,
				      p_subinventory_code         IN            VARCHAR2,
				      p_locator_id                IN            NUMBER,
				      p_supply_demand_type_id     IN            NUMBER,
				      p_supply_demand_header_id   IN            NUMBER,
				      p_supply_demand_line_id     IN            NUMBER,
				      p_supply_demand_line_detail IN            NUMBER,
  p_lpn_id                    IN            NUMBER,
  p_project_id                IN            NUMBER,
  p_task_id                   IN            NUMBER,
  p_api_version_number        IN            NUMBER,
  p_init_msg_lst              IN            VARCHAR2
  ) IS
     l_debug                    NUMBER ;
     l_progress                 VARCHAR2(10);
     l_module_name              VARCHAR2(30);

     l_rti_primary_quantity NUMBER;
     l_mol_primary_qty NUMBER;
     l_supply_prim_qty NUMBER;

BEGIN

   l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_progress := '10';
   l_module_name := 'get_available_supply_demand';

   IF (l_debug = 1) THEN
      print_debug('Entering inv_rcv_availability',l_module_name,11);
      print_debug('  p_supply_demand_code       => '||        p_supply_demand_code);
      print_debug('  p_organization_id          => '||           p_organization_id);
      print_debug('  p_item_id                  => '||                   p_item_id);
      print_debug('  p_revision                => '||                  p_revision);
      print_debug('  p_lot_number               => '||                p_lot_number);
      print_debug('  p_subinventory_code        => '||         p_subinventory_code);
      print_debug('  p_locator_id               => '||                p_locator_id);
      print_debug('  p_supply_demand_type_id    => '||     p_supply_demand_type_id);
      print_debug('  p_supply_demand_header_id  => '||   p_supply_demand_header_id);
      print_debug('  p_supply_demand_line_id    => '||     p_supply_demand_line_id);
      print_debug('  p_supply_demand_line_detail=> '|| p_supply_demand_line_detail);
      print_debug('  p_lpn_id                   => '|| p_lpn_id);
      print_debug('  p_project_id               => '|| p_project_id);
      print_debug('  p_task_id                  => '|| p_task_id);
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   --Query the total on hand quantity in receiving.

   BEGIN
      SELECT Nvl(SUM(rs.to_org_primary_quantity),0)
	INTO l_supply_prim_qty
	FROM rcv_supply rs
	, rcv_transactions rt
	WHERE rs.supply_source_id = rt.transaction_id
	AND rs.supply_type_code = 'RECEIVING'
	AND rs.to_organization_id = p_organization_id
	AND rs.item_id = p_item_id

	--10/04/05: Reservations are not created on the revision level, so
	--when availability API is called, revision maybe NULL.  In
	--that case, don't use revision as a query criteria
	AND Nvl(rs.item_revision,'*&@') = Nvl(p_revision,Nvl(rs.item_revision,'*&@'));
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception occurred at progress:'||l_progress,l_module_name,11);
	    print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,11);
	 END IF;
	 l_supply_prim_qty := 0;
   END;

   IF (l_debug = 1) THEN
      print_debug('l_supply_prim_qty:'||l_supply_prim_qty);
   END IF;

   l_progress := '20';

   --Query the total MOL quantity which is being crossdocked to wip

   BEGIN
      SELECT Nvl(SUM((quantity-Nvl(quantity_delivered,0))*primary_quantity/quantity),0)
	INTO l_mol_primary_qty
	FROM mtl_txn_request_lines mtrl
	, mtl_txn_request_headers mtrh
	WHERE mtrh.header_id = mtrl.header_id
	AND mtrh.move_order_type = 6
	AND mtrl.organization_id = p_organization_id
	AND mtrl.inventory_item_id = p_item_id

	--10/04/05: Reservations are not created on the revision level, so
	--when availability API is called, revision maybe NULL.  In
	--that case, don't use revision as a query criteria
	AND Nvl(mtrl.revision,'@#@') = Nvl(p_revision,Nvl(mtrl.revision,'@#@'))
	AND Nvl(mtrl.crossdock_type, -1) = 2
	AND mtrl.line_status = 7
	AND mtrl.quantity - Nvl(mtrl.quantity_delivered,0) > 0;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception occurred at progress:'||l_progress,l_module_name,11);
	    print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,11);
	 END IF;
	 l_mol_primary_qty := 0;
   END;

   IF (l_debug = 1) THEN
      print_debug('l_mol_primary_qty:'||l_mol_primary_qty);
   END IF;

   --Must subtract the transaction quantity for pending
   --deliver/return to vendor/correction transactions

   BEGIN
      SELECT Nvl(ABS(SUM(primary_quantity)),0)
	INTO l_rti_primary_quantity
	FROM rcv_transactions_interface rti
	WHERE to_organization_id = p_organization_id
	AND item_id = p_item_id

	--10/04/05: Reservations are not created on the revision level, so
	--when availability API is called, revision maybe NULL.  In
	--that case, don't use revision as a query criteria
	AND NVL(item_revision, '@@@') = NVL(p_revision,NVL(item_revision, '@@@'))
	AND rti.processing_status_code <> 'ERROR'
	AND rti.transaction_status_code <> 'ERROR'
	AND NOT exists (SELECT '1' FROM rcv_transactions rt
			WHERE rt.interface_transaction_id = rti.interface_transaction_id)
	AND (TRANSACTION_TYPE = 'DELIVER'
	     OR (TRANSACTION_TYPE IN ('RETURN TO VENDOR','RETURN TO CUSTOMER')
		 AND EXISTS (SELECT '1' FROM rcv_transactions rt
			     WHERE rt.transaction_id = rti.parent_transaction_id
			     AND rt.transaction_type IN ('RECEIVE','ACCEPT','REJECT','TRANSFER')))
	     OR (TRANSACTION_TYPE IN ('CORRECT')
		 AND quantity < 0
		 AND EXISTS (SELECT '1' FROM rcv_transactions rt
			     WHERE rt.transaction_id = rti.parent_transaction_id
			     AND rt.transaction_type IN ('RECEIVE')))
	     OR (TRANSACTION_TYPE IN ('CORRECT')
		 AND quantity > 0
		 AND EXISTS (SELECT '1' FROM rcv_transactions rt
			     WHERE rt.transaction_id = rti.parent_transaction_id
			     AND rt.transaction_type IN ('DELIVER'))));
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception occurred at progress:'||l_progress,l_module_name,11);
	    print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,11);
	 END IF;
	 l_rti_primary_quantity := 0;
   END;

   IF (l_debug = 1) THEN
      print_debug('l_rti_primary_quantity:'||l_rti_primary_quantity);
   END IF;

   x_available_quantity := l_supply_prim_qty - l_mol_primary_qty - l_rti_primary_quantity;

   BEGIN
      SELECT primary_uom_code
	INTO x_source_primary_uom_code
	FROM mtl_system_items
	WHERE organization_id = p_organization_id
	AND inventory_item_id = p_item_id;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('Exception occurred at progress:'||l_progress,l_module_name,11);
	    print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,11);
	 END IF;
   END;

   x_source_uom_code := x_source_primary_uom_code;

   IF (l_debug = 1) THEN
      print_debug('Exitting get_available_supply_demand with success',l_module_name,11);
      print_debug('x_available_quantity = '||x_available_quantity,l_module_name,11);
      print_debug('x_source_uom_code    = '||x_source_uom_code,l_module_name,11);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress:'||l_progress,l_module_name,11);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_module_name,11);
      END IF;
      x_return_status :=  fnd_api.g_ret_sts_error;
END get_available_supply_demand;
END inv_rcv_availability;

/
