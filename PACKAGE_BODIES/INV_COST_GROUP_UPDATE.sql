--------------------------------------------------------
--  DDL for Package Body INV_COST_GROUP_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_COST_GROUP_UPDATE" AS
/* $Header: INVCGUPB.pls 120.6.12010000.4 2009/07/21 23:25:20 mchemban ship $*/
g_pkg_name   varchar2(100) := 'INV_COST_GROUP_UPDATE';

g_corrupt_cg_error VARCHAR2(1) := 'C';

CURSOR cur_mtlt (p_transaction_temp_id NUMBER) IS
   SELECT mtlt.ROWID mtlt_rowid,
          mtlt.*
     FROM mtl_transaction_lots_temp mtlt
     WHERE mtlt.transaction_temp_id = p_transaction_temp_id;

CURSOR cur_msnt(cp_transaction_temp_id NUMBER) IS
   SELECT msnt.* ,
          msnt.ROWID  msnt_rowid
     FROM mtl_serial_numbers_temp msnt
     WHERE transaction_temp_id  =  cp_transaction_temp_id;

CURSOR cur_msn(cp_fm_serial_number     VARCHAR2,
	       cp_to_serial_number     VARCHAR2,
	       cp_inventory_item_id    NUMBER,
	       cp_organization_id      NUMBER,
	       cp_prefix               VARCHAR2,
	       cp_length               NUMBER)
  IS
     SELECT cost_group_id,
            serial_number
       FROM mtl_serial_numbers
       WHERE serial_number
       BETWEEN cp_fm_serial_number AND Nvl(cp_to_serial_number, cp_fm_serial_number)
       AND Length(serial_number)=cp_length
       AND serial_number LIKE (cp_prefix||'%')
       AND inventory_item_id       = cp_inventory_item_id
       AND current_organization_id = cp_organization_id;

procedure print_debug(p_message in VARCHAR2) IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
   IF (l_debug = 1) THEN
      inv_log_util.trace(p_message, 'INV_COST_GROUP_UPDATE', 9);
   END IF;
end;

PROCEDURE proc_update_mmtt(p_transaction_temp_id       IN  NUMBER,
			   p_transfer_wms_org          IN  BOOLEAN,
			   p_fob_point                 IN  NUMBER,
			   p_tfr_primary_cost_method   IN  NUMBER,
			   p_tfr_org_cost_group_id     IN  NUMBER,
			   p_transaction_action_id     IN  NUMBER,
			   p_transfer_organization     IN  NUMBER := NULL,
			   p_transfer_subinventory     IN  VARCHAR2,
			   p_cost_group_id             IN  NUMBER,
			   p_transfer_cost_group_id    IN  NUMBER,
			   p_primary_quantity          IN  NUMBER :=  NULL,
			   p_transaction_quantity      IN  NUMBER :=  NULL,
			   p_from_project_id           IN  NUMBER := NULL,
			   p_to_project_id             IN  NUMBER := NULL,
			   x_return_status             OUT NOCOPY VARCHAR2)
IS
   l_transfer_cost_group_id   NUMBER      :=  NULL;
   x_valid                    VARCHAR2(1) := 'Y';

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('in proc_update_mmtt .. p_transaction_temp_id : '|| p_transaction_temp_id );
      print_debug('in proc_update_mmtt .. p_cost_group_id : '|| p_cost_group_id );
      print_debug('in proc_update_mmtt .. p_transaction_action_id : '|| p_transaction_action_id );
      print_debug('in proc_update_mmtt .. p_transfer_organization : '|| p_transfer_organization );
   END IF;
   x_return_status := fnd_api.g_ret_sts_success;

   IF p_transaction_action_id IN (inv_globals.g_action_subxfr,
				  inv_globals.g_action_stgxfr,
				  inv_globals.g_action_ownxfr)
                                  -- Subtransfer, staging transfer
   THEN
      l_transfer_cost_group_id := p_cost_group_id;
    ELSE
      l_transfer_cost_group_id := p_transfer_cost_group_id;
   END IF;

   IF p_transaction_Action_id = inv_globals.g_action_intransitshipment THEN
      IF NOT p_transfer_wms_org AND p_fob_point = 1 THEN -- shipment
	 -- We don't care about the costing method of the org
	 l_transfer_cost_group_id := p_tfr_org_cost_group_id;
	 IF (l_debug = 1) THEN
   	 print_debug('default cost group of org ' ||  p_transfer_organization || ' : ' || l_transfer_cost_group_id);
	 END IF;
       ELSIF p_fob_point = 2 THEN -- receipt
	 l_transfer_cost_group_id := p_cost_group_id;
      END IF;
   END IF;

   IF(p_from_project_id IS NULL AND
      p_to_project_id IS NOT NULL AND
      p_transaction_action_id IN (inv_globals.g_action_subxfr,
				  inv_globals.g_action_stgxfr,
				  inv_globals.G_Action_Receipt)) then

      IF (l_debug = 1) THEN
         print_debug('updating the transfer_cost_group to null as the dest'|| 'locator is proj enabled');
      END IF;
      l_transfer_cost_group_id := NULL;

   END IF;



      IF (l_debug = 1) THEN
         print_debug('proc_update_mmtt .. l_transfer_cost_group_id: ' ||
                                               l_transfer_cost_group_id || ':' );
      END IF;
   UPDATE mtl_material_transactions_temp
   SET cost_group_id           = Nvl(p_cost_group_id, cost_group_id),
       transfer_cost_group_id  = Nvl(l_transfer_cost_group_id, transfer_cost_group_id),
       primary_quantity        = Nvl(p_primary_quantity, primary_quantity),
       transaction_quantity    = Nvl(p_transaction_quantity, transaction_quantity)
   WHERE transaction_temp_id = p_transaction_temp_id;
   IF (SQL%NOTFOUND )THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('INV', 'INV_UPDATE_ERROR');
      fnd_message.set_token('ENTITY1', 'mtl_material_transactions_temp');
      -- MESSAGE_TEXT = "Error Updating ENTITY1 "
      fnd_msg_pub.add;
      IF (l_debug = 1) THEN
         print_debug('proc_update_mmtt .. nodatafound OTHERS : ' );
      END IF;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
         IF (l_debug = 1) THEN
            print_debug('proc_update_mmtt .. EXCEP G_EXC_ERROR : ' );
         END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_debug = 1) THEN
         print_debug('proc_update_mmtt .. EXCEP G_EXC_UNEXPECTED_ERROR : ' );
      END IF;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_debug = 1) THEN
         print_debug('proc_update_mmtt .. UNEXCEP OTHERS : ' );
      END IF;
END proc_update_mmtt ;

PROCEDURE proc_update_msnt(p_rowid                   IN  ROWID,
			   p_new_transaction_temp_id IN  NUMBER,
			   p_from_serial_number      IN  VARCHAR2,
			   p_to_serial_number        IN  VARCHAR2,
			   x_return_status           OUT NOCOPY VARCHAR2)
  IS
   x_valid VARCHAR2(1) := 'Y';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('in proc_update_msnt .. p_rowid: '|| p_rowid );
      print_debug('in proc_update_msnt .. p_new_transaction_temp_id: '|| p_new_transaction_temp_id );
      print_debug('in proc_update_msnt .. p_from_serial_number: '|| p_from_serial_number);
      print_debug('in proc_update_msnt .. p_to_serial_number: '|| p_to_serial_number);
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

   UPDATE mtl_serial_numbers_temp
     SET
     transaction_temp_id = p_new_transaction_temp_id,
     fm_serial_number  = p_from_serial_number,
     to_serial_number    = p_to_serial_number
     WHERE ROWID = p_rowid;

   IF (SQL%NOTFOUND) THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('INV', 'INV_UPDATE_ERROR');
      fnd_message.set_token('ENTITY1', 'MTL_SERIAL_NUMBERS_TEMP');
      -- MESSAGE_TEXT = "Error Updating ENTITY1 "
      fnd_msg_pub.add;
      IF (l_debug = 1) THEN
         print_debug('proc_update_msnt .. nodatafound OTHERS : ');
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_debug = 1) THEN
         print_debug('proc_update_msnt .. UNEXCEP OTHERS : ');
      END IF;
END proc_update_msnt;

PROCEDURE proc_update_mtlt(p_rowid                   IN  ROWID,
			   p_new_transaction_temp_id IN  NUMBER,
			   p_lot_number              IN  VARCHAR2,
			   p_primary_quantity        IN  NUMBER,
			   p_transaction_quantity    IN  NUMBER,
			   p_new_serial_trx_temp_id  IN  NUMBER,
			   x_return_status           OUT NOCOPY VARCHAR2)
  IS
   x_valid VARCHAR2(1) := 'Y';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('in proc_update_mtlt .. p_rowid: '|| p_rowid);
      print_debug('in proc_update_mtlt .. p_new_transaction_temp_id: '|| p_new_transaction_temp_id );
      print_debug('in proc_update_mtlt .. p_lot_number: '|| p_lot_number);
      print_debug('in proc_update_mtlt .. p_primary_quantity: '|| p_primary_quantity);
      print_debug('in proc_update_mtlt .. p_transaction_quantity: '|| p_transaction_quantity);
      print_debug('in proc_update_mtlt .. p_new_serial_trx_temp_id: '|| p_new_serial_trx_temp_id);
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

   UPDATE mtl_transaction_lots_temp
     SET
     transaction_temp_id        = p_new_transaction_temp_id,
     lot_number                 = Nvl(p_lot_number, lot_number),
     primary_quantity           = Nvl(p_primary_quantity, primary_quantity),
     transaction_quantity       = Nvl(p_transaction_quantity, transaction_quantity),
     serial_transaction_temp_id = p_new_serial_trx_temp_id
     WHERE ROWID = p_rowid;

   IF (SQL%NOTFOUND) THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('INV', 'INV_UPDATE_ERROR');
      fnd_message.set_token('ENTITY1', 'MTL_LOT_NUMBERS_TEMP');
      -- MESSAGE_TEXT = "Error Updating ENTITY1 "
      fnd_msg_pub.add;
      IF (l_debug = 1) THEN
         print_debug('proc_update_mtlt .. nodatafound OTHERS : ');
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_debug = 1) THEN
         print_debug('proc_update_mtlt .. UNEXCEP OTHERS : ');
      END IF;
END proc_update_mtlt;

FUNCTION onhand_quantity_exists(p_inventory_item_id IN NUMBER,
				p_revision          IN VARCHAR2,
				p_organization_id   IN NUMBER,
				p_subinventory_code IN VARCHAR2,
				p_locator_id        IN NUMBER,
				p_lot_number        IN VARCHAR2,
				p_serial_number     IN VARCHAR2,
				p_lpn_id            IN NUMBER)
  RETURN BOOLEAN
  IS
     l_onhand NUMBER := 0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   BEGIN
      IF p_lpn_id IS NULL THEN
	 IF p_serial_number IS NULL THEN
	    SELECT 1 INTO l_onhand FROM dual
	      WHERE exists
	      (SELECT organization_id
	       FROM mtl_onhand_quantities_detail moq
	       WHERE (moq.lot_number = p_lot_number
		      OR (p_lot_number IS NULL AND moq.lot_number IS NULL))
	       AND (moq.revision = p_revision
		    OR (p_revision IS NULL AND moq.revision IS NULL))
	       AND moq.inventory_item_id = p_inventory_item_id
	       AND Nvl(moq.locator_id, -1) = Nvl(p_locator_id, -1)
	       AND moq.subinventory_code = p_subinventory_code
	       AND moq.organization_id = p_organization_id
	       AND Nvl(moq.containerized_flag, 2) = 2);  --  Loose Items only

	  ELSE
	    SELECT 1 INTO l_onhand FROM dual
	      WHERE exists
	      (SELECT current_organization_id
	       FROM mtl_serial_numbers msn
	       WHERE (msn.lot_number = p_lot_number
		      OR (p_lot_number IS NULL AND msn.lot_number IS NULL))
	       AND (msn.revision = p_revision
		    OR (p_revision IS NULL AND msn.revision IS NULL))
	       AND msn.inventory_item_id = p_inventory_item_id
	       AND Nvl(msn.current_locator_id, -1) = Nvl(p_locator_id, -1)
	       AND msn.current_subinventory_code = p_subinventory_code
	       AND msn.lpn_id IS NULL
	       AND msn.current_status = 3
	       AND msn.serial_number = p_serial_number
	       AND msn.current_organization_id = p_organization_id);
	 END IF;
       ELSE
	 IF p_serial_number IS NULL THEN
	    SELECT 1 INTO l_onhand FROM dual
	      WHERE exists
	      (SELECT wlpn.organization_id
	       FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn
	       WHERE (wlc.lot_number = p_lot_number
		      OR (p_lot_number IS NULL AND wlc.lot_number IS NULL))
	       AND (wlc.revision = p_revision
		    OR (p_revision IS NULL AND wlc.revision IS NULL))
	       AND wlc.inventory_item_id = p_inventory_item_id
	       AND Nvl(wlpn.locator_id, -1) = Nvl(p_locator_id, -1)
	       AND wlpn.subinventory_code = p_subinventory_code
	       AND wlpn.lpn_context IN (1,11) -- onhand, picked
	       AND wlc.parent_lpn_id = wlpn.lpn_id
	       AND wlc.organization_id = p_organization_id
	       AND wlc.parent_lpn_id = p_lpn_id);
	  ELSE
	    SELECT 1 INTO l_onhand FROM dual
	      WHERE exists
	      (SELECT current_organization_id
	       FROM mtl_serial_numbers msn
	       WHERE (msn.lot_number = p_lot_number
		      OR (p_lot_number IS NULL AND msn.lot_number IS NULL))
	       AND (msn.revision = p_revision
		    OR (p_revision IS NULL AND msn.revision IS NULL))
	       AND msn.lpn_id = p_lpn_id
	       AND msn.current_status = 3
	       AND msn.inventory_item_id = p_inventory_item_id
	       AND Nvl(msn.current_locator_id, -1) = Nvl(p_locator_id, -1)
	       AND msn.current_subinventory_code = p_subinventory_code
	       AND msn.serial_number = p_serial_number
	       AND msn.current_organization_id = p_organization_id);
	 END IF;
      END IF;

   EXCEPTION
      WHEN no_data_found THEN
	 l_onhand := 0;
      WHEN OTHERS THEN
	 RAISE;
   END;
   IF l_onhand = 0 THEN
      RETURN FALSE;
    ELSIF l_onhand = 1 THEN
      RETURN TRUE;
   END IF;
END onhand_quantity_exists;

function valid_cost_group(p_cost_group_id   IN NUMBER,
			  p_organization_id IN NUMBER)
  RETURN boolean
  IS
     l_valid VARCHAR2(1) := NULL;
BEGIN
   l_valid := 'N';

   BEGIN
      SELECT 'Y' INTO l_valid FROM dual
	WHERE
	EXISTS
	(SELECT ccgA.cost_group_id FROM
	 cst_cost_group_accounts CCGA
	 WHERE
	 ccga.cost_group_id = p_cost_group_id
	 AND ccga.organization_id = p_organization_id);
   EXCEPTION
      WHEN no_data_found THEN
	 l_valid := 'N';
   END;

   IF l_valid = 'Y' THEN
      print_debug('cost group is valid');
      RETURN TRUE;
    ELSE
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      print_debug('exception in valid_cost_group');
      RETURN FALSE;
END valid_cost_group;

-- Returns the default cost group from the organization or the subinventory
-- depending on whether the organization is standard costed or average costed
PROCEDURE proc_get_default_costgroup(p_organization_id       IN  NUMBER,
				     p_inventory_item_id     IN NUMBER,
				     p_subinventory_code     IN  VARCHAR2,
				     p_locator_id            IN NUMBER,
				     p_revision              IN VARCHAR2,
				     p_lot_number            IN VARCHAR2,
				     p_serial_number         IN VARCHAR2,
				     p_lpn_id                IN NUMBER,
				     p_transaction_action_id IN NUMBER,
				     p_is_backflush_txn      IN  BOOLEAN,
				     x_cost_group_id         OUT NOCOPY NUMBER,
				     x_return_status         OUT NOCOPY VARCHAR2)
  IS
     l_primary_cost_method        NUMBER;
     l_negative_balances_allowed  NUMBER;
     l_override_neg_for_backflush NUMBER := 0;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     l_return_status              VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_data                   VARCHAR2(255) := NULL;
     l_msg_count                  NUMBER;
     l_cost_group_id              NUMBER;

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   SELECT primary_cost_method, negative_inv_receipt_code
     INTO l_primary_cost_method, l_negative_balances_allowed
     FROM mtl_parameters
     WHERE organization_id = p_organization_id;

   IF (l_debug = 1) THEN
      print_debug('proc_get_default_costgroup.. l_negative_balances_allowed ' || l_negative_balances_allowed);
   END IF;

   IF p_is_backflush_txn = TRUE THEN
      l_override_neg_for_backflush := fnd_profile.value('INV_OVERRIDE_NEG_FOR_BACKFLUSH');
   END IF;

   IF (l_debug = 1) THEN
      print_debug('proc_get_default_costgroup.. l_override_neg_for_backflush ' || l_override_neg_for_backflush);
   END IF;

   IF l_negative_balances_allowed = 1 -- Negative balances are allowed
     OR l_override_neg_for_backflush = 1 -- Negative balances are allowed for backflush
     THEN

        BEGIN
	   --2690948 Bug fix
	   IF (l_debug = 1) THEN
	      print_debug('calling inv_user_cost_group.get_cg_for_neg_onhand');
	   END IF;
	   inv_user_cost_group.get_cg_for_neg_onhand
	     (x_return_status         => l_return_status,
	      x_msg_count             => l_msg_count,
	      x_msg_data              => l_msg_data,
	      x_cost_group_id         => l_cost_group_id,
	      p_organization_id       => p_organization_id,
	      p_inventory_item_id     => p_inventory_item_id,
	      p_subinventory_code     => p_subinventory_code,
	      p_locator_id            => p_locator_id,
	      p_revision              => p_revision,
	      p_lot_number            => p_lot_number,
	      p_serial_number         => p_serial_number,
	      p_transaction_action_id => p_transaction_action_id);
	EXCEPTION
	   WHEN OTHERS THEN
	      IF (l_debug = 1) THEN
		 print_debug('Exception raised from inv_user_cost_group.get_cg_for_neg_onhand');
		 print_debug(Sqlerrm);
	      END IF;
	END;

	IF (l_debug = 1) THEN
	   print_debug('get_cg_for_neg_onhand ret l_return_status '||l_return_status);
	   print_debug('get_cg_for_neg_onhand ret l_cost_group_id '||l_cost_group_id);
	END IF;

	IF l_return_status <> fnd_api.g_ret_sts_success THEN
	   IF (l_debug = 1) THEN
	      print_debug('get_cg_for_neg_onhand ret l_msg_data '||l_msg_data);
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;

	 ELSIF (l_return_status = fnd_api.g_ret_sts_success) AND
	   (l_cost_group_id IS NOT NULL) THEN

	   IF valid_cost_group(p_cost_group_id => l_cost_group_id,
			       p_organization_id => p_organization_id) THEN
	      x_cost_group_id := l_cost_group_id;
	    ELSE
	      IF (l_debug = 1) THEN
		 print_debug('Invalid cost group returned from inv_user_cost_group.get_cg_for_neg_onhand');
	      END IF;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
	   --2690948 Bug fix

	 ELSE

	   IF l_primary_cost_method = 1 THEN -- Standard costed org
             BEGIN
		SELECT default_cost_group_id
		  INTO x_cost_group_id
		  FROM mtl_secondary_inventories
		  WHERE organization_id = p_organization_id
		  AND secondary_inventory_name = p_subinventory_code;
		IF (l_debug = 1) THEN
		   print_debug('proc_get_default_costgroup.. default_sub_cost_group: ' || x_cost_group_id);
		END IF;
	     EXCEPTION
		WHEN no_data_found THEN
		   SELECT default_cost_group_id
		     INTO x_cost_group_id
		     FROM mtl_parameters
		     WHERE organization_id = p_organization_id;
		   IF (l_debug = 1) THEN
		      print_debug('proc_get_default_costgroup.. default_org_cost_group: ' || x_cost_group_id);
		   END IF;
	     END;
	    ELSE
		   SELECT default_cost_group_id
		     INTO x_cost_group_id
		     FROM mtl_parameters
		     WHERE organization_id = p_organization_id;
		   IF (l_debug = 1) THEN
		      print_debug('proc_get_default_costgroup.. default_org_cost_group: ' || x_cost_group_id);
		   END IF;
	   END IF;
	END IF;
    ELSIF l_negative_balances_allowed = 2 THEN -- Negative balances are not allowed
	   x_return_status := FND_API.G_RET_STS_ERROR ;
	   fnd_message.set_name('INV', 'INV_ZERO_ONHAND');
	   fnd_msg_pub.add;
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('INV', 'INV_ZERO_ONHAND');
      fnd_msg_pub.add;
      IF (l_debug = 1) THEN
         print_debug('proc_get_default_costgroup .. no_data_found' );
      END IF;

END proc_get_default_costgroup;

