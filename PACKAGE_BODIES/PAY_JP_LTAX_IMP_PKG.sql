--------------------------------------------------------
--  DDL for Package Body PAY_JP_LTAX_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_LTAX_IMP_PKG" as
/* $Header: pyjpltxi.pkb 120.0.12010000.4 2009/09/10 02:41:41 keyazawa noship $ */
--
c_package  constant varchar2(30) := 'pay_jp_ltax_imp_pkg.';
g_debug    boolean := hr_utility.debug_enabled;
--
c_com_ltx_info_elm  constant varchar2(80) := 'COM_LTX_INFO';
c_com_itx_info_elm  constant varchar2(80) := 'COM_ITX_INFO';
c_itx_org_iv        constant varchar2(80) := 'WITHHOLD_AGENT';
c_non_res_iv        constant varchar2(80) := 'NRES_FLAG';
c_com_nres_info_elm constant varchar2(80) := 'COM_NRES_INFO';
c_non_res_date_iv   constant varchar2(80) := 'NRES_START_DATE';
c_res_date_iv       constant varchar2(80) := 'PROJECTED_RES_DATE';
--
c_com_ltx_info_elm_id  constant number := hr_jp_id_pkg.element_type_id(c_com_ltx_info_elm,null,'JP');
c_com_itx_info_elm_id  constant number := hr_jp_id_pkg.element_type_id(c_com_itx_info_elm,null,'JP');
c_itx_org_iv_id        constant number := hr_jp_id_pkg.input_value_id(c_com_itx_info_elm_id,c_itx_org_iv);
c_non_res_iv_id        constant number := hr_jp_id_pkg.input_value_id(c_com_itx_info_elm_id,c_non_res_iv);
c_com_nres_info_elm_id constant number := hr_jp_id_pkg.element_type_id(c_com_nres_info_elm,null,'JP');
c_non_res_date_iv_id   constant number := hr_jp_id_pkg.input_value_id(c_com_nres_info_elm_id,c_non_res_date_iv);
c_res_date_iv_id       constant number := hr_jp_id_pkg.input_value_id(c_com_nres_info_elm_id,c_res_date_iv);
--
type t_file_rec is record(
  file_name varchar2(80),
  file_out utl_file.file_type);
type t_file_tbl is table of t_file_rec index by binary_integer;
g_file_tbl t_file_tbl;
g_file_tbl_cnt number;
--
type t_data_rec is record(
  file_id            number,
  line               number,
  i_swot_number      pay_jp_swot_numbers.swot_number%type,
  i_personal_number  pay_element_entry_values_f.screen_entry_value%type,
  i_employee_number  per_all_people_f.employee_number%type,
  i_address          varchar2(800),
  i_address_kana     varchar2(800),
  i_full_name        varchar2(400),
  i_full_name_kana   varchar2(400),
  i_sp_ltax          number,
  i_ltax_6           number,
  i_ltax_7           number,
  i_ltax_8           number,
  i_ltax_9           number,
  i_ltax_10          number,
  i_ltax_11          number,
  i_ltax_12          number,
  i_ltax_1           number,
  i_ltax_2           number,
  i_ltax_3           number,
  i_ltax_4           number,
  i_ltax_5           number,
  i_district_code    per_addresses.town_or_city%type,
  assignment_id      number,
  assignment_number  per_all_assignments_f.assignment_number%type);
type t_data_tbl is table of t_data_rec index by binary_integer;
g_imp_data_tbl t_data_tbl;
g_imp_data_tbl_cnt number;
g_ass_data_tbl t_data_tbl;
--
type t_num_tbl is table of number index by binary_integer;
g_ass_id_tbl t_num_tbl;
g_ass_id_tbl_cnt number;
--
type t_ass_rec is record(
  assignment_id number,
  payroll_id number,
  assignment_number per_all_assignments_f.assignment_number%type,
  final_process_date date);
type t_ass_tbl is table of t_ass_rec index by binary_integer;
g_ass_ind_tbl t_ass_tbl;
--
type t_ass_amd_rec is record(
  assignment_id number,
  assignment_number per_all_assignments_f.assignment_number%type,
  include_or_exclude hr_assignment_set_amendments.include_or_exclude%type);
type t_ass_amd_tbl is table of t_ass_amd_rec index by binary_integer;
g_ass_amd_ind_tbl t_ass_amd_tbl;
--
type t_imp_file_rec is record(
  district_code per_addresses.town_or_city%type,
  organization_id number,
  swot_number pay_jp_swot_numbers.swot_number%type,
  input_file_name pay_jp_swot_numbers.input_file_name%type);
type t_imp_file_tbl is table of t_imp_file_rec index by binary_integer;
g_imp_file_ind_tbl t_imp_file_tbl;
--
type t_mth_rec is record(
  payroll_id      number,
  mth_cnt         number,
  payment_date_1  date,
  payment_date_2  date,
  payment_date_3  date,
  payment_date_4  date,
  payment_date_5  date,
  payment_date_6  date,
  payment_date_7  date,
  payment_date_8  date,
  payment_date_9  date,
  payment_date_10 date,
  payment_date_11 date,
  payment_date_12 date,
  upload_date_1   date,
  upload_date_2   date,
  upload_date_3   date,
  upload_date_4   date,
  upload_date_5   date,
  upload_date_6   date,
  upload_date_7   date,
  upload_date_8   date,
  upload_date_9   date,
  upload_date_10  date,
  upload_date_11  date,
  upload_date_12  date);
type t_mth_tbl is table of t_mth_rec index by binary_integer;
g_mth_tbl t_mth_tbl;
--
type t_ee_rec is record(
  period_year number,
  period_num  number,
  upload_date date);
type t_ee_tbl is table of t_ee_rec index by binary_integer;
g_ee_tbl t_ee_tbl;
--
type t_wng_tbl is table of varchar2(2000) index by binary_integer;
g_dup_file_wng_tbl t_wng_tbl;
g_dup_file_wng_tbl_cnt number;
g_no_file_wng_tbl t_wng_tbl;
g_no_file_wng_tbl_cnt number;
g_diff_ltax_wng_tbl t_wng_tbl;
g_diff_ltax_wng_tbl_cnt number;
g_inv_data_wng_tbl t_wng_tbl;
g_inv_data_wng_tbl_cnt number;
g_incon_data_wng_tbl t_wng_tbl;
g_incon_data_wng_tbl_cnt number;
g_no_ass_wng_tbl t_wng_tbl;
g_no_ass_wng_tbl_cnt number;
g_non_res_wng_tbl t_wng_tbl;
g_non_res_wng_tbl_cnt number;
g_dup_ass_wng_tbl t_wng_tbl;
g_dup_ass_wng_tbl_cnt number;
g_upd_eev_wng_tbl t_wng_tbl;
g_upd_eev_wng_tbl_cnt number;
g_no_upd_wng_tbl t_wng_tbl;
g_no_upd_wng_tbl_cnt number;
g_sp_with_wng_tbl t_wng_tbl;
g_sp_with_wng_tbl_cnt number;
g_inv_ass_wng_tbl t_wng_tbl;
g_inv_ass_wng_tbl_cnt number;
--
-- -------------------------------------------------------------------------
-- insert_session
-- -------------------------------------------------------------------------
procedure insert_session(
  p_effective_date in date)
is
begin
--
  insert into fnd_sessions(
    session_id,
    effective_date)
  select
    userenv('sessionid'),
    p_effective_date
  from dual
  where not exists(
    select null
    from   fnd_sessions
    where  session_id = userenv('sessionid')
    and    effective_date = p_effective_date);
--
	commit;
--
end insert_session;
--
-- -------------------------------------------------------------------------
-- delete_session
-- -------------------------------------------------------------------------
procedure delete_session
is
begin
--
  delete from fnd_sessions
  where	session_id = userenv('sessionid');
--
	commit;
--
end delete_session;
--
-- -------------------------------------------------------------------------
-- set_file_prefix
-- -------------------------------------------------------------------------
procedure set_file_prefix(
  p_file_prefix in varchar2)
is
begin
--
  pay_jp_ltax_imp_pkg.g_file_prefix := p_file_prefix;
--
end set_file_prefix;
--
-- -------------------------------------------------------------------------
-- set_file_suffix
-- -------------------------------------------------------------------------
procedure set_file_suffix(
  p_file_suffix in varchar2)
is
begin
--
  pay_jp_ltax_imp_pkg.g_file_suffix := p_file_suffix;
--
end set_file_suffix;
--
-- -------------------------------------------------------------------------
-- set_file_extension
-- -------------------------------------------------------------------------
procedure set_file_extension(
  p_file_extension in varchar2)
is
begin
--
  pay_jp_ltax_imp_pkg.g_file_extension := p_file_extension;
--
end set_file_extension;
--
-- -------------------------------------------------------------------------
-- set_file_split
-- -------------------------------------------------------------------------
procedure set_file_split(
  p_file_split in varchar2)
is
begin
--
  pay_jp_ltax_imp_pkg.g_file_split := p_file_split;
--
end set_file_split;
--
-- -------------------------------------------------------------------------
-- set_datetrack_eev
-- -------------------------------------------------------------------------
procedure set_datetrack_eev(
  p_datetrack_eev in varchar2)
is
begin
--
  pay_jp_ltax_imp_pkg.g_datetrack_eev := p_datetrack_eev;
--
end set_datetrack_eev;
--
-- -------------------------------------------------------------------------
-- set_detail_debug
-- -------------------------------------------------------------------------
procedure set_detail_debug(
  p_yn in varchar2)
is
begin
--
  pay_jp_ltax_imp_pkg.g_detail_debug := p_yn;
--
end set_detail_debug;
--
-- -------------------------------------------------------------------------
-- default_file_name
-- -------------------------------------------------------------------------
function default_file_name(
  p_district_code   in varchar2,
  p_organization_id in number,
  p_swot_number     in pay_jp_swot_numbers.swot_number%type)
return varchar2
is
--
  l_file_name varchar2(80);
  l_file_end varchar2(80);
  l_sub_name  varchar2(15);
--
begin
--
  l_file_end := pay_jp_ltax_imp_pkg.g_file_extension;
  if pay_jp_ltax_imp_pkg.g_file_suffix is not null then
  --
    l_file_end := c_file_spliter||pay_jp_ltax_imp_pkg.g_file_suffix||l_file_end;
  --
  end if;
--
  if p_organization_id is null then
  --
    if p_district_code is not null then
    --
      l_file_name := pay_jp_ltax_imp_pkg.g_file_prefix||
        c_file_spliter||p_district_code||l_file_end;
    --
    else
    --
      l_file_name := pay_jp_ltax_imp_pkg.g_file_prefix||
        l_file_end;
    --
    end if;
  --
  else
  --
    l_sub_name := to_char(p_organization_id);
    if p_swot_number is not null then
    --
      l_sub_name := p_swot_number;
    --
    end if;
  --
    l_file_name := pay_jp_ltax_imp_pkg.g_file_prefix||
      c_file_spliter||p_district_code||
      c_file_spliter||l_sub_name||
      l_file_end;
  --
  end if;
--
  if lengthb(l_file_name) > 80 then
  --
    fnd_message.set_name('PAY','PAY_JP_SPR_INV_FILE_NAME');
    fnd_message.raise_error;
  --
  end if;
--
return l_file_name;
end default_file_name;
--
-- -------------------------------------------------------------------------
-- cnv_num
-- -------------------------------------------------------------------------
function cnv_num(
  p_text in varchar2)
return number
is
--
  l_text number;
--
begin
--
  l_text := to_number(p_text);
--
return l_text;
exception
when others then
--
  return l_text;
--
end cnv_num;
--
-- -------------------------------------------------------------------------
-- set_upload_date
-- -------------------------------------------------------------------------
function set_upload_date(
  p_period_date in date,
  p_base_date   in date)
return date
is
--
  l_diff_yyyy number;
  l_diff_mm number;
  l_upload_date date;
--
begin
--
  l_upload_date := p_period_date;
--
  if p_base_date is not null then
  --
    l_diff_yyyy := to_number(to_char(p_period_date,'YYYY')) - to_number(to_char(p_base_date,'YYYY'));
    l_diff_mm   := to_number(to_char(p_period_date,'MM')) - to_number(to_char(p_base_date,'MM'));
  --
    if l_diff_mm < 0 then
      l_diff_yyyy := l_diff_yyyy - 1;
      l_diff_mm := 12 + l_diff_mm;
    end if;
  --
    l_upload_date := add_months(p_base_date,l_diff_yyyy * 12 + l_diff_mm);
  --
  end if;
--
return l_upload_date;
end set_upload_date;
--
-- -------------------------------------------------------------------------
-- set_ee_tbl
-- -------------------------------------------------------------------------
procedure set_ee_tbl(
  p_mth          in number,
  p_payment_date in date,
  p_upload_date  in date)
is
--
  l_proc varchar2(80) := c_package||'set_ee_tbl';
--
begin
--
  g_ee_tbl(p_mth).period_year  := to_number(to_char(p_payment_date,'YYYY'));
  g_ee_tbl(p_mth).period_num   := to_number(to_char(p_payment_date,'MM'));
  g_ee_tbl(p_mth).upload_date  := set_upload_date(p_upload_date,g_upload_date);
--
end set_ee_tbl;
--
-- -------------------------------------------------------------------------
-- create_asg_set_amd
-- -------------------------------------------------------------------------
procedure create_asg_set_amd(
  p_business_group_id   in number,
  p_payroll_id          in number,
  p_assignment_id       in number,
  p_assignment_set_id   in out nocopy number,
  p_assignment_set_name in out nocopy varchar2)
