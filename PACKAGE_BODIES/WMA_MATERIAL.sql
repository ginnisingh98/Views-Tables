--------------------------------------------------------
--  DDL for Package Body WMA_MATERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_MATERIAL" AS
/* $Header: wmapmtlb.pls 120.1 2006/05/06 04:04:36 mraman noship $ */

  /**
   * Forward declaration
   */
  Function checkQty(txnType    NUMBER,
                    txnQty     NUMBER,
                    errMessage OUT NOCOPY VARCHAR2) RETURN boolean;


  /**
   * This procedure is the entry point into the Material Transaction
   * processing code for processing.
   * Parameters:
   *   parameters  ResParams contains values from the mobile form.
   *   status      Indicates success (0), failure (-1).
   *   errMessage  The error or warning message, if any.
   */
  PROCEDURE process(param      IN     MtlParam,
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2) IS
    error VARCHAR2(241);                        -- error message
    mtlRec MtlRecord;                           -- record to populate and insert
    procMode NUMBER;
    l_returnStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER;
  BEGIN
    savepoint wmapmtlb0;

    l_logLevel  := to_number(fnd_log.g_current_runtime_level);

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'not printing params';
      l_params(1).paramValue := ' ';
      wip_logger.entryPoint(p_procName => 'wma_material.process',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
    end if;

    status := 0;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('before derive', l_returnStatus);
    end if;

    -- derive and validate all necessary fields for insertion
    if ( derive(param, mtlRec, error) = false ) then
      -- process error
      status := -1;
      errMessage := error;
      return;
    end if;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('before put', l_returnStatus);
    end if;

    -- insert into the interface table for background processing
    if ( put(mtlRec, error) = false ) then
      -- process error
      status := -1;
      errMessage := error;
      return;
    end if;

    --if online, go ahead and process the txn
--    if(wma_derive.getTxnMode(param.environment.orgID) = wip_constants.online OR
--       param.isFromSerializedPage = 1 ) then
--      wip_mtlProc_priv.processTemp(p_initMsgList => fnd_api.g_true,
--                                   p_processInv  => fnd_api.g_true,
--                                   p_endDebug => fnd_api.g_true,
--                                   p_txnTmpID => param.transactionTempID,
--                                   x_returnStatus => l_returnStatus);

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('before processor', l_returnStatus);
    end if;

    wip_mtlTempProc_priv.processTemp(p_initMsgList => fnd_api.g_true,
                                     p_txnHdrID => mtlRec.transaction_header_id,
                                     p_txnMode => mtlRec.transaction_mode,
                                     p_destroyQtyTrees => fnd_api.g_true,
                                     x_returnStatus => l_returnStatus,
                                     x_errorMsg => errMessage);
    if(l_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_material.process',
                           p_procReturnStatus => status,
                           p_msg => 'success',
                           x_returnStatus => l_returnStatus);
    end if;
  EXCEPTION
    when fnd_api.g_exc_unexpected_error then
      rollback to wmapmtlb0;
      status := -1;
--      wip_utilities.get_message_stack(p_msg => errMessage);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_material.process',
                               p_procReturnStatus => status,
                               p_msg => errMessage,
                               x_returnStatus => l_returnStatus);
      end if;
    when others then
      status := -1;
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_material.process');
      fnd_message.set_token ('ERROR', SQLERRM);
      errMessage := fnd_message.get;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_material.process',
                               p_procReturnStatus => status,
                               p_msg => errMessage,
                               x_returnStatus => l_returnStatus);
      end if;
  END process;


  /**
   * This function is used to derive the neccessary information to filled out
   * the MtlRecord structure to passed into function put.
   *
   * HISTORY:
   * 30-DEC-2004  spondalu  Bug 4093569: eAM-WMS Integration enhancements: Set value
   *                        for element rebuild_item_id of record mtlRec
   */
  Function derive(param  MtlParam,
                  mtlRec OUT NOCOPY MtlRecord,
                  errMsg OUT NOCOPY VARCHAR2) Return boolean IS

    periodID number;
    job wma_common.Job;
    item wma_common.Item;
    openPastPeriod boolean := false;

  Begin

    job := wma_derive.getJob(param.jobID);
    if (job.wipEntityID is null) then
      fnd_message.set_name ('WIP', 'WIP_JOB_DOES_NOT_EXIST');
      fnd_message.set_token('INTERFACE', 'wma_material.derive', TRUE);
      errMsg := fnd_message.get;
      return false;
    end if;

    item := wma_derive.getItem(param.itemID,
                               param.environment.orgID,
                               param.locatorID);

    -- First, check qty entered.
    if ( checkQty(param.transactionType,
                  param.transactionQty,
                  errMsg) = false ) then
      return false;
    end if;

    -- check the project reference
    if ( pjm_project_locator.check_project_references(
                             param.environment.orgID,
                             param.locatorID,
                             'SPECIFIC',
                             'N',
                             job.projectID,
                             job.taskID) = false ) then
      errMsg := FND_MESSAGE.get;
      return false;
    end if;



    -- get the accounting period
    invttmtx.tdatechk(
        org_id           => param.environment.orgID,
        transaction_date => sysdate,
        period_id        => periodID,
        open_past_period => openPastPeriod);

    if (periodID = -1 or periodID = 0) then
      fnd_message.set_name(
        application => 'INV',
        name        => 'INV_NO_OPEN_PERIOD');
      errMsg := fnd_message.get;
      return false;
    end if;

    mtlRec.final_completion_flag := 'N';
    mtlRec.transaction_header_id := param.transactionHeaderID;
    mtlRec.transaction_interface_id := param.transactionIntID;

    if(wma_derive.getTxnMode(param.environment.orgID) = wip_constants.online OR
      param.isFromSerializedPage = 1 ) then
      mtlRec.transaction_mode := WIP_CONSTANTS.ONLINE;
    else
      mtlRec.transaction_mode := WIP_CONSTANTS.BACKGROUND;
    end if;
