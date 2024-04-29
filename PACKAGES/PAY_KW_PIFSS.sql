--------------------------------------------------------
--  DDL for Package PAY_KW_PIFSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KW_PIFSS" AUTHID CURRENT_USER as
/* $Header: pykwpifs.pkh 120.5 2006/08/23 10:39:20 spendhar noship $ */
 level_cnt NUMBER;
 --
 PROCEDURE range_cursor (pactid IN NUMBER,
                         sqlstr OUT nocopy VARCHAR2);
 --
 procedure assignment_action_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       p_start_person_id    in per_all_people_f.person_id%type,
       p_end_person_id      in per_all_people_f.person_id%type,
       p_chunk              in number);
 --
 procedure spawn_archive_reports;
 --
 CURSOR CSR_KW_PIFSS_HEADER IS
 SELECT 'REPORT_TYPE=P'
	,pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Report_Type')
	,'EMPLOYER_KEY=P'
	,pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Employer_Key')
	,'FILE_ID=P'
	,pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'File_ID')
	,'CREATION_DATE=P'
      ,to_char(ppa.effective_date, 'YYYYMMDD')
	,'ACTUAL_DATE=P'
,to_char(trunc(to_date('01'||'-'||pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Month')||'-'||pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Year'),'dd-mm-yyyy'), 'MM'),'YYYYMMDD')
	,'TOT_EMPLOYEE=P'
      ,pay_kw_pifss_report.get_total_count(pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Employer_Id'),
                                           pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Month'),
                                           pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Year'),
					   pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'LOCAL_NATIONALITY'))
	,'CHANGE_EMPLOYEE=P'
      ,pay_kw_pifss_report.get_change_count(pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Employer_Id'),
                                           pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Month'),
                                           pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Year'),
					   pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'LOCAL_NATIONALITY'))
	,'TERM_EMPLOYEE=P'
      ,pay_kw_pifss_report.get_term_count(pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Employer_Id'),
                                           pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Month'),
                                           pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Year'),
				           pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'LOCAL_NATIONALITY'))
	,'NEW_EMPLOYEE=P'
      ,pay_kw_pifss_report.get_new_count(pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Employer_Id'),
                                           pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Month'),
                                           pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'Year'),
    					   pay_kw_pifss_report.get_parameter(ppa.legislative_parameters,'LOCAL_NATIONALITY'))
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
FROM   pay_payroll_actions ppa
WHERE  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
--
CURSOR CSR_KW_PIFSS_BODY IS
SELECT /*+ INDEX(hscl, HR_SOFT_CODING_KEYFLEX_PK) */ distinct 'REPORT_TYPE=P'
	   		,pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Report_Type')
	   		,'AMOUNT=P'
			, pay_kw_pifss_report.get_amount_cont(
			pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Employer_Id'),paa.assignment_action_id,pef.person_id , to_date('01'||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Month')
			||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Year'),'dd-mm-yyyy'))
			,'SSN=P'
			,nvl(hscl.segment2,' ')
			,'CIVIL_ID=P'
			,nvl(pef.national_identifier,' ')
			,'EMP_NO=P'
			,pef.employee_number
			,'EMP_NAME=P'
--			,pef.full_name
,decode(FND_PROFILE.VALUE('HR_LOCAL_OR_GLOBAL_NAME_FORMAT'),
       'L',
       NVL(hr_person_name.get_person_name
                       (pef.person_id
                       ,TRUNC(to_date('01'||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Month')||'-'||
                                      pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Year'),'dd-mm-yyyy'), 'MM')
                       ,'DISPLAY_NAME'
                       ,FND_PROFILE.VALUE('HR_LOCAL_OR_GLOBAL_NAME_FORMAT')),' '),
       pef.full_name)
			,'EFFECTIVE_DATE=P'
			,to_char(ppa.effective_date,'YYYYMMDD')
			,'CHANGE_IND=P'
			,nvl(pay_kw_pifss_report.get_change_indicator(pef.person_id),' ')
			,'ASSIGNMENT_ID=C' , asg.assignment_id
			      ,'BUSINESS_GROUP_ID=C' , asg.business_group_id
			      ,'DATE_EARNED=C' , to_char(ppa.effective_date, 'YYYY/MM/DD HH24:MI:SS')
			      ,'ORGANIZATION_ID=C' , asg.organization_id
      ,'TAX_UNIT_ID=C' , paa.tax_unit_id
  FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_people_f pef
           ,pay_payroll_actions ppa1
	   ,pay_legislation_rules leg
    WHERE  asg.assignment_id = paa.assignment_id
    AND    pef.person_id = asg.person_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(to_date('01'||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Month')||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Year'),'dd-mm-yyyy'), 'MM')
    AND    trunc(to_date('01'||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Month')||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Year'),'dd-mm-yyyy'), 'MM')
               between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(to_date('01'||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Month')||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Year'),'dd-mm-yyyy'), 'MM')
               between trunc(pef.effective_start_date,'MM') and pef.effective_end_date
    AND    ppa1.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Employer_Id')
    AND    leg.legislation_code = 'KW'
    AND    leg.rule_type = 'S'
    AND    leg.rule_mode = hscl.id_flex_num
    AND    pef.nationality = pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'LOCAL_NATIONALITY');