is
begin
--
  if g_create_asg_set_for_errored = 'Y' then
  --
    if p_assignment_set_id is null then
    --
      hr_jp_ast_utility_pkg.create_asg_set_with_request_id(
        p_prefix              => c_asg_set_prefix,
        p_business_group_id   => p_business_group_id,
        p_payroll_id          => p_payroll_id,
        p_assignment_set_id   => p_assignment_set_id,
        p_assignment_set_name => p_assignment_set_name);
    --
      commit;
    --
    end if;
  --
    hr_jp_ast_utility_pkg.create_asg_set_amd(
      p_assignment_set_id  => p_assignment_set_id,
      p_assignment_id      => p_assignment_id,
      p_include_or_exclude => 'I');
  --
    commit;
  --
  end if;
--
end create_asg_set_amd;
--
-- -------------------------------------------------------------------------
-- init
-- -------------------------------------------------------------------------
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
  p_create_asg_set_for_errored in varchar2)
is
--
  l_proc varchar2(80) := c_package||'init';
--
  l_detail_debug varchar2(1) := pay_jp_ltax_imp_pkg.g_detail_debug;
--
  cursor csr_file_dir
  is
  select fcp.plsql_dir
  from   fnd_concurrent_requests fcr,
         fnd_concurrent_processes fcp
  where  fcr.request_id = g_request_id
  and    fcp.concurrent_process_id = fcr.controlling_manager;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  --if g_business_group_id is null
  --or g_business_group_id <> p_business_group_id then
  --
    g_file_tbl.delete;
    g_imp_data_tbl.delete;
    g_ass_data_tbl.delete;
    g_ass_id_tbl.delete;
    g_ass_ind_tbl.delete;
    g_ass_amd_ind_tbl.delete;
    g_imp_file_ind_tbl.delete;
    g_mth_tbl.delete;
  --
    g_dup_file_wng_tbl.delete;
    g_no_file_wng_tbl.delete;
    g_diff_ltax_wng_tbl.delete;
    g_inv_data_wng_tbl.delete;
    g_incon_data_wng_tbl.delete;
    g_no_ass_wng_tbl.delete;
    g_non_res_wng_tbl.delete;
    g_dup_ass_wng_tbl.delete;
    g_upd_eev_wng_tbl.delete;
    g_no_upd_wng_tbl.delete;
    g_sp_with_wng_tbl.delete;
    g_inv_ass_wng_tbl.delete;
  --
    g_file_tbl_cnt     := 0;
    g_imp_data_tbl_cnt := 0;
    g_ass_id_tbl_cnt   := 0;
  --
    g_dup_file_wng_tbl_cnt   := 0;
    g_no_file_wng_tbl_cnt    := 0;
    g_diff_ltax_wng_tbl_cnt  := 0;
    g_inv_data_wng_tbl_cnt   := 0;
    g_incon_data_wng_tbl_cnt := 0;
    g_no_ass_wng_tbl_cnt     := 0;
    g_non_res_wng_tbl_cnt    := 0;
    g_dup_ass_wng_tbl_cnt    := 0;
    g_upd_eev_wng_tbl_cnt    := 0;
    g_no_upd_wng_tbl_cnt     := 0;
    g_sp_with_wng_tbl_cnt    := 0;
    g_inv_ass_wng_tbl_cnt    := 0;
  --
    g_request_id        := fnd_global.conc_request_id;
    g_business_group_id := p_business_group_id;
    g_effective_yyyymm  := p_subject_yyyymm;
    g_effective_som     := to_date(g_effective_yyyymm||'01','YYYYMMDD');
    g_effective_eom     := last_day(g_effective_som);
    g_effective_soy     := trunc(g_effective_som,'YYYY');
    g_effective_eoy     := add_months(g_effective_soy,12) - 1;
  --
    g_upload_date       := p_upload_date;
  --
    g_session_date := g_upload_date;
    if g_session_date is null then
    --
      g_session_date := g_effective_som;
    --
    end if;
  --
    g_organization_id   := p_organization_id;
    g_district_code     := p_district_code;
    g_assignment_set_id := p_assignment_set_id;
  --
    g_ass_set_formula_id := null;
    g_ass_set_amendment_type := null;
    if g_assignment_set_id is not null then
    --
      hr_jp_ast_utility_pkg.get_assignment_set_info(g_assignment_set_id,g_ass_set_formula_id,g_ass_set_amendment_type);
    --
    end if;
  --
    g_file_dir := null;
    open csr_file_dir;
    fetch csr_file_dir into g_file_dir;
    close csr_file_dir;
  --
    if g_file_dir is null then
    --
      fnd_message.set_name('FND','CONC-GET PLSQL FILE NAMES');
      fnd_message.raise_error;
    --
    end if;
  --
    if pay_jp_report_pkg.g_char_set is null then
    --
      pay_jp_report_pkg.set_char_set(c_char_set);
    --
    end if;
  --
    pay_jp_report_pkg.set_db_char_set;
  --
    if pay_jp_ltax_imp_pkg.g_file_prefix is null then
    --
      set_file_prefix(c_file_prefix);
    --
    end if;
  --
    if pay_jp_ltax_imp_pkg.g_file_extension is null then
    --
      set_file_extension(c_file_extension);
    --
    end if;
  --
    if p_file_suffix is not null then
    --
      set_file_suffix(p_file_suffix);
    --
    end if;
  --
    if p_file_split is not null then
    --
      set_file_split(p_file_split);
    --
    end if;
  --
    if p_datetrack_eev is not null then
    --
      set_datetrack_eev(p_datetrack_eev);
    --
    end if;
  --
    g_show_dup_file    := p_show_dup_file;
    g_show_no_file     := p_show_no_file;
    g_valid_diff_ltax  := p_valid_diff_ltax;
    g_valid_incon_data := p_valid_incon_data;
    g_show_incon_data  := p_show_incon_data;
    g_valid_non_res    := p_valid_non_res;
    g_valid_dup_ass    := p_valid_dup_ass;
    g_show_upd_eev     := p_show_upd_eev;
    g_valid_no_upd     := p_valid_no_upd;
    g_show_no_upd      := p_show_no_upd;
    g_valid_sp_with    := p_valid_sp_with;
  --
    g_action_if_exists := p_action_if_exists;
    g_reject_if_future_changes := p_reject_if_future_changes;
    if g_datetrack_eev = 'Y' then
    --
      if g_action_if_exists = 'I' then
      --
        g_action_if_exists := 'U';
      --
      end if;
    --
      if g_reject_if_future_changes = 'Y' then
      --
        g_reject_if_future_changes := 'N';
      --
      end if;
    --
    end if;
  --
    g_create_entry_if_not_exist := p_create_entry_if_not_exist;
    g_create_asg_set_for_errored := p_create_asg_set_for_errored;
  --
    g_err_ass_set_id   := null;
    g_err_ass_set_name := null;
  --
  --end if;
--
  set_detail_debug(l_detail_debug);
--
  if g_debug then
  --
    hr_utility.trace('g_request_id                    : '||to_char(g_request_id));
    hr_utility.trace('g_business_group_id             : '||to_char(g_business_group_id));
    hr_utility.trace('g_effective_yyyymm              : '||g_effective_yyyymm);
    hr_utility.trace('g_effective_som                 : '||to_char(g_effective_som,'YYYY/MM/DD'));
    hr_utility.trace('g_effective_eom                 : '||to_char(g_effective_eom,'YYYY/MM/DD'));
    hr_utility.trace('g_effective_soy                 : '||to_char(g_effective_soy,'YYYY/MM/DD'));
    hr_utility.trace('g_effective_eoy                 : '||to_char(g_effective_eoy,'YYYY/MM/DD'));
    hr_utility.trace('g_upload_date                   : '||to_char(g_upload_date,'YYYY/MM/DD'));
    hr_utility.trace('g_session_date                  : '||to_char(g_session_date,'YYYY/MM/DD'));
    hr_utility.trace('g_organization_id               : '||to_char(g_organization_id));
    hr_utility.trace('g_district_code                 : '||g_district_code);
    hr_utility.trace('g_assignment_set_id             : '||to_char(g_assignment_set_id));
    hr_utility.trace('g_ass_set_formula_id            : '||to_char(g_ass_set_formula_id));
    hr_utility.trace('g_ass_set_amendment_type        : '||g_ass_set_amendment_type);
    hr_utility.trace('g_file_dir                      : '||g_file_dir);
    hr_utility.trace('g_file_suffix                   : '||g_file_suffix);
    hr_utility.trace('g_file_split                    : '||g_file_split);
    hr_utility.trace('g_datetrack_eev                 : '||g_datetrack_eev);
    hr_utility.trace('g_show_dup_file                 : '||g_show_dup_file);
    hr_utility.trace('g_show_no_file                  : '||g_show_no_file);
    hr_utility.trace('g_valid_diff_ltax               : '||g_valid_diff_ltax);
    hr_utility.trace('g_valid_incon_data              : '||g_valid_incon_data);
    hr_utility.trace('g_show_incon_data               : '||g_show_incon_data);
    hr_utility.trace('g_valid_non_res                 : '||g_valid_non_res);
    hr_utility.trace('g_valid_dup_ass                 : '||g_valid_dup_ass);
    hr_utility.trace('g_show_upd_eev                  : '||g_show_upd_eev);
    hr_utility.trace('g_valid_no_upd                  : '||g_valid_no_upd);
    hr_utility.trace('g_show_no_upd                   : '||g_show_no_upd);
    hr_utility.trace('g_valid_sp_with                 : '||g_valid_sp_with);
    hr_utility.trace('g_action_if_exists              : '||g_action_if_exists);
    hr_utility.trace('g_reject_if_future_changes      : '||g_reject_if_future_changes);
    hr_utility.trace('g_create_entry_if_not_exist     : '||g_create_entry_if_not_exist);
    hr_utility.trace('g_create_asg_set_for_errored    : '||g_create_asg_set_for_errored);
    hr_utility.trace('pay_jp_report_pkg.g_char_set    : '||pay_jp_report_pkg.g_char_set);
    hr_utility.trace('pay_jp_report_pkg.g_db_char_set : '||pay_jp_report_pkg.g_db_char_set);
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end init;
--
-- -------------------------------------------------------------------------
-- imp_file_data
-- -------------------------------------------------------------------------
procedure imp_file_data
is
--
  l_proc varchar2(80) := c_package||'imp_file_data';
--
  l_assignment_id per_all_assignments_f.assignment_id%type;
  l_include_or_exclude hr_assignment_set_amendments.include_or_exclude%type;
--
  l_district_code_o   per_addresses.town_or_city%type;
  l_organization_id_o number;
  l_input_file_name_o pay_jp_swot_numbers.input_file_name%type;
--
  l_input_file_name pay_jp_swot_numbers.input_file_name%type;
  l_file_line       number;
--
  l_ass_id_tbl t_num_tbl;
  l_ass_id_tbl_cnt number;
--
  l_ass_amd_tbl t_ass_amd_tbl;
  l_ass_amd_tbl_cnt number;
  l_ass_amd_ind_tbl t_ass_amd_tbl;
--
  type t_ass_file_rec is record(
    assignment_id        number,
    district_code        per_addresses.town_or_city%type,
    organization_id      number,
    swot_number          pay_jp_swot_numbers.swot_number%type,
    input_file_name      pay_jp_swot_numbers.input_file_name%type,
    assignment_number    per_all_assignments_f.assignment_number%type,
    include_or_exclude   hr_assignment_set_amendments.include_or_exclude%type,
    regular_payment_date date);
  type t_ass_file_tbl is table of t_ass_file_rec index by binary_integer;
  l_ass_file_tbl t_ass_file_tbl;
--
  l_imp_file_tbl t_imp_file_tbl;
  l_imp_file_tbl_cnt number;
  l_imp_file_ind_tbl t_imp_file_tbl;
--
  l_file_tbl t_file_tbl;
  l_file_tbl_cnt number;
  l_file_data_tbl pay_jp_report_pkg.t_file_data_tbl;
--
  l_cnv_data varchar2(32767);
--
  l_imp_file boolean;
--
  cursor csr_imp_file
  is
  select nvl(pjsn_act.report_district_code,pjsn_act.district_code) rep_district_code,
         pjsn_act.organization_id,
         pjsn_rep.swot_number,
         pjsn_rep.input_file_name
  from   hr_organization_information hoi,
         hr_all_organization_units hou,
         pay_jp_swot_numbers pjsn_act,
         pay_jp_swot_numbers pjsn_rep
  where  hoi.org_information_context = 'CLASS'
  and    hoi.org_information1 = 'JP_TAX_SWOT'
  and    hoi.organization_id = nvl(g_organization_id,hoi.organization_id)
  and    hou.organization_id = hoi.organization_id
  and    hou.business_group_id + 0 = g_business_group_id
  and    hou.date_from <= g_effective_eoy
  and    nvl(hou.date_to,hr_api.g_eot) >= g_effective_soy
  and    pjsn_act.organization_id = hou.organization_id
  and    pjsn_rep.organization_id = pjsn_act.organization_id
  and    pjsn_rep.district_code = nvl(pjsn_act.report_district_code,pjsn_act.district_code)
  and    substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5) = nvl(g_district_code,substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5))
  and    nvl(pjsn_rep.import_exclusive_flag,'N') = 'N'
  and    (pjsn_rep.swot_number is not null
          or pjsn_rep.input_file_name is not null)
  group by
    nvl(pjsn_act.report_district_code,pjsn_act.district_code),
    pjsn_act.organization_id,
    pjsn_rep.swot_number,
    pjsn_rep.input_file_name
  order by
    pjsn_rep.input_file_name,
    nvl(pjsn_act.report_district_code,pjsn_act.district_code),
    pjsn_rep.swot_number,
    pjsn_act.organization_id;
