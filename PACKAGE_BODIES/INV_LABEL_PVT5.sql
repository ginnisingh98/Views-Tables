--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT5" AS
/* $Header: INVLAP5B.pls 120.22.12010000.14 2010/04/12 23:57:35 sfulzele ship $ */

-- Bug 2795525 : This mask is used to mask all date fields.
G_DATE_FORMAT_MASK VARCHAR2(100) := INV_LABEL.G_DATE_FORMAT_MASK;

LABEL_B    CONSTANT VARCHAR2(50) := '<label';
LABEL_E    CONSTANT VARCHAR2(50) := '</label>'||fnd_global.local_chr(10);
VARIABLE_B  CONSTANT VARCHAR2(50) := '<variable name= "';
VARIABLE_E  CONSTANT VARCHAR2(50) := '</variable>'||fnd_global.local_chr(10);
TAG_E    CONSTANT VARCHAR2(50)  := '>'||fnd_global.local_chr(10);
l_debug number;

g_get_hash_for_insert NUMBER := 1;
g_get_hash_for_retrieve NUMBER := 0;
g_count_custom_sql NUMBER := 0; -- Added for Bug#4179391

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  Included SQL_STMT to field_element_tp                                                    |
---------------------------------------------------------------------------------------------

TYPE field_element_tp IS RECORD
  (column_name_with_count VARCHAR2(60),
   variable_name VARCHAR2(60),
   sql_stmt VARCHAR2(4000));


TYPE field_elements_tab_tp IS TABLE OF field_element_tp
  INDEX BY BINARY_INTEGER;

g_field_elements_table field_elements_tab_tp;



PROCEDURE trace(p_message IN VARCHAR2) iS
BEGIN
     inv_label.trace(p_message, 'LABEL_LPN_SUM');
END trace;



FUNCTION get_field_hash_value (p_input_string VARCHAR2, p_get_hash_mode NUMBER)
  RETURN NUMBER IS
     l_return_hash_value NUMBER;
     l_orig_hash_value NUMBER;
     l_hash_base NUMBER := 2;
     l_hash_size NUMBER := Power(2, 20);
BEGIN
   l_orig_hash_value := dbms_utility.get_hash_value
     (
      name         => p_input_string
      ,base     => l_hash_base
      ,hash_size   => l_hash_size
      );

   IF  g_field_elements_table.exists(l_orig_hash_value) AND
     g_field_elements_table(l_orig_hash_value).column_name_with_count = p_input_string THEN

      l_return_hash_value := l_orig_hash_value;

   ELSIF g_field_elements_table.exists(l_orig_hash_value) THEN
      -- hash collision

   LOOP
   l_orig_hash_value := l_orig_hash_value + 1;

   IF l_orig_hash_value > l_hash_size THEN
      -- Don't need to check hash overflow here because the hash range
      -- for sure is greater than the number of columns.
      l_orig_hash_value := l_hash_base;
   END IF;

   IF g_field_elements_table.exists(l_orig_hash_value) AND
     g_field_elements_table(l_orig_hash_value).column_name_with_count = p_input_string THEN

      EXIT;
    ELSIF NOT g_field_elements_table.exists(l_orig_hash_value) THEN

      EXIT;
   END IF;

      END LOOP;

      l_return_hash_value := l_orig_hash_value;

    ELSE

      l_return_hash_value := l_orig_hash_value;
   END IF;

   IF p_get_hash_mode = g_get_hash_for_insert THEN
      g_field_elements_table(l_return_hash_value).column_name_with_count := p_input_string;
   END IF;
   RETURN l_return_hash_value;

END get_field_hash_value;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  Included SQL_STMT to c_label_field_var cursor                                            |
---------------------------------------------------------------------------------------------

PROCEDURE build_format_fields_structure(p_label_format_id NUMBER) IS

   CURSOR c_label_field_var IS
      SELECT wlf.column_name,
             wlf.sql_stmt,
             wlfv.field_variable_name
  FROM wms_label_field_variables wlfv,
  wms_label_fields_vl wlf
  WHERE wlfv.label_format_id = p_label_format_id
  AND wlfv.label_field_id = wlf.label_field_id
  ORDER BY wlf.column_name, wlfv.field_variable_name;

   l_label_field_var c_label_field_var%ROWTYPE;
   l_column_count NUMBER := 1;
   l_prev_column_name VARCHAR2(60) := '';

BEGIN

  --Bug #3142232. +1 line.
  --Clearing the PL/SQL table g_field_elements_table before building it new.
  g_field_elements_table.DELETE(nvl(g_field_elements_table.first,0),nvl(g_field_elements_table.last,0));
   OPEN c_label_field_var;
   LOOP
      FETCH c_label_field_var INTO l_label_field_var;
      EXIT WHEN c_label_field_var%notfound;

      IF l_prev_column_name IS NULL OR l_prev_column_name <> l_label_field_var.column_name THEN
         l_prev_column_name := l_label_field_var.column_name;
         l_column_count := 1;
      ELSE
         l_column_count := l_column_count + 1;
      END IF;

      -- build the hash table with column_name concatenate count as key
     --     trace('*********** insert into hash table '|| l_label_field_var.column_name ||l_column_count||'  ************ ' || l_label_field_var.field_variable_name);
     g_field_elements_table(get_field_hash_value(l_label_field_var.column_name||l_column_count, g_get_hash_for_insert)).variable_name := l_label_field_var.field_variable_name;

    IF l_label_field_var.column_name = 'sql_stmt' THEN
     g_count_custom_sql := g_count_custom_sql + 1; -- Added for Bug#4179391
     g_field_elements_table(get_field_hash_value(l_label_field_var.column_name||l_column_count, g_get_hash_for_insert)).sql_stmt := l_label_field_var.sql_stmt;
    END IF;

   END LOOP;


   CLOSE c_label_field_var;

END build_format_fields_structure;



/****************************************************************************
 * p_transaction_identifier :
 ****************************************************************************/
