--------------------------------------------------------
--  DDL for Package Body WIP_MTLPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MTLPROC_PRIV" as
 /* $Header: wipmtlpb.pls 120.11.12000000.3 2007/05/07 11:25:53 akbhatia ship $ */

/*  History
*
*     Bug           Fix By           Description
*  ---------       ----------        -----------
*
*  5356098          mraman           Added 2 local variables and
*                                    intialized them to null to avoid
*                                    ORA-6531 in procedure populateRepScheds
*
*/
  ----------------------
  --private package types
  -----------------------
  type num_tbl_t is table of number;

  -----------------
  --package globals
  -----------------
  g_extendAmount constant number := 20; --for nested tables, the amount to extend each time more rows are needed.

  ----------------------
  --forward declarations
  ----------------------
--  procedure setMtlTxnID(p_mtlTxnID IN NUMBER);
--  procedure resetMtlTxnID;
--  procedure setTxnTmpID(p_txnTmpID IN NUMBER);
  procedure writeError(p_txnTmpID IN NUMBER);

  procedure processTxn(p_issueRec IN wip_mtlTempProc_grp.comp_rec_t,
                       p_issueQty IN NUMBER,
                       p_repSchedID IN NUMBER,
                       x_returnStatus OUT NOCOPY VARCHAR2);

  procedure populateRepScheds(p_issueRec IN wip_mtlTempProc_grp.comp_rec_t,
                              x_schedTbl OUT NOCOPY num_tbl_t,
                              x_qtyTbl OUT NOCOPY num_tbl_t,
                              x_returnStatus OUT NOCOPY VARCHAR2);

  procedure processRepetitive(p_issueRec IN OUT nocopy wip_mtlTempProc_grp.comp_rec_t,
                              x_returnStatus OUT NOCOPY VARCHAR2);

  ---------------------------
  --public/private procedures
  ---------------------------
  procedure processTemp(p_initMsgList IN VARCHAR2,
                        p_endDebug IN VARCHAR2,
                        p_txnTmpID IN NUMBER,
                        x_returnStatus OUT NOCOPY VARCHAR2) is
    l_issueRec wip_mtlTempProc_grp.comp_rec_t;
    l_returnStatus VARCHAR2(1);
    l_invStatus NUMBER;
    l_errMsg VARCHAR2(2400);
    l_params wip_logger.param_tbl_t;
    l_msgCount NUMBER;
    l_jobStatus NUMBER;
    l_jobStatusCode VARCHAR2(240);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin
    savepoint wipmtlpb_SP1;

    if(fnd_api.to_boolean(p_initMsgList)) then
      fnd_msg_pub.initialize;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnTmpID';
      l_params(1).paramValue := p_txnTmpID;
      wip_logger.entryPoint(p_procName => 'wip_mtlProc_priv.processTemp',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    select p_txnTmpID,
           mmtt.material_allocation_temp_id,
           mmtt.transaction_source_id,
           mmtt.wip_entity_type,
           mmtt.organization_id, --5
           mmtt.repetitive_line_id,
           mmtt.inventory_item_id,
           mmtt.operation_seq_num,
           -1 * mmtt.primary_quantity, --qty is relative to inv, make it relative to wip
           -1 * mmtt.transaction_quantity, --10
           mmtt.negative_req_flag,
           mmtt.wip_supply_type,
           msi.wip_supply_subinventory, /* Bug 5918149 : Pick subinventory from msi instead of mmtt. FP for bug 5895215 */
           msi.wip_supply_locator_id, /* Bug 5918149 : Pick locator from msi instead of mmtt. FP for bug 5895215 */
           mmtt.transaction_date, --15
           mmtt.transaction_header_id,
           mmtt.move_transaction_id,
           mmtt.completion_transaction_id,
           mmtt.qa_collection_id,
           mmtt.department_id,
           mmtt.transaction_action_id,
           msi.serial_number_control_code,
           msi.lot_control_code,
           msi.eam_item_type,
           mmtt.rebuild_item_id,
           mmtt.rebuild_job_name,
           mmtt.rebuild_activity_id,
           mmtt.rebuild_serial_number
      into l_issueRec.txnTmpID,
           l_issueRec.mtlTxnID,
           l_issueRec.wipEntityID,
           l_issueRec.wipEntityType,
           l_issueRec.orgID,
           l_issueRec.repLineID,--5
           l_issueRec.itemID,
           l_issueRec.opSeqNum,
           l_issueRec.primaryQty,
           l_issueRec.txnQty,
           l_issueRec.negReqFlag, --10
           l_issueRec.wipSupplyType,
           l_issueRec.supplySub,
           l_issueRec.supplyLocID,
           l_issueRec.txnDate,
           l_issueRec.txnHdrID, --15
           l_issueRec.movTxnID,
           l_issueRec.cplTxnID,
           l_issueRec.qaCollectionID,
           l_issueRec.deptID,
           l_issueRec.txnActionID,
           l_issueRec.serialControlCode,
           l_issueRec.lotControlCode,
           l_issueRec.eamItemType,
           l_issueRec.rebuildItemID,
           l_issueRec.rebuildJobName,
           l_issueRec.rebuildActivityID,
           l_issueRec.rebuildSerialNumber
       from mtl_material_transactions_temp mmtt, mtl_system_items_b msi
     where transaction_temp_id = p_txnTmpID
       and mmtt.inventory_item_id = msi.inventory_item_id
       and mmtt.organization_id = msi.organization_id
         and nvl(flow_schedule, 'N') <> 'Y';

    --in 11.5.9 forms don't always insert wip supply type. from 11.5.10 on, all forms and interfaces should
    --for now, use ids to default supplytype if not populated:
    if(l_issueRec.wipSupplyType is null) then
      if(l_issueRec.movTxnID is not null) then
        l_issueRec.wipSupplyType := wip_constants.op_pull;
      elsif(l_issueRec.cplTxnID is not null) then
        l_issueRec.wipSupplyType := wip_constants.assy_pull;
      else
        l_issueRec.wipSupplyType := wip_constants.push;
      end if;
    end if;

    if(l_issueRec.wipEntityType in (wip_constants.discrete,
                                    wip_constants.lotbased,
                                    wip_constants.eam)) then
      /* commented out to prevent stuck transactions in MMTT
      select status_type
        into l_jobStatus
        from wip_discrete_jobs
       where wip_entity_id = l_issueRec.wipEntityID;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('selected job status:' || l_jobStatus, l_returnStatus);
      end if;

      if(l_jobStatus not in (wip_constants.released, wip_constants.comp_chrg)) then
        begin
          select meaning
            into l_JobStatus
            from mfg_lookups
           where lookup_type = 'WIP_JOB_STATUS'
             and lookup_code = l_jobStatus;
        exception
          when others then
            l_jobStatusCode := l_jobStatus;
        end;
        fnd_message.set_name('WIP', 'WIP_PICKING_STATUS_ERROR');
        fnd_message.set_token('STATUS', l_jobStatus);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      end if;
      */

      processTxn(p_issueRec     => l_issueRec,
                 p_issueQty     => null, --since not processing rep schedules
                 p_repSchedID   => null, --since not processing rep schedules
                 x_returnStatus => x_returnStatus);
      if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      -------------------
      --eam issue code
      -------------------
      if(l_issueRec.wipEntityType = wip_constants.eam) then
        --if error occurs, processRebuildable should put an err msg on the stack
         if (l_logLevel <= wip_constants.full_logging) then
           wip_logger.log('about to call EAM processor ', l_returnStatus);
         end if;
         wip_eamMtlProc_priv.processCompTxn(p_compRec => l_issueRec,
                                          x_returnStatus => x_returnStatus);
        if(x_returnStatus <> fnd_api.g_ret_sts_success) then
          l_errMsg := 'EAM logic failed';
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;

    elsif(l_issueRec.wipEntityType = wip_constants.repetitive) then
      --may be multiple schedule transactions per single issue
      processRepetitive(p_issueRec     => l_issueRec,
                        x_returnStatus => x_returnStatus);

    else
      fnd_message.set_name('WIP', 'OPERATION_PROCESSING_ERROR');
      l_errMsg := 'Invalid WIP Entity Type:' || l_issueRec.wipEntityType;
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      l_errMsg := 'processing failed';
      raise fnd_api.g_exc_unexpected_error;
    end if;
    if(l_issueRec.qaCollectionID is not null and
       l_issueRec.movTxnID is null) then --if movTxnID is present, move would have enabled results.
      qa_result_grp.enable(p_api_version => 1.0,
                           p_validation_level => 0,
                           p_collection_id => l_issueRec.qaCollectionID,
                           p_return_status => x_returnStatus,
                           p_msg_count => l_msgCount,
                           p_msg_data => l_errMsg);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'QA Failed. Collection ID:' || l_issueRec.qaCollectionID;
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processTemp',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Transaction Succeeded',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
    if(fnd_api.to_boolean(p_endDebug)) then
      wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    --processing error. return status and error msg should have already been set.
    when no_data_found then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      rollback to wipmtlpb_SP1;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processTemp',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'no data found exception. tmpID:' || p_txnTmpID,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      fnd_message.set_name('WIP', 'INVALID_MMTT_TEMP_ID');
      fnd_msg_pub.add;
      writeError(p_txnTmpID);

    when fnd_api.g_exc_unexpected_error then
      rollback to wipmtlpb_SP1;

      x_returnStatus := fnd_api.g_ret_sts_unexp_error;

      writeError(p_txnTmpID); --update the MMTT line to error for wip failures
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processTemp',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      rollback to wipmtlpb_SP1;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mtlProc_priv',
                              p_procedure_name => 'processTemp',
                              p_error_text => SQLERRM);
      writeError(p_txnTmpID);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processTemp',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'item' || l_issueRec.itemID || ' unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end processTemp;

  procedure fillIssueParamTbl(p_issueRec IN wip_mtlTempProc_grp.comp_rec_t,
                              x_params OUT NOCOPY wip_logger.param_tbl_t)
  is begin

    x_params(1).paramName := 'p_issueRec.txnTmpID';
    x_params(1).paramValue := p_issueRec.txnTmpID;
    x_params(2).paramName := 'p_issueRec.mtlTxnID';
    x_params(2).paramValue := p_issueRec.mtlTxnID;
    x_params(3).paramName := 'p_issueRec.wipEntityID';
    x_params(3).paramValue := p_issueRec.wipEntityID;
    x_params(4).paramName := 'p_issueRec.repLineID';
    x_params(4).paramValue := p_issueRec.repLineID;
    x_params(5).paramName := 'p_issueRec.orgID';
    x_params(5).paramValue := p_issueRec.orgID;
    x_params(6).paramName := 'p_issueRec.itemID';
    x_params(6).paramValue := p_issueRec.itemID;
    x_params(7).paramName := 'p_issueRec.opSeqNum';
    x_params(7).paramValue := p_issueRec.opSeqNum;
    x_params(8).paramName := 'p_issueRec.primaryQty';
    x_params(8).paramValue := p_issueRec.primaryQty;
    x_params(9).paramName := 'p_issueRec.txnQty';
    x_params(9).paramValue := p_issueRec.txnQty;
    x_params(10).paramName := 'p_issueRec.negReqFlag';
    x_params(10).paramValue := p_issueRec.negReqFlag;
    x_params(11).paramName := 'p_issueRec.wipSupplyType';
    x_params(11).paramValue := p_issueRec.wipSupplyType;
    x_params(12).paramName := 'p_issueRec.wipEntityType';
    x_params(12).paramValue := p_issueRec.wipEntityType;
    x_params(13).paramName := 'p_issueRec.supplySub';
    x_params(13).paramValue := p_issueRec.supplySub;
    x_params(14).paramName := 'p_issueRec.supplyLocID';
    x_params(14).paramValue := p_issueRec.supplyLocID;
    x_params(15).paramName := 'p_issueRec.txnDate';
    x_params(15).paramValue := p_issueRec.txnDate;
    x_params(16).paramName := 'p_issueRec.txnHdrID';
    x_params(16).paramValue := p_issueRec.txnHdrID;
    x_params(17).paramName := 'p_issueRec.movTxnID';
    x_params(17).paramValue := p_issueRec.movTxnID;
    x_params(18).paramName := 'p_issueRec.cplTxnID';
    x_params(18).paramValue := p_issueRec.cplTxnID;
    x_params(19).paramName := 'p_issueRec.qaCollectionID';
    x_params(19).paramValue := p_issueRec.qaCollectionID;
    x_params(20).paramName := 'p_issueRec.deptID';
    x_params(20).paramValue := p_issueRec.deptID;
    x_params(21).paramName := 'p_issueRec.txnActionID';
    x_params(21).paramValue := p_issueRec.txnActionID;
    x_params(22).paramName := 'p_issueRec.serialControlCode';
    x_params(22).paramValue := p_issueRec.serialControlCode;
    x_params(23).paramName := 'p_issueRec.lotControlCode';
    x_params(23).paramValue := p_issueRec.lotControlCode;
    x_params(24).paramName := 'p_issueRec.eamItemType';
    x_params(24).paramValue := p_issueRec.eamItemType;
    x_params(25).paramName := 'p_issueRec.rebuildItemID';
    x_params(25).paramValue := p_issueRec.rebuildItemID;
    x_params(26).paramName := 'p_issueRec.rebuildJobName';
    x_params(26).paramValue := p_issueRec.rebuildJobName;
    x_params(27).paramName := 'p_issueRec.rebuildActivityID';
    x_params(27).paramValue := p_issueRec.rebuildActivityID;
    x_params(28).paramName := 'p_issueRec.rebuildSerialNumber';
    x_params(28).paramValue := p_issueRec.rebuildSerialNumber;

  end fillIssueParamTbl;

  procedure processTxn(p_issueRec IN wip_mtlTempProc_grp.comp_rec_t,
                       p_issueQty IN NUMBER,
                       p_repSchedID IN NUMBER,
                       x_returnStatus OUT NOCOPY VARCHAR2) IS
    l_rowid ROWID;
    l_doUpdate boolean := true;
    l_params wip_logger.param_tbl_t;
    l_paramCount NUMBER;
    l_errMsg VARCHAR2(240);
    l_returnStatus VARCHAR2(1);
    l_newRequiredQty NUMBER;
    l_newIssuedQty NUMBER;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_dept_id NUMBER := null; /* Bugfix 5401362 */
  begin
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('processTxn: p_issueQty: ' || p_issueQty, l_returnStatus);
    end if;
    --just logs the issue record. moved to a helper just to keep procedure small

    if (l_logLevel <= wip_constants.trace_logging) then
      fillIssueParamTbl(p_issueRec => p_issueRec,
                        x_params => l_params);
      l_paramCount := l_params.count;
      l_params(l_paramCount + 1).paramName := 'p_issueQty';
      l_params(l_paramCount + 1).paramValue := p_issueQty;
      l_params(l_paramCount + 2).paramName := 'p_repSchedID';
      l_params(l_paramCount + 2).paramValue := p_repSchedID;
      wip_logger.entryPoint(p_procName => 'wip_mtlProc_priv.processTxn',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(p_repSchedID is null) then
      begin
        select rowid
          into l_rowid
          from wip_requirement_operations
         where  inventory_item_id = p_issueRec.itemID
         and wip_entity_id = p_issueRec.wipEntityID
         and operation_seq_num = p_issueRec.opSeqNum
        for update of quantity_issued, quantity_allocated nowait;
      exception
        when no_data_found then
          l_doUpdate := false;
      end;
      if(l_doUpdate) then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('do update is true', l_returnStatus);
        end if;
        --below, quantity_allocated must be >= 0. At the same time, it must never increase via a return, negative issue.
        --only the component picking process should increase the quantity_allocated column
        update wip_requirement_operations --try to update an existing requirement
           set quantity_issued = quantity_issued + nvl(p_issueQty, p_issueRec.primaryQty),
               quantity_allocated = greatest(0, least(quantity_allocated, quantity_allocated - nvl(p_issueQty, p_issueRec.primaryQty))),
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.conc_login_id,
               request_id = fnd_global.conc_request_id,
               program_id = fnd_global.conc_program_id,
               program_application_id = fnd_global.prog_appl_id
         where rowid = l_rowid returning quantity_issued, required_quantity into l_newIssuedQty, l_newRequiredQty;

      end if;
    else
      begin --try to find an existing requirement
        select rowid
          into l_rowid
          from wip_requirement_operations
         where inventory_item_id = p_issueRec.itemID
         and wip_entity_id = p_issueRec.wipEntityID
         and repetitive_schedule_id = p_repSchedID
         and operation_seq_num = p_issueRec.opSeqNum
        for update of quantity_issued, quantity_allocated nowait;
      exception
        when no_data_found then --no existing requirement, will have to insert one
          l_doUpdate := false;
      end;
      if(l_doUpdate) then
        --below, quantity_allocated must be >= 0. At the same time, it must never increase via a return, negative issue.
        --only the component picking process should increase the quantity_allocated column
        update wip_requirement_operations --try to update an existing requirement
           set quantity_issued = quantity_issued + nvl(p_issueQty, p_issueRec.primaryQty),
               quantity_allocated = greatest(0, least(quantity_allocated, quantity_allocated - nvl(p_issueQty, p_issueRec.primaryQty))),
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.conc_login_id,
               request_id = fnd_global.conc_request_id,
               program_id = fnd_global.conc_program_id,
               program_application_id = fnd_global.prog_appl_id
         where rowid = l_rowid returning quantity_issued, required_quantity into l_newIssuedQty, l_newRequiredQty;

      end if;
    end if;

    if(not l_doUpdate) then --create the requirement since we could not find an existing one
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('about to do insert', l_returnStatus);
      end if;

      /* Bugfix 5401362. Default department_id when null */
      if (p_issueRec.deptID is null) then
        begin
	  select department_id
	  into l_dept_id
	  from wip_operations wo
	  where wip_entity_id = p_issueRec.wipEntityID
	  and operation_seq_num = p_issueRec.opSeqNum;
        exception
    	  when others then
            null;
        end;
      end if;
      /* End bugfix 5401362 */

      insert into wip_requirement_operations
        (inventory_item_id,
         organization_id,
         wip_entity_id,
         operation_seq_num,
         repetitive_schedule_id, --5
         creation_date,
         created_by,
         last_update_login,
         last_update_date,
         last_updated_by, --10
         department_id,
         date_required,
         required_quantity,
         quantity_issued,
         quantity_per_assembly, --15
         wip_supply_type,
         mrp_net_flag,
         request_id,
         program_application_id,
         program_id, --20
         program_update_date,
         supply_subinventory,
         supply_locator_id,
         mps_date_required,
         mps_required_quantity, --25
         segment1,
         segment2,
         segment3,
         segment4,
         segment5, --30
         segment6,
         segment7,
         segment8,
         segment9,
         segment10, --35
         segment11,
         segment12,
         segment13,
         segment14,
         segment15, --40
         segment16,
         segment17,
         segment18,
         segment19,
         segment20,
         component_yield_factor -- Added for bug 4703470
         )
       select p_issueRec.itemID,
              p_issueRec.orgID,
              p_issueRec.wipEntityID,
              p_issueRec.opSeqNum,
              p_repSchedID, --5
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              sysdate,
              fnd_global.user_id, --10
              nvl(p_issueRec.deptID, l_dept_id), /* Bugfix 5401362 l_dept_id if null */
              p_issueRec.txnDate,
              0, --required_quantity
              nvl(p_issueQty, p_issueRec.primaryQty),
              0, --quantity_per_assembly 15
              nvl(p_issueRec.wipSupplyType, wip_constants.push),
              wip_constants.yes,
              fnd_global.conc_request_id,
              fnd_global.prog_appl_id,
              fnd_global.conc_program_id, --20
              sysdate,
              p_issueRec.supplySub,
              p_issueRec.supplyLocID,
              p_issueRec.txnDate,
              0, --mps_required_quantity??? 25
              SEGMENT1,
              SEGMENT2,
              SEGMENT3,
              SEGMENT4,
              SEGMENT5, --30
              SEGMENT6,
              SEGMENT7,
              SEGMENT8,
              SEGMENT9,
              SEGMENT10, --35
              SEGMENT11,
              SEGMENT12,
              SEGMENT13,
              SEGMENT14,
              SEGMENT15, --40
              SEGMENT16,
              SEGMENT17,
              SEGMENT18,
              SEGMENT19,
              SEGMENT20,
              1          -- Added for Bug 4703470
         FROM MTL_SYSTEM_ITEMS
        WHERE ORGANIZATION_ID = p_issueRec.orgID
          AND INVENTORY_ITEM_ID = p_issueRec.itemID;

       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('inserted ' || SQL %ROWCOUNT, l_returnStatus);
       end if;
    end if;

    x_returnStatus := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processTxn',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processTxn',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    fnd_message.set_name('WIP', 'OPERATION_PROCESSING_ERROR');
    fnd_msg_pub.add;
    --need to add a message to the stack and count it
  when wip_constants.records_locked then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processTxn',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'records locked',
                           x_returnStatus => l_returnStatus);
    end if;
    fnd_message.set_name('INV', 'INV_WIP_WORK_ORDER_LOCKED');
    fnd_msg_pub.add;
  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mtlProc_priv',
                            p_procedure_name => 'processTxn',
                            p_error_text => SQLERRM);
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processTxn',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'unexpected error: ' || SQLERRM,
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
    fnd_message.set_name('WIP', 'OPERATION_PROCESSING_ERROR');
    fnd_msg_pub.add;
  end processTxn;

  --This procedure fetches the repetitive schedules and how much of the component
  --quantity can be allocated to that schedule. As different cursors are used for
  --issues and returns as well as by supply type, this helper method helps reduce
  --the size of processRepetitive() below
  procedure populateRepScheds(p_issueRec IN wip_mtlTempProc_grp.comp_rec_t,
                              x_schedTbl OUT NOCOPY num_tbl_t,
                              x_qtyTbl OUT NOCOPY num_tbl_t,
                              x_returnStatus OUT NOCOPY VARCHAR2) is
    l_mmttCount NUMBER;
    l_include_yield NUMBER ; -- added for bug 5491202
    /* Bug Num 5356098 */
    l_schedTbl num_tbl_t := num_tbl_t();
    l_qtyTbl num_tbl_t   := num_tbl_t();
  begin
    x_schedTbl := l_schedTbl ;
    x_qtyTbl   := l_qtyTbl ;
    --return status is set to success at the last line of the procedure.
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    if(p_issueRec.wipSupplyType = wip_constants.push) then
      /* Fix for bug 5373061: Added date_released condition */
      if(p_issueRec.txnActionID in (wip_constants.isscomp_action, wip_constants.issnegc_action)) then
        select wro.repetitive_schedule_id,
               wro.required_quantity - wro.quantity_issued
          bulk collect into x_schedTbl, x_qtyTbl
          from wip_requirement_operations wro,
               wip_repetitive_schedules wrs
         where wro.wip_entity_id = p_issueRec.wipEntityID
           and wro.inventory_item_id = p_issueRec.itemID
           and wro.operation_seq_num = p_issueRec.opSeqNum
           and sign(wro.quantity_per_assembly) = sign(p_issueRec.negReqFlag)
           and wrs.repetitive_schedule_id = wro.repetitive_schedule_id
           and wrs.line_id = p_issueRec.repLineID
           and sign(wro.required_quantity) = p_issueRec.negReqFlag
           and wrs.status_type in (3,4)    /* bug3338344*/
           and wrs.date_released < p_issueRec.txnDate
         order by wrs.first_unit_start_date;
      else -- a return transaction
        select wro.repetitive_schedule_id,--same as issue cursor above except for order by
               wro.quantity_issued
          bulk collect into x_schedTbl, x_qtyTbl
          from wip_requirement_operations wro,
               wip_repetitive_schedules wrs
         where wro.wip_entity_id = p_issueRec.wipEntityID
           and wro.inventory_item_id = p_issueRec.itemID
           and wro.operation_seq_num = p_issueRec.opSeqNum
           and sign(wro.quantity_per_assembly) = sign(p_issueRec.negReqFlag)
           and wrs.repetitive_schedule_id = wro.repetitive_schedule_id
           and wrs.line_id = p_issueRec.repLineID
           and sign(wro.required_quantity) = p_issueRec.negReqFlag
           and wrs.status_type in (3,4)    /* bug3338344*/
           and wrs.date_released < p_issueRec.txnDate
         order by wrs.first_unit_start_date desc;
      end if;
    elsif(p_issueRec.movTxnID is not null) then

      -- bug 5491202 added the following sql to find org level parameter
      -- for including or excluding component_yield_factor

      select nvl(include_component_yield,1)
      into l_include_yield
      from wip_parameters
      where organization_id = p_issueRec.orgID ;

      -- bug 5491202 end changes

      if(p_issueRec.txnActionID in (wip_constants.isscomp_action, wip_constants.issnegc_action)) then
        select wro.repetitive_schedule_id,
          --   bug 5491202 changed the next line to include component yield
          --   wro.quantity_per_assembly * wmta.primary_quantity
               round( wro.quantity_per_assembly * wmta.primary_quantity
                      / decode(l_include_yield,2,1,nvl(wro.component_yield_factor,1)),
                      wip_constants.inv_max_precision)
          bulk collect into x_schedTbl, x_qtyTbl
          from wip_repetitive_schedules wrs,
               wip_requirement_operations wro,
               wip_move_txn_allocations wmta
         where wmta.transaction_id = p_issueRec.movTxnID
           and wro.repetitive_schedule_id = wmta.repetitive_schedule_id
           and wro.repetitive_schedule_id = wrs.repetitive_schedule_id
           and wro.wip_entity_id = p_issueRec.wipEntityID
           and wro.inventory_item_id = p_issueRec.itemID
           and wro.operation_seq_num = p_issueRec.opSeqNum
           and wro.wip_supply_type = p_issueRec.wipSupplyType
           and wro.quantity_per_assembly <> 0
           and sign(wro.required_quantity) = p_issueRec.negReqFlag
           /* and wrs.status_type in (3,4) */   /* bug3338344 removed for bug5137228 (fp5015515) */
         order by wrs.first_unit_start_date;
      else --return txn
        select wro.repetitive_schedule_id,
          --   bug 5491202 changed the next line to include component yield
          --   wro.quantity_per_assembly * wmta.primary_quantity schedQty
               round( wro.quantity_per_assembly * wmta.primary_quantity
                      / decode(l_include_yield,2,1,nvl(wro.component_yield_factor,1)),
                      wip_constants.inv_max_precision)
          bulk collect into x_schedTbl, x_qtyTbl
          from wip_repetitive_schedules wrs,
               wip_requirement_operations wro,
               wip_move_txn_allocations wmta
         where wmta.transaction_id = p_issueRec.movTxnID
           and wro.repetitive_schedule_id = wmta.repetitive_schedule_id
           and wro.repetitive_schedule_id = wrs.repetitive_schedule_id
           and wro.wip_entity_id = p_issueRec.wipEntityID
           and wro.inventory_item_id = p_issueRec.itemID
           and wro.operation_seq_num = p_issueRec.opSeqNum
           and wro.wip_supply_type = p_issueRec.wipSupplyType
           and wro.quantity_per_assembly <> 0
           and sign(wro.required_quantity) = p_issueRec.negReqFlag
           /* and wrs.status_type in (3,4) */    /* bug3338344 removed for bug5137228 (fp5015515) */
         order by wrs.first_unit_start_date desc;
      end if;

    elsif(p_issueRec.cplTxnID is not null) then
      --the completion transaction could either be in mmtt or mmt...
      select count(*)
        into l_mmttCount
        from mtl_material_transactions_temp
       where completion_transaction_id = p_issueRec.cplTxnID
         and transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action);

      if(l_mmttCount > 0) then
        if(p_issueRec.txnActionID in (wip_constants.isscomp_action, wip_constants.issnegc_action)) then
          select wro.repetitive_schedule_id,
                 wro.quantity_per_assembly * sum(mmta.primary_quantity) schedQty
            bulk collect into x_schedTbl, x_qtyTbl
            from wip_repetitive_schedules wrs,
                 wip_requirement_operations wro,
                 mtl_material_txn_allocations mmta,
                 mtl_material_transactions_temp mmtt --the MMTT row(s) are the assy rows
           where mmta.transaction_id = mmtt.material_allocation_temp_id
             and mmtt.completion_transaction_id = p_issueRec.cplTxnID
             and mmtt.transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action)
             and wro.wip_entity_id = p_issueRec.wipEntityID
             and wro.repetitive_schedule_id = mmta.repetitive_schedule_id
             and wro.repetitive_schedule_id = wrs.repetitive_schedule_id
             and wro.inventory_item_id = p_issueRec.itemID
             and wro.operation_seq_num = p_issueRec.opSeqNum
             and wro.wip_supply_type = p_issueRec.wipSupplyType
             and wro.quantity_per_assembly <> 0
             and sign(wro.required_quantity) = p_issueRec.negReqFlag
             /* and wrs.status_type in (3,4) */   /* bug3338344 removed for bug5137228 (fp5015515) */
           group by wro.repetitive_schedule_id, wro.quantity_per_assembly, wrs.first_unit_start_date
           order by wrs.first_unit_start_date;

         /* Fix for Bug#5030360 (fp5201404). Check into wip_mtl_allocations_temp as
            Completion record may not be processed yet
            to be present in mtl_material_txn_allocations
         */

        if sql%NOTFOUND  then
          select wro.repetitive_schedule_id,
                 wro.quantity_per_assembly * sum(wmat.primary_quantity) schedQty
            bulk collect into x_schedTbl, x_qtyTbl
            from wip_repetitive_schedules wrs,
                 wip_requirement_operations wro,
                 wip_mtl_allocations_temp  wmat,
                 mtl_material_transactions_temp mmtt --the MMTT row(s) are the assy rows
           where wmat.transaction_temp_id = mmtt.transaction_temp_id
             and mmtt.completion_transaction_id = p_issueRec.cplTxnID
             and mmtt.transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action)
             and wro.wip_entity_id = p_issueRec.wipEntityID
             and wro.repetitive_schedule_id = wmat.repetitive_schedule_id
             and wro.repetitive_schedule_id = wrs.repetitive_schedule_id
             and wro.inventory_item_id = p_issueRec.itemID
             and wro.operation_seq_num = p_issueRec.opSeqNum
             and wro.wip_supply_type = p_issueRec.wipSupplyType
             and wro.quantity_per_assembly <> 0
             and sign(wro.required_quantity) = p_issueRec.negReqFlag
           group by wro.repetitive_schedule_id, wro.quantity_per_assembly, wrs.first_unit_start_date
           order by wrs.first_unit_start_date;
         end if ;
         /* End for Bug#5030360 (fp52014040) */

        else --return txn
          select wro.repetitive_schedule_id,
                 wro.quantity_per_assembly * sum(mmta.primary_quantity) schedQty
            bulk collect into x_schedTbl, x_qtyTbl
            from wip_repetitive_schedules wrs,
                 wip_requirement_operations wro,
                 mtl_material_txn_allocations mmta,
                 mtl_material_transactions_temp mmtt
           where mmta.transaction_id = mmtt.material_allocation_temp_id
             and mmtt.completion_transaction_id = p_issueRec.cplTxnID
             and mmtt.transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action)
             and wro.wip_entity_id = p_issueRec.wipEntityID
             and wro.repetitive_schedule_id = mmta.repetitive_schedule_id
             and wro.repetitive_schedule_id = wrs.repetitive_schedule_id
             and wro.inventory_item_id = p_issueRec.itemID
             and wro.operation_seq_num = p_issueRec.opSeqNum
             and wro.wip_supply_type = p_issueRec.wipSupplyType
             and wro.quantity_per_assembly <> 0
             and sign(wro.required_quantity) = p_issueRec.negReqFlag
             /* and wrs.status_type in (3,4) */    /* bug3338344 removed for bug5137228 (fp5015515) */
           group by wro.repetitive_schedule_id, wro.quantity_per_assembly, wrs.first_unit_start_date
           order by wrs.first_unit_start_date desc;

         /* Fix for Bug#5030360 (fp5201404). Check into wip_mtl_allocations_temp as
            Completion record may not be processed yet
            to be present in mtl_material_txn_allocations
         */
         if sql%NOTFOUND  then
          select wro.repetitive_schedule_id,
                 wro.quantity_per_assembly * sum(wmat.primary_quantity) schedQty
            bulk collect into x_schedTbl, x_qtyTbl
            from wip_repetitive_schedules wrs,
                 wip_requirement_operations wro,
                 wip_mtl_allocations_temp  wmat,
                 mtl_material_transactions_temp mmtt --the MMTT row(s) are the assy rows
           where wmat.transaction_temp_id = mmtt.transaction_temp_id
             and mmtt.completion_transaction_id = p_issueRec.cplTxnID
             and mmtt.transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action)
             and wro.wip_entity_id = p_issueRec.wipEntityID
             and wro.repetitive_schedule_id = wmat.repetitive_schedule_id
             and wro.repetitive_schedule_id = wrs.repetitive_schedule_id
             and wro.inventory_item_id = p_issueRec.itemID
             and wro.operation_seq_num = p_issueRec.opSeqNum
             and wro.wip_supply_type = p_issueRec.wipSupplyType
             and wro.quantity_per_assembly <> 0
             and sign(wro.required_quantity) = p_issueRec.negReqFlag
           group by wro.repetitive_schedule_id, wro.quantity_per_assembly, wrs.first_unit_start_date
           order by wrs.first_unit_start_date desc;
         end if ;
         /* End for Bug#5030360 (fp5201404) */
        end if;--issue return stmt
      --This case occurs when the assembly is processed online and the components background. This
      --can happen through the desktop form since there are 2 profiles, one governing assy txn mode
      --and the other governing component txn mode if the assy mode is online...
      else --l_mmttCount == 0 => assy row is in MMT
        if(p_issueRec.txnActionID in (wip_constants.isscomp_action, wip_constants.issnegc_action)) then
          select wro.repetitive_schedule_id,
                 wro.quantity_per_assembly * sum(mmta.primary_quantity) schedQty
            bulk collect into x_schedTbl, x_qtyTbl
            from wip_repetitive_schedules wrs,
                 wip_requirement_operations wro,
                 mtl_material_txn_allocations mmta,
                 mtl_material_transactions mmt
           where mmta.transaction_id = mmt.transaction_id
             and mmt.completion_transaction_id = p_issueRec.cplTxnID
             and mmt.transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action)
             and wro.wip_entity_id = p_issueRec.wipEntityID
             and wro.repetitive_schedule_id = mmta.repetitive_schedule_id
             and wro.repetitive_schedule_id = wrs.repetitive_schedule_id
             and wro.inventory_item_id = p_issueRec.itemID
             and wro.operation_seq_num = p_issueRec.opSeqNum
             and wro.wip_supply_type = p_issueRec.wipSupplyType
             and wro.quantity_per_assembly <> 0
             and sign(wro.required_quantity) = p_issueRec.negReqFlag
             /* and wrs.status_type in (3,4) */   /* bug3338344 removed for bug5137228 (fp5015515) */
           group by wro.repetitive_schedule_id, wro.quantity_per_assembly, wrs.first_unit_start_date
           order by wrs.first_unit_start_date;
        else --return txn
          select wro.repetitive_schedule_id,
                 wro.quantity_per_assembly * sum(mmta.primary_quantity) schedQty
            bulk collect into x_schedTbl, x_qtyTbl
            from wip_repetitive_schedules wrs,
                 wip_requirement_operations wro,
                 mtl_material_txn_allocations mmta,
                 mtl_material_transactions mmt
           where mmta.transaction_id = mmt.transaction_id
             and mmt.completion_transaction_id = p_issueRec.cplTxnID
             and mmt.transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action)
             and wro.wip_entity_id = p_issueRec.wipEntityID
             and wro.repetitive_schedule_id = mmta.repetitive_schedule_id
             and wro.repetitive_schedule_id = wrs.repetitive_schedule_id
             and wro.inventory_item_id = p_issueRec.itemID
             and wro.operation_seq_num = p_issueRec.opSeqNum
             and wro.wip_supply_type = p_issueRec.wipSupplyType
             and wro.quantity_per_assembly <> 0
             and sign(wro.required_quantity) = p_issueRec.negReqFlag
             /* and wrs.status_type in (3,4)*/    /* bug3338344 removed for bug5137228 (fp5015515) */
           group by wro.repetitive_schedule_id, wro.quantity_per_assembly, wrs.first_unit_start_date
           order by wrs.first_unit_start_date desc;
        end if;--issue/return stmt
      end if; --MMTT/MMT stmt
    end if; --supply type stmt
    x_returnStatus := fnd_api.g_ret_sts_success;
    --only errors that can occur are sql exceptions. let those fall through to the calling fn
  end populateRepScheds;

  procedure processRepetitive(p_issueRec IN OUT NOCOPY wip_mtlTempProc_grp.comp_rec_t,
                              x_returnStatus OUT NOCOPY VARCHAR2) IS
   /* Fix for bug 4390097: Rounding l_remQty to prevent wrong quantities in MMTA */
  --  l_remQty NUMBER := round(abs(p_issueRec.primaryQty),5);
  /*Fix for bug 5374443: Need not round l_remQty. It contains MMTT primary quantity which is already rounded to 6 decimals. */
  l_remQty NUMBER := abs(p_issueRec.primaryQty);
  l_schedID NUMBER;
  l_excessQtySchedID NUMBER;--if not enough open qty for txn, excess qty goes to this sched
  l_schedQty NUMBER;
  l_issueQty NUMBER;
  l_params wip_logger.param_tbl_t;
  l_errMsg VARCHAR2(240);
  l_returnStatus VARCHAR2(1);
  l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  l_schedTbl num_tbl_t;--TABLE OF NUMBER;
  l_qtyTbl num_tbl_t;--TABLE OF NUMBER;
  l_mmta_schedIdTbl num_tbl_t := num_tbl_t();
  l_mmta_priQtyTbl num_tbl_t := num_tbl_t();
  l_mmta_txnQtyTbl num_tbl_t := num_tbl_t();
  l_mmtaRowCount NUMBER := 0;

  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      fillIssueParamTbl(p_issueRec => p_issueRec,
                        x_params => l_params);
      wip_logger.entryPoint(p_procName => 'wip_mtlProc_priv.processRepetitive',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('remaining qty:' || l_remQty, l_returnStatus);
    end if;

    populateRepScheds(p_issueRec => p_issueRec,
                      x_schedTbl => l_schedTbl,
                      x_qtyTbl => l_qtyTbl,
                      x_returnStatus => x_returnStatus);

    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(p_issueRec.mtlTxnID is null) then
      update mtl_material_transactions_temp
         set material_allocation_temp_id = mtl_material_transactions_s.nextval
       where transaction_temp_id = p_issueRec.txnTmpID returning material_allocation_temp_id into p_issueRec.mtlTxnID;
    end if;

    --if over-issuing or returning, apply excess qty to the last schedule
    if(l_schedTbl.count > 0) then
      l_excessQtySchedID := l_schedTbl(l_schedTbl.count);
    end if;

    for i in 1..l_schedTbl.count LOOP
      exit when l_remQty = 0;

      -- Fix for Bug#4390097. Round l_qtyTbl(i) as corresponding MMTT qty is
      -- already rounded to 5 decimal precision.
      --l_qtyTbl(i) := round(l_qtyTbl(i), 5) ;

      -- Fix for Bug#5374443 : Round l_qtyTbl(i) to 6 decimals as corresponding MMTT qty is rounded to 6 decimal precision.
        l_qtyTbl(i) := round(l_qtyTbl(i),6);

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('start loop', l_returnStatus);
        wip_logger.log('  sched_id:' || l_schedTbl(i), l_returnStatus);
        wip_logger.log('  sched_qty:' || l_qtyTbl(i), l_returnStatus);
      end if;

      if(round(l_qtyTbl(i), wip_constants.inv_max_precision) = 0) then
        goto END_OF_LOOP;
      end if;
      if(l_remQty > abs(l_qtyTbl(i))) then
        l_remQty := l_remQty - abs(l_qtyTbl(i));
        l_issueQty := sign(p_issueRec.primaryQty) * abs(l_qtyTbl(i));
      else
        l_issueQty := l_remQty * sign(p_issueRec.primaryQty);
        l_remQty := 0;
      end if;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('    l_remQty:' || l_remQty, l_returnStatus);
        wip_logger.log('    l_issQty:' || l_issueQty, l_returnStatus);
        wip_logger.log('    sign(priQty):' || sign(p_issueRec.primaryQty), l_returnStatus);
      end if;

      if(mod(l_mmtaRowCount, g_extendAmount) = 0) then
        l_mmta_schedIdTbl.extend(g_extendAmount);
        l_mmta_priQtyTbl.extend(g_extendAmount);
        l_mmta_txnQtyTbl.extend(g_extendAmount);
      end if;
      l_mmtaRowCount := l_mmtaRowCount + 1;
      l_mmta_schedIdTbl(l_mmtaRowCount) := l_schedTbl(i);
      l_mmta_priQtyTbl(l_mmtaRowCount) := -1 * l_issueQty; --make qty relative to inv for quantities
      l_mmta_txnQtyTbl(l_mmtaRowCount) := round(-1 * (l_issueQty/p_issueRec.primaryQty) * p_issueRec.txnQty, wip_constants.inv_max_precision);

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('inserted sched:' || l_schedTbl(i) || '; qty:' || l_mmta_priQtyTbl(l_mmtaRowCount), l_returnStatus);
      end if;

      processTxn(p_issueRec => p_issueRec,
                 p_issueQty => l_issueQty, --override p_issueRec.primaryQty
                 p_repSchedID => l_schedTbl(i),
                 x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'processTxn for schedule ' || l_schedTbl(i) || ' failed.';
        raise fnd_api.g_exc_unexpected_error;
      end if;
      <<END_OF_LOOP>>
      null;
    end loop;
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('remQty:' || l_remQty, l_returnStatus);
    end if;

    if(l_remQty > 0) then --should only happen for push txns
      if(l_excessQtySchedID is null) then
        /* Fix for bug 5373061: Added status_type and date_released checks to pick valid schedules only */
        select repetitive_schedule_id --the requirement doesn't exist. Find the earliest open schedule
          into l_excessQtySchedID
          from wip_repetitive_schedules wrs
         where wrs.wip_entity_id = p_issueRec.wipEntityID
           and wrs.line_id = p_issueRec.repLineID
           and wrs.status_type in (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG)
           and wrs.date_released < p_issueRec.txnDate
           and first_unit_start_date = (select min(first_unit_start_date)
                                          from wip_repetitive_schedules
                                         where wip_entity_id =  p_issueRec.wipEntityID
                                           and line_id = p_issueRec.repLineID
                                           and status_type in (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG)
                                           and date_released < p_issueRec.txnDate)

         order by wrs.first_unit_start_date;
      end if;

      if(l_mmtaRowCount = 0) then
        l_mmta_schedIdTbl.extend(g_extendAmount);
        l_mmta_priQtyTbl.extend(g_extendAmount);
        l_mmta_txnQtyTbl.extend(g_extendAmount);
        l_mmtaRowCount := l_mmtaRowCount + 1;
      end if;

      l_mmta_schedIdTbl(l_mmtaRowCount) := l_excessQtySchedID;
      l_issueQty := l_remQty * sign(p_issueRec.primaryQty);--first get the sign correct

       /* Fix for bug 5729726: Add excess quantity to the existing allocation quantity, if any, instead of over-writing the
       existing allocation quantity with the excess quantity. This will prevent incorrect allocation and MMT-MMTA Mismatch */
       l_mmta_priQtyTbl(l_mmtaRowCount) := nvl(l_mmta_priQtyTbl(l_mmtaRowCount),0) - l_issueQty;--make qty relative to inventory
       l_mmta_txnQtyTbl(l_mmtaRowCount) := nvl(l_mmta_txnQtyTbl(l_mmtaRowCount),0) + round(-1 * (l_issueQty/p_issueRec.primaryQty) * p_issueRec.txnQty, wip_constants.inv_max_precision);

--      l_mmta_priQtyTbl(l_mmtaRowCount) := -1 * l_issueQty;--make qty relative to inventory
--      l_mmta_txnQtyTbl(l_mmtaRowCount) := round(-1 * (l_issueQty/p_issueRec.primaryQty) * p_issueRec.txnQty, wip_constants.inv_max_precision);
	/*End of fix 5729726:*/

      processTxn(p_issueRec => p_issueRec,
                 p_issueQty => l_issueQty,
                 p_repSchedID => l_excessQtySchedID,
                 x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'processTxn for the first schedule ' || l_excessQtySchedID || ' failed.';
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('rowcount ' || l_mmtaRowCount || ' rows.', l_returnStatus);
    end if;

    --now trim unused rows
    l_mmta_schedIdTbl.trim(g_extendAmount - mod(l_mmtaRowCount, g_extendAmount));
    l_mmta_priQtyTbl.trim(g_extendAmount - mod(l_mmtaRowCount, g_extendAmount));
    l_mmta_txnQtyTbl.trim(g_extendAmount - mod(l_mmtaRowCount, g_extendAmount));


    forall i in 1..l_mmta_schedIdTbl.count
      insert into mtl_material_txn_allocations
        (transaction_id,
         repetitive_schedule_id,
         organization_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         primary_quantity,
         transaction_quantity,
         transaction_date)
      values
        (p_issueRec.mtlTxnID,
         l_mmta_schedIdTbl(i),
         p_issueRec.orgID,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         fnd_global.conc_login_id,
         fnd_global.conc_request_id,
         fnd_global.prog_appl_id,
         fnd_global.conc_program_id,
         sysdate,
         l_mmta_priQtyTbl(i),
         l_mmta_txnQtyTbl(i),
         p_issueRec.txnDate);

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log(SQL%ROWCOUNT || ' row inserted into MMTA', l_returnStatus);
      wip_logger.log('txn id' || p_issueRec.mtlTxnID, l_returnStatus);
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processRepetitive',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success.',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processRepetitive',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mtlProc_priv',
                              p_procedure_name => 'processRepetitive',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processRepetitive',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end processRepetitive;


  procedure writeError(p_txnTmpID IN NUMBER) is
    l_errCode VARCHAR2(2000);
    l_errExpl VARCHAR2(2000);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_returnStatus VARCHAR(1);
  begin
    wip_utilities.get_message_stack(p_delete_stack => fnd_api.g_false,
                                    p_msg => l_errExpl);
    fnd_message.set_name('WIP', 'MTL_PROC_FAIL');
    l_errCode := fnd_message.get;
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('writeError: tempID is ' || p_txnTmpID, l_returnStatus);
      wip_logger.log('writeError: errCode is ' ||l_errCode, l_returnStatus);
      wip_logger.log('writeError: errExpl is ' ||l_errExpl, l_returnStatus);
    end if;
    update mtl_material_transactions_temp
       set error_code = substr(l_errCode, 1, 240),
           error_explanation = substr(l_errExpl, 1, 240),
           process_flag = 'E'
     where transaction_temp_id = p_txnTmpID;
  exception
    when others then
      null;
  end writeError;

  PROCEDURE processOATxn(p_mtl_header_id  IN        NUMBER,
                         x_returnStatus  OUT NOCOPY VARCHAR2) IS

    l_log_level     NUMBER := fnd_log.g_current_runtime_level;
    l_ret_value     NUMBER;
    l_error_msg     VARCHAR2(1000);
    l_process_phase VARCHAR2(3);
    l_return_status VARCHAR(1);
    l_params        wip_logger.param_tbl_t;
  BEGIN
    l_process_phase := '1';
    IF (l_log_level <= wip_constants.trace_logging) THEN
      l_params(1).paramName   := 'p_mtl_header_id';
      l_params(1).paramValue  :=  p_mtl_header_id;
      wip_logger.entryPoint(p_procName     => 'wip_mtlProc_priv.processOATxn',
                            p_params       => l_params,
                            x_returnStatus => l_return_status);
    END IF;
    l_process_phase := '2';
    SAVEPOINT s_oa_txn_proc;
    -- Validate and move records from MTI to MMTT.
    wip_mtlTempProc_priv.validateInterfaceTxns(
      p_txnHdrID      => p_mtl_header_id,
      p_addMsgToStack => fnd_api.g_true, -- So that we can display to user
      p_rollbackOnErr => fnd_api.g_false,
      x_returnStatus  => x_returnStatus);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;

    l_process_phase := '3';
    wip_mtlTempProc_priv.processTemp
     (p_initMsgList   => fnd_api.g_true,
      p_txnHdrID      => p_mtl_header_id,
      p_txnMode       => WIP_CONSTANTS.ONLINE,
      x_returnStatus  => x_returnStatus,
      x_errorMsg      => l_error_msg);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_error_msg);
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    END IF;
    l_process_phase := '4';
    x_returnStatus := fnd_api.g_ret_sts_success;

    -- write to the log file
    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processOATxn',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure complete',
                           x_returnStatus => l_return_status);
    END IF;
    -- close log file
    wip_logger.cleanUp(x_returnStatus => l_return_status);
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO SAVEPOINT s_oa_txn_proc;
      x_returnStatus := fnd_api.g_ret_sts_error;

      IF (l_log_level <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(p_procName => 'wip_mtlProc_priv.processOATxn',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'wip_cplProc_priv.processOATxn failed : '
                                     || l_process_phase,
                             x_returnStatus => l_return_status);
      END IF;
      -- close log file
      wip_logger.cleanUp(x_returnStatus => l_return_status);
    WHEN others THEN
      ROLLBACK TO SAVEPOINT s_oa_txn_proc;
      x_returnStatus := fnd_api.g_ret_sts_error;
      l_error_msg := ' unexpected error: ' || SQLERRM || 'SQLCODE = ' ||
                     SQLCODE;

      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_error_msg);
      fnd_msg_pub.add;

      IF (l_log_level <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processOATxn',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_error_msg || ' : ' || l_process_phase,
                             x_returnStatus => l_return_status);
      END IF;
      -- close log file
      wip_logger.cleanUp(x_returnStatus => l_return_status);
  END processOATxn;

end wip_mtlProc_priv;

/
