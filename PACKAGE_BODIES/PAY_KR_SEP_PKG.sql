--------------------------------------------------------
--  DDL for Package Body PAY_KR_SEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_SEP_PKG" as
/* $Header: pykrsepp.pkb 115.6 2002/12/11 12:16:20 krapolu noship $ */
--
-- Global Variables.
--
g_business_group_id        number;
g_legislation_code         varchar2(2);
g_itax_bal_id              number;
g_itax_wo_adj_bal_id       number;
g_rtax_bal_id              number;
g_rtax_wo_adj_bal_id       number;
g_stax_bal_id              number;
g_stax_wo_adj_bal_id       number;
g_hi_prem_ee_bal_id        number;
g_hi_prem_ee_wo_adj_bal_id number;
g_hi_prem_er_bal_id        number;
g_hi_prem_er_wo_adj_bal_id number;
g_itax_ue_id               number;
g_itax_wo_adj_ue_id        number;
g_rtax_ue_id               number;
g_rtax_wo_adj_ue_id        number;
g_stax_ue_id               number;
g_stax_wo_adj_ue_id        number;
g_hi_prem_ee_ue_id         number;
g_hi_prem_ee_wo_adj_ue_id  number;
g_hi_prem_er_ue_id         number;
g_hi_prem_er_wo_adj_ue_id  number;
--------------------------------------------------------------------------------
procedure get_balance_type_id(p_balance_name      in varchar2,
                              p_business_group_id in number,
                              p_balance_type_id   in out NOCOPY number)
--------------------------------------------------------------------------------
is
--
  cursor csr_balance
  is
  select balance_type_id
  from   pay_balance_types
  where  balance_name = p_balance_name
  and    nvl(business_group_id, g_business_group_id) = g_business_group_id
  and    nvl(legislation_code, g_legislation_code) = g_legislation_code;
--
begin
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := pay_kr_report_pkg.legislation_code(p_business_group_id);
  end if;
--
  if p_balance_type_id is null then
    open csr_balance;
    fetch csr_balance into p_balance_type_id;
    close csr_balance;
  end if;
end get_balance_type_id;
--------------------------------------------------------------------------------
procedure get_user_entity_id(p_user_entity_name  in varchar2,
                             p_business_group_id in number,
                             p_user_entity_id    in out NOCOPY number)
--------------------------------------------------------------------------------
is
--
  cursor csr_user_entity
  is
  select user_entity_id
  from   ff_user_entities
  where  user_entity_name = p_user_entity_name
  and    nvl(business_group_id, g_business_group_id) = g_business_group_id
  and    nvl(legislation_code, g_legislation_code) = g_legislation_code;
--
begin
--
  if g_business_group_id is null or p_business_group_id <> g_business_group_id then
    g_business_group_id := p_business_group_id;
    g_legislation_code  := pay_kr_report_pkg.legislation_code(p_business_group_id);
  end if;
--
  if p_user_entity_id is null then
    open csr_user_entity;
    fetch csr_user_entity into p_user_entity_id;
    close csr_user_entity;
  end if;
end get_user_entity_id;
--------------------------------------------------------------------------------
function get_iyea_tax_adj(p_assignment_action_id in number,
                          p_business_group_id    in number,
                          p_itax_adj             out NOCOPY number,
                          p_rtax_adj             out NOCOPY number,
                          p_stax_adj             out NOCOPY number) return number
--------------------------------------------------------------------------------
is
--
  l_itax        number;
  l_itax_wo_adj number;
  l_rtax        number;
  l_rtax_wo_adj number;
  l_stax        number;
  l_stax_wo_adj number;
--
  l_dummy number := -1;
