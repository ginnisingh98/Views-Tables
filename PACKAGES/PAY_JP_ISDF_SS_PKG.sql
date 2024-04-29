--------------------------------------------------------
--  DDL for Package PAY_JP_ISDF_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_ISDF_SS_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpisfs.pkh 120.3.12010000.1 2008/07/27 22:59:35 appldev ship $ */
--
c_life_gen_calc_udt varchar2(80) := 'T_YEA_LIFE_INS_EXM';
c_life_pens_calc_udt varchar2(80) := 'T_YEA_INDIVIDUAL_PENSION_INS_EXM';
c_nonlife_long_calc_udt varchar2(80) := 'T_YEA_LONG_NONLIFE_INS_EXM';
c_nonlife_short_calc_udt varchar2(80) := 'T_YEA_SHORT_NONLIFE_INS_EXM';
--
c_rate_udtcol varchar2(80) := 'RATE';
c_add_adj_udtcol varchar2(80) := 'ADD_AMT';
--
c_yea_calc_max_udt varchar2(80) := 'T_YEA_MAX_AMT';
c_max_udtcol varchar2(80) := 'MAX';
c_nonlife_udtrow varchar2(80) := 'NONLIFE_INS_EXM';
c_earthquake_udtrow varchar2(80) := 'EARTHQUAKE_INS_EXM';
c_sp_emp_income_udtrow varchar2(80) := 'SPOUSE_SP_EXM_EARNER_ANNUAL_INCOME';
c_sp_dctable_sp_income_udtrow varchar2(80) := 'SPOUSE_EXM_SPOUSE_ANNUAL_INCOME';
c_sp_spouse_income_udtrow varchar2(80) := 'SPOUSE_SP_EXM_SPOUSE_ANNUAL_INCOME';
--
c_spouse_calc_udt varchar2(80) := 'T_YEA_SPOUSE_SP_EXM_RECKONER';
c_dct_udtcol varchar2(80) := 'EXM';
--
c_nonlife_long_year number := 10;
c_sp_calc_unit number := 10000;
c_sp_earned_inc_exp number := 650000;
c_sp_calc_earned_inc_calc1 number := 0;
c_sp_calc_other_inc_calc_rate number := 0.5;
--
c_nonlife_max number;
c_earthquake_max number;
c_emp_income_max number;
c_inc_spouse_dct_max number;
c_spouse_income_max number;
--
g_life_range1b varchar2(80);
g_life_range2a varchar2(80);
g_life_range2b varchar2(80);
g_life_range3a varchar2(80);
g_life_range3b varchar2(80);
g_life_range4a varchar2(80);
g_life_calc2 varchar2(80);
g_life_calc3 varchar2(80);
g_life_calc4 varchar2(80);
g_life_gen_max varchar2(80);
g_life_pens_max varchar2(80);
g_life_ins_max varchar2(80);
g_earthquake_max varchar2(80);
g_lnonlife_range1b varchar2(80);
g_lnonlife_calc2 varchar2(80);
g_lnonlife_year varchar2(80);
g_snonlife_range1b varchar2(80);
g_snonlife_calc2 varchar2(80);
g_lnonlife_max varchar2(80);
g_snonlife_max varchar2(80);
g_nonlife_max varchar2(80);
g_nonlife_max_2007 varchar2(80);
g_sp_emp_inc_max varchar2(80);
g_sp_spdct_max varchar2(80);
g_sp_spinc_max varchar2(80);
g_sp_calc_unit number;
g_sp_calc_exp1b number;
g_sp_calc_exp1b_fmt varchar2(80);
g_sp_calc_cal1 varchar2(80);
g_sp_calc_cal6 varchar2(80);
g_sp_calc_dct_range1a varchar2(80);
g_sp_calc_dct_range1b varchar2(80);
g_sp_calc_dct1 varchar2(80);
g_sp_calc_dct_range2a varchar2(80);
g_sp_calc_dct_range2b varchar2(80);
g_sp_calc_dct2 varchar2(80);
g_sp_calc_dct_range3a varchar2(80);
g_sp_calc_dct_range3b varchar2(80);
g_sp_calc_dct3 varchar2(80);
g_sp_calc_dct_range4a varchar2(80);
g_sp_calc_dct_range4b varchar2(80);
g_sp_calc_dct4 varchar2(80);
g_sp_calc_dct_range5a varchar2(80);
g_sp_calc_dct_range5b varchar2(80);
g_sp_calc_dct5 varchar2(80);
g_sp_calc_dct_range6a varchar2(80);
g_sp_calc_dct_range6b varchar2(80);
g_sp_calc_dct6 varchar2(80);
g_sp_calc_dct_range7a varchar2(80);
g_sp_calc_dct_range7b varchar2(80);
g_sp_calc_dct7 varchar2(80);
g_sp_calc_dct_range8a varchar2(80);
g_sp_calc_dct_range8b varchar2(80);
g_sp_calc_dct8 varchar2(80);
g_sp_calc_dct_range9a varchar2(80);
g_sp_calc_dct_range9b varchar2(80);
g_sp_calc_dct9 varchar2(80);
--
g_msg_life_range1        fnd_new_messages.message_text%type;
g_msg_life_range2        fnd_new_messages.message_text%type;
g_msg_life_range3        fnd_new_messages.message_text%type;
g_msg_life_range4        fnd_new_messages.message_text%type;
g_msg_life_calc2         fnd_new_messages.message_text%type;
g_msg_life_calc3         fnd_new_messages.message_text%type;
g_msg_life_calc4         fnd_new_messages.message_text%type;
g_msg_life_gen_max       fnd_new_messages.message_text%type;
g_msg_life_pens_max      fnd_new_messages.message_text%type;
g_msg_life_ins_max       fnd_new_messages.message_text%type;
g_msg_nonlife_2007         fnd_new_messages.message_text%type;
g_msg_nonlife_ap_2007      fnd_new_messages.message_text%type;
g_msg_eqnonlife_s_2007     fnd_new_messages.message_text%type;
g_msg_lnonlife_s_2007      fnd_new_messages.message_text%type;
g_msg_lnonlife             fnd_new_messages.message_text%type;
g_msg_eqnonlife_2007       fnd_new_messages.message_text%type;
g_msg_lnonlife_2007        fnd_new_messages.message_text%type;
g_msg_lnonlife_dct         fnd_new_messages.message_text%type;
g_msg_snonlife_dct         fnd_new_messages.message_text%type;
g_msg_lnonlife_dct_2007    fnd_new_messages.message_text%type;
g_msg_earthquake_max       fnd_new_messages.message_text%type;
g_msg_nonlife_long_max     fnd_new_messages.message_text%type;
g_msg_nonlife_short_max    fnd_new_messages.message_text%type;
g_msg_nonlife_ins_max      fnd_new_messages.message_text%type;
g_msg_nonlife_ins_max_2007 fnd_new_messages.message_text%type;
g_msg_sp_emp_inc_max     fnd_new_messages.message_text%type;
g_msg_sp_sp_inc_max      fnd_new_messages.message_text%type;
g_msg_sp_calc_cal1       fnd_new_messages.message_text%type;
g_msg_sp_calc_cal6       fnd_new_messages.message_text%type;
g_msg_sp_calc_dct_range1 fnd_new_messages.message_text%type;
g_msg_sp_calc_dct_range2 fnd_new_messages.message_text%type;
g_msg_sp_calc_dct_range3 fnd_new_messages.message_text%type;
g_msg_sp_calc_dct_range4 fnd_new_messages.message_text%type;
g_msg_sp_calc_dct_range5 fnd_new_messages.message_text%type;
g_msg_sp_calc_dct_range6 fnd_new_messages.message_text%type;
g_msg_sp_calc_dct_range7 fnd_new_messages.message_text%type;
g_msg_sp_calc_dct_range8 fnd_new_messages.message_text%type;
g_msg_sp_calc_dct_range9 fnd_new_messages.message_text%type;
g_msg_sp_calc_dct1       fnd_new_messages.message_text%type;
g_msg_sp_calc_dct2       fnd_new_messages.message_text%type;
g_msg_sp_calc_dct3       fnd_new_messages.message_text%type;
g_msg_sp_calc_dct4       fnd_new_messages.message_text%type;
g_msg_sp_calc_dct5       fnd_new_messages.message_text%type;
g_msg_sp_calc_dct6       fnd_new_messages.message_text%type;
g_msg_sp_calc_dct7       fnd_new_messages.message_text%type;
g_msg_sp_calc_dct8       fnd_new_messages.message_text%type;
g_msg_sp_calc_dct9       fnd_new_messages.message_text%type;
--
g_payroll_action_id number;
g_business_group_id number;
g_effective_date    date;
--
type t_action_info_rec is record(
  action_information_id       pay_action_information.action_information_id%type,
  action_context_id           pay_action_information.action_context_id%type,
  action_context_type         pay_action_information.action_context_type%type,
  object_version_number       pay_action_information.object_version_number%type,
  action_information_category pay_action_information.action_information_category%type,
  action_information1         pay_action_information.action_information1%type,
  action_information2         pay_action_information.action_information2%type,
  action_information3         pay_action_information.action_information3%type,
  action_information4         pay_action_information.action_information4%type,
  action_information5         pay_action_information.action_information5%type,
  action_information6         pay_action_information.action_information6%type,
  action_information7         pay_action_information.action_information7%type,
  action_information8         pay_action_information.action_information8%type,
  action_information9         pay_action_information.action_information9%type,
  action_information10        pay_action_information.action_information10%type,
  action_information11        pay_action_information.action_information11%type,
  action_information12        pay_action_information.action_information12%type,
  action_information13        pay_action_information.action_information13%type,
  action_information14        pay_action_information.action_information14%type,
  action_information15        pay_action_information.action_information15%type,
  action_information16        pay_action_information.action_information16%type,
  action_information17        pay_action_information.action_information17%type,
  action_information18        pay_action_information.action_information18%type,
  action_information19        pay_action_information.action_information19%type,
  action_information20        pay_action_information.action_information20%type,
  action_information21        pay_action_information.action_information21%type,
  action_information22        pay_action_information.action_information22%type,
  action_information23        pay_action_information.action_information23%type,
  action_information24        pay_action_information.action_information24%type,
  action_information25        pay_action_information.action_information25%type,
  action_information26        pay_action_information.action_information26%type,
  action_information27        pay_action_information.action_information27%type,
  action_information28        pay_action_information.action_information28%type,
  action_information29        pay_action_information.action_information29%type,
  action_information30        pay_action_information.action_information30%type,
  effective_date              pay_action_information.effective_date%type,
  assignment_id               pay_action_information.assignment_id%type);
