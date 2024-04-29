--------------------------------------------------------
--  DDL for Package Body EAM_WB_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WB_UTILS" AS
/* $Header: EAMWBUTB.pls 120.20.12010000.4 2009/12/21 08:47:40 vchidura ship $ */

  g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_WB_UTILS';

  procedure add_forecast(p_pm_forecast_id number) IS
  begin
    if current_forecasts.COUNT = 0 then
      current_forecasts_index := system.eam_wipid_tab_type();
    end if;
    current_forecasts(p_pm_forecast_id) := p_pm_forecast_id;
    current_forecasts_index.extend;
    current_forecasts_index2(p_pm_forecast_id) := current_forecasts_index.last;
    current_forecasts_index(current_forecasts_index.last) := p_pm_forecast_id;

  end add_forecast;

  procedure remove_forecast(p_pm_forecast_id number) IS
  begin
    current_forecasts.DELETE(p_pm_forecast_id);
    current_forecasts_index.delete(current_forecasts_index2(p_pm_forecast_id));
    current_forecasts_index2.DELETE(p_pm_forecast_id);
  end remove_forecast;

  procedure clear_forecasts IS
  begin
    current_forecasts := empty_id_list;
    current_forecasts_index2 := empty_id_list;
    if current_forecasts.COUNT = 0 then
      current_forecasts_index := system.eam_wipid_tab_type();
    end if;
    current_forecasts_index.delete;
  end clear_forecasts;

  function get_forecast_total return number IS
  begin
    return current_forecasts.COUNT;
  end get_forecast_total;

  procedure convert_work_orders2(p_pm_group_id number,
                                 p_project_id IN NUMBER DEFAULT NULL,
                                 p_task_id IN NUMBER DEFAULT NULL,
                                 p_parent_wo_id IN NUMBER DEFAULT NULL,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_msg OUT NOCOPY VARCHAR2) IS
    l_group_id		NUMBER;
    l_forecast_id	NUMBER;
    l_old_flag		VARCHAR2(1);
    l_req_id		NUMBER;

    -- parameters needed for the WO wrapper API call
    l_eam_wo_tbl              eam_process_wo_pub.eam_wo_tbl_type;
    l_eam_wo_relations_tbl     eam_process_wo_pub.eam_wo_relations_tbl_type;
    l_eam_op_tbl              eam_process_wo_pub.eam_op_tbl_type;
    l_eam_op_network_tbl       eam_process_wo_pub.eam_op_network_tbl_type;
    l_eam_res_tbl              eam_process_wo_pub.eam_res_tbl_type;
    l_eam_res_inst_tbl         eam_process_wo_pub.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl          eam_process_wo_pub.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl        eam_process_wo_pub.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl          eam_process_wo_pub.eam_mat_req_tbl_type;
    l_eam_direct_item_tbl      EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
    l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_tbl            eam_process_wo_pub.eam_wo_tbl_type;
    l_out_eam_wo_relations_tbl  eam_process_wo_pub.eam_wo_relations_tbl_type;
    l_out_eam_op_tbl            eam_process_wo_pub.eam_op_tbl_type;
    l_out_eam_op_network_tbl    eam_process_wo_pub.eam_op_network_tbl_type;
    l_out_eam_res_tbl           eam_process_wo_pub.eam_res_tbl_type;
    l_out_eam_res_inst_tbl      eam_process_wo_pub.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl       eam_process_wo_pub.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl     eam_process_wo_pub.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl       eam_process_wo_pub.eam_mat_req_tbl_type;
    l_out_eam_direct_item_tbl      EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
    l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_return_status     VARCHAR2(1);
    l_msl_count         NUMBER;
    l_message_text      VARCHAR2(256);
    l_msl_text          VARCHAR2(256);
    l_entity_index      NUMBER;
    l_entity_id         VARCHAR2(100);
    l_message_type      VARCHAR2(100);
    l_base_meter_id      NUMBER;
    l_api_name			CONSTANT VARCHAR2(30)	:= 'convert_work_orders2';

    l_module            varchar2(200) ;
    l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
    l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
    l_sLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_statement >= l_log_level;


   -- This cursor returns all necessary fields to call the WO API.modified for ib
      --modified for performance issues
  CURSOR c1 IS
   SELECT meaa.asset_activity_id, fw.pm_schedule_id, fw.action_type,
  fw.wip_entity_id, fw.wo_status, ewsv.system_status, fw.cycle_id, fw.seq_id,
  meaa.maintenance_object_type, meaa.maintenance_object_id,
  msi.inventory_item_id, msi.eam_item_type, fw.scheduled_start_date,
  fw.scheduled_completion_date, fw.organization_id organization_id,
  fw.pm_base_meter_reading
   from eam_forecasted_work_orders fw, mtl_eam_asset_activities meaa,
   eam_wo_statuses_v ewsv, csi_item_instances cii, mtl_system_items_b msi
 where PM_FORECAST_ID = l_forecast_id and
  fw.activity_association_id = meaa.activity_association_id and
  ewsv.status_id=fw.wo_status and meaa.maintenance_object_type = 3 and
  meaa.maintenance_object_id = cii.instance_id and cii.inventory_item_id =
  msi.inventory_item_id and cii.last_vld_organization_id = msi.organization_id
union all
SELECT meaa.asset_activity_id, fw.pm_schedule_id, fw.action_type,
 fw.wip_entity_id, fw.wo_status, ewsv.system_status, fw.cycle_id, fw.seq_id,
 meaa.maintenance_object_type, meaa.maintenance_object_id,
 meaa.maintenance_object_id, 3, fw.scheduled_start_date,
 fw.scheduled_completion_date, fw.organization_id organization_id,
 fw.pm_base_meter_reading
from eam_forecasted_work_orders fw, mtl_eam_asset_activities meaa,
 eam_wo_statuses_v ewsv
