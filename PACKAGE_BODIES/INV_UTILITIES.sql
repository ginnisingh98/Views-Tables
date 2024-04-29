--------------------------------------------------------
--  DDL for Package Body INV_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_UTILITIES" AS
  /* $Header: INVUTILB.pls 120.6.12010000.14 2013/01/29 18:47:03 avrose ship $ */
  PROCEDURE do_sql(p_sql_stmt IN VARCHAR2) IS
    cursor_id  INTEGER;
    return_val INTEGER;
    sql_stmt   VARCHAR2(8192);
    l_debug    NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- set sql statement
    sql_stmt    := p_sql_stmt;
    -- open a cursor
    cursor_id   := DBMS_SQL.open_cursor;
    -- parse sql statement
    DBMS_SQL.parse(cursor_id, sql_stmt, DBMS_SQL.v7);
    -- execute statement
    return_val  := DBMS_SQL.EXECUTE(cursor_id);
    -- close cursor
    DBMS_SQL.close_cursor(cursor_id);
  END do_sql;

 /*********************************** DEPRECATED *************************************
  *********************************** DEPRECATED *************************************
  *********************************** DEPRECATED *************************************
  * Procedure OBSOLETED. Use INV_PICK_SLIP_REPORT.RUN_DETAIL_ENGINE for Future use.  *
  *                THIS PROCEDURE WILL NOT BE SUPPORTED ANY MORE                     *
  *********************************** DEPRECATED *************************************
  *********************************** DEPRECATED *************************************
  *********************************** DEPRECATED *************************************/
  --Added NOCOPY hint to p_detail_status OUT parameter
  --to comply with GSCC File.Sql.39 standard Bug:4410848
  PROCEDURE run_detail_engine(
    p_detail_status           OUT NOCOPY   VARCHAR2
  , p_org_id                  IN           NUMBER
  , p_move_order_type         IN           NUMBER
  , p_transfer_order          IN           VARCHAR2
  , p_source_subinv           IN           VARCHAR2
  , p_source_locid            IN           NUMBER
  , p_dest_subinv             IN           VARCHAR2
  , p_dest_locid              IN           NUMBER
  , p_requested_by            IN           NUMBER
  , p_plan_tasks              IN           BOOLEAN
  , p_pick_slip_group_rule_id IN           NUMBER
  ) IS
    v_line_id                NUMBER         := 0;
    v_num_of_rows            NUMBER         := 0;
    v_detailed_qty           NUMBER         := 0;
    v_secondary_detailed_qty NUMBER         := NULL;   --INVCONV
    v_return_status          VARCHAR2(10);
    v_msg                    VARCHAR2(2000);
    v_count                  NUMBER;
    v_rev                    VARCHAR2(100)  := NULL;
    v_from_loc_id            NUMBER         := 0;
    v_to_loc_id              NUMBER         := 0;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    v_lot_number             VARCHAR2(80);
    v_expiration_date        DATE;
    v_transaction_temp_id    NUMBER;
    v_header_id              NUMBER;
    l_serial_flag            VARCHAR2(1)    := 'F';
    serial_control_code      NUMBER;
    v_inventory_item_id      NUMBER;
    l_move_order_type        NUMBER;
    l_max_batch              NUMBER;
    l_batch_size             NUMBER;
    /* FP-J PAR Replenishment Count: 3 new variables declared */
    v_pick_slip_no           NUMBER;
    v_err_msg                VARCHAR2(1000);
    mtrh_header_change_track NUMBER         := 0;
    l_req_msg                VARCHAR2(30)   := NULL;
    /* Tracking variable to check the change in the header_id from the set of mtrls
       fetched. If header_id changes, then update GROUPING_RULE_ID for the header
       and continue the FOR loop until header_id changes again.  */

    /* Bug #2060360
     * Added NVL for from_subinventory_code to allocate lines
     * where from sub is not specified.
    */
    --bug 2307649
    --type codes have changed, so we need to handle situation
    -- where p_move_order_type = 99 (all lines)

    -- kkoothan Bug Fix:2352405
    -- Added one more column to_account_id
    -- in the cursor below which is later used to update
    -- the distribution_account_id of MMTT

    /* Restructured the Following Cursor SQL as part of
           Performance Fix: 2853526.
           Removed NVLs around from and to Subinventory Codes and
           used base tables mtl_txn_request_headers and
           mtl_txn_request_lines instead of the View mtl_txn_request_lines_v*/
    /* FP-J PAR Replenishment Counts: Introduced 3 more columns to be fetched
       viz., header_id, project_id and task_id. Also, the cursor is now ordered by
       mtrl.header_id so that update of GROUPING_RULE_ID of mtrh (for header_id) is
       done efficiently knowing the fact that the cursor may fetch multiple lines
       from same header and across headers. column header_id is used to update GROUPINNG_RULE_ID
       of MTRH, project_id and task_id are used as input parameters for the new call
       INV_PR_PICK_SLIP_NUMBER.GET_PICK_SLIP_NUMBER() to generate the pick slip number.*/
    CURSOR c_move_order_lines IS
      SELECT   mtrl.line_id
             , mtrl.inventory_item_id
             , mtrh.move_order_type
             , mtrl.to_account_id
             , mtrl.header_id
             , mtrl.project_id
             , mtrl.task_id
          FROM mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh
         WHERE mtrl.line_status IN(3, 7)
           AND mtrl.header_id = mtrh.header_id
           AND mtrl.organization_id = p_org_id
           AND(
               (p_move_order_type IN(1, 2)
                AND mtrh.move_order_type = p_move_order_type)
               OR(p_move_order_type = 99
                  AND mtrh.move_order_type IN(1, 2))
              )
           AND mtrl.quantity > NVL(mtrl.quantity_detailed, 0)
           AND mtrh.request_number = NVL(p_transfer_order, mtrh.request_number)
           AND mtrl.created_by = NVL(p_requested_by, mtrl.created_by)
           AND(p_source_subinv IS NULL
               OR mtrl.from_subinventory_code = p_source_subinv)
           AND(p_dest_subinv IS NULL
               OR mtrl.to_subinventory_code = p_dest_subinv)
      ORDER BY mtrl.header_id;

    CURSOR c_mmtt IS
      SELECT transaction_temp_id
           , subinventory_code
           , locator_id
           , transfer_subinventory
           , transfer_to_location
           , revision
        FROM mtl_material_transactions_temp
       WHERE move_order_line_id = v_line_id
         AND pick_slip_number IS NULL;

    l_debug                  NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF p_org_id IS NULL
       OR p_move_order_type IS NULL THEN
      RETURN;
    END IF;

    --only allocate requisition and replenishment move orders
    --99 is "All"
    IF p_move_order_type NOT IN(1, 2, 99) THEN
      RETURN;
    END IF;

    l_max_batch   := TO_NUMBER(fnd_profile.VALUE('INV_PICK_SLIP_BATCH_SIZE'));

    IF (l_debug = 1) THEN
      inv_log_util.TRACE('max batch: ' || l_max_batch, 'INV_UTILITIES', 9);
    END IF;

    IF l_max_batch IS NULL
       OR l_max_batch <= 0 THEN
      l_max_batch  := 20;

      IF (l_debug = 1) THEN
        inv_log_util.TRACE('using default batch size', 'INV_UTILITIES', 9);
      END IF;
    END IF;

    l_batch_size  := 0;

    IF (l_debug = 1) THEN
      inv_log_util.TRACE('Pick Slip Grouping Rule Id ' || TO_CHAR(p_pick_slip_group_rule_id), 'INV_UTILITIES', 9);
    END IF;

    --device integration starts
    IF (inv_install.adv_inv_installed(p_org_id) = TRUE) THEN --for WMS org
       IF wms_device_integration_pvt.wms_call_device_request IS NULL THEN
	  wms_device_integration_pvt.is_device_set_up(p_org_id,wms_device_integration_pvt.WMS_BE_MO_TASK_ALLOC,v_return_status);
       END IF;
    END IF;
    --device integration end


    FOR move_ord_rec IN c_move_order_lines LOOP
       l_batch_size       := l_batch_size + 1;
       v_line_id          := move_ord_rec.line_id;
       l_move_order_type  := move_ord_rec.move_order_type;

       /* FP-J PAR Replenishment Count: Code block to update GROUPING_RULE_ID of mtrh
         only once per header_id change in the set of mtrls fetched in the cursor.
         This approach works because cursor is ordered by mtrl.header_id.
         Implied inline branching between I and J here is to check whether
         p_pick_slip_group_rule_id IS NULL or not. In FP-I, concurrent program
         cannot pass p_pick_slip_group_rule_id(hence default NULL). */
      IF move_ord_rec.header_id <> mtrh_header_change_track
         AND p_pick_slip_group_rule_id IS NOT NULL THEN
        mtrh_header_change_track  := move_ord_rec.header_id;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Updating MTRH Id ' || TO_CHAR(mtrh_header_change_track), 'INV_UTILITIES', 9);
        END IF;

        UPDATE mtl_txn_request_headers
           SET grouping_rule_id = p_pick_slip_group_rule_id
         WHERE header_id = move_ord_rec.header_id;

        -- Flushing out the Cached Pick Slip Numbers.
        inv_pr_pick_slip_number.delete_wip_ps_tbl;
      END IF;

      SELECT serial_number_control_code
        INTO serial_control_code
        FROM mtl_system_items
       WHERE inventory_item_id = move_ord_rec.inventory_item_id
         AND organization_id = p_org_id;

      IF serial_control_code <> 1 THEN
        l_serial_flag  := 'T';
      END IF;

      SELECT mtl_material_transactions_s.NEXTVAL
        INTO v_header_id
        FROM DUAL;

      inv_replenish_detail_pub.line_details_pub(
        p_line_id                    => v_line_id
      , x_number_of_rows             => v_num_of_rows
      , x_detailed_qty               => v_detailed_qty
      , x_detailed_qty2              => v_secondary_detailed_qty  --INVCONV
      , x_return_status              => v_return_status
      , x_msg_count                  => v_count
      , x_msg_data                   => v_msg
      , x_revision                   => v_rev
      , x_locator_id                 => v_from_loc_id
      , x_transfer_to_location       => v_to_loc_id
      , x_lot_number                 => v_lot_number
      , x_expiration_date            => v_expiration_date
      , x_transaction_temp_id        => v_transaction_temp_id
      , p_transaction_header_id      => v_header_id
      , p_transaction_mode           => NULL
      , p_move_order_type            => l_move_order_type
      , p_serial_flag                => l_serial_flag
      , p_plan_tasks                 => p_plan_tasks
      );

      --INVCONV  Added secondary qty
      UPDATE mtl_txn_request_lines
         SET quantity_detailed = (nvl(quantity_delivered,0) + v_detailed_qty) -- against bug : 4155230
            ,secondary_quantity_detailed = DECODE(v_secondary_detailed_qty,0,NULL,v_secondary_detailed_qty)
       WHERE line_id = v_line_id
         AND organization_id = p_org_id;

      /* FP-J PAR Replenishment Counts: Implied inline branching b/w I and J is to check
         if p_pick_slip_group_rule_id is NULL or not. In FP-I, concurrent program cannot pass
         p_pick_slip_group_rule_id (hence default null) */
      IF p_pick_slip_group_rule_id IS NOT NULL THEN
        -- Looping for each allocation of the MO Line for which Pick Slip Number is not stamped.
        FOR v_mmtt IN c_mmtt LOOP
          inv_pr_pick_slip_number.get_pick_slip_number(
            p_pick_grouping_rule_id      => p_pick_slip_group_rule_id
          , p_org_id                     => p_org_id
          , p_wip_entity_id              => NULL
          , p_rep_schedule_id            => NULL
          , p_operation_seq_num          => NULL
          , p_dept_id                    => NULL
          , p_push_or_pull               => NULL
          , p_supply_subinventory        => v_mmtt.transfer_subinventory
          , p_supply_locator_id          => v_mmtt.transfer_to_location
          , p_project_id                 => move_ord_rec.project_id
          , p_task_id                    => move_ord_rec.task_id
          , p_src_subinventory           => v_mmtt.subinventory_code
          , p_src_locator_id             => v_mmtt.locator_id
          , p_inventory_item_id          => move_ord_rec.inventory_item_id
          , p_revision                   => v_mmtt.revision
          , p_lot_number                 => NULL
          , x_pick_slip_number           => v_pick_slip_no
          , x_api_status                 => v_return_status
          , x_error_message              => v_err_msg
          );
          UPDATE mtl_material_transactions_temp
             SET pick_slip_number = v_pick_slip_no
           WHERE transaction_temp_id = v_mmtt.transaction_temp_id;
        END LOOP;
      END IF;

      -- kkoothan Bug Fix:2352405
      -- Update the distribution_account_id of MMTT
      -- from to_account_id of mtl_txn_request_lines_v
      -- since this was not done previously.After this fix,
      -- MOs allocated using MO Pick Slip Report too,
      -- along with manually allocated MO will populate
      -- the distribution_account_id of MMTT.
      IF move_ord_rec.to_account_id IS NOT NULL THEN
        UPDATE mtl_material_transactions_temp
           SET distribution_account_id = move_ord_rec.to_account_id
         WHERE move_order_line_id = v_line_id;
      END IF;

      IF l_batch_size >= l_max_batch THEN
        COMMIT;

        IF (l_debug = 1) THEN
          inv_log_util.TRACE('commit', 'INV_UTILITIES', 9);
        END IF;

        l_batch_size  := 0;
      END IF;
    END LOOP;

    -- Call Device Integration API to send the details of this
    -- PickRelease Wave to devices, if it is a WMS organization.
    -- Note: We don't check for the return condition of this API as
    -- we let the Move Order Allocation  process succeed
    -- irrespective of DeviceIntegration succeed or fail.
    if (WMS_INSTALL.check_install
	  (
	   x_return_status   => v_return_status,
	   x_msg_count       => v_count,
	   x_msg_data        => v_msg,
	   p_organization_id => p_org_id
	   ) = TRUE	) then
       WMS_DEVICE_INTEGRATION_PVT.device_request
	 (p_bus_event      => WMS_DEVICE_INTEGRATION_PVT.WMS_BE_MO_TASK_ALLOC,
	  p_call_ctx       => WMS_Device_integration_pvt.DEV_REQ_AUTO,
	  p_task_trx_id    => NULL,
	  x_request_msg    => l_req_msg,
	  x_return_status  => v_return_status,
	  x_msg_count      => v_count,
	  x_msg_data       => v_msg
	  );

       IF (l_debug = 1) THEN
          inv_log_util.TRACE('Device_API: return stat:'||v_return_status, 'INV_UTILITIES', 9);
       END IF;

    end if;



    COMMIT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_return_status  := 'E';
  END run_detail_engine;

  --Added NOCOPY hint to table_of_strings OUT parameter to comply
  --with GSCC File.Sql.39 standard .Bug:4410848
  PROCEDURE parse_vector(vector_in IN VARCHAR2, delimiter IN VARCHAR2, table_of_strings OUT NOCOPY vector_tabtype) IS
    delimiter_index NUMBER;
    string_in       VARCHAR2(32767);
    counter         NUMBER;
    l_debug         NUMBER          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    --parse the input vector of strings
    --by separating the strings that are delimitted by commas
    string_in                  := vector_in;
    delimiter_index            := INSTR(string_in, delimiter, 1);
    counter                    := 0;

    --dbms_output.put_line('string_in '||string_in);
    --dbms_output.put_line('delimiter '||delimiter);
    --dbms_output.put_line('index '||delimiter_index);
    WHILE delimiter_index > 0 LOOP
      table_of_strings(counter)  := SUBSTR(string_in, 1, delimiter_index - 1);
      string_in                  := SUBSTR(string_in, delimiter_index + 1);
      delimiter_index            := INSTR(string_in, delimiter, 1);
      counter                    := counter + 1;
    END LOOP;

    --add last element of string to table
    table_of_strings(counter)  := string_in;
  END parse_vector;