--
-- #2243411 bulk collect bug fix is available from 9.2
type t_action_info_tbl is table of t_action_info_rec index by binary_integer;
--
type t_calc_total_rec is record(
  life_gen                 number,
  life_pens                number,
  earthquake               number,
  nonlife_long             number,
  nonlife_short            number,
  national_pens            number,
  social                   number,
  mutual_aid_ec            number,
  mutual_aid_p             number,
  mutual_aid_dsc           number,
  sp_emp_inc               number,
  sp_spouse_inc            number,
  sp_sp_type               varchar2(60),
  sp_wid_type              varchar2(60),
  sp_dct_exc               varchar2(60),
  sp_inc_cnt               number,
  sp_earned_inc            number,
  sp_earned_inc_exp        number,
  sp_business_inc          number,
  sp_business_inc_exp      number,
  sp_miscellaneous_inc     number,
  sp_miscellaneous_inc_exp number,
  sp_dividend_inc          number,
  sp_dividend_inc_exp      number,
  sp_real_estate_inc       number,
  sp_real_estate_inc_exp   number,
  sp_retirement_inc        number,
  sp_retirement_inc_exp    number,
  sp_other_inc             number,
  sp_other_inc_exp         number,
  sp_other_inc_exp_dct     number,
  sp_other_inc_exp_tmp     number,
  sp_other_inc_exp_tmp_exp number);