-- Tries to assign the cost group for the material if the material is
-- present in MTL_MATERIAL_TRANSACTIONS_TEMP as pending transactions.
PROCEDURE proc_get_pending_costgroup(p_organization_id       IN  NUMBER,
				     p_inventory_item_id     IN  NUMBER,
				     p_subinventory_code     IN  VARCHAR2,
				     p_locator_id            IN  NUMBER,
				     p_revision              IN  VARCHAR2,
				     p_lot_number            IN  VARCHAR2,
				     p_serial_number         IN  VARCHAR2,
				     p_lpn_id                IN  NUMBER,
				     p_transaction_action_id IN  NUMBER,
				     x_cost_group_id         OUT NOCOPY NUMBER,
				     x_return_status         OUT NOCOPY VARCHAR2)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('In proc_get_pending_costgroup... ');
   END IF;
   x_return_status := fnd_api.g_ret_sts_success;

   IF p_serial_number IS NULL THEN
      IF (l_debug = 1) THEN
         print_debug('In proc_get_pending_costgroup...No Control ');
      END IF;
      IF p_lot_number IS NULL THEN
	 -- No control
	 IF (l_debug = 1) THEN
   	 print_debug('In proc_get_pending_costgroup...No Control ');
	 END IF;

     Select cost_group_id INTO x_cost_group_id FROM (
	 SELECT mmtt.cost_group_id
	   FROM mtl_material_transactions_temp mmtt
	   WHERE mmtt.transfer_organization = p_organization_id
	   AND mmtt.transfer_subinventory = p_subinventory_code
	   AND Nvl(mmtt.transfer_to_location, -1) = Nvl(p_locator_id, -1)
	   AND mmtt.inventory_item_id = p_inventory_item_id
	   AND Nvl(mmtt.lpn_id, -1) = Nvl(p_lpn_id, -1)
	   AND mmtt.transaction_action_id IN (inv_globals.g_action_subxfr,
					      inv_globals.g_action_orgxfr,
					      inv_globals.g_action_stgxfr)

	 UNION

	   -- No control

	 SELECT mmtt.cost_group_id
	   FROM mtl_material_transactions_temp mmtt
	   WHERE mmtt.organization_id = p_organization_id
	   AND mmtt.subinventory_code = p_subinventory_code
	   AND Nvl(mmtt.locator_id, -1) = Nvl(p_locator_id, -1)
	   AND mmtt.inventory_item_id = p_inventory_item_id
	   AND Nvl(mmtt.lpn_id, -1) = Nvl(p_lpn_id, -1)
	   AND mmtt.transaction_action_id IN (inv_globals.g_action_cyclecountadj,
					      inv_globals.g_action_physicalcountadj,
					      inv_globals.g_action_intransitreceipt,
					      inv_globals.g_action_receipt,
					      inv_globals.g_action_assycomplete,
					      /*3199679inv_globals.g_action_assyreturn,*/
					      inv_globals.g_action_inv_lot_split,
					      inv_globals.g_action_inv_lot_merge,
					      inv_globals.g_action_inv_lot_translate))
       WHERE  ROWNUM = 1;

       ELSE
	  IF (l_debug = 1) THEN
   	  print_debug('In proc_get_pending_costgroup... Lot Control');
	  END IF;
	  -- Lot control
	  Select cost_group_id INTO x_cost_group_id FROM (
	 SELECT mmtt.cost_group_id
	   FROM mtl_material_transactions_temp mmtt,
	        mtl_transaction_lots_temp mtlt
	   WHERE mmtt.transfer_organization = p_organization_id
	   AND mmtt.transfer_subinventory = p_subinventory_code
	   AND Nvl(mmtt.transfer_to_location, -1) = Nvl(p_locator_id, -1)
	   AND mmtt.inventory_item_id = p_inventory_item_id
	   AND Nvl(mmtt.lpn_id, -1) = Nvl(p_lpn_id, -1)
	   AND mmtt.transaction_action_id IN (inv_globals.g_action_subxfr,
					      inv_globals.g_action_orgxfr,
					      inv_globals.g_action_stgxfr)
	   AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
	   AND mtlt.lot_number = p_lot_number

	 UNION

	   SELECT mmtt.cost_group_id
	   FROM mtl_material_transactions_temp mmtt,
	   mtl_transaction_lots_temp mtlt
	   WHERE mmtt.organization_id = p_organization_id
	   AND mmtt.subinventory_code = p_subinventory_code
	   AND Nvl(mmtt.locator_id, -1) = Nvl(p_locator_id, -1)
	   AND mmtt.inventory_item_id = p_inventory_item_id
	   AND Nvl(mmtt.lpn_id, -1) = Nvl(p_lpn_id, -1)
	   AND mmtt.transaction_action_id IN (inv_globals.g_action_cyclecountadj,
					      inv_globals.g_action_physicalcountadj,
					      inv_globals.g_action_intransitreceipt,
					      inv_globals.g_action_receipt,
					      inv_globals.g_action_assycomplete,
					      /*3199679 inv_globals.g_action_assyreturn,*/
					      inv_globals.g_action_inv_lot_split,
					      inv_globals.g_action_inv_lot_merge,
					      inv_globals.g_action_inv_lot_translate)
	   AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
	    AND mtlt.lot_number = p_lot_number)
	    WHERE ROWNUM = 1;

     END IF;

   ELSE
	IF (l_debug = 1) THEN
   	print_debug('In proc_get_pending_costgroup...No ControlSerial Control ');
	END IF;

      -- Serial control
	IF p_lot_number IS NULL THEN
 IF (l_debug = 1) THEN
    print_debug('In proc_get_pending_costgroup...Serial Control ');
 END IF;
	 Select cost_group_id INTO x_cost_group_id FROM (
	 SELECT mmtt.cost_group_id
	   FROM mtl_material_transactions_temp mmtt,
	        mtl_serial_numbers_temp msnt
	   WHERE mmtt.transfer_organization = p_organization_id
	   AND mmtt.transfer_subinventory = p_subinventory_code
	   AND Nvl(mmtt.transfer_to_location, -1) = Nvl(p_locator_id, -1)
	   AND mmtt.inventory_item_id = p_inventory_item_id
	   AND Nvl(mmtt.lpn_id, -1) = Nvl(p_lpn_id, -1)
	   AND mmtt.transaction_action_id IN (inv_globals.g_action_subxfr,
					      inv_globals.g_action_orgxfr,
					      inv_globals.g_action_stgxfr)
	   AND mmtt.transaction_temp_id = msnt.transaction_temp_id
	   AND msnt.fm_serial_number <= p_serial_number
	   AND msnt.to_serial_number >= p_serial_number

	 UNION

	   SELECT mmtt.cost_group_id
	   FROM mtl_material_transactions_temp mmtt,
	   mtl_serial_numbers_temp msnt
	   WHERE mmtt.organization_id = p_organization_id
	   AND mmtt.subinventory_code = p_subinventory_code
	   AND Nvl(mmtt.locator_id, -1) = Nvl(p_locator_id, -1)
	   AND mmtt.inventory_item_id = p_inventory_item_id
	   AND Nvl(mmtt.lpn_id, -1) = Nvl(p_lpn_id, -1)
	   AND mmtt.transaction_action_id IN (inv_globals.g_action_cyclecountadj,
					      inv_globals.g_action_physicalcountadj,
					      inv_globals.g_action_intransitreceipt,
					      inv_globals.g_action_receipt,
					      inv_globals.g_action_assycomplete,
					      /*3199679inv_globals.g_action_assyreturn,*/
					      inv_globals.g_action_inv_lot_split,
					      inv_globals.g_action_inv_lot_merge,
					      inv_globals.g_action_inv_lot_translate)
	   AND mmtt.transaction_temp_id = msnt.transaction_temp_id
	   AND msnt.fm_serial_number <= p_serial_number
	   AND msnt.to_serial_number >= p_serial_number)
	   WHERE ROWNUM = 1;

       ELSE
	  IF (l_debug = 1) THEN
   	  print_debug('In proc_get_pending_costgroup...BOTh control ');
	  END IF;
	  -- Lot and serial control
	   Select cost_group_id INTO x_cost_group_id FROM (
	 SELECT mmtt.cost_group_id
	   FROM mtl_material_transactions_temp mmtt,
	        mtl_transaction_lots_temp mtlt,
	        mtl_serial_numbers_temp msnt
	   WHERE mmtt.transfer_organization = p_organization_id
	   AND mmtt.transfer_subinventory = p_subinventory_code
	   AND Nvl(mmtt.transfer_to_location, -1) = Nvl(p_locator_id, -1)
	   AND mmtt.inventory_item_id = p_inventory_item_id
	   AND Nvl(mmtt.lpn_id, -1) = Nvl(p_lpn_id, -1)
	   AND mmtt.transaction_action_id IN (inv_globals.g_action_subxfr,
					      inv_globals.g_action_orgxfr,
					      inv_globals.g_action_stgxfr)
	   AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
	   AND mtlt.lot_number = p_lot_number
	   AND mtlt.transaction_temp_id = msnt.transaction_temp_id
	   AND msnt.fm_serial_number <= p_serial_number
	   AND msnt.to_serial_number >= p_serial_number

	 UNION

	   SELECT mmtt.cost_group_id
	   FROM mtl_material_transactions_temp mmtt,
	   mtl_transaction_lots_temp mtlt,
	   mtl_serial_numbers_temp msnt
	   WHERE mmtt.organization_id = p_organization_id
	   AND mmtt.subinventory_code = p_subinventory_code
	   AND Nvl(mmtt.locator_id, -1) = Nvl(p_locator_id, -1)
	   AND mmtt.inventory_item_id = p_inventory_item_id
	   AND Nvl(mmtt.lpn_id, -1) = Nvl(p_lpn_id, -1)
	   AND mmtt.transaction_action_id IN (inv_globals.g_action_cyclecountadj,
					      inv_globals.g_action_physicalcountadj,
					      inv_globals.g_action_intransitreceipt,
					      inv_globals.g_action_receipt,
					      inv_globals.g_action_assycomplete,
					      /*3199679inv_globals.g_action_assyreturn,*/
					      inv_globals.g_action_inv_lot_split,
					      inv_globals.g_action_inv_lot_merge,
					      inv_globals.g_action_inv_lot_translate)
	   AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
	   AND mtlt.lot_number = p_lot_number
	   AND mtlt.transaction_temp_id = msnt.transaction_temp_id
	   AND msnt.fm_serial_number <= p_serial_number
	     AND msnt.to_serial_number >= p_serial_number)
	     WHERE ROWNUM = 1;

     END IF;

   END IF;
/* BUG 3777187
--Bug 2844271 fix
   IF x_cost_group_id IS NULL
     OR x_cost_group_id = 0 THEN
      IF (l_debug = 1) THEN
	 print_debug('proc_get_pendingcostgroup...cg null for pending txn '||
		     'org '||p_organization_id||
		     'item '||p_inventory_item_id||
		     'sub '||p_subinventory_code||
		     'loc '||p_locator_id||
		     'rev '||p_revision||
		     'lot '||p_lot_number||
		     'ser '||p_serial_number);

	 print_debug('proc_get_pendingcostgroup...returning failure with CG:'||x_cost_group_id);
      END IF;
      fnd_message.set_name('INV','INV_PENDING_CG_NULL');
      fnd_message.set_token('ORG',p_organization_id);
      fnd_message.set_token('ITEM',p_inventory_item_id);
      fnd_msg_pub.add;
      x_return_status := g_corrupt_cg_error;
      --Bug 2844271 fix
    ELSE */
    /*BUG 3777187 Pending transactions may not have cost_group_id always so x_cost_group_id might be null. In this case we need to
      call the proc_get_default_costgroup  api so that to get cost_group from sub/org or from user defined api */
    IF x_cost_group_id IS NULL
     OR x_cost_group_id = 0 THEN
      IF (l_debug = 1) THEN
               print_debug('proc_get_pendingcostgroup...cg is null or cg is zero for pending txn :x_cost_group_id' || x_cost_group_id);
	        print_debug('returning error to call proc_get_default_costgroup() api..');
      END IF;
                x_return_status := FND_API.G_RET_STS_ERROR ; --8715706
    ELSE
      IF (l_debug = 1) THEN
	  print_debug('proc_get_pendingcostgroup... Returning success with CG:'|| x_cost_group_id);
      END IF;
      x_return_status := FND_API.g_ret_sts_success;
   END IF;

EXCEPTION
   WHEN no_data_found THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('INV', 'INV_ZERO_ONHAND');
      fnd_msg_pub.add;
      IF (l_debug = 1) THEN
         print_debug('proc_get_pending_costgroup .. no_data_found' );
      END IF;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_debug = 1) THEN
         print_debug('proc_get_pending_costgroup .. UNEXCEP OTHERS : ' );
      END IF;
END proc_get_pending_costgroup;

-- Gets the current cost group for the material given parameters
-- First checks the mtl_onhand_quantities for onhand inventory and then the
-- mtl_material_transactions_temp for any pending transactions.
PROCEDURE proc_get_costgroup(p_organization_id       IN  NUMBER,
			     p_inventory_item_id     IN  NUMBER,
			     p_subinventory_code     IN  VARCHAR2,
			     p_locator_id            IN  NUMBER,
			     p_revision              IN  VARCHAR2,
			     p_lot_number            IN  VARCHAR2,
			     p_serial_number         IN  VARCHAR2,
			     p_containerized_flag    IN  NUMBER,
			     p_lpn_id                IN  NUMBER,
			     p_transaction_action_id IN  NUMBER,
			     x_cost_group_id         OUT NOCOPY NUMBER,
			     x_return_status         OUT NOCOPY VARCHAR2)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug( 'In proc_get_costgroup... ');
      print_debug('p_organization_id'||p_organization_id);
      print_debug('p_inventory_item_id'||p_inventory_item_id);
      print_debug('p_subinventory_code'||p_subinventory_code);
      print_debug('p_locator_id'||p_locator_id);
      print_debug('p_revision'||p_revision);
      print_debug('p_lot_number'||p_lot_number);
      print_debug('p_serial_number'||p_serial_number);
      print_debug('p_containerized_flag'||p_containerized_flag);
      print_debug('p_lpn_id'||p_lpn_id);
      print_debug('p_transaction_action_id'||p_transaction_action_id);
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;
   IF p_lpn_id IS NULL THEN
      IF p_serial_number IS NULL THEN
	 SELECT moq.cost_group_id -- Loose material, no serial control
	   INTO x_cost_group_id
	   FROM mtl_onhand_quantities_detail moq
	   WHERE (moq.lot_number = p_lot_number
		  OR (p_lot_number IS NULL AND moq.lot_number IS NULL))
  	    AND (moq.revision = p_revision
		 OR (p_revision IS NULL AND moq.revision IS NULL))
	    AND moq.inventory_item_id = p_inventory_item_id
	    AND nvl(moq.locator_id, -1) = Nvl(p_locator_id, -1)
	    AND moq.subinventory_code = p_subinventory_code
	    AND moq.organization_id = p_organization_id
	    AND Nvl(moq.containerized_flag, 2) = 2  --  Loose Items only
	    AND ROWNUM = 1;
       ELSE
	 SELECT msn.cost_group_id -- Loose material, serial control
	   INTO x_cost_group_id
	   FROM mtl_serial_numbers msn
	   WHERE (msn.lot_number = p_lot_number
		  OR (p_lot_number IS NULL AND msn.lot_number IS NULL))
	   AND (msn.revision = p_revision
		OR (p_revision IS NULL AND msn.revision IS NULL))
	   AND msn.inventory_item_id = p_inventory_item_id
    	   AND Nvl(msn.current_locator_id, -1) = Nvl(p_locator_id, -1)
	   AND msn.current_subinventory_code = p_subinventory_code
           AND msn.current_status = 3
	   AND msn.serial_number = p_serial_number
           AND msn.current_organization_id = p_organization_id
	   AND ROWNUM = 1;
	 END IF;
    ELSE
      IF p_serial_number IS NULL THEN
       -- Packed material, no serial control
       SELECT  cost_group_id  INTO x_cost_group_id
        FROM (
	 SELECT wlc.cost_group_id
	   FROM wms_lpn_contents wlc,
  	        wms_license_plate_numbers wlpn
	   WHERE (wlc.lot_number = p_lot_number
		  OR (p_lot_number IS NULL AND wlc.lot_number IS NULL))
       	    AND (wlc.revision = p_revision
		 OR (p_revision IS NULL AND wlc.revision IS NULL))
	    AND wlc.inventory_item_id = p_inventory_item_id
	    AND wlc.parent_lpn_id = wlpn.lpn_id
	    -- Bug 2393441 - During ship confirmation, an LPN may
	    -- have blank sub and loc if some lines belonging to the LPN
	    -- are shipped out. To prevent the API from erroring out the
	    -- following checks are commented out
	    -- AND Nvl(wlpn.locator_id, -1) = nvl(p_locator_id, -1)
	    -- AND wlpn.subinventory_code = p_subinventory_code
            AND wlpn.organization_id = p_organization_id
	    AND wlpn.lpn_id = p_lpn_id
	    AND ROWNUM = 1
	   UNION  --Bug#6133411.Added the UNION and outer SELECT as well.
	   SELECT moq.cost_group_id
	    FROM mtl_onhand_quantities_detail moq
	    WHERE (moq.lot_number = p_lot_number
		  OR (p_lot_number IS NULL AND moq.lot_number IS NULL))
  	    AND (moq.revision = p_revision
		 OR (p_revision IS NULL AND moq.revision IS NULL))
	    AND moq.inventory_item_id = p_inventory_item_id
	    AND moq.locator_id = p_locator_id
	    AND moq.subinventory_code = p_subinventory_code
	    AND moq.organization_id = p_organization_id
	    AND moq.containerized_flag = 1
	    AND moq.lpn_id = p_lpn_id
	    AND ROWNUM < 2 )
	WHERE ROWNUM < 2 ;
       ELSE
	 SELECT msn.cost_group_id -- Packed material, serial control
	   INTO x_cost_group_id
	   FROM mtl_serial_numbers msn
	   WHERE (msn.lot_number = p_lot_number
		  OR (p_lot_number IS NULL AND msn.lot_number IS NULL))
   	   AND (msn.revision = p_revision
		OR (p_revision IS NULL AND msn.revision IS NULL))
	   AND msn.lpn_id = p_lpn_id
	   AND msn.current_status = 3
	   AND msn.inventory_item_id = p_inventory_item_id
	   AND Nvl(msn.current_locator_id, -1) = Nvl(p_locator_id, -1)
	   AND msn.current_subinventory_code = p_subinventory_code
	   AND msn.serial_number = p_serial_number
           AND msn.current_organization_id = p_organization_id
           AND ROWNUM = 1;
      END IF;
   END IF;

      --Bug 2844271 fix
   IF x_cost_group_id IS NULL
     OR x_cost_group_id <= 0 THEN
      IF (l_debug = 1) THEN
	 print_debug('proc_get_costgroup...onhand cg null or 0 for '||
		     'org '||p_organization_id||
		     'item '||p_inventory_item_id||
		     'sub '||p_subinventory_code||
		     'loc '||p_locator_id||
		     'rev '||p_revision||
		     'lot '||p_lot_number||
		     'ser '||p_serial_number);

	 print_debug('proc_get_costgroup...returning failure with CG:'||x_cost_group_id);
      END IF;
      fnd_message.set_name('INV','INV_ONHAND_CG_NULL');
      fnd_message.set_token('ORG',p_organization_id);
      fnd_message.set_token('ITEM',p_inventory_item_id);
      fnd_msg_pub.add;
      x_return_status := g_corrupt_cg_error;
      --Bug 2844271 fix
    ELSE
       IF (l_debug = 1) THEN
	  print_debug('proc_get_costgroup... Returning success with CG:'|| x_cost_group_id);
       END IF;
       x_return_status := FND_API.g_ret_sts_success;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 1) THEN
         print_debug('proc_get_costgroup .. EXCEP G_EXC_ERROR : ' );
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 1) THEN
         print_debug('proc_get_costgroup .. EXCEP G_EXC_UNEXPECTED_ERROR : ' );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   WHEN no_data_found THEN
      IF (l_debug = 1) THEN
         print_debug('proc_get_costgroup .. No data found in MOQ, checking MMTT' );
      END IF;
      -- Check if there is any material in the pending transactions
      proc_get_pending_costgroup(p_organization_id       => p_organization_id,
				  p_inventory_item_id     => p_inventory_item_id,
				  p_subinventory_code     => p_subinventory_code,
				  p_locator_id            => p_locator_id,
				  p_revision              => p_revision,
				  p_lot_number            => p_lot_number,
				  p_serial_number         => p_serial_number,
				  p_lpn_id                => p_lpn_id,
				  p_transaction_action_id => p_transaction_action_id,
				  x_cost_group_id         => x_cost_group_id,
				  x_return_status         => x_return_status);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_debug = 1) THEN
         print_debug('proc_get_costgroup .. UNEXCEP OTHERS : ' );
      END IF;

END proc_get_costgroup;

-- Gets the current cost group for the material given parameters
-- First checks the mtl_onhand_quantities for onhand inventory and then the
-- mtl_material_transactions_temp for any pending transactions. If no
-- entries are found there then it checks if negative onhand balances are
-- allowed. If negative balances are allowed then it assigns the default
-- cost group of the subinventory or the organization.
PROCEDURE proc_determine_costgroup(p_organization_id       IN  NUMBER,
				   p_inventory_item_id     IN  NUMBER,
				   p_subinventory_code     IN  VARCHAR2,
				   p_locator_id            IN  NUMBER,
				   p_revision              IN  VARCHAR2,
				   p_lot_number            IN  VARCHAR2,
				   p_serial_number         IN  VARCHAR2,
				   p_containerized_flag    IN  NUMBER,
				   p_lpn_id                IN  NUMBER,
				   p_transaction_action_id IN  NUMBER,
				   p_is_backflush_txn      IN  BOOLEAN,
				   x_cost_group_id         OUT NOCOPY NUMBER,
				   x_return_status         OUT NOCOPY VARCHAR2)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   proc_get_costgroup(p_organization_id       => p_organization_id,
		      p_inventory_item_id     => p_inventory_item_id,
		      p_subinventory_code     => p_subinventory_code,
		      p_locator_id            => p_locator_id,
		      p_revision              => p_revision,
		      p_lot_number            => p_lot_number,
		      p_serial_number         => p_serial_number,
		      p_containerized_flag    => p_containerized_flag,
		      p_lpn_id                => p_lpn_id,
		      p_transaction_action_id => p_transaction_action_id,
		      x_cost_group_id         => x_cost_group_id,
		      x_return_status         => x_return_status);
   IF (l_debug = 1) THEN
      print_debug('proc_get_costgroup returned ' || x_return_status);
   END IF;

   IF x_return_status = g_corrupt_cg_error THEN
      x_return_status :=  fnd_api.g_ret_sts_error;
    ELSIF x_return_status <> fnd_api.g_ret_sts_success THEN
      proc_get_default_costgroup(p_organization_id    => p_organization_id,
				 p_inventory_item_id  => p_inventory_item_id,
				 p_subinventory_code  => p_subinventory_code,
				 p_locator_id         => p_locator_id,
				 p_revision           => p_revision,
				 p_lot_number         => p_lot_number,
				 p_serial_number      => p_serial_number,
				 p_lpn_id             => p_lpn_id,
				 p_transaction_action_id => p_transaction_action_id,
				 p_is_backflush_txn   => p_is_backflush_txn,
				 x_cost_group_id      => x_cost_group_id,
				 x_return_status      => x_return_status);
      IF (l_debug = 1) THEN
         print_debug('proc_get_default_costgroup returned ' || x_return_status);
      END IF;
   END IF;

END;

PROCEDURE proc_insert_msnt(p_msnt_rec                IN   cur_msnt%ROWTYPE,
			   p_from_serial_number      IN   VARCHAR2,
			   p_to_serial_number        IN   VARCHAR2,
			   p_new_txn_temp_id         IN   NUMBER,
			   x_return_status           OUT  NOCOPY VARCHAR2)
