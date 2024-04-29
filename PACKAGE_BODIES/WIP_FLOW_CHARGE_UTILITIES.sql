--------------------------------------------------------
--  DDL for Package Body WIP_FLOW_CHARGE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_FLOW_CHARGE_UTILITIES" as
 /* $Header: wipworob.pls 120.1 2006/08/17 22:13:56 shkalyan noship $ */


g_line_code VARCHAR2(10) := NULL ;

/* *********************************************************************
                        Private Procedures
***********************************************************************/
function Charge_Resources (p_txn_temp_id in number,
			   p_comp_txn_id in number,
			   p_rtg_rev_date in varchar2) return number is

BEGIN

INSERT INTO WIP_COST_TXN_INTERFACE
  (transaction_id,
   last_update_date,
   last_updated_by,
   last_updated_by_name,
   creation_date,
   created_by,
   created_by_name,
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
   organization_code,
   wip_entity_id,
   entity_type,
   primary_item_id,
   line_id,
   line_code,
   transaction_date,
   acct_period_id,
   operation_seq_num,
   department_id,
   department_code,
   employee_id,
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
   activity_name,
   reason_id,
   reference,
   completion_transaction_id,
   po_header_id,
   po_line_id,
   repetitive_schedule_id,
   attribute_category,
   attribute1, attribute2, attribute3, attribute4, attribute5,
   attribute6, attribute7, attribute8, attribute9, attribute10,
   attribute11, attribute12,attribute13, attribute14, attribute15,
   project_id,
   task_id
  )
   SELECT
        NULL,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.USER_NAME,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.USER_NAME,
        MMTT.LAST_UPDATE_LOGIN,
        MMTT.REQUEST_ID,
        MMTT.PROGRAM_APPLICATION_ID,
        MMTT.PROGRAM_ID,
        NVL(MMTT.PROGRAM_UPDATE_DATE, SYSDATE),
        NULL,
        MMTT.SOURCE_CODE,
        MMTT.SOURCE_LINE_ID,
        2,				-- Process_Phase
        1,				-- Process Status
        1,
        MP.ORGANIZATION_ID,
        MP.ORGANIZATION_CODE,
        MMTT.TRANSACTION_SOURCE_ID,
        4,				-- Wip_Entity_Type
        MMTT.INVENTORY_ITEM_ID,
        MMTT.REPETITIVE_LINE_ID,
        g_line_code,			-- the global line code variable
        MMTT.TRANSACTION_DATE,
        MMTT.ACCT_PERIOD_ID,
  	BOS.OPERATION_SEQ_NUM,
        BOS.DEPARTMENT_ID,
        BD.DEPARTMENT_CODE,
        NULL,
	BOR.RESOURCE_SEQ_NUM,
        BOR.RESOURCE_ID,
        BR.RESOURCE_CODE,
        sum(BOR.USAGE_RATE_OR_AMOUNT),
        BOR.BASIS_TYPE,
        BOR.AUTOCHARGE_TYPE,
        BOR.STANDARD_RATE_FLAG,
	/* Bug 5472762 - Modified the following DECODE to derive correct transaction quantity*/
        sum(BOR.USAGE_RATE_OR_AMOUNT * DECODE (BOR.BASIS_TYPE,
                                       1, MMTT.PRIMARY_QUANTITY,
                                       2, DECODE( wfs.QUANTITY_COMPLETED + MMTT.PRIMARY_QUANTITY + wfs.QUANTITY_SCRAPPED,
                                                  MMTT.PRIMARY_QUANTITY, Decode(Sign(mmtt.primary_quantity),1,1,-1),
                                                  0, -1,
                                                  0
                                                ),
                                       0
                                     )),
	BR.UNIT_OF_MEASURE,
	/* Bug 5472762 - Modified the following DECODE to derive correct primary quantity*/
        sum(BOR.USAGE_RATE_OR_AMOUNT * DECODE (BOR.BASIS_TYPE,
                                       1, MMTT.PRIMARY_QUANTITY,
                                       2, DECODE( wfs.QUANTITY_COMPLETED + MMTT.PRIMARY_QUANTITY + wfs.QUANTITY_SCRAPPED,
                                                  MMTT.PRIMARY_QUANTITY, Decode(Sign(mmtt.primary_quantity),1,1,-1),
                                                  0, -1,
                                                  0
                                                ),
                                       0
                                     )),
	BR.UNIT_OF_MEASURE,
        NULL,
        NVL(BOR.ACTIVITY_ID,-1),
        ca.activity,
        MMTT.REASON_ID,
        MMTT.TRANSACTION_REFERENCE,
        MMTT.COMPLETION_TRANSACTION_ID,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        wfs.PROJECT_ID,
        wfs.TASK_ID
