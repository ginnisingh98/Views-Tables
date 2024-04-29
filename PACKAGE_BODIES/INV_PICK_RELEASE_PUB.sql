--------------------------------------------------------
--  DDL for Package Body INV_PICK_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PICK_RELEASE_PUB" AS
/* $Header: INVPPICB.pls 120.26.12010000.12 2010/02/09 03:46:17 ksivasa ship $ */

--  Global constant holding the package name
G_PKG_NAME                CONSTANT VARCHAR2(30) := 'INV_Pick_Release_PUB';

is_debug                  BOOLEAN := NULL;
all_del_det_bo_tbl        WSH_INTERFACE.ChangedAttributeTabType;
g_org_grouping_rule_id    NUMBER;
g_organization_id         NUMBER;
g_print_mode              VARCHAR2(1);

-- Bug# 4258360: Added these global constants which refer to the allocation method
-- stored for the current pick release batch (refers to INV_CACHE.wpb_rec.allocation_method)
g_inventory_only          CONSTANT VARCHAR2(1) := 'I';
g_crossdock_only          CONSTANT VARCHAR2(1) := 'C';
g_prioritize_inventory    CONSTANT VARCHAR2(1) := 'N';
g_prioritize_crossdock    CONSTANT VARCHAR2(1) := 'X';


-- Start of Comments
-- API name 	Pick_Release
-- Type		Public
-- Purpose
--   Pick releases the move order lines passed in.
--
-- Input Parameters
--   p_api_version_number
--	   API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--	   Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--	   whether or not to commit the changes to database
--
--   p_mo_line_tbl
--       Table of Move Order Line records to pick release
--	p_auto_pick_confirm (optional, default 2)
--       Overrides org-level parameter for whether to automatically call
--		pick confirm after release
--	    Valid values: 1 (yes) or 2 (no)
--   p_grouping_rule_id
--       Overrides org-level and Move Order header-level grouping rule for
--		generating pick slip numbers
--   p_allow_partial_pick
--	    TRUE if the pick release process should continue after a line fails to
--		be detailed completely.  FALSE if the process should stop and roll
--		back all changes if a line cannot be fully detailed.
--	    NOTE: Printing pick slips as the lines are detailed is only supported if
--		this parameter is TRUE, since a commit must be done before printing.
--
-- Output Parameters
--   x_return_status
--       if the pick release process succeeds, the value is
--			fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--             fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--             fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--       	in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   	(See fnd_api package for more details about the above output parameters)
--   x_pick_release_status
--	 This output parameter is a table of records (of type
-- 		INV_Release_Status_Tbl_Type) which specifies the pick release status
--		for each move order line that is passed in.
--

procedure print_debug( p_message in varchar2, p_module in varchar2) is
begin
 	inv_trx_util_pub.trace(p_message, 'PICKREL');
end;



--2509322:Earlier when ever a component in a model is short we backorder all
--   components to the difference of new model quantity and original
--   and repick release all.But if many components are short then we end
--   up splitting many delivery details.
--   Now avoided multiple splits by storing back order details and do only once.

PROCEDURE  Store_smc_bo_details
	   (x_return_status    OUT  NOCOPY VARCHAR2,
            back_order_det_tbl IN WSH_INTERFACE.ChangedAttributeTabType) IS
l_delivery_detail_id       NUMBER;
l_new_cycle_count_quantity NUMBER:=0;
l_old_cycle_count_quantity NUMBER:=0;



BEGIN
 If is_debug Then
   print_debug('Inside Store_smc_bo_details','INV_PICK_RELEASE_PUB');
   print_debug('delivery detail'||back_order_det_tbl(1).delivery_detail_id,
	'INV_PICK_RELEASE_PUB');
 End If;
 x_return_status := fnd_api.g_ret_sts_success;

  if back_order_det_tbl.count >0 then
    l_delivery_detail_id :=back_order_det_tbl(1).delivery_detail_id;
    If is_debug Then
      print_debug('Delivery detail'||l_delivery_detail_id,
	'INV_PICK_RELEASE_PUB');
    End If;
    l_new_cycle_count_quantity :=back_order_det_tbl(1).cycle_count_quantity;

  end if;
  IF all_del_det_bo_tbl.EXISTS(l_delivery_detail_id) then
    l_old_cycle_count_quantity :=
	all_del_det_bo_tbl(l_delivery_detail_id).cycle_count_quantity;
    all_del_det_bo_tbl(l_delivery_detail_id).cycle_count_quantity :=
        l_old_cycle_count_quantity+l_new_cycle_count_quantity;
  ELSE
    all_del_det_bo_tbl(l_delivery_detail_id) :=back_order_det_tbl(1);
  END IF;

  If is_debug Then
    print_debug('New Cycle count Qty: '
	||all_del_det_bo_tbl(l_delivery_detail_id).cycle_count_quantity
        ,'INV_PICK_RELEASE_PUB');
  End If;
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        --
        x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        if is_debug then
          print_debug(SQLERRM,'INV_PICK_RELEASE_PUB');
        end if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN OTHERS THEN
	if is_debug then
          print_debug(SQLERRM,'INV_PICK_RELEASE_PUB');
        end if;
        ROLLBACK TO Pick_Release_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

--2509322:Earlier when ever a component in a model is short we backorder all
-- components to the difference of new model quantity and original
-- and repick release all.But if many components are short then we end
-- up splitting many delivery details.
-- Now avoided multiple splits by storing back order details and do only once.

PROCEDURE Backorder_SMC_DETAILS(x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER
                                ) IS
l_api_name  VARCHAR2(100):='Backorder_SMC_DETAILS';
l_delivery_detail_id NUMBER;
l_shipping_attr  WSH_INTERFACE.ChangedAttributeTabType;
l_del_index INTEGER;

BEGIN
 x_return_status := fnd_api.g_ret_sts_success;

IF all_del_det_bo_tbl.COUNT >0 THEN
   l_del_index :=all_del_det_bo_tbl.FIRST ;
  LOOP
    l_shipping_attr(1).source_header_id :=
	all_del_det_bo_tbl(l_del_index).source_header_id;
    l_shipping_attr(1).source_line_id :=
	all_del_det_bo_tbl(l_del_index).source_line_id;
    l_shipping_attr(1).ship_from_org_id :=
	all_del_det_bo_tbl(l_del_index).ship_from_org_id;
    l_shipping_attr(1).released_status :=
	all_del_det_bo_tbl(l_del_index).released_status;
    l_shipping_attr(1).delivery_detail_id :=
	all_del_det_bo_tbl(l_del_index).delivery_detail_id;
    l_shipping_attr(1).action_flag := 'B';
    l_shipping_attr(1).cycle_count_quantity :=
        all_del_det_bo_tbl(l_del_index).cycle_count_quantity;

    l_shipping_attr(1).subinventory :=
	all_del_det_bo_tbl(l_del_index).subinventory ;
    l_shipping_attr(1).locator_id :=all_del_det_bo_tbl(l_del_index).locator_id;

    if is_debug then
      print_debug('Backordering SMC','INV_PICK_RELEASE_PUB');
      print_debug('Delivery detail'|| l_shipping_attr(1).delivery_detail_id,
	'INV_PICK_RELEASE_PUB');
    end if;

    WSH_INTERFACE.Update_Shipping_Attributes
              (p_source_code               => 'INV',
               p_changed_attributes        => l_shipping_attr,
               x_return_status             => x_return_status
    );

    if( x_return_status = FND_API.G_RET_STS_ERROR ) then
		if is_debug then
                  print_debug('return error from update shipping attributes',
                              'Inv_Pick_Release_Pub.Pick_Release');
		end if;
                raise FND_API.G_EXC_ERROR;
    elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
		if is_debug then
                  print_debug('return error from update shipping attributes',
                              'Inv_Pick_Release_Pub.Pick_Release');
		end if;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    l_shipping_attr.DELETE;
    EXIT WHEN l_del_index =all_del_det_bo_tbl.LAST;
    l_del_index :=all_del_det_bo_tbl.NEXT(l_del_index);

  END LOOP;
END IF;
all_del_det_bo_tbl.DELETE;
x_return_status :=fnd_api.g_ret_sts_success;
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        --
        x_return_status := FND_API.G_RET_STS_ERROR;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);
        --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);
        --
     WHEN OTHERS THEN
        ROLLBACK TO Pick_Release_PUB;
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);
END;


--Sort
--  This procedure sorts the input lines so that lines with the same
-- header_id are contiguous. This sort used quick sort, but quick sort
-- doesn't preserve the order of the records within a header.  It's
-- necessary to preserve this order because of shipsets - lines belonging
-- to the same shipset must be consecutive in the table.  Because
-- these lines will usually be mostly in order already, we can use the
-- InsertionSort algorithm.

procedure sort( p_trolin_tbl IN OUT NOCOPY INV_Move_Order_PUB.TROLIN_TBL_TYPE,
		p_low_index	IN NUMBER,
		p_high_index	IN NUMBER) IS
   l_low_index 	NUMBER := p_low_index;
   l_high_index NUMBER := p_high_index;
   l_pivot_idx  NUMBER;
   l_prior_index NUMBER;
   l_trolin_rec INV_MOVE_ORDER_PUB.TROLIN_REC_TYPE;
   l_pivot_rec  INV_MOVE_ORDER_PUB.TROLIN_REC_TYPE;
   i NUMBER;
   j NUMBER;

BEGIN

   IF l_low_Index >= l_high_index THEN
      RETURN;
   END IF;
   -- for each record in table but the first
   i := p_trolin_tbl.NEXT(l_low_index);
   LOOP
       j := i;
       l_pivot_rec := p_trolin_tbl(i);
       -- table to left of current location (j) is already sorted.
       -- Copy current record (pivot rec) from table.
       -- Look at record to left (prior index).  If record to
       -- left has header greater than current record, move record to
       -- left one place to the right (the spot that used to be
       -- occupied by the currect record). Continue to move current
       -- record to the left until the prior record's header id is
       -- <= current record's header id.  At that point, save pivot
       -- rec into table at current location.
       While j > l_low_index  Loop
	  l_prior_index := p_trolin_tbl.PRIOR(j);
	  IF l_pivot_rec.header_id >= p_trolin_tbl(l_prior_index).header_id Then
	     EXIT;
	  END IF;
	  p_trolin_tbl(j) := p_trolin_tbl(l_prior_index);
	  j := l_prior_index;
       End Loop;
       p_trolin_tbl(j) := l_pivot_rec;
       EXIT WHEN p_trolin_tbl.LAST = i;
       i := p_trolin_tbl.NEXT(i);
   END LOOP;
END sort;

PROCEDURE test_sort( p_trolin_tbl IN OUT NOCOPY INV_MOVE_ORDER_PUB.Trolin_Tbl_Type) IS
BEGIN
    sort(p_trolin_tbl, p_trolin_tbl.FIRST, p_trolin_tbl.LAST);
END test_sort;

-- the following API is added for assign pick slip numbers after cartonize
-- for patchset J bulk picking
PROCEDURE assign_pick_slip_number(
                    x_return_status	    OUT   NOCOPY VARCHAR2,
		    x_msg_count       	    OUT   NOCOPY NUMBER,
		    x_msg_data        	    OUT   NOCOPY VARCHAR2,
		    p_move_order_header_id  IN    NUMBER   DEFAULT  0,
		    p_ps_mode               IN    VARCHAR2,
		    p_grouping_rule_id IN    NUMBER,
		    p_allow_partial_pick    IN    VARCHAR2) IS


l_pick_slip_mode           VARCHAR2(1); -- The print pick slip mode (immediate or deferred) that should be used
l_pick_slip_number         NUMBER; -- The pick slip number to put on the Move Order Line Details for a Line.
l_ready_to_print           VARCHAR2(1); -- The flag for whether we need to commit and print after receiving
-- the current pick slip number.
l_api_return_status        VARCHAR2(1); -- The return status of APIs called within the Process Line API.
l_api_error_code           NUMBER; -- The error code of APIs called within the Process Line API.
l_api_error_msg            VARCHAR2(100); -- The error message returned by certain APIs called within Process_Line
l_count                    NUMBER;
l_message                  VARCHAR2(255);
l_report_set_id            NUMBER;
l_request_number           VARCHAR2(80);
l_call_mode                VARCHAR2(1); --bug 1968032 will not commit if not null when called from SE.
l_grouping_rule_id         NUMBER;
l_get_header_rule         NUMBER; -- 1 (yes) if the grouping rule ID was
                                        -- not passed in and the headers have
                                        -- different grouping rules, or 2 (no)
                                        -- otherwise.
l_mso_header_id          NUMBER;
l_organization_id        NUMBER;
l_api_name		CONSTANT VARCHAR2(30) := 'ASSIGN_PICK_SLIP_NUMBER';
CURSOR l_mold_crs IS
  SELECT mmtt.transaction_temp_id
       , mmtt.subinventory_code
       , mmtt.locator_id
       , mmtt.transfer_to_location
       , mmtt.organization_id
       , wdd.oe_header_id
       , wdd.oe_line_id
       , wdd.customer_id
       , wdd.freight_code
       , wdd.ship_to_location
       , wdd.shipment_priority_code
       , wdd.trip_stop_id
       , wdd.shipping_delivery_id
       , mol.ship_set_id
       , mol.ship_model_id
       , mmtt.parent_line_id
       , mmtt.transfer_subinventory
       , mmtt.project_id
       , mmtt.task_id
       , mmtt.inventory_item_id
       , mmtt.revision
    FROM mtl_material_transactions_temp mmtt,mtl_txn_request_lines mol,wsh_inv_delivery_details_v wdd
   WHERE mmtt.move_order_line_id = mol.line_id
     AND mol.header_id = p_move_order_header_id
     AND wdd.move_order_line_id = mol.line_id
     AND mmtt.pick_slip_number IS NULL;

 -- the following cursor will be used when calling from concurrent program
 CURSOR l_mold_crs_con IS
   SELECT wct.transaction_temp_id
   FROM wms_cartonization_temp wct
   WHERE wct.parent_line_id = wct.transaction_temp_id;   -- only parent lines

 l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
  IF (l_debug = 1) THEN
	print_debug('get pick slip number for move order header '||p_move_order_header_id,
	            'Inv_Pick_Release_PVT.assign_pick_slip_number');
   print_debug('p_grouping_rule_id = '||p_grouping_rule_id,'Inv_Pick_Release_PVT.assign_pick_slip_number');
  END IF;
  SAVEPOINT assign_pick_slip;

  IF p_move_order_header_id = -1 THEN
      IF (l_debug = 1) THEN
      	print_debug('calling from concurrent program ',
      	            'Inv_Pick_Release_PVT.assign_pick_slip_number');
      END IF;
      For mmtt_line in l_mold_crs_con LOOP
          UPDATE mtl_material_transactions_temp
	  SET pick_slip_number = wsh_pick_slip_numbers_s.nextval
	  WHERE transaction_temp_id = mmtt_line.transaction_temp_id;
      END LOOP;
  ELSE

-- The Move Order Lines may need to have their grouping rule ID defaulted
-- from the header.  This is only necessary if the Grouping Rule ID was not
-- passed in as a parameter.
  IF p_grouping_rule_id <> FND_API.G_MISS_NUM THEN
  l_grouping_rule_id := p_grouping_rule_id;
  l_get_header_rule := 2;
  ELSE
  l_get_header_rule := 1;
  END IF;

  IF (l_debug = 1) THEN
 	     print_debug('l_get_header_rule = '||l_get_header_rule,'Inv_Pick_Release_PVT.assign_pick_slip_number');
  END IF;

  IF l_get_header_rule = 1 THEN
  BEGIN
  SELECT grouping_rule_id,organization_id
  INTO l_grouping_rule_id,l_organization_id
  FROM mtl_txn_request_headers
  WHERE header_id = p_move_order_header_id;
  EXCEPTION
  WHEN no_data_found THEN
    ROLLBACK TO Assign_Pick_slip;
    FND_MESSAGE.SET_NAME('INV','INV_NO_HEADER_FOUND');
    FND_MESSAGE.SET_TOKEN('MO_LINE_ID','');
    FND_MSG_PUB.Add;
    RAISE fnd_api.g_exc_unexpected_error;
  END;

  IF (l_debug = 1) THEN
 	     print_debug('l_grouping_rule_id = '||l_grouping_rule_id||',l_organization_id = '||l_organization_id,
 	                 'Inv_Pick_Release_PVT.assign_pick_slip_number');
  END IF;

-- If the header did not have a grouping rule ID, retrieve it from
-- the organization-level default.
  IF l_grouping_rule_id IS NULL THEN
  BEGIN
    SELECT pick_slip_rule_id
    INTO l_grouping_rule_id
    FROM wsh_parameters
    WHERE organization_id = l_organization_id;
    EXCEPTION
    WHEN no_data_found THEN
      ROLLBACK TO Assign_pick_slip;
      FND_MESSAGE.SET_NAME('INV','INV-NO ORG INFORMATION');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
  END;
  END IF; -- get header rule
  END IF; -- return status

  For mmtt_line in l_mold_crs LOOP

    IF mmtt_line.parent_line_id is not null THEN   -- parent line
    -- assign a seperate pick slip number for parent task and call WMS's pick slip
    -- report to print out
       UPDATE mtl_material_transactions_temp
	  SET pick_slip_number = wsh_pick_slip_numbers_s.nextval
	WHERE transaction_temp_id = mmtt_line.parent_line_id;
       IF ( p_ps_mode <> 'I' ) THEN
	   	    WSH_INV_INTEGRATION_GRP.FIND_PRINTER
	   	    ( p_subinventory    => mmtt_line.subinventory_code
	   	    , p_organization_id => mmtt_line.organization_id
	   	    , x_error_message   => l_api_error_msg
	   	    , x_api_Status      => l_api_return_status
	   	    ) ;

	   	    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
	   	      IF (l_debug = 1) THEN
	   		 print_debug('return error from WSH_INV_INTEGRATION.find_printer',
	   			  'Inv_Pick_Release_Pvt.Process_Line');
	   	      END IF;
	   	      RAISE fnd_api.g_exc_unexpected_error;
	   	    END IF;

       END IF ;
       IF p_ps_mode = 'I' and
       	  p_allow_partial_pick = fnd_api.g_true THEN
       	    COMMIT WORK;

       	    BEGIN

	      /*Added for Bug # 6144354 */
	      SELECT request_number
	      INTO l_request_number
	      FROM mtl_txn_request_headers
	      WHERE header_id = p_move_order_header_id;
	      --AND organization_id =  mmtt_line.organization_id; --bug 8829363

	      IF (l_debug = 1) THEN
		print_debug('organization_id '||mmtt_line.organization_id,'Inv_Pick_Release_PVT.assign_pick_slip_number');
              END IF;
              /*End of modifications for Bug # 6144354 */

       	      SELECT document_set_id
       		INTO l_report_set_id
       		FROM wsh_picking_batches
       	       WHERE NAME = l_request_number;
       	    EXCEPTION
       	      WHEN NO_DATA_FOUND THEN
       		x_return_status  := fnd_api.g_ret_sts_error;
       		RAISE fnd_api.g_exc_error;
       	    END;

       	    wsh_pr_pick_slip_number.print_pick_slip(
       	      p_pick_slip_number           => l_pick_slip_number
       	    , p_report_set_id              => l_report_set_id
       	    , p_organization_id            => mmtt_line.organization_id
       	    , x_api_status                 => l_api_return_status
       	    , x_error_message              => l_api_error_msg
       	    );   -- don't need to call WMS new pick slip report, call shipping's api and add new wms report to the
                 -- proper document set

       	    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
       	      ROLLBACK TO assign_pick_slip;
       	      fnd_message.set_name('INV', 'INV_PRINT_PICK_SLIP_FAILED');
       	      fnd_message.set_token('PICK_SLIP_NUM', TO_CHAR(l_pick_slip_number));
       	      fnd_msg_pub.ADD;
       	      RAISE fnd_api.g_exc_unexpected_error;
       	    END IF;
	  END IF;

    ELSE
	  l_call_mode  := NULL;
	  -- Bug 2666620: Inline branching to call either WSH or INV get_pick_slip_number
	  inv_pick_release_pvt.get_pick_slip_number(
	    p_ps_mode                    => p_ps_mode
	  , p_pick_grouping_rule_id      => l_grouping_rule_id
	  , p_org_id                     => mmtt_line.organization_id
	  , p_header_id                  => mmtt_line.oe_header_id
	  , p_customer_id                => mmtt_line.customer_id
	  , p_ship_method_code           => mmtt_line.freight_code
	  , p_ship_to_loc_id             => mmtt_line.ship_to_location
	  , p_shipment_priority          => mmtt_line.shipment_priority_code
	  , p_subinventory               => mmtt_line.subinventory_code
	  , p_trip_stop_id               => mmtt_line.trip_stop_id
	  , p_delivery_id                => mmtt_line.shipping_delivery_id
	  , x_pick_slip_number           => l_pick_slip_number
	  , x_ready_to_print             => l_ready_to_print
	  , x_api_status                 => l_api_return_status
	  , x_error_message              => l_api_error_msg
	  , x_call_mode                  => l_call_mode
	  , p_dest_subinv                => mmtt_line.transfer_subinventory
	  , p_dest_locator_id            => mmtt_line.transfer_to_location
	  , p_project_id                 => mmtt_line.project_id
	  , p_task_id                    => mmtt_line.task_id
	  , p_inventory_item_id          => mmtt_line.inventory_item_id
	  , p_locator_id                 => mmtt_line.locator_id
	  , p_revision                   => mmtt_line.revision
	  );
	  IF (l_debug = 1) THEN
	     print_debug('l_call_mode'|| l_call_mode, 'Inv_Pick_Release_PVT.Process_Line');
	  END IF;

	  IF l_api_return_status <> fnd_api.g_ret_sts_success
	     OR l_pick_slip_number = -1 THEN
	    ROLLBACK TO assign_pick_slip;
	    fnd_message.set_name('INV', 'INV_NO_PICK_SLIP_NUMBER');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_unexpected_error;
	  END IF;

	  IF ( p_ps_mode <> 'I' ) THEN
	    WSH_INV_INTEGRATION_GRP.FIND_PRINTER
	    ( p_subinventory    => mmtt_line.subinventory_code
	    , p_organization_id => mmtt_line.organization_id
	    , x_error_message   => l_api_error_msg
	    , x_api_Status      => l_api_return_status
	    ) ;

	    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
	      IF (l_debug = 1) THEN
		 print_debug('return error from WSH_INV_INTEGRATION.find_printer',
			  'Inv_Pick_Release_Pvt.Process_Line');
	      END IF;
	      RAISE fnd_api.g_exc_unexpected_error;
	    END IF;

	  END IF ;
          l_mso_header_id     := inv_salesorder.get_salesorder_for_oeheader(mmtt_line.oe_header_id);
	  -- Assign the pick slip number to the record in MTL_MATERIAL_TRANSACTIONS_TEMP
	  UPDATE mtl_material_transactions_temp
	     SET pick_slip_number = l_pick_slip_number
	       , transaction_source_id = l_mso_header_id
	       , trx_source_line_id = mmtt_line.oe_line_id
	       , demand_source_header_id = l_mso_header_id
	       , demand_source_line = mmtt_line.oe_line_id
	   WHERE transaction_temp_id = mmtt_line.transaction_temp_id;

	  -- If the pick slip is ready to be printed (and partial
	  -- picking is allowed) commit
	  -- and print at this point.
	  -- Bug 1663376 - Don't Commit if Ship_set_Id is not null,
	  --  since we need to be able to rollback
	  IF  l_ready_to_print = fnd_api.g_true
	      AND p_allow_partial_pick = fnd_api.g_true
	      AND mmtt_line.ship_set_id IS NULL
	      AND mmtt_line.ship_model_id IS NULL
	      AND l_call_mode IS NULL THEN
	    COMMIT WORK;

	    BEGIN
              SELECT request_number
	      INTO l_request_number
	      FROM mtl_txn_request_headers
	      WHERE header_id = p_move_order_header_id;
	      	--AND organization_id = l_organization_id; Bug 8829363

	      SELECT document_set_id
		INTO l_report_set_id
		FROM wsh_picking_batches
	       WHERE NAME = l_request_number;
	    EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		x_return_status  := fnd_api.g_ret_sts_error;
		RAISE fnd_api.g_exc_error;
	    END;

	    wsh_pr_pick_slip_number.print_pick_slip(
	      p_pick_slip_number           => l_pick_slip_number
	    , p_report_set_id              => l_report_set_id
	    , p_organization_id            => mmtt_line.organization_id
	    , x_api_status                 => l_api_return_status
	    , x_error_message              => l_api_error_msg
	    );

	    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
	      ROLLBACK TO process_line_pvt;
	      fnd_message.set_name('INV', 'INV_PRINT_PICK_SLIP_FAILED');
	      fnd_message.set_token('PICK_SLIP_NUM', TO_CHAR(l_pick_slip_number));
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
	  END IF;
      END IF;
  END LOOP;
  END IF; -- p_move_ordeR_header <> -1
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO   Assign_pick_slip;
     	--
     	x_return_status := FND_API.G_RET_STS_ERROR;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     	   , p_data => x_msg_data);
     	--
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO   Assign_pick_slip;
     	--
     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     	   , p_data => x_msg_data);
     	--
     WHEN OTHERS THEN
	ROLLBACK TO   Assign_pick_slip;
     	--
     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	--
     	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     	END IF;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     	   , p_data => x_msg_data);
