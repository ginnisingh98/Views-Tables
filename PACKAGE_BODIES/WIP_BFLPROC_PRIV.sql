--------------------------------------------------------
--  DDL for Package Body WIP_BFLPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_BFLPROC_PRIV" as
  /* $Header: wipbflpb.pls 120.48.12010000.11 2010/02/01 22:15:51 ntangjee ship $ */

  ---------------
  --private types
  ---------------

  type component_rec_t is record(itemID NUMBER,
                                 itemName VARCHAR2(2000),
                                 deptID NUMBER,
                                 orgID  NUMBER,
                                 opSeqNum NUMBER,
                                 countPointType NUMBER,
                                 supplySub VARCHAR2(10),
                                 supplyLocID NUMBER,
                                 restrictSubsCode NUMBER,
                                 restrictLocsCode NUMBER,
                                 qtyPerAssy NUMBER,
                                 /* begin LBM Project added new members */
                                 requiredQty NUMBER,
                                 qtyIssued   NUMBER,
                                 opAblyQtyCompleted NUMBER,
                                 jobAblyQtyCompleted NUMBER,
                                 jobAblyQtyScrapped  NUMBER,
                                 basisType  NUMBER,
                                 /* end LBM Project */
                                 componentYieldFactor NUMBER, /* ER 4369064 */
                                 priUomCode VARCHAR2(3),
                                 lotControlCode NUMBER,
                                 serialNumControlCode NUMBER,
                                 revControlCode VARCHAR2(3),
                                 projectID NUMBER,
                                 taskID NUMBER,
                                 srcProjectID NUMBER,
                                 srcTaskID NUMBER,
                                 itemDescription VARCHAR2(240),
                                 locatorName VARCHAR2(2000),
                                 revisionControlCode NUMBER,
                                 locationControlCode NUMBER,
                                 locatorProjectID NUMBER,
                                 locatorTaskID NUMBER);


  ----------------------
  --forward declarations
  ----------------------

  function findTxnTypeID(p_txnActionID IN NUMBER) return NUMBER;

  ---------------------------
  --public/private procedures
  ---------------------------

  procedure processRequirements(p_wipEntityID    IN NUMBER,
                                p_wipEntityType  IN NUMBER,
                                p_repSchedID     IN NUMBER := null,
                                p_repLineID      IN NUMBER := null,
                                p_cplTxnID       IN NUMBER := null,
                                p_movTxnID       IN NUMBER := null,
                                p_batchID        IN NUMBER := null,
                                p_orgID          IN NUMBER,
                                p_assyQty        IN NUMBER, --relative to wip (positive means pull material)
                                p_txnDate        IN DATE,
                                p_wipSupplyType  IN NUMBER,
                                p_txnHdrID       IN NUMBER,
                                p_firstOp        IN NUMBER,
                                p_lastOp         IN NUMBER,
                                p_firstMoveOp    IN NUMBER := null,
                                p_lastMoveOp     IN NUMBER := null,
                                p_srcCode        IN VARCHAR2 := null,
                                p_batchSeq       IN NUMBER := null,
                                p_lockFlag       IN NUMBER := null,
                                p_mergeMode      IN VARCHAR2,
                                p_reasonID       IN NUMBER := null,
                                p_reference      IN VARCHAR2 := null,
                                p_initMsgList    IN VARCHAR2,
                                p_endDebug       IN VARCHAR2,
                                p_mtlTxnMode     IN NUMBER,
                                x_compTbl        IN OUT NOCOPY system.wip_component_tbl_t,
                                x_returnStatus  OUT NOCOPY VARCHAR2) is
    cursor c_populatedReqs IS
      select mti.inventory_item_id itemID,
             mti.transaction_interface_id txnIntID,
             mti.transaction_action_id txnActionID,
             mti.operation_seq_num opSeqNum,
             -1 * mti.primary_quantity priQty, --make qty relative to wip (relative to inv in table)
             -1 * mti.transaction_quantity txnQty, --make qty relative to wip (relative to inv in table)
             msi.lot_control_code lotControlCode,
             msi.serial_number_control_code serialNumControlCode
        from mtl_transactions_interface mti,
             mtl_system_items_b msi
       where mti.transaction_header_id = p_txnHdrID
         and mti.transaction_action_id in (wip_constants.isscomp_action, wip_constants.retcomp_action,
                                            wip_constants.issnegc_action, wip_constants.retnegc_action)
         and mti.operation_seq_num between p_firstOp and p_lastOp
         and msi.inventory_item_id = mti.inventory_item_id
         and msi.organization_id = mti.organization_id
         and (   (    p_cplTxnID is null
                  and p_movTxnID is null)
              or mti.move_transaction_id = p_movTxnID
              or mti.completion_transaction_id = p_cplTxnID
             )