--
CURSOR CSR_KW_PIFSS_FOOTER IS
SELECT /*+ INDEX(hscl,HR_SOFT_CODING_KEYFLEX_PK) */ distinct 'REPORT_TYPE=P'
	   		,pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Report_Type')
			,'EMPLOYER_KEY=P'
	   		,pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Employer_Key')
	   		,'DED_SSN=P'
			,nvl(hscl.segment2,' ')
			,'DED_CIVIL_ID=P'
			,nvl(pef.national_identifier,' ')
			,'DED_EMP_NO=P'
			,pef.employee_number
			,'DED_EMP_NAME=P'
--			,pef.full_name
,decode(FND_PROFILE.VALUE('HR_LOCAL_OR_GLOBAL_NAME_FORMAT'),
       'L',
       NVL(hr_person_name.get_person_name
                       (pef.person_id
                       ,TRUNC(to_date('01'||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Month')||'-'||
                                      pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Year'),'dd-mm-yyyy'), 'MM')
                       ,'DISPLAY_NAME'
                       ,FND_PROFILE.VALUE('HR_LOCAL_OR_GLOBAL_NAME_FORMAT')),' '),
       pef.full_name)
			,'DED_DETAIL=P'
			,nvl(substr(pay_kw_pifss_report.get_deduction_detail(pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Report_Type'),paa.assignment_action_id,asg.assignment_id,ppa.effective_date),1,63),' ')
			,'DED_DETAIL2=P'
			,nvl(substr(pay_kw_pifss_report.get_deduction_detail(pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Report_Type'),paa.assignment_action_id,asg.assignment_id,ppa.effective_date),64,63),' ')
			,'DED_DETAIL3=P'
			,nvl(substr(pay_kw_pifss_report.get_deduction_detail(pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Report_Type'),paa.assignment_action_id,asg.assignment_id,ppa.effective_date),127,63),' ')
			,'DED_DETAIL4=P'
			,nvl(substr(pay_kw_pifss_report.get_deduction_detail(pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Report_Type'),paa.assignment_action_id,asg.assignment_id,ppa.effective_date),190,63),' ')
			,'DED_DETAIL5=P'
			,nvl(substr(pay_kw_pifss_report.get_deduction_detail(pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Report_Type'),paa.assignment_action_id,asg.assignment_id,ppa.effective_date),253,63),' ')
			,'ASSIGNMENT_ID=C' , asg.assignment_id
			      ,'BUSINESS_GROUP_ID=C' , asg.business_group_id
			      ,'DATE_EARNED=C' , to_char(ppa.effective_date, 'YYYY/MM/DD HH24:MI:SS')
			      ,'ORGANIZATION_ID=C' , asg.organization_id
      ,'TAX_UNIT_ID=C' , paa.tax_unit_id
  FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_people_f pef
           ,pay_payroll_actions ppa1
	   ,pay_legislation_rules leg
    WHERE  asg.assignment_id = paa.assignment_id
    AND    pef.person_id = asg.person_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(to_date('01'||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Month')||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Year'),'dd-mm-yyyy'), 'MM')
    AND    trunc(to_date('01'||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Month')||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Year'),'dd-mm-yyyy'), 'MM')
	 between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(to_date('01'||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Month')||'-'||pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Year'),'dd-mm-yyyy'), 'MM')
	 between trunc(pef.effective_start_date,'MM') and pef.effective_end_date
    AND    ppa1.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'Employer_Id')
    AND    leg.legislation_code = 'KW'
    AND    leg.rule_type = 'S'
    AND    leg.rule_mode = hscl.id_flex_num
    AND    pef.nationality = pay_kw_pifss_report.get_parameter(ppa1.legislative_parameters,'LOCAL_NATIONALITY');
--
END PAY_KW_PIFSS;

/
