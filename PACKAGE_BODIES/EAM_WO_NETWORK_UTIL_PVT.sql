--------------------------------------------------------
--  DDL for Package Body EAM_WO_NETWORK_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_NETWORK_UTIL_PVT" AS
/* $Header: EAMVWNUB.pls 120.2.12010000.3 2009/04/15 07:09:04 vboddapa ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWNUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_NETWORK_UTIL_PVT
--
--  NOTES
--
--  HISTORY
--
--  11-SEP-2003    Basanth Roy     Initial Creation
***************************************************************************/



G_Pkg_Name      VARCHAR2(30) := 'EAM_WO_NETWORK_UTIL_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_dummy         NUMBER;

    PROCEDURE Move_WO
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,
        p_offset_days                   IN      NUMBER := 1,  -- 1 Day Default
        p_offset_direction              IN      NUMBER  := 1, -- Forward
        p_start_date                    IN      DATE    := null,
        p_completion_date               IN      DATE    := null,
        p_schedule_method               IN      NUMBER  := 1, -- Forward Scheduling

	p_ignore_firm_flag		IN	VARCHAR2 := 'N', -- Move firm work orders

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
       )

    IS
     l_api_name			CONSTANT VARCHAR2(30)	:= 'Move_WO';
     l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_stmt_num                  NUMBER;
    l_work_object_id            NUMBER;
    l_work_object_type_id       NUMBER;
    l_offset_days               NUMBER;
    l_offset_direction          NUMBER;
    l_start_date                DATE;
    l_completion_date           DATE;
    l_wo_start_date             DATE;
    l_wo_completion_date        DATE;
    l_schedule_method           NUMBER;
    l_child_index		NUMBER;
    l_operation_index		NUMBER;
    l_resource_index		NUMBER;
    l_res_inst_index		NUMBER;
    l_res_usage_index		NUMBER;
    l_material_index		NUMBER;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);
    l_error_message             VARCHAR2(1000);

    l_eam_wo_rec                eam_process_wo_pub.eam_wo_rec_type;
    l_eam_op_rec		EAM_PROCESS_WO_PUB.eam_op_rec_type;
    l_eam_res_rec		EAM_PROCESS_WO_PUB.eam_res_rec_type;
    l_eam_res_inst_rec		EAM_PROCESS_WO_PUB.eam_res_inst_rec_type;
    l_eam_res_usage_rec		EAM_PROCESS_WO_PUB.eam_res_usage_rec_type;
    l_eam_mat_req_rec		EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;

    l_eam_wo_relations_tbl 	EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
    l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
    l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl    	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl       	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl      	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_di_tbl         	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_tbl           EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
    l_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;

    l_out_eam_wo_relations_tbl  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
    l_out_eam_wo_tbl            EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
    l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_di_tbl         	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_tbl           EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
    l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;

    l_eam_counter_prop_tbl        EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_cur_firm_flag		NUMBER;
    l_cur_non_firm_flag		NUMBER;

     CURSOR constrained_children_cur (l_obj_id NUMBER, l_obj_type_id NUMBER,l_cur_non_firm_flag NUMBER,l_cur_firm_flag NUMBER) IS
                        (   SELECT  WSR1.CHILD_OBJECT_ID CHILD_OBJECT_ID,
                                WSR1.CHILD_OBJECT_TYPE_ID CHILD_OBJECT_TYPE_ID,
				WSR1.PARENT_OBJECT_ID PARENT_OBJECT_ID,
				WDJ.ORGANIZATION_ID,
				WDJ.SCHEDULED_START_DATE,
				WDJ.SCHEDULED_COMPLETION_DATE,
				WDJ.requested_start_date,
		                WDJ.due_date,
                                WSR1.WO_LEVEL ,
				WDJ.FIRM_PLANNED_FLAG
                        FROM    (SELECT WSR.CHILD_OBJECT_ID,
                                 WSR.CHILD_OBJECT_TYPE_ID,
				 WSR.PARENT_OBJECT_ID,
                                 LEVEL WO_LEVEL
				 FROM WIP_SCHED_RELATIONSHIPS WSR
				 WHERE  WSR.RELATIONSHIP_TYPE      = 1
                                 CONNECT BY  prior WSR.CHILD_OBJECT_ID  =  WSR.PARENT_OBJECT_ID
				 START WITH  WSR.PARENT_OBJECT_ID       = l_obj_id) WSR1,
				WIP_DISCRETE_JOBS WDJ
                        WHERE   l_obj_type_id               = 1
			AND	WSR1.CHILD_OBJECT_ID 	    = WDJ.WIP_ENTITY_ID
                        AND    ( WDJ.firm_planned_flag      = l_cur_non_firm_flag OR WDJ.firm_planned_flag  = l_cur_firm_flag)
                        AND     WDJ.status_type NOT IN (7,4,5,12,14)
 			)
                        UNION
			(   SELECT WDJ.WIP_ENTITY_ID CHILD_OBJECT_ID,
				l_obj_type_id "CHILD_OBJECT_TYPE_ID",
				WDJ.PARENT_WIP_ENTITY_ID PARENT_OBJECT_ID,
				WDJ.ORGANIZATION_ID,
				WDJ.SCHEDULED_START_DATE,
				WDJ.SCHEDULED_COMPLETION_DATE,
				WDJ.requested_start_date,
		                WDJ.due_date,
				0 WO_LEVEL,
				WDJ.FIRM_PLANNED_FLAG
				FROM	WIP_DISCRETE_JOBS WDJ
				WHERE	WDJ.WIP_ENTITY_ID = l_obj_id
				AND	l_obj_type_id = 1
                                AND     WDJ.status_type NOT IN (7,4,5,12,14)
			) ORDER BY 8 DESC ;


    CURSOR workorder_operations_cur (l_obj_id NUMBER, l_obj_type_id NUMBER) IS
			select  WO.FIRST_UNIT_START_DATE START_DATE,
				WO.FIRST_UNIT_COMPLETION_DATE COMPLETION_DATE,
				WO.OPERATION_SEQ_NUM,WO.DESCRIPTION,WO.LONG_DESCRIPTION
			FROM    WIP_OPERATIONS WO
    	                WHERE   WO.WIP_ENTITY_ID             = l_obj_id
        	        AND     l_obj_type_id                = 1;

   CURSOR workorder_material_cur (l_obj_id NUMBER, l_obj_type_id NUMBER) IS
			select  WRO.INVENTORY_ITEM_ID,OPERATION_SEQ_NUM,DATE_REQUIRED,STOCK_ENABLED_FLAG
			FROM    WIP_REQUIREMENT_OPERATIONS  WRO,
				MTL_SYSTEM_ITEMS_B MSI
    	                WHERE   WRO.WIP_ENTITY_ID             = l_obj_id
			AND     MSI.INVENTORY_ITEM_ID         = WRO.INVENTORY_ITEM_ID
			AND     MSI.ORGANIZATION_ID           = WRO.ORGANIZATION_ID
        	        AND     l_obj_type_id                 = 1;

    CURSOR workorder_resources_cur (l_obj_id NUMBER, l_obj_type_id NUMBER) IS
			select  WOR.START_DATE, WOR.COMPLETION_DATE,
				WOR.OPERATION_SEQ_NUM,
				WOR.RESOURCE_SEQ_NUM
			FROM    WIP_OPERATION_RESOURCES WOR
    	                WHERE   WOR.WIP_ENTITY_ID             = l_obj_id
        	        AND     l_obj_type_id                 = 1;

    CURSOR workorder_res_inst_cur (l_obj_id NUMBER, l_obj_type_id NUMBER) IS
			select  WORI.START_DATE, WORI.COMPLETION_DATE,
				wORI.OPERATION_SEQ_NUM,
				WORI.RESOURCE_SEQ_NUM,
				WORI.INSTANCE_ID,
				WORI.SERIAL_NUMBER
			FROM    WIP_OP_RESOURCE_INSTANCES WORI
    	                WHERE   WORI.WIP_ENTITY_ID             = l_obj_id
        	        AND     l_obj_type_id                  = 1;

    CURSOR workorder_res_usage_cur (l_obj_id NUMBER, l_obj_type_id NUMBER) IS
			SELECT	woru.start_date,
				woru.completion_date,
				woru.operation_seq_num,
				woru.resource_seq_num,
				woru.instance_id,
				woru.serial_number,
				woru.assigned_units
			  FROM	wip_operation_resource_usage woru, wip_discrete_jobs wdj
			 WHERE	woru.wip_entity_id            = l_obj_id
			   AND	wdj.wip_entity_id              = l_obj_id
		    --     AND	wdj.firm_planned_flag       = l_cur_firm_flag
		           AND     l_obj_type_id			= 1;

			 l_output_dir  VARCHAR2(512);

   BEGIN


    /*******************************************************************
    * Procedure	: Move_WO
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY: Work Object ID, Work Object Type
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: This API moves a Work Order structure
    *********************************************************************/

	-- 3942544
	l_cur_non_firm_flag := 2;

	if p_ignore_firm_flag = 'Y' then
		l_cur_firm_flag :=1;
	else
		l_cur_firm_flag :=2;
	end if;

EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

	-- Standard Start of API savepoint
    SAVEPOINT	EAM_WO_NETWORK_UTIL_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
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
        x_msg_count     := 0;
	-- API body

    /* Initialize the local variables */
    l_stmt_num := 10;
    l_child_index           := 1;

    l_work_object_id        := p_work_object_id;
    l_work_object_type_id   := p_work_object_type_id;
    l_offset_days           := p_offset_days;
    l_offset_direction      := p_offset_direction;
    l_schedule_method       := p_schedule_method;
    l_return_status         := FND_API.G_RET_STS_SUCCESS;
    l_start_date            := p_start_date;
    l_completion_date       := p_completion_date;

    select scheduled_start_date, scheduled_completion_date
      into l_wo_start_date, l_wo_completion_date
      from wip_discrete_jobs where
      wip_entity_id = p_work_object_id;

     if l_offset_days is null then
      if l_start_date is not null then
	l_offset_days := ABS(l_start_date - l_wo_start_date);
	if l_start_date - l_wo_start_date > 0 then
		l_offset_direction :=1; -- Work Order is moved forward
	else
		l_offset_direction :=2; -- Work Order is moved backward
	end if;
      elsif l_completion_date is not null then
	l_offset_days := ABS(l_completion_date - l_wo_completion_date);
	if l_completion_date - l_wo_completion_date > 0 then
		l_offset_direction :=1; -- Work Order is moved forward
	else
		l_offset_direction :=2; -- Work Order is moved backward
	end if;
      end if;
    end if;


	IF (l_offset_direction <> 1) THEN  -- Move Backward
                l_offset_days       := l_offset_days * (-1);
        END IF;

    /* Process Work Order Bottom up */
	-- 3942544
	l_operation_index := 1;
	l_material_index := 1;
	l_resource_index := 1;
	l_res_inst_index := 1;
	l_res_usage_index := 1 ;
    FOR child IN constrained_children_cur (l_work_object_id, l_work_object_type_id,l_cur_non_firm_flag,l_cur_firm_flag)
    LOOP
	l_eam_wo_rec.batch_id 			:=	1;
	l_eam_wo_rec.header_id			:=	child.CHILD_OBJECT_ID;
 	l_eam_wo_rec.wip_entity_id  		:=	child.CHILD_OBJECT_ID;
	l_eam_wo_rec.parent_wip_entity_id       :=     child.PARENT_OBJECT_ID;
	l_eam_wo_rec.organization_id 		:= 	child.ORGANIZATION_ID;
	l_eam_wo_rec.scheduled_start_date	:=	child.SCHEDULED_START_DATE + l_offset_days;
	l_eam_wo_rec.scheduled_completion_date	:=	child.SCHEDULED_COMPLETION_DATE + l_offset_days;
	l_eam_wo_rec.validate_structure		:=	'Y'; -- added for bug# 3544860
	l_eam_wo_rec.transaction_type 		:= 	EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

    if p_schedule_method = 1 then -- forward sched
      l_eam_wo_rec.requested_start_date := child.scheduled_start_date + l_offset_days;
      l_eam_wo_rec.due_date := null;
    else -- backward sched
      l_eam_wo_rec.due_date := child.scheduled_completion_date + l_offset_days;
      l_eam_wo_rec.requested_start_date := null;
    end if;

	l_eam_wo_tbl(l_child_index) := l_eam_wo_rec;
	l_child_index := l_child_index + 1;

	FOR operation IN workorder_operations_cur (child.CHILD_OBJECT_ID, child.CHILD_OBJECT_TYPE_ID)
    	LOOP
		l_eam_op_rec.batch_id 			:=	1;
		l_eam_op_rec.header_id			:=	child.CHILD_OBJECT_ID;
	 	l_eam_op_rec.wip_entity_id  		:=	child.CHILD_OBJECT_ID;
		l_eam_op_rec.organization_id 		:= 	child.ORGANIZATION_ID;
		l_eam_op_rec.operation_seq_num		:=	operation.operation_seq_num;
		l_eam_op_rec.start_date			:=	operation.START_DATE + l_offset_days;
		l_eam_op_rec.completion_date		:=	operation.COMPLETION_DATE + l_offset_days;
		l_eam_op_rec.transaction_type 		:= 	EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
		l_eam_op_rec.description                      :=         operation.description;
                l_eam_op_rec.long_description                      :=         operation.long_description;

		l_eam_op_tbl(l_operation_index) := l_eam_op_rec;
		l_operation_index := l_operation_index + 1;
	END LOOP;

	-- 3942544
	-- Do not move non stockable items

