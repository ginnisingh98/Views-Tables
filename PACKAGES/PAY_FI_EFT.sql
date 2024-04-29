--------------------------------------------------------
--  DDL for Package PAY_FI_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_EFT" AUTHID CURRENT_USER as
/* $Header: pyfieftp.pkh 120.1 2006/03/14 01:12:44 dbehera noship $ */

level_cnt NUMBER;

FUNCTION  get_parameter (
          p_parameter_string  in varchar2
         ,p_token             in varchar2
         ,p_segment_number    in number default null) RETURN varchar2;


 /********************************************************
*   Cursor to fetch Header record information		*
********************************************************/

CURSOR CSR_FI_EFT_HEADER IS
select 'PROCESS_DATE=P',
	to_char(fnd_date.canonical_to_date(pay_fi_eft.get_parameter
	(ppa.legislative_parameters,'PROCESS_DATE')),'YYYYMMDD')
FROM   pay_payroll_actions ppa
WHERE  ppa.payroll_action_id =
       pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
       AND    EXISTS (
       SELECT 1
       FROM    pay_assignment_actions pas
              ,pay_pre_payments       ppp
       WHERE   pas.payroll_action_id = ppa.payroll_action_id
       AND     ppp.pre_payment_id    = pas.pre_payment_id   );


/********************************************************
*   Cursor to fetch Body record information		*
********************************************************/
CURSOR CSR_FI_EFT_BODY IS
SELECT  /*+ INDEX( hsck , HR_SOFT_CODING_KEYFLEX_PK) */  'PAYER_CODE=P',hoi2.org_information1
 ,'PAY_DATE=P',to_char(fnd_date.canonical_to_date(pay_fi_eft.get_parameter
 (ppa.legislative_parameters,'PROCESS_DATE')),'YYYYMMDD')
 ,'PAYER_NAME=P',substr(o1.name,1,16)
 ,'PAYER_INFO=P',lpad(nvl(pay_fi_eft.get_parameter(ppa.legislative_parameters,'PAYER_INFO'),' '),10,' ')
 ,'PAYEE_CODE=P',pef.national_identifier
 ,'PAYEE_NAME=P',substr(pef.full_name,1,19)
 ,'PAYEE_ACT_NO=P',pea.segment3
 ,'PAY_AMOUNT=P' , ppp.value * 100
        ,'ASSIGNMENT_ID=C' , paf.assignment_id
 ,'BUSINESS_GROUP_ID=C' , paf.business_group_id
 ,'PER_PAY_METHOD_ID=C' , ppp.personal_payment_method_id
 ,'ORG_PAY_METHOD_ID=C' , ppa.org_payment_method_id
 ,'DATE_EARNED=C' , to_char(ppa.effective_date, 'YYYY/MM/DD HH24:MI:SS')
 ,'PAYROLL_ID=C' , ppa.payroll_id
 ,'PAYROLL_ACTION_ID=C' , ppa.payroll_action_id
 ,'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id
 ,'ORGANIZATION_ID=C' , paf.organization_id
 ,'TAX_UNIT_ID=C' , paa.tax_unit_id
     from
      pay_payroll_actions          ppa
      ,pay_assignment_actions       paa
      ,per_all_assignments_f            paf
      ,pay_pre_payments             ppp
      ,pay_personal_payment_methods_f    pppm
      ,per_all_people_f                 pef
      ,pay_external_accounts   pea
      ,hr_soft_coding_keyflex hsck
       ,hr_all_organization_units        o1
      ,hr_organization_information  hoi1
      ,hr_organization_information  hoi2
      ,hr_organization_information  hoi3
      ,hr_organization_information  hoi4
where paa.payroll_action_id =
               pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppa.business_group_id =o1.business_group_id
and    paf.business_group_id=o1.business_group_id
and    paa.pre_payment_id             = ppp.pre_payment_id
and    paa.payroll_action_id          = ppa.payroll_action_id
and    paa.assignment_id              = paf.assignment_id
and    paf.person_id                  = pef.person_id
and    pppm.personal_payment_method_id         = ppp.personal_payment_method_id
and    pppm.external_account_id    = pea.external_account_id
and    pppm.assignment_id              = paf.assignment_id
and    ppa.effective_date between pppm.effective_start_date
                              and pppm.effective_end_date
and    ppa.effective_date between paf.effective_start_date
                              and paf.effective_end_date
and    ppa.effective_date between pef.effective_start_date
                              and pef.effective_end_date
and hoi1.organization_id = o1.organization_id
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi1.org_information_context = 'CLASS'
and o1.organization_id = hoi2.organization_id
and hoi2.org_information_context='FI_LEGAL_EMPLOYER_DETAILS'
and hoi3.org_information1 = 'FI_LOCAL_UNIT'
and hoi3.org_information_context = 'CLASS'
and hoi3.organization_id = hoi4.org_information1
and hoi4.org_information_context='FI_LOCAL_UNITS'
and hoi4.organization_id = hoi1.organization_id
and paf.SOFT_CODING_KEYFLEX_ID = hsck.SOFT_CODING_KEYFLEX_ID
and hsck.segment2 = TO_CHAR(hoi3.organization_id)
order by decode(pay_fi_eft.get_parameter(legislative_parameters,
                                  'SORT_ORDER'),
                                  'NAME', substr(pef.last_name || ' ' || pef.first_name,1,50),
                                  'NUMBER', pef.employee_number, null);

END PAY_FI_EFT;

/