FROM
        BOM_OPERATION_RESOURCES BOR,
        WIP_FLOW_SCHEDULES  wfs,
        BOM_DEPARTMENTS BD,
        BOM_RESOURCES BR,
        CST_ACTIVITIES CA,
        BOM_OPERATION_SEQUENCES BOS,
--        BOM_OPERATIONAL_ROUTINGS ROUT,
        mtl_material_transactions_temp MMTT,
        mtl_parameters mp
WHERE
    	MMTT.transaction_temp_id = p_txn_temp_id
    AND MMTT.inventory_item_id = wfs.primary_item_id
    AND MMTT.organization_id = wfs.organization_Id
    AND MMTT.organization_id = mp.organization_id
--    AND ROUT.assembly_item_id = wfs.primary_item_id
--    AND ROUT.organization_id = wfs.organization_id
--    AND NVL(ROUT.alternate_routing_designator, -1) =
--                NVL(wfs.alternate_routing_designator, -1)
    AND MMTT.common_routing_seq_id = bos.routing_sequence_id
--  for implement ECO we only explode those operations with implementation date
    AND BOS.implementation_date is not null
    AND BOS.effectivity_date <=
	to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
    AND NVL(BOS.disable_date,
                  to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT))
               >= to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
    AND bos.operation_sequence_id = bor.operation_sequence_id
    AND wfs.organization_id = bd.organization_id
    AND bos.department_id = bd.department_id
    AND wfs.organization_id = br.organization_id
    AND bor.resource_id = br.resource_id
    AND wfs.wip_entity_id = MMTT.transaction_source_id
    AND wfs.organization_id = MMTT.organization_id
--  for implement ECO we only explode those undeleted resource
    AND (bor.acd_type <> 3 or bor.acd_type is null)
    AND bor.autocharge_type <> 2 -- basically we charge it for everything except for manual
    AND br.cost_element_id in (3, 4)
    AND bor.usage_rate_or_amount <> 0
    AND (bos.count_point_type in (1, 2)
	 OR (mmtt.transaction_action_id = 30
	     AND Nvl(mmtt.operation_seq_num,-1) <> -1
	     AND wip_flow_utilities.event_to_lineop_seq_num(
			  bos.routing_sequence_id,
			  to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT),
			  bos.operation_seq_num) = mmtt.operation_seq_num)) --CFM Scrap. Resources are charged at the scrap line op even if the events are non-autocharge operations.
    AND DECODE (BOR.BASIS_TYPE,
                        1, MMTT.TRANSACTION_QUANTITY,
                        2, DECODE(wfs.QUANTITY_COMPLETED,
                                            0, 1,
                                            0 ),
                                   0 ) <> 0
    AND Decode (BOR.BASIS_TYPE,
		2, Decode(WFS.SCHEDULED_FLAG,
			  1,MMTT.TRANSACTION_ACTION_ID,
			  0),
		0) <> 30 -- Lot based resources are not charged for scheduled cfm scrap
    AND bor.activity_id = ca.activity_id (+)
    AND Nvl(bos.operation_type,1) = 1
    AND wip_flow_utilities.same_or_prior_lineop_safe(bos.routing_sequence_id,
						      to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT),
						      bos.operation_seq_num,
						      Nvl(mmtt.operation_seq_num,-1)) = 1 -- CFM Scrap
    GROUP BY
	BOS.OPERATION_SEQ_NUM,
       	BOS.DEPARTMENT_ID,
        BD.DEPARTMENT_CODE,
        BOR.RESOURCE_ID,
        BOR.RESOURCE_SEQ_NUM,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.USER_NAME,
        MMTT.LAST_UPDATE_LOGIN,
        MMTT.REQUEST_ID,
        MMTT.PROGRAM_APPLICATION_ID,
        MMTT.PROGRAM_ID,
        NVL(MMTT.PROGRAM_UPDATE_DATE, SYSDATE),
        MMTT.SOURCE_CODE,
        MMTT.SOURCE_LINE_ID,
        MMTT.ORGANIZATION_ID,
        MMTT.TRANSACTION_SOURCE_ID,
        MMTT.INVENTORY_ITEM_ID,
        MMTT.REPETITIVE_LINE_ID,
        MMTT.TRANSACTION_DATE,
        MMTT.ACCT_PERIOD_ID,
        BR.RESOURCE_CODE,
        BOR.BASIS_TYPE,
        BOR.AUTOCHARGE_TYPE,
        BOR.STANDARD_RATE_FLAG,
	BR.UNIT_OF_MEASURE,
        NVL(BOR.ACTIVITY_ID,-1),
        ca.activity,
        MMTT.REASON_ID,
        MMTT.TRANSACTION_REFERENCE,
        MMTT.COMPLETION_TRANSACTION_ID,
        wfs.PROJECT_ID,
        wfs.TASK_ID,
	/* although will pass compilation, but will get a run
	   time sql error - without these two in group by */
        MP.ORGANIZATION_ID,
        MP.ORGANIZATION_CODE;

	-- Taking care of the Activity update in two stages
	-- as we have an index on completion_txn_id
	UPDATE WIP_COST_TXN_INTERFACE
	SET ACTIVITY_ID = DECODE(ACTIVITY_ID,
				 -1, NULL,
				 ACTIVITY_ID)
	WHERE COMPLETION_TRANSACTION_ID = p_comp_txn_id;

	return 1;

