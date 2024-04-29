--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT4" AS
/* $Header: INVLAP4B.pls 120.34.12010000.20 2010/04/13 17:15:36 sfulzele ship $ */

LABEL_B    CONSTANT VARCHAR2(50) := '<label';
LABEL_E    CONSTANT VARCHAR2(50) := '</label>'||fnd_global.local_chr(10);
VARIABLE_B  CONSTANT VARCHAR2(50) := '<variable name= "';
VARIABLE_E  CONSTANT VARCHAR2(50) := '</variable>'||fnd_global.local_chr(10);
TAG_E    CONSTANT VARCHAR2(50)  := '>'||fnd_global.local_chr(10);
l_debug number;

-- Bug 2795525 : This mask is used to mask all date fields.
G_DATE_FORMAT_MASK VARCHAR2(100) := INV_LABEL.G_DATE_FORMAT_MASK;

PROCEDURE trace(p_message IN VARCHAR2) iS
BEGIN
     inv_label.trace(p_message, 'LABEL_LPN_CONT');
END trace;

PROCEDURE get_variable_data(
  x_variable_content   OUT NOCOPY INV_LABEL.label_tbl_type
,  x_msg_count    OUT NOCOPY NUMBER
,  x_msg_data    OUT NOCOPY VARCHAR2
,  x_return_status    OUT NOCOPY VARCHAR2
,  x_var_content     IN LONG DEFAULT NULL
,  p_label_type_info  IN INV_LABEL.label_type_rec
,  p_transaction_id  IN NUMBER
,  p_input_param    IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,  p_transaction_identifier IN NUMBER
) IS

  p_organization_id     MTL_PARAMETERS.ORGANIZATION_ID%TYPE := null;
  p_inventory_item_id     MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE := null;
  p_lot_number      MTL_LOT_NUMBERS.LOT_NUMBER%TYPE :=null;
  p_revision      MTL_MATERIAL_TRANSACTIONS_TEMP.REVISION%TYPE := null;
  p_qty        MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_QUANTITY%TYPE := null;
  p_uom        MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_UOM%TYPE := null;
  p_cost_group_id      MTL_MATERIAL_TRANSACTIONS_TEMP.COST_GROUP_ID%TYPE := null;

  l_subinventory_code     MTL_MATERIAL_TRANSACTIONS_TEMP.SUBINVENTORY_CODE%TYPE := null;
  l_locator_id       MTL_MATERIAL_TRANSACTIONS_TEMP.LOCATOR_ID%TYPE :=null;
  l_locator       VARCHAR2(204):=null;
  l_printer_sub    VARCHAR2(30) := null;

   l_project_id              NUMBER;  --- bug 8430171
   l_task_id                 NUMBER;  ---bug 8430171
   l_project_name            VARCHAR2(204);
   l_task_name                VARCHAR2(204);
   l_header_id       NUMBER := NULL;
  l_packaging_mode     NUMBER := NULL;
  l_package_id       NUMBER := NULL;
  l_content_volume_uom_code   VARCHAR2(3);
  l_content_volume     NUMBER;
  l_gross_weight_uom_code   VARCHAR2(3);
  l_gross_weight       NUMBER;
  l_inventory_item_id     NUMBER;
  l_parent_package_id     NUMBER;
  l_pack_level       NUMBER;
  l_parent_lpn_id     NUMBER;
  l_parent_lpn      VARCHAR2(204);
  l_outermost_lpn_id     NUMBER;
  l_tare_weight       NUMBER;
  l_tare_weight_uom_code     VARCHAR2(3);
  cartonization_flag     NUMBER := 0;
  l_max_pack_level    NUMBER := 0;

  l_container_item    VARCHAR2(204);
  print_outer      BOOLEAN := FALSE;

  l_lpn_info       lpn_data_type_rec;
  l_item_info       item_data_type_rec;

  l_lpn_id      NUMBER := NULL;
  l_receipt_number     varchar2(30);

  -- Added for Bug 2748297
  l_vendor_id         NUMBER;
  l_vendor_site_id       NUMBER;

   -- Added for UCC 128 J Bug #3067059
   l_gtin_enabled BOOLEAN := FALSE;
   l_gtin VARCHAR2(100);
   l_gtin_desc VARCHAR2(240);
-- Added for patchset J enhancements
   l_deliver_to_location_id NUMBER;
   l_location_id NUMBER;

   g_req_cnt NUMBER;

   l_cost_group_id NUMBER;        -- Added for bug # 4998201
   l_cost_group    VARCHAR2(10);  -- Added for bug # 4998201

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

   -- invconv fabdi start

   l_secondary_uom_code     VARCHAR2(3);
   l_secondary_transaction_qty     NUMBER;

   -- invconv fabdi start

  -- Added vendor_id and vendor_site_id to the cursor for Bug 2748297

 --Bug 4891916 -Added the variable for the cycle count name
   l_cycle_count_name mtl_cycle_count_headers.cycle_count_header_name%TYPE;

  CURSOR c_rti_lpn IS
    SELECT   rti.lpn_id lpn_id, rti.to_organization_id to_oragnization_id,
      pha.segment1 purchase_order, rti.subinventory, rti.locator_id, l_receipt_number,
      pol.line_num po_line_number, pll.quantity quantity_ordered ,
      rti.vendor_item_num supplier_part_number, pov.vendor_id vendor_id,
                        pov.vendor_name supplier_name, pvs.vendor_site_id vendor_site_id,
      pvs.vendor_site_code supplier_site, ppf.full_name requestor,
                        hrl1.location_code deliver_to_location,
      hrl2.location_code location, pll.note_to_receiver note_to_receiver
    FROM   rcv_transactions_interface rti, po_headers_trx_v pha,--CLM Changes, using CLM views instead of base tables
      -- MOAC : po_line_locations changed to po_line_locations_all
      po_lines_trx_v pol, rcv_shipment_headers rsh, po_line_locations_trx_v pll,
      po_vendors pov, hr_locations_all hrl1, hr_locations_all hrl2,
      -- MOAC : po_vendor_sites changed to po_vendor_sites_all
      po_vendor_sites_all pvs, per_people_f ppf
    where   rti.interface_transaction_id   = p_transaction_id
    AND  rti.po_header_id     = pha.po_header_id(+)
    AND  rsh.shipment_header_id(+)       = rti.shipment_header_id
    AND  pol.po_line_id  (+)             = rti.po_line_id
    AND  pol.po_header_id (+)            = rti.po_header_id
    --AND  pll.po_line_id(+)               = pol.po_line_id      -- bug 2372669
    AND     pll.line_location_id(+)         = rti.po_line_location_id -- bug 2372669
    AND  pov.vendor_id(+)                = rti.vendor_id
    -- AND  pvs.vendor_id(+)                = rti.vendor_id uneccessary line dherring 8/2/05
    AND     pvs.vendor_site_id(+)           = rti.vendor_site_id
    AND  ppf.person_id(+)                = rti.deliver_to_person_id
    AND ppf.EFFECTIVE_END_DATE(+) >= trunc(sysdate) --bug 6501344
    AND  hrl1.location_id(+)             = rti.deliver_to_location_id
    AND  hrl2.location_id(+)             = rti.location_id;

  -- Bug 2377796 : Added this cursor for Inspection.
  -- Added vendor_id and vendor_site_id to the cursor for Bug 2748297
  CURSOR c_rti_lpn_inspection IS
    SELECT   rti.transfer_lpn_id transfer_lpn_id, rti.to_organization_id to_oragnization_id,
      pha.segment1 purchase_order, rti.subinventory, rti.locator_id, l_receipt_number,
      pol.line_num po_line_number, pll.quantity quantity_ordered ,
      rti.vendor_item_num supplier_part_number, pov.vendor_id vendor_id,
                        pov.vendor_name supplier_name, pvs.vendor_site_id vendor_site_id,
      pvs.vendor_site_code supplier_site, ppf.full_name requestor,
                        hrl1.location_code deliver_to_location,
      hrl2.location_code location, pll.note_to_receiver note_to_receiver
    FROM   rcv_transactions_interface rti, po_headers_trx_v pha,--CLM Changes,using CLM views instead of base tables
      -- MOAC : po_line_locations changed to po_line_locations_all
      po_lines_trx_v pol, rcv_shipment_headers rsh, po_line_locations_trx_v pll,
      po_vendors pov, hr_locations_all hrl1, hr_locations_all hrl2,
      -- MOAC : po_vendor_sites changed to po_vendor_sites_all
      po_vendor_sites_all pvs, per_people_f ppf
    where   rti.interface_transaction_id   = p_transaction_id
    AND  rti.po_header_id     = pha.po_header_id(+)
    AND  rsh.shipment_header_id(+)       = rti.shipment_header_id
    AND  pol.po_line_id (+)               = rti.po_line_id
    AND  pol.po_header_id  (+)            = rti.po_header_id
    --AND  pll.po_line_id(+)               = pol.po_line_id       -- bug 2372669
    AND   pll.line_location_id(+)         = rti.po_line_location_id  -- bug 2372669
    AND  pov.vendor_id(+)                = rti.vendor_id
    -- AND  pvs.vendor_id(+)                = rti.vendor_id uneccessary line dherring 8/2/05
    AND     pvs.vendor_site_id(+)           = rti.vendor_site_id
    AND  ppf.person_id(+)                = rti.deliver_to_person_id
    AND  hrl1.location_id(+)             = rti.deliver_to_location_id
    AND  hrl2.location_id(+)             = rti.location_id;

  -- Cursor for RCV flows based on NEW architecture of querying LPN data from
  -- RCV transaction tables instead of Interface tables : J-DEV
  -- Note: records in RT are filtered by transaction_type and business_flow_code
  --   becuase it is possible for label-API to be called multiple times by RCV-TM
  --   in the case of ROI, when multiple trx.types are present in a group
  --
   CURSOR c_rt_lpn IS
     SELECT distinct all_lpn.lpn_id
       , pha.segment1 purchase_order
       , all_lpn.subinventory
       , all_lpn.locator_id
       , rsh.receipt_num
       , pol.line_num po_line_number
       , pll.quantity quantity_ordered
       , rsl.vendor_item_num supplier_part_number
       , pov.vendor_id vendor_id
       , pvs.vendor_site_id vendor_site_id
       , pov.vendor_name supplier_name
       , pvs.vendor_site_code supplier_site
       , ppf.full_name requestor
  --     , hrl1.location_code deliver_to_location
  --     , hrl2.location_code location
       , pll.note_to_receiver note_to_receiver
       , all_lpn.deliver_to_location_id
       , all_lpn.location_id
       , pol.item_id item_id
       , all_lpn.quantity quantity
       , wlpn.license_plate_number /*5758070*/
       , rsl.item_revision revision  --Bug 7565852
       , all_lpn.project_id
       , all_lpn.task_id    ---bug 8430171
     FROM(
       -- LPN_ID
          select lpn_id
            , po_header_id, po_line_id
            , subinventory, locator_id
            , shipment_header_id, po_line_location_id
            , vendor_id, vendor_site_id
            , deliver_to_person_id, deliver_to_location_id
            , location_id
            , rt.quantity
            , project_id  -- bug 8430171
            , task_id    -- bug 8430171
	  from rcv_transactions rt
          where rt.lpn_id is not null
            and rt.group_id = p_transaction_id
            AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                  AND p_label_type_info.business_flow_code = 2)
               OR (rt.transaction_type = 'DELIVER'
                  AND p_label_type_info.business_flow_code in (3,4))
               OR (rt.transaction_type = 'RECEIVE'
                  --AND rt.routing_header_id <> 3 Modified for Bug: 4312020
                  AND p_label_type_info.business_flow_code = 1
                  )
             )
          UNION ALL
            -- PARENT LPN of LPN_ID
          select lpn.parent_lpn_id
            , rt.po_header_id, rt.po_line_id
            , rt.subinventory, rt.locator_id
            , rt.shipment_header_id, rt.po_line_location_id
            , rt.vendor_id, rt.vendor_site_id
            , rt.deliver_to_person_id, rt.deliver_to_location_id deliver_to_location_id
            , rt.location_id location_id
            , rt.quantity
            , rt.project_id  -- bug 8430171
            , rt.task_id    -- bug 8430171
	    from wms_license_plate_numbers lpn,
            rcv_transactions rt
          where lpn.lpn_id = rt.lpn_id
            and lpn.parent_lpn_id <> rt.lpn_id
            and rt.group_id = p_transaction_id
            and lpn.parent_lpn_id is not null   -- parentLPN could be null for single-level LPN
            AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                  AND p_label_type_info.business_flow_code = 2)
               OR (rt.transaction_type = 'DELIVER'
                  AND p_label_type_info.business_flow_code in (3,4))
               OR (rt.transaction_type = 'RECEIVE'
                  --AND rt.routing_header_id <> 3 Modified for Bug: 4312020
                  AND p_label_type_info.business_flow_code = 1
                  )
             )
          UNION ALL
            -- OUTERMOSE LPN of LPN_ID, and different than the LPN and parent LPN
          select lpn.outermost_lpn_id
              , rt.po_header_id, rt.po_line_id
              , rt.subinventory, rt.locator_id
              , rt.shipment_header_id, rt.po_line_location_id
              , rt.vendor_id, rt.vendor_site_id
              , rt.deliver_to_person_id, rt.deliver_to_location_id deliver_to_location_id
              , rt.location_id location_id
              , rt.quantity
              , rt.project_id  -- bug 8430171
             , rt.task_id    -- bug 8430171
	      from wms_license_plate_numbers lpn, rcv_transactions rt
          where lpn.lpn_id = rt.lpn_id
              and lpn.outermost_lpn_id <> lpn.lpn_id
              and lpn.outermost_lpn_id <> lpn.parent_lpn_id
              and rt.group_id = p_transaction_id
              AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                  AND p_label_type_info.business_flow_code = 2)
               OR (rt.transaction_type = 'DELIVER'
                  AND p_label_type_info.business_flow_code in (3,4))
               OR (rt.transaction_type = 'RECEIVE'
                  --AND rt.routing_header_id <> 3 Modified for Bug: 4312020
                  AND p_label_type_info.business_flow_code = 1
                  )
               )
          UNION all
              -- Transfer LPN (different than LPN)
          select transfer_lpn_id lpn_id
              , po_header_id, po_line_id
              , subinventory, locator_id
              , shipment_header_id, po_line_location_id
              , vendor_id, vendor_site_id
              , deliver_to_person_id, deliver_to_location_id deliver_to_location_id
              , location_id location_id
              , rt.quantity
        , project_id  -- bug 8430171
            , task_id    -- bug 8430171
	      from rcv_transactions rt
          where
              nvl(transfer_lpn_id,-999) <> nvl(lpn_id,-999) AND
              group_id = p_transaction_id
              AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                  AND p_label_type_info.business_flow_code = 2)
               OR (rt.transaction_type = 'DELIVER'
                  AND p_label_type_info.business_flow_code in (3,4))
               OR (rt.transaction_type = 'RECEIVE'
                  --AND rt.routing_header_id <> 3 Modified for Bug: 4312020
                  AND p_label_type_info.business_flow_code = 1
                  )
               )
          UNION all
              -- Parent LPN of Transfer LPN
          select lpn.parent_lpn_id
              , rt.po_header_id, rt.po_line_id
              , rt.subinventory, rt.locator_id
              , rt.shipment_header_id, rt.po_line_location_id
              , rt.vendor_id, rt.vendor_site_id
              , rt.deliver_to_person_id, rt.deliver_to_location_id deliver_to_location_id
              , rt.location_id location_id
              , rt.quantity
	      , rt.project_id  -- bug 8430171
              , rt.task_id    -- bug 8430171
          from wms_license_plate_numbers lpn, rcv_transactions rt
              where lpn.lpn_id = rt.transfer_lpn_id
              and rt.transfer_lpn_id <> rt.lpn_id
              and lpn.parent_lpn_id <> lpn.lpn_id
              and lpn.parent_lpn_id is not null -- parentLPN could be null for single-level LPN
              and rt.group_id = p_transaction_id
              AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                  AND p_label_type_info.business_flow_code = 2)
               OR (rt.transaction_type = 'DELIVER'
                  AND p_label_type_info.business_flow_code in (3,4))
               OR (rt.transaction_type = 'RECEIVE'
                  --AND rt.routing_header_id <> 3 Modified for Bug: 4312020
                  AND p_label_type_info.business_flow_code = 1
                  )
               )
          UNION ALL
              -- Outermost LPN of Transfer LPN
           select lpn.outermost_lpn_id
              , rt.po_header_id, rt.po_line_id
              , rt.subinventory, rt.locator_id
              , rt.shipment_header_id, rt.po_line_location_id
              , rt.vendor_id, rt.vendor_site_id
              , rt.deliver_to_person_id, rt.deliver_to_location_id deliver_to_location_id
              , rt.location_id location_id
              , rt.quantity
              , rt.project_id  -- bug 8430171
              , rt.task_id    -- bug 8430171
	   from wms_license_plate_numbers lpn, rcv_transactions rt
           where lpn.lpn_id = rt.transfer_lpn_id
              and rt.transfer_lpn_id <> rt.lpn_id
              and lpn.outermost_lpn_id <> lpn.lpn_id
              and lpn.outermost_lpn_id <> lpn.parent_lpn_id
              and rt.group_id = p_transaction_id
              AND ((rt.transaction_type IN ('ACCEPT', 'REJECT')
                  AND p_label_type_info.business_flow_code = 2)
               OR (rt.transaction_type = 'DELIVER'
                  AND p_label_type_info.business_flow_code in (3,4))
               OR (rt.transaction_type = 'RECEIVE'
                  --AND rt.routing_header_id <> 3 Modified for Bug: 4312020
                  AND p_label_type_info.business_flow_code = 1
                  )
               )
        )  all_lpn
         , po_headers_trx_v pha--CLM Changes, using CLM views instead of base tables
         , po_lines_trx_v pol
         , rcv_shipment_headers rsh
         , rcv_shipment_lines rsl
         -- MOAC : po_line_locations changed to po_line_locations_all
         , po_line_locations_trx_v pll
         , po_vendors pov
      --   , hr_locations_all hrl1
      --   , hr_locations_all hrl2
         -- MOAC : po_vendor_sites changed to po_vendor_sites_all
         , po_vendor_sites_all pvs
         , per_people_f ppf
            , wms_license_plate_numbers wlpn
        WHERE  pha.po_header_id(+)       = all_lpn.po_header_id
         AND  rsh.shipment_header_id(+) = all_lpn.shipment_header_id
         AND  rsh.shipment_header_id    = rsl.shipment_header_id
         /* Bug 5241400, Add where clause for rsl and appl_lpn location_id */
         /* Bug 5336350, also need to consider case when po_line_location_id is null, Intransit Shipment or RMA txns */
         AND ((rsl.po_line_location_id IS NULL and all_lpn.po_line_location_id IS NULL) OR
               rsl.po_line_location_id   = all_lpn.po_line_location_id)
         AND  pol.po_line_id  (+)       = all_lpn.po_line_id
         AND  pol.po_header_id (+)      = all_lpn.po_header_id
         AND  pll.line_location_id(+)   = all_lpn.po_line_location_id
         AND  pov.vendor_id(+)          = all_lpn.vendor_id
         -- AND  pvs.vendor_id(+)          = all_lpn.vendor_id uneccessary line dherring 8/2/05
         AND  pvs.vendor_site_id(+)     = all_lpn.vendor_site_id
         AND  ppf.person_id(+)          = all_lpn.deliver_to_person_id
         AND ppf.EFFECTIVE_END_DATE(+) >= trunc(sysdate) --6501344
         -- Bug 3826298, for receiving putaway, do not print if the
         -- LPN is picked (11), which will be doing cross docking
         -- label will be printed during cross docking business flow
         AND  wlpn.lpn_id = all_lpn.lpn_id -- Bug 3836623, add this missing where clause for bug 3826298 fix
         AND  (p_label_type_info.business_flow_code <> 4 OR
              (p_label_type_info.business_flow_code = 4 AND
               wlpn.lpn_context <> 11))
       --  AND  hrl1.location_id(+)       = all_lpn.deliver_to_location_id
       --  AND  hrl2.location_id(+)       = all_lpn.location_id
       ORDER BY wlpn.license_plate_number  /* 5758070*/