--
  cursor csr_imp_file_ass
  is
  select /*+ ORDERED */
         pa.assignment_id,
         pa.assignment_number,
         nvl(pjsn_act.report_district_code,pjsn_act.district_code) rep_district_code,
         pjsn_act.organization_id,
         pjsn_rep.swot_number,
         pjsn_rep.input_file_name,
         ptp.regular_payment_date
  from   hr_organization_information hoi,
         hr_all_organization_units hou,
         pay_jp_swot_numbers pjsn_act,
         pay_jp_swot_numbers pjsn_rep,
         per_addresses pad,
         per_periods_of_service ppos,
         per_all_assignments_f pa,
         per_time_periods ptp
  where  hoi.org_information_context = 'CLASS'
  and    hoi.org_information1 = 'JP_TAX_SWOT'
  and    hoi.organization_id = nvl(g_organization_id,hoi.organization_id)
  and    hou.organization_id = hoi.organization_id
  and    hou.business_group_id + 0 = g_business_group_id
  and    hou.date_from <= g_effective_eoy
  and    nvl(hou.date_to,hr_api.g_eot) >= g_effective_soy
  and    pjsn_act.organization_id = hou.organization_id
  and    pjsn_rep.organization_id = pjsn_act.organization_id
  and    pjsn_rep.district_code = nvl(pjsn_act.report_district_code,pjsn_act.district_code)
  and    substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5) = nvl(g_district_code,substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5))
  and    nvl(pjsn_rep.import_exclusive_flag,'N') = 'N'
  and    (pjsn_rep.swot_number is not null
          or pjsn_rep.input_file_name is not null)
  -- group by required for reporting and actual swot
  and    pad.town_or_city = substrb(pjsn_act.district_code,1,5)
  and    pad.address_type in ('JP_R','JP_C')
  and    pad.business_group_id + 0 = g_business_group_id
  and    ppos.person_id = pad.person_id
  and    nvl(ppos.actual_termination_date, g_effective_soy)
         between pad.date_from and nvl(pad.date_to,hr_api.g_eot)
  and    pa.period_of_service_id = ppos.period_of_service_id
  and    pa.effective_start_date <= g_effective_eom
  and    pa.effective_end_date >= g_effective_som
  and    pa.primary_flag = 'Y'
  and    ptp.payroll_id = pa.payroll_id
  and    ptp.regular_payment_date
         between g_effective_som and g_effective_eom
  and    ptp.regular_payment_date
         between pa.effective_start_date and pa.effective_end_date
  and    pay_jp_balance_pkg.get_entry_value_number(c_itx_org_iv_id,pa.assignment_id,ptp.regular_payment_date) = pjsn_act.organization_id
  group by
    pa.assignment_id,
    pa.assignment_number,
    nvl(pjsn_act.report_district_code,pjsn_act.district_code),
    pjsn_act.organization_id,
    pjsn_rep.swot_number,
    pjsn_rep.input_file_name,
    ptp.regular_payment_date
  order by
    pjsn_rep.input_file_name,
    nvl(pjsn_act.report_district_code,pjsn_act.district_code),
    pjsn_rep.swot_number,
    pjsn_act.organization_id,
    pa.assignment_id;
--
  l_csr_imp_file_ass csr_imp_file_ass%rowtype;
--
  cursor csr_ass_amd
  is
  select hasa.assignment_id,
         pa.assignment_number,
         hasa.include_or_exclude
  from   hr_assignment_set_amendments hasa,
         per_all_assignments_f pa,
         per_time_periods ptp
  where  hasa.assignment_set_id = g_assignment_set_id
  and    pa.assignment_id = hasa.assignment_id
  and    pa.effective_start_date <= g_effective_eom
  and    pa.effective_end_date >= g_effective_som
  and    pa.primary_flag = 'Y'
  and    ptp.payroll_id = pa.payroll_id
  and    ptp.regular_payment_date
         between g_effective_som and g_effective_eom
  and    ptp.regular_payment_date
         between pa.effective_start_date and pa.effective_end_date;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('g_file_split : '||g_file_split);
  end if;
--
  l_file_tbl_cnt := 0;
  l_ass_id_tbl_cnt := 0;
  l_ass_amd_tbl_cnt := 0;
  l_imp_file_tbl_cnt := 0;
--
  if g_file_split is null
  or g_file_split = 'Y' then
  --
    if g_debug then
      hr_utility.set_location(l_proc,10);
    end if;
  --
    if g_assignment_set_id is null then
    --
      open csr_imp_file;
      fetch csr_imp_file bulk collect into l_imp_file_tbl;
      close csr_imp_file;
    --
      if g_debug then
        hr_utility.set_location(l_proc,20);
        hr_utility.trace('l_imp_file_tbl.count : '||to_char(l_imp_file_tbl.count));
      end if;
    --
    else
    --
      if g_ass_set_amendment_type is not null
      and g_ass_set_amendment_type <> 'N' then
      --
        open csr_ass_amd;
        fetch csr_ass_amd bulk collect into l_ass_amd_tbl;
        close csr_ass_amd;
      --
        if l_ass_amd_tbl.count > 0 then
        --
          for i in 1..l_ass_amd_tbl.count loop
          --
            l_ass_amd_ind_tbl(l_ass_amd_tbl(i).assignment_id).assignment_id      := l_ass_amd_tbl(i).assignment_id;
            l_ass_amd_ind_tbl(l_ass_amd_tbl(i).assignment_id).include_or_exclude := l_ass_amd_tbl(i).include_or_exclude;
          --
          --
          end loop;
        --
        end if;
      --
      end if;
    --
      if g_debug then
        hr_utility.set_location(l_proc,30);
        hr_utility.trace('g_ass_set_amendment_type : '||g_ass_set_amendment_type);
        hr_utility.trace('l_ass_amd_tbl.count      : '||to_char(l_ass_amd_tbl.count));
        hr_utility.trace('l_ass_amd_ind_tbl.count  : '||to_char(l_ass_amd_ind_tbl.count));
      end if;
    --
      open csr_imp_file_ass;
      loop
      --
        fetch csr_imp_file_ass into l_csr_imp_file_ass;
        exit when csr_imp_file_ass%notfound;
      --
        if l_ass_amd_ind_tbl.count > 0 then
        --
          begin
          --
            l_assignment_id        := l_ass_amd_ind_tbl(l_csr_imp_file_ass.assignment_id).assignment_id;
            l_include_or_exclude   := l_ass_amd_ind_tbl(l_csr_imp_file_ass.assignment_id).include_or_exclude;
          --
            -- not store all csr_ass_amd to reduce non record in file
            g_ass_amd_ind_tbl(l_assignment_id).assignment_id      := l_assignment_id;
            g_ass_amd_ind_tbl(l_assignment_id).include_or_exclude := l_include_or_exclude;
          --
            if l_include_or_exclude is null
            or l_include_or_exclude = 'I' then
            --
              l_ass_id_tbl_cnt := l_ass_id_tbl_cnt + 1;
              l_ass_id_tbl(l_ass_id_tbl_cnt) := l_csr_imp_file_ass.assignment_id;
            --
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).assignment_id        := l_csr_imp_file_ass.assignment_id;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).district_code        := l_csr_imp_file_ass.rep_district_code;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).organization_id      := l_csr_imp_file_ass.organization_id;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).swot_number          := l_csr_imp_file_ass.swot_number;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).input_file_name      := l_csr_imp_file_ass.input_file_name;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).assignment_number    := l_csr_imp_file_ass.assignment_number;
              -- set to skip below formula validation if included amendment
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).include_or_exclude   := l_include_or_exclude;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).regular_payment_date := l_csr_imp_file_ass.regular_payment_date;
            --
            end if;
          --
          exception
          when no_data_found then
          --
            if (g_ass_set_amendment_type is not null
            and g_ass_set_amendment_type = 'E')
            or g_ass_set_formula_id is not null then
            --
              l_ass_id_tbl_cnt := l_ass_id_tbl_cnt + 1;
              l_ass_id_tbl(l_ass_id_tbl_cnt) := l_csr_imp_file_ass.assignment_id;
            --
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).assignment_id        := l_csr_imp_file_ass.assignment_id;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).district_code        := l_csr_imp_file_ass.rep_district_code;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).organization_id      := l_csr_imp_file_ass.organization_id;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).swot_number          := l_csr_imp_file_ass.swot_number;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).input_file_name      := l_csr_imp_file_ass.input_file_name;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).assignment_number    := l_csr_imp_file_ass.assignment_number;
              -- go through formula validation
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).include_or_exclude   := null;
              l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).regular_payment_date := l_csr_imp_file_ass.regular_payment_date;
            --
            end if;
          --
          end;
        --
        else
        --
        -- no amendment
        --
          l_ass_id_tbl_cnt := l_ass_id_tbl_cnt + 1;
          l_ass_id_tbl(l_ass_id_tbl_cnt) := l_csr_imp_file_ass.assignment_id;
        --
          l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).assignment_id        := l_csr_imp_file_ass.assignment_id;
          l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).district_code        := l_csr_imp_file_ass.rep_district_code;
          l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).organization_id      := l_csr_imp_file_ass.organization_id;
          l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).swot_number          := l_csr_imp_file_ass.swot_number;
          l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).input_file_name      := l_csr_imp_file_ass.input_file_name;
          l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).assignment_number    := l_csr_imp_file_ass.assignment_number;
          -- go through formula validation
          l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).include_or_exclude   := null;
          l_ass_file_tbl(l_csr_imp_file_ass.assignment_id).regular_payment_date := l_csr_imp_file_ass.regular_payment_date;
        --
        end if;
      --
      end loop;
      close csr_imp_file_ass;
    --
      if g_debug then
        hr_utility.set_location(l_proc,40);
        hr_utility.trace('l_ass_id_tbl.count      : '||to_char(l_ass_id_tbl.count));
        hr_utility.trace('l_ass_file_tbl.count    : '||to_char(l_ass_file_tbl.count));
        hr_utility.trace('g_ass_amd_ind_tbl.count : '||to_char(g_ass_amd_ind_tbl.count));
      end if;
    --
      if l_ass_id_tbl.count > 0 then
      --
        for i in 1..l_ass_id_tbl.count loop
        --
          l_imp_file := false;
        --
          if g_ass_set_formula_id is not null
          and l_ass_file_tbl(l_ass_id_tbl(i)).include_or_exclude is null then
          --
            if hr_jp_ast_utility_pkg.formula_validate(
                 p_formula_id     => g_ass_set_formula_id,
                 p_assignment_id  => l_ass_id_tbl(i),
                 p_effective_date => l_ass_file_tbl(l_ass_id_tbl(i)).regular_payment_date,
                 p_populate_fs    => true) then
            --
              if l_imp_file_tbl.count > 0
              and l_imp_file_tbl_cnt > 0 then
              --
                if nvl(l_imp_file_tbl(l_imp_file_tbl_cnt).input_file_name,'X') <> nvl(l_ass_file_tbl(l_ass_id_tbl(i)).input_file_name,'X')
                or nvl(l_imp_file_tbl(l_imp_file_tbl_cnt).district_code,'X') <> nvl(l_ass_file_tbl(l_ass_id_tbl(i)).district_code,'X')
                or nvl(l_imp_file_tbl(l_imp_file_tbl_cnt).organization_id,-1) <> nvl(l_ass_file_tbl(l_ass_id_tbl(i)).organization_id,-1)
                or nvl(l_imp_file_tbl(l_imp_file_tbl_cnt).swot_number,'X') <> nvl(l_ass_file_tbl(l_ass_id_tbl(i)).swot_number,'X') then
                --
                  l_imp_file := true;
                --
                end if;
              --
              end if;
            --
              if l_imp_file_tbl_cnt = 0
              or l_imp_file then
              --
                l_imp_file_tbl_cnt := l_imp_file_tbl_cnt + 1;
                l_imp_file_tbl(l_imp_file_tbl_cnt).district_code   := l_ass_file_tbl(l_ass_id_tbl(i)).district_code;
                l_imp_file_tbl(l_imp_file_tbl_cnt).organization_id := l_ass_file_tbl(l_ass_id_tbl(i)).organization_id;
                l_imp_file_tbl(l_imp_file_tbl_cnt).swot_number     := l_ass_file_tbl(l_ass_id_tbl(i)).swot_number;
                l_imp_file_tbl(l_imp_file_tbl_cnt).input_file_name := l_ass_file_tbl(l_ass_id_tbl(i)).input_file_name;
              --
              end if;
            --
            end if;
          --
          else
          --
            if l_imp_file_tbl.count > 0
            and l_imp_file_tbl_cnt > 0
            and (l_ass_file_tbl(l_ass_id_tbl(i)).include_or_exclude is null
                or l_ass_file_tbl(l_ass_id_tbl(i)).include_or_exclude <> 'E') then
            --
              if nvl(l_imp_file_tbl(l_imp_file_tbl_cnt).input_file_name,'X') <> nvl(l_ass_file_tbl(l_ass_id_tbl(i)).input_file_name,'X')
              or nvl(l_imp_file_tbl(l_imp_file_tbl_cnt).district_code,'X') <> nvl(l_ass_file_tbl(l_ass_id_tbl(i)).district_code,'X')
              or nvl(l_imp_file_tbl(l_imp_file_tbl_cnt).organization_id,-1) <> nvl(l_ass_file_tbl(l_ass_id_tbl(i)).organization_id,-1)
              or nvl(l_imp_file_tbl(l_imp_file_tbl_cnt).swot_number,'X') <> nvl(l_ass_file_tbl(l_ass_id_tbl(i)).swot_number,'X') then
              --
                l_imp_file := true;
              --
              end if;
            --
            end if;
            --
            if (l_imp_file_tbl_cnt = 0
                or l_imp_file) then
            --
              l_imp_file_tbl_cnt := l_imp_file_tbl_cnt + 1;
              l_imp_file_tbl(l_imp_file_tbl_cnt).district_code   := l_ass_file_tbl(l_ass_id_tbl(i)).district_code;
              l_imp_file_tbl(l_imp_file_tbl_cnt).organization_id := l_ass_file_tbl(l_ass_id_tbl(i)).organization_id;
              l_imp_file_tbl(l_imp_file_tbl_cnt).swot_number     := l_ass_file_tbl(l_ass_id_tbl(i)).swot_number;
              l_imp_file_tbl(l_imp_file_tbl_cnt).input_file_name := l_ass_file_tbl(l_ass_id_tbl(i)).input_file_name;
            --
            end if;
          --
          end if;
        --
        end loop;
      --
      end if;
    --
      if g_debug then
        hr_utility.set_location(l_proc,60);
        hr_utility.trace('l_imp_file_tbl.count : '||to_char(l_imp_file_tbl.count));
      end if;
    --
    end if;
  --
    if g_debug then
      hr_utility.set_location(l_proc,70);
    end if;
  --
    if l_imp_file_tbl.count > 0 then
    --
      for i in 1..l_imp_file_tbl.count loop
      --
        if l_imp_file_tbl(i).input_file_name is not null then
        --
          l_input_file_name := l_imp_file_tbl(i).input_file_name;
        --
          if l_input_file_name_o is not null
          and l_input_file_name_o = l_input_file_name then
          --
            if g_show_dup_file = 'Y' then
            --
              g_dup_file_wng_tbl_cnt := g_dup_file_wng_tbl_cnt + 1;
              g_dup_file_wng_tbl(g_dup_file_wng_tbl_cnt) := l_input_file_name||' : '||
                to_char(l_organization_id_o)||','||l_district_code_o||' - '||
                to_char(l_imp_file_tbl(i).organization_id)||','||l_imp_file_tbl(i).district_code;
            --
            end if;
          --
          else
          --
            l_file_tbl_cnt := l_file_tbl_cnt + 1;
          --
            l_file_tbl(l_file_tbl_cnt).file_name := l_input_file_name;
          --
            l_imp_file_ind_tbl(l_file_tbl_cnt).district_code   := l_imp_file_tbl(i).district_code;
            l_imp_file_ind_tbl(l_file_tbl_cnt).organization_id := l_imp_file_tbl(i).organization_id;
            l_imp_file_ind_tbl(l_file_tbl_cnt).swot_number     := l_imp_file_tbl(i).swot_number;
            l_imp_file_ind_tbl(l_file_tbl_cnt).input_file_name := l_imp_file_tbl(i).input_file_name;
          --
            l_input_file_name_o := l_input_file_name;
            l_district_code_o   := l_imp_file_tbl(i).district_code;
            l_organization_id_o := l_imp_file_tbl(i).organization_id;
          --
          end if;
        --
        else
        --
          --l_input_file_name := default_file_name(l_imp_file_tbl(i).district_code,null,null);
          l_input_file_name := default_file_name(l_imp_file_tbl(i).district_code,l_imp_file_tbl(i).organization_id,l_imp_file_tbl(i).swot_number);
        --
          -- basically this validation will not be required because swot num should be unique
          if l_input_file_name_o is not null
          and l_input_file_name_o = l_input_file_name then
          --
            if g_show_dup_file = 'Y' then
            --
              g_dup_file_wng_tbl_cnt := g_dup_file_wng_tbl_cnt + 1;
              g_dup_file_wng_tbl(g_dup_file_wng_tbl_cnt) := l_input_file_name||' : '||
                to_char(l_organization_id_o)||','||l_district_code_o||' - '||
                to_char(l_imp_file_tbl(i).organization_id)||','||l_imp_file_tbl(i).district_code;
            --
            end if;
          --
          else
          --
            --if l_district_code_o is not null
            --and l_district_code_o = l_imp_file_tbl(i).district_code then
            ----
            --  l_file_tbl(l_file_tbl_cnt - 1).file_name := default_file_name(l_imp_file_tbl(i - 1).district_code,l_imp_file_tbl(i - 1).organization_id,l_imp_file_tbl(i - 1).swot_number);
            --  l_file_tbl(l_file_tbl_cnt).file_name := default_file_name(l_imp_file_tbl(i).district_code,l_imp_file_tbl(i).organization_id,l_imp_file_tbl(i).swot_number);
            ----
            --end if;
          --
            l_file_tbl_cnt := l_file_tbl_cnt + 1;
          --
            l_file_tbl(l_file_tbl_cnt).file_name := l_input_file_name;
          --
            l_imp_file_ind_tbl(l_file_tbl_cnt).district_code   := l_imp_file_tbl(i).district_code;
            l_imp_file_ind_tbl(l_file_tbl_cnt).organization_id := l_imp_file_tbl(i).organization_id;
            l_imp_file_ind_tbl(l_file_tbl_cnt).swot_number     := l_imp_file_tbl(i).swot_number;
            l_imp_file_ind_tbl(l_file_tbl_cnt).input_file_name := l_imp_file_tbl(i).input_file_name;
          --
            l_input_file_name_o := l_input_file_name;
            l_district_code_o   := l_imp_file_tbl(i).district_code;
            l_organization_id_o := l_imp_file_tbl(i).organization_id;
          --
          end if;
        --
        end if;
      --
      end loop;
    --
    end if;
  --
    if g_debug then
      hr_utility.set_location(l_proc,80);
      hr_utility.trace('l_file_tbl.count         : '||to_char(l_file_tbl.count));
      hr_utility.trace('l_imp_file_ind_tbl.count : '||to_char(l_imp_file_ind_tbl.count));
      hr_utility.trace('g_show_dup_file          : '||g_show_dup_file);
      hr_utility.trace('g_dup_file_wng_tbl.count : '||to_char(g_dup_file_wng_tbl.count));
    end if;
  --
  else
  --
    if g_debug then
      hr_utility.set_location(l_proc,90);
    end if;
  --
    l_file_tbl_cnt := l_file_tbl_cnt + 1;
    l_file_tbl(l_file_tbl_cnt).file_name := default_file_name(null,null,null);
  --
    if g_debug then
      hr_utility.set_location(l_proc,100);
    end if;
  --
    if g_ass_set_amendment_type is not null
    and g_ass_set_amendment_type <> 'N' then
    --
      open csr_ass_amd;
      fetch csr_ass_amd bulk collect into l_ass_amd_tbl;
      close csr_ass_amd;
    --
      if l_ass_amd_tbl.count > 0 then
      --
        for i in 1..l_ass_amd_tbl.count loop
        --
          g_ass_amd_ind_tbl(l_ass_amd_tbl(i).assignment_id).assignment_id      := l_ass_amd_tbl(i).assignment_id;
          g_ass_amd_ind_tbl(l_ass_amd_tbl(i).assignment_id).include_or_exclude := l_ass_amd_tbl(i).include_or_exclude;
        --
        end loop;
      --
      end if;
    --
    end if;
  --
    if g_debug then
      hr_utility.set_location(l_proc,110);
      hr_utility.trace('l_ass_amd_tbl.count     : '||to_char(l_ass_amd_tbl.count));
      hr_utility.trace('g_ass_amd_ind_tbl.count : '||to_char(g_ass_amd_ind_tbl.count));
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,120);
    hr_utility.trace('l_file_tbl.count : '||to_char(l_file_tbl.count));
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
  --
    if l_file_tbl.count > 0 then
    --
      for i in 1..l_file_tbl.count loop
      --
        hr_utility.trace(to_char(i)||' : '||l_file_tbl(i).file_name);
      --
      end loop;
    --
    end if;
  --
  end if;
