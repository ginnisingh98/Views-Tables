--------------------------------------------------------
--  DDL for Package PAY_NO_PAYPROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_PAYPROC" AUTHID CURRENT_USER AS
/* $Header: pynopproc.pkh 120.0.12000000.1 2007/01/17 23:09:45 appldev noship $ */

 level_cnt NUMBER;

--
-- PROCEDURE range_cursor
-- Procedure which stamps the payroll action with the PAYROLL_ID (if
-- supplied), then returns a varchar2 defining a SQL Stateent to select
-- all the people in the business group.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
--
-- to return parameter values from legislative parameters in pay_payroll_actions
--

 PROCEDURE range_cursor(
                p_payroll_action_id     IN  NUMBER,
                p_sqlstr                OUT NOCOPY VARCHAR2);

PROCEDURE assignment_action_code(
                p_payroll_action_id     IN NUMBER,
                p_start_person_id       IN NUMBER,
                p_end_person_id         IN NUMBER,
                p_chunk_number          IN NUMBER);


CURSOR CSR_NO_PP_HEADER IS
SELECT
      'CREATION_DATE=P'
      ,to_char(ppa.effective_date, 'YYYYMMDD')
      ,'PAYMENT_DATE=P'
      ,to_char(fnd_date.canonical_to_date(PAY_NO_PAYPROC_UTILITY.get_parameter(ppa.payroll_action_id,'PAYMENT_DATE')), 'YYYYMMDD')
      ,'LEGAL_EMPLOYER=P'
      , to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(ppa.payroll_action_id,'LEGAL_EMPLOYER'))
      ,'AH_SEQ_NO=P'
      ,to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(ppa.payroll_action_id,'AH_SEQUENCE_NUMBER'))
      ,'DIVISION=P'
      ,PAY_NO_PAYPROC_UTILITY.get_parameter(ppa.payroll_action_id,'DIVISION')
      ,'PASSWORD=P'
      ,PAY_NO_PAYPROC_UTILITY.get_parameter(ppa.payroll_action_id,'PASSWORD')
      ,'NEW_PASSWORD=P'
      ,PAY_NO_PAYPROC_UTILITY.get_parameter(ppa.payroll_action_id,'NEW_PASSWORD')
      ,'SEQ_CONTROL=P'
      ,to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(ppa.payroll_action_id,'SEQUENCE_CONTROL'))
      ,'MAGNETIC_FILE_NAME=P'
      ,ppa.magnetic_file_name
      ,'REPORT_FILE_NAME=P'
      ,ppa.report_file_name
      ,'DATE_EARNED=C'
      ,to_char(ppa.effective_date, 'YYYY/MM/DD HH24:MI:SS')
      ,'ORG_PAY_METHOD_ID=C'
      ,ppp.org_payment_method_id
      ,'BUSINESS_GROUP_ID=C'
      ,ppa.business_group_id
      ,'PAYROLL_ID=C'
      ,paf.payroll_id
      ,'PAYROLL_ACTION_ID=C'
      ,ppa.payroll_action_id

FROM   pay_payroll_actions ppa,
            pay_assignment_actions paa,
            per_all_assignments_f  paf,
            pay_pre_payments       ppp

where  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  and    ppp.pre_payment_id              = paa.pre_payment_id
  and    ppp.value                      > 0
  and    paa.payroll_action_id           = ppa.payroll_action_id
  and    paa.assignment_id               = paf.assignment_id
  and rownum < 2;


CURSOR CSR_NO_PP_BODY IS

