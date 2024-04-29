--------------------------------------------------------
--  DDL for Package MSC_GET_NAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_GET_NAME" AUTHID CURRENT_USER AS
	/* $Header: MSCGPRJS.pls 120.20.12010000.6 2010/01/11 07:30:33 skakani ship $ */

	FUNCTION project(arg_project_id IN NUMBER,
                         arg_org_id IN NUMBER,
                         arg_plan_id IN NUMBER,
                         arg_instance_id IN NUMBER) return varchar2;

	FUNCTION task(arg_task_id IN NUMBER,
                      arg_project_id IN NUMBER,
                         arg_org_id IN NUMBER,
                         arg_plan_id IN NUMBER,
                         arg_instance_id IN NUMBER) return varchar2;

  FUNCTION resource_over_util_cost(arg_resource_id IN NUMBER,
                               arg_department_id IN NUMBER,
                               arg_org_id IN NUMBER,
                               arg_plan_id IN NUMBER,
                               arg_instance_id IN NUMBER) return number;

   FUNCTION planning_group(arg_project_id IN NUMBER,
                         arg_org_id IN NUMBER,
                         arg_plan_id IN NUMBER,
                         arg_instance_id IN NUMBER) return varchar2;

  FUNCTION demand_date (arg_pegging_id 	IN NUMBER,
                  arg_plan_id IN NUMBER)	return DATE;

  FUNCTION supply_date (arg_pegging_id 	IN NUMBER,
                  arg_plan_id IN NUMBER)	return DATE;

  FUNCTION org_code(arg_org_id IN NUMBER,
                  arg_instance_id IN NUMBER) return varchar2;
  FUNCTION org_code(arg_org_inst_id IN varchar2) return varchar2;  -- for SRP


  FUNCTION location_code(arg_org_id      IN NUMBER,
                         arg_location_id IN NUMBER,
                         arg_instance_id IN NUMBER) return VARCHAR2;


  FUNCTION instance_code(arg_instance_id IN NUMBER) return varchar2;

  FUNCTION lookup_meaning(arg_lookup_type IN varchar2,
                        arg_lookup_code IN NUMBER) return varchar2;

  FUNCTION lookup_by_plan(arg_lookup_type IN varchar2,
                        arg_lookup_code IN NUMBER,
                        arg_plan_type IN NUMBER,
                        arg_source_org_id IN NUMBER DEFAULT null) return varchar2;

   FUNCTION fnd_lookup_meaning(arg_lookup_type IN varchar2,
				arg_lookup_code IN NUMBER) return varchar2;

  FUNCTION supply_order(arg_demand_type IN NUMBER,
			    arg_disp_id IN NUMBER,
			    arg_org_id IN NUMBER,
			    arg_plan_id IN NUMBER,
		   	    arg_instance_id IN NUMBER,
                            arg_supply_type IN NUMBER DEFAULT NULL)
              return varchar2;

  FUNCTION order_type (arg_plan_id IN number,
                     arg_transaction_id IN NUMBER,
                     arg_instance_id IN NUMBER) RETURN number;

  FUNCTION job_name (arg_transaction_id IN NUMBER,
			   arg_plan_id IN NUMBER,
                            arg_sr_instance_id IN NUMBER DEFAULT NULL)
              return varchar2 ;


 FUNCTION  process_priority(arg_plan_id IN NUMBER,
                         arg_sr_instance_id IN NUMBER,
                         arg_organization_id IN NUMBER,
                        arg_inventory_item_id IN NUMBER,
                        arg_process_sequence_id IN NUMBER)
 return NUMBER;

  FUNCTION supply_type (arg_transaction_id IN NUMBER,
			   arg_plan_id IN NUMBER)
    return varchar2;

FUNCTION from_org(arg_plan_id IN NUMBER,
		  arg_transaction_id IN NUMBER,
 	     	  arg_instance_id IN NUMBER) return varchar2;

FUNCTION to_org(arg_plan_id IN NUMBER,
		  arg_transaction_id IN NUMBER,
 	     	  arg_instance_id IN NUMBER) return varchar2;

FUNCTION from_org_id(arg_plan_id IN NUMBER,
		  arg_transaction_id IN NUMBER,
 	     	  arg_instance_id IN NUMBER) return number;

FUNCTION to_org_id(arg_plan_id IN NUMBER,
		  arg_transaction_id IN NUMBER,
 	     	  arg_instance_id IN NUMBER) return number;