--
  if l_file_tbl.count > 0 then
  --
    for i in 1..l_file_tbl.count loop
    --
      if pay_jp_report_pkg.check_file(
           l_file_tbl(i).file_name,
           g_file_dir) then
      --
        g_file_tbl_cnt := g_file_tbl_cnt + 1;
        g_file_tbl(g_file_tbl_cnt).file_name := l_file_tbl(i).file_name;
      --
        -- set only case g_file_split = Y
        if l_imp_file_ind_tbl.count > 0 then
        --
          g_imp_file_ind_tbl(g_file_tbl_cnt).district_code   := l_imp_file_ind_tbl(i).district_code;
          g_imp_file_ind_tbl(g_file_tbl_cnt).organization_id := l_imp_file_ind_tbl(i).organization_id;
          g_imp_file_ind_tbl(g_file_tbl_cnt).swot_number     := l_imp_file_ind_tbl(i).swot_number;
          g_imp_file_ind_tbl(g_file_tbl_cnt).input_file_name := l_imp_file_ind_tbl(i).input_file_name;
        --
        end if;
      --
        pay_jp_report_pkg.open_file(
          g_file_tbl(g_file_tbl_cnt).file_name,
          g_file_dir,
          g_file_tbl(g_file_tbl_cnt).file_out,
          'r');
      --
      else
      --
        if g_show_no_file = 'Y' then
        --
          g_no_file_wng_tbl_cnt := g_no_file_wng_tbl_cnt + 1;
          g_no_file_wng_tbl(g_no_file_wng_tbl_cnt) := l_file_tbl(i).file_name;
        --
        end if;
      --
      end if;
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,130);
    hr_utility.trace('g_file_tbl.count         : '||to_char(g_file_tbl.count));
    hr_utility.trace('g_imp_file_ind_tbl.count : '||to_char(g_imp_file_ind_tbl.count));
    hr_utility.trace('g_show_no_file           : '||g_show_no_file);
    hr_utility.trace('g_no_file_wng_tbl.count  : '||to_char(g_no_file_wng_tbl.count));
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
  --
    if g_file_tbl.count > 0 then
    --
      for i in 1..g_file_tbl.count loop
      --
        hr_utility.trace(to_char(i)||' : '||g_file_tbl(i).file_name);
      --
      end loop;
    --
    end if;
  --
  end if;
--
  if g_file_tbl.count > 0 then
  --
    <<loop_file_tbl>>
    for i in 1..g_file_tbl.count loop
    --
      l_file_line := 0;
    --
      pay_jp_report_pkg.read_file(
        g_file_tbl(i).file_name,
        g_file_tbl(i).file_out,
        l_file_data_tbl);
    --
      if g_debug
      and g_detail_debug = 'Y' then
      --
        hr_utility.trace(g_file_tbl(i).file_name||' : '||l_file_data_tbl.count);
      --
      end if;
    --
      if l_file_data_tbl.count > 0 then
      --
        <<loop_data_tbl>>
        for j in l_file_data_tbl.first..l_file_data_tbl.last loop
        --
          l_cnv_data := pay_jp_report_pkg.cnv_db_txt(l_file_data_tbl(j));
        --
          if g_show_data = 'Y' then
          --
            pay_jp_report_pkg.show_debug(l_cnv_data);
          --
            <<loop_split_data>>
            for k in 1..21 loop
            --
              hr_utility.trace(to_char(k)||' : '||pay_jp_report_pkg.split_str(l_cnv_data,k));
            --
            end loop loop_split_data;
          --
          end if;
        --
          g_imp_data_tbl_cnt := g_imp_data_tbl_cnt + 1;
          l_file_line := l_file_line + 1;
          g_imp_data_tbl(g_imp_data_tbl_cnt).file_id := i;
          g_imp_data_tbl(g_imp_data_tbl_cnt).line := l_file_line;
        --
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_swot_number     := substrb(pay_jp_report_pkg.split_str(l_cnv_data,1),1,15);
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_personal_number := substrb(pay_jp_report_pkg.split_str(l_cnv_data,2),1,60);
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_employee_number := substrb(pay_jp_report_pkg.split_str(l_cnv_data,3),1,30);
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_address         := substrb(pay_jp_report_pkg.split_str(l_cnv_data,4),1,800);
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_address_kana    := substrb(pay_jp_report_pkg.split_str(l_cnv_data,5),1,800);
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_full_name       := substrb(pay_jp_report_pkg.split_str(l_cnv_data,6),1,400);
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_full_name_kana  := substrb(pay_jp_report_pkg.split_str(l_cnv_data,7),1,400);
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_sp_ltax         := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,8));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_6          := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,9));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_7          := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,10));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_8          := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,11));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_9          := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,12));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_10         := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,13));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_11         := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,14));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_12         := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,15));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_1          := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,16));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_2          := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,17));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_3          := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,18));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_4          := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,19));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_ltax_5          := cnv_num(pay_jp_report_pkg.split_str(l_cnv_data,20));
          g_imp_data_tbl(g_imp_data_tbl_cnt).i_district_code   := substrb(pay_jp_report_pkg.split_str(l_cnv_data,21),1,6);
          --
          -- validate date is all numeric
          if lengthb(ltrim(rtrim(g_imp_data_tbl(g_imp_data_tbl_cnt).i_district_code))) = 5
          and (lengthb(replace(translate(ltrim(rtrim(g_imp_data_tbl(g_imp_data_tbl_cnt).i_district_code)),'0123456789','*'),'*','')) is null
              or lengthb(replace(translate(ltrim(rtrim(g_imp_data_tbl(g_imp_data_tbl_cnt).i_district_code)),'0123456789','*'),'*','')) = 0) then
          --
            g_imp_data_tbl(g_imp_data_tbl_cnt).i_district_code := ltrim(rtrim(substrb(pay_jp_report_pkg.split_str(l_cnv_data,21),1,6)))
              ||per_jp_validations.district_code_check_digit(ltrim(rtrim(substrb(pay_jp_report_pkg.split_str(l_cnv_data,21),1,6))));
          --
          end if;
        --
        end loop loop_data_tbl;
      --
      end if;
    --
      pay_jp_report_pkg.close_file(
        g_file_tbl(i).file_name,
        g_file_tbl(i).file_out,
        'r');
    --
    end loop loop_file_tbl;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,140);
    hr_utility.trace('g_imp_data_tbl.count : '||to_char(g_imp_data_tbl.count));
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
  --
    if g_imp_data_tbl.count > 0 then
    --
      for i in 1..g_imp_data_tbl.count loop
      --
        hr_utility.trace(to_char(i)||' :'||to_char(g_imp_data_tbl(i).file_id)||','||to_char(g_imp_data_tbl(i).line));
      --
      end loop;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end imp_file_data;
