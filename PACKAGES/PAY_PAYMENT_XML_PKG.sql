--------------------------------------------------------
--  DDL for Package PAY_PAYMENT_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYMENT_XML_PKG" AUTHID CURRENT_USER AS
/* $Header: pypayxml.pkh 120.8.12010000.1 2008/07/27 23:19:43 appldev ship $ */
--
-- Global variables
--
g_currency_code  varchar2(10);
--
level_cnt number;
--
CURSOR c_header_footer
IS
SELECT 'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
       'BG_ID=P', ppa.business_group_id
from pay_payroll_actions ppa
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value
                              ('TRANSFER_PAYROLL_ACTION_ID')
or ppa.payroll_action_id = pay_magtape_generic.get_parameter_value
                              ('PAYROLL_ACTION_ID');
--
CURSOR c_payment_asg_actions
IS
SELECT 'TRANSFER_ACT_ID=P', paa.assignment_action_id
FROM   pay_assignment_actions paa
WHERE  paa.payroll_action_id =
         pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
or paa.payroll_action_id = pay_magtape_generic.get_parameter_value
                              ('PAYROLL_ACTION_ID');

CURSOR c_bank_act_grp
IS
SELECT distinct 'EXT_ACT_ID=P', popm.external_account_id
FROM  pay_payroll_actions ppa,
      pay_assignment_actions paa,
      pay_pre_payments ppp,
      pay_action_interlocks pai,
      pay_org_payment_methods_f popm
WHERE (ppa.payroll_action_id = pay_magtape_generic.get_parameter_value
                              ('TRANSFER_PAYROLL_ACTION_ID')
      or ppa.payroll_action_id = pay_magtape_generic.get_parameter_value
                              ('PAYROLL_ACTION_ID'))
AND  paa.payroll_action_id=ppa.payroll_action_id
and  paa.assignment_action_id=pai.locking_action_id
and  pai.locked_action_id=ppp.assignment_action_id
and  ppp.org_payment_method_id=popm.org_payment_method_id
and  ppa.payment_type_id=popm.payment_type_id
and (ppa.org_payment_method_id is NULL
     or
     ppa.org_payment_method_id=ppp.org_payment_method_id);

CURSOR c_bank_asg_actions
IS
SELECT 'TRANSFER_ACT_ID=P', paa.assignment_action_id
FROM   pay_assignment_actions paa
      ,pay_action_interlocks pai
      ,pay_pre_payments ppp
      ,pay_org_payment_methods_f popm
      ,pay_assignment_actions paa2
      ,pay_payroll_actions ppa
WHERE (paa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
      or paa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'))
and paa.assignment_action_id=pai.locking_action_id
and  pai.locked_action_id=ppp.assignment_action_id
and ppp.assignment_action_id=paa2.assignment_action_id
and ppp.pre_payment_id=paa.pre_payment_id
and paa2.payroll_action_id=ppa.payroll_action_id
and ppp.org_payment_method_id=popm.org_payment_method_id
and popm.external_account_id=pay_magtape_generic.get_parameter_value('EXT_ACT_ID')
and ppa.effective_date between popm.effective_start_date and popm.effective_end_date;

--
CURSOR c_payment_details
IS
SELECT 'PRE_PAY_ID=P', ppp.pre_payment_id,
       'PAYMENT_AMOUNT=P', ppp.value,
       'PERSONAL_PAY_METH=P', ppp.personal_payment_method_id,
       'DET_ORG_PAY_METH=P', ppp.org_payment_method_id,
       'PAYEE_PAY_METH_ID=P', ppp.payees_org_payment_method_id,
       'PRE_PAY_ASG_ACT=P', ppp.assignment_action_id,
       'ASG_ID=P', paa.assignment_id,
       'ORG_ID=P',paa.object_id, --should be null
       'PRE_PAY_EFF_DATE=P', ppa.effective_date,
       'DET_BG_ID=P', ppa.business_group_id
FROM   pay_pre_payments ppp
,      pay_action_interlocks pai
,      pay_assignment_actions paa
,      pay_assignment_actions paa_chq
,      pay_payroll_actions ppa
,      pay_payroll_actions ppa_chq
,      pay_org_payment_methods_f popm
WHERE  paa_chq.assignment_action_id = pay_magtape_generic.get_parameter_value
                               ('TRANSFER_ACT_ID')
and paa_chq.assignment_action_id = pai.locking_action_id
and pai.locked_action_id=paa.assignment_action_id
and paa.payroll_action_id=ppa.payroll_action_id
and ppp.assignment_action_id=paa.assignment_action_id  --is prepayment
and ppp.pre_payment_id=paa_chq.pre_payment_id
and popm.org_payment_method_id= ppp.org_payment_method_id
and ppa_chq.payment_type_id=popm.payment_type_id
and (ppa_chq.org_payment_method_id is NULL
     or
     ppa_chq.org_payment_method_id=ppp.org_payment_method_id)
and (ppa_chq.payroll_action_id =
         pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
or ppa_chq.payroll_action_id = pay_magtape_generic.get_parameter_value
                              ('PAYROLL_ACTION_ID'))
and ppa_chq.effective_date between popm.effective_start_date and popm.effective_end_date
UNION ALL
SELECT 'PRE_PAY_ID=P', ppp.pre_payment_id,
       'PAYMENT_AMOUNT=P', ppp.value,
       'PERSONAL_PAY_METH=P', ppp.personal_payment_method_id, -- should be null
       'DET_ORG_PAY_METH=P', ppp.org_payment_method_id,
       'PAYEE_PAY_METH_ID=P', ppp.payees_org_payment_method_id,
       'PRE_PAY_ASG_ACT=P', ppp.assignment_action_id,  --should be null
       'ASG_ID=P', paa.assignment_id, --null
       'ORG_ID=P',paa.object_id,
       'PRE_PAY_EFF_DATE=P', ppa.effective_date,
       'DET_BG_ID=P', ppa.business_group_id
FROM   pay_pre_payments ppp
,      pay_assignment_actions paa
,      pay_payroll_actions ppa
WHERE  paa.assignment_action_id= pay_magtape_generic.get_parameter_value
                               ('TRANSFER_ACT_ID')
and   paa.object_type='HOU'
and   ppp.organization_id=paa.object_id
and   ppp.payroll_action_id= ppa.payroll_action_id
and   exists (select 1 from pay_action_interlocks pai,
                            pay_assignment_actions paa2
              where pai.locking_action_id=paa.assignment_action_id
              and pai.locked_action_id=paa2.assignment_action_id
              and paa2.payroll_action_id=ppa.payroll_action_id);




--
-- procedures to generate xml
--
PROCEDURE gen_header_xml;
PROCEDURE gen_footer_xml;
PROCEDURE gen_bank_header_xml;
PROCEDURE gen_bank_footer_xml;
PROCEDURE gen_payment_details_xml;
--
END PAY_PAYMENT_XML_PKG;

/
