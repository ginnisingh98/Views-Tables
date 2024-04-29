--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT1" AS
  /* $Header: INVLAP1B.pls 120.31.12010000.13 2010/04/07 09:30:24 jianxzhu ship $ */

  label_b    CONSTANT VARCHAR2(50)  := '<label';
  label_e    CONSTANT VARCHAR2(50)  := '</label>' || fnd_global.local_chr(10);
  variable_b CONSTANT VARCHAR2(50)  := '<variable name= "';
  variable_e CONSTANT VARCHAR2(50)  := '</variable>' || fnd_global.local_chr(
                                                          10
                                                        );
  tag_e      CONSTANT VARCHAR2(50)  := '>' || fnd_global.local_chr(10);
  l_debug             NUMBER;
  -- Bug 2795525 : This mask is used to mask all date fields.
  g_date_format_mask  VARCHAR2(100) := inv_label.g_date_format_mask;
  g_header_printed    BOOLEAN                   := FALSE;
  g_user_name         fnd_user.user_name%TYPE   := fnd_global.user_name;

  PROCEDURE trace(p_message IN VARCHAR2) IS
  BEGIN
    IF (g_header_printed = FALSE) THEN
      inv_label.trace('$Header: INVLAP1B.pls 120.31.12010000.13 2010/04/07 09:30:24 jianxzhu ship $', 'LABEL_MATRL');
      g_header_printed  := TRUE;
    END IF;

    inv_label.trace(g_user_name || ': ' || p_message, 'LABEL_MATRL');
  END trace;

  FUNCTION get_uom_code(
    p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_unit_of_measure   IN VARCHAR2
  )
    RETURN VARCHAR2 IS
    l_uom_code VARCHAR2(3) := '';
  BEGIN
    SELECT uom_code
      INTO l_uom_code
      FROM mtl_item_uoms_view
     WHERE organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id
       AND unit_of_measure = p_unit_of_measure;

    IF SQL%NOTFOUND THEN
      l_uom_code  := '';
    END IF;

    RETURN l_uom_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '';
    WHEN OTHERS THEN
      RETURN '';
  END get_uom_code;

  -- Added for OPM changes, bug 4373856
  FUNCTION get_uom2_code(
    p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  )
    RETURN VARCHAR2 IS
    l_uom_code VARCHAR2(3) := '';
  BEGIN
    SELECT SECONDARY_UOM_CODE
      INTO l_uom_code
      FROM mtl_system_items
     WHERE organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id;

    IF SQL%NOTFOUND THEN
      l_uom_code  := '';
    END IF;

    RETURN l_uom_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '';
    WHEN OTHERS THEN
      RETURN '';
  END get_uom2_code;


  FUNCTION get_origination_type (
    p_origination_type   IN NUMBER
  )
    RETURN VARCHAR2 IS
    l_origination_type  	mfg_lookups.meaning%TYPE := '';
  BEGIN

     SELECT meaning
     into   l_origination_type
     FROM   mfg_lookups
     WHERE  lookup_type = 'MTL_LOT_ORIGINATION_TYPE'
     AND    lookup_code = p_origination_type;

    IF SQL%NOTFOUND THEN
      l_origination_type  := '';
    END IF;

    RETURN l_origination_type;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '';
    WHEN OTHERS THEN
      RETURN '';
  END get_origination_type;


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
    -- Fix for 4888701: Included the Precsion and Scale for the variable quatity.
    --l_quantity               NUMBER                                       := 0;
    l_quantity               NUMBER(38,5)                                   := 0;
    -- End of fix for 4888701

    l_uom                    mtl_material_transactions.transaction_uom%TYPE;
    l_revision               mtl_material_transactions.revision%TYPE;
    l_inventory_item_id      NUMBER;
    l_item_description       VARCHAR2(240)                                  := NULL;
    l_organization_code      VARCHAR2(30); -- Bug 7423016, Added to hold org code in case of expense items.
    l_organization_id        NUMBER;
    l_lot_number             VARCHAR2(240);
    l_from_subinventory      VARCHAR2(30)                                   := NULL;
    l_to_subinventory        VARCHAR2(30)                                   := NULL;
    l_subinventory_code      VARCHAR2(30);
    l_from_locator_id        NUMBER;
    l_to_locator_id          NUMBER;
    l_locator_id             NUMBER;
    l_cost_group_id          NUMBER;
    l_xfr_cost_group_id      NUMBER;  /*  Added for the Bug # 4686024  */
    l_cost_group             VARCHAR2(240);
    l_project_id             NUMBER;
    l_task_id                NUMBER;
    l_project_number         VARCHAR (25); -- Fix For Bug: 4907062
    l_task_number            VARCHAR (25); -- Fix For Bug: 4907062
    l_project_name           VARCHAR2(240);
    l_task_name              VARCHAR2(240);
    l_err_msg                VARCHAR2(240);
    item_fetch_cntr          NUMBER                                         := NULL;
    --Bug 8230113
    l_po_line_id             NUMBER;
    --8533306
    l_po_distribution_id     NUMBER;
    --Bug 8632067
    l_rcv_transaction_id     NUMBER;
    -- Added for Bug 2308273
    l_attribute_category     VARCHAR2(150);
    l_c_attribute1           VARCHAR2(150);
    l_c_attribute2           VARCHAR2(150);
    l_c_attribute3           VARCHAR2(150);
    l_c_attribute4           VARCHAR2(150);
    l_c_attribute5           VARCHAR2(150);
    l_c_attribute6           VARCHAR2(150);
    l_c_attribute7           VARCHAR2(150);
    l_c_attribute8           VARCHAR2(150);
    l_c_attribute9           VARCHAR2(150);
    l_c_attribute10          VARCHAR2(150);
    l_c_attribute11          VARCHAR2(150);
    l_c_attribute12          VARCHAR2(150);
    l_c_attribute13          VARCHAR2(150);
    l_c_attribute14          VARCHAR2(150);
    l_c_attribute15          VARCHAR2(150);
    l_c_attribute16          VARCHAR2(150);
    l_c_attribute17          VARCHAR2(150);
    l_c_attribute18          VARCHAR2(150);
    l_c_attribute19          VARCHAR2(150);
    l_c_attribute20          VARCHAR2(150);
    l_d_attribute1           DATE;
    l_d_attribute2           DATE;
    l_d_attribute3           DATE;
    l_d_attribute4           DATE;
    l_d_attribute5           DATE;
    l_d_attribute6           DATE;
    l_d_attribute7           DATE;
    l_d_attribute8           DATE;
    l_d_attribute9           DATE;
    l_d_attribute10          DATE;
    l_n_attribute1           NUMBER                                         := NULL;
    l_n_attribute2           NUMBER                                         := NULL;
    l_n_attribute3           NUMBER                                         := NULL;
    l_n_attribute4           NUMBER                                         := NULL;
    l_n_attribute5           NUMBER                                         := NULL;
    l_n_attribute6           NUMBER                                         := NULL;
    l_n_attribute7           NUMBER                                         := NULL;
    l_n_attribute8           NUMBER                                         := NULL;
    l_n_attribute9           NUMBER                                         := NULL;
    l_n_attribute10          NUMBER                                         := NULL;
    l_territory_code         VARCHAR2(30);
    l_grade_code             VARCHAR2(150);
    l_origination_date       DATE;
    l_date_code              VARCHAR2(150);
    l_change_date            DATE;
    l_age                    NUMBER                                         := NULL;
    l_retest_date            DATE;
    l_maturity_date          DATE;
    l_item_size              NUMBER                                         := NULL;
    l_color                  VARCHAR2(150);
    l_volume                 NUMBER                                         := NULL;
    l_volume_uom             VARCHAR2(3);
    l_place_of_origin        VARCHAR2(150);
    l_best_by_date           DATE;
    l_length                 NUMBER                                         := NULL;
    l_length_uom             VARCHAR2(3);
    l_recycled_content       NUMBER                                         := NULL;
    l_thickness              NUMBER                                         := NULL;
    l_thickness_uom          VARCHAR2(3);
    l_width                  NUMBER                                         := NULL;
    l_width_uom              VARCHAR2(3);
    l_curl_wrinkle_fold      VARCHAR2(150);
    l_vendor_name            VARCHAR2(240);
    -- Added l_transaction_identifier, for flow
    -- Depending on when it is called, the driving table might be different
    -- 1 means MMTT is the driving table
    -- 2 means MTI is the driving table
    -- 3 means Mtl_txn_request_lines is the driving table

    l_transaction_identifier NUMBER                                         := 0;
    l_receipt_number         VARCHAR2(30);
    -- Added for Bug 2748297
    l_vendor_id              NUMBER;
    l_vendor_site_id         NUMBER;
    -- Added for UCC 128 J Bug #3067059
    l_gtin_enabled           BOOLEAN                                        := FALSE;
    l_gtin                   VARCHAR2(100);
    l_gtin_desc              VARCHAR2(240);
    l_quantity_floor         NUMBER                                         := 0;
    -- changing l_shipment_num type from NUMBER to VARCHAR2 for bug 4306134
    --l_shipment_num NUMBER;
    l_shipment_num VARCHAR2(30);

    /* Patchset J - Label Printing support for OSP
     * Added the following local variables to support addition of new variables
     * job / schedule, job description, OSP operation sequence, OSP department,
     * and OSP resource in the Material Label. The cursors rt_material_cur,
     * rti_material_lpn_cur, rti_material_inspec_cur, rti_material_mtlt_cur
     * are changed.
     */

   l_wip_entity_id NUMBER;
   l_wip_op_seq_num rcv_transactions.WIP_OPERATION_SEQ_NUM%type;
   l_osp_dept_code VARCHAR2(10);
   l_bom_resource_id NUMBER;
   l_bom_resource_code VARCHAR2(20);
   l_wip_entity_name wip_osp_jobs_val_v.wip_entity_name%TYPE;
   l_wip_description wip_osp_jobs_val_v.description%TYPE;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--   Following variables were added (as a part of 11i10+ 'Custom Labels' Project)            |
