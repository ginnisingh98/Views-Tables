--------------------------------------------------------
--  DDL for Package PAY_JP_GENERIC_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_GENERIC_UPGRADE_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpgupg.pkh 120.6.12010000.1 2008/07/27 22:59:05 appldev ship $ */
--
function get_upgrade_status(
	p_upgrade_short_name	in varchar2,
	p_legislation_code	in varchar2) return varchar2;
--
function get_business_group_id(p_legislation_code in varchar2) return varchar2;
--
/*
procedure set_upgrade_completed(
	p_upgrade_short_name	in varchar2,
	p_legislation_code	in varchar2);
*/
--
procedure validate_pay_jp_pre_tax(p_valid_upgrade out nocopy varchar2);
--
procedure qualify_pay_jp_pre_tax(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2);
--
procedure upgrade_disaster_tax_reduction(p_assignment_id in number);
--
--
procedure validate_prev_job(p_valid_upgrade out nocopy varchar2);
--
procedure qualify_prev_job(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2);
--
procedure upgrade_prev_job(p_assignment_id in number);
--
function entries_or_results_exist(p_legislation_code in varchar2) return boolean;
function entries_or_results_exist(p_element_type_id in number) return boolean;
function entries_or_results_exist(p_assignment_id in number) return boolean;
function entries_or_results_exist(
	p_assignment_id		in number,
	p_element_type_id	in number) return boolean;
--
procedure sync_link_input_values(p_element_type_id in number);
procedure sync_entries_and_results(
	p_assignment_id		in number,
	p_element_type_id	in number);
--
procedure init_pay_a;
procedure validate_pay_a(p_valid_upgrade out nocopy varchar2);
procedure qualify_pay_a(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2);
procedure upgrade_pay_a(p_assignment_id in number);
--
procedure validate_itax_description(
	p_valid_upgrade out nocopy varchar2
);
procedure qualify_itax_description(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2
);
procedure upgrade_itax_description(
	p_assignment_id in number
);

procedure validate_code_jp_pre_tax(p_valid_upgrade out nocopy varchar2);

procedure qualifying_jp_pre_tax(
            p_assignment_id  in  number,
            p_qualifier      out nocopy varchar2);

procedure upgrade_jp_pre_tax(p_assignment_id in number);
--
procedure validate_yea_national_pens(
  p_valid_upgrade out nocopy varchar2);
--
procedure qualify_yea_national_pens(
  p_assignment_id in number,
  p_qualifier     out nocopy varchar2);
--
procedure upgrade_yea_national_pens(
  p_assignment_id in number);
--
--procedure init_yea_earthquake_ins;
procedure validate_yea_earthquake_ins(p_valid_upgrade out nocopy varchar2);
procedure qualify_yea_earthquake_ins(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2);
procedure upgrade_yea_earthquake_ins(p_assignment_id in number);
--
procedure validate_itw_archive(p_valid_upgrade out nocopy varchar2);
procedure qualify_itw_archive(
	p_assignment_id		in number,
	p_qualifier		out nocopy varchar2);
function to_canonical_date(p_str in varchar2) return varchar2;
procedure upgrade_itw_archive(p_assignment_id in number);
--
procedure qualify_hi_smr_data(
  p_assignment_id in number,
  p_qualifier     out nocopy varchar2);
procedure migrate_hi_smr_data(p_assignment_id in number);
--
procedure validate_adj_ann_std_bon(
  p_valid_upgrade out nocopy varchar2);
procedure qualify_adj_ann_std_bon(
  p_assignment_id in number,
  p_qualifier     out nocopy varchar2);
procedure upgrade_adj_ann_std_bon(
  p_assignment_id in number);
--
/*
function submit_request(
	p_legislation_code		in varchar2,
	p_upgrade_short_name		in varchar2,
	p_validate_procedure		in varchar2,
	p_application_short_name	in varchar2,
	p_concurrent_program_name	in varchar2) return number;
*/
--
end pay_jp_generic_upgrade_pkg;

/
