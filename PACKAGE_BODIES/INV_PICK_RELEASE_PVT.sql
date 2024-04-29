--------------------------------------------------------
--  DDL for Package Body INV_PICK_RELEASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PICK_RELEASE_PVT" AS
  /* $Header: INVVPICB.pls 120.25.12010000.15 2010/01/22 18:10:10 mporecha ship $ */

  --  Global constant holding the package name

  TYPE all_item_reservation_type IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;
  g_item_non_inv_rsv         all_item_reservation_type;
  g_item_sec_non_inv_rsv     all_item_reservation_type;

  g_backorder_cache         all_item_reservation_type;
  g_cleared_cache           all_item_reservation_type;

  g_pkg_name   CONSTANT VARCHAR2(30) := 'INV_Pick_Release_PVT';
  is_debug              BOOLEAN      := NULL;
  g_sub_reservable_type NUMBER       := 1;
  g_transaction_type_id    NUMBER;
  g_transaction_source_type_id NUMBER;
  g_organization_id NUMBER := NULL;
  g_inventory_item_id NUMBER := NULL;
  g_default_subinventory VARCHAR2(10);
  g_default_locator_id NUMBER := -1;
  g_request_number VARCHAR2(30);
  g_report_set_id NUMBER;
  g_use_backorder_cache NUMBER;
  g_honor_pick_from VARCHAR2(1);

  PROCEDURE print_debug(p_message IN VARCHAR2, p_module IN VARCHAR2) IS
  BEGIN
      IF is_debug THEN
        inv_pick_wave_pick_confirm_pub.tracelog(p_message, p_module);
        gmi_reservation_util.println('pick release '||p_message);
      END IF;
  END;

  FUNCTION check_backorder_cache (
    p_org_id                NUMBER
  , p_inventory_item_id     NUMBER
  , p_ignore_reservations   BOOLEAN
  , p_demand_line_id        NUMBER)
  return BOOLEAN IS

  l_quantity_reserved     NUMBER;
  l_debug                 NUMBER;

  BEGIN
    IF is_debug IS NULL THEN
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       If l_debug = 1 Then
         is_debug := TRUE;
       Else
         is_debug := FALSE;
       End If;
    END IF;

    if is_debug then
          print_debug('g_use_backorder_cache = '||g_use_backorder_cache, 'INV_PICK_RELEASE_PVT.CHECK_BACKORDER_CACHE');
    end if;

      -- Check whether backorder caching is turned off
      -- Bug 6997809, the profile value when No is 2, so changing 0 to 2.
    IF g_use_backorder_cache IS NULL THEN
         g_use_backorder_cache := NVL(FND_PROFILE.VALUE('INV_BACKORDER_CACHE'),2);
      END IF;

      -- Bug 6997809, the profile value when No is 2, so changing 0 to 2.
    IF g_use_backorder_cache = 2 THEN
       If is_debug then
            print_debug('Profile is No, returning FALSE', 'INV_PICK_RELEASE_PVT.CHECK_BACKORDER_CACHE');
         end if;
         RETURN FALSE;
      END IF;

      -- First check to determine if any reservations exist for the demand line
    If NOT p_ignore_reservations THEN
         -- Bug 4494038: exclude crossdock reservations
     SELECT sum(reservation_quantity - detailed_quantity)
       INTO l_quantity_reserved
         FROM  mtl_reservations
     WHERE demand_source_line_id = p_demand_line_id
           AND inventory_item_id = p_inventory_item_id
           AND organization_id = p_org_id
           AND nvl(staged_flag,'N') <> 'Y'
           AND demand_source_line_detail IS NULL;

     IF l_quantity_reserved > 0 THEN
            if is_debug then
               print_debug('l_quantity_reserved > 0, returning FALSE', 'INV_PICK_RELEASE_PVT.CHECK_BACKORDER_CACHE');
            end if;
            RETURN FALSE;
         END IF;
      END IF;

      -- IF an entry exists in the cache for this item verify Org and batch then return TRUE
    IF g_backorder_cache.EXISTS(p_inventory_item_id) THEN
     IF g_backorder_cache(p_inventory_item_id) = p_org_id THEN
             if is_debug then
                print_debug('Found item cache, returning TRUE', 'INV_PICK_RELEASE_PVT.CHECK_BACKORDER_CACHE');
             end if;
         RETURN TRUE;
         END IF;
      END IF;
      -- IF no reservation exists or no match found in cache then return FALSE
      if is_debug then
         print_debug('End returning FALSE', 'INV_PICK_RELEASE_PVT.CHECK_BACKORDER_CACHE');
      end if;
      RETURN FALSE;
  END;

  PROCEDURE clear_backorder_cache IS
  BEGIN
      g_backorder_cache := g_cleared_cache;
  END;


  PROCEDURE release_mo_tasks (p_header_id    NUMBER) IS
  BEGIN
      UPDATE mtl_material_transactions_temp
      SET wms_task_status = 1
      WHERE move_order_header_id = p_header_id;

        -- 8249710
        -- the following query updates the wms_task_status of parent records if exist
        UPDATE mtl_material_transactions_temp
        SET wms_task_status = 1
        WHERE transaction_temp_id IN
            ( SELECT DISTINCT mmtt2.parent_line_id
              FROM mtl_material_transactions_temp  mmtt2
              WHERE move_order_header_id = p_header_id
              AND parent_line_id IS NOT NULL
            );

  END;

  PROCEDURE get_tolerance(p_mo_line_id  NUMBER,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count OUT NOCOPY VARCHAR2,
                     x_msg_data OUT NOCOPY VARCHAR2,
                     x_max_tolerance OUT NOCOPY NUMBER,
                     x_min_tolerance OUT NOCOPY NUMBER) IS

 CURSOR c_mo_type IS
  SELECT move_order_typE
  FROM mtl_txn_request_headers mtrh, mtl_txn_request_lines mtrl
  WHERE mtrl.header_id = mtrh.header_id
   AND mtrl.line_id = p_mo_line_id;

 CURSOR c_detail_info IS
  SELECT inventory_item_id,
                 organization_id,
                 requested_quantity,
                 requested_quantity_uom,
                 requested_quantity_uom2,
                 ship_tolerance_above,
                 ship_tolerance_below,
                 source_header_id,
                 source_line_set_id,
                 source_code,
         source_line_id
  FROM   wsh_delivery_details
  WHERE  move_order_line_id = p_mo_line_id;

  l_detail_info    c_detail_info%ROWTYPE;
  l_minmaxinrectype WSH_DETAILS_VALIDATIONS.MinMaxInRecType;
  l_minmaxinoutrectype WSH_DETAILS_VALIDATIONS.MinMaxInOutRecType;
  l_minmaxoutrectype WSH_DETAILS_VALIDATIONS.MinMaxOutRecType;
  l_quantity_uom WSH_DELIVERY_DETAILS.requested_quantity_uom%TYPE;
  l_min_quantity NUMBER;
  l_max_quantity NUMBER;
  l_quantity_uom2 WSH_DELIVERY_DETAILS.requested_quantity_uom%TYPE;
  l_min_quantity2 NUMBER;
  l_max_quantity2 NUMBER;
  l_req_quantity NUMBER;
  l_move_order_type NUMBER;
  l_debug           NUMBER;

  BEGIN

    IF is_debug IS NULL THEN
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     If l_debug = 1 Then
     is_debug := TRUE;
       Else
     is_debug := FALSE;
       End If;
    END IF;

    OPEN c_mo_type;
    FETCH c_mo_type
     INTO l_move_order_type;
    IF NOT c_mo_type%FOUND THEN
        x_return_status := fnd_api.g_ret_sts_error;
      IF is_debug THEN
           print_debug('Move Order Line not found ' || p_mo_line_id,'INV_PICK_RELEASE_PVT.GET_TOLERANCE');
        END IF;
    END IF;
    CLOSE c_mo_type;

     -- {{ Test Case # UTK-REALLOC-3.2.6:60 }}
     --   Description: Allocate Requisition move order. No tolerances used.
     --     Tolerance used for Pick Wave Move orders
     --     For this release no tolerance for all other types of move orders
    IF (l_move_order_type = inv_globals.g_move_order_requisition) THEN
       --SELECT * FROM mtl_parameters;
       x_max_tolerance := 0;
       x_min_tolerance := 0;

    ELSIF (l_move_order_type = inv_globals.g_move_order_pick_wave
          AND NVL(fnd_profile.VALUE('WSH_OVERPICK_ENABLED'), 'N') = 'Y') THEN

       OPEN  c_detail_info;
       FETCH c_detail_info INTO l_detail_info;
       --l_found_flag := c_detail_info%FOUND;

     IF NOT c_detail_info%FOUND THEN
          x_return_status := fnd_api.g_ret_sts_error;
        IF is_debug THEN
             print_debug('Delivery Detail not found ' || p_mo_line_id,'INV_PICK_RELEASE_PVT.GET_TOLERANCE');
          END IF;
       ELSE
       l_minmaxinrectype.source_code := l_detail_info.source_code;
       l_minmaxinrectype.line_id := l_detail_info.source_line_id;
       l_minmaxinrectype.source_header_id := l_detail_info.source_header_id;
       l_minmaxinrectype.source_line_set_id := l_detail_info.source_line_set_id;
       l_minmaxinrectype.ship_tolerance_above := l_detail_info.ship_tolerance_above;
       l_minmaxinrectype.ship_tolerance_below := l_detail_info.ship_tolerance_below;
       l_minmaxinrectype.action_flag := 'P'; -- pick confirm
       l_minmaxinrectype.lock_flag := 'N';
       l_minmaxinrectype.quantity_uom := l_detail_info.requested_quantity_uom;
       l_minmaxinrectype.quantity_uom2 := l_detail_info.requested_quantity_uom2;

     WSH_DETAILS_VALIDATIONS.get_min_max_tolerance_quantity
                (p_in_attributes  => l_minmaxinrectype,
                 x_out_attributes  => l_minmaxoutrectype,
                 p_inout_attributes  => l_minmaxinoutrectype,
                 x_return_status  => x_return_status,
                 x_msg_count  =>  x_msg_count,
                 x_msg_data => x_msg_data
                 );

     l_quantity_uom := l_minmaxoutrectype.quantity_uom;
     l_min_quantity := l_minmaxoutrectype.min_remaining_quantity;
     l_max_quantity := l_minmaxoutrectype.max_remaining_quantity;
     l_quantity_uom2 := l_minmaxoutrectype.quantity2_uom;
     l_min_quantity2 := l_minmaxoutrectype.min_remaining_quantity2;
     l_max_quantity2 := l_minmaxoutrectype.max_remaining_quantity2;
     l_req_quantity := l_detail_info.requested_quantity;

     --x_max_tolerance := least(greatest((l_max_quantity - l_req_quantity) / l_req_quantity, 0), l_detail_info.ship_tolerance_above);
     x_max_tolerance := l_max_quantity - l_req_quantity;

     --x_min_tolerance := l_req_quantity - l_min_quantity;  --Bug 7238552
     x_min_tolerance := 0; -- Bug 7449487

     IF is_debug THEN
        print_debug('Return Status '||x_return_status,'INV_PICK_RELEASE_PVT.GET_TOLERANCE');
        print_debug('Req Qty '||l_req_quantity,'INV_PICK_RELEASE_PVT.GET_TOLERANCE');
        print_debug('Max Qty '||l_max_quantity,'INV_PICK_RELEASE_PVT.GET_TOLERANCE');
        print_debug('Min Qty '||l_min_quantity,'INV_PICK_RELEASE_PVT.GET_TOLERANCE');
        print_debug('Qty UOM '||l_quantity_uom,'INV_PICK_RELEASE_PVT.GET_TOLERANCE');
        print_debug('Max Tolerance '||x_max_tolerance,'INV_PICK_RELEASE_PVT.GET_TOLERANCE');
        print_debug('Min Tolerance '||x_min_tolerance,'INV_PICK_RELEASE_PVT.GET_TOLERANCE');
     END IF;
     END IF; -- if c_detail_info found
       CLOSE c_detail_info;
  ELSE
     x_max_tolerance := 0;
     x_min_tolerance := 0;
  END IF;
    g_max_tolerance := x_max_tolerance;
    g_min_tolerance := x_min_tolerance;
  END get_tolerance;


  -- This function returns 2 if the reservation does not match the move order
  -- line, 1 otherwise.
  FUNCTION reservation_matches(
    p_mo_line_rec IN inv_move_order_pub.trolin_rec_type
  , p_res_rec     IN inv_reservation_global.mtl_reservation_rec_type
  )
    RETURN NUMBER IS
   l_mo_from_sub   VARCHAR2(10);
   l_mo_from_loc   NUMBER;
  BEGIN
    -- Bug 2363651 - We will give preference to the reservation, not to the
    -- value on the move order line. This will remove the issue of excess
    -- reservations from getting created if the from sub, from locator, rev,
    -- or is specified on the move order line

    IF p_res_rec.ship_ready_flag = 1 THEN
      RETURN 2;
    END IF;

-- BUG 3352603
-- Bug 3195332, removing
-- p_res_rec.primary_reservation_quantity-nvl(p_res_rec.detailed_quantity,0)) <=0 condtion,
-- as this was creating multiple reservations for the same controls. Keeping the
-- p_res_rec.primary_reservation_quantity <0 check for data corruption.

   IF p_res_rec.primary_reservation_quantity <0 THEN
       return 2;
   END IF;

-- BUG 4702900
-- In a reversal of the fix made above 2363651 the move order will have
-- preference if the profile WSH_HONOR_PICK_FROM is set.
-- To avoid the problem of excess reservations, the lines for which the
-- from sub on the reservation does not match will not be passed from
-- shipping. See 4529693 for further details
   IF g_honor_pick_from IS NULL THEN
      g_honor_pick_from := NVL(FND_PROFILE.VALUE('WSH_HONOR_PICK_FROM'),'N');
   END IF;
   l_mo_from_sub := p_mo_line_rec.from_subinventory_code;
   IF l_mo_from_sub IS NOT NULL THEN
     IF l_mo_from_sub <> nvl(p_res_rec.subinventory_code,l_mo_from_sub) THEN
       IF (is_debug) THEN
           print_debug('Reservation with different SUB to move order skipped ',
                   'INV_PICK_RELEASE_PVT.RESERVATION_MATCHES');
       END IF;
       return 2;
     END IF;
     l_mo_from_loc := p_mo_line_rec.from_locator_id;
     IF l_mo_from_loc IS NOT NULL THEN
       IF l_mo_from_loc <> nvl(p_res_rec.locator_id,l_mo_from_loc) THEN
         IF (is_debug) THEN
            print_debug('Reservation with different Locator to move order skipped ',
                   'INV_PICK_RELEASE_PVT.RESERVATION_MATCHES');
         END IF;
         return 2;
       END IF;
     END IF;
   END IF;

   --Completed reservations should not be used for detailing

   -- If the reservation has not been filtered out yet, it is a match.
   RETURN 1;
  END reservation_matches;
/* FP-J PAR Replenishment Counts: 4 new input parameters are introduced viz.,
   p_dest_subinv, p_dest_locator_id, p_project_id, p_task_id. This is as a result
   of moving Supply Subinv, Supply Locator, Project and Task to 'Common' group
   from 'Manufacturing' group in Grouping Rule form. */
  PROCEDURE get_pick_slip_number(
    p_ps_mode                   VARCHAR2
  , p_pick_grouping_rule_id     NUMBER
  , p_org_id                    NUMBER
  , p_header_id                 NUMBER
  , p_customer_id               NUMBER
  , p_ship_method_code          VARCHAR2
  , p_ship_to_loc_id            NUMBER
  , p_shipment_priority         VARCHAR2
  , p_subinventory              VARCHAR2
  , p_trip_stop_id              NUMBER
  , p_delivery_id               NUMBER
  , x_pick_slip_number      OUT NOCOPY NUMBER
  , x_ready_to_print        OUT NOCOPY VARCHAR2
  , x_api_status            OUT NOCOPY VARCHAR2
  , x_error_message         OUT NOCOPY VARCHAR2
  , x_call_mode             OUT NOCOPY VARCHAR2
  , p_dest_subinv               VARCHAR2 DEFAULT NULL
  , p_dest_locator_id           NUMBER   DEFAULT NULL
  , p_project_id                NUMBER   DEFAULT NULL
  , p_task_id                   NUMBER   DEFAULT NULL
  , p_inventory_item_id         NUMBER   DEFAULT NULL
  , p_locator_id                NUMBER   DEFAULT NULL
  , p_revision                  VARCHAR2 DEFAULT NULL
) IS
  p_pr_mode   BOOLEAN  := WSH_PICK_LIST.G_PICK_REL_PARALLEL;
  BEGIN
    x_api_status := fnd_api.g_ret_sts_success;
    -- Bug 2666620:
    --    If the Patchset Level of Shipping is less than 'I' then call
    --     Shipping's GET_PICK_SLIP_NUMBER.
    --    Otherwise calls Inventory's GET_PICK_SLIP_NUMBER
    IF wsh_code_control.get_code_release_level < '110509' THEN
      IF (is_debug) THEN
         print_debug('Calling WSH_PR_PICK_SLIP_NUMBER.GET_PICK_SLIP_NUMBER',
             'INV_PICK_RELEASE_PVT.GET_PICK_SLIP_NUMBER');
      END IF;
      wsh_pr_pick_slip_number.get_pick_slip_number(
        p_ps_mode                    => p_ps_mode
      , p_pick_grouping_rule_id      => p_pick_grouping_rule_id
      , p_org_id                     => p_org_id
      , p_header_id                  => p_header_id
      , p_customer_id                => p_customer_id
      , p_ship_method_code           => p_ship_method_code
      , p_ship_to_loc_id             => p_ship_to_loc_id
      , p_shipment_priority          => p_shipment_priority
      , p_subinventory               => p_subinventory
      , p_trip_stop_id               => p_trip_stop_id
      , p_delivery_id                => p_delivery_id
      , x_pick_slip_number           => x_pick_slip_number
      , x_ready_to_print             => x_ready_to_print
      , x_api_status                 => x_api_status
      , x_error_message              => x_error_message
      , x_call_mode                  => x_call_mode
      );
    ELSE
    IF (is_debug) THEN
         print_debug('Calling INV_PR_PICK_SLIP_NUMBER.GET_PICK_SLIP_NUMBER',
         'GET_PICK_SLIP_NUMBER');
      END IF;
      /* If p_pr_mode is TRUE then calling the api get_pick_slip_number_parallel
          for Parallel Pick-Release enhancement */
      IF p_pr_mode THEN
        inv_pr_pick_slip_number.get_pick_slip_number_parallel(
        p_ps_mode                    => p_ps_mode
          , p_pick_grouping_rule_id      => p_pick_grouping_rule_id
          , p_org_id                     => p_org_id
          , p_header_id                  => p_header_id
          , p_customer_id                => p_customer_id
          , p_ship_method_code           => p_ship_method_code
          , p_ship_to_loc_id             => p_ship_to_loc_id
          , p_shipment_priority          => p_shipment_priority
          , p_subinventory               => p_subinventory
          , p_trip_stop_id               => p_trip_stop_id
          , p_delivery_id                => p_delivery_id
          , p_inventory_item_id          => p_inventory_item_id
          , p_locator_id                 => p_locator_id
          , p_revision                   => p_revision
          , x_pick_slip_number           => x_pick_slip_number
          , x_ready_to_print             => x_ready_to_print
          , x_api_status                 => x_api_status
          , x_error_message              => x_error_message
          , x_call_mode                  => x_call_mode
          , p_dest_subinventory          => p_dest_subinv
          , p_dest_locator_id            => p_dest_locator_id
          , p_project_id                 => p_project_id
          , p_task_id                    => p_task_id
          );

      ELSE
      /* FP-J PAR Replenishment Count: Call the API with 4 new additional
         input parameters so that these are
         also honored for grouping for pick wave move orders */
      inv_pr_pick_slip_number.get_pick_slip_number(
        p_ps_mode                    => p_ps_mode
      , p_pick_grouping_rule_id      => p_pick_grouping_rule_id
      , p_org_id                     => p_org_id
      , p_header_id                  => p_header_id
      , p_customer_id                => p_customer_id
      , p_ship_method_code           => p_ship_method_code
      , p_ship_to_loc_id             => p_ship_to_loc_id
      , p_shipment_priority          => p_shipment_priority
      , p_subinventory               => p_subinventory
      , p_trip_stop_id               => p_trip_stop_id
      , p_delivery_id                => p_delivery_id
      , p_inventory_item_id          => p_inventory_item_id
      , p_locator_id                 => p_locator_id
      , p_revision                   => p_revision
      , x_pick_slip_number           => x_pick_slip_number
      , x_ready_to_print             => x_ready_to_print
      , x_api_status                 => x_api_status
      , x_error_message              => x_error_message
      , x_call_mode                  => x_call_mode
      , p_dest_subinventory          => p_dest_subinv
      , p_dest_locator_id            => p_dest_locator_id
      , p_project_id                 => p_project_id
      , p_task_id                    => p_task_id
      );
      END IF;
    END IF;
  END get_pick_slip_number;


-- Adding  x_rsv_qty2_available parameter to pass the secondary quantity available to reserve bug #7377744
  PROCEDURE process_reservations(
    x_return_status       OUT    NOCOPY VARCHAR2
  , x_msg_count           OUT    NOCOPY NUMBER
  , x_msg_data            OUT    NOCOPY VARCHAR2
  , p_demand_info         IN     wsh_inv_delivery_details_v%ROWTYPE
  , p_mo_line_rec         IN     inv_move_order_pub.trolin_rec_type
  , p_mso_line_id         IN     NUMBER
  , p_demand_source_type  IN     VARCHAR2
  , p_demand_source_name  IN     VARCHAR2
  , p_allow_partial_pick  IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_demand_rsvs_ordered OUT    NOCOPY inv_reservation_global.mtl_reservation_tbl_type
  , x_rsv_qty_available   OUT    NOCOPY NUMBER
  , x_rsv_qty2_available   OUT    NOCOPY NUMBER
  ) IS
    -- A local copy of the move order line record
    l_qry_rsv_rec            inv_reservation_global.mtl_reservation_rec_type;
    -- Record for querying up matching reservations for the move order line
    l_qry_rsv_rec_by_id      inv_reservation_global.mtl_reservation_rec_type;
    -- Record for querying up a single reservation record by the reservation ID
    l_update_rsv_rec         inv_reservation_global.mtl_reservation_rec_type;
    -- Record for updating reservations
    l_demand_reservations    inv_reservation_global.mtl_reservation_tbl_type;
    -- The table of reservations for the line's demand source
    l_demand_rsvs_ordered     inv_reservation_global.mtl_reservation_tbl_type;
    -- The above table in descending order of detail, and with any non-matching records filtered out.
    l_reservation_count           NUMBER; -- The number of reservations for the line
    l_all_reservation_count       NUMBER; -- The number of reservations for the line
    l_reservation_count_by_id     NUMBER; -- The number of reservations returned when querying by reservation ID (should be 1)
    l_mso_header_id               NUMBER; -- The MTL_SALES_ORDERS header ID, which should be derived from the OE header ID
                                          -- and used for reservation queries.
    l_org_wide_res_id             NUMBER                                          := -1; -- If an org-wide reservation exists for the move order line, this variable will
    -- contain its reservation ID.
    l_res_tbl_index               NUMBER; -- An index to the elements of the reservations table.
    l_res_ordered_index           NUMBER; -- An index to the elements of the ordered and filtered reservations table.
    l_qty_to_detail_unconv        NUMBER; -- The quantity which should be detailed, in the UOM of the move order line.
    l_reserved_quantity           NUMBER := 0; -- The quantity for the given move order line which is reserved.
    l_sec_reserved_quantity       NUMBER := 0; -- The quantity for the given move order line which is reserved.
    l_unreserved_quantity         NUMBER; -- The quantity for the given move order line which is not reserved.
    l_sec_unreserved_quantity     NUMBER; -- The quantity for the given move order line which is not reserved.
    l_qty_available_to_reserve    NUMBER; -- The quantity which can still be reserved.
    l_qty_on_hand                 NUMBER; -- The org-wide quantity on-hand
    l_qty_res_on_hand             NUMBER; -- The org-wide reservable quantity on-hand
    l_qty_res                     NUMBER; -- The org-wide quantity reserved
    l_qty_sug                     NUMBER; -- The org-wide quantity suggested
    l_qty_att                     NUMBER; -- The org-wide available to transact
    l_quantity_to_reserve         NUMBER; -- The additional quantity which should be reserved.
    l_sec_qty_available_to_reserve    NUMBER; -- The quantity which can still be reserved.
    l_sec_qty_on_hand                 NUMBER; -- The org-wide quantity on-hand
    l_sec_qty_res_on_hand             NUMBER; -- The org-wide reservable quantity on-hand
    l_sec_qty_res                     NUMBER; -- The org-wide quantity reserved
    l_sec_qty_sug                     NUMBER; -- The org-wide quantity suggested
    l_sec_qty_att                     NUMBER; -- The org-wide available to transact
    l_sec_quantity_to_reserve         NUMBER; -- The additional quantity which should be reserved.
                                          -- Equivalent to the MIN of the unreserved quantity and the quantity available to reserve.
    l_qty_succ_reserved           NUMBER; -- The quantity which was successfully reserved (if a reservation was created)
    l_quantity_to_detail          NUMBER; -- The quantity for the move order line which should be detailed.
                                          -- Equivalent to the Move Order Line quantity minus the detailed quantity
                                          -- and converted to the primary UOM.
    l_sec_qty_succ_reserved       NUMBER; -- The quantity which was successfully reserved (if a reservation was created)
    l_sec_quantity_to_detail      NUMBER; -- The quantity for the move order line which should be detailed.

    l_primary_uom                 VARCHAR2(3); -- The primary UOM for the item
    l_secondary_uom               VARCHAR2(3); -- The secondary UOM for the item
    l_grade_code                  VARCHAR2(150); -- grade required

    l_msg_data                    VARCHAR2(2000);
    l_msg_count                   NUMBER;
    l_api_return_status           VARCHAR2(1); -- The return status of APIs called within the Process Line API.
    l_api_error_code              NUMBER; -- The error code of APIs called within the Process Line API.
    l_api_error_msg               VARCHAR2(100); -- The error message returned by certain APIs called within Process_Line
    l_count                       NUMBER;
    l_message                     VARCHAR2(255);
    l_demand_source_type          NUMBER                                          := p_demand_source_type;
    l_non_inv_reservations_qty NUMBER                                          := 0;
    l_primary_reservation_qty     NUMBER                                          := 0;

    l_non_inv_sec_reservation_qty NUMBER                                          := 0;
    l_secondary_reservation_qty     NUMBER                                          := 0;

    l_staged_flag                 VARCHAR2(1);
    l_dummy_sn                    inv_reservation_global.serial_number_tbl_type;
    l_revision_control_code       NUMBER;
    l_lot_control_code            NUMBER;
    l_lot_divisible_flag          VARCHAR2(1);
    l_serial_control_code         NUMBER;
    l_is_revision_control         BOOLEAN;
    l_is_lot_control              BOOLEAN;
    l_is_serial_control           BOOLEAN;
    source_from_sub               VARCHAR2(20);
    source_from_loc               NUMBER;
    l_return_value           BOOLEAN := TRUE;
    l_new_prim_rsv_quantity      NUMBER;
    l_new_sec_rsv_quantity      NUMBER;
    l_index              NUMBER;
    l_new_rsv_quantity          NUMBER;

-- Bug 2972143
    l_new_demand_rsvs_ordered         INV_Reservation_GLOBAL.MTL_RESERVATION_TBL_TYPE;

-- Bug 4171297
    l_order_line_qty_unconv       NUMBER; -- The order line quantity, in the order line uom.
    l_order_line_qty              NUMBER; -- The order line quantity, converted in the primary uom.
    l_order_line_uom              VARCHAR2(3); -- The UOM in which the order line quantity is specified.
    l_primary_staged_qty          NUMBER := 0; -- Sum of staged reservation qty for this order line.
    l_orig_quantity_to_detail     NUMBER;

    l_rsv_serials          inv_reservation_global.serial_number_tbl_type;
    l_pri_sec_conv          NUMBER;
    --Expired lots custom hook
    l_exp_date              DATE;

    CURSOR get_rsv_serials (rsv_id   NUMBER) IS
      SELECT reservation_id, serial_number
      FROM mtl_serial_numbers msn
      WHERE reservation_id =  rsv_id
        AND current_status = 3
        AND NOT EXISTS (Select serial_number
                        From mtl_serial_numbers_temp msnt
                        Where msn.serial_number between msnt.fm_serial_number and nvl(msnt.to_serial_number,msnt.fm_serial_number)
                        and (msn.group_mark_id = msnt.transaction_temp_id
                             OR msn.group_mark_id = msnt.group_header_id
                             )
                        ); -- Bug 8618236
  -- Possible Performance improvement
  -- Select serials for this item into a table and use that table


  BEGIN
    IF (is_debug ) THEN
       print_debug('Inside Process_Reservations', 'Inv_Pick_Release_PVT.Process_Reservations');
    END IF;

    BEGIN
        -- Bug 4494038: exclude crossdock reservations
        IF NOT g_item_non_inv_rsv.exists(p_mo_line_rec.inventory_item_id) THEN
           SELECT sum(primary_reservation_quantity)
                , sum(secondary_reservation_quantity)
             INTO g_item_non_inv_rsv(p_mo_line_rec.inventory_item_id)
                , g_item_sec_non_inv_rsv(p_mo_line_rec.inventory_item_id)
             FROM mtl_reservations
            WHERE organization_id = p_mo_line_rec.organization_id
              AND inventory_item_id = p_mo_line_rec.inventory_item_id
              AND supply_source_type_id <> INV_Reservation_GLOBAL.g_source_type_inv
              AND demand_source_line_detail IS NULL;
        END IF;

        -- Bug 4494038: exclude crossdock reservations
        IF g_item_non_inv_rsv(p_mo_line_rec.inventory_item_id) > 0 THEN
           SELECT nvl(sum(primary_reservation_quantity),0)
                , nvl(sum(secondary_reservation_quantity),0)
             INTO l_non_inv_reservations_qty
                , l_non_inv_sec_reservation_qty
             FROM mtl_reservations
            WHERE demand_source_line_id = p_demand_info.oe_line_id
              AND organization_id = p_mo_line_rec.organization_id
              AND inventory_item_id = p_mo_line_rec.inventory_item_id
              AND demand_source_type_id = p_demand_source_type
              AND supply_source_type_id <> INV_Reservation_GLOBAL.g_source_type_inv
              AND demand_source_line_detail IS NULL;
        ELSE
           l_non_inv_reservations_qty := 0;
           l_non_inv_sec_reservation_qty := 0;
        END IF;

    EXCEPTION
        WHEN no_data_found THEN
          l_non_inv_reservations_qty := 0;
          l_non_inv_sec_reservation_qty := 0;
          g_item_non_inv_rsv(p_mo_line_rec.inventory_item_id) := 0;
    END;
    IF is_debug THEN
      print_debug('All primary reservation qty: '||l_non_inv_reservations_qty, 'Inv_Pick_Release_PVT.Process_Reservations');
      print_debug('All secondary reservation qty: '||l_non_inv_sec_reservation_qty , 'Inv_Pick_Release_PVT.Process_Reservations');
    END IF;

    l_qry_rsv_rec.organization_id         := p_mo_line_rec.organization_id;
    l_qry_rsv_rec.inventory_item_id       := p_mo_line_rec.inventory_item_id;
    l_qry_rsv_rec.demand_source_type_id   := p_demand_source_type;
    l_qry_rsv_rec.demand_source_header_id := nvl(p_mso_line_id,fnd_api.g_miss_num);
    l_qry_rsv_rec.demand_source_line_id   := p_demand_info.oe_line_id;
    l_qry_rsv_rec.demand_source_name      := nvl(p_demand_source_name,fnd_api.g_miss_char);
    l_qry_rsv_rec.supply_source_type_id   := inv_reservation_global.g_source_type_inv;
    inv_reservation_pub.query_reservation(
      p_api_version_number         => 1.0
    , p_init_msg_lst               => fnd_api.g_false
    , x_return_status              => l_api_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_query_input                => l_qry_rsv_rec
    --, p_cancel_order_mode           => inv_reservation_global.g_cancel_order_yes
    , x_mtl_reservation_tbl        => l_demand_reservations
    , x_mtl_reservation_tbl_count  => l_reservation_count
    , x_error_code                 => l_api_error_code
    );

    -- Return an error if the query reservations call failed
    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
      IF (is_debug) THEN
         print_debug('return error from query reservation: '||l_api_return_status,'INV_Pick_Release_PVT.Process_Reservations');
      END IF;
      fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (is_debug) THEN
       print_debug('Unstaged l_non_inv_reservations_qty '|| l_non_inv_reservations_qty,'Inv_Pick_Release_PVT.Process_Reservations');
    END IF;

    -- Check if the picking subinventory (if specified on the MO) is
    -- reservable OR not
    IF (p_mo_line_rec.from_subinventory_code IS NOT NULL) THEN
      l_return_value := INV_CACHE.set_fromsub_rec(
                p_mo_line_rec.organization_id,
                p_mo_line_rec.from_subinventory_code);
      If NOT l_return_value Then
        if is_debug then
          print_debug('Error setting from sub cache','Inv_Pick_Release_PVT.Process_Reservations');
        end if;
        RAISE fnd_api.g_exc_unexpected_error;
      End If;
      g_sub_reservable_type := INV_CACHE.fromsub_rec.reservable_type;
    ELSE
      g_sub_reservable_type  := 1;
    END IF;

    -- Filter out reservations which do not match attributes of the move
    -- order line, and copy the reservation records into another table
    -- in reverse order (so that this table
    -- will have the reservations in descending order of detail).
    IF l_reservation_count > 0 THEN
      l_res_tbl_index      := l_demand_reservations.LAST;
      l_res_ordered_index  := 0;

      LOOP
        l_staged_flag := l_demand_reservations(l_res_tbl_index).staged_flag;
        IF NVL(l_staged_flag, 'N') = 'N' THEN
          l_primary_reservation_qty    := l_primary_reservation_qty +
                                        l_demand_reservations(l_res_tbl_index).primary_reservation_quantity;
          l_secondary_reservation_qty  := l_secondary_reservation_qty +
                                        l_demand_reservations(l_res_tbl_index).secondary_reservation_quantity;
        END IF;

        IF (is_debug) THEN
           print_debug('l_primary_reservation_qty'|| l_primary_reservation_qty,
        'Inv_Pick_Release_PVT.process_reservations');

        -- Bug 6989438
        print_debug('l_secondary_reservation_qty'|| l_secondary_reservation_qty,
        'Inv_Pick_Release_PVT.process_reservations');

           print_debug('try to match the reservation exist with the current move order ', 'Inv_Pick_Release_PVT.process_reservations');
        END IF;

        IF  reservation_matches(p_mo_line_rec, l_demand_reservations(l_res_tbl_index)) = 1
            AND NVL(l_staged_flag, 'N') = 'N' THEN
          l_res_ordered_index                  := l_res_ordered_index + 1;
          l_demand_rsvs_ordered(l_res_ordered_index) :=
          l_demand_reservations(l_res_tbl_index);
          IF g_sub_reservable_type = 1 THEN
            -- Compute the total reserved quantity by summing the quantities
            -- for the filtered reservations (minus any quantity detailed).
            l_reserved_quantity  :=   l_reserved_quantity
              + NVL(l_demand_reservations(l_res_tbl_index).primary_reservation_quantity, 0)
              - NVL(l_demand_reservations(l_res_tbl_index).detailed_quantity,0);
            l_sec_reserved_quantity  :=   l_sec_reserved_quantity
              + NVL(l_demand_reservations(l_res_tbl_index).secondary_reservation_quantity, 0)
              - NVL(l_demand_reservations(l_res_tbl_index).secondary_detailed_quantity,0);
          END IF;

        END IF;

        EXIT WHEN l_res_tbl_index = l_demand_reservations.FIRST;
        l_res_tbl_index  := l_demand_reservations.PRIOR(l_res_tbl_index);
      END LOOP;
    END IF;

    -- Update the reservation count based on the reservations which matched
    l_reservation_count                    := l_demand_rsvs_ordered.COUNT;

    -- Determine whether an organization-wide reservation exists for this
    -- move order line. Since reservations are now sorted in descending
    --  order of detail, only the last reservation record in the table could
    -- possibly be an org-level reservation.
    IF l_reservation_count > 0 THEN
      l_res_ordered_index  := l_demand_rsvs_ordered.LAST;

      IF  l_demand_rsvs_ordered(l_res_ordered_index).revision IS NULL
          AND l_demand_rsvs_ordered(l_res_ordered_index).lot_number IS NULL
          AND l_demand_rsvs_ordered(l_res_ordered_index).subinventory_code IS NULL
          AND l_demand_rsvs_ordered(l_res_ordered_index).locator_id IS NULL THEN
        l_org_wide_res_id  := l_demand_rsvs_ordered(l_res_ordered_index).reservation_id;
      END IF;
    END IF;


    IF g_sub_reservable_type = 1 THEN

        -- Compute the quantity which will be detailed (converted to
        -- primary quantity)
        l_qty_to_detail_unconv    := p_mo_line_rec.quantity - NVL(p_mo_line_rec.quantity_detailed, 0);
        l_sec_quantity_to_detail  := p_mo_line_rec.secondary_quantity - NVL(p_mo_line_rec.secondary_quantity_detailed, 0);
        l_grade_code              := p_mo_line_rec.grade_code;

        l_return_value := INV_CACHE.set_item_rec(
                                      p_mo_line_rec.organization_id,
                                      p_mo_line_rec.inventory_item_id);
        If NOT l_return_value Then
            if is_debug then
              print_debug('Error setting from sub cache',
                          'Inv_Pick_Release_PVT.Process_Reservations');
            end if;
            RAISE fnd_api.g_exc_unexpected_error;
        End If;

        l_primary_uom:= INV_CACHE.item_rec.primary_uom_code;
        l_secondary_uom:= INV_CACHE.item_rec.secondary_uom_code;
        l_revision_control_code:= INV_CACHE.item_rec.revision_qty_control_code;
        l_lot_control_code:= INV_CACHE.item_rec.lot_control_code;
        l_serial_control_code:= INV_CACHE.item_rec.serial_number_control_code;

        IF(l_lot_control_code = inv_reservation_global.g_lot_control_yes AND INV_CACHE.item_rec.lot_divisible_flag <> 'Y') THEN
            l_lot_divisible_flag := 'N';
        ELSE
            l_lot_divisible_flag := 'Y';
        END IF;

        IF (l_primary_uom <> p_mo_line_rec.uom_code) THEN
            l_quantity_to_detail  := inv_convert.inv_um_convert(
                                      item_id                      => p_mo_line_rec.inventory_item_id
                                    , PRECISION                    => NULL
                                    , from_quantity                => l_qty_to_detail_unconv
                                    , from_unit                    => p_mo_line_rec.uom_code
                                    , to_unit                      => l_primary_uom
                                    , from_name                    => NULL
                                    , to_name                      => NULL
                                 );

            IF (l_quantity_to_detail = -99999) THEN
                IF (is_debug) THEN
                    print_debug('Cannot convert uom to primary uom', 'Inv_Pick_release_pvt.process_reservations');
                END IF;
                fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
                fnd_message.set_token('UOM', l_primary_uom);
                fnd_message.set_token('ROUTINE', 'Pick Release process');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        ELSE
            l_quantity_to_detail  := l_qty_to_detail_unconv;
        END IF;

        -- convert revision/lot control indicators into boolean
        IF l_revision_control_code = 2 THEN
            l_is_revision_control  := TRUE;
        ELSE
            l_is_revision_control  := FALSE;
        END IF;

        --
        IF l_lot_control_code = 2 THEN
            l_is_lot_control  := TRUE;
        ELSE
            l_is_lot_control  := FALSE;
        END IF;

        --
        IF l_serial_control_code = 2 THEN
            l_is_serial_control  := TRUE;
        ELSE
            l_is_serial_control  := FALSE;
        END IF;

        IF (is_debug) THEN
            print_debug('l_reserved_quantity  = ' ||l_reserved_quantity, 'Inv_Pick_Release_PVT.Process_Reservations');
            print_debug('l_sec_reserved_quantity  = ' ||l_sec_reserved_quantity, 'Inv_Pick_Release_PVT.Process_Reservations');
            print_debug('l_quantity_to_detail = ' ||l_quantity_to_detail, 'Inv_Pick_Release_PVT.Process_Reservations');
            print_debug('l_sec_quantity_to_detail = ' ||l_sec_quantity_to_detail, 'Inv_Pick_Release_PVT.Process_Reservations');
            print_debug('l_non_inv_reservations_qty = ' ||l_non_inv_reservations_qty, 'Inv_Pick_Release_PVT.Process_Reservations');
            print_debug('l_non_inv_sec_reservation_qty = ' ||l_non_inv_sec_reservation_qty, 'Inv_Pick_Release_PVT.Process_Reservations');
        END IF;

        IF (l_non_inv_reservations_qty > 0 AND l_quantity_to_detail > l_reserved_quantity    -- Bug 3440014
         ) THEN
            IF (is_debug) THEN
                print_debug('Adjust l_quantity_to_detail honor supply rsv', 'Inv_Pick_Release_PVT.Process_Reservations');
            END IF;
            -- Bug 4171297, if the order line has Wip supply reservation then l_quantity_to_detail
            -- should be calculated based on order line quantity. Adding the below logic to calculate
            -- the l_quantity_to_detail.
            l_return_value := INV_CACHE.set_oola_rec(p_demand_info.oe_line_id);
            IF NOT l_return_value Then
                IF (is_debug) THEN
                    print_debug('Error setting cache for order line', 'Inv_Pick_Release_PVT.Process_Reservations');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_order_line_qty_unconv := INV_CACHE.oola_rec.ordered_quantity;
            l_order_line_uom        := INV_CACHE.oola_rec.order_quantity_uom;

            IF (is_debug) THEN
              print_debug('l_order_line_qty_unconv  = ' ||l_order_line_qty_unconv, 'Inv_Pick_Release_PVT.Process_Reservations');
              print_debug('l_order_line_uom = ' ||l_order_line_uom, 'Inv_Pick_Release_PVT.Process_Reservations');
            END IF;

            IF (l_primary_uom <> l_order_line_uom) THEN
               l_order_line_qty  := inv_convert.inv_um_convert(
                                       item_id                      => p_mo_line_rec.inventory_item_id
                                     , PRECISION                    => NULL
                                     , from_quantity                => l_order_line_qty_unconv
                                     , from_unit                    => l_order_line_uom
                                     , to_unit                      => l_primary_uom
                                     , from_name                    => NULL
                                     , to_name                      => NULL
                                     );

                IF (l_order_line_qty = -99999) THEN
                    IF (is_debug) THEN
                        print_debug('Cannot convert order quantity to primary uom', 'Inv_Pick_release_pvt.process_reservations');
                    END IF;
                    fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
                    fnd_message.set_token('UOM', l_primary_uom);
                    fnd_message.set_token('ROUTINE', 'Pick Release process');
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            ELSE
                l_order_line_qty  := l_order_line_qty_unconv;
            END IF;

            IF (is_debug) THEN
                print_debug('l_order_line_qty  = ' ||l_order_line_qty, 'Inv_Pick_Release_PVT.Process_Reservations');
            END IF;

            -- Calculated using the following formula least of move order line quantity and
            -- order line quantity - all reservations + calculated reserved quantity for line
            -- all reservations = l_non_inv_reservation_qty + l_primary_reservation_qty + l_primary_staged_qty
            l_orig_quantity_to_detail := l_quantity_to_detail;
            -- l_quantity_to_detail  := l_quantity_to_detail - (l_non_inv_reservation_qty - l_primary_reservation_qty);
            l_quantity_to_detail := least(l_quantity_to_detail, l_order_line_qty - (l_non_inv_reservations_qty + l_primary_staged_qty
                                                                                  + l_primary_reservation_qty - l_reserved_quantity));
            --l_order_line_qty - (l_non_inv_reservation_qty - l_reserved_quantity + l_primary_staged_qty));

            IF (is_debug) THEN
                print_debug('l_quantity_to_detail = ' ||l_quantity_to_detail, 'Inv_Pick_Release_PVT.Process_Reservations');
            END IF;
            l_sec_quantity_to_detail  := l_sec_quantity_to_detail * (l_quantity_to_detail / l_orig_quantity_to_detail);
        END IF; /* IF (l_non_inv_reservations_qty > 0 AND l_quantity_to_detail > l_reserved_quantity */   -- Bug 3440014

        -- Expired lots custom hook
        IF inv_pick_release_pub.g_pick_expired_lots THEN
            l_exp_date := NULL;
        ELSE
            l_exp_date := SYSDATE;
        END IF;

        -- Handle reserving additional quantity if necessary
        IF l_reserved_quantity < l_quantity_to_detail THEN
            l_unreserved_quantity  := l_quantity_to_detail - l_reserved_quantity;
            l_sec_unreserved_quantity  := l_sec_quantity_to_detail - l_sec_reserved_quantity;
            IF (is_debug) THEN
               print_debug('l_unreserved_quantity is '|| l_unreserved_quantity,'Inv_Pick_Release_PVT.Process_Reservations');
               print_debug('l_sec_unreserved_quantity is '|| l_sec_unreserved_quantity,'Inv_Pick_Release_PVT.Process_Reservations');
            END IF;

            IF  p_mo_line_rec.from_subinventory_code IS NOT NULL  AND g_sub_reservable_type = 1 THEN
                source_from_sub        := p_mo_line_rec.from_subinventory_code;
                l_is_lot_control       := FALSE;
                l_is_revision_control  := FALSE;

                IF p_mo_line_rec.from_locator_id IS NOT NULL THEN
                    source_from_loc        := p_mo_line_rec.from_locator_id;
                END IF;
            END IF;

            -- Call quantity tree to obtain the quantity available to reserve
            -- Bug 1890424 - pass in expiration date of sysdate. Expired lots
            -- shouldn't appear as available
            -- Added following secondary qty related section for Bug 7377744

            inv_quantity_tree_pub.query_quantities(
                  p_api_version_number         => 1.0
                , p_init_msg_lst               => fnd_api.g_false
                , x_return_status              => l_api_return_status
                , x_msg_count                  => x_msg_count
                , x_msg_data                   => x_msg_data
                , p_organization_id            => p_mo_line_rec.organization_id
                , p_inventory_item_id          => p_mo_line_rec.inventory_item_id
                , p_tree_mode                  => inv_quantity_tree_pub.g_reservation_mode
                , p_is_revision_control        => l_is_revision_control
                , p_is_lot_control             => l_is_lot_control
                , p_is_serial_control          => l_is_serial_control
                , p_demand_source_type_id      => p_demand_source_type
                , p_demand_source_header_id    => p_mso_line_id
                , p_demand_source_line_id      => p_demand_info.oe_line_id
                , p_demand_source_name         => p_demand_source_name
                , p_revision                   => NULL
                , p_lot_number                 => NULL
                , p_lot_expiration_date        => l_exp_date
                , p_subinventory_code          => source_from_sub
                , p_locator_id                 => source_from_loc
                , x_qoh                        => l_qty_on_hand
                , x_rqoh                       => l_qty_res_on_hand
                , x_qr                         => l_qty_res
                , x_qs                         => l_qty_sug
                , x_att                        => l_qty_att
                , x_atr                        => l_qty_available_to_reserve

                , p_grade_code                 => l_grade_code
                , x_sqoh                       => l_sec_qty_on_hand
                 , x_srqoh                      => l_sec_qty_res_on_hand
                 , x_sqr                        => l_sec_qty_res
                 , x_sqs                        => l_sec_qty_sug
                 , x_satt                       => l_sec_qty_att
                 , x_satr                       => l_sec_qty_available_to_reserve
                );
            IF (is_debug) THEN
               print_debug('Reservable qty  from qtytree '|| l_qty_available_to_reserve, 'Inv_Pick_Release_PVT.Process_Reservations');
               print_debug('Reservable qty2 from qtytree '|| l_sec_qty_available_to_reserve, 'Inv_Pick_Release_PVT.Process_Reservations');
            END IF;

            IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
              IF (is_debug) THEN
                 print_debug('Error from query quantity tree', 'Inv_Pick_Release_PVT.Process_Reservations');
              END IF;
              fnd_message.set_name('INV', 'INV_QRY_QTY_FAILED');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (is_debug) THEN
                print_debug('l_qty_available_to_reserve = '||l_qty_available_to_reserve||', l_qty_att = '||l_qty_att||', p_demand_source_type = '||p_demand_source_type, 'Inv_Pick_Release_PVT.Process_Reservations');
            END IF;

            --Bug 8560030, added below code in order to allow picking of non-rsvable lots for Internal Orders.
            IF (l_qty_available_to_reserve <= 0 AND l_qty_att > 0 AND p_demand_source_type = 8 AND l_is_lot_control) THEN
                IF g_prf_pick_nonrsv_lots IS NULL THEN
                    g_prf_pick_nonrsv_lots := NVL(FND_PROFILE.VALUE('INV_PICK_NONRSV_LOTS'),2);
                    IF (is_debug) THEN
                        print_debug('g_prf_pick_nonrsv_lots = '||g_prf_pick_nonrsv_lots, 'Inv_Pick_Release_PVT.Process_Reservations');
                    END IF;
                END IF;
                IF g_prf_pick_nonrsv_lots = 1 THEN
                    g_pick_nonrsv_lots := 1;
                END IF;
            END IF;

            l_quantity_to_reserve  := l_unreserved_quantity;
            l_sec_quantity_to_reserve  := l_sec_unreserved_quantity;

            IF l_qty_available_to_reserve < l_unreserved_quantity THEN
              l_quantity_to_reserve  := l_qty_available_to_reserve;
              l_sec_quantity_to_reserve := l_sec_qty_available_to_reserve; -- Bug 7377744
              -- Backorder cache. If sufficient quantity is not available then add item to backorder cache
              IF source_from_sub IS NULL THEN
                 g_backorder_cache(p_mo_line_rec.inventory_item_id) := p_mo_line_rec.organization_id;
              END IF;
            END IF;

            IF l_quantity_to_reserve > 0 THEN
              x_rsv_qty_available  := l_quantity_to_reserve;
             x_rsv_qty2_available  := l_sec_quantity_to_reserve; --Bug #7377744

              -- Since there is unreserved quantity which can be reserved, create
              -- or update an org-level reservation for the remaining quantity.
                IF l_org_wide_res_id <> -1 THEN
                /*
                    -- Update the existing reservation
                    l_res_ordered_index                            := l_demand_rsvs_ordered.LAST;
                    l_qry_rsv_rec                                  := l_demand_rsvs_ordered(l_res_ordered_index);
                    l_update_rsv_rec                               := l_qry_rsv_rec;
                    l_update_rsv_rec.primary_reservation_quantity  := l_update_rsv_rec.primary_reservation_quantity + l_quantity_to_reserve;
                    l_update_rsv_rec.reservation_quantity          := NULL; -- Force update of reserved qty
                    IF (is_debug) THEN
                       print_debug('Org wide reservation exist', 'Inv_Pick_Release_PVT.Process_Reservations');
                       print_debug('update reservation', 'Inv_Pick_Release_PVT.Process_Reservations');
                    END IF;
                    inv_reservation_pub.update_reservation(
                      p_api_version_number         => 1.0
                    , p_init_msg_lst               => fnd_api.g_false
                    , x_return_status              => l_api_return_status
                    , x_msg_count                  => x_msg_count
                    , x_msg_data                   => x_msg_data
                    , p_original_rsv_rec           => l_qry_rsv_rec
                    , p_to_rsv_rec                 => l_update_rsv_rec
                    , p_original_serial_number     => l_dummy_sn
                    , p_to_serial_number           => l_dummy_sn
                    , p_validation_flag            => fnd_api.g_true
                    );

                    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                      IF (is_debug) THEN
                         print_debug('error in update reservation', 'Inv_Pick_Release_PVT.Process_Reservations');
                      END IF;
                      fnd_message.set_name('INV', 'INV_UPD_RSV_FAILED');
                      fnd_msg_pub.ADD;
                      RAISE fnd_api.g_exc_unexpected_error;
                    ELSE
                      --Requery the reservation record and update it in the local table.
                      IF (is_debug) THEN
                         print_debug('query that reservation again',
                        'Inv_Pick_release_pvt.Process_Reservations');
                      END IF;
                      l_qry_rsv_rec_by_id.reservation_id := l_update_rsv_rec.reservation_id;
                      inv_reservation_pub.query_reservation(
                        p_api_version_number         => 1.0
                      , p_init_msg_lst               => fnd_api.g_true
                      , x_return_status              => l_api_return_status
                      , x_msg_count                  => x_msg_count
                      , x_msg_data                   => x_msg_data
                      , p_query_input                => l_qry_rsv_rec_by_id
                      , x_mtl_reservation_tbl        => l_demand_reservations
                      , x_mtl_reservation_tbl_count  => l_reservation_count_by_id
                      , x_error_code                 => l_api_error_code
                      );

                      -- Return an error if the query reservations call failed
                      IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                        fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
                        fnd_msg_pub.ADD;
                        RAISE fnd_api.g_exc_unexpected_error;
                      END IF;

                      l_res_tbl_index            := l_demand_reservations.FIRST;
                      l_demand_rsvs_ordered(l_res_ordered_index) := l_demand_reservations(l_res_tbl_index);
                    END IF;
                    */
                    --update quantity tree
                    IF is_debug THEN
                      print_debug('updating quantity tree','Inv_Pick_Release_PVT.Process_Reservations');
                    END IF;

                    -- Added following secondary qty related section for Bug 7377744
                    inv_quantity_tree_pub.update_quantities(
                        p_api_version_number         => 1.0
                      , p_init_msg_lst               => fnd_api.g_false
                      , x_return_status              => l_api_return_status
                      , x_msg_count                  => x_msg_count
                      , x_msg_data                   => x_msg_data
                      , p_organization_id            => p_mo_line_rec.organization_id
                      , p_inventory_item_id          => p_mo_line_rec.inventory_item_id
                      , p_tree_mode          => inv_quantity_tree_pub.g_reservation_mode
                      , p_is_revision_control        => l_is_revision_control
                      , p_is_lot_control             => l_is_lot_control
                      , p_is_serial_control          => l_is_serial_control
                      , p_demand_source_type_id      => p_demand_source_type
                      , p_demand_source_header_id    => p_mso_line_id
                      , p_demand_source_line_id      => p_demand_info.oe_line_id
                      , p_demand_source_name         => p_demand_source_name
                      , p_revision                   => NULL
                      , p_lot_number                 => NULL
                      , p_lot_expiration_date        => l_exp_date
                      , p_subinventory_code          => NULL
                      , p_locator_id                 => NULL
                      , p_primary_quantity         => l_quantity_to_reserve
                       , p_secondary_quantity         => l_sec_quantity_to_reserve      -- Bug 7377744
                      , p_quantity_type         => inv_quantity_tree_pub.g_qr_same_demand
                      , x_qoh                        => l_qty_on_hand
                      , x_rqoh                       => l_qty_res_on_hand
                      , x_qr                         => l_qty_res
                      , x_qs                         => l_qty_sug
                      , x_att                        => l_qty_att
                      , x_atr                        => l_qty_available_to_reserve


                     , p_grade_code                 => l_grade_code
                     , x_sqoh                       => l_sec_qty_on_hand
                     , x_srqoh                      => l_sec_qty_res_on_hand
                     , x_sqr                        => l_sec_qty_res
                     , x_sqs                        => l_sec_qty_sug
                     , x_satt                       => l_sec_qty_att
                     , x_satr                       => l_sec_qty_available_to_reserve
                    );
                    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                      IF (is_debug) THEN
                        print_debug('Error from query quantity tree', 'Inv_Pick_Release_PVT.Process_Reservations');
                      END IF;
                      fnd_message.set_name('INV', 'INV_QRY_QTY_FAILED');
                      fnd_msg_pub.ADD;
                      RAISE fnd_api.g_exc_unexpected_error;
                    END IF;

                    --find new reservation quantities
                    l_index := l_demand_rsvs_ordered.LAST;
                    l_new_prim_rsv_quantity := l_demand_rsvs_ordered(l_index).primary_reservation_quantity
                                             + l_quantity_to_reserve;

                    l_new_sec_rsv_quantity :=  l_demand_rsvs_ordered(l_index).secondary_reservation_quantity
                                            + l_sec_quantity_to_reserve;

                    --handle conversion to reservation UOM
                    IF l_demand_rsvs_ordered(l_index).reservation_uom_code IS NULL
                      THEN
                        --when missing rsv UOM, assume primary UOM
                        l_new_rsv_quantity := l_new_prim_rsv_quantity;
                    ELSIF l_demand_rsvs_ordered(l_index).reservation_uom_code =
                        l_primary_uom THEN
                        --reservation UOM = primary UOM
                        l_new_rsv_quantity := l_new_prim_rsv_quantity;
                    ELSE
                        l_new_rsv_quantity  := inv_convert.inv_um_convert(
                              item_id                 => p_mo_line_rec.inventory_item_id
                            , PRECISION               => NULL
                            , from_quantity           => l_new_prim_rsv_quantity
                            , from_unit               => l_primary_uom
                            , to_unit                 => l_demand_rsvs_ordered(l_index).reservation_uom_code
                            , from_name               => NULL
                            , to_name                 => NULL
                          );

                        IF (l_new_rsv_quantity = -99999) THEN
                          IF (is_debug) THEN
                            print_debug('Cannot convert primary uom to rsv uom', 'Inv_Pick_release_pvt.process_reservations');
                          END IF;
                          fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
                          fnd_message.set_token('UOM', l_primary_uom);
                          fnd_message.set_token('ROUTINE', 'Pick Release process');
                          fnd_msg_pub.ADD;
                          RAISE fnd_api.g_exc_unexpected_error;
                        END IF;
                    END IF;
                    IF (is_debug) THEN
                      print_debug('0 New prim rsv qty: ' || l_new_prim_rsv_quantity, 'Inv_Pick_Release_PVT.Process_Reservations');
                      print_debug('New rsv qty: ' || l_new_rsv_quantity, 'Inv_Pick_Release_PVT.Process_Reservations');
                      print_debug('New sec rsv qty: ' || l_new_sec_rsv_quantity, 'Inv_Pick_Release_PVT.Process_Reservations');
                    END IF;

                    UPDATE mtl_reservations
                       SET primary_reservation_quantity = l_new_prim_rsv_quantity
                          ,reservation_quantity = l_new_rsv_quantity
                          ,secondary_reservation_quantity =  l_new_sec_rsv_quantity
                     WHERE reservation_id = l_org_wide_res_id;

                    inv_rsv_synch.for_update(
                      p_reservation_id => l_org_wide_res_id
                    , x_return_status => l_api_return_status
                    , x_msg_count => x_msg_count
                    , x_msg_data => x_msg_data);

                    IF l_api_return_status = fnd_api.g_ret_sts_error THEN
                      IF (is_debug) THEN
                        print_debug('Error from inv_rsv_synch.for_update', 'Inv_Pick_Release_PVT.Process_Reservations');
                      END IF;
                      RAISE fnd_api.g_exc_error;
                    END IF;
                    --
                    IF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
                      IF (is_debug) THEN
                        print_debug('Unexp. error from inv_rsv_synch.for_update', 'Inv_Pick_Release_PVT.Process_Reservations');
                      END IF;
                      RAISE fnd_api.g_exc_unexpected_error;
                    END IF;

                    l_demand_rsvs_ordered(l_index).primary_reservation_quantity := l_new_prim_rsv_quantity;
                    l_demand_rsvs_ordered(l_index).secondary_reservation_quantity := l_new_sec_rsv_quantity;
                    l_demand_rsvs_ordered(l_index).reservation_quantity := l_new_rsv_quantity;

                ELSIF ( l_lot_divisible_flag = 'Y') THEN
                    -- If no org-wide reservation existed before, created one now.
                    IF (is_debug) THEN
                       print_debug('no org-wide reservation exist, need to create one',
                            'Inv_Pick_Release_Pvt.Process_Reservations');
                    END IF;
                    l_update_rsv_rec.reservation_id             := NULL; -- cannot know
                    l_update_rsv_rec.requirement_date           := SYSDATE;
                    l_update_rsv_rec.organization_id            :=  p_mo_line_rec.organization_id;
                    l_update_rsv_rec.inventory_item_id          :=p_mo_line_rec.inventory_item_id;
                    l_update_rsv_rec.demand_source_type_id      := p_demand_source_type;
                    l_update_rsv_rec.demand_source_name      := p_demand_source_name;
                    --INV_Reservation_Global.g_source_type_oe; -- order entry
                    l_update_rsv_rec.demand_source_header_id       := p_mso_line_id;
                    l_update_rsv_rec.demand_source_line_id         := p_demand_info.oe_line_id;
                    l_update_rsv_rec.demand_source_delivery        := NULL;
                    l_update_rsv_rec.primary_uom_code              := l_primary_uom;
                    l_update_rsv_rec.secondary_uom_code            := l_secondary_uom;
                    l_update_rsv_rec.primary_uom_id                := NULL;
                    l_update_rsv_rec.secondary_uom_id              := NULL;
                    l_update_rsv_rec.reservation_uom_code          := NULL;
                    l_update_rsv_rec.reservation_uom_id            := NULL;
                    l_update_rsv_rec.reservation_quantity          := NULL;
                    l_update_rsv_rec.primary_reservation_quantity  := l_quantity_to_reserve;
                    l_update_rsv_rec.secondary_reservation_quantity  := l_sec_quantity_to_reserve;
                    --l_update_rsv_rec.grade_code                      := l_grade_code;
                    l_update_rsv_rec.autodetail_group_id           := NULL;
                    l_update_rsv_rec.external_source_code          := NULL;
                    l_update_rsv_rec.external_source_line_id       := NULL;
                    l_update_rsv_rec.supply_source_type_id         := inv_reservation_global.g_source_type_inv;
                    l_update_rsv_rec.supply_source_header_id       := NULL;
                    l_update_rsv_rec.supply_source_line_id         := NULL;
                    l_update_rsv_rec.supply_source_name            := NULL;
                    l_update_rsv_rec.supply_source_line_detail     := NULL;
                    l_update_rsv_rec.revision                      := NULL;
                    l_update_rsv_rec.subinventory_code             := NULL;
                    l_update_rsv_rec.subinventory_id               := NULL;
                    l_update_rsv_rec.locator_id                    := NULL;
                    l_update_rsv_rec.lot_number                    := NULL;
                    l_update_rsv_rec.lot_number_id                 := NULL;
                    l_update_rsv_rec.pick_slip_number              := NULL;
                    l_update_rsv_rec.lpn_id                        := NULL;
                    l_update_rsv_rec.attribute_category            := NULL;
                    l_update_rsv_rec.attribute1                    := NULL;
                    l_update_rsv_rec.attribute2                    := NULL;
                    l_update_rsv_rec.attribute3                    := NULL;
                    l_update_rsv_rec.attribute4                    := NULL;
                    l_update_rsv_rec.attribute5                    := NULL;
                    l_update_rsv_rec.attribute6                    := NULL;
                    l_update_rsv_rec.attribute7                    := NULL;
                    l_update_rsv_rec.attribute8                    := NULL;
                    l_update_rsv_rec.attribute9                    := NULL;
                    l_update_rsv_rec.attribute10                   := NULL;
                    l_update_rsv_rec.attribute11                   := NULL;
                    l_update_rsv_rec.attribute12                   := NULL;
                    l_update_rsv_rec.attribute13                   := NULL;
                    l_update_rsv_rec.attribute14                   := NULL;
                    l_update_rsv_rec.attribute15                   := NULL;
                    l_update_rsv_rec.ship_ready_flag               := 2;
                    --      l_update_rsv_rec.n_column1                    := NULL;
                    l_update_rsv_rec.detailed_quantity             := 0;
                    IF (is_debug) THEN
                       print_debug('create new reservation', 'Inv_Pick_Release_PVT.Process_Reservations');
                    END IF;
                    inv_reservation_pub.create_reservation(
                      p_api_version_number         => 1.0
                    , p_init_msg_lst               => fnd_api.g_false
                    , x_return_status              => l_api_return_status
                    , x_msg_count                  => x_msg_count
                    , x_msg_data                   => x_msg_data
                    , p_rsv_rec                    => l_update_rsv_rec
                    , p_serial_number              => l_dummy_sn
                    , x_serial_number              => l_dummy_sn
                    , p_partial_reservation_flag   => fnd_api.g_true
                    , p_force_reservation_flag     => fnd_api.g_false
                    , p_validation_flag            => 'Q'
                    , x_quantity_reserved          => l_qty_succ_reserved
                    , x_reservation_id             => l_org_wide_res_id
                    , p_over_reservation_flag      => 2  -- Bug 5365200 Passing p_over_reservation_flag to allow reservation of demand for overpicking case
                    );

                    -- Return an error if the create reservation call failed
                    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                      IF (is_debug) THEN
                         print_debug('error in create reservation', 'Inv_Pick_Release_PVT.Process_Reservations');
                      END IF;
                      fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
                      fnd_msg_pub.ADD;
                      RAISE fnd_api.g_exc_unexpected_error;
                    END IF;

                    -- If partial picking is not allowed and the full quantity could no
                    -- be reserved, return an error.
                    IF  p_allow_partial_pick = fnd_api.g_false
                        AND l_qty_succ_reserved < l_quantity_to_reserve THEN
                      IF (is_debug) THEN
                         print_debug('p_allow_partial_pick is false and could not reserve the quantity requested'
                            , 'Inv-Pick_Release_PVT.Process_Reservations');
                      END IF;
                      fnd_message.set_name('INV', 'INV_COULD_NOT_PICK_FULL');
                      fnd_msg_pub.ADD;
                      RAISE fnd_api.g_exc_unexpected_error;
                    END IF;

                    -- Query up the reservation which was just created and add it to the
                    -- filtered table.
                    l_qry_rsv_rec_by_id.reservation_id        := l_org_wide_res_id;
                    inv_reservation_pub.query_reservation(
                      p_api_version_number         => 1.0
                    , p_init_msg_lst               => fnd_api.g_true
                    , x_return_status              => l_api_return_status
                    , x_msg_count                  => x_msg_count
                    , x_msg_data                   => x_msg_data
                    , p_query_input                => l_qry_rsv_rec_by_id
                    , x_mtl_reservation_tbl        => l_demand_reservations
                    , x_mtl_reservation_tbl_count  => l_reservation_count_by_id
                    , x_error_code                 => l_api_error_code
                    );

                    -- Return an error if the query reservations call failed
                    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                      fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
                      fnd_msg_pub.ADD;
                      RAISE fnd_api.g_exc_unexpected_error;
                    END IF;

                    -- Add the retrieved reservation to the filtered table
                    l_res_tbl_index         := l_demand_reservations.FIRST;
                    l_res_ordered_index     := NVL(l_demand_rsvs_ordered.LAST, 0) + 1;
                    l_demand_rsvs_ordered(l_res_ordered_index) := l_demand_reservations(l_res_tbl_index);
                    -- Update with the actual  reservation quantity
                    x_rsv_qty_available := l_demand_reservations(l_res_tbl_index).primary_reservation_quantity;
                    IF (is_debug) THEN
                       print_debug('Reservation created for: '|| x_rsv_qty_available, 'Inv-Pick_Release_PVT.Process_Reservations');
                    END IF; -- debug on
                END IF; -- An org-wide reservation existed
            END IF; -- The quantity to reserve was > 0
        END IF; --l_reserved_quantity < l_quantity_to_detail
    END IF; -- If the sub is reservable

    --Bug 2972143 Changes, filtering out already allocated reservations from l_demand_rsvs_ordered table.
    --before passing the table to create suggestions API.

    l_reservation_count := NVL(l_demand_rsvs_ordered.count,0);

    IF (is_debug) then
       print_debug('l_reservation_count = '|| l_reservation_count, 'Inv-Pick_Release_PVT.Process_Reservations');
    END IF;

    IF  (l_reservation_count > 0) THEN
        l_res_tbl_index := l_demand_rsvs_ordered.FIRST;
        l_res_ordered_index := l_demand_rsvs_ordered.FIRST;
        IF (is_debug) then
          print_debug('Checking for Serial Reservations ', 'Inv-Pick_Release_PVT.Process_Reservations');
        END IF;
        LOOP
            IF ( nvl(l_demand_rsvs_ordered(l_res_tbl_index).primary_reservation_quantity,0)
              - nvl(l_demand_rsvs_ordered(l_res_tbl_index).detailed_quantity,0) > 0) THEN

                -- Bug 5535030: fetch from get_rsv_serials only for serial controlled items
                IF (INV_CACHE.set_item_rec( p_mo_line_rec.organization_id, p_mo_line_rec.inventory_item_id)) THEN
                    IF INV_CACHE.item_rec.serial_number_control_code NOT IN (1,6) THEN
                        l_rsv_serials.DELETE;
                        OPEN get_rsv_serials(l_demand_rsvs_ordered(l_res_tbl_index).reservation_id);
                        FETCH get_rsv_serials bulk collect INTO l_rsv_serials;
                        CLOSE get_rsv_serials;
                    END IF;
                END IF;

                IF (is_debug) then
                  print_debug('Serial Count = '|| l_rsv_serials.count, 'Inv-Pick_Release_PVT.Process_Reservations');
                  print_debug('Subinventory :  '|| l_demand_rsvs_ordered(l_res_tbl_index).subinventory_code, 'Inv-Pick_Release_PVT.Process_Reservations');
                END IF;
                -- {{ Test Case # UTK-REALLOC-3.2.1:40 }}
                --   Description: Single non-detailed reservation should allocate
                -- {{ Test Case # UTK-REALLOC-3.2.1:41 }}
                --   Description: Multiple non-detailed reservations should allocate
                -- {{ Test Case # UTK-REALLOC-3.2.1:42 }}
                --   Description: Reservation that is already partially allocated should not re-allocate allocated serials
                IF (nvl(l_rsv_serials.COUNT,0) = 0) OR (l_demand_rsvs_ordered(l_res_tbl_index).subinventory_code IS NULL) THEN
                  IF (is_debug) then
                     print_debug('No Serials for this reservation', 'Inv-Pick_Release_PVT.Process_Reservations');
                  END IF;
                  x_demand_rsvs_ordered(l_res_ordered_index) := l_demand_rsvs_ordered(l_res_tbl_index);
                  l_res_ordered_index := l_res_ordered_index + 1;
                ELSE
                  l_pri_sec_conv := l_demand_rsvs_ordered(l_res_tbl_index).secondary_reservation_quantity / l_demand_rsvs_ordered(l_res_tbl_index).primary_reservation_quantity;
                  -- Could use maximum of last serial and reservation quantity
                  FOR i in nvl(l_rsv_serials.FIRST,0)..nvl(l_rsv_serials.LAST,0) LOOP
                      x_demand_rsvs_ordered(l_res_ordered_index) := l_demand_rsvs_ordered(l_res_tbl_index);
                      x_demand_rsvs_ordered(l_res_ordered_index).serial_number := l_rsv_serials(i).serial_number;
                      x_demand_rsvs_ordered(l_res_ordered_index).primary_reservation_quantity := 1;
                      x_demand_rsvs_ordered(l_res_ordered_index).secondary_reservation_quantity := l_pri_sec_conv;
                      x_demand_rsvs_ordered(l_res_ordered_index).detailed_quantity := 0;
                      l_demand_rsvs_ordered(l_res_tbl_index).primary_reservation_quantity := l_demand_rsvs_ordered(l_res_tbl_index).primary_reservation_quantity - 1;
                      l_demand_rsvs_ordered(l_res_tbl_index).secondary_reservation_quantity := l_demand_rsvs_ordered(l_res_tbl_index).secondary_reservation_quantity - l_pri_sec_conv;
                      l_res_ordered_index := l_res_ordered_index + 1;
                      IF (is_debug) then
                          print_debug('Serial Number - ' || l_rsv_serials(i).serial_number, 'Inv-Pick_Release_PVT.Process_Reservations');
                          print_debug('l_res_ordered_index ' || l_res_ordered_index, 'Inv-Pick_Release_PVT.Process_Reservations');
                      END IF;
                  END LOOP;
                  -- {{ Test Case # UTK-REALLOC-3.2.1:43 }}
                  --   Description: Reservation for qty>1 with 1 serial number should allocate serial and do remainder
                  -- {{ Test Case # UTK-REALLOC-3.2.1:44 }}
                  --   Description: Reservation for qty>1 with multile serials < qty should allocate serials and do remainder
                  IF l_demand_rsvs_ordered(l_res_tbl_index).primary_reservation_quantity > 0 THEN
                     x_demand_rsvs_ordered(l_res_ordered_index) := l_demand_rsvs_ordered(l_res_tbl_index);
                     l_res_ordered_index := l_res_ordered_index + 1;
                  END IF;
                END IF;
            END IF;

            EXIT WHEN l_res_tbl_index = l_demand_rsvs_ordered.LAST;
            l_res_tbl_index := l_demand_rsvs_ordered.NEXT(l_res_tbl_index);
        End LOOP;
    END IF;
    --x_demand_rsvs_ordered := l_new_demand_rsvs_ordered;

    --x_demand_rsvs_ordered                  := l_demand_rsvs_ordered;
    IF (is_debug) THEN
       print_debug('Return from process_Reservations','Inv-Pick_Release_PVT.Process_Reservations');
       print_debug('Final Reservation Count : ' || x_demand_rsvs_ordered.count, 'Inv-Pick_Release_PVT.Process_Reservations');
       IF x_demand_rsvs_ordered.COUNT > 0 THEN
          FOR i in x_demand_rsvs_ordered.FIRST..x_demand_rsvs_ordered.LAST LOOP
              print_debug('Subinevntory code - ' || x_demand_rsvs_ordered(i).subinventory_code, 'Inv-Pick_Release_PVT.Process_Reservations');
              print_debug('Locator - ' || x_demand_rsvs_ordered(i).locator_id, 'Inv-Pick_Release_PVT.Process_Reservations');
              print_debug('Lot - ' || x_demand_rsvs_ordered(i).lot_number, 'Inv-Pick_Release_PVT.Process_Reservations');
              print_debug('Serial Number - ' || x_demand_rsvs_ordered(i).serial_number, 'Inv-Pick_Release_PVT.Process_Reservations');
          END LOOP;
       END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'INV_PICK_RELEASE_PVT');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      GMI_RESERVATION_UTIL.println('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
  END;

  PROCEDURE process_unreservable_items(
    x_return_status    OUT    NOCOPY VARCHAR2
  , x_msg_count        OUT    NOCOPY NUMBER
  , x_msg_data         OUT    NOCOPY VARCHAR2
  , x_pick_slip_number OUT    NOCOPY NUMBER
  , x_ready_to_print   OUT    NOCOPY VARCHAR2
  , x_call_mode        OUT    NOCOPY VARCHAR2
  , p_mo_line_rec      IN OUT NOCOPY     inv_move_order_pub.trolin_rec_type
  , p_demand_info      IN     wsh_inv_delivery_details_v%ROWTYPE
  , p_grouping_rule_id IN     NUMBER
  , p_pick_slip_mode   IN     VARCHAR2
  , p_print_mode       IN     VARCHAR2
  ) IS
    l_shipping_attr        wsh_interface.changedattributetabtype;
    l_report_set_id        NUMBER;
    l_request_number       VARCHAR2(80);
    l_return_status        VARCHAR2(1);
    l_pick_slip_number     NUMBER;
    l_ready_to_print       VARCHAR2(1);
    l_api_error_msg        VARCHAR2(2000);
    l_default_subinventory VARCHAR2(10)                          := fnd_api.g_miss_char;
    l_default_locator_id   NUMBER                                := fnd_api.g_miss_num;
    l_call_mode            VARCHAR2(1);

    --8430412 add for getting revision
    l_revision_control     NUMBER;
    l_rule_id              NUMBER;
    l_revision_rule        NUMBER;
    l_order_by             VARCHAR2(1000);
    l_base_stmt            VARCHAR2(2000);
    l_stmt                 VARCHAR2(2000);
    l_revision             VARCHAR2(3);
    l_txn_date             DATE;
    --8430412

  BEGIN
    IF (is_debug) THEN
       print_debug('Inside Process_Unreservable', 'Inv_Pick_Release_PVT.Process_Unreservable_Items');
    END IF;
    x_return_status                        := fnd_api.g_ret_sts_success;

    /* bug 1560334 jxlu  */

   IF g_organization_id IS NOT NULL and
      g_organization_id = p_mo_line_rec.organization_id and
      g_inventory_item_id IS NOT NULL and
      g_inventory_item_id = p_mo_line_rec.inventory_item_id and
      g_default_subinventory IS NOT NULL THEN

     l_default_subinventory := g_default_subinventory;
   ELSE
     BEGIN
      SELECT subinventory_code
        INTO l_default_subinventory
        FROM mtl_item_sub_defaults
       WHERE inventory_item_id = p_mo_line_rec.inventory_item_id
         AND organization_id = p_mo_line_rec.organization_id
         AND default_type = 1;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
     END;

     g_organization_id := p_mo_line_rec.organization_id;
     g_inventory_item_id := p_mo_line_rec.inventory_item_id;
     g_default_subinventory := l_default_subinventory;
     g_default_locator_id := -1;

   END IF;

   IF g_default_locator_id IS NOT NULL AND
      g_default_locator_id = -1 THEN

     BEGIN
        SELECT locator_id
          INTO l_default_locator_id
          FROM mtl_item_loc_defaults
         WHERE inventory_item_id = p_mo_line_rec.inventory_item_id
           AND organization_id = p_mo_line_rec.organization_id
           AND subinventory_code = l_default_subinventory
           AND default_type = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
      l_default_locator_id := NULL;
          NULL;
     END;

     g_default_locator_id := l_default_locator_id;

   ELSE
     l_default_locator_id := g_default_locator_id;
   END IF;

    IF (is_debug) THEN
       print_debug('Default Sub is'|| l_default_subinventory, 'Inv_Pick_Release_PVT.Process_Unreservable_Items');
       print_debug('Default Loc is'|| l_default_locator_id, 'Inv_Pick_Release_PVT.Process_Unreservable_Items');
    END IF;

    -- 8430412 begin added the following logic to get revision for non-reservable item.
    IF nvl(inv_cache.item_rec.revision_qty_control_code,1) = 2 THEN  -- revision controlled
       IF (is_debug) THEN
          print_debug('Revision_ctrl: '||inv_cache.item_rec.revision_qty_control_code,'Inv_Pick_Release_PVT.Process_Unreservable_Items');
       END IF;

       l_rule_id := inv_cache.item_rec.picking_rule_id;

       IF l_rule_id is NULL THEN
          IF inv_cache.set_org_rec(g_organization_id) THEN
             l_rule_id := inv_cache.org_rec.default_picking_rule_id;
          ELSE
             l_rule_id := NULL;
          END IF;
       END IF;

       IF (is_debug) THEN
          print_debug('Default picking rule id: '|| l_rule_id, 'Inv_Pick_Release_PVT.Process_Unreservable_Items');
       END IF;

       IF l_rule_id is not NULL THEN

          SELECT revision_sort
            INTO l_revision_rule
            FROM mtl_inv_picking_rules
           WHERE wms_rule_id = l_rule_id;

       END IF;

       IF (is_debug) THEN
          print_debug('Revision Sort: '|| l_revision_rule, 'Inv_Pick_Release_PVT.Process_Unreservable_Items');
       END IF;

       IF l_revision_rule is not NULL THEN
          CASE l_revision_rule
             WHEN 1 THEN
                  l_order_by := 'order by mir.revision ASC';
             WHEN 2 THEN
                  l_order_by := 'order by mir.revision DESC';
             WHEN 3 THEN
                  l_order_by := 'order by mir.effectivity_date ASC';
             WHEN 4 THEN
                  l_order_by := 'order by mir.effectivity_date DESC';
          END CASE;

          l_base_stmt := 'SELECT mir.revision FROM mtl_item_revisions mir '
                       ||' WHERE mir.organization_id = :org_id '
                       ||'   AND mir.inventory_item_id = :item_id '
                       ||'   AND mir.effectivity_date <= SYSDATE '
                       ||l_order_by;

          l_stmt := 'SELECT revision FROM ('||l_base_stmt
                  ||' ) where rownum=1 ';

          EXECUTE IMMEDIATE l_stmt INTO l_revision USING p_mo_line_rec.organization_id, p_mo_line_rec.inventory_item_id;

          IF (is_debug) THEN
             print_debug('Revision : '|| l_revision, 'Inv_Pick_Release_PVT.Process_Unreservable_Items');
          END IF;

       ELSE  --revision sort not defined

         l_txn_date :=  nvl(inv_cache.mo_transaction_date, SYSDATE);

         IF (is_debug) THEN
            print_debug('call bom_revisions.get_revision to get revsion, revision date = '||l_txn_date, 'Inv_Pick_Release_PVT.Process_Unreservable_Items');
         END IF;

         bom_revisions.GET_REVISION (type => 'PART'
                                     ,org_id => p_mo_line_rec.organization_id
                                     ,item_id => p_mo_line_rec.inventory_item_id
                                     ,rev_date => l_txn_date
                                     ,itm_rev => l_revision);

         IF (is_debug) THEN
            print_debug('Revision  : '||l_revision, 'Inv_Pick_Release_PVT.Process_Unreservable_Items');
         END IF;

       END IF;
    END IF;  -- revision ctrl

    -- end 8430412

    l_shipping_attr(1).subinventory        := l_default_subinventory;
    l_shipping_attr(1).locator_id          := l_default_locator_id;
    /*end of bug 1560334  jxlu */
    l_shipping_attr(1).source_header_id    := p_demand_info.oe_header_id;
    l_shipping_attr(1).source_line_id      := p_demand_info.oe_line_id;
    l_shipping_attr(1).ship_from_org_id    := p_mo_line_rec.organization_id;
    l_shipping_attr(1).released_status     := 'Y';
    l_shipping_attr(1).delivery_detail_id  := p_demand_info.delivery_detail_id;
    l_shipping_attr(1).action_flag         := 'U';
    l_shipping_attr(1).revision            := l_revision;  --8430412
    IF (is_debug) THEN
       print_debug('Calling WSH_Interface.Update_Shipping_Attributes',
          'Inv_Pick_Release_PVT.Process_Unreservable_Items');
    END IF;
    wsh_interface.update_shipping_attributes(
      p_source_code                => 'INV'
    , p_changed_attributes         => l_shipping_attr
    , x_return_status              => l_return_status
    );
    IF (is_debug) THEN
       print_debug('after update shipping attributes',
          'Inv_Pick_Release_Pvt.Process_Unreservable_Items');
    END IF;

    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
      IF (is_debug) THEN
         print_debug('return error from update shipping attributes',
            'Inv_Pick_Release_Pvt.Process_Unreservable_Items');
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      IF (is_debug) THEN
         print_debug('return error from update shipping attributes',
             'Inv_Pick_Release_Pvt.Process_Unreservable_Items');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- call the get pick slip number

    IF (is_debug) THEN
       print_debug('calling get_pick_slip_number',
           'Inv_Pick_Release_Pvt.Process_Unreservable_Items');
    END IF;
    -- Bug 2666620: Inline branching to call either WSH or INV get_pick_slip_number
    /* FP-J PAR Replenishment Counts: It is not required to send dest_subinv,
       dest_locator_id, project_id and task_id. Dest Sub / Loc not required because
       the item is non-reservable, project and task not required because we are
       not sending input parameters from_locator/to_locator. */
    get_pick_slip_number(
      p_ps_mode                    => p_pick_slip_mode
    , p_pick_grouping_rule_id      => p_grouping_rule_id
    , p_org_id                     => p_mo_line_rec.organization_id
    , p_header_id                  => p_demand_info.oe_header_id
    , p_customer_id                => p_demand_info.customer_id
    , p_ship_method_code           => p_demand_info.freight_code
    , p_ship_to_loc_id             => p_demand_info.ship_to_location
    , p_shipment_priority          => p_demand_info.shipment_priority_code
    , p_subinventory               => NULL
    , p_trip_stop_id               => p_demand_info.trip_stop_id
    , p_delivery_id                => p_demand_info.shipping_delivery_id
    , x_pick_slip_number           => l_pick_slip_number
    , x_ready_to_print             => l_ready_to_print
    , x_api_status                 => l_return_status
    , x_error_message              => l_api_error_msg
    , x_call_mode                  => l_call_mode
    , p_inventory_item_id          => p_mo_line_rec.inventory_item_id
    , p_revision                   => p_mo_line_rec.revision
    );
    IF (is_debug) THEN
       print_debug('after calling get_pick_slip_number',
           'Inv_Pick_Release_Pvt.Process_Unreservable_Items');
    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success
       OR l_pick_slip_number = -1 THEN
      IF (is_debug) THEN
         print_debug('return error from get_pick_slip_number',
             'Inv_Pick_Release_Pvt.Process_Unreservable_Items');
      END IF;
      fnd_message.set_name('INV', 'INV_NO_PICK_SLIP_NUMBER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    if ( p_pick_slip_mode <> 'I' ) then
       WSH_INV_INTEGRATION_GRP.find_printer
       ( p_subinventory    => NULL
       , p_organization_id => p_mo_line_rec.organization_id
       , x_error_message   => l_api_error_msg
       , x_api_Status      => l_return_status
       );
       IF l_return_status <> fnd_api.g_ret_sts_success THEN
         IF (is_debug) THEN
            print_debug('return error from WSH_INV_INTEGRATION.find_printer',
                     'Inv_Pick_Release_Pvt.Process_Unreservable_Items');
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
       END IF;
    end if ;

    IF (is_debug) THEN
       print_debug('update move order line',
           'Inv_pick_release_pvt.process_unreservable_items');
    END IF;

    p_mo_line_rec.quantity_detailed := p_mo_line_rec.quantity;
    p_mo_line_rec.quantity_delivered := p_mo_line_rec.quantity;
    p_mo_line_rec.pick_slip_number := l_pick_slip_number;
    p_mo_line_rec.pick_slip_date := sysdate;
    p_mo_line_rec.line_status := 5;

    -- Bug 6989438
    IF (is_debug) THEN
       print_debug('p_mo_line_rec.quantity '|| p_mo_line_rec.quantity, 'Inv_Pick_Release_Pvt.Process_Unreservable_Items');
       print_debug('p_mo_line_rec.quantity '|| p_mo_line_rec.quantity, 'Inv_Pick_Release_Pvt.Process_Unreservable_Items');
    END IF;

    UPDATE mtl_txn_request_lines
       SET quantity_detailed = p_mo_line_rec.quantity,
       quantity_delivered = p_mo_line_rec.quantity,
       pick_slip_number = l_pick_slip_number,
       pick_slip_date = sysdate,
       line_status = 5,
       status_date =sysdate                               -- BUG 6932648
     WHERE line_id = p_mo_line_rec.line_id;

    x_pick_slip_number                     := l_pick_slip_number;
    x_ready_to_print                       := l_ready_to_print;
    IF (is_debug) THEN
       print_debug('end of process_unreservable_items ',
           'Inv_pick_release_pvt.process_unreservable_items');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'INV_PICK_RELEASE_PVT');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  PROCEDURE process_prj_dynamic_locator(
    p_mo_line_rec     IN OUT NOCOPY inv_move_order_pub.trolin_rec_type
  , p_mold_temp_id    IN     NUMBER
  , p_mold_sub_code   IN     VARCHAR2
  , p_from_locator_id IN     NUMBER
  , p_to_locator_id   IN     NUMBER
  , x_return_status   OUT    NOCOPY VARCHAR2
  , x_msg_count       OUT    NOCOPY NUMBER
  , x_msg_data        OUT    NOCOPY VARCHAR2
  , x_to_locator_id   OUT NOCOPY NUMBER
  , p_to_subinventory     IN     VARCHAR2 DEFAULT NULL
  ) IS
    l_org_loc_control     NUMBER;
    l_item_loc_control    NUMBER;
    l_sub_loc_control     NUMBER;
    l_reservable_type     NUMBER;
    l_sub_reservable_type NUMBER;
    l_from_locator_id     NUMBER;
    l_to_locator_id       NUMBER;
    l_new_to_locator_id   NUMBER;
    l_dummy               VARCHAR2(1);
    l_locator             inv_validate.LOCATOR;
    l_org                 inv_validate.org;
    l_sub                 inv_validate.sub;
    success               NUMBER;
    l_debug           NUMBER;
    l_return_value       BOOLEAN;
    l_to_subinventory     VARCHAR2(10);
  BEGIN
    IF is_debug IS NULL THEN
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       If l_debug = 1 Then
     is_debug := TRUE;
       Else
     is_debug := FALSE;
       End If;
    END IF;
    IF (is_debug) THEN
       print_debug('inside process_prj_dynamic_locator',
           'Inv_Pick_Release_PVt.Process_Prj_Dynamic_Locator');
    END IF;
    x_return_status  := fnd_api.g_ret_sts_success;

    IF p_to_subinventory IS NULL THEN
       l_to_subinventory := p_mo_line_rec.to_subinventory_code;
     ELSE
       l_to_subinventory := p_to_subinventory;
    END IF;

    IF (p_mo_line_rec.project_id IS NOT NULL) THEN
      IF (is_debug) THEN
         print_debug('Move ORder has project reference',
        'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
      END IF;

      l_return_value := INV_CACHE.set_org_rec(p_mo_line_rec.organization_id);
      IF NOT l_return_value THEN
     IF (is_debug) THEN
       print_debug('error setting org cache',
                   'Inv_Pick_Release_PVt.Process_Prj_Dynamic_Locator');
     END IF;
     RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      l_org_loc_control := INV_CACHE.org_rec.stock_locator_control_code;

      l_return_value := INV_CACHE.set_item_rec(
                    p_mo_line_rec.organization_id,
                p_mo_line_rec.inventory_item_id);
      IF NOT l_return_value THEN
         IF (is_debug) THEN
           print_debug('error setting item cache',
                   'Inv_Pick_Release_PVt.Process_Prj_Dynamic_Locator');
     END IF;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      l_item_loc_control := INV_CACHE.item_rec.location_control_code;

      l_return_value := INV_CACHE.set_tosub_rec(
                                p_mo_line_rec.organization_id,
                                l_to_subinventory);
      IF NOT l_return_value THEN
         IF (is_debug) THEN
           print_debug('error setting to sub cache',
                   'Inv_Pick_Release_PVt.Process_Prj_Dynamic_Locator');
     END IF;
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      l_sub_loc_control := INV_CACHE.tosub_rec.locator_type;

      IF (is_debug) THEN
         print_debug('l_org_loc_control is '|| l_org_loc_control, 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
         print_debug('l_item_loc_control is '|| l_item_loc_control, 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
         print_debug('l_sub_loc_control is '|| l_sub_loc_control, 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
      END IF;

      IF (l_org_loc_control = 3
          OR (l_org_loc_control = 4
              AND l_sub_loc_control = 3
             )
          OR (l_org_loc_control = 4
              AND l_sub_loc_control = 5
              AND l_item_loc_control = 3
             )
         ) THEN
        IF (is_debug) THEN
           print_debug('inside the locator control code',
               'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
        END IF;

        BEGIN
          SELECT *
            INTO l_locator
            FROM mtl_item_locations
           WHERE inventory_location_id = p_to_locator_id
             AND organization_id = p_mo_line_rec.organization_id
             AND subinventory_code = l_to_subinventory;
          IF (is_debug) THEN
             print_debug('after select l_locator', 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
          END IF;
          /*
          SELECT *
            INTO l_org
            FROM mtl_parameters
           WHERE organization_id = p_mo_line_rec.organization_id;

          IF (is_debug) THEN
             print_debug('after select organization', 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
          END IF;

          SELECT *
            INTO l_sub
            FROM mtl_secondary_inventories
           WHERE secondary_inventory_name = p_mo_line_rec.to_subinventory_code
             AND organization_id = p_mo_line_rec.organization_id;
      */
          IF (is_debug) THEN
             print_debug('l_locator.segment1 = '|| l_locator.segment1, 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
             print_debug('l_locator.segment2 = '|| l_locator.segment2, 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
             print_debug('l_locator.segment3 = '|| l_locator.segment3, 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
             print_debug('l_locator.segment19 = '|| l_locator.segment19, 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
             print_debug('l_locator.segment20 = '|| l_locator.segment20, 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
          END IF;

          IF (l_locator.segment19 IS NULL
              AND l_locator.segment20 IS NULL
             ) THEN
            --bug 2418676 - populate physical location id
            l_locator.physical_location_id   := l_locator.inventory_location_id;
            l_locator.inventory_location_id  := NULL;
            l_locator.project_id             := p_mo_line_rec.project_id;
            l_locator.task_id                := p_mo_line_rec.task_id;
            l_locator.segment19              := p_mo_line_rec.project_id;
            l_locator.segment20              := p_mo_line_rec.task_id;
            success := inv_validate.validatelocator(
                           p_locator          => l_locator
                         , p_org              => INV_CACHE.org_rec
                         , p_sub              => INV_CACHE.tosub_rec
                         , p_validation_mode  => inv_validate.exists_or_create
                         , p_value_or_id      => 'I'
                       );

            IF (success = inv_validate.t) THEN
              l_new_to_locator_id  := l_locator.inventory_location_id;
            ELSE
              IF (is_debug) THEN
                 print_debug('INV_Validate error', 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
              END IF;
              /*FND_MSG_PUB.Count_And_Get (p_count => l_count , p_data => l_message , p_encoded => 'T');
              if( l_count = 0 ) then
                 IF (is_debug) THEN
                    print_debug('no message from detailing engine');
                 END IF;
              elsif(l_count = 1) then
                 IF (is_debug) THEN
                    print_debug(l_message);
                 END IF;
              else
                 for i in 1..l_count LOOP
                    l_message := fnd_msg_pub.get(i, 'T');
                     IF (is_debug) THEN
                        print_debug(l_message);
                     END IF;
                 end loop;
              end if;*/
              fnd_message.set_name('INV', 'INV_INT_LOCSEGCODE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF; --success
          ELSE --no task/project
            IF (NVL(TO_NUMBER(l_locator.segment19), -1) <>   NVL(p_mo_line_rec.project_id, -1)
                AND NVL(TO_NUMBER(l_locator.segment20), -1) <>     NVL(p_mo_line_rec.task_id, -1)
               ) THEN
              fnd_message.set_name('INV', 'INV_INT_LOCCODE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF; --task project
        END;

        IF l_new_to_locator_id IS NOT NULL THEN
          IF (is_debug) THEN
             print_debug('new locator id is '|| l_new_to_locator_id,
                 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
          END IF;

      If p_mo_line_rec.to_locator_id <> l_new_to_locator_id AND
           p_mo_line_rec.to_locator_id IS NOT NULL Then

            UPDATE mtl_txn_request_lines
               SET to_locator_id = l_new_to_locator_id
             WHERE line_id = p_mo_line_rec.line_id;

        p_mo_line_rec.to_locator_id := l_new_to_locator_id;
          End If; -- update mtrl
          IF (is_debug) THEN
             print_debug('new locator id is '|| l_new_to_locator_id, 'Inv_Pick_Release_PVT.Process_Prj_Dynamic_Locator');
          END IF;  --debug
        END IF; -- new locator id is not null
      END IF; --locator controlled
    END IF;
    x_to_locator_id := NVL(l_new_to_locator_id, p_to_locator_id);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'INV_PICK_RELEASE_PVT');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  -- Start of Comments
  --
  -- Name
  --   PROCEDURE Process_Line
  --
  -- Package
  --   INV_Pick_Release_PVT
  --
  -- Purpose
  --   Pick releases the move order line passed in.  Any necessary validation is
  --   assumed to have been done by the caller.
  --
  -- Input Parameters
  --   p_mo_line_rec
  --       The Move Order Line record to pick release
  --   p_grouping_rule_id
  --       The grouping rule to use for generating pick slip numbers
  --   p_allow_partial_pick
  --      TRUE if the pick release process should continue after a line fails to
  --    be detailed completely.  FALSE if the process should stop and roll
  --    back all changes if a line cannot be fully detailed.
  --      NOTE: Printing pick slips as the lines are detailed is only supported if
  --    this parameter is TRUE, since a commit must be done before printing.
  --   p_print_mode
  --   Whether the pick slips should be printed as they are generated or not.
  --   If this is 'I' (immediate) then after a pick slip number has been returned a
  --   specified number of times (given in the shipping parameters), that pick
  --   slip will be printed immediately.
  --   If this is 'E' (deferred) then the pick slips will not be printed until the
  --   pick release process is complete.
  --
  -- Output Parameters
  --   x_return_status
  --       if the process succeeds, the value is
  --      fnd_api.g_ret_sts_success;
  --       if there is an expected error, the value is
  --             fnd_api.g_ret_sts_error;
  --       if there is an unexpected error, the value is
  --             fnd_api.g_ret_sts_unexp_error;
  --   x_msg_count
  --       if there is one or more errors, the number of error messages
  --        in the buffer
  --   x_msg_data
  --       if there is one and only one error, the error message
  --    (See fnd_api package for more details about the above output parameters)
  --
  -- Bug8757642. Added p_wave_simulation_mode with default vale 'N' for WavePlanning Project.
-- This project is available only in for R121 and mainline. To retain dual maintenance INV code changes are made in branchline, however it will not affect any existing flow.
  PROCEDURE process_line(
    p_api_version        IN     NUMBER
  , p_init_msg_list      IN     VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit             IN     VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status      OUT    NOCOPY VARCHAR2
  , x_msg_count          OUT    NOCOPY NUMBER
  , x_msg_data           OUT    NOCOPY VARCHAR2
  , p_mo_line_rec        IN OUT NOCOPY inv_move_order_pub.trolin_rec_type
  , p_grouping_rule_id   IN     NUMBER
  , p_allow_partial_pick IN     VARCHAR2 DEFAULT fnd_api.g_true
  , p_print_mode         IN     VARCHAR2
  , x_detail_rec_count   OUT    NOCOPY NUMBER
  , p_plan_tasks         IN     BOOLEAN DEFAULT FALSE
  , p_wave_simulation_mode IN VARCHAR2 DEFAULT 'N'
  ) IS
    -- Define local variables
    l_api_version     CONSTANT NUMBER       := 1.0;
    l_api_name        CONSTANT VARCHAR2(30) := 'Process_Line';
    l_demand_info              wsh_inv_delivery_details_v%ROWTYPE;
    -- All of the demand source and delivery information for the line which is being processed
    -- A local copy of the move order line record
    l_demand_rsvs_ordered      inv_reservation_global.mtl_reservation_tbl_type;
    -- The above table in descending order of detail, and with any non-matching records filtered out.
    l_mso_header_id            NUMBER; -- The MTL_SALES_ORDERS header ID, which should be derived from the OE header ID
    l_res_ordered_index        NUMBER; -- An index to the elements of the ordered and filtered reservations table.
    l_quantity_to_detail       NUMBER; -- The quantity for the move order line which should be detailed.
    l_primary_uom              VARCHAR2(3); -- The primary UOM for the item
    l_secondary_uom            VARCHAR2(3); -- The primary UOM for the item
    l_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
    l_quantity_detailed        NUMBER; -- The quantity for the current move order which was detailed (in primary UOM)
    l_sec_quantity_detailed    NUMBER; -- The quantity for the current move order which was detailed (in secondary UOM)
    l_num_detail_recs          NUMBER; -- The number of move order line details for this move order line.
    l_partially_detailed       NUMBER; -- A flag indicating whether the line could only be partially picked.  If this flag is
    -- set to 1 (yes) then a return value of success would instead be 'P' for partial.
    l_quantity_detailed_conv   NUMBER; -- The quantity detailed for the current move order (in the UOM of the move order)
    l_mold_temp_id             NUMBER; -- The transaction temp ID of the move order line detail being processed
    l_mold_sub_code            VARCHAR2(10); -- The subinventory code for the move order line detail being processed
    l_pick_slip_mode           VARCHAR2(1); -- The print pick slip mode (immediate or deferred) that should be used
    l_pick_slip_number         NUMBER; -- The pick slip number to put on the Move Order Line Details for a Line.
    l_reservation_detailed_qty NUMBER; -- The qty detailed for a reservation.
    l_rsv_detailed_qty_conv    NUMBER; -- The qty detailed for a reservation. (In reservation UOM)
    l_rsv_detailed_qty2        NUMBER; -- The qty2 detailed for a reservation.
    l_prev_rsv_detailed_qty    NUMBER; -- The existing qty detailed for a reservation.
    l_prev_rsv_detailed_qty2   NUMBER; -- The existing qty2 detailed for a reservation.
    l_ready_to_print           VARCHAR2(1); -- The flag for whether we need to commit and print after receiving
    -- the current pick slip number.
    l_api_return_status        VARCHAR2(1); -- The return status of APIs called within the Process Line API.
    l_api_error_code           NUMBER; -- The error code of APIs called within the Process Line API.
    l_api_error_msg            VARCHAR2(100); -- The error message returned by certain APIs called within Process_Line
    l_count                    NUMBER;
    l_message                  VARCHAR2(255);
    l_report_set_id            NUMBER;
    l_request_number           VARCHAR2(80);
    l_reservable_type          NUMBER;
    l_from_locator_id          NUMBER;
/* FP-J PAR Replenishment Counts: 3 new variables used in get_pick_slip_number() */
    l_dest_subinv              VARCHAR2(10);
    l_project_id               NUMBER;
    l_task_id                  NUMBER;
    l_to_locator_id            NUMBER;
    l_demand_source_type       NUMBER;
    l_debug                    NUMBER;
    l_rsv_qty_available        NUMBER      := 0;
    l_rsv_qty2_available        NUMBER      := 0; --bug#7377744 This variable will pass the secondary quantity to reserve
    l_call_mode                VARCHAR2(1); --bug 1968032 will not commit if not null when called from SE.
    l_return_value             BOOLEAN;
    l_index                    NUMBER;
    l_reservation_id           NUMBER;
    l_new_prim_rsv_quantity    NUMBER;
    l_new_sec_rsv_quantity     NUMBER := 0; -- Bug 6989438
    l_new_rsv_quantity         NUMBER;
    l_revision_control_code    NUMBER;
    l_lot_control_code         NUMBER;
    l_lot_divisible_flag       VARCHAR2(1);
    l_serial_number_control_code NUMBER;
    l_is_revision_control      BOOLEAN;
    l_is_lot_control           BOOLEAN;
    l_is_serial_control        BOOLEAN;
    l_qty_on_hand              NUMBER;
    l_qty_res_on_hand          NUMBER;
    l_qty_res                  NUMBER;
    l_qty_sug                  NUMBER;
    l_qty_att                  NUMBER;
    l_qty_available_to_reserve NUMBER;
    l_max_tolerance            NUMBER;
    l_min_tolerance            NUMBER;
    l_revision                 VARCHAR2(3);

    l_reduce_rsv_qty           NUMBER := 0; -- bug 6264551
    l_reduce_rsv_qty2          NUMBER := 0; -- bug 6989438
    l_original_rsv_record      inv_reservation_global.mtl_reservation_rec_type ;       -- for bug 7253296
    l_to_rsv_record            inv_reservation_global.mtl_reservation_rec_type ;       -- for bug 7253296

    -- Added following variables for Bug 7377744
    l_sec_qty_available_to_reserve    NUMBER; -- The quantity which can still be reserved.
    l_sec_qty_on_hand                 NUMBER; -- The org-wide quantity on-hand
    l_sec_qty_res_on_hand             NUMBER; -- The org-wide reservable quantity on-hand
    l_sec_qty_res                     NUMBER; -- The org-wide quantity reserved
    l_sec_qty_sug                     NUMBER; -- The org-wide quantity suggested
    l_sec_qty_att                     NUMBER; -- The org-wide available to transact
    l_sec_quantity_to_reserve         NUMBER; -- The additional quantity which should be reserved.
    l_exp_date                        DATE;   -- Expired lots custom hook

    --l_request_number                  varchar2(30); --bug 1488875
    -- Define cursors
   /* FP-J PAR Replenishment Counts: transfer_subinventory, project_id and task_id are also
      fetched in the cursor. These are used in calling get_pick_slip_number */
    CURSOR l_mold_crs(p_mo_line_id IN NUMBER) IS
      SELECT transaction_temp_id
           , subinventory_code
           , locator_id
           , transfer_subinventory
           , project_id
           , task_id
           , transfer_to_location
           , revision
        FROM mtl_material_transactions_temp
       WHERE move_order_line_id = p_mo_line_id
         AND pick_slip_number IS NULL;

    /*Bug 3229204:Adding variable to specify to be passed to process_prj_dynamic_locators*/
    l_dest_locator_id NUMBER;


 BEGIN
    IF is_debug IS NULL THEN
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       If l_debug = 1 Then
     is_debug := TRUE;
       Else
     is_debug := FALSE;
       End If;
    END IF;
    IF (is_debug) THEN
       print_debug('Inside Process_Line', 'Inv_Pick_Release_PVT.Process_Line');
       gmi_reservation_util.println('inside Inv_Pick_Release_PVT.Process_Line');
    END IF;

    SAVEPOINT process_line_pvt;
    x_detail_rec_count  := 0;
    l_num_detail_recs   := 0;

    -- Standard Call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to true
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status     := fnd_api.g_ret_sts_success;

    -- Return success immediately if the line is already fully detailed
     -- check required quantity otherwise use the quantity - CMS change bug 2135900
    IF NVL(p_mo_line_rec.quantity_detailed, 0) >= NVL(p_mo_line_rec.required_quantity, NVL(p_mo_line_rec.quantity, 0)) THEN
      RETURN;
    END IF;
    -- Override the printing mode to deferred if allow partial pick is false.
    -- Otherwise set it based on the parameter passed in.
    IF p_allow_partial_pick = fnd_api.g_false THEN
      l_pick_slip_mode  := 'E';
    ELSE
      l_pick_slip_mode  := p_print_mode;
    END IF;

    inv_project.set_org_client_info(l_api_return_status,
                    p_mo_line_rec.organization_id);

    -- Determine the demand source and delivery information for the given line.

    BEGIN
     /* BENCHMARK - don't need to join to OE_ORDER_LINES_ALL or RA_CUSTOMERS,
       since we don't use customer number or shipment number in this code
      SELECT *
        INTO l_demand_info
        FROM wsh_inv_delivery_details_v
       WHERE move_order_line_id = p_mo_line_rec.line_id
         AND move_order_line_id IS NOT NULL
         AND released_status = 'S';
      */
      /* Bug 5570553  added the index hint with the suggestion of apps performance team */
	-- Bug8757642. Added p_wave_simulation_mode with default vale 'N' for WavePlanning Project.
	-- This project is available only in for R121 and mainline. To retain dual maintenance INV code changes are made in branchline, however it will not affect any existing flow.
      IF p_wave_simulation_mode = 'N' THEN
       SELECT /*+index (WDD WSH_DELIVERY_DETAILS_N7)*/
             wdd.source_header_id oe_header_id,
             wts.stop_id trip_stop_id,
             wdd.source_line_id oe_line_id,
             wda.delivery_id shipping_delivery_id,
             wdd.customer_id customer_id,
             NULL,   --ra.customer number
             wdd.ship_to_location_id ship_to_location,
             wdd.ship_from_location_id ship_from_location,
             wdd.shipment_priority_code shipment_priority_code,
             NULL, --ol.shipment_number shipment_number,
             wdd.ship_method_code freight_code,
             wdd.move_order_line_id move_order_line_id,
             wdd.released_status,
             wdd.delivery_detail_id
        INTO l_demand_info
            FROM wsh_delivery_details wdd, wsh_delivery_assignments_v wda,
             wsh_new_deliveries wnd, wsh_delivery_legs wlg, wsh_trip_stops wts
       WHERE wnd.delivery_id(+) = wda.delivery_id
         AND wlg.delivery_id(+) = wnd.delivery_id
         AND wts.stop_id(+) = wlg.pick_up_stop_id
         AND NVL(wlg.sequence_number,-1) =
        (SELECT NVL(min(g.sequence_number),-1)
           FROM wsh_delivery_legs g
          WHERE g.delivery_id(+) = wnd.delivery_id )
         AND wdd.delivery_detail_id = wda.delivery_detail_id
         AND wdd.move_order_line_id = p_mo_line_rec.line_id
         AND wdd.move_order_line_Id IS NOT NULL
          --AND nvl(wdd.shipment_direction,'O') in ( 'O' , 'IO')
         AND wdd.released_status = 'S';
      ELSIF p_wave_simulation_mode = 'Y' THEN
	SELECT /*+index (WDD WSH_DELIVERY_DETAILS_N7)*/
	wdd.source_header_id oe_header_id,
	wdd.source_line_id oe_line_id
	INTO l_demand_info.oe_header_id, l_demand_info.oe_line_id
	FROM wsh_delivery_details wdd
	WHERE wdd.move_order_line_id = p_mo_line_rec.line_id;
     end if;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (is_debug) THEN
          print_debug('No data found-Delivery Info', 'Inv_Pick_Release_PVT.Process_Line');
          gmi_reservation_util.println('Process_LineNo data found-Delivery Info');
        END IF;
        ROLLBACK TO process_line_pvt;
        fnd_message.set_name('INV', 'INV_DELIV_INFO_MISSING');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;
    IF (is_debug) THEN
      gmi_reservation_util.println('Process_Line after fetch wdd');
    END IF;
    l_return_value := INV_CACHE.set_item_rec(p_mo_line_rec.organization_id, p_mo_line_rec.inventory_item_id);
    IF NOT l_return_value THEN
    If is_debug THEN
      print_debug('Error setting item cache', 'Inv_Pick_Release_PVT.Process_Line');
    End If;
      raise fnd_api.g_exc_unexpected_error;
    End If;
    l_reservable_type:= INV_CACHE.item_rec.reservable_type;

    IF p_mo_line_rec.transaction_type_id = 52 THEN
      l_demand_source_type := 2;
    ELSIF p_mo_line_rec.transaction_type_id = 53 THEN
      l_demand_source_type := 8;
    ELSIF g_transaction_type_id = p_mo_line_rec.transaction_type_id THEN
      l_demand_source_type := g_transaction_source_type_id;
    ELSE
      l_return_value := INV_CACHE.set_mtt_rec(p_mo_line_rec.transaction_type_id);
      IF NOT l_return_value THEN
        If is_debug THEN
          print_debug('Error setting item cache','Inv_Pick_Release_PVT.Process_Line');
        End If;
        raise fnd_api.g_exc_unexpected_error;
      End If;
      l_demand_source_type := INV_CACHE.mtt_rec.transaction_source_type_id;
      g_transaction_type_id := p_mo_line_rec.transaction_type_id;
      g_transaction_source_type_id := l_demand_source_type;
    END IF;
    IF (is_debug) THEN
       gmi_reservation_util.println('Process_Line after trans type ');
    END IF;

    -- Compute the MTL_SALES_ORDERS header ID to use when dealing with reservations.
    --l_mso_header_id     := inv_salesorder.get_salesorder_for_oeheader(l_demand_info.oe_header_id);

    l_return_value := INV_CACHE.set_mso_rec(l_demand_info.oe_header_id);
    IF NOT l_return_value THEN
      IF (is_debug) THEN
         print_debug('No Mtl_Sales_Order ID found for oe header', 'Inv_Pick_Release_PVT.Process_Line');
         gmi_reservation_util.println('No Mtl_Sales_Order ID found for oe header');
      END IF;
      fnd_message.set_name('INV', 'INV_COULD_NOT_GET_MSO_HEADER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_mso_header_id := INV_CACHE.mso_rec.sales_order_id;

    IF (is_debug) THEN
       gmi_reservation_util.println('Process_Line,  l_mso_header_id '|| l_mso_header_id);

       print_debug('p_mo_line_rec.unit_number is '|| p_mo_line_rec.unit_number, 'Inv_Pick_Release_PVT.Process_Line');
       print_debug('p_mo_line_Rec.project_id is '|| p_mo_line_rec.project_id, 'Inv_Pick_Release_PVT.Process_Line');
       print_debug('p_mo_line_Rec.task_id  is '|| p_mo_line_rec.task_id, 'Inv_Pick_Release_PVT.Process_Line');
    END IF;

    -- Retrieve reservation information for that demand source
    -- only if the item is reservable
    IF (l_reservable_type = 1) THEN
      IF (is_debug) THEN
         print_debug('Calling process_reservations', 'Inv_Pick_Release_PVT.Process_Line');
      END IF;
      --bug#7377744
      process_reservations(
        x_return_status              => l_api_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_demand_info                => l_demand_info
      , p_mo_line_rec                => p_mo_line_rec
      , p_mso_line_id                => l_mso_header_id
      , p_demand_source_type         => l_demand_source_type
      , p_demand_source_name         => NULL
      , p_allow_partial_pick         => p_allow_partial_pick
      , x_demand_rsvs_ordered        => l_demand_rsvs_ordered
      , x_rsv_qty_available          => l_rsv_qty_available
     , x_rsv_qty2_available          => l_rsv_qty2_available
      );

      -- Return an error if the query reservations call failed
      IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
        ROLLBACK TO process_line_pvt;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF (l_reservable_type = 2) THEN
      -- bug 1412145 for non reservable item, just update shipping attr with released_status = 'Y'
      -- update the qty_Detailed and qty_Delivered in the move order line
      IF (is_debug) THEN
         print_debug('Calling process_unreservable_items', 'Inv_Pick_Release_PVT.Process_Line');
      END IF;
      l_call_mode  := NULL;
      process_unreservable_items(
        x_return_status              => l_api_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_pick_slip_number           => l_pick_slip_number
      , x_ready_to_print             => l_ready_to_print
      , p_mo_line_rec                => p_mo_line_rec
      , p_demand_info                => l_demand_info
      , p_grouping_rule_id           => p_grouping_rule_id
      , p_pick_slip_mode             => l_pick_slip_mode
      , p_print_mode                 => p_print_mode
      , x_call_mode                  => l_call_mode
      );

      IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
        ROLLBACK TO process_line_pvt;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF  l_ready_to_print = fnd_api.g_true
       AND p_allow_partial_pick = fnd_api.g_true
       AND l_call_mode IS NULL THEN
        COMMIT WORK;

        l_return_value := INV_CACHE.set_mtrh_rec(p_mo_line_rec.header_id);
        IF NOT l_return_value THEN
          If is_debug THEN
            print_debug('Error setting header cache', 'Inv_Pick_Release_PVT.Process_Line');
          End If;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
        l_request_number := INV_CACHE.mtrh_rec.request_number;

        IF g_request_number is NOT NULL and
          g_request_number = l_request_number AND
          g_report_set_id IS NOT NULL THEN
            l_report_set_id := g_report_set_id;
        ELSE
          BEGIN
              SELECT document_set_id
                INTO l_report_set_id
                FROM wsh_picking_batches
               WHERE NAME = l_request_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF is_debug THEN
                print_debug('No Data found - document set','Inv_Pick_Release_PVT.Process_Line');
              END IF;
              x_return_status  := fnd_api.g_ret_sts_error;
              RAISE fnd_api.g_exc_error;
          END;
          g_request_number := l_request_number;
          g_report_set_id := l_report_set_id;
        END IF;

        wsh_pr_pick_slip_number.print_pick_slip(
            p_pick_slip_number           => l_pick_slip_number
          , p_report_set_id              => l_report_set_id
          , p_organization_id            => p_mo_line_rec.organization_id
          , x_api_status                 => l_api_return_status
          , x_error_message              => l_api_error_msg
        );

        IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
          IF (is_debug) THEN
            print_debug('Error in Print Pick Slip', 'Inv_Pick_Release_PVT.Process_Line');
          END IF;
          ROLLBACK TO process_line_pvt;
          fnd_message.set_name('INV', 'INV_PRINT_PICK_SLIP_FAILED');
          fnd_message.set_token('PICK_SLIP_NUM', TO_CHAR(l_pick_slip_number));
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- ready to print

      GOTO end_pick;
    ELSE
        print_debug('Non-standard reservable type: ' || l_reservable_type, 'Inv_Pick_Release_PVT.Process_Line');
    END IF; -- The item is reservable

    l_lot_control_code:= INV_CACHE.item_rec.lot_control_code;

    IF (l_lot_control_code = inv_reservation_global.g_lot_control_yes AND INV_CACHE.item_rec.lot_divisible_flag <> 'Y') THEN
       l_lot_divisible_flag := 'N';
    ELSE
       l_lot_divisible_flag := 'Y';
    END IF;

    -- If the sub is not reservable we still want to move further
    IF g_sub_reservable_type = 1 THEN
      IF (l_demand_rsvs_ordered.COUNT = 0 AND l_lot_divisible_flag = 'Y' AND g_pick_nonrsv_lots <> 1) THEN -- Bug 8560030
        IF (is_debug) THEN
           print_debug('Could not reserve any qty skip suggestion', 'Inv_Pick_Release_PVT.Process_Line');
        END IF;
        GOTO rsv_failed;
      END IF;
    END IF;

    -- If lot indivisible item then set tolerance for use during allocation
    l_min_tolerance := 0;
    l_max_tolerance := 0;
    g_min_tolerance := 0;
    g_max_tolerance := 0;
    -- {{ Test Case # UTK-REALLOC-3.2.6:61 }}
    --   Description: Tolerances on Non-lot indivisible items should not be considered
    IF l_lot_divisible_flag = 'N' THEN
       IF (is_debug) THEN
          print_debug('Calling get tolerance', 'Inv_Pick_Release_PVT.Process_Line');
       END IF;
       get_tolerance(p_mo_line_id  =>  p_mo_line_rec.line_id,
                     x_return_status  => l_api_return_status,
                     x_msg_count  =>  x_msg_count,
                     x_msg_data => x_msg_data,
                     x_max_tolerance => l_max_tolerance,
                     x_min_tolerance => l_min_tolerance);
       IF (is_debug) THEN
          print_debug('max tolerance is '|| l_max_tolerance || ' , min tolerance is ' || l_min_tolerance, 'Inv_Pick_Release_PVT.Process_line');
       END IF;
    END IF;

    IF (is_debug) THEN
       print_debug('calling create suggestions', 'Inv_Pick_Release_PVT.Process_Line');
       print_debug('line_id is '|| p_mo_line_rec.line_id, 'Inv_Pick_Release_PVT.Process_line');
    END IF;
    --Bug3237702 starts added for caching
    inv_cache.tolocator_id := p_mo_line_rec.to_locator_id;
    inv_cache.tosubinventory_code := p_mo_line_rec.to_subinventory_code;
    --Bug3237702 ends
    -- Bug 5264987 Added p_organization_id to the create_suggestions call
    inv_ppengine_pvt.create_suggestions(
      p_api_version                => 1.0
    , p_init_msg_list              => fnd_api.g_false
    , p_commit                     => fnd_api.g_false
    , x_return_status              => l_api_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_transaction_temp_id        => p_mo_line_rec.line_id
    , p_reservations               => l_demand_rsvs_ordered
    , p_suggest_serial             => 'T'
    , p_plan_tasks                 => p_plan_tasks
    , p_organization_id           => p_mo_line_rec.organization_id
    , p_wave_simulation_mode       => p_wave_simulation_mode
    );

    g_pick_nonrsv_lots := 2; -- Bug 8560030

    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
      IF (is_debug) THEN
         print_debug('l_return_status = '|| l_api_return_status, 'Inv_Pick_Release_PVT.Process_Line');
         print_debug('inv detailing failed', 'Inv_Pick_Release_PVT.Process_Line');
      END IF;
      /*As a part of bug 1826833, commented the line below and
        uncommented the the message printing code below
      */
      -- print_debug(replace(x_msg_data,chr(0),'#'), 'Inv_Pick_Release_PVT.Process_Line');
      fnd_msg_pub.count_and_get(p_count => l_count, p_data => l_message, p_encoded => 'F');

      IF (l_count = 0) THEN
        IF (is_debug) THEN
           print_debug('no message from detailing engine',
               'Inv_Pick_Release_PVT.Process_Line');
        END IF;
      ELSIF (l_count = 1) THEN
        IF (is_debug) THEN
           print_debug(l_message, 'Inv_Pick_Release_PVT.Process_Line');
        END IF;
      ELSE
        FOR i IN 1 .. l_count LOOP
          l_message  := fnd_msg_pub.get(i, 'F');
          IF (is_debug) THEN
             print_debug(l_message, 'Inv_Pick_Release_PVT.Process_Line');
          END IF;
        END LOOP;

        fnd_msg_pub.delete_msg();
       END IF;

      ROLLBACK TO process_line_pvt;

      l_return_value := INV_CACHE.set_mtrh_rec(p_mo_line_rec.header_id);
      IF NOT l_return_value THEN
          If is_debug THEN
              print_debug('Error setting header cache', 'Inv_Pick_Release_PVT.Process_Line');
          End If;
          raise fnd_api.g_exc_unexpected_error;
      END IF;
      l_request_number := INV_CACHE.mtrh_rec.request_number;

      fnd_message.set_name('INV', 'INV_DETAILING_FAILED');
      fnd_message.set_token('LINE_NUM', TO_CHAR(p_mo_line_rec.line_number));
      fnd_message.set_token('MO_NUMBER', l_request_number);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (is_debug) THEN
       print_debug('after calling create suggestions with return status = '||l_api_return_status, 'Inv_Pick_Release_PVT.Process_Line');
    END IF;

    -- Update the detailed quantity (and if possible, the sourcing information)
    -- of the Move Order Line
    --Incase no reservations  skipped create suggestions 1705058
    <<rsv_failed>>
    BEGIN
      SELECT NVL(SUM(primary_quantity), 0)
        ,NVL(sum(transaction_quantity),0)
        ,NVL(sum(secondary_transaction_quantity),0)
        ,COUNT(*)
        INTO l_quantity_detailed
            ,l_quantity_detailed_conv
            ,l_sec_quantity_detailed
            ,l_num_detail_recs
        FROM mtl_material_transactions_temp
       WHERE move_order_line_id = p_mo_line_rec.line_id;
      -- Bug 6989438
      IF (is_debug) THEN
         print_debug('l_quantity detailed is '|| l_quantity_detailed, 'Inv_Pick_Release_PVT.Process_Line');
         print_debug('l_sec_quantity detailed is '|| l_sec_quantity_detailed, 'Inv_Pick_Release_PVT.Process_Line');
         print_debug('l_num_detail_recs is '|| l_num_detail_recs, 'Inv_Pick_Release_PVT.Process_Line');
      END IF;

      --Bug#6085577. l_quantity_detailed_conv should hold quantity in the UOM of MTRL.
      l_primary_uom:= INV_CACHE.item_rec.primary_uom_code; --Get primary UOM of item.
      IF (is_debug) THEN
        print_debug('Move Order line UOM '||p_mo_line_rec.uom_code || 'Pri UOM:'|| l_primary_uom,'Inv_Pick_Release_PVT.Process_Line');
      END IF;
      IF (p_mo_line_rec.uom_code <> l_primary_uom ) THEN
        l_quantity_detailed_conv :=   inv_convert.inv_um_convert(
              item_id                      => p_mo_line_rec.inventory_item_id
            , PRECISION                    => NULL
            , from_quantity                => l_quantity_detailed
            , from_unit                    => l_primary_uom
            , to_unit                      => p_mo_line_rec.uom_code
            , from_name                    => NULL
            , to_name                      => NULL
        );
      ELSE
        l_quantity_detailed_conv := l_quantity_detailed;
      END IF;  --end of Bug#6085577

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (is_debug) THEN
           print_debug('no detail records found', 'Inv_Pick_Release_PVT.Process_line');
        END IF;
        l_quantity_detailed  := 0;
        l_sec_quantity_detailed  := 0;
        l_quantity_detailed_conv  := 0;
        l_num_detail_recs := 0;
    END;

    -- If the move order line is not fully detailed, update the
    -- return status as appropriate.
    -- {{ Test Case # UTK-REALLOC-3.2.6:62 }}
    --   Description: Partially detailed should be set to 1 if allocation within tolerance but less
    --                than the requested quantity
    IF l_quantity_detailed < p_mo_line_rec.primary_quantity - l_min_tolerance THEN
      IF p_allow_partial_pick = fnd_api.g_false THEN
        IF (is_debug) THEN
           print_debug('Error - could not pick full', 'Inv_Pick_Release_PVT.Process_Line');
        END IF;
        ROLLBACK TO process_line_pvt;
        fnd_message.set_name('INV', 'INV_COULD_NOT_PICK_FULL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSE
        -- Set a flag to later set the return status for success,
        -- but only partially detailed
        IF (is_debug) THEN
           print_debug('l_partially_detailed is 1', 'Inv_Pick_Release_PVT.Process_Line');
        END IF;
        l_partially_detailed  := 1;
      END IF;
    ELSE
      IF (is_debug) THEN
         print_debug('l_partially_detailed is 2', 'Inv_Pick_Release_PVT.Process_Line');
         IF l_quantity_detailed < p_mo_line_rec.primary_quantity THEN
             print_debug('Underallocated with tolerance', 'Inv_Pick_Release_PVT.Process_Line');
         END IF;
      END IF;
      l_partially_detailed  := 2;
    END IF;

    -- Expired lots custom hook
    IF inv_pick_release_pub.g_pick_expired_lots THEN
        l_exp_date := NULL;
    ELSE
        l_exp_date := SYSDATE;
    END IF;

    IF (l_num_detail_recs = 0) THEN
      p_mo_line_rec.txn_source_id       := l_mso_header_id;
      p_mo_line_rec.quantity_detailed:=NVL(p_mo_line_rec.quantity_delivered,0);
      p_mo_line_rec.secondary_quantity_detailed:=NVL(p_mo_line_rec.secondary_quantity_delivered,0);
      p_mo_line_rec.txn_source_line_id := l_demand_info.oe_line_id;
      p_mo_line_rec.pick_slip_date := SYSDATE;

      -- Bug 6989438
      IF (is_debug) THEN
         print_debug('p_mo_line_rec.quantity_delivered '||p_mo_line_rec.quantity_delivered, 'Inv_Pick_Release_PVT.Process_Line');
         print_debug('p_mo_line_rec.secondary_quantity_delivered '||p_mo_line_rec.secondary_quantity_delivered, 'Inv_Pick_Release_PVT.Process_Line');
      end if;
      UPDATE MTL_TXN_REQUEST_LINES
         SET quantity_detailed = NVL(p_mo_line_rec.quantity_delivered,0),
             secondary_quantity_detailed = NVL(p_mo_line_rec.secondary_quantity_delivered,0),
             txn_source_id = l_mso_header_id,
             txn_source_line_id = l_demand_info.oe_line_id,
             pick_slip_date = sysdate
       WHERE line_id = p_mo_line_rec.line_id;


      /*update unsuggested qty as already org level rsv already created*/

      IF (l_demand_rsvs_ordered.COUNT > 0  AND l_rsv_qty_available > 0) THEN
        l_index  := l_demand_rsvs_ordered.LAST;
        l_reservation_id := l_demand_rsvs_ordered(l_index).reservation_id;
        l_new_prim_rsv_quantity  := l_demand_rsvs_ordered(l_index).primary_reservation_quantity   - NVL(l_rsv_qty_available, 0);
        l_new_sec_rsv_quantity   := l_demand_rsvs_ordered(l_index).secondary_reservation_quantity - NVL(l_rsv_qty2_available, 0);
        IF (is_debug) THEN
            print_debug('updating reservations created as suggestions failed', 'Inv_Pick_Release_PVT.Process_Line');
            print_debug('reduce reservation by '|| l_rsv_qty_available, 'Inv_Pick_Release_PVT.Process_Line');
            print_debug('reduce secondary reservation by '||l_rsv_qty2_available, 'Inv_Pick_Release_PVT.Process_Line');
        END IF;

        --if setting new quantity to 0, call delete
        If l_new_prim_rsv_quantity = 0 Then
            --CHANGE - should pass validation flag that does not validate but
            --does update quantity tree
            IF is_debug THEN
                print_debug('Delete org level reservation', 'Inv_Pick_Release_PVT.Process_Reservations');
            END IF;
            inv_reservation_pvt.delete_reservation(
                 p_api_version_number => 1.0
                ,p_init_msg_lst => fnd_api.g_false
                ,x_return_status => l_api_return_status
                ,x_msg_count    => x_msg_count
                ,x_msg_data    => x_msg_data
                ,p_rsv_rec => l_demand_rsvs_ordered(l_index)
                ,p_original_serial_number => l_dummy_sn
                ,p_validation_flag => fnd_api.g_true
            );

            IF (l_api_return_status = fnd_api.g_ret_sts_error) THEN
                IF (is_debug) THEN
                    print_debug('return error from delete_reservation', 'Inv_Pick_Release_Pvt.Process_Line');
                END IF;
                RAISE fnd_api.g_exc_error;
            ELSIF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
                IF (is_debug) THEN
                    print_debug('return unexpected error from delete_reservation','Inv_Pick_Release_Pvt.Process_Line');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

        Else
          --update quantity tree
          IF is_debug THEN
            print_debug('updating quantity tree', 'Inv_Pick_Release_PVT.Process_Line');
          END IF;
          l_primary_uom:= INV_CACHE.item_rec.primary_uom_code;
          l_secondary_uom:= INV_CACHE.item_rec.secondary_uom_code;
          l_revision_control_code:=INV_CACHE.item_rec.revision_qty_control_code;
          l_lot_control_code:= INV_CACHE.item_rec.lot_control_code;
          l_serial_number_control_code:= INV_CACHE.item_rec.serial_number_control_code;
          -- convert revision/lot control indicators into boolean

          IF l_revision_control_code = 2 THEN
              l_is_revision_control  := TRUE;
          ELSE
              l_is_revision_control  := FALSE;
          END IF;
          --
          IF l_lot_control_code = 2 THEN
              l_is_lot_control  := TRUE;
          ELSE
              l_is_lot_control  := FALSE;
          END IF;
          --
          IF l_serial_number_control_code = 2 THEN
              l_is_serial_control  := TRUE;
          ELSE
              l_is_serial_control  := FALSE;
          END IF;

        -- Added  secondary qty related parameters section for Bug 7377744
          inv_quantity_tree_pub.update_quantities(
              p_api_version_number         => 1.0
            , p_init_msg_lst               => fnd_api.g_false
            , x_return_status              => l_api_return_status
            , x_msg_count                  => x_msg_count
            , x_msg_data                   => x_msg_data
            , p_organization_id            => p_mo_line_rec.organization_id
            , p_inventory_item_id          => p_mo_line_rec.inventory_item_id
            , p_tree_mode          => inv_quantity_tree_pub.g_reservation_mode
            , p_is_revision_control        => l_is_revision_control
            , p_is_lot_control             => l_is_lot_control
            , p_is_serial_control          => l_is_serial_control
            , p_demand_source_type_id      => l_demand_source_type
            , p_demand_source_header_id    => l_mso_header_id
            , p_demand_source_line_id      => l_demand_info.oe_line_id
            , p_demand_source_name         => NULL
            , p_revision                   => NULL
            , p_lot_number                 => NULL
            , p_lot_expiration_date        => l_exp_date
            , p_subinventory_code          => NULL
            , p_locator_id                 => NULL
            , p_primary_quantity           => -(l_rsv_qty_available)
            , p_secondary_quantity         => -(l_rsv_qty2_available) -- Bug 7377744
            , p_quantity_type              => inv_quantity_tree_pub.g_qr_same_demand
            , x_qoh                        => l_qty_on_hand
            , x_rqoh                       => l_qty_res_on_hand
            , x_qr                         => l_qty_res
            , x_qs                         => l_qty_sug
            , x_att                        => l_qty_att
            , x_atr                        => l_qty_available_to_reserve


              , p_grade_code                 => p_mo_line_rec.grade_code
              , x_sqoh                       => l_sec_qty_on_hand
              , x_srqoh                      => l_sec_qty_res_on_hand
              , x_sqr                        => l_sec_qty_res
              , x_sqs                        => l_sec_qty_sug
              , x_satt                       => l_sec_qty_att
              , x_satr                       => l_sec_qty_available_to_reserve
          );
          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
            IF (is_debug) THEN
              print_debug('Error from update quantity tree',
             'Inv_Pick_Release_PVT.Process_Line');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          --handle conversion to reservation UOM
          IF l_demand_rsvs_ordered(l_index).reservation_uom_code IS NULL OR l_new_prim_rsv_quantity = 0 THEN
            --when missing rsv UOM, assume primary UOM
            l_new_rsv_quantity := l_new_prim_rsv_quantity;
          ELSIF l_demand_rsvs_ordered(l_index).reservation_uom_code =
            l_primary_uom THEN
            --reservation UOM = primary UOM
            l_new_rsv_quantity := l_new_prim_rsv_quantity;
          ELSE
            l_new_rsv_quantity  := inv_convert.inv_um_convert(
                item_id                 => p_mo_line_rec.inventory_item_id
              , PRECISION               => NULL
              , from_quantity           => l_new_prim_rsv_quantity
              , from_unit               => l_primary_uom
              , to_unit                 => l_demand_rsvs_ordered(l_index).reservation_uom_code
              , from_name               => NULL
              , to_name                 => NULL
            );


            IF (l_new_rsv_quantity = -99999) THEN
              IF (is_debug) THEN
                 print_debug('Cannot convert primary uom to rsv uom','Inv_Pick_release_pvt.process_line');
              END IF;
              fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
              fnd_message.set_token('UOM', l_primary_uom);
              fnd_message.set_token('ROUTINE', 'Pick Release process');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;

          -- Bug 6989438
          IF (is_debug) THEN
              print_debug('1 New prim rsv qty: ' || l_new_prim_rsv_quantity,'Inv_Pick_Release_PVT.Process_Line');
              print_debug('New rsv qty: ' || l_new_rsv_quantity,'Inv_Pick_Release_PVT.Process_Line');
              print_debug('New sec rsv qty: ' || l_new_sec_rsv_quantity,'Inv_Pick_Release_PVT.Process_Line');
          END IF;
          UPDATE mtl_reservations
             SET primary_reservation_quantity = l_new_prim_rsv_quantity
                ,reservation_quantity = l_new_rsv_quantity
                ,secondary_reservation_quantity = l_new_sec_rsv_quantity -- Bug 6989438
           WHERE reservation_id = l_reservation_id;

          inv_rsv_synch.for_update(
            p_reservation_id => l_reservation_id
          , x_return_status => l_api_return_status
          , x_msg_count => x_msg_count
          , x_msg_data => x_msg_data);

          IF l_api_return_status = fnd_api.g_ret_sts_error THEN
            IF (is_debug) THEN
              print_debug('Error from inv_rsv_synch.for_update','Inv_Pick_Release_PVT.Process_Reservations');
            END IF;
            RAISE fnd_api.g_exc_error;
          END IF;
          --
          IF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (is_debug) THEN
              print_debug('Unexp. error from inv_rsv_synch.for_update','Inv_Pick_Release_PVT.Process_Reservations');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

        End If; -- new rsv qty = 0
      END IF; -- demand rsvs ordered count > 0
      /*update unsuggested qty as already org level rsv already created*/
    END IF; --num recs = 0


    /* BUG 6216137
    -- Reservations created during pick release should be removed if the line is
    -- partially backordered */
    l_res_ordered_index  := l_demand_rsvs_ordered.LAST;
    IF l_demand_rsvs_ordered.COUNT > 0 AND l_partially_detailed = 1 AND l_num_detail_recs > 0 THEN

      IF (l_debug = 1) THEN
           print_debug('Checking whether to unreserve non-detailed quantity or not', 'Inv_Pick_Release_PVT.Process_Line');
      END IF;

      l_reduce_rsv_qty := l_rsv_qty_available;
      l_reduce_rsv_qty2:= l_rsv_qty2_available;

      BEGIN
         SELECT NVL(SUM(ABS(primary_quantity)), 0),
                NVL(SUM(ABS(secondary_transaction_quantity)), 0)    -- Pushkar
           INTO l_reservation_detailed_qty,
                l_rsv_detailed_qty2
           FROM mtl_material_transactions_temp
          WHERE organization_id = p_mo_line_rec.organization_id
            AND reservation_id = l_demand_rsvs_ordered(l_res_ordered_index).reservation_id;

         IF l_reduce_rsv_qty > (l_demand_rsvs_ordered(l_res_ordered_index).primary_reservation_quantity - nvl(l_reservation_detailed_qty,0)) THEN
           l_reduce_rsv_qty := (l_demand_rsvs_ordered(l_res_ordered_index).primary_reservation_quantity - nvl(l_reservation_detailed_qty,0));
           l_reduce_rsv_qty2:= (l_demand_rsvs_ordered(l_res_ordered_index).secondary_reservation_quantity  - nvl(l_rsv_detailed_qty2,0));
         END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           l_reduce_rsv_qty := l_rsv_qty_available;
      END;

      l_new_prim_rsv_quantity  := l_demand_rsvs_ordered(l_res_ordered_index).primary_reservation_quantity   - NVL(l_reduce_rsv_qty, 0);
      l_new_sec_rsv_quantity   := l_demand_rsvs_ordered(l_res_ordered_index).secondary_reservation_quantity - NVL(l_reduce_rsv_qty2, 0);

      IF (l_debug = 1) THEN
           print_debug('l_reduce_rsv_qty = '||l_reduce_rsv_qty, 'Inv_Pick_Release_PVT.Process_Line');
           print_debug('l_new_prim_rsv_quantity = '||l_new_prim_rsv_quantity, 'Inv_Pick_Release_PVT.Process_Line');
           print_debug('l_new_sec_rsv_quantity  = '||l_new_sec_rsv_quantity, 'Inv_Pick_Release_PVT.Process_Line');
      END IF;

      IF NVL(l_reduce_rsv_qty,0) > 0 THEN
        IF (l_debug = 1) THEN
           print_debug('updating reservations created as suggestions got created with partial qty', 'Inv_Pick_Release_PVT.Process_Line');
           print_debug('system generated reservation '|| l_rsv_qty_available, 'Inv_Pick_Release_PVT.Process_Line');
           print_debug('system generated sec reservation '||l_rsv_qty2_available, 'Inv_Pick_Release_PVT.Process_Line');
           print_debug('reduce reservation by '|| l_reduce_rsv_qty, 'Inv_Pick_Release_PVT.Process_Line');
           print_debug('reduce sec reservation by '|| l_reduce_rsv_qty2, 'Inv_Pick_Release_PVT.Process_Line');
        END IF;

        --handle conversion to reservation UOM
        IF l_demand_rsvs_ordered(l_res_ordered_index).reservation_uom_code IS NULL THEN
          --when missing rsv UOM, assume primary UOM
          l_new_rsv_quantity := l_new_prim_rsv_quantity;
        ELSIF l_demand_rsvs_ordered(l_res_ordered_index).reservation_uom_code = l_primary_uom THEN
          --reservation UOM = primary UOM
          l_new_rsv_quantity := l_new_prim_rsv_quantity;
        ELSE
          l_new_rsv_quantity  := inv_convert.inv_um_convert(
              item_id                 => p_mo_line_rec.inventory_item_id
            , PRECISION               => NULL
            , from_quantity           => l_new_prim_rsv_quantity
            , from_unit               => l_primary_uom
            , to_unit                 => l_demand_rsvs_ordered(l_res_ordered_index).reservation_uom_code
            , from_name               => NULL
            , to_name                 => NULL
          );

          IF (l_new_rsv_quantity = -99999) THEN
            IF (is_debug) THEN
              print_debug('Cannot convert primary uom to rsv uom','Inv_Pick_release_pvt.process_line');
            END IF;
            fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
            fnd_message.set_token('UOM', l_primary_uom);
            fnd_message.set_token('ROUTINE', 'Pick Release process');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;
        IF (is_debug) THEN
            print_debug('2 New prim rsv qty: ' || l_new_prim_rsv_quantity,'Inv_Pick_Release_PVT.Process_Line');
            print_debug('New rsv qty: ' || l_new_rsv_quantity,'Inv_Pick_Release_PVT.Process_Line');
            print_debug('New sec rsv qty: ' || l_new_sec_rsv_quantity,'Inv_Pick_Release_PVT.Process_Line');
        END IF;
        /* bug 7253296 - error in quantity tree */
        /*l_demand_rsvs_ordered(l_res_ordered_index).primary_reservation_quantity  := l_new_prim_rsv_quantity;
        l_demand_rsvs_ordered(l_res_ordered_index).reservation_quantity := l_new_rsv_quantity;

        UPDATE mtl_reservations
           SET primary_reservation_quantity = l_new_prim_rsv_quantity
              ,reservation_quantity = l_new_rsv_quantity
         WHERE reservation_id = l_demand_rsvs_ordered(l_res_ordered_index).reservation_id;*/

        l_original_rsv_record                 := l_demand_rsvs_ordered(l_res_ordered_index);
        l_to_rsv_record                       := l_original_rsv_record ;
        l_to_rsv_record.primary_reservation_quantity := l_new_prim_rsv_quantity;
        l_to_rsv_record.reservation_quantity  := l_new_rsv_quantity;
        l_to_rsv_record.secondary_reservation_quantity := l_new_sec_rsv_quantity; -- Bug 6989438

        inv_reservation_pub.update_reservation(
               p_api_version_number         => 1.0
             , p_init_msg_lst               => fnd_api.g_false
             , x_return_status              => l_api_return_status
             , x_msg_count                  => l_count
             , x_msg_data                   => l_message
             , p_original_rsv_rec           => l_original_rsv_record
             , p_to_rsv_rec                 => l_to_rsv_record
             , p_original_serial_number     => l_dummy_sn
             , p_to_serial_number           => l_dummy_sn
             , p_validation_flag            => fnd_api.g_true
        );

        IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
            IF (is_debug) THEN
                print_debug('error in update reservation', 'Inv_Pick_Release_PVT.Process_Reservations');
            END IF;
            fnd_message.set_name('INV', 'INV_UPD_RSV_FAILED');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        /* inv_rsv_synch.for_update(
              p_reservation_id => l_demand_rsvs_ordered(l_res_ordered_index).reservation_id
            , x_return_status => l_api_return_status
            , x_msg_count => x_msg_count
            , x_msg_data => x_msg_data);

        IF l_api_return_status = fnd_api.g_ret_sts_error THEN
            IF (is_debug) THEN
                print_debug('Error from inv_rsv_synch.for_update','Inv_Pick_Release_PVT.Process_Line');
            END IF;
            RAISE fnd_api.g_exc_error;
        END IF;
        --
        IF l_api_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (is_debug) THEN
                print_debug('Unexp. error from inv_rsv_synch.for_update','Inv_Pick_Release_PVT.Process_Line');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;*/
        /* end bug 7253296 */
      END IF; /* IF NVL(l_reduce_rsv_qty,0) > 0 THEN */
    END IF;
    /* End bug 6216137 */

    -- Update the line with the supply information if all the detail
    -- records match (otherwise update the line with NULL)
    IF l_num_detail_recs > 0 THEN
      -- Calculate the quantity detailed in the UOM of the move order line
      IF (is_debug) THEN
         print_debug('calling inv_convert.inv_uom_convert', 'Inv_Pick_Release_PVT.Process_Line');
         print_debug('l_quantity_detailed = '|| l_quantity_detailed, 'Inv_Pick_Release_PVT.Process_Line');
         print_debug('l_sec_quantity_detailed = '|| l_sec_quantity_detailed, 'Inv_Pick_Release_PVT.Process_Line');
      END IF;

      l_quantity_detailed_conv := nvl(l_quantity_detailed_conv,0) + Nvl(p_mo_line_rec.quantity_delivered,0);
      l_sec_quantity_detailed  := nvl(l_sec_quantity_detailed,0) + Nvl(p_mo_line_rec.secondary_quantity_delivered,0);

      p_mo_line_rec.quantity_detailed := l_quantity_detailed_conv;
      p_mo_line_rec.secondary_quantity_detailed := l_sec_quantity_detailed;
      p_mo_line_rec.txn_source_id       := l_mso_header_id;
      p_mo_line_rec.txn_source_line_id := l_demand_info.oe_line_id;
      p_mo_line_rec.pick_slip_date := sysdate;

      -- Bug 6989438
      IF (is_debug) THEN
         print_debug('Quantity_detailed is '|| l_quantity_detailed_conv, 'Inv_Pick_Release_PVT.Process_Line');
         print_debug('sec Quantity_detailed is '|| l_sec_quantity_detailed, 'Inv_Pick_Release_PVT.Process_Line');
      END IF;

      UPDATE MTL_TXN_REQUEST_LINES
         SET quantity_detailed = l_quantity_detailed_conv,
             secondary_quantity_detailed = l_sec_quantity_detailed,
             txn_source_id = l_mso_header_id,
             txn_source_line_id = l_demand_info.oe_line_id,
             pick_slip_date = sysdate
       WHERE line_id = p_mo_line_rec.line_id;

      -- Update the quantity detailed on the reservations
      IF l_demand_rsvs_ordered.COUNT > 0 THEN
        l_res_ordered_index  := l_demand_rsvs_ordered.FIRST;

        l_primary_uom:= INV_CACHE.item_rec.primary_uom_code;
        l_secondary_uom:= INV_CACHE.item_rec.secondary_uom_code;
        l_revision_control_code:=INV_CACHE.item_rec.revision_qty_control_code;
        l_lot_control_code:= INV_CACHE.item_rec.lot_control_code;
        l_serial_number_control_code:= INV_CACHE.item_rec.serial_number_control_code;
        -- convert revision/lot control indicators into boolean
        IF l_revision_control_code = 2 THEN
          l_is_revision_control  := TRUE;
        ELSE
          l_is_revision_control  := FALSE;
        END IF;
        --
        IF l_lot_control_code = 2 THEN
          l_is_lot_control  := TRUE;
        ELSE
          l_is_lot_control  := FALSE;
        END IF;
        --
        IF l_serial_number_control_code = 2 THEN
          l_is_serial_control  := TRUE;
        ELSE
          l_is_serial_control  := FALSE;
        END IF;

        LOOP
          l_reservation_id := l_demand_rsvs_ordered(l_res_ordered_index).reservation_id;

          l_prev_rsv_detailed_qty := nvl(l_demand_rsvs_ordered(l_res_ordered_index).detailed_quantity,0);
          l_prev_rsv_detailed_qty2 := nvl(l_demand_rsvs_ordered(l_res_ordered_index).secondary_detailed_quantity,0);
          BEGIN
            SELECT NVL(SUM(ABS(primary_quantity)), 0)
                 , NVL(SUM(ABS(secondary_transaction_quantity)), 0)
              INTO l_reservation_detailed_qty
                 , l_rsv_detailed_qty2
              FROM mtl_material_transactions_temp
             WHERE organization_id = p_mo_line_rec.organization_id
               AND reservation_id = l_reservation_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_reservation_detailed_qty  := 0;
              l_rsv_detailed_qty2         := 0;
          END;
          --update quantity tree
          IF is_debug THEN
            print_debug('updating quantity tree', 'Inv_Pick_Release_PVT.Process_Line');
          END IF;
          inv_quantity_tree_pub.update_quantities(
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => l_api_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_organization_id            => p_mo_line_rec.organization_id
              , p_inventory_item_id          => p_mo_line_rec.inventory_item_id
              , p_tree_mode                  => inv_quantity_tree_pub.g_reservation_mode
              , p_is_revision_control        => l_is_revision_control
              , p_is_lot_control             => l_is_lot_control
              , p_is_serial_control          => l_is_serial_control
              , p_demand_source_type_id      => l_demand_source_type
              , p_demand_source_header_id    => l_mso_header_id
              , p_demand_source_line_id      => l_demand_info.oe_line_id
              , p_demand_source_name         => NULL
              , p_revision                   => l_demand_rsvs_ordered(l_res_ordered_index).revision
              , p_lot_number                 => l_demand_rsvs_ordered(l_res_ordered_index).lot_number
              , p_lot_expiration_date        => l_exp_date
              , p_subinventory_code          => l_demand_rsvs_ordered(l_res_ordered_index).subinventory_code
              , p_locator_id                 => l_demand_rsvs_ordered(l_res_ordered_index).locator_id
              , p_primary_quantity           => -(l_reservation_detailed_qty - l_prev_rsv_detailed_qty)
              , p_secondary_quantity         => -(l_rsv_detailed_qty2        - l_prev_rsv_detailed_qty2) /* Bug 7377744 */
              , p_lpn_id                     => l_demand_rsvs_ordered(l_res_ordered_index).lpn_id /* Bug 7229711 */
              , p_quantity_type              => inv_quantity_tree_pub.g_qr_same_demand
              , x_qoh                        => l_qty_on_hand
              , x_rqoh                       => l_qty_res_on_hand
              , x_qr                         => l_qty_res
              , x_qs                         => l_qty_sug
              , x_att                        => l_qty_att
              , x_atr                        => l_qty_available_to_reserve
   /* Added following secondary qty related section for Bug 7377744 */
              , p_grade_code                 => p_mo_line_rec.grade_code
              , x_sqoh                       => l_sec_qty_on_hand
              , x_srqoh                      => l_sec_qty_res_on_hand
              , x_sqr                        => l_sec_qty_res
              , x_sqs                        => l_sec_qty_sug
              , x_satt                       => l_sec_qty_att
              , x_satr                       => l_sec_qty_available_to_reserve
            );
          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
            IF (is_debug) THEN
              print_debug('Error from update quantity tree', 'Inv_Pick_Release_PVT.Process_Line');
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
          IF (is_debug) THEN
             print_debug('update reservation with quantity_detailed', 'Inv_Pick_Release_PVT.Process_Line');
             print_debug('quantity_detailed'|| l_reservation_detailed_qty, 'Inv_Pick_Release_PVT.Process_Line');
             print_debug('prev_quantity_detailed'|| l_prev_rsv_detailed_qty, 'Inv_Pick_Release_PVT.Process_Line');
          END IF;

           -- Bug Fix 5624514
               --handle conversion to reservation UOM
          IF l_demand_rsvs_ordered(l_res_ordered_index).reservation_uom_code IS NULL
          THEN
          --when missing rsv UOM, assume primary UOM
            l_rsv_detailed_qty_conv := l_reservation_detailed_qty;
          ELSIF l_demand_rsvs_ordered(l_res_ordered_index).reservation_uom_code =
            l_primary_uom THEN
            --reservation UOM = primary UOM
            l_rsv_detailed_qty_conv := l_reservation_detailed_qty;
          ELSE
            l_rsv_detailed_qty_conv  := inv_convert.inv_um_convert(
                  item_id                 => p_mo_line_rec.inventory_item_id
                , PRECISION               => NULL
                , from_quantity           => l_reservation_detailed_qty
                , from_unit               => l_primary_uom
                , to_unit                 => l_demand_rsvs_ordered(l_res_ordered_index).reservation_uom_code
                , from_name               => NULL
                , to_name                 => NULL
            );
            IF (l_rsv_detailed_qty_conv = -99999) THEN
              IF (is_debug) THEN
                   print_debug('Cannot convert primary uom to rsv uom','Inv_Pick_release_pvt.process_reservations');
              END IF;
              fnd_message.set_name('INV', 'INV-CANNOT CONVERT');
              fnd_message.set_token('UOM', l_primary_uom);
              fnd_message.set_token('ROUTINE', 'Pick Release process');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;
          -- End of Bug Fix 5624514
          IF (is_debug) THEN
            print_debug('quantity_detailed conv'|| l_rsv_detailed_qty_conv, 'Inv_Pick_Release_PVT.Process_Line');
          END IF;
          -- Upper tolerance may lead to allocation above the reservation
          -- {{ Test Case # UTK-REALLOC-3.2.6:64 }}
          --   Description: If allocation is greater than reservation, increase the reserved quantity


         -- Bug 6989438
          IF (is_debug) THEN
             print_debug('l_rsv_detailed_qty_conv '|| l_rsv_detailed_qty_conv, 'Inv_Pick_Release_PVT.Process_Line');
             print_debug('l_rsv_detailed_qty2 '|| l_rsv_detailed_qty2, 'Inv_Pick_Release_PVT.Process_Line');
          END IF;

          UPDATE mtl_reservations
             SET reservation_quantity = greatest(reservation_quantity, l_rsv_detailed_qty_conv)  -- Bug Fix 5624514
              ,  primary_reservation_quantity = greatest(primary_reservation_quantity, l_reservation_detailed_qty)
	      ,  secondary_reservation_quantity = greatest(secondary_reservation_quantity, l_rsv_detailed_qty2)
              ,  detailed_quantity = l_reservation_detailed_qty
              ,  secondary_detailed_quantity = l_rsv_detailed_qty2
           WHERE reservation_id = l_reservation_id;

          EXIT WHEN l_res_ordered_index = l_demand_rsvs_ordered.LAST;
          l_res_ordered_index:= l_demand_rsvs_ordered.NEXT(l_res_ordered_index);
        END LOOP;
      END IF;

      -- Obtain the pick slip number for each Move Order Line Detail created
	-- Bug8757642. Added p_wave_simulation_mode with default vale 'N' for WavePlanning Project.
	-- This project is available only in for R121 and mainline. To retain dual maintenance INV code changes are made in branchline, however it will not affect any existing flow.
      IF p_wave_simulation_mode = 'N' THEN
      OPEN l_mold_crs(p_mo_line_rec.line_id);

      LOOP
        -- Retrieve each Move Order Line Detail and get the pick slip number for each
        FETCH l_mold_crs INTO l_mold_temp_id, l_mold_sub_code, l_from_locator_id, l_dest_subinv,
                              l_project_id, l_task_id, l_to_locator_id, l_revision;

        IF l_mold_crs%FOUND THEN
            -- bug 1159171. check if the org is dynamic locator control
            -- or if the sub is dynamic locator contro, and there is project and task
            -- for the move order line, then create a new locator with the project
            -- and task.
          IF (is_debug) THEN
            print_debug('Calling process_prj_dynamic_locator with the following values','Inv_Pick_Release_PVT.Process_Line');
            print_debug('p_from_locator_id ==> '||l_from_locator_id, 'Inv_Pick_Release_PVT.Process_Line');
            print_debug('p_to_locator_id   ==> '||l_to_locator_id, 'Inv_Pick_Release_PVT.Process_Line');
            print_debug('p_mold_temp_id    ==> '||l_mold_temp_id, 'Inv_Pick_Release_PVT.Process_Line');
            print_debug('p_mold_sub_code   ==> '||l_mold_sub_code, 'Inv_Pick_Release_PVT.Process_Line');
          END IF;

          /*Bug Number:3229204:l_to_locator_id was passed as a parameter for p_to_locator_id as well
          as x_to_locator_id .x_to_locator id is a out parameter with no copy hint,which was causing
          l_to_locator_id to be nulled out.*/

          process_prj_dynamic_locator(
                p_mo_line_rec                => p_mo_line_rec
              , p_mold_temp_id               => l_mold_temp_id
              , p_mold_sub_code              => l_mold_sub_code
              , p_from_locator_id            => l_from_locator_id
              , p_to_locator_id              => l_to_locator_id
              , x_return_status              => l_api_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , x_to_locator_id                   => l_dest_locator_id
              , p_to_subinventory            => l_dest_subinv
              );



          IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
            ROLLBACK TO process_line_pvt;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          IF (is_debug) THEN
            print_debug('Value of locator id obtained from process_prj_dynamic_locator '||l_dest_locator_id,'Inv_Pick_Release_PVT.Process_Line');
          END IF;


          -- patchset J, bulk picking -------------------
          if (WMS_INSTALL.check_install(
                        x_return_status   => l_api_return_status,
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data,
                        p_organization_id => p_mo_line_rec.organization_id
                ) = TRUE
            and WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= INV_RELEASE.G_J_RELEASE_LEVEL) then
                IF (l_debug = 1) THEN
                   print_debug('PATCHSET J -- BULK PICKING, do not assign pick slip number now', 'Inv_Pick_Release_PVT.Process_Line');
                END IF;
          ELSE -- INV org or before patchset J

            IF (is_debug) THEN
              print_debug('get pick slip number','Inv_Pick_Release_PVT.Process_Line');
            END IF;
            l_call_mode  := NULL;
            -- Bug 2666620: Inline branching to call either WSH or INV get_pick_slip_number
            /* FP-J PAR Replenishment Counts: Pass 4 new parameters for grouping */
            get_pick_slip_number(
                p_ps_mode                    => l_pick_slip_mode
              , p_pick_grouping_rule_id      => p_grouping_rule_id
              , p_org_id                     => p_mo_line_rec.organization_id
              , p_header_id                  => l_demand_info.oe_header_id
              , p_customer_id                => l_demand_info.customer_id
              , p_ship_method_code           => l_demand_info.freight_code
              , p_ship_to_loc_id             => l_demand_info.ship_to_location
              , p_shipment_priority          => l_demand_info.shipment_priority_code
              , p_subinventory               => l_mold_sub_code
              , p_trip_stop_id               => l_demand_info.trip_stop_id
              , p_delivery_id                => l_demand_info.shipping_delivery_id
              , x_pick_slip_number           => l_pick_slip_number
              , x_ready_to_print             => l_ready_to_print
              , x_api_status                 => l_api_return_status
              , x_error_message              => l_api_error_msg
              , x_call_mode                  => l_call_mode
              , p_dest_subinv                => l_dest_subinv
              , p_dest_locator_id            => l_dest_locator_id --Bug Number:3229204:Passing l_dest_locator_id instead of l_to_locator_id
              , p_project_id                 => l_project_id
              , p_task_id                    => l_task_id
              , p_inventory_item_id          => p_mo_line_rec.inventory_item_id
              , p_locator_id                 => l_from_locator_id
              , p_revision                   => l_revision
            );
            IF (is_debug) THEN
              print_debug('l_call_mode'|| l_call_mode, 'Inv_Pick_Release_PVT.Process_Line');
            END IF;

            IF l_api_return_status <> fnd_api.g_ret_sts_success OR l_pick_slip_number = -1 THEN
              ROLLBACK TO process_line_pvt;
              fnd_message.set_name('INV', 'INV_NO_PICK_SLIP_NUMBER');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF ( l_pick_slip_mode <> 'I' ) THEN
              WSH_INV_INTEGRATION_GRP.FIND_PRINTER
                ( p_subinventory    => l_mold_sub_code
                , p_organization_id => p_mo_line_rec.organization_id
                , x_error_message   => l_api_error_msg
                , x_api_Status      => l_api_return_status
                ) ;

              IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                IF (is_debug) THEN
                  print_debug('return error from WSH_INV_INTEGRATION.find_printer','Inv_Pick_Release_Pvt.Process_Line');
                END IF;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END IF ;
              -- Assign the pick slip number to the record in MTL_MATERIAL_TRANSACTIONS_TEMP
            UPDATE mtl_material_transactions_temp
               SET pick_slip_number = l_pick_slip_number
                 , transaction_source_id = l_mso_header_id
                 , trx_source_line_id = l_demand_info.oe_line_id
                 , demand_source_header_id = l_mso_header_id
                 , demand_source_line = l_demand_info.oe_line_id
                 , transfer_to_location = l_dest_locator_id
               WHERE transaction_temp_id = l_mold_temp_id;

            -- If the pick slip is ready to be printed (and partial
            -- picking is allowed) commit
            -- and print at this point.
            -- Bug 1663376 - Don't Commit if Ship_set_Id is not null,
            --  since we need to be able to rollback
            IF  l_ready_to_print = fnd_api.g_true
            AND p_allow_partial_pick = fnd_api.g_true
            AND p_mo_line_rec.ship_set_id IS NULL
            AND p_mo_line_rec.ship_model_id IS NULL
            AND l_call_mode IS NULL THEN
                COMMIT WORK;

              l_return_value := INV_CACHE.set_mtrh_rec(p_mo_line_rec.header_id);
              IF NOT l_return_value THEN
                If is_debug THEN
                  print_debug('Error setting header cache','Inv_Pick_Release_PVT.Process_Line');
                End If;
                raise fnd_api.g_exc_unexpected_error;
              END IF;
              l_request_number := INV_CACHE.mtrh_rec.request_number;

              IF g_request_number is NOT NULL and
                g_request_number = l_request_number AND
                g_report_set_id IS NOT NULL THEN
                l_report_set_id := g_report_set_id;
              ELSE
                BEGIN
                  SELECT document_set_id
                    INTO l_report_set_id
                    FROM wsh_picking_batches
                   WHERE NAME = l_request_number;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      IF is_debug THEN
                        print_debug('No Data found - document set',
                            'Inv_Pick_Release_PVT.Process_Line');
                      END IF;
                      x_return_status  := fnd_api.g_ret_sts_error;
                      RAISE fnd_api.g_exc_error;
                END;
                g_request_number := l_request_number;
                g_report_set_id := l_report_set_id;
              END IF;
              wsh_pr_pick_slip_number.print_pick_slip(
                  p_pick_slip_number           => l_pick_slip_number
                , p_report_set_id              => l_report_set_id
                , p_organization_id            => p_mo_line_rec.organization_id
                , x_api_status                 => l_api_return_status
                , x_error_message              => l_api_error_msg
              );
              IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                ROLLBACK TO process_line_pvt;
                fnd_message.set_name('INV', 'INV_PRINT_PICK_SLIP_FAILED');
                fnd_message.set_token('PICK_SLIP_NUM', TO_CHAR(l_pick_slip_number));
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END IF;
          END IF; -- end the patchset J and WMS org check
        END IF;

        EXIT WHEN l_mold_crs%NOTFOUND;
      END LOOP;

      CLOSE l_mold_crs;
      END IF; -- p_wave_simulation_mode = 'N'
    END IF; -- if l_num_detail_rec > 0

    -- If the line was only partially detailed and the API was about to return success,
    -- set the return status to 'P' (for partial) instead.
    IF  x_return_status = fnd_api.g_ret_sts_success
     AND l_partially_detailed = 1 THEN
          IF (is_debug) THEN
             print_debug('x_return_status is '|| x_return_status, 'Inv_Pick_Release_PVT.Process_Line');
          END IF;
          x_return_status  := 'P';
    END IF;

    select quantity_detailed
         , secondary_quantity_detailed
      into l_quantity_detailed
         , l_sec_quantity_detailed
      from mtl_txn_request_lines
     WHERE line_id = p_mo_line_rec.line_id;
    print_debug('Quantity_detailed is '|| l_quantity_detailed,'Inv_Pick_Release_PVT.Process_Line');
    print_debug('2nd after select sec Quantity_detailed is '|| l_sec_quantity_detailed, 'Inv_Pick_Release_PVT.Process_Line');

    --x_detail_rec_count := l_num_detail_recs;
    -- Standard call to commit
    <<end_pick>>
    IF  p_commit = fnd_api.g_true
      AND p_allow_partial_pick = fnd_api.g_true THEN
        COMMIT;
    END IF;
    print_debug('Commit? is '|| p_commit, 'Inv_Pick_Release_PVT.Process_Line');

    x_detail_rec_count  := l_num_detail_recs;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  END process_line;
END inv_pick_release_pvt;

/
