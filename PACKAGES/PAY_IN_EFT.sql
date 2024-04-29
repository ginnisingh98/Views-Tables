--------------------------------------------------------
--  DDL for Package PAY_IN_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_EFT" AUTHID CURRENT_USER AS
/* $Header: pyineft.pkh 120.2 2006/11/24 10:45:52 abhjain noship $ */

level_cnt NUMBER;
g_start_date_param   CONSTANT VARCHAR2(20) := pay_magtape_generic.get_parameter_value('START_DATE_PARAM');
g_eff_date_param     CONSTANT VARCHAR2(20) := pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE_PARAM');
g_pay_date_param     CONSTANT VARCHAR2(20) := pay_magtape_generic.get_parameter_value('PAYMENT_DATE_PARAM');
g_trans_date         CONSTANT VARCHAR2(20) := pay_magtape_generic.get_parameter_value('TRANSACTION_DATE');

g_cons_set_param     CONSTANT pay_consolidation_sets.consolidation_set_id%TYPE :=
                                      pay_magtape_generic.get_parameter_value('CONSOLIDATION_SET_PARAM');
g_pay_action_param   CONSTANT pay_payroll_actions.payroll_action_id%TYPE :=
                                      pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
g_org_pay_meth_param CONSTANT pay_org_payment_methods_f.org_payment_method_id%TYPE :=
                                      pay_magtape_generic.get_parameter_value('ORG_PAYMENT_METHOD_PARAM');
g_reg_er_param       CONSTANT hr_organization_units.organization_id%TYPE :=
                                      pay_magtape_generic.get_parameter_value('REGISTERED_EMPLOYER_PARAM');

--Cursor to retrieve Header Info
CURSOR  c_eft_header IS
SELECT  'COMPANY_NAME1=P'
       , SUBSTR(company_name1, 1, 80)
       ,'COMPANY_NAME2=P'
       , SUBSTR(company_name1, 81, 160)
       ,'NUMBER_OF_DATA_RECORDS=P'
       , COUNT(*)
       ,'TOTAL_PAYMENT_AMOUNT=P'
       , SUM(payment_amt)
       ,'PAYMENT_BANK_NAME=P'
       , hr_general.decode_lookup('IN_BANK', org_bank_name)
       ,'PAYMENT_BANK_BRANCH=P'
       , hr_general.decode_lookup('IN_BANK_BRANCH', org_bank_branch)
       ,'PAYMENT_BRANCH_CODE=P'
       , org_bank_branch
       ,'PAYMENT_BANK_ACCOUNT_NUMBER=P'
       , bank_acc_num
       ,'PAYMENT_DATE=P'
       , g_pay_date_param
       , 'SUBMIT_DATE=P'
       , g_trans_date
  FROM ( SELECT  hoi.org_information4  company_name1
               , NVL(ppp.value,0)      payment_amt
               , oea.segment3          org_bank_name
               , oea.segment4          org_bank_branch
               , oea.segment1          bank_acc_num
  FROM
         pay_org_payment_methods_f      popm
  ,      pay_external_accounts          pea
  ,      pay_personal_payment_methods_f pppm
  ,      pay_external_accounts          oea
  ,      pay_pre_payments               ppp
  ,      pay_assignment_actions         paa
  ,      pay_payroll_actions            ppa
  ,      per_assignments_f              asg
  ,      per_people_f                   per
  ,      hr_organization_units          org
  ,      hr_organization_information    hoi
  ,      hr_organization_units          hou
  ,      pay_payment_types              ppto
  WHERE  ppa.payroll_action_id           = g_pay_action_param
  AND    ppp.pre_payment_id              = paa.pre_payment_id
  AND    paa.payroll_action_id           = ppa.payroll_action_id
  AND    ppa.business_group_id           = popm.business_group_id
  AND    oea.external_account_id         = popm.external_account_id
  AND    ppa.business_group_id           = org.organization_id
  AND    popm.org_payment_method_id      = ppp.org_payment_method_id
  AND    pea.external_account_id         = popm.external_account_id
  AND    pppm.personal_payment_method_id = ppp.personal_payment_method_id
  AND    paa.assignment_id               = asg.assignment_id
  AND    asg.person_id                   = per.person_id
  AND    ppa.effective_date BETWEEN popm.effective_start_date AND popm.effective_end_date
  AND    ppa.effective_date BETWEEN pppm.effective_start_date AND pppm.effective_end_date
  AND    ppa.effective_date BETWEEN  asg.effective_start_date AND  asg.effective_end_date
  AND    ppa.effective_date BETWEEN  per.effective_start_date AND  per.effective_end_date
  AND    hoi.organization_id = g_reg_er_param
  AND    hoi.org_information_context = 'PER_IN_COMPANY_DF'
  AND    hou.organization_id = hoi.organization_id
  AND    hou.business_group_id = ppa.business_group_id
  AND    ppto.category = 'MT'
  AND    popm.payment_type_id = ppto.payment_type_id
  AND    popm.org_payment_method_id = g_org_pay_meth_param
     )
