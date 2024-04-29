--------------------------------------------------------
--  DDL for Package Body WMA_COMPLETION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_COMPLETION" AS
/* $Header: wmapcmpb.pls 120.7.12010000.2 2009/12/15 18:20:03 pding ship $ */

  /**
   * This procedure is the entry point into the Completion and Return
   * Processing code for background processing.
   * Parameters:
   *   parameters  CmpParams contains values from the mobile form.
   *   status      Indicates success (0), failure (-1).
   *   errMessage  The error or warning message, if any.
   */
  PROCEDURE process(parameters IN  CmpParams,
                    processInv IN  VARCHAR2,
                    txnMode    IN  NUMBER,
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2) IS
    error VARCHAR2(2000);                 -- error message
    errCode VARCHAR2(1);
    cmpRecord CmpTxnRec;                 -- record to populate and insert
    primaryCostMethod NUMBER;
    msgCount NUMBER;
    errNum NUMBER;
    errMsg VARCHAR2(241);
    retValue NUMBER;
    returnStatus VARCHAR2(1);
    labelStatus VARCHAR2(1);
    dummy VARCHAR2(1);
    l_msg_stack VARCHAR2(2000);
    l_serialNum VARCHAR2(30);
    l_paramTbl wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_txnMode NUMBER;
    l_overCplRec wip_cplProc_priv.completion_rec_t;
  BEGIN
    savepoint wma_cmp_proc10;

    if (l_logLevel <= wip_constants.trace_logging) then
      --logging not fully supported in this package.
      l_paramTbl(1).paramName := 'not printing params';
      l_paramTbl(1).paramValue := ' ';
      --just skip
      wip_logger.entryPoint(p_procName => 'wma_completion.process',
                          p_params => l_paramTbl,
                          x_returnStatus => errCode);
    end if;

    status := 0;
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('enter wmapcmpb.process. int id is ' || parameters.transactionIntID, errCode);
    end if;

    --if the caller has chosen to override the wip parameter, use that value, otherwise use the
    --value in wip_parameters
    l_txnMode := nvl(txnMode, wma_derive.getTxnMode(parameters.environment.orgID));

    -- derive and validate all necessary fields for insertion
    if (derive(cmpRecord, l_overCplRec, parameters, l_txnMode, error) = FALSE) then
      -- process error
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', error);
      fnd_msg_pub.add;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('error from derive', errCode);
      end if;
      raise fnd_api.g_exc_unexpected_error;
    end if;
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('new tmp id is ' || cmpRecord.transaction_interface_id, errCode);
    end if;

    -- insert into the interface table for background processing
    if (put(cmpRecord, errMessage) = FALSE) then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('error from put', errCode);
      end if;
      raise fnd_api.g_exc_unexpected_error;
    end if;

    select primary_cost_method
      into primaryCostMethod
      from mtl_parameters
      where organization_id = parameters.environment.orgID;

    --insert a row into cst_comp_snap_temp
    /* Fix for bug 4252359. Do this only for non-LPN completions. WMS will
      take care of LPN completions through bug 4059728*/
    if(primaryCostMethod in (wip_constants.cost_avg,
                             wip_constants.cost_fifo,
                             wip_constants.cost_lifo)
        AND parameters.lpnID  IS NULL) then
      retValue := CSTACOSN.op_snapshot(i_txn_temp_id => cmpRecord.transaction_interface_id,
                                       err_num => errNum,
                                       err_code => errMessage,
                                       err_msg => errMessage);
      if(retValue <> 1) then
        fnd_message.set_name(application => 'CST',
                             name        => 'CST_SNAPSHOT_FAILED');
        fnd_msg_pub.add;
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('error from cst', errMessage);
        end if;
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    wip_utilities.print_label(p_txn_id => cmpRecord.transaction_header_id,
                              p_table_type => 2, --MMTT
                              p_ret_status => returnStatus,
                              p_msg_count  => msgCount,
                              p_msg_data   => error,
                              p_label_status => labelStatus,
                              p_business_flow_code => 26); -- discrete business flow code
    -- do not error out if label printing, only put warning message in log
    if(returnStatus <> fnd_api.g_ret_sts_success) then
      wip_utilities.get_message_stack(p_msg => l_msg_stack);
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(p_msg => 'An error has occurred with label printing.\n' ||
                                'The following error has occurred during ' ||
                                'printing: ' || l_msg_stack || '\n' ||
                                'Please check the Inventory log file for more ' ||
                                'information.',
                       x_returnStatus =>dummy);
      end if;
    end if;
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log(p_msg => 'Label printing returned with status ' ||
                              returnStatus,
                     x_returnStatus => dummy);
    end if;


    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wma_completion.process: tmpID => ' || cmpRecord.transaction_interface_id, returnStatus);
    end if;

    --if a return from the serialized page, re-populate the wip_entity_id,
    --intraoperation_seq_num, and intraoperation_step_type columns in MSN.
    --select it here to get the serial number before it leaves the temp table.
    if (parameters.isFromSerializedPage = wip_constants.yes and
        parameters.transactionType = wip_constants.retassy_type) then

      if(cmpRecord.item_lot_control_code = wip_constants.lot) then
        select fm_serial_number
          into l_serialNum
          from mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt
         where mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
           and mtlt.transaction_temp_id = cmpRecord.transaction_interface_id;
      else
        select fm_serial_number
          into l_serialNum
          from mtl_serial_numbers_temp
         where transaction_temp_id = cmpRecord.transaction_interface_id;
      end if;
    end if;

    -- call wip_cplProc_priv.processOverCpl() if overomplete transaction and
    -- transaction_mode is online.
    if (parameters.overcomplete = true AND
        l_txnMode = WIP_CONSTANTS.ONLINE) then
      wip_cplProc_priv.processOverCpl(p_cplRec       => l_overCplRec,
                                      x_returnStatus => returnStatus);

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('wma_completion.process: overcomplete retStatus => ' ||
                        returnStatus, dummy);
      end if;

      if(returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(fnd_api.to_boolean(processInv)) then
      wip_mtlTempProc_priv.processTemp(p_initMsgList => fnd_api.g_true,
                                       p_txnHdrID => cmpRecord.transaction_header_id,
                                       p_txnMode => l_txnMode,
                                       p_destroyQtyTrees => fnd_api.g_true,
                                       p_endDebug => fnd_api.g_false,
                                       x_returnStatus => returnStatus,
                                       x_errorMsg => errMessage);
    else
      wip_mtlTempProc_priv.processWIP(p_txnTmpID => cmpRecord.transaction_interface_id,
                                      p_processLpn => fnd_api.g_true,
                                      x_returnStatus => returnStatus,
                                      x_errorMsg => errMessage);
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wma_completion.process: retStatus => ' || returnStatus, dummy);
    end if;
    if(returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    --update to MSN must take place after inventory processing as they always clear the
    --group mark id when processing a serial. Here we have to repopulate the group_mark_id,
    --wip_entity_id, op_seq, and intra_op columns.
    if (parameters.isFromSerializedPage = wip_constants.yes and
        parameters.transactionType = wip_constants.retassy_type) then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('wma_completion.process: about to update serial', dummy);
      end if;
      if(cmpRecord.operation_seq_num = -1) then
        wip_utilities.update_serial(p_serial_number => l_serialNum,
                                    p_inventory_item_id => parameters.itemID,
                                    p_organization_id => parameters.environment.orgID,
                                    p_wip_entity_id => parameters.wipEntityID,
                                    p_operation_seq_num => null,
                                    p_intraoperation_step_type => null,
                                    x_return_status => returnStatus);
      else
        wip_utilities.update_serial(p_serial_number => l_serialNum,
                                    p_inventory_item_id => parameters.itemID,
                                    p_organization_id => parameters.environment.orgID,
                                    p_wip_entity_id => parameters.wipEntityID,
                                    p_operation_seq_num => cmpRecord.operation_seq_num,
                                    p_intraoperation_step_type => wip_constants.toMove,
                                    x_return_status => returnStatus);
      end if;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('wma_completion.process: serialization op retStatus => ' || returnStatus, dummy);
      end if;
      if(returnStatus <> fnd_api.g_ret_sts_success) then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('wma_completion.process: retStatus of serial update failure ' || returnStatus, dummy);
        end if;
        wip_utilities.get_message_stack(p_msg => errMessage);
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_completion.process',
                           p_procReturnStatus => status,
                           p_msg => 'success',
                           x_returnStatus => dummy);
    end if;
    wip_logger.cleanUp(dummy);
  EXCEPTION
    when fnd_api.g_exc_unexpected_error then
      status := -1;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_completion.process',
                             p_procReturnStatus => status,
                             p_msg => 'failure',
                             x_returnStatus => dummy);
        wip_logger.cleanUp(dummy);
      end if;
      rollback to wma_cmp_proc10;
    when others then
      status := -1;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_completion.process',
                             p_procReturnStatus => status,
                             p_msg => 'exception',
                             x_returnStatus => dummy);
        wip_logger.cleanUp(dummy);
      end if;
      rollback to wma_cmp_proc10;
      returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_completion.process');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
  END process;

  FUNCTION putIntoMMTT(lpnCmpRecord IN LpnCmpTxnRec,
                       txnTmpID   OUT NOCOPY NUMBER,
                       errMessage OUT NOCOPY VARCHAR2) return boolean
  is
  begin
   insert into mtl_material_transactions_temp
           (transaction_header_id,
            transaction_temp_id,
            completion_transaction_id,
            transaction_mode,
            created_by,
            creation_date,
            last_update_date,
            last_updated_by,
            inventory_item_id,
            transaction_quantity,
            transaction_uom,
            primary_quantity,
            transaction_date,
            organization_id,
            acct_period_id,
            transaction_action_id,
            transaction_source_id,
            transaction_source_type_id,
            transaction_type_id,
            wip_entity_type,
            revision,
            operation_seq_num,
            process_flag,
            posting_flag,
            final_completion_flag,
            qa_collection_id,
            kanban_card_id,
            lpn_id)
    values (mtl_material_transactions_s.nextval,
            mtl_material_transactions_s.nextval,
            lpnCmpRecord.row.completion_transaction_id,
            lpnCmpRecord.row.transaction_mode,
            lpnCmpRecord.row.created_by,
            lpnCmpRecord.row.creation_date,
            lpnCmpRecord.row.last_update_date,
            lpnCmpRecord.row.last_updated_by,
            lpnCmpRecord.row.inventory_item_id,
            lpnCmpRecord.row.transaction_quantity,
            lpnCmpRecord.row.transaction_uom,
            lpnCmpRecord.row.primary_quantity,
            lpnCmpRecord.row.transaction_date,
            lpnCmpRecord.row.organization_id,
            lpnCmpRecord.row.acct_period_id,
            lpnCmpRecord.row.transaction_action_id,
            lpnCmpRecord.row.transaction_source_id,
            lpnCmpRecord.row.transaction_source_type_id,
            lpnCmpRecord.row.transaction_type_id,
            lpnCmpRecord.row.wip_entity_type,
            lpnCmpRecord.row.bom_revision,
            lpnCmpRecord.row.operation_seq_num,
            'Y',
            'Y',
            lpnCmpRecord.row.final_completion_flag,
            lpnCmpRecord.row.qa_collection_id,
            lpnCmpRecord.row.kanban_card_id,
            lpnCmpRecord.row.lpn_id) returning transaction_temp_id into txnTmpID;
    return true;
  exception when others then
    errMessage := SQLERRM;
    return false;
  end putIntoMMTT;

  PROCEDURE process(parameters IN LpnCmpParams,
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2,
                    cmpl_txnTmpId OUT NOCOPY NUMBER) IS -- Added for Bug 6013398.
    error VARCHAR2(2000);                 -- error message
    lpnCmpRecord LpnCmpTxnRec; -- record to populate and insert
    l_txnHdrID NUMBER;
    l_txnTmpID NUMBER;
    l_retStatus VARCHAR2(1);
    /* new variables for bug 4253002 */
    msgCount NUMBER;
    labelStatus VARCHAR2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_msg_stack VARCHAR2(2000);
    dummy VARCHAR2(1);
  BEGIN
    savepoint wmapcmpb_proc1000;

    status := 0;

    -- derive and validate all necessary fields for insertion
    if (derive(lpnCmpRecord, parameters, error) = FALSE) then
      -- process error
      rollback to wmapcmpb_proc1000;
      status := -1;
      errMessage := error;
      return;
    end if;

    --put a dummy record into MMTT...
    if(putIntoMMTT(lpnCmpRecord, l_txnTmpID, error) = FALSE) then
      rollback to wmapcmpb_proc1000;
      status := -1;
      errMessage := error;
      return;
    end if;

    /* Start: Bug 6013398.
    Start of fix for bug 4253002
    select transaction_header_id
    into   l_txnHdrID
    from   mtl_material_transactions_temp
    where  transaction_temp_id = l_txnTmpID;

    wip_utilities.print_label(p_txn_id     => l_txnTmpID,
                              p_table_type => 2, --MMTT
                              p_ret_status => l_retStatus,
                              p_msg_count  => msgCount,
                              p_msg_data   => error,
                              p_label_status => labelStatus,
                              p_business_flow_code => 26); -- discrete business flow code
    -- do not error out if label printing, only put warning message in log
    if(l_retStatus <> fnd_api.g_ret_sts_success) then
      wip_utilities.get_message_stack(p_msg => l_msg_stack);
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(p_msg => 'An error has occurred with label printing.\n' ||
                                'The following error has occurred during ' ||
                                'printing: ' || l_msg_stack || '\n' ||
                                'Please check the Inventory log file for more ' ||
                                'information.',
                       x_returnStatus =>dummy);
      end if;
    end if;
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log(p_msg => 'Label printing returned with status ' ||
                              l_retStatus,
                     x_returnStatus => dummy);
    end if;
    Assign value to out parameter and remove the label printing code.
    Label printing code has been moved to calling procedure wipopsrb.lpnCompleteJob
    End of fix for bug 4253002 */
    cmpl_txnTmpID :=   l_txnTmpID;
	--End: Bug 6013398.
    --use it to do WIP processing...
    wip_mtlTempProc_priv.processWIP(p_txnTmpID => l_txnTmpID,
                                    p_processLpn => fnd_api.g_true,
                                    x_returnStatus => l_retStatus,
                                    x_errorMsg => error);
    if(l_retStatus <> fnd_api.g_ret_sts_success) then
      rollback to wmapcmpb_proc1000;
      status := -1;
      errMessage := error;
      return;
    end if;

    /* commented out for bug 6354507.
				--and delete it
    delete mtl_material_transactions_temp
     where transaction_temp_id = l_txnTmpID; */

    -- insert into the wip table
    if (put(lpnCmpRecord, error) = FALSE) then
      -- process error
      status := -1;
      errMessage := error;
      return;
    end if;

  EXCEPTION
    when others then
      rollback to wmapcmpb_proc1000;
      status := -1;
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_completion.process');
      fnd_message.set_token ('ERROR', SQLERRM);
      errMessage := fnd_message.get;

  END process;

  /**
   * This function derives and validates the values necessary for executing a
   * completion or return transaction. Given the form parameters, it populates
   * cmpRecord preparing it to be inserted into the interface table.
   * Parameters:
   *   cmpRecord  record to be populated. The minimum number of fields to
   *              execute the transaction successfully are populated
   *   overCplRec record to be used by wip_cplProc_priv.processOverCpl()
   *   parameters completion or return mobile form parameters
   *   errMessage populated if an error occurrs
   * Return:
   *   boolean    flag indicating the successful derivation of necessary values
   * HISTORY:
   * 02-MAR-2006  spondalu  ER 4163405: Derived demandSourceHeaderID and demandSourceLineID
   *                        from parameters and populated cmpRecord with the same. Also,
   *                        restricted call to checkQuantity() to completion transactions only.
   *
   */
  Function derive(cmpRecord  IN OUT NOCOPY CmpTxnRec,
                  overCplRec IN OUT NOCOPY wip_cplProc_priv.completion_rec_t,
                  parameters IN            CmpParams,
                  txnMode    IN            NUMBER,
                  errMessage IN OUT NOCOPY VARCHAR2)
  return boolean IS
    item wma_common.Item;
    job wma_common.Job;
    lastOpSeq NUMBER;
    periodID NUMBER;
    availableQty NUMBER;
    openPastPeriod BOOLEAN := false;
    primaryCostMethod NUMBER;
    l_dummy VARCHAR2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  BEGIN
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('enter wmapcmpb.derive', l_dummy);
       end if;

    -- get the job info
    job := wma_derive.getJob(parameters.wipEntityID);
    if (job.wipEntityID is null) then
      fnd_message.set_name ('WIP', 'WIP_JOB_DOES_NOT_EXIST');
      fnd_message.set_token('INTERFACE', 'wma_completion.derive', TRUE);
      errMessage := fnd_message.get;
      return false;
    end if;

    select primary_cost_method
      into primaryCostMethod
      from mtl_parameters
     where organization_id = parameters.environment.orgID;


    --may have to populate the txn temp id for costing.
    --the conditional population is probably not necessary, need
    --to check with inv
    if(parameters.transactionIntID is null or parameters.transactionIntID <= 0) then
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('wmapcmpb.derive: selecting new int id', l_dummy);
       end if;
       select mtl_material_transactions_s.nextval
         into cmpRecord.transaction_interface_id
         from dual;
    else
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('wmapcmpb.derive: using old int id', l_dummy);
       end if;
      cmpRecord.transaction_interface_id := parameters.transactionIntID;
    end if;

    /* ER 4163405: Restricting quantity check to completion only */
    if (parameters.transactionType =  WIP_CONSTANTS.CPLASSY_TYPE) then
    -- validate transaction quantity.
    if (checkQuantity(parameters, job, errMessage) = false) then
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('wmapcmpb.derive: chkQty returns false', l_dummy);
       end if;
      return false;
    end if;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wmapcmpb.derive: about to call pjm', l_dummy);
      wip_logger.log('org:' || parameters.environment.orgID, l_dummy);
      wip_logger.log('loc:' || parameters.locatorID, l_dummy);
      wip_logger.log('prj:' || job.projectID, l_dummy);
      wip_logger.log('tsk:' || job.taskID, l_dummy);
    end if;

    -- check the project reference
    if (pjm_project_locator.check_project_references(
          parameters.environment.orgID,
          parameters.locatorID,
          'SPECIFIC',
          'N',
          job.projectID,
          job.taskID) = false) then
      errMessage := fnd_message.get;
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('wmapcmpb.derive: pjm_project_locator returns false', l_dummy);
       end if;
      return false;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wmapcmpb.derive: about to call getItem', l_dummy);
    end if;

    -- get the item info
    item := wma_derive.getItem(parameters.itemID,
                               parameters.environment.orgID,
                               parameters.locatorID);
    if (item.invItemID is null) then
      fnd_message.set_name ('WIP', 'WIP_ITEM_DOES_NOT_EXIST');
      errMessage := fnd_message.get;
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('wmapcmpb.derive: wma_derive.getItem returns false', l_dummy);
       end if;
      return false;
    end if;

    -- get the item revision
    cmpRecord.revision := null;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wmapcmpb.derive: about to call getRev', l_dummy);
    end if;

    if (item.revQtyControlCode = WIP_CONSTANTS.REVISION_CONTROLLED) then
      if(NOT wma_completion.getRevision(
                           wipEntityID => parameters.wipEntityID,
                           orgID       => parameters.environment.orgID,
                           itemID      => parameters.itemID,
                           revision    => cmpRecord.revision)) then
        errMessage := substr(fnd_message.get,1,241);
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('wmapcmpb.derive: wma_completion.getRevision returns false', l_dummy);
       end if;
        return false;
      end if; -- getRevision
    end if; -- revQtyControlCode = WIP_CONSTANTS.REVISION_CONTROLLED

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wmapcmpb.derive: about to call tdatechk', l_dummy);
    end if;

    -- get the accounting period
    invttmtx.tdatechk(
      org_id           => parameters.environment.orgID,
      transaction_date => sysdate,
      period_id        => periodID,
      open_past_period => openPastPeriod);

    if (periodID = -1 or periodID = 0) then
      fnd_message.set_name(
        application => 'INV',
        name        => 'INV_NO_OPEN_PERIOD');
      errMessage := fnd_message.get;
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('wmapcmpb.derive: tdatechk returns false', l_dummy);
       end if;
      return false;
    end if;


    -- get the last operation sequence
    lastOpSeq := getLastOpSeq (job);


    -- set the quantity and the action id depending on the transaction type
    if (parameters.transactionType = WIP_CONSTANTS.CPLASSY_TYPE) then
      cmpRecord.transaction_action_id := WIP_CONSTANTS.CPLASSY_ACTION;
      cmpRecord.transaction_quantity := parameters.transactionQty;
    else    -- return transaction
      cmpRecord.transaction_action_id := WIP_CONSTANTS.RETASSY_ACTION;
      cmpRecord.transaction_quantity := parameters.transactionQty * -1;
    end if;
    -- primary quantity is always equal to transaction quantity
    cmpRecord.primary_quantity := cmpRecord.transaction_quantity;

    -- derive and set the rest of the mandatory fields in cmpRecord
    cmpRecord.transaction_type_id := parameters.transactionType;
    cmpRecord.transaction_source_id := parameters.wipEntityID;
    cmpRecord.transaction_source_type_id := INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_WIP;
    cmpRecord.transaction_header_id := parameters.transactionHeaderID;
    cmpRecord.completion_transaction_id := parameters.cmpTransactionID;
    cmpRecord.created_by := parameters.environment.userID;
    cmpRecord.creation_date := sysdate;
    if ( parameters.isFromSerializedPage = 1 ) then
      cmpRecord.source_code := wma_common.SERIALIZATION_SOURCE_CODE;
    else
      cmpRecord.source_code :=  wma_common.SOURCE_CODE;
    end if;
    cmpRecord.source_header_id := -1;
    cmpRecord.source_line_id := -1;