END assign_pick_slip_number;


-- Bug# 4258360
-- Pick_Release API is overloaded for R12 changes related to the Planned Crossdocking project.
PROCEDURE Pick_Release
  (
   p_api_version		IN  	NUMBER
   ,p_init_msg_list	        IN  	VARCHAR2
   ,p_commit		        IN	VARCHAR2
   ,x_return_status             OUT 	NOCOPY VARCHAR2
   ,x_msg_count                 OUT 	NOCOPY NUMBER
   ,x_msg_data                  OUT 	NOCOPY VARCHAR2
   ,p_mo_line_tbl		IN  	INV_Move_Order_PUB.TROLIN_TBL_TYPE
   ,p_auto_pick_confirm	        IN  	NUMBER
   ,p_grouping_rule_id	        IN  	NUMBER
   ,p_allow_partial_pick	IN	VARCHAR2
   ,x_pick_release_status	OUT	NOCOPY INV_Release_Status_Tbl_Type
   ,p_plan_tasks                IN      BOOLEAN
   ,p_skip_cartonization        IN      BOOLEAN := FALSE
   ,p_mo_transact_date          IN      DATE
   )
  IS
   l_wsh_release_table          WSH_PR_CRITERIA.relRecTabTyp;
   l_trolin_delivery_ids        WSH_UTIL_CORE.Id_Tab_Type;
   l_del_detail_id              WSH_PICK_LIST.DelDetTabTyp;

BEGIN
   INV_Pick_Release_Pub.Pick_Release
     (
      p_api_version             => p_api_version
      ,p_init_msg_list	        => p_init_msg_list
      ,p_commit		        => p_commit
      ,x_return_status          => x_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data
      ,p_mo_line_tbl		=> p_mo_line_tbl
      ,p_auto_pick_confirm	=> p_auto_pick_confirm
      ,p_grouping_rule_id	=> p_grouping_rule_id
      ,p_allow_partial_pick	=> p_allow_partial_pick
      ,x_pick_release_status	=> x_pick_release_status
      ,p_plan_tasks             => p_plan_tasks
      ,p_skip_cartonization     => p_skip_cartonization
      ,p_wsh_release_table      => l_wsh_release_table
      ,p_trolin_delivery_ids    => l_trolin_delivery_ids
      ,p_del_detail_id          => l_del_detail_id
      ,p_mo_transact_date       => p_mo_transact_date
      ,p_dynamic_replenishment  => NULL  --Added R12.1 Replenishment Proj 6710368
      );
END Pick_Release;


-- Bug# 4258360
-- Pick_Release API is overloaded for R12 changes related to the Planned Crossdocking project.
-- Three new IN OUT parameters are added.
PROCEDURE Pick_Release
  (
   p_api_version		IN  	NUMBER
   ,p_init_msg_list	        IN  	VARCHAR2
   ,p_commit		        IN	VARCHAR2
   ,x_return_status             OUT 	NOCOPY VARCHAR2
   ,x_msg_count                 OUT 	NOCOPY NUMBER
   ,x_msg_data                  OUT 	NOCOPY VARCHAR2
   ,p_mo_line_tbl		IN  	INV_Move_Order_PUB.TROLIN_TBL_TYPE
   ,p_auto_pick_confirm	        IN  	NUMBER
   ,p_grouping_rule_id	        IN  	NUMBER
   ,p_allow_partial_pick	IN	VARCHAR2
   ,x_pick_release_status	OUT	NOCOPY INV_Release_Status_Tbl_Type
   ,p_plan_tasks                IN      BOOLEAN
   ,p_skip_cartonization        IN      BOOLEAN
   ,p_wsh_release_table         IN OUT  NOCOPY WSH_PR_CRITERIA.relRecTabTyp
   ,p_trolin_delivery_ids       IN OUT  NOCOPY WSH_UTIL_CORE.Id_Tab_Type
   ,p_del_detail_id             IN OUT  NOCOPY WSH_PICK_LIST.DelDetTabTyp
   ,p_mo_transact_date          IN      DATE
   ,p_dynamic_replenishment     IN      VARCHAR2  --Added R12.1 Replenishment Proj 6710368
   ) IS
      l_api_version		CONSTANT NUMBER := 1.0;
      l_api_name		CONSTANT VARCHAR2(30) := 'Pick_Release';

      l_mo_line_count		NUMBER;
					-- The number of move order lines to
                                	-- be pick released.
      l_line_index		NUMBER;
					-- The index of the line in the table
					-- being processed
      l_mo_line		        INV_Move_Order_PUB.TROLIN_REC_TYPE;
					-- Temporary record to hold information
					-- on the record being processed.
      l_organization_id	        NUMBER;
					-- The organization ID to use (based
					-- on the move order lines passed in).
      l_print_mode		VARCHAR2(1);
					-- The pick slip printing mode to use
					-- (I = immediate, E = deferred)
      l_mo_type			NUMBER;	-- The type of the move order (should
					-- be Pick Wave - 3)
      l_mo_number		VARCHAR2(30);
					-- The move order number
      l_grouping_rule_id	NUMBER;	-- The grouping rule ID to use (which
					-- may come from the parameter passed
					-- in or the default in the header).
      l_get_header_rule	        NUMBER;	-- 1 (yes) if the grouping rule ID was
					-- not passed in and the headers have
					-- different grouping rules, or 2 (no)
					-- otherwise.
      l_grouping_rules_differ	NUMBER;	-- Flag which tells whether the move
					-- order lines have differing grouping
					-- rule IDS in their headers.
      l_auto_pick_confirm	NUMBER;	-- Whether or not to call the pick
					-- confirm process automatically.
					-- This may come from the parameter
					-- passed in or the org-level
					-- parameter.
      l_api_return_status	VARCHAR2(1);
					-- The return status of APIs called
					-- within the Pick Release API.
      l_processed_row_count	NUMBER := 0;
					-- The number of rows which have been
					-- processed.
      l_detail_rec_count         NUMBER := 0;


   l_mo_line_tbl	        INV_Move_Order_Pub.Trolin_Tbl_Type := p_mo_line_tbl;
   l_shipping_attr              WSH_INTERFACE.ChangedAttributeTabType;
   l_smc_backorder_det_tbl      WSH_INTERFACE.ChangedAttributeTabType;
   l_shipset_smc_backorder_rec  WSH_INTEGRATION.BackorderRecType;
   l_action_flag VARCHAR2(1);
   l_quantity NUMBER;
   -- HW INVCONV Added Qty2 variables
   l_quantity2 NUMBER;
   l_transaction_quantity2 NUMBER;
   l_transaction_quantity NUMBER;
   l_delivery_detail_id NUMBER;
   l_source_header_id NUMBER;
   l_source_line_id NUMBER;
   l_released_status VARCHAR2(1);
   l_line_status Number;
   -- used for processing ship sets
   l_cur_ship_set_id NUMBER := NULL;
   l_set_index NUMBER;
   l_start_index NUMBER;
   l_set_process NUMBER;
   l_start_process NUMBER;
   -- used for processing ship model complete
   l_model_reloop BOOLEAN := FALSE;
   l_cur_ship_model_id NUMBER := NULL;
   l_cur_txn_source_line_id NUMBER;
   l_cur_txn_source_qty NUMBER;
   -- HW INVCONV -Added Qty2
   l_cur_txn_source_qty2 NUMBER;
   l_cur_txn_source_req_qty NUMBER;
   l_txn_source_line_uom VARCHAR2(3);
   l_new_model_quantity NUMBER;
   l_set_txn_source_line_id NUMBER := NULL;
   l_set_txn_source_req_qty NUMBER;
   l_set_txn_source_uom VARCHAR2(3);
   l_set_new_req_qty NUMBER;
   l_new_line_quantity NUMBER;
   l_tree_id NUMBER;
   l_revision_control_code NUMBER;
   l_lot_control_code NUMBER;
   l_revision_controlled BOOLEAN;
   l_lot_controlled BOOLEAN;
   l_req_msg  VARCHAR2(255);
   g_pjm_unit_eff_enabled VARCHAR2(1) :=NULL;
   l_demand_source_type      NUMBER;
   l_mso_header_id     NUMBER;
   l_oe_header_id      NUMBER;
   l_reservable_type NUMBER := NULL;

   l_last_rec NUMBER;
   l_item_index NUMBER;
   l_qtree_line_index NUMBER;
   l_wms_installed BOOLEAN;
   l_multiple_headers BOOLEAN := FALSE;
   l_first_header_id NUMBER := NULL;
   l_quantity_delivered NUMBER;
   -- HW INVCONV -Added Qty2
   l_quantity2_delivered NUMBER;
   l_backup_id NUMBER;
   l_current_header_id NUMBER := NULL;
   l_return_value BOOLEAN := TRUE;
   l_do_cartonization number := NVL(FND_PROFILE.VALUE('WMS_ASSIGN_TASK_TYPE'),1); --added for Bug3237702


TYPE quantity_tree_tbl_type is TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;


   --there will be one record in this table for every item in the MO batch.
   --if the item is unit effective,
   --    first line rec will hold the txn_source_line_id of first MO line
   --    for this item; last_line_rec will hold the txn_source_line_id of
   --    the last MO line for this item in the batch;
   --This table is indexed based on the item_id
   TYPE qtree_item_rec_type IS RECORD (
       tree_id        NUMBER
      ,unit_effective VARCHAR2(1)
      ,first_line_rec NUMBER
      ,last_line_rec  NUMBER
   );

   --if item is unit effective controlled, there will be one record
   -- in this table for each separate sales order line in this batch;
   --transaction type id and move order line id are needed to get the
   --  information on demand to build the correct quantity tree;
   --next_line_rec contains the txn_source_line_id of the next MO line
   --  for this item;
   --This table is indexed by txn_source_line_id
   TYPE qtree_line_rec_type IS RECORD (
       tree_id             NUMBER
      ,move_order_line_id  NUMBER
      ,transaction_type_id NUMBER
      ,next_line_rec       NUMBER
   );

   TYPE qtree_item_tbl_type IS TABLE OF qtree_item_rec_type
	INDEX BY BINARY_INTEGER;

   TYPE qtree_line_tbl_type IS TABLE OF qtree_line_rec_type
      INDEX BY BINARY_INTEGER;

   l_qtree_item_tbl qtree_item_tbl_type;
   l_qtree_line_tbl qtree_line_tbl_type;


   --This table is used to make sure that restore tree and backup tree
   -- never get called more than once for a given tree within a shipset.
   -- These two procedures can be a little slow, it's best to avoid calling
   --  more than necessary. This table will be indexed by tree_id;  if
   -- a record exists in this table for a given tree id, then the tree
   -- is currently backed up and has not been restored.
   -- This table is deleted at the beginning of each shipset/model.
   l_qtree_backup_tbl  quantity_tree_tbl_type;


   TYPE uom_tbl_type IS TABLE OF VARCHAR2(3)
        INDEX BY BINARY_INTEGER;

   l_primary_uom_tbl uom_tbl_type;

   l_debug NUMBER;

   -- Bug# 4258360: Index pointer table so we can navigate through p_wsh_release_table
   -- easily if needed based on the allocation mode for the pick release batch.
   -- This should only be used for allocation mode = N (Prioritize Inventory)
   TYPE wdd_index_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_wdd_index_tbl               wdd_index_tbl;

   -- Index used for adding crossdocked WDD lines into the input tables,
   -- p_trolin_delivery_ids and p_del_detail_id for allocation mode of X (Prioritize Crossdock).
   -- This is needed to enter the crossdocked WDD lines from p_wsh_release_table into the
   -- delivery tables so a delivery can be created for them if needed.
   -- This will also be used for other crossdock related changes.
   -- l_xdock_next_index is needed when removing backordered WDD lines from the
   -- delivery tables.
   l_xdock_index                 PLS_INTEGER;
   l_xdock_next_index            PLS_INTEGER;

   -- Table storing the delivery detail ID's for backordered lines.  These records
   -- should be removed from the input tables, p_trolin_delivery_ids and p_del_detail_id
   -- for allocation modes of I (Inventory Only) and X (Prioritize Crossdock).
   -- This is so deliveries are not autocreated for them later on by Shipping.
   -- UPDATE: This is not used anymore due to change in what Shipping passes for the
   -- delivery tables.
   TYPE backordered_wdd_tbl IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
   l_backordered_wdd_tbl         backordered_wdd_tbl;

   -- Variables used to call the Shipping API to update a WDD line during partial or zero
   -- allocation for allocation mode of N (Prioritize Inventory).  This will be used
   -- primarily to update the released_status and to null out the move_order_line_id.
   l_detail_info_tab             WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
   l_in_rec                      WSH_INTERFACE_EXT_GRP.detailInRecType;
   l_out_rec                     WSH_INTERFACE_EXT_GRP.detailOutRecType;

   -- Variables used to call the Shipping API to split a WDD line during partial
   -- allocation for allocation mode of N (Prioritize Inventory).
   l_detail_id_tab               WSH_UTIL_CORE.id_tab_type;
   l_action_prms                 WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
   l_action_out_rec              WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
   l_split_wdd_rel_rec           WSH_PR_CRITERIA.relRecTyp;
   l_split_delivery_detail_id    NUMBER;

   -- Variable storing the allocation method for the current picking batch
   l_allocation_method           VARCHAR2(1);

   -- Variable used to store the lower tolerance for the current move order line
   l_lower_tolerance		 NUMBER;

   -- Bug 4349602: save all MOL IDs in current batch
   TYPE l_molid_tbltyp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_mol_id_tbl                  l_molid_tbltyp;
   l_mol_id_index                NUMBER;
   l_atr_org            NUMBER; -- r12 replenishment project

    --Bug 6696594
    l_transaction_id	INV_LABEL.transaction_id_rec_type;
    l_counter		NUMBER := 1 ;
    honor_case_pick_count NUMBER := 0;
    honor_case_pick	VARCHAR2(1) := 'Y';
    l_label_status VARCHAR2(500);
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    v_transaction_id INV_LABEL.transaction_id_rec_type;

    Cursor c_mmtt(p_move_order_line_id NUMBER)
    IS SELECT transaction_temp_id
    FROM mtl_material_transactions_temp
    WHERE move_order_line_id = p_move_order_line_id;
    --Bug 6696594

