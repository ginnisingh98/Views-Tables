--------------------------------------------------------
--  DDL for Package PAY_ZA_ACB_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_ACB_TAPE" AUTHID CURRENT_USER as
/* $Header: pyzaacb.pkh 120.3 2006/05/17 05:38:05 rpahune ship $ */

function get_acb_user_gen_num
(
   p_payroll_action_id in number,
   p_user_code         in varchar2
)  return number;

function get_acb_inst_gen_num
(
   p_payroll_action_id in number,
   p_acb_user_type     in varchar2,
   p_acb_inst_code     in varchar2
)  return number;

-- Declare public variables
level_cnt number;
user_gen  number(30);
inst_gen  number(30);

-- ACB Cursors
-- ACB Installation Header Cursor
cursor acb_inst_header is
   select 'TRANSFER_PAYROLL_ACTION_ID=P', ppa.payroll_action_id,
          'TRANSFER_INST_ID_CODE_FROM=P', substr(hoi.org_information1, 1, 80),
          'TRANSFER_ACB_USER_TYPE=P',     substr(hoi.org_information2, 1, 80),
          'TRANSFER_INST_NAME=P',         nvl(substr(hoi.org_information3, 1, 80), substr(hou.name, 1, 80)),
          'TRANSFER_CREATION_DATE=P',     to_char(sysdate, 'YYMMDD'),
          'TRANSFER_PURGE_DATE=P',        to_char(sysdate + 30, 'YYMMDD'),
          'TRANSFER_START_DATE=P',        to_char(ppa.start_date, 'YYMMDD'),
          'TRANSFER_END_DATE=P',          to_char(ppa.effective_date, 'YYMMDD'),
          'PAYROLL_ACTION_ID=C',          ppa.payroll_action_id
   from   pay_payroll_actions         ppa,
          hr_organization_information hoi,
          hr_organization_units       hou
   where  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
   and    hou.organization_id = ppa.business_group_id
   and    hoi.organization_id = hou.organization_id
   and    hoi.org_information_context = 'ZA_ACB_INFORMATION';

-- ACB User Header Cursor
--
cursor acb_user_header is
   select /*+ ORDERED
              INDEX (paa PAY_ASSIGNMENT_ACTIONS_N50)
              INDEX (ppp PAY_PRE_PAYMENTS_PK)
              INDEX (paa2 PAY_ASSIGNMENT_ACTIONS_PK)
              INDEX (ppa2 PAY_PAYROLL_ACTIONS_PK)
              INDEX (ppf PAY_PAYROLLS_F_PK)
              INDEX (scl HR_SOFT_CODING_KEYFLEX_PK)
              INDEX (ppa PAY_PAYROLL_ACTIONS_PK)
              INDEX (ptp PER_TIME_PERIODS_PK)
          */
          'TRANSFER_ACB_USER_CODE=P',     substr(scl.segment2, 1, 80),
          'TRANSFER_FIRST_ACTION_DATE=P', to_char(min(nvl(ppa.overriding_dd_date, nvl(ptp.default_dd_date, ptp.end_date))), 'YYYYMMDD'),
          'TRANSFER_LAST_ACTION_DATE=P',  to_char(max(nvl(ppa.overriding_dd_date, nvl(ptp.default_dd_date, ptp.end_date))), 'YYYYMMDD'),
          'TRANSFER_SERVICE_TYPE=P',      min(substr(scl.segment3, 1, 80)),
          'TRANSFER_USER_REFERENCE=P',    min(rpad(upper(scl.segment4),10,' ') || rpad(upper(scl.segment5), 20, ' ')),
          'TRANSFER_AGGREGATE_LIMIT=P',   nvl(min(substr(scl.segment6, 1, 80)), '0'),
          'TRANSFER_ITEM_LIMIT=P',        nvl(min(substr(scl.segment7, 1, 80)), '0')
     from
          pay_assignment_actions paa
        , pay_pre_payments       ppp
        , pay_assignment_actions paa2
        , pay_payroll_actions    ppa2
        , pay_payrolls_f         ppf
        , hr_soft_coding_keyflex scl
        , pay_payroll_actions    ppa
        , per_time_periods       ptp
    where
          paa.payroll_action_id      = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
      and paa.pre_payment_id         = ppp.pre_payment_id
      and paa2.assignment_action_id  =
        (
         select max(locked_action_id)
           from pay_action_interlocks pai
          where pai.locking_action_id = ppp.assignment_action_id
        )
      and paa2.payroll_action_id     = ppa2.payroll_action_id
      and ppa2.payroll_id            = ppf.payroll_id
      and ppa2.effective_date  between ppf.effective_start_date and ppf.effective_end_date
      and ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
      and scl.id_flex_num            = (select rule_mode from pay_legislation_rules where legislation_code = 'ZA' and rule_type = 'S')
      and scl.enabled_flag           = 'Y'
      and paa.payroll_action_id      = ppa.payroll_action_id
      and ppa2.time_period_id        = ptp.time_period_id
    group by substr(scl.segment2, 1, 80)
    order by substr(scl.segment2, 1, 80);

