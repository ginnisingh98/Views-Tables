--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT3" AS
  /* $Header: INVLAP3B.pls 120.11.12010000.2 2010/04/12 23:56:04 sfulzele ship $ */

  label_b    CONSTANT VARCHAR2(50) := '<label';
  label_e    CONSTANT VARCHAR2(50) := '</label>' || fnd_global.local_chr(10);
  variable_b CONSTANT VARCHAR2(50) := '<variable name= "';
  variable_e CONSTANT VARCHAR2(50) := '</variable>' || fnd_global.local_chr(10);
  tag_e      CONSTANT VARCHAR2(50) := '>' || fnd_global.local_chr(10);
  l_debug             NUMBER;

  PROCEDURE TRACE(p_message VARCHAR2) IS
  BEGIN
    inv_label.TRACE(p_message, 'LABEL_LPN');
  END TRACE;

  PROCEDURE get_variable_data(
    x_variable_content       OUT NOCOPY    inv_label.label_tbl_type
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , x_return_status          OUT NOCOPY    VARCHAR2
  , p_label_type_info        IN            inv_label.label_type_rec
  , p_transaction_id         IN            NUMBER
  , p_input_param            IN            mtl_material_transactions_temp%ROWTYPE
  , p_transaction_identifier IN            NUMBER
  ) IS

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--   Following variables were added (as a part of 11i10+ 'Custom Labels' Project)            |
--   to retrieve and hold the SQL Statement and it's result.                                 |
---------------------------------------------------------------------------------------------
   l_sql_stmt  VARCHAR2(4000);
   l_sql_stmt_result VARCHAR2(4000) := NULL;
   TYPE sql_stmt IS REF CURSOR;
   c_sql_stmt sql_stmt;
   l_custom_sql_ret_status VARCHAR2(1);
   l_custom_sql_ret_msg VARCHAR2(2000);

   -- Fix for bug: 4179593 Start
   l_CustSqlWarnFlagSet BOOLEAN;
   l_CustSqlErrFlagSet BOOLEAN;
   l_CustSqlWarnMsg VARCHAR2(2000);
   l_CustSqlErrMsg VARCHAR2(2000);
   -- Fix for bug: 4179593 End

