--------------------------------------------------------
--  DDL for Package PAY_CORE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CORE_UTILS" AUTHID CURRENT_USER as
/* $Header: pycorutl.pkh 120.7.12010000.2 2008/10/01 06:12:55 ankagarw ship $ */
--
g_cache_business_group BOOLEAN;
g_business_group_id PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;

    type date_array is table of date index by binary_integer;
    type char_array is table of varchar(30) index by binary_integer;
--
-- Set up the types to hold the dynamic contexts details.
--
type t_contexts_rec is record
(context_name        ff_contexts.context_name%type,
 is_context_def      boolean,
 input_value_name    pay_input_values_f.name%type,
 default_plsql       varchar2(60)
);
--
type t_contexts_tab is table of t_contexts_rec index by binary_integer;
--
-- Set up the types to hold the dynamic sql statements.
--
type t_sql_stm_rec is record
(statement           varchar2(1000),
 sql_cur             number
);
--
type t_sql_stm_tab is table of t_sql_stm_rec index by binary_integer;
--
function get_sql_cursor(p_statement  in    varchar2,
                        p_sql_cur    out nocopy   number) return boolean;
--
procedure close_all_sql_cursors;
procedure close_sql_cursor(p_sql_cur in    number);
--
g_sql_cursors t_sql_stm_tab;
--
--
------------------------------ get_parameter -------------------------------
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
------------------------------ remove_parameter -------------------------------
function remove_parameter(p_name in varchar2,
                       p_parameter_list varchar2) return varchar2;

function get_business_group (p_statement varchar2) return number;
function get_dyt_business_group (p_statement varchar2) return number;
function get_legislation_code (p_bg_id number) return varchar2;
procedure reset_cached_values;
procedure get_time_definition(p_element_entry in            number,
                              p_asg_act_id    in            number,
                              p_time_def_id      out nocopy number);
function get_time_period_start(p_payroll_action_id in number
                               ) return date;
function get_entry_end_date(p_element_type_id in number,
                            p_payroll_action_id in number,
                            p_assignment_action_id in number,
                            p_date_earned in date   ) return date;
procedure get_prorated_dates(p_ee_id         in            number,
                             p_asg_act_id    in            number,
                             p_time_def_type in            varchar2,
                             p_time_def_id   in out nocopy number,
                             p_date_array       out nocopy char_array,
                             p_type_array       out nocopy char_array
                            );
procedure set_prorate_dates(p_et_id      in number,
                             p_asg_act_id in number,
                             p_date_array in char_array,
                             p_type_array in char_array,
                             p_arr_cnt    in number,
                             p_prd_end    out nocopy varchar2,
                             p_start_date out nocopy varchar2,
                             p_end_date   out nocopy varchar2
                            );
procedure get_rr_id( p_rr_id_list out nocopy varchar2);
procedure get_aa_id( p_aa_id_list out nocopy varchar2);
procedure get_rb_id( p_rb_id_list out nocopy varchar2);
procedure push_message(p_applid in number,
                       p_msg_name in varchar2,
                       p_level in varchar2
                      );
procedure push_message(p_applid in number,
                       p_msg_name in varchar2,
                       p_msg_txt in varchar2,
                       p_level in varchar2
                      );
procedure push_token(
                     p_tok_name in varchar2,
                     p_tok_value in varchar2
                    );
procedure pop_message(
                       p_msg_text out nocopy varchar2
                      );
procedure pop_message(
                       p_msg_text out nocopy varchar2,
                       p_sev_level out nocopy varchar2
                      );
procedure mesg_stack_error_hdlr(p_pactid in number);

function get_pp_action_id(p_action_type in varchar2,
                          p_action_id   in number) return number;
function include_action_in_payment(p_calling_action_type in varchar2,
                                   p_calling_action_id   in number,
                                   p_run_action_id       in number
                                  ) return varchar2;
procedure set_pap_group_id(p_pap_group_id in number);
function  get_pap_group_id return number;
pay_action_parameter_group_id number;
procedure get_action_parameter(p_para_name   in         varchar2,
                               p_para_value  out nocopy varchar2,
                               p_found       out nocopy boolean
                              );
procedure get_report_f_parameter(
                               p_payroll_action_id in   number,
                               p_para_name   in         varchar2,
                               p_para_value  out nocopy varchar2,
                               p_found       out nocopy boolean
                              );
procedure get_legislation_rule(p_legrul_name   in         varchar2,
                               p_legislation   in         varchar2,
                               p_legrul_value  out nocopy varchar2,
                               p_found         out nocopy boolean
                              );
procedure unset_context_iv_cache;
procedure get_leg_context_iv_name(p_context_name   in         varchar2,
                                  p_legislation    in         varchar2,
                                  p_inp_val_name   out nocopy varchar2,
                                  p_found          out nocopy boolean
                                 );
procedure get_dynamic_contexts(p_business_group_id in            number,
                               p_context_list         out nocopy t_contexts_tab
                              );
function check_ctx_set (p_ee_id      in number,
                        p_context_name in varchar2,
                        p_context_value in varchar2
                       ) return varchar2;
procedure assert_condition (p_location  in varchar2,
                            p_condition in boolean);
function get_process_path(p_asg_action_id in number)
 return varchar2;
procedure get_upgrade_status(p_bus_grp_id in            number,
                             p_short_name in            varchar2,
                             p_status        out nocopy varchar2,
                             p_raise_error in           boolean default TRUE);
function get_upgrade_status(p_bus_grp_id in            number,
                            p_short_name in            varchar2,
                            p_raise_error in           varchar2 default 'TRUE')
 return varchar2;

function getprl(p_pactid in number) return varchar2;
function get_context_iv_name (p_asg_act_id in number,
                              p_context	   in varchar2)
return varchar2;

function is_element_included (p_element_type_id   in number,
                              p_run_type_id       in number,
                              p_effective_date    in date,
                              p_business_group_id in number,
                              p_legislation       in varchar2,
                              p_label             in varchar)
return varchar2;
end pay_core_utils;

/