exception

when others then
 return 0;

End Charge_Resources ;



function Charge_Item_Overheads(p_txn_temp_id in number,
			       p_rtg_rev_date in varchar2 ) return number is

Begin

INSERT INTO WIP_COST_TXN_INTERFACE
   (    transaction_id,
        last_update_date,
        last_updated_by,
        last_updated_by_name,
        creation_date,
        created_by,
        created_by_name,
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
        organization_code,
        wip_entity_id,
        entity_type,
        primary_item_id,
        line_id,
	line_code,
        transaction_date,
        acct_period_id,
        operation_seq_num,
        department_id,
        department_code,
        employee_id,
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
        activity_name,
        reason_id,
        reference,
        completion_transaction_id,
        po_header_id,
        po_line_id,
        repetitive_schedule_id,
        attribute_category,
        attribute1, attribute2, attribute3, attribute4, attribute5,
        attribute6, attribute7, attribute8, attribute9, attribute10,
        attribute11, attribute12, attribute13, attribute14, attribute15,
        project_id,
        task_id)
   SELECT
        NULL,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.USER_NAME,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.USER_NAME,
        MMTT.LAST_UPDATE_LOGIN,
        MMTT.REQUEST_ID,
        MMTT.PROGRAM_APPLICATION_ID,
        MMTT.PROGRAM_ID,
        NVL(MMTT.PROGRAM_UPDATE_DATE, SYSDATE),
        NULL,
        MMTT.SOURCE_CODE,
        MMTT.SOURCE_LINE_ID,
        2,
        1,
        2,
        MP.ORGANIZATION_ID,
        MP.ORGANIZATION_CODE,
        MMTT.TRANSACTION_SOURCE_ID,
        4,
        MMTT.INVENTORY_ITEM_ID,
        MMTT.REPETITIVE_LINE_ID,
	g_line_code,                    -- the global line code variable
        MMTT.TRANSACTION_DATE,
        MMTT.ACCT_PERIOD_ID,
        BOS.OPERATION_SEQ_NUM,
        BOS.DEPARTMENT_ID,
        BD.DEPARTMENT_CODE,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        1,      -- Per Item
        1,      -- WWIP_MOVE
        NULL,
        NVL(MMTT.transaction_quantity, 0),
        MMTT.TRANSACTION_UOM,
        NVL(MMTT.primary_quantity, 0),
        MMTT.ITEM_PRIMARY_UOM_CODE,
        NULL,
        NULL,
        NULL,
        MMTT.REASON_ID,
        MMTT.TRANSACTION_REFERENCE,
        MMTT.COMPLETION_TRANSACTION_ID,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        wfs.PROJECT_ID,
        wfs.TASK_ID
    FROM
        BOM_DEPARTMENTS bd,
        BOM_OPERATION_SEQUENCES bos,
        WIP_FLOW_SCHEDULES wfs,
