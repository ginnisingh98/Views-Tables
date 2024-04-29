--------------------------------------------------------
--  DDL for Package Body WIP_REBUILD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_REBUILD" AS
/* $Header: wiprbldb.pls 115.22 2004/06/02 18:07:20 kboonyap ship $ */

  procedure insert_job_interface(p_tempId IN NUMBER,
                             x_groupId OUT NOCOPY NUMBER) IS BEGIN

   select wip_job_schedule_interface_s.nextval
     into x_groupID
     from dual;

   INSERT INTO WIP_JOB_SCHEDULE_INTERFACE(
   creation_date,
   created_by,
   last_update_login,
   last_update_date,
   last_updated_by,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   load_type,
   group_id,
   scheduling_method,
   first_unit_start_date,
   job_name,
   description,
   primary_item_id,
   organization_id,
   process_phase,
   process_status,
   rebuild_item_id,
   rebuild_serial_number,
   parent_wip_entity_id,
   manual_rebuild_flag,
   activity_type,
   activity_cause,
   activity_source,
   priority,
   owning_department,
   tagout_required,
   shutdown_type)
   SELECT sysdate,
          mmtt.created_by,
          mmtt.last_update_login,
          sysdate,
          mmtt.last_updated_by,
          mmtt.request_id,
          mmtt.program_application_id,
          mmtt.program_id,
          mmtt.program_update_date,
          wip_constants.CREATE_EAM_JOB,
          x_groupID,
          wip_constants.routing,
          SYSDATE,
          mmtt.rebuild_job_name,
          msi.description,
          mmtt.rebuild_activity_id,
          mmtt.organization_id,
          wip_constants.ML_VALIDATION,
          wip_constants.pending,
          mmtt.rebuild_item_id,
          mmtt.rebuild_serial_number,
          mmtt.transaction_source_id,
          'N',
          meaa.activity_type_code,
          meaa.activity_cause_code,
          meaa.activity_source_code,
          to_number(meaa.priority_code),
          meaa.owning_department_id,
          meaa.tagging_required_flag,
          to_number(meaa.shutdown_type_code)
     FROM MTL_MATERIAL_TRANSACTIONS_TEMP mmtt,
          mtl_system_items msi,
          mtl_eam_asset_activities meaa
    WHERE transaction_temp_id = p_tempId
      and mmtt.rebuild_activity_id = msi.inventory_item_id (+)
      and mmtt.organization_id = msi.organization_id (+)
      and mmtt.rebuild_activity_id = meaa.asset_activity_id (+)
      and mmtt.organization_id = meaa.organization_id (+)
      and mmtt.rebuild_item_id = meaa.inventory_item_id (+)
      and nvl(mmtt.rebuild_serial_number, '@@@') =
          nvl(meaa.serial_number,'@@@'); /* Bug 3661984 */

  end insert_job_interface;

  procedure update_genealogy(p_tempId IN NUMBER,
                             x_retVal OUT NOCOPY VARCHAR2,
                             x_errMsg OUT NOCOPY VARCHAR2) IS

    l_rebuildSerNum VARCHAR2(30);
    l_rebuildItemID NUMBER;
    l_orgID NUMBER;
    l_txnDate DATE;
    l_assetNum VARCHAR2(30);
    l_assetGrpID NUMBER;
    l_serial_status NUMBER;  /* Bug 3655393 */

    l_msgCount NUMBER;
  BEGIN

    x_retVal := fnd_api.G_RET_STS_SUCCESS; --assume success

    select mmtt.rebuild_serial_number,
           mmtt.rebuild_item_id,
           mmtt.organization_id,
           mmtt.transaction_date,
           wdj.asset_number, --will need these eventually
           wdj.asset_group_id
      into l_rebuildSerNum,
           l_rebuildItemID,
           l_orgID,
           l_txnDate,
           l_assetNum,
           l_assetGrpID
      from mtl_material_transactions_temp mmtt,
           wip_discrete_jobs wdj
     where wdj.wip_entity_id = mmtt.transaction_source_id
       and mmtt.transaction_temp_id = p_tempId;

    --call genealogy API whether or not a serial exists. The eam procedure
    --will figure out what to do (if anything).
    /* Bug 3655393 - Should not call update_geneology if serial_status = 1
       or defined but not used.Not handling NO_DATA_FOUND as we do not want
       to call update_geneology, if there is no serial exists. Transaction
       should error out if no MSN record for corresponding
       rebuild_serial_number in mmtt*/

     /*Bug 3655393 - reset l_serial_status to 0 so that in case no rebuid
       serial number present also, update_geneology will be called*/
     l_serial_status := 0;

     if (l_rebuildSerNum is NOT NULL and
         l_rebuildItemID is NOT NULL) then
        select current_status
          into l_serial_status
          from mtl_serial_numbers
         where serial_number = l_rebuildSerNum
           and current_organization_id= l_orgID
           and inventory_item_id = l_rebuildItemID;
     end if;

     if (l_serial_status <> WIP_CONSTANTS.DEF_NOT_USED) then /*Bug 3655393*/
       wip_eam_genealogy_pvt.update_eam_genealogy(
         p_api_version => 1.0,
         p_object_type => 2, -- serial number
         p_serial_number => l_rebuildSerNum,
         p_inventory_item_id => l_rebuildItemID,
         p_organization_id => l_orgID,
         p_genealogy_type => 5, --asset/item releationship
         p_end_date_active => l_txnDate,
         x_return_status => x_retVal,
         x_msg_count => l_msgCount,
         x_msg_data => x_errMsg);
     end if;

  EXCEPTION when others then
    x_retVal := fnd_api.G_RET_STS_ERROR;
    fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
    fnd_message.set_token('ERROR_TEXT', 'wip_rebuild.update_genealogy');
    x_errMsg := fnd_message.get;
  end update_genealogy;

  procedure create_rebuild_job(p_tempId IN NUMBER,
                           x_retVal OUT NOCOPY VARCHAR2,
                           x_errMsg OUT NOCOPY VARCHAR2) IS

    l_groupId NUMBER;
    l_requestId NUMBER;
    l_phase VARCHAR2(240);
    l_status VARCHAR2(240);
    l_devPhase VARCHAR2(240);
    l_devStatus VARCHAR2(240);
    l_message VARCHAR2(240);
    l_success BOOLEAN;

    l_interface_record   WIP_EAMWORKORDER_PVT.work_order_interface_rec_type;
    --cursor to fetch details for the workorder to be created


    CURSOR workorder IS
    SELECT mmtt.created_by,
          mmtt.last_update_login,
          mmtt.last_updated_by,
          mmtt.request_id,
          mmtt.program_application_id,
          mmtt.program_id,
          mmtt.program_update_date,
          mmtt.rebuild_job_name,
          msi.description,
          mmtt.rebuild_activity_id,
          mmtt.organization_id,
          mmtt.rebuild_item_id,
          mmtt.rebuild_serial_number,
          mmtt.transaction_source_id,
          msn.wip_accounting_class_code,
          meaa.activity_type_code,
          meaa.activity_cause_code,
          to_number(meaa.priority_code) as priority_code,
          meaa.owning_department_id,
          tagging_required_flag,
          to_number(shutdown_type_code) as shutdown_type_code
     FROM MTL_MATERIAL_TRANSACTIONS_TEMP mmtt,
          mtl_serial_numbers msn,
          mtl_system_items msi,
          mtl_eam_asset_activities meaa
    WHERE transaction_temp_id = p_tempId
      and mmtt.rebuild_activity_id = msi.inventory_item_id (+)
      and mmtt.organization_id = msi.organization_id (+)
      and mmtt.rebuild_activity_id = meaa.asset_activity_id (+)
      and mmtt.organization_id = meaa.organization_id (+)
      and mmtt.rebuild_item_id = meaa.inventory_item_id (+)
      and nvl(mmtt.rebuild_serial_number, '@@@') =
          nvl(meaa.serial_number, '@@@'); /* Bug 3661984 */

   l_workorder workorder%ROWTYPE;
   l_return_status     VARCHAR2(20);
   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(1000);
   l_group_id          NUMBER;
   l_request_id        NUMBER;

  l_maintenance_object_id    NUMBER;
  l_maintenance_object_type  NUMBER;
  l_output_dir  VARCHAR2(500);


  mesg varchar2(2000);
  i NUMBER;
  msg_index number;
  temp varchar2(500);


   /* added for calling WO API */

        l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_rec  EAM_PROCESS_WO_PUB.eam_op_rec_type;
        l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

        l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

 begin
    SAVEPOINT REBUILD;

      OPEN workorder;
      FETCH workorder into l_workorder;

      IF(workorder %FOUND) THEN

