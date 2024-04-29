--------------------------------------------------------
--  DDL for Package WIP_SF_CUSTOM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SF_CUSTOM_API" AUTHID CURRENT_USER AS
/* $Header: wipsfcas.pls 115.8 2002/12/12 15:59:07 rmahidha ship $ */

/* ***************************************************************

   schedule_custom_api

   INPUT PARAMETERS (and the db columns they correspond to)
   scheduleNumber : wip_flow_schedules.schedule_number
   orgCode : org_organization_definitions.organization_code
   lineCode : wip_lines.line_code
   opSeqID : bom_operation_sequences.operation_sequence_id
   salesOrderNumber : mtl_sales_orders_kfv.concatenated_segments
   assemblyName : mtl_system_items_kfv.concatenated_segments
   scheduleGroup : wip_schedule_groups.schedule_group_name
   buildSequence : wip_flow_schedules.build_sequence
   completionDate : wip_flow_schedules.scheduled_completion_date
   projectName : pjm_projects_v.project_name
   taskName : pjm_tasks_v.task_name

   note that a set of orgCode, lineCode, scheduleNumber, and
   opSeqID uniquely identifies a schedule node.  These input
   parameters are guaranteed to have non-null values.
   Some of the other input parameters may be null.

*************************************************************** */

PROCEDURE schedule_custom_api (
	scheduleNumber IN VARCHAR2,
	orgCode IN VARCHAR2,
	lineCode IN VARCHAR2,
	opSeqID IN NUMBER,
	salesOrderNumber IN VARCHAR2,
	assemblyName IN VARCHAR2,
	scheduleGroup IN VARCHAR2,
	buildSequence IN NUMBER,
	completionDate IN DATE,
	projectName IN VARCHAR2,
	taskName IN VARCHAR2,
	x_num_attr OUT NOCOPY NUMBER,
	x_labels OUT NOCOPY system.wip_attr_labels,
	x_values OUT NOCOPY system.wip_attr_values,
	x_colors OUT NOCOPY system.wip_attr_colors);

/* ***************************************************************

   event_custom_api

   INPUT PARAMETERS
   scheduleNumber : wip_flow_schedules.schedule_number
   orgCode : org_organization_definitions.organization_code
   lineCode : wip_lines.line_code
   lineopSeqID : bom_operation_sequences.operation_sequence_id
   opSeqNum : bom_operation_sequences.operation_seq_num
   opCode : bom_standard_operations.operation_code
   deptCode : bom_departments.department_code

   note that a set of orgCode, lineCode, scheduleNumber,
   lineopSeqID, and opSeqNum uniquely identifies a schedule node.

*************************************************************** */

PROCEDURE event_custom_api (
	scheduleNumber IN VARCHAR2,
	orgCode IN VARCHAR2,
	lineCode IN VARCHAR2,
	lineopSeqID IN NUMBER,    -- equals schedule's opSeqID
	opSeqNum IN NUMBER,
	opCode IN VARCHAR2,
	deptCode IN VARCHAR2,
	x_num_attr OUT NOCOPY NUMBER,
	x_labels OUT NOCOPY system.wip_attr_labels,
	x_values OUT NOCOPY system.wip_attr_values,
	x_colors OUT NOCOPY system.wip_attr_colors);

END wip_sf_custom_api;

 

/
