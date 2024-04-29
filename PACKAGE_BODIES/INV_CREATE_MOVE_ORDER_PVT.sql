--------------------------------------------------------
--  DDL for Package Body INV_CREATE_MOVE_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CREATE_MOVE_ORDER_PVT" AS
  /* $Header: INVTOMMB.pls 120.0 2005/05/25 04:58:37 appldev noship $ */

  --  Global constant holding the package name

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_Create_Move_Order_PVT';
  g_version_printed   BOOLEAN      := FALSE;

  PROCEDURE print_debug(p_message IN VARCHAR2, p_module IN VARCHAR2, p_level NUMBER DEFAULT 9) IS
  BEGIN
    IF NOT g_version_printed THEN
      inv_log_util.TRACE('$Header: INVTOMMB.pls 120.0 2005/05/25 04:58:37 appldev noship $', g_pkg_name, 9);
      g_version_printed  := TRUE;
    END IF;

    inv_log_util.TRACE(p_message, g_pkg_name || '.' || p_module, p_level);
  END;

  --
  -- Create_Move_Order : This procedure would create a move order from
  --                     minmax planning with source type subinventory transfer
  --        or replenishment

  FUNCTION create_move_orders(
    p_item_id                IN NUMBER
  , p_quantity               IN NUMBER
  , p_secondary_quantity     IN NUMBER   DEFAULT NULL          --INVCONV changes
  , p_need_by_date           IN DATE
  , p_primary_uom_code       IN VARCHAR2
  , p_secondary_uom_code     IN VARCHAR2 DEFAULT NULL          --INVCONV changes
  , p_grade_code             IN VARCHAR2 DEFAULT NULL          --INVCONV changes
  , p_user_id                IN NUMBER
  , p_organization_id        IN NUMBER
  , p_src_type               IN NUMBER
  , p_src_subinv             IN VARCHAR2
  , p_subinv                 IN VARCHAR2
  , p_locator_id             IN NUMBER   DEFAULT NULL
  , p_reference              IN VARCHAR2 DEFAULT NULL
  , p_reference_source       IN NUMBER   DEFAULT NULL
  , p_reference_type         IN NUMBER   DEFAULT NULL
  )
    RETURN VARCHAR2 IS
    l_x_trohdr_rec         inv_move_order_pub.trohdr_rec_type;
    l_x_trolin_tbl         inv_move_order_pub.trolin_tbl_type;
    l_trohdr_rec           inv_move_order_pub.trohdr_rec_type;
    l_trolin_tbl           inv_move_order_pub.trolin_tbl_type;
    l_return_status        VARCHAR2(1)                        := fnd_api.g_ret_sts_success;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(240);
    msg                    VARCHAR2(2000);
    l_header_id            NUMBER                             := fnd_api.g_miss_num;
    l_line_num             NUMBER                             := 0;
    l_order_count          NUMBER                             := 1;
    l_approval             NUMBER;
    l_debug                NUMBER                             := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_module_name CONSTANT VARCHAR2(30)                       := 'Create_move_orders';
  BEGIN
    /*inv_debug.message('In create transfer order');*/
    IF l_debug = 1 THEN
      print_debug('Input Parameters are', l_module_name, 3);
      print_debug('p_item_id           => ' || p_item_id, l_module_name, 3);
      print_debug('p_quantity          => ' || p_quantity, l_module_name, 3);
      print_debug('p_need_by_date      => ' || p_need_by_date, l_module_name, 3);
      print_debug('p_primary_uom_code  => ' || p_primary_uom_code, l_module_name, 3);
      print_debug('p_user_id           => ' || p_user_id, l_module_name, 3);
      print_debug('p_organization_id   => ' || p_organization_id, l_module_name, 3);
      print_debug('p_src_type          => ' || p_src_type, l_module_name, 3);
      print_debug('p_src_subinv        => ' || p_src_subinv, l_module_name, 3);
      print_debug('p_subinv            => ' || p_subinv, l_module_name, 3);
      print_debug('p_locator_id        => ' || p_locator_id, l_module_name, 3);
      print_debug('p_reference         => ' || p_reference, l_module_name, 3);
      print_debug('p_reference_source  => ' || p_reference_source, l_module_name, 3);
      print_debug('p_reference_type    => ' || p_reference_type, l_module_name, 3);
    END IF;

    --
    -- From now onwards(Patchset J), Move Orders should also honor
    -- the profile value set at the  profile "INV: RC Requisition Approval"
    -- This profile can have 3 values:
    -- (Lookup Type 'MTL_REQUISITION_APPROVAL' defined in MFG_LOOKUPS)
    --  1- Pre-approved
    --  2- Pre-approve move orders only (Incomplete)
    --  3- Approval Required
    --
    l_approval := to_number(nvl(FND_PROFILE.VALUE('RC_REQUISITION_APPROVAL'),'2'));
    IF l_debug = 1 THEN
       print_debug('Approval Status profile is: ' || l_approval
                   ,l_module_name
                   ,3);
    END IF;
    --
    -- Converting these codes to the ones defined in MFG_LOOKUPS under the
    -- lookup type'MTL_TXN_REQUEST_STATUS'.
    --  IF  l_approval = 3  THEN
    --    l_approval := 1; -- Incomplete
    --  ELSE
    --    l_approval := 7; -- Pre-approved
    --  END IF;
    --
    IF  l_approval = 3  THEN
      l_approval := 1; -- Incomplete
    ELSE
      l_approval := 7; -- Pre Approved
    END IF;
    IF l_debug = 1 THEN
       print_debug('Approval Status for the MO Header and Lines : ' || l_approval
                   ,l_module_name
                   ,3);
    END IF;

    l_trohdr_rec.created_by                             := p_user_id;
    l_trohdr_rec.creation_date                          := SYSDATE;
    l_trohdr_rec.date_required                          := p_need_by_date;
    l_trohdr_rec.from_subinventory_code                 := p_src_subinv;
    l_trohdr_rec.header_status                          := l_approval;
    l_trohdr_rec.last_updated_by                        := p_user_id;
    l_trohdr_rec.last_update_date                       := SYSDATE;
    l_trohdr_rec.last_update_login                      := p_user_id;
    l_trohdr_rec.organization_id                        := p_organization_id;
    l_trohdr_rec.status_date                            := SYSDATE;
    l_trohdr_rec.to_subinventory_code                   := p_subinv;
    l_trohdr_rec.move_order_type                        := inv_globals.g_move_order_replenishment;
    l_trohdr_rec.transaction_type_id                    := inv_globals.g_type_transfer_order_subxfr;
    l_trohdr_rec.db_flag                                := fnd_api.g_true;
    l_trohdr_rec.operation                              := inv_globals.g_opr_create;
    l_line_num                                          := l_line_num + 1;
    l_trolin_tbl(l_order_count).created_by              := fnd_global.user_id;
    l_trolin_tbl(l_order_count).creation_date           := SYSDATE;
    l_trolin_tbl(l_order_count).date_required           := p_need_by_date;
    l_trolin_tbl(l_order_count).from_subinventory_code  := p_src_subinv;
    l_trolin_tbl(l_order_count).inventory_item_id       := p_item_id;
    l_trolin_tbl(l_order_count).last_updated_by         := fnd_global.user_id;
    l_trolin_tbl(l_order_count).last_update_date        := SYSDATE;
    l_trolin_tbl(l_order_count).last_update_login       := fnd_global.login_id;
    l_trolin_tbl(l_order_count).line_id                 := fnd_api.g_miss_num;
    l_trolin_tbl(l_order_count).line_number             := l_line_num;
    l_trolin_tbl(l_order_count).line_status             := l_approval;
    l_trolin_tbl(l_order_count).organization_id         := p_organization_id;
    l_trolin_tbl(l_order_count).quantity                := p_quantity;
    l_trolin_tbl(l_order_count).secondary_quantity      := p_secondary_quantity; 	-- INVCONV changes
    l_trolin_tbl(l_order_count).status_date             := SYSDATE;
    l_trolin_tbl(l_order_count).to_subinventory_code    := p_subinv;
    l_trolin_tbl(l_order_count).uom_code                := p_primary_uom_code;
    l_trolin_tbl(l_order_count).secondary_uom           := p_secondary_uom_code; 	-- INVCONV changes
    l_trolin_tbl(l_order_count).grade_code              := p_grade_code;        	-- INVCONV changes
    l_trolin_tbl(l_order_count).transaction_type_id     := inv_globals.g_type_transfer_order_subxfr;

    l_trolin_tbl(l_order_count).db_flag                 := fnd_api.g_true;
    l_trolin_tbl(l_order_count).operation               := inv_globals.g_opr_create;

    /*Patchset J:Enhancements:Health Care Project*/
    IF (inv_control.g_current_release_level >= inv_release.g_j_release_level) THEN
      print_debug('Patchset J:PAR replenish Counts Project', l_module_name, 9);
      l_trolin_tbl(l_order_count).REFERENCE      := p_reference;
      l_trolin_tbl(l_order_count).reference_id   := p_reference_source;

      IF p_reference_type = 10 THEN
        l_trolin_tbl(l_order_count).reference_type_code  := inv_transfer_order_pvt.g_ref_type_repl_count;
      ELSE
        l_trolin_tbl(l_order_count).reference_type_code  := inv_transfer_order_pvt.g_ref_type_reord_point;
      END IF;

      l_trolin_tbl(l_order_count).to_locator_id  := p_locator_id;
    END IF;

    /*inv_debug.message('calling inv_transfer_order_pvt.process_transfer_order');*/
    inv_transfer_order_pvt.process_transfer_order(
      p_api_version_number         => 1.0
    , p_init_msg_list              => 'T'
    , x_return_status              => l_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_trohdr_rec                 => l_trohdr_rec
    , p_trolin_tbl                 => l_trolin_tbl
    , x_trohdr_rec                 => l_x_trohdr_rec
    , x_trolin_tbl                 => l_x_trolin_tbl
    );

    IF (l_debug = 1) THEN
      print_debug('Return status from Process Transfer Order is ' || l_return_status, l_module_name, 9);
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_msg_pub.add_exc_msg(g_pkg_name, 'Create_move_orders');
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_msg_pub.add_exc_msg(g_pkg_name, 'Create_move_orders');
      RAISE fnd_api.g_exc_error;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE fnd_api.g_exc_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Create_Move_Orders');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END create_move_orders;
END inv_create_move_order_pvt;

/