-- Bug 12746059: LC Calculation By Item Category
-- Function name   : get_LCMTrackingFlag
-- Type       : Group
-- Function   : Check whether a given item is trackable in LCM.
--              Returns 'N' if not trackable.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_inventory_item_id IN NUMBER
--              p_organization_id IN NUMBER
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION get_LCMTrackingFlag (p_inventory_item_id IN NUMBER,
                              p_organization_id IN NUMBER) RETURN VARCHAR2 IS

l_lcm_tracking_flag VARCHAR2(1);
l_prof_category_set_id NUMBER;
l_count_item_category_set NUMBER;

BEGIN

    l_prof_category_set_id := FND_PROFILE.VALUE('INL_ITEM_CATEGORY_SET');

    IF l_prof_category_set_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO l_count_item_category_set
        FROM mtl_item_categories
        WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id
        AND category_set_id = l_prof_category_set_id;

        IF NVL(l_count_item_category_set,0) > 0 THEN
            l_lcm_tracking_flag := 'Y';
        ELSE
            l_lcm_tracking_flag := 'N';
        END IF;
    ELSE
        l_lcm_tracking_flag := 'Y';
    END IF;

    RETURN l_lcm_tracking_flag;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N' ;
END get_LCMTrackingFlag;
-- End Bug 12746059: LC Calculation By Item Category