/*	FOR material IN workorder_material_cur (child.CHILD_OBJECT_ID, child.CHILD_OBJECT_TYPE_ID)
	LOOP
		IF material.STOCK_ENABLED_FLAG = 'Y' THEN
			l_eam_mat_req_rec.batch_id 			:=	1;
			l_eam_mat_req_rec.header_id			:=	child.CHILD_OBJECT_ID;
			l_eam_mat_req_rec.wip_entity_id  		:=	child.CHILD_OBJECT_ID;
			l_eam_mat_req_rec.organization_id 		:= 	child.ORGANIZATION_ID;
			l_eam_mat_req_rec.inventory_item_id		:=	material.INVENTORY_ITEM_ID;
			l_eam_mat_req_rec.operation_seq_num		:=	material.OPERATION_SEQ_NUM;
			l_eam_mat_req_rec.date_required			:=	material.DATE_REQUIRED + l_offset_days;
			l_eam_mat_req_rec.transaction_type 		:= 	EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

			l_eam_mat_req_tbl(l_material_index) := l_eam_mat_req_rec;
			l_material_index := l_material_index + 1;
		END IF;
	END LOOP;
*/

	FOR res IN workorder_resources_cur (child.CHILD_OBJECT_ID, child.CHILD_OBJECT_TYPE_ID)
    	LOOP
		l_eam_res_rec.batch_id 			:=	1;
		l_eam_res_rec.header_id			:=	child.CHILD_OBJECT_ID;
	 	l_eam_res_rec.wip_entity_id  		:=	child.CHILD_OBJECT_ID;
		l_eam_res_rec.organization_id 		:= 	child.ORGANIZATION_ID;
		l_eam_res_rec.operation_seq_num		:=	res.operation_seq_num;
		l_eam_res_rec.resource_seq_num		:=	res.resource_seq_num;
		l_eam_res_rec.start_date		:=	res.START_DATE + l_offset_days;
		l_eam_res_rec.completion_date		:=	res.COMPLETION_DATE + l_offset_days;
		l_eam_res_rec.transaction_type 		:= 	EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

		l_eam_res_tbl(l_resource_index) := l_eam_res_rec;
		l_resource_index := l_resource_index + 1;
	END LOOP;

	FOR res_inst IN workorder_res_inst_cur (child.CHILD_OBJECT_ID, child.CHILD_OBJECT_TYPE_ID)
    	LOOP
		l_eam_res_inst_rec.batch_id 		:=	1;
		l_eam_res_inst_rec.header_id		:=	child.CHILD_OBJECT_ID;
	 	l_eam_res_inst_rec.wip_entity_id  	:=	child.CHILD_OBJECT_ID;
		l_eam_res_inst_rec.organization_id 	:= 	child.ORGANIZATION_ID;
		l_eam_res_inst_rec.operation_seq_num	:=	res_inst.operation_seq_num;
		l_eam_res_inst_rec.resource_seq_num	:=	res_inst.resource_seq_num;
		l_eam_res_inst_rec.instance_id		:=	res_inst.instance_id;
		l_eam_res_inst_rec.serial_number	:=	res_inst.serial_number;
		l_eam_res_inst_rec.start_date		:=	res_inst.START_DATE + l_offset_days;
		l_eam_res_inst_rec.completion_date	:=	res_inst.COMPLETION_DATE + l_offset_days;
		l_eam_res_inst_rec.transaction_type 	:= 	EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

		l_eam_res_inst_tbl(l_res_inst_index) := l_eam_res_inst_rec;
		l_res_inst_index := l_res_inst_index + 1;

	END LOOP;

	FOR res_usage IN workorder_res_usage_cur (child.CHILD_OBJECT_ID, child.CHILD_OBJECT_TYPE_ID)
    	LOOP
		l_eam_res_usage_rec.batch_id 			:=	1;
		l_eam_res_usage_rec.header_id			:=	child.CHILD_OBJECT_ID;
	 	l_eam_res_usage_rec.wip_entity_id		:=	child.CHILD_OBJECT_ID;
		l_eam_res_usage_rec.organization_id 	:= 	child.ORGANIZATION_ID;
		l_eam_res_usage_rec.operation_seq_num	:=	res_usage.operation_seq_num;
		l_eam_res_usage_rec.resource_seq_num	:=	res_usage.resource_seq_num;
		l_eam_res_usage_rec.instance_id		:=	res_usage.instance_id;
		l_eam_res_usage_rec.serial_number		:=	res_usage.serial_number;
		l_eam_res_usage_rec.assigned_units		:=	res_usage.assigned_units;

		l_eam_res_usage_rec.old_start_date		:=	res_usage.START_DATE ;
		l_eam_res_usage_rec.old_completion_date	:=	res_usage.COMPLETION_DATE ;

		l_eam_res_usage_rec.start_date		:=	res_usage.START_DATE + l_offset_days;
		l_eam_res_usage_rec.completion_date	:=	res_usage.COMPLETION_DATE + l_offset_days;
		l_eam_res_usage_rec.transaction_type 	:= 	EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

		l_eam_res_usage_tbl(l_res_usage_index) := l_eam_res_usage_rec;
		l_res_usage_index := l_res_usage_index + 1;
	END LOOP;

    END LOOP;

  		l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;

    /* Call Work Order API to perform the operations */


	eam_process_wo_pub.PROCESS_MASTER_CHILD_WO
         ( p_bo_identifier           => 'EAM'
         , p_init_msg_list           => TRUE
         , p_api_version_number      => 1.0
         , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
         , p_eam_wo_tbl              => l_eam_wo_tbl
         , p_eam_op_tbl              => l_eam_op_tbl
         , p_eam_op_network_tbl      => l_eam_op_network_tbl
         , p_eam_res_tbl             => l_eam_res_tbl
         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
         , p_eam_direct_items_tbl    => l_eam_di_tbl
	 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
	 , p_eam_wo_comp_tbl         => l_eam_wo_comp_tbl
	 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
	 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
	 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
	 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
	 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
	 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
	 , p_eam_request_tbl         => l_eam_request_tbl
	 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
         , x_eam_wo_tbl              => l_out_eam_wo_tbl
         , x_eam_op_tbl              => l_out_eam_op_tbl
         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
         , x_eam_res_tbl             => l_out_eam_res_tbl
         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
	 , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
	 , x_eam_wo_comp_tbl         => l_out_eam_wo_comp_tbl
	 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
	 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
	 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
	 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
	 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
	 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
	 , x_eam_request_tbl         => l_out_eam_request_tbl
	 , p_commit                  => 'N'
      --   , x_error_msg_tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.error_tbl_type
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_debug_filename          => 'movewo.log'
         , p_output_dir              => l_output_dir
    	 , p_debug_file_mode	     => 'W'
         );



