--------------------------------------------------------
--  DDL for Package Body WMA_CFM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_CFM" AS
/* $Header: wmapcfmb.pls 115.16 2003/10/01 21:14:33 rseela ship $ */

   /**
    * This procedure is the entry point for work order-less/flow transaction.
    * Parameters:
    *   parameters  CfmParam contains values from the mobile form.
    *   status      Indicates success (0), failure (-1).
    *   errMessage  The error or warning message, if any.
    */
   PROCEDURE process(param      IN     CfmParam,
                     status     OUT NOCOPY NUMBER,
                     errMessage OUT NOCOPY VARCHAR2) IS
     cfmRec CfmRecord;
     errMsg VARCHAR2(241);
   Begin
     if ( derive(param, cfmRec, errMsg) = false ) then
       status := -1;
       errMessage := errMsg;
       return;
     end if;

     if ( put(cfmRec, errMsg) = false ) then
       status := -1;
       errMessage := errMsg;
       return;
     end if;

   EXCEPTION
    when others then
      status := -1;
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_cfm.process');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
   End process;

  PROCEDURE process(lpnParam   IN     LpnCfmParam,
                    status     OUT NOCOPY NUMBER,
                    errMessage OUT NOCOPY VARCHAR2) IS
     lpnCfmRec LpnCfmRecord;
     errMsg VARCHAR2(241);
   Begin
     if ( derive(lpnParam, lpnCfmRec, errMsg) = false ) then
       status := -1;
       errMessage := errMsg;
       return;
     end if;

     if ( put(lpnCfmRec, errMsg) = false ) then
       status := -1;
       errMessage := errMsg;
       return;
     end if;

   EXCEPTION
    when others then
      status := -1;
      fnd_message.set_name ('WIP', 'GENERIC_ERROR');
      fnd_message.set_token ('FUNCTION', 'wma_cfm.process');
      fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
      errMessage := fnd_message.get;
   End process;

   /**
    * This function is used to derive the neccessary information to filled out
    * the CfmRecord structure to passed into function put.
    */
   Function derive(param CfmParam,
                   cfmRec OUT NOCOPY CfmRecord,
                   errMsg OUT NOCOPY VARCHAR2) return boolean IS
     assembly wma_common.Item;
     periodID number;
     openPastPeriod boolean := false;
     defaultPrefix VARCHAR2(200);
     scheduleNumber VARCHAR2(30);
     scrapAcctID NUMBER := null;
     dummy NUMBER;
     accountingClass VARCHAR2(30);
     errMesg1 VARCHAR2(30);
     errClass1 VARCHAR2(10);
     errMesg2 VARCHAR2(30);
     errClass2 VARCHAR2(10);
     x_released_revs_type	NUMBER;
     x_released_revs_meaning	Varchar2(30);


   Begin

     assembly := wma_derive.getItem(param.assemblyID,
                                    param.environment.orgID,
                                    param.locatorID);

     if assembly.revQtyControlCode = WIP_CONSTANTS.REV then
       /* 3033785 */
       wip_common.Get_Released_Revs_Type_Meaning (x_released_revs_type,
                                                  x_released_revs_meaning
                                                 );

        BOM_REVISIONS.Get_Revision(
                        type         => 'PART',
                        eco_status   => x_released_revs_meaning,
                        examine_type => 'ALL',
                        org_id       => param.environment.orgID,
                        item_id      => param.assemblyID,
                        rev_date     => param.transactionDate,
                        itm_rev      => cfmRec.row.revision);
     else
       cfmRec.row.revision := NULL;
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

     cfmRec.row.transaction_date := param.transactionDate;

     -- derive routing and bom rev info
     dummy := Wip_Flow_Derive.bom_revision (
                 p_bom_rev      => cfmRec.row.bom_revision,
                 p_rev          => cfmRec.row.revision,
                 p_bom_rev_date => cfmRec.row.bom_revision_date,
                 p_item_id      => param.assemblyID,
                 p_start_date   => cfmRec.row.transaction_date,
                 p_Org_id       => param.environment.orgID);

     dummy := Wip_Flow_Derive.routing_revision(
                 p_rout_rev      => cfmRec.row.routing_revision,
                 p_rout_rev_date => cfmRec.row.routing_revision_date,
                 p_item_id       => param.assemblyID,
                 p_start_date    => cfmRec.row.transaction_date,
                 p_Org_id        => param.environment.orgID);


     cfmRec.row.transaction_interface_id := param.transactionInterfaceID;
     cfmRec.row.transaction_header_id := param.transactionHeaderID;
     cfmRec.row.lock_flag := 2;
     cfmRec.row.transaction_mode := WIP_CONSTANTS.BACKGROUND;
     cfmRec.row.process_flag := WIP_CONSTANTS.PENDING;
     cfmRec.row.validation_required := 1;

     cfmRec.row.source_code := WMA_COMMON.SOURCE_CODE;
     cfmRec.row.source_line_id := -1;
     cfmRec.row.source_header_id := -1;

     cfmRec.row.last_updated_by := param.environment.userID;
     cfmRec.row.last_update_date := sysdate;
     cfmRec.row.creation_date := sysdate;
     cfmRec.row.created_by := param.environment.userID;

     cfmRec.row.inventory_item_id := param.assemblyID;
     cfmRec.row.organization_id := param.environment.orgID;
     cfmRec.row.acct_period_id := periodID;

     cfmRec.row.transaction_type_id := param.transactionType;
     cfmRec.row.negative_req_flag := 1;
     cfmRec.row.transaction_quantity := param.transactionQty;
     cfmRec.row.primary_quantity := param.transactionQty;

     if ( param.transactionType = WIP_CONSTANTS.CPLASSY_TYPE ) then
        -- for completion
        cfmRec.row.transaction_action_id := WIP_CONSTANTS.CPLASSY_ACTION;
     elsif ( param.transactionType = WIP_CONSTANTS.RETASSY_TYPE ) then
        -- for return
        cfmRec.row.transaction_action_id := WIP_CONSTANTS.RETASSY_ACTION;
     elsif ( param.transactionType in (WIP_CONSTANTS.SCRASSY_TYPE,
                                       WIP_CONSTANTS.RETSCRA_TYPE) ) then
        -- for scrap
        cfmRec.row.transaction_action_id := WIP_CONSTANTS.SCRASSY_ACTION;
        if ( wma_util.getScrapAcctID(param.environment.orgID,
                                     scrapAcctID,
                                     errMsg) = false ) then
          return false;
        end if;
     end if;

     cfmRec.row.distribution_account_id := scrapAcctID;
     cfmRec.row.transaction_uom := param.transactionUOM;
     cfmRec.row.subinventory_code := param.subinventoryCode;
     cfmRec.row.locator_id := param.locatorID;
     cfmRec.row.reason_id := param.reasonID;
     cfmRec.row.qa_collection_id := param.qualityID;
     cfmRec.row.transaction_source_type_id := 5; -- means WIP
     cfmRec.row.wip_entity_type := 4; -- means flow schedule