PROCEDURE get_variable_data(
  x_variable_content   OUT NOCOPY INV_LABEL.label_tbl_type
,  x_msg_count    OUT NOCOPY NUMBER
,  x_msg_data    OUT NOCOPY VARCHAR2
,  x_return_status    OUT NOCOPY VARCHAR2
,  p_label_type_info  IN INV_LABEL.label_type_rec
,  p_transaction_id  IN NUMBER
,  p_input_param    IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,  p_lpn_id    IN NUMBER
,  p_transaction_identifier IN NUMBER
) IS

  l_receipt_number  varchar2(30);

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

   --Bug# 3739739
  l_qty        NUMBER;
  l_uom        MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_UOM%TYPE := null;


  -- Added vendor_id and vendor_site_id to the cursor for Bug 2748297
  CURSOR c_rti_lpn IS
    SELECT   rti.lpn_id, rti.to_organization_id, pha.segment1 purchase_order,
      rti.subinventory, rti.locator_id,
      l_receipt_number receipt_number,  pol.line_num po_line_number,
                        pll.quantity quantity_ordered, rti.vendor_item_num supplier_part_number,
      pov.vendor_id vendor_id, pov.vendor_name supplier_name,
      pvs.vendor_site_id vendor_site_id, pvs.vendor_site_code supplier_site,
      ppf.full_name requestor, hrl1.location_code deliver_to_location,
                        hrl2.location_code location, pll.note_to_receiver note_to_receiver
    FROM   rcv_transactions_interface rti, po_headers_trx_v pha,--CLM Changes,using CLM views instead of base tables
      -- MOAC : changed po_line_locations to po_line_locations_all
      po_lines_trx_v pol, rcv_shipment_headers rsh, po_line_locations_trx_v pll,
            po_vendors pov, hr_locations_all hrl1, hr_locations_all hrl2,
            -- MOAC : changed po_vendor_sites to po_vendor_sites_all
            po_vendor_sites_all pvs, per_people_f ppf
    where   rti.interface_transaction_id = p_transaction_id
    AND  rti.po_header_id  = pha.po_header_id(+)
    AND     rsh.shipment_header_id(+)       = rti.shipment_header_id
    AND     pol.po_line_id(+)                  = rti.po_line_id --Added outer join, bug 4918726
    AND     pol.po_header_id(+)                = rti.po_header_id --Added outer join, bug 4918726
    --AND  pll.po_line_id(+)               = pol.po_line_id      -- bug 2372669
    AND   pll.line_location_id(+)         = rti.po_line_location_id -- bug 2372669
    AND     pov.vendor_id(+)                = rti.vendor_id
    -- AND     pvs.vendor_id(+)                = rti.vendor_id -- Unesseccary line dherring 8/2/05
    AND     pvs.vendor_site_id(+)           = rti.vendor_site_id
    AND     ppf.person_id(+)                = rti.deliver_to_person_id
    AND     hrl1.location_id(+)             = rti.deliver_to_location_id
    AND     hrl2.location_id(+)             = rti.location_id;

  -- Bug 2377796 : Added this cursor for Inspection.
  -- Added vendor_id and vendor_site_id to the cursor for Bug 2748297
  CURSOR c_rti_lpn_inspection IS
    SELECT   rti.transfer_lpn_id transfer_lpn_id, rti.to_organization_id to_oragnization_id,
      pha.segment1 purchase_order  , rti.subinventory, rti.locator_id,
      l_receipt_number receipt_number,  pol.line_num po_line_number, pll.quantity
                        quantity_ordered, rti.vendor_item_num supplier_part_number,
                        pov.vendor_id vendor_id, pov.vendor_name supplier_name,
                        pvs.vendor_site_id vendor_site_id,
      pvs.vendor_site_code supplier_site, ppf.full_name requestor,
                        hrl1.location_code deliver_to_location, hrl2.location_code location,
      pll.note_to_receiver note_to_receiver
    FROM   rcv_transactions_interface rti, po_headers_trx_v pha,--CLM Changes,using CLM views instead of base tables
      -- MOAC : changed po_line_locations to po_line_locations_all
      po_lines_trx_v pol, rcv_shipment_headers rsh, po_line_locations_trx_v pll,
      po_vendors pov, hr_locations_all hrl1, hr_locations_all hrl2,
      -- MOAC : changed po_vendor_sites to po_vendor_sites_all
      po_vendor_sites_all pvs, per_people_f ppf
    where   rti.interface_transaction_id   = p_transaction_id
    AND  rti.po_header_id     = pha.po_header_id(+)
    AND  rsh.shipment_header_id(+)       = rti.shipment_header_id
    AND  pol.po_line_id (+)               = rti.po_line_id
    AND  pol.po_header_id  (+)            = rti.po_header_id
    --AND  pll.po_line_id(+)               = pol.po_line_id       -- bug 2372669
    AND   pll.line_location_id(+)         = rti.po_line_location_id  -- bug 2372669
    AND  pov.vendor_id(+)                = rti.vendor_id
    -- AND  pvs.vendor_id(+)                = rti.vendor_id -- Unesseccary line dherring 8/2/05
    AND     pvs.vendor_site_id(+)           = rti.vendor_site_id
    AND  ppf.person_id(+)                = rti.deliver_to_person_id
    AND  hrl1.location_id(+)             = rti.deliver_to_location_id
    AND  hrl2.location_id(+)             = rti.location_id;


  -- Cursor for RCV flows based on NEW architecture of querying LPN data from
  -- RCV transaction tables instead of Interface tables : J-DEV
  -- Note: records in RT are filtered by transaction_type and business_flow_code
  --   because it is possible for label-API to be called multiple times by RCV-TM
  --   in the case of ROI, when multiple trx.types are present in a group
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
   --    , hrl1.location_code deliver_to_location
   --    , hrl2.location_code location
       , pll.note_to_receiver note_to_receiver
       , all_lpn.deliver_to_location_id
       , all_lpn.location_id
       -- Added for bug 3581021 by joabraha
       , pol.item_id item_id
       --
      FROM(
       -- LPN_ID
          select lpn_id
            , po_header_id, po_line_id
            , subinventory, locator_id
            , shipment_header_id, po_line_location_id
            , vendor_id, vendor_site_id
            , deliver_to_person_id, deliver_to_location_id
            , location_id
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
          from wms_license_plate_numbers lpn,
            rcv_transactions rt
          where lpn.lpn_id = rt.lpn_id
            and lpn.parent_lpn_id <> rt.lpn_id
            and lpn.parent_lpn_id is not null
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
            -- OUTERMOSE LPN of LPN_ID, and different than the LPN and parent LPN
          select lpn.outermost_lpn_id
              , rt.po_header_id, rt.po_line_id
              , rt.subinventory, rt.locator_id
              , rt.shipment_header_id, rt.po_line_location_id
              , rt.vendor_id, rt.vendor_site_id
              , rt.deliver_to_person_id, rt.deliver_to_location_id deliver_to_location_id
              , rt.location_id location_id
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
              , deliver_to_person_id, deliver_to_location_id
              , location_id
          from rcv_transactions rt
          where nvl(transfer_lpn_id,-999) <> nvl(lpn_id,-999)
              and group_id = p_transaction_id
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
          from wms_license_plate_numbers lpn, rcv_transactions rt
              where lpn.lpn_id = rt.transfer_lpn_id
              and rt.transfer_lpn_id <> rt.lpn_id
              and lpn.parent_lpn_id is not null
              and lpn.parent_lpn_id <> lpn.lpn_id
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
         -- MOAC : changed po_line_locations to po_line_locations_all
         , po_line_locations_trx_v pll
         , po_vendors pov
     --    , hr_locations_all hrl1
     --    , hr_locations_all hrl2
         -- MOAC : changed po_vendor_sites to po_vendor_sites_all
         , po_vendor_sites_all pvs
         , per_people_f ppf
         , wms_license_plate_numbers wlpn -- Bug 3836623
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
         -- AND  pvs.vendor_id(+)          = all_lpn.vendor_id -- Unesseccary line dherring 8/2/05
         AND  pvs.vendor_site_id(+)     = all_lpn.vendor_site_id
         AND  ppf.person_id(+)          = all_lpn.deliver_to_person_id
         -- Bug 3836623, for receiving putaway, do not print if the
         -- LPN is picked (11), which will be doing cross docking
         -- label will be printed during cross docking business flow
         AND wlpn.lpn_id = all_lpn.lpn_id
         AND  (p_label_type_info.business_flow_code <> 4 OR
               (p_label_type_info.business_flow_code = 4 AND
                wlpn.lpn_context <> 11))
    --     AND  hrl1.location_id(+)       = all_lpn.deliver_to_location_id
    --     AND  hrl2.location_id(+)       = all_lpn.location_id
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
    SELECT mmtt.lpn_id,
           mmtt.content_lpn_id,
           mmtt.transfer_lpn_id,
           mmtt.transfer_subinventory,
           mmtt.transfer_to_location,
           mmtt.transaction_type_id,
           mmtt.transaction_action_id,
           mmtt.transaction_uom --Bug# 3739739
           -- Bug 2515486: Added transaction_type_id, transaction_action_id, inventory_item_id
    FROM   mtl_material_transactions_temp mmtt
    WHERE  mmtt.transaction_temp_id = p_transaction_id
      AND  rownum<2;

  CURSOR c_mmtt_lpn_pick_load IS
    -- Bug 4277718, pick load printing.
    -- when pick a whole LPN and load the same LPN, transfer_lpn_id is NULL
    -- So take the content_lpn_id
    SELECT   nvl(mmtt.transfer_lpn_id, mmtt.content_lpn_id), mmtt.organization_id, mmtt.inventory_item_id,
      mtlt.lot_number, mmtt.revision,
                        abs(nvl(mtlt.transaction_quantity,
                                mmtt.transaction_quantity)) quantity,
      mmtt.transaction_uom,
                        --mmtt.transfer_subinventory, mmtt.transfer_to_location
			  mmtt.subinventory_code, mmtt.locator_id --Bug 8528146
                        , mmtt.subinventory_code /*from sub, to select printer*/
      , abs(nvl(mtlt.secondary_quantity, mmtt.secondary_transaction_quantity)) secondary_quantity, -- invocnv changes
      mmtt.secondary_uom_code -- invconv changes
    FROM   mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
    WHERE  mtlt.transaction_temp_id(+)  = mmtt.transaction_temp_id
    AND     mmtt.transaction_temp_id  = p_transaction_id;

  CURSOR c_mmtt_cart_lpn IS
    SELECT lpn_id, package_id, content_volume_uom_code, content_volume, gross_weight_uom_code,
           gross_weight, inventory_item_id, parent_package_id, pack_level, parent_lpn_id,
           header_id, packaging_mode
    FROM   wms_packaging_hist
    WHERE  lpn_id is not null
    OR     package_id is not null
    START WITH parent_lpn_id = p_transaction_id
    CONNECT BY PARENT_PACKAGE_ID = PRIOR PACKAGE_ID;

  CURSOR c_mmtt_wip_pick_drop_lpn IS
    SELECT  transfer_lpn_id, organization_id, inventory_item_id,
      lot_number, revision, abs(transaction_quantity), transaction_uom,
      transfer_subinventory, transfer_to_location,
     abs(secondary_transaction_quantity), secondary_uom_code -- invconv changes
    FROM  mtl_material_transactions_temp
    WHERE    transaction_temp_id = p_transaction_id;

  CURSOR c_mmtt_pregen_lpn IS
    SELECT   lpn_id, subinventory_code, locator_id, abs(transaction_quantity) quantity
    FROM   mtl_material_transactions_temp
    WHERE   transaction_temp_id = p_transaction_id;

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

  CURSOR c_wnd_lpn IS
    SELECT DISTINCT wdd2.lpn_id, wdd1.organization_id /*8736862-added distinct*/
    FROM wsh_new_deliveries wnd, wsh_delivery_assignments_v wda
      , wsh_delivery_details wdd1, wsh_delivery_details wdd2
    WHERE wnd.delivery_id = p_transaction_id
    AND    wnd.delivery_id = wda.delivery_id
    AND    wdd1.delivery_detail_id = wda.delivery_detail_id
    AND   wdd2.delivery_detail_id = wda.parent_delivery_detail_id;

  -- Bug 2825748 : WIP is passing a transaction_temp_id instead of
  -- wip_lpn_completions,header_id for both LPN and non-LPN Completions.
  -- Bug 4277718
  -- for WIP completion, lpn_id is used rather than transfer_lpn_id
  -- Changed to use c_mmtt_lpn
  /*CURSOR  c_wip_lpn IS
    SELECT   transfer_lpn_id
    FROM   mtl_material_transactions_temp mmtt
    WHERE   mmtt.transaction_temp_id = p_transaction_id;*/


  -- For business flow code of 33, the MMTT, MTI or MOL id is passed
  -- Depending on the txn identifier being passed,one of the
  -- following 2 flow csrs or the generic mmtt crsr will be called

  CURSOR  c_flow_lpn_mol IS
     SELECT lpn_id
       FROM mtl_txn_request_lines
       WHERE line_id=p_transaction_id;

  CURSOR c_flow_lpn_mti IS
     SELECT lpn_id
       FROM mtl_transactions_interface
       WHERE transaction_interface_id = p_transaction_id;

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
           -- MOAC : changed po_line_locations to po_line_locations_all
           , po_line_locations_trx_v pll
           , po_vendors pov
           , hr_locations_all hrl1
           , hr_locations_all hrl2
           -- MOAC : changed po_vendor_sites to po_vendor_sites_all
           , po_vendor_sites_all pvs
           , per_people_f ppf
      WHERE      pha.po_header_id(+)       = all_lpn.po_header_id
           AND   rsh.shipment_header_id(+) = all_lpn.shipment_header_id
           AND   pol.po_line_id  (+)       = all_lpn.po_line_id
           AND   pol.po_header_id (+)      = all_lpn.po_header_id
           AND   pll.line_location_id(+)   = all_lpn.po_line_location_id
           AND   pov.vendor_id(+)          = all_lpn.vendor_id
           -- AND   pvs.vendor_id(+)          = all_lpn.vendor_id -- Unesseccary line dherring 8/2/05
           AND   pvs.vendor_site_id(+)     = all_lpn.vendor_site_id
           AND   ppf.person_id(+)          = all_lpn.deliver_to_person_id
           AND   hrl1.location_id(+)       = all_lpn.deliver_to_location_id
           AND   hrl2.location_id(+)       = all_lpn.location_id
           AND   all_lpn.lpn_id = nvl(p_lpn_id, all_lpn.lpn_id);

  p_organization_id NUMBER := null;
  p_inventory_item_id NUMBER := null;
  p_lot_number  MTL_LOT_NUMBERS.LOT_NUMBER%TYPE :=null;
  p_revision    MTL_MATERIAL_TRANSACTIONS_TEMP.REVISION%TYPE := null;
  p_qty      NUMBER := null;
  p_uom      MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_UOM%TYPE := null;
  p_cost_group_id  NUMBER := null;

  --Fix for 4891916
  l_lot_number mtl_lot_numbers.lot_number%TYPE := NULL;
  l_revision mtl_material_transactions_temp.revision%TYPE := NULL;
  -- End of fix for 4891916

  l_subinventory_code VARCHAR2(10) := null;
  l_locator_id NUMBER :=null;
  l_locator VARCHAR2(204):=null;
  l_header_id NUMBER := NULL;
  l_packaging_mode NUMBER := NULL;
  l_lpn_id  NUMBER := NULL;
  l_package_id NUMBER := NULL;
  l_content_volume_uom_code VARCHAR2(3);
  l_content_volume NUMBER;
  l_gross_weight_uom_code VARCHAR2(3);
  l_gross_weight NUMBER;
  l_inventory_item_id NUMBER;
  l_parent_package_id NUMBER;
  l_pack_level NUMBER;
  l_parent_lpn_id NUMBER;
  l_outermost_lpn_id NUMBER;
  cartonization_flag NUMBER := 0;

  -- invconv changes start
  l_secondary_quantity  NUMBER;
  l_secondary_uom VARCHAR2(3) :=  NULL;
  -- invconv changes end


  CURSOR c_lpn_attributes (p_org_id NUMBER, p_lpn_id NUMBER)IS
    SELECT lpn.LICENSE_PLATE_NUMBER lpn
      , plpn.lpn_id parent_lpn_id
       , plpn.license_plate_number parent_lpn
       , olpn.license_plate_number outermost_lpn
       , msik.INVENTORY_ITEM_ID container_item_id
      , msik.concatenated_segments container_item
      , nvl(lpn.CONTENT_VOLUME, l_content_volume) volume
       , nvl(lpn.CONTENT_VOLUME_UOM_CODE, l_content_volume_uom_code) volume_uom
      , nvl(lpn.GROSS_WEIGHT, l_gross_weight) gross_weight
       , nvl(lpn.GROSS_WEIGHT_UOM_CODE, l_gross_weight_uom_code) gross_weight_uom
      , nvl(lpn.TARE_WEIGHT, msik.unit_weight) tare_weight
      , nvl(lpn.TARE_WEIGHT_UOM_CODE, msik.weight_uom_code) tare_weight_uom
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
       , nvl(wph.parent_package_id, l_parent_package_id) parent_package
       , nvl(wph.pack_level, l_pack_level) pack_level
     FROM WMS_LICENSE_PLATE_NUMBERS lpn
       , WMS_PACKAGING_HIST wph
      , WMS_LICENSE_PLATE_NUMBERS plpn
      , WMS_LICENSE_PLATE_NUMBERS olpn
      , MTL_SYSTEM_ITEMS_KFV msik
     /*Commented for bug# 6334460 start
        , DUAL d
     WHERE d.dummy = 'X'
     AND   lpn.license_plate_number (+) <> NVL('@@@',d.dummy)
     Commented for bug# 6334460 end */
     WHERE   lpn.lpn_id (+) = p_lpn_id
     AND   wph.lpn_id (+) = lpn.lpn_id
     AND  plpn.lpn_id (+) = NVL(lpn.parent_lpn_id, l_parent_lpn_id)
     AND  olpn.lpn_id (+) = NVL(lpn.outermost_lpn_id, l_outermost_lpn_id)
     AND   msik.organization_id (+) = p_org_id
     AND  msik.inventory_item_id (+) = NVL(lpn.inventory_item_id, l_inventory_item_id);


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
     SELECT mp.organization_code  organization
       , msik.concatenated_segments item
       , WMS_DEPLOY.GET_CLIENT_ITEM(p_org_id, msik.inventory_item_id) client_item			-- Added for LSP Project, bug 9087971
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
      , mln.parent_lot_number  parent_lot_number --     invconv changes start
      , mln.expiration_action_date  expiration_action_date
      , mln.origination_type origination_type
      , mln.hold_date hold_date
      , mln.expiration_action_code  expiration_action_code
      , mln.supplier_lot_number  supplier_lot_number -- invconv changes end
     FROM   mtl_parameters mp
         ,mtl_system_items_kfv msik
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

  -- Added an extra parameter p_item_id NUMBER for Bug 3581021 by joabraha
  -- Bug 4137707, performance of printing at cartonization
  -- Break the original cursor into seperate cursor
  --  for cartonization flow c_lpn_item_content_cart
  --   and non-cartonization flow c_lpn_item_content
  -- Since this is for non-cartonization flow
  -- Removed the following information
  --  1. Removed input parameter p_package_id
  --  2. Removed the reference to l_packaging_mode because it is only relavent for cartonization
  --  3. Removed the union all of wms_packaging_hist part
  --Bug#8366557 Added hints to following cursor
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
      , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id,milkfv.organization_id) locator
      , sum(nvl(l_secondary_quantity,wlc.secondary_quantity))  secondary_quantity -- invconv fabdi
      , wlc.secondary_uom_code  secondary_uom      -- invconv fabdi
      FROM wms_lpn_contents wlc
       , wms_license_plate_numbers plpn
       , cst_cost_groups  ccg
      , mtl_item_locations milkfv
      WHERE plpn.lpn_id in (select /*+ cardinality(1) */ lpn_id from wms_license_plate_numbers
                                  where 1=1
                              -- Bug 4137707
                                    --start with lpn_id in (select nvl(p_lpn_id, -99) from dual
                              --union all
                              --select lpn_id from wms_packaging_hist
                              --where pack_level = 0
                              --and lpn_id IS not null
                              --start with parent_package_id = p_package_id
                              --connect by PARENT_PACKAGE_ID = PRIOR PACKAGE_ID)
                                    start with lpn_id = p_lpn_id
                                    connect by parent_lpn_id = prior lpn_id)
      AND wlc.parent_lpn_id(+) = plpn.lpn_id
      AND milkfv.organization_id (+)  =   NVL(p_organization_id, plpn.organization_id)
      -- Added the new mode (WMS_CARTNZN_WRAP.mfg_pr_pkg_mode) for fix to Bug 2764074.
      -- Bug 4137707
      --AND     milkfv.subinventory_code(+) =
      --        DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL, WMS_CARTNZN_WRAP.mfg_pr_pkg_mode, NULL,
      --                                           nvl(l_subinventory_code,plpn.subinventory_code))
      --AND     milkfv.inventory_location_id(+) =
      --        DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL, WMS_CARTNZN_WRAP.mfg_pr_pkg_mode, NULL,
      --                                               nvl(l_locator_id, plpn.locator_id))
      AND milkfv.subinventory_code(+) = nvl(l_subinventory_code,plpn.subinventory_code)
      AND milkfv.inventory_location_id(+) = nvl(l_locator_id, plpn.locator_id)
      AND ccg.cost_group_id (+)     = nvl(p_cost_group_id, wlc.cost_group_id)
      -- Added the AND for fix to Bug 2764074..

     	--Bug 6523723 Added IS NULL condition.

	AND   (nvl(p_inventory_item_id, wlc.inventory_item_id)  IS NOT NULL
            OR (nvl(p_inventory_item_id, wlc.inventory_item_id)  IS NULL AND
                p_label_type_info.business_flow_code IS NULL))

      -- Added for Bug 3581021 by joabraha
      -- AND   wlc.inventory_item_id = nvl(p_item_id,wlc.inventory_item_id)
      -- Bug 4280265, Pick Load
      -- The above where clause caused a regression problem for pick load txn
      -- where lpn content is not packed to wlc yet.
      -- changed to the following
      AND nvl(wlc.inventory_item_id,-999) = nvl(p_item_id,nvl(wlc.inventory_item_id,-999))
      -- Added the following condition for bug 4387168
      -- AND nvl(wlc.lot_number,-1) = nvl(p_lot_number,nvl(wlc.lot_number,-1)) --Bug 8393799
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
      , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id,milkfv.organization_id)
     , wlc.secondary_uom_code;

       --Bug 4891916 -Added the cursor to fetch from mcce
      CURSOR mcce_lpn_cur IS
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

      --End of fix for bug 4891916

      --Bug 4891916. Added this cursor to get details like cycle count header name and
      --counter for the entry for the label printed at the time of cycle count approval
      CURSOR cc_det_approval IS
        SELECT    mcch.cycle_count_header_name
                , ppf.full_name requestor
            FROM  mtl_cycle_count_headers mcch
                , mtl_cycle_count_entries mcce
                , per_people_f ppf
                , mtl_material_transactions_temp mmtt
            WHERE mmtt.transaction_temp_id= p_transaction_id
              AND mmtt.cycle_count_id = mcce.cycle_count_entry_id
              AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
              AND ppf.person_id(+) = mcce.counted_by_employee_id_current ;
      -- End of fix for Bug 4891916

      -- Bug 4137707
      --  create new cursor for cartonization flow
      --  For cartonization flow, p_org.., p_inventory_item..,
      --   p_rev..p_lot..p_qty, p_uom, p_cg., l_subinventory, l_locator_id.are always null
      --   remove nvl(.) for those parameters
      --  Remove p_item_id because it is only used for receiving transactions
  --Bug#8366557 Added hints to following cursor
  CURSOR c_lpn_item_content_cart(p_lpn_id NUMBER, p_package_id NUMBER) IS
    SELECT /*+ ORDERED index(PLPN WMS_LICENSE_PLATE_NUMBERS_U1) use_nl(WLC MILKFV CCG) */
        plpn.organization_id  organization_id
      , wlc.inventory_item_id inventory_item_id
      , wlc.revision  revision
      , wlc.lot_number  lot_number
      , sum(wlc.quantity)  quantity
      , wlc.uom_code  uom
      , wlc.cost_group_id cost_group_id
      , ccg.cost_group  cost_group
      , milkfv.subinventory_code subinventory_code
      , milkfv.inventory_location_id        locator_id
      , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id,milkfv.organization_id) locator
      , sum(nvl(l_secondary_quantity,wlc.secondary_quantity))  secondary_quantity -- invconv fabdi
      , wlc.secondary_uom_code  secondary_uom      -- invconv fabdi
      FROM wms_lpn_contents wlc
       , wms_license_plate_numbers plpn
       , cst_cost_groups  ccg
      , mtl_item_locations milkfv
      WHERE plpn.lpn_id in (
		                          select /*+ cardinality(1) */ id from
		                          ((select lpn_id id from wms_license_plate_numbers
                                  where 1=1
                                    start with lpn_id in (select nvl(p_lpn_id, -99) from dual
                                 union all
                                 select /*+ cardinality(1) */ lpn_id from wms_packaging_hist
                              where pack_level = 0
                              and lpn_id IS not null
                              start with parent_package_id = p_package_id
                              connect by PARENT_PACKAGE_ID = PRIOR PACKAGE_ID)
                                    connect by parent_lpn_id = prior lpn_id) ) t )
      AND   wlc.parent_lpn_id(+) = plpn.lpn_id
      AND   milkfv.organization_id (+)  =   plpn.organization_id
      -- Added the new mode (WMS_CARTNZN_WRAP.mfg_pr_pkg_mode) for fix to Bug 2764074.
      AND     milkfv.subinventory_code(+) =
              DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL, WMS_CARTNZN_WRAP.mfg_pr_pkg_mode, NULL,
                                                 plpn.subinventory_code)
      AND     milkfv.inventory_location_id(+) =
              DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL, WMS_CARTNZN_WRAP.mfg_pr_pkg_mode, NULL,
                                                     plpn.locator_id)
      AND   ccg.cost_group_id (+)     = wlc.cost_group_id
      -- Added the AND for fix to Bug 2764074..
      -- Bug 4137707
      -- Do not need the where clause about p_item_id
      --AND  nvl(p_inventory_item_id, wlc.inventory_item_id)  IS NOT NULL
      -- Added for Bug 3581021 by joabraha
      -- AND   wlc.inventory_item_id = nvl(p_item_id,wlc.inventory_item_id)
      -- Bug 4280265, Pick Load
      -- The above where clause caused a regression problem for pick load txn
      -- where lpn content is not packed to wlc yet.
      -- changed to the following
      --AND   nvl(wlc.inventory_item_id,-999) = nvl(p_item_id,nvl(wlc.inventory_item_id,-999))
       GROUP BY
        plpn.organization_id
      , wlc.inventory_item_id
      , wlc.revision
      , wlc.lot_number
      , wlc.uom_code
      , wlc.cost_group_id
      , ccg.cost_group
      , milkfv.subinventory_code
      , milkfv.inventory_location_id
      , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id,milkfv.organization_id)
     , wlc.secondary_uom_code

       UNION ALL

       -- The Subinventory and location information is not required for the Outbound Stuff like Pick Release
                   -- and Pick Confirm. Hence the decode for the sub and the loc in the where clause of this cursor.

       SELECT /*+ ORDERED index(MMTT MTL_MATERIAL_TRANS_TEMP_U1) rowid(WPC) use_nl(WPC MMTT MSI CSG MILKFV) index(MSI MTL_SYSTEM_ITEMS_B_U1)*/
        wpc.organization_id organization_id
      , wpc.inventory_item_id inventory_item_id
      , wpc.revision  revision
      , wpc.lot_number  lot_number
      , sum(wpc.primary_quantity)  quantity
      , msi.primary_uom_code  uom
      , mmtt.cost_group_id cost_group_id
      , ccg.cost_group  cost_group
      , milkfv.subinventory_code subinventory_code
      , milkfv.inventory_location_id locator_id
      , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id,milkfv.organization_id) locator
      , l_secondary_quantity secondary_quantity -- invconv fabdi
      , l_secondary_uom    secondary_uom  -- invconv fabdi

      FROM wms_packaging_hist wpc
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
                         AND   l_packaging_mode in (WMS_CARTNZN_WRAP.PR_PKG_MODE, WMS_CARTNZN_WRAP.mfg_pr_pkg_mode)
                         -- Added the new mode (WMS_CARTNZN_WRAP.mfg_pr_pkg_mode) for fix to Bug 2764074..
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
      AND  msi.inventory_item_id (+) = wpc.inventory_item_id
      AND  msi.organization_id (+)  =  wpc.organization_id
      AND     milkfv.organization_id (+)  = mmtt.organization_id
      -- Added the new mode (WMS_CARTNZN_WRAP.mfg_pr_pkg_mode) for fix to Bug 2764074..
      AND     milkfv.subinventory_code(+) =
              DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL, WMS_CARTNZN_WRAP.mfg_pr_pkg_mode, NULL,
                                                 mmtt.subinventory_code)
      AND     milkfv.inventory_location_id(+) =
              DECODE(l_packaging_mode, WMS_CARTNZN_WRAP.PR_PKG_MODE, NULL, WMS_CARTNZN_WRAP.mfg_pr_pkg_mode, NULL,
                                                     mmtt.locator_id)
      AND     ccg.cost_group_id (+)      = mmtt.cost_group_id
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
      , INV_PROJECT.GET_LOCSEGS(milkfv.inventory_location_id,milkfv.organization_id);


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

   -- invconv changes bug 4377633
   cursor c_origination_type (p_origination_type NUMBER)
   IS
   SELECT meaning
    FROM   mfg_lookups
    WHERE  lookup_type = 'MTL_LOT_ORIGINATION_TYPE'
    AND    lookup_code = p_origination_type;
   l_origination_type                  mfg_lookups.meaning%TYPE;

  l_content_lpn_id  NUMBER;
  l_transfer_lpn_id  NUMBER;
  l_from_lpn_id    NUMBER;
  l_purchase_order   PO_HEADERS_ALL.SEGMENT1%TYPE;

  l_content_item_data LONG;

  l_selected_fields INV_LABEL.label_field_variable_tbl_type;
  l_selected_fields_count  NUMBER;

  l_content_rec_index NUMBER := 0;

  l_label_format_id       NUMBER := null ;
  l_label_format          VARCHAR2(100);
  l_printer        VARCHAR2(30);
  l_printer_sub    VARCHAR2(30) := null;

  l_api_name VARCHAR2(20) := 'get_variable_data';
  l_return_status VARCHAR2(240);

  l_error_message  VARCHAR2(240);
  l_msg_count      NUMBER;
  l_api_status     VARCHAR2(240);
  l_msg_data     VARCHAR2(240);

  i NUMBER;
  j NUMBER;

  new_label boolean:=true;
  no_of_rows_per_label NUMBER;
  row_index_per_label   NUMBER;
  max_no_of_rows_defined NUMBER;

  l_variable_name VARCHAR2(100);

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