--
-- -------------------------------------------------------------------------
-- get_ltxi_assignment
-- -------------------------------------------------------------------------
procedure get_ltxi_assignment(
  p_swot_number          in varchar2,
  p_employee_number      in varchar2,
  p_district_code        in varchar2,
  p_assignment_id        out nocopy number,
  p_payroll_id           out nocopy number,
  p_assignment_number    out nocopy varchar2,
  p_regular_payment_date out nocopy date,
  p_final_process_date   out nocopy date)
is
--
  l_proc varchar2(80) := c_package||'get_ltxi_assignment';
--
  l_assignment_id        per_all_assignments_f.assignment_id%type;
  l_payroll_id           pay_all_payrolls_f.payroll_id%type;
  l_assignment_number    per_all_assignments_f.assignment_number%type;
  l_regular_payment_date date;
  l_final_process_date   date;
--
  cursor csr_ass
  is
  select pa.assignment_id,
         pa.payroll_id,
         pa.assignment_number,
         ptp.regular_payment_date,
         greatest(ppos.actual_termination_date,nvl(ppos.final_process_date,ppos.actual_termination_date)) final_process_date
  from   per_all_people_f pp,
         per_all_assignments_f pa,
         per_time_periods ptp,
         per_periods_of_service ppos
  where  pp.business_group_id + 0 = g_business_group_id
  and    pp.effective_start_date <= g_effective_eom
  and    pp.effective_end_date >= g_effective_som
  and    pp.employee_number = p_employee_number
  and    pa.person_id = pp.person_id
  and    pa.primary_flag = 'Y'
  and    pa.effective_start_date <= g_effective_eom
  and    pa.effective_end_date >= g_effective_som
  and    ptp.payroll_id = pa.payroll_id
  and    ptp.regular_payment_date
         between g_effective_som and g_effective_eom
  and    ptp.regular_payment_date
         between pa.effective_start_date and pa.effective_end_date
  and    ptp.regular_payment_date
         between pp.effective_start_date and pp.effective_end_date
  and    ppos.person_id = pp.person_id
  and    ppos.period_of_service_id = pa.period_of_service_id
  and    ptp.regular_payment_date
         between ppos.date_start and nvl(greatest(ppos.actual_termination_date,nvl(ppos.final_process_date,ppos.actual_termination_date)),ptp.regular_payment_date)
  and    exists(
           select null
           from   per_addresses pad,
                  pay_jp_swot_numbers pjsn_act,
                  pay_jp_swot_numbers pjsn_rep,
                  hr_all_organization_units hou,
                  hr_organization_information hoi
           where  pad.person_id = pp.person_id
           and    pad.address_type in ('JP_C','JP_R')
           and    nvl(ppos.actual_termination_date,g_effective_soy)
                  between pad.date_from and nvl(pad.date_to,hr_api.g_eot)
           and    substrb(pjsn_act.district_code,1,5) = pad.town_or_city
           and    pjsn_rep.organization_id = pjsn_act.organization_id
           and    pjsn_rep.district_code = nvl(pjsn_act.report_district_code,pjsn_act.district_code)
           and    substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5) = nvl(g_district_code,substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5))
           and    nvl(pjsn_act.report_district_code,pjsn_act.district_code) = p_district_code
           and    nvl(pjsn_rep.import_exclusive_flag,'N') = 'N'
           and    pjsn_rep.swot_number = p_swot_number
           and    hou.organization_id = pjsn_rep.organization_id
           and    hou.business_group_id + 0 = g_business_group_id
           and    hou.date_from <= g_effective_eoy
           and    nvl(hou.date_to,hr_api.g_eot) >= g_effective_soy
           and    hou.organization_id = nvl(g_organization_id,hou.organization_id)
           and    hou.organization_id = hoi.organization_id
           and    hoi.org_information_context = 'CLASS'
           and    hoi.org_information1 = 'JP_TAX_SWOT'
           --exclude different itax are mixed in one file (swot_number should be different).
           and    pay_jp_balance_pkg.get_entry_value_number(c_itx_org_iv_id,pa.assignment_id,ptp.regular_payment_date) = hoi.organization_id);
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
  end if;
--
  open csr_ass;
  fetch csr_ass into
    l_assignment_id,
    l_payroll_id,
    l_assignment_number,
    l_regular_payment_date,
    l_final_process_date;
  close csr_ass;
--
  p_assignment_id        := l_assignment_id;
  p_payroll_id           := l_payroll_id;
  p_assignment_number    := l_assignment_number;
  p_regular_payment_date := l_regular_payment_date;
  p_final_process_date   := l_final_process_date;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.trace('p_swot_number          : '||p_swot_number);
    hr_utility.trace('p_employee_number      : '||p_employee_number);
    hr_utility.trace('p_district_code        : '||p_district_code);
    hr_utility.trace('l_assignment_id        : '||to_char(l_assignment_id));
    hr_utility.trace('l_payroll_id           : '||to_char(l_payroll_id));
    hr_utility.trace('l_assignment_number    : '||l_assignment_number);
    hr_utility.trace('l_regular_payment_date : '||to_char(l_regular_payment_date,'YYYY/MM/DD'));
    hr_utility.trace('l_final_process_date   : '||to_char(l_final_process_date,'YYYY/MM/DD'));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end get_ltxi_assignment;
--
-- -------------------------------------------------------------------------
-- valid_ltxi_assignment
-- -------------------------------------------------------------------------
procedure valid_ltxi_assignment(
  p_assignment_id        in number,
  p_assignment_number    in varchar2,
  p_regular_payment_date in date,
  p_imp_data_tbl_ind     in number,
  p_valid                out nocopy boolean)
--
is
--
  l_proc varchar2(80) := c_package||'valid_ltxi_assignment';
--
  l_valid boolean;
--
  l_assignment_id        per_all_assignments_f.assignment_id%type;
  l_include_or_exclude   hr_assignment_set_amendments.include_or_exclude%type;
--
  l_non_res_date date;
  l_res_date date;
  l_non_res_flag hr_lookups.lookup_code%type;
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_assignment_id         : '||to_char(p_assignment_id));
    hr_utility.trace('g_assignment_set_id     : '||to_char(g_assignment_set_id));
    hr_utility.trace('g_ass_amd_ind_tbl.count : '||to_char(g_ass_amd_ind_tbl.count));
  end if;
--
  l_valid := true;
--
  if p_assignment_id is not null
  and g_assignment_set_id is not null then
  --
    if g_ass_amd_ind_tbl.count > 0 then
    --
      begin
      --
        l_assignment_id        := g_ass_amd_ind_tbl(p_assignment_id).assignment_id;
        l_include_or_exclude   := g_ass_amd_ind_tbl(p_assignment_id).include_or_exclude;
      --
        if l_include_or_exclude is not null
        and l_include_or_exclude = 'E' then
        --
          l_valid := false;
        --
        end if;
      --
      exception
      when no_data_found then
      --
        if (g_ass_set_amendment_type is not null
        and g_ass_set_amendment_type = 'E')
        or g_ass_set_formula_id is not null then
        --
          null;
        --
        else
        --
          l_valid := false;
        --
        end if;
      --
      end;
    --
    end if;
  --
    if g_ass_set_formula_id is not null
    and l_include_or_exclude is null then
    --
      if not hr_jp_ast_utility_pkg.formula_validate(
               p_formula_id     => g_ass_set_formula_id,
               p_assignment_id  => p_assignment_id,
               p_effective_date => p_regular_payment_date,
               p_populate_fs    => true) then
      --
        l_valid := false;
      --
      end if;
    --
    end if;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
  --
    hr_utility.set_location(l_proc,10);
  --
    if l_valid then
      hr_utility.trace('ass set valid true');
    end if;
  --
  end if;
--
  if l_valid
  and p_assignment_id is null then
  --
    l_valid := false;
  --
    if ((g_file_split is null
        or g_file_split = 'Y')
       or (g_file_split = 'N'
          and g_district_code is null
          and g_organization_id is null))  then
    --
      g_no_ass_wng_tbl_cnt := g_no_ass_wng_tbl_cnt + 1;
      g_no_ass_wng_tbl(g_no_ass_wng_tbl_cnt) := g_file_tbl(g_imp_data_tbl(p_imp_data_tbl_ind).file_id).file_name||' ('||to_char(g_imp_data_tbl(p_imp_data_tbl_ind).line)||') : '||
        g_imp_data_tbl(p_imp_data_tbl_ind).i_swot_number||','||g_imp_data_tbl(p_imp_data_tbl_ind).i_employee_number||','||g_imp_data_tbl(p_imp_data_tbl_ind).i_district_code;
    --
    end if;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
  --
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('g_no_ass_wng_tbl.count : '||to_char(g_no_ass_wng_tbl.count));
  --
    if l_valid then
      hr_utility.trace('g_no_ass_wng_tbl valid true');
    end if;
  --
  end if;
--
  if l_valid then
  --
    l_non_res_date := pay_jp_balance_pkg.get_entry_value_date(c_non_res_date_iv_id,p_assignment_id,p_regular_payment_date);
    l_res_date := nvl(pay_jp_balance_pkg.get_entry_value_date(c_res_date_iv_id,p_assignment_id,p_regular_payment_date),hr_api.g_eot);
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.set_location(l_proc,30);
      hr_utility.trace('l_non_res_date : '||to_char(l_non_res_date,'YYYY/MM/DD'));
      hr_utility.trace('l_res_date     : '||to_char(l_res_date,'YYYY/MM/DD'));
    end if;
  --
    if l_non_res_date is not null then
    --
      l_non_res_flag := 'N';
      if l_non_res_date <= p_regular_payment_date
      and p_regular_payment_date < l_res_date then
      --
        l_non_res_flag := 'Y';
      --
      end if;
    --
    else
    --
      l_non_res_flag := nvl(pay_jp_balance_pkg.get_entry_value_char(c_non_res_iv_id,p_assignment_id,p_regular_payment_date),'N');
    --
    end if;
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.set_location(l_proc,40);
      hr_utility.trace('l_non_res_flag : '||l_non_res_flag);
    end if;
  --
    if l_non_res_flag is not null
    and l_non_res_flag = 'Y' then
    --
      g_non_res_wng_tbl_cnt := g_non_res_wng_tbl_cnt + 1;
      g_non_res_wng_tbl(g_non_res_wng_tbl_cnt) := p_assignment_number||' ('||to_char(p_assignment_id)||')';
    --
      if g_valid_non_res = 'Y' then
      --
        l_valid := false;
      --
      end if;
    --
    end if;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
  --
    hr_utility.set_location(l_proc,50);
    hr_utility.trace('g_valid_non_res         : '||g_valid_non_res);
    hr_utility.trace('g_non_res_wng_tbl.count : '||to_char(g_non_res_wng_tbl.count));
  --
    if l_valid then
      hr_utility.trace('g_non_res_wng_tbl valid true');
    end if;
  --
  end if;
--
  if l_valid then
  --
    if g_ass_ind_tbl.count > 0 then
    --
      begin
      --
        l_assignment_id := g_ass_ind_tbl(p_assignment_id).assignment_id;
      --
        g_dup_ass_wng_tbl_cnt := g_dup_ass_wng_tbl_cnt + 1;
        g_dup_ass_wng_tbl(g_dup_ass_wng_tbl_cnt) := g_file_tbl(g_imp_data_tbl(p_imp_data_tbl_ind).file_id).file_name||' ('||to_char(g_imp_data_tbl(p_imp_data_tbl_ind).line)||') - '||
          g_file_tbl(g_ass_data_tbl(l_assignment_id).file_id).file_name||' ('||to_char(g_ass_data_tbl(l_assignment_id).line)||') : '||
          p_assignment_number||' ('||to_char(p_assignment_id)||') : '||
          g_imp_data_tbl(p_imp_data_tbl_ind).i_swot_number||','||g_imp_data_tbl(p_imp_data_tbl_ind).i_employee_number||','||g_imp_data_tbl(p_imp_data_tbl_ind).i_district_code;
      --
        if g_valid_dup_ass = 'Y' then
        --
          l_valid := false;
        --
        end if;
      --
      exception
      when no_data_found then
      --
        null;
      --
      end;
    --
    end if;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
  --
    hr_utility.set_location(l_proc,60);
    hr_utility.trace('g_ass_ind_tbl.count     : '||to_char(g_ass_ind_tbl.count));
    hr_utility.trace('g_valid_dup_ass         : '||g_valid_dup_ass);
    hr_utility.trace('g_dup_ass_wng_tbl.count : '||to_char(g_dup_ass_wng_tbl.count));
  --
  end if;
--
  p_valid := l_valid;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end valid_ltxi_assignment;
