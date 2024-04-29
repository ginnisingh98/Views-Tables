--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT2" AS
  /* $Header: INVLAP2B.pls 120.20.12010000.4 2010/04/07 09:35:54 jianxzhu ship $ */
  label_b    CONSTANT VARCHAR2(50)              := '<label';
  label_e    CONSTANT VARCHAR2(50)              := '</label>' || fnd_global.local_chr(10);
  variable_b CONSTANT VARCHAR2(50)              := '<variable name= "';
  variable_e CONSTANT VARCHAR2(50)              := '</variable>' || fnd_global.local_chr(10);
  tag_e      CONSTANT VARCHAR2(50)              := '>' || fnd_global.local_chr(10);
  l_debug             NUMBER;
  -- Bug 2795525 : This mask is used to mask all date fields.
  g_date_format_mask  VARCHAR2(100)             := inv_label.g_date_format_mask;
  g_header_printed    BOOLEAN                   := FALSE;
  g_user_name         fnd_user.user_name%TYPE   := fnd_global.user_name;

  PROCEDURE TRACE(p_message IN VARCHAR2) IS
  BEGIN
    IF (g_header_printed = FALSE) THEN
      inv_label.TRACE('$Header: INVLAP2B.pls 120.20.12010000.4 2010/04/07 09:35:54 jianxzhu ship $', 'LABEL_SERIAL');
      g_header_printed  := TRUE;
    END IF;

    inv_label.TRACE(g_user_name || ': ' || p_message, 'LABEL_SERIAL');
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
    l_receipt_number        VARCHAR2(30);   -- Added for Bug 2847799
    l_delivery_detail_id    NUMBER;
    l_project_id            NUMBER;
    l_task_id               NUMBER;
    l_cost_group_id         NUMBER;
    l_inventory_item_id     NUMBER;
    l_organization_id       NUMBER;
    l_lot_number            VARCHAR2(240);
    l_serial_number         VARCHAR2(240);
    l_revision              mtl_material_transactions_temp.revision%TYPE;
    l_subinventory          VARCHAR2(30)                                     := NULL;
    l_project_number        VARCHAR (25); -- Fix For Bug: 4907062
    l_project_name          VARCHAR2(240);
    l_task_number           VARCHAR (25); -- Fix For Bug: 4907062
    l_task_name             VARCHAR2(240);
    l_wip_entity_id         NUMBER;
    -- Added for Bug 2748297
    l_vendor_id             NUMBER;
    l_vendor_site_id        NUMBER;
    -- Bug 2825748 : Material Label Is Not Printed On WIP Completion.
    l_uom                   mtl_material_transactions.transaction_uom%TYPE;
    l_locator_id            NUMBER;
    -- Added for Bug 4582954
    l_oe_order_header_id    NUMBER;
    l_oe_order_line_id      NUMBER;
    -- Added for UCC 128 J Bug #3067059
    l_gtin_enabled          BOOLEAN                                          := FALSE;
    l_gtin                  VARCHAR2(100);
    l_gtin_desc             VARCHAR2(240);
    l_quantity_floor        NUMBER                                           := 0;
    l_fm_serial_number      VARCHAR2(240);
    l_to_serial_number      VARCHAR2(240);