--
type t_calc_spouse_inc_rec is record(
  sp_earned_inc_calc        number,
  sp_business_inc_calc      number,
  sp_miscellaneous_inc_calc number,
  sp_dividend_inc_calc      number,
  sp_real_estate_inc_calc   number,
  sp_retirement_inc_calc    number,
  sp_other_inc_calc         number,
  sp_inc_calc               number);
--
type t_calc_dct_rec is record(
  life_gen_ins_prem           number,
  life_pens_ins_prem          number,
  life_gen_ins_calc_prem      number,
  life_pens_ins_calc_prem     number,
  life_ins_deduction          number,
  nonlife_long_ins_prem       number,
  nonlife_short_ins_prem      number,
  earthquake_ins_prem         number,
  nonlife_long_ins_calc_prem  number,
  nonlife_short_ins_calc_prem number,
  earthquake_ins_calc_prem    number,
  nonlife_ins_deduction       number,
  national_pens_ins_prem      number,
  social_ins_prem             number,
  social_ins_deduction        number,
  mutual_aid_deduction        number,
  sp_earned_inc_calc          number,
  sp_business_inc_calc        number,
  sp_miscellaneous_inc_calc   number,
  sp_dividend_inc_calc        number,
  sp_real_estate_inc_calc     number,
  sp_retirement_inc_calc      number,
  sp_other_inc_calc           number,
  sp_inc_calc                 number,
  spouse_inc                  number,
  spouse_deduction            number);