/*      group by mmtt.inventory_item_id,
               mmtt.transaction_action_id,
               mmtt.operation_seq_num,
               msi.lot_control_code,
               msi.serial_number_control_code
  */    order by mti.inventory_item_id, mti.operation_seq_num;

    cursor c_discReqs return component_rec_t IS
      select wro.inventory_item_id,
             msi.concatenated_segments,
             wro.department_id,
             wro.organization_id,
             wro.operation_seq_num,
             wo.count_point_type,
             wro.supply_subinventory,
             wro.supply_locator_id,
             msi.restrict_subinventories_code,
             msi.restrict_locators_code,
             wro.quantity_per_assembly,
             /* begin LBM Project */
             wro.required_quantity,
             wro.quantity_issued,
             wo.quantity_completed,
             wdj.quantity_completed,
             wdj.quantity_scrapped,
             wro.basis_type,
             /* end LBM Project */
             nvl(wro.component_yield_factor,1),  /* ER 4369064 */
             msi.primary_uom_code,
             msi.lot_control_code,
             msi.serial_number_control_code,
             msi.revision_qty_control_code,
             mil.segment19,
             mil.segment20,
             wdj.project_id,
             wdj.task_id,
             msi.description,
             decode(mp.project_reference_enabled,
               null,milk.concatenated_segments,
               2,milk.concatenated_segments,
               1, inv_project.get_pjm_locsegs(milk.concatenated_segments)),
             msi.revision_qty_control_code,
             msi.location_control_code,
             mil.project_id,
             mil.task_id
        from wip_requirement_operations wro,
             mtl_system_items_kfv msi,
             wip_operations wo,
             mtl_item_locations_kfv milk,
             wip_discrete_jobs wdj,
             mtl_parameters mp,
           -- Fixed bug 4692413. We should not refer to column in kfv directly.
             mtl_item_locations mil
       where wro.inventory_item_id = msi.inventory_item_id
         and wro.organization_id = msi.organization_id
         and wro.organization_id = mp.organization_id
         and wro.wip_entity_id = p_wipEntityID
         and wro.wip_supply_type = p_wipSupplyType
         and wro.quantity_per_assembly <> 0
         and wro.operation_seq_num between p_firstOp and p_lastOp
         and wro.wip_entity_id = wdj.wip_entity_id
         and wro.organization_id = wdj.organization_id
         and wro.wip_entity_id = wo.wip_entity_id (+)
         and wro.operation_seq_num = wo.operation_seq_num (+)
         /* added for OSFM jump enhancement 2541431 */
         and nvl(wo.skip_flag, WIP_CONSTANTS.NO) <> WIP_CONSTANTS.YES
         and wro.supply_locator_id = mil.inventory_location_id (+)
         and wro.organization_id = mil.organization_id (+)
         and wro.supply_locator_id = milk.inventory_location_id (+)
         and wro.organization_id = milk.organization_id (+)
       order by wro.inventory_item_id, wro.operation_seq_num;

    cursor c_repReqs return component_rec_t IS
      select wro.inventory_item_id,
             msi.concatenated_segments,
             wro.department_id,
             wro.organization_id,
             wro.operation_seq_num,
             wo.count_point_type,
             wro.supply_subinventory,
             wro.supply_locator_id,
             msi.restrict_subinventories_code,
             msi.restrict_locators_code,
             wro.quantity_per_assembly,
             /* LBM Project */
             wro.required_quantity,
             wro.quantity_issued,
             wo.quantity_completed,
             wrs.quantity_completed,
             0,                         -- quantity_scrapped
             wro.basis_type,
             /* LBM Project */
             nvl(wro.component_yield_factor,1),  /* ER 4369064 */
             msi.primary_uom_code,
             msi.lot_control_code,
             msi.serial_number_control_code,
             msi.revision_qty_control_code,
             mil.segment19,
             mil.segment20,
             null,
             null,
             msi.description,
             decode(mp.project_reference_enabled,
               null,milk.concatenated_segments,
               2,milk.concatenated_segments,
               1, inv_project.get_pjm_locsegs(milk.concatenated_segments)),
             msi.revision_qty_control_code,
             msi.location_control_code,
             mil.project_id,
             mil.task_id
        from wip_requirement_operations wro,
             wip_repetitive_schedules wrs,
             wip_repetitive_items wri,
             mtl_system_items_kfv msi,
             wip_operations wo,
             mtl_item_locations_kfv milk,
             mtl_parameters mp,
          -- Fixed bug 4692413. We should not refer to column in kfv directly.
             mtl_item_locations mil
       where wro.wip_entity_id = p_wipEntityID
         and wro.repetitive_schedule_id = p_repSchedID
         and wro.wip_supply_type = p_wipSupplyType
         and wro.repetitive_schedule_id = wrs.repetitive_schedule_id
         and wro.quantity_per_assembly <> 0
         and wro.operation_seq_num between p_firstOp and p_lastOp
         and wri.wip_entity_id = wrs.wip_entity_id
         and wri.line_id = wrs.line_id
         and msi.inventory_item_id = wro.inventory_item_id /* Fix bug#4233474 */
         and msi.organization_id = wro.organization_id /* Fix bug#4233474 */
         and msi.organization_id = mp.organization_id
         and wro.wip_entity_id = wo.wip_entity_id (+)
         and wro.repetitive_schedule_id = wo.repetitive_schedule_id (+)
         and wro.operation_seq_num = wo.operation_seq_num (+)
         and wro.supply_locator_id = mil.inventory_location_id (+)
         and wro.organization_id = mil.organization_id (+)
         and wro.supply_locator_id = milk.inventory_location_id (+)
         and wro.organization_id = milk.organization_id (+)
       order by wro.inventory_item_id, wro.operation_seq_num;

    /* BUG 4712505 */
    cursor c_checkExistingMTI(x_opSeqNum NUMBER, x_inventoryItemID NUMBER,
                              x_txnActionID NUMBER, x_txnTypeID NUMBER) IS
       select 1
       from mtl_transactions_interface mti
       where mti.transaction_source_id = p_wipEntityID
         and mti.organization_id = p_orgID
         and mti.operation_seq_num = x_opSeqNum
         and mti.inventory_item_id = x_inventoryItemID
         and mti.transaction_action_id = x_txnActionID
         and mti.transaction_type_id = x_txnTypeID;

    cursor c_checkExistingMMTT(x_opSeqNum NUMBER, x_inventoryItemID NUMBER,
                               x_txnActionID NUMBER, x_txnTypeID NUMBER) IS
       select 1
       from mtl_material_transactions_temp mmtt
       where mmtt.transaction_source_id = p_wipEntityID
         and mmtt.organization_id = p_orgID
         and mmtt.operation_seq_num = x_opSeqNum
         and mmtt.inventory_item_id = x_inventoryItemID
         and mmtt.transaction_action_id = x_txnActionID
         and mmtt.transaction_type_id = x_txnTypeID;

    l_reqRec component_rec_t;
    l_popRec c_populatedReqs%ROWTYPE;
    l_txnActionID NUMBER;
    l_txnTypeID NUMBER;
    l_compQty NUMBER;
    l_openPastPeriod boolean := false;
    l_acctPeriodID NUMBER;
    l_deriveStatus VARCHAR2(1);
    l_errMsg VARCHAR2(240);
    l_params wip_logger.param_tbl_t;
    l_returnStatus VARCHAR2(1);
    l_extendCount NUMBER := 0;
    l_index NUMBER;
    l_revision VARCHAR2(3);
    l_dummy NUMBER;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_include_yield NUMBER; /* ER 4369064 */


    /* Fix for 5160604/5004291 */
    l_released_revs_type           NUMBER ;
    l_released_revs_meaning        Varchar2(30);
    l_created_by                   NUMBER ;/* Fix for #Bug 5444243 */
  begin
    savepoint wipbflpb20;
    if(fnd_api.to_boolean(p_initMsgList)) then
      fnd_msg_pub.initialize;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_wipEntityID';
      l_params(1).paramValue := p_wipEntityID;
      l_params(2).paramName := 'p_wipEntityType';
      l_params(2).paramValue := p_wipEntityType;
      l_params(3).paramName := 'p_repSchedID';
      l_params(3).paramValue := p_repSchedID;
      l_params(4).paramName := 'p_repLineID';
      l_params(4).paramValue := p_repLineID;
      l_params(5).paramName := 'p_cplTxnID';
      l_params(5).paramValue := p_cplTxnID;
      l_params(6).paramName := 'p_movTxnID';
      l_params(6).paramValue := p_movTxnID;
      l_params(7).paramName := 'p_batchID';
      l_params(7).paramValue := p_batchID;
      l_params(8).paramName := 'p_orgID';
      l_params(8).paramValue := p_orgID;
      l_params(9).paramName := 'p_assyQty';
      l_params(9).paramValue := p_assyQty;
      l_params(10).paramName := 'p_txnDate';
      l_params(10).paramValue := to_char(p_txnDate, 'MM/DD/YYYY HH24:MI:SS');
      l_params(11).paramName := 'p_wipSupplyType';
      l_params(11).paramValue := p_wipSupplyType;
      l_params(12).paramName := 'p_txnHdrID';
      l_params(12).paramValue := p_txnHdrID;
      l_params(13).paramName := 'p_firstOp';
      l_params(13).paramValue := p_firstOp;
      l_params(14).paramName := 'p_lastOp';
      l_params(14).paramValue := p_lastOp;
      l_params(15).paramName := 'p_firstMoveOp';
      l_params(15).paramValue := p_firstMoveOp;
      l_params(16).paramName := 'p_lastMoveOp';
      l_params(16).paramValue := p_lastMoveOp;
      l_params(17).paramName := 'p_batchSeq';
      l_params(17).paramValue := p_batchSeq;
      l_params(18).paramName := 'p_lockFlag';
      l_params(18).paramValue := p_lockFlag;
      l_params(19).paramName := 'p_mergeMode';
      l_params(19).paramValue := p_mergeMode;
      l_params(20).paramName := 'p_reasonID';
      l_params(20).paramValue := p_reasonID;
      l_params(21).paramName := 'p_reference';
      l_params(21).paramValue := p_reference;
      l_params(22).paramName := 'p_mtlTxnMode';
      l_params(22).paramValue := p_mtlTxnMode;
      wip_logger.entryPoint(p_procName => 'wip_bflProc_priv.processRequirements',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

   /* Fix for bug # 5160604/5004291:
      Determine whether to backflush unimplemented revisions */
    wip_common.Get_Released_Revs_Type_Meaning (l_released_revs_type,
                                               l_released_revs_meaning
                                               );

    if(p_wipEntityType = wip_constants.repetitive) then
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('processing repetitive...',l_returnStatus);
      end if;
      --select the highest operation where the backflush flag is set
      open c_repReqs;
    else
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('processing discrete...',l_returnStatus);
      end if;
      open c_discReqs;
    end if;
    --no routing

    open c_populatedReqs;
    invttmtx.tdatechk(org_id => p_orgID,
                      transaction_date => p_txnDate,
                      period_id => l_acctPeriodID,
                      open_past_period => l_openPastPeriod);

    if(l_acctPeriodID is null or
       l_acctPeriodID <= 0) then
      fnd_message.set_name('INV', 'INV_NO_OPEN_PERIOD');
      fnd_msg_pub.add;
      l_errMsg := 'acct period id could not be derived.';
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(x_compTbl is not null) then
      l_index := nvl(x_compTbl.last, 0) + 1;
      x_compTbl.extend(g_compTblExtendSize);
    end if;
    loop
      if(p_repSchedID is not null) then
        fetch c_repReqs into l_reqRec;
        exit when c_repReqs%NOTFOUND;
      else
        fetch c_discReqs into l_reqRec;
        exit when c_discReqs%NOTFOUND;
      end if;
      exit when l_reqRec.opSeqNum > p_lastOp;

      if(p_assyQty > 0) then --completion, forward move
        if(l_reqRec.qtyPerAssy > 0) then
          l_txnActionID := wip_constants.isscomp_action;
        else
          l_txnActionID := wip_constants.issnegc_action;
        end if;
      else --return, backward move
        if(l_reqRec.qtyPerAssy > 0) then
          l_txnActionID := wip_constants.retcomp_action;
        else
          l_txnActionID := wip_constants.retnegc_action;
        end if;
      end if;

      --this loop tries to find an existing record for the backflush component. It exits when it finds one (= condition) or
      --can't find one (gets to end of cursor or itemID > the current requirement's itemID)
      loop
        exit when not c_populatedReqs%ISOPEN;
        exit when l_popRec.opSeqNum > l_reqRec.opSeqNum and l_popRec.itemID > l_reqRec.itemID; --still haven't found a txn
        exit when l_popRec.txnActionID = l_txnActionID
              and l_popRec.itemID = l_reqRec.itemID
              and l_popRec.opSeqNum = l_reqRec.opSeqNum;

        fetch c_populatedReqs into l_popRec;
        if(c_populatedReqs%NOTFOUND) then
          close c_populatedReqs;
          l_popRec.itemID := null; --indicate no item exists
          exit;
        end if;
      end loop;

      --if this isn't an autocharge operation and the operation seq num isn't the one being moved into, then
      --skip inserting requirements.
      --This is the only check we have to do since operations w/assy pull requirements must be autocharge and
      --moves will always pass p_firstMoveOp and p_lastMoveOp
      if(l_reqRec.countPointType = wip_constants.no_direct and
         l_reqRec.opSeqNum not in (p_firstMoveOp, p_lastMoveOp)) then
        goto end_of_loop;
      end if;

      /* begin LBM Project code here to set the component quantity */
      --set the component quantity
      l_compQty := 0;

      /* Bug 4712535 -- need to check for include component yield flag even for lot based items */
      select nvl(include_component_yield,1)
            into l_include_yield
            from wip_parameters
           where organization_id = p_orgID;


      if (l_reqRec.basisType = WIP_CONSTANTS.LOT_BASED_MTL) then

         -- forward move

         if (l_reqRec.qtyIssued = 0 and p_assyQty > 0) then

             /* Bug 4712535 */
             if (l_include_yield = 1) then
                -- backflush the entire quantity stored in wro, since it is calculated based on
                -- comp yield at job component definition time

               l_compQty := round(l_reqRec.qtyPerAssy / NVL(l_reqRec.componentYieldFactor,1),
                                  wip_constants.inv_max_precision);
             else
               -- otherwise just backflush the qty per assembly, not including the comp yield */
               l_compQty := round(l_reqRec.qtyPerAssy, wip_constants.inv_max_precision);
             end if;

         -- backward move

         elsif (p_assyQty < 0) then
            --bug 5285593 The following condition works only for online txns since for background qty completed in WO
            --has already been updated to 0 before reaching here. Hence changing the conditions so that it will work for both
            --online and background cases

            /*
                 if (p_wipSupplyType = WIP_CONSTANTS.OP_PULL and (l_reqRec.opAblyQtyCompleted + p_assyQty) = 0) or
                     (p_wipSupplyType = WIP_CONSTANTS.ASSY_PULL and
                     (l_reqRec.jobAblyQtyCompleted + l_reqRec.jobAblyQtyScrapped + p_assyQty) = 0) then
             */

            -- bug 5524972 rewritten the following if clause. made logic for assembly pull components similar to
            -- that for operation pull

            /*

            if (((p_wipSupplyType = WIP_CONSTANTS.OP_PULL)
                  and (LEAST(l_reqRec.opAblyQtyCompleted, ABS(l_reqRec.opAblyQtyCompleted + p_assyQty)) = 0)) or
                ((p_wipSupplyType = WIP_CONSTANTS.ASSY_PULL)
                  and (LEAST(l_reqRec.jobAblyQtyCompleted + l_reqRec.jobAblyQtyScrapped,
                             ABS(l_reqRec.jobAblyQtyCompleted + l_reqRec.jobAblyQtyScrapped + p_assyQty)) = 0)))
            */

            if (((p_wipSupplyType = WIP_CONSTANTS.OP_PULL) or (p_wipSupplyType = WIP_CONSTANTS.ASSY_PULL))
                  and (LEAST(l_reqRec.opAblyQtyCompleted, ABS(l_reqRec.opAblyQtyCompleted + p_assyQty)) = 0))
            then

                /* Bug 4712535 */

                if (l_include_yield = 1) then
                  l_compQty := - round(l_reqRec.qtyPerAssy / NVL(l_reqRec.componentYieldFactor,1),
                                  wip_constants.inv_max_precision);
                else
                  l_compQty := - round(l_reqRec.qtyPerAssy, wip_constants.inv_max_precision);
                end if;

            end if;

         end if;

         /* below code changed due to comp yield project. */

      else

          /* ER 4369064: Component quantity will depend on yield factor, if the parameter is set */
          /*select include_component_yield
            into l_include_yield
            from wip_parameters
           where organization_id = p_orgID;  -- moved above */

          if (l_include_yield = 1) then
              l_compQty := round(l_reqRec.qtyPerAssy * p_assyQty/NVL(l_reqRec.componentYieldFactor,1),
                           wip_constants.inv_max_precision);
          else
              l_compQty := round(l_reqRec.qtyPerAssy * p_assyQty,
                           wip_constants.inv_max_precision);
          end if;

      end if;

      /* end LBM Project code here to set the component quantity */



      --this if gets executed, say, if the Q/A is something like 1 X 10E-100 or something. it's not in the
      --cursor where clause b/c we actually need to multiply by txn qty since if the assy qty is large, the required
      --quantity for the component could be large enough to transact. in the above case, let's say the assy qty was
      --1 X 10E100. The required qty for the component would be 1 and thus we would populate the requirement.
      if(l_compQty = 0) then
        goto end_of_loop;
      end if;


      if(l_popRec.itemID = l_reqRec.itemID) then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('found existing requirement',l_returnStatus);
        end if;
        if(fnd_api.to_boolean(p_mergeMode)) then
           --user wants to merge requirements. Update the txn qty
           update mtl_transactions_interface
                  set last_update_date = sysdate,
                  last_updated_by = fnd_global.user_id,
                  last_update_login = fnd_global.login_id,
                  request_id = fnd_global.conc_request_id,
                  program_application_id = fnd_global.prog_appl_id,
                  program_id = fnd_global.conc_program_id,
                  program_update_date = sysdate,
                  transaction_quantity = transaction_quantity - l_compQty, --subtract b/c l_compQty is relative to WIP
                  primary_quantity = primary_quantity - l_compQty --subtract b/c l_compQty is relative to WIP
            where transaction_interface_id = l_popRec.txnIntID;
        end if;
        --in either mode, skip the MTI insert.
        goto end_of_loop;
      end if;

      l_txnTypeID := findTxnTypeID(p_txnActionID => l_txnActionID);

      /* Fix for bug# 5160604/5004291:
         Added eco_status parameter to ensure that the revision being
         backflushed will be determind by the profile WIP_RELEASED_REVS */

      if(l_reqRec.revControlCode = wip_constants.revision_controlled) then
        bom_revisions.get_revision(examine_type => 'ALL',
                                   eco_status => l_released_revs_meaning,
                                   org_id => p_orgID,
                                   item_id => l_reqRec.itemID,
                                   rev_date => p_txnDate,
                                   itm_rev => l_revision);
      else
        l_revision := null;
      end if;

      /* Bug 4712505 */
      -- For lot based components we need to check if there are existing records in MTI or MMTT.
      -- If there are existing records then we don't want to backflush again, since the quantity
      -- should only be backflushed once.
      if (l_reqRec.basisType = WIP_CONSTANTS.LOT_BASED_MTL) then
        open c_checkExistingMTI(l_reqRec.opSeqNum, l_reqRec.itemID, l_txnActionID, l_txnTypeID);
        fetch c_checkExistingMTI into l_dummy;
        -- Fixed bug 4755034. This is a regression from 4712505 bug fix.
        -- Cursor should be close no matter pending record found or not.
        if c_checkExistingMTI%found then
          close c_checkExistingMTI;
          goto end_of_loop;
        else
          close c_checkExistingMTI;
        end if;

        open c_checkExistingMMTT(l_reqRec.opSeqNum, l_reqRec.itemID, l_txnActionID, l_txnTypeID);
        fetch c_checkExistingMMTT into l_dummy;
        -- Fixed bug 4755034. This is a regression from 4712505 bug fix.
        -- Cursor should be close no matter pending record found or not.
        if c_checkExistingMMTT%found then
          close c_checkExistingMMTT;
          goto end_of_loop;
        else
          close c_checkExistingMMTT;
        end if;
      end if;


      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('inserting item:' || l_reqRec.itemID || ' opSeq:' ||  l_reqRec.opSeqNum || ' qty:' || l_compQty * -1,l_returnStatus);
        wip_logger.log('txnAction:' || l_txnActionID || ' txnType:' || l_txnTypeID,l_returnStatus);
      end if;
      if(x_compTbl is null) then

       /* Fix for Bug 5444243 */
        Begin
          SELECT created_by
          INTO l_created_by
          FROM wip_move_transactions
          WHERE TRANSACTION_ID = p_movTxnID;
        exception when others then
          l_created_by:= fnd_global.user_id;
        end;
        /* End of fix for Bug 5444243 */

        insert into mtl_transactions_interface
          (last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           transaction_header_id,
           transaction_interface_id,
           transaction_source_id,
           transaction_source_type_id,
           transaction_type_id,
           transaction_action_id,
           transaction_date,
           transaction_quantity,
           transaction_uom,
           primary_quantity,
           wip_supply_type,
           wip_entity_type,
           inventory_item_id,
           revision,
           operation_seq_num,
           department_id,
           organization_id,
           process_flag,
--           posting_flag,
           subinventory_code,
           locator_id,
           acct_period_id,
           completion_transaction_id,
           move_transaction_id,
           repetitive_line_id,
           negative_req_flag,
--           item_serial_control_code,
--           item_lot_control_code,
           source_code,
           source_header_id,
           source_line_id,
           project_id,
           task_id,
           source_project_id,
           source_task_id,
           transaction_mode,
           -- transaction_batch_id, /*Fix for bug 8663842(FP 8490405)*/
           -- transaction_batch_seq,/*Fix for bug 8663842(FP 8490405)*/
           lock_flag,
           reason_id,
           transaction_reference)
        values
          (sysdate,
           fnd_global.user_id,
           sysdate,
           l_created_by,/* Fix for Bug 5444243 */
           fnd_global.login_id,
           fnd_global.conc_request_id,
           fnd_global.prog_appl_id,
           fnd_global.conc_program_id,
           sysdate,
           p_txnHdrID,
           mtl_material_transactions_s.nextval,
           p_wipEntityID,
           5,
           l_txnTypeID,
           l_txnActionID,
           p_txnDate,
           -1 * l_compQty, --make quantity relative to inventory
           l_reqRec.priUomCode,
           -1 * l_compQty,
           p_wipSupplyType,
           p_wipEntityType,
           l_reqRec.itemID,
           l_revision,
           l_reqRec.opSeqNum,
           l_reqRec.deptID,
           l_reqRec.orgID,
           wip_constants.mti_inventory,
--           'Y',
           l_reqRec.supplySub,
           l_reqRec.supplyLocID,
           l_acctPeriodID,
           p_cplTxnID,
           p_movTxnID,
           p_repLineID,
           decode(l_txnActionID,
             wip_constants.isscomp_action, 1,
             wip_constants.retcomp_action, 1,
             wip_constants.issnegc_action, -1,
             wip_constants.retnegc_action, -1),
--           l_reqRec.serialNumControlCode,
--           l_reqRec.lotControlCode,
           nvl(p_srcCode, 'WIP Backflush'),
           p_wipEntityID,
           l_reqRec.opSeqNum,
           l_reqRec.projectID,
           l_reqRec.taskID,
           l_reqRec.srcProjectID,
           l_reqRec.srcTaskID,
           p_mtlTxnMode,
           -- p_batchID, /*Fix for bug 8663842(FP 8490405)*/
           -- NVL(p_batchSeq,wip_constants.component_batch_seq), /*Fix for bug 8663842(FP 8490405)*/
           p_lockFlag,
           p_reasonID,
           p_reference);
      --must be after completion
      else
        if(floor(l_extendCount/g_compTblExtendSize) = 1) then
          x_compTbl.extend(g_compTblExtendSize);
          l_extendCount := 0;
        end if;
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('serial control code is ' || l_reqRec.serialNumControlCode,l_returnStatus);
          wip_logger.log('lot control code is ' || l_reqRec.lotControlCode,l_returnStatus);
        end if;

        --pass movTxnID as the move needs to distinguish between the mtl requirements for the child
        --move transaction vs. the parent move transaction in the over move case. Over-completions do
        --not need this as we can just use supply type to distinguish between the move and completion
        --requirements
        x_compTbl(l_index) := system.wip_component_obj_t(
                                operation_seq_num => l_reqRec.opSeqNum,
                                inventory_item_id => l_reqRec.itemID,
                                item_name => l_reqRec.itemName,
                                primary_quantity => l_compQty,
                                primary_uom_code => l_reqRec.priUomCode,
                                supply_subinventory => l_reqRec.supplySub,
                                supply_locator_id => l_reqRec.supplyLocID,
                                wip_supply_type => p_wipSupplyType,
                                transaction_action_id => l_txnActionID,
                                --don't populate txns enabled flag
                                mtl_transactions_enabled_flag => null,
                                serial_number_control_code => l_reqRec.serialNumControlCode,
                                lot_control_code => l_reqRec.lotControlCode,
                                revision => l_revision,
                                first_lot_index => null,
                                last_lot_index => null,
                                first_serial_index => null,
                                last_serial_index => null,
                                generic_id => p_movTxnID,
                                department_id => l_reqRec.deptID,
                                restrict_subinventories_code => l_reqRec.restrictSubsCode,
                                restrict_locators_code => l_reqRec.restrictLocsCode,
                                project_id => l_reqRec.projectID,
                                task_id => l_reqRec.taskID,
                                component_sequence_id => null,
                                completion_transaction_id => p_cplTxnID,
                                item_description => l_reqRec.itemDescription,
                                locator_name => l_reqRec.locatorName,
                                revision_qty_control_code => l_reqRec.revisionControlCode,
                                location_control_code => l_reqRec.locationControlCode,
                                component_yield_factor => null,/*Component Yield Enhancement(Bug 4369064)->wip_component_obj_t structure has been changed,
                                                                   its value assigened to null to compile the structure..*/
                                basis_type => l_reqRec.basisType,
                                locator_project_id => l_reqRec.locatorProjectID,
                                locator_task_id => l_reqRec.locatorTaskID
                                );
        l_index := l_index + 1;
        l_extendCount := l_extendCount + 1;
      end if;

      <<end_of_loop>>
      null;
    end loop;
    if(x_compTbl is not null) then
      --trim any trailing null entries
      x_compTbl.trim(g_compTblExtendSize - l_extendCount);
    end if;

    if(c_populatedReqs%ISOPEN) then
      close c_populatedReqs;
    end if;

    if(c_discReqs%ISOPEN) then
      close c_discReqs;
    end if;
    if(c_repReqs%ISOPEN) then
      close c_repReqs;
    end if;

    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.processRequirements',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'procedure succeeded',
                         x_returnStatus => l_returnStatus); --discard logging return status
    end if;

    if(fnd_api.to_boolean(p_endDebug)) then
      wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      rollback to wipbflpb20;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.processRequirements',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus); --discard logging return status
      end if;

      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      rollback to wipbflpb20;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;--unexpec error if exception occurs
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_bflProc_priv',
                              p_procedure_name => 'processRequirements',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.processRequirements',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;

      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end processRequirements;


  procedure explodeRequirements(p_itemID        IN NUMBER,
                                p_orgID         IN NUMBER,
                                p_qty           IN NUMBER,
                                p_altBomDesig   IN VARCHAR2,
                                p_altOption     IN NUMBER,
    /* Fix for bug#3423629 */   p_bomRevDate    IN DATE  DEFAULT NULL,
                                p_txnDate       IN DATE,
    /* Fix for bug 5383135 */   p_implFlag      IN NUMBER,
                                p_projectID     IN NUMBER,
                                p_taskID        IN NUMBER,
    /* added for bug 5332615 */ p_unitNumber  in varchar2 DEFAULT '',
                                p_initMsgList   IN VARCHAR2,
                                p_endDebug      IN VARCHAR2,
                                x_compTbl      OUT NOCOPY system.wip_component_tbl_t,
                                x_returnStatus OUT NOCOPY VARCHAR2) is
    l_grpID NUMBER; --bom table identifier
    l_cmnBillID NUMBER;
    l_cmnOrgID NUMBER;
    l_isPhantom boolean := false;
    l_phantomRowID rowid;
    l_opSeqNum NUMBER;
    l_qtyMultiplier NUMBER := 1;
    l_index NUMBER := 1;
    l_params wip_logger.param_tbl_t;
    l_errMsg VARCHAR2(240);
    l_returnStatus VARCHAR2(1);
    l_errCode NUMBER;
    l_inheritPhOpSeq NUMBER;
    l_bomItemType NUMBER;
    l_maxBomLevel NUMBER;
    l_extendCount NUMBER := 0;
    l_bomLevel NUMBER;
    l_dummy NUMBER;
    l_msgData VARCHAR2(8000);
    l_msgCount NUMBER;
    l_locatorControl NUMBER;
    l_locID NUMBER;
    l_revision VARCHAR2(3);
    l_txnActionID NUMBER;
    l_success boolean;
    l_projectID NUMBER;
    l_taskID NUMBER;
    l_bom_or_eng_flag NUMBER := 1;
    l_released_revs_type           NUMBER ;
    l_released_revs_meaning        Varchar2(30);

    cursor c_components(v_cmnOrgID NUMBER, v_orgID NUMBER, v_grpID NUMBER) is
      select be.operation_seq_num opSeqNum,
             be.component_item_id itemID,
             be.component_quantity priQty,
             be.component_yield_factor compYield,
             msi.primary_uom_code priUomCode,
             msi.mtl_transactions_enabled_flag txnsEnabledFlag,
             decode(msi.shrinkage_rate, 1, 0, null, 0, msi.shrinkage_rate) shrinkageRate,
             decode(be.common_bill_sequence_id, be.bill_sequence_id, bic.supply_subinventory, null) supplySubinv,/*Fix bug 7609139 (FP bug 7415520)*/
             decode(be.common_bill_sequence_id, be.bill_sequence_id, bic.supply_locator_id, null) supplyLocID,/*Fix bug 7609139 (FP bug 7415520)*/
             nvl(bic.wip_supply_type , msi.wip_supply_type) wipSupplyType, /* 2695355 */
             be.component_code compCode,
             be.rowid beRowID,
             be.plan_level bomLevel, --level of nesting. 1 is a top level component
             bic.basis_type   /* LBM Project */
        from bom_explosion_temp be,
             bom_inventory_components bic,
             mtl_system_items msi
       where be.group_id = v_grpID
         and be.component_sequence_id = bic.component_sequence_id
         and be.component_item_id = msi.inventory_item_id
         and be.component_item_id <> p_itemID --exclude assy if it is in the table
         and msi.bom_item_type not in (wip_constants.model_type,
                                       wip_constants.option_class_type) /* Fix for 4575119 */
         and msi.organization_id = v_orgID
       order by be.component_code;

    cursor c_groupedComponents(v_cmnOrgID NUMBER, v_orgID NUMBER, v_grpID NUMBER) is
      select be.operation_seq_num opSeqNum,
             msi.concatenated_segments itemName,
             be.component_item_id itemID,
             sum(be.component_quantity) priQty,/*For Component Yield Enhancement(Bug 4369064)->Removed yield consideration */
             msi.primary_uom_code priUomCode,
             msi.restrict_subinventories_code restrictSubs,
             msi.restrict_locators_code restrictLocs,
             decode(msi.shrinkage_rate, 1, 0, null, 0, msi.shrinkage_rate) shrinkageRate,
             decode(be.common_bill_sequence_id, be.bill_sequence_id, bic.supply_subinventory, null) supplySubinv,/*Fix bug 7609139 (FP bug 7415520)*/
             decode(be.common_bill_sequence_id, be.bill_sequence_id, bic.supply_locator_id, null) supplyLocID,/*Fix bug 7609139 (FP bug 7415520)*/
             bic.component_sequence_id componentSeqID,
             nvl(bic.wip_supply_type , msi.wip_supply_type) wipSupplyType, /* 2695355 */
             msi.mtl_transactions_enabled_flag txnsEnabledFlag,
             msi.revision_qty_control_code revControlCode,
             msi.serial_number_control_code serialNumControlCode,
             msi.lot_control_code lotControlCode,
             msi.end_assembly_pegging_flag pegFlag,
             be.component_yield_factor compYield, /*For Component Yield Enhancement(Bug 4369064) */
             bic.basis_type,                        /* LBM Project */
             /* Add more item for flow OA project */
             msi.description itemDesc,
             msi.location_control_code locControlCode,
             decode(mp.project_reference_enabled,
               null,milk.concatenated_segments,
               2,milk.concatenated_segments,
               1, inv_project.get_pjm_locsegs(milk.concatenated_segments)) locatorName
        from bom_explosion_temp be,
             bom_inventory_components bic,
             mtl_system_items_kfv msi,
             mtl_item_locations_kfv milk,
             mtl_parameters mp
       where be.group_id = v_grpID
         and be.component_sequence_id = bic.component_sequence_id
         and be.component_item_id = msi.inventory_item_id
         and be.component_item_id <> p_itemID --exclude assy if it is in the table
         and msi.bom_item_type not in (wip_constants.model_type,
                                       wip_constants.option_class_type) /* Fix for 4575119 */
         and msi.organization_id = v_orgID
         and msi.organization_id = mp.organization_id
         and bic.supply_locator_id = milk.inventory_location_id(+)
       group by be.operation_seq_num,
                msi.concatenated_segments,
                be.component_item_id,
                msi.primary_uom_code,
                msi.restrict_subinventories_code,
                msi.restrict_locators_code,
                decode(msi.shrinkage_rate, 1, 0, null, 0, msi.shrinkage_rate),
                decode(be.common_bill_sequence_id, be.bill_sequence_id, bic.supply_subinventory, null),/*Fix bug 7609139 (FP bug 7415520)*/
                decode(be.common_bill_sequence_id, be.bill_sequence_id, bic.supply_locator_id, null),/*Fix bug 7609139 (FP bug 7415520)*/
                bic.component_sequence_id,
                nvl(bic.wip_supply_type, msi.wip_supply_type),
                msi.mtl_transactions_enabled_flag,
                msi.revision_qty_control_code,
                msi.serial_number_control_code,
                msi.lot_control_code,
                msi.end_assembly_pegging_flag,
                be.component_yield_factor,
                bic.basis_type,                           /* LBM Project */
                msi.description,
                msi.location_control_code,
                decode(mp.project_reference_enabled,
                  null,milk.concatenated_segments,
                  2,milk.concatenated_segments,
                  1, inv_project.get_pjm_locsegs(milk.concatenated_segments))
       order by be.component_item_id;--be.operation_seq_num, msi.concatenated_segments;

    l_compRec c_components%ROWTYPE;
    l_logLevel NUMBER := to_number(fnd_log.g_current_runtime_level);

    multiple_factor number ; /* LBM Project */
  begin
    savepoint wipbflpb30;

    if(fnd_api.to_boolean(p_initMsgList)) then
      fnd_msg_pub.initialize;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_itemID';
      l_params(1).paramValue := p_itemID;
      l_params(2).paramName := 'p_orgID';
      l_params(2).paramValue := p_orgID;
      l_params(3).paramName := 'p_altBomDesig';
      l_params(3).paramValue := p_altBomDesig;
      l_params(4).paramName := 'p_altOption';
      l_params(4).paramValue := p_altOption;
      l_params(5).paramName := 'p_txnDate';
      l_params(5).paramValue := to_char(p_txnDate, 'MM/DD/YYYY HH24:MI:SS');
      l_params(6).paramName := 'p_qty';
      l_params(6).paramValue := p_qty;
      wip_logger.entryPoint(p_procName => 'wip_bflProc_priv.explodeRequirements',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    begin
      --get the common bill info.
      if(p_altOption = 2) then

        -- FP Bug 4643335 : Rewrote the query by adding a subquery to improve performance.
	--FP Bug 6502612 : Added Check for Engineering BOMs .
        select a.organization_id, a.bill_sequence_id
          into l_cmnOrgID, l_cmnBillID
          from bom_bill_of_materials a
         where a.bill_sequence_id = (select b.common_bill_sequence_id
                        from  bom_bill_of_materials b
                        where b.assembly_item_id = p_itemID
                        and   b.organization_id = p_orgID
                        and   nvl(b.alternate_bom_designator, '@@@@@') = NVL(p_altBomDesig, '@@@@@')
			and  (b.assembly_type = wip_constants.manufacturing_bill or	--FP Bug 6502612
			      to_number(fnd_profile.value('WIP_SEE_ENG_ITEMS')) = wip_constants.yes ));  --FP Bug 6502612

        /******
        select a.organization_id, a.bill_sequence_id
          into l_cmnOrgID, l_cmnBillID
          from bom_bill_of_materials a, bom_bill_of_materials b
         where a.bill_sequence_id = b.common_bill_sequence_id
           and b.assembly_item_id = p_itemID
           and b.organization_id  = p_orgID
           and nvl(b.alternate_bom_designator, '@@@@@') = nvl(p_altBomDesig, '@@@@@');
         ******/
       else
        select a.organization_id, a.bill_sequence_id
          into l_cmnOrgID, l_cmnBillID
          from bom_bill_of_materials a, bom_bill_of_materials b
         where a.bill_sequence_id = b.common_bill_sequence_id
           and b.assembly_item_id = p_itemID
           and b.organization_id  = p_orgID
           and (   nvl(b.alternate_bom_designator, '@@@@@') = nvl(p_altBomDesig , '@@@@@')
                or
                   (    b.alternate_bom_designator is null
                    and
                        not exists (select 'x'
                                      from bom_bill_of_materials c
                                     where c.assembly_item_id = p_itemID
                                       and c.organization_id = p_orgID
                                       and c.alternate_bom_designator = p_altBomDesig)
                   )
               );
      end if;
    exception
      when no_data_found then
        x_returnStatus := fnd_api.g_ret_sts_success;
        x_compTbl := system.wip_component_tbl_t();

        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.explodeRequirements',
                               p_procReturnStatus => x_returnStatus,
                               p_msg => 'no bom for this item!',
                               x_returnStatus => l_returnStatus); --discard logging return status
        end if;

        if(fnd_api.to_boolean(p_endDebug)) then
          wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
        end if;
        return;
    end;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('cmn bill id: ' || l_cmnBillID,l_returnStatus);
      wip_logger.log('cmn org id: ' || l_cmnOrgID,l_returnStatus);
    end if;

    begin
      select bp.inherit_phantom_op_seq,
             bom_explosion_temp_s.nextval,
             msi.bom_item_type,
             bp.maximum_bom_level
        into l_inheritPhOpSeq,
             l_grpID,
             l_bomItemType,
             l_maxBomLevel
        from bom_parameters bp, mtl_system_items_b msi
       where bp.organization_id = p_orgID
         and bp.organization_id = msi.organization_id
         and msi.inventory_item_id = p_itemID;
    exception
      when no_data_found then --assume bom parameters not defined. the item_id should be valid.
        fnd_message.set_name('BOM', 'BOM_PARAMETER_SETUP');
        fnd_msg_pub.add;
        l_errMsg := 'no bom parameters';
        raise fnd_api.g_exc_unexpected_error;
    end;

    /* Fix for bug 5383135. To honour the profile 'WIP:Exclude ECOs',
       pass its value to bom exploder */
    wip_common.Get_Released_Revs_Type_Meaning (l_released_revs_type,
                                               l_released_revs_meaning
                                               );

    /* Fix for bug 4771231. Get bill type(bom or eng bill) and pass it to
       bom exploder */

       select assembly_type into l_bom_or_eng_flag
         from bom_structures_b
        where assembly_item_id = p_itemID
          and organization_id = p_orgID
          and nvl(alternate_bom_designator, '@@@@@') = NVL(p_altBomDesig, '@@@@@'); /* Bug 5139022 Added NVL functions */

    --explode the bom. This API has a few shortcomings. Namely:
    --   it will not prune exploded components for subassemblies
    --   it will not set phantom component quantities properly
    --   it will not set phantom component op_seq's correctly
    --This is why we need the first loop.
