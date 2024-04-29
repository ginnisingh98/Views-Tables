--------------------------------------------------------
--  DDL for Package Body EAM_WO_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_UTILITY_PVT" AS
/* $Header: EAMVWOUB.pls 120.11 2006/06/08 18:08:33 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWOUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_WO_UTILITY_PVT';

        /*********************************************************************
        * Procedure     : Query_Row
        * Parameters IN : wip entity id
        *                 organization Id
        * Parameters OUT NOCOPY: EAM WO column record
        *                 Mesg token Table
        *                 Return Status
        * Purpose       : Procedure will query the database record
        *                 and return with those records.
        ***********************************************************************/
        PROCEDURE Query_Row
        (  p_wip_entity_id       IN  NUMBER
         , p_organization_id     IN  NUMBER
         , x_eam_wo_rec          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_Return_status       OUT NOCOPY VARCHAR2
        )
        IS
                l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
                l_dummy                 varchar2(10);
        BEGIN

                SELECT   we.wip_entity_name
                       , wdj.wip_entity_id
                       , wdj.organization_id
                       , wdj.description
                       , wdj.asset_number
                       , wdj.asset_group_id
                       , wdj.rebuild_item_id
                       , wdj.rebuild_serial_number
                       , we.gen_object_id
                       , wdj.maintenance_object_id
                       , wdj.maintenance_object_type
                       , wdj.maintenance_object_source
                       , wdj.eam_linear_location_id
                       , wdj.class_code
                       , wdj.primary_item_id
                       , wdj.activity_type
                       , wdj.activity_cause
                       , wdj.activity_source
                       , wdj.work_order_type
                       , wdj.status_type
                       , wdj.start_quantity
                       , wdj.date_released
                       , wdj.owning_department
                       , wdj.priority
                       , wdj.requested_start_date
                       , wdj.due_date
                       , wdj.shutdown_type
                       , wdj.firm_planned_flag
                       , wdj.notification_required
                       , wdj.tagout_required
                       , wdj.plan_maintenance
                       , wdj.project_id
                       , wdj.task_id
                       --, wdj.project_costed
                       , wdj.end_item_unit_number
                       , wdj.schedule_group_id
                       , wdj.bom_revision_date
                       , wdj.routing_revision_date
                       , wdj.alternate_routing_designator
                       , wdj.alternate_bom_designator
                       , wdj.routing_revision
                       , wdj.bom_revision
                       , wdj.parent_wip_entity_id
                       , wdj.manual_rebuild_flag
                       , wdj.pm_schedule_id
                       , wdj.material_account
                       , wdj.material_overhead_account
                       , wdj.resource_account
                       , wdj.outside_processing_account
                       , wdj.material_variance_account
                       , wdj.resource_variance_account
                       , wdj.outside_proc_variance_account
                       , wdj.std_cost_adjustment_account
                       , wdj.overhead_account
                       , wdj.overhead_variance_account
                       , wdj.scheduled_start_date
                       , wdj.scheduled_completion_date
                       , wdj.common_bom_sequence_id
                       , wdj.common_routing_sequence_id
                       , wdj.po_creation_time
                       , wdj.attribute_category
                       , wdj.attribute1
                       , wdj.attribute2
                       , wdj.attribute3
                       , wdj.attribute4
                       , wdj.attribute5
                       , wdj.attribute6
                       , wdj.attribute7
                       , wdj.attribute8
                       , wdj.attribute9
                       , wdj.attribute10
                       , wdj.attribute11
                       , wdj.attribute12
                       , wdj.attribute13
                       , wdj.attribute14
                       , wdj.attribute15
                       , wdj.material_issue_by_mo
                       , wdj.source_line_id
                       , wdj.source_code
                       , wdj.issue_zero_cost_flag
		       , ewod.user_defined_status_id
		       , ewod.pending_flag
		       , ewod.material_shortage_check_date
		       , ewod.material_shortage_flag
		       , ewod.workflow_type
		       , ewod.warranty_claim_status
		       , ewod.cycle_id
		       , ewod.seq_id
		       , ewod.ds_scheduled_flag
		       , ewod.assignment_complete
		       , ewod.warranty_active
                       , ewod.pm_suggested_start_date
                       , ewod.pm_suggested_end_date
                       , ewod.pm_base_meter_reading
                       , ewod.pm_base_meter
    	               , ewod.failure_code_required
                INTO
                         l_eam_wo_rec.wip_entity_name
                       , l_eam_wo_rec.wip_entity_id
                       , l_eam_wo_rec.organization_id
                       , l_eam_wo_rec.description
                       , l_eam_wo_rec.asset_number
                       , l_eam_wo_rec.asset_group_id
                       , l_eam_wo_rec.rebuild_item_id
                       , l_eam_wo_rec.rebuild_serial_number
                       , l_eam_wo_rec.gen_object_id
                       , l_eam_wo_rec.maintenance_object_id
                       , l_eam_wo_rec.maintenance_object_type
                       , l_eam_wo_rec.maintenance_object_source
                       , l_eam_wo_rec.eam_linear_location_id
                       , l_eam_wo_rec.class_code
                       , l_eam_wo_rec.asset_activity_id
                       , l_eam_wo_rec.activity_type
                       , l_eam_wo_rec.activity_cause
                       , l_eam_wo_rec.activity_source
                       , l_eam_wo_rec.work_order_type
                       , l_eam_wo_rec.status_type
                       , l_eam_wo_rec.job_quantity
                       , l_eam_wo_rec.date_released
                       , l_eam_wo_rec.owning_department
                       , l_eam_wo_rec.priority
                       , l_eam_wo_rec.requested_start_date
                       , l_eam_wo_rec.due_date
                       , l_eam_wo_rec.shutdown_type
                       , l_eam_wo_rec.firm_planned_flag
                       , l_eam_wo_rec.notification_required
                       , l_eam_wo_rec.tagout_required
                       , l_eam_wo_rec.plan_maintenance
                       , l_eam_wo_rec.project_id
                       , l_eam_wo_rec.task_id
                       --, l_eam_wo_rec.project_costed
                       , l_eam_wo_rec.end_item_unit_number
                       , l_eam_wo_rec.schedule_group_id
                       , l_eam_wo_rec.bom_revision_date
                       , l_eam_wo_rec.routing_revision_date
                       , l_eam_wo_rec.alternate_routing_designator
                       , l_eam_wo_rec.alternate_bom_designator
                       , l_eam_wo_rec.routing_revision
                       , l_eam_wo_rec.bom_revision
                       , l_eam_wo_rec.parent_wip_entity_id
                       , l_eam_wo_rec.manual_rebuild_flag
                       , l_eam_wo_rec.pm_schedule_id
                       , l_eam_wo_rec.material_account
                       , l_eam_wo_rec.material_overhead_account
                       , l_eam_wo_rec.resource_account
                       , l_eam_wo_rec.outside_processing_account
                       , l_eam_wo_rec.material_variance_account
                       , l_eam_wo_rec.resource_variance_account
                       , l_eam_wo_rec.outside_proc_variance_account
                       , l_eam_wo_rec.std_cost_adjustment_account
                       , l_eam_wo_rec.overhead_account
                       , l_eam_wo_rec.overhead_variance_account
                       , l_eam_wo_rec.scheduled_start_date
                       , l_eam_wo_rec.scheduled_completion_date
                       , l_eam_wo_rec.common_bom_sequence_id
                       , l_eam_wo_rec.common_routing_sequence_id
                       , l_eam_wo_rec.po_creation_time
                       , l_eam_wo_rec.attribute_category
                       , l_eam_wo_rec.attribute1
                       , l_eam_wo_rec.attribute2
                       , l_eam_wo_rec.attribute3
                       , l_eam_wo_rec.attribute4
                       , l_eam_wo_rec.attribute5
                       , l_eam_wo_rec.attribute6
                       , l_eam_wo_rec.attribute7
                       , l_eam_wo_rec.attribute8
                       , l_eam_wo_rec.attribute9
                       , l_eam_wo_rec.attribute10
                       , l_eam_wo_rec.attribute11
                       , l_eam_wo_rec.attribute12
                       , l_eam_wo_rec.attribute13
                       , l_eam_wo_rec.attribute14
                       , l_eam_wo_rec.attribute15
                       , l_eam_wo_rec.material_issue_by_mo
                       , l_eam_wo_rec.source_line_id
                       , l_eam_wo_rec.source_code
                       , l_eam_wo_rec.issue_zero_cost_flag
		       , l_eam_wo_rec.user_defined_status_id
		       , l_eam_wo_rec.pending_flag
		       , l_eam_wo_rec.material_shortage_check_date
		       , l_eam_wo_rec.material_shortage_flag
		       , l_eam_wo_rec.workflow_type
		       , l_eam_wo_rec.warranty_claim_status
		       , l_eam_wo_rec.cycle_id
		       , l_eam_wo_rec.seq_id
		       , l_eam_wo_rec.ds_scheduled_flag
		       , l_eam_wo_rec.assignment_complete
		       , l_eam_wo_rec.warranty_active
                       , l_eam_wo_rec.pm_suggested_start_date
                       , l_eam_wo_rec.pm_suggested_end_date
                       , l_eam_wo_rec.pm_base_meter_reading
                       , l_eam_wo_rec.pm_base_meter
	               , l_eam_wo_rec.failure_code_required
                FROM  wip_discrete_jobs wdj, wip_entities we,eam_work_order_details ewod
                WHERE wdj.wip_entity_id = we.wip_entity_id
                AND   wdj.organization_id = we.organization_id
                AND   wdj.wip_entity_id = p_wip_entity_id
                AND   wdj.organization_id = p_organization_id
		AND   wdj.wip_entity_id = ewod.wip_entity_id(+)
		AND   wdj.organization_id = ewod.organization_id(+);


                x_return_status  := EAM_PROCESS_WO_PVT.G_RECORD_FOUND;
                x_eam_wo_rec     := l_eam_wo_rec;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND;
                        x_eam_wo_rec    := l_eam_wo_rec;

                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_eam_wo_rec    := l_eam_wo_rec;

        END Query_Row;


        /********************************************************************
        * Procedure     : Insert_Row
        * Parameters IN : Work Order column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 win_discrete_jobs and wip_entities table.
        *********************************************************************/

        PROCEDURE Insert_Row
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS

	l_asset_ops_msg_count	  NUMBER;
	l_asset_ops_msg_data	  VARCHAR2(2000);
	l_asset_ops_return_status VARCHAR2(1);

        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Writing EAM WO rec for ' || p_eam_wo_rec.wip_entity_name); END IF;