--        BOM_OPERATIONAL_ROUTINGS BOR,
        mtl_material_transactions_temp mmtt,
        mtl_parameters mp
    WHERE
    	MMTT.transaction_temp_id = p_txn_temp_id
    AND MMTT.transaction_source_id = wfs.wip_entity_id
    AND MMTT.inventory_item_id = wfs.primary_item_id
    AND MMTT.organization_id = wfs.organization_Id
    AND MMTT.organization_id = mp.organization_id
--    AND BOR.assembly_item_id = wfs.primary_item_id
--    AND BOR.organization_id = wfs.organization_id
--    AND NVL(BOR.alternate_routing_designator, -1) =
--                NVL(wfs.alternate_routing_designator, -1)
    AND MMTT.common_routing_seq_id = bos.routing_sequence_id
--  for implement ECO we only explode those operations with implementation date
    AND BOS.implementation_date is not null
    AND BOS.effectivity_date <=
	to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
    AND NVL(BOS.disable_date,
                  to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT))
               >= to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
    AND wfs.organization_id = bd.organization_id
    AND bos.department_id = bd.department_id
    AND (bos.count_point_type in (1, 2)  -- ovhd for autocharge operations
	 OR (mmtt.transaction_action_id = 30
	     AND Nvl(mmtt.operation_seq_num,-1) <> -1
	     AND wip_flow_utilities.event_to_lineop_seq_num(
			  bos.routing_sequence_id,
			  to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT),
			  bos.operation_seq_num) = mmtt.operation_seq_num)) --CFM Scrap. Overheads are charged at the scrap line op even if the events are non-autocharge operations.
    AND Nvl(bos.operation_type,1) = 1
    AND wip_flow_utilities.same_or_prior_lineop_safe(bos.routing_sequence_id,
						      to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT),
						      bos.operation_seq_num,
						      Nvl(mmtt.operation_seq_num,-1)) = 1; -- CFM Scrap
    return 1;

exception

when others then
 return 0;

end Charge_Item_Overheads;


function Charge_Lot_Overheads(p_txn_temp_id in number,
			      p_rtg_rev_date in varchar2 ) return number is

Begin

INSERT INTO WIP_COST_TXN_INTERFACE
   (    transaction_id,
        last_update_date,
        last_updated_by,
        last_updated_by_name,
        creation_date,
        created_by,
        created_by_name,
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
        organization_code,
        wip_entity_id,
        entity_type,
        primary_item_id,
        line_id,
	line_code,
        transaction_date,
        acct_period_id,
        operation_seq_num,
        department_id,
        department_code,
        employee_id,
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
        activity_name,
        reason_id,
        reference,
        completion_transaction_id,
        po_header_id,
        po_line_id,
        repetitive_schedule_id,
        attribute_category,
        attribute1, attribute2, attribute3, attribute4, attribute5,
        attribute6, attribute7, attribute8, attribute9, attribute10,
        attribute11, attribute12, attribute13, attribute14, attribute15,
        project_id,
        task_id)
   SELECT
        NULL,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.USER_NAME,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.USER_NAME,
        MMTT.LAST_UPDATE_LOGIN,
        MMTT.REQUEST_ID,
        MMTT.PROGRAM_APPLICATION_ID,
        MMTT.PROGRAM_ID,
        NVL(MMTT.PROGRAM_UPDATE_DATE, SYSDATE),
        NULL,
        MMTT.SOURCE_CODE,
        MMTT.SOURCE_LINE_ID,
        2,
        1,
        2,
        MP.ORGANIZATION_ID,
        MP.ORGANIZATION_CODE,
        MMTT.TRANSACTION_SOURCE_ID,
        4,
        MMTT.INVENTORY_ITEM_ID,
        MMTT.REPETITIVE_LINE_ID,
	g_line_code,                    -- the global line code variable
        MMTT.TRANSACTION_DATE,
        MMTT.ACCT_PERIOD_ID,
        BOS.OPERATION_SEQ_NUM,
        BOS.DEPARTMENT_ID,
        BD.DEPARTMENT_CODE,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        2,      -- Per Lot
        1,      -- WWIP_MOVE
        NULL,
	/* Bug 5472762 - Modified the following DECODE to derive correct transaction quantity*/
        DECODE( wfs.QUANTITY_COMPLETED + MMTT.PRIMARY_QUANTITY + wfs.QUANTITY_SCRAPPED,
                MMTT.PRIMARY_QUANTITY, Decode(Sign(mmtt.primary_quantity),1,1,-1),
                0, -1,
                0
         ),
        MMTT.TRANSACTION_UOM,
	/* Bug 5472762 - Modified the following DECODE to derive correct primary quantity*/
        DECODE( wfs.QUANTITY_COMPLETED + MMTT.PRIMARY_QUANTITY + wfs.QUANTITY_SCRAPPED,
                MMTT.PRIMARY_QUANTITY, Decode(Sign(mmtt.primary_quantity),1,1,-1),
                0, -1,
                0
         ),
        MMTT.ITEM_PRIMARY_UOM_CODE,
        NULL,
        NULL,
        NULL,
        MMTT.REASON_ID,
        MMTT.TRANSACTION_REFERENCE,
        MMTT.COMPLETION_TRANSACTION_ID,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL,
        wfs.PROJECT_ID,
        wfs.TASK_ID
    FROM
        BOM_DEPARTMENTS bd,
        BOM_OPERATION_SEQUENCES bos,
        WIP_flow_schedules wfs,