IS
   l_api_name CONSTANT VARCHAR2(100)  := 'proc_insert_msnt';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   SAVEPOINT sp_proc_insert_msnt;
   IF (l_debug = 1) THEN
      print_debug('proc_insert_msnt.. FSN: ' || p_from_serial_number);
      print_debug('proc_insert_msnt.. TSN: ' || p_to_serial_number);
      print_debug('proc_insert_msnt.. Txn temp id: ' || p_new_txn_temp_id);
   END IF;

   INSERT INTO mtl_serial_numbers_temp
           (TRANSACTION_TEMP_ID
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_LOGIN
            ,REQUEST_ID
            ,PROGRAM_APPLICATION_ID
            ,PROGRAM_ID
            ,PROGRAM_UPDATE_DATE
            ,VENDOR_SERIAL_NUMBER
            ,VENDOR_LOT_NUMBER
            ,FM_SERIAL_NUMBER
            ,TO_SERIAL_NUMBER
            ,SERIAL_PREFIX
            ,ERROR_CODE
            ,PARENT_SERIAL_NUMBER
            ,GROUP_HEADER_ID
            ,END_ITEM_UNIT_NUMBER
            ,SERIAL_ATTRIBUTE_CATEGORY
            ,TERRITORY_CODE
            ,ORIGINATION_DATE
            ,C_ATTRIBUTE1
            ,C_ATTRIBUTE2
            ,C_ATTRIBUTE3
            ,C_ATTRIBUTE4
            ,C_ATTRIBUTE5
            ,C_ATTRIBUTE6
            ,C_ATTRIBUTE7
            ,C_ATTRIBUTE8
            ,C_ATTRIBUTE9
            ,C_ATTRIBUTE10
            ,C_ATTRIBUTE11
            ,C_ATTRIBUTE12
            ,C_ATTRIBUTE13
            ,C_ATTRIBUTE14
            ,C_ATTRIBUTE15
            ,C_ATTRIBUTE16
            ,C_ATTRIBUTE17
            ,C_ATTRIBUTE18
            ,C_ATTRIBUTE19
            ,C_ATTRIBUTE20
            ,D_ATTRIBUTE1
            ,D_ATTRIBUTE2
            ,D_ATTRIBUTE3
            ,D_ATTRIBUTE4
            ,D_ATTRIBUTE5
            ,D_ATTRIBUTE6
            ,D_ATTRIBUTE7
            ,D_ATTRIBUTE8
            ,D_ATTRIBUTE9
            ,D_ATTRIBUTE10
            ,N_ATTRIBUTE1
            ,N_ATTRIBUTE2
            ,N_ATTRIBUTE3
            ,N_ATTRIBUTE4
            ,N_ATTRIBUTE5
            ,N_ATTRIBUTE6
            ,N_ATTRIBUTE7
            ,N_ATTRIBUTE8
            ,N_ATTRIBUTE9
            ,N_ATTRIBUTE10
            ,STATUS_ID
            ,TIME_SINCE_NEW
            ,CYCLES_SINCE_NEW
            ,TIME_SINCE_OVERHAUL
            ,CYCLES_SINCE_OVERHAUL
            ,TIME_SINCE_REPAIR
            ,CYCLES_SINCE_REPAIR
            ,TIME_SINCE_VISIT
            ,CYCLES_SINCE_VISIT
            ,TIME_SINCE_MARK
            ,CYCLES_SINCE_MARK
            ,NUMBER_OF_REPAIRS
            ,OBJECT_TYPE2                      -- R12 Genealogy Enhancements
            ,OBJECT_NUMBER2                    -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_TYPE                -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_ID                  -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_NUMBER              -- R12 Genealogy Enhancements
            ,PARENT_ITEM_ID                    -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_TYPE2               -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_ID2                 -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_NUMBER2)            -- R12 Genealogy Enhancements
     VALUES (p_new_txn_temp_id
            ,p_msnt_rec.LAST_UPDATE_DATE
            ,p_msnt_rec.LAST_UPDATED_BY
            ,p_msnt_rec.CREATION_DATE
            ,p_msnt_rec.CREATED_BY
            ,p_msnt_rec.LAST_UPDATE_LOGIN
            ,p_msnt_rec.REQUEST_ID
            ,p_msnt_rec.PROGRAM_APPLICATION_ID
            ,p_msnt_rec.PROGRAM_ID
            ,p_msnt_rec.PROGRAM_UPDATE_DATE
            ,p_msnt_rec.VENDOR_SERIAL_NUMBER
            ,p_msnt_rec.VENDOR_LOT_NUMBER
            ,p_from_serial_number
            ,p_to_serial_number
            ,p_msnt_rec.SERIAL_PREFIX
            ,p_msnt_rec.ERROR_CODE
            ,p_msnt_rec.PARENT_SERIAL_NUMBER
            ,p_msnt_rec.GROUP_HEADER_ID
            ,p_msnt_rec.END_ITEM_UNIT_NUMBER
            ,p_msnt_rec.SERIAL_ATTRIBUTE_CATEGORY
            ,p_msnt_rec.TERRITORY_CODE
            ,p_msnt_rec.ORIGINATION_DATE
            ,p_msnt_rec.C_ATTRIBUTE1
            ,p_msnt_rec.C_ATTRIBUTE2
            ,p_msnt_rec.C_ATTRIBUTE3
            ,p_msnt_rec.C_ATTRIBUTE4
            ,p_msnt_rec.C_ATTRIBUTE5
            ,p_msnt_rec.C_ATTRIBUTE6
            ,p_msnt_rec.C_ATTRIBUTE7
            ,p_msnt_rec.C_ATTRIBUTE8
            ,p_msnt_rec.C_ATTRIBUTE9
            ,p_msnt_rec.C_ATTRIBUTE10
            ,p_msnt_rec.C_ATTRIBUTE11
            ,p_msnt_rec.C_ATTRIBUTE12
            ,p_msnt_rec.C_ATTRIBUTE13
            ,p_msnt_rec.C_ATTRIBUTE14
            ,p_msnt_rec.C_ATTRIBUTE15
            ,p_msnt_rec.C_ATTRIBUTE16
            ,p_msnt_rec.C_ATTRIBUTE17
            ,p_msnt_rec.C_ATTRIBUTE18
            ,p_msnt_rec.C_ATTRIBUTE19
            ,p_msnt_rec.C_ATTRIBUTE20
            ,p_msnt_rec.D_ATTRIBUTE1
            ,p_msnt_rec.D_ATTRIBUTE2
            ,p_msnt_rec.D_ATTRIBUTE3
            ,p_msnt_rec.D_ATTRIBUTE4
            ,p_msnt_rec.D_ATTRIBUTE5
            ,p_msnt_rec.D_ATTRIBUTE6
            ,p_msnt_rec.D_ATTRIBUTE7
            ,p_msnt_rec.D_ATTRIBUTE8
            ,p_msnt_rec.D_ATTRIBUTE9
            ,p_msnt_rec.D_ATTRIBUTE10
            ,p_msnt_rec.N_ATTRIBUTE1
            ,p_msnt_rec.N_ATTRIBUTE2
            ,p_msnt_rec.N_ATTRIBUTE3
            ,p_msnt_rec.N_ATTRIBUTE4
            ,p_msnt_rec.N_ATTRIBUTE5
            ,p_msnt_rec.N_ATTRIBUTE6
            ,p_msnt_rec.N_ATTRIBUTE7
            ,p_msnt_rec.N_ATTRIBUTE8
            ,p_msnt_rec.N_ATTRIBUTE9
            ,p_msnt_rec.N_ATTRIBUTE10
            ,p_msnt_rec.STATUS_ID
            ,p_msnt_rec.TIME_SINCE_NEW
            ,p_msnt_rec.CYCLES_SINCE_NEW
            ,p_msnt_rec.TIME_SINCE_OVERHAUL
            ,p_msnt_rec.CYCLES_SINCE_OVERHAUL
            ,p_msnt_rec.TIME_SINCE_REPAIR
            ,p_msnt_rec.CYCLES_SINCE_REPAIR
            ,p_msnt_rec.TIME_SINCE_VISIT
            ,p_msnt_rec.CYCLES_SINCE_VISIT
            ,p_msnt_rec.TIME_SINCE_MARK
            ,p_msnt_rec.CYCLES_SINCE_MARK
            ,p_msnt_rec.number_of_repairs
            ,p_msnt_rec.OBJECT_TYPE2                      -- R12 Genealogy Enhancements
            ,p_msnt_rec.OBJECT_NUMBER2                    -- R12 Genealogy Enhancements
            ,p_msnt_rec.PARENT_OBJECT_TYPE                -- R12 Genealogy Enhancements
            ,p_msnt_rec.PARENT_OBJECT_ID                -- R12 Genealogy Enhancements
            ,p_msnt_rec.PARENT_OBJECT_NUMBER            -- R12 Genealogy Enhancements
            ,p_msnt_rec.PARENT_ITEM_ID                -- R12 Genealogy Enhancements
            ,p_msnt_rec.PARENT_OBJECT_TYPE2             -- R12 Genealogy Enhancements
            ,p_msnt_rec.PARENT_OBJECT_ID2               -- R12 Genealogy Enhancements
            ,p_msnt_rec.PARENT_OBJECT_NUMBER2);         -- R12 Genealogy Enhancements
EXCEPTION
    WHEN OTHERS THEN
     IF (l_debug = 1) THEN
        print_debug( 'proc_insert_msnt .. EXCEP others : ' );
     END IF;
     ROLLBACK TO sp_proc_insert_msnt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END proc_insert_msnt;