FUNCTION ship_method(arg_plan_id IN NUMBER,
		  arg_transaction_id IN NUMBER,
 	     	  arg_instance_id IN NUMBER) return varchar2;


  FUNCTION item_desc(arg_item_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2;

  FUNCTION item_name(arg_item_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2;

  FUNCTION item_name(arg_item_id IN NUMBER) return varchar2; -- for SRP

  FUNCTION resource_util_pct (arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return number;

  FUNCTION department_code(arg_line_flag IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2;

  FUNCTION resource_code(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2;

  FUNCTION resource_type(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return number;



  FUNCTION department_resource_code(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2;

  FUNCTION supplier(arg_supplier_id IN NUMBER) return varchar2;

  FUNCTION supplier_site(arg_supplier_site_id IN NUMBER) return varchar2;

  FUNCTION customer(arg_customer_id IN NUMBER) return varchar2;

  FUNCTION customer_site(arg_customer_site_id IN NUMBER) return varchar2;

  FUNCTION customer_address(arg_customer_site_id IN NUMBER) return varchar2;

  FUNCTION action(arg_source_table IN VARCHAR2,
		arg_bom_item_type IN NUMBER DEFAULT NULL,
		arg_base_item_id IN NUMBER DEFAULT NULL,
		arg_wip_supply_type IN NUMBER DEFAULT NULL,
		arg_order_type IN NUMBER DEFAULT NULL,
		arg_rescheduled_flag IN NUMBER DEFAULT NULL,
		arg_disposition_status_type IN NUMBER DEFAULT NULL,
		arg_new_due_date IN DATE DEFAULT NULL,
		arg_old_due_date IN DATE DEFAULT NULL,
		arg_implemented_quantity IN NUMBER DEFAULT NULL,
		arg_quantity_in_process IN NUMBER DEFAULT NULL,
		arg_quantity_rate IN NUMBER DEFAULT NULL,
   		arg_release_time_fence_code IN NUMBER DEFAULT NULL,
                arg_reschedule_days IN NUMBER DEFAULT NULL,
                arg_firm_quantity IN NUMBER DEFAULT NULL,
                arg_plan_id  IN NUMBER DEFAULT NULL,
                arg_critical_component  IN NUMBER DEFAULT NULL,
                arg_mrp_planning_code IN NUMBER DEFAULT NULL,
                arg_lots_exist IN NUMBER DEFAULT NULL,
                arg_part_condition IN NUMBER DEFAULT NULL) RETURN varchar2;

FUNCTION cfm_routing_flag(p_plan_id IN NUMBER,
        p_org_id IN NUMBER,
        p_instance_id IN NUMBER,
        p_item_id IN NUMBER,
        p_alt_rtg_desig IN VARCHAR2) return number;

FUNCTION alternate_bom(p_plan_id IN NUMBER,
	p_instance_id IN NUMBER,
	p_seq_id IN NUMBER) return varchar2;

FUNCTION alternate_rtg(p_plan_id IN NUMBER,
	p_instance_id IN NUMBER,
	p_seq_id IN NUMBER) return varchar2;

FUNCTION cfm_routing_flag(p_plan_id IN NUMBER,
	p_instance_id IN NUMBER,
	p_seq_id IN NUMBER) return number;

FUNCTION designator(p_desig_id IN NUMBER,
	p_fcst_set_id IN NUMBER default NULL,
        p_plan_id in NUMBER default NULL) return varchar2;

FUNCTION scenario_designator(p_desig_id IN NUMBER,
                             p_plan_id IN NUMBER,
                             p_organization_id IN NUMBER,
                             p_instance_id IN NUMBER) return varchar2;

FUNCTION forecastsetname(p_desig_id IN NUMBER,
                         p_plan_id IN NUMBER,
                         p_organization_id IN NUMBER,
                         p_instance_id IN NUMBER) return varchar2;

FUNCTION wip_status(p_transaction_id IN NUMBER) return number;

FUNCTION source_demand_priority(p_plan_id number,
                                p_demand_id NUMBER) return number;

  FUNCTION resource_batchable_flag(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return number;

  FUNCTION resource_min_capacity(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return number;

  FUNCTION resource_max_capacity(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER,
		   arg_supply_id IN NUMBER,
		   arg_batch_number IN NUMBER) return number;
  FUNCTION BATCHABLE_UOM(p_organization_id in NUMBER,
                         p_department_id   in NUMBER,
                         p_resource_id     in NUMBER) return varchar2;

  FUNCTION demand_quantity(p_plan_id number,
                           p_inst_id number,
                           p_demand_id NUMBER) return number;
  FUNCTION demand_order_number (p_plan_id number,
                           p_inst_id number,
                           p_demand_id NUMBER) return varchar2;

  FUNCTION ss_method_text (p_plan_id in number,
         p_org_id in number, p_inst_id in number, p_item_id in number)
         return varchar2 ;

-- This procedure executes dynamic sql because we cannot run
-- it on the client
PROCEDURE execute_dsql(arg_sql_stmt VARCHAR2);

FUNCTION Date_Timenum_to_DATE(dt dATE, time number) RETURN DATE;
PRAGMA RESTRICT_REFERENCES(Date_Timenum_to_DATE, WNDS, WNPS);

/* this function returns the julian date in floating point format */
FUNCTION DT_to_float(dt DATE)  RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(DT_to_float, WNDS, WNPS);

/* this function takes a julian date in a floating point format and returns a date */
FUNCTION float_to_DT(fdt NUMBER)  RETURN DATE;
PRAGMA RESTRICT_REFERENCES(float_to_DT, WNDS, WNPS);

/* FUNCTION sales_order(arg_demand_id IN NUMBER)
                            return varchar2;
*/
	PRAGMA RESTRICT_REFERENCES (project, WNDS,WNPS);
  	PRAGMA RESTRICT_REFERENCES (task, WNDS,WNPS);
  	PRAGMA RESTRICT_REFERENCES (planning_group, WNDS,WNPS);

 PRAGMA RESTRICT_REFERENCES (supply_order, WNDS,WNPS);
-- PRAGMA RESTRICT_REFERENCES (sales_order, WNDS, WNPS);
FUNCTION plan_name(p_plan_id number) return varchar2;
-- new function to calculate the number of workdays between two dates
FUNCTION get_number_work_days(start_date date,
                              end_date   date,
                              p_org_id   number,
                              p_inst_id  number) return number;
FUNCTION ABC_CLASS_ID (p_org_id number,
                       p_inst_id number) return number;

FUNCTION DEMAND_CLASS (p_inst_id number,
                       p_org_id number,
                       p_plan  varchar2) return varchar2 ;

FUNCTION DMD_PRIORITY_RULE (p_rule_id number) return varchar2 ;

FUNCTION OP_SEQ_NUM (p_plan_id number,
                     p_inst_id number,
                     p_org_id number,
                     p_comp_seq_id number,
                     p_bill_seq_id number,
                     p_arg_1 number ) return varchar2 ;

FUNCTION demand_name (p_plan_id number, p_demand_id number)
               return varchar2;
FUNCTION forward_backward_days(p_plan_id number,
                               p_schedule_desig_id number,
                               p_fb_type number)
               return number ;

FUNCTION category_desc(arg_category_name IN VARCHAR2,
                       arg_category_set_id IN NUMBER,
                       arg_org_id IN NUMBER,
                       arg_instance_id IN NUMBER) return varchar2;

  FUNCTION planner_code (arg_item_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2;


FUNCTION MSCX_CUST_SHIP_DATE(arg_exception_id IN NUMBER) return date;
FUNCTION MSCX_UDE_PUB_ORDER_TYPE (arg_exception_id IN NUMBER) return number;
FUNCTION MSCX_PLANNER_CODE (arg_exception_id IN NUMBER) return varchar2;
FUNCTION MSCX_QUANTITY (arg_exception_id IN NUMBER) return number;
FUNCTION MSCX_COMP_RECEIPT_DATE (arg_exception_id IN NUMBER) return date;
FUNCTION MSCX_COMP_REQUEST_DATE (arg_exception_id IN NUMBER) return date;
FUNCTION cp_exception_type_text (arg_exception_type IN NUMBER) return varchar2;
FUNCTION resource_code_all(arg_resource_id IN NUMBER, arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER,arg_resource_type in number) return varchar2;
FUNCTION resource_desc_all(arg_resource_id IN NUMBER, arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER,arg_resource_type in number) return varchar2;

FUNCTION source_supplier(arg_sr_instance_id IN NUMBER,
			arg_plan_id IN NUMBER,
			arg_supplier_id IN NUMBER,
			arg_source_supplier_id IN NUMBER,
			arg_source_org_id IN NUMBER,
			arg_order_type IN NUMBER) return varchar2;

FUNCTION source_supplier_site(arg_sr_instance_id IN NUMBER,
				arg_plan_id IN NUMBER,
				arg_supplier_site_id IN NUMBER,
				arg_source_supplier_site_id IN NUMBER,
				arg_source_org_id IN NUMBER,
				arg_order_type IN NUMBER) return varchar2;

FUNCTION category_name(arg_category_id IN number,
                       arg_category_set_id IN NUMBER,
                       arg_org_id IN NUMBER default null,
                       arg_instance_id IN NUMBER default null) return varchar2;
FUNCTION BUDGET_NAME(arg_budget_id in number) return varchar2;

function drp_alloc_name(arg_rule_id number)  return varchar2;
function drp_pri_rule_name(arg_rule_id number)  return varchar2;

function get_category_id(p_category_name in varchar2,
                         p_org_id number,
                         p_inst_id number) return number;

function get_order_number(p_inst_id in number,
                          p_plan_id in number,
                          p_transaction_id in number,
                          p_coprod in number default 0) return varchar2;

function get_trans_mode(p_ship_method_code in varchar2,
                        p_instance_id in number ) return varchar2;
FUNCTION lookup_meaning1(arg_lookup_type IN varchar2,
                        arg_lookup_code IN varchar2,
                        arg_application_id in number,
                        arg_security_group_id in number) return varchar2;

function res_req_capacity(p_plan_id in number,
                          p_transaction_id in number) return number;
FUNCTION set_name(p_inst_id in number,
                  p_so_line_id in number,
                  p_set_type in number) return varchar2;
function get_bom_item_type(p_item_id in number) return number;

FUNCTION get_other_customers(p_plan_id number,
                               p_schedule_desig_id number) return varchar2 ;

FUNCTION get_days_on_arrival(p_plan_id number,
                              p_exception_id number,
                              p_exception_type number,
                              p_demand_id number,
                              p_schedule_by number,
                              p_late_early_flag number) return number;
function get_cat_id (p_inventory_item_id number,
                     p_organization_id number,
                     p_instance_id number) return number;

function get_cat_set_id (p_inventory_item_id number,
                     p_organization_id number,
                     p_instance_id number) return number;

FUNCTION resource_group_name(arg_resource_id IN NUMBER,
                   arg_dept_id IN NUMBER,
                   arg_org_id IN NUMBER,
                   arg_plan_id IN NUMBER,
                   arg_instance_id IN NUMBER) return varchar2;

FUNCTION new_schedule_date (arg_plan_id IN NUMBER,
                  arg_trx_id IN NUMBER)	return DATE;

FUNCTION Get_Zone_Name(p_zone_id IN NUMBER,
		       p_sr_instance_id IN NUMBER )
		       return varchar2 ;

function alternate_bom_eff(p_process_seq_id number,
                               p_plan_id number,
                               p_sr_instance_id number) return varchar2;
function alternate_rtg_eff(p_process_seq_id number,
                               p_plan_id number,
                               p_sr_instance_id number) return varchar2;

function supply_order_number(p_order_type number,
				p_order_number varchar2,
				p_plan_id number ,
				p_sr_instance_id number,
				p_transaction_id number ,
				p_disposition_id number ) return varchar2;

FUNCTION operation_code(p_plan_id IN NUMBER,
                  p_sr_instance_id IN NUMBER,
                  p_standard_operation_id IN NUMBER) return varchar2;

FUNCTION setup_code(p_plan_id IN NUMBER,
                  p_sr_instance_id IN NUMBER,
                  p_resource_id IN NUMBER,
                  p_organization_id IN NUMBER,
                  p_setup_id IN NUMBER
                  ) return varchar2;

function get_mfd_order_number(p_order_type     in number,
                              p_order_number   in varchar2,
                              p_transaction_id in number,
                              p_sr_instance_id in number,
                              p_plan_id        in number,
                              p_disposition_id in number)
      return varchar2;

function get_res_and_dept_details(p_plan_id             in number,
                                  p_sr_instance_id      in number,
                                  P_res_transaction_id  in number,
                                  P_column_name      in varchar2)
return varchar2;

function get_mtq_details(p_plan_id  	    in number,
                         p_sr_instance_id   in number,
                         p_routing_seq_id   in number,
                         p_operation_seq_id in number,
                         p_item_id          in number,
                         p_cfm_routing_flag in number,
                         p_column_name      in varchar2)
         return number;

function eam_parent_work_order(	p_plan_id number ,
				p_sr_instance_id number,
				p_transaction_id number
				) return number;

FUNCTION standard_operation_code(p_plan_id IN NUMBER,
                  p_sr_instance_id IN NUMBER,
                  p_resource_id IN NUMBER,
                  p_org_id IN NUMBER,
                  p_from_setup_id IN NUMBER,
                  p_to_setup_id IN NUMBER
                  ) return varchar2;

function get_op_seq_id(p_plan_id  	    in number,
                       p_sr_instance_id   in number,
                       p_routing_seq_id   in number,
                       p_op_seq_num in number)
         return number;

function get_mfd_details(p_plan_id number,
                         p_trans_id number,
                         p_inst_id number,
                         p_routing_seq_id number,
                         p_op_seq_id number,
                         p_item_id  number,
                         c_trans_id number,
                         c_inst_id number,
                         c_op_seq_id number,
                         p_column_name varchar2)
           return number;

function get_mtq_coprod_details(p_plan_id  	     in number,
                          p_sr_instance_id   in number,
                          p_routing_seq_id   in number,
                          p_operation_seq_id in number,
                          p_item_id          in number,
                          p_column_name      in varchar2)
     return number;

function get_supply_order_number(p_plan_id number,
                                 p_inst_id number,
                                 p_trans_id number)
         return varchar2;

function get_supply_item(p_plan_id number,
                         p_inst_id number,
                         p_trans_id number)
         return varchar2;

function get_supply_org_code(p_plan_id number,
				 p_inst_id number,
				 p_trans_id number)
         return varchar2;

function get_min_max_offset_time(p_plan_id number,
				 p_inst_id number,
				 p_from_trans_id number,
				 p_to_trans_id number,
				 p_from_op_seq_num number,
				 p_to_op_seq_num number ,
				 p_from_res_seq_num number,
				 p_to_res_seq_num number ,
				 p_min_max_flag varchar2)
         return number;

function get_load_ratio_diff_threshold(p_plan_id number,
					p_sr_instance_id number,
					p_organization_id number,
					p_department_id number,
					p_resource_id number)
	return number;

function get_ship_to_consumption_level(p_demand_plan_id number,
				       p_scenario_id  number
					)
	return number;
function GET_preference(p_key varchar2,
                        p_pref_id number,
                        p_plan_type number)
         return varchar2;

  FUNCTION lookup_fnd(arg_lookup_type IN varchar2, arg_lookup_code IN varchar2) return varchar2;
  function get_default_pref_id(p_user_id number,p_plan_type in number default null) return number;
  FUNCTION get_std_op_code(p_plan_id              number,
                         p_sr_instance_id       number,
                         p_routing_sequence_id  number,
                         p_op_seq_id         number) return varchar2;

  function res_instance_data(p_req_column IN varchar2,
    p_plan_id IN number,
    p_sr_instance_id IN number,
    p_organization_id IN number,
    p_department_id IN number,
    p_resource_id IN Number,
    p_supply_id IN Number,
    p_operation_seq_num IN Number,
    p_resource_seq_num IN Number,
    p_orig_resource_seq_num IN Number,
    p_parent_seq_num IN Number,
    p_parent_Id IN Number) return varchar2;

FUNCTION get_processing_leadtime(p_plan_id number,
                                 p_org number,
		                         p_inst number,
		                         p_item number,
		                         p_supplier number,
		                         p_supplier_site number) return number;


FUNCTION check_cfm(p_plan_id number,p_org_id number,
                   p_instance_id number, p_item_id number,
                   p_transaction_id number,
                   p_impl_alt_routing varchar2)
         return number;

FUNCTION load_type ( p_plan_type IN NUMBER
                   , p_plan_id IN NUMBER
                   , p_source_table IN VARCHAR2  -- MSC_SUPPLIES or MSC_DEMANDS
                   , p_transaction_id IN NUMBER  -- or demand_id
                   , p_organization_id IN NUMBER
                   , p_sr_instance_id IN NUMBER
                   , p_order_type IN NUMBER
                   , p_implement_as IN NUMBER
                   , p_source_organization_id IN NUMBER
                   , p_source_sr_instance_id IN NUMBER
                   , p_cfm_routing_flag IN NUMBER
                   , p_item_id IN NUMBER DEFAULT NULL
                   , p_impl_alt_routing IN VARCHAR2 DEFAULT NULL
                   ) RETURN NUMBER;

FUNCTION get_equipment_desc(arg_plan_id IN NUMBER,
                            arg_org_id IN NUMBER,
                            arg_instance_id IN NUMBER,
                            arg_item_id IN NUMBER) return varchar2;

function isResReqSegments_Available(p_plan_id          in number,
                                   p_sr_instance_id        in number,
                                   p_trans_id              in number)
     return number;

FUNCTION get_application_id(arg_application_name in varchar2) return number;

FUNCTION setup_std_op_code(
                  p_plan_id IN NUMBER,
                  p_sr_instance_id IN NUMBER,
                  p_department_id IN NUMBER,
                  p_org_id IN NUMBER,
                  p_supply_id IN Number,
                  p_operation_seq_num IN Number,
                  p_resource_seq_num IN number,
                  p_parent_seq_num IN Number,
                  p_setup_id IN Number,
                  p_schedule_flag IN Number
                  ) return varchar2;

    FUNCTION is_within_rel_time_fence(p_plan_start_date  IN DATE,
                                      P_order_start_date IN DATE,
                                      p_release_time_fence_code     IN NUMBER,
                                      P_cumulative_total_lead_time  IN NUMBER,
                                      P_cum_manufacturing_lead_time IN NUMBER,
                                      P_full_lead_time              IN NUMBER,
                                      P_release_time_fence_days     IN NUMBER
                                    ) RETURN NUMBER;

-- This function executes dynamic sql and returns count.
function execute_sql_getcount(arg_sql_stmt VARCHAR2) return number;

FUNCTION implement_as(p_order_type number,
                      p_org_id number,
                      p_source_org_id number,
                      p_source_supplier_id number,
                      p_build_in_wip_flag number,
                      p_planning_make_buy_code number,
                      p_purchasing_enabled_flag number,
                      p_cfm_routing_flag number) RETURN number;

FUNCTION get_res_units(p_plan_id     IN NUMBER,
                  p_sr_instance_id   IN NUMBER,
                  p_org_id           IN NUMBER,
                  p_department_id    IN NUMBER,
                  p_resource_id      IN NUMBER,
                  p_batch_start_date IN DATE,
                  p_batch_end_date   IN DATE) RETURN number;

FUNCTION category_set_name(p_cat_set_id NUMBER) return varchar2;

FUNCTION get_default_dem_pri_rule_id return number;

FUNCTION get_default_dem_pri_rule return varchar2;

  --5375991bugfix
  function op_desc(p_plan_id number, p_sr_instance_id number,
        p_routing_seq_id number, p_op_seq_id number) return varchar2;

FUNCTION get_order_view(p_plan_type number, p_plan_id number) return varchar2;

function get_srp_group_name(p_group_id number default null, p_user_id number default null, p_planned_by number default null) return varchar2;

  function forecast_rule_name(p_forecast_rule_id number) return varchar2;

  Function get_order_Comments(p_plan_id in number,
                              p_entity_type  in varchar2,
                              p_transaction_id in number)
                              return varchar2;

FUNCTION action_id(arg_source_table IN VARCHAR2,
                arg_bom_item_type IN NUMBER DEFAULT NULL,
                arg_base_item_id IN NUMBER DEFAULT NULL,
                arg_wip_supply_type IN NUMBER DEFAULT NULL,
                arg_order_type IN NUMBER DEFAULT NULL,
                arg_rescheduled_flag IN NUMBER DEFAULT NULL,
                arg_disposition_status_type IN NUMBER DEFAULT NULL,
                arg_new_due_date IN DATE DEFAULT NULL,
                arg_old_due_date IN DATE DEFAULT NULL,
                arg_implemented_quantity IN NUMBER DEFAULT NULL,
                arg_quantity_in_process IN NUMBER DEFAULT NULL,
                arg_quantity_rate IN NUMBER DEFAULT NULL,
                arg_release_time_fence_code IN NUMBER DEFAULT NULL,
                arg_reschedule_days IN NUMBER DEFAULT NULL,
                arg_firm_quantity IN NUMBER DEFAULT NULL,
                arg_plan_id  IN NUMBER DEFAULT NULL,
                arg_critical_component IN NUMBER DEFAULT NULL,
                arg_mrp_planning_code  IN NUMBER DEFAULT NULL,
                arg_lots_exist IN NUMBER DEFAULT NULL,
                arg_part_condition IN NUMBER DEFAULT NULL) RETURN Number;
FUNCTION carrier(arg_carrier_id IN NUMBER) return varchar2;

FUNCTION CUSTOMER_PO_NUMBER (arg_demand_id IN NUMBER,
                             arg_sr_instance_id IN NUMBER) return varchar2;

FUNCTION CUST_LINE_NUMBER (arg_demand_id IN NUMBER,
                                  arg_sr_instance_id IN NUMBER) return varchar2;

end msc_get_name;

/
