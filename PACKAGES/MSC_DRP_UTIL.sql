--------------------------------------------------------
--  DDL for Package MSC_DRP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_DRP_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSCDRPUS.pls 120.9 2007/05/29 21:32:43 eychen ship $ */

TYPE numberArr IS TABLE OF number INDEX BY BINARY_INTEGER;

FUNCTION order_type_text(arg_lookup_type IN varchar2,
                        arg_lookup_code IN NUMBER,
                        arg_org_id IN NUMBER,
                        arg_source_org IN NUMBER,
                        arg_demand_source_type IN NUMBER default null) return varchar2;

FUNCTION cost_under_util(p_plan_id number,
                         p_weight_cap number, p_volume_cap number,
                         p_weight number, p_volume number,
                         p_from_org_id number, p_from_inst_id number,
                         p_to_org_id number, p_to_inst_id number,
                         p_ship_method varchar2) RETURN number;

FUNCTION material_avail_date(p_plan_id number, p_supply_id number)
                                                         RETURN date ;

 PROCEDURE offset_date(p_anchor_date in varchar2,
                          p_plan_id in number,
                          p_from_org in number, p_to_org in number,
                          p_inst_id in number,
                          p_ship_method in varchar2,
                          p_lead_time in out nocopy number,
                          p_ship_calendar in out nocopy varchar2,
                          p_deliver_calendar in out nocopy varchar2,
                          p_receive_calendar in out nocopy varchar2,
                          p_ship_date in out nocopy date,
                          p_dock_date in out nocopy date);

 PROCEDURE offset_dates(p_anchor_date in varchar2,
                          p_plan_id in number,
                          p_from_org in number, p_to_org in number,
                          p_inst_id in number,
                          p_item_id in number,
                          p_ship_method in varchar2,
                          p_lead_time in number,
                          p_ship_calendar in varchar2,
                          p_deliver_calendar in varchar2,
                          p_receive_calendar in varchar2,
                          p_ship_date in out nocopy date,
                          p_dock_date in out nocopy date,
                          p_due_date in out nocopy date);

 PROCEDURE IR_dates( p_plan_id in number,
                          p_inst_id in number,
                          p_transaction_id in number,
                          p_ship_date out nocopy date,
                          p_dock_date out nocopy date,
                          p_due_date out nocopy date);


FUNCTION wt_convert_ratio(p_item_id number, p_org_id number, p_inst_id number,
                p_uom_code varchar2) return number;
FUNCTION vl_convert_ratio(p_item_id number, p_org_id number, p_inst_id number,
                p_uom_code varchar2) return number;

FUNCTION sourcing_rule_name(p_plan_id number, p_item_id number,
                            p_from_org_id number, p_from_org_inst_id number,
                            p_to_org_id number, p_to_org_inst_id number,
                            p_rank number) return varchar2;

FUNCTION get_pref_key(p_plan_type number,
                      p_lookup_type varchar2, p_lookup_code number,
                      p_pref_tab varchar2) RETURN varchar2;


FUNCTION alloc_rule_name(p_rule_id number) return varchar2;

FUNCTION get_cal_violation(p_violated_calendars varchar2 )
                       return varchar2;

PROCEDURE update_supply_row(p_plan_id number,
                          p_transaction_id number,
                          p_shipment_id number,
                          p_firm_flag number,
                          p_ship_date date,
                          p_dock_date date,
                          p_ship_method varchar2,
                          p_lead_time number);

PROCEDURE mark_supply_undo(p_plan_id number);

FUNCTION notEqual(p_value number, p_value2 number) return boolean;
FUNCTION notEqual(p_value varchar2, p_value2 varchar2) return boolean;
FUNCTION notEqual(p_value date, p_value2 date) return boolean;
Function get_msg(p_product varchar2, p_name varchar2) RETURN varchar2;
FUNCTION get_iso_trip(p_plan_id number, p_instance_id number,
                      p_disposition_id number) return number;
FUNCTION forecast_name(p_plan_id number,p_instance_id number,p_org_id number,
                       p_schedule_designator_id number,p_forecast_set_id number)
  RETURN varchar2;
FUNCTION get_iso_name(p_plan_id number, p_instance_id number,
                      p_transaction_id number) return varchar2;
FUNCTION get_work_day(  p_next_or_prev          IN varchar2,
                        p_calendar_code         IN varchar2,
                        p_instance_id           IN number,
                        p_calendar_date         IN date) return date;

FUNCTION construct_list(p_id numberArr) RETURN varchar2;

FUNCTION related_excp(p_id numberArr,p_related_excp_type number,
                      p_plan_id number, p_org_id number,
                      p_inst_id number, p_item_id number,
                      p_start_date date, p_end_date date,
                      p_max_time number, p_min_time number,
                      p_lt_window number) RETURN numberArr;

FUNCTION rel_exp_where_clause(p_exc_type number,
                      p_plan_id number, p_org_id number,
                      p_inst_id number, p_item_id number,
                      p_source_org_id number, p_source_inst_id number,
                      p_supplier_id number, p_supply_id number,
                      p_demand_id number,
                      p_due_date date, p_dmd_satisfied_date date,
                      p_start_date date, p_end_date date) RETURN varchar2;

PROCEDURE update_exp_version(p_rowid rowid,
                             p_action_taken number);

PROCEDURE retrieve_exp_version(p_plan_id number);

END MSC_DRP_UTIL;

/
