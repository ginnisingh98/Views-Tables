--------------------------------------------------------
--  DDL for Package Body WIP_MTLTEMPPROC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MTLTEMPPROC_GRP" as
 /* $Header: wiptmppb.pls 115.18 2003/10/13 19:16:59 kmreddy ship $ */

  non_txactable_value CONSTANT VARCHAR2(1) := 'N';

  g_pkgName constant varchar2(30) := 'wip_mtlTempProc_grp';

  procedure processTemp(p_initMsgList IN VARCHAR2,
                        p_processInv IN VARCHAR2, --whether or not to call inventory TM
                        p_txnHdrID IN NUMBER,
                        p_mtlTxnBusinessFlowCode IN NUMBER := null,
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
    l_procName VARCHAR2(30) := 'processTemp';
  begin
-------------------------------------------------------------
--Initial Preprocessing
-------------------------------------------------------------

    savepoint wiptmppb0;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_initMsgList';
      l_params(1).paramValue := p_initMsgList;
      l_params(2).paramName := 'p_processInv';
      l_params(2).paramValue := p_processInv;
      l_params(3).paramName := 'p_txnHdrID';
      l_params(3).paramValue := p_txnHdrID;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(fnd_api.to_boolean(p_initMsgList)) then
      fnd_msg_pub.initialize;
    end if;

    l_retCode := inv_lpn_trx_pub.process_lpn_trx(p_trx_hdr_id       => p_txnHdrID,
                                                 p_business_flow_code => p_mtlTxnBusinessFlowCode,
                                                 x_proc_msg         => x_errorMsg);

    if(nvl(l_retCode, -1) <> 0) then
      fnd_msg_pub.initialize;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', x_errorMsg);
      x_returnStatus := fnd_api.g_ret_sts_error;
    else
      x_returnStatus := fnd_api.g_ret_sts_success;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'normal completion. errMsg:' || x_errorMsg,
                           x_returnStatus     => l_retStatus);
      wip_logger.cleanup(l_retStatus);
    end if;
  exception
    when others then
      rollback to wiptmppb0;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkgName,
                              p_procedure_name => l_procName,
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
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unhandled exception: ' || SQLERRM,
                             x_returnStatus     => l_retStatus);
        wip_logger.cleanup(l_retStatus);
      end if;
  end processTemp;

  procedure processWIP(p_txnTmpID IN NUMBER,
                       x_returnStatus OUT NOCOPY VARCHAR2,
                       x_errorMsg OUT NOCOPY VARCHAR2) is
    l_reqID NUMBER;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin
    savepoint wiptmppb100;
    if(l_logLevel <= wip_constants.trace_logging) then
      --if a concurrent request, put the session ID in the concurrent
      --request''s log file.
      l_reqID := fnd_global.conc_request_id;
      if(nvl(l_reqID, -1) <> -1) then
        fnd_file.put_line(which => fnd_file.log,
                          buff => 'AUDSID: ' || fnd_global.session_id);
      end if;
    end if;
    wip_mtlTempProc_priv.processWIP(p_txnTmpID => p_txnTmpID,
                                    p_endDebug => fnd_api.g_false,
                                    p_processLpn => fnd_api.g_false,
                                    x_returnStatus => x_returnStatus,
                                    x_errorMsg => x_errorMsg);
  exception
    when others then
      rollback to wiptmppb100;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_mtlTempProc_grp',
                              p_procedure_name => 'processWIP',
                              p_error_text => SQLERRM);
      x_errorMsg := substrb(SQLERRM, 1, 240);
  end processWIP;

  function isTxnIDRequired(p_txnTmpID IN NUMBER) return boolean is
    l_txnSrcTypID NUMBER;
    l_wipEntityType NUMBER;
    l_wipEntityID NUMBER;
    l_orgID NUMBER;
    l_txnActionID NUMBER;
    l_procName VARCHAR2(30) := 'isTxnIDRequired';
    l_retStatus VARCHAR2(1);
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
    l_params wip_logger.param_tbl_t;
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnTmpID';
      l_params(1).paramValue := p_txnTmpID;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => l_retStatus);
    end if;

    select transaction_source_type_id,
           wip_entity_type,
           transaction_source_id,
           organization_id,
           transaction_action_id
      into l_txnSrcTypID,
           l_wipEntityType,
           l_wipEntityID,
           l_orgID,
           l_txnActionID
      from mtl_material_transactions_temp
     where transaction_temp_id = p_txnTmpID;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('   txn src type:' || l_txnSrcTypID, l_retStatus);
      wip_logger.log('wip entity type:' || l_wipEntityType, l_retStatus);
      wip_logger.log('  wip entity id:' || l_wipEntityID, l_retStatus);
      wip_logger.log('         org id:' || l_orgID, l_retStatus);
      wip_logger.log('  txn action id:' || l_txnActionID, l_retStatus);
    end if;

    if(l_txnSrcTypID = 5) then
      if(l_wipEntityType = wip_constants.repetitive) then
        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                               p_procReturnStatus => 'true',
                               p_msg              => 'found repetitive',
                               x_returnStatus     => l_retStatus);
          wip_logger.cleanup(l_retStatus);
        end if;
        return true;
      elsif(l_wipEntityType is null) then
        select entity_type
          into l_wipEntityType
          from wip_entities
         where wip_entity_id = l_wipEntityID
           and organization_id = l_orgID;

        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                               p_procReturnStatus => l_wipEntityType || '==' || wip_constants.repetitive,
                               p_msg              => 'queried for wip_entity_type',
                               x_returnStatus     => l_retStatus);
          wip_logger.cleanup(l_retStatus);
        end if;
        return (l_wipEntityType = wip_constants.repetitive);
      end if;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => 'false',
                           p_msg              => 'not repetitive',
                           x_returnStatus     => l_retStatus);
      wip_logger.cleanup(l_retStatus);
    end if;
    return false;
  exception
    when others then
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => 'false',
                           p_msg              => 'sql error:' || SQLERRM,
                           x_returnStatus     => l_retStatus);
      wip_logger.cleanup(l_retStatus);
    end if;
    return false;
  end isTxnIDRequired;

end wip_mtlTempProc_grp;

/
