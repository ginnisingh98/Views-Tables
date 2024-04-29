--------------------------------------------------------
--  DDL for Package Body WIP_CFMPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_CFMPROC_PRIV" as
/* $Header: wipcfmpb.pls 120.0.12000000.2 2007/02/23 22:33:22 kboonyap ship $ */

  /**
   * This procedure process a single flow/work orderless transaction.
   */
  procedure processTemp(p_initMsgList  in  varchar2,
                        p_txnTempID    in  number,
                        x_returnStatus out nocopy varchar2) is
    processing_exception exception;
    l_txnHeaderID number;
    l_cplTxnID number;
    l_kanbanCardID number := null;
    l_qaCollectionID number := null;
    l_wipEntityID number;
    l_success number;
    l_primaryQty number;
    l_lpnID number;
    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_msgCount number;
    l_msgData varchar2(2000);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin

    x_returnStatus := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_initMsgList';
      l_params(1).paramValue := p_initMsgList;
      l_params(2).paramName := 'p_txnTempID';
      l_params(2).paramValue := p_txnTempID;
      wip_logger.entryPoint(p_procName => 'wip_cfmProc_priv.processTemp',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(fnd_api.to_boolean(p_initMsgList)) then
      fnd_msg_pub.initialize;
    end if;

    -- set a save point
    savepoint wip_cfmproc_s0;

    select completion_transaction_id,
           transaction_source_id,
           kanban_card_id,
           qa_collection_id,
           primary_quantity,
           transaction_header_id,
           nvl(lpn_id, content_lpn_id)
      into l_cplTxnID,
           l_wipEntityID,
           l_kanbanCardID,
           l_qaCollectionID,
           l_primaryQty,
           l_txnHeaderID,
           l_lpnID
      from mtl_material_transactions_temp
     where transaction_temp_id = p_txnTempID;

/*
    -- Step 1:
    -- For unscheduled work orderless completion, we should create an entry
    -- in wip_flow_schedules and wip_entities since that is needed for resource
    -- transactions and material transactions.

    wip_flowUtil_priv.createFlowSchedule(p_txnTempID,
                                         l_returnStatus);
    if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise processing_exception;
    end if;
*/
    -- Step 2:
    -- Create reservation for the sales order
    --if lpn completion, then sales order transfer is done at lpn the drop, not
    --lpn completion time.
    if(l_lpnID is null) then
      /*Bug 5676680: Added one extra parameter p_txnTempID */
      wip_so_reservations.complete_flow_sched_to_so(l_txnHeaderID,
                                                    p_txnTempID,
                                                    l_returnStatus,
                                                    l_msgCount,
                                                    l_msgData);
      if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_msgData);
        fnd_msg_pub.add;
        raise processing_exception;
      end if;
    end if;

    -- Step 3:
    -- Explode the Routing and insert the resource and overhead charge
    -- information into WCTI.
    wip_flowResCharge.chargeResourceAndOverhead(p_txnTempID,
                                                l_returnStatus);
    if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise processing_exception;
    end if;


    -- Step 4:
    -- Update the flow schedule
    wip_flowUtil_priv.updateFlowSchedule(p_txnTempID,
                                         l_returnStatus);
    if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise processing_exception;
    end if;


    -- Step 5:
    -- Update the kanban card status to FULL
    if ( l_kanbanCardID is not null ) then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(p_msg => 'Calling inv_kanban_pvt.update_card_supply_status',
                       x_returnStatus => l_returnStatus);
      end if;

      inv_kanban_pvt.update_card_supply_status(
        p_kanban_card_id     => l_kanbanCardID,
        p_supply_status      => inv_kanban_pvt.g_supply_status_full,
        p_document_type      => inv_kanban_pvt.g_doc_type_flow_schedule,
        p_document_header_id => l_wipEntityID,
        p_document_detail_id => null,
        p_replenish_quantity => l_primaryQty,
        x_return_status      => l_returnStatus);

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(p_msg => 'inv_kanban_pvt.update_card_supply_status returns ' ||
                                'with status ' || l_returnStatus,
                       x_returnStatus => l_returnStatus);
      end if;

      if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
        raise processing_exception;
      end if;
    end if;


    -- Step 6:
    -- Enable the QA results
    if ( l_qaCollectionID is not null ) then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(p_msg => 'Calling qa_result_grp.enable',
                       x_returnStatus => l_returnStatus);
      end if;

      qa_result_grp.enable(p_api_version => 1.0,
                           p_init_msg_list => 'F',
                           p_commit => 'F',
                           p_validation_level => 0,
                           p_collection_id => l_qaCollectionID,
                           p_return_status => l_returnStatus,
                           p_msg_count => l_msgCount,
                           p_msg_data => l_msgData);


      if ( l_returnStatus <> 'S' ) then
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_msgData);
        fnd_msg_pub.add;
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log(p_msg => 'qa_result_grp.enable returns return with error ' ||
                                 l_msgData,
                         x_returnStatus => l_returnStatus);
        end if;
        raise processing_exception;
      end if;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.log(p_msg => 'qa_result_grp.enable returns ' ||
                     'with status ' || l_returnStatus,
                     x_returnStatus => l_returnStatus);
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cfmProc_priv.processTemp',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Request processed successfully!',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;

  exception
  when processing_exception then
    x_returnStatus := fnd_api.g_ret_sts_error;
    rollback to wip_cfmproc_s0;
    wip_flowUtil_priv.setMmttError(p_txnTempID,
                                   'Processing Error');
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cfmProc_priv.processTemp',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Request failed!',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    rollback to wip_cfmproc_s0;
    wip_flowUtil_priv.setMmttError(p_txnTempID,
                                   'Unexpected Error');
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cfmProc_priv.processTemp',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'unexpected error: ' || SQLERRM,
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  end processTemp;


  /**
   * This procedure processes a single flow/work orderless transaction inserted
   * by the mobile application.
   */
  procedure processMobile(p_txnHdrID    in  number,
                          p_txnTmpID    in number,
                          p_processInv   in  varchar2,
                          x_returnStatus out nocopy varchar2,
                          x_errorMessage out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_txnHeaderID number;
    l_cplTxnID number;
    l_wipEntityID number;
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
  begin

    savepoint wip_cfmproc_s100;

    x_returnStatus := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHdrID';
      l_params(1).paramValue := p_txnHdrID;
      l_params(2).paramName := 'p_txnTmpID';
      l_params(2).paramValue := p_txnTmpID;
      l_params(3).paramName := 'p_processInv';
      l_params(3).paramValue := p_processInv;
      wip_logger.entryPoint(p_procName => 'wip_cfmProc_priv.processMobile',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    --need to create the flow schedule, this also updates component records
    --so they have the proper transaction_source_id
    if(fnd_api.to_boolean(p_processInv)) then
       --create the flow schedule from MTI
      wip_flowUtil_priv.createFlowSchedule(p_txnInterfaceID => p_txnTmpID,
                                           x_returnStatus => x_returnStatus,
                                           x_wipEntityID => l_wipEntityID);
    else
       --create the flow schedule from MMTT
      wip_flowUtil_priv.createFlowSchedule(p_txnTmpID => p_txnTmpID,
                                           x_returnStatus => x_returnStatus,
                                           x_wipEntityID => l_wipEntityID);
    end if;

    if(x_returnStatus = fnd_api.g_ret_sts_success) then
       --move assy and component records to MMTT
       wip_mtlTempProc_priv.validateInterfaceTxns(p_txnHdrID     => p_txnHdrID,
                                                  p_initMsgList  => fnd_api.g_true,
                                                  x_returnStatus => x_returnStatus);
    end if;

    if(x_returnStatus = fnd_api.g_ret_sts_success) then
      -- process the request
      if(fnd_api.to_boolean(p_processInv)) then
        wip_mtlTempProc_priv.processTemp(p_txnHdrID        => p_txnHdrID,
                                         p_initMsgList     => fnd_api.g_true,
                                         p_txnMode         => wip_constants.online,
                                         p_destroyQtyTrees => fnd_api.g_true,
                                         p_endDebug        => fnd_api.g_false,
                                         x_returnStatus    => x_returnStatus,
                                         x_errorMsg        => x_errorMessage);
      else
        --only do wip processing
        wip_mtlTempProc_priv.processWIP(p_txnTmpID => p_txnTmpID,
                                        p_processLpn => fnd_api.g_true,
                                        x_returnStatus => x_returnStatus,
                                        x_errorMsg => x_errorMessage);
      end if;
    end if;

    --if validateInterfaceTxns or processing errors...
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      if(x_errorMessage is null) then
        wip_utilities.get_message_stack(p_msg => x_errorMessage,
                                        p_delete_stack => fnd_api.g_false);
      end if;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_cfmProc_priv.processMobile',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => x_errorMessage,
                             x_returnStatus => l_returnStatus); --discard logging return status
        wip_logger.cleanUp(l_returnStatus);
      end if;
      return;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_cfmProc_priv.processMobile',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Finished processing successfully!',
                           x_returnStatus => l_returnStatus); --discard logging return status
      wip_logger.cleanUp(l_returnStatus);
    end if;
  end processMobile;


end wip_cfmProc_priv;

/
