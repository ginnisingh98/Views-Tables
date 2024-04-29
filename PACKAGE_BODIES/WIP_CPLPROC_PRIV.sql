--------------------------------------------------------
--  DDL for Package Body WIP_CPLPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_CPLPROC_PRIV" as
/* $Header: wipcplpb.pls 120.12.12010000.2 2009/06/24 18:32:51 ntangjee ship $ */

  ---------------
  --private types
  ---------------
  type num_tbl_t is table of number;
  type char_tbl_t is table of varchar2(3);
  type rowid_tbl_t is table of varchar2(18);
  type date_tbl_t is table of date;

  type schedule_rec_t is record(repSchedID NUMBER,
                                bomRev VARCHAR2(3),
                                startQty NUMBER,
                                toMoveQty NUMBER);

  ----------------------
  --forward declarations
  ----------------------
  procedure fillCplParamTbl(p_cplRec IN completion_rec_t,
                            x_params OUT NOCOPY wip_logger.param_tbl_t);

  procedure processRepetitive(p_cplRec IN completion_rec_t,
                              p_txnTmpID IN NUMBER,
                              x_returnStatus OUT NOCOPY VARCHAR2);

  procedure processDiscrete(p_cplRec IN completion_rec_t,
                            p_txnTmpID IN NUMBER,
                            x_serialStartOp OUT NOCOPY NUMBER,
                            x_returnStatus OUT NOCOPY VARCHAR2);

  ---------------------------
  --public/private procedures
  ---------------------------
  procedure processTemp(p_txnTmpID IN NUMBER,
                        p_initMsgList IN VARCHAR2,
                        p_endDebug IN VARCHAR2,
                        x_returnStatus OUT NOCOPY VARCHAR2) is

    l_cplRec completion_rec_t;
    l_wipEntityType NUMBER;
    l_params wip_logger.param_tbl_t;
    l_returnStatus VARCHAR2(1);
    l_retValue VARCHAR2(10);
    l_msgCount NUMBER;
    l_errMsg VARCHAR2(240);
    l_msgData VARCHAR2(4000);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_serialStartOp NUMBER;

    /* Bug 5708242 */
    l_primaryCostMethod NUMBER;
    l_errNum            NUMBER;
    l_cstRetVal         NUMBER;
  begin
    savepoint wipcplpb20;
    x_returnStatus := fnd_api.g_ret_sts_success;
    if(fnd_api.to_boolean(p_initMsgList)) then
      fnd_msg_pub.initialize;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnTmpID';
      l_params(1).paramValue := p_txnTmpID;
      wip_logger.entryPoint(p_procName => 'wip_cplProc_priv.processTemp',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    select wip_entity_type,
           organization_id,
           transaction_source_id,
           repetitive_line_id,
           inventory_item_id, --5
           transaction_action_id,
           primary_quantity, --qty is relative to inv, but is also relative to wip in this case (completions are positive)
           transaction_quantity,
           transaction_date,
           completion_transaction_id, --10
           kanban_card_id,
           qa_collection_id,
           operation_seq_num,
           revision, --14
           transaction_header_id,
           transaction_status,
           overcompletion_transaction_id,
           overcompletion_primary_qty,
           last_updated_by,
           created_by,
           nvl(content_lpn_id, lpn_id),
           transaction_mode,
           move_transaction_id,
           material_allocation_temp_id
      into l_cplRec.wipEntityType,
           l_cplRec.orgID,
           l_cplRec.wipEntityID,
           l_cplRec.repLineID,
           l_cplRec.itemID, --5
           l_cplRec.txnActionID,
           l_cplRec.priQty,
           l_cplRec.txnQty,
           l_cplRec.txnDate,
           l_cplRec.cplTxnID, --10
           l_cplRec.kanbanCardID,
           l_cplRec.qaCollectionID,
           l_cplRec.lastOpSeq,
           l_cplRec.revision,--14
           l_cplRec.txnHdrID,
           l_cplRec.txnStatus,
           l_cplRec.overCplTxnID,
           l_cplRec.overCplPriQty,
           l_cplRec.lastUpdBy,
           l_cplRec.createdBy,
           l_cplRec.lpnID,
           l_cplRec.txnMode,
           l_cplRec.movTxnID,
           l_cplRec.mtlAlcTmpID
       from mtl_material_transactions_temp
     where transaction_temp_id = p_txnTmpID;

    if(l_cplRec.qaCollectionID is not null) then
      qa_result_grp.enable(p_api_version => 1.0,
                           p_validation_level => 0,
                           p_collection_id => l_cplRec.qaCollectionID,
                           p_return_status => l_returnStatus,
                           p_msg_count => l_msgCount,
                           p_msg_data => l_errMsg);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'QA error: ' || l_errMsg;
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(nvl(l_cplRec.overCplPriQty, 0) <> 0) then
      --ensure the overcompletion txn id is populated
      if(l_cplRec.overCplTxnID is null) then
        update mtl_material_transactions_temp
           set overcompletion_transaction_id = wip_transactions_s.nextval
         where transaction_temp_id = p_txnTmpID returning overcompletion_transaction_id into l_cplRec.overCplTxnID;

      end if;

      --if the txn mode is online, the form does the over-cpl move as it must do one move for all the
      --cpl records in the multi-row block. In all other cases, the move is done here.
      if(l_cplRec.txnMode <> wip_constants.online) then
        processOverCpl(p_cplRec => l_cplRec,
                       x_returnStatus => x_returnStatus);
      end if;

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'overcompletion processing errored';
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(l_cplRec.wipEntityType = wip_constants.repetitive) then
      processRepetitive(p_cplRec => l_cplRec,
                        p_txnTmpID => p_txnTmpID,
                        x_returnStatus => x_returnStatus);

    else
      processDiscrete(p_cplRec => l_cplRec,
                      p_txnTmpID => p_txnTmpID,
                      x_serialStartOp => l_serialStartOp,
                      x_returnStatus => x_returnStatus);

    end if;
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      l_errMsg := 'entity specific processing failed';
      raise fnd_api.g_exc_unexpected_error;
    end if;

    /* Fix for bug 5708242: Moved the call to cstpacms.validate_move_snap_to_temp() from
                wipmtivb.pls to this place, to avoid intermittent commits, and to facilitate proper
                rollback into CST_COMP_SNAP_INTERFACE if exception occurs */

     select primary_cost_method
     into   l_primaryCostMethod
     from   mtl_parameters
     where  organization_id = l_cplRec.orgID;

     if (l_primaryCostMethod in (2,5,6)) then
       l_cstRetVal := 1;
       l_cstRetVal := cstpacms.validate_move_snap_to_temp(
                          p_txnTmpID,
                          p_txnTmpID,
                          1, -- for Inventory interface
                          l_cplRec.priQty,
                          l_errNum,
                          l_retValue,
                          l_errMsg);
       if(l_cstRetVal <> 1) then
         /* Error message will be populated by the procedure. Just raise exception. */
         raise fnd_api.g_exc_unexpected_error;
       end if;
     end if;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processTemp',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success.',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
    if(fnd_api.to_boolean(p_endDebug)) then
      wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when no_data_found then
      rollback to wipcplpb20;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processTemp',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'no data found',
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      fnd_message.set_name('WIP', 'INVALID_MMTT_TEMP_ID');
      fnd_msg_pub.add;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(SQLERRM, l_returnStatus);
      end if;
    when fnd_api.g_exc_error then --could not derive all lot/serial info for components
      --do *not* rollback. leave the component records in mmtt/mtlt for the caller to query/complete
      --when the record is processed again, only the material processing and inv txn will occur
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processTemp',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'need to collect l/s info',
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when fnd_api.g_exc_unexpected_error then
      rollback to wipcplpb20;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processTemp',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      rollback to wipcplpb20;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_cplProc_priv',
                              p_procedure_name => 'processTemp',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processTemp',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end processTemp;

  procedure processDiscrete(p_cplRec IN completion_rec_t,
                            p_txnTmpID IN NUMBER,
                            x_serialStartOp OUT NOCOPY NUMBER,
                            x_returnStatus OUT NOCOPY VARCHAR2) is
    l_rowid ROWID;
    l_qtyCompleted NUMBER;
    l_jobStatus NUMBER;
    l_cplDate DATE;
    l_toMoveQty NUMBER;
    l_msgCount NUMBER;
    l_paramCount NUMBER;
    l_params wip_logger.param_tbl_t;
    l_errMsg VARCHAR2(240);
    l_msgTxt VARCHAR2(2000);
    l_returnStatus VARCHAR2(1);
    l_qtyAvailToComplete NUMBER;
    l_nullObj system.wip_component_tbl_t := null;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_docType NUMBER;
    oc_primary_qty NUMBER;   -- Fix BUG 4869979 (FP 5107900)
    -- Fixed bug 3678776. We should allow user to overreturn assembly back
    -- to non-standard job.
    l_jobType NUMBER;
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      fillCplParamTbl(p_cplRec => p_cplRec,
                      x_params => l_params);
      l_paramCount := l_params.count;
      l_params(l_paramCount + 1).paramName := 'p_txnTmpID';
      l_params(l_paramCount + 1).paramValue := p_txnTmpID;

      wip_logger.entryPoint(p_procName => 'wip_cplProc_priv.processDiscrete',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    select rowid,
           quantity_completed,
           start_quantity - quantity_scrapped - quantity_completed, --remaining qty to complete
           serialization_start_op,
           job_type,
           date_completed
      into l_rowid,
           l_qtyCompleted,
           l_qtyAvailToComplete,
           x_serialStartOp,
           l_jobType,
           l_cplDate
      from wip_discrete_jobs
     where wip_entity_id = p_cplRec.wipEntityID
      for update of quantity_completed nowait;

    if(p_cplRec.txnActionID = wip_constants.cplassy_action) then
      if(p_cplRec.priQty >= l_qtyAvailToComplete) then
        l_jobStatus := wip_constants.comp_chrg;
        l_cplDate := nvl(l_cplDate, p_cplRec.txnDate); --Bug 4864403 Only change date_completed if it is null
      end if;
      --allocate completions to sales orders
      l_errMsg := 'SO allocation failed.'; --set message in case it fails
      x_returnStatus := fnd_api.g_ret_sts_success;
      if(p_cplRec.lpnID is null) then
        wip_so_reservations.allocate_completion_to_so(
          p_organization_id       => p_cplRec.orgID,
          p_wip_entity_id         => p_cplRec.wipEntityID,
          p_inventory_item_id     => p_cplRec.itemID,
          p_transaction_header_id => p_cplRec.cplTxnID,
          p_txn_temp_id           => p_txnTmpID,
          x_return_status         => x_returnStatus,
          x_msg_count             => l_msgCount,
          x_msg_data              => l_errMsg);
      end if;

      --if so allocation went ok, then update the kanban card if it exists
      if(x_returnStatus = fnd_api.g_ret_sts_success and
         p_cplRec.kanbanCardID is not null) then
        l_errMsg := 'Kanban update failed.'; --set message in case it fails
        if(p_cplRec.wipEntityType = wip_constants.lotbased) then
          l_docType := 8;
        else
          l_docType := inv_kanban_pvt.g_doc_type_discrete_job;
        end if;

        inv_kanban_pvt.UPDATE_CARD_SUPPLY_STATUS
          (p_kanban_card_id     => p_cplRec.kanbanCardID,
           p_supply_status      => inv_kanban_pvt.g_supply_status_full,
           p_document_type      => l_docType,
           p_document_header_id => p_cplRec.wipEntityID,
           p_document_detail_id => null,
           p_replenish_quantity => p_cplRec.priQty,
           x_return_status      => x_returnStatus);
      end if;
    else --a return
    /* Bug 4864403 Change Status and date_completed when quantity_completed is less than start_quantity*/
      if(l_qtyAvailToComplete > p_cplRec.priQty) then
        l_jobStatus := wip_constants.released; --make sure the job status gets flipped back to released
        l_cplDate := NULL;
      end if;
      -- Fixed bug 3678776. We should allow user to overreturn assembly back
      -- to non-standard job.
      if(abs(p_cplRec.priQty) > l_qtyCompleted AND
         l_jobType = WIP_CONSTANTS.STANDARD) then
        fnd_message.set_name('WIP', 'WIP_LESS_OR_EQUAL');
        fnd_message.set_token('ENTITY1', 'total txn qty-cap', true);
        fnd_message.set_token('ENTITY2', 'job complete quantity', true);
        fnd_msg_pub.add;
        l_errMsg := 'not enough quantity to return';
        raise fnd_api.g_exc_unexpected_error;
      end if;
      --return the so reservation to wip
      l_errMsg := 'SO return reservation failed'; --set message in case SO return failed
      wip_so_reservations.return_reservation_to_wip(
        p_organization_id       => p_cplRec.orgID,
        p_wip_entity_id         => p_cplRec.wipEntityID,
        p_inventory_item_id     => p_cplRec.itemID,
        p_transaction_header_id => p_cplRec.cplTxnID,
        p_txn_temp_id           => p_txnTmpID,
        x_return_status         => x_returnStatus,
        x_msg_count             => l_msgCount,
        x_msg_data              => l_errMsg);
    end if;
    --if any of the above failed, make sure the error status is unexpected error and fail
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      raise fnd_api.g_exc_unexpected_error;
    end if;

    update wip_discrete_jobs --increase the qty completed
      set quantity_completed = l_qtyCompleted + p_cplRec.priQty, --remember txn qty is negative for returns
          date_completed = l_cplDate,
          status_type = nvl(l_jobStatus, status_type),
          last_updated_by = fnd_global.user_id,
          last_update_date = sysdate,
          request_id = fnd_global.conc_request_id,
          program_application_id = fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where rowid = l_rowid;

    --if there exists a routing, lock the last operation
    if(p_cplRec.lastOpSeq > 0) then
      select quantity_waiting_to_move, rowid
        into l_toMoveQty, l_rowid
        from wip_operations
       where wip_entity_id = p_cplRec.wipEntityID
         and operation_seq_num = p_cplRec.lastOpSeq
         for update of quantity_waiting_to_move nowait;

      if(l_toMoveQty - p_cplRec.priQty < 0) then
        fnd_message.set_name('WIP', 'WIP_LESS_QTY');
        fnd_msg_pub.add;
        l_errMsg := 'not enough qty in to move of last op';
        raise fnd_api.g_exc_unexpected_error;
      end if;
      update wip_operations --lower the quantity available to complete
         set quantity_waiting_to_move = quantity_waiting_to_move - p_cplRec.priQty,
             date_last_moved = decode(p_cplRec.txnActionID, wip_constants.cplassy_action, p_cplRec.txnDate, date_last_moved),
             last_updated_by = fnd_global.user_id,
             last_update_date = sysdate,
             request_id = fnd_global.conc_request_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id = fnd_global.conc_program_id,
             program_update_date = sysdate
       where rowid = l_rowid;
    else -- Fix BUG 4869979 (FP 5107900)
         -- If routing does not exist, validate if quantity is available on the job for completion

       if (p_cplRec.overCplPriQty is null or p_cplRec.overCplPriQty < 0) then
           oc_primary_qty:= 0;
       else
           oc_primary_qty := p_cplRec.overCplPriQty;
       end if;
         if p_cplRec.priQty - abs(l_qtyAvailToComplete) - oc_primary_qty > 0 then
            fnd_message.set_name('WIP', 'WIP_LESS_QTY');
            fnd_msg_pub.add;
            l_errMsg := 'Quantity required to complete this transaction no longer available';
            raise fnd_api.g_exc_unexpected_error;

         end if;
     -- end of BUG 4869979 (FP 5107900)

    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processDiscrete',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success.',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processDiscrete',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when wip_constants.records_locked then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processDiscrete',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'records were locked',
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      fnd_message.set_name('INV', 'INV_WIP_WORK_ORDER_LOCKED');
      fnd_msg_pub.add;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_cplProc_priv',
                              p_procedure_name => 'processDiscrete',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processDiscrete',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end processDiscrete;



  procedure processRepetitive(p_cplRec IN completion_rec_t,
                              p_txnTmpID IN NUMBER,
                              x_returnStatus OUT NOCOPY VARCHAR2) is

    l_lastOpSeq NUMBER;
    l_firstSchedID NUMBER;
    l_lastSchedID NUMBER;
    l_schedRec schedule_rec_t;
    l_status NUMBER;
    l_params wip_logger.param_tbl_t;
    l_paramCount NUMBER;
    l_returnStatus VARCHAR2(1);
    l_errMsg VARCHAR2(240);
    l_nullObj system.wip_component_tbl_t := null;
    --the following  field is used to store values for a final update to MMTA if not enough open qty can be found
    --in the existing schedules and we need to allocate more qty to the first/last schedule after the main loop is done
    l_finalRepSchedID NUMBER;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_scrapQty NUMBER;

    --type for below cursor
    type schedule_recTbl_t is record(schedID num_tbl_t,
                                     bomRev char_tbl_t,
                                     startQty num_tbl_t,
                                     cpldQty num_tbl_t, --completed qty
                                     toMoveQty num_tbl_t,
                                     preAlcQty num_tbl_t,
                                     wrsRowID rowid_tbl_t,
                                     woRowID rowid_tbl_t);

    cursor c_preAllocs(v_lastOpSeq NUMBER) is
      select wrs.repetitive_schedule_id,
             wrs.bom_revision,
             wrs.daily_production_rate * wrs.processing_work_days,
             wrs.quantity_completed,
             wo.quantity_waiting_to_move,
             wmat.primary_quantity,
             rowidtochar(wrs.rowid),
             rowidtochar(wo.rowid)
        from wip_operations wo,
             wip_repetitive_schedules wrs,
             wip_mtl_allocations_temp wmat
       where wrs.wip_entity_id = p_cplRec.wipEntityID
         and wrs.line_id = p_cplRec.repLineID
         and wrs.status_type in (wip_constants.released, wip_constants.comp_chrg)
         and wrs.repetitive_schedule_id = wo.repetitive_schedule_id (+)
         and wrs.wip_entity_id = wo.wip_entity_id (+)
         and v_lastOpSeq = wo.operation_seq_num (+)
         and wrs.repetitive_schedule_id = wmat.repetitive_schedule_id
         and wmat.transaction_temp_id = p_txnTmpID
       order by wrs.first_unit_start_date
         for update of wo.quantity_completed, wrs.quantity_completed nowait;

    l_schedRecTbl schedule_recTbl_t;
    l_newSchedQty NUMBER;
    l_cplStatus NUMBER;
    l_rollFwdSuccess NUMBER;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      fillCplParamTbl(p_cplRec => p_cplRec,
                      x_params => l_params);
      l_paramCount := l_params.count;
      l_params(l_paramCount + 1).paramName := 'p_txnTmpID';
      l_params(l_paramCount + 1).paramValue := p_txnTmpID;

      wip_logger.entryPoint(p_procName => 'wip_cplProc_priv.processRepetitive',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;


    if(p_cplRec.txnActionID = wip_constants.cplassy_action AND
       p_cplRec.kanbanCardID is not null) then
      inv_kanban_pvt.update_card_supply_status
        (p_kanban_card_id     => p_cplRec.kanbanCardID,
         p_supply_status      => inv_kanban_pvt.g_supply_status_full,
         p_document_type      => inv_kanban_pvt.g_doc_type_rep_schedule,
         p_document_header_id => p_cplRec.wipEntityID,
         p_document_detail_id => null,
         p_replenish_quantity => p_cplRec.priQty,
         x_return_status      => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        l_errMsg := 'Kanban update failed.'; --set message in case it fails
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(p_cplRec.lastOpSeq is null or p_cplRec.lastOpSeq < 0) then
      l_lastOpSeq := 1; --if no rtg, components have op_seq = 1
    else
      l_lastOpSeq := p_cplRec.lastOpSeq;
    end if;
    open c_preAllocs(v_lastOpSeq => l_lastOpSeq);
    fetch c_preAllocs
      bulk collect into l_schedRecTbl.schedID,
                        l_schedRecTbl.bomRev,
                        l_schedRecTbl.startQty,
                        l_schedRecTbl.cpldQty,
                        l_schedRecTbl.toMoveQty,
                        l_schedRecTbl.preAlcQty,
                        l_schedRecTbl.wrsRowID,
                        l_schedRecTbl.woRowID;
    close c_preAllocs;

    for i in 1..l_schedRecTbl.schedID.count loop
      select nvl(sum(quantity_scrapped), 0)
        into l_scrapQty
        from wip_operations
       where repetitive_schedule_id = l_schedRecTbl.schedID(i);

      if(l_schedRecTbl.woRowID(i) is not null) then
        update wip_operations
           set quantity_waiting_to_move = quantity_waiting_to_move - l_schedRecTbl.preAlcQty(i),
               date_last_moved = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_date = sysdate,
               request_id = fnd_global.conc_request_id,
               program_application_id = fnd_global.prog_appl_id,
               program_id = fnd_global.conc_program_id,
               program_update_date = sysdate
         where rowid = chartorowid(l_schedRecTbl.woRowID(i))
        returning quantity_waiting_to_move into l_newSchedQty;

        if(l_newSchedQty < 0) then
          --add check for pending txns here
          fnd_message.set_name('WIP', 'WIP_LESS_QTY');
          fnd_msg_pub.add;
          l_errMsg := 'not enough qty in to move of last op';
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('schedID' || l_schedRecTbl.schedID(i), l_returnStatus);
        wip_logger.log('startQty ' || l_schedRecTbl.startQty(i), l_returnStatus);
        wip_logger.log('cpldQty ' || l_schedRecTbl.cpldQty(i), l_returnStatus);
        wip_logger.log('scrapQty ' || l_scrapQty, l_returnStatus);
        wip_logger.log('preAlcQty ' || l_schedRecTbl.preAlcQty(i), l_returnStatus);
      end if;

      if(l_schedRecTbl.startQty(i) - l_schedRecTbl.cpldQty(i) - l_scrapQty <= l_schedRecTbl.preAlcQty(i) AND
         p_cplRec.txnActionID = wip_constants.cplassy_action) then
        l_status := wip_constants.comp_chrg;
      else
        l_status := wip_constants.released;
      end if;

      update wip_repetitive_schedules
         set quantity_completed = quantity_completed + l_schedRecTbl.preAlcQty(i),
             status_type = l_status,
             last_updated_by = fnd_global.user_id,
             last_update_date = sysdate,
             request_id = fnd_global.conc_request_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id = fnd_global.conc_program_id,
             program_update_date = sysdate
       where rowid = chartorowid(l_schedRecTbl.wrsRowID(i));

      if(l_status = wip_constants.comp_chrg) then
        wip_repetitive_utilities.roll_forward_cover(p_closed_sched_id => l_schedRecTbl.schedID(i),
                                                    p_rollfwd_sched_id => null, --doesn't seem to be in use
                                                    p_rollfwd_type     => wip_constants.roll_complete,
                                                    p_org_id           => p_cplRec.orgID,
                                                    p_update_status    => wip_constants.yes,
                                                    p_success_flag     => l_rollFwdSuccess,
                                                    p_error_msg        => l_errMsg);
        if(l_rollFwdSuccess <> wip_constants.yes) then
          --            fnd_msg_pub.add; --assume error message is still current
          x_returnStatus := fnd_api.g_ret_sts_unexp_error;
          l_errMsg := 'roll forward failed for schedule ' || l_schedRec.repSchedID;
        end if;
      end if;
    end loop;
    insert into mtl_material_txn_allocations(transaction_id,
                                             repetitive_schedule_id,
                                             organization_id,
                                             last_update_date,
                                             last_updated_by,
                                             creation_date,
                                             created_by,
                                             last_update_login,
                                             primary_quantity,
                                             transaction_quantity,
                                             request_id,
                                             program_application_id,
                                             program_id,
                                             transaction_date)
      select p_cplRec.mtlAlcTmpID,
             wmat.repetitive_schedule_id,
             wmat.organization_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id,
             wmat.primary_quantity,
             wmat.transaction_quantity,
             fnd_global.conc_request_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_program_id,
             wmat.transaction_date
        from wip_mtl_allocations_temp wmat
       where wmat.transaction_temp_id = p_txnTmpID;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('inserted ' || SQL%ROWCOUNT || ' rows into MMTA', l_returnStatus);
      end if;
      delete wip_mtl_allocations_temp
       where transaction_temp_id = p_txnTmpID;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('deleted ' || SQL%ROWCOUNT || ' rows from WMAT', l_returnStatus);
      end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processRepetitive',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success.',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;

  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processRepetitive',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_cplProc_priv',
                               p_procedure_name => 'processRepetitive',
                               p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processRepetitive',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end processRepetitive;

  --This procedure:
  -- + checks tolerances
  -- + performs a move txn if the job/sched has a routing
  -- + updates wro if the job/sched does *not* have a routing (not for repetitive yet)
  --
  -- The end result is that after this procedure, the completion code should be able
  -- to process normally
  -- The one caveat is that the overcompletion quantity must match the remaining quantity
  -- after completing all repetitive schedules. This check is done in processRepetitive()
  procedure processOverCpl(p_cplRec IN OUT NOCOPY completion_rec_t,
                           x_returnStatus OUT NOCOPY VARCHAR2) is

    l_errMsg VARCHAR2(240);
    l_params wip_logger.param_tbl_t;
    l_returnStatus VARCHAR2(1);
    l_firstSchedID NUMBER;
    l_lastSchedID NUMBER;
    l_firstOpSeq NUMBER;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    --use the cursors only to lock the relavent wro rows
    cursor c_repRows(v_schedID NUMBER) is
      select required_quantity
        from wip_requirement_operations
       where repetitive_schedule_id = v_schedID
         for update of required_quantity nowait;

    cursor c_discRows(v_wipEntityID NUMBER) is
      select required_quantity
        from wip_requirement_operations
       where wip_entity_id = v_wipEntityID
         for update of required_quantity nowait;

  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      fillCplParamTbl(p_cplRec => p_cplRec,
                      x_params => l_params);
      wip_logger.entryPoint(p_procName => 'wip_cplProc_priv.processOverCpl',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(p_cplRec.wipEntityType = wip_constants.repetitive) then
      wip_repetitive_utilities.get_first_last_sched(p_wip_entity_id  => p_cplRec.wipEntityID,
                                                    p_org_id         => p_cplRec.orgID,
                                                    p_line_id        => p_cplRec.repLineID,
                                                    x_first_sched_id => l_firstSchedID,
                                                    x_last_sched_id  => l_lastSchedID,
                                                    x_error_mesg     => l_errMsg);
      if(l_errMsg <> null) then
        fnd_msg_pub.add; --assume prev fn used the fnd_message pkg
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        l_errMsg := 'wip_repetitive_utilities.get_first_last_sched: ' || l_errMsg;
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    wip_overcompletion.check_tolerance(p_organization_id        => p_cplRec.orgID,
                                       p_wip_entity_id          => p_cplRec.wipEntityID,
                                       p_repetitive_schedule_id => l_lastSchedID,
                                       p_primary_quantity       => p_cplRec.overCplPriQty,
                                       p_result                 => x_returnStatus);


    if(x_returnStatus = wip_constants.no) then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WIP', 'WIP_OC_TOLERANCE_FAIL');
      fnd_msg_pub.add;
      l_errMsg := 'cpl exceeded tolerances';
      raise fnd_api.g_exc_unexpected_error;
    else
      x_returnStatus := fnd_api.g_ret_sts_success;
    end if;


    --if a routing exists, insert a move record and perform the move
    if(p_cplRec.lastOpSeq > 0) then

      wip_overcompletion.insert_oc_move_txn( p_primary_quantity        =>  p_cplRec.overCplPriQty,
                                             p_cpl_profile             =>  wip_constants.online,
                                             p_oc_txn_id               =>  p_cplRec.overCplTxnID,
                                             p_parent_cpl_txn_id       =>  p_cplRec.cplTxnID,
                                             p_first_schedule_id       =>  l_firstSchedID,
                                             p_user_id                 =>  p_cplRec.lastUpdBy, --fnd_global.user_id,
                                             p_login_id                =>  fnd_global.conc_login_id,
                                             p_req_id                  =>  fnd_global.conc_request_id,
                                             p_appl_id                 =>  fnd_global.prog_appl_id,
                                             p_prog_id                 =>  fnd_global.conc_program_id,
                                             p_child_txn_id            =>  p_cplrec.movTxnID,
                                             p_first_operation_seq_num =>  l_firstOpSeq,
                                             p_err_mesg                =>  l_errMsg);

      --if insert failed
      if(l_errMsg is not null) then
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.add;
        l_errMsg := 'wip_overcompletion.insert_oc_move_txn: ' || l_errMsg;
        raise fnd_api.g_exc_unexpected_error;
      end if;

      --we must process material requirements in background mode so any assy pull components in MMTT
      --do not get processed. Assy pull components must remain through the discrete job processing so
      --the backflush procedure does not insert new requirements.

      wip_movProc_priv.processIntf(p_group_id => p_cplRec.movTxnID,
                                   p_child_txn_id => -1,
                                   p_mtl_header_id => p_cplRec.txnHdrID,
                                   p_proc_phase => wip_constants.move_proc,
                                   p_time_out => 0,
                                   p_move_mode => wip_constants.online,
                                   p_bf_mode => wip_constants.online, --ignored
                                   p_mtl_mode => wip_constants.no_processing,--do not call inv TM at all
                                   p_endDebug => fnd_api.g_false,
                                   p_initMsgList => fnd_api.g_false,
                                   p_insertAssy => fnd_api.g_true,
                                   p_do_backflush => fnd_api.g_false,--backflush was already done
                                   p_cmp_txn_id => null,
                                   x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        --depend on move to set the message
        raise fnd_api.g_exc_unexpected_error;
      end if;
    --otherwise we just have to increase the component requirements in wro
    else
      if(p_cplRec.wipEntityType = wip_constants.repetitive) then
        open c_repRows(v_schedID => l_lastSchedID);
        update wip_requirement_operations
           set required_quantity = round(required_quantity + p_cplRec.overCplPriQty * quantity_per_assembly, wip_constants.inv_max_precision)
         where repetitive_schedule_id = l_lastSchedID;
        close c_repRows;
      else
        open c_discRows(v_wipEntityID => p_cplRec.wipEntityID);
        update wip_requirement_operations
           set required_quantity = round(required_quantity + p_cplRec.overCplPriQty * quantity_per_assembly, wip_constants.inv_max_precision)
         where wip_entity_id = p_cplRec.wipEntityID
           AND nvl(basis_type,1) <> WIP_CONSTANTS.LOT_BASED_MTL;  /* LBM Project */
        close c_discRows;
      end if;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processOverCpl',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success.',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processOverCpl',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_cplProc_priv',
                               p_procedure_name => 'processOverCpl',
                               p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processOverCpl',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end processOverCpl;

  procedure preAllocateSchedules(p_txnHdrID IN NUMBER,
                                 p_cplTxnID IN NUMBER,
                                 p_txnActionID IN NUMBER,
                                 p_wipEntityID IN NUMBER,
                                 p_repLineID IN NUMBER,
                                 p_tblName IN VARCHAR2,
                                 p_endDebug IN VARCHAR2,
                                 x_returnStatus OUT NOCOPY VARCHAR2) IS

 /* Fix for bug 5373061: Added date_released condition to allocate back-dated transactions correctly */
    cursor c_repCplScheds(v_lastOpSeq NUMBER, v_wipEntityID NUMBER, v_repLineID NUMBER, v_txnDate DATE) is
      select wrs.repetitive_schedule_id repSchedID,
             wrs.bom_revision bomRev,
             nvl(wo.quantity_waiting_to_move,
                 ((wrs.daily_production_rate * wrs.processing_work_days) - wrs.quantity_completed)) availQty,
             nvl(sum(wmat.primary_quantity), 0) tempQty
        from wip_operations wo,
             wip_repetitive_schedules wrs,
             wip_mtl_allocations_temp wmat
       where wrs.wip_entity_id = v_wipEntityID
         and wrs.line_id = v_repLineID
         and wrs.date_released < v_txnDate
         and wrs.status_type in (wip_constants.released, wip_constants.comp_chrg)
         and wrs.repetitive_schedule_id = wo.repetitive_schedule_id (+)
         and wrs.wip_entity_id = wo.wip_entity_id (+)
         and v_lastOpSeq = wo.operation_seq_num (+)
         and wrs.repetitive_schedule_id = wmat.repetitive_schedule_id (+)
       group by wrs.repetitive_schedule_id,
             wrs.bom_revision,
             wo.quantity_waiting_to_move,
             wrs.daily_production_rate,
             wrs.processing_work_days,
             wrs.quantity_completed,
             wrs.first_unit_start_date
       order by wrs.first_unit_start_date;

    /* Fix for bug 5373061: Added date_released condition to allocate back-dated transactions correctly */
    cursor c_repRetScheds(v_lastOpSeq NUMBER, v_wipEntityID NUMBER, v_repLineID NUMBER, v_txnDate DATE) is
      select wrs.repetitive_schedule_id repSchedID,
             wrs.bom_revision bomRev,
             wrs.quantity_completed availQty,
             nvl(sum(wmat.primary_quantity), 0) tempQty
        from wip_repetitive_schedules wrs,
             wip_mtl_allocations_temp wmat
       where wrs.wip_entity_id = v_wipEntityID
         and wrs.line_id = v_repLineID
         and wrs.date_released < v_txnDate
         and wrs.status_type in (wip_constants.released, wip_constants.comp_chrg)
         and wrs.repetitive_schedule_id = wmat.repetitive_schedule_id (+)
       group by wrs.repetitive_schedule_id,
             wrs.bom_revision,
             wrs.daily_production_rate,
             wrs.processing_work_days,
             wrs.quantity_completed,
             wrs.first_unit_start_date
       order by wrs.first_unit_start_date desc;

      cursor c_mmttTxns is
        select transaction_temp_id txnTmpID,
               operation_seq_num lastOpSeq,
               revision,
               transaction_date txnDate,
               primary_quantity priQty,
               transaction_quantity txnQty,
               overcompletion_primary_qty,
               organization_id
          from mtl_material_transactions_temp
         where completion_transaction_id = p_cplTxnID
           and transaction_header_id = p_txnHdrID
           and transaction_source_id = p_wipEntityID
           and transaction_source_type_id = 5
           and transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action);

      cursor c_mtiTxns is
        select transaction_interface_id,
               operation_seq_num lastOpSeq,
               revision,
               transaction_date txnDate,
               primary_quantity priQty,
               transaction_quantity txnQty,
               overcompletion_primary_qty,
               organization_id
          from mtl_transactions_interface
         where completion_transaction_id = p_cplTxnID
           and transaction_header_id = p_txnHdrID
           and transaction_source_id = p_wipEntityID
           and transaction_source_type_id = 5
           and transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action);

    type schedule_recTbl_t is record(repSchedID num_tbl_t,
                                     bomRev char_tbl_t,
                                     availQty num_tbl_t,
                                     tempQty num_tbl_t);

    type txn_alloc_recTbl_t is record(txnID num_tbl_t,
                                      lastOpSeq num_tbl_t,
                                      revision char_tbl_t,
                                      txnDate date_tbl_t,
                                      priQty num_tbl_t,
                                      txnQty num_tbl_t,
                                      overCplQty num_tbl_t,
                                      orgID num_tbl_t);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_lastOpSeq NUMBER;
    l_schedQty NUMBER;
    l_returnStatus VARCHAR2(1);
    l_errMsg VARCHAR2(2000);
    l_remainingQty NUMBER;
    l_lastSchedID NUMBER;
    l_txnRecTbl txn_alloc_recTbl_t;
    l_schedRecTbl schedule_recTbl_t;
    l_startQty NUMBER;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;

    savepoint wipcplpb40;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHdrID';
      l_params(1).paramValue := p_txnHdrID;
      l_params(2).paramName := 'p_cplTxnID';
      l_params(2).paramValue := p_cplTxnID;
      l_params(3).paramName := 'p_txnActionID';
      l_params(3).paramValue := p_txnActionID;
      l_params(4).paramName := 'p_wipEntityID';
      l_params(4).paramValue := p_wipEntityID;
      l_params(5).paramName := 'p_repLineID';
      l_params(5).paramValue := p_repLineID;
      l_params(6).paramName := 'p_tblName';
      l_params(6).paramValue := p_tblName;

      wip_logger.entryPoint(p_procName => 'wip_cplProc_priv.preAllocateSchedules',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(p_tblName = wip_constants.MTI_TBL) then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('.25', l_returnStatus);
      end if;
      open c_mtiTxns;
      fetch c_mtiTxns
        bulk collect into l_txnRecTbl.txnID,
                          l_txnRecTbl.lastOpSeq,
                          l_txnRecTbl.revision,
                          l_txnRecTbl.txnDate,
                          l_txnRecTbl.priQty,
                          l_txnRecTbl.txnQty,
                          l_txnRecTbl.overCplQty,
                          l_txnRecTbl.orgID;
      close c_mtiTxns;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('mti row count is ' || l_txnRecTbl.txnID.count, l_returnStatus);
      end if;
    else
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('1', l_returnStatus);
      end if;
      open c_mmttTxns;
      fetch c_mmttTxns
        bulk collect into l_txnRecTbl.txnID,
                          l_txnRecTbl.lastOpSeq,
                          l_txnRecTbl.revision,
                          l_txnRecTbl.txnDate,
                          l_txnRecTbl.priQty,
                          l_txnRecTbl.txnQty,
                          l_txnRecTbl.overCplQty,
                          l_txnRecTbl.orgID;
      close c_mmttTxns;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('2', l_returnStatus);
      end if;
    end if;

    for i in 1..l_txnRecTbl.txnID.count loop
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('processing cpl tmpID:' || l_txnRecTbl.txnID(i) || '; qty:' || l_txnRecTbl.priQty(i), l_returnStatus);
      end if;

      if(l_txnRecTbl.lastOpSeq(i) is null or l_txnRecTbl.lastOpSeq(i) < 0) then
        l_lastOpSeq := 1; --if no rtg, components have op_seq = 1
      else
        l_lastOpSeq := l_txnRecTbl.lastOpSeq(i);
      end if;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('last op seq is ' || l_lastOpSeq, l_returnStatus);
        wip_logger.log('action is ' || l_lastOpSeq, l_returnStatus);
      end if;
      l_remainingQty := l_txnRecTbl.priQty(i);

      if(p_txnActionID = wip_constants.cplassy_action) then
        /* Fix for bug 5373061: Pass txnDate to cursor to fetch
           only valid schedules as on transaction date */
        open c_repCplScheds(v_lastOpSeq => l_txnRecTbl.lastOpSeq(i),
                            v_wipEntityID => p_wipEntityID,
                            v_repLineID => p_repLineID,
                            v_txnDate => l_txnRecTbl.txnDate(i));

        fetch c_repCplScheds
          bulk collect into l_schedRecTbl.repSchedID,
                            l_schedRecTbl.bomRev,
                            l_schedRecTbl.availQty,
                            l_schedRecTbl.tempQty;
        close c_repCplScheds;
       else
        /* Fix for bug 5373061: Pass txnDate to cursor to fetch
           only valid schedules as on transaction date */
        open c_repRetScheds(v_lastOpSeq => l_txnRecTbl.lastOpSeq(i),
                          v_wipEntityID => p_wipEntityID,
                          v_repLineID => p_repLineID,
                          v_txnDate => l_txnRecTbl.txnDate(i));

        fetch c_repRetScheds
          bulk collect into l_schedRecTbl.repSchedID,
                            l_schedRecTbl.bomRev,
                            l_schedRecTbl.availQty,
                            l_schedRecTbl.tempQty;
        close c_repRetScheds;
      end if;
      for j in 1..l_schedRecTbl.repSchedID.count loop

        if(p_txnActionID = wip_constants.cplassy_action) then
          if(l_schedRecTbl.availQty(j) is null) then
            select ((wrs.daily_production_rate * wrs.processing_work_days) - wrs.quantity_completed) - nvl(sum(wo.quantity_scrapped), 0)
              into l_schedRecTbl.availQty(j)
              from wip_repetitive_schedules wrs,
                   wip_operations wo
             where wrs.wip_entity_id = p_wipEntityID
               and wrs.repetitive_schedule_id = l_schedRecTbl.repSchedID(j)
               and wrs.repetitive_schedule_id = wo.repetitive_schedule_id (+)
               and wrs.wip_entity_id = wo.wip_entity_id (+)
             group by wrs.daily_production_rate,
                    wrs.processing_work_days,
                    wrs.quantity_completed;
          end if;
          l_schedQty := greatest(0, least(l_schedRecTbl.availQty(j) - nvl(l_schedRecTbl.tempQty(j), 0), l_remainingQty));
        else
          l_schedQty := -1 * greatest(0, least(l_schedRecTbl.availQty(j) + nvl(l_schedRecTbl.tempQty(j), 0), abs(l_remainingQty)));
        end if;


        l_lastSchedID := l_schedRecTbl.repSchedID(j);--the last schedule fetched is the last one open for completions

        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('processing sched ' || l_schedRecTbl.repSchedID(j) || ' w/open qty of ' || l_schedQty, l_returnStatus);
          wip_logger.log('availQty: ' || l_schedRecTbl.availQty(j), l_returnStatus);
          wip_logger.log('startQty: ' || l_startQty, l_returnStatus);
          wip_logger.log('tempQty: ' || l_schedRecTbl.tempQty(j), l_returnStatus);
          wip_logger.log('remainQty: ' || l_remainingQty, l_returnStatus);
        end if;

        --if the revisions don't match...
        if(l_schedRecTbl.bomRev(j) <> l_txnRecTbl.revision(i) and
           (l_schedRecTbl.bomRev(j) is not null or l_txnRecTbl.revision(i) is not null)) then
          fnd_message.set_name('WIP', 'WIP_SCHED_MULTIPLE_BILL_REV');
          fnd_msg_pub.add;
          l_errMsg := 'Schedules have different bill revisions.'; --set message in case it fails
          raise fnd_api.g_exc_unexpected_error;
        end if;

        --complete the lesser of the open quantity and the remaining transaction qty

        if(l_schedQty <> 0) then
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('inserting into temp table; sched:' || l_schedRecTbl.repSchedID(j) || '; qty:' || l_schedQty, l_returnStatus);
          end if;
          insert into wip_mtl_allocations_temp
            (transaction_temp_id,
             completion_transaction_id,
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
             transaction_quantity,
             primary_quantity,
             transaction_date)
            values
            (l_txnRecTbl.txnID(i),
             p_cplTxnID,
             l_schedRecTbl.repSchedID(j),
             l_txnRecTbl.orgID(i),
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id,
             fnd_global.conc_request_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_program_id,
             sysdate,
             round(l_txnRecTbl.txnQty(i) * l_schedQty/l_txnRecTbl.priQty(i), wip_constants.inv_max_precision), --% of qty completed * txn Qty
             l_schedQty,
             l_txnRecTbl.txnDate(i));

          l_remainingQty := l_remainingQty - l_schedQty;
          if(l_remainingQty = 0) then
            exit;
          end if;
        end if;
      end loop;
      if(l_remainingQty <> 0) then -- over-completion/return
        if(l_lastSchedID is null) then
          /* Fix for bug 5373061: Passed missing token */
          fnd_message.set_name('WIP', 'WIP_INT_ERROR_NO_SCHED');
          fnd_message.set_token('ROUTINE', 'wip_cplProc_priv.preAllocateSchedules');
          fnd_msg_pub.add;
          l_errMsg := 'did not find any schedules.';
          raise fnd_api.g_exc_unexpected_error; -- couldn't find any open schedules
        end if;

        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('txnID' || l_txnRecTbl.txnID(i), l_returnStatus);
          wip_logger.log('rmnQty' || l_remainingQty, l_returnStatus);
          wip_logger.log('schedID' || l_lastSchedID, l_returnStatus);
        end if;

        --in below stmt, transaction_quantity = old_qty + (conversion ratio * new primary_qty)
        update wip_mtl_allocations_temp
           set transaction_quantity = transaction_quantity +
                                      (transaction_quantity/primary_quantity * l_remainingQty),
               primary_quantity = primary_quantity + l_remainingQty
         where transaction_temp_id = l_txnRecTbl.txnID(i)
           and repetitive_schedule_id = l_lastSchedID;

        if(SQL%ROWCOUNT = 0) then
            wip_logger.log('l_txnRecTbl.overCplQty = '||to_char(l_txnRecTbl.overCplQty(i)), l_returnStatus);

          /* Fix for bug 5373061: We will reach here even if no overcompletion is involved. Back-dated
             transactions can pick up older schedules which do not have open quantity. Do not allocate
             to the older schedule. Throw error */

         /* Fix for Bug#6018877 - FP of bug#6004763. Added the if condition check not to consider Return  txn */
         if(p_txnActionID <> wip_constants.retassy_action) then
          if(l_txnRecTbl.overCplQty(i) IS NULL) then
            fnd_message.set_name('WIP', 'WIP_INT_ERROR_NO_SCHED');
            fnd_message.set_token('ROUTINE', 'wip_cplProc_priv.preAllocateSchedules');
            fnd_msg_pub.add;
            l_errMsg := 'did not find any schedules.';
            raise fnd_api.g_exc_unexpected_error; -- couldn't find any open schedules
          end if;
         end if; /*Fix for Bug#6018877 - FP of bug#6004763*/

          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('update failed. inserting new row', l_returnStatus);
          end if;
          /* Fixed bug 3698513. Completion_transaction_id is a not null column
           * , so we have to insert a value into this column. This bug only
           * occur when overcompletion and available quantity is zero.
           */
          insert into wip_mtl_allocations_temp
            (transaction_temp_id,
             completion_transaction_id,
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
             transaction_quantity,
             primary_quantity,
             transaction_date)
            values
            (l_txnRecTbl.txnID(i),
             p_cplTxnID,
             l_lastSchedID,
             l_txnRecTbl.orgID(i),
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id,
             fnd_global.conc_request_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_program_id,
             sysdate,
             l_txnRecTbl.txnQty(i),
             l_txnRecTbl.priQty(i),
             l_txnRecTbl.txnDate(i));
        end if;
      end if;
    end loop;


    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.preAllocateSchedules',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success.',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      rollback to wipcplpb40;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.preAllocateSchedules',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_cplProc_priv',
                               p_procedure_name => 'preAllocateSchedules',
                               p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.preAllocateSchedules',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end preAllocateSchedules;
/*
  procedure preAllocateRets(p_txnHdrID IN NUMBER,
                            p_cplTxnID IN NUMBER,
                            p_wipEntityID IN NUMBER,
                            p_repLineID IN NUMBER,
                            p_tblName IN VARCHAR2,
                            x_returnStatus OUT NOCOPY VARCHAR2) IS

    cursor c_openScheds is
      select wrs.repetitive_schedule_id,
             ((wrs.daily_production_rate * wrs.processing_work_days) - wrs.quantity_completed) startQty,
             wrs.quantity_completed cplQty,
             sum(wmat.primary_quantity) tempQty
        from wip_repetitive_schedules wrs,
             wip_mtl_allocations_temp wmat
       where wrs.wip_entity_id = p_wipEntityID
         and wrs.line_id = p_repLineID
         and wrs.status_type in (wip_constants.released, wip_constants.comp_chrg)
         and wrs.repetitive_schedule_id = wmat.repetitive_schedule_id (+)
       group by wrs.repetitive_schedule_id,
             wrs.bom_revision,
             wrs.daily_production_rate,
             wrs.processing_work_days,
             wrs.quantity_completed,
             wrs.first_unit_start_date
    order by wrs.first_unit_start_date;

    l_schedID NUMBER;
    l_errMsg VARCHAR2(2000);
    l_returnStatus VARCHAR2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
  begin
    --need to find the first open schedule. if we have pre-allocated completions, we have to see
    --which ones will be completed by the time this return is processed.
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHdrID';
      l_params(1).paramValue := p_txnHdrID;
      l_params(2).paramName := 'p_cplTxnID';
      l_params(2).paramValue := p_cplTxnID;
      l_params(3).paramName := 'p_wipEntityID';
      l_params(3).paramValue := p_wipEntityID;
      l_params(4).paramName := 'p_repLineID';
      l_params(4).paramValue := p_repLineID;
      l_params(5).paramName := 'p_tblName';
      l_params(5).paramValue := p_tblName;

      wip_logger.entryPoint(p_procName => 'wip_cplProc_priv.preAllocateRets',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    for l_schedRec in c_openScheds loop
      l_schedID := l_schedRec.repetitive_schedule_id;

      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('l_schedRec.cplQty' || l_schedRec.cplQty, l_returnStatus);
        wip_logger.log('l_schedRec.tempQty' || l_schedRec.tempQty, l_returnStatus);
        wip_logger.log('l_schedRec.startQty' || l_schedRec.startQty, l_returnStatus);
      end if;

      if(greatest(l_schedRec.cplQty, 0) + nvl(l_schedRec.tempQty, 0) < l_schedRec.startQty) then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('found open schedule' || l_schedID, l_returnStatus);
        end if;
        exit;
      end if;
    end loop;
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('returning to schedule' || l_schedID, l_returnStatus);
    end if;

    if(p_tblName = wip_constants.MMTT_TBL) then
      insert into wip_mtl_allocations_temp
        (transaction_temp_id,
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
         transaction_quantity,
         primary_quantity,
         transaction_date)
         select mmtt.transaction_temp_id,
                l_schedID,
                mmtt.organization_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                fnd_global.conc_request_id,
                fnd_global.prog_appl_id,
                fnd_global.conc_program_id,
                sysdate,
                mmtt.transaction_quantity,
                mmtt.primary_quantity,
                mmtt.transaction_date
           from mtl_material_transactions_temp mmtt
          where mmtt.transaction_header_id = p_txnHdrID
            and mmtt.completion_transaction_id = p_cplTxnID
            and mmtt.transaction_action_id = wip_constants.retassy_action;
    elsif(p_tblName = wip_constants.MTI_TBL) then
      insert into wip_mtl_allocations_temp
        (transaction_temp_id,
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
         transaction_quantity,
         primary_quantity,
         transaction_date)
         select mti.transaction_interface_id,
                l_schedID,
                mti.organization_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                fnd_global.conc_request_id,
                fnd_global.prog_appl_id,
                fnd_global.conc_program_id,
                sysdate,
                mti.transaction_quantity,
                mti.primary_quantity,
                mti.transaction_date
           from mtl_transactions_interface mti
          where mti.transaction_header_id = p_txnHdrID
            and mti.completion_transaction_id = p_cplTxnID
            and mti.transaction_action_id = wip_constants.retassy_action;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('inserted ' || SQL%ROWCOUNT || ' rows', l_returnStatus);
    end if;

    x_returnStatus := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.preAllocateRets',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'success',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;

  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.preAllocateRets',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end preAllocateRets;

  procedure preAllocateSchedules(p_txnHdrID IN NUMBER,
                                 p_cplTxnID IN NUMBER,
                                 p_txnActionID IN NUMBER,
                                 p_wipEntityID IN NUMBER,
                                 p_repLineID IN NUMBER,
                                 p_tblName IN VARCHAR2,
                                 p_endDebug IN VARCHAR2,
                                 x_returnStatus OUT NOCOPY VARCHAR2) IS

    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_returnStatus VARCHAR2(1);
    l_errMsg VARCHAR2(2000);
  begin
    savepoint wipcplpb40;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_cplTxnID';
      l_params(1).paramValue := p_cplTxnID;

      wip_logger.entryPoint(p_procName => 'wip_cplProc_priv.preAllocateSchedules',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(p_txnActionID = wip_constants.cplassy_action) then
      preAllocateCpls(p_txnHdrID => p_txnHdrID,
                      p_cplTxnID => p_cplTxnID,
                      p_wipEntityID => p_wipEntityID,
                      p_repLineID => p_repLineID,
                      p_tblName => p_tblName,
                      x_returnStatus => x_returnStatus);
    else
      preAllocateRets(p_txnHdrID => p_txnHdrID,
                      p_cplTxnID => p_cplTxnID,
                      p_wipEntityID => p_wipEntityID,
                      p_repLineID => p_repLineID,
                      p_tblName => p_tblName,
                      x_returnStatus => x_returnStatus);
    end if;

    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.preAllocateSchedules',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success.',
                           x_returnStatus => l_returnStatus); --discard logging return status
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    end if;

  exception
    when fnd_api.g_exc_unexpected_error then
      rollback to wipcplpb40;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.preAllocateSchedules',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
        if(fnd_api.to_boolean(p_endDebug)) then
          wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
        end if;
      end if;
    when others then
      rollback to wipcplpb40;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_cplProc_priv',
                               p_procedure_name => 'preAllocateSchedules',
                               p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.preAllocateSchedules',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
        if(fnd_api.to_boolean(p_endDebug)) then
          wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
        end if;
      end if;
  end preAllocateSchedules;
*/
  procedure fillCplParamTbl(p_cplRec IN completion_rec_t,
                            x_params OUT NOCOPY wip_logger.param_tbl_t) is
  begin
    x_params(1).paramName := 'p_cplRec.wipEntityType';
    x_params(1).paramValue := p_cplRec.wipEntityType;
    x_params(2).paramName := 'p_cplRec.wipEntityID';
    x_params(2).paramValue := p_cplRec.wipEntityID;
    x_params(3).paramName := 'p_cplRec.orgID';
    x_params(3).paramValue := p_cplRec.orgID;
    x_params(4).paramName := 'p_cplRec.repLineID';
    x_params(4).paramValue := p_cplRec.repLineID;
    x_params(5).paramName := 'p_cplRec.itemID';
    x_params(5).paramValue := p_cplRec.itemID;
    x_params(6).paramName := 'p_cplRec.txnActionID';
    x_params(6).paramValue := p_cplRec.txnActionID;
    x_params(7).paramName := 'p_cplRec.priQty';
    x_params(7).paramValue := p_cplRec.priQty;
    x_params(8).paramName := 'p_cplRec.txnQty';
    x_params(8).paramValue := p_cplRec.txnQty;
    x_params(9).paramName := 'p_cplRec.txnDate';
    x_params(9).paramValue := p_cplRec.txnDate;
    x_params(10).paramName := 'p_cplRec.cplTxnID';
    x_params(10).paramValue := p_cplRec.cplTxnID;
    x_params(11).paramName := 'p_cplRec.kanbanCardID';
    x_params(11).paramValue := p_cplRec.kanbanCardID;
    x_params(12).paramName := 'p_cplRec.qaCollectionID';
    x_params(12).paramValue := p_cplRec.qaCollectionID;
    x_params(13).paramName := 'p_cplRec.lastOpSeq';
    x_params(13).paramValue := p_cplRec.lastOpSeq;
    x_params(14).paramName := 'p_cplRec.revision';
    x_params(14).paramValue := p_cplRec.revision;
    x_params(15).paramName := 'p_cplRec.mtlAlcTmpID';
    x_params(15).paramValue := p_cplRec.mtlAlcTmpID;
    x_params(16).paramName := 'p_cplRec.txnHdrID';
    x_params(16).paramValue := p_cplRec.txnHdrID;
    x_params(17).paramName := 'p_cplRec.txnStatus';
    x_params(17).paramValue := p_cplRec.txnStatus;
    x_params(18).paramName := 'p_cplRec.overCplPriQty';
    x_params(18).paramValue := p_cplRec.overCplPriQty;
    x_params(19).paramName := 'p_cplRec.overCplTxnID';
    x_params(19).paramValue := p_cplRec.overCplTxnID;
    x_params(20).paramName := 'p_cplRec.lastUpdBy';
    x_params(20).paramValue := p_cplRec.lastUpdBy;
    x_params(21).paramName := 'p_cplRec.createdBy';
    x_params(21).paramValue := p_cplRec.createdBy;
    x_params(22).paramName := 'p_cplRec.lpnID';
    x_params(22).paramValue := p_cplRec.lpnID;
    x_params(23).paramName := 'p_cplRec.movTxnID';
    x_params(23).paramValue := p_cplRec.movTxnID;
  end fillCplParamTbl;

  PROCEDURE processOATxn(p_org_id         IN        NUMBER,
                         p_interface_id   IN        NUMBER,
                         p_mtl_header_id  IN        NUMBER,
                         p_oc_primary_qty IN        NUMBER,
                         p_assySerial     IN        VARCHAR2:= NULL,
                         p_print_label    IN        NUMBER default null, /*VJ Label Printing*/
                         x_returnStatus  OUT NOCOPY VARCHAR2) IS
    CURSOR c_cmp_txn IS
      SELECT transaction_source_id wip_entity_id,
             organization_id org_id,
             inventory_item_id item_id,
             transaction_action_id action_id,
             primary_quantity primary_qty,
             transaction_quantity txn_qty,
             transaction_date txn_date,
             completion_transaction_id cmp_txn_id,
             overcompletion_transaction_id oc_txn_id,
             kanban_card_id,
             qa_collection_id,
             operation_seq_num op_seq_num,
             revision,
             overcompletion_primary_qty oc_primary_qty,
             last_updated_by,
             created_by
        FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_interface_id;


    l_cmp_txn c_cmp_txn%ROWTYPE;
    l_log_level     NUMBER := fnd_log.g_current_runtime_level;
    l_cost_method   NUMBER;
    l_err_num       NUMBER;
    l_msg_count     NUMBER;
    l_ret_value     NUMBER;
    l_error_msg     VARCHAR2(1000);
    l_label_status  VARCHAR2(1);
    l_msg_stack     VARCHAR2(2000);
    l_process_phase VARCHAR2(3);
    l_return_status VARCHAR(1);
    l_params        wip_logger.param_tbl_t;
    l_oc_rec        wip_cplProc_priv.completion_rec_t;
    -- new variables for serialization
    l_op_seq        NUMBER;
    l_step          NUMBER;
  BEGIN
    l_process_phase := '1';
    IF (l_log_level <= wip_constants.trace_logging) THEN
      l_params(1).paramName   := 'p_org_id';
      l_params(1).paramValue  :=  p_org_id;
      l_params(2).paramName   := 'p_interface_id';
      l_params(2).paramValue  :=  p_interface_id;
      l_params(3).paramName   := 'p_mtl_header_id';
      l_params(3).paramValue  :=  p_mtl_header_id;
      l_params(4).paramName   := 'p_oc_primary_qty';
      l_params(4).paramValue  :=  p_oc_primary_qty;
      wip_logger.entryPoint(p_procName     => 'wip_cplProc_priv.processOATxn',
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
    SELECT primary_cost_method
      INTO l_cost_method
      FROM mtl_parameters
     WHERE organization_id = p_org_id;

    l_process_phase := '4';
    --insert a row into cst_comp_snap_temp
    IF(l_cost_method IN (wip_constants.cost_avg,wip_constants.cost_fifo,
                         wip_constants.cost_lifo)) THEN
      l_ret_value := CSTACOSN.op_snapshot(i_txn_temp_id => p_interface_id,
                                          err_num       => l_err_num,
                                          err_code      => l_error_msg,
                                          err_msg       => l_error_msg);
      IF(l_ret_value <> 1) THEN
        fnd_message.set_name(application => 'CST',
                             name        => 'CST_SNAPSHOT_FAILED');
        fnd_msg_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    l_process_phase := '5';
    IF (p_print_label = 1) THEN /* VJ Label Printing */
      wip_utilities.print_label(p_txn_id       => p_mtl_header_id,
                                p_table_type   => 2, --MMTT
                                p_ret_status   => x_returnStatus,
                                p_msg_count    => l_msg_count,
                                p_msg_data     => l_error_msg,
                                p_label_status => l_label_status,
                                p_business_flow_code => 26); -- discrete business flow code
      -- do not error out if label printing, only put warning message in log
      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        wip_utilities.get_message_stack(p_msg => l_msg_stack);
        IF (l_log_level <= wip_constants.full_logging) then
          wip_logger.log(p_msg => 'An error has occurred with label printing.\n' ||
                                'The following error has occurred during ' ||
                                'printing: ' || l_msg_stack || '\n' ||
                                'Please check the Inventory log file for more ' ||
                                'information.',
                         x_returnStatus =>l_return_status);
        END IF;
      END IF;
    END IF; /* VJ Label Printing */

    l_process_phase := '6';

    OPEN c_cmp_txn;
    -- This cursor will return only one record.
    FETCH c_cmp_txn INTO l_cmp_txn;

    IF(p_oc_primary_qty IS NOT NULL AND p_oc_primary_qty > 0) THEN
      -- Initialize l_oc_rec
      l_oc_rec.wipEntityType  := WIP_CONSTANTS.DISCRETE;
      l_oc_rec.wipEntityID    := l_cmp_txn.wip_entity_id;
      l_oc_rec.orgID          := l_cmp_txn.org_id;
      l_oc_rec.repLineID      := null; -- only used for repetitive
      l_oc_rec.itemID         := l_cmp_txn.item_id;
      l_oc_rec.txnActionID    := l_cmp_txn.action_id;
      l_oc_rec.priQty         := l_cmp_txn.primary_qty;
      l_oc_rec.txnQty         := l_cmp_txn.txn_qty;
      l_oc_rec.txnDate        := l_cmp_txn.txn_date;
      l_oc_rec.cplTxnID       := l_cmp_txn.cmp_txn_id;
      l_oc_rec.movTxnID       := l_cmp_txn.oc_txn_id;
      l_oc_rec.kanbanCardID   := l_cmp_txn.kanban_card_id;
      l_oc_rec.qaCollectionID := l_cmp_txn.qa_collection_id;
      l_oc_rec.lastOpSeq      := l_cmp_txn.op_seq_num;
      l_oc_rec.revision       := l_cmp_txn.revision;
      l_oc_rec.mtlAlcTmpID    := null; -- only used for repetitive
      l_oc_rec.txnHdrID       := p_mtl_header_id;
      l_oc_rec.txnStatus      := null;
      l_oc_rec.overCplPriQty  := p_oc_primary_qty;
      l_oc_rec.lastUpdBy      := l_cmp_txn.last_updated_by;
      l_oc_rec.createdBy      := l_cmp_txn.created_by;
      l_oc_rec.lpnID          := null; -- only used for LPN
      l_oc_rec.txnMode        := WIP_CONSTANTS.ONLINE;
      l_oc_rec.overCplTxnID   := l_cmp_txn.oc_txn_id;

      wip_cplProc_priv.processOverCpl(p_cplRec       => l_oc_rec,
                                      x_returnStatus => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- Overcompletion

    l_process_phase := '7';
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

    l_process_phase := '8';
    -- Update to MSN must take place after inventory processing as they always
    -- clear the group mark id when processing a serial. Here we have to
    -- repopulate the group_mark_id, wip_entity_id, op_seq, and
    -- intra_op columns.
    IF (p_assySerial IS NOT NULL AND
        l_cmp_txn.action_id = WIP_CONSTANTS.RETASSY_ACTION) THEN
      -- Check whether the job has routing or not.
      IF(l_cmp_txn.op_seq_num = -1) THEN
        -- No routing
        l_op_seq := null;
        l_step   := null;
      ELSE
        l_op_seq := l_cmp_txn.op_seq_num;
        l_step   := WIP_CONSTANTS.TOMOVE;
      END IF;

      wip_utilities.update_serial(p_serial_number => p_assySerial,
                                  p_inventory_item_id => l_cmp_txn.item_id,
                                  p_organization_id => l_cmp_txn.org_id,
                                  p_wip_entity_id => l_cmp_txn.wip_entity_id,
                                  p_operation_seq_num => l_op_seq,
                                  p_intraoperation_step_type => l_step,
                                  x_return_status => x_returnStatus);

      IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- Serialized transaction

    l_process_phase := '9';
    IF(c_cmp_txn%ISOPEN) THEN
      CLOSE c_cmp_txn;
    END IF;

    x_returnStatus := fnd_api.g_ret_sts_success;
    -- write to the log file
    IF (l_log_level <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processOATxn',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure complete',
                           x_returnStatus => l_return_status);
    END IF;
    -- close log file
    wip_logger.cleanUp(x_returnStatus => l_return_status);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF(c_cmp_txn%ISOPEN) THEN
        CLOSE c_cmp_txn;
      END IF;
      ROLLBACK TO SAVEPOINT s_oa_txn_proc;
      x_returnStatus := fnd_api.g_ret_sts_error;

      IF (l_log_level <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(p_procName => 'wip_cplProc_priv.processOATxn',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'wip_cplProc_priv.processOATxn failed : '
                                     || l_process_phase,
                             x_returnStatus => l_return_status);
      END IF;
      -- close log file
      wip_logger.cleanUp(x_returnStatus => l_return_status);
    WHEN others THEN
      IF(c_cmp_txn%ISOPEN) THEN
        CLOSE c_cmp_txn;
      END IF;
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
end wip_cplProc_priv;

/
