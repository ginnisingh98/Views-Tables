--------------------------------------------------------
--  DDL for Package Body WIP_ONLINE_MTL_TXN_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_ONLINE_MTL_TXN_PROCESSOR" AS
/* $Header: wipopsrb.pls 120.3 2007/10/12 18:33:30 vjambhek ship $ */

  --unmarks serial numbers and sets their status to 'in transit'
  --precondition: p_source_id is SOURCE_ID of one or many items
  --              serial numbers exist in msn
  PROCEDURE updateSerials(p_header_id IN NUMBER,
                          x_err_msg OUT NOCOPY VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR c_serials IS
      SELECT wlc.inventory_item_id,
             wlc.organization_id,
             wlcs.fm_serial_number,
             wlcs.to_serial_number
        FROM wip_lpn_completions wlc, wip_lpn_completions_serials wlcs
       WHERE wlc.header_id = p_header_id
         and wlc.header_id = wlcs.header_id;

    l_msg_count NUMBER;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT PRE_UPDATE;
     FOR v_serial IN c_serials LOOP
       wms_wip_integration.post_completion(p_item_id          => v_serial.inventory_item_id,
                                           p_org_id           => v_serial.organization_id,
                                           p_quantity         => NULL,
                                           p_fm_serial_number => v_serial.fm_serial_number,
                                           p_to_serial_number => v_serial.to_serial_number,
                                           x_msg_count        => l_msg_count,
                                           x_msg_data         => x_err_msg,
                                           x_return_status    => x_return_status);
       if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         ROLLBACK TO PRE_UPDATE;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
     END LOOP;

  EXCEPTION
    when FND_API.G_EXC_UNEXPECTED_ERROR then
    if(l_msg_count > 1) then
      fnd_msg_pub.get(p_data => x_err_msg,
                      p_msg_index_out => l_msg_count);
    end if;
    when others then
      null;
  end updateSerials;

  --precondition: p_header_id is HEADER_ID and SOURCE_ID of assy
  --              p_header_id is SOURCE_ID of components
  PROCEDURE backflushComponents(p_header_id IN  NUMBER,
                                x_err_msg   OUT NOCOPY VARCHAR2,
                                x_return_status   OUT NOCOPY VARCHAR2) IS
    msgCount NUMBER;
  BEGIN
    commit;
    wms_wip_integration.backflush(p_header_id     => p_header_id,
                                  x_msg_data      => x_err_msg,
                                  x_msg_count     => msgCount,
                                  x_return_status => x_return_status);
  END backflushComponents;


  --precondition: p_header_id is HEADER_ID and SOURCE_ID of assy
  --              p_header_id is SOURCE_ID of components
  PROCEDURE completeWol(p_header_id IN  NUMBER,
                        x_err_msg   OUT NOCOPY VARCHAR2,
                        x_return_status   OUT NOCOPY VARCHAR2) IS BEGIN

  SAVEPOINT COMPLETEWOL;
  wip_wol_processor.completeAssyItem(p_header_id     => p_header_id,
                                     x_err_msg       => x_err_msg,
                                     x_return_status => x_return_status);

  if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  updateSerials(p_header_id => p_header_id,
                x_err_msg => x_err_msg,
                x_return_status => x_return_status);

  if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  exception when others then
    ROLLBACK TO COMPLETEWOL;
  END completeWol;

  --precondition: p_header_id is HEADER_ID and SOURCE_ID of assy
  --              p_header_id is SOURCE_ID of components
  PROCEDURE completeAssyAndComponents(p_header_id IN  NUMBER,
                                      x_err_msg   OUT NOCOPY VARCHAR2,
                                      x_return_status   OUT NOCOPY VARCHAR2) IS BEGIN
  SAVEPOINT CACSTART;
  wip_online_mtl_txn_processor.completeAssyItem(p_header_id => p_header_id,
                                              x_err_msg    => x_err_msg,
                                              x_return_status   => x_return_status);

  if(x_return_status = FND_API.G_RET_STS_SUCCESS) then --now perform material txns for the components
    transactMaterials(p_source_id => p_header_id,
                      x_err_msg   => x_err_msg,
                      x_return_status   => x_return_status);
  end if;


  if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    ROLLBACK to SAVEPOINT CACSTART;
  end if;
  END completeAssyAndComponents;


  --precondition: p_header_id is HEADER_ID and SOURCE_ID of assy
  PROCEDURE completeAssyItem(p_header_id IN  NUMBER,
                             x_err_msg   OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2) IS BEGIN
    SAVEPOINT COMPASSYITEM;
    wip_discrete_job_processor.completeAssyItem(p_header_id => p_header_id,
                                                x_err_msg    => x_err_msg,
                                                x_return_status   => x_return_status);
     if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
    updateSerials(p_header_id => p_header_id,
                  x_err_msg => x_err_msg,
                  x_return_status => x_return_status);

     if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;

  EXCEPTION
    when others then
      ROLLBACK TO COMPASSYITEM;
  END completeAssyItem;

  --precondition: p_source_id is SOURCE_ID of materials
  --              for any material record, HEADER_ID != SOURCE_ID
  -- The not-equal is a requirement for assembly completion and makes
  -- sense for material txns as well(generate a header id for each item
  -- and then another for the source id column to group them for processing).
  PROCEDURE transactMaterials(p_source_id IN  NUMBER,
                              x_err_msg   OUT NOCOPY VARCHAR2,
                              x_return_status   OUT NOCOPY VARCHAR2) IS

  CURSOR c_components(v_source_id NUMBER) IS
         SELECT HEADER_ID
           FROM WIP_LPN_COMPLETIONS
          WHERE v_source_id = SOURCE_ID
            AND v_source_id <> HEADER_ID;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT TXMAT;
    FOR v_comp_header_id IN c_components(p_source_id) LOOP
      transactMaterial(p_header_id => v_comp_header_id.header_id,
                       x_err_msg   => x_err_msg,
                       x_return_status   => x_return_status);
      if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;--break out nocopy of the loop, preserving the error message and status for the bad component
    END LOOP;

  EXCEPTION
    when others then
      ROLLBACK TO SAVEPOINT TXMAT;
  END transactMaterials;


  PROCEDURE transactMaterial(p_header_id IN  NUMBER,
                             x_err_msg   OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2) IS BEGIN
  wip_material_processor.processItem(p_header_id => p_header_id,
                                     x_err_msg    => x_err_msg,
                                     x_return_status   => x_return_status);
  END transactMaterial;


  PROCEDURE lpnCompleteFlow (p_orgID NUMBER,
                             p_userID NUMBER,
                             p_scheduledFlag NUMBER,
                             p_scheduleNumber VARCHAR2,
                             p_transactionTypeID NUMBER,
                             p_transactionHeaderID NUMBER,
                             p_completionTxnID NUMBER,
                             p_processHeaderID NUMBER,
                             p_processTempID NUMBER,
                             p_processCmpTxnID NUMBER,
                             p_transactionQty NUMBER,
                             p_transactionUOM VARCHAR2,
                             p_lineID NUMBER,
                             p_lineOp NUMBER,
                             p_assyItemID NUMBER,
                             p_reasonID NUMBER,
                             p_qualityID NUMBER,
                             p_wipEntityID IN OUT NOCOPY NUMBER,
                             p_kanbanID NUMBER,
                             p_projectID NUMBER,
                             p_taskID NUMBER,
                             p_lpnID NUMBER,
                             p_demandSourceHeaderID NUMBER,
                             p_demandSourceLine VARCHAR2,
                             p_demandSourceDelivery VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_err_msg OUT NOCOPY VARCHAR2) IS
     environment wma_common.Environment;
     mmttParameter wma_flow.FlowParam;
     lpnParameter wma_cfm.LpnCfmParam;
     dummyErrCode VARCHAR2(1);
     error VARCHAR2(241);                 -- error message
     l_msg_stack VARCHAR2(2000);
     l_msg_count NUMBER;
     l_ret_value NUMBER;
     returnStatus VARCHAR2(1);
     labelStatus VARCHAR2(1);
     l_paramTbl wip_logger.param_tbl_t;
     l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
  BEGIN
     if (l_logLevel <= wip_constants.trace_logging) then
       l_paramTbl(1).paramName := 'not printing params';
       l_paramTbl(1).paramValue := ' ';
       wip_logger.entryPoint(p_procName => 'wipopsrb.lpnCompleteFlow',
                            p_params => l_paramTbl,
                            x_returnStatus => dummyErrCode);
     end if;

     environment.orgID := p_orgID;
     environment.userID := p_userID;
     wma_derive.deriveEnvironment(environment);

     -- Insert records into mmtt
     -- lpnID inserted here for label printing
     mmttParameter.environment := environment ;
     mmttParameter.transactionDate := sysdate ;
     mmttParameter.scheduledFlag := p_scheduledFlag ;
     if (l_logLevel <= wip_constants.full_logging) then
       wip_logger.log('scheduled flag: ' || mmttParameter.scheduledFlag, dummyErrCode);
     end if;
     mmttParameter.scheduleNumber := p_scheduleNumber ;
     mmttParameter.transactionType := p_transactionTypeID ;
     mmttParameter.transactionHeaderID := p_processHeaderID ;
     if(p_processTempID is null) then
       select mtl_material_transactions_s.nextval
         into mmttParameter.transactionIntID
         from dual;
     else
       mmttParameter.transactionIntID := p_processTempID;
     end if;

     /*Fix for bug #6216695, which is an FP of 6082623:
       Assign header id to flow parameter so that it can used to populate MTLT and MSNT*/
     mmttParameter.headerId := p_transactionHeaderID ;

     mmttParameter.transactionQty := p_transactionQty ;
     mmttParameter.transactionUOM := p_transactionUOM ;
     mmttParameter.lineID := p_lineID ;
     mmttParameter.lineOp := p_lineOp ;
     mmttParameter.assemblyID := p_assyItemID ;
     mmttParameter.reasonID := p_reasonID ;
     mmttParameter.qualityID := p_qualityID ;
     mmttParameter.completionTxnID := p_completionTxnID ; /*2880347 */
     mmttParameter.wipEntityID := p_wipEntityID ;
     mmttParameter.kanbanID := p_kanbanID;
     mmttParameter.projectID := p_projectID ;
     mmttParameter.taskID := p_taskID ;
     mmttParameter.lpnID := p_lpnID ;
     mmttParameter.demandSourceHeaderID := p_demandSourceHeaderID ;
     mmttParameter.demandSourceLine := p_demandSourceLine ;
     mmttParameter.demandSourceDelivery := p_demandSourceDelivery ;

/*     select DEFAULT_PULL_SUPPLY_SUBINV,
            DEFAULT_PULL_SUPPLY_LOCATOR_ID
       into mmttParameter.subinventoryCode,
            mmttParameter.locatorID
       from wip_parameters
      where organization_id = p_orgID;
*/
--     mmttParameter.subinventoryCode := null;
--     mmttParameter.locatorID := null;

     wma_flow.insertParentRecordIntoMMTT(mmttParameter, l_ret_value , x_err_msg);
     if ( l_ret_value = -1 ) then
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('assy insert failed', dummyErrCode);
       end if;
       raise fnd_api.g_exc_unexpected_error;
     end if;


     /*Bug 6417742 (FP of 6342851) - Commented label printing call, this API will be called from WIP_MTLTEMPPROC_PRIV.PROCESSWIP.
     -- print label
     wip_utilities.print_label(p_txn_id => p_processHeaderID,
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
       wip_logger.log(p_msg => 'Label printing returned with status ' ||
                               returnStatus,
                      x_returnStatus => dummyErrCode);
     end if; */

     -- process the transaction
     wip_cfmProc_priv.processMobile(p_processHeaderID,
                                    p_processTempID,
                                    fnd_api.g_false, -- do not call inv trx processor
                                    x_return_status,
                                    x_err_msg);

     if ( x_return_status <> fnd_api.g_ret_sts_success ) then
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('assy processing failed', dummyErrCode);
       end if;
       raise fnd_api.g_exc_unexpected_error;
     end if;

     --get the flow schedule wip entity id if it is a wol trx
     if (p_scheduledFlag = 2) then
       select transaction_source_id
       into p_wipEntityID
       from mtl_material_transactions_temp
       where transaction_temp_id = p_processTempID;
     end if;


     --delete the assy mmtt record
     delete from mtl_material_transactions_temp
      where transaction_temp_id = p_processTempID;

     /*Start - Fix for bug #6216695, which is an FP of 6082623:
       Delete MTLT and MSNT records also*/
     delete mtl_serial_numbers_temp
     where  transaction_temp_id = p_processTempID
     or     transaction_temp_id in (
                select serial_transaction_temp_id
            	from mtl_transaction_lots_temp
                where transaction_temp_id = p_processTempID);

     delete mtl_transaction_lots_temp
     where transaction_temp_id = p_processTempID;
     /*End  - Fix for bug #6216695, which is an FP of 6082623:
       Delete MTLT and MSNT records also*/

     --process the components
     wip_mtlTempProc_priv.processTemp(p_initMsgList => fnd_api.g_true,
                                      p_txnHdrID => p_processHeaderID,
                                      p_txnMode => wip_constants.online,
                                      p_destroyQtyTrees => fnd_api.g_true,
                                      p_endDebug => fnd_api.g_false,
                                      x_returnStatus => x_return_status,
                                      x_errorMsg => x_err_msg);
     if(x_return_status <> fnd_api.g_ret_sts_success) then
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('component processing failed', dummyErrCode);
       end if;
       raise fnd_api.g_exc_unexpected_error;
     end if;

     -- insert into wip_lpn_completions
     lpnParameter.environment := environment ;
     lpnParameter.transactionDate := sysdate ;
     -- for wip_lpn_completions, unscheduled is 3
     if (p_scheduledFlag = 1) then
       lpnParameter.scheduledFlag := 1 ;
     else
       lpnParameter.scheduledFlag := 3 ;
     end if;
     lpnParameter.transactionType :=  p_transactionTypeID ;
     lpnParameter.headerID := p_transactionHeaderID ;
     lpnParameter.transactionQty := p_transactionQty ;
     lpnParameter.transactionUOM := p_transactionUOM ;
     lpnParameter.subinventoryCode := null ;
     lpnParameter.locatorID := null ;
     lpnParameter.kanbanID := p_kanbanID ;
     lpnParameter.lineID := null ;
     lpnParameter.lineOp := null ;
     lpnParameter.assemblyID := p_assyItemID ;
     lpnParameter.reasonID := p_reasonID ;
     lpnParameter.qualityID := p_qualityID ;
     lpnParameter.lpnID := p_lpnID ;
     lpnParameter.completionTxnID := p_completionTxnID;
     lpnParameter.wipEntityID := p_wipEntityID;
     lpnParameter.demandSourceHeaderID := p_demandSourceHeaderID;
     lpnParameter.demandSourceLine := p_demandSourceLine;
     lpnParameter.demandSourceDelivery := p_demandSourceDelivery;
     wma_cfm.process(lpnParameter, l_ret_value , x_err_msg);
     if ( l_ret_value = -1 ) then
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('assy lpn insert failed', dummyErrCode);
       end if;
       raise fnd_api.g_exc_unexpected_error;
     end if;

     updateSerials(p_header_id => lpnParameter.headerID,
                   x_err_msg => x_err_msg,
                   x_return_status => x_return_status);

     if ( x_return_status <> fnd_api.g_ret_sts_success ) then
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('updateSerials failed', dummyErrCode);
       end if;
       raise fnd_api.g_exc_unexpected_error;
     end if;

     x_return_status := fnd_api.G_RET_STS_SUCCESS;

     if (l_logLevel <= wip_constants.trace_logging) then
       wip_logger.exitPoint(p_procName =>  'wipopsrb.lpnCompleteFlow',
                            p_procReturnStatus => x_return_status,
                            p_msg => x_err_msg,
                            x_returnStatus => dummyErrCode);
       wip_logger.cleanUp(dummyErrCode);
     end if;

  EXCEPTION
     when fnd_api.g_exc_unexpected_error then
       if (l_logLevel <= wip_constants.trace_logging) then
         wip_logger.exitPoint(p_procName =>  'wipopsrb.lpnCompleteFlow',
                              p_procReturnStatus => x_return_status,
                              p_msg => 'error:' || x_err_msg,
                              x_returnStatus => dummyErrCode);
         wip_logger.cleanUp(dummyErrCode);
       end if;
     when others then
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       x_err_msg := SQLERRM;
--       WIP_UTILITIES.get_message_stack(p_msg => x_err_msg);
       if (l_logLevel <= wip_constants.trace_logging) then
         wip_logger.exitPoint(p_procName =>  'wipopsrb.lpnCompleteFlow',
                              p_procReturnStatus => x_return_status,
                              p_msg => 'unexp error: ' || x_err_msg,
                              x_returnStatus => dummyErrCode);
         wip_logger.cleanUp(dummyErrCode);
       end if;
  END lpnCompleteFlow;

  /* Process an Lpn (discrete job)  completion, called by LpnCmpProcessor.java  Calls
   * wma online processor in mmtt first, then deletes those records and
   * populates wip_lpn_completions for wms processing.
   *
   * parameters: p_orgID  -- current org
   *             p_userID -- current user
   *             p_transactionHeaderID -- header ID in wip_lpn_completions
   *             p_processHeaderID  -- transaction header ID in mmtt
   *             p_processIntID  -- transaction temp ID in mmtt
   *             x_err_msg    -- err_msg if call fails, null if success
   *             x_return_status   -- fnd_api.G_RET_STS_SUCCESS ('S') if successful
   */
  PROCEDURE lpnCompleteJob (p_orgID NUMBER,
                            p_userID NUMBER,
                            p_transactionTypeID NUMBER,
                            p_transactionHeaderID NUMBER,
                            p_completionTxnID NUMBER,
                            p_processHeaderID NUMBER,
                            p_processIntID NUMBER,
                            p_processCmpTxnID NUMBER,
                            p_wipEntityID NUMBER,
                            p_wipEntityName VARCHAR2,
                            p_assyItemID NUMBER,
                            p_assyItemName VARCHAR2,
                            p_overcomplete NUMBER,
                            p_transactionQty NUMBER,
                            p_transactionUOM VARCHAR2,
                            p_qualityID NUMBER,
                            p_kanbanID NUMBER,
                            p_projectID NUMBER,
                            p_taskID NUMBER,
                            p_lpnID NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_err_msg OUT NOCOPY VARCHAR2) IS
     environment wma_common.Environment;
     mtiParameters wma_completion.CmpParams;
     lpnParameters wma_completion.LpnCmpParams;
     dummyErrCode VARCHAR2(1);
     l_ret_value NUMBER;
     l_paramTbl wip_logger.param_tbl_t;
     l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
	 /* New variables for Bug 6013398*/
     msgCount NUMBER;
     labelStatus VARCHAR2(1);
     l_msg_stack VARCHAR2(2000);
     dummy VARCHAR2(1);
     l_cmpl_txnTmpID    NUMBER;
     l_retStatus VARCHAR2(1);
     error VARCHAR2(2000);    -- error message

  BEGIN
     if (l_logLevel <= wip_constants.trace_logging) then
       l_paramTbl(1).paramName := 'not printing params';
       l_paramTbl(1).paramValue := ' ';
       wip_logger.entryPoint(p_procName => 'wipopsrb.lpnCompleteJob',
                            p_params => l_paramTbl,
                            x_returnStatus => dummyErrCode);
     end if;

     environment.orgID := p_orgID;
     environment.userID := p_userID;
     wma_derive.deriveEnvironment(environment) ;


     lpnParameters.environment := environment ;
     lpnParameters.transactionTypeID := p_transactionTypeID ;
     lpnParameters.headerID := p_transactionHeaderID ;
     lpnParameters.wipEntityID := p_wipEntityID ;
     lpnParameters.wipEntityName := p_wipEntityName ;
     lpnParameters.itemID := p_assyItemID ;
     lpnParameters.itemName := p_assyItemName ;
     lpnParameters.overcomplete := ( p_overcomplete = 1) ;
     lpnParameters.transactionQty := p_transactionQty ;
     lpnParameters.transactionUOM := p_transactionUOM ;
     lpnParameters.subinv := null ;
     lpnParameters.locatorID := null ;
     lpnParameters.locatorName := null ;
     lpnParameters.kanbanCardID := p_kanbanID ;
     lpnParameters.qualityID := p_qualityID ;
     lpnParameters.lpnID := p_lpnID ;
     lpnParameters.completionTxnID := p_completionTxnID;
     wma_completion.process(parameters => lpnParameters,
                            status     => l_ret_value,
                            errMessage => x_err_msg,
							cmpl_txnTmpID => l_cmpl_txnTmpID); --Bug 6013398
     if ( l_ret_value = -1 ) then
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('lpn processing failed', dummyErrCode);
       end if;
       raise fnd_api.g_exc_unexpected_error;
     end if;

     --move the components to MMTT
     wip_mtlTempProc_priv.validateInterfaceTxns(p_txnHdrID => p_processHeaderID,
                                                p_initMsgList => fnd_api.g_true,
                                                x_returnStatus => x_return_status);
     if(x_return_status <> fnd_api.g_ret_sts_success) then
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('component validation failed', dummyErrCode);
       end if;
       wip_utilities.get_message_stack(p_msg => x_err_msg);
       raise fnd_api.g_exc_unexpected_error;
     end if;

     --process the components
     wip_mtlTempProc_priv.processTemp(p_initMsgList => fnd_api.g_true,
                                      p_txnHdrID => p_processHeaderID,
                                      p_txnMode => wip_constants.online,
                                      p_destroyQtyTrees => fnd_api.g_true,
                                      p_endDebug => fnd_api.g_false,
                                      x_returnStatus => x_return_status,
                                      x_errorMsg => x_err_msg);

     if(x_return_status <> fnd_api.g_ret_sts_success) then
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('component processing failed', dummyErrCode);
       end if;
       raise fnd_api.g_exc_unexpected_error;
     end if;

	 /* Start - Bug 6013398: Moved below code from procedure wma_completion.process to here*/
     /* Start of fix for bug 4253002 */
     wip_utilities.print_label(p_txn_id     => l_cmpl_txnTmpID,
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
            wip_logger.log(p_msg => 'Label printing returned with status ' || l_retStatus,
                           x_returnStatus => dummy);
        end if;
        /* End of fix for bug 4253002 */

        --and delete it
        delete mtl_material_transactions_temp
        where transaction_temp_id = l_cmpl_txnTmpID;

        /* Fix for bug 4253002: Dummy mtlt and msnt records created in putintoMMTT()
        will also be deleted along with the parent MMTT record. */
        delete mtl_serial_numbers_temp
        where transaction_temp_id = l_cmpl_txnTmpID
        or transaction_temp_id in (
        select serial_transaction_temp_id
        from mtl_transaction_lots_temp
        where transaction_temp_id = l_cmpl_txnTmpID);

        delete mtl_transaction_lots_temp
        where transaction_temp_id = l_cmpl_txnTmpID;

        /* End - Bug 6013398: Moved below code from procedure wma_completion.process to here*/

     updateSerials(p_header_id => lpnParameters.headerID,
                   x_err_msg => x_err_msg,
                   x_return_status => x_return_status);

     if ( x_return_status <> fnd_api.g_ret_sts_success ) then
       if (l_logLevel <= wip_constants.full_logging) then
         wip_logger.log('updateSerials failed', dummyErrCode);
       end if;
       raise fnd_api.g_exc_unexpected_error;
     end if;



     x_return_status := fnd_api.G_RET_STS_SUCCESS;

     if (l_logLevel <= wip_constants.trace_logging) then
       wip_logger.exitPoint(p_procName =>  'wipopsrb.lpnCompleteJob',
                            p_procReturnStatus => x_return_status,
                            p_msg => x_err_msg,
                            x_returnStatus => dummyErrCode);
       wip_logger.cleanUp(dummyErrCode);
     end if;

  EXCEPTION
     when fnd_api.g_exc_unexpected_error then
       if (l_logLevel <= wip_constants.trace_logging) then
         wip_logger.exitPoint(p_procName =>  'wipopsrb.lpnCompleteJob',
                              p_procReturnStatus => x_return_status,
                              p_msg => x_err_msg,
                              x_returnStatus => dummyErrCode);
         wip_logger.cleanUp(dummyErrCode);
       end if;
     when others then
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       WIP_UTILITIES.get_message_stack(p_msg => x_err_msg);
       if (l_logLevel <= wip_constants.trace_logging) then
         wip_logger.exitPoint(p_procName =>  'wipopsrb.lpnCompleteJob',
                              p_procReturnStatus => x_return_status,
                              p_msg => SQLERRM,
                              x_returnStatus => dummyErrCode);
         wip_logger.cleanUp(dummyErrCode);
       end if;

  END lpnCompleteJob;

END wip_online_mtl_txn_processor;

/
