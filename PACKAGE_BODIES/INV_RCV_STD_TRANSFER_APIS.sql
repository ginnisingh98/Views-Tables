--------------------------------------------------------
--  DDL for Package Body INV_RCV_STD_TRANSFER_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_STD_TRANSFER_APIS" AS
  /* $Header: INVSTDTB.pls 120.11 2006/11/22 05:40:13 anviswan ship $ */

  --Transaction UOM Code in RTI. Need this because the rcv_transactions
  --record type does not store the uom_code
  g_transfer_uom_code MTL_ITEM_UOMS_VIEW.UOM_CODE%TYPE;

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_RCV_STD_TRANSFER_APIS';

  /* Debugging utility*/
  PROCEDURE print_debug (
      p_err_msg VARCHAR2
    , p_level   NUMBER) IS
    l_debug NUMBER  :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog (
          p_err_msg   =>  p_err_msg
        , p_module    =>  g_pkg_name||' ($Revision: 120.11 $)'
        , p_level     =>  p_level);
    END IF;
    --dbms_output.put_line(p_err_msg);
  END print_debug;

 /*----------------------------------------------------------------------------*
  * FUNCTION: insert_interface_code
  * Description:
  *   Helper routing to create a new record in RCV_TRANSACTIONS_INTERFACE
  *
  * Input Parameters:
  *    p_rcv_transactions_rec - Record containing the values for RTI
  *
  * Returns: NUMBER - transaction_interface_id
  *---------------------------------------------------------------------------*/

  FUNCTION insert_interface_code (
    p_rcv_transaction_rec INV_RCV_STD_DELIVER_APIS.RCVTXN_TRANSACTION_REC_TP
      )
  RETURN NUMBER IS
    l_interface_transaction_id  NUMBER;
    l_destination_context       RCV_TRANSACTIONS_INTERFACE.DESTINATION_CONTEXT%TYPE :=  'RECEIVING';
    l_parent_transaction_id     NUMBER  :=  p_rcv_transaction_rec.rcv_transaction_id;
    l_movement_id               NUMBER;
    l_bom_resource_id           NUMBER  :=  NULL;
    l_group_id                  NUMBER  :=  inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    l_user_id                   NUMBER  :=  inv_rcv_common_apis.g_po_startup_value.user_id;
    l_employee_id               NUMBER  :=  inv_rcv_common_apis.g_po_startup_value.employee_id;
    l_logon_id                  NUMBER  :=  inv_rcv_common_apis.g_po_startup_value.logon_id;
    l_transaction_mode          VARCHAR2(10)  := inv_rcv_common_apis.g_po_startup_value.transaction_mode;
    l_trx_date                  DATE;
    l_currency_conv_date        DATE;
    l_validation_flag           VARCHAR2(1);
    l_lpn_group_id              NUMBER;
    l_progress                  NUMBER;       --Index to track progress and log error
    l_debug                     NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
    l_project_id                NUMBER := NULL;
    l_task_id                   NUMBER := NULL;

    l_operating_unit_id MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE;   --<R12 MOAC>

  BEGIN

    print_debug('Entered insert_interface_code 10 : ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    print_debug('  parent_transaction_id => '||p_rcv_transaction_rec.rcv_transaction_id,1);

    --Generate a new value for RTID from the sequence
    SELECT  rcv_transactions_interface_s.NEXTVAL
    INTO    l_interface_transaction_id
    FROM    sys.DUAL;

    l_parent_transaction_id := p_rcv_transaction_rec.rcv_transaction_id;

    BEGIN
       --R12: We can no longer join to MTRL.TXN_SOURCE_ID.
       --Using RT.PROJECT_ID and RT.TASK_ID should be sufficient
       SELECT rt.movement_id
	 , rt.project_id
	 , rt.task_id
	 INTO   l_movement_id
	 , l_project_id
	 , l_task_id
	 FROM   rcv_transactions rt
	 WHERE  rt.transaction_id = l_parent_transaction_id
	 AND ROWNUM < 2;
    EXCEPTION
       WHEN OTHERS THEN
	  print_debug('Error while retrieving project and task. SQLCODE:'||SQLCODE||' SQLERRM:'||Sqlerrm,1);
          RAISE FND_API.G_EXC_ERROR;
    END ;


    --Truncate the transaction_date to store only the date part
    l_trx_date            :=  TRUNC(p_rcv_transaction_rec.transaction_date_nb);
    -- bug 3452845
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
       l_trx_date := Sysdate;
     ELSE
       l_trx_date := Trunc(Sysdate);
    END IF;

    l_currency_conv_date  :=  TRUNC(p_rcv_transaction_rec.currency_conversion_date);

    --Populate the LPN_GROUP_ID and validation_flag columns in RTI
    l_validation_flag := 'Y';
    l_lpn_group_id    := l_group_id;

    --<R12 MOAC>
    l_operating_unit_id := inv_rcv_common_apis.get_operating_unit_id( p_rcv_transaction_rec.receipt_source_code,
                                                                      p_rcv_transaction_rec.po_header_id,
                                                                      p_rcv_transaction_rec.req_line_id,
                                                                      p_rcv_transaction_rec.oe_order_header_id );

    IF (l_debug = 1) THEN
      print_debug('   parent txn: ' || l_parent_transaction_id,4);
      print_debug('   item: ' || p_rcv_transaction_rec.item_id,4);
      print_debug('   org: ' || p_rcv_transaction_rec.to_organization_id,4);
      print_debug('   txn tp: ' || p_rcv_transaction_rec.transaction_type,4);
      print_debug('   src doc: ' || p_rcv_transaction_rec.source_document_code,4);
      print_debug('   dest: ' || p_rcv_transaction_rec.destination_type_code,4);
      print_debug('   po hdr: ' || p_rcv_transaction_rec.po_header_id,4);
      print_debug('   vnd id: ' || p_rcv_transaction_rec.vendor_id,4);
      print_debug('   po line: ' || p_rcv_transaction_rec.po_line_id,4);
      print_debug('   po loc: ' || p_rcv_transaction_rec.po_line_location_id,4);
      print_debug('   shp hdr: ' || p_rcv_transaction_rec.shipment_header_id,4);
      print_debug('   shp line: ' || p_rcv_transaction_rec.shipment_line_id,4);
      print_debug('   req hdr: ' || p_rcv_transaction_rec.req_header_id,4);
      print_debug('   req line: ' || p_rcv_transaction_rec.req_line_id,4);
      print_debug('   oe hdr: ' || p_rcv_transaction_rec.oe_order_header_id,4);
      print_debug('   oe line: ' || p_rcv_transaction_rec.oe_order_line_id,4);
      print_debug('   txn qty: ' || p_rcv_transaction_rec.transaction_quantity,4);
      print_debug('   txn uom: ' || p_rcv_transaction_rec.transaction_uom,4);
      print_debug('   prm qty: ' || p_rcv_transaction_rec.primary_quantity,4);
      print_debug('   prm uom: ' || p_rcv_transaction_rec.primary_uom,4);
      print_debug('   sec qty: ' || p_rcv_transaction_rec.sec_transaction_quantity,4);
      print_debug('   sec uom: ' || p_rcv_transaction_rec.secondary_uom ,4);
      print_debug('   sec uom code: ' || p_rcv_transaction_rec.secondary_uom_code,4);
      print_debug('   gov ctx: ' || p_rcv_transaction_rec.government_context,4);
      print_debug('   cur code: ' || p_rcv_transaction_rec.currency_code,4);
      print_debug('   cur type: ' || p_rcv_transaction_rec.currency_conversion_type,4);
      print_debug('   cur rate: ' || p_rcv_transaction_rec.currency_conversion_rate,4);
      print_debug('   lpn: ' || p_rcv_transaction_rec.lpn_id,4);
      print_debug('   xfr lpn: ' || p_rcv_transaction_rec.transfer_lpn_id,4);
      print_debug('   locn: ' || p_rcv_transaction_rec.location_id,4);
      print_debug('   sub: ' || p_rcv_transaction_rec.subinventory_dsp,4);
      print_debug('   loc: ' || p_rcv_transaction_rec.locator_id,4);
      print_debug('   grp id: ' || l_group_id, 4);
      print_debug('   usr id: ' || l_user_id, 4);
      print_debug('   emp id: ' || l_employee_id, 4);
      print_debug('   trx dt: ' || l_trx_date, 4);
      print_debug('   vldn_flg: ' || l_validation_flag, 4);
      print_debug('   lpn_group_id: ' || l_lpn_group_id, 4);
      print_debug('   project_id: ' || l_project_id, 4);
      print_debug('   task_id: ' || l_task_id, 4);
      print_debug('   l_operating_unit_id: ' || l_operating_unit_id, 4);  --<R12 MOAC>
   END IF;

   BEGIN
   --At last, now insert the record into RTI
    INSERT INTO rcv_transactions_interface
                (
                 receipt_source_code
               , interface_transaction_id
               , group_id
               , created_by
               , creation_date
               , last_updated_by
               , last_update_date
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
               , uom_code
               -- OPM COnvergence
               , SECONDARY_QUANTITY
               , SECONDARY_UNIT_OF_MEASURE
               , SECONDARY_UOM_CODE
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
               , validation_flag
               , lpn_group_id
               , project_id
               , task_id
               , org_id              --<R12 MOAC>
               , from_subinventory
               , from_locator_id
                )
         VALUES (
                 p_rcv_transaction_rec.receipt_source_code  --receipt source code
               , l_interface_transaction_id                 --interface txn id
               , l_group_id                                 --group id
               , l_user_id                                  --created_by
               , SYSDATE                                    --creation_date
               , l_user_id                                  --last_updated_by
               , SYSDATE                                    --last_update_date
               , l_logon_id                                 --last_update_login
               , 'RCV'                                      --interface_source_code
               , p_rcv_transaction_rec.source_document_code   --source_document_code
               , p_rcv_transaction_rec.destination_type_code  --destination_type_code
               , l_trx_date                                   --transaction_date
               , p_rcv_transaction_rec.transaction_quantity   --quantity
               , p_rcv_transaction_rec.transaction_uom        --unit_of_measure
               , p_rcv_transaction_rec.shipment_header_id     --shipment_header_id
               , p_rcv_transaction_rec.shipment_line_id       --shipment_line_id
               , p_rcv_transaction_rec.substitute_unordered_code  --substitute_unordered_code
               , l_employee_id                                  --employee_id
               , l_parent_transaction_id                        --parent_transaction_id
               , p_rcv_transaction_rec.inspection_status_code   --inspection_status_code
               , p_rcv_transaction_rec.inspection_quality_code  --inspection_quality_code
               , p_rcv_transaction_rec.po_header_id           --po_header_id
               , p_rcv_transaction_rec.po_release_id          --po_release_id
               , p_rcv_transaction_rec.po_line_id             --po_line_id
               , p_rcv_transaction_rec.po_line_location_id    --po_line_location_id
               , p_rcv_transaction_rec.po_distribution_id     --po_distribution_id
               , p_rcv_transaction_rec.po_revision_num        --po_revision_num
               , p_rcv_transaction_rec.po_unit_price          --po_unit_price
               , p_rcv_transaction_rec.currency_code          --currency_code
               , p_rcv_transaction_rec.currency_conversion_rate   --currency_conversion_rate
               , p_rcv_transaction_rec.req_line_id            --requsition_line_id
               , p_rcv_transaction_rec.req_distribution_id    --req_distribution_id
               , p_rcv_transaction_rec.routing_id             --routing_header_id
               , p_rcv_transaction_rec.routing_step_id        --routing_step_id
               , p_rcv_transaction_rec.packing_slip           --packing_slip
               , p_rcv_transaction_rec.vendor_item_number     --vendor_item_num
               , p_rcv_transaction_rec.comments               --comments
               , p_rcv_transaction_rec.attribute_category     --attribute_category
               , p_rcv_transaction_rec.attribute1             --attribute1
               , p_rcv_transaction_rec.attribute2             --attribute2
               , p_rcv_transaction_rec.attribute3             --attribute3
               , p_rcv_transaction_rec.attribute4             --attribute4
               , p_rcv_transaction_rec.attribute5             --attribute5
               , p_rcv_transaction_rec.attribute6             --attribute6
               , p_rcv_transaction_rec.attribute7             --attribute7
               , p_rcv_transaction_rec.attribute8             --attribute8
               , p_rcv_transaction_rec.attribute9             --attribute9
               , p_rcv_transaction_rec.attribute10            --attribute10
               , p_rcv_transaction_rec.attribute11            --attribute11
               , p_rcv_transaction_rec.attribute12            --attribute12
               , p_rcv_transaction_rec.attribute13            --attribute13
               , p_rcv_transaction_rec.attribute14            --attribute14
               , p_rcv_transaction_rec.attribute15            --attribute15
               , p_rcv_transaction_rec.transaction_type       --transaction_type
               , p_rcv_transaction_rec.location_id            --location_id
               , 'PENDING'                                    --processing_status_code
               , l_transaction_mode                           --processing_mode_code
               , 'PENDING'                                    --transaction_status_code
               , p_rcv_transaction_rec.category_id            --category_id
               , p_rcv_transaction_rec.vendor_lot_num         --vendor_lot_num
               , p_rcv_transaction_rec.reason_id              --reason_id
               , p_rcv_transaction_rec.primary_quantity       --primary_quantity
               , p_rcv_transaction_rec.primary_uom            --primary_unit_of_measure
               , g_transfer_uom_code                          --uom_code
               -- OPM COnvergence
               , DECODE(p_rcv_transaction_rec.sec_transaction_quantity, FND_API.G_MISS_NUM, NULL)
               , p_rcv_transaction_rec.secondary_uom
               , p_rcv_transaction_rec.secondary_uom_code
               , p_rcv_transaction_rec.item_id                --item_id
               , p_rcv_transaction_rec.item_revision          --item_revision
               , p_rcv_transaction_rec.to_organization_id     --to_organization_id
               , p_rcv_transaction_rec.deliver_to_location_id   --deliver_to_location_id
               , l_destination_context                        --destination_context
               , p_rcv_transaction_rec.vendor_id              --vendor_id
               , p_rcv_transaction_rec.deliver_to_person_id   --deliver_to_persion_id
               , p_rcv_transaction_rec.subinventory_dsp       --subinventory
               , p_rcv_transaction_rec.locator_id             --locator_id
               , p_rcv_transaction_rec.wip_entity_id          --wip_entity_id
               , p_rcv_transaction_rec.wip_line_id            --wip_line_id
               , p_rcv_transaction_rec.wip_repetitive_schedule_id   --wip_repetitive_schedule_id
               , p_rcv_transaction_rec.wip_operation_seq_num  --wip_operation_seq_num
               , p_rcv_transaction_rec.wip_resource_seq_num   --wip_resource_seq_num
               , l_bom_resource_id                            --bom_resource_id
               , p_rcv_transaction_rec.lot_control_code       --use_mtl_lot
               , p_rcv_transaction_rec.serial_number_control_code    --use_mtl_serial
               , l_movement_id                                  --movement_id
               , l_currency_conv_date                           --currency_conversion_date
               , p_rcv_transaction_rec.currency_conversion_type --currency_conversion_type
               , p_rcv_transaction_rec.qa_collection_id         --qa_collection_id
               , p_rcv_transaction_rec.ussgl_transaction_code   --ussgl_transaction_date
               , p_rcv_transaction_rec.government_context       --government_context
               , p_rcv_transaction_rec.vendor_site_id           --vendor_site_id
               , p_rcv_transaction_rec.oe_order_header_id       --oe_order_header_id
               , p_rcv_transaction_rec.oe_order_line_id         --oe_order_line_id
               , p_rcv_transaction_rec.customer_id              --customer_id
               , p_rcv_transaction_rec.customer_site_id         --customer_site_id
               , p_rcv_transaction_rec.put_away_rule_id         --put_away_rule_id
               , p_rcv_transaction_rec.put_away_strategy_id     --put_away_strategy_id
               , p_rcv_transaction_rec.lpn_id                   --lpn_id
               , p_rcv_transaction_rec.transfer_lpn_id          --transfer_lpn_id
               , p_rcv_transaction_rec.cost_group_id            --cost_group_id
               , p_rcv_transaction_rec.mmtt_temp_id             --mmtt_temp_id
               , 'Y'                                            --mobile_txn
               , p_rcv_transaction_rec.transfer_cost_group_id   --transfer_cost_group_id
               , l_validation_flag                              --validation_flag
               , l_lpn_group_id                                 --lpn_group_id
               , l_project_id                                   --project_id
               , l_task_id                                      --task_id
               , l_operating_unit_id      --<R12 MOAC>
               ,  p_rcv_transaction_rec.from_subinventory_code  --for matching non-lpn materials
               ,  p_rcv_transaction_rec.from_locator_id         --for matching non-lpn materials
                );
   EXCEPTION
      WHEN OTHERS THEN
	 print_debug('Error inserting into RTI. SQLCODE:'||SQLCODE||' SQLERRM:'||Sqlerrm,1);
	 RAISE FND_API.G_EXC_ERROR;
   END;

    IF (l_debug = 1) THEN
      print_debug('insert_interface_code completed successfully. Generated RTID: ' || l_interface_transaction_id, 4);
    END IF;

    RETURN l_interface_transaction_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error (
          'INV_RCV_STD_TRANSFER_APIS.INSERT_INTERFACE_CODE', 10, SQLCODE);
      END IF;
      RETURN -9999;
  END insert_interface_code;

 /*----------------------------------------------------------------------------*
  * PROCEDURE: populate_transfer_rti_values
  * Description:
  *   Accept the parent transaction record and calculate other values for RTI
  *   Populate the RTI record corresponding to TRANSFER
  *   Call the helper routine to insert the RTI record
  *   Update the Lots and serial interface records with the RTI record created
  *
  * Output Parameters:
  *    x_return_status
  *      Return status indicating Success (S), Error (E), Unexpected Error (U)
  *    x_msg_count
  *      Number of messages in  message list
  *    x_msg_data
  *      Stacked messages text
  *
  * Input Parameters:
  *    p_rcv_transaction_rec - Record type for RTI with quantities initialized
  *    p_rcvtxn_rec          - Record type for the parent RCV Transaction
  *    p_parent_txn_id       - Transaction ID of the parent transaction
  *    p_organization_id     - Organization ID
  *    p_item_id             - Item ID
  *    p_revision            - Item Revision
  *    p_subinventory_code   - Destination receiving subinventory code
  *    p_locator_id          - Destination receiving locator ID
  *    p_lot_control_code    - Lot Control Code of the item
  *    p_serial_control_code - Serial Control Code of the item
  *    p_original_rti_id     - Interface Transaction Id for lot/serial split
  *    p_original_temp_id    - Transaction Temp ID of the MMTT being putaway
  *    p_lpn_id              - LPN ID of the move order line
  *    p_transfer_lpn_id     - LPN ID of the LPN being dropped into
  *    p_doc_type            - Document Type (PO/RMA/INTSHIP)
  *
  * Returns: NONE
  *---------------------------------------------------------------------------*/
  PROCEDURE populate_transfer_rti_values (
      x_return_status       OUT NOCOPY    VARCHAR2
    , x_msg_count           OUT NOCOPY    NUMBER
    , x_msg_data            OUT NOCOPY    VARCHAR2
    , p_rcv_transaction_rec IN OUT NOCOPY INV_RCV_STD_DELIVER_APIS.rcvtxn_transaction_rec_tp
    , p_rcvtxn_rec          IN OUT NOCOPY INV_RCV_STD_DELIVER_APIS.rcvtxn_enter_rec_cursor_rec
    , p_parent_txn_id       IN            NUMBER
    , p_organization_id     IN            NUMBER
    , p_item_id             IN            NUMBER
    , p_revision            IN            VARCHAR2
    , p_subinventory_code   IN            VARCHAR2
    , p_locator_id          IN            NUMBER
    , p_lot_control_code    IN            NUMBER
    , p_serial_control_code IN            NUMBER
    , p_original_rti_id     IN            NUMBER    DEFAULT NULL
    , p_original_temp_id    IN            NUMBER    DEFAULT NULL
    , p_lpn_id              IN            NUMBER    DEFAULT NULL
    , p_transfer_lpn_id     IN            NUMBER    DEFAULT NULL
    , p_doc_type            IN            VARCHAR2  DEFAULT NULL ) IS

    --Local variables
    l_content_lpn_id              NUMBER; --Content LPN ID
    l_lpn_controlled_flag         NUMBER;
    l_interface_txn_id            NUMBER;
    l_location_id                 NUMBER;
    l_msni_count                  NUMBER := 0;
    l_progress                    NUMBER;       --Index to track progress and log error
    l_debug                       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN

    --Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := 10;

    IF (l_debug = 1) THEN
      print_debug('***Entered populate_transfer_rti_values***: ' || l_progress || ' '
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    --First fetch the values for RTI from the original MMTT record
    p_rcv_transaction_rec.mmtt_temp_id := p_original_temp_id;

    BEGIN
      SELECT    cost_group_id
              , put_away_rule_id
              , put_away_strategy_id
      INTO      p_rcv_transaction_rec.cost_group_id
              , p_rcv_transaction_rec.put_away_rule_id
              , p_rcv_transaction_rec.put_away_strategy_id
      FROM      mtl_material_transactions_temp
      WHERE     transaction_temp_id = p_original_temp_id;
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          print_debug('Could not fetch original MMTT info. Maybe not passed', 4);
        END IF;
    END;

    l_progress := 20;

    BEGIN
      SELECT  cost_group_id
      INTO    p_rcv_transaction_rec.transfer_cost_group_id
      FROM    rcv_shipment_lines
      WHERE   shipment_line_id = p_rcvtxn_rec.shipment_line_id;
    EXCEPTION
      WHEN OTHERS THEN
        p_rcv_transaction_rec.transfer_cost_group_id := NULL;
    END;

    IF (l_debug = 1) THEN
      print_debug('***Columns fetched from the original MMTT record***', 4);
      print_debug('   Orignal Temp ID: ' || p_rcv_transaction_rec.mmtt_temp_id, 4);
      print_debug('   cost_group_id: ' || p_rcv_transaction_rec.cost_group_id, 4);
      print_debug('   transfer_cost_group_id: ' || p_rcv_transaction_rec.transfer_cost_group_id, 4);
      print_debug('   put_away_rule_id: ' || p_rcv_transaction_rec.put_away_rule_id, 4);
      print_debug('   put_away_strategy_id: ' || p_rcv_transaction_rec.put_away_strategy_id, 4);
      print_debug('   from_subinventory_code : ' || p_rcvtxn_rec.from_subinventory_code, 4);
      print_debug('   from_locator_id : ' || p_rcvtxn_rec.from_locator_id, 4);
    END IF;

    --Now populate the columns from the parent transaction record
    l_progress := 30;

    IF (l_debug = 1) THEN
      print_debug('Defaulting columns from the parent (p_rcvtxn_rec) record', 4);
    END IF;

    p_rcv_transaction_rec.source_document_code        :=  p_rcvtxn_rec.source_document_code;
    p_rcv_transaction_rec.receipt_source_code         :=  p_rcvtxn_rec.receipt_source_code;
    p_rcv_transaction_rec.rcv_transaction_id          :=  p_rcvtxn_rec.rcv_transaction_id;
    p_rcv_transaction_rec.transaction_date            :=  p_rcvtxn_rec.transaction_date;
    p_rcv_transaction_rec.po_header_id                :=  p_rcvtxn_rec.po_header_id;
    p_rcv_transaction_rec.po_revision_num             :=  p_rcvtxn_rec.po_revision_num;
    p_rcv_transaction_rec.po_release_id               :=  p_rcvtxn_rec.po_release_id;
    p_rcv_transaction_rec.vendor_id                   :=  p_rcvtxn_rec.vendor_id;
    p_rcv_transaction_rec.vendor_site_id              :=  p_rcvtxn_rec.vendor_site_id;
    p_rcv_transaction_rec.po_line_id                  :=  p_rcvtxn_rec.po_line_id;
    p_rcv_transaction_rec.po_line_location_id         :=  p_rcvtxn_rec.po_line_location_id;
    p_rcv_transaction_rec.po_unit_price               :=  p_rcvtxn_rec.po_unit_price;
    p_rcv_transaction_rec.category_id                 :=  p_rcvtxn_rec.category_id;
    p_rcv_transaction_rec.employee_id                 :=  p_rcvtxn_rec.employee_id;
    p_rcv_transaction_rec.comments                    :=  p_rcvtxn_rec.comments;
    p_rcv_transaction_rec.req_header_id               :=  p_rcvtxn_rec.req_header_id;
    p_rcv_transaction_rec.req_line_id                 :=  p_rcvtxn_rec.req_line_id;
    p_rcv_transaction_rec.shipment_header_id          :=  p_rcvtxn_rec.shipment_header_id;
    p_rcv_transaction_rec.shipment_line_id            :=  p_rcvtxn_rec.shipment_line_id;
    p_rcv_transaction_rec.packing_slip                :=  p_rcvtxn_rec.packing_slip;
    p_rcv_transaction_rec.government_context          :=  p_rcvtxn_rec.government_context;
    p_rcv_transaction_rec.ussgl_transaction_code      :=  p_rcvtxn_rec.ussgl_transaction_code;
    p_rcv_transaction_rec.inspection_status_code      :=  p_rcvtxn_rec.inspection_status_code;
    p_rcv_transaction_rec.inspection_quality_code     :=  p_rcvtxn_rec.inspection_quality_code;
    p_rcv_transaction_rec.vendor_lot_num              :=  p_rcvtxn_rec.vendor_lot_num;
    p_rcv_transaction_rec.vendor_item_number          :=  p_rcvtxn_rec.vendor_item_number;
    p_rcv_transaction_rec.substitute_unordered_code   :=  p_rcvtxn_rec.substitute_unordered_code;
    p_rcv_transaction_rec.routing_id                  :=  p_rcvtxn_rec.routing_id;
    p_rcv_transaction_rec.routing_step_id             :=  p_rcvtxn_rec.routing_step_id;
    p_rcv_transaction_rec.reason_id                   :=  p_rcvtxn_rec.reason_id;
    p_rcv_transaction_rec.currency_code               :=  p_rcvtxn_rec.currency_code;
    p_rcv_transaction_rec.currency_conversion_rate    :=  p_rcvtxn_rec.currency_conversion_rate;
    p_rcv_transaction_rec.currency_conversion_date    :=  p_rcvtxn_rec.currency_conversion_date;
    p_rcv_transaction_rec.currency_conversion_type    :=  p_rcvtxn_rec.currency_conversion_type;
    p_rcv_transaction_rec.req_distribution_id         :=  p_rcvtxn_rec.req_distribution_id;
    p_rcv_transaction_rec.destination_type_code_hold  :=  p_rcvtxn_rec.destination_type_code_hold;
    p_rcv_transaction_rec.un_number_id                :=  p_rcvtxn_rec.un_number_id;
    p_rcv_transaction_rec.hazard_class_id             :=  p_rcvtxn_rec.hazard_class_id;
    p_rcv_transaction_rec.creation_date               :=  p_rcvtxn_rec.creation_date;
    p_rcv_transaction_rec.attribute_category          :=  p_rcvtxn_rec.attribute_category;
    p_rcv_transaction_rec.attribute1                  :=  p_rcvtxn_rec.attribute1;
    p_rcv_transaction_rec.attribute2                  :=  p_rcvtxn_rec.attribute2;
    p_rcv_transaction_rec.attribute3                  :=  p_rcvtxn_rec.attribute3;
    p_rcv_transaction_rec.attribute4                  :=  p_rcvtxn_rec.attribute4;
    p_rcv_transaction_rec.attribute5                  :=  p_rcvtxn_rec.attribute5;
    p_rcv_transaction_rec.attribute6                  :=  p_rcvtxn_rec.attribute6;
    p_rcv_transaction_rec.attribute7                  :=  p_rcvtxn_rec.attribute7;
    p_rcv_transaction_rec.attribute8                  :=  p_rcvtxn_rec.attribute8;
    p_rcv_transaction_rec.attribute9                  :=  p_rcvtxn_rec.attribute9;
    p_rcv_transaction_rec.attribute10                 :=  p_rcvtxn_rec.attribute10;
    p_rcv_transaction_rec.attribute11                 :=  p_rcvtxn_rec.attribute11;
    p_rcv_transaction_rec.attribute12                 :=  p_rcvtxn_rec.attribute12;
    p_rcv_transaction_rec.attribute13                 :=  p_rcvtxn_rec.attribute13;
    p_rcv_transaction_rec.attribute14                 :=  p_rcvtxn_rec.attribute14;
    p_rcv_transaction_rec.attribute15                 :=  p_rcvtxn_rec.attribute15;
    p_rcv_transaction_rec.qa_collection_id            :=  p_rcvtxn_rec.qa_collection_id;
    p_rcv_transaction_rec.oe_order_header_id          :=  p_rcvtxn_rec.oe_order_header_id;
    p_rcv_transaction_rec.oe_order_line_id            :=  p_rcvtxn_rec.oe_order_line_id;
    p_rcv_transaction_rec.customer_id                 :=  p_rcvtxn_rec.customer_id;
    p_rcv_transaction_rec.customer_site_id            :=  p_rcvtxn_rec.customer_site_id;
    p_rcv_transaction_rec.from_subinventory_code      :=  p_rcvtxn_rec.from_subinventory_code;
    p_rcv_transaction_rec.from_locator_id             :=  p_rcvtxn_rec.from_locator_id;

    p_rcv_transaction_rec.po_distribution_id          :=  NULL;

    --Next, populate the columns from the input parameters
    l_progress := 40;

    IF (l_debug = 1) THEN
      print_debug('Setting the location_id from the subinventory', 4);
    END IF;
    IF (p_subinventory_code IS NOT NULL) THEN
      BEGIN
        SELECT  location_id
        INTO    l_location_id
        FROM    mtl_secondary_inventories
        WHERE   secondary_inventory_name  = p_subinventory_code
        AND     organization_id           = p_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_location_id := p_rcvtxn_rec.location_id;
      END;
    ELSE
      l_location_id := p_rcvtxn_rec.location_id;
    END IF;

    p_rcv_transaction_rec.location_id := l_location_id;

    IF (l_debug = 1) THEN
      print_debug('Defaulting columns from the input parameters', 4);
    END IF;

    p_rcv_transaction_rec.lpn_id              :=  p_lpn_id;
    p_rcv_transaction_rec.transfer_lpn_id     :=  p_transfer_lpn_id;
    p_rcv_transaction_rec.item_id             :=  p_item_id;
    p_rcv_transaction_rec.item_revision       :=  p_revision;
    p_rcv_transaction_rec.subinventory_dsp    :=  p_subinventory_code;
    p_rcv_transaction_rec.locator_id          :=  p_locator_id;
    p_rcv_transaction_rec.to_organization_id  :=  p_organization_id;
    p_rcv_transaction_rec.transaction_date_nb :=  SYSDATE;
    p_rcv_transaction_rec.serial_number_control_code  :=  p_serial_control_code;
    p_rcv_transaction_rec.lot_control_code            :=  p_lot_control_code;

    --Default the rest of the values for an RTI corresponding to Transfer
    --Destination Type and context are 'RECEIVING', transaction type is 'TRANSFER'
    --Delivery To and WIP related columns are NULL
    p_rcv_transaction_rec.transaction_type        :=  'TRANSFER';
    p_rcv_transaction_rec.destination_type_code   :=  'RECEIVING';
    p_rcv_transaction_rec.deliver_to_person_id    :=  NULL;
    p_rcv_transaction_rec.deliver_to_location_id  :=  NULL;
    p_rcv_transaction_rec.wip_entity_id           :=  NULL;
    p_rcv_transaction_rec.wip_line_id             :=  NULL;
    p_rcv_transaction_rec.wip_operation_seq_num   :=  NULL;
    p_rcv_transaction_rec.wip_resource_seq_num    :=  NULL;
    p_rcv_transaction_rec.wip_repetitive_schedule_id  :=  NULL;

    --Now, insert the RCV_TRANSACTIONS_INTERFACE record
    l_progress := 50;

    IF (l_debug = 1) THEN
      print_debug('Inserting the RTI for TRANSFER transaction', 4);
    END IF;

    IF (NVL(inv_rcv_common_apis.g_rcv_global_var.express_mode, 'NO') <> 'YES') THEN
      --Call the helper routine to create the RTI record
      l_interface_txn_id := insert_interface_code (
            p_rcv_transaction_rec   =>  p_rcv_transaction_rec);

      IF (l_debug = 1) THEN
        print_debug('INTERFACE_TXN_ID returned for the RTI: ' || l_interface_txn_id, 4);

        --If the insert fails, return value would be -9999 and so error out
        IF (l_interface_txn_id = -9999) THEN
          IF (l_debug = 1) THEN
            print_debug('Progress: ' || l_progress || '. Failure in RTI creation for Transfer', 4);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      --Update the lots and serials interface records with the RTID that was
      --just generated. For transfer, there will only be one parent transaction.
      --So, we just need to update the product_transaction_id of MTLI and MSNI
      --records (which have a dummy value) with the RTID just created
      l_progress := 60;
      l_msni_count := 0;
      IF (p_lot_control_code = 2) THEN
        IF (p_serial_control_code = 6) THEN
          --First update the lot interface records
          --Bug #3405320
          --We support putaway of serials if the item serial control code is
          --dynamic at SO Issue for int ship/int req documents.
          --Check the number of serials in interface for this transaction
          -- (For other docs, the value of l_msni_count would be 0).
          IF (p_doc_type = 'INTSHIP') THEN
            SELECT count(1)
            INTO   l_msni_count
            FROM   mtl_serial_numbers_interface
            WHERE  product_transaction_id = p_original_rti_id
            AND    product_code = 'RCV';
          END IF;

          IF (l_debug = 1) THEN
            print_debug('Serial control code is 6. doc_type : ' || p_doc_type ||
                        ' . Update MTLI.serial_txn_temp_id TO NULL', 4);
          END IF;
          --Bug #3405320
          --If the document is RMA, do not change serial_transaction_temp_od
          --For other documents, check if serials are populated in MSNI
          --If there are none, NULL out serial_temp_id in MTLI else retain it
          UPDATE  mtl_transaction_lots_interface
          SET     product_transaction_id     = l_interface_txn_id
                , serial_transaction_temp_id = DECODE(p_doc_type, 'RMA', serial_transaction_temp_id,
                                                      decode(l_msni_count, 0, NULL, serial_transaction_temp_id))
          WHERE   product_code               = 'RCV'
          AND     product_transaction_id     = p_original_rti_id;
	      ELSE
	        --First update the lot interface records
	        UPDATE  mtl_transaction_lots_interface
          SET     product_transaction_id  = l_interface_txn_id
          WHERE   product_code            = 'RCV'
          AND     product_transaction_id  = p_original_rti_id;
        END IF;

        IF (l_debug = 1) THEN
          print_debug('Updated ' || SQL%ROWCOUNT || ' lot records', 4);
        END IF;

        --For a lot and serial controlled item, update the MSNI records too
        UPDATE    mtl_serial_numbers_interface
        SET       product_transaction_id  = l_interface_txn_id
        WHERE     product_code            = 'RCV'
        AND       product_transaction_id  = p_original_rti_id;

        IF (l_debug = 1) THEN
          print_debug('Updated ' || SQL%ROWCOUNT || ' serial records', 4);
        END IF;

      ELSIF (p_serial_control_code > 1) THEN
	      --Update the serial interface records
        UPDATE    mtl_serial_numbers_interface
        SET       product_transaction_id  = l_interface_txn_id
        WHERE     product_code            = 'RCV'
        AND       product_transaction_id  = p_original_rti_id;

        IF (l_debug = 1) THEN
          print_debug('Updated ' || SQL%ROWCOUNT || ' serial records', 4);
        END IF;
      END IF;   --END IF p_lot_control_code = 2
    END IF;   --END IF express_mode <> 'YES'

    l_progress := 70;

    IF (l_debug = 1) THEN
      print_debug('***populate_transfer_rti_values completed successfully***', 4);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error (
          'INV_RCV_STD_TRANSFER_APIS.POPULATE_TRANSFER_RTI_VALUES',
          l_progress,
          SQLCODE);
      END IF;
  END populate_transfer_rti_values;

  /*----------------------------------------------------------------------------*
  * PROCEDURE: get_avail_quantity_to_transfer
  * Description: This procedure does the following
  *   a) Validate LPN from rcv_supply for the parent txn
  *   b) Validate Lot from rcv_lots_supply for the parent txn
  *   c) Check the available quantity for the parent transaction
  *   d) Convert the quantity into UOM of MO Line and primary UOM
  *
  * Output Parameters:
  *    x_return_status
  *      Return status indicating Success (S), Error (E), Unexpected Error (U)
  *    x_msg_count
  *      Number of messages in  message list
  *    x_msg_data
  *      Stacked messages text
  *
  * Input Parameters:
  *   p_parent_txn_id       - Parent Txn Id
  *   p_organization_id     - Organization ID
  *   p_item_id             - Item ID
  *   p_lpn_id              - LPN ID of the parent txn
  *   p_lot_number          - Lot Number
  *   p_transfer_quantity   - Quantity selected for transfer
  *   p_transfer_uom_code   - Transaction (MMTT) UOM Code
  *   p_primary_uom_code    - Item's Primary UOM Code
  *   x_avail_transfer_qty  - Quantity available to transfer in Txn UOM
  *   x_avail_primary_qty   - Available transfer quantity in primary UOM
  *
  * Returns: NONE
  *---------------------------------------------------------------------------*/
  PROCEDURE get_avail_quantity_to_transfer(
        x_return_status         OUT NOCOPY  VARCHAR2
      , x_msg_count             OUT NOCOPY  NUMBER
      , x_msg_data              OUT NOCOPY  VARCHAR2
      , p_parent_txn_id         IN          NUMBER
      , p_organization_id       IN          NUMBER
      , p_item_id               IN          NUMBER
      , p_lpn_id                IN          NUMBER
      , p_lot_number            IN          VARCHAR2
      , p_transfer_quantity     IN          NUMBER
      , p_receipt_source_code   IN          VARCHAR2
      , p_transfer_uom_code     IN          VARCHAR2
      , p_primary_uom_code      IN          VARCHAR2
      , x_avail_transfer_qty    OUT NOCOPY  NUMBER
      , x_avail_primary_qty     OUT NOCOPY  NUMBER ) IS

    --Local Variables
    l_parent_txn_id       NUMBER;   --Parent Transaction Id
    l_avail_transfer_qty  NUMBER;   --Quantity available to transfer
    l_avail_primary_qty   NUMBER;   --Quantity in primary UOM
    l_rcvtxn_qty          NUMBER;   --Parent transaction qty
    l_rcvqty_txn_uom      NUMBER;   --Available Qty in txn uom
    l_rcvtxn_uom_code     MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
    l_rcvtxn_uom          MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;
    l_tolerable_qty       NUMBER;
    l_lpn_count           NUMBER;   --Count of RT records for the LPN ID
    l_lot_count           NUMBER;   --Count of RLS records for the given lot

    l_progress            NUMBER;   --Index to track progress and log error
    l_debug               NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);

  BEGIN
    --Initizlize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := 10;

    IF (l_debug = 1) THEN
      print_debug('***Entered get_avail_quantity_to_transfer***' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('Validating LPN in parent txn', 4);
    END IF;

    --Validate the LPN from rcv_supply
    IF (p_lpn_id IS NOT NULL AND p_lpn_id > 0) THEN
      BEGIN
        SELECT  count(1)
        INTO    l_lpn_count
        FROM    rcv_supply rs
        WHERE   rs.rcv_transaction_id = p_parent_txn_id
        AND     rs.lpn_id = p_lpn_id;

        IF l_lpn_count = 0 THEN
          IF (l_debug = 1) THEN
            print_debug('MOL LPN not matching!!!', 4);
          END IF;
          fnd_message.set_name('INV', 'INV_RCV_NO_ROWS');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name('INV', 'INV_RCV_NO_ROWS');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
      END;
    END IF;   --END IF p_lpn_id is NOT NULL

    l_progress := 20;
    IF (l_debug = 1) THEN
      print_debug('Validating Lot in parent txn', 4);
    END IF;

    --Validate the lot number against RCV_LOTS_SUPPLY
    IF (p_lot_number IS NOT NULL) THEN
      BEGIN
        SELECT  count(1)
        INTO    l_lot_count
        FROM    rcv_lots_supply rls
        WHERE   rls.lot_num = p_lot_number
        AND     rls.transaction_id = p_parent_txn_id;

        IF l_lot_count = 0 THEN
          IF (l_debug = 1) THEN
            print_debug('Lot Number not matching!!!', 4);
          END IF;
          fnd_message.set_name('INV', 'INV_RCV_NO_ROWS');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name('INV', 'INV_RCV_NO_ROWS');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
      END;
    END IF;   --END IF p_lot_number is NOT NULL

    l_parent_txn_id := p_parent_txn_id;

    l_progress := 30;
    IF (l_debug = 1) THEN
      print_debug('Calling rcv_quantities_s.get_available_quantity to get transfer qty', 4);
    END IF;

    --Check the quantity available to transfer and the transaction UOM
    rcv_quantities_s.get_available_quantity (
        p_transaction_type        =>  'TRANSFER'
      , p_parent_id               =>  l_parent_txn_id
      , p_receipt_source_code     =>  p_receipt_source_code
      , p_parent_transaction_type =>  NULL
      , p_grand_parent_id         =>  l_parent_txn_id
      , p_correction_type         =>  NULL
      , p_available_quantity      =>  l_rcvtxn_qty
      , p_tolerable_quantity      =>  l_tolerable_qty
      , p_unit_of_measure         =>  l_rcvtxn_uom);

    IF (l_debug = 1) THEN
      print_debug('*** Return Values from get_available_quantity***', 4);
      print_debug('   l_rcvtxn_qty: ' || l_rcvtxn_qty || ' :: l_rcvtxn_uom '
            || l_rcvtxn_uom || ' :: l_tolerable_qty: ' || l_tolerable_qty, 4);
    END IF;

    SELECT  uom_code
    INTO    l_rcvtxn_uom_code
    FROM    mtl_item_uoms_view
    WHERE   organization_id = p_organization_id
    AND     inventory_item_id = p_item_id
    AND     unit_of_measure = l_rcvtxn_uom;

    l_progress := 40;
    IF (l_debug = 1) THEN
      print_debug('Converting l_rcvtxn_qty to transfer UOM', 4);
    END IF;

    --Convert the available quantity from paremt txn UOM to transfer (MOL) UOM
    IF l_rcvtxn_uom_code <> p_transfer_uom_code THEN
      l_rcvqty_txn_uom := inv_convert.inv_um_convert(
            item_id       =>  p_item_id
          , precision     =>  NULL
          , from_quantity =>  l_rcvtxn_qty
          , from_unit     =>  l_rcvtxn_uom_code
          , to_unit       =>  p_transfer_uom_code
          , from_name     =>  NULL
          , to_name       =>  NULL);
    ELSE
      l_rcvqty_txn_uom := l_rcvtxn_qty;
    END IF;

    -- a) If available quantity is 0 then raise the error to indicate match failed
    -- b) If input quantity > available quantity, then raise over tolerance error
    -- c) If input quantity < available quantity, then set transfer quantity to input quantity
    -- d) If input quantity = available quantity, then set transfer quantity to avalable quantity

    IF (l_rcvqty_txn_uom = 0) THEN
      IF (l_debug = 1) THEN
        print_debug('get_avail_quantity_to_transfer: There is no quantity available to transfer: ', 4);
      END IF;
      fnd_message.set_name('INV', 'INV_RCV_NO_ROWS');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_transfer_quantity > l_rcvqty_txn_uom) THEN
      IF (l_debug = 1) THEN
        print_debug('Transfer qty ' || p_transfer_quantity || ' exceeds ' ||
          ' available quantity ' || l_rcvqty_txn_uom, 4);
      END IF;
      fnd_message.set_name('INV', 'INV_RCV_QTY_OVER_TOLERANCE');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_transfer_quantity < l_rcvqty_txn_uom) THEN
      l_avail_transfer_qty := p_transfer_quantity;
    ELSE
      l_avail_transfer_qty := l_rcvqty_txn_uom;
    END IF;

    l_progress := 50;
    IF (l_debug = 1) THEN
      print_debug('Getting transfer quantity in primary UOM', 4);
    END IF;

    --Get the quantity in terms of primary UOM
    IF p_transfer_uom_code <> p_primary_uom_code THEN
      l_avail_primary_qty := inv_convert.inv_um_convert(
            item_id       =>  p_item_id
          , precision     =>  NULL
          , from_quantity =>  l_avail_transfer_qty
          , from_unit     =>  p_transfer_uom_code
          , to_unit       =>  p_primary_uom_code
          , from_name     =>  NULL
          , to_name       =>  NULL);
    ELSE
      l_avail_primary_qty := l_avail_transfer_qty;
    END IF;

    --Set the available quantity values, for both txn uom and primary uom
    x_avail_transfer_qty := l_avail_transfer_qty;
    x_avail_primary_qty := l_avail_primary_qty;

    l_progress := 60;
    IF (l_debug = 1) THEN
      print_debug('get_avail_quantity_to_transfer completed successfully', 4);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error (
          'INV_RCV_STD_TRANSFER_APIS.GET_AVAIL_QTY_TO_TRANSFER',
          l_progress,
          SQLCODE);
      END IF;
  END get_avail_quantity_to_transfer;

 /*-----------------------------------------------------------------------------
  * PROCEDURE: create_po_transfer_rec
  * Description/Processing Logic:
  *   Called when the document source type is a Purchase Order
  *   Fetch the parent transaction values using po line location id
  *   Validate the transfer quantity with rcv_supply for the PO line location
  *   Initialize the RTI record with the quantity and primary quantity
  *   Call the populate_transfer_rti_values rotuine to create the Transfer RTI
  *
  * Output Parameters:
  *    x_return_status
  *      Return status indicating Success (S), Error (E), Unexpected Error (U)
  *    x_msg_count
  *      Number of messages in  message list
  *    x_msg_data
  *      Stacked messages text
  *
  * Input Parameters:
  *    p_organization_id     - Organization ID
  *    p_po_header_id        - PO Header ID
  *    p_po_release_id       - PO Release ID
  *    p_po_line_id          - PO Line ID for the PO line location
  *    p_po_line_location_id - PO Line ID for the PO line location
  *    p_parent_txn_id       - Transaction ID of the parent transaction
  *    p_item_id             - Item Being transferred
  *    p_revision            - Item Revision
  *    p_subinventory_code   - Destination receiving subinventory code
  *    p_locator_id          - Destination receiving locator ID
  *    p_transfer_quantity   - Quantity to be transferred
  *    p_transfer_uom_code   - UOM code of the quantity being tranferred
  *    p_lot_control_code    - Lot Control Code of the item
  *    p_serial_control_code - Serial Control Code of the item
  *    p_original_rti_id     - Interface Transaction Id for lot/serial split
  *    p_original_temp_id    - Transaction Temp ID of the MMTT being putaway
  *    p_lpn_id              - LPN ID of the move order line
  *    p_transfer_lpn_id     - LPN ID of the LPN being dropped into
  *
  * Returns: NONE
  *---------------------------------------------------------------------------*/
  PROCEDURE create_po_transfer_rec (
      x_return_status         OUT NOCOPY  VARCHAR2
    , x_msg_count             OUT NOCOPY  VARCHAR2
    , x_msg_data              OUT NOCOPY  VARCHAR2
    , p_organization_id       IN          NUMBER
    , p_po_header_id          IN          NUMBER
    , p_po_release_id         IN          NUMBER
    , p_po_line_id            IN          NUMBER
    , p_po_line_location_id   IN          NUMBER
    , p_parent_txn_id         IN          NUMBER
    , p_item_id               IN          NUMBER
    , p_revision              IN          VARCHAR2
    , p_subinventory_code     IN          VARCHAR2
    , p_locator_id            IN          NUMBER
    , p_transfer_quantity     IN          NUMBER
    , p_transfer_uom_code     IN          VARCHAR2
    , p_lot_control_code      IN          NUMBER
    , p_serial_control_code   IN          NUMBER
    , p_original_rti_id       IN          NUMBER    DEFAULT NULL
    , p_original_temp_id      IN          NUMBER    DEFAULT NULL
    , p_lot_number            IN          VARCHAR2  DEFAULT NULL
    , p_lpn_id                IN          NUMBER    DEFAULT NULL
    , p_transfer_lpn_id       IN          NUMBER    DEFAULT NULL
    , p_sec_transfer_quantity IN          NUMBER    DEFAULT NULL --OPM Convergence
    , p_sec_transfer_uom_code      IN     VARCHAR2  DEFAULT NULL)--OPM Convergence
    IS
    CURSOR c_rcvtxn_detail( v_rcv_txn_id          NUMBER,
                            v_po_line_location_id NUMBER) IS
      SELECT    rs.from_organization_id         from_organization_id
              , rs.to_organization_id           to_organization_id
              , rt.source_document_code         source_document_code
              , rsh.receipt_source_code         receipt_source_code
              , rs.rcv_transaction_id           rcv_transaction_id
              , rt.transaction_date             transaction_date
              , rt.transaction_type             transaction_type
              , rt.primary_unit_of_measure      primary_unit_of_measure
              , rt.primary_quantity             primary_quantity
              , rs.po_header_id                 po_header_id
              , rt.po_revision_num              po_revision_num
              , rs.po_release_id                po_release_id
              , rsh.vendor_id                   vendor_id
              , rt.vendor_site_id               vendor_site_id
              , rs.po_line_id                   po_line_id
              , rt.po_unit_price                po_unit_price
              , rsl.category_id                 category_id
              , rs.item_id                      item_id
              , msi.serial_number_control_code  serial_number_control_code
              , msi.lot_control_code            lot_control_code
              , rs.item_revision                item_revision
              , rs.po_line_location_id          po_line_location_id
              , to_number(NULL)                 po_distribution_id
              , rt.employee_id                  employee_id
              , rsl.comments                    comments
              , to_number(NULL)                 req_header_id
              , to_number(NULL)                 req_line_id
              , rs.shipment_header_id           shipment_header_id
              , rs.shipment_line_id             shipment_line_id
              , rsh.packing_slip                packing_slip
              , rsl.government_context          government_context
              , rsl.ussgl_transaction_code      ussgl_transaction_code
              , rt.inspection_status_code       inspection_status_code
              , rt.inspection_quality_code      inspectin_quality_code
              , rt.vendor_lot_num               vendor_lot_num
              , pol.vendor_product_num          vendor_item_number
              , rt.substitute_unordered_code    substitute_unordered_code
              , rt.routing_header_id            routing_id
              , rt.routing_step_id              routing_step_id
              , rt.reason_id                    reason_id
              , rt.currency_code                currency_code
              , rt.currency_conversion_rate     currency_conversion_rate
              , rt.currency_conversion_date     currency_conversion_date
              , rt.currency_conversion_type     currency_conversion_type
              , to_number(NULL)                 req_distribution_id
              , rs.destination_type_code        destination_type_code_hold
              , rs.destination_type_code        final_destination_type_code
              , rt.location_id                  location_id
              , to_number(NULL)                 final_deliver_to_person_id
              , to_number(NULL)                 final_deliver_to_location_id
              , rsl.to_subinventory             subinventory
              , NVL(pol.un_number_id,
                    msi.un_number_id)           un_number_id
              , NVL(pol.hazard_class_id,
                    msi.hazard_class_id)        hazard_class_id
              , rs.creation_date                creation_date
              , rt.attribute_category           attribute_category
              , rt.attribute1                   attribute1
              , rt.attribute2                   attribute2
              , rt.attribute3                   attribute3
              , rt.attribute4                   attribute4
              , rt.attribute5                   attribute5
              , rt.attribute6                   attribute6
              , rt.attribute7                   attribute7
              , rt.attribute8                   attribute8
              , rt.attribute9                   attribute9
              , rt.attribute10                  attribute10
              , rt.attribute11                  attribute11
              , rt.attribute12                  attribute12
              , rt.attribute13                  attribute13
              , rt.attribute14                  attribute14
              , rt.attribute15                  attribute15
              , rt.qa_collection_id             qa_collection_id
              , to_number(NULL)                 oe_order_header_id
              , to_number(NULL)                 oe_order_line_id
              , rsh.customer_id                 customer_id
              , rsh.customer_site_id            customer_site_id
              , to_number(NULL)                 wip_entity_id
              , to_number(NULL)                 po_operation_seq_num
              , to_number(NULL)                 po_resource_seq_num
              , to_number(NULL)                 wip_repetitive_schedule_id
              , to_number(NULL)                 wip_line_id
              , to_number(NULL)                 bom_resource_id
              , to_char(NULL)                   final_subinventory
              , rt.secondary_quantity           secondary_quantity --OPM Convergence
              , rt.secondary_unit_of_measure    secondary_uom --OPM Convergence
	      --The following columns are needed for matching in cases where no LPN is involved
	      , rs.to_subinventory              from_subinventory_code
	      , rs.to_locator_id                from_locator_id
      FROM      rcv_transactions      rt
              , rcv_supply            rs
              , rcv_shipment_headers  rsh
              , rcv_shipment_lines    rsl
              , po_lines              pol
              , mtl_system_items      msi
      WHERE     rs.rcv_transaction_id   = v_rcv_txn_id
        AND     rs.to_organization_id   = p_organization_id
        AND     rs.rcv_transaction_id   = rt.transaction_id
        AND     rs.po_line_location_id  = v_po_line_location_id
        AND     rs.shipment_line_id     = rsl.shipment_line_id
        AND     rs.shipment_header_id   = rsh.shipment_header_id
        AND     rs.po_line_id           = pol.po_line_id
        AND     msi.organization_id     = p_organization_id
        AND     msi.inventory_item_id   = rs.item_id;

    --Local variables
    l_parent_transaction_id NUMBER;   --Transaction ID of the parent RT record
    l_con_transfer_qty      NUMBER;   --Qty converted in MOL UOM code
    l_primary_qty           NUMBER;   --Quantity in primay uom code
    l_primary_uom           mtl_units_of_measure.unit_of_measure%TYPE;
    l_transfer_uom          mtl_units_of_measure.unit_of_measure%TYPE;
    l_primary_uom_code      mtl_units_of_measure.uom_code%TYPE;
    l_transfer_uom_code     mtl_units_of_measure.uom_code%TYPE;
    l_rcv_transaction_rec   INV_RCV_STD_DELIVER_APIS.rcvtxn_transaction_rec_tp;
    l_rcvtxn_rec            INV_RCV_STD_DELIVER_APIS.rcvtxn_enter_rec_cursor_rec;
    l_receipt_source_code   RCV_SHIPMENT_HEADERS.RECEIPT_SOURCE_CODE%TYPE;
    l_parent_txn_id         NUMBER;
    l_um_transfer_qty       NUMBER;   --Transfer quantity converted to MOL UOM

    l_progress              NUMBER;   --Index to track progress and log error
    l_debug                 NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);

    --OPM Convergence
    l_sec_transfer_uom_code mtl_units_of_measure.uom_code%TYPE; --OPM Convergence
    l_secondary_uom           mtl_units_of_measure.unit_of_measure%TYPE;
    l_sec_transfer_uom          mtl_units_of_measure.unit_of_measure%TYPE;
    l_secondary_uom_code      mtl_units_of_measure.uom_code%TYPE;
    l_sec_um_xfer_qty       NUMBER;

    l_secondary_qty NUMBER;


  BEGIN

    --Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := 10;

    IF (l_debug = 1) THEN
      print_debug('Entered create_po_transfer_rec: ' || l_progress || ' ' ||
                    TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 3);
      print_debug('************Input parameters are************', 3);
      print_debug('   p_po_header_id       ===> ' || p_po_header_id, 3);
      print_debug('   p_po_release_id       ===> ' || p_po_release_id, 3);
      print_debug('   p_po_line_id          ===> ' || p_po_line_id, 3);
      print_debug('   p_po_line_location_id ===> ' || p_po_line_location_id, 3);
      print_debug('********************************************', 3);
    END IF;

    l_progress := 20;

    IF (l_debug = 1) THEN
      print_debug('Fetching the Units of measure for the item', 4);
    END IF;

    /* Fetch the primary uom, primary uom code and the transfer uom
     * This is needed because receiving works in unit of measure rather
     * than the uom code
     */
    BEGIN

      l_transfer_uom_code := p_transfer_uom_code;
      l_sec_transfer_uom_code := p_sec_transfer_uom_code; --OPM Convergence

      SELECT    primary_unit_of_measure
              , primary_uom_code
          --    , secondary_unit_of_measure
              , secondary_uom_code --OPM Convergence
      INTO      l_primary_uom
              , l_primary_uom_code
           --   , l_secondary_uom ----OPM Convergence
              , l_secondary_uom_code --OPM Convergence
      FROM      mtl_system_items
      WHERE     inventory_item_id = p_item_id
      AND       organization_id   = p_organization_id;

      SELECT    unit_of_measure
      INTO      l_transfer_uom
      FROM      mtl_item_uoms_view
      WHERE     organization_id   = p_organization_id
      AND       inventory_item_id = p_item_id
      AND       uom_code          = l_transfer_uom_code;


      --OPM Convergence
      IF l_sec_transfer_uom_code IS NOT NULL THEN

         SELECT    unit_of_measure
         INTO      l_sec_transfer_uom
         FROM      mtl_item_uoms_view
         WHERE     organization_id   = p_organization_id
         AND       inventory_item_id = p_item_id
         AND       uom_code          = l_sec_transfer_uom_code;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('INV', 'INV-NO ITEM UOM');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
    END;

    l_progress := 30;

    IF (l_debug = 1) THEN
      print_debug('Progress: '|| l_progress || '. Fetching the parent transaction details', 4);
    END IF;

    --Fetch the parent transaction details
    OPEN  c_rcvtxn_detail(p_parent_txn_id, p_po_line_location_id);
    FETCH c_rcvtxn_detail INTO l_rcvtxn_rec;
    CLOSE c_rcvtxn_detail;

    l_progress := 40;

    l_parent_txn_id := p_parent_txn_id;
    l_receipt_source_code := l_rcvtxn_rec.receipt_source_code;

    --Call the common routine to validate the LPN, lot and also fetch the
    --quantity available to transfer
    IF (l_debug = 1) THEN
      print_debug('***Current Progress: ' || l_progress || '. Calling get_avail_quantity_to_transfer with***', 4);
      print_debug('   Primary UOM Code: ' || l_primary_uom_code, 4);
      print_debug('   Transfer UOM Code:' || l_transfer_uom_code, 4);
      print_debug('   Secondary UOM Code:' || l_sec_transfer_uom_code || ' (' || l_sec_transfer_uom || ')', 4);
    END IF;

    get_avail_quantity_to_transfer(
        x_return_status         =>  x_return_status
      , x_msg_count             =>  x_msg_count
      , x_msg_data              =>  x_msg_data
      , p_parent_txn_id         =>  l_parent_txn_id
      , p_organization_id       =>  p_organization_id
      , p_item_id               =>  p_item_id
      , p_lpn_id                =>  p_lpn_id
      , p_lot_number            =>  p_lot_number
      , p_transfer_quantity     =>  p_transfer_quantity
      , p_receipt_source_code   =>  l_receipt_source_code
      , p_transfer_uom_code     =>  l_transfer_uom_code
      , p_primary_uom_code      =>  l_primary_uom_code
      , x_avail_transfer_qty    =>  l_um_transfer_qty
      , x_avail_primary_qty     =>  l_primary_qty);

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_po_transfer_rec at progress level '
          || l_progress || ' . get_avail_quantity_to_transfer raised FND_API.G_EXC_ERROR', 4);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_po_transfer_rec at progress level ' || l_progress
         || ' . get_avail_quantity_to_transfer raised FND_API.G_EXC_UNEXP_ERROR', 4);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* OPM Convergence. Obtain the seondary available to transfer quantity
       using the qty available to transfer in primary uom
      */
    l_sec_um_xfer_qty := inv_convert.inv_um_convert(p_item_id,
                                                    5,
                                                    l_um_transfer_qty,
                                                    l_transfer_uom_code,
                                                    p_sec_transfer_uom_code,
                                                    NULL,
                                                    NULL);
    IF (l_debug = 1) THEN
      print_debug('create_po_transfer_rec: Quantity to transfer (txn uom): ' || l_um_transfer_qty, 4);
      print_debug('Primary Quantity: ' || l_primary_qty ||' Secondary Quantity: ' || l_sec_um_xfer_qty || ' ' || l_secondary_uom_code, 4);
    END IF;

    l_progress := 50;

    --Populate the rcv_transactions_rec record with the quantities and UOMs
    --This is later populated with other values from the parent transaction and MMTT
    l_rcv_transaction_rec.transaction_quantity  :=  l_um_transfer_qty;
    l_rcv_transaction_rec.transaction_uom       :=  l_transfer_uom;
    l_rcv_transaction_rec.primary_quantity      :=  l_primary_qty;
    l_rcv_transaction_rec.primary_uom           :=  l_primary_uom;

    --OPM Convergence
    l_rcv_transaction_rec.sec_transaction_quantity  :=  l_sec_um_xfer_qty;
    l_rcv_transaction_rec.secondary_uom             :=  l_sec_transfer_uom;
    l_rcv_transaction_rec.secondary_uom_code        :=  l_secondary_uom_code;

    --Now call the procedure to create the RTI record for transfer
    l_progress := 60;

    IF (l_debug = 1) THEN
      print_debug('Calling populate_transfer_rti_values', 4);
    END IF;

    populate_transfer_rti_values (
          x_return_status         =>  x_return_status
        , x_msg_count             =>  x_msg_count
        , x_msg_data              =>  x_msg_data
        , p_rcv_transaction_rec   =>  l_rcv_transaction_rec
        , p_rcvtxn_rec            =>  l_rcvtxn_rec
        , p_parent_txn_id         =>  p_parent_txn_id
        , p_organization_id       =>  p_organization_id
        , p_item_id               =>  p_item_id
        , p_revision              =>  p_revision
        , p_subinventory_code     =>  p_subinventory_code
        , p_locator_id            =>  p_locator_id
        , p_lot_control_code      =>  p_lot_control_code
        , p_serial_control_code   =>  p_serial_control_code
        , p_original_rti_id       =>  p_original_rti_id
        , p_original_temp_id      =>  p_original_temp_id
        , p_lpn_id                =>  p_lpn_id
        , p_transfer_lpn_id       =>  p_transfer_lpn_id
        , p_doc_type              =>  'PO');

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_po_transfer_rec at progress level '
          || l_progress || ' . populate_transfer_rti_values raised FND_API.G_EXC_ERROR', 4);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_po_transfer_rec at progress level ' || l_progress
          || ' . populate_transfer_rti_values raised FND_API.G_EXC_UNEXP_ERROR', 4);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := 70;
    IF (l_debug = 1) THEN
      print_debug('***create_po_transfer_rec completed successfully***', 4);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      print_debug('Exception in create_po_transfer_rec ', 4);
      IF c_rcvtxn_detail%ISOPEN THEN
        CLOSE c_rcvtxn_detail;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      print_debug('Unexpected Exception in create_po_transfer_rec ', 4);
      IF c_rcvtxn_detail%ISOPEN THEN
        CLOSE c_rcvtxn_detail;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN OTHERS THEN
      print_debug('Other Exception in create_po_transfer_rec '||SQLERRM, 4);
      IF c_rcvtxn_detail%ISOPEN THEN
        CLOSE c_rcvtxn_detail;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error (
          'INV_RCV_STD_TRANSFER_APIS.CREATE_PO_TRANSFER_REC',
          l_progress,
          SQLCODE);
      END IF;
  END create_po_transfer_rec;


 /*-----------------------------------------------------------------------------
  * PROCEDURE: create_int_ship_transfer_rec
  * Description/Processing Logic:
  *   Called when the document source type is Internal Req/ Intransit Ship
  *   Fetch the parent transaction values using shipment line
  *   Validate the transfer quantity with rcv_supply for the shipment line
  *   Initialize the RTI record with the quantity and primary quantity
  *   Call the populate_transfer_rti_values rotuine to create the Transfer RTI
  *
  * Output Parameters:
  *    x_return_status
  *      Return status indicating Success (S), Error (E), Unexpected Error (U)
  *    x_msg_count
  *      Number of messages in  message list
  *    x_msg_data
  *      Stacked messages text
  *
  * Input Parameters:
  *    p_organization_id     - Organization ID
  *    p_shipment_header_id  - PO Header ID
  *    p_shipment_line_id    - PO Line ID for the PO line location
  *    p_parent_txn_id       - Transaction ID of the parent transaction
  *    p_item_id             - Item Being transferred
  *    p_revision            - Item Revision
  *    p_subinventory_code   - Destination receiving subinventory code
  *    p_locator_id          - Destination receiving locator ID
  *    p_transfer_quantity   - Quantity to be transferred
  *    p_transfer_uom_code   - UOM code of the quantity being tranferred
  *    p_lot_control_code    - Lot Control Code of the item
  *    p_serial_control_code - Serial Control Code of the item
  *    p_original_rti_id     - Interface Transaction Id for lot/serial split
  *    p_original_temp_id    - Transaction Temp ID of the MMTT being putaway
  *    p_lpn_id              - LPN ID of the move order line
  *    p_transfer_lpn_id     - LPN ID of the LPN being dropped into
  *
  * Returns: NONE
  *---------------------------------------------------------------------------*/
  PROCEDURE create_int_ship_transfer_rec (
      x_return_status         OUT NOCOPY  VARCHAR2
    , x_msg_count             OUT NOCOPY  VARCHAR2
    , x_msg_data              OUT NOCOPY  VARCHAR2
    , p_organization_id       IN          NUMBER
    , p_shipment_header_id    IN          NUMBER
    , p_shipment_line_id      IN          NUMBER
    , p_parent_txn_id         IN          NUMBER
    , p_item_id               IN          NUMBER
    , p_revision              IN          VARCHAR2
    , p_subinventory_code     IN          VARCHAR2
    , p_locator_id            IN          NUMBER
    , p_transfer_quantity     IN          NUMBER
    , p_transfer_uom_code     IN          VARCHAR2
    , p_lot_control_code      IN          NUMBER
    , p_serial_control_code   IN          NUMBER
    , p_original_rti_id       IN          NUMBER    DEFAULT NULL
    , p_original_temp_id      IN          NUMBER    DEFAULT NULL
    , p_lot_number            IN          VARCHAR2  DEFAULT NULL
    , p_lpn_id                IN          NUMBER    DEFAULT NULL
    , p_transfer_lpn_id       IN          NUMBER    DEFAULT NULL
    , p_sec_transfer_quantity IN          NUMBER    DEFAULT NULL --OPM Convergence
    , p_sec_transfer_uom_code      IN     VARCHAR2  DEFAULT NULL)--OPM Convergence
     IS
    CURSOR c_rcvtxn_detail( v_rcv_txn_id        NUMBER,
                            v_shipment_line_id  NUMBER) IS
      SELECT    rs.from_organization_id         from_organization_id
              , rs.to_organization_id           to_organization_id
              , rt.source_document_code         source_document_code
              , rsh.receipt_source_code         receipt_source_code
              , rs.rcv_transaction_id           rcv_transaction_id
              , rt.transaction_date             transaction_date
              , rt.transaction_type             transaction_type
              , rt.primary_unit_of_measure      primary_unit_of_measure
              , rt.primary_quantity             primary_quantity
              , to_number(NULL)                 po_header_id
              , to_number(NULL)                 po_revision_num
              , to_number(NULL)                 po_release_id
              , rsh.vendor_id                   vendor_id
              , rt.vendor_site_id               vendor_site_id
              , to_number(NULL)                 po_line_id
              , to_number(NULL)                po_unit_price
              , rsl.category_id                 category_id
              , rs.item_id                      item_id
              , msi.serial_number_control_code  serial_number_control_code
              , msi.lot_control_code            lot_control_code
              , rs.item_revision                item_revision
              , to_number(NULL)                 po_line_location_id
              , to_number(NULL)                 po_distribution_id
              , rt.employee_id                  employee_id
              , rsl.comments                    comments
              , to_number(NULL)                 req_header_id
              , to_number(NULL)                 req_line_id
              , rs.shipment_header_id           shipment_header_id
              , rs.shipment_line_id             shipment_line_id
              , rsh.packing_slip                packing_slip
              , rsl.government_context          government_context
              , rsl.ussgl_transaction_code      ussgl_transaction_code
              , rt.inspection_status_code       inspection_status_code
              , rt.inspection_quality_code      inspectin_quality_code
              , rt.vendor_lot_num               vendor_lot_num
              , ''                              vendor_item_number
              , rt.substitute_unordered_code    substitute_unordered_code
              , rt.routing_header_id            routing_id
              , rt.routing_step_id              routing_step_id
              , rt.reason_id                    reason_id
              , rt.currency_code                currency_code
              , rt.currency_conversion_rate     currency_conversion_rate
              , rt.currency_conversion_date     currency_conversion_date
              , rt.currency_conversion_type     currency_conversion_type
              , rsl.req_distribution_id         req_distribution_id
              , rs.destination_type_code        destination_type_code_hold
              , rs.destination_type_code        final_destination_type_code
              , rt.location_id                  location_id
              , to_number(NULL)                 final_deliver_to_person_id
              , to_number(NULL)                 final_deliver_to_location_id
              , rsl.to_subinventory             subinventory
              , msi.un_number_id                un_number_id
              , msi.hazard_class_id             hazard_class_id
              , rs.creation_date                creation_date
              , rt.attribute_category           attribute_category
              , rt.attribute1                   attribute1
              , rt.attribute2                   attribute2
              , rt.attribute3                   attribute3
              , rt.attribute4                   attribute4
              , rt.attribute5                   attribute5
              , rt.attribute6                   attribute6
              , rt.attribute7                   attribute7
              , rt.attribute8                   attribute8
              , rt.attribute9                   attribute9
              , rt.attribute10                  attribute10
              , rt.attribute11                  attribute11
              , rt.attribute12                  attribute12
              , rt.attribute13                  attribute13
              , rt.attribute14                  attribute14
              , rt.attribute15                  attribute15
              , rt.qa_collection_id             qa_collection_id
              , to_number(NULL)                 oe_order_header_id
              , to_number(NULL)                 oe_order_line_id
              , rsh.customer_id                 customer_id
              , rsh.customer_site_id            customer_site_id
              , to_number(NULL)                 wip_entity_id
              , to_number(NULL)                 po_operation_seq_num
              , to_number(NULL)                 po_resource_seq_num
              , to_number(NULL)                 wip_repetitive_schedule_id
              , to_number(NULL)                 wip_line_id
              , to_number(NULL)                 bom_resource_id
              , to_char(NULL)                   final_subinventory
              , rt.secondary_quantity           secondary_quantity --OPM Convergence
              , rt.secondary_unit_of_measure    secondary_uom --OPM Convergence
	      --The following columns are needed for matching in cases where no LPN is involved
	      , rs.to_subinventory              from_subinventory_code
	      , rs.to_locator_id                from_locator_id
      FROM      rcv_transactions      rt
              , rcv_supply            rs
              , rcv_shipment_headers  rsh
              , rcv_shipment_lines    rsl
              , mtl_system_items      msi
      WHERE     rs.rcv_transaction_id = v_rcv_txn_id
        AND     rs.to_organization_id = p_organization_id
        AND     rs.rcv_transaction_id = rt.transaction_id
        AND     rs.shipment_line_id   = v_shipment_line_id
        AND     rs.shipment_line_id   = rsl.shipment_line_id
        AND     rs.shipment_header_id = rsh.shipment_header_id
        AND     msi.organization_id   = p_organization_id
        AND     msi.inventory_item_id = rs.item_id;

    --Local variables
    l_parent_transaction_id NUMBER;   --Transaction ID of the parent RT record
    l_con_transfer_qty      NUMBER;   --Qty converted in MOL UOM code
    l_primary_qty           NUMBER;   --Quantity in primay uom code
    l_primary_uom           mtl_units_of_measure.unit_of_measure%TYPE;
    l_transfer_uom          mtl_units_of_measure.unit_of_measure%TYPE;
    l_primary_uom_code      mtl_units_of_measure.uom_code%TYPE;
    l_transfer_uom_code     mtl_units_of_measure.uom_code%TYPE;
    l_rcv_transaction_rec   INV_RCV_STD_DELIVER_APIS.rcvtxn_transaction_rec_tp;
    l_rcvtxn_rec            INV_RCV_STD_DELIVER_APIS.rcvtxn_enter_rec_cursor_rec;
    l_receipt_source_code   RCV_SHIPMENT_HEADERS.RECEIPT_SOURCE_CODE%TYPE;
    l_parent_txn_id         NUMBER;
    l_um_transfer_qty       NUMBER;   --Transfer quantity converted to MOL UOM
    l_progress              NUMBER;   --Index to track progress and log error
    l_debug                 NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
    --OPM Convergence
    l_sec_transfer_uom_code mtl_units_of_measure.uom_code%TYPE; --OPM Convergence
    l_secondary_uom           mtl_units_of_measure.unit_of_measure%TYPE;
    l_sec_transfer_uom          mtl_units_of_measure.unit_of_measure%TYPE;
    l_secondary_uom_code      mtl_units_of_measure.uom_code%TYPE;
    l_sec_um_xfer_qty       NUMBER;

    l_secondary_qty NUMBER;
  BEGIN

    l_progress := 10;

    --Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (l_debug = 1) THEN
      print_debug('Entered create_int_ship_transfer_rec: ' || l_progress || ' ' ||
                  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 3);
      print_debug('************Input parameters are************', 3);
      print_debug('   p_shipment_header_id   ===> ' || p_shipment_header_id, 3);
      print_debug('   p_shipment_line_id     ===> ' || p_shipment_line_id, 3);
      print_debug('********************************************', 3);
    END IF;

    l_progress := 20;

    IF (l_debug = 1) THEN
      print_debug('Fetching the units of measure for the item', 4);
    END IF;

    --Fetch the primary uom, primary uom code and transaction uom for the item
    --This is because receiving works unit of measure than uom code
    BEGIN
      l_transfer_uom_code := p_transfer_uom_code;
      l_sec_transfer_uom_code := p_sec_transfer_uom_code;

      SELECT    primary_unit_of_measure
              , primary_uom_code
           --   , secondary_unit_of_measure
              , secondary_uom_code
     INTO      l_primary_uom
              , l_primary_uom_code
         ---     , l_secondary_uom
              , l_secondary_uom_code
      FROM      mtl_system_items
      WHERE     inventory_item_id = p_item_id
      AND       organization_id   = p_organization_id;

      SELECT    unit_of_measure
      INTO      l_transfer_uom
      FROM      mtl_item_uoms_view
      WHERE     inventory_item_id = p_item_id
      AND       organization_id   = p_organization_id
      AND       uom_code          = l_transfer_uom_code;

      --OPM Convergence
      IF l_sec_transfer_uom_code IS NOT NULL THEN

         SELECT    unit_of_measure
         INTO      l_sec_transfer_uom
         FROM      mtl_item_uoms_view
         WHERE     inventory_item_id = p_item_id
         AND       organization_id   = p_organization_id
         AND       uom_code          = l_sec_transfer_uom_code;

      END IF;

   EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('INV', 'INV-NO ITEM UOM');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
    END;

    l_progress := 30;

    IF (l_debug = 1) THEN
      print_debug('Progress: ' || l_progress || '. Fetching parent txn details', 4);
    END IF;

    OPEN  c_rcvtxn_detail(p_parent_txn_id, p_shipment_line_id);
    FETCH c_rcvtxn_detail INTO l_rcvtxn_rec;
    CLOSE c_rcvtxn_detail;

    l_progress := 40;

    l_parent_txn_id := p_parent_txn_id;
    l_receipt_source_code := l_rcvtxn_rec.receipt_source_code;

    --Call the routine to validate LPN, lot, fetch the quantity available
    --to transfer in transaction and primary uom
    IF (l_debug = 1) THEN
      print_debug('***Current Progress: ' || l_progress || '. Calling get_avail_quantity_to_transfer with***', 4);
      print_debug('   Primary UOM Code: ' || l_primary_uom_code, 4);
      print_debug('   Transfer UOM Code: ' || l_transfer_uom_code, 4);
      print_debug('   Secondary UOM Code:' || l_sec_transfer_uom_code || ' (' || l_sec_transfer_uom || ')', 4);
    END IF;

    get_avail_quantity_to_transfer (
        x_return_status       =>  x_return_status
      , x_msg_count           =>  x_msg_count
      , x_msg_data            =>  x_msg_data
      , p_parent_txn_id       =>  p_parent_txn_id
      , p_organization_id     =>  p_organization_id
      , p_item_id             =>  p_item_id
      , p_lpn_id              =>  p_lpn_id
      , p_lot_number          =>  p_lot_number
      , p_transfer_quantity   =>  p_transfer_quantity
      , p_receipt_source_code =>  l_receipt_source_code
      , p_transfer_uom_code   =>  l_transfer_uom_code
      , p_primary_uom_code    =>  l_primary_uom_code
      , x_avail_transfer_qty  =>  l_um_transfer_qty
      , x_avail_primary_qty   =>  l_primary_qty);

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_int_ship_transfer_rec at progress: ' ||
          l_progress || '. get_avail_quantity_to_transfer returned FND_API.G_EXC_ERROR', 9);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_int_ship_transfer_rec at progress: ' ||
          l_progress || '. get_avail_quantity_to_transfer returned FND_API.G_EXC_UNEXPECTED_ERROR', 4);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* OPM Convergence. Obtain the seondary available to transfer quantity
       using the qty available to transfer in primary uom
      */
    l_sec_um_xfer_qty := inv_convert.inv_um_convert(p_item_id,
                                                    5,
                                                    l_um_transfer_qty,
                                                    l_transfer_uom_code,
                                                    p_sec_transfer_uom_code,
                                                    NULL,
                                                    NULL);


    IF (l_debug = 1) THEN
      print_debug('create_int_ship_transfer_rec: Quantity to transfer (txn uom) ' || l_um_transfer_qty, 4);
      print_debug('Primary Quantity: ' || l_primary_qty ||' Secondary Quantity: ' || l_sec_um_xfer_qty || ' ' || l_secondary_uom_code, 4);
    END IF;

    l_progress := 50;

    --Populate the rcv_transactions_rec record with the quantities and UOMs
    --This is later populated with other values from the parent transaction and MMTT
    l_rcv_transaction_rec.transaction_quantity  :=  l_um_transfer_qty;
    l_rcv_transaction_rec.transaction_uom       :=  l_transfer_uom;
    l_rcv_transaction_rec.primary_quantity      :=  l_primary_qty;
    l_rcv_transaction_rec.primary_uom           :=  l_primary_uom;
    --OPM Convergence
    l_rcv_transaction_rec.sec_transaction_quantity  :=  l_sec_um_xfer_qty;
    l_rcv_transaction_rec.secondary_uom             :=  l_sec_transfer_uom;
    l_rcv_transaction_rec.secondary_uom_code        :=  l_secondary_uom_code;



    --Now create the RTI record for Transfer for Int Ship
    populate_transfer_rti_values (
        x_return_status         =>  x_return_status
      , x_msg_count             =>  x_msg_count
      , x_msg_data              =>  x_msg_data
      , p_rcv_transaction_rec   =>  l_rcv_transaction_rec
      , p_rcvtxn_rec            =>  l_rcvtxn_rec
      , p_parent_txn_id         =>  p_parent_txn_id
      , p_organization_id       =>  p_organization_id
      , p_item_id               =>  p_item_id
      , p_revision              =>  p_revision
      , p_subinventory_code     =>  p_subinventory_code
      , p_locator_id            =>  p_locator_id
      , p_lot_control_code      =>  p_lot_control_code
      , p_serial_control_code   =>  p_serial_control_code
      , p_original_rti_id       =>  p_original_rti_id
      , p_original_temp_id      =>  p_original_temp_id
      , p_lpn_id                =>  p_lpn_id
      , p_transfer_lpn_id       =>  p_transfer_lpn_id
      , p_doc_type              =>  'INTSHIP');

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_int_ship_transfer_rec at progress level '
          || l_progress || ' . populate_transfer_rti_values raised FND_API.G_EXC_ERROR', 4);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_int_ship_transfer_rec at progress level '
          || l_progress || ' . populate_transfer_rti_values raised FND_API.G_EXC_UNEXP_ERROR', 4);
      END IF;
    END IF;

    l_progress := 60;

    IF (l_debug = 1) THEN
      print_debug('***create_int_ship_transfer_rec completed succesfully ***', 4);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF c_rcvtxn_detail%ISOPEN THEN
        CLOSE c_rcvtxn_detail;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF c_rcvtxn_detail%ISOPEN THEN
        CLOSE c_rcvtxn_detail;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN OTHERS THEN
      IF c_rcvtxn_detail%ISOPEN THEN
        CLOSE c_rcvtxn_detail;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error (
          'INV_RCV_STD_TRANSFER_APIS.CREATE_INT_SHIP_TRANSFER_REC',
          l_progress,
          SQLCODE);
      END IF;
  END create_int_ship_transfer_rec;


 /*-----------------------------------------------------------------------------
  * PROCEDURE: create_rma_transfer_rec
  * Description/Processing Logic:
  *   Called when the document source type is a RMA
  *   Fetch the parent transaction values using order line ID
  *   Validate the transfer quantity with rcv_supply for the parent transaction
  *   Initialize the RTI record with the quantity and primary quantity
  *   Call the populate_transfer_rti_values rotuine to create the Transfer RTI
  *
  * Output Parameters:
  *    x_return_status
  *      Return status indicating Success (S), Error (E), Unexpected Error (U)
  *    x_msg_count
  *      Number of messages in  message list
  *    x_msg_data
  *      Stacked messages text
  *
  * Input Parameters:
  *    p_organization_id     - Organization ID
  *    p_oe_order_header_id  - Sales Order Header ID
  *    p_oe_order_line_id    - Sales Order Line ID
  *    p_parent_txn_id       - Transaction ID of the parent transaction
  *    p_item_id             - Item Being transferred
  *    p_revision            - Item Revision
  *    p_subinventory_code   - Destination receiving subinventory code
  *    p_locator_id          - Destination receiving locator ID
  *    p_transfer_quantity   - Quantity to be transferred
  *    p_transfer_uom_code   - UOM code of the quantity being tranferred
  *    p_lot_control_code    - Lot Control Code of the item
  *    p_serial_control_code - Serial Control Code of the item
  *    p_original_rti_id     - Interface Transaction Id for lot/serial split
  *    p_original_temp_id    - Transaction Temp ID of the MMTT being putaway
  *    p_lpn_id              - LPN ID of the move order line
  *    p_transfer_lpn_id     - LPN ID of the LPN being dropped into
  *
  * Returns: NONE
  *---------------------------------------------------------------------------*/
  PROCEDURE create_rma_transfer_rec (
      x_return_status         OUT NOCOPY  VARCHAR2
    , x_msg_count             OUT NOCOPY  VARCHAR2
    , x_msg_data              OUT NOCOPY  VARCHAR2
    , p_organization_id       IN          NUMBER
    , p_oe_order_header_id    IN          NUMBER
    , p_oe_order_line_id      IN          NUMBER
    , p_parent_txn_id         IN          NUMBER
    , p_item_id               IN          NUMBER
    , p_revision              IN          VARCHAR2
    , p_subinventory_code     IN          VARCHAR2
    , p_locator_id            IN          NUMBER
    , p_transfer_quantity     IN          NUMBER
    , p_transfer_uom_code     IN          VARCHAR2
    , p_lot_control_code      IN          NUMBER
    , p_serial_control_code   IN          NUMBER
    , p_original_rti_id       IN          NUMBER    DEFAULT NULL
    , p_original_temp_id      IN          NUMBER    DEFAULT NULL
    , p_lot_number            IN          VARCHAR2  DEFAULT NULL
    , p_lpn_id                IN          NUMBER    DEFAULT NULL
    , p_transfer_lpn_id       IN          NUMBER    DEFAULT NULL
    , p_sec_transfer_quantity IN          NUMBER    DEFAULT NULL --OPM Convergence
    , p_sec_transfer_uom_code IN          VARCHAR2  DEFAULT NULL--OPM Convergence
     ) IS
    CURSOR c_rcvtxn_detail( v_rcv_txn_id        NUMBER,
                            v_oe_order_line_id  NUMBER) IS
      SELECT    rs.from_organization_id         from_organization_id
              , rs.to_organization_id           to_organization_id
              , rt.source_document_code         source_document_code
              , rsh.receipt_source_code         receipt_source_code
              , rs.rcv_transaction_id           rcv_transaction_id
              , rt.transaction_date             transaction_date
              , rt.transaction_type             transaction_type
              , rt.primary_unit_of_measure      primary_unit_of_measure
              , rt.primary_quantity             primary_quantity
              , to_number(NULL)                 po_header_id
              , to_number(NULL)                 po_revision_num
              , to_number(NULL)                 po_release_id
              , rsh.vendor_id                   vendor_id
              , rt.vendor_site_id               vendor_site_id
              , to_number(NULL)                 po_line_id
              , to_number(NULL)                 po_unit_price
              , rsl.category_id                 category_id
              , rs.item_id                      item_id
              , msi.serial_number_control_code  serial_number_control_code
              , msi.lot_control_code            lot_control_code
              , rs.item_revision                item_revision
              , to_number(NULL)                 po_line_location_id
              , to_number(NULL)                 po_distribution_id
              , rt.employee_id                  employee_id
              , rsl.comments                    comments
              , to_number(NULL)                 req_header_id
              , to_number(NULL)                 req_line_id
              , rs.shipment_header_id           shipment_header_id
              , rs.shipment_line_id             shipment_line_id
              , rsh.packing_slip                packing_slip
              , rsl.government_context          government_context
              , rsl.ussgl_transaction_code      ussgl_transaction_code
              , rt.inspection_status_code       inspection_status_code
              , rt.inspection_quality_code      inspectin_quality_code
              , rt.vendor_lot_num               vendor_lot_num
              , ''                              vendor_item_number
              , rt.substitute_unordered_code    substitute_unordered_code
              , rt.routing_header_id            routing_id
              , rt.routing_step_id              routing_step_id
              , rt.reason_id                    reason_id
              , rt.currency_code                currency_code
              , rt.currency_conversion_rate     currency_conversion_rate
              , rt.currency_conversion_date     currency_conversion_date
              , rt.currency_conversion_type     currency_conversion_type
              , rsl.req_distribution_id         req_distribution_id
              , rs.destination_type_code        destination_type_code_hold
              , to_number(NULL)                 final_destination_type_code
              , rt.location_id                  location_id
              , to_number(NULL)                 final_deliver_to_person_id
              , to_number(NULL)                 final_deliver_to_location_id
              , rsl.to_subinventory             subinventory
              , msi.un_number_id                un_number_id
              , msi.hazard_class_id             hazard_class_id
              , rs.creation_date                creation_date
              , rt.attribute_category           attribute_category
              , rt.attribute1                   attribute1
              , rt.attribute2                   attribute2
              , rt.attribute3                   attribute3
              , rt.attribute4                   attribute4
              , rt.attribute5                   attribute5
              , rt.attribute6                   attribute6
              , rt.attribute7                   attribute7
              , rt.attribute8                   attribute8
              , rt.attribute9                   attribute9
              , rt.attribute10                  attribute10
              , rt.attribute11                  attribute11
              , rt.attribute12                  attribute12
              , rt.attribute13                  attribute13
              , rt.attribute14                  attribute14
              , rt.attribute15                  attribute15
              , rt.qa_collection_id             qa_collection_id
              , rs.oe_order_header_id           oe_order_header_id
              , rs.oe_order_line_id             oe_order_line_id
              , rsh.customer_id                 customer_id
              , rsh.customer_site_id            customer_site_id
              , to_number(NULL)                 wip_entity_id
              , to_number(NULL)                 po_operation_seq_num
              , to_number(NULL)                 po_resource_seq_num
              , to_number(NULL)                 wip_repetitive_schedule_id
              , to_number(NULL)                 wip_line_id
              , to_number(NULL)                 bom_resource_id
              , to_char(NULL)                   final_subinventory
              , rt.secondary_quantity           secondary_quantity --OPM Convergence
              , rt.secondary_unit_of_measure    secondary_uom --OPM Convergence
	      --The following columns are needed for matching in cases where no LPN is involved
	      , rs.to_subinventory              from_subinventory_code
	      , rs.to_locator_id                from_locator_id
      FROM      rcv_transactions      rt
              , rcv_supply            rs
              , rcv_shipment_headers  rsh
              , rcv_shipment_lines    rsl
              , mtl_system_items      msi
      WHERE     rs.rcv_transaction_id = v_rcv_txn_id
        AND     rs.to_organization_id = p_organization_id
        AND     rs.rcv_transaction_id = rt.transaction_id
        AND     rs.oe_order_line_id   = v_oe_order_line_id
        AND     rs.shipment_line_id   = rsl.shipment_line_id
        AND     rs.shipment_header_id = rsh.shipment_header_id
        AND     msi.organization_id = p_organization_id
        AND     msi.inventory_item_id = rs.item_id;

    --Local variables
    l_parent_transaction_id NUMBER;   --Transaction ID of the parent RT record
    l_con_transfer_qty      NUMBER;   --Qty converted in MOL UOM code
    l_primary_qty           NUMBER;   --Quantity in primay uom code
    l_primary_uom           mtl_units_of_measure.unit_of_measure%TYPE;
    l_transfer_uom          mtl_units_of_measure.unit_of_measure%TYPE;
    l_primary_uom_code      mtl_units_of_measure.uom_code%TYPE;
    l_transfer_uom_code     mtl_units_of_measure.uom_code%TYPE;
    l_rcv_transaction_rec   INV_RCV_STD_DELIVER_APIS.rcvtxn_transaction_rec_tp;
    l_rcvtxn_rec            INV_RCV_STD_DELIVER_APIS.rcvtxn_enter_rec_cursor_rec;
    l_receipt_source_code   RCV_SHIPMENT_HEADERS.RECEIPT_SOURCE_CODE%TYPE;
    l_parent_txn_id         NUMBER;
    l_um_transfer_qty       NUMBER;   --Transfer quantity converted to MOL UOM

    l_progress              NUMBER;   --Index to track progress and log error
    l_debug                 NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);

     --OPM Convergence
    l_sec_transfer_uom_code mtl_units_of_measure.uom_code%TYPE; --OPM Convergence
    l_secondary_uom           mtl_units_of_measure.unit_of_measure%TYPE;
    l_sec_transfer_uom          mtl_units_of_measure.unit_of_measure%TYPE;
    l_secondary_uom_code      mtl_units_of_measure.uom_code%TYPE;
    l_sec_um_xfer_qty       NUMBER;
    l_secondary_qty NUMBER;

  BEGIN

    --Initialize the return status to succes
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := 10;

    IF (l_debug = 1) THEN
      print_debug('Entered create_rma_transfer_rec: ' || l_progress || ' ' ||
                  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 3);
      print_debug('************Input parameters are************', 3);
      print_debug('   p_oe_order_header_id   ===> ' || p_oe_order_header_id, 3);
      print_debug('   p_oe_order_line_id     ===> ' || p_oe_order_line_id, 3);
      print_debug('********************************************', 3);
    END IF;

    l_progress := 20;

    IF (l_debug = 1) THEN
      print_debug('Fetching the units of measure for the item', 4);
    END IF;

    --Fetch the primary uom, primary uom code and transaction uom for the item
    --This is because receiving works unit of measure than uom code
    BEGIN
      l_transfer_uom_code := p_transfer_uom_code;
      l_sec_transfer_uom_code := p_sec_transfer_uom_code;
      SELECT    primary_unit_of_measure
              , primary_uom_code
             -- , secondary_unit_of_measure --OPM Convergence
              , secondary_uom_code
      INTO      l_primary_uom
              , l_primary_uom_code
             -- , l_secondary_uom
              , l_secondary_uom_code
      FROM      mtl_system_items
      WHERE     inventory_item_id = p_item_id
      AND       organization_id   = p_organization_id;

      SELECT    unit_of_measure
      INTO      l_transfer_uom
      FROM      mtl_item_uoms_view
      WHERE     inventory_item_id = p_item_id
      AND       organization_id   = p_organization_id
      AND       uom_code          = l_transfer_uom_code;

     --OPM Convergence
      IF l_sec_transfer_uom_code IS NOT NULL THEN

         SELECT    unit_of_measure
         INTO      l_sec_transfer_uom
         FROM      mtl_item_uoms_view
         WHERE     inventory_item_id = p_item_id
         AND       organization_id   = p_organization_id
         AND       uom_code          = l_sec_transfer_uom_code;

      END IF;


    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('INV', 'INV-NO ITEM UOM');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
    END;

    l_progress := 30;

    IF (l_debug = 1) THEN
      print_debug('Fetching the parent transaction details', 4);
    END IF;

    --Fetch the parent transaction details
    OPEN c_rcvtxn_detail(p_parent_txn_id, p_oe_order_line_id);
    FETCH c_rcvtxn_detail INTO l_rcvtxn_rec;
    CLOSE c_rcvtxn_detail;

    l_progress := 40;

    l_parent_txn_id := p_parent_txn_id;
    l_receipt_source_code := l_rcvtxn_rec.receipt_source_code;

    --Call the routine to validate LPN, Lot and return the available quantity
    --to transfer in transaction UOM and primary UOM
    IF (l_debug = 1) THEN
      print_debug('Current Progress: ' || l_progress || '. Calling get_avail_quantity_to_transfer with', 4);
      print_debug('   Primary UOM Code: ' || l_primary_uom_code, 4);
      print_debug('   Transfer UOM Code:' || l_transfer_uom_code, 4);
      print_debug('   Secondary UOM Code:' || l_sec_transfer_uom_code || ' (' || l_sec_transfer_uom || ')', 4);
    END IF;

    get_avail_quantity_to_transfer (
        x_return_status         =>  x_return_status
      , x_msg_count             =>  x_msg_count
      , x_msg_data              =>  x_msg_data
      , p_parent_txn_id         =>  p_parent_txn_id
      , p_organization_id       =>  p_organization_id
      , p_item_id               =>  p_item_id
      , p_lpn_id                =>  p_lpn_id
      , p_lot_number            =>  p_lot_number
      , p_transfer_quantity     =>  p_transfer_quantity
      , p_receipt_source_code   =>  l_receipt_source_code
      , p_transfer_uom_code     =>  l_transfer_uom_code
      , p_primary_uom_code      =>  l_primary_uom_code
      , x_avail_transfer_qty    =>  l_um_transfer_qty
      , x_avail_primary_qty     =>  l_primary_qty);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_rma_transfer_rec at progress level '
          || l_progress || ' . get_avail_quantity_to_transfer raised FND_API.G_EXC_ERROR', 4);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_rma_transfer_rec at progress level '
          || l_progress || ' . get_avail_quantity_to_transfer raised FND_API.G_EXC_UNEXP_ERROR', 4);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
     /* OPM Convergence. Obtain the seondary available to transfer quantity
       using the qty available to transfer in primary uom
      */
    l_sec_um_xfer_qty := inv_convert.inv_um_convert(p_item_id,
                                                    5,
                                                    l_um_transfer_qty,
                                                    l_transfer_uom_code,
                                                    p_sec_transfer_uom_code,
                                                    NULL,
                                                    NULL);

    l_progress := 60;
    IF (l_debug = 1) THEN
      print_debug('create_rma_transfer_rec: Quantity to transfer (txn uom): ' || l_um_transfer_qty, 4);
      print_debug('Primary Quantity: ' || l_primary_qty ||' Secondary Quantity: ' || l_sec_um_xfer_qty || ' ' || l_secondary_uom_code, 4);
    END IF;

    --Populate the rcv_transactions_rec record with the quantities and UOMs
    l_rcv_transaction_rec.transaction_quantity  :=  l_um_transfer_qty;
    l_rcv_transaction_rec.transaction_uom       :=  l_transfer_uom;
    l_rcv_transaction_rec.primary_quantity      :=  l_primary_qty;
    l_rcv_transaction_rec.primary_uom           :=  l_primary_uom;

    --OPM Convergence
    l_rcv_transaction_rec.sec_transaction_quantity  :=  l_sec_um_xfer_qty;
    l_rcv_transaction_rec.secondary_uom             :=  l_sec_transfer_uom;
    l_rcv_transaction_rec.secondary_uom_code        :=  l_secondary_uom_code;

    --Now call the procedure to create the RTI record for transfer
    l_progress := 60;
    IF (l_debug = 1) THEN
      print_debug('Calling populate_transfer_rti_values', 4);
    END IF;

    populate_transfer_rti_values (
          x_return_status         =>  x_return_status
        , x_msg_count             =>  x_msg_count
        , x_msg_data              =>  x_msg_data
        , p_rcv_transaction_rec   =>  l_rcv_transaction_rec
        , p_rcvtxn_rec            =>  l_rcvtxn_rec
        , p_parent_txn_id         =>  p_parent_txn_id
        , p_organization_id       =>  p_organization_id
        , p_item_id               =>  p_item_id
        , p_revision              =>  p_revision
        , p_subinventory_code     =>  p_subinventory_code
        , p_locator_id            =>  p_locator_id
        , p_lot_control_code      =>  p_lot_control_code
        , p_serial_control_code   =>  p_serial_control_code
        , p_original_rti_id       =>  p_original_rti_id
        , p_original_temp_id      =>  p_original_temp_id
        , p_lpn_id                =>  p_lpn_id
        , p_transfer_lpn_id       =>  p_transfer_lpn_id
        , p_doc_type              =>  'RMA');

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_rma_transfer_rec at progress level '
          || l_progress || ' . populate_transfer_rti_values raised FND_API.G_EXC_ERROR', 4);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF (l_debug = 1) THEN
        print_debug('Failure in create_rma_transfer_rec at progress level '
          || l_progress || ' . populate_transfer_rti_values raised FND_API.G_EXC_UNEXP_ERROR', 4);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := 70;
    IF (l_debug = 1) THEN
      print_debug('***create_rma_transfer_rec completed successfully***', 4);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF c_rcvtxn_detail%ISOPEN THEN
        CLOSE c_rcvtxn_detail;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF c_rcvtxn_detail%ISOPEN THEN
        CLOSE c_rcvtxn_detail;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN OTHERS THEN
      IF c_rcvtxn_detail%ISOPEN THEN
        CLOSE c_rcvtxn_detail;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error (
          'INV_RCV_STD_TRANSFER_APIS.CREATE_RMA_TRANSFER_REC',
          l_progress,
          SQLCODE);
      END IF;
  END create_rma_transfer_rec;