SELECT 'AMOUNT=P'
      ,ppp.value
      ,'EMPLOYEE_NUMBER=P'
      ,pef.EMPLOYEE_NUMBER
      ,'FIRST_NAME=P'
      , substr(pef.first_name,1,35)
      ,'LAST_NAME=P'
      ,substr(pef.last_name,1,35)
      ,'ORG_ACCOUNT_NO=P'
      ,pea.segment6
      ,'EXTERNAL_ACCOUNT=P'
      ,PAY_NO_PAYPROC_UTILITY.get_account_no(ppp.personal_payment_method_id,paf.payroll_id,ppa.effective_date)
      ,'MASS_OR_INVOICE_F=P'
      ,PAY_NO_PAYPROC_UTILITY.get_payment_invoice_or_mass(ppp.personal_payment_method_id,paf.payroll_id,ppa.effective_date) mass_or_invoice
      ,'ASSIGNMENT_ID=C' , paf.assignment_id
      ,'BUSINESS_GROUP_ID=C' , paf.business_group_id
      ,'PER_PAY_METHOD_ID=C' , NVL(ppp.personal_payment_method_id,PAY_NO_PAYPROC_UTILITY.get_payment_method_id(paf.payroll_id,ppa.effective_date))
      ,'ORG_PAY_METHOD_ID=C' , ppp.org_payment_method_id
      ,'DATE_EARNED=C' , to_char(ppa.effective_date, 'YYYY/MM/DD HH24:MI:SS')
      ,'PAYROLL_ID=C' , paf.payroll_id
      ,'PAYROLL_ACTION_ID=C' , ppa.payroll_action_id
      ,'ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id

  FROM    pay_assignment_actions paa,
          per_all_assignments_f  paf,
          pay_payroll_actions    ppa,
          pay_pre_payments       ppp,
          pay_org_payment_methods_f pop,
          per_all_people_f	  pef,
          pay_external_accounts        pea,
   	  hr_soft_coding_keyflex hsk,
	  pay_payment_types ppt

where  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  and    ppp.pre_payment_id              = paa.pre_payment_id
  and    ppp.value                      > 0
  and    paa.payroll_action_id           = ppa.payroll_action_id
  and    pop.org_payment_method_id      = ppp.org_payment_method_id
  and    ppt.payment_type_id= pop.payment_type_id
  and    ( ppt.payment_type_name like 'NO Money Order' or ppt.category in ('MT'))
  and    pop.external_account_id         = pea.external_account_id
  and    paa.assignment_id               = paf.assignment_id
  and    hsk.SOFT_CODING_KEYFLEX_ID = paf.SOFT_CODING_KEYFLEX_ID
  and    hsk.enabled_flag = 'Y'
  and    hsk.segment2 in (
       select hoi2.org_information1
       from HR_ORGANIZATION_UNITS o1
	  , HR_ORGANIZATION_INFORMATION hoi1
	  , HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id = ppa.business_group_id
            and hoi1.organization_id = o1.organization_id
            and hoi1.organization_id =  to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(ppa.payroll_action_id,'LEGAL_EMPLOYER'))
            and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
            and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            and hoi1.organization_id = hoi2.organization_id
            and hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
                        )
  and    paf.person_id                     = pef.person_id
  and    paf.payroll_id                    = nvl(ppa.payroll_id,paf.payroll_id )
  and    ppa.effective_date between pop.effective_start_date and pop.effective_end_date
  and    ppa.effective_date between    paf.effective_start_date and paf.effective_end_date
  and    ppa.effective_date between    pef.effective_start_date and pef.effective_end_date
  ORDER BY mass_or_invoice,paf.organization_id,substr(pef.last_name || ' ' || pef.first_name,1,50);
