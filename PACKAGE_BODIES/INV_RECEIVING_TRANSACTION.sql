--------------------------------------------------------
--  DDL for Package Body INV_RECEIVING_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RECEIVING_TRANSACTION" AS
/* $Header: INVRCVFB.pls 120.8.12010000.2 2008/07/29 12:54:37 ptkumar ship $*/

--  Global constant holding the package name
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'inv_receiving_transaction';



PROCEDURE print_debug(p_err_msg VARCHAR2,
		      p_level NUMBER)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'inv_receiving_transaction',
      p_level => p_level);
   END IF;

END print_debug;



PROCEDURE create_errors(p_group_id IN NUMBER,
			p_msg IN VARCHAR2)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('Enter create_errors : 10:'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('Parameters passed : 10.1: p_msg - '||p_msg, 4);
   END IF;

   INSERT INTO po_interface_errors
     (interface_type,
      interface_transaction_id,
      error_message,
      processing_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login)
     SELECT 'RECEIVING',
     rti.interface_transaction_id,
     p_msg,
     sysdate,
     rti.creation_date,
     rti.created_by,
     rti.last_update_date,
     rti.last_updated_by,
     rti.last_update_login
     FROM rcv_transactions_interface rti
     WHERE rti.group_id = p_group_id;

   UPDATE rcv_transactions_interface
      SET processing_status_code = 'COMPLETED',
          transaction_status_code = 'ERROR'
    WHERE group_id  = p_group_id;

   IF (l_debug = 1) THEN
      print_debug('Exit create_errors : 10:'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      NULL;
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('Exit create_errors with exception : 10:'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
END create_errors;



-- Need to make sure RTI has not been deleted before calling
-- this cleanup api
PROCEDURE rcv_txn_clean_up
  (  x_return_status                 OUT NOCOPY VARCHAR2,
     x_msg_count                     OUT NOCOPY NUMBER,
     x_msg_data                      OUT NOCOPY VARCHAR2,
     p_group_id                   IN     NUMBER)
  IS
     l_lpn_id NUMBER;
     l_inventory_item_id NUMBER;
     l_revision VARCHAR(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number VARCHAR2(80);
     l_serial_number VARCHAR2(30);
     l_quantity NUMBER;
     l_uom_code VARCHAR2(3);
     l_organization_id NUMBER;
     l_po_line_id NUMBER;
     l_po_release_id NUMBER;
     l_source_line_id NUMBER;
     l_group_id NUMBER;
     l_from_organization_id NUMBER;
     l_receipt_source_code VARCHAR2(25);
     l_source_document_code VARCHAR2(25);
     l_serial_control_at_from_org NUMBER;
     l_source_name varchar2(30);

     l_progress VARCHAR2(10);

     CURSOR lpn_pack_histroy_cur
       IS
	SELECT wlh.parent_lpn_id
	     , wlh.inventory_item_id
	     , wlh.revision
	     , wlh.lot_number
	     , wlh.serial_number
	     , wlh.quantity
	     , wlh.uom_code
	     , wlh.organization_id
             , wlh.source_name
	  FROM wms_lpn_histories wlh
	  WHERE wlh.source_header_id = p_group_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      print_debug('rcv_txn_clean_up entered 10'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('rcv_txn_clean_up 10.1: Parameters passed :  p_group_id - '||p_group_id, 4);
   END IF;
   SAVEPOINT rcv_cleanup_sp;

   l_progress := '10';

   OPEN lpn_pack_histroy_cur;

   l_progress := '20';

   LOOP
      l_progress := '30';
      FETCH lpn_pack_histroy_cur INTO
	l_lpn_id,
	l_inventory_item_id,
	l_revision,
	l_lot_number,
	l_serial_number,
	l_quantity,
	l_uom_code,
	l_organization_id,
        l_source_name;

      l_progress := '40';

      EXIT WHEN lpn_pack_histroy_cur%notfound;

      -- unpack the lpn
      IF (l_debug = 1) THEN
         print_debug('rcv_txn_clean_up 20: We need to undo the pack/unpack changes ',4);
         print_debug('l_source_name='||l_source_name, 4); --Bug 4611237
      END IF;

      if l_source_name = 'ASNEXP'
      then
	   IF (l_debug = 1) THEN
   	   print_debug('rcv_txn_clean_up Cleanup for ASNEXP Receive Case - ',1);
	   END IF;
           UPDATE wms_license_plate_numbers
              SET lpn_context = 7
            WHERE lpn_id = l_lpn_id;
      --Begin Bug 4611237
      elsif l_source_name = 'INTEXP'
      then
	   IF (l_debug = 1) THEN
	   	print_debug('rcv_txn_clean_up Cleanup for INTEXP Receive Case',1);
           	print_debug('l_lpn_id='||l_lpn_id,1);
           END IF;

           UPDATE wms_license_plate_numbers
           SET    lpn_context = 6,
                  organization_id = l_organization_id
           WHERE  lpn_id = l_lpn_id;

           UPDATE wms_lpn_contents
           SET    organization_id = l_organization_id
           WHERE  parent_lpn_id = l_lpn_id;

           UPDATE mtl_serial_numbers
           SET    current_organization_id = l_organization_id,
                  group_mark_id = null,
                  current_subinventory_code = null,
                  current_locator_id = null
           WHERE  lpn_id = l_lpn_id;

	   IF (l_debug = 1) THEN
		print_debug('After rcv_txn_clean_up Cleanup for INTEXP Receive Case',1);
	   END IF;
      --End Bug 4611237
      else
	   IF (l_debug = 1) THEN
   	   print_debug('rcv_txn_clean_up Cleanup for NON ASNEXP Receive Case - ',1);
	   END IF;
      WMS_Container_PUB.PackUnpack_Container
	(p_api_version => 1.0,
	 x_return_status => x_return_status,
	 x_msg_count => x_msg_count,
	 x_msg_data => x_msg_data,
	 p_lpn_id => l_lpn_id,
	 p_content_lpn_id => NULL,
	 p_content_item_id => l_inventory_item_id,
	 p_content_item_desc => NULL,
	 p_revision => l_revision,
	 p_lot_number => l_lot_number,
	 p_from_serial_number => l_serial_number,
	 p_to_serial_number => l_serial_number,
	 p_quantity => l_quantity,
	 p_uom => l_uom_code,
	 p_organization_id => l_organization_id,
	 p_subinventory => NULL,
	 p_locator_id => NULL,
	 p_enforce_wv_constraints => NULL,
	 p_operation => 2,   -- unpack flag
	 p_cost_group_id => NULL,
	 p_source_type_id => NULL,
	 p_source_header_id => NULL,
	 p_source_name => NULL,
	 p_source_line_id => NULL,
	 p_source_line_detail_id => NULL,
	 p_homogeneous_container => NULL,
	 p_match_locations => NULL,
	 p_match_lpn_context => NULL,
	 p_match_lot => NULL,
	 p_match_cost_groups =>NULL,
	 p_match_mtl_status =>  NULL
	 );
      end if;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
	 IF (l_debug = 1) THEN
   	 print_debug('rcv_txn_clean_up 30:  Could not undo the pack/unpack changes, exitting - '||x_msg_data,1);
	 END IF;
	 RAISE FND_API.g_exc_error; --RETURN;
      END IF;
      IF (l_debug = 1) THEN
         print_debug('rcv_txn_clean_up 30.1:  pack/unpack done',1);
      END IF;

      -- revert serial number changes if there's any
      -- and revert serial attributes
      IF l_serial_number IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	 print_debug('rcv_txn_clean_up 30.3:  revert serial number ' || l_serial_number,1);
	 END IF;

	 l_progress := '50';

	 l_from_organization_id := NULL;

	 SELECT from_organization_id
	   , receipt_source_code
	   , source_document_code
	   INTO l_from_organization_id
	   , l_receipt_source_code
	   , l_source_document_code
	   FROM rcv_transactions_interface
	   WHERE group_id = p_group_id
	   AND ROWNUM < 2;

	 l_progress := '55';

         IF l_source_name = 'ASNEXP'
         THEN
	     l_progress := '55.1';
	     IF (l_debug = 1) THEN
   	     print_debug('rcv_txn_clean_up  - Case for Serial ASNEXP cleanup ',1);
	     END IF;

	     UPDATE mtl_serial_numbers
	     SET current_status = Nvl(previous_status, current_status)
	     , group_mark_id = -1
	     , previous_status = NULL
	     WHERE inventory_item_id = l_inventory_item_id
	     AND serial_number = l_serial_number
	     AND current_organization_id = l_organization_id;

         ELSE
	     IF (l_debug = 1) THEN
   	     print_debug('rcv_txn_clean_up  - Case for Serial NON ASNEXP cleanup ',1);
	     END IF;
	     IF ((l_receipt_source_code = 'INVENTORY'
	        AND l_source_document_code = 'INVENTORY')
	       OR (l_receipt_source_code = 'INTERNAL ORDER'
           		 AND l_source_document_code = 'REQ')) THEN
	        SELECT serial_number_control_code
	          INTO l_serial_control_at_from_org
	          FROM mtl_system_items
	          WHERE inventory_item_id = l_inventory_item_id
	          AND organization_id = l_from_organization_id;
	      ELSE
	        -- delete if it is a newly created dynamic serial
	        DELETE mtl_serial_numbers
	          WHERE inventory_item_id = l_inventory_item_id
	          AND serial_number = l_serial_number
	          AND current_organization_id = l_organization_id
	          AND previous_status IS NULL;
	     END IF;

	     l_progress := '60';
	     -- revert its previous status otherwise
	     UPDATE mtl_serial_numbers
	       SET current_status = Nvl(previous_status, current_status)
	       , group_mark_id = -1 -- This line and next line for Bug#2368323
	       , current_organization_id = Decode(previous_status, NULL,
						Decode(l_serial_control_at_from_org,
						       1, current_organization_id,
						       6, current_organization_id,
						       Nvl (l_from_organization_id,current_organization_id)),
	        					current_organization_id)
	       , previous_status = NULL
	       WHERE inventory_item_id = l_inventory_item_id
	       AND serial_number = l_serial_number
	       AND current_organization_id = l_organization_id;

         END IF;

	   l_progress := '70';

      END IF;

   END LOOP;

   l_progress := '80';

   CLOSE lpn_pack_histroy_cur;

   -- Delete MO line(s) that are for the RTI that errors out
   -- It is populated when MOL is created.
   IF (l_debug = 1) THEN
      print_debug('rcv_txn_clean_up 40: delete MO Lines RTI ',4);
   END IF;
   l_progress := '90';

   DELETE mtl_txn_request_lines
     WHERE line_id IN
     (SELECT line_id
      FROM rcv_transactions_interface rti
      , mtl_txn_request_lines mol
      WHERE rti.group_id = p_group_id
      AND mol.txn_source_id = rti.interface_transaction_id
      AND mol.organization_id = rti.to_organization_id
      AND mol.inventory_item_id = rti.item_id);

   l_progress := '100';

   IF (l_debug = 1) THEN
      print_debug('rcv_txn_clean_up 50 complete ',4);
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      IF (l_debug = 1) THEN
         print_debug('rcv_txn_clean_up: Execution error',4);
      END IF;
      ROLLBACK TO rcv_cleanup_sp;
      CLOSE lpn_pack_histroy_cur;

      x_return_status := FND_API.G_RET_STS_ERROR;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('rcv_txn_clean_up: Other Exception',4);
      END IF;
      ROLLBACK TO rcv_cleanup_sp;
      CLOSE lpn_pack_histroy_cur;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF SQLCODE IS NOT NULL THEN
	 inv_mobile_helper_functions.sql_error('inv_receiving_transaction.rcv_txn_clean_up', l_progress, SQLCODE);
	 IF (l_debug = 1) THEN
   	 print_debug('rcv_txn_clean_up : l_progress = ' || l_progress ||'  SQLCODE is '||SQLCODE,4);
	 END IF;
      END IF;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

END rcv_txn_clean_up;



PROCEDURE txn_complete(p_group_id      IN     NUMBER,
		       p_txn_status    IN     VARCHAR2, -- TRUE/FALSE
		       p_txn_mode      IN     VARCHAR2, -- ONLINE/IMMEDIATE
		       x_return_status    OUT NOCOPY VARCHAR2,
		       x_msg_data         OUT NOCOPY VARCHAR2,
		       x_msg_count        OUT NOCOPY NUMBER)
  IS
     l_transaction_type VARCHAR2(100);
     l_error_code NUMBER;
     l_prev_lpn_group_id NUMBER;
     l_txn_mode_code VARCHAR2(25);--BUG 5090595

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   IF (l_debug = 1) THEN
      print_debug('TXN_COMPLETE - Enter txn_complete : 10: '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('TXN_COMPLETE - Parameters passed : 10.1: p_group_id - '||p_group_id, 4);
      print_debug('TXN_COMPLETE - Parameters passed : 10.2: p_txn_status - '||p_txn_status, 4);
      print_debug('TXN_COMPLETE - Parameters passed : 10.3: p_txn_mode - '||p_txn_mode, 4);
   END IF;


        IF (l_debug = 1) THEN
	   print_debug('TXN_COMPLETE - Release Level is J or Above',1);
	END IF;

	IF (p_txn_status = 'FALSE') THEN
	   --BUG 5090595 (FP of BUG 5082146)
	   IF (p_txn_mode = 'ONLINE') THEN
	      l_txn_mode_code := 'ONLINE';
	    ELSE
	      BEGIN
		 SELECT 'ONLINE'
		   INTO l_txn_mode_code
		   FROM dual
		   WHERE exists (SELECT 1
				 FROM  rcv_transactions_interface
				 WHERE interface_transaction_id = p_group_id
				 AND   processing_mode_code = 'ONLINE');
	      EXCEPTION
		 WHEN OTHERS THEN
		    l_txn_mode_code := NULL;
	      END;
	   END IF;

	   IF (l_debug = 1) THEN
	      print_debug('TXN_COMPLETE - PROCESSING MODE:'||l_txn_mode_code,1);
	   END IF;

	   IF (l_txn_mode_code = 'ONLINE') THEN
	      IF (l_debug = 1) THEN
		 print_debug('TXN_COMPLETE - Txn Failed for Online mode. Rolling back all work by tm',1);
	      END IF;
	      ROLLBACK WORK;
	   END IF;
	   --END BUG 5090595

	   IF (p_txn_mode IN ('PREPROCESSOR','PROCESSOR')) THEN
	      FOR l_rti_rec IN (SELECT interface_transaction_id
				, transaction_type
				, mmtt_temp_id
				, processing_mode_code
				, parent_transaction_id
				, item_id
				, lpn_id
				, item_revision
				, item_description
				, to_organization_id
				FROM rcv_transactions_interface
				WHERE interface_transaction_id =
				p_group_id)
		LOOP
		   IF (l_rti_rec.processing_mode_code <> 'ONLINE') THEN
		      IF l_rti_rec.mmtt_temp_id IS NOT NULL THEN
			 --Call Cleanup Op Instance
			 wms_atf_runtime_pub_apis.cleanup_operation_instance
			   (x_return_status => x_return_status
			    ,x_msg_data => x_msg_data
			    ,x_msg_count => x_msg_count
			    ,x_error_code => l_error_code
			    ,p_source_task_id => l_rti_rec.mmtt_temp_id
			    ,p_activity_type_id => 1);
		      END IF; --IF l_rti_rec.mmtt_temp_id IS NOT NULL THEN
		   END IF; --IF (l_rti_rec.processing_mode_code <> 'ONLINE') THEN

		   --update mol and msn

		   --In R12, the line between MOL.TXN_SOURCE_ID and RT.TRANSACTION_ID
		   --is removed.  So when unmarking the wme_process_flag here,
		   --we cannot join on MOL.TXN_SOURCE_ID.  Instead, we make
		   --use of rti.mmtt_temp_id if present.  If not, we can only
		   --update all MOL for the given org/item combination
		   IF (l_rti_rec.mmtt_temp_id IS NOT NULL) THEN
		      UPDATE mtl_txn_request_lines
			SET wms_process_flag = 1
			WHERE line_id = (SELECT move_order_line_id
					 FROM   mtl_material_transactions_temp
					 WHERE  transaction_temp_id = l_rti_rec.mmtt_temp_id);
		    ELSIF (l_rti_rec.lpn_id IS NOT NULL) THEN
		      UPDATE  mtl_txn_request_lines
			SET   wms_process_flag = 1
			WHERE organization_id = l_rti_rec.to_organization_id
			AND   lpn_id = l_rti_rec.lpn_id
			AND   wms_process_flag = 2;
		    ELSE
		      UPDATE mtl_txn_request_lines
			SET wms_process_flag = 1
			WHERE organization_id = l_rti_rec.to_organization_id
			AND inventory_item_id = l_rti_rec.item_id
			AND Nvl(revision,'#$!') = Nvl(l_rti_rec.item_revision,'#$!')
			AND wms_process_flag = 2;
			--AND txn_source_id = l_rti_rec.parent_transaction_id;
		   END IF;--IF (l_rti_rec.mmtt_temp_id IS NOT NULL) THEN

		   IF (l_debug = 1) THEN
		      print_debug('Number of MOL updated: '||SQL%rowcount,4);
		   END IF;
		  /* Bug 4911281: We have to clear the line_mark_id and lot_line_mark_id
		                along with group_mark_id */
                  -- Bug 6869089
                  update /*+ ROWID */ mtl_serial_numbers msn
                  set group_mark_id = NULL,
                      line_mark_id = NULL,
                      lot_line_mark_id = NULL
                  where  msn.ROWID in ( select msn1.ROWID
                                        from mtl_serial_numbers msn1 ,
                                        mtl_serial_numbers_interface msni
                                        where msn1.inventory_item_id = l_rti_rec.item_id
                                        and msni.product_code = 'RCV'
                                        and msni.product_transaction_id = l_rti_rec.interface_transaction_id
                                        and msn1.serial_number between msni.fm_serial_number and msni.to_serial_number
                                        and length(msn1.serial_number) = length(msni.fm_serial_number)
                                        and length(msni.fm_serial_number) = length(nvl(msni.to_serial_number,msni.fm_serial_number)));

		   --MSNI could have been moved to MSNT
                  update /*+ ROWID */ mtl_serial_numbers msn
                  set group_mark_id = NULL,
                      line_mark_id = NULL,
                      lot_line_mark_id = NULL
                  where msn.ROWID in ( select msn1.ROWID
                                       from mtl_serial_numbers msn1 ,
                                       mtl_serial_numbers_temp msnt
                                       where msn1.inventory_item_id = l_rti_rec.item_id
                                       and msnt.product_code = 'RCV'
                                       and msnt.product_transaction_id = l_rti_rec.interface_transaction_id
                                       and msn1.serial_number between msnt.fm_serial_number and msnt.to_serial_number
                                       and length(msn1.serial_number) = length(msnt.fm_serial_number)
                                       and length(msnt.fm_serial_number) = length(nvl(msnt.to_serial_number,msnt.fm_serial_number)));

		END LOOP; --FOR l_rti_rec IN (SELECT interface_transaction_id
	    ELSIF (p_txn_mode = 'LPN_GROUP') THEN --IF (p_txn_mode IN ('PREPROCESSOR','PROCESSOR')) THEN
	      FOR l_rti_rec IN (SELECT interface_transaction_id
				, transaction_type
				, mmtt_temp_id
				, processing_mode_code
				, parent_transaction_id
				, item_id
				, to_organization_id
				, lpn_id
				, item_description
				, item_revision
				FROM rcv_transactions_interface
				WHERE lpn_group_id =
				p_group_id)
		LOOP
		   IF (l_rti_rec.processing_mode_code <> 'ONLINE') THEN
		      IF l_rti_rec.mmtt_temp_id IS NOT NULL THEN
			 --Call Cleanup Op Instance
			 wms_atf_runtime_pub_apis.cleanup_operation_instance
			   (x_return_status => x_return_status
			    ,x_msg_data => x_msg_data
			    ,x_msg_count => x_msg_count
			    ,x_error_code => l_error_code
			    ,p_source_task_id => l_rti_rec.mmtt_temp_id
			    ,p_activity_type_id => 1);
		      END IF; --IF l_rti_rec.mmtt_temp_id IS NOT NULL THEN
		   END IF; --IF (l_rti_rec.processing_mode_code <> 'ONLINE') THEN

		   --update mol and msn

		   --In R12, the line between MOL.TXN_SOURCE_ID and RT.TRANSACTION_ID
		   --is removed.  So when unmarking the wme_process_flag here,
		   --we cannot join on MOL.TXN_SOURCE_ID.  Instead, we make
		   --use of rti.mmtt_temp_id if present.  If not, we can only
		   --update all MOL for the given org/item combination
		   IF (l_rti_rec.mmtt_temp_id IS NOT NULL) THEN
		      UPDATE mtl_txn_request_lines
			SET wms_process_flag = 1
			WHERE line_id = (SELECT move_order_line_id
					 FROM   mtl_material_transactions_temp
					 WHERE  transaction_temp_id = l_rti_rec.mmtt_temp_id);
		    ELSIF (l_rti_rec.lpn_id IS NOT NULL) THEN
		      UPDATE  mtl_txn_request_lines
			SET   wms_process_flag = 1
			WHERE organization_id = l_rti_rec.to_organization_id
			AND   lpn_id = l_rti_rec.lpn_id
			AND   wms_process_flag = 2;
		    ELSE
		      UPDATE mtl_txn_request_lines
			SET wms_process_flag = 1
			WHERE organization_id = l_rti_rec.to_organization_id
			AND inventory_item_id = l_rti_rec.item_id
			AND wms_process_flag = 2
			AND Nvl(revision,'#$!') = Nvl(l_rti_rec.item_revision,'#$!');
			--AND txn_source_id = l_rti_rec.parent_transaction_id;
		   END IF;--IF (l_rti_rec.mmtt_temp_id IS NOT NULL) THEN

		   IF (l_debug = 1) THEN
		      print_debug('Number of MOL updated: '||SQL%rowcount,4);
		   END IF;

		   /* Bug 4911281: We have to clear the line_mark_id and lot_line_mark_id
		                along with group_mark_id */
                  -- Bug 6869089
                  update /*+ ROWID */ mtl_serial_numbers msn
                  set group_mark_id = NULL,
                      line_mark_id = NULL,
                      lot_line_mark_id = NULL
                  where  msn.ROWID in ( select msn1.ROWID
                                        from mtl_serial_numbers msn1 ,
                                        mtl_serial_numbers_interface msni
                                        where msn1.inventory_item_id = l_rti_rec.item_id
                                        and msni.product_code = 'RCV'
                                        and msni.product_transaction_id = l_rti_rec.interface_transaction_id
                                        and msn1.serial_number between msni.fm_serial_number and msni.to_serial_number
                                        and length(msn1.serial_number) = length(msni.fm_serial_number)
                                        and length(msni.fm_serial_number) = length(nvl(msni.to_serial_number,msni.fm_serial_number)));

		   --MSNI could have been moved to MSNT
                  update /*+ ROWID */ mtl_serial_numbers msn
                  set group_mark_id = NULL,
                      line_mark_id = NULL,
                      lot_line_mark_id = NULL
                  where msn.ROWID in ( select msn1.ROWID
                                       from mtl_serial_numbers msn1 ,
                                       mtl_serial_numbers_temp msnt
                                       where msn1.inventory_item_id = l_rti_rec.item_id
                                       and msnt.product_code = 'RCV'
                                       and msnt.product_transaction_id = l_rti_rec.interface_transaction_id
                                       and msn1.serial_number between msnt.fm_serial_number and msnt.to_serial_number
                                       and length(msn1.serial_number) = length(msnt.fm_serial_number)
                                       and length(msnt.fm_serial_number) = length(nvl(msnt.to_serial_number,msnt.fm_serial_number)));


		END LOOP; --FOR l_rti_rec IN (SELECT interface_transaction_id
	    ELSIF (p_txn_mode = 'HEADER') THEN --IF (p_txn_mode IN ('PREPROCESSOR','PROCESSOR')) THEN
	      FOR l_rti_rec IN (SELECT interface_transaction_id
				, transaction_type
				, mmtt_temp_id
				, processing_mode_code
				, parent_transaction_id
				, item_id
				, to_organization_id
				, lpn_id
				, item_description
				, item_revision
				FROM rcv_transactions_interface
				WHERE header_interface_id = p_group_id)
		LOOP
		   IF (l_rti_rec.processing_mode_code <> 'ONLINE') THEN
		      IF l_rti_rec.mmtt_temp_id IS NOT NULL THEN
			 --Call Cleanup Op Instance
			 wms_atf_runtime_pub_apis.cleanup_operation_instance
			   (x_return_status => x_return_status
			    ,x_msg_data => x_msg_data
			    ,x_msg_count => x_msg_count
			    ,x_error_code => l_error_code
			    ,p_source_task_id => l_rti_rec.mmtt_temp_id
			    ,p_activity_type_id => 1);
		      END IF; --IF l_rti_rec.mmtt_temp_id IS NOT NULL THEN
		   END IF; --IF (l_rti_rec.processing_mode_code <> 'ONLINE') THEN

		   --update mol and msn

		   --In R12, the line between MOL.TXN_SOURCE_ID and RT.TRANSACTION_ID
		   --is removed.  So when unmarking the wme_process_flag here,
		   --we cannot join on MOL.TXN_SOURCE_ID.  Instead, we make
		   --use of rti.mmtt_temp_id if present.  If not, we can only
		   --update all MOL for the given org/item combination
		   IF (l_rti_rec.mmtt_temp_id IS NOT NULL) THEN
		      UPDATE mtl_txn_request_lines
			SET wms_process_flag = 1
			WHERE line_id = (SELECT move_order_line_id
					 FROM   mtl_material_transactions_temp
					 WHERE  transaction_temp_id = l_rti_rec.mmtt_temp_id);
		    ELSIF (l_rti_rec.lpn_id IS NOT NULL) THEN
		      UPDATE  mtl_txn_request_lines
			SET   wms_process_flag = 1
			WHERE organization_id = l_rti_rec.to_organization_id
			AND   lpn_id = l_rti_rec.lpn_id
			AND   wms_process_flag = 2;
		    ELSE
		      UPDATE mtl_txn_request_lines
			SET wms_process_flag = 1
			WHERE organization_id = l_rti_rec.to_organization_id
			AND inventory_item_id = l_rti_rec.item_id
			AND wms_process_flag = 2
			AND Nvl(revision,'#$!') = Nvl(l_rti_rec.item_revision,'#$!');
			--AND txn_source_id = l_rti_rec.parent_transaction_id;
		   END IF;--IF (l_rti_rec.mmtt_temp_id IS NOT NULL) THEN

		   IF (l_debug = 1) THEN
		      print_debug('Number of MOL updated: '||SQL%rowcount,4);
		   END IF;
		   /* Bug 4911281: We have to clear the line_mark_id and lot_line_mark_id
		                along with group_mark_id */
                  -- Bug 6869089
                  update /*+ ROWID */ mtl_serial_numbers msn
                  set group_mark_id = NULL,
                      line_mark_id = NULL,
                      lot_line_mark_id = NULL
                  where  msn.ROWID in ( select msn1.ROWID
                                        from mtl_serial_numbers msn1 ,
                                        mtl_serial_numbers_interface msni
                                        where msn1.inventory_item_id = l_rti_rec.item_id
                                        and msni.product_code = 'RCV'
                                        and msni.product_transaction_id = l_rti_rec.interface_transaction_id
                                        and msn1.serial_number between msni.fm_serial_number and msni.to_serial_number
                                        and length(msn1.serial_number) = length(msni.fm_serial_number)
                                        and length(msni.fm_serial_number) = length(nvl(msni.to_serial_number,msni.fm_serial_number)));

		   -- MSNI could have been moved to MSNT
                  update /*+ ROWID */ mtl_serial_numbers msn
                  set group_mark_id = NULL,
                      line_mark_id = NULL,
                      lot_line_mark_id = NULL
                  where msn.ROWID in ( select msn1.ROWID
                                       from mtl_serial_numbers msn1 ,
                                       mtl_serial_numbers_temp msnt
                                       where msn1.inventory_item_id = l_rti_rec.item_id
                                       and msnt.product_code = 'RCV'
                                       and msnt.product_transaction_id = l_rti_rec.interface_transaction_id
                                       and msn1.serial_number between msnt.fm_serial_number and msnt.to_serial_number
                                       and length(msn1.serial_number) = length(msnt.fm_serial_number)
                                       and length(msnt.fm_serial_number) = length(nvl(msnt.to_serial_number,msnt.fm_serial_number)));

		END LOOP; --FOR l_rti_rec IN (SELECT interface_transaction_id
	    ELSE --IF (p_txn_mode IN ('PREPROCESSOR','PROCESSOR')) THEN
	      l_prev_lpn_group_id := 0;
	      FOR l_rti_rec IN (SELECT interface_transaction_id
				, transaction_type
				, mmtt_temp_id
				, processing_mode_code
				, parent_transaction_id
				, item_id
				, to_organization_id
				, lpn_group_id
				, lpn_id
				, item_description
				, item_revision
				FROM rcv_transactions_interface
				WHERE group_id =
				p_group_id)
		LOOP
		   IF (l_rti_rec.processing_mode_code <> 'ONLINE') THEN
		      IF l_rti_rec.mmtt_temp_id IS NOT NULL THEN
			 --Call Cleanup Op Instance
			 wms_atf_runtime_pub_apis.cleanup_operation_instance
			   (x_return_status => x_return_status
			    ,x_msg_data => x_msg_data
			    ,x_msg_count => x_msg_count
			    ,x_error_code => l_error_code
			    ,p_source_task_id => l_rti_rec.mmtt_temp_id
			    ,p_activity_type_id => 1);
		      END IF; --IF l_rti_rec.mmtt_temp_id IS NOT NULL THEN
		   END IF; --IF (l_rti_rec.processing_mode_code <> 'ONLINE') THEN

		   --update mol and msn

		   --In R12, the line between MOL.TXN_SOURCE_ID and RT.TRANSACTION_ID
		   --is removed.  So when unmarking the wme_process_flag here,
		   --we cannot join on MOL.TXN_SOURCE_ID.  Instead, we make
		   --use of rti.mmtt_temp_id if present.  If not, we can only
		   --update all MOL for the given org/item combination
		   IF (l_rti_rec.mmtt_temp_id IS NOT NULL) THEN
		      UPDATE mtl_txn_request_lines
			SET wms_process_flag = 1
			WHERE line_id = (SELECT move_order_line_id
					 FROM   mtl_material_transactions_temp
					 WHERE  transaction_temp_id = l_rti_rec.mmtt_temp_id);
		    ELSIF (l_rti_rec.lpn_id IS NOT NULL) THEN
		      UPDATE  mtl_txn_request_lines
			SET   wms_process_flag = 1
			WHERE organization_id = l_rti_rec.to_organization_id
			AND   lpn_id = l_rti_rec.lpn_id
			AND   wms_process_flag = 2;
		    ELSE
		      UPDATE mtl_txn_request_lines
			SET wms_process_flag = 1
			WHERE organization_id = l_rti_rec.to_organization_id
			AND inventory_item_id = l_rti_rec.item_id
			AND wms_process_flag = 2
			AND Nvl(revision,'#$!') = Nvl(l_rti_rec.item_revision,'#$!');
			--AND txn_source_id = l_rti_rec.parent_transaction_id;
		   END IF;--IF (l_rti_rec.mmtt_temp_id IS NOT NULL) THEN

		   IF (l_debug = 1) THEN
		      print_debug('Number of MOL updated: '||SQL%rowcount,4);
		   END IF;
		   /* Bug 4911281: We have to clear the line_mark_id and lot_line_mark_id
		                along with group_mark_id */
                  -- Bug 6869089
                  update /*+ ROWID */ mtl_serial_numbers msn
                  set group_mark_id = NULL,
                      line_mark_id = NULL,
                      lot_line_mark_id = NULL
                  where  msn.ROWID in ( select msn1.ROWID
                                        from mtl_serial_numbers msn1 ,
                                        mtl_serial_numbers_interface msni
                                        where msn1.inventory_item_id = l_rti_rec.item_id
                                        and msni.product_code = 'RCV'
                                        and msni.product_transaction_id = l_rti_rec.interface_transaction_id
                                        and msn1.serial_number between msni.fm_serial_number and msni.to_serial_number
                                        and length(msn1.serial_number) = length(msni.fm_serial_number)
                                        and length(msni.fm_serial_number) = length(nvl(msni.to_serial_number,msni.fm_serial_number)));

		   -- MSNI could have been moved to MSNT
                  update /*+ ROWID */ mtl_serial_numbers msn
                  set group_mark_id = NULL,
                      line_mark_id = NULL,
                      lot_line_mark_id = NULL
                  where msn.ROWID in ( select msn1.ROWID
                                       from mtl_serial_numbers msn1 ,
                                       mtl_serial_numbers_temp msnt
                                       where msn1.inventory_item_id = l_rti_rec.item_id
                                       and msnt.product_code = 'RCV'
                                       and msnt.product_transaction_id = l_rti_rec.interface_transaction_id
                                       and msn1.serial_number between msnt.fm_serial_number and msnt.to_serial_number
                                       and length(msn1.serial_number) = length(msnt.fm_serial_number)
                                       and length(msnt.fm_serial_number) = length(nvl(msnt.to_serial_number,msnt.fm_serial_number)));

                   -- Delete WLPNI/MSNI/MSNT/MTLI/MTLT
                   -- Commenting the following as PO never deletes the RTI row.
                   /* Bug 4901912 - Uncommenting the deleting of the interface and temp tables as
                   also deleting the rti if in the online mode. */

                   IF (l_rti_rec.processing_mode_code = 'ONLINE' ) THEN
                      IF (l_debug = 1) THEN
                         print_debug('TXN_COMPLETE - Deleting mtli, msni, mtlt, msnt, wlpni for interface id:'
                         || l_rti_rec.interface_transaction_id ,1);
                      END IF;

                      DELETE FROM mtl_transaction_lots_interface
                       WHERE product_code = 'RCV'
                         AND product_transaction_id = l_rti_rec.interface_transaction_id;

                      DELETE FROM mtl_transaction_lots_temp
                       WHERE product_code = 'RCV'
                         AND product_transaction_id = l_rti_rec.interface_transaction_id;

                      DELETE FROM mtl_serial_numbers_interface
                       WHERE product_code = 'RCV'
                         AND product_transaction_id = l_rti_rec.interface_transaction_id;

                      DELETE FROM mtl_serial_numbers_temp
                       WHERE product_code = 'RCV'
                         AND product_transaction_id = l_rti_rec.interface_transaction_id;

                      IF (l_prev_lpn_group_id <> l_rti_rec.lpn_group_id) THEN
                         l_prev_lpn_group_id := l_rti_rec.lpn_group_id;

                         DELETE FROM wms_lpn_interface
                          WHERE source_group_id = l_rti_rec.lpn_group_id;
                      END IF; --IF (l_prev_lpn_group_id <> l_rti_rec.lpn_group_id) THEN
                   END IF; -- l_rti_rec.processing_mode_code = 'ONLINE'

                   /* End of fix for Bug 4901912 */

 	       END LOOP; --FOR l_rti_rec IN (SELECT interface_transaction_id
	   END IF; --IF (p_txn_mode IN ('PREPROCESSOR','PROCESSOR')) THEN
	   COMMIT;
	 ELSE --IF (p_txn_status = 'FALSE') THEN
	   BEGIN
	      IF p_txn_mode = 'LPN_GROUP' THEN
		 SELECT transaction_type
		   INTO l_transaction_type
		   FROM rcv_transactions
		   WHERE lpn_group_id = p_group_id
		   AND   transaction_date >= (Sysdate - 1) --BUG 3444137: RT
		   --will have INDEX ON transaction_date AND lpn_group_id
		   AND transaction_type IN ('CORRECT','RETURN TO VENDOR',
					    'RETURN TO RECEIVING','RETURN TO CUSTOMER')
		   AND ROWNUM < 2;
	       ELSE
		 SELECT transaction_type
		   INTO l_transaction_type
		   FROM rcv_transactions
		   WHERE group_id = p_group_id
		   AND transaction_type IN ('CORRECT','RETURN TO VENDOR',
					    'RETURN TO RECEIVING','RETURN TO CUSTOMER')
		   AND ROWNUM < 2;
	      END IF; --IF p_txn_mode = 'LPN_GROUP' THEN
	   EXCEPTION
	      WHEN no_data_found THEN
		 IF (l_debug = 1) THEN
		    print_debug('No records matched in RT for group_id - '||p_group_id||' : 100',1);
		 END IF;
		 RETURN;
	   END;

	   --Must call wms_return_sv.txn_complete to take care of deleting
	   --reservations for non-express case.
	   IF l_transaction_type in ('CORRECT','RETURN TO VENDOR','RETURN TO RECEIVING','RETURN TO CUSTOMER') THEN

	      x_return_status := fnd_api.g_ret_sts_success;
	      wms_return_sv.txn_complete(
					 p_group_id        => p_group_id,
					 p_txn_status      => p_txn_status,
					 p_txn_mode        => p_txn_mode,
					 x_return_status   => x_return_status,
					 x_msg_data        => x_msg_data,
					 x_msg_count       => x_msg_count);

	      IF ( x_return_status = fnd_api.g_ret_sts_error OR
		   x_return_status = fnd_api.g_ret_sts_unexp_error )  THEN
		 IF (l_debug = 1) THEN
		    print_debug('Error return from wms_return_sv.txn_complete, exitting - '||x_msg_data||' : 101',1);
		 END IF;
		 IF p_txn_mode <> 'ONLINE' THEN
		    create_errors(p_group_id => p_group_id,
				  p_msg => 'inv_receiving_transaction.txn_complete - 102 -'||x_msg_data);
		 END IF;
		 IF x_return_status = fnd_api.g_ret_sts_error THEN
		    RAISE fnd_api.g_exc_error;
		  ELSE
		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;
	      END IF;

	      x_return_status := fnd_api.g_ret_sts_success;

	   END IF; --IF l_transaction_type in ('CORRECT','RETURN TO VENDOR','RETURN TO RECEIVING','RETURN TO CUSTOMER') THEN

	END IF; --IF (p_txn_status = 'FALSE') THEN

   --Begin bug 4611237
   --Delete records from WLPNH with context 6, operation_mode of -99999 and
   --group_id passed to txn_complete api.

   IF (l_debug = 1) THEN
	print_debug('Delete records from WLPN with context 6, operation_mode of -99999 and group_id', 4);
   END IF;

   DELETE FROM wms_lpn_histories
   WHERE  source_header_id = p_group_id
   AND    lpn_context      = 6
   AND    operation_mode   = -99999;

   --End bug 4611237
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
         print_debug('Execution error in txn_complete',4);
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

   WHEN fnd_api.g_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
         print_debug('Unexpected error in txn_complete',4);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('Exception in txn_complete',4);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'txn_complete'
              );
      END IF;

      --  Get message count and data
      --fnd_msg_pub.count_and_get
      --    (  p_count  => x_msg_count
      --     , p_data   => x_msg_data
      --      );
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

END txn_complete;

PROCEDURE txn_mobile_timeout_cleanup(p_group_id      IN     NUMBER,
 		       p_rti_rec_count	  IN  NUMBER,
		       x_return_status    OUT NOCOPY VARCHAR2,
		       x_msg_data         OUT NOCOPY VARCHAR2,
		       x_msg_count        OUT NOCOPY NUMBER)
  IS
     CURSOR c_mmtt_txn_temp_id IS
	SELECT DISTINCT rti.mmtt_temp_id
	  FROM rcv_transactions_interface rti
	 WHERE rti.group_id = p_group_id;

     l_transaction_type VARCHAR2(100);
     l_organization_id NUMBER;
     l_mmtt_transaction_temp_id NUMBER;
     l_wms_install_status VARCHAR2(1);
     l_return_status VARCHAR2(5);
     l_msg_data VARCHAR2(500);
     l_msg_count NUMBER;


     l_patch_j_code BOOLEAN := FALSE;
     l_mobile_txn_count NUMBER;

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   x_return_status := fnd_api.g_ret_sts_success;
   IF (l_debug = 1) THEN
      print_debug('TXN_COMPLETE - Enter txn_complete : 10: '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('TXN_COMPLETE - Parameters passed : 10.1: p_group_id - '||p_group_id, 4);
      print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Parameters passed : 10.1: p_rti_rec_count - '||p_rti_rec_count, 4);
   END IF;

   --setting a parameter to see if the release level is above J or below J.
   IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
       (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      l_patch_j_code := TRUE;
    ELSE
      l_patch_j_code := FALSE;
   END IF;

   IF (l_patch_j_code = FALSE) THEN
      IF (l_debug = 1) THEN
	 print_debug('TXN_COMPLETE - Release level is prior to J',1);
      END IF;
      -- for a group id, if it is a row from mobile, all rows will have
      -- the same mobile_txn, transaction_type, lpn_id, transfer_lpn_id,
      -- content_lpn_id
	 SELECT count(Nvl(rti.mobile_txn, 'N'))
	 INTO l_mobile_txn_count
         FROM rcv_transactions_interface rti
	 WHERE rti.group_id = p_group_id
         AND	processing_mode_code = 'ONLINE'
         AND	processing_status_code = 'PENDING'
         AND	transaction_status_code = 'PENDING';

       IF (l_mobile_txn_count <> p_rti_rec_count) THEN
  	   IF (l_debug = 1) THEN
	    print_debug('TXN_MOBILE_TIMEOUT_CLEANUP -count does not match - exiting the procedure : 30',1);
	   END IF;
         RETURN;
       END IF;

      -- set wms_installed flag
      IF wms_install.check_install(x_return_status,
				   x_msg_count,
				   x_msg_data,
				   l_organization_id) THEN
	 l_wms_install_status := 'I';
       ELSE
	 l_wms_install_status := 'U';
      END IF;
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
	 IF (l_debug = 1) THEN
	       print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Could not get wms installed status, exitting - '||x_msg_data||' : 40',1);
	 END IF;
	 RAISE fnd_api.g_exc_error; --RETURN;
      END IF;

      IF l_wms_install_status = 'I' THEN

	 IF (l_debug = 1) THEN
	       print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - WMS is installed : 50',4);
	 END IF;

         IF l_transaction_type = 'DELIVER' THEN
	    IF (l_debug = 1) THEN
		    print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Transaction type is DELIVER : 180',4);
   	    END IF;
	    BEGIN
   	      OPEN c_mmtt_txn_temp_id;
	      LOOP   -- Loop through all the mmtt recs for this group for crossdocking
	        IF (l_debug = 1) THEN
		  print_debug('TXN_MOBILE_TIMEOUT_CLEANUP -  p_group_id:'||p_group_id,4);
		END IF;
		FETCH c_mmtt_txn_temp_id
		INTO l_mmtt_transaction_temp_id;
		EXIT WHEN c_mmtt_txn_temp_id%notfound;
		IF (l_debug = 1) THEN
		  print_debug('TXN_MOBILE_TIMEOUT_CLEANUP -  mmtt_temp_id:'||l_mmtt_transaction_temp_id,4);
		END IF;
		-- the records will be there in mmtt only if it was a wms
		-- enabled org. For an inventory org, there will be no recs.
		-- in mmtt so it will exit out of the loop immediately.
		wms_task_dispatch_put_away.putaway_cleanup
				 (  p_temp_id=>l_mmtt_transaction_temp_id
			          , p_org_id=>l_organization_id
				  , x_return_status =>x_return_status
				  ,  x_msg_count =>x_msg_count
				  ,  x_msg_data  =>x_msg_data
				 );
		IF x_return_status <> fnd_api.g_ret_sts_success THEN
		  IF (l_debug = 1) THEN
		    print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Could not archive tasks, exiting - '||x_msg_data||' : 105',1);
		  END IF;
	        END IF;
              END LOOP;
	      CLOSE c_mmtt_txn_temp_id;
	    END;

	    BEGIN
	      UPDATE wms_lpn_contents
	      SET txn_error_flag = 'Y'
	      WHERE source_header_id = p_group_id;
	    EXCEPTION
	      WHEN no_data_found THEN
	         NULL;
	      WHEN OTHERS THEN
	        IF (l_debug = 1) THEN
		  print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Exception while updating wms_lpn_contents to error : 200',4);
		END IF;
            END;

	    BEGIN
	      UPDATE mtl_serial_numbers
	      SET lpn_txn_error_flag = 'Y'
	      WHERE ROWID IN (SELECT msn.ROWID
			      FROM mtl_serial_numbers msn
			      , rcv_transactions_interface rti
			      WHERE msn.last_txn_source_id = p_group_id
			      AND rti.group_id = p_group_id
			      AND rti.item_id = msn.inventory_item_id);

	    EXCEPTION
	      WHEN no_data_found THEN
	        NULL;
	      WHEN OTHERS THEN
	        IF (l_debug = 1) THEN
		  print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Exception while updating mtl_serial_numbers to error : 210',4);
		END IF;
	    END;

          ELSIF l_transaction_type = 'RECEIVE' THEN
	    IF (l_debug = 1) THEN
	      print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Transaction type was RECEIVE : 220',4);
	    END IF;

	    rcv_txn_clean_up
		 (x_return_status => x_return_status,
		  x_msg_count => x_msg_count,
		  x_msg_data => x_msg_data,
		  p_group_id => p_group_id);
            print_debug('rcv_txn_clean_up - Finished clean up : 221',4);
	  END IF;


	  -- Delete/Clear mtl_serial_numbers_temp rows
	  -- Delete/Clear mtl_transaction_lots_temp rows
	  -- If the Transaction Fails

	  IF (l_debug = 1) THEN
		 print_debug('TXN_MOBILE_TIMEOUT_CLEANUP -  cleanup msnt 1',4);
	  END IF;


	  delete from mtl_serial_numbers_temp msnt
	  where msnt.transaction_temp_id in
	    ( select interface_transaction_id
	      from rcv_transactions_interface
	      where group_id = p_group_id )
	  ;

	  IF (l_debug = 1) THEN
	    print_debug('TXN_MOBILE_TIMEOUT_CLEANUP -  cleanup msnt 2',4);
	  END IF;

	  delete from mtl_serial_numbers_temp msnt
	  where msnt.transaction_temp_id in
		( select mtlt.serial_transaction_temp_id
		  from mtl_transaction_lots_temp mtlt
		  where mtlt.transaction_temp_id in (
						     select interface_transaction_id
						     from rcv_transactions_interface
						     where group_id = p_group_id )
	        );

	  IF (l_debug = 1) THEN
	    print_debug('TXN_MOBILE_TIMEOUT_CLEANUP -  cleanup mtlt 3',4);
	  END IF;

	  delete from mtl_transaction_lots_temp mtlt
	  where mtlt.transaction_temp_id
			in ( select interface_transaction_id
			     from rcv_transactions_interface
			     where group_id = p_group_id );

	  IF (l_debug = 1) THEN
	    print_debug('TXN_MOBILE_TIMEOUT_CLEANUP -  Committing after rollbacking and cleanup',4);
	  END IF;
       END IF; -- l_wms_install_status = 'I'
       IF (l_debug = 1) THEN
	 print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Exiting TXN_MOBILE_TIMEOUT_CLEANUP : 230  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
        END IF;
     END IF; --IF (l_patch_j_code = FALSE) THEN

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
        print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Execution error in TXN_MOBILE_TIMEOUT_CLEANUP',4);
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

   WHEN fnd_api.g_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
         print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Unexpected error in TXN_MOBILE_TIMEOUT_CLEANUP',4);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         print_debug('TXN_MOBILE_TIMEOUT_CLEANUP - Exception in TXN_MOBILE_TIMEOUT_CLEANUP',4);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'txn_complete'
              );
      END IF;

      --  Get message count and data
      --fnd_msg_pub.count_and_get
      --    (  p_count  => x_msg_count
      --     , p_data   => x_msg_data
      --      );
      inv_mobile_helper_functions.get_stacked_messages(x_message => x_msg_data);

END txn_mobile_timeout_cleanup;

END inv_receiving_transaction;

/
