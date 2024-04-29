--------------------------------------------------------
--  DDL for Package Body WMS_RETURN_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RETURN_SV" AS
/* $Header: WMSRETNB.pls 120.6.12010000.11 2013/02/22 09:57:50 ssingams ship $ */

PROCEDURE print_debug(p_err_msg VARCHAR2, p_level NUMBER default 4) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'WMS_RETURN_SV',
      p_level => p_level);

END print_debug;

PROCEDURE maintain_move_orders(
    p_group_id         IN  NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER) IS

    CURSOR c_create_mo IS
       SELECT rt.organization_id
	    , rt.po_line_location_id
	    , rt.shipment_line_id
	    , rt.oe_order_line_id
	    , rt.lpn_id
	    , rt.transfer_lpn_id
            , rsl.item_id
	    , rsl.item_revision
	    , rt.quantity
	    , rt.unit_of_measure
	    , rt.transaction_type
            , rt.interface_transaction_id
	    , rt.destination_type_code
	    , rt.parent_transaction_id
	    --, rsl.shipment_line_id
	    --, poll.receiving_routing_id routing_id
	    , msi.lot_control_code
	    , DECODE(MSI.RETURN_INSPECTION_REQUIREMENT,1,'Y','N') INSPECTION_REQUIRED_FLAG
	    , rsl.from_organization_id
            , rsl.asn_line_flag
	 FROM rcv_shipment_lines rsl
	    , mtl_system_items msi
	    , rcv_transactions rt
	WHERE rt.group_id = p_group_id
	  AND (rt.transaction_type = 'CORRECT'
	       -- return to receiving is also created for a rtv/rtc txn.
	       -- from inventory. But for that we dont want to create
	       -- a move order so should eliminate those txns.
	       -- Those txns. will not have a transfer_lpn_id stamped
	       -- but the pure return_to_receiving txns. will have
	       -- destination_type_code = 'INVENTORY' unlike the pure
	       -- ones which will have destination_type_code = 'RECEIVING'
	       OR (rt.transaction_type = 'RETURN TO RECEIVING'
		   AND rt.destination_type_code = 'RECEIVING'))
          AND rt.user_entered_flag = 'Y'
	  AND rsl.shipment_line_id = rt.shipment_line_id
	  AND msi.inventory_item_id = rsl.item_id
	  AND msi.organization_id = rt.organization_id;

    CURSOR c_rt_for_mo_udpate IS
       SELECT rsl.item_id
	    , rt.po_line_location_id
	    , rt.shipment_line_id
	    , rt.oe_order_line_id
	    , rt.quantity rt_quantity
	    , rt.transaction_id
            , rt.interface_transaction_id
	    , rt.lpn_id
	    , rt.transfer_lpn_id
	    , rt.primary_unit_of_measure
	    , rt.unit_of_measure
	    , rt.organization_id
   	    , mtlt.lot_number
	    , mtlt.transaction_quantity
	    , rt.transaction_type
	    , rt.parent_transaction_id
	    , rsl.asn_line_flag
	    , DECODE(MSI.RETURN_INSPECTION_REQUIREMENT,1,'Y','N') INSPECTION_REQUIRED_FLAG
	 FROM mtl_transaction_lots_temp mtlt
	    , rcv_shipment_lines rsl
	    , rcv_transactions rt
	    , mtl_system_items msi
	WHERE rt.group_id = p_group_id
	  AND (mtlt.transaction_temp_id (+) = rt.interface_transaction_id
	       -- Since mtlt is deleted for a correction record for a
	       -- deliver transaction, that record should be selected
	       -- from the union. So eliminating the selection of that
	       -- record from this part of the union.
	       AND NOT (rt.quantity > 0
			AND rt.transaction_type = 'CORRECT'
			AND msi.lot_control_code = 2
		        AND exists (SELECT 1
				      FROM rcv_transactions rt1
				     WHERE rt1.transaction_id = rt.parent_transaction_id
				       AND rt1.transaction_type = 'DELIVER')))
	  AND (rt.transaction_type = 'CORRECT'
	       -- select the return_to_receiving txn created for the
	       -- rtv/rtc transaction from inventory as for this all we
	       -- need to do is update the process_flag and not update any
	       -- mol since rtv/rtc from inventory does not effect mol
	       -- but for that the process_flag on mol was updated to 2.
	       OR (rt.transaction_type = 'RETURN TO RECEIVING'
		   AND rt.destination_type_code = 'INVENTORY')
	       OR (rt.transaction_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER')
		   -- to eliminate the row being selected for a rtv
		   -- from inventory as for those we dont need to update
		   -- the move order line.
		   AND NOT exists (SELECT 1
				  FROM rcv_transactions rt2
			         WHERE rt2.interface_transaction_id = rt.interface_transaction_id
			           AND rt2.transaction_type = 'RETURN TO RECEIVING'
			           AND rt2.group_id = p_group_id)))
	  AND rt.user_entered_flag = 'Y'
	  AND rsl.shipment_line_id = rt.shipment_line_id
	  AND msi.inventory_item_id = rsl.item_id
	  AND msi.organization_id = rt.organization_id
      UNION ALL
       SELECT rsl.item_id
            , rt.po_line_location_id
            , rt.shipment_line_id
            , rt.oe_order_line_id
            , rt.quantity rt_quantity
            , rt.transaction_id
            , rt.interface_transaction_id
            , rt.lpn_id
            , rt.transfer_lpn_id
            , rt.primary_unit_of_measure
            , rt.unit_of_measure
            , rt.organization_id
            , mtln.lot_number
            , mtln.transaction_quantity
            , rt.transaction_type
	    , rt.parent_transaction_id
	    , rsl.asn_line_flag
            , DECODE(MSI.RETURN_INSPECTION_REQUIREMENT,1,'Y','N') INSPECTION_REQUIRED_FLAG
         FROM mtl_material_transactions mmt
	    , mtl_transaction_lot_numbers mtln
            , rcv_shipment_lines rsl
            , rcv_transactions rt
            , mtl_system_items msi
        WHERE rt.group_id = p_group_id
          AND mmt.rcv_transaction_id = rt.transaction_id
	  AND mmt.transaction_id = mtln.transaction_id
	 -- should select in this part of the union only the cases which
	 -- have not been selected on top which are the ones for which the
	 -- row is deleted from mtlt.
	  AND rt.quantity > 0
	  AND rt.transaction_type = 'CORRECT'
	  AND msi.lot_control_code = 2
	  AND exists (SELECT 1
		        FROM rcv_transactions rt1
		       WHERE rt1.transaction_id = rt.parent_transaction_id
		         AND rt1.transaction_type = 'DELIVER')
          AND rt.user_entered_flag = 'Y'
          AND rsl.shipment_line_id = rt.shipment_line_id
          AND msi.inventory_item_id = rsl.item_id
          AND msi.organization_id = rt.organization_id;


    CURSOR c_update_mo(l_transaction_id IN NUMBER
		       , l_item_id IN NUMBER
		       , l_lot_number in VARCHAR2
		       , v_reference IN VARCHAR2
		       , v_reference_id IN NUMBER
		       , v_lpn_id IN NUMBER
		       , v_inspection_status IN NUMBER
		       , v_organization_id IN NUMBER)
      IS
	 SELECT mol.header_id
	      , mol.line_id
	      , mol.quantity mol_quantity
	      , nvl(mol.quantity_delivered,0) mol_quantity_delivered
	      , (mol.quantity - nvl(mol.quantity_delivered,0)) mol_available_quantity
	      , mol.lot_number
	      , mol.uom_code mol_uom_code
	      , mol.reference
	      , mol.lpn_id
	      , mol.inventory_item_id item_id
	      , rt.quantity rt_quantity
	      , rt.primary_unit_of_measure
	      , rt.unit_of_measure
	      , rt.organization_id
	   FROM mtl_txn_request_lines mol, rcv_transactions rt
	   WHERE rt.transaction_id = l_transaction_id
	    AND mol.organization_id = v_organization_id
	    AND rt.organization_id = v_organization_id
	    AND mol.reference_id = v_reference_id
	    AND mol.reference = v_reference
	    AND mol.inventory_item_id = l_item_id
	    AND mol.lpn_id = v_lpn_id
	    AND Nvl(mol.inspection_status,-1) = Nvl(v_inspection_status,-1)
	    AND nvl(mol.lot_number,'@@@') = nvl(l_lot_number,'@@@')
	    AND nvl(mol.quantity,0) - nvl(mol.quantity_delivered,0) > 0
	  ORDER BY nvl(mol.quantity,0) - nvl(mol.quantity_delivered,0) DESC;

	l_lpn_id NUMBER;
	l_inspect NUMBER;
	l_parent_transaction_type VARCHAR2(30);
	l_rtr_parent_txn_type VARCHAR2(30);
	l_rtv_parent_txn_type VARCHAR2(30);
	l_grand_parent_txn_type VARCHAR2(30);
	l_uom_code VARCHAR2(3);
	l_move_order_header_id NUMBER;
	l_mol_unit_of_measure VARCHAR2(25);
	l_rt_qty_in_mol_uom NUMBER;
	l_mol_qty_in_primary_uom NUMBER;
	l_rt_qty_in_primary_uom NUMBER;
	l_reference_id NUMBER;
	l_reference VARCHAR2(25);

	l_update_lpn NUMBER;
	l_routing_id NUMBER;
	l_transfer_org_id NUMBER;
	l_inspection_status NUMBER;
	l_progress VARCHAR2(5);
	l_return_status VARCHAR2(5);
	l_msg_data VARCHAR2(500);
	l_msg_count NUMBER;
	l_lpn_context NUMBER;--bug3646129

	l_pregen_putaway_tasks_flag NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := fnd_api.g_ret_sts_success;
   x_msg_count := 0;

   l_progress := '10';
   IF (l_debug = 1) THEN
      print_debug('=== Start maintain_move_orders ===');
   END IF;

   FOR i IN c_create_mo LOOP

      IF (l_debug = 1) THEN
         print_debug('Creating MO for id:'||i.interface_transaction_id||':transaction_type='||  i.transaction_type || ', qty=' || i.quantity);
      END IF;

      IF i.transaction_type = 'RETURN TO RECEIVING' THEN
	 l_progress := '20';

	 l_lpn_id := i.transfer_lpn_id;
	 -- Bug #1939258
	 SELECT transaction_type
	   INTO l_rtr_parent_txn_type
	   FROM rcv_transactions
	  WHERE transaction_id = i.parent_transaction_id;
	 IF (l_debug = 1) THEN
   	 print_debug('parent transaction_type for return to receiving='|| l_rtr_parent_txn_type);
	 END IF;

       ELSIF i.transaction_type = 'CORRECT' THEN

	 l_progress := '30';
	 SELECT transaction_type into l_parent_transaction_type
	   FROM rcv_transactions
	   WHERE transaction_id = i.parent_transaction_id;

	 IF (l_debug = 1) THEN
   	 print_debug('correction parent transaction_type='|| l_parent_transaction_type);
	 END IF;

	 IF l_parent_transaction_type = 'RECEIVE' THEN
	    l_progress := '40';

	    IF i.quantity > 0 THEN
	       l_lpn_id := i.transfer_lpn_id;
	     ELSE
	       l_lpn_id := NULL; -- MO is updated
	    END IF;

	  ELSIF l_parent_transaction_type = 'DELIVER' THEN
	    l_progress := '50';

	    IF i.quantity > 0 THEN
	       l_lpn_id := NULL; -- MO is updated
	     ELSE
	       l_lpn_id := i.lpn_id;
	    END IF;

	  ELSIF l_parent_transaction_type in ('RETURN TO VENDOR','RETURN TO CUSTOMER') THEN
	    l_progress := '60';

	    IF i.quantity > 0 THEN
	       l_lpn_id := NULL; -- MO is updated
	     ELSE
	       l_lpn_id := i.lpn_id;
	    END IF;

	  ELSIF l_parent_transaction_type IN ('ACCEPT', 'REJECT') THEN
	    l_progress := '70';
	    IF i.quantity < 0 THEN
	       -- For this we need to create a new MO with an inspection
	       -- status of not inspected and also later modify
	       -- the
	       l_lpn_id := i.lpn_id;
	     ELSE
	       l_lpn_id := i.transfer_lpn_id;
	    END IF;
	 END IF;

      END IF;
      l_progress := '80';
      IF l_lpn_id IS NOT NULL
	AND (i.transaction_type = 'RETURN TO RECEIVING'
	     OR (i.transaction_type = 'CORRECT' AND
		 (l_parent_transaction_type in ('RETURN TO VENDOR','RETURN TO CUSTOMER','DELIVER') AND i.quantity < 0)
		 OR (l_parent_transaction_type = 'RECEIVE' AND i.quantity > 0)
		 OR (l_parent_transaction_type IN ('ACCEPT', 'REJECT')))) THEN
	 l_progress := '90';
	 IF (l_debug = 1) THEN
   	 print_debug('lpn_id being used to create a mo:'||l_lpn_id);
	 END IF;

	 IF l_parent_transaction_type IN ('ACCEPT', 'REJECT') THEN
	    l_progress := '100';
	    IF i.quantity < 0 THEN
	       -- it is -ve correction of inspected qty
	       -- so create a mo with inspection status of null.
	       l_inspect := 1;
	     ELSIF l_parent_transaction_type = 'ACCEPT' THEN
	       l_inspect := 2;
	     ELSE l_inspect := 3;
	    END IF;
	  ELSE
	    l_progress := '110';
	    IF i.po_line_location_id IS NOT NULL THEN
               BEGIN
		  l_progress := '112';
		  SELECT receiving_routing_id
		    INTO l_routing_id
		    FROM po_line_locations_all
		   WHERE line_location_id = i.po_line_location_id;
	       EXCEPTION
		  WHEN OTHERS THEN NULL;
	       END;
	       l_progress := '114';
	     ELSIF i.oe_order_line_id IS NOT NULL THEN
	       IF Nvl(i.inspection_required_flag,'N') = 'Y' THEN
		  l_routing_id := 2;
		ELSE
                  BEGIN
		     l_progress := '116';
		     SELECT Nvl(receiving_routing_id,1)
		       INTO l_routing_id
		       FROM rcv_parameters
		      WHERE organization_id = i.organization_id;
		  EXCEPTION
		     WHEN OTHERS THEN NULL;
		  END;
		  l_progress := '117';
	       END IF;
	     ELSE
	        -- it is a intransit shipment.
		l_transfer_org_id := i.from_organization_id;
	        BEGIN
		   l_progress := '118';
		   SELECT routing_header_id
		     INTO l_routing_id
		     FROM rcv_shipment_lines
		    WHERE shipment_line_id = i.shipment_line_id;
		EXCEPTION
		   WHEN OTHERS THEN NULL;
		END;
		l_progress := '119';
	    END IF;
	    l_progress := '120';
	    IF (l_debug = 1) THEN
   	    print_debug('routing id found was :'||l_routing_id);
	    END IF;
	    IF l_routing_id = 2 THEN
	       -- Bug #1939258
	       -- IF l_parent_transaction_type = 'DELIVER' THEN
	       IF l_parent_transaction_type = 'DELIVER' OR
		 (i.transaction_type = 'RETURN TO RECEIVING' AND
		  l_rtr_parent_txn_type = 'DELIVER') THEN
		  -- If it is a deliver txn and we are doing a -ve
		  -- correction then the inspection_status need to
		  -- be determined based on the transaction_type
		  -- of the parent_transaction_id of the deliver txn
		  BEGIN
		     l_progress := '130';
		     SELECT transaction_type
		       INTO l_grand_parent_txn_type
		       FROM rcv_transactions rt
		      WHERE transaction_id = (SELECT rt2.parent_transaction_id
					        FROM rcv_transactions rt2
					       WHERE rt2.transaction_id = i.parent_transaction_id);
		  EXCEPTION
		     WHEN OTHERS THEN
			IF (l_debug = 1) THEN
   			print_debug('Could not get the grand parent txn. type:'||i.parent_transaction_id);
			END IF;
			l_inspect := NULL;
		  END;
		  l_progress := '140';
		  IF (l_debug = 1) THEN
   		  print_debug('Grand parent txn. type:'||l_grand_parent_txn_type);
		  END IF;
		  IF l_grand_parent_txn_type = 'ACCEPT' THEN
		     l_inspect := 2;
		   ELSIF l_grand_parent_txn_type = 'REJECT' THEN
		     l_inspect := 3;
		   ELSE
		     l_inspect := 1;
		  END IF;
		ELSE
		  l_inspect := 1;
	       END IF;
	     ELSE
	       l_inspect := NULL;
	    END IF;
	 END IF;
	 l_progress := '150';

	 SELECT uom_code INTO l_uom_code FROM mtl_item_uoms_view
	  WHERE organization_id = i.organization_id
	    AND unit_of_measure = i.unit_of_measure
	    AND inventory_item_id = i.item_id;
	 l_progress := '160';
	 IF (l_debug = 1) THEN
   	 print_debug('Calling create mo for correction..asn_line_flag:'||i.asn_line_flag);
	 END IF;
	 IF i.asn_line_flag IS NOT NULL THEN
	    IF i.asn_line_flag = 'Y' THEN
	       INV_RCV_STD_RCPT_APIS.create_mo_for_correction(p_move_order_header_id  => l_move_order_header_id,
							      p_po_line_location_id   => NULL,
							      p_shipment_line_id      => i.shipment_line_id,
							      p_oe_order_line_id      => NULL,
							      p_routing               => 1,
							      p_lot_control_code      => i.lot_control_code,
							      p_org_id                => i.organization_id,
							      p_item_id               => i.item_id,
							      p_qty                   => abs(i.quantity),
							      p_uom_code              => l_uom_code,
							      p_lpn                   => l_lpn_id,
							      p_revision              => i.item_revision,
							      p_inspect               => l_inspect,
							      p_txn_source_id         => i.interface_transaction_id,
							      x_status                => x_return_status,
							      x_message               => x_msg_data,
							      p_transfer_org_id       => l_transfer_org_id,
							      p_wms_process_flag      => 1
		 );
	     ELSE
	       INV_RCV_STD_RCPT_APIS.create_mo_for_correction(p_move_order_header_id  => l_move_order_header_id,
							      p_po_line_location_id   => i.po_line_location_id,
							      p_shipment_line_id      => i.shipment_line_id,
							      p_oe_order_line_id      => i.oe_order_line_id,
							      p_routing               => 1,
							      p_lot_control_code      => i.lot_control_code,
							      p_org_id                => i.organization_id,
							      p_item_id               => i.item_id,
							      p_qty                   => abs(i.quantity),
							      p_uom_code              => l_uom_code,
							      p_lpn                   => l_lpn_id,
							      p_revision              => i.item_revision,
							      p_inspect               => l_inspect,
							      p_txn_source_id         => i.interface_transaction_id,
							      x_status                => x_return_status,
							      x_message               => x_msg_data,
							      p_transfer_org_id       => l_transfer_org_id,
							      p_wms_process_flag      => 1
		 );
	    END IF;
	 END IF;
	 l_progress := '170';

	 -- Make a call to pregenerate suggestions for the LPN for
	 -- which the move order is being created.
	 BEGIN
	    IF (l_debug = 1) THEN
   	    print_debug('Calling the pregeneration API',4);
	    END IF;
	    wms_putaway_suggestions.start_pregenerate_program(p_org_id =>i.organization_id,
							      p_lpn_id => l_lpn_id,
							      x_return_status => l_return_status,
							      x_msg_count => l_msg_count,
							      x_msg_data => l_msg_data);
	    IF (l_debug = 1) THEN
   	    print_debug('After calling the pregen API'||l_return_status||':'||l_msg_data||':'||l_msg_count,4);
	    END IF;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
   	       print_debug('Exception in calling the pregen API',1);
	       END IF;
	 END;

	 -- Donot need to do this since it will get updated in
	 -- the end anyway.
	 --UPDATE mtl_txn_request_lines
	   --SET wms_process_flag = 1
	   --WHERE txn_source_id = i.interface_transaction_id;
      END IF;
      l_update_lpn := l_lpn_id;
      IF i.transaction_type = 'RETURN TO RECEIVING' THEN
	 l_update_lpn := i.lpn_id;
      END IF;
      -- In mark_returns and pack_into_receiving we update
      -- mol.txn_source_line_detail_id so use that to update the
      -- wms_process_flag since the new ones are anyway created with a
      -- wms_process_flag = 1.
      IF (l_debug = 1) THEN
         print_debug('Updating MOLs for:'||l_update_lpn);
      END IF;
      UPDATE mtl_txn_request_lines
	 SET wms_process_flag = 1
	   , txn_source_line_detail_id = NULL
       WHERE lpn_id = l_update_lpn
	 AND txn_source_line_detail_id = i.interface_transaction_id;
   END LOOP; -- c_create_mo

   IF (l_debug = 1) THEN
      print_debug('Finished creating new MOLs');
   END IF;
   l_progress := '180';

   FOR i IN c_rt_for_mo_udpate LOOP
      IF (l_debug = 1) THEN
         print_debug('Updating MOL for:'||i.transaction_id||':'||i.transaction_type);
      END IF;
      IF i.transaction_type in ('RETURN TO VENDOR','RETURN TO CUSTOMER') THEN

	 l_lpn_id := i.lpn_id;

	 SELECT transaction_type INTO l_rtv_parent_txn_type
	   FROM rcv_transactions
	   WHERE transaction_id = i.parent_transaction_id;
	 l_progress := '210';
	 IF (l_debug = 1) THEN
	    print_debug('RTV parent txn type='|| l_rtv_parent_txn_type);
	 END IF;

       ELSIF i.transaction_type = 'RETURN TO RECEIVING' THEN
	 -- this is for the updation of mol.process_flag to 1 from 2
	 -- as for a return to receiving transaction created as part
	 -- of a rtv/rtc from inventory we dont need to update or create
	 -- any mol but we do need to update the process_flag as that
	 -- was updated.
	 l_lpn_id := NULL;
	 UPDATE mtl_txn_request_lines
	    SET wms_process_flag = 1
	      , txn_source_line_detail_id = NULL
	  WHERE lpn_id = i.lpn_id
	    AND txn_source_line_detail_id = i.interface_transaction_id;

       ELSIF i.transaction_type = 'CORRECT' THEN

	 l_progress := '250';
	 SELECT transaction_type into l_parent_transaction_type
	   FROM rcv_transactions
	  WHERE transaction_id = i.parent_transaction_id;
	 l_progress := '260';
	 IF (l_debug = 1) THEN
   	 print_debug('parent transaction_type='|| l_parent_transaction_type);
	 END IF;

	 IF l_parent_transaction_type = 'RECEIVE' THEN

            IF i.rt_quantity < 0 THEN
	       l_lpn_id := i.transfer_lpn_id;
	     ELSE
	       l_lpn_id := NULL; -- MO is created
            END IF;

	  ELSIF l_parent_transaction_type = 'DELIVER' THEN

            IF i.rt_quantity < 0 THEN
	       l_lpn_id := NULL; -- MO is created
	     ELSE
	       l_lpn_id := i.lpn_id;
            END IF;

	  ELSIF l_parent_transaction_type in ('RETURN TO VENDOR','RETURN TO CUSTOMER') THEN

            IF i.rt_quantity < 0 THEN
	       l_lpn_id := NULL; -- MO is created
	     ELSE
	       l_lpn_id := i.lpn_id;
            END IF;

	  ELSIF l_parent_transaction_type IN ('ACCEPT', 'REJECT') THEN
	    -- For inspected qty. we have already created the new mo
	    -- for the new quantity with proper inspection status
	    -- but we still need to update the old mo.
	    IF i.rt_quantity < 0 THEN
	       l_lpn_id := i.transfer_lpn_id;
	     ELSE
	       l_lpn_id := i.lpn_id;
	    END IF;

	 END IF;

      END IF;
      l_progress := '270';
      IF l_lpn_id IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	 print_debug('lpn_id being used to update a mo:'||l_lpn_id);
	 END IF;
	 IF i.po_line_location_id IS NOT NULL THEN
	    l_reference := 'PO_LINE_LOCATION_ID';
	    l_reference_id := i.po_line_location_id;
	  ELSIF i.oe_order_line_id IS NOT NULL THEN
	    l_reference := 'ORDER_LINE_ID';
	    l_reference_id := i.oe_order_line_id;
	  ELSE
	    l_reference := 'SHIPMENT_LINE_ID';
	    l_reference_id := i.shipment_line_id;
	 END IF;

	 --If received against an ASN then use shipment_line_id instead of po_line_location_id
	 IF i.asn_line_flag IS NOT NULL THEN
	    IF i.asn_line_flag = 'Y' THEN
	       l_reference := 'SHIPMENT_LINE_ID';
	       l_reference_id := i.shipment_line_id;
	    END IF;
	 END IF;

	 IF (l_debug = 1) THEN
   	 print_debug('referece:'||l_reference||':referece_id:'||l_reference_id);
	 END IF;
	 /* Converting Receiving Txn qty to Primary UOM */
	 l_rt_qty_in_primary_uom := 0;
	 l_progress := '280';
	 po_uom_s.uom_convert(abs(i.rt_quantity),
			      i.unit_of_measure,
			      i.item_id,
			      i.primary_unit_of_measure,
			      l_rt_qty_in_primary_uom);
	 l_progress := '290';
	 IF (l_debug = 1) THEN
   	 print_debug('l_rt_qty_in_primary_uom=' || l_rt_qty_in_primary_uom || ', rt_quantity=' || i.rt_quantity || ', unit_of_measure=' || i.unit_of_measure || ', primary_unit_of_measure=' || i.primary_unit_of_measure);
	 END IF;

	 -- For MOL update of ACCEPT/REJECT transaction we have to select
	 -- MOL with proper status.
	 IF (l_parent_transaction_type IN ('ACCEPT', 'REJECT')
	     OR l_rtv_parent_txn_type IN ('ACCEPT', 'REJECT')) THEN
	    IF (l_parent_transaction_type IN ('ACCEPT','REJECT')) THEN
	       IF i.rt_quantity > 0 THEN
		  IF (l_debug = 1) THEN
		     print_debug('+ve correction for inspect for mol update');
		  END IF;
		  l_inspection_status := 1;
		ELSIF l_parent_transaction_type = 'ACCEPT' THEN
		  l_inspection_status := 2;
		ELSE
		  l_inspection_status := 3;
	       END IF;
	     ELSIF l_rtv_parent_txn_type IN ('ACCEPT','REJECT') THEN
	       IF (l_rtv_parent_txn_type = 'ACCEPT') THEN
		  l_inspection_status := 2;
		ELSE
		  l_inspection_status := 3;
	       END IF;
	    END IF;
	  ELSIF (l_parent_transaction_type IN ('RECEIVE', 'DELIVER')
		    OR l_rtv_parent_txn_type = 'RECEIVE') THEN
	    -- Inspection status should be null or 1 based on the routing
	    -- determined for the receipt being corrected which should be
	    -- the same as it was when the receipt took place.
	    l_progress := '300';
	    IF i.po_line_location_id IS NOT NULL THEN
	       l_progress := '310';
               BEGIN
		  SELECT receiving_routing_id
		    INTO l_routing_id
		    FROM po_line_locations_all
		   WHERE line_location_id = i.po_line_location_id;
	       EXCEPTION
		  WHEN OTHERS THEN NULL;
	       END;
	       l_progress := '320';
	     ELSIF i.oe_order_line_id IS NOT NULL THEN
	       IF Nvl(i.inspection_required_flag,'N') = 'Y' THEN
		  l_routing_id := 2;
		ELSE
                  BEGIN
		     l_progress := '330';
		     SELECT Nvl(receiving_routing_id,1)
		       INTO l_routing_id
		       FROM rcv_parameters
		      WHERE organization_id = i.organization_id;
		  EXCEPTION
		     WHEN OTHERS THEN NULL;
		  END;
		  l_progress := '340';
	       END IF;
	     ELSE
	        -- it is a intransit shipment.
	        BEGIN
		   l_progress := '350';
		   SELECT routing_header_id
		     INTO l_routing_id
		     FROM rcv_shipment_lines
		    WHERE shipment_line_id = i.shipment_line_id;
		EXCEPTION
		   WHEN OTHERS THEN NULL;
		END;
		l_progress := '360';
	    END IF;

	    l_progress := '370';
	    IF (l_debug = 1) THEN
   	    print_debug('routing id found was :'||l_routing_id);
	    END IF;
	    IF l_routing_id = 2 THEN
	       IF l_parent_transaction_type = 'DELIVER' THEN
		  -- If it is a deliver txn and we are doing a -ve
		  -- correction then the inspection_status need to
		  -- be determined based on the transaction_type
		  -- of the parent_transaction_id of the deliver txn
		  BEGIN
		     l_progress := '380';
		     SELECT transaction_type
		       INTO l_grand_parent_txn_type
		       FROM rcv_transactions rt
		      WHERE transaction_id = (SELECT rt2.parent_transaction_id
					        FROM rcv_transactions rt2
					       WHERE rt2.transaction_id = i.parent_transaction_id);
		  EXCEPTION
		     WHEN OTHERS THEN
			IF (l_debug = 1) THEN
   			print_debug('Could not get the grand parent txn. type:'||i.parent_transaction_id);
			END IF;
			l_inspection_status := NULL;
		  END;
		  l_progress := '390';
		  IF (l_debug = 1) THEN
   		  print_debug('Grand parent txn. type:'||l_grand_parent_txn_type);
		  END IF;
		  IF l_grand_parent_txn_type = 'ACCEPT' THEN
		     l_inspection_status := 2;
		   ELSIF l_grand_parent_txn_type = 'REJECT' THEN
		     l_inspection_status := 3;
		   ELSE
		     l_inspection_status := 1;
		  END IF;
		ELSE
		 l_inspection_status := 1;
	       END IF;
	     ELSE
	       l_inspection_status := NULL;
	    END IF;
	 END IF;
	 IF (l_debug = 1) THEN
   	 print_debug('Opening MO cursor for:'||i.transaction_id||':'||
		     i.item_id||':'||i.lot_number||':'||l_reference||':'||
		     l_reference_id||':'||l_lpn_id||':'||l_inspection_status||':'||
		     i.organization_id);
	 END IF;
	 FOR j IN c_update_mo(i.transaction_id, i.item_id, i.lot_number,
			      l_reference, l_reference_id, l_lpn_id,
			      l_inspection_status, i.organization_id) LOOP
            IF (l_debug = 1) THEN
               print_debug('Opened update MOL for line_id:'||j.line_id);
            END IF;
	    -- Converting Move Order Line qty to Primary UOM
	    l_progress := '450';
	    SELECT unit_of_measure INTO l_mol_unit_of_measure
	      FROM mtl_item_uoms_view
	      WHERE organization_id = i.organization_id
	      AND uom_code = j.mol_uom_code
	      AND inventory_item_id = i.item_id;

	    l_progress := '460';
	    po_uom_s.uom_convert(abs(j.mol_available_quantity),
				 l_mol_unit_of_measure,
				 i.item_id,
				 i.primary_unit_of_measure,
				 l_mol_qty_in_primary_uom);
	    l_progress := '470';

	    po_uom_s.uom_convert(abs(l_rt_qty_in_primary_uom),
				 i.primary_unit_of_measure,
				 i.item_id,
				 l_mol_unit_of_measure,
				 l_rt_qty_in_mol_uom);

	    l_progress := '480';
	    IF (l_debug = 1) THEN
   	    print_debug('l_mol_qty_in_primary_uom=' || l_mol_qty_in_primary_uom
			|| ', l_rt_qty_in_mol_uom=' || l_rt_qty_in_mol_uom);
	    END IF;

	    -- Only for those cases in which MOL qty. has to be decreased.
	    -- Which are -ve of receive, +ve and -ve of accept/reject
	    -- +ve of deliver, +ve of RTV/RTC
	    -- RTV/RTC also need to decrease the MOL.
	    IF (i.transaction_type IN ('RETURN TO VENDOR', 'RETURN TO CUSTOMER')
		OR (i.transaction_type = 'CORRECT' AND
		    ((l_parent_transaction_type IN ('RECEIVE','ACCEPT','REJECT')
		      AND i.rt_quantity < 0)
		     OR (l_parent_transaction_type IN ('ACCEPT', 'REJECT',
						       'DELIVER',
						       'RETURN TO VENDOR',
						       'RETURN TO CUSTOMER')
			 AND i.rt_quantity > 0)))) THEN
	       IF (l_debug = 1) THEN
   	       print_debug('MOL quantity has to be reduced');
	       END IF;
	       IF l_mol_qty_in_primary_uom >= l_rt_qty_in_primary_uom THEN

		  /* We have enough qty in MO Line, hence consume it and exit */
		  /* Substract the MO Line qty with l_mol_qty_in_primary_uom */

		  UPDATE mtl_txn_request_lines
		     SET quantity = quantity - l_rt_qty_in_mol_uom
		       , primary_quantity = primary_quantity - l_rt_qty_in_primary_uom
		   WHERE header_id = j.header_id
		     AND nvl(lot_number,'@@@') = nvl(j.lot_number,'@@@')
		     AND line_id = j.line_id;

		  IF (l_debug = 1) THEN
   	            print_debug('Before update of mtrl within IF');
	          END IF;


		  -- 4389811 updating line status to 5 for closed MO
                    UPDATE mtl_txn_request_lines
		      SET line_status=5
		    WHERE header_id = j.header_id
		     AND line_id = j.line_id
		     AND ( nvl(quantity,0) = 0 OR
		           nvl(quantity,0)=nvl(quantity_delivered,0)
			 ) ;

		IF (l_debug = 1) THEN
   	        print_debug('After update of mtrl within IF');
	        END IF;

		  l_rt_qty_in_primary_uom := 0;
		  IF (l_debug = 1) THEN
   		  print_debug('updated mol:'||j.line_id||' and exiting');
		  END IF;
		  exit;

		ELSE
		  /* We don't have enough qty in MO Line, hence consume it and proceed to next loop */
		  /* Substract the MO Line qty with l_mol_qty_in_primary_uom */

		  UPDATE mtl_txn_request_lines
		     SET quantity = quantity - abs(j.mol_available_quantity) --l_rt_qty_in_mol_uom
		       , primary_quantity = primary_quantity - l_mol_qty_in_primary_uom
		   WHERE header_id = j.header_id
		     AND nvl(lot_number,'@@@') = nvl(j.lot_number,'@@@')
		     AND line_id = j.line_id;

		IF (l_debug = 1) THEN
   	        print_debug(' Before update of mtrl within ELSE');
	        END IF;

		     -- 4389811 updating line status to 5 for closed MO
                   UPDATE mtl_txn_request_lines
		     SET line_status=5
		   WHERE header_id = j.header_id
		     AND line_id = j.line_id
		     AND ( nvl(quantity,0) = 0 OR
		           nvl(quantity,0)=nvl(quantity_delivered,0)
			 );

		IF (l_debug = 1) THEN
   	        print_debug(' After update of mtrl within ELSE');
	        END IF;

		  IF (l_debug = 1) THEN
   		  print_debug('updated mol:'||j.line_id);
		  END IF;
		  l_rt_qty_in_primary_uom := l_rt_qty_in_primary_uom - l_mol_qty_in_primary_uom;

	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
   	       print_debug('MOL quantity has to be increased');
   	       print_debug('We create new MOL for inc. qty. so should not have come here');
	       END IF;
	    END IF;

	 END LOOP; -- c_update_mo
	 IF (l_debug = 1) THEN
   	 print_debug('finished finding mol for update');
	 END IF;
	 IF l_rt_qty_in_primary_uom > 0 THEN
	    IF (l_debug = 1) THEN
   	    print_debug('Should not have happened. Not enough quantity in MOL');
	    END IF;
	    /* There is no enought qty in all the MO Lines and hence through an exception */
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    RAISE fnd_api.g_exc_error; --return;
	 END IF;

	 UPDATE mtl_txn_request_lines
	    SET wms_process_flag = 1
	      , txn_source_line_detail_id = NULL
	  WHERE lpn_id = l_lpn_id
	    AND txn_source_line_detail_id = i.interface_transaction_id;

 	 -- Make a call to pregenerate suggestions for the LPN for
	 -- which the move order is being updated after deleting the
	 -- existing suggestions.
	 BEGIN

	    SELECT pregen_putaway_tasks_flag
	      INTO l_pregen_putaway_tasks_flag
	      FROM mtl_parameters
	      WHERE organization_id = i.organization_id;

	    IF (l_debug = 1) THEN
   	    print_debug('l_pregen_putaway_tasks_flag: ' || l_pregen_putaway_tasks_flag);
	    END IF;

	    IF l_pregen_putaway_tasks_flag = 1 THEN
	       IF (l_debug = 1) THEN
   	       print_debug('Calling the suggestion clean up API',4);
	       END IF;
	       wms_putaway_suggestions.cleanup_suggestions(p_org_id=>i.organization_id,
							   p_lpn_id => l_lpn_id,
							   x_return_status => l_return_status,
							   x_msg_count => l_msg_count,
							   x_msg_data => l_msg_data);
	       IF (l_debug = 1) THEN
   	       print_debug('After calling the suggestion clean up API'||l_return_status||':'||l_msg_data||':'||l_msg_count,4);
	       END IF;
	       IF l_return_status = fnd_api.g_ret_sts_error THEN
		  IF (l_debug = 1) THEN
   		  print_debug('Error while cleaning up the suggestions',2);
   		  print_debug('Not calling to pregenerate the suggestions',4);
		  END IF;
		ELSE
		/* BUG 3646129 In WMSPRGEB.pls  wms_putaway_suggestions.start_pregenerate_program() *
		 * new error conditions have been added which check for the lpn_context of lpn and  *
		 * will return error if the lpn_context of the passed lpn is othere than 2 or 3 so  *
		 * changes are being made to call this program only if the lpn_context is 2 or 3    */

		 SELECT lpn_context
	         INTO l_lpn_context
		 FROM wms_license_plate_numbers
		 WHERE lpn_id = l_lpn_id;
		 IF l_lpn_context in (2,3) THEN
		 	wms_putaway_suggestions.start_pregenerate_program(p_org_id =>i.organization_id,
								    p_lpn_id => l_lpn_id,
								    x_return_status => l_return_status,
								    x_msg_count => l_msg_count,
								    x_msg_data => l_msg_data);
		        IF (l_debug = 1) THEN
               		   print_debug('After calling the pregen API'||l_return_status||':'||l_msg_data||':'||l_msg_count,4);
              		END IF;
		 ELSE
			print_debug('lpn_context not in 2 or 3 not calling to pregenerate the suggestions',4);
		 END IF; -- BUG 3646129
	       END IF;
	    END IF;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
   	       print_debug('Exception in calling the pregen/cleanup API',1);
	       END IF;
	 END;

      END IF; -- l_lpn_id IS NULL

   END LOOP; -- c_rt_for_mo_udpate
   IF (l_debug = 1) THEN
      print_debug('Finished updating mol');
   END IF;
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      IF (l_debug = 1) THEN
         print_debug('maintain_move_orders : execution error');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Maintain MO - exception when others at:'||l_progress||': ' || sqlerrm || ':' || sqlcode);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
      x_msg_data := x_msg_data||sqlerrm;