/* Modified following call for bug#3423629. Pass p_bomRevDate as revision date
   instead of p_txnDate */
    bompexpl.exploder_userexit(org_id => p_orgID,
                               grp_id => l_grpID,
                               rev_date => to_char(p_bomRevDate, wip_constants.datetime_fmt),
                               explode_option => 2,
--                               order_by => 2,
                               levels_to_explode => l_maxBomLevel,
                               module => 5,
                               item_id => p_itemID,
                               bom_or_eng => l_bom_or_eng_flag,
                               err_msg => l_msgData,
                               error_code => l_errCode,
                               alt_desg => p_altBomDesig,
                               unit_number => p_unitNumber,  /* Fix for bug 5332615 */
                               release_option => l_released_revs_type, /* Fix for bug 5383135 */
                               impl_flag => p_implFlag); /* Fix for bug 5383135 */

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log(l_errCode,l_returnStatus);
    end if;
    if(l_errCode <> 0) then
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_msgData);
      fnd_msg_pub.add;
      l_errMsg := 'BOM exploder failed';
      raise fnd_api.g_exc_unexpected_error;
    end if;

    /* Fix for Bug 5646262. Added code to check if there are any LOOP in BOM */
    select count(1) into l_errCode from bom_explosion_temp
    where group_id = l_grpID and loop_flag=1;

    if(l_errCode <> 0) then
      fnd_message.set_name('WIP', 'WIP_BOM_LOOP');
      fnd_msg_pub.add;
      l_errMsg := 'Loop In BOM Encountered';
      raise fnd_api.g_exc_unexpected_error;
    end if;

    --don't explode, just delete all exploded components
    if(l_bomItemType in (wip_constants.option_class_type, wip_constants.model_type)) then
       delete bom_explosion_temp
        where group_id = l_grpID
          and plan_level > 2;
    else
      --first pass: update quantities and delete components
      open c_components(v_cmnOrgID => l_cmnOrgID, v_orgID => p_orgID, v_grpID => l_grpID);
      loop
        fetch c_components into l_compRec;
        <<start_loop_processing>>
        if(c_components%NOTFOUND) then
          close c_components;
          exit;
        end if;
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('process item ' || l_compRec.itemID || ' w/compCode= ' || l_compRec.compCode,l_returnStatus);
        end if;
        --The op seq of a phantom component should be the op seq of it's ancestor that's on the assy_item's bom,
        --or in other words, a direct child of the assembly. If this check is not done, multiple levels of nesting
        --will cause problems.
        if(l_inheritPhOpSeq = wip_constants.yes) then
          if(l_compRec.bomLevel = 2) then
            l_opSeqNum := l_compRec.opSeqNum;
            if (l_logLevel <= wip_constants.full_logging) then
              wip_logger.log('--set all descendant op seqs to' || l_opSeqNum,l_returnStatus);
            end if;
          end if;
        else
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('--retain op seqs',l_returnStatus);
          end if;
          l_opSeqNum := null;
        end if;

        if(l_compRec.wipSupplyType = wip_constants.phantom) then --if item is a phantom
          if(l_inheritPhOpSeq = wip_constants.no) then
            select operation_seq_num
              into l_opSeqNum
              from bom_explosion_temp
             where rowid = l_compRec.beRowID;


            update bom_explosion_temp
               set operation_seq_num = l_opSeqNum
             where group_id = l_grpID
               and operation_seq_num = 1
               and component_code like l_compRec.compCode || '-%';

            --only needed to use l_opSeqNum for the above update
            l_opSeqNum := null;
          end if;
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('--item is a phantom',l_returnStatus);
          end if;
          --update all the descendants quantity to reflect the phantom parent
          if(l_inheritPhOpSeq = wip_constants.yes and l_compRec.bomLevel = 1) then
            l_opSeqNum := l_compRec.opSeqNum;
          else
            l_opSeqNum := null;
          end if;
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('--updated qty by ' || l_compRec.priQty,l_returnStatus);
            wip_logger.log('shrinkage_rate: ' || l_compRec.shrinkageRate,l_returnStatus);
          end if;

          /*For Component Yield Enhancement(Bug 4369064)
            *Keep component_quantity free from component yield
            *For phantoms, recalcuate component_yield_factor by multiplying it with child yield */
          /* Fix for bug 5221306 lot basis was taken care for children of phantom
             Added decode in basis_type of component */
          update bom_explosion_temp
             set component_quantity = (component_quantity * decode (basis_type , wip_constants.lot_based_mtl,1,l_compRec.priQty) ) / (1 - l_compRec.shrinkageRate),
             /* For phantoms, recalcuate component_yield_factor by multiplying it with child yield  only for components
             having basis_type as item. Bug fix 5524603. */
                 component_yield_factor = decode(basis_type,wip_constants.lot_based_mtl,component_yield_factor,component_yield_factor * l_compRec.compYield),
                 operation_seq_num = nvl(l_opSeqNum, operation_seq_num)
             where group_id = l_grpID
             and component_code like l_compRec.compCode || '-%';
        else
          --delete all descendants of the subassembly
          delete bom_explosion_temp
           where group_id = l_grpID
             and component_code like l_compRec.compCode || '-%';

          l_bomLevel := l_compRec.bomLevel;
          --this loop skips processing for all the 'poisonous' descendants of the subassembly
          loop
            fetch c_components into l_compRec;
            if(c_components%NOTFOUND) then
              goto start_loop_processing; --outer loop will check notfound and exit the outer loop
            end if;
            if(l_compRec.bomLevel <= l_bomLevel) then
              --found an item that is not a descendant of the sub assy. reset the comp code and exit the inner loop
              --if the item is a phantom and has any children w/op seq 1 and not inheriting op-seqs, update the op seq
              --to the parent's. we need to do a db sub-query b/c the phantom op may be out of sync w/the cursor if there
              --are consecutive levels with op_seq = 1. i.e. Assy -> Ph(20) -> Ph(1) -> Comp(1). In this case the cursor record
              --for the phantom item would have an op-seq of 1, while the db will have an op_seq of 20. However, we can not
              --blindly update all descendant's b/c one of the levels may not have an op-seq of one,
              --e.g. Assy -> Ph(20) -> Ph(1) -> Ph(10) -> Comp(1). In this case, we would want to set the comp's op seq to 10, not 20.
              goto start_loop_processing; --outer loop will check notfound, but will continue processing since the attribute will be false
            end if;
            if (l_logLevel <= wip_constants.full_logging) then
              wip_logger.log('--skipping item' || l_compRec.compCode,l_returnStatus);
            end if;
          end loop;
        end if;
      end loop;
    end if;

    x_compTbl := system.wip_component_tbl_t();
    x_compTbl.extend(g_compTblExtendSize);

    --second pass: select all the remaining records into a pl/sql table
    for l_compRec in c_groupedComponents(v_cmnOrgID => l_cmnOrgID, v_orgID => p_orgID, v_grpID => l_grpID) loop
      if(p_qty > 0) then
        if(l_compRec.priQty > 0) then
          l_txnActionID := wip_constants.isscomp_action;
        else
          l_txnActionID := wip_constants.issnegc_action;
        end if;
      else
        if(l_compRec.priQty > 0) then
          l_txnActionID := wip_constants.retcomp_action;
        else
          l_txnActionID := wip_constants.retnegc_action;
        end if;
      end if;


      if(floor(l_extendCount/g_compTblExtendSize) = 1) then
        x_compTbl.extend(g_compTblExtendSize);
        l_extendCount := 0;
      end if;
      if(l_compRec.wipSupplyType = wip_constants.phantom) then
        --phantom is supposedly an implicit conversion from a supply to a demand. Thus we need to factor by the
        --'shrinkage rate' item attribute.
        l_compRec.priQty := l_compRec.priQty / (1 - l_compRec.shrinkageRate);
      end if;

      if(l_compRec.revControlCode = wip_constants.revision_controlled) then
        bom_revisions.get_revision(examine_type => 'ALL',
                                   eco_status => l_released_revs_meaning,/*Added for bug fix: 7721526 (FP of bug 7553760)*/
                                   org_id => p_orgID,
                                   item_id => l_compRec.itemID,
                                   --rev_date => p_txnDate,
                                   rev_date => p_bomRevDate, --8830234 (FP of 8810786): passing BOM Revision Date instead of Transaction Date
                                   itm_rev => l_revision);
      else
        l_revision := null;
      end if;
      l_locID := l_compRec.supplyLocID;
      l_projectID := null;
      l_taskID := null;

      --if a project is provided, get the proj/task locator if necessary. If no
      --project/task provided, still call this API to make sure the BOM locator
      --is the common locator.
      l_success := pjm_project_locator.get_component_projectSupply(p_organization_id => p_orgID,
                                                                   p_project_id => p_projectID,
                                                                   p_task_id => p_taskID,
                                                                   p_wip_entity_id => null,--unused
                                                                   p_supply_sub => l_compRec.supplySubinv,
                                                                   p_supply_loc_id => l_locID,
                                                                   p_item_id => l_compRec.itemID,
                                                                   p_org_loc_control => null); --unused
      if(not l_success) then
        l_errMsg := 'PJM locator logic failed';
        raise fnd_api.g_exc_unexpected_error;
      end if;

      --if we are using a project/task locator, then set the project/task IDs
      if(p_projectID is not null and
         l_compRec.pegFlag in (wip_constants.peg_hard, wip_constants.peg_end_assm_hard)) then
        l_projectID := p_projectID;
        l_taskID := p_taskID;
      end if;

      -- locator id could be not null for item not under locator control. We should check whether
      -- it is under locator ctl. For bug 3885878
      if(l_compRec.supplySubinv is not null) then
        wip_globals.get_locator_control(p_orgID,
                                      l_compRec.supplySubinv,
                                      l_compRec.itemID,
                                      l_returnStatus,
                                      l_msgCount,
                                      l_msgData,
                                      l_locatorControl);
        if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
          l_errMsg := substr(l_msgData, 1, 240);
          raise fnd_api.g_exc_unexpected_error;
        end if;

        if ( l_locatorControl = 1 ) then
          l_locID := null;
        end if;
      end if;

       /* LBM Project */

       -- set multiplication factor for lot based component
          if( l_compRec.basis_type = WIP_CONSTANTS.LOT_BASED_MTL) then
             if  ((l_txnActionID = wip_constants.retcomp_action) or
                  (l_txnActionID = wip_constants.retnegc_action)) then
               multiple_factor := -1;
             else
               multiple_factor := 1;
             end if;
          else
              multiple_factor := p_qty ;
          end if;

       /* LBM Project */


      x_compTbl(l_index) := system.wip_component_obj_t(
                              operation_seq_num => l_compRec.opSeqNum,
                              inventory_item_id => l_compRec.itemID,
                              item_name => l_compRec.itemName,
                              --adjust for assy qty
                              primary_quantity => l_compRec.priQty * multiple_factor, /* LBM Project */
                              primary_uom_code => l_compRec.priUomCode,
                              supply_subinventory => l_compRec.supplySubinv,
                              supply_locator_id => l_locID,
                              wip_supply_type => l_compRec.wipSupplyType,
                              transaction_action_id => l_txnActionID,
                              mtl_transactions_enabled_flag => l_compRec.txnsEnabledFlag,
                              serial_number_control_code => l_compRec.serialNumControlCode,
                              lot_control_code => l_compRec.lotControlCode,
                              revision => l_revision,
                              first_lot_index => null,
                              last_lot_index => null,
                              first_serial_index => null,
                              last_serial_index => null,
                              generic_id => null,
                              department_id => null,
                              restrict_subinventories_code => l_compRec.restrictSubs,
                              restrict_locators_code => l_compRec.restrictLocs,
                              project_id => l_projectID,
                              task_id => l_taskID,
                              component_sequence_id => l_compRec.componentSeqID,
                              completion_transaction_id => null,
                              item_description => l_compRec.itemDesc,
                              locator_name => l_compRec.locatorName,
                              revision_qty_control_code => l_compRec.revControlCode,
                              location_control_code =>l_compRec.locControlCode,
                              component_yield_factor => l_compRec.compYield,/*For Component Yield Enhancement(Bug 4369064) */
                              basis_type => l_compRec.basis_type,
                              locator_project_id => null,
                              locator_task_id => null
                              );
      l_index := l_index + 1;
      l_extendCount := l_extendCount + 1;
      /*Bug 5255566 (FP Bug 5504661) */
          <<end_of_groupcomp_loop>>
          null;
    end loop;

    --trim any trailing null entries
    x_compTbl.trim(g_compTblExtendSize - l_extendCount);

    --finally bom doesn't want us to leave anything in there temp table. delete the rows.
    delete bom_explosion_temp
     where group_id = l_grpID;
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.explodeRequirements',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;

    if(fnd_api.to_boolean(p_endDebug)) then
      wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
    end if;

  exception
    when fnd_api.g_exc_unexpected_error then
      rollback to wipbflpb30;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.explodeRequirements',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;

      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;

    when others then
      rollback to wipbflpb30;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
      fnd_message.set_token('ERROR_TEXT', SQLERRM);
      fnd_msg_pub.add;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.explodeRequirements',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;

      if(fnd_api.to_boolean(p_endDebug)) then
        wip_logger.cleanUp(x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end explodeRequirements;


  function findTxnTypeID(p_txnActionID IN NUMBER) return NUMBER is begin
    if(p_txnActionID = wip_constants.isscomp_action) then
      return wip_constants.isscomp_type;
    elsif(p_txnActionID = wip_constants.issnegc_action) then
      return wip_constants.issnegc_type;
    elsif(p_txnActionID = wip_constants.retcomp_action) then
      return wip_constants.retcomp_type;
    elsif(p_txnActionID = wip_constants.retnegc_action) then
      return wip_constants.retnegc_type;
    end if;
  end findTxnTypeID;

PROCEDURE backflush(p_wipEntityID       IN        NUMBER,
                    p_orgID             IN        NUMBER,
                    p_primaryQty        IN        NUMBER,
                    p_txnDate           IN        DATE,
                    p_txnHdrID          IN        NUMBER,
                    p_batchID           IN        NUMBER,
                    p_txnType           IN        NUMBER,
                    p_entityType        IN        NUMBER,
                    p_tblName           IN        VARCHAR2,
                    p_lineID            IN        NUMBER:= NULL,
                    p_fmOp              IN        NUMBER:= NULL,
                    p_fmStep            IN        NUMBER:= NULL,
                    p_toOp              IN        NUMBER:= NULL,
                    p_toStep            IN        NUMBER:= NULL,
                    p_ocQty             IN        NUMBER:= NULL,
                    p_childMovTxnID     IN        NUMBER:= NULL,
                    p_movTxnID          IN        NUMBER:= NULL,
                    p_cplTxnID          IN        NUMBER:= NULL,
                    p_batchSeq          IN        NUMBER:= NULL,
                    p_fmMoveProcessor   IN        NUMBER:= NULL,
                    p_lockFlag          IN        NUMBER:= NULL,
                    p_mtlTxnMode        IN        NUMBER,
                    p_reasonID          IN        NUMBER := null,
                    p_reference         IN        VARCHAR2 := null,
                    x_lotSerRequired   OUT NOCOPY NUMBER,
                    x_bfRequired       OUT NOCOPY NUMBER,
                    x_returnStatus     OUT NOCOPY VARCHAR2) IS

CURSOR c_repAssyPull IS
  SELECT repetitive_schedule_id scheID,
         primary_quantity primaryQty
    FROM wip_mtl_allocations_temp
   WHERE completion_transaction_id = p_cplTxnID;

CURSOR c_wmta (p_txn_id NUMBER) IS
  SELECT wmta.primary_quantity txn_qty,
         wmta.repetitive_schedule_id rep_id
    FROM wip_move_txn_interface wmti,
         wip_move_txn_allocations wmta
   WHERE wmti.organization_id = wmta.organization_id
     AND wmti.transaction_id  = wmta.transaction_id
     AND wmti.transaction_id = p_txn_id;

l_rsa            wip_movProc_priv.rsa_tbl_t;
l_params         wip_logger.param_tbl_t;
l_compTbl        system.wip_component_tbl_t:=NULL;
l_repAssyPull    c_repAssyPull%ROWTYPE;
l_wmta           c_wmta%ROWTYPE;
l_returnStatus   VARCHAR(1);
l_errMsg         VARCHAR2(240);
l_sche_count     NUMBER;
l_proc_status    NUMBER;
l_fm_op          NUMBER;
l_fm_step        NUMBER;
l_to_op          NUMBER;
l_to_step        NUMBER;
l_first_op       NUMBER;
l_last_op        NUMBER;
l_oc_txn_type    NUMBER;
l_first_bf_op    NUMBER;
l_last_bf_op     NUMBER;
l_bf_qty         NUMBER;
l_forward        NUMBER;
l_bf_count       NUMBER;
l_lot_ser_count  NUMBER;
l_lot_entry_type NUMBER;
l_batch_seq      NUMBER;
l_logLevel       NUMBER := fnd_log.g_current_runtime_level;
TVE_NO_MOVE_ALLOC CONSTANT NUMBER := -5;
TVE_OVERCOMPLETION_MISMATCH CONSTANT NUMBER:= -6;
BEGIN
  SAVEPOINT s_backflush;
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_wipEntityID';
    l_params(1).paramValue  :=  p_wipEntityID;
    l_params(2).paramName   := 'p_orgID';
    l_params(2).paramValue  :=  p_orgID;
    l_params(3).paramName   := 'p_primaryQty';
    l_params(3).paramValue  :=  p_primaryQty;
    l_params(4).paramName   := 'p_txnDate';
    l_params(4).paramValue  :=  p_txnDate;
    l_params(5).paramName   := 'p_txnHdrID';
    l_params(5).paramValue  :=  p_txnHdrID;
    l_params(6).paramName   := 'p_batchID';
    l_params(6).paramValue  :=  p_batchID;
    l_params(7).paramName   := 'p_txnType';
    l_params(7).paramValue  :=  p_txnType;
    l_params(8).paramName   := 'p_entityType';
    l_params(8).paramValue  :=  p_entityType;
    l_params(9).paramName   := 'p_tblName';
    l_params(9).paramValue  :=  p_tblName;
    l_params(10).paramName  := 'p_lineID';
    l_params(10).paramValue :=  p_lineID;
    l_params(11).paramName  := 'p_fmOp';
    l_params(11).paramValue :=  p_fmOp;
    l_params(12).paramName  := 'p_fmStep';
    l_params(12).paramValue :=  p_fmStep;
    l_params(13).paramName  := 'p_toOp';
    l_params(13).paramValue :=  p_toOp;
    l_params(14).paramName  := 'p_toStep';
    l_params(14).paramValue :=  p_toStep;
    l_params(15).paramName  := 'p_ocQty';
    l_params(15).paramValue :=  p_ocQty;
    l_params(16).paramName  := 'p_childMovTxnID';
    l_params(16).paramValue :=  p_childMovTxnID;
    l_params(17).paramName  := 'p_movTxnID';
    l_params(17).paramValue :=  p_movTxnID;
    l_params(18).paramName  := 'p_cplTxnID';
    l_params(18).paramValue :=  p_cplTxnID;
    l_params(19).paramName  := 'p_batchSeq';
    l_params(19).paramValue :=  p_batchSeq;
    l_params(20).paramName  := 'p_mtlTxnMode';
    l_params(20).paramValue :=  p_mtlTxnMode;
    l_params(21).paramName  := 'p_fmMoveProcessor';
    l_params(21).paramValue :=  p_fmMoveProcessor;
    l_params(22).paramName   := 'p_lockFlag';
    l_params(22).paramValue  :=  p_lockFlag;
    l_params(23).paramName   := 'p_mtlTxnMode';
    l_params(23).paramValue  :=  p_mtlTxnMode;
    l_params(24).paramName   := 'p_reasonID';
    l_params(24).paramValue  :=  p_reasonID;
    l_params(25).paramName   := 'p_reference';
    l_params(25).paramValue  :=  p_reference;

    wip_logger.entryPoint(p_procName => 'wip_bflProc_priv.backflush',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;
  IF(p_batchSeq IS NULL) THEN
    l_batch_seq := WIP_CONSTANTS.COMPONENT_BATCH_SEQ;
  ELSE
    l_batch_seq := p_batchSeq;
  END IF;

  IF(p_entityType = WIP_CONSTANTS.REPETITIVE) THEN
    SELECT MIN(wo.operation_seq_num),
           MAX(wo.operation_seq_num)
      INTO l_first_op,
           l_last_op
      FROM wip_operations wo,
           wip_repetitive_schedules wrs
     WHERE wrs.organization_id = wo.organization_id
       AND wrs.wip_entity_id = wo.wip_entity_id
       AND wrs.repetitive_schedule_id = wo.repetitive_schedule_id
       AND wrs.status_type in (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG)
       AND wrs.wip_entity_id = p_wipEntityID
       AND wrs.organization_id = p_orgID;
  ELSE -- Discrete and Lotbased jobs
    SELECT MIN(wo.operation_seq_num),
           MAX(wo.operation_seq_num)
      INTO l_first_op,
           l_last_op
      FROM wip_operations wo,
           wip_discrete_jobs wdj
     WHERE wdj.organization_id = wo.organization_id
       AND wdj.wip_entity_id = wo.wip_entity_id
       AND wdj.status_type in (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG)
       AND wdj.wip_entity_id = p_wipEntityID
       AND wdj.organization_id = p_orgID;
  END IF;

  IF(l_first_op IS NULL) THEN
    -- Routingless schedules
    l_first_op := 0;
  END IF;
  IF(l_last_op IS NULL) THEN
    -- Routingless schedules
    l_last_op := 1.1;
  END IF;

  IF(p_fmOp IS NULL OR p_fmStep IS NULL OR
     p_toOp IS NULL OR p_toStep IS NULL) THEN
    -- Call from WIP Completion form
    IF(p_txnType = WIP_CONSTANTS.COMP_TXN) THEN
      -- Ccmpletion transaction
      l_fm_op   := l_last_op;
      l_fm_step := WIP_CONSTANTS.TOMOVE;
      l_to_op   := NULL;
      l_to_step := NULL;
    ELSIF(p_txnType = WIP_CONSTANTS.RET_TXN) THEN
      -- Return transaction
      l_fm_op   := NULL;
      l_fm_step := NULL;
      l_to_op   := l_last_op;
      l_to_step := WIP_CONSTANTS.TOMOVE;
    END IF;
  ELSE -- call from WIP Move form
    l_fm_op   := p_fmOp;
    l_fm_step := p_fmStep;
    l_to_op   := p_toOp;
    l_to_step := p_toStep;
  END IF; -- Call from WIP Completion form

  -- Check if repetitive schedule
  IF(p_entityType = WIP_CONSTANTS.REPETITIVE) THEN -- Repetitive schedule
    -- Fixed bug 5056289.Basically, we should not rely on the fact that p_fmOp
    -- will be null if call from Completion form. We should also check
    -- p_fmMoveProcessor. Since move processor will also pass null for p_fmOp
    -- for assembly pull item.
    IF((p_fmOp IS NULL OR p_fmStep IS NULL OR
        p_toOp IS NULL OR p_toStep IS NULL) AND
       (p_fmMoveProcessor IS NULL OR
        p_fmMoveProcessor = WIP_CONSTANTS.NO)) THEN
      -- Call from WIP Completion form, so use the allocation information in
      -- wip_mtl_allocations_temp. There is no need to call schedule_alloc
      -- again.

      /*Backflush all assembly pull component*/
      FOR l_repAssyPull IN c_repAssyPull LOOP
        wip_bflProc_priv.processRequirements
               (p_wipEntityID   => p_wipEntityID,
                p_wipEntityType => p_entityType,
                p_repSchedID    => l_repAssyPull.scheID,
                p_repLineID     => p_lineID,
                p_cplTxnID      => p_cplTxnID,
                -- Fixed bug 5014211. Stamp move_transaction_id for assembly
                -- pull components so that we will have a link if component
                -- records fail inventory validation.
                p_movTxnID      => p_movTxnID,
                p_batchID       => p_batchID,
                p_orgID         => p_orgID,
                p_assyQty       => l_repAssyPull.primaryQty,
                p_txnDate       => p_txnDate,
                p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
                p_txnHdrID      => p_txnHdrID,
                p_firstOp       => -1,
                p_lastOP        => l_last_op,
                p_firstMoveOp   => null,
                p_lastMoveOp    => null,
                p_lockFlag      => p_lockFlag,
                p_batchSeq      => l_batch_seq,
                p_mergeMode     => fnd_api.g_true,
                p_reasonID      => p_reasonID,
                p_reference     => p_reference,
                p_initMsgList   => fnd_api.g_false,
                p_endDebug      => fnd_api.g_false,
                p_mtlTxnMode    => p_mtlTxnMode,
                x_compTbl       => l_compTbl,
                x_returnStatus  => l_returnStatus);

        IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
          l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

    ELSE
      IF(p_fmMoveProcessor = WIP_CONSTANTS.YES) THEN
        -- If call from move processor, no need to do schedule allocation again
        -- Instead, we should use the value in WMTA table.
        l_sche_count := 0;
        FOR l_wmta IN c_wmta (p_txn_id => p_movTxnID) LOOP
          l_sche_count := l_sche_count + 1;
          l_rsa(l_sche_count).scheID := l_wmta.rep_id;
          l_rsa(l_sche_count).scheQty := l_wmta.txn_qty;
        END LOOP;
      ELSIF(p_fmMoveProcessor IS NULL OR
            p_fmMoveProcessor = WIP_CONSTANTS.NO) THEN
        -- Check whether overcompletion transaction
        IF(p_ocQty IS NOT NULL) THEN
          l_oc_txn_type := WIP_CONSTANTS.PARENT_TXN;
        ELSE
          l_oc_txn_type := WIP_CONSTANTS.NORMAL_TXN;
        END IF;
        wip_movProc_priv.schedule_alloc(p_org_id         => p_orgID,
                                        p_wip_id         => p_wipEntityID,
                                        p_line_id        => p_lineID,
                                        p_quantity       => p_primaryQty,
                                        p_fm_op          => l_fm_op,
                                        p_fm_step        => l_fm_step,
                                        p_to_op          => l_to_op,
                                        p_to_step        => l_to_step,
                                        p_oc_txn_type    => l_oc_txn_type,
                                        p_txnType        => p_txnType,
                                        p_fm_form        => WIP_CONSTANTS.YES,
                                        p_comp_alloc     => WIP_CONSTANTS.NO,
                                        p_txn_date       => p_txndate, /* bug 5373061 */
                                        x_proc_status    => l_proc_status,
                                        x_sche_count     => l_sche_count,
                                        x_rsa            => l_rsa,
                                        x_returnStatus   => l_returnStatus);

        IF (l_logLevel <= wip_constants.full_logging) THEN
          wip_logger.log(p_msg          => 'l_proc_status = ' || l_proc_status,
                         x_returnStatus => l_returnStatus);
          wip_logger.log(p_msg          => 'l_sche_count = ' || l_sche_count,
                         x_returnStatus => l_returnStatus);
        END IF;

        IF(l_proc_status = TVE_OVERCOMPLETION_MISMATCH) THEN
          fnd_message.set_name('WIP', 'WIP_OVERCOMPLETION_MISMATCH');
          fnd_msg_pub.add;
          l_errMsg := 'parent txn is not really overcompletion txn';
          raise fnd_api.g_exc_unexpected_error;
        ELSIF(l_proc_status = TVE_NO_MOVE_ALLOC) THEN
          fnd_message.set_name('WIP', 'WIP_LESS_OR_EQUAL');
          fnd_message.set_token('ENTITY1', 'transaction quantity');
          fnd_message.set_token('ENTITY2', 'quantity available to move');
          fnd_msg_pub.add;
          l_errMsg := 'available qty is not enough to fullfill move txn';
          raise fnd_api.g_exc_unexpected_error;
        ELSIF(l_proc_status = WIP_CONSTANTS.ERROR) THEN
          l_errMsg := 'wip_movProc_priv.schedule_alloc failed';
          raise fnd_api.g_exc_unexpected_error;
        END IF; -- check l_proc_status
      END IF; -- check p_fmMoveProcessor

      IF (l_logLevel <= wip_constants.full_logging) THEN
        FOR i IN 1..l_sche_count LOOP
          wip_logger.log(p_msg          => 'sche_id = ' || l_rsa(i).scheID,
                         x_returnStatus => l_returnStatus);
          wip_logger.log(p_msg          => 'txn_qty = ' || l_rsa(i).scheQty,
                         x_returnStatus => l_returnStatus);
        END LOOP;
      END IF;
      -- Check whether call from Completion form or not

      IF(l_fm_op IS NOT NULL AND l_to_op IS NOT NULL) THEN

        -- set l_first_bf_op and l_last_bf_op back to -1
        l_first_bf_op := -1;
        l_last_bf_op  := -1;

        -- Call bf_require to derive first_bf_op, last_bf_op, and bf_qty
        -- before call wip_bflProc_priv.processRequirements for
        -- Operation Pull components
        wma_move.bf_require(p_jobID        => p_wipEntityID,
                            p_fm_op        => l_fm_op,
                            p_fm_step      => l_fm_step,
                            p_to_op        => l_to_op,
                            p_to_step      => l_to_step,
                            p_moveQty      => p_primaryQty,
                            x_first_bf_op  => l_first_bf_op,
                            x_last_bf_op   => l_last_bf_op,
                            x_bf_qty       => l_bf_qty,
                            x_returnStatus => l_returnStatus,
                            x_errMessage   => l_errMsg);
        IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE', l_errMsg);
          fnd_msg_pub.add;
          raise fnd_api.g_exc_unexpected_error;
        END IF;

        IF(l_first_bf_op <> -1) THEN
          -- check forward transactions
          IF(l_bf_qty > 0) THEN
            l_forward := 1;
          ELSE
            l_forward := -1;
          END IF;
          FOR i IN 1..l_sche_count LOOP
            /**
             * Call backflush processor to insert record into MMTT
             * for each schedule found in l_rsa.
             * This is only for operation pull components.
             **/
            wip_bflProc_priv.processRequirements
             (p_wipEntityID   => p_wipEntityID,
              p_wipEntityType => p_entityType,
              p_repSchedID    => l_rsa(i).scheID,
              p_repLineID     => p_lineID,
              p_cplTxnID      => null,
              p_movTxnID      => p_movTxnID,
              p_batchID       => p_batchID,
              p_orgID         => p_orgID,
              p_assyQty       => l_rsa(i).scheQty * l_forward,
              p_txnDate       => p_txnDate,
              p_wipSupplyType => WIP_CONSTANTS.OP_PULL,
              p_txnHdrID      => p_txnHdrID,
              p_firstOp       => l_first_bf_op,
              p_lastOP        => l_last_bf_op,
              p_firstMoveOp   => l_fm_op,
              p_lastMoveOp    => l_to_op,
              p_lockFlag      => p_lockFlag,
              p_batchSeq      => l_batch_seq,
              p_mergeMode     => fnd_api.g_true,
              p_reasonID      => p_reasonID,
              p_reference     => p_reference,
              p_initMsgList   => fnd_api.g_false,
              p_endDebug      => fnd_api.g_false,
              p_mtlTxnMode    => p_mtlTxnMode,
              x_compTbl       => l_compTbl,
              x_returnStatus  => l_returnStatus);

            IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
              l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
              raise fnd_api.g_exc_unexpected_error;
            END IF;
          END LOOP;
        END IF; -- l_first_bf_op <> -1

        -- Call assy_pull_bf to derive first_bf_op, last_bf_op,
        -- and bf_qty before call wip_bflProc_priv.processRequirements
        -- for Assembly Pull components. This is only for Scrap txns

        -- set l_first_bf_op and l_last_bf_op back to -1
        l_first_bf_op := -1;
        l_last_bf_op  := -1;

        wma_move.assy_pull_bf(p_jobID        => p_wipEntityID,
                              p_fm_op        => l_fm_op,
                              p_fm_step      => l_fm_step,
                              p_to_op        => l_to_op,
                              p_to_step      => l_to_step,
                              p_moveQty      => p_primaryQty,
                              x_first_bf_op  => l_first_bf_op,
                              x_last_bf_op   => l_last_bf_op,
                              x_bf_qty       => l_bf_qty,
                              x_returnStatus => l_returnStatus,
                              x_errMessage   => l_errMsg);

        IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE', l_errMsg);
          fnd_msg_pub.add;
          raise fnd_api.g_exc_unexpected_error;
        END IF;

        IF(l_first_bf_op <> -1) THEN
          -- check forward transactions
          IF(l_bf_qty > 0) THEN
            l_forward := 1;
          ELSE
            l_forward := -1;
          END IF;
          FOR i IN 1..l_sche_count LOOP
            /**
             * Call backflush processor to insert record into MMTT
             * for each schedule found in l_rsa
             * This is only for assembly pull components.
             **/
            wip_bflProc_priv.processRequirements
             (p_wipEntityID   => p_wipEntityID,
              p_wipEntityType => p_entityType,
              p_repSchedID    => l_rsa(i).scheID,
              p_repLineID     => p_lineID,
              p_cplTxnID      => null,
              p_movTxnID      => p_movTxnID,
              p_batchID       => p_batchID,
              p_orgID         => p_orgID,
              p_assyQty       => l_rsa(i).scheQty * l_forward,
              p_txnDate       => p_txnDate,
              p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
              p_txnHdrID      => p_txnHdrID,
              p_firstOp       => l_first_bf_op,
              p_lastOP        => l_last_bf_op,
              p_firstMoveOp   => l_fm_op,
              p_lastMoveOp    => l_to_op,
              p_lockFlag      => p_lockFlag,
              p_batchSeq      => l_batch_seq,
              p_mergeMode     => fnd_api.g_true,
              p_reasonID      => p_reasonID,
              p_reference     => p_reference,
              p_initMsgList   => fnd_api.g_false,
              p_endDebug      => fnd_api.g_false,
              p_mtlTxnMode    => p_mtlTxnMode,
              x_compTbl       => l_compTbl,
              x_returnStatus  => l_returnStatus);

            IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
              l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
              raise fnd_api.g_exc_unexpected_error;
            END IF;
          END LOOP;
        END IF; -- l_first_bf_op <> -1
      END IF; -- call from Move form

      -- only do schedule allocation for completion if not call from move
      -- processor
      IF(p_cplTxnID IS NOT NULL AND
         (p_txnType = WIP_CONSTANTS.COMP_TXN OR
          p_txnType = WIP_CONSTANTS.RET_TXN)) THEN
        IF(p_fmMoveProcessor = WIP_CONSTANTS.YES) THEN
          -- If call from move processor, no need to do schedule allocation
          -- again Instead, we should use the value in WMTA table.
          l_sche_count := 0;
          FOR l_wmta IN c_wmta (p_txn_id => p_movTxnID) LOOP
            l_sche_count := l_sche_count + 1;
            l_rsa(l_sche_count).scheID := l_wmta.rep_id;
            l_rsa(l_sche_count).scheQty := l_wmta.txn_qty;
          END LOOP;
        ELSIF(p_fmMoveProcessor IS NULL OR
              p_fmMoveProcessor = WIP_CONSTANTS.NO) THEN
          wip_movProc_priv.schedule_alloc(
            p_org_id         => p_orgID,
            p_wip_id         => p_wipEntityID,
            p_line_id        => p_lineID,
            p_quantity       => p_primaryQty,
            p_fm_op          => l_fm_op,
            p_fm_step        => l_fm_step,
            p_to_op          => l_to_op,
            p_to_step        => l_to_step,
            p_oc_txn_type    => l_oc_txn_type,
            p_txnType        => p_txnType,
            p_fm_form        => WIP_CONSTANTS.YES,
            p_comp_alloc     => WIP_CONSTANTS.YES,
            p_txn_date       => p_txndate, /* bug 5373061 */
            x_proc_status    => l_proc_status,
            x_sche_count     => l_sche_count,
            x_rsa            => l_rsa,
            x_returnStatus   => l_returnStatus);

          IF (l_logLevel <= wip_constants.full_logging) THEN
            wip_logger.log(p_msg          => 'l_proc_status = ' ||
                                              l_proc_status,
                           x_returnStatus => l_returnStatus);
            wip_logger.log(p_msg          => 'l_sche_count = ' ||
                                              l_sche_count,
                          x_returnStatus => l_returnStatus);
          END IF;

          IF(l_proc_status = TVE_OVERCOMPLETION_MISMATCH) THEN
            fnd_message.set_name('WIP', 'WIP_OVERCOMPLETION_MISMATCH');
            fnd_msg_pub.add;
            l_errMsg := 'parent txn is not really overcompletion txn';
            raise fnd_api.g_exc_unexpected_error;
          ELSIF(l_proc_status = TVE_NO_MOVE_ALLOC) THEN
            fnd_message.set_name('WIP', 'WIP_LESS_OR_EQUAL');
            fnd_message.set_token('ENTITY1', 'transaction quantity');
            fnd_message.set_token('ENTITY2', 'quantity available to move');
            fnd_msg_pub.add;
            l_errMsg := 'available qty is not enough to fullfill move txn';
            raise fnd_api.g_exc_unexpected_error;
          ELSIF(l_proc_status = WIP_CONSTANTS.ERROR) THEN
            l_errMsg := 'wip_movProc_priv.schedule_alloc failed';
            raise fnd_api.g_exc_unexpected_error;
          END IF; -- check l_proc_status
        END IF; -- check p_fmMoveProcessor

        IF (l_logLevel <= wip_constants.full_logging) THEN
          FOR i IN 1..l_sche_count LOOP
            wip_logger.log(p_msg          => 'sche_id = ' || l_rsa(i).scheID,
                           x_returnStatus => l_returnStatus);
            wip_logger.log(p_msg          => 'txn_qty = ' || l_rsa(i).scheQty,
                           x_returnStatus => l_returnStatus);
          END LOOP;
        END IF;

        -- If Completion or Return txns, we have to backflush Assembly
        -- pull components too
        IF(p_txnType = WIP_CONSTANTS.COMP_TXN) THEN
          l_forward := 1;
        ELSE
          l_forward := -1;
        END IF;

        FOR i IN 1..l_sche_count LOOP
          /**
           * Call backflush processor to insert record into MMTT
           * for each schedule found in l_rsa
           * This is only for assembly pull components(Completion/Return).
           **/
          wip_bflProc_priv.processRequirements
             (p_wipEntityID   => p_wipEntityID,
              p_wipEntityType => p_entityType,
              p_repSchedID    => l_rsa(i).scheID,
              p_repLineID     => p_lineID,
              p_cplTxnID      => p_cplTxnID,
              -- Fixed bug 5014211. Stamp move_transaction_id for assembly
              -- pull components so that we will have a link if component
              -- records fail inventory validation.
              p_movTxnID      => p_movTxnID,
              p_batchID       => p_batchID,
              p_orgID         => p_orgID,
              p_assyQty       => l_rsa(i).scheQty * l_forward,
              p_txnDate       => p_txnDate,
              p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
              p_txnHdrID      => p_txnHdrID,
              p_firstOp       => -1,
              p_lastOP        => l_last_op,
              p_firstMoveOp   => null,
              p_lastMoveOp    => null,
              p_lockFlag      => p_lockFlag,
              p_batchSeq      => l_batch_seq,
              p_mergeMode     => fnd_api.g_true,
              p_reasonID      => p_reasonID,
              p_reference     => p_reference,
              p_initMsgList   => fnd_api.g_false,
              p_endDebug      => fnd_api.g_false,
              p_mtlTxnMode    => p_mtlTxnMode,
              x_compTbl       => l_compTbl,
              x_returnStatus  => l_returnStatus);

          IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
            l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
            raise fnd_api.g_exc_unexpected_error;
          END IF;
        END LOOP;
      END IF; -- Completion/return txns
    END IF; -- call from completion form
    -- Check whether overcompletion
    IF(p_childMovTxnID IS NOT NULL AND p_ocQty IS NOT NULL) THEN
      -- overmove/overcomplete
      IF(p_fmMoveProcessor = WIP_CONSTANTS.YES) THEN
        -- If call from move processor, no need to do schedule allocation
        -- again. Instead, we should use the value in WMTA table.
        l_sche_count := 0;
        FOR l_wmta IN c_wmta (p_txn_id => p_childMovTxnID) LOOP
          l_sche_count := l_sche_count + 1;
          l_rsa(l_sche_count).scheID := l_wmta.rep_id;
          l_rsa(l_sche_count).scheQty := l_wmta.txn_qty;
        END LOOP;
      ELSIF(p_fmMoveProcessor IS NULL OR
            p_fmMoveProcessor = WIP_CONSTANTS.NO) THEN
        l_oc_txn_type := WIP_CONSTANTS.CHILD_TXN;
        l_fm_op   := l_first_op;
        l_fm_step := WIP_CONSTANTS.QUEUE;
        IF(p_fmOp IS NULL OR p_fmStep IS NULL OR
           p_toOp IS NULL OR p_toStep IS NULL) THEN
          -- Call from Completion form
          l_to_op   := l_last_op;
          l_to_step := WIP_CONSTANTS.TOMOVE;
        ELSE -- Call from WIP Move or OSFM Move forms
          l_to_op   := p_fmOp;
          l_to_step := p_fmStep;
        END IF;
        wip_movProc_priv.schedule_alloc(
          p_org_id         => p_orgID,
          p_wip_id         => p_wipEntityID,
          p_line_id        => p_lineID,
          p_quantity       => p_ocQty,
          p_fm_op          => l_fm_op,
          p_fm_step        => l_fm_step,
          p_to_op          => l_to_op,
          p_to_step        => l_to_step,
          p_oc_txn_type    => l_oc_txn_type,
          p_txnType        => p_txnType,
          p_fm_form        => WIP_CONSTANTS.YES,
          p_comp_alloc     => WIP_CONSTANTS.NO,
          p_txn_date       => p_txndate, /* bug 5373061 */
          x_proc_status    => l_proc_status,
          x_sche_count     => l_sche_count,
          x_rsa            => l_rsa,
          x_returnStatus   => l_returnStatus);

        IF (l_logLevel <= wip_constants.full_logging) THEN
          wip_logger.log(p_msg          => 'l_proc_status = ' ||
                                            l_proc_status,
                         x_returnStatus => l_returnStatus);
          wip_logger.log(p_msg          => 'l_sche_count = ' ||
                                            l_sche_count,
                         x_returnStatus => l_returnStatus);
        END IF;

        IF(l_proc_status = TVE_OVERCOMPLETION_MISMATCH) THEN
          fnd_message.set_name('WIP', 'WIP_OVERCOMPLETION_MISMATCH');
          fnd_msg_pub.add;
          l_errMsg := 'parent txn is not really overcompletion txn';
          raise fnd_api.g_exc_unexpected_error;
        ELSIF(l_proc_status = TVE_NO_MOVE_ALLOC) THEN
          fnd_message.set_name('WIP', 'WIP_LESS_OR_EQUAL');
          fnd_message.set_token('ENTITY1', 'transaction quantity');
          fnd_message.set_token('ENTITY2', 'quantity available to move');
          fnd_msg_pub.add;
          l_errMsg := 'available qty is not enough to fullfill move txn';
          raise fnd_api.g_exc_unexpected_error;
        ELSIF(l_proc_status = WIP_CONSTANTS.ERROR) THEN
          l_errMsg := 'wip_movProc_priv.schedule_alloc failed';
          raise fnd_api.g_exc_unexpected_error;
        END IF; -- check l_proc_status
      END IF; -- check p_fmMoveProcessor

      IF (l_logLevel <= wip_constants.full_logging) THEN
        FOR i IN 1..l_sche_count LOOP
          wip_logger.log(p_msg          => 'sche_id = ' || l_rsa(i).scheID,
                         x_returnStatus => l_returnStatus);
          wip_logger.log(p_msg          => 'txn_qty = ' || l_rsa(i).scheQty,
                         x_returnStatus => l_returnStatus);
        END LOOP;
      END IF;
      -- Call bf_require to derive first_bf_op, last_bf_op, and bf_qty
      -- before call wip_bflProc_priv.processRequirements for
      -- Operation Pull components

      -- set l_first_bf_op and l_last_bf_op back to -1
      l_first_bf_op := -1;
      l_last_bf_op  := -1;
      wma_move.bf_require(p_jobID        => p_wipEntityID,
                          p_fm_op        => l_fm_op,
                          p_fm_step      => l_fm_step,
                          p_to_op        => l_to_op,
                          p_to_step      => l_to_step,
                          p_moveQty      => p_ocQty,
                          x_first_bf_op  => l_first_bf_op,
                          x_last_bf_op   => l_last_bf_op,
                          x_bf_qty       => l_bf_qty,
                          x_returnStatus => l_returnStatus,
                          x_errMessage   => l_errMsg);
      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_errMsg);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
      IF(l_first_bf_op <> -1) THEN
        -- check forward transactions
        IF(l_bf_qty > 0) THEN
          l_forward := 1;
        ELSE
          l_forward := -1;
        END IF;
        FOR i IN 1..l_sche_count LOOP
          /**
           * Call backflush processor to insert record into MMTT
           * for each schedule found in l_rsa.
           * This is only for operation pull components.
           **/
          wip_bflProc_priv.processRequirements
           (p_wipEntityID   => p_wipEntityID,
            p_wipEntityType => p_entityType,
            p_repSchedID    => l_rsa(i).scheID,
            p_repLineID     => p_lineID,
            p_cplTxnID      => null,
            p_movTxnID      => p_childMovTxnID,
            p_batchID       => p_batchID,
            p_orgID         => p_orgID,
            p_assyQty       => l_rsa(i).scheQty * l_forward,
            p_txnDate       => p_txnDate,
            p_wipSupplyType => WIP_CONSTANTS.OP_PULL,
            p_txnHdrID      => p_txnHdrID,
            p_firstOp       => l_first_bf_op,
            p_lastOP        => l_last_bf_op,
            p_firstMoveOp   => l_fm_op,
            p_lastMoveOp    => l_to_op,
            p_batchSeq      => l_batch_seq,
            p_lockFlag      => p_lockFlag,
            p_mergeMode     => fnd_api.g_true,
            p_reasonID      => p_reasonID,
            p_reference     => p_reference,
            p_initMsgList   => fnd_api.g_false,
            p_endDebug      => fnd_api.g_false,
            p_mtlTxnMode    => p_mtlTxnMode,
            x_compTbl       => l_compTbl,
            x_returnStatus  => l_returnStatus);

          IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
            l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
            raise fnd_api.g_exc_unexpected_error;
          END IF;
        END LOOP;
      END IF; -- l_first_bf_op <> -1
      -- Call assy_pull_bf to derive first_bf_op, last_bf_op,
      -- and bf_qty before call wip_bflProc_priv.processRequirements
      -- for Assembly Pull components. This is only for Scrap txns

      -- set l_first_bf_op and l_last_bf_op back to -1
      l_first_bf_op := -1;
      l_last_bf_op  := -1;

      wma_move.assy_pull_bf(p_jobID        => p_wipEntityID,
                            p_fm_op        => l_fm_op,
                            p_fm_step      => l_fm_step,
                            p_to_op        => l_to_op,
                            p_to_step      => l_to_step,
                            p_moveQty      => p_ocQty,
                            x_first_bf_op  => l_first_bf_op,
                            x_last_bf_op   => l_last_bf_op,
                            x_bf_qty       => l_bf_qty,
                            x_returnStatus => l_returnStatus,
                            x_errMessage   => l_errMsg);

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_errMsg);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      END IF;

      IF(l_first_bf_op <> -1) THEN
        -- check forward transactions
        IF(l_bf_qty > 0) THEN
          l_forward := 1;
        ELSE
          l_forward := -1;
        END IF;
        FOR i IN 1..l_sche_count LOOP
          /**
           * Call backflush processor to insert record into MMTT
           * for each schedule found in l_rsa
           * This is only for assembly pull components.
           **/
          wip_bflProc_priv.processRequirements
           (p_wipEntityID   => p_wipEntityID,
            p_wipEntityType => p_entityType,
            p_repSchedID    => l_rsa(i).scheID,
            p_repLineID     => p_lineID,
            p_cplTxnID      => null,
            p_movTxnID      => p_childMovTxnID,
            p_batchID       => p_batchID,
            p_orgID         => p_orgID,
            p_assyQty       => l_rsa(i).scheQty * l_forward,
            p_txnDate       => p_txnDate,
            p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
            p_txnHdrID      => p_txnHdrID,
            p_firstOp       => l_first_bf_op,
            p_lastOP        => l_last_bf_op,
            p_firstMoveOp   => l_fm_op,
            p_lastMoveOp    => l_to_op,
            p_lockFlag      => p_lockFlag,
            p_batchSeq      => l_batch_seq,
            p_mergeMode     => fnd_api.g_true,
            p_reasonID      => p_reasonID,
            p_reference     => p_reference,
            p_initMsgList   => fnd_api.g_false,
            p_endDebug      => fnd_api.g_false,
            p_mtlTxnMode    => p_mtlTxnMode,
            x_compTbl       => l_compTbl,
            x_returnStatus  => l_returnStatus);

          IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
            l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
            raise fnd_api.g_exc_unexpected_error;
          END IF;
        END LOOP;
      END IF; -- l_first_bf_op <> -1
    END IF;-- -- overmove/overcomplete
  ELSE -- Discrete and Lotbased Job
    -- Check whether call from Completion form or not
    IF(l_fm_op IS NOT NULL AND l_to_op IS NOT NULL) THEN

      -- set l_first_bf_op and l_last_bf_op back to -1
      l_first_bf_op := -1;
      l_last_bf_op  := -1;
      -- Call bf_require to derive first_bf_op, last_bf_op, and bf_qty
      -- before call wip_bflProc_priv.processRequirements for
      -- Operation Pull components
      wma_move.bf_require(p_jobID        => p_wipEntityID,
                          p_fm_op        => l_fm_op,
                          p_fm_step      => l_fm_step,
                          p_to_op        => l_to_op,
                          p_to_step      => l_to_step,
                          p_moveQty      => p_primaryQty,
                          x_first_bf_op  => l_first_bf_op,
                          x_last_bf_op   => l_last_bf_op,
                          x_bf_qty       => l_bf_qty,
                          x_returnStatus => l_returnStatus,
                          x_errMessage   => l_errMsg);
      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_errMsg);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
      IF(l_first_bf_op <> -1) THEN
        wip_bflProc_priv.processRequirements
         (p_wipEntityID   => p_wipEntityID,
          p_wipEntityType => p_entityType,
          p_repSchedID    => null,
          p_repLineID     => null,
          p_cplTxnID      => null,
          p_movTxnID      => p_movTxnID,
          p_batchID       => p_batchID,
          p_orgID         => p_orgID,
          p_assyQty       => l_bf_qty,
          p_txnDate       => p_txnDate,
          p_wipSupplyType => WIP_CONSTANTS.OP_PULL,
          p_txnHdrID      => p_txnHdrID,
          p_firstOp       => l_first_bf_op,
          p_lastOP        => l_last_bf_op,
          p_firstMoveOp   => l_fm_op,
          p_lastMoveOp    => l_to_op,
          p_batchSeq      => l_batch_seq,
          p_lockFlag      => p_lockFlag,
          p_mergeMode     => fnd_api.g_false,
          p_reasonID      => p_reasonID,
          p_reference     => p_reference,
          p_initMsgList   => fnd_api.g_false,
          p_endDebug      => fnd_api.g_false,
          p_mtlTxnMode    => p_mtlTxnMode,
          x_compTbl       => l_compTbl,
          x_returnStatus  => l_returnStatus);

        IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
          l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- l_first_bf_op <> -1

      -- Call assy_pull_bf to derive first_bf_op, last_bf_op,
      -- and bf_qty before call wip_bflProc_priv.processRequirements
      -- for Assembly Pull components. This is only for Scrap txns

      -- set l_first_bf_op and l_last_bf_op back to -1
      l_first_bf_op := -1;
      l_last_bf_op  := -1;

      wma_move.assy_pull_bf(p_jobID        => p_wipEntityID,
                            p_fm_op        => l_fm_op,
                            p_fm_step      => l_fm_step,
                            p_to_op        => l_to_op,
                            p_to_step      => l_to_step,
                            p_moveQty      => p_primaryQty,
                            x_first_bf_op  => l_first_bf_op,
                            x_last_bf_op   => l_last_bf_op,
                            x_bf_qty       => l_bf_qty,
                            x_returnStatus => l_returnStatus,
                            x_errMessage   => l_errMsg);

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_errMsg);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
      IF(l_first_bf_op <> -1) THEN

        /**
         * Call backflush processor to insert record into MMTT
         * for each schedule found in l_rsa
         * This is only for assembly pull components.
         **/
        wip_bflProc_priv.processRequirements
         (p_wipEntityID   => p_wipEntityID,
          p_wipEntityType => p_entityType,
          p_repSchedID    => null,
          p_repLineID     => null,
          p_cplTxnID      => null,
          p_movTxnID      => p_movTxnID,
          p_batchID       => p_batchID,
          p_orgID         => p_orgID,
          p_assyQty       => l_bf_qty,
          p_txnDate       => p_txnDate,
          p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
          p_txnHdrID      => p_txnHdrID,
          p_firstOp       => l_first_bf_op,
          p_lastOP        => l_last_bf_op,
          p_firstMoveOp   => l_fm_op,
          p_lastMoveOp    => l_to_op,
          p_batchSeq      => l_batch_seq,
          p_lockFlag      => p_lockFlag,
          p_mergeMode     => fnd_api.g_false,
          p_reasonID      => p_reasonID,
          p_reference     => p_reference,
          p_initMsgList   => fnd_api.g_false,
          p_endDebug      => fnd_api.g_false,
          p_mtlTxnMode    => p_mtlTxnMode,
          x_compTbl       => l_compTbl,
          x_returnStatus  => l_returnStatus);

        IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
          l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- l_first_bf_op <> -1
    END IF; -- call from Move form

    IF(p_cplTxnID IS NOT NULL AND
       (p_txnType = WIP_CONSTANTS.COMP_TXN OR
        p_txnType = WIP_CONSTANTS.RET_TXN)) THEN

      IF(p_txnType = WIP_CONSTANTS.COMP_TXN) THEN
        l_bf_qty := p_primaryQty;
      ELSIF(p_txnType = WIP_CONSTANTS.RET_TXN) THEN
        l_bf_qty := -1 * p_primaryQty;
      END IF;
      wip_bflProc_priv.processRequirements
       (p_wipEntityID   => p_wipEntityID,
        p_wipEntityType => p_entityType,
        p_repSchedID    => null,
        p_repLineID     => null,
        p_cplTxnID      => p_cplTxnID,
        -- Fixed bug 5014211. Stamp move_transaction_id for assembly
        -- pull components so that we will have a link if component
        -- records fail inventory validation.
        p_movTxnID      => p_movTxnID,
        p_batchID       => p_batchID,
        p_orgID         => p_orgID,
        p_assyQty       => l_bf_qty,
        p_txnDate       => p_txnDate,
        p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
        p_txnHdrID      => p_txnHdrID,
        p_firstOp       => -1,
        p_lastOP        => l_last_op,
        p_firstMoveOp   => null,
        p_lastMoveOp    => null,
        p_lockFlag      => p_lockFlag,
        p_batchSeq      => l_batch_seq,
        p_mergeMode     => fnd_api.g_false,
        p_reasonID      => p_reasonID,
        p_reference     => p_reference,
        p_initMsgList   => fnd_api.g_false,
        p_endDebug      => fnd_api.g_false,
        p_mtlTxnMode    => p_mtlTxnMode,
        x_compTbl       => l_compTbl,
        x_returnStatus  => l_returnStatus);

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- Completion/Return/EZ Completion/EZ Return

    -- Check whether overcompletion
    IF(p_childMovTxnID IS NOT NULL AND p_ocQty IS NOT NULL) THEN
      -- overmove/overcomplete
      l_fm_op   := l_first_op;
      l_fm_step := WIP_CONSTANTS.QUEUE;
      IF(p_fmOp IS NULL OR p_fmStep IS NULL OR
         p_toOp IS NULL OR p_toStep IS NULL) THEN
        -- Call from Completion form
        l_to_op   := l_last_op;
        l_to_step := WIP_CONSTANTS.TOMOVE;
      ELSE -- Call from WIP Move or OSFM Move forms
        l_to_op   := p_fmOp;
        l_to_step := p_fmStep;
      END IF;
      -- Call bf_require to derive first_bf_op, last_bf_op, and bf_qty
      -- before call wip_bflProc_priv.processRequirements for
      -- Operation Pull components

      -- set l_first_bf_op and l_last_bf_op back to -1
      l_first_bf_op := -1;
      l_last_bf_op  := -1;
      wma_move.bf_require(p_jobID        => p_wipEntityID,
                          p_fm_op        => l_fm_op,
                          p_fm_step      => l_fm_step,
                          p_to_op        => l_to_op,
                          p_to_step      => l_to_step,
                          p_moveQty      => p_ocQty,
                          x_first_bf_op  => l_first_bf_op,
                          x_last_bf_op   => l_last_bf_op,
                          x_bf_qty       => l_bf_qty,
                          x_returnStatus => l_returnStatus,
                          x_errMessage   => l_errMsg);
      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_errMsg);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
      IF(l_first_bf_op <> -1) THEN
       /**
        * Call backflush processor to insert record into MMTT
        * for each schedule found in l_rsa.
        * This is only for operation pull components.
        **/
        wip_bflProc_priv.processRequirements
         (p_wipEntityID   => p_wipEntityID,
          p_wipEntityType => p_entityType,
          p_repSchedID    => null,
          p_repLineID     => null,
          p_cplTxnID      => null,
          p_movTxnID      => p_childMovTxnID,
          p_batchID       => p_batchID,
          p_orgID         => p_orgID,
          p_assyQty       => l_bf_qty,
          p_txnDate       => p_txnDate,
          p_wipSupplyType => WIP_CONSTANTS.OP_PULL,
          p_txnHdrID      => p_txnHdrID,
          p_firstOp       => l_first_bf_op,
          p_lastOP        => l_last_bf_op,
          p_firstMoveOp   => l_fm_op,
          p_lastMoveOp    => l_to_op,
          p_batchSeq      => l_batch_seq,
          p_lockFlag      => p_lockFlag,
          p_mergeMode     => fnd_api.g_false,
          p_reasonID      => p_reasonID,
          p_reference     => p_reference,
          p_initMsgList   => fnd_api.g_false,
          p_endDebug      => fnd_api.g_false,
          p_mtlTxnMode    => p_mtlTxnMode,
          x_compTbl       => l_compTbl,
          x_returnStatus  => l_returnStatus);

        IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
          l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- l_first_bf_op <> -1

      -- Call assy_pull_bf to derive first_bf_op, last_bf_op,
      -- and bf_qty before call wip_bflProc_priv.processRequirements
      -- for Assembly Pull components. This is only for Scrap txns

      -- set l_first_bf_op and l_last_bf_op back to -1
      l_first_bf_op := -1;
      l_last_bf_op  := -1;

      wma_move.assy_pull_bf(p_jobID        => p_wipEntityID,
                            p_fm_op        => l_fm_op,
                            p_fm_step      => l_fm_step,
                            p_to_op        => l_to_op,
                            p_to_step      => l_to_step,
                            p_moveQty      => p_ocQty,
                            x_first_bf_op  => l_first_bf_op,
                            x_last_bf_op   => l_last_bf_op,
                            x_bf_qty       => l_bf_qty,
                            x_returnStatus => l_returnStatus,
                            x_errMessage   => l_errMsg);

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_errMsg);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
      IF(l_first_bf_op <> -1) THEN
        /**
         * Call backflush processor to insert record into MMTT
         * for each schedule found in l_rsa
         * This is only for assembly pull components.
         **/
        wip_bflProc_priv.processRequirements
          (p_wipEntityID   => p_wipEntityID,
           p_wipEntityType => p_entityType,
           p_repSchedID    => null,
           p_repLineID     => null,
           p_cplTxnID      => null,
           p_movTxnID      => p_childMovTxnID,
           p_batchID       => p_batchID,
           p_orgID         => p_orgID,
           p_assyQty       => l_bf_qty,
           p_txnDate       => p_txnDate,
           p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
           p_txnHdrID      => p_txnHdrID,
           p_firstOp       => l_first_bf_op,
           p_lastOP        => l_last_bf_op,
           p_firstMoveOp   => l_fm_op,
           p_lastMoveOp    => l_to_op,
           p_lockFlag      => p_lockFlag,
           p_batchSeq      => l_batch_seq,
           p_mergeMode     => fnd_api.g_false,
           p_reasonID      => p_reasonID,
           p_reference     => p_reference,
           p_initMsgList   => fnd_api.g_false,
           p_endDebug      => fnd_api.g_false,
           p_mtlTxnMode    => p_mtlTxnMode,
           x_compTbl       => l_compTbl,
           x_returnStatus  => l_returnStatus);

        IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
          l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      END IF; -- l_first_bf_op <> -1
    END IF; -- Overmove/ Overcompletion
  END IF; -- Repetive schedule

  SELECT COUNT(*)
    INTO l_bf_count
    FROM mtl_transactions_interface
   WHERE transaction_header_id = p_txnHdrID
     AND transaction_action_id IN (WIP_CONSTANTS.ISSCOMP_ACTION,
                                   WIP_CONSTANTS.RETCOMP_ACTION,
                                   WIP_CONSTANTS.ISSNEGC_ACTION,
                                   WIP_CONSTANTS.RETNEGC_ACTION)
     AND (MOVE_TRANSACTION_ID = p_movTxnID OR COMPLETION_TRANSACTION_ID = p_cplTxnID);

  SELECT COUNT(*)
    INTO l_lot_ser_count
    FROM mtl_transactions_interface mti,
         mtl_system_items msi
   WHERE mti.organization_id = msi.organization_id
     AND mti.inventory_item_id = msi.inventory_item_id
     AND (msi.lot_control_code = WIP_CONSTANTS.LOT
          OR
          msi.serial_number_control_code IN(WIP_CONSTANTS.FULL_SN,
                                            WIP_CONSTANTS.DYN_RCV_SN))
     AND transaction_header_id = p_txnHdrID
     AND transaction_action_id IN (WIP_CONSTANTS.ISSCOMP_ACTION,
                                   WIP_CONSTANTS.RETCOMP_ACTION,
                                   WIP_CONSTANTS.ISSNEGC_ACTION,
                                   WIP_CONSTANTS.RETNEGC_ACTION);


  SELECT backflush_lot_entry_type
    INTO l_lot_entry_type
    FROM wip_parameters
   WHERE organization_id = p_orgID;

  IF(l_bf_count = 0) THEN
    -- There is no backflush components required for this transaction
    x_bfRequired := WIP_CONSTANTS.WBF_NOBF;
    x_lotSerRequired := WIP_CONSTANTS.NO;
  ELSE
    IF(l_lot_ser_count = 0) THEN
      -- no component under lot/serial control
      x_bfRequired := WIP_CONSTANTS.WBF_BF_NOPAGE;
      x_lotSerRequired := WIP_CONSTANTS.NO;
    ELSE
      IF(l_lot_entry_type = WIP_CONSTANTS.MAN_ENTRY) THEN
        -- If backflush lot entry type is set to manual, no need to do lot
        -- derivation
        x_bfRequired := WIP_CONSTANTS.WBF_BF_PAGE;
        x_lotSerRequired := WIP_CONSTANTS.YES;
      ELSE
        -- derive lot for both Operation Pull and Assembly Pull components
        wip_autoLotProc_priv.deriveLotsFromMTI
         (p_orgID         => p_orgID,
          p_wipEntityID   => p_wipEntityID,
          p_txnHdrID      => p_txnHdrID,
          p_cplTxnID      => p_cplTxnID,
          p_movTxnID      => p_movTxnID,
          p_childMovTxnID => p_childMovTxnID,
          p_initMsgList   => fnd_api.g_false,
          p_endDebug      => fnd_api.g_false,
          x_returnStatus  => l_returnStatus);
        IF(l_returnStatus = fnd_api.g_ret_sts_unexp_error) THEN
          l_errMsg := 'wip_autoLotProc_priv.deriveLotsFromMTI failed';
          raise fnd_api.g_exc_unexpected_error;
        ELSIF(l_returnStatus = fnd_api.g_ret_sts_error) THEN
          x_bfRequired := WIP_CONSTANTS.WBF_BF_PAGE;
          x_lotSerRequired := WIP_CONSTANTS.YES;
        ELSE -- succesfully derived lot
          IF(l_lot_entry_type IN (WIP_CONSTANTS.RECDATE_FULL,
                                  WIP_CONSTANTS.EXPDATE_FULL,
/* Added for Wilson Greatbatch Enhancement */
                                  WIP_CONSTANTS.TXNHISTORY_FULL)) THEN
            x_bfRequired := WIP_CONSTANTS.WBF_BF_PAGE;
            x_lotSerRequired := WIP_CONSTANTS.NO;
          ELSE -- backflush lot entry page is exception only
            x_bfRequired := WIP_CONSTANTS.WBF_BF_NOPAGE;
            x_lotSerRequired := WIP_CONSTANTS.NO;
          END IF;
        END IF; -- check return status
      END IF; -- check lot entry type
    END IF; -- l_lot_ser_count = 0
  END IF; -- l_bf_count = 0

  IF(p_tblName = WIP_CONSTANTS.MMTT_TBL) THEN
    -- Move record from mti to mmtt
    wip_mtlTempProc_priv.validateInterfaceTxns(
      p_txnHdrID      => p_txnHdrID,
      p_addMsgToStack => fnd_api.g_true,
      p_initMsgList   => fnd_api.g_true, /* Bug 5017345/5079379 - to initialize the message stack. */
      p_rollbackOnErr => fnd_api.g_false,
      x_returnStatus  => x_returnStatus);

    IF(x_returnStatus <> fnd_api.g_ret_sts_success) THEN
      l_errMsg := 'wip_mtlTempProc_priv.validateInterfaceTxns failed' ;
      raise fnd_api.g_exc_unexpected_error;
    END IF;

    -- Insert all necessary info that need to be used by inventory form to
    -- gather lot/serial from the user
    IF(x_bfRequired = WIP_CONSTANTS.WBF_BF_PAGE)THEN
       UPDATE mtl_material_transactions_temp mmtt
         SET (mmtt.item_segments,
              mmtt.item_description,
              mmtt.item_trx_enabled_flag,
              mmtt.item_location_control_code,
              mmtt.item_restrict_subinv_code,
              mmtt.item_restrict_locators_code,
              mmtt.item_revision_qty_control_code,
              mmtt.item_primary_uom_code,
              mmtt.item_uom_class,
              mmtt.item_shelf_life_code,
              mmtt.item_shelf_life_days,
              mmtt.item_lot_control_code,
              mmtt.item_serial_control_code,
              mmtt.item_inventory_asset_flag,
              mmtt.number_of_lots_entered)
              =
             (SELECT msik.concatenated_segments,
                     msik.description,
                     msik.mtl_transactions_enabled_flag,
                     msik.location_control_code,
                     msik.restrict_subinventories_code,
                     msik.restrict_locators_code,
                     msik.revision_qty_control_code,
                     msik.primary_uom_code,
                     muom.uom_class,
                     msik.shelf_life_code,
                     msik.shelf_life_days,
                     msik.lot_control_code,
                     msik.serial_number_control_code,
                     msik.inventory_asset_flag,
                     mmtt.transaction_quantity
                FROM mtl_system_items_kfv msik,
                     mtl_units_of_measure muom
               WHERE mmtt.organization_id = msik.organization_id
                 AND mmtt.inventory_item_id = msik.inventory_item_id
                 AND msik.primary_uom_code = muom.uom_code)
        WHERE mmtt.transaction_header_id = p_txnHdrID
          -- Added the check below because OSFM will call this API twice.
          AND mmtt.number_of_lots_entered IS NULL;

      /* Fixed bug 3771273. mmtt.department_id may be null if a job has no
       * routing. We should seperate statement to set mmtt.department_code
       * from statement to update other columns.
       */
      -- set department code if mmtt.department_id is not null
      UPDATE mtl_material_transactions_temp mmtt
         SET (mmtt.department_code)
              =
             (SELECT bd.department_code
                FROM bom_departments bd
               WHERE bd.organization_id = mmtt.organization_id
                 AND bd.department_id = mmtt.department_id
             )
        WHERE mmtt.transaction_header_id = p_txnHdrID
          AND mmtt.department_id IS NOT NULL;

