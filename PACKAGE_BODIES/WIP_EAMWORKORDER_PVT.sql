--------------------------------------------------------
--  DDL for Package Body WIP_EAMWORKORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EAMWORKORDER_PVT" AS
/* $Header: WIPVEWOB.pls 120.5.12010000.3 2009/03/06 00:49:14 mashah ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30):='WIP_EAMWORKORDER_PVT';

PROCEDURE Create_EAM_Work_Order
(   p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_work_order_rec            IN  work_order_interface_rec_type,
    x_group_id                  OUT NOCOPY NUMBER,
    x_request_id                OUT NOCOPY NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30)  := 'Create_EAM_Work_Order';
l_api_version       CONSTANT NUMBER        := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
l_module                  CONSTANT VARCHAR2(60) := 'wip.plsql.'||l_full_name;
l_log            boolean := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
l_request_id        NUMBER := 0;
l_debug             VARCHAR2(1);
l_scheduled_start_date      DATE;
l_scheduled_completion_date DATE;
l_gen_object_id             NUMBER ;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_message_text              VARCHAR2(2000);
l_maintenance_object_type   NUMBER;
l_maint_obj_fnd             VARCHAR2(1);
l_dept_id                   NUMBER;
l_def_return_status         VARCHAR2(1);
l_def_msg_count             NUMBER;
l_def_msg_data              VARCHAR2(1000);
l_maintenance_object_id     NUMBER;
l_output_dir		VARCHAR2(512);
l_asset_group_id	NUMBER	:= NULL;
l_asset_number		VARCHAR2(255)	:= NULL;

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

BEGIN
    if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'Start of ' || l_module);
    end if;
    l_maint_obj_fnd :='N';
    l_eam_wo_rec.asset_activity_id := p_work_order_rec.primary_item_id;

    -- Standard Start of API savepoint
    SAVEPOINT    Create_EAM_Work_Order_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body

   -- EAM Specific Validation
   IF (NVL(p_work_order_rec.load_type,7) <> 7) THEN
        FND_MESSAGE.SET_NAME('EAM','Incorrect Value of Load Type: '||p_work_order_rec.load_type);
        FND_MSG_PUB.ADD();
        RAISE FND_API.G_EXC_ERROR;
   END IF;

/*
	For maintenance_object_type, use the following criteria
	1. For asset work orders and serialized rebuild work order, pass value of 3
	2. For non-serialized rebuild work orders, pass value of 2
	*/

	 l_asset_group_id := p_work_order_rec.asset_group_id;
	 l_asset_number := p_work_order_rec.asset_number;

	 IF  (p_work_order_rec.maintenance_object_id IS NOT NULL  AND
	 p_work_order_rec.maintenance_object_type  = 3 )  THEN

	  BEGIN
		SELECT   cii.inventory_item_id,
		cii.serial_number
		INTO
		l_asset_group_id,
		l_asset_number
		FROM
		csi_item_instances cii
		WHERE
		cii.instance_id = p_work_order_rec.maintenance_object_id;
		l_maintenance_object_type := 3;
		l_gen_object_id := p_work_order_rec.maintenance_object_id;
	  l_maint_obj_fnd :='Y';
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	    NULL;
	  END;
	 END IF;

	IF (l_maint_obj_fnd<>'Y' AND p_work_order_rec.asset_group_id IS NOT NULL AND p_work_order_rec.asset_number IS NOT NULL ) THEN
	  BEGIN

           SELECT instance_id into l_gen_object_id
	     FROM csi_item_instances
	      WHERE inventory_item_id = p_work_order_rec.asset_group_id and serial_number = p_work_order_rec.asset_number and last_vld_organization_id =p_work_order_rec.organization_id  ;
	    l_maintenance_object_type := 3;
	    l_maintenance_object_id := l_gen_object_id;
	    l_maint_obj_fnd :='Y';
	 EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	  NULL;
	 END;
	END IF;

	IF (l_maint_obj_fnd<>'Y' AND p_work_order_rec.rebuild_item_id IS NOT NULL
	AND p_work_order_rec.rebuild_serial_number IS NOT NULL ) THEN
          BEGIN
	     select instance_id into l_gen_object_id
	       from csi_item_instances
	        where inventory_item_id = p_work_order_rec.rebuild_item_id and serial_number = p_work_order_rec.rebuild_serial_number and last_vld_organization_id =p_work_order_rec.organization_id;
	     l_maintenance_object_type := 3;
	     l_maintenance_object_id := l_gen_object_id;
	     l_maint_obj_fnd :='Y';
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	    NULL;
	  END;
	END IF ;

	IF (l_maint_obj_fnd<>'Y' AND  p_work_order_rec.rebuild_item_id IS NOT NULL) THEN
           BEGIN
		SELECT inventory_item_id into l_gen_object_id
		  FROM mtl_system_items
	             WHERE inventory_item_id = p_work_order_rec.rebuild_item_id  and organization_id =p_work_order_rec.organization_id;
           l_maintenance_object_type := 2;
	   l_maintenance_object_id := l_gen_object_id;
	   EXCEPTION
  	     WHEN NO_DATA_FOUND THEN
	     NULL;
	   END;
	END IF;

  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'l_gen_object_id: ' || l_gen_object_id);
  end if;
       l_eam_wo_rec.status_type := p_work_order_rec.status_type;

        /* get output directory path from database */
     log_path(l_output_dir);

	l_eam_wo_rec.header_id := null;
	l_eam_wo_rec.batch_id :=  null;
	l_eam_wo_rec.row_id := null;
	l_eam_wo_rec.wip_entity_name := null ;
	l_eam_wo_rec.wip_entity_id := null;
	l_eam_wo_rec.organization_id := p_work_order_rec.organization_id;
	l_eam_wo_rec.description := null;
	l_eam_wo_rec.asset_number := l_asset_number;
	l_eam_wo_rec.asset_group_id := l_asset_group_id;
	l_eam_wo_rec.rebuild_item_id := p_work_order_rec.rebuild_item_id;
	l_eam_wo_rec.rebuild_serial_number := p_work_order_rec.rebuild_serial_number;
	l_eam_wo_rec.maintenance_object_id := l_gen_object_id;
	l_eam_wo_rec.maintenance_object_type := l_maintenance_object_type;
	l_eam_wo_rec.maintenance_object_source := 1;
	l_eam_wo_rec.class_code := p_work_order_rec.class_code;
	l_eam_wo_rec.activity_type := p_work_order_rec.activity_type;
	l_eam_wo_rec.activity_cause :=p_work_order_rec.activity_cause;
	l_eam_wo_rec.activity_source := p_work_order_rec.activity_source;
	l_eam_wo_rec.work_order_type := p_work_order_rec.work_order_type;

  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'Fetching default owning dept');
  end if;
  IF p_work_order_rec.owning_department is not null THEN
  l_dept_id := p_work_order_rec.owning_department;
  ELSE if p_work_order_rec.owning_department_code is not null THEN
  	  SELECT department_id into l_dept_id
   FROM bom_departments
   WHERE department_code =  p_work_order_rec.owning_department_code and organization_id= p_work_order_rec.organization_id;
      ELSE
       WIP_EAMWORKORDER_PVT.Get_EAM_Owning_Dept_Default
         (   p_api_version               => 1.0,
            p_init_msg_list             => FND_API.G_FALSE,
            p_commit                    => FND_API.G_FALSE,
            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
            x_return_status             => l_def_return_status,
            x_msg_count                 => l_def_msg_count,
            x_msg_data                  => l_def_msg_data,
            p_primary_item_id           => l_eam_wo_rec.asset_activity_id,
            p_organization_id           => l_eam_wo_rec.organization_id,
            p_maintenance_object_type   => l_maintenance_object_type,
            p_maintenance_object_id     => l_maintenance_object_id,
            p_rebuild_item_id           => l_eam_wo_rec.rebuild_item_id,
            x_owning_department_id      => l_dept_id
         );
     END IF ;
  END IF ;

    /* If the Department of Work Order cannot be set then change the status of Work Order to Unrelease */
  IF l_dept_id is null and p_work_order_rec.status_type not in (1,6,17) THEN
      l_eam_wo_rec.status_type:=1;
   END IF ;
  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'default owning dept id:'
    || l_dept_id);
  end if;

	l_eam_wo_rec.job_quantity := null;
	l_eam_wo_rec.date_released := p_work_order_rec.date_released;
	l_eam_wo_rec.owning_department := l_dept_id;
	l_eam_wo_rec.priority := p_work_order_rec.priority;
	l_eam_wo_rec.requested_start_date := p_work_order_rec.requested_start_date;
	l_eam_wo_rec.due_date := p_work_order_rec.due_date;
	l_eam_wo_rec.shutdown_type := p_work_order_rec.shutdown_type;
	l_eam_wo_rec.firm_planned_flag := p_work_order_rec.firm_planned_flag;
	l_eam_wo_rec.notification_required := p_work_order_rec.notification_required;
	l_eam_wo_rec.tagout_required := p_work_order_rec.tagout_required;
	l_eam_wo_rec.plan_maintenance := p_work_order_rec.plan_maintenance;
	l_eam_wo_rec.project_id := p_work_order_rec.project_id;
	l_eam_wo_rec.task_id := p_work_order_rec.task_id;
	--project_costed
	l_eam_wo_rec.end_item_unit_number := p_work_order_rec.end_item_unit_number;
	l_eam_wo_rec.schedule_group_id := p_work_order_rec.schedule_group_id;
	l_eam_wo_rec.bom_revision_date := p_work_order_rec.bom_revision_date;
	l_eam_wo_rec.routing_revision_date := p_work_order_rec.routing_revision_date;
	l_eam_wo_rec.alternate_routing_designator := p_work_order_rec.alternate_routing_designator;
	l_eam_wo_rec.alternate_bom_designator := p_work_order_rec.alternate_bom_designator;
	l_eam_wo_rec.routing_revision := p_work_order_rec.routing_revision;
	l_eam_wo_rec.bom_revision := p_work_order_rec.bom_revision;
	l_eam_wo_rec.parent_wip_entity_id := p_work_order_rec.parent_wip_entity_id;
	l_eam_wo_rec.manual_rebuild_flag := p_work_order_rec.manual_rebuild_flag;
	l_eam_wo_rec.pm_schedule_id := p_work_order_rec.pm_schedule_id;
	l_eam_wo_rec.wip_supply_type := p_work_order_rec.wip_supply_type;
	l_eam_wo_rec.material_account := null;
	l_eam_wo_rec.material_overhead_account := null ;
	l_eam_wo_rec.resource_account := null;
	l_eam_wo_rec.outside_processing_account := null;
	l_eam_wo_rec.material_variance_account := null;
	l_eam_wo_rec.resource_variance_account := null;
	l_eam_wo_rec.outside_proc_variance_account := null;
	l_eam_wo_rec.std_cost_adjustment_account := null;
	l_eam_wo_rec.overhead_account := null;
	l_eam_wo_rec.overhead_variance_account := null;
	l_eam_wo_rec.scheduled_start_date := sysdate;
	l_eam_wo_rec.scheduled_completion_date := sysdate;
	l_eam_wo_rec.common_bom_sequence_id := null;
	l_eam_wo_rec.common_routing_sequence_id := null;
	l_eam_wo_rec.po_creation_time := null;
	l_eam_wo_rec.gen_object_id := l_gen_object_id;
	l_eam_wo_rec.attribute_category := p_work_order_rec.attribute_category;
	l_eam_wo_rec.attribute1 := p_work_order_rec.attribute1;
	l_eam_wo_rec.attribute2 := p_work_order_rec.attribute2;
	l_eam_wo_rec.attribute3 := p_work_order_rec.attribute3;
	l_eam_wo_rec.attribute4 := p_work_order_rec.attribute4;
	l_eam_wo_rec.attribute5 := p_work_order_rec.attribute5;
	l_eam_wo_rec.attribute6 := p_work_order_rec.attribute6;
	l_eam_wo_rec.attribute7 := p_work_order_rec.attribute7;
	l_eam_wo_rec.attribute8 := p_work_order_rec.attribute8;
	l_eam_wo_rec.attribute9 := p_work_order_rec.attribute9;
	l_eam_wo_rec.attribute10 := p_work_order_rec.attribute10;
	l_eam_wo_rec.attribute11 := p_work_order_rec.attribute11;
	l_eam_wo_rec.attribute12 := p_work_order_rec.attribute12;
	l_eam_wo_rec.attribute13 := p_work_order_rec.attribute13;
	l_eam_wo_rec.attribute14 := p_work_order_rec.attribute14;
	l_eam_wo_rec.attribute15 := p_work_order_rec.attribute15;
	l_eam_wo_rec.material_issue_by_mo := null;
	l_eam_wo_rec.issue_zero_cost_flag := null;
	l_eam_wo_rec.user_id := fnd_global.user_id;
	l_eam_wo_rec.responsibility_id :=  fnd_global.resp_id;
	l_eam_wo_rec.request_id := p_work_order_rec.request_id;
	l_eam_wo_rec.program_id := p_work_order_rec.program_id;
	l_eam_wo_rec.program_application_id := p_work_order_rec.program_application_id;
	l_eam_wo_rec.source_line_id := p_work_order_rec.source_line_id;
	l_eam_wo_rec.source_code := p_work_order_rec.source_code;
