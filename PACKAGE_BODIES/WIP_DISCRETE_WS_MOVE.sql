--------------------------------------------------------
--  DDL for Package Body WIP_DISCRETE_WS_MOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DISCRETE_WS_MOVE" AS
/* $Header: wipdsmvb.pls 120.2 2006/09/19 06:31:24 paho noship $ */

  procedure explodeComponents(p_jobID        in number,
                              p_orgID        in number,
                              p_moveQty      in number,
                              p_fromOp       in number,
                              p_fromStep     in number,
                              p_toOp         in number,
                              p_toStep       in number,
                              p_txnType      in number,
                              x_moveTxnID    out nocopy number,
                              x_cplTxnID     out nocopy number,
                              x_txnHeaderID  out nocopy number,
                              x_compHeaderID out nocopy number,
                              x_batchID      out nocopy number,
                              x_lotEntryType out nocopy number,
                              x_compInfo     out nocopy system.wip_lot_serial_obj_t,
                              x_mtlMode      out nocopy number,
                              x_periodID     out nocopy number,
                              x_returnStatus out nocopy varchar2,
                              x_errMessage   out nocopy varchar2) is
    openPastPeriod boolean;
    periodID number;
  begin
    select wip_transactions_s.nextval into x_moveTxnID from dual;
    select mtl_material_transactions_s.nextval into x_cplTxnID from dual;
    select mtl_material_transactions_s.nextval into x_batchID from dual;
    select mtl_material_transactions_s.nextval into x_txnHeaderID from dual;

    openPastPeriod := false;
    x_mtlMode := nvl(to_number(fnd_profile.value('TRANSACTION_PROCESS_MODE')),
                     WIP_CONSTANTS.ONLINE);
    if ( x_mtlMode = WIP_CONSTANTS.FORM_LEVEL ) then
      x_mtlMode := nvl(to_number(fnd_profile.value('WIP_SHOP_FLOOR_MTL_TRANSACTION')),
                       WIP_CONSTANTS.ONLINE);
    end if;

    if ( x_mtlMode <> WIP_CONSTANTS.ONLINE ) then
      select mtl_material_transactions_s.nextval into x_compHeaderID from dual;
    else
      x_compHeaderID := x_txnHeaderID;
    end if;

    -- derive the accounting period stuff by calling inv routine
    invttmtx.tdatechk(
      org_id           => p_orgID,
      transaction_date => sysdate,
      period_id        => periodID,
      open_past_period => openPastPeriod);

    if (periodID = -1 or periodID = 0) then
      fnd_message.set_name(
        application => 'INV',
        name        => 'INV_NO_OPEN_PERIOD');
      x_returnStatus := fnd_api.g_ret_sts_error;
      x_errMessage := fnd_message.get;
      return;
    end if;

    x_periodID := periodID;

    wma_move.backflush(p_jobID => p_jobID,
                       p_orgID => p_orgID,
                       p_childMoveID => -1,
                       p_moveID => x_moveTxnID,
                       p_ocQty => 0,
                       p_moveQty => p_moveQty,
                       p_txnDate => sysdate,
                       p_txnHdrID => x_txnHeaderID,
                       p_fm_op => p_fromOp,
                       p_fm_step => p_fromStep,
                       p_to_op => p_toOp,
                       p_to_step => p_toStep,
                       p_cmpTxnID => x_cplTxnID,
                       p_txnType => p_txnType,
                       p_objectID => -1,
                       x_lotEntryType => x_lotEntryType,
                       x_compInfo => x_compInfo,
                       x_returnStatus => x_returnStatus,
                       x_errMessage => x_errMessage);

  end explodeComponents;


  procedure processMove(moveData       in  MoveData,
                        x_returnStatus out nocopy varchar2,
                        x_errMessage   out nocopy varchar2) is
    qaCollectionID number;
    processStatus number;
    groupID number;
    primaryItemID number;
    lineID number;

    fmOpCode varchar2(5);
    fmDeptID number;
    fmDeptCode varchar2(11);
    fmPrevOpSeq number;
    fmNextOpSeq number;
    fmOpExists boolean;
    toOpCode varchar2(5);
    toDeptID number;
    toDeptCode varchar2(11);
    toPrevOpSeq number;
    toNextOpSeq number;
    toOpExists boolean;

    l_totalNum number;
    l_returnStatus VARCHAR2(1);
    l_logLevel NUMBER;
    l_params  wip_logger.param_tbl_t;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    l_totalNum := 0;
    l_logLevel := to_number(fnd_log.g_current_runtime_level);
    savepoint dsmove1;

    if ( l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'not printing params';
      l_params(1).paramValue := ' ';
      wip_logger.entryPoint(p_procName => 'wip_discrete_ws_move.insertMoveRecord',
                            p_params => l_params,
                            x_returnStatus => l_returnStatus);
    end if;

    qaCollectionID := moveData.qaCollectionID;
    if ( moveData.qaCollectionID is not null ) then
      select count(*) into l_totalNum
        from qa_results
       where collection_id = moveData.qaCollectionID;
      if ( l_totalNum = 0 ) then
        qaCollectionID := null;
      end if;
    end if;

    if ( moveData.txnMode = 1 ) then
      groupID := moveData.txnID;
      processStatus := 2; -- running
    else
      groupID := null;
      processStatus := 1;
    end if;

    select primary_item_id, line_id
      into primaryItemID, lineID
      from wip_discrete_jobs
     where organization_id = moveData.orgID
       and wip_entity_id = moveData.wipEntityID;

    wip_operations_info.derive_info(
      p_org_id => moveData.orgID,
      p_wip_entity_id => moveData.wipEntityID,
      p_first_schedule_id => null,
      p_operation_seq_num => moveData.fmOp,
      p_operation_code => fmOpCode,
      p_department_id => fmDeptID,
      p_department_code => fmDeptCode,
      p_prev_op_seq_num => fmPrevOpSeq,
      p_next_op_seq_num => fmNextOpSeq,
      p_operation_exists => fmOpExists);

    wip_operations_info.derive_info(
      p_org_id => moveData.orgID,
      p_wip_entity_id => moveData.wipEntityID,
      p_first_schedule_id => null,
      p_operation_seq_num => moveData.toOp,
      p_operation_code => toOpCode,
      p_department_id => toDeptID,
      p_department_code => toDeptCode,
      p_prev_op_seq_num => toPrevOpSeq,
      p_next_op_seq_num => toNextOpSeq,
      p_operation_exists => toOpExists);


    insert into wip_move_txn_interface
         (transaction_id,
          group_id,
          source_code,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          process_phase,
          process_status,
          transaction_type,
          organization_id,
          wip_entity_id,
          entity_type,
          transaction_date,
          acct_period_id,
          fm_operation_seq_num,
          fm_intraoperation_step_type,
          to_operation_seq_num,
          to_intraoperation_step_type,
          transaction_quantity,
          transaction_uom,
          scrap_account_id,
          qa_collection_id,
          primary_item_id,
          line_id,
          fm_operation_code,
          fm_department_id,
          fm_department_code,
          to_operation_code,
          to_department_id,
          to_department_code,
          primary_quantity,
          primary_uom)
   values(moveData.txnID,
          groupID,
          'Discrete Station Move',
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          2, -- move processing
          processStatus,
          moveData.txnType,
          moveData.orgID,
          moveData.wipEntityID,
          1,
          sysdate,
          moveData.periodID,
          moveData.fmOp,
          moveData.fmStep,
          moveData.toOp,
          moveData.toStep,
          moveData.txnQty,
          moveData.txnUOM,
          moveData.scrapAcctID,
          qaCollectionID,
          primaryItemID,
          lineID,
          fmOpCode,
          fmDeptID,
          fmDeptCode,
          toOpCode,
          toDeptID,
          toDeptCode,
          moveData.txnQty,
          moveData.txnUOM
          );

    if ( moveData.txnMode = WIP_CONSTANTS.BACKGROUND ) then
      return;
    end if;

    -- process online move transactions
    if ( moveData.compHeaderID is not null ) then
      wip_mtlTempProc_priv.validateInterfaceTxns(
         p_txnHdrID      => moveData.compHeaderID,
         p_addMsgToStack => fnd_api.g_true,
         p_rollbackOnErr => fnd_api.g_true,
         x_returnStatus  => l_returnStatus);
    end if;

    if ( l_returnStatus <> fnd_api.g_ret_sts_success) then
      x_returnStatus := fnd_api.g_ret_sts_error;
      wip_utilities.get_message_stack(p_msg => x_errMessage);
      return;
    end if;

    if ( moveData.assyHeaderID is not null AND moveData.assyHeaderID <> moveData.compHeaderID ) then
      wip_mtlTempProc_priv.validateInterfaceTxns(
         p_txnHdrID      => moveData.assyHeaderID,
         p_addMsgToStack => fnd_api.g_true,
         p_rollbackOnErr => fnd_api.g_true,
         x_returnStatus  => l_returnStatus);
      if ( l_returnStatus <> fnd_api.g_ret_sts_success) then
        x_returnStatus := fnd_api.g_ret_sts_error;
        wip_utilities.get_message_stack(p_msg => x_errMessage);
        return;
      end if;
    end if;

    wip_movProc_priv.processIntf(
                        p_group_id => groupID,
                        p_proc_phase => WIP_CONSTANTS.MOVE_PROC,
                        p_time_out => 0,
                        p_move_mode => WIP_CONSTANTS.ONLINE,
                        p_bf_mode => WIP_CONSTANTS.ONLINE,
                        p_mtl_mode => moveData.mtlMode,
                        p_endDebug => fnd_api.g_true,
                        p_initMsgList => fnd_api.g_true,
                        p_insertAssy => fnd_api.g_false,
                        p_do_backflush => fnd_api.g_false,
                        p_assy_header_id => moveData.assyHeaderID,
                        p_mtl_header_id => moveData.compHeaderID,
                        x_returnStatus => x_returnStatus);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      wip_utilities.get_message_stack(p_msg => x_errMessage);
      rollback to dsmove1;
    end if;

  exception
    when fnd_api.g_exc_unexpected_error THEN
      rollback to dsmove1;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      wip_utilities.get_message_stack(p_msg => x_errMessage);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_discrete_ws_move.insertMoveRecord',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => x_errMessage,
                             x_returnStatus => l_returnStatus);
      end if;

    when others then
      rollback to dsmove1;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('PROCEDURE', 'wip_discrete_ws_move.processMove');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      x_errMessage := fnd_message.get;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_discrete_ws_move.processMove',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => x_errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
  end processMove;


  procedure createLocator(p_orgID        in number,
                          p_locatorName  in varchar2,
                          p_subinv       in varchar2,
                          x_locatorID    out nocopy number,
                          x_returnStatus out nocopy varchar2,
                          x_errMessage   out nocopy varchar2) is
    l_msgCount number;
    l_locExists varchar2(1);
  begin
    inv_loc_wms_pub.create_locator(
                     x_return_status => x_returnStatus,
                     x_msg_count => l_msgCount,
                     x_msg_data => x_errMessage,
                     x_inventory_location_id => x_locatorID,
                     x_locator_exists => l_locExists,
                     p_organization_id => p_orgID,
                     p_organization_code => null,
                     p_concatenated_segments => p_locatorName,
                     p_description => null,
                     p_inventory_location_type => 3, --storage locator
                     p_picking_order => null,
                     p_location_maximum_units => null,
                     p_subinventory_code => p_subinv,
                     p_location_weight_uom_code => null,
                     p_max_weight => null,
                     p_volume_uom_code => null,
                     p_max_cubic_area => null,
                     p_x_coordinate => null,
                     p_y_coordinate => null,
                     p_z_coordinate => null,
                     p_physical_location_id => null,
                     p_pick_uom_code => null,
                     p_dimension_uom_code => null,
                     p_length => null,
                     p_width => null,
                     p_height => null,
                     p_status_id => null,
                     p_dropping_order => null);
  end createLocator;


  procedure checkOvershipment(p_orgID       in number,
                              p_itemID      in number,
                              p_orderLineID in number,
                              p_primaryQty  in number,
                              p_primaryUOM  in varchar2,
                              x_returnStatus out nocopy varchar2,
                              x_errMessage   out nocopy varchar2) is
    l_wsh_minmax_in_rec wsh_integration.minmaxinrectype;
    l_wsh_minmax_out_rec wsh_integration.minmaxoutrectype;
    l_wsh_minmax_inout_rec wsh_integration.minmaxinoutrectype;
    l_msg_count number;
    l_msg_data varchar2(2000);

    l_max_rem_primary_qty number;
    l_inv_primary_rsv_quantity number;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    l_wsh_minmax_in_rec.api_version_number := 1.0;
    l_wsh_minmax_in_rec.source_code := 'OE';--Fix for Bug 4635597
    l_wsh_minmax_in_rec.line_id := p_orderLineID;

    wsh_integration.get_min_max_tolerance_quantity(
      p_in_attributes => l_wsh_minmax_in_rec,
      p_out_attributes => l_wsh_minmax_out_rec,
      p_inout_attributes => l_wsh_minmax_inout_rec,
      x_return_status => x_returnStatus,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);

    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      fnd_message.set_name(application => 'WIP',
                           name => 'WIP_WSH_MINMAX_API_FAILURE');
      fnd_message.set_token(token => 'ENTITY1',
                            value => substr(l_msg_data, 1, 250),
                            translate => false);
      x_errMessage := fnd_message.get;
      return;
    end if;

    l_max_rem_primary_qty := inv_convert.inv_um_convert(
        item_id => p_itemID,
        precision => null,
        from_quantity => l_wsh_minmax_out_rec.max_remaining_quantity,
        from_unit => l_wsh_minmax_out_rec.quantity_uom,
        to_unit => p_primaryUOM,
        from_name => null,
        to_name => null);

    select nvl(sum(primary_reservation_quantity), 0)
      into l_inv_primary_rsv_quantity
      from mtl_reservations
     where demand_source_line_id = p_orderLineID
       and organization_id = p_orgID
       and supply_source_type_id = 13;

    if ( p_primaryQty > l_max_rem_primary_qty - l_inv_primary_rsv_quantity ) then
      x_returnStatus := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WIP', 'WIP_OSHP_TOLERANCE_FAIL');
      x_errMessage := fnd_message.get;
    end if;

  end checkOvershipment;


  function clientToServerDate(p_date in date) return date is
    l_dateval varchar2(100);
    l_date  date;
  begin
    if ( p_date is null ) then
      return null;
    end if;
    l_dateval := to_char(p_date, fnd_date.outputDT_mask);
    l_date := fnd_date.displayDT_to_date(l_dateval);
    return l_date;
  end clientToServerDate;


  function serverToClientDate(p_date in date) return date is
    l_dateval varchar2(100);
    l_date  date;
  begin
    if ( p_date is null ) then
      return null;
    end if;
    l_dateval := fnd_date.date_to_displayDT(p_date);
    l_date := to_date(l_dateval, fnd_date.outputDT_mask);
    return l_date;
  end serverToClientDate;


  procedure initTimezone is
  begin
    fnd_date.timezones_enabled := true;
    fnd_date.server_timezone_code := fnd_timezones.get_server_timezone_code;
    fnd_date.client_timezone_code := fnd_timezones.get_client_timezone_code;
    if ( fnd_timezones.timezones_enabled = 'N' ) then
      fnd_date.timezones_enabled := false;
    end if;
  end initTimezone;