/*Update MMTT Lot number if only one lot is derived */
          IF(l_lot_entry_type IN (WIP_CONSTANTS.RECDATE_FULL,
                                  WIP_CONSTANTS.EXPDATE_FULL,
                                  WIP_CONSTANTS.TXNHISTORY_FULL)) THEN

    UPDATE mtl_material_transactions_temp mmtt
       SET mmtt.lot_number =
           ( SELECT mtlt.lot_number
               FROM mtl_transaction_lots_temp mtlt
              WHERE mmtt.transaction_temp_id = mtlt.transaction_temp_id
                AND 1 = ( SELECT count(*)
                           FROM mtl_transaction_lots_temp mtlt
              WHERE mmtt.transaction_temp_id = mtlt.transaction_temp_id)
           )
     WHERE mmtt.transaction_header_id = p_txnHdrID
     AND mmtt.transaction_action_id IN (WIP_CONSTANTS.ISSCOMP_ACTION,
                                   WIP_CONSTANTS.RETCOMP_ACTION,
                                   WIP_CONSTANTS.ISSNEGC_ACTION,
                                   WIP_CONSTANTS.RETNEGC_ACTION);

		/* Bug 6342487  - FP of Bug 6111292 - Moved this delete statement from below */
		DELETE FROM mtl_transaction_lots_temp mtlt
		WHERE EXISTS
		   (SELECT 'x'
		      FROM mtl_material_transactions_temp mmtt,
			   wip_entities we
		     WHERE mmtt.transaction_header_id = p_txnHdrID
		       AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
		       AND mmtt.transaction_source_id = we.wip_entity_id
		       AND we.entity_type = wip_constants.lotbased
		       AND 1 = (SELECT count(*)
				  FROM mtl_transaction_lots_temp mtlt2
				  WHERE mtlt2.transaction_temp_id =
					mtlt.transaction_temp_id
		));
            END IF;