where PM_FORECAST_ID = l_forecast_id and fw.activity_association_id =
 meaa.activity_association_id and ewsv.status_id=fw.wo_status and
 meaa.maintenance_object_type = 2 ;

    sugg_rec c1%ROWTYPE;

    -- batch id is the forecast group id (p_pm_group_id),
    -- header id is i
    -- These two are used in the WO wrapper API.
    i number;

    -- counter for relationship table
    j number;
     l_output_dir VARCHAR2(512);
  BEGIN
    if (l_ulog) then
          l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
    end if;
    l_group_id := p_pm_group_id;
    l_eam_wo_tbl.delete;
    l_eam_wo_relations_tbl.delete;

    l_forecast_id := current_forecasts.FIRST;
    i := 1;
    LOOP
      open c1;
      fetch c1 into sugg_rec;
      if (c1%NOTFOUND) then
        close c1;
        fnd_message.set_name('EAM', 'EAM_FORECAST_DELETED');
        raise NO_DATA_FOUND;
      end if;

      select decode(eps.RESCHEDULING_POINT,6,epr.meter_id ,null) into l_base_meter_id
      from eam_pm_schedulings eps,eam_pm_scheduling_rules epr where
      eps.pm_schedule_id = epr.pm_schedule_id and rownum = 1
      and eps.pm_schedule_id =  sugg_rec.pm_schedule_id;

      -- Now process the suggestion and fill out the parameters for the
      -- wrapper API call
      if(sugg_rec.action_type = 4) then
      -- NO ACTION
	null;
      else
	-- Bug 3610484
	l_eam_wo_tbl(i).plan_maintenance := 'Y';
        l_eam_wo_tbl(i).user_id := fnd_global.user_id;
        l_eam_wo_tbl(i).responsibility_id := fnd_global.resp_id;

	begin
 	        select description into l_eam_wo_tbl(i).description
 	        from mtl_system_items_vl
 	        where inventory_item_id = sugg_rec.asset_activity_id
 	        and organization_id = sugg_rec.organization_id;

 	      exception
 	        WHEN no_data_found   THEN
 	          l_eam_wo_tbl(i).description := null;
 	        WHEN OTHERS THEN
 	          l_eam_wo_tbl(i).description := null;
 	      END   ;

          if(sugg_rec.action_type IN (2,6,7)) then
             -- Reschedule
          l_eam_wo_tbl(i).transaction_type := eam_process_wo_pub.G_OPR_UPDATE;

          l_eam_wo_tbl(i).organization_id := sugg_rec.organization_id;
          l_eam_wo_tbl(i).wip_entity_id := sugg_rec.wip_entity_id;

          if(sugg_rec.scheduled_start_date is not null) then
            -- forward scheduling
            l_eam_wo_tbl(i).scheduled_start_date := sugg_rec.scheduled_start_date;
            -- dummy value here, it will be over-written by the scheduler
            l_eam_wo_tbl(i).scheduled_completion_date := sugg_rec.scheduled_start_date;
            l_eam_wo_tbl(i).requested_start_date := sugg_rec.scheduled_start_date;
            l_eam_wo_tbl(i).pm_suggested_start_date := sugg_rec.scheduled_start_date;
          else
            -- backward scheduling
            l_eam_wo_tbl(i).scheduled_start_date := sugg_rec.scheduled_completion_date;
            -- dummy value here, it will be over-written by the scheduler
            l_eam_wo_tbl(i).scheduled_completion_date := sugg_rec.scheduled_completion_date;
            l_eam_wo_tbl(i).due_date := sugg_rec.scheduled_completion_date;
            l_eam_wo_tbl(i).pm_suggested_end_date := sugg_rec.scheduled_completion_date;
        end if;
	   l_eam_wo_tbl(i).status_type := sugg_rec.system_status;
	   l_eam_wo_tbl(i).user_defined_status_id := sugg_rec.wo_status;
           l_eam_wo_tbl(i).cycle_id := sugg_rec.cycle_id;
           l_eam_wo_tbl(i).seq_id := sugg_rec.seq_id;

        elsif(sugg_rec.action_type = 3) then
        -- Cancel
          l_eam_wo_tbl(i).transaction_type := eam_process_wo_pub.G_OPR_UPDATE;

          l_eam_wo_tbl(i).organization_id := sugg_rec.organization_id;
          l_eam_wo_tbl(i).wip_entity_id := sugg_rec.wip_entity_id;
          l_eam_wo_tbl(i).status_type := 7; -- cancelled
	  l_eam_wo_tbl(i).user_defined_status_id := 98; --cancelled by pm added for 12i
        elsif(sugg_rec.action_type = 1) then
        -- Create
          l_eam_wo_tbl(i).transaction_type := eam_process_wo_pub.G_OPR_CREATE;
          l_eam_wo_tbl(i).batch_id := p_pm_group_id;
          l_eam_wo_tbl(i).header_id := i;
          l_eam_wo_tbl(i).maintenance_object_source := 1; -- EAM
          l_eam_wo_tbl(i).maintenance_object_type := sugg_rec.maintenance_object_type;
          l_eam_wo_tbl(i).maintenance_object_id := sugg_rec.maintenance_object_id;
          l_eam_wo_tbl(i).class_code := null;  -- WO API will default WAC

	  --added by akalaval for cyclic pm
          l_eam_wo_tbl(i).status_type := sugg_rec.system_status;
	  l_eam_wo_tbl(i).user_defined_status_id := sugg_rec.wo_status;
          l_eam_wo_tbl(i).cycle_id := sugg_rec.cycle_id;
          l_eam_wo_tbl(i).seq_id := sugg_rec.seq_id;

          l_eam_wo_tbl(i).pm_schedule_id := sugg_rec.pm_schedule_id;
          l_eam_wo_tbl(i).asset_activity_id := sugg_rec.asset_activity_id;


          if(sugg_rec.scheduled_start_date is not null) then
            -- forward scheduling
            l_eam_wo_tbl(i).scheduled_start_date := sugg_rec.scheduled_start_date;
            -- dummy value here, it will be over-written by the scheduler
            l_eam_wo_tbl(i).scheduled_completion_date := sugg_rec.scheduled_start_date;
            l_eam_wo_tbl(i).requested_start_date := sugg_rec.scheduled_start_date;
	    l_eam_wo_tbl(i).pm_suggested_start_date := sugg_rec.scheduled_start_date;
          else
            -- backward scheduling
            l_eam_wo_tbl(i).scheduled_start_date := sugg_rec.scheduled_completion_date;
            -- dummy value here, it will be over-written by the scheduler
            l_eam_wo_tbl(i).scheduled_completion_date := sugg_rec.scheduled_completion_date;
            l_eam_wo_tbl(i).due_date := sugg_rec.scheduled_completion_date;
	    l_eam_wo_tbl(i).pm_suggested_end_date := sugg_rec.scheduled_completion_date;
          end if;
          l_eam_wo_tbl(i).organization_id := sugg_rec.organization_id;

          if(sugg_rec.eam_item_type = 1) then
            -- asset
            l_eam_wo_tbl(i).asset_group_id := sugg_rec.inventory_item_id;
          else
            -- rebuildable
            l_eam_wo_tbl(i).rebuild_item_id := sugg_rec.inventory_item_id;
          end if;

        else
          fnd_message.set_name('EAM', 'EAM_FORECAST_DELETED');
          raise NO_DATA_FOUND;
        end if;

        -- common fields for all operations
        l_eam_wo_tbl(i).batch_id := p_pm_group_id;
        l_eam_wo_tbl(i).header_id := i;
	l_eam_wo_tbl(i).pm_base_meter_reading := sugg_rec.pm_base_meter_reading;
	l_eam_wo_tbl(i).pm_base_meter  := l_base_meter_id;


        -- project and task
        if(p_project_id is not null) then
          l_eam_wo_tbl(i).project_id := p_project_id;
        end if;
        if(p_task_id is not null) then
          l_eam_wo_tbl(i).task_id := p_task_id;
        end if;

        -- parent work order
        if(p_parent_wo_id is not null) then
          l_eam_wo_relations_tbl(i).batch_id := p_pm_group_id;
          l_eam_wo_relations_tbl(i).PARENT_OBJECT_ID := p_parent_wo_id;
          l_eam_wo_relations_tbl(i).PARENT_OBJECT_TYPE_ID := 1;
          l_eam_wo_relations_tbl(i).PARENT_HEADER_ID := p_parent_wo_id;
          l_eam_wo_relations_tbl(i).CHILD_OBJECT_ID  := null;
          l_eam_wo_relations_tbl(i).CHILD_OBJECT_TYPE_ID := 1;
          l_eam_wo_relations_tbl(i).CHILD_HEADER_ID := i;

          -- constraint child
          l_eam_wo_relations_tbl(i).PARENT_RELATIONSHIP_TYPE     :=1;

          l_eam_wo_relations_tbl(i).TOP_LEVEL_OBJECT_ID    := p_parent_wo_id;
          l_eam_wo_relations_tbl(i).TOP_LEVEL_OBJECT_TYPE_ID     :=1;
          l_eam_wo_relations_tbl(i).TOP_LEVEL_HEADER_ID          :=p_parent_wo_id;

          l_eam_wo_relations_tbl(i).RETURN_STATUS                :=null;
          l_eam_wo_relations_tbl(i).TRANSACTION_TYPE :=EAM_PROCESS_WO_PUB.G_OPR_CREATE;
        end if;

      end if;
      close c1;

      EXIT when l_forecast_id = current_forecasts.LAST;
      l_forecast_id := current_forecasts.NEXT(l_forecast_id);

      if(sugg_rec.action_type <> 4) then
        i := i + 1;
        j := j + 1;
      end if;


    end loop;

   --checking whether the previous sequences have been implemented or selected
   if not check_previous_implements(p_pm_group_id) then
       p_return_status := 'N' ;
       p_msg := 'EAM_PM_PREV_NOTIMPL';
       return;
   end if;

   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


    eam_process_wo_pub.PROCESS_MASTER_CHILD_WO
         ( p_bo_identifier           => 'EAM'
         , p_init_msg_list           => TRUE
         , p_api_version_number      => 1.0
         , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
         , p_eam_wo_tbl              => l_eam_wo_tbl

-- dummy parameters as these are not used in PM
         , p_eam_op_tbl              => l_eam_op_tbl
         , p_eam_op_network_tbl      => l_eam_op_network_tbl
         , p_eam_res_tbl             => l_eam_res_tbl
         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
         , p_eam_direct_items_tbl    => l_eam_direct_item_tbl
	 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
	 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
	 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
	 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
	, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
	 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
	 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
	 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
	 , p_eam_request_tbl          => l_eam_request_tbl
         , x_eam_direct_items_tbl    => l_out_eam_direct_item_tbl
	 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
         , x_eam_wo_tbl              => l_out_eam_wo_tbl
         , x_eam_wo_relations_tbl    => l_out_eam_wo_relations_tbl
         , x_eam_op_tbl              => l_out_eam_op_tbl
         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
         , x_eam_res_tbl             => l_out_eam_res_tbl
         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
         , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
         , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
         , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
	 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
         , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
         , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
         , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
         , x_eam_request_tbl          => l_out_eam_request_tbl

-- error handling parameters
         , p_commit                  => 'Y'
      --   , x_error_msl_tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.error_tbl_type
         , x_return_status           => p_return_status
         , x_msg_count               => l_msl_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_debug_filename          => 'convertwo2.log'
         , p_output_dir              => l_output_dir

         );



    -- This commit is for work orders and deletion of suggestions
    commit;


    EAM_ERROR_MESSAGE_PVT.Get_Message(l_message_text, l_entity_index, l_entity_id, l_message_type);

    IF( l_slog ) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Return status:' || p_return_status);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Error message:' || SUBSTRB(l_message_text,1,200));
    END IF;
  END convert_work_orders2;
    procedure convert_work_orders3(p_pm_group_id number,
                                 p_project_id IN NUMBER DEFAULT NULL,
                                 p_task_id IN NUMBER DEFAULT NULL,
                                 p_parent_wo_id IN NUMBER DEFAULT NULL,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_msg OUT NOCOPY VARCHAR2) IS
    l_group_id		NUMBER;
    l_forecast_id	NUMBER;
    l_old_flag		VARCHAR2(1);
    l_req_id		NUMBER;

    -- parameters needed for the WO wrapper API call
    l_eam_wo_tbl              eam_process_wo_pub.eam_wo_tbl_type;
    l_eam_wo_relations_tbl     eam_process_wo_pub.eam_wo_relations_tbl_type;
    l_eam_op_tbl              eam_process_wo_pub.eam_op_tbl_type;
    l_eam_op_network_tbl       eam_process_wo_pub.eam_op_network_tbl_type;
    l_eam_res_tbl              eam_process_wo_pub.eam_res_tbl_type;
    l_eam_res_inst_tbl         eam_process_wo_pub.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl          eam_process_wo_pub.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl        eam_process_wo_pub.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl          eam_process_wo_pub.eam_mat_req_tbl_type;
    l_eam_direct_item_tbl      EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
    l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_tbl            eam_process_wo_pub.eam_wo_tbl_type;
    l_out_eam_wo_relations_tbl  eam_process_wo_pub.eam_wo_relations_tbl_type;
    l_out_eam_op_tbl            eam_process_wo_pub.eam_op_tbl_type;
    l_out_eam_op_network_tbl    eam_process_wo_pub.eam_op_network_tbl_type;
    l_out_eam_res_tbl           eam_process_wo_pub.eam_res_tbl_type;
    l_out_eam_res_inst_tbl      eam_process_wo_pub.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl       eam_process_wo_pub.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl     eam_process_wo_pub.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl       eam_process_wo_pub.eam_mat_req_tbl_type;
    l_out_eam_direct_item_tbl      EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
    l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_return_status     VARCHAR2(1);
    l_msl_count         NUMBER;
    l_message_text      VARCHAR2(256);
    l_msl_text      VARCHAR2(256);
    l_entity_index      NUMBER;
    l_entity_id         VARCHAR2(100);
    l_message_type      VARCHAR2(100);
    l_org_id            number;
    l_api_name			CONSTANT VARCHAR2(30)	:= 'convert_work_orders2';

    l_module            varchar2(200) ;
    l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
    l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
    l_sLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_statement >= l_log_level;


    -- This cursor returns all necessary fields to call the WO API.modified for ib
    --modified for performance issues
   CURSOR c1 IS
    SELECT meaa.asset_activity_id, fw.pm_schedule_id, fw.action_type,
  fw.wip_entity_id, fw.wo_status, ewsv.system_status, fw.cycle_id, fw.seq_id,
  meaa.maintenance_object_type, meaa.maintenance_object_id,
  msi.inventory_item_id, msi.eam_item_type, fw.scheduled_start_date,
  fw.scheduled_completion_date, fw.organization_id organization_id,
  fw.pm_base_meter_reading
   from eam_forecasted_work_orders fw, mtl_eam_asset_activities meaa,
   eam_wo_statuses_v ewsv, csi_item_instances cii, mtl_system_items_b msi
 where group_id = l_group_id and
  fw.activity_association_id = meaa.activity_association_id and
  ewsv.status_id=fw.wo_status and meaa.maintenance_object_type = 3 and
  meaa.maintenance_object_id = cii.instance_id and cii.inventory_item_id =
  msi.inventory_item_id and cii.last_vld_organization_id = msi.organization_id