--dbms_output.put_line('PARENT MOVE RETURN VAL = '||l_return_status);
--dbms_output.put_line( '######');

        x_msg_count     := l_msg_count;

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;

        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETURN;

        END IF;

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(
            p_count         	=>      x_msg_count,
			p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);


    END move_WO;



    /*******************************************************************
    * Procedure	: Schedule_for_Move
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY: Work Object ID, Work Object Type
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: This API schedules the work order after move
    *********************************************************************/

    PROCEDURE Schedule_for_Move
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,
        p_offset_days                   IN      NUMBER := 1, -- 1 Day Default
        p_offset_direction              IN      NUMBER  := 1, -- Ahead
        p_schedule_method               IN      NUMBER  := 1, -- Forward Scheduling

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        )

    IS
	l_api_name			      CONSTANT VARCHAR2(30)	:= 'Schedule_for_Move';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_stmt_num                  NUMBER;
    l_work_object_id            NUMBER;
    l_work_object_type_id       NUMBER;
    l_offset_days               NUMBER;
    l_offset_direction          NUMBER;
    l_schedule_method           NUMBER;

    l_job_status                   NUMBER;
    l_organization_id           NUMBER;
    l_scheduled_start_date      DATE;
    l_scheduled_completion_date DATE;
    l_temp_start_date           DATE;
    l_temp_completion_date      DATE;


    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);
    l_error_message             VARCHAR2(1000);


   BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	EAM_WO_NETWORK_UTIL_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
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

    /* Initialize the local variables */
    l_stmt_num := 10;
    l_work_object_id        := p_work_object_id;
    l_work_object_type_id   := p_work_object_type_id;
    l_offset_days           := p_offset_days;
    l_offset_direction      := p_offset_direction;
    l_schedule_method       := p_schedule_method;


    l_job_status         := NULL;
    l_organization_id   := NULL;
    l_scheduled_start_date      := NULL;
    l_scheduled_completion_date := NULL;

    BEGIN
        SELECT  WDJ.STATUS_TYPE,
                WDJ.ORGANIZATION_ID,
                WDJ.SCHEDULED_START_DATE,
                WDJ.SCHEDULED_COMPLETION_DATE
        INTO    l_job_status,
                l_organization_id,
                l_scheduled_start_date,
                l_scheduled_completion_date
        FROM    WIP_DISCRETE_JOBS WDJ
        WHERE   WDJ.WIP_ENTITY_ID           = l_work_object_id
        AND     l_work_object_type_id       = 1;
    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

            RETURN;
    END;