/* Fixed bug 4121977. One transaction header ID can have multiple temp ID.
   This cause select count(*) to throw  single-row subquery returns more
   than one row exception. */
/*
   DELETE FROM mtl_transaction_lots_temp mtlt
     WHERE mtlt.transaction_temp_id =
           ( SELECT mmtt.transaction_temp_id
               FROM mtl_material_transactions_temp mmtt,
                    wip_entities we
              WHERE mmtt.transaction_header_id = p_txnHdrID
                AND 1 = ( SELECT count(*)
                           FROM mtl_transaction_lots_temp mtlt
                          WHERE mmtt.transaction_temp_id =
                                mtlt.transaction_temp_id
                            )
                AND mmtt.transaction_source_id = we.wip_entity_id
                AND we.entity_type = wip_constants.lotbased
           ) ;
*/
/* Bug 6342487  - FP of Bug 6111292 - Moved this delete statement above inside the IF condition. The rows should be deleted from MTLT
only for the case of Lot Verification=All after the lot has been stamped on MMTT. For Lot Verification=Exception Only
there is no need to delete since the component rows will not be visible in the UI.
    DELETE FROM mtl_transaction_lots_temp mtlt
     WHERE EXISTS
           (SELECT 'x'
              FROM mtl_material_transactions_temp mmtt,
                   wip_entities we
             WHERE mmtt.transaction_header_id = p_txnHdrID
               AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
               AND mmtt.transaction_source_id = we.wip_entity_id
               AND we.entity_type = wip_constants.lotbased
               AND 1 = (SELECT count(*)
                          FROM mtl_transaction_lots_temp mtlt2
                          WHERE mtlt2.transaction_temp_id =
                                mtlt.transaction_temp_id
                        ));
*/
-- Comment out statement below because we will use color to determine whether
-- user need to provide more lot/serial information or not from J onward.
-- In the past, we use transaction quantity to represent the lot quantity
-- we can derive. If it is not equal to required quantity, user need to provide
-- more lot/serial information.
/*
      -- Only update transaction_quantity for item under lot/serial.
      UPDATE mtl_material_transactions_temp mmtt
         SET mmtt.transaction_quantity =
             (SELECT NVL(SUM(mtlt.transaction_quantity),0)
                FROM mtl_transaction_lots_temp mtlt
               WHERE mmtt.transaction_temp_id = mtlt.transaction_temp_id)
       WHERE mmtt.transaction_header_id = p_txnHdrID
         AND (mmtt.item_serial_control_code IN(WIP_CONSTANTS.FULL_SN,
                                               WIP_CONSTANTS.DYN_RCV_SN)
             OR
              mmtt.item_lot_control_code = WIP_CONSTANTS.LOT);
*/
    END IF; -- x_bfRequired = WIP_CONSTANTS.WBF_BF_PAGE
  END IF; -- WIP_CONSTANTS.MMTT_TBL

  x_returnStatus := fnd_api.g_ret_sts_success;
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.backflush',
                         p_procReturnStatus => x_returnStatus,
                         p_msg => 'Succesfully inserted components into MMTT',
                         x_returnStatus => l_returnStatus);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO SAVEPOINT s_backflush;
    x_returnStatus := fnd_api.g_ret_sts_error;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.backflush',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
  WHEN others THEN
    ROLLBACK TO SAVEPOINT s_backflush;
    x_returnStatus := fnd_api.g_ret_sts_error;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.backflush',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Unexpected error : ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
    END IF;
