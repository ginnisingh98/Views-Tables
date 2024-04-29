--------------------------------------------------------
--  DDL for Package PAY_JP_LTAX_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_LTAX_IMP_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpltxi.pkh 120.0.12010000.1 2009/06/24 07:04:18 keyazawa noship $ */
--
c_char_set varchar2(30) := 'JA16SJIS';
c_file_prefix varchar2(6) := 'ltax';
c_file_spliter varchar2(1) := '_';
c_file_extension varchar2(4) := '.csv';
c_asg_set_prefix varchar2(30) := 'REQUEST_ID_';
--
c_def_val varchar2(1000) := to_char(hr_api.g_number);
c_value_if_null_tbl constant pay_jp_bee_utility_pkg.t_varchar2_tbl
  := pay_jp_bee_utility_pkg.entry_value_tbl(
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val,
    c_def_val);
--
g_request_id number;
g_business_group_id number;
g_effective_yyyymm varchar2(6);
g_effective_som date;
g_effective_eom date;
g_effective_soy date;
g_effective_eoy date;
g_upload_date date;
g_session_date date;
g_district_code per_addresses.town_or_city%type;
g_organization_id number;
g_assignment_set_id number;
g_ass_set_formula_id number;
g_ass_set_amendment_type hr_assignment_set_amendments.include_or_exclude%type;
g_file_dir fnd_concurrent_processes.plsql_dir%type;
g_action_if_exists varchar2(1);
g_reject_if_future_changes varchar2(1);
g_create_entry_if_not_exist varchar2(1);
g_create_asg_set_for_errored varchar2(1);
g_payroll_id number;
g_err_ass_set_id number;
g_err_ass_set_name hr_assignment_sets.assignment_set_name%type;
--
g_file_prefix    varchar2(30);
g_file_suffix    varchar2(30);
g_file_extension varchar2(30);
--
g_file_split      varchar2(1) := 'Y';
g_datetrack_eev   varchar2(1) := 'N';
g_valid_term_flag varchar2(1) := 'Y';
--
g_show_dup_file    varchar2(1) := 'N';
g_show_no_file     varchar2(1) := 'N';
g_valid_diff_ltax  varchar2(1) := 'N';
g_valid_incon_data varchar2(1) := 'N';
g_show_incon_data  varchar2(1) := 'N';
g_valid_non_res    varchar2(1) := 'N';
g_valid_dup_ass    varchar2(1) := 'N';
g_show_upd_eev     varchar2(1) := 'N';
g_valid_no_upd     varchar2(1) := 'Y';
g_show_no_upd      varchar2(1) := 'N';
g_valid_sp_with    varchar2(1) := 'Y';
g_valid_inv_ass    varchar2(1) := 'Y';
--
g_show_data    varchar2(1) := 'N';
g_detail_debug varchar2(1) := 'N';
g_detail_eev   varchar2(1) := 'Y';
--
procedure set_file_prefix(
  p_file_prefix in varchar2);
--
procedure set_file_suffix(
  p_file_suffix in varchar2);
--
procedure set_file_extension(
  p_file_extension in varchar2);
--
procedure set_file_split(
  p_file_split in varchar2);
--
procedure set_datetrack_eev(
  p_datetrack_eev in varchar2);
--
procedure set_detail_debug(
  p_yn in varchar2);
--
procedure init(
  p_business_group_id          in number,
  p_subject_yyyymm             in varchar2,
  p_upload_date                in date,
  p_organization_id            in number,
  p_district_code              in varchar2,
  p_assignment_set_id          in number,
  p_file_suffix                in varchar2,
  p_file_split                 in varchar2,
  p_datetrack_eev              in varchar2,
  p_show_dup_file              in varchar2,
  p_show_no_file               in varchar2,
  p_valid_diff_ltax            in varchar2,
  p_valid_incon_data           in varchar2,
  p_show_incon_data            in varchar2,
  p_valid_non_res              in varchar2,
  p_valid_dup_ass              in varchar2,
  p_show_upd_eev               in varchar2,
  p_valid_no_upd               in varchar2,
  p_show_no_upd                in varchar2,
  p_valid_sp_with              in varchar2,
  p_action_if_exists           in varchar2,
  p_reject_if_future_changes   in varchar2,
  p_create_entry_if_not_exist  in varchar2,
  p_create_asg_set_for_errored in varchar2);
--
procedure transfer_imp_ltax_info_to_bee(
  p_errbuf                     out nocopy varchar2,
  p_retcode                    out nocopy varchar2,
  p_business_group_id          in number,
  p_subject_yyyymm             in varchar2,
  p_upload_date                in varchar2,
  p_batch_name                 in varchar2,
  p_action_if_exists           in varchar2,
  p_reject_if_future_changes   in varchar2,
  p_date_effective_changes     in varchar2,
  p_purge_after_transfer       in varchar2,
  p_create_entry_if_not_exist  in varchar2,
  p_create_asg_set_for_errored in varchar2,
  p_organization_id            in number,
  p_district_code              in varchar2,
  p_assignment_set_id          in number,
  p_file_suffix                in varchar2,
  p_file_split                 in varchar2,
  p_datetrack_eev              in varchar2,
  p_valid_diff_ltax            in varchar2,
  p_valid_incon_data           in varchar2,
  p_valid_non_res              in varchar2,
  p_valid_dup_ass              in varchar2,
  p_valid_no_upd               in varchar2,
  p_valid_sp_with              in varchar2,
  p_show_dup_file              in varchar2 default 'N',
  p_show_no_file               in varchar2 default 'N',
  p_show_incon_data            in varchar2 default 'N',
  p_show_upd_eev               in varchar2 default 'N',
  p_show_no_upd                in varchar2 default 'N');
--
end pay_jp_ltax_imp_pkg;

/