END maintain_move_orders;

PROCEDURE PackUnpack_Container
(  x_return_status		OUT     NOCOPY VARCHAR2,
   x_msg_count          OUT     NOCOPY NUMBER,
   x_msg_data           OUT     NOCOPY VARCHAR2,
   p_lpn_id         IN      NUMBER,
   p_content_item_id        IN      NUMBER := NULL,
   p_revision           IN      VARCHAR2 := NULL,
   p_lot_number         IN      VARCHAR2 := NULL,
   p_from_serial_number     IN      VARCHAR2 := NULL,
   p_to_serial_number       IN      VARCHAR2 := NULL,
   p_quantity           IN      NUMBER   := 1,
   p_uom            IN      VARCHAR2 := NULL,
   p_organization_id        IN      NUMBER,
   p_subinventory       IN      VARCHAR2 := NULL,
   p_locator_id         IN      NUMBER   := NULL,
   p_operation          IN      NUMBER,
   p_cost_group_id          IN      NUMBER   := NULL,
   p_source_header_id       IN      NUMBER   := NULL,
   p_source_name            IN      VARCHAR2 := NULL,
   p_secondary_quantity     IN      NUMBER :=NULL  -- 13399743
)
IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_transactable_flag VARCHAR2(1) := NULL; --bug 5068433
    l_validation_level NUMBER := fnd_api.g_valid_level_full; --bug 5068433
    l_sec_qty NUMBER := null; -- 12621897
    l_sec_uom_code VARCHAR2(50) := null; -- 12621897