END backflush;

FUNCTION NegLSCompExist(p_compInfo IN OUT NOCOPY system.wip_lot_serial_obj_t)
  RETURN NUMBER IS

  l_curItem system.wip_component_obj_t;
BEGIN
  LOOP
    IF(p_compInfo.getCurrentItem(l_curItem)) THEN
      IF(l_curItem.transaction_action_id = WIP_CONSTANTS.RETNEGC_ACTION
         AND
         (l_curItem.lot_control_code = WIP_CONSTANTS.LOT
          OR
          l_curItem.serial_number_control_code IN(WIP_CONSTANTS.FULL_SN,
                                                  WIP_CONSTANTS.DYN_RCV_SN))
         ) THEN
        -- Return after the first negative lot/serial component found.
        RETURN WIP_CONSTANTS.YES;
      END IF;
    END IF; -- getCurrentItem
    EXIT WHEN NOT p_compInfo.setNextItem;
  END LOOP;
  -- No negative lot/serial component.
  RETURN WIP_CONSTANTS.NO;
END NegLSCompExist;

PROCEDURE backflush(p_wipEntityID       IN        NUMBER,
                    p_orgID             IN        NUMBER,
                    p_primaryQty        IN        NUMBER,
                    p_txnDate           IN        DATE,
                    p_txnHdrID          IN        NUMBER,
                    p_txnType           IN        NUMBER,
                    p_entityType        IN        NUMBER,
                    p_fmOp              IN        NUMBER:= NULL,
                    p_fmStep            IN        NUMBER:= NULL,
                    p_toOp              IN        NUMBER:= NULL,
                    p_toStep            IN        NUMBER:= NULL,
                    p_ocQty             IN        NUMBER:= NULL,
                    p_childMovTxnID     IN        NUMBER:= NULL,
                    p_movTxnID          IN        NUMBER:= NULL,
                    p_cplTxnID          IN        NUMBER:= NULL,
                    p_objectID          IN        NUMBER:= NULL,
                    x_compInfo         OUT NOCOPY system.wip_lot_serial_obj_t,
                    x_lotSerRequired   OUT NOCOPY NUMBER,
                    x_returnStatus     OUT NOCOPY VARCHAR2) IS