--   to retrieve and hold the SQL Statement and it's result.                                 |
---------------------------------------------------------------------------------------------
   l_sql_stmt  VARCHAR2(4000);
   l_sql_stmt_result VARCHAR2(4000);
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


    --Start: Enabling EPC generation for R12 Project
    l_epc VARCHAR2(300);
    l_epc_ret_status VARCHAR2(10);
    l_epc_ret_msg VARCHAR2(1000);
    l_label_status VARCHAR2(1);
    l_label_err_msg VARCHAR2(1000);
    l_is_epc_exist VARCHAR2(1) := 'N';
    l_label_formats_in_set NUMBER;
    --End: Enabling EPC generation for R12 Project


    ------------------------End of this change for Custom Labels project code--------------------

    -- invconv fabdi start

    l_parent_lot_number      VARCHAR2(80);
    l_expiration_action_date DATE;
    l_expiration_action_code VARCHAR2(32);
    l_origination_type       NUMBER;
    l_hold_date              DATE;
    l_secondary_uom_code     VARCHAR2(3);
    l_secondary_transaction_qty     NUMBER;
    l_supplier_lot_number    VARCHAR2(150);
    -- invconv fabdi start


    -- For Receipt, Inspection, Putaway, Delivery,
    --  the Item/Lot information is obtained like this

    -- 1. For WMS Org,       Item       Lot           Qty
    --                     --------    ------       -------
    --  Receipt/Inspection   rti       rti+lpnCont  rti or lpnContent
    --  Putaway              rti       rti+mtlt     rti or mtlt
    --  Delivery      no apply for WMS org
    -- 2. For INV Org,       Item       Lot           Qty
    --                     --------    ------       -------
    --  Receipt/Inspection   rti        no lot       rti.quantity
    --  Putaway       no apply for Inv org
    --  Delivery             rti        rti+mtlt     rti or mtlt
    -- Therefore, two cursors are needed, rti+lpnContent or rti+mtlt

    -- MOAC: Replaced the po_line_locations
    -- view with a _ALL table the where clause of
    -- the cursor select is sufficient to stripe
    -- by a single OU.

    -- RTI + LPN Content
    -- Added vendor_id and vendor_site_id to the cursor for Bug 2748297
    CURSOR rti_material_lpn_cur IS
      SELECT rti.item_id inventory_item_id
           , rti.to_organization_id organization_id
           , wlc.lot_number lot_number
           , rti.cost_group_id cost_group_id
           , pol.project_id project_id
           , pol.task_id task_id
           --  Added by joabraha bug 3472150
           , rsh.receipt_num
           --
           , NVL(wlc.quantity, rti.quantity) quantity
           , -- Bug 2743097, For OSP or onetime expense item, they will not be packed into LPN
             -- even in WMS org. So the UOM code need to be retrieved from RTI
             NVL(
               wlc.uom_code
             , get_uom_code(
                 rti.to_organization_id
               , rti.item_id
               , rti.unit_of_measure
               )
             ) uom
           , rti.item_revision revision
           , rti.lpn_id
           , pha.segment1
           , pol.line_num po_line_number
           , pll.quantity quantity_ordered
           , rti.vendor_item_num supplier_part_number
           , pov.vendor_id vendor_id
           , pov.vendor_name supplier_name
           , pvs.vendor_site_id vendor_site_id
           , pvs.vendor_site_code supplier_site
           , ppf.full_name requestor
           , hrl1.location_code deliver_to_location
           , hrl2.location_code location
           , pll.note_to_receiver note_to_receiver
           , rrh.routing_name routing_name
           , rti.item_description item_description
           , rti.subinventory
           , rti.locator_id
           , WOJV.WIP_ENTITY_NAME
           , WOJV.DESCRIPTION
           , RTI.WIP_OPERATION_SEQ_NUM
           , rti.DEPARTMENT_CODE
           , rti.BOM_RESOURCE_ID
        FROM rcv_transactions_interface rti
           , wms_lpn_contents wlc
           , po_lines_trx_v pol -- CLM project, bug 9403291
           , po_headers_trx_v pha -- CLM project, bug 9403291
           , rcv_shipment_headers rsh
           , po_line_locations_trx_v pll -- CLM project, bug 9403291
           , po_vendors pov
           , hr_locations_all hrl1
           , hr_locations_all hrl2
           , po_vendor_sites_all pvs
           , per_people_f ppf
           , rcv_routing_headers rrh
           , wip_osp_jobs_val_v wojv
       WHERE wlc.parent_lpn_id(+) = rti.lpn_id
         AND wlc.inventory_item_id(+) = rti.item_id -- bug 2372669
         AND pol.po_line_id(+) = rti.po_line_id
         AND pha.po_header_id(+) = rti.po_header_id
         AND rsh.shipment_header_id(+) = rti.shipment_header_id
         AND pll.line_location_id(+) = rti.po_line_location_id
         AND pov.vendor_id(+) = rti.vendor_id
         -- AND pvs.vendor_id(+) = rti.vendor_id This line is uneccessary dherring 8/2/05
         AND pvs.vendor_site_id(+) = rti.vendor_site_id
         AND ppf.person_id(+) = rti.deliver_to_person_id
         AND hrl1.location_id(+) = rti.deliver_to_location_id
         AND hrl2.location_id(+) = rti.location_id
         AND rrh.routing_header_id(+) = rti.routing_header_id
         AND wlc.source_header_id(+) = rti.GROUP_ID --- Added for Bug 2699098.
         AND rti.interface_transaction_id = p_transaction_id
         AND wojv.wip_entity_id = rti.wip_entity_id
         AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date(+) AND ppf.effective_end_date(+);  -- for bug#5889715

    -- MOAC: Replaced the po_line_locations
    -- view with a _ALL table the where clause of
    -- the cursor select is sufficient to stripe
    -- by a single OU.

    -- Inspection Cursor for Bug 2377796
    -- Added vendor_id and vendor_site_id to the cursor for Bug 2748297
    CURSOR rti_material_lpn_inspec_cur IS
      SELECT rti.item_id inventory_item_id
           , rti.to_organization_id organization_id
           , wlc.lot_number lot_number
           , rti.cost_group_id cost_group_id
           , pol.project_id project_id
           , pol.task_id task_id
           --  Added by joabraha bug 3472150
           , rsh.receipt_num
           --
           , NVL(wlc.quantity, rti.quantity) quantity
           , -- Bug 2743097, For OSP or onetime expense item, they will not be packed into LPN
             -- even in WMS org. So the UOM code need to be retrieved from RTI
             NVL(
               wlc.uom_code
             , get_uom_code(
                 rti.to_organization_id
               , rti.item_id
               , rti.unit_of_measure
               )
             ) uom
           , rti.item_revision revision
           , rti.lpn_id
           , pha.segment1
           , pol.line_num po_line_number
           , pll.quantity quantity_ordered
           , rti.vendor_item_num supplier_part_number
           , pov.vendor_id vendor_id
           , pov.vendor_name supplier_name
           , pvs.vendor_site_id vendor_site_id
           , pvs.vendor_site_code supplier_site
           , ppf.full_name requestor
           , hrl1.location_code deliver_to_location
           , hrl2.location_code location
           , pll.note_to_receiver note_to_receiver
           , rrh.routing_name routing_name
           , rti.item_description item_description
           , rti.subinventory
           , rti.locator_id
           , WOJV.WIP_ENTITY_NAME
           , WOJV.DESCRIPTION
           , RTI.WIP_OPERATION_SEQ_NUM
           , rti.DEPARTMENT_CODE
           , rti.BOM_RESOURCE_ID
        FROM rcv_transactions_interface rti
           , wms_lpn_contents wlc
           , po_lines_trx_v pol -- CLM project, bug 9403291
           , po_headers_trx_v pha -- CLM projet, bug 9403291
           , rcv_shipment_headers rsh
           , po_line_locations_trx_v pll -- CLM project, bug 9403291
           , po_vendors pov
           , hr_locations_all hrl1
           , hr_locations_all hrl2
           , po_vendor_sites_all pvs
           , per_people_f ppf
           , rcv_routing_headers rrh
           , wip_osp_jobs_val_v wojv
       WHERE wlc.parent_lpn_id(+) = rti.transfer_lpn_id
         AND wlc.inventory_item_id(+) = rti.item_id -- bug 2372669
         AND pol.po_line_id(+) = rti.po_line_id
         AND pha.po_header_id(+) = rti.po_header_id
         AND rsh.shipment_header_id(+) = rti.shipment_header_id
         AND pll.line_location_id(+) = rti.po_line_location_id
         AND pov.vendor_id(+) = rti.vendor_id
         -- AND pvs.vendor_id(+) = rti.vendor_id This line is uneccessary dherring 8/2/05
         AND pvs.vendor_site_id(+) = rti.vendor_site_id
         AND ppf.person_id(+) = rti.deliver_to_person_id
         AND hrl1.location_id(+) = rti.deliver_to_location_id
         AND hrl2.location_id(+) = rti.location_id
         AND rrh.routing_header_id(+) = rti.routing_header_id
         AND wlc.source_header_id(+) = rti.GROUP_ID --- Added for Bug 2699098.
         AND rti.interface_transaction_id = p_transaction_id
         AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date(+) AND ppf.effective_end_date(+);  -- for bug#5889715

    -- RTI + MTLT
    -- This is the new cursor designed for the "I" cleanup project for printing at receipt
    -- Added vendor_id and vendor_site_id to the cursor for Bug 2748297

    -- MOAC: Replaced the po_line_locations
    -- view with a _ALL table the where clause of
    -- the cursor select is sufficient to stripe
    -- by a single OU.

    CURSOR rti_material_mtlt_cur IS
      SELECT   rti.item_id
             , rti.item_revision
             , mtlt.lot_number
             , rti2.organization_id
             , rti2.cost_group_id
             , rti2.project_id
             , rti2.task_id
             , SUM(NVL(mtlt.transaction_quantity, rti.quantity)) quantity
             , rti2.uom
             , rti2.segment1
             , rti2.po_line_number
             , rti2.quantity_ordered
             , rti2.supplier_part_number
             , rti2.vendor_id
             , rti2.supplier_name
             , rti2.vendor_site_id
             , rti2.supplier_site
             , rti2.requestor
             , rti2.deliver_to_location
             , rti2.location
             , rti2.note_to_receiver
             , rti2.routing_name
             , rti2.item_description
             , rti2.subinventory
             , rti2.locator_id
             , WOJV.WIP_ENTITY_NAME
             , WOJV.DESCRIPTION
             , RTI.WIP_OPERATION_SEQ_NUM
             , rti.DEPARTMENT_CODE
             , rti.BOM_RESOURCE_ID
          FROM rcv_transactions_interface rti
             , wip_osp_jobs_val_v wojv
             , mtl_transaction_lots_temp mtlt
             , /***************************************/
               (SELECT rti.GROUP_ID
                     , rti.interface_transaction_id
                     , rti.to_organization_id organization_id
                     , rti.cost_group_id cost_group_id
                     , pol.project_id project_id
                     , pol.task_id task_id
                     , inv_label_pvt1.get_uom_code(
                         rti.to_organization_id
                       , rti.item_id
                       , rti.unit_of_measure
                       ) uom
                     , pha.segment1 segment1
                     , pol.line_num po_line_number
                     , pll.quantity quantity_ordered
                     , rti.vendor_item_num supplier_part_number
                     , pov.vendor_id vendor_id
                     , pov.vendor_name supplier_name
                     , pvs.vendor_site_id vendor_site_id
                     , pvs.vendor_site_code supplier_site
                     , hre.full_name requestor
                     , hrl1.location_code deliver_to_location
                     , hrl2.location_code location
                     , pll.note_to_receiver note_to_receiver
                     , rrh.routing_name routing_name
                     , rti.item_description item_description
                     , rti.subinventory subinventory
                     , rti.locator_id locator_id
                  FROM rcv_transactions_interface rti
                     , po_lines_trx_v pol -- CLM project, bug 9403291
                     , po_headers_trx_v pha -- CLM project, bug 9403291
                     , rcv_shipment_headers rsh
                     , po_line_locations_trx_v pll -- CLM project, bug 9403291
                     , po_vendors pov
                     , hr_locations hrl1
                     , hr_locations hrl2
                     -- MOAC changed po_vendor_sites to po_vendor_sites_all
                     , po_vendor_sites_all pvs
                     , hr_employees hre
                     , rcv_routing_headers rrh
                     , wip_osp_jobs_val_v wojv
                 WHERE rti.GROUP_ID IN (SELECT GROUP_ID
                                          FROM rcv_transactions_interface
                                         WHERE interface_transaction_id =
                                                               p_transaction_id)
                   AND pol.po_line_id(+) = rti.po_line_id
                   AND pha.po_header_id(+) = rti.po_header_id
                   AND rsh.shipment_header_id(+) = rti.shipment_header_id
                   AND pll.line_location_id(+) = rti.po_line_location_id
                   AND pov.vendor_id(+) = rti.vendor_id
                   -- corrected following line to be pvs.vendor_site_id and not pvs.vendor_id dherring
                   AND pvs.vendor_site_id(+) = rti.vendor_site_id
                   -- AND pvs.vendor_id(+) = rti.vendor_id Uneccessary line dherring 8/2/05
                   AND hre.employee_id(+) = rti.deliver_to_person_id
                   AND hrl1.location_id(+) = rti.deliver_to_location_id
                   AND rrh.routing_header_id(+) = rti.routing_header_id
                   AND hrl2.location_id(+) = rti.location_id) rti2
         /***************************************/
         WHERE inv_label_pvt1.check_rti_id(
                 rti2.interface_transaction_id
               , mtlt.lot_number
               , rti.item_revision
               ) = 'N'
           AND mtlt.transaction_temp_id(+) = rti.interface_transaction_id
           AND rti.interface_transaction_id = rti2.interface_transaction_id
           AND rti.GROUP_ID = rti2.GROUP_ID
           AND rti.wip_entity_id = wojv.wip_entity_id
      GROUP BY rti.item_id
             , rti.item_revision
             , mtlt.lot_number
             , rti2.organization_id
             , rti2.cost_group_id
             , rti2.project_id
             , rti2.task_id
             , rti2.uom
             , rti2.segment1
             , rti2.po_line_number
             , rti2.quantity_ordered
             , rti2.supplier_part_number
             /* Bug# 3329195  - Added rti2.vendor_id and rti2.vendor_site_id to the group by clause */
             , rti2.vendor_id
             , rti2.supplier_name
             , rti2.vendor_site_id
             , rti2.supplier_site
             , rti2.requestor
             , rti2.deliver_to_location
             , rti2.location
             , rti2.note_to_receiver
             , rti2.routing_name
             , rti2.item_description
             , rti2.subinventory
             , rti2.locator_id
             , WOJV.WIP_ENTITY_NAME
             , WOJV.DESCRIPTION
             , RTI.WIP_OPERATION_SEQ_NUM
             , rti.DEPARTMENT_CODE
             , rti.BOM_RESOURCE_ID;

    /* 3069426 - Patchset J project - Label printing enhancements -
     * Use one cursor that queries RCV_TRANSACTIONS_INTERFACE and RCV_LOTS_INTERFACE tables for
     * Item, Lot, Quantity information
     */

    -- MOAC: Replaced the po_line_locations
    -- view with a _ALL table the where clause of
    -- the cursor select is sufficient to stripe
    -- by a single OU.

    /* Modified for Bug# 4516067
     * Reverted the Modifications done for the Bug#4186856.
     * The modifications done for the Bug#4186856 was causing performance issues.
     */

    CURSOR rt_material_cur IS
      SELECT   rsl.item_id inventory_item_id
             , rt.organization_id organization_id
             , rls.lot_num lot_number -- Reverted to original code as part of Bug#4516067
             -- , rsl.cost_group_id cost_group_id /* Modified for the Bug # 4770558 */
             , mmt.cost_group_id cost_group_id
             --Bug# 3586116 - Get project and task id from rt
             , rt.project_id
             , rt.task_id
             --  , pod.project_id project_id     --Commented as part of Bug# 3586116
             --  , pod.task_id task_id          --Commented as part of Bug# 3586116
             --  Added by joabraha bug 3472150
             , rsh.receipt_num
             , SUM(NVL(rls.quantity, rt.quantity)) quantity -- Reverted to original code as part of Bug#4516067
             -- Commented as part of the Bug#4516067 and added the code to fetch secondary_quantity from rls instead of mtln
             -- , SUM(NVL(mtln.SECONDARY_TRANSACTION_QUANTITY, rt.SECONDARY_QUANTITY)) secondary_quantity -- fabdi 4373856
             , SUM(NVL(rls.SECONDARY_QUANTITY, rt.SECONDARY_QUANTITY)) secondary_quantity -- fabdi 4373856
             , (inv_label_pvt1.get_uom_code(
                  rt.organization_id
                , rsl.item_id
                , rsl.unit_of_measure
                )
               ) uom
             , (inv_label_pvt1.get_uom2_code(
                  rt.organization_id
                , rsl.item_id
                )
               ) secondary_uom  -- bug 4373856
             , rsl.item_revision revision
             , pha.segment1
             , rsh.shipment_num
             , pol.line_num po_line_number
             --Bug 8230113
             , pol.po_line_id po_line_id
             , pll.quantity quantity_ordered
             , rsl.vendor_item_num supplier_part_number
             , pov.vendor_id vendor_id
             , pov.vendor_name supplier_name
             , pvs.vendor_site_id vendor_site_id
             , pvs.vendor_site_code supplier_site
             , ppf.full_name requestor
             , hrl1.location_code deliver_to_location
             , hrl2.location_code location
             , pll.note_to_receiver note_to_receiver
             , rrh.routing_name routing_name
             --Bug 6504959-Reverted fix made which was fetching item desc from msiv.
             , rsl.item_description item_description
             , rt.subinventory
             , rt.locator_id
             -- Bug 4516067, to improve performance, query the base table directly
             --, WOJV.WIP_ENTITY_NAME     wip_entity_name
             --, WOJV.DESCRIPTION         wip_description
             , we.wip_entity_name        wip_entity_name  -- Added for Bug#4516067
             , wdj.description           wip_description  -- Added for Bug#4516067
             , RT.WIP_OPERATION_SEQ_NUM  wip_op_seq_num
             , rt.DEPARTMENT_CODE       wip_department_code
             , rt.BOM_RESOURCE_ID    wip_bom_resource_id
             , wlpn.lpn_context
             , wlpn.lpn_id
             , rt.routing_header_id routing_header_id --bug 4916450
              --8533306
             , rt.po_distribution_id
              --Bug 8632067
             , rt.transaction_id
          FROM rcv_transactions rt
             , rcv_lots_supply rls -- Reverted to original code as part of Bug#4516067
             -- , rcv_lot_transactions rls -- Replaced rcv_lot_transactions by mtl_transaction_lot_numbers to fetch the LOT details as part of Bug# 4186856
             -- Added rt2 as part of Bug# 4186856
             -- rt2, mtln commented for Bug#4516067 to revert the changes done for Bug#4186856
             /* , (select transaction_id
              *  from rcv_transactions rt_deliver
              *  where rt_deliver.group_id = p_transaction_id
              *    and rt_deliver.transaction_type = 'DELIVER') rt2
              * , mtl_transaction_lot_numbers mtln  -- Added as part of Bug# 4186856
              */
             , rcv_shipment_lines rsl
             , po_lines_trx_v pol -- CLM project, bug 9403291
             -- , po_distributions_all pod           --Commented as part of Bug# 3586116
             , po_headers_trx_v pha -- CLM project, bug 9403291
             , rcv_shipment_headers rsh
             , po_line_locations_trx_v pll -- CLM project, bug 9403291
             , po_vendors pov
             , hr_locations_all hrl1
             , hr_locations_all hrl2
             , po_vendor_sites_all pvs
             , per_people_f ppf
             , rcv_routing_headers rrh
             -- Bug 4516067, to improve performance, query the base table directly
             --, wip_osp_jobs_val_v wojv
             , wip_entities we           -- Added for Bug#4516067
             , wip_discrete_jobs wdj     -- Added for Bug#4516067
             , wms_license_plate_numbers wlpn -- Bug 3836623
             , (SELECT cost_group_id, rcv_transaction_id
                  FROM mtl_material_transactions mmt1
                 WHERE mmt1.rcv_transaction_id = p_transaction_id
                   AND nvl(mmt1.logical_transaction, -999) <> 1) mmt -- Modified for bug# 5515979
             --, mtl_material_transactions mmt -- Added for the Bug # 4770558
         WHERE rls.transaction_id(+) = rt.transaction_id             -- Reverted to original code as part of Bug#4516067
               --mtln.product_transaction_id(+) = rt.transaction_id  -- Commented as part of Bug#4186856
               /* Reverted to original code as part of Bug#4516067
                * mtln.product_code = 'RCV'                           -- Added as part of Bug#4186856
                * AND mtln.product_transaction_id = rt2.transaction_id      -- Added as part of Bug#4186856
                * AND mtln.inventory_item_id = pol.item_id                  -- Added as part of Bug#4186856
                */
           AND pol.po_line_id(+) = rt.po_line_id
           AND pha.po_header_id(+) = rt.po_header_id
           AND rsh.shipment_header_id(+) = rt.shipment_header_id
           AND pll.line_location_id(+) = rt.po_line_location_id
           --  AND pod.po_distribution_id(+) = rt.po_distribution_id        --Commented as part of Bug# 3586116
           AND pov.vendor_id(+) = rt.vendor_id
           -- AND pvs.vendor_id(+) = rt.vendor_id Uneccessary line dherring 8/2/05
           AND pvs.vendor_site_id(+) = rt.vendor_site_id
           AND ppf.person_id(+) = rt.deliver_to_person_id
           AND hrl1.location_id(+) = rt.deliver_to_location_id
           AND hrl2.location_id(+) = rt.location_id
           AND rrh.routing_header_id(+) = rt.routing_header_id
           AND rsl.shipment_line_id = rt.shipment_line_id
           AND rt.GROUP_ID = p_transaction_id
           -- Bug 4516067, to improve performance, query the base table directly
           --AND rt.wip_entity_id = wojv.wip_entity_id (+)
           AND rt.wip_entity_id = we.wip_entity_id (+)
           AND rt.wip_entity_id = wdj.wip_entity_id (+)
           AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                  AND p_label_type_info.business_flow_code = 2)  -- label flow code 'Inspect'
                OR (rt.transaction_type = 'RECEIVE'
                    AND p_label_type_info.business_flow_code = 1  -- label flow code 'Receive'
                    -- Commented following condition for bug 4142656
                    -- Reverted back the changes done for Bug#4142656 as part of Bug#4516067
                    AND rt.routing_header_id <> 3
                   )
               )
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
            AND rt.transaction_id = mmt.rcv_transaction_id(+)  /* Added for the Bug # 4770558 */
            AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date(+) AND ppf.effective_end_date(+)  -- for bug#5889715
    -- The outer join has been added in the above condition for solving the bug # 4863161
      GROUP BY rsl.item_id
             , rt.organization_id
             , rls.lot_num  -- Modified as part of Bug# 4516067
             --, rsl.cost_group_id /* Modified for the Bug # 4770558 */
             , mmt.cost_group_id
             , rt.project_id
             , rt.task_id
             -- , pod.project_id  --Commented as part of Bug# 3586116
             -- , pod.task_id      --Commented as part of Bug# 3586116
             --  Added by joabraha bug 3472150
             , rsh.receipt_num
             --
             , inv_label_pvt1.get_uom_code(
                 rt.organization_id
               , rsl.item_id
               , rsl.unit_of_measure
               )
             , (inv_label_pvt1.get_uom2_code(
                  rt.organization_id
                , rsl.item_id
                ) -- bug 4373856
               )
             , (inv_label_pvt1.get_uom2_code(
                  rt.organization_id
                , rsl.item_id
                )
               ) -- bug 4373856
             , rsl.item_revision
             , pha.segment1
             , rsh.shipment_num
             , pol.line_num
             --Bug 8230113
             , pol.po_line_id
             , pll.quantity
             , rsl.vendor_item_num
             , pov.vendor_id
             , pov.vendor_name
             , pvs.vendor_site_id
             , pvs.vendor_site_code
             , ppf.full_name
             , hrl1.location_code
             , hrl2.location_code
             , pll.note_to_receiver
             , rrh.routing_name
             --Bug 6504959-Reverted fix made which was fetching item desc from msiv.
             , rsl.item_description
             , rt.subinventory
             , rt.locator_id
             -- Bug 4516067, to improve performance, query the base table directly
             --, WOJV.WIP_ENTITY_NAME
             --, WOJV.DESCRIPTION
             , we.wip_entity_name
             , wdj.description
             , RT.WIP_OPERATION_SEQ_NUM
             , rt.DEPARTMENT_CODE
             , rt.BOM_RESOURCE_ID
             , wlpn.lpn_context
             , wlpn.lpn_id
             , rt.routing_header_id --bug 4916450
             --8533306
             , rt.po_distribution_id
               --Bug 8632067
             , rt.transaction_id
      UNION ALL -- Removed the cursor Added as part of 4186856 to segregate the Lot Controlled items and non Lot Controlled items.
      -- Added a new cursor to pick the records for label during Direct Routing for Bug# 4516067
      SELECT   rsl.item_id inventory_item_id
             , rt.organization_id organization_id
             , mtln.lot_number lot_number
             -- , rsl.cost_group_id cost_group_id /* Modified for the Bug # 4770558 */
             , mmt.cost_group_id cost_group_id
             --Bug# 3586116 - Get project and task id from rt
             , rt.project_id
             , rt.task_id
             -- , pod.project_id project_id
             --, pod.task_id task_id
             --  Added by joabraha bug 3472150
             , rsh.receipt_num
             --
             , SUM(NVL(mtln.transaction_quantity, rt.quantity)) quantity
             , SUM(NVL(mtln.SECONDARY_TRANSACTION_QUANTITY, rt.SECONDARY_QUANTITY)) secondary_quantity -- fabdi 4373856
             , (inv_label_pvt1.get_uom_code(
                  rt.organization_id
                , rsl.item_id
                , rsl.unit_of_measure
                )
               ) uom
             , (inv_label_pvt1.get_uom2_code(
                  rt.organization_id
                , rsl.item_id
                )
               ) secondary_uom  -- bug 4373856
             , rsl.item_revision revision
             , pha.segment1
             , rsh.shipment_num
             , pol.line_num po_line_number
             --Bug 8230113
             , pol.po_line_id po_line_id
             , pll.quantity quantity_ordered
             , rsl.vendor_item_num supplier_part_number
             , pov.vendor_id vendor_id
             , pov.vendor_name supplier_name
             , pvs.vendor_site_id vendor_site_id
             , pvs.vendor_site_code supplier_site
             , ppf.full_name requestor
             , hrl1.location_code deliver_to_location
             , hrl2.location_code location
             , pll.note_to_receiver note_to_receiver
             , rrh.routing_name routing_name
             --Bug 6504959-Reverted fix made which was fetching item desc from msiv.
             , rsl.item_description item_description
             , rt.subinventory
             , rt.locator_id
             -- Bug 4516067, to improve performance, query the base table directly
             --, WOJV.WIP_ENTITY_NAME     wip_entity_name
             --, WOJV.DESCRIPTION         wip_description
             , we.wip_entity_name        wip_entity_name
             , wdj.description           wip_description
             , RT.WIP_OPERATION_SEQ_NUM
             , rt.DEPARTMENT_CODE
             , rt.BOM_RESOURCE_ID
             , wlpn.lpn_context
             , wlpn.lpn_id
             , rt.routing_header_id routing_header_id --bug 4916450
             --8533306
             , rt.po_distribution_id
              --Bug 8632067
             ,rt.transaction_id
          FROM rcv_transactions rt
             , mtl_transaction_lot_numbers mtln
             , rcv_shipment_lines rsl
             , po_lines_trx_v pol -- CLM project, bug 9403291
             -- , po_distributions_all pod --Commented as part of Bug# 3586116
             , po_headers_trx_v pha -- CLM project, bug 9403291
             , rcv_shipment_headers rsh
             , po_line_locations_trx_v pll -- CLM project, bug 9403291
             , po_vendors pov
             , hr_locations_all hrl1
             , hr_locations_all hrl2
             , po_vendor_sites_all pvs
             , per_people_f ppf
             , rcv_routing_headers rrh
             -- Bug 4516067, to improve performance, query the base table directly
             --, wip_osp_jobs_val_v wojv
             , wip_entities we
             , wip_discrete_jobs wdj
             , wms_license_plate_numbers wlpn -- Bug 3836623
             , (SELECT cost_group_id, rcv_transaction_id
                  FROM mtl_material_transactions mmt1
                 WHERE mmt1.rcv_transaction_id = p_transaction_id
                   AND nvl(mmt1.logical_transaction, -999) <> 1) mmt   -- Modified for bug# 5515979
                    --, mtl_material_transactions mmt -- Added for the Bug # 4770558
         WHERE mtln.product_transaction_id(+) = rt.transaction_id
           AND mtln.product_code(+) = 'RCV'
           AND pol.po_line_id(+) = rt.po_line_id
           AND pha.po_header_id(+) = rt.po_header_id
           AND rsh.shipment_header_id(+) = rt.shipment_header_id
           AND pll.line_location_id(+) = rt.po_line_location_id
           -- AND pod.po_distribution_id(+) = rt.po_distribution_id --Commented as part of Bug# 3586116
           AND pov.vendor_id(+) = rt.vendor_id
           -- AND pvs.vendor_id(+) = rt.vendor_id
           AND pvs.vendor_site_id(+) = rt.vendor_site_id
           AND ppf.person_id(+) = rt.deliver_to_person_id
           AND hrl1.location_id(+) = rt.deliver_to_location_id
           AND hrl2.location_id(+) = rt.location_id
           AND rrh.routing_header_id(+) = rt.routing_header_id
           AND rsl.shipment_line_id = rt.shipment_line_id
           AND rt.GROUP_ID = p_transaction_id
           AND rt.transaction_type = 'DELIVER'
           AND rt.routing_header_id = 3  -- Added as part of Bug# 4516067
           AND p_label_type_info.business_flow_code in (1)  -- Only pick for label flow code of 'deliver' or 'putaway'
           -- Bug 4516067, to improve performance, query the base table directly
           --AND rt.wip_entity_id = wojv.wip_entity_id (+)
           AND rt.wip_entity_id = we.wip_entity_id (+)
           AND rt.wip_entity_id = wdj.wip_entity_id (+)
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
           AND rt.transaction_id = mmt.rcv_transaction_id(+)  /* Added for the Bug # 4770558 */
           AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date(+) AND ppf.effective_end_date(+)  -- for bug#5889715
     -- The outer join has been added in the above condition for solving the bug # 4863161
      GROUP BY rsl.item_id
             , rt.organization_id
             , mtln.lot_number
             --, rsl.cost_group_id /* Modified for the Bug # 4770558 */
             , mmt.cost_group_id
             , rt.project_id
             , rt.task_id
             -- , pod.project_id --Commented as part of Bug# 3586116
             --, pod.task_id    --Commented as part of Bug# 3586116
             --  Added by joabraha bug 3472150
             , rsh.receipt_num
             --
             , (inv_label_pvt1.get_uom_code(
                  rt.organization_id
                , rsl.item_id
                , rsl.unit_of_measure
                )
               )
             , (inv_label_pvt1.get_uom2_code(
                  rt.organization_id
                , rsl.item_id
                )
               ) -- bug 4373856
             , rsl.item_revision
             , pha.segment1
             , rsh.shipment_num
             , pol.line_num
             --Bug 8230113
             , pol.po_line_id
             , pll.quantity
             , rsl.vendor_item_num
             , pov.vendor_id
             , pov.vendor_name
             , pvs.vendor_site_id
             , pvs.vendor_site_code
             , ppf.full_name
             , hrl1.location_code
             , hrl2.location_code
             , pll.note_to_receiver
             , rrh.routing_name
	     --Bug 6504959-Reverted fix made which was fetching item desc from msiv.
             , rsl.item_description
             , rt.subinventory
             , rt.locator_id
             -- Bug 4516067, to improve performance, query the base table directly
             --, WOJV.WIP_ENTITY_NAME
             --, WOJV.DESCRIPTION
             , we.wip_entity_name
             , wdj.description
             , RT.WIP_OPERATION_SEQ_NUM
             , rt.DEPARTMENT_CODE
             , rt.BOM_RESOURCE_ID
             , wlpn.lpn_context
             , wlpn.lpn_id
             , rt.routing_header_id --bug 4916450
             --8533306
             , rt.po_distribution_id
               --8632067
             , rt.Transaction_id;

      -- Bug 4516067, break the following query into new cursor for putaway and deliver
      --  it was part of rt_material_cur
      CURSOR rt_putaway_deliver_cur IS
        SELECT   rsl.item_id inventory_item_id
             , rt.organization_id organization_id
             , mtln.lot_number lot_number
             , rsl.cost_group_id cost_group_id
             --Bug# 3586116 - Get project and task id from rt
             , rt.project_id
             , rt.task_id
             -- , pod.project_id project_id
             --, pod.task_id task_id
             --  Added by joabraha bug 3472150
             , rsh.receipt_num
             --
             , SUM(NVL(mtln.transaction_quantity, rt.quantity)) quantity
             , SUM(NVL(mtln.SECONDARY_TRANSACTION_QUANTITY, rt.SECONDARY_QUANTITY)) secondary_quantity
             , (inv_label_pvt1.get_uom_code(
                  rt.organization_id
                , rsl.item_id
                , rsl.unit_of_measure
                )
               ) uom
             , (inv_label_pvt1.get_uom2_code(
                  rt.organization_id
                , rsl.item_id
                )
               ) secondary_uom  -- bug 4373856
             , rsl.item_revision revision
             , pha.segment1
             , rsh.shipment_num
             , pol.line_num po_line_number
               --Bug 8648128
             , pol.po_line_id po_line_id
             , pll.quantity quantity_ordered
             , rsl.vendor_item_num supplier_part_number
             , pov.vendor_id vendor_id
             , pov.vendor_name supplier_name
             , pvs.vendor_site_id vendor_site_id
             , pvs.vendor_site_code supplier_site
             , ppf.full_name requestor
             , hrl1.location_code deliver_to_location
             , hrl2.location_code location
             , pll.note_to_receiver note_to_receiver
             , rrh.routing_name routing_name
             , rsl.item_description item_description
             , rt.subinventory
             , rt.locator_id
             -- Bug 4516067, to improve performance, query the base table directly
             --, WOJV.WIP_ENTITY_NAME     wip_entity_name
             --, WOJV.DESCRIPTION         wip_description
             , we.wip_entity_name        wip_entity_name
             , wdj.description           wip_description
             , RT.WIP_OPERATION_SEQ_NUM
             , rt.DEPARTMENT_CODE
             , rt.BOM_RESOURCE_ID
             , wlpn.lpn_context
             , wlpn.lpn_id
             , rt.routing_header_id --bug 4916450
             --Bug 8648128
             , rt.po_distribution_id
             --Bug 8632067
             , rt.transaction_id
          FROM rcv_transactions rt
             , mtl_transaction_lot_numbers mtln
             , rcv_shipment_lines rsl
             , po_lines_trx_v pol -- CLM project, bug 9403291
             -- , po_distributions_all pod --Commented as part of Bug# 3586116
             , po_headers_trx_v pha -- CLM project, bug 9403291
             , rcv_shipment_headers rsh
             , po_line_locations_trx_v pll -- CLM project, bug 9403291
             , po_vendors pov
             , hr_locations_all hrl1
             , hr_locations_all hrl2
             , po_vendor_sites_all pvs
             , per_people_f ppf
             , rcv_routing_headers rrh
             -- Bug 4516067, to improve performance, query the base table directly
             --, wip_osp_jobs_val_v wojv
             , wip_entities we
             , wip_discrete_jobs wdj
             , wms_license_plate_numbers wlpn -- Bug 3836623
         WHERE mtln.product_transaction_id(+) = rt.transaction_id
           AND mtln.product_code(+) = 'RCV'
           AND pol.po_line_id(+) = rt.po_line_id
           AND pha.po_header_id(+) = rt.po_header_id
           AND rsh.shipment_header_id(+) = rt.shipment_header_id
           AND pll.line_location_id(+) = rt.po_line_location_id
           -- AND pod.po_distribution_id(+) = rt.po_distribution_id --Commented as part of Bug# 3586116
           AND pov.vendor_id(+) = rt.vendor_id
           -- AND pvs.vendor_id(+) = rt.vendor_id uneccessary line dherring 8/2/05
           AND pvs.vendor_site_id(+) = rt.vendor_site_id
           AND ppf.person_id(+) = rt.deliver_to_person_id
           AND hrl1.location_id(+) = rt.deliver_to_location_id
           AND hrl2.location_id(+) = rt.location_id
           AND rrh.routing_header_id(+) = rt.routing_header_id
           AND rsl.shipment_line_id = rt.shipment_line_id
           AND rt.GROUP_ID = p_transaction_id
           AND rt.transaction_type = 'DELIVER'
           -- Bug 4516067, because created this new cursor for putaway and deliver
           -- no need to restrict business flow code here
           -- AND p_label_type_info.business_flow_code in (3,4)  -- Only pick for label flow code of 'deliver' or 'putaway'
           -- Bug 4516067, to improve performance, query the base table directly
           -- AND rt.wip_entity_id = wojv.wip_entity_id (+)
           AND rt.wip_entity_id = we.wip_entity_id (+)
           AND rt.wip_entity_id = wdj.wip_entity_id (+)
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
           AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date(+) AND ppf.effective_end_date(+)  -- for bug#5889715
      GROUP BY rsl.item_id
             , rt.organization_id
             , mtln.lot_number
             , rsl.cost_group_id
             , rt.project_id
             , rt.task_id
             -- , pod.project_id --Commented as part of Bug# 3586116
             --, pod.task_id    --Commented as part of Bug# 3586116
             --  Added by joabraha bug 3472150
             , rsh.receipt_num
             --
             , (inv_label_pvt1.get_uom_code(
                  rt.organization_id
                , rsl.item_id
                , rsl.unit_of_measure
                )
               )
             , (inv_label_pvt1.get_uom2_code(
                  rt.organization_id
                , rsl.item_id
                )
               ) -- bug 4373856
             , rsl.item_revision
             , pha.segment1
             , rsh.shipment_num
             , pol.line_num
             --Bug 8648128
             , pol.po_line_id
             , pll.quantity
             , rsl.vendor_item_num
             , pov.vendor_id
             , pov.vendor_name
             , pvs.vendor_site_id
             , pvs.vendor_site_code
             , ppf.full_name
             , hrl1.location_code
             , hrl2.location_code
             , pll.note_to_receiver
             , rrh.routing_name
             , rsl.item_description
             , rt.subinventory
             , rt.locator_id
             -- Bug 4516067, to improve performance, query the base table directly
             --, WOJV.WIP_ENTITY_NAME
             --, WOJV.DESCRIPTION
             , we.wip_entity_name
             , wdj.description
             , RT.WIP_OPERATION_SEQ_NUM
             , rt.DEPARTMENT_CODE
             , rt.BOM_RESOURCE_ID
             , wlpn.lpn_context
             , wlpn.lpn_id
             , rt.routing_header_id --bug 4916450
             --bug 8648128
             , rt.po_distribution_id
             --Bug 8632067
             , rt.transaction_id;
    /* Bug# 3238878
       Cursor to get the resource_code and departmetn_code */

    CURSOR get_resource_dept_code_cur(p_resource_id NUMBER) IS
       SELECT br.resource_code
             ,bd.department_code
       FROM   bom_resources br
             ,bom_department_resources bdr
             ,bom_departments bd
       WHERE br.resource_id = p_resource_id
         AND bdr.resource_id = p_resource_id
         AND bd.department_id = bdr.department_id
    GROUP BY br.resource_code
            ,bd.department_code;


    -- For transactions based on mmtt
    -- obtain item and lot information from mmtt and mtlt

    -- For transactions based on mmtt
    -- obtain item and lot information from mmtt and mtlt
    -- Fix bug 2308273: Miscellaneous receipt(13) is calling label printing through TM
    -- but when label printing is called, the TM has not processed the LOT information into
    -- the mtl_lot_numbers table from the mtl_transactions_lot_temp. So for misc.receipts into
    -- a new lot, the lot number detailed information is taken from the mtl_transactions_lot_temp
    -- since the mtl_lot_numbers doesn't have the Lot number yet.
    CURSOR mmtt_material_receipt_cur IS
      SELECT mmtt.inventory_item_id
           , mmtt.organization_id
           , mtlt.lot_number
           , mmtt.cost_group_id
           , mmtt.project_id
           , mmtt.task_id
           , ABS(NVL(mtlt.transaction_quantity, mmtt.transaction_quantity)) quantity
           , mmtt.transaction_uom
           , ABS(NVL(mtlt.secondary_quantity, mmtt.secondary_transaction_quantity)) secondary_quantity --  invconv changes
           , mmtt.secondary_uom_code --  invconv changes
           , mmtt.revision
           , -- Added for Bug 2308273
             mtlt.lot_attribute_category
           , mtlt.c_attribute1
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
           , mtlt.territory_code
           , mtlt.grade_code
           , mtlt.origination_date
           , mtlt.date_code
           , mtlt.change_date
           , mtlt.age
           , mtlt.retest_date
           , mtlt.maturity_date
           , mtlt.item_size
           , mtlt.color
           , mtlt.volume
           , mtlt.volume_uom
           , mtlt.place_of_origin
           , mtlt.best_by_date
           , mtlt.LENGTH
           , mtlt.length_uom
           , mtlt.recycled_content
           , mtlt.thickness
           , mtlt.thickness_uom
           , mtlt.width
           , mtlt.width_uom
           , mtlt.curl_wrinkle_fold
           , mtlt.vendor_name
           -- End Bug 2308273
           , mmtt.subinventory_code
           , mmtt.locator_id
           , we.wip_entity_name -- Fix For Bug: 4907062
           , we.description     -- Fix For Bug: 4907062
           , mtlt.parent_lot_number --  added for inconv fabdi start
           , mtlt.expiration_action_date
           , mtlt.origination_type
           , mtlt.hold_date
           , mtlt.expiration_action_code
           , mtlt.supplier_lot_number  -- invconv end
        FROM mtl_material_transactions_temp mmtt
            ,mtl_transaction_lots_temp mtlt
            ,wip_entities we -- Fix For Bug: 4907062
       WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND mmtt.transaction_temp_id = p_transaction_id
         AND we.wip_entity_id(+) = mmtt.transaction_source_id; -- Fix For Bug: 4907062
    /* Outer join has been added to fetch the data while performing the Misc. Alias/Receipt
       business flow */


    -- Bug Fix for bug 2251686
    -- If content lpn_id in MMTT is populated, we have to get the
    -- material info from WMS_LPN_CONTENTS
    -- New Union to this table has been added
    CURSOR mmtt_material_cur IS
      SELECT mmtt.inventory_item_id inventory_item_id
           , mmtt.organization_id organization_id
           , mtlt.lot_number lot_number
           , mmtt.cost_group_id cost_group_id
           , mmtt.transfer_cost_group_id xfr_cost_group_id /* Added for the bug # 4686024 */
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , ABS(NVL(mtlt.transaction_quantity, mmtt.transaction_quantity)) quantity
           , mmtt.transaction_uom uom
           , mmtt.revision revision
           , mmtt.subinventory_code
           , mmtt.transfer_subinventory
           , mmtt.locator_id
           , mmtt.transfer_to_location
           , mmtt.secondary_uom_code --  added for invconv
           , ABS(NVL(mtlt.secondary_quantity, mmtt.secondary_transaction_quantity)) --  added for invconv
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND mmtt.transaction_temp_id = p_transaction_id
         AND mmtt.content_lpn_id IS NULL
      UNION ALL
      SELECT wlc.inventory_item_id inventory_item_id
           , wlc.organization_id organization_id
           , wlc.lot_number lot_number
           , wlc.cost_group_id cost_group_id
           , mmtt.transfer_cost_group_id xfr_cost_group_id /* Added for the bug # 4686024 */
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , wlc.quantity quantity
           , wlc.uom_code uom
           , wlc.revision revision
           , mmtt.subinventory_code
           , mmtt.transfer_subinventory
           , mmtt.locator_id
           , mmtt.transfer_to_location
           , wlc.secondary_uom_code --  added for invconv
           , wlc.secondary_quantity --  added for invconv
        FROM wms_lpn_contents wlc, mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_transaction_id
         AND mmtt.content_lpn_id IS NOT NULL
         AND mmtt.content_lpn_id = wlc.parent_lpn_id;

    -- Bug fix for 2356935
    -- create new cursor for Inventory putaway (30)
    -- If putaway to a LPN-controlled location, the content information is in WLC
    -- If putaway to a non LPN-controlled location, TM will do a unpack and create
    --  multiple MMTT record for each content , with the same transaction_header_id
    --  of the original MMTT line
    -- Therefore, mmtt_material_cur will not work for this situation
    CURSOR inv_putaway_material_cur IS
      SELECT mmtt.inventory_item_id inventory_item_id
           , mmtt.organization_id organization_id
           , mtlt.lot_number lot_number
           , mmtt.cost_group_id cost_group_id
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , ABS(NVL(mtlt.transaction_quantity, mmtt.transaction_quantity)) quantity
           , ABS(NVL(mtlt.SECONDARY_QUANTITY, mmtt.SECONDARY_TRANSACTION_QUANTITY)) secondary_quantity -- fabdi bug 4387144
           , mmtt.transaction_uom uom
           , mmtt.SECONDARY_UOM_CODE secondary_uom -- fabdi bug 4387144
           , mmtt.revision revision
           , mmtt.transfer_subinventory
           , mmtt.transfer_to_location
        FROM mtl_material_transactions_temp mmtt
           , mtl_transaction_lots_temp mtlt
           , mtl_material_transactions_temp mmtt_orgin
       WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND mmtt.transaction_header_id = mmtt_orgin.transaction_header_id
         AND mmtt.transaction_temp_id <> mmtt_orgin.transaction_temp_id
         AND mmtt_orgin.content_lpn_id IS NOT NULL
         AND mmtt_orgin.transaction_temp_id = p_transaction_id
      UNION ALL
      SELECT mmtt.inventory_item_id inventory_item_id
           , mmtt.organization_id organization_id
           , mtlt.lot_number lot_number
           , mmtt.cost_group_id cost_group_id
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , ABS(NVL(mtlt.transaction_quantity, mmtt.transaction_quantity)) quantity
           , ABS(NVL(mtlt.SECONDARY_QUANTITY  , mmtt.SECONDARY_TRANSACTION_QUANTITY)) secondary_quantity -- fabdi bug 4387144
           , mmtt.transaction_uom uom
           , mmtt.SECONDARY_UOM_CODE secondary_uom -- fabdi bug 4387144
           , mmtt.revision revision
           , mmtt.transfer_subinventory
           , mmtt.transfer_to_location
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND mmtt.content_lpn_id IS NULL
         AND mmtt.transaction_temp_id = p_transaction_id;

    -- Bug 2342737 : Print Material Label for Pack/Unpack/Split LPN.
    -- This call to label printing is from the TM and so the LPN is already packed when label printing is called.
    -- The absence of the outer join in the 2nd, 3rd and 4th sql ensures that they return records only for
    -- specific cases.
    CURSOR material_lpn_cur IS
      -- This part of the cursor returns all the items unpacked loose from an LPN.
      SELECT mmtt.inventory_item_id inventory_item_id
           , mmtt.organization_id organization_id
           , mtlt.lot_number lot_number
           , mmtt.cost_group_id cost_group_id
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , ABS(NVL(mtlt.transaction_quantity, mmtt.transaction_quantity)) quantity
           , mmtt.transaction_uom uom
           , mmtt.revision revision
           , mmtt.subinventory_code
           , mmtt.transfer_subinventory
           , mmtt.locator_id
           , mmtt.transfer_to_location
           , ABS(NVL(mtlt.secondary_quantity, mmtt.secondary_transaction_quantity)) secondary_quantity --  invconv changes
           , mmtt.secondary_uom_code --  invconv changes
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND mmtt.transfer_lpn_id IS NULL
         AND mmtt.content_lpn_id IS NULL
         AND mmtt.transaction_temp_id = p_transaction_id
      UNION ALL
      -- This part of the cursor returns the content_lpn_id unpacked from an LPN.
      SELECT wlc.inventory_item_id inventory_item_id
           , wlc.organization_id organization_id
           , wlc.lot_number lot_number
           , wlc.cost_group_id cost_group_id
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , wlc.quantity quantity
           , wlc.uom_code uom
           , wlc.revision revision
           , mmtt.subinventory_code
           , mmtt.transfer_subinventory
           , mmtt.locator_id
           , mmtt.transfer_to_location
           , wlc.secondary_quantity --  added for invconv
           , wlc.secondary_uom_code --  added for invconv
        FROM wms_lpn_contents wlc, mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_transaction_id
         AND mmtt.content_lpn_id = wlc.parent_lpn_id
      UNION ALL
      -- This part of the cursor is for 2 cases. Items unpacked from an LPN and packed into another LPN AND
      -- for loose Items packed into an existing or loose LPN.
      SELECT wlc.inventory_item_id inventory_item_id
           , wlc.organization_id organization_id
           , wlc.lot_number lot_number
           , wlc.cost_group_id cost_group_id
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , wlc.quantity quantity
           , wlc.uom_code uom
           , wlc.revision revision
           , mmtt.subinventory_code
           , mmtt.transfer_subinventory
           , mmtt.locator_id
           , mmtt.transfer_to_location
           , wlc.secondary_quantity --  added for invconv
           , wlc.secondary_uom_code --  added for invconv
        FROM wms_lpn_contents wlc, mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_transaction_id
         AND mmtt.transfer_lpn_id = wlc.parent_lpn_id
      UNION ALL
      -- This part of the cursor is for all cases except loose items being packed into an existing/new LPN.
      SELECT wlc.inventory_item_id inventory_item_id
           , wlc.organization_id organization_id
           , wlc.lot_number lot_number
           , wlc.cost_group_id cost_group_id
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , wlc.quantity quantity
           , wlc.uom_code uom
           , wlc.revision revision
           , mmtt.subinventory_code
           , mmtt.transfer_subinventory
           , mmtt.locator_id
           , mmtt.transfer_to_location
           , wlc.secondary_quantity --  added for invconv
           , wlc.secondary_uom_code --  added for invconv
        FROM wms_lpn_contents wlc, mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_transaction_id
         AND mmtt.lpn_id = wlc.parent_lpn_id;

     -- Packaging/Cartonization Cursors
     /*Bug 3639762 */
    CURSOR c_get_pkg_items_content IS
      SELECT  wlc.organization_id
    , wlc.inventory_item_id
    , wlc.revision
    , wlc.lot_number
    , SUM(wlc.quantity)
    FROM wms_lpn_contents wlc, WMS_LICENSE_PLATE_NUMBERS wlpn
        WHERE wlpn.OUTERMOST_LPN_ID = p_transaction_id
        and  wlc.parent_lpn_id = wlpn.lpn_id
    GROUP BY wlc.organization_id
    , wlc.inventory_item_id
    , wlc.revision
    , wlc.lot_number
    /* Union Clause added to fetch the details from mmtt for pick release transactions for cartonization flow
       as a part of Bug#4305501*/
    UNION
      SELECT  mmtt.organization_id
            , mmtt.inventory_item_id
            , mmtt.revision
            , mtlt.lot_number
            , SUM(mmtt.primary_quantity)  quantity
      FROM mtl_material_transactions_temp mmtt
         , mtl_transaction_lots_temp mtlt
      WHERE mmtt.cartonization_id = p_transaction_id
        AND mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
      GROUP BY mmtt.organization_id
             , mmtt.inventory_item_id
             , mmtt.revision
             , mtlt.lot_number;
      -- End Packaging/Cartonization Cursors


    -- For business_flow_code of Cross Dock, the delivery_detail_id is passed.
    CURSOR wdd_material_cur IS
      SELECT wdd1.inventory_item_id inventory_item_id
           , wdd1.organization_id organization_id
           , wdd1.lot_number lot_number
           , NVL(wlpn.cost_group_id, 0) cost_group_id
           , NVL(wdd1.project_id, 0) project_id
           , NVL(wdd1.task_id, 0) task_id
           , wdd1.requested_quantity quantity
           , wdd1.requested_quantity_uom uom
           , wdd1.revision revision
           , wdd1.subinventory
           , wdd1.locator_id
        FROM wsh_delivery_details wdd1
           , wsh_delivery_details wdd2
           , wsh_delivery_assignments_v wda
           , wms_license_plate_numbers wlpn
       WHERE wdd1.delivery_detail_id = wda.delivery_detail_id
         AND wdd2.delivery_detail_id = wda.parent_delivery_detail_id
         AND wlpn.lpn_id(+) = wdd2.lpn_id
         AND wdd2.delivery_detail_id = p_transaction_id;

    -- Fix bug 2167545, problem 3, need to change the above cusror.
    --  the lpn_id is not on the WDD record that has inventory_item_id information,
    --  it is on the other parent WDD record. Changed to following
    CURSOR wda_material_cur IS
      SELECT wdd1.inventory_item_id inventory_item_id
           , wdd1.organization_id organization_id
           , wdd1.lot_number lot_number
           , NVL(wlpn.cost_group_id, 0) cost_group_id
           , NVL(wdd1.project_id, 0) project_id
           , NVL(wdd1.task_id, 0) task_id
           -- Bug - 4193950, requested_quantity is replaced with shipped_quantity.
           , wdd1.shipped_quantity quantity --, wdd1.requested_quantity quantity
           , wdd1.requested_quantity_uom uom
           , wdd1.revision revision
           , wdd1.subinventory
           , wdd1.locator_id
        FROM wsh_delivery_details wdd1
           , wsh_delivery_assignments_v wda
           , wsh_new_deliveries wnd
           , wms_license_plate_numbers wlpn
           , wsh_delivery_details wdd2
       WHERE wda.delivery_id = wnd.delivery_id
         AND wdd1.delivery_detail_id = wda.delivery_detail_id
         AND wdd2.delivery_detail_id = wda.parent_delivery_detail_id
         AND wdd1.inventory_item_id IS NOT NULL
         AND wlpn.lpn_id(+) = wdd2.lpn_id
         AND wnd.delivery_id = p_transaction_id;

    -- For business_flow_code of WIP Completion(26), the transaction temp id  is passed.
    -- Bug 2825748 : Material Label Is Not Printed On WIP Ccompletion.
     -- Bug 3823140, WIP Completion will use cursor mmtt_material_receipt_cur to get new lot information from MTLT
    /*
    CURSOR wip_material_cur IS
      SELECT mmtt.inventory_item_id
           , mmtt.organization_id
           , mtlt.lot_number
           , mmtt.cost_group_id
           , mmtt.project_id
           , mmtt.task_id
           , ABS(NVL(mtlt.transaction_quantity, mmtt.transaction_quantity))
           , mmtt.transaction_uom
           , mmtt.revision
           , mmtt.subinventory_code
           , mmtt.locator_id
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND mmtt.transaction_temp_id = p_transaction_id;
        */
    -- For business_flow_code of Manufacturing Cross-Dock
    CURSOR wip_material_cur IS
      SELECT mmtt.inventory_item_id
           , mmtt.organization_id
           , mtlt.lot_number
           , mmtt.cost_group_id
           , mmtt.project_id
           , mmtt.task_id
           , ABS(NVL(mtlt.transaction_quantity, mmtt.transaction_quantity))
           , mmtt.transaction_uom
           , mmtt.revision
           , mmtt.subinventory_code
           , mmtt.locator_id
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
       WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND mmtt.transaction_temp_id = p_transaction_id;

    -- For business flow code of 33, the MMTT, MTI or MOL id is passed
    -- Depending on the txn identifier being passed,one of the
    -- following 3 flow csrs will be called

    CURSOR flow_material_curs_mmtt IS
      SELECT mmtt.inventory_item_id inventory_item_id
           , mmtt.organization_id organization_id
           , mtlt.lot_number lot_number
           , mmtt.cost_group_id cost_group_id
           , mmtt.project_id project_id
           , mmtt.task_id task_id
           , NVL(mtlt.transaction_quantity, mmtt.transaction_quantity) quantity
           , mmtt.transaction_uom uom
           , mmtt.revision revision
           , mmtt.subinventory_code
           , mmtt.locator_id
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
       WHERE mmtt.transaction_temp_id = mtlt.transaction_temp_id(+)
         AND mmtt.transaction_temp_id = p_transaction_id;

    CURSOR flow_material_curs_mti IS
      SELECT mti.inventory_item_id inventory_item_id
           , mti.organization_id organization_id
           , mtil.lot_number lot_number
           , mti.cost_group_id cost_group_id
           , mti.project_id project_id
           , mti.task_id task_id
           , NVL(mtil.transaction_quantity, mti.transaction_quantity) quantity
           , mti.transaction_uom uom
           , mti.revision revision
           , mti.subinventory_code
           , mti.locator_id
        FROM mtl_transactions_interface mti, mtl_transaction_lots_interface mtil
       WHERE mti.transaction_interface_id = mtil.transaction_interface_id(+)
         AND mti.transaction_interface_id = p_transaction_id;

    CURSOR flow_material_curs_mol IS
      SELECT mtrl.inventory_item_id inventory_id
           , mtrl.organization_id organization_id
           , mtrl.lot_number lot_number
           , mtrl.from_cost_group_id cost_group_id
           , mtrl.project_id project_id
           , mtrl.task_id task_id
           , mtrl.quantity quantity
           , mtrl.uom_code uom
           , mtrl.revision revision
           , mtrl.from_subinventory_code
           , mtrl.from_locator_id
        FROM mtl_txn_request_lines mtrl
       WHERE mtrl.line_id = p_transaction_id;

    -- End of Flow csr



    -- To get org type.
    CURSOR rti_get_org_cur IS
      SELECT to_organization_id
        FROM rcv_transactions_interface rti
       WHERE rti.interface_transaction_id = p_transaction_id;


    /*Bug# 3238878
      To get Org Type for Patchset J and above */
    CURSOR rt_get_org_cur IS
       SELECT organization_id
         FROM rcv_transactions rt
        WHERE rt.group_id = p_transaction_id
        and ( (p_label_type_info.business_flow_code = 1 AND rt.transaction_type = 'RECEIVE')
           OR (p_label_type_info.business_flow_code = 2 AND rt.transaction_type in ('ACCEPT', 'REJECT') )
           OR (p_label_type_info.business_flow_code = 3 AND rt.transaction_type = 'DELIVER')
           OR (p_label_type_info.business_flow_code = 4 AND rt.transaction_type = 'DELIVER')
           );
    /*End of Bug# 3238878 */

    /* The following cursor is modified for the bug # 4686024 */