BEGIN

	IF (l_debug = 1) THEN
   	print_debug('=== Calling WMS_Container_PUB.PackUnpack_Container ===');
   	print_debug('p_lpn_id                  =>' || p_lpn_id);
   	print_debug('p_lot_number              =>' || p_lot_number);
   	print_debug('p_from_serial_number      =>' || p_from_serial_number);
   	print_debug('p_to_serial_number        =>' || p_to_serial_number);
   	print_debug('p_quantity                =>' || p_quantity);
   	print_debug('p_uom                     =>' || p_uom);
   	print_debug('p_subinventory            =>' || p_subinventory);
   	print_debug('p_locator_id              =>' || p_locator_id);
   	print_debug('p_operation               =>' || p_operation);
   	print_debug('p_source_header_id        =>' || p_source_header_id);
   	print_debug('p_source_name             =>' || p_source_name);
   	print_debug('P_COST_GROUP_ID           =>' || P_COST_GROUP_ID);
	print_debug('p_secondary_quantity      =>' || p_secondary_quantity); -- 13399743
	END IF;

        /* bug 13011555, removed the block defined for bug 5068433 and used
        inv_cache to improve performance */
        IF (inv_cache.set_item_rec(p_organization_id,p_content_item_id)) THEN
             l_transactable_flag := INV_CACHE.item_rec.mtl_transactions_enabled_flag;
             l_sec_uom_code      := INV_CACHE.item_rec.secondary_uom_code;
         ELSE
           l_transactable_flag := 'Y';
           l_sec_uom_code      :=NULL;
           IF (l_debug = 1) THEN
              print_debug('Error getting item transactable flag and sec_uom_code');
           END IF;
        END IF;

        IF (l_debug = 1) THEN
           print_debug('l_transactable_flag =>' || l_transactable_flag);
        END IF;

        IF l_transactable_flag = 'N' THEN --bug 5048633
         l_validation_level := fnd_api.g_valid_level_none;
        END IF;

        IF (l_debug = 1) THEN
         print_debug('l_sec_uom_code =>' || l_sec_uom_code);--bug13011555
        END IF;

   -- as part of the fix for bug13011555,removed the select statement used for bug 12621897, because wlc wont be there AT this point
        IF l_sec_uom_code IS NOT NULL THEN

           l_sec_qty := p_secondary_quantity ;-- 13399743
        END IF;

        IF (l_debug = 1) THEN
           print_debug('l_sec_qty =>' || l_sec_qty);--bug13011555
        END IF;


	WMS_Container_PUB.PackUnpack_Container(
                p_api_version              => 1.0,
		        p_validation_level         => l_validation_level,--bug 5048633
                x_return_status            => x_return_status,
                x_msg_count                => x_msg_count,
                x_msg_data                 => x_msg_data,
                p_lpn_id                   => p_lpn_id,
                p_content_item_id          => p_content_item_id,
                p_revision                 => p_revision,
                p_lot_number               => p_lot_number,
                p_from_serial_number       => p_from_serial_number,
                p_to_serial_number         => p_to_serial_number,
                p_quantity                 => p_quantity,
                p_uom                      => p_uom,
                p_organization_id          => p_organization_id,
                p_subinventory             => p_subinventory,
                p_locator_id               => p_locator_id,
                p_operation                => p_operation,
                p_source_header_id         => p_source_header_id,
                p_source_name              => p_source_name,
				p_cost_group_id            => p_cost_group_id,
                p_sec_uom => l_sec_uom_code,   -- 12621897
                p_sec_quantity => l_sec_qty    -- 12621897
                );

	IF (l_debug = 1) THEN
   	print_debug('***************Output Parameters********************');
   	print_debug('x_return_status               =>' || x_return_status);
   	print_debug('x_msg_count                   =>' || x_msg_count);
   	print_debug('x_msg_data                    =>' || x_msg_data);
	END IF;

	--IF (x_return_status <> FND_API.G_RET_STS_SUCCESS or x_msg_count > 0) THEN
	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	   x_return_status := 'E';
	   IF (l_debug = 1) THEN
	      print_debug('Errored out...');
	      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
	      print_debug(x_msg_data);
	   END IF;
	END IF;

END PackUnpack_Container;

/* Called from INVRCVFB.pls
** This procedure is used to unpack LPN for Return To Vendor and Correction
** Transactions with parent transaction type = RECEIVING as Inventory Manager
** is not called for these transactions.
*/

