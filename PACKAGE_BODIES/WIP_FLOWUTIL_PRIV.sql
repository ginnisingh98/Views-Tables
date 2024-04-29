--------------------------------------------------------
--  DDL for Package Body WIP_FLOWUTIL_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_FLOWUTIL_PRIV" as
/* $Header: wipfscmb.pls 120.21.12010000.5 2009/06/30 23:50:24 ankohli ship $ */

  function checkSubstitution(p_parentID in number) return varchar2;

  procedure mergeComponents(p_parentID     in  number,
                            x_returnStatus out NOCOPY varchar2);

  procedure generateIssueLocator(p_parentID     in  number,
                                 x_returnStatus out NOCOPY varchar2);

  /**
   * This function does the default for flow transactions.
   */
 function deriveCompletion(p_scheduledFlag in number,
                           p_orgID         in number,
                           p_itemID        in number,
                           p_txnSrcID      in number,
                           p_txnDate       in date,
                           p_txnActionID   in number,
                           p_schedNum      in  out NOCOPY varchar2,
                           p_srcProjID     in  out NOCOPY number,
                           p_projID        in  out NOCOPY number,
                           p_srcTaskID     in  out NOCOPY number,
                           p_taskID        in  out NOCOPY number,
                           p_bomRev        in  out NOCOPY varchar2,
                           p_rev           in  out NOCOPY varchar2,
                           p_bomRevDate    in  out NOCOPY date,
                           p_altBomDes     in  out NOCOPY varchar2,
                           p_routRev       in  out NOCOPY varchar2,
                           p_routRevDate   in  out NOCOPY date,
                           p_altRtgDes     in  out NOCOPY varchar2,
                           p_cplSubinv     in  out NOCOPY varchar2,
                           p_cplLocID      in  out NOCOPY number,
                           p_classCode     in  out NOCOPY varchar2) return varchar2;


  /**
   * This is to validate the interface record for flow parent record.
   */
  function validateInterfaceCompletion(p_rowid in rowid) return varchar2;

  /**
   * This is to derive and validate the flow interface records for the given
   * header id.
   */
  procedure processFlowInterfaceRecords(p_txnHeaderID in number) is
    cursor flow_c is
      select rowid,
             transaction_interface_id,
             primary_quantity,
             operation_seq_num,
             scheduled_flag,
             organization_id,
             inventory_item_id,
             transaction_source_id,
             transaction_date,
             transaction_type_id,
             transaction_action_id,
             schedule_number,
             source_project_id,
             project_id,
             source_task_id,
             task_id,
             bom_revision,
             revision,
             bom_revision_date,
             alternate_bom_designator,
             routing_revision,
             routing_revision_date,
             alternate_routing_designator,
             subinventory_code,
             locator_id,
             accounting_class,
             acct_period_id,
             completion_transaction_id,
             transaction_batch_id,
             transaction_batch_seq
        from mtl_transactions_interface
       where transaction_header_id = p_txnHeaderID
         and transaction_source_type_id = 5
         and process_flag = 1
         and upper(nvl(flow_schedule, 'N')) = 'Y'
         and transaction_action_id in (WIP_CONSTANTS.SCRASSY_ACTION,
                                       WIP_CONSTANTS.CPLASSY_ACTION,
                                       WIP_CONSTANTS.RETASSY_ACTION);
    l_returnStatus varchar2(1);
    l_validationException exception;

    l_params wip_logger.param_tbl_t;

    l_fromUI NUMBER;--> 0 if the record originated from oracle user interfaces

    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
    l_src_code VARCHAR2(2000);
    l_errMsg VARCHAR2(50);    /* Fix for Bug#5187500. Changed it to 50 */
    l_bf_count       NUMBER ; /* Fix for Bug#5187500 */
    l_lot_ser_count  NUMBER ; /* Fix for Bug#5187500 */
    l_lot_entry_type NUMBER ; /* Fix for Bug#5187500 */
    l_nontxn_excluded VARCHAR2(1); --added for fix 5630078
  begin
    l_lot_entry_type := 0 ; /* Fix for Bug#5187500 */

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHeaderID';
      l_params(1).paramValue := p_txnHeaderID;
      wip_logger.entryPoint(p_procName => 'wip_flowutil_priv.processFlowInterfaceRecords',
                            p_params => l_params,
                            x_returnStatus => l_returnStatus);
      if(l_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    for flow_rec in flow_c loop
    begin
      select count(*)
        into l_fromUI
        from mtl_transactions_interface
       where parent_id is not null
         and parent_id = flow_rec.transaction_interface_id
         and substitution_type_id is null;

      if(l_fromUI = 0) then
        l_returnStatus := deriveCompletion
                            (
                             flow_rec.scheduled_flag,
                             flow_rec.organization_id,
                             flow_rec.inventory_item_id,
                             flow_rec.transaction_source_id,
                             flow_rec.transaction_date,
                             flow_rec.transaction_action_id,
                             flow_rec.schedule_number,
                             flow_rec.source_project_id,
                             flow_rec.project_id,
                             flow_rec.source_task_id,
                             flow_rec.task_id,
                             flow_rec.bom_revision,
                             flow_rec.revision,
                             flow_rec.bom_revision_date,
                             flow_rec.alternate_bom_designator,
                             flow_rec.routing_revision,
                             flow_rec.routing_revision_date,
                             flow_rec.alternate_routing_designator,
                             flow_rec.subinventory_code,
                             flow_rec.locator_id,
                             flow_rec.accounting_class);
        if ( l_returnStatus = fnd_api.g_ret_sts_success ) then
          update mtl_transactions_interface
             set schedule_number = flow_rec.schedule_number,
                 source_project_id = flow_rec.source_project_id,
                 project_id = flow_rec.project_id,
                 source_task_id = flow_rec.source_task_id,
                 task_id = flow_rec.task_id,
                 bom_revision = flow_rec.bom_revision,
                 revision = flow_rec.revision,
                 bom_revision_date = flow_rec.bom_revision_date,
                 alternate_bom_designator = flow_rec.alternate_bom_designator,
                 routing_revision = flow_rec.routing_revision,
                 routing_revision_date = flow_rec.routing_revision_date,
                 alternate_routing_designator = flow_rec.alternate_routing_designator,
                 subinventory_code = flow_rec.subinventory_code,
                 locator_id = flow_rec.locator_id,
                 accounting_class = flow_rec.accounting_class
           where rowid = flow_rec.rowid;
        else
          fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_DEFAULTING');
          fnd_message.set_token('ENTITY1',to_char(flow_rec.transaction_interface_id));
          wip_mti_pub.setMtiError(p_txnInterfaceID => flow_rec.transaction_interface_id,
                                  p_errCode => null,
                                  p_msgData => fnd_message.get);
          l_errMsg := 'error defaulting';
          raise l_validationException;
        end if;

        if ( validateInterfaceCompletion(flow_rec.rowid) <>
                   fnd_api.g_ret_sts_success ) then
          l_errMsg := 'error validating';
          raise l_validationException;
        end if;

       -- now validate the substitution records
        if ( checkSubstitution(flow_rec.transaction_interface_id) <>
                        fnd_api.g_ret_sts_success ) then
          l_errMsg := 'check sub error';
          raise l_validationException;
        end if;
      end if;

      --for both UI and background, create a flow schedule, this stmt needs to be
      --after deriveCompletion() in case of background.

	/* Fix for bug : 8358517 (FP 8320778)
 	We need to create flow schedule only when transaction_source_id (wip_entity_id) is not
 	populated in mti. If transaction_source_id is populated,then procedure createFlowSchedule
 	returns null for wip_entity_id and hence flow_rec.transaction_source_id is assigned null.
 	*/
      if flow_rec.transaction_source_id is null then
        createFlowSchedule(p_txnInterfaceID => flow_rec.transaction_interface_id,
                           x_returnStatus => l_returnStatus,
                           x_wipEntityID => flow_rec.transaction_source_id);
        if(l_returnStatus <> fnd_api.g_ret_sts_success) then
          l_errMsg := 'createFlowSchedule error';
          raise l_validationException;
        end if;
      end if;

      --Bug 5181899, for schedules submitted from oracle ui, if user has submitted the txn
      --with no component, then we should not re-explode the bill
      select source_code
      into   l_src_code
      from   mtl_transactions_interface
      where  rowid = flow_rec.rowid;

      if(l_src_code = 'WIP_FLOW_SCHEDULES_OA' OR l_src_code = 'WIP_FLOW_SCHEDULES')
        then l_fromUI := 1;
      end if;

      if(l_fromUI = 0) then
        -- explode the bom
        explodeRequirementsToMTI(p_txnHeaderID => p_txnHeaderID,
                                 p_parentID => flow_rec.transaction_interface_id,
                                 p_txnTypeID => flow_rec.transaction_type_id,
                                 p_assyID => flow_rec.inventory_item_id,
                                 p_orgID => flow_rec.organization_id,
                                 p_qty => flow_rec.primary_quantity,
                                 p_altBomDesig => flow_rec.alternate_bom_designator,
                                 p_altOption => 2,
     /* Fix for bug#3423629 */   p_bomRevDate => flow_rec.bom_revision_date,
                                 p_txnDate => flow_rec.transaction_date,
                                 p_projectID => flow_rec.project_id,
                                 p_taskID => flow_rec.task_id,
                                 p_toOpSeqNum => flow_rec.operation_seq_num,
                                 p_altRoutDesig => flow_rec.alternate_routing_designator,
                                 p_acctPeriodID => flow_rec.acct_period_id,
                                 p_txnMode => wip_constants.background,
                                 p_lockFlag => wip_constants.yes,
                                 p_txnSourceID => flow_rec.transaction_source_id,
                                 p_cplTxnID => flow_rec.completion_transaction_id,
                                 p_txnBatchID => flow_rec.transaction_batch_id,
                                 p_txnBatchSeq => flow_rec.transaction_batch_seq + 1,
                                 p_defaultPushSubinv => 'Y', --bug#5262858
                                 x_returnStatus => l_returnStatus,
                                 x_nontxn_excluded =>l_nontxn_excluded); --added for fix 5630078
        if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
          l_errMsg := 'explosion error';
          raise l_validationException;
        end if;

        -- now merge the exploded records with those substitution records.
        mergeComponents(flow_rec.transaction_interface_id, l_returnStatus);
        if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
          l_errMsg := 'component merge error';
          raise l_validationException;
        end if;

        -- Start for Fix for Bug#5187500. Default Lots

        l_bf_count       := 0 ;
        l_lot_ser_count  := 0 ;

       SELECT COUNT(*)
       INTO   l_bf_count
       FROM   mtl_transactions_interface
       WHERE  transaction_header_id = p_txnHeaderID
       AND    completion_transaction_id = flow_rec.completion_transaction_id
       AND    transaction_action_id IN (WIP_CONSTANTS.ISSCOMP_ACTION,
                                   WIP_CONSTANTS.RETCOMP_ACTION,
                                   WIP_CONSTANTS.ISSNEGC_ACTION,
                                   WIP_CONSTANTS.RETNEGC_ACTION);
       SELECT COUNT(*)
       INTO   l_lot_ser_count
       FROM   mtl_transactions_interface mti,
              mtl_system_items msi
       WHERE  mti.organization_id = msi.organization_id
       AND mti.inventory_item_id = msi.inventory_item_id
       AND (msi.lot_control_code = WIP_CONSTANTS.LOT
           OR
           msi.serial_number_control_code IN(WIP_CONSTANTS.FULL_SN,
                                            WIP_CONSTANTS.DYN_RCV_SN))
       AND transaction_header_id = p_txnHeaderID
       AND completion_transaction_id = flow_rec.completion_transaction_id
       AND transaction_action_id IN (WIP_CONSTANTS.ISSCOMP_ACTION,
                                   WIP_CONSTANTS.RETCOMP_ACTION,
                                   WIP_CONSTANTS.ISSNEGC_ACTION,
                                   WIP_CONSTANTS.RETNEGC_ACTION);

       if (l_lot_entry_type = 0 ) then -- Check only once
         SELECT backflush_lot_entry_type
         INTO l_lot_entry_type
         FROM wip_parameters
         WHERE organization_id = flow_rec.organization_id ;
      end if ;

      IF ((l_bf_count <> 0) and (l_lot_ser_count <> 0) and
         (l_lot_entry_type <> WIP_CONSTANTS.MAN_ENTRY)) THEN
         -- derive lot for Components
         wip_autoLotProc_priv.deriveLotsFromMTI
         (p_orgID         => flow_rec.organization_id,
          p_wipEntityID   => flow_rec.transaction_source_id,
          p_txnHdrID      => p_txnHeaderID,
          p_cplTxnID      => flow_rec.completion_transaction_id,
          p_movTxnID      => null,
          p_childMovTxnID => null,
          p_initMsgList   => fnd_api.g_false,
          p_endDebug      => fnd_api.g_false,
          x_returnStatus  => l_returnStatus);
        IF ((l_returnStatus = fnd_api.g_ret_sts_unexp_error)  or
            (l_returnStatus = fnd_api.g_ret_sts_error)) THEN
          l_errMsg := 'wip_autoLotProc_priv.deriveLotsFromMTI failed';
          raise l_validationException ;
        END IF;
      END IF;

    -- End  for Fix for Bug#5187500. Default Lots

        -- update the schedule number column of MTI to the schedule number of the parent record
        -- this way, if it erorred out in MMTT, the user can query up all the records for a completion
        -- transaction
        update mtl_transactions_interface
           set schedule_number = flow_rec.schedule_number
         where completion_transaction_id = flow_rec.completion_transaction_id
           and organization_id = flow_rec.organization_id --fix for bug 4890147, add more criteria so no FTS is done
           and parent_id = flow_rec.transaction_interface_id;

        -- generate issue locator
        if ( flow_rec.source_project_id is not null ) then
          generateIssueLocator(flow_rec.transaction_interface_id, l_returnStatus);
          if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
          l_errMsg := 'issue locator error';
            raise l_validationException;
          end if;
        end if;
      end if;
    exception
      when l_validationException then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log(p_msg => 'Error defaulting/validating interface ' ||
                                  to_char(flow_rec.transaction_interface_id) || ':' || l_errMsg,
                         x_returnStatus => l_returnStatus);
        end if;
        -- skip this one, validate next record. pl/sql doesn't have continue;
    end;
    end loop;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_flowutil_priv.processFlowInterfaceRecords',
                           p_procReturnStatus => fnd_api.g_ret_sts_success,
                           p_msg => 'Finished processFlowInterfaceRecords',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  end processFlowInterfaceRecords;



  /**
   * This function does the default for flow transactions.
   * It doesn''t take the rowid so that everything can be selected from interface table.
   * Instead, it takes all the parameter. The reason is that this might be called from
   * the forms. It''s up to the caller to check the return value and set the error
   * message. 1 means success and 0 means error.
   */
  function deriveCompletion(p_scheduledFlag in number,
                            p_orgID         in number,
                            p_itemID        in number,
                            p_txnSrcID      in number,
                            p_txnDate       in date,
                            p_txnActionID   in number,
                            p_schedNum      in out NOCOPY varchar2,
                            p_srcProjID     in out NOCOPY number,
                            p_projID        in out NOCOPY number,
                            p_srcTaskID     in out NOCOPY number,
                            p_taskID        in out NOCOPY number,
                            p_bomRev        in out NOCOPY varchar2,
                            p_rev           in out NOCOPY varchar2,
                            p_bomRevDate    in out NOCOPY date,
                            p_altBomDes     in out NOCOPY varchar2,
                            p_routRev       in out NOCOPY varchar2,
                            p_routRevDate   in out NOCOPY date,
                            p_altRtgDes     in out NOCOPY varchar2,
                            p_cplSubinv     in out NOCOPY varchar2,
                            p_cplLocID      in out NOCOPY number,
                            p_classCode     in out NOCOPY varchar2) return varchar2 is
    l_errMsg varchar2(240);
    l_dummy number;
  begin
    if ( p_scheduledFlag = 2 ) then
      if (   (wip_flow_derive.schedule_number(
                                p_sched_num => p_schedNum) = 0 )
          or (wip_flow_derive.src_project_id(
                                p_src_proj_id => p_srcProjID,
                                p_proj_id => p_projID) = 0 )
          or (wip_flow_derive.src_task_id(
                                p_src_task_id => p_srcTaskID,
                                p_task_id => p_taskID) = 0 )
          or (wip_flow_derive.bom_revision(
                                p_bom_rev => p_bomRev,
                                p_rev => p_rev,
                                p_bom_rev_date => p_bomRevDate,
                                p_item_id => p_itemID,
                                p_start_date => p_txnDate,
                                p_org_id => p_orgID) = 0 )
          or (wip_flow_derive.routing_revision(
                                p_rout_rev => p_routRev,
                                p_rout_rev_date => p_routRevDate,
                                p_item_id => p_itemID,
                                p_start_date => p_txnDate,
                                p_org_id => p_orgID) = 0 )
          or (p_txnActionID <> WIP_CONSTANTS.SCRASSY_ACTION and
              wip_flow_derive.completion_sub(
                                p_comp_sub => p_cplSubinv,
                                p_item_id => p_itemID,
                                p_org_id => p_orgID,
                                p_alt_rtg_des => p_altRtgDes) = 0 )
          or (p_txnActionID <> WIP_CONSTANTS.SCRASSY_ACTION and
              wip_flow_derive.completion_locator_id(
                                p_comp_loc => p_cplLocID,
                                p_item_id => p_itemID,
                                p_org_id => p_orgID,
                                p_alt_rtg_des => p_altRtgDes,
                                p_proj_id => p_srcProjID,
                                p_task_id => p_taskID,
                                p_comp_sub => p_cplSubinv) = 0 )
          or (wip_flow_derive.class_code(
                                p_class_code => p_classCode,
                                p_err_mesg => l_errMsg,
                                p_org_id => p_orgID,
                                p_item_id => p_itemID,
                                p_wip_entity_type => 4,
                                p_project_id => p_srcProjID) = 0 ) ) then
        return fnd_api.g_ret_sts_error;
      end if;
    else -- else of p_scheduledFlag = 2
      if ( wip_flow_derive.scheduled_flow_derivation(
                                p_txn_action_id => p_txnActionID,
                                p_item_id => p_itemID,
                                p_org_id => p_orgID,
                                p_txn_src_id => p_txnSrcID,
                                p_sched_num => p_schedNum,
                                p_src_proj_id => p_srcProjID,
                                p_proj_id => p_projID,
                                p_src_task_id => p_srcTaskID,
                                p_task_id => p_taskID,
                                p_bom_rev => p_bomRev,
                                p_rev => p_rev,
                                p_bom_rev_date  => p_bomRevDate,
                                p_rout_rev => p_routRev,
                                p_rout_rev_date => p_routRevDate,
                                p_comp_sub => p_cplSubinv,
                                p_class_code => p_classCode,
                                p_wip_entity_type => l_dummy,
                                p_comp_loc => p_cplLocID,
                                p_alt_rtg_des => p_altRtgDes,
                                p_alt_bom_des => p_altBomDes) = 0 ) then
        return fnd_api.g_ret_sts_error;
      end if;
    end if;
    return fnd_api.g_ret_sts_success;
  exception
  when others then
    return fnd_api.g_ret_sts_error;
  end deriveCompletion;


  /**
   * This is to validate the interface record for flow parent record.
   * This function is to be called for validating interface row for flow txns
   * It sets the error for those records that errors out. It the return values
   * is 0, then it means there is validation errors for the given row.
   */
  function validateInterfaceCompletion(p_rowid in rowid) return varchar2 is
    l_dummy number;
    l_scheduleNumber varchar2(30);
    l_interfaceID number;
  begin
    select schedule_number,
           transaction_interface_id
      into l_scheduleNumber,
           l_interfaceID
      from mtl_transactions_interface
     where rowid = p_rowid;

    if ( wip_flow_validation.primary_item_id(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_CANNOT_BUILD_ITEM');

    elsif (wip_flow_validation.class_code(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_INTERFACE_INVALID_CLASS');

    elsif (wip_flow_validation.bom_rev_date(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_INVALID_BOM_REVISION_DATE');

    elsif (wip_flow_validation.bom_revision(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_INVALID_BOM_REVISION');

    elsif (wip_flow_validation.rout_rev_date(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_INVALID_ROUT_REVISION_DATE');

    elsif (wip_flow_validation.routing_revision(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_INVALID_ROUT_REVISION');

    elsif (wip_flow_validation.alt_bom_desg(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_ALTERNATE_BOM');

    elsif (wip_flow_validation.alt_rout_desg(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_ALTERNATE_ROUTING');

    elsif (wip_flow_validation.completion_sub(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_INVALID_COMPLETION_SUB');

    elsif (wip_flow_validation.completion_locator_id(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_INVALID_LOCATOR');

    elsif (wip_flow_validation.demand_class(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_DEMAND_CLASS');

    elsif (wip_flow_validation.schedule_group_id(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_SCHEDULE_GROUP');

    elsif (wip_flow_validation.build_sequence(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_BUILD_SEQUENCE');

    elsif (wip_flow_validation.line_id(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_LINE_ID');

    elsif (wip_flow_validation.project_id(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_INVALID_PROJECT');

    elsif (wip_flow_validation.task_id(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_INVALID_TASK');

    elsif (wip_flow_validation.schedule_number(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'WIP_INVALID_SCHEDULE_NUMBER');

    elsif (wip_flow_validation.unit_number(p_rowid => p_rowid) = 0 ) then
      fnd_message.set_name('WIP', 'UEFF-UNIT NUMBER INVALID');
    else
      return fnd_api.g_ret_sts_success;
    end if;

    wip_mti_pub.setMtiError(p_txnInterfaceID => l_interfaceID,
                            p_errCode => null,
                            p_msgData => fnd_message.get);
    return fnd_api.g_ret_sts_error;
  exception
  when others then
    fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_VALIDATION');
    fnd_message.set_token('ENTITY1', l_scheduleNumber);
    wip_mti_pub.setMtiError(p_txnInterfaceID => l_interfaceID,
                            p_errCode => null,
                            p_msgData => fnd_message.get);
    return fnd_api.g_ret_sts_error;
  end validateInterfaceCompletion;


  /**
   * This procedure validates the substitution type id and the substitution_item_id
   * and inventory_item_id. It also checks the operation seq num?
   * If there is any valiation error, then it will set the process_flag to 3 for
   * the parent record as well as all the child records.
   */
  function checkSubstitution(p_parentID in number) return varchar2 is
    cursor subs_c is
      select inventory_item_id,
             organization_id,
             substitution_item_id,
             substitution_type_id,
             operation_seq_num
        from mtl_transactions_interface
       where parent_id = p_parentID
         and process_flag = 1;

    l_result number := 0;
    l_seeEngItem number;
    l_errMsg varchar2(240);
  begin
    -- validate substitution_type_id
    --    1: Change
    --    2: Delete
    --    3: Add
    --    4: Lot/Serial
    begin
      select count(*)
        into l_result
        from mtl_transactions_interface
       where parent_id = p_parentID
         and process_flag = 1
         and nvl(substitution_type_id, -1) not in (1, 2, 3, 4);

      if ( l_result > 0 ) then
        fnd_message.set_name('WIP', 'WIP_ERROR_SUBST_TYPE');
        wip_mti_pub.setMtiError(p_parentID,
                                'substitution_type_id',
                                substrb(fnd_message.get, 1, 240));
        return fnd_api.g_ret_sts_error;
      end if;

      select count(*)
        into l_result
        from mtl_transactions_interface
       where parent_id = p_parentID
         and process_flag = 1
         and nvl(flow_schedule, 'Y') <> 'Y';

      if ( l_result > 0 ) then
        fnd_message.set_name('WIP', 'WIP_FLOW_FLAG_ERROR');
        wip_mti_pub.setMtiError(p_parentID,
                                'flow_schedule',
                                substrb(fnd_message.get, 1, 240));
        return fnd_api.g_ret_sts_error;
      end if;
    exception
    when others then
      null; -- no substitution record
    end;

    begin
      l_seeEngItem := to_number(fnd_profile.value('WIP_SEE_ENG_ITEMS'));
    exception
    when others then
      l_seeEngItem := 2; -- default to not an engineering item
    end;

    for sub_rec in subs_c loop
      if ( sub_rec.substitution_type_id <> 3 ) then
        l_result := 0;
        select 1
          into l_result
          from mtl_system_items msi
         where msi.organization_id = sub_rec.organization_id
           and msi.inventory_item_id = sub_rec.inventory_item_id
           and msi.mtl_transactions_enabled_flag = 'Y'
           and msi.inventory_item_flag = 'Y'
           and msi.bom_enabled_flag = 'Y'
           and msi.eng_item_flag = decode(l_seeEngItem,
                                          1,
                                          msi.eng_item_flag,
                                          'N')
           and msi.bom_item_type = 4; -- standard type
        if ( l_result = 0 ) then
          fnd_message.set_name('WIP', 'WIP_ERROR_SUBST_ASSEMBLY');
          l_errMsg := 'Original item id ' || to_char(sub_rec.inventory_item_id) ||
                      ' at op seq ' || to_char(sub_rec.operation_seq_num) || '.';
          fnd_message.set_token('ENTITY1', l_errMsg);
          fnd_message.set_token('ENTITY2', 'Original Component');
          wip_mti_pub.setMtiError(p_parentID,
                                  'inventory_item_id',
                                  substrb(fnd_message.get, 1, 240));
          return fnd_api.g_ret_sts_error;
        end if;
      end if;

      if ( sub_rec.substitution_type_id in (1, 3) ) then
        l_result := 0;
        select 1
          into l_result
          from mtl_system_items msi
         where msi.organization_id = sub_rec.organization_id
           and msi.inventory_item_id = sub_rec.substitution_item_id
           and msi.mtl_transactions_enabled_flag = 'Y'
           and msi.inventory_item_flag = 'Y'
           and msi.bom_enabled_flag = 'Y'
           and msi.eng_item_flag = decode(l_seeEngItem,
                                          1,
                                          msi.eng_item_flag,
                                          'N')
           and msi.bom_item_type = 4; -- standard type
        if ( l_result = 0 ) then
          fnd_message.set_name('WIP', 'WIP_ERROR_SUBST_ASSEMBLY');
          l_errMsg := 'Original item id ' || to_char(sub_rec.inventory_item_id) ||
                      ' at op seq ' || to_char(sub_rec.operation_seq_num) || '.';
          fnd_message.set_token('ENTITY1', l_errMsg);
          fnd_message.set_token('ENTITY2', 'Substitution Component');
          wip_mti_pub.setMtiError(p_parentID,
                                  'substitution_item_id',
                                  substrb(fnd_message.get, 1, 240));
          return fnd_api.g_ret_sts_error;
        end if;
      end if;
    end loop;

    return fnd_api.g_ret_sts_success;
  end checkSubstitution;


  /**
   * This procedure explodes the BOM and insert the material requirement into
   * mti table under the given header id and parent id.
   * If the supply subinv and locator in the BOM is not provided, then it will try
   * to default those the rule: BOM level --> item level --> wip parameter
   */
  procedure explodeRequirementsToMTI(p_txnHeaderID     in  number,
                                     p_parentID        in  number,
                                     p_txnTypeID       in  number,
                                     p_assyID          in  number,
                                     p_orgID           in  number,
                                     p_qty             in  number,
                                     p_altBomDesig     in  varchar2,
                                     p_altOption       in  number,
         /* Fix for bug#3423629 */   p_bomRevDate      in  date default NULL,
                                     p_txnDate         in  date,
                                     p_projectID       in  number,
                                     p_taskID          in  number,
                                     p_toOpSeqNum      in  number,
                                     p_altRoutDesig    in  varchar2,
                                     p_txnMode         in  number,
                                     p_lockFlag        in  number := null,
                                     p_txnSourceID     in  number := null,
                                     p_acctPeriodID    in  number := null,
                                     p_cplTxnID        in  number := null,
                                     p_txnBatchID      in  number := null,
                                     p_txnBatchSeq     in  number := null,
         /* Fix for bug#5262858 */   p_defaultPushSubinv in varchar2 default null,
                                     x_returnStatus    out NOCOPY varchar2,
         /* Fix for bug 5630078 */   x_nontxn_excluded out NOCOPY varchar2) is
    l_compTbl system.wip_component_tbl_t;
    l_count number;
    l_childTxnTypeID number;
    l_childTxnActionID number;
    l_insertPhantom number := WIP_CONSTANTS.NO;

    l_insert varchar2(1) ;		/*BUG 6134576*/
    l_service_item_flag varchar2(1) ;	/*BUG 6134576*/

    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);
    l_errMsg VARCHAR2(2000);

    cursor wfs_info_cursor(wipEntityId number) is
      select wip_entity_id,
             planned_quantity,
             nvl(quantity_completed,0) as quantity_completed,
             nvl(quantity_scrapped,0) as quantity_scrapped,
             (planned_quantity - nvl(quantity_completed,0) - nvl(quantity_scrapped,0)) as open_quantity
       from wip_flow_schedules wfs
      where wfs.wip_entity_id = wipEntityId
    ;

    cursor wip_entity_id_cursor(txn_header_id number) is
      select transaction_source_id
        from mtl_transactions_interface
       where transaction_header_id = txn_header_id
      and rownum < 2
    ;

    l_wfs_info wfs_info_cursor%ROWTYPE := null;
    l_wip_entity_id number := null;   -- use it to retrieve wip_flow_schedules info
  begin

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHeaderID';
      l_params(1).paramValue := p_txnHeaderID;
      l_params(2).paramName := 'p_parentID';
      l_params(2).paramValue := p_parentID;
      l_params(3).paramName := 'p_txnTypeID';
      l_params(3).paramValue := p_txnTypeID;
      l_params(4).paramName := 'p_assyID';
      l_params(4).paramValue := p_assyID;
      l_params(5).paramName := 'p_orgID';
      l_params(5).paramValue := p_orgID;
      l_params(6).paramName := 'p_qty';
      l_params(6).paramValue := p_qty;
      l_params(7).paramName := 'p_altBomDesig';
      l_params(7).paramValue := p_altBomDesig;
      l_params(8).paramName := 'p_altOption';
      l_params(8).paramValue := p_altOption;
      l_params(9).paramName := 'p_txnDate';
      l_params(9).paramValue := p_txnDate;
      l_params(10).paramName := 'p_projectID';
      l_params(10).paramValue := p_projectID;
      l_params(11).paramName := 'p_taskID';
      l_params(11).paramValue := p_taskID;
      l_params(12).paramName := 'p_toOpSeqNum';
      l_params(12).paramValue := p_toOpSeqNum;
      l_params(13).paramName := 'p_altRoutDesig';
      l_params(13).paramValue := p_altRoutDesig;
      l_params(14).paramName := 'p_txnMode';
      l_params(14).paramValue := p_txnMode;
      l_params(15).paramName := 'p_lockFlag';
      l_params(15).paramValue := p_lockFlag;
      l_params(16).paramName := 'p_txnSourceID';
      l_params(16).paramValue := p_txnSourceID;
      l_params(17).paramName := 'p_acctPeriodID';
      l_params(17).paramValue := p_acctPeriodID;
      l_params(18).paramName := 'p_cplTxnID';
      l_params(18).paramValue := p_cplTxnID;
      l_params(19).paramName := 'p_txnBatchID';
      l_params(19).paramValue := p_txnBatchID;
      l_params(20).paramName := 'p_txnBatchSeq';
      l_params(20).paramValue := p_txnBatchSeq;
      l_params(20).paramName := 'p_defaultPushSubinv';
      l_params(20).paramValue := p_defaultPushSubinv;
      wip_logger.entryPoint(p_procName => 'wip_flowutil_priv.explodeRequirementsToMTI',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    explodeRequirementsAndDefault(p_assyID => p_assyID,
                                  p_orgID => p_orgID,
                                  p_qty => p_qty,
                                  p_altBomDesig => p_altBomDesig,
                                  p_altOption => p_altOption,
                                  p_bomRevDate => p_bomRevDate, /* Fix for bug#3423629 */
                                  p_txnDate => p_txnDate,
				  p_implFlag => 1,
                                  p_projectID => p_projectID,
                                  p_taskID => p_taskID,
                                  p_toOpSeqNum => p_toOpSeqNum,
                                  p_altRoutDesig => p_altRoutDesig,
                                  p_txnFlag => true,  -- p_txnFlag, for bug 4538135 /* ER 4369064 */
                                  p_defaultPushSubinv => p_defaultPushSubinv, --bug#5262858
                                  x_compTbl => l_compTbl,
                                  x_returnStatus => x_returnStatus);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    l_insertPhantom := wip_globals.use_phantom_routings(p_orgID);

    -- bug 5605598
    -- p_txnSourceID could be null if it's processing records manually inserted into interface table
    l_wip_entity_id := p_txnSourceID;
    if (l_wip_entity_id is null) then
      for c_wip_entity_id in wip_entity_id_cursor(p_txnHeaderID) loop
        l_wip_entity_id := c_wip_entity_id.transaction_source_id;
      end loop;
    end if;
    -- fetch flow schedule's information into wfs_info
    for c_wfs_info in wfs_info_cursor(l_wip_entity_id) loop
      l_wfs_info := c_wfs_info;
    end loop;

    l_count := l_compTbl.first;
    while ( l_count is not null ) loop
  /* Fix for #6134576 If the item is a non-transactable, service-item, no backflushing
  will take place for them. No records are inserted in MTI for service items        */

         l_insert := 'Y' ;
         l_service_item_flag := 'N' ;

         select service_item_flag
         into   l_service_item_flag
         from   mtl_system_items
         where  inventory_item_id = l_compTbl(l_count).inventory_item_id
         and    organization_id = p_orgid ;

     -- bug 5630078
      -- we dont insert any component that is not transaction_enabled
      if ((nvl(l_compTbl(l_count).wip_supply_type, -1) <> 6) and
          (l_compTbl(l_count).mtl_transactions_enabled_flag <> 'Y') and
	  (l_service_item_flag = 'Y') ) then
        x_nontxn_excluded := 'Y';
        l_insert := 'N' ; /* 6134576 */
            /* 6134576. Removed following goto and control it by
               l_insert in following if statement
            */
           /* goto MtiInsertLoop; */

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
          -- skip the component it it's not the 1st complete/scrap or the last return/return-from-scrap
          goto MtiInsertLoop;
        end if;
      end if;

      -- we don't insert phantom comp(for phantom routing resource charging) into mti if
      -- the bom parameter is set to NO.
      if (( l_insertPhantom = WIP_CONSTANTS.YES or
           nvl(l_compTbl(l_count).wip_supply_type, 1) <> 6) and l_insert = 'Y' ) then  /*Bug 6134576*/
        -- derive the txn type and action id
        l_childTxnActionID := l_compTbl(l_count).transaction_action_id;
        l_childTxnTypeID := getTypeFromAction(l_childTxnActionID);

        -- if it is phantom, we insert it with negative op seq num
        insert into mtl_transactions_interface(
          transaction_header_id,
          transaction_interface_id,
          transaction_mode,
          parent_id,
          source_code,
          source_line_id,
          source_header_id,
          inventory_item_id,
          revision,
          organization_id,
          transaction_source_id,
          operation_seq_num,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          process_flag,
          lock_flag,
          validation_required,
          transaction_date,
          transaction_quantity,
          transaction_uom,
          primary_quantity,
          transaction_source_type_id,
          flow_schedule,
          transaction_action_id,
          transaction_type_id,
          wip_supply_type,
          wip_entity_type,
          subinventory_code,
          locator_id,
          acct_period_id,
          completion_transaction_id,
          transaction_batch_id,
          transaction_batch_seq,
          project_id,
          task_id,
          source_project_id,
          source_task_id)
        values
         (p_txnHeaderID,
          mtl_material_transactions_s.nextval,
          p_txnMode,
          p_parentID,
          'Backflush',
          1,
          1,
          l_compTbl(l_count).inventory_item_id,
          l_compTbl(l_count).revision,
          p_orgID,
          p_txnSourceID,
          decode(l_compTbl(l_count).wip_supply_type,
                 6, -1*l_compTbl(l_count).operation_seq_num,
                 l_compTbl(l_count).operation_seq_num),
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id,
          fnd_global.conc_request_id,
          fnd_global.prog_appl_id,
          fnd_global.conc_program_id,
          sysdate,
          1, -- process flag
          p_lockFlag,
          1, -- validation required
          p_txnDate,
          ROUND(l_compTbl(l_count).primary_quantity * -1, WIP_CONSTANTS.INV_MAX_PRECISION),
          l_compTbl(l_count).primary_uom_code,
          ROUND(l_compTbl(l_count).primary_quantity * -1, WIP_CONSTANTS.INV_MAX_PRECISION),
          5,
          'Y',
          l_childTxnActionID,
          l_childTxnTypeID,
          l_compTbl(l_count).wip_supply_type,
          wip_constants.flow,
          l_compTbl(l_count).supply_subinventory,
          l_compTbl(l_count).supply_locator_id,
          p_acctPeriodID,
          p_cplTxnID,
          p_txnBatchID,
          p_txnBatchSeq,
          l_compTbl(l_count).project_id,
          l_compTbl(l_count).task_id,
          p_projectID,
          p_taskID);

        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log(p_msg => 'Insert item ' || l_compTbl(l_count).inventory_item_id ||
                                  ' under op ' || l_compTbl(l_count).operation_seq_num,
                         x_returnStatus => l_returnStatus);
        end if;
      end if;

      <<MtiInsertLoop>>
      l_count := l_compTbl.next(l_count);
    end loop;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_flowutil_priv.explodeRequirementsToMTI',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Explode BOM to MTI successfully for interface ' ||
                                    to_char(p_parentID) || ' successfully!',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
  when fnd_api.g_exc_unexpected_error then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;

    wip_utilities.get_message_stack(p_msg => l_errMsg,
                                    p_delete_stack => fnd_api.g_false);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_flowutil_priv.explodeRequirementsToMTI',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'explosion error: ' || l_errMsg || ' for exploding interface '
                                    || to_char(p_parentID),
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;

    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_errMsg);
    wip_mti_pub.setMtiError(p_parentID,
                            null,
                            substrb(fnd_message.get, 1, 240));

  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if (l_logLevel <= wip_constants.trace_logging) then

      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_flowutil_priv',
                              p_procedure_name => 'explodeRequirementsToMTI',
                              p_error_text => SQLERRM);

      wip_logger.exitPoint(p_procName => 'wip_flowutil_priv.explodeRequirementsToMTI',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'unexpected error: ' || l_errMsg || ' for exploding interface '
                                    || to_char(p_parentID),
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
    fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_BKFLUSH');
    fnd_message.set_token('ENTITY1', p_parentID);
    wip_mti_pub.setMtiError(p_parentID,
                            null,
                            substrb(fnd_message.get, 1, 240));
  end explodeRequirementsToMTI;


  /**
   * This function merge the substitution records to backflush records. It also sets
   * transaction action id, etc. to the right value.
   */
  procedure mergeComponents(p_parentID     in  number,
                            x_returnStatus out NOCOPY varchar2) is
    cursor subs_c is
      select transaction_interface_id,
             substitution_type_id,
             operation_seq_num,
             organization_id,
             inventory_item_id,
             substitution_item_id,
             transaction_uom,
             subinventory_code,
             locator_id
        from mtl_transactions_interface
       where parent_id = p_parentID
         and process_flag = 1
         and substitution_type_id is not null
    order by substitution_type_id;

    cursor bf_c(p_opSeq  number,
                p_orgID  number,
                p_itemID number) is
      select transaction_interface_id
        from mtl_transactions_interface
       where parent_id = p_parentID
         and process_flag = 1
         and substitution_type_id is null
         and operation_seq_num = p_opSeq
         and organization_id = p_orgID
         and inventory_item_id = p_itemID;

    l_bfInterfaceID number;
    l_primaryUOM varchar2(3);

    l_txnActionID number;
    l_srcProjID number := null;
    l_srcTaskID number := null;
    l_txnDate date;
    l_wipEntityID number := null;

    merge_exception exception;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;

    for subs_rec in subs_c loop
      if ( subs_rec.substitution_type_id = 1 ) then
        ------------- Replacement ----------------------
        -- 1. Op seq and item exists, replace the item
        -- 2. Op seq doesn't exist or item doesn't exist, error out
        ------------------------------------------------
        open bf_c(subs_rec.operation_seq_num,
                  subs_rec.organization_id,
                  subs_rec.inventory_item_id);
        fetch bf_c into l_bfInterfaceID;

        if ( bf_c%FOUND) then
          -- if found, then delete the bf record and set substitute record right
          delete from mtl_transactions_interface
          where transaction_interface_id = l_bfInterfaceID;

          -- we don't need to worry transaction qty, uom, type, etc. since those
          -- are not null columns and don't have to be the same as the backflush record
          -- we also don't need to worry about lot/serial since those info should go
          -- with the substitution record
          update mtl_transactions_interface
             set inventory_item_id = subs_rec.substitution_item_id,
                 substitution_item_id = null,
                 substitution_type_id = null
           where transaction_interface_id = subs_rec.transaction_interface_id;

          close bf_c;
        else
          close bf_c;
          fnd_message.set_name('WIP', 'WIP_ERROR_MERGE_REPLACE');
          fnd_message.set_token('ENTITY1', to_char(subs_rec.operation_seq_num));
          raise merge_exception;
        end if;

      elsif ( subs_rec.substitution_type_id = 2 ) then
        --------------- Delete --------------------------
        -- 1. Op seq and item exist, delete the item
        -- 2. Op seq doesn't exist or item doesn't exist, error out
        -------------------------------------------------
        open bf_c(subs_rec.operation_seq_num,
                  subs_rec.organization_id,
                  subs_rec.inventory_item_id);
        fetch bf_c into l_bfInterfaceID;

        if ( bf_c%FOUND) then
          -- if found, then delete the bf record
          delete from mtl_transactions_interface
          where transaction_interface_id = l_bfInterfaceID;

          -- delete the substitution record as well
          delete from mtl_transactions_interface
          where transaction_interface_id = subs_rec.transaction_interface_id;

          close bf_c;
        else
          close bf_c;
          fnd_message.set_name('WIP', 'WIP_ERROR_MERGE_DELETE');
          fnd_message.set_token('ENTITY1', to_char(subs_rec.operation_seq_num));
          raise merge_exception;
        end if;

      elsif ( subs_rec.substitution_type_id = 3 ) then
        ----------------- Add --------------------------------
        -- Op seq exist, then add it
        -- If not exist, we will just let go trough, as decided on the meeting.
        -- We don't merge the additions into one transaction. They have to be in
        -- the same UOM, transaction action, etc. It's decided to have it as 2
        -- separate txns(decided by jgu and dsoosai).
        update mtl_transactions_interface
           set substitution_type_id = null,
               inventory_item_id = subs_rec.substitution_item_id,
               substitution_item_id = null
         where transaction_interface_id = subs_rec.transaction_interface_id;

      elsif ( subs_rec.substitution_type_id = 4 ) then
        --------------- Lot/Serial -----------------------------
        -- 1. Op seq and item exist, replace the lot/serial association
        -- 2. Op seq doesn't exist or item doesn't exist, error out
        -- We will error it out if the substitution lot serial info is not in the
        -- primary UOM.
        ---------------------------------------------------------
        if ( wip_common.is_primary_uom(
                 p_item_id => subs_rec.inventory_item_id,
                 p_org_id => subs_rec.organization_id,
                 p_txn_uom => subs_rec.transaction_uom,
                 p_pri_uom => l_primaryUOM ) = 1 ) then

          open bf_c(subs_rec.operation_seq_num,
                    subs_rec.organization_id,
                    subs_rec.inventory_item_id);
          fetch bf_c into l_bfInterfaceID;

          if ( bf_c%FOUND) then
            -- if found, then delete the substitution record
            delete from mtl_transactions_interface
            where transaction_interface_id = subs_rec.transaction_interface_id;

            -- build the link and update the subinventory and locator id
            update mtl_transactions_interface
               set transaction_interface_id = subs_rec.transaction_interface_id,
                   subinventory_code = subs_rec.subinventory_code,
                   locator_id = subs_rec.locator_id
             where transaction_interface_id = l_bfInterfaceID;

            close bf_c;
          else
            close bf_c;
            fnd_message.set_name('WIP', 'WIP_ERROR_MERGE_LOT_SERIAL');
            fnd_message.set_token('ENTITY1', to_char(subs_rec.operation_seq_num));
            raise merge_exception;
          end if; -- end of bf_c%FOUND

        else
          fnd_message.set_name('WIP', 'WIP_ERROR_MERGE_LOT_UOM');
          fnd_message.set_token('ENTITY1', to_char(subs_rec.operation_seq_num));
          fnd_message.set_token('ENTITY2', subs_rec.transaction_uom);
          fnd_message.set_token('ENTITYY3', l_primaryUOM);
          raise merge_exception;
        end if;

      end if;
    end loop;

    -- update the txn date, etc.
    select transaction_source_id,
           transaction_date
      into l_wipEntityID,
           l_txnDate
      from mtl_transactions_interface
     where transaction_interface_id = p_parentID;

    if ( l_wipEntityID is not null ) then
      select project_id, task_id
        into l_srcProjID, l_srcTaskID
        from wip_flow_schedules
       where wip_entity_id = l_wipEntityID;
    end if;


    update mtl_transactions_interface
       set transaction_source_type_id = nvl(transaction_source_type_id, 5),
           flow_schedule = nvl(flow_schedule, 'Y'),
           source_project_id = l_srcProjID,
           source_task_id = l_srcTaskID,
           transaction_source_id = l_wipEntityID,
           wip_entity_type = decode(l_wipEntityID, null, null, 4),
           transaction_date = to_date(to_char(l_txnDate, WIP_CONSTANTS.DT_NOSEC_FMT), WIP_CONSTANTS.DT_NOSEC_FMT)
     where parent_id = p_parentID
       and process_flag = 1
       and substitution_type_id is null;

  exception
  when merge_exception then
    x_returnStatus := fnd_api.g_ret_sts_error;
    wip_mti_pub.setMtiError(p_parentID,
                            null,
                            substrb(fnd_message.get, 1, 240));
  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    wip_mti_pub.setMtiError(p_parentID,
                            null,
                            substrb('Error in merging: ' || SQLERRM, 1, 240));
  end mergeComponents;


  /**
   * Generate the issue locator for all the issues associated with a completion.
   * This is only applicable to a project related completions.
   * ????
   * Need to talk to PJM team to remove wip_entity_id from
   * PJM_Project_Locator.Get_Flow_ProjectSupply or provide an equivalent.
   */
  procedure generateIssueLocator(p_parentID     in  number,
                                 x_returnStatus out NOCOPY varchar2) is
    l_orgID number;
    l_wipEntityID number := null;
    l_srcProjID number := null;
    l_srcTaskID number := null;
    l_success number;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    null;
  end generateIssueLocator;

  /**
   * This procedure creates an entry in wip_flow_schedules and wip_entities for
   * unscheduled work orderless completion. Those entries are needed for the
   * following resource and material transactions.
   */
  procedure createFlowSchedule(p_txnInterfaceID    in  number := null,
                               p_txnTmpID          in  number := null,
                               x_returnStatus out nocopy varchar2,
                               x_wipEntityID  out nocopy number) is

    type flow_rec_t is record(transaction_action_id NUMBER,   -- CFM Scrap
             last_update_date DATE,
             last_updated_by NUMBER,
             creation_date DATE,
             created_by NUMBER,
             last_update_login NUMBER,
             request_id NUMBER,
             program_application_id NUMBER,
             program_id NUMBER,
             program_update_date DATE,
             organization_id NUMBER,
             inventory_item_id NUMBER,
             accounting_class VARCHAR2(10),
             transaction_date DATE,
             transaction_quantity NUMBER,   -- we have to get the primary qty
             transaction_uom VARCHAR2(3),
             primary_quantity NUMBER,
             transaction_source_id NUMBER,
             transaction_source_name VARCHAR2(240),
             revision VARCHAR2(3),
             bom_revision VARCHAR2(3),
             routing_revision VARCHAR2(3),
             bom_revision_date DATE,
             routing_revision_date DATE,
             alternate_bom_designator VARCHAR2(10),
             alternate_routing_designator VARCHAR2(10),
             subinventory_code VARCHAR2(10),
             locator_id NUMBER,
             demand_class VARCHAR2(30),
             schedule_group NUMBER,
             build_sequence NUMBER,
             repetitive_line_id NUMBER,
             source_project_id NUMBER,
             project_id NUMBER,
             source_task_id NUMBER,
             task_id NUMBER,
             schedule_number VARCHAR2(30),
             scheduled_flag NUMBER,
             wip_entity_type NUMBER,
             end_item_unit_number VARCHAR2(60),
             transaction_header_id NUMBER,
             completion_transaction_id NUMBER,
             row_id rowid);

    cursor c_MTIflowCompletion return flow_rec_t is
      select transaction_action_id,   -- CFM Scrap
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             organization_id,
             inventory_item_id,
             accounting_class,
             transaction_date,
             transaction_quantity,   -- we have to get the primary qty
             transaction_uom,
             primary_quantity,
             transaction_source_id,
             transaction_source_name,
             revision,
             bom_revision,
             routing_revision,
             bom_revision_date,
             routing_revision_date,
             alternate_bom_designator,
             alternate_routing_designator,
             subinventory_code,
             locator_id,
             demand_class,
             schedule_group,
             build_sequence,
             repetitive_line_id,
             source_project_id,
             project_id,
             source_task_id,
             task_id,
             schedule_number,
             scheduled_flag,
             wip_entity_type,
             end_item_unit_number,
             transaction_header_id,
             completion_transaction_id,
             rowid
        from mtl_transactions_interface
       where transaction_interface_id = p_txnInterfaceID
         and transaction_source_type_id = 5
         and transaction_source_id is null
         and flow_schedule = 'Y'
         and transaction_action_id in (31, 32, 30)  -- CFM Scrap
         and scheduled_flag = 2
         and process_flag = wip_constants.mti_inventory;

    cursor c_MMTTflowCompletion return flow_rec_t is
      select transaction_action_id,   -- CFM Scrap
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             organization_id,
             inventory_item_id,
             class_code,
             transaction_date,
             transaction_quantity,   -- we have to get the primary qty
             transaction_uom,
             primary_quantity,
             transaction_source_id,
             transaction_source_name,
             revision,
             bom_revision,
             routing_revision,
             bom_revision_date,
             routing_revision_date,
             alternate_bom_designator,
             alternate_routing_designator,
             subinventory_code,
             locator_id,
             demand_class,
             schedule_group,
             build_sequence,
             repetitive_line_id,
             source_project_id,
             project_id,
             source_task_id,
             task_id,
             schedule_number,
             scheduled_flag,
             wip_entity_type,
             end_item_unit_number,
             transaction_header_id,
             completion_transaction_id,
             rowid
        from mtl_material_transactions_temp
       where transaction_temp_id = p_txnTmpID
         and transaction_source_type_id = 5
         and transaction_source_id is null
         and flow_schedule = 'Y'
         and transaction_action_id in (31, 32, 30)  -- CFM Scrap
         and scheduled_flag = 2
         and process_flag = 'Y';

    l_primaryUOM varchar2(3);
    l_wipEntityID number;

    l_materialAccount number;
    l_materialOverheadAccount number;
    l_resourceAccount number;
    l_outsideProcessingAccount number;
    l_materialVarianceAccount number;
    l_resourceVarianceAccount number;
    l_outsideProcVarAccount number;
    l_stdCostAdjustmentAccount number;
    l_overheadAccount number;
    l_overheadVarianceAccount number ;

    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;

    l_prjID NUMBER;
    l_tskID NUMBER;

    l_flowRec flow_rec_t;

    cursor c_MTIparams is
      select transaction_source_type_id,
        transaction_source_id,
        flow_schedule,
        transaction_action_id,
        scheduled_flag,
        process_flag
        from mtl_transactions_interface
       where transaction_interface_id = p_txnInterfaceID;

    cursor c_MMTTparams is
      select transaction_source_type_id,
        transaction_source_id,
        flow_schedule,
        transaction_action_id,
        scheduled_flag,
        process_flag
        from mtl_transactions_interface
       where transaction_interface_id = p_txnInterfaceID;

  begin

    x_returnStatus := fnd_api.g_ret_sts_success;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnInterfaceID';
      l_params(1).paramValue := p_txnInterfaceID;
      wip_logger.entryPoint(p_procName => 'wip_flowUtil_priv.createFlowSchedule',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(l_logLevel <= wip_constants.full_logging) then
      declare
        l_count NUMBER;
      begin
        if(p_txnInterfaceID is not null) then
          select count(*)
            into l_count
            from mtl_transactions_interface
           where transaction_interface_id = p_txnInterfaceID;
          wip_logger.log('MTI rowcount is ' || l_count, l_returnStatus);

          for l_paramRec in c_MTIparams loop
            wip_logger.log('transaction_source_id:' || l_paramRec.transaction_source_id, l_returnStatus);
            wip_logger.log('flow_schedule:' || l_paramRec.flow_schedule, l_returnStatus);
            wip_logger.log('transaction_action_id:' || l_paramRec.transaction_action_id, l_returnStatus);
            wip_logger.log('scheduled_flag:' || l_paramRec.scheduled_flag, l_returnStatus);
            wip_logger.log('process_flag:' || l_paramRec.process_flag, l_returnStatus);
          end loop;
        else
          select count(*)
            into l_count
            from mtl_material_transactions_temp
           where transaction_temp_id = p_txnTmpID;
          wip_logger.log('MMTT rowcount is ' || l_count, l_returnStatus);

          for l_paramRec in c_MMTTparams loop
            wip_logger.log('transaction_source_id:' || l_paramRec.transaction_source_id, l_returnStatus);
            wip_logger.log('flow_schedule:' || l_paramRec.flow_schedule, l_returnStatus);
            wip_logger.log('transaction_action_id:' || l_paramRec.transaction_action_id, l_returnStatus);
            wip_logger.log('scheduled_flag:' || l_paramRec.scheduled_flag, l_returnStatus);
            wip_logger.log('process_flag:' || l_paramRec.process_flag, l_returnStatus);
          end loop;
        end if;
      end;
    end if;

    if(p_txnInterfaceID is not null) then
      open c_MTIflowCompletion;
      fetch c_MTIflowCompletion into l_flowRec;
      close c_MTIflowCompletion;
    else
      open c_MMTTflowCompletion;
      fetch c_MMTTflowCompletion into l_flowRec;
      close c_MMTTflowCompletion;
    end if;

    if(l_flowRec.organization_id is null) then --org id column is not null in both MTI and MMTT
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_flowUtil_priv.createFlowSchedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'Flow schedule creation not necessary.',
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      x_returnStatus := fnd_api.g_ret_sts_success;
      return;
    end if;

    l_flowRec.wip_entity_type := 4 ; -- Set it to Flow Schedule

    -- get the primary txn quantity
    select primary_uom_code
      into l_primaryUOM
      from mtl_system_items
     where inventory_item_id = l_flowRec.inventory_item_id
       and organization_id = l_flowRec.organization_id;

    if( l_primaryUOM <> l_flowRec.transaction_uom ) then
        l_flowRec.primary_quantity :=
                 inv_convert.inv_um_convert(
                       item_id => l_flowRec.inventory_item_id,
                       precision => NULL,
                       from_quantity => l_flowRec.transaction_quantity,
                       from_unit => l_flowRec.transaction_uom,
                       to_unit => l_primaryUOM,
                       from_name => NULL,
                       to_name => NULL) ;
      else
        l_flowRec.primary_quantity := l_flowRec.transaction_quantity;
      end if;

      -- now getting the wip_entity_id and the account info
      select wip_entities_s.nextval into l_wipEntityID from dual;

      select material_account,
             material_overhead_account,
             resource_account,
             outside_processing_account,
             material_variance_account,
             resource_variance_account,
             outside_proc_variance_account,
             std_cost_adjustment_account,
             overhead_account,
             overhead_variance_account
        into l_materialAccount,
             l_materialOverheadAccount,
             l_resourceAccount,
             l_outsideProcessingAccount,
             l_materialVarianceAccount,
             l_resourceVarianceAccount,
             l_outsideProcVarAccount,
             l_stdCostAdjustmentAccount,
             l_overheadAccount,
             l_overheadVarianceAccount
        from wip_accounting_classes
       where class_code = l_flowRec.accounting_class
         and organization_id = l_flowRec.organization_id;

      -- we do NOT need to insert an entry in wip_entities since there is a database
      -- trigger on wfs to do that
      insert into wip_flow_schedules(
          wip_entity_id,
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
          primary_item_id,
          class_code,
          scheduled_start_date,
          date_closed,
          planned_quantity,
          quantity_completed,
          quantity_scrapped,
          mps_scheduled_completion_date,
          mps_net_quantity,
          bom_revision,
          routing_revision,
          bom_revision_date,
          routing_revision_date,
          alternate_bom_designator,
          alternate_routing_designator,
          completion_subinventory,
          completion_locator_id,
          material_account,
          material_overhead_account,
          resource_account,
          outside_processing_account,
          material_variance_account,
          resource_variance_account,
          outside_proc_variance_account,
          std_cost_adjustment_account,
          overhead_account,
          overhead_variance_account,
          demand_class,
          scheduled_completion_date,
          schedule_group_id,
          build_sequence,
          line_id,
          project_id,
          task_id,
          status,
          schedule_number,
          scheduled_flag,
          end_item_unit_number,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15)
      values(
          l_wipEntityID,
          l_flowRec.organization_id,
          l_flowRec.last_update_date,
          l_flowRec.last_updated_by,
          l_flowRec.creation_date,
          l_flowRec.created_by,
          l_flowRec.last_update_login,
          l_flowRec.request_id,
          l_flowRec.program_application_id,
          l_flowRec.program_id,
          l_flowRec.program_update_date,
          l_flowRec.inventory_item_id,
          l_flowRec.accounting_class,
          l_flowRec.transaction_date,
          NULL,
          0,
          0,
          0,
          NULL,
          NULL,
          l_flowRec.bom_revision,
          l_flowRec.routing_revision,
          l_flowRec.bom_revision_date,
          l_flowRec.routing_revision_date,
          l_flowRec.alternate_bom_designator,
          l_flowRec.alternate_routing_designator,
          l_flowRec.subinventory_code,
          l_flowRec.locator_id,
          l_materialAccount,
          l_materialOverheadAccount,
          l_resourceAccount,
          l_outsideProcessingAccount,
          l_materialVarianceAccount,
          l_resourceVarianceAccount,
          l_outsideProcVarAccount,
          l_stdCostAdjustmentAccount,
          l_overheadAccount,
          l_overheadVarianceAccount,
          l_flowRec.demand_class,
          l_flowRec.transaction_date,
          l_flowRec.schedule_group,
          l_flowRec.build_sequence,
          l_flowRec.repetitive_line_id,
             --technically, the user should populate the source prj/tsk columns, but also
             --accept prj/tsk columns
          nvl(l_flowRec.source_project_id, l_flowRec.project_id),
          decode(l_flowRec.source_project_id, null, l_flowRec.task_id, l_flowRec.source_task_id),
          1,                      -- 1. Open, 2. Close
          l_flowRec.schedule_number,
          2,                      -- Unscheduled
          l_flowRec.end_item_unit_number,  -- end item unit number
          NULL,
          NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL
      ) returning project_id, task_id into l_prjID, l_tskID;

      x_wipEntityID := l_wipEntityID;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(p_msg => 'wip entity id: ' || x_wipEntityID,
                       x_returnStatus => l_returnStatus);
        wip_logger.log(p_msg => 'src prjID: ' || l_flowRec.source_project_id,
                       x_returnStatus => l_returnStatus);
        wip_logger.log(p_msg => 'projID: ' || l_flowRec.project_id,
                       x_returnStatus => l_returnStatus);
        wip_logger.log(p_msg => 'prjID: ' || l_prjID,
                       x_returnStatus => l_returnStatus);
        wip_logger.log(p_msg => 'tskID:' || l_tskID,
                       x_returnStatus => l_returnStatus);
        wip_logger.log(p_msg => 'Flow schedule ' || l_wipEntityID || ' was created!',
                       x_returnStatus => l_returnStatus);
      end if;

    -- set the transaction_source_id for the assembly record (if from MTI)
    --and its components
    update mtl_transactions_interface
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           transaction_source_id = l_wipEntityID,
           wip_entity_type = l_flowRec.wip_entity_type
     where transaction_header_id = l_flowRec.transaction_header_id
       and completion_transaction_id = l_flowRec.completion_transaction_id;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log(p_msg => SQL%ROWCOUNT || 'MTI rows updated!',
                     x_returnStatus => l_returnStatus);
    end if;

    --if txn originated from MMTT, update the assy record
    if(p_txnTmpID is not null) then
            update mtl_material_transactions_temp
         set last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id = fnd_global.conc_program_id,
             program_update_date = sysdate,
             request_id = fnd_global.conc_request_id,
             transaction_source_id = l_wipEntityID,
             wip_entity_type = l_flowRec.wip_entity_type
       where transaction_temp_id = p_txnTmpID;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log(p_msg => SQL%ROWCOUNT || 'MMTT rows updated!',
                     x_returnStatus => l_returnStatus);
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_flowUtil_priv.createFlowSchedule',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Flow schedules created successfully!',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_flowUtil_priv.createFlowSchedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;

      fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_CREATION');
      fnd_message.set_token('ENTITY1',to_char(p_txnInterfaceID));
      fnd_msg_pub.add;
  end createFlowSchedule;


  /**
   * This procedure performs the update to wip flow schedule.
   */
  procedure updateFlowSchedule(p_txnTempID    in  number,
                               x_returnStatus out nocopy varchar2) is
    l_wipEntityID number;
    l_transactionDate date;
    l_cplQty number;
    l_scrapQty number;
    l_flowSchedule varchar(1) := 'N';
    l_statusChange number := 0;
    l_completedQty number;
    l_plannedQty number;
    l_newCompletedQty number;

    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnTempID';
      l_params(1).paramValue := p_txnTempID;
      wip_logger.entryPoint(p_procName => 'wip_flowUtil_priv.updateFlowSchedule',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

  /*
    select distinct
             transaction_source_id,
             decode(transaction_action_id, 30, 0, primary_quantity),
             decode(transaction_action_id, 30, primary_quantity, 0),-- CFM Scrap
             transaction_date,
             flow_schedule
      into l_wipEntityID,
           l_cplQty,
           l_scrapQty,
           l_transactionDate,
           l_flowSchedule
      from mtl_material_transactions
     where transaction_set_id = p_txnHeaderID
       and transaction_action_id in (30, 31, 32);
   */

   select transaction_source_id,
          decode(transaction_action_id, 30, 0, primary_quantity),
          decode(transaction_action_id, 30, primary_quantity, 0),-- CFM Scrap
          transaction_date,
          flow_schedule
     into l_wipEntityID,
          l_cplQty,
          l_scrapQty,
          l_transactionDate,
          l_flowSchedule
     from mtl_material_transactions_temp
    where transaction_temp_id = p_txnTempID;

    select planned_quantity,
           quantity_completed
      into l_plannedQty,
           l_completedQty
      from wip_flow_schedules
     where wip_entity_id = l_wipEntityID;

    -- status change
    -- 0: no change, 1: reopen the schedule, 2: close the schedule
    l_statusChange := 0;
    l_newCompletedQty := l_completedQty + l_cplQty;

    if ( l_newCompletedQty >= l_plannedQty ) then
      if ( l_completedQty <= l_plannedQty ) then
        l_statusChange := 2;
      end if;
    else
      if ( l_completedQty >= l_plannedQty ) then
        l_statusChange := 1;
      end if;
    end if;

    update wip_flow_schedules
       set quantity_completed = nvl(quantity_completed, 0) + l_cplQty,
           quantity_scrapped = nvl(quantity_scrapped, 0) + l_scrapQty,
           transacted_flag = 'Y',
           date_closed = decode(upper(nvl(l_flowSchedule, 'N')),
                                'Y',
                                decode(l_statusChange, 0, date_closed,
                                                       1, null,
                                                       2, l_transactionDate),
                                date_closed),
           status = decode(upper(nvl(l_flowSchedule, 'N')),
                           'Y',
                           decode(l_statusChange, 0, status,
                                                  1, 1,
                                                  2, 2),
                           status),
           last_updated_by = FND_GLOBAL.user_id,--bugfix 7379879
           last_update_date = sysdate
      where wip_entity_id = l_wipEntityID;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_flowUtil_priv.updateFlowSchedule',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Flow schedules updated successfully!',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_flowUtil_priv.updateFlowSchedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;

      fnd_message.set_name('WIP', 'WIP_UPDATE_WFS_ERROR');
      fnd_msg_pub.add;
  end updateFlowSchedule;

  /**
   * This procedure sets the error status to the mmtt. It sets the error
   * for the given temp id as well as the child records.
   */
  procedure setMmttError(p_txnTempID in number,
                         p_msgData   in varchar2) is
  begin
    update mtl_material_transactions_temp
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 'E',
           lock_flag = 2,
           error_code = substrb(p_msgData, 1, 240),
           error_explanation = substrb(p_msgData, 1, 240)
     where transaction_temp_id = p_txnTempID
        or completion_transaction_id =
              (select completion_transaction_id
                 from mtl_material_transactions_temp
                where transaction_temp_id = p_txnTempID);
  end setMmttError;


  /**
   * This procedure explodes the BOM for the given assemble and do the default of
   * subinventory and locator. It will find the components up to the toOpSeqNum.
   * If the supply subinv and locator in the BOM is not provided, then it will try
   * to default those the rule: BOM level --> item level --> wip parameter
   *
   * ER 4369064: This API is called from both Flow and WIP. If called from Flow, we
   * need to   1) Validate transaction flag for components
   *           2) Include / exclude component yield based on WIP Parameter
   * Calling program should pass 'TRUE' through the parameter p_tcnFlag if the above
   * two tasks are applicable, and 'FALSE' if not.
   */
  procedure explodeRequirementsAndDefault(p_assyID          in  number,
                                          p_orgID           in  number,
                                          p_qty             in  number,
                                          p_altBomDesig     in  varchar2,
                                          p_altOption       in  number,
            /* Fix for bug#3423629 */     p_bomRevDate      in  date default NULL,
                                          p_txnDate         in  date,
	    /* Fix for bug 5383135 */     p_implFlag        in  number,
                                          p_projectID       in  number,
                                          p_taskID          in  number,
                                          p_toOpSeqNum      in  number,
                                          p_altRoutDesig    in  varchar2,
            /* Fix for bug#4538135 */     p_txnFlag         in boolean default true,
            /* Fix for bug#5262858 */     p_defaultPushSubinv in varchar2 default null,
	    /* added for bug 5332615 */   p_unitNumber  in varchar2 DEFAULT '',
                                          x_compTbl         out nocopy system.wip_component_tbl_t,
                                          x_returnStatus    out nocopy varchar2) is
    l_numOfComp number;
    l_count number := 1;
    l_returnStatus varchar2(1);

    l_msiSubinv varchar2(10);
    l_msiLocatorID number;
    l_wpSubinv varchar2(10);
    l_wpLocatorID number;

    l_cfmRouting number;
    l_commonRoutSeqID number;
    l_checkPass boolean;
    l_lineOpTbl bom_rtg_network_api.op_tbl_type;
    l_constructed boolean := false;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_success boolean;
    l_locatorID number := null;

    l_includeYield NUMBER; /*Component Yield Enhancement(Bug 4369064)*/
    l_service_item_flag varchar2(1); 	/*Bug 6134576*/
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;

    wip_bflProc_priv.explodeRequirements(p_itemID => p_assyID,
                                         p_orgID => p_orgID,
                                         p_qty => p_qty,
                                         p_altBomDesig => p_altBomDesig,
                                         p_altOption => p_altOption,
                                         p_bomRevDate => p_bomRevDate, /* Fix for 3423629*/
                                         p_txnDate => p_txnDate,
					 p_implFlag => p_implFlag,
                                         p_projectID => p_projectID,
                                         p_taskID => p_taskID,
					 p_unitNumber => p_unitNumber, /* added for bug 5332615 */
                                         p_initMsgList => fnd_api.g_false,
                                         p_endDebug => fnd_api.g_true,
                                         x_compTbl => x_compTbl,
                                         x_returnStatus => x_returnStatus);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      return;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log(p_msg => x_compTbl.count || ' components exploded!',
                     x_returnStatus => l_returnStatus);
    end if;

    -- get the routing type
    begin
      select common_routing_sequence_id,
             nvl(cfm_routing_flag, 2)
        into l_commonRoutSeqID,
             l_cfmRouting
        from bom_operational_routings
       where organization_id = p_orgID
         and assembly_item_id = p_assyID
         and nvl(alternate_routing_designator, 'NONE') =
             nvl(p_altRoutDesig, 'NONE');
    exception
    when others then
      l_cfmRouting := -2;
    end;

    -- ER 4369064: Get the 'Include yield' setting from WIP Parameters
    if (p_txnFlag) then
      select nvl(include_component_yield,1)
      into   l_includeYield
      from   wip_parameters
      where  organization_id = p_orgID;
    end if;

    l_numOfComp := x_compTbl.count;
    while ( l_count <= l_numOfComp ) loop

      -- ER 4369064: For work orderless txn, we have to include yield factor
      -- if Include Yield in WIP Parameters is checked.
      -- Rounding this to 5 decimals since this will go into MTI
      /* Bug fix 4728358: Number of rounding decimal places should be obtained from WIP_CONSTANTS.
         In particular we want 6 places instead of 5. */
      if (p_txnFlag AND l_includeYield = 1) then
         x_compTbl(l_count).primary_quantity :=  round(x_compTbl(l_count).primary_quantity
                                                 / x_compTbl(l_count).component_yield_factor, WIP_CONSTANTS.INV_MAX_PRECISION);
      /* End of bug fix 4728358 */
      end if;

      if (round(abs(x_compTbl(l_count).primary_quantity),
                WIP_CONSTANTS.INV_MAX_PRECISION) = 0) then
        if(p_txnFlag) then
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log(p_msg => 'Qty too small, component ' ||
                                    x_compTbl(l_count).inventory_item_id || ' stripped!',
                           x_returnStatus => l_returnStatus);
          end if;
          x_compTbl.delete(l_count);
--        end if;
        l_checkPass := false;
	else
	--bug 8327926 (FP 8275269): setting l_checkPass to true in case of job creation with 0 primary_quantity
	--this will let supply subinventory be populated for this component from Item Master, if its
 	--already not done from BOM
	  l_checkPass := true;
	end if;
      elsif ( l_cfmRouting = -2 ) then
        -- the assy doesn't have a routing, we backflush everything
        l_checkPass := true;
      else
        -- according to the meeting on 02/15/2002, as decided by Richard, Jung and
        -- Barry, even though the operation is disabled, we still should backflush
        -- the material needed at that operation. So here I am not checking the
        -- operation effectivity/disable date.
        if ( p_toOpSeqNum is null ) then
          -- we backflush all the material if terminal op seq is not provided
          l_checkPass := true;
        elsif ( l_cfmRouting <> 1 ) then
          if ( x_compTbl(l_count).operation_seq_num > p_toOpSeqNum ) then
            -- delete the comp that has op seq greater than to op seq num
            if (l_logLevel <= wip_constants.full_logging) then
              wip_logger.log(p_msg => 'Op ' || x_compTbl(l_count).operation_seq_num ||
                                      ' after terminal op, item ' ||
                                      x_compTbl(l_count).inventory_item_id || ' stripped!',
                             x_returnStatus => l_returnStatus);
            end if;
            x_compTbl.delete(l_count);
            l_checkPass := false;
          else
            l_checkPass := true;
          end if;
        else
          -- it is cfm routing, what we get in op seq num is the event number,
          -- we need to check whether the line op this event belongs to is before
          -- or the same as the one provided or not.
          if ( not l_constructed ) then
            constructWipLineOps(p_routingSeqID => l_commonRoutSeqID,
                                p_assyItemID => null,
                                p_orgID => null,
                                p_altRoutDesig => null,
                                p_terminalOpSeqNum => p_toOpSeqNum,
                                x_lineOpTbl => l_lineOpTbl);
            l_constructed := true;
          end if;
          if ( eventInPriorSameLineOp(l_commonRoutSeqID,
                                      x_compTbl(l_count).operation_seq_num,
                                      p_toOpSeqNum,
                                      l_lineOpTbl) ) then
            l_checkPass := true;
          else
            if (l_logLevel <= wip_constants.full_logging) then
              wip_logger.log(p_msg => 'Event ' || x_compTbl(l_count).operation_seq_num ||
                                  ' belongs to line op that after terminal op, item ' ||
                                  x_compTbl(l_count).inventory_item_id || ' stripped!',
                             x_returnStatus => l_returnStatus);
            end if;
            x_compTbl.delete(l_count);
            l_checkPass := false;
          end if;
        end if;
      end if; -- end of l_cfmRouting = -2

      -- for work orderless txn, we don't backflush 'Bulk' components. We only
      -- backflush operation pull, assembly pull and push components.
      -- for phantom, we insert them into mmtt with negative op seq num
      -- ER 4369064: This code is called for discrete jobs too. Bulk and Supplier
      -- type components should be exploded for discrete jobs.
      if ( l_checkPass and p_txnFlag and
           nvl(x_compTbl(l_count).wip_supply_type, 1) not in (1, 2, 3, 6) ) then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log(p_msg => 'Nonrelated supply type item ' ||
                                  x_compTbl(l_count).inventory_item_id ||
                                  ' at op ' || x_compTbl(l_count).operation_seq_num ||
                                  ' stripped!',
                         x_returnStatus => l_returnStatus);
        end if;
        x_compTbl.delete(l_count);
        l_checkPass := false;
      end if;

      -- here, we should NOT set the supply subinv/locator for phantom,
      -- however, since inv's validation logic validates the whole phantom record, if will fail
      -- if we don't default the subinv/locator.
      -- for next release, we should revert this logic back and have inv skip the record for phantom.
      -- if ( l_checkPass and nvl(x_compTbl(l_count).wip_supply_type, -1) <> 6 ) then
      if ( l_checkPass ) then
          /* Fix for Bug#6134576. Let non transactable service item go through */

           l_service_item_flag := 'Y' ;

           select msi.service_item_flag
           into   l_service_item_flag
           from   mtl_system_items msi
           where  msi.inventory_item_id = x_compTbl(l_count).inventory_item_id
           and    msi.organization_id = p_orgID ;

           if l_service_item_flag = 'N' then
                if ( nvl(x_compTbl(l_count).wip_supply_type, -1) <> 6 and
                         x_compTbl(l_count).mtl_transactions_enabled_flag <> 'Y' and
                         p_txnFlag) then  --Bug4538135.Don't check this while creating job
				x_returnStatus := fnd_api.g_ret_sts_error;
				fnd_message.set_name('WIP', 'WIP_COMP_NOT_TRANSACTABLE');
				fnd_message.set_token('ENTITY1', x_compTbl(l_count).item_name);
				fnd_msg_pub.add;
				if (l_logLevel <= wip_constants.full_logging) then
					wip_logger.log(p_msg => 'Item ' || x_compTbl(l_count).inventory_item_id ||
							' not transactable, failed explosion!',
							x_returnStatus => l_returnStatus);
				end if;
				x_compTbl.delete;
				return;
		end if;
	    end if;
        l_locatorID := null;  /* reset locatorID */
        if ( x_compTbl(l_count).supply_subinventory is null) then
          select msi.wip_supply_subinventory,
                 msi.wip_supply_locator_id,
                 wp.default_pull_supply_subinv,
                 wp.default_pull_supply_locator_id
            into l_msiSubinv,
                 l_msiLocatorID,
                 l_wpSubinv,
                 l_wpLocatorID
            from mtl_system_items msi,
                 wip_parameters wp
           where msi.organization_id = wp.organization_id
             and msi.organization_id = p_orgID
             and msi.inventory_item_id = x_compTbl(l_count).inventory_item_id;
	/* Bugfix 4556685: Locator ID and supply subinventory at parameter and item levels
	   should be checked together. */
           if ( l_msiSubinv is not null ) then
             x_compTbl(l_count).supply_subinventory := l_msiSubinv;
             l_locatorID := l_msiLocatorID;
	     /* for bug 5057025. Do not default supply info for push components */
             /* for bug 5262858, we should default supply info for wol/flow txn */
           else
             if(nvl(p_defaultPushSubinv, 'N') = 'Y') then --This is wol/flow txn
               x_compTbl(l_count).supply_subinventory := l_wpSubinv;
               l_locatorID := l_wpLocatorID;
             else -- This is discrete txn
               if(x_compTbl(l_count).wip_supply_type in(wip_constants.op_pull, wip_constants.assy_pull)) then
	         x_compTbl(l_count).supply_subinventory := l_wpSubinv;
	         l_locatorID := l_wpLocatorID;
               end if;
             end if;
           end if;
        else
           if x_compTbl(l_count).supply_locator_id is not null then
             l_locatorID :=  x_compTbl(l_count).supply_locator_id;
           else
             l_locatorID := null;
           end if;
        end if;

	if(l_locatorID is not null) then
             l_success := pjm_project_locator.get_component_projectSupply(
                                p_organization_id => p_orgID,
                                p_project_id => x_compTbl(l_count).project_id,
                                p_task_id => x_compTbl(l_count).task_id,
                                p_wip_entity_id => null,--unused
                                p_supply_sub => x_compTbl(l_count).supply_subinventory,
                                p_supply_loc_id => l_locatorID,
                                p_item_id => x_compTbl(l_count).inventory_item_id,
                                p_org_loc_control => null); --unused
             x_compTbl(l_count).supply_locator_id := l_locatorID;
        end if;
	/* Fix for bug 5437157. Populate locator_name field as this will be displayed in
	   backflush region of self service flow txn pages */
	if(x_compTbl(l_count).supply_locator_id is not null and
	   x_compTbl(l_count).locator_name is null) then
	      select decode (mp.project_reference_enabled,
                             null,milk.concatenated_segments,
                             2,milk.concatenated_segments,
		             1, inv_project.get_pjm_locsegs(milk.concatenated_segments))
		     into x_compTbl(l_count).locator_name
		from mtl_parameters mp, mtl_item_locations_kfv milk
	       where mp.organization_id = p_orgID
	         and mp.organization_id = milk.organization_id
	         and milk.inventory_location_id = x_compTbl(l_count).supply_locator_id;
        end if;
	/* end of fix for bug 5437157 */
      end if; -- end of l_checkPass

      -- we need to increment the counter anyway even though the current element
      -- may be deleted since PL/SQL keeps placeholders for deleted elements.
      l_count := l_count + 1;
    end loop;
  end explodeRequirementsAndDefault;

  /**
   * This procedure explodes the BOM and insert the material requirement into
   * mmtt table under the given header id and completion txn id.
   * If the supply subinv and locator in the BOM is not provided, then it will try
   * to default those the rule: BOM level --> item level --> wip parameter
   */
  procedure explodeRequirementsToMMTT(p_txnTempID       in  number,
                                      p_assyID          in  number,
                                      p_orgID           in  number,
                                      p_qty             in  number,
                                      p_altBomDesig     in  varchar2,
                                      p_altOption       in  number,
                                      p_txnDate         in  date,
                                      p_projectID       in  number,
                                      p_taskID          in  number,
                                      p_toOpSeqNum      in  number,
                                      p_altRoutDesig    in  varchar2,
                                      x_returnStatus    out nocopy varchar2) is
    l_compTbl system.wip_component_tbl_t;
    l_count number;

    l_childTxnTypeID number;
    l_childTxnActionID number;
    l_insertPhantom number;
    l_acctPeriodID number;
    l_openPastPeriod boolean := false;

    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnTempID';
      l_params(1).paramValue := p_txnTempID;
      l_params(2).paramName := 'p_assyID';
      l_params(2).paramValue := p_assyID;
      l_params(3).paramName := 'p_orgID';
      l_params(3).paramValue := p_orgID;
      l_params(4).paramName := 'p_qty';
      l_params(4).paramValue := p_qty;
      l_params(5).paramName := 'p_altBomDesig';
      l_params(5).paramValue := p_altBomDesig;
      l_params(6).paramName := 'p_altOption';
      l_params(6).paramValue := p_altOption;
      l_params(7).paramName := 'p_txnDate';
      l_params(7).paramValue := p_txnDate;
      l_params(8).paramName := 'p_projectID';
      l_params(8).paramValue := p_projectID;
      l_params(9).paramName := 'p_taskID';
      l_params(9).paramValue := p_taskID;
      l_params(10).paramName := 'p_toOpSeqNum';
      l_params(10).paramValue := p_toOpSeqNum;
      l_params(11).paramName := 'p_altRoutDesig';
      l_params(11).paramValue := p_altRoutDesig;
      wip_logger.entryPoint(p_procName => 'wip_flowUtil_priv.explodeRequirementsToMMTT',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    invttmtx.tdatechk(org_id => p_orgID,
                      transaction_date => p_txnDate,
                      period_id => l_acctPeriodID,
                      open_past_period => l_openPastPeriod);
    if ( l_acctPeriodID is null ) then
      fnd_message.set_name('INV', 'INV_NO_OPEN_PERIOD');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    end if;

    explodeRequirementsAndDefault(p_assyID => p_assyID,
                                  p_orgID  => p_orgID,
                                  p_qty => p_qty,
                                  p_altBomDesig => p_altBomDesig,
                                  p_altOption => p_altOption,
                                  p_txnDate => p_txnDate,
				  p_implFlag => 1,
                                  p_projectID => p_projectID,
                                  p_taskID => p_taskID,
                                  p_toOpSeqNum => p_toOpSeqNum,
                                  p_altRoutDesig => p_altRoutDesig,
     /* fix for bug4538135 */     p_txnFlag => true, /* E 4369064 */
                                  x_compTbl => l_compTbl,
                                  x_returnStatus => x_returnStatus);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    l_insertPhantom := wip_globals.use_phantom_routings(p_orgID);

    l_count := l_compTbl.first;
    while ( l_count is not null ) loop
      -- we don't insert phantom comp(for phantom routing resource charging) into mmtt if
      -- the bom parameter is set to NO.
      if ( l_insertPhantom = WIP_CONSTANTS.YES or
           nvl(l_compTbl(l_count).wip_supply_type, 1) <> 6 ) then
        -- derive the txn action and type id
        l_childTxnActionID := l_compTbl(l_count).transaction_action_id;
        l_childTxnTypeID := getTypeFromAction(l_childTxnActionID);

        insert into mtl_material_transactions_temp(
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          transaction_header_id,
          transaction_temp_id,
          transaction_mode,
          transaction_source_id,
          transaction_source_type_id,
          transaction_type_id,
          transaction_action_id,
          transaction_date,
          transaction_quantity,
          transaction_uom,
          primary_quantity,
          parent_transaction_temp_id,
          wip_supply_type,
          wip_entity_type,
          inventory_item_id,
          revision,
          operation_seq_num,
          organization_id,
          source_code,
          process_flag,
          posting_flag,
          lock_flag,
          subinventory_code,
          locator_id,
          acct_period_id,
          completion_transaction_id,
          flow_schedule
        )
        select
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id,
          fnd_global.conc_request_id,
          fnd_global.prog_appl_id,
          fnd_global.conc_program_id,
          sysdate,
          mmtt.transaction_header_id,
          mtl_material_transactions_s.nextval,
          mmtt.transaction_mode,
          mmtt.transaction_source_id,
          5,
          l_childTxnTypeID,
          l_childTxnActionID,
          p_txnDate,
          l_compTbl(l_count).primary_quantity * -1,
          l_compTbl(l_count).primary_uom_code,
          l_compTbl(l_count).primary_quantity * -1,
          p_txnTempID, -- parent transaction temp id
          l_compTbl(l_count).wip_supply_type,
          mmtt.wip_entity_type,
          l_compTbl(l_count).inventory_item_id,
          l_compTbl(l_count).revision,
          decode(l_compTbl(l_count).wip_supply_type,
                 6, -1*l_compTbl(l_count).operation_seq_num,
                 l_compTbl(l_count).operation_seq_num),
          p_orgID,
          'WIP Flow Transcaction',
          'N',  -- default to No. call processLotSerialTemp() to update process flag
                -- and determine if unfulfilled l/s requirements exist
          'Y',
          2, -- lock flag
          l_compTbl(l_count).supply_subinventory,
          l_compTbl(l_count).supply_locator_id,
          l_acctPeriodID,
          mmtt.completion_transaction_id,
          'Y'
        from mtl_material_transactions_temp mmtt
        where mmtt.transaction_temp_id = p_txnTempID;

        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log(p_msg => 'Insert item ' || l_compTbl(l_count).inventory_item_id ||
                                  ' under op ' || l_compTbl(l_count).operation_seq_num,
                         x_returnStatus => l_returnStatus);
        end if;
      end if;

      l_count := l_compTbl.next(l_count);
    end loop;

    l_compTbl.delete;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_flowUtil_priv.explodeRequirementsToMMTT',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Exploded BOM to MMTT successfully!',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_flowUtil_priv.explodeRequirementsToMMTT',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;

  end explodeRequirementsToMMTT;


  /**
   * This procedure constructs the wip line ops table of records by calling
   * the appropriate BOM API.
   *
   * You must either privide the routing sequence id or
   * (assy id, orgid, alternate routing designator)
   * Line Op doesn't have any effective date, it is always in effect. So we
   * don't need to check it against the effectivity_date and disable_date. The event
   * does though.
   *
   * p_terminalOpSeqNum is greater than 0, it calls the BOM API to get all the
   *   line ops up to the terminal line op in the primary path of the routing network.
   * p_terminalOpSeqNum is -1, then all the line ops in the primary patch of the
   *   routing network are cached.
   * p_terminalOpSeqNum is -2, then all the line ops (except rework loops) in the
   *   routing network are cached.
   */
  procedure constructWipLineOps(p_routingSeqID     in  number,
                                p_assyItemID       in  number,
                                p_orgID            in  number,
                                p_altRoutDesig     in  varchar2,
                                p_terminalOpSeqNum in  number,
                                x_lineOpTbl        out nocopy bom_rtg_network_api.op_tbl_type) is
    l_opSeqID number;
    l_num number;
  begin
    x_lineOpTbl.delete;

    if ( p_terminalOpSeqNum > 0 ) then
      bom_rtg_network_api.get_primary_prior_line_ops(
             p_rtg_sequence_id => p_routingSeqID,
             p_assy_item_id => p_assyItemID,
             p_org_id => p_orgID,
             p_alt_rtg_desig => p_altRoutDesig,
             p_curr_line_op => p_terminalOpSeqNum,
             x_op_tbl => x_lineOpTbl);
      -- we get all that are prior to this one. we need to get the terminalOpSeqNum as well
      begin
        if ( p_routingSeqID is null ) then
          -- line op doesn't have effectivity date
          select distinct bos.operation_sequence_id
            into l_opSeqID
            from bom_operation_sequences bos,
                 bom_operational_routings bor
           where bor.common_routing_sequence_id = bos.routing_sequence_id
             and bor.assembly_item_id = p_assyItemID
             and bor.organization_id = p_orgID
             and nvl(alternate_routing_designator, 'NONE') =
                 nvl(p_altRoutDesig, 'NONE')
             and bos.operation_seq_num = p_terminalOpSeqNum
             and bos.operation_type = 3;
        else
          select distinct bos.operation_sequence_id
            into l_opSeqID
            from bom_operation_sequences bos,
                 bom_operational_routings bor
           where bor.common_routing_sequence_id = bos.routing_sequence_id
             and bor.common_routing_sequence_id = p_routingSeqID
             and bos.operation_seq_num = p_terminalOpSeqNum
             and bos.operation_type = 3;
        end if;

        l_num := x_lineOpTbl.count;
        x_lineOpTbl(l_num+1).operation_seq_num := p_terminalOpSeqNum;
        x_lineOpTbl(l_num+1).operation_sequence_id := l_opSeqID;
      exception
      when others then
        null; --if the terminal op seq or the routing doesn't exist, just ignore it
      end;
    elsif ( p_terminalOpSeqNum = -1 ) then
      bom_rtg_network_api.get_all_primary_line_ops(
             p_rtg_sequence_id => p_routingSeqID,
             p_assy_item_id => p_assyItemID,
             p_org_id =>  p_orgID,
             p_alt_rtg_desig => p_altRoutDesig,
             x_op_tbl => x_lineOpTbl);
    elsif ( p_terminalOpSeqNum = -2 ) then
      bom_rtg_network_api.get_all_line_ops(
             p_rtg_sequence_id => p_routingSeqID,
             p_assy_item_id => p_assyItemID,
             p_org_id =>  p_orgID,
             p_alt_rtg_desig => p_altRoutDesig,
             x_op_tbl => x_lineOpTbl);
    end if;
  end constructWipLineOps;


  /**
   * This function decides whether the given event belongs to a line op that is
   * prior to or the same as the given line op or not.
   * If you call constructWipLineOps before calling this function, then the cache
   * built before will be used to check the existence. Otherwise, it will construct
   * the cache and then do the compare.
   * It returns true if p_eventNum belongs to a line op that is prior or same as
   * p_lineOpNum. It returns false otherwise. It also returns false if any of the
   * given parameter doesn't exist.
   */
  function eventInPriorSameLineOp(p_routingSeqID in number,
                                  p_eventNum     in number,
                                  p_lineOpNum    in number,
                                  p_lineOpTbl    in bom_rtg_network_api.op_tbl_type)
                                                                      return boolean is
    l_evtLineOp number;
    l_count number;
  begin
    select distinct bos2.operation_seq_num
      into l_evtLineOp
      from bom_operation_sequences bos1,
           bom_operation_sequences bos2
     where bos1.routing_sequence_id = bos2.routing_sequence_id
       and bos1.routing_sequence_id = p_routingSeqID
       and bos1.operation_seq_num = p_eventNum
       and bos1.operation_type = 1 -- event
       and bos1.line_op_seq_id = bos2.operation_sequence_id
       and bos2.operation_type = 3; -- line op

    l_count := p_lineOpTbl.first;
    while ( l_count is not null ) loop
      if ( p_lineOpTbl(l_count).operation_seq_num = l_evtLineOp ) then
        return true;
      end if;
      l_count := p_lineOpTbl.next(l_count);
    end loop;
    return false;
  exception
  when no_data_found then
    -- the select statment doesn't select anything, this event is not assigned to
    -- any line op.
    return true;
  when others then
    return false;
  end eventInPriorSameLineOp;


  /**
   * This function is used to derive the transaction action id from the
   * transaction type id
   */
  function getTypeFromAction(p_txnActionID in number) return number is
  begin
    if ( p_txnActionID = WIP_CONSTANTS.ISSCOMP_ACTION ) then
      return WIP_CONSTANTS.ISSCOMP_TYPE;
    end if;

    if ( p_txnActionID = WIP_CONSTANTS.ISSNEGC_ACTION ) then
      return WIP_CONSTANTS.ISSNEGC_TYPE;
    end if;

    if ( p_txnActionID = WIP_CONSTANTS.RETCOMP_ACTION ) then
      return WIP_CONSTANTS.RETCOMP_TYPE;
    end if;

    if ( p_txnActionID = WIP_CONSTANTS.RETNEGC_ACTION ) then
      return WIP_CONSTANTS.RETNEGC_TYPE;
    end if;

    return null;
  end getTypeFromAction;

  /**
   * This function is used to derive the transaction_type_id and transaction_action_id
   * of the child given the parent txn type id and required per assembly.
   */
  procedure getChildTxn(p_parentTxnTypeID  in  number,
                        p_signOfPer        in  number,
                        x_childTxnTypeID   out nocopy number,
                        x_childTxnActionID out nocopy number) is
  begin
    if ( p_parentTxnTypeID in (WIP_CONSTANTS.CPLASSY_TYPE,
                               WIP_CONSTANTS.SCRASSY_TYPE) ) then
      if ( p_signOfPer > 0 ) then
        x_childTxnTypeID := WIP_CONSTANTS.ISSCOMP_TYPE;
        x_childTxnActionID := WIP_CONSTANTS.ISSCOMP_ACTION;
      else
        x_childTxnTypeID := WIP_CONSTANTS.ISSNEGC_TYPE;
        x_childTxnActionID := WIP_CONSTANTS.ISSNEGC_ACTION;
      end if;
    else -- return or return from scrap
      if ( p_signOfPer > 0 ) then
        x_childTxnTypeID := WIP_CONSTANTS.RETCOMP_TYPE;
        x_childTxnActionID := WIP_CONSTANTS.RETCOMP_ACTION;
      else
        x_childTxnTypeID := WIP_CONSTANTS.RETNEGC_TYPE;
        x_childTxnActionID := WIP_CONSTANTS.RETNEGC_ACTION;
      end if;
    end if;
  end getChildTxn;


  /**
   * Generate the issue locators for all the issues associated with a completion
   * This would be called only for a project related completions.
   */
  procedure generateCompLocator(p_parentID     in  number,
                                x_returnStatus out nocopy varchar2) is
    cursor comp_c(cpl_id number) is
      select inventory_item_id,
             subinventory_code,
             locator_id,
             rowid
        from mtl_material_transactions_temp
       where completion_transaction_id = cpl_id
         and transaction_source_type_id = 5
         and flow_schedule = 'Y'
         and process_flag = 'Y'
         and locator_id is not null
         and transaction_action_id in (WIP_CONSTANTS.ISSCOMP_ACTION,
                                       WIP_CONSTANTS.RETCOMP_ACTION,
                                       WIP_CONSTANTS.ISSNEGC_ACTION,
                                       WIP_CONSTANTS.RETNEGC_ACTION)
       order by operation_seq_num;

    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_success boolean;

    l_orgID number;
    l_cplID number;
    l_srcProjectID number;
    l_srcTaskID number;
    l_wipEntityID number;
    l_projRefEnabled number;
    l_orgLocControl number := 0;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_parentID';
      l_params(1).paramValue := p_parentID;
      wip_logger.entryPoint(p_procName => 'wip_flowUtil_priv.generateCompLocator',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    select organization_id,
           completion_transaction_id,
           transaction_source_id,
           source_project_id,
           source_task_id
      into l_orgID,
           l_cplID,
           l_wipEntityID,
           l_srcProjectID,
           l_srcTaskID
      from mtl_material_transactions_temp
     where transaction_temp_id = p_parentID;

    select nvl(project_reference_enabled, 2),
           stock_locator_control_code
      into l_projRefEnabled,
           l_orgLocControl
      from mtl_parameters
     where organization_id = l_orgID;

    if ( (l_srcProjectID is null) or (l_projRefEnabled <> 1) ) then
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_flowUtil_priv.generateCompLocator',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'Source project id is null or the org parameter ' ||
                                      'does not has project reference enabled',
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      return;
    end if;

    for comp_rec in comp_c(l_cplID) loop
      l_success := pjm_project_locator.get_component_projectsupply(
                       p_organization_id => l_orgID,
                       p_project_id => l_srcProjectID,
                       p_task_id => l_srcTaskID,
                       p_wip_entity_id => l_wipEntityID,
                       p_supply_sub => comp_rec.subinventory_code,
                       p_supply_loc_id => comp_rec.locator_id,
                       p_item_id => comp_rec.inventory_item_id,
                       p_org_loc_control => l_orgLocControl);
      if ( l_success = false ) then
        x_returnStatus := fnd_api.g_ret_sts_error;
        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.exitPoint(p_procName => 'wip_flowUtil_priv.generateCompLocator',
                               p_procReturnStatus => x_returnStatus,
                               p_msg => 'Error in calling '||
                                        'pjm_project_locator.get_component_projectsupply!',
                               x_returnStatus => l_returnStatus); --discard logging return status
        end if;
        return;
      end if;

      if ( comp_rec.locator_id <> 0 ) then
        update mtl_material_transactions_temp
           set (locator_id, project_id, task_id) =
               (select inventory_location_id,
                       project_id,
                       task_id
                  from mtl_item_locations
                 where inventory_location_id = comp_rec.locator_id
                   and organization_id = l_orgID)
         where rowid = comp_rec.rowid;
      end if;
    end loop;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_flowUtil_priv.generateCompLocator',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Finished!',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  end generateCompLocator;

end wip_flowUtil_priv;

/
