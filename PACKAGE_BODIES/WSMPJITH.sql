--------------------------------------------------------
--  DDL for Package Body WSMPJITH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPJITH" AS
/* $Header: WSMJITHB.pls 115.6 2001/11/15 15:14:03 pkm ship      $ */

PROCEDURE copy_to_wjsi(		p_header_id	IN NUMBER,
				p_wjsi_group_id	OUT NUMBER,
				x_err_code	OUT NUMBER,
				x_err_msg	OUT VARCHAR2	) IS

l_group_id	NUMBER;
l_wip_entity_id	NUMBER;
l_stmt_num	NUMBER;


CURSOR COPY_WLJI_CURSOR IS

	SELECT	last_update_date,
  		last_updated_by,
  		creation_date,
  		created_by,
  		last_update_login,
  		request_id,
  		program_id,
  		program_application_id,
  		program_update_date,
		-- group_id, Removed as new group id is used
  		source_code,
  		source_line_id,
  		-- process_type,
  		organization_id,
  		load_type,
  		status_type,
  		-- old_status_type,
  		last_unit_completion_date,
  		-- old_completion_date,
  		processing_work_days,
  		daily_production_rate,
  		line_id,
  		primary_item_id,
  		bom_reference_id,
  		routing_reference_id,
  		bom_revision_date,
  		routing_revision_date,
  		wip_supply_type,
  		class_code,
  		lot_number,
  		-- lot_control_code,
  		job_name,
  		description,
  		firm_planned_flag,
  		alternate_routing_designator,
  		alternate_bom_designator,
  		demand_class,
  		start_quantity,
  		-- old_start_quantity,
  		wip_entity_id,
  		repetitive_schedule_id,
  		-- error,
  		-- parent_group_id,
  		attribute_category,
  		attribute1,
  		attribute2,
  		attribute3,
  		attribute4,
  		attribute5,
  		attribute6,
  		attribute7,
  		attribute8,
  		attribute9,
  		attribute10,
  		attribute11,
  		attribute12,
  		attribute13,
  		attribute14,
  		attribute15,
  		-- interface_id, removed as null value is used in wjsi
  		last_updated_by_name,
  		created_by_name,
  		process_phase,
  		process_status,
  		organization_code,
  		first_unit_start_date,
  		first_unit_completion_date,
  		last_unit_start_date,
  		scheduling_method,
  		line_code,
  		-- primary_item_segments,
  		-- bom_reference_segments,
  		-- routing_reference_segments,
  		routing_revision,
  		bom_revision,
  		completion_subinventory,
  		completion_locator_id,
  		completion_locator_segments,
  		schedule_group_id,
  		schedule_group_name,
  		build_sequence,
  		project_id,
  		-- project_name,
  		task_id,
  		-- task_name,
  		net_quantity,
  		-- descriptive_flex_segments,
 		project_number,
  		task_number,
  		-- project_costed,
  		end_item_unit_number,
 		overcompletion_tolerance_type,
  		overcompletion_tolerance_value,
  		kanban_card_id,
  		priority,
  		due_date,
  		allow_explosion,
  		header_id,
  		delivery_id
	FROM 	wsm_lot_job_interface
	/*BD#LIIP*/
	/*
	WHERE	interface_id = 	p_interface_id ;
	*/
	/*ED#LIIP*/
	/*BA#LIIP*/
	WHERE	header_id = 	p_header_id ;
	/*EA#LIIP*/


	--begin bugfix 2050277

	l_bom_revision		varchar2(3);
	l_rtg_revision		varchar2(3);

	--end bugfix 2050277


BEGIN

l_stmt_num := 10;

	x_err_code:=0;
	x_err_msg := NULL;
	p_wjsi_group_id := 0;

l_stmt_num := 20;

	SELECT wip_job_schedule_interface_s.NEXTVAL
	INTO p_wjsi_group_id
	FROM dual;

l_stmt_num := 30;

	SELECT wip_entities_s.NEXTVAL
	INTO l_wip_entity_id
	FROM dual;

