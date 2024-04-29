--------------------------------------------------------
--  DDL for Package Body WMS_RULE_EXTN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULE_EXTN_PVT" AS
  /* $Header: WMSVRXTB.pls 120.5.12010000.5 2008/11/06 11:01:36 avuppala ship $ */
  --
  -- File        : WMSVPPTB.pls
  -- Content     : WMS_Test_Pub package body
  -- Description : wms rules engine private API's
  -- Notes       :
  -- Modified    : 05/18/05 rambrose created orginal file
  --
  g_pkg_name    CONSTANT VARCHAR2(30) := 'WMS_rule_extn_PVT';
  g_debug       NUMBER;


  TYPE numtbltype IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  --Procedures for logging messages
  PROCEDURE log_event(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
  END log_event;

  PROCEDURE log_error(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
  END log_error;

  PROCEDURE log_error_msg(p_api_name VARCHAR2, p_label VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace('err:', l_module, 9);
  END log_error_msg;

  PROCEDURE log_procedure(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
  END log_procedure;

  PROCEDURE log_statement(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
  END log_statement;

  -- Start of comments
  -- Name        : InitQtyTree
  -- Function    : Initializes quantity tree for picking and returns tree id.
  -- Pre-reqs    : none
  -- Parameters  :
  --  x_return_status              out varchar2(1)
  --  x_msg_count                  out number
  --  x_msg_data                   out varchar2(2000)
  --  p_organization_id            in  number   required
  --  p_inventory_item_id          in  number   required
  --  p_transaction_source_type_id in  number   required
  --  p_transaction_source_id      in  number   required
  --  p_trx_source_line_id         in  number   required
  --  p_trx_source_delivery_id     in  number   required
  --  p_transaction_source_name    in  varchar2 required
  --  p_tree_mode                  in  number   required
  --  x_tree_id                    out number
  -- Notes       : privat procedure for internal use only
  -- End of comments

  procedure InitQtyTree (
            x_return_status                out nocopy  varchar2
           ,x_msg_count                    out nocopy  number
           ,x_msg_data                     out nocopy  varchar2
           ,p_organization_id              in   number
           ,p_inventory_item_id            in   number
           ,p_transaction_source_type_id   in   number
           ,p_transaction_source_id        in   number
           ,p_trx_source_line_id           in   number
           ,p_trx_source_delivery_id       in   number
           ,p_transaction_source_name      in   varchar2
           ,p_tree_mode                    in   number
           ,x_tree_id                      out nocopy  number
                        ) is

    l_api_name            VARCHAR2(30) := 'InitQtyTree';
    l_rev_control_code    MTL_SYSTEM_ITEMS.REVISION_QTY_CONTROL_CODE%type;
    l_lot_control_code    MTL_SYSTEM_ITEMS.LOT_CONTROL_CODE%type;
    l_ser_control_code    MTL_SYSTEM_ITEMS.SERIAL_NUMBER_CONTROL_CODE%type;
    l_is_revision_control boolean;
    l_is_lot_control      boolean;
    l_is_serial_control   boolean;
    l_msg_data VARCHAR2(240);
    l_transaction_source_id NUMBER;
    l_trx_source_line_id NUMBER;
    l_debug              NUMBER;
    cursor iteminfo is
    select nvl(msi.REVISION_QTY_CONTROL_CODE,1)
          ,nvl(msi.LOT_CONTROL_CODE,1)
          ,nvl(msi.SERIAL_NUMBER_CONTROL_CODE,1)
      from MTL_SYSTEM_ITEMS msi
     where ORGANIZATION_ID   = p_organization_id
       and INVENTORY_ITEM_ID = p_inventory_item_id
    ;
  begin

    IF (g_debug IS   NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    If (l_debug = 1) then
      log_procedure(l_api_name, 'start', 'Start InitQtyTree');
    End if;
    /*--
    -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('enter '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section
    -- */
    open iteminfo;
    fetch iteminfo into l_rev_control_code
                       ,l_lot_control_code
                       ,l_ser_control_code;
    if iteminfo%notfound then
      close iteminfo;
      raise no_data_found;
    end if;
    close iteminfo;

    if l_rev_control_code = 1 then
      l_is_revision_control := false;
    else
      l_is_revision_control := true;
    end if;
    if l_lot_control_code = 1 then
      l_is_lot_control := false;
    else
      l_is_lot_control := true;
    end if;
    if l_ser_control_code = 1 then
      l_is_serial_control := false;
    else
      l_is_serial_control := true;
    end if;

    -- bug 2398927
    --if source type id is 13 (inventory), don't pass in the demand
    --source line and header info.  This info was causing LPN putaway
    -- to fall for unit effective items.
    IF p_transaction_source_type_id IN (4,13) THEN
      l_transaction_source_id := -9999;
      l_trx_source_line_id := -9999;
    ELSE      l_transaction_source_id := p_transaction_source_id;
      l_trx_source_line_id := p_trx_source_line_id;
    END IF;

    If (l_debug = 1) then
      log_event(l_api_name, 'create_tree',
                'Trying to create quantity tree in exclusive mode');
    End if;

    INV_Quantity_Tree_PVT.Create_Tree
        (
          p_api_version_number              => 1.0
          --,p_init_msg_list                => fnd_api.g_false
          ,x_return_status                  => x_return_status
          ,x_msg_count                      => x_msg_count
          ,x_msg_data                       => x_msg_data
          ,p_organization_id                => p_organization_id
          ,p_inventory_item_id              => p_inventory_item_id
          ,p_tree_mode                      => p_tree_mode
          ,p_is_revision_control            => l_is_revision_control
          ,p_is_lot_control                 => l_is_lot_control
          ,p_is_serial_control              => l_is_serial_control
          ,p_asset_sub_only                 => FALSE
          ,p_include_suggestion             => TRUE
          ,p_demand_source_type_id          => p_transaction_source_type_id
          ,p_demand_source_header_id        => l_transaction_source_id
          ,p_demand_source_line_id          => l_trx_source_line_id
          ,p_demand_source_name             => p_transaction_source_name
          ,p_demand_source_delivery         => p_trx_source_delivery_id
          ,p_lot_expiration_date            => sysdate
          ,p_onhand_source                  => inv_quantity_tree_pvt.g_all_subs
          ,p_exclusive                      => inv_quantity_tree_pvt.g_exclusive
          ,p_pick_release                   => inv_quantity_tree_pvt.g_pick_release_yes
          ,x_tree_id                        => x_tree_id
        );
    --
    If (l_debug = 1) then
      log_event(l_api_name, 'create_tree_finished',
                'Created quantity tree in exclusive mode');
    End if;
   /* -- debugging portion
    -- can be commented ut for final code
    IF inv_pp_debug.is_debug_mode THEN
       inv_pp_debug.send_message_to_pipe('exit '||g_pkg_name||'.'||l_api_name);
    END IF;
    -- end of debugging section */
    If (l_debug = 1) then
      log_procedure(l_api_name, 'end', 'End InitQtyTree');
    End if;
    --
exception
    when others then
      if iteminfo%isopen then
        close iteminfo;
      end if;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );
      If (l_debug = 1) then
        log_error(l_api_name, 'error', 'Error in InitQtyTree - ' || x_msg_data);
      End if;
end InitQtyTree;


PROCEDURE suggest_reservations(
    p_api_version         IN            NUMBER
  , p_init_msg_list       IN            VARCHAR2
  , p_commit              IN            VARCHAR2
  , p_validation_level    IN            NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_transaction_temp_id IN            NUMBER
  , p_allow_partial_pick  IN            VARCHAR2
  , p_suggest_serial	  IN		VARCHAR2
  , p_mo_line_rec         IN     inv_move_order_pub.trolin_rec_type
  , p_demand_source_type  IN            NUMBER
  , p_demand_source_header_id  IN       NUMBER
  , p_demand_source_line_id    IN       NUMBER
  , p_demand_source_detail     IN       NUMBER DEFAULT NULL
  , p_demand_source_name  IN            VARCHAR2 DEFAULT NULL
  , p_requirement_date    IN            DATE  DEFAULT  NULL
  , p_suggestions         OUT NOCOPY g_suggestion_list_rec_type
  ) IS
    l_api_version       CONSTANT NUMBER                                         := 1.0;
    l_api_name             VARCHAR2(30)   :=    'Suggest_Reservations';
    l_qry_rsv_rec            inv_reservation_global.mtl_reservation_rec_type;
    l_new_reservation        inv_reservation_global.mtl_reservation_rec_type;
    l_orig_reservation       inv_reservation_global.mtl_reservation_rec_type;
    l_last_reservation       inv_reservation_global.mtl_reservation_rec_type;
    -- Record for querying up matching reservations for the move order line
    l_demand_rsvs_ordered     inv_reservation_global.mtl_reservation_tbl_type;
    l_demand_reservations     inv_reservation_global.mtl_reservation_tbl_type;
    l_rsv_qty_available       NUMBER;

     l_rsv_qty2_available      NUMBER; --BUG#7377744 Added a secondary quantity available to reserve to make it consistent with process_reservations call
    l_new_reservation_id      NUMBER;
    l_qty_succ_reserved       NUMBER;
    l_rsv_index               NUMTBLTYPE;
    l_demand_info             wsh_inv_delivery_details_v%ROWTYPE;
    l_dummy_sn                inv_reservation_global.serial_number_tbl_type;
    l_reserved_serials       inv_reservation_global.serial_number_tbl_type;
    l_suggested_serials       inv_reservation_global.serial_number_tbl_type;
    l_reservation_count_by_id NUMBER;
    l_requirement_date        DATE;
    l_primary_uom_code        VARCHAR2(10) ;
    l_simulation_mode         NUMBER;
    l_simulation_id           NUMBER;
    l_api_error_code	      VARCHAR2(10);
    l_return_value	      BOOLEAN;
    l_message	              VARCHAR2(200);
    l_reservable_type	      NUMBER;
    i NUMBER;

    first_pass                BOOLEAN;
    l_tree_id                       NUMBER;
    l_qoh                       NUMBER;
    l_rqoh                      NUMBER;
    l_qr                        NUMBER;
    l_qs                        NUMBER;
    l_att                       NUMBER;
    l_atr                       NUMBER;
    l_allocation_quantity       NUMBER;
    l_sqoh                      NUMBER;
    l_srqoh                     NUMBER;
    l_sqr                       NUMBER;
    l_sqs                       NUMBER;
    l_satt                      NUMBER;
    l_satr                      NUMBER;

    l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_last_sugg_str    VARCHAR2(120);


  CURSOR c_sugg_grp IS
     SELECT from_organization_id
          , lot_number
          , revision
          , from_subinventory_code
          , from_locator_id
          , lpn_id
          , reservation_id
          , sum(primary_quantity) primary_quantity
          , sum(transaction_quantity) transaction_quantity
          , sum(secondary_quantity) secondary_quantity
          , revision || ' - ' || lot_number || ' - ' || from_subinventory_code || ' - ' || from_locator_id || ' - ' || lpn_id as sugg_str
     FROM wms_transactions_temp
     WHERE line_type_code = 2
     GROUP BY from_organization_id,
              lot_number, from_subinventory_code, revision,
             from_locator_id, lpn_id, reservation_id
     ORDER BY sugg_str, reservation_id;

  CURSOR c_sugg_serials(lc_from_org   NUMBER
                      , lc_from_sub   VARCHAR2
                      , lc_from_loc   NUMBER
                      , lc_from_rev   VARCHAR2
                      , lc_lot_num    VARCHAR2
                      , lc_lpn_id     NUMBER
                      , lc_res_id     NUMBER) IS
     SELECT serial_number
     FROM   wms_transactions_temp
     WHERE line_type_code = 2
       AND from_organization_id = lc_from_org
       AND from_subinventory_code = lc_from_sub
       AND nvl(from_locator_id,-888)      = nvl(lc_from_loc,-888)
       AND nvl(revision,'@@@')      = nvl(lc_from_rev,'@@@')
       AND nvl(lot_number,'@@@')          = nvl(lc_lot_num,'@@@')
       AND nvl(lpn_id,-888)     = nvl(lc_lpn_id, -888)
       AND nvl(reservation_id,-888) = nvl(lc_res_id, -888);


  CURSOR c_suggestions IS
     SELECT from_organization_id
          , to_organization_id
          , revision
          , lot_number
          , lot_expiration_date
          , from_subinventory_code
          , to_subinventory_code
          , from_locator_id
          , to_locator_id
          , lpn_id
          , reservation_id
          , serial_number
          , grade_code
          , from_cost_group_id
          , to_cost_group_id
          , sum(primary_quantity) primary_quantity
          , sum(transaction_quantity) transaction_quantity
          , sum(secondary_quantity) secondary_quantity
     FROM wms_transactions_temp
     WHERE line_type_code = 2
     GROUP BY from_organization_id, to_organization_id, revision,
              lot_number, lot_expiration_date, from_subinventory_code,
              to_subinventory_code, from_locator_id, to_locator_id, lpn_id, reservation_id,
              serial_number, grade_code, from_cost_group_id, to_cost_group_id;
BEGIN

    g_debug := l_debug;

    If l_debug = 1  THEN
       log_procedure(l_api_name, 'start', 'Start suggest_reservations');
       log_event(
                    l_api_name
                 , 'start_detail'
                 , 'Starting the WMS Rules engine Extention to create Rules Based reservations: '
                 || p_transaction_temp_id
                 );
    End if;

    -- Standard start of API savepoint
    SAVEPOINT suggest_reservations_sa;

    --
    -- Standard Call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to true
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

       log_procedure(l_api_name, 'start', 'Start suggest_reservations');
    --
    -- Initialisize API return status to access
    x_return_status          := fnd_api.g_ret_sts_success;
    --

  l_return_value := INV_CACHE.set_item_rec(p_mo_line_rec.organization_id,
                                             p_mo_line_rec.inventory_item_id);
  l_reservable_type:= INV_CACHE.item_rec.reservable_type;

  IF l_reservable_type = 2 THEN
     IF (l_debug = 1) THEN
         log_error(l_api_name, 'Process_Reservations','Error - Item is not reservable');
     END IF;

     RAISE fnd_api.g_exc_error;
  END IF;

  /* Set Demand Info Record */
  l_demand_info.oe_line_id := p_demand_source_line_id;

  /* Call Process Reservations */
 --Bug#7377744 : included secondary quantity available to reserve in the parameters
  inv_pick_release_pvt.process_reservations(
     x_return_status => x_return_status
   , x_msg_count => x_msg_count
   , x_msg_data => x_msg_data
   , p_demand_info => l_demand_info
   , p_mo_line_rec => p_mo_line_rec
   , p_mso_line_id => p_demand_source_header_id
   , p_demand_source_type => p_demand_source_type
   , p_demand_source_name => p_demand_source_name
   , p_allow_partial_pick => p_allow_partial_pick
   , x_demand_rsvs_ordered => l_demand_rsvs_ordered
   , x_rsv_qty_available => l_rsv_qty_available
    ,x_rsv_qty2_available  => l_rsv_qty2_available);


  -- Return an error if the query reservations call failed
  IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF ( l_debug = 1 ) THEN
         log_error(l_api_name, 'Suggest Reservations', 'l_return_status = '|| x_return_status);
         log_error(l_api_name, 'Suggest Reservations', 'Process Reservations Failed ' || x_msg_data);
      END IF;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
  /* Place reservation IDs into a table for easy access when creating new reservations */
  IF l_demand_rsvs_ordered.count > 0 THEN
     log_event(l_api_name, 'Suggest Reservations','# Reservations returned from Process Reservation : ' || l_demand_rsvs_ordered.count);
     FOR i in l_demand_rsvs_ordered.First..l_demand_rsvs_ordered.Last LOOP
          inv_reservation_pvt.print_rsv_rec(l_demand_rsvs_ordered (i));
        l_rsv_index(l_demand_rsvs_ordered(i).reservation_id) := i;
     END LOOP;
  END IF;

  DELETE FROM WMS_TRANSACTIONS_TEMP WHERE line_type_code = 2;

  /* Call create suggestions */
  wms_engine_pvt.create_suggestions(
     p_api_version => 1.0
   , p_init_msg_list => fnd_api.g_true
   , p_commit => fnd_api.g_false
   , p_validation_level => NULL
   , x_return_status => x_return_status
   , x_msg_count => x_msg_count
   , x_msg_data => x_msg_data
   , p_transaction_temp_id => p_mo_line_rec.line_id
   , p_reservations => l_demand_rsvs_ordered
   , p_suggest_serial => p_suggest_serial
   , p_simulation_mode => wms_engine_pvt.g_pick_full_mode
   , p_simulation_id => NULL
   , p_plan_tasks => FALSE
   , p_quick_pick_flag => 'N'
   );
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF ( l_debug = 1 ) THEN
         log_error(l_api_name, 'Suggest Reservations', 'l_return_status = '|| x_return_status);
         log_error(l_api_name, 'Suggest Reservations', 'Detailing Failed ');
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => l_message, p_encoded => 'F');

      IF (x_msg_count = 0) THEN
        IF ( l_debug = 1) THEN
           log_error(l_api_name, 'Suggest Reservations', 'no message from detailing engine');
        END IF;
      ELSIF (x_msg_count = 1) THEN
        IF ( l_debug = 1 ) THEN
           log_error(l_api_name, 'Suggest_Reservations', l_message);
        END IF;
      ELSE
        FOR i IN 1 .. x_msg_count LOOP
          l_message  := fnd_msg_pub.get(i, 'F');
          IF ( l_debug = 1) THEN
            log_error(l_api_name, 'Suggest_Reservations', l_message);
          END IF;
        END LOOP;

        fnd_msg_pub.delete_msg();
      END IF;

      ROLLBACK TO suggest_reservations_sa;

      fnd_message.set_name('INV', 'INV_DETAILING_FAILED');
      fnd_message.set_token('LINE_NUM', TO_CHAR(p_mo_line_rec.line_number));
      fnd_msg_pub.ADD;
      x_msg_count := 1;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_suggested_serials := l_dummy_sn;
    l_requirement_date := nvl(p_requirement_date, sysdate);

    first_pass := TRUE;
    FOR l_grp_sugg_rec in c_sugg_grp LOOP

    IF first_pass THEN
      InitQtyTree ( x_return_status
                   ,x_msg_count
                   ,x_msg_data
                   ,p_mo_line_rec.organization_id
                   ,p_mo_line_rec.inventory_item_id
                   ,p_demand_source_type
                   ,p_demand_source_header_id
                   ,p_demand_source_line_id
                   ,p_demand_source_detail
                   ,p_demand_source_name
                   ,INV_Quantity_Tree_PVT.g_transaction_mode
                   ,l_tree_id
                  );
      if x_return_status = fnd_api.g_ret_sts_unexp_error then
        raise fnd_api.g_exc_unexpected_error;
      elsif x_return_status = fnd_api.g_ret_sts_error then
        raise fnd_api.g_exc_error;
      end if;
      first_pass := FALSE;
   END IF;

    -- Update quantity tree for this suggested quantity
    IF l_debug = 1 THEN
       log_statement(l_api_name, 'update_tree', 'Updating qty tree');
    END IF;

    inv_quantity_tree_pvt.update_quantities
           (
                p_api_version_number         => 1.0
              , p_init_msg_lst               => fnd_api.g_false
              , x_return_status              => x_return_status
              , x_msg_count                  => x_msg_count
              , x_msg_data                   => x_msg_data
              , p_tree_id                    => l_tree_id
              , p_revision                   => l_grp_sugg_rec.revision
              , p_lot_number                 => l_grp_sugg_rec.lot_number
              , p_subinventory_code          => l_grp_sugg_rec.from_subinventory_code
              , p_locator_id                 => l_grp_sugg_rec.from_locator_id
              , p_primary_quantity           => -1 * l_grp_sugg_rec.primary_quantity
              , p_secondary_quantity         => -1 * l_grp_sugg_rec.secondary_quantity             -- INVCONV
              , p_quantity_type              => inv_quantity_tree_pvt.g_qs_txn
              , x_qoh                        => l_qoh
              , x_rqoh                       => l_rqoh
              , x_qr                         => l_qr
              , x_qs                         => l_qs
              , x_att                        => l_att
              , x_atr                        => l_atr
              , x_sqoh                       => l_sqoh                                             -- INVCONV
              , x_srqoh                      => l_srqoh                                            -- INVCONV
              , x_sqr                        => l_sqr                                              -- INVCONV
              , x_sqs                        => l_sqs                                              -- INVCONV
              , x_satt                       => l_satt                                             -- INVCONV
              , x_satr                       => l_satr                                             -- INVCONV
              , p_transfer_subinventory_code => null
              , p_cost_group_id              => null
              , p_lpn_id                     => l_grp_sugg_rec.lpn_id
           );

       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         IF l_debug = 1 THEN
            log_statement(l_api_name, 'uerr_update_qty', 'Unexpected error in inv_quantity_tree_pvt.update_quantities');
         END IF;

         RAISE fnd_api.g_exc_unexpected_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
         IF l_debug = 1 THEN
            log_statement(l_api_name, 'err_update_qty', 'Error in inv_quantity_tree_pvt.update_quantities');
         END IF;
         RAISE fnd_api.g_exc_error;
       END IF;

       /* Get Original reservation for which these grouped suggestions were created */
        -- {{ Test Case #  UTK- REALLOC
        --  Description : API called with either a) No existing Reservation or
        --  b) A single existing Reservation or c) Multiple existing Reservations }}
       IF l_grp_sugg_rec.reservation_id IS NOT NULL THEN
          log_event(l_api_name, 'Suggest Reservations','Sugg Res : ' || l_grp_sugg_rec.reservation_id);
          l_orig_reservation := l_demand_rsvs_ordered(l_rsv_index(l_grp_sugg_rec.reservation_id));
	  l_primary_uom_code := l_orig_reservation.primary_uom_code;
          l_new_reservation := l_orig_reservation;
       END IF;

       IF l_debug = 1 THEN
          log_event(l_api_name, 'Suggest Reservations', 'Suggested lot_number : ' || l_grp_sugg_rec.lot_number);
          log_event(l_api_name, 'Suggest Reservations', 'Suggested subinventory_code : ' || l_grp_sugg_rec.from_subinventory_code);
          log_event(l_api_name, 'Suggest Reservations', 'Suggested locator id : ' || l_grp_sugg_rec.from_locator_id);
          log_event(l_api_name, 'Suggest Reservations', 'Suggested lpn_id  : ' || l_grp_sugg_rec.lpn_id);
          log_event(l_api_name, 'Suggest Reservations', 'Suggested pri quantity  : ' || l_grp_sugg_rec.primary_quantity);
          log_event(l_api_name, 'Suggest Reservations', 'Suggested sec quantity  : ' || l_grp_sugg_rec.secondary_quantity);
       END IF;

       /* Set new_rsv record from the grouped suggestion record */
       l_new_reservation.organization_id :=  p_mo_line_rec.organization_id;
       l_new_reservation.inventory_item_id :=  p_mo_line_rec.inventory_item_id;
       l_new_reservation.supply_source_type_id         := inv_reservation_global.g_source_type_inv;
       l_new_reservation.revision :=  l_grp_sugg_rec.revision;
       l_new_reservation.lot_number := l_grp_sugg_rec.lot_number;
       l_new_reservation.subinventory_code := l_grp_sugg_rec.from_subinventory_code;
       l_new_reservation.locator_id := l_grp_sugg_rec.from_locator_id;
       l_new_reservation.lpn_id := l_grp_sugg_rec.lpn_id;

       l_new_reservation.primary_uom_code              := l_primary_uom_code;
       l_new_reservation.reservation_uom_code          := p_mo_line_rec.uom_code;
       l_new_reservation.secondary_uom_code            := p_mo_line_rec.secondary_uom;

       l_new_reservation.primary_reservation_quantity  := l_grp_sugg_rec.primary_quantity;
       l_new_reservation.secondary_reservation_quantity  := l_grp_sugg_rec.secondary_quantity;
       l_new_reservation.demand_source_type_id   := p_demand_source_type;
       l_new_reservation.demand_source_header_id := p_demand_source_header_id;
       l_new_reservation.demand_source_line_id   := p_demand_source_line_id;
       l_new_reservation.demand_source_name   := p_demand_source_name;
       l_new_reservation.requirement_date           := l_requirement_date;

       IF p_suggest_serial = 'Y' THEN
          l_suggested_serials := l_dummy_sn;
          IF ( l_debug = 1 ) THEN
             log_event(l_api_name,'Suggest_Reservations','Get Serials Suggested for this Reservation');
          END IF;
          For l_ser_rec in c_sugg_serials(l_new_reservation.organization_id, l_new_reservation.subinventory_code,
                                          l_new_reservation.locator_id, l_new_reservation.revision, l_new_reservation.lot_number,
                                          l_new_reservation.lpn_id, l_grp_sugg_rec.reservation_id
                                ) LOOP
              l_suggested_serials(i).inventory_item_id := p_mo_line_rec.inventory_item_id;
              l_suggested_serials(i).serial_number := l_ser_rec.serial_number;
          END LOOP;
       END IF;

       IF l_grp_sugg_rec.reservation_id IS NOT NULL THEN
          IF l_debug = 1 THEN
             log_event(l_api_name, 'Suggest Reservations', 'Original revision : ' || l_orig_reservation.revision);
             log_event(l_api_name, 'Suggest Reservations', 'Original lot_number : ' || l_orig_reservation.lot_number);
             log_event(l_api_name, 'Suggest Reservations', 'Original subinventory_code : ' || l_orig_reservation.subinventory_code);
             log_event(l_api_name, 'Suggest Reservations', 'Original locator id : ' || l_orig_reservation.locator_id);
             log_event(l_api_name, 'Suggest Reservations', 'Original lpn_id  : ' || l_orig_reservation.lpn_id);
             log_event(l_api_name, 'Suggest Reservations', 'Original pri quantity  : ' || l_orig_reservation.primary_reservation_quantity);
             log_event(l_api_name, 'Suggest Reservations', 'Original sec quantity  : ' || l_orig_reservation.secondary_reservation_quantity);
          END IF;

          l_last_sugg_str := l_grp_sugg_rec.sugg_str;
          l_last_reservation := l_new_reservation;

          /* Check whether original reservation is equal to the allocated record */
          /* If not equal to the original reservation the transfer the allocated quantity to the new reservation */
          IF ((nvl(l_orig_reservation.lot_number,'-999') <> nvl(l_new_reservation.lot_number, '-999')) OR
              (nvl(l_orig_reservation.revision,'-999') <> nvl(l_new_reservation.revision, '-999')) OR
              (nvl(l_orig_reservation.subinventory_code,'-999') <> nvl(l_new_reservation.subinventory_code, '-999')) OR
              (nvl(l_orig_reservation.locator_id,'-999') <> nvl(l_new_reservation.locator_id, '-999')) OR
              (nvl(l_orig_reservation.lpn_id,'-999') <> nvl(l_new_reservation.lpn_id, '-999')))  THEN

             -- Setting this to null will allow the reservation to be added to other reservations
             -- with the same controls that may have been created during this process
             l_new_reservation.reservation_id := NULL;

             inv_reservation_pvt.Transfer_Reservation (
              p_api_version_number => 1.0
              , p_init_msg_lst => fnd_api.g_true
              , x_return_status => x_return_status
              , x_msg_count  => x_msg_count
              , x_msg_data   => x_msg_data
              , p_original_rsv_rec => l_orig_reservation
              , p_to_rsv_rec  => l_new_reservation
              , p_original_serial_number => l_dummy_sn
              , p_validation_flag => fnd_api.g_false
              , x_reservation_id  => l_new_reservation_id
             );

         -- Bug 6719290 Return an error if the transfer reservation call failed
	     IF x_return_status = fnd_api.g_ret_sts_error THEN
               IF (l_debug = 1) THEN
                  log_error(l_api_name, 'Suggest_Reservations','expected error in transfer reservation');
               END IF;
               fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
             END IF;

	     -- Return an error if the transfer reservation call failed
             IF x_return_status <> fnd_api.g_ret_sts_success THEN
               IF (l_debug = 1) THEN
                  log_error(l_api_name, 'Suggest_Reservations','error in transfer reservation');
               END IF;
               fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_unexpected_error;
             END IF;
             IF l_debug = 1 THEN
                log_event(l_api_name, 'Suggest Reservations', 'After calling transfer from ' || l_orig_reservation.reservation_id || ' to ' || l_new_reservation_id);
             END IF;
          ELSE
             IF l_debug = 1 THEN
                log_event(l_api_name, 'Suggest Reservations', 'Reservation already Exists and is Detailed: ID = ' || l_grp_sugg_rec.reservation_id);
             END IF;
          END IF;
       -- ELSE reservation ID is null AND not the same inventory controls
       ELSIF l_grp_sugg_rec.sugg_str = nvl(l_last_sugg_str,'@@@') THEN
          /* Update the current reservation with the quantities from the new reservation */
          l_new_reservation.primary_reservation_quantity := l_last_reservation.primary_reservation_quantity + l_new_reservation.primary_reservation_quantity;
          l_new_reservation.secondary_reservation_quantity := l_last_reservation.secondary_reservation_quantity + l_new_reservation.secondary_reservation_quantity;

          inv_reservation_pvt.update_reservation(
                 p_api_version_number        => 1.0
               , p_init_msg_lst              => fnd_api.g_false
               , x_return_status             => x_return_status
               , x_msg_count                 => x_msg_count
               , x_msg_data                  => x_msg_data
               , p_original_rsv_rec          => l_last_reservation
               , p_to_rsv_rec                => l_new_reservation
               , p_original_serial_number    => l_dummy_sn
               , p_to_serial_number          => l_reserved_serials
               , p_validation_flag           => 'Q'
               , p_check_availability        => fnd_api.g_false
             );


             -- Return an error if the update reservation call failed
             IF x_return_status <> fnd_api.g_ret_sts_success THEN
               IF (l_debug = 1) THEN
                  log_error(l_api_name, 'Suggest_Reservations','error in update reservation');
               END IF;
               fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_unexpected_error;
             END IF;

       ELSE -- reservtion ID is null
          /* Create new reservation and set as current reservation */
          IF l_debug = 1 THEN
             log_event(l_api_name, 'Suggest Reservations', 'Defaulting vales to create the reservations');
          END IF;

          l_new_reservation.reservation_id             := NULL; -- cannot know
          l_new_reservation.demand_source_delivery        := NULL;
          l_new_reservation.primary_uom_id                := NULL;
          l_new_reservation.secondary_uom_id              := NULL;
          l_new_reservation.reservation_uom_code          := NULL;
          l_new_reservation.reservation_uom_id            := NULL;
          l_new_reservation.reservation_quantity          := NULL;
          l_new_reservation.autodetail_group_id           := NULL;
          l_new_reservation.external_source_code          := NULL;
          l_new_reservation.external_source_line_id       := NULL;
          l_new_reservation.supply_source_header_id       := NULL;
          l_new_reservation.supply_source_line_id         := NULL;
          l_new_reservation.supply_source_name            := NULL;
          l_new_reservation.supply_source_line_detail     := NULL;
          l_new_reservation.subinventory_id               := NULL;
          l_new_reservation.lot_number_id                 := NULL;
          l_new_reservation.pick_slip_number              := NULL;
          l_new_reservation.attribute_category            := NULL;
          l_new_reservation.attribute1                    := NULL;
          l_new_reservation.attribute2                    := NULL;
          l_new_reservation.attribute3                    := NULL;
          l_new_reservation.attribute4                    := NULL;
          l_new_reservation.attribute5                    := NULL;
          l_new_reservation.attribute6                    := NULL;
          l_new_reservation.attribute7                    := NULL;
          l_new_reservation.attribute8                    := NULL;
          l_new_reservation.attribute9                    := NULL;
          l_new_reservation.attribute10                   := NULL;
          l_new_reservation.attribute11                   := NULL;
          l_new_reservation.attribute12                   := NULL;
          l_new_reservation.attribute13                   := NULL;
          l_new_reservation.attribute14                   := NULL;
          l_new_reservation.attribute15                   := NULL;
          l_new_reservation.ship_ready_flag               := NULL;
          l_new_reservation.detailed_quantity             := 0;

          inv_reservation_pub.create_reservation(
             p_api_version_number         => 1.0
           , p_init_msg_lst               => fnd_api.g_false
           , x_return_status              => x_return_status
           , x_msg_count                  => x_msg_count
           , x_msg_data                   => x_msg_data
           , p_rsv_rec                    => l_new_reservation
           , p_serial_number              => l_suggested_serials
           , x_serial_number              => l_reserved_serials
           , p_partial_reservation_flag   => fnd_api.g_true
           , p_force_reservation_flag     => fnd_api.g_false
           , p_validation_flag            => 'Q'
           , x_quantity_reserved          => l_qty_succ_reserved
           , x_reservation_id             => l_new_reservation_id
           );

          IF l_debug = 1 THEN
             log_event(l_api_name, 'Suggest Reservations', 'After creating the reservations: status =' || x_return_status);
             log_event(l_api_name, 'Suggest Reservations', 'After creating the reservations: Reservation ID =' || l_new_reservation_id);
          END IF;
          -- Return an error if the create reservation call failed
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
            IF (l_debug = 1) THEN
               log_error(l_api_name, 'Process_Reservations','error in create reservation');
            END IF;
            fnd_message.set_name('INV', 'INV_QRY_RSV_FAILED');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END IF;
   END LOOP;

   -- Return the suggestions
   OPEN c_suggestions;
   FETCH c_suggestions
    BULK COLLECT INTO
      p_suggestions.from_organization_id
    , p_suggestions.to_organization_id
    , p_suggestions.revision
    , p_suggestions.lot_number
    , p_suggestions.lot_expiration_date
    , p_suggestions.from_subinventory_code
    , p_suggestions.to_subinventory_code
    , p_suggestions.from_locator_id
    , p_suggestions.to_locator_id
    , p_suggestions.lpn_id
    , p_suggestions.reservation_id
    , p_suggestions.serial_number
    , p_suggestions.grade_code
    , p_suggestions.from_cost_group_id
    , p_suggestions.to_cost_group_id
    , p_suggestions.primary_quantity
    , p_suggestions.transaction_quantity
    , p_suggestions.secondary_quantity;
    CLOSE c_suggestions;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      --ROLLBACK TO suggest_reservations_sa;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error in suggest_reservations - ' || x_msg_data);
      END IF ;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      --ROLLBACK TO suggest_reservations_sa;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
      log_error(l_api_name, 'unexp_error', 'Unexpected error ' || 'in suggest_reservations - ' || x_msg_data);
      END IF;
     --
    WHEN OTHERS THEN
      ROLLBACK TO suggest_reservations_sa;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error ' || 'in suggest_reservations - ' || x_msg_data);
         log_error(l_api_name, 'other_error', 'SQL Error ' || SQLERRM);
      END IF;
 END suggest_reservations;

END wms_rule_extn_pvt;

/