---------------------------------------------------------------------------------------
CURSOR CSR_NO_PP_AUDIT_EMP IS

   SELECT
      'AMOUNT=P'
      ,ppp.value
      ,'EMPLOYEE_NUMBER=P'
      ,pap.EMPLOYEE_NUMBER
      ,'FIRST_NAME=P'
      , substr(pap.first_name,1,35)
      ,'LAST_NAME=P'
      ,substr(pap.last_name,1,35)
   FROM   pay_assignment_actions act,
          per_all_assignments_f  asg,
          pay_payroll_actions    pa2,
          pay_payroll_actions    pa1,
          pay_pre_payments       ppp,
          pay_org_payment_methods_f OPM,
          per_all_people_f	  pap,
          hr_soft_coding_keyflex hsk,
          pay_payment_types ppt

   WHERE  pa1.payroll_action_id           = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
   AND    pa2.payroll_id		  = NVL(to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(pa1.payroll_action_id,'PAYROLL_ID')),pa2.payroll_id)
   AND    pa2.effective_date 		  <= pa1.effective_date
   AND    pa2.action_type    		  IN ('U','P') -- Prepayments or Quickpay Prepayments
   AND    act.payroll_action_id		  = pa2.payroll_action_id
   AND    act.action_status    		  = 'C'
   AND    asg.assignment_id    		  = act.assignment_id
   AND    pa1.business_group_id		  = asg.business_group_id
   AND    pa1.effective_date between  asg.effective_start_date and asg.effective_end_date
   AND    pa1.effective_date between  pap.effective_start_date and pap.effective_end_date
   AND    pa1.effective_date between  opm.effective_start_date and opm.effective_end_date
   AND    pap.person_id			  = asg.person_id
   AND    ppp.assignment_action_id 	  = act.assignment_action_id
   AND    ppp.org_payment_method_id 	  = opm.org_payment_method_id
   AND    ppt.payment_type_id= opm.payment_type_id
   AND    ( ppt.payment_type_name like 'NO Money Order' or ppt.category in ('MT'))
   AND    (ppt.category not in ('MT') and not exists ( select '1'
                                               FROM  per_addresses pad
                                              WHERE pad.person_id = asg.person_id
                                                and pad.PRIMARY_FLAG ='Y')
          )
   AND    (to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(pa1.payroll_action_id,'ASSIGNMENT_SET_ID')) IS NULL
   	            OR EXISTS (     SELECT ''
   	    	        	    FROM   hr_assignment_set_amendments hr_asg
   	    	        	    WHERE  hr_asg.assignment_set_id = to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(pa1.payroll_action_id,'ASSIGNMENT_SET_ID'))
   	    	        	    AND    hr_asg.assignment_id     = asg.assignment_id
           	                 ))
   AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
                   FROM   pay_action_interlocks pai1,
                          pay_assignment_actions act2,
                          pay_payroll_actions appa
                   WHERE  pai1.locked_action_id = act.assignment_action_id
                   AND    act2.assignment_action_id = pai1.locking_action_id
                   AND    act2.payroll_action_id = appa.payroll_action_id
                   AND    appa.action_type = 'X'
                   AND    appa.report_type = 'NO_PP')

  and    hsk.SOFT_CODING_KEYFLEX_ID = asg.SOFT_CODING_KEYFLEX_ID
  and    hsk.enabled_flag = 'Y'
  and    hsk.segment2 in (
       select hoi2.org_information1
       from HR_ORGANIZATION_UNITS o1
	  , HR_ORGANIZATION_INFORMATION hoi1
	  , HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id = pa1.business_group_id
            and hoi1.organization_id = o1.organization_id
            and hoi1.organization_id =  to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(pa1.payroll_action_id,'LEGAL_EMPLOYER'))
            and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
            and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            and hoi1.organization_id = hoi2.organization_id
            and hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
                        )
 ORDER BY substr(pap.last_name || ' ' || pap.first_name,1,50);


------------------------------------------------------------------------------------------

 -- Added new select for bug fix 4253729