--    cmpRecord.lock_flag := 'N';
    cmpRecord.inventory_item_id := parameters.itemID;
    cmpRecord.subinventory_code := parameters.subinv;
    cmpRecord.transaction_uom := parameters.transactionUOM;
    cmpRecord.transaction_date := sysdate;
    cmpRecord.organization_id := parameters.environment.orgID;
    cmpRecord.acct_period_id := periodID;
    cmpRecord.last_update_date := sysdate;
    cmpRecord.last_updated_by := parameters.environment.userID;
    cmpRecord.wip_entity_type := WIP_CONSTANTS.DISCRETE;
    cmpRecord.locator_id := parameters.locatorID;

    if (parameters.demandSourceHeaderID = 0) then
      cmpRecord.demand_source_header_id := NULL;
    else
      cmpRecord.demand_source_header_id := parameters.demandSourceHeaderID; /* ER 4163405 */
    end if;

    if (parameters.demandSourceLineID = 0) then
      cmpRecord.demand_source_line_id := NULL;
    else
      cmpRecord.demand_source_line_id := parameters.demandSourceLineID;
    end if;

    --do not use online processing mode as it will disable over-cpl
    --processing in the processor (due to desktop forms logic)
    if(txnMode = wip_constants.online) then
      cmpRecord.transaction_mode := wip_constants.online;
    else
      cmpRecord.transaction_mode := txnMode;
    end if;

    cmpRecord.operation_seq_num := lastOpSeq;

    cmpRecord.process_flag := wip_constants.mti_inventory;


