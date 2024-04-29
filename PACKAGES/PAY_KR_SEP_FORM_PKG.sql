--------------------------------------------------------
--  DDL for Package PAY_KR_SEP_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_SEP_FORM_PKG" AUTHID CURRENT_USER as
/* $Header: pykrsepf.pkh 120.1 2006/09/29 11:54:04 vaisriva noship $ */
--
-- Exception Handlers
--
zero_req_id exception;
pragma exception_init(zero_req_id, -9999);
--------------------------------------------------------------------------------
function get_run_type_name(p_run_type_id    in number,
                           p_effective_date in date) return varchar2;
--------------------------------------------------------------------------------
function get_kr_d_address_line1(p_address_line1 in varchar2) return varchar2;
--------------------------------------------------------------------------------
procedure process_run(p_payroll_id           in number,
                      p_consolidation_set_id in number,
                      p_earned_date          in varchar2,
                      p_date_paid            in varchar2,
                      p_ele_set_id           in number,
                      p_assignment_set_id    in number,
                      p_run_type_id          in number,
                      p_leg_params           in varchar2,
		      p_payout_date	     in varchar2,
                      p_req_id               in out NOCOPY number,
                      p_success              out NOCOPY boolean,
                      errbuf                 out NOCOPY varchar2);
--------------------------------------------------------------------------------
procedure archive_run(p_business_group_id    in number,
                      p_start_date           in varchar2,
                      p_effective_date       in varchar2,
                      p_payroll_id           in number,
                      p_payroll_id_hd        in varchar2,
                      p_req_id               in out NOCOPY number,
                      p_success              out NOCOPY boolean,
                      errbuf                 out NOCOPY varchar2);
--------------------------------------------------------------------------------
procedure delete_action(p_source_action_id in number,
                        p_dml_mode             in varchar2); /* NO_COMMIT, NONE, FULL */
--------------------------------------------------------------------------------
procedure lock_action(p_source_action_id in number);
--------------------------------------------------------------------------------
procedure find_dt_upd_modes(
  p_effective_date       in         date,
  p_base_key_value       in         number,
  p_correction           out NOCOPY boolean,
  p_update               out NOCOPY boolean,
  p_update_override      out NOCOPY boolean,
  p_update_change_insert out NOCOPY boolean);
--------------------------------------------------------------------------------
procedure find_dt_del_modes(
  p_effective_date     in date,
  p_base_key_value     in number,
  p_zap                out NOCOPY boolean,
  p_delete             out NOCOPY boolean,
  p_future_change      out NOCOPY boolean,
  p_delete_next_change out NOCOPY boolean);
--------------------------------------------------------------------------------
procedure lock_element_entry(
  p_effective_date        in  date,
  p_datetrack_mode        in  varchar2,
  p_element_entry_id      in  number,
  p_object_version_number in  number,
  p_validation_start_date out NOCOPY date,
  p_validation_end_date	  out NOCOPY date);
--------------------------------------------------------------------------------
procedure insert_element_entry(
  p_validate          in boolean default false,
  p_assignment_id     in number,
  p_business_group_id in number,
  p_effective_date    in date,
  p_element_link_id   in number,
  p_input_value_id1   in number default null,
  p_input_value_id2   in number default null,
  p_input_value_id3   in number default null,
  p_input_value_id4   in number default null,
  p_input_value_id5   in number default null,
  p_input_value_id6   in number default null,
  p_input_value_id7   in number default null,
  p_input_value_id8   in number default null,
  p_input_value_id9   in number default null,
  p_input_value_id10  in number default null,
  p_input_value_id11  in number default null,
  p_input_value_id12  in number default null,
  p_input_value_id13  in number default null,
  p_input_value_id14  in number default null,
  p_input_value_id15  in number default null,
  p_entry_value1      in varchar2 default null,
  p_entry_value2      in varchar2 default null,
  p_entry_value3      in varchar2 default null,
  p_entry_value4      in varchar2 default null,
  p_entry_value5      in varchar2 default null,
  p_entry_value6      in varchar2 default null,
  p_entry_value7      in varchar2 default null,
  p_entry_value8      in varchar2 default null,
  p_entry_value9      in varchar2 default null,
  p_entry_value10     in varchar2 default null,
  p_entry_value11     in varchar2 default null,
  p_entry_value12     in varchar2 default null,
  p_entry_value13     in varchar2 default null,
  p_entry_value14     in varchar2 default null,
  p_entry_value15     in varchar2 default null,
  p_element_entry_id      out NOCOPY number,
  p_effective_start_date  out NOCOPY date,
  p_effective_end_date    out NOCOPY date,
  p_object_version_number out NOCOPY number);
