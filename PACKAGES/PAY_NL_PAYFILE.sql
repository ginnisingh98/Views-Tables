--------------------------------------------------------
--  DDL for Package PAY_NL_PAYFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_PAYFILE" AUTHID CURRENT_USER as
/* $Header: pynleftp.pkh 120.1.12010000.2 2009/07/29 12:14:33 namgoyal ship $ */

level_cnt NUMBER;
--

FUNCTION  get_payee_details(p_assignment_id              IN NUMBER
                           ,p_business_group_id          IN NUMBER
                           ,p_per_pay_method_id          IN NUMBER
                           ,p_date_earned                IN DATE
                           ,p_payee_address              OUT NOCOPY VARCHAR2
                           ) RETURN VARCHAR2;

PROCEDURE cache_formula(p_formula_name           IN VARCHAR2
                        ,p_business_group_id     IN NUMBER
                        ,p_effective_date        IN DATE
                        ,p_formula_id		 IN OUT NOCOPY NUMBER
                        ,p_formula_exists	 IN OUT NOCOPY BOOLEAN
                        ,p_formula_cached	 IN OUT NOCOPY BOOLEAN
                        );

PROCEDURE run_formula(p_formula_id      IN NUMBER
                     ,p_effective_date  IN DATE
                     ,p_formula_name    IN VARCHAR2
                     ,p_inputs          IN ff_exec.inputs_t
                     ,p_outputs         IN OUT NOCOPY ff_exec.outputs_t);

FUNCTION get_transaction_desc (p_assignment_id 		IN NUMBER
			      ,p_date_earned 		IN DATE
			      ,p_business_group_id 	IN NUMBER
	                      ,p_transaction_desc	IN VARCHAR2
	                      ,p_prepayment_id          IN VARCHAR2
			       ) RETURN VARCHAR2;

FUNCTION  get_payee_address(p_payee_id   IN NUMBER
                           ,p_payee_type IN VARCHAR2
                           ,p_effective_date IN DATE) RETURN VARCHAR2;


/********************************************************
*       Cursor to fetch header record information       *
********************************************************/

CURSOR CSR_NL_PAYFILE_HEADER IS
SELECT 'CREATION_DATE=P'
      ,to_char(ppa.effective_date, 'DDMMYY')
      ,'PROCESS_DATE=P'
      ,to_char(fnd_date.canonical_to_date(pay_nl_general.get_parameter(
                                            ppa.legislative_parameters,
                                            'PROCESS_DATE')), 'DDMMYY')
      ,'FILE_ID=P'
      , pay_nl_general.get_file_id(ppa.effective_date)
      ,'BATCH_DESCRIPTION=P'
      ,nvl(pay_nl_general.get_parameter(ppa.legislative_parameters, 'BATCH_DESC'),' ')
      ,'USER_NAME=P'
      ,pay_nl_general.get_parameter(ppa.legislative_parameters, 'USER_NAME')
      ,'DATE_EARNED=C'
      ,to_char(ppa.effective_date, 'YYYY/MM/DD HH24:MI:SS')
      ,'ORG_PAY_METHOD_ID=C'
      ,ppa.org_payment_method_id
FROM   pay_payroll_actions ppa
WHERE  ppa.payroll_action_id =
       pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
       AND    EXISTS (
       SELECT 1
       FROM    pay_assignment_actions pas
              ,pay_pre_payments       ppp
       WHERE   pas.payroll_action_id = ppa.payroll_action_id
       AND     ppp.pre_payment_id    = pas.pre_payment_id
       AND     ppp.value > 0 );



/********************************************************
*   Cursor to fetch batch/payment record information    *
********************************************************/

CURSOR CSR_NL_PAYFILE_BODY IS
SELECT 'AMOUNT=P'
      ,sum(ppp.value*100)
      ,'FIRST_NAME=P'
      , substr(min(pef.first_name),1,35)
      ,'LAST_NAME=P'
      , substr(min(pef.last_name),1,35)
      ,'INITIALS=P'
      ,substr(min(pef.per_information1),1,35)
      ,'EMP_NO=P'
      , nvl(min(pef.employee_number),' ')
      ,'ASG_NO=P'
      ,decode(min(pay_nl_general.chk_multiple_assignments(ppa.effective_date,paf.person_id))
                                      ,'Y',nvl(min(paf.assignment_number),' ')
                                     ,'N', ' ')
      ,'SUPPRESS_PAYEE_RECORD=P'
      ,min(pay_nl_general.get_parameter(ppa.legislative_parameters,'SUPPRESS_PAYEE_RECORD'))
      ,'ASSIGNMENT_ID=C'
      , min(paf.assignment_id)
      ,'BUSINESS_GROUP_ID=C'
      , min(paf.business_group_id)
      ,'PER_PAY_METHOD_ID=C'
      ,min(ppp.personal_payment_method_id)
      ,'DATE_EARNED=C'
      ,to_char(min(ppa.effective_date), 'YYYY/MM/DD HH24:MI:SS')
      ,'PRE_PAYMENT_ID=P'
      ,min(ppp.pre_payment_id)
FROM  per_assignments_f             paf
      ,per_people_f                 pef
      ,pay_pre_payments             ppp
      ,pay_assignment_actions       paa
      ,pay_payroll_actions          ppa
      ,pay_personal_payment_methods_f ppmf
      ,pay_external_accounts        pea
WHERE  paa.payroll_action_id          =
       pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
AND    paa.pre_payment_id             = ppp.pre_payment_id
AND    paa.payroll_action_id          = ppa.payroll_action_id
AND    PPP.personal_payment_method_id = ppmf.personal_payment_method_id
AND    paa.assignment_id              = paf.assignment_id
AND    paf.person_id                  = pef.person_id
AND    ppp.value                      > 0
AND    pea.external_account_id  = ppmf.external_account_id
AND    ppa.effective_date BETWEEN paf.effective_start_date
                              AND paf.effective_end_date
AND    ppa.effective_date BETWEEN pef.effective_start_date
                              AND pef.effective_end_date
AND    ppa.effective_date BETWEEN ppmf.effective_start_date
                              AND ppmf.effective_end_date

/* This is for consolidating the third-party payments having same
    account number for an employee.This will group the payments
    by account number and person id if the user wishes to consolidate
    else it will group by assignment id */

Group by decode (pay_nl_general.get_parameter (legislative_parameters,
                       'ACCOUNTNO_CONSOLIDATION'),'Y', (lpad(pef.person_id,10,0) ||lpad(pea.segment2,10,0)),
		         (lpad(paf.assignment_id,10,0)||lpad(pea.segment2,10,0)))

ORDER BY decode(min(pay_nl_general.get_parameter(legislative_parameters,
                                  'SORT_ORDER')),
                                  'NAME', substr(min(pef.last_name) || ' ' || min(pef.first_name),1,30),
                                  'NUMBER', min(pef.employee_number), null);

--Cash Management Reconciliation function
FUNCTION f_get_payfile_recon_data (p_effective_date        IN DATE,
                                   p_identifier_name       IN VARCHAR2,
	                           p_payroll_action_id	   IN NUMBER,
	                           p_payment_type_id	   IN NUMBER,
	                           p_org_payment_method_id	IN NUMBER,
	                           p_personal_payment_method_id	IN NUMBER,
	                           p_assignment_action_id	IN NUMBER,
	                           p_pre_payment_id	        IN NUMBER,
	                           p_delimiter_string   	IN VARCHAR2)
RETURN VARCHAR2;


END PAY_NL_PAYFILE;

/