/*
 Added for bug No 7440217
 PO API for LCM
*/
FUNCTION inv_check_lcm(
         p_inventory_item_id IN NUMBER,
         p_ship_to_org_id IN NUMBER,
         p_consigned_flag IN VARCHAR2,
         p_outsource_assembly_flag IN VARCHAR2,
         p_vendor_id IN NUMBER,
         p_vendor_site_id IN NUMBER,
         p_po_line_location_id IN NUMBER   --Bug#10279800
 )
 RETURN VARCHAR2 IS
      v_stock_enabled_flag VARCHAR2(1);
      v_lcm_enabled_flag VARCHAR2(1);
	  v_inv_asset_flag VARCHAR2(1);
      v_vs_ou_id    NUMBER; -- bug 9767031
      v_org_ou_id  NUMBER;  -- bug 9767031
      v_drop_ship_flag VARCHAR2(1);    --Bug#10279800
      v_lcm_tracking_flag VARCHAR2(1) := 'N';  -- Bug 12746059: LC Calculation By Item Category

      --13825283
      v_all_expense_flag varchar2(1) := 'Y';

      --13927039
      v_emp_flag varchar2(1);

BEGIN
      IF    NVL(p_consigned_flag, 'N') = 'Y'
      OR    NVL(p_outsource_assembly_flag, 'N') = 'Y'
      OR    NVL(p_inventory_item_id, -9999) = -9999
      OR    NVL(p_ship_to_org_id,-9999) = -9999
      THEN
            RETURN 'N';
      ELSE
           SELECT NVL(LCM_ENABLED_FLAG, 'N')
           INTO   v_lcm_enabled_flag
           FROM   MTL_PARAMETERS
           WHERE  ORGANIZATION_ID = p_ship_to_org_id;

           IF  v_lcm_enabled_flag = 'N' THEN
               RETURN v_lcm_enabled_flag;
           END IF;
           /*Bug#10279800 Add to check drop_ship_flag, return 'N' if
             drop_ship_flag = 'Y'*/
           IF nvl(p_po_line_location_id,-1) <> -1 THEN
             SELECT NVL(DROP_SHIP_FLAG, 'N')
             INTO   v_drop_ship_flag
             FROM   PO_LINE_LOCATIONS_ALL
             WHERE  LINE_LOCATION_ID = p_po_line_location_id;

             IF v_drop_ship_flag = 'Y' THEN
               RETURN 'N';
             END IF;

             --13825283
             begin

                SELECT  'N' INTO v_all_expense_flag
                FROM    dual
                WHERE   EXISTS ( SELECT 1
                FROM    po_distributions_all pod
                WHERE   pod.destination_type_code <> 'EXPENSE'
                AND     pod.line_location_id = p_po_line_location_id);

             exception when others then
                if v_all_expense_flag = 'Y' then
                   return 'N';
                end if;
             end;


           END IF;
           /*Bug#10279800*/
           SELECT STOCK_ENABLED_FLAG,INVENTORY_ASSET_FLAG
           INTO   v_stock_enabled_flag,v_inv_asset_flag
           FROM   MTL_SYSTEM_ITEMS
           WHERE  INVENTORY_ITEM_ID = p_inventory_item_id
           AND    ORGANIZATION_ID = p_ship_to_org_id;




           --13927039 employee supplier return 'N'
           IF p_vendor_id IS NOT NULL
           THEN

               begin
               v_emp_flag := 'Y';
               SELECT 'N'
               INTO   v_emp_flag
               FROM   po_vendors
               WHERE  vendor_type_lookup_code = 'EMPLOYEE'
               AND    vendor_id = p_vendor_id;

               IF v_emp_flag = 'N' THEN
                  RETURN 'N';
               END IF;

               EXCEPTION WHEN OTHERS THEN
                  NULL;
               END;


           END IF;

           IF (NVL(v_stock_enabled_flag, 'N') = 'Y' and NVL(v_inv_asset_flag,'N') = 'Y')
           THEN