---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
-- Following variables were added (as a part of 11i10+ 'Custom Labels'  Project)             |
-- to retrieve and hold the SQL Statement and it's result.                                   |
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

     -- added for conergence projact (invconv)
    l_grade_code             mtl_lot_numbers.grade_code%TYPE;
    l_parent_lot_number      mtl_lot_numbers.parent_lot_number%TYPE;
    l_expiration_action_date mtl_lot_numbers.expiration_action_date%TYPE;
    l_expiration_action_code mtl_lot_numbers.expiration_action_code%TYPE;
    l_origination_type       mtl_lot_numbers.origination_type%TYPE;
    l_hold_date              mtl_lot_numbers.hold_date%TYPE;
    l_supplier_lot_number    mtl_lot_numbers.supplier_lot_number%TYPE;
    l_expiration_date        mtl_lot_numbers.expiration_date%TYPE;

    l_maturity_date          mtl_lot_numbers.maturity_date%TYPE;
    l_retest_date            mtl_lot_numbers.retest_date%TYPE;
    l_origination_date       mtl_lot_numbers.origination_date%TYPE;
    l_lot_status             mtl_material_statuses_vl.status_code%TYPE; -- Bug 4355080
    -- invconv enf


    -- For Receipt, Inspection, Putaway, Delivery,
    --  the Item/Lot information is obtained like this

    -- 1. For WMS Org,       Serial
    --                     --------
    --  Receipt/Inspection   rti+msn(with lpn_id)
    --  Putaway              rti+mtlt+msnt
    --  Delivery      no apply for WMS org
    -- 2. For INV Org,       Serial
    --                     --------
    --  Receipt/Inspection   No serial number
    --  Putaway       no apply for Inv org
    --  Delivery             rti+mtlt+msnt
    -- Therefore, two cursors are needed, rti+msn or rti+mtlt+msnt

    -- For WMS org, receipt and inspection
    CURSOR rti_serial_lpn_cur IS
      SELECT   rti.item_id inventory_item_id
             , rti.to_organization_id organization_id
             , msn.lot_number lot_number
             , pol.project_id project_id
             , pol.task_id task_id
             , rti.item_revision revision
             , msn.serial_number serial_number
             , pha.segment1 purchase_order
             , rti.subinventory
             , rti.vendor_id
             , rti.vendor_site_id
             , rti.oe_order_header_id --Bug 4582954
             , rti.oe_order_line_id   --Bug 4582954
          FROM rcv_transactions_interface rti, mtl_serial_numbers msn,
          po_lines_trx_v pol,  -- CLM project, bug 9403291
          wms_lpn_contents wlc,
          po_headers_trx_v pha -- CLM project, bug 9403291
         WHERE wlc.parent_lpn_id = rti.lpn_id
           AND pol.po_line_id(+) = rti.po_line_id
           AND pha.po_header_id(+) = rti.po_header_id
           AND msn.lpn_id = rti.lpn_id
           AND NVL(msn.lot_number, '&&&') = NVL(wlc.lot_number, NVL(msn.lot_number, '&&&'))
           AND msn.inventory_item_id = rti.item_id
           AND msn.current_organization_id = rti.to_organization_id
           AND rti.interface_transaction_id = p_transaction_id
      ORDER BY msn.serial_number;

    /* Patchset J - Earlier serial numbers were only recorded for WMS organizations
     * using RTI_SERIAL_LPN_CUR by joining RTI to WLC and MTL_SERIAL_NUMBERS(MSN).
     * Now th Serial numbers are recorded for both WMS and INV organizations in
     * RCV_SERIALS_INTERFACE table, with the link to RTI, and/or RLI.
     * The old cursor RTI_SERIAL_LPN_CUR should be replaced by new cursor RTI_SERIAL_CUR
     */
    CURSOR rt_serial_cur IS
           /* Note: records in RT are filtered by transaction_type and business_flow_code
           *   becuase it is possible for label-API to be called multiple times by RCV-TM
           *   in the case of ROI, when multiple trx.types are present in a group
           */
      --   Commented as part of fix for bug Bug 3472432. The l_inventory_item_id is required for the serial_cur as an
      --   input parameter. The item id is being derived from the rcv_shipment_lines because irrespective of the
      --   transaction type(Receipt or Internal Req), the item id will be populated. For Internal Requisitions, the
      --   pol.item_id may not be populated. This cursor is common for everything except a deliver transaction . This
      --   is taken care of in teh second part of the SQL(after the UNION ALL) since for Deliver transactions, the
      --   rcv_serials_supply may not be populated. This information has been derived from talking to the Inbound
      --   team.
      --   SELECT  to_number(null) inventory_item_id
      SELECT rsl.item_id inventory_item_id   -- @@@ Bug 3472432
           , rt.organization_id organization_id
           , rss.lot_num lot_number
           --Bug# 3586116 - Get project and task id from rt
      ,      rt.project_id
           , rt.task_id
           --  , pod.project_id project_id     --Commented as part of Bug# 3586116
           -- , pod.task_id task_id          --Commented as part of Bug# 3586116
      ,      pol.item_revision revision
           , rss.serial_num
           , pha.segment1 purchase_order
           , rt.subinventory
           , rt.locator_id
           , rt.vendor_id
           , rt.vendor_site_id
           , rt.uom_code
           , rt.oe_order_header_id --Bug 4582954
           , rt.oe_order_line_id   --Bug 4582954
        FROM rcv_transactions rt, rcv_serials_supply rss,
        po_lines_trx_v pol -- CLM project, bug 9403291
             --    , po_distributions_all pod      --Commented as part of Bug# 3586116
             , po_headers_trx_v pha,  -- CLM project, bug 9403291
             rcv_shipment_lines rsl
             , wms_license_plate_numbers wlpn -- Bug 3836623
       WHERE rss.transaction_id = rt.transaction_id
         AND pol.po_line_id(+) = rt.po_line_id
         AND pha.po_header_id(+) = rt.po_header_id
         --  AND   pod.po_distribution_id(+)          = rt.po_distribution_id     --Commented as part of Bug# 3586116
         AND(
             (rt.transaction_type IN('ACCEPT', 'REJECT')
              AND p_label_type_info.business_flow_code = 2)
             OR(rt.transaction_type = 'RECEIVE'
                --AND rt.routing_header_id <> 3 Modified for Bug: 4312020
                AND p_label_type_info.business_flow_code = 1)
            )
         --AND   rsl.shipment_header_id = rt.shipment_header_id  -- @@@ Bug 3472432. Takes care of the cartesian product.
         AND rsl.shipment_line_id = rt.shipment_line_id   --Bug# 3516361. Takes care of cartesian product.
         AND rt.GROUP_ID = p_transaction_id
         -- Bug 3836623
         -- Add check for LPN context
         -- When cross docking happens, label printing are called for both cross docking and putaway
         -- To prevent duplicate labels
         -- For putaway business flow, only print if LPN Context is not Picked (11)
         AND wlpn.lpn_id(+) = rt.lpn_id
         AND ((rt.lpn_id IS NULL) OR
              (p_label_type_info.business_flow_code <> 4) OR
              (p_label_type_info.business_flow_code = 4 AND
                      wlpn.lpn_context <> 11))
      UNION ALL
      SELECT rsl.item_id inventory_item_id
           , rt.organization_id organization_id
           , mtln.lot_number
           --Bug# 3586116 - Get project and task id from rt
      ,      rt.project_id
           , rt.task_id
           --  , pod.project_id project_id     --Commented as part of Bug# 3586116
           -- , pod.task_id task_id          --Commented as part of Bug# 3586116
      ,      rsl.item_revision revision
           , mut.serial_number
           , pha.segment1 purchase_order
           , rt.subinventory
           , rt.locator_id
           , rt.vendor_id
           , rt.vendor_site_id
           , rt.uom_code
           , rt.oe_order_header_id --Bug 4582954
           , rt.oe_order_line_id   --Bug 4582954
        FROM rcv_transactions rt
           , mtl_transaction_lot_numbers mtln
           , mtl_unit_transactions mut
           -- , po_distributions_all pod     --Commented as part of Bug# 3586116
      ,      po_lines_trx_v pol -- CLM project, bug 9403291
           , po_headers_trx_v pha -- CLM project, bug 9403291
           , rcv_shipment_lines rsl
           , wms_license_plate_numbers wlpn -- Bug 3836623
           -- Bug 4179732, can not print serial number from putaway
           -- Changed to link to MUT through MMT
           , mtl_material_transactions mmt
         WHERE mmt.rcv_transaction_id = rt.transaction_id
         AND mmt.transaction_id = mtln.transaction_id (+)
         AND mut.transaction_id = nvl(mtln.serial_transaction_id, mmt.transaction_id)
       --WHERE mtln.product_transaction_id(+) = rt.transaction_id
       --  AND mut.product_transaction_id(+) = rt.transaction_id
       --  AND NVL(mut.transaction_id, -9998) = NVL(mtln.serial_transaction_id, NVL(mut.transaction_id, -9998))
       -- End of bug 4179732
         AND pol.po_line_id(+) = rt.po_line_id
         AND pha.po_header_id(+) = rt.po_header_id
         --AND   pod.po_distribution_id(+)            = rt.po_distribution_id       --Commented as part of Bug# 3586116
         AND rt.transaction_type = 'DELIVER'
         AND (p_label_type_info.business_flow_code IN(3, 4) OR
               (rt.routing_header_id = 3
                AND p_label_type_info.business_flow_code = 1)) /* Added for bug # 5219262*/
         AND rt.GROUP_ID = p_transaction_id
         AND rsl.shipment_line_id = rt.shipment_line_id
         -- Bug 3836623
         -- Add check for LPN context
         -- When cross docking happens, label printing are called for both cross docking and putaway
         -- To prevent duplicate labels
         -- For putaway business flow, only print if LPN Context is not Picked (11)
         AND wlpn.lpn_id(+) = rt.lpn_id
         AND ((rt.lpn_id IS NULL) OR
              (p_label_type_info.business_flow_code <> 4) OR
              (p_label_type_info.business_flow_code = 4 AND
                      wlpn.lpn_context <> 11))

         ;

    -- For Putaway in WMS org and Delivery in INV org
    -- If the item is serial/lot control then the link is mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
    -- If the item is serial only control, then the above link is missing and so  the link is from rti.transaction_temp_id to
    -- msnt.transaction_temp_id
    -- (delivery)
    CURSOR rti_serial_msnt_cur IS
      SELECT rti.item_id inventory_item_id
           , rti.to_organization_id organization_id
           , mtlt.lot_number lot_number
           , pol.project_id project_id
           , pol.task_id task_id
           , rti.item_revision revision
           , msnt.fm_serial_number fm_serial_number
           , msnt.to_serial_number to_serial_number
           , pha.segment1 purchase_order
           , rti.subinventory
           , rti.vendor_id
           , rti.vendor_site_id
           , rti.oe_order_header_id --Bug 4582954
           , rti.oe_order_line_id   --Bug 4582954
        FROM rcv_transactions_interface rti
           , mtl_serial_numbers_temp msnt
           , mtl_transaction_lots_temp mtlt
           , po_lines_trx_v pol -- CLM project, bug 9403291
           , po_headers_trx_v pha -- CLM project, bug 9403291
       WHERE mtlt.transaction_temp_id(+) = rti.interface_transaction_id
         AND msnt.transaction_temp_id = NVL(mtlt.serial_transaction_temp_id, rti.interface_transaction_id)
         AND pol.po_line_id(+) = rti.po_line_id
         AND pha.po_header_id(+) = rti.po_header_id
         AND rti.interface_transaction_id = p_transaction_id;

    -- For INV org
    -- If the item is serial/lot controlled then the link is mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
    -- If the item is serial controlled, then the above link is missing and so  the link is from mmtt.transaction_temp_id to
    -- msnt.transaction_temp_id
    -- (Misc/Alias issue/receipt)
    CURSOR mmtt_serial_cur IS
      SELECT mmtt.inventory_item_id inventory_item_id
           , mmtt.organization_id organization_id
           , mtlt.lot_number lot_number
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , mmtt.revision revision
           , msnt.fm_serial_number fm_serial_number
           , msnt.to_serial_number to_serial_number
           , mmtt.subinventory_code
           , mmtt.transaction_uom
           , mmtt.locator_id /* Added for Bug # 4672471 */
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, mtl_serial_numbers_temp msnt
       WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND msnt.transaction_temp_id = NVL(mtlt.serial_transaction_temp_id, mmtt.transaction_temp_id)
         AND mmtt.transaction_temp_id = p_transaction_id;

    -- The following cursor has been added for bug # 5245012
    -- For details about the changes, please refer to bug or read the rlog message
    CURSOR wip_lpn_serial_cur IS
      SELECT mmtt.inventory_item_id inventory_item_id
           , mmtt.organization_id organization_id
           , msn.lot_number lot_number
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , mmtt.revision revision
           , msn.serial_number serial_number
           , mmtt.subinventory_code
           , mmtt.transaction_uom
           , mmtt.locator_id
        FROM mtl_material_transactions_temp mmtt, mtl_serial_numbers msn
       WHERE mmtt.transaction_temp_id = p_transaction_id
         AND mmtt.lpn_id = msn.lpn_id;

    -- For business_flow_code of Cross Dock, the delivery_detail_id is passed.
    CURSOR wdd_serial_cur IS
      SELECT wdd1.inventory_item_id inventory_item_id
           , wdd1.organization_id organization_id
           , wdd1.lot_number lot_number
           , NVL(wdd1.project_id, 0) project_id
           , NVL(wdd1.task_id, 0) task_id
           , wdd1.revision revision
           , wdd1.serial_number serial_number
           , wdd1.subinventory
           , wdd1.requested_quantity_uom
        FROM wsh_delivery_details wdd1, wsh_delivery_assignments_v wda, wsh_delivery_details wdd2
       WHERE wdd1.delivery_detail_id(+) = wda.delivery_detail_id
         AND wda.parent_delivery_detail_id(+) = wdd2.delivery_detail_id
         AND wdd2.delivery_detail_id = p_transaction_id;   --168158

    -- For business_flow_code of Ship Confirm, the delivery_id is passed. So this means derive all the delivery_detail_id's for the
    -- delivery_id.
    CURSOR wda_serial_cur IS
      SELECT wdd.inventory_item_id inventory_item_id
           , wdd.organization_id organization_id
           , wdd.lot_number lot_number
           , NVL(wdd.project_id, 0) project_id
           , NVL(wdd.task_id, 0) task_id
           , wdd.revision revision
           , wdd.serial_number serial_number      /* If there is only one item then this sl. no will get populated
                                                     and there would not be any mtl_serial_numbers_temp record for it. */
           , msnt.fm_serial_number fm_serial_number  --Added to fix Bug# 4290536
           , NVL(msnt.to_serial_number, msnt.fm_serial_number) to_serial_number --Added to fix Bug# 4290536
           , wdd.subinventory
           , wdd.requested_quantity_uom
        FROM wsh_delivery_details wdd, wsh_delivery_assignments wda,
             wsh_new_deliveries wnd, mtl_serial_numbers_temp msnt
       WHERE wda.delivery_id = wnd.delivery_id
         AND NVL(wdd.transaction_temp_id, -1) = msnt.transaction_temp_id(+)
         AND wdd.delivery_detail_id = wda.delivery_detail_id
         AND wdd.inventory_item_id IS NOT NULL
         AND wnd.delivery_id = p_transaction_id;

    -- For business_flow_code of WIP Completion(26), Manufacturing Cross-Dock (37) the transaction temp id  is passed.
    -- Bug 2825748 : Material Label Is Not Printed On WIP Completion.
     -- Bug 3896738
    CURSOR wip_serial_cur IS
      SELECT mmtt.inventory_item_id
           , mmtt.organization_id
           , mtlt.lot_number
           , mmtt.cost_group_id
           , mmtt.project_id
           , mmtt.task_id
           , mmtt.transaction_uom
           , mmtt.revision
           , msnt.fm_serial_number
           , msnt.to_serial_number
           , mmtt.subinventory_code
           , mmtt.locator_id
           , wnt.wip_entity_name --Added for Bug: 4642062
           , wnt.wip_entity_id
        FROM  mtl_material_transactions_temp mmtt
            , mtl_transaction_lots_temp mtlt
            , mtl_serial_numbers_temp msnt
            , wip_entities wnt --Added for Bug 4642062
       WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND msnt.transaction_temp_id = NVL(mtlt.serial_transaction_temp_id, mmtt.transaction_temp_id)
         AND mmtt.transaction_temp_id = p_transaction_id
         AND wnt.wip_entity_id(+) = mmtt.transaction_source_id;--Added for Bug 4642062
    -- Added the outer Join in the above condition for bug#5438565

    -- For business flow code of 33, the MMTT, MTI or MOL id is passed
    -- Depending on the txn identifier being passed,one of the
    -- following 2 flow csrs or the generic mmtt crsr will be called
    CURSOR flow_serial_curs_mti IS
      SELECT mti.inventory_item_id inventory_item_id
           , mti.organization_id organization_id
           , mtil.lot_number lot_number
           , mti.project_id project_id
           , mti.task_id task_id
           , mti.revision revision
           , msni.fm_serial_number fm_serial_number
           , msni.to_serial_number to_serial_number
           , mti.subinventory_code
           , mti.locator_id   -- Added for Bug #5533362
           , mti.transaction_uom
        FROM mtl_transactions_interface mti, mtl_transaction_lots_interface mtil, mtl_serial_numbers_interface msni
       WHERE mtil.transaction_interface_id(+) = mti.transaction_interface_id
         AND msni.transaction_interface_id = NVL(mtil.serial_transaction_temp_id, mti.transaction_interface_id)
         AND mti.transaction_interface_id = p_transaction_id;

    CURSOR flow_serial_curs_mol IS
      SELECT mol.inventory_item_id inventory_item_id
           , mol.organization_id organization_id
           , mol.lot_number lot_number
           , mol.project_id project_id
           , mol.task_id task_id
           , mol.revision revision
           , mol.serial_number_start fm_serial_number
           , mol.serial_number_end to_serial_number
           , mol.from_subinventory_code
           , mol.uom_code
        FROM mtl_txn_request_lines mol
       WHERE mol.line_id = p_transaction_id;

    -- End of Flow csr

    --      Commented as part of bug fix for Bug 3472432.
    --      Repaced the query with rcv_transactions.
      -- To get org type.
    --  CURSOR  rti_get_org_cur IS
    --  SELECT  to_organization_id
    --  FROM  rcv_transactions_interface rti
    --  WHERE rti.interface_transaction_id = p_transaction_id;

    -- To get org type.
    CURSOR rt_get_org_cur IS
      SELECT organization_id
        FROM rcv_transactions rt
       WHERE rt.GROUP_ID = p_transaction_id;

    -- Fix For Bug: 4907062
    -- a) Included Project Number in the cursor
    -- b) Taken the project details from pjm_projects_mtll_v instead of pa_projects
    CURSOR c_project IS
    SELECT project_name, project_number
    FROM pjm_projects_mtll_v  --pa_projects
    WHERE project_id = l_project_id;

    -- Fix For Bug: 4907062
    -- Included Task Number in the cursor
    CURSOR c_task IS
    SELECT task_name, task_number
    FROM pa_tasks
    WHERE task_id = l_task_id;

    /* The following cursor has been added to fetch the PROJECT_REFERENCE_ENABLED value
     * from pjm_org_parameters table. The value 'Y' represents the PJM enabled org.
     * This field will be used to open the cursors that are required only for PJM org.
     */

    CURSOR c_project_enabled(p_organization_id NUMBER) IS
       SELECT pop.project_reference_enabled
       FROM pjm_org_parameters pop
       WHERE pop.organization_id = p_organization_id;

    l_is_pjm_org             VARCHAR (1);

    --Bug #6417575,Label Printing Support for WIP Move Transactions (12.1)
    --  Created new cursor to fetch WIP Job Attributes based on wip_entity_id.
    CURSOR wip_attributes_cur IS
      SELECT wipent.wip_entity_name job_name
           , mfglkp.meaning job_type
           , wipdj.net_quantity job_net_quantity
           , TO_CHAR(wipdj.scheduled_start_date, g_date_format_mask) job_scheduled_start_date
           , TO_CHAR(wipdj.scheduled_completion_date, g_date_format_mask) job_scheduled_completion_date
           , wipdj.bom_revision job_bom_revision
           , wipdj.routing_revision job_routing_revision
        FROM wip_entities wipent
           , wip_discrete_jobs wipdj
           , mfg_lookups mfglkp
       WHERE wipdj.wip_entity_id = wipent.wip_entity_id
         AND wipdj.organization_id = wipent.organization_id
         AND mfglkp.lookup_code(+) = wipent.entity_type
         AND mfglkp.lookup_type(+) = 'WIP_ENTITY'
         AND wipent.wip_entity_id = l_wip_entity_id
         AND wipent.organization_id = l_organization_id;

    l_entity_type                VARCHAR2(80)                        := NULL;
    l_net_quantity               NUMBER                              := NULL;
    l_scheduled_start_date       DATE                                := NULL;
    l_scheduled_completion_date  DATE                                := NULL;
    l_bom_revision               VARCHAR2(3)                         := NULL;
    l_routing_revision           VARCHAR2(3)                         := NULL;


    /* Start of fix for bug # 4947399 */
    l_lot_c_attribute1           VARCHAR2(150);
    l_lot_c_attribute2           VARCHAR2(150);
    l_lot_c_attribute3           VARCHAR2(150);
    l_lot_c_attribute4           VARCHAR2(150);
    l_lot_c_attribute5           VARCHAR2(150);
    l_lot_c_attribute6           VARCHAR2(150);
    l_lot_c_attribute7           VARCHAR2(150);
    l_lot_c_attribute8           VARCHAR2(150);
    l_lot_c_attribute9           VARCHAR2(150);
    l_lot_c_attribute10          VARCHAR2(150);
    l_lot_c_attribute11          VARCHAR2(150);
    l_lot_c_attribute12          VARCHAR2(150);
    l_lot_c_attribute13          VARCHAR2(150);
    l_lot_c_attribute14          VARCHAR2(150);
    l_lot_c_attribute15          VARCHAR2(150);
    l_lot_c_attribute16          VARCHAR2(150);
    l_lot_c_attribute17          VARCHAR2(150);
    l_lot_c_attribute18          VARCHAR2(150);
    l_lot_c_attribute19          VARCHAR2(150);
    l_lot_c_attribute20          VARCHAR2(150);
    l_lot_d_attribute1           DATE;
    l_lot_d_attribute2           DATE;
    l_lot_d_attribute3           DATE;
    l_lot_d_attribute4           DATE;
    l_lot_d_attribute5           DATE;
    l_lot_d_attribute6           DATE;
    l_lot_d_attribute7           DATE;
    l_lot_d_attribute8           DATE;
    l_lot_d_attribute9           DATE;
    l_lot_d_attribute10          DATE;
    l_lot_n_attribute1           NUMBER                          := NULL;
    l_lot_n_attribute2           NUMBER                          := NULL;
    l_lot_n_attribute3           NUMBER                          := NULL;
    l_lot_n_attribute4           NUMBER                          := NULL;
    l_lot_n_attribute5           NUMBER                          := NULL;
    l_lot_n_attribute6           NUMBER                          := NULL;
    l_lot_n_attribute7           NUMBER                          := NULL;
    l_lot_n_attribute8           NUMBER                          := NULL;
    l_lot_n_attribute9           NUMBER                          := NULL;
    l_lot_n_attribute10          NUMBER                          := NULL;
    l_serial_c_attribute1        VARCHAR2(150);
    l_serial_c_attribute2        VARCHAR2(150);
    l_serial_c_attribute3        VARCHAR2(150);
    l_serial_c_attribute4        VARCHAR2(150);
    l_serial_c_attribute5        VARCHAR2(150);
    l_serial_c_attribute6        VARCHAR2(150);
    l_serial_c_attribute7        VARCHAR2(150);
    l_serial_c_attribute8        VARCHAR2(150);
    l_serial_c_attribute9        VARCHAR2(150);
    l_serial_c_attribute10       VARCHAR2(150);
    l_serial_c_attribute11       VARCHAR2(150);
    l_serial_c_attribute12       VARCHAR2(150);
    l_serial_c_attribute13       VARCHAR2(150);
    l_serial_c_attribute14       VARCHAR2(150);
    l_serial_c_attribute15       VARCHAR2(150);
    l_serial_c_attribute16       VARCHAR2(150);
    l_serial_c_attribute17       VARCHAR2(150);
    l_serial_c_attribute18       VARCHAR2(150);
    l_serial_c_attribute19       VARCHAR2(150);
    l_serial_c_attribute20       VARCHAR2(150);
    l_serial_d_attribute1        DATE;
    l_serial_d_attribute2        DATE;
    l_serial_d_attribute3        DATE;
    l_serial_d_attribute4        DATE;
    l_serial_d_attribute5        DATE;
    l_serial_d_attribute6        DATE;
    l_serial_d_attribute7        DATE;
    l_serial_d_attribute8        DATE;
    l_serial_d_attribute9        DATE;
    l_serial_d_attribute10       DATE;
    l_serial_n_attribute1        NUMBER                          := NULL;
    l_serial_n_attribute2        NUMBER                          := NULL;
    l_serial_n_attribute3        NUMBER                          := NULL;
    l_serial_n_attribute4        NUMBER                          := NULL;
    l_serial_n_attribute5        NUMBER                          := NULL;
    l_serial_n_attribute6        NUMBER                          := NULL;
    l_serial_n_attribute7        NUMBER                          := NULL;
    l_serial_n_attribute8        NUMBER                          := NULL;
    l_serial_n_attribute9        NUMBER                          := NULL;
    l_serial_n_attribute10       NUMBER                          := NULL;


    /*
     * The following cursor has been added to fetch the lot and serial attributes from
     * mtl_transaction_lots_temp and mtl_serial_numbers_temp based on transaction_id,
     * lot_number, from_serial_number and to_serial_number. Since a lot can have
     * multiple serials associated with it and each serial can have different attributes,
     * fm_serial_number and to_serial_number has been added in the condition.
     *
     */

    CURSOR c_lot_serial_attributes IS
     SELECT mtlt.c_attribute1
          , mtlt.c_attribute2
          , mtlt.c_attribute3
          , mtlt.c_attribute4
          , mtlt.c_attribute5
          , mtlt.c_attribute6
          , mtlt.c_attribute7
          , mtlt.c_attribute8
          , mtlt.c_attribute9
          , mtlt.c_attribute10
          , mtlt.c_attribute11
          , mtlt.c_attribute12
          , mtlt.c_attribute13
          , mtlt.c_attribute14
          , mtlt.c_attribute15
          , mtlt.c_attribute16
          , mtlt.c_attribute17
          , mtlt.c_attribute18
          , mtlt.c_attribute19
          , mtlt.c_attribute20
          , mtlt.d_attribute1
          , mtlt.d_attribute2
          , mtlt.d_attribute3
          , mtlt.d_attribute4
          , mtlt.d_attribute5
          , mtlt.d_attribute6
          , mtlt.d_attribute7
          , mtlt.d_attribute8
          , mtlt.d_attribute9
          , mtlt.d_attribute10
          , mtlt.n_attribute1
          , mtlt.n_attribute2
          , mtlt.n_attribute3
          , mtlt.n_attribute4
          , mtlt.n_attribute5
          , mtlt.n_attribute6
          , mtlt.n_attribute7
          , mtlt.n_attribute8
          , mtlt.n_attribute9
          , mtlt.n_attribute10
          , msnt.c_attribute1
          , msnt.c_attribute2
          , msnt.c_attribute3
          , msnt.c_attribute4
          , msnt.c_attribute5
          , msnt.c_attribute6
          , msnt.c_attribute7
          , msnt.c_attribute8
          , msnt.c_attribute9
          , msnt.c_attribute10
          , msnt.c_attribute11
          , msnt.c_attribute12
          , msnt.c_attribute13
          , msnt.c_attribute14
          , msnt.c_attribute15
          , msnt.c_attribute16
          , msnt.c_attribute17
          , msnt.c_attribute18
          , msnt.c_attribute19
          , msnt.c_attribute20
          , msnt.d_attribute1
          , msnt.d_attribute2
          , msnt.d_attribute3
          , msnt.d_attribute4
          , msnt.d_attribute5
          , msnt.d_attribute6
          , msnt.d_attribute7
          , msnt.d_attribute8
          , msnt.d_attribute9
          , msnt.d_attribute10
          , msnt.n_attribute1
          , msnt.n_attribute2
          , msnt.n_attribute3
          , msnt.n_attribute4
          , msnt.n_attribute5
          , msnt.n_attribute6
          , msnt.n_attribute7
          , msnt.n_attribute8
          , msnt.n_attribute9
          , msnt.n_attribute10
       FROM mtl_transaction_lots_temp mtlt
          , mtl_serial_numbers_temp msnt
          , mtl_material_transactions_temp mmtt
      WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
        AND msnt.transaction_temp_id = NVL(mtlt.serial_transaction_temp_id, mmtt.transaction_temp_id)
        AND mmtt.transaction_temp_id = p_transaction_id
        AND mtlt.lot_number(+) = l_lot_number
        AND msnt.fm_serial_number = l_fm_serial_number
        AND msnt.to_serial_number = l_to_serial_number;

    /* End of fix for bug # 4947399 */


    CURSOR serial_cur IS
      SELECT msn2.item item
	     , msn2.client_item client_item			-- Added for LSP Project, bug 9087971
           , msn2.inventory_item_id inventory_item_id
           , mp.organization_code ORGANIZATION
           , msn2.organization_id organization_id
           , msn2.item_description item_description
           , msn2.revision revision
           , msn2.item_hazard_class item_hazard_class
           , msn2.item_attribute_category item_attribute_category
           , msn2.item_attribute1 item_attribute1
           , msn2.item_attribute2 item_attribute2
           , msn2.item_attribute3 item_attribute3
           , msn2.item_attribute4 item_attribute4
           , msn2.item_attribute5 item_attribute5
           , msn2.item_attribute6 item_attribute6
           , msn2.item_attribute7 item_attribute7
           , msn2.item_attribute8 item_attribute8
           , msn2.item_attribute9 item_attribute9
           , msn2.item_attribute10 item_attribute10
           , msn2.item_attribute11 item_attribute11
           , msn2.item_attribute12 item_attribute12
           , msn2.item_attribute13 item_attribute13
           , msn2.item_attribute14 item_attribute14
           , msn2.item_attribute15 item_attribute15
           , msn2.serial_number serial_number
           , mmsvl1.status_code lot_status
           , msn2.serial_attribute_category serial_attribute_category
           , -- Start for bug # 4947399
             NVL(l_serial_c_attribute1, msn2.serial_c_attribute1) serial_c_attribute1
           , NVL(l_serial_c_attribute2, msn2.serial_c_attribute2) serial_c_attribute2
           , NVL(l_serial_c_attribute3, msn2.serial_c_attribute3) serial_c_attribute3
           , NVL(l_serial_c_attribute4, msn2.serial_c_attribute4) serial_c_attribute4
           , NVL(l_serial_c_attribute5, msn2.serial_c_attribute5) serial_c_attribute5
           , NVL(l_serial_c_attribute6, msn2.serial_c_attribute6) serial_c_attribute6
           , NVL(l_serial_c_attribute7, msn2.serial_c_attribute7) serial_c_attribute7
           , NVL(l_serial_c_attribute8, msn2.serial_c_attribute8) serial_c_attribute8
           , NVL(l_serial_c_attribute9, msn2.serial_c_attribute9) serial_c_attribute9
           , NVL(l_serial_c_attribute10, msn2.serial_c_attribute10) serial_c_attribute10
           , NVL(l_serial_c_attribute11, msn2.serial_c_attribute11) serial_c_attribute11
           , NVL(l_serial_c_attribute12, msn2.serial_c_attribute12) serial_c_attribute12
           , NVL(l_serial_c_attribute13, msn2.serial_c_attribute13) serial_c_attribute13
           , NVL(l_serial_c_attribute14, msn2.serial_c_attribute14) serial_c_attribute14
           , NVL(l_serial_c_attribute15, msn2.serial_c_attribute15) serial_c_attribute15
           , NVL(l_serial_c_attribute16, msn2.serial_c_attribute16) serial_c_attribute16
           , NVL(l_serial_c_attribute17, msn2.serial_c_attribute17) serial_c_attribute17
           , NVL(l_serial_c_attribute18, msn2.serial_c_attribute18) serial_c_attribute18
           , NVL(l_serial_c_attribute19, msn2.serial_c_attribute19) serial_c_attribute19
           , NVL(l_serial_c_attribute20, msn2.serial_c_attribute20) serial_c_attribute20
           , NVL(l_serial_d_attribute1, msn2.serial_d_attribute1) serial_d_attribute1
           , NVL(l_serial_d_attribute2, msn2.serial_d_attribute2) serial_d_attribute2
           , NVL(l_serial_d_attribute3, msn2.serial_d_attribute3) serial_d_attribute3
           , NVL(l_serial_d_attribute4, msn2.serial_d_attribute4) serial_d_attribute4
           , NVL(l_serial_d_attribute5, msn2.serial_d_attribute5) serial_d_attribute5
           , NVL(l_serial_d_attribute6, msn2.serial_d_attribute6) serial_d_attribute6
           , NVL(l_serial_d_attribute7, msn2.serial_d_attribute7) serial_d_attribute7
           , NVL(l_serial_d_attribute8, msn2.serial_d_attribute8) serial_d_attribute8
           , NVL(l_serial_d_attribute9, msn2.serial_d_attribute9) serial_d_attribute9
           , NVL(l_serial_d_attribute10, msn2.serial_d_attribute10) serial_d_attribute10
           , NVL(l_serial_n_attribute1, msn2.serial_n_attribute1) serial_n_attribute1
           , NVL(l_serial_n_attribute2, msn2.serial_n_attribute2) serial_n_attribute2
           , NVL(l_serial_n_attribute3, msn2.serial_n_attribute3) serial_n_attribute3
           , NVL(l_serial_n_attribute4, msn2.serial_n_attribute4) serial_n_attribute4
           , NVL(l_serial_n_attribute5, msn2.serial_n_attribute5) serial_n_attribute5
           , NVL(l_serial_n_attribute6, msn2.serial_n_attribute6) serial_n_attribute6
           , NVL(l_serial_n_attribute7, msn2.serial_n_attribute7) serial_n_attribute7
           , NVL(l_serial_n_attribute8, msn2.serial_n_attribute8) serial_n_attribute8
           , NVL(l_serial_n_attribute9, msn2.serial_n_attribute9) serial_n_attribute9
           , NVL(l_serial_n_attribute10, msn2.serial_n_attribute10) serial_n_attribute10
           , -- End for bug # 4947399
             msn2.serial_country_of_origin serial_country_of_origin
           , msn2.serial_time_since_new serial_time_since_new
           , msn2.serial_cycles_since_new serial_cycles_since_new
           , msn2.serial_time_since_overhaul serial_time_since_overhaul
           , msn2.serial_cycles_since_overhaul serial_cycles_since_overhaul
           , msn2.serial_time_since_repair serial_time_since_repair
           , msn2.serial_cycles_since_repair serial_cycles_since_repair
           , msn2.serial_time_since_visit serial_time_since_visit
           , msn2.serial_cycles_since_visit serial_cycles_since_visit
           , msn2.serial_time_since_mark serial_time_since_mark
           , msn2.serial_cycles_since_mark serial_cycles_since_mark
           , msn2.serial_num_of_repairs serial_num_of_repairs
           , msn2.serial_initialization_date serial_initialization_date
           , msn2.serial_completion_date serial_completion_date
           , msn2.serial_fixed_asset_tag serial_fixed_asset_tag
           , msn2.serial_vendor_serial serial_vendor_serial
           , msn2.project_number project_number -- Fix For Bug: 4907062
           , msn2.project project
           , msn2.task_number task_number  -- Fix For Bug: 4907062
           , msn2.task task
           , msn2.cost_group cost_group
           , NVL(l_lot_number, mln.lot_number) lot_number
           , msn2.serial_number_status serial_number_status
           , msn2.job_name job_name
           ,   -- Added as part of change for patchset "I".
             msn2.LOCATOR LOCATOR
           , TO_CHAR(mln.expiration_date, g_date_format_mask) lot_expiration_date
           ,   -- Added for Bug 2795525,
             mln.attribute_category lot_attribute_category
           , -- Start for bug # 4947399
             NVL(l_lot_c_attribute1, mln.c_attribute1) lot_c_attribute1
           , NVL(l_lot_c_attribute2, mln.c_attribute2) lot_c_attribute2
           , NVL(l_lot_c_attribute3, mln.c_attribute3) lot_c_attribute3
           , NVL(l_lot_c_attribute4, mln.c_attribute4) lot_c_attribute4
           , NVL(l_lot_c_attribute5, mln.c_attribute5) lot_c_attribute5
           , NVL(l_lot_c_attribute6, mln.c_attribute6) lot_c_attribute6
           , NVL(l_lot_c_attribute7, mln.c_attribute7) lot_c_attribute7
           , NVL(l_lot_c_attribute8, mln.c_attribute8) lot_c_attribute8
           , NVL(l_lot_c_attribute9, mln.c_attribute9) lot_c_attribute9
           , NVL(l_lot_c_attribute10, mln.c_attribute10) lot_c_attribute10
           , NVL(l_lot_c_attribute11, mln.c_attribute11) lot_c_attribute11
           , NVL(l_lot_c_attribute12, mln.c_attribute12) lot_c_attribute12
           , NVL(l_lot_c_attribute13, mln.c_attribute13) lot_c_attribute13
           , NVL(l_lot_c_attribute14, mln.c_attribute14) lot_c_attribute14
           , NVL(l_lot_c_attribute15, mln.c_attribute15) lot_c_attribute15
           , NVL(l_lot_c_attribute16, mln.c_attribute16) lot_c_attribute16
           , NVL(l_lot_c_attribute17, mln.c_attribute17) lot_c_attribute17
           , NVL(l_lot_c_attribute18, mln.c_attribute18) lot_c_attribute18
           , NVL(l_lot_c_attribute19, mln.c_attribute19) lot_c_attribute19
           , NVL(l_lot_c_attribute20, mln.c_attribute20) lot_c_attribute20
           , TO_CHAR(NVL(l_lot_d_attribute1, mln.d_attribute1), g_date_format_mask) lot_d_attribute1
           ,   -- Added for Bug 2795525,
             TO_CHAR(NVL(l_lot_d_attribute2, mln.d_attribute2), g_date_format_mask) lot_d_attribute2
           ,   -- Added for Bug 2795525,
             TO_CHAR(NVL(l_lot_d_attribute3, mln.d_attribute3), g_date_format_mask) lot_d_attribute3
           ,   -- Added for Bug 2795525,
             TO_CHAR(NVL(l_lot_d_attribute4, mln.d_attribute4), g_date_format_mask) lot_d_attribute4
           ,   -- Added for Bug 2795525,
             TO_CHAR(NVL(l_lot_d_attribute5, mln.d_attribute5), g_date_format_mask) lot_d_attribute5
           ,   -- Added for Bug 2795525,
             TO_CHAR(NVL(l_lot_d_attribute6, mln.d_attribute6), g_date_format_mask) lot_d_attribute6
           ,   -- Added for Bug 2795525,
             TO_CHAR(NVL(l_lot_d_attribute7, mln.d_attribute7), g_date_format_mask) lot_d_attribute7
           ,   -- Added for Bug 2795525,
             TO_CHAR(NVL(l_lot_d_attribute8, mln.d_attribute8), g_date_format_mask) lot_d_attribute8
           ,   -- Added for Bug 2795525,
             TO_CHAR(NVL(l_lot_d_attribute9, mln.d_attribute9), g_date_format_mask) lot_d_attribute9
           ,   -- Added for Bug 2795525,
             TO_CHAR(NVL(l_lot_d_attribute10, mln.d_attribute10), g_date_format_mask) lot_d_attribute10
           ,   -- Added for Bug 2795525,
             NVL(l_lot_n_attribute1, mln.n_attribute1) lot_n_attribute1
           , NVL(l_lot_n_attribute2, mln.n_attribute2) lot_n_attribute2
           , NVL(l_lot_n_attribute3, mln.n_attribute3) lot_n_attribute3
           , NVL(l_lot_n_attribute4, mln.n_attribute4) lot_n_attribute4
           , NVL(l_lot_n_attribute5, mln.n_attribute5) lot_n_attribute5
           , NVL(l_lot_n_attribute6, mln.n_attribute6) lot_n_attribute6
           , NVL(l_lot_n_attribute7, mln.n_attribute7) lot_n_attribute7
           , NVL(l_lot_n_attribute8, mln.n_attribute8) lot_n_attribute8
           , NVL(l_lot_n_attribute9, mln.n_attribute9) lot_n_attribute9
           , NVL(l_lot_n_attribute10, mln.n_attribute10) lot_n_attribute10
           , -- End for bug # 4947399
             mln.territory_code lot_country_of_origin
           , mln.grade_code lot_grade_code
           , TO_CHAR(mln.origination_date, g_date_format_mask) lot_origination_date
           ,   -- Added for Bug 2795525,
             mln.date_code lot_date_code
           , TO_CHAR(mln.change_date, g_date_format_mask) lot_change_date
           ,   -- Added for Bug 2795525,
             mln.age lot_age
           , TO_CHAR(mln.retest_date, g_date_format_mask) lot_retest_date
           ,   -- Added for Bug 2795525,
             TO_CHAR(mln.maturity_date, g_date_format_mask) lot_maturity_date
           ,   -- Added for Bug 2795525,
             mln.item_size lot_item_size
           , mln.color lot_color
           , mln.volume lot_volume
           , mln.volume_uom lot_volume_uom
           , mln.place_of_origin lot_place_of_origin
           , TO_CHAR(mln.best_by_date, g_date_format_mask) lot_best_by_date
           ,   -- Added for Bug 2795525,
             mln.LENGTH lot_length
           , mln.length_uom lot_length_uom
           , mln.recycled_content lot_recycled_cont
           , mln.thickness lot_thickness
           , mln.thickness_uom lot_thickness_uom
           , mln.width lot_width
           , mln.width_uom lot_width_uom
           , mln.curl_wrinkle_fold lot_curl
           , mln.vendor_name lot_vendor
        FROM mtl_lot_numbers mln
           , mtl_material_statuses_vl mmsvl1
           , mtl_parameters mp
           , (SELECT msik.concatenated_segments item
                   , WMS_DEPLOY.GET_CLIENT_ITEM(l_organization_id, msik.inventory_item_id) client_item		-- Added for LSP Project, bug 9087971
                   , msik.inventory_item_id inventory_item_id
                   , msik.organization_id organization_id
                   , msik.description item_description
                   , l_revision revision
                   , poh.hazard_class item_hazard_class
                   , msik.attribute_category item_attribute_category
                   , msik.attribute1 item_attribute1
                   , msik.attribute2 item_attribute2
                   , msik.attribute3 item_attribute3
                   , msik.attribute4 item_attribute4
                   , msik.attribute5 item_attribute5
                   , msik.attribute6 item_attribute6
                   , msik.attribute7 item_attribute7
                   , msik.attribute8 item_attribute8
                   , msik.attribute9 item_attribute9
                   , msik.attribute10 item_attribute10
                   , msik.attribute11 item_attribute11
                   , msik.attribute12 item_attribute12
                   , msik.attribute13 item_attribute13
                   , msik.attribute14 item_attribute14
                   , msik.attribute15 item_attribute15
                   , mmsvl2.status_code serial_number_status
                   , msn.attribute_category serial_attribute_category
                   , msn.c_attribute1 serial_c_attribute1
                   , msn.c_attribute2 serial_c_attribute2
                   , msn.c_attribute3 serial_c_attribute3
                   , msn.c_attribute4 serial_c_attribute4
                   , msn.c_attribute5 serial_c_attribute5
                   , msn.c_attribute6 serial_c_attribute6
                   , msn.c_attribute7 serial_c_attribute7
                   , msn.c_attribute8 serial_c_attribute8
                   , msn.c_attribute9 serial_c_attribute9
                   , msn.c_attribute10 serial_c_attribute10
                   , msn.c_attribute11 serial_c_attribute11
                   , msn.c_attribute12 serial_c_attribute12
                   , msn.c_attribute13 serial_c_attribute13
                   , msn.c_attribute14 serial_c_attribute14
                   , msn.c_attribute15 serial_c_attribute15
                   , msn.c_attribute16 serial_c_attribute16
                   , msn.c_attribute17 serial_c_attribute17
                   , msn.c_attribute18 serial_c_attribute18
                   , msn.c_attribute19 serial_c_attribute19
                   , msn.c_attribute20 serial_c_attribute20
                   , TO_CHAR(msn.d_attribute1, g_date_format_mask) serial_d_attribute1
                   ,   -- Added for Bug 2795525,
                     TO_CHAR(msn.d_attribute2, g_date_format_mask) serial_d_attribute2
                   ,   -- Added for Bug 2795525,
                     TO_CHAR(msn.d_attribute3, g_date_format_mask) serial_d_attribute3
                   ,   -- Added for Bug 2795525,
                     TO_CHAR(msn.d_attribute4, g_date_format_mask) serial_d_attribute4
                   ,   -- Added for Bug 2795525,
                     TO_CHAR(msn.d_attribute5, g_date_format_mask) serial_d_attribute5
                   ,   -- Added for Bug 2795525,
                     TO_CHAR(msn.d_attribute6, g_date_format_mask) serial_d_attribute6
                   ,   -- Added for Bug 2795525,
                     TO_CHAR(msn.d_attribute7, g_date_format_mask) serial_d_attribute7
                   ,   -- Added for Bug 2795525,
                     TO_CHAR(msn.d_attribute8, g_date_format_mask) serial_d_attribute8
                   ,   -- Added for Bug 2795525,
                     TO_CHAR(msn.d_attribute9, g_date_format_mask) serial_d_attribute9
                   ,   -- Added for Bug 2795525,
                     TO_CHAR(msn.d_attribute10, g_date_format_mask) serial_d_attribute10
                   ,   -- Added for Bug 2795525,
                     msn.n_attribute1 serial_n_attribute1
                   , msn.n_attribute2 serial_n_attribute2
                   , msn.n_attribute3 serial_n_attribute3
                   , msn.n_attribute4 serial_n_attribute4
                   , msn.n_attribute5 serial_n_attribute5
                   , msn.n_attribute6 serial_n_attribute6
                   , msn.n_attribute7 serial_n_attribute7
                   , msn.n_attribute8 serial_n_attribute8
                   , msn.n_attribute9 serial_n_attribute9
                   , msn.n_attribute10 serial_n_attribute10
                   , msn.territory_code serial_country_of_origin
                   , msn.time_since_new serial_time_since_new
                   , msn.cycles_since_new serial_cycles_since_new
                   , msn.time_since_overhaul serial_time_since_overhaul
                   , msn.cycles_since_overhaul serial_cycles_since_overhaul
                   , msn.time_since_repair serial_time_since_repair
                   , msn.cycles_since_repair serial_cycles_since_repair
                   , msn.time_since_visit serial_time_since_visit
                   , msn.cycles_since_visit serial_cycles_since_visit
                   , msn.time_since_mark serial_time_since_mark
                   , msn.cycles_since_mark serial_cycles_since_mark
                   , msn.number_of_repairs serial_num_of_repairs
                   , TO_CHAR(msn.initialization_date, g_date_format_mask) serial_initialization_date
                   -- Added for Bug 2795525,
                   , TO_CHAR(msn.completion_date, g_date_format_mask) serial_completion_date
                   -- Added for Bug 2795525,      ,
                   , msn.fixed_asset_tag serial_fixed_asset_tag
                   , msn.vendor_serial_number serial_vendor_serial
                   , l_project_number project_number -- Fix For Bug: 4907062
                   , l_project_name project
                   , l_task_number task_number -- Fix For Bug: 4907062
                   , l_task_name task
                   , ccg.cost_group cost_group
                   , msn.lot_number lot_number
                   , msn.serial_number serial_number
                   , wipent.wip_entity_name job_name
                   ,   -- Added as part of change for patchset "I".
                     wilk.concatenated_segments LOCATOR
                    --milk.concatenated_segments LOCATOR -- Modified for bug # 5015415
                FROM mtl_system_items_vl msik
                   , mtl_material_statuses_vl mmsvl2
                   , po_hazard_classes poh
                   , mtl_serial_numbers msn
                   , cst_cost_groups ccg
                   , wip_entities wipent
                   , wms_item_locations_kfv wilk  -- Modified for bug # 5015415
                  -- , mtl_item_locations_kfv milk   -- Added as part of change for patchset "I".
               WHERE msik.inventory_item_id = l_inventory_item_id
                 AND msik.organization_id = l_organization_id
                 AND poh.hazard_class_id(+) = msik.hazard_class_id
                 AND msn.current_organization_id(+) = msik.organization_id
                 AND msn.inventory_item_id(+) = msik.inventory_item_id
                 AND msn.serial_number(+) = l_serial_number
                 AND mmsvl2.status_id(+) = msn.status_id
                 AND ccg.cost_group_id(+) = msn.cost_group_id
                 AND wipent.wip_entity_id(+) = msn.wip_entity_id
         /* The following conditions have been modified for bug # 5015415.

         For PJM Org, Locator field in Material Label should not show the Project and task id's.
         This is because, the Project and Task Id's are not Bar code transactable.
         In mtl_item_locations_kfv, the cocatenated segments will have Project and
         Task Id's attached to it. Whereas in wms_item_locations_kfv, concatenated
         segments will have only the physical details (Row, Rack and Bin)
         and not the project and Task id's.

                 AND milk.inventory_location_id(+) = l_locator_id
                 AND milk.organization_id(+) = msik.organization_id
                 AND milk.subinventory_code(+) = l_subinventory*/

                 AND wilk.inventory_location_id(+) = l_locator_id
                 AND wilk.organization_id(+) = msik.organization_id
                 AND wilk.subinventory_code(+) = l_subinventory) msn2   -- Added as part of change for patchset "I".
       WHERE mln.organization_id(+) = l_organization_id
         AND mln.inventory_item_id(+) = l_inventory_item_id
         AND mmsvl1.status_id(+) = mln.status_id
         AND mln.lot_number(+) = msn2.lot_number
         AND mp.organization_id = msn2.organization_id
         AND mln.lot_number(+) = l_lot_number;