l_params         wip_logger.param_tbl_t;
l_returnStatus   VARCHAR(1);
l_errMsg         VARCHAR2(240);
l_fm_op          NUMBER;
l_fm_step        NUMBER;
l_to_op          NUMBER;
l_to_step        NUMBER;
l_first_op       NUMBER;
l_last_op        NUMBER;
l_first_bf_op    NUMBER;
l_last_bf_op     NUMBER;
l_bf_qty         NUMBER;
l_compTbl        system.wip_component_tbl_t;
l_logLevel       NUMBER := fnd_log.g_current_runtime_level;
l_backwardMove   NUMBER := WIP_CONSTANTS.NO;
BEGIN
  SAVEPOINT s_backflush2;
  -- write parameter value to log file
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_wipEntityID';
    l_params(1).paramValue  :=  p_wipEntityID;
    l_params(2).paramName   := 'p_orgID';
    l_params(2).paramValue  :=  p_orgID;
    l_params(3).paramName   := 'p_primaryQty';
    l_params(3).paramValue  :=  p_primaryQty;
    l_params(4).paramName   := 'p_txnDate';
    l_params(4).paramValue  :=  p_txnDate;
    l_params(5).paramName   := 'p_txnHdrID';
    l_params(5).paramValue  :=  p_txnHdrID;
    l_params(6).paramName   := 'p_txnType';
    l_params(6).paramValue  :=  p_txnType;
    l_params(7).paramName   := 'p_entityType';
    l_params(7).paramValue  :=  p_entityType;
    l_params(8).paramName  := 'p_fmOp';
    l_params(8).paramValue :=  p_fmOp;
    l_params(9).paramName  := 'p_fmStep';
    l_params(9).paramValue :=  p_fmStep;
    l_params(10).paramName  := 'p_toOp';
    l_params(10).paramValue :=  p_toOp;
    l_params(11).paramName  := 'p_toStep';
    l_params(11).paramValue :=  p_toStep;
    l_params(12).paramName  := 'p_ocQty';
    l_params(12).paramValue :=  p_ocQty;
    l_params(13).paramName  := 'p_childMovTxnID';
    l_params(13).paramValue :=  p_childMovTxnID;
    l_params(14).paramName  := 'p_movTxnID';
    l_params(14).paramValue :=  p_movTxnID;

    wip_logger.entryPoint(p_procName => 'wip_bflProc_priv.backflush',
                          p_params => l_params,
                          x_returnStatus => l_returnStatus);
  END IF;

  SELECT MIN(wo.operation_seq_num),
         MAX(wo.operation_seq_num)
    INTO l_first_op,
         l_last_op
    FROM wip_operations wo,
         wip_discrete_jobs wdj
   WHERE wdj.organization_id = wo.organization_id
     AND wdj.wip_entity_id = wo.wip_entity_id
     AND wdj.status_type in (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG)
     AND wdj.wip_entity_id = p_wipEntityID
     AND wdj.organization_id = p_orgID;

  IF(l_first_op IS NULL) THEN
    -- Routingless job
    l_first_op := 0;
  END IF;
  IF(l_last_op IS NULL) THEN
    -- Routingless job
    l_last_op := 1.1;
  END IF;

  -- Initialized component object
  l_compTbl := system.wip_component_tbl_t();

  IF(p_fmOp IS NULL OR p_fmStep IS NULL OR
     p_toOp IS NULL OR p_toStep IS NULL) THEN
    -- Completion/return transactions
    IF(p_txnType = WIP_CONSTANTS.COMP_TXN) THEN
      -- Completion transaction
      l_fm_op   := l_last_op;
      l_fm_step := WIP_CONSTANTS.TOMOVE;
      l_to_op   := NULL;
      l_to_step := NULL;
    ELSIF(p_txnType = WIP_CONSTANTS.RET_TXN) THEN
      -- Return transaction
      l_fm_op   := NULL;
      l_fm_step := NULL;
      l_to_op   := l_last_op;
      l_to_step := WIP_CONSTANTS.TOMOVE;
    END IF;
  ELSE -- Move related transactions
    l_fm_op   := p_fmOp;
    l_fm_step := p_fmStep;
    l_to_op   := p_toOp;
    l_to_step := p_toStep;
    -- Check whether it is a backward move
    IF (l_fm_op > l_to_op OR
        (l_fm_op = l_to_op AND l_fm_step > l_to_step)) THEN
      l_backwardMove := WIP_CONSTANTS.YES;
    ELSE
      l_backwardMove := WIP_CONSTANTS.NO;
    END IF;
  END IF;

  -- Check whether it is move related transactions or not
  IF(l_fm_op IS NOT NULL AND l_to_op IS NOT NULL) THEN
    -- set l_first_bf_op and l_last_bf_op back to -1
    l_first_bf_op := -1;
    l_last_bf_op  := -1;
    -- Call bf_require to derive first_bf_op, last_bf_op, and bf_qty
    -- before call wip_bflProc_priv.processRequirements for
    -- Operation Pull components
    wma_move.bf_require(p_jobID        => p_wipEntityID,
                        p_fm_op        => l_fm_op,
                        p_fm_step      => l_fm_step,
                        p_to_op        => l_to_op,
                        p_to_step      => l_to_step,
                        p_moveQty      => p_primaryQty,
                        x_first_bf_op  => l_first_bf_op,
                        x_last_bf_op   => l_last_bf_op,
                        x_bf_qty       => l_bf_qty,
                        x_returnStatus => l_returnStatus,
                        x_errMessage   => l_errMsg);
    IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_errMsg);
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    END IF;
    IF(l_first_bf_op <> -1) THEN
      wip_bflProc_priv.processRequirements
       (p_wipEntityID   => p_wipEntityID,
        p_wipEntityType => p_entityType,
        p_cplTxnID      => null,
        p_movTxnID      => p_movTxnID,
        p_orgID         => p_orgID,
        p_assyQty       => l_bf_qty,
        p_txnDate       => p_txnDate,
        p_wipSupplyType => WIP_CONSTANTS.OP_PULL,
        p_txnHdrID      => p_txnHdrID,
        p_firstOp       => l_first_bf_op,
        p_lastOP        => l_last_bf_op,
        p_firstMoveOp   => l_fm_op,
        p_lastMoveOp    => l_to_op,
        p_mergeMode     => fnd_api.g_false,
        p_initMsgList   => fnd_api.g_false,
        p_endDebug      => fnd_api.g_false,
        p_mtlTxnMode    => WIP_CONSTANTS.ONLINE,
        x_compTbl       => l_compTbl,
        x_returnStatus  => l_returnStatus);

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- l_first_bf_op <> -1

    -- Call assy_pull_bf to derive first_bf_op, last_bf_op,
    -- and bf_qty before call wip_bflProc_priv.processRequirements
    -- for Assembly Pull components. This is only for Scrap txns

    -- set l_first_bf_op and l_last_bf_op back to -1
    l_first_bf_op := -1;
    l_last_bf_op  := -1;

    wma_move.assy_pull_bf(p_jobID        => p_wipEntityID,
                          p_fm_op        => l_fm_op,
                          p_fm_step      => l_fm_step,
                          p_to_op        => l_to_op,
                          p_to_step      => l_to_step,
                          p_moveQty      => p_primaryQty,
                          x_first_bf_op  => l_first_bf_op,
                          x_last_bf_op   => l_last_bf_op,
                          x_bf_qty       => l_bf_qty,
                          x_returnStatus => l_returnStatus,
                          x_errMessage   => l_errMsg);

    IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_errMsg);
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    END IF;
    IF(l_first_bf_op <> -1) THEN
      wip_bflProc_priv.processRequirements
       (p_wipEntityID   => p_wipEntityID,
        p_wipEntityType => p_entityType,
        p_cplTxnID      => null,
        p_movTxnID      => p_movTxnID,
        p_orgID         => p_orgID,
        p_assyQty       => l_bf_qty,
        p_txnDate       => p_txnDate,
        p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
        p_txnHdrID      => p_txnHdrID,
        p_firstOp       => l_first_bf_op,
        p_lastOP        => l_last_bf_op,
        p_firstMoveOp   => l_fm_op,
        p_lastMoveOp    => l_to_op,
        p_mergeMode     => fnd_api.g_false,
        p_initMsgList   => fnd_api.g_false,
        p_endDebug      => fnd_api.g_false,
        p_mtlTxnMode    => WIP_CONSTANTS.ONLINE,
        x_compTbl       => l_compTbl,
        x_returnStatus  => l_returnStatus);

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- l_first_bf_op <> -1
  END IF; -- Move related transactions

  IF(p_txnType = WIP_CONSTANTS.COMP_TXN OR
      p_txnType = WIP_CONSTANTS.RET_TXN) THEN

    IF(p_txnType = WIP_CONSTANTS.COMP_TXN) THEN
      l_bf_qty := p_primaryQty;
    ELSIF(p_txnType = WIP_CONSTANTS.RET_TXN) THEN
      l_bf_qty := -1 * p_primaryQty;
    END IF;
    wip_bflProc_priv.processRequirements
     (p_wipEntityID   => p_wipEntityID,
      p_wipEntityType => p_entityType,
      p_cplTxnID      => p_cplTxnID,
      -- Fixed bug 5014211. Stamp move_transaction_id for assembly
      -- pull components so that we will have a link if component
      -- records fail inventory validation.
      p_movTxnID      => p_movTxnID,
      p_orgID         => p_orgID,
      p_assyQty       => l_bf_qty,
      p_txnDate       => p_txnDate,
      p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
      p_txnHdrID      => p_txnHdrID,
      p_firstOp       => -1,
      p_lastOP        => l_last_op,
      p_firstMoveOp   => null,
      p_lastMoveOp    => null,
      p_mergeMode     => fnd_api.g_false,
      p_initMsgList   => fnd_api.g_false,
      p_endDebug      => fnd_api.g_false,
      p_mtlTxnMode    => WIP_CONSTANTS.ONLINE,
      x_compTbl       => l_compTbl,
      x_returnStatus  => l_returnStatus);

    IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
      l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
      raise fnd_api.g_exc_unexpected_error;
    END IF;
  END IF; -- Completion/Return/EZ Completion/EZ Return

  -- Check whether overcompletion
  IF(p_childMovTxnID IS NOT NULL AND p_ocQty IS NOT NULL) THEN
    -- overmove/overcomplete
    l_fm_op   := l_first_op;
    l_fm_step := WIP_CONSTANTS.QUEUE;
    IF(p_fmOp IS NULL OR p_fmStep IS NULL OR
       p_toOp IS NULL OR p_toStep IS NULL) THEN
      -- Call from Completion form
      l_to_op   := l_last_op;
      l_to_step := WIP_CONSTANTS.TOMOVE;
    ELSE -- Call from WIP Move or OSFM Move forms
      l_to_op   := p_fmOp;
      l_to_step := p_fmStep;
    END IF;
    -- Call bf_require to derive first_bf_op, last_bf_op, and bf_qty
    -- before call wip_bflProc_priv.processRequirements for
    -- Operation Pull components

    -- set l_first_bf_op and l_last_bf_op back to -1
    l_first_bf_op := -1;
    l_last_bf_op  := -1;
    wma_move.bf_require(p_jobID        => p_wipEntityID,
                        p_fm_op        => l_fm_op,
                        p_fm_step      => l_fm_step,
                        p_to_op        => l_to_op,
                        p_to_step      => l_to_step,
                        p_moveQty      => p_ocQty,
                        x_first_bf_op  => l_first_bf_op,
                        x_last_bf_op   => l_last_bf_op,
                        x_bf_qty       => l_bf_qty,
                        x_returnStatus => l_returnStatus,
                        x_errMessage   => l_errMsg);
    IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_errMsg);
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    END IF;
    IF(l_first_bf_op <> -1) THEN
      wip_bflProc_priv.processRequirements
       (p_wipEntityID   => p_wipEntityID,
        p_wipEntityType => p_entityType,
        p_cplTxnID      => null,
        p_movTxnID      => p_childMovTxnID,
        p_orgID         => p_orgID,
        p_assyQty       => l_bf_qty,
        p_txnDate       => p_txnDate,
        p_wipSupplyType => WIP_CONSTANTS.OP_PULL,
        p_txnHdrID      => p_txnHdrID,
        p_firstOp       => l_first_bf_op,
        p_lastOP        => l_last_bf_op,
        p_firstMoveOp   => l_fm_op,
        p_lastMoveOp    => l_to_op,
        p_mergeMode     => fnd_api.g_false,
        p_initMsgList   => fnd_api.g_false,
        p_endDebug      => fnd_api.g_false,
        p_mtlTxnMode    => WIP_CONSTANTS.ONLINE,
        x_compTbl       => l_compTbl,
        x_returnStatus  => l_returnStatus);

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- l_first_bf_op <> -1

    -- Call assy_pull_bf to derive first_bf_op, last_bf_op,
    -- and bf_qty before call wip_bflProc_priv.processRequirements
    -- for Assembly Pull components. This is only for Scrap txns

    -- set l_first_bf_op and l_last_bf_op back to -1
    l_first_bf_op := -1;
    l_last_bf_op  := -1;

    wma_move.assy_pull_bf(p_jobID        => p_wipEntityID,
                          p_fm_op        => l_fm_op,
                          p_fm_step      => l_fm_step,
                          p_to_op        => l_to_op,
                          p_to_step      => l_to_step,
                          p_moveQty      => p_ocQty,
                          x_first_bf_op  => l_first_bf_op,
                          x_last_bf_op   => l_last_bf_op,
                          x_bf_qty       => l_bf_qty,
                          x_returnStatus => l_returnStatus,
                          x_errMessage   => l_errMsg);

    IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_errMsg);
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
    END IF;
    IF(l_first_bf_op <> -1) THEN
      wip_bflProc_priv.processRequirements
        (p_wipEntityID   => p_wipEntityID,
         p_wipEntityType => p_entityType,
         p_cplTxnID      => null,
         p_movTxnID      => p_childMovTxnID,
         p_orgID         => p_orgID,
         p_assyQty       => l_bf_qty,
         p_txnDate       => p_txnDate,
         p_wipSupplyType => WIP_CONSTANTS.ASSY_PULL,
         p_txnHdrID      => p_txnHdrID,
         p_firstOp       => l_first_bf_op,
         p_lastOP        => l_last_bf_op,
         p_firstMoveOp   => l_fm_op,
         p_lastMoveOp    => l_to_op,
         p_mergeMode     => fnd_api.g_false,
         p_initMsgList   => fnd_api.g_false,
         p_endDebug      => fnd_api.g_false,
         p_mtlTxnMode    => WIP_CONSTANTS.ONLINE,
         x_compTbl       => l_compTbl,
         x_returnStatus  => l_returnStatus);

      IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
        l_errMsg := 'wip_bflProc_priv.procesRequirements failed' ;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- l_first_bf_op <> -1
  END IF; -- Overmove/ Overcompletion

  if (l_logLevel <= wip_constants.full_logging) then
    wip_logger.log(p_msg          => 'before system.wip_lot_serial_obj_t',
                   x_returnStatus => l_returnStatus);
  end if;
  x_compInfo := system.wip_lot_serial_obj_t(null, null, null, l_compTbl,
                                            null, null);
  if (l_logLevel <= wip_constants.full_logging) then
    wip_logger.log(p_msg          => 'after system.wip_lot_serial_obj_t',
                   x_returnStatus => l_returnStatus);
  end if;
  x_compInfo.initialize;
  if (l_logLevel <= wip_constants.full_logging) then
    wip_logger.log(p_msg          => 'after x_compInfo.initialize',
                   x_returnStatus => l_returnStatus);
  end if;

  -- If serialized return or serialized backward move, we have to derive
  -- lot and serial information from genealogy.
  IF (p_objectID IS NOT NULL AND
      (p_txnType = WIP_CONSTANTS.RET_TXN OR
       l_backwardMove = WIP_CONSTANTS.YES)) THEN
    -- Derive lot control only from genealogy
    wip_autoLotProc_priv.deriveLotsFromMOG(x_compLots      => x_compInfo,
                                           p_orgID         => p_orgID,
                                           p_objectID      => p_objectID,
                                           p_initMsgList   => fnd_api.g_true,
                                           x_returnStatus  => x_returnStatus);

    IF(x_returnStatus = fnd_api.g_ret_sts_unexp_error) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;
    -- Derive serial, and lot and serial from genealogy
    wip_autoSerialProc_priv.deriveSerial(x_compLots      => x_compInfo,
                                         p_orgID         => p_orgID,
                                         p_objectID      => p_objectID,
                                         p_initMsgList   => fnd_api.g_true,
                                         x_returnStatus  => x_returnStatus);

    IF(x_returnStatus = fnd_api.g_ret_sts_unexp_error) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;

    IF(NegLSCompExist(p_compInfo => x_compInfo) = WIP_CONSTANTS.YES) THEN
      x_lotSerRequired := WIP_CONSTANTS.YES;
    ELSE
      x_lotSerRequired := WIP_CONSTANTS.NO;
    END IF;
  ELSE
    -- derive lot if the component under lot control, if return status
    -- is 'E' mean cannot derive lot, so the user need to provide more
    -- info.
    wip_autoLotProc_priv.deriveLots(
      x_compLots      => x_compInfo,
      p_orgID         => p_orgID,
      p_wipEntityID   => p_wipEntityID,
      p_initMsgList   => fnd_api.g_true,
      p_endDebug      => fnd_api.g_false,
      p_destroyTrees  => fnd_api.g_true,
      p_treeMode      => inv_quantity_tree_pvt.g_reservation_mode,
      p_treeSrcName   => null,
      x_returnStatus  => x_returnStatus);

    IF(x_returnStatus = fnd_api.g_ret_sts_unexp_error) THEN
      l_errMsg := 'wip_autoLotProc_priv.deriveLots failed';
      raise fnd_api.g_exc_unexpected_error;
    ELSIF(x_returnStatus = fnd_api.g_ret_sts_error) THEN
      x_lotSerRequired := WIP_CONSTANTS.YES;
    ELSE -- succesfully derived lot
      x_lotSerRequired := WIP_CONSTANTS.NO;
    END IF;-- check return status
  END IF; -- check serialized return or serialized backward move

  x_returnStatus := fnd_api.g_ret_sts_success;
  IF (l_logLevel <= wip_constants.trace_logging) THEN
    wip_logger.exitPoint(
      p_procName => 'wip_bflProc_priv.backflush',
      p_procReturnStatus => x_returnStatus,
      p_msg => 'Succesfully inserted components into PL/SQL object',
      x_returnStatus => l_returnStatus);
  END IF;
EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO SAVEPOINT s_backflush2;
    x_returnStatus := fnd_api.g_ret_sts_error;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.backflush',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
    END IF;
  WHEN others THEN
    ROLLBACK TO SAVEPOINT s_backflush2;
    x_returnStatus := fnd_api.g_ret_sts_error;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_bflProc_priv.backflush',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Unexpected error : ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
    END IF;
END backflush;
end wip_bflProc_priv;

/