-- bug 9767031
            IF p_vendor_site_id IS NOT NULL THEN
           	  SELECT  nvl(ORG_ID,-1)
		      INTO    v_vs_ou_id
   		      FROM PO_VENDOR_SITES_ALL
		      WHERE VENDOR_SITE_ID = p_vendor_site_id;

 			  SELECT  To_number(hoi2.org_information3)
			  INTO v_org_ou_id
			  FROM  hr_organization_information hoi2
			  WHERE organization_id = p_ship_to_org_id
              AND ( hoi2.org_information_context || '' ) = 'Accounting Information';

              IF   v_vs_ou_id = v_org_ou_id THEN
				-- RETURN 'Y';             -- Bug 12746059: LC Calculation By Item Category
				v_lcm_enabled_flag := 'Y'; -- Bug 12746059: LC Calculation By Item Category
              ELSE
                RETURN 'N';
              END IF;
            ELSE
              -- RETURN 'Y';             -- Bug 12746059: LC Calculation By Item Category
	      v_lcm_enabled_flag := 'Y'; -- Bug 12746059: LC Calculation By Item Category
            END IF;
          ELSE
/* bug 9849579 fixed. Return 'N' if stockable_flag or inv_asset_flag is no */
              RETURN 'N';
          END IF;
        END IF;

	 -- Bug 12746059: LC Calculation By Item Category

	 IF (v_lcm_enabled_flag = 'Y') THEN

            v_lcm_tracking_flag := get_LCMTrackingFlag(
                                       p_inventory_item_id => p_inventory_item_id,
                                       p_organization_id => p_ship_to_org_id);

            IF (v_lcm_tracking_flag = 'Y') THEN
                RETURN 'Y';
            ELSE
                RETURN 'N';
            END IF;
        ELSE
            RETURN 'N';
        END IF;
        -- End Bug 12746059: LC Calculation By Item Category

   EXCEPTION
		WHEN OTHERS THEN
           RETURN 'N' ;