PROCEDURE txn_complete(
    p_group_id         IN  NUMBER,
    p_txn_status       IN  VARCHAR2, -- TRUE/FALSE
    p_txn_mode         IN  VARCHAR2, -- ONLINE/IMMEDIATE
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER) IS

    /* The first part of the cursor is for Plain and Lot controlled items.
    ** The second part of the cursor is for Serial and Lot/Serial controlled items.
    */

    CURSOR c_lpn_cnts IS
       SELECT wlpnc.organization_id
  	    , wlpn.subinventory_code subinventory
	    , wlpn.locator_id
            , rt.lpn_id lpn_id
	    , rt.transfer_lpn_id
            , wlpnc.inventory_item_id
	    , wlpnc.revision
	    , wlpnc.lot_number
            , to_char(null) serial_number
   	    , wlpnc.quantity
	    , wlpnc.uom_code
	    , rt.transaction_type
            , rt.interface_transaction_id
	    , wlpnc.COST_GROUP_ID cg_id
            , rt.destination_type_code
	    , rt.quantity rt_quantity
	    , rt.parent_transaction_id
	 FROM wms_license_plate_numbers wlpn, wms_lpn_contents wlpnc, rcv_transactions rt
	WHERE rt.group_id = p_group_id
          AND ((((   rt.transaction_type = 'RETURN TO VENDOR'
                  AND rt.lpn_id IS NOT NULL   -- 3603808
	         )
                 OR
                 (   rt.transaction_type  = 'RETURN TO CUSTOMER'
                  -- AND rt.transfer_lpn_id IS NOT NULL fix for 4389811
                  AND rt.lpn_id IS NOT NULL
		  ))
                -- to eliminate the row being selected for a rtv
                -- from inventory as pack unpack for that is already
                -- taken care of in inventory tm.
                AND NOT exists (SELECT 1
                                  FROM rcv_transactions rt2
                                 WHERE rt2.interface_transaction_id = rt.interface_transaction_id
                                   AND rt2.transaction_type = 'RETURN TO RECEIVING'
                                   AND rt2.group_id = p_group_id))
	       OR (rt.transaction_type = 'CORRECT')
	       OR (rt.transaction_type = 'RETURN TO RECEIVING'
		   AND rt.transfer_lpn_id IS NOT NULL
		   AND rt.lpn_id IS NOT NULL))
	  AND rt.user_entered_flag = 'Y'
          AND wlpnc.source_name = rt.transaction_type
          AND wlpnc.source_header_id = rt.interface_transaction_id
          AND nvl(wlpnc.serial_summary_entry,2) <> 1
          AND wlpn.lpn_id = wlpnc.parent_lpn_id
      UNION ALL
      SELECT msn.current_organization_id organization_id, msn.current_subinventory_code subinventory,
         msn.current_locator_id locator_id, rt.lpn_id, rt.transfer_lpn_id,
         msn.inventory_item_id, msn.revision, msn.lot_number,
         msn.serial_number, to_number(null) quantity, wlpnc.uom_code uom_code, rt.transaction_type,
         rt.interface_transaction_id, msn.COST_GROUP_ID cg_id,
         rt.destination_type_code, rt.quantity rt_quantity, rt.parent_transaction_id
      FROM mtl_serial_numbers msn, wms_lpn_contents wlpnc, rcv_transactions rt
      WHERE msn.last_txn_source_name = rt.transaction_type
         AND msn.last_txn_source_id = rt.interface_transaction_id
         AND rt.group_id = p_group_id
          AND ((((   rt.transaction_type = 'RETURN TO VENDOR'  -- 3603808
                  AND rt.lpn_id IS NOT NULL
	         )
                 OR
                 (   rt.transaction_type  = 'RETURN TO CUSTOMER'
                 -- AND rt.transfer_lpn_id IS NOT NULL fix for 4389811
                  AND rt.lpn_id IS NOT NULL
		  ))
                AND NOT exists (SELECT 1
                                  FROM rcv_transactions rt2
                                 WHERE rt2.interface_transaction_id = rt.interface_transaction_id
                                   AND rt2.transaction_type = 'RETURN TO RECEIVING'
                                   AND rt2.group_id = p_group_id))
	       OR (rt.transaction_type = 'CORRECT')	       OR (rt.transaction_type = 'RETURN TO RECEIVING'
		   AND rt.transfer_lpn_id IS NOT NULL
		   AND rt.lpn_id IS NOT NULL))
         AND rt.user_entered_flag = 'Y'
         AND wlpnc.parent_lpn_id = msn.lpn_id
         AND wlpnc.inventory_item_id = msn.inventory_item_id;

    -- Bug# 3281512 - Performance Fixes
    -- Also select for the item_id column in RTI so we can use
    -- this in looking up the values in MSN.
    CURSOR c_failure IS
       SELECT transaction_type, interface_transaction_id, item_id
	 FROM rcv_transactions_interface rti
	 WHERE rti.group_id = p_group_id
	 AND rti.transaction_type in ('RETURN TO VENDOR','RETURN TO CUSTOMER','RETURN TO RECEIVING','CORRECT');

    CURSOR c_newly_packed IS
       SELECT wlpnc.organization_id
	,     rti.lpn_id lpn_id
        ,     rti.transfer_lpn_id
	,     wlpnc.inventory_item_id
        ,     wlpnc.revision
        ,     wlpnc.lot_number
        ,     to_char(null) serial_number
        ,     wlpnc.quantity
        ,     wlpnc.uom_code
        ,     rti.transaction_type
        ,     rti.interface_transaction_id
        ,     rti.destination_type_code
        ,     rti.quantity rti_quantity
        ,     rti.parent_transaction_id
         FROM wms_lpn_contents wlpnc, rcv_transactions_interface rti, rcv_transactions rt
        WHERE rti.group_id = p_group_id
	AND rti.transaction_type = 'CORRECT'
	AND rt.transaction_id = rti.parent_transaction_id
	AND ((rt.transaction_type in ('RETURN TO VENDOR','RETURN TO CUSTOMER') AND rti.quantity < 0) OR
	     (rt.transaction_type = 'RECEIVE' AND rti.quantity > 0))
	AND wlpnc.source_name = rti.transaction_type
	AND wlpnc.source_header_id = rti.interface_transaction_id
	AND nvl(wlpnc.serial_summary_entry,2) <> 1
      UNION ALL
      SELECT msn.current_organization_id organization_id
	,    rti.lpn_id
	,    rti.transfer_lpn_id
        ,    msn.inventory_item_id
	,    msn.revision
	,    msn.lot_number
        ,    msn.serial_number
	,    to_number(null) quantity
        ,    wlpnc.uom_code
	,    rti.transaction_type
        ,    rti.interface_transaction_id
        ,    rti.destination_type_code
	,    rti.quantity rti_quantity
	,    rti.parent_transaction_id
      FROM mtl_serial_numbers msn, wms_lpn_contents wlpnc, rcv_transactions_interface rti, rcv_transactions rt
      WHERE msn.last_txn_source_name = rti.transaction_type
        AND msn.last_txn_source_id = rti.interface_transaction_id
        AND rti.group_id = p_group_id
        AND rti.transaction_type = 'CORRECT'
	AND rt.transaction_id = rti.parent_transaction_id
	AND ((rt.transaction_type in ('RETURN TO VENDOR','RETURN TO CUSTOMER') AND rti.quantity < 0) OR
             (rt.transaction_type = 'RECEIVE' AND rti.quantity > 0))
	AND wlpnc.parent_lpn_id = msn.lpn_id
	AND wlpnc.inventory_item_id = msn.inventory_item_id;

    CURSOR c_neg_deliver_ser IS
       SELECT msn.current_organization_id organization_id, msn.current_subinventory_code subinventory,
	 msn.current_locator_id locator_id, rt.lpn_id, rt.transfer_lpn_id,
	 msn.inventory_item_id, msn.revision, msn.lot_number,
	 msn.serial_number, to_number(NULL) quantity, rt.transaction_type,
	 rt.interface_transaction_id, msn.COST_GROUP_ID cg_id,
	 rt.destination_type_code, rt.quantity rt_quantity, rt.parent_transaction_id
	 FROM mtl_serial_numbers msn, rcv_transactions rt, rcv_shipment_lines rsl
	 WHERE rt.group_id = p_group_id
	 AND ((rt.transaction_type = 'CORRECT' AND Nvl(msn.lpn_id,-1) = Nvl(rt.lpn_id,-1))
	      OR (rt.transaction_type = 'RETURN TO RECEIVING'
		  AND Nvl(msn.lpn_id,-1) = Nvl(rt.transfer_lpn_id,-1)))
	 AND msn.current_subinventory_code = rt.from_subinventory
	 AND Nvl(msn.current_locator_id,-1) = Nvl(rt.from_locator_id,-1)
	 AND msn.current_organization_id = rt.organization_id
	 AND rsl.shipment_header_id = rt.shipment_header_id
	 AND rsl.shipment_line_id = rt.shipment_line_id
	 AND msn.inventory_item_id = rsl.item_id
	 AND rt.user_entered_flag = 'Y'
	 AND msn.current_status = 4
	 AND exists (SELECT '1' FROM rcv_transactions rt2
		     WHERE rt2.transaction_id = rt.parent_transaction_id
		     AND rt2.transaction_type = 'DELIVER');

    CURSOR c_neg_deliver_ser_lpng IS
       SELECT msn.current_organization_id organization_id, msn.current_subinventory_code subinventory,
	 msn.current_locator_id locator_id, rt.lpn_id, rt.transfer_lpn_id,
	 msn.inventory_item_id, msn.revision, msn.lot_number,
	 msn.serial_number, to_number(NULL) quantity, rt.transaction_type,
	 rt.interface_transaction_id, msn.COST_GROUP_ID cg_id,
	 rt.destination_type_code, rt.quantity rt_quantity, rt.parent_transaction_id
	 FROM mtl_serial_numbers msn, rcv_transactions rt, rcv_shipment_lines rsl
	 WHERE rt.transaction_date >= (Sysdate - 1)
	 AND rt.lpn_group_id = p_group_id
	 AND ((rt.transaction_type = 'CORRECT' AND Nvl(msn.lpn_id,-1) = Nvl(rt.lpn_id,-1))
	      OR (rt.transaction_type = 'RETURN TO RECEIVING'
		  AND Nvl(msn.lpn_id,-1) = Nvl(rt.transfer_lpn_id,-1)))
	 AND msn.current_subinventory_code = rt.from_subinventory
	 AND Nvl(msn.current_locator_id,-1) = Nvl(rt.from_locator_id,-1)
	 AND msn.current_organization_id = rt.organization_id
	 AND rsl.shipment_header_id = rt.shipment_header_id
	 AND rsl.shipment_line_id = rt.shipment_line_id
	 AND msn.inventory_item_id = rsl.item_id
	 AND rt.user_entered_flag = 'Y'
	 AND msn.current_status = 4
	 AND exists (SELECT '1' FROM rcv_transactions rt2
		     WHERE rt2.transaction_id = rt.parent_transaction_id
		     AND rt2.transaction_type = 'DELIVER');

        -- Added new cursor to address the Bug 4489361
   CURSOR c_neg_deliver_ser_1159 IS
     SELECT msn.current_organization_id organization_id, msn.current_subinventory_code subinventory,
       msn.current_locator_id locator_id, rt.lpn_id, rt.transfer_lpn_id,
       msn.inventory_item_id, msn.revision, msn.lot_number,
       msn.serial_number, to_number(NULL) quantity, rt.transaction_type,
       rt.interface_transaction_id, msn.COST_GROUP_ID cg_id,
       rt.destination_type_code, rt.quantity rt_quantity, rt.parent_transaction_id
       FROM mtl_serial_numbers msn, rcv_transactions rt, rcv_shipment_lines rsl
       WHERE rt.group_id = p_group_id
       AND ((rt.transaction_type = 'CORRECT' AND Nvl(msn.lpn_id,-1) = Nvl(rt.lpn_id,-1))
            OR (rt.transaction_type = 'RETURN TO RECEIVING'
          AND Nvl(msn.lpn_id,-1) = Nvl(rt.transfer_lpn_id,-1)))
       AND msn.current_subinventory_code = rt.subinventory
       AND Nvl(msn.current_locator_id,-1) = Nvl(rt.locator_id,-1)
       AND msn.current_organization_id = rt.organization_id
       AND rsl.shipment_header_id = rt.shipment_header_id
       AND rsl.shipment_line_id = rt.shipment_line_id
       AND msn.inventory_item_id = rsl.item_id
       AND rt.user_entered_flag = 'Y'
       AND msn.current_status = 4
       AND exists (SELECT '1' FROM rcv_transactions rt2
             WHERE rt2.transaction_id = rt.parent_transaction_id
             AND rt2.transaction_type = 'DELIVER');

        ret boolean;
        l_lpn_id number;
        l_pack_lpn NUMBER;
        l_unpack_lpn NUMBER;
        l_parent_transaction_type VARCHAR2(25);
	l_routing_header_id NUMBER;
	l_insp_status NUMBER;
        l_status NUMBER;

	/* New vars needed for deleting reservations*/
	l_qry_res_rec               INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE;
	l_res_rec_to_delete         INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE;
	l_src_doc_code              VARCHAR2(10);
	l_dem_src_type_id           NUMBER;
	l_mtl_reservation_tbl       INV_RESERVATION_GLOBAL.MTL_RESERVATION_TBL_TYPE;
	l_mtl_reservation_tbl_count NUMBER;
	l_dummy_sn                  INV_RESERVATION_GLOBAL.SERIAL_NUMBER_TBL_TYPE;
	l_error_code                NUMBER;
	l_res_lpn_id                NUMBER;
	l_unreserve_qty             NUMBER;
	l_express_return            VARCHAR2(1);

	-- Bug# 3631611: Performance Fixes
	-- Break the c_reservation_csr into two cursors, one where
	-- p_txn_mode = 'LPN_GROUP' and one for all other cases.
	CURSOR c_reservation_csr IS
	   SELECT rt.source_document_code,
	     rt.organization_id,
	     rsl.item_id,
	     rt.subinventory,
	     rt.locator_id,
	     rt.from_subinventory,
	     rt.from_locator_id,
	     rt.lpn_id,
	     rt.quantity
	     FROM   rcv_transactions rt, rcv_shipment_lines rsl
	     WHERE  rt.group_id = p_group_id
	     AND    p_txn_mode <> 'LPN_GROUP'
	     AND    rt.transaction_type IN ('RETURN TO VENDOR','RETURN TO RECEIVING', 'RETURN TO CUSTOMER')
	     AND    rt.shipment_line_id = rsl.shipment_line_id;

	CURSOR c_reservation_lpn_grp_csr IS
	   SELECT rt.source_document_code,
	     rt.organization_id,
	     rsl.item_id,
	     rt.subinventory,
	     rt.locator_id,
	     rt.from_subinventory,
	     rt.from_locator_id,
	     rt.lpn_id,
	     rt.quantity
	     FROM   rcv_transactions rt, rcv_shipment_lines rsl
	     WHERE  rt.transaction_date >= (SYSDATE-1)
	     AND    rt.lpn_group_id = p_group_id
	     AND    p_txn_mode = 'LPN_GROUP'
	     AND    rt.transaction_type IN ('RETURN TO VENDOR','RETURN TO RECEIVING', 'RETURN TO CUSTOMER')
	     AND    rt.shipment_line_id = rsl.shipment_line_id;

	-- Bug# 3631611: Performance Fixes
	-- Also define a cursor record type to fetch the results into.
	-- Since both cursors have the same return values, we can use this
	-- record type for both.
	l_res_csr           c_reservation_csr%ROWTYPE;

	l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
	l_wms_po_j_higher BOOLEAN := FALSE;

	-- Bug# 3281512 - Performance Fixes
	-- Cursor to get rid of the hash join problem
	CURSOR c_interface_txn_id IS
	   SELECT interface_transaction_id
	     FROM rcv_transactions
	     WHERE group_id = p_group_id;
	l_interface_txn_id  NUMBER;
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      print_debug('======== Start txn_complete =========');
      print_debug('	p_group_id 	=> ' || p_group_id);
      print_debug('	p_txn_status 	=> ' || p_txn_status);
      print_debug('	p_txn_mode 	=> ' || p_txn_mode);
   END IF;

    /* FP-J Lot/Serial Support Enhancement
     * Read the currentand PO patch levels and set the flag (that would be used to
     * match the Lot Number and the LPN) accordingly
     */
    IF ((WMS_UI_TASKS_APIS.g_wms_patch_level >= WMS_UI_TASKS_APIS.g_patchset_j) AND
        (WMS_UI_TASKS_APIS.g_po_patch_level >= WMS_UI_TASKS_APIS.g_patchset_j_po)) THEN
      l_wms_po_j_higher := TRUE;
      IF (l_debug = 1) THEN
        print_debug('WMS and PO patch levels are J or higher', 4);
      END IF;
    ELSE
      l_wms_po_j_higher := FALSE;
      IF (l_debug = 1) THEN
        print_debug('Either WMS or/and PO patch level(s) are lower than J', 4);
      END IF;
    END IF;

   IF (p_txn_status = 'TRUE') THEN
       print_debug('Within p_txn_status=TRUE', 4);
      IF (l_wms_po_j_higher = FALSE) THEN

	print_debug('Within l_wms_po_j_higher = FALSE', 4);
	 FOR i IN c_lpn_cnts LOOP

	    IF (l_debug = 1) THEN
	       print_debug('Txn Type=' || i.transaction_type || ', Destination=' || i.destination_type_code);
	       print_debug('Txn qty=' || i.rt_quantity);
	       print_debug('From LPN=' || i.lpn_id);
	       print_debug('To LPN=' || i.transfer_lpn_id);
	    END IF;

	    IF i.transaction_type <> 'CORRECT'
	      AND i.transaction_type <> 'RETURN TO RECEIVING' THEN
	       -- dont want to call pup for return to receiving as it is done
	       -- in inventory tm.
	       IF (l_debug = 1) THEN
		  print_debug('transaction_type <> CORRECT, RETURN TO RECEIVING');
	       END IF;
	       -- Need to call it only for a rtv from receiving as other
	       -- cases are taken care of in inventory tm.
	       -- Even a rtv/rtc from inventory creates 2 txns. - return
	       -- to receiving and rtv/rtc for same transaction_interface_id
	       -- and the same group_id. Unpacking for it has already happened
	       -- in the inventory TM (INVTRXWB.pls) so here should not call
	       -- it again for rtv/rtc from inventory.
	       PackUnpack_Container(
				    x_return_status            => x_return_status,
				    x_msg_count                => x_msg_count,
				    x_msg_data                 => x_msg_data,
				    p_lpn_id                   => i.lpn_id,
				    p_content_item_id          => i.inventory_item_id,
				    p_revision                 => i.revision,
				    p_lot_number               => i.lot_number,
				    p_from_serial_number       => i.serial_number,
				    p_to_serial_number         => i.serial_number,
				    p_quantity                 => i.quantity,
				    p_uom                      => i.uom_code,
				    p_organization_id          => i.organization_id,
				    p_subinventory             => NULL,
				    p_locator_id               => NULL,
				    p_operation                => 2, -- unpack
				    p_source_header_id         => i.interface_transaction_id,
				    p_source_name              => i.transaction_type,
				    p_cost_group_id		   => i.cg_id
				    );
	       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		  IF (l_debug = 1) THEN
		     print_debug('Error while unpacking for rtv/rtc from receiving');
		  END IF;
		  RAISE fnd_api.g_exc_error; --return;
	       END IF;

	     ELSIF i.transaction_type = 'CORRECT' THEN -- <> CORRECT
	       IF (l_debug = 1) THEN
		  print_debug('transaction_type = CORRECT');
	       END IF;

               BEGIN
		  SELECT transaction_type, routing_header_id
		    INTO l_parent_transaction_type, l_routing_header_id
		    FROM rcv_transactions
		    WHERE transaction_id = i.parent_transaction_id;
		  IF (l_debug = 1) THEN
		     print_debug('l_parent_transaction_type=' || l_parent_transaction_type);
		  END IF;
	       EXCEPTION
		  WHEN OTHERS THEN
		     l_parent_transaction_type := NULL;
		     IF (l_debug = 1) THEN
			print_debug('Error l_parent_transaction_type=' || l_parent_transaction_type);
		     END IF;
	       END;

	       IF i.lpn_id IS NOT NULL AND i.transfer_lpn_id IS NOT NULL AND
		 l_parent_transaction_type in ('ACCEPT','REJECT') THEN

		  /* Accept or Reject */
		  IF (l_debug = 1) THEN
		     print_debug('Correct Txn = Accept or Reject');
		  END IF;
		  IF i.rt_quantity < 0 THEN
		     l_unpack_lpn := i.transfer_lpn_id;
		     l_pack_lpn := i.lpn_id;
		   ELSE
		     l_unpack_lpn := i.lpn_id;
		     l_pack_lpn := i.transfer_lpn_id;
		  END IF;

		  PackUnpack_Container(
				       x_return_status            => x_return_status,
				       x_msg_count                => x_msg_count,
				       x_msg_data                 => x_msg_data,
				       p_lpn_id                   => l_unpack_lpn,
				       p_content_item_id          => i.inventory_item_id,
				       p_revision                 => i.revision,
				       p_lot_number               => i.lot_number,
				       p_from_serial_number       => i.serial_number,
				       p_to_serial_number         => i.serial_number,
				       p_quantity                 => Abs(i.quantity),
				       p_uom                      => i.uom_code,
				       p_organization_id          => i.organization_id,
				       p_subinventory             => NULL,
				       p_locator_id               => NULL,
				       p_operation                => 2, -- unpack
				       p_source_header_id         => i.interface_transaction_id,
				       p_source_name              => i.transaction_type,
				       p_cost_group_id            => i.cg_id
		    );

		  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		     IF (l_debug = 1) THEN
			print_debug('Error while unpacking in txn_complete for correction OF ACCEPT/REJECT');
		     END IF;
		     RAISE fnd_api.g_exc_error; --return;
		  END IF;

		  PackUnpack_Container(
				       x_return_status            => x_return_status,
				       x_msg_count                => x_msg_count,
				       x_msg_data                 => x_msg_data,
				       p_lpn_id                   => l_pack_lpn,
				       p_content_item_id          => i.inventory_item_id,
				       p_revision                 => i.revision,
				       p_lot_number               => i.lot_number,
				       p_from_serial_number       => i.serial_number,
				       p_to_serial_number         => i.serial_number,
				       p_quantity                 => Abs(i.quantity),
				       p_uom                      => i.uom_code,
				       p_organization_id          => i.organization_id,
				       p_subinventory             => NULL,
				       p_locator_id               => NULL,
				       p_operation                => 1, -- pack
				       p_source_header_id         => NULL,
				       p_source_name              => NULL,
				       p_cost_group_id            => NULL
				       );

		  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		     IF (l_debug = 1) THEN
			print_debug('Error while packing in txn_complete for correction OF ACCEPT/REJECT');
		     END IF;
		     RAISE fnd_api.g_exc_error; --return;
		  END IF;

		  -- Update the context for the pack lpn to 'resides in
		  -- receiving' as packunpack api may have changed it to
		  -- 'Defined but not used'

		  UPDATE wms_license_plate_numbers
		    SET lpn_context = wms_container_pub.lpn_context_rcv
		    WHERE lpn_id = l_pack_lpn;

		ELSIF ((i.lpn_id IS NOT NULL OR i.transfer_lpn_id IS NOT NULL) AND
		       l_parent_transaction_type in ('RECEIVE','RETURN TO VENDOR','RETURN TO CUSTOMER')) THEN

		  --IF i.lpn_id IS NOT NULL AND  i.transfer_lpn_id IS NULL THEN
		  -- Making it more explicit.
		  IF (l_parent_transaction_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER')
		      AND i.rt_quantity > 0)
		    OR (l_parent_transaction_type = 'RECEIVE' AND i.rt_quantity < 0) THEN

		     /* +ve Correct on RTV/RTC or -ve correction on Receive Txns */
		     IF l_parent_transaction_type = 'RECEIVE' THEN
			l_lpn_id := i.transfer_lpn_id;
		      ELSE
			l_lpn_id := i.lpn_id;
		     END IF;

		     IF (l_debug = 1) THEN
			print_debug('Correct Txn = +ve Correct RTV/RTC or -ve on Receive Txns');
		     END IF;

		     PackUnpack_Container(
					  x_return_status            => x_return_status,
					  x_msg_count                => x_msg_count,
					  x_msg_data                 => x_msg_data,
					  p_lpn_id                   => l_lpn_id,
					  p_content_item_id          => i.inventory_item_id,
					  p_revision                 => i.revision,
					  p_lot_number               => i.lot_number,
					  p_from_serial_number       => i.serial_number,
					  p_to_serial_number         => i.serial_number,
					  p_quantity                 => abs(i.quantity),
					  p_uom                      => i.uom_code,
					  p_organization_id          => i.organization_id,
					  p_subinventory             => NULL,
					  p_locator_id               => NULL,
					  p_operation                => 2, -- unpack
					  p_source_header_id         => i.interface_transaction_id,
					  p_source_name              => i.transaction_type,
					  p_cost_group_id            => i.cg_id
					  );

		     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			IF (l_debug = 1) THEN
			   print_debug('Error in unpacking for Correct Txn = +ve Correct RTV/RTC or -ve on Receive Txns');
			END IF;
			RAISE fnd_api.g_exc_error; --return;
		     END IF;

		     --ELSIF i.lpn_id IS NULL AND  i.transfer_lpn_id IS NOT NULL THEN
		   ELSIF (l_parent_transaction_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER')
			  AND i.rt_quantity < 0)
		     OR (l_parent_transaction_type = 'RECEIVE' AND i.rt_quantity > 0) THEN

		     /* -ve Correct on RTV/RTC or +ve on Receive Txns */
		     -- For a negative correction on RTV/RTC, the correction
		     -- FORM has lpn_id that gets populated. Also for the
		     -- negative correction of RTV we pack material into the
		     -- lpn_id entered on the form.
		     IF i.rt_quantity < 0 THEN l_lpn_id := i.lpn_id;
		      ELSE l_lpn_id := i.transfer_lpn_id;
		     END IF;

		     IF (l_debug = 1) THEN
			print_debug('Correct Txn = -ve Correct on RTV/RTC or +ve on Receive txns FOR lpn:'||l_lpn_id);
		     END IF;

		     /* Need to unmark the contents that are already packed into receiving */

		     PackUnpack_Container(
					  x_return_status            => x_return_status,
					  x_msg_count                => x_msg_count,
					  x_msg_data                 => x_msg_data,
					  p_lpn_id                   => l_lpn_id,
					  p_content_item_id          => i.inventory_item_id,
					  p_revision                 => i.revision,
					  p_lot_number               => i.lot_number,
					  p_from_serial_number       => i.serial_number,
					  p_to_serial_number         => i.serial_number,
					  p_quantity                 => abs(i.quantity),
					  p_uom                      => i.uom_code,
					  p_organization_id          => i.organization_id,
					  p_subinventory             => NULL,
					  p_locator_id               => NULL,
					  p_operation                => 2, -- unpack
					  p_source_header_id         => i.interface_transaction_id,
					  p_source_name              => i.transaction_type,
					  p_cost_group_id		=> i.cg_id
					  );

		     PackUnpack_Container(
					  x_return_status            => x_return_status,
					  x_msg_count                => x_msg_count,
					  x_msg_data                 => x_msg_data,
					  p_lpn_id                   => l_lpn_id,
					  p_content_item_id          => i.inventory_item_id,
					  p_revision                 => i.revision,
					  p_lot_number               => i.lot_number,
					  p_from_serial_number       => i.serial_number,
					  p_to_serial_number         => i.serial_number,
					  p_quantity                 => abs(i.quantity),
					  p_uom                      => i.uom_code,
					  p_organization_id          => i.organization_id,
					  p_subinventory             => NULL,
					  p_locator_id               => NULL,
					  p_operation                => 1, -- pack
					  p_source_header_id         => NULL,
					  p_source_name              => NULL,
					  p_cost_group_id            => NULL
					  );

		     -- If the parent transaction is a receive txn,
		     -- update the lpn_context as while unpacking, the
		     -- packunpack api might have changed the context
		     -- to 'Defined But not used'
		     IF (l_parent_transaction_type = 'RECEIVE') THEN
			UPDATE wms_license_plate_numbers
			  SET lpn_context = wms_container_pub.lpn_context_rcv
			  WHERE lpn_id = l_lpn_id;
		     END IF;

		  END IF;

	       END IF;
	    END IF; -- <> CORRECT

	    IF (i.serial_number IS NOT NULL
		AND i.transaction_type = 'CORRECT'
		AND l_parent_transaction_type IN ('RECEIVE','RETURN TO VENDOR','RETURN TO CUSTOMER')) THEN
	       -- The status of the serial number should be changes to issued
	       -- out of stores (4) if the serial number is going out of receiving
	       -- to the vendor which will be +ve correction of RTV and
	       -- -ve correction of a receive transaction.
	       -- For -ve corrections of rtvs and +ve correction of receive
	       -- transaction the serial number is received into receiving
	       -- so should have a current_status which is same as it has
	       -- when received through mobile which is 5.
	       IF (l_parent_transaction_type = 'RECEIVE' AND i.rt_quantity>0)
		 OR (l_parent_transaction_type IN ('RETURN TO VENDOR', 'RETURN TO CUSTOMER')
		     AND i.rt_quantity < 0) THEN

		  /* FP-J Lot/Serial Support Enhancement
		  * If WMS and PO J are installed, then the current status for serials in
		    * receiving should be "Resides in Receiving"
		    * If WMS or PO patch levels are less than J, then retain the current
		    * status of "Resides in Intransit"
		    */
		    IF (l_wms_po_j_higher) THEN
		       l_status := 7;
		     ELSE
		       l_status := 5;
		    END IF;
		    /* FP-J Lot/Serial Support Enhancement */
		ELSE
		  l_status := 4;
	       END IF;

	       IF (l_parent_transaction_type = 'RECEIVE' AND i.rt_quantity>0)
		 THEN
		  IF (l_routing_header_id = 2) THEN
		     l_insp_status := 1;
		   ELSE
		     l_insp_status := NULL;
		  END IF;
	       END IF;

	       -- updating status of the sn. to 5 for -ve correction of rtv
	       -- since this means that the sn are to be packed in receiving.
	       UPDATE mtl_serial_numbers
		 SET current_status = l_status
	         , inspection_status = l_insp_status
	         , last_txn_source_name = NULL
	         , last_txn_source_id = NULL
	         , group_mark_id = NULL
	         , line_mark_id = NULL
	         , cost_group_id = NULL
		 WHERE serial_number = i.serial_number
		 AND inventory_item_id = i.inventory_item_id;
	       IF (l_debug = 1) THEN
		  print_debug('Updated sn for correction of rtv and receive to status:'||l_status);
	       END IF;
	     ELSIF (i.serial_number IS NOT NULL
		    AND i.transaction_type = 'CORRECT'
		    AND l_parent_transaction_type IN ('ACCEPT','REJECT')) THEN
	       IF i.rt_quantity < 0 THEN
		  l_status := 1;
		ELSE
		  IF l_parent_transaction_type = 'ACCEPT' THEN
		     l_status := 2;
		   ELSE
		     l_status := 3;
		  END IF;
	       END IF;
	       -- Leave the current status of the serial number same
	       -- as the serial number continues to stay in receiving
	       -- need to change just the inspection status appropriately.
	       UPDATE mtl_serial_numbers
		 SET inspection_status = l_status
	         , last_txn_source_name = NULL
	         , last_txn_source_id = NULL
	         , group_mark_id = NULL
	         , line_mark_id = NULL
	         , cost_group_id = NULL
		 WHERE serial_number = i.serial_number
		 AND inventory_item_id = i.inventory_item_id;
	       IF (l_debug = 1) THEN
		  print_debug('Updated inspection status of sn for correction of accept/reject');
	       END IF;
	     ELSIF (i.serial_number IS NOT NULL
		    AND i.lpn_id IS NOT NULL
		    AND i.transfer_lpn_id IS NULL
		    AND i.transaction_type in ('RETURN TO VENDOR','RETURN TO CUSTOMER')) THEN

	       /* Not for Accept or Reject */
	       l_status := 4;
	       UPDATE mtl_serial_numbers
		 SET current_status = l_status
		 , last_txn_source_name = NULL
		 , last_txn_source_id = NULL
		 , group_mark_id = NULL
		 , line_mark_id = NULL
		 , cost_group_id = NULL
		 WHERE serial_number = i.serial_number
		 AND inventory_item_id = i.inventory_item_id;

	     ELSIF (i.serial_number IS NOT NULL
		    AND i.transaction_type in ('RETURN TO RECEIVING')) THEN
	       --l_status := 5;
	       /* FP-J Lot/Serial Support Enhancement
	       * If WMS and PO J are installed, then the current status for serials in
		 * receiving should be "Resides in Receiving"
		 * If WMS or PO patch levels are less than J, then retain the current
		 * status of "Resides in Intransit"
		 */
		 IF (l_wms_po_j_higher) THEN
		    l_status := 7;
		  ELSE
		    l_status := 5;
		 END IF;

		 UPDATE mtl_serial_numbers
		   SET current_status = l_status
		   , last_txn_source_name = NULL
		   , last_txn_source_id = NULL
		   , group_mark_id = NULL
		   , line_mark_id = NULL
		   , cost_group_id = NULL
		   WHERE serial_number = i.serial_number
		   AND inventory_item_id = i.inventory_item_id;

	    END IF;

	 END LOOP;
      END IF; --IF (l_wms_po_j_higher = FALSE) THEN
      --Check the express return profile value
      --FND_PROFILE.GET('WMS_EXPRESS_RETURN', l_express_return);
      --IF NVL(l_express_return,'Y') = 'N' THEN
      BEGIN
	 -- Bug# 3631611: Performance Fixes
	 -- Open the appropriate cursor based on p_txn_mode
	 IF (p_txn_mode = 'LPN_GROUP') THEN
	    OPEN c_reservation_lpn_grp_csr;
	  ELSE
	    OPEN c_reservation_csr;
	 END IF;
	 LOOP
	    IF (p_txn_mode = 'LPN_GROUP') THEN
	       FETCH c_reservation_lpn_grp_csr INTO l_res_csr;
	       EXIT WHEN c_reservation_lpn_grp_csr%NOTFOUND;
	     ELSE
	       FETCH c_reservation_csr INTO l_res_csr;
	       EXIT WHEN c_reservation_csr%NOTFOUND;
	    END IF;
	 --FOR l_res_csr IN c_reservation_csr LOOP
	    l_src_doc_code := l_res_csr.source_document_code;
	    -- Relieve the reservations created against this record
	    IF l_src_doc_code = 'PO' THEN
	       l_dem_src_type_id := 1;
	     ELSIF l_src_doc_code = 'INTREQ' THEN
	       l_dem_src_type_id := 7;
	     ELSIF l_src_doc_code = 'RMA' THEN
	       l_dem_src_type_id := 12;
	     ELSE
	       l_dem_src_type_id := 10;
	    END IF;

	    --Form the query criteria for checking a reservation record
	    l_qry_res_rec.demand_source_type_id := l_dem_src_type_id;
	    l_qry_res_rec.organization_id := l_res_csr.organization_id;
	    l_qry_res_rec.inventory_item_id := l_res_csr.item_id;
	    IF (l_wms_po_j_higher) THEN
	       l_qry_res_rec.subinventory_code := l_res_csr.from_subinventory;
	       l_qry_res_rec.locator_id := l_res_csr.from_locator_id;
	     ELSE
	       l_qry_res_rec.subinventory_code := l_res_csr.subinventory;
	       l_qry_res_rec.locator_id := l_res_csr.locator_id;
	    END IF;
	    l_qry_res_rec.lpn_id := l_res_csr.lpn_id;

	    IF (l_debug = 1) THEN
	       print_debug('TXN_COMPLETE: Querying reservation using following parameters');
	       print_debug('TXN_COMPLETE: Demand source type id:'||l_qry_res_rec.demand_source_type_id);
	       print_debug('TXN_COMPLETE: Organization id:'||l_qry_res_rec.organization_id);
	       print_debug('TXN_COMPLETE: Item id:'||l_qry_res_rec.inventory_item_id);
	       print_debug('TXN_COMPLETE: Subinventory Code:'||l_qry_res_rec.subinventory_code);
	       print_debug('TXN_COMPLETE: Locator id:'||l_qry_res_rec.locator_id);
	       print_debug('TXN_COMPLETE: LPN id:'||l_qry_res_rec.lpn_id);
	    END IF;

	    --Query all the reservation records for the above combinations
	    INV_RESERVATION_PUB.QUERY_RESERVATION(
						  p_api_version_number        => 1.0,
						  x_return_status             => x_return_status,
						  x_msg_count                 => x_msg_count,
						  x_msg_data                  => x_msg_data,
						  p_query_input               => l_qry_res_rec,
						  x_mtl_reservation_tbl       => l_mtl_reservation_tbl,
						  x_mtl_reservation_tbl_count => l_mtl_reservation_tbl_count,
						  x_error_code                => l_error_code
						  );

	    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	       IF (l_debug = 1) THEN
		  print_debug('TXN_COMPLETE: Error while calling query_reservations');
	       END IF;
	       FND_MSG_PUB.COUNT_AND_GET( p_count => x_msg_count, p_data => x_msg_data);
	       RAISE fnd_api.g_exc_error; --return;
	    END IF;

	    IF (l_debug = 1) THEN
	       print_debug('TXN_COMPLETE: No. of reservation recs found:'||l_mtl_reservation_tbl_count);
	    END IF;

	    --Check all the records for the given demand source, header and line.
	    FOR l_counter IN 1 .. l_mtl_reservation_tbl_count LOOP
	       l_res_lpn_id := l_mtl_reservation_tbl(l_counter).lpn_id;
	       l_unreserve_qty := l_res_csr.quantity;

	       --If a record whose LPN matches the LPN being returned
	       IF (l_res_lpn_id = l_res_csr.lpn_id) THEN
		  --Check the reservation quantity. If it is lesser than the quantity to be returned
		  --update the reservation. If the entire quantity is to be returned, then
		  --clear the reservation
		  l_res_rec_to_delete := l_mtl_reservation_tbl(l_counter);
		  IF (l_debug = 1) THEN
		     print_debug('TXN_COMPLETE: Deleting the reservation...');
		  END IF;
		  INV_RESERVATION_PUB.DELETE_RESERVATION(
							 p_api_version_number => 1.0,
							 p_init_msg_lst       => FND_API.G_FALSE,
							 x_return_status      => x_return_status,
							 x_msg_count          => x_msg_count,
							 x_msg_data           => x_msg_data,
							 p_rsv_rec            => l_res_rec_to_delete,
							 p_serial_number      => l_dummy_sn
							 );
		  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		     IF (l_debug = 1) THEN
			print_debug('TXN_COMPLETE: Error while deleting reservations');
		     END IF;
		     FND_MSG_PUB.COUNT_AND_GET( p_count => x_msg_count, p_data => x_msg_data);
		     RAISE fnd_api.g_exc_error; --return;
		  END IF;
		  IF (l_debug = 1) THEN
		     print_debug('TXN_COMPLETE: Deleted the reservation record successfully');
		  END IF;
	       END IF; --End If the lpn_id of the reservation record matches
	    END LOOP; --END delete all the reservation records
	 END LOOP;   --End for all the records for the group_id
	 -- Bug# 3631611: Performance Fixes
	 -- Close the appropriate reservation cursor that was opened
	 IF (p_txn_mode = 'LPN_GROUP') THEN
	    CLOSE c_reservation_lpn_grp_csr;
	  ELSE
	    CLOSE c_reservation_csr;
	 END IF;
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    NULL;
	 WHEN OTHERS THEN
	    -- Bug# 3631611: Performance Fixes
	    -- In case of exceptions, make sure these cursors are closed if open
	    IF (c_reservation_lpn_grp_csr%ISOPEN) THEN
	       CLOSE c_reservation_lpn_grp_csr;
	    END IF;
	    IF (c_reservation_csr%ISOPEN) THEN
	       CLOSE c_reservation_csr;
	    END IF;
      END;
      --END IF;    --End If the "Express Returns" profile is "N"

      -- If a -ve correction or return to receiving was performed on the DELIVER transaction then we
      -- need to update the current_status, sub and locator for the serial
      -- numbers - Bug 2490630
      IF (p_txn_mode <> 'LPN_GROUP') THEN
        -- Start of fix for the bug 4489361
        IF NOT l_wms_po_j_higher THEN

           FOR irec IN c_neg_deliver_ser_1159 LOOP
            IF ((irec.transaction_type = 'CORRECT' AND irec.rt_quantity < 0)
                OR (irec.transaction_type = 'RETURN TO RECEIVING')) THEN

             UPDATE mtl_serial_numbers
               SET
                 current_status = 5
               , current_subinventory_code = NULL
               , current_locator_id = NULL
               , last_txn_source_name = NULL
               , last_txn_source_id = NULL
               , group_mark_id = NULL
               , line_mark_id = NULL
               , cost_group_id = NULL
               WHERE serial_number = irec.serial_number
               AND inventory_item_id = irec.inventory_item_id ;

             IF (l_debug = 1) THEN
                print_debug('TXN_COMPLETE: Deliver Transaction. 1159.. updated serial... '||irec.serial_number);
             END IF;
           END IF; -- Txn type Check
          END LOOP;
       ELSE   -- Check for l_wms_po_j_higher  --End of fix for the bug 4489361

	 FOR irec IN c_neg_deliver_ser LOOP
	    IF ((irec.transaction_type = 'CORRECT' AND irec.rt_quantity < 0)
		OR (irec.transaction_type = 'RETURN TO RECEIVING')) THEN
	       /* FP-J Lot/Serial Support Enhancement
	       * If WMS and PO J are installed, then the current status for serials in
		 * receiving should be "Resides in Receiving"
		 * If WMS or PO patch levels are less than J, then retain the current
		 * status of "Resides in Intransit"
		 */
		 IF (l_wms_po_j_higher) THEN
		    l_status := 7;
		  ELSE
		    l_status := 5;
		 END IF;
		 UPDATE mtl_serial_numbers
		   SET
		   --current_status = 5
		   current_status = l_status
		   , current_subinventory_code = NULL
		   , current_locator_id = NULL
		   , last_txn_source_name = NULL
		   , last_txn_source_id = NULL
		   , group_mark_id = NULL
		   , line_mark_id = NULL
		   , cost_group_id = NULL
		   WHERE serial_number = irec.serial_number
		   AND inventory_item_id = irec.inventory_item_id
		   AND exists (SELECT '1' FROM rcv_serials_supply rss
			       WHERE rss.serial_num = serial_number
			       AND rss.supply_type_code = 'RECEIVING');
		 IF (l_debug = 1) THEN
		    print_debug('TXN_COMPLETE: Deliver Transaction... updated serial... '||irec.serial_number);
		 END IF;
	    END IF;
	 END LOOP;
        END IF ;   -- Check for l_wms_po_j_higher
       ELSE --IF (p_txn_mode <> 'LPN_GROUP') THEN
	 FOR irec IN c_neg_deliver_ser_lpng LOOP
	    IF ((irec.transaction_type = 'CORRECT' AND irec.rt_quantity < 0)
		OR (irec.transaction_type = 'RETURN TO RECEIVING')) THEN
	       /* FP-J Lot/Serial Support Enhancement
	       * If WMS and PO J are installed, then the current status for serials in
		 * receiving should be "Resides in Receiving"
		 * If WMS or PO patch levels are less than J, then retain the current
		 * status of "Resides in Intransit"
		 */
		 IF (l_wms_po_j_higher) THEN
		    l_status := 7;
		  ELSE
		    l_status := 5;
		 END IF;
		 UPDATE mtl_serial_numbers
		   SET
		   --current_status = 5
		   current_status = l_status
		   , current_subinventory_code = NULL
		   , current_locator_id = NULL
		   , last_txn_source_name = NULL
		   , last_txn_source_id = NULL
		   , group_mark_id = NULL
		   , line_mark_id = NULL
		   , cost_group_id = NULL
		   WHERE serial_number = irec.serial_number
		   AND inventory_item_id = irec.inventory_item_id
		   AND exists (SELECT '1' FROM rcv_serials_supply rss
			       WHERE rss.serial_num = serial_number
			       AND rss.supply_type_code = 'RECEIVING');
		 IF (l_debug = 1) THEN
		    print_debug('TXN_COMPLETE: Deliver Transaction... updated serial... '||irec.serial_number);
		 END IF;
	    END IF;
	 END LOOP;
      END IF; --IF (p_txn_mode <> 'LPN_GROUP') THEN


      -- End Changes for Bug 2490630
      IF (l_wms_po_j_higher = FALSE) THEN
	 maintain_move_orders(
			      p_group_id         => p_group_id,
			      x_return_status    => x_return_status,
			      x_msg_data         => x_msg_data,
			      x_msg_count        => x_msg_count);

	 -- Need to clean up the Lot/Serial Temp tables.
	 -- For Inventory destination txns, this would have already been
	 -- done by Inventory Mgr., but we are checking that here
	 -- as there is no harm in doing it again

	 -- Bug# 3281512 - Performance Fixes
	 -- Open up a cursor to retrieve all of the interface_transaction_id
	 -- values to avoid the hash join.
	 OPEN c_interface_txn_id;
	 LOOP
	    FETCH c_interface_txn_id INTO l_interface_txn_id;
	    EXIT WHEN c_interface_txn_id%NOTFOUND;

	    BEGIN
	       DELETE FROM MTL_SERIAL_NUMBERS_TEMP
		 WHERE TRANSACTION_TEMP_ID = l_interface_txn_id;

	       DELETE FROM MTL_TRANSACTION_LOTS_TEMP
		 WHERE TRANSACTION_TEMP_ID = l_interface_txn_id;

	    EXCEPTION
	       WHEN OTHERS THEN NULL;
	    END;
	 END LOOP;
	 CLOSE c_interface_txn_id;

      END IF; --IF (l_wms_po_j_higher = FALSE) THEN

   ELSIF (p_txn_status = 'FALSE') THEN -- p_txn_status = 'FALSE'

   IF (l_debug = 1) THEN
      print_debug('txn_complete- failure:  Transaction failed and hence doing the following...');
      print_debug('txn_complete- failure: Unpack Contents/serials that were marked');
      print_debug('txn_complete- failure: Update Contents/Serials that were marked, erasing Source_Name');
   END IF;