--------------------------------------------------------------------------------
procedure update_element_entry(
  p_validate              in boolean default false,
  p_dt_update_mode        in varchar2, /* UPDATE,UPDATE_CHANGE_INSERT,UPDATE_OVERRIDE,CORRECTION */
  p_effective_date        in date,
  p_business_group_id     in number,
  p_element_entry_id      in number,
  p_object_version_number in out NOCOPY number,
  p_input_value_id1       in number default null,
  p_input_value_id2       in number default null,
  p_input_value_id3       in number default null,
  p_input_value_id4       in number default null,
  p_input_value_id5       in number default null,
  p_input_value_id6       in number default null,
  p_input_value_id7       in number default null,
  p_input_value_id8       in number default null,
  p_input_value_id9       in number default null,
  p_input_value_id10      in number default null,
  p_input_value_id11      in number default null,
  p_input_value_id12      in number default null,
  p_input_value_id13      in number default null,
  p_input_value_id14      in number default null,
  p_input_value_id15      in number default null,
  p_entry_value1          in varchar2 default null,
  p_entry_value2          in varchar2 default null,
  p_entry_value3          in varchar2 default null,
  p_entry_value4          in varchar2 default null,
  p_entry_value5          in varchar2 default null,
  p_entry_value6          in varchar2 default null,
  p_entry_value7          in varchar2 default null,
  p_entry_value8          in varchar2 default null,
  p_entry_value9          in varchar2 default null,
  p_entry_value10         in varchar2 default null,
  p_entry_value11         in varchar2 default null,
  p_entry_value12         in varchar2 default null,
  p_entry_value13         in varchar2 default null,
  p_entry_value14         in varchar2 default null,
  p_entry_value15         in varchar2 default null,
  p_effective_start_date  out NOCOPY date,
  p_effective_end_date    out NOCOPY date);
------------------------------------------------------------------------------
procedure delete_element_entry(
  p_validate              in boolean default false,
  p_dt_delete_mode        in varchar2, /* DELETE,ZAP,DELETE_NEXT_CHANGE,FUTURE_CHANGE */
  p_effective_date        in date,
  p_element_entry_id      in number,
  p_object_version_number in out NOCOPY number,
  p_effective_start_date  out NOCOPY date,
  p_effective_end_date    out NOCOPY date);
--------------------------------------------------------------------------------
procedure chk_entry(
  p_element_entry_id      in number,
  p_assignment_id         in number,
  p_element_link_id       in number,
  p_entry_type            in varchar2,
  p_original_entry_id     in number default null,
  p_target_entry_id       in number default null,
  p_effective_date        in date,
  p_validation_start_date in date,
  p_validation_end_date   in date,
  p_effective_start_date  in out NOCOPY date,
  p_effective_end_date    in out NOCOPY date,
  p_usage                 in varchar2,
  p_dt_update_mode        in varchar2,
  p_dt_delete_mode        in varchar2);
--------------------------------------------------------------------------------
procedure chk_formula(
  p_formula_id        in  number,
  p_entry_value       in  varchar2,
  p_business_group_id in  number,
  p_assignment_id     in  number,
  p_date_earned       in  date,
  p_formula_status    out NOCOPY varchar2,
  p_formula_message   out NOCOPY varchar2);
