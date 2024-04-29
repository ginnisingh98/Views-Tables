--------------------------------------------------------
--  DDL for Package PAY_CN_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_EFT" AUTHID CURRENT_USER AS
/* $Header: pycneft.pkh 120.4 2006/12/13 12:38:56 sukukuma noship $ */

level_cnt NUMBER;
g_start_date_param   CONSTANT VARCHAR2(20) := pay_magtape_generic.get_parameter_value('START_DATE_PARAM');
g_eff_date_param     CONSTANT VARCHAR2(20) := pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE_PARAM');
g_cons_set_param     CONSTANT pay_consolidation_sets.consolidation_set_id%TYPE :=
                                      pay_magtape_generic.get_parameter_value('CONSOLIDATION_SET_PARAM');
g_pay_action_param   CONSTANT pay_payroll_actions.payroll_action_id%TYPE :=
                                      pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
g_org_pay_meth_param CONSTANT pay_org_payment_methods_f.org_payment_method_id%TYPE :=
                                      pay_magtape_generic.get_parameter_value('ORG_PAYMENT_METHOD_PARAM');
g_legal_er_param     CONSTANT hr_organization_units.organization_id%TYPE :=
                                      pay_magtape_generic.get_parameter_value('LEGAL_EMPLOYER_PARAM');



--Cursor to retrieve CCBS Header Info
CURSOR  c_ccbs_header IS
SELECT 'COMPANY_NAME=P'
       , gre_name  /* 3592894, replaced gre_name with action_information18 */
       ,'NUMBER_OF_DATA_RECORDS=P'
       ,   count(*)
       ,'TOTAL_PAYMENT_AMOUNT=P'
       ,   sum(payment_amount)*100
       ,'PAYMENT_BANK_NAME=P'
       ,   org_bank_name
       ,'PAYMENT_PERIOD=P' /* Bug 3260333, replaced payment date with payment period*/
       , TO_CHAR(effective_date,'YYYY/MM')  /* 3592894, replaced payment date with effective date*/
       ,'PAYMENT_METHOD=P'
       ,   personal_payment_method_name
       ,'CURRENCY=P'
       ,   currency_code
FROM   ( SELECT hou.name                        gre_name
              , ppp.value                       payment_amount
	      , pea.segment1                     org_bank_name
	      , ppa.effective_date              effective_date
	      ,opm.org_payment_method_name      personal_payment_method_name
	      ,opm.currency_code                currency_code
	FROM   pay_pre_payments                 ppp
	      ,pay_payroll_actions              ppa
	      ,pay_assignment_actions           paa
	      ,pay_org_payment_methods_f        opm
	      ,pay_personal_payment_methods_f   ppm
	      ,pay_external_accounts            pea
              ,hr_organization_units            hou
	WHERE  ppa.payroll_action_id= g_pay_action_param
	AND    paa.payroll_action_id = ppa.payroll_action_id
	AND    ppp.pre_payment_id = paa.pre_payment_id
	AND    opm.org_payment_method_id = ppp.org_payment_method_id
	AND    ppm.personal_payment_method_id =ppp.personal_payment_method_id
	AND    pea.external_account_id = opm.external_account_id
	AND    hou.organization_id = g_legal_er_param
	AND    ppa.effective_date BETWEEN opm.effective_start_date AND opm.effective_end_date
	AND    ppa.effective_date BETWEEN ppm.effective_start_date AND ppm.effective_end_date
	)
GROUP BY
       'COMPANY_NAME=P'
       , gre_name
       ,'NUMBER_OF_DATA_RECORDS=P'
       ,'TOTAL_PAYMENT_AMOUNT=P'
       ,'PAYMENT_BANK_NAME=P'
       , org_bank_name
       ,'PAYMENT_PERIOD=P'
       ,TO_CHAR(effective_date,'YYYY/MM')
       ,'PAYMENT_METHOD=P'
       , personal_payment_method_name
       ,'CURRENCY=P'
       , currency_code;

--Cursor to retrieve CCBS data
CURSOR   c_ccbs_data IS
SELECT  'ORGANIZATION_NAME=P'
       ,  organization_name
       ,'EMPLOYEE_NUMBER=P'
       ,  employee_number
       ,'PAYEE_NAME=P'
       ,  payee_name
       ,'EMPLOYEE_ACCOUNT_NUMBER=P'
       ,  personal_bank_account_number
       ,'PAYMENT_AMOUNT=P'
       ,  TO_CHAR(payment_amount*100 )
    FROM ( SELECT hou.name                 organization_name
                 ,ppf.employee_number      employee_number
                 ,ppf.full_name            payee_name
                 ,pea.segment3             personal_bank_account_number
                 ,ppp.value                payment_amount
           FROM   pay_pre_payments ppp
                 ,pay_payroll_actions ppa
                 ,pay_assignment_actions paa
                 ,pay_org_payment_methods_f opm
                 ,pay_personal_payment_methods_f ppm
                 ,pay_external_accounts      pea
                 ,per_assignments_f             paf
                 ,hr_organization_units         hou
                 ,per_people_f                  ppf
           WHERE  ppa.payroll_action_id= g_pay_action_param
	   AND    paa.payroll_action_id = ppa.payroll_action_id
	   AND    ppp.pre_payment_id = paa.pre_payment_id
	   AND    opm.org_payment_method_id = ppp.org_payment_method_id
	   AND    ppm.personal_payment_method_id =ppp.personal_payment_method_id
	   AND    pea.external_account_id = ppm.external_account_id
           AND    paa.assignment_id       = paf.assignment_id
           AND    hou.organization_id     = paf.organization_id
           AND    ppf.person_id           = paf.person_id
           AND    ppa.effective_date BETWEEN opm.effective_start_date AND opm.effective_end_date
           AND    ppa.effective_date BETWEEN ppm.effective_start_date AND ppm.effective_end_date
           AND    ppa.effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
	   AND    ppa.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date)
           ORDER BY organization_name,employee_number ASC;

END pay_cn_eft;

/