BEGIN
   -- because the debug profile  rarely changes, only check it once per
   -- session, instead of once per batch
   IF is_debug IS NULL THEN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     if l_debug = 1 then
       is_debug := TRUE;
     else
       is_debug := FALSE;
     end if;
   END IF;

   -- Set savepoint for this API
   If is_debug then
    print_debug('Inside Pick_Release', 'INV_Pick_Release_Pub.Pick_Release');
    print_debug('p_dynamic_replenishment :'||p_dynamic_replenishment, 'INV_Pick_Release_Pub.Pick_Release');
   End If;

   l_return_value := inv_cache.set_pick_release(TRUE); --Added for bug3237702
   inv_log_util.g_maintain_log_profile := TRUE; -- Bug 5558315 - duplication so no dependency btw inv_cache and inv_log

   SAVEPOINT Pick_Release_PUB;

   -- Standard Call to check for call compatibility
   IF NOT fnd_api.Compatible_API_Call(l_api_version , p_api_version , l_api_name , G_PKG_NAME) THEN
     If is_debug then
      print_debug('Fnd_APi not compatible','INV_Pick_Release_Pub.Pick_Release');
     End If;
     RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to true
   IF fnd_api.to_Boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;


   -- Validate parameters

   -- First determine whether the table of move order lines in p_mo_line_tbl has
   -- any records
   l_mo_line_count := p_mo_line_tbl.COUNT;
   IF l_mo_line_count = 0 THEN
     If is_debug then
       print_debug('No Lines to pick', 'INV_Pick_Release_Pub.Pick_Release');
     End If;

      ROLLBACK TO Pick_Release_PUB;
      FND_MESSAGE.SET_NAME('INV','INV_NO_LINES_TO_PICK');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Set move order transaction date if passed in as not NULL
   IF p_mo_transact_date <> fnd_api.g_miss_date THEN
      inv_cache.mo_transaction_date := p_mo_transact_date;
   END IF;

   -- Validate that all move order lines are from the same org, that all lines
   -- have a status of pre-approved(7) or approved(3),and that all of the move
   -- order lines are of type Pick Wave (3)
   l_line_index := l_mo_line_tbl.FIRST;
   l_mol_id_index := 1;
   l_organization_id := l_mo_line_tbl(l_line_index).organization_id;
   LOOP
     l_mo_line := l_mo_line_tbl(l_line_index);

     --This clause checks to see if there are multiple headers in this
     -- table of move orders.  If there are, we need to sort these lines
     -- for cartonization  (see call to sort() below).
     if l_first_header_id IS NULL THEN
        l_first_header_id := l_mo_line.header_id;
     else
        IF l_first_header_id <> l_mo_line.header_id THEN
          l_multiple_headers := TRUE;
        END IF;
     end if;

     -- only process the valid move order, fix bug 1540709.
     IF (l_mo_line.return_status <> FND_API.G_RET_STS_UNEXP_ERROR and
         l_mo_line.return_status <> FND_API.G_RET_STS_ERROR) THEN

      -- Verify that the lines are all for the same organization
      IF l_mo_line.organization_id <> l_organization_id THEN
        If is_debug then
          print_debug('Error: Trying to pick for different org','INV_Pick_Release_Pub.Pick_Release');
        End If;

        ROLLBACK TO Pick_Release_PUB;
        FND_MESSAGE.SET_NAME('INV','INV_PICK_DIFFERENT_ORG');
        FND_MSG_PUB.Add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Verify that the line status is approved or pre-approved
      IF (l_mo_line.line_status <> 3 AND l_mo_line.line_status <> 7) THEN
        If is_debug then
          print_debug('Error: Invalid Move Order Line Status','INV_Pick_Release_Pub.Pick_Release');
        End If;

        ROLLBACK TO Pick_Release_PUB;
        FND_MESSAGE.SET_NAME('INV','INV_PICK_LINE_STATUS');
        FND_MSG_PUB.Add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF l_mo_line.header_id <> l_current_header_id OR
         l_current_header_id IS NULL THEN
         l_return_value := INV_CACHE.set_mtrh_rec(l_mo_line.header_Id);
         If NOT l_return_value Then
          If is_debug then
             print_debug('Error setting cache for move order header ','INV_Pick_Release_Pub.Pick_Release');
          End If;
          RAISE fnd_api.g_exc_unexpected_error;
         End If;
         l_mo_type := INV_CACHE.mtrh_rec.move_order_type;
         l_mo_number := INV_CACHE.mtrh_rec.request_number;
         l_current_header_id := l_mo_line.header_id;
      END IF;

      IF l_mo_type <> 3 THEN
        If is_debug then
          print_debug('Error: Trying to release non pick wave move order','INV_Pick_Release_Pub.Pick_Release');
        End If;

        ROLLBACK TO Pick_Release_PUB;
        FND_MESSAGE.SET_NAME('INV','INV_NON_PICK_WAVE_MO');
        FND_MESSAGE.SET_TOKEN('MO_NUMBER',l_mo_number);
        FND_MSG_PUB.Add;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      l_mol_id_tbl(l_mol_id_index) := l_mo_line.line_id;
      l_mol_id_index := l_mol_id_index + 1;
    END IF;

    IF NOT l_qtree_item_tbl.exists(l_mo_line.inventory_item_id) THEN
      --determine if item is unit-effective or not, and create
      --record in item_tbl

      If is_debug then
        print_debug('Storing rec in qtree_item_tbl', 'PICKREL');
      End If;
      --Bug2242924 For ship model Backorder was not happening correctly so
      -- create_tree for every line
      -- Bug 2363739 - call unit_effective_item instead of enabled
      --old: select pjm_unit_eff.enabled into g_pjm_unit_eff_enabled from dual;

      l_qtree_item_tbl(l_mo_line.inventory_item_id).unit_effective :=
        pjm_unit_eff.unit_effective_item(
          x_item_id => l_mo_line.inventory_item_id
         ,x_organization_id => l_organization_id);

      --if item is unit effective control, we have to build one tree for
      -- every sales order line.  Create record in line_tbl
      If l_qtree_item_tbl(l_mo_line.inventory_item_id).unit_effective =
         'Y' Then

        If is_debug then
          print_debug('Item is unit effective', 'PICKREL');
        End If;
        l_qtree_line_tbl(l_mo_line.txn_source_line_id).next_line_rec := 0;
        l_qtree_line_tbl(l_mo_line.txn_source_line_id).move_order_line_id :=
                l_mo_line.line_id;
        l_qtree_line_tbl(l_mo_line.txn_source_line_id).transaction_type_id :=
                l_mo_line.transaction_type_id;
        l_qtree_item_tbl(l_mo_line.inventory_item_id).first_line_rec :=
          l_mo_line.txn_source_line_id;
        l_qtree_item_tbl(l_mo_line.inventory_item_id).last_line_rec :=
          l_mo_line.txn_source_line_id;
      End If;

    --item entry already exists, but the item is effective control;
    --so, we have to create another entry in line tbl if one does not
    -- already exist for this sales order line
    ELSIF l_qtree_item_tbl(l_mo_line.inventory_item_id).unit_effective = 'Y'
      AND NOT l_qtree_line_tbl.exists(l_mo_line.txn_source_line_id) THEN

      If is_debug then
        print_debug('Item is unit effective. Inserting new line rec','PICKREL');
      End If;
      --make the next record the last one for this item
      l_last_rec:=l_qtree_item_tbl(l_mo_line.inventory_item_id).last_line_rec;
      l_qtree_line_tbl(l_last_rec).next_line_rec :=
                l_mo_line.txn_source_line_id;
      l_qtree_item_tbl(l_mo_line.inventory_item_id).last_line_rec :=
                l_mo_line.txn_source_line_id;

      --initialize values in new line record
      l_qtree_line_tbl(l_mo_line.txn_source_line_id).next_line_rec := 0;
      l_qtree_line_tbl(l_mo_line.txn_source_line_id).move_order_line_id :=
                l_mo_line.line_id;
      l_qtree_line_tbl(l_mo_line.txn_source_line_id).transaction_type_id :=
                l_mo_line.transaction_type_id;

    --IF item is not unit controlled and already exists in item_tbl,
    -- or if item is unit eff controlled and line already exists in line tbl,
    -- no need to do anything
    ELSE
      If is_debug then
        print_debug('Item/line recs already exist in table','PICKREL');
      End If;
    END IF;

    EXIT WHEN l_line_index = p_mo_line_tbl.LAST;
    l_line_index := p_mo_line_tbl.NEXT(l_line_index);
  END LOOP;

  l_item_index := l_qtree_item_tbl.FIRST;
  If is_debug then
    print_debug('Begin item loop.  First item id:' || l_item_index,
        'PICKREL');
  End If;

  LOOP
    EXIT WHEN l_item_index = 0;
    If is_debug then
      print_debug('Build quantity tree for item id:' || l_item_index,'PICKREL');
    End If;

    BEGIN
        SELECT revision_qty_control_code, lot_control_code,
               primary_uom_code, NVL(reservable_type,1)
          INTO l_revision_control_code, l_lot_control_code,
               l_primary_uom_tbl(l_item_index),
               l_reservable_type
          FROM mtl_system_items
         WHERE organization_id = l_organization_id
           AND inventory_item_id = l_item_index;
    EXCEPTION
       WHEN no_data_found THEN
           ROLLBACK TO Pick_Release_PUB;
           If is_debug then
              print_debug('No Item Info found','Inv_Pick_Release_Pub.Pick_Release');
           End If;
           RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF l_revision_control_code = 1 THEN
       l_revision_controlled := FALSE;
    ELSE
       l_revision_controlled := TRUE;
    END IF;

    IF l_lot_control_code = 1 THEN
      l_lot_controlled := FALSE;
    ELSE
      l_lot_controlled := TRUE;
    END IF;

    -- if not unit effective, build qty tree for item
    IF l_qtree_item_tbl(l_item_index).unit_effective = 'N' AND l_reservable_type = 1 THEN
         -- Because of the quantity tree rearchitechture, we
         -- can pass dummy values for demand source info.
         -- Bug 1890424 - Pass sysdate to create_tree so
         -- expired lots don't appear as available

          inv_quantity_tree_pvt.create_tree
          (
            p_api_version_number        => 1.0
           ,p_init_msg_lst              => fnd_api.g_false
           ,x_return_status             => l_api_return_status
           ,x_msg_count                 => x_msg_count
           ,x_msg_data                  => x_msg_data
           ,p_organization_id           => l_organization_id
           ,p_inventory_item_id         => l_item_index
           ,p_tree_mode                 => inv_quantity_tree_pvt.g_transaction_mode
           ,p_is_revision_control       => l_revision_controlled
           ,p_is_lot_control            => l_lot_controlled
           ,p_is_serial_control         => FALSE
           ,p_asset_sub_only            => FALSE
           ,p_include_suggestion        => FALSE
           ,p_demand_source_type_id     => -99
           ,p_demand_source_header_id   => -99
           ,p_demand_source_line_id     => -99
           ,p_demand_source_delivery    => NULL
           ,p_demand_source_name        => NULL
           ,p_lot_expiration_date       => SYSDATE
           ,x_tree_id                   => l_tree_id
           ,p_exclusive              => inv_quantity_tree_pvt.g_exclusive
           ,p_pick_release           => inv_quantity_tree_pvt.g_pick_release_yes
         );

         If is_debug then
            print_debug('Tree id from Normal Create tree'||l_tree_id,'Inv_Pick_Release_PVT.Process_Line');
         End If;

         l_qtree_item_tbl(l_item_index).tree_id := l_tree_id;

         IF l_api_return_status = fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error ;
         ELSIF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;

    --Bug 2500570.If unable to get delivery detail we should not
    --error for batch.
    ELSIF l_qtree_item_tbl(l_item_index).unit_effective = 'Y' AND
          l_reservable_type = 1 THEN
      --loop through all lines
      l_qtree_line_index := l_qtree_item_tbl(l_item_index).first_line_rec;
      Loop
        EXIT WHEN l_qtree_line_index = 0;
        --get demand information
        BEGIN
         SELECT SOURCE_HEADER_ID
           INTO l_OE_HEADER_ID
           FROM wsh_delivery_details
          WHERE move_order_line_id =
                l_qtree_line_tbl(l_qtree_line_index).move_order_line_id
            AND   move_order_line_id is not NULL
            AND released_status = 'S';
        EXCEPTION
          WHEN others THEN
            l_OE_HEADER_ID :=-9999;
            If is_debug then
              print_debug('No data found-Delivery Info',
                    'Inv_Pick_Release_PUB.Pick_release');
            End If;
            --ROLLBACK TO Pick_Release_PUB;
            --FND_MESSAGE.SET_NAME('INV','INV_DELIV_INFO_MISSING');
            -- FND_MSG_PUB.Add;
            -- RAISE fnd_api.g_exc_unexpected_error;
        END;

        l_return_value := INV_CACHE.set_mso_rec(l_oe_header_id);
        IF NOT l_return_value THEN
           l_mso_header_id :=-9999;
           If is_debug then
              print_debug('No Mtl_Sales_Order ID found for oe header','Inv_Pick_Release_PUB.Process_Line');
           End If;
        ELSE
           l_mso_header_id := INV_CACHE.mso_rec.sales_order_id;
        END IF;

        BEGIN
          select t.transaction_source_type_id
            into l_demand_source_type
            from mtl_transaction_types t, mtl_txn_source_types st
           where t.transaction_type_id =
                  l_qtree_line_tbl(l_qtree_line_index).transaction_type_id
             and t.transaction_source_type_id = st.transaction_source_type_id;
        exception
          when others then
            l_demand_source_type :=-9999;
            If is_debug then
              print_debug('No data found-Transaction types','Inv_Pick_Release_PVT.Process_Line');
            End If;
        END;

        inv_quantity_tree_pvt.create_tree
         (
            p_api_version_number        => 1.0
           ,p_init_msg_lst              => fnd_api.g_false
           ,x_return_status             => l_api_return_status
           ,x_msg_count                 => x_msg_count
           ,x_msg_data                  => x_msg_data
           ,p_organization_id           => l_organization_id
           ,p_inventory_item_id         => l_item_index
           ,p_tree_mode                 => inv_quantity_tree_pvt.g_reservation_mode
           ,p_is_revision_control       => l_revision_controlled
           ,p_is_lot_control            => l_lot_controlled
           ,p_is_serial_control         => FALSE
           ,p_asset_sub_only            => FALSE
           ,p_include_suggestion        => FALSE
           ,p_demand_source_type_id     => l_demand_source_type
           ,p_demand_source_header_id   => l_mso_header_id
           ,p_demand_source_line_id     => l_qtree_line_index
           ,p_demand_source_delivery    => NULL
           ,p_demand_source_name        => NULL
           ,p_lot_expiration_date       => SYSDATE
           ,x_tree_id                   => l_tree_id
           ,p_exclusive                 => inv_quantity_tree_pvt.g_exclusive
           ,p_pick_release          => inv_quantity_tree_pvt.g_pick_release_yes
         );
         If is_debug then
           print_debug('Tree id from PJM Create tree'||l_tree_id,'Inv_Pick_Release_PVT.Process_Line');
         End If;

         l_qtree_line_tbl(l_qtree_line_index).tree_id := l_tree_id;

         IF l_api_return_status = fnd_api.g_ret_sts_error THEN
           If is_debug then
             print_debug('Error from Create tree','Inv_pick_release_pub.Pick_release');
           End If;
           RAISE fnd_api.g_exc_error ;
         ELSIF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
           If is_debug then
             print_debug('Unexpected error from Create tree','Inv_pick_release_pub.Pick_release');
           End If;
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         l_qtree_line_index :=
             l_qtree_line_tbl(l_qtree_line_index).next_line_rec;
       End Loop; --End of loop through order lines

     END IF; -- unit effective

     EXIT WHEN l_item_index = l_qtree_item_tbl.LAST;
     l_item_index := l_qtree_item_tbl.NEXT(l_item_index);
   END LOOP;

   -- now sort the move order line by the header_id
   --BENCHMARK - check cache
   --l_wms_installed := inv_install.adv_inv_installed(
   --            l_mo_line_tbl(l_line_index).organization_id);
   l_return_value := INV_CACHE.set_wms_installed(l_organization_id);
   If NOT l_return_value Then
      If is_debug then
          print_debug('Error setting cache for wms installed','INV_Pick_Release_Pub.Pick_Release');
      End If;
      RAISE fnd_api.g_exc_unexpected_error;
   End If;
   l_wms_installed := INV_CACHE.wms_installed;
   --sort only necessary if wms installed and multiple headers in the
   --    line_tbl
   IF l_wms_installed and l_multiple_headers THEN
      sort(l_mo_line_tbl, l_mo_line_tbl.FIRST, l_mo_line_tbl.LAST);
   END IF;

   -- Determine whether or not to automatically pick confirm
   IF p_auto_pick_confirm IS NOT NULL THEN
      IF (p_auto_pick_confirm <> 1 AND p_auto_pick_confirm <> 2) THEN
        If is_debug then
         print_debug('Error: Invalid auto_pick_confirm flag','INV_Pick_Release_Pub.Pick_Release');
        End If;
        ROLLBACK TO Pick_Release_PUB;
        FND_MESSAGE.SET_NAME('INV','INV_AUTO_PICK_CONFIRM_PARAM');
        FND_MSG_PUB.Add;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSE
        l_auto_pick_confirm := p_auto_pick_confirm;
      END IF;
   ELSE
      -- Retrieve the org-level parameter for auto-pick confirm
      l_return_value := INV_CACHE.set_org_rec(l_organization_id);
      If NOT l_return_value Then
          If is_debug then
             print_debug('Error setting cache for organization',
                      'INV_Pick_Release_Pub.Pick_Release');
          End If;
	  RAISE fnd_api.g_exc_unexpected_error;
      End If;
      l_auto_pick_confirm:= INV_CACHE.org_rec.mo_pick_confirm_required;
   END IF;

   -- Determine what printing mode to use when pick releasing lines.
   IF g_organization_id IS NOT NULL AND
      g_organization_id = l_organization_id AND
      g_print_mode IS NOT NULL THEN

     l_print_mode := g_print_mode;
   ELSE

    BEGIN
      SELECT print_pick_slip_mode, pick_grouping_rule_id
      INTO l_print_mode, g_org_grouping_rule_id
      FROM WSH_SHIPPING_PARAMETERS
      WHERE organization_id = l_organization_id;
    EXCEPTION
      WHEN no_data_found THEN
        If is_debug then
          print_debug('Error: print_pick_slip_mode not defined','INV_Pick_Release_Pub.Pick_Release');
        End If;
        ROLLBACK TO Pick_Release_PUB;
        FND_MESSAGE.SET_NAME('INV','INV_WSH_ORG_NOT_FOUND');
        FND_MSG_PUB.Add;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

     g_organization_id := l_organization_id;
     g_print_mode := l_print_mode;
   END IF;

   -- Validate parameter for allowing partial pick release
   IF p_allow_partial_pick <> fnd_api.g_true AND
      p_allow_partial_pick <> fnd_api.g_false THEN

      If is_debug then
        print_debug('Error: invalid partial pick parameter','INV_Pick_Release_Pub.Pick_Release');
      End If;
      ROLLBACK TO Pick_Release_PUB;
      FND_MESSAGE.SET_NAME('INV','INV_INVALID_PARTIAL_PICK_PARAM');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   If is_debug then
     print_debug('p_allow_partial_pick is ' || p_allow_partial_pick,'Inv_Pick_Release_Pub.Pick_Release');
   End If;

   -- The Move Order Lines may need to have their grouping rule ID defaulted
   -- from the header.  This is only necessary if the Grouping Rule ID was not
   -- passed in as a parameter.
   IF p_grouping_rule_id IS NOT NULL AND p_grouping_rule_id <> fnd_api.G_MISS_NUM THEN
      l_grouping_rule_id := p_grouping_rule_id;
      l_get_header_rule := 2;
   ELSE
      l_get_header_rule := 1;
   END IF;

   -- Bug# 4258360: Query for and cache the picking batch record.
   -- Even if multiple move order headers are created for this batch (not likely),
   -- they should all refer to the same picking batch record.  A value for the move
   -- order header record should be cached by now in INV_CACHE.  'Batch' refers to
   -- the set of MOL's passed into the pick release API and not the entire set of pick
   -- release lines.
   -- {{
   -- Pick Release a batch such that you have orders from multiple
   -- organizations. This will cause multiple MOH to be created.
   -- If successfully pick released, then no bug.
   -- }}
   IF (NOT INV_CACHE.set_wpb_rec
       (p_batch_id       => NULL,
        p_request_number => INV_CACHE.mtrh_rec.request_number)) THEN
      IF (is_debug) THEN
         print_debug('Error setting cache for WSH picking batch record','INV_Pick_Release_Pub.Pick_Release');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   -- Set the allocation method variable
   l_allocation_method := NVL(INV_CACHE.wpb_rec.allocation_method, g_inventory_only);

   -- Bug# 4258360: Validate that p_trolin_delivery_ids and p_del_detail_id tables have the
   -- same number of entries.  There should be a one to one relationship between the tables
   -- and the indices used.  If NULL tables are passed, the counts should still match (0 = 0).
   -- NULL empty tables should be passed by Shipping for this.  These tables are used to store
   -- crossdocked WDD lines so deliveries can be created for them.
   IF (p_del_detail_id.COUNT <> p_trolin_delivery_ids.COUNT) THEN
      IF (is_debug) THEN
         print_debug('Mismatch in size of input tables from Shipping for delivery creation','INV_Pick_Release_Pub.Pick_Release');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Bug# 4258360: Loop through p_wsh_release_table to build the index pointer table to it.
   -- Do this only if p_wsh_release_table has entries in it.  Crossdocking will be called after
   -- Inventory allocation has completed.  Since it makes use of the release table, we need to keep
   -- that updated and in sync.  We also want to update any backordered lines in the release table
   -- so Shipping can know which lines were backordered and not auto-create deliveries for them.
   -- UPDATE: Do not need to insert lines into the delivery tables for Prioritize Crossdock.
   -- Since Shipping is not populating the delivery tables inputted, they will just be used to store
   -- the crossdocked WDD lines.  The crossdock pegging API will now insert the crossdocked WDD lines
   -- into these delivery tables.
   -- {{
   -- Run PR in Prioritize Inventory mode. Ensure that some rows get
   -- allocated from INV and some get x-docked. The ones that got
   -- allocated from INV should not get x-docked.
   -- }}
   -- {{
   -- Run PR in Prioritize x-dock mode. Ensure that no deliveries are
   -- created prior to running PR. Also ensure some WDDs get x-docked
   -- and some get allocated from INV. All these WDDs should have deliveries
   -- created at the end of PR run.
   -- }}
   IF (p_wsh_release_table.COUNT > 0) THEN
      l_line_index := p_wsh_release_table.FIRST;
      l_wdd_index_tbl.DELETE;
      IF (is_debug) THEN
	 print_debug('Build the WDD index pointer table (Prioritize Inventory)',
		     'Inv_Pick_Release_Pub.Pick_Release');
      END IF;
      LOOP
	 -- Store this WDD record into the WDD index pointer table
	 l_wdd_index_tbl(p_wsh_release_table(l_line_index).delivery_detail_id) := l_line_index;

	 EXIT WHEN l_line_index = p_wsh_release_table.LAST;
	 l_line_index := p_wsh_release_table.NEXT(l_line_index);
      END LOOP;
   END IF;

   -- Validation and initialization complete.  Begin pick release processing row-by-row.
   l_line_index := l_mo_line_tbl.FIRST;
   l_organization_id := l_mo_line.organization_id;
   LOOP
    l_mo_line := l_mo_line_tbl(l_line_index);
      -- only process the valid move order, fix bug 1540709.
    IF (l_mo_line.return_status <> FND_API.G_RET_STS_UNEXP_ERROR and
          l_mo_line.return_status <> FND_API.G_RET_STS_ERROR) THEN
      -- First retrieve the new Grouping Rule ID if necessary.
      IF l_get_header_rule = 1 THEN
	l_return_value := INV_CACHE.set_mtrh_rec(l_mo_line.header_id);
	If NOT l_return_value Then
          If is_debug then
             print_debug('Error setting cache for move order header ',
                      'INV_Pick_Release_Pub.Pick_Release');
          End If;
	  RAISE fnd_api.g_exc_unexpected_error;
	End If;
	l_grouping_rule_id := INV_CACHE.mtrh_rec.grouping_rule_id;

	-- If the header did not have a grouping rule ID, retrieve it from
	-- the organization-level default.
	IF l_grouping_rule_id IS NULL THEN
	  If g_organization_id IS NOT NULL And
             g_organization_id = l_organization_id And
	     g_org_grouping_rule_id IS NOT NULL Then

	    l_grouping_rule_id := g_org_grouping_rule_id;

	  Else
	    BEGIN
	      SELECT pick_grouping_rule_id
	      INTO l_grouping_rule_id
	      FROM wsh_shipping_parameters
	      WHERE organization_id = l_organization_id;
      	    EXCEPTION
	      WHEN no_data_found THEN
	        If is_debug then
		  print_debug('Error finding org grouping rules',
			 'INV_Pick_Release_Pub.Pick_Release');
		End If;
	        ROLLBACK TO Pick_Release_PUB;
      	        FND_MESSAGE.SET_NAME('INV','INV-NO ORG INFORMATION');
	        FND_MSG_PUB.Add;
	        RAISE fnd_api.g_exc_unexpected_error;
	    END;

	    If g_organization_id IS NULL Or
 	       g_organization_id <> l_organization_id Then
	      g_organization_id := l_organization_id;
	      -- null out other org based global variables
	      g_print_mode := NULL;
	    End If;

 	    g_org_grouping_rule_id := l_grouping_rule_id;
	  End If;

	END IF; -- get header rule
      END IF; -- return status


      IF l_mo_line.ship_set_id IS NOT NULL AND
	  (l_cur_ship_set_id IS NULL OR
	   l_cur_ship_set_id <> l_mo_line.ship_set_id) THEN

         SAVEPOINT SHIPSET;
	 l_cur_ship_set_id := l_mo_line.ship_set_id;
	 l_start_index := l_line_index;
         l_start_process := l_processed_row_count;
         l_qtree_backup_tbl.DELETE;
         If is_debug then
	   print_debug('Start Shipset :' || l_cur_ship_set_id,
	              'Inv_Pick_Release_Pub.Pick_Release');
	 End If;
      ELSIF l_cur_ship_set_id IS NOT NULL AND
	    l_mo_line.ship_set_id IS NULL THEN
        If is_debug then
	  print_debug('End of Shipset :' || l_cur_ship_set_id,
	              'Inv_Pick_Release_Pub.Pick_Release');
	End If;
	 l_cur_ship_set_id := NULL;
         l_qtree_backup_tbl.DELETE;
      END IF;
      --2509322
      IF  l_cur_ship_model_id IS NOT NULL AND
          l_mo_line.ship_model_id IS NULL OR
          l_mo_line.ship_model_id <>l_cur_ship_model_id then
           Backorder_SMC_DETAILS(l_api_return_status ,
                                x_msg_data ,
                                x_msg_count ) ;
         IF l_api_return_status = fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error ;
         ELSIF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF l_mo_line.ship_model_id IS NOT NULL AND
	  (l_cur_ship_model_id IS NULL OR
	   l_cur_ship_model_id <> l_mo_line.ship_model_id) THEN

         SAVEPOINT SHIPMODEL;
	 l_cur_ship_model_id := l_mo_line.ship_model_id;
	 l_start_index := l_line_index;
         l_start_process := l_processed_row_count;
         l_qtree_backup_tbl.DELETE;
         If is_debug then
	   print_debug('Start Ship Model :' || l_cur_ship_model_id,
	              'Inv_Pick_Release_Pub.Pick_Release');
         End If;
      ELSIF l_cur_ship_model_id IS NOT NULL AND
	    l_mo_line.ship_model_id IS NULL THEN
         If is_debug then
	   print_debug('End of Ship Model :' || l_cur_ship_model_id,
	              'Inv_Pick_Release_Pub.Pick_Release');
         End If;
	 l_cur_ship_model_id := NULL;
         l_qtree_backup_tbl.DELETE;
      END IF;

      IF (l_mo_line.ship_set_id IS NOT NULL OR
	  l_mo_line.ship_model_id IS NOT NULL)     THEN

        --find tree id.  If item is unit effective, get tree id from
        -- qtree_line_tbl.  Else, get it from qtree_item_tbl.
        If l_qtree_item_tbl(l_mo_line.inventory_item_id).unit_effective='Y'
         Then
          l_tree_id := l_qtree_line_tbl(l_mo_line.txn_source_line_id).tree_id;
        Else
          l_tree_id := l_qtree_item_tbl(l_mo_line.inventory_item_id).tree_id;
        End If;

        --only backup the tree if it is not already backed up
        If Not l_qtree_backup_tbl.Exists(l_tree_id) Then
          If is_debug then
            print_debug('Backing up qty tree: ' || l_tree_id,
                        'Inv_Pick_Release_Pub.Pick_Release');
          End If;
          --Bug 2814919
          if l_tree_id is not null then
            inv_quantity_tree_pvt.backup_tree(
              x_return_status   => l_api_return_status
             ,p_tree_id         => l_tree_id
	     ,x_backup_id	=> l_backup_id
	    );

           IF l_api_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error ;
           ELSIF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
             RAISE fnd_api.g_exc_unexpected_error;
           END IF;
	  End If;

          --Bug 2814919
	  if l_tree_id is not null then
            l_qtree_backup_tbl(l_tree_id) := l_backup_id;
	  End if;

        End If;

      END IF; -- shipset/ship model NOT NULL

      -- Need to keep track of the quantity allocated so far for this
      --  sales order - there can be multiple move orders per
      -- sales order line, and when dealing with ship model complete,
      -- the quantity requested and quantity allocated for the
      -- sales order line is important
      IF l_cur_txn_source_line_id IS NULL OR
         l_mo_line.txn_source_line_id <> l_cur_txn_source_line_id THEN

         l_cur_txn_source_line_id := l_mo_line.txn_source_line_id;
         l_cur_txn_source_qty := 0;
         -- HW INVCONV Added Qty2
         l_cur_txn_source_qty2 := 0;
         If is_debug then
            print_debug('Set Current Txn Src Line:' || l_cur_txn_source_line_id,'Inv_Pick_Release_Pub.Pick_Release');
         End If;
      END IF;

      g_pick_expired_lots := FALSE;
      g_pick_expired_lots := USER_PKG_LOT.use_expired_lots (
                             p_organization_id            => l_mo_line.organization_id
                           , p_inventory_item_id          => l_mo_line.inventory_item_id
                           , p_demand_source_type_id      => l_mo_line.transaction_source_type_id
                           , p_demand_source_line_id      => l_mo_line.txn_source_line_id
                             );

      -- Call the Pick Release Process_Line API on the current Move Order Line
      If is_debug then
        print_debug('calling INV_Pick_Release_PVT.process_line',
        'Inv_Pick_Release_Pub.Pick_Release');
      End If;

      INV_Pick_Release_PVT.Process_Line(
       p_api_version	=> 1.0
      ,p_init_msg_list	=> fnd_api.g_false
      ,p_commit		=> fnd_api.g_false
      ,x_return_status     => l_api_return_status
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,p_mo_line_rec       => l_mo_line
      ,p_grouping_rule_id	=> l_grouping_rule_id
      ,p_allow_partial_pick => p_allow_partial_pick
      ,p_print_mode        => l_print_mode
      ,x_detail_rec_count	=> l_detail_rec_count
           ,p_plan_tasks        => p_plan_tasks
      );

      If is_debug then
        print_debug('l_return_status from process_line is '|| l_api_return_status, 'Inv_Pick_Release_Pub.Pick_Release');
      End If;

      IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
         -- Return error if Process_Line returns error and
         -- allow_partial_pick is false, since we can't pick full quantity
         IF p_allow_partial_pick = fnd_api.g_false THEN
           x_pick_release_status.delete;
           ROLLBACK TO Pick_Release_PUB;
                FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_PICK_FULL');
           FND_MSG_PUB.Add;
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      l_quantity := l_mo_line.quantity;
      -- HW INVCONV Added Qty2
      l_quantity2 := l_mo_line.secondary_quantity;
      l_line_status := l_mo_line.line_status;
      l_quantity_delivered := l_mo_line.quantity_delivered;
      l_quantity2_delivered := l_mo_line.secondary_quantity_delivered;

      -- For non reservable items this status is set to 5 in
      -- process_line API and the below processing should not be done

      IF l_line_status <> 5 THEN
	 --BENCHMARK - can we use quantity detailed, or perhaps
	 --quantity detailed - quantity delivered

	 --select nvl(sum(transaction_quantity),0)
	 --into l_transaction_quantity
	 --from mtl_material_transactions_Temp
	 --where move_order_line_id = l_mo_line.line_id;

	 l_transaction_quantity := nvl(l_mo_line.quantity_detailed,0) -
	                           nvl(l_mo_line.quantity_delivered,0);
	 l_cur_txn_source_qty := nvl(l_cur_txn_source_qty,0) + nvl(l_transaction_quantity,0);

	 -- HW INVCONV Added Qty2
	 l_transaction_quantity2 := nvl(l_mo_line.secondary_quantity_detailed,0) -
	                            nvl(l_mo_line.secondary_quantity_delivered,0);
	 l_cur_txn_source_qty2 := nvl(l_cur_txn_source_qty2,0) + nvl(l_transaction_quantity2,0);

	 -- If the total allocated quantity is less than the requested
	 -- quantity, call shipping to backorder the missing quantity.
	 -- Update the move order line to change the requested quantity
	 -- to be equal to the allocated quantity

         -- Get the tolerance set while allocating the line
         -- If quantity is within tolerance then do not backorder shipset
         --
         -- l_lower_tolerance := l_quantity * inv_pick_release_pvt.g_min_tolerance;
         -- Bug 5188796: g_min_tolerance is a qty, not a %, so use as is
         l_lower_tolerance := inv_pick_release_pvt.g_min_tolerance;

	 -- Bug #2748751
	 -- If move order is partially transacted and the allocations are split
	 -- again, the allocated quantity will be lesser than move order quantity
	 -- In that case, we need to compare the allocated quantity against the
	 -- difference of move order requested quantity and delivered quantity
	 IF (l_transaction_quantity < (l_quantity - NVL(l_quantity_delivered,0) - l_lower_tolerance)) THEN

	    -- For shipsets, if any of the lines fail to allocate completely,
	    -- rollback all allocations and then back order all of the
	    -- move order lines for that ship set.
	    IF l_cur_ship_set_id IS NOT NULL THEN

	       -- Bug 2461353, 2411016
	       -- Call Shipping and let them know for a ship set we were not able
	       -- to detail complete so back ordering started.

	       BEGIN
		  If is_debug then
		     print_debug('Update shipping that ship set detailing failed',
				 'Inv_Pick_Release_Pub.Pick_Release');
		  End If;

		  l_shipset_smc_backorder_rec.move_order_line_id:=l_mo_line.line_id;
		  l_shipset_smc_backorder_rec.ship_set_id :=l_cur_ship_set_id;


		  wsh_integration.ins_backorder_ss_smc_rec
		    (p_api_version_number => 1.0,
		     p_source_code        => 'INV',
		     p_init_msg_list      => fnd_api.g_false,
		     p_backorder_rec      => l_shipset_smc_backorder_rec,
		     x_return_status      => l_api_return_status,
		     x_msg_count          => x_msg_count,
		     x_msg_data           => x_msg_data);

		  IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
		     If is_debug then
			print_debug('Error occured while updating shipping for ' ||
				    'failed ship set','Inv_Pick_Release_Pub.Pick_Release');
			print_debug('l_return_status' || l_api_return_status,
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		  END IF;

	       EXCEPTION
		  WHEN OTHERS THEN
		     If is_debug then
			print_debug('When other exception: ' || Sqlerrm,
				    'Inv_Pick_Release_Pub.Pick_Release');
			print_debug('l_return_status' || l_api_return_status,
			'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		     NULL;
		     --no need to error out for reporting purpose.
	       END;

	       If is_debug then
		  print_debug('Rollback for shipset :' || l_cur_ship_set_id,
			      'Inv_Pick_Release_Pub.Pick_Release');
	       End If;

	       ROLLBACK to SHIPSET;
	       l_set_index := l_start_index;
	       l_set_process := l_start_process;

	       --loop through all move order lines for this ship set
	       LOOP
		  l_mo_line := l_mo_line_tbl(l_set_index);

		  --find tree id.  If item is unit effective, get tree id from
		  -- qtree_line_tbl.  Else, get it from qtree_item_tbl.
		  IF l_qtree_item_tbl(l_mo_line.inventory_item_id).unit_effective='Y'
		    THEN
		     l_tree_id :=
		       l_qtree_line_tbl(l_mo_line.txn_source_line_id).tree_id;
		   ELSE
		     l_tree_id :=
		       l_qtree_item_tbl(l_mo_line.inventory_item_id).tree_id;
		  END IF;

		  -- only restore tree if it is currently in backup table.
		  -- Tree would not be in backup table if current move order line
		  -- was not allocated or if the tree had already been restored
		  -- for a previous move order line.
		  IF l_qtree_backup_tbl.EXISTS(l_tree_id) THEN

		     If is_debug then
			print_debug('Restoring Quantity Tree: ' || l_tree_id,
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;

		     inv_quantity_tree_pvt.restore_tree
		       (x_return_status  => l_api_return_status
			,p_tree_id       => l_tree_id
			,p_backup_id     => l_qtree_backup_tbl(l_tree_id)
			);

		     if( l_api_return_status = FND_API.G_RET_STS_ERROR ) then
			If is_debug then
			   print_debug('Error in Restore_Tree',
				       'Inv_Pick_Release_Pub.Pick_Release');
			End If;
			raise FND_API.G_EXC_ERROR;
		      elsif l_api_return_status=FND_API.G_RET_STS_UNEXP_ERROR then
			If is_debug then
			   print_debug('Unexpected error in Restore_tree',
				       'Inv_Pick_Release_Pub.Pick_Release');
			End If;
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		     end if;

		     --delete entry, so we don't restore tree more than once
		     l_qtree_backup_tbl.DELETE(l_tree_id);

		  END IF;

		  If is_debug then
		     print_debug('Backorder mo line:' || l_mo_line.line_id,
				 'Inv_Pick_Release_Pub.Pick_Release');
		  End If;

		  l_return_value := INV_CACHE.set_wdd_rec(l_mo_line.line_id);
		  If NOT l_return_value Then
		     If is_debug then
			print_debug('Error setting cache for delivery line',
				    'INV_Pick_Release_Pub.Pick_Release');
		     End If;
		     RAISE fnd_api.g_exc_unexpected_error;
		  End If;
		  l_delivery_detail_id := INV_CACHE.wdd_rec.delivery_detail_id;
		  l_source_header_id := INV_CACHE.wdd_rec.source_header_id;
		  l_source_line_id := INV_CACHE.wdd_rec.source_line_id;
		  l_released_status := INV_CACHE.wdd_rec.released_status;


		  --Call Update_Shipping_Attributes to backorder detail line
		  l_shipping_attr(1).source_header_id := l_source_header_id;
		  l_shipping_attr(1).source_line_id := l_source_line_id;
		  l_shipping_attr(1).ship_from_org_id := l_mo_line.organization_id;
		  l_shipping_attr(1).released_status := l_released_status;
		  l_shipping_attr(1).delivery_detail_id := l_delivery_detail_id;
		  l_shipping_attr(1).action_flag := 'B';
		  l_shipping_attr(1).cycle_count_quantity := l_mo_line.quantity;
		  -- HW INVCONV Added Qty2
		  l_shipping_attr(1).cycle_count_quantity2 := l_mo_line.secondary_quantity;
		  l_shipping_attr(1).subinventory := l_mo_line.from_subinventory_code;
		  l_shipping_attr(1).locator_id := l_mo_line.from_locator_id;


		  WSH_INTERFACE.Update_Shipping_Attributes
		    (p_source_code               => 'INV',
		     p_changed_attributes        => l_shipping_attr,
		     x_return_status             => l_api_return_status
		     );
		  if( l_api_return_status = FND_API.G_RET_STS_ERROR ) then
		     If is_debug then
			print_debug('return error from update shipping attributes',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		     raise FND_API.G_EXC_ERROR;
		   elsif l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
		     If is_debug then
			print_debug('return error from update shipping attributes',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		     raise FND_API.G_EXC_UNEXPECTED_ERROR;
		  end if;

		  --close the move order line
		  -- HW INVCONV Update Qty2
		  update mtl_txn_request_lines
		    set  quantity = 0
		    ,quantity_detailed = 0
		    ,secondary_quantity = decode(secondary_quantity,fnd_api.g_miss_num, NULL, 0)
		    ,secondary_quantity_detailed = decode(secondary_quantity_detailed,fnd_api.g_miss_num, NULL, 0)
		    ,line_status = 5
          ,status_date =sysdate                      --BUG 7560455
		    where line_id = l_mo_line.line_id;

		  -- Exit if there are no more move order lines to detail
		  --  or when the next move order is not for the same ship set.
		  -- Exit before updating the pick_release_status tbl
		  -- for the last line.  The table gets updated for the last
		  -- line later.
		  -- l_set_index should always be equal to the last line
		  --  in the current ship set, so that the logic at the
		  --  end of the outer loop works correctly.
		  EXIT WHEN l_mo_line_tbl.LAST = l_set_index;
		  l_set_index := l_mo_line_tbl.NEXT(l_set_index);
		  if nvl(l_mo_line_tbl(l_set_index).ship_set_id,-1)
		    <> l_cur_ship_set_id then
		     l_set_index := l_mo_line_tbl.PRIOR(l_set_index);
		     EXIT;
		  end if;

		  --If next line is for same ship set, update output table
		  l_set_process := l_set_process + 1;
		  x_pick_release_status(l_set_process).mo_line_id :=
		    l_mo_line.line_id;
		  x_pick_release_status(l_set_process).return_status :=
		    l_api_return_status;
		  x_pick_release_status(l_set_process).detail_rec_count := 0;
		  If is_debug then
		     print_debug('x_pick_release_status ' || l_set_process ||
				 ' mo_line_id = ' || l_mo_line.line_id,
				 'Pick_release_Pub');
		     print_debug('x_pick_release_status ' || l_set_process ||
				 ' return_status = '|| l_api_return_status,
				 'Pick_release_Pub');
		     print_debug('x_pick_release_status ' || l_set_process ||
				 ' detail_rec_count = 0', 'Pick_Release_Pub');
		  End If;
	       END LOOP;

	       -- at the end of this loop, l_mo_line and l_set_index
	       --  point to the last line for this ship set.  l_set_process
	       --  is the index of the last entry in the pick release status
	       --  table.  This allows all of the logic near the end of the
	       --  loop to work correctly.
	       l_line_index := l_set_index;
	       l_cur_ship_set_id := NULL;
	       l_processed_row_count := l_set_process;
	       l_detail_rec_count := 0;
	       l_qtree_backup_tbl.DELETE;
	       If is_debug then
		  print_debug('Finished backordering all lines in shipset',
	              'Inv_Pick_Release_Pub.Pick_Release');
	       End If;

	       --For Ship Models, if a move order line does not fully
	       -- allocate, we have to determine the new model quantity.  Then,
	       -- once we know the new model quantity, we have to change the
	       -- quantity on each move order line to reflect the new model
	       -- quantity.  Backorders have to created for the lines which
	       -- have their quantity reduced.
	     ELSIF l_cur_ship_model_id IS NOT NULL THEN
	       -- Bug 2461353, 2411016
	       --Call Shipping and let them know for a ship model we were not
	       --able to allocate completely
	       BEGIN
		  If is_debug then
		     print_debug('Update shipping that ship model detailing partial',
				 'Inv_Pick_Release_Pub.Pick_Release');
		  End If;

		  l_shipset_smc_backorder_rec.move_order_line_id:=l_mo_line.line_id;
		  l_shipset_smc_backorder_rec.ship_model_id :=l_cur_ship_model_id;

		  wsh_integration.ins_backorder_ss_smc_rec
		    (p_api_version_number => 1.0,
		     p_source_code        => 'INV',
		     p_init_msg_list      => fnd_api.g_false,
		     p_backorder_rec      => l_shipset_smc_backorder_rec,
		     x_return_status      => l_api_return_status,
		     x_msg_count          => x_msg_count,
		     x_msg_data           => x_msg_data);

		  IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
		     If is_debug then
			print_debug('Error occured while updating shipping for ' ||
				    'failed ship set',
				    'Inv_Pick_Release_Pub.Pick_Release');
			print_debug('l_return_status'||l_api_return_status,
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		  END IF;
	       EXCEPTION
		  WHEN OTHERS THEN
		     If is_debug then
			print_debug('When other exception',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		     NULL;
		     --no need to error out for reporting purpose.
	       END;

	       If is_debug then
		  print_debug('Rolling back for ship model :' ||l_cur_ship_model_id,
			      'Inv_Pick_Release_Pub.Pick_Release');
	       End If;

	       ROLLBACK to SHIPMODEL;
	       l_set_index := l_start_index;
	       l_set_process := l_start_process;

	       If is_debug then
		  print_debug('OE Line: ' || l_cur_txn_source_line_id,
			      'Inv_Pick_Release_Pub.Pick_Release');
	       End If;

	       -- Get the sales order line quantity.  We need the order
	       -- line quantity to determine the new model quantity. We
	       -- can't just use the move order line quantity, b/c there
	       -- could be multiple move orders per sales order line.
 	       BEGIN
		  SELECT ordered_quantity, order_quantity_uom
		    INTO l_cur_txn_source_req_qty, l_txn_source_line_uom
		    FROM OE_ORDER_LINES_ALL
		    WHERE line_id = l_cur_txn_source_line_id;
	       EXCEPTION
		  WHEN NO_DATA_FOUND then
		     If is_debug then
			print_debug('No Order Line Quantity found',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		     ROLLBACK TO Pick_Release_PUB;
		     FND_MESSAGE.SET_NAME('INV','INV_DELIV_INFO_MISSING');
		     FND_MSG_PUB.Add;
		     RAISE fnd_api.g_exc_unexpected_error;
	       END;

	       -- convert to primary UOM
	       IF l_txn_source_line_uom <>
		 l_primary_uom_tbl(l_mo_line.inventory_item_id) THEN

		  l_cur_txn_source_req_qty :=
		    inv_convert.inv_um_convert(
					       l_mo_line.inventory_item_id
					       ,NULL
					       ,l_cur_txn_source_req_qty
					       ,l_txn_source_line_uom
					       ,l_primary_uom_tbl(l_mo_line.inventory_item_id)
					       ,NULL
					       ,NULL);
	       END IF;
	       -- find new model quantity.
	       -- new model qty = floor((allocated for this sales order /
	       --		       requested for this sales order) *
	       --		       original model quantity)
	       --  We take the floor because we can only ship whole numbers
	       --  of the top model
	       l_new_model_quantity := floor(l_cur_txn_source_qty * l_mo_line.model_quantity /
					     l_cur_txn_source_req_qty);
	       --l_new_model_quantity :=
	       --floor(l_cur_txn_source_qty * l_mo_line.model_quantity/
	       --l_mo_line.quantity);

	       --We keep model quantity and quantity in PUOM so should not
	       --find it from order lines.
	       If is_debug then
		  print_debug('New model qty ' || l_new_model_quantity,
			      'Inv_Pick_Release_Pub.Pick_Release');
	       End If;

	       --loop through all move order lines for this ship model
	       LOOP
		  l_mo_line := l_mo_line_tbl(l_set_index);
		  If is_debug then
		     print_debug('SHIPMODEL-Current mo line:'||l_mo_line.line_id,
				 'Inv_Pick_Release_Pub.Pick_Release');
		  End If;

		  --find tree id.  If item is unit effective, get tree id from
		  -- qtree_line_tbl.  Else, get it from qtree_item_tbl.
		  IF l_qtree_item_tbl(l_mo_line.inventory_item_id).unit_effective='Y'
		    THEN
		     l_tree_id :=
		       l_qtree_line_tbl(l_mo_line.txn_source_line_id).tree_id;
		   ELSE
		     l_tree_id :=
		       l_qtree_item_tbl(l_mo_line.inventory_item_id).tree_id;
		  END IF;

		  -- only restore tree if it is currently in backup table.
		  -- Tree would not be in backup table if current move order line
		  -- was not allocated or if the tree had already been restored
		  -- for a previous move order line.
		  IF l_qtree_backup_tbl.EXISTS(l_tree_id) THEN

		     If is_debug then
			print_debug('Restoring Quantity Tree: ' || l_tree_id,
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		     inv_quantity_tree_pvt.restore_tree
		       (x_return_status  => l_api_return_status
			,p_tree_id       => l_tree_id
			,p_backup_id     => l_qtree_backup_tbl(l_tree_id)
			);
		     if( l_api_return_status = FND_API.G_RET_STS_ERROR ) then
			If is_debug then
			   print_debug('Error in Restore_Tree',
				       'Inv_Pick_Release_Pub.Pick_Release');
			End If;
			raise FND_API.G_EXC_ERROR;
		      elsif l_api_return_status=FND_API.G_RET_STS_UNEXP_ERROR then
			If is_debug then
			   print_debug('Unexpected error in Restore_tree',
				       'Inv_Pick_Release_Pub.Pick_Release');
			End If;
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		     end if;

		     --delete entry, so we don't restore tree more than once
		     l_qtree_backup_tbl.DELETE(l_tree_id);

		  END IF;


		  -- whenever line changes, find sales order quantity for
		  -- this line
		  IF l_set_txn_source_line_Id IS NULL OR
		    l_set_txn_source_line_id <> l_mo_line.txn_source_line_id
		    THEN
		     l_set_txn_source_line_id := l_mo_line.txn_source_line_id;
		     If is_debug then
			print_debug('OE Line: ' || l_set_txn_source_line_id,
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;

		     -- if we already got the qty, don't get it again
		     IF l_set_txn_source_line_id = l_cur_txn_source_line_id Then
			l_set_txn_source_req_qty := l_cur_txn_source_req_qty;
		      ELSE
 	                BEGIN
			   -- Bug 3340502, fetching order_quantity_uom in variable
			   -- l_txn_source_line_uom instead of l_set_txn_source_uom
			   SELECT ordered_quantity, order_quantity_uom
			     INTO l_set_txn_source_req_qty, l_txn_source_line_uom
			     FROM OE_ORDER_LINES_ALL
			     WHERE line_id = l_set_txn_source_line_id;
			EXCEPTION
			   WHEN NO_DATA_FOUND then
			      If is_debug then
				 print_debug('No Order Line Quantity found',
					     'Inv_Pick_Release_Pub.Pick_Release');
			      End If;
			      ROLLBACK TO Pick_Release_PUB;
			      FND_MESSAGE.SET_NAME('INV','INV_DELIV_INFO_MISSING');
			      FND_MSG_PUB.Add;
			      RAISE fnd_api.g_exc_unexpected_error;
			END;

			--convert to primary quantity
			if l_txn_source_line_uom <>
			  l_primary_uom_tbl(l_mo_line.inventory_item_id) then

			   l_cur_txn_source_req_qty :=
			     inv_convert.inv_um_convert(
							l_mo_line.inventory_item_id
							,NULL
							,l_cur_txn_source_req_qty
							,l_txn_source_line_uom
							,l_primary_uom_tbl(l_mo_line.inventory_item_id)
							,NULL
							,NULL);
			end if;
		     END IF;

		     -- based on new model quantity, find new move order
		     -- line quantity
		     -- l_set_new_req_qty :=  (l_mo_line.quantity *
		     --		          l_new_model_quantity
		     --			   / l_mo_line.model_quantity);

		     l_set_new_req_qty := l_set_txn_source_req_qty *
		       l_new_model_quantity /
		       l_mo_line.model_quantity;

		     If is_debug then
			print_debug('New req qty: ' || l_set_new_req_qty,
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		  END IF;

		  -- set new move order line quantity
		  IF l_set_new_req_qty >= l_mo_line.quantity THEN
		     l_new_line_quantity := l_mo_line.quantity;
		   ELSE
		     -- if new line quantity < previous line qty,
		     -- backorder
		     l_new_line_quantity := l_set_new_req_qty;

		     If is_debug then
			print_debug('New line qty: ' || l_new_line_quantity,
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;

		     l_return_value := INV_CACHE.set_wdd_rec(l_mo_line.line_id);
		     If NOT l_return_value Then
			If is_debug then
			   print_debug('Error setting cache for delivery line',
				       'INV_Pick_Release_Pub.Pick_Release');
			End If;
			RAISE fnd_api.g_exc_unexpected_error;
		     End If;
		     l_delivery_detail_id := INV_CACHE.wdd_rec.delivery_detail_id;
		     l_source_header_id := INV_CACHE.wdd_rec.source_header_id;
		     l_source_line_id := INV_CACHE.wdd_rec.source_line_id;
		     l_released_status := INV_CACHE.wdd_rec.released_status;

		     --Call Update_Shipping_Attributes to backorder detail line
		     l_shipping_attr(1).source_header_id := l_source_header_id;
		     l_shipping_attr(1).source_line_id := l_source_line_id;
		     l_shipping_attr(1).ship_from_org_id := l_mo_line.organization_id;
		     l_shipping_attr(1).released_status := l_released_status;
		     l_shipping_attr(1).delivery_detail_id := l_delivery_detail_id;
		     l_shipping_attr(1).action_flag := 'B';
		     l_shipping_attr(1).cycle_count_quantity := l_mo_line.quantity - l_new_line_quantity;
		     l_shipping_attr(1).subinventory := l_mo_line.from_subinventory_code;
		     l_shipping_attr(1).locator_id := l_mo_line.from_locator_id;
		     l_smc_backorder_det_tbl(1) :=l_shipping_attr(1);
		     -- 2509322: Earlier whenever a component in a model is short we
		     -- backorder all
		     -- components to the difference of new model quantity and original
		     -- and repick release all.But if many components are short then
		     -- we end up splitting many delivery details.
		     -- Now avoided multiple splits by storing back order details
		     -- and do only once.

		     Store_smc_bo_details(x_return_status    => l_api_return_status,
					  back_order_det_tbl =>l_smc_backorder_det_tbl);
		     if( l_api_return_status = FND_API.G_RET_STS_ERROR ) then
			If is_debug then
			   print_debug(' return error E from Store_smc_bo_details',
				       'Inv_Pick_Release_Pub.Pick_Release');
			End If;
			l_smc_backorder_det_tbl.DELETE;
			raise FND_API.G_EXC_ERROR;
		      elsif l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			If is_debug then
			   print_debug(' return error U from Store_smc_bo_details',
				       'Inv_Pick_Release_Pub.Pick_Release');
			End If;
			l_smc_backorder_det_tbl.DELETE;
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		     end if;

		     l_smc_backorder_det_tbl.DELETE;


		     --WSH_INTERFACE.Update_Shipping_Attributes
		     --(p_source_code               => 'INV',
		     --p_changed_attributes        => l_shipping_attr,
		     --x_return_status             => l_api_return_status
		     --);

		  END IF;

		  l_set_new_req_qty := l_set_new_req_qty - l_new_line_quantity;

		  -- Update mo line with new quantity and model quantity;
		  --If mo line quantity is 0, close the move order line
		  IF l_new_line_quantity = 0 THEN
		     update mtl_txn_request_lines
		       set  quantity = 0
		       ,quantity_detailed = 0
		       ,line_status = 5
             ,status_date =sysdate                    --BUG 7560455
		       ,model_quantity = l_new_model_quantity
		       where line_id = l_mo_line.line_id;
		     l_mo_line_tbl(l_set_index).quantity_detailed := 0;
		     l_mo_line_tbl(l_set_index).line_status := 5;
		   ELSE
		     update mtl_txn_request_lines
		       set  quantity = l_new_line_quantity
		       ,quantity_detailed = NULL
		       ,model_quantity = l_new_model_quantity
		       where line_id = l_mo_line.line_id;
		     l_mo_line_tbl(l_set_index).quantity_detailed := NULL;
		  END IF;
		  l_mo_line_tbl(l_set_index).quantity := l_new_line_quantity;

		  -- Bug# 3085075. Commented out the next line so that model qty does not
		  -- become fractional.
		  --l_mo_line_tbl(l_set_index).model_quantity := l_new_model_quantity;

		  If is_debug then
		     print_debug('Finished Updating Mo Line',
				 'Inv_Pick_Release_Pub.Pick_Release');
		  End If;

		  -- Exit if there are no more move order lines to detail
		  --  or when the next move order is not for the same ship model.
		  -- Exit before updating the pick_release_status tbl
		  -- for the last line.  The table gets updated for the last
		  -- line later.
		  -- l_set_index should always be equal to the last line
		  --  in the current ship set, so that the logic at the
		  --  end of the outer loop works correctly.
		  EXIT WHEN l_mo_line_tbl.LAST = l_set_index;
		  l_set_index := l_mo_line_tbl.NEXT(l_set_index);
		  if nvl(l_mo_line_tbl(l_set_index).ship_model_id,-99)
		    <> l_cur_ship_model_id then
		     l_set_index := l_mo_line_tbl.PRIOR(l_set_index);
		     EXIT;
		  end if;

		  -- Only update status table if model_quantity = 0;
		  -- If model quantity <> 0, then we loop through all these
		  -- records again, re-detailing them for the new line quantities.
		  -- The status table will get populated at that point.
		  -- But, if model_quantity = 0, then we don't look at these
		  -- mo lines again, since the quantity for all the lines = 0.
		  -- We have to update the status now.
		  if l_new_model_quantity = 0 then

		     --If next line is for same ship set, update output table
		     l_set_process := l_set_process + 1;
		     x_pick_release_status(l_set_process).mo_line_id := l_mo_line.line_id;
		     x_pick_release_status(l_set_process).return_status := l_api_return_status;
		     x_pick_release_status(l_set_process).detail_rec_count := 0;
		     If is_debug then
			print_debug('x_pick_release_status ' || l_set_process ||
				    ' mo_line_id = ' || l_mo_line.line_id,
				    'Pick_release_Pub');
			print_debug('x_pick_release_status ' || l_set_process ||
				    ' return_status = '|| l_api_return_status,
				    'Pick_release_Pub');
			print_debug('x_pick_release_status ' || l_set_process ||
				    ' detail_rec_count = 0', 'Pick_Release_Pub');
		     End If;
		  end if;
	       END LOOP;

	       --reset global values, since we are relooping
	       --Bug 2706558 - reset cur_txn_source_qty and cur_txn_source_line_id
	       l_cur_ship_model_id := NULL;
	       l_qtree_backup_tbl.DELETE;
	       l_cur_txn_source_qty := 0;
	       -- HW INVCONV Added Qty2
	       l_cur_txn_source_qty2 :=0;
	       l_cur_txn_source_line_id := NULL;

	       -- If new model quantity = 0, then we backordered all of the
	       -- lines.  No need to try to redetail.  Set line index
	       -- to point at the last mo line we backordered.
	       IF l_new_model_quantity = 0 THEN
		  l_line_index := l_set_index;
		  l_processed_row_count := l_set_process;
		  l_detail_rec_count := 0;

		  If is_debug then
		     print_debug('Backordered all lines with this Ship Model Id',
				 'Inv_Pick_Release_Pub.Pick_Release');
		  End If;
		  Backorder_SMC_DETAILS(l_api_return_status ,
					x_msg_data ,
					x_msg_count
					);
		  if( l_api_return_status = FND_API.G_RET_STS_ERROR ) then
		     If is_debug then
			print_debug('return error E from Backorder_SMC_DETAILS',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		     raise FND_API.G_EXC_ERROR;
		   elsif l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
		     If is_debug then
			print_debug('return error U from Backorder_SMC_DETAILS',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     End If;
		     raise FND_API.G_EXC_UNEXPECTED_ERROR;
		  end if;

		ELSE

		  -- If new model quantity <> 0, then we want to loop
		  -- through these lines again.  Set line index to
		  -- point to the  first record with this ship
		  -- model id. Also we need to turn on the reloop flag so that
		  -- the line index is not incremented later.
		  l_line_index := l_start_index;
		  l_processed_row_count := l_start_process;
		  l_model_reloop := TRUE;
	       END IF;

	     ELSE
	       -- Move order line is not fully allocated and it is not part of a
	       -- shipset or ship model


	        -- 8519286
                /*  l_return_value := INV_CACHE.set_wdd_rec(l_mo_line.line_id); */
      	        l_return_value := FALSE;

		  BEGIN
		     SELECT *
		     INTO INV_CACHE.wdd_rec
		     FROM WSH_DELIVERY_DETAILS
		     WHERE move_order_line_id = l_mo_line.line_id
		     AND NVL(released_status, 'Z') NOT IN ('Y','C');
		     l_return_value := TRUE;
		      EXCEPTION
		     WHEN NO_DATA_FOUND THEN
                     l_return_value := FALSE;
                     WHEN OTHERS THEN
                     l_return_value := FALSE;
		  END;
                 -- End of 8519286


	       -- Retrieve the WDD record corresponding to the current MOL
	       l_return_value := INV_CACHE.set_wdd_rec(l_mo_line.line_id);
	       IF (NOT l_return_value) THEN
		  IF (is_debug) THEN
		     print_debug('Error setting cache for delivery line',
				 'INV_Pick_Release_Pub.Pick_Release');
		  END IF;
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;
	       l_delivery_detail_id := INV_CACHE.wdd_rec.delivery_detail_id;
	       l_source_header_id := INV_CACHE.wdd_rec.source_header_id;
	       l_source_line_id := INV_CACHE.wdd_rec.source_line_id;
	       l_released_status := INV_CACHE.wdd_rec.released_status;

	       -- Bug# 4258360: If allocation mode = N (Prioritize Inventory), instead of simply
	       -- backordering the unallocated quantity on the WDD record, we need to perform
	       -- new logic to support crossdocking.  The WDD record needs to be split or updated
	       -- properly so we can still try to allocate material through crossdocking later.
	       -- {{
	       -- Run PR in Prioritize INV mode and ensure that one WDD
	       -- does not get allocated at all. That WDD should get
	       -- x-docked and later deliveries created for same.
	       -- }}
	       -- {{
	       -- Run PR in Prioritize INV mode and ensure that one WDD
	       -- gets partially allocated. That WDD should get split and
	       -- x-docked and later deliveries created for the new WDD.
	       -- Also ensure that the original WDD has the correct qty.
	       -- }}
	       IF (l_allocation_method = g_prioritize_inventory) AND (p_wsh_release_table.COUNT > 0) THEN
		  IF (l_transaction_quantity = 0) THEN


		     -- Move order line is not allocated at all.
		     -- Do not backorder the current WDD line yet since crossdocking can still
		     -- potentially allocate material for this.  Update the WDD record to null
		     -- out the move_order_line_id column and reset the released_status to the
		     -- original value from the corresponding record in p_wsh_release_table.


		     -- R12.1 replenishment Project 6681109/6710368
		     -- changes based ON p_dynamic_replenishment
		     IF (is_debug) THEN
			print_debug('p_dynamic_replenishment :'||p_dynamic_replenishment,
				    'INV_Pick_Release_Pub.Pick_Release');
		     END IF;


		     l_detail_info_tab(1).delivery_detail_id := l_delivery_detail_id;
		     l_detail_info_tab(1).released_status :=
		       p_wsh_release_table(l_wdd_index_tbl(l_delivery_detail_id)).released_status;

		     IF NVL(p_dynamic_replenishment,'N') = 'Y' THEN

			IF (is_debug) THEN
			   print_debug('Mark WDD repl_status as RR','INV_Pick_Release_Pub.Pick_Release');
			END IF;
			--if qty is available somewhere in the org, we will try to replenish it first
			-- mark the demand lines for replenishment requested status
			l_detail_info_tab(1).replenishment_status := 'R';
			l_in_rec.caller := 'WMS_REP';
			l_in_rec.action_code := 'UPDATE';

		      ELSE

			-- When calling the Shipping package WSH_INTERFACE_EXT_GRP instead of
			-- WSH_INTERFACE_GRP, we have to pass a G_MISS_NUM value instead of NULL
			-- in order to properly NULL out the move_order_line_id value.

			l_detail_info_tab(1).move_order_line_id := fnd_api.g_miss_num;

			-- Caller needs to be WMS_XDOCK% in order for shipping to allow this action
			l_in_rec.caller := 'WMS_XDOCK.INVPPICB';
			l_in_rec.action_code := 'UPDATE';

		     END IF;

		     WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail
		       (p_api_version_number  => 1.0,
			p_init_msg_list       => fnd_api.g_false,
			p_commit              => fnd_api.g_false,
			x_return_status       => l_api_return_status,
			x_msg_count           => x_msg_count,
			x_msg_data            => x_msg_data,
			p_detail_info_tab     => l_detail_info_tab,
			p_in_rec              => l_in_rec,
			x_out_rec             => l_out_rec
			);

		     IF (l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
			IF (is_debug) THEN
			   print_debug('Error returned from Create_Update_Delivery_Detail API',
				       'Inv_Pick_Release_Pub.Pick_Release');
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		      ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			IF (is_debug) THEN
			   print_debug('Unexpected errror from Create_Update_Delivery_Detail API',
				       'Inv_Pick_Release_Pub.Pick_Release');
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		     END IF;

		   ELSE -- means (l_transaction_quantity <> 0)
		     -- Move order line is partially allocated
		     -- Split the WDD line with the partial quantity allocated.  The new WDD
		     -- line with the unallocated quantity will retain the original released_status
		     -- on the original WDD record in p_wsh_release_table
		     l_detail_id_tab(1) := l_delivery_detail_id;
		     -- Caller needs to be WMS_XDOCK% in order for shipping to allow this action
		     l_action_prms.caller := 'WMS_XDOCK.INVPPICB';
		     l_action_prms.action_code := 'SPLIT-LINE';
		     l_action_prms.split_quantity :=
		       (l_quantity - NVL(l_quantity_delivered,0)) - l_transaction_quantity;
		     l_action_prms.split_quantity2 :=
		       (l_quantity2 - NVL(l_quantity2_delivered,0)) - l_transaction_quantity2;

		     WSH_INTERFACE_GRP.Delivery_Detail_Action
		       (p_api_version_number  => 1.0,
			p_init_msg_list       => fnd_api.g_false,
			p_commit              => fnd_api.g_false,
			x_return_status       => l_api_return_status,
			x_msg_count           => x_msg_count,
			x_msg_data            => x_msg_data,
			p_detail_id_tab       => l_detail_id_tab,
			p_action_prms         => l_action_prms,
			x_action_out_rec      => l_action_out_rec
			);

		     IF (l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
			IF (is_debug) THEN
			   print_debug('Error returned from Split Delivery_Detail_Action API',
				       'Inv_Pick_Release_Pub.Pick_Release');
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		      ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			IF (is_debug) THEN
			   print_debug('Unexpected errror from Split Delivery_Detail_Action API',
				       'Inv_Pick_Release_Pub.Pick_Release');
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		     END IF;

		     l_xdock_index := l_action_out_rec.result_id_tab.FIRST;
		     l_split_delivery_detail_id := l_action_out_rec.result_id_tab(l_xdock_index);

		     -- Update the split WDD line for the unallocated quantity to null out the
		     -- move_order_line_id column and reset the released_status to the original
		     -- value in the corresponding WDD record (original one) in p_wsh_release_table
		     l_detail_info_tab(1).delivery_detail_id := l_split_delivery_detail_id;
		     l_detail_info_tab(1).released_status :=
		       p_wsh_release_table(l_wdd_index_tbl(l_delivery_detail_id)).released_status;
		     -- When calling the Shipping package WSH_INTERFACE_EXT_GRP instead of
		     -- WSH_INTERFACE_GRP, we have to pass a G_MISS_NUM value instead of NULL
		     -- in order to properly NULL out the move_order_line_id value.
		     --l_detail_info_tab(1).move_order_line_id := NULL;
		     l_detail_info_tab(1).move_order_line_id := fnd_api.g_miss_num;


		     IF NVL(p_dynamic_replenishment,'N') = 'Y' THEN
			IF (is_debug) THEN
			   print_debug(' Mark repl_status of WDD as RR','INV_Pick_Release_Pub.Pick_Release');
			END IF;
			-- mark the new split demand lines for replenishment requested status
			l_detail_info_tab(1).replenishment_status := 'R';
			l_in_rec.caller := 'WMS_REP';
		      ELSE
			-- Caller needs to be WMS_XDOCK% in order for shipping to allow this action
			l_in_rec.caller := 'WMS_XDOCK.INVPPICB';
		     END IF;


		     l_in_rec.action_code := 'UPDATE';

		     WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail
		       (p_api_version_number  => 1.0,
			p_init_msg_list       => fnd_api.g_false,
			p_commit              => fnd_api.g_false,
			x_return_status       => l_api_return_status,
			x_msg_count           => x_msg_count,
			x_msg_data            => x_msg_data,
			p_detail_info_tab     => l_detail_info_tab,
			p_in_rec              => l_in_rec,
			x_out_rec             => l_out_rec
			);

		     IF (l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
			IF (is_debug) THEN
			   print_debug('Error returned from Create_Update_Delivery_Detail API',
				       'Inv_Pick_Release_Pub.Pick_Release');
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		      ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			IF (is_debug) THEN
			   print_debug('Unexpected errror from Create_Update_Delivery_Detail API',
				       'Inv_Pick_Release_Pub.Pick_Release');
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		     END IF;

		     -- Insert the split WDD line into p_wsh_release_table.
		     -- The split WDD release record should be the same as the original one with
		     -- only the following fields modified: delivery_detail_id, move_order_line_id
		     -- replenishment_status, and requested_quantity fields
		     l_split_wdd_rel_rec := p_wsh_release_table(l_wdd_index_tbl(l_delivery_detail_id));
		     l_split_wdd_rel_rec.delivery_detail_id := l_split_delivery_detail_id;
		     l_split_wdd_rel_rec.move_order_line_id := NULL;
		     l_split_wdd_rel_rec.requested_quantity :=
		       (l_quantity - NVL(l_quantity_delivered,0)) - l_transaction_quantity;
		     l_split_wdd_rel_rec.requested_quantity2 :=
		       (l_quantity2 - NVL(l_quantity2_delivered,0)) - l_transaction_quantity2;


		     l_xdock_index := p_wsh_release_table.LAST + 1;
		     p_wsh_release_table(l_xdock_index) := l_split_wdd_rel_rec;

		     -- Insert a new record into p_trolin_delivery_ids and p_del_detail_id
		     -- for the split WDD line created.
		     -- UPDATE: Do not need to do this anymore.  The delivery tables passed in by
		     -- Shipping are used for storing crossdocked WDD lines.  If this split line
		     -- is later allocated from Crossdocking, the crossdock API will insert them
		     -- into the delivery tables.
		     /*l_xdock_index := NVL(p_del_detail_id.LAST, 0) + 1;
		     p_del_detail_id(l_xdock_index) := l_split_wdd_rel_rec.delivery_detail_id;
		     p_trolin_delivery_ids(l_xdock_index) := l_split_wdd_rel_rec.delivery_id;*/

		     -- Update the original WDD line in p_wsh_release_table with
		     -- released_status = 'S' and the corresponding allocated quantity
		     l_xdock_index := l_wdd_index_tbl(l_delivery_detail_id);
		     p_wsh_release_table(l_xdock_index).released_status := 'S';
		     p_wsh_release_table(l_xdock_index).requested_quantity := l_transaction_quantity;
		     p_wsh_release_table(l_xdock_index).requested_quantity2 := l_transaction_quantity2;

		  END IF; -- for  IF (l_transaction_quantity = 0) THEN
		ELSE
		  -- Original code which is used for allocation mode = I (Inventory Only)
		  -- and X (Prioritize Crossdock).
		  -- NOTE: I believe cycle_count_quantity should technically be:
		  -- (l_quantity - NVL(l_quantity_delivered,0)) - l_transaction_quantity
		  -- Same thing goes for cycle_count_quantity2.  Since the transaction quantity
		  -- variable already takes the quantity delivered into account, the requested
		  -- quantity on the MOL (l_quantity) should do the same.  Not making the changes
		  -- yet but leaving the comments here for the future.  -etam
		  l_shipping_attr(1).source_header_id := l_source_header_id;
		  l_shipping_attr(1).source_line_id := l_source_line_id;

		  l_shipping_attr(1).ship_from_org_id := l_mo_line.organization_id;
		  l_shipping_attr(1).released_status := l_released_status;
		  l_shipping_attr(1).delivery_detail_id := l_delivery_detail_id;


		  --Note: Inside the API Update_Shipping_Attributes, wdd is split and qty are backordered
		  --in case action_flag is 'B'.  Backorder qty is passed
		  --from INV as cycle_count_quantity below and requested qty is obtained from WDD table by
		  --shipping. Now in case of 'R', shipping team will make change
		  -- to mark those lines as Replenishment Requested instead of backordering them

		  IF NVL(p_dynamic_replenishment,'N') = 'Y'  THEN
		     IF is_debug THEN
			print_debug('Marking line status as RR',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     END IF;
		     l_shipping_attr(1).action_flag := 'R';
		   ELSE
		     l_shipping_attr(1).action_flag := 'B';
		  END IF;

		  --l_shipping_attr(1).cycle_count_quantity := (l_quantity - l_transaction_quantity);
		  -- HW INVCONV - Added Qty2
		  --l_shipping_attr(1).cycle_count_quantity2 := (l_quantity2 - l_transaction_quantity2);

		   -- End of 8519286
                  l_shipping_attr(1).cycle_count_quantity := (l_quantity - NVL(l_quantity_delivered,0) - l_transaction_quantity);
                  l_shipping_attr(1).cycle_count_quantity2 := (l_quantity2 - NVL(l_quantity2_delivered,0) - l_transaction_quantity2);
                  -- End of 8519286


		  l_shipping_attr(1).subinventory := l_mo_line.from_subinventory_code;
		  l_shipping_attr(1).locator_id := l_mo_line.from_locator_id;

		  WSH_INTERFACE.Update_Shipping_Attributes
		    (p_source_code               => 'INV',
		     p_changed_attributes        => l_shipping_attr,
		     x_return_status             => l_api_return_status
		     );
		  IF (l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
		     IF is_debug THEN
			print_debug('return error from update shipping attributes',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     END IF;
		     RAISE FND_API.G_EXC_ERROR;
		   ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		     IF is_debug THEN
			print_debug('return error from update shipping attributes',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     END IF;
		     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		  END IF;
	       END IF; -- for  IF (l_allocation_method = g_prioritize_inventory) AND (p_wsh...

	       -- HW INVCONV Added secondary_quantity
	       -- Update the current move order line depending on how much quantity
	       -- was successfully allocated from inventory.
	       IF (l_transaction_quantity = 0) THEN
		  -- Close the move order line created since no quantity was allocated
		  UPDATE mtl_txn_request_lines
		    SET line_status = 5,
          status_date =sysdate,                --BUG 7560455
		    quantity = l_transaction_quantity,
		    secondary_quantity = DECODE(secondary_quantity, fnd_api.g_miss_num, NULL,
						l_transaction_quantity2)
		    WHERE line_id = l_mo_line.line_id;

		  -- Bug# 4258360: For allocation modes of I (Inventory Only) or
		  -- X (Prioritize Crossdock), allocation (both from inventory and crossdock)
		  -- has completed.  We need to remove the backordered lines from
		  -- p_trolin_delivery_ids and p_del_detail_id tables so deliveries are not
		  -- autocreated for them later on by Shipping.  Store the lines which did
		  -- not get any material allocated at all in PLSQL table l_backordered_wdd_tbl.
		  IF (l_allocation_method IN (g_inventory_only, g_prioritize_crossdock)) AND
                     (p_wsh_release_table.COUNT > 0) THEN
		     -- UPDATE: Do not need to do this anymore.  The delivery tables inputted from
		     -- Shipping are used only to store crossdocked WDD lines.  They will be
		     -- empty initially.  Instead, set the released_status for the line to be 'B'
		     -- in the inputted release table.
		     --l_backordered_wdd_tbl(l_delivery_detail_id) := TRUE;
		     p_wsh_release_table(l_wdd_index_tbl(l_delivery_detail_id)).released_status := 'B';
		  END IF;
		ELSE
        --Bug 9199956 The primary quantity in mtrl should match the quantity in primary uom. Since for Pick Wave move orders
        --The uom is always primary uom setting it to quantity value.
		  -- Update the move order line to the partial quantity that was allocated
		  UPDATE mtl_txn_request_lines
		    SET quantity = l_transaction_quantity,
		    secondary_quantity = DECODE(secondary_quantity, fnd_api.g_miss_num, NULL,
						l_transaction_quantity2)
                   ,primary_quantity=l_transaction_quantity
		    WHERE line_id = l_mo_line.line_id;
	       END IF;

	    END IF;  --cur ship set id
	  ELSIF (l_transaction_quantity = (l_quantity - NVL(l_quantity_delivered,0))) THEN
	    -- Bug# 4258360: If allocation mode = N (Prioritize Inventory), we need to update
	    -- the corresponding WDD record in p_wsh_release_table to a released_status of 'S'.
	    -- This is so the crossdock API (which will be called later on) knows the WDD record has
	    -- been fully allocated already.  This is added for the R12 Planned Crossdocking project.
	    -- {{
	    -- Run PR in prioritize INV mode and ensure entire WDD
	    -- gets allocated. That WDD should not be re-allocated for
	    -- x-docking.
	    -- }}
	    IF (l_allocation_method = g_prioritize_inventory) THEN
	       -- Retrieve the WDD record associated with the current MOL
	       IF (NOT INV_CACHE.set_wdd_rec(l_mo_line.line_id)) THEN
		  IF (is_debug) THEN
		     print_debug('Error setting cache for WDD delivery line',
				 'INV_Pick_Release_Pub.Pick_Release');
		  END IF;
		  RAISE fnd_api.g_exc_unexpected_error;
	       END IF;
	       l_delivery_detail_id := INV_CACHE.wdd_rec.delivery_detail_id;

	       -- Update WDD record in release table with a released status of 'S'
               IF (p_wsh_release_table.COUNT > 0) THEN
	          p_wsh_release_table(l_wdd_index_tbl(l_delivery_detail_id)).released_status := 'S';
               END IF;
	    END IF;

	 END IF; -- transaction quantity < quantity
      END IF;  --line status = 5

      -- If there is no need to reloop for processsing partial quantities
      -- FOR ship models
      IF (l_model_reloop <> TRUE) THEN
	 -- Populate return status structure with the processing status of
	 -- this row
	 l_processed_row_count := l_processed_row_count + 1;
	 x_pick_release_status(l_processed_row_count).mo_line_id := l_mo_line.line_id;
	 x_pick_release_status(l_processed_row_count).return_status := l_api_return_status;
	 x_pick_release_status(l_processed_row_count).detail_rec_count := l_detail_rec_count;
	 If is_debug then
	    print_debug('x_pick_release_status ' || l_processed_row_count ||
			'   mo_line_id = ' ||
			x_pick_release_status(l_processed_row_count).mo_line_id,
			'Pick_release_Pub');
	    print_debug('x_pick_release_status ' || l_processed_row_count ||
			' return_status = ' ||
			x_pick_release_status(l_processed_row_count).return_status,
			'Pick_release_Pub');
	    print_debug('x_pick_release_status ' || l_processed_row_count ||
			' detail_rec_count = ' ||
			x_pick_release_status(l_processed_row_count).detail_rec_count,
			'Pick_Release_Pub');
	    print_Debug('detail record count is ' ||
			x_pick_release_status(l_processed_row_count).detail_rec_count,
			'Inv_Pick_Release_Pub.Pick_Release');
	 End If;
      END IF;
      l_detail_rec_count := 0;
      --Update the Pick Release API's return status to an error if the line could
      -- not be processed.  Note that processing of other lines will continue.
      IF l_api_return_status = fnd_api.g_ret_sts_unexp_error OR
	l_api_return_status = fnd_api.g_ret_sts_error THEN
	 x_return_status := fnd_api.g_ret_sts_error;
      END IF;
    END IF; -- mo line return status <> ERROR

    -- Bug 2776309
    -- If model reloop is required then do not exit.
    -- Exit in the case where the new model quantity = 0.
    EXIT WHEN l_line_index = l_mo_line_tbl.last AND (l_model_reloop <> TRUE);

    IF (l_model_reloop <> TRUE) THEN
       l_line_index := l_mo_line_tbl.NEXT(l_line_index);
     ELSE
       --Don't increment the line index and turn off the reloop variable
       l_model_reloop := FALSE;
    END IF;
   END LOOP;

   IF is_debug then
     print_debug('after calling inv_pick_release_pvt',
	       'Inv_Pick_Release_Pub.Pick_Release');
   END IF;

    -- To ensure that lock_flag should not get updated to Y unnecessarily i.e., only change needed only when high volume related code executes
    -- WMS installed should be true
    -- Auto Pick Confirm should be no
    -- The profile value of WMS_ASSIGN_TASK_TYPE should be NULL or YES(default)
    -- Value of p_skip_cartonization passed as TRUE only when parallel pick release happens
    IF  l_wms_installed AND p_auto_pick_confirm = 2 AND l_do_cartonization = 1 AND p_skip_cartonization = TRUE THEN
      BEGIN
        IF is_debug THEN
          print_debug('Updating lock_flag of MMTT records','Inv_Pick_Release_Pub.Pick_Release');
        END IF;
        FORALL ii IN l_mol_id_tbl.FIRST..l_mol_id_tbl.LAST
          update mtl_material_transactions_temp
          set lock_flag = 'Y'
          where move_order_line_id =l_mol_id_tbl(ii);
      EXCEPTION
      WHEN OTHERS THEN
        IF is_debug THEN
          print_debug('Error in updating MMTT records lock_flag: ' || sqlerrm
                     ,'Inv_Pick_Release_Pub.Pick_Release');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
    END IF;

   -- Bug 4349602: Deleting Move Order Lines which are not allocated
   BEGIN
      IF is_debug THEN
         print_debug('Deleting MOLs in status 5','Inv_Pick_Release_Pub.Pick_Release');
      END IF;
      FORALL ii IN l_mol_id_tbl.FIRST..l_mol_id_tbl.LAST
        DELETE FROM mtl_txn_request_lines  mtrl
         WHERE line_status = 5
           AND line_id = l_mol_id_tbl(ii)
           AND EXISTS
             ( SELECT 'x'
                 FROM mtl_system_items  msi
                WHERE msi.organization_id = mtrl.organization_id
                  AND msi.inventory_item_id = mtrl.inventory_item_id
                  AND NVL(msi.reservable_type,1) = 1
             );
   EXCEPTION
     WHEN OTHERS THEN
       IF is_debug THEN
          print_debug('Error in Deleting Move Order Lines: ' || sqlerrm
                     ,'Inv_Pick_Release_Pub.Pick_Release');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   IF l_wms_installed THEN
      -- 09/14/2000 added call to cartonization api
      l_line_index := l_mo_line_tbl.FIRST;
      l_api_return_status := '';
      IF is_debug THEN
	 print_Debug('l_mo_line_tbl.count is ' || l_mo_line_tbl.COUNT,
		     'Inv_Pick_Release_pub.Pick_Release');
      END IF;
      -- Calling device integration api to set global var which will decide
      -- whether to process device request or not, if it is a WMS organization.
      IF wms_device_integration_pvt.wms_call_device_request IS NULL THEN
	 -- Bug# 4491974
	 -- Changed l_mo_line_tbl(1).organization_id to l_mo_line_tbl(l_line_index).organization_id
	 -- since it is possible to have null value at 1 which will lead to ORA-1403 error.
	 wms_device_integration_pvt.is_device_set_up(
						     --l_mo_line_tbl(1).organization_id,
						     l_mo_line_tbl(l_line_index).organization_id,
						     11,
						     l_api_return_status);
      END IF;

      IF (l_do_cartonization = 1 AND NOT p_skip_cartonization) THEN --Added for bug3237702
	 LOOP
	    If is_debug then
	       print_debug('headeR_id for line index ' || l_line_index || ' is ' ||
			   l_mo_line_tbl(l_line_index).header_id,
			   'Inv_Pick_Release_Pub.Pick_Release');
	    End If;

	    IF l_line_index >= l_mo_line_tbl.COUNT THEN
	       -- it's the last line in this group
	       If is_debug then
		  print_debug('calling cartonize api',
			      'Inv_Pick_Release_Pub.Pick_Release');
	       End If;

	       WMS_CARTNZN_PUB.cartonize
		 (
		  p_api_version           => 1,
		  p_init_msg_list         => fnd_api.g_false,
		  p_commit                => fnd_api.g_false,
		  p_validation_level      => fnd_api.g_valid_level_full,
		  x_return_status         => l_api_return_status,
		  x_msg_count             => x_msg_count,
		  x_msg_data              => x_msg_data,
		  p_out_bound             => 'Y',
		  p_org_id                => l_mo_line_tbl(l_line_index).organization_id,
		  p_move_order_header_id  => l_mo_line_tbl(l_line_index).header_id
		  );

	       IF l_api_return_status = fnd_api.g_ret_sts_unexp_error OR
		 l_api_return_status = fnd_api.g_ret_sts_error THEN
		  If is_debug then
		     print_debug('error from cartonize api',
				 'Inv_Pick_Release_Pub.Pick_Release');
		     print_debug('error count ' || x_msg_count,
				 'Inv_Pick_Release_Pub.Pick_Release');
		     print_debug('error msg ' || x_msg_data,
				 'Inv_Pick_Release_Pub.Pick_Release');
		     x_return_status := fnd_api.g_ret_sts_error;
		  End If;
		ELSE  -- patchset J bulk picking
		  IF (WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= INV_RELEASE.G_J_RELEASE_LEVEL) THEN
		     IF (is_debug) THEN
			print_debug('PATCHSET J -- BULK PICKING --- START',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     END IF;
		     assign_pick_slip_number
		       (x_return_status	        => l_api_return_status,
			x_msg_count       	=> x_msg_count,
			x_msg_data        	=> x_msg_data,
			p_move_order_header_id  => l_mo_line_tbl(l_line_index).header_id,
			p_ps_mode               => l_print_mode,
			p_grouping_rule_id	=> p_grouping_rule_id,
			p_allow_partial_pick    => p_allow_partial_pick);

		     IF l_api_return_status = fnd_api.g_ret_sts_unexp_error OR
		       l_api_return_status = fnd_api.g_ret_sts_error THEN
			print_debug('error from assign_pick_slip_number api',
				    'Inv_Pick_Release_Pub.Pick_Release');
			print_debug('error count ' || x_msg_count,
				    'Inv_Pick_Release_Pub.Pick_Release');
			print_debug('error msg ' || x_msg_data,
				    'Inv_Pick_Release_Pub.Pick_Release');
			x_return_status := fnd_api.g_ret_sts_error;
		     END IF;
		     IF (is_debug) THEN
			print_debug('PATCHSET J -- BULK PICKING --- END',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     END IF;
		  END IF;
	       END IF;
	       EXIT;

	     ELSIF l_mo_line_tbl(l_line_index).header_id =
                   l_mo_line_tbl(l_mo_line_tbl.NEXT(l_line_index)).header_id THEN
                 l_line_index := l_mo_line_tbl.NEXT(l_line_index);  --Changed bug4102518;
	     ELSE
	       -- call cartonize API
	       If is_debug then
		  print_debug('calling cartonize api',
			      'Inv_Pick_Release_Pub.Pick_Release');
	       End If;

	       WMS_CARTNZN_PUB.cartonize
		 (
		  p_api_version           => 1,
		  p_init_msg_list         => fnd_api.g_false,
		  p_commit                => fnd_api.g_false,
		  p_validation_level      => fnd_api.g_valid_level_full,
		  x_return_status         => l_api_return_status,
		  x_msg_count             => x_msg_count,
		  x_msg_data              => x_msg_data,
		  p_out_bound             => 'Y',
		  p_org_id                => l_mo_line_tbl(l_line_index).organization_id,
		  p_move_order_header_id  => l_mo_line_tbl(l_line_index).header_id
		  );

	       IF l_api_return_status = fnd_api.g_ret_sts_unexp_error OR
		 l_api_return_status = fnd_api.g_ret_sts_error THEN
		  If is_debug then
		     print_debug('error from cartonize api',
				 'Inv_Pick_Release_Pub.Pick_Release');
		     print_debug('error count ' || x_msg_count,
				 'Inv_Pick_Release_Pub.Pick_Release');
		     print_debug('error msg ' || x_msg_data,
				 'Inv_Pick_Release_Pub.Pick_Release');
		  End If;
		  x_return_status := fnd_api.g_ret_sts_error;
		ELSE  -- patchset J bulk picking
		  IF (WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= INV_RELEASE.G_J_RELEASE_LEVEL) THEN
		     IF (is_debug) THEN
			print_debug('PATCHSET J -- BULK PICKING --- START',
				    'Inv_Pick_Release_Pub.Pick_Release');
			print_debug('calling assign_pick_slip_number',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     END IF;

		     assign_pick_slip_number
		       (x_return_status	        => l_api_return_status,
			x_msg_count       	=> x_msg_count,
			x_msg_data        	=> x_msg_data,
			p_move_order_header_id  => l_mo_line_tbl(l_line_index).header_id,
			p_ps_mode               => l_print_mode,
			p_grouping_rule_id	=> p_grouping_rule_id,
			p_allow_partial_pick    => p_allow_partial_pick);

		     IF l_api_return_status = fnd_api.g_ret_sts_unexp_error OR
		       l_api_return_status = fnd_api.g_ret_sts_error THEN
			print_debug('error from assign_pick_slip_number api',
				    'Inv_Pick_Release_Pub.Pick_Release');
			print_debug('error count ' || x_msg_count,
				    'Inv_Pick_Release_Pub.Pick_Release');
			print_debug('error msg ' || x_msg_data,
				    'Inv_Pick_Release_Pub.Pick_Release');
			x_return_status := fnd_api.g_ret_sts_error;
		     END IF;
		     IF (is_debug) THEN
			print_debug('PATCHSET J -- BULK PICKING --- END',
				    'Inv_Pick_Release_Pub.Pick_Release');
		     END IF;
		  END IF;
	       END IF;

	       IF is_debug THEN
		  print_debug('success from cartonize api',
			      'Inv_Pick_Release_Pub.Pick_Release');
	       END IF;
	       l_line_index := l_line_index + 1;
	    END IF;
	    EXIT WHEN l_line_index > l_mo_line_tbl.LAST;
	 END LOOP;
      END IF; -- Do cartonization?? --Added bug3237702
   END IF;  -- wms installed

   -- At this point, each Move Order Line has been processed.
   -- If automatic pick confirmation is chosen, call pick confirm now.
   IF l_auto_pick_confirm = 1 THEN
	NULL;
   END IF;

 -- Start Bug 6696594
IF INV_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 THEN
	FOR a IN l_mol_id_tbl.FIRST..l_mol_id_tbl.LAST
	LOOP
		IF (l_debug = 1) THEN
			print_debug('l_mol_id_tbl(a) ' || l_mol_id_tbl(a), 'Inv_Pick_Release_Pub.Pick_Release');
		END IF;

		FOR v_mmtt in c_mmtt (l_mol_id_tbl(a))
		LOOP
			IF (l_debug = 1) THEN
				print_debug('v_mmtt.transaction_temp_id ' || v_mmtt.transaction_temp_id, 'Inv_Pick_Release_Pub.Pick_Release');
			END IF;

			l_transaction_id(l_counter) := v_mmtt.transaction_temp_id;
			l_counter := l_counter + 1;
		END LOOP;
	END LOOP;

	BEGIN
		--Need to add logic to find out if cartonization is enabled or not, if yes, then find out if shipping content label is
		--enabled for Cartonization bussiness flow.

		--use p_skip_cartonization which is a variable passed to Pick_Release() to find if cartonization is enabled or not
		l_counter := 1;
		FOR b in l_transaction_id.first..l_transaction_id.last
		LOOP

			SELECT count (*) into honor_case_pick_count
			FROM mtl_material_transactions_temp mmtt, wms_user_task_type_attributes wutta
			WHERE mmtt.standard_operation_id = wutta.user_task_type_id
			AND mmtt.organization_id = wutta.organization_id
			AND mmtt.transaction_temp_id = l_transaction_id(b)
			AND honor_case_pick_flag = 'Y';

			IF (l_debug = 1) THEN
				print_debug('l_counter' || l_counter, 'Inv_Pick_Release_Pub.Pick_Release');
			END IF;

			IF honor_case_pick_count > 0 THEN
				v_transaction_id(l_counter) := l_transaction_id(b);
				l_counter := l_counter + 1;
			END IF;
		END LOOP;

		IF l_counter > 1 THEN
			l_return_status := fnd_api.g_ret_sts_success;

			inv_label.print_label (
				x_return_status      => l_return_status
				, x_msg_count          => x_msg_count
				, x_msg_data           => x_msg_data
				, x_label_status       => l_label_status
				, p_api_version        => 1.0
				, p_print_mode         => 1
				, p_business_flow_code => 42  --Business Flow Pick Release
				, p_transaction_id     => v_transaction_id);

			IF ( l_return_status <> fnd_api.g_ret_sts_success ) THEN
				IF (l_debug = 1) THEN
					print_debug('failed to print labels', 'Inv_Pick_Release_Pub.Pick_Release');
				END IF;
				fnd_message.set_name('WMS', 'WMS_PRINT_LABEL_FAIL');
				fnd_msg_pub.ADD;
			END IF;
		END IF;
	EXCEPTION
	WHEN OTHERS THEN
		IF (l_debug = 1) THEN
			print_debug('Exception occured while calling print_label', 'Inv_Pick_Release_Pub.Pick_Release');
		END IF;
		fnd_message.set_name('WMS', 'WMS_PRINT_LABEL_FAIL');
		fnd_msg_pub.ADD;
	END;
END IF;
--END Bug 6696594


   -- Call Device Integration API to send the details of this
   -- PickRelease Wave to devices, if it is a WMS organization.
   -- All the MoveOrderLines should have the same MO Header Id. So
   -- picking the FIRST line's Header Id
   -- Note: We don't check for the return condition of this API as
   -- we let the PickRelease process succeed whether DeviceIntegration
   -- succeeds or fails.
   IF l_wms_installed THEN
      WMS_DEVICE_INTEGRATION_PVT.device_request
	(p_bus_event      => WMS_DEVICE_INTEGRATION_PVT.WMS_BE_PICK_RELEASE,
	 p_call_ctx       => WMS_Device_integration_pvt.DEV_REQ_AUTO,
	 p_task_trx_id    => l_mo_line_tbl(l_mo_line_tbl.FIRST).header_id,
    -- Bug 6401204 Passing the Organization id as WCS API isn't called correctly
    p_org_id         => l_mo_line_tbl(l_mo_line_tbl.FIRST).organization_id,
	 x_request_msg    =>  l_req_msg,
	 x_return_status  =>  l_api_return_status,
	 x_msg_count      => x_msg_count,
	 x_msg_data       => x_msg_data
	 );
      IF is_debug THEN
	 print_debug('Device_API: return stat:'||l_api_return_status,
		     'PICKREL');
      END IF;
   END IF;

   -- Bug 2776309
   -- The below call should never backorder but if this
   -- happens then do not check l_cur_ship_model_id
   --IF l_cur_ship_model_id is not NULL then
   --2509322
   backorder_smc_details(l_api_return_status,
			 x_msg_data,
			 x_msg_count);
   IF l_api_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   -- END IF;

   --bug 2408329: Since Quantity trees are cached and not built in a pick release
   --session, available qty seen is wrong during a blanket pick release.
   --Now Clear_cache after pick release so as to ensure when new locks are
   --obtained, the tree is built with latest db state.
   inv_quantity_tree_grp.clear_quantity_cache;

   -- Bug# 4258360: For allocation modes of I (Inventory Only) or
   -- X (Prioritize Crossdock), allocation (both from inventory and crossdock)
   -- has completed.  We need to remove the backordered lines from
   -- p_trolin_delivery_ids and p_del_detail_id tables so deliveries are not
   -- autocreated for them later on by Shipping.
   -- UPDATE: Do not need to do this logic anymore.  Shipping does not populate the delivery
   -- tables inputted.  Those are only used to store crossdocked lines for creation of deliveries.
   -- {{
   -- Run PR in Inventory Only mode and ensure no delivery exists for WDD
   -- Also ensure that the WDD is not allocated. After PR completes
   -- WDD should be back ordered and no delivery should exist for it.
   -- }}
   -- {{
   -- Run PR in Prioritize Xdock mode and ensure no delivery exists for WDD
   -- Also ensure that the WDD is not allocated. After PR completes
   -- WDD should be back ordered and no delivery should exist for it.
   -- }}
   /*IF (l_allocation_method IN (g_inventory_only, g_prioritize_crossdock) AND
       p_del_detail_id.COUNT > 0) THEN
      IF (is_debug) THEN
	 print_debug('Remove the backordered WDD lines from the inputted delivery tables: ' ||
		     l_allocation_method, 'Inv_Pick_Release_Pub.Pick_Release');
      END IF;
      l_xdock_index := p_del_detail_id.FIRST;
      l_xdock_next_index := p_del_detail_id.FIRST;
      -- Loop through table p_del_detail_id.  If that WDD is backordered (value exists in
      -- l_backordered_wdd_tbl), then delete that entry from p_del_detail_id and the corresponding
      -- one in p_trolin_delivery_ids.
      LOOP
	 l_xdock_index := l_xdock_next_index;
	 l_xdock_next_index := p_del_detail_id.NEXT(l_xdock_next_index);
	 -- Exit out of loop when l_xdock_index is null, meaning we have
	 -- reached the last entry in the table.
	 EXIT WHEN l_xdock_index IS NULL;

	 IF (l_backordered_wdd_tbl.EXISTS(p_del_detail_id(l_xdock_index))) THEN
	    p_del_detail_id.DELETE(l_xdock_index);
	    p_trolin_delivery_ids.DELETE(l_xdock_index);
	 END IF;
      END LOOP;
   END IF;*/

   -- Bug# 4258360: For allocation modes of N (Prioritize Inventory), call the
   -- Crossdock Pegging API here since inventory allocation has been completed
   IF (l_allocation_method = g_prioritize_inventory) THEN
      IF (is_debug) THEN
	 print_debug('Call the Planned_Cross_Dock API (Prioritize Inventory)',
		     'Inv_Pick_Release_Pub.Pick_Release');
      END IF;
      WMS_XDOCK_PEGGING_PUB.Planned_Cross_Dock
	(p_api_version		=> 1.0,
	 p_init_msg_list	=> fnd_api.g_false,
	 p_commit		=> fnd_api.g_false,
	 x_return_status        => l_api_return_status,
	 x_msg_count            => x_msg_count,
	 x_msg_data             => x_msg_data,
	 p_batch_id             => INV_CACHE.wpb_rec.batch_id,
	 p_wsh_release_table    => p_wsh_release_table,
	 p_trolin_delivery_ids  => p_trolin_delivery_ids,
	 p_del_detail_id        => p_del_detail_id);

      IF (l_api_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	 IF (is_debug) THEN
	    print_debug('Success returned from Planned_Cross_Dock API',
			'Inv_Pick_Release_Pub.Pick_Release');
	 END IF;
       ELSIF (l_api_return_status = FND_API.G_RET_STS_ERROR) THEN
	 IF (is_debug) THEN
	    print_debug('Error returned from Planned_Cross_Dock API',
			'Inv_Pick_Release_Pub.Pick_Release');
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (l_api_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	 IF (is_debug) THEN
	    print_debug('Unexpected error returned from Planned_Cross_Dock API',
			'Inv_Pick_Release_Pub.Pick_Release');
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- Standard call to commit
   IF p_commit = fnd_api.g_true THEN
      COMMIT;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   IF is_debug THEN
      print_Debug('x_return_status is ' || x_return_status,
		  'Inv_Pick_Release_Pub.Pick_Release');
   END IF;

   inv_cache.mo_transaction_date := NULL;
   l_return_value := inv_cache.set_pick_release(FALSE); --Added bug3237702
   inv_log_util.g_maintain_log_profile := FALSE;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      --
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_return_value := inv_cache.set_pick_release(FALSE); --Added bug3237702
      inv_log_util.g_maintain_log_profile := TRUE;
      --
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
      --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_return_value := inv_cache.set_pick_release(FALSE); --Added bug3237702
      inv_log_util.g_maintain_log_profile := TRUE;
      --
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
      --
   WHEN OTHERS THEN
      IF is_debug THEN
         print_Debug('Other error: ' || sqlerrm,
                     'Inv_Pick_Release_Pub.Pick_Release');
      END IF;

      ROLLBACK TO Pick_Release_PUB;
      --
      l_return_value := inv_cache.set_pick_release(FALSE); --Added bug3237702
      inv_log_util.g_maintain_log_profile := TRUE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      --
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				, p_data => x_msg_data);
END Pick_Release;


-- Start of Comments
-- API name 	Reserve_Unconfirmed_Quantity
-- Type		Public
--
-- Purpose
--   Transfers a reservation on material which is missing or damaged to an
-- 	    appropriate demand source.
--
-- Input Parameters
--   p_missing_quantity
--       The quantity to be transferred to a Cycle Count reservation, in the primary
--	    UOM for the item.
--	p_organization_id
--	    The organization in which the reservation(s) should be created
--	p_reservation_id
--	    The reservation to transfer quantity from (not required if demand source
--	    parameters are given).
--	p_demand_source_type_id
--	    The demand source type ID for the reservation to be transferred
--   p_demand_source_header_id
--	    The demand source header ID for the reservation to be transferred
--	p_demand_source_line_id
--	    The demand source line ID for the reservation to be transferred
--	p_inventory_item_id
--	    The item which is missing or damaged.
--	p_subinventory_code
--	    The subinventory in which the material is missing or damaged.
--   p_locator_id
--	    The locator in which the material is missing or damaged.
--	p_revision
--	    The revision of the item which is missing or damaged.
--	p_lot_number
--	    The lot number of the item which is missing or damaged.
--
-- Output Parameters
--   x_return_status
--       if the pick release process succeeds, the value is
--			fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--             fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--             fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--       	in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   (See fnd_api package for more details about the above output parameters)
--

-- HW INVCONV added p_missing_quantity2

PROCEDURE Reserve_Unconfirmed_Quantity
  (
      p_api_version			IN  	NUMBER
      ,p_init_msg_list			IN  	VARCHAR2 DEFAULT fnd_api.g_false
      ,p_commit				IN	VARCHAR2 DEFAULT fnd_api.g_false
      ,x_return_status        		OUT 	NOCOPY VARCHAR2
      ,x_msg_count            		OUT 	NOCOPY NUMBER
      ,x_msg_data             		OUT 	NOCOPY VARCHAR2
      ,p_missing_quantity		IN	NUMBER
      ,p_missing_quantity2		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_reservation_id			IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_demand_source_header_id	IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_demand_source_line_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_organization_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_inventory_item_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_subinventory_code		IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
      ,p_locator_id			IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_revision			IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
      ,p_lot_number			IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
  ) IS
      l_api_version	CONSTANT NUMBER := 1.0;
      l_api_name	CONSTANT VARCHAR2(30) := 'Reserve_Unconfirmed_Quantity';

      l_reservation_id		NUMBER;	-- The reservation to transfer quantity from
					-- If invoked at Pick Confirm, this will
					-- typically be passed in as a parameter,
					-- based on the reservation tied to the Move
					-- Order Line Detail which is being Pick
					-- Confirmed.  If invoked at Ship Confirm,
					-- this will most likely be derived from the
					-- demand and supply source parameters.
      l_reservation_rec		INV_Reservation_GLOBAL.MTL_RESERVATION_REC_TYPE;
					-- Temporary reservation record for retrieving
					-- the reservation to transfer.
      l_reservation_count	NUMBER;	-- The number of reservations which match the
					-- demand/supply source parameters passed in.
      l_cc_reservation_rec	INV_Reservation_GLOBAL.MTL_RESERVATION_REC_TYPE;
					-- Temporary reservation record for the amount
					-- to be transferred to Cycle Count.
      l_reservations_tbl	INV_Reservation_GLOBAL.MTL_RESERVATION_TBL_TYPE;
					-- The table of reservations for given
					-- supply and demand source
      l_dummy_sn  		INV_Reservation_GLOBAL.SERIAL_NUMBER_TBL_TYPE;
      l_new_rsv_id		NUMBER;	-- The reservation ID that has been transferred
					-- to or updated
      l_mso_header_id		NUMBER; -- The header ID for the record in
					-- MTL_SALES_ORDERS that corresponds to the OE
					-- header and line passed in.
      l_api_return_status	VARCHAR2(1);
					-- The return status of APIs called
					-- within this API.
      l_api_error_code		NUMBER; -- The error code of APIs called within
					-- this API.
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Set savepoint for this API
   SAVEPOINT Reserve_Unconfirmed_Qty_PUB;

   -- Standard Call to check for call compatibility
   IF NOT fnd_api.Compatible_API_Call(l_api_version
				      , p_api_version
				      , l_api_name
				      , G_PKG_NAME) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to true
   IF fnd_api.to_Boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   -- Validate parameters

   -- First make sure that missing quantity is not <= 0
   IF p_missing_quantity <= 0 THEN
      FND_MESSAGE.SET_NAME('INV','INV_NO_QTY_TO_TRANSFER');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Determine whether the reservation id was given, or if it must be derived
   -- based on the supply source parameters.
   IF p_reservation_id <> fnd_api.g_miss_num AND
      p_reservation_id IS NOT NULL THEN
     -- Initialize the reservation querying record with the reservation ID
     l_reservation_id := p_reservation_id;
     l_reservation_rec.reservation_id := l_reservation_id;
   ELSE
     -- Initialize the reservation record with the demand/supply source
     -- information.  At minimum, must have a demand source type, line and header,
     -- and an item and organization ID
     IF	p_inventory_item_id = fnd_api.g_miss_num OR
	p_inventory_item_id IS NULL OR
	p_organization_id = fnd_api.g_miss_num OR
	p_organization_id IS NULL OR
	p_demand_source_header_id = fnd_api.g_miss_num OR
	p_demand_source_header_id IS NULL OR
	p_demand_source_line_id = fnd_api.g_miss_num OR
	p_demand_source_line_id IS NULL THEN
          FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_ID_RSV');
	  FND_MSG_PUB.Add;
	  RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- First attempt to convert the demand source header id given
     -- (the OE header id) to the MTL_SALES_ORDERS id to be used.
     /*l_mso_header_id :=
	inv_salesorder.get_salesorder_for_oeheader(p_demand_source_header_id);
     IF l_mso_header_id IS NULL THEN
	FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_GET_MSO_HEADER');
	FND_MSG_PUB.Add;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;*/

     l_reservation_rec.inventory_item_id := p_inventory_item_id;
     l_reservation_rec.organization_id := p_organization_id;
     l_reservation_rec.demand_source_type_id :=
			INV_Reservation_GLOBAL.g_source_type_oe;
     l_reservation_rec.demand_source_header_id := p_demand_source_header_id;
     l_reservation_rec.demand_source_line_id := p_demand_source_line_id;
     -- R12 Crossdock changes
     l_reservation_rec.demand_source_line_detail := NULL;

     IF p_subinventory_code <> fnd_api.g_miss_char THEN
	l_reservation_rec.subinventory_code := p_subinventory_code;
     ELSE
	l_reservation_rec.subinventory_code := NULL;
     END IF;

     IF p_locator_id <> fnd_api.g_miss_num THEN
	l_reservation_rec.locator_id := p_locator_id;
     ELSE
	l_reservation_rec.locator_id := NULL;
     END IF;

     IF p_revision <> fnd_api.g_miss_char THEN
	l_reservation_rec.revision := p_revision;
     ELSE
	l_reservation_rec.revision := NULL;
     END IF;

     IF p_lot_number <> fnd_api.g_miss_char THEN
	l_reservation_rec.lot_number := p_lot_number;
     ELSE
	l_reservation_rec.lot_number := NULL;
     END IF;
   END IF;

   -- Retrieve the reservation information
   INV_Reservation_PUB.Query_Reservation
   (
	p_api_version_number		=> 1.0
	, p_init_msg_lst		=> fnd_api.g_false
	, x_return_status		=> l_api_return_status
	, x_msg_count			=> x_msg_count
	, x_msg_data			=> x_msg_data
	, p_query_input			=> l_reservation_rec
	, x_mtl_reservation_tbl		=> l_reservations_tbl
	, x_mtl_reservation_tbl_count	=> l_reservation_count
	, x_error_code			=> l_api_error_code
   );
   -- Return an error if the query reservations call failed
   IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
      FND_MESSAGE.SET_NAME('INV','INV_QRY_RSV_FAILED');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Only 1 reservation record should have been returned, since the parameters
   -- passed are supposed to uniquely identify a reservation record.
   IF l_reservation_count = 0 THEN
      FND_MESSAGE.SET_NAME('INV','INV_NO_RSVS_FOUND');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF l_reservation_count > 1 THEN
      FND_MESSAGE.SET_NAME('INV','INV_NON_UNIQUE_RSV');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Determine whether the quantity to transfer is greater
   -- than the currently reserved quantity
   IF p_missing_quantity > l_reservations_tbl(1).primary_reservation_quantity THEN
      FND_MESSAGE.SET_NAME('INV','INV_INSUFF_QTY_RSV');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize the querying record with the reservation ID so that the update
   -- will be more efficient.
   l_reservation_rec.reservation_id := l_reservations_tbl(1).reservation_id;

   -- Validation complete - ready to transfer reservation to appropriate source
   l_cc_reservation_rec.primary_reservation_quantity := p_missing_quantity;
   l_cc_reservation_rec.primary_uom_code := l_reservations_tbl(1).primary_uom_code;
   l_cc_reservation_rec.detailed_quantity := 0;
   l_cc_reservation_rec.demand_source_type_id := 9;
-- HW INVCONV
   l_cc_reservation_rec.secondary_reservation_quantity := p_missing_quantity2;
   l_cc_reservation_rec.secondary_uom_code := l_reservations_tbl(1).secondary_uom_code;
   l_cc_reservation_rec.secondary_detailed_quantity := 0;
-- End of HW INVCONV
   l_cc_reservation_rec.demand_source_header_id := -1;
   l_cc_reservation_rec.demand_source_line_id := -1;
   -- R12 Crossdock changes
   l_cc_reservation_rec.demand_source_line_detail := -1;

   l_cc_reservation_rec.subinventory_code := p_subinventory_code;
	 l_cc_reservation_rec.locator_id := p_locator_id;
   l_cc_reservation_rec.revision := p_revision;
   l_cc_reservation_rec.lot_number := p_lot_number;

   -- Make the call to the Transfer Reservation API
   INV_Reservation_PUB.Transfer_Reservation
   (
	p_api_version_number          => 1.0
	, p_init_msg_lst              => fnd_api.g_true
	, x_return_status             => l_api_return_status
	, x_msg_count                 => x_msg_count
	, x_msg_data                  => x_msg_data
	, p_original_rsv_rec          => l_reservation_rec
	, p_to_rsv_rec                => l_cc_reservation_rec
	, p_original_serial_number    => l_dummy_sn
	, p_to_serial_number          => l_dummy_sn
	, p_validation_flag           => fnd_api.g_true
	, x_to_reservation_id         => l_new_rsv_id
   );
   -- Return an error if the transfer reservations call failed
   IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
      FND_MESSAGE.SET_NAME('INV','INV_TRANSFER_RSV_FAILED');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Commit if necessary
   IF x_return_status <> fnd_api.g_ret_sts_success THEN
     ROLLBACK TO Reserve_Unconfirmed_Qty_PUB;
   ELSE
     -- Standard call to commit
     IF p_commit = fnd_api.g_true THEN
       COMMIT;
     END IF;
   END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     	--
     	x_return_status := FND_API.G_RET_STS_ERROR;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     	   , p_data => x_msg_data);
     	--
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     	--
     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     	   , p_data => x_msg_data);
     	--
     WHEN OTHERS THEN
	ROLLBACK TO Reserve_Unconfirmed_Qty_PUB;
     	--
     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	--
     	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     	END IF;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     	   , p_data => x_msg_data);
END Reserve_Unconfirmed_Quantity;


PROCEDURE call_cartonization (
         p_api_version              IN   NUMBER
         , p_init_msg_list          IN   VARCHAR2
         , p_commit                 IN   VARCHAR2
         , p_validation_level       IN   NUMBER
         , x_return_status          OUT NOCOPY VARCHAR2
         , x_msg_count              OUT NOCOPY NUMBER
         , x_msg_data               OUT NOCOPY VARCHAR2
         , p_out_bound              IN   VARCHAR2
         , p_org_id                 IN   NUMBER
         , p_move_order_header_id   IN   NUMBER
         , p_grouping_rule_id       IN   NUMBER
         , p_allow_partial_pick     IN   VARCHAR2
) IS

l_print_mode     VARCHAR(1);
l_debug          NUMBER;
l_api_return_status    VARCHAR2(1);
l_do_cartonization number := NVL(FND_PROFILE.VALUE('WMS_ASSIGN_TASK_TYPE'),1);

BEGIN
   -- Set savepoint for this API
   SAVEPOINT PR_Call_cartonization;

   -- because the debug profile  rarely changes, only check it once per
   -- session, instead of once per batch
   IF is_debug IS NULL THEN
     l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     if l_debug = 1 then
       is_debug := TRUE;
     else
       is_debug := FALSE;
     end if;
   END IF;

   IF l_do_cartonization = 1 THEN
   -- Determine what printing mode to use when pick releasing lines.
   IF g_organization_id IS NOT NULL AND
      g_organization_id = p_org_id AND
      g_print_mode IS NOT NULL THEN

     l_print_mode := g_print_mode;
   ELSE

    BEGIN
      SELECT print_pick_slip_mode, pick_grouping_rule_id
      INTO l_print_mode, g_org_grouping_rule_id
      FROM WSH_SHIPPING_PARAMETERS
      WHERE organization_id = p_org_id;
    EXCEPTION
      WHEN no_data_found THEN
        If is_debug then
          print_debug('Error: print_pick_slip_mode not defined',
                     'INV_Pick_Release_Pub.Pick_Release');
        End If;
        --ROLLBACK TO Pick_Release_PUB;
        FND_MESSAGE.SET_NAME('INV','INV_WSH_ORG_NOT_FOUND');
        FND_MSG_PUB.Add;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

     g_organization_id := p_org_id;
     g_print_mode := l_print_mode;
   END IF;

   -- call cartonize API
   If is_debug then
      print_debug('calling cartonize api',
                   'Inv_Pick_Release_Pub.Pick_Release');
   End If;

   IF p_move_order_header_id <> -1 and  p_move_order_header_id <> 0 and p_move_order_header_id IS NOT NULL THEN
	update mtl_material_transactions_temp
        set lock_flag = NULL
        where move_order_header_id  = p_move_order_header_id
        and organization_id = p_org_id
        and lock_flag is not null;
   END IF;

   WMS_CARTNZN_PUB.cartonize
        (
         p_api_version           => 1,
         p_init_msg_list         => fnd_api.g_false,
         p_commit                => fnd_api.g_false,
         p_validation_level      => fnd_api.g_valid_level_full,
         x_return_status         => l_api_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_out_bound             => 'Y',
         p_org_id          => p_org_id,
         p_move_order_header_id  => p_move_order_header_id
   );
   IF l_api_return_status = fnd_api.g_ret_sts_unexp_error OR
       l_api_return_status = fnd_api.g_ret_sts_error THEN
      If is_debug then
         print_debug('error from cartonize api',
                  'Inv_Pick_Release_Pub.Call_Cartonization');
         print_debug('error count ' || x_msg_count,
                  'Inv_Pick_Release_Pub.Call_Cartonization');
         print_debug('error msg ' || x_msg_data,
                  'Inv_Pick_Release_Pub.Call_Cartonization');
      End If;
      x_return_status := fnd_api.g_ret_sts_error;
   ELSE
      IF (is_debug) THEN print_debug('PATCHSET J -- BULK PICKING --- START',
                                'Inv_Pick_Release_Pub.Call_Cartonization');
                    print_debug('calling assign_pick_slip_number',
                                'Inv_Pick_Release_Pub.Call_Cartonization');
      END IF;
      assign_pick_slip_number(
                x_return_status         => l_api_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_move_order_header_id  => p_move_order_header_id,
                p_ps_mode            => l_print_mode,
                p_grouping_rule_id  => p_grouping_rule_id,
                p_allow_partial_pick => p_allow_partial_pick);
      IF l_api_return_status = fnd_api.g_ret_sts_unexp_error OR
                l_api_return_status = fnd_api.g_ret_sts_error THEN
                print_debug('error from assign_pick_slip_number api',
                            'Inv_Pick_Release_Pub.Call_Cartonization');
                print_debug('error count ' || x_msg_count,
                            'Inv_Pick_Release_Pub.Call_Cartonization');
                print_debug('error msg ' || x_msg_data,
                            'Inv_Pick_Release_Pub.Call_Cartonization');
                x_return_status := fnd_api.g_ret_sts_error;
      END IF;
   END IF;

   If is_debug then
     print_debug('success from cartonize api',
               'Inv_Pick_Release_Pub.Call_Cartonization');
   End If;
   END IF; --l_do_Cartonization=1
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        --
        x_return_status := FND_API.G_RET_STS_ERROR;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);
        --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);
        --
     WHEN OTHERS THEN
        ROLLBACK TO PR_Call_cartonization;
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Call_Cartonization');
        END IF;
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
           , p_data => x_msg_data);
END call_cartonization;

/* Bug 7504490* - Added the procedure Reserve_Unconfqty_lpn. This procedure transfers the reservation
   of the remaining quantity (task qty-picked qty) to cycle count reservation and ensures that the
   lpn_id is stamped on the reservation if the task was for an allocated lpn. This is similar to the
   Reserve_unconfirmed_quantity API except for passing the lpn_id to the reservation record. */

PROCEDURE Reserve_Unconfqty_lpn
  (
       p_api_version			IN  	NUMBER
      ,p_init_msg_list			IN  	VARCHAR2 DEFAULT fnd_api.g_false
      ,p_commit				IN	VARCHAR2 DEFAULT fnd_api.g_false
      ,x_return_status        		OUT 	NOCOPY VARCHAR2
      ,x_msg_count            		OUT 	NOCOPY NUMBER
      ,x_msg_data             		OUT 	NOCOPY VARCHAR2
      ,x_new_rsv_id                     OUT     NOCOPY NUMBER -- bug8301348
      ,p_missing_quantity		IN	NUMBER
      ,p_secondary_missing_quantity     IN      NUMBER DEFAULT NULL  /*9251210*/
      ,p_reservation_id			IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_demand_source_header_id	IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_demand_source_line_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_organization_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_inventory_item_id		IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_subinventory_code		IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
      ,p_locator_id			IN	NUMBER DEFAULT fnd_api.g_miss_num
      ,p_revision			IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
      ,p_lot_number			IN	VARCHAR2 DEFAULT fnd_api.g_miss_char
      ,p_lpn_id                         IN	NUMBER DEFAULT fnd_api.g_miss_num
  ) IS
      l_api_version	CONSTANT NUMBER := 1.0;
      l_api_name	CONSTANT VARCHAR2(30) := 'Reserve_Unconfirmed_Quantity';

      l_reservation_id		NUMBER;	-- The reservation to transfer quantity from
					-- If invoked at Pick Confirm, this will
					-- typically be passed in as a parameter,
					-- based on the reservation tied to the Move
					-- Order Line Detail which is being Pick
					-- Confirmed.  If invoked at Ship Confirm,
					-- this will most likely be derived from the
					-- demand and supply source parameters.
      l_reservation_rec		INV_Reservation_GLOBAL.MTL_RESERVATION_REC_TYPE;
					-- Temporary reservation record for retrieving
					-- the reservation to transfer.
      l_reservation_count	NUMBER;	-- The number of reservations which match the
					-- demand/supply source parameters passed in.
      l_cc_reservation_rec	INV_Reservation_GLOBAL.MTL_RESERVATION_REC_TYPE;
					-- Temporary reservation record for the amount
					-- to be transferred to Cycle Count.
      l_reservations_tbl	INV_Reservation_GLOBAL.MTL_RESERVATION_TBL_TYPE;
					-- The table of reservations for given
					-- supply and demand source
      l_dummy_sn  		INV_Reservation_GLOBAL.SERIAL_NUMBER_TBL_TYPE;
      l_new_rsv_id		NUMBER;	-- The reservation ID that has been transferred
					-- to or updated
      l_mso_header_id		NUMBER; -- The header ID for the record in
					-- MTL_SALES_ORDERS that corresponds to the OE
					-- header and line passed in.
      l_api_return_status	VARCHAR2(1);
					-- The return status of APIs called
					-- within this API.
      l_api_error_code		NUMBER; -- The error code of APIs called within
					-- this API.
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Set savepoint for this API
   SAVEPOINT Reserve_Unconfirmed_Qty_PUB;

   -- Standard Call to check for call compatibility
   IF NOT fnd_api.Compatible_API_Call(l_api_version
				      , p_api_version
				      , l_api_name
				      , G_PKG_NAME) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to true
   IF fnd_api.to_Boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   -- Validate parameters

   -- First make sure that missing quantity is not <= 0
   IF p_missing_quantity <= 0 THEN
      FND_MESSAGE.SET_NAME('INV','INV_NO_QTY_TO_TRANSFER');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Determine whether the reservation id was given, or if it must be derived
   -- based on the supply source parameters.
   IF p_reservation_id <> fnd_api.g_miss_num AND
      p_reservation_id IS NOT NULL THEN
     -- Initialize the reservation querying record with the reservation ID
     l_reservation_id := p_reservation_id;
     l_reservation_rec.reservation_id := l_reservation_id;
   ELSE
     -- Initialize the reservation record with the demand/supply source
     -- information.  At minimum, must have a demand source type, line and header,
     -- and an item and organization ID
     IF	p_inventory_item_id = fnd_api.g_miss_num OR
	p_inventory_item_id IS NULL OR
	p_organization_id = fnd_api.g_miss_num OR
	p_organization_id IS NULL OR
	p_demand_source_header_id = fnd_api.g_miss_num OR
	p_demand_source_header_id IS NULL OR
	p_demand_source_line_id = fnd_api.g_miss_num OR
	p_demand_source_line_id IS NULL THEN
          FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_ID_RSV');
	  FND_MSG_PUB.Add;
	  RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- First attempt to convert the demand source header id given
     -- (the OE header id) to the MTL_SALES_ORDERS id to be used.
     /*l_mso_header_id :=
	inv_salesorder.get_salesorder_for_oeheader(p_demand_source_header_id);
     IF l_mso_header_id IS NULL THEN
	FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_GET_MSO_HEADER');
	FND_MSG_PUB.Add;
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;*/

     l_reservation_rec.inventory_item_id := p_inventory_item_id;
     l_reservation_rec.organization_id := p_organization_id;
     l_reservation_rec.demand_source_type_id :=
			INV_Reservation_GLOBAL.g_source_type_oe;
     l_reservation_rec.demand_source_header_id := p_demand_source_header_id;
     l_reservation_rec.demand_source_line_id := p_demand_source_line_id;

     IF p_subinventory_code <> fnd_api.g_miss_char THEN
	l_reservation_rec.subinventory_code := p_subinventory_code;
     ELSE
	l_reservation_rec.subinventory_code := NULL;
     END IF;

     IF p_locator_id <> fnd_api.g_miss_num THEN
	l_reservation_rec.locator_id := p_locator_id;
     ELSE
	l_reservation_rec.locator_id := NULL;
     END IF;

     IF p_revision <> fnd_api.g_miss_char THEN
	l_reservation_rec.revision := p_revision;
     ELSE
	l_reservation_rec.revision := NULL;
     END IF;

     IF p_lot_number <> fnd_api.g_miss_char THEN
	l_reservation_rec.lot_number := p_lot_number;
     ELSE
	l_reservation_rec.lot_number := NULL;
     END IF;

     /* Bug 7504490 - Checking for the allocated_lpn_id passed */
     IF p_lpn_id <> fnd_api.g_miss_char THEN
	l_reservation_rec.lpn_id := p_lpn_id;
     ELSE
	l_reservation_rec.lpn_id := NULL;
     END IF;
   END IF;

   -- Retrieve the reservation information
   INV_Reservation_PUB.Query_Reservation
   (
	p_api_version_number		=> 1.0
	, p_init_msg_lst		=> fnd_api.g_false
	, x_return_status		=> l_api_return_status
	, x_msg_count			=> x_msg_count
	, x_msg_data			=> x_msg_data
	, p_query_input			=> l_reservation_rec
	, x_mtl_reservation_tbl		=> l_reservations_tbl
	, x_mtl_reservation_tbl_count	=> l_reservation_count
	, x_error_code			=> l_api_error_code
   );
   -- Return an error if the query reservations call failed
   IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
      FND_MESSAGE.SET_NAME('INV','INV_QRY_RSV_FAILED');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Only 1 reservation record should have been returned, since the parameters
   -- passed are supposed to uniquely identify a reservation record.
   IF l_reservation_count = 0 THEN
      FND_MESSAGE.SET_NAME('INV','INV_NO_RSVS_FOUND');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF l_reservation_count > 1 THEN
      FND_MESSAGE.SET_NAME('INV','INV_NON_UNIQUE_RSV');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Determine whether the quantity to transfer is greater
   -- than the currently reserved quantity
   IF p_missing_quantity > l_reservations_tbl(1).primary_reservation_quantity THEN
      FND_MESSAGE.SET_NAME('INV','INV_INSUFF_QTY_RSV');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize the querying record with the reservation ID so that the update
   -- will be more efficient.
   l_reservation_rec.reservation_id := l_reservations_tbl(1).reservation_id;

   -- Validation complete - ready to transfer reservation to appropriate source
   l_cc_reservation_rec.primary_reservation_quantity := p_missing_quantity;
   l_cc_reservation_rec.primary_uom_code := l_reservations_tbl(1).primary_uom_code;
   l_cc_reservation_rec.secondary_reservation_quantity := p_secondary_missing_quantity ; --9251213
   l_cc_reservation_rec.detailed_quantity := 0;
   l_cc_reservation_rec.secondary_detailed_quantity := 0; --9251213
   l_cc_reservation_rec.demand_source_type_id := 9;
   l_cc_reservation_rec.demand_source_header_id := -1;
   l_cc_reservation_rec.demand_source_line_id := -1;
   l_cc_reservation_rec.subinventory_code := p_subinventory_code;
   l_cc_reservation_rec.locator_id := p_locator_id;
   l_cc_reservation_rec.revision := p_revision;
   l_cc_reservation_rec.lot_number := p_lot_number;
   /* Bug 7504490 - passing the lpn_id to the CC reservation record. */
   l_cc_reservation_rec.lpn_id := p_lpn_id;

   -- Make the call to the Transfer Reservation API
   INV_Reservation_PUB.Transfer_Reservation
   (
	p_api_version_number          => 1.0
	, p_init_msg_lst              => fnd_api.g_true
	, x_return_status             => l_api_return_status
	, x_msg_count                 => x_msg_count
	, x_msg_data                  => x_msg_data
	, p_original_rsv_rec          => l_reservation_rec
	, p_to_rsv_rec                => l_cc_reservation_rec
	, p_original_serial_number    => l_dummy_sn
	, p_to_serial_number          => l_dummy_sn
	, p_validation_flag           => fnd_api.g_true
	, x_to_reservation_id         => l_new_rsv_id
   );
   -- Return an error if the transfer reservations call failed
   IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
      FND_MESSAGE.SET_NAME('INV','INV_TRANSFER_RSV_FAILED');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   x_new_rsv_id := l_new_rsv_id ; --Bug#8301348
   -- Commit if necessary
   IF x_return_status <> fnd_api.g_ret_sts_success THEN
     ROLLBACK TO Reserve_Unconfirmed_Qty_PUB;
   ELSE
     -- Standard call to commit
     IF p_commit = fnd_api.g_true THEN
       COMMIT;
     END IF;
   END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     	--
     	x_return_status := FND_API.G_RET_STS_ERROR;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     	   , p_data => x_msg_data);
     	--
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     	--
     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     	   , p_data => x_msg_data);
     	--
     WHEN OTHERS THEN
	ROLLBACK TO Reserve_Unconfirmed_Qty_PUB;
     	--
     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	--
     	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     	END IF;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
     	   , p_data => x_msg_data);
END Reserve_Unconfqty_lpn;


END INV_Pick_Release_PUB;

/