/*------------------------------------------------------------------------------
  * PROCEDURE: create_transfer_rcvtxn_rec
  * Description:
  *   This procedure creates a RCV_TRANSACTIONS_INTERFACE record for a Receiving
  *   Transfer Transaction<br>
  *   Called from the Mobile putaway UI and packing workbench
  *
  * Output Parameters
  *   x_return_status
  *      Return status indicating Success (S), Error (E), Unexpected Error (U)
  *   x_msg_count
  *      Number of messages in  message list
  *   x_msg_data
  *      Stacked messages text
  *
  * Input Parameters
  *    p_organization_id     - Organization ID
  *    p_parent_txn_id       - Transaction ID of the parent transaction
  *    p_reference_id        - Reference ID of the move order line
  *    p_reference           - Reference Indicator for the source doc
  *    p_reference_type_code - Reference Type Code
  *    p_item_id             - Item Being transferred
  *    p_revision            - Item Revision
  *    p_subinventory_code   - Destination receiving subinventory code
  *    p_locator_id          - Destination receiving locator ID
  *    p_transfer_quantity   - Quantity to be transferred
  *    p_transfer_uom_code   - UOM code of the quantity being tranferred
  *    p_lot_control_code    - Lot Control Code of the item
  *    p_serial_control_code - Serial Control Code of the item
  *    p_original_rti_id     - Original RTI ID for lot/serial split
  *    p_original_temp_id    - Transaction Temp ID of the putaway MMTT
  *    p_lot_number          - Lot Number on the move order line
  *    p_lpn_id              - LPN ID of the move order line
  *    p_transfer_lpn_id     - LPN ID of the LPN being dropped into
  *
  * Returns: NONE
  *---------------------------------------------------------------------------*/
 PROCEDURE create_transfer_rcvtxn_rec(
      x_return_status       OUT NOCOPY  VARCHAR2
    , x_msg_count           OUT NOCOPY  NUMBER
    , x_msg_data            OUT NOCOPY  VARCHAR2
    , p_organization_id     IN          NUMBER
    , p_parent_txn_id       IN          NUMBER
    , p_reference_id        IN          NUMBER
    , p_reference           IN          VARCHAR2
    , p_reference_type_code IN          NUMBER
    , p_item_id             IN          NUMBER
    , p_revision            IN          VARCHAR2
    , p_subinventory_code   IN          VARCHAR2
    , p_locator_id          IN          NUMBER
    , p_transfer_quantity   IN          NUMBER
    , p_transfer_uom_code   IN          VARCHAR2
    , p_lot_control_code    IN          NUMBER
    , p_serial_control_code IN          NUMBER
    , p_original_rti_id     IN          NUMBER   DEFAULT NULL
    , p_original_temp_id    IN          NUMBER   DEFAULT NULL
    , p_lot_number          IN          VARCHAR2 DEFAULT NULL
    , p_lpn_id              IN          NUMBER   DEFAULT NULL
    , p_transfer_lpn_id     IN          NUMBER   DEFAULT NULL
    , p_sec_transfer_quantity    IN          NUMBER  DEFAULT NULL --OPM Convergence
    , p_sec_transfer_uom_code         IN          VARCHAR2 DEFAULT NULL ) --OPM Convergence
      IS

    --Local Variables
    l_po_header_id          NUMBER;
    l_po_release_id         NUMBER;
    l_po_line_id            NUMBER;
    l_shipment_header_id    NUMBER;
    l_oe_order_header_id    NUMBER;
    l_group_id              NUMBER;       --Interface Group ID
    l_progress              NUMBER;       --Index to track progress and log error
    l_debug                 NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
    l_message               VARCHAR2(1000);

    l_sec_uom_code          VARCHAR2(3) := p_sec_transfer_uom_code;

  BEGIN

    --Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (l_debug = 1) THEN
      print_debug('Entered create_transfer_rcvtxn_rec 10: ' ||
                    to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := 20;


    --Print the input parameters
    IF (l_debug = 1) THEN
      print_debug('******Input parameters passed to the procedure:****** ', 3);
      print_debug('   p_lpn_id               ===> ' || p_lpn_id, 3);
      print_debug('   p_organization_id      ===> ' || p_organization_id, 3);
      print_debug('   p_parent_txn_id        ===> ' || p_parent_txn_id, 3);
      print_debug('   p_reference_id         ===> ' || p_reference_id, 3);
      print_debug('   p_reference            ===> ' || p_reference, 3);
      print_debug('   p_reference_type_code  ===> ' || p_reference_type_code, 3);
      print_debug('   p_item_id              ===> ' || p_item_id, 3);
      print_debug('   p_revision             ===> ' || p_revision, 3);
      print_debug('   p_subinventory_code    ===> ' || p_subinventory_code, 3);
      print_debug('   p_locator_id           ===> ' || p_locator_id, 3);
      print_debug('   p_transfer_quantity    ===> ' || p_transfer_quantity, 3);
      print_debug('   p_transfer_uom_code    ===> ' || p_transfer_uom_code, 3);
      print_debug('   p_original_rti_id      ===> ' || p_original_rti_id, 3);
      print_debug('   p_lot_control_code     ===> ' || p_lot_control_code, 3);
      print_debug('   p_serial_control_code  ===> ' || p_serial_control_code, 3);
      print_debug('   p_original_temp_id     ===> ' || p_original_temp_id, 3);
      print_debug('   p_lot_number           ===> ' || p_lot_number, 3);
      print_debug('   p_secondary_quantity   ===> ' || p_sec_transfer_quantity,3);
      print_debug('   p_secondary_uom_code   ===> ' || l_sec_uom_code,3);
      print_debug('***************************************************** ', 3);
    END IF;

    IF(l_sec_uom_code IS NULL) THEN
       IF (l_debug = 1) THEN
         print_debug('Fetching the secondary units of measure for the item', 4);
       END IF;

     SELECT    secondary_uom_code
     INTO      l_sec_uom_code
      FROM      mtl_system_items
      WHERE     inventory_item_id = p_item_id
      AND       organization_id   = p_organization_id;

       IF (l_debug = 1) THEN
         print_debug('   p_secondary_uom_code   ===> ' || l_sec_uom_code,3);
       END IF;

    END IF;

    --Initialize the receiving parameters for the organization id
    BEGIN
      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          print_debug('Failed at progress : ' || l_progress ||
          ' . Error in initializing receiving parameters', 4);
          print_debug('err: ' || substr(sqlerrm,1,140),4);
        END IF;
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.add;

        RAISE FND_API.G_EXC_ERROR;
    END;

    --First check if the transaction date satisfies the validation.
    --If the transaction date is invalid then error out the transaction
    IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
      --Bug #	3444214
      --For better performance, using hr_organization_information to fetch set_of_books_id
      SELECT TO_NUMBER(hoi.org_information1)
      INTO   inv_rcv_common_apis.g_po_startup_value.sob_id
      FROM   hr_organization_information hoi
      WHERE  hoi.organization_id = p_organization_id
      AND    (hoi.org_information_context || '') = 'Accounting Information';
    END IF;

    l_progress := 15;

    inv_rcv_common_apis.validate_trx_date(
      p_trx_date            => SYSDATE
    , p_organization_id     => p_organization_id
    , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
    , x_return_status       => x_return_status
    , x_error_code          => l_message
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    l_progress := 20;

    --Fetch the group_id from global variable. Set the value for the current set
    IF (l_debug = 1) THEN
      print_debug('Setting group_id for the current txn', 4);
    END IF;

    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT  rcv_interface_groups_s.NEXTVAL
      INTO    l_group_id
      FROM    sys.dual;
      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    END IF;

    --Set the package variable for uom_code
    g_transfer_uom_code := p_transfer_uom_code;

    --Check the document reference from the Move Order line and call the
    --appropriate procedures

    --If the source document is a Purchase Order
    IF p_reference_type_code = 4    AND p_reference = 'PO_LINE_LOCATION_ID' THEN

      l_progress := 30;

      BEGIN
	 SELECT  po_header_id
	   , po_release_id
	   , po_line_id
	   INTO    l_po_header_id
	   , l_po_release_id
	   , l_po_line_id
	   FROM    po_line_locations
	   WHERE   line_location_id = p_reference_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('create_transfer_rcvtxn_rec 20: Error retrieving po info.',1);
	       print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||Sqlerrm,1);
	    END IF;
	    RAISE fnd_api.g_exc_error;
      END;

      IF (l_debug = 1) THEN
        print_debug('Current Progress: ' || l_progress || '. Calling create_po_transfer_rec', 4);
      END IF;

      create_po_transfer_rec (
          x_return_status         =>  x_return_status
        , x_msg_count             =>  x_msg_count
        , x_msg_data              =>  x_msg_data
        , p_organization_id       =>  p_organization_id
        , p_po_header_id          =>  l_po_header_id
        , p_po_release_id         =>  l_po_release_id
        , p_po_line_id            =>  l_po_line_id
        , p_po_line_location_id   =>  p_reference_id
        , p_parent_txn_id         =>  p_parent_txn_id
        , p_item_id               =>  p_item_id
        , p_revision              =>  p_revision
        , p_subinventory_code     =>  p_subinventory_code
        , p_locator_id            =>  p_locator_id
        , p_transfer_quantity     =>  p_transfer_quantity
        , p_transfer_uom_code     =>  p_transfer_uom_code
        , p_lot_control_code      =>  p_lot_control_code
        , p_serial_control_code   =>  p_serial_control_code
        , p_original_rti_id       =>  p_original_rti_id
        , p_original_temp_id      =>  p_original_temp_id
        , p_lot_number            =>  p_lot_number
        , p_lpn_id                =>  p_lpn_id
        , p_transfer_lpn_id       =>  p_transfer_lpn_id
        , p_sec_transfer_quantity =>  p_sec_transfer_quantity --OPM Convergence
        , p_sec_transfer_uom_code      =>  l_sec_uom_code ); --OPM Convergence

      --Check the return status
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL');
        fnd_msg_pub.add;

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          IF (l_debug = 1) THEN
            print_debug('Failure in create_transfer_rcvtxn_rec at progress level '
              || l_progress || ' . create_po_transfer_rec raised FND_API.G_EXC_ERROR', 4);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          IF (l_debug = 1) THEN
            print_debug('Failure in create_transfer_rcvtxn_rec at progress level '
               || l_progress || ' . create_po_transfer_rec raised FND_API.G_EXC_UNEXP_ERROR', 4);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;   --END IF check return status

      IF l_debug = 1 THEN
        print_debug('RTI record created successfully for PO', 4);
      END IF;

    --If the source document is an Internal Requisition/Intransit Shipment

    --Bug 5662935 :Added reference_type_code = 6 in the following condition.
    --After the bug fix done as a part of bug 4996680,reference_type_code=6 is
    --for source document 'Intransit Shipment' and reference_type_code = 8
    --is for source document 'Internal Requisition'.
    ELSIF p_reference_type_code in (6,8) AND p_reference = 'SHIPMENT_LINE_ID'    THEN

      l_progress := 40;

      SELECT  shipment_header_id
      INTO    l_shipment_header_id
      FROM    rcv_shipment_lines
      WHERE   shipment_line_id = p_reference_id;

      IF (l_debug = 1) THEN
        print_debug('Current Progress: ' || l_progress ||
          ' . Calling create_int_ship_transfer_rec', 4);
      END IF;

      create_int_ship_transfer_rec (
          x_return_status         =>  x_return_status
        , x_msg_count             =>  x_msg_count
        , x_msg_data              =>  x_msg_data
        , p_organization_id       =>  p_organization_id
        , p_shipment_header_id    => l_shipment_header_id
        , p_shipment_line_id      =>  p_reference_id
        , p_parent_txn_id         =>  p_parent_txn_id
        , p_item_id               =>  p_item_id
        , p_revision              =>  p_revision
        , p_subinventory_code     =>  p_subinventory_code
        , p_locator_id            =>  p_locator_id
        , p_transfer_quantity     =>  p_transfer_quantity
        , p_transfer_uom_code     =>  p_transfer_uom_code
        , p_lot_control_code      =>  p_lot_control_code
        , p_serial_control_code   =>  p_serial_control_code
        , p_original_temp_id      =>  p_original_temp_id
        , p_original_rti_id       =>  p_original_rti_id
        , p_lot_number            =>  p_lot_number
        , p_lpn_id                =>  p_lpn_id
        , p_transfer_lpn_id       =>  p_transfer_lpn_id
        , p_sec_transfer_quantity =>  p_sec_transfer_quantity --OPM Convergence
        , p_sec_transfer_uom_code      =>  l_sec_uom_code ); --OPM Convergence

      --Check the return status
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL');
        fnd_msg_pub.add;

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          IF (l_debug = 1) THEN
            print_debug('Failure in create_transfer_rcvtxn_rec at progress level '
               || l_progress || ' . create_int_ship_transfer_rec raised FND_API.G_EXC_ERROR', 4);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          IF (l_debug = 1) THEN
            print_debug('Failure in create_transfer_rcvtxn_rec at progress level '
               || l_progress || ' . create_int_ship_transfer_rec raised FND_API.G_EXC_UNEXP_ERROR', 4);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;   --END IF check return status

      IF l_debug = 1 THEN
        print_debug('RTI record created successfully for INT SHIP.', 4);
      END IF;

    --If the source document is an RMA
    ELSIF p_reference_type_code = 7 AND p_reference = 'ORDER_LINE_ID'       THEN

      l_progress := 50;

      SELECT  header_id
      INTO    l_oe_order_header_id
      FROM    oe_order_lines_all
      WHERE   line_id = p_reference_id;

      IF (l_debug = 1) THEN
        print_debug('Current Progress: ' || l_progress ||
          ' . Calling create_rma_transfer_rec', 4);
      END IF;

      create_rma_transfer_rec (
          x_return_status         =>  x_return_status
        , x_msg_count             =>  x_msg_count
        , x_msg_data              =>  x_msg_data
        , p_organization_id       =>  p_organization_id
        , p_oe_order_header_id    =>  l_oe_order_header_id
        , p_oe_order_line_id      =>  p_reference_id
        , p_parent_txn_id         =>  p_parent_txn_id
        , p_item_id               =>  p_item_id
        , p_revision              =>  p_revision
        , p_subinventory_code     =>  p_subinventory_code
        , p_locator_id            =>  p_locator_id
        , p_transfer_quantity     =>  p_transfer_quantity
        , p_transfer_uom_code     =>  p_transfer_uom_code
        , p_lot_control_code      =>  p_lot_control_code
        , p_serial_control_code   =>  p_serial_control_code
        , p_original_rti_id       =>  p_original_rti_id
        , p_original_temp_id      =>  p_original_temp_id
        , p_lot_number            =>  p_lot_number
        , p_lpn_id                =>  p_lpn_id
        , p_transfer_lpn_id       =>  p_transfer_lpn_id
        , p_sec_transfer_quantity =>  p_sec_transfer_quantity --OPM Convergence
        , p_sec_transfer_uom_code      =>  l_sec_uom_code ); --OPM Convergence

      --Check the return status
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL');
        fnd_msg_pub.add;

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          IF (l_debug = 1) THEN
            print_debug('Failure in create_transfer_rcvtxn_rec at progress level '
               || l_progress || ' . create_rma_transfer_rec raised FND_API.G_EXC_ERROR', 4);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          IF (l_debug = 1) THEN
            print_debug('Failure in create_transfer_rcvtxn_rec at progress level '
               || l_progress || ' . create_rma_transfer_rec raised FND_API.G_EXC_UNEXP_ERROR', 4);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;   --END IF check return status

      IF l_debug = 1 THEN
        print_debug('RTI record created successfully for RMA.', 4);
      END IF;

    --If the move order line reference is invalid then scream
    ELSE
      print_debug('Failed at : ' || l_progress || ' . Invalid Reference passed : '
        || p_reference_type_code, 4);
      fnd_message.set_name('INV', 'INV-BAD SOURCE TYPE');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_progress := 60;

    IF (l_debug = 1) THEN
      print_debug('Current Progress : ' || l_progress ||
      ' . :-) create_transfer_rcvtxn_rec completed successfully! :-)', 4);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error (
          'INV_RCV_STD_TRANSFER_APIS.CREATE_TRANSFER_RCVTXN_REC',
          l_progress,
          SQLCODE);
      END IF;
  END create_transfer_rcvtxn_rec;

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


  PROCEDURE Match_transfer_rcvtxn_rec(
      x_return_status       OUT NOCOPY  VARCHAR2
    , x_msg_count           OUT NOCOPY  NUMBER
    , x_msg_data            OUT NOCOPY  VARCHAR2
    , p_organization_id     IN          NUMBER
    , p_parent_txn_id       IN          NUMBER
    , p_reference_id        IN          NUMBER
    , p_reference           IN          VARCHAR2
    , p_reference_type_code IN          NUMBER
    , p_item_id             IN          NUMBER
    , p_revision            IN          VARCHAR2
    , p_subinventory_code   IN          VARCHAR2
    , p_locator_id          IN          NUMBER
    , p_transfer_quantity   IN          NUMBER
    , p_transfer_uom_code   IN          VARCHAR2
    , p_lot_control_code    IN          NUMBER
    , p_serial_control_code IN          NUMBER
    , p_original_rti_id     IN          NUMBER   DEFAULT NULL
    , p_original_temp_id    IN          NUMBER   DEFAULT NULL
    , p_lot_number          IN          VARCHAR2 DEFAULT NULL
    , p_lpn_id              IN          NUMBER   DEFAULT NULL
    , p_transfer_lpn_id     IN          NUMBER   DEFAULT NULL
    , p_sec_transfer_quantity    IN     NUMBER  DEFAULT NULL --OPM Convergence
    , p_sec_transfer_uom_code    IN     VARCHAR2 DEFAULT NULL  --OPM Convergence
    , p_inspection_status        IN     NUMBER DEFAULT NULL
    , p_primary_uom_code         IN     VARCHAR2
    , p_from_sub            IN          VARCHAR2 DEFAULT NULL --Needed for matching non-lpn materials
    , p_from_loc            IN          NUMBER DEFAULT NULL) --Needed for matching non-lpn materials
     IS

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
      AND Nvl(rs.item_revision,nvl(p_revision,'@@@')) = nvl(p_revision,'@@@')
      AND rs.to_organization_id = p_organization_id
      AND nvl(rs.lpn_id,-1) = nvl(p_lpn_id,-1)
      AND rs.rcv_transaction_id = rt.transaction_id
      AND msni.product_code = 'RCV'
      AND msni.product_transaction_id = p_original_rti_id
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
		     /*Bug 5511398:In case the receipt transcation for WMS enabled org is done via
		       desktop, then there will not be data in RLS table,in which case fetch the qty
		       from rcv_supply .*/
 		   /*,Nvl(rls.primary_quantity,0) lot_prim_qty
		     ,Nvl(rls.quantity,0)         lot_qty*/
		     ,nvl(rls.primary_quantity,rs.to_org_primary_quantity) lot_prim_qty
                     ,nvl(rls.quantity,rs.quantity) lot_qty
                     ,decode(rt.uom_code, p_transfer_uom_code, 1, 2) ORDERING1
                     ,decode(rt.uom_code, p_transfer_uom_code, (p_transfer_quantity - rs.quantity), 0) ORDERING2
		     ,rsl.asn_line_flag        asn_line_flag
                FROM rcv_supply rs,
                     rcv_transactions rt,
                     rcv_shipment_lines rsl,
                     rcv_lots_supply rls,
                     rcv_shipment_headers rsh
               WHERE rs.item_id = p_item_id
                 AND Nvl(rs.item_revision,nvl(p_revision,'@@@@')) = nvl(p_revision,'@@@@')
                 AND rs.to_organization_id = p_organization_id
                 AND nvl(rs.lpn_id,-1) = nvl(p_lpn_id,-1)
                 AND nvl(rt.subinventory,'@$#_') = nvl(v_from_sub,'@$#_')
                 AND nvl(rt.locator_id,-1) = nvl(v_from_locator_id, -1)
                 AND nvl(rt.transfer_lpn_id,-1) = nvl(p_lpn_id,-1)
                 AND rs.rcv_transaction_id = rt.transaction_id
                 AND rt.shipment_line_id = rsl.shipment_line_id
                 AND rs.supply_type_code = 'RECEIVING'
                 AND rls.transaction_id (+) = rs.supply_source_id
                 AND nvl(rls.lot_num, '@$#_') = nvl(p_lot_number, '@$#_')
                 AND rsh.shipment_header_id = rsl.shipment_header_id
                 AND decode(rt.routing_header_id, 2,
                     decode(rt.inspection_status_code,'NOT INSPECTED',1, 'ACCEPTED',2,'REJECTED', 3)
                     ,-1) = nvl(p_inspection_status, -1)
   	         --Bug 5331779 - Begin change
		 --Adding the following to make sure that we do not pickup RS with serial numbers
		 AND NOT exists
		   (SELECT '1' FROM rcv_serials_supply rss
		    WHERE rss.transaction_id = rs.supply_source_id
		    AND rss.supply_type_code = 'RECEIVING')
		   --Bug 5331779-End change
                 ORDER BY ORDERING1, ORDERING2
                 ;


    --Local Variables
    l_debug                 NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);


  l_new_rti_info    inv_rcv_integration_apis.child_rec_tb_tp;
  l_from_sub   VARCHAR2(30);
  l_from_locator_id NUMBER;
  l_split_lot_serial_ok     BOOLEAN;
  l_receipt_uom  VARCHAR2(25);
  l_receipt_qty  NUMBER;

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
  L_matched_index           NUMBER;
  l_ser_txn_temp_id         NUMBER;
  l_progress                VARCHAR2(10);
  l_original_sec_qty        NUMBER;
  l_lot_temp_id             NUMBER;
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
  l_mmtt_id_to_insert NUMBER;
  k NUMBER;
  l VARCHAR2(80);

  BEGIN

    --Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SAVEPOINT match_rti_ss;

    IF (l_debug = 1) THEN
      print_debug('Entered Match_transfer_rcvtxn_rec 10: '|| to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := 20;


  --Print the input parameters
    IF (l_debug = 1) THEN
      print_debug('******Input parameters passed to the procedure:****** ', 3);
      print_debug('   p_lpn_id               ===> ' || p_lpn_id, 3);
      print_debug('   p_organization_id      ===> ' || p_organization_id, 3);
      print_debug('   p_parent_txn_id        ===> ' || p_parent_txn_id, 3);
      print_debug('   p_reference_id         ===> ' || p_reference_id, 3);
      print_debug('   p_reference            ===> ' || p_reference, 3);
      print_debug('   p_reference_type_code  ===> ' || p_reference_type_code, 3);
      print_debug('   p_item_id              ===> ' || p_item_id, 3);
      print_debug('   p_revision             ===> ' || p_revision, 3);
      print_debug('   p_subinventory_code    ===> ' || p_subinventory_code, 3);
      print_debug('   p_locator_id           ===> ' || p_locator_id, 3);
      print_debug('   p_transfer_quantity    ===> ' || p_transfer_quantity, 3);
      print_debug('   p_transfer_uom_code    ===> ' || p_transfer_uom_code, 3);
      print_debug('   p_original_rti_id      ===> ' || p_original_rti_id, 3);
      print_debug('   p_lot_control_code     ===> ' || p_lot_control_code, 3);
      print_debug('   p_serial_control_code  ===> ' || p_serial_control_code, 3);
      print_debug('   p_original_temp_id     ===> ' || p_original_temp_id, 3);
      print_debug('   p_lot_number           ===> ' || p_lot_number, 3);
      print_debug('   p_secondary_quantity   ===> ' || p_sec_transfer_quantity,3);
      print_debug('   p_secondary_uom_code   ===> ' || p_sec_transfer_uom_code,3);
      print_debug('   p_primary_uom_code     ===> ' ||p_primary_uom_code,3);
      print_debug('   p_from_sub             ===> ' ||p_from_sub,3);
      print_debug('   p_from_loc             ===> ' ||p_from_loc,3);
      print_debug('***************************************************** ', 3);
    END IF;

    l_primary_uom_code := p_primary_uom_code;

    IF (p_lpn_id IS NULL) THEN
       l_from_sub := p_from_sub;
       l_from_locator_id := p_from_loc;
     ELSE
       BEGIN
	  select subinventory_code
	    , locator_id
	    into l_from_sub
	    ,l_from_locator_id
	    from wms_license_plate_numbers wlpn
	    where wlpn.lpn_id = p_lpn_id;
       EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     l_from_sub := NULL;
	     l_from_locator_id := NULL;
       END;
    END IF;

    l_remaining_prim_qty := inv_convert.inv_um_convert(
                                item_id     => p_item_id,
                              precision     => 6,
                          from_quantity     => p_transfer_quantity,
                              from_unit     => p_transfer_uom_code,
                                to_unit     => l_primary_uom_code,
                              from_name     => null,
                                to_name     => null);

   IF (p_serial_control_code = 1 OR p_serial_control_code = 6) then
       -- CASE WHERE ITEM IS NOT SERIAL CONTROLLED
       -- OR  CASE WHEN SERIAL CONTROLLED CODE IS AT SO ISSUE Bug: 5331779
       For l_rtv_rec in c_rtv_cur(l_from_sub, l_from_locator_id)
       Loop

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
              print_debug('transaction id '        || l_rtv_rec.rcv_transaction_id, 1);
              print_debug('lot primary quantity '  || l_rtv_rec.lot_prim_qty, 1);
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
	      IF (l_debug = 1) THEN
		 print_debug('BEFORE GETTING AVAIL QTY  ' , 1);
	      END IF;

	      rcv_quantities_s.get_available_quantity(
						      'TRANSFER'
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


	      l_avail_prim_qty := inv_convert.inv_um_convert( item_id     => p_item_id,
							      precision     => 6,
							      from_quantity     => l_avail_qty,
							      from_unit     => l_rtv_rec.uom_code,
							      to_unit     => l_primary_uom_code,
							      from_name     => null,
							      to_name     => null);

	      IF (l_debug = 1) THEN
		 print_debug('AVAIL QTY = '         ||  l_avail_qty , 1);
		 print_debug('AVAIL_PRIM QTY = '    || l_avail_prim_qty , 1);
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
              IF (p_transfer_uom_code <> l_rtv_rec.uom_code) THEN
                 l_qty_to_insert := inv_convert.inv_um_convert( item_id     => p_item_id,
                              precision     => 6,
                          from_quantity     => l_avail_qty,
                              from_unit     => l_rtv_rec.uom_code,
                                to_unit     => p_transfer_uom_code,
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

	      IF (l_debug = 1) THEN
		 print_debug('INTF ID = '||l_new_intf_id , 1);
	      END IF;

	      IF (p_original_temp_id IS NOT NULL) THEN
		 IF (l_debug = 1) THEN
		    print_debug('Calling split_mmtt', 1);
		 END IF;

		 inv_rcv_integration_apis.split_mmtt
		   (p_orig_mmtt_id      => p_original_temp_id
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
	      END IF;--END IF (p_original_temp_id IS NOT NULL) THEN

	      IF (p_lot_control_code = 2) THEN
		 l_new_rti_info(1).orig_interface_trx_id := p_original_rti_id;
		 l_new_rti_info(1).new_interface_trx_id  := l_new_intf_id;
		 l_new_rti_info(1).quantity              := L_qty_to_insert;

		 l_new_rti_info(1).to_organization_id    := p_organization_id;
		 l_new_rti_info(1).item_id               := p_item_id;
		 l_new_rti_info(1).uom_code              := p_transfer_uom_code;

		 IF (l_remaining_prim_qty > 0) THEN
		    IF (p_transfer_uom_code <> l_primary_uom_code) THEN
		       l_new_rti_info(2).quantity := inv_convert.inv_um_convert
			                             ( item_id       => p_item_id,
						       precision     => 6,
						       from_quantity => l_remaining_prim_qty,
						       from_unit     => l_primary_uom_code,
						       to_unit       => p_transfer_uom_code,
						       from_name     => null,
						       to_name       => null );
		     ELSE
		       l_new_rti_info(2).quantity := l_remaining_prim_qty;
		    END IF;

		    l_new_rti_info(2).orig_interface_trx_id := p_original_rti_id;
		    l_new_rti_info(2).new_interface_trx_id  := p_original_rti_id;

		    l_new_rti_info(2).to_organization_id    := p_organization_id;
		    l_new_rti_info(2).item_id               := p_item_id;
		    l_new_rti_info(2).uom_code              := p_transfer_uom_code;
		 END IF;

		 IF (l_debug = 1) THEN
		    print_debug('Before calling the split lot serial', 1);
		 END IF;

		 l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial
		   (p_api_version   => 1.0
		    , p_init_msg_lst  => FND_API.G_FALSE
		    , x_return_status =>  l_return_status
		    , x_msg_count     =>  l_msg_count
		    , x_msg_data      =>  l_msg_data
		    , p_new_rti_info  =>  l_new_rti_info);


		 IF (l_debug = 1) THEN
		    print_debug('After calling the split lot serial', 1);
		 END IF;

		 IF ( NOT l_split_lot_serial_ok) THEN
		    IF (l_debug = 1) THEN
		       print_debug(' MATCH_TRANSFER_INTF_REC: Failure in split_lot_serial ', 4);
		    END IF;
		    RAISE FND_API.G_EXC_ERROR;
		 END IF;
	      END IF;

           ELSE
                 l_qty_to_insert := inv_convert.inv_um_convert(
                                item_id     => p_item_id,
                              precision     => 6,
                          from_quantity     => l_remaining_prim_qty,
                              from_unit     => l_primary_uom_code,
                                to_unit     => p_transfer_uom_code,
                              from_name     => null,
                                to_name     => null );

                 IF (l_debug = 1) THEN
                    print_debug('QTY TO INSERT3: = ' || L_QTY_TO_INSERT , 1);
                 END IF;

		 IF (p_lot_control_code = 2) THEN
		    UPDATE mtl_transaction_lots_interface
		      SET  product_transaction_id = l_new_intf_id
		      WHERE product_transaction_id = p_original_rti_id
		      AND   product_code = 'RCV';
		 END IF;

                 l_remaining_prim_qty := 0;
		 l_mmtt_id_to_insert := p_original_temp_id;
           END IF;

           IF l_rtv_rec.source_document_code = 'PO' THEN
	      L_reference := 'PO_LINE_LOCATION_ID';
	      L_reference_type_code := 4;
	      L_reference_id := l_rtv_rec.po_line_location_id ;
   	   --Bug5662935:For source_document_code 'INVENTORY', reference_type_code is'6'.
           ELSIF l_rtv_rec.source_document_code = 'INVENTORY' THEN
                L_reference := 'SHIPMENT_LINE_ID';
                L_reference_type_code := 6;
                L_reference_id := l_rtv_rec.shipment_line_id;
           ELSIF l_rtv_rec.source_document_code = 'REQ' THEN
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

           if p_sec_transfer_uom_code is not null Then
              IF (l_debug = 1) THEN
                   print_debug('CALCULATING SEC QTY' , 1);
              END IF;
              l_secondary_quantity := p_sec_transfer_quantity * (l_qty_to_insert/p_transfer_quantity);
           Else
              l_secondary_quantity := null;
           End if;

           IF (l_debug = 1) THEN
                   print_debug('SECONDARY UOM CODE = '|| p_sec_transfer_uom_code  , 1);
                   print_debug('SECONDARY QTY      = '|| l_secondary_quantity, 1);
           END IF;

           inv_rcv_std_transfer_apis.create_transfer_rcvtxn_rec(
              x_return_status       =>  l_return_status
            , x_msg_count           =>  l_msg_count
            , x_msg_data            =>  l_msg_data
            , p_organization_id     =>  p_organization_id
            , p_parent_txn_id       =>  l_rtv_rec.rcv_transaction_id
            , p_reference_id        =>  l_reference_id
            , p_reference           =>  l_reference
            , p_reference_type_code =>  l_reference_type_code
            , p_item_id             =>  p_item_id
            , p_revision            =>  p_revision
            , p_subinventory_code   =>  p_subinventory_code
            , p_locator_id          =>  p_locator_id
            , p_transfer_quantity   =>  l_qty_to_insert
            , p_transfer_uom_code   =>  p_transfer_uom_code
            , p_lot_control_code    =>  p_lot_control_code
            , p_serial_control_code =>  p_serial_control_code
            , p_original_rti_id     =>  l_new_intf_id
            , p_original_temp_id    =>  l_mmtt_id_to_insert
            , p_lot_number          =>  p_lot_number
            , p_lpn_id              =>  p_lpn_id
            , p_transfer_lpn_id     =>  p_transfer_lpn_id
            , p_sec_transfer_quantity   =>  l_secondary_quantity
            , p_sec_transfer_uom_code   =>  p_sec_transfer_uom_code
            );

           IF (l_debug = 1) THEN
                print_debug('AFTER CALLING THE TRANSFER API: STATUS = '|| l_return_status, 1);
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

	   <<nextrtrecord>>
	     NULL;
       End Loop; -- End of Recipt' txns Loop
       --Bug 5331779-Begin change
       --If l_remaining_prim_qty > 0 then only
       --fail if the serial control code is 1 because for serial control
       --code of 6, there may be lines with serial number which are yet to
       --be processed.
       IF p_serial_control_code = 1 AND l_remaining_prim_qty > 0 THEN
       -- Bug 5331779 -End change
--     IF l_remaining_prim_qty > 0 THEN

           IF (l_debug = 1) THEN
                print_debug('COUND NOT MATCH RECEIPT TRANSACTION FOR THE QTY TO BE TRANSFERRED:  FAILURE ', 1);
           END IF;

           -- Unable to match RS with quantity.
           fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
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
		  l_rti_tb(l_txn_id)(l_lot_num).reference := 'PO_LINE_LOCATION_ID';
		  l_rti_tb(l_txn_id)(l_lot_num).reference_type_code := 4;
		  l_rti_tb(l_txn_id)(l_lot_num).reference_id := l_serial_rec.po_line_location_id;
		--Bug5662935:For source_document_code 'INVENTORY', reference_type_code is'6'.
                ELSIF l_rti_tb(l_txn_id)(l_lot_num).source_document_code = 'INVENTORY' THEN
                     l_rti_tb(l_txn_id)(l_lot_num).reference := 'SHIPMENT_LINE_ID';
                     l_rti_tb(l_txn_id)(l_lot_num).reference_type_code := 6;
                     l_rti_tb(l_txn_id)(l_lot_num).reference_id := l_serial_rec.shipment_line_id;
		ELSIF l_rti_tb(l_txn_id)(l_lot_num).source_document_code = 'REQ' THEN
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

	k := l_rti_tb.first;

	LOOP
	   EXIT WHEN k IS NULL;

	   l := l_rti_tb(k).first;

	   LOOP
	      EXIT WHEN l IS NULL;

	      --
	      -- Get the seconadry qty from the Original MTLI
	      --
	      IF p_transfer_uom_code = l_primary_uom_code Then
		 l_qty_to_insert :=  l_rti_tb(k)(l).quantity;
	       ELSE
		 l_qty_to_insert := inv_convert.inv_um_convert
		                        ( item_id     => p_item_id,
					  precision     => 6,
					  from_quantity     => l_rti_tb(k)(l).quantity,
					  from_unit     => l_primary_uom_code,
					  to_unit     => p_transfer_uom_code,
					  from_name     => null,
					  to_name     => null );
	      END IF;

	      l_uom_code := p_transfer_uom_code;

	      IF (l_debug = 1) THEN
		 print_debug(' qty to insert = ' || l_qty_to_insert, 1);
	      END IF;

	      rcv_quantities_s.get_available_quantity(
						      'TRANSFER'
						      ,l_rti_tb(k)(l).rcv_transaction_id
						      ,l_rti_tb(k)(l).receipt_source_code
						      , NULL
						      , l_rti_tb(k)(l).rcv_transaction_id
						      , NULL
						      , l_avail_qty
						      , l_tolerable_qty
						      , l_receipt_uom);
	      if l_rti_tb(k)(l).uom_code <> l_uom_code then

		 l_receipt_qty := inv_convert.inv_um_convert( item_id     => p_item_id,
							      precision     => 6,
							      from_quantity     => l_avail_qty,
							      from_unit     => l_rti_tb(k)(l).uom_code,
							      to_unit     => l_uom_code,
							      from_name     => null,
							      to_name     => null );

                 l_avail_qty := l_receipt_qty;
	      End if;

	      IF l_avail_qty < l_qty_to_insert THEN
		 -- FAIL THE TXN NOT ENOUGH QTY AVAIABLE TO TRANSACT
		 IF (l_debug = 1) THEN
		    print_debug('Avaiable Qty is less than Txn Qty  ' , 1);
		 END IF;
		 fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;

	      IF (l_rti_tb(k)(l).quantity < l_remaining_prim_qty) THEN

		 IF (p_original_temp_id IS NOT NULL) THEN
		    IF (l_debug = 1) THEN
		       print_debug('Calling split_mmtt', 1);
		    END IF;

		    inv_rcv_integration_apis.split_mmtt
		      (p_orig_mmtt_id      => p_original_temp_id
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
		 END IF;--END IF (p_original_temp_id IS NOT NULL) THEN

		 l_remaining_prim_qty := l_remaining_prim_qty-l_rti_tb(k)(l).quantity;
	       ELSE
		 l_mmtt_id_to_insert := p_original_temp_id;
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
		      and mtli.product_transaction_id =  p_original_rti_id ;
		 EXCEPTION
		    WHEN NO_DATA_FOUND THEN NULL;
		 END;

		 IF l_original_sec_qty is not null THEN
		    l_lot_sec_qty_to_insert := l_original_lot_sec_qty * (l_qty_to_insert / p_transfer_quantity);
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
		   print_debug('  p_secondary_uom    =>'|| p_sec_transfer_uom_code,1);
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
				, p_secondary_uom      => p_sec_transfer_uom_code);   --OPM Convergence

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


             IF P_SEC_TRANSFER_UOM_CODE is not null THEN
                l_secondary_quantity := p_sec_transfer_quantity * (l_qty_to_insert/p_transfer_quantity);
             END IF;

	     IF (l_debug = 1) THEN
		print_debug('BEFORE CALLING THE TRANSFER API ', 1);
	     END IF;

	     inv_rcv_std_transfer_apis.create_transfer_rcvtxn_rec
	                                  (x_return_status       =>  l_return_status
					   , x_msg_count           =>  l_msg_count
					   , x_msg_data            =>  l_msg_data
					   , p_organization_id     =>  p_organization_id
					   , p_parent_txn_id       =>  l_parent_txn_id
					   , p_reference_id        =>  l_reference_id
					   , p_reference           =>  l_reference
					   , p_reference_type_code =>  l_reference_type_code
					   , p_item_id             =>  p_item_id
					   , p_revision            =>  p_revision
					   , p_subinventory_code   =>  p_subinventory_code
					   , p_locator_id          =>  p_locator_id
					   , p_transfer_quantity   =>  l_qty_to_insert
					   , p_transfer_uom_code   =>  p_transfer_uom_code
					   , p_lot_control_code    =>  p_lot_control_code
					   , p_serial_control_code =>  p_serial_control_code
					   , p_original_rti_id     =>  l_new_intf_id
					   , p_original_temp_id    =>  l_mmtt_id_to_insert
					   , p_lot_number          =>  p_lot_number
					   , p_lpn_id              =>  p_lpn_id
	       , p_transfer_lpn_id     =>  p_transfer_lpn_id
	       , p_sec_transfer_quantity   =>  l_secondary_quantity
	       , p_sec_transfer_uom_code   =>  p_sec_transfer_uom_code
	       );

	     IF (l_debug = 1) THEN
		print_debug('AFTER CALLING THE TRANSFER API: STATUS = '||l_return_status, 1);
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
           print_debug('MATCH TRANSFER RETURNING WITH SUCCESS RETUN STATUS = ' ||x_return_status, 1);
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      rollback to match_rti_ss;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      rollback to match_rti_ss;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN OTHERS THEN
      rollback to match_rti_ss;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error (
          'INV_RCV_STD_TRANSFER_APIS.MATCH_TRANSFER_RCVTXN_REC',
          l_progress,
          SQLCODE);
      END IF;
  END Match_transfer_rcvtxn_rec;

END INV_RCV_STD_TRANSFER_APIS;


/
