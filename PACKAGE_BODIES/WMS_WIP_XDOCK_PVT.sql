--------------------------------------------------------
--  DDL for Package Body WMS_WIP_XDOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WIP_XDOCK_PVT" AS
  /* $Header: WMSWIPCB.pls 120.4.12010000.2 2009/06/18 08:11:11 abasheer ship $ */

  --  Global constant holding the package name
  g_pkg_name CONSTANT VARCHAR2(30)              := 'WMS_WIP_XDock_Pvt';
  g_header_printed    BOOLEAN                   := FALSE;
  g_user_name         fnd_user.user_name%TYPE   := fnd_global.user_name;

  PROCEDURE mydebug(msg IN VARCHAR2) IS
    l_msg   VARCHAR2(5100);
    l_ts    VARCHAR2(30);
    l_debug NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH:MM:SS')
      INTO l_ts
      FROM DUAL;

    l_msg  := l_ts || '  ' || msg;

    IF (g_header_printed = FALSE) THEN
      inv_mobile_helper_functions.tracelog(p_err_msg => '$Header: WMSWIPCB.pls 120.4.12010000.2 2009/06/18 08:11:11 abasheer ship $', p_module => g_pkg_name || ' - ' || 'wms_cross_dock_pvt', p_level => 4);
      g_header_printed  := TRUE;
    END IF;

    inv_mobile_helper_functions.tracelog(p_err_msg => g_user_name || ': ' || l_msg, p_module => 'wms_cross_dock_pvt', p_level => 4);
    --dbms_output.put_line(msg);
    NULL;
  END mydebug;

  PROCEDURE wip_chk_crossdock(
    p_org_id             IN            NUMBER
  , p_lpn                IN            NUMBER := NULL
  , x_ret                OUT NOCOPY    NUMBER
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , p_move_order_line_id IN            NUMBER DEFAULT NULL   -- added for ATF_J
  ) IS
    l_wip_id                     NUMBER;
    l_wip_item                   NUMBER;
    l_wip_qty                    NUMBER;
    l_wip_uom                    VARCHAR2(3);
    l_count                      NUMBER;
    l_ret                        NUMBER;
    l_lpn_qty                    NUMBER;
    l_new_qty                    NUMBER;
    l_org_id                     NUMBER;
    l_inventory_item_id          NUMBER;
    l_qty                        NUMBER;
    l_uom                        VARCHAR2(3);
    l_lpn_id                     NUMBER;
    l_project_id                 NUMBER                                := NULL;
    l_task_id                    NUMBER                                := NULL;
    l_reference                  VARCHAR2(240)                         := NULL;
    l_reference_type_code        NUMBER                                := NULL;
    l_reference_id               NUMBER                                := NULL;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number                 VARCHAR2(80);
    l_revision                   VARCHAR2(3);
    l_header_id                  NUMBER                                := NULL;
    l_sub                        VARCHAR2(10)                          := NULL;
    l_loc                        NUMBER                                := NULL;
    l_to_sub                     VARCHAR2(10)                          := NULL;
    l_to_loc                     NUMBER                                := NULL;
    l_inspection_status          NUMBER                                := NULL;
    l_txn_source_id              NUMBER;
    l_transaction_type_id        NUMBER;
    l_transaction_source_type_id NUMBER;
    l_line_id                    NUMBER;
    l_partial_alloc_qty          NUMBER;
    l_return_status              VARCHAR2(1);
    l_trip_stop_id               NUMBER;
    b_no_more_lines              BOOLEAN;
    l_shipping_attr              wsh_interface.changedattributetabtype;
    b_wip_not_fulfilled          BOOLEAN;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(240);
    --b_no_more_lines  boolean;
    l_cnt1                       NUMBER;
    l_insp_cnt                   NUMBER                                := 0;
    l_wip_entity_id              NUMBER;
    l_operation_seq_num          NUMBER;
    l_repetitive_schedule_id     NUMBER;
    l_primary_uom                VARCHAR2(3);
    l_wip_issue_flag             VARCHAR2(1)                           := NULL;
    l_subinventory_code          VARCHAR2(50)                          := NULL;
    l_locator_id                 NUMBER                                := NULL;
    indx                         NUMBER                                := 0;
    l_quantity_allocated         NUMBER                                := 0;

    CURSOR wip_csr IS
      SELECT w.wip_entity_id wip_entity_id
           , w.quantity_backordered requested_quantity
           , w.inventory_item_id inventory_item_id
           , w.repetitive_schedule_id
           , w.operation_seq_num
           , w.wip_issue_flag
           , w.subinventory_code
           , w.locator_id
        FROM wip_material_shortages_v w, mtl_txn_request_lines l
       WHERE l.lpn_id = l_lpn_id
         AND l.line_id = NVL(p_move_order_line_id, l.line_id)   -- added for ATF_J
         AND l.organization_id = l_org_id
         AND w.organization_id = l_org_id
         AND NVL(l.project_id, -999) = NVL(w.project_id, -999)
         AND NVL(l.task_id, -999) = NVL(w.task_id, -999)
         AND w.inventory_item_id = l.inventory_item_id
         AND l.backorder_delivery_detail_id IS NULL
         AND(l.quantity_detailed IS NULL
             OR l.quantity_delivered IS NULL
             OR l.quantity_delivered = 0) ;

    l_debug                      NUMBER                                := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_tmp_line_id NUMBER;
  BEGIN
    l_return_status                                  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('In WIP crossdock check api...');
    END IF;

    l_lpn_id                                         := p_lpn;
    l_org_id                                         := p_org_id;
    l_ret                                            := 1;
    l_count                                          := 0;
    l_partial_alloc_qty                              := 0;
    b_no_more_lines                                  := FALSE;
    b_wip_not_fulfilled                              := FALSE;
    -- b_no_more_lines :=FALSE;
    l_cnt1                                           := 0;
    l_insp_cnt                                       := 0;
    -- First check to see if there are any crossdock opportunities
    -- at all
    wms_task_dispatch_put_away.crdk_wip_info_table.DELETE;
    wms_task_dispatch_put_away.crdk_wip_table_index  := 0;

    BEGIN
      SELECT 1
        INTO l_count
        FROM DUAL
       WHERE EXISTS(
               SELECT 1
                 FROM wip_material_shortages_v b, mtl_txn_request_lines l
                WHERE l.lpn_id = l_lpn_id
                  AND l.line_id = NVL(p_move_order_line_id, l.line_id)   -- added for ATF_J
                  AND l.organization_id = l_org_id
                  AND b.organization_id = l.organization_id
                  AND NVL(l.project_id, -999) = NVL(b.project_id, -999)
                  AND NVL(l.task_id, -999) = NVL(b.task_id, -999)
                  AND b.inventory_item_id = l.inventory_item_id
                  AND l.backorder_delivery_detail_id IS NULL
                  AND(l.quantity_detailed IS NULL
                      OR l.quantity_detailed = 0));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_count  := 0;
    END;

    IF (l_debug = 1) THEN
      mydebug('l_count ' || l_count);
    END IF;

    -- Checking to see if material is rejected
    BEGIN
      SELECT 1
        INTO l_insp_cnt
        FROM DUAL
       WHERE EXISTS(
               SELECT 1
                 FROM mtl_txn_request_lines
                WHERE lpn_id = l_lpn_id
                  AND line_id = NVL(p_move_order_line_id, line_id)   -- added for ATF_J
                  AND organization_id = l_org_id
                  AND NVL(inspection_status, 2) = 3);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_insp_cnt  := 0;
    END;

    IF (l_debug = 1) THEN
      mydebug('l_insp_cnt ' || l_insp_cnt);
    END IF;

    IF (l_count > 0
        AND l_insp_cnt = 0) THEN
      IF (l_debug = 1) THEN
        mydebug('CrossDock Opp exists and material has not been rejected');
      END IF;

      OPEN wip_csr;

      LOOP
        IF (l_debug = 1) THEN
          mydebug('Fetching from wip csr');
        END IF;

        FETCH wip_csr
         INTO l_wip_id
            , l_wip_qty
            , l_wip_item
            , l_repetitive_schedule_id
            , l_operation_seq_num
            , l_wip_issue_flag
            , l_subinventory_code
            , l_locator_id;

        EXIT WHEN wip_csr%NOTFOUND;

        -- get loc and sub if trip stip id is null
        -- else call api to get staging sub and loc
        -- IF b_no_more_lines THEN
        --   EXIT;
        -- END IF;
        IF (l_debug = 1) THEN
          mydebug('WIP Id:' || l_wip_id);
        END IF;

        b_wip_not_fulfilled  := FALSE;
        l_ret                := 0;

        --IF l_cnt1>=l_count THEN
          -- mydebug('No More MOLs');
           --EXIT;
        --END IF;
        SELECT default_crossdock_subinventory
             , default_crossdock_locator_id
          INTO l_to_sub
             , l_to_loc
          FROM mtl_parameters
         WHERE organization_id = l_org_id;

        IF ((l_to_sub IS NULL)
            OR(l_to_loc IS NULL)) THEN
          SELECT default_stage_subinventory
               , default_stage_locator_id
            INTO l_to_sub
               , l_to_loc
            FROM wsh_shipping_parameters
           WHERE organization_id = l_org_id;
        END IF;

        -- Check against mo lines

        -- comment the below line for back flush testing
        --l_wip_issue_flag := 'Y';
        IF (l_wip_issue_flag <> 'Y') THEN
          IF (l_debug = 1) THEN
            mydebug(' Shortage is not for a wip issue ');
          END IF;

          IF ((l_subinventory_code IS NOT NULL)
              AND(l_locator_id IS NOT NULL)) THEN
            IF (l_debug = 1) THEN
              mydebug(' subinventory AND LOC is not null on the line');
            END IF;

            l_to_sub  := l_subinventory_code;
            l_to_loc  := l_locator_id;
          ELSE
            IF (l_debug = 1) THEN
              mydebug(' subinventory is null on the line');
              mydebug(' using shipping parameters sub and loc ');
            END IF;
          END IF;
        END IF;

        IF (l_debug = 1) THEN
          mydebug('Staging Sub' || l_to_sub);
        END IF;

        l_partial_alloc_qty  := 0;

        -- OPEN lpn_csr;
        LOOP
          BEGIN
            SELECT mol.organization_id
                 , mol.inventory_item_id
                 , mol.quantity
                 , mol.uom_code
                 , mol.lot_number
                 , mol.revision
                 , mol.project_id
                 , mol.task_id
                 , mol.REFERENCE
                 , mol.reference_type_code
                 , mol.reference_id
                 , mol.header_id
                 , mol.txn_source_id
                 , mol.transaction_type_id
                 , mol.transaction_source_type_id
                 , mol.from_subinventory_code
                 , mol.from_locator_id
                 , mol.inspection_status
                 , mol.line_id
                 , msi.primary_uom_code
              INTO l_org_id
                 , l_inventory_item_id
                 , l_qty
                 , l_uom
                 , l_lot_number
                 , l_revision
                 , l_project_id
                 , l_task_id
                 , l_reference
                 , l_reference_type_code
                 , l_reference_id
                 , l_header_id
                 , l_txn_source_id
                 , l_transaction_type_id
                 , l_transaction_source_type_id
                 , l_sub
                 , l_loc
                 , l_inspection_status
                 , l_line_id
                 , l_primary_uom
              FROM mtl_txn_request_lines mol, mtl_system_items msi
             WHERE lpn_id = l_lpn_id
               AND line_id = NVL(p_move_order_line_id, line_id)   -- added for ATF_J
               AND mol.organization_id = l_org_id
               AND mol.inventory_item_id = l_wip_item
               AND mol.backorder_delivery_detail_id IS NULL
               AND mol.inventory_item_id = msi.inventory_item_id
               AND mol.organization_id = msi.organization_id
               AND ROWNUM = 1;

            IF (l_debug = 1) THEN
              mydebug('MOL:' || l_line_id);
            END IF;

            l_cnt1  := l_cnt1 + 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                mydebug('No data');
              END IF;

              --b_no_more_lines:=TRUE;
               /*IF b_wip_not_fulfilled THEN
              mark_wip(p_line_id => l_line_id,
                     p_wip_entity_id =>l_wip_id,
                     p_operation_seq_num =>l_operation_seq_num,
                     p_inventory_item_id=>l_inventory_item_id,
                     p_repetitive_schedule_id =>l_repetitive_schedule_id,
                     p_primary_quantity =>l_partial_alloc_qty,
                     x_quantity_allocated => l_quantity_allocated,
                     x_return_status =>l_return_status,
                     x_msg_data =>l_msg_data,
                     p_primary_uom =>l_primary_uom,
                           p_uom =>l_uom);

                l_partial_alloc_qty :=0;
                END IF;
                */
              EXIT;
          END;

          l_lpn_qty  := l_qty;

          -- Compare qty
          -- if lpn_qty is more than delivery qty, call pick release
          -- for this delivery detail, continue loop
          -- else, split delivery line and pick release the line that
          -- we can satisfy

          -- Check to see if the UOMs are the same. if not, convert
          IF (l_debug = 1) THEN
            mydebug('in 2nd loop');
          END IF;

          IF l_uom <> l_primary_uom THEN
            --convert qty to same uom
            IF (l_debug = 1) THEN
              mydebug('Converting Qty');
            END IF;

            l_wip_qty  :=
              inv_convert.inv_um_convert(
                item_id                      => l_inventory_item_id
              , PRECISION                    => NULL
              , from_quantity                => l_wip_qty
              , from_unit                    => l_primary_uom
              , to_unit                      => l_uom
              , from_name                    => NULL
              , to_name                      => NULL
              );

            IF (l_debug = 1) THEN
              mydebug('Converted Qty ' || l_wip_qty);
            END IF;
          END IF;

          IF l_lpn_qty > l_wip_qty THEN
            IF (l_debug = 1) THEN
              mydebug('MOL>WIP');
            END IF;

                -- update mol with new qty
                --UPDATE mtl_txn_request_lines SET
            --quantity=l_wip_qty,BACKORDER_DELIVERY_DETAIL_ID=l_wip_id
            --,to_subinventory_code=l_to_sub,to_locator_id=l_to_loc, crossdock_type=2
            --WHERE line_id=l_line_id;

            -- Mark del detail as submitted
            IF (l_debug = 1) THEN
              mydebug('calling mark_wip');
            END IF;

            mark_wip(
              p_line_id                    => l_line_id
            , p_wip_entity_id              => l_wip_id
            , p_operation_seq_num          => l_operation_seq_num
            , p_inventory_item_id          => l_inventory_item_id
            , p_repetitive_schedule_id     => l_repetitive_schedule_id
            , p_primary_quantity           => l_wip_qty
            , x_quantity_allocated         => l_quantity_allocated
            , x_return_status              => l_return_status
            , x_msg_data                   => l_msg_data
            , p_primary_uom                => l_primary_uom
            , p_uom                        => l_uom
            );

            IF (l_debug = 1) THEN
              mydebug('after calling mark_wip');
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              fnd_message.set_name('WMS', 'WMS_TD_WIP_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              fnd_message.set_name('WMS', 'WMS_TD_WIP_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            ELSIF(l_return_status = 'L') THEN
              IF (l_debug = 1) THEN
                mydebug('Unable to lock the record');
                mydebug(' Getting next shortage ');
              END IF;

              EXIT;
            END IF;

            IF (l_debug = 1) THEN
              mydebug('qty allocated is ' || l_quantity_allocated);
            END IF;

            IF (l_quantity_allocated = 0) THEN
              EXIT;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('Updating the old mo line');
              END IF;

              UPDATE mtl_txn_request_lines
                 SET quantity = l_quantity_allocated
                   , backorder_delivery_detail_id = l_wip_id
                   , to_subinventory_code = l_to_sub
                   , to_locator_id = l_to_loc
                   , crossdock_type = 2
               WHERE line_id = l_line_id;
            END IF;

            IF (l_debug = 1) THEN
              mydebug('updating crdk_wip_table ');
            END IF;

            wms_task_dispatch_put_away.crdk_wip_table_index                              :=
                                                                                         wms_task_dispatch_put_away.crdk_wip_table_index + 1;
            indx                                                                         := wms_task_dispatch_put_away.crdk_wip_table_index;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).move_order_line_id      := l_line_id;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).wip_entity_id           := l_wip_id;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).operation_seq_num       := l_operation_seq_num;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).repetitive_schedule_id  := l_repetitive_schedule_id;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).wip_issue_flag          := l_wip_issue_flag;

            -- reduce lpn_qty
            --l_lpn_qty:=l_lpn_qty-l_wip_qty;
            IF (l_debug = 1) THEN
              mydebug('creating new lines..');
            END IF;

            -- create new mo line
            wms_task_dispatch_put_away.create_mo_line(
              p_org_id                     => l_org_id
            , p_inventory_item_id          => l_inventory_item_id
            , p_qty                        => l_lpn_qty - l_quantity_allocated
            , p_uom                        => l_uom
            , p_lpn                        => l_lpn_id
            , p_project_id                 => l_project_id
            , p_task_id                    => l_task_id
            , p_reference                  => l_reference
            , p_reference_type_code        => l_reference_type_code
            , p_reference_id               => l_reference_id
            , p_header_id                  => l_header_id
            , p_lot_number                 => l_lot_number
            , p_revision                   => l_revision
            , p_inspection_status          => l_inspection_status
            , p_txn_source_id              => l_txn_source_id
            , p_transaction_type_id        => l_transaction_type_id
            , p_transaction_source_type_id => l_transaction_source_type_id
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
	    , x_line_id                    => l_tmp_line_id
	      );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              fnd_message.set_name('WMS', 'WMS_TD_CMOL_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              fnd_message.set_name('WMS', 'WMS_TD_CMOL_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          -- Need to fetch next del line
          -- EXIT;
          ELSIF l_lpn_qty < l_wip_qty THEN
            IF (l_debug = 1) THEN
              mydebug('MOL<DEL');
            END IF;

            -- update mol with new qty
            -- Try to get next mol
            --UPDATE mtl_txn_request_lines SET
            --  BACKORDER_DELIVERY_DETAIL_ID=l_wip_id
            -- ,to_subinventory_code=l_to_sub,to_locator_id=l_to_loc,   crossdock_type=2
            --WHERE line_id=l_line_id;
            -- Call update shipping API with back order action

            --         l_wip_qty = l_wip_qty - l_lpn_qty;
            IF (l_debug = 1) THEN
              mydebug('Calling wip');
            END IF;

            mark_wip(
              p_line_id                    => l_line_id
            , p_wip_entity_id              => l_wip_id
            , p_operation_seq_num          => l_operation_seq_num
            , p_inventory_item_id          => l_inventory_item_id
            , p_repetitive_schedule_id     => l_repetitive_schedule_id
            , p_primary_quantity           => l_lpn_qty
            , x_quantity_allocated         => l_quantity_allocated
            , x_return_status              => l_return_status
            , x_msg_data                   => l_msg_data
            , p_primary_uom                => l_primary_uom
            , p_uom                        => l_uom
            );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              fnd_message.set_name('WMS', 'WMS_TD_WIP_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              fnd_message.set_name('WMS', 'WMS_TD_WIP_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            ELSIF(l_return_status = 'L') THEN
              IF (l_debug = 1) THEN
                mydebug('Unable to lock the record');
                mydebug(' Getting next shortage ');
              END IF;

              EXIT;
            END IF;

            IF (l_debug = 1) THEN
              mydebug('qty allocated ' || l_quantity_allocated);
            END IF;

            IF (l_quantity_allocated = 0) THEN
              EXIT;
            END IF;

            IF (l_lpn_qty > l_quantity_allocated) THEN
              IF (l_debug = 1) THEN
                mydebug(' l_lpn_qty > l_quantity_allocated ');
              END IF;

              IF (l_debug = 1) THEN
                mydebug('updating the old mol');
              END IF;

              UPDATE mtl_txn_request_lines
                 SET backorder_delivery_detail_id = l_wip_id
                   , quantity = l_quantity_allocated
                   , to_subinventory_code = l_to_sub
                   , to_locator_id = l_to_loc
                   , crossdock_type = 2
               WHERE line_id = l_line_id;

              IF (l_debug = 1) THEN
                mydebug('updating the crdk_wip_table');
              END IF;

              wms_task_dispatch_put_away.crdk_wip_table_index                              :=
                                                                                         wms_task_dispatch_put_away.crdk_wip_table_index + 1;
              indx                                                                         :=
                                                                                             wms_task_dispatch_put_away.crdk_wip_table_index;
              wms_task_dispatch_put_away.crdk_wip_info_table(indx).move_order_line_id      := l_line_id;
              wms_task_dispatch_put_away.crdk_wip_info_table(indx).wip_entity_id           := l_wip_id;
              wms_task_dispatch_put_away.crdk_wip_info_table(indx).operation_seq_num       := l_operation_seq_num;
              wms_task_dispatch_put_away.crdk_wip_info_table(indx).repetitive_schedule_id  := l_repetitive_schedule_id;
              wms_task_dispatch_put_away.crdk_wip_info_table(indx).wip_issue_flag          := l_wip_issue_flag;

              IF (l_debug = 1) THEN
                mydebug('creating a mol for the rest ');
              END IF;

              wms_task_dispatch_put_away.create_mo_line(
                p_org_id                     => l_org_id
              , p_inventory_item_id          => l_inventory_item_id
              , p_qty                        => l_lpn_qty - l_quantity_allocated
              , p_uom                        => l_uom
              , p_lpn                        => l_lpn_id
              , p_project_id                 => l_project_id
              , p_task_id                    => l_task_id
              , p_reference                  => l_reference
              , p_reference_type_code        => l_reference_type_code
              , p_reference_id               => l_reference_id
              , p_header_id                  => l_header_id
              , p_lot_number                 => l_lot_number
              , p_revision                   => l_revision
              , p_inspection_status          => l_inspection_status
              , p_txn_source_id              => l_txn_source_id
              , p_transaction_type_id        => l_transaction_type_id
              , p_transaction_source_type_id => l_transaction_source_type_id
              , x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
              , x_line_id                    => l_tmp_line_id
              );

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                fnd_message.set_name('WMS', 'WMS_TD_CMOL_ERROR');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                fnd_message.set_name('WMS', 'WMS_TD_CMOL_ERROR');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;

              IF (l_debug = 1) THEN
                mydebug(' exiting to get the next shortage ');
              END IF;

              EXIT;
            END IF;

            IF (l_debug = 1) THEN
              mydebug(' qty allocated is same as lpn_qty ');
              mydebug(' update old mol ');
            END IF;

            UPDATE mtl_txn_request_lines
               SET backorder_delivery_detail_id = l_wip_id
                 , to_subinventory_code = l_to_sub
                 , to_locator_id = l_to_loc
                 , crossdock_type = 2
             WHERE line_id = l_line_id;

            l_wip_qty                                                                    := l_wip_qty - l_lpn_qty;

            IF (l_debug = 1) THEN
              mydebug(' setting b_wip_not_fulfilled to true ');
            END IF;

            b_wip_not_fulfilled                                                          := TRUE;

            IF (l_debug = 1) THEN
              mydebug(' updating the crdk_wip_table ');
            END IF;

            wms_task_dispatch_put_away.crdk_wip_table_index                              :=
                                                                                         wms_task_dispatch_put_away.crdk_wip_table_index + 1;
            indx                                                                         := wms_task_dispatch_put_away.crdk_wip_table_index;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).move_order_line_id      := l_line_id;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).wip_entity_id           := l_wip_id;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).operation_seq_num       := l_operation_seq_num;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).repetitive_schedule_id  := l_repetitive_schedule_id;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).wip_issue_flag          := l_wip_issue_flag;
          --l_lpn_qty:=0;
          ELSIF l_lpn_qty = l_wip_qty THEN
            IF (l_debug = 1) THEN
              mydebug('MOL=DEL');
            END IF;

            IF (l_debug = 1) THEN
              mydebug(' calling mark_wip ');
            END IF;

            -- Mark wip as allocated
            mark_wip(
              p_line_id                    => l_line_id
            , p_wip_entity_id              => l_wip_id
            , p_operation_seq_num          => l_operation_seq_num
            , p_inventory_item_id          => l_inventory_item_id
            , p_repetitive_schedule_id     => l_repetitive_schedule_id
            , p_primary_quantity           => l_wip_qty
            , x_quantity_allocated         => l_quantity_allocated
            , x_return_status              => l_return_status
            , x_msg_data                   => l_msg_data
            , p_primary_uom                => l_primary_uom
            , p_uom                        => l_uom
            );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              fnd_message.set_name('WMS', 'WMS_TD_WIP_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              fnd_message.set_name('WMS', 'WMS_TD_WIP_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            ELSIF(l_return_status = 'L') THEN
              IF (l_debug = 1) THEN
                mydebug('Unable to lock the record');
                mydebug(' Getting next shortage ');
              END IF;

              EXIT;
            END IF;

            IF (l_debug = 1) THEN
              mydebug(' qty allocated ' || l_quantity_allocated);
            END IF;

            IF (l_quantity_allocated = 0) THEN
              EXIT;
            END IF;

            IF (l_lpn_qty > l_quantity_allocated) THEN
              IF (l_debug = 1) THEN
                mydebug('l_lpn_qty > l_quantity_allocated ');
                mydebug('updating the old mol ');
              END IF;

              UPDATE mtl_txn_request_lines
                 SET backorder_delivery_detail_id = l_wip_id
                   , quantity = l_quantity_allocated
                   , to_subinventory_code = l_to_sub
                   , to_locator_id = l_to_loc
                   , crossdock_type = 2
               WHERE line_id = l_line_id;

              IF (l_debug = 1) THEN
                mydebug('updating the crdk_wip_table ');
              END IF;

              wms_task_dispatch_put_away.crdk_wip_table_index                              :=
                                                                                         wms_task_dispatch_put_away.crdk_wip_table_index + 1;
              indx                                                                         :=
                                                                                             wms_task_dispatch_put_away.crdk_wip_table_index;
              wms_task_dispatch_put_away.crdk_wip_info_table(indx).move_order_line_id      := l_line_id;
              wms_task_dispatch_put_away.crdk_wip_info_table(indx).wip_entity_id           := l_wip_id;
              wms_task_dispatch_put_away.crdk_wip_info_table(indx).operation_seq_num       := l_operation_seq_num;
              wms_task_dispatch_put_away.crdk_wip_info_table(indx).repetitive_schedule_id  := l_repetitive_schedule_id;
              wms_task_dispatch_put_away.crdk_wip_info_table(indx).wip_issue_flag          := l_wip_issue_flag;

              IF (l_debug = 1) THEN
                mydebug('creating new mol for the rest ');
              END IF;

              wms_task_dispatch_put_away.create_mo_line(
                p_org_id                     => l_org_id
              , p_inventory_item_id          => l_inventory_item_id
              , p_qty                        => l_lpn_qty - l_quantity_allocated
              , p_uom                        => l_uom
              , p_lpn                        => l_lpn_id
              , p_project_id                 => l_project_id
              , p_task_id                    => l_task_id
              , p_reference                  => l_reference
              , p_reference_type_code        => l_reference_type_code
              , p_reference_id               => l_reference_id
              , p_header_id                  => l_header_id
              , p_lot_number                 => l_lot_number
              , p_revision                   => l_revision
              , p_inspection_status          => l_inspection_status
              , p_txn_source_id              => l_txn_source_id
              , p_transaction_type_id        => l_transaction_type_id
              , p_transaction_source_type_id => l_transaction_source_type_id
              , x_return_status              => l_return_status
              , x_msg_count                  => l_msg_count
              , x_msg_data                   => l_msg_data
	      , x_line_id                    => l_tmp_line_id
              );

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                fnd_message.set_name('WMS', 'WMS_TD_CMOL_ERROR');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_unexpected_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                fnd_message.set_name('WMS', 'WMS_TD_CMOL_ERROR');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;

              IF (l_debug = 1) THEN
                mydebug(' exiting to get the next shortage ');
              END IF;

              EXIT;
            END IF;

            IF (l_debug = 1) THEN
              mydebug('qty allocated equals lpn_qty ');
              mydebug('updating the old mol ');
            END IF;

            UPDATE mtl_txn_request_lines
               SET backorder_delivery_detail_id = l_wip_id
                 , to_subinventory_code = l_to_sub
                 , to_locator_id = l_to_loc
                 , crossdock_type = 2
             WHERE line_id = l_line_id;

            IF (l_debug = 1) THEN
              mydebug('updating the crdk_wip_table_index ');
            END IF;

            wms_task_dispatch_put_away.crdk_wip_table_index                              :=
                                                                                         wms_task_dispatch_put_away.crdk_wip_table_index + 1;
            indx                                                                         := wms_task_dispatch_put_away.crdk_wip_table_index;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).move_order_line_id      := l_line_id;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).wip_entity_id           := l_wip_id;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).operation_seq_num       := l_operation_seq_num;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).repetitive_schedule_id  := l_repetitive_schedule_id;
            wms_task_dispatch_put_away.crdk_wip_info_table(indx).wip_issue_flag          := l_wip_issue_flag;

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              fnd_message.set_name('WMS', 'WMS_TD_MK_DEL_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
              fnd_message.set_name('WMS', 'WMS_TD_MK_DEL_ERROR');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          -- Qty's match. Pick release the delivery detail
          --l_lpn_qty:=0;
          END IF;

          IF (b_wip_not_fulfilled = FALSE) THEN
            -- This lpn qty has been consumed, get the next line
            IF (l_debug = 1) THEN
              mydebug('Del not fulfilled');
            END IF;

            EXIT;
          END IF;
        END LOOP;
      END LOOP;

      CLOSE wip_csr;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('No CrossDock Opp for WIP');
      END IF;

      l_ret  := 1;
    END IF;

    x_ret                                            := l_ret;
    x_return_status                                  := l_return_status;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_ret            := 2;
      x_return_status  := l_return_status;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_ret            := 2;
      x_return_status  := l_return_status;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_ret            := 2;
      x_return_status  := l_return_status;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END wip_chk_crossdock;

  PROCEDURE wip_complete_crossdock(
    p_org_id            IN            NUMBER
  , p_temp_id           IN            NUMBER
  , p_wip_id            IN            NUMBER
  , p_inventory_item_id IN            NUMBER
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  ) IS
      /*
        ,p_del_id NUMBER
        ,p_mo_line_id NUMBER
        , p_item_id NUMBER
    ,x_return_status     OUT VARCHAR2
    */
    l_cnt_lpn_id             NUMBER;
    l_msg_cnt                NUMBER;
    -- l_msg_data VARCHAR2(240);
    l_org_id                 NUMBER;
    l_item_id                NUMBER;
    l_ret                    NUMBER;
    l_temp_id                NUMBER;
    l_del_id                 NUMBER;
    l_mo_line_id             NUMBER;
    l_demand_source_type     NUMBER;
    l_mso_header_id          NUMBER;   -- The MTL_SALES_ORDERS
    --header ID, which should be derived from the OE header ID
    -- and used for reservation queries.
    l_shipping_attr          wsh_interface.changedattributetabtype;
    l_update_rsv_rec         inv_reservation_global.mtl_reservation_rec_type;
    l_demand_info            wsh_inv_delivery_details_v%ROWTYPE;
    l_prim_qty               NUMBER;
    l_prim_uom               VARCHAR2(3);
    l_sub                    VARCHAR2(10);
    l_loc                    NUMBER;
    l_return_status          VARCHAR2(1);
    l_api_return_status      VARCHAR2(1);
    l_org_wide_res_id        NUMBER;
    l_qty_succ_reserved      NUMBER;
    l_msg_data               VARCHAR2(2400);
    l_dummy_sn               inv_reservation_global.serial_number_tbl_type;
    l_source_header_id       NUMBER;
    l_source_line_id         NUMBER;
    l_rev                    VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot                    VARCHAR2(80);
    l_lot_count              NUMBER;
    l_lot_control_code       NUMBER;
    l_serial_control_code    NUMBER;
    l_serial_trx_id          NUMBER;
    l_transaction_type_id    NUMBER;
    l_action_flag            VARCHAR2(1);
    l_serial_temp_id         NUMBER;
    l_serial_number          VARCHAR2(30);
    l_order_source_id        NUMBER;
    l_label_status           VARCHAR2(2000);
    l_lpn_del_detail_id      NUMBER;
    l_new_temp_id            NUMBER;
    l_new_txn_hdr_id         NUMBER;
    l_txn_ret                NUMBER                                          := 0;
    l_wip_issue_flag         VARCHAR2(1)                                     := 'Y';
    line_id                  NUMBER                                          := NULL;
    item_id                  NUMBER                                          := NULL;
    l_wip_entity_id          NUMBER                                          := NULL;
    l_operation_seq_num      NUMBER                                          := NULL;
    l_repetitive_schedule_id NUMBER                                          := NULL;
    l_primary_quantity       NUMBER                                          := 0;
    l_transaction_quantity   NUMBER                                          := 0;
    l_mtl_lots_temp_rec      mtl_transaction_lots_temp%ROWTYPE;
    l_mtl_srl_temp_rec       mtl_serial_numbers_temp%ROWTYPE;
    l_returnstatus           VARCHAR2(1);
    l_lpn_id                 NUMBER                                          := NULL;
    l_transfer_lpn_id        NUMBER                                          := NULL;
    l_content_lpn_id         NUMBER                                          := NULL;
    l_bflow_exist            NUMBER;

    CURSOR serial_csr IS
      SELECT fm_serial_number
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = l_serial_temp_id;

    l_debug                  NUMBER                                          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('in WIP Complete cdock');
    END IF;

    l_org_id         := p_org_id;
    l_temp_id        := p_temp_id;
    l_ret            := 0;

       -- Need  to create a new MMTT line and call TM here!
    /*
       SELECT mtl_material_transactions_s.NEXTVAL
         INTO l_new_temp_id
         FROM  dual;

       SELECT mtl_material_transactions_s.NEXTVAL
         INTO l_new_txn_hdr_id
         FROM  dual;
     */

    --mydebug('l_new_temp_id = ' || l_new_temp_id);
    BEGIN
      SELECT move_order_line_id
           , DECODE(wip_supply_type, 1, 'Y', 'N')
           , demand_source_header_id
           , repetitive_line_id
           , operation_seq_num
           , NVL(primary_quantity, 0)
           , NVL(transaction_quantity, 0)
           , lpn_id
           , content_lpn_id
           , transfer_lpn_id
        INTO line_id
           , l_wip_issue_flag
           , l_wip_entity_id
           , l_repetitive_schedule_id
           , l_operation_seq_num
           , l_primary_quantity
           , l_transaction_quantity
           , l_lpn_id
           , l_content_lpn_id
           , l_transfer_lpn_id
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = l_temp_id
         AND ROWNUM < 2;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('Cannot find the mmtt ');
        END IF;
    END;

    IF (l_debug = 1) THEN
      mydebug('l_wip_entity_id ' || l_wip_entity_id);
      mydebug('l_operation_seq_num ' || l_operation_seq_num);
      mydebug('l_repetitive_schedule_id' || l_repetitive_schedule_id);
      mydebug('l_wip_issue_flag' || l_wip_issue_flag);
    END IF;

    IF (l_wip_issue_flag = 'Y') THEN
      IF (l_debug = 1) THEN
        mydebug('wip isuue - before Insert into MMTT..');
      END IF;

      insert_new_mmtt_row_like(p_txn_temp_id => l_temp_id, x_new_temp_id => l_new_temp_id, x_new_hdr_id => l_new_txn_hdr_id);

      IF (l_debug = 1) THEN
        mydebug('l_new_temp_id = ' || l_new_temp_id);
        mydebug('after Insert into MMTT..');
      END IF;

      l_primary_quantity      := (-1) * l_primary_quantity;
      l_transaction_quantity  := (-1) * l_transaction_quantity;

      -- call sajus api here
      IF (l_debug = 1) THEN
        mydebug('calling wms_wip_integration.update_mmtt_for_wip without ');
      END IF;

      -- Bug  2375076 -- Removed the move order line iod from the parameter list
      BEGIN
        wms_wip_integration.update_mmtt_for_wip(
          p_transaction_temp_id        => l_new_temp_id
        , p_wip_entity_id              => l_wip_entity_id
        , p_operation_seq_num          => l_operation_seq_num
        , p_repetitive_schedule_id     => l_repetitive_schedule_id
        , p_transaction_type_id        => inv_globals.g_type_xfer_order_wip_issue
        );
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            mydebug('wms_wip_integration.update_mmtt_for_wip failed ');
          END IF;
      END;

      IF (l_debug = 1) THEN
        mydebug('after calling wms_wip_integration.update_mmtt_for_wip');
      END IF;

      IF (l_debug = 1) THEN
        mydebug(' making the qunatities neagative for wip issue');
        mydebug(' move order line is set to null');
        mydebug(' transaction_status = 1 ');
      END IF;

      --bug 2074100 fix
      --If the lpn is not compltely used for this issue
      --the quantity is dropped lose and hence we should issue
      --loose,
      --other wise content lpn id should be populated so that
      -- after the isuue the lpn context is automatically changed
      -- to defined but not used
      IF (l_content_lpn_id IS NULL) THEN
        IF (l_debug = 1) THEN
          mydebug(' l_content_lpn_id IS NULL ');
        END IF;

        IF (l_lpn_id = l_transfer_lpn_id) THEN
          IF (l_debug = 1) THEN
            mydebug('setting l_content_lpn_id := ' || l_lpn_id);
          END IF;

          l_content_lpn_id  := l_lpn_id;
        END IF;

        IF ((l_lpn_id IS NOT NULL)
            AND(l_transfer_lpn_id IS NULL)) THEN
          l_lpn_id           := NULL;
          l_content_lpn_id   := NULL;
          l_transfer_lpn_id  := NULL;

          IF (l_debug = 1) THEN
            mydebug(' lpn_id is set to NULL ');
            mydebug(' content_lpn_id is set to NULL');
            mydebug(' transfer_lpn_id is set to NULL');
          END IF;
        END IF;
      END IF;

      IF (l_debug = 1) THEN
        mydebug(' lpn_id ' || l_lpn_id);
        mydebug(' content_lpn_id ' || l_content_lpn_id);
        mydebug(' transfer_lpn_id ' || l_transfer_lpn_id);
      END IF;

      UPDATE mtl_material_transactions_temp
         SET move_order_line_id = NULL
           , transaction_status = 1
           , primary_quantity = l_primary_quantity
           , transaction_quantity = l_transaction_quantity
           --, lpn_id = l_lpn_id
           --, content_lpn_id = l_content_lpn_id
           --, transfer_lpn_id = l_transfer_lpn_id
      ,      wms_task_type = NULL   -- bug fix 3233053
       WHERE transaction_temp_id = l_new_temp_id;

      IF (l_debug = 1) THEN
        mydebug('update - complete');
      END IF;

      --   UPDATE mtl_material_transactions_temp
      --  SET
      --transaction_source_type_id = 5,
      --transaction_type_id = 35,
      --transaction_action_id = 1,
      --move_order_line_id = NULL,
      ---transaction_status = 1
      -- WHERE transaction_temp_id = l_new_temp_id;
      IF (l_debug = 1) THEN
        mydebug('after updating _mmtt move_order_line_id, transaction_status ');
      END IF;

      -- Bug 2829872, triggering label printing for Manufacturing Cross-Dock.
      BEGIN
        SELECT 1
          INTO l_bflow_exist
          FROM mfg_lookups
         WHERE lookup_type = 'WMS_BUSINESS_FLOW'
           AND lookup_code = 37;

        IF (l_debug = 1) THEN
          mydebug('Calling label printing API for Manufacturing Cross-Dock');
          mydebug('Transaction temp id: ' || l_new_temp_id);
        END IF;

        inv_label.print_label_wrap(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_cnt
        , x_msg_data                   => l_msg_data
        , x_label_status               => l_label_status
        , p_business_flow_code         => 37
        , p_transaction_id             => l_new_temp_id
        );

        IF (l_debug = 1) THEN
          mydebug('Return Status: ' || l_return_status);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      UPDATE mtl_material_transactions_temp
         SET lpn_id = l_lpn_id
           , content_lpn_id = l_content_lpn_id
           , transfer_lpn_id = l_transfer_lpn_id
       WHERE transaction_temp_id = l_new_temp_id;

      IF (l_debug = 1) THEN
        mydebug('After insert into MMTT');
        mydebug('Calling txn proc');
        mydebug('Hdr' || l_new_txn_hdr_id);
      END IF;

      -- Call the txn processor
      wms_wip_integration.wip_processor(p_txn_hdr_id => l_new_txn_hdr_id, p_business_flow_code => inv_label.wms_bf_wip_pick_drop
      , x_return_status              => x_return_status);

      IF (l_debug = 1) THEN
        mydebug('After Calling WIP txn proc STATUS' || x_return_status);
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('WMS', 'WMS_TD_TXNMGR_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    --Changed call above to WIP
    --l_txn_ret:=inv_lpn_trx_pub.PROCESS_LPN_TRX(p_trx_hdr_id=>l_new_txn_hdr_id,
    --           p_commit=> fnd_api.g_false,
    --x_proc_msg =>l_msg_data
     -- );
    --mydebug('After Calling txn proc');
    --mydebug('l_txn_ret : ' || l_txn_ret);
    --mydebug ('Txn Message'||l_msg_data);

    --COMMIT;
    --IF l_txn_ret<>0 THEN
       --FND_MESSAGE.SET_NAME('WMS','WMS_TD_TXNMGR_ERROR' );
       --fND_MSG_PUB.ADD;
      -- RAISE FND_API.g_exc_unexpected_error;
    --END IF;
    ELSE
      -- Bug 2829872, triggering label printing for Manufacturing Cross-Dock.
      BEGIN
        SELECT 1
          INTO l_bflow_exist
          FROM mfg_lookups
         WHERE lookup_type = 'WMS_BUSINESS_FLOW'
           AND lookup_code = 37;

        IF (l_debug = 1) THEN
          mydebug('Calling label printing API for Manufacturing Cross-Dock for pull component');
          mydebug('Transaction temp id: ' || l_temp_id);
        END IF;

        inv_label.print_label_wrap(
          x_return_status              => l_return_status
        , x_msg_count                  => l_msg_cnt
        , x_msg_data                   => l_msg_data
        , x_label_status               => l_label_status
        , p_business_flow_code         => 37
        , p_transaction_id             => l_temp_id
        );

        IF (l_debug = 1) THEN
          mydebug('Return Status: ' || l_return_status);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF (l_debug = 1) THEN
        mydebug(' Back FLUSH ');
      END IF;
    --Nothing to do
    /* Back FLUSH */

    --UPDATE mtl_material_transactions_temp
    --  SET
    --  transaction_source_type_id = 5,
    --  transaction_type_id = 35,
    --  transaction_action_id = 1,
    --  move_order_line_id = NULL,
    --  transaction_status = 1
     -- WHERE transaction_temp_id = l_new_temp_id;
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
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
      fnd_message.set_name('WMS', 'WMS_TD_CCDOCK_ERROR');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END wip_complete_crossdock;

  PROCEDURE mark_wip(
    p_line_id                IN            NUMBER
  , p_wip_entity_id          IN            NUMBER
  , p_operation_seq_num      IN            NUMBER
  , p_inventory_item_id      IN            NUMBER
  , p_repetitive_schedule_id IN            NUMBER
  , p_primary_quantity       IN            NUMBER
  , x_quantity_allocated     OUT NOCOPY    NUMBER
  , x_return_status          OUT NOCOPY    VARCHAR2
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , p_primary_uom            IN            VARCHAR2
  , p_uom                                  VARCHAR2
  ) IS
    l_ret                    VARCHAR2(1);
    l_wip_id                 NUMBER;
    l_operation_seq_num      NUMBER;
    l_inventory_item_id      NUMBER;
    l_repetitive_schedule_id NUMBER;
    l_wip_qty                NUMBER;
    l_uom                    VARCHAR2(3);
    l_primary_uom            VARCHAR2(3);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(240);
    l_return_status          VARCHAR2(1);
    l_qty_allocated          NUMBER;
    l_debug                  NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('in mark wip as allocated');
    END IF;

    l_wip_id                  := p_wip_entity_id;
    l_operation_seq_num       := p_operation_seq_num;
    l_inventory_item_id       := p_inventory_item_id;
    l_repetitive_schedule_id  := p_repetitive_schedule_id;
    l_wip_qty                 := p_primary_quantity;
    l_uom                     := p_uom;
    l_primary_uom             := l_primary_uom;
    l_wip_id                  := p_wip_entity_id;

    IF l_uom <> l_primary_uom THEN
      IF (l_debug = 1) THEN
        mydebug('UOM is different');
      END IF;

      l_wip_qty  :=
        inv_convert.inv_um_convert(
          item_id                      => l_inventory_item_id
        , PRECISION                    => NULL
        , from_quantity                => l_wip_qty
        , from_unit                    => l_uom
        , to_unit                      => l_primary_uom
        , from_name                    => NULL
        , to_name                      => NULL
        );
    END IF;

    IF (l_debug = 1) THEN
      mydebug('Before calling wip allocate mtl');
    END IF;

    wip_picking_pub.allocate_material(
      p_wip_entity_id              => l_wip_id
    , p_operation_seq_num          => l_operation_seq_num
    , p_inventory_item_id          => l_inventory_item_id
    , p_repetitive_schedule_id     => l_repetitive_schedule_id
    , p_primary_quantity           => l_wip_qty
    , x_quantity_allocated         => l_qty_allocated
    , x_return_status              => l_return_status
    , x_msg_data                   => l_msg_data
    );

    IF (l_debug = 1) THEN
      mydebug('return status' || l_ret);
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('WMS', 'WMS_TD_UPD_SHP_ERROR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('WMS', 'WMS_TD_UPD_SHP_ERROR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    --x_ret:=l_ret;
    x_return_status           := l_return_status;
    x_quantity_allocated      := l_qty_allocated;

    IF (l_debug = 1) THEN
      mydebug('returned quantity allocated ' || l_qty_allocated);
    END IF;

    IF ((l_wip_qty - l_qty_allocated) = 0) THEN
      IF (l_debug = 1) THEN
        mydebug('whole shortage has been removed');
      END IF;

      RETURN;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      --x_return_status:=l_return_status;
       --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      -- x_return_status:=l_return_status;
        --  Get message count and data
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --x_return_status:=l_return_status;
      fnd_message.set_name('WMS', 'WMS_TD_MW_ERROR');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
  END mark_wip;

  PROCEDURE insert_new_mmtt_row_like(p_txn_temp_id IN NUMBER, x_new_temp_id OUT NOCOPY NUMBER, x_new_hdr_id OUT NOCOPY NUMBER) IS
    SUBTYPE mmtt_type IS mtl_material_transactions_temp%ROWTYPE;

    mmtt_row                mmtt_type;

    SUBTYPE mtlt_type IS mtl_transaction_lots_temp%ROWTYPE;

    lot_row                 mtlt_type;

    SUBTYPE msnt_type IS mtl_serial_numbers_temp%ROWTYPE;

    ser_row                 msnt_type;
    l_new_txn_hdr_id        NUMBER      := -1;
    new_txn_temp_id         NUMBER      := -1;
    ser_transaction_temp_id NUMBER;
    v_lot_control_code      NUMBER      := -1;
    v_serial_control_code   NUMBER      := -1;
    v_allocate_serial_flag  VARCHAR2(1) := 'X';

    CURSOR mtlt(txn_tmp_id NUMBER) IS
      SELECT *
        FROM mtl_transaction_lots_temp
       WHERE transaction_temp_id = txn_tmp_id;

    CURSOR msnt(txn_tmp_id NUMBER) IS
      SELECT *
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = txn_tmp_id;

    l_debug                 NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    SELECT mtl_material_transactions_s.NEXTVAL
      INTO new_txn_temp_id
      FROM DUAL;

    x_new_temp_id                   := new_txn_temp_id;

    SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_new_txn_hdr_id
      FROM DUAL;

    x_new_hdr_id                    := l_new_txn_hdr_id;

    SELECT *
      INTO mmtt_row
      FROM mtl_material_transactions_temp
     WHERE transaction_temp_id = p_txn_temp_id;

    mmtt_row.transaction_temp_id    := new_txn_temp_id;
    mmtt_row.transaction_header_id  := l_new_txn_hdr_id;

    /*************NOW Updating MTLT and MSNT *************************/
    SELECT lot_control_code
         , serial_number_control_code
      INTO v_lot_control_code
         , v_serial_control_code
      FROM mtl_system_items
     WHERE inventory_item_id = mmtt_row.inventory_item_id
       AND organization_id = mmtt_row.organization_id;

    SELECT allocate_serial_flag
      INTO v_allocate_serial_flag
      FROM mtl_parameters
     WHERE organization_id = mmtt_row.organization_id;

    /*****LOT controlled only **********/
    IF (v_lot_control_code = 2
        AND v_serial_control_code IN(1, 6)) THEN
      IF (l_debug = 1) THEN
        mydebug(' LOT controlled only ');
      END IF;

      OPEN mtlt(p_txn_temp_id);

      LOOP
        FETCH mtlt
         INTO lot_row;

        EXIT WHEN mtlt%NOTFOUND;

        IF (l_debug = 1) THEN
          mydebug('child row with temp id ' || lot_row.transaction_temp_id);
        END IF;

        lot_row.transaction_temp_id  := new_txn_temp_id;
        inv_rcv_common_apis.insert_mtlt(lot_row);
        lot_row                      := NULL;
      END LOOP;

      IF mtlt%ISOPEN THEN
        CLOSE mtlt;
      END IF;
    /********* serial Controlled only **************/
    ELSIF(v_lot_control_code = 1
          AND v_serial_control_code NOT IN(1, 6)) THEN
      IF (l_debug = 1) THEN
        mydebug(' Serial controlled only ');
      END IF;

--      IF (v_allocate_serial_flag = 'Y') THEN -- For Bug#8498782
        IF (l_debug = 1) THEN
          mydebug(' allocate_serial_flag is Y ');
        END IF;

        OPEN msnt(p_txn_temp_id);

        LOOP
          FETCH msnt
           INTO ser_row;

          EXIT WHEN msnt%NOTFOUND;

          IF (l_debug = 1) THEN
            mydebug('child row with temp id ' || ser_row.transaction_temp_id);
          END IF;

          ser_row.transaction_temp_id  := new_txn_temp_id;
          inv_rcv_common_apis.insert_msnt(ser_row);
          ser_row                      := NULL;
        END LOOP;

        IF msnt%ISOPEN THEN
          CLOSE msnt;
        END IF;
--      END IF; -- For Bug#8498782
    /********* LOT and serial Controlled  **************/
    ELSIF(v_lot_control_code = 2
          AND v_serial_control_code NOT IN(1, 6)) THEN
      IF (l_debug = 1) THEN
        mydebug(' Both lot and Serial controlled  ');
      END IF;

--      IF (v_allocate_serial_flag = 'N') THEN -- For Bug#8498782
        /*******************same as LOT CONTROLLED ONLY***********/
/*        IF (l_debug = 1) THEN
          mydebug(' allocate_serial_flag is N ');
        END IF;

        OPEN mtlt(p_txn_temp_id);

        LOOP
          FETCH mtlt
           INTO lot_row;

          EXIT WHEN mtlt%NOTFOUND;

          IF (l_debug = 1) THEN
            mydebug('child row with temp id ' || lot_row.transaction_temp_id);
          END IF;

          lot_row.transaction_temp_id  := new_txn_temp_id;
          inv_rcv_common_apis.insert_mtlt(lot_row);
          lot_row                      := NULL;
        END LOOP;

        IF mtlt%ISOPEN THEN
          CLOSE mtlt;
        END IF;
      --END IF;
      ELSE */  -- For Bug#8498782
        /*Need to split both lot and serial tables*/
        IF (l_debug = 1) THEN
          mydebug(' allocate_serial_flag is Y ');
        END IF;

        OPEN mtlt(p_txn_temp_id);

        LOOP
          FETCH mtlt
           INTO lot_row;

          EXIT WHEN mtlt%NOTFOUND;

          /***********Serial Stuff *****************************/
          IF (l_debug = 1) THEN
            mydebug('child lot row with temp id ' || lot_row.transaction_temp_id);
          END IF;

          SELECT mtl_material_transactions_s.NEXTVAL
            INTO ser_transaction_temp_id
            FROM DUAL;

          OPEN msnt(lot_row.serial_transaction_temp_id);

          LOOP
            FETCH msnt
             INTO ser_row;

            EXIT WHEN msnt%NOTFOUND;

            IF (l_debug = 1) THEN
              mydebug('child lot ser row with temp id ' || ser_row.transaction_temp_id);
            END IF;

            SELECT mtl_material_transactions_s.NEXTVAL
              INTO ser_row.transaction_temp_id
              FROM DUAL;

            ser_row.transaction_temp_id         := ser_transaction_temp_id;
            inv_rcv_common_apis.insert_msnt(ser_row);
            /* Swapped the stmts, so that serial_transaction_temp_id is
             * correctly stamped in MTLT*/
            lot_row.serial_transaction_temp_id  := ser_row.transaction_temp_id;
            ser_row                             := NULL;
          END LOOP;

          IF msnt%ISOPEN THEN
            CLOSE msnt;
          END IF;

          /***********Serial Stuff *****************************/
          lot_row.transaction_temp_id  := new_txn_temp_id;
          inv_rcv_common_apis.insert_mtlt(lot_row);
          lot_row                      := NULL;
        END LOOP;

        IF mtlt%ISOPEN THEN
          CLOSE mtlt;
        END IF;
--      END IF; -- For Bug#8498782
    END IF;

    IF (l_debug = 1) THEN
      mydebug(' inserting the new row into mmtt using ' || 'wms_task_dispatch_engine.insert_mmtt ');
    END IF;

    wms_task_dispatch_engine.insert_mmtt(l_mmtt_rec => mmtt_row);
  END insert_new_mmtt_row_like;
END wms_wip_xdock_pvt;

/