-- ACB Contra-Transaction Header Cursor
--
cursor acb_trans_header is
  select /*+ INDEX (ppa PAY_PAYROLL_ACTIONS_PK)
             INDEX (opm PAY_ORG_PAYMENT_METHODS_F_PK)
             INDEX (pea PAY_EXTERNAL_ACCOUNTS_PK)
             INDEX (paa PAY_ASSIGNMENT_ACTIONS_N50)
             INDEX (ppp PAY_PRE_PAYMENTS_PK)
             INDEX (ppm PAY_PERSONAL_PAYMENT_METHO_PK)
             INDEX (pea2 PAY_EXTERNAL_ACCOUNTS_PK)
             INDEX (paa2 PAY_ASSIGNMENT_ACTIONS_PK)
             INDEX (ppa2 PAY_PAYROLL_ACTIONS_PK)
             INDEX (ppf PAY_PAYROLLS_F_PK)
             INDEX (scl HR_SOFT_CODING_KEYFLEX_PK)
             INDEX (ptp PER_TIME_PERIODS_PK)
         */
 distinct 'TRANSFER_ORG_PAY_METHOD=P',          ppp.org_payment_method_id,
          'TRANSFER_USER_BRANCH=P',             substr(pea.segment1, 1, 80),
          'TRANSFER_ENTRY_CLASS=P',             decode(pea2.segment2, '4', '64', '61'),
          'TRANSFER_USER_ACCOUNT_NO=P',         substr(pea.segment3, 1, 80),
          'TRANSFER_USER_ACC_NAME=P',           substr(pea.segment4, 1, 80),
          'TRANSFER_ACTION_DATE=P',             to_char(min(nvl(ppa.overriding_dd_date, nvl(ptp.default_dd_date, ptp.end_date))), 'YYYYMMDD'),
          'TRANSFER_PAYROLL_NAME=P',            substr(ppf.payroll_name, 1, 80),
          'TRANSFER_PAYROLL_ID=P',              ppf.payroll_id,
          'TRANSFER_PAY_METHOD_NAME=P',         substr(opm.org_payment_method_name, 1, 80)
   from   pay_payroll_actions            ppa,
          pay_assignment_actions         paa,
          pay_pre_payments               ppp,
          pay_org_payment_methods_f      opm,
          pay_external_accounts          pea,
          pay_personal_payment_methods_f ppm,
          pay_external_accounts          pea2,
          pay_assignment_actions         paa2,
          pay_payroll_actions            ppa2,
          pay_all_payrolls_f             ppf,
          hr_soft_coding_keyflex         scl,
          per_time_periods               ptp
   where
          ppa.payroll_action_id          = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
   and    ppa.payroll_action_id          = paa.payroll_action_id
   and    paa.pre_payment_id             = ppp.pre_payment_id
   and    ppp.org_payment_method_id      = opm.org_payment_method_id
   and    ppa.effective_date       between opm.effective_start_date
                                       and opm.effective_end_date
   and    opm.external_account_id        = pea.external_account_id
   and    pea.id_flex_num                = (Select rule_mode from pay_legislation_rules WHERE LEGISLATION_CODE = 'ZA' and rule_type = 'E')
   and    pea.enabled_flag               = 'Y'

   and    ppp.personal_payment_method_id = ppm.personal_payment_method_id
   and    ppa.effective_date       between ppm.effective_start_date
                                       and ppm.effective_end_date
   and    ppm.external_account_id        = pea2.external_account_id
   and    paa2.assignment_action_id      =
   (
      select max(locked_action_id)
      from   pay_action_interlocks pai
      where  pai.locking_action_id = ppp.assignment_action_id
   )
   and    paa2.payroll_action_id         = ppa2.payroll_action_id
   and    ppa2.time_period_id            = ptp.time_period_id
   and    ppa2.effective_date      between ppf.effective_start_date
                                       and ppf.effective_end_date
   and    ppa2.business_group_id         = ppf.business_group_id
   and    ppa2.payroll_id                = ppf.payroll_id
   and    ppf.soft_coding_keyflex_id + 0 = scl.soft_coding_keyflex_id
   and    scl.id_flex_num                = (SELECT rule_mode FROM pay_legislation_rules  WHERE LEGISLATION_CODE = 'ZA' and rule_type = 'S')
   and    scl.enabled_flag               = 'Y'
   and    scl.segment2                   = pay_magtape_generic.get_parameter_value('TRANSFER_ACB_USER_CODE')
   group  by ppp.org_payment_method_id,
             pea.segment1,
             decode(pea2.segment2, '4', '64', '61'),
             pea.segment3,
             pea.segment4,
             ppf.payroll_name,
             ppf.payroll_id,
             opm.org_payment_method_name
   order  by decode(pea2.segment2, '4', '64', '61'),
             substr(ppf.payroll_name, 1, 80),
             substr(opm.org_payment_method_name, 1, 80),
             substr(pea.segment4, 1, 80);