--------------------------------------------------------------------------------
procedure validate_entry_value(
  p_element_link_id	  in     number,
  p_input_value_id	  in     number,
  p_effective_date	  in     date,
  p_business_group_id in         number,
  p_assignment_id     in         number,
  p_user_value        in out NOCOPY varchar2,
  p_canonical_value   out    NOCOPY varchar2,
  p_hot_defaulted     out    NOCOPY boolean,
  p_min_max_warning   out    NOCOPY boolean,
  p_user_min_value    out    NOCOPY varchar2,
  p_user_max_value    out    NOCOPY varchar2,
  p_formula_warning   out    NOCOPY boolean,
  p_formula_message   out    NOCOPY varchar2);
--------------------------------------------------------------------------------
function get_session_date return date;
--------------------------------------------------------------------------------
function get_element_type_id(
  p_element_name       in varchar2,
  p_business_group_id  in number,
  p_effective_date     in date) return number;
--------------------------------------------------------------------------------
function get_input_value_id(
  p_element_type_id         in number,
  p_sequence                in number,
  p_business_group_id       in number,
  p_effective_date          in date default null) return number;
--------------------------------------------------------------------------------
function get_input_value_name(
  p_element_type_id         in number,
  p_sequence                in number,
  p_business_group_id       in number,
  p_effective_date          in date default null) return varchar2;
--------------------------------------------------------------------------------
function get_input_value_d_sequence(
  p_element_type_id         in number,
  p_sequence                in number,
  p_business_group_id       in number,
  p_effective_date          in date default null) return number;
--------------------------------------------------------------------------------
function get_input_value_lookup_type(
  p_element_type_id         in number,
  p_sequence                in number,
  p_business_group_id       in number,
  p_effective_date          in date default null) return varchar2;
--------------------------------------------------------------------------------
function get_input_value_mandatory(
  p_element_type_id         in number,
  p_sequence                in number,
  p_business_group_id       in number,
  p_effective_date          in date default null) return varchar2;
--------------------------------------------------------------------------------
procedure get_default_value(
  p_assignment_id	 in  number,
  p_element_type_id      in  number,
  p_business_group_id	 in  varchar2,
  p_entry_type           in  varchar2 default 'E',
  p_effective_date	 in  date,
  p_element_link_id	 out NOCOPY number,
  p_input_value_id1      out NOCOPY number,
  p_input_value_id2      out NOCOPY number,
  p_input_value_id3      out NOCOPY number,
  p_input_value_id4      out NOCOPY number,
  p_input_value_id5      out NOCOPY number,
  p_input_value_id6      out NOCOPY number,
  p_input_value_id7      out NOCOPY number,
  p_input_value_id8      out NOCOPY number,
  p_input_value_id9      out NOCOPY number,
  p_input_value_id10     out NOCOPY number,
  p_input_value_id11     out NOCOPY number,
  p_input_value_id12     out NOCOPY number,
  p_input_value_id13     out NOCOPY number,
  p_input_value_id14     out NOCOPY number,
  p_input_value_id15     out NOCOPY number,
  p_default_value1       out NOCOPY varchar2,
  p_default_value2       out NOCOPY varchar2,
  p_default_value3       out NOCOPY varchar2,
  p_default_value4       out NOCOPY varchar2,
  p_default_value5       out NOCOPY varchar2,
  p_default_value6       out NOCOPY varchar2,
  p_default_value7       out NOCOPY varchar2,
  p_default_value8       out NOCOPY varchar2,
  p_default_value9       out NOCOPY varchar2,
  p_default_value10      out NOCOPY varchar2,
  p_default_value11      out NOCOPY varchar2,
  p_default_value12      out NOCOPY varchar2,
  p_default_value13      out NOCOPY varchar2,
  p_default_value14      out NOCOPY varchar2,
  p_default_value15      out NOCOPY varchar2,
  p_b_default_value1     out NOCOPY varchar2,
  p_b_default_value2     out NOCOPY varchar2,
  p_b_default_value3     out NOCOPY varchar2,
  p_b_default_value4     out NOCOPY varchar2,
  p_b_default_value5     out NOCOPY varchar2,
  p_b_default_value6     out NOCOPY varchar2,
  p_b_default_value7     out NOCOPY varchar2,
  p_b_default_value8     out NOCOPY varchar2,
  p_b_default_value9     out NOCOPY varchar2,
  p_b_default_value10    out NOCOPY varchar2,
  p_b_default_value11    out NOCOPY varchar2,
  p_b_default_value12    out NOCOPY varchar2,
  p_b_default_value13    out NOCOPY varchar2,
  p_b_default_value14    out NOCOPY varchar2,
  p_b_default_value15    out NOCOPY varchar2,
  p_effective_start_date in out NOCOPY date,
  p_effective_end_date	 in out NOCOPY date);
