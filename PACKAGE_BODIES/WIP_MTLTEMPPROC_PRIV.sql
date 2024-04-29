--------------------------------------------------------
--  DDL for Package Body WIP_MTLTEMPPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MTLTEMPPROC_PRIV" as
 /* $Header: wiptmpvb.pls 120.3.12010000.3 2010/01/27 00:21:15 ntangjee ship $ */

  non_txactable_value CONSTANT VARCHAR2(1) := 'N';

  g_pkgName VARCHAR2(30) := 'wip_mtlTempProc_priv';

  procedure processTemp(p_initMsgList IN VARCHAR2,
                        p_txnHdrID IN NUMBER,
                        p_txnMode IN NUMBER,
                        p_destroyQtyTrees IN VARCHAR2 := null,
                        p_endDebug IN VARCHAR2 := null,
                        x_returnStatus OUT NOCOPY VARCHAR2,
                        x_errorMsg OUT NOCOPY VARCHAR2) IS
  l_errMsg VARCHAR2(2000);
  l_errCode VARCHAR2(2000);
  l_params wip_logger.param_tbl_t;
  l_retStatus VARCHAR2(1);
  l_logRetStatus VARCHAR2(1);
  l_retCode NUMBER;
  l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
  l_flowSchedCount NUMBER;
  l_invStatus NUMBER;
  l_count NUMBER;
  cursor c_rows is
    select transaction_temp_id
      from mtl_material_transactions_temp
     where transaction_header_id = p_txnHdrID;

  begin
-------------------------------------------------------------
--Initial Preprocessing
-------------------------------------------------------------

    savepoint wiptmpvb0;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_initMsgList';
      l_params(1).paramValue := p_initMsgList;
      l_params(2).paramName := 'p_txnHdrID';
      l_params(2).paramValue := p_txnHdrID;
      l_params(3).paramName := 'p_txnMode';
      l_params(3).paramValue := p_txnMode;
      l_params(4).paramName := 'p_destroyQtyTrees';
      l_params(4).paramValue := p_destroyQtyTrees;
      wip_logger.entryPoint(p_procName     => 'wip_mtlTempProc_priv.processTemp',
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

    if(fnd_api.to_boolean(p_initMsgList)) then
      fnd_msg_pub.initialize;
    end if;

    l_retCode := inv_lpn_trx_pub.process_lpn_trx(p_trx_hdr_id => p_txnHdrID,
                                                 p_proc_mode => p_txnMode,
                                                 x_proc_msg => l_errMsg);

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('inv returned:' || l_retCode, l_retStatus);
      wip_logger.log('inv errmsg:' || l_errMsg, l_retStatus);
    end if;

    --for some reason TM errors clear the stack so we must put the
    --error message back, but successful txns do not clear the stack
    if(l_retCode <> 0) then
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_errMsg);
      fnd_msg_pub.add;
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                      p_delete_stack => fnd_api.g_false);
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    else
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                      p_delete_stack => fnd_api.g_false);
    end if;