--    mtlRec.lock_flag := 'N';
    mtlRec.inventory_item_id := param.itemID;
    mtlRec.subinventory_code := param.subinventoryCode;
    mtlRec.transaction_date := sysdate;
    mtlRec.organization_id := param.environment.orgID;
    mtlRec.acct_period_id := periodID;
    mtlRec.last_update_date := sysdate;
    mtlRec.last_updated_by := param.environment.userID;
    mtlRec.creation_date := sysdate;
    mtlRec.created_by := param.environment.userID;
    mtlRec.transaction_source_id := param.jobID;
    mtlRec.transaction_source_type_id := 5;

    if ( param.isFromSerializedPage = 1 ) then
      mtlRec.source_code := wma_common.SERIALIZATION_SOURCE_CODE;
    else
      mtlRec.source_code := wma_common.SOURCE_CODE;
    end if;

    mtlRec.source_line_id := -1;
    mtlRec.source_header_id := -1;
    -- set up the transaction action id and trx quantity
    mtlRec.transaction_quantity := param.transactionQty;
    mtlRec.primary_quantity := param.transactionQty;
    mtlRec.negative_req_flag := 1;
    if ( param.transactionType = WIP_CONSTANTS.ISSCOMP_TYPE ) then
      mtlRec.transaction_action_id := WIP_CONSTANTS.ISSCOMP_ACTION;
      mtlRec.transaction_quantity := param.transactionQty * -1;
      mtlRec.primary_quantity := param.transactionQty * -1;
    elsif ( param.transactionType = WIP_CONSTANTS.RETCOMP_TYPE ) then
      mtlRec.transaction_action_id := WIP_CONSTANTS.RETCOMP_ACTION;
    elsif ( param.transactionType = WIP_CONSTANTS.ISSNEGC_TYPE ) then
      mtlRec.transaction_action_id := WIP_CONSTANTS.ISSNEGC_ACTION;
      mtlRec.negative_req_flag := -1;
    elsif ( param.transactionType = WIP_CONSTANTS.RETNEGC_TYPE ) then
      mtlRec.transaction_action_id := WIP_CONSTANTS.RETNEGC_ACTION;
      mtlRec.transaction_quantity := param.transactionQty * -1;
      mtlRec.primary_quantity := param.transactionQty * -1;
      mtlRec.negative_req_flag := -1;
    end if;
    mtlRec.transaction_type_id := param.transactionType;
    mtlRec.wip_entity_type := WIP_CONSTANTS.DISCRETE;

    mtlRec.locator_id := param.locatorID;
    mtlRec.operation_seq_num := param.opSeqNum;
    mtlRec.department_id := param.deptID;
--    mtlRec.row.item_trx_enabled_flag := item.mtlTxnsEnabled;
--    mtlRec.row.item_description := item.description;
--    mtlRec.row.item_location_control_code := item.locationControlCode;
--    mtlRec.row.item_restrict_subinv_code := item.restrictSubinvCode;
--    mtlRec.row.item_restrict_locators_code := item.restrictLocatorsCode;
--    mtlRec.row.item_revision_qty_control_code := item.revQtyControlCode;
    mtlRec.revision := param.revision;
--    mtlRec.item_primary_uom_code := item.primaryUOMCode;
    mtlRec.transaction_uom := param.transactionUOM;