--
begin
--
/*
--  get_balance_type_id('ITAX',p_business_group_id,g_itax_bal_id);
--  get_balance_type_id('ITAX_WO_ADJ',p_business_group_id,g_itax_wo_adj_bal_id);
--  get_balance_type_id('RTAX',p_business_group_id,g_rtax_bal_id);
--  get_balance_type_id('RTAX_WO_ADJ',p_business_group_id,g_rtax_wo_adj_bal_id);
--  get_balance_type_id('STAX',p_business_group_id,g_stax_bal_id);
--  get_balance_type_id('STAX_WO_ADJ',p_business_group_id,g_stax_wo_adj_bal_id);
----
--  l_itax := pay_kr_report_pkg.get_balance_value_asg_run(p_assignment_action_id,g_itax_bal_id);
--  l_itax_wo_adj := pay_kr_report_pkg.get_balance_value_asg_run(p_assignment_action_id,g_itax_wo_adj_bal_id);
--  l_rtax := pay_kr_report_pkg.get_balance_value_asg_run(p_assignment_action_id,g_rtax_bal_id);
--  l_rtax_wo_adj := pay_kr_report_pkg.get_balance_value_asg_run(p_assignment_action_id,g_rtax_wo_adj_bal_id);
--  l_stax := pay_kr_report_pkg.get_balance_value_asg_run(p_assignment_action_id,g_stax_bal_id);
--  l_stax_wo_adj := pay_kr_report_pkg.get_balance_value_asg_run(p_assignment_action_id,g_stax_wo_adj_bal_id);
----
--  p_itax_adj := l_itax - l_itax_wo_adj;
--  p_rtax_adj := l_rtax - l_rtax_wo_adj;
--  p_stax_adj := l_stax - l_stax_wo_adj;
*/
--
  get_user_entity_id('X_YEA_ITAX_ADJ',p_business_group_id,g_itax_ue_id);
  get_user_entity_id('X_YEA_RTAX_ADJ',p_business_group_id,g_rtax_ue_id);
  get_user_entity_id('X_YEA_STAX_ADJ',p_business_group_id,g_stax_ue_id);
--
  p_itax_adj := fnd_number.canonical_to_number(pay_kr_report_pkg.get_archive_items(p_assignment_action_id,g_itax_ue_id));
  p_rtax_adj := fnd_number.canonical_to_number(pay_kr_report_pkg.get_archive_items(p_assignment_action_id,g_rtax_ue_id));
  p_stax_adj := fnd_number.canonical_to_number(pay_kr_report_pkg.get_archive_items(p_assignment_action_id,g_stax_ue_id));
--
  return l_dummy;
--
end get_iyea_tax_adj;
--------------------------------------------------------------------------------
function get_ihia_prem_adj(p_assignment_action_id in number,
                           p_business_group_id    in number,
                           p_hi_prem_ee_adj       out NOCOPY number,
                           p_hi_prem_er_adj       out NOCOPY number) return number
--------------------------------------------------------------------------------
is
--
  l_hi_prem_ee        number;
  l_hi_prem_ee_wo_adj number;
  l_hi_prem_er        number;
  l_hi_prem_er_wo_adj number;
--
  l_dummy number := -1;
--
begin
--
/*
--  get_balance_type_id('HI_PREM_EE',p_business_group_id,g_hi_prem_ee_bal_id);
--  get_balance_type_id('HI_PREM_EE_WO_ADJ',p_business_group_id,g_hi_prem_ee_wo_adj_bal_id);
--  get_balance_type_id('HI_PREM_ER',p_business_group_id,g_hi_prem_er_bal_id);
--  get_balance_type_id('HI_PREM_ER_WO_ADJ',p_business_group_id,g_hi_prem_er_wo_adj_bal_id);
----
--  l_hi_prem_ee := pay_kr_report_pkg.get_balance_value_asg_run(p_assignment_action_id,g_hi_prem_ee_bal_id);
--  l_hi_prem_ee_wo_adj := pay_kr_report_pkg.get_balance_value_asg_run(p_assignment_action_id,g_hi_prem_ee_wo_adj_bal_id);
--  l_hi_prem_er := pay_kr_report_pkg.get_balance_value_asg_run(p_assignment_action_id,g_hi_prem_er_bal_id);
--  l_hi_prem_er_wo_adj := pay_kr_report_pkg.get_balance_value_asg_run(p_assignment_action_id,g_hi_prem_er_wo_adj_bal_id);
----
--  p_hi_prem_ee_adj := l_hi_prem_ee - l_hi_prem_ee_wo_adj;
--  p_hi_prem_er_adj := l_hi_prem_er - l_hi_prem_er_wo_adj;
*/
--
  get_user_entity_id('A_HEALTH_INS_SEP_ADJ_EMPLOYEE_CHARGE_ASG_YTD',p_business_group_id,g_hi_prem_ee_ue_id);
  get_user_entity_id('A_HEALTH_INS_SEP_ADJ_EMPLOYER_CHARGE_ASG_YTD',p_business_group_id,g_hi_prem_er_ue_id);
--
  p_hi_prem_ee_adj := fnd_number.canonical_to_number(pay_kr_report_pkg.get_archive_items(p_assignment_action_id,g_hi_prem_ee_ue_id));
  p_hi_prem_er_adj := fnd_number.canonical_to_number(pay_kr_report_pkg.get_archive_items(p_assignment_action_id,g_hi_prem_er_ue_id));
--
  return l_dummy;
--
end get_ihia_prem_adj;
end pay_kr_sep_pkg;

/