--
function get_spouse_type(
  p_assignment_id        in number,
  p_effective_date       in date,
  p_payroll_id           in number)
return varchar2;
--
function get_widow_type(
  p_assignment_id        in number,
  p_effective_date       in date)
return varchar2;
--
procedure set_form_pg_prompt(
  p_action_information_id in number);
--
procedure do_new(
  p_action_information_id in number,
  p_object_version_number in out nocopy number);
--
procedure do_apply(
  p_action_information_id in number,
  p_object_version_number in out nocopy number);
--
procedure do_calculate(
  p_action_information_id in number,
  p_object_version_number in out nocopy number);
--
procedure do_finalize(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_user_comments         in varchar2);
--
procedure do_reject(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_admin_comments        in varchar2);
--
procedure do_return(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_admin_comments        in varchar2);
--
procedure do_approve(
  p_action_information_id in number,
  p_object_version_number in out nocopy number);
--
procedure do_transfer(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_transfer_date         in date,
  p_create_session        in boolean default true,
  p_expire_after_transfer in varchar2 default 'N');
--
procedure do_expire(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_expiry_date           in date,
  p_create_session        in boolean default true,
  p_mode                  in varchar2 default null);
--
-- internal use only
procedure do_finalize(
  errbuf              out nocopy varchar2,
  retcode             out nocopy varchar2,
  p_payroll_action_id in number,
  p_user_comments in varchar2);
--
procedure do_approve(
  errbuf              out nocopy varchar2,
  retcode             out nocopy varchar2,
  p_payroll_action_id in number);
--
procedure do_transfer(
  errbuf                  out nocopy varchar2,
  retcode                 out nocopy varchar2,
  p_payroll_action_id     in number,
  p_transfer_date         in varchar2,
  p_expire_after_transfer in varchar2 default 'N');
--
procedure do_expire(
  errbuf              out nocopy varchar2,
  retcode             out nocopy varchar2,
  p_payroll_action_id in number,
  p_expiry_date       in varchar2,
  p_mode              in varchar2 default null);
--
end pay_jp_isdf_ss_pkg;

/