union all
SELECT meaa.asset_activity_id, fw.pm_schedule_id, fw.action_type,
 fw.wip_entity_id, fw.wo_status, ewsv.system_status, fw.cycle_id, fw.seq_id,
 meaa.maintenance_object_type, meaa.maintenance_object_id,
 meaa.maintenance_object_id, 3, fw.scheduled_start_date,
 fw.scheduled_completion_date, fw.organization_id organization_id,
 fw.pm_base_meter_reading
from eam_forecasted_work_orders fw, mtl_eam_asset_activities meaa,
 eam_wo_statuses_v ewsv
where group_id = l_group_id and fw.activity_association_id =
 meaa.activity_association_id and ewsv.status_id=fw.wo_status and
 meaa.maintenance_object_type = 2 ;

    sugg_rec c1%ROWTYPE;

    -- batch id is the forecast group id (p_pm_group_id),
    -- header id is i
    -- These two are used in the WO wrapper API.
    i number;

    -- counter for relationship table
    j number;
     l_output_dir VARCHAR2(512);
  BEGIN


    if (l_ulog) then
          l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
    end if;
    l_group_id := p_pm_group_id;
    l_eam_wo_tbl.delete;
    l_eam_wo_relations_tbl.delete;

    i := 1;

    FOR sugg_rec in c1

    LOOP

    if(sugg_rec.action_type IN (2,6,7,1)) then

          l_eam_wo_tbl(i).plan_maintenance := 'Y';
        --fnd_file.put_line(FND_FILE.LOG, 'Anton: Create');
        -- Create
          l_eam_wo_tbl(i).transaction_type := eam_process_wo_pub.G_OPR_CREATE;
          l_eam_wo_tbl(i).batch_id := p_pm_group_id;
          l_eam_wo_tbl(i).header_id := i;
          l_eam_wo_tbl(i).maintenance_object_source := 1; -- EAM
          l_eam_wo_tbl(i).maintenance_object_type := sugg_rec.maintenance_object_type;
          l_eam_wo_tbl(i).maintenance_object_id := sugg_rec.maintenance_object_id;
          l_eam_wo_tbl(i).class_code := null;  -- WO API will default WAC
          -- l_eam_wo_tbl(i).status_type := 1; -- unreleased

    	  --added by akalaval for cyclic pm
          l_eam_wo_tbl(i).status_type := sugg_rec.system_status;
	      l_eam_wo_tbl(i).user_defined_status_id := sugg_rec.wo_status;
          l_eam_wo_tbl(i).cycle_id := sugg_rec.cycle_id;
          l_eam_wo_tbl(i).seq_id := sugg_rec.seq_id;

          l_eam_wo_tbl(i).pm_schedule_id := sugg_rec.pm_schedule_id;
          l_eam_wo_tbl(i).asset_activity_id := sugg_rec.asset_activity_id;


          if(sugg_rec.scheduled_start_date is not null) then
            -- forward scheduling
            l_eam_wo_tbl(i).scheduled_start_date := sugg_rec.scheduled_start_date;
            -- dummy value here, it will be over-written by the scheduler
            l_eam_wo_tbl(i).scheduled_completion_date := sugg_rec.scheduled_start_date;
            l_eam_wo_tbl(i).requested_start_date := sugg_rec.scheduled_start_date;
          else
            -- forward scheduling
            l_eam_wo_tbl(i).scheduled_start_date := sugg_rec.scheduled_completion_date;
            -- dummy value here, it will be over-written by the scheduler
            l_eam_wo_tbl(i).scheduled_completion_date := sugg_rec.scheduled_completion_date;
            l_eam_wo_tbl(i).due_date := sugg_rec.scheduled_completion_date;
          end if;
          l_eam_wo_tbl(i).organization_id := sugg_rec.organization_id;

          if(sugg_rec.eam_item_type = 1) then
            -- asset
            l_eam_wo_tbl(i).asset_group_id := sugg_rec.inventory_item_id;
          else
            -- rebuildable
            l_eam_wo_tbl(i).rebuild_item_id := sugg_rec.inventory_item_id;
          end if;

            -- common fields for all operations
            l_eam_wo_tbl(i).batch_id := p_pm_group_id;
            l_eam_wo_tbl(i).header_id := i;

            -- project and task
        if(p_project_id is not null) then
          l_eam_wo_tbl(i).project_id := p_project_id;
        end if;
        if(p_task_id is not null) then
          l_eam_wo_tbl(i).task_id := p_task_id;
        end if;

        -- parent work order
        if(p_parent_wo_id is not null) then
          l_eam_wo_relations_tbl(i).batch_id := p_pm_group_id;
          l_eam_wo_relations_tbl(i).PARENT_OBJECT_ID := p_parent_wo_id;
          l_eam_wo_relations_tbl(i).PARENT_OBJECT_TYPE_ID := 1;
          l_eam_wo_relations_tbl(i).PARENT_HEADER_ID := p_parent_wo_id;
          l_eam_wo_relations_tbl(i).CHILD_OBJECT_ID  := null;
          l_eam_wo_relations_tbl(i).CHILD_OBJECT_TYPE_ID := 1;
          l_eam_wo_relations_tbl(i).CHILD_HEADER_ID := i;

          -- constraint child
          l_eam_wo_relations_tbl(i).PARENT_RELATIONSHIP_TYPE     :=1;

          l_eam_wo_relations_tbl(i).TOP_LEVEL_OBJECT_ID    := p_parent_wo_id;
          l_eam_wo_relations_tbl(i).TOP_LEVEL_OBJECT_TYPE_ID     :=1;
          l_eam_wo_relations_tbl(i).TOP_LEVEL_HEADER_ID          :=p_parent_wo_id;

          l_eam_wo_relations_tbl(i).RETURN_STATUS                :=null;
          l_eam_wo_relations_tbl(i).TRANSACTION_TYPE :=EAM_PROCESS_WO_PUB.G_OPR_CREATE;
        end if;

        i := i + 1;
        j := j + 1;
      end if;


    end loop;


    EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);



    eam_process_wo_pub.PROCESS_MASTER_CHILD_WO
         ( p_bo_identifier           => 'EAM'
         , p_init_msg_list           => TRUE
         , p_api_version_number      => 1.0
         , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
         , p_eam_wo_tbl              => l_eam_wo_tbl

    -- dummy parameters as these are not used in PM
         , p_eam_op_tbl              => l_eam_op_tbl
         , p_eam_op_network_tbl      => l_eam_op_network_tbl
         , p_eam_res_tbl             => l_eam_res_tbl
         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
         , p_eam_direct_items_tbl    => l_eam_direct_item_tbl
	 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
	 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
	 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
	 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
	, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
	 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
	 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
	 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
	 , p_eam_request_tbl          => l_eam_request_tbl
         , x_eam_direct_items_tbl    => l_out_eam_direct_item_tbl
	 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
         , x_eam_wo_tbl              => l_out_eam_wo_tbl
         , x_eam_wo_relations_tbl    => l_out_eam_wo_relations_tbl
         , x_eam_op_tbl              => l_out_eam_op_tbl
         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
         , x_eam_res_tbl             => l_out_eam_res_tbl
         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
         , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
         , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
         , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
	 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
         , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
         , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
         , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
         , x_eam_request_tbl          => l_out_eam_request_tbl

-- error handling parameters
         , p_commit                  => 'N'
      --   , x_error_msl_tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.error_tbl_type
         , x_return_status           => p_return_status
         , x_msg_count               => l_msl_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_debug_filename          => 'convertwo2.log'
         , p_output_dir              => l_output_dir

         );

    EAM_ERROR_MESSAGE_PVT.Get_Message(l_message_text, l_entity_index, l_entity_id, l_message_type);

    IF( l_slog ) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Return status:' || p_return_status);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Error message:' || SUBSTRB(l_message_text,1,200));
    END IF;
  END convert_work_orders3;


  procedure convert_work_orders(p_pm_group_id number, x_request_id OUT NOCOPY number)  IS


    l_group_id		NUMBER;
    l_forecast_id	NUMBER;
    l_old_flag		VARCHAR2(1);
    l_req_id		NUMBER;

    CURSOR c1 IS
	SELECT PROCESS_FLAG
	from eam_forecasted_work_orders
	where PM_FORECAST_ID = l_forecast_id
	for update of process_flag nowait;

  begin
    l_group_id := p_pm_group_id;
    if current_forecasts.COUNT <= 0 then
      x_request_id := -1;
      return;
    end if;

    l_forecast_id := current_forecasts.FIRST;
    LOOP
      open c1;
      fetch c1 into l_old_flag;
      if (c1%NOTFOUND) then
        close c1;
        fnd_message.set_name('EAM', 'EAM_FORECAST_DELETED');
        raise NO_DATA_FOUND;
      end if;
      close c1;

      if l_old_flag <> 'Y' then
        update eam_forecasted_work_orders
        set process_flag = 'Y'
	where pm_forecast_id = l_forecast_id;
      else
        raise_application_error(
		-22222,
		'EAM FORECAST IS ALREADY CONVERTED TO WORK ORDER');
      end if;
      EXIT when l_forecast_id = current_forecasts.LAST;
      l_forecast_id := current_forecasts.NEXT(l_forecast_id);
    END LOOP;

    l_req_id := FND_REQUEST.SUBMIT_REQUEST('EAM', 'EAMCVTWO',
      null, null, FALSE, to_char(l_group_id),
      chr(0), null, null, null, null, null, null, null, null, null,
      null, null, null, null, null, null, null, null, null, null,
      null, null, null, null, null, null, null, null, null, null,
      null, null, null, null, null, null, null, null, null, null,
      null, null, null, null, null, null, null, null, null, null,
      null, null, null, null, null, null, null, null, null, null,
      null, null, null, null, null, null, null, null, null, null,
      null, null, null, null, null, null, null, null, null, null,
      null, null, null, null, null, null, null, null, null, null,
      null, null, null, null, null, null, null, null, null);


    if ( l_req_id = 0 ) then
      raise_application_error(
		-22223,
		'EAM WORK ORDER CONVERTING REQUEST FAILED');
    else
      commit;
    end if;

    x_request_id := l_req_id;

  end convert_work_orders;

      -- wrapper for autonomous commit in pm scheduler
  procedure run_pm_scheduler2(
			p_view_non_scheduled IN varchar2,
			p_start_date IN date,
			p_end_date IN date,
			p_org_id IN number,
			p_user_id IN number,
			p_stmt IN varchar2,
			p_setname_id IN number,
			p_combine_default IN varchar2,
            p_forecast_set_id IN number,
	    p_source IN varchar2) IS
    begin
        eam_pm_engine.do_forecast2(
			p_view_non_scheduled,
			p_start_date,
			p_end_date,
			p_org_id,
			p_user_id,
			p_stmt,
			p_setname_id,
			p_combine_default,
            p_forecast_set_id,
	    p_source
			);
    --Uncomment for deubg purpose
    --commit;

  END run_pm_scheduler2;


  function run_pm_scheduler(
			p_view_non_scheduled IN varchar2,
			p_start_date IN date,
			p_end_date IN date,
			p_org_id IN number,
			p_user_id IN number,
			p_stmt IN varchar2,
			p_setname_id IN number,
			p_combine_default IN varchar2) return number IS

  l_group_id number;
  BEGIN

    l_group_id := eam_pm_engine.do_forecast(
			p_view_non_scheduled,
			p_start_date,
			p_end_date,
			p_org_id,
			p_user_id,
			p_stmt,
			p_setname_id,
			p_combine_default
			);
    --Uncomment for deubg purpose
    --commit;

    return l_group_id;
  END run_pm_scheduler;

  procedure clear_forecasted_work_orders(p_group_id number) IS



  BEGIN
    delete from eam_forecasted_work_orders
    where group_id = p_group_id and
    process_flag = 'N';
    commit;
  END clear_forecasted_work_orders;

  --
  -- fore MASS RELEASE
  --

  procedure add_work_order(p_wip_entity_id number, wo_type number) IS
  begin
    if wo_type = 1 then
      work_orders_not_ready(p_wip_entity_id) := p_wip_entity_id;
    elsif wo_type = 3 then
        work_orders_released(p_wip_entity_id) := p_wip_entity_id;
    else
      work_orders_unreleased(p_wip_entity_id) := p_wip_entity_id;
    end if;
  end add_work_order;

  procedure remove_work_order(p_wip_entity_id number, wo_type number) IS
  begin
    if wo_type = 1 then
      work_orders_not_ready.DELETE(p_wip_entity_id);
    elsif wo_type = 3 then
        work_orders_released.DELETE(p_wip_entity_id);
    else
      work_orders_unreleased.DELETE(p_wip_entity_id);
    end if;
  end remove_work_order;

  procedure clear_work_orders IS
  begin
    work_orders_not_ready := empty_id_list;
    work_orders_unreleased := empty_id_list;
  end clear_work_orders;

  procedure clear_released_work_orders IS
  begin
    work_orders_released := empty_id_list;
  end clear_released_work_orders;


  function get_work_order_total return number IS
  begin
    return work_orders_not_ready.COUNT + work_orders_unreleased.COUNT;
  end get_work_order_total;

  function get_work_order_release_total return number IS
  begin
    return work_orders_released.COUNT;
  end get_work_order_release_total;

  procedure complete_work_orders(p_org_id number)  IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_org_id		NUMBER;
    l_wip_entity_id	NUMBER;

    l_return_status VARCHAR2(1);
    l_msg_count                NUMBER;
    l_message_text      VARCHAR2(4000);
    l_err_occured   VARCHAR2(1);
    l_sheduled_start_date date;
    l_scheduled_completion_date date;
    l_shutdown_type	        VARCHAR2(30);	--Added for bug 7133506

    /* added for calling WO API */

    l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
    l_eam_wo_tbl_1                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_eam_op_network_tbl        EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_eam_sub_res_tbl           EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_mat_req_tbl           EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_eam_direct_items_tbl	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
