--------------------------------------------------------
--  DDL for Package MSC_ANALYSIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ANALYSIS_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCANLSS.pls 120.2 2007/04/30 18:31:27 minduvad ship $  */

PROCEDURE populate_cost_savings(arg_ret_val IN  OUT NOCOPY VARCHAR2,
			arg_period_type IN VARCHAR2,
			arg_detail_level IN VARCHAR2,
			arg_viewby IN VARCHAR2,
			arg_plan_list IN VARCHAR2,
                        arg_org_list IN VARCHAR2 DEFAULT NULL,
			arg_category_list IN VARCHAR2 DEFAULT NULL,
                        arg_item_list IN VARCHAR2 DEFAULT NULL,
			arg_date_list IN DATE DEFAULT NULL,
			arg_round in NUMBER DEFAULT NULL);

PROCEDURE populate_srvlvl_breakdown(arg_ret_val IN  OUT NOCOPY VARCHAR2,
			arg_period_type IN VARCHAR2,
			arg_detail_level IN VARCHAR2,
			arg_viewby IN VARCHAR2,
			arg_plan_list IN VARCHAR2,
                        arg_org_list IN VARCHAR2 DEFAULT NULL,
			arg_category_list IN VARCHAR2 DEFAULT NULL,
                        arg_item_list IN VARCHAR2 DEFAULT NULL,
                        arg_demand_class_list IN VARCHAR2 DEFAULT NULL,
                        arg_year_from IN DATE DEFAULT NULL,
                        arg_year_to IN DATE DEFAULT NULL,
			arg_date_list IN DATE DEFAULT NULL,
			arg_round in NUMBER DEFAULT NULL);

PROCEDURE populate_cost_breakdown(arg_ret_val IN  OUT NOCOPY VARCHAR2,
			arg_period_type IN VARCHAR2,
			arg_detail_level IN VARCHAR2,
			arg_viewby IN VARCHAR2,
			arg_plan_list IN VARCHAR2,
                        arg_org_list IN VARCHAR2 DEFAULT NULL,
			arg_category_list IN VARCHAR2 DEFAULT NULL,
                        arg_item_list IN VARCHAR2 DEFAULT NULL,
                        arg_year_from IN DATE DEFAULT NULL,
                        arg_year_to IN DATE DEFAULT NULL,
			arg_date_list IN DATE DEFAULT NULL,
			arg_round in NUMBER DEFAULT NULL);

PROCEDURE populate_srvlvl_profit(arg_ret_val IN  OUT NOCOPY VARCHAR2,
			arg_period_type IN VARCHAR2,
			arg_viewby IN VARCHAR2,
			arg_plan_list IN VARCHAR2,
			arg_round in NUMBER DEFAULT NULL);

function get_tp_cost ( arg_period_type IN VARCHAR2, arg_detail_level IN VARCHAR2,
        arg_plan in number, arg_instance in number, arg_org in number,
        arg_item in number,  arg_detail_date date)  return number;

procedure store_user_pref (p_plan_type varchar2);

FUNCTION get_cat_set_id(arg_plan_list varchar2) RETURN NUMBER;

function get_plan_service_level(p_plan_id number, p_type number,
  p_instance_id in number default null, p_organization_id in number default null,
  p_item_id in number default null,
  p_start_date date default null, p_end_date date default null) return number;

function get_plan_dflt_value(p_plan_id number) return number;

FUNCTION get_num_periods(p_plan_id IN NUMBER, p_calendar_type IN NUMBER) RETURN NUMBER;

function get_dflt_value(p_plan_id number,
  p_cate_set_id  number default null,
  p_definition_level number default null,
  p_inst_id number default null, p_org_id number default null,
  p_item_id number default null,
  p_demand_class varchar2 default null,
  p_customer_id  number default null,
  p_customer_site_id  number default null,
  p_cate_id  number default null) return number;

END MSC_ANALYSIS_PKG;

/
