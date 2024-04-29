--------------------------------------------------------
--  DDL for Package Body WMA_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_FLOW" AS
/* $Header: wmapflwb.pls 120.10 2007/10/12 18:31:26 vjambhek ship $ */

   Function putIntoMMTT(flowRec FlowRecord, errMsg OUT NOCOPY VARCHAR2) return boolean;

   /**
    * This procedure is the entry point for work order-less/flow transaction.
    * Parameters:
    *   parameters  FlowParam contains values from the mobile form.
    *   status      Indicates success (0), failure (-1).
    *   errMessage  The error or warning message, if any.
    */
   PROCEDURE insertParentRecord(param      IN     FlowParam,
                                status     OUT NOCOPY NUMBER,
                                errMessage OUT NOCOPY VARCHAR2) IS
     flowRec FlowRecord;
     errMsg VARCHAR2(241);
     l_returnStatus VARCHAR2(1);
     l_params wip_logger.param_tbl_t;
     l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
   Begin
     status := 0;
     if (l_logLevel <= wip_constants.trace_logging) then
       l_params(1).paramName := 'not printing params';
       l_params(1).paramValue := ' ';
       wip_logger.entryPoint(p_procName => 'wma_flow.insertParentRecord',
                             p_params => l_params,
                             x_returnStatus => l_returnStatus);
     end if;

     if ( derive(param, flowRec, errMsg) = false ) then
       status := -1;
       errMessage := errMsg;
       if (l_logLevel <= wip_constants.trace_logging) then
         wip_logger.exitPoint(p_procName => 'wma_flow.insertParentRecord',
                              p_procReturnStatus => status,
                              p_msg => errMessage,
                              x_returnStatus => l_returnStatus);
       end if;
       return;
     end if;

     if ( put(flowRec, errMsg) = false ) then
       status := -1;
       errMessage := errMsg;
       if (l_logLevel <= wip_constants.trace_logging) then
         wip_logger.exitPoint(p_procName => 'wma_flow.insertParentRecord',
                              p_procReturnStatus => status,
                              p_msg => errMessage,
                              x_returnStatus => l_returnStatus);
       end if;
       return;
     end if;

     if (l_logLevel <= wip_constants.trace_logging) then
       wip_logger.exitPoint(p_procName => 'wma_flow.insertParentRecord',
                            p_procReturnStatus => status,
                            p_msg => 'success',
                            x_returnStatus => l_returnStatus);
     end if;

   EXCEPTION
    when others then
      status := -1;
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_flow.insertParentRecord');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_flow.insertParentRecord',
                             p_procReturnStatus => status,
                             p_msg => errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
   End insertParentRecord;

   /**
    * This procedure is the entry point for work order-less/flow transaction.
    * Parameters:
    *   parameters  FlowParam contains values from the mobile form.
    *   status      Indicates success (0), failure (-1).
    *   errMessage  The error or warning message, if any.
    */
   PROCEDURE insertParentRecordIntoMMTT(param      IN     FlowParam,
                                        status     OUT NOCOPY NUMBER,
                                        errMessage OUT NOCOPY VARCHAR2) IS
     flowRec FlowRecord;
     errMsg VARCHAR2(241);
     l_returnStatus VARCHAR2(1);
     l_params wip_logger.param_tbl_t;
     l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
   Begin

     if (l_logLevel <= wip_constants.trace_logging) then
       l_params(1).paramName := 'not printing params';
       l_params(1).paramValue := ' ';
       wip_logger.entryPoint(p_procName => 'wma_flow.insertParentRecordintoMMTT',
                             p_params => l_params,
                             x_returnStatus => l_returnStatus);
     end if;

     if ( derive(param, flowRec, errMsg) = false ) then
       status := -1;
       errMessage := errMsg;
       if (l_logLevel <= wip_constants.trace_logging) then
         wip_logger.exitPoint(p_procName => 'wma_flow.insertParentRecordintoMMTT',
                              p_procReturnStatus => status,
                              p_msg => errMessage,
                              x_returnStatus => l_returnStatus);
       end if;
       return;
     end if;

     if ( putIntoMMTT(flowRec, errMsg) = false ) then
       status := -1;
       errMessage := errMsg;
       if (l_logLevel <= wip_constants.trace_logging) then
         wip_logger.exitPoint(p_procName => 'wma_flow.insertParentRecordintoMMTT',
                              p_procReturnStatus => status,
                              p_msg => errMessage,
                              x_returnStatus => l_returnStatus);
       end if;
       return;
     end if;

     if (l_logLevel <= wip_constants.trace_logging) then
       wip_logger.exitPoint(p_procName => 'wma_flow.insertParentRecordintoMMTT',
                            p_procReturnStatus => status,
                            p_msg => 'success',
                            x_returnStatus => l_returnStatus);
     end if;

   EXCEPTION
    when others then
      status := -1;
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_flow.insertParentRecordintoMMTT');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wma_flow.insertParentRecordintoMMTT',
                             p_procReturnStatus => status,
                             p_msg => errMessage,
                             x_returnStatus => l_returnStatus);
      end if;
   End insertParentRecordIntoMMTT;

   /**
    * This function is used to derive the neccessary information to filled out
    * the FlowRecord structure to passed into function put.
    */
   Function derive(param FlowParam,
                   flowRec OUT NOCOPY FlowRecord,
                   errMsg OUT NOCOPY VARCHAR2) return boolean IS
     assembly wma_common.Item;
     periodID number;
     openPastPeriod boolean := false;
     scheduleNumber VARCHAR2(30);
     scrapAcctID NUMBER := null;
     dummy NUMBER;
     accountingClass VARCHAR2(30);
     retval VARCHAR2(1);
     errCode VARCHAR2(80);
     errMesg1 VARCHAR2(30);
     errClass1 VARCHAR2(10);
     errMesg2 VARCHAR2(30);
     errClass2 VARCHAR2(10);
     defaultPrefix VARCHAR2(200);
   Begin

     assembly := wma_derive.getItem(param.assemblyID,
                                    param.environment.orgID,
                                    param.locatorID);

     if assembly.revQtyControlCode = WIP_CONSTANTS.REV then
        BOM_REVISIONS.Get_Revision(
                        type         => 'PART',
                        eco_status   => 'EXCLUDE_OPEN_HOLD',
                        examine_type => 'ALL',
                        org_id       => param.environment.orgID,
                        item_id      => param.assemblyID,
                        rev_date     => param.transactionDate,
                        itm_rev      => flowRec.revision);
     else
       flowRec.revision := NULL;
     end if;

     accountingClass := wip_common.default_acc_class(
                            param.environment.orgID,
                            param.assemblyID,
                            4,  -- for flow schedule
                            assembly.projectID,
                            errMesg1,
                            errClass1,
                            errMesg2,
                            errClass2);

     -- If there is no WIP defaulting accounting class, error out
     if(accountingClass is null) then
       fnd_message.set_name(
         application => 'WIP',
         name        => 'WIP_NO_DEFAULT_CLASSES');
      errMsg := fnd_message.get;
      return false;
     end if;

     -- get the accounting period
     invttmtx.tdatechk(
          org_id           => param.environment.orgID,
          transaction_date => param.transactionDate,
          period_id        => periodID,
          open_past_period => openPastPeriod);

    if (periodID = -1 or periodID = 0) then
      fnd_message.set_name(
        application => 'INV',
        name        => 'INV_NO_OPEN_PERIOD');
      errMsg := fnd_message.get;
      return false;
    end if;

     -- default schedule number, it is the value read from profile option 'WIP_JOB_PREFIX'
     -- appended by a sequence number. We only default it for non flow schedule.
     -- 3 means unscheduled, 1 means scheduled
     if ( param.scheduleNumber is null ) then
       defaultPrefix := substr(fnd_profile.value('WIP_JOB_PREFIX'), 1, 200);
       scheduleNumber := defaultPrefix || wma_derive.getNextVal('WIP_JOB_NUMBER_S');
     else
       scheduleNumber := param.scheduleNumber;
     end if;
     flowRec.schedule_number := scheduleNumber;

     flowRec.transaction_date := param.transactionDate;

     -- derive routing and bom rev info
     dummy := Wip_Flow_Derive.bom_revision (
                 p_bom_rev      => flowRec.bom_revision,
                 p_rev          => flowRec.revision,
                 p_bom_rev_date => flowRec.bom_revision_date,
                 p_item_id      => param.assemblyID,
                 p_start_date   => flowRec.transaction_date,
                 p_Org_id       => param.environment.orgID);

     dummy := Wip_Flow_Derive.routing_revision(
                 p_rout_rev      => flowRec.routing_revision,
                 p_rout_rev_date => flowRec.routing_revision_date,
                 p_item_id       => param.assemblyID,
                 p_start_date    => flowRec.transaction_date,
                 p_Org_id        => param.environment.orgID);


     flowRec.transaction_interface_id := param.transactionIntID;
     flowRec.transaction_header_id := param.transactionHeaderID;
     flowRec.completion_transaction_id := param.completionTxnID;
     flowRec.transaction_mode := wma_derive.getTxnMode(param.environment.orgID);
     flowRec.process_flag := wip_constants.mti_inventory;

     flowRec.source_code := WMA_COMMON.SOURCE_CODE;

     flowRec.last_updated_by := param.environment.userID;
     flowRec.last_update_date := sysdate;
     flowRec.creation_date := sysdate;
     flowRec.created_by := param.environment.userID;

     flowRec.inventory_item_id := param.assemblyID;
     flowRec.organization_id := param.environment.orgID;
     flowRec.acct_period_id := periodID;

     flowRec.transaction_type_id := param.transactionType;
     flowRec.transaction_quantity := param.transactionQty;
     flowRec.primary_quantity := param.transactionQty;

     if ( param.transactionType = WIP_CONSTANTS.CPLASSY_TYPE ) then
        -- for completion
        flowRec.transaction_action_id := WIP_CONSTANTS.CPLASSY_ACTION;
     elsif ( param.transactionType = WIP_CONSTANTS.RETASSY_TYPE ) then
        -- for return
        flowRec.transaction_action_id := WIP_CONSTANTS.RETASSY_ACTION;
     elsif ( param.transactionType in (WIP_CONSTANTS.SCRASSY_TYPE,
                                       WIP_CONSTANTS.RETSCRA_TYPE) ) then
        -- for scrap
        flowRec.transaction_action_id := WIP_CONSTANTS.SCRASSY_ACTION;
        if ( wma_util.getScrapAcctID(param.environment.orgID,
                                     scrapAcctID,
                                     errMsg) = false ) then
          return false;
        end if;
     end if;

     flowRec.distribution_account_id := scrapAcctID;
     flowRec.transaction_uom := param.transactionUOM;
     flowRec.subinventory_code := param.subinventoryCode;
     flowRec.locator_id := param.locatorID;
     flowRec.reason_id := param.reasonID;
     flowRec.qa_collection_id := param.qualityID;
     flowRec.transaction_source_type_id := 5; -- means WIP

     flowRec.source_line_id := -1;
     flowRec.source_header_id := -1;


     flowRec.repetitive_line_id := param.lineID;
     flowRec.operation_seq_num := param.lineOp;
     flowRec.scheduled_flag := param.scheduledFlag;
     flowRec.flow_schedule := 'Y';
     flowRec.wipEntityType := wip_constants.flow;

     flowRec.demand_source_header_id := param.demandSourceHeaderId;
     flowRec.demand_source_line := param.demandSourceLine;
     flowRec.demand_source_delivery := param.demandSourceDelivery;

     flowRec.transaction_source_id := param.wipEntityID;
     if ( flowRec.transaction_source_id is not null ) then
       flowRec.wip_entity_type := wip_constants.flow; -- means flow schedule
     end if;

     flowRec.header_id := param.headerId;/*Fix for bug #6216695, which is an FP of 6082623 :
                                           Add header id to populate MTLT and MSNT*/

     flowRec.accounting_class := accountingClass;
     flowRec.kanban_card_id := param.kanbanID;

     -- if the transaction is a work order-less completion, call the PJM
     -- API to check that the project references are correct
     if (param.scheduledFlag <> 1 and param.transactionType = WIP_CONSTANTS.CPLASSY_TYPE) then
        retval := PJM_PROJECT.VALIDATE_PROJ_REFERENCES
           (x_inventory_org_id  => param.environment.orgID,
            x_project_id        => param.projectID,
            x_task_id           => param.taskID,
            x_date1             => param.transactionDate,
            x_date2             => NULL,
            x_calling_function  => 'wmapflwb',
            x_error_code        => errCode
           );
        if ( retval = PJM_PROJECT.G_VALIDATE_FAILURE ) then
           wip_utilities.get_message_stack(p_msg => errMsg);
           return false;
        end if;
     end if;

     flowRec.source_project_id := param.projectID;
     flowRec.source_task_id := param.taskID;
     flowRec.lpn_id := param.lpnID;

     if ( param.wipEntityID is not null and param.scheduledFlag = 1 ) then
       select project_id,
              task_id
         into flowRec.source_project_id,
              flowRec.source_task_id
         from wip_flow_schedules
        where wip_entity_id = param.wipEntityID
          and organization_id = param.environment.orgID;

       --if the destination sub is known, transfer the reservation. The sub is
       --not known for lpn flow completions, so inventory does a callback when
       --the material is dropped (wma_inv_wrappers.transferReservation())
       /* Not required as Sales Order will be entered through UI
       if(param.subinventoryCode is not null AND
          param.demandSourceHeaderID IS NULL) then
         -- if the item is a CTO item then we should populate sales order info to mmtt
         -- talked to Renga and the following sql should be used to determine whether the
         -- item is CTO item or not.
         dummy := 0;
         select count(*) into dummy
           from mtl_system_items
          where inventory_item_id = param.assemblyID
            and organization_id = param.environment.orgID
            and build_in_wip_flag = 'Y'
            and base_item_id is not null
            and bom_item_type = 4
            and replenish_to_order_flag = 'Y';
         if ( dummy = 1 ) then
           select demand_source_header_id,
                  demand_source_line,
                  demand_source_delivery
             into flowRec.demand_source_header_id,
                  flowRec.demand_source_line,
                  flowRec.demand_source_delivery
             from wip_flow_schedules
            where organization_id = param.environment.orgID
              and wip_entity_id = param.wipEntityID;
         end if;
       end if;
       */
     end if;

     return true;
   End derive;

   /**
    * This function is used to insert the record encapsulated in flowRec to
    * table mtl_transactions_interface and some furthur validation and processing.
    */
   Function put(flowRec FlowRecord, errMsg OUT NOCOPY VARCHAR2) return boolean IS
      l_dummy varchar2(1);
   Begin
     wip_logger.log('lpnid: ' || flowRec.lpn_id, l_dummy);
     INSERT INTO mtl_transactions_interface
                (transaction_interface_id,
                 transaction_header_id,
                 completion_transaction_id,
                 transaction_mode,
                 process_flag,
                 source_code,
                 last_updated_by, last_update_date,
                 creation_date, created_by,
                 inventory_item_id,
                 organization_id,
                 acct_period_id,
                 transaction_date,
                 bom_revision, revision,
                 bom_revision_date,
                 routing_revision, routing_revision_date,
                 transaction_type_id,
                 transaction_action_id,
                 transaction_quantity,
                 primary_quantity,
                 distribution_account_id,
                 transaction_uom,
                 subinventory_code,
                 locator_id, reason_id,
                 qa_collection_id,
                 transaction_source_type_id,
                 schedule_number,
                 repetitive_line_id,
                 operation_seq_num,
                 scheduled_flag,
                 flow_schedule,
                 wip_entity_type,
                 transaction_source_id,
                 accounting_class,
                 source_project_id,
                 source_task_id,
                 project_id,
                 task_id,
                 kanban_card_id,
                 demand_source_header_id,
                 demand_source_line,
                 demand_source_delivery,
                 lpn_id,
                 source_header_id,
                 source_line_id,
                 transaction_batch_id,  --bug 4545130
                 transaction_batch_seq  --bug 4545130
                )
         VALUES (flowRec.transaction_interface_id,
                 flowRec.transaction_header_id,
                 flowRec.completion_transaction_id,
                 flowRec.transaction_mode,
                 flowRec.process_flag,
                 flowRec.source_code,
                 flowRec.last_updated_by, flowRec.last_update_date,
                 flowRec.creation_date, flowRec.created_by,
                 flowRec.inventory_item_id,
                 flowRec.organization_id,
                 flowRec.acct_period_id,
                 flowRec.transaction_date,
                 flowRec.bom_revision, flowRec.revision,
                 flowRec.bom_revision_date,
                 flowRec.routing_revision,
                 flowRec.routing_revision_date,
                 flowRec.transaction_type_id,
                 flowRec.transaction_action_id,
                 flowRec.transaction_quantity,
                 flowRec.primary_quantity,
                 flowRec.distribution_account_id,
                 flowRec.transaction_uom,
                 flowRec.subinventory_code,
                 flowRec.locator_id,
                 flowRec.reason_id,
                 flowRec.qa_collection_id,
                 flowRec.transaction_source_type_id,
                 flowRec.schedule_number,
                 flowRec.repetitive_line_id,
                 flowRec.operation_seq_num,
                 flowRec.scheduled_flag,
                 flowRec.flow_schedule,
                 flowRec.wip_entity_type,
                 flowRec.transaction_source_id,
                 flowRec.accounting_class,
                 flowRec.source_project_id,
                 flowRec.source_task_id,
                 flowRec.source_project_id,
                 flowRec.source_task_id,
                 flowRec.kanban_card_id,
                 flowRec.demand_source_header_id,
                 flowRec.demand_source_line,
                 flowRec.demand_source_delivery,
                 flowRec.lpn_id,
                 flowRec.source_header_id,
                 flowRec.source_line_id,
                 flowRec.transaction_header_id, --bug 4545130
                 wip_constants.ASSY_BATCH_SEQ  --bug 4545130
                );
     return true;

     EXCEPTION
     when others then
       fnd_message.set_name ('WIP', 'GENERIC_ERROR');
       fnd_message.set_token ('FUNCTION', 'wma_flow.put');
       fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
       errMsg := fnd_message.get;
       return false;
   End put;

   Function putIntoMMTT(flowRec FlowRecord, errMsg OUT NOCOPY VARCHAR2) return boolean IS
      l_dummy varchar2(1);

      /* Start - Fix for bug #6216695, which is an FP of 6082623 :
         Changed code to make it compatible with 8i database.
         Following cursor has been created for this */
      l_txnTmpID  NUMBER;
      cursor get_serial_txn is
        select mtlt.serial_transaction_temp_id,
               wlcs.fm_serial_number,
               wlcs.to_serial_number
        from   mtl_transaction_lots_temp mtlt,
               wip_lpn_completions_serials wlcs
        where  mtlt.lot_number = wlcs.lot_number
        and    wlcs.header_id = flowRec.header_id
        and    mtlt.transaction_temp_id = l_txnTmpID;
      /* End - Fix for bug #6216695, which is an FP of 6082623 */

   Begin
     wip_logger.log('lpnid: ' || flowRec.lpn_id, l_dummy);
     INSERT INTO mtl_material_transactions_temp
                (transaction_temp_id,
                 transaction_header_id,
                 completion_transaction_id,
                 transaction_mode,
                 process_flag,
                 source_code,
                 last_updated_by, last_update_date,
                 creation_date, created_by,
                 inventory_item_id,
                 organization_id,
                 acct_period_id,
                 transaction_date,
                 bom_revision, revision,
                 bom_revision_date,
                 routing_revision, routing_revision_date,
                 transaction_type_id,
                 transaction_action_id,
                 transaction_quantity,
                 primary_quantity,
                 distribution_account_id,
                 transaction_uom,
                 subinventory_code,
                 locator_id, reason_id,
                 qa_collection_id,
                 transaction_source_type_id,
                 schedule_number,
                 repetitive_line_id,
                 operation_seq_num,
                 scheduled_flag,
                 flow_schedule,
                 wip_entity_type,
                 transaction_source_id,
                 class_code,
                 source_project_id,
                 source_task_id,
                 project_id,
                 task_id,
                 kanban_card_id,
                 demand_source_header_id,
                 demand_source_line,
                 demand_source_delivery,
                 lpn_id--,
--                 source_header_id,
--                 source_line_id
                )
         VALUES (flowRec.transaction_interface_id,
                 flowRec.transaction_header_id,
                 flowRec.completion_transaction_id,
                 flowRec.transaction_mode,
                 decode(flowRec.process_flag, wip_constants.mti_inventory, 'Y', 'N'),
                 flowRec.source_code,
                 flowRec.last_updated_by, flowRec.last_update_date,
                 flowRec.creation_date, flowRec.created_by,
                 flowRec.inventory_item_id,
                 flowRec.organization_id,
                 flowRec.acct_period_id,
                 flowRec.transaction_date,
                 flowRec.bom_revision, flowRec.revision,
                 flowRec.bom_revision_date,
                 flowRec.routing_revision,
                 flowRec.routing_revision_date,
                 flowRec.transaction_type_id,
                 flowRec.transaction_action_id,
                 flowRec.transaction_quantity,
                 flowRec.primary_quantity,
                 flowRec.distribution_account_id,
                 flowRec.transaction_uom,
                 flowRec.subinventory_code,
                 flowRec.locator_id,
                 flowRec.reason_id,
                 flowRec.qa_collection_id,
                 flowRec.transaction_source_type_id,
                 flowRec.schedule_number,
                 flowRec.repetitive_line_id,
                 flowRec.operation_seq_num,
                 flowRec.scheduled_flag,
                 flowRec.flow_schedule,
                 flowRec.wip_entity_type,
                 flowRec.transaction_source_id,
                 flowRec.accounting_class,
                 flowRec.source_project_id,
                 flowRec.source_task_id,
                 flowRec.source_project_id,
                 flowRec.source_task_id,
                 flowRec.kanban_card_id,
                 flowRec.demand_source_header_id,
                 flowRec.demand_source_line,
                 flowRec.demand_source_delivery,
                 flowRec.lpn_id--,
--                 flowRec.source_header_id,
--                 flowRec.source_line_id
                )
                returning transaction_temp_id into l_txnTmpID ;
                /*Fix for bug #6216695, which is an FP of 6082623 :
                  Store txnTempId into local variable*/


     /*Start - Fix for bug #6216695, which is an FP of 6082623 :
     Insert records into MTLT and MSNT also. Need to create records in
     mtl_transaction_lots_temp and mtl_serial_numbers_temp based on data
     in wip_lpn_completions_lots and wip_lpn_completions_serials.
     This is done so that the data is available for label printing. */

     insert into mtl_transaction_lots_temp(
           transaction_temp_id,
           serial_transaction_temp_id,
           creation_date,
	   created_by,
	   last_update_login,
	   request_id,
	   program_update_date,
	   program_application_id,
	   program_id,
	   transaction_quantity,
	   primary_quantity,
	   lot_number,
	   lot_expiration_date,
	   error_code,
	   lot_attribute_category,
	   status_id,
	   c_attribute1,
	   c_attribute2,
	   c_attribute3,
	   c_attribute4,
	   c_attribute5,
	   c_attribute6,
	   c_attribute7,
	   c_attribute8,
	   c_attribute9,
	   c_attribute10,
	   c_attribute11,
	   c_attribute12,
	   c_attribute13,
	   c_attribute14,
	   c_attribute15,
	   c_attribute16,
	   c_attribute17,
	   c_attribute18,
	   c_attribute19,
	   c_attribute20,
	   d_attribute1,
	   d_attribute2,
	   d_attribute3,
	   d_attribute4,
	   d_attribute5,
	   d_attribute6,
	   d_attribute7,
	   d_attribute8,
	   d_attribute9,
	   d_attribute10,
	   n_attribute1,
	   n_attribute2,
	   n_attribute3,
	   n_attribute4,
	   n_attribute5,
	   n_attribute6,
	   n_attribute7,
	   n_attribute8,
	   n_attribute9,
	   n_attribute10,
	   territory_code,
	   vendor_name,
	   supplier_lot_number,
	   vendor_id,
	   description,
	   grade_code,
	   origination_date,
	   date_code,
	   change_date,
	   age,
	   retest_date,
	   maturity_date,
	   item_size,
	   color,
	   volume,
	   volume_uom,
	   place_of_origin,
	   best_by_date,
	   length,
	   length_uom,
	   recycled_content,
	   thickness,
	   thickness_uom,
	   width,
	   width_uom,
	   curl_wrinkle_fold,
	   last_update_date,
	   last_updated_by
          )
     select l_txnTmpID,
            null,
	    wlcl.creation_date,
	    wlcl.created_by,
	    wlcl.last_update_login,
	    wlcl.request_id,
	    wlcl.program_update_date,
	    wlcl.program_application_id,
	    wlcl.program_id,
	    wlcl.transaction_quantity,
	    wlcl.primary_quantity,
	    wlcl.lot_number,
	    wlcl.lot_expiration_date,
	    wlcl.error_code,
	    wlcl.lot_attribute_category,
	    wlcl.status_id,
	    wlcl.c_attribute1,
	    wlcl.c_attribute2,
	    wlcl.c_attribute3,
	    wlcl.c_attribute4,
	    wlcl.c_attribute5,
	    wlcl.c_attribute6,
	    wlcl.c_attribute7,
	    wlcl.c_attribute8,
	    wlcl.c_attribute9,
	    wlcl.c_attribute10,
	    wlcl.c_attribute11,
	    wlcl.c_attribute12,
	    wlcl.c_attribute13,
	    wlcl.c_attribute14,
	    wlcl.c_attribute15,
	    wlcl.c_attribute16,
	    wlcl.c_attribute17,
	    wlcl.c_attribute18,
	    wlcl.c_attribute19,
	    wlcl.c_attribute20,
	    wlcl.d_attribute1,
	    wlcl.d_attribute2,
	    wlcl.d_attribute3,
	    wlcl.d_attribute4,
	    wlcl.d_attribute5,
	    wlcl.d_attribute6,
	    wlcl.d_attribute7,
	    wlcl.d_attribute8,
	    wlcl.d_attribute9,
	    wlcl.d_attribute10,
	    wlcl.n_attribute1,
	    wlcl.n_attribute2,
	    wlcl.n_attribute3,
	    wlcl.n_attribute4,
	    wlcl.n_attribute5,
	    wlcl.n_attribute6,
	    wlcl.n_attribute7,
	    wlcl.n_attribute8,
	    wlcl.n_attribute9,
	    wlcl.n_attribute10,
	    wlcl.territory_code,
	    wlcl.vendor_name,
	    wlcl.supplier_lot_number,
	    wlcl.vendor_id,
	    wlcl.description,
	    wlcl.grade_code,
	    wlcl.origination_date,
	    wlcl.date_code,
	    wlcl.change_date,
	    wlcl.age,
	    wlcl.retest_date,
	    wlcl.maturity_date,
	    wlcl.item_size,
	    wlcl.color,
	    wlcl.volume,
	    wlcl.volume_uom,
	    wlcl.place_of_origin,
	    wlcl.best_by_date,
	    wlcl.length,
	    wlcl.length_uom,
	    wlcl.recycled_content,
	    wlcl.thickness,
	    wlcl.thickness_uom,
	    wlcl.width,
	    wlcl.width_uom,
	    wlcl.curl_wrinkle_fold,
	    wlcl.last_update_date,
	    wlcl.last_updated_by
     from   wip_lpn_completions_lots wlcl
     where  wlcl.header_id = flowRec.header_id;

     update mtl_transaction_lots_temp
     set    serial_transaction_temp_id = mtl_material_transactions_s.nextval
     where  transaction_temp_id=l_txnTmpID
     and    lot_number in
	       (select lot_number
	        from   wip_lpn_completions_serials
		where  header_id = flowRec.header_id) ;


     insert into mtl_serial_numbers_temp(
               transaction_temp_id,
               fm_serial_number,
	       to_serial_number,
	       serial_prefix,
	       parent_serial_number,
	       error_code,
	       c_attribute1,
	       c_attribute2,
	       c_attribute3,
	       c_attribute4,
	       c_attribute5,
	       c_attribute6,
	       c_attribute7,
	       c_attribute8,
	       c_attribute9,
	       c_attribute10,
	       c_attribute11,
	       c_attribute12,
	       c_attribute13,
	       c_attribute14,
	       c_attribute15,
	       c_attribute16,
	       c_attribute17,
	       c_attribute18,
	       c_attribute19,
	       c_attribute20,
	       d_attribute1,
	       d_attribute2,
	       d_attribute3,
	       d_attribute4,
	       d_attribute5,
	       d_attribute6,
	       d_attribute7,
	       d_attribute8,
	       d_attribute9,
	       d_attribute10,
	       n_attribute1,
	       n_attribute2,
	       n_attribute3,
	       n_attribute4,
	       n_attribute5,
	       n_attribute6,
	       n_attribute7,
	       n_attribute8,
	       n_attribute9,
	       n_attribute10,
	       territory_code,
	       time_since_new,
	       cycles_since_new,
	       time_since_overhaul,
	       cycles_since_overhaul,
	       time_since_repair,
	       cycles_since_repair,
	       time_since_visit,
	       cycles_since_visit,
	       time_since_mark,
	       cycles_since_mark,
	       number_of_repairs,
	       last_update_date,
	       last_updated_by,
	       creation_date,
	       created_by,
	       last_update_login,
	       request_id,
	       program_application_id,
	       program_id,
	       program_update_date,
	       serial_attribute_category,
	       status_id,
               origination_date
          )
     select l_txnTmpID,
            wlcs.fm_serial_number,
	    wlcs.to_serial_number,
	    wlcs.serial_prefix,
	    wlcs.parent_serial_number,
	    wlcs.error_code,
	    wlcs.c_attribute1,
	    wlcs.c_attribute2,
	    wlcs.c_attribute3,
	    wlcs.c_attribute4,
	    wlcs.c_attribute5,
	    wlcs.c_attribute6,
	    wlcs.c_attribute7,
	    wlcs.c_attribute8,
	    wlcs.c_attribute9,
	    wlcs.c_attribute10,
	    wlcs.c_attribute11,
	    wlcs.c_attribute12,
	    wlcs.c_attribute13,
	    wlcs.c_attribute14,
	    wlcs.c_attribute15,
	    wlcs.c_attribute16,
	    wlcs.c_attribute17,
	    wlcs.c_attribute18,
	    wlcs.c_attribute19,
	    wlcs.c_attribute20,
	    wlcs.d_attribute1,
	    wlcs.d_attribute2,
	    wlcs.d_attribute3,
	    wlcs.d_attribute4,
	    wlcs.d_attribute5,
	    wlcs.d_attribute6,
	    wlcs.d_attribute7,
	    wlcs.d_attribute8,
	    wlcs.d_attribute9,
	    wlcs.d_attribute10,
	    wlcs.n_attribute1,
	    wlcs.n_attribute2,
	    wlcs.n_attribute3,
	    wlcs.n_attribute4,
	    wlcs.n_attribute5,
	    wlcs.n_attribute6,
	    wlcs.n_attribute7,
	    wlcs.n_attribute8,
	    wlcs.n_attribute9,
	    wlcs.n_attribute10,
	    wlcs.territory_code,
	    wlcs.time_since_new,
	    wlcs.cycles_since_new,
	    wlcs.time_since_overhaul,
	    wlcs.cycles_since_overhaul,
	    wlcs.time_since_repair,
	    wlcs.cycles_since_repair,
	    wlcs.time_since_visit,
	    wlcs.cycles_since_visit,
	    wlcs.time_since_mark,
	    wlcs.cycles_since_mark,
	    wlcs.number_of_repairs,
	    wlcs.last_update_date,
	    wlcs.last_updated_by,
	    wlcs.creation_date,
	    wlcs.created_by,
	    wlcs.last_update_login,
	    wlcs.request_id,
	    wlcs.program_application_id,
	    wlcs.program_id,
	    wlcs.program_update_date,
	    wlcs.serial_attribute_category,
	    wlcs.status_id,
            wlcs.origination_date
     from   wip_lpn_completions_serials wlcs
     where  wlcs.header_id =  flowRec.header_id;

     for serial_rec in get_serial_txn loop

         update mtl_serial_numbers_temp
         set transaction_temp_id = serial_rec.serial_transaction_temp_id
         where fm_serial_number = serial_rec.fm_serial_number
         and to_serial_number = serial_rec.to_serial_number
         and transaction_temp_id = l_txnTmpID;

     end loop;

     /*End - Fix for bug #6216695, which is an FP of 6082623 :
       Insert records into MTLT and MSNT also*/

     return true;

     EXCEPTION
     when others then
       fnd_message.set_name ('WIP', 'GENERIC_ERROR');
       fnd_message.set_token ('FUNCTION', 'wma_flow.putIntoMMTT');
       fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
       errMsg := fnd_message.get;
       return false;
   End putIntoMMTT;

  procedure explodeBOMAndDerive(p_assyID          in  number,
                                p_orgID           in  number,
                                p_qty             in  number,
                                p_wipEntityID     in  number,
                                p_txnDate         in  date,
                                p_projectID       in  number,
                                p_taskID          in  number,
                                p_toOpSeqNum      in  number,
                                x_lotEntryType    out nocopy number,
                                x_compInfo        out nocopy system.wip_lot_serial_obj_t,
                                x_returnStatus    out nocopy varchar2,
                                x_errMessage      out nocopy varchar2) is
    l_compTbl system.wip_component_tbl_t;
    l_bomRevDate date := null;
    l_count number;
    l_returnStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);

    l_alt_bom VARCHAR2(10);
    l_alt_rtg VARCHAR2(10);
    l_line_id NUMBER;

    cursor wfs_info_cursor(wipEntityId number) is
      select wip_entity_id,
             planned_quantity,
             nvl(quantity_completed,0) as quantity_completed,
             nvl(quantity_scrapped,0) as quantity_scrapped,
             (planned_quantity - nvl(quantity_completed,0) - nvl(quantity_scrapped,0)) as open_quantity
       from wip_flow_schedules wfs
      where wfs.wip_entity_id = wipEntityId
    ;

    l_wfs_info wfs_info_cursor%ROWTYPE := null;

  begin
    x_returnStatus := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'not printing params';
      l_params(1).paramValue := ' ';
      wip_logger.entryPoint(p_procName => 'wma_flow.explodeBOMAndDerive',
                            p_params => l_params,
                            x_returnStatus => l_returnStatus);
    end if;

    select backflush_lot_entry_type
      into x_lotEntryType
      from wip_parameters
     where organization_id = p_orgID;