-------------------------------------------------------------
--Cleanup Processing
-------------------------------------------------------------
    if(fnd_api.to_boolean(nvl(p_destroyQtyTrees, fnd_api.g_false))) then
      inv_quantity_tree_pub.clear_quantity_cache;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_mtlTempProc_priv.processTemp',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
      if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_false))) then
        wip_logger.cleanup(l_retStatus);
      end if;
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      rollback to wiptmpvb0;
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                     p_delete_stack => fnd_api.g_false,
                                     p_separator => ' ');
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_mtlTempProc_priv.processTemp',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unhandled exception: ' || SQLERRM,
                             x_returnStatus     => l_retStatus);
        if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_false))) then
          wip_logger.cleanup(l_retStatus);
        end if;
      end if;
    when others then
      rollback to wiptmpvb0;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'wip_mtlTempProc_priv',
                              p_procedure_name => 'processTemp',
                              p_error_text     => SQLERRM);
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                     p_delete_stack => fnd_api.g_false,
                                     p_separator => ' ');
      fnd_message.set_name('WIP', 'MTL_PROC_FAIL');
      l_errCode := fnd_message.get;

      update mtl_material_transactions_temp
         set process_flag = 'E',
             error_code = substr(l_errCode,1,240),
             error_explanation = substr(x_errorMsg,1,240)
       where transaction_header_id = p_txnHdrID
         and process_flag in ('Y', 'W')
         and transaction_source_type_id = 5
         and transaction_action_id in (wip_constants.isscomp_action,
                                       wip_constants.retcomp_action,
                                       wip_constants.issnegc_action,
                                       wip_constants.retnegc_action);

      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_mtlTempProc_priv.processTemp',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unhandled exception: ' || SQLERRM,
                             x_returnStatus     => l_retStatus);
        if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_false))) then
          wip_logger.cleanup(l_retStatus);
        end if;
      end if;
  end processTemp;

  procedure processWIP(p_txnTmpID IN NUMBER,
                       p_processLpn IN VARCHAR2,
                       p_endDebug in VARCHAR2 := null,
                       x_returnStatus OUT NOCOPY VARCHAR2,
                       x_errorMsg OUT NOCOPY VARCHAR2) is
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_procName VARCHAR2(20) := 'processWIP';
    l_txnActionID NUMBER;
    l_wipEntityType NUMBER;
    l_orgID NUMBER;
    l_wipEntityID NUMBER;
    l_lpnID NUMBER;
    l_repLineID NUMBER;
    l_postingFlag VARCHAR2(1);
    l_flowSchedule VARCHAR2(1);
    l_opSeq number;
    l_supplyType number;
    /*Bug 6417742 (FP of 6342851): Added following variables*/
    l_transaction_header_id number;
    l_transaction_type_id number;
    returnStatus varchar2(1);
    l_msg_count number;
    error varchar2(241);
    labelStatus varchar2(1);
    l_msg_stack VARCHAR2(2000);
    dummyErrCode VARCHAR2(1);
  begin
    savepoint wiptmpvb100;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnTmpID';
      l_params(1).paramValue := p_txnTmpID;
      l_params(2).paramName := 'p_processLpn';
      l_params(2).paramValue := p_processLpn;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    x_returnStatus := fnd_api.g_ret_sts_success;

    select transaction_action_id,
           transaction_header_id,   /*Added for bug 6417742(FP of 6342851)*/
           transaction_type_id,     /*Added for bug 6417742(FP of 6342851)*/
           decode(flow_schedule, --treat wol cpls as flow
                  'Y', wip_constants.flow,
                  wip_entity_type),
           nvl(content_lpn_id, lpn_id),
           transaction_source_id,
           organization_id,
           posting_flag,
           flow_schedule,
           operation_seq_num,
           wip_supply_type
      into l_txnActionID,
           l_transaction_header_id,   /*Added for bug 6417742(FP of 6342851)*/
           l_transaction_type_id,     /*Added for bug 6417742(FP of 6342851)*/
           l_wipEntityType,
           l_lpnID,
           l_wipEntityID,
           l_orgID,
           l_postingFlag,
           l_flowSchedule,
           l_opSeq,
           l_supplyType
      from mtl_material_transactions_temp
     where transaction_temp_id = p_txnTmpID
       and transaction_source_type_id = 5;

    -- delete the record if it is for phantom
    if ( l_opSeq < 0 and l_supplyType = 6 ) then

        delete mtl_material_transactions_temp
        where transaction_temp_id = p_txnTmpID;

        if(l_logLevel <= wip_constants.trace_logging) then
          wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'success: phantom record deleted without any action',
                             x_returnStatus     => l_retStatus);
          if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_false))) then
            wip_logger.cleanup(l_retStatus);
          end if;
        end if;
      return;
    end if;

    --wip entity type should be populated. do this as an added check
    if(l_wipEntityType is null) then
      select entity_type
        into l_wipEntityType
        from wip_entities
       where wip_entity_id = l_wipEntityID
         and organization_id = l_orgID;
    end if;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('txnActID: ' || l_txnActionID, l_retStatus);
      wip_logger.log('wipEntityType: ' || l_wipEntityType, l_retStatus);
      wip_logger.log('lpnID: ' || l_lpnID, l_retStatus);
      wip_logger.log('wipEntityID: ' || l_wipEntityID, l_retStatus);
      wip_logger.log('orgID: ' || l_orgID, l_retStatus);
      wip_logger.log('postingFlag: ' || l_postingFlag, l_retStatus);
      wip_logger.log('FlowSchedule: ' || l_flowSchedule, l_retStatus);
    end if;

    --component issues
    if(l_txnActionID in (wip_constants.isscomp_action, wip_constants.retcomp_action,
                         wip_constants.issnegc_action, wip_constants.retnegc_action)) then
      --no action is necessary for flow txns
      if(l_wipEntityType <> wip_constants.flow) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('calling component processor', l_retStatus);
        end if;
        wip_mtlProc_priv.processTemp(p_initMsgList => fnd_api.g_false,
                                     p_endDebug => fnd_api.g_false,
                                     p_txnTmpID => p_txnTmpID,
                                     x_returnStatus => x_returnStatus);
      end if;

    elsif(l_txnActionID in (wip_constants.cplassy_action, wip_constants.retassy_action)) then
      --no action is necessary for lpn completions
      if(l_lpnID is null or fnd_api.to_boolean(p_processLpn)) then
        if(l_wipEntityType = wip_constants.flow) then
          if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('calling flow/wol processor', l_retStatus);
          end if;
          wip_cfmProc_priv.processTemp(p_initMsgList => fnd_api.g_false,
                                       p_txnTempID => p_txnTmpID,
                                       x_returnStatus => x_returnStatus);
        else --non flow completion
          if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('calling cpl processor', l_retStatus);
          end if;
          wip_cplProc_priv.processTemp(p_txnTmpID => p_txnTmpID,
                                       p_initMsgList => fnd_api.g_false,
                                       p_endDebug => fnd_api.g_false,
                                       x_returnStatus => x_returnStatus);
        end if;
      end if;
    elsif(l_txnActionID = wip_constants.scrassy_action) then
      --for repetitive, must do allocation
      if(l_wipEntityType = wip_constants.repetitive) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('calling rep scrap processor', l_retStatus);
        end if;
        wip_movProc_priv.repetitive_scrap(p_tmp_id => p_txnTmpID,
                                          x_returnStatus => x_returnStatus);
      elsif (l_wipEntityType = wip_constants.flow) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('calling flow/wol processor', l_retStatus);
        end if;
        wip_cfmProc_priv.processTemp(p_initMsgList => fnd_api.g_false,
                                     p_txnTempID => p_txnTmpID,
                                     x_returnStatus => x_returnStatus);
      end if;
    end if;

    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
      if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_false))) then
        wip_logger.cleanup(l_retStatus);
      end if;
    end if;

    /*Start - Bug 6417742(FP of 6342851): Added call label printing*/
    /* Fix bug 8901142 (FP of 8585291) Added criteria to prevent printing label
       twice for LPN completion/drop transaction */
    if ( l_txnActionID = WIP_CONSTANTS.CPLASSY_ACTION and
         l_flowSchedule = 'Y' and
         l_transaction_type_id = WIP_CONSTANTS.CPLASSY_TYPE and
         (l_lpnID is null or fnd_api.to_boolean(p_processLpn))) then
         -- print label
      wip_utilities.print_label(p_txn_id => l_transaction_header_id,  -- should be transaction header id
                                p_table_type => 2, --MMTT
                                p_ret_status => returnStatus,
                                p_msg_count  => l_msg_count,
                                p_msg_data   => error,
                                p_label_status => labelStatus,
                                p_business_flow_code => 33); -- discrete business flow code

              -- do not error out if label printing, only put warning message in log
      if(returnStatus <> fnd_api.g_ret_sts_success) then
        WIP_UTILITIES.get_message_stack(p_msg => l_msg_stack);
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log(p_msg => 'An error has occurred with label printing.\n' ||
                                  'The following error has occurred during ' ||
                                  'printing: ' || l_msg_stack || '\n' ||
                                  'Please check the Inventory log file for more ' ||
                                  'information.',
                         x_returnStatus =>dummyErrCode);
        end if;
      end if;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(p_msg => 'Label printing returned with status ' || returnStatus,
                       x_returnStatus => dummyErrCode);
      end if;
    end if;
    /*End - Bug 6417742(FP of 6342851): Added call label printing*/


  exception
    when fnd_api.g_exc_unexpected_error then
      rollback to wiptmpvb100;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                       p_delete_stack => fnd_api.g_false);
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'error:' || x_errorMsg,
                             x_returnStatus     => l_retStatus);
        if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_false))) then
          wip_logger.cleanup(l_retStatus);
        end if;
      end if;
    when others then
      rollback to wiptmpvb100;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkgName,
                              p_procedure_name => l_procName,
                              p_error_text => SQLERRM);
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                      p_delete_stack => fnd_api.g_false);
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error:' || x_errorMsg,
                             x_returnStatus     => l_retStatus);
        if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_false))) then
          wip_logger.cleanup(l_retStatus);
        end if;
      end if;
  end processWIP;

  procedure validateInterfaceTxns(p_txnHdrID in NUMBER,
                                  p_initMsgList in VARCHAR2 := null,
                                  p_endDebug in VARCHAR2 := null,
                                  p_numRows IN NUMBER := null,
                                  p_addMsgToStack IN VARCHAR2 := null,
                                  p_rollbackOnErr IN VARCHAR2 := null,
                                  x_returnStatus out nocopy VARCHAR2) is
    l_retCode NUMBER;
    l_numIntRows NUMBER := p_numRows;
    l_numTempRows NUMBER;
    l_numErrRows NUMBER;
    l_msgCount NUMBER;
    l_msgData VARCHAR2(2000);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    type err_tbl_t is table of varchar2(240);
    type item_tbl_t is table of varchar2(2000);
    l_errExplTbl err_tbl_t;
    l_itemNameTbl item_tbl_t;
    l_procName VARCHAR2(30) := 'validateInterfaceTxns';
    l_endDebug VARCHAR2(1) := nvl(p_endDebug, fnd_api.g_false);
    l_retStatus VARCHAR2(1);
  begin
    savepoint wiptmpvb200;
    x_returnStatus := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHdrID';
      l_params(1).paramValue := p_txnHdrID;

      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(fnd_api.to_boolean(nvl(p_initMsgList, fnd_api.g_false))) then
      fnd_msg_pub.initialize;
    end if;

    if(l_numIntRows is null) then
      select count(*)
        into l_numIntRows
        from mtl_transactions_interface
       where transaction_header_id = p_txnHdrID
         and process_flag = wip_constants.mti_inventory;
    end if;

    if(l_numIntRows = 0) then
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'no rows to backflush',
                             x_returnStatus     => l_retStatus);
        if(fnd_api.to_boolean(l_endDebug)) then
          wip_logger.cleanup(l_retStatus);
        end if;
      end if;
      return;
    end if;

    l_retCode := inv_txn_manager_grp.validate_transactions(p_api_version => 1.0,
                                                           p_init_msg_list => nvl(p_initMsgList, fnd_api.g_false),
                                                           p_validation_level => fnd_api.g_valid_level_none,
                                                           p_header_id => p_txnHdrID,
                                                           x_trans_count => l_numTempRows,
                                                           x_return_status => x_returnStatus,
                                                           x_msg_count => l_msgCount,
                                                           x_msg_data => l_msgData);

    --x_trans_count out param is not supported yet
    select count(*)
      into l_numErrRows
      from mtl_transactions_interface
     where transaction_header_id = p_txnHdrID;

    select count(*)
      into l_numTempRows
      from mtl_material_transactions_temp
     where transaction_header_id = p_txnHdrID;

    --after inv supports x_trans_count, change if below