--        BOM_OPERATIONAL_ROUTINGS BOR,
        mtl_material_transactions_temp mmtt,
        mtl_parameters mp
    WHERE
    	MMTT.transaction_temp_id = p_txn_temp_id
    AND MMTT.transaction_source_id = wfs.wip_entity_id
    AND MMTT.inventory_item_id = wfs.primary_item_id
    AND MMTT.organization_id = wfs.organization_Id
    AND MMTT.organization_id = mp.organization_id
--    AND BOR.assembly_item_id = wfs.primary_item_id
--    AND BOR.organization_id = wfs.organization_id
--    AND NVL(BOR.alternate_routing_designator, -1) =
--                NVL(wfs.alternate_routing_designator, -1)
    AND MMTT.common_routing_seq_id = bos.routing_sequence_id
    AND decode( NVL(wfs.Quantity_Completed, 0),
                                0, 1,
		0 ) <> 0
--  for implement ECO we only explode those operations with implementation date
    AND BOS.implementation_date is not null
    AND BOS.effectivity_date <=
	to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
    AND NVL(BOS.disable_date,
                  to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT))
               >= to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
    AND wfs.organization_id = bd.organization_id
    AND bos.department_id = bd.department_id
    AND (bos.count_point_type in (1, 2)  -- ovhd for autocharge operations
	 OR (mmtt.transaction_action_id = 30
	     AND Nvl(mmtt.operation_seq_num,-1) <> -1
	     AND wip_flow_utilities.event_to_lineop_seq_num(
			  bos.routing_sequence_id,
			  to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT),
			  bos.operation_seq_num) = mmtt.operation_seq_num)) --CFM Scrap. Overheads are charged at the scrap line op even if the events are non-autocharge operations.
    AND Nvl(bos.operation_type,1) = 1
    AND Decode(WFS.SCHEDULED_FLAG,
	       1,MMTT.TRANSACTION_ACTION_ID,
	       0) <> 30	-- Lot based ovhds are not charged for scheduled cfm scrap
    AND wip_flow_utilities.same_or_prior_lineop_safe(bos.routing_sequence_id,
						      to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT),
						      bos.operation_seq_num,
						      Nvl(mmtt.operation_seq_num,-1)) = 1; -- CFM Scrap

    return 1;

exception
when others then
 return 0;


end Charge_Lot_Overheads;




/* *********************************************************************
			Public Functions
***********************************************************************/
Function Charge_Resource_Overhead (p_header_id in number,
			p_rtg_rev_date in varchar2) return number is

/* ********************************************************
 	Cursor to get all Unique Flow Completions from MMTT
   ******************************************************** */
   CURSOR Flow_Completion (header_id number) is
   SELECT completion_transaction_id,
	  transaction_temp_id,
	  repetitive_line_id
   FROM   mtl_material_transactions_temp
   WHERE  transaction_header_id = header_id
          AND transaction_source_type_id = 5
          AND UPPER(NVL(flow_schedule,'N')) = 'Y'
          AND transaction_action_id in (31, 32, 30)-- CFM Scrap
	  AND process_flag = 'Y'
	  AND wip_entity_type = 4 ;

