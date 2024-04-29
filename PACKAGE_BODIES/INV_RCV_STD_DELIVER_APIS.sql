--------------------------------------------------------
--  DDL for Package Body INV_RCV_STD_DELIVER_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_STD_DELIVER_APIS" AS
  /* $Header: INVSTDDB.pls 120.17.12010000.17 2012/05/30 11:50:36 ssingams ship $*/

  --Variable to store interface_transaction_id for lot and serial splits
  g_interface_transaction_id  NUMBER;

  g_pkg_name VARCHAR2(30) := 'INV_RCV_STD_DELIVER_APIS';

  PROCEDURE print_debug(p_err_msg VARCHAR2, p_level NUMBER) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg
      	, p_module => g_pkg_name||'($Revision: 120.17.12010000.17 $)'
      	, p_level => p_level);
    END IF;
  --   dbms_output.put_line(p_err_msg);
  END print_debug;

  -- rcv_transaction block
  FUNCTION insert_interface_code(
  		l_rcv_transaction_rec IN OUT NOCOPY rcvtxn_transaction_rec_tp
  	, p_organization_id IN NUMBER)
    RETURN NUMBER IS
    l_receipt_source_code      VARCHAR2(30)  := l_rcv_transaction_rec.receipt_source_code;
    l_interface_transaction_id NUMBER;
    l_group_id                 NUMBER        := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    l_user_id                  NUMBER        := inv_rcv_common_apis.g_po_startup_value.user_id;
    l_logon_id                 NUMBER        := inv_rcv_common_apis.g_po_startup_value.logon_id;
    l_source_document_code     VARCHAR2(30)  := l_rcv_transaction_rec.source_document_code;
    l_dest_type_code           VARCHAR2(30)  := l_rcv_transaction_rec.destination_type_code;
    l_quantity                 NUMBER        := l_rcv_transaction_rec.transaction_quantity;
    l_uom                      VARCHAR2(30)  := l_rcv_transaction_rec.transaction_uom;
    l_shipment_hdr_id          NUMBER        := l_rcv_transaction_rec.shipment_header_id;
    l_shipment_line_id         NUMBER        := l_rcv_transaction_rec.shipment_line_id;
    l_substitute_code          VARCHAR2(30)  := l_rcv_transaction_rec.substitute_unordered_code;
    l_employee_id              NUMBER        := inv_rcv_common_apis.g_po_startup_value.employee_id;
    l_parent_transaction_id    NUMBER        := l_rcv_transaction_rec.rcv_transaction_id;
    l_inspection_code          VARCHAR2(30)  := l_rcv_transaction_rec.inspection_status_code;
    l_quality_code             VARCHAR2(30)  := l_rcv_transaction_rec.inspection_quality_code;
    l_po_hdr_id                NUMBER        := l_rcv_transaction_rec.po_header_id;
    l_po_release_id            NUMBER        := l_rcv_transaction_rec.po_release_id;
    l_po_line_id               NUMBER        := l_rcv_transaction_rec.po_line_id;
    l_po_line_location_id      NUMBER        := l_rcv_transaction_rec.po_line_location_id;
    l_po_dist_id               NUMBER        := l_rcv_transaction_rec.po_distribution_id;
    l_po_rev_num               NUMBER        := l_rcv_transaction_rec.po_revision_num;
    l_po_unit_price            NUMBER        := l_rcv_transaction_rec.po_unit_price;
    l_currency_code            VARCHAR2(30)  := l_rcv_transaction_rec.currency_code;
    l_currency_conv_rate       NUMBER        := l_rcv_transaction_rec.currency_conversion_rate;
    l_currency_conv_date       DATE          := l_rcv_transaction_rec.currency_conversion_date;
    l_currency_conv_type       VARCHAR2(80)  := l_rcv_transaction_rec.currency_conversion_type;
    l_req_line_id              NUMBER        := l_rcv_transaction_rec.req_line_id;
    l_req_dist_id              NUMBER        := l_rcv_transaction_rec.req_distribution_id;
    l_routing_id               NUMBER        := l_rcv_transaction_rec.routing_id;
    l_packing_slip             VARCHAR2(80)  := l_rcv_transaction_rec.packing_slip;
    l_routing_step_id          NUMBER        := l_rcv_transaction_rec.routing_step_id;
    l_comments                 VARCHAR2(240) := l_rcv_transaction_rec.comments;
    l_vendor_item_num          VARCHAR2(30)  := l_rcv_transaction_rec.vendor_item_number;
    l_attribute_category       VARCHAR2(30)  := l_rcv_transaction_rec.attribute_category;
    l_attribute1               VARCHAR2(150) := l_rcv_transaction_rec.attribute1;
    l_attribute2               VARCHAR2(150) := l_rcv_transaction_rec.attribute2;
    l_attribute3               VARCHAR2(150) := l_rcv_transaction_rec.attribute3;
    l_attribute4               VARCHAR2(150) := l_rcv_transaction_rec.attribute4;
    l_attribute5               VARCHAR2(150) := l_rcv_transaction_rec.attribute5;
    l_attribute6               VARCHAR2(150) := l_rcv_transaction_rec.attribute6;
    l_attribute7               VARCHAR2(150) := l_rcv_transaction_rec.attribute7;
    l_attribute8               VARCHAR2(150) := l_rcv_transaction_rec.attribute8;
    l_attribute9               VARCHAR2(150) := l_rcv_transaction_rec.attribute9;
    l_attribute10              VARCHAR2(150) := l_rcv_transaction_rec.attribute10;
    l_attribute11              VARCHAR2(150) := l_rcv_transaction_rec.attribute11;
    l_attribute12              VARCHAR2(150) := l_rcv_transaction_rec.attribute12;
    l_attribute13              VARCHAR2(150) := l_rcv_transaction_rec.attribute13;
    l_attribute14              VARCHAR2(150) := l_rcv_transaction_rec.attribute14;
    l_attribute15              VARCHAR2(150) := l_rcv_transaction_rec.attribute15;
    l_transaction_type         VARCHAR2(30)  := l_rcv_transaction_rec.transaction_type;
    l_location_id              NUMBER        := l_rcv_transaction_rec.location_id;
    l_processor_value          VARCHAR2(10)  := inv_rcv_common_apis.g_po_startup_value.transaction_mode;
    l_category_id              NUMBER        := l_rcv_transaction_rec.category_id;
    l_vendor_lot               VARCHAR2(30)  := l_rcv_transaction_rec.vendor_lot_num;
    l_reason_id                NUMBER        := l_rcv_transaction_rec.reason_id;
    l_primary_qty              NUMBER        := l_rcv_transaction_rec.primary_quantity;
    l_primary_uom              VARCHAR2(25)  := l_rcv_transaction_rec.primary_uom;
    l_secondary_quantity       NUMBER        := l_rcv_transaction_rec.sec_transaction_quantity; -- Bug 13344122
    l_secondary_uom_code       VARCHAR2(3)   := l_rcv_transaction_rec.secondary_uom_code; -- Bug 13344122
    l_item_id                  NUMBER        := l_rcv_transaction_rec.item_id;
    l_item_revision            VARCHAR2(3)   := l_rcv_transaction_rec.item_revision;
    l_org_id                   NUMBER        := p_organization_id;
    l_deliver_to_location_id   NUMBER        := l_rcv_transaction_rec.deliver_to_location_id;
    l_dest_context             VARCHAR2(30)  := l_rcv_transaction_rec.destination_context_nb;
    l_vendor_id                NUMBER        := l_rcv_transaction_rec.vendor_id;
    l_deliver_to_person_id     NUMBER        := l_rcv_transaction_rec.deliver_to_person_id;
    l_subinventory             VARCHAR2(30)  := l_rcv_transaction_rec.subinventory_dsp;
    l_locator_id               NUMBER        := l_rcv_transaction_rec.locator_id;
    -- Bug 820859
    l_wip_entity_id            NUMBER        := l_rcv_transaction_rec.wip_entity_id;
    l_wip_line_id              NUMBER        := l_rcv_transaction_rec.wip_line_id;
    l_wip_repetitive_schd_id   NUMBER        := l_rcv_transaction_rec.wip_repetitive_schedule_id;
    l_bom_resource_id          NUMBER        := l_rcv_transaction_rec.bom_resource_id_nb;
    -- Bug 820859
    l_wip_resource_seq_num     NUMBER        := l_rcv_transaction_rec.wip_resource_seq_num;
    l_wip_operation_seq_num    NUMBER        := l_rcv_transaction_rec.wip_operation_seq_num;
    l_mtl_lot                  NUMBER        := l_rcv_transaction_rec.lot_control_code;
    l_mtl_serial               NUMBER        := l_rcv_transaction_rec.serial_number_control_code;
    l_transaction_date         DATE          := l_rcv_transaction_rec.transaction_date_nb;
    l_movement_id              NUMBER;
    l_qa_collection_id         NUMBER        := l_rcv_transaction_rec.qa_collection_id;
    l_ussgl_transaction_code   VARCHAR2(30)  := l_rcv_transaction_rec.ussgl_transaction_code;
    l_government_context       VARCHAR2(30)  := l_rcv_transaction_rec.government_context;
    l_vendor_site_id           NUMBER        := l_rcv_transaction_rec.vendor_site_id;
    l_oe_order_header_id       NUMBER        := l_rcv_transaction_rec.oe_order_header_id;
    l_oe_order_line_id         NUMBER        := l_rcv_transaction_rec.oe_order_line_id;
    l_customer_id              NUMBER        := l_rcv_transaction_rec.customer_id;
    l_customer_site_id         NUMBER        := l_rcv_transaction_rec.customer_site_id;
    l_put_away_rule_id         NUMBER        := l_rcv_transaction_rec.put_away_rule_id;
    l_put_away_strategy_id     NUMBER        := l_rcv_transaction_rec.put_away_strategy_id;
    l_lpn_id                   NUMBER        := l_rcv_transaction_rec.lpn_id;
    l_transfer_lpn_id          NUMBER        := l_rcv_transaction_rec.transfer_lpn_id;
    l_cost_group_id            NUMBER        := l_rcv_transaction_rec.cost_group_id;
    l_mmtt_temp_id             NUMBER        := l_rcv_transaction_rec.mmtt_temp_id;
    l_transfer_cost_group_id   NUMBER        := l_rcv_transaction_rec.transfer_cost_group_id;
    l_project_id               NUMBER        := NULL;
    l_task_id                  NUMBER        := NULL;

    l_debug                    NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_validation_flag          VARCHAR2(1);
    l_lpn_group_id             NUMBER;

    l_operating_unit_id MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE;   --<R12 MOAC>
    --Bug #4348794
    l_uom_code                 mtl_units_of_measure.uom_code%TYPE;


    -- For Bug 7440217
     v_lcm_enabled_org  varchar2(1);
     v_pre_receive      varchar2(1);
     v_lcm_ship_line_id NUMBER;
     v_unit_landed_cost NUMBER;