--------------------------------------------------------------------------------
function get_screen_entry_value(
  p_element_type_id         in number,
  p_sequence                in number,
  p_business_group_id       in number,
  p_ee_element_entry_id     in number,
  p_ee_effective_start_date in date,
  p_ee_effective_end_date   in date) return varchar2;
--------------------------------------------------------------------------------
function get_entry_value(
  p_element_type_id         in number,
  p_sequence                in number,
  p_business_group_id       in number,
  p_ee_element_entry_id     in number,
  p_ee_effective_start_date in date,
  p_ee_effective_end_date   in date,
  p_el_element_link_id      in number) return varchar2;
-------------------------------------------------------------------------------------------------------------+
--
-- Bug# 2425705
-- Added function get_employee_status,procedures create_entries and create_entry_for_assignment
-- to enhance the function of PAYKRSEP.fmb.
-- Added a pl/sql table to hold assignment_id's.
-------------------------------------------------------------------------------------------------------------+
type assignment_id_tbl is table of pay_assignment_actions.assignment_id%type index by binary_integer;
g_assignment_id_tbl assignment_id_tbl;
-------------------------------------------------------------------------------------------------------------+
procedure create_entries(
  p_assignment_id_tbl  in g_assignment_id_tbl%type,
  p_element_set_id     in pay_element_type_rules.element_set_id%type,
  p_run_type_id        in pay_run_types.run_type_id%type,
  p_business_group_id  in hr_assignment_sets.business_group_id%type,
  p_session_date       in date);
-------------------------------------------------------------------------------------------------------------+
procedure create_entries(
  p_assignment_set_id  in hr_assignment_sets.assignment_set_id%type,
  p_element_set_id     in pay_element_type_rules.element_set_id%type,
  p_run_type_id        in pay_run_types.run_type_id%type,
  p_business_group_id  in hr_assignment_sets.business_group_id%type,
  p_payroll_id         in hr_assignment_sets.payroll_id%type,
  p_session_date       in date);
-------------------------------------------------------------------------------------------------------------+
procedure create_entry_for_assignment(
  p_assignment_id         in pay_assignment_actions.assignment_id%type,
  p_element_type_id       in pay_element_types.element_type_id%type,
  p_business_group_id     in pay_element_types.business_group_id%type,
  p_entry_type            in pay_element_entries_f.entry_type%type,
  p_effective_date        in date,
  p_effective_start_date  in out NOCOPY date,
  p_effective_end_date    in out NOCOPY date,
  p_element_entry_id      out NOCOPY pay_element_entries_f.element_entry_id%type,
  p_object_version_number out NOCOPY number);
-------------------------------------------------------------------------------------------------------------+
function get_employee_status(
  p_assignment_id in pay_assignment_actions.assignment_id%type,
  p_run_type_name in pay_run_types.run_type_name%type,
  p_date_earned   in date) return varchar2;
-------------------------------------------------------------------------------------------------------------+
-- Bug# 2425705
-------------------------------------------------------------------------------------------------------------+
end pay_kr_sep_form_pkg;

/
