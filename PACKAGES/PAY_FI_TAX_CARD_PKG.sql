--------------------------------------------------------
--  DDL for Package PAY_FI_TAX_CARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FI_TAX_CARD_PKG" AUTHID CURRENT_USER as
/* $Header: pyfitaxr.pkh 120.1 2005/12/13 21:35:34 vetsrini noship $ */


level_cnt NUMBER;

FUNCTION  get_parameter (
          p_parameter_string  in varchar2
         ,p_token             in varchar2
         ,p_segment_number    in number default null) RETURN varchar2;

PROCEDURE range_code(
                p_payroll_action_id     IN  NUMBER,
                p_sqlstr                OUT NOCOPY VARCHAR2);


PROCEDURE assignment_action_code(
                          pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER);

FUNCTION get_employment_status(
			 p_assignment_id	IN	NUMBER
			,p_effective_date	IN	DATE)	RETURN	VARCHAR2;


/********************************************************
*   Cursor to fetch Body record information		*
********************************************************/

CURSOR CSR_FI_TAX_CARD IS
SELECT /*+ INDEX(scl, HR_SOFT_CODING_KEYFLEX_PK) */	 'EMPLOYERS_ID=P'
       ,hoi2.org_information1 || '-'|| hoi5.org_information1
       ,'EMPLOYEES_ID=P'
       ,pap.national_identifier
       ,'PREPAYMENT_YEAR=P'
       ,pay_fi_tax_card_pkg.get_parameter(ppa.legislative_parameters, 'PREPAYMENT_YEAR')
       ,'TYVI_ID=P'
       ,pay_fi_tax_card_pkg.get_parameter(ppa.legislative_parameters,'TYVI_ID')
       ,'SALARIED_EMP=P'      ,DECODE(paa.hourly_salaried_code,NULL,DECODE(hoi2.org_information6,NULL,hoi5.org_information9,hoi2.org_information6 ) , paa.hourly_salaried_code)
       ,'PRIMARY_EMPLOYMENT=P'
       ,pay_fi_tax_card_pkg.get_employment_status(paa.assignment_id,ppa.effective_date)
FROM          PAY_PAYROLL_ACTIONS ppa
      , PER_ALL_PEOPLE_F pap
      , PER_ALL_ASSIGNMENTS_F paa
      , PAY_LEGISLATION_RULES plr
      , HR_SOFT_CODING_KEYFLEX scl
      , HR_ORGANIZATION_INFORMATION hoi1
      , HR_ORGANIZATION_INFORMATION hoi2
      , HR_ORGANIZATION_INFORMATION hoi3
      , HR_ORGANIZATION_INFORMATION hoi4
      , HR_ORGANIZATION_INFORMATION hoi5
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and pap.person_id = paa.person_id
and pap.BUSINESS_GROUP_ID = ppa.BUSINESS_GROUP_ID
and ppa.effective_date BETWEEN pap.effective_start_date and pap.effective_end_date
and paa.BUSINESS_GROUP_ID = ppa.BUSINESS_GROUP_ID
and ppa.effective_date BETWEEN paa.effective_start_date and paa.effective_end_date
and paa.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and scl.id_flex_num = plr.rule_mode
and scl.enabled_flag='Y'
and plr.legislation_code = 'FI'
and plr.rule_type = 'S'
and (paa.assignment_id,pap.person_id )  in (SELECT  /*+ INDEX(scl1, HR_SOFT_CODING_KEYFLEX_PK) */ min(paa.assignment_id),pap1.person_id
	         FROM per_all_assignments_f paa
		      ,per_all_people_f pap1
		      ,HR_SOFT_CODING_KEYFLEX scl1
		      ,HR_ORGANIZATION_INFORMATION hoi6
		 WHERE paa.person_id = pap1.person_id
and ppa.BUSINESS_GROUP_ID = pap1.BUSINESS_GROUP_ID
and ppa.effective_date BETWEEN pap1.effective_start_date and pap1.effective_end_date
and ppa.effective_date BETWEEN paa.effective_start_date and paa.effective_end_date
and ppa.BUSINESS_GROUP_ID = paa.BUSINESS_GROUP_ID
                 	AND paa.soft_coding_keyflex_id= scl1.soft_coding_keyflex_id
	AND scl1.segment2 = nvl(pay_fi_tax_card_pkg.get_parameter(ppa.legislative_parameters,'LOCAL_UNIT'),scl1.segment2)
	and scl1.enabled_flag='Y'
		AND hoi6.organization_id =pay_fi_tax_card_pkg.get_parameter(ppa.legislative_parameters, 'LEGAL_EMPLOYER')
		AND hoi6.ORG_INFORMATION_CONTEXT = 'FI_LOCAL_UNITS'
		        AND  hoi6.org_information1 = scl1.segment2
			group by pap1.person_id
			)
and hoi1.organization_id = pay_fi_tax_card_pkg.get_parameter(ppa.legislative_parameters, 'LEGAL_EMPLOYER')
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi1.organization_id =  hoi2.organization_id
and hoi2.ORG_INFORMATION_CONTEXT='FI_LEGAL_EMPLOYER_DETAILS'
and hoi2.organization_id = hoi3.organization_id
and hoi3.ORG_INFORMATION_CONTEXT = 'FI_LOCAL_UNITS'
and hoi3.org_information1= hoi4.organization_id
and hoi4.ORG_INFORMATION_CONTEXT='CLASS'
and hoi4.org_information1='FI_LOCAL_UNIT'
and hoi4.organization_id = nvl(pay_fi_tax_card_pkg.get_parameter(ppa.legislative_parameters,'LOCAL_UNIT'),hoi4.organization_id)
and hoi4.organization_id = hoi5.organization_id
and hoi5.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNIT_DETAILS'
and to_char(hoi5.organization_id) = scl.segment2;

END PAY_FI_TAX_CARD_PKG;

 

/