/* ********************************************************
        Cursor to get all PHANTOMS for  Flow Completions
	 The phantoms must be in a count-point operation
	 and also an ECO implemented operation
   ******************************************************** */
   CURSOR phantoms (header_id number) is
   SELECT mmtt.inventory_item_id  phantom_item_id,
          mmtt.operation_seq_num*(-1) operation_seq_num,
          mmtt.completion_transaction_id,
          mmtt.transaction_temp_id,
          mmtt.repetitive_line_id
   FROM   mtl_material_transactions_temp        mmtt,
          wip_flow_schedules                    wfs,
          bom_operational_routings              bor,
          bom_operation_sequences               bos
   WHERE
              mmtt.transaction_header_id = header_id
          AND mmtt.transaction_source_type_id = 5
          AND UPPER(NVL(mmtt.flow_schedule,'N')) = 'Y'
          AND mmtt.transaction_action_id in (1, 27, 33, 34)
          AND mmtt.operation_seq_num < 0     -- phantoms only
          AND mmtt.process_flag = 'Y'
          AND mmtt.wip_entity_type = 4
          AND MMTT.transaction_source_id = wfs.wip_entity_id
          AND MMTT.organization_id = wfs.organization_id
          AND wfs.primary_item_id = bor.assembly_item_id
          AND wfs.organization_id = bor.organization_id
          AND NVL(wfs.alternate_routing_designator, -1)
              = NVL(bor.alternate_routing_designator, -1)
     -- for implement ECO the routing must be not pending from ecn
          AND bor.pending_from_ecn is null
          AND bor.common_routing_sequence_id = bos.routing_sequence_id
--  for implement ECO we only explode those operations with implementation date
          AND BOS.implementation_date is not null
    	  AND bos.effectivity_date <=
        	to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
    	  AND NVL(bos.disable_date,
                  to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT))
               >= to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
          AND bos.operation_seq_num = mmtt.operation_seq_num*(-1)
          AND Nvl(bos.operation_type,1) = 1
          AND bos.count_point_type in (1, 2)
   /* Start of fix for bug 2743096: To bring in records from mmtt where
      phantoms are attached to default operation sequence 1. */
   UNION
   SELECT mmtt.inventory_item_id  phantom_item_id,
          mmtt.operation_seq_num*(-1) operation_seq_num,
          mmtt.completion_transaction_id,
          mmtt.transaction_temp_id,
          mmtt.repetitive_line_id
   FROM   mtl_material_transactions_temp        mmtt,
          wip_flow_schedules                    wfs,
          bom_operational_routings              bor,
          bom_operation_sequences               bos
   WHERE
              mmtt.transaction_header_id = header_id
          AND mmtt.transaction_source_type_id = 5
          AND UPPER(NVL(mmtt.flow_schedule,'N')) = 'Y'
          AND mmtt.transaction_action_id in (1, 27, 33, 34)
          AND mmtt.operation_seq_num < 0     -- phantoms only
          AND mmtt.process_flag = 'Y'
          AND mmtt.wip_entity_type = 4
          AND MMTT.transaction_source_id = wfs.wip_entity_id
          AND MMTT.organization_id = wfs.organization_id
          AND wfs.primary_item_id = bor.assembly_item_id
          AND wfs.organization_id = bor.organization_id
          AND NVL(wfs.alternate_routing_designator, -1)
              = NVL(bor.alternate_routing_designator, -1)
     -- for implement ECO the routing must be not pending from ecn
          AND bor.pending_from_ecn is null
          AND bor.common_routing_sequence_id = bos.routing_sequence_id