--	l_eam_wo_rec.return_status :=
	l_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'Calling work order API');
  end if;
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
	  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
	  		         , p_debug_filename          => 'wipvewob.log'
	  		         , p_output_dir              => l_output_dir
	                         , p_debug_file_mode         => 'W'
	                       );
      if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'work order API returned status: '|| l_return_status);
      end if;

       if(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
	      fnd_message.set_name('EAM','EAM_CANNOT_CREAT_WRK');
	      fnd_msg_pub.add();
	      RAISE FND_API.G_EXC_ERROR;
       end if ;

      IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
      END IF;

    -- End of API body.
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count       =>      x_msg_count,
         p_data        =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Create_EAM_Work_Order_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        x_request_id := l_request_id;
        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	 ROLLBACK TO Create_EAM_Work_Order_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_request_id := l_request_id;
        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN OTHERS THEN
	ROLLBACK TO Create_EAM_Work_Order_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_request_id := l_request_id;
          IF     FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
END Create_EAM_Work_Order;


/********************************************************************/
-- API to obtain eAM Mass Load Defaults
/********************************************************************/


PROCEDURE Get_EAM_Act_Cause_Default
(   p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_primary_item_id           IN  NUMBER,
    p_organization_id           IN  NUMBER,
    p_maintenance_object_type   IN  NUMBER,
    p_maintenance_object_id     IN  NUMBER,
    p_rebuild_item_id           IN  NUMBER,
    x_activity_cause_code       OUT NOCOPY NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30)     := 'Get_EAM_Act_Cause_Default';
l_api_version       CONSTANT NUMBER           := 1.0;


BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Get_EAM_Act_Cause_Default_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body

    -- Find the Activity Cause from the Association Table
     IF (p_maintenance_object_type IN (1,2) ) THEN -- 'MSN', 'MSI'
        BEGIN
            SELECT  MEAA.activity_cause_code
            INTO    x_activity_cause_code
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id        = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_maintenance_object_id
            AND     MEAA.maintenance_object_type = p_maintenance_object_type
            AND     NVL(MEAA.tmpl_flag,'N') = 'N';
        EXCEPTION
            WHEN OTHERS THEN
                    x_activity_cause_code := NULL;
        END;
    END IF;

    IF (p_maintenance_object_type = 3) THEN -- 'CII'
        BEGIN
        --Begin bug fix 7343758
            /*SELECT  MEAA.activity_cause_code
            INTO    x_activity_cause_code
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id  = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_rebuild_item_id
            AND     MEAA.maintenance_object_type = 2 ;-- 'MSI'*/
            SELECT eomd.activity_cause_code
            INTO    x_activity_cause_code
            FROM eam_org_maint_defaults eomd, mtl_eam_asset_activities MEAA
            WHERE eomd.organization_id=p_organization_id
            AND eomd.object_type = 60
            AND eomd.object_id = meaa.activity_association_id
            AND MEAA.asset_activity_id  = p_primary_item_id
            AND MEAA.maintenance_object_id = p_maintenance_object_id
            AND MEAA.maintenance_object_type = 3 ;
          --End bug fix 7343758
        EXCEPTION
            WHEN OTHERS THEN
                    x_activity_cause_code := NULL;
        END;

    END IF;

    -- Find the Activity Cause from the MSI or MSN Tables based on maintenance_object_type

    IF (x_activity_cause_code IS NULL) THEN
        BEGIN
            SELECT  MSI.eam_activity_cause_code
            INTO    x_activity_cause_code
            FROM    MTL_SYSTEM_ITEMS MSI
            WHERE   MSI.inventory_item_id = p_primary_item_id
            AND     MSI.organization_id = p_organization_id;
        EXCEPTION
            WHEN OTHERS THEN
                    x_activity_cause_code := NULL;
        END;

    END IF;


    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count       =>      x_msg_count,
         p_data        =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Get_EAM_Act_Cause_Default_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_EAM_Act_Cause_Default_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN OTHERS THEN
        ROLLBACK TO Get_EAM_Act_Cause_Default_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
END Get_EAM_Act_Cause_Default;

/*Procedure to find the log directory path to write debug messages for EAM workorder API*/

      PROCEDURE log_path(
	    x_output_dir   OUT NOCOPY VARCHAR2
	  )
	IS
		        l_full_path     VARCHAR2(512);
			l_new_full_path         VARCHAR2(512);
			l_file_dir      VARCHAR2(512);

			fileHandler     UTL_FILE.FILE_TYPE;
			fileName        VARCHAR2(50);

			l_flag          NUMBER;
	BEGIN
	           fileName:='test.log';--this is only a dummy filename to check if directory is valid or not

        	   /* get output directory path from database */
			SELECT value
			INTO   l_full_path
			FROM   v$parameter
			WHERE  name = 'utl_file_dir';

			l_flag := 0;
			--l_full_path contains a list of comma-separated directories
			WHILE(TRUE)
			LOOP
					    --get the first dir in the list
					    SELECT trim(substr(l_full_path, 1, decode(instr(l_full_path,',')-1,
											  -1, length(l_full_path),
											  instr(l_full_path, ',')-1
											 )
								  )
							   )
					    INTO  l_file_dir
					    FROM  dual;

					    -- check if the dir is valid
					    BEGIN
						    fileHandler := UTL_FILE.FOPEN(l_file_dir , filename, 'w');
						    l_flag := 1;
					    EXCEPTION
						    WHEN utl_file.invalid_path THEN
							l_flag := 0;
						    WHEN utl_file.invalid_operation THEN
							l_flag := 0;
					    END;

					    IF l_flag = 1 THEN --got a valid directory
						utl_file.fclose(fileHandler);
						EXIT;
					    END IF;

					    --earlier found dir was not a valid dir,
					    --so remove that from the list, and get the new list
					    l_new_full_path := trim(substr(l_full_path, instr(l_full_path, ',')+1, length(l_full_path)));

					    --if the new list has not changed, there are no more valid dirs left
					    IF l_full_path = l_new_full_path THEN
						    l_flag:=0;
						    EXIT;
					    END IF;
					     l_full_path := l_new_full_path;
			 END LOOP;

			 IF(l_flag=1) THEN --found a valid directory
			     x_output_dir := l_file_dir;
			  ELSE
			      x_output_dir:= null;

			  END IF;
         EXCEPTION
              WHEN OTHERS THEN
                  x_output_dir := null;

	END log_path;

/********************************************************************/
-- API to obtain eAM Mass Load Defaults
/********************************************************************/


PROCEDURE Get_EAM_Act_Type_Default
(   p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_primary_item_id           IN  NUMBER,
    p_organization_id           IN  NUMBER,
    p_maintenance_object_type   IN  NUMBER,
    p_maintenance_object_id     IN  NUMBER,
    p_rebuild_item_id           IN  NUMBER,
    x_activity_type_code        OUT NOCOPY NUMBER
)
IS
l_api_name            CONSTANT VARCHAR2(30)     := 'Get_EAM_Act_Type_Default';
l_api_version       CONSTANT NUMBER             := 1.0;


BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Get_EAM_Act_Type_Default_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body

    -- Find the Activity type from the Association Table
     IF (p_maintenance_object_type IN (1,2) ) THEN -- 'MSN', 'MSI'
        BEGIN
            SELECT  MEAA.activity_type_code
            INTO    x_activity_type_code
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id        = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_maintenance_object_id
            AND     MEAA.maintenance_object_type = p_maintenance_object_type
            AND     NVL(MEAA.tmpl_flag,'N') = 'N';
        EXCEPTION
            WHEN OTHERS THEN
                    x_activity_type_code := NULL;
        END;
    END IF;

    IF (p_maintenance_object_type = 3) THEN -- 'CII'
        BEGIN
         --Begin bug fix 7343758
            /*SELECT  MEAA.activity_type_code
            INTO    x_activity_type_code
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id  = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_rebuild_item_id
            AND     MEAA.maintenance_object_type = 2 ;-- 'MSI'*/
             SELECT eomd.activity_type_code
            INTO    x_activity_type_code
            FROM eam_org_maint_defaults eomd, mtl_eam_asset_activities MEAA
            WHERE eomd.organization_id=p_organization_id
            AND eomd.object_type = 60
            AND eomd.object_id = meaa.activity_association_id
            AND MEAA.asset_activity_id  = p_primary_item_id
            AND MEAA.maintenance_object_id = p_maintenance_object_id
            AND MEAA.maintenance_object_type = 3 ;
          --End bug fix 7343758
        EXCEPTION
            WHEN OTHERS THEN
                    x_activity_type_code := NULL;
        END;

    END IF;

    -- Find the Activity type from the MSI or MSN Tables based on maintenance_object_type

    IF (x_activity_type_code IS NULL) THEN
        BEGIN
            SELECT  MSI.eam_activity_type_code
            INTO    x_activity_type_code
            FROM    MTL_SYSTEM_ITEMS MSI
            WHERE   MSI.inventory_item_id = p_primary_item_id
            AND     MSI.organization_id = p_organization_id;
        EXCEPTION
            WHEN OTHERS THEN
                    x_activity_type_code := NULL;
        END;

    END IF;

    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count       =>      x_msg_count,
         p_data        =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Get_EAM_Act_Type_Default_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_EAM_Act_Type_Default_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN OTHERS THEN
        ROLLBACK TO Get_EAM_Act_Type_Default_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
END Get_EAM_Act_type_Default;



/********************************************************************/
-- API to obtain eAM Mass Load Defaults
/********************************************************************/


PROCEDURE Get_EAM_Act_Source_Default
(   p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_primary_item_id           IN  NUMBER,
    p_organization_id           IN  NUMBER,
    p_maintenance_object_type   IN  NUMBER,
    p_maintenance_object_id     IN  NUMBER,
    p_rebuild_item_id           IN  NUMBER,
    x_activity_Source_code      OUT NOCOPY NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30)     := 'Get_EAM_Act_Source_Default';
l_api_version       CONSTANT NUMBER           := 1.0;


BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Get_EAM_Act_Source_Default_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body

    -- Find the Activity Source from the Association Table
     IF (p_maintenance_object_type IN (1, 2) ) THEN -- 'MSN', 'MSI'
        BEGIN
            SELECT  MEAA.activity_source_code
            INTO    x_activity_source_code
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id        = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_maintenance_object_id
            AND     MEAA.maintenance_object_type = p_maintenance_object_type
            AND     NVL(MEAA.tmpl_flag,'N') = 'N';
        EXCEPTION
            WHEN OTHERS THEN
                    x_activity_source_code := NULL;
        END;
    END IF;

    IF (p_maintenance_object_type = 3) THEN -- 'CII'
        BEGIN
         --Begin bug fix 7343758
           /* SELECT  MEAA.activity_source_code
            INTO    x_activity_source_code
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id  = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_rebuild_item_id
            AND     MEAA.maintenance_object_type = 2 ;-- 'MSI'*/
            SELECT eomd.activity_source_code
            INTO    x_activity_source_code
            FROM eam_org_maint_defaults eomd, mtl_eam_asset_activities MEAA
            WHERE eomd.organization_id=p_organization_id
            AND eomd.object_type = 60
            AND eomd.object_id = meaa.activity_association_id
            AND MEAA.asset_activity_id  = p_primary_item_id
            AND MEAA.maintenance_object_id = p_maintenance_object_id
            AND MEAA.maintenance_object_type = 3 ;
            --End bug fix 7343758
        EXCEPTION
            WHEN OTHERS THEN
                    x_activity_source_code := NULL;
        END;

    END IF;

    -- Find the Activity Source from the MSI or MSN Tables based on maintenance_object_type

    IF (x_activity_source_code IS NULL) THEN
        BEGIN
            SELECT  MSI.eam_activity_source_code
            INTO    x_activity_source_code
            FROM    MTL_SYSTEM_ITEMS MSI
            WHERE   MSI.inventory_item_id = p_primary_item_id
            AND     MSI.organization_id = p_organization_id;
        EXCEPTION
            WHEN OTHERS THEN
                    x_activity_source_code := NULL;
        END;

    END IF;

    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count       =>      x_msg_count,
         p_data        =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Get_EAM_Act_Source_Default_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_EAM_Act_Source_Default_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN OTHERS THEN
        ROLLBACK TO Get_EAM_Act_Source_Default_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
END Get_EAM_Act_Source_Default;



/********************************************************************/
-- API to obtain eAM Mass Load Defaults
/********************************************************************/


PROCEDURE Get_EAM_Shutdown_Default
(   p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_primary_item_id           IN  NUMBER,
    p_organization_id           IN  NUMBER,
    p_maintenance_object_type   IN  NUMBER,
    p_maintenance_object_id     IN  NUMBER,
    p_rebuild_item_id           IN  NUMBER,
    x_shutdown_type_code        OUT NOCOPY NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30)     := 'Get_EAM_Shutdown_Default';
l_api_version       CONSTANT NUMBER           := 1.0;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Get_EAM_Shutdown_Default_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body

    -- Find the Shutdown Type from the Association Table
     IF (p_maintenance_object_type IN (1,2) ) THEN -- 'MSN', 'MSI'
        BEGIN
            SELECT  MEAA.shutdown_type_code
            INTO    x_shutdown_type_code
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id        = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_maintenance_object_id
            AND     MEAA.maintenance_object_type = p_maintenance_object_type
            AND     NVL(MEAA.tmpl_flag,'N') = 'N';
        EXCEPTION
            WHEN OTHERS THEN
                    x_shutdown_type_code := NULL;
        END;
    END IF;

    IF (p_maintenance_object_type = 3) THEN -- 'CII'
        BEGIN
         --Begin bug fix 7343758
           /* SELECT  MEAA.shutdown_type_code
            INTO    x_shutdown_type_code
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id  = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_rebuild_item_id
            AND     MEAA.maintenance_object_type = 2 ;-- 'MSI'*/

            SELECT eomd.shutdown_type_code
            INTO    x_shutdown_type_code
            FROM eam_org_maint_defaults eomd, mtl_eam_asset_activities MEAA
            WHERE eomd.organization_id=p_organization_id
            AND eomd.object_type = 60
            AND eomd.object_id = meaa.activity_association_id
            AND MEAA.asset_activity_id  = p_primary_item_id
            AND MEAA.maintenance_object_id = p_maintenance_object_id
            AND MEAA.maintenance_object_type = 3 ;

            --End bug fix 7343758
        EXCEPTION
            WHEN OTHERS THEN
                    x_shutdown_type_code := NULL;
        END;

    END IF;

    -- Find the Activity source from the MSI or MSN Tables based on maintenance_object_source

    IF (x_shutdown_type_code IS NULL) THEN
        BEGIN
            SELECT  MSI.eam_act_shutdown_status
            INTO    x_shutdown_type_code
            FROM    MTL_SYSTEM_ITEMS MSI
            WHERE   MSI.inventory_item_id = p_primary_item_id
            AND     MSI.organization_id = p_organization_id;
        EXCEPTION
            WHEN OTHERS THEN
                    x_shutdown_type_code := NULL;
        END;

    END IF;

    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count       =>      x_msg_count,
         p_data        =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Get_EAM_Shutdown_Default_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_EAM_Shutdown_Default_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN OTHERS THEN
        ROLLBACK TO Get_EAM_Shutdown_Default_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
END Get_EAM_Shutdown_Default;



/********************************************************************/
-- API to obtain eAM Mass Load Defaults
/********************************************************************/


PROCEDURE Get_EAM_Notification_Default
(   p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_primary_item_id           IN  NUMBER,
    p_organization_id           IN  NUMBER,
    p_maintenance_object_type   IN  NUMBER,
    p_maintenance_object_id     IN  NUMBER,
    p_rebuild_item_id           IN  NUMBER,
    x_notification_flag         OUT NOCOPY VARCHAr2
)
IS
l_api_name          CONSTANT VARCHAR2(30)     := 'Get_EAM_Notification_Default';
l_api_version       CONSTANT NUMBER           := 1.0;


BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Get_EAM_Notification_Def_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body
/*
    -- Find the Shutdown Type from the Association Table
     IF (p_maintenance_object_type IN (1,2) ) THEN -- 'MSN', 'MSI'
        BEGIN
            SELECT  MEAA.notification_required
            INTO    x_notification_flag
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id        = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_maintenance_object_id
            AND     MEAA.maintenance_object_type = p_maintenance_object_type
            AND     NVL(MEAA.tmpl_flag,'N') = 'N';
        EXCEPTION
            WHEN OTHERS THEN
                    x_notification_flag := NULL;
        END;
    END IF;

    IF (p_maintenance_object_type = 3) THEN -- 'CII'
        BEGIN
            SELECT  MEAA.notification_required
            INTO    x_notification_flag
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id  = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_rebuild_item_id
            AND     MEAA.maintenance_object_type = 2 ;-- 'MSI'
        EXCEPTION
            WHEN OTHERS THEN
                    x_notification_flag := NULL;
        END;

    END IF;
*/
    -- Find the Activity source from the MSI or MSN Tables based on maintenance_object_source

    IF (x_notification_flag IS NULL) THEN
        BEGIN
            SELECT  MSI.eam_act_notification_flag
            INTO    x_notification_flag
            FROM    MTL_SYSTEM_ITEMS MSI
            WHERE   MSI.inventory_item_id = p_primary_item_id
            AND     MSI.organization_id = p_organization_id;
        EXCEPTION
            WHEN OTHERS THEN
                    x_notification_flag := NULL;
        END;

    END IF;

    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count       =>      x_msg_count,
         p_data        =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Get_EAM_Notification_Def_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_EAM_Notification_Def_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN OTHERS THEN
        ROLLBACK TO Get_EAM_Notification_Def_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
END Get_EAM_Notification_Default;



/********************************************************************/
-- API to obtain eAM Mass Load Defaults
/********************************************************************/


PROCEDURE Get_EAM_Tagout_Default
(   p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_primary_item_id           IN  NUMBER,
    p_organization_id           IN  NUMBER,
    p_maintenance_object_type   IN  NUMBER,
    p_maintenance_object_id     IN  NUMBER,
    p_rebuild_item_id           IN  NUMBER,
    x_tagout_required           OUT NOCOPY VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30)     := 'Get_EAM_Tagout_Default';
l_api_version       CONSTANT NUMBER           := 1.0;


BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Get_EAM_Tagout_Default_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body

    -- Find the Shutdown Type from the Association Table
     IF (p_maintenance_object_type IN (1,2) ) THEN -- 'MSN', 'MSI'
        BEGIN
            SELECT  MEAA.tagging_required_flag
            INTO    x_tagout_required
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id        = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_maintenance_object_id
            AND     MEAA.maintenance_object_type = p_maintenance_object_type
            AND     NVL(MEAA.tmpl_flag,'N') = 'N';
        EXCEPTION
            WHEN OTHERS THEN
                    x_tagout_required := NULL;
        END;
    END IF;

    IF (p_maintenance_object_type = 3) THEN -- 'CII'
        BEGIN
        /*Begin fix for 8287895*
            SELECT  MEAA.tagging_required_flag
            INTO    x_tagout_required
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.organization_id    = p_organization_id
            AND     MEAA.asset_activity_id  = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_rebuild_item_id
            AND     MEAA.maintenance_object_type = 2 ;-- 'MSI'*/

            SELECT eomd.tagging_required_flag
            INTO    x_tagout_required
            FROM eam_org_maint_defaults eomd, mtl_eam_asset_activities MEAA
            WHERE eomd.organization_id=p_organization_id
            AND eomd.object_type = 60
            AND eomd.object_id = meaa.activity_association_id
            AND MEAA.asset_activity_id  = p_primary_item_id
            AND MEAA.maintenance_object_id = p_maintenance_object_id
            AND MEAA.maintenance_object_type = 3 ;

            /*End fix for 8287895*/
        EXCEPTION
            WHEN OTHERS THEN
                    x_tagout_required := NULL;
        END;

    END IF;

    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count       =>      x_msg_count,
         p_data        =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Get_EAM_Tagout_Default_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_EAM_Tagout_Default_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN OTHERS THEN
        ROLLBACK TO Get_EAM_Tagout_Default_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
END Get_EAM_Tagout_Default;



/********************************************************************/
-- API to obtain eAM Mass Load Defaults
/********************************************************************/



PROCEDURE Get_EAM_Owning_Dept_Default
(   p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_primary_item_id           IN  NUMBER,
    p_organization_id           IN  NUMBER,
    p_maintenance_object_type   IN  NUMBER,
    p_maintenance_object_id     IN  NUMBER,
    p_rebuild_item_id           IN  NUMBER,
    x_owning_department_id      OUT NOCOPY NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30)     := 'Get_EAM_Owning_Dept_Default';
l_api_version       CONSTANT NUMBER           := 1.0;
l_act_assoc_id               NUMBER;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Get_EAM_Owning_Dept_Def_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body

    -- Find the Shutdown Type from the Association Table
     IF (p_maintenance_object_type = 1 ) THEN -- 'MSN', 'MSI'
        BEGIN
            SELECT  MEAA.owning_department_id
            INTO    x_owning_department_id
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.asset_activity_id        = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_maintenance_object_id
            AND     MEAA.maintenance_object_type = p_maintenance_object_type
            AND     NVL(MEAA.tmpl_flag,'N') = 'N';
        EXCEPTION
            WHEN OTHERS THEN
                    x_owning_department_id := NULL;
        END;
    END IF;

    IF (p_maintenance_object_type IN( 2,3) ) THEN -- 'CII'
        BEGIN
	    SELECT  MEAA.activity_association_id
            INTO    l_act_assoc_id
            FROM    MTL_EAM_ASSET_ACTIVITIES MEAA
            WHERE   MEAA.asset_activity_id     = p_primary_item_id
            AND     MEAA.maintenance_object_id = p_maintenance_object_id
            AND     MEAA.maintenance_object_type = p_maintenance_object_type
            AND     NVL(MEAA.tmpl_flag,'N') = 'N';

	    SELECT  EOMD.OWNING_DEPARTMENT_ID
            INTO    x_owning_department_id
            FROM    EAM_ORG_MAINT_DEFAULTS EOMD
            WHERE   EOMD.organization_id    = p_organization_id
            AND     EOMD.OBJECT_ID  = l_act_assoc_id
            AND     EOMD.OBJECT_TYPE IN (40,60) ;
        EXCEPTION
            WHEN OTHERS THEN
                    x_owning_department_id := NULL;
        END;

    END IF;

       -- Find the Activity source from the MSI or MSN Tables based on maintenance_object_source

    IF (x_owning_department_id IS NULL AND p_maintenance_object_type = 3) THEN
        BEGIN
            SELECT  EOMD.OWNING_DEPARTMENT_ID
            INTO    x_owning_department_id
            FROM    EAM_ORG_MAINT_DEFAULTS EOMD
            WHERE   EOMD.organization_id  = p_organization_id
            AND     EOMD.OBJECT_ID  = p_maintenance_object_id
            AND     EOMD.OBJECT_TYPE = 50 ;
        EXCEPTION
            WHEN OTHERS THEN
                    x_owning_department_id := NULL;
        END;

    END IF;

       -- Find the Activity source from the EAM Parameters Tables based on maintenance_object_source

    IF (x_owning_department_id IS NULL AND p_maintenance_object_type IN (2,3) ) THEN
        BEGIN
            SELECT  WEP.default_department_id
            INTO    x_owning_department_id
            FROM    WIP_EAM_PARAMETERS WEP
            WHERE   WEP.organization_id = p_organization_id;
        EXCEPTION
            WHEN OTHERS THEN
                    x_owning_department_id := NULL;
        END;

    END IF;

    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count       =>      x_msg_count,
         p_data        =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Get_EAM_Owning_Dept_Def_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Get_EAM_Owning_Dept_Def_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
    WHEN OTHERS THEN
        ROLLBACK TO Get_EAM_Owning_Dept_Def_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (p_count       =>      x_msg_count,
             p_data        =>      x_msg_data
            );
END Get_EAM_Owning_Dept_Default;


END WIP_EAMWORKORDER_PVT;

/
