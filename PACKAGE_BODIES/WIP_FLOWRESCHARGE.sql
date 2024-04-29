--------------------------------------------------------
--  DDL for Package Body WIP_FLOWRESCHARGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_FLOWRESCHARGE" as
/* $Header: wipfsrcb.pls 120.6.12010000.2 2008/08/15 00:47:32 kboonyap ship $ */

  procedure chargePhantomResource(p_txnTempID in number,
                                  p_orgID     in number,
                                  p_effDate   in date,
                                  p_hasRouting in boolean,
                                  x_returnStatus out nocopy varchar2);
  /**
   * This procedure is called by flow completion/work orderless completion to charge the
   * resource and item/lot overhead.
   * p_txnTempID is the temp id in the MMTT
   *
   * We will base the overhead and resource transaction out of the BOM.
   * 1. Charge the resources even if the auto-charge flag is set to NO.
   *      -- This is based on the count_point_type in bom_operation_sequences
   *      -- 1 Yes  Autocharge
   *      -- 2 No   Autocharge
   *      -- 3 No   Direct Charge
   * 2. Charge the Lot Based only once if it is pre-planned. Else we charge it everytime.
   *      -- This is based on basis_type in bom_resources
   *      -- 1 Item
   *      -- 2 Lot
   *      -- 3 Resource Unit
   *      -- 4 Resource Value
   *      -- 5 Total Value
   *      -- 6 Activity
   * 3. We will NOT charge the Manually Charged resources
   *      -- This is based on autocharge_type in bom_operation_resources
   *      -- If this is set to WIP_MOVE where the info about the standard rate is stored,
   *      -- we will still charge this even though it would be OSP resource
   *      -- 1 Wip move
   *      -- 2 Manual
   *      -- 3 PO receipt
   *      -- 4 PO move
   * 4. Different overhead and ordinary resource
   *      -- This is based on cost_element_id in bom_resources
   *      -- 1 Material
   *      -- 2 Material Overheads
   *      -- 3 Resource
   *      -- 4 Outside Processing
   *      -- 5 Overhead
   */
  procedure chargeResourceAndOverhead(p_txnTempID    in  number,
                                      x_returnStatus out NOCOPY varchar2) is
    -- cursor for find out all the applicable operation seq num
    -- to be charged. For normal work orderless scrap, we don't support scrap
    -- at a particular operation seq num. So in terms of resources to be charged,
    -- there is no diff between completion and completion.
    cursor op_c(p_commonRoutSeqID number,
                p_effDate   date) is
      select operation_sequence_id,
             operation_seq_num
        from bom_operation_sequences
       where routing_sequence_id = p_commonRoutSeqID
         and nvl(operation_type, 1) = 1
         and effectivity_date <= p_effDate
         and nvl(disable_date, p_effDate+1) > p_effDate
         and implementation_date is not null
         and count_point_type in (1, 2);

    -- cursor to find out all applicable events to be charged for a particular lineOp.
    -- for scrap, according to Biju's design doc, resources and overheads used at
    -- non-autocharge operations will not be charged unless it is the scrap lineop.
    cursor event_c(p_lineOpSeqID       number,
                   p_effDate           date,
                   p_scrapLineOp       number,
                   p_parentTxnActionID number) is
      select bos2.operation_sequence_id,
             bos2.operation_seq_num
        from bom_operation_sequences bos1,
             bom_operation_sequences bos2
       where bos2.line_op_seq_id = bos1.operation_sequence_id
         and bos2.operation_type = 1
         and bos1.operation_sequence_id = p_lineOpSeqID
         and bos2.effectivity_date <= p_effDate
         and nvl(bos2.disable_date, p_effDate+1) > p_effDate
         and bos2.implementation_date is not null
         and (   bos2.count_point_type in (1, 2)
              or (   p_parentTxnActionID = WIP_CONSTANTS.SCRASSY_ACTION
                 and bos1.operation_seq_num = p_scrapLineOp));

    -- cursor to find out all the events that are not assigned to any lineop.
    -- It is decided on the meeting(Richard, Barry, Adrian, Serena, Jung and Yong) that
    -- we should charge/uncharge the resource for the event even the event is not assigned
    -- to any line op(usually doesn't happen).
    cursor standalone_event_c(p_routingSeqID number,
                              p_effDate      date) is
      select operation_sequence_id,
             operation_seq_num
        from bom_operation_sequences
       where routing_sequence_id = p_routingSeqID
         and operation_type = 1
         and effectivity_date <= p_effDate
         and nvl(disable_date, p_effDate+1) > p_effDate
         and implementation_date is not null
         and line_op_seq_id is null;

    l_chargeTbl bom_rtg_network_api.op_tbl_type;
    l_lineOpTbl bom_rtg_network_api.op_tbl_type;
    l_count number := 1;
    l_index number := 1;

    l_commonRoutSeqID number;
    l_effDate date;
    l_parentTxnActionID number;
    l_toOpSeqNum number := null;
    l_cfmFlag number;
    l_orgID number;

    l_params wip_logger.param_tbl_t;
    l_returnStatus varchar2(1);
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_org_code VARCHAR2(3); --bug 5231366

  begin
    l_params(1).paramName := 'p_txnTempID';
    l_params(1).paramValue := p_txnTempID;
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.entryPoint(p_procName => 'wip_flowResCharge.chargeResourceAndOverhead',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    begin
      select bor.common_routing_sequence_id,
             nvl(bor.cfm_routing_flag, 2),
             mmtt.routing_revision_date,
             nvl(mmtt.operation_seq_num, -1),
             mmtt.transaction_action_id,
             mmtt.organization_id
        into l_commonRoutSeqID,
             l_cfmFlag,
             l_effDate,
             l_toOpSeqNum,
             l_parentTxnActionID,
             l_orgID
        from bom_operational_routings bor,
             mtl_material_transactions_temp mmtt
       where bor.assembly_item_id =  mmtt.inventory_item_id
         and bor.organization_id = mmtt.organization_id
         and nvl(bor.alternate_routing_designator, 'NONE') =
             nvl(mmtt.alternate_routing_designator, 'NONE')
         and mmtt.transaction_temp_id = p_txnTempID;
    -- to check the operation effectivity date, we should use routing_revision_date
    -- instead of transaction date. The reason is that even when a routing revision is
    -- not in effect, we still allow the user to pick that up to do transactions.
    exception
    when others then
      -- no routing, try to charege phantom
      select organization_id,
             nvl(routing_revision_date, sysdate)
       into l_orgID,
            l_effDate
       from mtl_material_transactions_temp
      where transaction_temp_id = p_txnTempID;

      chargePhantomResource(p_txnTempID, l_orgID, l_effDate, false, x_returnStatus);

      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_flowResCharge.chargeResourceAndOverhead',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'No routing, tried to charge phantom',
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      return;
    end;


    -- for flow txn, we needs to construct the lineOp table, and then itereate through the
    -- the table to find out the event attached and further down resources attached.
    -- for normal work orderless txn, to keep the code consistent, I will construct an
    -- equivalent of that op table.
    if ( l_cfmFlag = 2 ) then
      for op_rec in op_c(l_commonRoutSeqID, l_effDate) loop
        l_chargeTbl(l_count).operation_sequence_id := op_rec.operation_sequence_id;
        l_chargeTbl(l_count).operation_seq_num := op_rec.operation_seq_num;
        l_count := l_count + 1;
      end loop;
    else
      wip_flowUtil_priv.constructWipLineOps(p_routingSeqID => l_commonRoutSeqID,
                                            p_assyItemID => null,
                                            p_orgID => null,
                                            p_altRoutDesig => null,
                                            p_terminalOpSeqNum => l_toOpSeqNum,
                                            x_lineOpTbl => l_lineOpTbl);
      l_count := l_lineOpTbl.first;
      while ( l_count is not null ) loop
        for event_rec in event_c(l_lineOpTbl(l_count).operation_sequence_id,
                                 l_effDate,
                                 l_toOpSeqNum,
                                 l_parentTxnActionID) loop
          l_chargeTbl(l_index).operation_sequence_id := event_rec.operation_sequence_id;
          l_chargeTbl(l_index).operation_seq_num := event_rec.operation_seq_num;
          l_index := l_index + 1;
        end loop;

        l_count := l_lineOpTbl.next(l_count);
      end loop;

      -- now we need to add those events that are not assigned to any line op
      for standalone_event_rec in standalone_event_c(l_commonRoutSeqID,
                                                     l_effDate) loop
        l_chargeTbl(l_index).operation_sequence_id :=
                          standalone_event_rec.operation_sequence_id;
        l_chargeTbl(l_index).operation_seq_num :=
                          standalone_event_rec.operation_seq_num;
        l_index := l_index + 1;
      end loop;
    end if;

    -- now we got all the event/operation seq num that needs to be charged
    -- iterate through that and find all the applicable resources attached to them
    l_count := l_chargeTbl.first;
    while ( l_count is not null ) loop
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(p_msg => 'Inserting Resources for op seq/event: ' ||
                                l_chargeTbl(l_count).operation_seq_num,
                       x_returnStatus => l_returnStatus);
      end if;

      --bug 5231366
      select mp.organization_code
        into l_org_code
        from mtl_material_transactions_temp mmtt,
             mtl_parameters mp
       where mmtt.transaction_temp_id = p_txnTempID
         and mmtt.organization_id = mp.organization_id;

      insert into wip_cost_txn_interface(
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        group_id,
        source_code,
        source_line_id,
        process_phase,
        process_status,
        transaction_type,
        organization_id,
        organization_code, --bug 5231366
        wip_entity_id,
        entity_type,
        primary_item_id,
        line_id,
        transaction_date,
        acct_period_id,
        operation_seq_num,
        department_id,
        department_code,
        resource_seq_num,
        resource_id,
        resource_code,
        usage_rate_or_amount,
        basis_type,
        autocharge_type,
        standard_rate_flag,
        transaction_quantity,
        transaction_uom,
        primary_quantity,
        primary_uom,
        actual_resource_rate,
        activity_id,
        reason_id,
        reference,
        completion_transaction_id,
        project_id,
        task_id)
      select
        sysdate,
        mmtt.last_updated_by,
        sysdate,
        mmtt.created_by,
        mmtt.last_update_login,
        mmtt.request_id,
        mmtt.program_application_id,
        mmtt.program_id,
        nvl(mmtt.program_update_date, sysdate),
        null, -- group id
        mmtt.source_code,
        mmtt.source_line_id,
        2, -- process phase: resource processing
        1, -- process status: pending
        1, -- transaction type: resource
        mmtt.organization_id,
        l_org_code,  --bug 5231366
        mmtt.transaction_source_id,
        4,
        mmtt.inventory_item_id,
        mmtt.repetitive_line_id,
        mmtt.transaction_date,
        mmtt.acct_period_id,
        l_chargeTbl(l_count).operation_seq_num,
        bos.department_id,
        bd.department_code,
        bor.resource_seq_num,
        bor.resource_id,
        br.resource_code,
        sum(bor.usage_rate_or_amount),
        bor.basis_type,
        bor.autocharge_type,
        bor.standard_rate_flag,
        sum(bor.usage_rate_or_amount *
            decode(bor.basis_type,
              1, mmtt.primary_quantity,
  /* Fixed bug 4162698. Since wfs.quantity_completed is either 0 or positive
     number, we have to set the sign based on transaction type.
   */
              2, decode(mmtt.transaction_type_id, 17, -1, 91, -1, 1) *
                 decode(wfs.quantity_completed,
                   0, 1,
                   0),
              0)), -- you may assign the same res multiple times at any op.
        br.unit_of_measure,
        sum(bor.usage_rate_or_amount *
            decode(bor.basis_type,
              1, mmtt.primary_quantity,
   /* Fixed bug 4162698. Since wfs.quantity_completed is either 0 or positive
      number, we have to set the sign based on transaction type.
   */
              2, decode(mmtt.transaction_type_id, 17, -1, 91, -1, 1) *
                 decode(wfs.quantity_completed,
                   0, 1,
                   0),
              0)),
        br.unit_of_measure,
        null, -- actual_resource_rate
        bor.activity_id,
        mmtt.reason_id,
        mmtt.transaction_reference,
        mmtt.completion_transaction_id,
        mmtt.project_id,
        mmtt.task_id
      from
        bom_operation_resources bor,
        wip_flow_schedules wfs,
        bom_departments bd,
        bom_resources br,
        bom_operation_sequences bos,
        mtl_material_transactions_temp mmtt
      where bos.operation_sequence_id =
              l_chargeTbl(l_count).operation_sequence_id
        and mmtt.transaction_temp_id = p_txnTempID
        and bor.operation_sequence_id = bos.operation_sequence_id
        and nvl(bor.acd_type, -1) <> 3 -- for implement ECO we only explode those undeleted res
        and bor.autocharge_type <> 2 -- charge everything but manual
        and bor.usage_rate_or_amount <> 0
        and decode(bor.basis_type,
                   1, mmtt.transaction_quantity,
                   2, decode(wfs.quantity_completed, 0, 1, 0),
                   0) <> 0
        and decode(bor.basis_type,
                   2, decode(wfs.scheduled_flag, 1, mmtt.transaction_action_id, 0),
                   0 ) <> 30 -- Lot based resources are not charged for scheduled cfm scrap
        and bd.organization_id = mmtt.organization_id
        and bd.department_id = bos.department_id
        and br.organization_id = mmtt.organization_id
        and br.resource_id = bor.resource_id
        and br.cost_element_id in (3, 4)
        and wfs.organization_id = mmtt.organization_id
        and wfs.wip_entity_id = mmtt.transaction_source_id
      group by
        bos.operation_seq_num,
        bos.department_id,
        bd.department_code,
        bor.resource_id,
        br.resource_code,
        bor.resource_seq_num,
        bor.autocharge_type,
        bor.basis_type,
        bor.standard_rate_flag,
        br.unit_of_measure,
        bor.activity_id,
        mmtt.last_updated_by,
        mmtt.created_by,
        mmtt.last_update_login,
        mmtt.request_id,
        mmtt.program_application_id,
        mmtt.program_id,
        nvl(mmtt.program_update_date, sysdate),
        mmtt.source_code,
        mmtt.source_line_id,
        mmtt.organization_id,
        l_org_code,
        mmtt.transaction_source_id,
        mmtt.inventory_item_id,
        mmtt.repetitive_line_id,
        mmtt.transaction_date,
        mmtt.acct_period_id,
        mmtt.reason_id,
        mmtt.transaction_reference,
        mmtt.transaction_type_id,
        mmtt.completion_transaction_id,
        mmtt.project_id,
        mmtt.task_id;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(p_msg => 'Inserting item overheads for op seq/event: ' ||
                                l_chargeTbl(l_count).operation_seq_num,
                       x_returnStatus => l_returnStatus);
      end if;

      insert into wip_cost_txn_interface(
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        group_id,
        source_code,
        source_line_id,
        process_phase,
        process_status,
        transaction_type,
        organization_id,
        organization_code,  --bug 5231366
        wip_entity_id,
        entity_type,
        primary_item_id,
        line_id,
        transaction_date,
        acct_period_id,
        operation_seq_num,
        department_id,
        department_code,
        basis_type,
        autocharge_type,
        transaction_quantity,
        transaction_uom,
        primary_quantity,
        primary_uom,
        reason_id,
        reference,
        completion_transaction_id,
        project_id,
        task_id)
      select
        sysdate,
        mmtt.last_updated_by,
        sysdate,
        mmtt.created_by,
        mmtt.last_update_login,
        mmtt.request_id,
        mmtt.program_application_id,
        mmtt.program_id,
        nvl(mmtt.program_update_date, sysdate),
        null, -- group id
        mmtt.source_code,
        mmtt.source_line_id,
        2, -- process phase: resource processing
        1, -- process status: pending
        2, -- transaction type: overhead
        mmtt.organization_id,
        l_org_code,  --bug 5231366
        mmtt.transaction_source_id,
        4,
        mmtt.inventory_item_id,
        mmtt.repetitive_line_id,
        mmtt.transaction_date,
        mmtt.acct_period_id,
        l_chargeTbl(l_count).operation_seq_num,
        bos.department_id,
        bd.department_code,
        1,  -- per item
        1,  -- wip move
        mmtt.transaction_quantity,
        mmtt.transaction_uom,
        mmtt.primary_quantity,
        mmtt.item_primary_uom_code,
        mmtt.reason_id,
        mmtt.transaction_reference,
        mmtt.completion_transaction_id,
        mmtt.project_id,
        mmtt.task_id
      from
        bom_departments bd,
        bom_operation_sequences bos,
        wip_flow_schedules wfs,
        mtl_material_transactions_temp mmtt
     where  bos.operation_sequence_id =
              l_chargeTbl(l_count).operation_sequence_id
        and mmtt.transaction_temp_id = p_txnTempID
        and bd.organization_id = mmtt.organization_id
        and bd.department_id = bos.department_id
        and wfs.organization_id = mmtt.organization_id
        and wfs.wip_entity_id = mmtt.transaction_source_id;

      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log(p_msg => 'Inserting lot overheads for op seq/event: ' ||
                                l_chargeTbl(l_count).operation_seq_num,
                       x_returnStatus => l_returnStatus);
      end if;

      insert into wip_cost_txn_interface(
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        group_id,
        source_code,
        source_line_id,
        process_phase,
        process_status,
        transaction_type,
        organization_id,
        organization_code,  --bug 5231366
        wip_entity_id,
        entity_type,
        primary_item_id,
        line_id,
        transaction_date,
        acct_period_id,
        operation_seq_num,
        department_id,
        department_code,
        basis_type,
        autocharge_type,
        transaction_quantity,
        transaction_uom,
        primary_quantity,
        primary_uom,
        reason_id,
        reference,
        completion_transaction_id,
        project_id,
        task_id)
      select
        sysdate,
        mmtt.last_updated_by,
        sysdate,
        mmtt.created_by,
        mmtt.last_update_login,
        mmtt.request_id,
        mmtt.program_application_id,
        mmtt.program_id,
        nvl(mmtt.program_update_date, sysdate),
        null, -- group id
        mmtt.source_code,
        mmtt.source_line_id,
        2, -- process phase: resource processing
        1, -- process status: pending
        2, -- transaction type: overhead
        mmtt.organization_id,
        l_org_code,  --bug 5231366
        mmtt.transaction_source_id,
        4,
        mmtt.inventory_item_id,
        mmtt.repetitive_line_id,
        mmtt.transaction_date,
        mmtt.acct_period_id,
        l_chargeTbl(l_count).operation_seq_num,
        bos.department_id,
        bd.department_code,
        2, -- lot based
        1, -- wip move
        decode(mmtt.transaction_action_id,
               31, 1,
               32, -1,
               30, decode(nvl(wfs.quantity_completed, 0), 0, sign(mmtt.primary_quantity), 0)),
        mmtt.transaction_uom,
        decode(mmtt.transaction_action_id,
               31, 1,
               32, -1,
               30, decode(nvl(wfs.quantity_completed, 0), 0, sign(mmtt.primary_quantity), 0)),
        mmtt.item_primary_uom_code,
        mmtt.reason_id,
        mmtt.transaction_reference,
        mmtt.completion_transaction_id,
        mmtt.project_id,
        mmtt.task_id
      from
        bom_departments bd,
        bom_operation_sequences bos,
        wip_flow_schedules wfs,
        mtl_material_transactions_temp mmtt
     where bos.operation_sequence_id =
              l_chargeTbl(l_count).operation_sequence_id
        and mmtt.transaction_temp_id = p_txnTempID
        and wfs.organization_id = mmtt.organization_id
        and wfs.wip_entity_id = mmtt.transaction_source_id
        and decode(nvl(wfs.quantity_completed, 0), 0, 1, 0) <> 0
        and decode(wfs.scheduled_flag, 1, mmtt.transaction_action_id, 0) <> 30
            -- lot based overheads are not charged for scheduled cfm scrap
        and bd.organization_id = mmtt.organization_id
        and bd.department_id = bos.department_id;


      l_count := l_chargeTbl.next(l_count);
    end loop;

    -- now charge the phantom routing is applicable
    chargePhantomResource(p_txnTempID, l_orgID, l_effDate, true, x_returnStatus);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_flowResCharge.chargeResourceAndOverhead',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'Exit resource charge either successfully or failed in charging phantom!',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_flowResCharge.chargeResourceAndOverhead',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'unexpected error: ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
    end if;
  end chargeResourceAndOverhead;

  procedure chargePhantomResource(p_txnTempID in number,
                                  p_orgID     in number,
                                  p_effDate   in date,
                                  p_hasRouting in boolean,
                                  x_returnStatus out nocopy varchar2) is
    -- cursor to get all phantoms for completion. The phantoms must be
    -- in a count-point operation and also an ECO implemented operation
    -- we already check the op num/event effecvitiy when exploding the bom.
    cursor phantoms_c1 is
       /* Bug 4545130; FP 4257633 Add distinct to select clause, and also
          change wfs.primary_item_id, wfs.organization_id to
          mmtt.inventory_item_id and mmtt.organization_id in join condition
          of bor.assembly_item_id, bor.organization_id
        */
      select distinct
             mmtt.inventory_item_id phantom_item_id,
             mmtt.operation_seq_num*(-1) operation_seq_num,
             mmtt.transaction_temp_id,
             mmtt.completion_transaction_id,
             mmtt.repetitive_line_id
        from mtl_material_transactions_temp mmtt,
             wip_flow_schedules wfs,
             bom_operational_routings bor,
             bom_operation_sequences bos
       where mmtt.completion_transaction_id =
                    (select mmtt2.completion_transaction_id
                       from mtl_material_transactions_temp mmtt2
                      where mmtt2.transaction_temp_id = p_txnTempID)
         and mmtt.transaction_action_id in (WIP_CONSTANTS.ISSCOMP_ACTION,
                                            WIP_CONSTANTS.RETCOMP_ACTION,
                                            WIP_CONSTANTS.ISSNEGC_ACTION,
                                            WIP_CONSTANTS.RETNEGC_ACTION)
         and mmtt.operation_seq_num < 0
         and mmtt.process_flag = 'Y'
         and mmtt.transaction_source_type_id = 5
         and wfs.organization_id = mmtt.organization_id
         and wfs.wip_entity_id = mmtt.transaction_source_id
       /* Bug 4545130; FP 4257633 */
         and bor.assembly_item_id = mmtt.inventory_item_id
         and bor.organization_id = mmtt.organization_id
         and nvl(bor.alternate_routing_designator, 'NONE') =
             nvl(mmtt.alternate_routing_designator, 'NONE')
         and bor.pending_from_ecn is null
             -- for implement ECO the routing must be not pending from ecn
         and bos.routing_sequence_id = bor.common_routing_sequence_id
       /* Bug 4545088; FP 4542270; Comment out following operation_seq_num cnd */
       /*  and bos.operation_seq_num = mmtt.operation_seq_num*(-1) */
         and bos.count_point_type in (1, 2);

    cursor phantoms_c2 is
      select mmtt.inventory_item_id phantom_item_id,
             mmtt.operation_seq_num*(-1) operation_seq_num,
             mmtt.transaction_temp_id,
             mmtt.completion_transaction_id,
             mmtt.repetitive_line_id
        from mtl_material_transactions_temp mmtt
       where mmtt.completion_transaction_id =
                    (select mmtt2.completion_transaction_id
                       from mtl_material_transactions_temp mmtt2
                      where mmtt2.transaction_temp_id = p_txnTempID)
         and mmtt.transaction_action_id in (WIP_CONSTANTS.ISSCOMP_ACTION,
                                            WIP_CONSTANTS.RETCOMP_ACTION,
                                            WIP_CONSTANTS.ISSNEGC_ACTION,
                                            WIP_CONSTANTS.RETNEGC_ACTION)
         and mmtt.operation_seq_num = -1
         and mmtt.transaction_source_type_id = 5
         and mmtt.process_flag = 'Y';

    l_logLevel number := fnd_log.g_current_runtime_level;
    l_returnStatus varchar2(1);
    l_params wip_logger.param_tbl_t;

    l_compID number;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    l_params(1).paramName := 'p_txnTempID';
    l_params(1).paramValue := p_txnTempID;
    l_params(2).paramName := 'p_orgID';
    l_params(2).paramValue := p_orgID;
    l_params(3).paramName := 'p_hasRouting';
    if ( p_hasRouting ) then
      l_params(3).paramValue := 'True';
    else
      l_params(3).paramValue := 'False';
    end if;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.entryPoint(p_procName => 'wip_flowResCharge.chargePhantomResource',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    -- now charge the phantom routing is applicable
    if ( wip_globals.use_phantom_routings(p_orgID) = WIP_CONSTANTS.YES) then
      if ( p_hasRouting ) then
        for phantoms_rec in phantoms_c1 loop
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log(p_msg => 'Charging phantom: ' ||
                                  phantoms_rec.phantom_item_id || ' at op: ' ||
                                  phantoms_rec.operation_seq_num || ' tmp id: ' ||
                                  phantoms_rec.transaction_temp_id,
                                  x_returnStatus => l_returnStatus);
          end if;

          if ( wip_explode_phantom_rtgs.charge_flow_resource_ovhd(
               p_org_id => p_orgID,
               p_phantom_item_id => phantoms_rec.phantom_item_id,
               p_op_seq_num => phantoms_rec.operation_seq_num,
               p_comp_txn_id => phantoms_rec.completion_transaction_id,
               p_txn_temp_id => phantoms_rec.transaction_temp_id,
               p_line_id => phantoms_rec.repetitive_line_id,
               p_rtg_rev_date => to_char(p_effDate, 'YYYY/MM/DD HH24:MI')) = 0 ) then
            raise fnd_api.g_exc_unexpected_error;
          end if;
        end loop;
      else -- it doens't have a routing, use the second cursor
        for phantoms_rec in phantoms_c2 loop
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log(p_msg => 'Charging phantom: ' ||
                                  phantoms_rec.phantom_item_id || ' at op: ' ||
                                  phantoms_rec.operation_seq_num || ' tmp id: ' ||
                                  phantoms_rec.transaction_temp_id,
                                  x_returnStatus => l_returnStatus);
          end if;

          if ( wip_explode_phantom_rtgs.charge_flow_resource_ovhd(
               p_org_id => p_orgID,
               p_phantom_item_id => phantoms_rec.phantom_item_id,
               p_op_seq_num => phantoms_rec.operation_seq_num,
               p_comp_txn_id => phantoms_rec.completion_transaction_id,
               p_txn_temp_id => phantoms_rec.transaction_temp_id,
               p_line_id => phantoms_rec.repetitive_line_id,
               p_rtg_rev_date => to_char(p_effDate, 'YYYY/MM/DD HH24:MI')) = 0 ) then
            raise fnd_api.g_exc_unexpected_error;
          end if;
        end loop;
      end if;
    end if;


  exception
  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_flowResCharge.chargePhantomResource',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'unexpected error: ' || SQLERRM,
                           x_returnStatus => l_returnStatus);
    end if;
  end chargePhantomResource;

end wip_flowResCharge;

/
