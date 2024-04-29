--------------------------------------------------------
--  DDL for Package PAY_SE_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_EFT" AUTHID CURRENT_USER AS
 /* $Header: pyseeftp.pkh 120.7.12010000.2 2009/09/23 08:46:55 vijranga ship $ */
level_cnt NUMBER;

FUNCTION get_parameter(p_payroll_action_id   NUMBER,
                       p_token_name          VARCHAR2) RETURN VARCHAR2;
 /********************************************************
*   Cursor to fetch Header1 record information		*
********************************************************/
CURSOR CSR_SE_PP_HEADER1 is
SELECT
    'START=P'
    ,1
    ,'PROCESS_DATE=P'
    ,fnd_date.canonical_to_date(pay_se_eft.get_parameter(ppa.payroll_action_id,
   'PROCESS_DATE'))
    from pay_payroll_actions ppa
    where ppa.payroll_action_id =pay_magtape_generic.get_parameter_value
    ('PAYROLL_ACTION_ID');

 /********************************************************
*   Cursor to fetch Footer1 record information		*
********************************************************/

/*CURSOR CSR_SE_PP_FOOTER1 is
SELECT
    'END=P', 1 from dual;*/

/********************************************************
*   Cursor to fetch Header record information		*
********************************************************/

CURSOR CSR_SE_PP_HEADER IS
select distinct  'CREATION_DATE=P'
      ,to_char(ppa.creation_date, 'YYMMDD')
      ,'CUSTOMER_NO=P'
     ,pay_se_eft.get_parameter(ppa.payroll_action_id,'CUSTOMER_NO')
     ,'ADDRESS1=P'
     , HL.ADDRESS_LINE_1
     ,'ADDRESS2=P'
     , HL.ADDRESS_LINE_2
     ,'ADDRESS3=P'
     , HL.ADDRESS_LINE_3
     ,'COUNTRY=P'
     ,hr_general.DECODE_TERRITORY(hl.style)
     ,'POSTAL_CODE=P'
     ,substr(hl.postal_code,1,3)||' '||substr(hl.postal_code,4,2) -- Bug#8849455 fix Added space between 3 and 4 digits in postal code
     ,'BANK_NAME=P'
     ,pea.segment1
     ,'ACCOUNT_NO=P'
     ,pea.segment2
     ,'ORGANIZATION_NO=P'
     ,hoi2.org_information2
     ,'ORGANIZATION_NAME=P'
     ,ou.Name
     ,'TRANSFER_ORGANIZATION_ID=P'
     ,ou.organization_id
     ,'PHONE=P'
     ,RPAD(NVL(substr(hoi4.org_information3,1,10),' '),10,' ')
     ,'PAYROLL=P'
     ,pap.payroll_Name
     ,'PAYMENT_PERIOD=P'
     ,fnd_date.canonical_to_date(pay_se_eft.get_parameter(ppa.payroll_action_id,'START_DATE'))||'  -  '
     ||fnd_date.canonical_to_date(pay_se_eft.get_parameter(ppa.payroll_action_id,'PROCESS_DATE'))
     ,'BANKGIRO_NO=P'
     ,pay_se_eft.get_parameter(ppa.payroll_action_id,'BANKGIRO_NO')
     from
       pay_payroll_actions ppa,
       pay_assignment_actions paa,
       per_all_assignments_f  paf,
       pay_pre_payments       ppp,
       hr_organization_units  ou,
       hr_locations_all hl,
       PAY_ORG_PAYMENT_METHODS_F ppm,
       pay_external_Accounts pea,
       hr_soft_coding_keyflex hsk,
       pay_all_payrolls_f pap,
       hr_organization_information hoi2,
       hr_organization_information hoi3,
       hr_organization_information hoi4