--
-- -------------------------------------------------------------------------
-- valid_file_data
-- -------------------------------------------------------------------------
procedure valid_file_data
is
--
  l_proc varchar2(80) := c_package||'valid_file_data';
--
  l_assignment_id        per_all_assignments_f.assignment_id%type;
  l_payroll_id           pay_all_payrolls_f.payroll_id%type;
  l_assignment_number    per_all_assignments_f.assignment_number%type;
  l_regular_payment_date date;
  l_final_process_date   date;
--
  l_valid boolean;
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('g_imp_data_tbl.count     : '||to_char(g_imp_data_tbl.count));
    hr_utility.trace('g_imp_file_ind_tbl.count : '||to_char(g_imp_file_ind_tbl.count));
  end if;
--
  if g_imp_data_tbl.count > 0 then
  --
    <<loop_data_tbl>>
    for i in 1..g_imp_data_tbl.count loop
    --
      l_valid := true;
    --
      if g_imp_data_tbl(i).i_swot_number is not null
      and g_imp_data_tbl(i).i_employee_number is not null
      and g_imp_data_tbl(i).i_district_code is not null then
      --
        if g_imp_data_tbl(i).i_ltax_7 is not null
        and g_imp_data_tbl(i).i_ltax_8 is not null
        and g_imp_data_tbl(i).i_ltax_9 is not null
        and g_imp_data_tbl(i).i_ltax_10 is not null
        and g_imp_data_tbl(i).i_ltax_11 is not null
        and g_imp_data_tbl(i).i_ltax_12 is not null
        and g_imp_data_tbl(i).i_ltax_1 is not null
        and g_imp_data_tbl(i).i_ltax_2 is not null
        and g_imp_data_tbl(i).i_ltax_3 is not null
        and g_imp_data_tbl(i).i_ltax_4 is not null
        and g_imp_data_tbl(i).i_ltax_5 is not null then
        --
          if not (
          g_imp_data_tbl(i).i_ltax_7 = g_imp_data_tbl(i).i_ltax_8
          and g_imp_data_tbl(i).i_ltax_7 = g_imp_data_tbl(i).i_ltax_9
          and g_imp_data_tbl(i).i_ltax_7 = g_imp_data_tbl(i).i_ltax_10
          and g_imp_data_tbl(i).i_ltax_7 = g_imp_data_tbl(i).i_ltax_11
          and g_imp_data_tbl(i).i_ltax_7 = g_imp_data_tbl(i).i_ltax_12
          and g_imp_data_tbl(i).i_ltax_7 = g_imp_data_tbl(i).i_ltax_1
          and g_imp_data_tbl(i).i_ltax_7 = g_imp_data_tbl(i).i_ltax_2
          and g_imp_data_tbl(i).i_ltax_7 = g_imp_data_tbl(i).i_ltax_3
          and g_imp_data_tbl(i).i_ltax_7 = g_imp_data_tbl(i).i_ltax_4
          and g_imp_data_tbl(i).i_ltax_7 = g_imp_data_tbl(i).i_ltax_5) then
          --
            g_diff_ltax_wng_tbl_cnt := g_diff_ltax_wng_tbl_cnt + 1;
            g_diff_ltax_wng_tbl(g_diff_ltax_wng_tbl_cnt) := g_file_tbl(g_imp_data_tbl(i).file_id).file_name||' ('||to_char(g_imp_data_tbl(i).line)||') : '||
              to_char(g_imp_data_tbl(i).i_ltax_7)||','||
              to_char(g_imp_data_tbl(i).i_ltax_8)||','||
              to_char(g_imp_data_tbl(i).i_ltax_9)||','||
              to_char(g_imp_data_tbl(i).i_ltax_10)||','||
              to_char(g_imp_data_tbl(i).i_ltax_11)||','||
              to_char(g_imp_data_tbl(i).i_ltax_12)||','||
              to_char(g_imp_data_tbl(i).i_ltax_1)||','||
              to_char(g_imp_data_tbl(i).i_ltax_2)||','||
              to_char(g_imp_data_tbl(i).i_ltax_3)||','||
              to_char(g_imp_data_tbl(i).i_ltax_4)||','||
              to_char(g_imp_data_tbl(i).i_ltax_5);
          --
            if g_valid_diff_ltax = 'Y' then
            --
              l_valid := false;
            --
            end if;
          --
          end if;
        --
        else
        --
          g_diff_ltax_wng_tbl_cnt := g_diff_ltax_wng_tbl_cnt + 1;
          g_diff_ltax_wng_tbl(g_diff_ltax_wng_tbl_cnt) := g_file_tbl(g_imp_data_tbl(i).file_id).file_name||' ('||to_char(g_imp_data_tbl(i).line)||') : '||
            to_char(g_imp_data_tbl(i).i_ltax_7)||','||
            to_char(g_imp_data_tbl(i).i_ltax_8)||','||
            to_char(g_imp_data_tbl(i).i_ltax_9)||','||
            to_char(g_imp_data_tbl(i).i_ltax_10)||','||
            to_char(g_imp_data_tbl(i).i_ltax_11)||','||
            to_char(g_imp_data_tbl(i).i_ltax_12)||','||
            to_char(g_imp_data_tbl(i).i_ltax_1)||','||
            to_char(g_imp_data_tbl(i).i_ltax_2)||','||
            to_char(g_imp_data_tbl(i).i_ltax_3)||','||
            to_char(g_imp_data_tbl(i).i_ltax_4)||','||
            to_char(g_imp_data_tbl(i).i_ltax_5);
        --
          if g_valid_diff_ltax = 'Y' then
          --
            l_valid := false;
          --
          end if;
        --
        end if;
      --
      else
      --
        g_inv_data_wng_tbl_cnt := g_inv_data_wng_tbl_cnt + 1;
        g_inv_data_wng_tbl(g_inv_data_wng_tbl_cnt) := g_file_tbl(g_imp_data_tbl(i).file_id).file_name||' ('||to_char(g_imp_data_tbl(i).line)||') : '||
          g_imp_data_tbl(i).i_swot_number||','||g_imp_data_tbl(i).i_employee_number||','||g_imp_data_tbl(i).i_district_code;
      --
        l_valid := false;
      --
      end if;
    --
      if l_valid
      and (g_show_incon_data = 'Y'
          or g_valid_incon_data = 'Y')
      -- valid only case g_file_split = Y
      and g_imp_file_ind_tbl.count > 0 then
      --
        if g_imp_data_tbl(i).i_district_code <> g_imp_file_ind_tbl(g_imp_data_tbl(i).file_id).district_code
        or g_imp_data_tbl(i).i_swot_number <> g_imp_file_ind_tbl(g_imp_data_tbl(i).file_id).swot_number then
        --
          if g_show_incon_data = 'Y' then
          --
            g_incon_data_wng_tbl_cnt := g_incon_data_wng_tbl_cnt + 1;
            g_incon_data_wng_tbl(g_incon_data_wng_tbl_cnt) := g_file_tbl(g_imp_data_tbl(i).file_id).file_name||' ('||to_char(g_imp_data_tbl(i).line)||') : '||
              g_imp_file_ind_tbl(g_imp_data_tbl(i).file_id).swot_number||','||g_imp_file_ind_tbl(g_imp_data_tbl(i).file_id).district_code||' : '||
              g_imp_data_tbl(i).i_swot_number||','||g_imp_data_tbl(i).i_employee_number||','||g_imp_data_tbl(i).i_district_code;
          --
          end if;
        --
          if g_valid_incon_data = 'Y' then
          --
            l_valid := false;
          --
          end if;
        --
        end if;
      --
      end if;
    --
      if l_valid then
      --
        get_ltxi_assignment(
          g_imp_data_tbl(i).i_swot_number,
          g_imp_data_tbl(i).i_employee_number,
          g_imp_data_tbl(i).i_district_code,
          l_assignment_id,
          l_payroll_id,
          l_assignment_number,
          l_regular_payment_date,
          l_final_process_date);
      --
        valid_ltxi_assignment(
          l_assignment_id,
          l_assignment_number,
          l_regular_payment_date,
          i,
          l_valid);
      --
        if l_valid then
        --
          g_ass_id_tbl_cnt := g_ass_id_tbl_cnt + 1;
          g_ass_id_tbl(g_ass_id_tbl_cnt) := l_assignment_id;
        --
          g_ass_ind_tbl(l_assignment_id).assignment_id      := l_assignment_id;
          g_ass_ind_tbl(l_assignment_id).payroll_id         := l_payroll_id;
          g_ass_ind_tbl(l_assignment_id).assignment_number  := l_assignment_number;
          g_ass_ind_tbl(l_assignment_id).final_process_date := l_final_process_date;
        --
          g_ass_data_tbl(l_assignment_id).file_id           := g_imp_data_tbl(i).file_id;
          g_ass_data_tbl(l_assignment_id).line              := g_imp_data_tbl(i).line;
          g_ass_data_tbl(l_assignment_id).i_swot_number     := g_imp_data_tbl(i).i_swot_number;
          g_ass_data_tbl(l_assignment_id).i_personal_number := g_imp_data_tbl(i).i_personal_number;
          g_ass_data_tbl(l_assignment_id).i_employee_number := g_imp_data_tbl(i).i_employee_number;
          g_ass_data_tbl(l_assignment_id).i_address         := g_imp_data_tbl(i).i_address;
          g_ass_data_tbl(l_assignment_id).i_address_kana    := g_imp_data_tbl(i).i_address_kana;
          g_ass_data_tbl(l_assignment_id).i_full_name       := g_imp_data_tbl(i).i_full_name;
          g_ass_data_tbl(l_assignment_id).i_full_name_kana  := g_imp_data_tbl(i).i_full_name_kana;
          g_ass_data_tbl(l_assignment_id).i_sp_ltax         := g_imp_data_tbl(i).i_sp_ltax;
          g_ass_data_tbl(l_assignment_id).i_ltax_6          := g_imp_data_tbl(i).i_ltax_6;
          g_ass_data_tbl(l_assignment_id).i_ltax_7          := g_imp_data_tbl(i).i_ltax_7;
          g_ass_data_tbl(l_assignment_id).i_ltax_8          := g_imp_data_tbl(i).i_ltax_8;
          g_ass_data_tbl(l_assignment_id).i_ltax_9          := g_imp_data_tbl(i).i_ltax_9;
          g_ass_data_tbl(l_assignment_id).i_ltax_10         := g_imp_data_tbl(i).i_ltax_10;
          g_ass_data_tbl(l_assignment_id).i_ltax_11         := g_imp_data_tbl(i).i_ltax_11;
          g_ass_data_tbl(l_assignment_id).i_ltax_12         := g_imp_data_tbl(i).i_ltax_12;
          g_ass_data_tbl(l_assignment_id).i_ltax_1          := g_imp_data_tbl(i).i_ltax_1;
          g_ass_data_tbl(l_assignment_id).i_ltax_2          := g_imp_data_tbl(i).i_ltax_2;
          g_ass_data_tbl(l_assignment_id).i_ltax_3          := g_imp_data_tbl(i).i_ltax_3;
          g_ass_data_tbl(l_assignment_id).i_ltax_4          := g_imp_data_tbl(i).i_ltax_4;
          g_ass_data_tbl(l_assignment_id).i_ltax_5          := g_imp_data_tbl(i).i_ltax_5;
          g_ass_data_tbl(l_assignment_id).i_district_code   := g_imp_data_tbl(i).i_district_code;
          g_ass_data_tbl(l_assignment_id).assignment_id     := l_assignment_id;
          g_ass_data_tbl(l_assignment_id).assignment_number := l_assignment_number;
        --
        end if;
      --
      end if;
    --
    end loop loop_data_tbl;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.trace('g_ass_id_tbl.count         : '||to_char(g_ass_id_tbl.count));
    hr_utility.trace('g_ass_ind_tbl.count        : '||to_char(g_ass_ind_tbl.count));
    hr_utility.trace('g_ass_data_tbl.count       : '||to_char(g_ass_data_tbl.count));
    hr_utility.trace('g_valid_diff_ltax          : '||g_valid_diff_ltax);
    hr_utility.trace('g_diff_ltax_wng_tbl.count  : '||to_char(g_diff_ltax_wng_tbl.count));
    hr_utility.trace('g_inv_data_wng_tbl.count   : '||to_char(g_inv_data_wng_tbl.count));
    hr_utility.trace('g_valid_incon_data         : '||g_valid_incon_data);
    hr_utility.trace('g_show_incon_data          : '||g_show_incon_data);
    hr_utility.trace('g_incon_data_wng_tbl.count : '||to_char(g_incon_data_wng_tbl.count));
    hr_utility.trace('g_no_ass_wng_tbl.count     : '||to_char(g_no_ass_wng_tbl.count));
    hr_utility.trace('g_valid_non_res            : '||g_valid_non_res);
    hr_utility.trace('g_non_res_wng_tbl.count    : '||to_char(g_non_res_wng_tbl.count));
    hr_utility.trace('g_valid_dup_ass            : '||g_valid_dup_ass);
    hr_utility.trace('g_dup_ass_wng_tbl.count    : '||to_char(g_dup_ass_wng_tbl.count));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end valid_file_data;
--
-- -------------------------------------------------------------------------
-- assignment_process
-- -------------------------------------------------------------------------
procedure assignment_process(
  p_assignment_id in number,
  p_batch_id      in number)
is
--
  l_proc varchar2(80) := c_package||'assignment_process';
--
  l_payroll_id number;
  l_final_process_date date;
  l_payment_date date;
  l_upload_date date;
  l_each_mth_cnt number;
--
  l_ltax_start_mth varchar2(6);
  l_ltax_end_mth varchar2(6);
  l_ltax_ini number;
  l_ltax_2nd number;