--
PROCEDURE  proc_insert_mtlt (p_mtlt_rec                IN   cur_mtlt%ROWTYPE,
                             p_new_txn_temp_id         IN   NUMBER,
                             p_prim_qty                IN   NUMBER,
                             p_txn_qty                 IN   NUMBER,
			     p_new_serial_trx_temp_id  IN   NUMBER,
                             x_return_status           OUT  NOCOPY VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   SAVEPOINT sp_proc_insert_mtlt;

   IF (l_debug = 1) THEN
      print_debug( 'proc_insert_mtlt ..p_new_txn_temp_id :'|| p_new_txn_temp_id );
      print_debug( 'proc_insert_mtlt ..p_prim_qty'|| p_prim_qty );
      print_debug( 'proc_insert_mtlt ..Lot : '|| p_mtlt_rec.lot_number );
      print_debug( 'proc_insert_mtlt ..p_new_serial_trx_temp_id: '|| p_new_serial_trx_temp_id );
      print_debug( 'proc_insert_mtlt ..RowId : '|| p_mtlt_rec.mtlt_RowId );
   END IF;

   INSERT  INTO  mtl_transaction_lots_temp
   (        TRANSACTION_TEMP_ID
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_LOGIN
            ,REQUEST_ID
            ,PROGRAM_APPLICATION_ID
            ,PROGRAM_ID
            ,PROGRAM_UPDATE_DATE
            ,TRANSACTION_QUANTITY
            ,PRIMARY_QUANTITY
            ,LOT_NUMBER
            ,LOT_EXPIRATION_DATE
            ,ERROR_CODE
            ,SERIAL_TRANSACTION_TEMP_ID
            ,GROUP_HEADER_ID
            ,PUT_AWAY_RULE_ID
            ,PICK_RULE_ID
            ,DESCRIPTION
            ,VENDOR_ID
            ,SUPPLIER_LOT_NUMBER
            ,TERRITORY_CODE
            ,ORIGINATION_DATE
            ,DATE_CODE
            ,GRADE_CODE
            ,CHANGE_DATE
            ,MATURITY_DATE
            ,STATUS_ID
            ,RETEST_DATE
            ,AGE
            ,ITEM_SIZE
            ,COLOR
            ,VOLUME
            ,VOLUME_UOM
            ,PLACE_OF_ORIGIN
            ,BEST_BY_DATE
            ,LENGTH
            ,LENGTH_UOM
            ,RECYCLED_CONTENT
            ,THICKNESS
            ,THICKNESS_UOM
            ,WIDTH
            ,WIDTH_UOM
            ,CURL_WRINKLE_FOLD
            ,LOT_ATTRIBUTE_CATEGORY
            ,C_ATTRIBUTE1
            ,C_ATTRIBUTE2
            ,C_ATTRIBUTE3
            ,C_ATTRIBUTE4
            ,C_ATTRIBUTE5
            ,C_ATTRIBUTE6
            ,C_ATTRIBUTE7
            ,C_ATTRIBUTE8
            ,C_ATTRIBUTE9
            ,C_ATTRIBUTE10
            ,C_ATTRIBUTE11
            ,C_ATTRIBUTE12
            ,C_ATTRIBUTE13
            ,C_ATTRIBUTE14
            ,C_ATTRIBUTE15
            ,C_ATTRIBUTE16
            ,C_ATTRIBUTE17
            ,C_ATTRIBUTE18
            ,C_ATTRIBUTE19
            ,C_ATTRIBUTE20
            ,D_ATTRIBUTE1
            ,D_ATTRIBUTE2
            ,D_ATTRIBUTE3
            ,D_ATTRIBUTE4
            ,D_ATTRIBUTE5
            ,D_ATTRIBUTE6
            ,D_ATTRIBUTE7
            ,D_ATTRIBUTE8
            ,D_ATTRIBUTE9
            ,D_ATTRIBUTE10
            ,N_ATTRIBUTE1
            ,N_ATTRIBUTE2
            ,N_ATTRIBUTE3
            ,N_ATTRIBUTE4
            ,N_ATTRIBUTE5
            ,N_ATTRIBUTE6
            ,N_ATTRIBUTE7
            ,N_ATTRIBUTE8
            ,N_ATTRIBUTE9
            ,N_ATTRIBUTE10
            ,vendor_name
            ,PARENT_OBJECT_TYPE              -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_ID                -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_NUMBER            -- R12 Genealogy Enhancements
            ,PARENT_ITEM_ID                  -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_TYPE2             -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_ID2               -- R12 Genealogy Enhancements
            ,PARENT_OBJECT_NUMBER2)          -- R12 Genealogy Enhancements
     VALUES  (p_new_txn_temp_id
            ,p_mtlt_rec.LAST_UPDATE_DATE
            ,p_mtlt_rec.LAST_UPDATED_BY
            ,p_mtlt_rec.CREATION_DATE
            ,p_mtlt_rec.CREATED_BY
            ,p_mtlt_rec.LAST_UPDATE_LOGIN
            ,p_mtlt_rec.REQUEST_ID
            ,p_mtlt_rec.PROGRAM_APPLICATION_ID
            ,p_mtlt_rec.PROGRAM_ID
            ,p_mtlt_rec.PROGRAM_UPDATE_DATE
            ,p_txn_qty
            ,p_prim_qty
            ,p_mtlt_rec.LOT_NUMBER
            ,p_mtlt_rec.LOT_EXPIRATION_DATE
            ,p_mtlt_rec.ERROR_CODE
            ,p_new_serial_trx_temp_id
            ,p_mtlt_rec.GROUP_HEADER_ID
            ,p_mtlt_rec.PUT_AWAY_RULE_ID
            ,p_mtlt_rec.PICK_RULE_ID
            ,p_mtlt_rec.DESCRIPTION
            ,p_mtlt_rec.VENDOR_ID
            ,p_mtlt_rec.SUPPLIER_LOT_NUMBER
            ,p_mtlt_rec.TERRITORY_CODE
            ,p_mtlt_rec.ORIGINATION_DATE
            ,p_mtlt_rec.DATE_CODE
            ,p_mtlt_rec.GRADE_CODE
            ,p_mtlt_rec.CHANGE_DATE
            ,p_mtlt_rec.MATURITY_DATE
            ,p_mtlt_rec.STATUS_ID
            ,p_mtlt_rec.RETEST_DATE
            ,p_mtlt_rec.AGE
            ,p_mtlt_rec.ITEM_SIZE
            ,p_mtlt_rec.COLOR
            ,p_mtlt_rec.VOLUME
            ,p_mtlt_rec.VOLUME_UOM
            ,p_mtlt_rec.PLACE_OF_ORIGIN
            ,p_mtlt_rec.BEST_BY_DATE
            ,p_mtlt_rec.LENGTH
            ,p_mtlt_rec.LENGTH_UOM
            ,p_mtlt_rec.RECYCLED_CONTENT
            ,p_mtlt_rec.THICKNESS
            ,p_mtlt_rec.THICKNESS_UOM
            ,p_mtlt_rec.WIDTH
            ,p_mtlt_rec.WIDTH_UOM
            ,p_mtlt_rec.CURL_WRINKLE_FOLD
            ,p_mtlt_rec.LOT_ATTRIBUTE_CATEGORY
            ,p_mtlt_rec.C_ATTRIBUTE1
            ,p_mtlt_rec.C_ATTRIBUTE2
            ,p_mtlt_rec.C_ATTRIBUTE3
            ,p_mtlt_rec.C_ATTRIBUTE4
            ,p_mtlt_rec.C_ATTRIBUTE5
            ,p_mtlt_rec.C_ATTRIBUTE6
            ,p_mtlt_rec.C_ATTRIBUTE7
            ,p_mtlt_rec.C_ATTRIBUTE8
            ,p_mtlt_rec.C_ATTRIBUTE9
            ,p_mtlt_rec.C_ATTRIBUTE10
            ,p_mtlt_rec.C_ATTRIBUTE11
            ,p_mtlt_rec.C_ATTRIBUTE12
            ,p_mtlt_rec.C_ATTRIBUTE13
            ,p_mtlt_rec.C_ATTRIBUTE14
            ,p_mtlt_rec.C_ATTRIBUTE15
            ,p_mtlt_rec.C_ATTRIBUTE16
            ,p_mtlt_rec.C_ATTRIBUTE17
            ,p_mtlt_rec.C_ATTRIBUTE18
            ,p_mtlt_rec.C_ATTRIBUTE19
            ,p_mtlt_rec.C_ATTRIBUTE20
            ,p_mtlt_rec.D_ATTRIBUTE1
            ,p_mtlt_rec.D_ATTRIBUTE2
            ,p_mtlt_rec.D_ATTRIBUTE3
            ,p_mtlt_rec.D_ATTRIBUTE4
            ,p_mtlt_rec.D_ATTRIBUTE5
            ,p_mtlt_rec.D_ATTRIBUTE6
            ,p_mtlt_rec.D_ATTRIBUTE7
            ,p_mtlt_rec.D_ATTRIBUTE8
            ,p_mtlt_rec.D_ATTRIBUTE9
            ,p_mtlt_rec.D_ATTRIBUTE10
            ,p_mtlt_rec.N_ATTRIBUTE1
            ,p_mtlt_rec.N_ATTRIBUTE2
            ,p_mtlt_rec.N_ATTRIBUTE3
            ,p_mtlt_rec.N_ATTRIBUTE4
            ,p_mtlt_rec.N_ATTRIBUTE5
            ,p_mtlt_rec.N_ATTRIBUTE6
            ,p_mtlt_rec.N_ATTRIBUTE7
            ,p_mtlt_rec.N_ATTRIBUTE8
            ,p_mtlt_rec.N_ATTRIBUTE9
            ,p_mtlt_rec.N_ATTRIBUTE10
            ,p_mtlt_rec.vendor_name
            ,p_mtlt_rec.PARENT_OBJECT_TYPE              -- R12 Genealogy Enhancements
            ,p_mtlt_rec.PARENT_OBJECT_ID                -- R12 Genealogy Enhancements
            ,p_mtlt_rec.PARENT_OBJECT_NUMBER            -- R12 Genealogy Enhancements
            ,p_mtlt_rec.PARENT_ITEM_ID                  -- R12 Genealogy Enhancements
            ,p_mtlt_rec.PARENT_OBJECT_TYPE2             -- R12 Genealogy Enhancements
            ,p_mtlt_rec.PARENT_OBJECT_ID2               -- R12 Genealogy Enhancements
            ,p_mtlt_rec.PARENT_OBJECT_NUMBER2);         -- R12 Genealogy Enhancements
EXCEPTION
    WHEN OTHERS THEN
     IF (l_debug = 1) THEN
        print_debug( 'proc_insert_mtlt .. EXCEP others : ' );
     END IF;
         ROLLBACK TO sp_proc_insert_mtlt;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END   proc_insert_mtlt;
--
PROCEDURE proc_insert_mmtt(p_mmtt_rec                IN   mtl_material_transactions_temp%ROWTYPE,
			   p_transfer_wms_org        IN   BOOLEAN,
			   p_fob_point               IN   NUMBER,
			   p_tfr_primary_cost_method IN   NUMBER,
			   p_tfr_org_cost_group_id   IN   NUMBER,
			   p_cost_group_id           IN   NUMBER,
			   p_transfer_cost_group_id  IN   NUMBER,
			   p_prim_qty                IN   NUMBER,
			   p_txn_qty                 IN   NUMBER,
			   p_new_txn_temp_id         IN   NUMBER,
			   p_from_project_id         IN   NUMBER,
			   p_to_project_id           IN   NUMBER,
			   x_return_status           OUT  NOCOPY VARCHAR2)
IS
   l_transfer_cost_group_id   NUMBER := NULL;
   x_valid                    VARCHAR2(1) := 'Y';
   l_comingling_occurs        VARCHAR2(1) := 'N';
   l_msg_data                 VARCHAR2(255) := NULL;
   l_msg_count                NUMBER := NULL;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   IF (l_debug = 1) THEN
      print_debug( 'Begin proc_insert_mmtt: action_id: ' ||  p_mmtt_rec.transaction_action_id );
   END IF;
   SAVEPOINT sp_proc_insert_mmtt;
   IF p_mmtt_rec.transaction_action_id IN (inv_globals.G_Action_Subxfr,
					   inv_globals.g_action_stgxfr,
					   inv_globals.g_action_ownxfr)
                                  -- Subtransfer, staging transfer
   THEN
      l_transfer_cost_group_id := p_cost_group_id;
   ELSE
      l_transfer_cost_group_id := p_transfer_cost_group_id;
   END IF;

   IF p_mmtt_rec.transaction_Action_id = inv_globals.g_action_intransitshipment THEN
      IF NOT p_transfer_wms_org AND p_fob_point = 1 THEN -- shipment
	 -- We don't care about the costing method of the org
	 l_transfer_cost_group_id := p_tfr_org_cost_group_id;
	 IF (l_debug = 1) THEN
   	 print_debug('default cost group of org ' ||  p_mmtt_rec.transfer_organization ||
		     ' : ' || l_transfer_cost_group_id);
	 END IF;
       ELSIF p_fob_point = 2 THEN -- receipt
	 l_transfer_cost_group_id := p_cost_group_id;
      END IF;
   END IF;

   IF(p_from_project_id IS NULL AND
      p_to_project_id IS NOT NULL AND
      p_mmtt_rec.transaction_action_id IN (inv_globals.g_action_subxfr,
					   inv_globals.g_action_stgxfr,
					   inv_globals.G_Action_Receipt)) then

      IF (l_debug = 1) THEN
         print_debug('inserting the transfer_cost_group to null as the dest'||
		  'locator is proj enabled');
      END IF;
      l_transfer_cost_group_id := NULL;

   END IF;

   IF (l_debug = 1) THEN
      print_debug( 'Begin proc_insert_mmtt: l_Transfer_cost_group_id: ' ||  l_Transfer_cost_group_id);
   END IF;
   INSERT INTO
     mtl_material_transactions_temp
     (
      TRANSACTION_HEADER_ID ,
      TRANSACTION_TEMP_ID   ,
      SOURCE_CODE           ,
      SOURCE_LINE_ID        ,
      TRANSACTION_MODE      ,
      LOCK_FLAG    ,
      LAST_UPDATE_DATE                   ,
      LAST_UPDATED_BY               ,
      CREATION_DATE                 ,
      CREATED_BY                    ,
      LAST_UPDATE_LOGIN             ,
      REQUEST_ID                    ,
      PROGRAM_APPLICATION_ID        ,
      PROGRAM_ID                    ,
      PROGRAM_UPDATE_DATE           ,
      INVENTORY_ITEM_ID             ,
      REVISION                      ,
      ORGANIZATION_ID               ,
      SUBINVENTORY_CODE             ,
      LOCATOR_ID                    ,
      TRANSACTION_QUANTITY          ,
      PRIMARY_QUANTITY              ,
      TRANSACTION_UOM               ,
      TRANSACTION_COST              ,
      TRANSACTION_TYPE_ID           ,
      TRANSACTION_ACTION_ID         ,
      TRANSACTION_SOURCE_TYPE_ID    ,
      TRANSACTION_SOURCE_ID         ,
     TRANSACTION_SOURCE_NAME       ,
     TRANSACTION_DATE                  ,
     ACCT_PERIOD_ID                 ,
     DISTRIBUTION_ACCOUNT_ID        ,
     TRANSACTION_REFERENCE          ,
     REQUISITION_LINE_ID            ,
     REQUISITION_DISTRIBUTION_ID    ,
     REASON_ID                      ,
     LOT_NUMBER                     ,
     LOT_EXPIRATION_DATE            ,
     SERIAL_NUMBER                  ,
     RECEIVING_DOCUMENT             ,
     DEMAND_ID                      ,
     RCV_TRANSACTION_ID             ,
     MOVE_TRANSACTION_ID            ,
     COMPLETION_TRANSACTION_ID      ,
     WIP_ENTITY_TYPE                ,
     SCHEDULE_ID                    ,
     REPETITIVE_LINE_ID             ,
     EMPLOYEE_CODE                  ,
     PRIMARY_SWITCH                 ,
     SCHEDULE_UPDATE_CODE           ,
     SETUP_TEARDOWN_CODE            ,
     ITEM_ORDERING                  ,
     NEGATIVE_REQ_FLAG              ,
     OPERATION_SEQ_NUM              ,
     PICKING_LINE_ID                ,
     TRX_SOURCE_LINE_ID             ,
     TRX_SOURCE_DELIVERY_ID         ,
     PHYSICAL_ADJUSTMENT_ID         ,
     CYCLE_COUNT_ID                 ,
     RMA_LINE_ID                    ,
     CUSTOMER_SHIP_ID               ,
     CURRENCY_CODE                  ,
     CURRENCY_CONVERSION_RATE       ,
     CURRENCY_CONVERSION_TYPE       ,
     CURRENCY_CONVERSION_DATE       ,
     USSGL_TRANSACTION_CODE         ,
     VENDOR_LOT_NUMBER              ,
     ENCUMBRANCE_ACCOUNT            ,
     ENCUMBRANCE_AMOUNT             ,
     SHIP_TO_LOCATION               ,
     SHIPMENT_NUMBER                ,
     TRANSFER_COST                  ,
     TRANSPORTATION_COST            ,
     TRANSPORTATION_ACCOUNT         ,
     FREIGHT_CODE                   ,
     CONTAINERS                     ,
     WAYBILL_AIRBILL                ,
     EXPECTED_ARRIVAL_DATE          ,
     TRANSFER_SUBINVENTORY          ,
     TRANSFER_ORGANIZATION          ,
     TRANSFER_TO_LOCATION           ,
     NEW_AVERAGE_COST               ,
     VALUE_CHANGE                   ,
     PERCENTAGE_CHANGE              ,
     MATERIAL_ALLOCATION_TEMP_ID    ,
     DEMAND_SOURCE_HEADER_ID        ,
     DEMAND_SOURCE_LINE             ,
     DEMAND_SOURCE_DELIVERY         ,
     ITEM_SEGMENTS                  ,
     ITEM_DESCRIPTION               ,
     ITEM_TRX_ENABLED_FLAG          ,
     ITEM_LOCATION_CONTROL_CODE     ,
     ITEM_RESTRICT_SUBINV_CODE      ,
     ITEM_RESTRICT_LOCATORS_CODE    ,
     ITEM_REVISION_QTY_CONTROL_CODE ,
     ITEM_PRIMARY_UOM_CODE          ,
     ITEM_UOM_CLASS                 ,
     ITEM_SHELF_LIFE_CODE           ,
     ITEM_SHELF_LIFE_DAYS           ,
     ITEM_LOT_CONTROL_CODE          ,
     ITEM_SERIAL_CONTROL_CODE       ,
     ITEM_INVENTORY_ASSET_FLAG      ,
     ALLOWED_UNITS_LOOKUP_CODE      ,
     DEPARTMENT_ID                  ,
     DEPARTMENT_CODE                ,
     WIP_SUPPLY_TYPE                ,
     SUPPLY_SUBINVENTORY            ,
     SUPPLY_LOCATOR_ID              ,
     VALID_SUBINVENTORY_FLAG        ,
     VALID_LOCATOR_FLAG             ,
     LOCATOR_SEGMENTS               ,
     CURRENT_LOCATOR_CONTROL_CODE   ,
     NUMBER_OF_LOTS_ENTERED         ,
     WIP_COMMIT_FLAG                ,
     NEXT_LOT_NUMBER                ,
     LOT_ALPHA_PREFIX               ,
     NEXT_SERIAL_NUMBER             ,
     SERIAL_ALPHA_PREFIX            ,
     SHIPPABLE_FLAG                 ,
     POSTING_FLAG                   ,
     REQUIRED_FLAG                  ,
     PROCESS_FLAG                   ,
     ERROR_CODE                     ,
     ERROR_EXPLANATION              ,
     ATTRIBUTE_CATEGORY             ,
     ATTRIBUTE1                     ,
     ATTRIBUTE2                     ,
     ATTRIBUTE3                     ,
     ATTRIBUTE4                     ,
     ATTRIBUTE5                     ,
     ATTRIBUTE6                     ,
     ATTRIBUTE7                     ,
     ATTRIBUTE8                     ,
     ATTRIBUTE9                     ,
     ATTRIBUTE10                    ,
     ATTRIBUTE11                    ,
     ATTRIBUTE12                    ,
     ATTRIBUTE13                    ,
     ATTRIBUTE14                    ,
     ATTRIBUTE15                    ,
     MOVEMENT_ID                    ,
     RESERVATION_QUANTITY           ,
     SHIPPED_QUANTITY               ,
     TRANSACTION_LINE_NUMBER        ,
     TASK_ID                        ,
     TO_TASK_ID                     ,
     SOURCE_TASK_ID                 ,
     PROJECT_ID                     ,
     SOURCE_PROJECT_ID              ,
     PA_EXPENDITURE_ORG_ID          ,
     TO_PROJECT_ID                  ,
     EXPENDITURE_TYPE               ,
     FINAL_COMPLETION_FLAG          ,
     TRANSFER_PERCENTAGE            ,
     TRANSACTION_SEQUENCE_ID        ,
     MATERIAL_ACCOUNT               ,
     MATERIAL_OVERHEAD_ACCOUNT      ,
     RESOURCE_ACCOUNT               ,
     OUTSIDE_PROCESSING_ACCOUNT     ,
     OVERHEAD_ACCOUNT               ,
     FLOW_SCHEDULE                  ,
     COST_GROUP_ID                  ,
     TRANSFER_COST_GROUP_ID         ,
     DEMAND_CLASS                   ,
     QA_COLLECTION_ID               ,
     KANBAN_CARD_ID                 ,
     OVERCOMPLETION_TRANSACTION_QTY ,
     OVERCOMPLETION_PRIMARY_QTY     ,
     OVERCOMPLETION_TRANSACTION_ID  ,
     END_ITEM_UNIT_NUMBER           ,
     SCHEDULED_PAYBACK_DATE         ,
     LINE_TYPE_CODE                 ,
     PARENT_TRANSACTION_TEMP_ID     ,
     PUT_AWAY_STRATEGY_ID           ,
     PUT_AWAY_RULE_ID               ,
     PICK_STRATEGY_ID               ,
     PICK_RULE_ID                   ,
     MOVE_ORDER_LINE_ID             ,
     TASK_GROUP_ID                  ,
     PICK_SLIP_NUMBER               ,
     RESERVATION_ID                 ,
     COMMON_BOM_SEQ_ID              ,
     COMMON_ROUTING_SEQ_ID          ,
     ORG_COST_GROUP_ID              ,
     COST_TYPE_ID                   ,
     TRANSACTION_STATUS             ,
     STANDARD_OPERATION_ID          ,
     TASK_PRIORITY                  ,
     WMS_TASK_TYPE                  ,
     PARENT_LINE_ID                 ,
     LPN_ID                         ,
     TRANSFER_LPN_ID                ,
     WMS_TASK_STATUS                ,
     CONTENT_LPN_ID                 ,
     CONTAINER_ITEM_ID              ,
     CARTONIZATION_ID               ,
     PICK_SLIP_DATE                 ,
     REBUILD_ITEM_ID                ,
     REBUILD_SERIAL_NUMBER          ,
     REBUILD_ACTIVITY_ID            ,
     REBUILD_JOB_NAME               ,
     ORGANIZATION_TYPE              ,
     TRANSFER_ORGANIZATION_TYPE     ,
     OWNING_ORGANIZATION_ID         ,
     OWNING_TP_TYPE                 ,
     XFR_OWNING_ORGANIZATION_ID     ,
     TRANSFER_OWNING_TP_TYPE        ,
     PLANNING_ORGANIZATION_ID       ,
     PLANNING_TP_TYPE               ,
     XFR_PLANNING_ORGANIZATION_ID   ,
     TRANSFER_PLANNING_TP_TYPE      ,
     SECONDARY_UOM_CODE             ,
     SECONDARY_TRANSACTION_QUANTITY ,
     TRANSACTION_BATCH_ID           ,
     TRANSACTION_BATCH_SEQ          ,
     ALLOCATED_LPN_ID               ,
     SCHEDULE_NUMBER                ,
     SCHEDULED_FLAG                 ,
     CLASS_CODE                     ,
     SCHEDULE_GROUP                 ,
     BUILD_SEQUENCE                 ,
     BOM_REVISION                   ,
     ROUTING_REVISION               ,
     BOM_REVISION_DATE              ,
     ROUTING_REVISION_DATE          ,
     ALTERNATE_BOM_DESIGNATOR       ,
     ALTERNATE_ROUTING_DESIGNATOR   ,
     OPERATION_PLAN_ID              ,
     fob_point                      ,
     intransit_account              ,
     relieve_reservations_flag      ,     /*** {{ R12 Enhanced reservations code changes ***/
     relieve_high_level_rsv_flag          /*** {{ R12 Enhanced reservations code changes ***/
     )
     values
     (p_mmtt_rec.TRANSACTION_HEADER_ID ,
      p_new_txn_temp_id   ,
      p_mmtt_rec.SOURCE_CODE           ,
      p_mmtt_rec.SOURCE_LINE_ID        ,
      p_mmtt_rec.TRANSACTION_MODE      ,
      p_mmtt_rec.LOCK_FLAG    ,
      p_mmtt_rec.LAST_UPDATE_DATE                   ,
      p_mmtt_rec.LAST_UPDATED_BY               ,
      p_mmtt_rec.CREATION_DATE                 ,
      p_mmtt_rec.CREATED_BY                    ,
      p_mmtt_rec.LAST_UPDATE_LOGIN             ,
      p_mmtt_rec.REQUEST_ID                    ,
      p_mmtt_rec.PROGRAM_APPLICATION_ID        ,
      p_mmtt_rec.PROGRAM_ID                    ,
      p_mmtt_rec.PROGRAM_UPDATE_DATE           ,
      p_mmtt_rec.INVENTORY_ITEM_ID             ,
      p_mmtt_rec.REVISION                      ,
      p_mmtt_rec.ORGANIZATION_ID               ,
      p_mmtt_rec.SUBINVENTORY_CODE             ,
      p_mmtt_rec.LOCATOR_ID                    ,
      p_txn_qty ,
      p_prim_qty ,
      p_mmtt_rec.TRANSACTION_UOM               ,
      p_mmtt_rec.TRANSACTION_COST              ,
     p_mmtt_rec.TRANSACTION_TYPE_ID           ,
     p_mmtt_rec.TRANSACTION_ACTION_ID         ,
     p_mmtt_rec.TRANSACTION_SOURCE_TYPE_ID    ,
     p_mmtt_rec.TRANSACTION_SOURCE_ID         ,
     p_mmtt_rec.TRANSACTION_SOURCE_NAME       ,
     p_mmtt_rec.TRANSACTION_DATE               ,
     p_mmtt_rec.ACCT_PERIOD_ID                 ,
     p_mmtt_rec.DISTRIBUTION_ACCOUNT_ID        ,
     p_mmtt_rec.TRANSACTION_REFERENCE          ,
     p_mmtt_rec.REQUISITION_LINE_ID            ,
     p_mmtt_rec.REQUISITION_DISTRIBUTION_ID    ,
     p_mmtt_rec.REASON_ID                      ,
     p_mmtt_rec.LOT_NUMBER                     ,
     p_mmtt_rec.LOT_EXPIRATION_DATE            ,
     p_mmtt_rec.SERIAL_NUMBER                  ,
     p_mmtt_rec.RECEIVING_DOCUMENT             ,
     p_mmtt_rec.DEMAND_ID                      ,
     p_mmtt_rec.RCV_TRANSACTION_ID             ,
     p_mmtt_rec.MOVE_TRANSACTION_ID            ,
     p_mmtt_rec.COMPLETION_TRANSACTION_ID      ,
     p_mmtt_rec.WIP_ENTITY_TYPE                ,
     p_mmtt_rec.SCHEDULE_ID                    ,
     p_mmtt_rec.REPETITIVE_LINE_ID             ,
     p_mmtt_rec.EMPLOYEE_CODE                  ,
     p_mmtt_rec.PRIMARY_SWITCH                 ,
     p_mmtt_rec.SCHEDULE_UPDATE_CODE           ,
     p_mmtt_rec.SETUP_TEARDOWN_CODE            ,
     p_mmtt_rec.ITEM_ORDERING                  ,
     p_mmtt_rec.NEGATIVE_REQ_FLAG              ,
     p_mmtt_rec.OPERATION_SEQ_NUM              ,
     p_mmtt_rec.PICKING_LINE_ID                ,
     p_mmtt_rec.TRX_SOURCE_LINE_ID             ,
     p_mmtt_rec.TRX_SOURCE_DELIVERY_ID         ,
     p_mmtt_rec.PHYSICAL_ADJUSTMENT_ID         ,
     p_mmtt_rec.CYCLE_COUNT_ID                 ,
     p_mmtt_rec.RMA_LINE_ID                    ,
     p_mmtt_rec.CUSTOMER_SHIP_ID               ,
     p_mmtt_rec.CURRENCY_CODE                  ,
     p_mmtt_rec.CURRENCY_CONVERSION_RATE       ,
     p_mmtt_rec.CURRENCY_CONVERSION_TYPE       ,
     p_mmtt_rec.CURRENCY_CONVERSION_DATE       ,
     p_mmtt_rec.USSGL_TRANSACTION_CODE         ,
     p_mmtt_rec.VENDOR_LOT_NUMBER              ,
     p_mmtt_rec.ENCUMBRANCE_ACCOUNT            ,
     p_mmtt_rec.ENCUMBRANCE_AMOUNT             ,
     p_mmtt_rec.SHIP_TO_LOCATION               ,
     p_mmtt_rec.SHIPMENT_NUMBER                ,
     p_mmtt_rec.TRANSFER_COST                  ,
     p_mmtt_rec.TRANSPORTATION_COST            ,
     p_mmtt_rec.TRANSPORTATION_ACCOUNT         ,
     p_mmtt_rec.FREIGHT_CODE                   ,
     p_mmtt_rec.CONTAINERS                     ,
     p_mmtt_rec.WAYBILL_AIRBILL                ,
     p_mmtt_rec.EXPECTED_ARRIVAL_DATE          ,
     p_mmtt_rec.TRANSFER_SUBINVENTORY          ,
     p_mmtt_rec.TRANSFER_ORGANIZATION          ,
     p_mmtt_rec.TRANSFER_TO_LOCATION           ,
     p_mmtt_rec.NEW_AVERAGE_COST               ,
     p_mmtt_rec.VALUE_CHANGE                   ,
     p_mmtt_rec.PERCENTAGE_CHANGE              ,
     p_mmtt_rec.MATERIAL_ALLOCATION_TEMP_ID    ,
     p_mmtt_rec.DEMAND_SOURCE_HEADER_ID        ,
     p_mmtt_rec.DEMAND_SOURCE_LINE             ,
     p_mmtt_rec.DEMAND_SOURCE_DELIVERY         ,
     p_mmtt_rec.ITEM_SEGMENTS                  ,
     p_mmtt_rec.ITEM_DESCRIPTION               ,
     p_mmtt_rec.ITEM_TRX_ENABLED_FLAG          ,
     p_mmtt_rec.ITEM_LOCATION_CONTROL_CODE     ,
     p_mmtt_rec.ITEM_RESTRICT_SUBINV_CODE      ,
     p_mmtt_rec.ITEM_RESTRICT_LOCATORS_CODE    ,
     p_mmtt_rec.ITEM_REVISION_QTY_CONTROL_CODE ,
     p_mmtt_rec.ITEM_PRIMARY_UOM_CODE          ,
     p_mmtt_rec.ITEM_UOM_CLASS                 ,
     p_mmtt_rec.ITEM_SHELF_LIFE_CODE           ,
     p_mmtt_rec.ITEM_SHELF_LIFE_DAYS           ,
     p_mmtt_rec.ITEM_LOT_CONTROL_CODE          ,
     p_mmtt_rec.ITEM_SERIAL_CONTROL_CODE       ,
     p_mmtt_rec.ITEM_INVENTORY_ASSET_FLAG      ,
     p_mmtt_rec.ALLOWED_UNITS_LOOKUP_CODE      ,
     p_mmtt_rec.DEPARTMENT_ID                  ,
     p_mmtt_rec.DEPARTMENT_CODE                ,
     p_mmtt_rec.WIP_SUPPLY_TYPE                ,
     p_mmtt_rec.SUPPLY_SUBINVENTORY            ,
     p_mmtt_rec.SUPPLY_LOCATOR_ID              ,
     p_mmtt_rec.VALID_SUBINVENTORY_FLAG        ,
     p_mmtt_rec.VALID_LOCATOR_FLAG             ,
     p_mmtt_rec.LOCATOR_SEGMENTS               ,
     p_mmtt_rec.CURRENT_LOCATOR_CONTROL_CODE   ,
     p_mmtt_rec.NUMBER_OF_LOTS_ENTERED         ,
     p_mmtt_rec.WIP_COMMIT_FLAG                ,
     p_mmtt_rec.NEXT_LOT_NUMBER                ,
     p_mmtt_rec.LOT_ALPHA_PREFIX               ,
     p_mmtt_rec.NEXT_SERIAL_NUMBER             ,
     p_mmtt_rec.SERIAL_ALPHA_PREFIX            ,
     p_mmtt_rec.SHIPPABLE_FLAG                 ,
     p_mmtt_rec.POSTING_FLAG                   ,
     p_mmtt_rec.REQUIRED_FLAG                  ,
     p_mmtt_rec.PROCESS_FLAG                   ,
     p_mmtt_rec.ERROR_CODE                     ,
     p_mmtt_rec.ERROR_EXPLANATION              ,
     p_mmtt_rec.ATTRIBUTE_CATEGORY             ,
     p_mmtt_rec.ATTRIBUTE1                     ,
     p_mmtt_rec.ATTRIBUTE2                     ,
     p_mmtt_rec.ATTRIBUTE3                     ,
     p_mmtt_rec.ATTRIBUTE4                     ,
     p_mmtt_rec.ATTRIBUTE5                     ,
     p_mmtt_rec.ATTRIBUTE6                     ,
     p_mmtt_rec.ATTRIBUTE7                     ,
     p_mmtt_rec.ATTRIBUTE8                     ,
     p_mmtt_rec.ATTRIBUTE9                     ,
     p_mmtt_rec.ATTRIBUTE10                    ,
     p_mmtt_rec.ATTRIBUTE11                    ,
     p_mmtt_rec.ATTRIBUTE12                    ,
     p_mmtt_rec.ATTRIBUTE13                    ,
     p_mmtt_rec.ATTRIBUTE14                    ,
     p_mmtt_rec.ATTRIBUTE15                    ,
     p_mmtt_rec.MOVEMENT_ID                    ,
     p_mmtt_rec.RESERVATION_QUANTITY           ,
     p_mmtt_rec.SHIPPED_QUANTITY               ,
     p_mmtt_rec.TRANSACTION_LINE_NUMBER        ,
     p_mmtt_rec.TASK_ID                        ,
     p_mmtt_rec.TO_TASK_ID                     ,
     p_mmtt_rec.SOURCE_TASK_ID                 ,
     p_mmtt_rec.PROJECT_ID                     ,
     p_mmtt_rec.SOURCE_PROJECT_ID              ,
     p_mmtt_rec.PA_EXPENDITURE_ORG_ID          ,
     p_mmtt_rec.TO_PROJECT_ID                  ,
     p_mmtt_rec.EXPENDITURE_TYPE               ,
     p_mmtt_rec.FINAL_COMPLETION_FLAG          ,
     p_mmtt_rec.TRANSFER_PERCENTAGE            ,
     p_mmtt_rec.TRANSACTION_SEQUENCE_ID        ,
     p_mmtt_rec.MATERIAL_ACCOUNT               ,
     p_mmtt_rec.MATERIAL_OVERHEAD_ACCOUNT      ,
     p_mmtt_rec.RESOURCE_ACCOUNT               ,
     p_mmtt_rec.OUTSIDE_PROCESSING_ACCOUNT     ,
     p_mmtt_rec.OVERHEAD_ACCOUNT               ,
     p_mmtt_rec.FLOW_SCHEDULE                  ,
     p_cost_group_id ,
     l_transfer_cost_group_id ,
     p_mmtt_rec.DEMAND_CLASS                   ,
     p_mmtt_rec.QA_COLLECTION_ID               ,
     p_mmtt_rec.KANBAN_CARD_ID                 ,
     p_mmtt_rec.OVERCOMPLETION_TRANSACTION_QTY ,
     p_mmtt_rec.OVERCOMPLETION_PRIMARY_QTY     ,
     p_mmtt_rec.OVERCOMPLETION_TRANSACTION_ID  ,
     p_mmtt_rec.END_ITEM_UNIT_NUMBER           ,
     p_mmtt_rec.SCHEDULED_PAYBACK_DATE         ,
     p_mmtt_rec.LINE_TYPE_CODE                 ,
     p_mmtt_rec.PARENT_TRANSACTION_TEMP_ID     ,
     p_mmtt_rec.PUT_AWAY_STRATEGY_ID           ,
     p_mmtt_rec.PUT_AWAY_RULE_ID               ,
     p_mmtt_rec.PICK_STRATEGY_ID               ,
     p_mmtt_rec.PICK_RULE_ID                   ,
     p_mmtt_rec.MOVE_ORDER_LINE_ID             ,
     p_mmtt_rec.TASK_GROUP_ID                  ,
     p_mmtt_rec.PICK_SLIP_NUMBER               ,
     p_mmtt_rec.RESERVATION_ID                 ,
     p_mmtt_rec.COMMON_BOM_SEQ_ID              ,
     p_mmtt_rec.COMMON_ROUTING_SEQ_ID          ,
     p_mmtt_rec.ORG_COST_GROUP_ID              ,
     p_mmtt_rec.COST_TYPE_ID                   ,
     p_mmtt_rec.TRANSACTION_STATUS             ,
     p_mmtt_rec.STANDARD_OPERATION_ID          ,
     p_mmtt_rec.TASK_PRIORITY                  ,
     p_mmtt_rec.WMS_TASK_TYPE                  ,
     p_mmtt_rec.PARENT_LINE_ID                 ,
     p_mmtt_rec.LPN_ID                         ,
     p_mmtt_rec.TRANSFER_LPN_ID                ,
     p_mmtt_rec.WMS_TASK_STATUS                ,
     p_mmtt_rec.CONTENT_LPN_ID                 ,
     p_mmtt_rec.CONTAINER_ITEM_ID              ,
     p_mmtt_rec.CARTONIZATION_ID               ,
     p_mmtt_rec.PICK_SLIP_DATE                 ,
     p_mmtt_rec.REBUILD_ITEM_ID                ,
     p_mmtt_rec.REBUILD_SERIAL_NUMBER          ,
     p_mmtt_rec.REBUILD_ACTIVITY_ID            ,
     p_mmtt_rec.REBUILD_JOB_NAME               ,
     p_mmtt_rec.ORGANIZATION_TYPE              ,
     p_mmtt_rec.TRANSFER_ORGANIZATION_TYPE     ,
     p_mmtt_rec.OWNING_ORGANIZATION_ID         ,
     p_mmtt_rec.OWNING_TP_TYPE                 ,
     p_mmtt_rec.XFR_OWNING_ORGANIZATION_ID     ,
     p_mmtt_rec.TRANSFER_OWNING_TP_TYPE        ,
     p_mmtt_rec.PLANNING_ORGANIZATION_ID       ,
     p_mmtt_rec.PLANNING_TP_TYPE               ,
     p_mmtt_rec.XFR_PLANNING_ORGANIZATION_ID   ,
     p_mmtt_rec.TRANSFER_PLANNING_TP_TYPE      ,
     p_mmtt_rec.SECONDARY_UOM_CODE             ,
     p_mmtt_rec.SECONDARY_TRANSACTION_QUANTITY ,
     p_mmtt_rec.TRANSACTION_BATCH_ID           ,
     p_mmtt_rec.TRANSACTION_BATCH_SEQ          ,
     p_mmtt_rec.ALLOCATED_LPN_ID               ,
     p_mmtt_rec.SCHEDULE_NUMBER                ,
     p_mmtt_rec.SCHEDULED_FLAG                 ,
     p_mmtt_rec.CLASS_CODE                     ,
     p_mmtt_rec.SCHEDULE_GROUP                 ,
     p_mmtt_rec.BUILD_SEQUENCE                 ,
     p_mmtt_rec.BOM_REVISION                   ,
     p_mmtt_rec.ROUTING_REVISION               ,
     p_mmtt_rec.BOM_REVISION_DATE              ,
     p_mmtt_rec.ROUTING_REVISION_DATE          ,
     p_mmtt_rec.ALTERNATE_BOM_DESIGNATOR       ,
     p_mmtt_rec.ALTERNATE_ROUTING_DESIGNATOR   ,
     p_mmtt_rec.OPERATION_PLAN_ID              ,
     p_mmtt_rec.fob_point                      ,
     p_mmtt_rec.intransit_account              ,
     p_mmtt_rec.relieve_reservations_flag      ,  /*** {{ R12 Enhanced reservations code changes ***/
     p_mmtt_rec.relieve_high_level_rsv_flag       /*** {{ R12 Enhanced reservations code changes ***/
     ) ;

   inv_comingling_utils.comingle_check
     (x_return_status                 => x_return_status
      , x_msg_count                   => L_msg_count
      , x_msg_data                    => L_msg_data
      , x_comingling_occurs           => l_comingling_occurs
      , p_transaction_temp_id         => p_mmtt_rec.transaction_temp_id);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
	       RAISE fnd_api.g_exc_unexpected_error;
    ELSIF l_comingling_occurs = 'Y' THEN
      IF (l_debug = 1) THEN
         print_debug('proc_insert_mmtt .. comigling occurs : ' );
      END IF;
      --Commenting these because this message is getting added
      --in INVCOMUB.pls
      --fnd_message.set_name('INV', 'INV_COMINGLE_ERROR');
      --fnd_msg_pub.add;
      x_return_status := inv_cost_group_pvt.g_comingle_error;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR ;
         IF (l_debug = 1) THEN
            print_debug('proc_insert_mmtt .. EXCEP G_EXC_ERROR : ' );
         END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF (l_debug = 1) THEN
            print_debug('proc_insert_mmtt .. EXCEP G_EXC_UNEXPECTED_ERROR : ' );
         END IF;
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug = 1) THEN
          print_debug('proc_insert_mmtt .. EXCEP others: ' || SQLERRM(SQLCODE) );
       END IF;
END proc_insert_mmtt;
--

PROCEDURE proc_process_nocontrol
  (p_mmtt_rec                IN  mtl_material_transactions_temp%ROWTYPE,
   p_fob_point               IN  NUMBER,
   p_transfer_wms_org        IN  BOOLEAN,
   p_tfr_primary_cost_method IN  NUMBER,
   p_tfr_org_cost_group_id   IN  NUMBER,
   p_from_project_id         IN  NUMBER,
   p_to_project_id           IN  NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT  NOCOPY NUMBER,
   x_msg_data                OUT  NOCOPY VARCHAR2)