-- bug no 3444091
	if p_eam_wo_rec.scheduled_start_date > p_eam_wo_rec.scheduled_completion_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_WORKORDER_DT_ERR');
                return;
	end if;

                INSERT INTO WIP_DISCRETE_JOBS
                       ( wip_entity_id
                       , organization_id
                       , description
                       , asset_number
                       , asset_group_id
                       , rebuild_item_id
                       , rebuild_serial_number
                       , maintenance_object_id
                       , maintenance_object_type
                       , maintenance_object_source
                       , eam_linear_location_id
                       , class_code
                       , primary_item_id
                       , activity_type
                       , activity_cause
                       , activity_source
                       , work_order_type
                       , status_type
                       , date_released
                       , owning_department
                       , priority
                       , requested_start_date
                       , due_date
                       , shutdown_type
                       , firm_planned_flag
                       , notification_required
                       , tagout_required
                       , plan_maintenance
                       , project_id
                       , task_id
                       --, project_costed
                       , end_item_unit_number
                       , schedule_group_id
                       , bom_revision_date
                       , routing_revision_date
                       , alternate_routing_designator
                       , alternate_bom_designator
                       , routing_revision
                       , bom_revision
                       , parent_wip_entity_id
                       , manual_rebuild_flag
                       , pm_schedule_id
                       , job_type
                       , wip_supply_type
                       , material_account
                       , material_overhead_account
                       , resource_account
                       , outside_processing_account
                       , material_variance_account
                       , resource_variance_account
                       , outside_proc_variance_account
                       , std_cost_adjustment_account
                       , overhead_account
                       , overhead_variance_account
                       , scheduled_start_date
                       , scheduled_completion_date
                       , start_quantity
                       , quantity_completed
                       , quantity_scrapped
                       , net_quantity
                       , common_bom_sequence_id
                       , common_routing_sequence_id
                       , po_creation_time
                       , attribute_category
                       , attribute1
                       , attribute2
                       , attribute3
                       , attribute4
                       , attribute5
                       , attribute6
                       , attribute7
                       , attribute8
                       , attribute9
                       , attribute10
                       , attribute11
                       , attribute12
                       , attribute13
                       , attribute14
                       , attribute15
                       , material_issue_by_mo
                       , issue_zero_cost_flag
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , last_update_login
                       , request_id
                       , program_application_id
                       , program_id
                       , program_update_date
                       , source_line_id
                       , source_code
                       )
                VALUES
                       ( p_eam_wo_rec.wip_entity_id
                       , p_eam_wo_rec.organization_id
                       , p_eam_wo_rec.description
                       , p_eam_wo_rec.asset_number
                       , p_eam_wo_rec.asset_group_id
                       , p_eam_wo_rec.rebuild_item_id
                       , p_eam_wo_rec.rebuild_serial_number
                       , p_eam_wo_rec.maintenance_object_id
                       , p_eam_wo_rec.maintenance_object_type
                       , p_eam_wo_rec.maintenance_object_source
                       , p_eam_wo_rec.eam_linear_location_id
                       , p_eam_wo_rec.class_code
                       , p_eam_wo_rec.asset_activity_id
                       , p_eam_wo_rec.activity_type
                       , p_eam_wo_rec.activity_cause
                       , p_eam_wo_rec.activity_source
                       , p_eam_wo_rec.work_order_type
                       , 17 -- Always create WO in default status, then update to other statuses accordingly
                       , decode(p_eam_wo_rec.status_type,
						    WIP_CONSTANTS.RELEASED, decode(p_eam_wo_rec.date_released, NULL, SYSDATE, decode(sign(p_eam_wo_rec.date_released - sysdate),1,sysdate, p_eam_wo_rec.date_released)),
							WIP_CONSTANTS.HOLD, NULL,
							WIP_CONSTANTS.UNRELEASED, NULL,
							NULL)
                       , p_eam_wo_rec.owning_department
                       , p_eam_wo_rec.priority
                       , p_eam_wo_rec.requested_start_date
                       , p_eam_wo_rec.due_date
                       , p_eam_wo_rec.shutdown_type
                       , p_eam_wo_rec.firm_planned_flag
                       , p_eam_wo_rec.notification_required
                       , p_eam_wo_rec.tagout_required
                       , p_eam_wo_rec.plan_maintenance
                       , p_eam_wo_rec.project_id
                       , p_eam_wo_rec.task_id
                       --, p_eam_wo_rec.project_costed
                       , p_eam_wo_rec.end_item_unit_number
                       , p_eam_wo_rec.schedule_group_id
                       , round(p_eam_wo_rec.bom_revision_date,'MI')
                       , round(p_eam_wo_rec.routing_revision_date,'MI')
                       , p_eam_wo_rec.alternate_routing_designator
                       , p_eam_wo_rec.alternate_bom_designator
                       , p_eam_wo_rec.routing_revision
                       , p_eam_wo_rec.bom_revision
                       , p_eam_wo_rec.parent_wip_entity_id
                       , p_eam_wo_rec.manual_rebuild_flag
                       , p_eam_wo_rec.pm_schedule_id
                       , 3
                       , 7
                       , p_eam_wo_rec.material_account
                       , p_eam_wo_rec.material_overhead_account
                       , p_eam_wo_rec.resource_account
                       , p_eam_wo_rec.outside_processing_account
                       , p_eam_wo_rec.material_variance_account
                       , p_eam_wo_rec.resource_variance_account
                       , p_eam_wo_rec.outside_proc_variance_account
                       , p_eam_wo_rec.std_cost_adjustment_account
                       , p_eam_wo_rec.overhead_account
                       , p_eam_wo_rec.overhead_variance_account
                       , p_eam_wo_rec.scheduled_start_date
                       , p_eam_wo_rec.scheduled_completion_date
                       , p_eam_wo_rec.job_quantity
                       , 0
                       , 0
                       , 1
                       , p_eam_wo_rec.common_bom_sequence_id
                       , p_eam_wo_rec.common_routing_sequence_id
                       , p_eam_wo_rec.po_creation_time
                       , p_eam_wo_rec.attribute_category
                       , p_eam_wo_rec.attribute1
                       , p_eam_wo_rec.attribute2
                       , p_eam_wo_rec.attribute3
                       , p_eam_wo_rec.attribute4
                       , p_eam_wo_rec.attribute5
                       , p_eam_wo_rec.attribute6
                       , p_eam_wo_rec.attribute7
                       , p_eam_wo_rec.attribute8
                       , p_eam_wo_rec.attribute9
                       , p_eam_wo_rec.attribute10
                       , p_eam_wo_rec.attribute11
                       , p_eam_wo_rec.attribute12
                       , p_eam_wo_rec.attribute13
                       , p_eam_wo_rec.attribute14
                       , p_eam_wo_rec.attribute15
                       , p_eam_wo_rec.material_issue_by_mo
                       , p_eam_wo_rec.issue_zero_cost_flag
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , FND_GLOBAL.login_id
                       , p_eam_wo_rec.request_id
                       , p_eam_wo_rec.program_application_id
                       , p_eam_wo_rec.program_id
                       , SYSDATE
                       , p_eam_wo_rec.source_line_id
                       , p_eam_wo_rec.source_code
                       );

                INSERT INTO WIP_ENTITIES
                       ( wip_entity_id
                       , organization_id
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , last_update_login
                       , request_id
                       , program_application_id
                       , program_id
                       , program_update_date
                       , wip_entity_name
                       , entity_type
                       , description
                       , primary_item_id
                       , gen_object_id)
                VALUES
                       ( p_eam_wo_rec.wip_entity_id
                       , p_eam_wo_rec.organization_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , FND_GLOBAL.login_id
                       , p_eam_wo_rec.request_id
                       , p_eam_wo_rec.program_application_id
                       , p_eam_wo_rec.program_id
                       , SYSDATE
                       , p_eam_wo_rec.wip_entity_name
                       , 6
                       , p_eam_wo_rec.description
                       , p_eam_wo_rec.asset_activity_id
                       , MTL_GEN_OBJECT_ID_S.nextval);

		INSERT INTO EAM_WORK_ORDER_DETAILS
		(
			 wip_entity_id
		       , organization_id
		       , user_defined_status_id
		       , pending_flag
		       , material_shortage_check_date
		       , material_shortage_flag
		       , workflow_type
		       , warranty_claim_status
		       , cycle_id
		       , seq_id
		       , ds_scheduled_flag
		       , assignment_complete
		       , warranty_active
                       , pm_suggested_start_date
                       , pm_suggested_end_date
                       , pm_base_meter_reading
                       , pm_base_meter
		       , failure_code_required
		       , request_id
		       , program_id
		       , program_application_id
		       , program_update_date
		       , last_update_date
		       , last_updated_by
		       , creation_date
		       , created_by
		       , last_update_login
		)
		VALUES
		(
			p_eam_wo_rec.wip_entity_id
		      ,	p_eam_wo_rec.organization_id
		      ,	p_eam_wo_rec.user_defined_status_id
		      ,	p_eam_wo_rec.pending_flag
		      ,	p_eam_wo_rec.material_shortage_check_date
		      ,	p_eam_wo_rec.material_shortage_flag
		      , p_eam_wo_rec.workflow_type
		      ,	p_eam_wo_rec.warranty_claim_status
     		      ,	p_eam_wo_rec.cycle_id
		      ,	p_eam_wo_rec.seq_id
	              ,	p_eam_wo_rec.ds_scheduled_flag
      	              ,	p_eam_wo_rec.assignment_complete
		      , p_eam_wo_rec.warranty_active
                      , p_eam_wo_rec.pm_suggested_start_date
                      , p_eam_wo_rec.pm_suggested_end_date
                      , p_eam_wo_rec.pm_base_meter_reading
                      , p_eam_wo_rec.pm_base_meter
                      , nvl(p_eam_wo_rec.failure_code_required,'N')
                      , p_eam_wo_rec.request_id
		      ,	p_eam_wo_rec.program_id
		      ,	p_eam_wo_rec.program_application_id
		      ,	SYSDATE
		      ,	SYSDATE
		      ,	FND_GLOBAL.user_id
		      ,	SYSDATE
                      , FND_GLOBAL.user_id
                      , FND_GLOBAL.login_id
		);

		 EAM_ASSET_LOG_PVT.INSERT_ROW
			 (
				p_api_version		=> 1.0,
				p_event_date		=> sysdate,
				p_event_type		=> 'EAM_SYSTEM_EVENTS',
				p_event_id		=> 5,
				p_organization_id	=> p_eam_wo_rec.organization_id,
				p_instance_id		=> p_eam_wo_rec.maintenance_object_id,
				p_comments		=> null,
				p_reference		=> p_eam_wo_rec.wip_entity_name,
				p_ref_id		=> p_eam_wo_rec.wip_entity_id,
				p_operable_flag		=> null,
				p_reason_code		=> null,
				x_return_status		=> l_asset_ops_return_status,
				x_msg_count		=> l_asset_ops_msg_count,
				x_msg_data		=> l_asset_ops_msg_data
			 );


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Creating new Work Order') ; END IF;
                x_return_status := FND_API.G_RET_STS_SUCCESS;


        EXCEPTION
            WHEN OTHERS THEN
                        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||' :Inserting Record ' || SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
                        );

                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Insert_Row;

        /********************************************************************
        * Procedure     : Update_Row
        * Parameters IN : Work Order column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update into the
        *                 wip_discrete_jobs table.
        *********************************************************************/

        PROCEDURE Update_Row
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Updating EAM WO '|| p_eam_wo_rec.wip_entity_name); END IF;

