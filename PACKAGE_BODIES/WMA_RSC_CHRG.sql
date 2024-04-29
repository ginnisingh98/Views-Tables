--------------------------------------------------------
--  DDL for Package Body WMA_RSC_CHRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_RSC_CHRG" AS
/* $Header: wmafcub.pls 115.2 2002/12/13 07:53:08 rmahidha noship $ */
  g_line_code wip_lines.line_code%TYPE;
  function Charge_Resources (p_header_id IN NUMBER) return boolean is

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
          wlc.LAST_UPDATED_BY,
          NULL,
          SYSDATE,
          wlc.CREATED_BY,
          NULL,
          wlc.LAST_UPDATE_LOGIN,
          null,
          wlc.PROGRAM_APPLICATION_ID,
          wlc.PROGRAM_ID,
          NVL(wlc.PROGRAM_UPDATE_DATE, SYSDATE),
          NULL,
          wlc.SOURCE_CODE,
          -1,
          2,
          1,
          1,
          wlc.ORGANIZATION_ID,
          wlc.wip_entity_id,
          4,
          wlc.INVENTORY_ITEM_ID,
          wlc.REPETITIVE_LINE_ID,
          g_line_code,
          wlc.TRANSACTION_DATE,
          wlc.ACCT_PERIOD_ID,
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
          sum(BOR.USAGE_RATE_OR_AMOUNT * wlc.PRIMARY_QUANTITY),
   	  BR.UNIT_OF_MEASURE,
          sum(BOR.USAGE_RATE_OR_AMOUNT * wlc.primary_quantity),
  	  BR.UNIT_OF_MEASURE,
          NULL,
          NVL(BOR.ACTIVITY_ID,-1),
          wlc.reason_id,
          null,
          wlc.completion_transaction_id,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL,
          wlc.item_project_id,
          wlc.item_task_id
  FROM
          BOM_OPERATION_RESOURCES BOR,
          BOM_DEPARTMENTS BD,
          BOM_RESOURCES BR,
          CST_ACTIVITIES CA,
          BOM_OPERATION_SEQUENCES BOS,
          wip_lpn_completions wlc,
          bom_operational_routings bop
WHERE
    	wlc.header_id = p_header_id
    AND wlc.organization_id = bd.organization_id
    AND wlc.organization_id = br.organization_id
    AND bop.common_routing_sequence_id = bos.routing_sequence_id
    AND bop.assembly_item_id = wlc.inventory_item_id
    AND bop.organization_id = wlc.organization_id
    AND BOS.implementation_date is not null
    AND BOS.effectivity_date <= wlc.routing_revision_date
    AND NVL(BOS.disable_date, wlc.routing_revision_date)  >= wlc.routing_revision_date
    AND bos.operation_sequence_id = bor.operation_sequence_id
    AND bos.department_id = bd.department_id
    AND bor.resource_id = br.resource_id
    AND (bor.acd_type <> 3 or bor.acd_type is null)
    AND bor.autocharge_type <> 2
    AND br.cost_element_id in (3, 4)
    AND bor.usage_rate_or_amount <> 0
    AND bos.count_point_type in (1, 2)
    AND bor.activity_id = ca.activity_id (+)
    AND Nvl(bos.operation_type,1) = 1
    GROUP BY
  	BOS.OPERATION_SEQ_NUM,
         	BOS.DEPARTMENT_ID,
          BD.DEPARTMENT_CODE,
          BOR.RESOURCE_ID,
          BOR.RESOURCE_SEQ_NUM,
  	  WLC.LAST_UPDATED_BY,
          WLC.CREATED_BY,
          WLC.LAST_UPDATE_LOGIN,
          WLC.PROGRAM_APPLICATION_ID,
          WLC.PROGRAM_ID,
          NVL(WLC.PROGRAM_UPDATE_DATE, SYSDATE),
          WLC.SOURCE_CODE,
          WLC.ORGANIZATION_ID,
          WLC.WIP_ENTITY_ID,
          WLC.INVENTORY_ITEM_ID,
          WLC.REPETITIVE_LINE_ID,
          WLC.TRANSACTION_DATE,
          WLC.ACCT_PERIOD_ID,
          BR.RESOURCE_CODE,
          BOR.BASIS_TYPE,
          BOR.AUTOCHARGE_TYPE,
          BOR.STANDARD_RATE_FLAG,
  	BR.UNIT_OF_MEASURE,
          NVL(BOR.ACTIVITY_ID,-1),
          WLC.REASON_ID,
          wlc.item_project_id,
          wlc.item_task_id,
          wlc.completion_transaction_id;