/*    CURSOR c_cost_group IS
      SELECT cost_group
        FROM cst_cost_groups
       WHERE cost_group_id = l_cost_group_id;        */

    CURSOR c_cost_group(p_cost_group_id NUMBER) IS
      SELECT cost_group
        FROM cst_cost_groups
      WHERE cost_group_id = p_cost_group_id;


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

    CURSOR c_material_cur(
      p_organization_id   NUMBER
    , p_inventory_item_id NUMBER
    , p_lot_number        VARCHAR2
    ) IS
      SELECT msik.concatenated_segments item
           , WMS_DEPLOY.GET_CLIENT_ITEM(p_organization_id, msik.inventory_item_id) client_item			-- Added for LSP Project, bug 9087971
           , NVL(msik.description, l_item_description) item_description
           , mp.organization_code ORGANIZATION
           , l_revision revision
           , l_quantity quantity
           , l_uom uom
           , mln.lot_number lot_number
           , NVL(l_parent_lot_number , mln.parent_lot_number) parent_lot_number -- invconv changes
           , TO_CHAR(NVL(l_expiration_action_date, mln.expiration_action_date), g_date_format_mask) expiration_action_date
           , NVL(l_expiration_action_code , mln.expiration_action_code) expiration_action_code
           , l_secondary_transaction_qty secondary_quantity
           , l_secondary_uom_code  secondary_uom
           , TO_CHAR(NVL(l_hold_date, mln.hold_date), g_date_format_mask) hold_date
           , NVL(l_origination_type , mln.origination_type) origination_type
           , NVL(l_supplier_lot_number, mln.supplier_lot_number) supplier_lot_number -- invconv changes
           , mmsvl.status_code lot_status
           , TO_CHAR(mln.expiration_date, g_date_format_mask) lot_expiration_date
           , -- Added for Bug 2795525,
            NVL(l_attribute_category, mln.attribute_category) lot_attribute_category
           , NVL(l_c_attribute1, mln.c_attribute1) lot_c_attribute1
           , NVL(l_c_attribute2, mln.c_attribute2) lot_c_attribute2
           , NVL(l_c_attribute3, mln.c_attribute3) lot_c_attribute3
           , NVL(l_c_attribute4, mln.c_attribute4) lot_c_attribute4
           , NVL(l_c_attribute5, mln.c_attribute5) lot_c_attribute5
           , NVL(l_c_attribute6, mln.c_attribute6) lot_c_attribute6
           , NVL(l_c_attribute7, mln.c_attribute7) lot_c_attribute7
           , NVL(l_c_attribute8, mln.c_attribute8) lot_c_attribute8
           , NVL(l_c_attribute9, mln.c_attribute9) lot_c_attribute9
           , NVL(l_c_attribute10, mln.c_attribute10) lot_c_attribute10
           , NVL(l_c_attribute11, mln.c_attribute11) lot_c_attribute11
           , NVL(l_c_attribute12, mln.c_attribute12) lot_c_attribute12
           , NVL(l_c_attribute13, mln.c_attribute13) lot_c_attribute13
           , NVL(l_c_attribute14, mln.c_attribute14) lot_c_attribute14
           , NVL(l_c_attribute15, mln.c_attribute15) lot_c_attribute15
           , NVL(l_c_attribute16, mln.c_attribute16) lot_c_attribute16
           , NVL(l_c_attribute17, mln.c_attribute17) lot_c_attribute17
           , NVL(l_c_attribute18, mln.c_attribute18) lot_c_attribute18
           , NVL(l_c_attribute19, mln.c_attribute19) lot_c_attribute19
           , NVL(l_c_attribute20, mln.c_attribute20) lot_c_attribute20
           , TO_CHAR(NVL(l_d_attribute1, mln.d_attribute1), g_date_format_mask) lot_d_attribute1
           , -- Added for Bug 2795525,
            TO_CHAR(NVL(l_d_attribute2, mln.d_attribute2), g_date_format_mask) lot_d_attribute2
           , -- Added for Bug 2795525,
            TO_CHAR(NVL(l_d_attribute3, mln.d_attribute3), g_date_format_mask) lot_d_attribute3
           , -- Added for Bug 2795525,
            TO_CHAR(NVL(l_d_attribute4, mln.d_attribute4), g_date_format_mask) lot_d_attribute4
           , -- Added for Bug 2795525,
            TO_CHAR(NVL(l_d_attribute5, mln.d_attribute5), g_date_format_mask) lot_d_attribute5
           , -- Added for Bug 2795525,
            TO_CHAR(NVL(l_d_attribute6, mln.d_attribute6), g_date_format_mask) lot_d_attribute6
           , -- Added for Bug 2795525,
            TO_CHAR(NVL(l_d_attribute7, mln.d_attribute7), g_date_format_mask) lot_d_attribute7
           , -- Added for Bug 2795525,
            TO_CHAR(NVL(l_d_attribute8, mln.d_attribute8), g_date_format_mask) lot_d_attribute8
           , -- Added for Bug 2795525,
            TO_CHAR(NVL(l_d_attribute9, mln.d_attribute9), g_date_format_mask) lot_d_attribute9
           , -- Added for Bug 2795525,
            TO_CHAR(
              NVL(l_d_attribute10, mln.d_attribute10)
            , g_date_format_mask
            ) lot_d_attribute10
           , -- Added for Bug 2795525,
            NVL(l_n_attribute1, mln.n_attribute1) lot_n_attribute1
           , NVL(l_n_attribute2, mln.n_attribute2) lot_n_attribute2
           , NVL(l_n_attribute3, mln.n_attribute3) lot_n_attribute3
           , NVL(l_n_attribute4, mln.n_attribute4) lot_n_attribute4
           , NVL(l_n_attribute5, mln.n_attribute5) lot_n_attribute5
           , NVL(l_n_attribute6, mln.n_attribute6) lot_n_attribute6
           , NVL(l_n_attribute7, mln.n_attribute7) lot_n_attribute7
           , NVL(l_n_attribute8, mln.n_attribute8) lot_n_attribute8
           , NVL(l_n_attribute9, mln.n_attribute9) lot_n_attribute9
           , NVL(l_n_attribute10, mln.n_attribute10) lot_n_attribute10
           , NVL(l_territory_code, mln.territory_code) lot_country_of_origin
           , NVL(l_grade_code, mln.grade_code) lot_grade_code
           , TO_CHAR(
               NVL(l_origination_date, mln.origination_date)
             , g_date_format_mask
             ) lot_origination_date
           , -- Added for Bug 2795525,
            NVL(l_date_code, mln.date_code) lot_date_code
           , TO_CHAR(NVL(l_change_date, mln.change_date), g_date_format_mask) lot_change_date
           , -- Added for Bug 2795525,
            NVL(l_age, mln.age) lot_age
           , TO_CHAR(NVL(l_retest_date, mln.retest_date), g_date_format_mask) lot_retest_date
           , -- Added for Bug 2795525,
            TO_CHAR(
              NVL(l_maturity_date, mln.maturity_date)
            , g_date_format_mask
            ) lot_maturity_date
           , -- Added for Bug 2795525,
            NVL(l_item_size, mln.item_size) lot_item_size
           , NVL(l_color, mln.color) lot_color
           , NVL(l_volume, mln.volume) lot_volume
           , NVL(l_volume_uom, mln.volume_uom) lot_volume_uom
           , NVL(l_place_of_origin, mln.place_of_origin) lot_place_of_origin
           , TO_CHAR(NVL(l_best_by_date, mln.best_by_date), g_date_format_mask) lot_best_by_date
           , -- Added for Bug 2795525,
            NVL(l_length, mln.LENGTH) lot_length
           , NVL(l_length_uom, mln.length_uom) lot_length_uom
           , NVL(l_recycled_content, mln.recycled_content) lot_recycled_cont
           , NVL(l_thickness, mln.thickness) lot_thickness
           , NVL(l_thickness_uom, mln.thickness_uom) lot_thickness_uom
           , NVL(l_width, mln.width) lot_width
           , NVL(l_width_uom, mln.width_uom) lot_width_uom
           , NVL(l_curl_wrinkle_fold, mln.curl_wrinkle_fold) lot_curl
           , NVL(l_vendor_name, mln.vendor_name) lot_vendor
           , l_cost_group cost_group
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
           , l_project_number project_number -- Fix For Bug: 4907062
           , l_project_name project
           , l_task_number task_number       -- Fix For Bug: 4907062
           , l_task_name task
           , l_subinventory_code subinventory_code
           , wilk.concatenated_segments LOCATOR
           -- milk.concatenated_segments LOCATOR -- Modified for bug # 5015415
        FROM mtl_system_items_vl msik --Bug 5302715 changed from kfv to vl
           , mtl_lot_numbers mln
           , mtl_material_statuses_vl mmsvl
           , po_hazard_classes poh
           , mtl_parameters mp
        /*Commented for bug# 6334460 start
           , DUAL d
          Commented for bug# 6334460 end */
           , wms_item_locations_kfv wilk
           --, mtl_item_locations_kfv milk -- Modified for bug # 5015415
       /*Commented for bug# 6334460 start
       WHERE d.dummy = 'X'
         AND msik.concatenated_segments(+) <> NVL('@@@', d.dummy)
       Commented for bug# 6334460 End */
         WHERE msik.inventory_item_id(+) = p_inventory_item_id
         AND msik.organization_id(+) = p_organization_id
         AND mp.organization_id = p_organization_id
         AND mln.organization_id(+) = msik.organization_id
         AND mln.inventory_item_id(+) = msik.inventory_item_id
         AND mln.lot_number(+) = p_lot_number
         AND mmsvl.status_id(+) = mln.status_id
         AND poh.hazard_class_id(+) = msik.hazard_class_id
         AND wilk.organization_id(+) = msik.organization_id
         AND wilk.subinventory_code(+) = l_subinventory_code
         AND wilk.inventory_location_id(+) = l_locator_id;

       /* The following conditions have been modified for bug # 5015415.

         For PJM Org, Locator field in Material Label should not show the Project and task id's.
         This is because, the Project and Task Id's are not Bar code transactable.
         In mtl_item_locations_kfv, the cocatenated segments will have Project and
         Task Id's attached to it. Whereas in wms_item_locations_kfv, concatenated
         segments will have only the physical details (Row, Rack and Bin)
         and not the project and Task id's.
         AND milk.organization_id(+) = msik.organization_id
         AND milk.subinventory_code(+) = l_subinventory_code
         AND milk.inventory_location_id(+) = l_locator_id; */


      /* For Bug 4916450 defined the cursor pod_project_task */
       CURSOR pod_project_task IS
       SELECT DISTINCT pod.project_id, pod.task_id
       FROM po_distributions_all pod,
            rcv_transactions rt
       WHERE pod.po_header_id = rt.po_header_id
       AND pod.po_line_id = rt.po_line_id
       AND pod.line_location_id = rt.po_line_location_id
       AND pod.po_distribution_id = nvl(rt.po_distribution_id, pod.po_distribution_id)
       AND rt.group_id = p_transaction_id
       --Bug 8230113 Cursor opens for a single po_line
       AND pod.po_line_id = l_po_line_id;

    /* The following cursor has been added to fetch the PROJECT_REFERENCE_ENABLED value
     * from pjm_org_parameters table. The value 'Y' represents the PJM enabled org.
     * This field will be used to open the cursors that are required only for PJM org.
     */

    CURSOR c_project_enabled(p_organization_id NUMBER) IS
       SELECT pop.project_reference_enabled
       FROM pjm_org_parameters pop
       WHERE pop.organization_id = p_organization_id;

    l_is_pjm_org             VARCHAR (1);


    --R12 PROJECT LABEL SET with RFID

    CURSOR c_label_formats_in_set(p_format_set_id IN NUMBER)  IS
       select wlfs.format_id label_format_id, wlf.label_entity_type --FOR SETS
         from wms_label_set_formats wlfs , wms_label_formats wlf
         where WLFS.SET_ID = p_format_set_id
         and wlfs.set_id = wlf.label_format_id
         and wlf.label_entity_type = 1
         AND WLF.DOCUMENT_ID = 1
       UNION --FOR FORMAT
       select label_format_id, nvl(wlf.label_entity_type,0) from wms_label_formats wlf
         where  wlf.label_format_id =  p_format_set_id
         and nvl(wlf.label_entity_type,0) = 0--for label formats only validation
         AND WLF.DOCUMENT_ID = 1 ;

    --Start of fix for 4891916.
    --Added the cursor to fetch records from mcce at the
    --the time of cycle count entry for a particular entry

    CURSOR mcce_material_cur IS
    SELECT mcce.inventory_item_id,
           mcce.organization_id,
           mcce.lot_number,
           mcce.cost_group_id,
           mcce.count_quantity_current,
           mcce.count_uom_current,
           mcce.revision,
           mcce.subinventory,
           mcce.locator_id,
           mcch.cycle_count_header_name,
           ppf.full_name requestor
    FROM mtl_cycle_count_headers mcch,
           mtl_cycle_count_entries mcce,
           per_people_f ppf
    WHERE mcce.cycle_count_entry_id =  p_transaction_Id
    AND ppf.person_id(+) = mcce.counted_by_employee_id_current
    AND mcce.cycle_count_header_id=mcch.cycle_count_header_id;


    --Added this cursor to get details like cycle count header name
    --and counter for the entry for the label printed at the time of
    --cycle count approval

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
    AND ppf.person_id(+) = mcce.counted_by_employee_id_current;

    --End of fix for Bug 4687964

    l_selected_fields        inv_label.label_field_variable_tbl_type;
    l_selected_fields_count  NUMBER;
    l_return_status          VARCHAR2(240);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(240);
    l_error_message          VARCHAR2(240);
    l_api_status             VARCHAR2(240);
    i                        NUMBER;
    l_transaction_id         NUMBER                             := p_transaction_id;
    l_business_flow_code     NUMBER         := p_label_type_info.business_flow_code;
    l_count                  NUMBER;
    l_lpn_id                 NUMBER;
    l_label_info             inv_label.label_type_rec;
    l_material_data          LONG                                             := '';
    l_label_format_id        NUMBER                                           := 0;
    l_label_format           VARCHAR2(100)                                  := NULL;
    l_printer                VARCHAR2(30)                                   := NULL;
    l_label_request_id       NUMBER                                           := 0;
    l_get_org_id             NUMBER;
    l_is_wms_org             BOOLEAN;
    l_material_input         inv_label.material_label_input_tbl;
    l_material_input_index   NUMBER;
    l_purchase_order         po_headers_all.segment1%TYPE;
    rti_material_lpn_rec     rti_material_lpn_cur%ROWTYPE;
    rti_material_mtlt_rec    rti_material_mtlt_cur%ROWTYPE;
    l_po_line_number         varchar2(240); -- CLM project, bug 9403291
    l_quantity_ordered       NUMBER;
    l_supplier_part_number   VARCHAR2(25);
    -- START of Bug fix for 3916663
     --l_supplier_name          VARCHAR2(80);
     --l_supplier_site          VARCHAR2(15);
     --l_requestor              VARCHAR2(80);
     --l_deliver_to_location    VARCHAR2(20);
     --l_location_code          VARCHAR2(20);
     --l_note_to_receiver       VARCHAR2(240);

   -- Increased this variable size to the corresponding column size in the table.
    l_supplier_name po_vendors.VENDOR_NAME%TYPE;
    l_supplier_site po_vendor_sites.VENDOR_SITE_CODE%TYPE;
    l_requestor per_people_f.FULL_NAME%TYPE;
    l_deliver_to_location hr_locations_all.LOCATION_CODE%TYPE;
    l_location_code hr_locations_all.LOCATION_CODE%TYPE;
    l_note_to_receiver po_line_locations.NOTE_TO_RECEIVER%TYPE;

   -- END of Bug fix for 3916663
    l_routing_name           VARCHAR2(30);
    l_content_rec_index      NUMBER                                           := 0;
    l_printed_flag           VARCHAR2(1);
    l_split_qty              NUMBER                                           := 0;
    l_label_counter          NUMBER                                           := 0;
    l_label_index            NUMBER;
    --I cleanup, use l_prev_format_id to record the previous label format
    l_prev_format_id         NUMBER;
    -- I cleanup, user l_prev_sub to record the previous subinventory
    --so that get_printer is not called if the subinventory is the same
    l_prev_sub               VARCHAR2(30);
    -- a list of columns that are selected for format
    l_column_name_list       LONG;

    l_patch_level  NUMBER;
    l_lpn_context Number;
    l_routing_header_id NUMBER; --bug 4916450
    l_next_project_id NUMBER; --bug 4916450
    l_next_task_id NUMBER; --bug 4916450


    l_gtin_epc_quantity NUMBER := 1;
    L_EPC_LOOP_COUNT NUMBER := 0;
    l_label_format_set_id NUMBER;

    l_is_expense_item        BOOLEAN := FALSE; /* Added for the bug # 4708752 */
    --Bug 4891916. Added the local variable to store the cycle count name
    l_cycle_count_name mtl_cycle_count_headers.cycle_count_header_name%TYPE;

    v_material_cur           c_material_cur%ROWTYPE; --Added for Bug 6504959
    l_moqd_quantity          number;--added for bug 6646793
    l_mmtt_quantity          number;--added for bug 6646793
    l_transaction_type       NUMBER;--added for bug 6646793


  BEGIN
    l_debug                   := inv_label.l_debug;
    x_return_status           := fnd_api.g_ret_sts_success;
    l_label_err_msg := NULL;

    IF (l_debug = 1) THEN
      TRACE('**In PVT1: Material label**');
      TRACE('  Business_flow=' || p_label_type_info.business_flow_code
        || ', Transaction ID=' || p_transaction_id
        || ', Transaction Identifier=' || p_transaction_identifier
      );
    END IF;

    l_transaction_identifier  := p_transaction_identifier;

    IF (inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j)
          AND (inv_rcv_common_apis.g_po_patch_level >=inv_rcv_common_apis.g_patchset_j_po) THEN
       l_patch_level := 1;
    ELSE
       l_patch_level := 0;
    END IF;
    -- Get org for p_transaction_id
    IF p_label_type_info.business_flow_code IN (1, 2, 3, 4) THEN

        /* Bug# 3238878 */
        IF((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j)
          AND (inv_rcv_common_apis.g_po_patch_level >=inv_rcv_common_apis.g_patchset_j_po)) THEN
            IF (l_debug = 1) THEN
                trace('Patchset J code ');
            END IF;
            OPEN rt_get_org_cur;
            FETCH rt_get_org_cur INTO l_get_org_id;
            IF rt_get_org_cur%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    TRACE(' No record found in RT to get the org for ID '|| p_transaction_id);
                END IF;
                CLOSE rt_get_org_cur;
                RETURN;
            ELSE
                CLOSE rt_get_org_cur;
            END IF;
        ELSE
            OPEN rti_get_org_cur;
            FETCH rti_get_org_cur INTO l_get_org_id;

            IF rti_get_org_cur%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    TRACE( ' No record found in RTI to get the org for ID '|| p_transaction_id);
                END IF;

                CLOSE rti_get_org_cur;
                RETURN;
            ELSE
                CLOSE rti_get_org_cur;
            END IF;
        END IF;
        /* End of Bug# 3238878 */

        l_is_wms_org  :=
          wms_install.check_install(
            x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          , p_organization_id            => l_get_org_id
          );

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

    -- Get l_inventory_item_id and l_lot_id
    IF (p_transaction_id IS NOT NULL) THEN -- Business flow + transaction_id passed.
        -- txn driven
        IF (p_label_type_info.business_flow_code IN (1,2,3,4)) THEN
            IF (l_debug = 1) THEN
                trace('business flow code is 1,2,3 or 4');
            END IF;
            IF l_patch_level = 1   THEN

                IF (l_debug = 1) THEN
                    TRACE('Patchset J code ');
                END IF;
                /* Patchset J - Use the new cursor rt_material_cur. This cursor replaces
                 * RTI_MATERIAL_LPN_CUR and RTI_MATERIAL_MTLT_CUR in patchset J, due to receiving tables
                 * changes. Also, earlier, receiving transaction records were created separately for
                 * INV and WMS organizations, which is not the case now.
                 * Open the cursor rt_material_cur. This cursor fetches data irrespective
                 * of whether it is a WMS org or INV org.
                 */
                -- Bug 4516067
                --  created new cursor for putaway and deliver
                -- Open rt_material_cur or rt_putaway_deliver_cur based on busienss flow code
                IF (p_label_type_info.business_flow_code IN (1,2)) THEN
                    OPEN rt_material_cur;
                    FETCH rt_material_cur INTO
                                   l_inventory_item_id
                                 , l_organization_id
                                 , l_lot_number
                                 , l_cost_group_id
                                 , l_project_id
                                 , l_task_id
                                 -- Added by joabraha for bug 3472150
                                 , l_receipt_number
                                 --
                                 , l_quantity
                                 , l_secondary_transaction_qty
                                 , l_uom
                                 , l_secondary_uom_code
                                 , l_revision
                                 , l_purchase_order
                                 , l_shipment_num
                                 , l_po_line_number
                                 -- Bug 8230113
                                 , l_po_line_id
                                 , l_quantity_ordered
                                 , l_supplier_part_number
                                 , l_vendor_id
                                 , l_supplier_name
                                 , l_vendor_site_id
                                 , l_supplier_site
                                 , l_requestor
                                 , l_deliver_to_location
                                 , l_location_code
                                 , l_note_to_receiver
                                 , l_routing_name
                                 , l_item_description
                                 , l_subinventory_code
                                 , l_locator_id
                                 , l_wip_entity_name
                                 , l_wip_description
                                 , l_wip_op_seq_num
                                 , l_osp_dept_code
                                 , l_bom_resource_id
                                 , l_lpn_context
                                 , l_lpn_id
                                 , l_routing_header_id --bug 4916450
                                   --8533306
                                 , l_po_distribution_id
                                   -- Bug 8632067
                                 , l_rcv_transaction_id;

                    IF rt_material_cur%NOTFOUND THEN
                        IF (l_debug = 1) THEN
                            TRACE(' No material found for this given Interface Transaction ID:' || p_transaction_id);
                        END IF;
                        CLOSE rt_material_cur;
                        RETURN;
                    END IF;
                ELSIF (p_label_type_info.business_flow_code IN (3,4)) THEN
                    OPEN rt_putaway_deliver_cur;
                    FETCH rt_putaway_deliver_cur INTO
                                       l_inventory_item_id
                                     , l_organization_id
                                     , l_lot_number
                                     , l_cost_group_id
                                     , l_project_id
                                     , l_task_id
                                     -- Added by joabraha for bug 3472150
                                     , l_receipt_number
                                     --
                                     , l_quantity
                                     , l_secondary_transaction_qty
                                     , l_uom
                                     , l_secondary_uom_code
                                     , l_revision
                                     , l_purchase_order
                                     , l_shipment_num
                                     , l_po_line_number
                                      -- Bug 8648128
                                     , l_po_line_id
                                     , l_quantity_ordered
                                     , l_supplier_part_number
                                     , l_vendor_id
                                     , l_supplier_name
                                     , l_vendor_site_id
                                     , l_supplier_site
                                     , l_requestor
                                     , l_deliver_to_location
                                     , l_location_code
                                     , l_note_to_receiver
                                     , l_routing_name
                                     , l_item_description
                                     , l_subinventory_code
                                     , l_locator_id
                                     , l_wip_entity_name
                                     , l_wip_description
                                     , l_wip_op_seq_num
                                     , l_osp_dept_code
                                     , l_bom_resource_id
                                     , l_lpn_context
                                     , l_lpn_id
                                     , l_routing_header_id --bug 4916450
                                     --Bug 8648128
                                     , l_po_distribution_id
                                     -- Bug 8632067
                                     , l_rcv_transaction_id;
                    IF rt_putaway_deliver_cur%NOTFOUND THEN
                        IF (l_debug = 1) THEN
                            TRACE(' No material found for this given Interface Transaction ID:' || p_transaction_id);
                        END IF;
                        CLOSE rt_putaway_deliver_cur;
                        RETURN;
                    END IF;

                END IF;

                OPEN get_resource_dept_code_cur(l_bom_resource_id);
                FETCH get_resource_dept_code_cur INTO l_bom_resource_code, l_osp_dept_code;
                IF get_resource_dept_code_cur%NOTFOUND THEN
                    IF (l_debug = 1) THEN
                        TRACE(' No Resource and Dept code found for Resource ID: ' || l_bom_resource_id);
                    END IF;
                END IF;
                --CLOSE get_resource_dept_code_cur;

                --l_receipt_number  := inv_rcv_common_apis.g_rcv_global_var.receipt_num;
                IF (l_debug = 1) THEN
                    TRACE(' Receipt Number: ' || l_receipt_number);
                END IF;

            ELSE
                IF (l_debug = 1) THEN
                    trace('NOT Patchset J code. Patch level < inv J or PO J');
                END IF;
                IF ((p_label_type_info.business_flow_code IN (1))
                    AND (l_is_wms_org = TRUE)
                ) THEN
                    --l_receipt_number  := inv_rcv_common_apis.g_rcv_global_var.receipt_num;
                    -- Receipt and Inspection, WMS org, obtaining the lot information
                    -- from the wms_lpn_contents and the rest information from the
                    -- rti record
                    OPEN rti_material_lpn_cur;
                    FETCH rti_material_lpn_cur INTO l_inventory_item_id
                                      , l_organization_id
                                      , l_lot_number
                                      , l_cost_group_id
                                      , l_project_id
                                      , l_task_id
                                      -- Added by joabraha for bug 3472150
                                      , l_receipt_number
                                      --
                                      , l_quantity
                                      , l_uom
                                      , l_revision
                                      , l_lpn_id
                                      , l_purchase_order
                                      , l_po_line_number
                                      , l_quantity_ordered
                                      , l_supplier_part_number
                                      , l_vendor_id
                                      , l_supplier_name
                                      , l_vendor_site_id
                                      , l_supplier_site
                                      , l_requestor
                                      , l_deliver_to_location
                                      , l_location_code
                                      , l_note_to_receiver
                                      , l_routing_name
                                      , l_item_description
                                      , l_subinventory_code
                                      , l_locator_id
                                      , l_wip_entity_name
                                      , l_wip_description
                                      , l_wip_op_seq_num
                                      , l_osp_dept_code
                                      , l_bom_resource_id;

                    IF rti_material_lpn_cur%NOTFOUND THEN
                        IF (l_debug = 1) THEN
                            TRACE(' No material found for this given Interface Transaction ID:' || p_transaction_id);
                        END IF;

                        CLOSE rti_material_lpn_cur;
                        RETURN;
                    END IF;

                    --l_receipt_number  := inv_rcv_common_apis.g_rcv_global_var.receipt_num;
                    IF (l_debug = 1) THEN
                        TRACE(' Receipt Number: ' || l_receipt_number);
                    END IF;

                ELSIF ((p_label_type_info.business_flow_code IN (2))
                  AND (l_is_wms_org = TRUE)
                ) THEN
                    -- Receipt and Inspection, WMS org, obtaining the lot information
                    -- from the wms_lpn_contents and the rest information from the rti record
                    --l_receipt_number  := inv_rcv_common_apis.g_rcv_global_var.receipt_num;
                    OPEN rti_material_lpn_inspec_cur;
                    FETCH rti_material_lpn_inspec_cur INTO l_inventory_item_id
                                             , l_organization_id
                                             , l_lot_number
                                             , l_cost_group_id
                                             , l_project_id
                                             , l_task_id
                                             -- Added by joabraha for bug 3472150
                                             , l_receipt_number
                                             --
                                             , l_quantity
                                             , l_uom
                                             , l_revision
                                             , l_lpn_id
                                             , l_purchase_order
                                             , l_po_line_number
                                             , l_quantity_ordered
                                             , l_supplier_part_number
                                             , l_vendor_id
                                             , l_supplier_name
                                             , l_vendor_site_id
                                             , l_supplier_site
                                             , l_requestor
                                             , l_deliver_to_location
                                             , l_location_code
                                             , l_note_to_receiver
                                             , l_routing_name
                                             , l_item_description
                                             , l_subinventory_code
                                             , l_locator_id
                                             , l_wip_entity_name
                                             , l_wip_description
                                             , l_wip_op_seq_num
                                             , l_osp_dept_code
                                             , l_bom_resource_id;

                    IF rti_material_lpn_inspec_cur%NOTFOUND THEN
                        IF (l_debug = 1) THEN
                            TRACE(' No material found for this given Interface Transaction ID:' || p_transaction_id);
                        END IF;

                        CLOSE rti_material_lpn_inspec_cur;
                        RETURN;
                    END IF;

                    --l_receipt_number  := inv_rcv_common_apis.g_rcv_global_var.receipt_num;
                    IF (l_debug = 1) THEN
                        TRACE(' Receipt Number: ' || l_receipt_number);
                    END IF;

                ELSIF ((p_label_type_info.business_flow_code IN (4))
                    AND (l_is_wms_org = TRUE)
                      )
                    OR ((p_label_type_info.business_flow_code IN (1, 2, 3))
                    AND (l_is_wms_org = FALSE)
                ) THEN
                    -- For putaway in WMS org and Receipt, Inspection, Delivery in INV org
                    -- Obtain information from RTI and MTLT (if applicable)
                    -- Receipt Inspection: No lot and seial information, print item information from RTI
                    -- Delivery: RTI + MTLT
                    --l_receipt_number  := inv_rcv_common_apis.g_rcv_global_var.receipt_num;
                    OPEN rti_material_mtlt_cur;
                    FETCH rti_material_mtlt_cur --INTO rti_material_mtlt_rec;
                                    INTO l_inventory_item_id
                                       , l_revision
                                       , l_lot_number
                                       , l_organization_id
                                       , l_cost_group_id
                                       , l_project_id
                                       , l_task_id
                                       , l_quantity
                                       , l_uom
                                       , l_purchase_order
                                       , l_po_line_number
                                       , l_quantity_ordered
                                       , l_supplier_part_number
                                       , l_vendor_id
                                       , l_supplier_name
                                       , l_vendor_site_id
                                       , l_supplier_site
                                       , l_requestor
                                       , l_deliver_to_location
                                       , l_location_code
                                       , l_note_to_receiver
                                       , l_routing_name
                                       , l_item_description
                                       , l_subinventory_code
                                       , l_locator_id
                                       , l_wip_entity_name
                                       , l_wip_description
                                       , l_wip_op_seq_num
                                       , l_osp_dept_code
                                       , l_bom_resource_id;

                    IF rti_material_mtlt_cur%NOTFOUND THEN
                        IF (l_debug = 1) THEN
                            TRACE(' No material found for this given Interface Transaction ID:' || p_transaction_id);
                        END IF;

                        CLOSE rti_material_mtlt_cur;
                        RETURN;
                    END IF;
                END IF;
            END IF; -- l-patch_level = 1
        ELSIF (p_label_type_info.business_flow_code IN (6)) THEN
            -- Cross Dock(6).
            -- Here in this case the delivery_detail_id is being passed.
            -- Delivery detail ID passed means that we just have to print serial label for the one
            -- delivery detail id and
            -- not all the delivery detail id's in the delivery.
            -- The cost group will be derived from the table wms_license_plate_numbers for the LPN
            -- stamped on the Delivery_detail_id.
            OPEN wdd_material_cur;
            FETCH wdd_material_cur INTO l_inventory_item_id
                                  , l_organization_id
                                  , l_lot_number
                                  , l_cost_group_id
                                  , l_project_id
                                  , l_task_id
                                  , l_quantity
                                  , l_uom
                                  , l_revision
                                  , l_subinventory_code
                                  , l_locator_id;

            IF wdd_material_cur%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    TRACE(' No Material found for this given Delivery Detail ID:' || p_transaction_id);
                END IF;
                CLOSE wdd_material_cur;
                RETURN;
                -- Bug 3836623
                -- Can not close the cursor because there maybe more record available
                -- ELSE
                --   CLOSE wdd_material_cur;
            END IF;
            -- Fix bug 2308273: Miscellaneous receipt(13) is calling label printing through TM
            -- but when label printing is called, the TM has not processed the LOT information into
            -- the mtl_lot_numbers table from the mtl_transactions_lot_temp. So for misc.receipts into
            -- a new lot, the lot number detailed information is taken from the mtl_transactions_lot_temp.

            -- Bug 3823140, For WIP Completion(26), it also needs to get the new lot information from MTLT. Therefore, it also uses cursor mmtt_material_receipt_cur.
            -- Commented out the use of  wip_material_cur

        ELSIF p_label_type_info.business_flow_code IN (13,26) THEN
            OPEN mmtt_material_receipt_cur;
            FETCH mmtt_material_receipt_cur INTO l_inventory_item_id
                                           , l_organization_id
                                           , l_lot_number
                                           , l_cost_group_id
                                           , l_project_id
                                           , l_task_id
                                           , l_quantity
                                           , l_uom
                                           , l_secondary_transaction_qty -- invconv
                                           , l_secondary_uom_code        -- invconv
                                           , l_revision
                                           , l_attribute_category
                                           , l_c_attribute1
                                           , l_c_attribute2
                                           , l_c_attribute3
                                           , l_c_attribute4
                                           , l_c_attribute5
                                           , l_c_attribute6
                                           , l_c_attribute7
                                           , l_c_attribute8
                                           , l_c_attribute9
                                           , l_c_attribute10
                                           , l_c_attribute11
                                           , l_c_attribute12
                                           , l_c_attribute13
                                           , l_c_attribute14
                                           , l_c_attribute15
                                           , l_c_attribute16
                                           , l_c_attribute17
                                           , l_c_attribute18
                                           , l_c_attribute19
                                           , l_c_attribute20
                                           , l_d_attribute1
                                           , l_d_attribute2
                                           , l_d_attribute3
                                           , l_d_attribute4
                                           , l_d_attribute5
                                           , l_d_attribute6
                                           , l_d_attribute7
                                           , l_d_attribute8
                                           , l_d_attribute9
                                           , l_d_attribute10
                                           , l_n_attribute1
                                           , l_n_attribute2
                                           , l_n_attribute3
                                           , l_n_attribute4
                                           , l_n_attribute5
                                           , l_n_attribute6
                                           , l_n_attribute7
                                           , l_n_attribute8
                                           , l_n_attribute9
                                           , l_n_attribute10
                                           , l_territory_code
                                           , l_grade_code
                                           , l_origination_date
                                           , l_date_code
                                           , l_change_date
                                           , l_age
                                           , l_retest_date
                                           , l_maturity_date
                                           , l_item_size
                                           , l_color
                                           , l_volume
                                           , l_volume_uom
                                           , l_place_of_origin
                                           , l_best_by_date
                                           , l_length
                                           , l_length_uom
                                           , l_recycled_content
                                           , l_thickness
                                           , l_thickness_uom
                                           , l_width
                                           , l_width_uom
                                           , l_curl_wrinkle_fold
                                           , l_vendor_name
                                           , l_subinventory_code
                                           , l_locator_id
                                           , l_wip_entity_name -- Fix For Bug: 4907062
                                           , l_wip_description -- Fix For Bug: 4907062
                                           , l_parent_lot_number -- invconv fabdi
                                           , l_expiration_action_date
                                           , l_origination_type
                                           , l_hold_date
                                           , l_expiration_action_code
                                           , l_supplier_lot_number; -- invconv end

            IF mmtt_material_receipt_cur%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    TRACE(' No record found in MMTT for given txn_temp_id: ' || p_transaction_id);
                END IF;

                CLOSE mmtt_material_receipt_cur;
                RETURN;
            END IF;
            -- Pack/Unpack/Split LPN
            -- The mmtt.transaction_temp_id is being passed.
        ELSIF p_label_type_info.business_flow_code = 20 THEN
            OPEN material_lpn_cur;
            FETCH material_lpn_cur INTO l_inventory_item_id
                                  , l_organization_id
                                  , l_lot_number
                                  , l_cost_group_id
                                  , l_project_id
                                  , l_task_id
                                  , l_quantity
                                  , l_uom
                                  , l_revision
                                  , l_from_subinventory
                                  , l_to_subinventory
                                  , l_from_locator_id
                                  , l_to_locator_id
                                  , l_secondary_transaction_qty -- invconv
                                  , l_secondary_uom_code; -- invconv


            IF material_lpn_cur%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    TRACE(' No Material found for this given temp ID:'|| p_transaction_id);
                END IF;

                CLOSE material_lpn_cur;
                RETURN;
            ELSE
                NULL;
            END IF;
        ELSIF p_label_type_info.business_flow_code IN (21) THEN
            -- Ship Confirm
            -- The delivery_id has being passed. Delivery ID passed means that all the delivery details ID have
            -- to be derived for the delivery ID. There will be one record per serial number in the wsh_delivery_details.
            -- The cost group will be derived from the table wms_license_plate_numbers for the LPN stamped on the Delivery_detail_id.

            OPEN wda_material_cur;
            FETCH wda_material_cur INTO l_inventory_item_id
                                  , l_organization_id
                                  , l_lot_number
                                  , l_cost_group_id
                                  , l_project_id
                                  , l_task_id
                                  , l_quantity
                                  , l_uom
                                  , l_revision
                                  , l_subinventory_code
                                  , l_locator_id;

            IF wda_material_cur%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    TRACE(' No Material found for this given delivery ID:' || p_transaction_id);
                END IF;

                CLOSE wda_material_cur;
                RETURN;
            END IF;
        ELSIF p_label_type_info.business_flow_code IN (22) THEN
            -- Cartonization
            OPEN c_get_pkg_items_content;
            FETCH c_get_pkg_items_content INTO l_organization_id
                                         , l_inventory_item_id
                                         , l_revision
                                         , l_lot_number
                                         , l_quantity;

            IF c_get_pkg_items_content%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    TRACE(' No records found for Header ID/package mode in the WPH:');
                END IF;

                CLOSE c_get_pkg_items_content;
                RETURN;
            END IF;
        /*ELSIF p_label_type_info.business_flow_code IN (26) THEN
            -- WIP Completion.
            --
            -- LPN Completions:
            -- In this case a record is populated in the MMTT with the item populated in the
            -- MMTT.inventorry_item_id and the LPN populated in the MMTT.transfer_lpn_id.
            -- As per the WIP team, the LPN is packed before label printing is called
            -- For every item of the completion, one record
            -- is inserted into the MMTT (with the MMTT.TRANSFER_LPN_ID ) populated and
            -- label printing is called. Material Label is printed for the
                        -- completed item .

            -- Non-LPN Completion
            -- In this case a record is populated in the MMTT with the item populated in the
            -- MMTT.inventory_item_id with all the related inforamtion.

            OPEN wip_material_cur;
            FETCH wip_material_cur INTO l_inventory_item_id
                                      , l_organization_id
                                      , l_lot_number
                                      , l_cost_group_id
                                      , l_project_id
                                      , l_task_id
                                      , l_quantity
                                      , l_uom
                                      , l_revision
                                      , l_subinventory_code
                                      , l_locator_id;
            TRACE(
                 ' wip_material_cur '
              || ', Item ID=' || l_inventory_item_id
              || ', Organization ID=' || l_organization_id
              || ', Lot Number=' || l_lot_number
              || ', Project ID=' || l_project_id
              || ', Cost Group ID=' || l_cost_group_id
              || ', Task ID=' || l_task_id
              || ', Transaction Quantity=' || l_quantity
              || ', Transaction UOM=' || l_uom
              || ', Item Revision=' || l_revision
              || ', Subinventory Code=' || l_subinventory_code
              || ', Locator ID=' || l_locator_id
            );

            IF wip_material_cur%NOTFOUND THEN
              TRACE(' No records found for transaction_temp_id in MMTT');
              CLOSE wip_material_cur;
            END IF;
        */
        -- Manufacturing Cross-Dock(37)
        ELSIF p_label_type_info.business_flow_code = 37 THEN
            OPEN wip_material_cur;
            FETCH wip_material_cur INTO l_inventory_item_id
                                      , l_organization_id
                                      , l_lot_number
                                      , l_cost_group_id
                                      , l_project_id
                                      , l_task_id
                                      , l_quantity
                                      , l_uom
                                      , l_revision
                                      , l_subinventory_code
                                      , l_locator_id;
            IF (l_debug = 1) THEN
                TRACE(' wip_material_cur '
                   || ', Item ID=' || l_inventory_item_id
                   || ', Organization ID=' || l_organization_id
                   || ', Lot Number=' || l_lot_number
                   || ', Project ID=' || l_project_id
                   || ', Cost Group ID=' || l_cost_group_id
                   || ', Task ID=' || l_task_id
                   || ', Transaction Quantity=' || l_quantity
                   || ', Transaction UOM=' || l_uom
                   || ', Item Revision=' || l_revision
                   || ', Subinventory Code=' || l_subinventory_code
                   || ', Locator ID=' || l_locator_id
                );
            END IF;

            IF wip_material_cur%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    TRACE(' No records found for transaction_temp_id in MMTT');
                END IF;
                CLOSE wip_material_cur;
            END IF;
        ELSIF p_label_type_info.business_flow_code IN (33) THEN
            -- Flow Completion

            IF l_transaction_identifier = 1 THEN
                OPEN flow_material_curs_mmtt;
                FETCH flow_material_curs_mmtt INTO l_inventory_item_id
                                           , l_organization_id
                                           , l_lot_number
                                           , l_cost_group_id
                                           , l_project_id
                                           , l_task_id
                                           , l_quantity
                                           , l_uom
                                           , l_revision
                                           , l_subinventory_code
                                           , l_locator_id;

                IF flow_material_curs_mmtt%NOTFOUND THEN
                    IF (l_debug = 1) THEN
                        TRACE(' No Flow Data found for this given ID:' || p_transaction_id || ' identifier=1');
                    END IF;

                    CLOSE flow_material_curs_mmtt;
                    RETURN;
                END IF;
            ELSIF l_transaction_identifier = 2 THEN
                OPEN flow_material_curs_mti;
                FETCH flow_material_curs_mti INTO l_inventory_item_id
                                          , l_organization_id
                                          , l_lot_number
                                          , l_cost_group_id
                                          , l_project_id
                                          , l_task_id
                                          , l_quantity
                                          , l_uom
                                          , l_revision
                                          , l_subinventory_code
                                          , l_locator_id;

                IF flow_material_curs_mti%NOTFOUND THEN
                    IF (l_debug = 1) THEN
                        TRACE(' No Flow Data found for this given ID:' || p_transaction_id || ' identifier=2');
                    END IF;

                    CLOSE flow_material_curs_mti;
                    RETURN;
                END IF;
            ELSIF l_transaction_identifier = 3 THEN
                OPEN flow_material_curs_mol;
                FETCH flow_material_curs_mol INTO l_inventory_item_id
                                          , l_organization_id
                                          , l_lot_number
                                          , l_cost_group_id
                                          , l_project_id
                                          , l_task_id
                                          , l_quantity
                                          , l_uom
                                          , l_revision
                                          , l_subinventory_code
                                          , l_locator_id;

                IF flow_material_curs_mol%NOTFOUND THEN
                    IF (l_debug = 1) THEN
                        TRACE(' No Flow Data found for this given ID:' || p_transaction_id || ' identifier=3');
                    END IF;

                    CLOSE flow_material_curs_mol;
                    RETURN;
                END IF;
            ELSE
                IF (l_debug = 1) THEN
                    TRACE(' Invalid transaction_identifier passed' || p_transaction_identifier);
                END IF;

                RETURN;
            END IF;
            -- Fix bug 2167545-1 Cost Group Update(11) is calling label printing through TM
            -- not manually, add 11 in the following group.

        --Fix for Bug 4891916
        --Modified the condition for business flow for cycle count by checking
        --for the business flow 8 and transaction_identifier as 5

        ELSIF p_label_type_info.business_flow_code IN
                           (/*8,*/ 9, 11, 12, 14, 19, 18, 22, 23, 27, 28, 29, 34)--Bug 5928736 - Removed business flow 7
            OR (p_label_type_info.business_flow_code = 8 AND p_transaction_identifier = 5)
        THEN
            select transaction_type_id into l_transaction_type
            from mtl_material_transactions_temp
            where transaction_temp_id = p_transaction_id;  --bug 6646793

            OPEN mmtt_material_cur;
            FETCH mmtt_material_cur INTO l_inventory_item_id
                                   , l_organization_id
                                   , l_lot_number
                                   , l_cost_group_id
                                   , l_xfr_cost_group_id  /* Added for the bug # 4686024 */
                                   , l_project_id
                                   , l_task_id
                                   , l_quantity
                                   , l_uom
                                   , l_revision
                                   , l_from_subinventory
                                   , l_to_subinventory
                                   , l_from_locator_id
                                   , l_to_locator_id
                                   , l_secondary_uom_code -- ADDED for invconv
                                   , l_secondary_transaction_qty; -- invocnv

            IF mmtt_material_cur%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    TRACE(' No record found in MMTT for given txn_temp_id: ' || p_transaction_id);
                END IF;

                CLOSE mmtt_material_cur;
                RETURN;
            ELSE
                --bug 6646793
                if (l_transaction_type = 82 and p_label_type_info.business_flow_code = 12)then
                   select nvl (mmtt.transaction_quantity,mtlt.transaction_quantity) into l_mmtt_quantity
                   from mtl_material_transactions_temp mmtt , mtl_transaction_lots_temp  mtlt
                   where mmtt.transaction_temp_id = p_transaction_id
                   and mtlt.transaction_temp_id = mmtt.transaction_temp_id;

                   SELECT Nvl(Sum(primary_transaction_quantity),0) INTO l_moqd_quantity
                   FROM mtl_onhand_quantities_detail moqd , mtl_material_transactions_temp mmtt , mtl_transaction_lots_temp mtlt
                   WHERE  mmtt.transaction_temp_id = p_transaction_id
                   and mtlt.transaction_temp_id = mmtt.transaction_temp_id
                   and moqd.lot_number = mtlt.lot_number
                   and nvl(mmtt.lpn_id , -999) = nvl(moqd.lpn_id , -999)
                   and moqd.inventory_item_id = mmtt.inventory_item_id
                   and moqd.organization_id  = mmtt.organization_id
                   and moqd.subinventory_code = mmtt.subinventory_code
                   and NVL(moqd.locator_id , -999 ) = NVL(mmtt.locator_id ,-999);
                   l_quantity := l_moqd_quantity + l_mmtt_quantity ;
                end if;
                -- end of fix for bug 6646793

                /* For transfer and drop transaction, should get printer with the to_subinventory,
                   for other cases, use the to_subinevntory */
                IF p_label_type_info.business_flow_code IN (14, 19, 29) THEN --Bug 5928736 - Removed business flow 7
                    l_subinventory_code  := l_to_subinventory;
                    l_locator_id         := l_to_locator_id;
                ELSE
                    l_subinventory_code  := l_from_subinventory;
                    l_locator_id         := l_from_locator_id;

                    --Bug 4891916. For cycle count, opened the cursor to fetch values for
                    --cycle count header name and counter.

                    IF p_label_type_info.business_flow_code = 8  THEN
                        OPEN cc_det_approval;

                        FETCH cc_det_approval
                        INTO l_cycle_count_name
                            ,l_requestor;

                        IF cc_det_approval%NOTFOUND THEN
                            IF (l_debug = 1) THEN
                                TRACE(' No record found in MCCE for given txn_temp_id: ' || p_transaction_id);
                            END IF;

                            CLOSE cc_det_approval;
                        END IF; --End of cursor not found condition
                    END IF; --End of business flow=8 condition
                --End of fix for Bug 4891916
                END IF;
            END IF;--End of mmtt_material_cursor not found

            --Bug 4891916- Added the condition to open the cursor to fetch from mcce
            --by checking for business flow 8 and transaction identifier 4
        ELSIF (p_label_type_info.business_flow_code = 8 AND p_transaction_identifier= 4)  THEN --from entry

            IF (l_debug = 1) THEN
                TRACE(' IN the condition for bus flow 8 and pti 4 ');
            END IF;

            OPEN mcce_material_cur ;

            FETCH mcce_material_cur
            INTO l_inventory_item_id
              , l_organization_id
              , l_lot_number
              , l_cost_group_id
              , l_quantity
              , l_uom
              , l_revision
              , l_subinventory_code
              , l_locator_id
              , l_cycle_count_name
              , l_requestor ;

            IF (l_debug = 1) THEN
                TRACE('Values fetched from cursor:');
                TRACE('Values of l_inventory_item_id:'|| l_inventory_item_id);
                TRACE('Values of l_organization_id:'  || l_organization_id);
                TRACE('Values of l_lot_number:'       || l_lot_number);
                TRACE('Values of l_cost_group_id:'    || l_cost_group_id);
                TRACE('Values of l_quantity:'         || l_quantity);
                TRACE('Values of l_uom:'              || l_uom);
                TRACE('Values of l_revision:'         || l_revision);
                TRACE('Values of l_subinventory:'     || l_subinventory_code);
                TRACE('Values of l_locator_id:'       || l_locator_id);
                TRACE('Values of l_cycle_count_name:' || l_cycle_count_name);
                TRACE('Values of l_counter:'          || l_requestor);
            END IF;

            IF mcce_material_cur%NOTFOUND THEN

                IF (l_debug = 1) THEN
                    TRACE(' No record found in mcce_material_cur for given cycle_count_id ' || p_transaction_id);
                END IF;

                CLOSE mcce_material_cur;

                RETURN;
            END IF;

            /* End of fix for Bug 4891916 */

            -- Fix for bug 2356935, add Sub and Loc information for Material label for Inventory Putaway
            -- Fix for bug 2390460,  for subinventory transfer, use the following cursor instead of mmtt_material_cur
        ELSIF p_label_type_info.business_flow_code IN (15, 30, 7) THEN --Bug 5928736 - Added the business flow 7
            OPEN inv_putaway_material_cur;
            FETCH inv_putaway_material_cur INTO l_inventory_item_id
                                          , l_organization_id
                                          , l_lot_number
                                          , l_cost_group_id
                                          , l_project_id
                                          , l_task_id
                                          , l_quantity
                                          , l_secondary_transaction_qty
                                          , l_uom
                                          , l_secondary_uom_code
                                          , l_revision
                                          , l_subinventory_code
                                          , l_locator_id;

            IF inv_putaway_material_cur%NOTFOUND THEN
                IF (l_debug = 1) THEN
                    TRACE(' No record found for Inventory Putaway for given txn_temp_id: ' || p_transaction_id);
                END IF;

                CLOSE inv_putaway_material_cur;
                RETURN;
            END IF;
        ELSE
            IF (l_debug = 1) THEN
                TRACE('No material label will be printed');
            END IF;

            RETURN;
        END IF;
    ELSE
        -- On demand, get information from input_param
        -- for transactions which don't have a mmtt row in the table,
        -- they will also call in a manual mode, they are
        -- 5 LPN Correction/Update
        -- 10 Material Status update

        l_organization_id    := p_input_param.organization_id;
        l_inventory_item_id  := p_input_param.inventory_item_id;
        l_lot_number         := p_input_param.lot_number;
        l_cost_group_id      := p_input_param.cost_group_id;
        l_xfr_cost_group_id  := p_input_param.transfer_cost_group_id; /* Added for the bug # 4686024*/
        l_project_id         := p_input_param.project_id;
        l_task_id            := p_input_param.task_id;
        l_revision           := p_input_param.revision;
        l_quantity           := p_input_param.transaction_quantity;
        l_uom                := p_input_param.transaction_uom;
    END IF; --  End transaction_is is not null

    -- Get cost group, project and task

     /* Added for the bug # 4686024 */

    IF (l_debug = 1) THEN
        TRACE('l_xfr_cost_group_id is ' || l_xfr_cost_group_id || ','  ||
              'l_cost_group_id is ' || l_cost_group_id);
    END IF;

    IF (l_xfr_cost_group_id IS NOT NULL) THEN
        OPEN c_cost_group(l_xfr_cost_group_id);
        FETCH c_cost_group INTO l_cost_group;

        IF c_cost_group%NOTFOUND THEN
            l_cost_group  := '';
        END IF;

        CLOSE c_cost_group;
    ELSE
        OPEN c_cost_group(l_cost_group_id);
        FETCH c_cost_group INTO l_cost_group;

        IF c_cost_group%NOTFOUND THEN
            l_cost_group  := '';
        END IF;

        CLOSE c_cost_group;
    END IF;

    /* End of fix for bug # 4686024 */

    IF (l_debug = 1) THEN
      TRACE('** in PVT1.get_variable_dataa ** , start ');
    END IF;

    l_material_input_index    := 1;

    -- Getting lot Number
    IF  (l_material_input IS NOT NULL)
        AND (l_material_input.COUNT <> 0) THEN
        l_lot_number  := l_material_input(l_material_input_index).lot_number;
        l_quantity    := l_material_input(l_material_input_index).lot_quantity;
    END IF;

    IF (l_debug = 1) THEN
        TRACE('Before the While Loop');
    END IF;

    item_fetch_cntr           := 1;
    l_label_index             := 1;
    l_content_rec_index       := 0;
    l_prev_format_id          := -999;
    l_prev_sub                := '####';
    l_printer                 := p_label_type_info.default_printer;

    WHILE ((l_inventory_item_id IS NOT NULL)
           OR (l_item_description IS NOT NULL)
          ) LOOP

    --Bug 8230113 Code-block shifted inside the while loop to check the po_distributions for all the po_lines.
    /* Start of fix for 4916450 */
    IF (l_debug = 1) THEN
        TRACE('Routing Id: ' || l_routing_header_id || ' Transaction id: ' || p_transaction_id);
    END IF;
    IF ( l_is_wms_org = FALSE AND l_routing_header_id <> 3 ) THEN
        OPEN pod_project_task;
        FETCH pod_project_task INTO l_project_id, l_task_id;
        IF pod_project_task%NOTFOUND THEN
            l_project_id  := NULL;
            l_task_id := NULL;
        ELSE
            IF (l_debug = 1) THEN
                TRACE('Project: ' || l_project_id || 'Task: ' || l_task_id);
            END IF;

            LOOP
                FETCH pod_project_task INTO l_next_project_id, l_next_task_id;
                EXIT WHEN pod_project_task%NOTFOUND;
                IF (l_debug = 1) THEN
                    TRACE('Next Project: ' || l_next_project_id || 'Next Task: ' || l_next_task_id);
                END IF;
                IF NVL(l_project_id,-9999) <> NVL(l_next_project_id,-9999) OR
                    NVL(l_task_id,-9999) <> NVL(l_next_task_id,-9999) THEN
                    IF (l_debug = 1) THEN
                        TRACE('There are multiple distributions for the same po line and shipment');
                    END IF;
                    l_project_id  := NULL;
                    l_task_id := NULL;
                    EXIT;
                END IF;
            END LOOP;
        END IF;

        IF (l_debug = 1) THEN
            TRACE('Project: ' || l_project_id || 'Task: ' || l_task_id);
        END IF;
        l_next_project_id := NULL;
        l_next_task_id := NULL;
        CLOSE pod_project_task;
    END IF;

    /* End of fix for 4916450 */

    -- Start of fix for 8533306. Fetching the project/task id from PO_Distributions_all for the Direct Delivery.
    IF ( l_is_wms_org = FALSE AND l_routing_header_id = 3 ) THEN

        BEGIN

            IF (Nvl(l_project_id,-1) = -1 AND Nvl(l_task_id,-1) = -1) THEN

                SELECT project_id , task_id
                INTO l_project_id, l_task_id
                FROM po_distributions_all
                WHERE po_distribution_id = l_po_distribution_id;

                IF (l_debug = 1) THEN
                    TRACE('Project: ' || l_project_id || 'Task: ' || l_task_id);
                END IF;

            ELSE

                IF (l_debug = 1) THEN
                    TRACE('Project: ' || l_project_id || 'Task: ' || l_task_id);
                END IF;

            END IF;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                l_project_id := NULL ;
                l_task_id    := NULL ;

            IF (l_debug = 1) THEN
                TRACE('In exception no data found');
            END IF;

        END;

    END IF;
    -- End of fix for 8533306

    OPEN c_project_enabled(l_organization_id);
        FETCH c_project_enabled INTO l_is_pjm_org;
        IF c_project_enabled%NOTFOUND THEN
            IF (l_debug = 1) THEN
                trace( 'Organization id ' || l_organization_id || 'is not a PJM Org.');
            END IF;
        END IF;
    CLOSE c_project_enabled;

    /*
     * The following code has been added so that the c_project and c_task cursors will be opened
     * only if the organization is project enabled.
     */
    IF l_is_pjm_org = 'Y' THEN
        -- Fix for 4907062. Fetching project number along with project name
        OPEN c_project;
        FETCH c_project INTO l_project_name, l_project_number;

        IF c_project%NOTFOUND THEN
            l_project_name  := '';
        END IF;

        CLOSE c_project;

        -- Fix for 4907062. Fetching task number along with project name
        OPEN c_task;
        FETCH c_task INTO l_task_name, l_task_number;

        IF c_task%NOTFOUND THEN
            l_task_name  := '';
        END IF;

        CLOSE c_task;
    END IF;
    --End of Fix for Bug 8230113
        l_material_data  := '';

        -- Bug 7423016, resetting the value of l_is_expense_item to False
        --   at the begining of every record fetched from txn cursors like rt_material_cur, etc.
        --   l_is_expense_item will be set inside loop over c_material_cur cursor.
        l_is_expense_item := FALSE;

        /* Bug 6504959- The fix through bug 4708750 is incorrectly fetching from the
           cursor c_material_cur even if the item_id is null.

        FOR v_material_cur IN c_material_cur(
                              l_organization_id
                            , l_inventory_item_id
                            , l_lot_number
                            ) LOOP

            -- Start of Fix for the bug # 4708752

            EXIT WHEN l_is_expense_item;

            IF (l_inventory_item_id IS NULL) THEN
                l_is_expense_item := TRUE;
            END IF;

            -- End of fix for the bug # 4708752 */

        OPEN c_material_cur(    l_organization_id
                              , l_inventory_item_id
                              , l_lot_number
                            );

        LOOP
            IF (l_debug = 1) THEN
                TRACE('Inside Inner Loop');
            END IF;
            EXIT WHEN l_is_expense_item;

            IF  l_inventory_item_id is not null THEN
                IF (l_debug = 1) THEN
                    TRACE('Fetching c_material_cur');
                END IF;
                FETCH c_material_cur
                INTO v_material_cur;

                EXIT WHEN c_material_cur%NOTFOUND;
            ELSE
                -- Bug 7423016, clearing v_material_cur to avoid printing of labels with last record's item details for expense item.
                -- Fetching organization code when item is an expense item.
                v_material_cur := null;
                SELECT organization_code
                INTO   l_organization_code
                FROM   mtl_parameters
                WHERE  organization_id = l_organization_id;

                --Bug 8632067, Fetching uom_code for expense item
                IF (l_uom IS NULL AND p_label_type_info.business_flow_code IN (1,2,3)) THEN

                    BEGIN

                        IF p_label_type_info.business_flow_code IN (1,3) THEN

                            SELECT uom_code
                            INTO   l_uom
                            FROM   rcv_transactions
                            WHERE  transaction_id = l_rcv_transaction_id;

                        END IF;

                        IF p_label_type_info.business_flow_code = 2 THEN

                            SELECT muom.uom_code
                            INTO   l_uom
                            FROM   rcv_transactions rt,
                                   mtl_units_of_measure_vl  muom
                            WHERE  rt.unit_of_measure = muom.unit_of_measure
                            AND    rt.transaction_id = l_rcv_transaction_id;

                        END IF;

                    EXCEPTION
                        WHEN No_Data_Found THEN
                            IF (l_debug = 1) THEN
                            TRACE('In exception no data found for UOM');
                            END IF;
                    END;
                END IF;
                --Bug 8632067


                IF (l_debug = 1) THEN
                    TRACE('inventory_item_id is null');
                END IF;
                l_is_expense_item := TRUE;
            END IF;

            /* End of fix for Bug 6504959 */

            l_content_rec_index := l_content_rec_index + 1;

            IF (l_debug = 1) THEN
                TRACE(' In Loop '|| l_content_rec_index || '^New Label^');
                TRACE( 'orgId=' || l_organization_id
                    || ',itemId=' || l_inventory_item_id
                    || ',itemDesc=' || l_item_description
                    || ',lot=' || l_lot_number
                    || ',qty=' || l_quantity
                    || ',uom=' || l_uom
                    || ',rev=' || l_revision
                    || ',Parent Lot=' -- invconv fabdi start
                    || l_parent_lot_number
                    || ',Expiration Action Date=' || l_expiration_action_date
                    || ',Origination type=' || l_origination_type
                    || ',Hold date=' || l_hold_date
                    || ',Secondary Qty=' || l_secondary_transaction_qty
                    || 'Secondary UOM=' || l_secondary_uom_code
                    || 'Expiration action code=' || l_expiration_action_code-- invconv fabdi end
                  );
                TRACE( ',fromSub=' || l_from_subinventory
                    || ',fromLoc=' || l_from_locator_id
                    || ',toSub=' || l_to_subinventory
                    || ',toLoc=' || l_to_locator_id
                    || ',sub=' || l_subinventory_code
                    || ',loc=' || l_locator_id
                  );
                TRACE( 'cg=' || l_cost_group
                    || ',project=' || l_project_name
                    || ',task=' || l_task_name
                  );
            END IF;

            l_label_status := INV_LABEL.G_SUCCESS;

            IF (l_debug = 1) THEN
                TRACE('Apply Rules engine for format,'
                    || ',manual_format_id=' || p_label_type_info.manual_format_id
                    || ',manual_format_name=' || p_label_type_info.manual_format_name
                  );
            END IF;

            /* R12 insert a record into wms_label_requests entity to
               call the label rules engine to get appropriate label
               In this call if this happens to be for the label-set, the record
               from wms_label_request will be deleted inside following API*/

            inv_label.get_format_with_rule(
              p_document_id                => p_label_type_info.label_type_id
            , p_label_format_id            => p_label_type_info.manual_format_id
            , p_organization_id            => l_organization_id
            , p_inventory_item_id          => l_inventory_item_id
            , p_lot_number                 => l_lot_number
            , p_revision                   => l_revision
            , p_subinventory_code          => l_subinventory_code
            , p_locator_id                 => l_locator_id
            , p_business_flow_code         => p_label_type_info.business_flow_code
            --, p_printer_name               => l_printer --not used post R12
            , p_last_update_date           => SYSDATE
            , p_last_updated_by            => fnd_global.user_id
            , p_creation_date              => SYSDATE
            , p_created_by                 => fnd_global.user_id
            , -- Added for Bug 2748297 Start
              p_supplier_id                => l_vendor_id
            , p_supplier_site_id           => l_vendor_site_id
            , -- End
              x_return_status              => l_return_status
            , x_label_format_id            => l_label_format_set_id
            , x_label_format               => l_label_format
            , x_label_request_id           => l_label_request_id
            );

            IF l_return_status <> 'S' THEN
              fnd_message.set_name('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
              fnd_msg_pub.ADD;
              l_label_format_set_id        := p_label_type_info.default_format_id;
              l_label_format               := p_label_type_info.default_format_name;
            END IF;

            IF (l_debug = 1) THEN
              TRACE('did apply label ' || l_label_format || ',' || l_label_format_set_id
                || ',req_id ' || l_label_request_id
              );
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
                     p_document_id                => p_label_type_info.label_type_id
                     , p_label_format_id            =>  l_label_formats_in_set.label_format_id --considers manual printer also
                     , p_organization_id            => l_organization_id
                     , p_inventory_item_id          => l_inventory_item_id
                     , p_lot_number                 => l_lot_number
                     , p_revision                   => l_revision
                     , p_subinventory_code          => l_subinventory_code
                     , p_locator_id                 => l_locator_id
                     , p_business_flow_code         => p_label_type_info.business_flow_code
                     --, p_printer_name               => l_printer --not used post R12
                     , p_last_update_date           => SYSDATE
                     , p_last_updated_by            => fnd_global.user_id
                     , p_creation_date              => SYSDATE
                     , p_created_by                 => fnd_global.user_id
                     , -- Added for Bug 2748297 Start
                     p_supplier_id                => l_vendor_id
                     , p_supplier_site_id           => l_vendor_site_id -- End
                     , p_use_rule_engine            => 'N' --------------------------Rules ENgine will NOT get called
                    ,  x_return_status              => l_return_status
                    , x_label_format_id            => l_label_format_id
                    , x_label_format               => l_label_format
                    , x_label_request_id           => l_label_request_id
                    );

                    IF l_return_status <> 'S' THEN
                        fnd_message.set_name('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
                        fnd_msg_pub.ADD;
                        l_label_format_id     := p_label_type_info.default_format_id;
                        l_label_format        := p_label_type_info.default_format_name;
                    END IF;


                    IF (l_debug = 1) THEN
                        TRACE('did apply label ' || l_label_format|| ',' || l_label_format_id
                               || ',req_id '|| l_label_request_id
                               );
                    END IF;


                ELSE --IT IS LABEL FORMAT
                    --Just use the format-id returned
                    l_label_format_id :=  l_label_formats_in_set.label_format_id ;
                END IF;



                IF (l_debug = 1) THEN
                   TRACE('Geting expected printer based on label_format_id :'||l_label_format_id);
                END IF;


                -- IF clause Added for Add format/printer for manual request
                IF p_label_type_info.manual_printer IS NULL THEN
                    -- The p_label_type_info.manual_printer is the one  passed from the manual page.
                    -- As per the design, if a printer is passed from the manual page, then we use that printer irrespective.
                    IF  (l_subinventory_code IS NOT NULL)
                        AND (l_subinventory_code <> l_prev_sub) THEN
                        IF (l_debug = 1) THEN
                          TRACE('getting printer with sub '|| l_subinventory_code);
                        END IF;

                        BEGIN
                            wsh_report_printers_pvt.get_printer
                             (p_concurrent_program_id        => p_label_type_info.label_type_id
                              , p_user_id                    => fnd_global.user_id
                              , p_responsibility_id          => fnd_global.resp_id
                              , p_application_id             => fnd_global.resp_appl_id
                              , p_organization_id            => l_organization_id
                              , p_zone                       => l_subinventory_code
                              , p_format_id                  => l_label_format_id --added in R12
                              , x_printer                    => l_printer
                              , x_api_status                 => l_api_status
                              , x_error_message              => l_error_message
                              );

                            IF l_api_status <> 'S' THEN
                                IF (l_debug = 1) THEN
                                    TRACE('Error in calling get_printer, set printer '
                                       || 'as default printer, err_msg:' || l_error_message
                                        );
                                END IF;

                                l_printer  := p_label_type_info.default_printer;
                            END IF;
                        EXCEPTION
                            WHEN OTHERS THEN
                                l_printer  := p_label_type_info.default_printer;
                        END;

                        l_prev_sub  := l_subinventory_code;
                    END IF;
                ELSE
                    IF (l_debug = 1) THEN
                        TRACE('Set printer as Manual Printer passed in:'
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

                        -- Changed for R12 RFID project
                        inv_label.get_variables_for_format
                          (  x_variables              => l_selected_fields
                           , x_variables_count        => l_selected_fields_count
                           , x_is_variable_exist      => l_is_epc_exist
                           , p_format_id              => l_label_format_id
                           , p_exist_variable_name    => 'EPC'
                           );

                        l_prev_format_id  := l_label_format_id;

                        IF (l_selected_fields_count = 0)
                            OR (l_selected_fields.COUNT = 0) THEN
                            IF (l_debug = 1) THEN
                                TRACE('no fields defined for this format: '
                                || l_label_format || ',' || l_label_format_id
                                );
                                TRACE('######## GOING TO THE NEXT LABEL####');
                            END IF;
                            GOTO nextlabel;
                        END IF;

                        IF (l_debug = 1) THEN
                            TRACE('   Found selected_fields for format '
                                || l_label_format || ', num=' || l_selected_fields_count
                            );
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
                , p_revision                   => l_revision );



                --R12 changes for RFID  compliance project
                l_epc_loop_count := 1;

                IF (l_gtin_enabled AND l_quantity > 1) THEN
                    SELECT FLOOR(l_quantity)
                    INTO   l_quantity_floor
                    FROM   DUAL;


                    IF (l_debug =1) THEN
                        trace('l_quantity_floor :'||l_quantity_floor);
                        trace('l_quantity :'||l_quantity);
                        trace('l_is_epc_exist :'||l_is_epc_exist );
                    END IF;


                    -- IF quantity IS NON-INTEGER THEN
                    -- derive _QUANTITY = transacted Qty.
                    IF (l_quantity = l_quantity_floor) THEN --Integer quantity

                        --check for GTIN and EPC
                        IF  l_is_epc_exist = 'Y'  THEN
                            l_gtin_epc_quantity := 1; --to assign to "_QUANTITY"
                            l_epc_loop_count   := l_quantity; --each time different epc will be generated
                            l_quantity          := 1;
                        ELSE
                            l_gtin_epc_quantity := l_quantity; --to assign to "_QUANTITY"
                            l_quantity          := 1;
                        END IF;

                    ELSE -- Fraction qty : Do not print GTIN

                        l_gtin_epc_quantity := 1;
                        l_gtin_desc := NULL;
                        l_gtin      := NULL;
                    END IF;

                END IF;


                --Start epc LOOP
                --This loop added in R12 for RFID compliance project
                FOR i IN 1..l_epc_loop_count  LOOP --loop  to generate  different EPC


                    -- Added in R12 RFID compliance project
                    -- Get RFID/EPC related information for a format
                    -- Only do this if EPC is a field included in the format
                    IF l_is_epc_exist = 'Y' THEN
                        IF (l_debug =1) THEN
                            trace('Generating EPC');
                        END IF;

                        --we ned seperate label request corresponding to each EPC

                        IF i > 1 THEN --for first request, a record in wms_label_request has
                            --already been posted IN last call TO .get_format_with_rule
                            IF (l_debug =1) THEN
                                trace('*****************passing l_label_format_id :' ||l_label_format_id);
                            END IF;

                            inv_label.get_format_with_rule
                                (
                                 p_document_id                  => p_label_type_info.label_type_id
                                  , p_label_format_id           => l_label_formats_in_set.label_format_id --keep current format id
                                 , p_organization_id            => l_organization_id
                                 , p_inventory_item_id          => l_inventory_item_id
                                 , p_lot_number                 => l_lot_number
                                 , p_revision                   => l_revision
                                 , p_subinventory_code          => l_subinventory_code
                                 , p_locator_id                 => l_locator_id
                                 , p_business_flow_code         => p_label_type_info.business_flow_code
                                 --, p_printer_name               => l_printer --not used post R12
                                 , p_last_update_date           => SYSDATE
                                 , p_last_updated_by            => fnd_global.user_id
                                 , p_creation_date              => SYSDATE
                                 , p_created_by                 => fnd_global.user_id
                                 , -- Added for Bug 2748297 Start
                                 p_supplier_id                  => l_vendor_id
                                 , p_supplier_site_id           => l_vendor_site_id -- End
                                 , p_use_rule_engine            => 'N' ------Rules Engine will NOT get called
                                ,  x_return_status              => l_return_status
                                , x_label_format_id             => l_label_format_id
                                , x_label_format                => l_label_format
                                , x_label_request_id            => l_label_request_id --A NEW label request id
                                );

                            IF l_return_status <> 'S' THEN
                                fnd_message.set_name('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
                                fnd_msg_pub.ADD;
                                l_label_format_id     := p_label_type_info.default_format_id;
                                l_label_format        := p_label_type_info.default_format_name;
                            END IF;


                            IF (l_debug = 1) THEN
                                TRACE('did apply label ' || l_label_format || ',' || l_label_format_id
                                   || ',req_id ' || l_label_request_id
                                   );
                            END IF;
                        END IF;


                        -- Now call generate EPC for each new label request
                        BEGIN

                            -- Added in R12 RFID compliance
                            -- New field : EPC
                            -- When generate_epc API returns E (expected error) or U(expected error),
                            --   it sets the error message, but generate xml with EPC as null

                            /* if l_quantity is fraction in primary_uom, it will not
                               find correcponding GTIN for fraction qty , and NO EPC will
                               be generated but for Non-primary UOM fraction qty it
                               might finda match as teh number might be integer afer
                               converting it to primary_qty*/

                            WMS_EPC_PVT.generate_epc
                              (p_org_id             => l_organization_id,
                               p_label_type_id      => p_label_type_info.label_type_id, -- 1
                               p_group_id           => inv_label.EPC_group_id,
                               p_label_format_id    => l_label_format_id,
                               p_item_id            => l_inventory_item_id,  --For Material label
                               p_txn_qty            => l_quantity,    --For Material Label
                               p_txn_uom            => l_uom,         --For Material Label
                               p_label_request_id   => l_label_request_id,
                               p_business_flow_code => p_label_type_info.business_flow_code,
                               x_epc                => l_epc,
                               x_return_status      => l_epc_ret_status, -- S / E / U
                               x_return_mesg        => l_epc_ret_msg
                               );

                            IF (l_debug = 1) THEN
                                trace('Called generate_epc with ');
                                trace('l_inventory_item_id='||l_inventory_item_id||',p_group_id='||inv_label.epc_group_id);
                                trace('l_quantity='||l_quantity||',l_uom='||l_uom);
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
                                  trace('Got unexpected error from generate_epc');
                                  trace('Set label status as Error and l_epc = null');
                               END IF;

                            ELSIF l_epc_ret_status = 'E' THEN
                               -- Expected error
                               l_epc := null;
                               IF(l_debug = 1) THEN
                                  trace('Got expected error from generate_epc, msg');
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
                    l_material_data := l_material_data || label_b;

                    IF l_label_format <> NVL(p_label_type_info.default_format_name, '@@@') THEN
                        l_material_data := l_material_data || ' _FORMAT="' || l_label_format || '"';
                    END IF;

                    IF  (l_printer IS NOT NULL)
                        AND (l_printer <> NVL(p_label_type_info.default_printer, '###')) THEN
                        l_material_data := l_material_data || ' _PRINTERNAME="' || l_printer || '"';
                    END IF;

                    -- Bug 7497507, printing _QUANTITY only when item is gtin enabled.
                    -- Earlier, _QUANTITY was always getting stamped to 1, in case of non-gtin enabled items.
                    -- _QUANTITY in label tag overrides _QUANTITY in labels tag.
                    -- Hence while printing no. of copies greater than 1, it always use to print only 1 label.
                    IF (l_gtin_enabled = TRUE) THEN
                        l_material_data  := l_material_data || ' _QUANTITY="' || l_gtin_epc_quantity || '"';
                    END IF;
                    l_material_data  :=  l_material_data || tag_e;

                    IF (l_debug = 1) THEN
                        TRACE('Starting assign variables, ');
                    END IF;

                    l_column_name_list     := 'Set variables for ';

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
                                trace('Custom Labels Trace [INVLAP1B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
                                trace('Custom Labels Trace [INVLAP1B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
                                trace('Custom Labels Trace [INVLAP1B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
                                trace('Custom Labels Trace [INVLAP1B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
                                trace('Custom Labels Trace [INVLAP1B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
                            END IF;
                            l_sql_stmt := l_selected_fields(i).sql_stmt;
                            IF (l_debug = 1) THEN
                                trace('Custom Labels Trace [INVLAP1B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
                            END IF;
                            l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
                            IF (l_debug = 1) THEN
                                trace('Custom Labels Trace [INVLAP1B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);

                            END IF;
                            BEGIN
                                IF (l_debug = 1) THEN
                                    trace('Custom Labels Trace [INVLAP1B.pls]: At Breadcrumb 1');
                                    trace('Custom Labels Trace [INVLAP1B.pls]: LABEL_REQUEST_ID : ' || l_label_request_id);
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
                                      trace('Custom Labels Trace [INVLAP1B.pls]: At Breadcrumb 2');
                                      trace('Custom Labels Trace [INVLAP1B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
                                      trace('Custom Labels Trace [INVLAP1B.pls]: WARNING: NULL value returned by the custom SQL Query.');
                                      trace('Custom Labels Trace [INVLAP1B.pls]: l_custom_sql_ret_status is set to : ' || l_custom_sql_ret_status);
                                    END IF;
                                ELSIF c_sql_stmt%rowcount=0 THEN
                                    IF (l_debug = 1) THEN
                                        trace('Custom Labels Trace [INVLAP1B.pls]: At Breadcrumb 3');
                                        trace('Custom Labels Trace [INVLAP1B.pls]: WARNING: No row returned by the Custom SQL query');
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
                                        trace('Custom Labels Trace [INVLAP1B.pls]: At Breadcrumb 4');
                                        trace('Custom Labels Trace [INVLAP1B.pls]: ERROR: Multiple values returned by the Custom SQL query');
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
                                      trace('Custom Labels Trace [INVLAP1B.pls]: At Breadcrumb 5');
                                      trace('Custom Labels Trace [INVLAP1B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
                                    END IF;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                                    fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
                                    fnd_msg_pub.ADD;
                                    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
                                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                            END;
                            IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLAP1B.pls]: At Breadcrumb 6');
                               trace('Custom Labels Trace [INVLAP1B.pls]: Before assigning it to l_material_data');
                            END IF;
                            l_material_data  :=   l_material_data
                                               || variable_b
                                               || l_selected_fields(i).variable_name
                                               || '">'
                                               || l_sql_stmt_result
                                               || variable_e;
                            l_sql_stmt_result := NULL;
                            l_sql_stmt        := NULL;
                            IF (l_debug = 1) THEN
                               trace('Custom Labels Trace [INVLAP1B.pls]: At Breadcrumb 7');
                               trace('Custom Labels Trace [INVLAP1B.pls]: After assigning it to l_material_data');
                               trace('Custom Labels Trace [INVLAP1B.pls]: --------------------------REPORT END-------------------------------------');
                            END IF;
                        ------------------------End of this change for Custom Labels project code--------------------
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'current_date' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || inv_label.g_date
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'current_time' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || inv_label.g_time
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'request_user' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || inv_label.g_user
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'client_item' THEN		-- Added for LSP Project, bug 9087971
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.client_item
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_description' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || nvl(v_material_cur.item_description,l_item_description) /* Modified for the bug # 4708752*/
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'revision' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.revision
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_number' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_lot_number
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_status' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_status
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_expiration_date' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_expiration_date
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'quantity' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_quantity
                                                || variable_e;
                        --Bug#8632067 Substituting l_uom for v_material_cur.uom
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'uom' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_uom
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'cost_group' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.cost_group
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'customer_purchase_order' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_purchase_order
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_attribute_category' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_attribute_category
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute1' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute1
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute2' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute2
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute3' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute3
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute4' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute4
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute5' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute5
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute6' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute6
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute7' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute7
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute8' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute8
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute9' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute9
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute10' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute10
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute11' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute11
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute12' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute12
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute13' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute13
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute14' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute14
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute15' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute15
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute16' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute16
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute17' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute17
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute18' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute18
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute19' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute19
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute20' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_c_attribute20
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute1' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_d_attribute1
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute2' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_d_attribute2
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute3' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_d_attribute3
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute4' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_d_attribute4
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute5' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_d_attribute5
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute6' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_d_attribute6
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute7' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_d_attribute7
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute8' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_d_attribute8
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute9' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_d_attribute9
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute10' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_d_attribute10
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute1' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_n_attribute1
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute2' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_n_attribute2
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute3' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_n_attribute3
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute4' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_n_attribute4
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute5' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_n_attribute5
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute6' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_n_attribute6
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute7' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_n_attribute7
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute8' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_n_attribute8
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute9' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_n_attribute9
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute10' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_n_attribute10
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) =
                                                                         'lot_country_of_origin' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_country_of_origin
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_grade_code' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_grade_code
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_origination_date' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_origination_date
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_date_code' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_date_code
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_change_date' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_change_date
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_age' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_age
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_retest_date' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_retest_date
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_maturity_date' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_maturity_date
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_item_size' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_item_size
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_color' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_color
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_volume' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_volume
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_volume_uom' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_volume_uom
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_place_of_origin' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_place_of_origin
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_best_by_date' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_best_by_date
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_length' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_length
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_length_uom' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_length_uom
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_recycled_cont' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_recycled_cont
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_thickness' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_thickness
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_thickness_uom' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_thickness_uom
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_width' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_width
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_width_uom' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_width_uom
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_curl' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_curl
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_vendor' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.lot_vendor
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_hazard_class' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_hazard_class
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) =
                                                                       'item_attribute_category' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute_category
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute1' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute1
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute2' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute2
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute3' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute3
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute4' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute4
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute5' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute5
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute6' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute6
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute7' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute7
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute8' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute8
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute9' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute9
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute10' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute10
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute11' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute11
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute12' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute12
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute13' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute13
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute14' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute14
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute15' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.item_attribute15
                                                || variable_e;
                        --START of Fix For Bug: 4907062
                        -- Project_Number and Task Number fields are added newly.
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'project_number' THEN
                               l_material_data  :=    l_material_data
                                                   || variable_b
                                                   || l_selected_fields(i).variable_name
                                                   || '">'
                                                   || v_material_cur.project_number
                                                   || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'task_number' THEN
                               l_material_data  :=    l_material_data
                                                   || variable_b
                                                   || l_selected_fields(i).variable_name
                                                   || '">'
                                                   || v_material_cur.task_number
                                                   || variable_e;
                        --END of Fix For Bug: 4907062
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'project' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.project
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'task' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.task
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'receipt_num' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_receipt_number
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'po_line_num' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_po_line_number
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'quan_ordered' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_quantity_ordered
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'supp_part_num' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_supplier_part_number
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'supp_name' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_supplier_name
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'supp_site' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_supplier_site
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'requestor' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_requestor
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'deliver_to_loc' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_deliver_to_location
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'loc_id' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_location_code
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'note_to_receiver' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_note_to_receiver
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'rec_routing' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_routing_name
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'po_num' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_purchase_order
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_code' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.subinventory_code
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'locator' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.LOCATOR
                                                || variable_e;
                        -- Bug 7423016, changed l_organization_id with l_organization_code.
                        /* Modified for the bug # 4708752*/
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'organization' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || nvl(v_material_cur.ORGANIZATION, l_organization_code)
                                                || variable_e;
                        --Bug 4891916- Added for the field Cycle Count Name */
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'cycle_count_name' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">' || l_cycle_count_name
                                                || variable_e;
                        --End of fix for Bug 4891916

                        -- Added for UCC 128 J Bug #3067059
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'gtin' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_gtin
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'gtin_description' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_gtin_desc
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'wip_entity_name' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_wip_entity_name
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'wip_description' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_wip_description
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'wip_operation_seq_num' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_wip_op_seq_num
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'osp_department_code' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_osp_dept_code
                                                || variable_e;
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'bom_resource' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || l_bom_resource_code
                                                || variable_e;

                        -- invconv fabdi start
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'parent_lot_number' THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.parent_lot_number
                                                || variable_e;

                        ELSIF LOWER(l_selected_fields(i).column_name) = 'expiration_action_date'  THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.expiration_action_date
                                                || variable_e;

                        ELSIF LOWER(l_selected_fields(i).column_name) = 'origination_type'  THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || get_origination_type (v_material_cur.origination_type)
                                                || variable_e;

                        ELSIF LOWER(l_selected_fields(i).column_name) = 'hold_date'  THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.hold_date
                                                || variable_e;

                        ELSIF LOWER(l_selected_fields(i).column_name) = 'secondary_transaction_quantity'  THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.secondary_quantity
                                                || variable_e;

                        ELSIF LOWER(l_selected_fields(i).column_name) = 'secondary_uom_code'  THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.secondary_uom
                                                || variable_e;

                        ELSIF LOWER(l_selected_fields(i).column_name) = 'expiration_action_code'  THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.expiration_action_code
                                                || variable_e;

                        ELSIF LOWER(l_selected_fields(i).column_name) = 'supplier_lot_number'  THEN
                            l_material_data  :=    l_material_data
                                                || variable_b
                                                || l_selected_fields(i).variable_name
                                                || '">'
                                                || v_material_cur.supplier_lot_number
                                                || variable_e;
                            -- invconv fabdi end

                            -- Added for R12 RFID Compliance project
                            -- New field : EPC
                            -- EPC is generated once for each LPN
                        ELSIF LOWER(l_selected_fields(i).column_name) = 'epc' THEN
                            l_material_data  :=    l_material_data
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

                    l_material_data                                     := l_material_data || label_e;
                    x_variable_content(l_label_index).label_content     := l_material_data;
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
                    END IF;
                    -- Fix for bug: 4179593 End
                    IF (l_CustSqlErrFlagSet) THEN
                       x_variable_content(l_label_index).label_status      := l_custom_sql_ret_status;
                    END IF;
                    x_variable_content(l_label_index).error_message     := l_custom_sql_ret_msg|| ' ' || l_label_err_msg;
                    ------------------------End of this changes for Custom Labels project code---------------
                    l_label_index                                       := l_label_index + 1;

                    IF (l_debug = 1) THEN
                        TRACE('l_column_name_list"'||l_column_name_list);
                    END IF;

                    --Clear all required variable values
                    l_material_data    := '';
                    l_custom_sql_ret_status := NULL;
                    l_custom_sql_ret_msg    := NULL;

                END LOOP; --END  epc LOOP



                --Clear all required variable values
                l_material_data    := '';
                l_custom_sql_ret_status := NULL;
                l_custom_sql_ret_msg    := NULL;


                IF (l_debug = 1) THEN
                    TRACE(' Done with Label formats in the current label-set');
                END IF;

            END LOOP; --for formats in label-set

            <<nextlabel>>

            l_material_data    := '';
            l_label_request_id := NULL;
            ------------------------Start of changes for Custom Labels project code------------------
            l_custom_sql_ret_status := NULL;
            l_custom_sql_ret_msg    := NULL;
            ------------------------End of this changes for Custom Labels project code---------------
        END LOOP;

        /* Bug 6504959-Closing the cursor */
        IF c_material_cur%ISOPEN THEN
            CLOSE c_material_cur;
        END IF;

        IF (p_transaction_id IS NOT NULL) THEN --Added for Bug 9475084
          IF l_patch_level = 1  AND (p_label_type_info.business_flow_code IN (1,2,3,4)) THEN
              IF (l_debug = 1) THEN
                 TRACE(' Within patchset level J');
                 TRACE(' If business flow code in 1, 2, 3,4 within patchset J');
              END IF;

              /* Patchset J - Use the new cursor rt_material_cur. This cursor replaces
               * RTI_MATERIAL_LPN_CUR and RTI_MATERIAL_MTLT_CUR in patchset J, due to receiving tables
               * changes. Also, earlier, receiving transaction records were created separately for
               * INV and WMS organizations, which is not the case now.
               * Open the cursor rt_material_cur. This cursor fetches data irrespective
               * of whether it is a WMS org or INV org.
               */
              -- Bug 4516067, created new cursor for putaway and deliver
              -- Fetch from rt_material_cur or rt_putaway_deliver_cur based on business flow code
              IF (p_label_type_info.business_flow_code IN (1,2)) THEN
                  FETCH rt_material_cur INTO
                                     l_inventory_item_id
                                   , l_organization_id
                                   , l_lot_number
                                   , l_cost_group_id
                                   , l_project_id
                                   , l_task_id
                                   -- Added by joabraha for bug 3472150
                                   , l_receipt_number
                                   --
                                   , l_quantity
                                       , l_secondary_transaction_qty
                                   , l_uom
                                       , l_secondary_uom_code
                                   , l_revision
                                   , l_purchase_order
                                   , l_shipment_num
                                   , l_po_line_number
                                   --Bug 8230113
                                   , l_po_line_id
                                   , l_quantity_ordered
                                   , l_supplier_part_number
                                   , l_vendor_id
                                   , l_supplier_name
                                   , l_vendor_site_id
                                   , l_supplier_site
                                   , l_requestor
                                   , l_deliver_to_location
                                   , l_location_code
                                   , l_note_to_receiver
                                   , l_routing_name
                                   , l_item_description
                                   , l_subinventory_code
                                   , l_locator_id
                                   , l_wip_entity_name
                                   , l_wip_description
                                   , l_wip_op_seq_num
                                   , l_osp_dept_code
                                   , l_bom_resource_id
                                   , l_lpn_context
                                   , l_lpn_id
                                   , l_routing_header_id --bug 4916450
                                     --8533306
                                   , l_po_distribution_id
                                    --Bug 8632067
                                   , l_rcv_transaction_id ;

                  IF rt_material_cur%NOTFOUND THEN
                      IF (l_debug = 1) THEN
                         TRACE(' No more material found for this given Interface Transaction ID:' || p_transaction_id);
                      END IF;
                      -- Fix for 4348641
                      -- Following 2 assignment statements that were previously
                      -- inside the above IF-ENDIF block is now moved outside.
                      l_inventory_item_id := NULL;
                      l_item_description := NULL;
                      CLOSE rt_material_cur;
                     --RETURN;
                  ELSE
                      IF (l_debug = 1) THEN
                          TRACE(' Got next Item for  Interface Transaction ID:' || p_transaction_id);
                      END IF;
                  END IF;
              ELSIF (p_label_type_info.business_flow_code IN (3,4)) THEN
                  FETCH rt_putaway_deliver_cur INTO
                                         l_inventory_item_id
                                       , l_organization_id
                                       , l_lot_number
                                       , l_cost_group_id
                                       , l_project_id
                                       , l_task_id
                                       -- Added by joabraha for bug 3472150
                                       , l_receipt_number
                                       --
                                       , l_quantity
                                       , l_secondary_transaction_qty
                                       , l_uom
                                       , l_secondary_uom_code
                                       , l_revision
                                       , l_purchase_order
                                       , l_shipment_num
                                       , l_po_line_number
                                       -- Bug 8648128
                                       , l_po_line_id
                                       , l_quantity_ordered
                                       , l_supplier_part_number
                                       , l_vendor_id
                                       , l_supplier_name
                                       , l_vendor_site_id
                                       , l_supplier_site
                                       , l_requestor
                                       , l_deliver_to_location
                                       , l_location_code
                                       , l_note_to_receiver
                                       , l_routing_name
                                       , l_item_description
                                       , l_subinventory_code
                                       , l_locator_id
                                       , l_wip_entity_name
                                       , l_wip_description
                                       , l_wip_op_seq_num
                                       , l_osp_dept_code
                                       , l_bom_resource_id
                                       , l_lpn_context
                                       , l_lpn_id
                                       , l_routing_header_id --bug 4916450
                                       --Bug 8648128
                                       , l_po_distribution_id
                                       -- Bug 8632067
                                       , l_rcv_transaction_id;

                  IF rt_putaway_deliver_cur%NOTFOUND THEN
                      IF (l_debug = 1) THEN
                          TRACE(' No more material found for this given Interface Transaction ID:' || p_transaction_id);
                      END IF;
                      -- Fix for 4277218 Begin:
                      -- Following 2 assignment statements that were previously
                      -- inside the above IF-ENDIF block is now moved outside.
                      l_inventory_item_id := NULL;
                      l_item_description := NULL;
                      -- Fix for 4277218 End
                      CLOSE rt_putaway_deliver_cur;
                      --RETURN;
                  ELSE
                      IF (l_debug = 1) THEN
                          TRACE(' Got next Item for  Interface Transaction ID:' || p_transaction_id);
                      END IF;
                  END IF;
              END IF;

              FETCH get_resource_dept_code_cur INTO l_bom_resource_code, l_osp_dept_code;
              IF get_resource_dept_code_cur%NOTFOUND THEN
                  IF (l_debug = 1) THEN
                      TRACE(' No more Resource and Dept code found for Resource ID: ' || l_bom_resource_id);
                  END IF;
              END IF;

              IF (l_debug = 1) THEN
                  TRACE(' End of Patchset J check');
              END IF;

          ELSE
              -- This fetch for receiving is for multiple lots.
              IF ((p_label_type_info.business_flow_code IN (1))
                  AND (l_is_wms_org = TRUE)
                  AND l_patch_level = 0
              ) THEN
                  -- Receipt and Inspection, WMS org, getting the next lot number from l_material_input
                  FETCH rti_material_lpn_cur INTO l_inventory_item_id
                                        , l_organization_id
                                        , l_lot_number
                                        , l_cost_group_id
                                        , l_project_id
                                        , l_task_id
                                        -- Added by joabraha for bug 3472150
                                        , l_receipt_number
                                        --
                                        , l_quantity
                                        , l_uom
                                        , l_revision
                                        , l_lpn_id
                                        , l_purchase_order
                                        , l_po_line_number
                                        , l_quantity_ordered
                                        , l_supplier_part_number
                                        , l_vendor_id
                                        , l_supplier_name
                                        , l_vendor_site_id
                                        , l_supplier_site
                                        , l_requestor
                                        , l_deliver_to_location
                                        , l_location_code
                                        , l_note_to_receiver
                                        , l_routing_name
                                        , l_item_description
                                        , l_subinventory_code
                                        , l_locator_id
                                        , l_wip_entity_name
                                        , l_wip_description
                                        , l_wip_op_seq_num
                                        , l_osp_dept_code
                                        , l_bom_resource_id;

                  IF rti_material_lpn_cur%NOTFOUND THEN
                      CLOSE rti_material_lpn_cur;
                      l_inventory_item_id  := NULL;
                      l_item_description   := NULL;
                  END IF;
              ELSIF ((p_label_type_info.business_flow_code IN (2))
                  AND (l_is_wms_org = TRUE)
                  AND l_patch_level = 0
              ) THEN
                  -- Receipt and Inspection, WMS org, getting the next lot number from l_material_input
                  FETCH rti_material_lpn_inspec_cur INTO l_inventory_item_id
                                               , l_organization_id
                                               , l_lot_number
                                               , l_cost_group_id
                                               , l_project_id
                                               , l_task_id
                                               -- Added by joabraha for bug 3472150
                                               , l_receipt_number
                                               --
                                               , l_quantity
                                               , l_uom
                                               , l_revision
                                               , l_lpn_id
                                               , l_purchase_order
                                               , l_po_line_number
                                               , l_quantity_ordered
                                               , l_supplier_part_number
                                               , l_vendor_id
                                               , l_supplier_name
                                               , l_vendor_site_id
                                               , l_supplier_site
                                               , l_requestor
                                               , l_deliver_to_location
                                               , l_location_code
                                               , l_note_to_receiver
                                               , l_routing_name
                                               , l_item_description
                                               , l_subinventory_code
                                               , l_locator_id
                                               , l_wip_entity_name
                                               , l_wip_description
                                               , l_wip_op_seq_num
                                               , l_osp_dept_code
                                               , l_bom_resource_id;

                  IF rti_material_lpn_inspec_cur%NOTFOUND THEN
                      CLOSE rti_material_lpn_inspec_cur;
                      l_inventory_item_id  := NULL;
                      l_item_description   := NULL;
                  END IF;
              ELSIF   ((p_label_type_info.business_flow_code IN (3))
                  AND (l_is_wms_org = TRUE)
                      )
                      OR ((p_label_type_info.business_flow_code IN (1, 2, 4))
                  AND (l_is_wms_org = FALSE)
                  )
                  AND l_patch_level = 0 THEN
                  -- For putaway in WMS org and Receipt, Inspection, Delivery in INV org
                  -- Obtain information from RTI and MTLT (if applicable)
                  -- Receipt Inspection: No lot and seial information, print item information from RTI
                  -- Delivery: RTI + MTLT

                  FETCH rti_material_mtlt_cur INTO l_inventory_item_id
                                         , l_revision
                                         , l_lot_number
                                         , l_organization_id
                                         , l_cost_group_id
                                         , l_project_id
                                         , l_task_id
                                         , l_quantity
                                         , l_uom
                                         , l_purchase_order
                                         , l_po_line_number
                                         , l_quantity_ordered
                                         , l_supplier_part_number
                                         , l_vendor_id
                                         , l_supplier_name
                                         , l_vendor_site_id
                                         , l_supplier_site
                                         , l_requestor
                                         , l_deliver_to_location
                                         , l_location_code
                                         , l_note_to_receiver
                                         , l_routing_name
                                         , l_item_description
                                         , l_subinventory_code
                                         , l_locator_id
                                         , l_wip_entity_name
                                         , l_wip_description
                                         , l_wip_op_seq_num
                                         , l_osp_dept_code
                                        , l_bom_resource_id;

                  IF rti_material_mtlt_cur%NOTFOUND THEN
                      CLOSE rti_material_mtlt_cur;
                      l_inventory_item_id  := NULL;
                      l_item_description   := NULL;
                  END IF;
                  -- Fix bug 2167545-2, for Pick Drop(19), should use cursor mmtt_material_cur
                  -- remove from this group, add to the mmtt_material_cur group
              ELSIF (p_label_type_info.business_flow_code IN (6)) THEN
                  FETCH wdd_material_cur INTO l_inventory_item_id
                                    , l_organization_id
                                    , l_lot_number
                                    , l_cost_group_id
                                    , l_project_id
                                    , l_task_id
                                    , l_quantity
                                    , l_uom
                                    , l_revision
                                    , l_subinventory_code
                                    , l_locator_id;

                  IF wdd_material_cur%NOTFOUND THEN
                      CLOSE wdd_material_cur;
                      l_inventory_item_id  := NULL;
                  END IF;
                  -- Bug 3823140, for WIP completion, also uses cursor mmtt_material_receipt_cur
              ELSIF p_label_type_info.business_flow_code IN (13,26) THEN
                  FETCH mmtt_material_receipt_cur INTO l_inventory_item_id
                                             , l_organization_id
                                             , l_lot_number
                                             , l_cost_group_id
                                             , l_project_id
                                             , l_task_id
                                             , l_quantity
                                             , l_uom
                                             , l_secondary_transaction_qty -- invconv
                                             , l_secondary_uom_code -- invconv
                                             , l_revision
                                             , l_attribute_category
                                             , l_c_attribute1
                                             , l_c_attribute2
                                             , l_c_attribute3
                                             , l_c_attribute4
                                             , l_c_attribute5
                                             , l_c_attribute6
                                             , l_c_attribute7
                                             , l_c_attribute8
                                             , l_c_attribute9
                                             , l_c_attribute10
                                             , l_c_attribute11
                                             , l_c_attribute12
                                             , l_c_attribute13
                                             , l_c_attribute14
                                             , l_c_attribute15
                                             , l_c_attribute16
                                             , l_c_attribute17
                                             , l_c_attribute18
                                             , l_c_attribute19
                                             , l_c_attribute20
                                             , l_d_attribute1
                                             , l_d_attribute2
                                             , l_d_attribute3
                                             , l_d_attribute4
                                             , l_d_attribute5
                                             , l_d_attribute6
                                             , l_d_attribute7
                                             , l_d_attribute8
                                             , l_d_attribute9
                                             , l_d_attribute10
                                             , l_n_attribute1
                                             , l_n_attribute2
                                             , l_n_attribute3
                                             , l_n_attribute4
                                             , l_n_attribute5
                                             , l_n_attribute6
                                             , l_n_attribute7
                                             , l_n_attribute8
                                             , l_n_attribute9
                                             , l_n_attribute10
                                             , l_territory_code
                                             , l_grade_code
                                             , l_origination_date
                                             , l_date_code
                                             , l_change_date
                                             , l_age
                                             , l_retest_date
                                             , l_maturity_date
                                             , l_item_size
                                             , l_color
                                             , l_volume
                                             , l_volume_uom
                                             , l_place_of_origin
                                             , l_best_by_date
                                             , l_length
                                             , l_length_uom
                                             , l_recycled_content
                                             , l_thickness
                                             , l_thickness_uom
                                             , l_width
                                             , l_width_uom
                                             , l_curl_wrinkle_fold
                                             , l_vendor_name
                                             , l_subinventory_code
                                             , l_locator_id
                                             , l_wip_entity_name -- Fix For Bug: 4907062
                                             , l_wip_description -- Fix For Bug: 4907062
                                             , l_parent_lot_number -- invconv fabdi start
                                             , l_expiration_action_date
                                             , l_origination_type
                                             , l_hold_date
                                             , l_expiration_action_code
                                             , l_supplier_lot_number ; -- invconv fabdi end


                  IF mmtt_material_receipt_cur%NOTFOUND THEN
                      CLOSE mmtt_material_receipt_cur;
                      l_inventory_item_id  := NULL;
                  END IF;
              ELSIF p_label_type_info.business_flow_code = 20 THEN
                  --      Pack/Unpack/Split LPN
                  FETCH material_lpn_cur INTO l_inventory_item_id
                                    , l_organization_id
                                    , l_lot_number
                                    , l_cost_group_id
                                    , l_project_id
                                    , l_task_id
                                    , l_quantity
                                    , l_uom
                                    , l_revision
                                    , l_from_subinventory
                                    , l_to_subinventory
                                    , l_from_locator_id
                                    , l_to_locator_id
                                    , l_secondary_transaction_qty -- invconv
                                    , l_secondary_uom_code; -- invconv


                  IF material_lpn_cur%NOTFOUND THEN
                      l_inventory_item_id  := NULL;
                      CLOSE material_lpn_cur;
                  END IF;
              ELSIF p_label_type_info.business_flow_code IN (21) THEN
                  -- Ship Confirm
                  FETCH wda_material_cur INTO l_inventory_item_id
                                    , l_organization_id
                                    , l_lot_number
                                    , l_cost_group_id
                                    , l_project_id
                                    , l_task_id
                                    , l_quantity
                                    , l_uom
                                    , l_revision
                                    , l_subinventory_code
                                    , l_locator_id;

                  IF wda_material_cur%NOTFOUND THEN
                      CLOSE wda_material_cur;
                      l_inventory_item_id  := NULL;
                  END IF;
              ELSIF p_label_type_info.business_flow_code IN (22) THEN
                  -- Cartonization
                  FETCH c_get_pkg_items_content INTO l_organization_id
                                           , l_inventory_item_id
                                           , l_revision
                                           , l_lot_number
                                           , l_quantity;

                  IF c_get_pkg_items_content%NOTFOUND THEN
                      IF (l_debug = 1) THEN
                          TRACE(' No more records found for Header ID/package mode in the WPH:');
                      END IF;

                      l_inventory_item_id  := NULL;
                      CLOSE c_get_pkg_items_content;
                  ELSE
                      item_fetch_cntr  := item_fetch_cntr + 1;

                      IF (l_debug = 1) THEN
                          TRACE('Item(s) fetched'|| item_fetch_cntr);
                      END IF;
                  END IF;
              -- Bug 3823140, use mmtt_material_receipt_cur instead to get new lot information
              /*ELSIF p_label_type_info.business_flow_code IN (26) THEN
                  -- WIP Completion
                  FETCH wip_material_cur INTO l_inventory_item_id
                                    , l_organization_id
                                    , l_lot_number
                                    , l_cost_group_id
                                    , l_project_id
                                    , l_task_id
                                    , l_quantity
                                    , l_uom
                                    , l_revision
                                    , l_subinventory_code
                                    , l_locator_id;

                  IF wip_material_cur%NOTFOUND THEN
                      TRACE(' No more records found for transaction_temp_id in MMTT');
                      l_inventory_item_id  := NULL;
                      CLOSE wip_material_cur;
                  ELSE
                      TRACE(' More Lot Items Retreived');
                      TRACE(
                             ' wip_material_cur '
                          || ', Item ID=' || l_inventory_item_id
                          || ', Organization ID=' || l_organization_id
                          || ', Lot Number=' || l_lot_number
                          || ', Project ID=' || l_project_id
                          || ', Cost Group ID=' || l_cost_group_id
                          || ', Task ID=' || l_task_id
                          || ', Transaction Quantity=' || l_quantity
                          || ', Transaction UOM=' || l_uom
                          || ', Item Revision=' || l_revision
                          || ', Subinventory Code=' || l_subinventory_code
                          || ', Locator ID=' || l_locator_id
                      );
                  END IF; */
              ELSIF p_label_type_info.business_flow_code = 37 THEN
                  -- Manufacturing Cross-Dock(37)
                  FETCH wip_material_cur INTO l_inventory_item_id
                                    , l_organization_id
                                    , l_lot_number
                                    , l_cost_group_id
                                    , l_project_id
                                    , l_task_id
                                    , l_quantity
                                    , l_uom
                                    , l_revision
                                    , l_subinventory_code
                                    , l_locator_id;

                  IF wip_material_cur%NOTFOUND THEN
                      TRACE(' No more records found for transaction_temp_id in MMTT');
                      l_inventory_item_id  := NULL;
                      CLOSE wip_material_cur;
                  ELSE
                      TRACE(' More Items Retreived');
                      TRACE( ' wip_material_cur '
                          || ', Item ID=' || l_inventory_item_id
                          || ', Organization ID=' || l_organization_id
                          || ', Lot Number=' || l_lot_number
                          || ', Project ID=' || l_project_id
                          || ', Cost Group ID=' || l_cost_group_id
                          || ', Task ID=' || l_task_id
                          || ', Transaction Quantity=' || l_quantity
                          || ', Transaction UOM=' || l_uom
                          || ', Item Revision=' || l_revision
                          || ', Subinventory Code=' || l_subinventory_code
                          || ', Locator ID=' || l_locator_id
                        );
                  END IF;
              ELSIF p_label_type_info.business_flow_code IN (33) THEN
                  -- Flow Completion


                  IF l_transaction_identifier = 1 THEN
                      FETCH flow_material_curs_mmtt INTO l_inventory_item_id
                                             , l_organization_id
                                             , l_lot_number
                                             , l_cost_group_id
                                             , l_project_id
                                             , l_task_id
                                             , l_quantity
                                             , l_uom
                                             , l_revision
                                             , l_subinventory_code
                                             , l_locator_id;

                      IF flow_material_curs_mmtt%NOTFOUND THEN
                          CLOSE flow_material_curs_mmtt;
                          l_inventory_item_id  := NULL;
                      END IF;
                  ELSIF l_transaction_identifier = 2 THEN
                      FETCH flow_material_curs_mti INTO l_inventory_item_id
                                            , l_organization_id
                                            , l_lot_number
                                            , l_cost_group_id
                                            , l_project_id
                                            , l_task_id
                                            , l_quantity
                                            , l_uom
                                            , l_revision
                                            , l_subinventory_code
                                            , l_locator_id;

                      IF flow_material_curs_mti%NOTFOUND THEN
                          CLOSE flow_material_curs_mti;
                          l_inventory_item_id  := NULL;
                      END IF;
                  ELSIF l_transaction_identifier = 3 THEN
                      FETCH flow_material_curs_mol INTO l_inventory_item_id
                                            , l_organization_id
                                            , l_lot_number
                                            , l_cost_group_id
                                            , l_project_id
                                            , l_task_id
                                            , l_quantity
                                            , l_uom
                                            , l_revision
                                            , l_subinventory_code
                                            , l_locator_id;

                      IF flow_material_curs_mol%NOTFOUND THEN
                          CLOSE flow_material_curs_mol;
                          l_inventory_item_id  := NULL;
                      END IF;
                  ELSE
                      IF (l_debug = 1) THEN
                          TRACE( ' Invalid transaction_identifier passed' || p_transaction_identifier);
                      END IF;

                      RETURN;
                  END IF;
              -- Fix bug 2167545-1: Cost Group Update(11) is calling label printing through TM
              --   add 11 to this group.
              -- Fix bug 2167545-2: Pick Drop(19) is also using this cursor. add to this group.

              --Bug 4891916. Modified the condition for business flow for cycle count by
              --checking for the business flow 8 and transaction_identifier as 5
              ELSIF p_label_type_info.business_flow_code IN
                             ( /*8,*/ 9, 11, 12, 13, 14, 18, 19, 22, 23, 27, 28, 29, 34)--Bug 5928736- Removed business flow 7
                  OR(p_label_type_info.business_flow_code = 8 AND p_transaction_identifier = 5) THEN

                  FETCH mmtt_material_cur INTO l_inventory_item_id
                                     , l_organization_id
                                     , l_lot_number
                                     , l_cost_group_id
                                     , l_xfr_cost_group_id  /* Added for the bug # 4686024 */
                                     , l_project_id
                                     , l_task_id
                                     , l_quantity
                                     , l_uom
                                     , l_revision
                                     , l_from_subinventory
                                     , l_to_subinventory
                                     , l_from_locator_id
                                     , l_to_locator_id
                                     , l_secondary_uom_code -- added for invconv
                                     , l_secondary_transaction_qty; -- added for invconv

                  IF mmtt_material_cur%NOTFOUND THEN
                      l_inventory_item_id  := NULL;
                      CLOSE mmtt_material_cur;
                  ELSE
                      IF p_label_type_info.business_flow_code IN (14, 19, 29) THEN --Bug 5928736- Removed business flow 7
                          l_subinventory_code  := l_to_subinventory;
                          l_locator_id         := l_from_locator_id;
                      ELSE
                          l_subinventory_code  := l_from_subinventory;
                          l_locator_id         := l_to_locator_id;

                          --Bug 4891916. For cycle count, opened the cursor to fetch values for
                          --cycle count header name and counter
                          IF p_label_type_info.business_flow_code = 8  THEN
                              OPEN cc_det_approval ;

                              FETCH cc_det_approval
                              INTO l_cycle_count_name
                                  , l_requestor ;

                              IF cc_det_approval%NOTFOUND THEN
                                  IF (l_debug = 1) THEN
                                      TRACE(' No record found in MCCE for given txn_temp_id: ' || p_transaction_id);
                                  END IF;

                                  CLOSE cc_det_approval;
                              END IF;--End of cursor not found condition

                          END IF; --End of business flow=8 condition
                          --End of fix for Bug 4891916

                      END IF;
                  END IF;

              --Bug 4891916- Added the condition to open the cursor to fetch from mcce
              --by checking for business flow 8 and transaction identifier 4
              ELSIF (p_label_type_info.business_flow_code = 8 AND p_transaction_identifier= 4)  THEN    --from entry
                  IF (l_debug = 1) THEN
                      TRACE(' IN the condition for bus flow 8 and pti 4 ');
                  END IF;
                  FETCH mcce_material_cur
                  INTO l_inventory_item_id
                     , l_organization_id
                     , l_lot_number
                     , l_cost_group_id
                     , l_quantity
                     , l_uom
                     , l_revision
                     , l_subinventory_code
                     , l_locator_id
                     , l_cycle_count_name
                     , l_requestor ;

                  IF (l_debug = 1) THEN
                      TRACE('Values fetched from cursor:');
                      TRACE('Values of l_inventory_item_id:'|| l_inventory_item_id);
                      TRACE('Values of l_organization_id:'  || l_organization_id);
                      TRACE('Values of l_lot_number:'       || l_lot_number);
                      TRACE('Values of l_cost_group_id:'    || l_cost_group_id);
                      TRACE('Values of l_quantity:'         || l_quantity);
                      TRACE('Values of l_uom:'              || l_uom);
                      TRACE('Values of l_revision:'         || l_revision);
                      TRACE('Values of l_subinventory:'     || l_subinventory_code);
                      TRACE('Values of l_locator_id:'       || l_locator_id);
                      TRACE('Values of l_cycle_count_name:' || l_cycle_count_name);
                      TRACE('Values of l_counter:'          || l_requestor);
                  END IF;

                  IF mcce_material_cur%NOTFOUND THEN
                      IF (l_debug = 1) THEN
                          TRACE(' No record found in mcce_material_cur for given cycle_count_id ' || p_transaction_id);
                      END IF;
                      CLOSE mcce_material_cur;
                      RETURN;
                  END IF;
                  /* End of fix for Bug 4891916 */

              ELSIF p_label_type_info.business_flow_code IN (15, 30, 7) THEN --Bug 5928736 -Added the business flow 7
                  FETCH inv_putaway_material_cur INTO l_inventory_item_id
                                            , l_organization_id
                                            , l_lot_number
                                            , l_cost_group_id
                                            , l_project_id
                                            , l_task_id
                                            , l_quantity
                                            , l_secondary_transaction_qty
                                            , l_uom
                                            , l_secondary_uom_code
                                            , l_revision
                                            , l_subinventory_code
                                            , l_locator_id;

                  IF inv_putaway_material_cur%NOTFOUND THEN
                      CLOSE inv_putaway_material_cur;
                      l_inventory_item_id  := NULL;
                  END IF;
              ELSE
                  l_inventory_item_id  := NULL;
                  l_item_description   := NULL;
              END IF;
          END IF;
        ELSE--Adding Else Part for If p_transaction_id IS NOT NULL Bug 9475084
          l_inventory_item_id  := NULL;
          l_item_description   := NULL;
        END IF;
        IF (l_debug = 1) THEN
            TRACE(' Outside of IF..THEN...ELSE... ENDIF; Check for patchset level J..');
            TRACE(' Just Before END LOOP ..');
        END IF;

    END LOOP;

    IF (wdd_material_cur%ISOPEN) THEN
      CLOSE wdd_material_cur;
    END IF;

    IF (wda_material_cur%ISOPEN) THEN
      CLOSE wda_material_cur;
    END IF;

    IF (rti_material_lpn_cur%ISOPEN) THEN
      CLOSE rti_material_lpn_cur;
    END IF;

    IF (rti_material_mtlt_cur%ISOPEN) THEN
      CLOSE rti_material_mtlt_cur;
    END IF;

    /*IF (wip_material_cur%ISOPEN) THEN
      CLOSE wip_material_cur;
    END IF;*/

    IF (flow_material_curs_mmtt%ISOPEN) THEN
      CLOSE flow_material_curs_mmtt;
    END IF;

    IF (flow_material_curs_mti%ISOPEN) THEN
      CLOSE flow_material_curs_mti;
    END IF;

    IF (flow_material_curs_mol%ISOPEN) THEN
      CLOSE flow_material_curs_mol;
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
      x_variable_content  :=
                     x_variable_content || l_variable_data_tbl(i).label_content;
    END LOOP;
  END get_variable_data;

  /*****************************************************************************
   *  This function is used for printing labels at receiving                   *
   *  This function adds all the interface transaction ID's to the PL/SQL table*
   *  which means that any interface transaction ID existing in this table is  *
   *  already printed.                                                         *
   *****************************************************************************/
  FUNCTION check_rti_id(
    p_rti_id     IN NUMBER
  , p_lot_number IN VARCHAR2
  , p_rev        IN VARCHAR2
  )
    RETURN VARCHAR2 IS
    l_label_counter NUMBER      := 0;
    l_return_flag   VARCHAR2(1) := 'N';
    l_debug         NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_label_counter  := g_rcv_label_print_rec_tb.COUNT;

    IF (l_debug = 1) THEN
      TRACE('**** New Function Call****');
      TRACE('**** l_label_counter=' || l_label_counter
         || ',p_rti_id=' || p_rti_id
         || ',p_lot_number=' || p_lot_number
         || ',p_rev=' || p_rev
      );
    END IF;

    IF (g_rcv_label_print_rec_tb.COUNT = 0)
       OR (l_label_counter = 0) THEN
      IF (l_debug = 1) THEN
        TRACE('no interface transaction IDs in the record structure table ');
      END IF;

      -- This is the first record and so blindly add the interface transaction id to the
      -- table and give out a status of 'N'
      l_label_counter                                                     := l_label_counter + 1;
      g_rcv_label_print_rec_tb(l_label_counter).interface_transaction_id  := p_rti_id;
      g_rcv_label_print_rec_tb(l_label_counter).lot_number                := p_lot_number;
      g_rcv_label_print_rec_tb(l_label_counter).item_rev                  := p_rev;

      -- This loop is to display the contents of the PL/SQL table in the log file.
      FOR i IN 1 .. l_label_counter LOOP
        IF (l_debug = 1) THEN
          TRACE( '****** first g_rcv_label_print_rec_tb(' || i || ')' || '.'
              || 'interface_transaction_id=' || g_rcv_label_print_rec_tb(i).interface_transaction_id
              || ',lot_number=' || g_rcv_label_print_rec_tb(i).lot_number
              || ',item_rev  ' || g_rcv_label_print_rec_tb(i).item_rev
          );
        END IF;
      END LOOP;

      IF (l_debug = 1) THEN
        TRACE('l_return_flag is '|| l_return_flag);
      END IF;

      RETURN l_return_flag;
    ELSE
      IF (l_debug = 1) THEN
        TRACE('interface transaction IDs exist in the record structure');
        TRACE('No of Records in Structure '|| l_label_counter);
      END IF;

      FOR i IN 1 .. l_label_counter LOOP
        IF (g_rcv_label_print_rec_tb(i).interface_transaction_id = p_rti_id
            AND NVL(g_rcv_label_print_rec_tb(i).lot_number, 'aaa') = NVL(p_lot_number, 'aaa')
            AND NVL(g_rcv_label_print_rec_tb(i).item_rev, 'aaa') = NVL(p_rev, 'aaa')
           ) THEN
          IF (l_debug = 1) THEN
            TRACE( 'interface transaction ID ' || p_rti_id
                || ', lot_number ' || g_rcv_label_print_rec_tb(i).lot_number
                || ', item_rev  ' || g_rcv_label_print_rec_tb(i).item_rev
                || 'has been already considered for label printing  '
            );
          END IF;

          -- This loop is to display the contents of the PL/SQL table in the log file.
          FOR j IN 1 .. l_label_counter LOOP
            IF (l_debug = 1) THEN
              TRACE( '****** Second g_rcv_label_print_rec_tb(' || j || ')' || '.'
                  || 'interface_transaction_id=' || g_rcv_label_print_rec_tb(j).interface_transaction_id
                  || ',lot_number=' || g_rcv_label_print_rec_tb(j).lot_number
                  || ',item_rev=' || g_rcv_label_print_rec_tb(j).item_rev
              );
            END IF;
          END LOOP;

          l_return_flag  := 'Y';

          IF (l_debug = 1) THEN
            TRACE('l_return_flag is '|| l_return_flag);
          END IF;

          RETURN l_return_flag;
        END IF;
      END LOOP;

      IF (l_debug = 1) THEN
        TRACE('Label is not yet printed for interface transaction ID '|| p_rti_id);
        TRACE('Adding Record to the PL/SQL table ');
      END IF;

      g_rcv_label_print_rec_tb(l_label_counter + 1).interface_transaction_id  := p_rti_id;
      g_rcv_label_print_rec_tb(l_label_counter + 1).lot_number                := p_lot_number;
      g_rcv_label_print_rec_tb(l_label_counter + 1).item_rev                  := p_rev;
      -- Updated Label Counter value.
      l_label_counter                                                         := g_rcv_label_print_rec_tb.COUNT;

      -- This loop is to display the contents of the PL/SQL table in the log file.
      FOR i IN 1 .. l_label_counter LOOP
        IF (l_debug = 1) THEN
          TRACE( '****** Third g_rcv_label_print_rec_tb('|| i || ')' || '.'
              || 'interface_transaction_id=' || g_rcv_label_print_rec_tb(i).interface_transaction_id
              || ',lot_number=' || g_rcv_label_print_rec_tb(i).lot_number
              || ',item_rev=' || g_rcv_label_print_rec_tb(i).item_rev
          );
        END IF;
      END LOOP;

      IF (l_debug = 1) THEN
        TRACE('l_return_flag is '|| l_return_flag);
      END IF;

      RETURN l_return_flag;
    END IF;
  END;
END inv_label_pvt1;

/