l_eam_res_usage_tbl        eam_process_wo_pub.eam_res_usage_tbl_type;

l_eam_wo_tbl1                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
l_eam_wo_relations_tbl1      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
l_eam_op_tbl1                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_eam_op_network_tbl1        EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_eam_res_tbl1               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_eam_res_inst_tbl1          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_eam_sub_res_tbl1           EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_mat_req_tbl1           EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
l_eam_direct_items_tbl_1	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_eam_wo_comp_rec EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;

    l_output_dir		VARCHAR2(512);
    i number;
    j number;
  begin

    l_org_id	:= p_org_id;
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_msg_count := 0;
    l_err_occured := 'N';

    i:= 1;
    j:= 1;
    /* get output directory path from database */
EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

  if work_orders_released.COUNT > 0 then
    l_wip_entity_id := work_orders_released.FIRST;
    LOOP
      l_eam_wo_comp_rec.header_id := l_wip_entity_id;
      l_eam_wo_comp_rec.batch_id := 1;
      l_eam_wo_comp_rec.batch_id := 1;
      l_eam_wo_comp_rec.wip_entity_id := l_wip_entity_id;
      l_eam_wo_comp_rec.organization_id := l_org_id;
      l_eam_wo_comp_rec.user_status_id := 4;

	select scheduled_start_date,scheduled_completion_date,shutdown_type
        into l_sheduled_start_date,l_scheduled_completion_date,l_shutdown_type
	from wip_discrete_jobs where wip_entity_id = l_wip_entity_id;

      l_eam_wo_comp_rec.actual_start_date := l_sheduled_start_date;
      l_eam_wo_comp_rec.actual_end_date := l_scheduled_completion_date;

      l_eam_wo_comp_rec.transaction_type := 4;

      --Start to add code for bug 7133506
      if l_shutdown_type = 2 then --if shutdown is required, need to set shutdown start and end date
        l_eam_wo_comp_rec.shutdown_start_date := l_eam_wo_comp_rec.actual_start_date;
        l_eam_wo_comp_rec.shutdown_end_date := l_eam_wo_comp_rec.actual_end_date;
      end if;
      --End add code for bug 7133506

      l_eam_wo_comp_tbl(i) := l_eam_wo_comp_rec;
      i := i + 1;
	exit when l_wip_entity_id = work_orders_released.LAST;
        l_wip_entity_id := work_orders_released.NEXT(l_wip_entity_id);
    END LOOP;

         EAM_PROCESS_WO_PUB.Process_Master_Child_WO
  	         ( p_bo_identifier           => 'EAM'
  	         , p_init_msg_list           => TRUE
  	         , p_api_version_number      => 1.0
  	         , p_eam_wo_tbl              => l_eam_wo_tbl
                 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
  	         , p_eam_op_tbl              => l_eam_op_tbl
  	         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  	         , p_eam_res_tbl             => l_eam_res_tbl
  	         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  	         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
    	         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                 , p_eam_direct_items_tbl    =>   l_eam_direct_items_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
		 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		 , p_eam_request_tbl          => l_eam_request_tbl
  	         , x_eam_wo_tbl              => l_eam_wo_tbl1
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_eam_op_tbl1
  	         , x_eam_op_network_tbl      => l_eam_op_network_tbl1
  	         , x_eam_res_tbl             => l_eam_res_tbl1
  	         , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
  	         , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
  	         , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
                 , x_eam_direct_items_tbl    =>   l_eam_direct_items_tbl_1
		, x_eam_res_usage_tbl       => l_eam_res_usage_tbl
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
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'completewo.log'
  	         , p_output_dir              => l_output_dir
                 , p_commit                  => 'Y'
                 , p_debug_file_mode         => 'W'
           );
  	IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
	    l_err_occured :='Y';
	END IF ;

  end if;

	IF (l_err_occured='Y' OR l_msg_count>0) THEN
		IF (l_msg_count>0) THEN
			eam_workorder_pkg.get_all_mesg(mesg=>l_message_text);
		END IF;
	 fnd_message.set_name('EAM','EAM_WO_NOT_COMPLETED');
	 fnd_message.set_token(token => 'MESG',
                               value => l_message_text,
                               translate => FALSE);
	 APP_EXCEPTION.RAISE_EXCEPTION;
	END IF ;

  commit;

  end complete_work_orders;

  procedure release_work_orders(p_group_id number,
				p_org_id number,
				p_auto_firm_flag varchar2)  IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_group_id		NUMBER;
    l_org_id		NUMBER;
    l_wip_entity_id	NUMBER;
    l_old_status	NUMBER;
    l_req_id		NUMBER;
    l_dummy		NUMBER;

    l_req_start_date	DATE;
    l_due_date		DATE;
    l_asset_number	VARCHAR2(30);
    l_class_code    VARCHAR2(40);

    l_return_status VARCHAR2(1);
    l_msg_count                NUMBER;
    l_message_text      VARCHAR2(4000);
    l_err_occured   VARCHAR2(1);

    /* added for calling WO API */

    l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
        l_eam_wo_tbl_1                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_eam_op_network_tbl        EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_eam_sub_res_tbl           EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_mat_req_tbl           EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_eam_direct_items_tbl	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