CURSOR CSR_NO_PP_AUDIT_EMP1 IS

    SELECT
      'AMOUNT=P'
      ,ppp.value
      ,'EMPLOYEE_NUMBER=P'
      ,pap.EMPLOYEE_NUMBER
      ,'FIRST_NAME=P'
      , substr(pap.first_name,1,35)
      ,'LAST_NAME=P'
      ,substr(pap.last_name,1,35)
   FROM   pay_assignment_actions act,
          per_all_assignments_f  asg,
          pay_payroll_actions    pa2,
          pay_payroll_actions    pa1,
          pay_pre_payments       ppp,
          pay_org_payment_methods_f OPM,
          per_all_people_f	  pap,
          hr_soft_coding_keyflex hsk,
          pay_payment_types ppt
   WHERE  pa1.payroll_action_id           = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
   AND    pa2.payroll_id		  = NVL(to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(pa1.payroll_action_id,'PAYROLL_ID')),pa2.payroll_id)
   AND    pa2.effective_date 		  <= pa1.effective_date
   AND    pa2.action_type    		  IN ('U','P') -- Prepayments or Quickpay Prepayments
   AND    act.payroll_action_id		  = pa2.payroll_action_id
   AND    act.action_status    		  = 'C'
   AND    asg.assignment_id    		  = act.assignment_id
   AND    pa1.business_group_id		  = asg.business_group_id
   AND    pa1.effective_date between  asg.effective_start_date and asg.effective_end_date
   AND    pa1.effective_date between  pap.effective_start_date and pap.effective_end_date
   AND    pa1.effective_date between  opm.effective_start_date and opm.effective_end_date
   AND    pap.person_id			  = asg.person_id
   AND    ppp.assignment_action_id 	  = act.assignment_action_id
   AND    ppp.org_payment_method_id 	  = opm.org_payment_method_id
   AND    ppt.payment_type_id= opm.payment_type_id
   AND   ( ppt.category  not in ('MT') and  exists ( select '1'  FROM
						     pay_org_payment_methods_f opm1
						     ,pay_payment_types ppt1
						     ,pay_pre_payments       ppp1
						     WHERE    ppp1.assignment_action_id 	  = act.assignment_action_id--2023513440
						       AND    ppp1.org_payment_method_id 	  = opm1.org_payment_method_id
						       AND    ppt1.payment_type_id= opm1.payment_type_id
						       AND    ppt1.category in ('MT')))
	AND    (to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(pa1.payroll_action_id,'ASSIGNMENT_SET_ID')) IS NULL
   	            OR EXISTS (     SELECT ''
   	    	        	    FROM   hr_assignment_set_amendments hr_asg
   	    	        	    WHERE  hr_asg.assignment_set_id = to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(pa1.payroll_action_id,'ASSIGNMENT_SET_ID'))
   	    	        	    AND    hr_asg.assignment_id     = asg.assignment_id
           	                 ))
   AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
                   FROM   pay_action_interlocks pai1,
                          pay_assignment_actions act2,
                          pay_payroll_actions appa
                   WHERE  pai1.locked_action_id = act.assignment_action_id
                   AND    act2.assignment_action_id = pai1.locking_action_id
                   AND    act2.payroll_action_id = appa.payroll_action_id
                   AND    appa.action_type = 'X'
                   AND    appa.report_type = 'NO_PP')
  and    hsk.SOFT_CODING_KEYFLEX_ID = asg.SOFT_CODING_KEYFLEX_ID
  and    hsk.enabled_flag = 'Y'
  and    hsk.segment2 in (
       select hoi2.org_information1
       from HR_ORGANIZATION_UNITS o1
	  , HR_ORGANIZATION_INFORMATION hoi1
	  , HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id = pa1.business_group_id
            and hoi1.organization_id = o1.organization_id
            and hoi1.organization_id =  to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(pa1.payroll_action_id,'LEGAL_EMPLOYER'))
            and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
            and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            and hoi1.organization_id = hoi2.organization_id
            and hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'                        )
 ORDER BY substr(pap.last_name || ' ' || pap.first_name,1,50);




----------------------------------------------------------------------------------------

CURSOR CSR_NO_PP_AUDIT IS

SELECT 'SUM_AMOUNT=P'
      ,sum(ppp.value)
      ,'ORG_ACCOUNT_NO=P'
      ,pea.segment6

  FROM    pay_assignment_actions paa,
          per_all_assignments_f  paf,
          pay_payroll_actions    ppa,
          pay_pre_payments       ppp,
          pay_org_payment_methods_f pop,
          per_all_people_f	  pef,
          per_addresses pad,
          pay_external_accounts    pea,
   	  hr_soft_coding_keyflex hsk,
          pay_payment_types ppt