IS
   l_cost_group_id    NUMBER  := -99999;
   l_lpn_id           NUMBER  := p_mmtt_rec.lpn_id;
   l_onhand_exists    BOOLEAN := TRUE;
   l_is_backflush_txn BOOLEAN := FALSE;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   IF (l_debug = 1) THEN
      print_debug( 'in proc_process_nocontrol p_mmtt_rec.transaction_temp_id:'  || p_mmtt_rec.transaction_temp_id || ':');
      print_debug( '1: '||p_mmtt_rec.organization_id      || ':');
      print_debug( '2: '||p_mmtt_rec.inventory_item_id    || ':');
      print_debug( '3: '||p_mmtt_rec.subinventory_code    || ':');
      print_debug( '4: '||p_mmtt_rec.locator_id           || ':');
      print_debug( '5: '||p_mmtt_rec.revision             || ':');
   END IF;

   IF p_mmtt_rec.transaction_action_id IN (inv_globals.g_type_cycle_count_adj,
					   inv_globals.g_type_physical_count_adj,
					   inv_globals.g_action_deliveryadj)
     THEN
      IF p_mmtt_rec.transaction_action_id = inv_globals.g_type_physical_count_adj THEN
	 IF p_mmtt_rec.lpn_id IS NOT NULL THEN
	    l_lpn_id := p_mmtt_rec.lpn_id;
	  ELSIF p_mmtt_rec.content_lpn_id IS NOT NULL THEN
	    l_lpn_id := p_mmtt_rec.content_lpn_id;
	  ELSIF p_mmtt_rec.transfer_lpn_id IS NOT NULL THEN
	    l_lpn_id := p_mmtt_rec.transfer_lpn_id;
	 END IF;
       ELSIF p_mmtt_rec.transaction_action_id = inv_globals.g_action_deliveryadj THEN
	 l_lpn_id := p_mmtt_rec.transfer_lpn_id;
       ELSIF p_mmtt_rec.transaction_action_id = inv_globals.g_type_cycle_count_adj THEN
	 l_lpn_id := p_mmtt_rec.transfer_lpn_id;
      END IF;

      l_onhand_exists :=
	onhand_quantity_exists
	(p_inventory_item_id => p_mmtt_rec.inventory_item_id,
	 p_revision          => p_mmtt_rec.revision,
	 p_organization_id   => p_mmtt_rec.organization_id,
	 p_subinventory_code => p_mmtt_rec.subinventory_code,
	 p_locator_id        => p_mmtt_rec.locator_id,
	 p_lot_number        => NULL,
	 p_serial_number     => NULL,
	 p_lpn_id            => l_lpn_id);
      IF NOT l_onhand_exists THEN
	 IF (l_debug = 1) THEN
   	 print_debug('Treating this as as receipt transaction...: ');
   	 print_debug('Getting transfer cost group id from rules engine...: ');
	 END IF;
	 wms_costgroupengine_pvt.assign_cost_group
	   (p_api_version => 1.0,
	    p_init_msg_list => FND_API.G_FALSE,
	    p_commit => FND_API.G_FALSE,
	    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	    x_return_status => x_return_Status,
	    x_msg_count => x_msg_count,
	    x_msg_data => x_msg_data,
	    p_line_id  => p_mmtt_rec.transaction_temp_id,
	    p_input_type => wms_costgroupengine_pvt.g_input_mmtt);

	 IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	    IF (l_debug = 1) THEN
   	    print_debug('return error from wms_costgroupengine_pvt');
	    END IF;
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	    IF (l_debug = 1) THEN
   	    print_debug('return unexpected error from wms_costgroupengine_pvt');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;
    ELSIF (p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_salesorder
	   OR p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_intorder)
      AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_issue
	   OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_subxfr
	   OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_orgxfr
	   OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_intransitshipment)
      THEN -- For a ship confirm transaction, get the cost group from the content lpn ID
      l_lpn_id := p_mmtt_rec.content_lpn_id;
      /* Bug 4628878: For staging transfers, when whole LPN is being transfered, cost group should
      * be obtained from content_lpn_id  */

      /*8650417 Added the following IF to handle Bill only WF from OM*/
      IF (l_lpn_id IS NULL AND p_mmtt_rec.transaction_action_id = inv_globals.g_action_issue) THEN
           l_lpn_id := p_mmtt_rec.lpn_id;
      END IF;

    ELSIF (
        ((p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_salesorder
             OR p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_intorder)
          AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_stgxfr))
       OR /*Bug 6499833:For move order sub transfers,trying to get the costgroup from content_lpn_id.*/
         (( p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_moveorder)
          AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_subxfr))
      )
      --   AND (p_mmtt_rec.lpn_id IS NULL) Bug#6770593
	   AND (p_mmtt_rec.content_lpn_id IS NOT NULL)
	   AND (p_mmtt_rec.inventory_item_id <> -1)
      THEN -- For a staging transfer transaction with content_lpn_id, get the cost group from the content lpn ID
      l_lpn_id := p_mmtt_rec.content_lpn_id;
   END IF;
   IF (l_debug = 1) THEN
      print_debug('l_lpn_id is set to: '||l_lpn_id);
   END IF;

   IF l_onhand_exists THEN

      IF p_mmtt_rec.move_transaction_id IS NOT NULL OR
	p_mmtt_rec.completion_transaction_id IS NOT NULL THEN
	 l_is_backflush_txn := TRUE;
      END IF;

      proc_determine_costgroup(p_organization_id         =>   p_mmtt_rec.organization_id,
			       p_inventory_item_id       =>   p_mmtt_rec.inventory_item_id,
			       p_subinventory_code       =>   p_mmtt_rec.subinventory_code,
			       p_locator_id              =>   p_mmtt_rec.locator_id,
			       p_revision                =>   p_mmtt_rec.revision,
			       p_lot_number              =>   NULL,
			       p_serial_number           =>   NULL,
			       p_containerized_flag      =>   2, -- we need unpacked material from moq
			       p_lpn_id                  =>   l_lpn_id,
			       p_transaction_action_id   =>   p_mmtt_rec.transaction_action_id,
			       p_is_backflush_txn        =>   l_is_backflush_txn,
			       x_cost_group_id           =>   l_cost_group_id,
			       x_return_status           =>   x_return_status);

      IF (l_debug = 1) THEN
         print_debug('proc_determine_costgroup return : ' || x_return_status);
         print_debug('proc_determine_costgroup cg : ' || l_cost_group_id);
      END IF;
      IF (x_return_status =  fnd_api.g_ret_sts_error)
	THEN
	 RAISE fnd_api.g_exc_error ;
      END IF;

      IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	THEN
	 RAISE fnd_api.g_exc_unexpected_error ;
      END IF;

      IF (l_debug = 1) THEN
         print_debug('call :proc_update_mmtt :p_transaction_temp_id: ' || p_mmtt_rec.transaction_temp_id);
         print_debug('call :proc_update_mmtt :l_cost_group_id: ' || l_cost_group_id);
      END IF;

      proc_update_mmtt(p_transaction_temp_id     => p_mmtt_rec.transaction_temp_id,
		       p_transfer_wms_org        => p_transfer_wms_org,
		       p_fob_point               => p_fob_point,
		       p_tfr_primary_cost_method => p_tfr_primary_cost_method,
		       p_tfr_org_cost_group_id   => p_tfr_org_cost_group_id,
		       p_transaction_action_id   => p_mmtt_rec.transaction_action_id,
		       p_transfer_organization   => p_mmtt_rec.transfer_organization,
		       p_transfer_subinventory   => p_mmtt_rec.transfer_subinventory,
		       p_cost_group_id           => l_cost_group_id,
		       p_transfer_cost_group_id  => NULL,
		       p_primary_quantity        => NULL,
		       p_transaction_quantity    => NULL,
		       p_from_project_id         => p_from_project_id,
		       p_to_project_id           => p_to_project_id,
		       x_return_status           => x_return_status);

      IF (l_debug = 1) THEN
         print_debug('proc_update_mmtt return : ' || x_return_status);
      END IF;
      IF (x_return_status =  fnd_api.g_ret_sts_error)
	THEN
	 RAISE fnd_api.g_exc_error ;
      END IF;

      IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	THEN
	 RAISE fnd_api.g_exc_unexpected_error ;
      END IF;
   END IF; -- Onhand exists

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF (l_debug = 1) THEN
         print_debug('no process control .. EXCEP G_EXC_ERROR : ' );
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (l_debug = 1) THEN
         print_debug('no process control .. EXCEP G_EXC_UNEXPECTED_ERROR : ' );
      END IF;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 1) THEN
         print_debug('no process control .. EXCEP OTHERS : ' );
      END IF;
END proc_process_nocontrol;


-- Processes lot  controlled items. This involves splitting
-- MMTT and updating MTLT lines so that each row corresponds to a unique cost
-- group.
PROCEDURE proc_process_lots
  (p_mmtt_rec                IN  mtl_material_transactions_temp%ROWTYPE,
   p_fob_point               IN  NUMBER,
   p_transfer_wms_org        IN  BOOLEAN,
   p_tfr_primary_cost_method IN  NUMBER,
   p_tfr_org_cost_group_id   IN  NUMBER,
   p_from_project_id         IN  NUMBER,
   p_to_project_id           IN  NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT  NOCOPY NUMBER,
   x_msg_data                OUT  NOCOPY VARCHAR2)
  IS
     l_api_name CONSTANT VARCHAR2(100) := 'proc_process_lots';
     l_transaction_temp_id NUMBER := NULL;
     i                        INTEGER;
     j                        INTEGER;
     l_transaction_quantity   NUMBER;
     l_quantity_sign          NUMBER;
     l_cost_group_id          NUMBER;

     -- For putting records in MTLT and MSNT tables
     TYPE lots_record IS RECORD
       (mtlt_rowid            ROWID,
	cost_group_id         NUMBER);
     TYPE lots_table IS TABLE OF lots_record INDEX BY BINARY_INTEGER;
     l_lots_table   lots_table;
     l_lti          INTEGER := 0;

     TYPE cg_quantity_record IS RECORD
       (new_transaction_temp_id NUMBER,
	primary_quantity        NUMBER,
	transaction_quantity    NUMBER,
	update_mmtt             BOOLEAN);
     TYPE cg_quantity_table IS TABLE OF cg_quantity_record INDEX BY BINARY_INTEGER;
     l_cg_quantity_table cg_quantity_table;

     rec_mtlt cur_mtlt%ROWTYPE;

     l_onhand_exists    BOOLEAN;
     l_is_backflush_txn BOOLEAN := FALSE;
     l_lpn_id           NUMBER := p_mmtt_rec.lpn_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  x_return_status := fnd_api.g_ret_sts_success;
  SAVEPOINT sp_proc_process_lots;

  IF (l_debug = 1) THEN
     print_debug('IN proc_process_lots.. ');
  END IF;

  OPEN cur_mtlt(p_mmtt_rec.transaction_temp_id);

  FETCH cur_mtlt INTO rec_mtlt;

  WHILE cur_mtlt%found LOOP
     IF (l_debug = 1) THEN
        print_debug('Within cur_mtlt loop... ' || rec_mtlt.lot_number);
     END IF;

     l_onhand_exists := TRUE;

     -- Adjustment transactions
     IF p_mmtt_rec.transaction_action_id IN (inv_globals.g_type_cycle_count_adj,
					      inv_globals.g_type_physical_count_adj,
					      inv_globals.g_action_deliveryadj)
       THEN
	IF p_mmtt_rec.transaction_action_id = inv_globals.g_type_physical_count_adj THEN
	   IF p_mmtt_rec.lpn_id IS NOT NULL THEN
	      l_lpn_id := p_mmtt_rec.lpn_id;
	    ELSIF p_mmtt_rec.content_lpn_id IS NOT NULL THEN
	      l_lpn_id := p_mmtt_rec.content_lpn_id;
	    ELSIF p_mmtt_rec.transfer_lpn_id IS NOT NULL THEN
	      l_lpn_id := p_mmtt_rec.transfer_lpn_id;
	   END IF;
	 ELSIF p_mmtt_rec.transaction_action_id = inv_globals.g_action_deliveryadj THEN
	   l_lpn_id := p_mmtt_rec.transfer_lpn_id;
	 ELSIF p_mmtt_rec.transaction_action_id = inv_globals.g_type_cycle_count_adj THEN
	   l_lpn_id := p_mmtt_rec.transfer_lpn_id;
	END IF;

	l_onhand_exists :=
	  onhand_quantity_exists
	  (p_inventory_item_id => p_mmtt_rec.inventory_item_id,
	   p_revision          => p_mmtt_rec.revision,
	   p_organization_id   => p_mmtt_rec.organization_id,
	   p_subinventory_code => p_mmtt_rec.subinventory_code,
	   p_locator_id        => p_mmtt_rec.locator_id,
	   p_lot_number        => rec_mtlt.lot_number,
	   p_serial_number     => NULL,
	   p_lpn_id            => l_lpn_id);
	IF NOT l_onhand_exists THEN
	   IF (l_debug = 1) THEN
   	   print_debug('Treating this as as receipt transaction...: ');
   	   print_debug('Getting transfer cost group id from rules engine...: ');
	   END IF;

	   wms_costgroupengine_pvt.assign_cost_group
	     (p_api_version => 1.0,
	      p_init_msg_list => FND_API.G_FALSE,
	      p_commit => FND_API.G_FALSE,
	      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	      x_return_status => x_return_Status,
	      x_msg_count => x_msg_count,
	      x_msg_data => x_msg_data,
	      p_line_id  => p_mmtt_rec.transaction_temp_id,
	      p_input_type => wms_costgroupengine_pvt.g_input_mmtt);

	   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	      IF (l_debug = 1) THEN
   	      print_debug('return error from wms_costgroupengine_pvt');
	      END IF;
	      RAISE FND_API.G_EXC_ERROR;
	    ELSIF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	      IF (l_debug = 1) THEN
   	      print_debug('return unexpected error from wms_costgroupengine_pvt');
	      END IF;
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;
	END IF;
      ELSIF (p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_salesorder
	     OR p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_intorder)
	AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_issue
	     OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_subxfr
	     OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_orgxfr
	     OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_intransitshipment)
	THEN -- For a ship confirm transaction, get the cost group from the content lpn ID
	l_lpn_id := p_mmtt_rec.content_lpn_id;
      /* Bug 4628878: For staging transfers, when whole LPN is being transfered, cost group should
	* be obtained from content_lpn_id  */

      /*8650417 Added the following IF to handle Bill only WF from OM*/
      IF (l_lpn_id IS NULL AND p_mmtt_rec.transaction_action_id = inv_globals.g_action_issue) THEN
           l_lpn_id := p_mmtt_rec.lpn_id;
      END IF;

   ELSIF (
        ((p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_salesorder
             OR p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_intorder)
          AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_stgxfr))
       OR/*Bug 6499833:For move order sub transfers,trying to get the costgroup from content_lpn_id.*/
         (( p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_moveorder)
          AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_subxfr))
      )
       --  AND (p_mmtt_rec.lpn_id IS NULL) 	Bug#6770593
	   AND (p_mmtt_rec.content_lpn_id IS NOT NULL)
	   AND (p_mmtt_rec.inventory_item_id <> -1)
      THEN -- For a staging transfer transaction with content_lpn_id, get the cost group from the content lpn ID
      l_lpn_id := p_mmtt_rec.content_lpn_id;
     END IF;
     IF (l_debug = 1) THEN
	print_debug('l_lpn_id is set to: '||l_lpn_id);
     END IF;

     IF l_onhand_exists THEN
	l_lti := l_lti + 1;
	IF (l_debug = 1) THEN
   	print_debug('trx_id: ' || p_mmtt_rec.transaction_temp_id);
   	print_debug('Row ID: ' || rec_mtlt.mtlt_rowid);
	END IF;

	l_lots_table(l_lti).mtlt_rowid := rec_mtlt.mtlt_rowid;

	IF p_mmtt_rec.move_transaction_id IS NOT NULL OR
	  p_mmtt_rec.completion_transaction_id IS NOT NULL THEN
	   l_is_backflush_txn := TRUE;
	END IF;

	-- Get the cost group for this MTLT record
	proc_determine_costgroup(p_organization_id       =>   p_mmtt_rec.organization_id,
				 p_inventory_item_id     =>   p_mmtt_rec.inventory_item_id,
				 p_subinventory_code     =>   p_mmtt_rec.subinventory_code,
				 p_locator_id            =>   p_mmtt_rec.locator_id,
				 p_revision              =>   p_mmtt_rec.revision,
				 p_lot_number            =>   rec_mtlt.lot_number,
				 p_serial_number         =>   NULL,
				 p_containerized_flag    =>   2, -- we need unpacked material from moq
				 p_lpn_id                =>   l_lpn_id,
				 p_transaction_action_id =>   p_mmtt_rec.transaction_action_id,
				 p_is_backflush_txn      =>   l_is_backflush_txn,
				 x_cost_group_id         =>   l_cost_group_id,
				 x_return_status         =>   x_return_status);


	l_lots_table(l_lti).cost_group_id := l_cost_group_id;

	IF x_return_status =  fnd_api.g_ret_sts_error THEN
	   RAISE fnd_api.g_exc_error ;
	END IF;

	IF l_cg_quantity_table.exists(l_cost_group_id) THEN
	   l_cg_quantity_table(l_cost_group_id).primary_quantity :=
	     l_cg_quantity_table(l_cost_group_id).primary_quantity +
	     Abs(rec_mtlt.primary_quantity);

	   l_cg_quantity_table(l_cost_group_id).transaction_quantity :=
	     l_cg_quantity_table(l_cost_group_id).transaction_quantity +
	     Abs(rec_mtlt.transaction_quantity);
	 ELSE
	   IF l_cg_quantity_table.COUNT = 0 THEN
	      -- If the table is empty then the existing
	      -- transaction_temp_id should be used as the
	      -- new_transaction_temp_id also
	      l_cg_quantity_table(l_cost_group_id).new_transaction_temp_id := p_mmtt_rec.transaction_temp_id;
	      l_cg_quantity_table(l_cost_group_id).update_mmtt := TRUE;
	    ELSE
	      -- otherwise generate a new_transaction_temp_id
	      SELECT mtl_material_transactions_s.NEXTVAL
		INTO l_transaction_temp_id
		FROM dual;
	      l_cg_quantity_table(l_cost_group_id).new_transaction_temp_id := l_transaction_temp_id;
	      l_cg_quantity_table(l_cost_group_id).update_mmtt := FALSE;
	   END IF;
	   l_cg_quantity_table(l_cost_group_id).primary_quantity := Abs(rec_mtlt.primary_quantity);
	   l_cg_quantity_table(l_cost_group_id).transaction_quantity := Abs(rec_mtlt.transaction_quantity);
	END IF;
     END IF; -- If onhand exists

     FETCH cur_mtlt INTO rec_mtlt;
  END LOOP;

  CLOSE cur_mtlt;

  -- Insert or update the records in l_cg_quantity_table into MMTT
  IF (l_debug = 1) THEN
     print_debug('count: ' || l_cg_quantity_table.count);
  END IF;

  IF l_cg_quantity_table.COUNT > 0 THEN
     IF (l_debug = 1) THEN
        print_debug('proc_process_lots..Inserting records INTO MMTT ');
     END IF;
     i := l_cg_quantity_table.first;

     IF p_mmtt_rec.transaction_quantity >= 0 THEN
	l_quantity_sign := 1;
      ELSE
	l_quantity_sign := -1;
     END IF;

     LOOP
	l_cg_quantity_table(i).primary_quantity :=
	  l_cg_quantity_table(i).primary_quantity * l_quantity_sign;

	l_cg_quantity_table(i).transaction_quantity :=
	  l_cg_quantity_table(i).transaction_quantity * l_quantity_sign;

	IF (l_debug = 1) THEN
   	print_debug('Primary qty: ' ||
		    l_cg_quantity_table(i).primary_quantity);
   	print_debug('qty sign: ' || l_quantity_sign);
	END IF;

	IF l_cg_quantity_table(i).update_mmtt = FALSE THEN
	   proc_insert_mmtt(p_mmtt_rec,
			    p_transfer_wms_org,
			    p_fob_point,
			    p_tfr_primary_cost_method,
			    p_tfr_org_cost_group_id,
			    i, -- Remember that i is also the cost_group_id of the record
			    NULL,
			    l_cg_quantity_table(i).primary_quantity,
			    l_cg_quantity_table(i).transaction_quantity,
			    l_cg_quantity_table(i).new_transaction_temp_id,
			    p_from_project_id,
			    p_to_project_id,
			    x_return_status);

	   IF (l_debug = 1) THEN
   	   print_debug('proc_insert_mmtt return : ' || x_return_status);
	   END IF;
	 ELSE
	   proc_update_mmtt(p_mmtt_rec.transaction_temp_id,
			    p_transfer_wms_org,
			    p_fob_point,
			    p_tfr_primary_cost_method,
			    p_tfr_org_cost_group_id,
			    p_mmtt_rec.transaction_action_id,
			    p_mmtt_rec.transfer_organization,
			    p_mmtt_rec.transfer_subinventory,
			    i, -- Remember that i is also the cost_group_id of the record
			    NULL,
			    l_cg_quantity_table(i).primary_quantity,
			    l_cg_quantity_table(i).transaction_quantity,
			    p_from_project_id,
			    p_to_project_id,
			    x_return_status);

	   IF (l_debug = 1) THEN
   	   print_debug('proc_update_mmtt return : ' || x_return_status);
	   END IF;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_error)
	  THEN
	   RAISE fnd_api.g_exc_error;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	  THEN
	   RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	EXIT WHEN i = l_cg_quantity_table.last;
	i := l_cg_quantity_table.next(i);
     END LOOP;

     -- Update the records in l_lots_table into MTLT and MSNT
     IF (l_debug = 1) THEN
        print_debug('IN proc_process_lots..updating records INTO MTLT');
     END IF;
     FOR i IN 1..l_lots_table.COUNT LOOP
	-- Update the MTLT records
	IF (l_debug = 1) THEN
   	print_debug('updating MTLT ');
	END IF;
	proc_update_mtlt(l_lots_table(i).mtlt_rowid,
			 l_cg_quantity_table(l_lots_table(i).cost_group_id).new_transaction_temp_id,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 x_return_status);

	IF (l_debug = 1) THEN
   	print_debug('proc_update_mtlt return : ' || x_return_status);
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_error)
	  THEN
	   RAISE fnd_api.g_exc_error ;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	  THEN
	   RAISE fnd_api.g_exc_unexpected_error ;
	END IF;
     END LOOP;

  END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 1) THEN
         print_debug('proc_process_lots .. EXCEP G_EXC_ERROR : ' );
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF cur_mtlt%isopen THEN
	 CLOSE cur_mtlt;
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 1) THEN
         print_debug('proc_process_lots .. EXCEP G_EXC_UNEXPECTED_ERROR : ' );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF cur_mtlt%isopen THEN
	 CLOSE cur_mtlt;
      END IF;
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('proc_process_lots .. EXCEP OTHERS : ' || SQLERRM(SQLCODE));
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF cur_mtlt%isopen THEN
	 CLOSE cur_mtlt;
      END IF;
END proc_process_lots;


-- Processes the lot and serial controlled items. This involves splitting
-- MMTT, MTLT and MSNT lines so that each row corresponds to a unique cost
-- group.