-- End for Bug 7440217

  BEGIN
    IF (l_debug = 1) THEN
      print_debug('entering insert_interface_code 10: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('l_po_dist_id :'||l_po_dist_id,1);
    END IF;
    print_debug('transaction type is'||l_transaction_type, 1);
    --Bug 3989684 start
    --Bug #4058417 - Adding an exception handler block
    --Check if l_reason_id is populated, if not get it from MMTT
    IF (l_reason_id) IS NULL THEN
      IF (l_debug = 1) THEN
        print_debug('l_reason_id is null, check reason_id on MMTT',1);
      END IF;
      BEGIN
        SELECT reason_id
        INTO   l_reason_id
        FROM   mtl_material_transactions_temp
        WHERE  transaction_temp_id = l_mmtt_temp_id;
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('Exception occurred while querying MMTT', 1);
          END IF;
      END;

      IF (l_debug = 1) THEN
		    print_debug('l_reason_id '||l_reason_id||' Updated to RTI,Transaction Interface Id'||l_interface_transaction_id,1);
	    END IF;
    END IF;
    --Bug 3989684 end

    -- Chk if RCV_TRANSACTION.INTERFACE_transaction_id item is populated
    -- If not, populate the item with get_interface_id function
    --if l_rcv_transaction_rec.INTERFACE_transaction_id is null THEN
    SELECT rcv_transactions_interface_s.NEXTVAL
    INTO   l_interface_transaction_id
    FROM   SYS.DUAL;

    l_rcv_transaction_rec.interface_transaction_id := l_interface_transaction_id;

    --else
      --l_interface_transaction_id := l_rcv_transaction_rec.INTERFACE_transaction_id;
    --end if;

    --dbms_output.put_line('Inserted with intf. txn id:'||l_interface_transaction_id);

    --Since we call the Transfer API for a receiving subinventory with WMS
    --patchset J, do not need this validation
    IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
        (inv_rcv_common_apis.g_po_patch_level  < inv_rcv_common_apis.g_patchset_j_po)) THEN
      IF (l_debug = 1) THEN
        print_debug('WMS patch level is < J. Setting txntype to TRANSFER for RECEIVING dest', 4);
      END IF;
      IF l_rcv_transaction_rec.destination_type_code = 'RECEIVING' THEN
        l_transaction_type := 'TRANSFER';
        l_dest_context := 'RECEIVING';
        l_deliver_to_person_id := NULL;
        l_deliver_to_location_id := NULL;
        l_wip_entity_id := NULL;
        l_subinventory := NULL;
        l_locator_id := NULL;
        l_wip_line_id := NULL;
        l_wip_repetitive_schd_id := NULL;
        l_wip_operation_seq_num := NULL;
        l_bom_resource_id := NULL;
        l_wip_resource_seq_num := NULL;
      ELSE
        l_transaction_type := 'DELIVER';
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        print_debug('WMS patch level is >= J. Setting txntype to DELIVER since dest is INVENTORY', 4);
      END IF;
      l_transaction_type := 'DELIVER';
    END IF;

    SELECT rt.movement_id,
           rt.project_id,
           rt.task_id
    INTO   l_movement_id,
           l_project_id,
           l_task_id
    FROM   rcv_transactions rt
    WHERE  rt.transaction_id = l_parent_transaction_id;

    /* FP-J Lot/Serial Support Enhancement
     * Populate the LPN_GROUP_ID and validation_flag columns if INV and PO
     * patch levels are J or higher else set them to NULL
     * Insert these two additional columns in RTI
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      l_validation_flag := 'Y';
      l_lpn_group_id    := l_group_id;
      -- bug 3452845
      l_transaction_date := Sysdate;
    ELSE
      l_validation_flag := NULL;
      l_lpn_group_id    := NULL;
      l_transaction_date := Trunc(Sysdate);
    END IF;

    --<R12 MOAC>
    l_operating_unit_id := inv_rcv_common_apis.get_operating_unit_id( l_receipt_source_code,
                                                                      l_po_hdr_id,
                                                                      l_req_line_id,
                                                                      l_oe_order_header_id );

    IF (l_debug = 1) THEN
      print_debug('insert_inspect_rec_rti: validation_flag : ' || l_validation_flag || ', lpn_group_id: ' || l_lpn_group_id, 4);
    END IF;

    --Bug #4348794 - Populate RTI with uom code
    BEGIN
      SELECT muom.uom_code
        INTO l_uom_code
        FROM mtl_units_of_measure muom
        WHERE muom.unit_of_measure = l_uom;
      IF (l_debug = 1) THEN
        print_debug('Unit of measure: ' || l_uom || ', UOM Code: ' || l_uom_code, 1);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          print_debug('Error occurred while fetching UOM code', 1);
        END IF;
    END;

--bug 6412992
  IF( inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j AND  l_wip_entity_id is NULL) then
    BEGIN
      select  backorder_delivery_detail_id into l_wip_entity_id
      from mtl_txn_request_lines mtrl , mtl_material_transactions_temp mmtt
      where mmtt.transaction_temp_id = l_mmtt_temp_id
      and mtrl.line_id = mmtt.move_order_line_id
      and mtrl.CROSSDOCK_TYPE = 2;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        l_wip_entity_id := null;
     END;
  END IF;
  --end of fix of bug 6412992




    INSERT INTO rcv_transactions_interface
                (
                 receipt_source_code
               , interface_transaction_id
               , GROUP_ID
               , last_update_date
               , last_updated_by
               , created_by
               , creation_date
               , last_update_login
               , interface_source_code
               , source_document_code
               , destination_type_code
               , transaction_date
               , quantity
               , unit_of_measure
               , shipment_header_id
               , shipment_line_id
               , substitute_unordered_code
               , employee_id
               , parent_transaction_id
               , inspection_status_code
               , inspection_quality_code
               , po_header_id
               , po_release_id
               , po_line_id
               , po_line_location_id
               , po_distribution_id
               , po_revision_num
               , po_unit_price
               , currency_code
               , currency_conversion_rate
               , requisition_line_id
               , req_distribution_id
               , routing_header_id
               , routing_step_id
               , packing_slip
               , vendor_item_num
               , comments
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
               , transaction_type
               , location_id
               , processing_status_code
               , processing_mode_code
               , transaction_status_code
               , category_id
               , vendor_lot_num
               , reason_id
               , primary_quantity
               , primary_unit_of_measure
               , item_id
               , item_revision
               , to_organization_id
               , deliver_to_location_id
               , destination_context
               , vendor_id
               , deliver_to_person_id
               , subinventory
               , locator_id
               , wip_entity_id
               , wip_line_id
               , wip_repetitive_schedule_id
               , wip_operation_seq_num
               , wip_resource_seq_num
               , bom_resource_id
               , use_mtl_lot
               , use_mtl_serial
               , movement_id
               , currency_conversion_date
               , currency_conversion_type
               , qa_collection_id
               , ussgl_transaction_code
               , government_context
               , vendor_site_id
               , oe_order_header_id
               , oe_order_line_id
               , customer_id
               , customer_site_id
               , put_away_rule_id
               , put_away_strategy_id
               , lpn_id
               , transfer_lpn_id
               , cost_group_id
               , mmtt_temp_id
               , mobile_txn
               , transfer_cost_group_id
               , secondary_quantity -- Bug 13344122
               , secondary_uom_code -- Bug 13344122
               , validation_flag
               , lpn_group_id
               , project_id
               , task_id
               , org_id          --<R12 MOAC>
               , uom_code
                )
    VALUES      (
                 l_receipt_source_code
               , l_interface_transaction_id
               , l_group_id
               , SYSDATE
               , l_user_id
               , l_user_id
               , SYSDATE
               , l_logon_id
               , 'RCV'
               , l_source_document_code
               , l_dest_type_code
               , l_transaction_date
               , l_quantity
               , l_uom
               , l_shipment_hdr_id
               , l_shipment_line_id
               , l_substitute_code
               , l_employee_id
               , l_parent_transaction_id
               , l_inspection_code
               , l_quality_code
               , l_po_hdr_id
               , l_po_release_id
               , l_po_line_id
               , l_po_line_location_id
               , l_po_dist_id
               , l_po_rev_num
               , l_po_unit_price
               , l_currency_code
               , l_currency_conv_rate
               , l_req_line_id
               , l_req_dist_id
               , l_routing_id
               , l_routing_step_id
               , l_packing_slip
               , l_vendor_item_num
               , l_comments
               , l_attribute_category
               , l_attribute1
               , l_attribute2
               , l_attribute3
               , l_attribute4
               , l_attribute5
               , l_attribute6
               , l_attribute7
               , l_attribute8
               , l_attribute9
               , l_attribute10
               , l_attribute11
               , l_attribute12
               , l_attribute13
               , l_attribute14
               , l_attribute15
               , l_transaction_type
               , l_location_id
               , 'PENDING'
               , l_processor_value
               , 'PENDING'
               , l_category_id
               , l_vendor_lot
               , l_reason_id
               , l_primary_qty
               , l_primary_uom
               , l_item_id
               , l_item_revision
               , l_org_id
               , l_deliver_to_location_id
               , l_dest_context
               , l_vendor_id
               , l_deliver_to_person_id
               , l_subinventory
               , l_locator_id
               , l_wip_entity_id
               , l_wip_line_id
               , l_wip_repetitive_schd_id
               , l_wip_operation_seq_num
               , l_wip_resource_seq_num
               , l_bom_resource_id
               , l_mtl_lot
               , l_mtl_serial
               , l_movement_id
               , TRUNC(l_currency_conv_date)
               , l_currency_conv_type
               , l_qa_collection_id
               , l_ussgl_transaction_code
               , l_government_context
               , l_vendor_site_id
               , l_oe_order_header_id
               , l_oe_order_line_id
               , l_customer_id
               , l_customer_site_id
               , l_put_away_rule_id
               , l_put_away_strategy_id
               , l_lpn_id
               , l_transfer_lpn_id
               , l_cost_group_id
               , l_mmtt_temp_id
               , 'Y'
               , -- MOBILE_TXN
                 l_transfer_cost_group_id
               , l_secondary_quantity -- Bug 13344122
               , l_secondary_uom_code -- Bug 13344122
               , l_validation_flag
               , l_lpn_group_id
               , l_project_id
               , l_task_id
               , l_operating_unit_id  --<R12 MOAC>
               , l_uom_code
                );





-- For Bug 7440217 added the following code to update RTI with the status as PENDING so that it gets picked up for processing
  SELECT  mp.lcm_enabled_flag
  INTO    v_lcm_enabled_org
  FROM    mtl_parameters mp
  WHERE	  mp.organization_id = l_org_id;

  SELECT  rp.pre_receive
  INTO    v_pre_receive
  FROM    rcv_parameters rp
  WHERE	  rp.organization_id = l_org_id;

  IF	nvl(v_lcm_enabled_org, 'N') = 'Y' THEN

          SELECT	LCM_SHIPMENT_LINE_ID, UNIT_LANDED_COST
		  INTO		v_lcm_ship_line_id, v_unit_landed_cost
		  FROM		rcv_shipment_lines
		  WHERE		shipment_line_id = l_shipment_line_id;

		  UPDATE	rcv_transactions_interface
		  SET		lcm_shipment_line_id = v_lcm_ship_line_id,
				    unit_landed_cost = v_unit_landed_cost
		  WHERE		interface_transaction_id = l_interface_transaction_id
		  AND		to_organization_id = l_org_id;

 END IF;
-- End for Bug 7440217




    RETURN l_interface_transaction_id;

    IF (l_debug = 1) THEN
      print_debug('exiting insert_interface_code 10: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  END insert_interface_code;

  PROCEDURE insert_lot_serial(
    p_lot_serial_break_tbl      IN  inv_rcv_common_apis.trans_rec_tb_tp
  , p_transaction_temp_id       IN  NUMBER
  , p_lot_control_code          IN  NUMBER
  , p_serial_control_code       IN  NUMBER
  , p_interface_transaction_id  IN  NUMBER
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('entering insert_lot_serial 10: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    inv_rcv_common_apis.BREAK(
    		p_transaction_temp_id
    	, p_lot_serial_break_tbl
    	, p_lot_control_code
    	, p_serial_control_code);

    IF p_lot_control_code = 2 THEN
      -- it is lot controlled so lots must be inserted into lots temp table
      INSERT INTO rcv_lots_interface
                  (
                   interface_transaction_id
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , request_id
                 , program_application_id
                 , program_id
                 , program_update_date
                 , lot_num
                 , quantity
                 , transaction_date
                 , expiration_date
                 , primary_quantity
                 , item_id
                 , shipment_line_id
                  )
        SELECT rti.interface_transaction_id
             , rti.last_update_date
             , rti.last_updated_by
             , rti.creation_date
             , rti.created_by
             , rti.last_update_login
             , rti.request_id
             , rti.program_application_id
             , rti.program_id
             , rti.program_update_date
             , mtlt.lot_number
             , mtlt.transaction_quantity
             , rti.transaction_date
             , mtlt.lot_expiration_date
             , mtlt.primary_quantity
             , rti.item_id
             , rti.shipment_line_id
        FROM   rcv_transactions_interface rti, mtl_transaction_lots_temp mtlt
        WHERE  rti.interface_transaction_id = p_interface_transaction_id
        AND    mtlt.transaction_temp_id = rti.interface_transaction_id;

      -- Bug 2458540
      -- IF p_serial_control_code NOT IN (1,6) THEN
      IF p_serial_control_code NOT IN(1) THEN
        -- serial numbers were also inserted in serials temp table
        INSERT INTO rcv_serials_interface
                    (
                     interface_transaction_id
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , last_update_login
                   , request_id
                   , program_application_id
                   , program_id
                   , program_update_date
                   , transaction_date
                   , fm_serial_num
                   , to_serial_num
                   , serial_prefix
                   , lot_num
                   , vendor_serial_num
                   , vendor_lot_num
                   , item_id
                   , organization_id
                    )
          SELECT rti.interface_transaction_id
               , rti.last_update_date
               , rti.last_updated_by
               , rti.creation_date
               , rti.created_by
               , rti.last_update_login
               , rti.request_id
               , rti.program_application_id
               , rti.program_id
               , rti.program_update_date
               , rti.transaction_date
               , mtst.fm_serial_number
               , mtst.to_serial_number
               , mtst.serial_prefix
               , mtlt.lot_number
               , NULL
               , rti.vendor_lot_num
               , rti.item_id
               , rti.to_organization_id
          FROM   rcv_transactions_interface rti, mtl_transaction_lots_temp mtlt, mtl_serial_numbers_temp mtst
          WHERE  rti.interface_transaction_id = p_interface_transaction_id
          AND    mtlt.transaction_temp_id = rti.interface_transaction_id
          AND    mtlt.serial_transaction_temp_id = mtst.transaction_temp_id;
      END IF;
    ELSE
      -- it is just serial controlled item
      --
      -- Toshiba Fix
      --
      -- IF p_serial_control_code NOT IN (1,6) THEN
      IF p_serial_control_code NOT IN(1) THEN
        -- serial numbers were also inserted in serials temp table
        INSERT INTO rcv_serials_interface
                    (
                     interface_transaction_id
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , last_update_login
                   , request_id
                   , program_application_id
                   , program_id
                   , program_update_date
                   , transaction_date
                   , fm_serial_num
                   , to_serial_num
                   , serial_prefix
                   , lot_num
                   , vendor_serial_num
                   , vendor_lot_num
                   , item_id
                   , organization_id
                    )
          SELECT rti.interface_transaction_id
               , rti.last_update_date
               , rti.last_updated_by
               , rti.creation_date
               , rti.created_by
               , rti.last_update_login
               , rti.request_id
               , rti.program_application_id
               , rti.program_id
               , rti.program_update_date
               , rti.transaction_date
               , mtst.fm_serial_number
               , mtst.to_serial_number
               , mtst.serial_prefix
               , NULL
               , NULL
               , rti.vendor_lot_num
               , rti.item_id
               , rti.to_organization_id
          FROM   rcv_transactions_interface rti, mtl_serial_numbers_temp mtst
          WHERE  rti.interface_transaction_id = p_interface_transaction_id
          AND    mtst.transaction_temp_id = rti.interface_transaction_id;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('exiting insert_lot_serial 10: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  END insert_lot_serial;

  PROCEDURE populate_default_values(
    p_rcv_transaction_rec   IN OUT NOCOPY  rcvtxn_transaction_rec_tp
  , p_rcv_rcvtxn_rec        IN OUT NOCOPY  rcvtxn_enter_rec_cursor_rec
  , p_organization_id       IN             NUMBER
  , p_item_id               IN             NUMBER
  , p_revision              IN             VARCHAR2
  , p_subinventory_code     IN             VARCHAR2
  , p_locator_id            IN             NUMBER
  , p_transaction_temp_id   IN             NUMBER
  , p_lot_control_code      IN             NUMBER
  , p_serial_control_code   IN             NUMBER
  , p_original_txn_temp_id  IN             NUMBER
  , p_lpn_id                IN             NUMBER DEFAULT NULL
  , p_transfer_lpn_id       IN             NUMBER DEFAULT NULL
  ) IS
    l_final_location_id            NUMBER;
    l_destination_context          VARCHAR2(30);
    l_final_deliver_to_person_id   NUMBER;
    l_final_deliver_to_location_id NUMBER;
    l_person                       VARCHAR2(240);
    l_location                     VARCHAR2(60); -- 4615262
    l_hazard_class                 VARCHAR2(40);
    l_un_number                    VARCHAR2(30);
    l_sub_locator_control          VARCHAR2(30);
    l_count                        NUMBER;
    l_locator_id                   NUMBER;
    l_locator_control              NUMBER;
    l_req_line_id                  NUMBER;
    l_oe_order_line_id             NUMBER;
    l_project_id                   NUMBER;
    temp_sub                       VARCHAR2(30);
    l_task_id                      NUMBER;
    l_primary_quantity             NUMBER;
    l_today_date                   DATE := SYSDATE;
    l_currency_conversion_rate     NUMBER;
    l_currency_conversion_date     DATE;
    l_linelocationid               NUMBER;
    l_rcvtrxid                     NUMBER;
    l_matchflag                    VARCHAR2(1);
    l_rate                         NUMBER;
    l_ratedate                     DATE;
    l_ratedisplay                  NUMBER;
    l_interface_transaction_id     NUMBER;
    -- This keeps track of the number with which the record was inserted.

    l_lot_serial_break_tbl         inv_rcv_common_apis.trans_rec_tb_tp;
    -- table that will store the record into which the lot/serial entered
    -- have to be broken.

    l_po_distribution_id           NUMBER;
    l_valid_ship_to_location       BOOLEAN;
    l_valid_deliver_to_location    BOOLEAN;
    l_valid_deliver_to_person      BOOLEAN;
    l_valid_subinventory           BOOLEAN;
    l_rcv_transaction_id           NUMBER;
    l_group_id                     NUMBER;
    l_final_destination_type_code  VARCHAR2(80);
    l_final_destination_type_dsp   VARCHAR2(80);
    l_destination_type_dsp_hold    VARCHAR2(80);
    l_final_subinventory           VARCHAR2(80);
    l_wip_entity_id                NUMBER;
    l_wip_line_id                  NUMBER;
    l_wip_repetitive_schedule_id   NUMBER;
    l_outside_processing           VARCHAR2(1);
    l_job_sch_dsp                  VARCHAR2(80);
    l_op_seq_num_dsp               VARCHAR2(80);
    l_department_code              VARCHAR2(80);
    l_prod_line_dsp                VARCHAR2(80);
    l_bom_resource_id              NUMBER;
    l_available_quantity           NUMBER;
    l_tolerable_quantity           NUMBER;
    l_uom                          VARCHAR2(80);
    l_distribution_count           NUMBER;
    l_receiving_value              VARCHAR2(80);
    l_po_operation_seq_num         NUMBER;
    l_po_resource_seq_num          NUMBER;
    l_content_lpn_id               NUMBER;
    l_lpn_controlled_flag          NUMBER;
    l_debug                        NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_subinventory_type            NUMBER;
    l_tmp_destination_code          VARCHAR2(80);
    l_asn_line_flag                 VARCHAR2(3);
    l_is_expense                    VARCHAR2(1);
    l_po_routing_id                 NUMBER;
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('entering populate_default_values 10: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    rcv_transaction_sv.post_query(
      p_rcv_rcvtxn_rec.rcv_transaction_id
    , p_rcv_rcvtxn_rec.receipt_source_code
    , p_rcv_rcvtxn_rec.to_organization_id
    , p_rcv_rcvtxn_rec.hazard_class_id
    , p_rcv_rcvtxn_rec.un_number_id
    , p_rcv_rcvtxn_rec.shipment_header_id
    , p_rcv_rcvtxn_rec.shipment_line_id
    , p_rcv_rcvtxn_rec.po_line_location_id
    , p_rcv_rcvtxn_rec.po_line_id
    , p_rcv_rcvtxn_rec.po_header_id
    , p_rcv_rcvtxn_rec.po_release_id
    , p_rcv_rcvtxn_rec.vendor_id
    , p_rcv_rcvtxn_rec.item_id
    , p_rcv_rcvtxn_rec.item_revision
    , p_rcv_rcvtxn_rec.transaction_date
    , p_rcv_rcvtxn_rec.creation_date
    , p_rcv_rcvtxn_rec.location_id
    , p_rcv_rcvtxn_rec.subinventory
    , p_rcv_rcvtxn_rec.destination_type_code_hold
    , l_destination_type_dsp_hold
    , p_rcv_rcvtxn_rec.primary_uom
    , p_rcv_rcvtxn_rec.routing_id
    , l_po_distribution_id
    , l_final_destination_type_code
    , l_final_destination_type_dsp
    , l_final_location_id
    , l_final_subinventory
    , l_destination_context
    , l_wip_entity_id
    , l_wip_line_id
    , l_wip_repetitive_schedule_id
    , l_outside_processing
    , l_job_sch_dsp
    , l_op_seq_num_dsp
    , l_department_code
    , l_prod_line_dsp
    , l_bom_resource_id
    , l_final_deliver_to_person_id
    , l_final_deliver_to_location_id
    , l_person
    , l_location
    , l_hazard_class
    , l_un_number
    , l_sub_locator_control
    , l_count
    , l_locator_id
    , l_available_quantity
    , l_primary_quantity
    , l_tolerable_quantity
    , l_uom
    , l_distribution_count
    , l_receiving_value
    , l_po_operation_seq_num
    , l_po_resource_seq_num
    , l_currency_conversion_rate
    , l_currency_conversion_date
    , p_rcv_rcvtxn_rec.oe_order_line_id
    );

    --validate deliver to info
    IF (l_debug = 1) THEN
      print_debug('populate_default_values 20: ', 4);
    END IF;

    rcv_transactions_sv.val_destination_info(
      p_organization_id
    , p_item_id
    , NULL
    , p_rcv_rcvtxn_rec.final_deliver_to_location_id
    , p_rcv_rcvtxn_rec.final_deliver_to_person_id
    , p_subinventory_code
    , l_valid_ship_to_location
    , l_valid_deliver_to_location
    , l_valid_deliver_to_person
    , l_valid_subinventory
    );
    -- query RCV_ENTER_RECEIPTS_V to populate DB items in rcv_transaction block
    p_rcv_transaction_rec.to_organization_id := p_rcv_rcvtxn_rec.to_organization_id;
    p_rcv_transaction_rec.source_document_code := p_rcv_rcvtxn_rec.source_document_code;
    p_rcv_transaction_rec.receipt_source_code := p_rcv_rcvtxn_rec.receipt_source_code;

    IF p_rcv_rcvtxn_rec.receipt_source_code = 'CUSTOMER' THEN
      SELECT displayed_field
           , lookup_code
      INTO   l_final_destination_type_dsp
           , l_final_destination_type_code
      FROM   po_lookup_codes
      WHERE  lookup_code = 'INVENTORY'
      AND    lookup_type = 'RCV DESTINATION TYPE';
    END IF;

    IF (l_debug = 1) THEN
      print_debug('populate_default_values 30: ', 4);
    END IF;

    -- Get the lpn_id, transfer_lpn_id, content_lpn_id, cost_group_id,
    -- PUT_AWAY_RULE_ID, PUT_AWAY_STRATEGY_ID
    BEGIN
      SELECT lpn_id
           , transfer_lpn_id
           , content_lpn_id
           , cost_group_id
           , put_away_rule_id
           , put_away_strategy_id
      INTO   p_rcv_transaction_rec.lpn_id
           , p_rcv_transaction_rec.transfer_lpn_id
           , l_content_lpn_id
           , p_rcv_transaction_rec.cost_group_id
           , p_rcv_transaction_rec.put_away_rule_id
           , p_rcv_transaction_rec.put_away_strategy_id
      FROM   mtl_material_transactions_temp
      WHERE  transaction_temp_id = p_original_txn_temp_id;
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          print_debug('exception in getting info. from orig mmtt', 4);
        END IF;

        NULL;
    END;

    -- Get the transfer_cost_group_id from rcv_shipment_lines
    BEGIN
      SELECT cost_group_id
      INTO   p_rcv_transaction_rec.transfer_cost_group_id
      FROM   rcv_shipment_lines
      WHERE  shipment_line_id = p_rcv_rcvtxn_rec.shipment_line_id;
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          print_debug('exception in getting transfer cost group id', 4);
        END IF;

        p_rcv_transaction_rec.transfer_cost_group_id := NULL;
    END;


    /* FP-J Nested LPN Support Enhancement
     * If WMS and PO patch levels are J or higher, set the value of lpn_id and
     * transfer_lpn_id in RTI from the input parameters and we should not
     * refer to the MMTT columns since they would not be updating them
     */
    IF ((inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j) OR
        (inv_rcv_common_apis.g_po_patch_level  < inv_rcv_common_apis.g_patchset_j_po)) THEN
      IF l_content_lpn_id IS NOT NULL THEN
        p_rcv_transaction_rec.lpn_id := l_content_lpn_id;

        BEGIN
          SELECT NVL(lpn_controlled_flag, 1)
          INTO   l_lpn_controlled_flag
          FROM   mtl_secondary_inventories
          WHERE  secondary_inventory_name = p_subinventory_code
          AND    organization_id = p_organization_id;

          IF l_lpn_controlled_flag = 1 THEN
            p_rcv_transaction_rec.transfer_lpn_id := l_content_lpn_id;
          ELSE
            p_rcv_transaction_rec.transfer_lpn_id := NULL;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            p_rcv_transaction_rec.transfer_lpn_id := NULL;
        END;
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        print_debug('populate_default_values 35.5 : WMS and PO patch levels are J or higher. LPN columns should be set from passed values rather than MMTT', 4);
      END IF;
      p_rcv_transaction_rec.lpn_id := p_lpn_id;
      p_rcv_transaction_rec.transfer_lpn_id := p_transfer_lpn_id;
    END IF;   --END IF check WMS and PO patch levels

    p_rcv_transaction_rec.mmtt_temp_id := p_original_txn_temp_id;

    IF (l_debug = 1) THEN
      print_debug('Info got from original mmtt', 4);
      print_debug('LPN_ID:' || p_rcv_transaction_rec.lpn_id, 4);
      print_debug('TRANSFER_LPN_ID:' || p_rcv_transaction_rec.transfer_lpn_id, 4);
      print_debug('CONTENT_LPN_ID:' || l_content_lpn_id, 4);
      print_debug('COST_GROUP_ID:' || p_rcv_transaction_rec.cost_group_id, 4);
      print_debug('TRANSFER_COST_GROUP_ID:' || p_rcv_transaction_rec.transfer_cost_group_id, 4);
      print_debug('PUT_AWAY_RULE_ID:' || p_rcv_transaction_rec.put_away_rule_id, 4);
      print_debug('PUT_AWAY_STRATEGY_ID:' || p_rcv_transaction_rec.put_away_strategy_id, 4);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('populate_default_values 40: ', 4);
    END IF;

    p_rcv_transaction_rec.rcv_transaction_id := p_rcv_rcvtxn_rec.rcv_transaction_id;
    p_rcv_transaction_rec.transaction_date := p_rcv_rcvtxn_rec.transaction_date;
    p_rcv_transaction_rec.transaction_type := p_rcv_rcvtxn_rec.transaction_type;
    p_rcv_transaction_rec.po_header_id := p_rcv_rcvtxn_rec.po_header_id;
    p_rcv_transaction_rec.po_revision_num := p_rcv_rcvtxn_rec.po_revision_num;
    p_rcv_transaction_rec.po_release_id := p_rcv_rcvtxn_rec.po_release_id;
    p_rcv_transaction_rec.vendor_id := p_rcv_rcvtxn_rec.vendor_id;
    p_rcv_transaction_rec.vendor_site_id := p_rcv_rcvtxn_rec.vendor_site_id;
    p_rcv_transaction_rec.po_line_id := p_rcv_rcvtxn_rec.po_line_id;
    p_rcv_transaction_rec.po_unit_price := p_rcv_rcvtxn_rec.po_unit_price;
    p_rcv_transaction_rec.category_id := p_rcv_rcvtxn_rec.category_id;
    p_rcv_transaction_rec.item_id := p_rcv_rcvtxn_rec.item_id;
    p_rcv_transaction_rec.primary_uom := p_rcv_rcvtxn_rec.primary_uom;
    p_rcv_transaction_rec.serial_number_control_code := p_rcv_rcvtxn_rec.serial_number_control_code;
    p_rcv_transaction_rec.lot_control_code := p_rcv_rcvtxn_rec.lot_control_code;
    p_rcv_transaction_rec.item_revision := p_rcv_rcvtxn_rec.item_revision;
    p_rcv_transaction_rec.po_line_location_id := p_rcv_rcvtxn_rec.po_line_location_id;
    p_rcv_transaction_rec.employee_id := p_rcv_rcvtxn_rec.employee_id;
    p_rcv_transaction_rec.comments := p_rcv_rcvtxn_rec.comments;
    p_rcv_transaction_rec.req_header_id := p_rcv_rcvtxn_rec.req_header_id;
    p_rcv_transaction_rec.req_line_id := p_rcv_rcvtxn_rec.req_line_id;
    p_rcv_transaction_rec.shipment_header_id := p_rcv_rcvtxn_rec.shipment_header_id;
    p_rcv_transaction_rec.shipment_line_id := p_rcv_rcvtxn_rec.shipment_line_id;
    p_rcv_transaction_rec.packing_slip := p_rcv_rcvtxn_rec.packing_slip;
    p_rcv_transaction_rec.government_context := p_rcv_rcvtxn_rec.government_context;
    p_rcv_transaction_rec.ussgl_transaction_code := p_rcv_rcvtxn_rec.ussgl_transaction_code;
    p_rcv_transaction_rec.inspection_status_code := p_rcv_rcvtxn_rec.inspection_status_code;
    p_rcv_transaction_rec.inspection_quality_code := p_rcv_rcvtxn_rec.inspection_quality_code;
    p_rcv_transaction_rec.vendor_lot_num := p_rcv_rcvtxn_rec.vendor_lot_num;
    p_rcv_transaction_rec.vendor_item_number := p_rcv_rcvtxn_rec.vendor_item_number;
    p_rcv_transaction_rec.substitute_unordered_code := p_rcv_rcvtxn_rec.substitute_unordered_code;
    p_rcv_transaction_rec.routing_id := p_rcv_rcvtxn_rec.routing_id;
    p_rcv_transaction_rec.routing_step_id := p_rcv_rcvtxn_rec.routing_step_id;
    p_rcv_transaction_rec.reason_id := p_rcv_rcvtxn_rec.reason_id;
    p_rcv_transaction_rec.currency_code := p_rcv_rcvtxn_rec.currency_code;
    p_rcv_transaction_rec.currency_conversion_rate := p_rcv_rcvtxn_rec.currency_conversion_rate;
    p_rcv_transaction_rec.currency_conversion_date := p_rcv_rcvtxn_rec.currency_conversion_date;
    p_rcv_transaction_rec.currency_conversion_type := p_rcv_rcvtxn_rec.currency_conversion_type;
    p_rcv_transaction_rec.req_distribution_id := p_rcv_rcvtxn_rec.req_distribution_id;
    p_rcv_transaction_rec.destination_type_code_hold := p_rcv_rcvtxn_rec.destination_type_code_hold;

    IF (l_valid_deliver_to_person) THEN
      p_rcv_transaction_rec.deliver_to_person_id := p_rcv_rcvtxn_rec.final_deliver_to_person_id;
    ELSE
      p_rcv_transaction_rec.deliver_to_person_id := '';
    END IF;

    IF (l_valid_deliver_to_location) THEN
      p_rcv_transaction_rec.deliver_to_location_id := p_rcv_rcvtxn_rec.final_deliver_to_location_id;
    ELSE
      p_rcv_transaction_rec.deliver_to_location_id := '';
    END IF;

    p_rcv_transaction_rec.subinventory := p_rcv_rcvtxn_rec.subinventory;
    p_rcv_transaction_rec.un_number_id := p_rcv_rcvtxn_rec.un_number_id;
    p_rcv_transaction_rec.hazard_class_id := p_rcv_rcvtxn_rec.hazard_class_id;
    p_rcv_transaction_rec.creation_date := p_rcv_rcvtxn_rec.creation_date;
    p_rcv_transaction_rec.attribute_category := p_rcv_rcvtxn_rec.attribute_category;
    p_rcv_transaction_rec.attribute1 := p_rcv_rcvtxn_rec.attribute1;
    p_rcv_transaction_rec.attribute2 := p_rcv_rcvtxn_rec.attribute2;
    p_rcv_transaction_rec.attribute3 := p_rcv_rcvtxn_rec.attribute3;
    p_rcv_transaction_rec.attribute4 := p_rcv_rcvtxn_rec.attribute4;
    p_rcv_transaction_rec.attribute5 := p_rcv_rcvtxn_rec.attribute5;
    p_rcv_transaction_rec.attribute6 := p_rcv_rcvtxn_rec.attribute6;
    p_rcv_transaction_rec.attribute7 := p_rcv_rcvtxn_rec.attribute7;
    p_rcv_transaction_rec.attribute8 := p_rcv_rcvtxn_rec.attribute8;
    p_rcv_transaction_rec.attribute9 := p_rcv_rcvtxn_rec.attribute9;
    p_rcv_transaction_rec.attribute10 := p_rcv_rcvtxn_rec.attribute10;
    p_rcv_transaction_rec.attribute11 := p_rcv_rcvtxn_rec.attribute11;
    p_rcv_transaction_rec.attribute12 := p_rcv_rcvtxn_rec.attribute12;
    p_rcv_transaction_rec.attribute13 := p_rcv_rcvtxn_rec.attribute13;
    p_rcv_transaction_rec.attribute14 := p_rcv_rcvtxn_rec.attribute14;
    p_rcv_transaction_rec.attribute15 := p_rcv_rcvtxn_rec.attribute15;
    p_rcv_transaction_rec.qa_collection_id := p_rcv_rcvtxn_rec.qa_collection_id;
    p_rcv_transaction_rec.oe_order_header_id := p_rcv_rcvtxn_rec.oe_order_header_id;
    p_rcv_transaction_rec.oe_order_line_id := p_rcv_rcvtxn_rec.oe_order_line_id;
    p_rcv_transaction_rec.customer_id := p_rcv_rcvtxn_rec.customer_id;
    p_rcv_transaction_rec.customer_site_id := p_rcv_rcvtxn_rec.customer_site_id;
    p_rcv_transaction_rec.destination_type_code_pqry := p_rcv_rcvtxn_rec.final_destination_type_code;
    --   p_rcv_transaction_rec.destination_type_code := p_rcv_rcvtxn_rec.final_destination_type_code;
    p_rcv_transaction_rec.destination_type_code := l_final_destination_type_code;
    p_rcv_transaction_rec.location_id := l_final_location_id;
    p_rcv_transaction_rec.subinventory_hold := p_rcv_rcvtxn_rec.final_subinventory;
    p_rcv_transaction_rec.subinventory_dsp := p_rcv_rcvtxn_rec.final_subinventory;
    p_rcv_transaction_rec.destination_context_nb := l_destination_context;
    p_rcv_transaction_rec.wip_entity_id := p_rcv_rcvtxn_rec.wip_entity_id;
    p_rcv_transaction_rec.wip_line_id := p_rcv_rcvtxn_rec.wip_line_id;
    p_rcv_transaction_rec.wip_repetitive_schedule_id := p_rcv_rcvtxn_rec.wip_repetitive_schedule_id;
    p_rcv_transaction_rec.wip_resource_seq_num := p_rcv_rcvtxn_rec.po_resource_seq_num;
    p_rcv_transaction_rec.wip_operation_seq_num := p_rcv_rcvtxn_rec.po_operation_seq_num;
    p_rcv_transaction_rec.bom_resource_id_nb := p_rcv_rcvtxn_rec.bom_resource_id;
    p_rcv_transaction_rec.deliver_to_location_id := p_rcv_rcvtxn_rec.final_deliver_to_location_id;
    p_rcv_transaction_rec.deliver_to_person_id := l_final_deliver_to_person_id;
    p_rcv_transaction_rec.locator_id := l_locator_id;


    -- added for ASN delivery bug fix
    IF p_rcv_transaction_rec.po_distribution_id IS NULL THEN
      p_rcv_transaction_rec.po_distribution_id := l_po_distribution_id;
    END IF;

    IF NVL(p_rcv_transaction_rec.routing_id, 1) = 2
       AND p_rcv_transaction_rec.inspection_status_code = 'NOT INSPECTED' THEN
      p_rcv_transaction_rec.destination_type_code := 'RECEIVING';
      p_rcv_transaction_rec.destination_context_nb := 'RECEIVING';
      p_rcv_transaction_rec.destination_type_code_pqry := p_rcv_rcvtxn_rec.final_destination_type_code;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('populate_default_values 50: ', 4);
    END IF;

    IF (p_rcv_transaction_rec.req_line_id IS NOT NULL) THEN
      po_subinventories_s.get_default_subinventory(p_organization_id, p_item_id, l_final_subinventory);
      p_rcv_transaction_rec.subinventory_dsp := l_final_subinventory;
      p_rcv_transaction_rec.subinventory_hold := l_final_subinventory;
    END IF;

    -- Go get the locator control value if the locator control has
    -- not already been selected or if the subinventory has been
    -- modified

    IF (l_debug = 1) THEN
      print_debug('populate_default_values 60: ', 4);
    END IF;

    IF (
        p_rcv_transaction_rec.destination_type_code_pqry = 'INVENTORY'
        AND p_rcv_transaction_rec.subinventory_locator_control IS NULL
        AND p_rcv_transaction_rec.subinventory_dsp IS NOT NULL
       ) THEN
      po_subinventories_s.get_locator_control(
        p_rcv_transaction_rec.to_organization_id
      , p_rcv_transaction_rec.subinventory_dsp
      , p_rcv_transaction_rec.item_id
      , l_locator_control
      );
      p_rcv_transaction_rec.subinventory_locator_control := l_locator_control;
    ELSE
      l_locator_control := p_rcv_transaction_rec.subinventory_locator_control;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('populate_default_values 70: ', 4);
    END IF;

    IF (p_rcv_transaction_rec.destination_type_code_hold = 'INVENTORY'
        AND p_rcv_transaction_rec.subinventory_dsp IS NOT NULL) THEN
      -- get default locator
      --
      -- Anytime a subinventory is selected then the locator field
      -- should be prepopulated with the default locator_id from
      -- mtl_item_loc_defaults for the item, org and subinventory
      -- and where the default_type = 2
      po_subinventories_s.get_default_locator(
        p_rcv_transaction_rec.to_organization_id
      , p_rcv_transaction_rec.item_id
      , p_rcv_transaction_rec.subinventory_dsp
      , l_locator_id
      );
      -- Bug 616392
      l_req_line_id := p_rcv_transaction_rec.req_line_id;
      l_oe_order_line_id := p_rcv_transaction_rec.oe_order_line_id;

      IF (l_debug = 1) THEN
        print_debug('populate_default_values 80: ', 4);
      END IF;

      IF p_rcv_transaction_rec.receipt_source_code <> 'CUSTOMER' THEN
        IF (l_req_line_id IS NOT NULL
            AND l_locator_id IS NOT NULL) THEN
          SELECT project_id
               , task_id
          INTO   l_project_id
               , l_task_id
          FROM   po_req_distributions
          WHERE  requisition_line_id = l_req_line_id;
        END IF;
      ELSE
        -- Locator field defaulting for rmas
        IF (l_oe_order_line_id IS NOT NULL
            AND l_locator_id IS NOT NULL) THEN
          SELECT project_id
               , task_id
          INTO   l_project_id
               , l_task_id
          FROM   oe_order_lines_all
          WHERE  line_id = l_oe_order_line_id;
        END IF;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('populate_default_values 90: ', 4);
      END IF;

      IF (l_project_id IS NOT NULL) THEN
        pjm_project_locator.get_defaultprojectlocator(
        		p_rcv_transaction_rec.to_organization_id
        	, l_locator_id
        	, l_project_id
        	, l_task_id
        	, l_locator_id);
      END IF;

      p_rcv_transaction_rec.locator_id := l_locator_id;
    END IF;

    -- Depending on the Destination Type value, dependent fields will
    -- be enabled or disabled
    -- To ensure this, INIT code of the dependent fields will be executed
    IF (l_debug = 1) THEN
      print_debug('populate_default_values 100: ', 4);
    END IF;

    -- Part of the code in RCV_LINE_LOC_PERS_CONTROL.LOCATION_DSP('INIT');
    IF (
        (p_rcv_transaction_rec.destination_type_code <> 'MULTIPLE')
        AND(p_rcv_transaction_rec.destination_type_code_hold <> 'MULTIPLE')
       ) THEN
      p_rcv_transaction_rec.location_id := p_rcv_transaction_rec.deliver_to_location_id;
    END IF;

    -- Part of the code in RCV_SUBINVENTORY_CONTROL.SUBINVENTORY_DSP('INIT');
    temp_sub := p_rcv_transaction_rec.subinventory_dsp;

    IF (p_rcv_transaction_rec.destination_type_code = 'INVENTORY') THEN
      -- INIT is used when you query up a new row or switch the destination
      -- destination type from receiving to inventory
      IF (temp_sub IS NULL) THEN
        p_rcv_transaction_rec.subinventory_dsp := p_rcv_transaction_rec.subinventory_hold;
      ELSE
        p_rcv_transaction_rec.subinventory_dsp := temp_sub;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('populate_default_values 110: ', 4);
    END IF;

    -- Part of the code in RCV_LOCATOR_CONTROL.SET_LOCATOR_ATTRIBUTES('INIT');
    IF (
        NVL(inv_rcv_common_apis.g_rcv_global_var.express_mode, 'NO') = 'NO'
        AND p_rcv_transaction_rec.subinventory_dsp IS NOT NULL
        AND p_rcv_transaction_rec.destination_type_code = 'INVENTORY'
        AND p_rcv_transaction_rec.subinventory_locator_control IN(2, 3)
       ) THEN
      NULL;
    ELSE
      p_rcv_transaction_rec.locator_id := NULL;
    END IF;

    -- l_primary_quantity has the available primary quantity for this row
    --p_rcv_transaction_rec.primary_quantity := l_primary_quantity;
    p_rcv_transaction_rec.transaction_date_nb := l_today_date;
    p_rcv_transaction_rec.inspection_detail := 'N';

    -- If subinventory is null, then null out default locator details
    IF p_rcv_transaction_rec.subinventory_dsp IS NULL THEN
      p_rcv_transaction_rec.locator_id := NULL;
    END IF;

    IF (p_rcv_transaction_rec.destination_type_code = 'MULTIPLE') THEN
      -- Chk if location_id item is null. If not null then copy null into the item
      IF p_rcv_transaction_rec.location_id IS NOT NULL THEN
        p_rcv_transaction_rec.location_id := NULL;
      END IF;

      -- Bug No 1823328 Changes, setting the destination type code otherwise fails in rcvtpo..
      IF p_rcv_transaction_rec.po_distribution_id IS NOT NULL THEN
        p_rcv_transaction_rec.destination_type_code := p_rcv_rcvtxn_rec.final_destination_type_code;

        IF (l_debug = 1) THEN
          print_debug('populate_default_values A : ' || p_rcv_transaction_rec.destination_type_code, 1);
        END IF;
      END IF;
    --
      --Begin changes bug 3157829


        SELECT nvl(rsh.asn_type, 'NNN')
        INTO l_asn_line_flag
        FROM rcv_shipment_headers rsh,
             rcv_shipment_lines rsl
        WHERE rsh.shipment_header_id = rsl.shipment_header_id
        AND   rsl.shipment_line_id = p_rcv_rcvtxn_rec.shipment_line_id;

        IF (l_debug = 1) THEN
                print_debug('populate_default_values : l_asn_line_flag = '||l_asn_line_flag, 4);
                print_debug('populate_defauly_values : p_rcv_transaction_rec.DESTINATION_TYPE_CODE ='||p_rcv_transaction_rec.DESTINATION_TYPE_CODE, 4);
        END IF;

        IF (l_asn_line_flag = 'ASN') THEN

                --Check if the destination is expense
                inv_rcv_common_apis.get_po_routing_id(
                        x_po_routing_id => l_po_routing_id,
                        x_is_expense    => l_is_expense,
                        p_po_header_id  => p_rcv_rcvtxn_rec.po_header_id,
                        p_po_release_id => p_rcv_rcvtxn_rec.po_release_id,
                        p_po_line_id    => p_rcv_rcvtxn_rec.po_line_id,
                        p_item_id       => p_rcv_rcvtxn_rec.item_id,
                        p_item_desc     => NULL);

                IF (l_debug = 1) THEN
                        print_debug('populate_default_values : l_is_expense ='||l_is_expense, 4);
                END IF;

                IF (l_is_expense = 'Y') THEN

                        SELECT lookup_code
                        INTO l_tmp_destination_code
                        FROM po_lookup_codes
                        WHERE lookup_code = 'EXPENSE'
                        AND lookup_type = 'RCV DESTINATION TYPE';

                ELSE

                        SELECT lookup_code
                        INTO l_tmp_destination_code
                        FROM po_lookup_codes
                        WHERE lookup_code = 'INVENTORY'
                        AND lookup_type = 'RCV DESTINATION TYPE';

                END IF;

                IF (l_debug = 1) THEN
                        print_debug('populate_default_values : l_tmp_destination_code = '||l_tmp_destination_code,4);
                END IF;

                p_rcv_transaction_rec.DESTINATION_TYPE_CODE := l_tmp_destination_code;
        END IF;

        --End changes 3157829


    ELSE
      p_rcv_transaction_rec.currency_conversion_rate := l_currency_conversion_rate;
      p_rcv_transaction_rec.currency_conversion_date := l_currency_conversion_date;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('populate_default_values 120: ', 4);
    END IF;

    IF p_rcv_transaction_rec.receipt_source_code = 'VENDOR' THEN
      l_linelocationid := p_rcv_transaction_rec.po_line_location_id;

      SELECT NVL(match_option, 'P')
      INTO   l_matchflag
      FROM   po_line_locations_all
      WHERE  line_location_id = l_linelocationid;

      l_matchflag := SUBSTR(l_matchflag, 1, 1);
      l_rcvtrxid := p_rcv_transaction_rec.rcv_transaction_id;

      IF l_matchflag = 'R' THEN
        -- need to pick up rate from rcv_transactions
        SELECT currency_conversion_date
             , currency_conversion_rate
        INTO   l_ratedate
             , l_rate
        FROM   rcv_transactions
        WHERE  transaction_id = l_rcvtrxid;

        p_rcv_transaction_rec.currency_conversion_rate := l_rate;
        p_rcv_transaction_rec.currency_conversion_date := l_ratedate;
      END IF;

      l_rate := p_rcv_transaction_rec.currency_conversion_rate;

      IF (inv_rcv_common_apis.g_po_startup_value.display_inverse_rate = 'Y') THEN
        l_ratedisplay := 1 / l_rate;
      ELSE
        l_ratedisplay := l_rate;
      END IF;
    END IF;

    -- This part of the code is from the on-update trigger of
    -- rcv_transaction block in rcvtxert form.

    -- Chk transaction getting saved are not under EXPRESS mode and
    -- that you havent entered inspection data for this line.  When
    -- you enter inspection data the line is auto selected but you want
    -- to skip this line in that case.
    IF (l_debug = 1) THEN
      print_debug('populate_default_values 130: ', 4);
    END IF;

    IF (NVL(inv_rcv_common_apis.g_rcv_global_var.express_mode, 'NO') <> 'YES'
        AND p_rcv_transaction_rec.inspection_detail <> 'Y') THEN
      --dbms_output.put_line('before insert');

      -- Before this must populate the passed in parameters in the
      -- current row which include, revision, sub, locator_id
      p_rcv_transaction_rec.item_revision := p_revision;
      p_rcv_transaction_rec.subinventory_dsp := p_subinventory_code;
      p_rcv_transaction_rec.locator_id := p_locator_id;

      IF (l_debug = 1) THEN
        print_debug('populate_default_values 140: ', 4);
      END IF;

        /* Bug 8518384  : Because of below code, destination_type_code was getting
         overridden to INVENTORY for EXPENSE case also, because of which
         Standard delivery against Internal Req (with destination as EXPENSE)
         was populating destination_type_code as 'INVENTORY' instead of 'EXPENSE'.
         Not sure why this code has been added.
         To fix bug 8518384 , we are firing this code only when
         p_rcv_transaction_rec.destination_type_code is null */

      --IF WMS and PO patch levels are J or higher, from teh putaway UI, we will create
      --a TRANSFER transaction if the subinventory type is RECEIVING. If the Deliver API is
      --called, then the destination sub should be a storage subinventory. So we should set
      --the destination type code to Inventory
      IF p_rcv_transaction_rec.destination_type_code IS NULL THEN
        IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
           (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
             p_rcv_transaction_rec.destination_type_code := 'INVENTORY';
        END IF;
      END IF;

      -- bug 3198278
      -- If the destination_type_code is set to receiving for what ever
      -- reasons, then we need to validate the subinventory_type.
      -- If the subinventory_type is storage then we need to throw an
      -- exception since one cannot do a transfer in a storage sub.
      -- If the destination_type_code is receiving then the
      -- transaction_type is defaulted to be transfer in insert_interface_code
      IF p_rcv_transaction_rec.destination_type_code = 'RECEIVING'
	AND ((inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j)
        AND (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
	 l_subinventory_type := wms_putaway_utils.get_subinventory_type
	                             (p_subinventory_code => p_subinventory_code
				      , p_organization_id => p_organization_id);
	 IF Nvl(l_subinventory_type,1) = 1 THEN
	    IF (l_debug = 1) THEN
	       print_debug('populate_default_values 141 - trying to do transfer IN storage sub_type : ', 4);
	    END IF;
	    fnd_message.set_name('INV', 'INV_INVALID_SUB_TXN_COMBO');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;

      -- Call procedure INSERT_INTERFACE_CODE to populate RCV_TRANSACTION_INTERFACE
      -- table with updated transactions
      l_interface_transaction_id := insert_interface_code(
            p_rcv_transaction_rec
          , p_organization_id);

      --Store the interface_transaction_id in a global variable which would later
      --be used for splitting lots and serials
      g_interface_transaction_id := l_interface_transaction_id;

      --   Create the necessary rcv_lots_interface and rcv_serials_interface
      --   rows based on the rows created in the mtl_transactions_lots_temp
      --   and the  mtl_serial_numbers_temp table.
      --   There is an issue here between v10 and 10sc.
      --   In 10 we inserted rows into the rcv_lots_interface
      --   and rcv_serials_interface tables through the
      --   lot and serial forms.  In 10sc we are using the Inventory lot and
      --   serial forms which insert into the mtl_transaction_lots_temp and
      --   the mtl_serial_numbers_temp table.  The issue here is that if the
      --   transaction_interface row was created by a 10 client then we want
      --   to continue to insert into the mtl_ tables.  If this trx was
      --   generated through a 10sc client then we need to insert into the
      --   10sc tables.  We are adding a flag use_mtl_lot_serial that is null
      --   allowable to tell us whether to use the rcv_ tables or the mtl_
      --   tables)

      /* FP-J Lot/Serial Support Enhancement
       * If INV J and PO J are installed then lot and serial splits are done based
       * on the interface tables (MTLI/MSNI).
       * If either of these are not installed, use the existing logic to break
       * lots and serials based on temp records MTLI/MSNT
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
          (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN

        l_lot_serial_break_tbl(1).transaction_id := l_interface_transaction_id;
        l_lot_serial_break_tbl(1).primary_quantity := p_rcv_transaction_rec.primary_quantity;

        IF (l_debug = 1) THEN
          print_debug('populate_default_values 150: ', 4);
        END IF;
        insert_lot_serial(
            l_lot_serial_break_tbl
          , p_transaction_temp_id
          , p_lot_control_code
          , p_serial_control_code
          , l_interface_transaction_id);
      ELSE
        IF (l_debug = 1) THEN
          print_debug('populate_default_values 150: INV and PO patch levels are J or higher. No splits to temp records', 4);
        END IF;
      END IF;   --END IF check INV and PO patch levels

      IF (l_debug = 1) THEN
        print_debug('populate_default_values 160: ', 4);
      END IF;
    ELSIF(p_rcv_transaction_rec.inspection_detail = 'Y') THEN
      -- When we insert inspection transactions, we insert them with
      -- transaction_status_code = 'INSPECTION' and processing_status_code = 'INSPECTION'
      -- so they are not picked up as pending quantity to be processed.  Since
      -- we insert the rows (like a post but not actually a post when you click
      -- on the OK button from the inspection buttton.  If you were to immediately
      -- do another find and not save changes, (since this does not actually execute a
      -- database rollback) you would see this quantity as pending to be transacted if
      -- we inserted the rows as transaction_status_code = 'PENDING'

      l_rcv_transaction_id := p_rcv_transaction_rec.rcv_transaction_id;
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;

      UPDATE rcv_transactions_interface
      SET transaction_status_code = 'PENDING'
        , processing_status_code = 'PENDING'
      WHERE  parent_transaction_id = l_rcv_transaction_id
      AND    GROUP_ID = l_group_id
      AND    transaction_status_code = 'INSPECTION'
      AND    processing_status_code = 'INSPECTION'
      AND    transaction_type IN('ACCEPT', 'REJECT');
    END IF; -- transaction not related to EXPRESS mode

    IF (l_debug = 1) THEN
      print_debug('exiting populate_default_values 10: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  END;

  PROCEDURE create_osp_po_rcvtxn_intf_rec(
    p_organization_id         IN          NUMBER
  , p_po_header_id            IN          NUMBER
  , p_po_release_id           IN          NUMBER
  , p_po_line_id              IN          NUMBER
  , p_po_line_location_id     IN          NUMBER
  , p_po_distribution_id      IN          NUMBER
  , p_item_id                 IN          NUMBER
  , p_vendor_id               IN          NUMBER
  , p_revision                IN          VARCHAR2
  , p_rcvtxn_qty              IN          NUMBER
  , p_rcvtxn_uom              IN          VARCHAR2
  , p_transaction_temp_id     IN          NUMBER
  , p_original_txn_temp_id    IN          NUMBER DEFAULT NULL
  , x_status                  OUT NOCOPY  VARCHAR2
  , x_message                 OUT NOCOPY  VARCHAR2
  , p_inspection_status_code  IN          VARCHAR2 DEFAULT NULL
  , p_sec_rcvtxn_qty          IN          NUMBER   DEFAULT NULL  --OPM Convergence
  , p_secondary_uom           IN          VARCHAR2   DEFAULT NULL --OPM Convergence
  ) IS
    l_rcv_transaction_rec       rcvtxn_transaction_rec_tp;
    l_rcv_rcvtxn_rec            rcvtxn_enter_rec_cursor_rec;
    -- local record in which the values returned from the cursor are fetched.

    l_rcvtxn_match_table_detail inv_rcv_common_apis.cascaded_trans_tab_type;
    -- local variable to store the output of the matching algorithm

    l_msg_count                 NUMBER;
    l_return_status             VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_group_id                  NUMBER;
    l_transaction_type          VARCHAR2(20) := 'STD_DELIVER';
    l_total_primary_qty         NUMBER       := 0;
    l_err_message               VARCHAR2(100);
    l_temp_message              VARCHAR2(100);
    l_msg_prod                  VARCHAR2(5);
    l_progress                  VARCHAR2(10);

    CURSOR l_curs_rcvtxn_detail(v_po_distribution_id NUMBER
    													, v_rcv_txn_id NUMBER) IS
      SELECT   rsup.from_organization_id from_organization_id
             , rsup.to_organization_id to_organization_id
             , rt.source_document_code source_document_code
             , rsh.receipt_source_code receipt_source_code
             , rsup.rcv_transaction_id rcv_transaction_id
             , rt.transaction_date transaction_date
             , rt.transaction_type transaction_type
             , rt.primary_unit_of_measure primary_uom
             , rt.primary_quantity primary_quantity
             , rsup.po_header_id po_header_id
             , rt.po_revision_num po_revision_num
             , rsup.po_release_id po_release_id
             , rsh.vendor_id vendor_id
             , rt.vendor_site_id vendor_site_id
             , rsup.po_line_id po_line_id
             , rt.po_unit_price po_unit_price
             , rsl.category_id category_id
             , rsup.item_id item_id
             , msi.serial_number_control_code serial_number_control_code
             , msi.lot_control_code lot_control_code
             , rsup.item_revision item_revision
             , rsup.po_line_location_id po_line_location_id
             , rt.po_distribution_id po_distribution_id
             , rt.employee_id employee_id
             , rsl.comments comments
             , rsup.req_header_id req_header_id
             , rsup.req_line_id req_line_id
             , rsup.shipment_header_id shipment_header_id
             , rsup.shipment_line_id shipment_line_id
             , rsh.packing_slip packing_slip
             , rsl.government_context government_context
             , rsl.ussgl_transaction_code ussgl_transaction_code
             , rt.inspection_status_code inspection_status_code
             , rt.inspection_quality_code inspection_quality_code
             , rt.vendor_lot_num vendor_lot_num
             , pol.vendor_product_num vendor_item_number
             , rt.substitute_unordered_code substitute_unordered_code
             , rt.routing_header_id routing_id
             , rt.routing_step_id routing_step_id
             , rt.reason_id reason_id
             , rt.currency_code currency_code
             , pod.rate currency_conversion_rate
             , pod.rate_date currency_conversion_date
             , rt.currency_conversion_type currency_conversion_type
             , rsl.req_distribution_id req_distribution_id
             , rsup.destination_type_code destination_type_code_hold
             , pod.destination_type_code final_destination_type_code
             , rt.location_id location_id
             , pod.deliver_to_person_id final_deliver_to_person_id
             , pod.deliver_to_location_id final_deliver_to_location_id
             , rsl.to_subinventory subinventory
             , NVL(pol.un_number_id, msi.un_number_id) un_number_id
             , NVL(pol.hazard_class_id, msi.hazard_class_id) hazard_class_id
             , rsup.creation_date creation_date
             , rt.attribute_category attribute_category
             , rt.attribute1 attribute1
             , rt.attribute2 attribute2
             , rt.attribute3 attribute3
             , rt.attribute4 attribute4
             , rt.attribute5 attribute5
             , rt.attribute6 attribute6
             , rt.attribute7 attribute7
             , rt.attribute8 attribute8
             , rt.attribute9 attribute9
             , rt.attribute10 attribute10
             , rt.attribute11 attribute11
             , rt.attribute12 attribute12
             , rt.attribute13 attribute13
             , rt.attribute14 attribute14
             , rt.attribute15 attribute15
             , rt.qa_collection_id qa_collection_id
             , rsup.oe_order_header_id oe_order_header_id
             , rt.oe_order_line_id oe_order_line_id
             , rsh.customer_id customer_id
             , rsh.customer_site_id customer_site_id
             , pod.wip_entity_id wip_entity_id
             , pod.wip_operation_seq_num po_operation_seq_num
             , pod.wip_resource_seq_num po_resource_seq_num
             , pod.wip_repetitive_schedule_id wip_repetitive_schedule_id
             , pod.wip_line_id wip_line_id
             , pod.bom_resource_id bom_resource_id
             , pod.destination_subinventory final_subinventory
             , rt.SECONDARY_QUANTITY --OPM Convergence
             , rt.SECONDARY_UNIT_OF_MEASURE --OPM Convergence
	     --The following columns are needed for matching in cases where no LPN is involved
	     , rsup.to_subinventory              from_subinventory_code
	     , rsup.to_locator_id                from_locator_id
      FROM     rcv_transactions rt
             , rcv_supply rsup
             , rcv_shipment_headers rsh
             , rcv_shipment_lines rsl
             , mtl_system_items msi
             , po_lines pol
             , po_distributions pod
      WHERE    rsup.rcv_transaction_id = v_rcv_txn_id
      AND      rsup.to_organization_id = p_organization_id
      AND      pod.line_location_id = rsup.po_line_location_id
      AND      pod.po_distribution_id = v_po_distribution_id
      AND      rsl.shipment_line_id = rsup.shipment_line_id
      AND      rt.transaction_id = rsup.rcv_transaction_id
      AND      rsh.shipment_header_id = rsup.shipment_header_id
      AND      pol.po_line_id = rsup.po_line_id
      AND      msi.organization_id = rsup.to_organization_id
      AND      msi.inventory_item_id = rsup.item_id
      ORDER BY rt.transaction_date DESC;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Entering create_osp_po_rcvtxn_intf_rec:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';

    BEGIN
      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE;
    END;

    l_progress := '20';

    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
      INTO   l_group_id
      FROM   DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    END IF;

    l_progress := '30';
    -- call matching algorithm
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).GROUP_ID := l_group_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).transaction_type := l_transaction_type;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).quantity := p_rcvtxn_qty;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).unit_of_measure := p_rcvtxn_uom;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).item_id := p_item_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).revision := p_revision; -- 2252193
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).to_organization_id := p_organization_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_header_id := p_po_header_id;
    -- line id and line location id will be passed only from the putaway api.
    -- line id however, can also be passed from the UI.
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_line_id := p_po_line_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_release_id := p_po_release_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_line_location_id := p_po_line_location_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_distribution_id := p_po_distribution_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).expected_receipt_date := SYSDATE;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).tax_amount := 0;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_status := 'S';
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).inspection_status_code := p_inspection_status_code;

    BEGIN
      SELECT primary_unit_of_measure
      INTO   g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).primary_unit_of_measure
      FROM   mtl_system_items
      WHERE  mtl_system_items.inventory_item_id = p_item_id
      AND    mtl_system_items.organization_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    l_progress := '40';
    inv_rcv_txn_interface.matching_logic(
      x_return_status          => x_status
    , x_msg_count              => l_msg_count
    , x_msg_data               => x_message
    , x_cascaded_table         => g_rcvtxn_match_table_gross
    , n                        => g_rcvtxn_detail_index
    , temp_cascaded_table      => l_rcvtxn_match_table_detail
    , p_receipt_num            => NULL
    , p_shipment_header_id     => NULL
    , p_lpn_id                 => NULL
    );

    -- x_status is not successful if there is any execution error in matching.
    IF x_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('Exiting create_osp_po_rcvtxn_intf_rec 20:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RETURN;
    END IF;

    IF g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_status = 'E' THEN
      x_status := fnd_api.g_ret_sts_error;
      l_err_message := g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('exiting create_osp_po_rcvtxn_intf_rec 30:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RETURN;
    END IF;

    l_err_message := '@@@';

    FOR i IN g_rcvtxn_detail_index ..(g_rcvtxn_detail_index + l_rcvtxn_match_table_detail.COUNT - 1) LOOP
      IF l_rcvtxn_match_table_detail(i - g_rcvtxn_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcvtxn_match_table_detail(i - g_rcvtxn_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('adding tolerance message create_osp_po_rcvtxn_intf_rec 40:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    l_progress := '50';
    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI

    l_progress := '60';

    IF (l_debug = 1) THEN
      print_debug('create_osp_po_rcvtxn_intf_rec no recs matched by matching 50:' || l_rcvtxn_match_table_detail.COUNT, 4);
    END IF;

    -- loop through results returned by matching algorithm
    FOR match_result_count IN 1 .. l_rcvtxn_match_table_detail.COUNT LOOP
      IF (l_debug = 1) THEN
        print_debug('create_osp_po_rcvtxn_intf_rec found a match 60', 4);
        print_debug('Matching returned values 60.1 - distribution_id:' || l_rcvtxn_match_table_detail(match_result_count).po_distribution_id, 4);
        print_debug('Matching returned values 60.1 - rcv_transaction_id:' || l_rcvtxn_match_table_detail(match_result_count).parent_transaction_id, 4);
        print_debug('Matching returned values 60.1 - transaction_quantity:' || l_rcvtxn_match_table_detail(match_result_count).quantity, 4);
        print_debug('Matching returned values 60.1 - transaction_uom:' || l_rcvtxn_match_table_detail(match_result_count).unit_of_measure, 4);
        print_debug('Matching returned values 60.1 - primary_quantity:' || l_rcvtxn_match_table_detail(match_result_count).primary_quantity, 4);
        print_debug('Matching returned values 60.1 - primary_uom:' || l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure, 4);
      END IF;

      OPEN l_curs_rcvtxn_detail(
            l_rcvtxn_match_table_detail(match_result_count).po_distribution_id
          , l_rcvtxn_match_table_detail(match_result_count).parent_transaction_id);
      FETCH l_curs_rcvtxn_detail INTO l_rcv_rcvtxn_rec;
      CLOSE l_curs_rcvtxn_detail;
      l_rcv_transaction_rec.po_distribution_id := l_rcvtxn_match_table_detail(match_result_count).po_distribution_id;
      l_rcv_transaction_rec.transaction_quantity := l_rcvtxn_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcvtxn_match_table_detail(match_result_count).unit_of_measure;
      l_rcv_transaction_rec.primary_quantity := l_rcvtxn_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
      l_progress := '70';
      populate_default_values(
        p_rcv_transaction_rec      => l_rcv_transaction_rec
      , p_rcv_rcvtxn_rec           => l_rcv_rcvtxn_rec
      , p_organization_id          => p_organization_id
      , p_item_id                  => p_item_id
      , p_revision                 => p_revision
      , p_subinventory_code        => NULL
      , p_locator_id               => NULL
      , p_transaction_temp_id      => p_transaction_temp_id
      , p_lot_control_code         => NULL
      , p_serial_control_code      => NULL
      , p_original_txn_temp_id     => p_original_txn_temp_id
      );
      l_progress := '80';
    END LOOP;

    IF l_curs_rcvtxn_detail%ISOPEN THEN
      CLOSE l_curs_rcvtxn_detail;
    END IF;

    l_progress := '90';
    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 18
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '100';

    IF (l_debug = 1) THEN
      print_debug('Exiting create_osp_po_rcvtxn_intf_rec:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcvtxn_detail%ISOPEN THEN
        CLOSE l_curs_rcvtxn_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_rcv_std_deliver_apis.create_osp_po_rcvtxn_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END create_osp_po_rcvtxn_intf_rec;

  PROCEDURE create_po_rcvtxn_intf_rec(
    p_organization_id         IN          NUMBER
  , p_po_header_id            IN          NUMBER
  , p_po_release_id           IN          NUMBER
  , p_po_line_id              IN          NUMBER
  , p_po_line_location_id     IN          NUMBER
  , p_receipt_num             IN          VARCHAR2
  , p_item_id                 IN          NUMBER
  , p_vendor_id               IN          NUMBER
  , p_revision                IN          VARCHAR2
  , p_subinventory_code       IN          VARCHAR2
  , p_locator_id              IN          NUMBER
  , p_rcvtxn_qty              IN          NUMBER
  , p_rcvtxn_uom              IN          VARCHAR2
  , p_transaction_temp_id     IN          NUMBER
  , p_lot_control_code        IN          NUMBER
  , p_serial_control_code     IN          NUMBER
  , p_original_txn_temp_id    IN          NUMBER DEFAULT NULL
  , x_status                  OUT NOCOPY  VARCHAR2
  , x_message                 OUT NOCOPY  VARCHAR2
  , p_inspection_status_code  IN          VARCHAR2 DEFAULT NULL
  , p_lpn_id                  IN          NUMBER   DEFAULT NULL
  , p_transfer_lpn_id         IN          NUMBER   DEFAULT NULL
  , p_lot_number              IN          VARCHAR2 DEFAULT NULL
  , p_parent_txn_id           IN          NUMBER   DEFAULT NULL
  , p_deliver_to_location_id  IN          NUMBER   DEFAULT NULL
  , p_sec_rcvtxn_qty          IN          NUMBER   DEFAULT NULL  --OPM Convergence
  , p_secondary_uom           IN          VARCHAR2   DEFAULT NULL --OPM Convergence
  , p_rcvtxn_uom_code         IN          VARCHAR2 DEFAULT NULL
    ) IS
    l_rcv_transaction_rec       rcvtxn_transaction_rec_tp;
    l_rcv_rcvtxn_rec            rcvtxn_enter_rec_cursor_rec;
    -- local record in which the values returned from the cursor are fetched.

    l_rcvtxn_match_table_detail inv_rcv_common_apis.cascaded_trans_tab_type;
    -- local variable to store the output of the matching algorithm

    l_msg_count                 NUMBER;
    l_return_status             VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_group_id                  NUMBER;
    l_transaction_type          VARCHAR2(20) := 'STD_DELIVER';
    l_total_primary_qty         NUMBER       := 0;
    l_err_message               VARCHAR2(100);
    l_temp_message              VARCHAR2(100);
    l_msg_prod                  VARCHAR2(5);
    l_progress                  VARCHAR2(10);
    l_orig_mol_id               NUMBER       := NULL;
    l_new_txn_temp_id           NUMBER;
    l_mo_splt_tb                inv_rcv_integration_apis.mo_in_tb_tp;

    CURSOR l_curs_rcvtxn_detail(v_po_distribution_id NUMBER
    													, v_rcv_txn_id NUMBER) IS
      SELECT   rsup.from_organization_id from_organization_id
             , rsup.to_organization_id to_organization_id
             , rt.source_document_code source_document_code
             , rsh.receipt_source_code receipt_source_code
             , rsup.rcv_transaction_id rcv_transaction_id
             , rt.transaction_date transaction_date
             , rt.transaction_type transaction_type
             , rt.primary_unit_of_measure primary_uom
             , rt.primary_quantity primary_quantity
             , rsup.po_header_id po_header_id
             , rt.po_revision_num po_revision_num
             , rsup.po_release_id po_release_id
             , rsh.vendor_id vendor_id
             , rt.vendor_site_id vendor_site_id
             , rsup.po_line_id po_line_id
             , rt.po_unit_price po_unit_price
             , rsl.category_id category_id
             , rsup.item_id item_id
             , msi.serial_number_control_code serial_number_control_code
             , msi.lot_control_code lot_control_code
             , rsup.item_revision item_revision
             , rsup.po_line_location_id po_line_location_id
             , rt.po_distribution_id po_distribution_id
             , rt.employee_id employee_id
             , rsl.comments comments
             , rsup.req_header_id req_header_id
             , rsup.req_line_id req_line_id
             , rsup.shipment_header_id shipment_header_id
             , rsup.shipment_line_id shipment_line_id
             , rsh.packing_slip packing_slip
             , rsl.government_context government_context
             , rsl.ussgl_transaction_code ussgl_transaction_code
             , rt.inspection_status_code inspection_status_code
             , rt.inspection_quality_code inspection_quality_code
             , rt.vendor_lot_num vendor_lot_num
             , pol.vendor_product_num vendor_item_number
             , rt.substitute_unordered_code substitute_unordered_code
             , rt.routing_header_id routing_id
             , rt.routing_step_id routing_step_id
             , rt.reason_id reason_id
             , rt.currency_code currency_code
             , pod.rate currency_conversion_rate
             , pod.rate_date currency_conversion_date
             , rt.currency_conversion_type currency_conversion_type
             , rsl.req_distribution_id req_distribution_id
             , rsup.destination_type_code destination_type_code_hold
             , pod.destination_type_code final_destination_type_code
             , rt.location_id location_id
             , pod.deliver_to_person_id final_deliver_to_person_id
             , pod.deliver_to_location_id final_deliver_to_location_id
             , rsl.to_subinventory subinventory
             , NVL(pol.un_number_id, msi.un_number_id) un_number_id
             , NVL(pol.hazard_class_id, msi.hazard_class_id) hazard_class_id
             , rsup.creation_date creation_date
             , rt.attribute_category attribute_category
             , rt.attribute1 attribute1
             , rt.attribute2 attribute2
             , rt.attribute3 attribute3
             , rt.attribute4 attribute4
             , rt.attribute5 attribute5
             , rt.attribute6 attribute6
             , rt.attribute7 attribute7
             , rt.attribute8 attribute8
             , rt.attribute9 attribute9
             , rt.attribute10 attribute10
             , rt.attribute11 attribute11
             , rt.attribute12 attribute12
             , rt.attribute13 attribute13
             , rt.attribute14 attribute14
             , rt.attribute15 attribute15
             , rt.qa_collection_id qa_collection_id
             , rsup.oe_order_header_id oe_order_header_id
             , rt.oe_order_line_id oe_order_line_id
             , rsh.customer_id customer_id
             , rsh.customer_site_id customer_site_id
             , pod.wip_entity_id wip_entity_id
             , pod.wip_operation_seq_num po_operation_seq_num
             , pod.wip_resource_seq_num po_resource_seq_num
             , pod.wip_repetitive_schedule_id wip_repetitive_schedule_id
             , pod.wip_line_id wip_line_id
             , pod.bom_resource_id bom_resource_id
             , pod.destination_subinventory final_subinventory
             , rt.SECONDARY_QUANTITY --OPM Convergence
             , rt.SECONDARY_UNIT_OF_MEASURE --OPM Convergence
	     --The following columns are needed for matching in cases where no LPN is involved
	     , rsup.to_subinventory              from_subinventory_code
	     , rsup.to_locator_id                from_locator_id
      FROM     rcv_transactions rt
             , rcv_supply rsup
             , rcv_shipment_headers rsh
             , rcv_shipment_lines rsl
             , mtl_system_items msi
             , po_lines pol
             , po_distributions pod
      WHERE    rsup.rcv_transaction_id = v_rcv_txn_id
      AND      rsup.to_organization_id = p_organization_id
      AND      pod.line_location_id = rsup.po_line_location_id
      AND      pod.po_distribution_id = v_po_distribution_id
      AND      rsl.shipment_line_id = rsup.shipment_line_id
      AND      rt.transaction_id = rsup.rcv_transaction_id
      AND      rsh.shipment_header_id = rsup.shipment_header_id
      AND      pol.po_line_id = rsup.po_line_id
      AND      msi.organization_id = rsup.to_organization_id
      AND      msi.inventory_item_id = rsup.item_id
      ORDER BY rt.transaction_date DESC;

    --BUG 4500676: To be used for expense items
    CURSOR l_curs_rcvtxn_detail_exp (v_po_distribution_id NUMBER  , v_rcv_txn_id NUMBER) IS
      SELECT   rsup.from_organization_id from_organization_id
             , rsup.to_organization_id to_organization_id
             , rt.source_document_code source_document_code
             , rsh.receipt_source_code receipt_source_code
             , rsup.rcv_transaction_id rcv_transaction_id
             , rt.transaction_date transaction_date
             , rt.transaction_type transaction_type
             , rt.primary_unit_of_measure primary_uom
             , rt.primary_quantity primary_quantity
             , rsup.po_header_id po_header_id
             , rt.po_revision_num po_revision_num
             , rsup.po_release_id po_release_id
             , rsh.vendor_id vendor_id
             , rt.vendor_site_id vendor_site_id
             , rsup.po_line_id po_line_id
             , rt.po_unit_price po_unit_price
             , rsl.category_id category_id
             , rsup.item_id item_id
             , null
             , null
             , rsup.item_revision item_revision
             , rsup.po_line_location_id po_line_location_id
             , rt.po_distribution_id po_distribution_id
             , rt.employee_id employee_id
             , rsl.comments comments
             , rsup.req_header_id req_header_id
             , rsup.req_line_id req_line_id
             , rsup.shipment_header_id shipment_header_id
             , rsup.shipment_line_id shipment_line_id
             , rsh.packing_slip packing_slip
             , rsl.government_context government_context
             , rsl.ussgl_transaction_code ussgl_transaction_code
             , rt.inspection_status_code inspection_status_code
             , rt.inspection_quality_code inspection_quality_code
             , rt.vendor_lot_num vendor_lot_num
             , pol.vendor_product_num vendor_item_number
             , rt.substitute_unordered_code substitute_unordered_code
             , rt.routing_header_id routing_id
             , rt.routing_step_id routing_step_id
             , rt.reason_id reason_id
             , rt.currency_code currency_code
             , pod.rate currency_conversion_rate
             , pod.rate_date currency_conversion_date
             , rt.currency_conversion_type currency_conversion_type
             , rsl.req_distribution_id req_distribution_id
             , rsup.destination_type_code destination_type_code_hold
             , pod.destination_type_code final_destination_type_code
             , rt.location_id location_id
             , pod.deliver_to_person_id final_deliver_to_person_id
             , pod.deliver_to_location_id final_deliver_to_location_id
             , rsl.to_subinventory subinventory
             , un_number_id un_number_id
             , hazard_class_id hazard_class_id
             , rsup.creation_date creation_date
             , rt.attribute_category attribute_category
             , rt.attribute1 attribute1
             , rt.attribute2 attribute2
             , rt.attribute3 attribute3
             , rt.attribute4 attribute4
             , rt.attribute5 attribute5
             , rt.attribute6 attribute6
             , rt.attribute7 attribute7
             , rt.attribute8 attribute8
             , rt.attribute9 attribute9
             , rt.attribute10 attribute10
             , rt.attribute11 attribute11
             , rt.attribute12 attribute12
             , rt.attribute13 attribute13
             , rt.attribute14 attribute14
             , rt.attribute15 attribute15
             , rt.qa_collection_id qa_collection_id
             , rsup.oe_order_header_id oe_order_header_id
             , rt.oe_order_line_id oe_order_line_id
             , rsh.customer_id customer_id
             , rsh.customer_site_id customer_site_id
             , pod.wip_entity_id wip_entity_id
             , pod.wip_operation_seq_num po_operation_seq_num
             , pod.wip_resource_seq_num po_resource_seq_num
             , pod.wip_repetitive_schedule_id wip_repetitive_schedule_id
             , pod.wip_line_id wip_line_id
             , pod.bom_resource_id bom_resource_id
             , pod.destination_subinventory final_subinventory
             , rt.SECONDARY_QUANTITY --OPM Convergence
             , rt.SECONDARY_UNIT_OF_MEASURE --OPM Convergence
	     --The following columns are needed for matching in cases where no LPN is involved
	     , rsup.to_subinventory              from_subinventory_code
	     , rsup.to_locator_id                from_locator_id
      FROM     rcv_transactions rt
             , rcv_supply rsup
             , rcv_shipment_headers rsh
             , rcv_shipment_lines rsl
             , po_lines pol
             , po_distributions pod
      WHERE    rsup.rcv_transaction_id = v_rcv_txn_id
      AND      rsup.to_organization_id = p_organization_id
      AND      pod.line_location_id = rsup.po_line_location_id
      AND      pod.po_distribution_id = v_po_distribution_id
      AND      rsl.shipment_line_id = rsup.shipment_line_id
      AND      rt.transaction_id = rsup.rcv_transaction_id
      AND      rsh.shipment_header_id = rsup.shipment_header_id
      AND      pol.po_line_id = rsup.po_line_id
      ORDER BY rt.transaction_date DESC;
    --END BUG 4500676



    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok     BOOLEAN;   --Return status of lot_serial_split API
    l_prim_uom_code           VARCHAR2(3);
    l_rcvtxn_uom_code         VARCHAR2(3);
  BEGIN
    x_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Entering create_po_rcvtxn_intf_rec:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('  p_item_id    => '||p_item_id,4);
    END IF;

    l_progress := '10';

    --dbms_output.put_line('In create po');
    BEGIN
      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE;
    END;

    l_progress := '20';

    -- default l_group_id ?? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
      INTO   l_group_id
      FROM   DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    END IF;

    l_progress := '30';
    -- call matching algorithm
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).GROUP_ID := l_group_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).transaction_type := l_transaction_type;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).quantity := p_rcvtxn_qty;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).unit_of_measure := p_rcvtxn_uom;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).item_id := p_item_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).revision := p_revision; -- 2252193
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).to_organization_id := p_organization_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_header_id := p_po_header_id;
    -- line id and line location id will be passed only from the putaway api.
    -- line id however, can also be passed from the UI.
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_line_id := p_po_line_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_release_id := p_po_release_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_line_location_id := p_po_line_location_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).p_lpn_id := p_lpn_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).expected_receipt_date := SYSDATE; --?
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).tax_amount := 0; -- ?
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_status := 'S'; -- ?
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).inspection_status_code := p_inspection_status_code;

    /* FP-J Lot/Serial Support Enhancement
     * If INV and PO J are installed, then the lots for the parent transaction will
     * be stored in rcv_lots_supply. We must match the lot number passed with that
     * of the parent transaction and also the parent_txn_id
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
          (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).lot_number := p_lot_number;
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).parent_transaction_id := p_parent_txn_id;
    ELSE
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).lot_number := NULL;
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).parent_transaction_id := NULL;
    END IF;

    BEGIN
      SELECT primary_unit_of_measure
      INTO   g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).primary_unit_of_measure
      FROM   mtl_system_items
      WHERE  mtl_system_items.inventory_item_id = p_item_id
      AND    mtl_system_items.organization_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      --Bug5574012:In case of one time items,the UOM will be fetched from the
      --PO data.Setting the g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).primary_unit_of_measure
      --to null.
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).primary_unit_of_measure := NULL;
      --NULL;
    END;

    --BUG 4364407
    IF g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).item_id IS NULL AND
       g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).item_desc IS NULL THEN
       BEGIN
	  SELECT item_description
	    INTO   g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).item_desc
	    FROM   po_lines_all pla
	    WHERE pla.po_header_id =g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_header_id
	    AND pla.po_line_id =g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).po_line_id;
       EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     NULL;
       END;

       IF (l_debug = 1) THEN
	  print_debug('g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).item_desc' || g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).item_desc, 1);
       END IF;
    END IF;
    --END BUG 4500676

    l_progress := '40';
    inv_rcv_txn_interface.matching_logic(
      x_return_status          => x_status
    , x_msg_count              => l_msg_count
    , x_msg_data               => x_message
    , x_cascaded_table         => g_rcvtxn_match_table_gross
    , n                        => g_rcvtxn_detail_index
    , temp_cascaded_table      => l_rcvtxn_match_table_detail
    , p_receipt_num            => p_receipt_num
    , p_shipment_header_id     => NULL
    , p_lpn_id                 => NULL
    );

    -- x_status is not successful if there is any execution error in matching.
    IF x_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('Exiting create_po_rcvtxn_intf_rec 20:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RETURN;
    END IF;

    IF g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_status = 'E' THEN
      x_status := fnd_api.g_ret_sts_error;
      l_err_message := g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('exiting create_po_rcvtxn_intf_rec 30:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RETURN;
    END IF;

    l_err_message := '@@@';

    FOR i IN g_rcvtxn_detail_index ..(g_rcvtxn_detail_index + l_rcvtxn_match_table_detail.COUNT - 1) LOOP
      IF l_rcvtxn_match_table_detail(i - g_rcvtxn_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcvtxn_match_table_detail(i - g_rcvtxn_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('adding tolerance message create_po_rcvtxn_intf_rec 40:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    l_progress := '50';
    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI

    l_progress := '60';

    IF (l_debug = 1) THEN
      print_debug('create_po_rcvtxn_intf_rec no recs matched by matching 50:' || l_rcvtxn_match_table_detail.COUNT, 4);
    END IF;

    -- loop through results returned by matching algorithm
    FOR match_result_count IN 1 .. l_rcvtxn_match_table_detail.COUNT LOOP
      IF (l_debug = 1) THEN
        print_debug('create_po_rcvtxn_intf_rec found a match 60', 4);
        print_debug(
          'Matching returned values 60.1 - distribution_id:' || l_rcvtxn_match_table_detail(match_result_count).po_distribution_id, 4);
        print_debug('Matching returned values 60.1 - rcv_transaction_id:' || l_rcvtxn_match_table_detail(match_result_count).parent_transaction_id, 4);
        print_debug('Matching returned values 60.1 - transaction_quantity:' || l_rcvtxn_match_table_detail(match_result_count).quantity, 4);
        print_debug('Matching returned values 60.1 - transaction_uom:' || l_rcvtxn_match_table_detail(match_result_count).unit_of_measure, 4);
        print_debug('Matching returned values 60.1 - primary_quantity:' || l_rcvtxn_match_table_detail(match_result_count).primary_quantity, 4);
        print_debug('Matching returned values 60.1 - primary_uom:' || l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure, 4);
      END IF;

      --BUG 4500676: Use the cursor for expense PO if normal cursor does not
      --get the values.
      IF (p_item_id IS NOT NULL) THEN
	 OPEN l_curs_rcvtxn_detail(
                 l_rcvtxn_match_table_detail(match_result_count).po_distribution_id
               , l_rcvtxn_match_table_detail(match_result_count).parent_transaction_id
				   );
	 FETCH l_curs_rcvtxn_detail INTO l_rcv_rcvtxn_rec;
	 CLOSE l_curs_rcvtxn_detail;
       ELSE
	 OPEN l_curs_rcvtxn_detail_exp(
                 l_rcvtxn_match_table_detail(match_result_count).po_distribution_id
               , l_rcvtxn_match_table_detail(match_result_count).parent_transaction_id
				       );
	 FETCH l_curs_rcvtxn_detail_exp  INTO l_rcv_rcvtxn_rec;
	 CLOSE l_curs_rcvtxn_detail_exp;
      END IF;
      --END BUG 4500676

      -- update following fields from matching algorithm return value
      -- Bug No 1823328 Changes.
      l_rcv_transaction_rec.po_distribution_id := l_rcvtxn_match_table_detail(match_result_count).po_distribution_id;

      --R12: create RTI with uom entered by user
      IF (p_item_id IS NOT NULL) THEN
	 l_prim_uom_code := inv_rcv_cache.get_primary_uom_code(p_organization_id,p_item_id);

	 IF (p_rcvtxn_uom_code IS NULL) THEN
	    SELECT   uom_code
	      INTO   l_rcvtxn_uom_code
	      FROM   mtl_item_uoms_view
	      WHERE  organization_id = p_organization_id
	      AND    inventory_item_id = p_item_id
	      AND    unit_of_measure = p_rcvtxn_uom
	      AND    ROWNUM < 2;
	  ELSE
	    l_rcvtxn_uom_code := p_rcvtxn_uom_code;
	 END IF;

	 IF (l_rcvtxn_uom_code <> l_prim_uom_code) THEN
	    l_rcv_transaction_rec.transaction_quantity := inv_rcv_cache.Convert_qty
	      (p_inventory_item_id => p_item_id
	       ,p_from_qty         => l_rcvtxn_match_table_detail(match_result_count).primary_quantity
	       ,p_from_uom_code    => l_prim_uom_code
	       ,p_to_uom_code      => l_rcvtxn_uom_code);
	    l_rcv_transaction_rec.transaction_uom := p_rcvtxn_uom;
	  ELSE
	    l_rcv_transaction_rec.transaction_quantity := l_rcvtxn_match_table_detail(match_result_count).primary_quantity;
	    l_rcv_transaction_rec.transaction_uom := l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure;
	 END IF;
       ELSE
	 IF (p_rcvtxn_uom_code IS NULL) THEN
	    BEGIN
	       SELECT  uom_code
		 INTO  l_rcvtxn_uom_code
		 FROM  mtl_units_of_measure
		 WHERE unit_of_measure = p_rcvtxn_uom
		 AND   ROWNUM < 2;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('Error retrieving UOM_CODE. SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,4);
		  END IF;
	    END;
	  ELSE
	    l_rcvtxn_uom_code := p_rcvtxn_uom_code;
	 END IF;

	 BEGIN
	    SELECT  uom_code
	      INTO  l_prim_uom_code
	      FROM  mtl_units_of_measure
	      WHERE unit_of_measure = l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure
	      AND   ROWNUM < 2;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('Error retrieving PRIM UOM_CODE. SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,4);
	       END IF;
	 END;

	 IF (l_debug = 1) THEN
	    print_debug('l_rcvtxn_uom_code:'||l_rcvtxn_uom_code,4);
	    print_debug('l_prim_uom_code:'||l_prim_uom_code,4);
	 END IF;

	 IF (l_rcvtxn_uom_code <> l_prim_uom_code) THEN
	    l_rcv_transaction_rec.transaction_quantity := inv_rcv_cache.Convert_qty
	      (p_inventory_item_id => NULL
	       ,p_from_qty         => l_rcvtxn_match_table_detail(match_result_count).primary_quantity
	       ,p_from_uom_code    => l_prim_uom_code
	       ,p_to_uom_code      => l_rcvtxn_uom_code);
	    l_rcv_transaction_rec.transaction_uom := p_rcvtxn_uom;
	  ELSE
	    l_rcv_transaction_rec.transaction_quantity := l_rcvtxn_match_table_detail(match_result_count).primary_quantity;
	    l_rcv_transaction_rec.transaction_uom := l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure;
	 END IF;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('Matching returned values 60.1 - l_rcv_transaction_rec.transaction_quantity :' ||l_rcv_transaction_rec.transaction_quantity  , 4);
	 print_debug('Matching returned values 60.1 - l_rcv_transaction_rec.transaction_uom :' ||l_rcv_transaction_rec.transaction_uom, 4);
      END IF;
      --R12 END

      l_rcv_transaction_rec.primary_quantity := l_rcvtxn_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure;

      /*OPM Convergence..calculate the secondary qty from the corresponding values obtained from matching logic's primary qty*/
      l_rcv_transaction_rec.sec_transaction_quantity := (l_rcvtxn_match_table_detail(match_result_count).quantity/p_rcvtxn_qty) * p_sec_rcvtxn_qty;
       print_debug('Matching returned values 60.1 -  l_rcv_transaction_rec.secondary_quantity:' ||  l_rcv_transaction_rec.sec_transaction_quantity, 4);

      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
      IF (p_deliver_to_location_id IS NOT NULL) THEN
	 l_rcv_rcvtxn_rec.final_deliver_to_location_id := p_deliver_to_location_id;
      END IF;
      l_progress := '70';

      -- Only call split MO for patchset J or higher
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
	  (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
	 -- Added addition check for p_original_txn_temp_id: if it is null,
	 -- then simply insert RTI with the MMTT column as null
	 IF p_original_txn_temp_id IS NULL OR l_rcvtxn_match_table_detail.COUNT = 1 THEN
	    l_new_txn_temp_id := p_original_txn_temp_id;
	  ELSE --More than 1 result returned from matching logic
	    -- Call split mo
	    IF (l_debug = 1) THEN
	       print_debug('create_po_rcvtxn_intf_rec calling split_mo',4);
	    END IF;

	    IF (l_orig_mol_id IS NULL) THEN
               BEGIN
		  SELECT move_order_line_id
		    INTO l_orig_mol_id
		    FROM mtl_material_transactions_temp
		    WHERE transaction_temp_id = p_original_txn_temp_id;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('create_po_rcvtxn_intf_rec: Error retrieving MOL id',4);
		     END IF;
		     RAISE fnd_api.g_exc_error;
	       END;
	    END IF; --IF (l_orig_mol_id IS NULL) THEN


	    l_mo_splt_tb(1).prim_qty := l_rcv_transaction_rec.primary_quantity;
	    l_mo_splt_tb(1).line_id := NULL;

	    IF (l_debug = 1) THEN
	       print_debug('create_po_rcvtxn_intf_rec: Calling split_mo',4);
	       print_debug('    (p_orig_mol_id ====> ' || l_orig_mol_id,4);
	       print_debug('    (p_mo_splt_tb.prim_qty ==> ' || l_mo_splt_tb(1).prim_qty,4);
	       print_debug('    (p_operation_type => ' || 'DELIVER',4);
	       print_debug('    (p_txn_header_id  => ' || p_original_txn_temp_id,4);
	    END IF;

	    inv_rcv_integration_apis.split_mo
	      (p_orig_mol_id => l_orig_mol_id,
	       p_mo_splt_tb => l_mo_splt_tb,
	       p_operation_type => 'DELIVER',
	       p_txn_header_id => p_original_txn_temp_id,
	       x_return_status => l_return_status,
	       x_msg_count => l_msg_count,
	       x_msg_data => x_message);

	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       RAISE fnd_api.g_exc_error;
	    END IF;
	    l_progress := '75';

            BEGIN
	       SELECT transaction_temp_id
		 INTO l_new_txn_temp_id
		 FROM mtl_material_transactions_temp
		 WHERE move_order_line_id = l_mo_splt_tb(1).line_id;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('create_po_rcvtxn_intf_rec: Error retrieving new mmtt id',4);
		  END IF;
	    END;
	 END IF; --l_rcvtxn_match_table_detail.COUNT = 1

	 IF (l_debug = 1) THEN
	    print_debug('create_po_rcvtxn_intf_rec RTI to be inserted with mmtt id: ' ||
			l_new_txn_temp_id || ' p_transaction_temp_id = ' ||
			p_transaction_temp_id,4);
	 END IF;
       ELSE  -- If lower than J
	 l_new_txn_temp_id := p_original_txn_temp_id;
      END IF;

    --dbms_output.put_line('Got a match');
      populate_default_values(
        p_rcv_transaction_rec      => l_rcv_transaction_rec
      , p_rcv_rcvtxn_rec           => l_rcv_rcvtxn_rec
      , p_organization_id          => p_organization_id
      , p_item_id                  => p_item_id
      , p_revision                 => p_revision
      , p_subinventory_code        => p_subinventory_code
      , p_locator_id               => p_locator_id
      , p_transaction_temp_id      => p_transaction_temp_id
      , p_lot_control_code         => p_lot_control_code
      , p_serial_control_code      => p_serial_control_code
      , p_original_txn_temp_id     => l_new_txn_temp_id
      , p_lpn_id                   => p_lpn_id
      , p_transfer_lpn_id          => p_transfer_lpn_id
      );
      l_progress := '80';

     /* FP-J Lot/Serial Support Enhancement
       * Populate the table to store the information of the RTIs created used for
       * splitting the lots and serials based on RTI quantity
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
          (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
        l_new_rti_info(match_result_count).orig_interface_trx_id := p_transaction_temp_id;
        l_new_rti_info(match_result_count).new_interface_trx_id := g_interface_transaction_id;
        l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_quantity;
        l_new_rti_info(match_result_count).sec_qty := l_rcv_transaction_rec.sec_transaction_quantity;--OPM Convergence
        l_new_rti_info(match_result_count).sec_uom_code := l_rcv_transaction_rec.secondary_uom; --OPM Convergence
        IF (l_debug = 1) THEN
          print_debug('create_po_rcvtxn_intf_rec: 65 - Populated the table for lot/serial split', 4);
        END IF;
      END IF;   --END IF populate the table to store RTI info that was just created
    END LOOP;

    --g_rcvtxn_detail_index := l_rcvtxn_match_table_detail.COUNT + g_rcvtxn_detail_index;

    IF l_curs_rcvtxn_detail%ISOPEN THEN
      CLOSE l_curs_rcvtxn_detail;
    END IF;

    /* FP-J Lot/Serial Support Enhancement
     * Call the split_lot API to split the lots and serials inserted from the UI
     * based on the quantity of each RTI record
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN

      IF (p_lot_control_code > 1 OR p_serial_control_code > 1) THEN
	      --BUG 3326408
	      IF (p_lot_control_code > 1 AND p_serial_control_code = 6) THEN
	        IF (l_debug = 1) THEN
	          print_debug('create_po_rcvtxn_intf_rec 65.3: serial_control_code IS 6, need TO NULL OUT mtli', 4);
	        END IF;
	        BEGIN
	          UPDATE mtl_transaction_lots_interface
	          SET  serial_transaction_temp_id = NULL
	          WHERE product_transaction_id = p_transaction_temp_id
	          AND   product_code = 'RCV';
	        EXCEPTION
	          WHEN OTHERS THEN
		          IF (l_debug = 1) THEN
		          print_debug('create_po_rcvtxn_intf_rec 65.7: Error nulling serial temp id OF MTLI', 4);
		          END IF;
	        END ;
      END IF;--IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN

      l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
                p_api_version   => 1.0
              , p_init_msg_lst  => FND_API.G_FALSE
              , x_return_status =>  l_return_status
              , x_msg_count     =>  l_msg_count
              , x_msg_data      =>  x_message
              , p_new_rti_info  =>  l_new_rti_info);
        IF ( NOT l_split_lot_serial_ok) THEN
          IF (l_debug = 1) THEN
            print_debug('create_po_rcvtxn_intf_rec 67: Failure in split_lot_serial', 4);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_debug = 1) THEN
          print_debug('create_po_rcvtxn_intf_rec 68: Call split_lot_serial is OK', 4);
        END IF;
      END IF;   --END IF check lot and serial controls
    END IF;   --END IF check INV J and PO J installed

    l_progress := '90';
    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 18
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '100';

    IF (l_debug = 1) THEN
      print_debug('Exiting create_po_rcvtxn_intf_rec:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcvtxn_detail%ISOPEN THEN
        CLOSE l_curs_rcvtxn_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_rcv_std_deliver_apis.create_po_rcvtxn_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END create_po_rcvtxn_intf_rec;

  PROCEDURE create_int_shp_rcvtxn_intf_rec(
    p_organization_id         IN          NUMBER
  , p_shipment_header_id      IN          NUMBER
  , p_shipment_line_id        IN          NUMBER
  , p_receipt_num             IN          VARCHAR2
  , p_item_id                 IN          NUMBER
  , p_source_id               IN          NUMBER
  , p_revision                IN          VARCHAR2
  , p_subinventory_code       IN          VARCHAR2
  , p_locator_id              IN          NUMBER
  , p_rcvtxn_qty              IN          NUMBER
  , p_rcvtxn_uom              IN          VARCHAR2
  , p_transaction_temp_id     IN          NUMBER
  , p_lot_control_code        IN          NUMBER
  , p_serial_control_code     IN          NUMBER
  , p_original_txn_temp_id    IN          NUMBER DEFAULT NULL
  , x_status                  OUT NOCOPY  VARCHAR2
  , x_message                 OUT NOCOPY  VARCHAR2
  , p_inspection_status_code  IN          VARCHAR2 DEFAULT NULL
  , p_lpn_id                  IN          NUMBER   DEFAULT NULL
  , p_transfer_lpn_id         IN          NUMBER   DEFAULT NULL
  , p_lot_number              IN          VARCHAR2 DEFAULT NULL
  , p_parent_txn_id           IN          NUMBER   DEFAULT NULL
  , p_sec_rcvtxn_qty          IN          NUMBER   DEFAULT NULL  --OPM Convergence
  , p_secondary_uom           IN          VARCHAR2   DEFAULT NULL --OPM Convergence
  , p_rcvtxn_uom_code         IN          VARCHAR2 DEFAULT NULL
  ) IS
    l_rcv_transaction_rec       rcvtxn_transaction_rec_tp;
    l_rcv_rcvtxn_rec            rcvtxn_enter_rec_cursor_rec;
    -- local record in which the values returned from the cursor are fetched.

    l_rcvtxn_match_table_detail inv_rcv_common_apis.cascaded_trans_tab_type;
    -- local variable to store the output of the matching algorithm

    l_msg_count                 NUMBER;
    l_return_status             VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_group_id                  NUMBER;
    l_transaction_type          VARCHAR2(20) := 'STD_DELIVER';
    l_total_primary_qty         NUMBER       := 0;
    l_asn_type                  VARCHAR2(25);
    l_source_type               VARCHAR2(80);
    l_source_code               VARCHAR2(30);
    l_err_message               VARCHAR2(100);
    l_temp_message              VARCHAR2(100);
    l_msg_prod                  VARCHAR2(5);
    l_progress                  VARCHAR2(10);
    l_orig_mol_id               NUMBER        := NULL;
    l_new_txn_temp_id           NUMBER;
    l_mo_splt_tb                inv_rcv_integration_apis.mo_in_tb_tp;

    CURSOR l_curs_rcvtxn_detail(v_shipment_line_id NUMBER
    													, v_rcv_txn_id NUMBER) IS
      SELECT   rsup.from_organization_id from_organization_id
             , rsup.to_organization_id to_organization_id
             , rt.source_document_code source_document_code
             , rsh.receipt_source_code receipt_source_code
             , rsup.rcv_transaction_id rcv_transaction_id
             , rt.transaction_date transaction_date
             , rt.transaction_type transaction_type
             , rt.primary_unit_of_measure primary_uom
             , rt.primary_quantity primary_quantity
             , rsup.po_header_id po_header_id
             , rt.po_revision_num po_revision_num
             , rsup.po_release_id po_release_id
             , rsh.vendor_id vendor_id
             , rt.vendor_site_id vendor_site_id
             , rsup.po_line_id po_line_id
             , rt.po_unit_price po_unit_price
             , rsl.category_id category_id
             , rsup.item_id item_id
             , msi.serial_number_control_code serial_number_control_code
             , msi.lot_control_code lot_control_code
             , rsup.item_revision item_revision
             , rsup.po_line_location_id po_line_location_id
             , rt.po_distribution_id po_distribution_id
             , rt.employee_id employee_id
             , rsl.comments comments
             , rsup.req_header_id req_header_id
             , rsup.req_line_id req_line_id
             , rsup.shipment_header_id shipment_header_id
             , rsup.shipment_line_id shipment_line_id
             , rsh.packing_slip packing_slip
             , rsl.government_context government_context
             , rsl.ussgl_transaction_code ussgl_transaction_code
             , rt.inspection_status_code inspection_status_code
             , rt.inspection_quality_code inspection_quality_code
             , rt.vendor_lot_num vendor_lot_num
             , '' vendor_item_number
             , rt.substitute_unordered_code substitute_unordered_code
             , rt.routing_header_id routing_id
             , rt.routing_step_id routing_step_id
             , rt.reason_id reason_id
             , rt.currency_code currency_code
             , rt.currency_conversion_rate currency_conversion_rate
             , rt.currency_conversion_date currency_conversion_date
             , rt.currency_conversion_type currency_conversion_type
             , rsl.req_distribution_id req_distribution_id
             , rsup.destination_type_code destination_type_code_hold
             , rsup.destination_type_code final_destination_type_code
             , rt.location_id location_id
             , rsl.deliver_to_person_id final_deliver_to_person_id
             , rsl.deliver_to_location_id final_deliver_to_location_id
             , rsl.to_subinventory subinventory
             , msi.un_number_id un_number_id
             , msi.hazard_class_id hazard_class_id
             , rsup.creation_date creation_date
             , rt.attribute_category attribute_category
             , rt.attribute1 attribute1
             , rt.attribute2 attribute2
             , rt.attribute3 attribute3
             , rt.attribute4 attribute4
             , rt.attribute5 attribute5
             , rt.attribute6 attribute6
             , rt.attribute7 attribute7
             , rt.attribute8 attribute8
             , rt.attribute9 attribute9
             , rt.attribute10 attribute10
             , rt.attribute11 attribute11
             , rt.attribute12 attribute12
             , rt.attribute13 attribute13
             , rt.attribute14 attribute14
             , rt.attribute15 attribute15
             , rt.qa_collection_id qa_collection_id
             , rsup.oe_order_header_id oe_order_header_id
             , rt.oe_order_line_id oe_order_line_id
             , rsh.customer_id customer_id
             , rsh.customer_site_id customer_site_id
             , NULL wip_entity_id
             , NULL po_operation_seq_num
             , NULL po_resource_seq_num
             , NULL wip_repetitive_schedule_id
             , NULL wip_line_id
             , NULL bom_resource_id
             , NULL final_subinventory
             , rt.SECONDARY_QUANTITY --OPM Convergence
             , rt.SECONDARY_UNIT_OF_MEASURE --OPM Convergence
	     --The following columns are needed for matching in cases where no LPN is involved
	     , rsup.to_subinventory              from_subinventory_code
	     , rsup.to_locator_id                from_locator_id
      FROM     rcv_transactions rt
      			 , rcv_supply rsup
      			 , rcv_shipment_headers rsh
      			 , rcv_shipment_lines rsl
      			 , mtl_system_items msi
      WHERE    rsup.rcv_transaction_id = v_rcv_txn_id
      AND      rsup.shipment_line_id = v_shipment_line_id
      AND      rsup.to_organization_id = p_organization_id
      AND      rsl.shipment_line_id = rsup.shipment_line_id
      AND      rt.transaction_id = rsup.rcv_transaction_id
      AND      rsh.shipment_header_id = rsup.shipment_header_id
      AND      msi.organization_id = rsup.to_organization_id
      AND      msi.inventory_item_id = rsup.item_id
      ORDER BY rt.transaction_date DESC;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok     BOOLEAN;   --Return status of lot_serial_split API
    l_msni_count              NUMBER := 0;
    l_prim_uom_code           VARCHAR2(3);
    l_rcvtxn_uom_code         VARCHAR2(3);
    l_lot_number              mtl_transaction_lots_interface.lot_number%TYPE; --Bug 13400589
  BEGIN
    x_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Entering create_int_shp_rcvtxn_intf_rec:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';

    BEGIN
      /*Begin Bug Fix 4158984
        Setting value of INV_RCV_COMMON_APIS.g_rcv_global_var.receipt_num to a
        dummy value of -9999 as if this value is null, we are generating recepit
        numbers during delivery transaction which is not required.
        We are setting value back to null after call to inv_rcv_common_apis.init_startup_values.
      */
      INV_RCV_COMMON_APIS.g_rcv_global_var.receipt_num := -9999;
      inv_rcv_common_apis.init_startup_values(p_organization_id);
      INV_RCV_COMMON_APIS.g_rcv_global_var.receipt_num := NULL;
      /*End bug 4158984*/
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE;
    END;

    l_progress := '20';

    -- default l_group_id ?? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
      INTO   l_group_id
      FROM   DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    END IF;

    -- default some header level variables based on the header id passed
    SELECT asn_type
    INTO   l_asn_type
    FROM   rcv_shipment_headers
    WHERE  shipment_header_id = p_shipment_header_id;

    -- If l_asn_type is NULL then this shipment is not from ASN
    IF l_asn_type IS NOT NULL THEN
      IF NVL(l_asn_type, 'STD') = 'STD' THEN
        l_source_type := 'INTERNAL';
      ELSE
        l_source_type := 'VENDOR';
      END IF;
    ELSE
      -- Not an ASN shipment.
      SELECT receipt_source_code
      INTO   l_source_code
      FROM   rcv_shipment_headers
      WHERE  shipment_header_id = p_shipment_header_id;

      IF l_source_code = 'VENDOR' THEN
        l_source_type := 'VENDOR';
      ELSE -- source code of 'INVENTORY' or 'INTERNAL ORDER'
        l_source_type := 'INTERNAL';
      END IF;
    END IF;

    --Bug 13400589
    IF(p_lot_number IS NULL) THEN
        BEGIN
             SELECT  lot_number INTO l_lot_number
             FROM mtl_transaction_lots_interface
             WHERE  product_transaction_id = p_transaction_temp_id ;
          EXCEPTION
          WHEN No_Data_Found THEN
              IF (l_debug = 1) THEN
                 print_debug('create_int_shp_rcvtxn_intf_rec: No Lot records in MTLI for id :'||p_transaction_temp_id,4);
              END IF;
              l_lot_number :=NULL;
          WHEN too_many_rows THEN
               IF (l_debug = 1) THEN
                 print_debug('create_int_shp_rcvtxn_intf_rec: More than one records in MTLI for id :'||p_transaction_temp_id,4);
              END IF;
              l_lot_number :=NULL; --For multiple lots dont input to matching logic
         END;
    ELSE
       l_lot_number:=p_lot_number;
    END IF;

    IF (l_debug = 1) THEN
        print_debug('create_int_shp_rcvtxn_intf_rec: 30.2 l_lot_number: ' || l_lot_number, 4);
    END IF;

    l_progress := '30';
    -- call matching algorithm
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).GROUP_ID := l_group_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).transaction_type := l_transaction_type;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).quantity := p_rcvtxn_qty;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).unit_of_measure := p_rcvtxn_uom;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).item_id := p_item_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).revision := p_revision; -- 2252193
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).shipment_header_id := p_shipment_header_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).shipment_line_id := p_shipment_line_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).to_organization_id := p_organization_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).from_organization_id := p_source_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).p_lpn_id := p_lpn_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).expected_receipt_date := SYSDATE; --?
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).tax_amount := 0; -- ?
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_status := 'S'; -- ?
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).inspection_status_code := p_inspection_status_code;

    /* FP-J Lot/Serial Support Enhancement
     * If INV and PO J are installed, then the lots for the parent transaction will
     * be stored in rcv_lots_supply. We must match the lot number passed with that
     * of the parent transaction and also the parent_txn_id
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
          (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).lot_number := l_lot_number;
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).parent_transaction_id := p_parent_txn_id;
    ELSE
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).lot_number := NULL;
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).parent_transaction_id := NULL;
    END IF;

    BEGIN
      SELECT primary_unit_of_measure
      INTO   g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).primary_unit_of_measure
      FROM   mtl_system_items
      WHERE  mtl_system_items.inventory_item_id = p_item_id
      AND    mtl_system_items.organization_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    l_progress := '40';
    if (l_asn_type = 'ASN') then
    	inv_rcv_txn_match.matching_logic(
      	x_return_status         => x_status  --?
    	, x_msg_count             => l_msg_count
    	, x_msg_data              => x_message
    	, x_cascaded_table        => g_rcvtxn_match_table_gross
    	, n                       => g_rcvtxn_detail_index
    	, temp_cascaded_table     => l_rcvtxn_match_table_detail
    	, p_receipt_num           => p_receipt_num
    	, p_match_type            => 'ASN'
    	, p_lpn_id                => NULL
    	);
     else
    	inv_rcv_txn_match.matching_logic(
      	x_return_status         => x_status  --?
    	, x_msg_count             => l_msg_count
    	, x_msg_data              => x_message
    	, x_cascaded_table        => g_rcvtxn_match_table_gross
    	, n                       => g_rcvtxn_detail_index
    	, temp_cascaded_table     => l_rcvtxn_match_table_detail
    	, p_receipt_num           => p_receipt_num
    	, p_match_type            => 'INTRANSIT SHIPMENT'
    	, p_lpn_id                => NULL
    	);


    -- x_status is not successful if there is any execution error in matching.
     IF x_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('Exiting create_int_shp_rcvtxn_intf_rec 20:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RETURN;
     END IF;

    END IF;

    IF g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_status = 'E' THEN
      x_status := fnd_api.g_ret_sts_error;
      l_err_message := g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('exiting create_int_shp_rcvtxn_intf_rec 30:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RETURN;
    END IF;

    l_err_message := '@@@';

    FOR i IN g_rcvtxn_detail_index ..(g_rcvtxn_detail_index + l_rcvtxn_match_table_detail.COUNT - 1) LOOP
      IF l_rcvtxn_match_table_detail(i - g_rcvtxn_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcvtxn_match_table_detail(i - g_rcvtxn_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('adding tolerance message create_int_shp_rcvtxn_intf_rec 40:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    l_progress := '50';
    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI

    l_progress := '60';

    IF (l_debug = 1) THEN
      print_debug('create_int_shp_rcvtxn_intf_rec no recs matched by matching 50:' || l_rcvtxn_match_table_detail.COUNT, 4);
    END IF;

    -- loop through results returned by matching algorithm
    FOR match_result_count IN 1 .. l_rcvtxn_match_table_detail.COUNT LOOP
      IF (l_debug = 1) THEN
        print_debug('create_int_shp_rcvtxn_intf_rec found a match 60', 4);
        print_debug('Matching returned values 60.1 - shipment_line_id:' || l_rcvtxn_match_table_detail(match_result_count).shipment_line_id, 4);
        print_debug('Matching returned values 60.1 - rcv_transaction_id:' || l_rcvtxn_match_table_detail(match_result_count).parent_transaction_id, 4);
        print_debug('Matching returned values 60.1 - transaction_quantity:' || l_rcvtxn_match_table_detail(match_result_count).quantity, 4);
        print_debug('Matching returned values 60.1 - transaction_uom:' || l_rcvtxn_match_table_detail(match_result_count).unit_of_measure, 4);
        print_debug('Matching returned values 60.1 - primary_quantity:' || l_rcvtxn_match_table_detail(match_result_count).primary_quantity, 4);
        print_debug('Matching returned values 60.1 - primary_uom:' || l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure, 4);
	 print_debug('Matching returned values 60.1 - po_distribution_id : '||l_rcvtxn_match_table_detail(match_result_count).po_distribution_id,4);
      END IF;

      OPEN l_curs_rcvtxn_detail(
            l_rcvtxn_match_table_detail(match_result_count).shipment_line_id
          , l_rcvtxn_match_table_detail(match_result_count).parent_transaction_id);
      FETCH l_curs_rcvtxn_detail INTO l_rcv_rcvtxn_rec;
      CLOSE l_curs_rcvtxn_detail;
      -- update following fields from matching algorithm return value
      -- Bug No 1823328 Changes
      l_rcv_transaction_rec.shipment_line_id := l_rcvtxn_match_table_detail(match_result_count).shipment_line_id;
      --

      --R12: create RTI with uom entered by user
      l_prim_uom_code := inv_rcv_cache.get_primary_uom_code(p_organization_id,p_item_id);

      IF (p_rcvtxn_uom_code IS NULL) THEN
	 SELECT   uom_code
	   INTO   l_rcvtxn_uom_code
	   FROM   mtl_item_uoms_view
	   WHERE  organization_id = p_organization_id
	   AND    inventory_item_id = p_item_id
	   AND    unit_of_measure = p_rcvtxn_uom
	   AND    ROWNUM < 2;
       ELSE
	 l_rcvtxn_uom_code := p_rcvtxn_uom_code;
      END IF;

      IF (l_rcvtxn_uom_code <> l_prim_uom_code) THEN
	 l_rcv_transaction_rec.transaction_quantity := inv_rcv_cache.Convert_qty
	   (p_inventory_item_id => p_item_id
	    ,p_from_qty         => l_rcvtxn_match_table_detail(match_result_count).primary_quantity
	    ,p_from_uom_code    => l_prim_uom_code
	    ,p_to_uom_code      => l_rcvtxn_uom_code);
	 l_rcv_transaction_rec.transaction_uom := p_rcvtxn_uom;
       ELSE
	 l_rcv_transaction_rec.transaction_quantity := l_rcvtxn_match_table_detail(match_result_count).primary_quantity;
	 l_rcv_transaction_rec.transaction_uom := l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('Matching returned values 60.1 - l_rcv_transaction_rec.transaction_quantity :' ||l_rcv_transaction_rec.transaction_quantity  , 4);
	 print_debug('Matching returned values 60.1 - l_rcv_transaction_rec.transaction_uom :' ||l_rcv_transaction_rec.transaction_uom, 4);
      END IF;
      --R12 END

      l_rcv_transaction_rec.primary_quantity := l_rcvtxn_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;

      -- Start Bug 13344122 change
      -- Passing the secondary quantity values entered by the user only when the matching logic returns one row
      -- i.e. one RTI record is created
      IF (l_rcvtxn_match_table_detail.COUNT = 1) THEN

           -- Start of Bug 13961952 changes
           -- p_secondary_uom can have the unit of measure or uom_code as its value
           BEGIN
               SELECT unit_of_measure,
                      uom_code
               INTO   l_rcv_transaction_rec.secondary_uom,
                      l_rcv_transaction_rec.secondary_uom_code
               FROM   MTL_UNITS_OF_MEASURE_VL
               WHERE  unit_of_measure = p_secondary_uom
                  OR  uom_code        = p_secondary_uom;

               l_rcv_transaction_rec.sec_transaction_quantity := p_sec_rcvtxn_qty;

           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   print_debug('Unit of measure does not exist', 4);
           END;
           -- End of Bug 13961952 changes

           IF (l_debug = 1) THEN
                print_debug('60.1 - p_sec_rcvtxn_qty : ' || p_sec_rcvtxn_qty, 4);
                print_debug('60.1 - p_secondary_uom : ' || p_secondary_uom, 4);
                print_debug('60.1 - secondary_uom : ' || l_rcv_transaction_rec.secondary_uom, 4); -- Bug 13961952
                print_debug('60.1 - secondary_uom_code : ' || l_rcv_transaction_rec.secondary_uom_code, 4); -- Bug 13961952
      	   END IF;

      END IF;
      -- End Bug 13344122 change

      l_progress := '70';

      if (l_asn_type = 'ASN') then
	l_rcv_transaction_rec.po_distribution_id := l_rcvtxn_match_table_detail(match_result_count).po_distribution_id;
      end if;



      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
	  (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
	 -- Added addition check for p_original_txn_temp_id: if it is null,
	 -- then simply insert RTI with the MMTT column as null
	 IF p_original_txn_temp_id IS NULL OR l_rcvtxn_match_table_detail.COUNT = 1 THEN
	    l_new_txn_temp_id := p_original_txn_temp_id;
	  ELSE --More than 1 result returned from matching logic
	    -- Call split mo
	    IF (l_debug = 1) THEN
	       print_debug('create_int_shp_rcvtxn_intf_rec calling split_mo',4);
	    END IF;

	    IF (l_orig_mol_id IS NULL) THEN
               BEGIN
		  SELECT move_order_line_id
		    INTO l_orig_mol_id
		    FROM mtl_material_transactions_temp
		    WHERE transaction_temp_id = p_original_txn_temp_id;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('create_int_shp_rcvtxn_intf_rec: Error retrieving MOL id',4);
		     END IF;
		     RAISE fnd_api.g_exc_error;
	       END;
	    END IF; --IF (l_orig_mol_id IS NULL) THEN

	    l_mo_splt_tb(1).prim_qty := l_rcv_transaction_rec.primary_quantity;
	    l_mo_splt_tb(1).line_id := NULL;

	    IF (l_debug = 1) THEN
	       print_debug('create_int_shp_rcvtxn_intf_rec: Calling split_mo',4);
	       print_debug('    (p_orig_mol_id ====> ' || l_orig_mol_id,4);
	       print_debug('    (p_mo_splt_tb.prim_qty ==> ' || l_mo_splt_tb(1).prim_qty,4);
	       print_debug('    (p_operation_type => ' || 'DELIVER',4);
	       print_debug('    (p_txn_header_id  => ' || p_original_txn_temp_id,4);
	    END IF;

	    inv_rcv_integration_apis.split_mo
	      (p_orig_mol_id => l_orig_mol_id,
	       p_mo_splt_tb => l_mo_splt_tb,
	       p_operation_type => 'DELIVER',
	       p_txn_header_id => p_original_txn_temp_id,
	       x_return_status => l_return_status,
	       x_msg_count => l_msg_count,
	       x_msg_data => x_message);

	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       RAISE fnd_api.g_exc_error;
	    END IF;
	    l_progress := '75';

            BEGIN
	       SELECT transaction_temp_id
		 INTO l_new_txn_temp_id
		 FROM mtl_material_transactions_temp
		 WHERE move_order_line_id = l_mo_splt_tb(1).line_id;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('create_int_shp_rcvtxn_intf_rec: Error retrieving new mmtt id',4);
		  END IF;
	    END;
	 END IF; --l_rcvtxn_match_table_detail.COUNT = 1

	 IF (l_debug = 1) THEN
	    print_debug('create_int_shp_rcvtxn_intf_rec RTI to be inserted with mmtt id: ' ||
			l_new_txn_temp_id || ' p_transaction_temp_id = ' ||
			p_transaction_temp_id,4);
	 END IF;
       ELSE -- If lower than J
	 l_new_txn_temp_id := p_original_txn_temp_id;
      END IF; -- End If (Patchset J)

      --dbms_output.put_line('Got a match');
      populate_default_values(
        p_rcv_transaction_rec      => l_rcv_transaction_rec
      , p_rcv_rcvtxn_rec           => l_rcv_rcvtxn_rec
      , p_organization_id          => p_organization_id
      , p_item_id                  => p_item_id
      , p_revision                 => p_revision
      , p_subinventory_code        => p_subinventory_code
      , p_locator_id               => p_locator_id
      , p_transaction_temp_id      => p_transaction_temp_id
      , p_lot_control_code         => p_lot_control_code
      , p_serial_control_code      => p_serial_control_code
      , p_original_txn_temp_id     => l_new_txn_temp_id
      , p_lpn_id                   => p_lpn_id
      , p_transfer_lpn_id          => p_transfer_lpn_id
      );
      l_progress := '80';

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_rcvtxn_intf_rec 125 - before update_rcv_serials_supply' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      /* FP-J Lot/Serial Support Enhancement
       * Populate the table to store the information of the RTIs created used for
       * splitting the lots and serials based on RTI quantity
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
          (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
        l_new_rti_info(match_result_count).orig_interface_trx_id := p_transaction_temp_id;
        l_new_rti_info(match_result_count).new_interface_trx_id := g_interface_transaction_id;
        l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_quantity;
        IF (l_debug = 1) THEN
          print_debug('create_int_shp_rcvtxn_intf_rec 126.5 - Populated the table for lot/serial split', 4);
        END IF;
      END IF;   --END IF populate the table to store RTI info that was just created

      /* FP-J Lot/Serial Support Enhancement
       * No updates to rcv_serials_supply if INV J and PO J are installed
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
        (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN
        IF l_rcv_rcvtxn_rec.req_line_id IS NOT NULL
           AND p_serial_control_code NOT IN(1, 6) THEN
          -- update rss for req
          update_rcv_serials_supply(
            x_return_status        => l_return_status
          , x_msg_count            => l_msg_count
          , x_msg_data             => x_message
          , p_shipment_line_id     => l_rcv_rcvtxn_rec.shipment_line_id
          );
        END IF;

        IF (l_debug = 1) THEN
          print_debug('create_int_shp_rcvtxn_intf_rec: 127 - before update_rcv_serials_supply' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          print_debug('create_int_shp_rcvtxn_intf_rec: 127.6 - INV and PO patch levels are J or higher. No update to rcv_supply', 4);
        END IF;
      END IF;   --END IF check INV and PO patch levels
    END LOOP;

    --g_rcvtxn_detail_index := l_rcvtxn_match_table_detail.COUNT + g_rcvtxn_detail_index;

    IF l_curs_rcvtxn_detail%ISOPEN THEN
      CLOSE l_curs_rcvtxn_detail;
    END IF;

    /* FP-J Lot/Serial Support Enhancement
     * Call the split_lot API to split the lots and serials inserted from the UI
     * based on the quantity of each RTI record
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      l_msni_count := 0;
      IF (p_lot_control_code > 1 OR p_serial_control_code > 1) THEN
	      --BUG 3326408, 3405320
        --If there are any serials confirmed from the UI for an item that is
        --lot controlled and serial control dynamic at SO issue,
        --do not NULL out serial_transaction_temp_id. In other cases,
        --NULL OUT serial_temp_id so that split_lot_serial does not look at MSNI
	      IF (p_lot_control_code > 1 AND p_serial_control_code = 6) THEN
          BEGIN
            SELECT count(1)
            INTO   l_msni_count
            FROM   mtl_serial_numbers_interface
            WHERE  product_transaction_id = p_transaction_temp_id
            AND    product_code = 'RCV';

            IF (l_debug = 1) THEN
	            print_debug('create_int_shp_rcvtxn_intf_rec 127.7: serial_control_code IS 6, need TO NULL OUT mtli', 4);
	          END IF;
            IF l_msni_count <= 0 THEN
              UPDATE mtl_transaction_lots_interface
		          SET  serial_transaction_temp_id = NULL
		          WHERE product_transaction_id = p_transaction_temp_id
		          AND   product_code = 'RCV';
            END IF;
	        EXCEPTION
	          WHEN OTHERS THEN
		          IF (l_debug = 1) THEN
		            print_debug('create_int_shp_rcvtxn_intf_rec 127.8: Error nulling serial temp id OF MTLI', 4);
		          END IF;
	        END ;
	      END IF;--IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN

	      l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
                p_api_version   => 1.0
              , p_init_msg_lst  => FND_API.G_FALSE
              , x_return_status =>  l_return_status
              , x_msg_count     =>  l_msg_count
              , x_msg_data      =>  x_message
              , p_new_rti_info  =>  l_new_rti_info);
        IF ( NOT l_split_lot_serial_ok) THEN
          IF (l_debug = 1) THEN
            print_debug('create_int_shp_rcvtxn_intf_rec 128: Failure in split_lot_serial', 4);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_debug = 1) THEN
          print_debug('create_int_shp_rcvtxn_intf_rec 129: Call split_lot_serial is OK', 4);
        END IF;
      END IF;   --END IF check lot and serial control controls
    END IF;   --END IF check INV J and PO J installed

    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 61
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '100';

    IF (l_debug = 1) THEN
      print_debug('Exiting create_int_shp_rcvtxn_intf_rec:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcvtxn_detail%ISOPEN THEN
        CLOSE l_curs_rcvtxn_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_rcv_std_deliver_apis.create_int_shp_rcvtxn_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END create_int_shp_rcvtxn_intf_rec;

  PROCEDURE create_rma_rcvtxn_intf_rec(
    p_organization_id         IN          NUMBER
  , p_oe_order_header_id      IN          NUMBER
  , p_oe_order_line_id        IN          NUMBER
  , p_receipt_num             IN          VARCHAR2
  , p_item_id                 IN          NUMBER
  , p_customer_id             IN          NUMBER
  , p_revision                IN          VARCHAR2
  , p_subinventory_code       IN          VARCHAR2
  , p_locator_id              IN          NUMBER
  , p_rcvtxn_qty              IN          NUMBER
  , p_rcvtxn_uom              IN          VARCHAR2
  , p_transaction_temp_id     IN          NUMBER
  , p_lot_control_code        IN          NUMBER
  , p_serial_control_code     IN          NUMBER
  , p_original_txn_temp_id    IN          NUMBER   DEFAULT NULL
  , x_status                  OUT NOCOPY  VARCHAR2
  , x_message                 OUT NOCOPY  VARCHAR2
  , p_inspection_status_code  IN          VARCHAR2 DEFAULT NULL
  , p_lpn_id                  IN          NUMBER   DEFAULT NULL
  , p_transfer_lpn_id         IN          NUMBER   DEFAULT NULL
  , p_lot_number              IN          VARCHAR2 DEFAULT NULL
  , p_parent_txn_id           IN          NUMBER   DEFAULT NULL
  , p_sec_rcvtxn_qty          IN          NUMBER   DEFAULT NULL  --OPM Convergence
  , p_secondary_uom           IN          VARCHAR2   DEFAULT NULL --OPM Convergence
  , p_rcvtxn_uom_code         IN          VARCHAR2 DEFAULT NULL
  ) IS
    l_rcv_transaction_rec       rcvtxn_transaction_rec_tp;
    l_rcv_rcvtxn_rec            rcvtxn_enter_rec_cursor_rec;
    -- local record in which the values returned from the cursor are fetched.

    l_rcvtxn_match_table_detail inv_rcv_common_apis.cascaded_trans_tab_type;
    -- local variable to store the output of the matching algorithm

    l_msg_count                 NUMBER;
    l_return_status             VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_group_id                  NUMBER;
    l_transaction_type          VARCHAR2(20) := 'STD_DELIVER';
    l_total_primary_qty         NUMBER       := 0;
    l_asn_type                  VARCHAR2(25);
    l_source_type               VARCHAR2(80);
    l_source_code               VARCHAR2(30);
    l_err_message               VARCHAR2(100);
    l_temp_message              VARCHAR2(100);
    l_msg_prod                  VARCHAR2(5);
    l_progress                  VARCHAR2(10);
    l_orig_mol_id               NUMBER        := NULL;
    l_new_txn_temp_id           NUMBER;
    l_mo_splt_tb                inv_rcv_integration_apis.mo_in_tb_tp;

    CURSOR l_curs_rcvtxn_detail(v_order_line_id NUMBER
    													, v_rcv_txn_id NUMBER) IS
      SELECT   rsup.from_organization_id from_organization_id
             , rsup.to_organization_id to_organization_id
             , rt.source_document_code source_document_code
             , rsh.receipt_source_code receipt_source_code
             , rsup.rcv_transaction_id rcv_transaction_id
             , rt.transaction_date transaction_date
             , rt.transaction_type transaction_type
             , rt.primary_unit_of_measure primary_uom
             , rt.primary_quantity primary_quantity
             , rsup.po_header_id po_header_id
             , rt.po_revision_num po_revision_num
             , rsup.po_release_id po_release_id
             , rsh.vendor_id vendor_id
             , rt.vendor_site_id vendor_site_id
             , rsup.po_line_id po_line_id
             , rt.po_unit_price po_unit_price
             , rsl.category_id category_id
             , rsup.item_id item_id
             , msi.serial_number_control_code serial_number_control_code
             , msi.lot_control_code lot_control_code
             , rsup.item_revision item_revision
             , rsup.po_line_location_id po_line_location_id
             , rt.po_distribution_id po_distribution_id
             , rt.employee_id employee_id
             , rsl.comments comments
             , rsup.req_header_id req_header_id
             , rsup.req_line_id req_line_id
             , rsup.shipment_header_id shipment_header_id
             , rsup.shipment_line_id shipment_line_id
             , rsh.packing_slip packing_slip
             , rsl.government_context government_context
             , rsl.ussgl_transaction_code ussgl_transaction_code
             , rt.inspection_status_code inspection_status_code
             , rt.inspection_quality_code inspection_quality_code
             , rt.vendor_lot_num vendor_lot_num
             , '' vendor_item_number
             , rt.substitute_unordered_code substitute_unordered_code
             , rt.routing_header_id routing_id
             , rt.routing_step_id routing_step_id
             , rt.reason_id reason_id
             , rt.currency_code currency_code
             , rt.currency_conversion_rate currency_conversion_rate
             , rt.currency_conversion_date currency_conversion_date
             , rt.currency_conversion_type currency_conversion_type
             , rsl.req_distribution_id req_distribution_id
             , rsup.destination_type_code destination_type_code_hold
             , rsup.destination_type_code final_destination_type_code
             , rt.location_id location_id
             , rsl.deliver_to_person_id final_deliver_to_person_id
             , rsl.deliver_to_location_id final_deliver_to_location_id
             , rsl.to_subinventory subinventory
             , msi.un_number_id un_number_id
             , msi.hazard_class_id hazard_class_id
             , rsup.creation_date creation_date
             , rt.attribute_category attribute_category
             , rt.attribute1 attribute1
             , rt.attribute2 attribute2
             , rt.attribute3 attribute3
             , rt.attribute4 attribute4
             , rt.attribute5 attribute5
             , rt.attribute6 attribute6
             , rt.attribute7 attribute7
             , rt.attribute8 attribute8
             , rt.attribute9 attribute9
             , rt.attribute10 attribute10
             , rt.attribute11 attribute11
             , rt.attribute12 attribute12
             , rt.attribute13 attribute13
             , rt.attribute14 attribute14
             , rt.attribute15 attribute15
             , rt.qa_collection_id qa_collection_id
             , rsup.oe_order_header_id oe_order_header_id
             , rt.oe_order_line_id oe_order_line_id
             , rsh.customer_id customer_id
             , rsh.customer_site_id customer_site_id
             , NULL wip_entity_id
             , NULL po_operation_seq_num
             , NULL po_resource_seq_num
             , NULL wip_repetitive_schedule_id
             , NULL wip_line_id
             , NULL bom_resource_id
             , NULL final_subinventory
             , rt.SECONDARY_QUANTITY --OPM Convergence
             , rt.SECONDARY_UNIT_OF_MEASURE --OPM Convergence
	     --The following columns are needed for matching in cases where no LPN is involved
             , rsup.to_subinventory              from_subinventory_code
	     , rsup.to_locator_id                from_locator_id
      FROM     rcv_transactions rt
      			 , rcv_supply rsup
      			 , rcv_shipment_headers rsh
      			 , rcv_shipment_lines rsl
      			 , mtl_system_items msi
      WHERE    rsup.rcv_transaction_id = v_rcv_txn_id
      AND      rsup.oe_order_line_id = v_order_line_id
      AND      rsup.to_organization_id = p_organization_id
      AND      rsl.shipment_line_id = rsup.shipment_line_id
      AND      rt.transaction_id = rsup.rcv_transaction_id
      AND      rsh.shipment_header_id = rsup.shipment_header_id
      AND      msi.organization_id = rsup.to_organization_id
      AND      msi.inventory_item_id = rsup.item_id
      ORDER BY rt.transaction_date DESC;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok     BOOLEAN;   --Return status of lot_serial_split API
    l_prim_uom_code           VARCHAR2(3);
    l_rcvtxn_uom_code         VARCHAR2(3);
  BEGIN
    x_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Entering create_rma_rcvtxn_intf_rec:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';

    BEGIN
      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE;
    END;

    l_progress := '20';

    -- default l_group_id ?? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
      INTO   l_group_id
      FROM   DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    END IF;

    l_progress := '30';
    -- call matching algorithm
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).GROUP_ID := l_group_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).transaction_type := l_transaction_type;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).quantity := p_rcvtxn_qty;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).unit_of_measure := p_rcvtxn_uom;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).item_id := p_item_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).revision := p_revision; -- 2252193
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).oe_order_header_id := p_oe_order_header_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).oe_order_line_id := p_oe_order_line_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).to_organization_id := p_organization_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).customer_id := p_customer_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).p_lpn_id := p_lpn_id;
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).expected_receipt_date := SYSDATE; --?
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).tax_amount := 0; -- ?
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_status := 'S'; -- ?
    g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).inspection_status_code := p_inspection_status_code;

    /* FP-J Lot/Serial Support Enhancement
     * If INV and PO J are installed, then the lots for the parent transaction will
     * be stored in rcv_lots_supply. We must match the lot number passed with that
     * of the parent transaction and also the parent_txn_id
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
          (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).lot_number := p_lot_number;
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).parent_transaction_id := p_parent_txn_id;
    ELSE
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).lot_number := NULL;
      g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).parent_transaction_id := NULL;
    END IF;

    BEGIN
      SELECT primary_unit_of_measure
      INTO   g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).primary_unit_of_measure
      FROM   mtl_system_items
      WHERE  mtl_system_items.inventory_item_id = p_item_id
      AND    mtl_system_items.organization_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    l_progress := '40';

    IF (l_debug = 1) THEN
      print_debug('Parameters to matching logic 40', 4);
      print_debug('40.1 quantity ' || g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).quantity, 4);
      print_debug('40.2 item_id ' || g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).item_id, 4);
      print_debug('40.3 oe_order_header_id ' || g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).oe_order_header_id, 4);
      print_debug('40.4 oe_order_line_id ' || g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).oe_order_line_id, 4);
      print_debug('40.5 to_organization_id ' || g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).to_organization_id, 4);
      print_debug('40.6 customer_id ' || g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).customer_id, 4);
      print_debug('40.6 n ' || g_rcvtxn_detail_index, 4);
    END IF;

    inv_rcv_txn_match.matching_logic(
      x_return_status         => x_status
    , --?
      x_msg_count             => l_msg_count
    , x_msg_data              => x_message
    , x_cascaded_table        => g_rcvtxn_match_table_gross
    , n                       => g_rcvtxn_detail_index
    , temp_cascaded_table     => l_rcvtxn_match_table_detail
    , p_receipt_num           => p_receipt_num
    , p_match_type            => 'RMA'
    , p_lpn_id                => NULL
    );

    -- x_status is not successful if there is any execution error in matching.
    IF x_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('Exiting create_rma_rcvtxn_intf_rec 20:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RETURN;
    END IF;

    IF g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_status = 'E' THEN
      x_status := fnd_api.g_ret_sts_error;
      l_err_message := g_rcvtxn_match_table_gross(g_rcvtxn_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('exiting create_rma_rcvtxn_intf_rec 30:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RETURN;
    END IF;

    l_err_message := '@@@';

    FOR i IN g_rcvtxn_detail_index ..(g_rcvtxn_detail_index + l_rcvtxn_match_table_detail.COUNT - 1) LOOP
      IF l_rcvtxn_match_table_detail(i - g_rcvtxn_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcvtxn_match_table_detail(i - g_rcvtxn_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('adding tolerance message create_rma_rcvtxn_intf_rec 40:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    l_progress := '50';
    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI

    l_progress := '60';

    IF (l_debug = 1) THEN
      print_debug('create_rma_rcvtxn_intf_rec no recs matched by matching 50:' || l_rcvtxn_match_table_detail.COUNT, 4);
    END IF;

    -- loop through results returned by matching algorithm
    FOR match_result_count IN 1 .. l_rcvtxn_match_table_detail.COUNT LOOP
      IF (l_debug = 1) THEN
        print_debug('create_rma_rcvtxn_intf_rec found a match 60', 4);
        print_debug('Matching returned values 60.1 - oe_order_line_id:' || l_rcvtxn_match_table_detail(match_result_count).oe_order_line_id, 4);
        print_debug('Matching returned values 60.1 - rcv_transaction_id:' || l_rcvtxn_match_table_detail(match_result_count).parent_transaction_id, 4);
        print_debug('Matching returned values 60.1 - transaction_quantity:' || l_rcvtxn_match_table_detail(match_result_count).quantity, 4);
        print_debug('Matching returned values 60.1 - transaction_uom:' || l_rcvtxn_match_table_detail(match_result_count).unit_of_measure, 4);
        print_debug('Matching returned values 60.1 - primary_quantity:' || l_rcvtxn_match_table_detail(match_result_count).primary_quantity, 4);
        print_debug('Matching returned values 60.1 - primary_uom:' || l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure, 4);
      END IF;

      OPEN l_curs_rcvtxn_detail(
            l_rcvtxn_match_table_detail(match_result_count).oe_order_line_id
          , l_rcvtxn_match_table_detail(match_result_count).parent_transaction_id);
      FETCH l_curs_rcvtxn_detail INTO l_rcv_rcvtxn_rec;
      CLOSE l_curs_rcvtxn_detail;
      -- update following fields from matching algorithm return value
      -- Bug No 1823328 Changes
      l_rcv_transaction_rec.oe_order_line_id := l_rcvtxn_match_table_detail(match_result_count).oe_order_line_id;
      --

      --R12: create RTI with uom entered by user
      l_prim_uom_code := inv_rcv_cache.get_primary_uom_code(p_organization_id,p_item_id);

      IF (p_rcvtxn_uom_code IS NULL) THEN
	 SELECT   uom_code
	   INTO   l_rcvtxn_uom_code
	   FROM   mtl_item_uoms_view
	   WHERE  organization_id = p_organization_id
	   AND    inventory_item_id = p_item_id
	   AND    unit_of_measure = p_rcvtxn_uom
	   AND    ROWNUM < 2;
       ELSE
	 l_rcvtxn_uom_code := p_rcvtxn_uom_code;
      END IF;

      IF (l_rcvtxn_uom_code <> l_prim_uom_code) THEN
	 l_rcv_transaction_rec.transaction_quantity := inv_rcv_cache.Convert_qty
	   (p_inventory_item_id => p_item_id
	    ,p_from_qty         => l_rcvtxn_match_table_detail(match_result_count).primary_quantity
	    ,p_from_uom_code    => l_prim_uom_code
	    ,p_to_uom_code      => l_rcvtxn_uom_code);
	 l_rcv_transaction_rec.transaction_uom := p_rcvtxn_uom;
       ELSE
	 l_rcv_transaction_rec.transaction_quantity := l_rcvtxn_match_table_detail(match_result_count).primary_quantity;
	 l_rcv_transaction_rec.transaction_uom := l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('Matching returned values 60.1 - l_rcv_transaction_rec.transaction_quantity :' ||l_rcv_transaction_rec.transaction_quantity  , 4);
	 print_debug('Matching returned values 60.1 - l_rcv_transaction_rec.transaction_uom :' ||l_rcv_transaction_rec.transaction_uom, 4);
      END IF;
      --R12 END

      l_rcv_transaction_rec.primary_quantity := l_rcvtxn_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcvtxn_match_table_detail(match_result_count).primary_unit_of_measure;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;

      -- Start Bug 10161177 change
      -- Passing the secondary quantity values entered by the user only when the
      -- matching logic returns 1 row i.e. one RTI record is created

      IF (l_rcvtxn_match_table_detail.COUNT = 1) THEN

      	IF (l_debug = 1) THEN
      		print_debug('60.1 - p_sec_rcvtxn_qty : ' || p_sec_rcvtxn_qty, 4);
      		print_debug('60.1 - p_secondary_uom : ' || p_secondary_uom, 4);
      	END IF;

      	l_rcv_transaction_rec.sec_transaction_quantity := p_sec_rcvtxn_qty;
      	l_rcv_transaction_rec.secondary_uom_code := p_secondary_uom;

      END IF;
      -- End Bug 10161177 change

      l_progress := '70';

      -- Only call split mo if J or higher
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
	  (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
	 -- Added addition check for p_original_txn_temp_id: if it is null,
	 -- then simply insert RTI with the MMTT column as null
	 IF p_original_txn_temp_id IS NULL OR l_rcvtxn_match_table_detail.COUNT = 1 THEN
	    l_new_txn_temp_id := p_original_txn_temp_id;
	  ELSE --More than 1 result returned from matching logic
	    -- Call split mo
	    IF (l_debug = 1) THEN
	       print_debug('create_rma_rcvtxn_intf_rec calling split_mo',4);
	    END IF;

	    IF (l_orig_mol_id IS NULL) THEN
               BEGIN
		  SELECT move_order_line_id
		    INTO l_orig_mol_id
		    FROM mtl_material_transactions_temp
		    WHERE transaction_temp_id = p_original_txn_temp_id;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('create_rma_rcvtxn_intf_rec: Error retrieving MOL id',4);
		     END IF;
		     RAISE fnd_api.g_exc_error;
	       END;
	    END IF; --IF (l_orig_mol_id IS NULL) THEN

	    l_mo_splt_tb(1).prim_qty := l_rcv_transaction_rec.primary_quantity;
	    l_mo_splt_tb(1).line_id := NULL;

	    IF (l_debug = 1) THEN
	       print_debug('create_rma_rcvtxn_intf_rec: Calling split_mo',4);
	       print_debug('    (p_orig_mol_id ====> ' || l_orig_mol_id,4);
	       print_debug('    (p_mo_splt_tb.prim_qty ==> ' || l_mo_splt_tb(1).prim_qty,4);
	       print_debug('    (p_operation_type => ' || 'DELIVER',4);
	       print_debug('    (p_txn_header_id  => ' || p_original_txn_temp_id,4);
	    END IF;

	    inv_rcv_integration_apis.split_mo
	      (p_orig_mol_id => l_orig_mol_id,
	       p_mo_splt_tb => l_mo_splt_tb,
	       p_operation_type => 'DELIVER',
	       p_txn_header_id => p_original_txn_temp_id,
	       x_return_status => l_return_status,
	       x_msg_count => l_msg_count,
	       x_msg_data => x_message);

	    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	       RAISE fnd_api.g_exc_error;
	    END IF;
	    l_progress := '75';

            BEGIN
	       SELECT transaction_temp_id
		 INTO l_new_txn_temp_id
		 FROM mtl_material_transactions_temp
		 WHERE move_order_line_id = l_mo_splt_tb(1).line_id;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('create_rma_rcvtxn_intf_rec: Error retrieving new mmtt id',4);
		  END IF;
	    END;
	 END IF; --l_rcvtxn_match_table_detail.COUNT = 1
       ELSE -- If lower than J
	 l_new_txn_temp_id := p_original_txn_temp_id;
      END IF; -- IF Patchset J

      IF (l_debug = 1) THEN
	 print_debug('create_rma_rcvtxn_intf_rec RTI to be inserted with mmtt id: ' ||
		     l_new_txn_temp_id || ' p_transaction_temp_id = ' ||
		     p_transaction_temp_id,4);
      END IF;

      --dbms_output.put_line('Got a match');
      populate_default_values(
        p_rcv_transaction_rec      => l_rcv_transaction_rec
      , p_rcv_rcvtxn_rec           => l_rcv_rcvtxn_rec
      , p_organization_id          => p_organization_id
      , p_item_id                  => p_item_id
      , p_revision                 => p_revision
      , p_subinventory_code        => p_subinventory_code
      , p_locator_id               => p_locator_id
      , p_transaction_temp_id      => p_transaction_temp_id
      , p_lot_control_code         => p_lot_control_code
      , p_serial_control_code      => p_serial_control_code
      , p_original_txn_temp_id     => l_new_txn_temp_id
      , p_lpn_id                   => p_lpn_id
      , p_transfer_lpn_id          => p_transfer_lpn_id
      );

      l_progress := '80';

      /* FP-J Lot/Serial Support Enhancement
       * Populate the table to store the information of the RTIs created used for
       * splitting the lots and serials based on RTI quantity
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
          (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
        l_new_rti_info(match_result_count).orig_interface_trx_id := p_transaction_temp_id;
        l_new_rti_info(match_result_count).new_interface_trx_id := g_interface_transaction_id;
        l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_quantity;
        IF (l_debug = 1) THEN
          print_debug('create_rma_rcvtxn_intf_rec 64 - Populated the table for lot/serial split', 4);
        END IF;
      END IF;   --END IF populate the table to store RTI info that was just created
    END LOOP;

    --g_rcvtxn_detail_index := l_rcvtxn_match_table_detail.COUNT + g_rcvtxn_detail_index;
    IF l_curs_rcvtxn_detail%ISOPEN THEN
      CLOSE l_curs_rcvtxn_detail;
    END IF;

   /* FP-J Lot/Serial Support Enhancement
     * Call the split_lot API to split the lots and serials inserted from the UI
     * based on the quantity of each RTI record
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      IF (p_lot_control_code > 1 OR p_serial_control_code > 1) THEN

	 l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
                p_api_version   => 1.0
              , p_init_msg_lst  => FND_API.G_FALSE
              , x_return_status =>  l_return_status
              , x_msg_count     =>  l_msg_count
              , x_msg_data      =>  x_message
              , p_new_rti_info  =>  l_new_rti_info);
        IF ( NOT l_split_lot_serial_ok) THEN
          IF (l_debug = 1) THEN
            print_debug('create_rma_rcvtxn_intf_rec 65: Failure in split_lot_serial', 4);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_debug = 1) THEN
          print_debug('create_rma_rcvtxn_intf_rec 66: Call split_lot_serial is OK', 4);
        END IF;
      END IF;   --END IF check lot and serial controls
    END IF;   --END IF check INV J and PO J installed

    l_progress := '90';
    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 15
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '100';

    IF (l_debug = 1) THEN
      print_debug('Exiting create_rma_rcvtxn_intf_rec:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcvtxn_detail%ISOPEN THEN
        CLOSE l_curs_rcvtxn_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_rcv_std_deliver_apis.create_rma_rcvtxn_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END create_rma_rcvtxn_intf_rec;

  PROCEDURE create_rpt_num_rcvtxn_intf_rec(
    p_organization_id      IN         NUMBER
  , p_receipt_num          IN         VARCHAR2
  , p_shipment_header_id   IN         NUMBER
  , p_item_id              IN         NUMBER
  , p_source_id            IN         NUMBER
  , p_revision             IN         VARCHAR2
  , p_subinventory_code    IN         VARCHAR2
  , p_locator_id           IN         NUMBER
  , p_rcvtxn_qty           IN         NUMBER
  , p_rcvtxn_uom           IN         VARCHAR2
  , p_transaction_temp_id  IN         NUMBER
  , p_lot_control_code     IN         NUMBER
  , p_serial_control_code  IN         NUMBER
  , x_status               OUT NOCOPY VARCHAR2
  , x_message              OUT NOCOPY VARCHAR2
  , p_deliver_to_location_id IN       NUMBER DEFAULT NULL
  , p_sec_rcvtxn_qty          IN          NUMBER   DEFAULT NULL  --OPM Convergence
  , p_secondary_uom           IN          VARCHAR2   DEFAULT NULL --OPM Convergence
  , p_inspection_status_code IN       VARCHAR2 DEFAULT NULL --BUG 4309432
  ) IS
    l_po_header_id       NUMBER;
    l_oe_order_header_id NUMBER;
    l_progress           VARCHAR2(10);
    l_msg_count          NUMBER;

  --BUG 3444177: query against the base tables instead
  -- of using the view.
    CURSOR l_curs_rcvtxn_detail IS
       SELECT rsup.po_header_id po_header_id
	     ,rsup.oe_order_header_id oe_order_header_id
	 FROM rcv_shipment_headers rsh
	     ,rcv_supply rsup
	 WHERE rsh.receipt_num = p_receipt_num
	 AND   rsh.shipment_header_id = rsup.shipment_header_id
	 AND   rsup.to_organization_id = p_organization_id
	 AND   rsup.item_id = p_item_id;

    l_debug              NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    IF (l_debug = 1) THEN
      print_debug('create_rpt_num_rcvtxn_intf_rec: 10' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    OPEN l_curs_rcvtxn_detail;
    FETCH l_curs_rcvtxn_detail INTO l_po_header_id, l_oe_order_header_id;
    CLOSE l_curs_rcvtxn_detail;
    l_progress := '20';

    IF l_po_header_id IS NOT NULL THEN
      l_progress := '30';

      IF (l_debug = 1) THEN
        print_debug('create_rpt_num_rcvtxn_intf_rec: 20 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_po_rcvtxn_intf_rec(
        p_organization_id            => p_organization_id
      , p_po_header_id               => l_po_header_id
      , p_po_release_id              => NULL
      , p_po_line_id                 => NULL
      , p_po_line_location_id        => NULL
      , p_receipt_num                => p_receipt_num
      , p_item_id                    => p_item_id
      , p_vendor_id                  => p_source_id
      , p_revision                   => p_revision
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_rcvtxn_qty                 => p_rcvtxn_qty
      , p_rcvtxn_uom                 => p_rcvtxn_uom
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_lot_control_code           => p_lot_control_code
      , p_serial_control_code        => p_serial_control_code
      , x_status                     => x_status
      , x_message                    => x_message
      , p_inspection_status_code     => p_inspection_status_code --BUG 4309432
      , p_lpn_id                     => NULL
      , p_transfer_lpn_id            => NULL
      , p_lot_number                 => NULL
      , p_deliver_to_location_id     => p_deliver_to_location_id
	);

      IF x_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_rpt_num_rcvtxn_intf_rec 20.1: RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_rpt_num_rcvtxn_intf_rec 20.2: FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF l_oe_order_header_id IS NOT NULL THEN
      l_progress := '40';

      IF (l_debug = 1) THEN
        print_debug('create_rpt_num_rcvtxn_intf_rec: 30 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_rma_rcvtxn_intf_rec(
        p_organization_id            => p_organization_id
      , p_oe_order_header_id         => l_oe_order_header_id
      , p_oe_order_line_id           => NULL
      , p_receipt_num                => p_receipt_num
      , p_item_id                    => p_item_id
      , p_customer_id                => p_source_id
      , p_revision                   => p_revision
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_rcvtxn_qty                 => p_rcvtxn_qty
      , p_rcvtxn_uom                 => p_rcvtxn_uom
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_lot_control_code           => p_lot_control_code
      , p_serial_control_code        => p_serial_control_code
      , x_status                     => x_status
      , x_message                    => x_message
      , p_inspection_status_code     => NULL
      , p_lpn_id                     => NULL
      , p_transfer_lpn_id            => NULL
      , p_lot_number                 => NULL
      );

      IF x_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_rpt_num_rcvtxn_intf_rec 30.1: RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_rpt_num_rcvtxn_intf_rec 30.2: FND_API.G_EXC_UNEXPECTED_ERROR;'|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE
      l_progress := '50';

      IF (l_debug = 1) THEN
        print_debug('create_rpt_num_rcvtxn_intf_rec: 40 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_int_shp_rcvtxn_intf_rec(
        p_organization_id            => p_organization_id
      , p_shipment_header_id         => p_shipment_header_id
      , p_shipment_line_id           => NULL
      , p_receipt_num                => p_receipt_num
      , p_item_id                    => p_item_id
      , p_source_id                  => p_source_id
      , p_revision                   => p_revision
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_rcvtxn_qty                 => p_rcvtxn_qty
      , p_rcvtxn_uom                 => p_rcvtxn_uom
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_lot_control_code           => p_lot_control_code
      , p_serial_control_code        => p_serial_control_code
      , x_status                     => x_status
      , x_message                    => x_message
      , p_inspection_status_code     => NULL
      , p_lpn_id                     => NULL
      , p_transfer_lpn_id            => NULL
      , p_lot_number                 => NULL
      );

      IF x_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_rpt_num_rcvtxn_intf_rec 40.1: RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_rpt_num_rcvtxn_intf_rec 40.2: FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    l_progress := '60';

    IF (l_debug = 1) THEN
      print_debug('create_rpt_num_rcvtxn_intf_rec exitting: 10' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcvtxn_detail%ISOPEN THEN
        CLOSE l_curs_rcvtxn_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcvtxn_detail%ISOPEN THEN
        CLOSE l_curs_rcvtxn_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcvtxn_detail%ISOPEN THEN
        CLOSE l_curs_rcvtxn_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_rcv_std_deliver_apis.create_rpt_num_rcvtxn_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END;

   PROCEDURE create_osp_std_rcvtxn_intf_rec(
    p_organization_id      IN             NUMBER
  , p_po_header_id         IN             NUMBER
  , p_po_release_id        IN             NUMBER
  , p_po_line_id           IN             NUMBER
  , p_po_distribution_id   IN             NUMBER
  , p_item_id              IN             NUMBER
  , p_vendor_id            IN             NUMBER
  , p_revision             IN             VARCHAR2
  , p_rcvtxn_qty           IN             NUMBER
  , p_rcvtxn_uom           IN             VARCHAR2
  , p_transaction_temp_id  IN             NUMBER
  , x_status               OUT NOCOPY     VARCHAR2
  , x_message              OUT NOCOPY     VARCHAR2
  , p_secondary_qty        IN             NUMBER DEFAULT NULL --OPM Convergence
  ) IS
    l_progress      VARCHAR2(10);
    l_msg_count     NUMBER;
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_data      VARCHAR2(400);
    l_label_status  VARCHAR2(500);
    l_txn_id_tbl    inv_label.transaction_id_rec_type;
    l_counter       NUMBER      := 0;

    CURSOR c_rti_txn_id IS
            /* Bug 2443163 */
      /* SELECT MIN(rti.interface_transaction_id) */
      SELECT   MAX(rti.interface_transaction_id)
      FROM     rcv_transactions_interface rti
      WHERE    rti.GROUP_ID = inv_rcv_common_apis.g_rcv_global_var.interface_group_id
      GROUP BY rti.lpn_id;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    IF (l_debug = 1) THEN
      print_debug('create_osp_std_rcvtxn_intf_rec: 10' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
       --BUG 3444177: User HOR for performance reasons
       SELECT TO_NUMBER(hoi.org_information1)
	 INTO   inv_rcv_common_apis.g_po_startup_value.sob_id
	 FROM hr_organization_information hoi
	 WHERE hoi.organization_id = p_organization_id
	 AND (hoi.org_information_context || '') = 'Accounting Information' ;
    END IF;

    l_progress := '20';
    -- first check if the transaction date satisfies the validation.
    inv_rcv_common_apis.validate_trx_date(
      p_trx_date            => SYSDATE
    , p_organization_id     => p_organization_id
    , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
    , x_return_status       => x_status
    , x_error_code          => x_message
    );

    IF x_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_progress := '30';

    IF p_po_header_id IS NOT NULL THEN
      l_progress := '40';

      IF (l_debug = 1) THEN
        print_debug('create_osp_std_rcvtxn_intf_rec: 20 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_osp_po_rcvtxn_intf_rec(
        p_organization_id            => p_organization_id
      , p_po_header_id               => p_po_header_id
      , p_po_release_id              => p_po_release_id
      , p_po_line_id                 => p_po_line_id
      , p_po_line_location_id        => NULL
      , p_po_distribution_id         => p_po_distribution_id
      , p_item_id                    => p_item_id
      , p_vendor_id                  => p_vendor_id
      , p_revision                   => p_revision
      , p_rcvtxn_qty                 => p_rcvtxn_qty
      , p_rcvtxn_uom                 => p_rcvtxn_uom
      , p_transaction_temp_id        => p_transaction_temp_id
      , x_status                     => x_status
      , x_message                    => x_message
      , p_inspection_status_code     => NULL
      );

      IF x_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_osp_std_rcvtxn_intf_rec 20.1:  create_osp_po_rcvtxn_intf_rec RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_osp_std_rcvtxn_intf_rec 20.2: create_osp_po_rcvtxn_intf_rec FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    l_progress := '80';

    IF (l_debug = 1) THEN
      print_debug('create_osp_std_rcvtxn_intf_rec exitting: 60' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    -- calling label printing API
    IF x_status <> fnd_api.g_ret_sts_error THEN
      IF (l_debug = 1) THEN
        print_debug('create_osp_std_rcpt_intf_rec: 8.1 before  inv_label.print_label ', 4);
      END IF;

      /* FP-J Lot/Serial Support Enhancement
       * If INV J and PO J are installed, do not call label printing API at this stage
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
          (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN
        l_counter := 1;
        OPEN c_rti_txn_id;

        LOOP
          FETCH c_rti_txn_id INTO l_txn_id_tbl(l_counter);
          EXIT WHEN c_rti_txn_id%NOTFOUND;
          l_counter := l_counter + 1;
        END LOOP;

        CLOSE c_rti_txn_id;
        inv_label.print_label(
          x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , x_msg_data               => l_msg_data
        , x_label_status           => l_label_status
        , p_api_version            => 1.0
        , p_print_mode             => 1
        , p_business_flow_code     => 3
        , p_transaction_id         => l_txn_id_tbl
        );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;
          x_status := 'W';

          IF (l_debug = 1) THEN
            print_debug('create_osp_std_rcpt_intf_rec 8.2: inv_label.print_label FAILED;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4);
          END IF;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          print_debug('INV J and PO J are installed. NO label printing from UI', 4);
        END IF;
      END IF;   --END IF check INV and PO patch levels
    END IF;   --END IF check ret status
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_rcv_std_deliver_apis.create_osp_std_rcvtxn_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END create_osp_std_rcvtxn_intf_rec;

  PROCEDURE create_std_rcvtxn_intf_rec(
    p_organization_id      IN             NUMBER
  , p_po_header_id         IN             NUMBER
  , p_po_release_id        IN             NUMBER
  , p_po_line_id           IN             NUMBER
  , p_shipment_header_id   IN             NUMBER
  , p_oe_order_header_id   IN             NUMBER
  , p_receipt_num          IN             VARCHAR2
  , p_item_id              IN             NUMBER
  , p_vendor_id            IN             NUMBER
  , p_revision             IN             VARCHAR2
  , p_subinventory_code    IN             VARCHAR2
  , p_locator_id           IN             NUMBER
  , p_rcvtxn_qty           IN             NUMBER
  , p_rcvtxn_uom           IN             VARCHAR2
  , p_transaction_temp_id  IN             NUMBER
  , p_lot_control_code     IN             NUMBER
  , p_serial_control_code  IN             NUMBER
  , x_status               OUT NOCOPY     VARCHAR2
  , x_message              OUT NOCOPY     VARCHAR2
  , p_deliver_to_location_id IN           NUMBER   DEFAULT NULL
  , p_sec_rcvtxn_qty       IN             NUMBER DEFAULT NULL --OPM Convergence
  , p_secondary_uom        IN             VARCHAR2 DEFAULT NULL --OPMConvergence
  , p_rcv_act_rjt_qty_type IN         NUMBER   DEFAULT NULL --BUG 4309432
  ) IS
    l_progress      VARCHAR2(10);
    l_msg_count     NUMBER;
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_data      VARCHAR2(400);
    l_label_status  VARCHAR2(500);
    l_txn_id_tbl    inv_label.transaction_id_rec_type;
    l_counter       NUMBER      := 0;
    l_inspection_status_code VARCHAR2(30);  --Bug 4309432

    CURSOR c_rti_txn_id IS
            /* Bug 2443163 */
      /* SELECT MIN(rti.interface_transaction_id) */
      SELECT   MAX(rti.interface_transaction_id)
      FROM     rcv_transactions_interface rti
      WHERE    rti.GROUP_ID = inv_rcv_common_apis.g_rcv_global_var.interface_group_id
      GROUP BY rti.lpn_id;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    IF (l_debug = 1) THEN
      print_debug('create_std_rcvtxn_intf_rec: 10' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('   p_rcv_act_rjt_qty_type => '||p_rcv_act_rjt_qty_type,1);
    END IF;

    IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
       --BUG 3444177: User HOR for performance reasons
       SELECT TO_NUMBER(hoi.org_information1)
	 INTO   inv_rcv_common_apis.g_po_startup_value.sob_id
	 FROM hr_organization_information hoi
	 WHERE hoi.organization_id = p_organization_id
	 AND (hoi.org_information_context || '') = 'Accounting Information' ;
    END IF;

    l_progress := '20';
    -- first check if the transaction date satisfies the validation.
    inv_rcv_common_apis.validate_trx_date(
      p_trx_date            => SYSDATE
    , p_organization_id     => p_organization_id
    , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
    , x_return_status       => x_status
    , x_error_code          => x_message
    );

    IF x_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_progress := '30';

    --Bug 4309432, p_rcv_act_rjt_qty_type will be passed from the MSCA deliver page if
    --the routing is Inspection. Based on this value setting the l_inspection_status_code
    --which will be finally passed to matching_logic api to respective accepted qty or rejected qty.
    IF p_rcv_act_rjt_qty_type = 1 THEN
       l_inspection_status_code := 'ACCEPTED';
     ELSIF p_rcv_act_rjt_qty_type = 2 THEN
       l_inspection_status_code := NULL;
     ELSIF p_rcv_act_rjt_qty_type = 3 THEN
       l_inspection_status_code := 'REJECTED';
     ELSE
       l_inspection_status_code := NULL;
    END IF;

    IF (l_debug = 1) THEN
         print_debug('l_inspection_status_code: ' || l_inspection_status_code, 1);
    END IF;

    --Bug 11887570 The interface records should be created based on po header id only when the receipt num is null.
    --Otherwise the receipt num,item combination should find all the valid POs attached to the receipt to Match.
    IF p_po_header_id IS NOT NULL AND p_receipt_num IS NULL THEN
      l_progress := '40';

      IF (l_debug = 1) THEN
        print_debug('create_std_rcvtxn_intf_rec: 20 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_po_rcvtxn_intf_rec(
        p_organization_id            => p_organization_id
      , p_po_header_id               => p_po_header_id
      , p_po_release_id              => p_po_release_id
      , p_po_line_id                 => p_po_line_id
      , p_po_line_location_id        => NULL
      , p_receipt_num                => p_receipt_num -- bug 7243023
      , p_item_id                    => p_item_id
      , p_vendor_id                  => p_vendor_id
      , p_revision                   => p_revision
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_rcvtxn_qty                 => p_rcvtxn_qty
      , p_rcvtxn_uom                 => p_rcvtxn_uom
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_lot_control_code           => p_lot_control_code
      , p_serial_control_code        => p_serial_control_code
      , x_status                     => x_status
      , x_message                    => x_message
      , p_inspection_status_code     => l_inspection_status_code --BUG 4309432
      , p_lpn_id                     => NULL
      , p_transfer_lpn_id            => NULL
      , p_lot_number                 => NULL
      , p_deliver_to_location_id     => p_deliver_to_location_id
      , p_sec_rcvtxn_qty             => p_sec_rcvtxn_qty --OPM Convergence
      , p_secondary_uom              => p_secondary_uom --OPM Convergence
      );

      IF x_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 20.1:  create_po_rcvtxn_intf_rec RAISE FND_API.G_EXC_ERROR;'|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 20.2: create_po_rcvtxn_intf_rec FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_receipt_num IS NOT NULL THEN
      l_progress := '50';

      IF (l_debug = 1) THEN
        print_debug('create_std_rcvtxn_intf_rec: 30 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_rpt_num_rcvtxn_intf_rec(
        p_organization_id         => p_organization_id
      , p_receipt_num             => p_receipt_num
      , p_shipment_header_id      => p_shipment_header_id
      , p_item_id                 => p_item_id
      , p_source_id               => p_vendor_id
      , p_revision                => p_revision
      , p_subinventory_code       => p_subinventory_code
      , p_locator_id              => p_locator_id
      , p_rcvtxn_qty              => p_rcvtxn_qty
      , p_rcvtxn_uom              => p_rcvtxn_uom
      , p_transaction_temp_id     => p_transaction_temp_id
      , p_lot_control_code        => p_lot_control_code
      , p_serial_control_code     => p_serial_control_code
      , x_status                  => x_status
      , x_message                 => x_message
      , p_deliver_to_location_id  => p_deliver_to_location_id
      , p_sec_rcvtxn_qty             => p_sec_rcvtxn_qty --OPM Convergence
      , p_secondary_uom              => p_secondary_uom --OPM Convergence
      , p_inspection_status_code  => l_inspection_status_code  --Bug 4309432
      );

      IF x_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 30.1:  create_rpt_num_rcvtxn_intf_rec RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 30.2: create_rpt_num_rcvtxn_intf_rec FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_shipment_header_id IS NOT NULL THEN
      l_progress := '60';

      IF (l_debug = 1) THEN
        print_debug('create_std_rcvtxn_intf_rec: 40 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_int_shp_rcvtxn_intf_rec(
        p_organization_id            => p_organization_id
      , p_shipment_header_id         => p_shipment_header_id
      , p_shipment_line_id           => NULL
      , p_receipt_num                => NULL
      , p_item_id                    => p_item_id
      , p_source_id                  => p_vendor_id
      , p_revision                   => p_revision
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_rcvtxn_qty                 => p_rcvtxn_qty
      , p_rcvtxn_uom                 => p_rcvtxn_uom
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_lot_control_code           => p_lot_control_code
      , p_serial_control_code        => p_serial_control_code
      , x_status                     => x_status
      , x_message                    => x_message
      , p_inspection_status_code     => NULL
      , p_lpn_id                     => NULL
      , p_transfer_lpn_id            => NULL
      , p_lot_number                 => NULL
      , p_sec_rcvtxn_qty             => p_sec_rcvtxn_qty --OPM Convergence
      , p_secondary_uom              => p_secondary_uom --OPM Convergence
      );

      IF x_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 40.1:  create_int_shp_rcvtxn_intf_rec RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 40.2: create_int_shp_rcvtxn_intf_rec FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_oe_order_header_id IS NOT NULL THEN
      l_progress := '70';

      IF (l_debug = 1) THEN
        print_debug('create_std_rcvtxn_intf_rec: 50 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      create_rma_rcvtxn_intf_rec(
        p_organization_id            => p_organization_id
      , p_oe_order_header_id         => p_oe_order_header_id
      , p_oe_order_line_id           => NULL
      , p_receipt_num                => NULL
      , p_item_id                    => p_item_id
      , p_customer_id                => p_vendor_id
      , p_revision                   => p_revision
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_rcvtxn_qty                 => p_rcvtxn_qty
      , p_rcvtxn_uom                 => p_rcvtxn_uom
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_lot_control_code           => p_lot_control_code
      , p_serial_control_code        => p_serial_control_code
      , x_status                     => x_status
      , x_message                    => x_message
      , p_inspection_status_code     => NULL
      , p_lpn_id                     => NULL
      , p_transfer_lpn_id            => NULL
      , p_lot_number                 => NULL
      , p_sec_rcvtxn_qty             => p_sec_rcvtxn_qty --OPM Convergence
      , p_secondary_uom              => p_secondary_uom --OPM Convergence
      );

      IF x_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 50.1: create_rma_rcvtxn_intf_rec  RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 50.2: create_rma_rcvtxn_intf_rec  FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    l_progress := '80';

    IF (l_debug = 1) THEN
      print_debug('create_std_rcvtxn_intf_rec exitting: 60' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    -- calling label printing API
    IF x_status <> fnd_api.g_ret_sts_error THEN
      IF (l_debug = 1) THEN
        print_debug('create_std_rcpt_intf_rec: 8.1 before  inv_label.print_label ', 4);
      END IF;

      /* FP-J Lot/Serial Support Enhancement
       * If INV J and PO J are installed, do not call label printing API at this stage
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
          (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN
        l_counter := 1;
        OPEN c_rti_txn_id;

        LOOP
          FETCH c_rti_txn_id INTO l_txn_id_tbl(l_counter);
          EXIT WHEN c_rti_txn_id%NOTFOUND;
          l_counter := l_counter + 1;
        END LOOP;

        CLOSE c_rti_txn_id;
        inv_label.print_label(
          x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , x_msg_data               => l_msg_data
        , x_label_status           => l_label_status
        , p_api_version            => 1.0
        , p_print_mode             => 1
        , p_business_flow_code     => 3
        , p_transaction_id         => l_txn_id_tbl
        );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;
          x_status := 'W';

          IF (l_debug = 1) THEN
            print_debug('create_std_rcpt_intf_rec 8.2: inv_label.print_label FAILED;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          print_debug('INV J and PO J are installed. NO label printing from UI', 4);
        END IF;
      END IF;   --END IF check INV and PO patch levels
    END IF;   --END IF check ret status
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_rcv_std_deliver_apis.create_std_rcvtxn_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END create_std_rcvtxn_intf_rec;

  /* FP-J Lot/Serial Support Enhancement
   * Added two new parameters p_transfer_lpn_id and p_lot_number
   */
  PROCEDURE create_putaway_rcvtxn_intf_rec(
    p_organization_id         IN             NUMBER
  , p_reference_id            IN             NUMBER
  , p_reference               IN             VARCHAR2
  , p_reference_type_code     IN             NUMBER
  , p_item_id                 IN             NUMBER
  , p_revision                IN             VARCHAR2
  , p_subinventory_code       IN             VARCHAR2
  , p_locator_id              IN             NUMBER
  , p_rcvtxn_qty              IN             NUMBER
  , p_rcvtxn_uom_code         IN             VARCHAR2
  , p_transaction_temp_id     IN             NUMBER
  , p_lot_control_code        IN             NUMBER
  , p_serial_control_code     IN             NUMBER
  , p_original_txn_temp_id    IN             NUMBER
  , x_return_status           OUT NOCOPY     VARCHAR2
  , x_msg_count               OUT NOCOPY     VARCHAR2
  , x_msg_data                OUT NOCOPY     VARCHAR2
  , p_inspection_status_code  IN             NUMBER
  , p_lpn_id                  IN             NUMBER
  , p_transfer_lpn_id         IN             NUMBER   DEFAULT NULL
  , p_lot_number              IN             VARCHAR2 DEFAULT NULL
  , p_parent_txn_id           IN             NUMBER   DEFAULT NULL
  , p_secondary_quantity      IN             NUMBER DEFAULT NULL --OPM Convergence
  , p_secondary_uom           IN             VARCHAR2 DEFAULT NULL --OPM Convergence
  ) IS
    l_po_header_id        NUMBER;
    l_po_release_id       NUMBER;
    l_po_line_id          NUMBER;
    l_po_line_location_id NUMBER;
    l_shipment_header_id  NUMBER;
    l_oe_order_header_id  NUMBER;
    l_rcvtxn_uom          VARCHAR2(25);
    l_progress            VARCHAR2(10);
    l_return_status       VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(400);
    l_label_status        VARCHAR2(500);
    l_txn_id_tbl          inv_label.transaction_id_rec_type;
    l_counter             NUMBER       := 0;
    l_inspection_status   VARCHAR2(25);

    CURSOR c_rti_txn_id IS
      SELECT DISTINCT rti.interface_transaction_id
      FROM   rcv_transactions_interface rti
      WHERE  rti.GROUP_ID = inv_rcv_common_apis.g_rcv_global_var.interface_group_id;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    IF (l_debug = 1) THEN
      print_debug('create_putaway_rcvtxn_intf_rec: 10' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('  p_organization_id        =>'||p_organization_id,1);
      print_debug('  p_reference_id           =>'||p_reference_id,1);
      print_debug('  p_reference              =>'||p_reference,1);
      print_debug('  p_reference_type_code    =>'||p_reference_type_code,1);
      print_debug('  p_item_id                =>'||p_item_id,1);
      print_debug('  p_revision               =>'||p_revision,1);
      print_debug('  p_subinventory_code      =>'||p_subinventory_code,1);
      print_debug('  p_locator_id             =>'||p_locator_id,1);
      print_debug('  p_rcvtxn_qty             =>'||p_rcvtxn_qty,1);
      print_debug('  p_rcvtxn_uom_code        =>'||p_rcvtxn_uom_code,1);
      print_debug('  p_transaction_temp_id    =>'||p_transaction_temp_id,1);
      print_debug('  p_lot_control_code       =>'||p_lot_control_code,1);
      print_debug('  p_serial_control_code    =>'||p_serial_control_code,1);
      print_debug('  p_original_txn_temp_id   =>'||p_original_txn_temp_id,1);
      print_debug('  p_inspection_status_code =>'||p_inspection_status_code,1);
      print_debug('  p_lpn_id                 =>'||p_lpn_id,1);
      print_debug('  p_transfer_lpn_id        =>'||p_transfer_lpn_id,1);
      print_debug('  p_lot_number             =>'||p_lot_number,1);
      print_debug('  p_parent_txn_id          =>'||p_parent_txn_id,1);
      print_debug('  p_secondary_quantity     =>'||p_secondary_quantity,1);
      print_debug('  p_secondary_uom          =>'||p_secondary_uom,1);
    END IF;

    --First check if the transaction date satisfies the validation.
    --If the transaction date is invalid then error out the transaction
    IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
       --BUG 3444177: User HOR for performance reasons
       BEGIN
	  SELECT TO_NUMBER(hoi.org_information1)
	    INTO   inv_rcv_common_apis.g_po_startup_value.sob_id
	    FROM hr_organization_information hoi
	    WHERE hoi.organization_id = p_organization_id
	    AND (hoi.org_information_context || '') = 'Accounting Information' ;
       EXCEPTION
	  WHEN OTHERS THEN
	     IF (l_debug = 1) THEN
		print_debug('create_std_rcvtxn_intf_rec 10.1: Error retrieving hr info',1);
		print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||Sqlerrm,1);
	     END IF;
	     RAISE fnd_api.g_exc_error;
       END ;
    END IF;

    l_progress := '15';

    inv_rcv_common_apis.validate_trx_date(
      p_trx_date            => SYSDATE
    , p_organization_id     => p_organization_id
    , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
    , x_return_status       => x_return_status
    , x_error_code          => x_msg_data
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
       IF (l_debug = 1) THEN
	  print_debug('create_std_rcvtxn_intf_rec 10.2: validate_trx_date returned failure. x_error_code:'||x_msg_data,1);
       END IF;
       RETURN;
    END IF;


    --dbms_output.put_line('In create putaway move order');
    SELECT unit_of_measure
    INTO   l_rcvtxn_uom
    FROM   mtl_item_uoms_view
    WHERE  organization_id = p_organization_id
    AND    inventory_item_id = p_item_id
    AND    uom_code = p_rcvtxn_uom_code
    AND    ROWNUM < 2;

    IF p_inspection_status_code = 2 THEN
      l_inspection_status := 'ACCEPTED';
    ELSIF p_inspection_status_code = 3 THEN
      l_inspection_status := 'REJECTED';
    ELSE
      l_inspection_status := NULL;
    END IF;

    l_progress := '20';

    IF p_reference = 'PO_LINE_LOCATION_ID' THEN
       BEGIN
	  SELECT po_header_id
	    , po_line_id
	    , po_release_id
	    INTO   l_po_header_id
	    , l_po_line_id
	    , l_po_release_id
	    FROM   po_line_locations
	    WHERE  line_location_id = p_reference_id;
       EXCEPTION
	  WHEN OTHERS THEN
	     IF (l_debug = 1) THEN
		print_debug('create_std_rcvtxn_intf_rec 20: Error retrieving po info.',1);
		print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||Sqlerrm,1);
	     END IF;
	     RAISE fnd_api.g_exc_error;
       END;

      l_progress := '30';
      create_po_rcvtxn_intf_rec(
        p_organization_id            => p_organization_id
      , p_po_header_id               => l_po_header_id
      , p_po_release_id              => l_po_release_id
      , p_po_line_id                 => l_po_line_id
      , p_po_line_location_id        => p_reference_id
      , p_receipt_num                => NULL
      , p_item_id                    => p_item_id
      , p_vendor_id                  => NULL
      , p_revision                   => p_revision
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_rcvtxn_qty                 => p_rcvtxn_qty
      , p_rcvtxn_uom                 => l_rcvtxn_uom
      , p_rcvtxn_uom_code            => p_rcvtxn_uom_code
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_lot_control_code           => p_lot_control_code
      , p_serial_control_code        => p_serial_control_code
      , p_original_txn_temp_id       => p_original_txn_temp_id
      , x_status                     => x_return_status
      , x_message                    => x_msg_data
      , p_inspection_status_code     => l_inspection_status
      , p_lpn_id                     => p_lpn_id
      , p_transfer_lpn_id            => p_transfer_lpn_id
      , p_lot_number                 => p_lot_number
      , p_parent_txn_id              => p_parent_txn_id
	);

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 20.1:  create_po_rcvtxn_intf_rec RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 20.2: create_po_rcvtxn_intf_rec FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_reference = 'SHIPMENT_LINE_ID' THEN
      l_progress := '40';

      SELECT shipment_header_id
      INTO   l_shipment_header_id
      FROM   rcv_shipment_lines
      WHERE  shipment_line_id = p_reference_id;

      l_progress := '50';
      create_int_shp_rcvtxn_intf_rec(
        p_organization_id            => p_organization_id
      , p_shipment_header_id         => l_shipment_header_id
      , p_shipment_line_id           => p_reference_id
      , p_receipt_num                => NULL
      , p_item_id                    => p_item_id
      , p_source_id                  => NULL
      , p_revision                   => p_revision
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_rcvtxn_qty                 => p_rcvtxn_qty
      , p_rcvtxn_uom                 => l_rcvtxn_uom
      , p_rcvtxn_uom_code            => p_rcvtxn_uom_code
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_lot_control_code           => p_lot_control_code
      , p_serial_control_code        => p_serial_control_code
      , p_original_txn_temp_id       => p_original_txn_temp_id
      , x_status                     => x_return_status
      , x_message                    => x_msg_data
      , p_inspection_status_code     => l_inspection_status
      , p_lpn_id                     => p_lpn_id
      , p_transfer_lpn_id            => p_transfer_lpn_id
      , p_lot_number                 => p_lot_number
      , p_parent_txn_id              => p_parent_txn_id
      , p_sec_rcvtxn_qty             => p_secondary_quantity -- Bug 13344122
      , p_secondary_uom              => p_secondary_uom -- Bug 13344122
      );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 30.1:  create_int_shp_rcvtxn_intf_rec RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 30.2: create_int_shp_rcvtxn_intf_rec FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_reference = 'ORDER_LINE_ID' THEN
      l_progress := '60';

      SELECT header_id
      INTO   l_oe_order_header_id
      FROM   oe_order_lines_all
      WHERE  line_id = p_reference_id;

      l_progress := '70';
      create_rma_rcvtxn_intf_rec(
        p_organization_id            => p_organization_id
      , p_oe_order_header_id         => l_oe_order_header_id
      , p_oe_order_line_id           => p_reference_id
      , p_receipt_num                => NULL
      , p_item_id                    => p_item_id
      , p_customer_id                => NULL
      , p_revision                   => p_revision
      , p_subinventory_code          => p_subinventory_code
      , p_locator_id                 => p_locator_id
      , p_rcvtxn_qty                 => p_rcvtxn_qty
      , p_rcvtxn_uom                 => l_rcvtxn_uom
      , p_rcvtxn_uom_code            => p_rcvtxn_uom_code
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_lot_control_code           => p_lot_control_code
      , p_serial_control_code        => p_serial_control_code
      , p_original_txn_temp_id       => p_original_txn_temp_id
      , x_status                     => x_return_status
      , x_message                    => x_msg_data
      , p_inspection_status_code     => l_inspection_status
      , p_lpn_id                     => p_lpn_id
      , p_transfer_lpn_id            => p_transfer_lpn_id
      , p_lot_number                 => p_lot_number
      , p_parent_txn_id              => p_parent_txn_id
      , p_sec_rcvtxn_qty             => p_secondary_quantity -- Bug 10161177
      , p_secondary_uom              => p_secondary_uom -- Bug 10161177
      );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 40.1: create_rma_rcvtxn_intf_rec  RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_std_rcvtxn_intf_rec 40.2: create_rma_rcvtxn_intf_rec  FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    l_progress := '80';

    IF (l_debug = 1) THEN
      print_debug('create_rma_rcvtxn_intf_rec exitting: 90' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    IF x_return_status <> fnd_api.g_ret_sts_error THEN
      IF (l_debug = 1) THEN
        print_debug('create_std_rcpt_intf_rec: 8.1 before  inv_label.print_label ', 4);
      END IF;

      /* FP-J Lot/Serial Support Enhancement
       * If INV J and PO J are installed, do not call label printing API at this stage
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
          (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN
        OPEN c_rti_txn_id;

        LOOP
          l_counter := 1;
          FETCH c_rti_txn_id INTO l_txn_id_tbl(l_counter);
          EXIT WHEN c_rti_txn_id%NOTFOUND;
          l_counter := l_counter + 1;
        END LOOP;

        CLOSE c_rti_txn_id;
        /* Start of Change.
           Earlier this call to label printing was commented out but was called for p_business_flow_code = 1
           Changed the p_business_flow_code = 4 (PutAway Drop) and uncommented this call to label printing for Bug 2151280.
        */
        inv_label.print_label(
          x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , x_msg_data               => l_msg_data
        , x_label_status           => l_label_status
        , p_api_version            => 1.0
        , p_print_mode             => 1
        , p_business_flow_code     => 4
        , p_transaction_id         => l_txn_id_tbl
        );

        /*  End of Change */
        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;
          x_return_status := 'W';
          IF (l_debug = 1) THEN
            print_debug('create_std_rcpt_intf_rec 8.2: inv_label.print_label FAILED;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          print_debug('INV J and PO J are installed. NO label printing from UI', 4);
        END IF;
      END IF;   --END IF check INV and PO patch levels
    END IF;   --END IF check ret status
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      IF (l_debug = 1) THEN
	 print_debug('create_std_rcpt_intf_rec: g_exc_error thrown at progress '||l_progress,4);
      END IF;
     WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      IF (l_debug = 1) THEN
	 print_debug('create_std_rcpt_intf_rec: g_exc_unexpected_error thrown at progress '||l_progress,4);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
	 print_debug('create_std_rcpt_intf_rec: others exception thrown at progress '||l_progress,4);
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_rcv_std_deliver_apis.create_std_rcvtxn_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END create_putaway_rcvtxn_intf_rec;

  PROCEDURE rcvtxn_clear_global IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    g_rcvtxn_detail_index := 1;
    inv_rcv_common_apis.g_po_startup_value := NULL;
    inv_rcv_common_apis.g_rcv_global_var := NULL;
    g_rcvtxn_match_table_gross.DELETE;
  END rcvtxn_clear_global;

  PROCEDURE update_rcv_serials_supply(
    x_return_status     OUT  NOCOPY VARCHAR2
  , x_msg_count         OUT  NOCOPY NUMBER
  , x_msg_data          OUT  NOCOPY VARCHAR2
  , p_shipment_line_id  IN          NUMBER
  ) IS
    l_progress      VARCHAR2(10);
    l_serial_number VARCHAR2(30);
    l_debug         NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Enter update_rcv_serials_supply 10' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('p_shipment_line_id => ' || p_shipment_line_id || '  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('p_serial_number => ' || l_serial_number || '  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    l_progress := '10';
    SAVEPOINT sp_update_rss;

    SELECT rsi.fm_serial_num
    INTO   l_serial_number
    FROM   rcv_serials_interface rsi, rcv_transactions_interface rti
    WHERE  rti.shipment_line_id = p_shipment_line_id
    AND    rti.interface_transaction_id = rsi.interface_transaction_id;

    IF (l_debug = 1) THEN
      print_debug('p_serial_number => ' || l_serial_number || '  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    l_progress := '15';

    UPDATE rcv_serials_supply
    SET shipment_line_id = (SELECT shipment_line_id
                            FROM   rcv_serials_supply
                            WHERE  serial_num = l_serial_number)
    WHERE  shipment_line_id = p_shipment_line_id;

    l_progress := '20';

    UPDATE rcv_serials_supply
    SET shipment_line_id = p_shipment_line_id
    WHERE  serial_num = l_serial_number;

    l_progress := '30';

    IF (l_debug = 1) THEN
      print_debug('Complete update_rcv_serials_supply 40' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_rcv_std_deliver_apis.update_rcv_serials_supply', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('Exception in update_rcv_serials_supply 50' || SQLCODE || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END update_rcv_serials_supply;

  FUNCTION insert_mtli_helper(
          p_txn_if_id       IN OUT NOCOPY NUMBER
        , p_lot_number      IN            VARCHAR2
        , p_txn_qty         IN            NUMBER
        , p_prm_qty         IN            NUMBER
        , p_item_id         IN            NUMBER
        , p_org_id          IN            NUMBER
        , p_serial_temp_id  IN            NUMBER
        , p_product_txn_id  IN            NUMBER
        , p_secondary_quantity IN NUMBER --OPM Convergence
        , p_secondary_uom   IN NUMBER --OPM Convergence
        ) RETURN BOOLEAN IS
    --Local variables
    l_lot_status_id         NUMBER;
    l_txn_if_id             NUMBER      :=  p_txn_if_id;
    l_product_txn_id        NUMBER      :=  p_product_txn_id;
    l_expiration_date       DATE;
    l_prod_code             VARCHAR2(5) := inv_rcv_integration_apis.G_PROD_CODE;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(10000);
    l_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    --Get the required columns from MLN first
    SELECT  expiration_date
          , status_id
    INTO    l_expiration_date
          , l_lot_status_id
    FROM    mtl_lot_numbers
    WHERE   lot_number = p_lot_number
    AND     inventory_item_id = p_item_id
    AND     organization_id = p_org_id;

    IF (l_txn_if_id IS NULL) THEN
       BEGIN
	  SELECT  mtl_material_transactions_s.NEXTVAL
	    INTO    l_txn_if_id
	    FROM    sys.dual;
       EXCEPTION
	  WHEN OTHERS THEN
	     IF (l_debug = 1) THEN
		print_debug('insert_mtli_helper: Error retrieving from seq.',1);
		print_debug('insert_mtli_helper: SQLCODE: '||SQLCODE||' SQLERRM:'||Sqlerrm,1);
	     END IF;
       END;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('insert_mtli_helper: l_txn_if_id: '||l_txn_if_id,1);
    END IF;

    --Call the insert_mtli API
    inv_rcv_integration_pvt.insert_mtli
      (p_product_transaction_id     => l_product_txn_id
       ,p_product_code              => l_prod_code
       ,p_interface_id              => l_txn_if_id
       ,p_org_id                    => p_org_id
       ,p_item_id                   => p_item_id
       ,p_lot_number                => p_lot_number
       ,p_transaction_quantity      => p_txn_qty
       ,p_primary_quantity          => p_prm_qty
       ,p_serial_interface_id       => p_serial_temp_id
       ,x_return_status             => l_return_status
       ,x_msg_count                 => l_msg_count
       ,x_msg_data                  => l_msg_data
       ,p_sec_qty                   => p_secondary_quantity
       );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
      IF (l_debug = 1) THEN
        print_debug('insert_mtli_helper: Error occurred while creating interface lots: ' || l_msg_data,1);
      END IF;
      RETURN FALSE;
    END IF;

    p_txn_if_id := l_txn_if_id;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        print_debug('Exception occurred in insert_mtli_helper: ',1);
      END IF;
      RETURN FALSE;
  END insert_mtli_helper;

  FUNCTION insert_msni_helper(
          p_txn_if_id       IN OUT NOCOPY NUMBER
        , p_serial_number   IN            VARCHAR2
        , p_item_id         IN            NUMBER
        , p_org_id          IN            NUMBER
        , p_product_txn_id  IN OUT NOCOPY NUMBER
       ) RETURN BOOLEAN IS
    --Local variables
    l_serial_status_id      NUMBER;
    l_txn_if_id             NUMBER      :=  p_txn_if_id;
    l_product_txn_id        NUMBER      :=  p_product_txn_id;
    l_prod_code             VARCHAR2(5) := inv_rcv_integration_apis.G_PROD_CODE;
    l_yes                   VARCHAR2(1) := inv_rcv_integration_apis.G_YES;
    l_no                    VARCHAR2(1) := inv_rcv_integration_apis.G_NO;
    l_false                 VARCHAR2(1) := inv_rcv_integration_apis.G_FALSE;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(10000);
    l_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN

    --Get the serial status
    SELECT  status_id
    INTO    l_serial_status_id
    FROM    mtl_serial_numbers
    WHERE   serial_number = p_serial_number
    AND     inventory_item_id = p_item_id;

    --Call the insert_msni API
    inv_rcv_integration_apis.insert_msni(
          p_api_version                 =>  1.0
        , p_init_msg_lst                =>  l_false
        , x_return_status               =>  l_return_status
        , x_msg_count                   =>  l_msg_count
        , x_msg_data                    =>  l_msg_data
        , p_transaction_interface_id    =>  l_txn_if_id
        , p_fm_serial_number            =>  p_serial_number
        , p_to_serial_number            =>  p_serial_number
        , p_organization_id             =>  p_org_id
        , p_inventory_item_id           =>  p_item_id
        , p_status_id                   =>  l_serial_status_id
        , p_product_transaction_id      =>  l_product_txn_id
        , p_product_code                =>  l_prod_code
        , p_att_exist                   =>  l_yes
        , p_update_msn                  =>  l_no);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
      IF (l_debug = 1) THEN
        print_debug('insert_msni_helper: Error occurred while creating interface serials: ' || l_msg_data,1);
      END IF;
      RETURN FALSE;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('insert_msni_helper: msni '||p_txn_if_id||' inserted for serial '||p_serial_number,1);
    END IF;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        print_debug('Exception occurred in insert_msni_helper: ',1);
      END IF;
      RETURN FALSE;
  END insert_msni_helper;

  PROCEDURE Match_putaway_rcvtxn_intf_rec(
    p_organization_id         IN             NUMBER
  , p_reference_id            IN             NUMBER
  , p_reference               IN             VARCHAR2
  , p_reference_type_code     IN             NUMBER
  , p_item_id                 IN             NUMBER
  , p_revision                IN             VARCHAR2
  , p_subinventory_code       IN             VARCHAR2
  , p_locator_id              IN             NUMBER
  , p_rcvtxn_qty              IN             NUMBER
  , p_rcvtxn_uom_code         IN             VARCHAR2
  , p_transaction_temp_id     IN             NUMBER
  , p_lot_control_code        IN             NUMBER
  , p_serial_control_code     IN             NUMBER
  , p_original_txn_temp_id    IN             NUMBER
  , x_return_status           OUT NOCOPY     VARCHAR2
  , x_msg_count               OUT NOCOPY     VARCHAR2
  , x_msg_data                OUT NOCOPY     VARCHAR2
  , p_inspection_status_code  IN             NUMBER
  , p_lpn_id                  IN             NUMBER
  , p_transfer_lpn_id         IN             NUMBER   DEFAULT NULL
  , p_lot_number              IN             VARCHAR2 DEFAULT NULL
  , p_parent_txn_id           IN             NUMBER   DEFAULT NULL
  , p_secondary_quantity      IN             NUMBER   DEFAULT NULL --OPM Convergence
  , p_secondary_uom           IN             VARCHAR2 DEFAULT NULL --OPM Convergence
  , p_inspection_status       IN             NUMBER DEFAULT NULL
  , p_primary_uom_code        IN             VARCHAR2
    ) IS

    CURSOR c_serial_cur IS
    SELECT distinct
           rsl.source_document_code       source_document_code
          ,rsl.po_line_location_id        po_line_location_id
          ,rsl.po_distribution_id         po_distribution_id
          ,rsl.shipment_line_id           shipment_line_id
          ,rsl.oe_order_line_id           oe_order_line_id
          ,rsh.receipt_source_code        receipt_source_code
          ,rss.serial_num                 serial_num
          ,rt.uom_code                    uom_code
          ,rss.transaction_id             rcv_transaction_id
          ,rss.lot_num                    lot_num
          ,rs.secondary_quantity          secondary_quantity
          ,msni.transaction_interface_id  transaction_interface_id
          ,rsl.asn_line_flag              asn_line_flag
     FROM rcv_supply rs,
          rcv_transactions rt,
          rcv_serials_supply rss,
          rcv_shipment_lines rsl,
          rcv_shipment_headers rsh,
          mtl_serial_numbers_interface msni
    WHERE rs.item_id = p_item_id
      --Bug 5250046: Removed the nvl and Modified the condition on item_revision.
      AND (p_revision is null or rs.item_revision = p_revision)
      AND rs.to_organization_id = p_organization_id
      AND nvl(rs.lpn_id,-1) = nvl(p_lpn_id,-1)
      AND rs.rcv_transaction_id = rt.transaction_id
      AND msni.product_code = 'RCV'
      AND msni.product_transaction_id = p_transaction_temp_id
      AND rss.serial_num between msni.fm_serial_number and msni.to_serial_number
      AND nvl(rss.lot_num,'@$#_') = nvl(p_lot_number, '@$#_')
      AND rss.supply_type_code = 'RECEIVING'
      AND rs.shipment_line_id = rsl.shipment_line_id
      AND rs.rcv_transaction_id = rss.transaction_id
      AND rsh.shipment_header_id = rsl.shipment_header_id
      AND decode(rt.routing_header_id, 2,
                decode(rt.inspection_status_code,'NOT INSPECTED',1, 'ACCEPTED',2,'REJECTED', 3)
                ,-1) = nvl(p_inspection_status, -1)
      ORDER BY  rcv_transaction_id
      ;

     CURSOR c_rtv_cur(v_from_sub VARCHAR2, v_from_locator_id NUMBER) IS
               SELECT
                      rsl.source_document_code source_document_code
                     ,rsl.po_line_location_id  po_line_location_id
                     ,rsl.po_distribution_id   po_distribution_id
                     ,rsl.shipment_line_id     shipment_line_id
                     ,rsl.oe_order_line_id     oe_order_line_id
                     ,rs.supply_source_id      supply_source_id
                     ,rs.rcv_transaction_id    rcv_transaction_id
                     ,rsh.receipt_source_code  receipt_source_code
                     ,rt.uom_code              uom_code
                     ,rs.secondary_quantity    secondary_quantity
		     ,Nvl(rls.primary_quantity,0) lot_prim_qty
		     ,Nvl(rls.quantity,0)         lot_qty
                     ,decode(rt.uom_code, p_rcvtxn_uom_code, 1, 2) ORDERING1
                     ,decode(rt.uom_code, p_rcvtxn_uom_code, (p_rcvtxn_qty - rs.quantity), 0) ORDERING2
                     ,rsl.asn_line_flag              asn_line_flag
                FROM rcv_supply rs,
                     rcv_transactions rt,
                     rcv_shipment_lines rsl,
                     rcv_lots_supply rls,
                     rcv_shipment_headers rsh
               WHERE rs.item_id = p_item_id
                 --Bug 5250046: Removed the nvl and Modified the condition on item_revision.
                 AND (p_revision is null or rs.item_revision = p_revision)
                 AND rs.to_organization_id = p_organization_id
                 AND nvl(rs.lpn_id,-1) = nvl(p_lpn_id,-1)
                 AND nvl(rt.subinventory,'@$#_') = nvl(v_from_sub,'@$#_')
                 AND nvl(rt.locator_id,-1) = nvl(v_from_locator_id, -1)

--4502518 Issue 26: redundant check.  Also, it will fail
--        when putting lines that have been corrected
--                 AND nvl(rt.transfer_lpn_id,-1) = nvl(p_lpn_id,-1)

                 AND rs.rcv_transaction_id = rt.transaction_id
                 AND rt.shipment_line_id = rsl.shipment_line_id
                 AND rs.supply_type_code = 'RECEIVING'
                 AND rls.transaction_id (+) = rs.supply_source_id
                 AND nvl(rls.lot_num, '@$#_') = nvl(p_lot_number, '@$#_')
                 AND rsh.shipment_header_id = rsl.shipment_header_id
                 AND decode(rt.routing_header_id, 2,
                     decode(rt.inspection_status_code,'NOT INSPECTED',1, 'ACCEPTED',2,'REJECTED', 3)
                     ,-1) = nvl(p_inspection_status, -1)
				AND --14133874
                   ((rsl.shipment_line_id = p_reference_id AND p_reference='SHIPMENT_LINE_ID')
                     OR
                    (rsl.po_line_location_id = p_reference_id AND p_reference='PO_LINE_LOCATION_ID')
                     OR
                    (rsl.oe_order_line_id = p_reference_id AND p_reference='ORDER_LINE_ID')
                   )
                 --Bug 5331779 - Begin change
		 --Adding the following to make sure that we do not pickup RS with serial numbers
		   AND NOT exists
		   (SELECT '1' FROM rcv_serials_supply rss
		    WHERE rss.transaction_id = rs.supply_source_id
		    AND rss.supply_type_code = 'RECEIVING')
		   --Bug 5331779-End change
		   ORDER BY ORDERING1, ORDERING2
                 ;

  l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_remaining_qty      NUMBER;
  l_new_rti_info    inv_rcv_integration_apis.child_rec_tb_tp;
  l_from_sub   VARCHAR2(30);
  l_from_locator_id NUMBER;
  l_split_lot_serial_ok     BOOLEAN;
  l_parent_txn_id           NUMBER;
  l_remaining_prim_qty      NUMBER;
  l_qty_to_insert           NUMBER;
  l_avail_qty               NUMBER;
  l_tolerable_qty           NUMBER;
  l_avail_prim_qty          NUMBER;
  l_secondary_quantity      NUMBER;
  l_original_lot_sec_qty    NUMBER;
  l_lot_sec_qty_to_insert   NUMBER;
  l_new_intf_id             NUMBER;
  l_primary_uom_code        VARCHAR2(3);
  l_uom_code        VARCHAR2(3);
  L_RTI_REC_FOUND           Boolean ;
  l_result                  Boolean;
  l_reference               VARCHAR2(240);
  l_reference_type_code     NUMBER;
  l_reference_id            NUMBER;
  l_return_status           VARCHAR2(1):= fnd_api.g_ret_sts_success;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(4000);
  l_matched_index           NUMBER;
  l_ser_txn_temp_id         NUMBER;
  l_progress                VARCHAR2(10);
  l_original_sec_qty        NUMBER;
  l_lot_temp_id             NUMBER;
  l_temp_id                 NUMBER;
  l_receipt_uom             VARCHAR2(30);
  l_receipt_qty             NUMBER;
  l_mmtt_id_to_insert       NUMBER;
  l_processed_lot_prim_qty  NUMBER;
  l_processed_lot_qty       NUMBER;

TYPE rti_info IS RECORD
  (rti_id                  NUMBER,
   rcv_transaction_id      NUMBER,
   lot_number              VARCHAR2(80),
   source_document_code    VARCHAR2(25),
   po_line_location_id     NUMBER,
   po_distribution_id      NUMBER,
   shipment_line_id        NUMBER,
   oe_order_line_id        NUMBER,
   receipt_source_code     VARCHAR2(25),
   serial_intf_id          NUMBER,
   uom_code                VARCHAR2(3),
   reference               VARCHAR2(240),
   REFERENCE_TYPE_CODE     NUMBER,
   REFERENCE_ID            NUMBER,
   quantity NUMBER);

  l_txn_id NUMBER;
  l_lot_num VARCHAR2(80);

  TYPE lot_tb_tp IS TABLE OF rti_info INDEX BY VARCHAR2(80);
  TYPE rti_tb_tp IS TABLE OF lot_tb_tp INDEX BY BINARY_INTEGER;

  l_rti_tb rti_tb_tp;

  k NUMBER;
  l VARCHAR2(80);

  BEGIN

    SAVEPOINT create_rti_ss;

    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Enter Match_putaway_rcvtxn_intf_rec ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Match_putaway_rcvtxn_intf_rec : ITEM_ID = '|| p_item_id , 1);
      print_debug('Match_putaway_rcvtxn_intf_rec : ORGANIZATION_ID = '|| p_organization_id , 1);
      print_debug('Match_putaway_rcvtxn_intf_rec : QTY = '|| p_rcvtxn_qty , 1);
      print_debug('Match_putaway_rcvtxn_intf_rec : UOM_CODE = '|| p_rcvtxn_qty , 1);
      print_debug('Match_putaway_rcvtxn_intf_rec : SUBINVENTORY_CODE = '||p_subinventory_code  , 1);
      print_debug('Match_putaway_rcvtxn_intf_rec : LOCATOR_ID = '|| p_locator_id , 1);

      print_debug('Match_putaway_rcvtxn_intf_rec : p_reference_id = '|| p_reference_id  , 1);
      print_debug('Match_putaway_rcvtxn_intf_rec : p_reference = '|| p_reference , 1);
      print_debug('Match_putaway_rcvtxn_intf_rec : p_reference_type_code = '|| p_reference_type_code , 1);
      print_debug('Match_putaway_rcvtxn_intf_rec : p_transaction_temp_id = '|| p_transaction_temp_id  , 1);
      print_debug('Match_putaway_rcvtxn_intf_rec : p_original_txn_temp_id = '||p_original_txn_temp_id,1);

    END IF;

    l_primary_uom_code := p_primary_uom_code;

    BEGIN
       select subinventory_code
             , locator_id
         into l_from_sub
             ,l_from_locator_id
         from wms_license_plate_numbers wlpn
        where wlpn.lpn_id = p_lpn_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF (l_debug = 1) THEN
      print_debug('Match_putaway_rcvtxn_intf_rec : PRIMARY_UOM_CODE = '|| l_primary_uom_code , 1);
    END IF;

    l_remaining_qty :=  p_rcvtxn_qty;

    l_remaining_prim_qty := inv_convert.inv_um_convert(
                                item_id     => p_item_id,
                              precision     => 5,
                          from_quantity     => p_rcvtxn_qty,
                              from_unit     => p_rcvtxn_uom_code,
                                to_unit     => l_primary_uom_code,
                              from_name     => null,
                                to_name     => null);

    IF (l_debug = 1) THEN
      print_debug('Match_putaway_rcvtxn_intf_rec 10 : REMAINING QTY  = '|| l_remaining_qty , 1);
      print_debug('Match_putaway_rcvtxn_intf_rec 10 : REMAINING PRIM QTY  = '|| l_remaining_prim_qty , 1);
    END IF;

    IF (p_serial_control_code = 1 OR p_serial_control_code = 6 ) then
       -- CASE WHERE ITEM IS NOT SERIAL CONTROLLED
       -- OR  CASE WHEN SERIAL CONTROLLED CODE IS AT SO ISSUE Bug: 5253223
       For l_rtv_rec in c_rtv_cur(l_from_sub, l_from_locator_id)
       Loop
	      IF (l_debug           = 1) THEN
       		 print_debug('Match_putaway_rcvtxn_intf_rec 10 : REMAINING PRIM QTY  = '|| l_remaining_prim_qty , 1);
	      END IF;

           IF l_remaining_prim_qty <= 0 THEN
             EXIT;
           END If;

           IF (l_debug = 1) THEN
              print_debug('INSIDE MATCHING LOOP TO FIND THE PARENT TXN  ' , 1);
              print_debug('SOURCE_DOCUMNET_CODE = '|| l_rtv_rec.source_document_code , 1);
              print_debug('po_line_location_id = ' || l_rtv_rec.po_line_location_id, 1);
              print_debug('shipment_line_id = '    || l_rtv_rec.shipment_line_id , 1);
              print_debug('oe_order_line_id '      || l_rtv_rec.oe_order_line_id , 1);
              print_debug('supply_source_id '      || l_rtv_rec.supply_source_id, 1);
              print_debug('receipt_source_code '   || l_rtv_rec.receipt_source_code, 1);
              print_debug('transaction id '   || l_rtv_rec.rcv_transaction_id, 1);
           END IF;

           IF (l_debug = 1) THEN
              print_debug('BEFORE GETTING AVAIL QTY  ' , 1);
           END IF;

	   IF (p_lot_control_code = 2) THEN
	      IF (l_debug = 1) THEN
		 print_debug('Querying MTLI to determine available QTY  ' , 1);
	      END IF;

	      BEGIN
		 SELECT SUM(primary_quantity)
		   ,    SUM(transaction_quantity)
		   INTO l_processed_lot_prim_qty
		   ,    l_processed_lot_qty
		   FROM mtl_transaction_lots_interface
		   WHERE product_code = 'RCV'
		   AND   product_transaction_id
		   IN (SELECT interface_transaction_id
		       FROM   rcv_transactions_interface
		       WHERE  parent_transaction_id = l_rtv_rec.rcv_transaction_id
		       )
		   AND   lot_number = p_lot_number;
	      EXCEPTION
		 WHEN OTHERS THEN
		    l_processed_lot_prim_qty := 0;
		    l_processed_lot_qty := 0;
	      END;

	      IF (l_debug = 1) THEN
		 print_debug('processed lot prim qty: '||l_processed_lot_prim_qty , 1);
		 print_debug('processed lot qty: '|| l_processed_lot_qty, 1);
	      END IF;

	      l_avail_prim_qty := l_rtv_rec.lot_prim_qty - Nvl(l_processed_lot_prim_qty,0);
	      l_avail_qty := l_rtv_rec.lot_qty - Nvl(l_processed_lot_qty,0);

	      IF (l_debug = 1) THEN
		 print_debug('available lot qty: '||l_avail_prim_qty , 1);
	      END IF;
	    ELSE
	      rcv_quantities_s.get_available_quantity
		                  ('DELIVER'
				   , l_rtv_rec.rcv_transaction_id
				   , l_rtv_rec.receipt_source_code
				   , NULL
				   ,  l_rtv_rec.rcv_transaction_id
				   , NULL
				   , l_avail_qty
				   , l_tolerable_qty
				   , l_receipt_uom);

	      IF (l_debug = 1) THEN
		 print_debug('AFTER GETTING AVAIL QTY. AVAIL QTY: '||l_avail_qty , 1);
	      END IF;

	      print_debug('p_item_id'||p_item_id , 1);
              print_debug('l_avail_qty'||l_avail_qty , 1);
              print_debug('l_rtv_rec.uom_code'||l_rtv_rec.uom_code , 1);
              print_debug('l_primary_uom_code'||l_primary_uom_code , 1);


        print_debug('l_rtv_rec.rcv_transaction_id '   || l_rtv_rec.rcv_transaction_id, 1);
	print_debug('p_organization_id '   || p_organization_id, 1);


/*7429358*/
	      BEGIN

 SELECT UOM_CODE INTO l_rtv_rec.uom_code FROM
 mtl_item_uoms_view WHERE organization_id=p_organization_id
 AND inventory_item_id = p_item_id
 AND unit_of_measure =
                       ( SELECT unit_of_measure FROM RCV_TRANSACTIONS
                         WHERE TRANSACTION_ID = l_rtv_rec.rcv_transaction_id);

EXCEPTION
 WHEN OTHERS THEN
   IF (l_debug = 1) THEN
      print_debug(': Error retrieving uom_code', 1);
   END IF;

   END;
   /*End of 7429358*/
   	print_debug('l_rtv_rec.uom_code '   || l_rtv_rec.uom_code, 1);


	      l_avail_prim_qty := inv_convert.inv_um_convert
		                       ( item_id     => p_item_id,
					 precision     => 5,
					 from_quantity     => l_avail_qty,
					 from_unit     => l_rtv_rec.uom_code,
					 to_unit     => l_primary_uom_code,
					 from_name     => null,
					 to_name     => null);

					 print_debug('p_item_id'||p_item_id , 1);
                      print_debug('l_avail_qty'||l_avail_qty , 1);
                      print_debug('l_rtv_rec.uom_code '||l_rtv_rec.uom_code , 1);
                      print_debug('l_primary_uom_code '||l_primary_uom_code , 1);



	      IF (l_debug = 1) THEN
		 print_debug('AVAIL QTY = '         ||  l_avail_qty , 1);
		 print_debug('AVAIL_PRIM QTY = '    || l_avail_prim_qty , 1);
		 print_debug('REMAINIG  QTY = '     || l_remaining_qty , 1);
		 print_debug('REMAINING_PRIM QTY = '|| l_remaining_prim_qty , 1);
	      END IF;
	   END IF;

	   IF l_avail_prim_qty <= 0 THEN
	      IF (l_debug = 1) THEN
		 print_debug('SKIPPING THIS LINE',1);
	      END IF;
	      GOTO nextrtrecord;
	   END IF;

	   SELECT rcv_transactions_interface_s.NEXTVAL
	     INTO l_new_intf_id
	     FROM dual;

           IF (l_avail_prim_qty < l_remaining_prim_qty ) THEN
              IF (p_rcvtxn_uom_code <> l_rtv_rec.uom_code) THEN
                 l_qty_to_insert := inv_convert.inv_um_convert( item_id     => p_item_id,
                              precision     => 5,
                          from_quantity     => l_avail_qty,
                              from_unit     => l_rtv_rec.uom_code,
                                to_unit     => p_rcvtxn_uom_code,
                              from_name     => null,
                                to_name     => null );


                 -- Qty to Insert IS
                 IF (l_debug = 1) THEN
                    print_debug('QTY TO INSERT1: = '||L_QTY_TO_INSERT , 1);
                 END IF;
              ELSE
                 --
                 -- WHICH MEANS THE DELIVER TRANSACTION UOM CODE
                 -- IS SAME AS THAN THE RECEIPT TRANSACTION UOM CODE
                 --
                 l_qty_to_insert := l_avail_qty;

                 IF (l_debug = 1) THEN
                    print_debug('QTY TO INSERT2: = '||L_QTY_TO_INSERT , 1);
                 END IF;

              END IF; -- IF (p_rcvtxn_uom_code <> l_rtv_rec.uom_code

              l_remaining_prim_qty := l_remaining_prim_qty - l_avail_prim_qty;
	      l_remaining_qty := l_remaining_qty - l_avail_qty;

	      IF (p_original_txn_temp_id IS NOT NULL) THEN
		 IF (l_debug = 1) THEN
		    print_debug('Calling split_mmtt', 1);
		 END IF;

		 inv_rcv_integration_apis.split_mmtt
		   (p_orig_mmtt_id      => p_original_txn_temp_id
		    ,p_prim_qty_to_splt => l_avail_prim_qty
		    ,p_prim_uom_code    => l_primary_uom_code
		    ,x_new_mmtt_id      => l_mmtt_id_to_insert
		    ,x_return_status    => l_return_status
		    ,x_msg_count        => l_msg_count
		    ,x_msg_data         => l_msg_data
		    );

		 IF (l_debug = 1) THEN
		    print_debug('Returned from split_mmtt',1);
		    print_debug('x_return_status: '||l_return_status,1);
		 END IF;

		 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		    IF (l_debug = 1) THEN
		       print_debug('x_msg_data:   '||l_msg_data,1);
		       print_debug('x_msg_count:  '||l_msg_count,1);
		       print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,1);
		       print_debug('Raising Exception!!!',1);
		    END IF;
		    l_progress := '@@@';
		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;
	      END IF;

	      IF (p_lot_control_code = 2) THEN


		 l_new_rti_info(1).orig_interface_trx_id := p_transaction_temp_id;
		 l_new_rti_info(1).new_interface_trx_id  := l_new_intf_id;
		 l_new_rti_info(1).quantity              := L_qty_to_insert;

		 l_new_rti_info(1).to_organization_id    := p_organization_id;
		 l_new_rti_info(1).item_id               := p_item_id;
		 l_new_rti_info(1).uom_code              := p_rcvtxn_uom_code;

		 IF (l_remaining_qty > 0) THEN
		    l_new_rti_info(2).orig_interface_trx_id := p_transaction_temp_id;
		    l_new_rti_info(2).new_interface_trx_id  := p_transaction_temp_id;
		    l_new_rti_info(2).quantity := l_remaining_qty;

		    l_new_rti_info(2).to_organization_id    := p_organization_id;
		    l_new_rti_info(2).item_id               := p_item_id;
		    l_new_rti_info(2).uom_code              := p_rcvtxn_uom_code;
		 END IF;

		 l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial
		   (p_api_version   => 1.0
		    , p_init_msg_lst  => FND_API.G_FALSE
		    , x_return_status =>  l_return_status
		    , x_msg_count     =>  l_msg_count
		    , x_msg_data      =>  l_msg_data
		    , p_new_rti_info  =>  l_new_rti_info);

		 IF ( NOT l_split_lot_serial_ok) THEN
		    IF (l_debug = 1) THEN
		       print_debug(' MATCH_PUTAWAY_RCVTXN_INTF_REC: Failure in split_lot_serial ', 4);
		    END IF;
		    RAISE FND_API.G_EXC_ERROR;
		 END IF;
	      END IF;
           ELSE
              /*10328780 - This is a redundant conversion
	      l_qty_to_insert := inv_convert.inv_um_convert(
                                item_id     => p_item_id,
                              precision     => 5,
                          from_quantity     => l_remaining_prim_qty,
                              from_unit     => l_primary_uom_code,
                                to_unit     => p_rcvtxn_uom_code,
                              from_name     => null,
                                to_name     => null ); */
                 l_qty_to_insert := l_remaining_qty; --10328780

                 IF (l_debug = 1) THEN
                    print_debug('QTY TO INSERT3: = ' || L_QTY_TO_INSERT , 1);
                 END IF;

		 IF (p_lot_control_code = 2) THEN
		    UPDATE mtl_transaction_lots_interface
		      SET  product_transaction_id = l_new_intf_id
		      WHERE product_transaction_id = p_transaction_temp_id
		      AND   product_code = 'RCV';
		 END IF;

                 l_remaining_prim_qty := 0;
		 l_remaining_qty := 0;
		 l_mmtt_id_to_insert := p_original_txn_temp_id;

           END IF;

           IF l_rtv_rec.source_document_code = 'PO' THEN
	      IF l_rtv_rec.asn_line_flag = 'Y' then
		 L_reference := 'SHIPMENT_LINE_ID';
		 L_reference_type_code := 4;
		 L_reference_id := l_rtv_rec.shipment_line_id ;
	       ELSE
		 L_reference := 'PO_LINE_LOCATION_ID';
		 L_reference_type_code := 4;
		 L_reference_id := l_rtv_rec.po_line_location_id ;
	      END IF;
           ELSIF l_rtv_rec.source_document_code IN ('INVENTORY', 'REQ') THEN
                L_reference := 'SHIPMENT_LINE_ID';
                L_reference_type_code := 8;
                L_reference_id := l_rtv_rec.shipment_line_id;
           ELSIF l_rtv_rec.source_document_code = 'RMA' THEN
                L_reference := 'ORDER_LINE_ID';
                L_reference_type_code := 7;
                L_reference_id := l_rtv_rec.oe_order_line_id;
           ELSE
                -- FAIL HERE AS THERE MAY NOT BE ANY OTHER SOURCE DOCUMENT CODE
                IF (l_debug = 1) THEN
                     print_debug('REFERENCE INFO CAN NOT BE RETRIEVVED FROM RT' , 1);
                END IF;
                fnd_message.set_name('INV', 'INV_FAILED');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
           END IF;

           IF (l_debug = 1) THEN
                print_debug('REFERENCE = '||L_REFERENCE , 1);
                print_debug('REFERENCE_TYPE_CODE = '||L_REFERENCE_TYPE_CODE , 1);
               print_debug('REFERENCE_ID = '||L_REFERENCE_ID , 1);
           END IF;

           -- If the secondary_uom_code is not null then calculate the secondary
           -- Qty based on percentage of transaction quantity

           if p_secondary_uom is not null Then
              IF (l_debug = 1) THEN
                   print_debug('CALCULATING SEC QTY' , 1);
              END IF;
              l_secondary_quantity := p_secondary_quantity * (l_qty_to_insert/p_rcvtxn_qty);
           Else
              l_secondary_quantity := null;
           End if;

	   IF (l_debug = 1) THEN
	      print_debug('INTF ID = '||l_new_intf_id , 1);
	   END IF;

           IF (l_debug = 1) THEN
                   print_debug('SECONDARY UOM CODE = '|| p_secondary_uom  , 1);
                   print_debug('SECONDARY QTY      = '|| l_secondary_quantity, 1);
           END IF;

           inv_rcv_std_deliver_apis.create_putaway_rcvtxn_intf_rec(
                    p_organization_id            => p_organization_id
                  , p_reference_id               => l_reference_id
                  , p_reference                  => l_reference
                  , p_reference_type_code        => l_reference_type_code
                  , p_item_id                    => p_item_id
                  , p_revision                   => p_revision
                  , p_subinventory_code          => p_subinventory_code
                  , p_locator_id                 => p_locator_id
                  , p_rcvtxn_qty                 => L_qty_to_insert
                  , p_rcvtxn_uom_code            => p_rcvtxn_uom_code
                  , p_transaction_temp_id        => l_new_intf_id
                  , p_lot_control_code           => p_lot_control_code
                  , p_serial_control_code        => p_serial_control_code
                  , p_original_txn_temp_id       => l_mmtt_id_to_insert
                  , x_return_status              => l_return_status
                  , x_msg_count                  => l_msg_count
                  , x_msg_data                   => l_msg_data
                  , p_inspection_status_code     => p_inspection_status_code
                  , p_lpn_id                     => p_lpn_id
                  , p_transfer_lpn_id            => p_transfer_lpn_id
                  , p_lot_number                 => p_lot_number
                  , p_parent_txn_id              => l_rtv_rec.rcv_transaction_id
                  , p_secondary_quantity         => l_secondary_quantity   --OPM Integration
                  , p_secondary_uom              => p_secondary_uom   --OPM Integration
                  );

           IF (l_debug = 1) THEN
		print_debug('AFTER CALLING THE DELIVERY API: p_rcvtxn_qty = '|| p_rcvtxn_qty, 1);
		print_debug('AFTER CALLING THE DELIVERY API: p_rcvtxn_uom_code = '|| p_rcvtxn_uom_code, 1);
		print_debug('AFTER CALLING THE DELIVERY API: STATUS = '|| l_return_status, 1);
           END IF;

           IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             fnd_message.set_name('WMS', 'WMS_TD_DEL_ERROR');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_unexpected_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
             fnd_message.set_name('WMS', 'WMS_TD_DEL_ERROR');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
           END IF;

	   <<nextrtrecord>>
	     NULL;
       End Loop; -- End of Recipt' txns Loop

	IF (l_debug = 1) THEN
           print_debug('l_remaining_prim_qty final is ... '|| l_remaining_prim_qty, 1);
        END IF;

       --Bug 5331779-Begin change
       --If l_remaining_prim_qty > 0 then only
       --fail if the serial control code is 1 because for serial control
       --code of 6, there may be lines with serial number which are yet to
       --be processed.
       IF p_serial_control_code = 1 AND l_remaining_prim_qty > 0.000005 THEN
       -- Bug 5331779 -End change
--     IF l_remaining_prim_qty > 0 THEN
           IF (l_debug = 1) THEN
                print_debug('COUND NOT MATCH RECEIPT TRANSACTION FOR THE QTY TO BE DELIVERED:  FAILURE ', 1);
           END IF;

           -- Unable to match RS with quantity.
           fnd_message.set_name('WMS', 'WMS_TD_DEL_ERROR');
           fnd_msg_pub.ADD;
           RAISE FND_API.g_exc_error;

       END IF;

       --Bug 5331779-Begin Change
       --Instead of an else block we need to have
       --another if block because for items with serial control code 6, we
       --want both blocks to be executed.
    END IF;
     --ELSE -- ITEM IS SERIAL CONTROLLED.

    IF ((p_serial_control_code NOT IN (1,6))
	OR (p_serial_control_code = 6 AND l_remaining_prim_qty > 0)) THEN
       --Bug 5331779- End change

       IF (l_debug = 1) THEN
	  print_debug('THIS IS A SERIAL-CONTROLLED ITEM',1);
	  print_debug('Fetching from C_SERIAL_CUR',1);
       END IF;

        L_RTI_REC_FOUND := FALSE;

        FOR l_serial_rec in C_SERIAL_CUR
        LOOP

           IF (l_debug = 1) THEN
                print_debug('INSIDE SERIAL CURSOR LOOP ', 1);
           END IF;

           IF (l_debug = 1) THEN
                print_debug('COUNT OF RTI ROWS '|| l_rti_tb.COUNT, 1);
           END IF;

	   l_txn_id := l_serial_rec.rcv_transaction_id;
	   l_lot_num := nvl(l_serial_rec.lot_num, '@$#_');


	   IF (l_rti_tb.exists(l_txn_id) AND
	       l_rti_tb(l_txn_id).exists(l_lot_num)) THEN

	      l_rti_tb(l_txn_id)(l_lot_num).quantity
		:= l_rti_tb(l_txn_id)(l_lot_num).quantity + 1;

	    ELSE
               SELECT rcv_transactions_interface_s.NEXTVAL
                 INTO l_new_intf_id
                 FROM dual;

               l_rti_tb(l_txn_id)(l_lot_num).rti_id := l_new_intf_id;

               IF (p_lot_number IS NOT NULL) THEN

                  -- Generate the Serial Txn Temp Id

                  select mtl_material_transactions_s.nextval
                    into l_ser_txn_temp_id from dual;

                   l_rti_tb(l_txn_id)(l_lot_num).lot_number       := l_serial_rec.lot_num;
                   l_rti_tb(l_txn_id)(l_lot_num).serial_intf_id   := l_ser_txn_temp_id;
               ELSE
		  l_rti_tb(l_txn_id)(l_lot_num).serial_intf_id   := null;
               END IF;

               l_rti_tb(l_txn_id)(l_lot_num).rcv_transaction_id   :=  l_serial_rec.rcv_transaction_id;
               l_rti_tb(l_txn_id)(l_lot_num).po_line_location_id  :=  l_serial_rec.po_line_location_id;
               l_rti_tb(l_txn_id)(l_lot_num).po_distribution_id   :=  l_serial_rec.po_distribution_id;
               l_rti_tb(l_txn_id)(l_lot_num).uom_code             :=  l_serial_rec.uom_code;
               l_rti_tb(l_txn_id)(l_lot_num).source_document_code :=  l_serial_rec.source_document_code;
               l_rti_tb(l_txn_id)(l_lot_num).quantity             :=  1;
	       l_rti_tb(l_txn_id)(l_lot_num).receipt_source_code  :=  l_serial_rec.receipt_source_code;
	       l_rti_tb(l_txn_id)(l_lot_num).uom_code             :=  l_serial_rec.uom_code;
               --l_rti_tb(l_txn_id)(l_lot_num).secondary_quantity   :=  l_serial_rec.secondary_quantity;
               --l_rti_tb(l_txn_id)(l_lot_num).secondary_uom_code   :=  l_serial_rec.secondary_uom_code;

               IF l_rti_tb(l_txn_id)(l_lot_num).source_document_code = 'PO' THEN
		  IF l_serial_rec.asn_line_flag = 'Y' then
		     l_rti_tb(l_txn_id)(l_lot_num).reference := 'SHIPMENT_LINE_ID';
		     l_rti_tb(l_txn_id)(l_lot_num).reference_type_code := 4;
		     l_rti_tb(l_txn_id)(l_lot_num).reference_id := l_serial_rec.shipment_line_id ;
		   ELSE
                     l_rti_tb(l_txn_id)(l_lot_num).reference := 'PO_LINE_LOCATION_ID';
                     l_rti_tb(l_txn_id)(l_lot_num).reference_type_code := 4;
                     l_rti_tb(l_txn_id)(l_lot_num).reference_id := l_serial_rec.po_line_location_id;
		  END IF;
                ELSIF l_rti_tb(l_txn_id)(l_lot_num).source_document_code IN ('INVENTORY', 'REQ') THEN
                     l_rti_tb(l_txn_id)(l_lot_num).reference := 'SHIPMENT_LINE_ID';
                     l_rti_tb(l_txn_id)(l_lot_num).reference_type_code := 8;
                     l_rti_tb(l_txn_id)(l_lot_num).reference_id := l_serial_rec.shipment_line_id;
                ELSIF l_rti_tb(l_txn_id)(l_lot_num).source_document_code = 'RMA' THEN
                     l_rti_tb(l_txn_id)(l_lot_num).reference := 'ORDER_LINE_ID';
                     l_rti_tb(l_txn_id)(l_lot_num).reference_type_code := 7;
                     l_rti_tb(l_txn_id)(l_lot_num).reference_id := l_serial_rec.oe_order_line_id;
                ELSE
                     -- FAIL HERE AS THERE MAY NOT BE ANY OTHER SOURCE DOCUMENT CODE
                     IF (l_debug = 1) THEN
                          print_debug('REF INFO CAN NOT BE RETRIEVVED FROM RT' , 1);
                     END IF;
                          fnd_message.set_name('INV', 'INV_FAILED');
                          fnd_msg_pub.ADD;
                          RAISE fnd_api.g_exc_error;
                     END IF;

                IF (l_debug = 1) THEN
                     print_debug('REFERENCE = '          ||l_rti_tb(l_txn_id)(l_lot_num).reference , 1);
                     print_debug('REFERENCE_TYPE_CODE = '||l_rti_tb(l_txn_id)(l_lot_num).reference_type_code , 1);
                     print_debug('REFERENCE_ID = '       ||l_rti_tb(l_txn_id)(l_lot_num).reference_id , 1);
                END IF;

           END IF;

           -- INSERT MSNI HERE
           l_result := insert_msni_helper(
                        p_txn_if_id       =>  l_rti_tb(l_txn_id)(l_lot_num).serial_intf_id
                      , p_serial_number   =>  l_serial_rec.serial_num
                      , p_org_id          =>  p_organization_id
                      , p_item_id         =>  p_item_id
                      , p_product_txn_id  =>  l_rti_tb(l_txn_id)(l_lot_num).rti_id
                      );

           IF NOT l_result THEN
                    IF (l_debug = 1) THEN
                    print_debug('Failure while Inserting MSNI records - lot and serial controlled item',1);
                    END IF;
                    RAISE fnd_api.g_exc_unexpected_error;
           END IF; -- END IF check l_result

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
             IF (l_debug = 1) THEN
               print_debug('insert_msni_helper: Error occurred while creating interface serials: ' || l_msg_data,1);
             END IF;
             RAISE fnd_api.g_exc_error;
           END IF;

	END LOOP; -- End of serial cursor Loop here

        --
        -- INSERT LOT ROWS HERE IF IT IS BOTH LOT AND SERIAL CONTROLLED

	l_remaining_prim_qty := inv_convert.inv_um_convert
	                             (item_id     => p_item_id,
				      precision     => 5,
				      from_quantity     => p_rcvtxn_qty,
				      from_unit     => p_rcvtxn_uom_code,
				      to_unit     => l_primary_uom_code,
				      from_name     => null,
				      to_name     => null);
	k := l_rti_tb.first;

	LOOP
	   EXIT WHEN k IS NULL;

	   l := l_rti_tb(k).first;

	   LOOP
	      EXIT WHEN l IS NULL;

	      IF (l_debug = 1) THEN
		 print_debug('k: ' || k || ' l: '||l,1);
		 print_debug('l_rti_tb(k)(l).quantity: '||l_rti_tb(k)(l).quantity,1);
		 print_debug('l_rti_tb(k)(l).rcv_transaction_id: '||l_rti_tb(k)(l).rcv_transaction_id,1);
		 print_debug('l_rti_tb(k)(l).receipt_source_code: '||l_rti_tb(k)(l).receipt_source_code,1);
	      END IF;

	      --
	      -- Get the seconadry qty from the Original MTLI
	      --
	      IF p_rcvtxn_uom_code = l_primary_uom_code Then
		 l_qty_to_insert :=  l_rti_tb(k)(l).quantity;
	       ELSE
		 l_qty_to_insert := inv_convert.inv_um_convert
		                        ( item_id     => p_item_id,
					  precision     => 5,
					  from_quantity     => l_rti_tb(k)(l).quantity,
					  from_unit     => l_primary_uom_code,
					  to_unit     => p_rcvtxn_uom_code,
					  from_name     => null,
					  to_name     => null );
	      END IF;

	      l_uom_code := p_rcvtxn_uom_code;

	      IF (l_debug = 1) THEN
		 print_debug(' qty to insert = ' || l_qty_to_insert, 1);
	      END IF;

	      rcv_quantities_s.get_available_quantity(
						      'DELIVER'
						      ,l_rti_tb(k)(l).rcv_transaction_id
						      ,l_rti_tb(k)(l).receipt_source_code
						      , NULL
						      ,l_rti_tb(k)(l).rcv_transaction_id
						      , NULL
						      , l_avail_qty
						      , l_tolerable_qty
						      , l_receipt_uom);
	      IF (l_debug =1 ) THEN
		 print_debug(' l_avail_qty: ' ||l_avail_qty, 1);
		 print_debug(' l_receipt_uom: '||l_receipt_uom, 1);

	      END IF;

	      if l_rti_tb(k)(l).uom_code <> l_uom_code then

		 l_receipt_qty := inv_convert.inv_um_convert( item_id     => p_item_id,
							      precision     => 5,
							      from_quantity     => l_avail_qty,
							      from_unit     => l_rti_tb(k)(l).uom_code,
							      to_unit     => l_uom_code,
							      from_name     => null,
							      to_name     => null );

                 l_avail_qty := l_receipt_qty;
	      END  if;

	      IF l_avail_qty < l_qty_to_insert THEN
		 -- FAIL THE TXN NOT ENOUGH QTY AVAIABLE TO TRANSACT
		 IF (l_debug = 1) THEN
		    print_debug('l_avail_qty: ' || l_avail_qty, 1);
		    print_debug('Avaiable Qty is less than Txn Qty  ' , 1);
		 END IF;
		 fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      IF (l_rti_tb(k)(l).quantity < l_remaining_prim_qty) THEN
		 IF (p_original_txn_temp_id IS NOT NULL) THEN
		    IF (l_debug = 1) THEN
		       print_debug('Calling split_mmtt', 1);
		    END IF;

		    inv_rcv_integration_apis.split_mmtt
		      (p_orig_mmtt_id      => p_original_txn_temp_id
		       ,p_prim_qty_to_splt => l_rti_tb(k)(l).quantity
		       ,p_prim_uom_code    => l_primary_uom_code
		       ,x_new_mmtt_id      => l_mmtt_id_to_insert
		       ,x_return_status    => l_return_status
		       ,x_msg_count        => l_msg_count
		       ,x_msg_data         => l_msg_data
		       );

		    IF (l_debug = 1) THEN
		       print_debug('Returned from split_mmtt',1);
		       print_debug('x_return_status: '||l_return_status,1);
		    END IF;

		    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		       IF (l_debug = 1) THEN
			  print_debug('x_msg_data:   '||l_msg_data,1);
			  print_debug('x_msg_count:  '||l_msg_count,1);
			  print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,1);
			  print_debug('Raising Exception!!!',1);
		       END IF;
		       l_progress := '@@@';
		       RAISE fnd_api.g_exc_unexpected_error;
		    END IF;
		 END IF;

		 l_remaining_prim_qty := l_remaining_prim_qty-l_rti_tb(k)(l).quantity;
	       ELSE
		 l_mmtt_id_to_insert := p_original_txn_temp_id;
		 l_remaining_prim_qty := 0;
	      END IF;

	      IF p_lot_number IS NOT NULL THEN
                -- CASE FOR BOTH LOT AND SERIAL CONTROLLED ITEM
                 BEGIN
                    select secondary_transaction_quantity
		      into l_original_lot_sec_qty
		      from mtl_transaction_lots_interface mtli
                      where mtli.lot_number = p_lot_number
		      and mtli.product_code = 'RCV'
		      and mtli.product_transaction_id =  p_transaction_temp_id ;
		 EXCEPTION
		    WHEN NO_DATA_FOUND THEN NULL;
		 END;

		 IF l_original_sec_qty is not null THEN
		    l_lot_sec_qty_to_insert := l_original_lot_sec_qty * (l_qty_to_insert / p_rcvtxn_qty);
                END IF;

                IF (l_debug = 1) THEN
                   print_debug('Lot Secondary qty to insert = ' || l_lot_sec_qty_to_insert, 1);
                END IF;

                IF (l_debug = 1) THEN
                   print_debug('BEFORE CALLING THE insert_mtli_helper API ', 1);
		   print_debug('  p_txn_if_id       => '|| l_lot_temp_id,1);
		   print_debug('  p_lot_number    => '|| l_rti_tb(k)(l).lot_number,1);
		   print_debug('  p_txn_qty       => '|| l_qty_to_insert,1);
		   print_debug('  p_prm_qty       => '|| l_rti_tb(k)(l).quantity,1);
		   print_debug('  p_item_id       => '|| p_item_id,1);
		   print_debug('  p_org_id        => '|| p_organization_id,1);
		   print_debug('  p_serial_temp_id=> '|| l_rti_tb(k)(l).serial_intf_id,1);
		   print_debug('  p_product_txn_id=> '|| l_rti_tb(k)(l).rti_id,1);
		   print_debug('  p_secondary_quantit=> '|| l_lot_sec_qty_to_insert,1);
		   print_debug('  p_secondary_uom    =>'|| p_secondary_uom,1);
                END IF;

                l_result := insert_mtli_helper
		               (p_txn_if_id         =>  l_lot_temp_id
				, p_lot_number      =>  l_rti_tb(k)(l).lot_number
				, p_txn_qty         =>  l_qty_to_insert
				, p_prm_qty         =>  l_rti_tb(k)(l).quantity
				, p_item_id         =>  p_item_id
				, p_org_id          =>  p_organization_id
				, p_serial_temp_id  =>  l_rti_tb(k)(l).serial_intf_id
				, p_product_txn_id  =>  l_rti_tb(k)(l).rti_id
				, p_secondary_quantity =>  l_lot_sec_qty_to_insert --OPM Convergence
				, p_secondary_uom      => p_secondary_uom);   --OPM Convergence

		IF NOT l_result THEN
		   IF (l_debug = 1) THEN
                      print_debug('Failure while Inserting MTLI records - lot and serial controlled item',1);
		   END IF;
		   RAISE fnd_api.g_exc_unexpected_error;
		END IF;   --END IF check l_result
             END IF; --IF P_LOT_NUMBER IS NOT NULL THEN

             -- CALL TO RTI HERE

             l_reference           := l_rti_tb(k)(l).reference;
             l_reference_id        := l_rti_tb(k)(l).reference_id;
             l_reference_type_code := l_rti_tb(k)(l).reference_type_code;
             l_new_intf_id         := l_rti_tb(k)(l).rti_id;
             l_parent_txn_id       := l_rti_tb(k)(l).rcv_transaction_id;

	     IF (l_debug = 1) THEN
                print_debug('REFERENCE = '||L_REFERENCE , 1);
                print_debug('REFERENCE_TYPE_CODE = '||L_REFERENCE_TYPE_CODE , 1);
                print_debug('REFERENCE_ID = '||L_REFERENCE_ID , 1);
	     END IF;

             IF p_secondary_uom is not null THEN
                l_secondary_quantity := p_secondary_quantity * (l_qty_to_insert/p_rcvtxn_qty);
             END IF;

	     IF (l_debug = 1) THEN
		print_debug('BEFORE CALLING THE DELIVER API ', 1);
	     END IF;

             inv_rcv_std_deliver_apis.create_putaway_rcvtxn_intf_rec(
                    p_organization_id            => p_organization_id
                  , p_reference_id               => l_reference_id
                  , p_reference                  => l_reference
                  , p_reference_type_code        => l_reference_type_code
                  , p_item_id                    => p_item_id
                  , p_revision                   => p_revision
                  , p_subinventory_code          => p_subinventory_code
                  , p_locator_id                 => p_locator_id
                  , p_rcvtxn_qty                 => L_qty_to_insert
                  , p_rcvtxn_uom_code            => p_rcvtxn_uom_code
                  , p_transaction_temp_id        => l_new_intf_id
                  , p_lot_control_code           => p_lot_control_code
                  , p_serial_control_code        => p_serial_control_code
                  , p_original_txn_temp_id       => l_mmtt_id_to_insert
                  , x_return_status              => l_return_status
                  , x_msg_count                  => l_msg_count
                  , x_msg_data                   => l_msg_data
                  , p_inspection_status_code     => p_inspection_status_code
                  , p_lpn_id                     => p_lpn_id
                  , p_transfer_lpn_id            => p_transfer_lpn_id
                  , p_lot_number                 => p_lot_number
                  , p_parent_txn_id              => l_parent_txn_id
                  , p_secondary_quantity         => l_secondary_quantity   --OPM Integration
                  , p_secondary_uom              => p_secondary_uom        --OPM Integration
	       );

	     IF (l_debug = 1) THEN
		print_debug('AFTER CALLING THE DELIVER API: STATUS = '||l_return_status, 1);
	     END IF;

	     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
	     END IF;

	     l := l_rti_tb(k).next(l);
	   END LOOP;

	   k := l_rti_tb.next(k);
	END LOOP;

     END IF; -- End of serial Controlled

     IF (l_debug = 1) THEN
           print_debug('MATCH PUTAWAY RETURNING WITH SUCCESS RETUN STATUS = ' ||x_return_status, 1);
     END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      rollback to create_rti_ss;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
     IF (l_debug = 1) THEN
           print_debug('MATCH PUTAWAY: EXCEPTION OCCURRED AT PROGRESS ' || l_progress, 1);
     END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      rollback to create_rti_ss;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
     IF (l_debug = 1) THEN
           print_debug('MATCH PUTAWAY: EXCEPTION OCCURRED AT PROGRESS ' || l_progress, 1);
     END IF;

    WHEN OTHERS THEN
      rollback to create_rti_ss;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_rcv_std_deliver_apis.create_std_rcvtxn_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END Match_putaway_rcvtxn_intf_rec ;

END inv_rcv_std_deliver_apis;

/