------------------------End of this change for Custom Labels project code--------------------

  l_organization_id    NUMBER;

  l_lpn_table    inv_label.lpn_table_type;
  l_lpn_table_index  NUMBER;
  l_lpn_info lpn_data_type_rec; --lpn_data_tbl_type;
  l_item_info item_data_type_rec; --item_data_tbl_type;

  l_rcv_lpn_table rcv_label_tbl_type;  -- Table of LPN-level info :J-DEV
  l_rlpn_ndx NUMBER := 0; -- Index to table of records for l_rcv_lpn_table
  l_rcv_isp_header rcv_isp_header_rec ; -- Header-level info for ASN iSP

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

  -- Bug 2515486
  l_transaction_type_id    number := 0;
  l_transaction_action_id    number := 0;

  l_loop_counter      number := 0;
  l_label_index      NUMBER;
  l_label_request_id    NUMBER;

  --I cleanup, use l_prev_format_id to record the previous label format
  l_prev_format_id      NUMBER;

  l_patch_level NUMBER;

  -- Added for Bug 3581021 by joabraha
  -- Item id that is currently being processed in RCV flows
  l_cur_item_id number:= null;
  --

  -- Variable for EPC Generation
  -- Added for 11.5.10+ RFID Compliance project
  --Modified in R12

  l_epc VARCHAR2(300);
  l_epc_ret_status VARCHAR2(10);
  l_epc_ret_msg VARCHAR2(1000);
  l_label_status VARCHAR2(1);
  l_label_err_msg VARCHAR2(1000);
  l_is_epc_exist VARCHAR2(1) := 'N';

l_lot_attribute_info item_data_type_rec; --BUG6008065

    -- Bug 4137707
    v_lpn_content c_lpn_item_content%ROWTYPE;

  l_count_custom_sql NUMBER := 0; -- Added for Bug#4179391

  --Bug 4891916. Added the local variable to store the cycle count name
  l_cycle_count_name  mtl_cycle_count_headers.cycle_count_header_name%TYPE;
  --lpn status project start
  l_material_status_code varchar2(30) := NULL;
  l_onhand_status_enabled NUMBER := 0;
  --lpn status project end

BEGIN
    l_debug := INV_LABEL.l_debug;
  IF (l_debug = 1) THEN
     trace('**In PVT5: LPN Summary label**');
     trace('  Business_flow='||p_label_type_info.business_flow_code ||
           ', Transaction ID='||p_transaction_id ||
           ', Transaction Identifier='||p_transaction_identifier );
  END IF;
  -- Initialize return status as success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j)
          AND (inv_rcv_common_apis.g_po_patch_level >=inv_rcv_common_apis.g_patchset_j_po) THEN
     l_patch_level := 1;
  ELSIF (inv_rcv_common_apis.g_inv_patch_level  < inv_rcv_common_apis.g_patchset_j)
          AND (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po) THEN
     l_patch_level := 0;
  END IF;
  trace('patch level is ******* ' || l_patch_level);
  -- Get l_lpn_id
  IF p_lpn_id IS NOT NULL and p_label_type_info.business_flow_code <> 25 THEN
    l_lpn_id := p_lpn_id;
    /* Bug# 3263037 */
    l_lpn_table(1) := l_lpn_id;
    /* End of 3263037 */
  ELSE
    IF p_transaction_id IS NOT NULL THEN
    -- txn driven
    i := 1;
    IF p_label_type_info.business_flow_code in (1,2,3,4) THEN
      -- Receipt, Inspection, Delivery, Putaway
      IF ( p_transaction_identifier = INV_LABEL.TRX_ID_RT) OR l_patch_level = 1 THEN
      trace('is J patchset ');
       -- New Architecture : Get LPN from RT  :J-DEV
       -- Applicable with DM.J and IProc.J
        FOR v_rt_lpn IN c_rt_lpn LOOP
          l_rlpn_ndx := l_rlpn_ndx+1;

          l_rcv_lpn_table(l_rlpn_ndx).lpn_id := v_rt_lpn.lpn_id;
          trace('lpn_id = ' || l_rcv_lpn_table(l_rlpn_ndx).lpn_id || 'l_rlpn_ndx ' || l_rlpn_ndx);
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
       --   l_rcv_lpn_table(l_rlpn_ndx).deliver_to_location := v_rt_lpn.deliver_to_location;
       --   l_rcv_lpn_table(l_rlpn_ndx).location := v_rt_lpn.location;
          l_rcv_lpn_table(l_rlpn_ndx).note_to_receiver := v_rt_lpn.note_to_receiver;
          l_rcv_lpn_table(l_rlpn_ndx).item_id := v_rt_lpn.item_id;

          l_deliver_to_location_id := v_rt_lpn.deliver_to_location_id;
          l_location_id := v_rt_lpn.location_id;

          IF l_deliver_to_location_id IS NOT NULL OR l_location_id IS NOT NULL THEN
             trace('either l_location_id or l_deliver_to_location_id is not null');
             for v_hr in c_hr_locations loop
                l_rcv_lpn_table(l_rlpn_ndx).deliver_to_location := v_hr.deliver_to_location;
                l_rcv_lpn_table(l_rlpn_ndx).location := v_hr.location;
             END LOOP;
          END IF;

          --l_rlpn_ndx := l_rlpn_ndx+1;
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
        END IF;
      END IF;
    ELSIF p_label_type_info.business_flow_code in (21) THEN
      -- Ship confirm, delivery_id is passed
      -- Get all the LPNs for this delivery
      FOR v_wnd_lpn IN c_wnd_lpn LOOP
        l_lpn_table(i) := v_wnd_lpn.lpn_id;
        i := i+1;
      END LOOP;
    ELSIF p_label_type_info.business_flow_code in (22) THEN
      -- Cartonization: the lpn_id is in cartonization_id
      -- Set flag to so that packaging history will be checked for items.
      cartonization_flag := 1;

      -- Find the header and packing mode to identify cartonization batch
      -- if no records found, should not try to access wph, so set flag to 0
      Begin
        SELECT DISTINCT header_id, packaging_mode , pack_level
        INTO l_header_id, l_packaging_mode,l_pack_level
        FROM WMS_PACKAGING_HIST
        WHERE parent_lpn_id = p_transaction_id;
      EXCEPTION
        WHEN no_data_found THEN
         IF (l_debug = 1) THEN
            trace('No record found in WPH with parent_lpn_id: '|| p_transaction_id);
         END IF;
         cartonization_flag := 0;
      END;

      OPEN c_mmtt_cart_lpn;
      l_outermost_lpn_id := p_transaction_id;
      l_lpn_id := p_transaction_id;
      l_lpn_table(1) := l_lpn_id;
      /* Bug# 3423817*/
      l_pack_level := l_pack_level + 1;

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
                receipt_num, comments
         INTO l_rcv_isp_header.asn_num, l_rcv_isp_header.shipment_date,
                 l_rcv_isp_header.expected_receipt_date, l_rcv_isp_header.freight_terms,
                 l_rcv_isp_header.freight_carrier, l_rcv_isp_header.num_of_containers,
                 l_rcv_isp_header.bill_of_lading, l_rcv_isp_header.waybill_airbill_num,
                 l_rcv_isp_header.packing_slip,
                 l_rcv_isp_header.packaging_code, l_rcv_isp_header.special_handling_code,
                 l_rcv_isp_header.receipt_num, l_rcv_isp_header.comments
         FROM rcv_shipment_headers
         WHERE shipment_header_id = p_transaction_id