where  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  and    ppp.pre_payment_id              = paa.pre_payment_id
  and    ppp.value                      > 0
  and    paa.payroll_action_id           = ppa.payroll_action_id
  and    pop.org_payment_method_id      = ppp.org_payment_method_id
  and    ppt.payment_type_id= pop.payment_type_id
  and    ( ppt.payment_type_name like 'NO Money Order' or ppt.category in ('MT'))
  and    pop.external_account_id         = pea.external_account_id
  and    paa.assignment_id               = paf.assignment_id
  and    hsk.SOFT_CODING_KEYFLEX_ID = paf.SOFT_CODING_KEYFLEX_ID
  and    hsk.segment2 in (
       select hoi2.org_information1
       from HR_ORGANIZATION_UNITS o1
	  , HR_ORGANIZATION_INFORMATION hoi1
	  , HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id = ppa.business_group_id
            and hoi1.organization_id = o1.organization_id
            and hoi1.organization_id =  to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(ppa.payroll_action_id,'LEGAL_EMPLOYER'))
            and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
            and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            and hoi1.organization_id = hoi2.organization_id
            and hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
                        )
  and    paf.person_id                     = pef.person_id
  and    pad.person_id (+)                 = pef.person_id
  and    ( ppt.category in ('MT')  or pad.primary_flag = 'Y')
  and    paf.payroll_id                    = nvl(ppa.payroll_id,paf.payroll_id )
  and    ppa.effective_date between pop.effective_start_date and pop.effective_end_date
  and    ppa.effective_date between    paf.effective_start_date and paf.effective_end_date
  and    ppa.effective_date between    pef.effective_start_date and pef.effective_end_date
  group by pea.segment6;
----------------------------------------------------------------------------------------

FUNCTION get_application_header (
         p_transaction_date in varchar2
	,p_sequence_number in number
	,p_write_text1  OUT NOCOPY VARCHAR2 ) return varchar2;

FUNCTION get_betfor00_record   (
                             p_Date_Earned  IN DATE
                            ,p_payment_method_id IN number
                            ,p_business_group_id IN number
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_production_date  IN VARCHAR2
                            ,p_seq_control  IN VARCHAR2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2
   			    ,p_division in varchar2
			    ,p_password in varchar2
			    ,p_new_password in varchar2) return varchar2;

FUNCTION get_betfor21_mass_record   (
                             p_assignment_id IN number
                            ,p_business_group_id IN number
                            ,p_per_pay_method_id IN number
   			    ,p_org_pay_method_id IN number
                            ,p_date_earned IN date
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_assignment_action_id IN number
                            ,p_org_account_number IN varchar2
                            ,p_payment_date  IN VARCHAR2
                            ,p_seq_control  IN VARCHAR2
			    ,p_enterprise_no IN varchar2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2  ) return varchar2;

FUNCTION get_betfor21_invoice_record   (
                             p_assignment_id IN number
                            ,p_business_group_id IN number
                            ,p_per_pay_method_id IN number
   			    ,p_org_pay_method_id IN number
                            ,p_date_earned IN date
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_assignment_action_id IN number
                            ,p_org_account_number IN varchar2
                            ,p_payment_date  IN VARCHAR2
                            ,p_seq_control  IN VARCHAR2
			    ,p_enterprise_no IN varchar2
			    ,p_payee_first_name in varchar2
			    ,p_payee_last_name in varchar2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2
			    ,p_status OUT NOCOPY VARCHAR2
    			    ,p_audit_address OUT NOCOPY VARCHAR2) return varchar2;

FUNCTION get_betfor23_record   (
                             p_assignment_id IN number
                            ,p_business_group_id IN number
                            ,p_per_pay_method_id IN number
   			    ,p_org_pay_method_id IN number
                            ,p_date_earned IN date
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_assignment_action_id IN number
                            ,p_org_account_number IN varchar2
			    ,p_amount in varchar2
                            ,p_seq_control  IN VARCHAR2
			    ,p_enterprise_no IN varchar2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2  ) return varchar2;