--    cmpRecord.posting_flag := 'Y';
    cmpRecord.item_lot_control_code := item.lotControlCode;
--    cmpRecord.item_serial_control_code := item.serialNumberControlCode;
--    cmpRecord.item_segments := item.itemName;
--    cmpRecord.locator_segments := parameters.locatorName;
--    cmpRecord.item_inventory_asset_flag := item.invAssetFlag;
--    cmpRecord.item_description := item.description;
--    cmpRecord.next_lot_number := item.startAutoLotNumber;
--    cmpRecord.lot_alpha_prefix := item.autoLotAlphaPrefix;
--    cmpRecord.item_primary_uom_code := item.primaryUOMCode;
--    cmpRecord.item_revision_qty_control_code := item.revQtyControlCode;
--    cmpRecord.item_restrict_locators_code := item.restrictLocatorsCode;
--    cmpRecord.item_location_control_code := item.locationControlCode;
--    cmpRecord.item_shelf_life_code := item.shelfLifeCode;
--    cmpRecord.item_shelf_life_days := item.shelfLifeDays;
--    cmpRecord.item_restrict_subinv_code := item.restrictSubinvCode;
--    cmpRecord.next_serial_number := item.startAutoSerialNumber;
--    cmpRecord.serial_alpha_prefix := item.autoSerialAlfaPrefix;
--    cmpRecord.allowed_units_lookup_code := item.allowedUnitsLookupCode;

     /* Fix for bug 4588479; fp 4496088:
        Setting final_completion_flag to NULL as this
        will be determined by INV TM before inserting into MMTT. Reverted
        fix for bug 4115120 */
    cmpRecord.final_completion_flag := null;      -- setting this to null for now
    cmpRecord.source_project_id := job.projectID;  --fixed by bug 9086130
    cmpRecord.source_task_id := job.taskID;        --fixed by bug 9086130

    cmpRecord.project_id := item.projectID;
    cmpRecord.task_id := item.taskID;
    cmpRecord.qa_collection_id := parameters.qualityID;
    cmpRecord.kanban_card_id := parameters.kanbanCardID;
    cmpRecord.lpn_id := parameters.lpnID;
    cmpRecord.move_transaction_id := parameters.movTransactionID;

    if (parameters.overcomplete = true) then
      -- generate an overcompletion txn id only if the assembly has a routing
      availableQty := getAvailableQty (job);
      cmpRecord.overcompletion_transaction_qty :=
        parameters.transactionQty - availableQty;
      cmpRecord.overcompletion_primary_qty :=
        parameters.transactionQty - availableQty;

      -- set the value of the record wip_cplProc_priv.completion_rec_t
      overCplRec.wipEntityType  := WIP_CONSTANTS.DISCRETE;
      overCplRec.wipEntityID    := cmpRecord.transaction_source_id;
      overCplRec.orgID          := cmpRecord.organization_id;
      overCplRec.repLineID      := null; -- only used for repetitive
      overCplRec.itemID         := cmpRecord.inventory_item_id;
      overCplRec.txnActionID    := cmpRecord.transaction_action_id;
      overCplRec.priQty         := cmpRecord.transaction_quantity;
      overCplRec.txnQty         := cmpRecord.transaction_quantity;
      overCplRec.txnDate        := cmpRecord.transaction_date;
      overCplRec.cplTxnID       := cmpRecord.completion_transaction_id;
      overCplRec.movTxnID       := cmpRecord.move_transaction_id;
      overCplRec.kanbanCardID   := cmpRecord.kanban_card_id;
      overCplRec.qaCollectionID := cmpRecord.qa_collection_id;
      overCplRec.lastOpSeq      := cmpRecord.operation_seq_num;
      overCplRec.revision       := cmpRecord.revision;
      overCplRec.mtlAlcTmpID    := null; -- only used for repetitive
      overCplRec.txnHdrID       := cmpRecord.transaction_header_id;
      overCplRec.txnStatus      := null;
      overCplRec.overCplPriQty  := cmpRecord.overcompletion_primary_qty;
      overCplRec.lastUpdBy      := cmpRecord.last_updated_by;
      overCplRec.createdBy      := cmpRecord.created_by;
      overCplRec.lpnID          := null; -- only used for LPN
      overCplRec.txnMode        := cmpRecord.transaction_mode;
      -- generate overcompletion_transaction_id because move processor need it
      -- to determine whether we should update quantity at Queue of the first
      -- operation or not.
      select wip_transactions_s.nextval
        into overCplRec.overCplTxnID
        from dual;
    end if;  -- overcompletion

    return true;

  EXCEPTION
    when others then
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_completion.derive');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
      return false;
  END derive;


  Function derive(LpnCmpRecord IN OUT NOCOPY LpnCmpTxnRec,
                  parameters IN LpnCmpParams,
                  errMessage IN OUT NOCOPY VARCHAR2)
  return boolean IS
    item wma_common.Item;
    job wma_common.Job;
    lastOpSeq NUMBER;
    periodID NUMBER;
    availableQty NUMBER;
    openPastPeriod BOOLEAN := false;
  BEGIN

    -- get the job info
    job := wma_derive.getJob(parameters.wipEntityID);
    if (job.wipEntityID is null) then
      fnd_message.set_name ('WIP', 'WIP_JOB_DOES_NOT_EXIST');
      fnd_message.set_token('INTERFACE', 'wma_completion.derive', TRUE);
      errMessage := fnd_message.get;
      return false;
    end if;

    -- take the quantity check off. The quantity has been checked before calling
    -- the on line processor. If we call it again here, since the quantity completed
    -- is already updated, it will error out. For P1 2324566.
    -- availableQty := getAvailableQty (job);
    -- if (checkQuantity(parameters.environment.orgID,
    --                   parameters.wipEntityID,
    --                   parameters.overcomplete,
    --                   parameters.transactionTypeID,
    --                   parameters.transactionQty,
    --                   availableQty,
    --                   job.quantityCompleted,
    --                   errMessage) = false) then
    --   return false;
    -- end if;

    -- check the project reference
    if (pjm_project_locator.check_project_references(
          parameters.environment.orgID,
          parameters.locatorID,
          'SPECIFIC',
          'N',
          job.projectID,
          job.taskID) = false) then
      errMessage := fnd_message.get;
      return false;
    end if;

    -- get the item info
    item := wma_derive.getItem(parameters.itemID,
                               parameters.environment.orgID,
                               parameters.locatorID);
    if (item.invItemID is null) then
      fnd_message.set_name ('WIP', 'WIP_ITEM_DOES_NOT_EXIST');
      errMessage := fnd_message.get;
      return false;
    end if;
    -- get the item revision
    LpnCmpRecord.row.bom_revision := null;
    if (item.revQtyControlCode = WIP_CONSTANTS.REVISION_CONTROLLED) then
      if(NOT wma_completion.getRevision(
                           wipEntityID => parameters.wipEntityID,
                           orgID       => parameters.environment.orgID,
                           itemID      => parameters.itemID,
                           revision    => lpnCmpRecord.row.bom_revision)) then
        errMessage := substr(fnd_message.get, 1, 241);
        return false;
      end if; -- getRevision
    end if; -- revQtyControlCode = WIP_CONSTANTS.REVISION_CONTROLLED

    -- get the accounting period
    invttmtx.tdatechk(
      org_id           => parameters.environment.orgID,
      transaction_date => sysdate,
      period_id        => periodID,
      open_past_period => openPastPeriod);

    if (periodID = -1 or periodID = 0) then
      fnd_message.set_name(
        application => 'INV',
        name        => 'INV_NO_OPEN_PERIOD');
      errMessage := fnd_message.get;
      return false;
    end if;

    -- get the last operation sequence
    lastOpSeq := getLastOpSeq (job);

    -- set the quantity and the action id depending on the transaction type
    if (parameters.transactionTypeID = WIP_CONSTANTS.CPLASSY_TYPE) then
      lpnCmpRecord.row.transaction_action_id := WIP_CONSTANTS.CPLASSY_ACTION;
      lpnCmpRecord.row.transaction_quantity := parameters.transactionQty;