--    dbms_output.put_line('JOB = '|| l_work_object_id);
--    dbms_output.put_line('BEFORE  START =' || to_char(l_scheduled_start_date, 'DD-MON-YYYY HH24:MM:SS'));
--    dbms_output.put_line('BEFORE  END =' || to_char(l_scheduled_completion_date, 'DD-MON-YYYY HH24:MM:SS'));
--  dbms_output.put_line('OFFSET DAYS = '||l_offset_days);


       IF (l_offset_direction <> 1) THEN  -- Move Backward

                l_offset_days       := l_offset_days * (-1);
                l_offset_days       := l_offset_days * (-1);
        END IF;

        BEGIN

                /* Update the job start and Enc Dates */
                UPDATE  WIP_DISCRETE_JOBS WDJ
                SET     WDJ.SCHEDULED_START_DATE    = WDJ.SCHEDULED_START_DATE + l_offset_days,
                        WDJ.SCHEDULED_COMPLETION_DATE    = WDJ.SCHEDULED_COMPLETION_DATE + l_offset_days
                WHERE   WDJ.WIP_ENTITY_ID           = l_work_object_id
                AND     l_work_object_type_id       = 1;



                UPDATE  WIP_OPERATIONS WO
                SET     WO.FIRST_UNIT_START_DATE        = WO.FIRST_UNIT_START_DATE + l_offset_days,
                        WO.FIRST_UNIT_COMPLETION_DATE   = WO.FIRST_UNIT_COMPLETION_DATE + l_offset_days,
                        WO.LAST_UNIT_START_DATE         = WO.LAST_UNIT_START_DATE + l_offset_days,
                        WO.LAST_UNIT_COMPLETION_DATE    = WO.LAST_UNIT_COMPLETION_DATE + l_offset_days
                WHERE   WO.WIP_ENTITY_ID                = l_work_object_id
                AND     l_work_object_type_id           = 1;


                UPDATE  WIP_OPERATION_RESOURCES WOR
                SET     WOR.START_DATE                  = WOR.START_DATE + l_offset_days,
                        WOR.COMPLETION_DATE             = WOR.COMPLETION_DATE + l_offset_days
                WHERE   WOR.WIP_ENTITY_ID               = l_work_object_id
                AND     l_work_object_type_id           = 1;


                UPDATE  WIP_OPERATION_RESOURCE_USAGE WORU
                SET     WORU.START_DATE                  = WORU.START_DATE + l_offset_days,
                        WORU.COMPLETION_DATE             = WORU.COMPLETION_DATE + l_offset_days
                WHERE   WORU.WIP_ENTITY_ID               = l_work_object_id
                AND     l_work_object_type_id            = 1;


                UPDATE  WIP_OP_RESOURCE_INSTANCES WORI
                SET     WORI.START_DATE                  = WORI.START_DATE + l_offset_days,
                        WORI.COMPLETION_DATE             = WORI.COMPLETION_DATE + l_offset_days
                WHERE   WORI.WIP_ENTITY_ID               = l_work_object_id
                AND     l_work_object_type_id            = 1;


            /* Reset it Back for next iteration */
            IF (l_offset_direction <> 1) THEN  -- Move Backward
                l_offset_days       := l_offset_days * (-1);
                l_offset_days       := l_offset_days * (-1);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN

           		FND_MSG_PUB.Add_Exc_Msg
   	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);

        END;



        IF (l_job_status NOT IN (3,4,5,6,7,12,14,15)) THEN -- Job in Planning Stage