/*
    if ( p_wipEntityID is not null ) then
      select scheduled_completion_date
        into l_bomRevDate
        from wip_flow_schedules
       where wip_entity_id = p_wipEntityID;
    end if;
*/


    if ( p_wipEntityID is not null ) then
      select scheduled_completion_date, line_id, alternate_bom_designator,
             alternate_routing_designator
        into l_bomRevDate, l_line_id, l_alt_bom, l_alt_rtg
        from wip_flow_schedules
       where wip_entity_id = p_wipEntityID;
    end if;


    l_compTbl := system.wip_component_tbl_t();
    -- explode the bom and do the default for the supply subinv and locator
    --commented for flow execution - component and detail merging

    wip_flowUtil_priv.explodeRequirementsAndDefault(
            p_assyID => p_assyID,
            p_orgID => p_orgID,
            p_qty => p_qty,
            p_altBomDesig => null,
            p_altOption => 2,
            p_bomRevDate => l_bomRevDate,
            p_txnDate => p_txnDate,
	    p_implFlag => 1,
            p_projectID => p_projectID,
            p_taskID => p_taskID,
            p_toOpSeqNum => p_toOpSeqNum,
            p_altRoutDesig => null,
            p_txnFlag => true,   -- fix for bug4538135 -  ER 4369064
            p_defaultPushSubinv => 'Y', --fox for bug 5358603
            x_compTbl => l_compTbl,
            x_returnStatus => x_returnStatus);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('Done with explosion of components',l_returnStatus);
    end if;

    -- fetch flow schedule's information into wfs_info
    for c_wfs_info in wfs_info_cursor(p_wipEntityID) loop
      l_wfs_info := c_wfs_info;
    end loop;

    -- filter out unwanted components
    l_count := l_compTbl.first;
    while (l_count is not null) loop
      -- bug 5630078
      -- we dont insert any component that is not transaction_enabled
      if ((nvl(l_compTbl(l_count).wip_supply_type, -1) <> 6) and
          (l_compTbl(l_count).mtl_transactions_enabled_flag <> 'Y')) then
        l_compTbl.delete(l_count);
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('Removed non txn enabled component: '+l_compTbl(l_count).item_name, l_returnStatus);
        end if;
        goto continue_loop;
      end if;

      -- bug 5605598: filter out lot-based components appropriately
      if (nvl(l_compTbl(l_count).basis_type,WIP_CONSTANTS.ITEM_BASED_MTL) = WIP_CONSTANTS.LOT_BASED_MTL) then
        if (
          not(
            (l_wfs_info.quantity_completed = 0 and l_wfs_info.quantity_scrapped <= 0 and p_qty > 0) or
            (l_wfs_info.quantity_completed + l_wfs_info.quantity_scrapped > 0 and
             l_wfs_info.quantity_completed + l_wfs_info.quantity_scrapped + p_qty <= 0)
          )
        ) then
          -- remove the component it it's not the 1st complete/scrap or the last return/return-from-scrap
          l_compTbl.delete(l_count);
          goto continue_loop;
        end if;
      end if;

      <<continue_loop>>
      l_count := l_compTbl.next(l_count);
    end loop;

    x_compInfo := system.wip_lot_serial_obj_t(null, null, null, l_compTbl, null, null);
    x_compInfo.initialize;

    wip_autoLotProc_priv.deriveLots(x_compLots => x_compInfo,
                                    p_orgID    => p_orgID,
                                    p_wipEntityID => p_wipEntityID,
                                    p_initMsgList => fnd_api.g_false,
                                    p_endDebug => fnd_api.g_true,
                                    p_destroyTrees => fnd_api.g_true,
                                    p_treeMode => inv_quantity_tree_pvt.g_reservation_mode,
                                    p_treeSrcName => null,
                                    x_returnStatus => x_returnStatus);
    if ( x_returnStatus = fnd_api.g_ret_sts_unexp_error ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('Done with lot derivation',l_returnStatus);
    end if;

    --now that we have exploded components and derived lots
    --merge these with recorded details
	  flm_execution_util.get_backflush_comps(
	  p_wip_ent_id    => p_wipEntityID,
	  p_line_id       => l_line_id,
	  p_assyID        => p_assyID,
	  p_orgID         => p_orgID,
	  p_qty           => p_qty,
	  p_altBomDesig   => l_alt_bom,
	  p_altOption     => 2,
	  p_bomRevDate    => l_bomRevDate,
	  p_txnDate       => p_txnDate,
	  p_projectID     => p_projectID,
	  p_taskID        => p_taskID,
	  p_toOpSeqNum    => p_toOpSeqNum,
	  p_altRoutDesig  => l_alt_rtg,
	  x_compInfo      => x_compInfo,
	  x_returnStatus  => x_returnStatus);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_flow.explodeBOMAndDerive',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'success',
                           x_returnStatus => l_returnStatus);
    end if;

  exception
  when fnd_api.g_exc_unexpected_error then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    x_errMessage := fnd_msg_pub.get(p_encoded => 'F');
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_flow.explodeBOMAndDerive',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
    rollback;


  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    x_errMessage := SQLERRM;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wma_flow.explodeBOMAndDerive',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errMessage,
                           x_returnStatus => l_returnStatus);
    end if;
    rollback;
  end explodeBOMAndDerive;

END wma_flow;

/