-- ACB Transactions Cursor
--
cursor acb_transactions is
   select 'ASSIGNMENT_ACTION_ID=P',   paa.assignment_action_id,
          'TRANSFER_ASSIGN_NO=P',     substr(paf.assignment_number, 1, 80),
          'TRANSFER_HOMING_BRANCH=P', substr(pea.segment1, 1, 80),
          'TRANSFER_HOMING_ACC_NO=P', substr(pea.segment3, 1, 80),
          'TRANSFER_ACC_TYPE=P',      substr(pea.segment2, 1, 80),
          'TRANSFER_TRANS_AMOUNT=P',  ppp.value * 100,
          'TRANSFER_HOMING_ACC_NAME=P', nvl(upper(substr(pea.segment4, 1, 80)), upper(substr(ppf.last_name, 1, 80)) || ' ' || substr(upper(ppf.first_name), 1, 1))
   from   per_all_people               ppf,
          pay_external_accounts        pea,
          pay_personal_payment_methods ppm,
          pay_pre_payments             ppp,
          per_all_assignments          paf,
          pay_assignment_actions       paa,
          pay_legislation_rules        plr
   where  paa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
   and    paa.assignment_id                     = paf.assignment_id
   and    paf.payroll_id + 0 = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ID')
   and    paf.person_id = ppf.person_id
   and    ppp.org_payment_method_id + 0 = pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METHOD')
   and    ppp.pre_payment_id                    = paa.pre_payment_id
   and    ppm.personal_payment_method_id        = ppp.personal_payment_method_id
   and    decode(pea.segment2, '4', '64', '61') = pay_magtape_generic.get_parameter_value('TRANSFER_ENTRY_CLASS')
   and    pea.external_account_id               = ppm.external_account_id
   and    pea.id_flex_num                       = plr.rule_mode
   and    plr.LEGISLATION_CODE                  = 'ZA'
   and    plr.rule_type                         = 'E'
   and    pea.enabled_flag                      = 'Y'
   order  by substr(paf.assignment_number, 1, 80),
             substr(pea.segment4, 1, 80);

end pay_za_acb_tape;

 

/