--dbms_output.put_line('Inside non-execution WO');

            IF (l_offset_direction = 1) THEN -- Move Forward

                IF (l_schedule_method = 1) THEN -- Forward Scheduling

                    l_temp_start_date := l_scheduled_start_date + l_offset_days;
                    l_temp_completion_date := NULL;

   -- dbms_output.put_line('OLD START = '||to_char(l_scheduled_start_date,'DD-MON-YYYY HH24:MM:SS'));
   --  dbms_output.put_line('NEW START = '||to_char(l_temp_start_date,'DD-MON-YYYY HH24:MM:SS'));

                      EAM_WO_SCHEDULE_PVT.SCHEDULE_WO
                        (
                        p_organization_id       => l_organization_id,
                        p_wip_entity_id         => l_work_object_id,
                        p_start_date            => l_temp_start_date,
                        p_completion_date       => l_temp_completion_date,
                        x_error_message         => l_error_message,
                        x_return_status         => l_return_status
                        );

    --    dbms_output.put_line('INFINITE SCHEDULER RETURN VAL = '||l_return_status);
    --    dbms_output.put_line('INFINITE SCHEDULER RETURN MSG = '||l_error_message);

                ELSE -- Backward Scheduling
                    l_temp_start_date      := NULL;
                    l_temp_completion_date := l_scheduled_completion_date + l_offset_days;

                    EAM_WO_SCHEDULE_PVT.SCHEDULE_WO
                        (
                        p_organization_id       => l_organization_id,
                        p_wip_entity_id         => l_work_object_id,
                        p_start_date            => l_temp_start_date,
                        p_completion_date       => l_temp_completion_date,
                        x_error_message         => l_error_message,
                        x_return_status         => l_return_status
                        );

                END IF;

            ELSE -- Move Backwards


                IF (l_schedule_method = 1) THEN -- Forward Scheduling

                    l_temp_start_date := l_scheduled_start_date - l_offset_days;
                    l_temp_completion_date := NULL;

                    EAM_WO_SCHEDULE_PVT.SCHEDULE_WO
                        (
                        p_organization_id       => l_organization_id,
                        p_wip_entity_id         => l_work_object_id,
                        p_start_date            => l_temp_start_date,
                        p_completion_date       => l_temp_completion_date,
                        x_error_message         => l_error_message,
                        x_return_status         => l_return_status
                        );
                ELSE -- Backward Scheduling
                    l_temp_start_date      := NULL;
                    l_temp_completion_date := l_scheduled_completion_date - l_offset_days;

                    EAM_WO_SCHEDULE_PVT.SCHEDULE_WO
                        (
                        p_organization_id       => l_organization_id,
                        p_wip_entity_id         => l_work_object_id,
                        p_start_date            => l_temp_start_date,
                        p_completion_date       => l_temp_completion_date,
                        x_error_message         => l_error_message,
                        x_return_status         => l_return_status
                        );

                END IF; -- Schedule Method

            END IF; -- OffSet Direction

        /* Uncomment it later
            IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;

            ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            END IF;
        */

        END IF; -- Job Status

/* Test portion  -- delete later */
    BEGIN
        SELECT  WDJ.STATUS_TYPE,
                WDJ.ORGANIZATION_ID,
                WDJ.SCHEDULED_START_DATE,
                WDJ.SCHEDULED_COMPLETION_DATE
        INTO    l_job_status,
                l_organization_id,
                l_scheduled_start_date,
                l_scheduled_completion_date
        FROM    WIP_DISCRETE_JOBS WDJ
        WHERE   WDJ.WIP_ENTITY_ID           = l_work_object_id
        AND     l_work_object_type_id       = 1;
    EXCEPTION
        WHEN OTHERS THEN

            x_return_status := FND_API.G_RET_STS_ERROR;
--            RETURN;
    END;


 --   dbms_output.put_line('AFTER  START =' || to_char(l_scheduled_start_date, 'DD-MON-YYYY HH24:MM:SS'));
 --   dbms_output.put_line('AFTER  END =' || to_char(l_scheduled_completion_date, 'DD-MON-YYYY HH24:MM:SS'));


	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(
            p_count         	=>      x_msg_count,
			p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);


    END Schedule_for_Move;





END EAM_WO_NETWORK_UTIL_PVT;

/