;

   /* Patchset J - Create a new cursor to fetch the location_code
    * for the given location_id and deliver_to_location_id
    */
   CURSOR c_hr_locations IS
    Select
       decode(l_deliver_to_location_id,null,null,hrl1.location_code)
           deliver_to_location
     , decode(l_location_id,null,null,hrl2.location_code) location
       from  hr_locations_all hrl1
          , hr_locations_all hrl2
         where  hrl1.location_id = decode(l_deliver_to_location_id,null,hrl1.location_id,l_deliver_to_location_id)
         AND  hrl2.location_id   = decode(l_location_id,null,hrl2.location_id,l_location_id)
         and hrl1.location_id = hrl2.location_id;

  CURSOR c_mmtt_lpn IS
    SELECT   mmtt.lpn_id,
             mmtt.content_lpn_id,
             mmtt.transfer_lpn_id,
             mmtt.transfer_subinventory,
             mmtt.transfer_to_location,
             mmtt.transaction_type_id,
             mmtt.transaction_action_id,
             mmtt.transaction_uom --Bug# 3739739
      -- Bug 2515486: Added transaction_type_id, transaction_action_id, inventory_item_id
     FROM   mtl_material_transactions_temp  mmtt
    WHERE   mmtt.transaction_temp_id = p_transaction_id;


  CURSOR c_mmtt_lpn_pick_load IS
    -- Bug 4277718, pick load printing.
    -- when pick a whole LPN and load the same LPN, transfer_lpn_id is NULL
    -- So take the content_lpn_id
    SELECT   nvl(mmtt.transfer_lpn_id, mmtt.content_lpn_id), mmtt.organization_id, mmtt.inventory_item_id,
      mtlt.lot_number, mmtt.revision,
      abs(nvl(mtlt.transaction_quantity,
                                mmtt.transaction_quantity)) quantity,
      mmtt.transaction_uom,
                        mmtt.transfer_subinventory, mmtt.transfer_to_location
      , mmtt.subinventory_code /*from sub, to select printer*/
      , abs(nvl(mtlt.secondary_quantity, -- invconv fabdi
                                mmtt.secondary_transaction_quantity)) secondary_quantity
     , mmtt.secondary_uom_code -- invconv fabdi
    FROM   mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
    WHERE  mtlt.transaction_temp_id(+)  = mmtt.transaction_temp_id
    AND     mmtt.transaction_temp_id  = p_transaction_id;

  CURSOR c_mmtt_pregen_lpn IS
    SELECT   lpn_id, subinventory_code, locator_id
    FROM   mtl_material_transactions_temp
    WHERE   transaction_temp_id = p_transaction_id;


  CURSOR c_mmtt_get_cart_lpn IS
    SELECT   cartonization_id
    FROM   mtl_material_transactions_temp
    WHERE  transaction_temp_id  = p_transaction_id;

  -- For business flow code of 33, the MMTT, MTI or MOL id is passed
  -- Depending on the txn identifier being passed,one of the
  -- following 2 flow csrs or the generic mmtt crsr will be called

  CURSOR  c_flow_lpn_mol IS
       SELECT lpn_id, from_subinventory_code subinventory_code
         FROM mtl_txn_request_lines
         WHERE line_id=p_transaction_id;

  CURSOR c_flow_lpn_mti IS
       SELECT lpn_id, subinventory_code
         FROM mtl_transactions_interface
         WHERE transaction_interface_id = p_transaction_id;

        -- The above cursor returns all the packages/LPN's in the parent_lpn_id.
        -- The gross weight and other information is from the next level which is achieved by
        -- opening the wms_packaging_hist as wph1. wph is the packlevel = 0 while wph1 is the
        -- pack_level = 1;

   /*Changing the cursor due to performance related changes. Bug 4237831
   CURSOR c_mmtt_cart_lpn IS
    SELECT distinct(wph.parent_package_id), wph.lpn_id, wph1.content_volume_uom_code, wph1.content_volume,
                       wph1.gross_weight_uom_code, wph1.gross_weight, wph.inventory_item_id, wph1.parent_package_id,
                       wph1.pack_level, wph.header_id,wph.packaging_mode, wph1.tare_weight, wph1.tare_weight_uom_code,
                       msik.concatenated_segments container_item, lpn.license_plate_number, wph2.pack_level
    FROM   wms_packaging_hist wph, wms_packaging_hist wph1, wms_packaging_hist wph2, mtl_system_items_kfv msik,
      WMS_LICENSE_PLATE_NUMBERS lpn
    WHERE  wph.rowid in (select rowid
                                     from wms_packaging_hist
                                     where pack_level = 0
                         START WITH parent_lpn_id = p_transaction_id
                         CONNECT BY PARENT_PACKAGE_ID = PRIOR PACKAGE_ID)
    AND   msik.inventory_item_id (+) = wph.parent_item_id
    AND   msik.organization_id  (+)  = wph.organization_id
           AND   wph.parent_package_id = wph1.package_id (+)
       AND   lpn.lpn_id(+) = wph1.parent_lpn_id
           AND wph2.parent_lpn_id = p_transaction_id;
     */
      --Bug#8366557 Added hints to following cursor
      CURSOR c_mmtt_cart_lpn IS
   SELECT /*+ rowid(WPH) */ distinct(wph.parent_package_id), wph.lpn_id, wph1.content_volume_uom_code, wph1.content_volume,
   wph1.gross_weight_uom_code, wph1.gross_weight, wph.inventory_item_id, wph1.parent_package_id,
   wph1.pack_level, wph.header_id,wph.packaging_mode, wph1.tare_weight, wph1.tare_weight_uom_code,
   msik.concatenated_segments container_item,lpn.license_plate_number
   FROM   wms_packaging_hist wph, wms_packaging_hist wph1, mtl_system_items_kfv
   msik, WMS_LICENSE_PLATE_NUMBERS lpn
       WHERE  wph.rowid in (select /*+ cardinality(1) */ rowid
                    from wms_packaging_hist
                    where pack_level = 0
             START WITH parent_lpn_id = p_transaction_id
             CONNECT BY PARENT_PACKAGE_ID = PRIOR PACKAGE_ID)
       AND   msik.inventory_item_id (+) = wph.parent_item_id
       AND   msik.organization_id  (+)  = wph.organization_id
       AND   wph.parent_package_id = wph1.package_id (+)
       AND   lpn.lpn_id(+) = wph1.parent_lpn_id;

  CURSOR c_mmtt_wip_pick_drop_lpn IS
    SELECT  transfer_lpn_id, organization_id, inventory_item_id,
      lot_number, revision, abs(transaction_quantity),
                        transaction_uom,
                        transfer_subinventory, transfer_to_location,
                  abs(secondary_transaction_quantity), secondary_uom_code -- invconv fabdi
    FROM  mtl_material_transactions_temp
    WHERE    transaction_temp_id = p_transaction_id;

  -- Bug 3836623
  -- To prevent printing duplicate labels for cross docking for serialized item
  -- remove the joint with WDA
  -- Obtain the Org/Sub from the LPN table because it should have the correct
  -- value when label printing is called from cross docking
  /*CURSOR  c_wdd_lpn IS
    SELECT  wdd2.lpn_id, nvl(wdd2.organization_id, wdd1.organization_id)
      , wdd1.subinventory
    FROM   wsh_delivery_details wdd1, wsh_delivery_details wdd2
      , wsh_delivery_assignments_v wda
    WHERE   wdd2.delivery_detail_id = p_transaction_id
    AND     wdd1.delivery_detail_id(+) = wda.delivery_detail_id
    AND     wdd2.delivery_detail_id = wda.parent_delivery_detail_id;
*/
    CURSOR  c_wdd_lpn IS
   SELECT wdd.lpn_id, wlpn.organization_id, wlpn.subinventory_code
   FROM wsh_delivery_details wdd, wms_license_plate_numbers wlpn
   WHERE wdd.delivery_detail_id = p_transaction_id
   AND wdd.lpn_id = wlpn.lpn_id;


  -- Bug 2825748 : WIP is passing a transaction_temp_id instead of
  -- wip_lpn_completions,header_id for both LPN and non-LPN Completions.
  -- Bug 4277718
  -- for WIP completion, lpn_id is used rather than transfer_lpn_id
  -- Changed to use c_mmtt_lpn
  /*CURSOR  c_wip_lpn IS
    SELECT   transfer_lpn_id
    FROM   mtl_material_transactions_temp mmtt
    WHERE   mmtt.transaction_temp_id = p_transaction_id;*/


  CURSOR c_wnd_lpn IS
    SELECT  DISTINCT wdd2.lpn_id
    FROM   wsh_new_deliveries wnd, wsh_delivery_assignments_v wda,
      wsh_delivery_details wdd1, wsh_delivery_details wdd2
    WHERE   wnd.delivery_id   = p_transaction_id
    AND  wnd.delivery_id   = wda.delivery_id
    AND  wdd1.delivery_detail_id = wda.delivery_detail_id
    AND     wdd2.delivery_detail_id = wda.parent_delivery_detail_id;

  CURSOR c_child_lpns(p_lpn_id NUMBER) IS
    SELECT   lpn_id
    FROM   wms_license_plate_numbers
    WHERE   parent_lpn_id = p_lpn_id;

  CURSOR c_lpn_attributes (p_org_id NUMBER, p_lpn_id NUMBER)IS
    SELECT lpn.LICENSE_PLATE_NUMBER lpn
      , plpn.lpn_id parent_lpn_id
       , plpn.license_plate_number parent_lpn
       , olpn.license_plate_number outermost_lpn
       , msik.INVENTORY_ITEM_ID container_item_id
      , msik.concatenated_segments container_item
      , nvl(l_content_volume, lpn.CONTENT_VOLUME) volume
      , nvl(l_content_volume_uom_code, lpn.CONTENT_VOLUME_UOM_CODE) volume_uom
      , nvl(l_gross_weight, lpn.GROSS_WEIGHT) gross_weight
      , nvl(l_gross_weight_uom_code, lpn.GROSS_WEIGHT_UOM_CODE) gross_weight_uom
      , nvl(l_tare_weight, lpn.TARE_WEIGHT) tare_weight
      , nvl(l_tare_weight_uom_code, lpn.TARE_WEIGHT_UOM_CODE) tare_weight_uom

      , lpn.attribute_category lpn_attribute_category
       , lpn.attribute1 lpn_attribute1
      , lpn.attribute2 lpn_attribute2
       , lpn.attribute3 lpn_attribute3
      , lpn.attribute4 lpn_attribute4
       , lpn.attribute5 lpn_attribute5
      , lpn.attribute6 lpn_attribute6
       , lpn.attribute7 lpn_attribute7
      , lpn.attribute8 lpn_attribute8
       , lpn.attribute9 lpn_attribute9
      , lpn.attribute10 lpn_attribute10
       , lpn.attribute11 lpn_attribute11
      , lpn.attribute12 lpn_attribute12
       , lpn.attribute13 lpn_attribute13
      , lpn.attribute14 lpn_attribute14
       , lpn.attribute15 lpn_attribute15
       , nvl(wph.parent_package_id, l_package_id) parent_package  --l_parent_package_id) parent_package
       , nvl(wph.pack_level, l_pack_level) pack_level
     FROM   WMS_LICENSE_PLATE_NUMBERS lpn
       , WMS_PACKAGING_HIST wph
      , WMS_LICENSE_PLATE_NUMBERS plpn
      , WMS_LICENSE_PLATE_NUMBERS olpn
      , MTL_SYSTEM_ITEMS_KFV msik
          , DUAL d
     WHERE d.dummy = 'X'
     AND   lpn.license_plate_number (+) <> NVL('@@@',d.dummy)
     AND   lpn.lpn_id (+) = p_lpn_id
     AND   wph.lpn_id (+) = lpn.lpn_id
     AND   plpn.lpn_id (+) = NVL(lpn.parent_lpn_id, l_parent_lpn_id)
     AND   olpn.lpn_id (+) = NVL(lpn.outermost_lpn_id, l_outermost_lpn_id)
     AND   msik.organization_id (+) = p_org_id
     AND   msik.inventory_item_id (+) = lpn.inventory_item_id;
     --AND   msik.inventory_item_id (+) = NVL(lpn.inventory_item_id, l_inventory_item_id);


     --BUG6008065
  CURSOR c_lot_attributes (p_org_id NUMBER, p_item_id NUMBER, p_lot_number VARCHAR2) IS
     SELECT    mp.organization_code  organization
       , msik.concatenated_segments item
	 , WMS_DEPLOY.GET_CLIENT_ITEM(p_org_id, msik.inventory_item_id) client_item		-- Added for LSP Project, bug 9087971
       , msik.description      item_description
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
       , to_char(mtlt.lot_expiration_date, G_DATE_FORMAT_MASK) lot_expiration_date
       , poh.hazard_class  item_hazard_class
       , mtlt.lot_attribute_category lot_attribute_category
       , mtlt.c_attribute1 lot_c_attribute1
       , mtlt.c_attribute2 lot_c_attribute2
       , mtlt.c_attribute3 lot_c_attribute3
       , mtlt.c_attribute4 lot_c_attribute4
       , mtlt.c_attribute5 lot_c_attribute5
       , mtlt.c_attribute6 lot_c_attribute6
       , mtlt.c_attribute7 lot_c_attribute7
       , mtlt.c_attribute8 lot_c_attribute8
       , mtlt.c_attribute9 lot_c_attribute9
       , mtlt.c_attribute10 lot_c_attribute10
       , mtlt.c_attribute11 lot_c_attribute11
       , mtlt.c_attribute12 lot_c_attribute12
       , mtlt.c_attribute13 lot_c_attribute13
       , mtlt.c_attribute14 lot_c_attribute14
       , mtlt.c_attribute15 lot_c_attribute15
       , mtlt.c_attribute16 lot_c_attribute16
       , mtlt.c_attribute17 lot_c_attribute17
       , mtlt.c_attribute18 lot_c_attribute18
       , mtlt.c_attribute19 lot_c_attribute19
       , mtlt.c_attribute20 lot_c_attribute20
       , to_char(mtlt.D_ATTRIBUTE1, G_DATE_FORMAT_MASK) lot_d_attribute1
       , to_char(mtlt.D_ATTRIBUTE2, G_DATE_FORMAT_MASK) lot_d_attribute2
       , to_char(mtlt.D_ATTRIBUTE3, G_DATE_FORMAT_MASK) lot_d_attribute3
       , to_char(mtlt.D_ATTRIBUTE4, G_DATE_FORMAT_MASK) lot_d_attribute4
       , to_char(mtlt.D_ATTRIBUTE5, G_DATE_FORMAT_MASK) lot_d_attribute5
       , to_char(mtlt.D_ATTRIBUTE6, G_DATE_FORMAT_MASK) lot_d_attribute6
       , to_char(mtlt.D_ATTRIBUTE7, G_DATE_FORMAT_MASK) lot_d_attribute7
       , to_char(mtlt.D_ATTRIBUTE8, G_DATE_FORMAT_MASK) lot_d_attribute8
       , to_char(mtlt.D_ATTRIBUTE9, G_DATE_FORMAT_MASK) lot_d_attribute9
       , to_char(mtlt.D_ATTRIBUTE10, G_DATE_FORMAT_MASK) lot_d_attribute10
       , mtlt.n_attribute1 lot_n_attribute1
       , mtlt.n_attribute2 lot_n_attribute2
       , mtlt.n_attribute3 lot_n_attribute3
       , mtlt.n_attribute4 lot_n_attribute4
       , mtlt.n_attribute5 lot_n_attribute5
       , mtlt.n_attribute6 lot_n_attribute6
       , mtlt.n_attribute7 lot_n_attribute7
       , mtlt.n_attribute8 lot_n_attribute8
       , mtlt.n_attribute9 lot_n_attribute9
       , mtlt.n_attribute10 lot_n_attribute10
       , mtlt.TERRITORY_CODE lot_country_of_origin
       , mtlt.grade_code lot_grade_code
       , to_char(mtlt.ORIGINATION_DATE, G_DATE_FORMAT_MASK) lot_origination_date
       , mtlt.DATE_CODE           lot_date_code
       , to_char(mtlt.CHANGE_DATE, G_DATE_FORMAT_MASK) lot_change_date
       , mtlt.AGE              lot_age
       , to_char(mtlt.RETEST_DATE, G_DATE_FORMAT_MASK) lot_retest_date
       , to_char(mtlt.MATURITY_DATE, G_DATE_FORMAT_MASK) lot_maturity_date
       , mtlt.ITEM_SIZE      lot_item_size
       , mtlt.COLOR      lot_color
       , mtlt.VOLUME      lot_volume
       , mtlt.VOLUME_UOM    lot_volume_uom
       , mtlt.PLACE_OF_ORIGIN    lot_place_of_origin
       , to_char(mtlt.BEST_BY_DATE, G_DATE_FORMAT_MASK) lot_best_by_date
       , mtlt.length lot_length
       , mtlt.length_uom lot_length_uom
       , mtlt.recycled_content lot_recycled_cont
       , mtlt.thickness lot_thickness
       , mtlt.thickness_uom lot_thickness_uom
       , mtlt.width lot_width
       , mtlt.width_uom lot_width_uom
       , mtlt.curl_wrinkle_fold lot_curl
       , mtlt.vendor_name lot_vendor
       , mmsv.status_code  lot_number_status
       , mtlt.parent_lot_number
       , mtlt.expiration_action_date
       , mtlt.origination_type
       , mtlt. hold_date
       , mtlt.expiration_action_code
       , mtlt.supplier_lot_number
     FROM      mtl_parameters mp
       , mtl_system_items_kfv msik
       , mtl_transaction_lots_temp mtlt
       , mtl_material_transactions_temp mmtt
       , po_hazard_classes poh
       , mtl_material_statuses_vl mmsv
     WHERE msik.inventory_item_id   = p_item_id
     AND   msik.organization_id     = p_org_id
     AND   mp.organization_id       = msik.organization_id
     AND   mtlt.transaction_temp_id = mmtt.transaction_temp_id
     AND   poh.hazard_class_id (+)  = msik.hazard_class_id
     AND   mtlt.lot_number (+)      = p_lot_number
     AND   mmsv.status_id (+)       = mtlt.status_id;
 --BUG--6008065

   CURSOR c_item_attributes (p_org_id NUMBER, p_item_id NUMBER, p_lot_number VARCHAR2) IS
     SELECT    mp.organization_code  organization
       , msik.concatenated_segments item
       , WMS_DEPLOY.GET_CLIENT_ITEM(msik.organization_id, msik.inventory_item_id) client_item		-- Added for LSP Project, bug 9087971
      , msik.description      item_description
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
      , to_char(mln.expiration_date, G_DATE_FORMAT_MASK) lot_expiration_date -- Added for Bug 2795525,
      , poh.hazard_class  item_hazard_class
      , mln.lot_attribute_category lot_attribute_category
      , mln.c_attribute1 lot_c_attribute1
       , mln.c_attribute2 lot_c_attribute2
      , mln.c_attribute3 lot_c_attribute3
       , mln.c_attribute4 lot_c_attribute4
      , mln.c_attribute5 lot_c_attribute5
       , mln.c_attribute6 lot_c_attribute6
      , mln.c_attribute7 lot_c_attribute7
       , mln.c_attribute8 lot_c_attribute8
      , mln.c_attribute9 lot_c_attribute9
       , mln.c_attribute10 lot_c_attribute10
      , mln.c_attribute11 lot_c_attribute11
       , mln.c_attribute12 lot_c_attribute12
      , mln.c_attribute13 lot_c_attribute13
       , mln.c_attribute14 lot_c_attribute14
      , mln.c_attribute15 lot_c_attribute15
       , mln.c_attribute16 lot_c_attribute16
      , mln.c_attribute17 lot_c_attribute17
       , mln.c_attribute18 lot_c_attribute18
      , mln.c_attribute19 lot_c_attribute19
       , mln.c_attribute20 lot_c_attribute20
      , to_char(mln.D_ATTRIBUTE1, G_DATE_FORMAT_MASK) lot_d_attribute1 -- Added for Bug 2795525,
      , to_char(mln.D_ATTRIBUTE2, G_DATE_FORMAT_MASK) lot_d_attribute2 -- Added for Bug 2795525,
      , to_char(mln.D_ATTRIBUTE3, G_DATE_FORMAT_MASK) lot_d_attribute3 -- Added for Bug 2795525,
      , to_char(mln.D_ATTRIBUTE4, G_DATE_FORMAT_MASK) lot_d_attribute4 -- Added for Bug 2795525,
      , to_char(mln.D_ATTRIBUTE5, G_DATE_FORMAT_MASK) lot_d_attribute5 -- Added for Bug 2795525,
      , to_char(mln.D_ATTRIBUTE6, G_DATE_FORMAT_MASK) lot_d_attribute6 -- Added for Bug 2795525,
      , to_char(mln.D_ATTRIBUTE7, G_DATE_FORMAT_MASK) lot_d_attribute7 -- Added for Bug 2795525,
      , to_char(mln.D_ATTRIBUTE8, G_DATE_FORMAT_MASK) lot_d_attribute8 -- Added for Bug 2795525,
      , to_char(mln.D_ATTRIBUTE9, G_DATE_FORMAT_MASK) lot_d_attribute9 -- Added for Bug 2795525,
      , to_char(mln.D_ATTRIBUTE10, G_DATE_FORMAT_MASK) lot_d_attribute10 -- Added for Bug 2795525,
      , mln.n_attribute1 lot_n_attribute1
       , mln.n_attribute2 lot_n_attribute2
      , mln.n_attribute3 lot_n_attribute3
       , mln.n_attribute4 lot_n_attribute4
      , mln.n_attribute5 lot_n_attribute5
       , mln.n_attribute6 lot_n_attribute6
      , mln.n_attribute7 lot_n_attribute7
       , mln.n_attribute8 lot_n_attribute8
      , mln.n_attribute9 lot_n_attribute9
       , mln.n_attribute10 lot_n_attribute10
      , mln.TERRITORY_CODE lot_country_of_origin
       , mln.grade_code lot_grade_code
      , to_char(mln.ORIGINATION_DATE, G_DATE_FORMAT_MASK) lot_origination_date -- Added for Bug 2795525,
      , mln.DATE_CODE           lot_date_code
      , to_char(mln.CHANGE_DATE, G_DATE_FORMAT_MASK) lot_change_date -- Added for Bug 2795525,
      , mln.AGE              lot_age
      , to_char(mln.RETEST_DATE, G_DATE_FORMAT_MASK) lot_retest_date -- Added for Bug 2795525,
      , to_char(mln.MATURITY_DATE, G_DATE_FORMAT_MASK) lot_maturity_date -- Added for Bug 2795525,
      , mln.ITEM_SIZE      lot_item_size
      , mln.COLOR      lot_color
      , mln.VOLUME      lot_volume
      , mln.VOLUME_UOM    lot_volume_uom
      , mln.PLACE_OF_ORIGIN    lot_place_of_origin
      , to_char(mln.BEST_BY_DATE, G_DATE_FORMAT_MASK) lot_best_by_date -- Added for Bug 2795525,
       , mln.length lot_length
      , mln.length_uom lot_length_uom
       , mln.recycled_content lot_recycled_cont
      , mln.thickness lot_thickness
       , mln.thickness_uom lot_thickness_uom
      , mln.width lot_width
       , mln.width_uom lot_width_uom
      , mln.curl_wrinkle_fold lot_curl
       , mln.vendor_name lot_vendor
       , mmsv.status_code  lot_number_status
      , mln.parent_lot_number --     invconv fabdi start
      , mln.expiration_action_date
      , mln.origination_type
      , mln.hold_date
      , mln.expiration_action_code
      , mln.supplier_lot_number  -- invconv fabdi end
     FROM      mtl_parameters mp
       , mtl_system_items_kfv msik
       , mtl_lot_numbers mln
       , po_hazard_classes poh
      , mtl_material_statuses_vl mmsv
     WHERE msik.inventory_item_id = p_item_id
     AND   msik.organization_id   = p_org_id
       AND   mp.organization_id      = msik.organization_id
    AND   mln.organization_id (+)   = msik.organization_id
     AND   mln.inventory_item_id (+) = msik.inventory_item_id
     AND   poh.hazard_class_id (+)   = msik.hazard_class_id
    AND   mln.lot_number (+)        = p_lot_number
     AND   mmsv.status_id (+)        = mln.status_id;

  -- p_item_id: if specified, then use it to restrict the contents of LPN
  -- Bug 4137707, performance of printing at cartonization
  -- Break the original cursor into seperate cursor
  --  for cartonization flow c_lpn_item_content_cart
  --   and non-cartonization flow c_lpn_item_content
  -- Since this is for non-cartonization flow
  -- Removed the following information
  --  1. Removed input parameter p_package_id
  --  2. Removed the reference to l_packaging_mode because it is only relavent for cartonization
  CURSOR c_lpn_item_content(p_lpn_id NUMBER, p_item_id NUMBER) IS
      SELECT
        nvl(p_organization_id, plpn.organization_id)  organization_id
      , nvl(p_inventory_item_id, wlc.inventory_item_id) inventory_item_id
       , nvl(p_revision, wlc.revision)  revision
      , nvl(p_lot_number,wlc.lot_number)  lot_number
       , sum(nvl(p_qty, wlc.quantity))  quantity
      , nvl(p_uom, wlc.uom_code)  uom
       , nvl(p_cost_group_id, wlc.cost_group_id) cost_group_id
      , ccg.cost_group  cost_group
      , milkfv.subinventory_code subinventory_code
      , milkfv.inventory_location_id        locator_id
      , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id, milkfv.organization_id) locator
      , sum(nvl(l_secondary_transaction_qty,wlc.secondary_quantity))  secondary_quantity -- invconv fabdi
      , wlc.secondary_uom_code  secondary_uom      -- invconv fabdi
      FROM wms_lpn_contents wlc
       , wms_license_plate_numbers plpn
       , cst_cost_groups  ccg
      , mtl_item_locations milkfv
      -- Bug 4137707, Do not need to include this where clause,
      -- This will be controlled when opening this cursor
      --WHERE cartonization_flag = 0  -- non Cartonization Flow
      WHERE --wlc.parent_lpn_id = p_lpn_id /* Modified for the bug # 4771610*/
            wlc.parent_lpn_id IN (SELECT lpn_id FROM wms_license_plate_numbers plpn
                                                WHERE 1 = 1
                                                start with lpn_id = p_lpn_id
                                                connect by parent_lpn_id = prior lpn_id)
      AND plpn.lpn_id (+) = wlc.parent_lpn_id
      AND milkfv.organization_id (+)  =   NVL(p_organization_id, plpn.organization_id)
      -- Bug 4137707
      --AND   milkfv.subinventory_code(+) =   DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL,
      --                                             nvl(l_subinventory_code, plpn.subinventory_code))
      --AND   milkfv.inventory_location_id(+) = DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL,
      --                                               nvl(l_locator_id, plpn.locator_id))
      AND milkfv.subinventory_code(+) =   nvl(l_subinventory_code, plpn.subinventory_code)
      AND milkfv.inventory_location_id(+) = nvl(l_locator_id, plpn.locator_id)
      AND ccg.cost_group_id (+)     = nvl(p_cost_group_id, wlc.cost_group_id)
      AND nvl(p_inventory_item_id, wlc.inventory_item_id) IS NOT NULL -- Added for Bug 2857568
      AND wlc.inventory_item_id = nvl(p_item_id,wlc.inventory_item_id)
      -- Added the following condition for bug 4387168
      AND nvl(wlc.lot_number,-1) = nvl(p_lot_number,nvl(wlc.lot_number,-1))
       GROUP BY
        nvl(p_organization_id, plpn.organization_id)
      , nvl(p_inventory_item_id, wlc.inventory_item_id)
       , nvl(p_revision, wlc.revision)
      , nvl(p_lot_number,wlc.lot_number)
      , nvl(p_uom, wlc.uom_code)
       , nvl(p_cost_group_id, wlc.cost_group_id)
      , ccg.cost_group
      , milkfv.subinventory_code
      , milkfv.inventory_location_id
      , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id, milkfv.organization_id)
     , wlc.secondary_uom_code -- invconv fabdi

    /*Fix for the bug 3693953. Added the following Query to this cursor*/
      UNION ALL
      SELECT        nvl(p_organization_id, plpn.organization_id)  organization_id
                  , nvl(p_inventory_item_id, mmtt.inventory_item_id) inventory_item_id
                  , nvl(p_revision, mmtt.revision) revision
                  , nvl(p_lot_number,mmtt.lot_number)      lot_number
                  , sum(nvl(p_qty, mmtt.primary_quantity)) quantity
                  , nvl(p_uom, mmtt.item_primary_uom_code)      uom
                  , nvl(p_cost_group_id, mmtt.cost_group_id) cost_group_id
                  , ccg.cost_group        cost_group
                  , milkfv.subinventory_code subinventory_code
                  , milkfv.inventory_location_id           locator_id
                  , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id, milkfv.organization_id) locator
                  , sum(nvl(l_secondary_transaction_qty,mmtt.secondary_transaction_quantity)) secondary_quantity -- invconv fabdi
                  , mmtt.secondary_uom_code      secondary_uom            -- invconv fabdi
      FROM          wms_license_plate_numbers plpn
                  , cst_cost_groups       ccg
                  , mtl_item_locations milkfv
                  , mtl_material_transactions_temp mmtt
      -- Bug 4137707, Do not need to include this where clause,
      -- This will be controlled when opening this cursor
      --WHERE cartonization_flag = 0  -- non Cartonization Flow
            WHERE   plpn.lpn_id (+) = p_lpn_id
            AND   p_label_type_info.business_flow_code NOT IN (19,20) /* Modified for bug# 5168330*/
            AND   milkfv.organization_id (+)  =   NVL(p_organization_id, plpn.organization_id)
              -- Bug 4137707
              --AND   milkfv.subinventory_code(+) =   DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL,
              --                                             nvl(l_subinventory_code, plpn.subinventory_code))
              --AND   milkfv.inventory_location_id(+) = DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL,
              --                                               nvl(l_locator_id, plpn.locator_id))
            AND   milkfv.subinventory_code(+) =   nvl(l_subinventory_code, plpn.subinventory_code)
            AND   milkfv.inventory_location_id(+) = nvl(l_locator_id, plpn.locator_id)
            AND   ccg.cost_group_id (+)     = nvl(p_cost_group_id, mmtt.cost_group_id)
            AND   mmtt.transaction_temp_id      = p_transaction_id
            AND  NOT EXISTS (SELECT 1 from wms_lpn_contents wlc where wlc.parent_lpn_id=p_lpn_id)
            AND  mmtt.primary_quantity > 0 --9070667
      GROUP BY
                nvl(p_organization_id, plpn.organization_id)
              , nvl(p_inventory_item_id, mmtt.inventory_item_id)
              , nvl(p_revision, mmtt.revision)
              , nvl(p_lot_number,mmtt.lot_number)
              , nvl(p_uom, mmtt.item_primary_uom_code)
              , nvl(p_cost_group_id, mmtt.cost_group_id)
              , ccg.cost_group
              , milkfv.subinventory_code
              , milkfv.inventory_location_id
                        , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id, milkfv.organization_id)
                    , mmtt.secondary_uom_code; -- invconv fabdi

              /*End of fix for 3693953*/

      -- Bug 4137707
      --  create new cursor for cartonization flow
      --  For cartonization flow, p_org.., p_inventory_item..,
      --   p_rev..p_lot..p_qty, p_uom, p_cg., l_subinventory, l_locator_id.are always null
      --   remove nvl(.) for those parameters
      --Bug#8366557 Added hints to following cursor
      CURSOR c_lpn_item_content_cart(p_lpn_id NUMBER, p_package_id NUMBER, p_item_id NUMBER) IS
      SELECT /*+ ORDERED index(MMTT MTL_MATERIAL_TRANS_TEMP_U1) rowid(WPC) use_nl(WPC MMTT MSI CSG MILKFV) index(MSI MTL_SYSTEM_ITEMS_B_U1)*/
        wpc.organization_id  organization_id
      , wpc.inventory_item_id inventory_item_id
       , wpc.revision  revision
      , wpc.lot_number  lot_number
      , sum(wpc.primary_quantity)  quantity
      , msi.primary_uom_code  uom
      , mmtt.cost_group_id cost_group_id
      , ccg.cost_group  cost_group
      , milkfv.subinventory_code subinventory_code
      , milkfv.inventory_location_id locator_id
      , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id, milkfv.organization_id) locator
     , l_secondary_transaction_qty  secondary_quantity -- invconv fabdi
     , l_secondary_uom_code secondary_uom -- invconv fabdi
      FROM   wms_packaging_hist wpc
            , mtl_material_transactions_temp mmtt
            , mtl_system_items msi
            , cst_cost_groups  ccg
           , mtl_item_locations milkfv
      -- Bug 4137707, Do not need to include this where clause,
      -- This will be controlled when opening this cursor
      -- WHERE cartonization_flag = 1  --Cartonization Flow
             WHERE   wpc.rowid in ( select /*+ cardinality(1) */ id from  ((select rowid id from wms_packaging_hist
                           where pack_level = 0
                           AND   header_id = l_header_id
                           AND   packaging_mode = l_packaging_mode
                                AND   lpn_id is null
                           start with parent_lpn_id = p_lpn_id
                           connect by PARENT_PACKAGE_ID = PRIOR PACKAGE_ID

                                union all

                                select rowid from wms_packaging_hist
                           where pack_level = 0
                                AND   lpn_id is null
                                start with parent_package_id = p_package_id
                           connect by PARENT_PACKAGE_ID = PRIOR PACKAGE_ID) ) t )
      AND   mmtt.transaction_temp_id (+) = wpc.reference_id
      AND   msi.inventory_item_id (+) = NVL(p_item_id, mmtt.inventory_item_id) -- 8816529
      AND   msi.organization_id (+)  = NVL(p_organization_id, mmtt.organization_id) -- 8816529
      AND   milkfv.organization_id (+)  = mmtt.organization_id
      AND   milkfv.subinventory_code(+) = DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL,
                                                 mmtt.subinventory_code)
      AND   milkfv.inventory_location_id(+) = DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL,
                                                     mmtt.locator_id)
      AND   ccg.cost_group_id (+)      = mmtt.cost_group_id
      GROUP BY
        wpc.organization_id
      , wpc.inventory_item_id
      , wpc.revision
      , wpc.lot_number
      , msi.primary_uom_code
      , mmtt.cost_group_id
      , ccg.cost_group
      , milkfv.subinventory_code
      , milkfv.inventory_location_id
      , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id, milkfv.organization_id);


  -- Cursor to retrieve all the LPNs (including parent and outermostLPN)
  -- associated with a shipment_header for ASN business-flow. iSP requirements.
  -- Note: RSH Header-level information is not queried in this cursor. Instead
  --  it is queried just once below for ASN flow. :J-DEV
  CURSOR c_asn_lpn IS
         SELECT distinct
            all_lpn.lpn_id
          , pha.segment1 purchase_order
          , all_lpn.subinventory_code
          , all_lpn.locator_id
          , nvl(pll.promised_date, pll.need_by_date) due_date
          , all_lpn.packing_slip
          , all_lpn.truck_num
          , all_lpn.country_of_origin_code
          , all_lpn.comments
          , pol.line_num po_line_number
          , pll.quantity quantity_ordered
          , all_lpn.vendor_item_num supplier_part_number
          , pov.vendor_id vendor_id
          , pvs.vendor_site_id vendor_site_id
          , pov.vendor_name supplier_name
          , pvs.vendor_site_code supplier_site
          , ppf.full_name requestor
          , hrl1.location_code deliver_to_location
          , hrl2.location_code location
          , pll.note_to_receiver note_to_receiver
      FROM(
             select lpn.lpn_id
               , rsl.po_header_id, rsl.po_line_id
               , lpn.subinventory_code, lpn.locator_id
               , rsh.shipment_header_id, rsl.po_line_location_id
               , rsh.vendor_id, rsh.vendor_site_id
               , rsl.deliver_to_person_id, rsl.deliver_to_location_id
               , '' location_id
               , rsh.packing_slip
               , rsl.truck_num
               , rsl.COUNTRY_OF_ORIGIN_CODE
               , rsl.comments
              , rsl.vendor_item_num
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
               , rsh.shipment_header_id, rsl.po_line_location_id
               , rsh.vendor_id, rsh.vendor_site_id
               , rsl.deliver_to_person_id, rsl.deliver_to_location_id
               , '' location_id
               , rsh.packing_slip
               , rsl.truck_num
               , rsl.COUNTRY_OF_ORIGIN_CODE
               , rsl.comments
              , rsl.vendor_item_num
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
               , rsh.shipment_header_id, rsl.po_line_location_id
               , rsh.vendor_id, rsh.vendor_site_id
               , rsl.deliver_to_person_id, rsl.deliver_to_location_id
               , '' location_id
               , rsh.packing_slip
               , rsl.truck_num
               , rsl.COUNTRY_OF_ORIGIN_CODE
               , rsl.comments
              , rsl.vendor_item_num
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
           -- MOAC : po_line_locations changed to po_line_locations_all
           , po_line_locations_trx_v pll
           , po_vendors pov
           , hr_locations_all hrl1
           , hr_locations_all hrl2
           -- MOAC : po_vendor_sites changed to po_vendor_sites_all
           , po_vendor_sites_all pvs
           , per_people_f ppf
      WHERE      pha.po_header_id(+)       = all_lpn.po_header_id
           AND   rsh.shipment_header_id(+) = all_lpn.shipment_header_id
           AND   pol.po_line_id  (+)       = all_lpn.po_line_id
           AND   pol.po_header_id (+)      = all_lpn.po_header_id
           AND   pll.line_location_id(+)   = all_lpn.po_line_location_id
           AND   pov.vendor_id(+)          = all_lpn.vendor_id
           -- AND   pvs.vendor_id(+)          = all_lpn.vendor_id uneccessary line dherring 8/2/05
           AND   pvs.vendor_site_id(+)     = all_lpn.vendor_site_id
           AND   ppf.person_id(+)          = all_lpn.deliver_to_person_id
           AND   hrl1.location_id(+)       = all_lpn.deliver_to_location_id
           AND   hrl2.location_id(+)       = all_lpn.location_id;

  /*
   * The following cursor has been added for bug # 4998201.
   * While performing Receipt and Receiving Put-Away Drop business flow for
   * serial, Lot Serial and Lot Serial revision controlled items, the cost_group_id
   * will be populated in mtl_serial_numbers table. Hence the following cursor has been
   * added to fetch the cost group details.
   */

  CURSOR c_cost_group(p_lpn_id NUMBER
                    , p_inventory_item_id NUMBER
                    , p_lot_number VARCHAR) IS
     SELECT msn.cost_group_id
          , ccg.cost_group
     FROM   mtl_serial_numbers msn
          , cst_cost_groups  ccg
     WHERE msn.lpn_id = p_lpn_id
       AND msn.inventory_item_id = p_inventory_item_id
       AND msn.lot_number = p_lot_number
       AND msn.cost_group_id = ccg.cost_group_id;

  --Fix for bug 5006693

    CURSOR c_order_details IS
       SELECT oeol.header_id ,
              oeol.line_id
       FROM mtl_material_transactions_temp mmtt,
            oe_order_lines_all oeol
       WHERE oeol.line_id = mmtt.trx_source_line_id
         AND  mmtt.transaction_temp_id =  p_transaction_id ;

  --End of Fix for bug 5006693


  --R12 PROJECT LABEL SET with RFID

  CURSOR c_label_formats_in_set(p_format_set_id IN NUMBER)  IS
     select wlfs.format_id label_format_id, wlf.label_entity_type --FOR SETS
       from wms_label_set_formats wlfs , wms_label_formats wlf
       where WLFS.SET_ID = p_format_set_id
       and wlfs.set_id = wlf.label_format_id
       and wlf.label_entity_type = 1
       AND WLF.DOCUMENT_ID = 4
       UNION --FOR FORMATS
       select label_format_id,nvl(wlf.label_entity_type,0)
       from wms_label_formats wlf
       where  wlf.label_format_id =  p_format_set_id
       and nvl(wlf.label_entity_type,0) = 0--for label formats only validation
       AND WLF.DOCUMENT_ID = 4 ;

       --Start of fix for Bug 4891916.
       --Added this cursor to fetch the details of the LPN for the
       --cycle count business flow
       CURSOR c_mcce_lpn_item_content(p_lpn_id NUMBER ) IS
         SELECT   NVL(p_organization_id, plpn.organization_id) organization_id
                , NVL(p_inventory_item_id, mcce.inventory_item_id) inventory_item_id
                , NVL(p_revision, mcce.revision) revision
                , NVL(p_lot_number, mcce.lot_number) lot_number
                , SUM(NVL(p_qty, mcce.count_quantity_current)) quantity
                , NVL(p_uom, mcce.count_uom_current) uom
                , NVL(p_cost_group_id, mcce.cost_group_id) cost_group_id
                , ccg.cost_group cost_group
                , milkfv.subinventory_code subinventory_code
                , milkfv.inventory_location_id locator_id
                , inv_project.get_locsegs(milkfv.inventory_location_id, milkfv.organization_id) LOCATOR
                , sum(nvl(l_secondary_transaction_qty,mcce.count_quantity_current)) secondary_quantity
                , mcce.count_uom_current secondary_uom
             FROM wms_license_plate_numbers plpn, cst_cost_groups ccg, mtl_item_locations milkfv,
                  mtl_cycle_count_entries mcce
            WHERE cartonization_flag = 0   -- non Cartonization Flow
              AND plpn.lpn_id(+) = p_lpn_id
              AND milkfv.organization_id(+) = NVL(p_organization_id, plpn.organization_id)
              AND milkfv.subinventory_code(+) = NVL(l_subinventory_code, plpn.subinventory_code)
              AND milkfv.inventory_location_id(+) = NVL(l_locator_id, plpn.locator_id)
              AND ccg.cost_group_id(+) = NVL(p_cost_group_id, mcce.cost_group_id)
              AND mcce.cycle_count_entry_id = p_transaction_id
         GROUP BY NVL(p_organization_id, plpn.organization_id)
                , NVL(p_inventory_item_id, mcce.inventory_item_id)
                , NVL(p_revision, mcce.revision)
                , NVL(p_lot_number, mcce.lot_number)
                , NVL(p_uom, mcce.count_uom_current)
                , NVL(p_cost_group_id, mcce.cost_group_id)
                , ccg.cost_group
                , milkfv.subinventory_code
                , milkfv.inventory_location_id
                , inv_project.get_locsegs(milkfv.inventory_location_id, milkfv.organization_id)
                , mcce.count_uom_current; /* Added for the bug # 5215799 */

       --Bug 4891916. Added the cursor to fetch records from mcce
       --at the time of cycle count entry for a particular entry
       CURSOR c_mcce_lpn_cur IS
         SELECT   mcce.inventory_item_id
                , mcce.organization_id
                , mcce.lot_number
                , mcce.cost_group_id
                , mcce.count_quantity_current
                , mcce.count_uom_current
                , mcce.revision
                , mcce.subinventory
                , mcce.locator_id
                , mcce.parent_lpn_id
                , mcch.cycle_count_header_name
                , ppf.full_name requestor
             FROM mtl_cycle_count_headers mcch
                , mtl_cycle_count_entries mcce
                , per_people_f ppf
            WHERE mcce.cycle_count_entry_id =  p_transaction_Id
              AND ppf.person_id(+) = mcce.counted_by_employee_id_current
              AND mcce.cycle_count_header_id=mcch.cycle_count_header_id;

       --Bug 4891916. Added this cursor to get details like cycle count header name
       --and counter for the entry for the label printed at the time of cycle count approval
       CURSOR cc_det_approval IS
         SELECT  mcch.cycle_count_header_name
               , ppf.full_name requestor
            FROM mtl_cycle_count_headers mcch
               , mtl_cycle_count_entries mcce
               , per_people_f ppf
               , mtl_material_transactions_temp mmtt
           WHERE mmtt.transaction_temp_id= p_transaction_id
             AND mmtt.cycle_count_id = mcce.cycle_count_entry_id
             AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
             AND ppf.person_id(+) = mcce.counted_by_employee_id_current ;

  --End of fix for Bug 4891916

  l_content_lpn_id  NUMBER;
  l_transfer_lpn_id  NUMBER;
  l_from_lpn_id    NUMBER;
  l_purchase_order  PO_HEADERS_ALL.SEGMENT1%TYPE;

  l_content_item_data   LONG;
  --l_child_lpn_summary   LONG;
  l_child_lpn_summary  INV_LABEL.label_tbl_type;

  l_selected_fields   INV_LABEL.label_field_variable_tbl_type;
  l_selected_fields_count  NUMBER;

  l_rcv_lpn_table rcv_label_tbl_type;  -- Table of LPN-level info : J-DEV
  l_rlpn_ndx NUMBER := 0; -- Index to table of records for RCV LPN
  l_rcv_isp_header rcv_isp_header_rec ; -- Header-level info for ASN iSP

  l_content_rec_index   NUMBER := 0;

  l_label_format_id       NUMBER := 0 ;
  l_label_format          VARCHAR2(100);
  l_printer          VARCHAR2(30):=NULL;

  l_api_name     VARCHAR2(20) := 'get_variable_data';
  l_return_status   VARCHAR2(240);
  l_error_message    VARCHAR2(240);
  l_msg_count        NUMBER;
      l_api_status       VARCHAR2(240);
  l_msg_data    VARCHAR2(240);

  l_label_type_child_lpn   INV_LABEL.label_type_rec;
  i       NUMBER;

  l_summary_format_id  NUMBER;
  l_summary_format  VARCHAR2(240);

  l_lpn_table    inv_label.lpn_table_type;

  -- Added for bug 2084791.
  -- l_item_id_table  inv_label.item_table_type;
  -- l_quantity_table  inv_label.quantity_table_type;
  -- End of bug 2084791 addition.

  l_lpn_table_index  NUMBER;

  --Bug# 7565852
	TYPE t_char IS TABLE OF varchar2(20) index by pls_integer;
	l_rev_t t_char;
  --Bug# 7565852

  l_po_line_number    number;
  l_quantity_ordered    number;
  l_supplier_part_number    varchar2(25);
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

  l_label_index       NUMBER;
  l_label_request_id    NUMBER;

  -- Bug 2515486
  l_transaction_type_id    number := 0;
  l_transaction_action_id    number := 0;

  --I cleanup, use l_prev_format_id to record the previous label format
  l_prev_format_id      NUMBER;
  -- I cleanup, user l_prev_sub to record the previous subinventory
  --so that get_printer is not called if the subinventory is the same
  l_prev_sub VARCHAR2(30);

  -- a list of columns that are selected for format
  l_column_name_list LONG;
  l_patch_level NUMBER;

  --Bug# 3423817
  l_outermost_pack_level   NUMBER;

  l_cur_item_id number; -- Item id that is currently being processed in RCV flows

  --Bug# 3739739
  l_qty        NUMBER;
  l_uom        MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_UOM%TYPE := null;

  -- Variable for EPC Generation
  -- Added for 11.5.10+ RFID Compliance project
  -- Modified in R12

  l_epc VARCHAR2(300);
  l_epc_ret_status VARCHAR2(10);
  l_epc_ret_msg VARCHAR2(1000);
  l_label_status VARCHAR2(1);
  l_label_err_msg VARCHAR2(1000);
  l_is_epc_exist VARCHAR2(1) := 'N';

  -- Bug 4137707
  v_lpn_content c_lpn_item_content%ROWTYPE;

  l_sales_order_header_id   NUMBER ;  -- bug 5006693
  l_sales_order_line_id     NUMBER ;  -- bug 5006693
  l_lot_attribute_info item_data_type_rec; --BUG6008065

  l_label_format_set_id NUMBER;
  --LPN STATUS project start
  l_return_status_id number;
  l_src_status_id NUMBER;
  l_src_locator_id NUMBER;
  l_src_subinventory_code VARCHAR2(30);
  l_src_lpn_id NUMBER;
  l_src_organization_id NUMBER;
  l_license_plate_id NUMBER;
  l_count NUMBER;
  l_query_moqd NUMBER := 1;
  l_material_status_code VARCHAR2(30);
  l_onhand_status_enabled NUMBER := 2;
  l_serial_controlled NUMBER := 2;
  l_lpn_context_id NUMBER := NULL;
  l_default_org_status_id NUMBER := NULL;
  --LPN STATUS Project End

BEGIN
  -- In case of items being packed at the lowest level into the parent_lpn_id directly,
  -- the LPN field on the label should be populated with the the parent LPN value.

  -- In case of items being packed into a package and the package in turn being packed into another
  -- package before its finally packed into the parent_lpn_id, the parent_lpn on the Content label
  -- should not be populated but the parent_package_id should be populated since we display the immediate
  -- parent of the current level.

    l_debug := INV_LABEL.l_debug;

  IF (l_debug = 1) THEN
     trace('**In PVT4: LPN Content label**');
     trace('  Business_flow='||p_label_type_info.business_flow_code ||
           ', Transaction ID='||p_transaction_id ||
           ', Transaction Identifier='||p_transaction_identifier );
  END IF;
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j)
          AND (inv_rcv_common_apis.g_po_patch_level >=inv_rcv_common_apis.g_patchset_j_po) THEN
     l_patch_level := 1;
  ELSIF (inv_rcv_common_apis.g_inv_patch_level  < inv_rcv_common_apis.g_patchset_j)
          AND (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po) THEN
     l_patch_level := 0;
  END IF;
  IF l_debug =1 THEN
  trace('patch level ' || l_patch_level);
  END IF;

  -- Get l_lpn_id
  IF p_transaction_id IS NOT NULL THEN
    -- txn driven
    i := 1;

    IF p_label_type_info.business_flow_code in (1,2,3,4) THEN
      -- Receipt, Inspection, Delivery, Putaway
      IF ( p_transaction_identifier = INV_LABEL.TRX_ID_RT) OR l_patch_level = 1 THEN
       -- New Architecture : Get LPN from RT  :J-DEV
       -- Applicable with DM.J and IProc.J
         IF l_debug = 1 THEN
          trace(' transaction_identifier is ' || p_transaction_identifier);
         END IF;
        FOR v_rt_lpn IN c_rt_lpn LOOP
          l_rcv_lpn_table(l_rlpn_ndx).lpn_id := v_rt_lpn.lpn_id;
          IF l_debug = 1 THEN
          trace('lpn id is ' || l_rcv_lpn_table(l_rlpn_ndx).lpn_id);
          END IF;
          l_rcv_lpn_table(l_rlpn_ndx).purchase_order := v_rt_lpn.purchase_order;
          l_rcv_lpn_table(l_rlpn_ndx).subinventory := v_rt_lpn.subinventory;
          l_rcv_lpn_table(l_rlpn_ndx).locator_id := v_rt_lpn.locator_id;
          l_rcv_lpn_table(l_rlpn_ndx).receipt_num := v_rt_lpn.receipt_num;
          l_rcv_lpn_table(l_rlpn_ndx).po_line_num := v_rt_lpn.po_line_number;
          l_rcv_lpn_table(l_rlpn_ndx).quantity_ordered := v_rt_lpn.quantity_ordered;
          l_rcv_lpn_table(l_rlpn_ndx).supplier_part_number := v_rt_lpn.supplier_part_number;
          l_rcv_lpn_table(l_rlpn_ndx).vendor_id := v_rt_lpn.vendor_id;
          l_rcv_lpn_table(l_rlpn_ndx).vendor_site_id := v_rt_lpn.vendor_site_id;
          l_rcv_lpn_table(l_rlpn_ndx).supplier_site := v_rt_lpn.supplier_site;
          l_rcv_lpn_table(l_rlpn_ndx).supplier_name := v_rt_lpn.supplier_name;
          l_rcv_lpn_table(l_rlpn_ndx).requestor := v_rt_lpn.requestor;
      --    l_rcv_lpn_table(l_rlpn_ndx).deliver_to_location := v_rt_lpn.deliver_to_location;
       --   l_rcv_lpn_table(l_rlpn_ndx).location := v_rt_lpn.location;
          l_rcv_lpn_table(l_rlpn_ndx).note_to_receiver := v_rt_lpn.note_to_receiver;
          l_rcv_lpn_table(l_rlpn_ndx).item_id := v_rt_lpn.item_id;
          l_deliver_to_location_id := v_rt_lpn.deliver_to_location_id;
          l_location_id := v_rt_lpn.location_id;
          l_rcv_lpn_table(l_rlpn_ndx).quantity := v_rt_lpn.quantity;
          l_rev_t(l_rlpn_ndx) := v_rt_lpn.revision;   --Bug# 7565852
          l_project_id:=  v_rt_lpn.project_id;  ----8430171
          l_task_id:=v_rt_lpn.task_id;                    ---  8430171

	    --Added (if and begin block) for bug# 9341719 vpedarla
	    IF l_debug =1 THEN
		     trace('l_project_id is :- '|| l_project_id);
		     trace('l_task_id is :- '|| l_task_id);
		END IF;
		IF (l_project_id IS NOT NULL )  THEN
		BEGIN
		  ---8430171
		  SELECT name
		  INTO l_project_name
		  FROM PA_PROJECTS_ALL
		  WHERE PROJECT_ID = l_project_id  and rownum=1 ;
		 EXCEPTION
		 WHEN no_data_found THEN
		   IF (l_debug = 1) THEN
		       trace('No record found in PA_PROJECTS_ALL with l_project_id as :- '|| l_project_id);
		   END IF;
		 END;
		 END IF;

		 --Added (if and begin block) for bug#9310523
		IF (l_task_id IS NOT NULL )  THEN
		BEGIN
		  SELECT task_name
		  INTO l_task_name
		  FROM PA_TASKS
		  WHERE TASK_ID =l_task_id AND ROWNUM=1;
		  ---8430171
		EXCEPTION
		WHEN no_data_found THEN
		   IF (l_debug = 1) THEN
		      trace('No record found in PA_TASKS with l_task_id as :- '|| l_task_id);
		   END IF;
		END;
		END IF;

	  IF l_deliver_to_location_id IS NOT NULL OR l_location_id IS NOT NULL THEN
             IF l_debug = 1 THEN
             trace('either l_location_id or l_deliver_to_location_id is not null');
             END IF;
             for v_hr in c_hr_locations loop
                l_rcv_lpn_table(l_rlpn_ndx).deliver_to_location := v_hr.deliver_to_location;
                l_rcv_lpn_table(l_rlpn_ndx).location := v_hr.location;
             END LOOP;
          END IF;
          l_rlpn_ndx := l_rlpn_ndx+1;
        END LOOP;
      ELSE
       -- Old Architecture
       IF p_label_type_info.business_flow_code = 2 THEN
          -- Inspection
          -- Getting lpn_id from RTI
          FOR v_rti_lpn_inspection IN c_rti_lpn_inspection LOOP
            l_lpn_table(i) := v_rti_lpn_inspection.transfer_lpn_id;
            l_purchase_order := v_rti_lpn_inspection.purchase_order;
            l_subinventory_code := v_rti_lpn_inspection.subinventory;
            l_locator_id := v_rti_lpn_inspection.locator_id;
            l_receipt_number     := INV_RCV_COMMON_APIS.g_rcv_global_var.receipt_num;
            l_po_line_number     := v_rti_lpn_inspection.po_line_number;
            l_quantity_ordered   := v_rti_lpn_inspection.quantity_ordered;
            l_supplier_part_number   := v_rti_lpn_inspection.supplier_part_number;
            l_supplier_name    := v_rti_lpn_inspection.supplier_name;
            l_vendor_id       := v_rti_lpn_inspection.vendor_id;
            l_vendor_site_id     := v_rti_lpn_inspection.vendor_site_id;
            l_supplier_site    := v_rti_lpn_inspection.supplier_site;
            l_requestor    := v_rti_lpn_inspection.requestor;
            l_deliver_to_location  := v_rti_lpn_inspection.deliver_to_location;
            l_location_code   := v_rti_lpn_inspection.location;
            l_note_to_receiver      := v_rti_lpn_inspection.note_to_receiver;
            i := i+1;
          END LOOP;
       ELSE
          IF l_debug = 1 THEN
          trace(' old architecture ');
          END IF;
          -- Getting lpn_id from RTI for Rcpt, Putaway, Delivery flows
          FOR v_rti_lpn IN c_rti_lpn LOOP
            l_lpn_table(i) := v_rti_lpn.lpn_id;
            l_purchase_order := v_rti_lpn.purchase_order;
            l_subinventory_code := v_rti_lpn.subinventory;
            l_locator_id := v_rti_lpn.locator_id;
            l_receipt_number     := INV_RCV_COMMON_APIS.g_rcv_global_var.receipt_num;
            l_po_line_number     := v_rti_lpn.po_line_number;
            l_quantity_ordered   := v_rti_lpn.quantity_ordered;
            l_supplier_part_number   := v_rti_lpn.supplier_part_number;
            l_vendor_id       := v_rti_lpn.vendor_id;
            l_vendor_site_id     := v_rti_lpn.vendor_site_id;
            l_supplier_name    := v_rti_lpn.supplier_name;
            l_supplier_site    := v_rti_lpn.supplier_site;
            l_requestor    := v_rti_lpn.requestor;
            l_deliver_to_location  := v_rti_lpn.deliver_to_location;
            l_location_code   := v_rti_lpn.location;
            l_note_to_receiver      := v_rti_lpn.note_to_receiver;
            i := i+1;
          END LOOP;
        END IF; --  p_label_type_info.business_flow_code = 2
      END IF; -- p_transaction_identifier = INV_LABEL.TRX_ID_RT
    ELSIF p_label_type_info.business_flow_code in (6) THEN
      -- Cross-Dock, Pick Load and Pick Drop
      --  The delivery_detail_id of the line in WDD which has the LPN_ID
      --    is passed , get lpn_id from WDD lines
      OPEN c_wdd_lpn;
      FETCH c_wdd_lpn INTO l_lpn_id, p_organization_id, l_subinventory_code;
      IF c_wdd_lpn%NOTFOUND THEN
        IF (l_debug = 1) THEN
           trace(' No cross-dock found in MMTT for ID:'||p_transaction_id);
        END IF;
        CLOSE c_wdd_lpn;
        RETURN;
      ELSE
        IF l_lpn_id IS NOT NULL THEN
          l_lpn_table(1) := l_lpn_id;
          cartonization_flag := 0;
        END IF;
      END IF;

    ELSIF p_label_type_info.business_flow_code in (21) THEN
      -- Ship confirm, delivery_id is passed
      -- Get all the LPNs for this delivery
      FOR v_wnd_lpn IN c_wnd_lpn LOOP
        l_lpn_table(i) := v_wnd_lpn.lpn_id;
        i := i+1;
        cartonization_flag := 0;
      END LOOP;

    ELSIF p_label_type_info.business_flow_code = INV_LABEL.WMS_BF_IMPORT_ASN THEN
      IF ( p_transaction_identifier = INV_LABEL.TRX_ID_RSH) THEN
         -- New Architecture for ASN : Get LPN details from RSH :J-DEV
         -- Applicable with DM.J and IProc.J
         -- First retrieve the header level info
         SELECT shipment_num asn_num, shipped_date shipment_date,
                expected_receipt_date,freight_terms,
                freight_carrier_code, num_of_containers,
                bill_of_lading, waybill_airbill_num,
                packing_slip,
                packaging_code, special_handling_code,
                receipt_num,comments
         INTO l_rcv_isp_header.asn_num, l_rcv_isp_header.shipment_date,
             l_rcv_isp_header.expected_receipt_date, l_rcv_isp_header.freight_terms,
             l_rcv_isp_header.freight_carrier, l_rcv_isp_header.num_of_containers,
             l_rcv_isp_header.bill_of_lading, l_rcv_isp_header.waybill_airbill_num,
             l_rcv_isp_header.packing_slip,
             l_rcv_isp_header.packaging_code, l_rcv_isp_header.special_handling_code,
             l_rcv_isp_header.receipt_num,l_rcv_isp_header.comments
         FROM rcv_shipment_headers
         WHERE shipment_header_id = p_transaction_id;

         -- Next retrieve details of all distinct LPNs associated with this shipment
         FOR v_asn_lpn IN c_asn_lpn
         LOOP
           l_rcv_lpn_table(l_rlpn_ndx).lpn_id := v_asn_lpn.lpn_id;
           l_rcv_lpn_table(l_rlpn_ndx).purchase_order := v_asn_lpn.purchase_order;
           l_rcv_lpn_table(l_rlpn_ndx).subinventory := v_asn_lpn.subinventory_code;
           l_rcv_lpn_table(l_rlpn_ndx).locator_id := v_asn_lpn.locator_id;
           l_rcv_lpn_table(l_rlpn_ndx).due_date := v_asn_lpn.due_date;
           l_rcv_lpn_table(l_rlpn_ndx).truck_num := v_asn_lpn.truck_num;
           l_rcv_lpn_table(l_rlpn_ndx).country_of_origin := v_asn_lpn.country_of_origin_code;
           l_rcv_lpn_table(l_rlpn_ndx).comments := v_asn_lpn.comments;
           l_rcv_lpn_table(l_rlpn_ndx).po_line_num := v_asn_lpn.po_line_number;
           l_rcv_lpn_table(l_rlpn_ndx).quantity_ordered := v_asn_lpn.quantity_ordered;
           l_rcv_lpn_table(l_rlpn_ndx).supplier_part_number := v_asn_lpn.supplier_part_number;
           l_rcv_lpn_table(l_rlpn_ndx).vendor_id := v_asn_lpn.vendor_id;
           l_rcv_lpn_table(l_rlpn_ndx).vendor_site_id := v_asn_lpn.vendor_site_id;
           l_rcv_lpn_table(l_rlpn_ndx).supplier_site := v_asn_lpn.supplier_site;
           l_rcv_lpn_table(l_rlpn_ndx).supplier_name := v_asn_lpn.supplier_name;
           l_rcv_lpn_table(l_rlpn_ndx).requestor := v_asn_lpn.requestor;
           l_rcv_lpn_table(l_rlpn_ndx).deliver_to_location := v_asn_lpn.deliver_to_location;
           l_rcv_lpn_table(l_rlpn_ndx).location := v_asn_lpn.location;
           l_rcv_lpn_table(l_rlpn_ndx).note_to_receiver := v_asn_lpn.note_to_receiver;
              l_rcv_lpn_table(l_rlpn_ndx).packing_slip := v_asn_lpn.packing_slip;

           -- Fields queried from RSH
           l_rcv_lpn_table(l_rlpn_ndx).receipt_num := l_rcv_isp_header.receipt_num;

           l_rlpn_ndx := l_rlpn_ndx + 1;
         END LOOP;
      ELSE
         -- Old Architecture
         l_lpn_table(1) := p_input_param.lpn_id;
      END IF;
      -- Bug 4277718
      -- for WIP completion, lpn_id is used rather than transfer_lpn_id
      -- Changed to use c_mmtt_lpn
    /*ELSIF p_label_type_info.business_flow_code in (26) THEN
      -- WIP Completion
      FOR v_wip_lpn IN c_wip_lpn
      LOOP
        l_lpn_table(i) := v_wip_lpn.transfer_lpn_id;
        i := i+1;
        cartonization_flag := 0;
      END LOOP;*/


     ELSIF p_label_type_info.business_flow_code in (33) AND p_transaction_identifier>1  THEN
       -- Flow Completion, not MMTT based

         IF p_transaction_identifier=2 THEN
              IF (l_debug = 1) THEN
                 trace('Flow Label - MTI based');
              END IF;
              FOR v_flow_mti_lpn IN c_flow_lpn_mti LOOP
           l_lpn_table(i) :=v_flow_mti_lpn.lpn_id;
           l_subinventory_code := v_flow_mti_lpn.subinventory_code;
           i := i+1;
           cartonization_flag := 0;
              END LOOP;
          ELSIF p_transaction_identifier=3 THEN
              IF (l_debug = 1) THEN
                 trace('Flow Label - MOL based');
              END IF;
              FOR v_flow_mol_lpn IN c_flow_lpn_mti LOOP
           l_lpn_table(i) :=v_flow_mol_lpn.lpn_id;
           l_subinventory_code := v_flow_mol_lpn.subinventory_code;
           i := i+1;
           cartonization_flag := 0;
              END LOOP;
         END IF;

    -- Start of change for business flow (22) cartonization for Packaging project.
    ELSIF p_label_type_info.business_flow_code in (22) THEN
      --trace(' Within the business flow code of Cartonization ELSIF');
      -- Cartonization: the lpn_id is in cartonization_id
      -- Set flag to so that packaging history will be checked for items.
      cartonization_flag := 1;

      -- Find the header and packing mode to identify cartonization batch
      -- if no records found, should not try to access wph, so set flag to 0
      BEGIN
        SELECT DISTINCT header_id, packaging_mode, pack_level
        INTO l_header_id, l_packaging_mode, l_max_pack_level
        FROM WMS_PACKAGING_HIST
        WHERE parent_lpn_id = p_transaction_id;
      EXCEPTION
        WHEN no_data_found THEN
         IF (l_debug = 1) THEN
            trace('No record found in WPH with parent_lpn_id: '|| p_transaction_id);
         END IF;
         cartonization_flag := 0;
      END;

      OPEN  c_mmtt_cart_lpn;
      FETCH c_mmtt_cart_lpn
      INTO  l_package_id, l_lpn_id, l_content_volume_uom_code, l_content_volume,
            l_gross_weight_uom_code, l_gross_weight, l_inventory_item_id, l_parent_package_id,
            l_pack_level, l_header_id, l_packaging_mode, l_tare_weight, l_tare_weight_uom_code,
            l_container_item, l_parent_lpn;

      l_outermost_pack_level  :=  l_max_pack_level;

        IF (l_pack_level = 1 AND l_lpn_id IS NOT NULL) THEN
          l_container_item := NULL;
          l_gross_weight := NULL; -- New Addition
          l_gross_weight_uom_code := NULL;  -- New Addition
          l_content_volume := NULL;  -- New Addition
          l_content_volume_uom_code := NULL;   -- New Addition
          l_tare_weight := NULL;   -- New Addition
          l_tare_weight_uom_code := NULL;   -- New Addition

          IF (l_package_id IS NOT NULL) THEN
            l_parent_package_id := l_package_id;
            l_package_id := NULL;
          END IF;

        END IF;

        IF (l_pack_level IS NULL AND l_parent_package_id IS NULL
                                 AND l_inventory_item_id IS NOT NULL) THEN
        -- Items packed directly into the parent_lpn_id
          l_lpn_id := p_transaction_id;
          l_pack_level := 0;
          l_outermost_pack_level := l_outermost_pack_level + 1;
              /* bug #2420787 the container item field is not displayed in
           the label if it is assigned to null. so comment out this code */
          --  l_container_item := NULL;
        END IF;

              --trace(' Got Container Item = ' || l_container_item);
        IF c_mmtt_cart_lpn%NOTFOUND THEN
          IF (l_debug = 1) THEN
             trace(' Finished getting containers ' );
          END IF;
          CLOSE c_mmtt_cart_lpn;
          RETURN;
        END IF;


      l_outermost_lpn_id := p_transaction_id;
      l_lpn_table(1) := null;
    -- End of change for business flow (22) cartonization for Packaging project.
          ELSIF p_label_type_info.business_flow_code in (29) THEN
             -- WIP Pick Drop, the lpn will not be packed, the lpn_id is transfer_lpn_id
             OPEN  c_mmtt_wip_pick_drop_lpn;
             FETCH    c_mmtt_wip_pick_drop_lpn INTO l_lpn_id, p_organization_id,
                  p_inventory_item_id, p_lot_number,
                  p_revision, p_qty, p_uom,
                                l_subinventory_code,l_locator_id,
                        l_secondary_transaction_qty, l_secondary_uom_code; -- invconv fabdi;

                  IF c_mmtt_wip_pick_drop_lpn%NOTFOUND THEN
                       IF (l_debug = 1) THEN
                          trace(' No WIP Pick Drop record found in MMTT for ID: '|| p_transaction_id);
                       END IF;
                       CLOSE c_mmtt_wip_pick_drop_lpn;
                       RETURN;
                  ELSE
                       IF l_lpn_id IS NOT NULL THEN
                          l_lpn_table(1) := l_lpn_id;
                          cartonization_flag := 0;
                       END IF;
                  END IF;

    ELSIF p_label_type_info.business_flow_code in (27) THEN
      -- Putaway pregeneration
      -- Get lpn_id from mmtt
      FOR v_pregen_lpn IN c_mmtt_pregen_lpn LOOP
        l_lpn_table(1) := v_pregen_lpn.lpn_id;
        l_subinventory_code := v_pregen_lpn.subinventory_code;
        l_locator_id := v_pregen_lpn.locator_id;
        cartonization_flag := 0;
      END LOOP;
    -- Fix bug 2167545-1 Cost Group Update(11) is calling label printing through TM
    --   not manually, add 11 in the following group.
    -- Bug 4277718
    -- for WIP completion, lpn_id is used rather than transfer_lpn_id
    -- Changed to use c_mmtt_lpn

    --Bug 4891916. Modified the condition for business flow for cycle count by checking
    --for the business flow 8 and transaction_identifier as 5

    ELSIF p_label_type_info.business_flow_code in (7,/*8,*/9,11,12,13,14,15,19,20,23,30,26)
    OR (p_label_type_info.business_flow_code IN(33) AND p_transaction_identifier=1)
    OR(p_label_type_info.business_flow_code = 8 AND p_transaction_identifier = 5) THEN
      -- Obtain lpn_id, content_lpn_id, transfer_lpn_id from
      -- MMTT record.
      OPEN   c_mmtt_lpn;
      FETCH   c_mmtt_lpn
      INTO    l_from_lpn_id, l_content_lpn_id,l_transfer_lpn_id, l_subinventory_code, l_locator_id,
              l_transaction_type_id, l_transaction_action_id,l_uom;
                                -- Bug 2515486: Added transaction_type_id, transaction_action_id, inventory_item_id       ;

               IF (l_debug = 1) THEN
                             trace('From LPN ID : ' || l_from_lpn_id||
                                   ',Content LPN ID : ' || l_content_lpn_id||
                                   ',Transfer LPN ID : ' || l_transfer_lpn_id||
                                   ',Transaction Type ID : ' || l_transaction_type_id||
                                   ',Transaction Action ID : ' || l_transaction_action_id);
                END IF;

        IF c_mmtt_lpn%NOTFOUND THEN
          IF (l_debug = 1) THEN
             trace(' No lpn_id found in MMTT for given ID: '|| p_transaction_id);
          END IF;
          CLOSE c_mmtt_lpn;
          RETURN;
        ELSE
          CLOSE c_mmtt_lpn;

          -- Bug 4891916. For cycle count, opened the cursor to fetch
          --values for cycle count header name and counter
             IF p_label_type_info.business_flow_code = 8  THEN
               OPEN cc_det_approval;

               FETCH cc_det_approval
                 INTO l_cycle_count_name
                     ,l_requestor;

               IF cc_det_approval%NOTFOUND THEN

                 IF (l_debug = 1) THEN
                   TRACE(' No record found in MMTT with cycle count id for given txn_temp_id: ' || p_transaction_id);
                 END IF;
                 CLOSE cc_det_approval;
              ELSE
                 CLOSE cc_det_approval;
               END IF;
             END IF;--End of business flow=8 condition
          -- End of fix for Bug 4891916

          -- Bug 2515486
          -- This check ensures that the content LPN ID is not added to the l_lpn_table for
          -- LPN Consolidation.
          --Bug # 3277260
          -- Content LPN ID is not added to the l_lpn_table for Pick Drop
          IF (l_content_lpn_id IS NOT NULL) THEN
            IF ((l_transaction_type_id = 87 AND l_transaction_action_id = 50)
                      AND (p_label_type_info.business_flow_code = 20
                           OR p_label_type_info.business_flow_code = 19)) THEN
              NULL;
              IF (l_debug = 1) THEN
                 trace('The Content LPN ID is not added to the l_lpn_table');
              END IF;
            ELSE
              l_lpn_table(i) := l_content_lpn_id;
              IF (l_debug = 1) THEN
                 trace('Content LPN ID has been added to the l_lpn_table');
              END IF;
              i := i+1;
            END IF;
          END IF;

          /* Start of fix for bug # 4716594 */
          /* The following condition has been added for fixing the bug # 4716594
             For Cost Group Update Bussiness Flow (11), only one label has to be generated with
             the updated cost group. Hence the following code (incrementing i, which controls the
             loop iteration) will be executed only if the business flow code is not 11
             i.e. Cost Group Update Business flow */

          IF (p_label_type_info.business_flow_code <> 11) THEN
            IF (l_transfer_lpn_id IS NOT NULL)
                AND(NVL(l_transfer_lpn_id, -999) <> NVL(l_content_lpn_id, -999)) THEN
              l_lpn_table(i)  := l_transfer_lpn_id;
              i               := i + 1;
            END IF;
          END IF;

         /* IF (l_transfer_lpn_id IS NOT NULL) AND (nvl(l_transfer_lpn_id,-999) <> nvl(l_content_lpn_id,-999))
          THEN
            l_lpn_table(i) := l_transfer_lpn_id;
            i := i+1;
          END IF;   */

          /* End of fix for bug # 4716594 */

          -- Bug 2367828 : In case of LPN Splits, the LPN labels were being printed for
          -- the new LPN being generated, but nothing for the existing LPN from which the
          -- the new LPN was being split.   l_from_lpn_id is the mmtt.lpn_id(the from LPN)
          IF (l_from_lpn_id IS NOT NULL) THEN
            l_lpn_table(i) := l_from_lpn_id;
          END IF;
          cartonization_flag := 0;
        END IF;

     -- Bug 4891916. Added the condition to open the cursor to fetch from mcce
     --by checking for business flow 8 and transaction identifier 4
         ELSIF p_label_type_info.business_flow_code = 8 AND p_transaction_identifier = 4  THEN
           IF (l_debug = 1) THEN
             TRACE(' IN the condition for bus flow 8 and pti 4 ');
           END IF;

           OPEN  c_mcce_lpn_cur ;

           FETCH c_mcce_lpn_cur
            INTO p_inventory_item_id
               , p_organization_id
               , p_lot_number
               , p_cost_group_id
               , p_qty
               , p_uom
               , p_revision
               , l_subinventory_code
               , l_locator_id
               , l_lpn_id
               , l_cycle_count_name
               , l_requestor ;

           IF c_mcce_lpn_cur%NOTFOUND THEN
             IF (l_debug = 1) THEN
               TRACE(' No record found in MCCE for cycle count entry_id: ' || p_transaction_id);
             END IF;
             CLOSE c_mcce_lpn_cur;
             RETURN;
           ELSE
             CLOSE c_mcce_lpn_cur;
             IF (l_debug = 1) THEN
               TRACE(' Found details');
               TRACE('Values of p_inventory_item_id:'|| p_inventory_item_id);
               TRACE('Values of p_organization_id:'|| p_organization_id);
               TRACE('Values of p_lot_number:'|| p_lot_number);
               TRACE('Values of p_cost_group_id:'|| p_cost_group_id);
               TRACE('Values of p_qty:'|| p_qty);
               TRACE('Values of p_uom:'|| p_uom);
               TRACE('Values of p_revision:'|| p_revision);
               TRACE('Values of l_subinventory:'|| l_subinventory_code);
               TRACE('Values of l_locator_id:'|| l_locator_id);
               TRACE('Values of l_lpn_id'|| l_lpn_id);
               TRACE('Values of l_cycle_count_name:'|| l_cycle_count_name);
               TRACE('Values of Counter:'|| l_requestor);
            END IF;

            IF l_lpn_id IS NOT NULL THEN
              l_lpn_table(1)      := l_lpn_id;
            END IF;
          END IF;
       --End of fix for Bug 4891916

    -- 18th February 2002 : Commented out below for fix to bug 2219171 for Qualcomm. Hence forth the
    -- WMSTASKB.pls will be calling label printing at Pick Load and WIP Pick Load with the
    -- transaction_temp_id as opposed to the transaction_header_id earlier. These business flows(18, 28)
    -- have been added to  the above call.

    ELSIF p_label_type_info.business_flow_code in (18,28,34) THEN
      OPEN   c_mmtt_lpn_pick_load;
      FETCH   c_mmtt_lpn_pick_load INTO l_lpn_id, p_organization_id,
            p_inventory_item_id, p_lot_number, p_revision,
                    p_qty, p_uom, l_subinventory_code, l_locator_id, l_printer_sub
               , l_secondary_transaction_qty, l_secondary_uom_code; -- invconv fabdi

        IF c_mmtt_lpn_pick_load%NOTFOUND THEN
          IF (l_debug = 1) THEN
             trace(' No record found in MMTT for temp ID: '|| p_transaction_id);
          END IF;
          CLOSE c_mmtt_lpn_pick_load;
          RETURN;
        ELSE
          IF (l_debug = 1) THEN
             trace(' Found lot ' || p_lot_number);
          END IF;
          IF l_lpn_id IS NOT NULL THEN
            l_lpn_table(1) := l_lpn_id;
            cartonization_flag := 0;
          END IF;
        END IF;

    ELSE
      IF (l_debug = 1) THEN
         trace(' Invalid business flow code '|| p_label_type_info.business_flow_code);
      END IF;
      RETURN;
    END IF;

      --Fix for bug 5006693
       IF (p_label_type_info.business_flow_code in (18,19)) THEN
           OPEN  c_order_details;
           FETCH   c_order_details INTO l_sales_order_header_id, l_sales_order_line_id ;
           IF c_order_details%NOTFOUND THEN
             IF (l_debug = 1) THEN
                trace(' No order details for this transaction temp ID: '|| p_transaction_id);
                l_sales_order_header_id := NULL;
                l_sales_order_line_id := NULL;
             END IF;
           END IF;
             IF (l_debug = 1) THEN
                trace(' Order details for this transaction temp ID: '|| p_transaction_id);
                trace(' l_sales_order_header_id '|| l_sales_order_header_id);
                trace(' l_sales_order_line_id '|| l_sales_order_line_id);
             END IF;
             CLOSE c_order_details;
       END IF;
       --End of fix for bug 5006693
  ELSE
    -- On demand, get information from input_param
    -- for transactions which don't have a mmtt row in the table,
    -- they will also call in a manual mode, they are
    -- 5 LPN Correction/Update
    -- 10 Material Status update
    -- 16 LPN Generation
    -- 25 Import ASN
    l_lpn_table(1) := p_input_param.lpn_id;
  END IF;

  IF (l_debug = 1) THEN
     trace(' Got LPN_IDs : '|| l_lpn_table.count);
  END IF;
  FOR i IN 1..l_lpn_table.count LOOP
    IF (l_debug = 1) THEN
       trace( '     '|| l_lpn_table(i));
    END IF;
  END LOOP;
  IF l_lpn_table.count = 0 THEN
    IF (l_debug = 1) THEN
       trace(' @@@@ No LPN found @@@@ ');
    END IF;
  END IF;
  IF (l_debug = 1) THEN
     trace(' Got receiving LPN_IDs : '|| l_rcv_lpn_table.count);
  END IF;
  FOR i IN 0..l_rcv_lpn_table.count-1 LOOP
    IF (l_debug = 1) THEN
       trace( '     '|| l_rcv_lpn_table(i).lpn_id);
    END IF;
  END LOOP;
  IF l_rcv_lpn_table.count = 0 THEN
    IF (l_debug = 1) THEN
       trace(' @@@@ No Receiving LPN found @@@@ ');
    END IF;
  END IF;

     l_content_rec_index := 0;
     l_content_item_data := '';
     IF (l_debug = 1) THEN
   trace('** in PVT4.get_variable_data ** , start ');
     END IF;
     IF l_debug = 1 THEN
   TRACE('P_TRANSACTION_IDENTIFIER ' || p_transaction_identifier || ' l_lpn_id ' || l_lpn_id ||' l_rlpn_ndx' || l_rlpn_ndx);
     END IF;
     IF l_lpn_id IS NULL AND l_rlpn_ndx = 0 THEN
   trace('lpn_id is null ');
   l_lpn_id := l_lpn_table(1);
   IF (l_debug = 1) THEN
      trace('l_lpn_id = ' || l_lpn_id);
   END IF;
      ELSIF l_lpn_id IS NULL AND l_patch_level = 1 AND l_rlpn_ndx <> 0 THEN
   /*   l_lpn_id := l_rcv_lpn_table(l_rlpn_ndx).lpn_id; */
   l_lpn_id := l_rcv_lpn_table(0).lpn_id;
   l_cur_item_id :=  l_rcv_lpn_table(0).item_id;
   IF (l_debug = 1) THEN
      trace('l_lpn_id = ' || l_lpn_id);
   END IF;
     END IF;

  l_lpn_table_index :=0;
  l_label_index := 1;
  IF l_debug = 1 THEN
  trace('l_lpn_table_index ' || l_lpn_table_index);
  END IF;
  l_prev_format_id := -999;
  l_printer := p_label_type_info.default_printer;
   l_prev_sub := '####';



   WHILE l_lpn_id IS NOT NULL OR l_package_id IS NOT NULL LOOP

     IF (l_debug = 1) THEN
           trace('* Inside While l_lpn_id/l_package_id loop, before c_lpn_item_content loop,l_lpn_id=' || nvl(l_lpn_id, 999)
             ||',l_package_id='||nvl(l_package_id, -999)||',l_parent_package_id='||nvl(l_parent_package_id,  -999));
           trace('  p_organization_id='||p_organization_id||', p_inventory_item_id='||p_inventory_item_id);
           trace('  p_lot_number='||p_lot_number||', p_revision='||p_revision||', p_qty='||',p_uom='||p_uom);
           trace('  l_subinventory_code='||l_subinventory_code||', l_locator_id='||l_locator_id||', l_printer_sub='||l_printer_sub);
           trace('  cartonization_flag = '||cartonization_flag);
        END IF;

    l_content_item_data := '';


    -- Bug 4137707, performance of printing at cartonization
    -- Open seperate cursor for cartonization and non-cartonization flow
    --FOR v_lpn_content IN c_lpn_item_content(l_lpn_id, l_package_id, l_cur_item_id) LOOP
    v_lpn_content := NULL;

    --Bug 4891916. To fetch lpn details for cycle count business flow
    IF (p_label_type_info.business_flow_code = 8 AND p_transaction_identifier = 4) THEN
       OPEN c_mcce_lpn_item_content(l_lpn_id);
       IF (l_debug = 1) THEN
         TRACE('before fetch c_mcce_lpn_item_content');
       END IF;

       FETCH c_mcce_lpn_item_content
        INTO v_lpn_content;

       IF (l_debug = 1) THEN
          TRACE('Item is ' || v_lpn_content.inventory_item_id || '  '
             || 'Quantity is ' || v_lpn_content.quantity);
       END IF;

       IF c_mcce_lpn_item_content%NOTFOUND THEN
          IF (l_debug = 1) THEN
             trace('No record found for c_mcce_lpn_item_content');
          END IF;
          CLOSE c_mcce_lpn_item_content;
       END IF;
    ELSIF cartonization_flag = 0 THEN
      -- non cartonization flow

       --Added for bug 7001066 -- Start
      IF(p_label_type_info.business_flow_code in (27)) THEN
        BEGIN
          SELECT inventory_item_id INTO l_cur_item_id
          FROM mtl_material_transactions_temp WHERE lpn_id = l_lpn_id AND transaction_temp_id = p_transaction_id;
            IF (l_debug = 1) THEN
               TRACE('LPN ID :' || l_lpn_id || '  ' || 'Inventory item_id :' || l_cur_item_id);
            END IF;
        EXCEPTION
          WHEN no_data_found THEN
              IF(l_debug =1 ) THEN
                  TRACE('No item found for the lpn id' ||l_lpn_id || ' and ' || 'transaction id' || p_transaction_id);
              END IF;
        END;
      END IF;
      --7001066 -- End

      OPEN c_lpn_item_content(l_lpn_id, l_cur_item_id);
      FETCH c_lpn_item_content INTO v_lpn_content;
      IF c_lpn_item_content%NOTFOUND THEN
          IF (l_debug = 1) THEN
             trace('No record found for c_lpn_item_content');
             --Moved the following statement outside the if block.
             -- as a part of a fix for Bug: -- Fix for 4351366
             --CLOSE c_lpn_item_content;
          END IF;
          -- Fix for 4351366 Start.
            CLOSE c_lpn_item_content;
          -- Fix for 4351366 end.
      END IF;
    ELSE
      -- cartonization flow
      --Added for bug#8816529  start
 	       IF (l_debug = 1) THEN
 	               trace('p_organization_id:-'||p_organization_id);
 	               trace('l_cur_item_id:-'||l_cur_item_id);
 	               trace('l_lpn_id:-'||l_lpn_id);
 	       END IF;

 	       IF (l_cur_item_id IS NULL AND l_lpn_id IS NOT NULL AND p_organization_id IS NULL) THEN
 	                BEGIN
 	                         SELECT
 	                         INVENTORY_ITEM_ID,ORGANIZATION_ID
 	                         INTO
 	                         l_cur_item_id,p_organization_id
 	                         FROM
 	                         wms_lpn_contents
 	                         WHERE
 	                         parent_lpn_id=l_lpn_id;

 	                 EXCEPTION
 	                   WHEN no_data_found THEN
 	                       IF (l_debug = 1) THEN
 	                         trace('Could not retrieve the l_cur_item_id,p_organization_id using lpn id:-'||l_lpn_id);
 	                       END IF;
 	                   WHEN too_many_rows THEN
 	                       IF (l_debug = 1) THEN
 	                         trace('Multiple rows returned for lpn with lpn_id:-'||l_lpn_id);
 	                       END IF;
 	                END;
 	       END IF;

 	       IF (l_debug = 1) THEN
 	               trace('p_organization_id:-'||p_organization_id);
 	               trace('l_cur_item_id:-'||l_cur_item_id);
 	       END IF;
   --Added for bug#8816529  end

      OPEN c_lpn_item_content_cart(l_lpn_id, l_package_id, l_cur_item_id);
      FETCH c_lpn_item_content_cart INTO v_lpn_content;
      IF c_lpn_item_content_cart%NOTFOUND THEN
          IF (l_debug = 1) THEN
             trace('No record found for c_lpn_item_content_cart');
             --Moved the following statement outside the if block.
             -- as a part of a fix for Bug: -- Fix for 4351366
             --CLOSE c_lpn_item_content_cart;
          END IF;
          -- Fix for 4351366 Start.
            CLOSE c_lpn_item_content_cart;
          -- Fix for 4351366 end.
      END IF;
    END IF;


    WHILE v_lpn_content.organization_id IS NOT NULL LOOP

       l_content_rec_index := l_content_rec_index + 1;
      IF (l_debug = 1) THEN
         trace('In v_lpn_content loop, l_content_rec_index='||l_content_rec_index);
      /*   trace('  inventory_item_id=' || v_lpn_content.inventory_item_id || ' Qty=' || nvl(
                    l_rcv_lpn_table(l_lpn_table_index).quantity,v_lpn_content.quantity));*/    --bug 6930405
      END IF;

      /* Bug# 3739739 */
      IF (p_label_type_info.business_flow_code in (7,8,9,11,12,13,14,15,19,20,23,30)) THEN

         -- Fix for BUG: 4654102. For the Buss. Flow 15, the UOM and QTY from WLC should
         -- be considered and therefore the conversion is not required.
         -- Added the AND condition(second part) to the following statement.
         /* Added the business flow code 14 in the second condition for the bug # 4860964 */
         IF(l_uom <> v_lpn_content.uom AND p_label_type_info.business_flow_code NOT IN (14, 15)) THEN
            --Transaction UOM is different from Primary UOM
            --Get the transaction quantity from the primary quantity
            l_qty :=
                     inv_convert.inv_um_convert ( v_lpn_content.inventory_item_id,
                                                  6,
                                                  v_lpn_content.quantity,
                                                  v_lpn_content.uom,
                                                  l_uom,
                                                  NULL,
                                                  NULL
                                                );
            v_lpn_content.quantity := l_qty;
            v_lpn_content.uom := l_uom;
         END IF;
      END IF;
      /* End of Bug# 3739739 */

      -- Fetch LPN information
      OPEN c_lpn_attributes(v_lpn_content.organization_id , l_lpn_id);
      FETCH c_lpn_attributes INTO l_lpn_info;
      CLOSE c_lpn_attributes;

      -- Fetch Item information
      OPEN c_item_attributes(v_lpn_content.organization_id,
                             v_lpn_content.inventory_item_id,
                             v_lpn_content.lot_number);
      FETCH c_item_attributes INTO l_item_info;
      CLOSE c_item_attributes;

  --Bug 5724519 for Misc Rec/Misc Issue
      IF (p_label_type_info.business_flow_code IN (12,13,19, 26, 33)) THEN --Adding the business flows 26 and 33 for Bug 6008065
         OPEN c_lot_attributes(v_lpn_content.organization_id,
                             v_lpn_content.inventory_item_id,
                             v_lpn_content.lot_number);
         FETCH c_lot_attributes INTO l_lot_attribute_info;
         CLOSE c_lot_attributes;
      END IF;


     /* The following code has been added for bug # 4998201 */

      IF (p_label_type_info.business_flow_code IN (1,2,3,4)) THEN
         OPEN c_cost_group(l_lpn_id
                         , v_lpn_content.inventory_item_id
                         , v_lpn_content.lot_number);
         FETCH c_cost_group INTO l_cost_group_id
                               , l_cost_group;
         IF c_cost_group%NOTFOUND THEN
            IF (l_debug = 1) THEN
               trace ('No records returned by c_cost_group cursor');
            END IF;
         END IF;
         CLOSE c_cost_group;

         v_lpn_content.cost_group_id := nvl(v_lpn_content.cost_group_id, l_cost_group_id);
         v_lpn_content.cost_group := nvl(v_lpn_content.cost_group, l_cost_group);

         IF (l_debug = 1) THEN
            trace('v_lpn_content.cost_group is ' || v_lpn_content.cost_group);
         END IF;
      END IF;
      -- End of fix for bug # 4998201

      IF (print_outer) THEN
        l_container_item := l_lpn_info.container_item;
        l_parent_lpn := l_lpn_info.parent_lpn;
      END IF;
         --LPN STATUS project

       IF(inv_cache.set_org_rec(v_lpn_content.organization_id))THEN
         IF((inv_cache.org_rec.default_status_id) IS NOT NULL)THEN
            l_onhand_status_enabled := 1;
            l_default_org_status_id := inv_cache.org_rec.default_status_id ;
            l_serial_controlled := 0;
            IF (l_debug = 1) THEN
               trace('Org is onhand status enabled');
            END IF;
         Else
           l_onhand_status_enabled := 0;
            l_material_status_code := NULL;

         END IF;
       END IF;

       IF (l_onhand_status_enabled = 1 )THEN
          l_item_info.lot_number_status := NULL;
          IF inv_cache.set_item_rec(v_lpn_content.organization_id, v_lpn_content.inventory_item_id) THEN
               IF (inv_cache.item_rec.serial_number_control_code in (2,5)) THEN
                   l_serial_controlled := 1; -- Item is serial controlled
                   IF (l_debug = 1) THEN
                      trace('Item is seiarl controlled so not consedring on hand status');
                  END IF;
                    l_material_status_code := NULL;

               END IF;
          END IF;
          IF (l_serial_controlled <> 1 ) THEN
             IF (l_debug = 1) THEN
                trace('checkin on hand status');
              END IF;
              BEGIN
               select lpn_context into l_lpn_context_id
               from wms_license_plate_numbers
               where lpn_id = l_lpn_id;
              EXCEPTION
                WHEN No_Data_Found THEN
                l_lpn_context_id := -99  ;
                IF (l_debug = 1) THEN
                  trace('unable to find wlpn for the lpn');
                END IF;
               END;

           IF(l_lpn_context_id = WMS_Container_PUB.LPN_CONTEXT_STORES
              OR l_lpn_context_id = WMS_Container_PUB.LPN_CONTEXT_INTRANSIT) THEN
               IF (l_debug = 1) THEN
                  trace('LPN_CONTEXT IS '||l_lpn_context_id||' so no need to check org level default status');
                END IF;
              l_return_status_id :=  l_default_org_status_id;

            ELSE
                IF (l_debug = 1) THEN
                  trace('LPN_CONTEXT IS '||l_lpn_context_id||' so no need to check moqd status');
                END IF;
               IF p_transaction_id is NOT NULL then --for business driven
                   IF p_label_type_info.business_flow_code IN (1,2,3,4) THEN --as they are driven through rt so no need to check mmtt
                    l_src_status_id := NULL;
                     IF (l_debug = 1) THEN
                       trace('Business flow code = '||p_label_type_info.business_flow_code||' so no need to check source status');
                     END IF;
                 ELSE
                    BEGIN
                     SELECT mmtt.transaction_action_id , mmtt.subinventory_code ,
                              mmtt.locator_id ,NVL(mmtt.lpn_id,mmtt.content_lpn_id) ,mmtt.organization_id
                     INTO  l_transaction_action_id , l_src_subinventory_code ,
                           l_src_locator_id ,l_src_lpn_id , l_src_organization_id
                     FROM mtl_material_transactions_temp mmtt
                     WHERE transaction_temp_id = p_transaction_id;
                      IF l_transaction_action_id IN (inv_globals.G_ACTION_SUBXFR,
                                                     inv_globals.G_ACTION_ORGXFR,
                                                     inv_globals.G_ACTION_STGXFR,
                                                     inv_globals.G_ACTION_CONTAINERPACK,
                                                     inv_globals.G_ACTION_CONTAINERUNPACK) THEN --src status is required for only these transactions
                       IF (l_debug = 1) THEN
                       trace('Transaction action id = '||l_transaction_action_id||' so  need to check source status');
                     END IF;
                        BEGIN --querying for source status
                           SELECT moqd.status_id into l_src_status_id
                           FROM mtl_onhand_quantities_detail moqd
                           WHERE inventory_item_id = v_lpn_content.inventory_item_id
                           AND organization_id = l_src_organization_id
                           AND subinventory_code = l_src_subinventory_code
                           AND NVL(lpn_id ,-999) = NVL(l_src_lpn_id,-999)
                           AND nvl( locator_id, -9999) =nvl( l_src_locator_id, -9999)
                           AND nvl(lot_number, '@@@@') = nvl(v_lpn_content.lot_number, '@@@@')
                           AND ROWNUM =1;
                        EXCEPTION
                           when no_data_found  THEN
                            IF (l_debug = 1) THEN
                              trace('unable to find moqd record for source');
                           END IF;
                           l_src_status_id := NULL; --source status is not there so setting to null
                        END;
                      END IF;
                    EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        l_src_status_id := NULL;
                        l_transaction_action_id := NULL;
                     END ;
                  END IF;
               ELSE -- for manual
                  select count(1) into l_count
                  from wms_lpn_contents
                  where parent_lpn_id = l_lpn_id;
                  if l_count = 0 then
                    l_query_moqd := -1;--wlc is not there so not checkin for status for manual driven
                  END IF;
                 l_src_status_id := NULL;
               END IF;
               IF l_query_moqd <> -1 THEN
               l_return_status_id  := INV_MATERIAL_STATUS_GRP.get_default_status --calling function to get the MOQD status
                                                 (p_organization_id   => v_lpn_content.organization_id,
                                                 p_inventory_item_id => v_lpn_content.inventory_item_id,
                                                 p_sub_code => v_lpn_content.subinventory_code,
                                                 p_loc_id => v_lpn_content.locator_id,
                                                 p_lot_number => v_lpn_content.lot_number,
                                                 p_lpn_id => l_lpn_id,
                                                 p_transaction_action_id=> l_transaction_action_id,
                                                 p_src_status_id => l_src_status_id);
             END IF;
             END IF;
             IF (l_debug = 1) THEN
                trace('Status_id returned is  '||l_return_status_id);
             END IF;
            BEGIN
                SELECT status_code INTO l_material_status_code
                FROM mtl_material_statuses_vl
                WHERE status_id = l_return_status_id;
            EXCEPTION
                WHEN No_Data_Found THEN
                  l_material_status_code := NULL;
            END;
            IF (l_debug = 1 ) Then
              trace('l_return_status_id :='||l_return_status_id);
            END IF;
            END IF;
          END IF;
  --End of LPN STATUS project changes


      IF (l_debug = 1) THEN
         trace(' ^^^^^^^^^^^^^^^^^New LAbel^^^^^^^^^^^^^^^^^');
      END IF;


       IF (l_debug = 1) THEN
          trace(' Getting printer, manual_printer='||p_label_type_info.manual_printer
           ||',sub='||nvl(l_printer_sub,v_lpn_content.subinventory_code)
           ||',default printer='||p_label_type_info.default_printer);
       END IF;


       --R12 : RFID compliance project
       --Calling rules engine before calling to get printer
       IF (l_debug = 1) THEN
          trace('Apply Rules engine for format, printer=' || l_printer
         ||',manual_format_id='||p_label_type_info.manual_format_id
         ||',manual_format_name='||p_label_type_info.manual_format_name);
       END IF;

       /* insert a record into wms_label_requests entity to
         call the label rules engine to get appropriate label
    In this call if this happens to be for the label-set, the record
    from wms_label_request will be deleted inside following API*/



    INV_LABEL.GET_FORMAT_WITH_RULE
    (   p_document_id        =>p_label_type_info.label_type_id,
        P_LABEL_FORMAT_ID    =>p_label_type_info.manual_format_id,
        p_organization_id    =>v_lpn_content.organization_id,
        p_inventory_item_id  =>v_lpn_content.inventory_item_id,
        p_subinventory_code  =>v_lpn_content.subinventory_code,
        p_locator_id         =>v_lpn_content.locator_id,
        p_lpn_id             =>l_lpn_id,
        P_LOT_NUMBER         =>v_lpn_content.lot_number,
        p_package_id         =>l_package_id,
        P_REVISION           =>v_lpn_content.revision,
        P_BUSINESS_FLOW_CODE =>p_label_type_info.business_flow_code,
        P_LAST_UPDATE_DATE   =>sysdate,
        P_LAST_UPDATED_BY    =>FND_GLOBAL.user_id,
        P_CREATION_DATE      =>sysdate,
        P_CREATED_BY         =>FND_GLOBAL.user_id,
        --P_PRINTER_NAME       =>l_printer, Removed in R12
        -- Added for Bug 2748297 Start
        P_SUPPLIER_ID        => l_vendor_id,
        P_SUPPLIER_SITE_ID   => l_vendor_site_id,
        -- End
        p_sales_order_header_id => l_sales_order_header_id,-- bug 5006693
        p_sales_order_line_id   => l_sales_order_line_id,  -- bug 5006693
        x_return_status      =>l_return_status,
      x_label_format_id    =>l_label_format_set_id,
      x_label_format       =>l_label_format,
      x_label_request_id   =>l_label_request_id);

       IF l_return_status <> 'S' THEN
        FND_MESSAGE.SET_NAME('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
        FND_MSG_PUB.ADD;
        l_label_format_set_id:= p_label_type_info.default_format_id;
        l_label_format    := p_label_type_info.default_format_name;
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

     -- Bug 4238729, 10+ CU2 bug
     -- Reset l_epc for each LPN
     l_epc := null;


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


         INV_LABEL.GET_FORMAT_WITH_RULE
      (   p_document_id        =>p_label_type_info.label_type_id,
          P_LABEL_FORMAT_ID    =>l_label_formats_in_set.label_format_id, --considers manual printer also
          p_organization_id    =>v_lpn_content.organization_id,
          p_inventory_item_id  =>v_lpn_content.inventory_item_id,
          p_subinventory_code  =>v_lpn_content.subinventory_code,
          p_locator_id         =>v_lpn_content.locator_id,
          p_lpn_id             =>l_lpn_id,
          P_LOT_NUMBER         =>v_lpn_content.lot_number,
          p_package_id         =>l_package_id,
          P_REVISION           =>v_lpn_content.revision,
          P_BUSINESS_FLOW_CODE =>p_label_type_info.business_flow_code,
          P_LAST_UPDATE_DATE   =>sysdate,
          P_LAST_UPDATED_BY    =>FND_GLOBAL.user_id,
          P_CREATION_DATE      =>sysdate,
          P_CREATED_BY         =>FND_GLOBAL.user_id,
          p_use_rule_engine    =>'N', -----Rules ENgine will NOT get called
          -- Added for Bug 2748297 Start
          P_SUPPLIER_ID        => l_vendor_id,
          P_SUPPLIER_SITE_ID   => l_vendor_site_id, -- End
          p_sales_order_header_id => l_sales_order_header_id,-- bug 5006693
          p_sales_order_line_id   => l_sales_order_line_id,  -- bug 5006693
          x_return_status      =>l_return_status,
          x_label_format_id    =>l_label_format_id,
          x_label_format       =>l_label_format,
          x_label_request_id   =>l_label_request_id);

         IF l_return_status <> 'S' THEN
          FND_MESSAGE.SET_NAME('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
          FND_MSG_PUB.ADD;
          l_label_format_id:= p_label_type_info.default_format_id;
          l_label_format  := p_label_type_info.default_format_name;
         END IF;

         IF (l_debug = 1) THEN
          trace('did apply label ' || l_label_format || ',' || l_label_format_id||',req_id '||l_label_request_id);
         END IF;
       ELSE --IT IS LABEL FORMAT
         --Just use the format-id returned
         l_label_format_id :=  l_label_formats_in_set.label_format_id ;
      END IF;


      -- IF clause Added for Add format/printer for manual request
      IF p_label_type_info.manual_printer IS NULL THEN
         -- The p_label_type_info.manual_printer is the one  passed from the manual page.
         -- As per the design, if a printer is passed from the manual page, then we use that printer irrespective.
         IF (nvl(l_printer_sub,v_lpn_content.subinventory_code) IS NOT NULL) AND
      (nvl(l_printer_sub,v_lpn_content.subinventory_code) <>l_prev_sub)THEN
       IF (l_debug = 1) THEN
          trace('getting printer with sub ' || nvl(l_printer_sub,v_lpn_content.subinventory_code));
       END IF;
            BEGIN

          WSH_REPORT_PRINTERS_PVT.get_printer
       (
        p_concurrent_program_id=>p_label_type_info.label_type_id,
        p_user_id              =>fnd_global.user_id,
        p_responsibility_id    =>fnd_global.resp_id,
        p_application_id       =>fnd_global.resp_appl_id,
        p_organization_id      =>v_lpn_content.organization_id,
        p_zone                 =>nvl(l_printer_sub,v_lpn_content.subinventory_code),
        p_format_id            => l_label_format_id, --added in r12 RFID
        x_printer              =>l_printer,
        x_api_status           =>l_api_status,
        x_error_message        =>l_error_message);

          IF l_api_status <> 'S' THEN
        IF (l_debug = 1) THEN
           trace('Error in calling get_printer, set printer as default printer, err_msg:'||l_error_message);
        END IF;
        l_printer := p_label_type_info.default_printer;
          END IF;
            EXCEPTION
          WHEN others THEN
        l_printer := p_label_type_info.default_printer;
            END;
            l_prev_sub := nvl(l_printer_sub,v_lpn_content.subinventory_code);
         END IF;
       ELSE
       IF (l_debug = 1) THEN
          trace('Set printer as Manual Printer passed in:' || p_label_type_info.manual_printer );
       END IF;
       l_printer := p_label_type_info.manual_printer;
      END IF;

      IF (l_debug = 1) THEN
         trace(' ######## printing l_label_format_id :'||l_label_format_id);
      END IF;


      IF (l_label_format_id IS NOT NULL) THEN
        -- Derive the fields for the format either passed in or derived via the rules engine.
        IF l_label_format_id <> nvl(l_prev_format_id, -999) THEN
          IF (l_debug = 1) THEN
             trace(' Getting variables for new format ' || l_label_format);
          END IF;

     /* Changed for R12 RFID project
     * while getting variables for format
       * Check whether EPC field is included in the format
       * If it is included, it will later query WMS_LABEL_FORMATS
       * table to get RFID related information
       * Otherwise, it does not need to do that
       */

       INV_LABEL.GET_VARIABLES_FOR_FORMAT(
                      x_variables         => l_selected_fields
                      ,  x_variables_count  => l_selected_fields_count
                      ,  x_is_variable_exist     => l_is_epc_exist
                      ,  p_format_id             => l_label_format_id
                      ,  p_exist_variable_name   => 'EPC'
                      );

          l_prev_format_id := l_label_format_id;

          IF (l_selected_fields_count=0) OR (l_selected_fields.count =0 ) THEN
            IF (l_debug = 1) THEN
               trace('no fields defined for this format: ' || l_label_format|| ',' ||l_label_format_id);
          trace('##############GOING TO NEXT LABEL#####################');
       END IF;

       GOTO NextLabel;
          END IF;
          IF (l_debug = 1) THEN
             trace('   Found selected_fields for format ' || l_label_format ||', num='|| l_selected_fields_count);
          END IF;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
           trace('No format exists for this label, goto nextlabel');
        END IF;
        GOTO NextLabel;
      END IF;

         -- Added for UCC 128 J Bug #3067059
         INV_LABEL.IS_ITEM_GTIN_ENABLED(
              x_return_status      =>   l_return_status
            , x_gtin_enabled       =>   l_gtin_enabled
            , x_gtin               =>   l_gtin
            , x_gtin_desc          =>   l_gtin_desc
            , p_organization_id    =>   v_lpn_content.organization_id
            , p_inventory_item_id  =>   v_lpn_content.inventory_item_id
            , p_unit_of_measure    =>   v_lpn_content.uom
            , p_revision           =>   v_lpn_content.revision);


        -- Added for 11.5.10+ RFID compliance project
        -- Get RFID/EPC related information for a format
        -- Only do this if EPC is a field included in the format
    IF l_is_epc_exist = 'Y' THEN
            IF (l_debug =1) THEN
          trace('EPC is a field included in the format, getting RFID/EPC related information from format');
            END IF;
            BEGIN

          -- Modified in R12-- changed spec WMS_EPC_PVT.generate_epc()
          -- Added for 11.5.10+ RFID Compliance project
          -- New field : EPC
          -- When generate_epc API returns E (expected error) or U(expected error),
          --   it sets the error message, but generate xml with EPC as null

          -- Bug 4238729, 10+ CU2 bug
          -- Only need to call EPC generation once for each LPN
          -- Added new parameter p_business_flow_code
          IF l_epc IS NULL THEN
        IF (l_debug = 1) THEN
                       trace('l_epc is null, calling generate_epc');
                   END IF;

         WMS_EPC_PVT.generate_epc
           (p_org_id          => v_lpn_content.organization_id,
            p_label_type_id   => p_label_type_info.label_type_id, -- 4
            p_group_id  => inv_label.epc_group_id,
            p_label_format_id => l_label_format_id,
            p_label_request_id    => l_label_request_id,
            p_business_flow_code  => p_label_type_info.business_flow_code,
            x_epc                 => l_epc,
            x_return_status       => l_epc_ret_status, -- S / E / U
            x_return_mesg         => l_epc_ret_msg
            );

                   IF (l_debug = 1) THEN
                      trace('Called generate_epc with ');
                      trace('l_label_request_id='||l_label_request_id||',p_group_id='||inv_label.epc_group_id);
                      trace('l_label_format_id='||l_label_format_id||',p_user_id='||fnd_global.user_id);
                      trace('business_flow_code='||p_label_type_info.business_flow_code||',p_org_id='||v_lpn_content.organization_id);
            trace('label_type_id='||p_label_type_info.label_type_id);
            trace('x_epc='||l_epc);
                      trace('x_return_status='||l_epc_ret_status);
                      trace('x_return_mesg='||l_epc_ret_msg);
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
                          trace('Set l_epc = null');
                      END IF;
                   ELSIF l_epc_ret_status = 'E' THEN
                      -- Expected error
                      l_epc := null;
                      IF(l_debug = 1) THEN
                          trace('Got expected error from generate_epc, msg='||l_epc_ret_msg);
                          trace('Set l_epc = null');
                      END IF;
                   ELSE
                            trace('generate_epc returned a status that is not recognized');
                   END IF;
                 ELSE -- l_epc is not null
                   IF (l_debug = 1) THEN
                            trace('generate_epc returned a status that is not recognized, set epc as null');
                            l_epc := null;
                   END IF;
                 END IF;
                 -- End Bug 4238729


            EXCEPTION
                WHEN no_data_found THEN
                    IF(l_debug =1 ) THEN
                       trace('No format found when retrieving EPC information.Format_id='||l_label_format_id);
                    END IF;
                WHEN others THEN
                    IF(l_debug =1 ) THEN
                       trace('Other error when retrieving EPC information.Format_id='||l_label_format_id);
                    END IF;
            END;
        ELSE
            IF (l_debug =1) THEN
                trace('EPC is not a field included in the format');
            END IF;
        END IF;

       /* variable header */
      l_label_status := INV_LABEL.G_SUCCESS;
      l_label_err_msg := NULL;
      l_content_item_data := l_content_item_data || LABEL_B;
      IF l_label_format <> nvl(p_label_type_info.default_format_name, '@@@') THEN
        l_content_item_data := l_content_item_data || ' _FORMAT="' ||l_label_format || '"';
      END IF;
      IF (l_printer IS NOT NULL) AND (l_printer <> nvl(p_label_type_info.default_printer,'###')) THEN
        l_content_item_data := l_content_item_data || ' _PRINTERNAME="'||l_printer||'"';
      END IF;

      l_content_item_data := l_content_item_data || TAG_E;

      IF (l_debug = 1) THEN
         trace('Starting assign variables, ');
      END IF;
      l_column_name_list := 'Set variables for ';

      l_custom_sql_ret_status := FND_API.G_RET_STS_SUCCESS;

      -- Fix for bug: 4179593 Start
      l_CustSqlWarnFlagSet := FALSE;
      l_CustSqlErrFlagSet := FALSE;
      l_CustSqlWarnMsg := NULL;
      l_CustSqlErrMsg := NULL;
      -- Fix for bug: 4179593 End

      /* Loop for each selected fields, find the columns and write into the XML_content*/
      FOR i IN 1..l_selected_fields.count LOOP
        IF (l_debug = 1) THEN
             l_column_name_list := l_column_name_list || ',' ||l_selected_fields(i).column_name;
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
              trace('Custom Labels Trace [INVLAP4B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
              trace('Custom Labels Trace [INVLAP4B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
              trace('Custom Labels Trace [INVLAP4B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
              trace('Custom Labels Trace [INVLAP4B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
              trace('Custom Labels Trace [INVLAP4B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
             END IF;
             l_sql_stmt := l_selected_fields(i).sql_stmt;
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP4B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
             END IF;
             l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP4B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
             END IF;
             BEGIN
             IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP4B.pls]: At Breadcrumb 1');
              trace('Custom Labels Trace [INVLAP4B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
             END IF;
             OPEN c_sql_stmt FOR l_sql_stmt using l_label_request_id;
             LOOP
                 FETCH c_sql_stmt INTO l_sql_stmt_result;
                 EXIT WHEN c_sql_stmt%notfound OR c_sql_stmt%rowcount >=2;
             END LOOP;

          IF (c_sql_stmt%rowcount=1 AND l_sql_stmt_result IS NULL) THEN
               x_return_status := FND_API.G_RET_STS_SUCCESS;
               l_custom_sql_ret_status  := INV_LABEL.G_WARNING;
               fnd_message.set_name('WMS','WMS_CS_NULL_VALUE_RETURNED');
               fnd_msg_pub.ADD;
               -- Fix for bug: 4179593 Start
               --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
               l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
               l_CustSqlWarnMsg := l_custom_sql_ret_msg;
               l_CustSqlWarnFlagSet := TRUE;
               -- Fix for bug: 4179593 End
             IF (l_debug = 1) THEN
               trace('Custom Labels Trace [INVLAP4B.pls]: At Breadcrumb 2');
               trace('Custom Labels Trace [INVLAP4B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
               trace('Custom Labels Trace [INVLAP4B.pls]: WARNING: NULL value returned by the custom SQL Query.');
               trace('Custom Labels Trace [INVLAP4B.pls]: l_custom_sql_ret_status  is set to : ' || l_custom_sql_ret_status );
             END IF;
          ELSIF c_sql_stmt%rowcount=0 THEN
                IF (l_debug = 1) THEN
                 trace('Custom Labels Trace [INVLAP4B.pls]: At Breadcrumb 3');
             trace('Custom Labels Trace [INVLAP4B.pls]: WARNING: No row returned by the Custom SQL query');
                END IF;
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_custom_sql_ret_status  := INV_LABEL.G_WARNING;
                fnd_message.set_name('WMS','WMS_CS_NO_DATA_FOUND');
                fnd_msg_pub.ADD;
                /* Replaced following statement for Bug 4207625: Anupam Jain*/
                 /*fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_status);*/
                -- Fix for bug: 4179593 Start
                --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                l_CustSqlWarnFlagSet := TRUE;
                -- Fix for bug: 4179593 End
             ELSIF c_sql_stmt%rowcount>=2 THEN
                IF (l_debug = 1) THEN
                 trace('Custom Labels Trace [INVLAP4B.pls]: At Breadcrumb 4');
                 trace('Custom Labels Trace [INVLAP4B.pls]: ERROR: Multiple values returned by the Custom SQL query');
                END IF;
            l_sql_stmt_result := NULL;
                x_return_status := FND_API.G_RET_STS_SUCCESS;
            l_custom_sql_ret_status  := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('WMS','WMS_CS_MULTIPLE_VALUES_RETURN');
                fnd_msg_pub.ADD;
                /* Replaced following statement for Bug 4207625: Anupam Jain*/
                 /*fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_status);*/
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
                 trace('Custom Labels Trace [INVLAP4B.pls]: At Breadcrumb 5');
             trace('Custom Labels Trace [INVLAP4B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
              END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
              fnd_msg_pub.ADD;
              fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
         IF (l_debug = 1) THEN
              trace('Custom Labels Trace [INVLAP4B.pls]: At Breadcrumb 6');
              trace('Custom Labels Trace [INVLAP4B.pls]: Before assigning it to l_content_item_data');
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
              trace('Custom Labels Trace [INVLAP4B.pls]: At Breadcrumb 7');
              trace('Custom Labels Trace [INVLAP4B.pls]: After assigning it to l_content_item_data');
           trace('Custom Labels Trace [INVLAP4B.pls]: --------------------------REPORT END-------------------------------------');
            END IF;
------------------------End of this changes for Custom Labels project code--------------------
         ELSIF LOWER(l_selected_fields(i).column_name) = 'current_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || INV_LABEL.G_DATE || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'current_time' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || INV_LABEL.G_TIME || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'request_user' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || INV_LABEL.G_USER || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'parent_lpn' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_parent_lpn || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'volume' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.volume || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'volume_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.volume_uom || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'gross_weight' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.gross_weight || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'gross_weight_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.gross_weight_uom || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'tare_weight' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.tare_weight || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'tare_weight_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.tare_weight_uom || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'po_num' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
            trace('po_num ' ||  l_rcv_lpn_table(l_lpn_table_index).purchase_order);
            l_content_item_data := l_content_item_data || VARIABLE_B ||
             l_selected_fields(i).variable_name || '">' ||   l_rcv_lpn_table(l_lpn_table_index).purchase_order || VARIABLE_E;
             else
            l_content_item_data := l_content_item_data || VARIABLE_B ||
             l_selected_fields(i).variable_name || '">' || l_purchase_order || VARIABLE_E;
          end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'organization' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.organization || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_code' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || v_lpn_content.subinventory_code || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'locator' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || v_lpn_content.locator || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'client_item' THEN		-- Added for LSP Project, bug 9087971
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.client_item || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_description' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_description || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'revision' THEN
        --Bug# 7565852
	if p_label_type_info.business_flow_code <> 1 then
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || v_lpn_content.revision || VARIABLE_E;
          else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rev_t(l_lpn_table_index) || VARIABLE_E;
        end if ;
        --Bug# 7565852
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || v_lpn_content.lot_number || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_status' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_number_status || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_expiration_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_expiration_date || VARIABLE_E;
	   /* for Bug 6930405 */
         ELSIF LOWER(l_selected_fields(i).column_name) = 'quantity' THEN
	if ( l_rlpn_ndx <> 0 ) then
           l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_selected_fields(i).variable_name || '">' ||  l_rcv_lpn_table(l_lpn_table_index).quantity || VARIABLE_E;
   	else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_selected_fields(i).variable_name || '">' || v_lpn_content.quantity || VARIABLE_E;
  	end if;
	   /* for Bug 6930405 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || v_lpn_content.uom || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'cost_group' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || v_lpn_content.cost_group || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_hazard_class' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_hazard_class || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute_category' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute_category || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute1' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute1 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute2' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute2 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute3' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute3 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute4' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute4 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute5' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute5 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute6' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute6 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute7' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute7 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute8' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute8 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute9' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute9 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute10' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute10 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute11' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute11 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute12' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute12 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute13' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute13 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute14' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute14 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute15' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.item_attribute15 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute_category' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute_category || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute1' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute1 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute2' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute2 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute3' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute3 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute4' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute4 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute5' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute5 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute6' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute6 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute7' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute7 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute8' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute8 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute9' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute9 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute10' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute10 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute11' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute11 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute12' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute12 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute13' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute13 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute14' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.lpn_attribute14 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute15' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
	     l_selected_fields(i).variable_name || '">' ||
	     l_lpn_info.lpn_attribute15 || VARIABLE_E;

ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_attribute_category' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_attribute_category || VARIABLE_E;

	   /*
	    8886501
       ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute1' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute1 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute2' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute2 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute3' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute3 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute4' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute4 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute5' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute5 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute6' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute6 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute7' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute7 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute8' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute8 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute9' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute9 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute10' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute10 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute11' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute11 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute12' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute12 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute13' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute13 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute14' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute14 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute15' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute15 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute16' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute16 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute17' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute17 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute18' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute18 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute19' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute19 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute20' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_c_attribute20 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute1' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_d_attribute1 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute2' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_d_attribute2 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute3' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_d_attribute3 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute4' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_d_attribute4 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute5' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_d_attribute5 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute6' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_d_attribute6 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute7' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_d_attribute7 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute8' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_d_attribute8 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute9' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_d_attribute9 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute10' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_d_attribute10 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute1' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_n_attribute1 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute2' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_n_attribute2 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute3' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_n_attribute3 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute4' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_n_attribute4 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute5' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_n_attribute5 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute6' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_n_attribute6 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute7' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_n_attribute7 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute8' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_n_attribute8 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute9' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_n_attribute9 || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute10' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_n_attribute10 || VARIABLE_E;

	 8886501  */

	 /*8886501
	 ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_country_of_origin' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_country_of_origin || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_grade_code' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_grade_code || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_origination_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_origination_date || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_date_code' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_date_code || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_change_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_change_date || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_age' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_age || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_retest_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_retest_date || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_maturity_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_maturity_date || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_item_size' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_item_size || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_color' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_color || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_volume' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_volume || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_volume_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_volume_uom || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_place_of_origin' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_item_info.lot_place_of_origin || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_best_by_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' ||
	 l_item_info.lot_best_by_date || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_length' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_length|| VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_length_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_length_uom|| VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_recycled_cont' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_recycled_cont|| VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_thickness' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_thickness|| VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_thickness_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_selected_fields(i).variable_name || '">' || l_item_info.lot_thickness_uom|| VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_width' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' ||l_item_info.lot_width|| VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_width_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.lot_width_uom|| VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_curl' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_selected_fields(i).variable_name || '">' || l_item_info.lot_curl|| VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_vendor' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
	   l_selected_fields(i).variable_name || '">' ||
	  l_item_info.lot_vendo || VARIABLE_E;
     8886501   */

    ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute1' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute1,l_item_info.lot_c_attribute1) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute2' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute2,l_item_info.lot_c_attribute2) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute3' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute3,l_item_info.lot_c_attribute3) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute4' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute4,l_item_info.lot_c_attribute4) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute5' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute5,l_item_info.lot_c_attribute5) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute6' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute6,l_item_info.lot_c_attribute6) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute7' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute7,l_item_info.lot_c_attribute7) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute8' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute8,l_item_info.lot_c_attribute8) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute9' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute9,l_item_info.lot_c_attribute9) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute10' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute10,l_item_info.lot_c_attribute10) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute11' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute11,l_item_info.lot_c_attribute11) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute12' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute12,l_item_info.lot_c_attribute12) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute13' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute13,l_item_info.lot_c_attribute13) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute14' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute14,l_item_info.lot_c_attribute14) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute15' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute15,l_item_info.lot_c_attribute15) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute16' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute16,l_item_info.lot_c_attribute16) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute17' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute17,l_item_info.lot_c_attribute17) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute18' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute18,l_item_info.lot_c_attribute18) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute19' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute19,l_item_info.lot_c_attribute19) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute20' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_c_attribute20,l_item_info.lot_c_attribute20) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute1' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_d_attribute1,l_item_info.lot_d_attribute1) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute2' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_d_attribute2,l_item_info.lot_d_attribute2) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute3' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_d_attribute3,l_item_info.lot_d_attribute3) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute4' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_d_attribute4,l_item_info.lot_d_attribute4) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute5' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_d_attribute5,l_item_info.lot_d_attribute5) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute6' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_d_attribute6,l_item_info.lot_d_attribute6) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute7' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_d_attribute7,l_item_info.lot_d_attribute7) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute8' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_d_attribute8,l_item_info.lot_d_attribute8) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute9' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_d_attribute9,l_item_info.lot_d_attribute9) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute10' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_d_attribute10,l_item_info.lot_d_attribute10) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute1' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_n_attribute1,l_item_info.lot_n_attribute1) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute2' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_n_attribute2,l_item_info.lot_n_attribute2) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute3' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_n_attribute3,l_item_info.lot_n_attribute3) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute4' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_n_attribute4,l_item_info.lot_n_attribute4) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute5' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_n_attribute5,l_item_info.lot_n_attribute5) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute6' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_n_attribute6,l_item_info.lot_n_attribute6) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute7' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_n_attribute7,l_item_info.lot_n_attribute7) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute8' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_n_attribute8,l_item_info.lot_n_attribute8) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute9' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_n_attribute9,l_item_info.lot_n_attribute9) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute10' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_n_attribute10,l_item_info.lot_n_attribute10) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_country_of_origin' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_country_of_origin,l_item_info.lot_country_of_origin) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_grade_code' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_grade_code,l_item_info.lot_grade_code) || VARIABLE_E; /* Changed for the bug # 4725393 */
    ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_origination_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_origination_date,l_item_info.lot_origination_date) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_date_code' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_date_code,l_item_info.lot_date_code) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_change_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_change_date,l_item_info.lot_change_date) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_age' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_age,l_item_info.lot_age) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_retest_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_retest_date,l_item_info.lot_retest_date) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_maturity_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_maturity_date,l_item_info.lot_maturity_date) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_item_size' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_item_size,l_item_info.lot_item_size) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_color' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_color,l_item_info.lot_color) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_volume' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_volume,l_item_info.lot_volume) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_volume_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_volume_uom,l_item_info.lot_volume_uom) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_place_of_origin' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_place_of_origin,l_item_info.lot_place_of_origin) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_best_by_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_best_by_date,l_item_info.lot_best_by_date) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_length' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_length,l_item_info.lot_length) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_length_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_length_uom,l_item_info.lot_length_uom) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_recycled_cont' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_recycled_cont,l_item_info.lot_recycled_cont) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_thickness' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_thickness,l_item_info.lot_thickness) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_thickness_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_thickness_uom,l_item_info.lot_thickness_uom) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_width' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_width,l_item_info.lot_width) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_width_uom' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_width_uom,l_item_info.lot_width_uom) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_curl' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_curl,l_item_info.lot_curl) || VARIABLE_E; /* Changed for the bug # 4725393 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_vendor' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || nvl(l_lot_attribute_info.lot_vendor,l_item_info.lot_vendor) || VARIABLE_E; /* Changed for the bug # 4725393 */




        ELSIF LOWER(l_selected_fields(i).column_name) = 'receipt_num' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).receipt_num || VARIABLE_E;
             else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_receipt_number || VARIABLE_E;
             end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'po_line_num' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).po_line_num || VARIABLE_E;
             else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_po_line_number || VARIABLE_E;
             end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'quan_ordered' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).quantity_ordered || VARIABLE_E;
             else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_quantity_ordered || VARIABLE_E;
             end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'supp_part_num' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).supplier_part_number || VARIABLE_E;
             else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_supplier_part_number || VARIABLE_E;
             end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'supp_name' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).supplier_name || VARIABLE_E;
             else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_supplier_name || VARIABLE_E;
             end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'supp_site' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).supplier_site || VARIABLE_E;
             else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_supplier_site || VARIABLE_E;
             end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'requestor' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).requestor || VARIABLE_E;
             else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_requestor || VARIABLE_E;
             end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'deliver_to_loc' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).deliver_to_location || VARIABLE_E;
             else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_deliver_to_location || VARIABLE_E;
             end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'loc_id' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).location || VARIABLE_E;
             else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_location_code || VARIABLE_E;
             end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'note_to_receiver' THEN
             if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).note_to_receiver || VARIABLE_E;
             else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_note_to_receiver || VARIABLE_E;
             end if;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'package_id' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_package_id || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'parent_package_id' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_parent_package_id || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'container_item' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_container_item || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'pack_level' THEN
             IF(l_lpn_id = p_transaction_id) THEN
                l_content_item_data := l_content_item_data || VARIABLE_B ||
                l_selected_fields(i).variable_name || '">' || l_outermost_pack_level || VARIABLE_E;
             ELSE
                l_content_item_data := l_content_item_data || VARIABLE_B ||
                l_selected_fields(i).variable_name || '">' || l_pack_level || VARIABLE_E;
             END IF;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'outermost_lpn' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_lpn_info.outermost_lpn || VARIABLE_E;
            -- Added for UCC 128 J Bug #3067059
        ELSIF LOWER(l_selected_fields(i).column_name) = 'gtin' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_gtin || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'gtin_description' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_gtin_desc || VARIABLE_E;

        --  New fields for iSP: line-level  : J-DEV
        ELSIF LOWER(l_selected_fields(i).column_name) = 'comments_line' THEN
             /* Modified for bug 4080297 -start */
             if ( l_rlpn_ndx <> 0 ) then
               l_content_item_data := l_content_item_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).comments || VARIABLE_E;
             else
               l_content_item_data := l_content_item_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || VARIABLE_E;
             end if;
            /* Modified for bug 4080297 -end */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'packing_slip_line' THEN
             /* Modified for bug 4080297 -start */
             if ( l_rlpn_ndx <> 0 ) then
               l_content_item_data := l_content_item_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).packing_slip || VARIABLE_E;
             else
               l_content_item_data := l_content_item_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || VARIABLE_E;
             end if;
            /* Modified for bug 4080297 -end */

        --  New fields for iSP: line-level  : J-DEV
        ELSIF LOWER(l_selected_fields(i).column_name) = 'shipment_due_date' THEN
             /* Modified for bug 4080297 -start */
             if ( l_rlpn_ndx <> 0 ) then
               l_content_item_data := l_content_item_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).due_date || VARIABLE_E;
             else
               l_content_item_data := l_content_item_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || VARIABLE_E;
             end if;
            /* Modified for bug 4080297 -end */
        --  New fields for iSP: line-level  : J-DEV
        ELSIF LOWER(l_selected_fields(i).column_name) = 'truck_number' THEN
             /* Modified for bug 4080297 -start */
             if ( l_rlpn_ndx <> 0 ) then
               l_content_item_data := l_content_item_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).truck_num || VARIABLE_E;
             else
               l_content_item_data := l_content_item_data || VARIABLE_B ||
               l_selected_fields(i).variable_name || '">' || VARIABLE_E;
             end if;
            /* Modified for bug 4080297 -end */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'country_of_origin' THEN
            /* Modified for bug 4080297 -start */
             if ( l_rlpn_ndx <> 0 ) then
                l_content_item_data := l_content_item_data || VARIABLE_B ||
                l_selected_fields(i).variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).country_of_origin || VARIABLE_E;
             else
                l_content_item_data := l_content_item_data || VARIABLE_B ||
                l_selected_fields(i).variable_name || '">' || VARIABLE_E;
             end if;
            /* Modified for bug 4080297 -end */
        --  New fields for iSP: header-level  : J-DEV
        ELSIF LOWER(l_selected_fields(i).column_name) = 'asn_number' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.asn_num || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'shipment_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.shipment_date || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'expct_rcpt_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.expected_receipt_date || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'freight_terms' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.freight_terms || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'freight_carrier' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.freight_carrier || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'num_of_containers' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.num_of_containers || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'bill_of_lading' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.bill_of_lading || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'waybill_airbill_num' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.waybill_airbill_num || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'packing_slip_header' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.packing_slip || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'comments_header' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.comments || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'packaging_code' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.packaging_code || VARIABLE_E;
        ELSIF LOWER(l_selected_fields(i).column_name) = 'special_handling_code' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_rcv_isp_header.special_handling_code || VARIABLE_E;
        --Bug 4891916. Added for the field Cycle Count Name
        ELSIF LOWER(l_selected_fields(i).column_name) = 'cycle_count_name' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_cycle_count_name || variable_e;
        --End of fix for Bug 4891916


