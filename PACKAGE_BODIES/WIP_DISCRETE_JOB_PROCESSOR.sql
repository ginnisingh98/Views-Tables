--------------------------------------------------------
--  DDL for Package Body WIP_DISCRETE_JOB_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DISCRETE_JOB_PROCESSOR" AS
/* $Header: wipcmppb.pls 115.7 2002/11/28 19:28:03 rmahidha ship $ */


  PROCEDURE completeAssyItem(p_header_id IN NUMBER,
                             x_err_msg    OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2) IS

    l_rem_qty  NUMBER;
    l_op_qty NUMBER;
    l_ret_code NUMBER;
    l_ret_msg  VARCHAR2(240);--size???
    l_retVal VARCHAR2(4);--retval for inventory update kanban proc, sales order completions
    l_rowid  ROWID;
    l_wlcRec wip_lpn_completions%ROWTYPE;
    l_msgCount NUMBER;
    l_msgData VARCHAR2(240);

    BEGIN
      SAVEPOINT preProcessing;
      SELECT *
        INTO l_wlcRec
        FROM wip_lpn_completions
       WHERE p_header_id = header_id;

      WIP_WEIGHTED_AVG.FINAL_COMPLETE(
              p_org_id    => l_wlcRec.organization_id,
              p_wip_id    => l_wlcRec.wip_entity_id,
              p_pri_qty   => l_wlcRec.primary_quantity,
              p_final_cmp => l_wlcRec.final_completion_flag,
              p_ret_code  => l_ret_code,
              p_ret_msg   => l_ret_msg);
      if(l_ret_code <> 0) then
        x_err_msg :=  fnd_message.get_string('WIP', 'TRANSACTION_FAILED') || ' ' || l_ret_msg;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      UPDATE wip_lpn_completions
         SET final_completion_flag = nvl(l_wlcRec.final_completion_flag, 'N')
       WHERE header_id = p_header_id;--rowid = l_wlcRec.rowid;

      SELECT start_quantity - quantity_completed - quantity_scrapped, rowid
        INTO l_rem_qty, l_rowid
        FROM wip_discrete_jobs
       WHERE organization_id = l_wlcRec.organization_id
         AND wip_entity_id = l_wlcRec.wip_entity_id
         FOR UPDATE OF quantity_completed;

      --if between the form validation and processing a completion txn was committed
      --overcompletions not allowed
      if(l_rem_qty < round(l_wlcRec.primary_quantity, 6)) then
        x_err_msg :=  fnd_message.get_string('WIP', 'TRANSACTION_FAILED');
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      if(l_wlcRec.operation_seq_num > 0) then
        SELECT quantity_waiting_to_move
          INTO l_op_qty
          FROM wip_operations
         WHERE organization_id = l_wlcRec.organization_id
           AND wip_entity_id = l_wlcRec.wip_entity_id
           AND operation_seq_num = l_wlcRec.operation_seq_num
           FOR UPDATE OF quantity_waiting_to_move;

        if(l_op_qty < ROUND(l_wlcRec.primary_quantity,6)) then
          x_err_msg :=  fnd_message.get_string('WIP', 'TRANSACTION_FAILED') || ' ' || fnd_message.get_string ('WIP', 'OPERATION_PROCESSING_ERROR');
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;


        UPDATE wip_operations
           SET quantity_waiting_to_move = quantity_waiting_to_move -
                                            ROUND(l_wlcRec.primary_quantity,6),
               date_last_moved = l_wlcRec.transaction_date,
               last_updated_by = l_wlcRec.last_updated_by,
               last_update_date = sysdate,
               program_application_id = l_wlcRec.program_application_id,
               program_id = l_wlcRec.program_id,
               program_update_date = l_wlcRec.program_update_date
         WHERE organization_id = l_wlcRec.organization_id
           AND wip_entity_id = l_wlcRec.wip_entity_id
           AND operation_seq_num = l_wlcRec.operation_seq_num;
      end if;
      if(SQL%NOTFOUND) then
        x_err_msg :=  fnd_message.get_string('WIP', 'TRANSACTION_FAILED') || ' ' || fnd_message.get_string('WIP', 'OPERATION_PROCESSING_ERROR');
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      if(round(l_wlcRec.primary_quantity, 6) = l_rem_qty) then --txn completes the job
        UPDATE wip_discrete_jobs
           SET quantity_completed = quantity_completed +
                                      ROUND(l_wlcRec.primary_quantity,6),
               date_completed = l_wlcRec.transaction_date,
               status_type = 4,
               last_updated_by = l_wlcRec.last_updated_by,
               last_update_date = sysdate,
               program_application_id = l_wlcRec.program_application_id,
               program_id = l_wlcRec.program_id,
               program_update_date = l_wlcRec.program_update_date
         WHERE rowid = l_rowid;
      else --txn doesn't complete the job
        UPDATE wip_discrete_jobs
           SET quantity_completed = quantity_completed +
                                      ROUND(l_wlcRec.primary_quantity,6),
               last_updated_by = l_wlcRec.last_updated_by,
               last_update_date = sysdate,
               program_application_id = l_wlcRec.program_application_id,
               program_id = l_wlcRec.program_id,
               program_update_date = l_wlcRec.program_update_date
         WHERE rowid = l_rowid;
      end if;

      if(l_wlcRec.kanban_card_id is not null) then
        inv_kanban_pvt.update_card_supply_status(
                      x_return_status => l_retVal,
                      p_kanban_card_id => l_wlcRec.kanban_card_id,
                      p_supply_status => INV_Kanban_PVT.G_Supply_Status_Full,
                      p_document_type => 5, --discrete job
                      p_document_header_id => l_wlcRec.wip_entity_id);

        if(l_retVal <> fnd_api.G_RET_STS_SUCCESS) then
          x_err_msg := fnd_message.get_string('WIP', 'TRANSACTION_FAILED') || ' ' || fnd_message.get_string('WIP', 'DISCRETE_JOB_KANBAN_ERROR');
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
      end if;
    /*  wip_so_reservations.allocate_completion_to_so(l_wlcRec.organization_id,
                                                    l_wlcRec.wip_entity_id,
                                                    l_wlcRec.inventory_item_id,
                                                    l_wlcRec.header_id,
                                                    'WLC', --use wip_lpn_completions table
                                                    l_retVal,
                                                    l_msgCount,
                                                    l_msgData);
      if(l_retVal <> FND_API.G_RET_STS_SUCCESS) then
        x_err_msg := fnd_message.get_string('WIP', 'TRANSACTION_FAILED') || ' ' || l_msgData;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
    */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN others Then
      ROLLBACK TO SAVEPOINT preProcessing;
      x_return_status := FND_API.G_RET_STS_ERROR;

  END completeAssyItem;
END wip_discrete_job_processor;

/