--     OR    shipment_header_id in --Bug 5051210. Performance fix. Removing OR and adding UNION
        UNION
         SELECT shipment_num asn_num, shipped_date shipment_date,
                 expected_receipt_date,freight_terms,
                 freight_carrier_code, num_of_containers,
                 bill_of_lading, waybill_airbill_num,
                 packing_slip,
                 packaging_code, special_handling_code,
                 receipt_num, comments
         FROM rcv_shipment_headers
         WHERE shipment_header_id IN
         (select shipment_header_id from rcv_shipment_lines
          where asn_lpn_id = p_lpn_id);

         -- Next retrieve details of all distinct LPNs associated with this shipment

         FOR v_asn_lpn IN c_asn_lpn
         LOOP
           l_rlpn_ndx := l_rlpn_ndx + 1;

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
      END LOOP;*/
    ELSIF p_label_type_info.business_flow_code in (29) THEN
    -- WIP Pick Drop, the lpn will not be packed, the lpn_id is transfer_lpn_id
      OPEN  c_mmtt_wip_pick_drop_lpn;
      FETCH    c_mmtt_wip_pick_drop_lpn
      INTO l_lpn_id, p_organization_id,
                 p_inventory_item_id, p_lot_number,
                 p_revision, p_qty, p_uom,
                             l_subinventory_code, l_locator_id,
                      l_secondary_quantity, l_secondary_uom; -- invconv changes

            IF c_mmtt_wip_pick_drop_lpn%NOTFOUND THEN
               IF (l_debug = 1) THEN
                  trace(' No WIP Pick Drop record found in MMTT for ID: '|| p_transaction_id);
               END IF;
               CLOSE c_mmtt_wip_pick_drop_lpn;
               RETURN;
            ELSE
               IF l_lpn_id IS NOT NULL THEN
                  l_lpn_table(1) := l_lpn_id;
               END IF;
            END IF;
    ELSIF p_label_type_info.business_flow_code in (27) THEN
      -- Putaway pregeneration
      -- Get lpn_id from mmtt
      FOR v_pregen_lpn IN c_mmtt_pregen_lpn LOOP
        l_lpn_table(1) := v_pregen_lpn.lpn_id;
        l_subinventory_code := v_pregen_lpn.subinventory_code;
        l_locator_id := v_pregen_lpn.locator_id;
	p_qty := v_pregen_lpn.quantity; --bug8775458
      END LOOP;

    -- Fix bug 2167545-1 Cost Group Update(11) is calling label printing through TM
    --   not manually, add 11 in the following group.
    -- Bug 4277718
    -- for WIP completion, lpn_id is used rather than transfer_lpn_id
    -- Changed to use c_mmtt_lpn

    --Bug 4891916. Modified the condition for business flow for cycle count
    --by checking for the business flow 8 and transaction_identifier as 5

    ELSIF p_label_type_info.business_flow_code IN (7,/*8,*/9,11,12,13,14,15,19,20,23,30,26)
    OR(p_label_type_info.business_flow_code IN(33) AND p_transaction_identifier=1)
    OR(p_label_type_info.business_flow_code = 8 AND p_transaction_identifier = 5) THEN
      -- Obtain lpn_id, content_lpn_id, transfer_lpn_id from
      -- MMT record.
      OPEN c_mmtt_lpn;
      FETCH c_mmtt_lpn
      INTO l_from_lpn_id, l_content_lpn_id, l_transfer_lpn_id,l_subinventory_code, l_locator_id,
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

          --Bug 4891916. For cycle count, opened the cursor to fetch
          --values for cycle count header name and counter
               IF p_label_type_info.business_flow_code = 8 THEN
                 OPEN cc_det_approval ;

                 FETCH cc_det_approval
                  INTO l_cycle_count_name
                     , l_requestor ;

                 IF cc_det_approval%NOTFOUND THEN
                   IF (l_debug = 1) THEN
                     TRACE(' No record found in MMTT for a cycle count id for given txn_temp_id: ' || p_transaction_id);
                   END IF;
                   CLOSE cc_det_approval;
                 END IF;

               END IF ; -- End of business flow=8 condition

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
              NULL;
              IF (l_debug = 1) THEN
                 trace('The Content LPN ID is not added to the l_lpn_table');
              END IF;
            ELSE
              l_lpn_table(i) := l_content_lpn_id;
              i := i+1;
              IF (l_debug = 1) THEN
                 trace('Content LPN ID has been added to the l_lpn_table');
              END IF;

            END IF;
          END IF;

          /* Start of fix for bug # 4751587 */
          /* The following condition has been added for fixing the bug # 4751587
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

        /*  IF (l_transfer_lpn_id IS NOT NULL)
              AND (nvl(l_transfer_lpn_id,-999) <> nvl(l_content_lpn_id,-999)) THEN
            l_lpn_table(i) := l_transfer_lpn_id;
            i := i+1;
          END IF; */

          /* End of fix for bug # 4751587 */

          -- Bug 2367828 : In case of LPN Splits, the LPN labels were being printed for
          -- the new LPN being generated, but nothing for the existing LPN from which the
          -- the new LPN was being split.   l_from_lpn_id is the mmtt.lpn_id(the from LPN)
          IF (l_from_lpn_id IS NOT NULL) THEN
            l_lpn_table(i) := l_from_lpn_id;
          END IF;
        END IF;

    --Bug 4891916- Added the condition to open the cursor to fetch from
    --mcce by checking for business flow 8 and transaction identifier 4
           ELSIF p_label_type_info.business_flow_code = 8 and p_transaction_identifier = 4 THEN
             IF (l_debug = 1) THEN
               TRACE(' In the condition for bus flow 8 and pti 4 ');
             END IF;

             OPEN mcce_lpn_cur ;

             FETCH mcce_lpn_cur
              INTO l_inventory_item_id
                 , l_organization_id
                 , l_lot_number
                 , l_cost_group_id
                 , l_qty
                 , l_uom
                 , l_revision
                 , l_subinventory_code
                 , l_locator_id
                 , l_lpn_id
                 , l_cycle_count_name
                 , l_requestor ;

             IF (l_debug = 1) THEN
               TRACE('Values fetched from cursor:');
               TRACE('Values of l_inventory_item_id:'|| l_inventory_item_id);
               TRACE('Values of l_organization_id:'  || l_organization_id);
               TRACE('Values of l_lot_number:'       || l_lot_number);
               TRACE('Values of l_cost_group_id:'    || l_cost_group_id);
               TRACE('Values of l_quantity:'         || l_qty);
               TRACE('Values of l_uom:'              || l_uom);
               TRACE('Values of l_revision:'         || l_revision);
               TRACE('Values of l_subinventory:'     || l_subinventory_code);
               TRACE('Values of l_locator_id:'       || l_locator_id);
               TRACE('Values of l_lpn_id:'           || l_lpn_id);
               TRACE('Values of l_cycle_count_name:' || l_cycle_count_name);
               TRACE('Values of Counter'             || l_requestor);
             END IF;

             IF mcce_lpn_cur%NOTFOUND THEN
               IF (l_debug = 1) THEN
                 TRACE(' No record in mcce for this transaction_id:' || p_transaction_id);
               END IF;

              CLOSE mcce_lpn_cur;
              RETURN;
             ELSE
               IF l_lpn_id IS NOT NULL THEN
                 l_lpn_table(1)  := l_lpn_id;
               END IF;
               CLOSE mcce_lpn_cur ;
            END IF;
          --End of fix for Bug 4891916

    -- 18th February 2002 : Commented out below for fix to bug 2219171 for Qualcomm. Hence forth the
    -- WMSTASKB.pls will be calling label printing at Pick Load and WIP Pick Load with the
    -- transaction_temp_id as opposed to the transaction_header_id earlier. These business flows(18, 28,34)
    -- have been added to  the above call.
    ELSIF p_label_type_info.business_flow_code in (18,28,34) THEN
    -- Pick Load
    OPEN   c_mmtt_lpn_pick_load;
    FETCH   c_mmtt_lpn_pick_load INTO l_lpn_id, p_organization_id,
      p_inventory_item_id, p_lot_number, p_revision, p_qty,
                        p_uom, l_subinventory_code, l_locator_id, l_printer_sub,
                  l_secondary_quantity, -- invconv changes
                  l_secondary_uom; -- invconv changes

      IF c_mmtt_lpn_pick_load%NOTFOUND THEN
        IF (l_debug = 1) THEN
           trace(' No record found in MMTT for temp ID: '|| p_transaction_id);
        END IF;
        CLOSE c_mmtt_lpn_pick_load;
        RETURN;
      ELSE
        IF l_lpn_id IS NOT NULL THEN
          l_lpn_table(1) := l_lpn_id;
        END IF;
      END IF;


     ELSIF p_label_type_info.business_flow_code in (33) AND p_transaction_identifier>1  THEN
       -- Flow Completion, not MMTT based

       IF p_transaction_identifier=2 THEN
          IF (l_debug = 1) THEN
             trace('Flow Label - MTI based');
          END IF;
          FOR v_flow_mti_lpn IN c_flow_lpn_mti LOOP
       l_lpn_table(i) :=v_flow_mti_lpn.lpn_id;
       i := i+1;
          END LOOP;
        ELSIF p_transaction_identifier=3 THEN
          IF (l_debug = 1) THEN
             trace('Flow Label - MOL based');
          END IF;
          FOR v_flow_mol_lpn IN c_flow_lpn_mti LOOP
       l_lpn_table(i) :=v_flow_mol_lpn.lpn_id;
       i := i+1;
          END LOOP;
       END IF;

    ELSE
      IF (l_debug = 1) THEN
         trace(' Invalid business flow code '|| p_label_type_info.business_flow_code);
      END IF;
      RETURN;
    END IF;
    ELSE
    -- On demand, get information from input_param
    --  for transactions which don't have a mmtt row in the table,
    --   they will also call in a manual mode, they are
    --   5 LPN Correction/Update
    --   10 Material Status update
    --   16 LPN Generation
    --    25 Import ASN
	trace('krishna');
    trace(' Business flow code is : '|| p_label_type_info.business_flow_code);
    trace(' l_cur_item_id : '|| l_cur_item_id);
    trace(' p_inventory_item_id : '|| p_inventory_item_id);

    l_lpn_table(1) := nvl(p_lpn_id,p_input_param.lpn_id);
    END IF;
  END IF;

  IF (l_debug = 1) THEN
     trace('Value of l_rlpn_ndx: '||l_rlpn_ndx);
     trace(' No. of LPN_IDs found: '|| l_lpn_table.count);
  END IF;
  IF (l_debug = 1) THEN
      FOR i IN 1..l_lpn_table.count LOOP
       trace(' LPN_ID('||i||')'|| l_lpn_table(i));
    END LOOP;
  END IF;
  trace('lpn table count ' || l_lpn_table.count || ' l_rlpn_ndx ' || l_rlpn_ndx);
  IF l_lpn_table.count = 0 AND l_rlpn_ndx = 0 THEN
    IF (l_debug = 1) THEN
       trace(' No LPN found, can not process ');
    END IF;
    RETURN;
  END IF;