--
  l_com_ltx_info_ee_rec  pay_jp_bee_utility_pkg.t_ee_rec;
  l_com_ltx_info_eev_rec pay_jp_bee_utility_pkg.t_eev_rec;
	l_new_value_tbl        pay_jp_bee_utility_pkg.t_varchar2_tbl;
--
  l_upd_eev        boolean;
  l_is_different   boolean;
  l_change_type    hr_lookups.lookup_code%type;
  l_write_all      boolean;
  l_batch_line_id  number;
  l_batch_line_ovn number;
--
  cursor csr_each_mth(
    p_payroll_id in number)
  is
  select ptp.regular_payment_date payment_date,
         ptp.start_date upload_date
  from   per_time_periods ptp
  where  ptp.payroll_id = p_payroll_id
  and    ptp.period_type = 'Calendar Month'
  and    ptp.regular_payment_date >= g_effective_som
  and    ptp.regular_payment_date < add_months(g_effective_som,12)
  order by ptp.start_date;
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_assignment_id              : '||to_char(p_assignment_id));
    hr_utility.trace('p_batch_id                   : '||to_char(p_batch_id));
    hr_utility.trace('g_create_entry_if_not_exist  : '||g_create_entry_if_not_exist);
    hr_utility.trace('g_mth_tbl.count              : '||to_char(g_mth_tbl.count));
    hr_utility.trace('g_ass_ind_tbl.count          : '||to_char(g_ass_ind_tbl.count));
    hr_utility.trace('g_datetrack_eev              : '||g_datetrack_eev);
    hr_utility.trace('g_valid_term_flag            : '||g_valid_term_flag);
  end if;
--
  begin
  --
    l_payroll_id := g_mth_tbl(g_ass_ind_tbl(p_assignment_id).payroll_id).payroll_id;
  --
  exception
  when no_data_found then
  --
    l_each_mth_cnt := 0;
    l_payroll_id := g_ass_ind_tbl(p_assignment_id).payroll_id;
  --
    open csr_each_mth(l_payroll_id);
    <<each_mth_loop>>
    loop
    --
      fetch csr_each_mth into l_payment_date, l_upload_date;
      exit when csr_each_mth%notfound;
    --
      l_each_mth_cnt := l_each_mth_cnt + 1;
    --
      g_mth_tbl(l_payroll_id).mth_cnt := l_each_mth_cnt;
    --
      if l_each_mth_cnt = 1 then
        g_mth_tbl(l_payroll_id).payroll_id      := l_payroll_id;
        g_mth_tbl(l_payroll_id).payment_date_1  := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_1   := l_upload_date;
      elsif l_each_mth_cnt = 2 then
        g_mth_tbl(l_payroll_id).payment_date_2  := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_2   := l_upload_date;
      elsif l_each_mth_cnt = 3 then
        g_mth_tbl(l_payroll_id).payment_date_3  := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_3   := l_upload_date;
      elsif l_each_mth_cnt = 4 then
        g_mth_tbl(l_payroll_id).payment_date_4  := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_4   := l_upload_date;
      elsif l_each_mth_cnt = 5 then
        g_mth_tbl(l_payroll_id).payment_date_5  := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_5   := l_upload_date;
      elsif l_each_mth_cnt = 6 then
        g_mth_tbl(l_payroll_id).payment_date_6  := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_6   := l_upload_date;
      elsif l_each_mth_cnt = 7 then
        g_mth_tbl(l_payroll_id).payment_date_7  := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_7   := l_upload_date;
      elsif l_each_mth_cnt = 8 then
        g_mth_tbl(l_payroll_id).payment_date_8  := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_8   := l_upload_date;
      elsif l_each_mth_cnt = 9 then
        g_mth_tbl(l_payroll_id).payment_date_9  := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_9   := l_upload_date;
      elsif l_each_mth_cnt = 10 then
        g_mth_tbl(l_payroll_id).payment_date_10 := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_10  := l_upload_date;
      elsif l_each_mth_cnt = 11 then
        g_mth_tbl(l_payroll_id).payment_date_11 := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_11  := l_upload_date;
      elsif l_each_mth_cnt = 12 then
        g_mth_tbl(l_payroll_id).payment_date_12 := l_payment_date;
        g_mth_tbl(l_payroll_id).upload_date_12  := l_upload_date;
      end if;
    --
      if g_datetrack_eev is null
      or g_datetrack_eev <> 'Y' then
      --
        exit each_mth_loop;
      --
      end if;
    --
    end loop each_mth_loop;
    close csr_each_mth;
  --
  end;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('l_payroll_id    : '||to_char(l_payroll_id));
    hr_utility.trace('g_payroll_id    : '||to_char(g_payroll_id));
    hr_utility.trace('g_mth_tbl.count : '||to_char(g_mth_tbl.count));
  end if;
--
  if g_mth_tbl.count > 0 then
  --
    if g_payroll_id is null
    or g_payroll_id <> l_payroll_id then
    --
      g_ee_tbl.delete;
      g_payroll_id := l_payroll_id;
    --
      if g_datetrack_eev = 'Y'
      and g_mth_tbl(l_payroll_id).mth_cnt = 12 then
      --
        set_ee_tbl(1,g_mth_tbl(l_payroll_id).payment_date_1,g_mth_tbl(l_payroll_id).upload_date_1);
        set_ee_tbl(2,g_mth_tbl(l_payroll_id).payment_date_2,g_mth_tbl(l_payroll_id).upload_date_2);
        set_ee_tbl(3,g_mth_tbl(l_payroll_id).payment_date_3,g_mth_tbl(l_payroll_id).upload_date_3);
        set_ee_tbl(4,g_mth_tbl(l_payroll_id).payment_date_4,g_mth_tbl(l_payroll_id).upload_date_4);
        set_ee_tbl(5,g_mth_tbl(l_payroll_id).payment_date_5,g_mth_tbl(l_payroll_id).upload_date_5);
        set_ee_tbl(6,g_mth_tbl(l_payroll_id).payment_date_6,g_mth_tbl(l_payroll_id).upload_date_6);
        set_ee_tbl(7,g_mth_tbl(l_payroll_id).payment_date_7,g_mth_tbl(l_payroll_id).upload_date_7);
        set_ee_tbl(8,g_mth_tbl(l_payroll_id).payment_date_8,g_mth_tbl(l_payroll_id).upload_date_8);
        set_ee_tbl(9,g_mth_tbl(l_payroll_id).payment_date_9,g_mth_tbl(l_payroll_id).upload_date_9);
        set_ee_tbl(10,g_mth_tbl(l_payroll_id).payment_date_10,g_mth_tbl(l_payroll_id).upload_date_10);
        set_ee_tbl(11,g_mth_tbl(l_payroll_id).payment_date_11,g_mth_tbl(l_payroll_id).upload_date_11);
        set_ee_tbl(12,g_mth_tbl(l_payroll_id).payment_date_12,g_mth_tbl(l_payroll_id).upload_date_12);
      --
      else
      --
        set_ee_tbl(1,g_mth_tbl(l_payroll_id).payment_date_1,g_mth_tbl(l_payroll_id).upload_date_1);
      --
      end if;
    --
    end if;
  --
  else
  --
    hr_utility.trace('l_mth_tbl.count is 0');
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('g_ee_tbl.count : '||to_char(g_ee_tbl.count));
  end if;
--
  if g_ee_tbl.count > 0 then
  --
    l_upd_eev := true;
  --
    for i in 1..g_ee_tbl.count loop
    --
      l_new_value_tbl.delete;
      l_com_ltx_info_ee_rec := null;
      l_com_ltx_info_eev_rec := null;
    --
      l_write_all := false;
      l_change_type := null;
      l_is_different := false;
      l_batch_line_id := null;
      l_batch_line_ovn := null;
    --
      l_final_process_date := g_ass_ind_tbl(p_assignment_id).final_process_date;
    --
      if g_debug
      and g_detail_debug = 'Y' then
        hr_utility.set_location(l_proc,30);
        hr_utility.trace('l_final_process_date : '||to_char(l_final_process_date,'YYYY/MM/DD'));
        hr_utility.trace('g_ee_tbl('||to_char(i)||').upload_date : '||to_char(g_ee_tbl(i).upload_date,'YYYY/MM/DD'));
      end if;
    --
      if g_valid_term_flag is null
      or g_valid_term_flag= 'N'
      or (g_valid_term_flag = 'Y'
         and (l_final_process_date is null
             or (l_final_process_date is not null
             and g_ee_tbl(i).upload_date <= l_final_process_date))) then
      --
        l_ltax_start_mth := to_char(g_ee_tbl(i).period_year)||lpad(to_char(g_ee_tbl(i).period_num),2,'0');
      --
        pay_jp_bee_utility_pkg.get_ee(
          p_assignment_id,
          c_com_ltx_info_elm_id,
          g_ee_tbl(i).upload_date,
          l_com_ltx_info_ee_rec,
          l_com_ltx_info_eev_rec);
      --
        if g_debug
        and g_detail_debug = 'Y' then
          hr_utility.set_location(l_proc,40);
          hr_utility.trace('l_ltax_start_mth                       : '||l_ltax_start_mth);
          hr_utility.trace('l_com_ltx_info_ee_rec.element_entry_id : '||to_char(l_com_ltx_info_ee_rec.element_entry_id));
        end if;
      --
        if l_com_ltx_info_ee_rec.element_entry_id is not null
        and l_com_ltx_info_eev_rec.entry_value_tbl.count > 0 then
        --
          if g_show_upd_eev = 'Y' then
          --
            g_upd_eev_wng_tbl_cnt := g_upd_eev_wng_tbl_cnt + 1;
            g_upd_eev_wng_tbl(g_upd_eev_wng_tbl_cnt)
              := g_file_tbl(g_ass_data_tbl(p_assignment_id).file_id).file_name||
                 ' ('||to_char(g_ass_data_tbl(p_assignment_id).line)||') : '||
                 g_ass_ind_tbl(p_assignment_id).assignment_number||' ('||
                 to_char(p_assignment_id)||') : '||
                 fnd_date.date_to_canonical(g_ee_tbl(i).upload_date)||' : '||
                 fnd_date.date_to_canonical(l_com_ltx_info_ee_rec.effective_start_date)||'-'||
                 fnd_date.date_to_canonical(l_com_ltx_info_ee_rec.effective_end_date);
            --
            if g_detail_eev = 'Y' then
            --
              for j in 1..l_com_ltx_info_eev_rec.entry_value_tbl.count loop
              --
                if j = 1 then
                --
                  g_upd_eev_wng_tbl(g_upd_eev_wng_tbl_cnt) :=
                    g_upd_eev_wng_tbl(g_upd_eev_wng_tbl_cnt)||
                    ' : ';
                --
                end if;
              --
                g_upd_eev_wng_tbl(g_upd_eev_wng_tbl_cnt) :=
                  g_upd_eev_wng_tbl(g_upd_eev_wng_tbl_cnt)||
                  l_com_ltx_info_eev_rec.entry_value_tbl(j);
              --
                if j <> l_com_ltx_info_eev_rec.entry_value_tbl.count then
                --
                  g_upd_eev_wng_tbl(g_upd_eev_wng_tbl_cnt) :=
                    g_upd_eev_wng_tbl(g_upd_eev_wng_tbl_cnt)||
                    ',';
                --
                end if;
              --
              end loop;
            --
            end if;
          --
          end if;
        --
          if i = 1
          and (g_valid_no_upd = 'Y'
              or g_show_no_upd = 'Y')
          and l_com_ltx_info_eev_rec.entry_value_tbl(3) is not null
          and l_com_ltx_info_eev_rec.entry_value_tbl(3) >= l_ltax_start_mth then
          --
            if g_show_no_upd = 'Y' then
            --
              g_no_upd_wng_tbl_cnt := g_no_upd_wng_tbl_cnt + 1;
              g_no_upd_wng_tbl(g_no_upd_wng_tbl_cnt)
                := g_file_tbl(g_ass_data_tbl(p_assignment_id).file_id).file_name||
                   ' ('||to_char(g_ass_data_tbl(p_assignment_id).line)||') : '||
                   g_ass_ind_tbl(p_assignment_id).assignment_number||' ('||
                   to_char(p_assignment_id)||') : '||
                   l_com_ltx_info_eev_rec.entry_value_tbl(3)||'-'||
                   l_ltax_start_mth;
            --
            end if;
          --
            if g_valid_no_upd = 'Y' then
            --
              l_upd_eev := false;
            --
            end if;
          --
          end if;
        --
          if i = 1
          and l_com_ltx_info_eev_rec.entry_value_tbl(1) is not null
          and l_com_ltx_info_eev_rec.entry_value_tbl(1) ='N' then
          --
            g_sp_with_wng_tbl_cnt := g_sp_with_wng_tbl_cnt + 1;
            g_sp_with_wng_tbl(g_sp_with_wng_tbl_cnt)
              := g_file_tbl(g_ass_data_tbl(p_assignment_id).file_id).file_name||
                 ' ('||to_char(g_ass_data_tbl(p_assignment_id).line)||') : '||
                 g_ass_ind_tbl(p_assignment_id).assignment_number||' ('||
                 to_char(p_assignment_id)||') : '||
                 l_com_ltx_info_eev_rec.entry_value_tbl(1);
          --
            if g_valid_sp_with = 'Y' then
            --
              l_upd_eev := false;
            --
            end if;
          --
          end if;
        --
        end if;
      --
        if (l_upd_eev
           and (l_com_ltx_info_ee_rec.element_entry_id is not null
               or g_create_entry_if_not_exist = 'Y')) then
        --
          l_ltax_end_mth := l_ltax_start_mth;
        --
          if g_ee_tbl(i).period_num = 1 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_1;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_2;
          elsif g_ee_tbl(i).period_num = 2 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_2;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_3;
          elsif g_ee_tbl(i).period_num = 3 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_3;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_4;
          elsif g_ee_tbl(i).period_num = 4 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_4;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_5;
          elsif g_ee_tbl(i).period_num = 5 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_5;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_6;
          elsif g_ee_tbl(i).period_num = 6 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_6;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_7;
          elsif g_ee_tbl(i).period_num = 7 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_7;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_8;
          elsif g_ee_tbl(i).period_num = 8 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_8;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_9;
          elsif g_ee_tbl(i).period_num = 9 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_9;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_10;
          elsif g_ee_tbl(i).period_num = 10 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_10;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_11;
          elsif g_ee_tbl(i).period_num = 11 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_11;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_12;
          elsif g_ee_tbl(i).period_num = 12 then
            l_ltax_ini := g_ass_data_tbl(p_assignment_id).i_ltax_12;
            l_ltax_2nd := g_ass_data_tbl(p_assignment_id).i_ltax_1;
          end if;
        --
          if i = 12 then
          --
            l_ltax_2nd := null;
          --
          end if;
        --
          if g_ee_tbl.count = 1 then
          --
            l_ltax_end_mth := to_char(add_months(to_date(l_ltax_start_mth||'01','YYYYMMDD'),12)-1,'YYYYMM');
          --
          end if;
        --
          l_new_value_tbl(1) := 'Y';
          l_new_value_tbl(2) := g_ass_data_tbl(p_assignment_id).i_district_code;
          l_new_value_tbl(3) := l_ltax_start_mth;
          l_new_value_tbl(4) := l_ltax_end_mth;
          l_new_value_tbl(5) := to_char(l_ltax_ini);
          l_new_value_tbl(6) := to_char(l_ltax_2nd);
          l_new_value_tbl(7) := g_ass_data_tbl(p_assignment_id).i_personal_number;
        --
          if g_debug
          and g_detail_debug = 'Y' then
          --
            hr_utility.set_location(l_proc,50);
          --
            for j in 1..7 loop
            --
              hr_utility.trace('l_new_value_tbl('||to_char(j)||') : '||l_new_value_tbl(j));
            --
            end loop;
          --
          end if;
        --
          pay_jp_bee_utility_pkg.set_eev(
            p_ee_rec            => l_com_ltx_info_ee_rec,
            p_eev_rec           => l_com_ltx_info_eev_rec,
            p_value_if_null_tbl => c_value_if_null_tbl,
            p_new_value_tbl     => l_new_value_tbl,
            p_is_different      => l_is_different);
        --
          if l_is_different then
          --
            if l_com_ltx_info_ee_rec.element_entry_id is null then
            --
              l_change_type := 'I';
              l_write_all := true;
            --
            else
            --
              if l_com_ltx_info_ee_rec.effective_start_date = g_ee_tbl(i).upload_date then
                l_change_type := 'C';
              else
                l_change_type := 'U';
              end if;
            --
            end if;
          --
            if g_debug
            and g_detail_debug = 'Y' then
              hr_utility.set_location(l_proc,60);
              hr_utility.trace('l_change_type : '||l_change_type);
            end if;
          --
            pay_jp_bee_utility_pkg.out(
              p_full_name         => g_ass_data_tbl(p_assignment_id).i_full_name,
              p_assignment_number => g_ass_data_tbl(p_assignment_id).assignment_number,
              p_effective_date    => g_ee_tbl(i).upload_date,
              p_change_type       => l_change_type,
              p_eev_rec           => l_com_ltx_info_eev_rec,
              p_new_value_tbl     => l_new_value_tbl,
              p_write_all         => l_write_all);
          --
            l_com_ltx_info_eev_rec.entry_value_tbl := l_new_value_tbl;
          --
            pay_jp_bee_utility_pkg.create_batch_line(
              p_batch_id              => p_batch_id,
              p_assignment_id         => p_assignment_id,
              p_assignment_number     => g_ass_data_tbl(p_assignment_id).assignment_number,
              p_element_type_id       => c_com_ltx_info_elm_id,
              p_element_name          => c_com_ltx_info_elm,
              p_effective_date        => g_ee_tbl(i).upload_date,
              p_ee_rec                => l_com_ltx_info_ee_rec,
              p_eev_rec               => l_com_ltx_info_eev_rec,
              p_batch_line_id         => l_batch_line_id,
              p_object_version_number => l_batch_line_ovn);
          --
            commit;
          --
            if g_debug
            and g_detail_debug = 'Y' then
              hr_utility.set_location(l_proc,70);
              hr_utility.trace('l_batch_line_id  : '||to_char(l_batch_line_id));
              hr_utility.trace('l_batch_line_ovn : '||to_char(l_batch_line_ovn));
            end if;
          --
          end if;
        --
        end if;
      --
      end if;
    --
    end loop;
  --
  else
  --
    hr_utility.trace('g_ee_tbl.count is 0');
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.trace('g_show_upd_eev          : '||g_show_upd_eev);
    hr_utility.trace('g_upd_eev_wng_tbl.count : '||to_char(g_upd_eev_wng_tbl.count));
    hr_utility.trace('g_valid_no_upd          : '||g_valid_no_upd);
    hr_utility.trace('g_show_no_upd           : '||g_show_no_upd);
    hr_utility.trace('g_no_upd_wng_tbl.count  : '||to_char(g_no_upd_wng_tbl.count));
    hr_utility.trace('g_valid_sp_with         : '||g_valid_sp_with);
    hr_utility.trace('g_sp_with_wng_tbl.count : '||to_char(g_sp_with_wng_tbl.count));
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
when others then
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,-1000);
  end if;
