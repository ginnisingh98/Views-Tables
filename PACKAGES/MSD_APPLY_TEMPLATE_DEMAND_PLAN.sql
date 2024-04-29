--------------------------------------------------------
--  DDL for Package MSD_APPLY_TEMPLATE_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_APPLY_TEMPLATE_DEMAND_PLAN" AUTHID CURRENT_USER AS
/* $Header: msdatdps.pls 120.3 2006/03/31 06:16:33 brampall noship $ */

/* Public Procedures */

function apply_template(
p_new_dp_id in out nocopy number,
p_target_demand_plan_name in VARCHAR2,
p_target_demand_plan_descr in VARCHAR2,
p_shared_db_location in VARCHAR2,
p_source_dp_id in NUMBER,
p_organization_id in number,
p_instance_id  in number,
p_errcode in out nocopy varchar2
) return NUMBER;


function create_plan_using_template(
p_new_dp_id in out nocopy number,
p_target_demand_plan_name in VARCHAR2,
p_target_demand_plan_descr in VARCHAR2,
p_plan_type in VARCHAR2,
p_plan_start_date in date,
p_plan_end_date in date,
p_supply_plan_id in number,
p_supply_plan_name in VARCHAR2,
p_organization_id in number,
p_instance_id  in number,
p_errcode in out nocopy varchar2
) return boolean;

procedure remove_dimension(
p_demand_plan_id in number,
p_dimension_code in varchar2,
p_dp_dimension_code in varchar2);

procedure remove_parameter(
p_demand_plan_id in number,
p_parameter_id in number);

procedure remove_scenario(
p_demand_plan_id in number,
p_scenario_id in number);

procedure remove_scenario_event(
p_demand_plan_id in number,
p_scenario_id in number,
p_event_id in number);

procedure remove_scenario_output_lvl(
p_demand_plan_id in number,
p_scenario_id in number,
p_level_id in number);

procedure remove_event(
p_demand_plan_id in number,
p_dp_event_id in number);

procedure remove_price_list(
p_demand_plan_id in number,
p_dp_price_list_id in number);

procedure remove_calendar(
p_demand_plan_id in number,
p_calendar_type in varchar2,
p_calendar_code in varchar2);

procedure remove_hierarchy(
p_demand_plan_id in number,
p_dp_dimension_code in varchar2,
p_hierarchy_id in number);

procedure add_dimension(
p_demand_plan_id in number,
p_dimension_code in varchar2,
p_dp_dimension_code in varchar2);

procedure add_parameter(
p_demand_plan_id in number,
p_parameter_type in varchar2,
p_parameter_name in varchar2);


procedure add_scenario(
p_demand_plan_id in number,
p_scenario_name in varchar2);

procedure add_event(
p_demand_plan_id in number,
p_event_id in number);

procedure add_price_list(
p_demand_plan_id in number,
p_dp_price_list_id in number);  /*--Bug # 4549068-- Instead of price_list_name, price_list_id will be passed.---*/

procedure add_calendar(
p_demand_plan_id in number,
p_calendar_type in varchar2,
p_calendar_code in varchar2);

procedure add_hierarchy(
p_demand_plan_id in number,
p_dp_dimension_code in varchar2,
p_hierarchy_id in number);

procedure add_scenario_event(
p_demand_plan_id in number,
p_scenario_id in number,
p_event_id in number);

procedure add_scenario_output_lvl(
p_demand_plan_id in number,
p_scenario_id in number,
p_level_id in number);

procedure change_output_period(
p_demand_plan_id in varchar2,
p_scenario_id in varchar2,
p_output_period_type_id in varchar2,
p_old_output_period_type_id in varchar2);

procedure change_hierarchy(
p_demand_plan_id in varchar2,
p_hierarchy_id in varchar2,
p_old_hierarchy_id in varchar2);

procedure change_output_level(
p_demand_plan_id in varchar2,
p_scenario_id in varchar2,
p_level_id in varchar2,
p_old_level_id in varchar2);

procedure change_scenario_stream(
p_demand_plan_id in varchar2,
p_scenario_id in varchar2,
p_stream_type in varchar2,
p_stream_name in varchar2,
p_old_stream_type in varchar2,
p_old_stream_name in varchar2);

Procedure create_seeded_definitions(p_demand_plan_id in number,
p_errcode in out nocopy varchar2
);

-- Bug 4729854
Procedure attach_supply_plan(p_new_dp_id in number,p_supply_plan_id in number,p_supply_plan_name in varchar2,p_old_supply_plan_id in number default null, p_old_supply_plan_name in varchar2 default null);

Procedure add_ascp_scenario(p_new_dp_id in number,p_supply_plan_id in number, p_supply_plan_name in varchar2);

Procedure add_ascp_input_parameter(p_new_dp_id in number,p_supply_plan_id in number,p_supply_plan_name in varchar2, p_old_supply_plan_id in number default null,p_old_supply_plan_name in varchar2 default null);

Procedure add_ascp_formula(p_new_dp_id in number,p_supply_plan_id in number, p_supply_plan_name in varchar2,p_old_supply_plan_id in number default null, p_old_supply_plan_name in varchar2 default null);

Procedure add_ascp_measure(p_new_dp_id in number,p_supply_plan_id in number, p_supply_plan_name in varchar2,p_old_supply_plan_id in number default null, p_old_supply_plan_name in varchar2 default null);

Procedure set_prd_lvl_for_liab_reports(p_demand_plan_id in number, p_errcode in out nocopy varchar2);

--Function get_supply_plan_name(p_supply_plan_id in number) return varchar2;  -- Bug 4729854

Function get_supply_plan_start_date(p_supply_plan_id in number) return date;

Function get_supply_plan_end_date(p_supply_plan_id in number) return date;

Function get_parameter_id(p_demand_plan_id in number, p_parameter_type in varchar2, p_parameter_name in varchar2, p_parameter_component in varchar2) return number;

Function get_formula_id(p_demand_plan_id in number, p_formula_name in varchar2, p_supply_plan_name in varchar2) return number;

Function get_calendar_code(p_demand_plan_id in number,p_old_output_period_type_id in number) return varchar2;

Procedure	replace_associate_parameters(p_new_dp_id	in number);

procedure replace_parameter_tokens(p_demand_plan_id number);

END MSD_APPLY_TEMPLATE_DEMAND_PLAN ;

 

/