/* For +ve correction on 'RECEIVE' and -ve correction on RTV/RTC, material gets into Receiving.
** So, contents/new Serials would have been created before calling transaction processor.
** Now unpacking them which in effect removes them
*/
        FOR i IN c_newly_packed LOOP
	      PackUnpack_Container(
		 x_return_status                => x_return_status,
		 x_msg_count                    => x_msg_count,
		 x_msg_data                     => x_msg_data,
		 p_lpn_id                       => i.lpn_id,
		 p_content_item_id              => i.inventory_item_id,
		 p_revision                     => i.revision,
		 p_lot_number                   => i.lot_number,
		 p_from_serial_number           => i.serial_number,
		 p_to_serial_number             => i.serial_number,
		 p_quantity                     => i.quantity,
		 p_uom                          => i.uom_code,
		 p_organization_id              => i.organization_id,
		 p_subinventory                 => NULL,
		 p_locator_id                   => NULL,
		 p_operation                    => 2, -- unpack
		 p_source_header_id             => NULL,
		 p_source_name                  => NULL,
		 P_COST_GROUP_ID                => NULL);

		if (x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
			IF (l_debug = 1) THEN
   			print_debug('Error in txn_complete while unpacking for txn failure');
			END IF;
			RAISE fnd_api.g_exc_error; --return; -- error while unpacking
		end if;

	END LOOP;

	/* In all other cases(other than the cases above), contents/new serials would be
	** marked and hence remove the marks (source_name).
	  ** Also, bring back the previous_status of the serial as the current status
	  ** and set the lpn_txn_error_flag of the serial
	  */

	  FOR i IN c_failure LOOP

	     UPDATE wms_lpn_contents
	       SET source_name = NULL
	       WHERE source_name = i.transaction_type
	       AND source_header_id = i.interface_transaction_id;

	     -- Bug# 3281512 - Performance Fixes
	     -- Also go against the inventory_item_id in the MSN table
	     -- otherwise an index is not used and a full table scan will occur.
	     -- Only update MSN if an item ID exists on the RTI record.
	     IF (i.item_id IS NOT NULL) THEN
		UPDATE mtl_serial_numbers
		  SET last_txn_source_name = NULL,
		  current_status = nvl(previous_status,current_status),
		  lpn_txn_error_flag = 'Y'
		  WHERE last_txn_source_name = i.transaction_type
		  AND last_txn_source_id = i.interface_transaction_id
		  AND inventory_item_id = i.item_id;
	     END IF;

	  END LOOP;


	  IF (l_debug = 1) THEN
	     print_debug('Exiting txn_complete- failure');
	  END IF;
   END IF;
   IF (l_debug = 1) THEN
      print_debug('Exiting txn_complete');
   END IF;

EXCEPTION
      WHEN FND_API.g_exc_error THEN
      IF (l_debug = 1) THEN
         print_debug('txn_complete : execution error');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('In exception when others: ' || sqlerrm || ':' || sqlcode);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
      x_msg_data := x_msg_data||sqlerrm;
END txn_complete;

/* This function is called from LOV Cursor procedure 'GET_RETURN_LPN' of
** WMSLPNLB.pls to determine if the LPN is fully marked or partially marked.
*/

FUNCTION GET_LPN_MARKED_STATUS (p_lpn_id IN NUMBER, p_org_id IN NUMBER) RETURN VARCHAR2 IS
/* Returns NONE or PARTIAL or FULL */

v_dummy VARCHAR2(1);
v_is_marked boolean := FALSE;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

      BEGIN

         SELECT  '1' INTO v_dummy  FROM
                 rcv_transactions_interface rti,wms_lpn_contents wlc
                 WHERE  rti.interface_transaction_id =  wlc.source_header_id
                 AND rti.processing_status_code = 'WSH_INTERFACED'
                 AND rti.to_organization_id = wlc.organization_id
                 AND wlc.parent_lpn_id =  p_lpn_id
		 AND ROWNUM < 2 ;


        IF (l_debug = 1) THEN
   	    print_debug('Lpn:' || p_lpn_id || 'Is Marked for Return Through Shipping RTV Project');
        END IF;

        RETURN 'NONE';

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

         IF (l_debug = 1) THEN
   	    print_debug('Lpn:' || p_lpn_id || 'Is Marked for Normal Return');
	 END IF;

          NULL;

         END;




    BEGIN

        SELECT '1' into v_dummy
        FROM mtl_serial_numbers
        WHERE lpn_id = p_lpn_id
        AND current_organization_id = p_org_id
        AND nvl(last_txn_source_name,'@@@') IN ('RETURN TO VENDOR', 'RETURN TO RECEIVING', 'RETURN TO CUSTOMER')
		AND rownum <= 1;

        v_is_marked := TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    END;

	if not v_is_marked then

    BEGIN

        SELECT '1' INTO v_dummy
        FROM wms_lpn_contents
        WHERE nvl(serial_summary_entry,2) <> 1
        AND parent_lpn_id = p_lpn_id
        AND organization_id = p_org_id
        AND nvl(source_name,'@@@') IN ('RETURN TO VENDOR', 'RETURN TO RECEIVING', 'RETURN TO CUSTOMER')
		AND rownum <= 1;

        v_is_marked := TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        null;
    END;

	end if;

	if not v_is_marked then
		RETURN 'NONE';
	end if;

    BEGIN

        SELECT '1' into v_dummy
		FROM mtl_serial_numbers
		WHERE lpn_id = p_lpn_id
        AND current_organization_id = p_org_id
        AND nvl(last_txn_source_name,'@@@') NOT IN ('RETURN TO VENDOR', 'RETURN TO RECEIVING', 'RETURN TO CUSTOMER')
		AND rownum <= 1;

		IF (l_debug = 1) THEN
   		print_debug('Lpn:' || p_lpn_id || ' having serial items is marked partially');
		END IF;
        return 'PARTIAL';

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    BEGIN

        SELECT '1' INTO v_dummy
        FROM wms_lpn_contents
        WHERE nvl(serial_summary_entry,2) <> 1
        AND parent_lpn_id = p_lpn_id
        AND ORGANIZATION_ID = p_org_id
        AND nvl(source_name,'@@@') NOT IN ('RETURN TO VENDOR', 'RETURN TO RECEIVING', 'RETURN TO CUSTOMER')
		AND rownum <= 1;

        IF (l_debug = 1) THEN
           print_debug('Lpn:' || p_lpn_id || 'having non serial items is marked partially');
        END IF;
        return 'PARTIAL';

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        null;
    END;
    IF (l_debug = 1) THEN
       print_debug('Lpn:' || p_lpn_id || ', entire lpn is marked for return');
    END IF;
    return 'FULL';
EXCEPTION
WHEN OTHERS THEN
	return 'PARTIAL';
END;

/*
** This Procedure is called from the Returns Form to Mark the LPN Contents
** that are selected for return.
*/


PROCEDURE MARK_RETURNS (
   x_return_status	   	OUT NOCOPY VARCHAR2,
   x_msg_count		      	OUT NOCOPY NUMBER,
   x_msg_data		      	OUT NOCOPY VARCHAR2,
   p_rcv_trx_interface_id 	IN NUMBER,
   p_ret_transaction_type 	IN VARCHAR2,
   p_lpn_id 			IN NUMBER,
   p_item_id 			IN NUMBER,
   p_item_revision 		IN VARCHAR2,
   p_quantity 			IN NUMBER,
   p_uom 			IN VARCHAR2,
   p_serial_controlled 	  	IN NUMBER,
   p_lot_controlled 	  	IN NUMBER,
   p_org_id 			IN NUMBER,
   p_subinventory 		IN VARCHAR2,
   p_locator_id 		IN NUMBER
   ) IS

-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_lot_number VARCHAR2(80);
   l_from_serial_number VARCHAR2(50);
   l_to_serial_number VARCHAR2(50);
   l_quantity number;
   l_lpn_context NUMBER := 0;
   l_cost_group_id number;
   TYPE c_ref_type IS REF CURSOR;
   c_ref c_ref_type;
   l_position VARCHAR2(4) := '0000';
   l_primary_uom VARCHAR2(10);
   l_uom VARCHAR2(3);--BUG 4939647: For non-serial controlled item, always pass the txn uom

   -- bug 4411792
   l_lpn_update              WMS_CONTAINER_PUB.LPN;
   l_return_status           VARCHAR2(1);
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(2000);

   l_sec_qty NUMBER; -- bug 13399743

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   l_position := '0010';
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      print_debug('Enter MARK_RETURNS');
      print_debug('p_serial_controlled => ' || p_serial_controlled);
      print_debug('p_lot_controlled    => ' || p_lot_controlled);
   END IF;

   BEGIN
      SELECT lpn_context
	INTO l_lpn_context
	FROM wms_license_plate_numbers
	WHERE organization_id = p_org_id
	AND lpn_id = p_lpn_id;
   EXCEPTION
      WHEN no_data_found THEN
	NULL;
   END;


   --Get primary UOM  - for bug fix 3609203
  BEGIN
     SELECT primary_uom_code
       INTO l_primary_uom
       FROM mtl_system_items
       WHERE inventory_item_id = p_item_id
       AND organization_id = p_org_id ;

  END; --get primary uom


  IF  p_lot_controlled = 2 AND p_serial_controlled in (2,5) THEN

      /* Lot/Serial Controlled */
      l_position := '0020';

      open c_ref for SELECT msn.lot_number, MSN.SERIAL_NUMBER FM_SERIAL_NUMBER,
      MSN.SERIAL_NUMBER TO_SERIAL_NUMBER, null quantity, msn.COST_GROUP_ID, null sec_qty--13399743
      FROM MTL_SERIAL_NUMBERS MSN, MTL_SERIAL_NUMBERS_TEMP MSNT, MTL_TRANSACTION_LOTS_TEMP MTLT
      WHERE MTLT.TRANSACTION_TEMP_ID = p_rcv_trx_interface_id
      AND MSNT.TRANSACTION_TEMP_ID = MTLT.SERIAL_TRANSACTION_TEMP_ID
      AND MSN.INVENTORY_ITEM_ID = p_item_id
      AND Nvl(MSN.revision,'@@@') = Nvl(p_item_revision,'@@@')
      AND MSN.LOT_NUMBER = MTLT.LOT_NUMBER
      AND MSN.SERIAL_NUMBER >= MSNT.FM_SERIAL_NUMBER
      AND MSN.SERIAL_NUMBER <= MSNT.TO_SERIAL_NUMBER

      UNION  --RTV Change 16197273

      SELECT msn.lot_number, MSN.SERIAL_NUMBER FM_SERIAL_NUMBER,
      MSN.SERIAL_NUMBER TO_SERIAL_NUMBER, null quantity, msn.COST_GROUP_ID, null sec_qty--13399743
      FROM MTL_SERIAL_NUMBERS MSN, MTL_SERIAL_NUMBERS_INTERFACE
      MSNI, mtl_transaction_lots_interface MTLI
      WHERE MTLI.PRODUCT_TRANSACTION_ID = p_rcv_trx_interface_id
      AND MSNI.PRODUCT_TRANSACTION_ID = p_rcv_trx_interface_id
      AND MSN.INVENTORY_ITEM_ID = p_item_id
      AND Nvl(MSN.revision,'@@@') = Nvl(p_item_revision,'@@@')
      AND MSN.LOT_NUMBER = MTLI.LOT_NUMBER
      AND MSN.SERIAL_NUMBER >= MSNI.FM_SERIAL_NUMBER
      AND MSN.SERIAL_NUMBER <= MSNI.TO_SERIAL_NUMBER;

--      AND length(MSN.SERIAL_NUMBER) = length(MSNT.FM_SERIAL_NUMBER);
-- It is not possible to use length function here because table MTL_TRANSACTION_LOTS_TEMP
-- has a field 'length' and it would result in a compilation error if function length
-- is used.

      l_uom := l_primary_uom;
   ELSIF p_lot_controlled = 2 AND p_serial_controlled not in (2,5) THEN

      /* Lot Controlled */
      l_position := '0030';

      /* For a given LPN, Lot and Item combination there could be more
      ** than one record in wms_lpn_contents, but we need
      ** only one record per LPN, Lot and Item combination as an output of this cursor
      */

      open c_ref for SELECT DISTINCT MTLT.LOT_NUMBER, NULL FM_SERIAL_NUMBER,
      NULL TO_SERIAL_NUMBER, MTLT.transaction_quantity quantity,wlpnc.cost_group_id, MTLT.secondary_quantity sec_qty--13399743
      FROM WMS_LPN_CONTENTS WLPNC, MTL_TRANSACTION_LOTS_TEMP MTLT
      WHERE MTLT.TRANSACTION_TEMP_ID = p_rcv_trx_interface_id
      AND WLPNC.LOT_NUMBER = MTLT.LOT_NUMBER
      AND WLPNC.PARENT_LPN_ID = p_lpn_id
      AND WLPNC.INVENTORY_ITEM_ID = P_ITEM_ID
      AND nvl(WLPNC.SOURCE_NAME,'@@@') not in ('RETURN TO RECEIVING','RETURN TO VENDOR', 'RETURN TO CUSTOMER')

      UNION  -- RTV Change 16197273

      SELECT DISTINCT MTLI.LOT_NUMBER, NULL FM_SERIAL_NUMBER,
      NULL TO_SERIAL_NUMBER, MTLI.transaction_quantity quantity,wlpnc.cost_group_id, MTLI.SECONDARY_TRANSACTION_QUANTITY sec_qty--13399743
      FROM WMS_LPN_CONTENTS WLPNC, mtl_transaction_lots_interface MTLI
      WHERE MTLI.PRODUCT_TRANSACTION_ID = p_rcv_trx_interface_id
      AND WLPNC.LOT_NUMBER = MTLI.LOT_NUMBER
      AND WLPNC.PARENT_LPN_ID = p_lpn_id
      AND WLPNC.INVENTORY_ITEM_ID = P_ITEM_ID
      AND nvl(WLPNC.SOURCE_NAME,'@@@') not in ('RETURN TO RECEIVING','RETURN TO VENDOR', 'RETURN TO CUSTOMER')   ;

      l_uom := p_uom;
   ELSIF p_lot_controlled <> 2 AND p_serial_controlled in (2,5) THEN

      /* Serial Controlled */
      l_position := '0040';
      open c_ref for SELECT NULL LOT_NUMBER, MSN.SERIAL_NUMBER FM_SERIAL_NUMBER,
      MSN.SERIAL_NUMBER TO_SERIAL_NUMBER, null quantity, msn.COST_GROUP_ID, null sec_qty --13399743
      FROM MTL_SERIAL_NUMBERS MSN, MTL_SERIAL_NUMBERS_TEMP msnt,
	wms_lpn_contents wlpnc
      WHERE MSNT.TRANSACTION_TEMP_ID = p_rcv_trx_interface_id
      AND MSN.INVENTORY_ITEM_ID = p_item_id
      AND Nvl(MSN.revision,'@@@') = Nvl(p_item_revision,'@@@')
      AND MSN.SERIAL_NUMBER >= MSNT.FM_SERIAL_NUMBER
      AND MSN.SERIAL_NUMBER <= MSNT.to_serial_number
	AND msn.lpn_id = wlpnc.parent_lpn_id
	AND wlpnc.parent_lpn_id = p_lpn_id
	AND wlpnc.inventory_item_id = msn.inventory_item_id
	AND nvl(WLPNC.SOURCE_NAME,'@@@') not in ('RETURN TO RECEIVING','RETURN TO VENDOR', 'RETURN TO CUSTOMER')
      AND length(MSN.SERIAL_NUMBER) = length(MSNT.FM_SERIAL_NUMBER)

      UNION   --RTV Change 16197273

      SELECT   NULL LOT_NUMBER, MSN.SERIAL_NUMBER FM_SERIAL_NUMBER,
      MSN.SERIAL_NUMBER TO_SERIAL_NUMBER, null quantity, msn.COST_GROUP_ID, null sec_qty --13399743
      FROM MTL_SERIAL_NUMBERS MSN, MTL_SERIAL_NUMBERS_INTERFACE MSNI,
	wms_lpn_contents wlpnc
      WHERE MSNI.PRODUCT_TRANSACTION_ID = p_rcv_trx_interface_id
      AND MSN.INVENTORY_ITEM_ID = p_item_id
      AND Nvl(MSN.revision,'@@@') = Nvl(p_item_revision,'@@@')
      AND MSN.SERIAL_NUMBER >= MSNI.FM_SERIAL_NUMBER
      AND MSN.SERIAL_NUMBER <= MSNI.to_serial_number
      AND msn.lpn_id = wlpnc.parent_lpn_id
      AND wlpnc.parent_lpn_id = p_lpn_id
      AND wlpnc.inventory_item_id = msn.inventory_item_id
      AND nvl(WLPNC.SOURCE_NAME,'@@@') not in ('RETURN TO RECEIVING','RETURN TO VENDOR', 'RETURN TO CUSTOMER')
      AND length(MSN.SERIAL_NUMBER) = length(MSNI.FM_SERIAL_NUMBER);


      l_uom := l_primary_uom;
   ELSE

      l_position := '0050';
      open c_ref for SELECT NULL , NULL , NULL , rti.quantity, wlpnc.cost_group_id, RTI.secondary_quantity sec_qty--13399743
      FROM WMS_LPN_CONTENTS WLPNC, RCV_TRANSACTIONS_INTERFACE RTI
      WHERE RTI.INTERFACE_TRANSACTION_ID = p_rcv_trx_interface_id
      AND WLPNC.PARENT_LPN_ID = p_lpn_id
      AND WLPNC.INVENTORY_ITEM_ID = RTI.ITEM_ID
      AND nvl(WLPNC.SOURCE_NAME,'@@@') not in ('RETURN TO RECEIVING','RETURN TO VENDOR', 'RETURN TO CUSTOMER')
      AND rownum <= 1;

      /* For a given LPN and Item combination there could be more
      ** than one record in wms_lpn_contents, but we need
      ** only one record as an output of this cursor
      */
     l_uom := p_uom;
   END IF;
   l_position := '0060';

   LOOP
      l_position := '0070';

      FETCH c_ref into l_lot_number, l_from_serial_number, l_to_serial_number, l_quantity, l_cost_group_id, l_sec_qty; --13399743
      l_position := '0080';


      IF c_ref%NOTFOUND THEN
         IF (l_debug = 1) THEN
            print_debug('Contents not found');
         END IF;
         EXIT;
      END IF;
      l_position := '0090';

      PackUnpack_Container(
         x_return_status    	        => x_return_status,
         x_msg_count			=> x_msg_count,
         x_msg_data			=> x_msg_data,
         p_lpn_id			=> p_lpn_id,
         p_content_item_id		=> p_item_id,
         p_revision			=> p_item_revision,
         p_lot_number			=> l_lot_number,
         p_from_serial_number	        => l_from_serial_number,
         p_to_serial_number		=> l_to_serial_number,
         p_quantity			=> abs(l_quantity),
         p_uom				=> l_uom,--BUG 4939647: For non-serial controlled item,always pass the txn uom
         p_organization_id		=> p_org_id,
         p_subinventory			=> p_subinventory,
         p_locator_id			=> p_locator_id,
         p_operation			=> 2, -- unpack
         p_source_header_id		=> NULL,
         p_source_name			=> NULL,
         P_COST_GROUP_ID		=> l_cost_group_id,
		 p_secondary_quantity           => abs(l_sec_qty) --13399743
      );
      l_position := '0100';

      if (x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	 IF (l_debug = 1) THEN
   	 print_debug('Error in mark_returns while unpacking');
	 END IF;
	 RAISE fnd_api.g_exc_error; --return; -- error while unpacking
      end if;

      PackUnpack_Container(
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data		  => x_msg_data,
         p_lpn_id		  => p_lpn_id,
         p_content_item_id	  => p_item_id,
         p_revision		  => p_item_revision   ,
         p_lot_number		  => l_lot_number,
         p_from_serial_number     => l_from_serial_number,
         p_to_serial_number	  => l_to_serial_number,
         p_quantity		  => abs(l_quantity),
         p_uom			  => l_uom,--R12: For non-serial controlled item,always pass the txn uom
         p_organization_id	  => p_org_id,
         p_subinventory		  => p_subinventory,
         p_locator_id		  => p_locator_id,
         p_operation		  => 1, -- pack
         p_source_header_id	  => p_rcv_trx_interface_id,
         p_source_name		  => p_ret_transaction_type,
         P_COST_GROUP_ID	  => l_cost_group_id,
		 p_secondary_quantity           => abs(l_sec_qty) --13399743
      );

      if (x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	 IF (l_debug = 1) THEN
   	 print_debug('Error in mark_returns while packing');
	 END IF;
	 RAISE fnd_api.g_exc_error; --return; -- error while packing
      end if;

   END LOOP;

   IF (l_lpn_context <> 0) THEN

      -- 4411792 Diecrt update to wlpn is replaced by the below call

      l_lpn_update.lpn_id          :=  p_lpn_id ;
      l_lpn_update.organization_id :=  p_org_id ;
      l_lpn_update.lpn_context     :=  l_lpn_context ;

      wms_container_pvt.Modify_LPN
             (
               p_api_version             => 1.0
               , p_validation_level      => fnd_api.g_valid_level_none
               , x_return_status         => l_return_status
               , x_msg_count             => l_msg_count
               , x_msg_data              => l_msg_data
               , p_lpn                   => l_lpn_update
      ) ;

      l_lpn_update := NULL;

      -- Bug 4411792
      --UPDATE wms_license_plate_numbers
      --SET lpn_context = l_lpn_context
      --WHERE organization_id = p_org_id
      --AND lpn_id = p_lpn_id;
   END IF;

   UPDATE mtl_txn_request_lines
      SET wms_process_flag = 2
        , txn_source_line_detail_id = p_rcv_trx_interface_id
    WHERE lpn_id = p_lpn_id;

   l_position := '0200';
   IF (l_debug = 1) THEN
      print_debug('Exit MARK_RETURNS');
   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      IF (l_debug = 1) THEN
         print_debug('mark_returns : execution error');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
   when others then
      IF (l_debug = 1) THEN
	 print_debug('Error(' || l_position || '):' || sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
      x_msg_data := x_msg_data||sqlerrm;
END MARK_RETURNS;

/*
--16197273
--Description:API to unmark the wms_lpn_contents table at the time of processing new rti/mti.
--This api will be called from RTV specific package :RCVWSHIB.pls
*/

PROCEDURE unmark_returns (
                       x_return_status        OUT NOCOPY VARCHAR2,
                       x_msg_count		      	OUT NOCOPY NUMBER,
                       x_msg_data		      	OUT NOCOPY VARCHAR2,
                       p_rcv_trx_interface_id IN NUMBER,
                       p_ret_transaction_type IN VARCHAR2,
                       p_lpn_id               IN NUMBER,
                       p_item_id              IN NUMBER,
                       p_item_revision        IN VARCHAR2,
                       p_org_id               IN NUMBER,
                       p_lot_number           IN VARCHAR2  )


  IS

  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_position VARCHAR2(4) := '0000';

 CURSOR c_unmark_wlc
  IS
  SELECT LPN_CONTENT_ID
  FROM wms_lpn_contents
  WHERE parent_lpn_id    = p_lpn_id
  AND inventory_item_id  = p_item_id
  AND organization_id    = p_org_id
  AND NVL(lot_number,      '@@@') = NVL(p_lot_number,'@@@')
  AND NVL(revision,        '@@@') = NVL(p_item_revision,'@@@')
  AND source_header_id  =   p_rcv_trx_interface_id
  AND source_name = p_ret_transaction_type;

  TYPE m_lpn_content_id IS TABLE OF    c_unmark_wlc%ROWTYPE;
  l_lpn_content_id         m_lpn_content_id;


  BEGIN

   l_position := '0010';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 1) THEN
       print_debug('RTV ER:Inside Unmark API ' ||  p_rcv_trx_interface_id );
       print_debug('RTV ER:Inside Unmark API ' ||  p_lpn_id );

   END if ;


   OPEN  c_unmark_wlc ;

   FETCH   c_unmark_wlc BULK COLLECT INTO  l_lpn_content_id ;

   CLOSE   c_unmark_wlc;


    FOR i IN 1..l_lpn_content_id.COUNT LOOP


        UPDATE wms_lpn_contents
        SET source_header_id = NULL,
        source_name        = NULL
        WHERE LPN_CONTENT_ID = l_lpn_content_id(i).LPN_CONTENT_ID ;

        l_position := '0020' ;

   END LOOP;

   IF (l_debug = 1) THEN

     print_debug('RTV ER:After Unmark API for  ' ||  p_lpn_id );

   END if ;



   l_position := '0030';
   IF (l_debug = 1) THEN
      print_debug('Exit UNMARK_RETURNS');
   END IF;

  EXCEPTION

     when others then
       IF (l_debug = 1) THEN
        l_position := '0040';
       print_debug('Error(' || l_position || '):' || sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
      x_msg_data := x_msg_data||sqlerrm;

END unmark_returns;

/*
--16197273
--Description:API to create container WDD and WDA  for Return order.
--This api will be called from RTV specific package :RCVWSHIB.pls

*/

PROCEDURE Create_Update_Containers_RTV (
          x_return_status OUT NOCOPY VARCHAR2
          ,x_msg_count     OUT NOCOPY NUMBER
          , x_msg_data      OUT NOCOPY VARCHAR2
          , p_interface_txn_id   IN   NUMBER
        , p_wdd_table WSH_GLBL_VAR_STRCT_GRP.delivery_details_Attr_tbl_Type

)IS


  CURSOR c_lpn_exist (v_lpn_id NUMBER) IS
    SELECT 1
    FROM wsh_delivery_details
    WHERE lpn_id = v_lpn_id
    AND released_status = 'X'
    and rownum <2;


  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_position VARCHAR2(4) := '0001';
  wsh_create_tbl  WSH_Glbl_Var_Strct_GRP.delivery_details_Attr_tbl_Type;
  l_IN_rec        WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
  l_OUT_rec       WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
  l_lpn_id        NUMBER ;
  l_wdd_exists    NUMBER ;
  l_return_status               VARCHAR2(1);
  l_shipping_attr              wsh_interface.changedattributetabtype;
  l_wsh_dd_rec WSH_Glbl_Var_Strct_GRP.Delivery_Details_Rec_Type;
  l_lpn_attr           WMS_Data_Type_Definitions_PUB.LPNRecordType;




BEGIN

  l_position := '0010';
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT transfer_lpn_id INTO l_lpn_id FROM rcv_transactions_interface
  WHERE interface_transaction_id = p_interface_txn_id;

   OPEN c_lpn_exist(l_lpn_id);
     FETCH c_lpn_exist INTO l_wdd_exists;
   CLOSE c_lpn_exist;

   IF l_wdd_exists = 1 THEN

     print_debug('Container WDD already exist for this lpn_id');


    ELSE

     BEGIN
        SELECT lpn_id
             , license_plate_number
             , parent_lpn_id
             , outermost_lpn_id
             , lpn_context
             , organization_id
             , subinventory_code
             , locator_id
             , inventory_item_id
             , revision
             , lot_number
             , serial_number
             , cost_group_id
             , tare_weight_uom_code
             , tare_weight
             , gross_weight_uom_code
             , gross_weight
             , container_volume_uom
             , container_volume
             , content_volume_uom_code
             , content_volume
             , source_type_id
             , source_header_id
             , source_line_id
             , source_line_detail_id
             , source_name
             , attribute_category
             , attribute1
             , attribute2
             , attribute3
             , attribute4
             , attribute5
             , attribute6
             , attribute7
             , attribute8
             , attribute9
             , attribute10
             , attribute11
             , attribute12
             , attribute13
             , attribute14
             , attribute15
          INTO l_lpn_attr.lpn_id
             , l_lpn_attr.license_plate_number
             , l_lpn_attr.parent_lpn_id
             , l_lpn_attr.outermost_lpn_id
             , l_lpn_attr.lpn_context
             , l_lpn_attr.organization_id
             , l_lpn_attr.subinventory_code
             , l_lpn_attr.locator_id
             , l_lpn_attr.inventory_item_id
             , l_lpn_attr.revision
             , l_lpn_attr.lot_number
             , l_lpn_attr.serial_number
             , l_lpn_attr.cost_group_id
             , l_lpn_attr.tare_weight_uom_code
             , l_lpn_attr.tare_weight
             , l_lpn_attr.gross_weight_uom_code
             , l_lpn_attr.gross_weight
             , l_lpn_attr.container_volume_uom
             , l_lpn_attr.container_volume
             , l_lpn_attr.content_volume_uom_code
             , l_lpn_attr.content_volume
             , l_lpn_attr.source_type_id
             , l_lpn_attr.source_header_id
             , l_lpn_attr.source_line_id
             , l_lpn_attr.source_line_detail_id
             , l_lpn_attr.source_name
             , l_lpn_attr.attribute_category
             , l_lpn_attr.attribute1
             , l_lpn_attr.attribute2
             , l_lpn_attr.attribute3
             , l_lpn_attr.attribute4
             , l_lpn_attr.attribute5
             , l_lpn_attr.attribute6
             , l_lpn_attr.attribute7
             , l_lpn_attr.attribute8
             , l_lpn_attr.attribute9
             , l_lpn_attr.attribute10
             , l_lpn_attr.attribute11
             , l_lpn_attr.attribute12
             , l_lpn_attr.attribute13
             , l_lpn_attr.attribute14
             , l_lpn_attr.attribute15
        FROM   wms_license_plate_numbers
        WHERE  lpn_id = l_lpn_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;



    wsh_create_tbl(1) := wms_container_pvt.To_DeliveryDetailsRecType(l_lpn_attr);


   IF ( wsh_create_tbl.last > 0 ) THEN
       IF (l_debug = 1) THEN
        print_debug('Calling WSH API to creat Container WDD');
       END IF;

      l_IN_rec.caller      := 'WMS';
      l_IN_rec.action_code := 'CREATE';

      WSH_WMS_LPN_GRP.Create_Update_Containers (
        p_api_version     => 1.0
      , p_init_msg_list   => fnd_api.g_false
      , p_commit          => fnd_api.g_false
      , x_return_status   => x_return_status
      , x_msg_count       => x_msg_count
      , x_msg_data        => x_msg_data
      , p_detail_info_tab => wsh_create_tbl
      , p_IN_rec          => l_IN_rec
      , x_OUT_rec         => l_OUT_rec );


      IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
        IF (l_debug = 1) THEN
          print_debug('Create_Update_Containers Failed');
        END IF ;

      END IF;
  -- Once Create is done need to clear table
        wsh_create_tbl.delete;
    END IF;

  END IF ;

 --Calling update shipping attributes

      IF (l_debug = 1) THEN
          print_debug('Calling update shipping attributes for all content WDD');
        END IF ;



   FOR i IN 1 .. p_wdd_table.Count  LOOP


       IF (l_debug = 1) THEN
       print_debug('after update shipping attributes for WDD:delivery_detail_id' ||  p_wdd_table(i).delivery_detail_id);
       print_debug('after update shipping attributes for WDD:source_header_id' ||  p_wdd_table(i).source_header_id);
       print_debug('after update shipping attributes for WDD:source_line_id' ||  p_wdd_table(i).source_line_id);
       print_debug('after update shipping attributes for WDD:organization_id' ||  p_wdd_table(i).organization_id);
       print_debug('after update shipping attributes for WDD:subinventory' ||  p_wdd_table(i).subinventory);
       print_debug('after update shipping attributes for WDD:revision' ||  p_wdd_table(i).revision);
       print_debug('after update shipping attributes for WDD:locator_id' ||  p_wdd_table(i).locator_id);
       print_debug('after update shipping attributes for WDD:lot_number' ||  p_wdd_table(i).lot_number);

      END IF;

      l_shipping_attr(i).source_header_id    := p_wdd_table(i).source_header_id;
      l_shipping_attr(i).source_line_id      := p_wdd_table(i).source_line_id;
      l_shipping_attr(i).ship_from_org_id    := p_wdd_table(i).organization_id;
      l_shipping_attr(i).subinventory        := p_wdd_table(i).subinventory;
      l_shipping_attr(i).revision            := p_wdd_table(i).revision;
      l_shipping_attr(i).locator_id          := p_wdd_table(i).locator_id;
      l_shipping_attr(i).released_status     := 'X';
      l_shipping_attr(i).delivery_detail_id  := p_wdd_table(i).delivery_detail_id;
      --l_shipping_attr(1).serial_number     := l_serial_number;
      l_shipping_attr(i).lot_number        := p_wdd_table(i).lot_number;
      l_shipping_attr(i).transfer_lpn_id      := l_lpn_id  ;

      wsh_interface.update_shipping_attributes(
                   p_source_code => 'INV',
                   p_changed_attributes => l_shipping_attr,
                   x_return_status => l_return_status);



    END LOOP ;


    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
        IF (l_debug = 1) THEN
             print_debug('return error from update shipping attributes');
         END IF;
          RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         IF (l_debug = 1) THEN
             print_debug('return error from update shipping attributes');
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;


EXCEPTION
  WHEN OTHERS THEN
     IF (l_debug = 1) THEN
       l_position := '0040';
       print_debug('Error(' || l_position || '):' || sqlerrm);
     END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
      x_msg_data := x_msg_data||sqlerrm;

 END  Create_Update_Containers_RTV;

 /*
 --16197273
 --Description;API created to do post TM updates from WMS side .

 */

PROCEDURE perform_post_TM_wms_updates (
                    x_return_status        OUT NOCOPY VARCHAR2,
                    p_rcv_trx_interface_id IN NUMBER   )

 IS

  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_position VARCHAR2(4) := '0000';

  l_lpn_id   NUMBER ;
  v_dummy    NUMBER ;


  BEGIN


   l_position := '0010';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 1) THEN
    print_debug('RTV ER: perform_post_TM_wms_updates ::' || p_rcv_trx_interface_id );
   END IF;

   BEGIN

       SELECT 1  INTO v_dummy
       FROM   rcv_transactions_interface rti,wms_license_plate_numbers wlpn
       WHERE  rti.interface_transaction_id = p_rcv_trx_interface_id
       AND rti.processing_status_code = 'WSH_INTERFACED'
       AND rti.transfer_lpn_id = wlpn.lpn_id
       AND wlpn.lpn_context  = 5
       AND rti.to_organization_id = wlpn.organization_id  ;


       IF (l_debug = 1) THEN
           print_debug('Master LPN is shipped.' );
        END IF;


       SELECT DISTINCT parent_lpn_id INTO  l_lpn_id  FROM wms_lpn_contents WHERE
       source_header_id  =   p_rcv_trx_interface_id
       AND source_name = 'RETURN TO VENDOR'
       AND ROWNUM < 2 ;

       IF (l_debug = 1) THEN
           print_debug('Before updating master RTI for the remaining qty.' );
        END IF;

       UPDATE rcv_transactions_interface SET transfer_lpn_id =  l_lpn_id
       WHERE
       interface_transaction_id =  p_rcv_trx_interface_id
       AND processing_status_code = 'WSH_INTERFACED' ;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
           print_debug('Master LPN not shipped.' );
        END IF;

        NULL;

        END;


     EXCEPTION
     WHEN OTHERS THEN

       IF (l_debug = 1) THEN
        l_position := '0040';
	print_debug('Error(' || l_position || '):' || sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;


END   perform_post_TM_wms_updates ;




/*
** This Procedure is called from the Corrections Form to Pack the LPN Contents
** that are selected for +ve correction into Receiving.
*/

PROCEDURE PACK_INTO_RECEIVING (
   x_return_status	   	OUT NOCOPY VARCHAR2,
   x_msg_count		      	OUT NOCOPY NUMBER,
   x_msg_data		      	OUT NOCOPY VARCHAR2,
   p_rcv_trx_interface_id 	IN NUMBER,
   p_ret_transaction_type 	IN VARCHAR2,
   p_lpn_id 			IN NUMBER,
   p_item_id 			IN NUMBER,
   p_item_revision 		IN VARCHAR2,
   p_quantity 			IN NUMBER,
   p_uom 			IN VARCHAR2,
   p_serial_controlled 	  	IN NUMBER,
   p_lot_controlled 	  	IN NUMBER,
   p_org_id 			IN NUMBER
) IS

-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_lot_number VARCHAR2(80);
   l_from_serial_number VARCHAR2(50);
   l_to_serial_number VARCHAR2(50);
   l_quantity number;
   l_cost_group_id number;
   TYPE c_ref_type IS REF CURSOR;
   c_ref c_ref_type;
   l_position VARCHAR2(4) := '0000';

   l_wms_po_j_higher BOOLEAN;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    l_position := '0010';
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* FP-J Lot/Serial Support Enhancement
     * Read the currentand PO patch levels and set the flag (that would be used to
     * match the Lot Number and the LPN) accordingly
     */
       IF ((WMS_UI_TASKS_APIS.g_wms_patch_level >= WMS_UI_TASKS_APIS.g_patchset_j) AND
	   (WMS_UI_TASKS_APIS.g_po_patch_level >= WMS_UI_TASKS_APIS.g_patchset_j_po)) THEN
	  l_wms_po_j_higher := TRUE;
	  IF (l_debug = 1) THEN
	     print_debug('PACK_INTO_RECEIVING:WMS and PO patch levels are J or higher', 4);
	  END IF;
	ELSE
	  l_wms_po_j_higher := FALSE;
	  IF (l_debug = 1) THEN
	     print_debug('PACK_INTO_RECEIVING:Either WMS or/and PO patch level(s) are lower than J', 4);
	  END IF;
       END IF;

  IF (l_wms_po_j_higher = FALSE) THEN

    IF (l_debug = 1) THEN
       print_debug('Enter PACK_INTO_RECEIVING');
       print_debug('p_serial_controlled => ' || p_serial_controlled);
       print_debug('p_lot_controlled    => ' || p_lot_controlled);
    END IF;

    IF  p_lot_controlled = 2 AND p_serial_controlled in (2,5) THEN
	    	l_position := '0020';
        open c_ref for SELECT mtlt.lot_number, MSN.SERIAL_NUMBER FM_SERIAL_NUMBER,
            MSN.SERIAL_NUMBER TO_SERIAL_NUMBER, null quantity
            FROM MTL_SERIAL_NUMBERS MSN, MTL_SERIAL_NUMBERS_TEMP MSNT, MTL_TRANSACTION_LOTS_TEMP MTLT
            WHERE MTLT.TRANSACTION_TEMP_ID = p_rcv_trx_interface_id
            AND MSNT.TRANSACTION_TEMP_ID = MTLT.SERIAL_TRANSACTION_TEMP_ID
            AND MSN.INVENTORY_ITEM_ID = p_item_id
            AND Nvl(MSN.revision,'@@@') = Nvl(p_item_revision,'@@@')
            --AND MSN.LOT_NUMBER = MTLT.LOT_NUMBER
            AND MSN.SERIAL_NUMBER >= MSNT.FM_SERIAL_NUMBER
            AND MSN.SERIAL_NUMBER <= MSNT.TO_SERIAL_NUMBER;
--          AND length(MSN.SERIAL_NUMBER) = length(MSNT.FM_SERIAL_NUMBER);
-- It is not possible to use length function here because table MTL_TRANSACTION_LOTS_TEMP
-- has a field 'length' and it would result in a compilation error if function length
-- is used.

	ELSIF p_lot_controlled = 2 AND p_serial_controlled not in (2,5) THEN
	    	l_position := '0030';
		open c_ref for SELECT MTLT.LOT_NUMBER, NULL FM_SERIAL_NUMBER,
			NULL TO_SERIAL_NUMBER, MTLT.TRANSACTION_QUANTITY quantity
			FROM MTL_TRANSACTION_LOTS_TEMP MTLT
			WHERE MTLT.TRANSACTION_TEMP_ID = p_rcv_trx_interface_id;

	ELSIF p_lot_controlled <> 2 AND p_serial_controlled in (2,5) THEN
	    	l_position := '0040';
		open c_ref for SELECT NULL LOT_NUMBER, MSN.SERIAL_NUMBER FM_SERIAL_NUMBER,
			MSN.SERIAL_NUMBER TO_SERIAL_NUMBER, null quantity
			FROM MTL_SERIAL_NUMBERS MSN, MTL_SERIAL_NUMBERS_TEMP MSNT
			WHERE MSNT.TRANSACTION_TEMP_ID = p_rcv_trx_interface_id
      			AND MSN.INVENTORY_ITEM_ID = p_item_id
		        AND Nvl(MSN.revision,'@@@') = Nvl(p_item_revision,'@@@')
			AND MSN.SERIAL_NUMBER >= MSNT.FM_SERIAL_NUMBER
			AND MSN.SERIAL_NUMBER <= MSNT.TO_SERIAL_NUMBER
			AND length(MSN.SERIAL_NUMBER) = length(MSNT.FM_SERIAL_NUMBER);

	ELSE
	    	l_position := '0050';
		open c_ref for SELECT NULL , NULL , NULL , rti.quantity
			FROM RCV_TRANSACTIONS_INTERFACE RTI
			WHERE RTI.INTERFACE_TRANSACTION_ID = p_rcv_trx_interface_id;

	END IF;
	l_position := '0060';

    LOOP
    	l_position := '0070';

	FETCH c_ref into l_lot_number, l_from_serial_number, l_to_serial_number, l_quantity;
    	l_position := '0080';

	IF c_ref%NOTFOUND THEN EXIT; END IF;
    	l_position := '0090';

	/* Update the previous_status of serial to current_status before doing anything.
	** This is needed so that current_status can be put back to previous_status
	** if the txn fails. Bringing back the status is done in txn_complete
	** if txn fails.
	*/
	IF l_from_serial_number IS NOT NULL THEN
	   UPDATE mtl_serial_numbers
	     SET previous_status = current_status
	     WHERE serial_number = l_from_serial_number
	     AND inventory_item_id = p_item_id;
	END IF;

	PackUnpack_Container(
   		x_return_status		=> x_return_status,
   		x_msg_count		=> x_msg_count,
   		x_msg_data		=> x_msg_data,
   		p_lpn_id		=> p_lpn_id,
   		p_content_item_id	=> p_item_id,
		p_revision		=> p_item_revision   ,
		p_lot_number		=> l_lot_number,
		p_from_serial_number	=> l_from_serial_number,
		p_to_serial_number	=> l_to_serial_number,
		p_quantity		=> abs(l_quantity),
		p_uom			=> p_uom,
		p_organization_id	=> p_org_id,
		p_subinventory		=> NULL,
		p_locator_id		=> NULL,
		p_operation		=> 1, -- pack
		p_source_header_id	=> p_rcv_trx_interface_id,
		p_source_name		=> p_ret_transaction_type,
		P_COST_GROUP_ID		=> NULL
		);

	if (x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	   IF (l_debug = 1) THEN
   	   print_debug('Error in PACK_INTO_RECEIVING while packing');
	   END IF;
	   RAISE fnd_api.g_exc_error; --return; -- error while packing
	end if;

    END LOOP;

    UPDATE wms_license_plate_numbers
      SET lpn_context = wms_container_pub.lpn_context_rcv
      WHERE lpn_id = p_lpn_id;

        UPDATE mtl_txn_request_lines
	  SET wms_process_flag = 2
	    , txn_source_line_detail_id = p_rcv_trx_interface_id
        WHERE lpn_id = p_lpn_id;

    l_position := '0200';
    IF (l_debug = 1) THEN
       print_debug('Exit PACK_INTO_RECEIVING');
    END IF;
  END IF;--IF (l_wms_po_j_higher = FALSE) THEN

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      IF (l_debug = 1) THEN
         print_debug('maintain_move_orders : execution error');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
   when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);
      x_msg_data := x_msg_data||sqlerrm;
      IF (l_debug = 1) THEN
         print_debug('Error(' || l_position || '):' || sqlerrm);
      END IF;
END PACK_INTO_RECEIVING;

/*
** This procedure is called from Mobile Returns when the input LPN
** is totally marked for Return.
*/

PROCEDURE PROCESS_WHOLE_LPN_RETURN (
                            x_return_status        OUT NOCOPY VARCHAR2
               ,            x_msg_count            OUT NOCOPY NUMBER
               ,            x_msg_data             OUT NOCOPY VARCHAR2
               ,            p_org_id               IN  NUMBER
               ,            p_lpn_id               IN  NUMBER
               ,            p_txn_proc_mode        IN  VARCHAR2
               ,            p_group_id             IN  NUMBER
                           ) IS
        l_rtiid   NUMBER;

        TYPE c_ref_type IS REF CURSOR;
        c_ref     c_ref_type;
        c_ref_ser c_ref_type;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

        IF (l_debug = 1) THEN
           print_debug('Enter PROCESS_WHOLE_LPN_RETURN');
           print_debug('Called PROCESS_WHOLE_LPN_RETURN with the parameters');
        END IF;

        IF (l_debug = 1) THEN
           print_debug('p_org_id                      =>' || p_org_id);
           print_debug('p_lpn_id                      =>' || p_lpn_id);
           print_debug('p_txn_proc_mode               =>' || p_txn_proc_mode);
           print_debug('p_group_id                    =>' || p_group_id);
        END IF;

        x_return_status := fnd_api.g_ret_sts_success;

       open c_ref for  SELECT SOURCE_HEADER_ID
		       FROM   WMS_LPN_CONTENTS WLPNC
		       WHERE  WLPNC.ORGANIZATION_ID 	      =	p_org_id
		       AND    WLPNC.PARENT_LPN_ID             = p_lpn_id
 		       AND    NVL(SERIAL_SUMMARY_ENTRY,2)    <> 1	-- Non Serial Contents Records(value=2)
		       AND    WLPNC.SOURCE_NAME IN ('RETURN TO VENDOR',
						    'RETURN TO CUSTOMER',
                                                    'RETURN TO RECEIVING');

        LOOP
                FETCH c_ref into l_rtiid;
                IF c_ref%NOTFOUND THEN
                        EXIT;
                END IF;
                IF (l_debug = 1) THEN
                   print_debug('l_rtiid    =>' || l_rtiid);
                END IF;

                UPDATE RCV_TRANSACTIONS_INTERFACE
                SET    GROUP_ID = p_group_id,
                       PROCESSING_MODE_CODE = p_txn_proc_mode,
                       MOBILE_TXN = 'Y'
                WHERE  INTERFACE_TRANSACTION_ID = l_rtiid;
        END LOOP;
        IF (l_debug = 1) THEN
           print_debug('END OF LOOP PROCESS WHOLE LPN RETURN - Non Serial Contents Records');
        END IF;

        open c_ref_ser for SELECT LAST_TXN_SOURCE_ID
		           FROM   MTL_SERIAL_NUMBERS MSN
		           WHERE  MSN.LPN_ID                    = p_lpn_id
		           AND    MSN.LAST_TXN_SOURCE_NAME IN ('RETURN TO VENDOR',
							       'RETURN TO CUSTOMER',
							       'RETURN TO RECEIVING');

       LOOP
                FETCH c_ref_ser into l_rtiid;
                IF c_ref_ser%NOTFOUND THEN
                        EXIT;
                END IF;
                IF (l_debug = 1) THEN
                   print_debug('l_rtiid    =>' || l_rtiid);
                END IF;

                UPDATE RCV_TRANSACTIONS_INTERFACE
                SET    GROUP_ID = p_group_id,
                       PROCESSING_MODE_CODE = p_txn_proc_mode,
                       MOBILE_TXN = 'Y'
                WHERE  INTERFACE_TRANSACTION_ID = l_rtiid;
        END LOOP;
        IF (l_debug = 1) THEN
           print_debug('END OF LOOP PROCESS WHOLE LPN RETURN - Serial Records');
        END IF;

   EXCEPTION
        WHEN fnd_api.g_exc_error THEN

                x_return_status := fnd_api.g_ret_sts_error;
                IF (l_debug = 1) THEN
                   print_debug('x_return_status    =>' || x_return_status);
                END IF;

                --  Get message count and data
                fnd_msg_pub.count_and_get
                  (  p_count  => x_msg_count
                   , p_data   => x_msg_data
                    );

                IF (c_ref%isopen) THEN
                        CLOSE c_ref;
                END IF;
                IF (c_ref_ser%isopen) THEN
                        CLOSE c_ref_ser;
                END IF;


        WHEN fnd_api.g_exc_unexpected_error THEN

                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                IF (l_debug = 1) THEN
                   print_debug('x_return_status    =>' || x_return_status);
                END IF;

              --  Get message count and data
              fnd_msg_pub.count_and_get
                  (  p_count  => x_msg_count
                   , p_data   => x_msg_data
                    );

                IF (c_ref%isopen) THEN
                        CLOSE c_ref;
                END IF;
                IF (c_ref_ser%isopen) THEN
                        CLOSE c_ref_ser;
                END IF;


        WHEN others THEN

                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                IF (l_debug = 1) THEN
                   print_debug('x_return_status    =>' || x_return_status);
                END IF;
              --
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
              THEN
                 fnd_msg_pub.add_exc_msg
                   (  g_pkg_name
                      , 'main_process'
                      );
              END IF;

              --  Get message count and data
              fnd_msg_pub.count_and_get
                  (  p_count  => x_msg_count
                   , p_data   => x_msg_data
                    );

                IF (c_ref%isopen) THEN
                        CLOSE c_ref;
                END IF;
                IF (c_ref_ser%isopen) THEN
                        CLOSE c_ref_ser;
                END IF;

END PROCESS_WHOLE_LPN_RETURN;


/*
** This procedure is called from Mobile Returns when the input LPN
** is partially marked for Return.
*/

PROCEDURE PROCESS_RETURNS (
                            x_return_status        OUT NOCOPY VARCHAR2
               ,            x_msg_count            OUT NOCOPY NUMBER
               ,            x_msg_data             OUT NOCOPY VARCHAR2
               ,            p_org_id               IN  NUMBER
               ,            p_lpn_id               IN  NUMBER
               ,            p_item_id              IN  NUMBER
               ,            p_item_revision        IN  VARCHAR2
               ,            p_uom                  IN  VARCHAR2
               ,            p_lot_code             IN  VARCHAR2
               ,            p_serial_code          IN  VARCHAR2
               ,            p_quantity             IN  NUMBER
               ,            p_serial_controlled    IN  NUMBER
               ,            p_lot_controlled       IN  NUMBER
               ,            p_txn_proc_mode        IN  VARCHAR2
               ,            p_group_id             IN  NUMBER
	       ,	    p_to_lpn_id		   IN  NUMBER
                           ) IS
	l_rtiid   NUMBER;

        TYPE c_ref_type IS REF CURSOR;
        c_ref c_ref_type;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

	x_return_status := fnd_api.g_ret_sts_success;

        IF (l_debug = 1) THEN
           print_debug('Enter PROCESS_RETURNS');
           print_debug('Called PROCESS_RETURNS with the parameters');
        END IF;

        IF (l_debug = 1) THEN
           print_debug('p_org_id                      =>' || p_org_id);
           print_debug('p_lpn_id                      =>' || p_lpn_id);
   		print_debug('p_item_id			   =>' || p_item_id);
           print_debug('p_item_revision               =>' || p_item_revision);
           print_debug('p_uom                         =>' || p_uom);
           print_debug('p_lot_code                    =>' || p_lot_code);
           print_debug('p_serial_code                 =>' || p_serial_code);
           print_debug('p_quantity                    =>' || p_quantity);
           print_debug('p_serial_controlled           =>' || p_serial_controlled);
           print_debug('p_lot_controlled              =>' || p_lot_controlled);
           print_debug('p_txn_proc_mode               =>' || p_txn_proc_mode);
           print_debug('p_group_id                    =>' || p_group_id);
           print_debug('p_to_lpn_id                   =>' || p_to_lpn_id);
        END IF;

 	IF  p_lot_controlled = 2 AND p_serial_controlled = 2 THEN  	-- NonSerial and NonLot
                open c_ref for SELECT SOURCE_HEADER_ID
                               FROM   WMS_LPN_CONTENTS WLPNC
                               WHERE  WLPNC.ORGANIZATION_ID = p_org_id
                               AND    WLPNC.PARENT_LPN_ID             = p_lpn_id
                               AND    WLPNC.INVENTORY_ITEM_ID         = p_item_id
                               AND    ((WLPNC.revision = p_item_revision AND p_item_revision IS NOT NULL) OR
                                       (WLPNC.REVISION IS NULL AND p_item_revision IS NULL))
                               AND    WLPNC.SOURCE_NAME IN ('RETURN TO VENDOR',
                                                            'RETURN TO CUSTOMER',
                                                            'RETURN TO RECEIVING');

        ELSIF p_serial_controlled = 1 THEN				-- Serial, Lot control doesn't matter
                open c_ref for SELECT LAST_TXN_SOURCE_ID
                               FROM   MTL_SERIAL_NUMBERS MSN
                               WHERE  MSN.LPN_ID                    = p_lpn_id
                               AND    MSN.INVENTORY_ITEM_ID         = p_item_id
                               AND    ((MSN.REVISION = p_item_revision AND p_item_revision IS NOT NULL) OR
                                       (MSN.REVISION IS NULL AND p_item_revision IS NULL))
                               AND    MSN.LAST_TXN_SOURCE_NAME IN ('RETURN TO VENDOR',
                                                                   'RETURN TO CUSTOMER',
                                                                   'RETURN TO RECEIVING')
                               AND    MSN.SERIAL_NUMBER = p_serial_code;

        ELSIF p_lot_controlled = 1 AND p_serial_controlled = 2 THEN	-- Lot Only
                open c_ref for SELECT SOURCE_HEADER_ID
                               FROM   WMS_LPN_CONTENTS WLPNC
                               WHERE  WLPNC.ORGANIZATION_ID   = p_org_id
                               AND    WLPNC.PARENT_LPN_ID            = p_lpn_id
                               AND    WLPNC.INVENTORY_ITEM_ID = p_item_id
                               AND    ((WLPNC.REVISION = p_item_revision AND p_item_revision IS NOT NULL) OR
                                       (WLPNC.REVISION IS NULL AND p_item_revision IS NULL))
                               AND    WLPNC.SOURCE_NAME IN ('RETURN TO VENDOR',
                                                            'RETURN TO CUSTOMER',
                                                            'RETURN TO RECEIVING')
                               AND    WLPNC.LOT_NUMBER = p_lot_code;

        END IF;

   	LOOP
        	FETCH c_ref into l_rtiid;
        	IF c_ref%NOTFOUND THEN
			EXIT;
		END IF;
		IF (l_debug = 1) THEN
   		print_debug('l_rtiid	=>' || l_rtiid);
		END IF;

		UPDATE RCV_TRANSACTIONS_INTERFACE
		SET    GROUP_ID = p_group_id,
		       PROCESSING_MODE_CODE = p_txn_proc_mode,
		       MOBILE_TXN = 'Y'
		WHERE  INTERFACE_TRANSACTION_ID = l_rtiid;

IF (l_debug = 1) THEN
   print_debug('yes, p_to_lpn_id not zero ' || to_char(p_to_lpn_id));
END IF;
		IF p_to_lpn_id <> 0 THEN
IF (l_debug = 1) THEN
   print_debug('yes, p_to_lpn_id not zero ' || to_char(p_to_lpn_id));
END IF;
			UPDATE RCV_TRANSACTIONS_INTERFACE
			SET    TRANSFER_LPN_ID = p_to_lpn_id
			WHERE  INTERFACE_TRANSACTION_ID = l_rtiid
			AND    NVL(TRANSACTION_TYPE, '@@@') = 'RETURN TO RECEIVING';
		END IF;

	END LOOP;
	COMMIT;
	IF (l_debug = 1) THEN
   	print_debug('END OF LOOP PROCESS RETURNS');
	END IF;

   EXCEPTION
   	WHEN fnd_api.g_exc_error THEN

      		x_return_status := fnd_api.g_ret_sts_error;
		IF (l_debug = 1) THEN
   		print_debug('x_return_status	=>' || x_return_status);
		END IF;

		--  Get message count and data
		fnd_msg_pub.count_and_get
		  (  p_count  => x_msg_count
		   , p_data   => x_msg_data
		    );

		IF (c_ref%isopen) THEN
			CLOSE c_ref;
		END IF;


   	WHEN fnd_api.g_exc_unexpected_error THEN

		x_return_status := fnd_api.g_ret_sts_unexp_error ;
		IF (l_debug = 1) THEN
   		print_debug('x_return_status	=>' || x_return_status);
		END IF;

	      --  Get message count and data
	      fnd_msg_pub.count_and_get
		  (  p_count  => x_msg_count
		   , p_data   => x_msg_data
		    );

		IF (c_ref%isopen) THEN
			CLOSE c_ref;
		END IF;


   	WHEN others THEN

		x_return_status := fnd_api.g_ret_sts_unexp_error ;
		IF (l_debug = 1) THEN
   		print_debug('x_return_status	=>' || x_return_status);
		END IF;
	      --
	      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	      THEN
		 fnd_msg_pub.add_exc_msg
		   (  g_pkg_name
		      , 'main_process'
		      );
	      END IF;

	      --  Get message count and data
	      fnd_msg_pub.count_and_get
		  (  p_count  => x_msg_count
		   , p_data   => x_msg_data
		    );

		IF (c_ref%isopen) THEN
			CLOSE c_ref;
		END IF;


END PROCESS_RETURNS;

/*
** This Function is called from procedure 'GET_TRX_VALUES' to get Receiving
** Processing Mode.
*/

FUNCTION GET_TRX_PROC_MODE RETURN VARCHAR2 IS
	/*
	** Function will return Receiving Transaction Processor Mode (RCV_TP_MODE)
	** If Transaction Processor Mode is NULL then
	**   Default the Mode to 'ONLINE'
	** Function will be referencing a 'FND_PROFILE.GET' procedure defined
	** by AOL grp . It will return the value of the PROFILE being asked for,
	** or will return 'ONLINE' if profile 'RCV_TP_MODE' is NULL.
	*/
   transaction_processor_value VARCHAR2(10);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
           fnd_profile.get('RCV_TP_MODE',transaction_processor_value);

           if transaction_processor_value is null then
              transaction_processor_value := 'ONLINE';
           end if;

	   return(transaction_processor_value);

           EXCEPTION
           WHEN OTHERS THEN
		IF (l_debug = 1) THEN
   		print_debug('Failure getting transaction processing mode');
		END IF;
           RAISE;

END GET_TRX_PROC_MODE;

/*
** This procedure is called from Mobile Returns to determine the
** Receiving Processing Mode and Group ID from sequence that are used
** to stamp on RTI. This single wrapper procedure is created so that Mobile
** Returns visits Database only once to get both Receiving Processing Mode
** and Group ID.
*/

PROCEDURE GET_TRX_VALUES(
			transaction_processor_value OUT NOCOPY VARCHAR2
	,		group_id                    OUT NOCOPY NUMBER) IS
   l_groupid NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	   transaction_processor_value := GET_TRX_PROC_MODE;
	   SELECT RCV_INTERFACE_GROUPS_S.NEXTVAL INTO l_groupid FROM DUAL;

	   group_id := l_groupid;
	   EXCEPTION
	   WHEN OTHERS THEN
		IF (l_debug = 1) THEN
   		print_debug('Failure getting TXN PROC MODE and GROUPID');
		END IF;
	   RAISE;

END GET_TRX_VALUES;

/*
** This procedure is called from Mobile Returns to launch the Receiving
** Processor after setting the input group ID and receiving processing mode.
*/

PROCEDURE RCV_PROCESS_WRAPPER(
                                x_return_status OUT NOCOPY VARCHAR2
    		,	 	x_msg_data      OUT NOCOPY VARCHAR2
		,		p_trx_proc_mode IN  VARCHAR2
		,		p_group_id      IN  NUMBER) IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	inv_rcv_common_apis.g_po_startup_value.transaction_mode := p_trx_proc_mode;
	inv_rcv_common_apis.g_rcv_global_var.interface_group_id := p_group_id;
	INV_RCV_MOBILE_PROCESS_TXN.rcv_process_receive_txn(x_return_status, x_msg_data);
END RCV_PROCESS_WRAPPER;

/*
** This procedure is called from Mobile Returns to get the suggested 'To LPN'
** if any, for the input From LPN and Item.
*/

PROCEDURE GET_SUGGESTED_TO_LPN(
		x_lpn_lov  OUT  NOCOPY t_genref
	,	p_org_id   IN   NUMBER
	,	p_lpn_id   IN   NUMBER
	,	p_item_id  IN	NUMBER
	, 	p_revision IN 	VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	OPEN x_lpn_lov FOR
		select distinct wlpnc.license_plate_number
		from   wms_license_plate_numbers wlpnc, rcv_transactions_interface rti
		where  rti.lpn_id = p_lpn_id
		and    rti.item_id = p_item_id
		and    nvl(rti.item_revision, '@@@') = nvl(p_revision, '@@@')
		and    nvl(rti.transaction_type, '@@@') = 'RETURN TO RECEIVING'
		and    rti.transfer_lpn_id is not null
		and    wlpnc.lpn_id = rti.transfer_lpn_id
		and    wlpnc.organization_id = p_org_id;
END GET_SUGGESTED_TO_LPN;

/* This procedure is used to create a reservation during a Return. Called
** from RCVTXERE.pld after creating an rcv_transaction_interface_record
*/
  PROCEDURE CREATE_RETURN_RESV(
			       x_return_status     OUT NOCOPY VARCHAR2,
			       x_msg_count         OUT NOCOPY VARCHAR2,
			       x_msg_data          OUT NOCOPY VARCHAR2,
			       p_org_id            IN NUMBER,
			       p_item_id           IN NUMBER,
			       p_revision          IN VARCHAR2,
			       p_subinventory_code IN VARCHAR2,
			       p_locator_id        IN NUMBER,
			       p_lpn_id            IN NUMBER,
			       p_reservation_qty   IN NUMBER,
			       p_unit_of_measure   IN VARCHAR2,
			       p_requirement_date  IN DATE,
			       p_dem_src_type_id   IN NUMBER,
			       p_dem_src_hdr_id    IN NUMBER,
			       p_dem_src_line_id   IN NUMBER,
			       p_intf_txn_id       IN NUMBER
			       ) IS

  /* Reservation Data Structures */
  l_mtl_reservation_tbl_count NUMBER;
  l_reservation_record        INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE;
  l_qry_reservation_record    INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE;
  l_upd_reservation_record    INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE;
  l_upd_reservation_tbl       INV_RESERVATION_GLOBAL.MTL_RESERVATION_TBL_TYPE;
  l_upd_reservation_tbl_cnt   NUMBER := 0;
  l_dummy_sn                  INV_RESERVATION_GLOBAL.SERIAL_NUMBER_TBL_TYPE;
  l_lot_number                MTL_LOT_NUMBERS.LOT_NUMBER%TYPE;  --Lot Number
  l_uom_code                  VARCHAR2(3);    --UOM Code
  l_quantity_reserved         NUMBER;  --Quantity that was reserved
  l_reservation_id            NUMBER;  --Reservation Id
  l_error_code                NUMBER;
  l_item_primary_uom          VARCHAR2(3);
  l_primary_res_qty           NUMBER;
  l_res_lpn_id                NUMBER;
  l_create_res                BOOLEAN := TRUE;
  l_lot_control_code          NUMBER := 1;

  CURSOR c_lots IS
     SELECT lot_number, primary_quantity
       FROM mtl_transaction_lots_temp
       WHERE product_code = 'RCV'
       AND product_transaction_id = p_intf_txn_id;

  CURSOR c_lots_old IS
     SELECT lot_number, primary_quantity
       FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = p_intf_txn_id;

  l_wms_po_j_higher BOOLEAN;

  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  IF (l_debug = 1) THEN
     print_debug('CREATE_RETURN_RESV:Interface Transaction ID:'||p_intf_txn_id,1);
  END IF;

  --Get the UOM code based on the Unit of Measure passed
  --For expense items, UOM would be null
  SELECT uom_code
    INTO   l_uom_code
    FROM   mtl_item_uoms_view
    WHERE  inventory_item_id = p_item_id
    AND    organization_id = p_org_id
    AND    unit_of_measure = p_unit_of_measure;

  SELECT primary_uom_code, lot_control_code
    INTO   l_item_primary_uom, l_lot_control_code
    FROM   mtl_system_items
    WHERE  inventory_item_id = p_item_id
    AND    organization_id = p_org_id;

  --  BEGIN
  --    SELECT wlc.lot_number
  --  INTO   l_lot_number
  --FROM   wms_lpn_contents wlc,
  --     mtl_system_items msi
  --WHERE  wlc.parent_lpn_id = p_lpn_id
  --AND    wlc.organization_id = p_org_id
  --AND    wlc.inventory_item_id = p_item_id
  --AND    msi.inventory_item_id = p_item_id
  --AND    msi.organization_id = p_org_id
  --AND    msi.lot_control_code = 2
  --AND    ROWNUM < 2;

  --  EXCEPTION
  --  WHEN NO_DATA_FOUND THEN
  -- NULL;
  --  END;

  IF ((WMS_UI_TASKS_APIS.g_wms_patch_level >= WMS_UI_TASKS_APIS.g_patchset_j) AND
      (WMS_UI_TASKS_APIS.g_po_patch_level >= WMS_UI_TASKS_APIS.g_patchset_j_po)) THEN
     l_wms_po_j_higher := TRUE;
     IF (l_debug = 1) THEN
        print_debug('CREATE_RETURN_RESV:WMS and PO patch levels are J or higher', 4);
     END IF;
   ELSE
     l_wms_po_j_higher := FALSE;
     IF (l_debug = 1) THEN
        print_debug('CREATE_RETURN_RESV:Either WMS or/and PO patch level(s) are lower than J', 4);
     END IF;
  END IF;

  IF (l_wms_po_j_higher) THEN
     OPEN c_lots;
   ELSE
     OPEN c_lots_old;
  END IF;

  LOOP
     --if the item is lot controlled then fetch from the cursor otherwise
     --just use the existing data and exit at the end.
     IF (l_lot_control_code = 2) THEN
	IF (l_wms_po_j_higher) THEN
	   FETCH c_lots INTO l_lot_number, l_primary_res_qty;

	   EXIT WHEN c_lots%NOTFOUND;
	 ELSE
	      FETCH c_lots_old INTO l_lot_number, l_primary_res_qty;

	      EXIT WHEN c_lots_old%NOTFOUND;
	END IF;
     END IF;

     --Check if there exists a reservation record for the current combination
     IF (l_debug = 1) THEN
	print_debug('CREATE_RETURN_RESV:Lot Number:'||l_lot_number);
	print_debug('CREATE_RETURN_RESV:Prim Qty:'||l_primary_res_qty);
	print_debug('CREATE_RETURN_RESV:Check if the reservation already exists');
     END IF;
     l_qry_reservation_record.organization_id := p_org_id;
     l_qry_reservation_record.inventory_item_id := p_item_id;
     l_qry_reservation_record.demand_source_header_id := p_dem_src_hdr_id;
     l_qry_reservation_record.demand_source_line_id := p_dem_src_line_id;
     l_qry_reservation_record.demand_source_type_id := p_dem_src_type_id;
     l_qry_reservation_record.lpn_id := p_lpn_id;
     l_qry_reservation_record.lot_number := l_lot_number;
     l_reservation_record.lpn_id := p_lpn_id;

     --Query all the reservation records for the above combinations
     INV_RESERVATION_PUB.QUERY_RESERVATION(
					   p_api_version_number        => 1.0,
					   x_return_status             => x_return_status,
					   x_msg_count                 => x_msg_count,
					   x_msg_data                  => x_msg_data,
					   p_query_input               => l_qry_reservation_record,
					   x_mtl_reservation_tbl       => l_upd_reservation_tbl,
					   x_mtl_reservation_tbl_count => l_upd_reservation_tbl_cnt,
					   x_error_code                => l_error_code
					   );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	IF (l_debug = 1) THEN
	   print_debug('CREATE_RETURN_RESV:Error while calling query_reservations');
	END IF;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (l_debug = 1) THEN
	print_debug('CREATE_RETURN_RESV:There are ' || l_upd_reservation_tbl_cnt  || ' reservation records');
     END IF;
     --If there exists a reservation for this combination then update the reservation quantity
     IF l_upd_reservation_tbl_cnt > 0 THEN
	FOR l_count IN 1 .. l_upd_reservation_tbl_cnt LOOP
	   l_upd_reservation_record := l_upd_reservation_tbl(l_count);
	   l_res_lpn_id := l_upd_reservation_record.lpn_id;
	   IF (l_res_lpn_id <> p_lpn_id) THEN
	      l_create_res := TRUE;
	    ELSE
	      l_create_res := FALSE;

	      --Get the quantity that was already reserved
	      l_quantity_reserved := l_upd_reservation_record.reservation_quantity;
	      IF (l_debug = 1) THEN
		 print_debug('CREATE_RETURN_RESV:Quantity that was reserved so far: ' || l_quantity_reserved);
	      END IF;
	      IF (l_lot_control_code = 1) THEN
		 IF l_uom_code <> l_item_primary_uom THEN
		    l_primary_res_qty := INV_CONVERT.INV_UM_CONVERT(
								    item_id       => p_item_id,
								    precision     => null,
								    from_quantity => p_reservation_qty,
								    from_unit  	=> l_uom_code,
								    to_unit       => l_item_primary_uom,
								    from_name     => null,
								    to_name       => null);
		    IF (l_primary_res_qty = -99999) THEN
		       fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
		       fnd_message.set_token('UOM', l_item_primary_uom);
		       fnd_message.set_token('ROUTINE', 'Create Reservation');
		       fnd_msg_pub.ADD;
		       RAISE fnd_api.g_exc_error;
		    END IF;
		  ELSE --IF l_uom_code <> l_item_primary_uom THEN
		    l_primary_res_qty := p_reservation_qty;
		 END IF; --IF l_uom_code <> l_item_primary_uom THEN
	      END IF; --IF (l_lot_control_code = 1) THEN

	      IF (l_debug = 1) THEN
		 print_debug('CREATE_RETURN_RESV:Quantity entered: ' || l_primary_res_qty);
	      END IF;
	      --Add the new quantity to the quantity that was already reserved
	      l_upd_reservation_record.reservation_quantity :=
		l_upd_reservation_record.reservation_quantity + l_primary_res_qty;

	      l_upd_reservation_record.primary_reservation_quantity :=
		l_upd_reservation_record.primary_reservation_quantity + l_primary_res_qty;

	      --Update the reservation record with the new quantity
	      INV_RESERVATION_PUB.UPDATE_RESERVATION(
						     p_api_version_number     => 1.0,
						     p_init_msg_lst           => FND_API.G_FALSE,
						     x_return_status          => x_return_status,
						     x_msg_count              => x_msg_count,
						     x_msg_data               => x_msg_data,
						     p_original_rsv_rec       => l_upd_reservation_tbl(l_count),
						     p_to_rsv_rec             => l_upd_reservation_record,
						     p_original_serial_number => l_dummy_sn,
						     p_to_serial_number       => l_dummy_sn,
						     p_validation_flag        => FND_API.G_TRUE);

	      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		 IF (l_debug = 1) THEN
		    print_debug('CREATE_RETURN_RESV:error in update_reservation');
		 END IF;
		 FND_MESSAGE.SET_NAME('INB', 'INV_UPD_RSV_FAILED');
		 FND_MSG_PUB.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;
	      IF (l_debug = 1) THEN
		 print_debug('CREATE_RETURN_RESV:successfully updated a reservation record: ' ||sql%rowcount);
	      END IF;
	      EXIT;
	   END IF; -- End if the lpn_id is the same as the one being returned
	END LOOP;
      ELSE
	l_create_res := TRUE;
     END IF; -- End if there exists a record in mtl_reservations

     --There exist no reservations for this combinations. Create one
     IF l_create_res = TRUE THEN
	IF (l_debug = 1) THEN
	   print_debug('CREATE_RETURN_RESV:No reservation exists for the LPN. Have to create one...');
	END IF;
	l_reservation_record.organization_id := p_org_id;
	l_reservation_record.inventory_item_id := p_item_id;
	l_reservation_record.revision := p_revision;

	IF (l_lot_control_code = 1) THEN
	   --Convert the quantity into the primary UOM code of the item
	   IF l_uom_code <> l_item_primary_uom THEN
	      l_primary_res_qty := INV_CONVERT.INV_UM_CONVERT(
							      item_id       => p_item_id,
							      precision     => null,
							      from_quantity => p_reservation_qty,
							      from_unit  	=> l_uom_code,
							      to_unit       => l_item_primary_uom,
							      from_name     => null,
							      to_name       => null);
	      IF (l_primary_res_qty = -99999) THEN
		 fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
		 fnd_message.set_token('UOM', l_item_primary_uom);
		 fnd_message.set_token('ROUTINE', 'Create Reservation');
		 fnd_msg_pub.add;
		 RAISE fnd_api.g_exc_error;
	      END IF;
	    ELSE --IF l_uom_code <> l_item_primary_uom THEN
	      l_primary_res_qty := p_reservation_qty;
	   END IF; --IF l_uom_code <> l_item_primary_uom THEN
	END IF; --IF (l_lot_control_code = 1) THEN

	--The reservation UOM code and the primary reservation UOM are set to
	--the primary UOM code of the item since it is a dummy reservation
	l_reservation_record.reservation_uom_id := NULL;
	l_reservation_record.reservation_uom_code := l_item_primary_uom;
	l_reservation_record.primary_uom_id := NULL;
	l_reservation_record.primary_uom_code := l_item_primary_uom;

	--Reservation quantity is set to the quantity after conversion to
	--the primary UOM code of the item
	l_reservation_record.primary_reservation_quantity := l_primary_res_qty;
	l_reservation_record.reservation_quantity := l_primary_res_qty;
	l_reservation_record.demand_source_header_id := p_dem_src_hdr_id;
	l_reservation_record.demand_source_line_id := p_dem_src_line_id;
	l_reservation_record.demand_source_type_id := p_dem_src_type_id;

	l_reservation_record.ship_ready_flag := 2;
	l_reservation_record.attribute1  := NULL;
	l_reservation_record.attribute2  := NULL;
	l_reservation_record.attribute3  := NULL;
	l_reservation_record.attribute4  := NULL;
	l_reservation_record.attribute5  := NULL;
	l_reservation_record.attribute6  := NULL;
	l_reservation_record.attribute7  := NULL;
	l_reservation_record.attribute8  := NULL;
	l_reservation_record.attribute9  := NULL;
	l_reservation_record.attribute10 := NULL;
	l_reservation_record.attribute11 := NULL;
	l_reservation_record.attribute12 := NULL;
	l_reservation_record.attribute13 := NULL;
	l_reservation_record.attribute14 := NULL;
	l_reservation_record.attribute15 := NULL;
	l_reservation_record.attribute_category := NULL;
	l_reservation_record.lpn_id := p_lpn_id;
	l_reservation_record.pick_slip_number := NULL;
	l_reservation_record.lot_number_id := NULL;
	l_reservation_record.lot_number := l_lot_number;
	l_reservation_record.subinventory_id := NULL;
	l_reservation_record.subinventory_code := p_subinventory_code;
	l_reservation_record.locator_id := p_locator_id;
	l_reservation_record.supply_source_type_id := 13;
	l_reservation_record.supply_source_line_detail := NULL;
	l_reservation_record.supply_source_name := NULL;
	l_reservation_record.supply_source_header_id := p_dem_src_hdr_id;
	l_reservation_record.supply_source_line_id := p_dem_src_line_id;
	l_reservation_record.external_source_line_id := NULL;
	l_reservation_record.external_source_code := NULL;
	l_reservation_record.autodetail_group_id := NULL;
	l_reservation_record.demand_source_delivery := NULL;
	l_reservation_record.demand_source_name := NULL;
	l_reservation_record.requirement_date := p_requirement_date;

	IF (l_debug = 1) THEN
	   print_debug('CREATE_RETURN_RESV:**********Calling create_reservations with foll. parameters********');
	   print_debug('CREATE_RETURN_RESV:org id: ' || p_org_id);
	   print_debug('CREATE_RETURN_RESV:item id: ' || p_item_id);
	   print_debug('CREATE_RETURN_RESV:rev: ' || p_revision);
	   print_debug('CREATE_RETURN_RESV:UOM: ' || l_uom_code);
	   print_debug('CREATE_RETURN_RESV:res qty: ' || l_primary_res_qty);
	   print_debug('CREATE_RETURN_RESV:lot: ' || l_lot_number);
	   print_debug('CREATE_RETURN_RESV:sub: ' || p_subinventory_code);
	   print_debug('CREATE_RETURN_RESV:loc: ' || p_locator_id);
	   print_debug('CREATE_RETURN_RESV:lpn_id: ' || p_lpn_id);
	   print_debug('CREATE_RETURN_RESV:dem_src_type: ' || p_dem_src_type_id);
	   print_debug('CREATE_RETURN_RESV:dem_src_hdr_id: ' || p_dem_src_hdr_id);
	   print_debug('CREATE_RETURN_RESV:dem_src_line_id: ' || p_dem_src_line_id);
	END IF;

	--Call the Create Reservations API
	INV_RESERVATION_PUB.CREATE_RESERVATION(
					       x_return_status            => x_return_status,
					       x_msg_count                => x_msg_count,
					       x_msg_data                 => x_msg_data,
					       x_serial_number            => l_dummy_sn,
					       x_quantity_reserved        => l_quantity_reserved,
					       x_reservation_id           => l_reservation_id,
					       p_api_version_number       => 1.0,
					       p_init_msg_lst             => FND_API.G_FALSE,
					       p_rsv_rec                  => l_reservation_record,
					       p_partial_reservation_flag => FND_API.G_TRUE,
					       p_force_reservation_flag   => FND_API.G_TRUE,
					       p_serial_number            => l_dummy_sn,
					       p_validation_flag          => FND_API.G_TRUE);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   IF (l_debug = 1) THEN
	      print_debug('CREATE_RETURN_RESV:error creating reservation: status:' || x_return_status || 'mess:' || sqlerrm);
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
	IF (l_debug = 1) THEN
	   print_debug('CREATE_RETURN_RESV:Reservation created successfully. Reservation Id: ' || l_reservation_id || ' . Quantity Reserved: ' || l_quantity_reserved);
	END IF;
     END IF; --IF l_create_res = TRUE THEN

     IF (l_lot_control_code = 1) THEN
	EXIT;
     END IF;
  END LOOP;

  IF (l_wms_po_j_higher) THEN
     CLOSE c_lots;
   ELSE
     CLOSE c_lots_old;
  END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF (l_debug = 1) THEN
	 print_debug('unxp:' || sqlerrm);
      END IF;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
  END CREATE_RETURN_RESV;

END;

/
