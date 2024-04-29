--------------------------------------------------------
--  DDL for Package PAY_AE_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AE_EFT" AUTHID CURRENT_USER as
/* $Header: pyaeeftp.pkh 120.0 2005/10/03 22:31:04 spendhar noship $ */
level_cnt NUMBER;
l_id_header number;
l_id_body number;
l_id_footer number;
l_payment_method_id  number(15);
--
FUNCTION get_customer_formula_header    (
                                 p_Date_Earned  IN DATE
                                ,p_payment_method_id IN number
                                ,p_business_group_id IN number
                                ,p_payroll_id IN number
                                ,p_payroll_action_id IN number
                                ,p_creation_date  IN VARCHAR2
                                ,p_process_date   IN VARCHAR2
                                ,p_count          IN VARCHAR2
                                ,p_sumt            IN VARCHAR2
                                ,p_sumc IN VARCHAR2
				,p_sumd IN VARCHAR2
                                ,p_write_text1  OUT NOCOPY VARCHAR2
                                ,p_write_text2  OUT NOCOPY VARCHAR2
                                ,p_write_text3  OUT NOCOPY VARCHAR2
                                ,p_write_text4  OUT NOCOPY VARCHAR2
                                ,p_write_text5  OUT NOCOPY VARCHAR2
                                ,p_report_text1 OUT NOCOPY VARCHAR2
                                ,p_report_text2 OUT NOCOPY VARCHAR2
                                ,p_report_text3 OUT NOCOPY VARCHAR2
                                ,p_report_text4 OUT NOCOPY VARCHAR2
                                ,p_report_text5 OUT NOCOPY VARCHAR2
                                ,p_report_text6 OUT NOCOPY VARCHAR2
                                ,p_report_text7 OUT NOCOPY VARCHAR2
                                ,p_report_text8 OUT NOCOPY VARCHAR2
                                ,p_report_text9 OUT NOCOPY VARCHAR2
                                ,p_report_text10 OUT NOCOPY VARCHAR2
				,p_bank_code IN VARCHAR2
				,p_employer_code IN VARCHAR2
				,p_tape_type IN VARCHAR2
				) return varchar2;
--
--
FUNCTION get_customer_formula_footer    (
                                 p_Date_Earned   IN DATE
                                ,p_payment_method_id IN number
                                ,p_business_group_id IN number
                                ,p_payroll_id IN number
                                ,p_payroll_action_id IN number
                                ,p_creation_date  IN VARCHAR2
                                ,p_process_date   IN VARCHAR2
                                ,p_count          IN VARCHAR2
                                ,p_sumt            IN VARCHAR2
                                ,p_sumc IN VARCHAR2
				,p_sumd IN VARCHAR2
                                ,p_write_text1  OUT NOCOPY VARCHAR2
                                ,p_write_text2  OUT NOCOPY VARCHAR2
                                ,p_write_text3  OUT NOCOPY VARCHAR2
                                ,p_write_text4  OUT NOCOPY VARCHAR2
                                ,p_write_text5  OUT NOCOPY VARCHAR2
                                ,p_report_text1 OUT NOCOPY VARCHAR2
                                ,p_report_text2 OUT NOCOPY VARCHAR2
                                ,p_report_text3 OUT NOCOPY VARCHAR2
                                ,p_report_text4 OUT NOCOPY VARCHAR2
                                ,p_report_text5 OUT NOCOPY VARCHAR2
                                ,p_report_text6 OUT NOCOPY VARCHAR2
                                ,p_report_text7 OUT NOCOPY VARCHAR2
                                ,p_report_text8 OUT NOCOPY VARCHAR2
                                ,p_report_text9 OUT NOCOPY VARCHAR2
                                ,p_report_text10 OUT NOCOPY VARCHAR2
				,p_bank_code IN VARCHAR2
				,p_employer_code IN VARCHAR2
				,p_tape_type IN VARCHAR2
				) return varchar2;
--
--
FUNCTION get_customer_formula_body      (
                                p_assignment_id IN number,
                                p_business_group_id IN number,
                                p_per_pay_method_id IN number,
                                p_date_earned IN date,
                                p_payroll_id IN number,
                                p_payroll_action_id IN number,
                                p_assignment_action_id IN number,
                                p_organization_id IN number,
                                p_tax_unit_id IN number,
                                p_amount IN varchar2,
                                p_first_name IN varchar2,
                                p_last_name IN varchar2,
                                p_initials IN varchar2,
                                p_emp_no IN varchar2,
                                p_asg_no IN varchar2,
                                p_count IN varchar2,
                                p_sumt IN varchar2
                                ,p_sumc IN VARCHAR2
				,p_sumd IN VARCHAR2
                                ,p_write_text1  OUT NOCOPY VARCHAR2
                                ,p_write_text2  OUT NOCOPY VARCHAR2
                                ,p_write_text3  OUT NOCOPY VARCHAR2
                                ,p_write_text4  OUT NOCOPY VARCHAR2
                                ,p_write_text5  OUT NOCOPY VARCHAR2
                                ,p_report_text1 OUT NOCOPY VARCHAR2
                                ,p_report_text2 OUT NOCOPY VARCHAR2
                                ,p_report_text3 OUT NOCOPY VARCHAR2
                                ,p_report_text4 OUT NOCOPY VARCHAR2
                                ,p_report_text5 OUT NOCOPY VARCHAR2
                                ,p_report_text6 OUT NOCOPY VARCHAR2
                                ,p_report_text7 OUT NOCOPY VARCHAR2
                                ,p_report_text8 OUT NOCOPY VARCHAR2
                                ,p_report_text9 OUT NOCOPY VARCHAR2
                                ,p_report_text10 OUT NOCOPY VARCHAR2
                                ,p_local_nationality IN VARCHAR2
				,p_bank_code IN VARCHAR2
				,p_employer_code IN VARCHAR2
				,p_trancode IN VARCHAR2
				,p_tape_type IN VARCHAR2
				) return varchar2;
