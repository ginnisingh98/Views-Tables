--------------------------------------------------------
--  DDL for Package PAY_KR_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_REPORT_PKG" AUTHID CURRENT_USER as
/* $Header: pykrrept.pkh 120.1 2005/07/28 23:34:40 mmark noship $ */
g_pre_get_balance_value_perf varchar2(1) := 'N';
g_pre_get_dbitem_value_perf varchar2(1) := 'N';
--------------------------------------------------------------------------------
function legislation_code(p_business_group_id in number) return varchar2;
--------------------------------------------------------------------------------
procedure pre_get_balance_value(p_business_group_id in number);
--------------------------------------------------------------------------------
procedure pre_get_dbitem_value(p_business_group_id in number);
--------------------------------------------------------------------------------
function get_defined_balance_id(p_balance_name      in varchar2,
                                p_dimension_name    in varchar2,
                                p_business_group_id in number) return number;
--------------------------------------------------------------------------------
function get_xbal_user_entity_id(p_defined_balance_id in number,
                                p_business_group_id  in number) return number;
--------------------------------------------------------------------------------
function get_user_entity_id(p_user_name         in varchar2,
                            p_business_group_id in number) return number;
--------------------------------------------------------------------------------
function get_xdbitem_user_entity_id(p_user_entity_id    in number,
                                    p_business_group_id in number) return number;
--------------------------------------------------------------------------------
function get_latest_assact(p_assignment_id       in number,
                           p_business_group_id   in number,
                           p_effective_date_from in date,
                           p_effective_date_to   in date,
                           p_type                in varchar2) return number;
--------------------------------------------------------------------------------
function get_balance_value_asg_run(p_assignment_action_id in number,
                                   p_balance_type_id      in number) return number;
--------------------------------------------------------------------------------
function get_archive_items(p_assignment_action_id in number,
                           p_user_entity_id       in number) return varchar2;
--------------------------------------------------------------------------------
function get_balance_value(p_assignment_action_id in number,
                           p_defined_balance_id in number) return varchar2;
--------------------------------------------------------------------------------
function get_balance_value(p_assignment_action_id in number,
                           p_balance_name in varchar2,
                           p_dimension_name in varchar2) return varchar2;
--------------------------------------------------------------------------------
function get_dbitem_value(p_assignment_action_id in number,
                          p_user_entity_id       in number) return varchar2;
--------------------------------------------------------------------------------
function get_dbitem_value(p_assignment_action_id in number,
                          p_user_name            in varchar2) return varchar2;
--------------------------------------------------------------------------------
function get_result_value_date(p_assignment_action_id in number,
                               p_business_group_id    in number,
                               p_element_type_name    in varchar2,
                               p_input_value_name     in varchar2) return date;
--------------------------------------------------------------------------------
function get_result_value_date(p_assignment_action_id in number,
                               p_business_group_id    in number,
                               p_element_type_id      in number,
                               p_input_value_id       in number) return date;
--------------------------------------------------------------------------------
function get_result_value_number(p_assignment_action_id in number,
                                 p_business_group_id    in number,
                                 p_element_type_name    in varchar2,
                                 p_input_value_name     in varchar2) return number;
--------------------------------------------------------------------------------
function get_result_value_number(p_assignment_action_id in number,
                                 p_business_group_id    in number,
                                 p_element_type_id      in number,
                                 p_input_value_id       in number) return number;
--------------------------------------------------------------------------------
function get_result_value_char(p_assignment_action_id in number,
                               p_business_group_id    in number,
                               p_element_type_name    in varchar2,
                               p_input_value_name     in varchar2) return varchar2;
--------------------------------------------------------------------------------
function get_result_value_char(p_assignment_action_id in number,
                               p_business_group_id    in number,
                               p_element_type_id      in number,
                               p_input_value_id       in number) return varchar2;
--------------------------------------------------------------------------------
function get_result_value(p_run_result_id 	in	pay_run_results.run_result_id%type,
			  p_input_value_id	in	pay_input_values_f.input_value_id%type) return varchar2 ;
--------------------------------------------------------------------------------
end pay_kr_report_pkg;

 

/