l_eam_res_usage_tbl        eam_process_wo_pub.eam_res_usage_tbl_type;

l_eam_wo_tbl1                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
l_eam_wo_relations_tbl1      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
l_eam_op_tbl1                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_eam_op_network_tbl1        EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_eam_res_tbl1               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_eam_res_inst_tbl1          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_eam_sub_res_tbl1           EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_mat_req_tbl1           EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
l_eam_direct_items_tbl_1	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_wo_rec_1 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_output_dir		VARCHAR2(512);
    i number;
    j number;
  begin

    l_group_id	:= p_group_id;
    l_org_id	:= p_org_id;
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_msg_count := 0;
    l_err_occured := 'N';

    i:= 1;
    j:= 1;
    /* get output directory path from database */
EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

--
-- UNRELEASED
--
  if work_orders_unreleased.COUNT > 0 then
    l_wip_entity_id := work_orders_unreleased.FIRST;
    LOOP
    l_eam_wo_rec.header_id := l_wip_entity_id;
      l_eam_wo_rec.batch_id := 1;
      l_eam_wo_rec.wip_entity_id := l_wip_entity_id;
      l_eam_wo_rec.organization_id := l_org_id;
      l_eam_wo_rec.status_type := 3;
      l_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
      l_eam_wo_rec.user_id            := fnd_global.user_id; /*added for bug 8408518*/
      l_eam_wo_rec.responsibility_id  := fnd_global.resp_id;  /*added for bug 8408518*/
      l_eam_wo_tbl(i) :=l_eam_wo_rec;
      i := i + 1;
	exit when l_wip_entity_id = work_orders_unreleased.LAST;
        l_wip_entity_id := work_orders_unreleased.NEXT(l_wip_entity_id);
    END LOOP;

         EAM_PROCESS_WO_PUB.Process_Master_Child_WO
  	         ( p_bo_identifier           => 'EAM'
  	         , p_init_msg_list           => TRUE
  	         , p_api_version_number      => 1.0
  	         , p_eam_wo_tbl              => l_eam_wo_tbl
                 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
  	         , p_eam_op_tbl              => l_eam_op_tbl
  	         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  	         , p_eam_res_tbl             => l_eam_res_tbl
  	         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  	         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
    	         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                 , p_eam_direct_items_tbl    =>   l_eam_direct_items_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
		 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		 , p_eam_request_tbl          => l_eam_request_tbl
  	         , x_eam_wo_tbl              => l_eam_wo_tbl1
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_eam_op_tbl1
  	         , x_eam_op_network_tbl      => l_eam_op_network_tbl1
  	         , x_eam_res_tbl             => l_eam_res_tbl1
  	         , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
  	         , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
  	         , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
                 , x_eam_direct_items_tbl    =>   l_eam_direct_items_tbl_1
		, x_eam_res_usage_tbl       => l_eam_res_usage_tbl
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
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'releasewo.log'
  	         , p_output_dir              => l_output_dir
                 , p_commit                  => 'Y'
                 , p_debug_file_mode         => 'W'
           );
  	IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
	    l_err_occured :='Y';
	END IF ;

  end if;