------------------------End of this change for Custom Labels project code--------------------

    CURSOR c_rti_lpn IS
      SELECT rti.lpn_id lpn_id
           , pha.segment1 purchase_order
           , rti.subinventory
           , rti.locator_id
        FROM rcv_transactions_interface rti, po_headers_trx_v pha--CLM Changes, using CLM views instead of base tables
       WHERE rti.interface_transaction_id = p_transaction_id
         AND rti.po_header_id = pha.po_header_id(+);

    CURSOR c_rti_lpn_inspection IS
      SELECT rti.transfer_lpn_id transfer_lpn_id
           , pha.segment1 purchase_order
           , rti.subinventory
           , rti.locator_id
        FROM rcv_transactions_interface rti, po_headers_trx_v pha--CLM Changes, using CLM views instead of base tables
       WHERE rti.interface_transaction_id = p_transaction_id
         AND rti.po_header_id = pha.po_header_id(+);

    CURSOR c_mmtt_lpn IS
      SELECT lpn_id
           , content_lpn_id
           , transfer_lpn_id
           , transfer_subinventory
           , subinventory_code
           , transaction_type_id
           , transaction_action_id
        -- Bug 2515486: Added transaction_type_id, transaction_action_id, inventory_item_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_transaction_id
         AND ROWNUM < 2;

    CURSOR c_mmtt_cart_lpn IS
      SELECT cartonization_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_transaction_id;

    CURSOR c_mmtt_pregen_lpn IS
      SELECT lpn_id
           , subinventory_code
           , locator_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_transaction_id;

    CURSOR c_wdd_lpn IS
      SELECT lpn_id
        FROM wsh_delivery_details
       WHERE delivery_detail_id = p_transaction_id;

    -- Bug 2825748 : WIP is passing a transaction_temp_id instead of
    -- wip_lpn_completions,header_id for both LPN and non-LPN Completions.
    CURSOR c_wip_lpn IS
      SELECT transfer_lpn_id
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_transaction_id;

    -- For business flow code of 33, the MMTT, MTI or MOL id is passed
    -- Depending on the txn identifier being passed,one of the
    -- following 2 flow csrs or the generic mmtt crsr will be called

    CURSOR c_flow_lpn_mol IS
      SELECT lpn_id
        FROM mtl_txn_request_lines
       WHERE line_id = p_transaction_id;

    CURSOR c_flow_lpn_mti IS
      SELECT lpn_id
        FROM mtl_transactions_interface
       WHERE transaction_interface_id = p_transaction_id;

    CURSOR c_wnd_lpn IS
      SELECT wdd2.lpn_id
        FROM wsh_new_deliveries wnd
           , wsh_delivery_assignments_v wda
           , wsh_delivery_details wdd1
           , wsh_delivery_details wdd2
       WHERE wnd.delivery_id = p_transaction_id
         AND wnd.delivery_id = wda.delivery_id
         AND wdd1.delivery_detail_id = wda.delivery_detail_id
         AND wdd2.delivery_detail_id = wda.parent_delivery_detail_id;

    l_subinventory_code      VARCHAR2(10)                            := NULL;
    l_locator_id             NUMBER                                  := NULL;
    l_locator                VARCHAR2(204)                           := NULL;

    /* Patchset J- Label printing support for Inbound.
     * This cursor will get the distinct LPN, Transfer LPN, and their parent LPN and outermost LPN
     * to be printed. Note that in a group of RTI records, there maybe many duplicate LPNs
     * so it is important to get a distinct list of LPNs so that they don't get printed many times.
     * After fetching from this cursor, the results will be saved into the new table of record type
     * rcv_lpn_table_type.
     * Note: records in RT are filtered by transaction_type and business_flow_code
     *   becuase it is possible for label-API to be called multiple times by RCV-TM
     *   in the case of ROI, when multiple trx.types are present in a group
     */

    CURSOR c_rt_lpn IS
      SELECT DISTINCT all_lpn.lpn_id
                    , pha.segment1 purchase_order
                    , all_lpn.subinventory
                    , all_lpn.locator_id
                 FROM (-- LPN_ID
                       SELECT lpn_id
                            , po_header_id
                            , subinventory
                            , locator_id
                         FROM rcv_transactions rt
                        WHERE lpn_id IS NOT NULL
                          AND rt.group_id = p_transaction_id
                          AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                                AND p_label_type_info.business_flow_code = 2)
                               OR (rt.transaction_type = 'DELIVER'
                                AND p_label_type_info.business_flow_code in (3,4))
                               OR (rt.transaction_type = 'RECEIVE'
			       /* modified for bug 4293052 :aujain*/
                               --    AND rt.routing_header_id <> 3
                                   AND p_label_type_info.business_flow_code = 1
                                  )
                              )
                       UNION ALL
                       -- PARENT LPN of LPN_ID
                       SELECT lpn.parent_lpn_id
                            , rt.po_header_id
                            , rt.subinventory
                            , rt.locator_id
                         FROM wms_license_plate_numbers lpn, rcv_transactions rt
                        WHERE lpn.lpn_id = rt.lpn_id
                       --   AND lpn.parent_lpn_id <> rt.lpn_id
                          AND rt.group_id = p_transaction_id
                          AND lpn.parent_lpn_id is not null
                          AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                                AND p_label_type_info.business_flow_code = 2)
                               OR (rt.transaction_type = 'DELIVER'
                                AND p_label_type_info.business_flow_code in (3,4))
                               OR (rt.transaction_type = 'RECEIVE'
			       /* modified for bug 4293052 :aujain*/
                                --   AND rt.routing_header_id <> 3
                                   AND p_label_type_info.business_flow_code = 1
                                  )
                              )
                       UNION ALL
                       -- OUTERMOSE LPN of LPN_ID, and different than the LPN and parent LPN
                       SELECT lpn.outermost_lpn_id
                            , rt.po_header_id
                            , rt.subinventory
                            , rt.locator_id
                         FROM wms_license_plate_numbers lpn, rcv_transactions rt
                        WHERE lpn.lpn_id = rt.lpn_id
                         -- AND lpn.outermost_lpn_id <> lpn.lpn_id
                        --  AND lpn.outermost_lpn_id <> lpn.parent_lpn_id
                          AND rt.group_id = p_transaction_id
                          AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                                AND p_label_type_info.business_flow_code = 2)
                               OR (rt.transaction_type = 'DELIVER'
                                AND p_label_type_info.business_flow_code in (3,4))
                               OR (rt.transaction_type = 'RECEIVE'
			       /* modified for bug 4293052 :aujain*/
                                 --  AND rt.routing_header_id <> 3
                                   AND p_label_type_info.business_flow_code = 1
                                  )
                              )
                       UNION ALL
                       -- Transfer LPN (different than LPN)
                       SELECT transfer_lpn_id lpn_id
                            , po_header_id
                            , subinventory
                            , locator_id
                         FROM rcv_transactions rt
                        WHERE
                          --rt.transfer_lpn_id <> rt.lpn_id AND
                         rt.group_id = p_transaction_id
                          AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                                AND p_label_type_info.business_flow_code = 2)
                               OR (rt.transaction_type = 'DELIVER'
                                AND p_label_type_info.business_flow_code in (3,4))
                               OR (rt.transaction_type = 'RECEIVE'
			       /* modified for bug 4293052 :aujain*/
                                   --AND rt.routing_header_id <> 3
                                   AND p_label_type_info.business_flow_code = 1
                                  )
                              )
                       UNION ALL
                       -- Parent LPN of Transfer LPN
                       SELECT lpn.parent_lpn_id
                            , rt.po_header_id
                            , rt.subinventory
                            , rt.locator_id
                         FROM wms_license_plate_numbers lpn, rcv_transactions rt
                        WHERE lpn.lpn_id = rt.transfer_lpn_id
                     --     AND rt.transfer_lpn_id <> rt.lpn_id
                       --   AND lpn.parent_lpn_id <> lpn.lpn_id
                          AND lpn.parent_lpn_id is not null
                          AND rt.group_id = p_transaction_id
                          AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                                AND p_label_type_info.business_flow_code = 2)
                               OR (rt.transaction_type = 'DELIVER'
                                AND p_label_type_info.business_flow_code in (3,4))
                               OR (rt.transaction_type = 'RECEIVE'
			       /* modified for bug 4293052 :aujain*/
                                   --AND rt.routing_header_id <> 3
                                   AND p_label_type_info.business_flow_code = 1
                                  )
                              )
                       UNION ALL
                       -- Outermost LPN of Transfer LPN
                       SELECT lpn.outermost_lpn_id
                            , rt.po_header_id
                            , rt.subinventory
                            , rt.locator_id
                         FROM wms_license_plate_numbers lpn, rcv_transactions rt
                        WHERE lpn.lpn_id = rt.transfer_lpn_id
                   --       AND rt.transfer_lpn_id <> rt.lpn_id
                     --     AND lpn.outermost_lpn_id <> lpn.lpn_id
                       --   AND lpn.outermost_lpn_id <> lpn.parent_lpn_id
                          AND rt.group_id = p_transaction_id
                          AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                                AND p_label_type_info.business_flow_code = 2)
                               OR (rt.transaction_type = 'DELIVER'
                                AND p_label_type_info.business_flow_code in (3,4))
                               OR (rt.transaction_type = 'RECEIVE'
			       /* modified for bug 4293052 :aujain*/
                                   --AND rt.routing_header_id <> 3
                                   AND p_label_type_info.business_flow_code = 1
                                  )
                              )) all_lpn
                    , po_headers_trx_v pha--CLM Changes, using CLM views instead of base tables
                    , wms_license_plate_numbers wlpn -- Bug 3836623
                WHERE pha.po_header_id(+) = all_lpn.po_header_id
                -- Bug 3836623
                -- Add check for LPN context
                -- When cross docking happens, label printing are called for both cross docking and putaway
                -- To prevent duplicate labels
                -- For putaway business flow, only print if LPN Context is not Picked (11)
                AND   wlpn.lpn_id = all_lpn.lpn_id
                AND   (p_label_type_info.business_flow_code <> 4 OR
                      (p_label_type_info.business_flow_code = 4 AND
                        wlpn.lpn_context <> 11));


    CURSOR c_lpn(p_lpn_id NUMBER) IS
      SELECT lpn.lpn_id lpn_id
           , lpn.license_plate_number lpn
           , msik.concatenated_segments lpn_container_item
           , lpn.inventory_item_id inventory_item_id
           , NVL(l_subinventory_code, lpn.subinventory_code) subinventory_code
           , lpn.revision revision
           , lpn.locator_id locator_id
           , inv_project.get_locsegs(
               milkfv.inventory_location_id
             , milkfv.organization_id
             ) LOCATOR
           , lpn.lot_number lot_number
           , lpn.serial_number serial_number
           , plpn.license_plate_number parent_lpn
           , olpn.license_plate_number outermost_lpn
           , mp.organization_code ORGANIZATION
           , lpn.organization_id organization_id
           , lpn.content_volume volume
           , lpn.content_volume_uom_code volume_uom
           , lpn.gross_weight gross_weight
           , lpn.gross_weight_uom_code gross_weight_uom
           , lpn.tare_weight tare_weight
           , lpn.tare_weight_uom_code tare_weight_uom
           , lpn.attribute_category CATEGORY
           , lpn.attribute1 attribute1
           , lpn.attribute2 attribute2
           , lpn.attribute3 attribute3
           , lpn.attribute4 attribute4
           , lpn.attribute5 attribute5
           , lpn.attribute6 attribute6
           , lpn.attribute7 attribute7
           , lpn.attribute8 attribute8
           , lpn.attribute9 attribute9
           , lpn.attribute10 attribute10
           , lpn.attribute11 attribute11
           , lpn.attribute12 attribute12
           , lpn.attribute13 attribute13
           , lpn.attribute14 attribute14
           , lpn.attribute15 attribute15
        FROM wms_license_plate_numbers lpn
           , wms_license_plate_numbers plpn
           , wms_license_plate_numbers olpn
           , mtl_system_items_kfv msik
           , mtl_parameters mp
           , mtl_item_locations milkfv
       WHERE lpn.lpn_id = p_lpn_id
         AND mp.organization_id(+) = lpn.organization_id
         AND msik.inventory_item_id(+) = lpn.inventory_item_id
         AND msik.organization_id(+) = lpn.organization_id
         AND milkfv.organization_id(+) = lpn.organization_id
         AND milkfv.subinventory_code(+) =
                                NVL(l_subinventory_code, lpn.subinventory_code)
         AND milkfv.inventory_location_id(+) =
                                              NVL(l_locator_id, lpn.locator_id)
         AND plpn.lpn_id(+) = lpn.parent_lpn_id
         AND olpn.lpn_id(+) = lpn.outermost_lpn_id;


    /* Bug 4891916 -Added the cursor to fetch records from mcce
                       at the time of cycle count entry for a particular entry*/
       CURSOR c_mcce_lpn_cur IS
         SELECT parent_lpn_id
              , subinventory
              , locator_id
              , mcch.cycle_count_header_name
              , ppf.full_name requestor
           FROM mtl_cycle_count_headers mcch,
                mtl_cycle_count_entries mcce,
                per_people_f ppf
          WHERE cycle_count_entry_id= p_transaction_id
            AND ppf.person_id(+) = mcce.counted_by_employee_id_current
            AND mcce.cycle_count_header_id=mcch.cycle_count_header_id;
       /* End of fix for Bug 4891916 */

       /* Bug 4891916- Added this cursor to get details like cycle count header name
                      and counter for the entry for the label printed at the time of
                      cycle count approval*/

       CURSOR cc_det_approval IS
         SELECT mcch.cycle_count_header_name,
                ppf.full_name requestor
          FROM  mtl_cycle_count_headers mcch,
                mtl_cycle_count_entries mcce,
                per_people_f ppf,
                mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_temp_id= p_transaction_id
            AND mmtt.cycle_count_id = mcce.cycle_count_entry_id
            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
            AND ppf.person_id(+) = mcce.counted_by_employee_id_current ;

      /* End of fix for Bug 4891916 */


    -- MOAC: Replaced the po_line_locations
    -- view with a _ALL table. The where
    -- clause is sufficient to stripe by
    -- OU

    /* bug 3841820 */
    CURSOR c_asn_lpn IS
        SELECT distinct
            all_lpn.lpn_id
          , pha.segment1 purchase_order
          , all_lpn.subinventory_code
          , all_lpn.locator_id
        FROM(
             select lpn.lpn_id
               , rsl.po_header_id, rsl.po_line_id
               , lpn.subinventory_code, lpn.locator_id
               , rsh.shipment_header_id
               , rsl.po_line_location_id
             from wms_license_plate_numbers lpn,
               rcv_shipment_headers rsh,
               rcv_shipment_lines rsl
             where lpn.source_name = rsh.shipment_num
               AND lpn.lpn_context = 7
               AND rsl.shipment_header_id = rsh.shipment_header_id
               and rsh.shipment_header_id = p_transaction_id
              and rsl.asn_lpn_id = lpn.lpn_id
               AND rsh.asn_type = 'ASN'
         UNION
             select lpn.parent_lpn_id
               , rsl.po_header_id, rsl.po_line_id
               , lpn.subinventory_code, lpn.locator_id
               , rsh.shipment_header_id
               , rsl.po_line_location_id
           from wms_license_plate_numbers lpn,
               rcv_shipment_headers rsh,
               rcv_shipment_lines rsl
             where lpn.source_name = rsh.shipment_num
               AND lpn.lpn_context = 7
               AND rsl.shipment_header_id = rsh.shipment_header_id
              and rsl.asn_lpn_id = lpn.lpn_id
               and rsh.shipment_header_id = p_transaction_id
               AND rsh.asn_type = 'ASN'
           UNION
             select lpn.outermost_lpn_id
               , rsl.po_header_id, rsl.po_line_id
               , lpn.subinventory_code, lpn.locator_id
               , rsh.shipment_header_id
               , rsl.po_line_location_id
           from wms_license_plate_numbers lpn,
               rcv_shipment_headers rsh,
               rcv_shipment_lines rsl
             where lpn.source_name = rsh.shipment_num
               AND lpn.lpn_context = 7
               AND rsl.shipment_header_id = rsh.shipment_header_id
               and rsh.shipment_header_id = p_transaction_id
              and rsl.asn_lpn_id = lpn.lpn_id
               AND rsh.asn_type = 'ASN'
          ) all_lpn
           , po_headers_trx_v pha--CLM Changes, using CLM views instead of base tables
           , po_lines_trx_v pol
           , rcv_shipment_headers rsh
           , po_line_locations_trx_v pll
   WHERE      pha.po_header_id(+)       = all_lpn.po_header_id
           AND   rsh.shipment_header_id(+) = all_lpn.shipment_header_id
           AND   pol.po_line_id  (+)       = all_lpn.po_line_id
           AND   pol.po_header_id (+)      = all_lpn.po_header_id
           AND   pll.line_location_id(+)   = all_lpn.po_line_location_id;

    --R12 PROJECT LABEL SET with RFID

    CURSOR c_label_formats_in_set(p_format_set_id IN NUMBER)  IS
       select wlfs.format_id label_format_id, wlf.label_entity_type --FOR SETS
	 from wms_label_set_formats wlfs , wms_label_formats wlf
	 where WLFS.SET_ID = p_format_set_id
	 and wlfs.set_id = wlf.label_format_id
	 and wlf.label_entity_type = 1
	 AND WLF.DOCUMENT_ID = 3
	 UNION --FOR FORMATS
	 select label_format_id,nvl(wlf.label_entity_type,0)
	 from wms_label_formats wlf
	 where  wlf.label_format_id =  p_format_set_id
	 and nvl(wlf.label_entity_type,0) = 0--for label formats only validation
	 AND WLF.DOCUMENT_ID = 3 ;



    l_lpn_id                 NUMBER;
    l_content_lpn_id         NUMBER;
    l_transfer_lpn_id        NUMBER;
    l_from_lpn_id            NUMBER;
    l_purchase_order         po_headers_all.segment1%TYPE;
    l_content_item_data      LONG;
    l_selected_fields        inv_label.label_field_variable_tbl_type;
    l_selected_fields_count  NUMBER;
    l_content_rec_index      NUMBER                                  := 0;
    l_label_format_set_id        NUMBER                                  := 0;
    l_label_format_id            NUMBER;
    l_label_format           VARCHAR2(100);
    l_printer                VARCHAR2(30);
    l_printer_sub            VARCHAR2(30)                            := NULL;
    l_api_name               VARCHAR2(20)                     := 'get_variable_data';
    l_return_status          VARCHAR2(240);
    l_error_message          VARCHAR2(240);
    l_msg_count              NUMBER;
    l_api_status             VARCHAR2(240);
    l_msg_data               VARCHAR2(240);
    l_lpn_table              inv_label.lpn_table_type;
    l_rcv_lpn_table          inv_label_pvt3.rcv_lpn_table_type;
    -- Bug 2515486
    l_transaction_type_id    NUMBER                                  := 0;
    l_transaction_action_id  NUMBER                                  := 0;
    i                        NUMBER;
    -- Added l_transaction_identifier, for flow
    -- Depending on when it is called, the driving table might be different
    -- 1 means MMTT is the driving table
    -- 2 means MTI is the driving table
    -- 3 means Mtl_txn_request_lines is the driving table

    l_transaction_identifier NUMBER                                  := 0;
    l_label_index            NUMBER;
    l_label_request_id       NUMBER;
    --I cleanup, use l_prev_format_id to record the previous label format
    l_prev_format_id         NUMBER;
    -- I cleanup, user l_prev_sub to record the previous subinventory
    --so that get_printer is not called if the subinventory is the same
    l_prev_sub               VARCHAR2(30);
    -- a list of columns that are selected for format
    l_column_name_list       LONG;

    --Bug 4891916. Added the following local variables to store the counter and cycle count name.
    l_requestor              per_people_f.full_name%TYPE;
    l_cycle_count_name       mtl_cycle_count_headers.cycle_count_header_name%TYPE;

    l_patch_level NUMBER;
    l_count NUMBER;

    l_rcv_isp_header rcv_isp_header_rec; -- Header-level info for ASN iSP

    -- Variable for EPC Generation
    -- Added for 11.5.10+ RFID Compliance project,
    -- Modified in R12
    l_epc VARCHAR2(300);
    l_epc_ret_status VARCHAR2(10);
    l_epc_ret_msg VARCHAR2(1000);
    l_label_status VARCHAR2(1);
    l_label_err_msg VARCHAR2(1000);
    l_is_epc_exist VARCHAR2(1) := 'N';
    l_label_formats_in_set NUMBER;

  BEGIN
    -- Initialize return status as success
    x_return_status      := fnd_api.g_ret_sts_success;
    l_debug              := inv_label.l_debug;

    IF (l_debug = 1) THEN
      TRACE('**In PVT3: LPN label**');
      TRACE(
           '  Business_flow='
        || p_label_type_info.business_flow_code
        || ', Transaction ID='
        || p_transaction_id
        || ', Transaction Identifier='
        || p_transaction_identifier
      );
    END IF;

    IF (inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j)
          AND (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)
          THEN
       l_patch_level := 1;
    ELSIF (inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j)
          AND
          (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)
           THEN
       l_patch_level := 0;
    END IF;


    -- Get l_lpn_id
    IF p_transaction_id IS NOT NULL THEN
      -- txn driven
      i  := 1;

      IF p_label_type_info.business_flow_code IN (1, 2, 3, 4) THEN
        -- Receipt, Inspection, Delivery
        -- Getting lpn_id from RTI
           /* Use the following loop for code below Inventory Patchset J level */
        IF (l_patch_level = 0)
            THEN
           trace('Patch level less than J');
          if p_label_type_info.business_flow_code = 2 THEN -- Inspection
             FOR v_rti_lpn_inspection IN c_rti_lpn_inspection LOOP
               l_lpn_table(i)       := v_rti_lpn_inspection.transfer_lpn_id;
               l_purchase_order     := v_rti_lpn_inspection.purchase_order;
               l_subinventory_code  := v_rti_lpn_inspection.subinventory;
               l_locator_id         := v_rti_lpn_inspection.locator_id;
               i                    := i + 1;
             END LOOP;
          else  -- else Receipt, delivery, putaway
            FOR v_rti_lpn IN c_rti_lpn LOOP
              l_lpn_table(i)       := v_rti_lpn.lpn_id;
              l_purchase_order     := v_rti_lpn.purchase_order;
              l_subinventory_code  := v_rti_lpn.subinventory;
              l_locator_id         := v_rti_lpn.locator_id;
              i                    := i + 1;
            END LOOP;
          end if;
        END IF;

        /* We will open up the new cursor c_rt_lpn from Patchset J onwards */
        IF (l_patch_level = 1) THEN
           trace('Patchset J code ');
          FOR v_rti_lpn IN c_rt_lpn LOOP
            l_rcv_lpn_table(i).lpn_id             := v_rti_lpn.lpn_id;
            l_rcv_lpn_table(i).purchase_order     := v_rti_lpn.purchase_order;
            l_rcv_lpn_table(i).subinventory_code  := v_rti_lpn.subinventory;
            l_rcv_lpn_table(i).locator_id         := v_rti_lpn.locator_id;
            i                                     := i + 1;
          END LOOP;
        END IF;
      ELSIF p_label_type_info.business_flow_code IN (6) THEN
        -- Cross-Dock and Pick Drop
        -- The delivery_detail_id of the line in WDD which has the LPN_ID
        -- is passed , get lpn_id from WDD lines
        FOR v_wdd_lpn IN c_wdd_lpn LOOP
          l_lpn_table(i)  := v_wdd_lpn.lpn_id;
          i               := i + 1;
        END LOOP;
        /* bug 3841820 */
      ELSIF p_label_type_info.business_flow_code = INV_LABEL.WMS_BF_IMPORT_ASN AND
            p_transaction_identifier = INV_LABEL.TRX_ID_RSH THEN
           trace('business flow code is asn import and txnid is 6');
         -- New Architecture for ASN : Get LPN details from RSH :J-DEV
         -- Applicable with DM.J and IProc.J
         -- First retrieve the header level info
         SELECT shipment_num asn_num, shipped_date shipment_date,
                expected_receipt_date,freight_terms,
                freight_carrier_code, num_of_containers,
                bill_of_lading, waybill_airbill_num,
                packing_slip,
                packaging_code, special_handling_code,
                receipt_num, comments
         INTO l_rcv_isp_header.asn_num, l_rcv_isp_header.shipment_date,
                 l_rcv_isp_header.expected_receipt_date, l_rcv_isp_header.freight_terms,
                 l_rcv_isp_header.freight_carrier, l_rcv_isp_header.num_of_containers,
                 l_rcv_isp_header.bill_of_lading, l_rcv_isp_header.waybill_airbill_num,
                 l_rcv_isp_header.packing_slip,
                 l_rcv_isp_header.packaging_code, l_rcv_isp_header.special_handling_code,
                 l_rcv_isp_header.receipt_num, l_rcv_isp_header.comments
         FROM rcv_shipment_headers
         WHERE shipment_header_id = p_transaction_id;

           FOR v_asn_lpn IN c_asn_lpn LOOP
            l_rcv_lpn_table(i).lpn_id             := v_asn_lpn.lpn_id;
            l_rcv_lpn_table(i).purchase_order     := v_asn_lpn.purchase_order;
            l_rcv_lpn_table(i).subinventory_code  := v_asn_lpn.subinventory_code;
            l_rcv_lpn_table(i).locator_id         := v_asn_lpn.locator_id;
            i                                     := i + 1;
           END LOOP;
      -- Bug 4277718
      -- for WIP completion, lpn_id is used rather than transfer_lpn_id
      -- Changed to use c_mmtt_lpn
      /*ELSIF p_label_type_info.business_flow_code IN (26) THEN
        -- WIP Completion
        FOR v_wip_lpn IN c_wip_lpn LOOP
          l_lpn_table(i)  := v_wip_lpn.transfer_lpn_id;
          i               := i + 1;
        END LOOP;*/
      ELSIF p_label_type_info.business_flow_code IN (21) THEN
        -- Ship confirm, delivery_id is passed
        -- Get all the LPNs for this delivery
        FOR v_wnd_lpn IN c_wnd_lpn LOOP
          l_lpn_table(i)  := v_wnd_lpn.lpn_id;
          i               := i + 1;
        END LOOP;
      ELSIF p_label_type_info.business_flow_code IN (22) THEN
        -- Cartonization:
        -- According to the new design, the LPN ID is passed in.
        -- Print the LPN inforamtion for the LPN passed.
        l_lpn_table(1)  := p_transaction_id;
      ELSIF p_label_type_info.business_flow_code IN (27) THEN
        -- Putaway pregeneration
        -- Get lpn_id from mmtt
        FOR v_pregen_lpn IN c_mmtt_pregen_lpn LOOP
          l_lpn_table(1)       := v_pregen_lpn.lpn_id;
          l_subinventory_code  := v_pregen_lpn.subinventory_code;
          l_locator_id         := v_pregen_lpn.locator_id;
        END LOOP;
      ELSIF  p_label_type_info.business_flow_code IN (33)
             AND p_transaction_identifier > 1 THEN
        -- Flow Completion, not MMTT based

        IF p_transaction_identifier = 2 THEN
          IF (l_debug = 1) THEN
            TRACE('Flow Label - MTI based');
          END IF;

          FOR v_flow_mti_lpn IN c_flow_lpn_mti LOOP
            l_lpn_table(i)  := v_flow_mti_lpn.lpn_id;
            i               := i + 1;
          END LOOP;
        ELSIF p_transaction_identifier = 3 THEN
          IF (l_debug = 1) THEN
            TRACE('Flow Label - MOL based');
          END IF;

          FOR v_flow_mol_lpn IN c_flow_lpn_mti LOOP
            l_lpn_table(i)  := v_flow_mol_lpn.lpn_id;
            i               := i + 1;
          END LOOP;
        END IF;
      -- Fix bug 2167545-1: Cost Group Update(11) is calling label printing through TM
         --  not manually, add 11 in the following group.


      -- Added Flow business code., if it is mmtt based,we can
      -- USE the same crsr
      -- Bug 4277718
      -- for WIP completion, lpn_id is used rather than transfer_lpn_id
      -- Changed to use c_mmtt_lpn

      --Bug 4891916. Modified the condition for business flow for cycle count
      --by checking for the business flow 8 and transaction_identifier as 5

      ELSIF p_label_type_info.business_flow_code IN
                   (7,/* 8,*/ 9, 11, 12, 13, 14, 15, 18, 19, 20, 23, 28, 29, 30, 34, 26)
        OR (p_label_type_info.business_flow_code IN (33) AND p_transaction_identifier = 1)
        OR(p_label_type_info.business_flow_code = 8 AND p_transaction_identifier = 5)
      THEN
        -- Obtain lpn_id, content_lpn_id, transfer_lpn_id from
        -- MMTT record.
        OPEN c_mmtt_lpn;
        FETCH c_mmtt_lpn INTO l_from_lpn_id
                            , l_content_lpn_id
                            , l_transfer_lpn_id
                            , l_subinventory_code
                            , l_printer_sub
                            , l_transaction_type_id
                            , l_transaction_action_id;

        -- Bug 2515486: Added transaction_type_id, transaction_action_id, inventory_item_id       ;

        IF (l_debug = 1) THEN
          TRACE(
               'From LPN ID : '
            || l_from_lpn_id
            || ',Content LPN ID : '
            || l_content_lpn_id
            || ',Transfer LPN ID : '
            || l_transfer_lpn_id
            || ',Transaction Type ID : '
            || l_transaction_type_id
            || ',Transaction Action ID : '
            || l_transaction_action_id
          );
        END IF;

        IF c_mmtt_lpn%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' No lpn_id found in MMTT for given ID: '|| p_transaction_id);
          END IF;

          CLOSE c_mmtt_lpn;
          RETURN;
        ELSE
          CLOSE c_mmtt_lpn;

          --Bug 4891916. For cycle count, opened the cursor to fetch values for
          --cycle count header name and counter
             IF p_label_type_info.business_flow_code = 8  THEN

               OPEN cc_det_approval ;
               FETCH cc_det_approval
                INTO l_cycle_count_name
                   , l_requestor ;

               IF cc_det_approval%NOTFOUND THEN
                 IF (l_debug = 1) THEN
                   TRACE(' No record found in MMTT for a cycle count id for given txn_temp_id: ' || p_transaction_id);
                 END IF;
                 CLOSE cc_det_approval;
               ELSE
                 CLOSE cc_det_approval ;
               END IF;

             END IF;--End of business flow=8 condition

          --End of fix for Bug 4891916

          -- Bug 2515486
          -- This check ensures that the content LPN ID is not added to the l_lpn_table for
          -- LPN Consolidation.
          --Bug 3277260
          -- Updated the condition to make sure that the LPN ID is not added for Pick-Drop
         -- Business Flow(19).
          IF (l_content_lpn_id IS NOT NULL) THEN
            IF ((l_transaction_type_id = 87 AND l_transaction_action_id = 50) AND
                (p_label_type_info.business_flow_code = 20 OR p_label_type_info.business_flow_code = 19)) THEN
              IF (l_debug = 1) THEN
                TRACE('The Content LPN ID is not added to the l_lpn_table');
              END IF;
            ELSE
              l_lpn_table(i)  := l_content_lpn_id;

              IF (l_debug = 1) THEN
                TRACE('Content LPN ID has been added to the l_lpn_table');
              END IF;

              i               := i + 1;
            END IF;
          END IF;

          /* Start of fix for bug # 4751587 */
          /* The following condition has been added for fixing the bug # 4751587
             For Cost Group Update Bussiness Flow (11), only one label has to be generated with
             the updated cost group. Hence the following code (incrementing i, which controls the
             loop iteration) will be executed only if the business flow code is not 11
             i.e. Cost Group Update Business flow */

          IF (p_label_type_info.business_flow_code NOT IN (11, 28, 29)) THEN  -- Modified for bug # 4911236
            IF (l_transfer_lpn_id IS NOT NULL)
                AND(NVL(l_transfer_lpn_id, -999) <> NVL(l_content_lpn_id, -999)) THEN
              l_lpn_table(i)  := l_transfer_lpn_id;
              i               := i + 1;
            END IF;
          END IF;

       /*   IF  (l_transfer_lpn_id IS NOT NULL)
              AND (NVL(l_transfer_lpn_id, -999) <> NVL(l_content_lpn_id, -999)) THEN
            l_lpn_table(i)  := l_transfer_lpn_id;
            i               := i + 1;
          END IF; */

         /* End of fix for bug # 4751587 */


          -- Bug 2367828 : In case of LPN Splits, the LPN labels were being printed for
          -- the new LPN being generated, but nothing for the existing LPN from which the
          -- the new LPN was being split.  l_from_lpn_id is the mmtt.lpn_id(the from LPN)
          IF (l_from_lpn_id IS NOT NULL
          AND p_label_type_info.business_flow_code NOT IN(28, 29)) THEN   -- Added for bug # 4911236
            l_lpn_table(i)  := l_from_lpn_id;
          ELSIF (p_label_type_info.business_flow_code IN (28, 29)) THEN -- Added for bug # 4911236
            l_lpn_table(i)  := l_transfer_lpn_id;
          END IF;

          /* for pick load and replenishment load, need the from sub to get_printer
            , otherwise, use to_sub to get printer */
          IF p_label_type_info.business_flow_code NOT IN (18, 34) THEN
            l_printer_sub  := NULL;
          END IF;
        END IF;
      -- 18th February 2002 : Commented out below for fix to bug 2219171 for Qualcomm. Hence forth the
      -- WMSTASKB.pls will be calling label printing at Pick Load and WIP Pick Load with the
      -- transaction_temp_id as opposed to the transaction_header_id earlier. These business flows(18, 28)
      -- have been added to  the above call.
      -- ELSIF p_label_type_info.business_flow_code in (18,28,34) THEN
        -- Pick Load
        -- Get transfer_lpn_id from mmtt with the given header_id
      --  FOR v_mmtt_header_lpn IN c_mmtt_header_lpn LOOP
      --    l_lpn_table(i) := v_mmtt_header_lpn.transfer_lpn_id;
      --    i := i +1;
      --  END LOOP;

      --Bug 4891916. Added the condition to open the cursor to fetch from mcce
      --by checking for business flow 8 and transaction identifier 4
         ELSIF p_label_type_info.business_flow_code = 8 AND p_transaction_identifier = 4  THEN
           IF (l_debug = 1) THEN
             TRACE(' IN the condition for bus flow 8 and pti 4 ');
           END IF;

           OPEN  c_mcce_lpn_cur ;

           FETCH c_mcce_lpn_cur
            INTO l_lpn_id,
                 l_subinventory_code,
                 l_locator_id,
                 l_cycle_count_name,
                 l_requestor ;
           IF c_mcce_lpn_cur%NOTFOUND THEN
             IF (l_debug = 1) THEN
               TRACE(' No record in mcce for this transaction_id:' || p_transaction_id);
             END IF;

             CLOSE c_mcce_lpn_cur;
             RETURN;
           ELSE
             IF l_lpn_id IS NOT NULL THEN
               l_lpn_table(1)  := l_lpn_id;
             END IF;
             CLOSE c_mcce_lpn_cur ;
           END IF;
      --End of fix for Bug 4891916
      ELSE
         IF (l_debug = 1) THEN
          TRACE(
               ' Invalid business flow code '
            || p_label_type_info.business_flow_code
          );
        END IF;

        RETURN;
      END IF;
    ELSE
      -- On demand, get information from input_param
      -- for transactions which don't have a mmtt row in the table,
      -- they will also call in a manual mode, they are
      -- 5 LPN Correction/Update
      -- 10 Material Status update
      -- 16 LPN Generation
      -- 25 Import ASN
      l_lpn_table(1)  := p_input_param.lpn_id;
    END IF;

    IF (l_debug = 1) THEN
      TRACE(' No. of LPN_IDs found in l_lpn_table: '|| l_lpn_table.COUNT);
    END IF;

    IF (l_debug = 1) THEN
      FOR i IN 1 .. l_lpn_table.COUNT LOOP
        TRACE(' LPN_ID('|| i || ')' || l_lpn_table(i));
      END LOOP;
    END IF;

    IF p_label_type_info.business_flow_code = 22 THEN
      -- Cartonization, only print the distinct LPN
      IF (l_debug = 1) THEN
        TRACE(' G_LPN_ID = '|| g_lpn_id);
      END IF;

      IF g_lpn_id = -1 THEN
        g_lpn_id  := l_lpn_table(1);
      ELSIF l_lpn_table(1) = g_lpn_id THEN
        RETURN;
      ELSE
        g_lpn_id  := l_lpn_table(1);
      END IF;
    END IF;

    IF l_lpn_table.COUNT = 0 AND l_rcv_lpn_table.count = 0 THEN
      IF (l_debug = 1) THEN
        TRACE(' No LPN found, can not process ');
      END IF;

      RETURN;
    END IF;


    l_content_rec_index  := 0;
    l_content_item_data  := '';

    IF (l_debug = 1) THEN
      TRACE('** in PVT3.get_variable_dataa ** , start ');
    END IF;

    l_printer            := p_label_type_info.default_printer;
    --x_variable_content := '';
    l_label_index        := 1;
    l_prev_format_id     := -999;
    l_prev_sub           := '####';
    trace('patch level is ' || l_patch_level || ' and businessflow code is ' || p_label_type_info.business_flow_code);
    IF (l_patch_level = 1 AND (p_label_type_info.business_flow_code IN (1,2, 3, 4, 25))
        ) THEN
       l_count := l_rcv_lpn_table.COUNT;
    ELSE
       l_count := l_lpn_table.COUNT;
    END IF;
    trace('count is ' || l_count);

    --
    FOR i IN 1 .. l_count LOOP
       trace('inside for loop ' || i || ' patch level is ' || l_patch_level);
       IF ((l_patch_level = 1) AND (p_label_type_info.business_flow_code IN (1,2, 3, 4, 25))) THEN
          IF l_rcv_lpn_table(i).lpn_id IS NOT NULL THEN
             trace(' patch level is 1.. lpn id is ' || l_lpn_id);
             l_lpn_id := l_rcv_lpn_table(i).lpn_id;
          END IF;
       ELSE
          l_lpn_id             := l_lpn_table(i);
          trace(' patch level is 0.. lpn id is ' || l_lpn_id);
       END IF;

      IF (l_debug = 1) THEN
        TRACE(' ^^^^ Getting New label for LPN_ID: '|| l_lpn_id);
      END IF;

      l_content_item_data  := '';

      /* Post Patchset J, subinventory code, locator_id, purchase_order are also present in
       * the l_rcv_lpn_table
       */
      IF (l_patch_level = 1) AND (p_label_type_info.business_flow_code IN (1, 2,3, 4, 25)) THEN
         IF l_rcv_lpn_table(i).lpn_id IS NOT NULL THEN
           trace(' patch level is 1..');
          l_subinventory_code  := l_rcv_lpn_table(i).subinventory_code;
          l_locator_id         := l_rcv_lpn_table(i).locator_id;
          l_purchase_order     := l_rcv_lpn_table(i).purchase_order;
         END IF;
      END IF;

      FOR v_lpn_content IN c_lpn(l_lpn_id) LOOP
        l_content_rec_index  := l_content_rec_index + 1;
        -- Bug 4238729, 10+ CU2 bug
        -- Moved set label status and message here.
        l_label_status := INV_LABEL.G_SUCCESS;
        l_label_err_msg := NULL;

        IF (l_debug = 1) THEN
          TRACE(' In Loop '|| l_content_rec_index);
        END IF;


	IF (l_debug = 1) THEN
	   TRACE(' Calling Rules Engine ');

	   TRACE( 'manual_format_id='
		  || p_label_type_info.manual_format_id
		  || ',manual_format_name='
		  || p_label_type_info.manual_format_name
		  );
        END IF;


	--In R12 moved this Rules engine call before the call to get printer
        /* insert a record into wms_label_requests entity to
         call the label rules engine to get appropriate label
	 In this call if this happens to be for the label-set, the record
	 from wms_label_request will be deleted inside following API*/

	  inv_label.get_format_with_rule
	  (
	   p_document_id                => p_label_type_info.label_type_id
	   , p_label_format_id            => p_label_type_info.manual_format_id
	   , p_organization_id            => v_lpn_content.organization_id
	   , p_inventory_item_id          => v_lpn_content.inventory_item_id
	   , p_subinventory_code          => v_lpn_content.subinventory_code
	   , p_locator_id                 => v_lpn_content.locator_id
	   , p_lpn_id                     => v_lpn_content.lpn_id
	   , p_lot_number                 => v_lpn_content.lot_number
	   , p_revision                   => v_lpn_content.revision
	   , p_serial_number              => v_lpn_content.serial_number
	   , p_business_flow_code         => p_label_type_info.business_flow_code
	   , p_last_update_date           => SYSDATE
	   , p_last_updated_by            => fnd_global.user_id
	   , p_creation_date              => SYSDATE
	   , p_created_by                 => fnd_global.user_id
	   --, p_printer_name               => l_printer --not used post R12
	  , x_return_status              => l_return_status
	  , x_label_format_id            => l_label_format_set_id
	  , x_label_format               => l_label_format
	  , x_label_request_id           => l_label_request_id
        );

        IF l_return_status <> 'S' THEN
          fnd_message.set_name('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
          fnd_msg_pub.ADD;
          l_label_format_set_id     := p_label_type_info.default_format_id;
          l_label_format         := p_label_type_info.default_format_name;
        END IF;


	--for manual printer, l_label_format_set_id returned from above API
	--will be infact p_label_type_info.manual_format_id which can be a
	--label set or a label format


	--Added in R12 for Label sets with RFID
	--l_label_format_set_idreturned by the rules engine can be either a
	--label format OR a label set
	IF (l_debug = 1) THEN
	    TRACE('^^^^^^^^^^^^^^^^Label-sets^^^^^^^^^^^^');
	   TRACE(' looping though formats in set begins, format_id/set_id :'||l_label_format_set_id);
	END IF;


	-- this CURSOR c_label_formats_in_set() will give all formats in the
	-- SET or just the current format

	FOR l_label_formats_in_set IN c_label_formats_in_set(l_label_format_set_id) LOOP

	   IF (l_debug = 1) THEN
	      TRACE(' Format_id for Current set :'||l_label_formats_in_set.label_format_id);
	   END IF;

	   --CODE logic
	   -- If it is label-SET then
	   ---- after getting all the formats inside a label SET calling the
	   ----get_format_with_rule() is same. Just need to
	   ----1 Insert record into WMS_LABEL_REQUESTS
	   ----2 get value of l_label_format_id, l_label_format, l_label_request_id
	   ----3 Do not call Rules Engine again, as we know format id
	   --else
	   ----Do not call get_format_with_rule(), just use the format-id

	   IF l_label_formats_in_set.label_entity_type = 1 THEN --IT IS LABEL SET

	      --In R12 call this API for the format AGAIN without calling Rules ENGINE
	      /* insert a record into wms_label_requests entity  */


	      inv_label.get_format_with_rule
		(
		 p_document_id                  => p_label_type_info.label_type_id
		 , p_label_format_id            => l_label_formats_in_set.label_format_id --considers manual printer also
		 , p_organization_id            => v_lpn_content.organization_id
		 , p_inventory_item_id          => v_lpn_content.inventory_item_id
		 , p_subinventory_code          => v_lpn_content.subinventory_code
		 , p_locator_id                 => v_lpn_content.locator_id
		 , p_lpn_id                     => v_lpn_content.lpn_id
		 , p_lot_number                 => v_lpn_content.lot_number
		 , p_revision                   => v_lpn_content.revision
		 , p_serial_number              => v_lpn_content.serial_number
		 , p_business_flow_code         => p_label_type_info.business_flow_code
		 , p_last_update_date           => SYSDATE
		 , p_last_updated_by            => fnd_global.user_id
		 , p_creation_date              => SYSDATE
		 , p_created_by                 => fnd_global.user_id
		 --, p_printer_name               => l_printer --not used post R12
		, p_use_rule_engine            => 'N' --------------------------Rules ENgine will NOT get called
		, x_return_status              => l_return_status
		, x_label_format_id            => l_label_format_id
		, x_label_format               => l_label_format
		, x_label_request_id           => l_label_request_id
		);

	      IF l_return_status <> 'S' THEN
		 fnd_message.set_name('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
		 fnd_msg_pub.ADD;
		 l_label_format_id     := p_label_type_info.default_format_id;
		 l_label_format   := p_label_type_info.default_format_name;
	      END IF;

	      IF (l_debug = 1) THEN
		 TRACE(
		       'did apply label '
		       || l_label_format
		       || ','
		       || l_label_format_id
		       || ',req_id '
		       || l_label_request_id
		       );
	      END IF;

	    ELSE --IT IS LABEL FORMAT
	      --Just use the format-id returned

	      l_label_format_id :=  l_label_formats_in_set.label_format_id ;

	   END IF;


	   IF (l_debug = 1) THEN
	      TRACE(
		    ' Getting printer label_format_id :'||l_label_format_id
		 || ', manual_printer='
		    || p_label_type_info.manual_printer
		 || ',sub='
		 || NVL(l_printer_sub, v_lpn_content.subinventory_code)
		 || ',default printer='
		 || p_label_type_info.default_printer
		 );
        END IF;


	-- IF clause Added for Add format/printer for manual request
        IF p_label_type_info.manual_printer IS NULL THEN
          -- The p_label_type_info.manual_printer is the one  passed from the manual page.
	   -- As per the design, if a printer is passed from the manual page, then we use that printer irrespective.

	   IF  (NVL(l_printer_sub, v_lpn_content.subinventory_code) IS NOT NULL)
	     AND (NVL(l_printer_sub, v_lpn_content.subinventory_code) <>
		  l_prev_sub
                  ) THEN
            BEGIN
	       wsh_report_printers_pvt.get_printer
		 ( p_concurrent_program_id      => p_label_type_info.label_type_id
		   , p_user_id                    => fnd_global.user_id
		   , p_responsibility_id          => fnd_global.resp_id
		   , p_application_id             => fnd_global.resp_appl_id
		   , p_organization_id            => v_lpn_content.organization_id
		   , p_zone                       => NVL(l_printer_sub,v_lpn_content.subinventory_code)
		   , p_format_id                  => l_label_format_id --added in R12
		   , x_printer                    => l_printer
		   , x_api_status                 => l_api_status
		   , x_error_message              => l_error_message
		   );

              IF l_api_status <> 'S' THEN
                IF (l_debug = 1) THEN
                  TRACE(
                       'Error in calling get_printer, set printer as default printer, err_msg:'
                    || l_error_message
                  );
                END IF;

                l_printer  := p_label_type_info.default_printer;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                l_printer  := p_label_type_info.default_printer;
            END;

            l_prev_sub  := NVL(l_printer_sub, v_lpn_content.subinventory_code);
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            TRACE(
                 'Set printer as Manual Printer passed in:'
              || p_label_type_info.manual_printer
            );
          END IF;

          l_printer  := p_label_type_info.manual_printer;
        END IF;


        IF (l_label_format_id IS NOT NULL) THEN
          -- Derive the fields for the format either passed in or derived via the rules engine.
          IF l_label_format_id <> NVL(l_prev_format_id, -999) THEN
            IF (l_debug = 1) THEN
              TRACE(' Getting variables for new format '|| l_label_format);
            END IF;

	    /* Changed for R12 RFID project
	    * while getting variables for format
	      * Check whether EPC field is included in the format
	      * If it is included, it will later query WMS_LABEL_FORMATS
	      * table to get RFID related information
	      * Otherwise, it does not need to do that
	      */

	      inv_label.get_variables_for_format
	      (
	       x_variables                  => l_selected_fields
	       , x_variables_count            => l_selected_fields_count
	       , x_is_variable_exist          => l_is_epc_exist
	       , p_format_id                  => l_label_format_id
	       , p_exist_variable_name        => 'EPC'
	       );
            l_prev_format_id  := l_label_format_id;

            IF (l_selected_fields_count = 0)
               OR (l_selected_fields.COUNT = 0) THEN
              IF (l_debug = 1) THEN
                TRACE(
                     'no fields defined for this format: '
                  || l_label_format
                  || ','
                  || l_label_format_id
                );
		TRACE('######## GOING TO NEXT LABEL #######');
	      END IF;

              GOTO nextlabel;
            END IF;

            IF (l_debug = 1) THEN
              TRACE(
                   '   Found selected_fields for format '
                || l_label_format
                || ', num='
                || l_selected_fields_count
              );
            END IF;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            TRACE('No format exists for this label, goto nextlabel');
          END IF;

          GOTO nextlabel;
        END IF;

        -- Added for 11.5.10+ RFID compliance project
        -- Get RFID/EPC related information for a format
        -- Only do this if EPC is a field included in the format
        IF l_is_epc_exist = 'Y' THEN
            IF (l_debug =1) THEN
                trace('EPC is a field included in the format, getting RFID/EPC related information from format');
            END IF;
            l_epc := null;
            BEGIN

              -- Added for 11.5.10+ RFID Compliance project
              -- New field : EPC
              -- When generate_epc API returns E (expected error) or U(expected error),
              --   it sets the error message, but generate xml with EPC as null

                -- R12 changed the call-- changed spec WMS_EPC_PVT.generate_epc()

		WMS_EPC_PVT.generate_epc
		  (p_org_id          => v_lpn_content.organization_id,
		   p_label_type_id   => p_label_type_info.label_type_id, -- 3
		   p_group_id	     => inv_label.epc_group_id,
		   p_label_format_id => l_label_format_id,
		   p_label_request_id    => l_label_request_id,
		   p_business_flow_code  => p_label_type_info.business_flow_code,
		   x_epc                 => l_epc,
		   x_return_status       => l_epc_ret_status, -- S / E / U
		   x_return_mesg         => l_epc_ret_msg
		   );

		IF (l_debug = 1) THEN
		   trace('Called generate_epc with ');
		   trace('p_lpn_id='||v_lpn_content.lpn_id||',p_group_id='||inv_label.epc_group_id);
		   trace('l_label_format_id='||l_label_format_id||',p_user_id='||fnd_global.user_id);
		   trace('p_org_id='||v_lpn_content.organization_id);
		   trace('l_label_request_id= '||l_label_request_id);
		   trace('x_epc='||l_epc);
		   trace('x_return_status='||l_epc_ret_status);
		   trace('x_return_mesg='  ||l_epc_ret_msg);
		END IF;

		IF l_epc_ret_status = 'S' THEN
		   -- Success
                      IF (l_debug = 1) THEN
                          trace('Succesfully generated EPC '||l_epc);
                      END IF;
                   ELSIF l_epc_ret_status = 'U' THEN
                      -- Unexpected error
                      l_epc := null;
                      IF(l_debug = 1) THEN
                          trace('Got unexpected error from generate_epc, msg='||l_epc_ret_msg);
                          trace('Set label status as Error and l_epc = null');
                      END IF;

                   ELSIF l_epc_ret_status = 'E' THEN
                      -- Expected error
                      l_epc := null;
                      IF(l_debug = 1) THEN
                          trace('Got expected error from generate_epc, msg='||l_epc_ret_msg);
                          trace('Set label status as Warning and l_epc = null');
                      END IF;
                   ELSE
                            trace('generate_epc returned a status that is not recognized, set epc as null');
                            l_epc := null;
                   END IF;
                   -- End Bug

            EXCEPTION
                WHEN no_data_found THEN
                    IF(l_debug =1 ) THEN
                       trace('No format found when retrieving EPC information. Format_id='||l_label_format_id);
                    END IF;
                WHEN others THEN
                    IF(l_debug =1 ) THEN
                       trace('Other error when retrieving EPC information. Format_id='||l_label_format_id);
                    END IF;
            END;
        ELSE
            IF (l_debug =1) THEN
                trace('EPC is not a field included in the format');
            END IF;
        END IF;




        /* variable header */

        l_content_item_data  :=  l_content_item_data || label_b;

        IF l_label_format <> NVL(p_label_type_info.default_format_name, '@@@') THEN
          l_content_item_data  :=    l_content_item_data
                                  || ' _FORMAT="'
                                  || l_label_format
                                  || '"';
        END IF;

        IF  (l_printer IS NOT NULL)
            AND (l_printer <> NVL(p_label_type_info.default_printer, '###')) THEN
          l_content_item_data  :=
                       l_content_item_data || ' _PRINTERNAME="' || l_printer || '"';
        END IF;

        l_content_item_data  :=  l_content_item_data || tag_e;

        IF (l_debug = 1) THEN
          TRACE('Starting assign variables, ');
        END IF;

        l_column_name_list             :=     'Set variables for ';

        -- Fix for bug: 4179593 Start
        l_custom_sql_ret_status := FND_API.G_RET_STS_SUCCESS;
        l_CustSqlWarnFlagSet := FALSE;
        l_CustSqlErrFlagSet := FALSE;
        l_CustSqlWarnMsg := NULL;
        l_CustSqlErrMsg := NULL;
        -- Fix for bug: 4179593 End

        /* Loop for each selected fields, find the columns and write into the XML_content*/
        FOR i IN 1 .. l_selected_fields.COUNT LOOP
          IF (l_debug = 1) THEN
            l_column_name_list  :=
                    l_column_name_list || ',' || l_selected_fields(i).column_name;
          END IF;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  The check (SQL_STMT <> NULL and COLUMN_NAME = NULL) implies that the field is a          |
--  Custom SQL based field. Handle it appropriately.                                         |
---------------------------------------------------------------------------------------------
          IF (l_selected_fields(i).SQL_STMT IS NOT NULL AND l_selected_fields(i).column_name = 'sql_stmt') THEN
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP3B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
              trace('Custom Labels Trace [INVLAP3B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
              trace('Custom Labels Trace [INVLAP3B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
              trace('Custom Labels Trace [INVLAP3B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
              trace('Custom Labels Trace [INVLAP3B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
             END IF;
             l_sql_stmt := l_selected_fields(i).sql_stmt;
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP3B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
             END IF;
             l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP3B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);

             END IF;
             BEGIN
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP3B.pls]: At Breadcrumb 1');
              trace('Custom Labels Trace [INVLAP3B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
             END IF;
             OPEN c_sql_stmt FOR l_sql_stmt using l_label_request_id;
             LOOP
                 FETCH c_sql_stmt INTO l_sql_stmt_result;
                 EXIT WHEN c_sql_stmt%notfound OR c_sql_stmt%rowcount >=2;
             END LOOP;

          IF (c_sql_stmt%rowcount=1 AND l_sql_stmt_result IS NULL) THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_custom_sql_ret_status := INV_LABEL.G_WARNING;
                fnd_message.set_name('WMS','WMS_CS_NULL_VALUE_RETURNED');
                fnd_msg_pub.ADD;
                -- Fix for bug: 4179593 Start
                --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                l_CustSqlWarnFlagSet := TRUE;
                -- Fix for bug: 4179593 End
             IF (l_debug = 1) THEN
               trace('Custom Labels Trace [INVLAP3B.pls]: At Breadcrumb 2');
               trace('Custom Labels Trace [INVLAP3B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
               trace('Custom Labels Trace [INVLAP3B.pls]: WARNING: NULL value returned.');
               trace('Custom Labels Trace [INVLAP3B.pls]: l_custom_sql_ret_status is set to : ' || l_custom_sql_ret_status);
             END IF;
          ELSIF c_sql_stmt%rowcount=0 THEN
                IF (l_debug = 1) THEN
                 trace('Custom Labels Trace [INVLAP3B.pls]: At Breadcrumb 3');
                 trace('Custom Labels Trace [INVLAP3B.pls]: WARNING: No row returned by the Custom SQL query');
                END IF;
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_custom_sql_ret_status := INV_LABEL.G_WARNING;
                fnd_message.set_name('WMS','WMS_CS_NO_DATA_FOUND');
                fnd_msg_pub.ADD;
                -- Fix for bug: 4179593 Start
                --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                l_CustSqlWarnFlagSet := TRUE;
                -- Fix for bug: 4179593 End
          ELSIF c_sql_stmt%rowcount>=2 THEN
                IF (l_debug = 1) THEN
                 trace('Custom Labels Trace [INVLAP3B.pls]: At Breadcrumb 4');
                 trace('Custom Labels Trace [INVLAP3B.pls]: ERROR: Multiple values returned by the Custom SQL query');
                END IF;
                l_sql_stmt_result := NULL;
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_custom_sql_ret_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('WMS','WMS_CS_MULTIPLE_VALUES_RETURN');
                fnd_msg_pub.ADD;
                -- Fix for bug: 4179593 Start
                --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                l_CustSqlErrMsg := l_custom_sql_ret_msg;
                l_CustSqlErrFlagSet := TRUE;
                -- Fix for bug: 4179593 End
             END IF;
          IF (c_sql_stmt%ISOPEN) THEN
              CLOSE c_sql_stmt;
          END IF;
            EXCEPTION
            WHEN OTHERS THEN
           IF (c_sql_stmt%ISOPEN) THEN
               CLOSE c_sql_stmt;
           END IF;
              IF (l_debug = 1) THEN
                 trace('Custom Labels Trace [INVLAP3B.pls]: At Breadcrumb 5');
                trace('Custom Labels Trace [INVLAP3B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
              fnd_msg_pub.ADD;
              fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
           IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP3B.pls]: At Breadcrumb 6');
              trace('Custom Labels Trace [INVLAP3B.pls]: Before assigning it to l_content_item_data');
           END IF;
            l_content_item_data  :=   l_content_item_data
                               || variable_b
                               || l_selected_fields(i).variable_name
                               || '">'
                               || l_sql_stmt_result
                               || variable_e;
            l_sql_stmt_result := NULL;
            l_sql_stmt        := NULL;
            IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP3B.pls]: At Breadcrumb 7');
              trace('Custom Labels Trace [INVLAP3B.pls]: After assigning it to l_content_item_data');
           trace('Custom Labels Trace [INVLAP3B.pls]: --------------------------REPORT END-------------------------------------');
            END IF;
------------------------End of this changes for Custom Labels project code--------------------
           ELSIF LOWER(l_selected_fields(i).column_name) = 'current_date' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || inv_label.g_date
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'current_time' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || inv_label.g_time
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'request_user' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || inv_label.g_user
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.lpn
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'organization' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.ORGANIZATION
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_code' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.subinventory_code
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'locator' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.LOCATOR
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'volume' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.volume
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'volume_uom' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.volume_uom
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'gross_weight' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.gross_weight
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'gross_weight_uom' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.gross_weight_uom
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'tare_weight' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.tare_weight
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'tare_weight_uom' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.tare_weight_uom
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_container_item' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.lpn_container_item
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'parent_lpn' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.parent_lpn
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'outermost_lpn' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.outermost_lpn
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) =
                                                       'customer_purchase_order' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_purchase_order
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'category' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.CATEGORY
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute1' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute1
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute2' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute2
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute3' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute3
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute4' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute4
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute5' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute5
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute6' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute6
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute7' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute7
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute8' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute8
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute9' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute9
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute10' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute10
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute11' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute11
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute12' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute12
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute13' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute13
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute14' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute14
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'attribute15' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || v_lpn_content.attribute15
                                    || variable_e;
         --Bug 4891916. Added for the field Requestor
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requestor' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">' || l_requestor
                                    || variable_e;
         --Bug 4891916. Added for the field Cycle Count Name
          ELSIF LOWER(l_selected_fields(i).column_name) = 'cycle_count_name' THEN
               l_content_item_data  := l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">' || l_cycle_count_name
                                    || variable_e;
         --End of fix for Bug 4891916

      -- Patchset J
      -- iSP printing
          ELSIF LOWER(l_selected_fields(i).column_name) = 'asn_number' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.asn_num
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'expct_rcpt_date' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.expected_receipt_date
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'freight_terms' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.freight_terms
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'freight_carrier' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.freight_carrier
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'num_of_containers' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.num_of_containers
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'bill_of_lading' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.bill_of_lading
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'waybill_airbill_num' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.waybill_airbill_num
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'comments_header' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.comments
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'packaging_code' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.packaging_code
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'special_handling_code' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.special_handling_code
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'shipment_date' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.shipment_date
                                    || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'packing_slip_header' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_rcv_isp_header.packing_slip
                                    || variable_e;
          -- Added for 11.5.10+ RFID Compliance project
          -- New field : EPC
          -- EPC is generated once for each LPN
          ELSIF LOWER(l_selected_fields(i).column_name) = 'epc' THEN
            l_content_item_data  :=    l_content_item_data
                                    || variable_b
                                    || l_selected_fields(i).variable_name
                                    || '">'
                                    || l_epc
                                    || variable_e;
	    l_label_err_msg := l_epc_ret_msg;
	    IF l_epc_ret_status = 'U' THEN
	       l_label_status := INV_LABEL.G_ERROR;
	     ELSIF l_epc_ret_status = 'E' THEN
	       l_label_status := INV_LABEL.G_WARNING;
	    END IF;

          END IF;
        END LOOP;

        l_content_item_data := l_content_item_data || label_e;
        x_variable_content(l_label_index).label_content := l_content_item_data;
        x_variable_content(l_label_index).label_request_id := l_label_request_id;
        x_variable_content(l_label_index).label_status  := l_label_status;
        x_variable_content(l_label_index).error_message := l_label_err_msg;

	------------------------Start of changes for Custom Labels project code------------------

        -- Fix for bug: 4179593 Start
        IF (l_CustSqlWarnFlagSet) THEN
         l_custom_sql_ret_status := INV_LABEL.G_WARNING;
         l_custom_sql_ret_msg := l_CustSqlWarnMsg;
        END IF;

        IF (l_CustSqlErrFlagSet) THEN
         l_custom_sql_ret_status := FND_API.G_RET_STS_ERROR;
         l_custom_sql_ret_msg := l_CustSqlErrMsg;
        END IF;
        -- Fix for bug: 4179593 End

        -- We will concatenate the error message from Custom SQL and EPC code.
        x_variable_content(l_label_index).error_message := l_custom_sql_ret_msg || ' ' || l_label_err_msg;
        IF(l_CustSqlWarnFlagSet OR l_CustSqlErrFlagSet) THEN
         x_variable_content(l_label_index).label_status  := l_custom_sql_ret_status;
        END IF;

	------------------------End of this changes for Custom Labels project code---------------
        l_label_index := l_label_index + 1;


	------------------------Starts R12 label-set project------------------
	l_content_item_data  := '';
        l_label_request_id   := NULL;
        l_custom_sql_ret_status := NULL;
        l_custom_sql_ret_msg    := NULL;
	------------------------Ends R12 label-set project---------------

	IF (l_debug = 1) THEN
	   TRACE(' Done with Label formats in the current label-set');
        END IF;


	END LOOP; --for formats in label-set

        <<nextlabel>>

	l_content_item_data  := '';
        l_label_request_id   := NULL;
	------------------------Start of changes for Custom Labels project code------------------
        l_custom_sql_ret_status := NULL;
        l_custom_sql_ret_msg    := NULL;
	------------------------End of this changes for Custom Labels project code---------------

        IF (l_debug = 1) THEN
          TRACE(l_column_name_list);
          TRACE(' Finished writing item variables ');
        END IF;
      END LOOP;
    --x_variable_content := x_variable_content || l_content_item_data ;
    END LOOP;
  END get_variable_data;

  PROCEDURE get_variable_data(
    x_variable_content       OUT NOCOPY    LONG
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , x_return_status          OUT NOCOPY    VARCHAR2
  , p_label_type_info        IN            inv_label.label_type_rec
  , p_transaction_id         IN            NUMBER
  , p_input_param            IN            mtl_material_transactions_temp%ROWTYPE
  , p_transaction_identifier IN            NUMBER
  ) IS
    l_variable_data_tbl inv_label.label_tbl_type;
  BEGIN
    get_variable_data(
      x_variable_content           => l_variable_data_tbl
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_return_status              => x_return_status
    , p_label_type_info            => p_label_type_info
    , p_transaction_id             => p_transaction_id
    , p_input_param                => p_input_param
    , p_transaction_identifier     => p_transaction_identifier
    );
    x_variable_content  := '';

    FOR i IN 1 .. l_variable_data_tbl.COUNT() LOOP
      x_variable_content  :=
                     x_variable_content || l_variable_data_tbl(i).label_content;
    END LOOP;
  END get_variable_data;
END inv_label_pvt3;

/
