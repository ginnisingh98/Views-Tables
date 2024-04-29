--------------------------------------------------------
--  DDL for Package MSC_RP_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_RP_RELEASE_PUB" AUTHID CURRENT_USER AS
-- $Header: MSCRPRLS.pls 120.3.12010000.5 2010/03/17 21:21:58 hulu noship $

PROCEDURE do_release(pid IN Number,psid in number,p_user_id   in number,
			p_resp_id   in number,
			p_appl_id   in number);
FUNCTION get_instance_release_status(p_sr_instance_id number)
		return number;
FUNCTION get_implement_dock_date(p_plan_id in number,
				  p_inst_id in number,
				  p_org_id in number,
				  p_item_id in number,
				  p_receiving_calendar in varchar2,
				  p_implement_date in date) return date;

FUNCTION get_implement_ship_date(p_plan_id in number,
				  p_inst_id in number,
				  p_org_id in number,
				  p_order_type in number,
				  p_source_sr_instance_id in number,
				  p_source_org_id in number,
				  p_sourcre_vendor_site_id in number,
				  p_ship_method in varchar2,
				  p_intransit_calendar in varchar2,
				  p_ship_calendar in varchar2,
				  p_implement_dock_date in date,
				  p_source_table in varchar2) return date;


FUNCTION GET_WIP_JOB_PREFIX(p_instance_id in number) return varchar2;
Function get_Imp_Employee_id(
   p_plan_id in number,
   p_org_id in number,
   p_inst_id in number,
   p_item_id in number,
   p_planner_code in varchar2)  return number;

FUNCTION Check_Source_Supp_Org (
     p_inst_id in number,
     p_org_id in number) return number;


FUNCTION  validate_order_for_release(
p_plan_id			in number,
p_inst_id			in number,
p_org_id			in number,
p_org_code			in varchar2,
p_item_id			in number,
p_vmi				in number,
p_source_Table			in varchar2,
p_transaction_id		in number,
p_order_type			in number,
p_source_org_id			in number,
P_bom_item_type			in number,
p_release_time_fence_code	in number,
p_in_source_plan		in number,
p_build_in_wip_flag		in number,
p_purchasing_enabled_flag	in number,
p_planning_make_buy_code	in number,
p_planner_code			in varchar2,
p_implement_alternate_routing   in varchar2,
p_user_id   in number,
p_resp_id   in number,
p_appl_id   in number) return varchar2;

FUNCTION GET_ACTION (arg_source_table IN VARCHAR2,
                arg_plan_id  IN NUMBER ,
                arg_sr_instance_id in number,
                arg_org_id in number,
                arg_item_id in number,
                arg_bom_item_type IN NUMBER ,
                arg_base_item_id IN NUMBER ,
                arg_wip_supply_type IN NUMBER ,
                arg_order_type IN NUMBER ,
                arg_rescheduled_flag IN NUMBER,
                arg_disposition_status_type IN NUMBER ,
                arg_new_due_date IN DATE ,
                arg_old_due_date IN DATE ,
                arg_implemented_quantity IN NUMBER ,
                arg_quantity_in_process IN NUMBER ,
                arg_quantity_rate IN NUMBER ,
                arg_release_time_fence_code IN NUMBER ,
                arg_reschedule_days IN NUMBER ,
                arg_firm_quantity IN NUMBER ,
                arg_mrp_planning_code IN NUMBER,
                arg_lots_exist IN NUMBER
                 ) RETURN varchar2;


FUNCTION get_Implement_Location_Id(p_inst_id in number,
					p_org_id in number) return number;


FUNCTION GET_IMPLEMENT_WIP_CLASS_CODE(
 	p_plan_id in number,
	p_instance_id in number,
	p_org_id in number,
	p_item_id in number,
	p_transaction_id in number,
	p_order_type in number,
	p_project_id in number,
	p_implement_project_id in number,
	p_implement_as in number,
	p_implement_alternate_routing in varchar2) return varchar2;

PROCEDURE PRINT_DEBUG(MSG IN VARCHAR2);
--procedure validate_icx_session(p_icx_cookie in varchar2,p_function varchar2) ;
procedure validate_icx_session(p_icx_cookie in varchar2,p_function in varchar2 DEFAULT NULL);
FUNCTION GET_RP_PLAN_PROFILE_VALUE(P_PLAN_ID IN NUMBER,
                                  P_PROFILE_CODE IN VARCHAR2) RETURN VARCHAR2;

Function GET_REQUEST_STATUS (
         request_id     IN OUT nocopy number,
         application    IN varchar2 default NULL,
         program        IN varchar2 default NULL,
         phase          OUT nocopy varchar2  ,
         status         OUT nocopy varchar2  ,
         dev_phase      OUT nocopy varchar2,
         dev_status     OUT nocopy varchar2,
         message        OUT nocopy varchar2) return number;

Function test_permission(pname in varchar2) return number;
Function save_user_profile(name in varchar2, value in varchar2) return number;

END MSC_RP_RELEASE_PUB;

/