--
  g_inv_ass_wng_tbl_cnt := g_inv_ass_wng_tbl_cnt + 1;
  g_inv_ass_wng_tbl(g_inv_ass_wng_tbl_cnt)
    := g_file_tbl(g_ass_data_tbl(p_assignment_id).file_id).file_name||
       ' ('||to_char(g_ass_data_tbl(p_assignment_id).line)||') : '||
       g_ass_data_tbl(p_assignment_id).i_swot_number||','||
       g_ass_data_tbl(p_assignment_id).i_employee_number||','||
       g_ass_data_tbl(p_assignment_id).i_district_code||
       ' : '||g_ass_ind_tbl(p_assignment_id).assignment_number||
       ' ('||to_char(p_assignment_id)||') : '||
       to_char(sqlcode)||':'||substrb(sqlerrm,1,100);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,-1100);
    hr_utility.trace('g_inv_ass_wng_tbl.count : '||to_char(g_inv_ass_wng_tbl.count));
    hr_utility.trace('g_ass_ind_tbl.count     : '||to_char(g_ass_ind_tbl.count));
  end if;
--
  if g_ass_ind_tbl.count > 0 then
  --
    create_asg_set_amd(
      p_business_group_id   => g_business_group_id,
      p_payroll_id          => g_ass_ind_tbl(p_assignment_id).payroll_id,
      p_assignment_id       => p_assignment_id,
      p_assignment_set_id   => g_err_ass_set_id,
      p_assignment_set_name => g_err_ass_set_name);
  --
  end if;
--
end assignment_process;
--
-- -------------------------------------------------------------------------
-- transfer_imp_ltax_info_to_bee
-- -------------------------------------------------------------------------
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
  p_show_no_upd                in varchar2 default 'N')
is
--
  l_proc varchar2(80) := c_package||'transfer_imp_ltax_info_to_bee';
--
  l_upload_date date;
--
  l_batch_reference pay_batch_headers.batch_reference%type;
  l_batch_source pay_batch_headers.batch_source%type;
  l_date_effective_changes pay_batch_headers.date_effective_changes%type;
  l_batch_id number;
  l_batch_ovn number;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  pay_jp_bee_utility_pkg.g_num_of_outs := 0;
--
  l_upload_date            := fnd_date.canonical_to_date(p_upload_date);
  l_date_effective_changes := p_date_effective_changes;
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('pay_jp_bee_utility_pkg.g_num_of_outs : '||to_char(pay_jp_bee_utility_pkg.g_num_of_outs));
    hr_utility.trace('l_upload_date                        : '||to_char(l_upload_date,'YYYY/MM/DD'));
  end if;
--
  init(
    p_business_group_id,
    p_subject_yyyymm,
    l_upload_date,
    p_organization_id,
    p_district_code,
    p_assignment_set_id,
    p_file_suffix,
    p_file_split,
    p_datetrack_eev,
    p_show_dup_file,
    p_show_no_file,
    p_valid_diff_ltax,
    p_valid_incon_data,
    p_show_incon_data,
    p_valid_non_res,
    p_valid_dup_ass,
    p_show_upd_eev,
    p_valid_no_upd,
    p_show_no_upd,
    p_valid_sp_with,
    p_action_if_exists,
    p_reject_if_future_changes,
    p_create_entry_if_not_exist,
    p_create_asg_set_for_errored);
--
  if g_debug then
    hr_utility.set_location(l_proc,20);
  end if;
--
  pay_jp_bee_utility_pkg.chk_date_effective_changes(
    g_action_if_exists,
    g_reject_if_future_changes,
    l_date_effective_changes);
--
  if g_debug then
    hr_utility.set_location(l_proc,30);
  end if;
--
  insert_session(g_session_date);
--
  if g_debug then
    hr_utility.set_location(l_proc,40);
  end if;
--
  pay_batch_element_entry_api.create_batch_header(
    p_validate                 => false,
    p_session_date             => g_session_date,
    p_batch_name               => substrb(p_batch_name,1,30),
    p_business_group_id        => g_business_group_id,
    p_action_if_exists         => g_action_if_exists,
    p_batch_reference          => l_batch_reference,
    p_batch_source             => l_batch_source,
    p_date_effective_changes   => l_date_effective_changes,
    p_purge_after_transfer     => p_purge_after_transfer,
    p_reject_if_future_changes => g_reject_if_future_changes,
    p_batch_id                 => l_batch_id,
    p_object_version_number    => l_batch_ovn);
--
  if g_debug then
    hr_utility.set_location(l_proc,50);
  end if;
--
  imp_file_data;
--
  if g_debug then
    hr_utility.set_location(l_proc,60);
  end if;
--
  valid_file_data;
--
  if g_debug then
    hr_utility.set_location(l_proc,70);
  end if;
--
  if g_ass_id_tbl.count > 0 then
  --
    for i in 1..g_ass_id_tbl.count loop
    --
      assignment_process(
        g_ass_id_tbl(i),
        l_batch_id);
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,80);
  end if;
--
  delete_session;
--
  if g_debug then
    hr_utility.set_location(l_proc,90);
  end if;
--
  if g_dup_file_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_DUP_FILE'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_dup_file_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_dup_file_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,100);
  end if;
--
  if g_no_file_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_NO_FILE'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_no_file_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_no_file_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,110);
  end if;
--
  if g_diff_ltax_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_DIFF_LTAX'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_diff_ltax_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_diff_ltax_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,120);
  end if;
--
  if g_inv_data_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_INV_DATA'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_inv_data_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_inv_data_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,130);
  end if;
--
  if g_incon_data_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_INCON_DATA'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_incon_data_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_incon_data_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,140);
  end if;
--
  if g_no_ass_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_NO_ASS'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_no_ass_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_no_ass_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,150);
  end if;
--
  if g_non_res_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_NON_RES'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_non_res_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_non_res_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,160);
  end if;
--
  if g_dup_ass_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_DUP_ASS'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_dup_ass_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_dup_ass_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,170);
  end if;
--
  if g_upd_eev_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_UPD_EEV'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_upd_eev_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_upd_eev_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,180);
  end if;
--
  if g_no_upd_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_NO_UPD'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_no_upd_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_no_upd_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,190);
  end if;
--
  if g_sp_with_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_SP_WITH'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_sp_with_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_sp_with_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,200);
  end if;
--
  if g_inv_ass_wng_tbl_cnt > 0 then
  --
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_LTAX_IMP_INV_ASS'));
    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
  --
    for i in 1..g_inv_ass_wng_tbl_cnt loop
    --
      fnd_file.put_line(fnd_file.log,g_inv_ass_wng_tbl(i));
    --
    end loop;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,210);
  end if;
--
  if g_err_ass_set_id is not null then
  --
    fnd_message.set_name('PAY','PAY_JP_BEE_UTIL_ASG_SET_CREATE');
    fnd_message.set_token('ASSIGNMENT_SET_NAME',g_err_ass_set_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,220);
    hr_utility.trace('pay_jp_bee_utility_pkg.g_num_of_outs : '||to_char(pay_jp_bee_utility_pkg.g_num_of_outs));
  end if;
--
  if pay_jp_bee_utility_pkg.g_num_of_outs = 0 then
  --
    pay_batch_element_entry_api.delete_batch_header(
      p_validate              => false,
      p_batch_id              => l_batch_id,
      p_object_version_number => l_batch_ovn);
  --
    commit;
  --
    fnd_message.set_name('PAY','PAY_JP_BEE_UTIL_NO_ASGS');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
  --
	end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,230);
  end if;
--
  if g_inv_ass_wng_tbl_cnt > 0 then
  --
    p_retcode := 1;
  --
  else
  --
    p_retcode := 0;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('p_retcode : '||to_char(p_retcode));
    hr_utility.trace('p_errbuf  : '||p_errbuf);
    hr_utility.set_location(l_proc,1000);
  end if;
--
end transfer_imp_ltax_info_to_bee;
--
end pay_jp_ltax_imp_pkg;

/