--
PROCEDURE run_formula(p_formula_id      IN NUMBER
                     ,p_effective_date  IN DATE
                     ,p_inputs          IN ff_exec.inputs_t
                     ,p_outputs         IN OUT NOCOPY ff_exec.outputs_t);


/********************************************************
*       Cursor to fetch header record information       *
********************************************************/
CURSOR CSR_AE_EFT_HEADER IS
SELECT 'CREATION_DATE=P'
      ,to_char(ppa.effective_date, 'DDMMYYYY')
      ,'PROCESS_DATE=P'
      ,to_char(fnd_date.canonical_to_date(pay_ae_general.get_parameter(
                                            ppa.legislative_parameters,
                                            'PROCESS_DATE')), 'DDMMYYYY')
      ,'DATE_EARNED=C'
      ,to_char(ppa.effective_date, 'YYYY/MM/DD HH24:MI:SS')
      ,'ORG_PAY_METHOD_ID=C'
      ,ppa.org_payment_method_id
      ,'BUSINESS_GROUP_ID=C'
      ,ppa.business_group_id
      ,'PAYROLL_ID=C'
      ,ppa.payroll_id
      ,'PAYROLL_ACTION_ID=C'
      ,ppa.payroll_action_id
       ,'COUNT1=P'
      ,pay_ae_general.get_count
      ,'SUMT=P'
      ,nvl(to_char(pay_ae_general.get_total_sum  * 100),'0')
      ,'SUMC=P'
      ,nvl(to_char(pay_ae_general.get_credit_sum * 100),'0')
      ,'SUMD=P'
      ,nvl(to_char(pay_ae_general.get_debit_sum  * 100),'0')
      ,'TAPE_TYPE=P'
      ,nvl(pay_ae_general.get_parameter(ppa.legislative_parameters,'TAPE_TYPE'),' ')
FROM   pay_payroll_actions ppa
WHERE  ppa.payroll_action_id =
       pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
       AND    EXISTS (
       SELECT 1
       FROM    pay_assignment_actions pas
              ,pay_pre_payments       ppp
       WHERE   pas.payroll_action_id = ppa.payroll_action_id
       AND     ppp.pre_payment_id    = pas.pre_payment_id
       AND     ppp.value <> 0 );


/********************************************************
*   Cursor to fetch batch/payment record information    *
********************************************************/
CURSOR CSR_AE_EFT_BODY IS
SELECT 'AMOUNT=P'
      ,ppp.value * 100
      ,'TRANCODE=P'
      ,decode(pay_ae_general.chk_tran_code(ppp.value)
                                      ,'Y','C'
                                      ,'N', 'D')
      ,'FIRST_NAME=P'
      , substr(pef.full_name,1,40)
      ,'LAST_NAME=P'
      , substr(pef.last_name,1,35)
      ,'INITIALS=P'
      ,substr(pef.per_information1,1,35)
      ,'EMP_NO=P'
      , nvl(pef.employee_number,' ')
      ,'ASG_NO=P'
      ,decode(pay_ae_general.chk_multiple_assignments(ppa.effective_date,paf.person_id)
                                      ,'Y',nvl(paf.assignment_number,' ')
                                      ,'N', ' ')
      ,'ASSIGNMENT_ID=C' , paf.assignment_id
      ,'BUSINESS_GROUP_ID=C' , paf.business_group_id
      ,'PER_PAY_METHOD_ID=C' , ppp.personal_payment_method_id
      ,'ORG_PAY_METHOD_ID=C' , ppa.org_payment_method_id
      ,'DATE_EARNED=C' , to_char(ppa.effective_date, 'YYYY/MM/DD HH24:MI:SS')
      ,'PAYROLL_ID=C' , ppa.payroll_id
      ,'PAYROLL_ACTION_ID=C' , ppa.payroll_action_id
      ,'ASSIGNMENT_ACTION_ID=C', ppa.org_payment_method_id
      ,'ORGANIZATION_ID=C' , paf.organization_id
      ,'TAX_UNIT_ID=C' , paa.tax_unit_id
      ,'LOCAL_NATIONALITY=P'
      ,pay_ae_general.get_parameter(ppa.legislative_parameters,
                                'LOCAL_NATIONALITY')
FROM  per_assignments_f            paf
      ,per_people_f                 pef
      ,pay_pre_payments             ppp
      ,pay_assignment_actions       paa
      ,pay_payroll_actions          ppa
WHERE  paa.payroll_action_id          =
       pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND    paa.pre_payment_id             = ppp.pre_payment_id
AND    paa.payroll_action_id          = ppa.payroll_action_id
AND    paa.assignment_id              = paf.assignment_id
AND    paf.person_id                  = pef.person_id
AND    ppp.value                      <> 0
AND    ppa.effective_date BETWEEN paf.effective_start_date
                              AND paf.effective_end_date
AND    ppa.effective_date BETWEEN pef.effective_start_date
                              AND pef.effective_end_date
ORDER BY decode(pay_ae_general.get_parameter(legislative_parameters,
                                  'SORT_ORDER'),
                                  'NAME', substr(pef.last_name || ' ' || pef.first_name,1,50),
                                  'NUMBER', pef.employee_number, null);
END PAY_AE_EFT;


 

/