--  for implement ECO we only explode those operations with implementation date
          AND BOS.implementation_date is not null
    	  AND bos.effectivity_date <=
        	to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
    	  AND NVL(bos.disable_date,
                  to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT))
               >= to_date(p_rtg_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
          AND mmtt.operation_seq_num = -1 /* for phantoms attached to op seq 1 */
          AND Nvl(bos.operation_type,1) = 1
          AND bos.count_point_type in (1, 2);
   /* End of fix for bug 2743096 */

   x_primary_uom VARCHAR2(3);
   x_primary_txn_qty NUMBER := 0;
   x_success number := 0;
   x_org_id     number;         /* phantom costing */

   BEGIN

   FOR Com_Rec IN Flow_Completion(p_header_id) LOOP
       	x_success := 0;

	begin
	 /* The PK for wip_lines is just Line_id */
	 select line_code into g_line_code
	 from wip_lines
	 where line_id = Com_Rec.repetitive_line_id ;

	 exception

	  when no_data_found then
	    g_line_code := null ;
	end ;

	x_success := Charge_Resources(Com_Rec.transaction_temp_id,
				      Com_Rec.completion_transaction_id,
				      p_rtg_rev_date );
	   if (x_success<>0) then
	    	x_success := Charge_Item_Overheads(Com_Rec.transaction_temp_id,
				      p_rtg_rev_date );
	    	if (x_success<>0) then
		   x_success := Charge_Lot_Overheads(Com_Rec.transaction_temp_id,
				      p_rtg_rev_date );
	    	else
		   return x_success ;
	    	end if;
	   else
	    	return x_success ;
	   end if;

    END LOOP ;

    /* phantom costing */
    SELECT organization_id
    INTO x_org_id
    FROM mtl_material_transactions_temp
    WHERE transaction_header_id = p_header_id
    AND rownum = 1;

    IF (wip_globals.USE_PHANTOM_ROUTINGS(x_org_id) = WIP_CONSTANTS.YES) THEN
        FOR Phan_Rec IN phantoms(p_header_id) LOOP
            x_success  := 0;

            x_success := WIP_EXPLODE_PHANTOM_RTGS.charge_flow_resource_ovhd(
                  x_org_id,
                  phan_rec.phantom_item_id,
                  phan_rec.operation_seq_num,
                  phan_rec.completion_transaction_id,
                  phan_rec.transaction_temp_id,
                  phan_rec.repetitive_line_id,
                  p_rtg_rev_date);

            if (x_success = 0) then
                return x_success;
            end if;
        END LOOP;

        /* delete phantoms from MMTT before moved to MMT */
        delete mtl_material_transactions_temp
        where
              transaction_header_id = p_header_id
          AND transaction_source_type_id = 5
          AND UPPER(NVL(flow_schedule,'N')) = 'Y'
          AND transaction_action_id in (1, 27, 33, 34)
          AND operation_seq_num < 0
          AND process_flag = 'Y'
          AND wip_entity_type = 4 ;

    END IF;
    /* end of phantom costing */

    return 1;
exception

when No_Data_Found then
return 1;

when others then
return 0;

end Charge_Resource_Overhead ;

/********************************************************************
    This function will be called from cmlctw - the cost transaction
    worker for both the resource as well as the overheads to validate
    the process phase for the group_id,
       - This will be called only for cfm flow schedules, so we don not
	 have to worry about the wip_entity_type in here.
**********************************************************************/

function Validate_Resource_Overhead (p_group_id in number,
				     p_err_mesg out NOCOPY varchar) return number is
/* Cursor for the rows that will fail validation */
CURSOR Failure_Cursor(p_group_id in number) is
        Select
                Transaction_id
        from WIP_COST_TXN_INTERFACE
        where group_id = p_group_id
        and   process_phase = 1;  /* The Process Phase is 1 */
x_error_mesg varchar2(240);
begin


    fnd_message.set_name('WIP', 'WIP_FLOW_RES_OVHD_VALIDATION');
    x_error_mesg := fnd_message.get ;

     For fail_rec in Failure_Cursor(p_group_id) LOOP

	     Update WIP_COST_TXN_INTERFACE
	     set PROCESS_STATUS = 3 /* set the process_phase to error */
	     where transaction_id = fail_rec.transaction_id ;

	     Insert into WIP_TXN_INTERFACE_ERRORS
	     	( 	transaction_id,
			error_column,
			error_message,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			request_id,
			program_application_id,
			program_id,
			program_update_date)
	     Select
			transaction_id,
			'PROCESS_PHASE',
			x_error_mesg,
			SYSDATE,
			last_updated_by,
			SYSDATE,
			last_updated_by,
			last_update_login,
			request_id,
			program_application_id,
			program_id,
			SYSDATE
	     from 	WIP_COST_TXN_INTERFACE
	     where transaction_id = fail_rec.transaction_id ;

     end LOOP ;


     return 1 ;

  exception
   when others then
	p_err_mesg := 'WIP_FLOW_CHARGE_UTILITIES.VALIDATE_RESOURCE_OVERHEAD' ||
			substr(SQLERRM,1,150);
	return 0;

end Validate_Resource_Overhead ;


end Wip_Flow_Charge_Utilities;

/