/* Fix for bug 4568517: New procedure get_prj_loc_lov added.
 * ==========================================================
 * Procedure returns a ref cursor containing LOV statement to
 * be used by discrete workstation code completion locator.
 * For PJM enabled orgs, the locator will show project number
 * and task number, and if project/task are passed, the
 * restriction would be applied.
 *===========================================================
 */
PROCEDURE get_prj_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  ) IS

  l_ispjm_org VARCHAR2(1);
  l_sub_type      NUMBER;
BEGIN
  BEGIN
    SELECT nvl(PROJECT_REFERENCE_ENABLED,'N')
    INTO   l_ispjm_org
    FROM   pjm_org_parameters
    WHERE  organization_id=p_organization_id;
  EXCEPTION
     WHEN NO_DATA_FOUND  THEN
       l_ispjm_org:='N';
  END;

  BEGIN
    SELECT Nvl(subinventory_type,1)
    INTO   l_sub_type
    FROM   mtl_secondary_inventories
    WHERE  secondary_inventory_name = p_subinventory_code
    AND    organization_id = p_organization_id;
  EXCEPTION
    WHEN OTHERS THEN
        l_sub_type := 1;
    END;

  IF l_ispjm_org='N' THEN /*Non PJM Org*/
    IF p_Restrict_Locators_Code = 1 AND l_sub_type = 1 THEN --Locators restricted to predefined list
      OPEN   x_Locators FOR
      SELECT a.inventory_location_id,
             a.concatenated_segments,
             nvl( a.description, -1)
      FROM   mtl_item_locations_kfv a,mtl_secondary_locators b
      WHERE  b.organization_id = p_Organization_Id
      AND    b.inventory_item_id = p_Inventory_Item_Id
      AND    nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate)
      AND    b.subinventory_code = p_Subinventory_Code
      AND    a.inventory_location_id = b.secondary_locator
      AND    a.concatenated_segments LIKE (p_concatenated_segments)
      AND    inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               a.inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
      ORDER BY 2;

    ELSE --Locators not restricted
      OPEN   x_Locators FOR
      SELECT inventory_location_id,
             concatenated_segments,
             description
      FROM   mtl_item_locations_kfv
      WHERE  organization_id = p_Organization_Id
      AND    subinventory_code = p_Subinventory_Code
      AND    nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate)
      AND    concatenated_segments LIKE (p_concatenated_segments )
      AND    inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
      ORDER BY 2;
    END IF;
  ELSE /*PJM org*/
    IF p_Restrict_Locators_Code = 1 AND l_sub_type = 1 THEN --Locators restricted to predefined list
      OPEN x_Locators FOR
      SELECT a.inventory_location_id,
             inv_project.get_locator(a.inventory_location_id,
                                     a.organization_id) concatenated_segments,
             nvl( a.description, -1)
      FROM   mtl_item_locations_kfv a,mtl_secondary_locators b
      WHERE  b.organization_id = p_Organization_Id
      AND    b.inventory_item_id = p_Inventory_Item_Id
      AND    nvl(a.disable_date, trunc(sysdate+1)) > trunc(sysdate)
      AND    b.subinventory_code = p_Subinventory_Code
      AND    a.inventory_location_id = b.secondary_locator
      AND    a.concatenated_segments like (p_concatenated_segments )
      AND    nvl(a.project_id,-1) = nvl(p_project_id, -1)
      AND    nvl(a.task_id, -1) = nvl(p_task_id, -1)
      AND    inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               a.inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
      ORDER BY 2;
    ELSE --Locators not restricted
      OPEN x_Locators FOR
      SELECT inventory_location_id,
             inv_project.get_locator(inventory_location_id,
                                     organization_id) concatenated_segments,
             description
      FROM   mtl_item_locations_kfv
      WHERE  organization_id = p_Organization_Id
      AND    subinventory_code = p_Subinventory_Code
      AND    nvl(disable_date, trunc(sysdate+1)) > trunc(sysdate)
      AND    concatenated_segments LIKE (p_concatenated_segments )
      AND    nvl(project_id,-1) = nvl(p_project_id, -1)
      AND    nvl(task_id, -1) = nvl(p_task_id, -1)
      AND    inv_material_status_grp.is_status_applicable
             ( p_wms_installed,
               NULL,
               p_transaction_type_id,
               NULL,
               NULL,
               p_Organization_Id,
               p_Inventory_Item_Id,
               p_Subinventory_Code,
               inventory_location_id,
               NULL,
               NULL,
               'L') = 'Y'
      ORDER BY 2;
    END IF;
  END IF;
END get_prj_loc_lov;

END wip_discrete_ws_move;

/