l_stmt_num := 40;

	FOR copy_wlji in copy_wlji_cursor LOOP

	--begin bugfix 2050277

	-- if bom_revision is null, then, get the default value
	if ( copy_wlji.bom_revision is null ) then
	    BOM_REVISIONS.Get_Revision
		(type => 'PART',
		 eco_status => 'ALL',
		 examine_type => 'ALL',
		 org_id => copy_wlji.organization_id,
		 item_id => copy_wlji.primary_item_id,
		 rev_date => nvl(copy_wlji.bom_revision_date, SYSDATE),
		 itm_rev => l_bom_revision);
	else
	   l_bom_revision := copy_wlji.bom_revision;
	end if;

	-- if routing_revision is null, then, get the default value
	if ( copy_wlji.routing_revision is null ) then
	   BOM_REVISIONS.Get_Revision
		(type => 'PROCESS',
		 eco_status => 'ALL',
		 examine_type => 'ALL',
		 org_id => copy_wlji.organization_id,
		 item_id => copy_wlji.primary_item_id,
		 rev_date => nvl(copy_wlji.Routing_Revision_Date, SYSDATE),
		 itm_rev => l_rtg_revision);
	else
	   l_rtg_revision := copy_wlji.routing_revision;
	end if;

	--end bugfix 2050277

	INSERT INTO wip_job_schedule_interface (
 				last_update_date,
  				last_updated_by,
  				creation_date,
  				created_by,
  				last_update_login,
  				request_id,
  				program_id,
  				program_application_id,
  				program_update_date,
  				group_id,
  				source_code,
  				source_line_id,
  				-- process_type,
  				organization_id,
  				load_type,
  				status_type,
  				-- old_status_type,
  				last_unit_completion_date,
  				-- old_completion_date,
  				processing_work_days,
  				daily_production_rate,
  				line_id,
  				primary_item_id,
  				bom_reference_id,
  				routing_reference_id,
  				bom_revision_date,
  				routing_revision_date,
  				wip_supply_type,
  				class_code,
  				lot_number,
  				-- lot_control_code,
  				job_name,
  				description,
  				firm_planned_flag,
  				alternate_routing_designator,
  				alternate_bom_designator,
  				demand_class,
  				start_quantity,
  				-- old_start_quantity,
  				wip_entity_id,
  				repetitive_schedule_id,
  				-- error,
  				-- parent_group_id,
  				attribute_category,
  				attribute1,
  				attribute2,
  				attribute3,
  				attribute4,
  				attribute5,
  				attribute6,
  				attribute7,
  				attribute8,
  				attribute9,
  				attribute10,
  				attribute11,
  				attribute12,
  				attribute13,
  				attribute14,
  				attribute15,
  				interface_id,
  				last_updated_by_name,
  				created_by_name,
  				process_phase,
  				process_status,
  				organization_code,
  				first_unit_start_date,
  				first_unit_completion_date,
  				last_unit_start_date,
  				scheduling_method,
  				line_code,
  				-- primary_item_segments,
  				-- bom_reference_segments,
  				-- routing_reference_segments,
  				routing_revision,
  				bom_revision,
  				completion_subinventory,
  				completion_locator_id,
  				completion_locator_segments,
  				schedule_group_id,
  				schedule_group_name,
  				build_sequence,
  				project_id,
  				-- project_name,
  				task_id,
  				-- task_name,
  				net_quantity,
  				-- descriptive_flex_segments,
 				project_number,
  				task_number,
  				-- project_costed,
  				end_item_unit_number,
 				overcompletion_tolerance_type,
  				overcompletion_tolerance_value,
  				kanban_card_id,
  				priority,
  				due_date,
  				allow_explosion,
  				header_id,
  				delivery_id )

		VALUES
			(	copy_wlji.last_update_date,
  				copy_wlji.last_updated_by,
  				copy_wlji.creation_date,
  				copy_wlji.created_by,
  				copy_wlji.last_update_login,
  				copy_wlji.request_id,
  				copy_wlji.program_id,
  				copy_wlji.program_application_id,
  				copy_wlji.program_update_date,
				p_wjsi_group_id, -- New group id is used
  				copy_wlji.source_code,
  				copy_wlji.source_line_id,
  				-- copy_wlji.process_type,
  				copy_wlji.organization_id,
  				copy_wlji.load_type,
  				copy_wlji.status_type,
  				--copy_wlji.old_status_type,
  				copy_wlji.last_unit_completion_date,
  				-- copy_wlji.old_completion_date,
  				copy_wlji.processing_work_days,
  				copy_wlji.daily_production_rate,
  				copy_wlji.line_id,
  				copy_wlji.primary_item_id,
  				copy_wlji.bom_reference_id,
  				copy_wlji.routing_reference_id,
  				copy_wlji.bom_revision_date,
  				copy_wlji.routing_revision_date,
  				copy_wlji.wip_supply_type,
  				copy_wlji.class_code,
  				copy_wlji.lot_number,
  				-- copy_wlji.lot_control_code,
  				copy_wlji.job_name,
  				copy_wlji.description,
  				copy_wlji.firm_planned_flag,
  				copy_wlji.alternate_routing_designator,
  				copy_wlji.alternate_bom_designator,
  				copy_wlji.demand_class,
  				copy_wlji.start_quantity,
  				-- copy_wlji.old_start_quantity,
  				copy_wlji.wip_entity_id,
  				copy_wlji.repetitive_schedule_id,
  				-- copy_wlji.error,
  				-- copy_wlji.parent_group_id,
  				copy_wlji.attribute_category,
  				copy_wlji.attribute1,
  				copy_wlji.attribute2,
  				copy_wlji.attribute3,
  				copy_wlji.attribute4,
  				copy_wlji.attribute5,
  				copy_wlji.attribute6,
  				copy_wlji.attribute7,
  				copy_wlji.attribute8,
  				copy_wlji.attribute9,
  				copy_wlji.attribute10,
  				copy_wlji.attribute11,
  				copy_wlji.attribute12,
  				copy_wlji.attribute13,
  				copy_wlji.attribute14,
  				copy_wlji.attribute15,
  				NULL, -- null assigned to interface_id
  				copy_wlji.last_updated_by_name,
  				copy_wlji.created_by_name,
  				copy_wlji.process_phase,
  				1, -- copy_wlji.process_status,
  				copy_wlji.organization_code,
  				copy_wlji.first_unit_start_date,
  				copy_wlji.first_unit_completion_date,
  				copy_wlji.last_unit_start_date,
  				copy_wlji.scheduling_method,
  				copy_wlji.line_code,
  				-- copy_wlji.primary_item_segments,
  				-- copy_wlji.bom_reference_segments,
  				-- copy_wlji.routing_reference_segments,
			    -- begin bugfix 2050277: Replace with l_rtg_revision and l_bom_revision
  				--copy_wlji.routing_revision,
  				--copy_wlji.bom_revision,
				l_rtg_revision,
				l_bom_revision,
			    -- end bugfix 2050277
  				copy_wlji.completion_subinventory,
  				copy_wlji.completion_locator_id,
  				copy_wlji.completion_locator_segments,
  				copy_wlji.schedule_group_id,
  				copy_wlji.schedule_group_name,
  				copy_wlji.build_sequence,
  				copy_wlji.project_id,
  				-- copy_wlji.project_name,
  				copy_wlji.task_id,
  				-- copy_wlji.task_name,
  				copy_wlji.net_quantity,
  				-- copy_wlji.descriptive_flex_segments,
 				copy_wlji.project_number,
  				copy_wlji.task_number,
  				-- copy_wlji.project_costed,
  				copy_wlji.end_item_unit_number,
 				copy_wlji.overcompletion_tolerance_type,
  				copy_wlji.overcompletion_tolerance_value,
  				copy_wlji.kanban_card_id,
  				copy_wlji.priority,
  				copy_wlji.due_date,
  				copy_wlji.allow_explosion,
  				copy_wlji.header_id,
  				copy_wlji.delivery_id );

		END LOOP;