FUNCTION get_betfor22_record   (
                             p_assignment_id IN number
                            ,p_business_group_id IN number
                            ,p_per_pay_method_id IN number
   			    ,p_org_pay_method_id IN number
                            ,p_date_earned IN date
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_assignment_action_id IN number
                            ,p_org_account_number IN varchar2
 			    ,p_last_name in varchar2
			    ,p_first_name in varchar2
			    ,p_amount in varchar2
			    ,p_serial_number in varchar2
                            ,p_seq_control  IN VARCHAR2
			    ,p_enterprise_no IN varchar2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2  ) return varchar2;

FUNCTION get_betfor99_record   (
                             p_Date_Earned  IN DATE
                            ,p_payment_method_id IN number
                            ,p_business_group_id IN number
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_production_date  IN VARCHAR2
                            ,p_seq_control  IN VARCHAR2
			    ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2
			    ,p_enterprise_no in varchar2
    			    ,p_nos_payments in varchar2
			    ,p_nos_records in varchar2) return varchar2;

FUNCTION get_audit_record(
                             p_assignment_id IN number
                            ,p_business_group_id IN number
                            ,p_per_pay_method_id IN number
   			    ,p_org_pay_method_id IN number
                            ,p_date_earned IN date
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_assignment_action_id IN number
  			    ,p_type_of_record  in varchar2
			    ,p_last_name in varchar2
			    ,p_first_name in varchar2
			    ,p_amount in varchar2
                            ,p_report2_text1 OUT NOCOPY VARCHAR2
			    ,p_ni_number in varchar2) return varchar2;

FUNCTION update_seq_values   (
                             p_payroll_id IN number
			    ,p_ah_seq     IN varchar2
                            ,p_seq_control  IN VARCHAR2) return varchar2;

FUNCTION get_next_value(
                              p_sequence varchar2
			     ,p_type varchar2) return varchar2;

FUNCTION get_legal_emp_name(
                              p_business_group_id IN number
                             ,p_legal_emp_id IN varchar2
			     ,p_legal_emp_name  OUT NOCOPY VARCHAR2 ) return varchar2;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* ACknowledgement Reply process */

    PROCEDURE upload(
      errbuf                     OUT NOCOPY   VARCHAR2,
      retcode                    OUT NOCOPY   NUMBER,
      p_file_name                IN           VARCHAR2,
      p_effective_date           IN           VARCHAR2,
      p_business_group_id        IN           VARCHAR2

     );

PROCEDURE read_trans_code
	      (  p_process  IN VARCHAR2
		,p_line     IN VARCHAR2
		,p_trans_code   OUT NOCOPY VARCHAR2
	      );

PROCEDURE read_lines
	      (  p_process  IN VARCHAR2
	        ,p_file_type IN UTL_FILE.file_type
		,p_record   OUT NOCOPY VARCHAR2
	      );

   PROCEDURE read_record
	      (p_process          	IN VARCHAR2
		,p_line     		IN VARCHAR2
		,p_trans_code    	IN VARCHAR2
		,p_ah_seq_no       	OUT NOCOPY VARCHAR2
		,p_ah_ret_code    	OUT NOCOPY VARCHAR2
		,p_ref_no             	OUT NOCOPY VARCHAR2
		,p_serial_no         	OUT NOCOPY VARCHAR2
		,p_emp_no           	OUT NOCOPY VARCHAR2
		,p_emp_name       	OUT NOCOPY VARCHAR2
		,p_amount            	OUT NOCOPY VARCHAR2
		,p_ret_code_rem   	OUT NOCOPY VARCHAR2
        	,p_emp_name_old   	IN OUT NOCOPY VARCHAR2
		,p_ah_seq_no_prev  	IN OUT NOCOPY VARCHAR2
		,p_acc_pay_no      	IN OUT NOCOPY VARCHAR2
		,p_acc_pay_amt    	IN OUT NOCOPY VARCHAR2
		,p_rej_pay_no       	IN OUT NOCOPY VARCHAR2
		,p_rej_pay_amt     	IN OUT NOCOPY VARCHAR2
		);

-- function to get labels of items from a lookup
  FUNCTION get_lookup_meaning (p_lookup_type varchar2,p_lookup_code varchar2) RETURN VARCHAR2 ;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
end  PAY_NO_PAYPROC;

 

/