where ppa.payroll_action_id =pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
and    ppa.business_group_id =ou.business_group_id
and    paf.business_group_id=ou.business_group_id
and    ppp.pre_payment_id              = paa.pre_payment_id
and    paa.payroll_action_id           = ppa.payroll_action_id
and    paa.assignment_id               = paf.assignment_id
and    ou.location_id=hl.location_id
--and    paf.location_id=hl.location_id
and    ppm.external_account_id =pea.external_account_id
and    ppm.org_payment_method_id =  ppa.org_payment_method_id
and    ppa.effective_date between
paf.effective_start_date and paf.effective_end_date
and    ppa.effective_date between
ppm.effective_start_date and ppm.effective_end_date
and ou.business_group_id=pay_se_eft.get_parameter(ppa.payroll_action_id,
'BUSINESS_GROUP_ID')
and hoi2.organization_id=ou.organization_id
and hoi2.ORG_INFORMATION_CONTEXT='SE_LEGAL_EMPLOYER_DETAILS'
and hoi2.organization_id =  hoi3.organization_id
and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi3.organization_id=hoi4.organization_id
and hoi4.organization_id = ou.organization_id
and hoi4.ORG_INFORMATION_CONTEXT = 'SE_ORG_CONTACT_DETAILS'
and hoi4.org_information1='PHONE'
and hoi4.org_information_id=(select
min(org_information_id)from
hr_organization_information
where organization_id = ou.organization_id
and ORG_INFORMATION_CONTEXT = 'SE_ORG_CONTACT_DETAILS'
and org_information1='PHONE' )
and hsk.SOFT_CODING_KEYFLEX_ID = paf.SOFT_CODING_KEYFLEX_ID
and hsk.enabled_flag = 'Y'
and ppa.payroll_id=pap.payroll_id
and ppa.payroll_id=paf.payroll_id;

/********************************************************
*   Cursor to fetch Body record information		*
********************************************************/

CURSOR CSR_SE_PP_BODY IS
SELECT
       'AMOUNT=P',ppp.value*100
      ,'PAYEE_CODE=P',pef.NATIONAL_IDENTIFIER
      ,'PAYEE_ACT_NO=P',pea.segment2
      ,'PAYEE_NAME=P',pef.full_name
      ,'PROCESS_DATE=P' ,pay_se_eft.get_parameter(ppa.payroll_action_id,'PROCESS_DATE')
      ,'EMPLOYEE_NO=P',pef.Employee_Number
FROM              pay_pre_payments       ppp,
          pay_org_payment_methods_f pop,
          pay_personal_payment_methods_f ppm,
          pay_external_accounts        pea,
pay_payroll_actions    ppa,
pay_assignment_actions paa,
          per_all_assignments_f  paf,
          per_all_people_f	  pef,
       	  hr_soft_coding_keyflex hsk
where  ppa.payroll_action_id =   pay_magtape_generic.get_parameter_value(
'PAYROLL_ACTION_ID')
and    ppa.payroll_action_id = paa.payroll_action_id
and    paa.assignment_id               = paf.assignment_id
and    paf.payroll_id                    = nvl(ppa.payroll_id,paf.payroll_id )
and    ppa.effective_date between    paf.effective_start_date and paf.effective_end_date
and    paf.person_id                     = pef.person_id
and    ppa.effective_date between    pef.effective_start_date and pef.effective_end_date
and    ppp.pre_payment_id = paa.pre_payment_id
and    ppp.org_payment_method_id = pop.org_payment_method_id
and    ppa.effective_date between pop.effective_start_date and pop.effective_end_date
and    ppp.personal_payment_method_id = ppm.personal_payment_method_id
and    ppm.external_account_id         = pea.external_account_id
and    ppa.effective_date between    ppm.effective_start_date and ppm.effective_end_date
and    hsk.SOFT_CODING_KEYFLEX_ID  = paf.SOFT_CODING_KEYFLEX_ID
and    hsk.enabled_flag = 'Y'
and    hsk.segment2 in
(
       select hoi2.org_information1
       from HR_ORGANIZATION_UNITS o1
	   , HR_ORGANIZATION_INFORMATION hoi1
	   , HR_ORGANIZATION_INFORMATION hoi2
        WHERE o1.business_group_id = ppa.business_group_id
        and o1.organization_id = hoi1.organization_id
        and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
        and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
        and hoi1.organization_id=pay_magtape_generic.get_parameter_value(
        'TRANSFER_ORGANIZATION_ID')
        and hoi1.organization_id = hoi2.organization_id
        and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
);


END PAY_SE_EFT;

/