GROUP BY
        'COMPANY_NAME=P'
       , company_name1
       ,'NUMBER_OF_DATA_RECORDS=P'
       ,'TOTAL_PAYMENT_AMOUNT=P'
       ,'PAYMENT_BANK_NAME=P'
       , org_bank_name
       ,'PAYMENT_BANK_BRANCH=P'
       , org_bank_branch
       ,'PAYMENT_BANK_ACCOUNT_NUMBER=P'
       , bank_acc_num
       ,'PAYMENT_DATE=P'
       , g_pay_date_param;

--Cursor to retrieve data records
CURSOR   c_eft_data IS
SELECT  'EMPLOYEE_NUMBER=P'
       , emp_num
       ,'EMPLOYEE_NAME1=P'
       , emp_name1
       ,'EMPLOYEE_NAME2=P'
       , emp_name2
       ,'EMPLOYEE_NAME3=P'
       , emp_name3
       ,'EMPLOYEE_BANK=P'
       , emp_bank
       ,'EMPLOYEE_BRANCH=P'
       , emp_branch
       ,'EMPLOYEE_ACCOUNT_NUMBER=P'
       , emp_acc_num
       ,'PAYMENT_AMOUNT=P'
       , payment_amt
  FROM (SELECT  per.employee_number                                     emp_num
              , SUBSTR(per.full_name,1,80)                              emp_name1
              , SUBSTR(per.full_name,81,80)                             emp_name2
              , SUBSTR(per.full_name,161,80)                            emp_name3
              , hr_general.decode_lookup('IN_BANK',pea.segment3)        emp_bank
              , hr_general.decode_lookup('IN_BANK_BRANCH',pea.segment4) emp_branch
              , pea.segment1                                            emp_acc_num
              , NVL(ppp.value,0)                                        payment_amt
  FROM   pay_org_payment_methods_f      popm
  ,      pay_external_accounts          oea
  ,      pay_personal_payment_methods_f pppm
  ,      pay_external_accounts          pea
  ,      pay_pre_payments               ppp
  ,      pay_assignment_actions         paa
  ,      pay_payroll_actions            ppa
  ,      per_assignments_f              asg
  ,      per_people_f                   per
  ,      hr_organization_units          org
  ,      pay_payment_types              ppto
  WHERE  ppa.payroll_action_id           = g_pay_action_param
  AND    ppp.pre_payment_id              = paa.pre_payment_id
  AND    paa.payroll_action_id           = ppa.payroll_action_id
  AND    ppa.business_group_id           = popm.business_group_id
  AND    oea.external_account_id         = popm.external_account_id
  AND    ppa.business_group_id           = org.organization_id
  AND    popm.org_payment_method_id      = ppp.org_payment_method_id
  AND    pea.external_account_id         = pppm.external_account_id
  AND    pppm.personal_payment_method_id = ppp.personal_payment_method_id
  AND    paa.assignment_id               = asg.assignment_id
  AND    asg.person_id                   = per.person_id
  AND    ppa.effective_date BETWEEN popm.effective_start_date AND popm.effective_end_date
  AND    ppa.effective_date BETWEEN pppm.effective_start_date AND pppm.effective_end_date
  AND    ppa.effective_date BETWEEN  asg.effective_start_date AND  asg.effective_end_date
  AND    ppa.effective_date BETWEEN  per.effective_start_date AND  per.effective_end_date
  AND    ppto.category = 'MT'
  AND    popm.payment_type_id = ppto.payment_type_id
  AND    popm.org_payment_method_id = g_org_pay_meth_param
       )
ORDER BY emp_bank
       , emp_branch
       , emp_num ASC;

END pay_in_eft;

/