EXCEPTION

	WHEN OTHERS THEN

	x_err_code := SQLCODE;
	x_err_msg  := 'WSMPJITH.COPY_TO_WJSI: '||
			    '(stmt_num='||l_stmt_num||')'||SUBSTR(SQLERRM, 1,1000);


END copy_to_wjsi;


PROCEDURE delete_from_wjsi( 	p_wjsi_group_id	IN NUMBER,
				x_err_code	OUT NUMBER,
				x_err_msg	OUT VARCHAR2	) IS

l_stmt_num 	NUMBER;

BEGIN

l_stmt_num:= 0;

	x_err_code:=0;
	x_err_msg := NULL;


	DELETE FROM wip_job_schedule_interface wjsi
	WHERE wjsi.group_id = p_wjsi_group_id ;

	DELETE FROM wip_interface_errors wie
	WHERE interface_id  in
		(SELECT interface_id
		FROM wip_job_schedule_interface wjsi
		WHERE  wjsi.group_id = p_wjsi_group_id);

EXCEPTION

	WHEN OTHERS THEN

	x_err_code := SQLCODE;
	x_err_msg  := 'WSMPJITH.DELETE_FROM_WJSI: '||
			    '(stmt_num='||l_stmt_num||')'||SUBSTR(SQLERRM, 1,1000);

END delete_from_wjsi;

END;

/