PROCEDURE proc_process_serials
  (p_mmtt_rec                IN  mtl_material_transactions_temp%ROWTYPE,
   p_fob_point               IN  NUMBER,
   p_transfer_wms_org        IN  BOOLEAN,
   p_tfr_primary_cost_method IN  NUMBER,
   p_tfr_org_cost_group_id   IN  NUMBER,
   p_from_project_id         IN  NUMBER,
   p_to_project_id           IN  NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT  NOCOPY NUMBER,
   x_msg_data                OUT  NOCOPY VARCHAR2)
  IS
     l_api_name CONSTANT VARCHAR2(100) := 'proc_process_serial';
     l_transaction_temp_id   NUMBER := NULL;
     i                       INTEGER;
     l_transaction_quantity  NUMBER;
     l_quantity_sign         NUMBER;
     l_cost_group_id         NUMBER;

     -- For putting records in MSNT tables
     TYPE serial_record IS RECORD
       (from_serial_number             mtl_serial_numbers.serial_number%TYPE,
	to_serial_number               mtl_serial_numbers.serial_number%TYPE,
	cost_group_id                  NUMBER,
	update_msnt                    BOOLEAN);
     TYPE serial_table IS TABLE OF serial_record INDEX BY BINARY_INTEGER;
     l_serial_table   serial_table;
     l_sti            INTEGER := 1;

     TYPE cg_quantity_record IS RECORD
       (new_transaction_temp_id NUMBER,
	quantity                NUMBER,
	update_mmtt             BOOLEAN);
     TYPE cg_quantity_table IS TABLE OF cg_quantity_record INDEX BY BINARY_INTEGER;
     l_cg_quantity_table cg_quantity_table;

     TYPE msnt_rowid_table IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
     l_msnt_rowid_table msnt_rowid_table;

     TYPE msnt_table IS TABLE OF cur_msnt%ROWTYPE INDEX BY BINARY_INTEGER;
     l_msnt_table msnt_table;

     rec_msnt cur_msnt%ROWTYPE;

     l_onhand_exists BOOLEAN;
     l_lpn_id        NUMBER := p_mmtt_rec.lpn_id;
     --Bug 3686015 fix
     l_temp_prefix VARCHAR2(30):=NULL;
     l_from_ser_number NUMBER := NULL;
     l_fm_ser_length NUMBER := NULL;
     l_to_temp_prefix VARCHAR2(30) := NULL;
     l_to_ser_number NUMBER := NULL;
     --Bug 3686015 fix
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  x_return_status := fnd_api.g_ret_sts_success;
  SAVEPOINT sp_proc_process_serial;

  IF (l_debug = 1) THEN
     print_debug('IN proc_process_serial.. ');
  END IF;

  OPEN cur_msnt(p_mmtt_rec.transaction_temp_id);

  FETCH cur_msnt INTO rec_msnt;

  -- If the serial control is dynamic entry at sales order issue check if
  -- there are any records in MSNT. If there are no records there treat the
  -- item as a no control item.
  IF p_mmtt_rec.item_serial_control_code = 6  THEN
     CLOSE cur_msnt;
     proc_process_nocontrol
       (p_mmtt_rec                => p_mmtt_rec,
	p_fob_point               => p_fob_point,
	p_transfer_wms_org        => p_transfer_wms_org,
	p_tfr_primary_cost_method => p_tfr_primary_cost_method,
	p_tfr_org_cost_group_id   => p_tfr_org_cost_group_id,
	p_from_project_id         => p_from_project_id,
	p_to_project_id           => p_to_project_id,
	x_return_status           => x_return_status,
	x_msg_count               => x_msg_count,
	x_msg_data                => x_msg_data);
     RETURN;
  END IF;


  IF p_mmtt_rec.item_serial_control_code <> 6 AND cur_msnt%notfound THEN
     IF (l_debug = 1) THEN
        print_debug('Serial Code is not 6 but does not have any corresponding
		 records IN MSNT');
     END IF;
		 fnd_message.set_name('INV', 'Cannot find the serial number
				      for the transaction being processed');
		 fnd_msg_pub.add;
		 RAISE FND_API.G_EXC_ERROR;
  END IF;

  WHILE cur_msnt%found LOOP
     IF (l_debug = 1) THEN
        print_debug('trx_id: ' || p_mmtt_rec.transaction_temp_id);
     END IF;

     i := 1;
     IF (l_debug = 1) THEN
        print_debug('FSN: ' || rec_msnt.fm_serial_number);
        print_debug('TSN: ' || rec_msnt.to_serial_number);
        print_debug('ORG: ' || p_mmtt_rec.organization_id);
        print_debug('ITEM: ' || p_mmtt_rec.inventory_item_id);
     END IF;

    --Bug 3686015
    inv_validate.number_from_sequence(rec_msnt.fm_serial_number, l_temp_prefix, l_from_ser_number);
    l_fm_ser_length := Length(rec_msnt.fm_serial_number);

    IF (l_debug = 1) THEN
	print_debug('FSNPREFIX: ' || l_temp_prefix);
	print_debug('FSNNUMERIC: ' || l_from_ser_number);
	print_debug('FSNLENGTH: ' || l_fm_ser_length);
    END IF;
    IF (rec_msnt.to_serial_number IS NOT NULL) AND
      (rec_msnt.to_serial_number <> rec_msnt.fm_serial_number) THEN
       IF Length(rec_msnt.to_serial_number)<>l_fm_ser_length THEN
	  IF (l_debug = 1) THEN
	     print_debug('ERROR: Length of FSN diff from TSN');
	  END IF;
	  fnd_message.set_name('INV', 'INV_FROM_TO_SER_DIFF_LENGTH');
	  fnd_message.set_token('FM_SER_NUM',rec_msnt.fm_serial_number);
	  fnd_message.set_token('TO_SER_NUM', rec_msnt.to_serial_number);
	  fnd_msg_pub.add;
	  RAISE fnd_api.g_exc_error;
       END IF;

       -- get the number part of the to serial
       inv_validate.number_from_sequence(rec_msnt.to_serial_number, l_to_temp_prefix, l_to_ser_number);

       IF (l_debug = 1) THEN
	  print_debug('TSNPREFIX: ' || l_to_temp_prefix);
	  print_debug('TSNNUMERIC: ' || l_to_ser_number);
       END IF;

       IF (l_temp_prefix IS NOT NULL) AND (l_to_temp_prefix IS NOT NULL) AND
	 (l_to_temp_prefix <> l_temp_prefix) THEN
	  IF (l_debug = 1) THEN
	     print_debug('ERROR: From serial prefix different from to serial prefix');
	  END IF;
	  fnd_message.set_name('INV', 'INV_FROM_TO_SER_DIFF_PFX');
	  fnd_message.set_token('FM_SER_NUM',rec_msnt.fm_serial_number);
	  fnd_message.set_token('TO_SER_NUM', rec_msnt.to_serial_number);
	  fnd_msg_pub.add;
	  RAISE fnd_api.g_exc_error;
       END IF;

    END IF;
    --Bug 3686015


     FOR rec_msn IN cur_msn(rec_msnt.fm_serial_number,
			    rec_msnt.to_serial_number,
			    p_mmtt_rec.inventory_item_id,
			    p_mmtt_rec.organization_id,
			    l_temp_prefix,
			    l_fm_ser_length)
       LOOP
        IF (l_debug = 1) THEN
           print_debug('In MSN cursor...SN: ' || rec_msn.serial_number);
        END IF;
	l_onhand_exists := TRUE;

	-- Adjustment transactions
	IF p_mmtt_rec.transaction_action_id IN (inv_globals.g_type_cycle_count_adj,
						 inv_globals.g_type_physical_count_adj,
						 inv_globals.g_action_deliveryadj)
	  THEN

	   IF p_mmtt_rec.transaction_action_id = inv_globals.g_type_physical_count_adj THEN
	      IF p_mmtt_rec.lpn_id IS NOT NULL THEN
		 l_lpn_id := p_mmtt_rec.lpn_id;
	       ELSIF p_mmtt_rec.content_lpn_id IS NOT NULL THEN
		 l_lpn_id := p_mmtt_rec.content_lpn_id;
	       ELSIF p_mmtt_rec.transfer_lpn_id IS NOT NULL THEN
		 l_lpn_id := p_mmtt_rec.transfer_lpn_id;
	      END IF;
	    ELSIF p_mmtt_rec.transaction_action_id = inv_globals.g_action_deliveryadj THEN
	      l_lpn_id := p_mmtt_rec.transfer_lpn_id;
	    ELSIF p_mmtt_rec.transaction_action_id = inv_globals.g_type_cycle_count_adj THEN
	      l_lpn_id := p_mmtt_rec.transfer_lpn_id;
	   END IF;

	   l_onhand_exists :=
	     onhand_quantity_exists
	     (p_inventory_item_id => p_mmtt_rec.inventory_item_id,
	      p_revision          => p_mmtt_rec.revision,
	      p_organization_id   => p_mmtt_rec.organization_id,
	      p_subinventory_code => p_mmtt_rec.subinventory_code,
	      p_locator_id        => p_mmtt_rec.locator_id,
	      p_lot_number        => NULL,
	      p_serial_number     => rec_msn.serial_number,
	      p_lpn_id            => l_lpn_id);
	   IF NOT l_onhand_exists THEN
	      IF (l_debug = 1) THEN
   	      print_debug('Treating this as as receipt transaction...: ');
   	      print_debug('Getting transfer cost group id from rules engine...: ');
	      END IF;
	      wms_costgroupengine_pvt.assign_cost_group
		(p_api_version => 1.0,
		 p_init_msg_list => FND_API.G_FALSE,
		 p_commit => FND_API.G_FALSE,
		 p_validation_level => FND_API.G_VALID_LEVEL_FULL,
		 x_return_status => x_return_Status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data,
		 p_line_id  => p_mmtt_rec.transaction_temp_id,
		 p_input_type => wms_costgroupengine_pvt.g_input_mmtt);

	      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		 IF (l_debug = 1) THEN
   		 print_debug('return error from wms_costgroupengine_pvt');
		 END IF;
		 RAISE FND_API.G_EXC_ERROR;
	       ELSIF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		 IF (l_debug = 1) THEN
   		 print_debug('return unexpected error from wms_costgroupengine_pvt');
		 END IF;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF;

	   END IF;
	 ELSIF (p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_salesorder
		OR p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_intorder)
	   AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_issue
		OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_subxfr
		OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_orgxfr
		OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_intransitshipment)
	   THEN -- For a ship confirm transaction, get the cost group from the content lpn ID
	   l_lpn_id := p_mmtt_rec.content_lpn_id;
	 /* Bug 4628878: For staging transfers, when whole LPN is being transfered, cost group should
	 * be obtained from content_lpn_id  */
	ELSIF (
        ((p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_salesorder
             OR p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_intorder)
          AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_stgxfr))
       OR/*Bug 6499833:For move order sub transfers,trying to get the costgroup from content_lpn_id.*/
         (( p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_moveorder)
          AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_subxfr))
      )
      --   AND (p_mmtt_rec.lpn_id IS NULL) Bug#6770593
	   AND (p_mmtt_rec.content_lpn_id IS NOT NULL)
	   AND (p_mmtt_rec.inventory_item_id <> -1)
	     THEN -- For a staging transfer transaction with content_lpn_id, get the cost group from the content lpn ID
	   l_lpn_id := p_mmtt_rec.content_lpn_id;
	END IF;
	IF (l_debug = 1) THEN
	   print_debug('l_lpn_id is set to: '||l_lpn_id);
	END IF;

	IF l_onhand_exists THEN

	   IF i=1 THEN --When the l_serial_table is empty
	   l_serial_table(l_sti).from_serial_number := rec_msn.serial_number;
	   l_serial_table(l_sti).to_serial_number := rec_msn.serial_number;
	   l_serial_table(l_sti).cost_group_id := rec_msn.cost_group_id;

	   l_serial_table(l_sti).update_msnt := TRUE;
	   l_msnt_rowid_table(l_sti) := rec_msnt.msnt_rowid;

	   l_msnt_table(l_sti) := rec_msnt;

	   l_sti := l_sti + 1;
	   i := i + 1;
	    ELSIF i<>1 THEN -- When there are records in l_serial_table
	   -- If the Cost Group ID of this record is the same as that of
	      -- the previous record then extend the serial number range of
	      -- the previous record otherwise insert a new record
	      IF rec_msn.cost_group_id = l_serial_table(l_sti-1).cost_group_id THEN
		 l_serial_table(l_sti-1).to_serial_number := rec_msn.serial_number;
	       ELSE
		 l_serial_table(l_sti).from_serial_number := rec_msn.serial_number;
		 l_serial_table(l_sti).to_serial_number := rec_msn.serial_number;
		 l_serial_table(l_sti).cost_group_id := rec_msn.cost_group_id;

		 l_serial_table(l_sti).update_msnt := FALSE;

		 l_msnt_table(l_sti) := rec_msnt;

		 l_sti := l_sti + 1;
	      END IF;
	   END IF;

	   IF rec_msn.cost_group_id IS NULL THEN
	      proc_get_pending_costgroup(p_organization_id       => p_mmtt_rec.organization_id,
					 p_inventory_item_id     => p_mmtt_rec.inventory_item_id,
					 p_subinventory_code     => p_mmtt_rec.subinventory_code,
					 p_locator_id            => p_mmtt_rec.locator_id,
					 p_revision              => p_mmtt_rec.revision,
					 p_lot_number            => p_mmtt_rec.lot_number,
					 p_serial_number         => rec_msn.serial_number,
					 p_lpn_id                => p_mmtt_rec.lpn_id,
					 p_transaction_action_id => p_mmtt_rec.transaction_action_id,
					 x_cost_group_id         => l_cost_group_id,
					 x_return_status         => x_return_status);
	      rec_msn.cost_group_id := l_cost_group_id;
	      IF x_return_status =  fnd_api.g_ret_sts_error THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;
	   END IF;

	   IF l_cg_quantity_table.exists(rec_msn.cost_group_id) THEN
	      l_cg_quantity_table(rec_msn.cost_group_id).quantity :=
		l_cg_quantity_table(rec_msn.cost_group_id).quantity + 1;
	    ELSE
	      IF l_cg_quantity_table.COUNT = 0 THEN
		 -- If the table is empty then the existing
		 -- transaction_temp_id should be used as the
		 -- new_transaction_temp_id also
		 l_cg_quantity_table(rec_msn.cost_group_id).new_transaction_temp_id := p_mmtt_rec.transaction_temp_id;
		 l_cg_quantity_table(rec_msn.cost_group_id).update_mmtt := TRUE;
	       ELSE
		 -- otherwise generate a new_transaction_temp_id
		 SELECT mtl_material_transactions_s.NEXTVAL
		   INTO l_transaction_temp_id
		   FROM dual;
		 IF (l_debug = 1) THEN
   		 print_debug('l_transaction_temp_id: ' || l_transaction_temp_id);
		 END IF;
		 l_cg_quantity_table(rec_msn.cost_group_id).new_transaction_temp_id := l_transaction_temp_id;
		 l_cg_quantity_table(rec_msn.cost_group_id).update_mmtt := FALSE;
	      END IF;
	      l_cg_quantity_table(rec_msn.cost_group_id).quantity := 1;
	   END IF;
	END IF;
       END LOOP;

       FETCH cur_msnt INTO rec_msnt;
  END LOOP;

  CLOSE cur_msnt;

  -- Insert or update the records in l_cg_quantity_table into MMTT
  IF (l_debug = 1) THEN
     print_debug('proc_process_serial..Inserting records INTO MMTT ');
     print_debug('count: ' || l_cg_quantity_table.count);
  END IF;
  IF l_cg_quantity_table.COUNT > 0 THEN
     i := l_cg_quantity_table.first;
     IF p_mmtt_rec.transaction_quantity >= 0 THEN
	l_quantity_sign := 1;
      ELSE
	l_quantity_sign := -1;
     END IF;

     LOOP
	l_transaction_quantity := inv_convert.inv_um_convert
	  (p_mmtt_rec.inventory_item_id,
	   5,
	   l_cg_quantity_table(i).quantity,
	   p_mmtt_rec.item_primary_uom_code,
	   p_mmtt_rec.transaction_uom,
	   NULL,
	   NULL);

	l_transaction_quantity := l_transaction_quantity * l_quantity_sign;
	IF (l_debug = 1) THEN
   	print_debug('qty: ' || l_transaction_quantity);
   	print_debug('qty sign: ' || l_quantity_sign);
	END IF;
	IF l_cg_quantity_table(i).update_mmtt = FALSE THEN
	   IF (l_debug = 1) THEN
   	   print_debug('trx_temp_id: ' || l_cg_quantity_table(i).new_transaction_temp_id);
	   END IF;

	   proc_insert_mmtt(p_mmtt_rec,
			    p_transfer_wms_org,
			    p_fob_point,
			    p_tfr_primary_cost_method,
			    p_tfr_org_cost_group_id,
			    i, -- Remember that i is also the cost_group_id of the record
			    NULL,
			    l_cg_quantity_table(i).quantity * l_quantity_sign,
			    l_transaction_quantity,
			    l_cg_quantity_table(i).new_transaction_temp_id,
			    p_from_project_id,
			    p_to_project_id,
			    x_return_status);

	   IF (l_debug = 1) THEN
   	   print_debug('proc_insert_mmtt return : ' || x_return_status);
	   END IF;
	 ELSE
	   proc_update_mmtt(p_mmtt_rec.transaction_temp_id,
			    p_transfer_wms_org,
			    p_fob_point,
			    p_tfr_primary_cost_method,
			    p_tfr_org_cost_group_id,
			    p_mmtt_rec.transaction_action_id,
			    p_mmtt_rec.transfer_organization,
			    p_mmtt_rec.transfer_subinventory,
			    i, -- Remember that i is also the cost_group_id of the record
			    NULL,
			    l_cg_quantity_table(i).quantity * l_quantity_sign,
			    l_transaction_quantity,
			    p_from_project_id,
			    p_to_project_id,
			    x_return_status);

	   IF (l_debug = 1) THEN
   	   print_debug('proc_update_mmtt return : ' || x_return_status);
	   END IF;
	END IF;
	IF (x_return_status =  fnd_api.g_ret_sts_error)
	  THEN
	   RAISE fnd_api.g_exc_error ;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	  THEN
	   RAISE fnd_api.g_exc_unexpected_error ;
	END IF;

	EXIT WHEN i = l_cg_quantity_table.last;
	i := l_cg_quantity_table.next(i);
     END LOOP;

     -- Insert or update the records in l_serial_table into MSNT
     IF (l_debug = 1) THEN
        print_debug('IN proc_process_serial..Inserting records INTO MSNT');
     END IF;
     FOR i IN 1..l_serial_table.COUNT LOOP
	IF (l_debug = 1) THEN
   	print_debug('cg_id: ' || l_serial_table(i).cost_group_id);
   	print_debug('FSN: ' || l_serial_table(i).from_serial_number);
   	print_debug('TSN: ' || l_serial_table(i).to_serial_number);
   	print_debug('txn tmp id: ' || l_cg_quantity_table(l_serial_table(i).cost_group_id).new_transaction_temp_id);
	END IF;

	IF l_serial_table(i).update_msnt = TRUE THEN -- Update the MSNT records
	   IF (l_debug = 1) THEN
   	   print_debug('updating MSNT ');
   	   print_debug('row_id: ' || l_msnt_rowid_table(i));
	   END IF;
	   proc_update_msnt(l_msnt_rowid_table(i),
			    l_cg_quantity_table(l_serial_table(i).cost_group_id).new_transaction_temp_id,
			    l_serial_table(i).from_serial_number,
			    l_serial_table(i).to_serial_number,
			    x_return_status);

	   IF (l_debug = 1) THEN
   	   print_debug('proc_update_msnt return : ' || x_return_status);
	   END IF;
	 ELSE -- Insert into MSNT to create new records
	   IF (l_debug = 1) THEN
   	   print_debug('inserting into MSNT ');
	   END IF;
	   proc_insert_msnt(l_msnt_table(i),
			    l_serial_table(i).from_serial_number,
			    l_serial_table(i).to_serial_number,
			    l_cg_quantity_table(l_serial_table(i).cost_group_id).new_transaction_temp_id,
			    x_return_status);

	   IF (l_debug = 1) THEN
   	   print_debug('proc_insert_msnt return : ' || x_return_status);
	   END IF;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_error)
	  THEN
	   RAISE fnd_api.g_exc_error ;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
       THEN
	   RAISE fnd_api.g_exc_unexpected_error ;
	END IF;

     END LOOP;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 1) THEN
         print_debug('proc_process_serial .. EXCEP G_EXC_ERROR : ' );
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF cur_msnt%isopen THEN
	 CLOSE cur_msnt;
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 1) THEN
         print_debug('proc_process_serial .. EXCEP G_EXC_UNEXPECTED_ERROR : ' );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF cur_msnt%isopen THEN
	 CLOSE cur_msnt;
      END IF;
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('proc_process_serial .. EXCEP OTHERS:' || SQLERRM(SQLCODE) );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF cur_msnt%isopen THEN
	 CLOSE cur_msnt;
      END IF;
END proc_process_serials;

-- Processes the lot and serial controlled items. This involves splitting
-- MMTT, MTLT and MSNT lines so that each row corresponds to a unique cost
-- group.
PROCEDURE proc_process_lot_serial
  (p_mmtt_rec                IN  mtl_material_transactions_temp%ROWTYPE,
   p_fob_point               IN  NUMBER,
   p_transfer_wms_org        IN  BOOLEAN,
   p_tfr_primary_cost_method IN  NUMBER,
   p_tfr_org_cost_group_id   IN  NUMBER,
   p_from_project_id         IN  NUMBER,
   p_to_project_id           IN  NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2)
  IS
     l_api_name CONSTANT VARCHAR2(100) := 'proc_process_lot_serial';
     l_transaction_temp_id NUMBER := NULL;
     i                        INTEGER;
     j                        INTEGER;
     l_transaction_quantity   NUMBER;
     l_quantity_sign          NUMBER;
     l_cost_group_id          NUMBER;
     l_ser_trx_tmp_id 	      NUMBER;    -- bug 1936698

     --Bug 3390284 Changed the logic in in this procedure to prevent the
     --splitting of mtlt if not necessary.
     --1. Changed the existing structure 'lot_serial_record', holding
     --lot/serial information to 'serial_record'. The structure 'serial_record'
     --now holds information about records IN msnt only
     --2.Added New record type lot_record, holds information about a row in mtlt
     --3.lot_cg_quantity record is indexed by cost_group and holds the quantity
     --against that cost_group, also holds the serial_transaction_temp_id
     --This is cleared before processing each mtlt record, built while
     --processing that record, and after processing the mtlt record completely,
     --the information in this table is copied to to lot_table

     -- For putting records in MTLT and MSNT tables
     TYPE serial_record IS RECORD
       (from_serial_number             mtl_serial_numbers.serial_number%TYPE,
	to_serial_number               mtl_serial_numbers.serial_number%TYPE,
	--lot_number                     mtl_serial_numbers.lot_number%TYPE,
	quantity                       NUMBER,
	cost_group_id                  NUMBER,
	new_serial_transaction_temp_id NUMBER,
	--update_mtlt                    BOOLEAN,
	update_msnt                    BOOLEAN);

     TYPE serial_table IS TABLE OF serial_record INDEX BY BINARY_INTEGER;
     l_serial_table   serial_table;
     l_sti               INTEGER := 1;

     TYPE cg_quantity_record IS RECORD
       (new_transaction_temp_id NUMBER,
	quantity                NUMBER,
	update_mmtt             BOOLEAN);
     TYPE cg_quantity_table IS TABLE OF cg_quantity_record INDEX BY BINARY_INTEGER;
     l_cg_quantity_table cg_quantity_table;

     --Bug 3390284
     TYPE lot_cg_qty_record IS RECORD
       (quantity NUMBER,
	serial_transaction_temp_id NUMBER);

     TYPE lot_cg_qty_table_tp IS TABLE OF lot_cg_qty_record INDEX BY BINARY_INTEGER;
     lot_cg_qty_table lot_cg_qty_table_tp;

     TYPE lot_record IS RECORD
       (mtlt_rowid  ROWID,
	lot_number mtl_lot_numbers.lot_number%TYPE,
	quantity NUMBER,
	serial_transaction_temp_id NUMBER,
	cost_group_id NUMBER,
	update_mtlt boolean);


     TYPE lot_table_tp IS TABLE OF lot_record INDEX BY BINARY_INTEGER;
     l_lot_table lot_table_tp;
     l_lti INTEGER := 0;
     --Bug 3390284

     TYPE mtlt_rowid_table IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
     l_mtlt_rowid_table mtlt_rowid_table;

     TYPE msnt_rowid_table IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
     l_msnt_rowid_table msnt_rowid_table;

     TYPE msnt_table IS TABLE OF cur_msnt%ROWTYPE INDEX BY BINARY_INTEGER;
     l_msnt_table msnt_table;

     TYPE mtlt_table IS TABLE OF cur_mtlt%ROWTYPE INDEX BY BINARY_INTEGER;
     l_mtlt_table mtlt_table;

     rec_mtlt cur_mtlt%ROWTYPE;
     rec_msnt cur_msnt%ROWTYPE;

     call_lot_control  BOOLEAN := FALSE;

     l_onhand_exists BOOLEAN;
     l_lpn_id        NUMBER := p_mmtt_rec.lpn_id;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_last NUMBER;
     lot_cgi NUMBER;

     --Bug 3686015 fix
     l_temp_prefix VARCHAR2(30):=NULL;
     l_from_ser_number NUMBER := NULL;
     l_fm_ser_length NUMBER := NULL;
     l_to_temp_prefix VARCHAR2(30) := NULL;
     l_to_ser_number NUMBER := NULL;
     --Bug 3686015 fix
