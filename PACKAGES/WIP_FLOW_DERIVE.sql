--------------------------------------------------------
--  DDL for Package WIP_FLOW_DERIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_FLOW_DERIVE" AUTHID CURRENT_USER as
 /* $Header: wipwodfs.pls 115.10 2004/07/28 10:42:01 panagara ship $ */

/* *********************************************************************
			Public Functions
***********************************************************************/

/* Defaulting the Flow related information for the form in one DB hit */
function Flow_Form_Defaulting(
		p_txn_action_id IN NUMBER,     -- CFM Scrap
                p_txn_type_id in number,
		p_item_id in number,
                p_org_id in number,
                p_start_date in date,
                p_alt_rtg_des in varchar2,
                p_bom_rev in out NOCOPY varchar2,
                p_rev in out NOCOPY varchar2,
                p_bom_rev_date in out NOCOPY date,
                p_rout_rev in out NOCOPY varchar2,
                p_rout_rev_date in out NOCOPY date,
                p_comp_sub in out NOCOPY varchar2,
                p_comp_loc in out NOCOPY number,
                p_proj_id in number,
                p_task_id in number) return number;


/* Default the Class Code */
function class_code( p_class_code in out NOCOPY varchar2,
                     p_err_mesg in out NOCOPY varchar2,
                     p_org_id in number,
                     p_item_id in number,
                     p_wip_entity_type in number,
                     p_project_id in number) return number;

/* Default the Bill Revision and date */
function bom_revision(     p_bom_rev in out NOCOPY varchar2,
			   p_rev in out NOCOPY varchar2,
                           p_bom_rev_date in out NOCOPY date,
                           p_item_id in number,
                           p_start_date in date,
                           p_Org_id in number) return number;

/* Default the Routing Revision and date */
function routing_revision(      p_rout_rev in out NOCOPY varchar2,
				p_rout_rev_date in out NOCOPY date,
				p_item_id in number,
                            	p_start_date in date,
                            	p_Org_id in number) return number ;


/* Defaulting Completion Subinventory */
function completion_sub(p_comp_sub in out NOCOPY varchar2,
                        p_item_id in number,
                        p_org_id in number,
                        p_alt_rtg_des in varchar2) return number ;


/* Defaulting Routing Completion Locator Id */
function routing_completion_sub_loc(
                        p_rout_comp_sub in out NOCOPY varchar2,
                        p_rout_comp_loc in out NOCOPY number,
                        p_item_id in number,
                        p_org_id in number,
                        p_alt_rtg_des in varchar2) return number;

/* Defaulting completion locator id. In completion_loc, we only default locator id from
   the routing if p_proj_id is not null. I don't think we need that restriction. Also,
   p_txn_int_id is unneccessary. INV validation should derive the locator id from the
   segments provided. We only need to check the existence of locator id */
function completion_locator_id(p_comp_loc in out NOCOPY number,
                               p_item_id in number,
                               p_org_id in number,
                               p_alt_rtg_des in varchar2,
                               p_proj_id in number,
                               p_task_id in number,
                               p_comp_sub in varchar2) return number;

/* Defaulting Completion Locator Id */
function completion_loc(p_comp_loc in out NOCOPY number,
                        p_item_id in number,
                        p_org_id in number,
                        p_alt_rtg_des in varchar2,
			p_proj_id in number,
                        p_task_id in number,
                        p_comp_sub in varchar2,
			p_txn_int_id in number default null) return number;


/* Defaulting Schedule Group Id nedded for R11+, right now it is stubbed */
function schedule_group_id(p_sched_grp_id in out NOCOPY number) return number ;


/* Defaulting Build Sequence Valid -- nedded for R11+, right now it is stubbed */
function build_sequence(p_build_seq in out NOCOPY number) return number;

/* Defaulting Project Id valid -- this makes sure both the values are the same */
function src_project_id(p_src_proj_id in out NOCOPY number,
                        p_proj_id in out NOCOPY number) return number;


/* Defaulting the Task Id valid -- this makes sure both the values are the same */
function src_task_id(p_src_task_id in out NOCOPY number,
                      p_task_id in out NOCOPY number) return number ;

/* Defaulting the schedule number*/
function schedule_number(p_sched_num in out NOCOPY varchar2) return number ;


/*Defaulting the Last Updated Id */
function Last_Updated_ID(     p_last_up_by_name in out NOCOPY varchar2,
                              p_last_up_id in out NOCOPY number) return number;

/*Defauting the Created By ID */
function Created_By_ID(  p_created_by_name in out NOCOPY varchar2,
                              p_created_id in out NOCOPY number) return number;

/* Defaulting the Organization ID */
function Organization_Code(p_org_name in out NOCOPY varchar2,
                           p_org_id in out  NOCOPY number) return number;

/* Defaulting the Transaction source name */
function Transaction_Source_Name(
                        p_txn_src_name in out NOCOPY varchar2,
                        p_txn_src_id in out NOCOPY number,
                        p_org_id in number) return number ;


/* Defaulting the information for a scheduled flow schedule */
function Scheduled_Flow_Derivation(
		        p_txn_action_id IN NUMBER,-- CFM Scrap
			p_item_id in number,
                        p_org_id in number,
                        p_txn_src_id in number,
                        p_sched_num in out NOCOPY varchar2,
                        p_src_proj_id in out NOCOPY number,
                        p_proj_id in out NOCOPY number,
                        p_src_task_id in out NOCOPY number,
                        p_task_id in out NOCOPY number,
                        p_bom_rev in out NOCOPY varchar2,
                        p_rev in out NOCOPY varchar2,
                        p_bom_rev_date  in out NOCOPY date,
                        p_rout_rev in out NOCOPY varchar2,
                        p_rout_rev_date in out NOCOPY date,
                        p_comp_sub in out NOCOPY varchar2,
                        p_class_code in out NOCOPY varchar2,
                        p_wip_entity_type in out NOCOPY number,
                        p_comp_loc in out NOCOPY number,
                        p_alt_rtg_des in out NOCOPY varchar2,
                        p_alt_bom_des in out NOCOPY varchar2) return number;


End Wip_Flow_Derive ;

 

/