/* Blocked in R12

  IF (l_debug = 1) THEN
     trace(' Getting selected fields ');
  END IF;
  INV_LABEL.GET_VARIABLES_FOR_FORMAT(
    x_variables     => l_selected_fields
  ,  x_variables_count  => l_selected_fields_count
  ,  x_is_variable_exist => l_is_epc_exist
  ,  p_format_id    => p_label_type_info.default_format_id
  ,  p_exist_variable_name => 'EPC');

  IF (l_selected_fields_count=0) OR (l_selected_fields.count =0 ) THEN
    IF (l_debug = 1) THEN
       trace('no fields defined for this format: ' || p_label_type_info.default_format_id || ',' ||p_label_type_info.default_format_name);
    END IF;
    --return;
  END IF;

  IF (l_debug = 1) THEN
     trace(' Found variable defined for this format, cont = ' || l_selected_fields_count);
  END IF;
    */

  l_content_rec_index := 0;
  l_content_item_data := '';
  IF (l_debug = 1) THEN
     trace('** in PVT5.get_variable_dataa ** , start ');
  END IF;
  l_printer := p_label_type_info.default_printer;

  -- Get number of rows per label
  BEGIN
    select min(table_a.c) into no_of_rows_per_label
    from (select wlfv.label_field_id,
      wlf.column_name, count(*) c
      from wms_label_field_variables wlfv, wms_label_fields_vl wlf
      where wlfv.label_field_id = wlf.label_field_id
      and wlfv.label_format_id = p_label_type_info.default_format_id
        group by wlfv.label_field_id, wlf.column_name
        having count(*)>1 ) table_a;
  EXCEPTION
    WHEN no_data_found THEN
      IF (l_debug = 1) THEN
         trace(' Did not find defined rows ');
      END IF;
  END;

  IF (no_of_rows_per_label IS NULL) OR (no_of_rows_per_label=0) THEN
    no_of_rows_per_label :=1 ;
  END IF;

  IF (l_debug = 1) THEN
     trace(' Got max rows per label='|| no_of_rows_per_label);
  END IF;
  new_label := true;
  row_index_per_label := 0;

  IF (l_debug = 1) THEN
     trace('LPN ID = '||l_lpn_id||','||', Patch Level = '||l_patch_level||','||
     ', RLPN indx = '|| l_rlpn_ndx);
  END IF;

  FOR i IN 1..l_rlpn_ndx
  LOOP
      IF (l_debug = 1) THEN
         trace(' For l_rcv_lpn_table (' || i ||')'||'.lpn_id = '|| l_rcv_lpn_table(i).lpn_id);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.purchase_order =' ||l_rcv_lpn_table(i).purchase_order);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.subinventory =' ||l_rcv_lpn_table(i).subinventory);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.locator_id =' ||l_rcv_lpn_table(i).locator_id);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.due_date =' ||l_rcv_lpn_table(i).due_date);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.truck_num =' ||l_rcv_lpn_table(i).truck_num);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.country_of_origin =' ||l_rcv_lpn_table(i).country_of_origin);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.comments =' ||l_rcv_lpn_table(i).comments);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.po_line_num =' ||l_rcv_lpn_table(i).po_line_num);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.quantity_ordered =' ||l_rcv_lpn_table(i).quantity_ordered);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.supplier_part_number =' ||l_rcv_lpn_table(i).supplier_part_number);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.vendor_id =' ||l_rcv_lpn_table(i).vendor_id);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.vendor_site_id =' ||l_rcv_lpn_table(i).vendor_site_id);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.supplier_site =' ||l_rcv_lpn_table(i).supplier_site);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.supplier_name =' ||l_rcv_lpn_table(i).supplier_name);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.requestor =' ||l_rcv_lpn_table(i).requestor);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.deliver_to_location =' ||l_rcv_lpn_table(i).deliver_to_location);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.location =' ||l_rcv_lpn_table(i).location);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.note_to_receiver =' ||l_rcv_lpn_table(i).note_to_receiver);
     trace(' For l_rcv_lpn_table (' || i ||')'||'.receipt_num =' ||l_rcv_lpn_table(l_rlpn_ndx).receipt_num);
      END IF;
  END LOOP;

  IF l_lpn_id IS NULL AND l_rlpn_ndx = 0 THEN
     trace('l_lpn_id IS NULL AND l_rlpn_ndx = 0 ');
    l_lpn_id := l_lpn_table(1);
    IF (l_debug = 1) THEN
       trace('l_lpn_id = ' || l_lpn_id);
    END IF;
  -- Added for Bug 3581021 by joabraha
  ELSIF l_lpn_id IS NULL AND l_patch_level = 1 AND l_rlpn_ndx <> 0 THEN
     IF (l_debug = 1) THEN
        trace('Within Else l_lpn_id IS NULL AND l_patch_level = 1 AND l_rlpn_ndx <> 0');
     END IF;
     /*   l_lpn_id := l_rcv_lpn_table(l_rlpn_ndx).lpn_id; */
     l_lpn_id := l_rcv_lpn_table(1).lpn_id;
     l_cur_item_id :=  l_rcv_lpn_table(1).item_id;
     IF (l_debug = 1) THEN
       trace('l_lpn_id = ' || l_lpn_id);
    END IF;
  --
  END IF;
  l_lpn_table_index :=0;

     IF (l_debug = 1) THEN
        trace('Past the newly added else clause');
     END IF;

  -- If labelAPI called for RCV flows with new architecture, then
  -- l_rlpn_ndx will be set. If so, then override earlier algorithms
  if ( l_rlpn_ndx <> 0 ) then
     trace('l_rlpn_ndx <> 0 ' || l_rlpn_ndx);
    l_lpn_id := l_rcv_lpn_table(1).lpn_id;
  end if;

  l_content_item_data := '';
  l_label_index := 1;

  IF (l_debug = 1) THEN
     trace('Manual Format='||p_label_type_info.manual_format_id||','
    ||p_label_type_info.manual_format_name
    ||',Manual Printer='||p_label_type_info.manual_printer);
  END IF;
  l_prev_format_id := p_label_type_info.default_format_id;

  IF (l_debug = 1) THEN
     trace('Before entering the While loop');
     trace('lpn_id=' ||l_lpn_id ||' package id=' || l_package_id ||
        ' organization_id=' || p_organization_id||' inventory_item_id=' || p_inventory_item_id||
         ' revision=' || p_revision ||' lot=' || p_lot_number||
         ' quantity=' || p_qty||' uom=' || p_uom);
     trace('cartonization flag=' || cartonization_flag||' header id=' || l_header_id||' Packaging Mode=' || l_packaging_mode);
  END IF;

  l_lpn_table_index := l_lpn_table_index + 1; -- Bug 3229533

  WHILE l_lpn_id IS NOT NULL OR l_package_id IS NOT NULL LOOP
    IF (l_debug = 1) THEN
       trace(' calling Summary loop, lpn=' || l_lpn_id || ' package_id=' || l_package_id);
       trace(' for: lpn_id='||l_lpn_id||', l_cur_item='||l_cur_item_id||',ndx='||l_lpn_table_index);
    END IF;

    -- Fix for bug: 4179593 <Begin>
      l_custom_sql_ret_status := FND_API.G_RET_STS_SUCCESS;
    -- Fix for bug: 4179593 <End>

    -- Fix for bug: 4179593 Start
    l_CustSqlWarnFlagSet := FALSE;
    l_CustSqlErrFlagSet := FALSE;
    l_CustSqlWarnMsg := NULL;
    l_CustSqlErrMsg := NULL;
    -- Fix for bug: 4179593 End

    -- Bug 4238729, 10+ CU2 bug
    -- Reset l_epc for each LPN
    l_epc := null;

    -- Bug 4137707, performance of printing at cartonization
    -- Open seperate cursor for cartonization and non-cartonization flow
    -- FOR v_lpn_content IN c_lpn_item_content(l_lpn_id, l_package_id, l_cur_item_id) LOOP
    v_lpn_content := NULL;
    IF cartonization_flag = 0 THEN
      -- non cartonization flow
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
      OPEN c_lpn_item_content_cart(l_lpn_id, l_package_id);
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
      row_index_per_label := row_index_per_label + 1;
      IF (l_debug = 1) THEN
         trace('Item=' || v_lpn_content.inventory_item_id || ' Qty=' || v_lpn_content.quantity);
         trace('organization= ' || v_lpn_content.organization_id);
         trace('revision= ' || v_lpn_content.revision);
         trace('lot number= '|| v_lpn_content.lot_number);
         trace('quantity= ' ||v_lpn_content.quantity);
         trace('uom= ' || v_lpn_content.uom);
         trace('cost group id= '|| v_lpn_content.cost_group_id);
         trace('cost group= ' ||  v_lpn_content.cost_group);
         trace('subinventory_code=  '|| v_lpn_content.subinventory_code);
         trace('location id= ' || v_lpn_content.locator_id);
         trace('locator= ' || v_lpn_content.locator);
         trace('In Loop, record_index= ' || l_content_rec_index || ', row_index_per_label='  ||row_index_per_label);
      END IF;

      /* Bug# 3739739 */
      IF (p_label_type_info.business_flow_code in (7,8,9,11,12,13,14,15,19,20,23,30)) THEN

         -- Fix for BUG: 4654102. For the Buss. Flow 15, the UOM and QTY from WLC should
         -- be considered and therefore the conversion is not required.
         -- Added the AND condition(second part) to the following statement.
         /* Added the business flow code 14 in the second condition for the bug # 4860964 */
	 /*Bug# 8574051,added lot number and org_id in inv_convert.inv_um_convert() call*/
         IF(l_uom <> v_lpn_content.uom AND p_label_type_info.business_flow_code NOT IN (14, 15)) THEN
            --Transaction UOM is different from Primary UOM
            --Get the transaction quantity from the primary quantity
            l_qty :=
                     inv_convert.inv_um_convert ( v_lpn_content.inventory_item_id,
		                                  v_lpn_content.lot_number,
 	                                          v_lpn_content.organization_id,
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
IF (p_label_type_info.business_flow_code IN (12, 13,19, 26, 33)) THEN --Adding the business flows 26 and 33 for Bug 6008065
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

     -- added by fabdi
      IF (l_item_info.origination_type IS NOT NULL)
      THEN
        OPEN c_origination_type (l_item_info.origination_type);
      FETCH c_origination_type INTO l_origination_type;
      CLOSE c_origination_type;
      END IF;
           --lpn status project start
    IF(inv_cache.set_org_rec(v_lpn_content.organization_id))THEN
         IF((inv_cache.org_rec.default_status_id) IS NOT NULL)THEN
            l_onhand_status_enabled := 1;
            IF (l_debug = 1) THEN
               trace('Org is onhand status enabled');
            END IF;
         Else
           l_onhand_status_enabled := 0;
         END IF;
       END IF;
       IF (l_onhand_status_enabled = 1) THEN
         l_item_info.lot_number_status := NULL;
           IF (l_debug = 1) THEN
               trace('going to get_txn_lpn_status');
          END IF;
         l_material_status_code := INV_LABEL.get_txn_lpn_status(p_lpn_id=>l_lpn_id,
                                                                p_transaction_id => p_transaction_id,
                                                                p_organization_id =>v_lpn_content.organization_id ,
                                                                p_business_flow =>p_label_type_info.business_flow_code);
       END IF;

--lpn status project

      -- Since it is a multi-record format,
      -- it will not apply different format for each record
      -- because they are in the same label
      IF l_content_rec_index = 1 OR (new_label) THEN -- Bug 3229533


        IF (l_debug = 1) THEN
           trace('   Going to apply rule engine to get label format with printer: ' || l_printer);
        END IF;
        /* Bug 3229533 */
        IF p_label_type_info.manual_format_id IS NOT NULL THEN
          l_label_format_id := p_label_type_info.manual_format_id;
          l_label_format := p_label_type_info.manual_format_name;
        ELSE
          l_label_format_id := null;
          l_label_format := null;
        END IF;
        /* Bug 3229533 */
        INV_LABEL.GET_FORMAT_WITH_RULE
        (   p_document_id        =>p_label_type_info.label_type_id,
          p_label_format_id    =>p_label_type_info.manual_format_id,
          p_organization_id    =>v_lpn_content.organization_id,
           p_inventory_item_id  =>v_lpn_content.inventory_item_id,
          p_subinventory_code  =>v_lpn_content.subinventory_code,
          p_locator_id         =>v_lpn_content.locator_id,
          p_lpn_id             =>l_lpn_id,
          P_LOT_NUMBER         =>v_lpn_content.lot_number,
          P_REVISION           =>v_lpn_content.revision,
          P_BUSINESS_FLOW_CODE =>   p_label_type_info.business_flow_code,
          P_PACKAGE_ID        => l_package_id,
          --P_PRINTER_NAME       =>l_printer, Blocked in R12
          -- Added for Bug 2748297 Start
          P_SUPPLIER_ID        => l_vendor_id,
          P_SUPPLIER_SITE_ID   => l_vendor_site_id,
          -- End
          P_LAST_UPDATE_DATE   =>sysdate,
          P_LAST_UPDATED_BY    =>FND_GLOBAL.user_id,
          P_CREATION_DATE      =>sysdate,
          P_CREATED_BY         =>FND_GLOBAL.user_id,

          x_return_status      =>l_return_status,
          x_label_format_id   =>l_label_format_id,
          x_label_format    =>l_label_format,
          x_label_request_id  =>l_label_request_id);

        IF l_return_status <> 'S' THEN
          IF (l_debug = 1) THEN
             trace(' Error in applying rules engine, setting as default');
          END IF;
          /* Bug 3229533 */
          IF l_content_rec_index = 1 THEN
            l_label_format := p_label_type_info.default_format_name;
            l_label_format_id := p_label_type_info.default_format_id;
          ELSIF (new_label) THEN
            l_label_format_id := l_prev_format_id;
          END IF;
        END IF;

        /* Bug 3229533 */
        /*IF p_label_type_info.manual_format_id IS NOT NULL THEN
          l_label_format_id := p_label_type_info.manual_format_id;
          l_label_format := p_label_type_info.manual_format_name;
        END IF; */

        l_prev_format_id := l_label_format_id;

        IF l_debug =1 THEN
            trace('Label format after calling rules engine, l_label_format_id='||l_label_format_id||',l_label_format='||l_label_format);
        END IF;


   --R12: RFID Compliance: Moved this call to after calling the Rules Engine
   IF p_label_type_info.manual_printer IS NULL THEN
      IF (nvl(l_printer_sub,v_lpn_content.subinventory_code) IS NOT NULL) THEN
              IF (l_debug = 1) THEN
                 trace('getting printer with sub '||nvl(l_printer_sub,v_lpn_content.subinventory_code));
                 -- null;
              END IF;

              BEGIN
       WSH_REPORT_PRINTERS_PVT.get_printer
         (p_concurrent_program_id=>p_label_type_info.label_type_id,
          p_user_id              =>fnd_global.user_id,
          p_responsibility_id    =>fnd_global.resp_id,
          p_application_id       =>fnd_global.resp_appl_id,
          p_organization_id      =>v_lpn_content.organization_id,
          p_zone                 =>nvl(l_printer_sub,v_lpn_content.subinventory_code),
          p_format_id            =>l_label_format_id, --added in R12
          x_printer              =>l_printer,
          x_api_status           =>l_api_status,
          x_error_message        =>l_error_message);

       IF l_api_status <> 'S' THEN
          IF (l_debug = 1) THEN
             trace('Error in GET_PRINTER '||l_error_message);
          END IF;
          l_printer := p_label_type_info.default_printer;
       END IF;
         EXCEPTION
       WHEN others THEN
          l_printer := p_label_type_info.default_printer;
              END;
          END IF;
    ELSE
        l_printer := p_label_type_info.manual_printer;
        END IF;


   IF (l_debug = 1) THEN
           trace(' Getting selected fields for label_format_id :'||l_label_format_id);
        END IF;
        INV_LABEL.get_variables_for_format
     (
      x_variables            => l_selected_fields
      ,  x_variables_count   => l_selected_fields_count
      ,  x_is_variable_exist => l_is_epc_exist
      ,  p_format_id         => l_label_format_id
      ,  p_exist_variable_name => 'EPC');

        IF (l_selected_fields_count=0) OR (l_selected_fields.count =0 ) THEN
      IF (l_debug = 1) THEN
             trace('no fields defined for this format: ' || l_label_format_id || ',' ||l_label_format);
      END IF;

      GOTO nextlabel; --Added in R12

        END IF;

        IF (l_debug = 1) THEN
           trace(' Found variable defined for this format, cont = ' || l_selected_fields_count);
        END IF;

        -- Get number of rows per label
        BEGIN
          select min(table_a.c) into no_of_rows_per_label
          from (select wlfv.label_field_id,
            wlf.column_name, count(*) c
            from wms_label_field_variables wlfv, wms_label_fields_vl wlf
            where wlfv.label_field_id = wlf.label_field_id
            and wlfv.label_format_id = l_label_format_id
                group by wlfv.label_field_id, wlf.column_name
                having count(*)>1 ) table_a;
        EXCEPTION
          WHEN no_data_found THEN
            IF (l_debug = 1) THEN
               trace(' Did not find defined rows ');
            END IF;
        END;

        IF (no_of_rows_per_label IS NULL) OR (no_of_rows_per_label=0) THEN
          no_of_rows_per_label :=1 ;
        END IF;


        build_format_fields_structure (l_label_format_id);

        -- Added for 11.5.10+ RFID compliance project
        -- Get RFID/EPC related information for a format
        -- Only do this if EPC is a field included in the format

        -- Bug 4238729, 10+ CU2
        -- Move this section into l_content_rec_index = 1 cause only need to do it once when get new format
        -- Generate EPC once for each LPN
        IF l_is_epc_exist = 'Y' THEN
            IF (l_debug =1) THEN
                trace('EPC is a field included in the format, getting RFID/EPC related information from format');
            END IF;
            BEGIN

          -- Modified in R12 -- changed spec WMS_EPC_PVT.generate_epc()
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
           p_label_type_id   => p_label_type_info.label_type_id, -- 5
           p_group_id          => inv_label.epc_group_id,
           p_label_format_id => l_label_format_id,
           p_label_request_id    => l_label_request_id,
           p_business_flow_code  => p_label_type_info.business_flow_code,
           x_epc                 => l_epc,
           x_return_status       => l_epc_ret_status, -- S / E / U
           x_return_mesg         => l_epc_ret_msg
         );

        IF (l_debug = 1) THEN
           trace('Called generate_epc with ');
           trace('p_label_type_id='||p_label_type_info.label_type_id||',p_group_id='||inv_label.epc_group_id);
           trace('l_label_request_id='||l_label_request_id||',p_user_id='||fnd_global.user_id);
           trace('l_label_format_id='||l_label_format_id||',p_org_id='||v_lpn_content.organization_id);
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
                 END IF; -- End if l_epc is null

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
        END IF; -- End if l_epc_exists = 'Y'
        -- End bug 4238729

      END IF; -- IF l_content_rec_index = 1


      -- Added for UCC 128 J Bug #3067059
      INV_LABEL.is_item_gtin_enabled
   (
    x_return_status      =>   l_return_status
    , x_gtin_enabled       =>   l_gtin_enabled
    , x_gtin               =>   l_gtin
    , x_gtin_desc          =>   l_gtin_desc
    , p_organization_id    =>   v_lpn_content.organization_id
    , p_inventory_item_id  =>   v_lpn_content.inventory_item_id
    , p_unit_of_measure    =>   v_lpn_content.uom
    , p_revision           =>   v_lpn_content.revision);



      --trace('Starting assign variables, ');
      /* variable header */
      IF(new_label) THEN
        IF (l_debug = 1) THEN
           trace('Inside New Label');
        END IF;

        l_label_status := INV_LABEL.G_SUCCESS;
        l_label_err_msg := NULL;

        row_index_per_label := 1;
        l_content_item_data := l_content_item_data || LABEL_B;
        IF  (l_label_format_id IS NOT NULL) AND
          (l_label_format_id <> nvl(p_label_type_info.default_format_id,-999)) THEN
          l_content_item_data := l_content_item_data || ' _FORMAT="' || l_label_format || '"';
        END IF;
        IF (l_printer IS NOT NULL) AND
          (l_printer <> nvl(p_label_type_info.default_printer, '@@@')) THEN
          l_content_item_data := l_content_item_data || ' _PRINTERNAME="'||l_printer ||'"';
        END IF;
        l_content_item_data := l_content_item_data || TAG_E;

        --For each new label, need to call get_format_with_rule to insert a WLR record
        -- but passing p_use_rule_engine a 'N'
        -- Only do this if it is not the first label
        /* Bug 3229533
         IF l_content_rec_index <> 1 THEN

          INV_LABEL.GET_FORMAT_WITH_RULE
          (   p_document_id        =>p_label_type_info.label_type_id,
            p_label_format_id    =>p_label_type_info.manual_format_id,
            p_organization_id    =>v_lpn_content.organization_id,
             p_inventory_item_id  =>v_lpn_content.inventory_item_id,
            p_subinventory_code  =>v_lpn_content.subinventory_code,
            p_locator_id         =>v_lpn_content.locator_id,
            p_lpn_id             =>l_lpn_id,
            P_LOT_NUMBER         =>v_lpn_content.lot_number,
            P_REVISION           =>v_lpn_content.revision,
            P_BUSINESS_FLOW_CODE =>   p_label_type_info.business_flow_code,
            P_PACKAGE_ID        => l_package_id,
            P_PRINTER_NAME       =>l_printer,
            P_LAST_UPDATE_DATE   =>sysdate,
            P_LAST_UPDATED_BY    =>FND_GLOBAL.user_id,
            P_CREATION_DATE      =>sysdate,
            P_CREATED_BY         =>FND_GLOBAL.user_id,
            p_use_rule_engine    => 'N',
            x_return_status      =>l_return_status,
            x_label_format_id   =>l_label_format_id,
            x_label_format    =>l_label_format,
            x_label_request_id  =>l_label_request_id);

          IF l_return_status <> 'S' THEN
            IF (l_debug = 1) THEN
               trace(' Error in applying rules engine, setting as default');
            END IF;
          END IF;
          l_label_format_id := l_prev_format_id;
        END IF;*/
        new_label := false;
      END IF; --new_label

      /* Loop for each selected fields, find the columns and write into the XML_content*/

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  For the column name 'sql_stmt', if the variable name is not null implies that the field  |
--  is a Custom SQL. For this variable name, get the corresponding SQL statement using the   |
--  function get_sql_for_variable(). Handle the sql appropriately.                           |
---------------------------------------------------------------------------------------------
 l_count_custom_sql := 0; -- Added for Bug#4179391
 Loop -- Added for Bug#4179391
   EXIT WHEN l_count_custom_sql >= g_count_custom_sql; -- Added for Bug#4179391
      --l_variable_name := get_variable_name('sql_stmt', row_index_per_label-1, l_label_format_id); -- Commented the statment to replace row_index_per_label with l_count_custom_sql
      l_variable_name := get_variable_name('sql_stmt', l_count_custom_sql, l_label_format_id); -- Added for Bug#4179391
      IF l_variable_name IS NOT NULL THEN
         --l_sql_stmt := get_sql_for_variable('sql_stmt', row_index_per_label-1, l_label_format_id); -- Commented the statment to replace row_index_per_label with l_count_custom_sql
         l_sql_stmt := get_sql_for_variable('sql_stmt', l_count_custom_sql, l_label_format_id); -- Added for Bug#4179391
         IF (l_sql_stmt IS NOT NULL) THEN
             IF (l_debug = 1) THEN
               trace('Custom Labels Trace [INVLAP5B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
               trace('Custom Labels Trace [INVLAP5B.pls]: FIELD_VARIABLE_NAME  : ' || l_variable_name);
               trace('Custom Labels Trace [INVLAP5B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
              END IF;
              l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
              IF (l_debug = 1) THEN
               trace('Custom Labels Trace [INVLAP5B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
              END IF;
              BEGIN
              IF (l_debug = 1) THEN
               trace('Custom Labels Trace [INVLAP5B.pls]: At Breadcrumb 1');
               trace('Custom Labels Trace [INVLAP5B.pls]: LABEL_REQUEST_ID : ' || l_label_request_id);
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
                  trace('Custom Labels Trace [INVLAP5B.pls]: At Breadcrumb 2');
                  trace('Custom Labels Trace [INVLAP5B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
                  trace('Custom Labels Trace [INVLAP5B.pls]: WARNING: NULL value returned by the custom SQL Query.');
                  trace('Custom Labels Trace [INVLAP5B.pls]: l_custom_sql_ret_status is set to : ' || l_custom_sql_ret_status);
                END IF;
              ELSIF c_sql_stmt%rowcount=0 THEN
                 IF (l_debug = 1) THEN
                  trace('Custom Labels Trace [INVLAP5B.pls]: At Breadcrumb 3');
                  trace('Custom Labels Trace [INVLAP5B.pls]: WARNING: No row returned by the Custom SQL query');
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
                  trace('Custom Labels Trace [INVLAP5B.pls]: At Breadcrumb 4');
                  trace('Custom Labels Trace [INVLAP5B.pls]: ERROR: Multiple values returned by the Custom SQL query');
                 END IF;
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
                  trace('Custom Labels Trace [INVLAP5B.pls]: At Breadcrumb 5');
                  trace('Custom Labels Trace [INVLAP5B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
                 END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
               fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
               fnd_msg_pub.ADD;
               fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
            IF (l_debug = 1) THEN
               trace('Custom Labels Trace [INVLAP5B.pls]: At Breadcrumb 6');
               trace('Custom Labels Trace [INVLAP5B.pls]: Before assigning it to l_content_item_data');
            END IF;
             l_content_item_data  :=   l_content_item_data
                                || variable_b
                                || l_variable_name
                                || '">'
                                || l_sql_stmt_result
                                || variable_e;
             l_sql_stmt_result := NULL;
             l_sql_stmt        := NULL;
             IF (l_debug = 1) THEN
               trace('Custom Labels Trace [INVLAP5B.pls]: At Breadcrumb 7');
               trace('Custom Labels Trace [INVLAP5B.pls]: After assigning it to l_content_item_data');
               trace('Custom Labels Trace [INVLAP5B.pls]: --------------------------REPORT END-------------------------------------');
             END IF;
         END IF;
         END IF;
  l_count_custom_sql := l_count_custom_sql + 1; -- Added for Bug#4179391
  END LOOP; -- Added for Bug#4179391
------------------------End of this change for Custom Labels project code--------------------

      l_variable_name := get_variable_name('current_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || INV_LABEL.G_DATE || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('current_time', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || INV_LABEL.G_TIME || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('request_user', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || INV_LABEL.G_USER || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('package_id', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_package_id || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('organization', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.organization, l_lot_attribute_info.organization) || VARIABLE_E;
      END IF;

      l_variable_name := get_variable_name('subinventory_code', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_variable_name || '">' || v_lpn_content.subinventory_code || VARIABLE_E;
        --null;
      END IF;
      l_variable_name := get_variable_name('locator', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || v_lpn_content.locator || VARIABLE_E;
        --null;
      END IF;

      l_variable_name := get_variable_name('item', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.item,l_lot_attribute_info.item) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('client_item', row_index_per_label-1, l_label_format_id);		-- Added for LSP Project, bug 9087971
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.client_item,l_lot_attribute_info.client_item) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_description', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.item_description,l_lot_attribute_info.item_description) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_number', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || v_lpn_content.lot_number || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('quantity', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || v_lpn_content.quantity || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('volume', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.volume || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('volume_uom', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.volume_uom || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('gross_weight', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.gross_weight || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('gross_weight_uom', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.gross_weight_uom || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('tare_weight', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.tare_weight || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('tare_weight_uom', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.tare_weight_uom || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('container_item', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.container_item || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('revision', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || v_lpn_content.revision || VARIABLE_E;
      END IF;/* 8886501  */
      l_variable_name := get_variable_name('lot_number_status', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_number_status,l_lot_attribute_info.lot_number_status) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_expiration_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_expiration_date,l_lot_attribute_info.lot_expiration_date) || VARIABLE_E;   /* 8886501  */
      END IF;
      l_variable_name := get_variable_name('uom', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || v_lpn_content.uom || VARIABLE_E;
        --null;
      END IF;
      l_variable_name := get_variable_name('cost_group', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || v_lpn_content.cost_group || VARIABLE_E;
        --null;
      END IF;
      l_variable_name := get_variable_name('item_hazard_class', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.item_hazard_class,l_lot_attribute_info.item_hazard_class) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('po_num', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
        if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
          l_content_item_data := l_content_item_data || VARIABLE_B || l_variable_name
           || '">' || l_rcv_lpn_table(l_lpn_table_index).purchase_order|| VARIABLE_E;
        else
            l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_variable_name || '">' || l_purchase_order || VARIABLE_E;
         end if;
      END IF;


      /* 8886501  */
      l_variable_name := get_variable_name('item_attribute_category', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.item_attribute_category,l_lot_attribute_info.item_attribute_category) || VARIABLE_E;
      END IF;


      /* 8886501  */


      l_variable_name := get_variable_name('item_attribute1', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.item_attribute1,l_lot_attribute_info.item_attribute1) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute2', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' ||  nvl(l_item_info.item_attribute2,l_lot_attribute_info.item_attribute2) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute3', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' ||  nvl(l_item_info.item_attribute3,l_lot_attribute_info.item_attribute3) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute4', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' ||  nvl(l_item_info.item_attribute4,l_lot_attribute_info.item_attribute4) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute5', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl( l_item_info.item_attribute5,l_lot_attribute_info.item_attribute5) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute6', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl( l_item_info.item_attribute6,l_lot_attribute_info.item_attribute6) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute7', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl( l_item_info.item_attribute7,l_lot_attribute_info.item_attribute7) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute8', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl( l_item_info.item_attribute8,l_lot_attribute_info.item_attribute8) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute9', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl( l_item_info.item_attribute9,l_lot_attribute_info.item_attribute9) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute10', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' ||  nvl(l_item_info.item_attribute10,l_lot_attribute_info.item_attribute10) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute11', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl( l_item_info.item_attribute11,l_lot_attribute_info.item_attribute11) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute12', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' ||  nvl(l_item_info.item_attribute12,l_lot_attribute_info.item_attribute12) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute13', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' ||  nvl(l_item_info.item_attribute13,l_lot_attribute_info.item_attribute13) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute14', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' ||  nvl(l_item_info.item_attribute14,l_lot_attribute_info.item_attribute14) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('item_attribute15', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' ||  nvl(l_item_info.item_attribute15,l_lot_attribute_info.item_attribute15) || VARIABLE_E;
      END IF;


	l_variable_name := get_variable_name('lpn_attribute_category', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute_category || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute1', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute1 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute2', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute2 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute3', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute3 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute4', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute4 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute5', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute5 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute6', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute6 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute7', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute7 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute8', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute8 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute9', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute9 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute10', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute10 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute11', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute11 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute12', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute12 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute13', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute13 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute14', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute14 || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lpn_attribute15', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.lpn_attribute15 || VARIABLE_E;
      END IF;




      /*8886501*/

      l_variable_name := get_variable_name('lot_attribute_category', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_attribute_category,l_lot_attribute_info.lot_attribute_category) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute1', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl( l_item_info.lot_c_attribute1,l_lot_attribute_info.lot_c_attribute1) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute2', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute2,l_lot_attribute_info.lot_c_attribute2) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute3', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute3,l_lot_attribute_info.lot_c_attribute3) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute4', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute4,l_lot_attribute_info.lot_c_attribute4) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute5', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute5,l_lot_attribute_info.lot_c_attribute5 )|| VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute6', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute6,l_lot_attribute_info.lot_c_attribute6) || VARIABLE_E;
      END IF;

      l_variable_name := get_variable_name('lot_c_attribute7', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute7,l_lot_attribute_info.lot_c_attribute7) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute8', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute8,l_lot_attribute_info.lot_c_attribute8) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute9', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute9 ,l_lot_attribute_info.lot_c_attribute9) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute10', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute10,l_lot_attribute_info.lot_c_attribute10) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute11', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute11,l_lot_attribute_info.lot_c_attribute11) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute12', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute12,l_lot_attribute_info.lot_c_attribute12) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute13', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute13,l_lot_attribute_info.lot_c_attribute13) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute14', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute14,l_lot_attribute_info.lot_c_attribute14) || VARIABLE_E;
      END IF;




      l_variable_name := get_variable_name('lot_c_attribute15', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute15,l_lot_attribute_info.lot_c_attribute15) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute16', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute16,l_lot_attribute_info.lot_c_attribute16) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute17', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute17,l_lot_attribute_info.lot_c_attribute17)|| VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute18', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute18,l_lot_attribute_info.lot_c_attribute18) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute19', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute19,l_lot_attribute_info.lot_c_attribute19) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_c_attribute20', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_c_attribute20, l_lot_attribute_info.lot_c_attribute20)|| VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_d_attribute1', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_d_attribute1,l_lot_attribute_info.lot_d_attribute1) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_d_attribute2', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_d_attribute2, l_lot_attribute_info.lot_d_attribute2)|| VARIABLE_E;
      END IF;


      l_variable_name := get_variable_name('lot_d_attribute3', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_d_attribute3,l_lot_attribute_info.lot_d_attribute3) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_d_attribute4', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_d_attribute4,l_lot_attribute_info.lot_d_attribute4)|| VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_d_attribute5', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_d_attribute5,l_lot_attribute_info.lot_d_attribute5) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_d_attribute6', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_d_attribute6,l_lot_attribute_info.lot_d_attribute6)|| VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_d_attribute7', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_d_attribute7,l_lot_attribute_info.lot_d_attribute7) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_d_attribute8', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_d_attribute8,l_lot_attribute_info.lot_d_attribute8) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_d_attribute9', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_d_attribute9,l_lot_attribute_info.lot_d_attribute9) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_d_attribute10', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_d_attribute10, l_lot_attribute_info.lot_d_attribute10)|| VARIABLE_E;
      END IF;


      l_variable_name := get_variable_name('lot_n_attribute1', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_n_attribute1,l_lot_attribute_info.lot_n_attribute1)|| VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_n_attribute2', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_n_attribute2,l_lot_attribute_info.lot_n_attribute2) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_n_attribute3', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_n_attribute3 ,l_lot_attribute_info.lot_n_attribute3)|| VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_n_attribute4', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_n_attribute4,l_lot_attribute_info.lot_n_attribute4) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_n_attribute5', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_n_attribute5,l_lot_attribute_info.lot_n_attribute5) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_n_attribute6', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_n_attribute6,l_lot_attribute_info.lot_n_attribute6) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_n_attribute7', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_n_attribute7,l_lot_attribute_info.lot_n_attribute7) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_n_attribute8', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_n_attribute8,l_lot_attribute_info.lot_n_attribute8) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_n_attribute9', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_n_attribute9,l_lot_attribute_info.lot_n_attribute9) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_n_attribute10', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B || l_variable_name || '">' || nvl(l_item_info.lot_n_attribute10, l_lot_attribute_info.lot_n_attribute10)|| VARIABLE_E;
      END IF;




      l_variable_name := get_variable_name('lot_country_of_origin', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_country_of_origin,l_lot_attribute_info.lot_country_of_origin) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_grade_code', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_grade_code,l_lot_attribute_info.lot_grade_code) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_origination_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_origination_date,l_lot_attribute_info.lot_origination_date) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_date_code', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_date_code,l_lot_attribute_info.lot_date_code) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_change_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_change_date,l_lot_attribute_info.lot_change_date) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_age', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_age,l_lot_attribute_info.lot_age) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_retest_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_retest_date,l_lot_attribute_info.lot_retest_date) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_maturity_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_maturity_date,l_lot_attribute_info.lot_maturity_date)  || VARIABLE_E;
      END IF;


      /******* start of invconv changes ***********/


        IF (l_debug = 1) THEN
         trace(' invconv setting OPM attributes .. ');
        END IF;

       l_variable_name := get_variable_name('parent_lot_number', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_variable_name || '">' || nvl(l_item_info.parent_lot_number,l_lot_attribute_info.parent_lot_number) || VARIABLE_E;
        END IF;


       l_variable_name := get_variable_name('hold_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_variable_name || '">' || nvl(l_item_info.hold_date,l_lot_attribute_info.hold_date) || VARIABLE_E;
        END IF;

       l_variable_name := get_variable_name('expiration_action_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_variable_name || '">' || nvl(l_item_info.expiration_action_date,l_lot_attribute_info.expiration_action_date) || VARIABLE_E;
      END IF;

       l_variable_name := get_variable_name('expiration_action_code', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_variable_name || '">' || nvl(l_item_info.expiration_action_code,l_lot_attribute_info.expiration_action_code) || VARIABLE_E;
        END IF;


	 /*8886501 */
       l_variable_name := get_variable_name('origination_type', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_variable_name || '">' || l_origination_type || VARIABLE_E;
      END IF;



     l_variable_name := get_variable_name('supplier_lot_number', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_variable_name || '">'|| nvl(l_item_info.supplier_lot_number,l_lot_attribute_info.supplier_lot_number)|| VARIABLE_E;
      END IF;


                                      /*8886501*/

       l_variable_name := get_variable_name('secondary_transaction_quantity', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_variable_name || '">' || v_lpn_content.secondary_quantity || VARIABLE_E;
      END IF;

       l_variable_name := get_variable_name('secondary_uom_code', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
           l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_variable_name || '">' || v_lpn_content.secondary_uom || VARIABLE_E;
      END IF;


  /******* end invconv changes ***************/


      l_variable_name := get_variable_name('lot_item_size', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_item_size,l_lot_attribute_info.lot_item_size) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_color', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_color,l_lot_attribute_info.lot_color) || VARIABLE_E;
	END IF;


      l_variable_name := get_variable_name('lot_volume', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_volume,l_lot_attribute_info.lot_volume)|| VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_place_of_origin', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_place_of_origin,l_lot_attribute_info.lot_place_of_origin) || VARIABLE_E;
      END IF;

      l_variable_name := get_variable_name('lot_best_by_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_best_by_date, l_lot_attribute_info.lot_best_by_date)|| VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_length', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_length,l_lot_attribute_info.lot_length) || VARIABLE_E;
      END IF;


      l_variable_name := get_variable_name('lot_length_uom', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_length_uom,l_lot_attribute_info.lot_length_uom) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_recycled_cont', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_recycled_cont,l_lot_attribute_info.lot_recycled_cont)|| VARIABLE_E;
      END IF;


      l_variable_name := get_variable_name('lot_thickness', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_thickness, l_lot_attribute_info.lot_thickness)|| VARIABLE_E;
      END IF;

      l_variable_name := get_variable_name('lot_thickness_uom', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_thickness_uom,l_lot_attribute_info.lot_thickness_uom)|| VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_width', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_width,l_lot_attribute_info.lot_width) || VARIABLE_E;
	END IF;


      l_variable_name := get_variable_name('lot_width_uom', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_width_uom,l_lot_attribute_info.lot_width_uom) || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('lot_curl', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || nvl(l_item_info.lot_curl,l_lot_attribute_info.lot_curl) || VARIABLE_E;
      END IF;


      l_variable_name := get_variable_name('lot_vendor', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
	   l_variable_name || '">' || nvl(l_item_info.lot_vendor,l_lot_attribute_info.lot_vendor)||VARIABLE_E;

      END IF;


/*8886501*/


      l_variable_name := get_variable_name('parent_lpn', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.parent_lpn || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('parent_package_id', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_parent_package_id || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('pack_level', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_pack_level || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('outermost_lpn', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_lpn_info.outermost_lpn || VARIABLE_E;
      END IF;

      --
      l_variable_name := get_variable_name('receipt_num', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
       if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
           l_content_item_data := l_content_item_data || VARIABLE_B ||l_variable_name
             || '">' || l_rcv_lpn_table(l_lpn_table_index).receipt_num || VARIABLE_E;
       else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
            l_variable_name || '">' || l_receipt_number || VARIABLE_E;
        end if;
      END IF;
      l_variable_name := get_variable_name('po_line_num', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
        if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
          l_content_item_data := l_content_item_data || VARIABLE_B || l_variable_name
           || '">' ||l_rcv_lpn_table(l_lpn_table_index).po_line_num || VARIABLE_E;
       else
          l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_variable_name || '">' || l_po_line_number || VARIABLE_E;
        end if;
      END IF;
      l_variable_name := get_variable_name('quan_ordered', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
       if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
          l_content_item_data := l_content_item_data || VARIABLE_B||l_variable_name
           || '">' ||l_rcv_lpn_table(l_lpn_table_index).quantity_ordered|| VARIABLE_E;
       else
          l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_variable_name || '">' || l_quantity_ordered || VARIABLE_E;
        end if;
      END IF;
      l_variable_name := get_variable_name('supp_part_num', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
        if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
          l_content_item_data := l_content_item_data || VARIABLE_B||l_variable_name
           || '">' ||l_rcv_lpn_table(l_lpn_table_index).supplier_part_number|| VARIABLE_E;
       else
         l_content_item_data := l_content_item_data || VARIABLE_B ||
          l_variable_name || '">' || l_supplier_part_number || VARIABLE_E;
       end if;
      END IF;
      l_variable_name := get_variable_name('supp_name', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
        if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
          l_content_item_data := l_content_item_data || VARIABLE_B||l_variable_name
           || '">' ||l_rcv_lpn_table(l_lpn_table_index).supplier_name|| VARIABLE_E;
        else
          l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_variable_name || '">' || l_supplier_name || VARIABLE_E;
       end if;
      END IF;
      l_variable_name := get_variable_name('supp_site', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
        if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
          l_content_item_data := l_content_item_data || VARIABLE_B||l_variable_name
           || '">' ||l_rcv_lpn_table(l_lpn_table_index).supplier_site|| VARIABLE_E;
       else
          l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_variable_name || '">' || l_supplier_site || VARIABLE_E;
       end if;
      END IF;
      l_variable_name := get_variable_name('requestor', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
        if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
          l_content_item_data := l_content_item_data || VARIABLE_B||l_variable_name
           || '">' ||l_rcv_lpn_table(l_lpn_table_index).requestor|| VARIABLE_E;
       else
          l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_variable_name || '">' || l_requestor || VARIABLE_E;
       end if;
      END IF;
      l_variable_name := get_variable_name('deliver_to_loc', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
        if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
          l_content_item_data := l_content_item_data || VARIABLE_B||l_variable_name
           || '">' ||l_rcv_lpn_table(l_lpn_table_index).deliver_to_location|| VARIABLE_E;
       else
          l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_variable_name || '">' || l_deliver_to_location || VARIABLE_E;
       end if;
      END IF;
      l_variable_name := get_variable_name('loc_id', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
        if ( l_rlpn_ndx <> 0 ) then  -- :J-DEV
          l_content_item_data := l_content_item_data || VARIABLE_B||l_variable_name
           || '">' ||l_rcv_lpn_table(l_lpn_table_index).location|| VARIABLE_E;
       else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
            l_variable_name || '">' || l_location_code || VARIABLE_E;
        end if;
      END IF;
      l_variable_name := get_variable_name('note_to_receiver', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
        if ( l_rlpn_ndx <> 0 ) then -- :J-DEV
          l_content_item_data := l_content_item_data || VARIABLE_B||l_variable_name
           || '">' ||l_rcv_lpn_table(l_lpn_table_index).note_to_receiver|| VARIABLE_E;
       else
          l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_variable_name || '">' || l_note_to_receiver || VARIABLE_E;
       end if;
      END IF;
      l_variable_name := get_variable_name('gtin', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_gtin || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('gtin_description', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_gtin_desc || VARIABLE_E;
      END IF;

      -- New fields for iSP : Line-level
      l_variable_name := get_variable_name('comments_line', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
        if ( l_rlpn_ndx <> 0 ) then
          l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).comments || VARIABLE_E;
        else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
             l_variable_name || '">' || VARIABLE_E;
        end if;
      END IF;
      -- New fields for iSP : Line-level
      l_variable_name := get_variable_name('packing_slip_line', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
        if ( l_rlpn_ndx <> 0 ) then
          l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).packing_slip || VARIABLE_E;
        else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
             l_variable_name || '">' || VARIABLE_E;
        end if;
      END IF;

      l_variable_name := get_variable_name('shipment_due_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
        if ( l_rlpn_ndx <> 0 ) then
          l_content_item_data := l_content_item_data || VARIABLE_B ||
           l_variable_name || '">' || l_rcv_lpn_table(l_lpn_table_index).due_date || VARIABLE_E;
        else
           l_content_item_data := l_content_item_data || VARIABLE_B ||
             l_variable_name || '">' || VARIABLE_E;
        end if;
      END IF;

      -- New fields for iSP : Header-level
      l_variable_name := get_variable_name('asn_number', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.asn_num || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('shipment_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.shipment_date || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('expct_rcpt_date', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.expected_receipt_date || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('freight_terms', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.freight_terms || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('freight_carrier', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.freight_carrier || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('num_of_containers', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.num_of_containers || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('bill_of_lading', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.bill_of_lading || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('waybill_airbill_num', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.waybill_airbill_num || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('packing_slip_header', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.packing_slip || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('comments_header', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.comments || VARIABLE_E;
      END IF;
      --lpn status project start
       l_variable_name := get_variable_name('material_status', row_index_per_label-1, l_label_format_id);
         IF l_variable_name IS NOT NULL THEN
         l_content_item_data := l_content_item_data || VARIABLE_B ||
         l_variable_name || '">' || l_material_status_code || VARIABLE_E;

      END IF;
      --lpn status project end
      l_variable_name := get_variable_name('packaging_code', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.packaging_code || VARIABLE_E;
      END IF;
      l_variable_name := get_variable_name('special_handling_code', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN -- :J-DEV
         l_content_item_data := l_content_item_data || VARIABLE_B ||
        l_variable_name || '">' || l_rcv_isp_header.special_handling_code || VARIABLE_E;
      END IF;

          -- Added for 11.5.10+ RFID Compliance project
          -- New field : EPC
          -- EPC is generated once for each LPN
      l_variable_name := get_variable_name('epc', row_index_per_label-1, l_label_format_id);
      IF l_variable_name IS NOT NULL THEN
          l_content_item_data  :=    l_content_item_data || variable_b ||
          l_variable_name || '">' || l_epc || variable_e;
          l_label_err_msg := l_epc_ret_msg;
          IF l_epc_ret_status = 'U' THEN
                  l_label_status := INV_LABEL.G_ERROR;
          ELSIF l_epc_ret_status = 'E' THEN
                  l_label_status := INV_LABEL.G_WARNING;
          END IF;

      END IF;

      --Bug 4891916. Added for the field Cycle Count Name
           l_variable_name      := get_variable_name('cycle_count_name', row_index_per_label - 1, l_label_format_id);

           IF l_variable_name IS NOT NULL THEN
             l_content_item_data  := l_content_item_data || variable_b || l_variable_name || '">' || l_cycle_count_name || variable_e;
           END IF;

      --End of fix for Bug 4891916

      IF row_index_per_label = no_of_rows_per_label THEN
    -- Finished
    l_content_item_data := l_content_item_data || LABEL_E;
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


    l_custom_sql_ret_status  := NULL;
    l_custom_sql_ret_msg     := NULL;
   ------------------------End of this changes for Custom Labels project code---------------

    l_content_item_data := '';
    l_label_index := l_label_index +1;
    new_label := true;
      END IF;


      IF (l_debug = 1) THEN
         trace('  Finished writing item variables ');
      END IF;

      <<nextlabel>>  --Added in R12

      -- Bug 4137707: performance of printing at cartonization
      -- Replaced the FOR LOOP
      -- Need to fetch record again for cartonization or non-cartonization flow
      IF cartonization_flag = 0 THEN
        -- non cartonization flow
        FETCH c_lpn_item_content INTO v_lpn_content;
        IF c_lpn_item_content%NOTFOUND THEN
            IF (l_debug = 1) THEN
               trace('No record found for c_lpn_item_content');
               --Moved the following 2 statements outside the if block.
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
               --Moved the following 2 statements outside the if block.
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


    END LOOP; --  v_lpn_content IN c_lpn_item_content



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
      FETCH c_mmtt_cart_lpn INTO l_lpn_id, l_package_id, l_content_volume_uom_code, l_content_volume,
            l_gross_weight_uom_code, l_gross_weight, l_inventory_item_id, l_parent_package_id, l_pack_level,
            l_parent_lpn_id, l_header_id, l_packaging_mode;
      IF c_mmtt_cart_lpn%NOTFOUND THEN
        IF (l_debug = 1) THEN
           trace(' Finished getting containers ' );
        END IF;
        CLOSE c_mmtt_cart_lpn;
        l_lpn_id := null;
        l_package_id := null;
      ELSE
        IF (l_debug = 1) THEN
           trace(' Found another container lpn_id=' || l_lpn_id || 'package_id=' || l_package_id);
        END IF;
        new_label := true;
        l_content_rec_index := 0;
      END IF;
    ELSIF p_label_type_info.business_flow_code = 29 THEN

             FETCH c_mmtt_wip_pick_drop_lpn INTO l_lpn_id, p_organization_id,
                  p_inventory_item_id, p_lot_number,
                  p_revision, p_qty, p_uom,
                                l_subinventory_code, l_locator_id,
                         l_secondary_quantity, l_secondary_uom; -- invconv changes
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
      INTO   l_lpn_id, p_organization_id,
        p_inventory_item_id, p_lot_number, p_revision,
                                p_qty, p_uom,l_subinventory_code, l_locator_id, l_printer_sub,
                             l_secondary_quantity, -- invconv changes
                          l_secondary_uom; -- invconv changes

        IF c_mmtt_lpn_pick_load%NOTFOUND THEN
          CLOSE c_mmtt_lpn_pick_load;
          l_lpn_id := null;
        ELSE
          IF (l_debug = 1) THEN
             trace(' Found another lot ' || p_lot_number);
          END IF;
        END IF;

    ELSE
      -- For RCV flows, check if called based on new Architecture
      -- If new architecture, then index corresponding to new RCV_LPN
      -- table of records would be greater than 0
      IF (l_debug = 1) THEN
         trace(' for-end: lpn_id='||l_lpn_id||'item='||l_cur_item_id||'ndx='||l_lpn_table_index||'count='||l_rcv_lpn_table.count);
      END IF;

      if l_rlpn_ndx > 0 then -- :J-DEV
       if (l_lpn_table_index < l_rcv_lpn_table.count) then
         l_lpn_table_index := l_lpn_table_index +1;
         l_lpn_id := l_rcv_lpn_table(l_lpn_table_index).lpn_id;
         l_cur_item_id := l_rcv_lpn_table(l_lpn_table_index).item_id;
            new_label := true; -- Bug 3841820, start a new label if found a new lpn
       else
          l_lpn_id := null;
       end if;
      else
        IF l_lpn_table_index < l_lpn_table.count THEN
          l_lpn_table_index := l_lpn_table_index +1;
          l_lpn_id := l_lpn_table(l_lpn_table_index);
            new_label := true; -- Bug 3841820, start a new label if found a new lpn
        ELSE
          l_lpn_id := null;
        END IF;
      end if;
    END IF;

    IF ((row_index_per_label < no_of_rows_per_label) AND (new_label=TRUE)
        AND (l_label_format_id IS NOT NULL)) THEN
      -- Label is partial, write null to the rest of the variables.
      -- First, get max number of rows defined.
      -- It might be greater than the actual number of rows per label
      -- For example, the user setup as
      -- _ITEM1, _ITEM2   and  _QTY1, _QTY2, _QTY3
      -- Then the number of rows per label is 2 and max_no_of_rows_defined is 3.
      max_no_of_rows_defined := 0;

      BEGIN
        select max(table_a.c) into max_no_of_rows_defined
        from (select wlfv.label_field_id,
          wlf.column_name, count(*) c
          from wms_label_field_variables wlfv, wms_label_fields_vl wlf
          where wlfv.label_field_id = wlf.label_field_id
          and wlfv.label_format_id = l_label_format_id
            group by wlfv.label_field_id, wlf.column_name) table_a;
      EXCEPTION
        WHEN no_data_found THEN
          IF (l_debug = 1) THEN
             trace(' Error in finding max_no_of_rows_defined');
          END IF;
      END;
      IF (l_debug = 1) THEN
         trace(' Max number of rows defined = '|| max_no_of_rows_defined);
      END IF;

      -- Loop for the rest of the rows that don't have value,
      -- we need to pass null.
      FOR i IN (row_index_per_label+1)..max_no_of_rows_defined LOOP
        FOR j IN 1..l_selected_fields.count LOOP
          IF j=1 OR l_selected_fields(j).column_name <>
            l_selected_fields(j-1).column_name THEN
            l_variable_name := get_variable_name(l_selected_fields(j).column_name,
                i-1, l_label_format_id);
            IF l_variable_name IS NOT NULL THEN
              IF (l_debug = 1) THEN
                 trace(' Found extra row to pass null=> '|| l_variable_name);
              END IF;
                 l_content_item_data := l_content_item_data || VARIABLE_B ||
              l_variable_name || '">' ||'' || VARIABLE_E;
            END IF;
          END IF;
        END LOOP;
      END LOOP;  -- while l_lpn_id IS NOT NULL OR ..
      l_content_item_data := l_content_item_data || LABEL_E;
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

      l_content_item_data := '';
      l_label_index := l_label_index + 1;
    END IF;
  END LOOP;
  IF (l_debug = 1) THEN
     trace('End of loop with lpn_id=' || l_lpn_id || 'package_id=' || l_package_id);
  END IF;

  IF ((row_index_per_label < no_of_rows_per_label) AND (new_label=FALSE)
      AND (l_label_format_id IS NOT NULL)) THEN
    -- Last label is partial, write null to the rest of the variables.
    -- First, get max number of rows defined.
    -- It might be greater than the actual number of rows per label
    -- For example, the user setup as
    -- _ITEM1, _ITEM2   and  _QTY1, _QTY2, _QTY3
    -- Then the number of rows per label is 2 and max_no_of_rows_defined is 3.
    max_no_of_rows_defined := 0;

    BEGIN
      select max(table_a.c) into max_no_of_rows_defined
      from (select wlfv.label_field_id,
        wlf.column_name, count(*) c
        from wms_label_field_variables wlfv, wms_label_fields_vl wlf
        where wlfv.label_field_id = wlf.label_field_id
        and wlfv.label_format_id = l_label_format_id
          group by wlfv.label_field_id, wlf.column_name) table_a;
    EXCEPTION
      WHEN no_data_found THEN
        IF (l_debug = 1) THEN
           trace(' Error in finding max_no_of_rows_defined');
        END IF;
    END;
    IF (l_debug = 1) THEN
       trace(' Max number of rows defined = '|| max_no_of_rows_defined);
    END IF;

    -- Loop for the rest of the rows that don't have value,
    -- we need to pass null.
    FOR i IN (row_index_per_label+1)..max_no_of_rows_defined LOOP
      FOR j IN 1..l_selected_fields.count LOOP
        IF j=1 OR l_selected_fields(j).column_name <>
          l_selected_fields(j-1).column_name THEN
          l_variable_name := get_variable_name(l_selected_fields(j).column_name,
              i-1, l_label_format_id);
          IF l_variable_name IS NOT NULL THEN
            IF (l_debug = 1) THEN
               trace(' Found extra row to pass null=> '|| l_variable_name);
            END IF;
               l_content_item_data := l_content_item_data || VARIABLE_B ||
            l_variable_name || '">' ||'' || VARIABLE_E;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
    l_content_item_data := l_content_item_data || LABEL_E;
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
    l_content_item_data := '';
    l_label_index := l_label_index + 1;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     trace(' Error Code, Error Message...' || sqlerrm(sqlcode));
END get_variable_data;





FUNCTION get_variable_name(p_column_name IN VARCHAR2, p_row_index IN NUMBER, p_format_id IN NUMBER)
RETURN VARCHAR2
IS

lv_variable_name VARCHAR2(100);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  BEGIN
     lv_variable_name := g_field_elements_table(get_field_hash_value(p_column_name||(p_row_index+1), g_get_hash_for_retrieve)).variable_name;
  EXCEPTION
    WHEN OTHERS THEN
      lv_variable_name := NULL;
  END;
  --IF l_variable_name is not null THEN
  --  trace('get variable name '||l_variable_name||' for column '|| p_column_name);
  --END IF;

  RETURN lv_variable_name;

END get_variable_name;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  This function get_sql_for_variable() is newly added for the Custom Labels project to     |
--  fetch the SQL statement from the PL/SQL table.                                           |
---------------------------------------------------------------------------------------------
FUNCTION get_sql_for_variable(p_column_name IN VARCHAR2, p_row_index IN NUMBER, p_format_id IN NUMBER)
RETURN VARCHAR2
IS

lv_sql_stmt VARCHAR2(4000);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  BEGIN
     lv_sql_stmt := g_field_elements_table(get_field_hash_value(p_column_name||(p_row_index+1), g_get_hash_for_retrieve)).sql_stmt;
     IF (l_debug = 1) THEN
      trace(' Inside get_sql_for_variable() lv_sql_stmt is: '|| lv_sql_stmt);
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
      lv_sql_stmt := NULL;
      IF (l_debug = 1) THEN
         trace(' Inside Exception Block of get_sql_for_variable() ');
      END IF;
  END;
  RETURN lv_sql_stmt;

END get_sql_for_variable;

------------------------End of this change for Custom Labels project code--------------------

PROCEDURE get_variable_data(
   x_variable_content   OUT NOCOPY LONG
,  x_msg_count    OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  p_label_type_info IN INV_LABEL.label_type_rec
,  p_transaction_id  IN NUMBER
,  p_input_param     IN MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
,  p_lpn_id       IN NUMBER
,  p_transaction_identifier IN NUMBER
) IS
   l_variable_data_tbl INV_LABEL.label_tbl_type;
BEGIN
   get_variable_data(
      x_variable_content   => l_variable_data_tbl
   ,  x_msg_count    => x_msg_count
   ,  x_msg_data           => x_msg_data
   ,  x_return_status      => x_return_status
   ,  p_label_type_info => p_label_type_info
   ,  p_transaction_id  => p_transaction_id
   ,  p_input_param     => p_input_param
  ,  p_lpn_id        => p_lpn_id
   ,  p_transaction_identifier=> p_transaction_identifier
   );

   x_variable_content := '';

   FOR i IN 1..l_variable_data_tbl.count() LOOP
      x_variable_content := x_variable_content || l_variable_data_tbl(i).label_content;
   END LOOP;

END get_variable_data;

END INV_LABEL_PVT5;

/
