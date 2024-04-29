--------------------------------------------------------
--  DDL for Package Body WIP_MTI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MTI_PUB" as
/* $Header: wipmtivb.pls 120.9.12010000.2 2009/06/16 17:07:06 hliew ship $ */

  type num_tbl_t is table of number;
  type date_tbl_t is table of date;
  type char_tbl_t is table of varchar2(3);
  type rowid_tbl_t is table of varchar2(18);
  type big_char_tbl_t is table of varchar2(2000);

  type mti_recTbl_t is record(wipEntityID   num_tbl_t,
                              orgID         num_tbl_t,
                              itemID        num_tbl_t,
                              txnQty        num_tbl_t,
                              priQty        num_tbl_t,
                              txnDate       date_tbl_t,
                              txnTypeID     num_tbl_t,
                              txnActionID   num_tbl_t,
                              txnIntID      num_tbl_t,
                              txnBatchID    num_tbl_t,
                              txnSeqNum     num_tbl_t,
                              repLineID     num_tbl_t,
                              cplTxnID      num_tbl_t,
                              overCplTxnID  num_tbl_t,
                              overCplTxnQty num_tbl_t,
                              overCplPriQty num_tbl_t,
                              movTxnID      num_tbl_t,
                              wipEntityType num_tbl_t,
                              txnUom        char_tbl_t,
                              priUom        char_tbl_t,
                              locatorID     num_tbl_t,
                              projectID     num_tbl_t,
                              taskID        num_tbl_t,
                              reasonID      num_tbl_t,
                              reference     big_char_tbl_t);

  type mti_err_recTbl_t is record(txnIntID num_tbl_t,
                                  errCode big_char_tbl_t,
                                  errExpl big_char_tbl_t);

  procedure preInvProcessFlow(p_txnHeaderID  in  number,
                              x_returnStatus out nocopy varchar2);



  function extendErrTbls(p_errTbl in out nocopy mti_err_recTbl_t) return number;

  procedure doPreProcessingValidations(p_txnHeaderID in number,
                                       x_returnStatus out nocopy varchar2);

  procedure preInvProcessWorkOrder(p_txnHeaderID in number,
                                   p_tbls in mti_recTbl_t,
                                   p_index in number,
                                   p_errTbls in out nocopy mti_err_recTbl_t,
                                   x_returnStatus OUT NOCOPY VARCHAR2);

  --This procedure should eventually do component explosion for work order-less
  --as well as component backflushing for discrete
  procedure preInvWIPProcessing(p_txnHeaderID  in  number,
                                x_returnStatus out nocopy varchar2) is
    cursor c_assyRecs is
      select mti.transaction_source_id,
             mti.organization_id,
             mti.inventory_item_id,
             mti.transaction_quantity,
             mti.primary_quantity,
             mti.transaction_date,
             mti.transaction_type_id,
             mti.transaction_action_id,
             mti.transaction_interface_id,
             mti.transaction_batch_id,
             mti.transaction_batch_seq,
             mti.repetitive_line_id,
             mti.completion_transaction_id,
             mti.overcompletion_transaction_id,
             mti.overcompletion_transaction_qty,
             mti.overcompletion_primary_qty,
             mti.move_transaction_id,
             decode(upper(mti.flow_schedule),
                    'Y', wip_constants.flow,
                    we.entity_type),
             mti.transaction_uom,
             msi.primary_uom_code,
             mti.locator_id,
             mti.project_id,
             mti.task_id,
             mti.reason_id,
             mti.transaction_reference
        from mtl_transactions_interface mti,
             wip_entities we,
             mtl_system_items msi
       where mti.transaction_header_id = p_txnHeaderID
         and mti.transaction_source_type_id = 5
         and mti.transaction_action_id in (wip_constants.cplassy_action,
                                           wip_constants.retassy_action,
                                           wip_constants.scrassy_action)
         and mti.transaction_source_id = we.wip_entity_id (+)
         and mti.organization_id = we.organization_id (+)
         and mti.inventory_item_id = msi.inventory_item_id
         and mti.organization_id = msi.organization_id;

    l_tbls mti_recTbl_t;
    l_errTbls mti_err_recTbl_t;
    l_count NUMBER;
    l_returnStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_errExp VARCHAR2(240);
    l_convPriQty NUMBER;
    l_convOverCplPriQty NUMBER;
    l_convErrExists boolean;
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHeaderID';
      l_params(1).paramValue := p_txnHeaderID;
      wip_logger.entryPoint(p_procName     => 'wip_mti_pub.preInvWipProcessing',
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    --This procedure must be done before opening the cursor!
    doPreProcessingValidations(p_txnHeaderID,
                              x_returnStatus);
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    open c_assyRecs;
    fetch c_assyRecs
      bulk collect into l_tbls.wipEntityID,
                        l_tbls.orgID,
                        l_tbls.itemID,
                        l_tbls.txnQty,
                        l_tbls.priQty,
                        l_tbls.txnDate,
                        l_tbls.txnTypeID,
                        l_tbls.txnActionID,
                        l_tbls.txnIntID,
                        l_tbls.txnBatchID,
                        l_tbls.txnSeqNum,
                        l_tbls.repLineID,
                        l_tbls.cplTxnID,
                        l_tbls.overCplTxnID,
                        l_tbls.overCplTxnQty,
                        l_tbls.overCplPriQty,
                        l_tbls.movTxnID,
                        l_tbls.wipEntityType,
                        l_tbls.txnUom,
                        l_tbls.priUom,
                        l_tbls.locatorID,
                        l_tbls.projectID,
                        l_tbls.taskID,
                        l_tbls.reasonID,
                        l_tbls.reference;
    close c_assyRecs;

    for i in 1..l_tbls.wipEntityID.count loop
      --derive primary quantity if necessary. This is a line level derivation
      --and thus is not done in doPreProcessingValidations()
      -- Bug 5411401. passing from_qty as absolute for UOM convert in below calls
      --saugupta 31-July-06
      l_convPriQty:= inv_convert.inv_um_convert(item_id => l_tbls.itemID(i),
                                                precision => null,
                                                from_quantity => abs(l_tbls.txnQty(i)),
                                                from_unit => l_tbls.txnUOM(i),
                                                to_unit => l_tbls.priUOM(i),
                                                from_name => null,
                                                to_name => null);

      if(l_tbls.overCplTxnQty(i) is not null) then
        l_convOverCplPriQty := inv_convert.inv_um_convert(item_id => l_tbls.itemID(i),
                                                        precision => null,
                                                        from_quantity => abs(l_tbls.overCplTxnQty(i)),
                                                        from_unit => l_tbls.txnUOM(i),
                                                        to_unit => l_tbls.priUOM(i),
                                                        from_name => null,
                                                        to_name => null);
      end if;

      -- -99999 is weird inv uom error code.
      l_convErrExists := l_convPriQty = -99999 or nvl(l_convOverCplPriQty,0) = -99999;

     /* Fix for Bug 5411401 */
     if (l_tbls.txnQty(i) < 0 and l_convPriQty >= 0) then
       l_convPriQty := -1 * l_convPriQty;
     end if;

     if (l_tbls.overCplTxnQty(i) is not null
           and l_tbls.overCplTxnQty(i) < 0
               and nvl(l_convOverCplPriQty,0) >= 0) then
       l_convOverCplPriQty := -1 * l_convOverCplPriQty ;
     end if;
    /* End of fix for Bug 5411401 */

      if(l_convErrExists) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('uom conversion failed.', l_returnStatus);
          wip_logger.log('l_convPriQty' || l_convPriQty, l_returnStatus);
          wip_logger.log('l_convOverCplPriQty' || l_convOverCplPriQty, l_returnStatus);
        end if;
        fnd_message.set_name('INV', 'INV_INT_UOMEXP');
        l_errExp := fnd_message.get;
        update mtl_transactions_interface
           set  last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id,
                program_application_id = fnd_global.prog_appl_id,
                program_id = fnd_global.conc_program_id,
                program_update_date = sysdate,
                request_id = fnd_global.conc_request_id,
                process_flag = 3,
                lock_flag = 2,
                error_code = 'wip_mti_pub.preInvWIPProcessing',
                error_explanation = l_errExp
          where transaction_interface_id = l_tbls.txnIntID(i);

      elsif(l_convPriQty <> l_tbls.priQty(i) or l_tbls.priQty(i) is null or
            (l_convOverCplPriQty is not null and
             (l_tbls.overCplPriQty(i) is null or l_tbls.overCplPriQty(i) <> l_convOverCplPriQty))) then
        l_tbls.priQty(i) := l_convPriQty;
        l_tbls.overCplPriQty(i) := l_convOverCplPriQty;

        update mtl_transactions_interface
           set last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id,
               program_application_id = fnd_global.prog_appl_id,
               program_id = fnd_global.conc_program_id,
               program_update_date = sysdate,
               request_id = fnd_global.conc_request_id,
               primary_quantity = l_tbls.priQty(i),
               overcompletion_primary_qty = l_tbls.overCplPriQty(i)
         where transaction_interface_id = l_tbls.txnIntID(i);
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('pri qty:' || l_tbls.priQty(i), l_returnStatus);
          wip_logger.log('ovcpl pri qty:' || l_tbls.overCplPriQty(i), l_returnStatus);
        end if;
      end if;

      if(l_tbls.wipEntityType(i) <> wip_constants.flow and not l_convErrExists) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('calling work order row-by-row processor', l_returnStatus);
        end if;
        preInvProcessWorkOrder(p_txnHeaderID => p_txnHeaderID,
                               p_tbls => l_tbls,
                               p_index => i,
                               p_errTbls => l_errTbls,
                               x_returnStatus => l_returnStatus);
      end if;
    end loop;

    if ( l_errTbls.txnIntID is not null ) then
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(l_errTbls.txnIntID.count || ' records failed work order pre-processing', l_returnStatus);
        for i in 1..l_errTbls.txnIntID.count loop
          wip_logger.log('txnIntID: ' || l_errTbls.txnIntID(i),  l_returnStatus);
          wip_logger.log(' errCode: ' || l_errTbls.errCode(i), l_returnStatus);
          wip_logger.log(' errExpl: ' || l_errTbls.errExpl(i), l_returnStatus);
        end loop;
      end if;

      forall i in 1..l_errTbls.txnIntID.count
        update mtl_transactions_interface
           set last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id,
               program_application_id = fnd_global.prog_appl_id,
               program_id = fnd_global.conc_program_id,
               program_update_date = sysdate,
               request_id = fnd_global.conc_request_id,
               process_flag = wip_constants.mti_error,
               error_code = l_errTbls.errCode(i),
               error_explanation = l_errTbls.errExpl(i),
               lock_flag = 2 --unlock the record so it can be re-submitted
         where transaction_interface_id = l_errTbls.txnIntID(i);
    end if;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('calling flow group processor', l_returnStatus);
    end if;

    preInvProcessFlow(p_txnHeaderID => p_txnHeaderID,
                      x_returnStatus => l_returnStatus);


    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_mti_pub.preInvWIPProcessing',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_returnStatus);
      wip_logger.cleanup(l_returnStatus);
    end if;
  exception
    when others then
      rollback to wipmtivb1;
      l_errExp := substrb(SQLERRM, 1, 240);
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;

      update mtl_transactions_interface
         set last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id = fnd_global.conc_program_id,
             program_update_date = sysdate,
             request_id = fnd_global.conc_request_id,
             process_flag = 3,
             lock_flag = 2,
             error_code = 'wip_mti_pub.preInvWIPProcessing',
             error_explanation = l_errExp
       where transaction_header_id = p_txnHeaderID
         and transaction_source_type_id = 5
         and process_flag = wip_constants.mti_inventory;

      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mti_pub.preInvWIPProcessing',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
        wip_logger.cleanup(l_returnStatus);
      end if;
  end preInvWIPProcessing;

  procedure preInvProcessWorkOrder(p_txnHeaderID in number,
                                   p_tbls in mti_recTbl_t,
                                   p_index in number,
                                   p_errTbls in out nocopy mti_err_recTbl_t,
                                   x_returnStatus OUT NOCOPY VARCHAR2) is
    l_txnType NUMBER;
    l_bfRequired NUMBER;
    l_lsRequired NUMBER;
    l_msg VARCHAR2(2000);
    l_errCount NUMBER;
    l_count NUMBER;
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_returnStatus VARCHAR2(1);
  begin
    savepoint wipmtivb10;

    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHeaderID';
      l_params(1).paramValue := p_txnHeaderID;
      l_params(2).paramName := 'p_index';
      l_params(2).paramValue := p_index;

      wip_logger.entryPoint(p_procName     => 'wip_mti_pub.preInvProcessWorkOrder',
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    x_returnStatus := fnd_api.g_ret_sts_success;

    if(p_tbls.txnActionID(p_index) = wip_constants.cplassy_action) then
      l_txnType := wip_constants.comp_txn;
    elsif(p_tbls.txnActionID(p_index) = wip_constants.retassy_action) then
      l_txnType := wip_constants.ret_txn;
    else --scrap. don't do anything
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_mti_pub.preInvWIPProcessing',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'success (scrap txn)',
                             x_returnStatus     => l_returnStatus);
      end if;
      return;
    end if;

    --if repetitive cpl, check allocation table to see if schedule has already been pre-processed
    if(p_tbls.repLineID(p_index) is not null) then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('doing repetitive processing', l_returnStatus);
      end if;
      select count(*)
        into l_count
        from wip_mtl_allocations_temp
       where transaction_temp_id = p_tbls.txnIntID(p_index);

      if(l_count = 0) then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('found unallocated schedule', l_returnStatus);
        end if;
        wip_cplProc_priv.preAllocateSchedules(p_txnHdrID => p_txnHeaderID,
                                              p_cplTxnID => p_tbls.cplTxnID(p_index),
                                              p_txnActionID => p_tbls.txnActionID(p_index),
                                              p_wipEntityID => p_tbls.wipEntityID(p_index),
                                              p_repLineID => p_tbls.repLineID(p_index),
                                              p_tblName => wip_constants.MTI_TBL,
                                              p_endDebug => fnd_api.g_false,
                                              x_returnStatus => x_returnStatus);
        if(x_returnStatus <> fnd_api.g_ret_sts_success) then
          raise fnd_api.g_exc_error;
        end if;

      end if;
    end if;

    select count(*)
      into l_count
      from mtl_transactions_interface
     where transaction_header_id = p_txnHeaderID
       and completion_transaction_id = p_tbls.cplTxnID(p_index)
       and transaction_action_id in (wip_constants.isscomp_action, wip_constants.retcomp_action,
                                     wip_constants.issnegc_action, wip_constants.retnegc_action);
    if(l_count = 0) then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('backflushing cpl', l_returnStatus);
      end if;
      wip_bflProc_priv.backflush(p_wipEntityID    => p_tbls.wipEntityID(p_index),
                                 p_orgID          => p_tbls.orgID(p_index),
                                 p_primaryQty     => abs(p_tbls.priQty(p_index)),
                                 p_txnDate        => p_tbls.txnDate(p_index),
                                 p_txnHdrID       => p_txnHeaderID,
                                 p_batchID        => p_tbls.txnBatchID(p_index),
                                 p_batchSeq       => p_tbls.txnSeqNum(p_index) + 1,
                                 p_txnType        => l_txnType,
                                 p_entityType     => p_tbls.wipEntityType(p_index),
                                 p_tblName        => wip_constants.MTI_TBL,
                                 p_lineID         => p_tbls.repLineID(p_index),
                                 p_ocQty          => p_tbls.overCplPriQty(p_index),
                                 p_childMovTxnID  => p_tbls.movTxnID(p_index),
                                 p_cplTxnID       => p_tbls.cplTxnID(p_index),
                                 p_mtlTxnMode     => inv_txn_manager_grp.PROC_MODE_MTI,
                                 p_lockFlag       => wip_constants.yes,
                                 p_reasonID       => p_tbls.reasonID(p_index),
                                 p_reference      => p_tbls.reference(p_index),
                                 x_bfRequired     => l_bfRequired,
                                 x_lotSerRequired => l_lsRequired,
                                 x_returnStatus   => x_returnStatus);

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('bf required:' || l_bfRequired, l_returnStatus);
        wip_logger.log('ls required:' || l_lsRequired, l_returnStatus);
      end if;
      --if the procedure fails or some lot/serial info for backflush components can not
      --be derived then error
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_error;
      end if;
      if(l_lsRequired = wip_constants.yes) then
        fnd_message.set_name('WIP', 'WIP_NO_LOT_SER_COMP_BKGND');
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
      end if;

    end if;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_mti_pub.preInvWIPProcessing',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_returnStatus);
    end if;
  exception
    when fnd_api.g_exc_error then
      rollback to wipmtivb10;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      l_errCount := extendErrTbls(p_errTbls);
      p_errTbls.txnIntID(l_errCount) := p_tbls.txnIntID(p_index);
      p_errTbls.errCode(l_errCount) := 'WIP_PREPROCESSING';
      wip_utilities.get_message_stack(p_msg => l_msg);
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_mti_pub.preInvWIPProcessing',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'error:' || l_msg,
                             x_returnStatus     => l_returnStatus);
      end if;
      p_errTbls.errExpl(l_errCount) := substrb(l_msg, 1, 240);
    when others then
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_mti_pub.preInvWIPProcessing',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error:' || SQLERRM,
                             x_returnStatus     => l_returnStatus);
      end if;
      rollback to wipmtivb10;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      l_errCount := extendErrTbls(p_errTbls);
      p_errTbls.txnIntID(l_errCount) := p_tbls.txnIntID(p_index);
      p_errTbls.errCode(l_errCount) := 'WIP_PREPROCESSING';
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mti_pub',
                              p_procedure_name => 'preInvProcessWorkOrder',
                              p_error_text => SQLERRM);
      wip_utilities.get_message_stack(p_msg => l_msg);
      p_errTbls.errExpl(l_errCount) := substrb(l_msg, 1, 240);
  end preInvProcessWorkOrder;

  function extendErrTbls(p_errTbl in out nocopy mti_err_recTbl_t) return number is
    begin
      if(p_errTbl.txnIntID is null) then
        p_errTbl.txnIntID := num_tbl_t();
        p_errTbl.errCode := big_char_tbl_t();
        p_errTbl.errExpl := big_char_tbl_t();
      end if;
      p_errTbl.txnIntID.extend(1);
      p_errTbl.errCode.extend(1);
      p_errTbl.errExpl.extend(1);
      return p_errTbl.txnIntId.count;
    end extendErrTbls;

  /**
   * This procedure do the general validation for the interface rows
   * under the given header id.
   */
  procedure validateInterfaceRows(p_txnHeaderID  in  number,
                                  x_returnStatus out nocopy varchar2) is
    cursor cpl_c is
      select organization_id,
             transaction_source_id,
             transaction_interface_id
        from mtl_transactions_interface
       where transaction_header_id = p_txnHeaderID
         and process_flag = 1
         and transaction_source_type_id = 5
         and transaction_action_id in (WIP_CONSTANTS.SCRASSY_ACTION,
                                       WIP_CONSTANTS.CPLASSY_ACTION,
                                       WIP_CONSTANTS.RETASSY_ACTION);
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_msgCount number;
    l_msgData varchar2(240);

  begin
    null;
  end validateInterfaceRows;

  /**
   * Flow transaction is a bit different than others. It has substitution records. Those
   * records can only be validated after we have routing information about the assembly to
   * complete/return/scrap. Also, we can only validate material backflush record after the
   * explosion. Originally, in inltev, inltvu and inltwv, we only validate the parent record.
   * After doing the explosion, merge, etc,  we assign the child record a new header id and
   * validate those child records by calling inltev, inltvu and inltwv again. After that,
   * we merge the parent and child records again under one header id.
   * Instead of calling it twice, for flow transactions, we will do some
   * minimum validation and then explode the bom, merge backflush records. Then we call
   * INV validation and then call wip validation.
   * This procedure is used to do some minimum validation, explode the BOM, validate/merge
   * substitute records.
   * After calling this, at least for flow, all the backflush records and parent records
   * should be grouped nicely into one group to be validated by inv and other wip logic.
   *
   * *** we need to call inv procedure to convert name to id and also get the primary
   * item id *****
   */
  procedure preInvProcessFlow(p_txnHeaderID  in  number,
                              x_returnStatus out nocopy varchar2) is


    l_primaryUOM varchar2(3);
    l_primaryQty number;

    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_errCode varchar2(240);
    l_errMsg varchar2(240);
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
    l_bigErrMsg VARCHAR2(2000);
  begin

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHeaderID';
      l_params(1).paramValue := p_txnHeaderID;
      wip_logger.entryPoint(p_procName => 'wip_mti_pub.preInvProcessFlow',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    -- do derivation and validation only for flow records
    wip_flowUtil_priv.processFlowInterfaceRecords(p_txnHeaderID);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mti_pub.preInvProcessFlow',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Finished pre inventory flow processing!',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mti_pub.preInvProcessFlow',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mti_pub',
                              p_procedure_name => 'preInvProcessFlow',
                              p_error_text => SQLERRM);
      wip_utilities.get_message_stack(p_msg => l_bigErrMsg);
      l_errMsg := substrb(l_bigErrMsg, 1, 240);
  end preInvProcessFlow;


  /**
   * check whether locator is under project mfg. constraint. validate it
   * for the parent record. We don''t do that for scrap.
   */
  procedure validateLocatorForProject(p_txnHeaderID in number) is
    cursor pt_c is
      select transaction_interface_id,
             organization_id,
             inventory_item_id,
             subinventory_code,
             transaction_source_id,
             locator_id,
             source_project_id,
             source_task_id,
             nvl(flow_schedule, 'N') flow_schedule,
             scheduled_flag,
             transaction_action_id
        from mtl_transactions_interface
       where transaction_header_id = p_txnHeaderID
         and process_flag = 1
         and transaction_source_type_id = 5
         and transaction_action_id in (WIP_CONSTANTS.CPLASSY_ACTION,
                                       WIP_CONSTANTS.RETASSY_ACTION,
                                       WIP_CONSTANTS.ISSCOMP_ACTION,
                                       WIP_CONSTANTS.RETCOMP_ACTION,
                                       WIP_CONSTANTS.ISSNEGC_ACTION,
                                       WIP_CONSTANTS.RETNEGC_ACTION);
    l_locatorCntlCode number;
    l_projRefEnabled number;
    l_projID number;
    l_taskID number;

    l_success boolean;
  begin
    for pt_rec in pt_c loop
      -- check for item locator control type
      select decode(p.stock_locator_control_code,
                    4, decode(s.locator_type,
                              5, i.location_control_code,
                              s.locator_type),
                    p.stock_locator_control_code),
             nvl(project_reference_enabled, 2)
        into l_locatorCntlCode,
             l_projRefEnabled
        from mtl_parameters p,
             mtl_secondary_inventories s,
             mtl_system_items i
       where i.inventory_item_id = pt_rec.inventory_item_id
         and i.organization_id = pt_rec.organization_id
         and s.secondary_inventory_name = pt_rec.subinventory_code
         and s.organization_id = pt_rec.organization_id
         and p.organization_id = pt_rec.organization_id;

      if ( l_locatorCntlCode <> 1 and l_projRefEnabled = 1 ) then

        if ( upper(pt_rec.flow_schedule) = 'Y' ) then
          if ( pt_rec.scheduled_flag = 1 ) then
            select project_id, task_id
              into l_projID, l_taskID
              from wip_flow_schedules
             where wip_entity_id = pt_rec.transaction_source_id;
          else
            l_projID := pt_rec.source_project_id;
            l_taskID := pt_rec.source_task_id;
          end if; -- end of scheduled_flag = 1
        else
          select project_id, task_id
            into l_projID, l_taskID
            from wip_discrete_jobs
           where wip_entity_id = pt_rec.transaction_source_id;
        end if; -- end of flow_schedule = 'Y'

        if (pt_rec.transaction_action_id in (WIP_CONSTANTS.CPLASSY_ACTION,
                                             WIP_CONSTANTS.RETASSY_ACTION)) then

          l_success := pjm_project_locator.check_project_references(
                          p_organization_id => pt_rec.organization_id,
                          p_locator_id => pt_rec.locator_id,
                          p_validation_mode => 'SPECIFIC',
                          p_required_flag => 'Y',
                          p_project_id => l_projID,
                          p_task_id => l_taskID);

        else

          -- material transaction
          l_success := pjm_project_locator.check_project_references(
                          p_organization_id => pt_rec.organization_id,
                          p_locator_id => pt_rec.locator_id,
                          p_validation_mode => 'SPECIFIC',
                          p_required_flag => 'N',
                          p_project_id => l_projID,
                          p_task_id => l_taskID);

        end if;

        if ( not l_success ) then
          fnd_message.set_name('INV', 'INV_INT_LOCSEGCODE');
          setMtiError(pt_rec.transaction_interface_id,
                      'locator_id',
                      fnd_message.get);
        end if;

      end if;
    end loop;

  end validateLocatorForProject;


  /**
   * This should be called after calling the inventory validation logic. It
   * does the wip specific validation.
   */
  procedure postInvWIPValidation(p_txnHeaderID  in  number,
                                 x_returnStatus out nocopy varchar2) is

    /*Bug 5708242  - Cursor and variables no longer needed*/
    /*Replacing back the variables and cursor for bug 7300614(FP 7281109) so that validation can be called*/
    cursor nonCfm_c is
      select transaction_interface_id,
             organization_id,
             inventory_item_id,
             transaction_quantity,
             transaction_uom
        from mtl_transactions_interface
       where transaction_header_id = p_txnHeaderID
         and process_flag = 1
         and transaction_source_type_id = 5
         and upper(nvl(flow_schedule, 'N')) = 'N'
         and transaction_action_id in (WIP_CONSTANTS.SCRASSY_ACTION,
                                       WIP_CONSTANTS.CPLASSY_ACTION,
                                       WIP_CONSTANTS.RETASSY_ACTION);

    l_primaryCostMethod number;
    l_cstRetVal number;

    l_priUOM varchar2(3);
    l_priQty number;
    l_errNum number;
    l_errCode varchar2(240);
    l_poExpToAssetTnsf number;
    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_errMsg varchar2(240);
    l_engItemFlag number := 2;
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
  begin

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHeaderID';
      l_params(1).paramValue := p_txnHeaderID;
      wip_logger.entryPoint(p_procName => 'wip_mti_pub.postInvWIPValidation.',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;


    -- check whether locator is under project mfg. constraint. validate it
    -- for the parent record. We don't do that for scrap
    validateLocatorForProject(p_txnHeaderID);

    -- check if it is an assembly completion/return for lot based job. If so error out
    fnd_message.set_name('WIP', 'WIP_NOT_VALID');
    fnd_message.set_token('ENTITY', 'Transactions');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'Transaction',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_type_id in (44, 17)
       and wip_entity_type = 5;

    -- check existence of line for repetitive schedules, job and flow schedule
    fnd_message.set_name('WIP', 'WIP_NOT_VALID');
    fnd_message.set_token('ENTITY', 'line');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'repetitive_line_id',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       and (  (   wip_entity_type = 2
              and not exists(select 'X'
                               from wip_lines wl
                              where wl.line_id = mti.repetitive_line_id
                                and wl.organization_id = mti.organization_id))
            or(    wip_entity_type in (1, 4, 5)
               and repetitive_line_id is not null
               and not exists(select 'X'
                               from wip_lines wl
                              where wl.line_id = mti.repetitive_line_id
                                and wl.organization_id = mti.organization_id)));

    -- check valid line for assembly
    fnd_message.set_name('WIP', 'WIP_INVALID_LINE');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'repetitive_line_id',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and wip_entity_type = 2
       and not exists (select 'X'
                         from wip_repetitive_items wri
                        where wri.wip_entity_id = mti.transaction_source_id
                          and wri.line_id = mti.repetitive_line_id
                          and wri.organization_id = mti.organization_id);


    -- check that job/schedule, etc. is transactable, flow is checked before
    fnd_message.set_name('WIP', 'WIP_NO_CHARGES_ALLOWED');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'transaction_source_id',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and (  (   mti.wip_entity_type in (1, 5, 6)
              and not exists (select 'X'
                                from wip_discrete_jobs wdj
                               where wdj.wip_entity_id = mti.transaction_source_id
                                 and wdj.organization_id = mti.organization_id
                                 and wdj.status_type in (3,4)))
           or (   mti.wip_entity_type = 2
              and not exists (select 'X'
                                from wip_repetitive_schedules wrs
                               where wrs.wip_entity_id = mti.transaction_source_id
                                 and wrs.organization_id = mti.organization_id
                                 and wrs.line_id = mti.repetitive_line_id
                                 and wrs.status_type in (3,4)))
           or mti.wip_entity_type not in (1, 2, 4, 5, 6));


    -- check to see if job/flow has an assembly associated with it
    -- validate this only for completion transactions
    fnd_message.set_name('WIP', 'WIP_NO_ASSY_NO_TXN');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'transaction_source_id',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id in (WIP_CONSTANTS.SCRASSY_ACTION,
                                     WIP_CONSTANTS.CPLASSY_ACTION,
                                     WIP_CONSTANTS.RETASSY_ACTION)
       and (  (exists (select 'X'
                         from wip_discrete_jobs wdj
                        where wdj.wip_entity_id = mti.transaction_source_id
                          and wdj.organization_id = mti.organization_id
                          and wdj.primary_item_id is null))
           or (    upper(nvl(mti.flow_schedule, 'N')) = 'Y'
               and exists (select 'X'
                             from wip_flow_schedules wfs
                            where wfs.wip_entity_id = mti.transaction_source_id
                              and wfs.organization_id = mti.organization_id
                              and primary_item_id is null)));

    -- derive earliest valid schedule
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           schedule_id = (select repetitive_schedule_id
                            from wip_repetitive_schedules wrs1
                           where wrs1.organization_id = mti.organization_id
                             and wrs1.wip_entity_id = mti.transaction_source_id
                             and wrs1.line_id = mti.repetitive_line_id
                             and wrs1.status_type in (3, 4)
                             and wrs1.first_unit_start_date =
                               (select min(wrs2.first_unit_start_date)
                                  from wip_repetitive_schedules wrs2
                                 where wrs2.organization_id = mti.organization_id
                                   and wrs2.wip_entity_id = mti.transaction_source_id
                                   and wrs2.line_id = mti.repetitive_line_id
                                   and wrs2.status_type in (3,4)))
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       and wip_entity_type = 2;


    -- derive op seq num for completions
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           operation_seq_num = (select max(operation_seq_num)
                                  from wip_operations wo
                                 where wo.organization_id = mti.organization_id
                                   and wo.wip_entity_id = mti.transaction_source_id
                                   and (   mti.wip_entity_type in (1,5)
                                        or (    mti.wip_entity_type = 2
                                            and wo.repetitive_schedule_id = mti.schedule_id))
                                   and wo.next_operation_seq_num is null)
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       and transaction_action_id in (WIP_CONSTANTS.CPLASSY_ACTION,
                                     WIP_CONSTANTS.RETASSY_ACTION);

    -- derive op seq num for wip component issue/return
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           operation_seq_num = (select nvl(max(operation_seq_num), 1)
                                  from wip_operations wo
                                 where wo.organization_id = mti.organization_id
                                   and wo.wip_entity_id = mti.transaction_source_id
                                   and (   mti.wip_entity_type in (1,5,6)
                                        or (    mti.wip_entity_type = 2
                                            and wo.repetitive_schedule_id = mti.schedule_id))
                                   and wo.next_operation_seq_num is null)
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       and operation_seq_num is null
       and transaction_action_id in (WIP_CONSTANTS.ISSCOMP_ACTION,
                                     WIP_CONSTANTS.RETCOMP_ACTION);


    -- validate operation seq num
    fnd_message.set_name('WIP', 'WIP_INVALID_OPERATION');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'operation_seq_num',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and wip_entity_type in (1, 2, 5, 6)
       and transaction_action_id in (WIP_CONSTANTS.ISSCOMP_ACTION,
                                     WIP_CONSTANTS.RETCOMP_ACTION,
                                     WIP_CONSTANTS.ISSNEGC_ACTION,
                                     WIP_CONSTANTS.RETNEGC_ACTION)
       and operation_seq_num is not null
       and 0 =(select decode(count(wo.operation_seq_num),
                             0,
                             decode(mti.operation_seq_num, 1, 1, 0),
                             decode(sum(decode(
                                        sign(mti.operation_seq_num-wo.operation_seq_num),
                                        0,
                                        1,
                                        0)),
                                     0,
                                     0,
                                     1))
                 from wip_operations wo
                where wo.wip_entity_id = mti.transaction_source_id
                  and wo.organization_id = mti.organization_id
                  and (   mti.wip_entity_type in (1, 5, 6)
                      or  (   mti.wip_entity_type = 2
                          and wo.repetitive_schedule_id = mti.schedule_id)));


    -- check item transactable
    fnd_message.set_name('WIP', 'WIP_ITEM_NOT_TRANSACTABLE');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    begin
      l_engItemFlag := to_number(fnd_profile.value('WIP_SEE_ENG_ITEMS'));
    exception
    when others then
      l_engItemFlag := 2; -- default to not an engineering item
    end;
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'inventory_item_id',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id in (WIP_CONSTANTS.ISSCOMP_ACTION,
                                     WIP_CONSTANTS.RETCOMP_ACTION,
                                     WIP_CONSTANTS.ISSNEGC_ACTION,
                                     WIP_CONSTANTS.RETNEGC_ACTION)
       and not exists (select 'X'
                         from mtl_system_items msi
                        where msi.organization_id = mti.organization_id
                          and msi.inventory_item_id = mti.inventory_item_id
                          and msi.mtl_transactions_enabled_flag = 'Y'
                          and msi.bom_enabled_flag = 'Y'
                          and msi.eng_item_flag = decode(l_engItemFlag,
                                                         1,
                                                         msi.eng_item_flag,
                                                         'N'))
       and ( (    mti.wip_entity_type in (1,5)
              and not exists(select 'X'
                              from wip_requirement_operations wro
                              where wro.organization_id = mti.organization_id
                                and wro.wip_entity_id = mti.transaction_source_id
                                and wro.inventory_item_id = mti.inventory_item_id
                                and wro.operation_seq_num = mti.operation_seq_num))
           or (   mti.wip_entity_type = 2
              and not exists(select 'X'
                              from wip_requirement_operations wro,
                                   wip_repetitive_schedules wrs
                              where wro.organization_id = mti.organization_id
                                and wro.wip_entity_id = mti.transaction_source_id
                                and wro.inventory_item_id = mti.inventory_item_id
                                and wro.operation_seq_num = mti.operation_seq_num
                                and wrs.organization_id = wro.organization_id
                                and wrs.wip_entity_id = wro.wip_entity_id
                                and wrs.line_id = mti.repetitive_line_id
                                and wrs.repetitive_schedule_id = wro.repetitive_schedule_id
                                and wrs.status_type in (3,4))));


    -- check for shop floor status
    fnd_message.set_name('WIP', 'WIP_STATUS_NO_TXN2');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'operation_seq_num',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION
       and upper(nvl(mti.flow_schedule, 'N')) = 'N'
       and operation_seq_num is not null
       and exists (select 'X'
                     from wip_shop_floor_status_codes wsfsc,
                          wip_shop_floor_statuses wsfs
                    where wsfs.wip_entity_id = mti.transaction_source_id
                      and wsfs.organization_id = mti.organization_id
                      and nvl(wsfs.line_id, -1) = nvl(mti.repetitive_line_id, -1)
                      and wsfs.operation_seq_num = mti.operation_seq_num
                      and wsfs.intraoperation_step_type = 3
                      and wsfs.shop_floor_status_code = wsfsc.shop_floor_status_code
                      and wsfsc.organization_id = mti.organization_id
                      and wsfsc.status_move_flag = 2
                      and nvl(wsfsc.disable_date, sysdate+1) > sysdate);


    -- check for valid final completion flag, this is not required for flow schedules
    fnd_message.set_name('WIP', 'WIP_NOT_VALID');
    fnd_message.set_token('ENTITY', 'final_completion_flag');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'final_completion_flag',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and upper(nvl(flow_schedule, 'N')) = 'N'
       and transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION
       and upper(nvl(final_completion_flag, 'E')) not in ('Y', 'N');


    -- derive item revision for completion txns for discrete jobs
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           revision = (select nvl(mti.revision, wdj.bom_revision)
                         from wip_discrete_jobs wdj
                        where wdj.organization_id = mti.organization_id
                          and wdj.wip_entity_id = mti.transaction_source_id)
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       and transaction_action_id in (WIP_CONSTANTS.CPLASSY_ACTION,
                                     WIP_CONSTANTS.RETASSY_ACTION)
       and wip_entity_type in (1,5)
       and exists(select 'X'
                    from mtl_system_items msi
                   where msi.organization_id = mti.organization_id
                     and msi.inventory_item_id = mti.inventory_item_id
                     and msi.revision_qty_control_code = 2);


    -- derive item revision for completion txns for repetitive
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           revision = (select nvl(mti.revision, wrs.bom_revision)
                         from wip_repetitive_schedules wrs
                        where wrs.organization_id = mti.organization_id
                          and wrs.repetitive_schedule_id = mti.schedule_id)
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       and transaction_action_id in (WIP_CONSTANTS.CPLASSY_ACTION,
                                     WIP_CONSTANTS.RETASSY_ACTION)
       and wip_entity_type = 2
       and exists(select 'X'
                    from mtl_system_items msi
                   where msi.organization_id = mti.organization_id
                     and msi.inventory_item_id = mti.inventory_item_id
                     and msi.revision_qty_control_code = 2);

    -- derive item revision for flow
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           revision = (select nvl(mti.revision, wfs.bom_revision)
                         from wip_flow_schedules wfs
                        where wfs.organization_id = mti.organization_id
                          and wfs.wip_entity_id = mti.transaction_source_id)
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       and transaction_action_id in (WIP_CONSTANTS.CPLASSY_ACTION,
                                     WIP_CONSTANTS.RETASSY_ACTION,
                                     WIP_CONSTANTS.SCRASSY_ACTION)
       and wip_entity_type = 4
       and exists(select 'X'
                    from mtl_system_items msi
                   where msi.organization_id = mti.organization_id
                     and msi.inventory_item_id = mti.inventory_item_id
                     and msi.revision_qty_control_code = 2);

    -- derive completion_transaction_id for flow components
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           completion_transaction_id = (select completion_transaction_id
                                        from mtl_transactions_interface mti2
                                        where mti.parent_id = mti2.transaction_interface_id)
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       -- Fixed bug 4405815. We should only update completion_transaction_id
       -- if it is null.
       and completion_transaction_id is null
       and transaction_action_id in (WIP_CONSTANTS.ISSCOMP_ACTION,
                                     WIP_CONSTANTS.RETCOMP_ACTION,
                                     WIP_CONSTANTS.ISSNEGC_ACTION,
                                     WIP_CONSTANTS.RETNEGC_ACTION)
       and wip_entity_type = 4
       and flow_schedule = 'Y';


    -- validate revision for completion/return/scrap
    fnd_message.set_name('WIP', 'WIP_BOM_ITEM_REVISION');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'revision',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id in (WIP_CONSTANTS.CPLASSY_ACTION,
                                     WIP_CONSTANTS.RETASSY_ACTION,
                                     WIP_CONSTANTS.SCRASSY_ACTION)
       and exists (select 'X'
                     from mtl_system_items msi
                    where msi.organization_id = mti.organization_id
                      and msi.inventory_item_id = mti.inventory_item_id
                      and msi.revision_qty_control_code = 2 )
       and not exists (select 'X'
                         from mtl_item_revisions mir
                        where mir.organization_id = mti.organization_id
                          and mir.inventory_item_id = mti.inventory_item_id
                          and mir.revision = mti.revision);


    -- derive revision for material issue if not supplied.
    -- **** double-check after merge ********
    -- if we explode the BOM and do the merge before calling validation,
    -- then we should include flow entities as well. Otherwise, we should do
    -- that especially for it alone.
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           revision = (select nvl(mti.revision, max(mir.revision))
                         from mtl_item_revisions mir
                        where mir.organization_id = mti.organization_id
                          and mir.inventory_item_id = mti.inventory_item_id
                          and mir.effectivity_date <= sysdate
                          and mir.effectivity_date =
                                    (select max(mir2.effectivity_date)
                                       from mtl_item_revisions mir2
                                      where mir2.organization_id = mti.organization_id
                                        and mir2.inventory_item_id = mti.inventory_item_id
                                        and mir2.effectivity_date <= sysdate))
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       and transaction_action_id in (WIP_CONSTANTS.ISSCOMP_ACTION,
                                     WIP_CONSTANTS.RETCOMP_ACTION,
                                     WIP_CONSTANTS.ISSNEGC_ACTION,
                                     WIP_CONSTANTS.RETNEGC_ACTION)
       and revision is null
       and exists (select 'X'
                     from mtl_system_items msi
                    where msi.organization_id = mti.organization_id
                      and msi.inventory_item_id = mti.inventory_item_id
                      and msi.revision_qty_control_code = 2);


    -- validate item revision for material issue, this is applicable to flow as well
    -- **** double-check after merge *******
    /* Fixed Performance bug 4890679 -
       Replaced bom_bill_released_revisions_v with base tables
       by removing the group by clauses
       which was causing non mergeable views */
    fnd_message.set_name('WIP', 'INV_INT_REVCODE');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'revision',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id in (WIP_CONSTANTS.ISSCOMP_ACTION,
                                     WIP_CONSTANTS.RETCOMP_ACTION,
                                     WIP_CONSTANTS.ISSNEGC_ACTION,
                                     WIP_CONSTANTS.RETNEGC_ACTION)
       and (  (   revision is not null
              and (  (    exists(select 'item under rev ctl'
                                   from mtl_system_items msi
                                  where msi.organization_id = mti.organization_id
                                    and msi.inventory_item_id = mti.inventory_item_id
                                    and msi.revision_qty_control_code = 2)
                      and not exists(select 'rev effective and not an open/hold eco'
                                        FROM ENG_REVISED_ITEMS ERI2,
				            MTL_ITEM_REVISIONS_B MIR ,
					    ENG_REVISED_ITEMS ERI,
					    MTL_ITEM_REVISIONS_B MIR2
				      WHERE MIR.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID(+)
					AND NVL(ERI.STATUS_TYPE,0) NOT IN (1,2)
					AND MIR2.ORGANIZATION_ID(+) = MIR.ORGANIZATION_ID
					AND MIR2.INVENTORY_ITEM_ID(+) = MIR.INVENTORY_ITEM_ID
					AND MIR2.EFFECTIVITY_DATE(+) > MIR.EFFECTIVITY_DATE
					AND MIR2.REVISED_ITEM_SEQUENCE_ID = ERI2.REVISED_ITEM_SEQUENCE_ID(+)
                                        and MIR.organization_id = mti.organization_id
                                        and MIR.inventory_item_id = mti.inventory_item_id
                                        and MIR.revision = mti.revision
                                        and MIR.effectivity_date <= sysdate))
                   or (exists (select 'item not under rev ctl'
                                 from mtl_system_items msi
                                where  msi.organization_id = mti.organization_id
                                  and msi.inventory_item_id = mti.inventory_item_id
                                  and msi.revision_qty_control_code = 1))))
           or (   revision is null
              and (   exists(select 'item is under rev control'
                               from mtl_system_items msi
                              where msi.organization_id = mti.organization_id
                                and msi.inventory_item_id = mti.inventory_item_id
                                and msi.revision_qty_control_code = 2)
                   and not exists (select 'any effective rev'
                                     FROM ENG_REVISED_ITEMS ERI2,
				     MTL_ITEM_REVISIONS_B MIR,
				     ENG_REVISED_ITEMS ERI,
				     MTL_ITEM_REVISIONS_B MIR2
				   WHERE MIR.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID(+)
				     AND NVL(ERI.STATUS_TYPE,0) NOT IN (1,2)
				     AND MIR2.ORGANIZATION_ID(+) = MIR.ORGANIZATION_ID
				     AND MIR2.INVENTORY_ITEM_ID(+) = MIR.INVENTORY_ITEM_ID
				     AND MIR2.EFFECTIVITY_DATE(+) > MIR.EFFECTIVITY_DATE
				     AND MIR2.REVISED_ITEM_SEQUENCE_ID = ERI2.REVISED_ITEM_SEQUENCE_ID(+)
				     and MIR.organization_id = mti.organization_id
                                     and MIR.inventory_item_id = mti.inventory_item_id
                                     and MIR.effectivity_date <= sysdate))));

    -- sign of transaction qty is validated already in inv


    -- validate transaction qty for wip completions.
    -- if there is no routing, then can over complete
    -- we do allow overcomplete for flow schedules, so we don't need to validation
    -- it for flow.
    fnd_message.set_name('WIP', 'WIP_LESS_OR_EQUAL');
    fnd_message.set_token('ENTITY1', 'total txn qty-cap');
    fnd_message.set_token('ENTITY2', 'qty avail to complete');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'transaction_quantity',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION
       and wip_entity_type is not null
       and wip_entity_type <> 4
       and operation_seq_num is not null
       and (primary_quantity - nvl(overcompletion_primary_qty, 0)) >
                              (select sum(quantity_waiting_to_move)
                                 from wip_operations wo
                                where wo.wip_entity_id = mti.transaction_source_id
                                  and wo.organization_id = mti.organization_id
                                  and wo.operation_seq_num = mti.operation_seq_num
                                  and (  mti.wip_entity_type in (1,5)
                                      or (   mti.wip_entity_type = 2
                                         and wo.repetitive_schedule_id in
                                              (select repetitive_schedule_id
                                                 from wip_repetitive_schedules
                                                where wip_entity_id = mti.transaction_source_id
                                                  and organization_id = mti.organization_id
                                                  and line_id = mti.repetitive_line_id
                                                  and status_type in (3,4)))));


    -- validate transaction qty for returns against jobs.
    -- 1. This is done only for scheduled flow completions
    -- 2. according to the comments in inltwv, mmodi, jgu, nsyed, dssosai decided to
    --    drive the completed qty negative for flow schedules
    fnd_message.set_name('WIP', 'WIP_LESS_OR_EQUAL');
    fnd_message.set_token('ENTITY1', 'total txn qty-cap');
    fnd_message.set_token('ENTITY2', 'job compelete quantity');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'transaction_quantity',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id = WIP_CONSTANTS.RETASSY_ACTION
       and (   wip_entity_type in (1,5)
           and (-1*primary_quantity > (select wdj.quantity_completed
                                         from wip_discrete_jobs wdj
                                        where wdj.organization_id = mti.organization_id
                                          and wdj.wip_entity_id = mti.transaction_source_id)));

    -- validate if asset item then cannot complete to expense sub.
    -- if profile is set then only check quantity_tracked, disable_date.
    -- this is applicable to flow as well
    begin
      l_poExpToAssetTnsf := fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER');
    exception
    when others then
      l_poExpToAssetTnsf := 2;
    end;
    fnd_message.set_name('WIP', 'WIP_NO_ASSET_ITEM_MOVE');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'subinventory_code',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id <> WIP_CONSTANTS.SCRASSY_ACTION
       and (  (   l_poExpToAssetTnsf = 2
              and not exists(select 'X'
                               from mtl_secondary_inventories sub,
                                    mtl_system_items msi
                              where msi.organization_id = mti.organization_id
                                and msi.inventory_item_id = msi.inventory_item_id
                                and sub.organization_id = mti.organization_id
                                and sub.secondary_inventory_name = mti.subinventory_code
                                and nvl(sub.disable_date, trunc(sysdate)+1) > trunc(sysdate)
                                and (  (    msi.inventory_asset_flag = 'Y'
                                        and sub.asset_inventory = 1
                                        and sub.quantity_tracked =1 )
                                    or msi.inventory_asset_flag = 'N')))
           or (   l_poExpToAssetTnsf <> 2
              and not exists (select 'X'
                                from mtl_secondary_inventories sub
                               where sub.organization_id = mti.organization_id
                                 and nvl(sub.disable_date, trunc(sysdate)+1) > trunc(sysdate)
                                 and sub.quantity_tracked = 1 )));


    -- transaction must occure after job/schedule is released.
    fnd_message.set_name('WIP', 'WIP_RELEASE_DATE');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'transaction_date',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and (  (   mti.wip_entity_type = 2
              and mti.transaction_date <
                            (select min(wrs.date_released)
                               from wip_repetitive_schedules wrs
                              where wrs.line_id = mti.repetitive_line_id
                                and wrs.organization_id = mti.organization_id
                                and wrs.wip_entity_id = mti.transaction_source_id
                                and wrs.status_type in (3,4)))
           or (   mti.wip_entity_type in (1, 5, 6)
              and mti.transaction_date <
                            (select wdj.date_released
                               from wip_discrete_jobs wdj
                              where wdj.wip_entity_id = mti.transaction_source_id
                                and wdj.organization_id = mti.organization_id
                                and wdj.status_type in (3, 4))));


    -- validate sales order demand for completions and returns
    -- **** do we need to do that for flow? ****
    fnd_message.set_name('WIP', 'WIP_INVALID_SO');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'demand_source_header_id',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and wip_entity_type in (1, 2, 5)
       and demand_source_header_id is not null
       and not exists (select 'X'
                         from mtl_reservations
                        where organization_id = mti.organization_id
                          and inventory_item_id = mti.inventory_item_id
                          and nvl(revision, '--1') = nvl(mti.revision, '--1')
                          and demand_source_type_id = inv_reservation_global.g_source_type_oe
                          and demand_source_header_id = mti.demand_source_header_id
                          and (  (   mti.transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION
                                 and supply_source_header_id = mti.transaction_source_id
                                 and supply_source_type_id =
                                         inv_reservation_global.g_source_type_wip)
                              or (   mti.transaction_action_id = WIP_CONSTANTS.RETASSY_ACTION
                                 and supply_source_type_id =
                                         inv_reservation_global.g_source_type_inv
                                 and subinventory_code = mti.subinventory_code
                                 and nvl(locator_id, -1) = nvl(mti.locator_id, -1) )));

    -- validate demand so line
    fnd_message.set_name('WIP', 'WIP_INVALID_SO_LINE');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'demand_source_line',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and wip_entity_type in (1, 2, 5)
       and demand_source_header_id is not null
       and not exists (select 'X'
                         from mtl_reservations
                        where organization_id = mti.organization_id
                          and inventory_item_id = mti.inventory_item_id
                          and nvl(revision, '--1') = nvl(mti.revision, '--1')
                          and demand_source_type_id =
                                     inv_reservation_global.g_source_type_oe
                          and demand_source_header_id = mti.demand_source_header_id
                          and nvl(demand_source_line_id, -1) =
                                     nvl(to_number(mti.demand_source_line), -1)
                          and (  (   mti.transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION
                                 and supply_source_header_id = mti.transaction_source_id
                                 and supply_source_type_id =
                                         inv_reservation_global.g_source_type_wip)
                              or (   mti.transaction_action_id = WIP_CONSTANTS.RETASSY_ACTION
                                 and supply_source_type_id =
                                         inv_reservation_global.g_source_type_inv
                                 and subinventory_code = mti.subinventory_code
                                 and nvl(locator_id, -1) = nvl(mti.locator_id, -1) )));


    -- validate demand so shipment number for completions
    fnd_message.set_name('WIP', 'WIP_INVALID_SO_SHIPNO_COMP');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'demand_source_delivery',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and wip_entity_type in (1, 2, 5)
       and transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION
       and demand_source_header_id is not null
       and not exists (select 'X'
                         from mtl_reservations
                        where organization_id = mti.organization_id
                          and inventory_item_id = mti.inventory_item_id
                          and nvl(revision, '--1') = nvl(mti.revision, '--1')
                          and demand_source_type_id =
                                    inv_reservation_global.g_source_type_oe
                          and demand_source_header_id = mti.demand_source_header_id
                          and nvl(demand_source_line_id, -1) =
                                    nvl(to_number(mti.demand_source_line), -1)
                          and supply_source_type_id =
                                    inv_reservation_global.g_source_type_wip
                          and supply_source_header_id = mti.transaction_source_id
                          and primary_reservation_quantity >= mti.primary_quantity);


    -- validate demand so shipment number for returns
    fnd_message.set_name('WIP', 'WIP_INVALID_SO_SHIPNO_RET');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'demand_source_delivery',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and wip_entity_type in (1, 2, 5)
       and transaction_action_id = WIP_CONSTANTS.RETASSY_ACTION
       and demand_source_header_id is not null
       and not exists (select 'X'
                         from mtl_reservations
                        where organization_id = mti.organization_id
                          and inventory_item_id = mti.inventory_item_id
                          and nvl(revision, '--1') = nvl(mti.revision, '--1')
                          and demand_source_type_id =
                                    inv_reservation_global.g_source_type_oe
                          and demand_source_header_id = mti.demand_source_header_id
                          and nvl(demand_source_line_id, -1) =
                                    nvl(to_number(mti.demand_source_line), -1)
                          and supply_source_type_id =
                                    inv_reservation_global.g_source_type_inv
                          and subinventory_code = mti.subinventory_code
                          and nvl(locator_id, -1) = nvl(mti.locator_id, -1)
                          and primary_reservation_quantity >= -1*mti.primary_quantity);


    -- validate the kanban card
    -- check that a completion txn does not have both, a kanban card and a sales
    -- order attached. Also only a completion txn can have a kanban card attached
    fnd_message.set_name('WIP', 'WIP_KB_ILLEGAL_CARD');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'kanban_card',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and ( (   transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION
             and demand_source_header_id is not null
             and kanban_card_id is not null)
           or(   transaction_action_id <> WIP_CONSTANTS.CPLASSY_ACTION
             and kanban_card_id is not null));


    -- validate the kanban card
    -- check that the completion subinv, locator, inventory_item_id of the
    -- completion txn against the kanban card
    fnd_message.set_name('WIP', 'WIP_KB_CPL_SUB_LOC_MISMATCH');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'kanban_card',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION
       and kanban_card_id is not null
       and not exists (select 'X'
                         from mtl_kanban_cards mkc
                        where mkc.kanban_card_id = mti.kanban_card_id
                          and mkc.source_type = 4
                          and mkc.organization_id = mti.organization_id
                          and mkc.subinventory_name = mti.subinventory_code
                          and (  mti.locator_id is null
                              or mkc.locator_id = mti.locator_id));


    -- validate the kanban card.
    -- check the status of the kanban card
    fnd_message.set_name('WIP', 'WIP_KB_CPL_STATUS_ILLEGAL');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'kanban_card',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION
       and kanban_card_id is not null
       and not exists (select 'X'
                         from mtl_kanban_cards mkc
                        where mkc.kanban_card_id = mti.kanban_card_id
                          and mkc.organization_id = mti.organization_id
                          and (  mkc.supply_status in (4, 5)
                              or (   mkc.supply_status = 2
                                 and exists
                                     (select 'X'
                                        from mtl_kanban_card_activity mkca
                                       where mkca.kanban_card_id = mti.kanban_card_id
                                         and mkca.organization_id = mti.organization_id
                                         and mkca.document_header_id =
                                             mti.transaction_source_id))));

    -- validate negative requirement flag for rep scheds
    -- this is not required for flow
    fnd_message.set_name('WIP', 'WIP_INVALID_NEG_REQ_FLAG');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'negative_req_flag',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id in (WIP_CONSTANTS.ISSCOMP_ACTION,
                                     WIP_CONSTANTS.RETCOMP_ACTION)
       and wip_entity_type = 2
       and negative_req_flag is not null
       and negative_req_flag not in (1, -1);

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('about to call EAM validations', l_returnStatus);
    end if;

    -- for discrete job, we do not support background transactions for
    -- serialized job
    fnd_message.set_name('WIP', 'WIP_NO_SERIALIZED_JOB_ALLOW');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'transaction_source_id',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and wip_entity_type = 1 -- Discrete Jobs
       and transaction_source_id is not null
       and not exists
           (select 'x'
              from wip_discrete_jobs wdj,
                   wip_entities we
             where wdj.wip_entity_id = mti.transaction_source_id
               and wdj.organization_id = mti.organization_id
               and wdj.wip_entity_id = we.wip_entity_id
               and (we.entity_type = wip_constants.lotbased or
                    wdj.serialization_start_op is null));


    --for assy completions and returns, project/task must match
    --source project/task
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           project_id = source_project_id,
           task_id = source_task_id
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id in (wip_constants.cplassy_action,
                                     wip_constants.retassy_action);


    --call eam specific validations. if it errors, just return error status
    wip_eamMtlProc_priv.validateTxns(p_txnHdrID => p_txnHeaderID,
                                     x_returnStatus => x_returnStatus);

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('EAM validation routine returned:' || x_returnStatus, l_returnStatus);
    end if;

     /* Fix for bug 5708242: Call to cstpacms.validate_move_snap_to_temp has been moved to
        wip_cplProc_priv.processTemp (wipcplpb.pls). Calling it here will commit records to
        CST_COMP_SNAP_TEMP even if error occurs later, and rollback is issued */
    -- do the snapshot moves for non-CFM WIP completions,returns, scraps
    /*Bug 7300614(FP 7281109) Replacing back the code commented in bug 5708242
 	  Now this code calls cstpacms.validate_snap_interface which would validate the CCSI record
    before going for inventory processing. Hence the inventory transaction does not happen
    unless the CCSI is validate. */
    for nonCfm_rec in nonCfm_c loop
      select primary_cost_method
        into l_primaryCostMethod
        from mtl_parameters
       where organization_id = nonCfm_rec.organization_id;

       if ( l_primaryCostMethod in (2, 5, 6) ) then
         select primary_uom_code
           into l_priUOM
           from mtl_system_items
          where organization_id = nonCfm_rec.organization_id
            and inventory_item_id = nonCfm_rec.inventory_item_id;

         l_priQty := inv_convert.inv_um_convert(
                       item_id => nonCfm_rec.inventory_item_id,
                       precision => NULL,
                       from_quantity => nonCfm_rec.transaction_quantity,
                       from_unit => nonCfm_rec.transaction_uom,
                       to_unit => l_priUOM,
                       from_name => NULL,
                       to_name => NULL);

         l_cstRetVal := cstpacms.validate_snap_interface(
                            nonCfm_rec.transaction_interface_id,
                            1, -- for inventory interface
                            l_priQty,
                            l_errNum,
                            l_errCode,
                            l_errMsg);
         if ( l_cstRetVal <> 1 ) then
           setMtiError(nonCfm_rec.transaction_interface_id,
                       l_errCode,
                       l_errMsg);
         end if;
       end if;
    end loop;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mti_pub.postInvWIPValidation',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Finished validating interface rows!',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mti_pub.postInvWIPValidation',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
     update mtl_transactions_interface
         set last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id = fnd_global.conc_program_id,
             program_update_date = sysdate,
             request_id = fnd_global.conc_request_id,
             process_flag = 3,
             lock_flag = 2
       where transaction_header_id = p_txnHeaderID;
  end postInvWIPValidation;


  /**
   * This procedure sets the error status to the mti. It sets the error
   * for the given interface id as well as the child records.
   */
  procedure setMtiError(p_txnInterfaceID in number,
                        p_errCode        in varchar2,
                        p_msgData        in varchar2) is

  begin
    update mtl_transactions_interface
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = substrb(p_errCode, 1, 240),
           error_explanation = substrb(p_msgData, 1, 240)
     where transaction_interface_id = p_txnInterfaceID
        or parent_id = p_txnInterfaceID;
  end setMtiError;

  procedure doPreProcessingValidations(p_txnHeaderID in number,
                                       x_returnStatus out nocopy varchar2) is
    l_returnStatus VARCHAR2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_errCode VARCHAR2(240);
    l_errMsg VARCHAR2(240);
    l_params wip_logger.param_tbl_t;
    l_orgIDTbl num_tbl_t;
    l_rowidTbl rowid_tbl_t;
    l_subCodeTbl big_char_tbl_t;
    l_itemIDTbl num_tbl_t;
/* FP bug 5708701 (base bug 5046732) - commenting the following variables
    l_locIDTbl num_tbl_t;
    l_locSegTbl big_char_tbl_t;
    l_locCtrl NUMBER;
*/
    cursor c_ItemTxns is
      select organization_id,
             rowidtochar(rowid),
             subinventory_code,
             inventory_item_id
             /* FP bug 5708701 (base bug 5046732) - Modified cursor. Need not fetch locator_id and locator segments
             locator_id,
             nvl(loc_segment1, nvl(loc_segment2, nvl(loc_segment3, nvl(loc_segment4,
             nvl(loc_segment5, nvl(loc_segment6, nvl(loc_segment7, nvl(loc_segment8,
             nvl(loc_segment9, nvl(loc_segment10, nvl(loc_segment11, nvl(loc_segment12,
             nvl(loc_segment13, nvl(loc_segment14, nvl(loc_segment15, nvl(loc_segment16,
             nvl(loc_segment17, nvl(loc_segment18, nvl(loc_segment19, loc_segment20)))))))))))))))))))
             */
        from mtl_transactions_interface
       where transaction_header_id = p_txnHeaderID
         and transaction_source_type_id = 5
         and process_flag = wip_constants.mti_inventory
         and (   inventory_item_id is null
              or (    locator_id is null
                  and (   loc_segment1 is not null
                       or loc_segment2 is not null
                       or loc_segment3 is not null
                       or loc_segment4 is not null
                       or loc_segment5 is not null
                       or loc_segment6 is not null
                       or loc_segment7 is not null
                       or loc_segment8 is not null
                       or loc_segment9 is not null
                       or loc_segment10 is not null
                       or loc_segment11 is not null
                       or loc_segment12 is not null
                       or loc_segment13 is not null
                       or loc_segment14 is not null
                       or loc_segment15 is not null
                       or loc_segment16 is not null
                       or loc_segment17 is not null
                       or loc_segment18 is not null
                       or loc_segment19 is not null
                       or loc_segment20 is not null
                      )
                 )
             );
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHeaderID';
      l_params(1).paramValue := p_txnHeaderID;
      wip_logger.entryPoint(p_procName     => 'wip_mti_pub.doPreProcessingValidations',
                            p_params       => l_params,
                            x_returnStatus => l_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

    -- derive transaction action id and transaction source type id,
    -- we need that for the logic that follows. Even though inv validation does
    -- the deriviation, we still needs to do that since we call inv afterwards.
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           transaction_action_id = (select mtt.transaction_action_id
                                      from mtl_transaction_types mtt
                                     where mtt.transaction_type_id =
                                           mti.transaction_type_id),
           transaction_source_type_id = (select mtt.transaction_source_type_id /*bug 4236301 -> changed table alias to mtt */
                                           from mtl_transaction_types mtt
                                          where mtt.transaction_type_id =
                                                mti.transaction_type_id)
    where transaction_header_id = p_txnHeaderID
      and process_flag = 1;

    --make sure the completions have a cpl id and batch id
    --make sure overcompletions have a move id and overcpl id.
    update mtl_transactions_interface
       set completion_transaction_id = nvl(completion_transaction_id, mtl_material_transactions_s.nextval),
           transaction_batch_id = nvl(transaction_batch_id, nvl(completion_transaction_id, mtl_material_transactions_s.nextval)),
           transaction_batch_seq = nvl(transaction_batch_seq, wip_constants.ASSY_BATCH_SEQ),
           overcompletion_transaction_id = nvl(overcompletion_transaction_id, decode(overcompletion_transaction_qty,
                                                                                     null, overcompletion_transaction_id,
                                                                                     wip_transactions_s.nextval)),
           move_transaction_id = nvl(move_transaction_id, decode(overcompletion_transaction_qty,
                                                                                     null, move_transaction_id,
                                                                                     wip_transactions_s.nextval))
     where transaction_header_id = p_txnHeaderID
       and transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action)
       and transaction_source_type_id = 5;

    --make sure flow scrap transactions have a cpl id and batch id
    update mtl_transactions_interface
       set completion_transaction_id = nvl(completion_transaction_id, mtl_material_transactions_s.nextval),
           transaction_batch_id = nvl(transaction_batch_id, nvl(completion_transaction_id, mtl_material_transactions_s.nextval)),
           transaction_batch_seq = nvl(transaction_batch_seq, wip_constants.ASSY_BATCH_SEQ)
     where transaction_header_id = p_txnHeaderID
       and transaction_action_id = wip_constants.scrassy_action
       and upper(nvl(flow_schedule, 'N')) = 'Y'
       and transaction_source_type_id = 5;


    -- validate organization id
    fnd_message.set_name('INV', 'INV_INT_ORGCODE');
    l_errCode := substrb(fnd_message.get, 1, 240);
    fnd_message.set_name('INV', 'INV_INT_ORGEXP');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = l_errCode,
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and not exists (select 'X'
                         from org_organization_definitions ood
                        where ood.organization_id = mti.organization_id
                          and nvl(ood.disable_date, sysdate+1) > sysdate);


    --validate scheduled_flag
    fnd_message.set_name('WIP', 'WIP_INVALID_FLOW_SCHED_FLAG');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'Invalid Scheduled Flag',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and upper(nvl(flow_schedule, 'N')) = 'Y'
       and transaction_action_id in (WIP_CONSTANTS.SCRASSY_ACTION,
                                     WIP_CONSTANTS.CPLASSY_ACTION,
                                     WIP_CONSTANTS.RETASSY_ACTION)
       and nvl(scheduled_flag, -1) not in (1, 2);


    -- validate transaction source name if provided, we won't do
    -- the validation for that if id is provided since id overrides name anyway
    fnd_message.set_name('WIP', 'WIP_NOT_VALID');
    fnd_message.set_token('ENTITY', 'transaction_source_name');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'transaction_source_name',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_source_id is null
       and transaction_source_name is not null
       and not exists (select 'X'
                         from wip_entities we
                        where we.organization_id = mti.organization_id
                          and we.wip_entity_name = mti.transaction_source_name);


    -- derive transaction source id from transaction source name
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           transaction_source_id = (select we.wip_entity_id
                                      from wip_entities we
                                     where we.organization_id = mti.organization_id
                                       and we.wip_entity_name = mti.transaction_source_name)
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_source_name is not null
       and transaction_source_id is null;


    -- validate transaction action
    fnd_message.set_name('INV', 'INV_INT_TRXACTCODE');
    l_errCode := substrb(fnd_message.get, 1, 240);
    fnd_message.set_name('INV', 'INV_INT_TRXACTEXP');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = l_errCode,
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id = WIP_CONSTANTS.SCRASSY_ACTION
       and upper(nvl(flow_schedule, 'N')) <> 'Y';


    -- validate transaction source id
    fnd_message.set_name('INV', 'INV_INT_SRCCODE');
    l_errCode := substrb(fnd_message.get, 1, 240);
    fnd_message.set_name('INV', 'INV_INT_SRCWIPEXP');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = l_errCode,
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and (  (upper(nvl(flow_schedule, 'N')) = 'N'
               and not exists (select null
                                 from wip_entities we
                                where we.organization_id = mti.organization_id
                                  and we.wip_entity_id = mti.transaction_source_id))
            or (upper(nvl(flow_schedule, 'N')) = 'Y'
                and scheduled_flag = 1
                and not exists (select null
                                 from wip_entities we
                                where we.organization_id = mti.organization_id
                                  and we.wip_entity_id = mti.transaction_source_id
                                  and we.entity_type = 4)));

    /* Fix for Bug#4893215 . Make sure that Flow and Work Order-less transaction
     * is processed as one batch - parent+components
     * */

    fnd_message.set_name('INV', 'INV_INT_PROCCODE');
    l_errCode := substrb(fnd_message.get, 1, 240);

    fnd_message.set_name('WIP', 'WIP_NO_PARENT_TRANSACTION');
    l_errMsg := substrb(fnd_message.get, 1, 240);

    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = l_errCode,
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_type_id not in (17, 44, 90, 91) -- No Parent transactions
       and upper(nvl(flow_schedule, 'N')) = 'Y'
       and not exists (select 1
                       from   mtl_transactions_interface mti2
                       where  mti2.transaction_header_id     = p_txnHeaderID
                       and    mti2.transaction_source_type_id = 5
                       and    upper(nvl(flow_schedule, 'N')) = 'Y'
                       and    mti2.transaction_interface_id  = mti.parent_id
                       and    mti2.transaction_type_id in (17, 44, 90, 91) -- Parent Transaction
                       ) ;

    /* Bug 5306902 - Parent WOLC resubmitted without all child component transactions. */

    fnd_message.set_name('INV', 'INV_INT_PROCCODE');
    l_errCode := substrb(fnd_message.get, 1, 240);

    fnd_message.set_name('WIP', 'WIP_PENDING_CHILD_TRANSACTION');
    l_errMsg := substrb(fnd_message.get, 1, 240);

    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = l_errCode,
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and upper(nvl(flow_schedule, 'N')) = 'Y'
       and exists (select 1
                        from   mtl_transactions_interface mti2
		       where   mti2.transaction_source_type_id = 5
                         and    upper(nvl(mti2.flow_schedule, 'N')) = 'Y'
		         and    mti2.parent_id = nvl(mti.parent_id,mti.transaction_interface_id)
                         and    mti2.process_flag = 3
		  ) ;

    -- derive inventory item id if transaction source id is provided
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           inventory_item_id = (select primary_item_id
                                  from wip_entities we
                                 where we.organization_id = mti.organization_id
                                   and we.wip_entity_id = mti.transaction_source_id)
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       and transaction_action_id in (WIP_CONSTANTS.SCRASSY_ACTION,
                                     WIP_CONSTANTS.CPLASSY_ACTION,
                                     WIP_CONSTANTS.RETASSY_ACTION)
       and transaction_source_id is not null;


    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('about to fetch records for name -> item derivation', l_returnStatus);
    end if;
    --item id from name
    open c_itemTxns;
    fetch c_itemTxns
      bulk collect into l_orgIDTbl,
                        l_rowidTbl,
                        l_subCodeTbl,
                        l_itemIDTbl;
                        /* FP bug 5708701 (base bug 5046732) Need not collect data for l_locIDTbl l_locSegTbl
                        l_locIDTbl,
                        l_locSegTbl;
                        */
    close c_itemTxns;
    --set up key flex package for flex -> id derivations
    if(l_orgIDTbl.count > 0) then
      fnd_flex_key_api.set_session_mode('seed_data');
    end if;

    for i in 1..l_orgIDTbl.count loop
      if(l_itemIDTbl(i) is null) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('about to derive item id from name', l_returnStatus);
        end if;
        if(not inv_txn_manager_grp.getitemid(x_itemID => l_itemIDTbl(i),
                                             p_orgID => l_orgIDTbl(i),
                                             p_rowid => l_rowidTbl(i))) then
          l_itemIDTbl(i) := null;--let inventory error out later
          if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('item id from name derivation failed', l_returnStatus);
          end if;
        elsif(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('item id' || l_itemIDTbl(i), l_returnStatus);
        end if;
      end if;

      /* FP bug 5708701 (base bug 5046732) - Removed the code to derive locator id. We do not require locator_id.
      if(l_locIDTbl(i) is null and l_locSegTbl(i) is not null) then
        select decode(mp.stock_locator_control_code,
                      4, decode(sub.locator_type,
                                5, it.location_control_code,
                                sub.locator_type),
                      mp.stock_locator_control_code)
          into l_locctrl
          from mtl_parameters mp,
               mtl_secondary_inventories sub,
               mtl_system_items it
         where it.inventory_item_id = l_itemIDTbl(i)
           and sub.secondary_inventory_name = l_subCodeTbl(i)
           and mp.organization_id = l_orgIDTbl(i)
           and it.organization_id = sub.organization_id
           and mp.organization_id = sub.organization_id
           and mp.organization_id = it.organization_id;

        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('about to derive locator id from name', l_returnStatus);
        end if;
        if(not inv_txn_manager_grp.getlocid(x_locID   => l_locIDTbl(i),
                                            p_org_id  => l_orgIDTbl(i),
                                            p_subinv  => l_subCodeTbl(i),
                                            p_rowid   => l_rowidTbl(i),
                                            p_locCtrl => l_locCtrl)) then
          l_locIDTbl(i) := null; --let inventory error out later
          if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('locator id from name derivation failed', l_returnStatus);
          end if;
        end if;
      end if;
      */

    end loop;
    --now do a bulk update
    forall i in 1..l_orgIDTbl.count
    /* FP bug 5708701 (base bug 5046732) - No need update locator id on MTI. It will be done in inventory code.*/
      update mtl_transactions_interface mti
         set last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id = fnd_global.conc_program_id,
             program_update_date = sysdate,
             request_id = fnd_global.conc_request_id,
             inventory_item_id = l_itemIDTbl(i)
             --locator_id = l_locIdTbl(i)
       where rowid = chartorowid(l_rowidTbl(i));

    /* FP bug 5708701 (base bug 5046732) No need update project id/task id on MTI. It will be done in inventory code.
    --update the project/task based on the derived locator
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           (project_id, task_id) = (select project_id, task_id
                                      from mtl_item_locations mil
                                     where inventory_location_id = mti.locator_id
                                       and organization_id = mti.organization_id)
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and locator_id is not null
       and project_id is null
       and process_flag = wip_constants.mti_inventory;
    */

    -- validate inventory item id
    fnd_message.set_name('INV', 'INV_INT_ITMCODE');
    l_errCode := substrb(fnd_message.get, 1, 240);
    fnd_message.set_name('INV', 'INV_INT_ITMEXP');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = l_errCode,
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and not exists (select 'X'
                         from mtl_system_items msi
                        where msi.inventory_item_id = mti.inventory_item_id
                          and msi.organization_id = mti.organization_id
                          and msi.inventory_item_flag = 'Y');


    -- derive wip_entity_type if transaction source id is provided
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           wip_entity_type = (select entity_type
                                from wip_entities we
                               where we.organization_id = mti.organization_id
                                 and we.wip_entity_id = mti.transaction_source_id)
     where transaction_header_id = p_txnHeaderID
       and transaction_source_type_id = 5
       and process_flag = 1
       and transaction_source_id is not null;

    --derive the source project id/task id for jobs
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           (source_project_id, source_task_id) =
             (select project_id,
                     task_id
                from wip_discrete_jobs
               where wip_entity_id = mti.transaction_source_id
                 and organization_id = mti.organization_id)
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and wip_entity_type in (wip_constants.discrete,
                               wip_constants.lotbased,
                               wip_constants.eam);

    --derive the source project id/task id for flow schedules
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           (source_project_id, source_task_id) =
             (select project_id,
                     task_id
                from wip_flow_schedules
               where wip_entity_id = mti.transaction_source_id
                 and organization_id = mti.organization_id)
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_source_id is not null
       and wip_entity_type = wip_constants.flow;



    -- make sure that flow_schedule flag is 'N' or NULL for job/repetitive and
    -- is Y for flow schedules
    fnd_message.set_name('WIP', 'WIP_FLOW_FLAG_ERROR');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'Invalid flow schedule flag',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and (  (    wip_entity_type <> 4
               and upper(nvl(flow_schedule, 'N')) = 'Y')
           or (    wip_entity_type = 4
               and upper(nvl(flow_schedule, 'N')) <> 'Y') );

    -- for flow schedule, we can't do complete/scrap against a closed schedule
    fnd_message.set_name('WIP', 'WIP_NO_CHARGES_ALLOWED');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'transaction_source_id',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHeaderID
       and process_flag = 1
       and transaction_source_type_id = 5
       and wip_entity_type = 4
       and transaction_source_id is not null
       and transaction_action_id in (WIP_CONSTANTS.SCRASSY_ACTION,
                                     WIP_CONSTANTS.CPLASSY_ACTION)
       and exists (select 1
                     from wip_flow_schedules wfs
                    where wfs.organization_id = mti.organization_id
                      and wfs.wip_entity_id = mti.transaction_source_id
                      and wfs.status = 2);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName     => 'wip_mti_pub.doPreProcessingValidations',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'normal completion',
                           x_returnStatus => l_returnStatus);
    end if;
  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      l_errMsg := substrb(SQLERRM, 1, 240);
      update mtl_transactions_interface
         set last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id = fnd_global.conc_program_id,
             program_update_date = sysdate,
             request_id = fnd_global.conc_request_id,
             process_flag = 3,
             lock_flag = 2,
             error_code = 'wip_mti_pub.doPreProcessingValidations',
             error_explanation = l_errMsg
       where transaction_header_id = p_txnHeaderID
         and transaction_source_type_id = 5
         and process_flag = wip_constants.mti_inventory;

      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mti_pub.doPreProcessingValidations',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end doPreProcessingValidations;

  procedure postInvWIPProcessing(p_txnHeaderID IN NUMBER,
                                 p_txnBatchID IN NUMBER,
                                 x_returnStatus OUT NOCOPY VARCHAR2) is

    l_cplTxnIDTbl num_tbl_t;
    l_movTxnIDTbl num_tbl_t;
    l_errExplTbl big_char_tbl_t;
    l_itemIDTbl num_tbl_t;
    l_orgIDTbl num_tbl_t;
    l_itemNameTbl big_char_tbl_t;
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;

    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHeaderID';
      l_params(1).paramValue := p_txnHeaderID;
      l_params(2).paramName := 'p_txnBatchID';
      l_params(2).paramValue := p_txnBatchID;
      wip_logger.entryPoint(p_procName     => 'wip_mti_pub.postInvWipProcessing',
                            p_params       => l_params,
                            x_returnStatus => l_retStatus);
    end if;
    --delete any pre-allocations that occurred for errored records
    delete wip_mtl_allocations_temp
     where transaction_temp_id in (select transaction_interface_id
                                     from mtl_transactions_interface
                                    where transaction_header_id = p_txnHeaderID
                                      and transaction_batch_id  = p_txnBatchID
                                      and process_flag = wip_constants.mti_error);

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('deleted ' || SQL%ROWCOUNT || ' pre-allocations', l_retStatus);
    end if;

    --fetch all errored components
    select mti.completion_transaction_id,
           mti.move_transaction_id,
           mti.error_explanation,
           mti.inventory_item_id,
           mti.organization_id,
           msik.concatenated_segments
      bulk collect into l_cplTxnIDTbl,
                        l_movTxnIDTbl,
                        l_errExplTbl,
                        l_itemIDTbl,
                        l_orgIDTbl,
                        l_itemNameTbl
      from mtl_transactions_interface mti,
           mtl_system_items_kfv msik
     where mti.transaction_header_id = p_txnHeaderID
       and mti.transaction_batch_id = p_txnBatchID
       and mti.transaction_action_id in (wip_constants.isscomp_action, wip_constants.retcomp_action,
                                     wip_constants.issnegc_action, wip_constants.retnegc_action)
       and upper(nvl(mti.flow_schedule,'N')) <> 'Y'
       and (   mti.completion_transaction_id is not null
            or mti.move_transaction_id is not null)
       and mti.process_flag = wip_constants.mti_error
       and mti.error_explanation is not null --records that caused errors have err expl
       and mti.inventory_item_id = msik.inventory_item_id
       and mti.organization_id = msik.organization_id;

    --delete all errored backflush components
    delete mtl_transactions_interface
     where transaction_header_id = p_txnHeaderID
       and transaction_batch_id = p_txnBatchID
       and transaction_action_id in (wip_constants.isscomp_action, wip_constants.retcomp_action,
                                     wip_constants.issnegc_action, wip_constants.retnegc_action)
       and upper(nvl(flow_schedule,'N')) <> 'Y'
       and (   completion_transaction_id is not null
            or move_transaction_id is not null)
       and process_flag = wip_constants.mti_error;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('deleted ' || SQL%ROWCOUNT || ' backflush components', l_retStatus);
    end if;

    --if any components failed update the parent with the error
    forall i in 1..l_errExplTbl.count
      update mtl_transactions_interface mti
         set last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id = fnd_global.conc_program_id,
             program_update_date = sysdate,
             request_id = fnd_global.conc_request_id,
             error_code = substrb(l_itemNameTbl(i), 1, 240),
             error_explanation = l_errExplTbl(i)
       where transaction_header_id = p_txnHeaderID
         and transaction_batch_id = p_txnBatchID
         and transaction_source_type_id = 5
         and (   completion_transaction_id = l_cplTxnIDTbl(i)
              or move_transaction_id = l_movTxnIDTbl(i))
         and transaction_action_id in (wip_constants.cplassy_action, wip_constants.retassy_action);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mti_pub.postInvWIPProcessing',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'success',
                           x_returnStatus => l_retStatus); --discard logging return status
      wip_logger.cleanup(l_retStatus);
    end if;

  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mti_pub.postInvWIPProcessing',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_retStatus); --discard logging return status
        wip_logger.cleanup(l_retStatus);
      end if;
  end postInvWIPProcessing;
end wip_mti_pub;

/
