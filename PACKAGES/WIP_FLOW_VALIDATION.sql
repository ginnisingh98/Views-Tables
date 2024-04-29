--------------------------------------------------------
--  DDL for Package WIP_FLOW_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_FLOW_VALIDATION" AUTHID CURRENT_USER as
 /* $Header: wipwovls.pls 120.0.12010000.1 2008/07/24 05:27:21 appldev ship $ */

/* *********************************************************************
			Public Functions
***********************************************************************/

/* Is it a valid Buildable Item */
function primary_item_id(p_rowid in rowid) return number;

/* Is it a valid Accounting Class */
function class_code( p_rowid in rowid) return number;

/* Is the Bom_Revision Valid */
function bom_revision(p_rowid in rowid) return number;

/*Is the Routing Revision Valid */
function routing_revision(p_rowid in rowid) return number;

/* Is the Bom Revision Date Valid */
function bom_rev_date(p_rowid in rowid) return number;

/* Is the Routing Revision Date Valid */
function rout_rev_date(p_rowid in rowid) return number;

/* Is the Alternate BOM Designator valid */
function alt_bom_desg(p_rowid in rowid) return number;

/* Is the ALternate Routing Designator Valid */
function alt_rout_desg(p_rowid in rowid) return number;

/* Is the Completion Sub Valid */
function completion_sub(p_rowid in rowid) return number;

/* Is the Completion Locator Valid */
function completion_locator_id(p_rowid in rowid) return number ;

/* Is the demand Class valid */
function demand_class(p_rowid in rowid) return number;

/* Is the schedule group id valid */
function schedule_group_id(p_rowid in rowid) return number;

/* Is the Build Sequence Valid */
function build_sequence(p_rowid in rowid) return number;

/* Is the line id valid */
function line_id(p_rowid in rowid) return number;

/* Is the Project Id valid */
function project_id(p_rowid in rowid) return number;

/* Is the Task Id valid */
function task_id(p_rowid in rowid) return number;

/* Is the Status valid */
function status(p_status in number) return number;

/* Is the schedule number valid */
function schedule_number(p_rowid in rowid) return number;

/* Is the schedule number valid */
function schedule_number(p_schedule_number in varchar2) return number;

/* Is the schedule flag valid */
function scheduled_flag(p_rowid in rowid) return number;

/* Is the end item unit number valid */
function unit_number(p_rowid in rowid) return number;


End Wip_Flow_Validation ;

/