/*      if (parameters.overcomplete = true) then --never happens?
        -- generate an overcompletion txn id only if the assembly has a routing
        if (lastOpSeq <> -1) then
          lpnCmpRecord.row.overcompletion_transaction_id := wma_derive.getNextVal('wip_transactions_s');
        end if;
        availableQty := getAvailableQty (job);
        lpnCmpRecord.row.overcompletion_transaction_qty := parameters.transactionQty - availableQty;
        lpnCmpRecord.row.overcompletion_primary_qty := parameters.transactionQty - availableQty;
      end if;  -- overcompletion
*/
    else    -- return transaction
      lpnCmpRecord.row.transaction_action_id := WIP_CONSTANTS.RETASSY_ACTION;
      lpnCmpRecord.row.transaction_quantity := parameters.transactionQty * -1;
    end if;

    -- primary quantity is always equal to transaction quantity
    lpnCmpRecord.row.primary_quantity := lpnCmpRecord.row.transaction_quantity;

    -- derive and set the rest of the mandatory fields in lpnCmpRecord
    lpnCmpRecord.row.transaction_type_id := parameters.transactionTypeID;
    lpnCmpRecord.row.transaction_source_id := parameters.wipEntityID;
    lpnCmpRecord.row.transaction_source_type_id := 5;
    lpnCmpRecord.row.header_id := parameters.headerID;

    --do not use online as online will prevent over-completion processing
    lpnCmpRecord.row.transaction_mode := wip_constants.online;


    lpnCmpRecord.row.created_by := parameters.environment.userID;
    lpnCmpRecord.row.creation_date := sysdate;
    lpnCmpRecord.row.lock_flag := 'N';
    lpnCmpRecord.row.inventory_item_id := parameters.itemID;
    lpnCmpRecord.row.subinventory_code := parameters.subinv;
    lpnCmpRecord.row.transaction_uom := parameters.transactionUOM;
    lpnCmpRecord.row.transaction_date := sysdate;
    lpnCmpRecord.row.organization_id := parameters.environment.orgID;
    lpnCmpRecord.row.acct_period_id := periodID;
    lpnCmpRecord.row.last_update_date := sysdate;
    lpnCmpRecord.row.last_updated_by := parameters.environment.userID;
    lpnCmpRecord.row.wip_entity_id := parameters.wipEntityID;
    lpnCmpRecord.row.wip_entity_type := WIP_CONSTANTS.DISCRETE;
    lpnCmpRecord.row.locator_id := parameters.locatorID;
    lpnCmpRecord.row.operation_seq_num := lastOpSeq;
