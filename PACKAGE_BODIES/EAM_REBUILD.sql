--------------------------------------------------------
--  DDL for Package Body EAM_REBUILD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_REBUILD" AS
/* $Header: EAMRBLDB.pls 120.4 2006/06/02 18:51:48 anjgupta noship $ */



/*  List of Changes made for IB on update_genealogy procedure

   1 Removed fetching Asset_Group_Id and Asset_Number columns from WDJ from
      the initial query since the columns were not being used anywhere
*/

  procedure update_genealogy(p_tempId IN NUMBER,
                             x_retVal OUT NOCOPY VARCHAR2,
                             x_errMsg OUT NOCOPY VARCHAR2) IS

    l_rebuildSerNum VARCHAR2(30);
    l_rebuildItemID NUMBER;
    l_orgID NUMBER;
    l_txnDate DATE;
    l_assetNum VARCHAR2(30);
    l_assetGrpID NUMBER;

    l_msgCount NUMBER;
    l_serial_status NUMBER;
  BEGIN

    x_retVal := fnd_api.G_RET_STS_SUCCESS; --assume success

    select mmtt.rebuild_serial_number,
           mmtt.rebuild_item_id,
           mmtt.organization_id,
           mmtt.transaction_date
     into l_rebuildSerNum,
           l_rebuildItemID,
           l_orgID,
           l_txnDate
      from mtl_material_transactions_temp mmtt
     where mmtt.transaction_temp_id = p_tempId;

    --call genealogy API whether or not a serial exists. The eam procedure
    --will figure out what to do (if anything).
    l_serial_status := 0; --fix for 3733049.initialise so that update_eam_genealogy will be called even if there is no serial number

        if (l_rebuildSerNum is NOT NULL and
            l_rebuildItemID is NOT NULL) then
            select current_status
             into l_serial_status
             from mtl_serial_numbers
            where serial_number = l_rebuildSerNum
              and inventory_item_id = l_rebuildItemID;
        end if;

        if (l_serial_status <> WIP_CONSTANTS.DEF_NOT_USED) then  --if status is not (defined but not used) then only call

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
    fnd_message.set_token('ERROR_TEXT', 'eam_rebuild.update_genealogy');
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
     l_maintenance_object_id    NUMBER;
     l_maintenance_object_type  NUMBER;


    --cursor to fetch details for the workorder to be created

    CURSOR workorder (l_org_id number) IS
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
          eomd.activity_type_code,
          eomd.activity_cause_code,
          to_number(meaa.priority_code) as priority_code,
          eomd.owning_department_id,
          eomd.tagging_required_flag,
          to_number(eomd.shutdown_type_code) as shutdown_type_code
     FROM MTL_MATERIAL_TRANSACTIONS_TEMP mmtt,
          mtl_system_items msi,
          mtl_eam_asset_activities meaa,
          (select * from eam_org_maint_defaults
		   where organization_id = l_org_id) eomd
          --activity has to be assigned to the work order organization
          -- hence no meed to join on MP.
    WHERE transaction_temp_id = p_tempId
      and mmtt.rebuild_activity_id = msi.inventory_item_id (+)
      and mmtt.organization_id = msi.organization_id (+)
      and mmtt.rebuild_activity_id = meaa.asset_activity_id (+)
      and l_maintenance_object_id = meaa.maintenance_object_id (+)
      and l_maintenance_object_type = meaa.maintenance_object_type(+)
      and eomd.object_type (+) = 60
      and eomd.object_id (+) = meaa.activity_association_id;

   l_workorder workorder%ROWTYPE;
   l_return_status     VARCHAR2(20);
   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(1000);
   l_group_id          NUMBER;
   l_request_id        NUMBER;



  l_rebuild_item_id   NUMBER;
  l_rebuild_serial_number  VARCHAR2(30);
  l_org_id            NUMBER;
  l_output_dir  VARCHAR2(512);


  mesg varchar2(2000);
  i NUMBER;
  msg_index number;
  temp varchar2(500);


   /* added for calling WO API */

	l_eam_wo_tbl EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
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
	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
        l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

        l_out_eam_wo_tbl EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
        l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
        l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

	l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_out_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
        l_eam_wo_relations_rec      EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
        l_serial number;

 begin
    SAVEPOINT REBUILD;

      --fix for 3733049.Get the maintenance_object_id and type and then open the cursor
       SELECT rebuild_item_id,rebuild_serial_number,organization_id
       INTO l_rebuild_item_id,l_rebuild_serial_number,l_org_id
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP
       where transaction_temp_id=p_tempId;

       --find maintenance object type,id,source
         if (l_rebuild_item_id is not null and l_rebuild_serial_number is not null) then
		   BEGIN
		     select cii.instance_id into l_maintenance_object_id
		       from csi_item_instances cii, mtl_parameters mp
			where cii.inventory_item_id = l_rebuild_item_id and cii.serial_number = l_rebuild_serial_number
            and mp.organization_id = cii.last_vld_organization_id
            and mp.maint_organization_id =l_org_id;

            l_maintenance_object_type := 3;
		   EXCEPTION
		    WHEN NO_DATA_FOUND THEN
		    NULL;
		  END;
	 else
		   BEGIN
			SELECT msi.inventory_item_id into l_maintenance_object_id
		         FROM mtl_system_items msi, mtl_parameters mp
			 WHERE msi.inventory_item_id = l_rebuild_item_id
             and mp.organization_id = msi.organization_id
            and mp.maint_organization_id =l_org_id
            and rownum = 1;

           l_maintenance_object_type := 2;

		   EXCEPTION
		     WHEN NO_DATA_FOUND THEN
		     NULL;
	          END;
	 end if;


      update_genealogy(p_tempId => p_tempId,
                       x_retVal => x_retVal,
                       x_errMsg => x_errMsg);
      if(x_retVal <> FND_API.G_RET_STS_SUCCESS) then
        ROLLBACK TO REBUILD; --gen update failure
      else

      OPEN workorder(l_org_id);
      FETCH workorder into l_workorder;

      IF(workorder %FOUND) THEN


    EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);



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

                l_eam_wo_tbl(1) := l_eam_wo_rec;

