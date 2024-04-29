--------------------------------------------------------
--  DDL for Package PAY_DK_MIA_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_MIA_REPORT_PKG" AUTHID CURRENT_USER as
/* $Header: pydkmiar.pkh 120.1 2006/01/19 22:19:15 pgopal noship $ */

level_cnt NUMBER;

PROCEDURE range_cursor(
                p_payroll_action_id     IN  NUMBER,
                p_sqlstr                OUT NOCOPY VARCHAR2);

PROCEDURE assignment_action_code(
                          pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER);

FUNCTION get_parameter(
                 p_parameter_string  IN VARCHAR2
                ,p_token             IN VARCHAR2
                ,p_segment_number    IN NUMBER DEFAULT NULL )RETURN VARCHAR2;

FUNCTION get_cp_parameter(
                          p_payroll_action_id   NUMBER
	  	         ,p_token_name          VARCHAR2) RETURN VARCHAR2;

FUNCTION get_period_dates(
                 p_payroll_id          IN VARCHAR2
		,p_payroll_action_id   IN VARCHAR2
                ,p_start_date          OUT NOCOPY VARCHAR2
		,p_end_date            OUT NOCOPY VARCHAR2
                ,p_direct_dd_date      OUT NOCOPY VARCHAR2)RETURN VARCHAR2;

/*FUNCTION get_payroll_period(
                 p_payroll_id          IN VARCHAR2
		,p_effective_date      IN DATE)RETURN VARCHAR2;*/

FUNCTION get_taxable_pay
   (p_assignment_action_id     IN  VARCHAR2) RETURN NUMBER;


FUNCTION get_sp_name(p_business_group_id IN NUMBER) RETURN varchar2;

FUNCTION get_sp_details (p_payroll_action_id IN number
			,p_cvr_no OUT NOCOPY varchar2
			,p_sp_name OUT NOCOPY varchar2
			,p_org_address OUT NOCOPY varchar2
			,p_town OUT NOCOPY varchar2) RETURN varchar2;


FUNCTION get_dd_date(p_payroll_id IN NUMBER,
                     p_effective_date IN DATE) RETURN varchar2;

FUNCTION get_business_group_id(p_payroll_action_id IN number) RETURN number;

FUNCTION check_termination_date(p_start_date varchar2,
				p_end_date varchar2,
				p_termination_date varchar2) RETURN varchar2;

CURSOR get_org_details IS
SELECT 'ORGANIZATION_NAME=P',hou1.name
      ,'TRANSFER_CVRNO=P',hoi2.org_information1
      ,'ORGANIZATION_ADDR=P', substr((loc.ADDRESS_LINE_1||' '||loc.ADDRESS_LINE_2||' '||loc.ADDRESS_LINE_3),1,40)
      ,'ORGANIZATION_TOWN=P' ,substr((loc.POSTAL_CODE ||' ' || loc.TOWN_OR_CITY),1,40)
      ,'PAY_PERIOD=P' , to_char(ppa.effective_date,'YYYYMM')
      ,'PAYROLL_ACTION_ID=C' , ppa.payroll_action_id

FROM    HR_ORGANIZATION_UNITS hou1
      , HR_ORGANIZATION_INFORMATION hoi1
      , HR_ORGANIZATION_INFORMATION hoi2
      , HR_LOCATIONS loc
      , PAY_PAYROLL_ACTIONS ppa
WHERE
ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and hou1.business_group_id = ppa.BUSINESS_GROUP_ID
and hou1.organization_id = nvl(PAY_DK_MIA_REPORT_PKG.get_parameter(legislative_parameters,'LEGAL_EMPLOYER_NAME',null),hou1.organization_id)
and hou1.location_id = loc.LOCATION_ID(+)
and hoi1.organization_id = hou1.organization_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = nvl2(PAY_DK_MIA_REPORT_PKG.get_parameter(legislative_parameters,'LEGAL_EMPLOYER_NAME',null),'HR_LEGAL_EMPLOYER','DK_SERVICE_PROVIDER')
and hoi1.ORG_INFORMATION2 ='Y'
and hoi2.ORG_INFORMATION_CONTEXT= nvl2(PAY_DK_MIA_REPORT_PKG.get_parameter(legislative_parameters,'LEGAL_EMPLOYER_NAME',null)
                                      ,'DK_LEGAL_ENTITY_DETAILS','DK_SERVICE_PROVIDER_DETAILS')
and hoi2.organization_id =  hoi1.organization_id
and ppa.EFFECTIVE_DATE BETWEEN hou1.DATE_FROM and nvl(hou1.DATE_TO, ppa.EFFECTIVE_DATE);