--
-- DRAFT
--

  if work_orders_not_ready.COUNT > 0 then
    l_wip_entity_id := work_orders_not_ready.FIRST;
    LOOP
    l_eam_wo_rec_1.header_id := l_wip_entity_id;
      l_eam_wo_rec_1.batch_id := 1;
      l_eam_wo_rec_1.wip_entity_id := l_wip_entity_id;
      l_eam_wo_rec_1.organization_id := l_org_id;
      l_eam_wo_rec_1.status_type := 3;
      l_eam_wo_rec_1.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
      l_eam_wo_tbl_1(j) :=l_eam_wo_rec_1;
      j := j + 1;
	exit when l_wip_entity_id = work_orders_not_ready.LAST ;
              l_wip_entity_id := work_orders_not_ready.NEXT(l_wip_entity_id);
    END LOOP;

         EAM_PROCESS_WO_PUB.Process_Master_Child_WO
  	         ( p_bo_identifier           => 'EAM'
  	         , p_init_msg_list           => TRUE
  	         , p_api_version_number      => 1.0
  	         , p_eam_wo_tbl              => l_eam_wo_tbl_1
                 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
  	         , p_eam_op_tbl              => l_eam_op_tbl
  	         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  	         , p_eam_res_tbl             => l_eam_res_tbl
  	         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  	         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
    	         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                 , p_eam_direct_items_tbl    =>   l_eam_direct_items_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
		 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		 , p_eam_request_tbl          => l_eam_request_tbl
  	         , x_eam_wo_tbl              => l_eam_wo_tbl1
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_eam_op_tbl1
  	         , x_eam_op_network_tbl      => l_eam_op_network_tbl1
  	         , x_eam_res_tbl             => l_eam_res_tbl1
  	         , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
  	         , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
  	         , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
                 , x_eam_direct_items_tbl    =>   l_eam_direct_items_tbl_1
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
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
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'releasedrwo.log'
  	         , p_output_dir              => l_output_dir
                 , p_commit                  => 'Y'
                 , p_debug_file_mode         => 'A'
           );
  	IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
	 l_err_occured :='Y';
	END IF ;
  end if;

	IF (l_err_occured='Y' OR l_msg_count>0) THEN
		IF (l_msg_count>0) THEN
			eam_workorder_pkg.get_all_mesg(mesg=>l_message_text);
		END IF;
	 fnd_message.set_name('EAM','EAM_WO_NOT_RELEASED');
	 fnd_message.set_token(token => 'MESG',
                               value => l_message_text,
                               translate => FALSE);
	 APP_EXCEPTION.RAISE_EXCEPTION;
	END IF ;

  commit;

  end release_work_orders;