--    if(l_numTempRows = l_numIntRows) then
    if(l_numErrRows = 0) then
      if(fnd_api.to_boolean(nvl(p_initMsgList, fnd_api.g_false))) then
        fnd_msg_pub.initialize;
      end if;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'normal completion. ' || l_numTempRows || ' rows processed.',
                             x_returnStatus     => l_retStatus);
        if(fnd_api.to_boolean(l_endDebug)) then
          wip_logger.cleanup(l_retStatus);
        end if;
      end if;
      return;
    end if;

    --if any rows errored...
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    if(fnd_api.to_boolean(nvl(p_addMsgToStack, fnd_api.g_true))) then
      --re-initialize message stack
      if(fnd_api.to_boolean(nvl(p_initMsgList, fnd_api.g_false))) then
        fnd_msg_pub.initialize;
      end if;

      select msik.concatenated_segments,
             mti.error_explanation
        bulk collect into l_itemNameTbl,
                          l_errExplTbl
        from mtl_transactions_interface mti,
             mtl_system_items_kfv msik
       where mti.transaction_header_id = p_txnHdrID
         and mti.error_explanation is not null
         and mti.inventory_item_id = msik.inventory_item_id
         and mti.organization_id = msik.organization_id;

      for i in 1..l_itemNameTbl.count loop
        fnd_message.set_name('WIP', 'WIP_TMPINSERT_ERR');
        fnd_message.set_token('ITEM_NAME', l_itemNameTbl(i));
        fnd_message.set_token('ERR_MSG', l_errExplTbl(i));
        if(l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log('item ' || l_itemNameTbl(i) || ': ' || l_errExplTbl(i), l_retStatus);
        end if;
        fnd_msg_pub.add;
      end loop;
    end if;

    if(fnd_api.to_boolean(nvl(p_rollBackOnErr, fnd_api.g_true))) then
      rollback to wiptmpvb200;
    end if;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => to_char(l_numIntRows - l_numTempRows) || ' records errored',
                           x_returnStatus     => l_retStatus);
      if(fnd_api.to_boolean(l_endDebug)) then
        wip_logger.cleanup(l_retStatus);
      end if;
    end if;

   exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(fnd_api.to_boolean(nvl(p_rollBackOnErr, fnd_api.g_true))) then
        rollback to wiptmpvb200;
      else --caller wants error in MTI
        wip_utilities.get_message_stack(p_msg => l_msgData,
                                        p_delete_stack => fnd_api.g_false);

        update mtl_transactions_interface
           set last_update_date = sysdate,
               last_update_login = fnd_global.login_id,
               program_application_id = fnd_global.prog_appl_id,
               program_id = fnd_global.conc_program_id,
               program_update_date = sysdate,
               request_id = fnd_global.conc_request_id,
               process_flag = wip_constants.mti_error,
               error_code = substrb(g_pkgName || '.' || l_procName, 1, 240),
               error_explanation = substrb(l_msgData, 1, 240)
         where transaction_header_id = p_txnHdrID;
      end if;

      if(l_msgData is not null) then
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_msgData);
        fnd_msg_pub.add;
      end if;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'error:' || l_msgData,
                             x_returnStatus     => l_retStatus);
        if(fnd_api.to_boolean(l_endDebug)) then
          wip_logger.cleanup(l_retStatus);
        end if;
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkgName,
                              p_procedure_name => l_procName,
                              p_error_text => SQLERRM);

      if(fnd_api.to_boolean(nvl(p_rollBackOnErr, fnd_api.g_true))) then
        rollback to wiptmpvb200;
      else
        wip_utilities.get_message_stack(p_msg => l_msgData,
                                        p_delete_stack => fnd_api.g_false);

        update mtl_transactions_interface
           set last_update_date = sysdate,
               last_update_login = fnd_global.login_id,
               program_application_id = fnd_global.prog_appl_id,
               program_id = fnd_global.conc_program_id,
               program_update_date = sysdate,
               request_id = fnd_global.conc_request_id,
               process_flag = wip_constants.mti_error,
               error_code = substrb(g_pkgName || '.' || l_procName, 1, 240),
               error_explanation = substrb(l_msgData, 1, 240)
         where transaction_header_id = p_txnHdrID;
      end if;

      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error:' || l_msgData,
                             x_returnStatus     => l_retStatus);
        if(fnd_api.to_boolean(l_endDebug)) then
          wip_logger.cleanup(l_retStatus);
        end if;
      end if;
    end validateInterfaceTxns;

end wip_mtlTempProc_priv;

/