--    mtlRec.row.item_inventory_asset_flag := item.invAssetFlag;
--    mtlRec.row.allowed_units_lookup_code := item.allowedUnitsLookupCode;
--    mtlRec.row.item_shelf_life_code := item.shelfLifeCode;
--    mtlRec.row.item_shelf_life_days := item.shelfLifeDays;
--    mtlRec.row.item_serial_control_code := item.serialNumberControlCode;
--    mtlRec.row.item_lot_control_code := item.lotControlCode;
--    mtlRec.row.posting_flag := 'Y';

    mtlRec.process_flag := wip_constants.mti_inventory;

    mtlRec.project_id := param.projectID;
    mtlRec.task_id := param.taskID;
    mtlRec.source_project_id := job.projectID;
    mtlRec.source_task_id := job.taskID;
    mtlRec.qa_collection_id := param.qualityID;
    mtlRec.wip_entity_type := param.wipEntityType;
    if (param.wipEntityType = WIP_CONSTANTS.EAM) then
      mtlRec.rebuild_item_id := param.itemID;
    else
      mtlRec.rebuild_item_id := NULL;
    end if;
    return true;
  End derive;


  /**
   * This function is used to insert the record encapsulated in mtlRec to
   * table MMTT and some furthur validation and processing.
   *
   * HISTORY:
   * 30-DEC-2004  spondalu  Bug 4093569: eAM-WMS Integration enhancements:
   *                        Insert rebuild_item_id into mti.
   */
  Function put(mtlRec MtlRecord, errMsg OUT NOCOPY VARCHAR2) return boolean IS
    l_retStatus VARCHAR2(1);
    l_logLevel NUMBER;
  Begin
    l_logLevel := fnd_log.g_current_runtime_level;

    INSERT INTO mtl_transactions_interface
               (wip_supply_type,
                final_completion_flag,
                transaction_header_id,
                transaction_interface_id,
                transaction_mode,
--                lock_flag,
                inventory_item_id,
                subinventory_code,
                primary_quantity,
                transaction_quantity,
                transaction_date,--10
                organization_id,
                acct_period_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                transaction_source_id,
                transaction_source_type_id,
                transaction_type_id,
                transaction_action_id,--20
                wip_entity_type,
                locator_id,
                operation_seq_num,
                department_id,
--                item_trx_enabled_flag,
--                item_description,
--                item_location_control_code,
--                item_restrict_subinv_code,
--                item_restrict_locators_code,
--                item_revision_qty_control_code, --30
                revision,
--                item_primary_uom_code,
                transaction_uom,
--                item_inventory_asset_flag,
--                allowed_units_lookup_code,
--                item_shelf_life_code,
--                item_shelf_life_days,
--                item_serial_control_code,
--                item_lot_control_code,
                negative_req_flag,
--                posting_flag,
                process_flag,
                project_id,
                task_id,
                source_project_id,
                source_task_id,
                qa_collection_id,
                source_code,
                source_line_id,
                source_header_id,
                rebuild_item_id)
        VALUES
               (wip_constants.push, --always a push item
                mtlRec.final_completion_flag,
                mtlRec.transaction_header_id,
                mtlRec.transaction_interface_id,
                mtlRec.transaction_mode,
--                mtlRec.lock_flag,
                mtlRec.inventory_item_id,
                mtlRec.subinventory_code,
                mtlRec.primary_quantity,
                mtlRec.transaction_quantity,
                mtlRec.transaction_date,--10
                mtlRec.organization_id,
                mtlRec.acct_period_id,
                mtlRec.last_update_date,
                mtlRec.last_updated_by,
                mtlRec.creation_date,
                mtlRec.created_by,
                mtlRec.transaction_source_id,
                mtlRec.transaction_source_type_id,
                mtlRec.transaction_type_id,
                mtlRec.transaction_action_id,--20
                mtlRec.wip_entity_type,
                mtlRec.locator_id,
                mtlRec.operation_seq_num,
                mtlRec.department_id,
--                mtlRec.item_trx_enabled_flag,
--                mtlRec.item_description,
--                mtlRec.item_location_control_code,
--                mtlRec.item_restrict_subinv_code,
--                mtlRec.item_restrict_locators_code,
--                mtlRec.item_revision_qty_control_code,
                mtlRec.revision,
--                mtlRec.item_primary_uom_code,
                mtlRec.transaction_uom,
--                mtlRec.item_inventory_asset_flag,
--                mtlRec.allowed_units_lookup_code,
--                mtlRec.item_shelf_life_code,
--                mtlRec.item_shelf_life_days,
--                mtlRec.item_serial_control_code,
--                mtlRec.item_lot_control_code,
                mtlRec.negative_req_flag,
--                mtlRec.posting_flag,
                mtlRec.process_flag,
                mtlRec.project_id,
                mtlRec.task_id,
                mtlRec.source_project_id,
                mtlRec.source_task_id,
                mtlRec.qa_collection_id,
                mtlRec.source_code,
                mtlRec.source_line_id,
                mtlRec.source_header_id,
                mtlRec.rebuild_item_id);

    wip_mtlTempProc_priv.validateInterfaceTxns(p_txnHdrID     => mtlRec.transaction_header_id,
                                               p_initMsgList  => fnd_api.g_true,
                                               x_returnStatus => l_retStatus);

    if(l_retStatus <> fnd_api.g_ret_sts_success) then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('put: error from validateInterfaceTxns', l_retStatus);
      end if;
      wip_utilities.get_message_stack(p_msg => errMsg);
      return false;
    end if;

    return true;

    EXCEPTION
    when others then
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_material.derive');
      fnd_message.set_token ('ERROR',  SQLERRM);
      errMsg := fnd_message.get;
      return false;
  End put;

  /**
   * This is a private function used by this pacakge only. It checks the qty entered
   * for material txn to make sure the qty > 0.
   */
  Function checkQty(txnType    NUMBER,
                    txnQty     NUMBER,
                    errMessage OUT NOCOPY VARCHAR2) RETURN boolean IS
  Begin
    if ( txnQty <= 0 ) then
       fnd_message.set_name('INV', 'INV_GREATER_THAN_ZERO');
       errMessage := fnd_message.get;
       return false;
    end if;

    return true;
  End checkQty;

  procedure validateIssueProject(p_orgID       in  number,
                                 p_wipEntityID in  number,
                                 p_locatorID   in  number,
                                 p_allowCrossIssue in number,
                                 x_projectID   out nocopy number,
                                 x_taskID      out nocopy number,
                                 x_projectNum  out nocopy varchar2,
                                 x_taskNum     out nocopy varchar2,
                                 x_returnStatus out nocopy varchar2,
                                 x_returnMsg   out nocopy varchar2) is
    l_jobProjectID number;
    l_jobTaskID number;
    l_locProjectID number;
    l_locTaskID number;
    l_num number;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    x_projectID := null;
    x_taskID := null;
    x_projectNum := null;
    x_taskNum := null;
    x_returnMsg := null;

 /* Bug 5111027 -  The following SQL will raise a
    NO DATA FOUND exception for PJM organization with no locator
    control at org/subinventory/item level. Added EXCEPTION
    block to handle it.*/
    BEGIN
      select project_id, task_id
        into l_locProjectID, l_locTaskID
        from mtl_item_locations_kfv
       where organization_id = p_orgID
         and inventory_location_id = p_locatorID;
    EXCEPTION
      when NO_DATA_FOUND THEN
        RETURN;
    END;


    -- no project/task reference on the locator
    if ( l_locProjectID is null and l_locTaskID is null ) then
      return;
    end if;

    x_projectID := l_locProjectID;
    x_taskID := l_locTaskID;
    x_projectNum := pjm_project.all_proj_idtonum(l_locProjectID);
    x_taskNum := pjm_project.all_task_idtonum(l_locTaskID);

    select project_id, task_id
      into l_jobProjectID, l_jobTaskID
      from wip_discrete_jobs
     where organization_id = p_orgID
       and wip_entity_id = p_wipEntityID;

    -- you can't issue project controlled item to non project controlled job
    if ( l_jobProjectID is null ) then
      x_returnStatus := fnd_api.g_ret_sts_error;
      x_projectID := null;
      x_taskID := null;
      x_projectNum := null;
      x_taskNum := null;
      fnd_message.set_name('WIP', 'JOB_NOT_PROJ_CNTL');
      x_returnMsg := fnd_message.get;
      return;
    end if;


    -- project/task are the same with job project/task
    if ( (l_locProjectID = l_jobProjectID) and (l_locTaskID = l_jobTaskID) ) then
      return;
    end if;

    -- project is the same and all cross project issue
    if ( (l_locProjectID = l_jobProjectID) and (p_allowCrossIssue = 1) ) then
      return;
    end if;


    -- diff project with the same cost group and planning group when
    -- allow cross issue
    if ( l_locProjectID <> l_jobProjectID and p_allowCrossIssue = 1 ) then
      select count(*)
        into l_num
        from pjm_project_parameters pp,
             pjm_project_parameters jpp
       where pp.organization_id = p_orgID
         and pp.project_id = l_locProjectID
         and jpp.organization_id = p_orgID
         and jpp.project_id = l_jobProjectID
         and pp.costing_group_id = jpp.costing_group_id
         and pp.planning_group = jpp.planning_group;
      if ( l_num > 0 ) then
        return;
      end if;
    end if;

    x_returnStatus := fnd_api.g_ret_sts_error;
    x_projectID := null;
    x_taskID := null;
    x_projectNum := null;
    x_taskNum := null;
    fnd_message.set_name('WIP', 'INVALID_SER_PROJECT_TASK');
    x_returnMsg := fnd_message.get;
  end validateIssueProject;


END wma_material;

/