--function added by akalaval
--function checks whether the previous sequence have been either implemented or selected
--called from convert_work_orders2 before calling process master child wo
FUNCTION check_previous_implements(p_pm_group_id number)
return boolean is


	TYPE c_efwo_type IS REF CURSOR;
	c_efwo c_efwo_type;

	i number;
	l_forecast_total number;

	l_pm_schedule_id eam_forecasted_work_orders.pm_schedule_id%type;
	l_cycle_id eam_forecasted_work_orders.cycle_id%type;
	l_seq_id eam_forecasted_work_orders.seq_id%type;
	l_wip_entity_id eam_forecasted_work_orders.wip_entity_id%type;
	l_activity_association_id eam_forecasted_work_orders.activity_association_id%type;

        l_cnt number;
	l_forecast_id		NUMBER;
        l_total                 NUMBER;
	l_maint_id              NUMBER;
	l_maint_type            NUMBER;
	l_prev_maint_type       NUMBER;
	l_prev_maint_id         NUMBER;
	l_prev_act_ass_id    	NUMBER;
	l_act_ass_id		NUMBER;

begin

l_total := 0;
l_cnt := 0;
l_maint_id := -1;
l_maint_type := -1;
l_act_ass_id := -1;
l_prev_maint_id := -2;
l_prev_maint_type := -2;
l_prev_act_ass_id := -2;
i:=1;
l_forecast_total := eam_wb_utils.get_forecast_total;