--find maintenance object type,id,source
         if (l_workorder.rebuild_item_id is not null and l_workorder.rebuild_serial_number is not null) then
           BEGIN
             select gen_object_id into l_maintenance_object_id
               from mtl_serial_numbers
                where inventory_item_id = l_workorder.rebuild_item_id and serial_number = l_workorder.rebuild_serial_number and current_organization_id =l_workorder.organization_id;
             l_maintenance_object_type := 1;
           EXCEPTION
            WHEN NO_DATA_FOUND THEN
            NULL;
          END;
         else
           BEGIN
                SELECT inventory_item_id into l_maintenance_object_id
                  FROM mtl_system_items
                     WHERE inventory_item_id = l_workorder.rebuild_item_id  and organization_id =l_workorder.organization_id;
           l_maintenance_object_type := 2;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
             NULL;
           END;
         end if;


     begin
    select trim(substr(value, 1, DECODE( instr( value, ','), 0, length( value), instr( value, ',') -1 ) ) ) into l_output_dir FROM v$parameter WHERE name = 'utl_file_dir';
    exception
      when NO_DATA_FOUND then
         null;
    end;


                l_eam_wo_rec.user_id := fnd_global.user_id;
                l_eam_wo_rec.responsibility_id :=fnd_global.resp_id;
                l_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
                l_eam_wo_rec.batch_id           := 1;
                l_eam_wo_rec.header_id          := 1;
                l_eam_wo_rec.wip_entity_name          := l_workorder.rebuild_job_name;
                l_eam_wo_rec.description       := l_workorder.description;
                l_eam_wo_rec.asset_activity_id  := l_workorder.rebuild_activity_id;
                l_eam_wo_rec.organization_id    := l_workorder.organization_id;
                l_eam_wo_rec.rebuild_item_id    := l_workorder.rebuild_item_id;
                l_eam_wo_rec.rebuild_serial_number := l_workorder.rebuild_serial_number;
                l_eam_wo_rec.parent_wip_entity_id   := l_workorder.transaction_source_id;
                l_eam_wo_rec.manual_rebuild_flag    := 'N';
                l_eam_wo_rec.class_code             := l_workorder.wip_accounting_class_code;
                l_eam_wo_rec.activity_type          := l_workorder.activity_type_code;
                l_eam_wo_rec.activity_cause         := l_workorder.activity_cause_code;
                l_eam_wo_rec.priority               := l_workorder.priority_code;
                l_eam_wo_rec.owning_department      := l_workorder.owning_department_id;
                l_eam_wo_rec.tagout_required        := l_workorder.tagging_required_flag;
                l_eam_wo_rec.shutdown_type          := l_workorder.shutdown_type_code;
                l_eam_wo_rec.status_type            :=  1;
                l_eam_wo_rec.maintenance_object_source  :=  1;
                l_eam_wo_rec.maintenance_object_type  := l_maintenance_object_type;
                l_eam_wo_rec.maintenance_object_id    := l_maintenance_object_id;
                l_eam_wo_rec.requested_start_date     := sysdate;
                l_eam_wo_rec.scheduled_start_date      := sysdate;
                l_eam_wo_rec.scheduled_completion_date       := sysdate;
                l_eam_wo_rec.firm_planned_flag                := 2;
                l_eam_wo_rec.wip_supply_type           := 7;
                l_eam_wo_rec.po_creation_time        := 2;


                 EAM_PROCESS_WO_PUB.Process_WO
                                 ( p_bo_identifier           => 'EAM'
                                 , p_init_msg_list           => TRUE
                                 , p_api_version_number      => 1.0
                                 , p_commit                  => 'N'
                                 , p_eam_wo_rec              => l_eam_wo_rec
                                 , p_eam_op_tbl              => l_eam_op_tbl
                                 , p_eam_op_network_tbl      => l_eam_op_network_tbl
                                 , p_eam_res_tbl             => l_eam_res_tbl
                                 , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
                                 , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
                                 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
                                 , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                                 , p_eam_direct_items_tbl    => l_eam_di_tbl
                                 , x_eam_wo_rec              => l_out_eam_wo_rec
                                 , x_eam_op_tbl              => l_out_eam_op_tbl
                                 , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
                                 , x_eam_res_tbl             => l_out_eam_res_tbl
                                 , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
                                 , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
                                 , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
                                 , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                                 , x_eam_direct_items_tbl    => l_out_eam_di_tbl
                                 , x_return_status           => l_return_status
                                 , x_msg_count               => l_msg_count
                                 , p_debug                   =>NVL(fnd_profile.value('EAM_DEBUG'), 'N')
                                 , p_debug_filename          => 'wiprbldb.log'
                                 , p_output_dir              => l_output_dir
                                 , p_debug_file_mode         => 'W'
                               );
      END IF;
      CLOSE workorder;

    IF(l_return_status<>'S') THEN
      x_retVal := FND_API.G_RET_STS_ERROR;

      --get the messages from the wo api

         mesg := '';
        IF(l_msg_count>0) THEN
         msg_index := l_msg_count;
         for i in 1..l_msg_count loop
                 fnd_msg_pub.get(p_msg_index => FND_MSG_PUB.G_NEXT,
                    p_encoded   => 'F',
                    p_data      => temp,
                    p_msg_index_out => msg_index);
                msg_index := msg_index-1;
                mesg := mesg || '    ' ||  to_char(i) || ' . '||temp ;
         end loop;
       END IF;

         x_errMsg := mesg;
         ROLLBACK TO REBUILD;
      else

      update_genealogy(p_tempId => p_tempId,
                       x_retVal => x_retVal,
                       x_errMsg => x_errMsg);
      if(x_retVal <> FND_API.G_RET_STS_SUCCESS) then
        ROLLBACK TO REBUILD; --gen update failure
      end if;
   end if;

  end create_rebuild_job;
end wip_rebuild;

/