/* added for invconv, to get OPM lot attributes */
	CURSOR  get_lot_info IS
	select
	parent_lot_number,
	expiration_action_date ,
	expiration_action_code,
	hold_date   ,
	supplier_lot_number,
	origination_type ,
	grade_code,
	maturity_date,
	retest_date,
	expiration_date,
	origination_date,
        sts.status_code
	FROM
	MTL_LOT_NUMBERS l,
        mtl_material_statuses_vl sts
	WHERE LOT_NUMBER = l_lot_number AND
	      INVENTORY_ITEM_ID = l_inventory_item_id AND
	      ORGANIZATION_ID = l_organization_id
              AND sts.status_id(+) = l.status_id; -- Bug 4355080

 /* added for invconv,to get OPM lot attributes , if the lot is new then the data
       must be fetched from mtlt */

	CURSOR	mtlt_lot_info_cur IS
	SELECT		parent_lot_number,
				expiration_action_date ,
				expiration_action_code,
				hold_date   ,
				supplier_lot_number,
				origination_type ,
				grade_code,
				maturity_date,
				retest_date,
			    lot_expiration_date,
				origination_date,
                                sts.status_code
	FROM	mtl_transaction_lots_temp t,
                mtl_material_statuses_vl sts
	WHERE	transaction_temp_id = p_input_param.transaction_temp_id AND
	  lot_number		    = l_lot_number
              AND sts.status_id(+) = t.status_id; -- Bug 4355080


   --R12 PROJECT LABEL SET with RFID
    CURSOR c_label_formats_in_set(p_format_set_id IN NUMBER)  IS
       select wlfs.format_id label_format_id, wlf.label_entity_type --FOR SETS
	 from wms_label_set_formats wlfs , wms_label_formats wlf
	 where WLFS.SET_ID = p_format_set_id
	 and wlfs.set_id = wlf.label_format_id
	 and wlf.label_entity_type = 1
	 AND WLF.DOCUMENT_ID = 2
	 UNION --FOR FORMATS
	 select label_format_id,nvl(wlf.label_entity_type,0)
	 from wms_label_formats wlf
	 where  wlf.label_format_id =  p_format_set_id
	 and nvl(wlf.label_entity_type,0) = 0 --for label formats only validation
	 AND WLF.DOCUMENT_ID = 2 ;


   -- Interface transaction_id 71629
    -- lpn_id   2170
    serial_rec              serial_cur%ROWTYPE;
    l_org_type              BOOLEAN                                          := FALSE;
    l_serial_label          LONG                                             := '';
    l_get_org_id            NUMBER                                           := 0;
    l_is_wms_org            BOOLEAN;
    l_selected_fields       inv_label.label_field_variable_tbl_type;
    l_selected_fields_count NUMBER;
    l_api_name              VARCHAR2(20)                                     := 'get_variable_data';
    l_return_status         VARCHAR2(240);
    l_error_message         VARCHAR2(240);
    l_api_status            VARCHAR2(240);
    i                       NUMBER;
    l_business_flow_code    NUMBER                                           := p_label_type_info.business_flow_code;
    l_count                 NUMBER;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(240);
    serial_count            NUMBER;
    l_serial_numbers_table  inv_label.serial_tab_type;
    i                       BINARY_INTEGER;
    l_wms_installed         BOOLEAN;
    l_serial_data           LONG                                             := '';
    l_label_format_id       NUMBER                                           := 0;
    l_label_format          VARCHAR2(100)                                    := '';
    l_printer               VARCHAR2(30)                                     := '';
    selected_fields_count   NUMBER;
    i                       NUMBER;
    j                       NUMBER;
    l_serial_table_index    NUMBER;
    l_serial_loop_count     NUMBER;
    l_purchase_order        po_headers_all.segment1%TYPE;
    l_label_index           NUMBER;
    l_label_request_id      NUMBER;
    --I cleanup, use l_prev_format_id to record the previous label format
    l_prev_format_id        NUMBER;
    -- I cleanup, user l_prev_sub to record the previous subinventory
    --so that get_printer is not called if the subinventory is the same
    l_prev_sub              VARCHAR2(30);
    -- a list of columns that are selected for format
    l_column_name_list      LONG;
    l_patch_level           NUMBER;
    -- Added the variable for Bug 4642062 to store the job name
    l_wip_entity_name       wip_entities.wip_entity_name%TYPE;

    --Start: Enabling EPC generation for R12 Project
    l_epc VARCHAR2(300);
    l_epc_ret_status VARCHAR2(10);
    l_epc_ret_msg VARCHAR2(1000);
    l_label_status VARCHAR2(1);
    l_label_err_msg VARCHAR2(1000);
    l_is_epc_exist VARCHAR2(1) := 'N';
    l_label_format_set_id NUMBER;
    --End: Enabling EPC generation for R12 Project

  BEGIN
     x_return_status       := fnd_api.g_ret_sts_success;
     l_label_err_msg := NULL;
    l_debug               := inv_label.l_debug;

    IF (
        (inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j)
        AND(inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)
       ) THEN
      l_patch_level  := 1;   --Patchset J and above
    ELSE
      l_patch_level  := 0;   --Below Patchset J
    END IF;

    IF (l_debug = 1) THEN
      TRACE('**In PVT2: Serial label**');
      TRACE(
           '  Business_flow='
        || p_label_type_info.business_flow_code
        || ', Transaction ID='
        || p_transaction_id
        || ', Transaction Identifier='
        || p_transaction_identifier
      );
    END IF;

    -- Get org for p_transaction_id
    -- As part of fix for bug 3472432, the rti_get_org_cur is beign replaced with rt_get_org_cur.
    IF p_label_type_info.business_flow_code IN(1, 2, 3, 4) THEN
      OPEN rt_get_org_cur;

      FETCH rt_get_org_cur
       INTO l_get_org_id;

      IF rt_get_org_cur%NOTFOUND THEN
        IF (l_debug = 1) THEN
          TRACE(' No record found in RTI for ID: ' || p_transaction_id);
        END IF;

        CLOSE rt_get_org_cur;

        RETURN;
      ELSE
        CLOSE rt_get_org_cur;
      END IF;

      l_is_wms_org  :=
        wms_install.check_install(x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data
        , p_organization_id            => l_get_org_id);

      IF l_return_status <> 'S' THEN
        fnd_message.set_name('WMS', 'WMS_INSTALL_CHECK_INSTALL_FAILED');
        fnd_msg_pub.ADD;
        RETURN;
      END IF;

      IF (l_debug = 1) THEN
        IF (l_is_wms_org = TRUE) THEN
          TRACE(' Org is WMS enabled ');
        ELSE
          TRACE(' Org is INV enabled ');
        END IF;
      END IF;
    END IF;

    --Main Start
    IF p_transaction_id IS NOT NULL THEN   -- Business flow + transaction_id passed.
      -- txn driven

      /* Patchset J- Open the new cursor for patchset J and above. Otherwise, the existing
       * code remains as it is.
       */
      IF (p_label_type_info.business_flow_code IN(1, 2, 3, 4)
          AND(l_patch_level = 1)) THEN
        TRACE('Patchset J code');
        l_receipt_number  := inv_rcv_common_apis.g_rcv_global_var.receipt_num;

        OPEN rt_serial_cur;

        FETCH rt_serial_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_project_id
            , l_task_id
            , l_revision
            , l_serial_number
            , l_purchase_order
            , l_subinventory
            , l_locator_id
            , l_vendor_id
            , l_vendor_site_id
            , l_uom
            , l_oe_order_header_id --Bug 4582954
            , l_oe_order_line_id;  --Bug 4582954

        IF rt_serial_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' (1)No Serial number found for this given Interface Transaction ID:' || p_transaction_id);
          END IF;

          CLOSE rt_serial_cur;

          RETURN;
        END IF;
      ELSIF((l_patch_level = 0)
            AND(p_label_type_info.business_flow_code IN(1, 2))
            AND(l_is_wms_org = TRUE)) THEN
        -- Receipt(1), Inspection(2) or Putaway Drop(4) and org is WMS enabled
        -- In an INV org there are no serial numbers at these points in the transaction.
        l_receipt_number  := inv_rcv_common_apis.g_rcv_global_var.receipt_num;

        OPEN rti_serial_lpn_cur;

        FETCH rti_serial_lpn_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_project_id
            , l_task_id
            , l_revision
            , l_serial_number
            , l_purchase_order
            , l_subinventory
            , l_vendor_id
            , l_vendor_site_id
            , l_oe_order_header_id --Bug 4582954
            , l_oe_order_line_id;  --Bug 4582954

        IF rti_serial_lpn_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' (1)No Serial number found for this given Interface Transaction ID:' || p_transaction_id);
          END IF;

          CLOSE rti_serial_lpn_cur;

          RETURN;
        END IF;
      ELSIF(
            (l_patch_level = 0)
            AND(
                (p_label_type_info.business_flow_code IN(3)
                 AND(l_is_wms_org = TRUE))
                OR(p_label_type_info.business_flow_code IN(4)
                   AND(l_is_wms_org = FALSE))
               )
           ) THEN
        -- Delivery(3) and org is an INV org.
        l_receipt_number  := inv_rcv_common_apis.g_rcv_global_var.receipt_num;

        OPEN rti_serial_msnt_cur;

        FETCH rti_serial_msnt_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_project_id
            , l_task_id
            , l_revision
            , l_fm_serial_number
            , l_to_serial_number
            , l_purchase_order
            , l_subinventory
            , l_vendor_id
            , l_vendor_site_id
            , l_oe_order_header_id --Bug 4582954
            , l_oe_order_line_id;  --Bug 4582954

        IF rti_serial_msnt_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' (2)No Serial number found for this given Interface Transaction ID:' || p_transaction_id);
          END IF;

          CLOSE rti_serial_msnt_cur;

          RETURN;
        ELSE
          -- getting range serial numbers
          inv_label.get_number_between_range(
            fm_x_number                  => l_fm_serial_number
          , to_x_number                  => l_to_serial_number
          , x_return_status              => l_return_status
          , x_number_table               => l_serial_numbers_table
          );

          IF l_return_status <> 'S' THEN
            fnd_message.set_name('WMS', 'WMS_GET_SER_CUR_FAILED');
            fnd_msg_pub.ADD;
            RETURN;
          END IF;

          IF (l_debug = 1) THEN
            TRACE(' Number of SN in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
          END IF;

          l_serial_number  := l_serial_numbers_table(1);
        END IF;
      ELSIF(p_label_type_info.business_flow_code IN(6)) THEN
        -- Cross Dock(6).
        -- Here in this case the delivery_detail_id is being passed.
        -- Delivery detail ID passed means that we just have to print serial label for the one  delivery detail id and
        -- not all the delivery detail id's in the delivery.
        -- The cost group will be derived from the table wms_license_plate_numbers for the LPN stamped on the Delivery_detail_id.
        OPEN wdd_serial_cur;

        FETCH wdd_serial_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_project_id
            , l_task_id
            , l_revision
            , l_serial_number
            , l_subinventory
            , l_uom;

        IF wdd_serial_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' No Serial number found for this given Delivery Detail ID:' || p_transaction_id);
          END IF;

          CLOSE wdd_serial_cur;

          RETURN;
       -- Bug 3836623
       -- Can not close the cursor because there maybe more record available
       -- ELSE
       --   CLOSE wdd_serial_cur;
        END IF;
      ELSIF p_label_type_info.business_flow_code IN(13, 23, 27) THEN
        -- Miscellaneous/Alias Receipt(13), Miscellaneous/Alias Issue(23)
           -- Put Away pregeneration(27)
           -- Flow, MMTT based (33), transaction_identifier=1
        OPEN mmtt_serial_cur;

        FETCH mmtt_serial_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_project_id
            , l_task_id
            , l_revision
            , l_fm_serial_number
            , l_to_serial_number
            , l_subinventory
            , l_uom
            , l_locator_id;  /* Added for Bug # 4672471 */

        IF mmtt_serial_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' No Serial number found for this given Transaction Temp ID:' || p_transaction_id);
          END IF;

          CLOSE mmtt_serial_cur;

          RETURN;
        ELSE
          inv_label.get_number_between_range(
            fm_x_number                  => l_fm_serial_number
          , to_x_number                  => l_to_serial_number
          , x_return_status              => l_return_status
          , x_number_table               => l_serial_numbers_table
          );

          IF l_return_status <> 'S' THEN
            fnd_message.set_name('WMS', 'WMS_GET_SER_CUR_FAILED');
            fnd_msg_pub.ADD;
            RETURN;
          END IF;

          IF (l_debug = 1) THEN
            TRACE(' Number of SN in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
          END IF;

          l_serial_number  := l_serial_numbers_table(1);
        END IF;
      ELSIF (p_label_type_info.business_flow_code IN(33) AND p_transaction_identifier = 1)  THEN

        IF (l_debug = 1) THEN
          trace(' WIP - LPN work orderless completion business flow.');
        END IF;

        OPEN wip_lpn_serial_cur;
        FETCH wip_lpn_serial_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_project_id
            , l_task_id
            , l_revision
            , l_serial_number
            , l_subinventory
            , l_uom
            , l_locator_id;

        IF (l_debug = 1) THEN
          trace('l_serial_number : ' || l_serial_number);
        END IF;

        IF wip_lpn_serial_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            trace('No record returned from wip_lpn_serial_cur cursor');
          END IF;
          CLOSE wip_lpn_serial_cur;
          RETURN;
        END IF;

      ELSIF p_label_type_info.business_flow_code IN(21) THEN
        -- Ship Confirm
        -- The delivery_id has being passed. Delivery ID passed means that all the delivery details ID have
        -- to be derived for the delivery ID. There will be one record per serial number in the wsh_delivery_details.
        -- The cost group will be derived from the table wms_license_plate_numbers for the LPN stamped on the Delivery_detail_id.
        IF (l_debug = 1) THEN
          TRACE(' Ship Confirm Flow with Delivery ID: ' || p_transaction_id);
        END IF;
        OPEN wda_serial_cur;
        FETCH wda_serial_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_project_id
            , l_task_id
            , l_revision
            , l_serial_number
            , l_fm_serial_number
            , l_to_serial_number
            , l_subinventory
            , l_uom;

        IF wda_serial_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' No Serial number found for this given ID:' || p_transaction_id);
          END IF;

          CLOSE wda_serial_cur;

          RETURN;
        --Start of New code to fix Bug# 4290536
        ELSE
          IF (l_debug = 1) THEN
            TRACE(' Found Serial Number for the given ID: ' || p_transaction_id||'; l_serial_number: '||l_serial_number||'; l_fm_serial_number: '||l_fm_serial_number||'; l_to_serial_number: '||l_to_serial_number);
          END IF;
          IF l_fm_serial_number IS NOT NULL THEN
            -- Gett range of Serial Numbers
            inv_label.get_number_between_range(
              fm_x_number     => l_fm_serial_number
            , to_x_number     => l_to_serial_number
            , x_return_status => l_return_status
            , x_number_table  => l_serial_numbers_table);

            IF l_return_status <> 'S' THEN
              FND_MESSAGE.SET_NAME('WMS', 'WMS_GET_SER_CUR_FAILED');
              FND_MSG_PUB.ADD;
              RETURN;
            END IF;

            IF (l_debug = 1) THEN
              TRACE(' Number of SN in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
            END IF;
            l_serial_number  := l_serial_numbers_table(1);
          END IF;
        --End of Newly added code to fix Bug# 4290536
        END IF;
      -- Bug Number: 3896738
      -- Added the business flow Manufacturing Cross-Dock(37)
      ELSIF p_label_type_info.business_flow_code IN(26, 37) THEN
        -- WIP Completion.
        -- Bug 2825748 : Material Label Is Not Printed On WIP Completion.
        -- LPN Completions:
        -- In this case a record is populated in the MMTT with the item populated in the
        -- MMTT.inventorry_item_id and the LLPN populated in the MMTT.transfer_lpn_id.
        -- As per the WIP team, the LPN is packed before label printing is called
        -- For every item of the completion, one record
        -- is inserted into the MMTT (with the MMTT.TRANSFER_LPN_ID ) populated and
        -- label printing is called. Serial Labels are printed for the completed items
                    --
        -- Non-LPN Completion
        -- In this case a record is populated in the MMTT with the item populated in the
        -- MMTT.inventory_item_id with all the related inforamtion.
        OPEN wip_serial_cur;

        FETCH wip_serial_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_cost_group_id
            , l_project_id
            , l_task_id
            , l_uom
            , l_revision
            , l_fm_serial_number
            , l_to_serial_number
            , l_subinventory
            , l_locator_id
            , l_wip_entity_name  --Added for Bug 4642062
            , l_wip_entity_id;

        TRACE(
             ' wip_serial_cur '
          || ', Item ID='
          || l_inventory_item_id
          || ', Organization ID='
          || l_organization_id
          || ', Lot Number='
          || l_lot_number
          || ', Project ID='
          || l_project_id
          || ', Cost Group ID='
          || l_cost_group_id
          || ', Task ID='
          || l_task_id
          || ', Transaction UOM='
          || l_uom
          || ', Item Revision='
          || l_revision
          || ', Subinventory Code='
          || l_subinventory
          || ', Locator ID='
          || l_locator_id
          || ', Job Name='
          || l_wip_entity_name
          || ', Job Id='
          || l_wip_entity_id
        );

        IF wip_serial_cur%NOTFOUND THEN
          TRACE(' No records found for transaction_temp_id in MMTT');

          CLOSE wip_serial_cur;
        ELSE
          inv_label.get_number_between_range(
            fm_x_number                  => l_fm_serial_number
          , to_x_number                  => l_to_serial_number
          , x_return_status              => l_return_status
          , x_number_table               => l_serial_numbers_table
          );

          IF l_return_status <> 'S' THEN
            fnd_message.set_name('WMS', 'WMS_GET_SER_CUR_FAILED');
            fnd_msg_pub.ADD;
            RETURN;
          END IF;

          TRACE(' Count of rows in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
          l_serial_number  := l_serial_numbers_table(1);
          TRACE('l_serial_number after call to GET_SERIALS_BETWEEN_RANGE ' || l_serial_number);
        END IF;
      -- Flow Labels
      ELSIF p_label_type_info.business_flow_code IN(33)
            AND p_transaction_identifier > 1 THEN
        -- Flow Completion, not MMTT based
        IF p_transaction_identifier = 2 THEN
          OPEN flow_serial_curs_mti;

          FETCH flow_serial_curs_mti
           INTO l_inventory_item_id
              , l_organization_id
              , l_lot_number
              , l_project_id
              , l_task_id
              , l_revision
              , l_fm_serial_number
              , l_to_serial_number
              , l_subinventory
              , l_locator_id    -- Added for Bug #5533362
              , l_uom;

          IF flow_serial_curs_mti%NOTFOUND THEN
            IF (l_debug = 1) THEN
              TRACE(' No Flow Data found for this given ID:' || p_transaction_id);
            END IF;

            CLOSE flow_serial_curs_mti;

            RETURN;
          ELSE
            inv_label.get_number_between_range(
              fm_x_number                  => l_fm_serial_number
            , to_x_number                  => l_to_serial_number
            , x_return_status              => l_return_status
            , x_number_table               => l_serial_numbers_table
            );

            IF l_return_status <> 'S' THEN
              fnd_message.set_name('WMS', 'WMS_GET_SER_CUR_FAILED');
              fnd_msg_pub.ADD;
              RETURN;
            END IF;

            IF (l_debug = 1) THEN
              TRACE(' Count of rows in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
            END IF;

            l_serial_number  := l_serial_numbers_table(1);
          END IF;
        ELSIF p_transaction_identifier = 3 THEN
          OPEN flow_serial_curs_mol;

          FETCH flow_serial_curs_mol
           INTO l_inventory_item_id
              , l_organization_id
              , l_lot_number
              , l_project_id
              , l_task_id
              , l_revision
              , l_fm_serial_number
              , l_to_serial_number
              , l_subinventory
              , l_uom;

          IF flow_serial_curs_mol%NOTFOUND THEN
            IF (l_debug = 1) THEN
              TRACE(' No Flow Data found for this given ID:' || p_transaction_id);
            END IF;

            CLOSE flow_serial_curs_mol;

            RETURN;
          ELSE
            inv_label.get_number_between_range(
              fm_x_number                  => l_fm_serial_number
            , to_x_number                  => l_to_serial_number
            , x_return_status              => l_return_status
            , x_number_table               => l_serial_numbers_table
            );

            IF l_return_status <> 'S' THEN
              fnd_message.set_name('WMS', 'WMS_GET_SER_CUR_FAILED');   -- Code message for this.
              fnd_msg_pub.ADD;
              RETURN;
            END IF;

            IF (l_debug = 1) THEN
              TRACE(' Count of rows in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
            END IF;

            l_serial_number  := l_serial_numbers_table(1);
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            TRACE(' Invalid transaction_identifier passed' || p_transaction_identifier);
          END IF;

          RETURN;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          TRACE('No serial number will be printed');
        END IF;

        RETURN;
      END IF;
    ELSE
      -- On demand, get information from p_input_param
      l_organization_id    := p_input_param.organization_id;
      l_inventory_item_id  := p_input_param.inventory_item_id;
      l_lot_number         := p_input_param.lot_number;
      l_serial_number      := p_input_param.serial_number;
      l_project_id         := p_input_param.project_id;
      l_task_id            := p_input_param.task_id;
      l_revision           := p_input_param.revision;
      l_wip_entity_id      := p_input_param.transaction_source_id;
    END IF;

    OPEN c_project_enabled(l_organization_id);
      FETCH c_project_enabled INTO l_is_pjm_org;
      IF c_project_enabled%NOTFOUND THEN
        IF (l_debug = 1) THEN
           trace( 'Organization id ' || l_organization_id || 'is not a PJM Org.');
        END IF;
      END IF;
    CLOSE c_project_enabled;

    --Bug #6417575,Label Printing Support for WIP Move Transactions (12.1)
    --  Fetching WIP Job attributes, based on wip_entity_id passed through
    --  transaction_source_id in manual mode.
    --  Currently, printing WIP job information for serial is restricted
    --  only for WIP Completion and Serial Label Manual Printing.
    IF (l_debug = 1) THEN
       trace( 'l_wip_entity_id = ' || l_wip_entity_id);
    END IF;
    IF (l_wip_entity_id IS NOT NULL) THEN
      OPEN wip_attributes_cur;
      FETCH wip_attributes_cur INTO l_wip_entity_name
                                  , l_entity_type
                                  , l_net_quantity
                                  , l_scheduled_start_date
                                  , l_scheduled_completion_date
                                  , l_bom_revision
                                  , l_routing_revision;

      IF wip_attributes_cur%NOTFOUND THEN
        IF (l_debug = 1) THEN
           trace( ' No records returned by wip_attributes_cur cursor');
        END IF;
      END IF;
      CLOSE wip_attributes_cur;
    END IF;

    /*
     * The following code has been added so that the c_project and c_task cursors will be opened
     * only if the organization is project enabled.
     */

    IF l_is_pjm_org = 'Y' THEN
      OPEN c_project;

      -- Fix for 4907062. Fetching project number along with project name
      FETCH c_project INTO l_project_name, l_project_number;

      IF c_project%NOTFOUND THEN
        l_project_name  := '';
      END IF;

      CLOSE c_project;

      OPEN c_task;

      -- Fix for 4907062. Fetching task number along with project name
      FETCH c_task INTO l_task_name, l_task_number;

      IF c_task%NOTFOUND THEN
        l_task_name  := '';
      END IF;

      CLOSE c_task;
    END IF;


    /* Oherwise, it does not need to do that

      -- Get variables defined for the format id passed in.
      inv_label.get_variables_for_format
      (
       x_variables       => l_selected_fields
       , x_variables_count => l_selected_fields_count
       , x_is_variable_exist      => l_is_epc_exist
       , p_format_id     => p_label_type_info.default_format_id
       , p_exist_variable_name    => 'EPC'
       );

    IF (l_selected_fields_count = 0)
       OR(l_selected_fields.COUNT = 0) THEN
      IF (l_debug = 1) THEN
        TRACE('no fields defined for this format: ' || p_label_type_info.default_format_id || ',' || p_label_type_info.default_format_name);
      END IF;
    END IF;


*/


    IF (l_debug = 1) THEN
      TRACE('** in PVT2.get_variable_dataa ** , start ');
    END IF;

    l_serial_data         := '';
    l_serial_table_index  := 1;

    IF (l_debug = 1) THEN
      TRACE('l_serial_number before WHILE LOOP ' || l_serial_number);
    END IF;

    l_serial_loop_count   := 1;
    l_label_index         := 1;
    l_prev_format_id      := -999;
    l_printer             := p_label_type_info.default_printer;
    l_prev_sub            := '####';

    WHILE l_serial_number IS NOT NULL LOOP
      IF (l_debug = 1) THEN
        TRACE(
             'org_id='
          || l_organization_id
          || ',item_id='
          || l_inventory_item_id
          || ',lot='
          || l_lot_number
          || ',serial='
          || l_serial_number
          || ',project_id='
          || l_project_id
          || ',task_id='
          || l_task_id
          || ',revision='
          || l_revision
        );
      END IF;

      /* Start of fix for bug # 4947399 */
      IF (p_label_type_info.business_flow_code IN (13, 23, 26)) THEN
        OPEN c_lot_serial_attributes;
        FETCH c_lot_serial_attributes INTO l_lot_c_attribute1
                                         , l_lot_c_attribute2
                                         , l_lot_c_attribute3
                                         , l_lot_c_attribute4
                                         , l_lot_c_attribute5
                                         , l_lot_c_attribute6
                                         , l_lot_c_attribute7
                                         , l_lot_c_attribute8
                                         , l_lot_c_attribute9
                                         , l_lot_c_attribute10
                                         , l_lot_c_attribute11
                                         , l_lot_c_attribute12
                                         , l_lot_c_attribute13
                                         , l_lot_c_attribute14
                                         , l_lot_c_attribute15
                                         , l_lot_c_attribute16
                                         , l_lot_c_attribute17
                                         , l_lot_c_attribute18
                                         , l_lot_c_attribute19
                                         , l_lot_c_attribute20
                                         , l_lot_d_attribute1
                                         , l_lot_d_attribute2
                                         , l_lot_d_attribute3
                                         , l_lot_d_attribute4
                                         , l_lot_d_attribute5
                                         , l_lot_d_attribute6
                                         , l_lot_d_attribute7
                                         , l_lot_d_attribute8
                                         , l_lot_d_attribute9
                                         , l_lot_d_attribute10
                                         , l_lot_n_attribute1
                                         , l_lot_n_attribute2
                                         , l_lot_n_attribute3
                                         , l_lot_n_attribute4
                                         , l_lot_n_attribute5
                                         , l_lot_n_attribute6
                                         , l_lot_n_attribute7
                                         , l_lot_n_attribute8
                                         , l_lot_n_attribute9
                                         , l_lot_n_attribute10
                                         , l_serial_c_attribute1
                                         , l_serial_c_attribute2
                                         , l_serial_c_attribute3
                                         , l_serial_c_attribute4
                                         , l_serial_c_attribute5
                                         , l_serial_c_attribute6
                                         , l_serial_c_attribute7
                                         , l_serial_c_attribute8
                                         , l_serial_c_attribute9
                                         , l_serial_c_attribute10
                                         , l_serial_c_attribute11
                                         , l_serial_c_attribute12
                                         , l_serial_c_attribute13
                                         , l_serial_c_attribute14
                                         , l_serial_c_attribute15
                                         , l_serial_c_attribute16
                                         , l_serial_c_attribute17
                                         , l_serial_c_attribute18
                                         , l_serial_c_attribute19
                                         , l_serial_c_attribute20
                                         , l_serial_d_attribute1
                                         , l_serial_d_attribute2
                                         , l_serial_d_attribute3
                                         , l_serial_d_attribute4
                                         , l_serial_d_attribute5
                                         , l_serial_d_attribute6
                                         , l_serial_d_attribute7
                                         , l_serial_d_attribute8
                                         , l_serial_d_attribute9
                                         , l_serial_d_attribute10
                                         , l_serial_n_attribute1
                                         , l_serial_n_attribute2
                                         , l_serial_n_attribute3
                                         , l_serial_n_attribute4
                                         , l_serial_n_attribute5
                                         , l_serial_n_attribute6
                                         , l_serial_n_attribute7
                                         , l_serial_n_attribute8
                                         , l_serial_n_attribute9
                                         , l_serial_n_attribute10;
        IF c_lot_serial_attributes%NOTFOUND THEN
           IF (l_debug = 1) THEN
              TRACE(' No records returned by c_lot_serial_attributes cursor');
           END IF;
        END IF;
        CLOSE c_lot_serial_attributes;
      END IF;
      /* End of fix for bug # 4947399 */

      FOR serial_rec IN serial_cur LOOP
        l_serial_data    := '';

        IF (l_debug = 1) THEN
          TRACE(' ^^^New label ^^^');
          TRACE('  Serial Number: ' || l_serial_number);
	END IF;
	l_label_status := INV_LABEL.G_SUCCESS;

	--In R12 moved this Rules engine call before the call to get printer
        /* insert a record into wms_label_requests entity to
         call the label rules engine to get appropriate label
	 In this call if this happens to be for the label-set, the record
	 from wms_label_request will be deleted inside following API*/

        IF (l_debug = 1) THEN
          TRACE(' 1. Apply Rules engine get label set or format');
        END IF;

        inv_label.get_format_with_rule(
          p_document_id                => p_label_type_info.label_type_id
        , p_label_format_id            => p_label_type_info.manual_format_id
        , p_organization_id            => serial_rec.organization_id
        , p_inventory_item_id          => serial_rec.inventory_item_id
        , p_lot_number                 => serial_rec.lot_number
        , p_serial_number              => serial_rec.serial_number
        , p_revision                   => serial_rec.revision
        , p_business_flow_code         => p_label_type_info.business_flow_code
        --, p_printer_name               => l_printer --Blocked in R12 RFID project
        , p_last_update_date           => SYSDATE
        , p_last_updated_by            => fnd_global.user_id
        , p_creation_date              => SYSDATE
        , p_created_by                 => fnd_global.user_id
        -- Added for Bug 2748297 Start
        , p_supplier_id                => l_vendor_id
        , p_supplier_site_id           => l_vendor_site_id
        -- End
        -- Added for bug 4582954 Start
        , p_sales_order_header_id      => l_oe_order_header_id
        , p_sales_order_line_id        => l_oe_order_line_id
        -- End bug 4582954
        , x_return_status              => l_return_status
        , x_label_format_id            => l_label_format_set_id
        , x_label_format               => l_label_format
        , x_label_request_id           => l_label_request_id
        );

        IF l_return_status <> 'S' THEN
	   fnd_message.set_name('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
	   fnd_msg_pub.ADD;
	   l_label_format_set_id     := p_label_type_info.default_format_id;
	   l_label_format            := p_label_type_info.default_format_name;
        END IF;

        IF (l_debug = 1) THEN
	   TRACE('did apply label ' || l_label_format || ',' || l_label_format_set_id || ',req_id ' || l_label_request_id);
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


	      IF (l_debug = 1) THEN
		 TRACE('Insert record into WMS_LABEL_REQUESTS and get label_request_id');
	      END IF;

	      inv_label.get_format_with_rule
		( p_document_id                => p_label_type_info.label_type_id
		  , p_label_format_id            => l_label_formats_in_set.label_format_id --considers manual printer also
		  , p_organization_id            => serial_rec.organization_id
		  , p_inventory_item_id          => serial_rec.inventory_item_id
		  , p_lot_number                 => serial_rec.lot_number
		  , p_serial_number              => serial_rec.serial_number
		  , p_revision                   => serial_rec.revision
		  , p_business_flow_code         => p_label_type_info.business_flow_code
		  --, p_printer_name               => l_printer --Blocked in R12 RFID project
		  , p_last_update_date           => SYSDATE
		  , p_last_updated_by            => fnd_global.user_id
		  , p_creation_date                 => SYSDATE
		  , p_created_by                 => fnd_global.user_id
		  , p_use_rule_engine            => 'N' --------------------------Rules ENgine will NOT get called
		  ,
		  -- Added for Bug 2748297 Start
		  p_supplier_id                  => l_vendor_id
		, p_supplier_site_id           => l_vendor_site_id
		,
		-- End
		x_return_status                => l_return_status
		, x_label_format_id            => l_label_format_id
		, x_label_format               => l_label_format
		, x_label_request_id           => l_label_request_id
		);

	      IF l_return_status <> 'S' THEN
		 fnd_message.set_name('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
		 fnd_msg_pub.ADD;
		 l_label_format_id         := p_label_type_info.default_format_id;
		 l_label_format            := p_label_type_info.default_format_name;
	      END IF;

	      IF (l_debug = 1) THEN
		 TRACE('did apply label ' || l_label_format || ',' || l_label_format_id || ',req_id ' || l_label_request_id);
	      END IF;


	       ELSE --IT IS LABEL FORMAT
		 --Just use the format-id returned

		 l_label_format_id :=  l_label_formats_in_set.label_format_id ;

	      END IF;


	      IF (l_debug = 1) THEN
		 TRACE(
		       ' Getting printer, manual_printer='
		       || p_label_type_info.manual_printer
		       || ',sub='
		       || l_subinventory
		       || ',default printer='
		       || p_label_type_info.default_printer
		       );
	      END IF;


        -- IF clause Added for Add format/printer for manual request
        IF p_label_type_info.manual_printer IS NULL THEN
          -- The p_label_type_info.manual_printer is the one  passed from the manual page.
          -- As per the design, if a printer is passed from the manual page, then we use that printer irrespective.
          IF (l_subinventory IS NOT NULL)
             AND(l_subinventory <> l_prev_sub) THEN
            IF (l_debug = 1) THEN
              TRACE('getting printer with sub ' || l_subinventory);
            END IF;

            BEGIN
	       wsh_report_printers_pvt.get_printer
		 (
		  p_concurrent_program_id      => p_label_type_info.label_type_id
		  , p_user_id                    => fnd_global.user_id
		  , p_responsibility_id          => fnd_global.resp_id
		  , p_application_id             => fnd_global.resp_appl_id
		  , p_organization_id            => l_organization_id
		  , p_zone                       => l_subinventory
		  , p_format_id                  => l_label_format_id --added in R12
		  , x_printer                    => l_printer
		  , x_api_status                 => l_api_status
		  , x_error_message              => l_error_message
              );

              IF l_api_status <> 'S' THEN
                IF (l_debug = 1) THEN
                  TRACE('Error in calling get_printer, set printer as default printer, err_msg:' || l_error_message);
                END IF;

                l_printer  := p_label_type_info.default_printer;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                l_printer  := p_label_type_info.default_printer;
            END;

            l_prev_sub  := l_subinventory;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            TRACE('Set printer as Manual Printer passed in:' || p_label_type_info.manual_printer);
          END IF;

          l_printer  := p_label_type_info.manual_printer;
        END IF;

        IF (l_debug = 1) THEN
          TRACE(
               'Apply Rules engine for format, printer='
            || l_printer
            || ',manual_format_id='
            || p_label_type_info.manual_format_id
            || ',manual_format_name='
            || p_label_type_info.manual_format_name
          );
        END IF;



	IF (l_label_format_id IS NOT NULL) THEN
          -- Derive the fields for the format either passed in or derived via the rules engine.
          IF l_label_format_id <> NVL(l_prev_format_id, -999) THEN
            IF (l_debug = 1) THEN
              TRACE(' Getting variables for new format ' || l_label_format);
            END IF;
	    --changed in R12
            inv_label.get_variables_for_format
	      (x_variables              => l_selected_fields
	       , x_variables_count      => l_selected_fields_count
	       , x_is_variable_exist    => l_is_epc_exist
	       , p_format_id            => l_label_format_id
	       , p_exist_variable_name  => 'EPC'
	       );

	    l_prev_format_id  := l_label_format_id;

            IF (l_selected_fields_count = 0)
               OR(l_selected_fields.COUNT = 0) THEN
              IF (l_debug = 1) THEN
                TRACE('no fields defined for this format: ' || l_label_format || ',' || l_label_format_id);
		TRACE('######## GOING TO THE NEXT LABEL####');
	      END IF;

              GOTO nextlabel;
            END IF;

            IF (l_debug = 1) THEN
              TRACE('   Found selected_fields for format ' || l_label_format || ', num=' || l_selected_fields_count);
            END IF;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            TRACE('No format exists for this label, goto nextlabel');
          END IF;

          GOTO nextlabel;
        END IF;

        -- Added for UCC 128 J Bug #3067059
        inv_label.is_item_gtin_enabled(
          x_return_status              => l_return_status
        , x_gtin_enabled               => l_gtin_enabled
        , x_gtin                       => l_gtin
        , x_gtin_desc                  => l_gtin_desc
        , p_organization_id            => l_organization_id
        , p_inventory_item_id          => l_inventory_item_id
        , p_unit_of_measure            => l_uom
        , p_revision                   => l_revision
        );


	-- Added in R12 RFID compliance project
        -- Get RFID/EPC related information for a format
        -- Only do this if EPC is a field included in the format
        IF l_is_epc_exist = 'Y' THEN
	   IF (l_debug =1) THEN
	      trace('Generating EPC');
	   END IF;

            BEGIN

	       -- Added in R12 RFID compliance
	       -- New field : EPC
	       -- When generate_epc API returns E (expected error) or U(expected error),
	       --   it sets the error message, but generate xml with EPC as null

		WMS_EPC_PVT.generate_epc
		  (p_org_id          => l_organization_id,
		   p_label_type_id   => p_label_type_info.label_type_id, -- 2
		   p_group_id	     => inv_label.EPC_group_id,
		   p_label_format_id => l_label_format_id,
		   p_label_request_id    => l_label_request_id,
		   p_business_flow_code  => p_label_type_info.business_flow_code,
		   x_epc                 => l_epc,
		   x_return_status       => l_epc_ret_status, -- S / E / U
		   x_return_mesg         => l_epc_ret_msg
		   );

		IF (l_debug = 1) THEN
		   trace('Called generate_epc with ');
		   trace('p_group_id='||inv_label.epc_group_id);
		   trace('l_label_format_id='||l_label_format_id||',p_user_id='||fnd_global.user_id);
		   trace('p_org_id='||l_organization_id);
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

	END IF;



	/* variable header */
	l_serial_data                                       := l_serial_data || label_b;

        IF l_label_format <> NVL(p_label_type_info.default_format_name, '@@@') THEN
          l_serial_data  := l_serial_data || ' _FORMAT="' || l_label_format || '"';
        END IF;

        IF (l_printer IS NOT NULL)
           AND(l_printer <> NVL(p_label_type_info.default_printer, '###')) THEN
          l_serial_data  := l_serial_data || ' _PRINTERNAME="' || l_printer || '"';
        END IF;

        l_serial_data                                       := l_serial_data || tag_e;

                /* added by incvonv project - start */
			open get_lot_info;
			FETCH get_lot_info into l_parent_lot_number,
				l_expiration_action_date ,
				l_expiration_action_code,
				l_hold_date   ,
				l_supplier_lot_number,
				l_origination_type ,
				l_grade_code,
				l_maturity_date,
				l_retest_date,
				l_expiration_date,
				l_origination_date,
				l_lot_status; --- Bug 4355080

		   IF	get_lot_info%NOTFOUND
	       THEN
			IF (l_debug = 1) THEN
   				trace('No lot record was found in MLN for lot, '|| l_lot_number );
   				trace('Lot must be new.' );
			END IF;

			-- since  lot is new, lot attributes must exists on MTLT
			OPEN mtlt_lot_info_cur;
			FETCH mtlt_lot_info_cur INTO l_parent_lot_number,
				l_expiration_action_date ,
				l_expiration_action_code,
				l_hold_date   ,
				l_supplier_lot_number,
				l_origination_type ,
				l_grade_code,
				l_maturity_date,
				l_retest_date,
				l_expiration_date,
				l_origination_date,
				l_lot_status; --- Bug 4355080

		    IF	mtlt_lot_info_cur%NOTFOUND
	        THEN
		  	 IF (l_debug = 1) THEN
   				trace('No lot record was found also in MTLT for lot , '|| l_lot_number ||
				   ', transaction_temp_id = ' || p_input_param.transaction_temp_id);
		 	 END IF;
	        END IF;
                --
	        CLOSE mtlt_lot_info_cur; --added along with Bugfix 4290536
                --
	       END IF;      	-- cursor not found
               --
               CLOSE get_lot_info; --added along with Bugfix 4290536
               --
			IF (l_debug = 1) THEN
   				trace(' fabdi ');
   				trace(' Item , ' || serial_rec.item );
   				trace(' lot_number, ' || serial_rec.lot_number);
   				trace(' parent_lot_number, ' || l_parent_lot_number);
  				trace(' grade code, ' || l_grade_code);
   				trace(' expiration action date , ' || l_expiration_action_date);
   				trace(' expiration action code , ' || l_expiration_action_code);
				trace(' origination date , '       || l_origination_date);
			END IF;

		/* added by incvonv project - END */

        IF (l_debug = 1) THEN
          TRACE('Starting assign variables, ');
        END IF;

        l_column_name_list                                  := 'Set variables for ';

        /* Modified for Bug 4072474 -start*/
        l_custom_sql_ret_status := FND_API.G_RET_STS_SUCCESS;
         /* Modified for Bug 4072474 -End*/

        -- Fix for bug: 4179593 Start
        l_CustSqlWarnFlagSet := FALSE;
        l_CustSqlErrFlagSet := FALSE;
        l_CustSqlWarnMsg := NULL;
        l_CustSqlErrMsg := NULL;
        -- Fix for bug: 4179593 End

        -- Loop for each selected fields, find the columns and write into the XML_content
        FOR i IN 1 .. l_selected_fields.COUNT LOOP
          IF (l_debug = 1) THEN
            l_column_name_list  := l_column_name_list || ',' || l_selected_fields(i).column_name;
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
              trace('Custom Labels Trace [INVLAP2B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
              trace('Custom Labels Trace [INVLAP2B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
              trace('Custom Labels Trace [INVLAP2B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
              trace('Custom Labels Trace [INVLAP2B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
              trace('Custom Labels Trace [INVLAP2B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
             END IF;
             l_sql_stmt := l_selected_fields(i).sql_stmt;
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP2B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
             END IF;
             l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP2B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
             END IF;
             BEGIN
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP2B.pls]: At Breadcrumb 1');
              trace('Custom Labels Trace [INVLAP2B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
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
               trace('Custom Labels Trace [INVLAP2B.pls]: At Breadcrumb 2');
               trace('Custom Labels Trace [INVLAP2B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
               trace('Custom Labels Trace [INVLAP2B.pls]: WARNING: NULL value returned by the custom SQL Query.');
               trace('Custom Labels Trace [INVLAP2B.pls]: l_custom_sql_ret_status is set to : ' || l_custom_sql_ret_status);
             END IF;
          ELSIF c_sql_stmt%rowcount=0 THEN
                IF (l_debug = 1) THEN
                 trace('Custom Labels Trace [INVLAP2B.pls]: At Breadcrumb 3');
                 trace('Custom Labels Trace [INVLAP2B.pls]: WARNING: No row returned by the Custom SQL query');
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
                 trace('Custom Labels Trace [INVLAP2B.pls]: At Breadcrumb 4');
             trace('Custom Labels Trace [INVLAP2B.pls]: ERROR: Multiple values returned by the Custom SQL query');
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
                 trace('Custom Labels Trace [INVLAP2B.pls]: At Breadcrumb 5');
             trace('Custom Labels Trace [INVLAP2B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
              fnd_msg_pub.ADD;
              fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
           IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP2B.pls]: At Breadcrumb 6');
              trace('Custom Labels Trace [INVLAP2B.pls]: Before assigning it to l_serial_data');
           END IF;
            l_serial_data  :=   l_serial_data
                               || variable_b
                               || l_selected_fields(i).variable_name
                               || '">'
                               || l_sql_stmt_result
                               || variable_e;
            l_sql_stmt_result := NULL;
            l_sql_stmt        := NULL;
            IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP2B.pls]: At Breadcrumb 7');
              trace('Custom Labels Trace [INVLAP2B.pls]: After assigning it to l_serial_data');
              trace('Custom Labels Trace [INVLAP2B.pls]: --------------------------REPORT END-------------------------------------');
            END IF;
------------------------End of this changes for Custom Labels project code--------------------
           ELSIF LOWER(l_selected_fields(i).column_name) = 'current_date' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || inv_label.g_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'current_time' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || inv_label.g_time || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'request_user' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || inv_label.g_user || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'client_item' THEN			-- Added for LSP Project, bug 9087971
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.client_item || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_description' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_description || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'revision' THEN
            l_serial_data  :=
                             l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.revision || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_number' THEN
            l_serial_data  :=
                           l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_number || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_expiration_date' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_expiration_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'cost_group' THEN
            l_serial_data  :=
                           l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.cost_group || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'customer_purchase_order' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_purchase_order || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_attribute_category' THEN
            l_serial_data  :=
               l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_attribute_category || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute1' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute1 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute2' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute2 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute3' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute3 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute4' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute4 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute5' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute5 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute6' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute6 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute7' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute7 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute8' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute8 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute9' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute9 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute10' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute10 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute11' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute11 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute12' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute12 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute13' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute13 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute14' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute14 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute15' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute15 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute16' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute16 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute17' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute17 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute18' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute18 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute19' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute19 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute20' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_c_attribute20 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute1' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_d_attribute1 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute2' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_d_attribute2 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute3' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_d_attribute3 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute4' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_d_attribute4 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute5' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_d_attribute5 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute6' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_d_attribute6 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute7' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_d_attribute7 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute8' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_d_attribute8 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute9' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_d_attribute9 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute10' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_d_attribute10 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute1' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_n_attribute1 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute2' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_n_attribute2 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute3' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_n_attribute3 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute4' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_n_attribute4 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute5' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_n_attribute5 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute6' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_n_attribute6 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute7' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_n_attribute7 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute8' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_n_attribute8 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute9' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_n_attribute9 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute10' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_n_attribute10 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_country_of_origin' THEN
            l_serial_data  :=
                l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_country_of_origin || variable_e;

          --- Start Bug 4355080
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_status' THEN
            l_serial_data  :=
                           l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_lot_status || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_grade_code' THEN
            l_serial_data  :=
                       l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_grade_code || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_origination_date' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_origination_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_retest_date' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_retest_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_maturity_date' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_maturity_date || variable_e;
          --- End Bug 4355080

          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_date_code' THEN
            l_serial_data  :=
                        l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_date_code || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_change_date' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_change_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_age' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_age || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_item_size' THEN
            l_serial_data  :=
                        l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_item_size || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_color' THEN
            l_serial_data  :=
                            l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_color || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_volume' THEN
            l_serial_data  :=
                           l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_volume || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_volume_uom' THEN
            l_serial_data  :=
                       l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_volume_uom || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_place_of_origin' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_place_of_origin || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_best_by_date' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_best_by_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_length' THEN
            l_serial_data  :=
                           l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_length || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_length_uom' THEN
            l_serial_data  :=
                       l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_length_uom || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_recycled_cont' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_recycled_cont || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_thickness' THEN
            l_serial_data  :=
                        l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_thickness || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_thickness_uom' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_thickness_uom || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_width' THEN
            l_serial_data  :=
                            l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_width || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_width_uom' THEN
            l_serial_data  :=
                        l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_width_uom || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_curl' THEN
            l_serial_data  :=
                             l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_curl || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_vendor' THEN
            l_serial_data  :=
                           l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.lot_vendor || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_hazard_class' THEN
            l_serial_data  :=
                    l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_hazard_class || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute_category' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute_category || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute1' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute1 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute2' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute2 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute3' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute3 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute4' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute4 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute5' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute5 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute6' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute6 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute7' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute7 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute8' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute8 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute9' THEN
            l_serial_data  :=
                      l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute9 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute10' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute10 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute11' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute11 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute12' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute12 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute13' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute13 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute14' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute14 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute15' THEN
            l_serial_data  :=
                     l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.item_attribute15 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_number' THEN
            l_serial_data  :=
                        l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_number || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_number_status' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_number_status || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_attribute_category' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_attribute_category
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute1' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute1 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute2' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute2 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute3' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute3 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute4' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute4 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute5' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute5 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute6' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute6 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute7' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute7 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute8' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute8 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute9' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute9 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute10' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute10 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute11' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute11 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute12' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute12 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute13' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute13 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute14' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute14 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute15' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute15 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute16' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute16 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute17' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute17 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute18' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute18 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute19' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute19 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_c_attribute20' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_c_attribute20 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_d_attribute1' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_d_attribute1 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_d_attribute2' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_d_attribute2 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_d_attribute3' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_d_attribute3 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_d_attribute4' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_d_attribute4 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_d_attribute5' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_d_attribute5 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_d_attribute6' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_d_attribute6 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_d_attribute7' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_d_attribute7 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_d_attribute8' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_d_attribute8 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_d_attribute9' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_d_attribute9 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_d_attribute10' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_d_attribute10 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_n_attribute1' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_n_attribute1 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_n_attribute2' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_n_attribute2 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_n_attribute3' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_n_attribute3 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_n_attribute4' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_n_attribute4 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_n_attribute5' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_n_attribute5 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_n_attribute6' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_n_attribute6 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_n_attribute7' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_n_attribute7 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_n_attribute8' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_n_attribute8 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_n_attribute9' THEN
            l_serial_data  :=
                  l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_n_attribute9 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_n_attribute10' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_n_attribute10 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_country_of_origin' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_country_of_origin
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_time_since_new' THEN
            l_serial_data  :=
                l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_time_since_new || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_cycles_since_new' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_cycles_since_new || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_time_since_over' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_time_since_overhaul
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_cycles_since_over' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_cycles_since_overhaul
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_time_since_repair' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_time_since_repair
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_cycles_since_repair' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_cycles_since_repair
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_time_since_visit' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_time_since_visit || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_cycles_since_visit' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_cycles_since_visit
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_time_since_mark' THEN
            l_serial_data  :=
               l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_time_since_mark || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_cycles_since_mark' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_cycles_since_mark
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_num_of_repairs' THEN
            l_serial_data  :=
                l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_num_of_repairs || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_initialization_date' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_initialization_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_completion_date' THEN
            l_serial_data  :=
               l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_completion_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_fixed_asset_tag' THEN
            l_serial_data  :=
               l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_fixed_asset_tag || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'serial_vendor_serial' THEN
            l_serial_data  :=
                 l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.serial_vendor_serial || variable_e;
          --START of Fix For Bug: 4907062
          -- Project_Number and Task Number fields are added newly.
          ELSIF LOWER(l_selected_fields(i).column_name) = 'project_number' THEN
            l_serial_data  :=
                l_serial_data || variable_b
                                || l_selected_fields(i).variable_name
                                || '">'
                                || serial_rec.project_number
                                || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'task_number' THEN
            l_serial_data  :=    l_serial_data
                                || variable_b
                                || l_selected_fields(i).variable_name
                                || '">'
                                || serial_rec.task_number
                                || variable_e;
          --END of Fix For Bug: 4907062
          ELSIF LOWER(l_selected_fields(i).column_name) = 'project' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.project || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'task' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.task || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'organization' THEN
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.ORGANIZATION || variable_e;

          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_name' THEN
            -- Added for Bug 4642062.
            -- Using the value of l_wip_entity_name if job_name from serial_rec is null
            l_serial_data  :=
              l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || nvl(serial_rec.job_name, l_wip_entity_name) || variable_e;

          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_type' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_entity_type || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_qty' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_net_quantity || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_scheduled_start_date' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_scheduled_start_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_scheduled_completion_date' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_scheduled_completion_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'bom_revision' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_bom_revision || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'routing_revision' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_routing_revision || variable_e;

          -- Added as part of change for patchset "I".
          ELSIF LOWER(l_selected_fields(i).column_name) = 'receipt_num' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_receipt_number || variable_e;
          -- Added for UCC 128 J Bug #3067059
          ELSIF LOWER(l_selected_fields(i).column_name) = 'gtin' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_gtin || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'gtin_description' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_gtin_desc || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_code' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_subinventory || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'locator' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || serial_rec.LOCATOR || variable_e;
         -- Fix for bug# 3739661: UOM not displayed in Serial Labels
            ELSIF LOWER(l_selected_fields(i).column_name) = 'uom' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_uom || variable_e;
         -- End of fix for 3739661

    -- invconv changes start
            ELSIF LOWER(l_selected_fields(i).column_name) = 'parent_lot_number' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_parent_lot_number || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'hold_date' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_hold_date || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'expiration_action_date' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_expiration_action_date || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'expiration_action_code' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_expiration_action_code || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'supplier_lot_number' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_supplier_lot_number || variable_e;

            ELSIF LOWER(l_selected_fields(i).column_name) = 'origination_type' THEN
            l_serial_data  := l_serial_data || variable_b || l_selected_fields(i).variable_name || '">' || l_origination_type || variable_e;
   -- invconv changes END

	    -- Added for R12 RFID Compliance project
	    -- New field : EPC
	    -- EPC is generated once for each LPN
          ELSIF LOWER(l_selected_fields(i).column_name) = 'epc' THEN
	       l_serial_data  := l_serial_data
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

        l_serial_data                                       := l_serial_data || label_e;
        x_variable_content(l_label_index).label_content     := l_serial_data;
        x_variable_content(l_label_index).label_request_id  := l_label_request_id;
	x_variable_content(l_label_index).label_status      := l_label_status;
------------------------Start of changes for Custom Labels project code------------------

        -- Fix for bug: 4179593 Start
        IF (l_CustSqlWarnFlagSet) THEN
         l_custom_sql_ret_status := INV_LABEL.G_WARNING;
         l_custom_sql_ret_msg := l_CustSqlWarnMsg;
        END IF;

        IF (l_CustSqlErrFlagSet) THEN
         l_custom_sql_ret_status := FND_API.G_RET_STS_ERROR;
         l_custom_sql_ret_msg := l_CustSqlErrMsg;
	 x_variable_content(l_label_index).label_status      := l_custom_sql_ret_status;
        END IF;
        -- Fix for bug: 4179593 End

        x_variable_content(l_label_index).error_message     := l_custom_sql_ret_msg|| ' ' || l_label_err_msg;
------------------------End of this changes for Custom Labels project code---------------
        l_label_index                                       := l_label_index + 1;

        IF (l_debug = 1) THEN
          TRACE(l_column_name_list);
          TRACE('Finished writing one label');
        END IF;

        l_serial_data       := '';
        l_label_request_id  := NULL;
------------------------Start of changes for Custom Labels project code------------------
        l_custom_sql_ret_status        := NULL;
        l_custom_sql_ret_msg           := NULL;
------------------------End of this changes for Custom Labels project code---------------
        l_serial_loop_count := l_serial_loop_count + 1;
      END LOOP;


      l_serial_data       := '';
      l_label_request_id  := NULL;
      ------------------------Start of changes for Custom Labels project code------------------
      l_custom_sql_ret_status        := NULL;
      l_custom_sql_ret_msg           := NULL;
      ------------------------End of this changes for Custom Labels project code---------------

      <<nextlabel>>

      IF (l_debug = 1) THEN
	 TRACE(' Done with Label format in the current label-set');
      END IF;


      END LOOP; --for formats in label-set






      IF (p_label_type_info.business_flow_code IN(1, 2, 3, 4)
          AND(l_patch_level = 1)) THEN
        FETCH rt_serial_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_project_id
            , l_task_id
            , l_revision
            , l_serial_number
            , l_purchase_order
            , l_subinventory
            , l_locator_id
            , l_vendor_id
            , l_vendor_site_id
            , l_uom
            , l_oe_order_header_id --Bug 4582954
            , l_oe_order_line_id;  --Bug 4582954

        IF rt_serial_cur%NOTFOUND THEN
          l_serial_number  := NULL;

          CLOSE rt_serial_cur;
        ELSE
          IF (l_debug = 1) THEN
            TRACE(' Found another serial number fetching once again RT_SERIAL_CUR => ' || l_serial_number);
          END IF;
        END IF;
      ELSIF((l_patch_level = 0)
            AND(p_label_type_info.business_flow_code IN(1, 2)
                AND(l_is_wms_org = TRUE))) THEN
        -- Receipt(1), Inspection(2) or Putaway Drop(4) and org is WMS enabled
         -- In an INV org there are no serial numbers at these points in the transaction.
        l_receipt_number  := inv_rcv_common_apis.g_rcv_global_var.receipt_num;

        FETCH rti_serial_lpn_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_project_id
            , l_task_id
            , l_revision
            , l_serial_number
            , l_purchase_order
            , l_subinventory
            , l_vendor_id
            , l_vendor_site_id
            , l_oe_order_header_id --Bug 4582954
            , l_oe_order_line_id;  --Bug 4582954

        IF rti_serial_lpn_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' (1)No Serial number found for this given Interface Transaction ID:' || p_transaction_id);
          END IF;

          CLOSE rti_serial_lpn_cur;

          RETURN;
        END IF;
      ELSIF(
            (l_patch_level = 0)
            AND(
                (p_label_type_info.business_flow_code IN(3)
                 AND(l_is_wms_org = TRUE))
                OR(p_label_type_info.business_flow_code IN(4)
                   AND(l_is_wms_org = FALSE))
               )
           ) THEN
        IF (l_debug = 1) THEN
          TRACE(
               ' getting next serial number for business flow 3, l_serial_table_index= '
            || l_serial_table_index
            || ', table count= '
            || l_serial_numbers_table.COUNT
          );
        END IF;

        IF (l_serial_table_index < l_serial_numbers_table.COUNT) THEN
          l_serial_table_index  := l_serial_table_index + 1;
          l_serial_number       := l_serial_numbers_table(l_serial_table_index);
        ELSE
          -- finished this serial number table, get a new record
          -- from rti_serial_msnt_cur and get a new serial number table
          FETCH rti_serial_msnt_cur
           INTO l_inventory_item_id
              , l_organization_id
              , l_lot_number
              , l_project_id
              , l_task_id
              , l_revision
              , l_fm_serial_number
              , l_to_serial_number
              , l_purchase_order
              , l_subinventory
              , l_vendor_id
              , l_vendor_site_id
              , l_oe_order_header_id --Bug 4582954
              , l_oe_order_line_id;  --Bug 4582954

          IF rti_serial_msnt_cur%NOTFOUND THEN
            CLOSE rti_serial_msnt_cur;

            l_serial_number  := NULL;
          ELSE
            -- getting range serial numbers
            inv_label.get_number_between_range(
              fm_x_number                  => l_fm_serial_number
            , to_x_number                  => l_to_serial_number
            , x_return_status              => l_return_status
            , x_number_table               => l_serial_numbers_table
            );

            IF l_return_status <> 'S' THEN
              fnd_message.set_name('WMS', 'WMS_GET_SER_CUR_FAILED');   -- Code message for this.
              fnd_msg_pub.ADD;
              RETURN;
            END IF;

            IF (l_debug = 1) THEN
              TRACE(' Count of rows in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
            END IF;

            l_serial_number       := l_serial_numbers_table(1);
            l_serial_table_index  := 1;
          END IF;

          IF (l_debug = 1) THEN
            TRACE(' Got the next serial number = ' || l_serial_number);
          END IF;
        END IF;
      ELSIF p_label_type_info.business_flow_code IN(21) THEN
         -- Start of New Code Added as part of Bug# 4290536
        IF (l_serial_table_index < l_serial_numbers_table.COUNT) THEN
            l_serial_table_index  := l_serial_table_index + 1;
            l_serial_number       := l_serial_numbers_table(l_serial_table_index);
        ELSE
        -- End of New Code Added as part of Bug# 4290536
          -- finished this serial number table, get a new record
          FETCH wda_serial_cur
           INTO l_inventory_item_id
              , l_organization_id
              , l_lot_number
              , l_project_id
              , l_task_id
              , l_revision
              , l_serial_number
              , l_fm_serial_number
              , l_to_serial_number
              , l_subinventory
              , l_uom;

          IF wda_serial_cur%NOTFOUND THEN
            l_serial_number    := NULL;
            l_fm_serial_number := NULL;
            l_to_serial_number := NULL;
            CLOSE wda_serial_cur;
          --
          -- Start of New Code Added as part of Bug# 4290536
          --
          ELSIF l_fm_serial_number IS NOT NULL THEN
            IF (l_debug = 1) THEN
              TRACE(' Found Serial Number for the given ID: ' || p_transaction_id||'; l_serial_number: '||l_serial_number||'; l_fm_serial_number: '||l_fm_serial_number||'; l_to_serial_number: '||l_to_serial_number);
            END IF;
            -- getting range serial numbers
            inv_label.get_number_between_range(
              fm_x_number     => l_fm_serial_number
            , to_x_number     => l_to_serial_number
            , x_return_status => l_return_status
            , x_number_table  => l_serial_numbers_table);

            IF l_return_status <> 'S' THEN
              FND_MESSAGE.SET_NAME('WMS', 'WMS_GET_SER_CUR_FAILED');
              FND_MSG_PUB.ADD;
              RETURN;
            END IF;
            IF (l_debug = 1) THEN
              TRACE(' Number of SN in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
            END IF;
            l_serial_number       := l_serial_numbers_table(1);
            l_serial_table_index  := 1;
          END IF;
        END IF;
        --
        -- End of New Code Added as part of Bug# 4290536
        --
      ELSIF p_label_type_info.business_flow_code IN(13, 23, 27) THEN
        --Misc receipt and Issue, Put away pregeneration
        -- Flow labels, MMTT based
        IF (l_serial_table_index < l_serial_numbers_table.COUNT) THEN
          l_serial_table_index  := l_serial_table_index + 1;
          l_serial_number       := l_serial_numbers_table(l_serial_table_index);
        ELSE
          -- finished this serial number table, get a new record
          -- from rti_serial_msnt_cur and get a new serial number table
          FETCH mmtt_serial_cur
           INTO l_inventory_item_id
              , l_organization_id
              , l_lot_number
              , l_project_id
              , l_task_id
              , l_revision
              , l_fm_serial_number
              , l_to_serial_number
              , l_subinventory
              , l_uom
              , l_locator_id;  /* Added for Bug # 4672471 */


          IF mmtt_serial_cur%NOTFOUND THEN
            IF (l_debug = 1) THEN
              TRACE(' No Serial number found for this given Transaction Temp ID:' || p_transaction_id);
            END IF;

            CLOSE mmtt_serial_cur;

            l_serial_number  := NULL;
          ELSE
            -- getting range serial numbers
            IF (l_debug = 1) THEN
              TRACE(' Before call to  GET_NUMBER_BETWEEN_RANGE ');
            END IF;

            inv_label.get_number_between_range(
              fm_x_number                  => l_fm_serial_number
            , to_x_number                  => l_to_serial_number
            , x_return_status              => l_return_status
            , x_number_table               => l_serial_numbers_table
            );

            IF l_return_status <> 'S' THEN
              fnd_message.set_name('WMS', 'WMS_GET_SER_CUR_FAILED');   -- Code message for this.
              fnd_msg_pub.ADD;
              RETURN;
            END IF;

            IF (l_debug = 1) THEN
              TRACE(' Count of rows in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
            END IF;

            l_serial_number       := l_serial_numbers_table(1);
            l_serial_table_index  := 1;
          END IF;

          IF (l_debug = 1) THEN
            TRACE(' Got the next serial number = ' || l_serial_number);
          END IF;
        END IF;
      ELSIF (p_label_type_info.business_flow_code IN(33) AND p_transaction_identifier = 1) THEN

        IF (l_debug = 1) THEN
          trace(' WIP - LPN work orderless completion business flow.');
        END IF;

        FETCH wip_lpn_serial_cur
         INTO l_inventory_item_id
            , l_organization_id
            , l_lot_number
            , l_project_id
            , l_task_id
            , l_revision
            , l_serial_number
            , l_subinventory
            , l_uom
            , l_locator_id;

        IF wip_lpn_serial_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            trace('No more serial number returned from wip_lpn_serial_cur cursor');
          END IF;
          CLOSE wip_lpn_serial_cur;
          RETURN;
        ELSE
          IF (l_debug = 1) THEN
            trace('Got the next serial number : ' || l_serial_number);
          END IF;
        END IF;

      ELSIF p_label_type_info.business_flow_code IN(26, 37) THEN   --WIP Completion,Manufacturing Cross-Dock(37)
        -- Bug 2825748 : Material Label Is Not Printed On WIP Completion.
          -- Bug 3896738: Added Manufacturing Cross-Dock flow
        IF (l_serial_table_index < l_serial_numbers_table.COUNT) THEN
          l_serial_table_index  := l_serial_table_index + 1;
          l_serial_number       := l_serial_numbers_table(l_serial_table_index);
        ELSE
          FETCH wip_serial_cur
           INTO l_inventory_item_id
              , l_organization_id
              , l_lot_number
              , l_cost_group_id
              , l_project_id
              , l_task_id
              , l_uom
              , l_revision
              , l_fm_serial_number
              , l_to_serial_number
              , l_subinventory
              , l_locator_id
              , l_wip_entity_name  --Added for Bug 4642062
              , l_wip_entity_id;

          TRACE(
               ' wip_serial_cur '
            || ', Item ID='
            || l_inventory_item_id
            || ', Organization ID='
            || l_organization_id
            || ', Lot Number='
            || l_lot_number
            || ', Project ID='
            || l_project_id
            || ', Cost Group ID='
            || l_cost_group_id
            || ', Task ID='
            || l_task_id
            || ', Transaction UOM='
            || l_uom
            || ', Item Revision='
            || l_revision
            || ', Subinventory Code='
            || l_subinventory
            || ', Locator ID='
            || l_locator_id
            || ', Job Name='
            || l_wip_entity_name
            || ', Job Id='
            || l_wip_entity_id
          );

          IF wip_serial_cur%NOTFOUND THEN
            TRACE(' No more records found for transaction_temp_id in MMTT/MTLT');
            l_serial_number  := NULL;

            CLOSE wip_serial_cur;
          ELSE
            --Bug #6417575,
            --  Fetching WIP Job attributes, based on wip_entity_id passed through
            --  transaction_source_id.
            --  Currently, printing WIP job information for serial is restricted
            --  only for WIP Completion and Serial Label Manual Printing.
            IF (l_debug = 1) THEN
              trace( 'l_wip_entity_id = ' || l_wip_entity_id);
            END IF;
            IF (l_wip_entity_id IS NOT NULL) THEN
              OPEN wip_attributes_cur;
              FETCH wip_attributes_cur INTO l_wip_entity_name
                                    , l_entity_type
                                    , l_net_quantity
                                    , l_scheduled_start_date
                                    , l_scheduled_completion_date
                                    , l_bom_revision
                                    , l_routing_revision;

              IF wip_attributes_cur%NOTFOUND THEN
                IF (l_debug = 1) THEN
                  trace( ' No records returned by wip_attributes_cur cursor');
                END IF;
              END IF;
              CLOSE wip_attributes_cur;
            END IF;

            inv_label.get_number_between_range(
              fm_x_number                  => l_fm_serial_number
            , to_x_number                  => l_to_serial_number
            , x_return_status              => l_return_status
            , x_number_table               => l_serial_numbers_table
            );

            IF l_return_status <> 'S' THEN
              fnd_message.set_name('WMS', 'WMS_GET_SER_CUR_FAILED');
              fnd_msg_pub.ADD;
              RETURN;
            END IF;

            TRACE(' Count of rows in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
            l_serial_number  := l_serial_numbers_table(1);
            TRACE('l_serial_number after call to GET_SERIALS_BETWEEN_RANGE ' || l_serial_number);
          END IF;
        END IF;
      -- Flow Labels
      ELSIF p_label_type_info.business_flow_code IN(33)
            AND p_transaction_identifier > 1 THEN
        -- Flow Completion, not MMTT based
        IF p_transaction_identifier = 2 THEN
          IF (l_serial_table_index < l_serial_numbers_table.COUNT) THEN
            l_serial_table_index  := l_serial_table_index + 1;
            l_serial_number       := l_serial_numbers_table(l_serial_table_index);
          ELSE
            FETCH flow_serial_curs_mti
             INTO l_inventory_item_id
                , l_organization_id
                , l_lot_number
                , l_project_id
                , l_task_id
                , l_revision
                , l_fm_serial_number
                , l_to_serial_number
                , l_subinventory
                , l_locator_id    -- Added for Bug #5533362
                , l_uom;

            IF flow_serial_curs_mti%NOTFOUND THEN
              IF (l_debug = 1) THEN
                TRACE(' No Flow Data found for this given ID:' || p_transaction_id);
              END IF;

              l_serial_number  := NULL;

              CLOSE flow_serial_curs_mti;
            -- RETURN;
            ELSE
              inv_label.get_number_between_range(
                fm_x_number                  => l_fm_serial_number
              , to_x_number                  => l_to_serial_number
              , x_return_status              => l_return_status
              , x_number_table               => l_serial_numbers_table
              );

              IF l_return_status <> 'S' THEN
                fnd_message.set_name('WMS', 'WMS_GET_SER_CUR_FAILED');   -- Code message for this.
                fnd_msg_pub.ADD;
                RETURN;
              END IF;

              IF (l_debug = 1) THEN
                TRACE(' Count of rows in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
              END IF;

              l_serial_number  := l_serial_numbers_table(1);
            END IF;
          END IF;
        ELSIF p_transaction_identifier = 3 THEN
          IF (l_serial_table_index < l_serial_numbers_table.COUNT) THEN
            l_serial_table_index  := l_serial_table_index + 1;
            l_serial_number       := l_serial_numbers_table(l_serial_table_index);
          ELSE
            FETCH flow_serial_curs_mol
             INTO l_inventory_item_id
                , l_organization_id
                , l_lot_number
                , l_project_id
                , l_task_id
                , l_revision
                , l_fm_serial_number
                , l_to_serial_number
                , l_subinventory
                , l_uom;

            IF flow_serial_curs_mol%NOTFOUND THEN
              IF (l_debug = 1) THEN
                TRACE(' No Flow Data found for this given ID:' || p_transaction_id);
              END IF;

              l_serial_number  := NULL;

              CLOSE flow_serial_curs_mol;
            --RETURN;
            ELSE
              inv_label.get_number_between_range(
                fm_x_number                  => l_fm_serial_number
              , to_x_number                  => l_to_serial_number
              , x_return_status              => l_return_status
              , x_number_table               => l_serial_numbers_table
              );

              IF l_return_status <> 'S' THEN
                fnd_message.set_name('WMS', 'WMS_GET_SER_CUR_FAILED');
                fnd_msg_pub.ADD;
                RETURN;
              END IF;

              IF (l_debug = 1) THEN
                TRACE(' Count of rows in l_serial_numbers_table ' || l_serial_numbers_table.COUNT);
              END IF;

              l_serial_number  := l_serial_numbers_table(1);
            END IF;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            TRACE(' Invalid transaction_identifier passed' || p_transaction_identifier);
          END IF;

          RETURN;
        END IF;
     -- Bug 3836623
     -- Fetch more serial numbers
     ELSIF p_label_type_info.business_flow_code IN(6) THEN
         FETCH wdd_serial_cur
          INTO l_inventory_item_id
             , l_organization_id
             , l_lot_number
             , l_project_id
             , l_task_id
             , l_revision
             , l_serial_number
             , l_subinventory
             , l_uom;

         IF wdd_serial_cur%NOTFOUND THEN
           IF (l_debug = 1) THEN
             TRACE(' No more Serial number found for cross dock');
           END IF;
             l_serial_number := null;
           CLOSE wdd_serial_cur;
           RETURN;
         ELSE
           IF (l_debug = 1) THEN
             TRACE(' Found a new Serial number found for cross dock: '||l_serial_number);
           END IF;
         END IF;
      ELSE
        l_serial_number  := NULL;
      END IF;
    END LOOP;

    IF (rti_serial_lpn_cur%ISOPEN) THEN
      CLOSE rti_serial_lpn_cur;
    END IF;

    IF (rti_serial_msnt_cur%ISOPEN) THEN
      CLOSE rti_serial_msnt_cur;
    END IF;

    IF (mmtt_serial_cur%ISOPEN) THEN
      CLOSE mmtt_serial_cur;
    END IF;

    IF (wdd_serial_cur%ISOPEN) THEN
      CLOSE wdd_serial_cur;
    END IF;

    IF (wip_lpn_serial_cur%ISOPEN) THEN
       CLOSE wip_lpn_serial_cur;
    END IF;

    IF (wda_serial_cur%ISOPEN) THEN
      CLOSE wda_serial_cur;
    END IF;

    IF (wip_serial_cur%ISOPEN) THEN
      CLOSE wip_serial_cur;
    END IF;

    IF (flow_serial_curs_mti%ISOPEN) THEN
      CLOSE flow_serial_curs_mti;
    END IF;

    IF (flow_serial_curs_mol%ISOPEN) THEN
      CLOSE flow_serial_curs_mol;
    END IF;

    --added along with Bugfix 4290536
    IF (mtlt_lot_info_cur%ISOPEN) THEN
      CLOSE mtlt_lot_info_cur;
    END IF;

    --added along with Bugfix 4290536
    IF (get_lot_info%ISOPEN) THEN
      CLOSE get_lot_info;
    END IF;

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
      x_variable_content  := x_variable_content || l_variable_data_tbl(i).label_content;
    END LOOP;
  END get_variable_data;
END inv_label_pvt2;

/