-- end of bug 9767031
END inv_check_lcm;
/*
 END for bug No 7440217
 PO API for LCM
*/



  FUNCTION get_conc_segments(x_org_id IN NUMBER, x_loc_id IN NUMBER)
    RETURN VARCHAR2 IS
    x_conc_segs        VARCHAR2(2000) := NULL;
    v_loc_str          VARCHAR2(2000) := NULL;
    v_proj_name        VARCHAR2(50)   := NULL;
    v_task_name        VARCHAR2(50)   := NULL;
    v_append           VARCHAR2(1000) := NULL;
    v_parse_str        VARCHAR2(3000) := NULL;
    v_num              NUMBER;
    v_cnt              NUMBER         := 0;
    v_proj_ref_enabled NUMBER         := NULL;
    v_flex_code        VARCHAR2(5)    := 'MTLL';
    v_flex_num         NUMBER;
    v_seg19_f          BOOLEAN        := FALSE;
    v_seg20_f          BOOLEAN        := FALSE;
    v_delim            VARCHAR2(1)    := NULL;
    dsql_cur           NUMBER;
    rows_processed     NUMBER;
    str1               VARCHAR2(15)   := NULL;
    d_data_str         VARCHAR2(1000) := NULL;

    CURSOR cur1(flex_code VARCHAR2) IS
      SELECT   a.application_column_name
          FROM fnd_id_flex_segments_vl a
         WHERE a.application_id = 401
           AND a.id_flex_code = flex_code
           AND a.id_flex_num = (SELECT id_flex_num
                                  FROM fnd_id_flex_structures
                                 WHERE id_flex_code = flex_code)
           AND a.enabled_flag = 'Y'
           AND a.display_flag = 'Y'
      ORDER BY a.segment_num;

    l_debug            NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SELECT id_flex_num
      INTO v_flex_num
      FROM fnd_id_flex_structures
     WHERE id_flex_code = 'MTLL';

    SELECT project_reference_enabled
      INTO v_proj_ref_enabled
      FROM mtl_parameters
     WHERE organization_id = x_org_id;

    v_delim  := fnd_flex_ext.get_delimiter('INV', v_flex_code, v_flex_num);
    str1     := '||''' || v_delim || '''||';

    FOR cur2 IN cur1(v_flex_code) LOOP
      IF v_proj_ref_enabled = 1
         AND(cur2.application_column_name = 'SEGMENT19'
             OR cur2.application_column_name = 'SEGMENT20') THEN
        IF cur2.application_column_name = 'SEGMENT19' THEN
          BEGIN
            v_seg19_f  := TRUE;

            -- bug 4662395 set the profile mfg_organization_id so
            -- the call to MTL_PROJECT_V will return data.

            FND_PROFILE.put('MFG_ORGANIZATION_ID',x_org_id);

            SELECT DISTINCT project_number
                       INTO v_proj_name
                       FROM mtl_project_v
                      WHERE project_id = (SELECT NVL(TO_NUMBER(segment19), 0)
                                            FROM mtl_item_locations
                                           WHERE inventory_location_id = x_loc_id
                                             AND organization_id = x_org_id);
          EXCEPTION
            WHEN OTHERS THEN
              v_proj_name  := NULL;
          END;
        ELSIF cur2.application_column_name = 'SEGMENT20' THEN
          BEGIN
            v_seg20_f  := TRUE;

            SELECT DISTINCT a.task_number
                       INTO v_task_name
                       FROM mtl_task_v a
                      WHERE a.task_id = (SELECT NVL(TO_NUMBER(segment20), 0)
                                           FROM mtl_item_locations
                                          WHERE inventory_location_id = x_loc_id
                                            AND organization_id = x_org_id)
                        AND a.project_id = (SELECT NVL(TO_NUMBER(segment19), a.project_id)
                                              FROM mtl_item_locations
                                             WHERE inventory_location_id = x_loc_id
                                               AND organization_id = x_org_id);
          EXCEPTION
            WHEN OTHERS THEN
              v_task_name  := NULL;
          END;
        END IF;
      END IF;
    END LOOP;

    FOR cur2 IN cur1(v_flex_code) LOOP
      IF v_loc_str IS NOT NULL THEN
        v_append  := v_loc_str || str1;
      ELSE
        v_append  := NULL;
      END IF;

      /*Bug#4278601
      v_loc_str needs to contain the locator segments in the order it was defined,
      including project and task segments.*/
      IF (CUR2.APPLICATION_COLUMN_NAME =  'SEGMENT19') THEN
          v_loc_str := v_append||''''||v_proj_name||'''';
      ELSIF (CUR2.APPLICATION_COLUMN_NAME =  'SEGMENT20') THEN
          v_loc_str := v_append||''''||v_task_name||'''';
      ELSIF (cur2.application_column_name <> 'SEGMENT19'
          AND cur2.application_column_name <> 'SEGMENT20') THEN
          v_loc_str  := v_append || cur2.application_column_name;
      END IF;
    END LOOP;

    IF v_loc_str IS NOT NULL THEN
      v_parse_str     :=
            'select ' || v_loc_str || ' from mtl_item_locations where inventory_location_id = :loc_id ' || ' and organization_id = :org_id';
      dsql_cur        := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(dsql_cur, v_parse_str, DBMS_SQL.native);
      DBMS_SQL.define_column(dsql_cur, 1, d_data_str, 800);
      DBMS_SQL.bind_variable(dsql_cur, 'loc_id', x_loc_id);
      DBMS_SQL.bind_variable(dsql_cur, 'org_id', x_org_id);
      rows_processed  := DBMS_SQL.EXECUTE(dsql_cur);

      LOOP
        IF (DBMS_SQL.fetch_rows(dsql_cur) > 0) THEN
          DBMS_SQL.column_value(dsql_cur, 1, d_data_str);
        ELSE
          -- No more rows in cursor
          DBMS_SQL.close_cursor(dsql_cur);
          EXIT;
        END IF;
      END LOOP;

      IF DBMS_SQL.is_open(dsql_cur) THEN
        DBMS_SQL.close_cursor(dsql_cur);
      END IF;
    END IF;

    /*Bug 4278601
    Comment out this section because now d_data_str will have the complete locator information
    in the order it was defined.
    IF v_seg19_f
       AND v_seg20_f THEN
      x_conc_segs  := d_data_str || v_delim || v_proj_name || v_delim || v_task_name;
    ELSIF v_seg19_f THEN
      x_conc_segs  := d_data_str || v_delim || v_proj_name;
    ELSIF v_seg20_f THEN
      x_conc_segs  := d_data_str || v_delim || v_task_name;
    ELSE
      x_conc_segs  := d_data_str;
    END IF;*/

    x_conc_segs := d_data_str; --Bug#4278601

    RETURN x_conc_segs;
  EXCEPTION
    WHEN OTHERS THEN
      x_conc_segs  := NULL;
      RETURN x_conc_segs;
  END get_conc_segments;

  /*
   Added for bug No :2326247.
   Calculates the item cost based on costing.
  */
  --Added NOCOPY hint to v_item_cost OUT parameter to comply
  --with GSCC standard File.Sql.39. Bug:4410848
  PROCEDURE get_item_cost(v_org_id IN NUMBER, v_item_id IN NUMBER, v_locator_id IN NUMBER, v_item_cost OUT NOCOPY NUMBER) IS
    -- For standard costed orgs, get the item cost with the common
    -- cost group ID = 1.  For average costed orgs, use the org's
    -- default cost group ID
    -- Bug # 2180251: All primary costing methods not equal to 1 should
    -- also be considered as an average costed org
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --Forward port bug7037252 	of bugs 6349028 and 6343400
    --Added DECODE on wms_enabled_flag in the 2nd SELECT stmt.
    --For WMS enabled average costing org, the org level CG may not be same as the onhand CG because you can have CG rules.
    l_wms_enabled_flag VARCHAR2(1) :=  'N';
  BEGIN
    --Bug7037252/6349028/6343400. Added following SELECT
    SELECT NVL(mp.wms_enabled_flag,'N')
     INTO l_wms_enabled_flag
    FROM MTL_PARAMETERS mp
    WHERE mp.organization_id=v_org_id ;
    SELECT NVL(ccicv.item_cost, 0)
      INTO v_item_cost
      FROM cst_cg_item_costs_view ccicv, mtl_parameters mp
     WHERE v_locator_id IS NULL
       AND ccicv.organization_id = v_org_id
       AND ccicv.inventory_item_id = v_item_id
       AND ccicv.organization_id = mp.organization_id
       AND ccicv.cost_group_id = DECODE(mp.primary_cost_method, 1, 1, NVL(mp.default_cost_group_id, 1))
    UNION ALL
    SELECT NVL(ccicv.item_cost, 0)
      FROM mtl_item_locations mil, cst_cg_item_costs_view ccicv, mtl_parameters mp
     WHERE v_locator_id IS NOT NULL
       AND mil.organization_id = v_org_id
       AND mil.inventory_location_id = v_locator_id
       AND mil.project_id IS NULL
       AND ccicv.organization_id = mil.organization_id
       AND ccicv.inventory_item_id = v_item_id
       AND ccicv.organization_id = mp.organization_id
    AND ccicv.cost_group_id = DECODE(mp.primary_cost_method, 1, 1, DECODE(l_wms_enabled_flag,'Y',ccicv.cost_group_id, NVL(mp.default_cost_group_id, 1)))
    UNION ALL
    SELECT NVL(ccicv.item_cost, 0)
      FROM mtl_item_locations mil, mrp_project_parameters mrp, cst_cg_item_costs_view ccicv, mtl_parameters mp
     WHERE v_locator_id IS NOT NULL
       AND mil.organization_id = v_org_id
       AND mil.inventory_location_id = v_locator_id
       AND mil.project_id IS NOT NULL
       AND mrp.organization_id = mil.organization_id
       AND mrp.project_id = mil.project_id
       AND ccicv.organization_id = mil.organization_id
       AND ccicv.inventory_item_id = v_item_id
       AND ccicv.organization_id = mp.organization_id
       AND ccicv.cost_group_id = DECODE(mp.primary_cost_method, 1, 1, NVL(mrp.costing_group_id, 1));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_item_cost  := -999;
    WHEN TOO_MANY_ROWS THEN  --Bug    --Forward port 7037252/6349028/6343400
     IF (l_wms_enabled_flag = 'Y' ) THEN
       --For WMS org with average costing, there may be more than one rows in cst_cg_item_costs_view.
       --In this case, the correct cost will be stamped from INV_COST_GROUP_PVT after obtaining exact cost group.
       v_item_cost := 1; --This is hard-coded so that we can retrieve the percent value in  INV_COST_GROUP_PVT.
     ELSE
       v_item_cost  := -999;  --This should result in error for non-wms orgs.
     END IF;
  END get_item_cost;

  PROCEDURE get_sales_order_id (
    p_sales_order_number               NUMBER  ,
    p_sales_order_type                 VARCHAR2,
    p_sales_order_source               VARCHAR2,
    p_concatenated_segments OUT NOCOPY VARCHAR2,
    p_source_id             OUT NOCOPY NUMBER) IS
  /*
    ||==============================================================================||
    ||  Created By : Nalin Kumar                                                    ||
    ||  Created On : 03-May-2005                                                    ||
    ||  Purpose    : This procedure will get called from TMO. This procedure will   ||
    ||               return the Sales Order ID and Concatenated Segments. Created   ||
    ||               as part of Depot Repair Enh. Bug# 4346443                      ||
    ||                                                                              ||
    ||  Known limitations, enhancements or remarks :                                ||
    ||  Change History :                                                            ||
    ||  Who             When            What                                        ||
    ||  (reverse chronological order - newest change first)                         ||
    ||==============================================================================||
  */
    l_delimiter VARCHAR2(1) := NULL;
    l_segment_array FND_FLEX_EXT.SegmentArray;
    l_n_segments NUMBER;
    l_val BOOLEAN;
  BEGIN
    p_source_id := NULL;
    --Get the Delimiter...
    l_delimiter := fnd_flex_apis.get_segment_delimiter(
                     x_application_id => 401,
                     x_id_flex_code   => 'MKTS',
                     x_id_flex_num    => '101');

    l_segment_array(1) := p_sales_order_number;
    l_segment_array(2) := p_sales_order_type;
    l_segment_array(3) := p_sales_order_source;
    l_n_segments       := 3;

    --Get Concatenated Segments...
    p_concatenated_segments := fnd_flex_ext.concatenate_segments(l_n_segments, l_segment_array, l_delimiter);

    --Check for the combination...
    l_val := fnd_flex_keyval.validate_segs(
               operation        => 'FIND_COMBINATION',
               appl_short_name  => 'INV',
               key_flex_code    => 'MKTS',
               structure_number => '101',
               concat_segments  => p_concatenated_segments,
               validation_date  => SYSDATE);

    --Get the combination id (source_id)...
    IF l_val THEN
      p_source_id := fnd_flex_keyval.combination_id;
    END IF;
  END get_sales_order_id ;

  /*
	This API was created as a part of MUOM fulfillment ER.
	This will accept source_line_id as input paramter and will return the fulfillment_base
	by calling  API OE_DUAL_UOM_UTIL.get_fulfillment_base.
	*/
	PROCEDURE get_inv_fulfillment_base(
                p_source_line_id IN NUMBER,
                p_demand_source_type_id IN NUMBER,
                p_org_id IN NUMBER,
                x_fulfillment_base OUT NOCOPY VARCHAR2) IS

     l_debug   NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_is_wms_enabled VARCHAR2 (2) := 'N';
   BEGIN

    IF (inv_cache.set_org_rec(p_org_id)) THEN
        l_is_wms_enabled := inv_cache.org_rec.WMS_ENABLED_FLAG;
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('WMS enabled? : '||l_is_wms_enabled , 'INV_UTILITIES', 9);
        END IF;
    END IF;

    IF l_is_wms_enabled = 'Y' THEN
          IF  p_demand_source_type_id IN (2,8) THEN
            x_fulfillment_base := Nvl(OE_DUAL_UOM_UTIL.get_fulfillment_base(p_source_line_id), 'P');
            IF (l_debug = 1) THEN
                inv_log_util.TRACE('The fulfillment Base: '||x_fulfillment_base , 'INV_UTILITIES', 9);
            END IF;
		  ELSE
			x_fulfillment_base := 'P';
          END IF;
		  ELSE
			x_fulfillment_base := 'P';
    END IF;
   END get_inv_fulfillment_base;

END inv_utilities;

/