CURSOR get_employee_details IS
SELECT distinct('CPR_NO=P'), to_char(PAP.NATIONAL_IDENTIFIER),
	'PERSON_ID=P', to_char(PAP.PERSON_ID),
	'PAYROLL_ID=P',to_char(PAA.PAYROLL_ID),
	'LEGAL_EMPLR_CVRNO=P', hoi2.ORG_INFORMATION1,
	'ASGMT_START_DATE=P' , to_char(PAA.EFFECTIVE_START_DATE,'YYYYMMDD'),
	'ASGMT_END_DATE=P' , nvl(to_char(PPS.ACTUAL_TERMINATION_DATE,'YYYYMMDD'),'-1'),
	'TERM_DATE=P', nvl(to_char(to_date(SCL.SEGMENT8,'DD/MM/YYYYY'),'YYYYMMDD'),'-1'),
	'DISPOSAL_DATE=P', PAY_DK_MIA_REPORT_PKG.get_dd_date(PPA.payroll_id,ppa.effective_date),
	'TAXABLE_PAY=P' , to_char(PAY_DK_MIA_REPORT_PKG.get_taxable_pay(pact.assignment_action_id)),
	'EMP_NO=P', PAP.EMPLOYEE_NUMBER,
	'ASGMNT_ID=P', PAA.ASSIGNMENT_ID
	--'PAYROLL_ACTION_ID=C' , ppa.payroll_action_id
FROM
     per_all_people_f                  PAP
   , per_all_assignments_f             PAA
   , pay_assignment_actions            pact
   , pay_payrolls_f                    PPF
   , pay_payroll_actions               PPA
   , per_periods_of_service	       PPS
   , hr_soft_coding_keyflex SCL
   , HR_ORGANIZATION_UNITS hou
   , HR_ORGANIZATION_INFORMATION hoi1
   , HR_ORGANIZATION_INFORMATION hoi2
WHERE
--ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
ppa.business_group_id = PAY_DK_MIA_REPORT_PKG.get_business_group_id(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'))
--AND PAA.business_group_id = ppa.business_group_id
AND PAP.per_information_category ='DK'
AND PAA.PERSON_ID = PAP.PERSON_ID
AND PPS.person_id = PAP.person_id
AND PAA.payroll_id = PPF.payroll_id
AND PAA.PAYROLL_ID > 0
AND PAA.payroll_id = PPA.payroll_id
AND pact.payroll_action_id = (select max(payroll_action_id) from pay_payroll_actions
			      where payroll_id=PPA.payroll_id
			      and action_type='R'
			      and action_status ='C'
			      and effective_date BETWEEN ppa.start_date AND ppa.effective_date)
			      and exists
			      (select '1' from pay_payroll_actions
			      where payroll_id=PPA.payroll_id
			      and action_type='P'
  			      and action_status = 'C'
			      and effective_date BETWEEN ppa.start_date AND ppa.effective_date)
AND PAA.assignment_id = pact.assignment_id
AND PAA.assignment_status_type_id = 1
AND PAA.soft_coding_keyflex_id = SCL.soft_coding_keyflex_id
--AND PPA.EFFECTIVE_DATE  between  PAA.EFFECTIVE_START_DATE  and PAA.EFFECTIVE_END_DATE
AND PPA.EFFECTIVE_DATE  between  PAP.EFFECTIVE_START_DATE  and PAP.EFFECTIVE_END_DATE
AND to_char(PPA.effective_date,'YYYYMMDD') =
			to_char((select effective_date from pay_payroll_actions
			where payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')),'YYYYMMDD')
AND PPA.EFFECTIVE_DATE BETWEEN PPS.DATE_START AND NVL(PPS.ACTUAL_TERMINATION_DATE,TO_DATE('31/12/4712','dd/mm/yyyy'))--Check added by pgopal for bug fix-4499107
and hou.business_group_id =  PPA.business_group_id
and hoi1.organization_id = hou.organization_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi1.ORG_INFORMATION2 = 'Y'
and hoi2.ORG_INFORMATION_CONTEXT='DK_LEGAL_ENTITY_DETAILS'
and hoi2.organization_id =  hoi1.organization_id
and nvl(hoi2.org_information1,0)= nvl2(PAY_DK_MIA_REPORT_PKG.get_parameter(legislative_parameters,'LEGAL_EMPLOYER_NAME',null),pay_magtape_generic.get_parameter_value('TRANSFER_CVRNO'),nvl(hoi2.org_information1,0) )
and ppa.EFFECTIVE_DATE BETWEEN hou.DATE_FROM and nvl(hou.DATE_TO, ppa.EFFECTIVE_DATE)
AND SCL.ENABLED_FLAG = 'Y'
AND SCL.SEGMENT1 =to_char(hou.ORGANIZATION_ID)
ORDER BY hoi2.ORG_INFORMATION1,PAA.payroll_id,PAP.PERSON_ID;

END PAY_DK_MIA_REPORT_PKG;


 

/