/***************************************************************************
 * commented out statement below because we do not need to use this value
 * below no more. Moreover, the size of
 * MTL_TRANSACTION_TYPES.TRANSACTION_TYPE_NAME is now VARCHAR2(80), but the
 * size of cfmRec.row.transaction_source_name is VARCHAR2(30).
 ***************************************************************************/
/*     select transaction_type_name
       into cfmRec.row.transaction_source_name
     from mtl_transaction_types
     where transaction_type_id = param.transactionType;
*/
     cfmRec.row.schedule_number := scheduleNumber;
     cfmRec.row.repetitive_line_id := param.lineId;
     cfmRec.row.operation_seq_num := param.lineOp;
     cfmRec.row.scheduled_flag := param.scheduledFlag;
     cfmRec.row.flow_schedule := 'Y';
     cfmRec.row.transaction_source_id := param.wipEntityID;

     cfmRec.row.accounting_class := accountingClass;
     cfmRec.row.kanban_card_id := param.kanbanID;

     cfmRec.row.demand_source_header_id := param.demandSourceHeaderID;
     cfmRec.row.demand_source_line := param.demandSourceLine;
     cfmRec.row.demand_source_delivery := param.demandSourceDelivery;

     cfmRec.row.source_project_id := param.projectID;
     cfmRec.row.source_task_id := param.taskID;
     if ( param.wipEntityID is not null and param.scheduledFlag = 1 and
          param.projectID is null ) then
       select project_id,
              task_id
         into cfmRec.row.source_project_id,
              cfmRec.row.source_task_id
         from wip_flow_schedules
        where wip_entity_id = param.wipEntityID
          and organization_id = param.environment.orgID;
     end if;

     /* -- Commented Out By Rajesh as reservation parameters will be passed fromUI
     if ( param.wipEntityID is not null and param.scheduledFlag = 1 ) then
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
           into cfmRec.row.demand_source_header_id,
                cfmRec.row.demand_source_line,
                cfmRec.row.demand_source_delivery
           from wip_flow_schedules
          where organization_id = param.environment.orgID
            and wip_entity_id = param.wipEntityID;
       end if;
     end if;
     */

     return true;
   End derive;

  Function derive(lpnParam LpnCfmParam,
                  lpnCfmRec OUT NOCOPY LpnCfmRecord,
                  errMsg OUT NOCOPY VARCHAR2) return boolean
 IS
     assembly wma_common.Item;
     periodID number;
     openPastPeriod boolean := false;
     defaultPrefix VARCHAR2(200);
     scheduleNumber VARCHAR2(30);
     scrapAcctID NUMBER := null;
     dummy NUMBER;
     accountingClass VARCHAR2(30);
     errMesg1 VARCHAR2(30);
     errClass1 VARCHAR2(10);
     errMesg2 VARCHAR2(30);
     errClass2 VARCHAR2(10);
     revision VARCHAR(30);
     x_released_revs_type	NUMBER;
     x_released_revs_meaning	Varchar2(30);

   Begin

     -- validate the qty to make sure it is greater than zero.
     if ( lpnParam.transactionQty <= 0 ) then
       fnd_message.set_name('INV', 'INV_GREATER_THAN_ZERO');
       errMsg := fnd_message.get;
       return false;
     end if;

     assembly := wma_derive.getItem(lpnParam.assemblyID,
                                    lpnParam.environment.orgID,
                                    lpnParam.locatorID);

     if assembly.revQtyControlCode = WIP_CONSTANTS.REV then
        /* 3033785 */
        wip_common.Get_Released_Revs_Type_Meaning (x_released_revs_type,
                                                   x_released_revs_meaning
                                                  );
        BOM_REVISIONS.Get_Revision(
                        type         => 'PART',
                        eco_status   => x_released_revs_meaning,
                        examine_type => 'ALL',
                        org_id       => lpnParam.environment.orgID,
                        item_id      => lpnParam.assemblyID,
                        rev_date     => lpnParam.transactionDate,
                        itm_rev      => revision);
     else
       revision := NULL;
     end if;

     accountingClass := wip_common.default_acc_class(
                            lpnParam.environment.orgID,
                            lpnParam.assemblyID,
                            4,  -- for flow schedule
                            assembly.projectID,
                            errMesg1,
                            errClass1,
                            errMesg2,
                            errClass2);

     -- get the accounting period
     invttmtx.tdatechk(
          org_id           => lpnParam.environment.orgID,
          transaction_date => lpnParam.transactionDate,
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
     --if ( lpnParam.scheduledFlag = 3 and lpnParam.scheduleNumber is null ) then
     --  defaultPrefix := substr(fnd_profile.value('WIP_JOB_PREFIX'), 1, 200);
     --  scheduleNumber := defaultPrefix || wma_derive.getNextVal('WIP_JOB_NUMBER_S');
     --else
     --  scheduleNumber := lpnParam.scheduleNumber;
     --end if;

     lpnCfmRec.row.transaction_date := lpnParam.transactionDate;

     -- derive routing and bom rev info
     dummy := Wip_Flow_Derive.bom_revision (
                 p_bom_rev      => lpnCfmRec.row.bom_revision,
                 p_rev          => revision,--lpnCfmRec.row.revision,
                 p_bom_rev_date => lpnCfmRec.row.bom_revision_date,
                 p_item_id      => lpnParam.assemblyID,
                 p_start_date   => lpnCfmRec.row.transaction_date,
                 p_Org_id       => lpnParam.environment.orgID);

     dummy := Wip_Flow_Derive.routing_revision(
                 p_rout_rev      => lpnCfmRec.row.routing_revision,
                 p_rout_rev_date => lpnCfmRec.row.routing_revision_date,
                 p_item_id       => lpnParam.assemblyID,
                 p_start_date    => lpnCfmRec.row.transaction_date,
                 p_Org_id        => lpnParam.environment.orgID);

     -- fix bug 1910976
     if ( lpnCfmRec.row.bom_revision = NULL) then
        lpnCfmRec.row.bom_revision := revision;
     end if;

     lpnCfmRec.row.header_id := lpnParam.headerID;
     lpnCfmRec.row.lock_flag := 'N';
     lpnCfmRec.row.transaction_mode := WIP_CONSTANTS.BACKGROUND;


     lpnCfmRec.row.last_updated_by := lpnParam.environment.userID;
     lpnCfmRec.row.last_update_date := sysdate;
     lpnCfmRec.row.creation_date := sysdate;
     lpnCfmRec.row.created_by := lpnParam.environment.userID;
     lpnCfmRec.row.lpn_id := lpnParam.lpnID;

     lpnCfmRec.row.inventory_item_id := lpnParam.assemblyID;
     lpnCfmRec.row.organization_id := lpnParam.environment.orgID;
     lpnCfmRec.row.acct_period_id := periodID;

     lpnCfmRec.row.transaction_type_id := lpnParam.transactionType;
     lpnCfmRec.row.transaction_quantity := lpnParam.transactionQty;
     lpnCfmRec.row.primary_quantity := lpnParam.transactionQty;

     if ( lpnParam.transactionType = WIP_CONSTANTS.CPLASSY_TYPE ) then
        -- for completion
        lpnCfmRec.row.transaction_action_id := WIP_CONSTANTS.CPLASSY_ACTION;
     elsif ( lpnParam.transactionType = WIP_CONSTANTS.RETASSY_TYPE ) then
        -- for return
        lpnCfmRec.row.transaction_action_id := WIP_CONSTANTS.RETASSY_ACTION;
        lpnCfmRec.row.transaction_quantity := lpnParam.transactionQty * -1;
        lpnCfmRec.row.primary_quantity := lpnParam.transactionQty * -1;
     elsif ( lpnParam.transactionType = WIP_CONSTANTS.SCRASSY_TYPE ) then
        -- for scrap
        lpnCfmRec.row.transaction_action_id := WIP_CONSTANTS.SCRASSY_ACTION;
        if ( wma_util.getScrapAcctID(lpnParam.environment.orgID,
                                     scrapAcctID,
                                     errMsg) = false ) then
          return false;
        end if;
     elsif ( lpnParam.transactionType = 91 ) then
        -- for return from scrap, it has the same action id as scrap, you
        -- can only distinguish them by type id
        lpnCfmRec.row.transaction_action_id := WIP_CONSTANTS.SCRASSY_ACTION;
        lpnCfmRec.row.transaction_quantity := lpnParam.transactionQty * -1;
        lpnCfmRec.row.primary_quantity := lpnParam.transactionQty * -1;
        if ( wma_util.getScrapAcctID(lpnParam.environment.orgID,
                                     scrapAcctID,
                                     errMsg) = false ) then
          return false;
        end if;
     end if;
--     lpnCfmRec.row.distribution_account_id := scrapAcctID;
     lpnCfmRec.row.transaction_uom := lpnParam.transactionUOM;
     lpnCfmRec.row.subinventory_code := lpnParam.subinventoryCode;
     lpnCfmRec.row.locator_id := lpnParam.locatorID;
     lpnCfmRec.row.reason_id := lpnParam.reasonID;
     lpnCfmRec.row.qa_collection_id := lpnParam.qualityID;
     lpnCfmRec.row.transaction_source_type_id := 5; -- means WIP
     lpnCfmRec.row.wip_entity_type := 4; -- means flow schedule

--     lpnCfmRec.row.schedule_number := scheduleNumber;
--     lpnCfmRec.row.repetitive_line_id := lpnParam.lineId;
--     lpnCfmRec.row.operation_seq_num := lpnParam.lineOp;
     lpnCfmRec.row.completion_transaction_id := lpnParam.completionTxnID;
     lpnCfmRec.row.wip_entity_id := lpnParam.wipEntityID;
--     lpnCfmRec.row.scheduled_flag := lpnParam.scheduledFlag;
--     lpnCfmRec.row.flow_schedule := 'Y';

     lpnCfmRec.row.accounting_class := accountingClass;
     lpnCfmRec.row.item_project_id := assembly.projectID;
     lpnCfmRec.row.item_task_id := assembly.taskID;
     lpnCfmRec.row.kanban_card_id := lpnParam.kanbanID;

     lpnCfmRec.row.demand_source_header_id := lpnParam.demandSourceHeaderID;
     lpnCfmRec.row.demand_source_line := lpnParam.demandSourceLine;
     lpnCfmRec.row.demand_source_delivery := lpnParam.demandSourceDelivery;
     return true;
   End derive;


   /**
    * This function is used to insert the record encapsulated in cfmRec to
    * table mtl_transactions_interface and some furthur validation and processing.
    */
   Function put(cfmRec CfmRecord, errMsg OUT NOCOPY VARCHAR2) return boolean IS
   Begin
     INSERT INTO mtl_transactions_interface
                (transaction_interface_id,
                 transaction_header_id,
                 lock_flag, transaction_mode,
                 process_flag, validation_required,
                 source_code,
                 source_line_id,
                 source_header_id,
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
                 negative_req_flag,
                 transaction_action_id,
                 transaction_quantity,
                 primary_quantity,
                 distribution_account_id,
                 transaction_uom,
                 subinventory_code,
                 locator_id, reason_id,
                 qa_collection_id,
                 transaction_source_type_id,
                 wip_entity_type,
                 transaction_source_name,
                 schedule_number,
                 repetitive_line_id,
                 operation_seq_num,
                 scheduled_flag, flow_schedule,
                 transaction_source_id,
                 accounting_class,
                 source_project_id,
                 source_task_id,
                 kanban_card_id,
                 demand_source_header_id,
                 demand_source_line,
                 demand_source_delivery
                )
         VALUES (cfmRec.row.transaction_interface_id,
                 cfmRec.row.transaction_header_id,
                 cfmRec.row.lock_flag, cfmRec.row.transaction_mode,
                 cfmRec.row.process_flag, cfmRec.row.validation_required,
                 cfmRec.row.source_code, cfmRec.row.source_line_id,
                 cfmRec.row.source_header_id,
                 cfmRec.row.last_updated_by, cfmRec.row.last_update_date,
                 cfmRec.row.creation_date, cfmRec.row.created_by,
                 cfmRec.row.inventory_item_id,
                 cfmRec.row.organization_id,
                 cfmRec.row.acct_period_id,
                 cfmRec.row.transaction_date,
                 cfmRec.row.bom_revision, cfmRec.row.revision,
                 cfmRec.row.bom_revision_date,
                 cfmRec.row.routing_revision, cfmRec.row.routing_revision_date,
                 cfmRec.row.transaction_type_id,
                 cfmRec.row.negative_req_flag,
                 cfmRec.row.transaction_action_id,
                 cfmRec.row.transaction_quantity,
                 cfmRec.row.primary_quantity,
                 cfmRec.row.distribution_account_id,
                 cfmRec.row.transaction_uom,
                 cfmRec.row.subinventory_code,
                 cfmRec.row.locator_id, cfmRec.row.reason_id,
                 cfmRec.row.qa_collection_id,
                 cfmRec.row.transaction_source_type_id,
                 cfmRec.row.wip_entity_type,
                 cfmRec.row.transaction_source_name,
                 cfmRec.row.schedule_number,
                 cfmRec.row.repetitive_line_id,
                 cfmRec.row.operation_seq_num,
                 cfmRec.row.scheduled_flag, cfmRec.row.flow_schedule,
                 cfmRec.row.transaction_source_id,
                 cfmRec.row.accounting_class,
                 cfmRec.row.source_project_id,
                 cfmRec.row.source_task_id,
                 cfmRec.row.kanban_card_id,
                 cfmRec.row.demand_source_header_id,
                 cfmRec.row.demand_source_line,
                 cfmRec.row.demand_source_delivery
                );
     return true;

     EXCEPTION
     when others then
       fnd_message.set_name ('WIP', 'GENERIC_ERROR');
       fnd_message.set_token ('FUNCTION', 'wma_work_order_less.derive');
       fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
       errMsg := fnd_message.get;
       return false;
   End put;

  Function put(lpnCfmRec LpnCfmRecord, errMsg OUT NOCOPY VARCHAR2) return boolean
 IS
   Begin
     INSERT INTO wip_lpn_completions
                (header_id, source_id, source_code,
                 lock_flag, transaction_mode,
                 last_updated_by, last_update_date,
                 creation_date, created_by,
                 inventory_item_id,
                 organization_id,
                 acct_period_id,
                 transaction_date,
                 bom_revision, --check later revision,
                 bom_revision_date,
                 routing_revision, routing_revision_date,
                 transaction_type_id,
                 transaction_action_id,
                 transaction_quantity,
                 primary_quantity,
--                 distribution_account_id,
                 transaction_uom,
                 subinventory_code,
                 locator_id, reason_id,
                 qa_collection_id,
                 transaction_source_type_id,
                 wip_entity_id,
                 wip_entity_type,
                 --repetitive_line_id,
                 operation_seq_num,
                 transaction_source_id,
                 accounting_class,
                 item_project_id,
                 item_task_id,
                 kanban_card_id,
                 lpn_id,
                 completion_transaction_id,
                 demand_source_header_id,
                 demand_source_line,
                 demand_source_delivery
                )
         VALUES (lpnCfmRec.row.header_id, lpnCfmRec.row.header_id, WMA_COMMON.SOURCE_CODE,
                 lpnCfmRec.row.lock_flag, lpnCfmRec.row.transaction_mode,
                 lpnCfmRec.row.last_updated_by, lpnCfmRec.row.last_update_date,
                 lpnCfmRec.row.creation_date, lpnCfmRec.row.created_by,
                 lpnCfmRec.row.inventory_item_id,
                 lpnCfmRec.row.organization_id,
                 lpnCfmRec.row.acct_period_id,
                 lpnCfmRec.row.transaction_date,
                 lpnCfmRec.row.bom_revision,-- lpnCfmRec.row.revision,
                 lpnCfmRec.row.bom_revision_date,
                 lpnCfmRec.row.routing_revision, lpnCfmRec.row.routing_revision_date,
                 lpnCfmRec.row.transaction_type_id,
                 lpnCfmRec.row.transaction_action_id,
                 lpnCfmRec.row.transaction_quantity,
                 lpnCfmRec.row.primary_quantity,
--                 lpnCfmRec.row.distribution_account_id,
                 lpnCfmRec.row.transaction_uom,
                 lpnCfmRec.row.subinventory_code,
                 lpnCfmRec.row.locator_id, lpnCfmRec.row.reason_id,
                 lpnCfmRec.row.qa_collection_id,
                 lpnCfmRec.row.transaction_source_type_id,
                 lpnCfmRec.row.wip_entity_id,
                 lpnCfmRec.row.wip_entity_type,
                 --lpnCfmRec.row.repetitive_line_id,
                 lpnCfmRec.row.operation_seq_num,
                 lpnCfmRec.row.transaction_source_id,
                 lpnCfmRec.row.accounting_class,
                 lpnCfmRec.row.item_project_id, lpnCfmRec.row.item_task_id,
                 lpnCfmRec.row.kanban_card_id,
                 lpnCfmRec.row.lpn_id,
                 lpnCfmRec.row.completion_transaction_id,
                 lpnCfmRec.row.demand_source_header_id,
                 lpnCfmRec.row.demand_source_line,
                 lpnCfmRec.row.demand_source_delivery
                );
     return true;

     EXCEPTION
     when others then
       fnd_message.set_name ('WIP', 'GENERIC_ERROR');
       fnd_message.set_token ('FUNCTION', 'wma_work_order_less.derive');
       fnd_message.set_token ('ERROR', SQLCODE || ' ' || SQLERRM);
       errMsg := fnd_message.get;
       return false;
   End put;

END wma_cfm;

/
