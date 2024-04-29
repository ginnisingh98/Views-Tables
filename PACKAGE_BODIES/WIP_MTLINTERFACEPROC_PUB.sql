--------------------------------------------------------
--  DDL for Package Body WIP_MTLINTERFACEPROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MTLINTERFACEPROC_PUB" as
/* $Header: wipintpb.pls 120.0.12000000.2 2007/05/17 13:37:06 mraman ship $ */

  type err_tbl_t is table of varchar2(240);
  type num_tbl_t is table of number;

  /*forward declarations */
  procedure processInterfaceRows(p_initMsgList IN VARCHAR2,
                                 p_processInv IN VARCHAR2,
                                 p_endDebug IN VARCHAR2,
                                 p_txnHdrID IN NUMBER,
                                 x_returnStatus OUT NOCOPY VARCHAR2);

  /* public procedures */
  procedure processInterface(p_txnHdrID IN NUMBER,
                             p_commit IN VARCHAR2 := fnd_api.g_false,
                             x_returnStatus OUT NOCOPY VARCHAR2) is
    l_returnStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_errCodeTbl err_tbl_t;
    l_errExpTbl err_tbl_t;
    l_intTbl num_tbl_t;
    l_errMessage VARCHAR2(2000);
    l_errCount NUMBER;
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
  begin
    savepoint wipintpb0;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHdrID';
      l_params(1).paramValue := p_txnHdrID;
      wip_logger.entryPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterface',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
    end if;

    fnd_msg_pub.initialize;

    processInterfaceRows(p_initMsgList  => fnd_api.g_true,
                         p_processInv   => fnd_api.g_true,
                         p_endDebug     => fnd_api.g_false,
                         p_txnHdrID     => p_txnHdrID,
                         x_returnStatus => x_returnStatus);

    --unexpected error occurred, return status gets set to unexpected error
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(fnd_api.to_boolean(p_commit)) then
      commit;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'attempted to process all rows successfully (no exceptions encountered).',
                           x_returnStatus => l_returnStatus); --discard logging return status
      wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      wip_utilities.get_message_stack(p_msg => l_errMessage,
                                      p_separator => ' ',
                                      p_delete_stack => fnd_api.g_false);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterface',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'proc failure:' || l_errMessage,
                             x_returnStatus => l_returnStatus); --discard logging return status

        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;

      l_errMessage := substr(l_errMessage,1,240);

      select transaction_interface_id, error_code, error_explanation
        bulk collect into l_intTbl, l_errCodeTbl, l_errExpTbl
        from mtl_transactions_interface
       where transaction_header_id = p_txnHdrID
         and process_flag = 3;

      rollback to wipintpb0;

      for i in 1..l_intTbl.count loop
        update mtl_transactions_interface
           set error_code = l_errCodeTbl(i),
               error_explanation = l_errExpTbl(i),
               process_flag = wip_constants.mti_error
         where transaction_header_id = p_txnHdrID
           and transaction_interface_id = l_intTbl(i);
      end loop;
    when others then --some unhandled exception occurred. rollback everything.
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterface',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'exception' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status

        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      rollback to wipintpb0;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mtlInterfaceProc_pub',
                              p_procedure_name => 'processInterface',
                              p_error_text => SQLERRM);
      wip_utilities.get_message_stack(p_msg => l_errMessage,
                                      p_separator => ' ',
                                      p_delete_stack => fnd_api.g_false);
      l_errMessage := substr(l_errMessage,1,240);
      update mtl_transactions_interface
         set error_code = 'wip_mtlInterfaceProc_pub.processInterface()',
             error_explanation = l_errMessage,
             process_flag = wip_constants.mti_error
       where transaction_header_id = p_txnHdrID;
  end processInterface;

  procedure processInterface(p_txnIntID IN NUMBER,
                             p_commit IN VARCHAR2 := fnd_api.g_false,
                             x_returnStatus OUT NOCOPY VARCHAR2,
                             x_errorMsg OUT NOCOPY VARCHAR2) is
    l_rowID rowid;
    l_txnHdrID NUMBER;

    cursor c_mtiRow is
      select error_explanation
        from mtl_transactions_interface
       where transaction_interface_id = p_txnIntID;
    l_params wip_logger.param_tbl_t;
    l_msg VARCHAR2(100);
    l_returnStatus VARCHAR2(1);
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
  begin
    savepoint wipintpb10;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnIntID';
      l_params(1).paramValue := p_txnIntID;
      wip_logger.entryPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterface',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_error;
      end if;
      wip_logger.cleanUp(x_returnStatus=>l_returnStatus);
    end if;

    --must be a single wip transaction that has not yet errored
    select rowid, transaction_header_id
      into l_rowID, l_txnHdrID
      from mtl_transactions_interface
     where transaction_interface_id = p_txnIntID
       and transaction_source_type_id = 5
       and process_flag = wip_constants.mti_inventory;


    processInterfaceRows(p_initMsgList   => fnd_api.g_true,
                         p_processInv    => fnd_api.g_true,
                         p_endDebug      => fnd_api.g_false,
                         p_txnHdrID      => l_txnHdrID,
                         x_returnStatus  => x_returnStatus);


    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      l_msg := 'process interface rows failed';
      raise fnd_api.g_exc_error;
    end if;


    if(fnd_api.to_boolean(p_commit)) then
      commit;
    end if;

    l_msg := 'success';
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterface',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_returnStatus); --discard logging return status

      wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
    end if;

  exception
    when fnd_api.g_exc_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                      p_separator => ' ',
                                      p_delete_stack => fnd_api.g_false);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterface',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'MTI failure: ' || l_msg,
                             x_returnStatus => l_returnStatus); --discard logging return status
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when TOO_MANY_ROWS then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mtlInterfaceProc_pub',
                              p_procedure_name => 'processInterface',
                              p_error_text => SQLERRM);
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                      p_separator => ' ',
                                      p_delete_stack => fnd_api.g_false);

      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterface',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'to many rows: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when NO_DATA_FOUND then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mtlInterfaceProc_pub',
                              p_procedure_name => 'processInterface',
                              p_error_text => SQLERRM);

      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                      p_separator => ' ',
                                      p_delete_stack => fnd_api.g_false);

      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterface',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'no data found: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mtlInterfaceProc_pub',
                              p_procedure_name => 'processInterface',
                              p_error_text => SQLERRM);
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                      p_separator => ' ',
                                      p_delete_stack => fnd_api.g_false);

      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterface',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'MMTT failure: ' || l_msg,
                             x_returnStatus => l_returnStatus); --discard logging return status
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end processInterface;


  /* private procedures */
  procedure processInterfaceRows(p_initMsgList IN VARCHAR2,
                                 p_processInv IN VARCHAR2,
                                 p_endDebug IN VARCHAR2,
                                 p_txnHdrID IN NUMBER,
                                 x_returnStatus OUT NOCOPY VARCHAR2) is

    l_returnStatus VARCHAR2(1);
    cursor c_mtiRows is
      select rowid,
             transaction_interface_id txnIntID
        from mtl_transactions_interface
       where transaction_header_id = p_txnHdrID
         and process_flag = 1;

    cursor c_mmttRows is
      select transaction_temp_id txnTmpID,
             transaction_action_id txnActionID,
             completion_transaction_id cplTxnID,
             move_transaction_id movTxnID
        from mtl_material_transactions_temp
       where transaction_header_id = p_txnHdrID;
    l_params wip_logger.param_tbl_t;
    l_msg VARCHAR2(2000);/* Fix for bug 6034320 */
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
    l_retStatus NUMBER;
    l_msgCount NUMBER;
    l_msgData VARCHAR2(2000);
    l_txnCount NUMBER;
  begin

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_processInv (now ignored)';
      l_params(1).paramValue := p_processInv;
      l_params(2).paramName := 'p_txnHdrID';
      l_params(2).paramValue := p_txnHdrID;
      wip_logger.entryPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterfaceRows',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
      wip_logger.cleanUp(x_returnStatus=>l_returnStatus);
    end if;

    x_returnStatus := fnd_api.g_ret_sts_success;

    l_msg := 'success';

    l_retStatus := inv_txn_manager_pub.process_transactions(p_api_version => 1.0,
                                                            p_init_msg_list => fnd_api.g_true,
                                                            p_commit => fnd_api.g_false,
                                                            p_validation_level => fnd_api.g_valid_level_full,
                                                            p_table => 1,
                                                            p_header_id => p_txnHdrID,
                                                            x_return_status => x_returnStatus,
                                                            x_msg_count => l_msgCount,
                                                            x_msg_data => l_msgData,
                                                            x_trans_count => l_txnCount);
    if(l_retStatus <> 0) then
      if(l_msgData is not null) then
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_msgData);
        fnd_msg_pub.add;
      end if;
      l_msg := 'error from INV MTI processor:' || l_msgData;
      raise fnd_api.g_exc_error;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterfaceRows',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
    if(fnd_api.to_boolean(p_endDebug)) then
      wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterfaceRows',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_msg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when fnd_api.g_exc_error then
      x_returnStatus := fnd_api.g_ret_sts_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterfaceRows',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_msg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;

    when others then
      x_returnStatus := fnd_api.g_ret_sts_error;
      l_msg := 'unexpected error: ' || SQLERRM;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mtlInterfaceProc_pub',
                              p_procedure_name => 'processInterfaceRows',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_mtlInterfaceProc_pub.processInterfaceRows',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_msg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end processInterfaceRows;

end wip_mtlInterfaceProc_pub;

/