/* 8430171 */
        ELSIF LOWER(l_selected_fields(i).column_name) = 'project' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_project_name || variable_e;

	   ELSIF LOWER(l_selected_fields(i).column_name) = 'task' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_task_name || variable_e;
/* 8430171  */


	   -- Added for 11.5.10+ RFID Compliance project
          -- New field : EPC
          -- EPC is generated once for each LPN
        ELSIF LOWER(l_selected_fields(i).column_name) = 'epc' THEN
            l_content_item_data := l_content_item_data || variable_b ||
              l_selected_fields(i).variable_name || '">' || l_epc || variable_e;
              l_label_err_msg := l_epc_ret_msg;
              IF l_epc_ret_status = 'U' THEN
                  l_label_status := INV_LABEL.G_ERROR;
              ELSIF l_epc_ret_status = 'E' THEN
                  l_label_status := INV_LABEL.G_WARNING;

               END IF;
   -- INVCONV changes start

        ELSIF LOWER(l_selected_fields(i).column_name) = 'parent_lot_number' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_selected_fields(i).variable_name || '">' || l_item_info.parent_lot_number || VARIABLE_E;

        ELSIF LOWER(l_selected_fields(i).column_name) = 'hold_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_selected_fields(i).variable_name || '">' || l_item_info.hold_date || VARIABLE_E;

        ELSIF LOWER(l_selected_fields(i).column_name) = 'expiration_action_date' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_selected_fields(i).variable_name || '">' || l_item_info.expiration_action_date || VARIABLE_E;

        ELSIF LOWER(l_selected_fields(i).column_name) = 'expiration_action_code' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_selected_fields(i).variable_name || '">' || l_item_info.expiration_action_code || VARIABLE_E;

        ELSIF LOWER(l_selected_fields(i).column_name) = 'origination_type' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_selected_fields(i).variable_name || '">' || l_item_info.origination_type || VARIABLE_E;

        ELSIF LOWER(l_selected_fields(i).column_name) = 'secondary_transaction_quantity' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || v_lpn_content.secondary_quantity || VARIABLE_E;

        ELSIF LOWER(l_selected_fields(i).column_name) = 'secondary_uom_code' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || v_lpn_content.secondary_uom || VARIABLE_E;

        ELSIF LOWER(l_selected_fields(i).column_name) = 'supplier_lot_number' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_item_info.supplier_lot_number || VARIABLE_E;

   -- INVCONV changes END
   --LPN STATUS Project changes start
      ELSIF LOWER(l_selected_fields(i).column_name) = 'material_status' THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_selected_fields(i).variable_name || '">' || l_material_status_code || variable_e;
   --LPN STATUS Project changes end


        END IF;

      END LOOP;
      l_content_item_data := l_content_item_data || LABEL_E;
      IF (l_debug = 1) THEN
        trace(l_column_name_list);
          trace(' Finished writing item variables  ');
      END IF;
      x_variable_content(l_label_index).label_content := l_content_item_data;
      x_variable_content(l_label_index).label_request_id := l_label_request_id;
      x_variable_content(l_label_index).label_status := l_label_status;
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


      <<NextLabel>>

   l_content_item_data := '';
      l_label_request_id := null;
      ------------------------Start of changes for Custom Labels project code------------------
        l_custom_sql_ret_status  := NULL;
        l_custom_sql_ret_msg     := NULL;