--          WLC.TRANSACTION_REFERENCE,
--          WLC.COMPLETION_TRANSACTION_ID;
  	return true;
  End Charge_Resources ;



  function Charge_Item_Overheads(p_header_id in number) return boolean is

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
          WLC.LAST_UPDATED_BY,
          NULL,
          SYSDATE,
          WLC.CREATED_BY,
          NULL,
          WLC.LAST_UPDATE_LOGIN,
          null, --mmtt.REQUEST_ID,
          WLC.PROGRAM_APPLICATION_ID,
          WLC.PROGRAM_ID,
          NVL(WLC.PROGRAM_UPDATE_DATE, SYSDATE),
          NULL,
          WLC.SOURCE_CODE,
          NULL, --MMTT.SOURCE_LINE_ID,
          2,
          1,
          2,
          WLC.ORGANIZATION_ID,
          WLC.WIP_ENTITY_ID,
          4,
          WLC.INVENTORY_ITEM_ID,
          WLC.REPETITIVE_LINE_ID,
  	  g_line_code,                    -- the global line code variable
          WLC.TRANSACTION_DATE,
          WLC.ACCT_PERIOD_ID,
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
          WLC.transaction_quantity,
          WLC.TRANSACTION_UOM,
          WLC.primary_quantity,
          WLC.TRANSACTION_UOM,
          NULL,
          NULL,
          WLC.REASON_ID,
          NULL, --WLC.TRANSACTION_REFERENCE,
          WLC.COMPLETION_TRANSACTION_ID,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL,
          wlc.ITEM_PROJECT_ID,
          wlc.ITEM_TASK_ID
      FROM
          BOM_DEPARTMENTS bd,
          BOM_OPERATION_SEQUENCES bos,
          wip_lpn_completions wlc,
          bom_operational_routings bop
      WHERE
          WLC.header_id = p_header_id
      AND wlc.organization_id = bd.organization_id
      AND bop.common_routing_sequence_id = bos.routing_sequence_id
      AND bop.assembly_item_id = wlc.inventory_item_id
      AND bop.organization_id = wlc.organization_id
  --  for implement ECO we only explode those operations with implementation date
      AND BOS.implementation_date is not null
      AND BOS.effectivity_date <= wlc.routing_revision_date
      AND NVL(BOS.disable_date,wlc.routing_revision_date)  >= wlc.routing_revision_date
      AND bos.department_id = bd.department_id
      AND bos.count_point_type in (1, 2)  -- ovhd for autocharge operations
      AND Nvl(bos.operation_type,1) = 1;
    return true;

  exception

  when others then
   return false;

  end Charge_Item_Overheads;


  function Charge_Lot_Overheads(p_header_id in number) return boolean is

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
          WLC.LAST_UPDATED_BY,
          NULL,
          SYSDATE,
          WLC.CREATED_BY,
          NULL,
          WLC.LAST_UPDATE_LOGIN,
          null, --mmtt.REQUEST_ID,
          WLC.PROGRAM_APPLICATION_ID,
          WLC.PROGRAM_ID,
          NVL(WLC.PROGRAM_UPDATE_DATE, SYSDATE),
          NULL,
          WLC.SOURCE_CODE,
          NULL, --MMTT.SOURCE_LINE_ID,
          2,
          1,
          2,
          WLC.ORGANIZATION_ID,
          WLC.WIP_ENTITY_ID,
          4,
          WLC.INVENTORY_ITEM_ID,
          WLC.REPETITIVE_LINE_ID,
  	  g_line_code,                    -- the global line code variable
          WLC.TRANSACTION_DATE,
          WLC.ACCT_PERIOD_ID,
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
          wlc.transaction_quantity,
          WLC.TRANSACTION_UOM,
          wlc.transaction_quantity,
          WLC.transaction_uom,
          NULL,
          NULL,
          wlc.REASON_ID,
          NULL, --MMTT.TRANSACTION_REFERENCE,
          wlc.COMPLETION_TRANSACTION_ID,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL,
          NULL, NULL, NULL, NULL, NULL,
          wlc.item_project_id,
          wlc.item_task_id
      FROM
          BOM_DEPARTMENTS bd,
          BOM_OPERATION_SEQUENCES bos,
          wip_lpn_completions wlc,
          bom_operational_routings bop
      WHERE
      	WLC.header_id = p_header_id
      AND wlc.organization_id = bd.organization_id
      AND bop.common_routing_sequence_id = bos.routing_sequence_id
      AND bop.organization_id = wlc.organization_id
      AND bop.assembly_item_id = wlc.inventory_item_id
--      AND decode( NVL(wfs.Quantity_Completed, 0),--????
--                                  0, 1,
--  		0 ) <> 0
  --  for implement ECO we only explode those operations with implementation date
      AND BOS.implementation_date is not null
      AND BOS.effectivity_date <= wlc.routing_revision_date
      AND NVL(BOS.disable_date,wlc.routing_revision_date) >= wlc.routing_revision_date
      AND bos.department_id = bd.department_id
      AND bos.count_point_type in (1, 2)  -- ovhd for autocharge operations
      AND Nvl(bos.operation_type,1) = 1;
      return true;

  exception
  when others then
   return false;


  end Charge_Lot_Overheads;




  Function Charge_Resource_Overhead (p_header_id in number)
    return boolean is
    l_repLineId NUMBER;
    x_primary_uom VARCHAR2(3);
    x_primary_txn_qty NUMBER := 0;
    x_org_id     number;         /* phantom costing */

  BEGIN
    BEGIN
      SELECT repetitive_line_id
        INTO l_repLineId
        FROM wip_lpn_completions
       WHERE header_id = p_header_id;

      EXCEPTION
        when others then
          null;--drop it
    END;

    BEGIN
      /* The PK for wip_lines is just Line_id */
      SELECT line_code
        INTO g_line_code
  	 FROM wip_lines
  	WHERE line_id = l_repLineId ;

      EXCEPTION
  	  when no_data_found then
  	    g_line_code := null ;
    END;
    if(Charge_Resources(p_header_id)) then
      if(Charge_Item_Overheads(p_header_id)) then
-- checking out concept of lot based resource charging for WoLs
-- not linked to a schedule
        return  Charge_Lot_Overheads(p_header_id);
      END if;
    END if;

    return false ;

      EXCEPTION
        when No_Data_Found then
        return true;

        when others then
        return false;
  END Charge_Resource_Overhead ;
end wma_rsc_chrg;

/