for c1 in  (
             select fwo.cycle_id,fwo.seq_id,eps.maintenance_object_id,eps.maintenance_object_type,fwo.activity_association_id
	     from eam_forecasted_work_orders fwo,eam_pm_schedulings eps
	     where fwo.pm_schedule_id=eps.pm_schedule_id and fwo.pm_forecast_id in (
	     ( select * from table( cast ( current_forecasts_index as system.eam_wipid_tab_type
	                                 )
				   )
	     )                                                                      )
	     and action_type <>3 and action_type <> 4 order by maintenance_object_id,maintenance_object_type,fwo.activity_association_id,cycle_id desc,seq_id desc
	   )
loop
  l_cycle_id := c1.cycle_id;
  l_seq_id   := c1.seq_id;
  l_maint_id := c1.maintenance_object_id;
  l_maint_type := c1.maintenance_object_type;
  l_act_ass_id := c1.activity_association_id ;

  if (l_maint_id <> l_prev_maint_id or l_maint_type <> l_prev_maint_type or l_act_ass_id <> l_prev_act_ass_id ) then
     if l_cnt <> l_total then
        return false;
     end if;
     l_total := 0;
     l_prev_maint_id := l_maint_id;
     l_prev_maint_type := l_maint_type;
     l_prev_act_ass_id := l_act_ass_id;

  end if;

  if l_total = 0 then
   select count(1) into l_cnt from
      eam_forecasted_work_orders fwo,eam_pm_schedulings eps
       where fwo.pm_schedule_id = eps.pm_schedule_id and group_id = p_pm_group_id
       and (cycle_id >0 and seq_id >0 and (( cycle_id=l_cycle_id and seq_id <= l_seq_id) or cycle_id < l_cycle_id ))
       and action_type NOT IN(3,4)
       and maintenance_object_id =l_maint_id
       and maintenance_object_type = l_maint_type
       and l_act_ass_id = fwo.activity_association_id;
  end if;
    l_total := l_total+1;
end loop;

if l_total = l_cnt then
  i:=1;
  l_forecast_id :=eam_wb_utils.current_forecasts.FIRST;
  while ( i <= l_forecast_total ) loop

      delete from eam_forecasted_work_orders
      where PM_FORECAST_ID = l_forecast_id;

      if i < l_forecast_total then
	   l_forecast_id := eam_wb_utils.current_forecasts.NEXT(l_forecast_id);
      end if;
     i:=i+1;
  end loop;
 return true;
else
  return false;
end if;
end;

FUNCTION  get_owning_dept_default(
 	                                  p_organization_id         IN number,
 	                                  p_maintenance_object_type IN number,
 	                                  p_maintenance_object_id   IN number,
 	                                  p_rebuild_item_id         IN number,
 	                                  p_primary_item_id         IN number
 	                                  )    return number  IS

 	   l_return_status varchar2(10);
 	   l_msg_count     number;
 	   l_msg_data      varchar2(5000);
 	   l_owning_department_id number;
 	   BEGIN
 	      l_owning_department_id := null;
 	      Wip_eamworkorder_pvt.get_eam_owning_dept_default(
 	                  p_api_version  => 1.0,
 	                  p_init_msg_list => FND_API.G_FALSE,
 	                  p_commit        => FND_API.G_FALSE,
 	                  p_validation_level =>FND_API.G_VALID_LEVEL_FULL,
 	                  x_return_status => l_return_status,
 	                  x_msg_count  => l_msg_count ,
 	                  x_msg_data  => l_msg_data ,
 	                  p_primary_item_id => p_primary_item_id ,
 	                  p_organization_id => p_organization_id,
 	                  p_maintenance_object_type => p_maintenance_object_type,
 	                  p_maintenance_object_id =>  p_maintenance_object_id,
 	                  p_rebuild_item_id => p_rebuild_item_id ,
 	                  x_owning_department_id => l_owning_department_id
 	           );
 	       return l_owning_department_id;
 END get_owning_dept_default;

END eam_wb_utils;


/