BEGIN
  x_return_status := fnd_api.g_ret_sts_success;
  SAVEPOINT sp_proc_process_lot_serial;

  IF (l_debug = 1) THEN
     print_debug('IN proc_process_lot_serial.. ');
  END IF;
  --3390284
  l_lot_table.DELETE;
  --3390284
  OPEN cur_mtlt(p_mmtt_rec.transaction_temp_id);

  FETCH cur_mtlt INTO rec_mtlt;

  WHILE cur_mtlt%found LOOP
     IF (l_debug = 1) THEN
        print_debug('trx_id: ' || p_mmtt_rec.transaction_temp_id);
     END IF;
     j := 1;

     --3390284
     lot_cg_qty_table.DELETE;
     --3390284

     OPEN cur_msnt(rec_mtlt.serial_transaction_temp_id);

     FETCH cur_msnt INTO rec_msnt;

     -- If the serial control is dynamic entry at sales order issue check if
     -- there are any records in MSNT. If there are no records there treat the
     -- item as a lot control item.
     IF p_mmtt_rec.item_serial_control_code = 6 AND cur_msnt%notfound THEN
	CLOSE cur_msnt;
	call_lot_control := TRUE;
	EXIT;
      ELSE
	WHILE cur_msnt%found LOOP
	   /* Bug 2424354: The variable i has to be reset to 1 for each record from MSNT
         rather than for each record from MTLT */
      i := 1;
	   IF (l_debug = 1) THEN
   	   print_debug('ser_trx_id: ' || rec_mtlt.serial_transaction_temp_id);
   	   print_debug('FSN: ' || rec_msnt.fm_serial_number);
   	   print_debug('TSN: ' || rec_msnt.to_serial_number);
   	   print_debug('ORG: ' || p_mmtt_rec.organization_id );
   	   print_debug('ITEM: ' || p_mmtt_rec.inventory_item_id);
	   END IF;

	   --Bug 3686015
	   inv_validate.number_from_sequence(rec_msnt.fm_serial_number, l_temp_prefix, l_from_ser_number);
	   l_fm_ser_length := Length(rec_msnt.fm_serial_number);

	   IF (l_debug = 1) THEN
	      print_debug('FSNPREFIX: ' || l_temp_prefix);
	      print_debug('FSNNUMERIC: ' || l_from_ser_number);
	      print_debug('FSNLENGTH: ' || l_fm_ser_length);
	   END IF;

	   IF (rec_msnt.to_serial_number IS NOT NULL) AND
	     (rec_msnt.to_serial_number <> rec_msnt.fm_serial_number) THEN
	      IF Length(rec_msnt.to_serial_number)<>l_fm_ser_length THEN
		 IF (l_debug = 1) THEN
		    print_debug('ERROR: Length of FSN diff from TSN');
		 END IF;
		 fnd_message.set_name('INV', 'INV_FROM_TO_SER_DIFF_LENGTH');
		 fnd_message.set_token('FM_SER_NUM',rec_msnt.fm_serial_number);
		 fnd_message.set_token('TO_SER_NUM', rec_msnt.to_serial_number);
		 fnd_msg_pub.add;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      -- get the number part of the to serial
	      inv_validate.number_from_sequence(rec_msnt.to_serial_number, l_to_temp_prefix, l_to_ser_number);

	      IF (l_debug = 1) THEN
		 print_debug('TSNPREFIX: ' || l_to_temp_prefix);
		 print_debug('TSNNUMERIC: ' || l_to_ser_number);
	      END IF;

	      IF (l_temp_prefix IS NOT NULL) AND (l_to_temp_prefix IS NOT NULL) AND
		(l_to_temp_prefix <> l_temp_prefix) THEN
		 IF (l_debug = 1) THEN
		    print_debug('ERROR: From serial prefix different from to serial prefix');
		 END IF;
		 fnd_message.set_name('INV', 'INV_FROM_TO_SER_DIFF_PFX');
		 fnd_message.set_token('FM_SER_NUM',rec_msnt.fm_serial_number);
		 fnd_message.set_token('TO_SER_NUM', rec_msnt.to_serial_number);
		 fnd_msg_pub.add;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	   END IF;
	   --Bug 3686015




	   FOR rec_msn IN cur_msn(rec_msnt.fm_serial_number,
				  rec_msnt.to_serial_number,
				  p_mmtt_rec.inventory_item_id,
       				  p_mmtt_rec.organization_id,
				  l_temp_prefix,
				  l_fm_ser_length)
	     LOOP
		IF (l_debug = 1) THEN
   		print_debug('In MSN cursor');
		END IF;
		l_onhand_exists := TRUE;

		-- Adjustment transactions
		IF p_mmtt_rec.transaction_action_id IN (inv_globals.g_type_cycle_count_adj,
							 inv_globals.g_type_physical_count_adj,
							 inv_globals.g_action_deliveryadj)
		  THEN
		   IF p_mmtt_rec.transaction_action_id = inv_globals.g_type_physical_count_adj THEN
		      IF p_mmtt_rec.lpn_id IS NOT NULL THEN
			 l_lpn_id := p_mmtt_rec.lpn_id;
		       ELSIF p_mmtt_rec.content_lpn_id IS NOT NULL THEN
			 l_lpn_id := p_mmtt_rec.content_lpn_id;
		       ELSIF p_mmtt_rec.transfer_lpn_id IS NOT NULL THEN
			 l_lpn_id := p_mmtt_rec.transfer_lpn_id;
		      END IF;
		    ELSIF p_mmtt_rec.transaction_action_id = inv_globals.g_action_deliveryadj THEN
		      l_lpn_id := p_mmtt_rec.transfer_lpn_id;
		    ELSIF p_mmtt_rec.transaction_action_id = inv_globals.g_type_cycle_count_adj THEN
		      l_lpn_id := p_mmtt_rec.transfer_lpn_id;
		   END IF;

		   l_onhand_exists :=
		     onhand_quantity_exists
		     (p_inventory_item_id => p_mmtt_rec.inventory_item_id,
		      p_revision          => p_mmtt_rec.revision,
		      p_organization_id   => p_mmtt_rec.organization_id,
		      p_subinventory_code => p_mmtt_rec.subinventory_code,
		      p_locator_id        => p_mmtt_rec.locator_id,
		      p_lot_number        => rec_mtlt.lot_number,
		      p_serial_number     => rec_msn.serial_number,
		      p_lpn_id            => l_lpn_id);
		   IF NOT l_onhand_exists THEN
		      IF (l_debug = 1) THEN
   		      print_debug('Treating this as as receipt transaction...: ');
   		      print_debug('Getting transfer cost group id from rules engine...: ');
		      END IF;
		      wms_costgroupengine_pvt.assign_cost_group
			(p_api_version => 1.0,
			 p_init_msg_list => FND_API.G_FALSE,
			 p_commit => FND_API.G_FALSE,
			 p_validation_level => FND_API.G_VALID_LEVEL_FULL,
			 x_return_status => x_return_Status,
			 x_msg_count => x_msg_count,
			 x_msg_data => x_msg_data,
			 p_line_id  => p_mmtt_rec.transaction_temp_id,
			 p_input_type => wms_costgroupengine_pvt.g_input_mmtt);

		      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
			 IF (l_debug = 1) THEN
   			 print_debug('return error from wms_costgroupengine_pvt');
			 END IF;
			 RAISE FND_API.G_EXC_ERROR;
		       ELSIF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			 IF (l_debug = 1) THEN
   			 print_debug('return unexpected error from wms_costgroupengine_pvt');
			 END IF;
			 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		      END IF;

		   END IF;
		 ELSIF (p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_salesorder
			OR p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_intorder)
		   AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_issue
			OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_subxfr
			OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_orgxfr
			OR p_mmtt_rec.transaction_action_id = inv_globals.g_action_intransitshipment)
		   THEN -- For a ship confirm transaction, get the cost group from the content lpn ID
		   l_lpn_id := p_mmtt_rec.content_lpn_id;

		   --Bug 2631651 fix. For sales order issue transactions,if the serial control is set at
 		   --sales order issue msn wouldn't have cost group id
 		   --stamped so we have to get the cost group from onhand,
 		   --considering the item as a non serial controlled item
 		   --(by passing null for p_serial_number parameter)

 		   IF p_mmtt_rec.item_serial_control_code = 6 AND rec_msn.cost_group_id IS NULL THEN

 		      proc_determine_costgroup(p_organization_id         =>   p_mmtt_rec.organization_id,
 					       p_inventory_item_id       =>   p_mmtt_rec.inventory_item_id,
 					       p_subinventory_code       =>   p_mmtt_rec.subinventory_code,
 					       p_locator_id              =>   p_mmtt_rec.locator_id,
 					       p_revision                =>   p_mmtt_rec.revision,
 					       p_lot_number              =>   rec_mtlt.lot_number,
 					       p_serial_number           =>   NULL,
 					       p_containerized_flag      =>   2, -- param is ignored by	the PROCEDURE
 					       p_lpn_id                  =>   l_lpn_id,
 					       p_transaction_action_id   =>   p_mmtt_rec.transaction_action_id,
 					       p_is_backflush_txn        =>   FALSE,
 					       x_cost_group_id           =>   l_cost_group_id,
 					       x_return_status           =>   x_return_status);

 		      rec_msn.cost_group_id := l_cost_group_id;

 		   END IF;
		   --Bug 2631651 fix
		  /* Bug 4628878: For staging transfers, when whole LPN is being transfered, cost group should
		   * be obtained from content_lpn_id  */
		   ELSIF (
        ((p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_salesorder
             OR p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_intorder)
          AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_stgxfr))
       OR/*Bug 6499833:For move order sub transfers,trying to get the costgroup from content_lpn_id.*/
         (( p_mmtt_rec.transaction_source_type_id = inv_globals.g_sourcetype_moveorder)
          AND (p_mmtt_rec.transaction_action_id = inv_globals.g_action_subxfr))
      )
                 --   AND (p_mmtt_rec.lpn_id IS NULL) Bug#6770593
		      AND (p_mmtt_rec.content_lpn_id IS NOT NULL)
		      AND (p_mmtt_rec.inventory_item_id <> -1)
		      THEN -- For a staging transfer transaction with content_lpn_id, get the cost group from the content lpn ID
		   l_lpn_id := p_mmtt_rec.content_lpn_id;

		   --Bug 2631651 fix. For sales order issue transactions,if the serial control is set at
 		   --sales order issue msn wouldn't have cost group id
 		   --stamped so we have to get the cost group from onhand,
 		   --considering the item as a non serial controlled item
 		   --(by passing null for p_serial_number parameter)

 		   IF p_mmtt_rec.item_serial_control_code = 6 AND rec_msn.cost_group_id IS NULL THEN

 		      proc_determine_costgroup(p_organization_id         =>   p_mmtt_rec.organization_id,
 					       p_inventory_item_id       =>   p_mmtt_rec.inventory_item_id,
 					       p_subinventory_code       =>   p_mmtt_rec.subinventory_code,
 					       p_locator_id              =>   p_mmtt_rec.locator_id,
 					       p_revision                =>   p_mmtt_rec.revision,
 					       p_lot_number              =>   rec_mtlt.lot_number,
 					       p_serial_number           =>   NULL,
 					       p_containerized_flag      =>   2, -- param is ignored by	the PROCEDURE
 					       p_lpn_id                  =>   l_lpn_id,
 					       p_transaction_action_id   =>   p_mmtt_rec.transaction_action_id,
 					       p_is_backflush_txn        =>   FALSE,
 					       x_cost_group_id           =>   l_cost_group_id,
 					       x_return_status           =>   x_return_status);

 		      rec_msn.cost_group_id := l_cost_group_id;

 		   END IF;
 		   --Bug 2631651 fix

		END IF;

		IF l_onhand_exists THEN

		   IF i=1 THEN --When the l_serial_table is empty
		      l_serial_table(l_sti).from_serial_number := rec_msn.serial_number;
		      l_serial_table(l_sti).to_serial_number := rec_msn.serial_number;
		      --l_serial_table(l_sti).lot_number := rec_mtlt.lot_number;
		      l_serial_table(l_sti).cost_group_id := rec_msn.cost_group_id;
		      l_serial_table(l_sti).quantity := 1;

		      IF lot_cg_qty_table.exists(rec_msn.cost_group_id) then
			 l_serial_table(l_sti).new_serial_transaction_temp_id
			   := lot_cg_qty_table(rec_msn.cost_group_id).serial_transaction_temp_id;
			 --Bug 3390284
			 lot_cg_qty_table(rec_msn.cost_group_id).quantity := lot_cg_qty_table(rec_msn.cost_group_id).quantity + 1;
			 --Bug 3390284
		       ELSE
			 SELECT mtl_material_transactions_s.NEXTVAL
			   INTO l_transaction_temp_id
			   FROM dual;

			 l_serial_table(l_sti).new_serial_transaction_temp_id:= l_transaction_temp_id;

			 --Bug 3390284
			 lot_cg_qty_table(rec_msn.cost_group_id).quantity := 1;
			 lot_cg_qty_table(rec_msn.cost_group_id).serial_transaction_temp_id := l_transaction_temp_id;
			 --Bug 3390284
		      END IF;

		      l_serial_table(l_sti).update_msnt := TRUE;
		      l_msnt_rowid_table(l_sti) := rec_msnt.msnt_rowid;

		      IF j = 1 THEN
			 --l_serial_table(l_sti).update_mtlt := TRUE;
			 l_mtlt_rowid_table(l_sti) := rec_mtlt.mtlt_rowid;
			 j := j + 1;
		       ELSE
			 --l_serial_table(l_sti).update_mtlt := FALSE;
			 NULL;
		      END IF;

		      l_msnt_table(l_sti) := rec_msnt;
		      --l_mtlt_table(l_sti) := rec_mtlt;

		      l_sti := l_sti + 1;
		      i := i + 1;
		    ELSIF i<>1 THEN -- When there are records in l_serial_table
		      -- If the Cost Group ID of this record is the same as that of
		      -- the previous record then extend the serial number range of
		      -- the previous record otherwise insert a new record
		      IF rec_msn.cost_group_id = l_serial_table(l_sti-1).cost_group_id THEN
			 l_serial_table(l_sti-1).to_serial_number := rec_msn.serial_number;
			 l_serial_table(l_sti-1).quantity := l_serial_table(l_sti-1).quantity + 1;

			 --3390284
			 IF lot_cg_qty_table.exists(rec_msn.cost_group_id) then
			    lot_cg_qty_table(rec_msn.cost_group_id).quantity :=
			      lot_cg_qty_table(rec_msn.cost_group_id).quantity + 1 ;
			  ELSE
			    RAISE fnd_api.g_exc_error ;
			 END IF;
			 --Bug 3390284
		       ELSE
			 l_serial_table(l_sti).from_serial_number := rec_msn.serial_number;
			 l_serial_table(l_sti).to_serial_number := rec_msn.serial_number;
			 --l_serial_table(l_sti).lot_number := rec_mtlt.lot_number;
			 l_serial_table(l_sti).cost_group_id := rec_msn.cost_group_id;
			 l_serial_table(l_sti).quantity := 1;

			  SELECT mtl_material_transactions_s.NEXTVAL
			  INTO l_transaction_temp_id
			  FROM dual;

			  --3390284
			 IF lot_cg_qty_table.exists(rec_msn.cost_group_id) then
			    lot_cg_qty_table(rec_msn.cost_group_id).quantity :=
			      lot_cg_qty_table(rec_msn.cost_group_id).quantity + 1 ;
			    l_transaction_temp_id := lot_cg_qty_table(rec_msn.cost_group_id).serial_transaction_temp_id;
			  ELSE
			    lot_cg_qty_table(rec_msn.cost_group_id).quantity := 1;
			    lot_cg_qty_table(rec_msn.cost_group_id).serial_transaction_temp_id := l_transaction_temp_id;
			 END IF;
			 --Bug 3390284

			 l_serial_table(l_sti).new_serial_transaction_temp_id:= l_transaction_temp_id;
			 l_serial_table(l_sti).update_msnt := FALSE;
			 --  l_serial_table(l_sti).update_mtlt := FALSE;

			 l_msnt_table(l_sti) := rec_msnt;
			 --l_mtlt_table(l_sti) := rec_mtlt;

			 l_sti := l_sti + 1;
		      END IF;
		   END IF;


		   IF rec_msn.cost_group_id IS NULL THEN
		      proc_get_pending_costgroup(p_organization_id       => p_mmtt_rec.organization_id,
						 p_inventory_item_id     => p_mmtt_rec.inventory_item_id,
						 p_subinventory_code     => p_mmtt_rec.subinventory_code,
						 p_locator_id            => p_mmtt_rec.locator_id,
						 p_revision              => p_mmtt_rec.revision,
						 p_lot_number            => p_mmtt_rec.lot_number,
						 p_serial_number         => rec_msn.serial_number,
						 p_lpn_id                => p_mmtt_rec.lpn_id,
						 p_transaction_action_id => p_mmtt_rec.transaction_action_id,
						 x_cost_group_id         => l_cost_group_id,
						 x_return_status         => x_return_status);
		      rec_msn.cost_group_id := l_cost_group_id;
		      IF x_return_status =  fnd_api.g_ret_sts_error THEN
			 RAISE fnd_api.g_exc_error ;
		      END IF;
		   END IF;

		   IF l_cg_quantity_table.exists(rec_msn.cost_group_id) THEN
		      l_cg_quantity_table(rec_msn.cost_group_id).quantity :=
			l_cg_quantity_table(rec_msn.cost_group_id).quantity + 1;
		    ELSE
		      IF l_cg_quantity_table.COUNT = 0 THEN
			 -- If the table is empty then the existing
			 -- transaction_temp_id should be used as the
			 -- new_transaction_temp_id also
			 l_cg_quantity_table(rec_msn.cost_group_id).new_transaction_temp_id := p_mmtt_rec.transaction_temp_id;
			 l_cg_quantity_table(rec_msn.cost_group_id).update_mmtt := TRUE;
		       ELSE
			 -- otherwise generate a new_transaction_temp_id
			 SELECT mtl_material_transactions_s.NEXTVAL
			   INTO l_transaction_temp_id
			   FROM dual;
			 l_cg_quantity_table(rec_msn.cost_group_id).new_transaction_temp_id := l_transaction_temp_id;
			 l_cg_quantity_table(rec_msn.cost_group_id).update_mmtt := FALSE;
		      END IF;
		      l_cg_quantity_table(rec_msn.cost_group_id).quantity := 1;
		   END IF;
		END IF;
	     END LOOP;
	     FETCH cur_msnt INTO rec_msnt;
	END LOOP;
     END IF;
     IF (l_debug = 1) THEN
        print_debug('Closing MSNT cursor... ');
     END IF;
     CLOSE cur_msnt;

     --Bug3390284
     --Copying information to l_lot_table
     IF lot_cg_qty_table.COUNT > 0 THEN
	l_last := lot_cg_qty_table.last;
	lot_cgi := lot_cg_qty_table.first;
	LOOP
	   l_lti := l_lti + 1;
	   l_lot_table(l_lti).mtlt_rowid := rec_mtlt.mtlt_ROWID;
	   l_lot_table(l_lti).lot_number := rec_mtlt.lot_number;
	   l_mtlt_table(l_lti) := rec_mtlt;
	   l_lot_table(l_lti).quantity := lot_cg_qty_table(lot_cgi).quantity;
	   l_lot_table(l_lti).serial_transaction_temp_id := lot_cg_qty_table(lot_cgi).serial_transaction_temp_id;
	   l_lot_table(l_lti).cost_group_id := lot_cgi;
	   IF lot_cgi = lot_cg_qty_table.first THEN
	      l_lot_table(l_lti).update_mtlt := TRUE;
	    ELSE
	      l_lot_table(l_lti).update_mtlt := FALSE;
	   END IF;

	   EXIT WHEN  (l_last = lot_cgi);

	   lot_cgi := lot_cg_qty_table.next(lot_cgi);

	END LOOP;
     END IF;
     --Bug3390284

     FETCH cur_mtlt INTO rec_mtlt;
  END LOOP;
  IF (l_debug = 1) THEN
     print_debug('Closing MTLT cursor... ');
  END IF;
  CLOSE cur_mtlt;

  -- If the item is to be treated as a lot control item then
  IF call_lot_control = TRUE THEN
     proc_process_lots
       (p_mmtt_rec                => p_mmtt_rec,
	p_fob_point               => p_fob_point,
	p_transfer_wms_org        => p_transfer_wms_org,
	p_tfr_primary_cost_method => p_tfr_primary_cost_method,
	p_tfr_org_cost_group_id   => p_tfr_org_cost_group_id,
	p_from_project_id         => p_from_project_id,
	p_to_project_id           => p_to_project_id,
	x_return_status           => x_return_status,
	x_msg_count               => x_msg_count,
	x_msg_data                => x_msg_data);
     RETURN;
  END IF;

  -- Insert or update the records in l_cg_quantity_table into MMTT
  IF (l_debug = 1) THEN
     print_debug('count: ' || l_cg_quantity_table.count);
  END IF;

  IF l_cg_quantity_table.COUNT > 0 THEN
     IF (l_debug = 1) THEN
	print_debug('proc_process_lot_serial..Inserting records INTO MMTT ');
     END IF;
     i := l_cg_quantity_table.first;
     IF p_mmtt_rec.transaction_quantity >= 0 THEN
	l_quantity_sign := 1;
      ELSE
	l_quantity_sign := -1;
     END IF;

     IF (l_debug = 1) THEN
	print_debug('Primary UOM: ' || p_mmtt_rec.item_primary_uom_code);
	print_debug('Txn UOM: ' || p_mmtt_rec.transaction_uom);
	print_debug('Qty: ' || l_cg_quantity_table(i).quantity);
     END IF;
     LOOP
	l_transaction_quantity := inv_convert.inv_um_convert
	  (p_mmtt_rec.inventory_item_id,
	   5,
	   l_cg_quantity_table(i).quantity,
	   p_mmtt_rec.item_primary_uom_code,
	   p_mmtt_rec.transaction_uom,
	   NULL,
	   NULL);
	l_transaction_quantity := l_transaction_quantity * l_quantity_sign;
	IF (l_debug = 1) THEN
	   print_debug('qty: ' || l_transaction_quantity);
	   print_debug('qty sign: ' || l_quantity_sign);
	END IF;
	IF l_cg_quantity_table(i).update_mmtt = FALSE THEN
	   proc_insert_mmtt(p_mmtt_rec,
			    p_transfer_wms_org,
			    p_fob_point,
			    p_tfr_primary_cost_method,
			    p_tfr_org_cost_group_id,
			    i, -- Remember that i is also the cost_group_id of the record
			    NULL,
			    l_cg_quantity_table(i).quantity * l_quantity_sign,
			    l_transaction_quantity,
			    l_cg_quantity_table(i).new_transaction_temp_id,
			    p_from_project_id,
			    p_to_project_id,
			    x_return_status);

	   IF (l_debug = 1) THEN
	      print_debug('proc_insert_mmtt return : ' || x_return_status);
	   END IF;
	 ELSE
	   proc_update_mmtt(p_mmtt_rec.transaction_temp_id,
			    p_transfer_wms_org,
			    p_fob_point,
			    p_tfr_primary_cost_method,
			    p_tfr_org_cost_group_id,
			    p_mmtt_rec.transaction_action_id,
			    p_mmtt_rec.transfer_organization,
			    p_mmtt_rec.transfer_subinventory,
			    i, -- Remember that i is also the cost_group_id of the record
			    NULL,
			    l_cg_quantity_table(i).quantity * l_quantity_sign,
			    l_transaction_quantity,
			    p_from_project_id,
			    p_to_project_id,
			    x_return_status);

	   IF (l_debug = 1) THEN
	      print_debug('proc_update_mmtt return : ' || x_return_status);
	     END IF;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_error)
	    THEN
	   RAISE fnd_api.g_exc_error;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	  THEN
	   RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	EXIT WHEN i = l_cg_quantity_table.last;
	i := l_cg_quantity_table.next(i);
     END LOOP;

     -- Insert or update the records in l_lot_serial_table into MTLT and MSNT
     IF (l_debug = 1) THEN
	print_debug('IN proc_process_lot_serial..Inserting records INTO MTLT');
     END IF;

     --3390284 Now inserting records into mtlt with the information from the lot
     --table

     FOR lot_i IN 1..l_lot_table.COUNT LOOP
	l_transaction_quantity := inv_convert.inv_um_convert
	  (p_mmtt_rec.inventory_item_id,
	   5,
	   l_lot_table(lot_i).quantity,
	   p_mmtt_rec.item_primary_uom_code,
	   p_mmtt_rec.transaction_uom,
	   NULL,
	   NULL);
	IF l_lot_table(lot_i).update_mtlt THEN
	   proc_update_mtlt(l_lot_table(lot_i).mtlt_rowid,
			    l_cg_quantity_table(l_lot_table(lot_i).cost_group_id).new_transaction_temp_id,
			    l_lot_table(lot_i).lot_number,
			    l_lot_table(lot_i).quantity,
			    l_transaction_quantity,
			    l_lot_table(lot_i).serial_transaction_temp_id,
			    x_return_status);

	 ELSE
	   proc_insert_mtlt(l_mtlt_table(lot_i),
			    l_cg_quantity_table(l_lot_table(lot_i).cost_group_id).new_transaction_temp_id,
			    l_lot_table(lot_i).quantity,
			    l_transaction_quantity,
			    l_lot_table(lot_i).serial_transaction_temp_id,
			    x_return_status);
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_error)
	  THEN
	   RAISE fnd_api.g_exc_error ;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	  THEN
	   RAISE fnd_api.g_exc_unexpected_error ;
	END IF;

     END LOOP;

     --3390284


     IF (l_debug = 1) THEN
	print_debug('IN proc_process_lot_serial..Inserting records INTO MSNT');
     END IF;

     FOR i IN 1..l_serial_table.COUNT LOOP


	IF l_serial_table(i).update_msnt = TRUE THEN -- Update the MSNT records
	   IF (l_debug = 1) THEN
	      print_debug('updating MSNT ');
	   END IF;
	   proc_update_msnt(l_msnt_rowid_table(i),
			    l_serial_table(i).new_serial_transaction_temp_id,
			    l_serial_table(i).from_serial_number,
			    l_serial_table(i).to_serial_number,
			    x_return_status);

	   IF (l_debug = 1) THEN
	      print_debug('proc_update_msnt return : ' || x_return_status);
	   END IF;
	 ELSE -- Insert into MSNT to create new records
	   IF (l_debug = 1) THEN
	      print_debug('inserting into MSNT ');
	   END IF;
	   proc_insert_msnt(l_msnt_table(i),
			    l_serial_table(i).from_serial_number,
			    l_serial_table(i).to_serial_number,
			    l_serial_table(i).new_serial_transaction_temp_id,
			    x_return_status);

	   IF (l_debug = 1) THEN
	      print_debug('proc_insert_msnt return : ' || x_return_status);
	   END IF;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_error)
	  THEN
	   RAISE fnd_api.g_exc_error ;
	END IF;

	IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	  THEN
	   RAISE fnd_api.g_exc_unexpected_error ;
	END IF;

     END LOOP;
  END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 1) THEN
         print_debug('proc_process_lot_serial .. EXCEP G_EXC_ERROR : ' );
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF cur_msnt%isopen THEN
	 CLOSE cur_msnt;
      END IF;
      IF cur_mtlt%isopen THEN
	 CLOSE cur_mtlt;
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 1) THEN
         print_debug('proc_process_lot_serial .. EXCEP G_EXC_UNEXPECTED_ERROR : ' );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF cur_msnt%isopen THEN
	 CLOSE cur_msnt;
      END IF;
      IF cur_mtlt%isopen THEN
	 CLOSE cur_mtlt;
      END IF;
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('proc_process_lot_serial .. EXCEP OTHERS : ' || SQLERRM(SQLCODE));
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF cur_msnt%isopen THEN
	 CLOSE cur_msnt;
      END IF;
      IF cur_mtlt%isopen THEN
	 CLOSE cur_mtlt;
      END IF;