------------------------End of this changes for Custom Labels project code---------------

        -- Bug 4137707: performance of printing at cartonization
        -- Replaced the FOR LOOP
        -- Need to fetch record again for cartonization or non-cartonization flow

        --Bug 4891916. To fetch lpn details cycle count business flow
        IF (p_label_type_info.business_flow_code = 8 AND p_transaction_identifier = 4) THEN
          OPEN c_mcce_lpn_item_content(l_lpn_id);
          IF (l_debug = 1) THEN
            TRACE('before fetch c_mcce_lpn_item_content');
          END IF;

          FETCH c_mcce_lpn_item_content
           INTO v_lpn_content;

          IF (l_debug = 1) THEN
            TRACE('Item is ' || v_lpn_content.inventory_item_id || '  '
               || 'Quantity is ' || v_lpn_content.quantity);
          END IF;

          IF c_mcce_lpn_item_content%NOTFOUND THEN
            IF (l_debug = 1) THEN
              trace('No record found for c_mcce_lpn_item_content');
            END IF;
            CLOSE c_mcce_lpn_item_content;
          END IF;
        ELSIF cartonization_flag = 0 THEN
          -- non cartonization flow
          FETCH c_lpn_item_content INTO v_lpn_content;
          IF c_lpn_item_content%NOTFOUND THEN
              IF (l_debug = 1) THEN
                 trace('No record found for c_lpn_item_content');
                 --Moved the following 2 statement outside the if block.
                 -- as a part of a fix for Bug: -- Fix for 4351366
                 --CLOSE c_lpn_item_content;
                 --v_lpn_content := null;
              END IF;
              -- Fix for 4351366 Start.
              CLOSE c_lpn_item_content;
              v_lpn_content := null;
              -- Fix for 4351366 end.
          END IF;
        ELSE
          -- cartonization flow
          FETCH c_lpn_item_content_cart INTO v_lpn_content;
          IF c_lpn_item_content_cart%NOTFOUND THEN
              IF (l_debug = 1) THEN
                 trace('No record found for c_lpn_item_content_cart');
                 --Moved the following 2 statement outside the if block.
                 -- as a part of a fix for Bug: -- Fix for 4351366
                 --CLOSE c_lpn_item_content_cart;
                 --v_lpn_content := null;
              END IF;
              -- Fix for 4351366 Start.
              CLOSE c_lpn_item_content_cart;
              v_lpn_content := null;
              -- Fix for 4351366 end.
          END IF;
        END IF;

    END LOOP; -- End loop of c_item_content/c_item_content_cart

    -- Begin Here, for other label type, do not include the following code
    -- For child LPNs, print LPN Summary
    -- Prepare input parameters

    -- get default format
    l_summary_format_id := null;
    l_summary_format := null;

    INV_LABEL.GET_DEFAULT_FORMAT
      (p_label_type_id => 5,
       p_label_format => l_summary_format,
       p_label_format_id => l_summary_format_id);
    IF l_summary_format_id IS NOT NULL THEN
        -- Bug 3841820
        -- When calling LPN Summary label from LPN Content label
        -- Pass default format as null , so that the actual LPN Summary label format
        -- will be different than the default format passed in
        -- So the LPN Summary label format will be included in <LABEL ..> tag
        -- Otherwise, it will still have the LPN Content label format from
        -- <LABELS ..> tag
      l_label_type_child_lpn.default_format_name := null;  --l_summary_format;
      l_label_type_child_lpn.default_format_id := null; --l_summary_format_id;
      l_label_type_child_lpn.business_flow_code := p_label_type_info.business_flow_code;
      l_label_type_child_lpn.label_type_id := 5;
      BEGIN
        SELECT meaning INTO l_label_type_child_lpn.label_type
        FROM mfg_lookups WHERE lookup_type = 'WMS_LABEL_TYPE'
        AND lookup_code = 5;
      EXCEPTION
        WHEN no_data_found THEN
          l_label_type_child_lpn.label_type:= 'LPN Summary';
      END;
      l_label_type_child_lpn.default_printer  := p_label_type_info.default_printer;
      l_label_type_child_lpn.default_no_of_copies := p_label_type_info.default_no_of_copies;

      FOR v_child_lpn IN c_child_lpns(l_lpn_id) LOOP
         IF l_debug = 1 THEN
         trace('calling inv_label_pvt5 with lpn_id ' || v_child_lpn.lpn_id);
         END IF;
         INV_LABEL_PVT5.get_variable_data(
          x_variable_content   => l_child_lpn_summary
        ,  x_msg_count    => l_msg_count
        ,  x_msg_data    => l_msg_data
        ,  x_return_status    => l_return_status
        ,  p_label_type_info  => l_label_type_child_lpn
        ,  p_lpn_id    => v_child_lpn.lpn_id
          ,  p_transaction_id => p_transaction_id
          ,  p_transaction_identifier => p_transaction_identifier
        );
        -- add childLPN summarylabel to list in x_variable_content
         IF l_debug = 1 THEN
         trace(' l_child_lpn_summary.count() ' || l_child_lpn_summary.count());
         END IF;
        FOR i IN 1..l_child_lpn_summary.count() LOOP
           IF l_debug = 1 THEN
           trace(' l_child_lpn_summary(i).label_content ' || l_child_lpn_summary(i).label_content);
           trace(' l_child_lpn_summary(i).label_request_id ' || l_child_lpn_summary(i).label_request_id);
           END IF;
          x_variable_content(l_label_index).label_content := l_child_lpn_summary(i).label_content;
          x_variable_content(l_label_index).label_request_id := l_child_lpn_summary(i).label_request_id;
     x_variable_content(l_label_index).label_status := l_child_lpn_summary(i).label_status;
     x_variable_content(l_label_index).error_message  := l_child_lpn_summary(i).error_message;
     g_req_cnt := inv_label.g_label_request_tbl.count();
          IF l_debug = 1 THEN
          trace('g_req_cnt ' || g_req_cnt);
          END IF;
          inv_label.g_label_request_tbl(g_req_cnt+1).label_request_id := l_child_lpn_summary(i).label_request_id;
          inv_label.g_label_request_tbl(g_req_cnt+1).label_type_id := 5;
     IF l_debug = 1 THEN
          trace('inv_label.g_label_request_tbl(g_req_cnt+1).label_request_id ' || inv_label.g_label_request_tbl(g_req_cnt+1).label_request_id);
          trace('inv_label.g_label_request_tbl(g_req_cnt+1).label_type_id ' || inv_label.g_label_request_tbl(g_req_cnt+1).label_type_id);
          END IF;

          l_label_index := l_label_index + 1;
        END LOOP;
        l_child_lpn_summary.delete;
      END LOOP;
    END IF;
    -- End here , for other label type, do not include the above code
    -- and the following line should be

    --x_variable_content := l_content_item_data ;


    IF p_label_type_info.business_flow_code in (6) THEN
      -- Cross-Dock
      FETCH c_wdd_lpn INTO l_lpn_id, p_organization_id, l_subinventory_code;
      IF c_wdd_lpn%NOTFOUND THEN
        IF (l_debug = 1) THEN
           trace(' Finished getting more cross-dock');
        END IF;
        CLOSE c_wdd_lpn;
        l_lpn_id := null;
      END IF;
    ELSIF p_label_type_info.business_flow_code = 22 THEN
      IF (l_debug = 1) THEN
         trace(' Getting another content for cartonization');
      END IF;
      IF (l_lpn_id = p_transaction_id) THEN
        IF (l_debug = 1) THEN
           trace(' Inside check for the l_lpn_id and the p_transaction_id');
        END IF;
           l_lpn_id := null;
      ELSE
        l_container_item := NULL;
        IF c_mmtt_cart_lpn%ISOPEN THEN
           FETCH c_mmtt_cart_lpn
           INTO  l_package_id, l_lpn_id, l_content_volume_uom_code, l_content_volume,
                l_gross_weight_uom_code, l_gross_weight, l_inventory_item_id, l_parent_package_id, l_pack_level,
                l_header_id, l_packaging_mode, l_tare_weight, l_tare_weight_uom_code, l_container_item, l_parent_lpn;

          IF (l_pack_level = 1 AND l_lpn_id IS NOT NULL) THEN
            --IF (l_debug = 1) THEN
               --trace('Within new condition');
            --END IF;
            l_container_item := NULL;
            l_gross_weight := NULL; -- New Addition
            l_gross_weight_uom_code := NULL;  -- New Addition
            l_content_volume := NULL;  -- New Addition
            l_content_volume_uom_code := NULL;   -- New Addition
            l_tare_weight := NULL;   -- New Addition
            l_tare_weight_uom_code := NULL;   -- New Addition

            IF (l_package_id IS NOT NULL) THEN
              l_parent_package_id := l_package_id;
              l_package_id := NULL;
            END IF;
          END IF;


          IF (l_debug = 1) THEN
             trace(' Got Container Item = ' || l_container_item);
          END IF;
          IF c_mmtt_cart_lpn%NOTFOUND THEN
            CLOSE c_mmtt_cart_lpn;
            l_package_id := NULL;

            IF (l_pack_level = 1 AND l_lpn_id IS NULL) THEN
          l_parent_package_id := NULL;
          l_container_item := NULL;
          p_inventory_item_id := l_inventory_item_id;
          print_outer := TRUE; -- flag to indicate a run for the outer LPN.
          l_content_volume_uom_code :=NULL;
          l_content_volume :=NULL;
          l_gross_weight_uom_code :=NULL;
          l_gross_weight :=NULL;
          l_tare_weight :=NULL;
          l_tare_weight_uom_code :=NULL;
          l_lpn_id := p_transaction_id;
          --Bug# 3423817
          l_pack_level := l_outermost_pack_level;
          l_outermost_pack_level := l_outermost_pack_level + 1;
          IF (l_debug = 1) THEN
        trace('l_lpn_id = ' || l_lpn_id || 'p_transaction_id = ' || p_transaction_id);
          END IF;
        ELSE
          l_lpn_id := null;
            END IF;

      ELSE
            IF (l_debug = 1) THEN
               trace(' Found another container lpn_id=' || l_lpn_id || 'package_id=' || l_package_id);
            END IF;
          END IF;
        END IF;
      END IF;
     ELSIF p_label_type_info.business_flow_code = 29 THEN
             FETCH c_mmtt_wip_pick_drop_lpn INTO l_lpn_id, p_organization_id,
                  p_inventory_item_id, p_lot_number,
                  p_revision, p_qty, p_uom,
                                l_subinventory_code,l_locator_id,
                          l_secondary_transaction_qty, l_secondary_uom_code; -- invconv fabdi
                IF c_mmtt_wip_pick_drop_lpn%NOTFOUND THEN
                     CLOSE c_mmtt_wip_pick_drop_lpn;
                     l_lpn_id := null;
                ELSE
                     IF (l_debug = 1) THEN
                        trace(' Found another lot ' || p_lot_number);
                     END IF;
                END IF;
    ELSIF p_label_type_info.business_flow_code in (18,28,34) THEN
      FETCH   c_mmtt_lpn_pick_load
      INTO   l_lpn_id, p_organization_id, p_inventory_item_id, p_lot_number, p_revision,
                        p_qty, p_uom,l_subinventory_code, l_locator_id, l_printer_sub
                  , l_secondary_transaction_qty, l_secondary_uom_code; -- invconv fabdi
        IF c_mmtt_lpn_pick_load%NOTFOUND THEN
          CLOSE c_mmtt_lpn_pick_load;
          l_lpn_id := null;
        ELSE
          IF (l_debug = 1) THEN
             trace(' Found another lot ' || p_lot_number);
          END IF;
        END IF;
    ELSE
       IF l_debug = 1 THEN
       trace('l_lpn_table_index ' || l_lpn_table_index ||  'rcv lpn count' || l_rcv_lpn_table.count);
       trace('l_rlpn_ndx ' ||  l_rlpn_ndx);
       trace('l_lpn_table.count ' ||  l_lpn_table.count);
       END IF;
      -- ============================================
      -- Reset l_lpn_id for all other Business Flow Code
      -- Without this reset, cause indefinite loop
      -- ============================================
      -- For RCV flows, check if called based on new Architecture
      -- If new architecture, then index corresponding to new RCV_LPN
      -- table of records would be greater than 0
      if l_rlpn_ndx > 0 then -- :J-DEV
       l_lpn_table_index := l_lpn_table_index +1;
       -- have all the records in l_rcv_lpn_table been processed ?
       if (l_lpn_table_index < l_rcv_lpn_table.count) then
         l_lpn_id := l_rcv_lpn_table(l_lpn_table_index).lpn_id;
         l_cur_item_id := l_rcv_lpn_table(l_lpn_table_index).item_id;
         IF l_debug = 1 THEN
         trace('l_lpn_id has been initialized again :'||l_lpn_id);
         END IF;
       else
          l_lpn_id := null;
          IF l_debug = 1 THEN
            trace('lpn id is null');
          END IF;
       end if;
      else
         /*Bug# 3263037*/
        IF l_lpn_table_index + 1 < l_lpn_table.count THEN
          l_lpn_table_index := l_lpn_table_index + 1;
          l_lpn_id := l_lpn_table(l_lpn_table_index + 1);
          /* End of Bug# 3263037 */
          IF l_debug = 1 THEN
          trace('lpn id is getting initialized again');
          END IF;
        ELSE
          l_lpn_id := null;
          IF l_debug = 1 THEN
          trace('lpn id is made null');
          END IF;
        END IF;
      end if;
    END IF;

  IF (l_debug = 1) THEN
     trace('l_lpn_id = ' || l_lpn_id || 'p_transaction_id = ' || p_transaction_id);
     trace(' Before End of while loop, end of pvt4');
  END IF;
 END LOOP; --  WHILE l_lpn_id IS NOT NULL OR l_package_id I

EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
       trace('ERROR CODE = ' || SQLCODE);
       trace('ERROR MESSAGE = ' || SQLERRM);
    END IF;

END get_variable_data;

PROCEDURE get_variable_data(
   x_variable_content   OUT NOCOPY LONG
,  x_msg_count    OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  x_var_content     IN LONG DEFAULT NULL
,  p_label_type_info IN INV_LABEL.label_type_rec
,  p_transaction_id  IN NUMBER
,  p_input_param     IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,  p_transaction_identifier IN NUMBER
) IS
   l_variable_data_tbl INV_LABEL.label_tbl_type;
BEGIN
   get_variable_data(
      x_variable_content   => l_variable_data_tbl
   ,  x_msg_count          => x_msg_count
   ,  x_msg_data           => x_msg_data
   ,  x_return_status      => x_return_status
   ,  x_var_content     => x_var_content
   ,  p_label_type_info => p_label_type_info
   ,  p_transaction_id  => p_transaction_id
   ,  p_input_param     => p_input_param
   ,       p_transaction_identifier=> p_transaction_identifier
   );

   x_variable_content := '';

   FOR i IN 1..l_variable_data_tbl.count() LOOP
      x_variable_content := x_variable_content || l_variable_data_tbl(i).label_content;
   END LOOP;

END get_variable_data;

END INV_LABEL_PVT4;

/
