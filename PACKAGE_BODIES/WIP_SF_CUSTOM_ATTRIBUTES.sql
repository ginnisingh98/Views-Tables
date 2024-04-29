--------------------------------------------------------
--  DDL for Package Body WIP_SF_CUSTOM_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SF_CUSTOM_ATTRIBUTES" AS
/* $Header: wipsfatb.pls 115.7 2002/11/28 13:02:04 jyeung ship $ */

PROCEDURE get_schedule_attr (
	orgID IN NUMBER,
	lineID IN NUMBER,
	wipEntityID IN NUMBER,
	opSeqID IN NUMBER,
	p_num_attr OUT NOCOPY NUMBER,
	p_labels OUT NOCOPY system.wip_attr_labels,
	p_values OUT NOCOPY system.wip_attr_values,
	p_colors OUT NOCOPY system.wip_attr_colors) IS
sched_num VARCHAR2(30);
org_code VARCHAR2(3);
line_code VARCHAR2(10);
sales_order VARCHAR2(122);
assembly VARCHAR2(40);
sched_group VARCHAR2(30);
build_seq NUMBER;
comp_date DATE;
proj_name VARCHAR2(30);
task_name VARCHAR2(20);
BEGIN
       SELECT 	wfs.schedule_number,
		mp.organization_code,
		wl.line_code,
		mso.concatenated_segments,
		msik.concatenated_segments,
		wsg.schedule_group_name,
		wfs.build_sequence,
		wfs.scheduled_completion_date,
                pjm_project.all_proj_idtoname(wfs.project_id),
                pjm_project.all_task_idtoname(wfs.task_id)
	INTO
		sched_num,
		org_code,
		line_code,
		sales_order,
		assembly,
		sched_group,
		build_seq,
		comp_date,
		proj_name,
		task_name
	FROM
		wip_flow_schedules wfs,
                mtl_system_items_kfv msik,
                mtl_sales_orders_kfv mso,
		mtl_parameters mp,
                wip_lines wl,
                wip_schedule_groups wsg
	WHERE
		wfs.organization_id = orgID
	    AND wfs.line_id = lineID
	    AND wfs.wip_entity_id = wipEntityID
            AND wsg.organization_id (+) = wfs.organization_id
            AND wsg.schedule_group_id (+) = wfs.schedule_group_id
            AND wl.line_id = wfs.line_id
            AND wl.organization_id = wfs.organization_id
            AND msik.inventory_item_id = wfs.primary_item_id
            AND msik.organization_id = wfs.organization_id
            AND mso.sales_order_id (+) = wfs.demand_source_header_id
	    AND	wfs.organization_id = mp.organization_id;

	wip_sf_custom_api.schedule_custom_api (
		scheduleNumber 	=> sched_num,
		orgCode        	=> org_code,
		lineCode	=> line_code,
		opSeqID 	=> opSeqID,
		salesOrderNumber => sales_order,
		assemblyName 	=> assembly,
		scheduleGroup 	=> sched_group,
		buildSequence 	=> build_seq,
		completionDate 	=> comp_date,
		projectName 	=> proj_name,
		taskName 	=> task_name,
		x_num_attr 	=> p_num_attr,
		x_labels 	=> p_labels,
		x_values 	=> p_values,
		x_colors 	=> p_colors);
END get_schedule_attr;

PROCEDURE get_event_attr (
	orgID IN NUMBER,
	lineID IN NUMBER,
	wipEntityID IN NUMBER,
	lineopSeqID IN NUMBER,    -- equals schedule's opSeqID
	opSeqNum IN NUMBER,
	p_num_attr OUT NOCOPY NUMBER,
	p_labels OUT NOCOPY system.wip_attr_labels,
	p_values OUT NOCOPY system.wip_attr_values,
	p_colors OUT NOCOPY system.wip_attr_colors) IS
sched_num VARCHAR2(30);
org_code VARCHAR2(3);
line_code VARCHAR2(10);
op_code VARCHAR2(4);
dept_code VARCHAR2(10);
BEGIN
  	SELECT	wfs.schedule_number,
               	mp.organization_code,
         	wl.line_code,
	 	bso.operation_code,
	 	bd.department_code
	INTO
		sched_num,
		org_code,
		line_code,
		op_code,
		dept_code
	FROM    wip_flow_schedules wfs,
        	wip_lines wl,
        	bom_operation_sequences bos,
        	bom_operation_sequences bos2,
        	bom_operational_routings bor,
        	bom_departments bd,
        	bom_standard_operations bso,
        	mtl_parameters mp
	WHERE   bor.organization_id = wfs.organization_id
  	  and   bor.assembly_item_id = wfs.primary_item_id
  	  and	bor.line_id = wfs.line_id
          and 	bor.cfm_routing_flag = 1
          and 	decode(bor.alternate_routing_designator, null,'@@@@@@@',bor.alternate_routing_designator) = decode(wfs.alternate_routing_designator, null, '@@@@@@@', wfs.alternate_routing_designator)
          and 	bos.operation_type = 3
          and 	bos.routing_sequence_id = bor.common_routing_sequence_id
          and 	bos2.line_op_seq_id = bos.operation_sequence_id
          and 	wfs.organization_id = orgID
	  and	wfs.line_id = lineID
	  and	wfs.wip_entity_id = wipEntityID
          and	bos.operation_sequence_ID = lineopSeqID
	  and	bos2.operation_seq_num = opSeqNum
	  and	wfs.organization_id = mp.organization_id
          and 	trunc(BOS2.effectivity_date) <= trunc(nvl(WFS.routing_revision_date,sysdate))
          and 	(BOS2.disable_date is null or trunc(BOS2.disable_date) > trunc(WFS.routing_revision_date))
          and	bd.department_id = bos2.department_id
	  and	bso.standard_operation_id (+) = bos2.standard_operation_id
          and	wl.line_id = wfs.line_id
          and	wl.organization_id = wfs.organization_id;

	wip_sf_custom_api.event_custom_api (
		scheduleNumber	=> sched_num,
		orgCode 	=> org_code,
		lineCode 	=> line_code,
		lineopSeqID 	=> lineopSeqID,
		opSeqNum 	=> opSeqNum,
		opCode 		=> op_code,
		deptCode 	=> dept_code,
		x_num_attr 	=> p_num_attr,
		x_labels 	=> p_labels,
		x_values 	=> p_values,
		x_colors 	=> p_colors);
END get_event_attr;

END wip_sf_custom_attributes;

/