END proc_process_lot_serial;

-- Main Logic

PROCEDURE cost_group_update
          (p_transaction_rec            IN   mtl_material_transactions_temp%ROWTYPE,
	   p_fob_point                  IN   mtl_interorg_parameters.fob_point%TYPE DEFAULT NULL,
	   p_transfer_wms_org           IN   BOOLEAN DEFAULT TRUE,
	   p_tfr_primary_cost_method    IN   NUMBER,
	   p_tfr_org_cost_group_id      IN   NUMBER,
	   p_from_project_id            IN   NUMBER DEFAULT NULL,
	   p_to_project_id              IN   NUMBER DEFAULT NULL,
	   x_return_status              OUT  NOCOPY VARCHAR2,
	   x_msg_count                  OUT  NOCOPY NUMBER,
	   x_msg_data                   OUT  NOCOPY VARCHAR2)
IS
   l_api_name               CONSTANT VARCHAR2(50)                    :=  'cost_group_update';
   l_txn_temp_id            NUMBER                                   :=  0;
   l_prev_rowid             ROWID                                    :=  NULL;
   l_prev_org_id            mtl_parameters.organization_id%TYPE      :=  NULL;
   l_primary_qty            NUMBER                                   :=  NULL;
   l_is_lot_control         BOOLEAN                                  :=  NULL;
   l_is_serial_control      BOOLEAN                                  :=  NULL;
   l_cost_group_id          NUMBER                                   := 0;
   l_mmtt_rec               mtl_material_transactions_temp%ROWTYPE;
   l_lpn_id                 NUMBER := p_transaction_rec.lpn_id;
   l_onhand_exists          BOOLEAN := TRUE;
   l_is_backflush_txn       BOOLEAN := FALSE;
   l_lot_number             VARCHAR2(80);   --- BUG#4291891 Joe DiIorio 04/08/2005
   l_transfer_cost_group_id NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT   API_updatecostgroups;
   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) THEN
      print_debug('Beginning get_cost_group.... with temp_id: ' ||
			  l_mmtt_rec.transaction_temp_id);
   END IF;

   l_mmtt_rec := p_transaction_rec;

   -- If this is a DirectOrg or an IntransitShipment Transaction and
   -- the transfer CostGroupId is NULL, then run the RulesEngine
   -- to pick the appropriate CostGroupId for the transfer side
   l_cost_group_id := l_mmtt_rec.cost_group_id;
   l_transfer_cost_group_id := l_mmtt_rec.transfer_cost_group_id;

   IF l_transfer_cost_group_id IS NULL AND p_transfer_wms_org AND
     ((l_mmtt_rec.transaction_action_id = inv_globals.g_action_orgxfr) OR
      (l_mmtt_rec.transaction_action_id = inv_globals.g_action_intransitshipment
      AND p_fob_point = 1)
      OR (l_mmtt_rec.transaction_action_id = inv_globals.g_action_intransitreceipt)
      )
     THEN
      IF (l_debug = 1) THEN
         print_debug('Getting transfer cost group id from rules engine...: ');
      END IF;
      wms_costgroupengine_pvt.assign_cost_group
	                 (p_api_version => 1.0,
			  p_init_msg_list => FND_API.G_FALSE,
			  p_commit => FND_API.G_FALSE,
			  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
			  x_return_status => x_return_Status,
			  x_msg_count => x_msg_count,
			  x_msg_data => x_msg_data,
			  p_line_id  => l_mmtt_rec.transaction_temp_id,
			  p_input_type => wms_costgroupengine_pvt.g_input_mmtt);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	  IF (l_debug = 1) THEN
   	  print_debug('return error from wms_costgroupengine_pvt');
	  END IF;
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	 IF (l_debug = 1) THEN
   	 print_debug('return unexpected error from wms_costgroupengine_pvt');
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Requery MMTT to get the fresh records
      SELECT *
	INTO l_mmtt_rec
	FROM mtl_material_transactions_temp
	WHERE transaction_temp_id = l_mmtt_rec.transaction_temp_id;

      IF (l_debug = 1) THEN
         print_debug('CG from RULES engine: ' || l_mmtt_rec.cost_group_id);
         print_debug('TCG from RULES engine: ' || l_mmtt_rec.transfer_cost_group_id);
      END IF;
   END IF;

   -- If transaction is not lpn triggered...
   IF l_mmtt_rec.inventory_item_id <> -1 THEN
      SELECT lot_control_code, serial_number_control_code, primary_uom_code
	INTO l_mmtt_rec.item_lot_control_code,
	l_mmtt_rec.item_serial_control_code, l_mmtt_rec.item_primary_uom_code
	FROM mtl_system_items
	WHERE organization_id = l_mmtt_rec.organization_id
	AND inventory_item_id = l_mmtt_rec.inventory_item_id;
    ELSE
      RETURN;
   END IF;

   IF inv_globals.is_issue_xfr_transaction(l_mmtt_rec.transaction_action_id) THEN
      IF l_mmtt_rec.transfer_cost_group_id IS NOT NULL
	AND l_mmtt_rec.cost_group_id IS NOT NULL THEN
	 RETURN;
       ELSIF l_mmtt_rec.cost_group_id IS NOT NULL AND
	 l_mmtt_rec.transfer_cost_group_id IS NULL THEN
	 proc_update_mmtt(l_mmtt_rec.transaction_temp_id,
			  p_transfer_wms_org,
			  p_fob_point,
			  p_tfr_primary_cost_method,
			  p_tfr_org_cost_group_id,
			  l_mmtt_rec.transaction_action_id,
			  l_mmtt_rec.transfer_organization,
			  l_mmtt_rec.transfer_subinventory,
			  l_cost_group_id,
			  NULL,
			  NULL,
			  NULL,
			  p_from_project_id,
			  p_to_project_id,
			  x_return_status);
	 IF (l_debug = 1) THEN
   	 print_debug('proc_update_mmtt : ' || x_return_status);
	 END IF;
	 IF (x_return_status =  fnd_api.g_ret_sts_error)
	   THEN
	    RAISE fnd_api.g_exc_error ;
	 END IF;

	 IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	   THEN
	    RAISE fnd_api.g_exc_unexpected_error ;
	 END IF;
	 RETURN;
      END IF;

   END IF;

   IF (l_debug = 1) THEN
      print_debug('Org: ' ||  l_mmtt_rec.organization_id);
      print_debug('Item: ' ||  l_mmtt_rec.inventory_item_id);
      print_debug('Lot control code: ' || l_mmtt_rec.item_lot_control_code);
      print_debug('Serial control code: ' || l_mmtt_rec.item_serial_control_code);
      print_debug('Action ID: ' ||  l_mmtt_rec.transaction_action_id);
      print_debug('Primary UOM: ' || l_mmtt_rec.item_primary_uom_code);
      print_debug('Txn UOM: ' || l_mmtt_rec.transaction_uom);
      print_debug('Qty: ' || l_mmtt_rec.transaction_quantity);
   END IF;

   l_txn_temp_id := l_mmtt_rec.transaction_header_id;
   IF (l_debug = 1) THEN
      print_debug('header_id:'||l_txn_temp_id || ':');
   END IF;

   IF l_mmtt_rec.item_lot_control_code = 2
     THEN
      l_is_lot_control    := TRUE;
    ELSE
      l_is_lot_control    := FALSE;
   END IF;

   IF l_mmtt_rec.item_serial_control_code = 1
     THEN
      IF (l_debug = 1) THEN
         print_debug('l_is_serial_control: FALSE: ' || l_mmtt_rec.item_serial_control_code);
      END IF;
      l_is_serial_control := FALSE;
    ELSE
       IF (l_debug = 1) THEN
          print_debug('l_is_serial_control: TRUE: ' || l_mmtt_rec.item_serial_control_code);
       END IF;
      l_is_serial_control := TRUE;
   END IF;

   -- only one serial/lot number for the line
   IF (l_mmtt_rec.serial_number IS NOT NULL) OR
     (l_mmtt_rec.lot_number IS NOT NULL) THEN

      l_lot_number := l_mmtt_rec.lot_number;
      -- Check if there is any MTLT record corresponding to this MMTT, use
      -- that to get the value of the lot number
      IF l_mmtt_rec.lot_number IS NULL THEN
	 BEGIN
	    SELECT lot_number
	      INTO l_lot_number
	      FROM mtl_transaction_lots_temp
	      WHERE transaction_temp_id = l_mmtt_rec.transaction_temp_id;
	    IF (l_debug = 1) THEN
   	    print_debug('Lot number from MTLT: ' || l_lot_number);
	    END IF;
	 EXCEPTION
	    WHEN no_data_found THEN
	       IF (l_debug = 1) THEN
   	       print_debug('No MTLT found: ' || l_lot_number);
	       END IF;
	       l_lot_number := NULL;
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
   	       print_debug('Unexpected error:' || Sqlerrm);
	       END IF;
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END;
      END IF;

      IF l_mmtt_rec.transaction_action_id IN (inv_globals.g_type_cycle_count_adj,
					      inv_globals.g_type_physical_count_adj,
					      inv_globals.g_action_deliveryadj)
	THEN
	 IF l_mmtt_rec.transaction_action_id IN (inv_globals.g_type_physical_count_adj,
						 inv_globals.g_action_deliveryadj) THEN
	    IF l_mmtt_rec.lpn_id IS NOT NULL THEN
	       l_lpn_id := l_mmtt_rec.lpn_id;
	     ELSIF l_mmtt_rec.content_lpn_id IS NOT NULL THEN
	       l_lpn_id := l_mmtt_rec.content_lpn_id;
	     ELSIF l_mmtt_rec.transfer_lpn_id IS NOT NULL THEN
	       l_lpn_id := l_mmtt_rec.transfer_lpn_id;
	    END IF;
	  ELSIF l_mmtt_rec.transaction_action_id = inv_globals.g_type_cycle_count_adj
	    THEN
	    l_lpn_id := l_mmtt_rec.transfer_lpn_id;
	 END IF;

	 l_onhand_exists :=
	   onhand_quantity_exists
	   (p_inventory_item_id => l_mmtt_rec.inventory_item_id,
	    p_revision          => l_mmtt_rec.revision,
	    p_organization_id   => l_mmtt_rec.organization_id,
	    p_subinventory_code => l_mmtt_rec.subinventory_code,
	    p_locator_id        => l_mmtt_rec.locator_id,
	    p_lot_number        => l_lot_number,
	    p_serial_number     => l_mmtt_rec.serial_number,
	    p_lpn_id            => l_lpn_id);
	 IF NOT l_onhand_exists THEN
	    IF (l_debug = 1) THEN
   	    print_debug('Treating this as as receipt transaction...: ');
   	    print_debug('Getting transfer cost group id from rules engine...: ');
	    END IF;
	    wms_costgroupengine_pvt.assign_cost_group
	      (p_api_version => 1.0,
	       p_init_msg_list => FND_API.G_FALSE,
	       p_commit => FND_API.G_FALSE,
	       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	       x_return_status => x_return_Status,
	       x_msg_count => x_msg_count,
	       x_msg_data => x_msg_data,
	       p_line_id  => l_mmtt_rec.transaction_temp_id,
	       p_input_type => wms_costgroupengine_pvt.g_input_mmtt);

	    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	       IF (l_debug = 1) THEN
   	       print_debug('return error from wms_costgroupengine_pvt');
	       END IF;
	       RAISE FND_API.G_EXC_ERROR;
	     ELSIF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	       IF (l_debug = 1) THEN
   	       print_debug('return unexpected error from wms_costgroupengine_pvt');
	       END IF;
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

	 END IF;
      END IF;

      IF l_onhand_exists THEN
	 IF (l_debug = 1) THEN
   	 print_debug('proc_determine_costgroup: ');
	 END IF;

	 IF l_mmtt_rec.move_transaction_id IS NOT NULL OR
	   l_mmtt_rec.completion_transaction_id IS NOT NULL THEN
	    l_is_backflush_txn := TRUE;
	 END IF;

	 proc_determine_costgroup(p_organization_id       =>  l_mmtt_rec.organization_id,
				  p_inventory_item_id     =>  l_mmtt_rec.inventory_item_id,
				  p_subinventory_code     =>  l_mmtt_rec.subinventory_code,
				  p_locator_id            =>  l_mmtt_rec.locator_id,
				  p_revision              =>  l_mmtt_rec.revision,
				  p_lot_number            =>  l_lot_number,
				  p_serial_number         =>  l_mmtt_rec.serial_number,
				  p_containerized_flag    =>  2, -- we need unpacked material from moq
				  p_lpn_id                =>  l_lpn_id,
				  p_transaction_action_id =>  l_mmtt_rec.transaction_action_id,
				  p_is_backflush_txn      =>  l_is_backflush_txn,
				  x_cost_group_id         =>  l_cost_group_id,
				  x_return_status         =>  x_return_status);

	 IF (l_debug = 1) THEN
   	 print_debug('proc_determine_costgroup return : ' || x_return_status);
   	 print_debug('cost_group_id: ' ||  l_cost_group_id);
	 END IF;

	 IF (x_return_status =  fnd_api.g_ret_sts_error)
	   THEN
	    RAISE fnd_api.g_exc_error ;
	 END IF;

	 IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	   THEN
	    RAISE fnd_api.g_exc_unexpected_error ;
	 END IF;

	 proc_update_mmtt(l_mmtt_rec.transaction_temp_id,
			  p_transfer_wms_org,
			  p_fob_point,
			  p_tfr_primary_cost_method,
			  p_tfr_org_cost_group_id,
			  l_mmtt_rec.transaction_action_id,
			  l_mmtt_rec.transfer_organization,
			  l_mmtt_rec.transfer_subinventory,
			  l_cost_group_id,
			  NULL,
			  NULL,
			  NULL,
			  p_from_project_id,
			  p_to_project_id,
			  x_return_status);
	 IF (l_debug = 1) THEN
   	 print_debug('proc_update_mmtt : ' || x_return_status);
	 END IF;
	 IF (x_return_status =  fnd_api.g_ret_sts_error)
	   THEN
	    RAISE fnd_api.g_exc_error ;
	 END IF;

	 IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	   THEN
	    RAISE fnd_api.g_exc_unexpected_error ;
	 END IF;
      END IF; -- If onhand exists
    ELSE
      IF l_is_lot_control THEN
	 IF l_is_serial_control THEN
	    -- Lot and serial controlled
	    IF (l_debug = 1) THEN
   	    print_debug('proc_process_lot_serial: ');
	    END IF;
	    proc_process_lot_serial
	      (p_mmtt_rec                =>  l_mmtt_rec,
	       p_fob_point               =>  p_fob_point,
	       p_transfer_wms_org        =>  p_transfer_wms_org,
	       p_tfr_primary_cost_method =>  p_tfr_primary_cost_method,
	       p_tfr_org_cost_group_id   =>  p_tfr_org_cost_group_id,
	       p_from_project_id         =>  p_from_project_id,
	       p_to_project_id           =>  p_to_project_id,
	       x_return_status           =>  x_return_status,
	       x_msg_count               =>  x_msg_count,
	       x_msg_data                =>  x_msg_data);
	    IF (l_debug = 1) THEN
   	    print_debug('proc_process_lot_serial: x_return_status: ' ||  x_return_status);
	    END IF;
	    IF (x_return_status =  fnd_api.g_ret_sts_error)
	      THEN
	       RAISE fnd_api.g_exc_error ;
	    END IF;

	    IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	      THEN
	       RAISE fnd_api.g_exc_unexpected_error ;
	    END IF;
	  ELSE
	    -- Lot controlled
	    proc_process_lots
	      (p_mmtt_rec                =>  l_mmtt_rec,
	       p_fob_point               =>  p_fob_point,
	       p_transfer_wms_org        =>  p_transfer_wms_org,
	       p_tfr_primary_cost_method =>  p_tfr_primary_cost_method,
	       p_tfr_org_cost_group_id   =>  p_tfr_org_cost_group_id,
	       p_from_project_id         =>  p_from_project_id,
	       p_to_project_id           =>  p_to_project_id,
	       x_return_status           =>  x_return_status,
	       x_msg_count               =>  x_msg_count,
	       x_msg_data                =>  x_msg_data);

	    IF (l_debug = 1) THEN
   	    print_debug('proc_process_lots return: ' || x_return_status);
	    END IF;
	    IF (x_return_status =  fnd_api.g_ret_sts_error)
	      THEN
	       RAISE fnd_api.g_exc_error ;
	    END IF;

	    IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	      THEN
	       RAISE fnd_api.g_exc_unexpected_error ;
	    END IF;
	 END IF;
       ELSE
	 IF l_is_serial_control THEN
	    -- Serial control
	    IF (l_debug = 1) THEN
   	    print_debug('is_serial_control: ' );
	    END IF;
	    -- Mrana inv_cost_group_update.proc_process_serials
	    proc_process_serials
	      (p_mmtt_rec                => l_mmtt_rec,
	       p_fob_point               => p_fob_point,
	       p_transfer_wms_org        => p_transfer_wms_org,
	       p_tfr_primary_cost_method => p_tfr_primary_cost_method,
	       p_tfr_org_cost_group_id   => p_tfr_org_cost_group_id,
	       p_from_project_id         => p_from_project_id,
	       p_to_project_id           => p_to_project_id,
	       x_return_status           => x_return_status,
	       x_msg_count               => x_msg_count,
	       x_msg_data                => x_msg_data);

	    IF (l_debug = 1) THEN
   	    print_debug('proc_process_serials return: ' || x_return_status);
	    END IF;
	    IF (x_return_status =  fnd_api.g_ret_sts_error)
	      THEN
	       RAISE fnd_api.g_exc_error ;
	    END IF;

	    IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	      THEN
	       RAISE fnd_api.g_exc_unexpected_error ;
	    END IF;
	  ELSE
	    -- No control
	    IF (l_debug = 1) THEN
   	    print_debug('Nocontrol: Call proc_process_nocontrol: Trx temp id:'
				   || l_mmtt_rec.transaction_temp_id);
	    END IF;
	    -- process mmtt
	    proc_process_nocontrol
	      (p_mmtt_rec                => l_mmtt_rec,
	       p_fob_point               => p_fob_point,
	       p_transfer_wms_org        => p_transfer_wms_org,
	       p_tfr_org_cost_group_id   => p_tfr_org_cost_group_id,
	       p_tfr_primary_cost_method => p_tfr_primary_cost_method,
	       p_from_project_id         => p_from_project_id,
	       p_to_project_id           => p_to_project_id,
	       x_return_status           => x_return_status,
	       x_msg_count               => x_msg_count,
	       x_msg_data                => x_msg_data);
	    IF (l_debug = 1) THEN
   	    print_debug('proc_process_nocontrol return : ' || x_return_status);
	    END IF;
	    IF (x_return_status =  fnd_api.g_ret_sts_error)
	      THEN
	       RAISE fnd_api.g_exc_error ;
	    END IF;

	    IF (x_return_status =  fnd_api.g_ret_sts_unexp_error)
	      THEN
	       RAISE fnd_api.g_exc_unexpected_error ;
	    END IF;
	    IF (l_debug = 1) THEN
   	    print_debug('after call to nocontrol');
	    END IF;
	 END IF;
      END IF;
   END IF;
   IF (l_debug = 1) THEN
      print_debug('Processing Over... ' || x_return_status );
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF (l_debug = 1) THEN
          print_debug('inv_cost_group_update .. EXCEP G_EXC_ERROR : ' );
       END IF;
       ROLLBACK TO API_updatecostgroups;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
	 (p_encoded   =>      FND_API.G_FALSE,
	  p_count     =>      x_msg_count,
	  p_data      =>      x_msg_data);
       IF (l_debug = 1) THEN
          print_debug(' over ');
       END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 1) THEN
         print_debug('inv_cost_group_update .. EXCEP G_EXC_UNEXPECTED_ERROR : ' );
      END IF;
      ROLLBACK TO API_updatecostgroups;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_encoded   =>      FND_API.G_FALSE,
	 p_count     =>      x_msg_count,
	 p_data      =>      x_msg_data);
      IF (l_debug = 1) THEN
         print_debug(' over ' );
      END IF;
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('inv_cost_group_update .. EXCEP G_EXC_UNEXPECTED_ERROR : ' );
      END IF;
      ROLLBACK TO API_updatecostgroups;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg (g_pkg_name,
				  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(p_encoded   =>      FND_API.G_FALSE,
	 p_count     =>      x_msg_count,
	 p_data      =>      x_msg_data);
      IF (l_debug = 1) THEN
         print_debug(' over ');
      END IF;
END cost_group_update;

END inv_cost_group_update;

/
