--------------------------------------------------------
--  DDL for Package Body WMS_XDOCK_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_XDOCK_UTILS_PVT" AS
  /* $Header: WMSXDUTB.pls 120.7 2005/10/06 17:01:42 stdavid noship $ */

  g_pkg_body_ver     CONSTANT VARCHAR2(100) := '$Header: WMSXDUTB.pls 120.7 2005/10/06 17:01:42 stdavid noship $';
  g_newline          CONSTANT VARCHAR2(10)  := fnd_global.newline;
  g_conv_precision   CONSTANT NUMBER        := 5;


  PROCEDURE print_debug
  ( p_msg      IN VARCHAR2
  , p_api_name IN VARCHAR2
  ) IS
  BEGIN
    inv_log_util.trace
    ( p_message => p_msg
    , p_module  => g_pkg_name || '.' || p_api_name
    , p_level   => 4
    );
  END print_debug;



  PROCEDURE print_version_info
    IS
  BEGIN
    print_debug('Spec::  ' || g_pkg_spec_ver, 'print_version_info');
    print_debug('Body::  ' || g_pkg_body_ver, 'print_version_info');
  END print_version_info;



  FUNCTION is_eligible_source
  ( p_criterion_id   IN   NUMBER
  , p_source_code    IN   NUMBER
  , p_source_type    IN   NUMBER
  ) RETURN BOOLEAN IS

    CURSOR c_source_exists
    ( p_crt_id   IN   NUMBER
    , p_src_cd   IN   NUMBER
    , p_src_tp   IN   NUMBER
    ) IS
      SELECT 'x'
        FROM wms_xdock_source_assignments  wxsa
       WHERE wxsa.criterion_id = p_crt_id
         AND wxsa.source_code  = p_src_cd
         AND wxsa.source_type  = p_src_tp;

    l_dummy      VARCHAR2(1);
    l_src_found  BOOLEAN;

  BEGIN
    l_src_found := FALSE;

    OPEN c_source_exists (p_criterion_id, p_source_code, p_source_type);
    FETCH c_source_exists INTO l_dummy;
    IF c_source_exists%FOUND
    THEN
       l_src_found := TRUE;
    END IF;
    CLOSE c_source_exists;

    RETURN l_src_found;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_source_exists%ISOPEN
      THEN
         CLOSE c_source_exists;
      END IF;
      RETURN FALSE;
  END is_eligible_source;



  FUNCTION is_eligible_supply_source
  ( p_criterion_id   IN   NUMBER
  , p_source_code    IN   NUMBER
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN is_eligible_source (p_criterion_id, p_source_code, G_SRC_TYPE_SUP);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END is_eligible_supply_source;



  FUNCTION is_eligible_demand_source
  ( p_criterion_id   IN   NUMBER
  , p_source_code    IN   NUMBER
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN is_eligible_source (p_criterion_id, p_source_code, G_SRC_TYPE_DEM);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END is_eligible_demand_source;


  -- Returns TRUE if RSV record is valid, FALSE otherwise
  FUNCTION rsv_record_valid
  ( p_rsv_rec   IN   inv_reservation_global.mtl_reservation_rec_type
  ) RETURN BOOLEAN IS

    l_api_name   VARCHAR2(30);
    l_debug      NUMBER;

    l_dummy      VARCHAR2(1);

    CURSOR c_chk_order_stat
    ( p_line_id   IN   NUMBER
    ) IS
      SELECT 'x'
        FROM oe_order_lines_all  oola
       WHERE oola.line_id     = p_line_id
         AND oola.booked_flag = 'Y'
         AND oola.open_flag   = 'Y';

  BEGIN
    l_api_name := 'rsv_record_valid';
    l_debug    := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    -- {{
    -- BEGIN rsv_record_valid }}
    --
    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with reservation rec: '
         || 'reservation ID: ' || to_char(p_rsv_rec.reservation_id)
         || ', for item ID: '  || to_char(p_rsv_rec.inventory_item_id)
         || ', xdock flag: '   || p_rsv_rec.crossdock_flag
       , l_api_name
       );
    END IF;

    -- Return if not a crossdock reservation
    IF NVL(p_rsv_rec.crossdock_flag,'N') <> 'Y'
    THEN
       RETURN TRUE;
    END IF;

    -- Check if delivery detail is stamped
    IF ( (p_rsv_rec.demand_source_line_detail IS NULL
          AND
          NVL(p_rsv_rec.crossdock_flag,'N') = 'Y')
         OR
         (p_rsv_rec.demand_source_line_detail IS NOT NULL
          AND
          NVL(p_rsv_rec.crossdock_flag,'N') = 'N')
       )
    THEN
       IF l_debug = 1 THEN
          print_debug
          ('Mismatch between crossdock_flag and ' ||
           'and demand_source_line_detail: '      || p_rsv_rec.crossdock_flag ||
           ', ' || to_char(p_rsv_rec.demand_source_line_detail)
          , l_api_name);
       END IF;

       fnd_message.set_name('WMS', 'WMS_RSV_WDD_MISSING');
       fnd_msg_pub.ADD;
       RETURN FALSE;
    END IF;

    -- {{
    -- Test with sales order / internal order that is not Booked }}
    --
    -- Ensure that sales order / internal order is booked
    IF p_rsv_rec.demand_source_type_id
       = inv_reservation_global.g_source_type_oe
       OR
       p_rsv_rec.demand_source_type_id
       = inv_reservation_global.g_source_type_internal_ord
    THEN
       OPEN c_chk_order_stat (p_rsv_rec.demand_source_line_id);
       FETCH c_chk_order_stat INTO l_dummy;

       IF c_chk_order_stat%NOTFOUND
       THEN
          CLOSE c_chk_order_stat;
          IF l_debug = 1 THEN
             print_debug
             ( 'Order line '
               || to_char(p_rsv_rec.demand_source_line_id) ||
               ' is not booked'
             , l_api_name
             );
          END IF;

          fnd_message.set_name('WMS', 'WMS_RSV_ORD_STAT_INVLD');
          fnd_msg_pub.ADD;
          RETURN FALSE;
       END IF;

       IF c_chk_order_stat%ISOPEN
       THEN
          CLOSE c_chk_order_stat;
       END IF;
    END IF;

    -- {{
    -- Test with demand source types: internal/sales order
    -- and supply source types: PO,WIP,Req,ASN,Intransit Shipment,
    -- Material in Receiving }}
    --
    -- Check demand and supply source types
    IF (p_rsv_rec.demand_source_type_id
        NOT IN ( inv_reservation_global.g_source_type_oe
               , inv_reservation_global.g_source_type_internal_ord
               )
        OR
        p_rsv_rec.supply_source_type_id
        NOT IN ( inv_reservation_global.g_source_type_po
               , inv_reservation_global.g_source_type_wip
               , inv_reservation_global.g_source_type_internal_req
               , inv_reservation_global.g_source_type_asn
               , inv_reservation_global.g_source_type_intransit
               , inv_reservation_global.g_source_type_rcv
               )
       )
    THEN
       IF l_debug = 1 THEN
          print_debug
          ( 'Invalid demand source type: '
            || to_char(p_rsv_rec.demand_source_type_id) ||
            ' or supply source type: '
            || to_char(p_rsv_rec.supply_source_type_id)
          , l_api_name
          );
       END IF;

       fnd_message.set_name('WMS', 'WMS_RSV_SRC_INVLD');
       fnd_msg_pub.ADD;
       RETURN FALSE;
    END IF;

    RETURN TRUE;

    -- {{
    -- END rsv_record_valid }}
    --

  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;

      RETURN FALSE;

  END rsv_record_valid;



  PROCEDURE process_delivery_detail
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_orig_rsv_rec    IN  inv_reservation_global.mtl_reservation_rec_type
  , p_new_rsv_rec     IN  inv_reservation_global.mtl_reservation_rec_type
  , p_action_code     IN           VARCHAR2
  ) IS

    l_api_name             VARCHAR2(30);
    l_debug                NUMBER;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_api_return_status    VARCHAR2(1);

    l_delivery_detail_id   NUMBER;
    l_new_wdd_qty          NUMBER;
    l_new_wdd_qty2         NUMBER;
    l_conv_rate            NUMBER;
    l_index                NUMBER;
    l_new_wdd_id           NUMBER;

    record_locked          EXCEPTION;
    PRAGMA EXCEPTION_INIT  (record_locked, -54);

    -- Variables for WDD split
    l_detail_id_tab        WSH_UTIL_CORE.id_tab_type;
    l_action_prms          WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
    l_action_out_rec       WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;

    -- Variables for WDD update
    l_detail_info_tab      WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type;
    l_in_rec               WSH_INTERFACE_EXT_GRP.detailInRecType;
    l_out_rec              WSH_INTERFACE_EXT_GRP.detailOutRecType;

    CURSOR c_lock_wdd
    ( p_delivery_detail_id   IN   NUMBER
    ) IS
      SELECT wdd.delivery_detail_id
           , wdd.released_status
           , wdd.requested_quantity
           , wdd.requested_quantity_uom
           , wdd.requested_quantity2
           , wdd.requested_quantity_uom2
        FROM wsh_delivery_details  wdd
       WHERE wdd.delivery_detail_id = p_delivery_detail_id
         FOR UPDATE NOWAIT;

    l_wdd_rec    c_lock_wdd%ROWTYPE;
    l_wdd2_rec   c_lock_wdd%ROWTYPE;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_api_name      := 'process_delivery_detail';
    l_debug         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    -- {{
    -- BEGIN process_delivery_detail }}
    --
    IF l_debug = 1
    THEN
       print_debug
       ( 'Entered with action code: ' || p_action_code
       , l_api_name
       );
    END IF;

    SAVEPOINT wmsxdutb_proc_wdd_sp;

    l_delivery_detail_id := p_orig_rsv_rec.demand_source_line_detail;

    -- Lock the WDD record
    BEGIN
       OPEN c_lock_wdd (l_delivery_detail_id);
       FETCH c_lock_wdd INTO l_wdd_rec;
       CLOSE c_lock_wdd;
    EXCEPTION
       WHEN record_locked THEN
          IF (l_debug = 1)
          THEN
             print_debug
             ( 'Unable to lock WDD: ' || to_char(l_delivery_detail_id)
             , l_api_name
             );
          END IF;

          IF c_lock_wdd%ISOPEN
          THEN
             CLOSE c_lock_wdd;
          END IF;

          fnd_message.set_name('WMS', 'WMS_RSV_WDD_LOCK_FAIL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
    END;

    IF (l_debug = 1)
    THEN
       print_debug
       ( 'Locked WDD: ' || to_char(l_delivery_detail_id)
       , l_api_name
       );
    END IF;

    -- {{
    -- Update of Xdock rsv due to reduction in qty of supply:
    -- Ensure that WDD is split.  Verify qty and secondary qty
    -- for the split line are calculated correctly.  Test with
    -- rsv UOM different from WDD UOM }}
    --
    -- For the update case, call shipping API to split the WDD.
    -- The quantity on the original WDD should be reduced,
    -- the new WDD should have remaining quantity with status
    -- 'Ready to Release'
    --
    IF p_action_code = 'UPDATE'
    THEN
    -- {
       -- Calculate the WDD quantity to split off
       l_new_wdd_qty := l_wdd_rec.requested_quantity
                        * (p_orig_rsv_rec.primary_reservation_quantity
                           - p_new_rsv_rec.primary_reservation_quantity)
                        / p_orig_rsv_rec.primary_reservation_quantity;

       IF (l_debug = 1)
       THEN
          print_debug
          ( 'New WDD qty: ' || to_char(l_new_wdd_qty)
          , l_api_name
          );
       END IF;

       -- Convert secondary qty if required
       IF l_wdd_rec.requested_quantity_uom2 IS NOT NULL
       THEN
          l_new_wdd_qty2 := l_wdd_rec.requested_quantity2
                            * (p_orig_rsv_rec.primary_reservation_quantity
                               - p_new_rsv_rec.primary_reservation_quantity)
                            / p_orig_rsv_rec.primary_reservation_quantity;
       END IF;

       IF (l_debug = 1)
       THEN
          print_debug
          ( 'New WDD secondary qty: ' || to_char(l_new_wdd_qty2)
          , l_api_name
          );
       END IF;

       -- Call WSH API to split the WDD
       l_detail_id_tab(1) := l_delivery_detail_id;
       l_action_prms.caller := 'WMS_XDOCK_UTILS_PVT';
       l_action_prms.action_code := 'SPLIT-LINE';
       l_action_prms.split_quantity := l_new_wdd_qty;
       l_action_prms.split_quantity2 := l_new_wdd_qty2;

       l_api_return_status := fnd_api.g_ret_sts_success;
       WSH_INTERFACE_GRP.Delivery_Detail_Action
       ( p_api_version_number  => 1.0
       , p_init_msg_list       => fnd_api.g_false
       , p_commit              => fnd_api.g_false
       , x_return_status       => l_api_return_status
       , x_msg_count           => l_msg_count
       , x_msg_data            => l_msg_data
       , p_detail_id_tab       => l_detail_id_tab
       , p_action_prms         => l_action_prms
       , x_action_out_rec      => l_action_out_rec
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF (l_debug = 1)
          THEN
             print_debug
             ( 'Error status from WSH_INTERFACE_GRP.Delivery_Detail_Action: '
               || l_api_return_status
             , l_api_name
             );
          END IF;

          IF x_return_status = fnd_api.g_ret_sts_error
          THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;

       ELSE
          IF (l_debug = 1)
          THEN
             print_debug('Successfully split the WDD record', l_api_name);
          END IF;
       END IF;

       l_index := l_action_out_rec.result_id_tab.FIRST;
       l_new_wdd_id := l_action_out_rec.result_id_tab(l_index);

       IF (l_debug = 1)
       THEN
          print_debug
          ( 'New delivery detail ID: ' || to_char (l_new_wdd_id)
          , l_api_name
          );
       END IF;

       -- New WDD's released status is to be updated
       l_delivery_detail_id := l_new_wdd_id;

       -- Lock the new WDD record
       BEGIN
          OPEN c_lock_wdd (l_delivery_detail_id);
          FETCH c_lock_wdd INTO l_wdd2_rec;
          CLOSE c_lock_wdd;
       EXCEPTION
          WHEN record_locked THEN
             IF (l_debug = 1)
             THEN
                print_debug
                ( 'Unable to lock WDD: ' || to_char(l_delivery_detail_id)
                , l_api_name
                );
             END IF;

             IF c_lock_wdd%ISOPEN
             THEN
                CLOSE c_lock_wdd;
             END IF;

             fnd_message.set_name('WMS', 'WMS_RSV_WDD_LOCK_FAIL');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
       END;

       IF (l_debug = 1)
       THEN
          print_debug
          ( 'Locked new WDD: ' || to_char(l_delivery_detail_id)
          , l_api_name
          );
       END IF;
    -- }
    END IF; -- end IF action is UPDATE

    -- {{
    -- For update of xdock rsv, ensure that the split WDD is
    -- set to 'Ready to Release' status.  For delete/relieve
    -- original WDD is set to ready to release.  Relieve rsv
    -- should fail if WDD is shipped or staged }}
    --
    -- Update WDD status to Ready to Release if ok to do so
    IF p_action_code IN ('UPDATE','DELETE')
    THEN
    -- {
       -- Update the released_status to 'R' for the new WDD record
       l_detail_info_tab(1).delivery_detail_id := l_delivery_detail_id;
       l_detail_info_tab(1).released_status := 'R';
       l_detail_info_tab(1).move_order_line_id := NULL;

       l_in_rec.caller := 'WMS_XDOCK_UTILS_PVT';
       l_in_rec.action_code := 'UPDATE';

       l_api_return_status := fnd_api.g_ret_sts_success;
       WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail
       ( p_api_version_number => 1.0
       , p_init_msg_list      => fnd_api.g_false
       , p_commit             => fnd_api.g_false
       , x_return_status      => l_api_return_status
       , x_msg_count          => l_msg_count
       , x_msg_data           => l_msg_data
       , p_detail_info_tab    => l_detail_info_tab
       , p_in_rec             => l_in_rec
       , x_out_rec            => l_out_rec
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF (l_debug = 1)
          THEN
             print_debug
             ( 'Error status from WSH_INTERFACE_GRP.Create_Update_Delivery_Detail: '
               || l_api_return_status
             , l_api_name
             );
          END IF;

          IF x_return_status = fnd_api.g_ret_sts_error
          THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;

       ELSE
          IF (l_debug = 1)
          THEN
             print_debug('Successfully updated the WDD record to status ''R''', l_api_name);
          END IF;
       END IF;
    -- }
    END IF; -- end IF ok to update WDD status to 'R'

    -- {{
    -- END process_delivery_detail }}
    --

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO wmsxdutb_proc_wdd_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO wmsxdutb_proc_wdd_sp;

      IF l_debug = 1
      THEN
         print_debug('Other error: ' || sqlerrm, l_api_name);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

  END process_delivery_detail;



  PROCEDURE create_crossdock_reservation
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_rsv_rec         IN  inv_reservation_global.mtl_reservation_rec_type
  ) IS

    l_api_name   VARCHAR2(30);
    l_debug      NUMBER;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_api_name      := 'create_crossdock_reservation';
    l_debug         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    print_version_info;

    IF l_debug = 1
    THEN
       print_debug
       ( 'Entered with reservation rec: '
         || 'reservation ID: ' || to_char(p_rsv_rec.reservation_id)
         || ', for item ID: '  || to_char(p_rsv_rec.inventory_item_id)
       , l_api_name
       );
    END IF;

    IF (NOT rsv_record_valid(p_rsv_rec))
    THEN
       x_return_status := fnd_api.g_ret_sts_error;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = 1
      THEN
         print_debug('Other error: ' || sqlerrm, l_api_name);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

  END create_crossdock_reservation;



  PROCEDURE update_crossdock_reservation
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_orig_rsv_rec    IN  inv_reservation_global.mtl_reservation_rec_type
  , p_new_rsv_rec     IN  inv_reservation_global.mtl_reservation_rec_type
  ) IS

    l_api_name             VARCHAR2(30);
    l_debug                NUMBER;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_api_return_status    VARCHAR2(1);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_api_name      := 'update_crossdock_reservation';
    l_debug         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    -- {{
    -- BEGIN update_crossdock_reservation }}
    --

    print_version_info;

    IF l_debug = 1
    THEN
       print_debug
       ( 'Entered with parameters: '
         || 'original rsv ID: ' || to_char(p_orig_rsv_rec.reservation_id)
         || ', for item ID: '   || to_char(p_orig_rsv_rec.inventory_item_id)
         || ', xdock flag: '    || p_orig_rsv_rec.crossdock_flag
         || 'changed rsv ID: '  || to_char(p_new_rsv_rec.reservation_id)
         || ', for item ID: '   || to_char(p_new_rsv_rec.inventory_item_id)
         || ', xdock flag: '    || p_new_rsv_rec.crossdock_flag
       , l_api_name
       );
       IF g_demand_triggered
       THEN
          print_debug('Demand triggered', l_api_name);
       ELSE
          print_debug('NOT demand triggered', l_api_name);
       END IF;
    END IF;

    -- Return if not crossdock reservations
    IF NVL(p_orig_rsv_rec.crossdock_flag,'N') <> 'Y'
       OR
       NVL(p_new_rsv_rec.crossdock_flag,'N') <> 'Y'
    THEN
       RETURN;
    END IF;

    SAVEPOINT wmsxdutb_update_sp;

    IF p_new_rsv_rec.primary_reservation_quantity = 0
    THEN
    -- {
       l_api_return_status := fnd_api.g_ret_sts_success;
       delete_crossdock_reservation
       ( x_return_status => l_api_return_status
       , p_rsv_rec       => p_orig_rsv_rec
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF (l_debug = 1)
          THEN
             print_debug
             ( 'Error status from delete_crossdock_reservation: '
               || l_api_return_status
             , l_api_name
             );
          END IF;

          IF x_return_status = fnd_api.g_ret_sts_error
          THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       ELSE
          IF (l_debug = 1)
          THEN
             print_debug('Successfully processed delete rsv', l_api_name);
          END IF;
       END IF;
    -- }
    ELSIF (NOT rsv_record_valid(p_new_rsv_rec))
    THEN
       IF (l_debug = 1)
       THEN
          print_debug('RSV record failed validation', l_api_name);
       END IF;
       RAISE fnd_api.g_exc_error;
    ELSIF (p_new_rsv_rec.primary_reservation_quantity
           < p_orig_rsv_rec.primary_reservation_quantity)
          AND
          NOT g_demand_triggered
    THEN
    -- {
       -- {{
       -- Ensure that WDD is not split if update of xdock rsv
       -- is triggered from the demand side }}
       --
       IF (l_debug = 1)
       THEN
          print_debug('Qty reduced, need to split WDD', l_api_name);
       END IF;

       l_api_return_status := fnd_api.g_ret_sts_success;
       process_delivery_detail
       ( x_return_status => l_api_return_status
       , p_orig_rsv_rec  => p_orig_rsv_rec
       , p_new_rsv_rec   => p_new_rsv_rec
       , p_action_code   => 'UPDATE'
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF (l_debug = 1)
          THEN
             print_debug
             ( 'Error status from process_delivery_detail: '
               || l_api_return_status
             , l_api_name
             );
          END IF;

          IF x_return_status = fnd_api.g_ret_sts_error
          THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       ELSE
          IF (l_debug = 1)
          THEN
             print_debug('Successfully processed WDD record', l_api_name);
          END IF;
       END IF;
    -- }
    END IF; -- end IF rsv qty reduced, and not triggered from demand side

    -- {{
    -- END update_crossdock_reservation }}
    --

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO wmsxdutb_update_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO wmsxdutb_update_sp;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

  END update_crossdock_reservation;



  PROCEDURE transfer_crossdock_reservation
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_orig_rsv_rec    IN  inv_reservation_global.mtl_reservation_rec_type
  , p_new_rsv_rec     IN  inv_reservation_global.mtl_reservation_rec_type
  ) IS

    l_api_name   VARCHAR2(30);
    l_debug      NUMBER;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_api_name      := 'transfer_crossdock_reservation';
    l_debug         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    print_version_info;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with parameters: '
         || 'original rsv ID: ' || to_char(p_orig_rsv_rec.reservation_id)
         || ', for item ID: '   || to_char(p_orig_rsv_rec.inventory_item_id)
         || 'changed rsv ID: '  || to_char(p_new_rsv_rec.reservation_id)
         || ', for item ID: '   || to_char(p_new_rsv_rec.inventory_item_id)
       , l_api_name
       );
    END IF;

    IF ((NOT rsv_record_valid(p_new_rsv_rec))
        OR
        (NOT rsv_record_valid(p_orig_rsv_rec))
       )
    THEN
       x_return_status := fnd_api.g_ret_sts_error;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

  END transfer_crossdock_reservation;



  PROCEDURE delete_crossdock_reservation
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_rsv_rec         IN  inv_reservation_global.mtl_reservation_rec_type
  ) IS

    l_api_name            VARCHAR2(30);
    l_debug               NUMBER;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_api_return_status   VARCHAR2(1);

    l_dummy_rsv_rec       inv_reservation_global.mtl_reservation_rec_type;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_api_name      := 'delete_crossdock_reservation';
    l_debug         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    -- {{
    -- BEGIN delete_crossdock_reservation }}
    --

    print_version_info;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with reservation rec: '
         || 'reservation ID: ' || to_char(p_rsv_rec.reservation_id)
         || ', for item ID: '  || to_char(p_rsv_rec.inventory_item_id)
         || ', xdock flag: '   || p_rsv_rec.crossdock_flag
       , l_api_name
       );
       IF g_demand_triggered
       THEN
          print_debug('Demand triggered', l_api_name);
       ELSE
          print_debug('NOT demand triggered', l_api_name);
       END IF;
    END IF;

    -- Return if not a crossdock reservation
    IF NVL(p_rsv_rec.crossdock_flag,'N') <> 'Y'
    THEN
       RETURN;
    END IF;

    SAVEPOINT wmsxdutb_delete_sp;

    -- {{
    -- Cancel a xdock rsv (from RSV UI) and ensure that
    -- WDD is set to Ready to Release status }}
    --

    IF NOT g_demand_triggered
    THEN
       l_api_return_status := fnd_api.g_ret_sts_success;
       process_delivery_detail
       ( x_return_status => l_api_return_status
       , p_orig_rsv_rec  => p_rsv_rec
       , p_new_rsv_rec   => l_dummy_rsv_rec
       , p_action_code   => 'DELETE'
       );

       IF l_api_return_status <> fnd_api.g_ret_sts_success
       THEN
          IF (l_debug = 1)
          THEN
             print_debug
             ( 'Error status from process_delivery_detail: '
               || l_api_return_status
             , l_api_name
             );
          END IF;

          IF x_return_status = fnd_api.g_ret_sts_error
          THEN
             RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       ELSE
          IF (l_debug = 1)
          THEN
             print_debug('Successfully processed WDD record', l_api_name);
          END IF;
       END IF;
    END IF;

    -- {{
    -- END delete_crossdock_reservation }}
    --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO wmsxdutb_delete_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO wmsxdutb_delete_sp;

      IF l_debug = 1 THEN
         print_debug ('Other error: ' || sqlerrm, l_api_name);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

  END delete_crossdock_reservation;



  PROCEDURE relieve_crossdock_reservation
  ( x_return_status   OUT NOCOPY   VARCHAR2
  , p_rsv_rec         IN  inv_reservation_global.mtl_reservation_rec_type
  ) IS

    l_api_name            VARCHAR2(30);
    l_debug               NUMBER;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_api_return_status   VARCHAR2(1);

    l_dummy_rsv_rec       inv_reservation_global.mtl_reservation_rec_type;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_api_name      := 'relieve_crossdock_reservation';
    l_debug         := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    -- {{
    -- BEGIN relieve_crossdock_reservation }}
    --

    print_version_info;

    IF l_debug = 1 THEN
       print_debug
       ( 'Entered with reservation rec: '
         || 'reservation ID: ' || to_char(p_rsv_rec.reservation_id)
         || ', for item ID: '  || to_char(p_rsv_rec.inventory_item_id)
         || ', xdock flag: '   || p_rsv_rec.crossdock_flag
       , l_api_name
       );
       IF g_demand_triggered
       THEN
          print_debug('Demand triggered', l_api_name);
       ELSE
          print_debug('NOT demand triggered', l_api_name);
       END IF;
    END IF;

    --
    -- Always raise an exception.  Reservations should not be
    -- calling this API anymore.
    --
    RAISE fnd_api.g_exc_error;

    -- {{
    -- END relieve_crossdock_reservation }}
    --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO wmsxdutb_relieve_sp;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get
      ( p_count   => l_msg_count
      , p_data    => l_msg_data
      , p_encoded => fnd_api.g_false
      );

      IF l_debug = 1 THEN
         print_debug (l_msg_data, l_api_name);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO wmsxdutb_relieve_sp;

      IF l_debug = 1
      THEN
         print_debug('Other error: ' || sqlerrm, l_api_name);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

  END relieve_crossdock_reservation;



END wms_xdock_utils_pvt;

/