--create follow up relation between workorder created and parent_wip_entity_id
 IF(l_workorder.transaction_source_id IS NOT NULL) THEN
     l_eam_wo_relations_rec.batch_id  :=  1;
     l_eam_wo_relations_rec.parent_object_id := l_workorder.transaction_source_id;
     l_eam_wo_relations_rec.parent_object_type_id := 1;
     l_eam_wo_relations_rec.parent_header_id := l_workorder.transaction_source_id;
     l_eam_wo_relations_rec.child_object_type_id := 1;
     l_eam_wo_relations_rec.child_header_id    :=1;
     l_eam_wo_relations_rec.child_object_id := 1;
     l_eam_wo_relations_rec.parent_relationship_type  := 4;
     l_eam_wo_relations_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
     l_eam_wo_relations_tbl(1) := l_eam_wo_relations_rec;
END IF;


		 EAM_PROCESS_WO_PUB.Process_Master_Child_WO
	  		         ( p_bo_identifier           => 'EAM'
	  		         , p_init_msg_list           => TRUE
	  		         , p_api_version_number      => 1.0
	                         , p_commit                  => 'N'
	  		         , p_eam_wo_tbl              => l_eam_wo_tbl
				 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
	  		         , p_eam_op_tbl              => l_eam_op_tbl
	  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
	  		         , p_eam_res_tbl             => l_eam_res_tbl
	  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
	  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
				 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
	  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
	                         , p_eam_direct_items_tbl    => l_eam_di_tbl
				 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
				, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
				, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
				, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
				, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
				, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
				, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
				, p_eam_request_tbl          => l_eam_request_tbl
	  		         , x_eam_wo_tbl             => l_out_eam_wo_tbl
			         , x_eam_wo_relations_tbl    => l_out_eam_wo_relations_tbl
	  		         , x_eam_op_tbl              => l_out_eam_op_tbl
	  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
	  		         , x_eam_res_tbl             => l_out_eam_res_tbl
	  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
	  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
				 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
	  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
	                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
				  , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
				 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
				 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
				 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
				 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
				 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
				 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
				 , x_eam_request_tbl          => l_out_eam_request_tbl
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
    end if;

   end if;

  end create_rebuild_job;
end eam_rebuild;

/
