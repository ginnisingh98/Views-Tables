--------------------------------------------------------
--  DDL for Package Body WIP_MATERIAL_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MATERIAL_PROCESSOR" AS
/* $Header: wipmatpb.pls 115.8 2003/05/16 18:26:13 ccai ship $ */

  FUNCTION wroUpdate(p_header_id IN NUMBER)
    return boolean IS
    l_wlcRec wip_lpn_completions%ROWTYPE;
    BEGIN
      SELECT *
        INTO l_wlcRec
        FROM wip_lpn_completions
       WHERE header_id = p_header_id;

      UPDATE wip_requirement_operations
         SET quantity_issued = quantity_issued - ROUND(l_wlcRec.primary_quantity, 6),
             quantity_allocated = greatest(0, quantity_allocated + ROUND(l_wlcRec.primary_quantity, 6)),
             last_update_date = l_wlcRec.last_update_date,
             last_updated_by = l_wlcRec.last_updated_by,
             request_id = -1,
             program_application_id = decode(l_wlcRec.program_application_id,
                                             -1, program_application_id,
                                             l_wlcRec.program_application_id),
             program_update_date = nvl(l_wlcRec.program_update_date, program_update_date)
       WHERE wip_entity_id = l_wlcRec.wip_entity_id
         AND organization_id = l_wlcRec.organization_id
         AND repetitive_schedule_id is null
         AND operation_seq_num = l_wlcRec.operation_seq_num
         AND inventory_item_id = l_wlcRec.inventory_item_id;

      if(SQL%NOTFOUND) then
        return FALSE;
      else
        return TRUE;
      end if;
    --header_id is PK of wip_lpn_completions, so TOO_MANY_ROWS will never occur

    EXCEPTION
      WHEN NO_DATA_FOUND then
        return FALSE;
  END wroUpdate;

  FUNCTION wroInsert(p_header_id IN NUMBER)
    return boolean IS
      l_wlcRec wip_lpn_completions%ROWTYPE;
    BEGIN
      SELECT *
        INTO l_wlcRec
        FROM wip_lpn_completions
       WHERE header_id = p_header_id;

       INSERT INTO WIP_REQUIREMENT_OPERATIONS
            (INVENTORY_ITEM_ID,
             ORGANIZATION_ID,
             WIP_ENTITY_ID,
             OPERATION_SEQ_NUM,
             REPETITIVE_SCHEDULE_ID,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             DEPARTMENT_ID,
             DATE_REQUIRED,
             REQUIRED_QUANTITY,
             QUANTITY_ISSUED,
             QUANTITY_PER_ASSEMBLY,
             WIP_SUPPLY_TYPE,
             MRP_NET_FLAG,
             REQUEST_ID,
             PROGRAM_APPLICATION_ID,
             PROGRAM_ID,
             PROGRAM_UPDATE_DATE,
             SUPPLY_SUBINVENTORY,
             SUPPLY_LOCATOR_ID,
             MPS_DATE_REQUIRED,
             MPS_REQUIRED_QUANTITY,
             SEGMENT1,
             SEGMENT2,
             SEGMENT3,
             SEGMENT4,
             SEGMENT5,
             SEGMENT6,
             SEGMENT7,
             SEGMENT8,
             SEGMENT9,
             SEGMENT10,
             SEGMENT11,
             SEGMENT12,
             SEGMENT13,
             SEGMENT14,
             SEGMENT15,
             SEGMENT16,
             SEGMENT17,
             SEGMENT18,
             SEGMENT19,
             SEGMENT20)
         SELECT l_wlcRec.inventory_item_id,
                l_wlcRec.organization_id,
                l_wlcRec.wip_entity_id,
                l_wlcRec.operation_seq_num,
                NULL,
                SYSDATE,
                l_wlcRec.last_updated_by,
                -1,
                SYSDATE,
                l_wlcRec.last_updated_by,
                NULL,--l_wlcRec.dept_id...look in WIP_OPERATIONS table if you need this val
                l_wlcRec.transaction_date,
                0,
                ROUND(l_wlcRec.primary_quantity, 6) * -1,
                0,
                wip_constants.PUSH, --WPUSH,--WIP_SUPPLY_TYPE, set to push???
                wip_constants.SUPPLY_NET, --WYES, --MRP_NET_FLAG, set to yes???
                to_number(NULL), --set request id to null?
                DECODE(l_wlcRec.program_application_id, -1, NULL, l_wlcRec.program_application_id),
                DECODE(l_wlcRec.program_id, -1, NULL, l_wlcRec.program_application_id),
                l_wlcRec.program_update_date,
                WIP_SUPPLY_SUBINVENTORY,
                WIP_SUPPLY_LOCATOR_ID,
                l_wlcRec.transaction_date,
                0,
                SEGMENT1,
                SEGMENT2,
                SEGMENT3,
                SEGMENT4,
                SEGMENT5,
                SEGMENT6,
                SEGMENT7,
                SEGMENT8,
                SEGMENT9,
                SEGMENT10,
                SEGMENT11,
                SEGMENT12,
                SEGMENT13,
                SEGMENT14,
                SEGMENT15,
                SEGMENT16,
                SEGMENT17,
                SEGMENT18,
                SEGMENT19,
                SEGMENT20
           FROM MTL_SYSTEM_ITEMS
          WHERE ORGANIZATION_ID = l_wlcRec.organization_id
            AND INVENTORY_ITEM_ID = l_wlcRec.inventory_item_id;

      RETURN TRUE;


    EXCEPTION
      WHEN OTHERS then --invalid insertion into wip_requirement_operations or invalid header_id
        return FALSE;
  END wroInsert;


  --the public procedure for this package. first try to update an existing requirement
  --if it don't exist, insert a new one (push txn case)
  --if for some reason that fails, return an error
  PROCEDURE processItem(p_header_id IN  NUMBER,
                        x_err_msg    OUT NOCOPY VARCHAR2,
                        x_return_status   OUT NOCOPY VARCHAR2) IS BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    if(not wroUpdate(p_header_id)) then
      if(not wroInsert(p_header_id)) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_err_msg := fnd_message.get_string('WIP', 'TRANSACTION_FAILED') || ' ' || fnd_message.get_string('WIP', 'OPERATION_PROCESSING_ERROR');
      end if;
    end if;

    exception
	when others then
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END processItem;
END wip_material_processor;

/