-- bug no 3444091
	if p_eam_wo_rec.scheduled_start_date > p_eam_wo_rec.scheduled_completion_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_WORKORDER_DT_ERR');
                return;
	end if;


                UPDATE WIP_DISCRETE_JOBS
                   SET   description                  = p_eam_wo_rec.description
		         ,rebuild_serial_number      = p_eam_wo_rec.rebuild_serial_number      -- agaurav - Added the rebuild_serial_number column so that updation of serial number can happen
			 ,rebuild_item_id                  = p_eam_wo_rec.rebuild_item_id
			 ,asset_number                   =  p_eam_wo_rec.asset_number
			 , asset_group_id                = p_eam_wo_rec.asset_group_id
                       , class_code                   = p_eam_wo_rec.class_code
                       , primary_item_id              = p_eam_wo_rec.asset_activity_id
                       , activity_type                = p_eam_wo_rec.activity_type
                       , activity_cause               = p_eam_wo_rec.activity_cause
                       , activity_source              = p_eam_wo_rec.activity_source
--                       , status_type                  = p_eam_wo_rec.status_type  Status will be updated through status change api
                       , work_order_type              = p_eam_wo_rec.work_order_type
                       , start_quantity               = p_eam_wo_rec.job_quantity
                       , date_released                = p_eam_wo_rec.date_released
                       , owning_department            = p_eam_wo_rec.owning_department
                       , priority                     = p_eam_wo_rec.priority
                       , requested_start_date         = p_eam_wo_rec.requested_start_date
                       , due_date                     = p_eam_wo_rec.due_date
                       , shutdown_type                = p_eam_wo_rec.shutdown_type
                       , firm_planned_flag            = p_eam_wo_rec.firm_planned_flag
                       , notification_required        = p_eam_wo_rec.notification_required
                       , tagout_required              = p_eam_wo_rec.tagout_required
                       , plan_maintenance             = p_eam_wo_rec.plan_maintenance
                       , project_id                   = p_eam_wo_rec.project_id
                       , task_id                      = p_eam_wo_rec.task_id
		       , maintenance_object_id        = p_eam_wo_rec.maintenance_object_id   --added these 3 fields so that maintenance object id is updateable
       		       , maintenance_object_type      = p_eam_wo_rec.maintenance_object_type
       		       , maintenance_object_source    = p_eam_wo_rec.maintenance_object_source
		       , parent_wip_entity_id      = p_eam_wo_rec.parent_wip_entity_id           /* Added the column so that parent_wip_entity_id is updateable */
                       --, project_costed               = p_eam_wo_rec.project_costed
                       , end_item_unit_number         = p_eam_wo_rec.end_item_unit_number
                       , schedule_group_id            = p_eam_wo_rec.schedule_group_id
                       , bom_revision_date            = p_eam_wo_rec.bom_revision_date
                       , routing_revision_date        = p_eam_wo_rec.routing_revision_date
                       , alternate_routing_designator = p_eam_wo_rec.alternate_routing_designator
                       , alternate_bom_designator     = p_eam_wo_rec.alternate_bom_designator
                       , routing_revision             = p_eam_wo_rec.routing_revision
                       , bom_revision                 = p_eam_wo_rec.bom_revision
                       , manual_rebuild_flag          = p_eam_wo_rec.manual_rebuild_flag
                       , material_account             = p_eam_wo_rec.material_account
                       , material_overhead_account    = p_eam_wo_rec.material_overhead_account
                       , resource_account             = p_eam_wo_rec.resource_account
                       , outside_processing_account   = p_eam_wo_rec.outside_processing_account
                       , material_variance_account    = p_eam_wo_rec.material_variance_account
                       , resource_variance_account    = p_eam_wo_rec.resource_variance_account
                       , outside_proc_variance_account= p_eam_wo_rec.outside_proc_variance_account
                       , std_cost_adjustment_account  = p_eam_wo_rec.std_cost_adjustment_account
                       , overhead_account             = p_eam_wo_rec.overhead_account
                       , overhead_variance_account    = p_eam_wo_rec.overhead_variance_account
                       , scheduled_start_date         = p_eam_wo_rec.scheduled_start_date
                       , scheduled_completion_date    = p_eam_wo_rec.scheduled_completion_date
                       , common_bom_sequence_id       = p_eam_wo_rec.common_bom_sequence_id
                       , common_routing_sequence_id   = p_eam_wo_rec.common_routing_sequence_id
                       , attribute_category           = p_eam_wo_rec.attribute_category
                       , attribute1                   = p_eam_wo_rec.attribute1
                       , attribute2                   = p_eam_wo_rec.attribute2
                       , attribute3                   = p_eam_wo_rec.attribute3
                       , attribute4                   = p_eam_wo_rec.attribute4
                       , attribute5                   = p_eam_wo_rec.attribute5
                       , attribute6                   = p_eam_wo_rec.attribute6
                       , attribute7                   = p_eam_wo_rec.attribute7
                       , attribute8                   = p_eam_wo_rec.attribute8
                       , attribute9                   = p_eam_wo_rec.attribute9
                       , attribute10                  = p_eam_wo_rec.attribute10
                       , attribute11                  = p_eam_wo_rec.attribute11
                       , attribute12                  = p_eam_wo_rec.attribute12
                       , attribute13                  = p_eam_wo_rec.attribute13
                       , attribute14                  = p_eam_wo_rec.attribute14
                       , attribute15                  = p_eam_wo_rec.attribute15
                       , material_issue_by_mo         = p_eam_wo_rec.material_issue_by_mo
                       , issue_zero_cost_flag         = p_eam_wo_rec.issue_zero_cost_flag
                       , source_line_id               = p_eam_wo_rec.source_line_id
                       , source_code                  = p_eam_wo_rec.source_code
                       , last_update_date             = SYSDATE
                       , last_updated_by              = FND_GLOBAL.user_id
                       , last_update_login            = FND_GLOBAL.login_id
                       , request_id                   = p_eam_wo_rec.request_id
                       , program_application_id       = p_eam_wo_rec.program_application_id
                       , program_id                   = p_eam_wo_rec.program_id
                       , program_update_date          = SYSDATE
                WHERE  wip_entity_id      = p_eam_wo_rec.wip_entity_id
                  AND  organization_id    = p_eam_wo_rec.organization_id;


                UPDATE WIP_ENTITIES
                   SET wip_entity_name                =   p_eam_wo_rec.wip_entity_name
                     , description                    = p_eam_wo_rec.description
                     , primary_item_id                = p_eam_wo_rec.asset_activity_id
                     , last_update_date               = SYSDATE
                     , last_updated_by                = FND_GLOBAL.user_id
                     , last_update_login              = FND_GLOBAL.login_id
                     , request_id                     = p_eam_wo_rec.request_id
                     , program_application_id         = p_eam_wo_rec.program_application_id
                     , program_id                     = p_eam_wo_rec.program_id
                     , program_update_date            = SYSDATE
                WHERE  wip_entity_id      = p_eam_wo_rec.wip_entity_id
                  AND  organization_id    = p_eam_wo_rec.organization_id;


		  UPDATE EAM_WORK_ORDER_DETAILS
		     SET wip_entity_id			=  p_eam_wo_rec.wip_entity_id
		       , organization_id		=  p_eam_wo_rec.organization_id
		       , user_defined_status_id		=  p_eam_wo_rec.user_defined_status_id
		       , pending_flag			=  p_eam_wo_rec.pending_flag
		       , material_shortage_check_date	=  p_eam_wo_rec.material_shortage_check_date
	               , material_shortage_flag		=  p_eam_wo_rec.material_shortage_flag
		       , workflow_type			=  p_eam_wo_rec.workflow_type
	               , warranty_claim_status		=  p_eam_wo_rec.warranty_claim_status
	               , cycle_id			=  p_eam_wo_rec.cycle_id
		       , seq_id				=  p_eam_wo_rec.seq_id
		       , ds_scheduled_flag		=  p_eam_wo_rec.ds_scheduled_flag
		       , assignment_complete		=  p_eam_wo_rec.assignment_complete
		       , warranty_active		=  p_eam_wo_rec.warranty_active
                       , pm_suggested_start_date        =  p_eam_wo_rec.pm_suggested_start_date
                       , pm_suggested_end_date          =  p_eam_wo_rec.pm_suggested_end_date
                       , pm_base_meter_reading          =  p_eam_wo_rec.pm_base_meter_reading
                       , pm_base_meter                  =  p_eam_wo_rec.pm_base_meter
		       , failure_code_required		=  nvl(p_eam_wo_rec.failure_code_required,'N')
		       , request_id			=  p_eam_wo_rec.request_id
		       , program_id			=  p_eam_wo_rec.program_id
		       , program_application_id		=  p_eam_wo_rec.program_application_id
		       , program_update_date		=  SYSDATE
		       , last_update_date		=  SYSDATE
		       , last_updated_by		=  FND_GLOBAL.user_id
		       , last_update_login		=  FND_GLOBAL.login_id
		WHERE  wip_entity_id      = p_eam_wo_rec.wip_entity_id
                  AND  organization_id    = p_eam_wo_rec.organization_id;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Update_Row;

        /*********************************************************************
        * Procedure     : Perform_Writes
        * Parameters IN : Work Order Column Record
        * Parameters OUT NOCOPY: Messgae Token Table
        *                 Return Status
        * Purpose       : This is the only procedure that the user will have
        *                 access to when he/she needs to perform any kind of
        *                 writes to the wip_discrete_jobs and wip_entities.
        *********************************************************************/

        PROCEDURE Perform_Writes
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
        )
        IS
                l_Mesg_Token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN

                IF p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                        Insert_Row
                        (  p_eam_wo_rec         => p_eam_wo_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                ELSIF p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                THEN
                        Update_Row
                        (  p_eam_wo_rec         => p_eam_wo_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

                END IF;

                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Perform_Writes;

END EAM_WO_UTILITY_PVT;

/