--    lpnCmpRecord.row.item_description := item.description;
    lpnCmpRecord.row.qa_collection_id := parameters.qualityID;
    lpnCmpRecord.row.kanban_card_id := parameters.kanbanCardID;
    lpnCmpRecord.row.lpn_id := parameters.lpnID;
    lpnCmpRecord.row.final_completion_flag := null;
--    lpnCmpRecord.row.job_project_id := job.projectID;--formerly source_project_id
--    lpnCmpRecord.row.job_task_id := job.taskID;--formerly source_task_id
    lpnCmpRecord.row.item_project_id := item.projectID; --formerly project_id
    lpnCmpRecord.row.item_task_id := item.taskID;
    lpnCmpRecord.row.end_item_unit_number := job.endItemUnitNumber;
    lpnCmpRecord.row.completion_transaction_id := parameters.completionTxnID;
    return true;

  EXCEPTION
    when others then
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_completion.derive');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
      return false;
  END derive;

  /**
   * checks the transaction quantity entered by the user.
   * The transaction quantity should not exceed the available quantity
   * If overcompleting, however, the transaction quantity should
   * be greater than the available quantity, nd should not exceed the
   * overcompletion tolerance. In the case of return, the transaction
   * should not exceed the completed quantity.
   * If the structures passed to this procedure are not available, use the
   * overloaded version.
   * Parameters:
   *   parameters completion or return mobile form parameters
   *   job        job to check transaction quantity against
   * Returns:
   *   boolean    flag indicating if validation is successful
   */
  FUNCTION checkQuantity (parameters IN CmpParams,
                          job IN wma_common.Job,
                          errMessage IN OUT NOCOPY VARCHAR2) return boolean
  IS
    availableQty NUMBER;
    status BOOLEAN;
  BEGIN
    availableQty := getAvailableQty (job);

    status := checkQuantity (parameters.environment.orgID,
                             parameters.wipEntityID,
                             parameters.overcomplete,
                             parameters.transactionType,
                             parameters.transactionQty,
                             availableQty,
                             job.quantityCompleted,
                             errMessage);
    return status;
  EXCEPTION
    when others then
      return false;
  END checkQuantity;


  /**
   * checks the transaction quantity entered by the user.
   * The transaction quantity should not exceed the available quantity
   * If overcompleting, however, the transaction quantity should
   * be greater than the available quantity, nd should not exceed the
   * overcompletion tolerance. In the case of return, the transaction
   * should not exceed the completed quantity.
   * Parameters:
   *   orgID           the organization job belongs to
   *   wipEntityID     the job ID used to check the overcompletion tolerance
   *   overcomplete    flag to indicate if user chose to overcomplete
   *   transactionType either WIP_CONSTANTS.CPLASSY_TYPE or RETASSY_TYPE
   *   transactionQty  the quantity to transact
   *   availableQty    the quantity availabe to the job
   *   completedQty    the job quantity completed
   * Returns:
   *   boolean    flag indicating if validation is successful
   * HISTORY:
   * 02-MAR-2006  spondalu  ER 4163405: Changed the logic in this function.
   *                        Transaction quantity was compared with available qty
   *                        only during completion. Generalized this for both
   *                        completion and return. Changed message to make it
   *                        relevant for both completions and returns.
   *
   */
  FUNCTION checkQuantity (orgID IN NUMBER,
                          wipEntityID IN NUMBER,
                          overcomplete IN BOOLEAN,
                          transactionType IN NUMBER,
                          transactionQty IN NUMBER,
                          availableQty IN NUMBER,
                          completedQty IN NUMBER,
                          errMessage IN OUT NOCOPY VARCHAR2) return boolean
  IS
    result NUMBER;
    ocQtyToCheck NUMBER;
    l_returnStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
    /* Fixed bug 3693148 */
    l_job_type NUMBER;
  BEGIN
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'not printing params';
      l_params(1).paramValue := ' ';
      wip_logger.entryPoint(p_procName => 'wma_completion.checkQuantity',
                            p_params => l_params,
                            x_returnStatus => l_returnStatus);
    end if;

    if (transactionQty <= 0) then
      fnd_message.set_name ('INV', 'INV_GREATER_THAN_ZERO');
      errMessage := fnd_message.get;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_completion.checkQuantity',
                             p_procReturnStatus => -1,
                             p_msg => errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
      return false;
    end if;
    if (overcomplete = true) then
      -- validate overcompletion quantity
      if (transactionQty <= availableQty) then
        fnd_message.set_name ('WIP', 'WIP_GREATER_THAN');
        fnd_message.set_token('ENTITY1', 'TRANSACTION QUANTITY-CAP', TRUE);
        fnd_message.set_token('ENTITY2', 'QTY AVAIL TO COMPLETE', TRUE);
        errMessage := fnd_message.get;
        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.exitPoint(p_procName => 'wma_completion.checkQuantity',
                               p_procReturnStatus => -1,
                               p_msg => errMessage,
                               x_returnStatus => l_returnStatus);
        end if;
        return false;
      end if;
      -- check overcompletion tolerance
      if (getLastOpSeq (wipEntityID, orgID) = -1) then
        ocQtyToCheck := transactionQty;
      else  -- the job has a routing
        ocQtyToCheck := transactionQty - availableQty;
      end if;
      wip_overcompletion.check_tolerance(
        p_organization_id => orgID,
        p_wip_entity_id => wipEntityID,
        p_primary_quantity => ocQtyToCheck,
        p_result => result);
      if (result = wip_constants.no) then    -- quantity exceeds tolerance
        fnd_message.set_name ('WIP', 'WIP_OC_TOLERANCE_FAIL');
        errMessage := fnd_message.get;
        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.exitPoint(p_procName => 'wma_completion.checkQuantity',
                               p_procReturnStatus => -1,
                               p_msg => errMessage,
                               x_returnStatus => l_returnStatus);
        end if;
        return false;
      end if;
    else       -- parameters.overcomplete = false
        -- validate completion quantity
     /* ER 4163405: Checking whether transactionQty is greater than availableQty was
        being made only for completion transaction. Removed the if-condition. Now,
        this will be checked for both completion and return. Changed message to be more
        suitable for both completion and return */
        if (transactionQty > availableQty) then
          fnd_message.set_name ('INV', 'INV_QTY_LESS_OR_EQUAL');
          errMessage := fnd_message.get;
          if (l_logLevel <= wip_constants.trace_logging) then
            wip_logger.exitPoint(p_procName => 'wma_completion.checkQuantity',
                                 p_procReturnStatus => -1,
                                 p_msg => errMessage,
                                 x_returnStatus => l_returnStatus);
          end if;
          return false;
        end if;

        select job_type
          into l_job_type
          from wip_discrete_jobs
         where wip_entity_id = wipEntityID
           and organization_id = orgID;

     /* ER 4163405: Re-add the condition here for return transactions only */
        if (transactionType = wip_constants.retassy_type) then

        -- validate return quantity
        /* Fixed bug 3693148. We should allow overreturn for non-standard job*/
        if (l_job_type = WIP_CONSTANTS.STANDARD AND
            transactionQty > completedQty) then
          fnd_message.set_name ('WIP', 'WIP_LESS_OR_EQUAL');
          fnd_message.set_token('ENTITY1', 'TOTAL TXN QTY-CAP', TRUE);
          fnd_message.set_token('ENTITY2', 'JOB COMPLETE QUANTITY', TRUE);
          errMessage := fnd_message.get;
          if (l_logLevel <= wip_constants.trace_logging) then
            wip_logger.exitPoint(p_procName => 'wma_completion.checkQuantity',
                                 p_procReturnStatus => -1,
                                 p_msg => errMessage,
                                 x_returnStatus => l_returnStatus);
          end if;
          return false;
        end if;
      end if;
    end if;    -- quantity validation
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_completion.checkQuantity',
                           p_procReturnStatus => 0,
                           p_msg => 'success',
                           x_returnStatus => l_returnStatus);
    end if;
    return true;
  EXCEPTION
    when others then
      return false;
  END checkQuantity;


  /**
   * Check whether exceeds overcompletion tolerance or not.
   */
  procedure checkOverCpl(p_orgID        in number,
                         p_wipEntityID  in number,
                         p_overCplQty   in number,
                         x_returnStatus out nocopy varchar2,
                         x_errMessage   out nocopy varchar2) is
    result number;
    l_returnStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'not printing params';
      l_params(1).paramValue := ' ';
      wip_logger.entryPoint(p_procName => 'wma_completion.checkOverCpl',
                            p_params => l_params,
                            x_returnStatus => l_returnStatus);
    end if;

    x_returnStatus := fnd_api.g_ret_sts_success;
    if ( p_overCplQty > 0 ) then
      wip_overcompletion.check_tolerance(
                p_organization_id => p_orgID,
                p_wip_entity_id => p_wipEntityID,
                p_primary_quantity => p_overCplQty,
                p_result => result);

      if (result = WIP_CONSTANTS.NO) then
        -- exceed tolerance, set error message
        fnd_message.set_name ('WIP', 'WIP_OC_TOLERANCE_FAIL');
        x_errMessage := fnd_message.get;
        x_returnStatus := fnd_api.g_ret_sts_error;
      end if;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_completion.checkOverCpl',
                           p_procReturnStatus => 0,
                           p_msg => x_errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
  EXCEPTION
    when others then
      x_returnStatus := fnd_api.g_ret_sts_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_completion.checkOverCpl',
                             p_procReturnStatus => -1,
                             p_msg => x_errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
  end checkOverCpl;


  /**
   * given a Job, getLastOpSeq() gets the last operation sequence
   * associated with the job if the job has a routing. If the job
   * does not have a routing, -1 is returned.
   * Parameters:
   *   job     job to get the last operation sequence for.
   * Returns:
   *   number  the last operation sequence. -1 if it doesn't exist.
   */
  FUNCTION getLastOpSeq (job IN wma_common.Job) return number
  IS
    lastOpSeq NUMBER;
  BEGIN
    lastOpSeq := getLastOpSeq (job.wipEntityID, job.organizationID);

    return lastOpSeq;

  END getLastOpSeq;


  /**
   * given a wipEntityID and an orgID, getLastOpSeq() gets the last
   * operation sequence associated with the job if the job has a
   * routing. If the job does not have a routing, -1 is returned.
   * Parameters:
   *   wipEntityID  the wip_entity_id of the job
   *   orgID        the organization job belongs to.
   * Returns:
   *   number  the last operation sequence. -1 if it doesn't exist.
   */
  FUNCTION getLastOpSeq (wipEntityID IN NUMBER,
                         orgID IN NUMBER) return number
  IS
    lastOpSeq NUMBER;

    cursor getLastOpSeq (wipEntityID NUMBER, orgID NUMBER) IS
      select max(wo.operation_seq_num)
      from wip_operations wo
      where wo.organization_id = orgID
        and wo.wip_entity_id = wipEntityID;
  BEGIN

    open getLastOpSeq (wipEntityID, orgID);
    fetch getLastOpSeq into lastOpSeq;
    if (lastOpSeq is null) then
      lastOpSeq := -1;
    end if;
    close getLastOpSeq;

    return lastOpSeq;

  END getLastOpSeq;


  /**
   * given a job, getAvilableQty() returns the quantity in the
   * To Move step of the final operation if the job has a routing.
   * If the job, does not have a routing, getAvailableQty() computes
   * the available quantity to complete from the job quantities.
   * Parameters:
   *   job     job to find the available quantity for.
   * Returns:
   *   number  the available quantity in the job.
   */
  FUNCTION getAvailableQty (job IN wma_common.Job) return number
  IS
    lastOpSeq NUMBER;
    availableQty NUMBER;

    cursor getAvailableQty (v_wipEntityID NUMBER, v_orgID NUMBER, v_lastOpSeq NUMBER) IS
      select wo.quantity_waiting_to_move
      from wip_operations wo
      where wo.organization_id = v_orgID
        and wo.wip_entity_id = v_wipEntityID
        and wo.operation_seq_num = v_lastOpSeq;
  BEGIN

    -- get the avilable quantity for the job
    lastOpSeq := getLastOpSeq (job);
    if (lastOpSeq = -1) then      -- if the job does not have a routing
      availableQty :=
        job.startQuantity - job.quantityCompleted - job.quantityScrapped;
      if (availableQty < 0) then  -- can happen if previously overcompleted
        availableQty := 0;
      end if;
    else
      open getAvailableQty (job.wipEntityID, job.organizationID, lastOpSeq);
      fetch getAvailableQty into availableQty;
      close getAvailableQty;
    end if;

    return availableQty;

  END getAvailableQty;


  /**
   * Inserts a populated CmpTxnRec into MTI
   * Parameters:
   *   cmpRecord  The CmpTxnRec representing the row to be inserted.
   *   errMessage populated if an error occurrs
   * Return:
   *   boolean    A flag indicating whether table update was successful or not.
   * HISTORY:
   * 02-MAR-2006  spondalu  ER 4163405: populating demandSourceHeaderID and
   *                        demandSourceLineID from CmpTxnRec into MTI.
   *
   */
  Function put(cmpRecord CmpTxnRec, errMessage IN OUT NOCOPY VARCHAR2)
  return boolean IS
    l_dummy VARCHAR2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_rowID rowid;
    l_retStatus VARCHAR2(1);
  BEGIN
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('before insert', l_dummy);
      wip_logger.log('before insert item' || cmpRecord.inventory_item_id, l_dummy);
      wip_logger.log('before insert org' || cmpRecord.organization_id, l_dummy);
      wip_logger.log('before insert subinv' || cmpRecord.subinventory_code, l_dummy);
      wip_logger.log('before insert loc' || cmpRecord.locator_id, l_dummy);
      wip_logger.log('before insert action' || cmpRecord.transaction_action_id, l_dummy);
      wip_logger.log('before insert movTxnID ' || cmpRecord.move_transaction_id, l_dummy);
      wip_logger.log('before insert demandsourceheaderID ' || cmpRecord.demand_source_header_id, l_dummy);
      wip_logger.log('before insert demandsourcelineID ' || cmpRecord.demand_source_line_id, l_dummy);
    end if;

    insert into mtl_transactions_interface
           (transaction_header_id,
            completion_transaction_id,
            move_transaction_id,
            transaction_mode,
            created_by,
            creation_date,
            source_code,
            source_header_id,
            source_line_id,
--            lock_flag,
            inventory_item_id,
            subinventory_code,
            transaction_quantity,
            transaction_uom,
            primary_quantity,
            transaction_date,
            organization_id,
            acct_period_id,
            last_update_date,
            last_updated_by,
            transaction_action_id,
            transaction_source_id,
            transaction_source_type_id,
            transaction_type_id,
            wip_entity_type,
            revision,
            locator_id,
            operation_seq_num,
            transaction_interface_id,
            process_flag,
            final_completion_flag,
            source_project_id,
            source_task_id,
            project_id,
            task_id,
            qa_collection_id,
            overcompletion_transaction_id,
            overcompletion_transaction_qty,
            overcompletion_primary_qty,
            kanban_card_id,
            lpn_id,
            transaction_batch_id,
            transaction_batch_seq,
            demand_source_header_id,
            demand_source_line)
    values (cmpRecord.transaction_header_id,
            cmpRecord.completion_transaction_id,
            cmpRecord.move_transaction_id,
            cmpRecord.transaction_mode,
            cmpRecord.created_by,
            cmpRecord.creation_date,
            cmpRecord.source_code,
            cmpRecord.source_header_id,
            cmpRecord.source_line_id,
--            cmpRecord.lock_flag,
            cmpRecord.inventory_item_id,
            cmpRecord.subinventory_code,
            cmpRecord.transaction_quantity,
            cmpRecord.transaction_uom,
            cmpRecord.primary_quantity,
            cmpRecord.transaction_date,
            cmpRecord.organization_id,
            cmpRecord.acct_period_id,
            cmpRecord.last_update_date,
            cmpRecord.last_updated_by,
            cmpRecord.transaction_action_id,
            cmpRecord.transaction_source_id,
            cmpRecord.transaction_source_type_id,
            cmpRecord.transaction_type_id,
            cmpRecord.wip_entity_type,
            cmpRecord.revision,
            cmpRecord.locator_id,
            cmpRecord.operation_seq_num,
            cmpRecord.transaction_interface_id,
            cmpRecord.process_flag,
            cmpRecord.final_completion_flag,
            cmpRecord.source_project_id,
            cmpRecord.source_task_id,
            cmpRecord.project_id,
            cmpRecord.task_id,
            cmpRecord.qa_collection_id,
            cmpRecord.overcompletion_transaction_id,
            cmpRecord.overcompletion_transaction_qty,
            cmpRecord.overcompletion_primary_qty,
            cmpRecord.kanban_card_id,
            cmpRecord.lpn_id,
            cmpRecord.transaction_header_id,
            wip_constants.ASSY_BATCH_SEQ,
            cmpRecord.demand_source_header_id,
            cmpRecord.demand_source_line_id);
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('after insert', l_dummy);
        end if;


    wip_mtlTempProc_priv.validateInterfaceTxns(p_txnHdrID     => cmpRecord.transaction_header_id,
                                               p_initMsgList  => fnd_api.g_true,
                                               x_returnStatus => l_retStatus);

    if(l_retStatus <> fnd_api.g_ret_sts_success) then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('error from validateInterfaceTxns', l_retStatus);
      end if;
      wip_utilities.get_message_stack(p_msg => errMessage);
      return false;
    end if;
    return true;
  EXCEPTION
    when others then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('put failed: ' || SQLERRM, l_dummy);
      end if;
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_completion.put');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
      return false;
  END put;


  /**
   * Inserts a populated CmpTxnRec into wip_lpn_completions
   * Parameters:
   *   lpnCmpRecord  The LpnCmpTxnRec representing the row to be inserted.
   *   errMessage populated if an error occurrs
   * Return:
   *   boolean    A flag indicating whether table update was successful or not.
   */
  Function put(lpnCmpRecord LpnCmpTxnRec, errMessage IN OUT NOCOPY VARCHAR2)
  return boolean IS
  BEGIN

    insert into wip_lpn_completions
           (header_id, source_id, source_code,
            transaction_mode, created_by,
            creation_date, lock_flag,
            inventory_item_id, subinventory_code,
            transaction_quantity, transaction_uom,
            primary_quantity, transaction_date,
            organization_id, acct_period_id,
            last_update_date, last_updated_by,
            transaction_action_id, transaction_source_id,
            transaction_source_type_id, transaction_type_id,
            wip_entity_id, wip_entity_type, bom_revision,
            locator_id, operation_seq_num, item_project_id, item_task_id,
            qa_collection_id, kanban_card_id, lpn_id,
            end_item_unit_number, completion_transaction_id)
    values (lpnCmpRecord.row.header_id,
            lpnCmpRecord.row.header_id,
            WMA_COMMON.SOURCE_CODE,
            lpnCmpRecord.row.transaction_mode,
            lpnCmpRecord.row.created_by,
            lpnCmpRecord.row.creation_date,
            lpnCmpRecord.row.lock_flag,
            lpnCmpRecord.row.inventory_item_id,
            lpnCmpRecord.row.subinventory_code,
            lpnCmpRecord.row.transaction_quantity,
            lpnCmpRecord.row.transaction_uom,
            lpnCmpRecord.row.primary_quantity,
            lpnCmpRecord.row.transaction_date,
            lpnCmpRecord.row.organization_id,
            lpnCmpRecord.row.acct_period_id,
            lpnCmpRecord.row.last_update_date,
            lpnCmpRecord.row.last_updated_by,
            lpnCmpRecord.row.transaction_action_id,
            lpnCmpRecord.row.transaction_source_id,
            lpnCmpRecord.row.transaction_source_type_id,
            lpnCmpRecord.row.transaction_type_id,
            lpnCmpRecord.row.wip_entity_id,
            lpnCmpRecord.row.wip_entity_type,
            lpnCmpRecord.row.bom_revision,
            lpnCmpRecord.row.locator_id,
            lpnCmpRecord.row.operation_seq_num,
            lpnCmpRecord.row.item_project_id,
            --lpnCmpRecord.row.job_project_id,
            lpnCmpRecord.row.item_task_id,
            --lpnCmpRecord.row.job_task_id,
            lpnCmpRecord.row.qa_collection_id,
            lpnCmpRecord.row.kanban_card_id,
            lpnCmpRecord.row.lpn_id,
            lpnCmpRecord.row.end_item_unit_number,
            lpnCmpRecord.row.completion_transaction_id);

    return true;

  EXCEPTION
    when others then
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_completion.put');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
      return false;
  END put;

  procedure backflush(p_jobID IN NUMBER,
                      p_orgID IN NUMBER,
                      p_cplQty IN NUMBER,
                      p_overCplQty IN NUMBER,
                      p_cplTxnID IN NUMBER,
                      p_movTxnID IN NUMBER,
                      p_txnDate IN DATE,
                      p_txnHdrID IN NUMBER,
                      p_txnMode IN NUMBER := null,
                      p_objectID in number,
                      x_lotEntryType OUT NOCOPY NUMBER,
                      x_compInfo OUT NOCOPY system.wip_lot_serial_obj_t,
                      x_returnStatus OUT NOCOPY VARCHAR2,
                      x_errMessage OUT NOCOPY VARCHAR2) IS
    l_txnMode NUMBER;
    l_minOpSeqNum NUMBER;
    l_maxOpSeqNum NUMBER;
    l_assyPullStatus VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_opPullStatus VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_compTbl system.wip_component_tbl_t;
    l_returnStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'not printing params';
      l_params(1).paramValue := ' ';
      wip_logger.entryPoint(p_procName => 'wma_completion.backflush',
                            p_params => l_params,
                            x_returnStatus => l_returnStatus);
    end if;

    l_txnMode := nvl(p_txnMode, wma_derive.getTxnMode(p_orgID));

    select backflush_lot_entry_type
      into x_lotEntryType
      from wip_parameters
     where organization_id = p_orgID;

    --change from verify all to exceptions only if in background mode
    --this is b/c in background mode, component l/s information should
    --not be enterable by the user
    if(l_txnMode = wip_constants.background) then
      if(x_lotEntryType = wip_constants.recdate_full) then
        x_lotEntryType := wip_constants.recdate_exc;
      elsif(x_lotEntryType = wip_constants.expdate_full) then
        x_lotEntryType := wip_constants.expdate_exc;
      end if;
    end if;

    select nvl(min(operation_seq_num), 1), nvl(max(operation_seq_num), 1)
      into l_minOpSeqNum, l_maxOpSeqNum
      from wip_operations
     where wip_entity_id = p_jobID;

    l_compTbl := system.wip_component_tbl_t();

    --online. need to backflush components
    wip_bflProc_priv.processRequirements(p_wipEntityID => p_jobID,
                                         p_wipEntityType => wip_constants.discrete,
                                         p_cplTxnID => p_cplTxnID,
                                         p_orgID => p_orgID,
                                         p_assyQty => p_cplQty,
                                         p_txnDate => p_txnDate,
                                         p_wipSupplyType => wip_constants.assy_pull,
                                         p_txnHdrID => p_txnHdrID,
                                         p_firstOp => -1,
                                         p_lastOp => l_maxOpSeqNum,
                                         p_mergeMode => fnd_api.g_false,
                                         p_initMsgList => fnd_api.g_true,
                                         p_endDebug => fnd_api.g_true,
                                         p_mtlTxnMode => l_txnMode,
                                         x_compTbl => l_compTbl,
                                         x_returnStatus => x_returnStatus);
    if(x_returnStatus <>  fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(p_overCplQty > 0) then --backflush move components if any exist
    wip_bflProc_priv.processRequirements(p_wipEntityID => p_jobID,
                                         p_wipEntityType => wip_constants.discrete,
                                         p_movTxnID => p_movTxnID,
                                         p_orgID => p_orgID,
                                         p_assyQty => p_overCplQty,
                                         p_txnDate => p_txnDate,
                                         p_wipSupplyType => wip_constants.op_pull,
                                         p_txnHdrID => p_txnHdrID,
                                         p_firstMoveOp => l_minOpSeqNum,
                                         p_lastMoveOp => l_maxOpSeqNum,
                                         p_firstOp => -1,
                                         p_lastOp => l_maxOpSeqNum,
                                         p_mergeMode => fnd_api.g_false,
                                         p_initMsgList => fnd_api.g_false,
                                         p_endDebug => fnd_api.g_true,
                                         p_mtlTxnMode => l_txnMode,
                                         x_compTbl => l_compTbl,
                                         x_returnStatus => x_returnStatus);

      if(x_returnStatus <>  fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    x_compInfo := system.wip_lot_serial_obj_t(null, null, null, l_compTbl, null, null);
    x_compInfo.initialize;

    wip_autoLotProc_priv.deriveLots(x_compLots => x_compInfo,
                                    p_orgID    => p_orgID,
                                    p_wipEntityID => p_jobID,
                                    p_initMsgList => fnd_api.g_false,
                                    p_endDebug => fnd_api.g_true,
                                    p_destroyTrees => fnd_api.g_true,
                                    p_treeMode => inv_quantity_tree_pvt.g_reservation_mode,
                                    p_treeSrcName => null,
                                    x_returnStatus => x_returnStatus);

    --if there is missing l/s info for a background txn, error out.
    --note that we are ignoring the serialization derivation below b/c
    --serialized pages are only online...
    if(x_returnStatus = fnd_api.g_ret_sts_error and
       l_txnMode = wip_constants.background) then
      fnd_message.set_name('WIP', 'WIP_NO_LS_COMP_IN_BKGND');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(x_returnStatus = fnd_api.g_ret_sts_unexp_error) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- derive serial for serialized transaction. We can just check p_objectID.
    -- If p_objectID is -1, don't need to call deriveSerial. Otherwise call
    -- the API below.
    if ( p_objectID <> -1 ) then
      wip_autoSerialProc_priv.deriveSerial(x_compLots      => x_compInfo,
                                           p_orgID         => p_orgID,
                                           p_objectID      => p_objectID,
                                           p_initMsgList   => fnd_api.g_true,
                                           x_returnStatus  => x_returnStatus);
      if ( x_returnStatus = fnd_api.g_ret_sts_unexp_error ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(l_txnMode = wip_constants.background) then
      x_returnStatus := fnd_api.g_ret_sts_success;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_completion.backflush',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => x_errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
      return; --do nothing for now
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_completion.backflush',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'success',
                             x_returnStatus => l_returnStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      x_errMessage := fnd_msg_pub.get(p_encoded => 'F');
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_completion.backflush',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => x_errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
      rollback;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      x_errMessage := SQLERRM;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_completion.backflush',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => x_errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
      rollback;
    end backflush;

  /**
   * given a wipEntityID, orgID and itemID, getRevision() will validate
   * whether bom_revision exists as an item_revision or not. If not
   * return false. Otherwise return true. If bom_revision is null, derive
   * it based on the transaction_date specified. In mobile it is sysdate.
   * Parameters:
   *   wipEntityID  the wip_entity_id of the job
   *   orgID        the organization job belongs to.
   *   itemID       the assembly item ID
   *   revision     bom_revision if bom_revision exists as an item_revision
   *                if bom_revision is null, derive it based on txn_date
   * Returns:
   *   true if bom_revision exist as an item_revision. Otherwise return false
   */
  FUNCTION getRevision (wipEntityID IN NUMBER,
                        orgID       IN NUMBER,
                        itemID      IN NUMBER,
                        revision   OUT NOCOPY VARCHAR2) return boolean IS

  BEGIN
    SELECT NVL(wdj.bom_revision, bom_revisions.get_item_revision_fn
            ('EXCLUDE_OPEN_HOLD',        -- eco_status
             'ALL',                      -- examine_type
              orgID,                     -- org_id
              itemID,                    -- item_id
              sysdate                    -- rev_date
            ))
      INTO revision
      FROM wip_discrete_jobs wdj,
           mtl_item_revisions mir
     WHERE wdj.organization_id = mir.organization_id
       AND wdj.wip_entity_id = wipEntityID
       AND mir.organization_id = orgID
       AND mir.inventory_item_id = itemID
       AND (mir.revision =
            NVL(wdj.bom_revision, bom_revisions.get_item_revision_fn
            ('EXCLUDE_OPEN_HOLD',        -- eco_status
             'ALL',                      -- examine_type
              orgID,                     -- org_id
              itemID,                    -- item_id
              sysdate                    -- rev_date
            )));
    return true;
  EXCEPTION
    WHEN others THEN
      fnd_message.set_name('WIP', 'WIP_BOM_ITEM_REVISION');
      return false;
  END getRevision;
end wma_completion;

/
