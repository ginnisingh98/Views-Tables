--------------------------------------------------------
--  DDL for Package PAY_DK_TAX_CARD_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_TAX_CARD_REQUEST_PKG" AUTHID CURRENT_USER as
/* $Header: pydktcrq.pkh 120.0 2005/05/29 04:21:34 appldev noship $ */

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



CURSOR get_org_details IS
SELECT 'ORGANIZATION_NAME=P',hou1.name
      ,'TRANSFER_CVRNO=P',hoi2.org_information1
      ,'ORGANIZATION_ADDR=P', loc.ADDRESS_LINE_1||' '||loc.ADDRESS_LINE_2||' '||loc.ADDRESS_LINE_3
FROM    HR_ORGANIZATION_UNITS hou1
      , HR_ORGANIZATION_INFORMATION hoi1
      , HR_ORGANIZATION_INFORMATION hoi2
      , HR_LOCATIONS loc
      , PAY_PAYROLL_ACTIONS ppa
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and hou1.business_group_id = ppa.BUSINESS_GROUP_ID
and hou1.organization_id = nvl(PAY_DK_TAX_CARD_REQUEST_PKG.get_parameter(legislative_parameters,'LEGAL_EMPLOYER_NAME',null),hou1.organization_id)
and hou1.location_id = loc.LOCATION_ID(+)
and hoi1.organization_id = hou1.organization_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = nvl2(PAY_DK_TAX_CARD_REQUEST_PKG.get_parameter(legislative_parameters,'LEGAL_EMPLOYER_NAME',null),'HR_LEGAL_EMPLOYER','DK_SERVICE_PROVIDER')
and hoi1.ORG_INFORMATION2 ='Y'
and hoi2.ORG_INFORMATION_CONTEXT= nvl2(PAY_DK_TAX_CARD_REQUEST_PKG.get_parameter(legislative_parameters,'LEGAL_EMPLOYER_NAME',null)
                                      ,'DK_LEGAL_ENTITY_DETAILS','DK_SERVICE_PROVIDER_DETAILS')
and hoi2.organization_id =  hoi1.organization_id
and ppa.EFFECTIVE_DATE BETWEEN hou1.DATE_FROM and nvl(hou1.DATE_TO, ppa.EFFECTIVE_DATE);


CURSOR get_employee_details IS
SELECT distinct('CPR_NO=P'), to_char(PAP.NATIONAL_IDENTIFIER), 'EMP_NO=P',to_char(PAP.EMPLOYEE_NUMBER)	, 'LEGAL_EMPLR_CVRNO=P', hoi2.ORG_INFORMATION1
FROM per_all_assignments_f PAA
   , per_all_people_f PAP
   , hr_soft_coding_keyflex SCL
   , pay_payroll_actions PPA
   , HR_ORGANIZATION_UNITS hou
   , HR_ORGANIZATION_INFORMATION hoi1
   , HR_ORGANIZATION_INFORMATION hoi2
WHERE PPA.payroll_action_id =  pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and PAA.business_group_id = PPA.business_group_id
AND PAP.per_information_category ='DK'
AND PAA.PERSON_ID = PAP.PERSON_ID
AND PAA.soft_coding_keyflex_id = SCL.soft_coding_keyflex_id
AND PPA.EFFECTIVE_DATE  between  PAA.EFFECTIVE_START_DATE  and PAA.EFFECTIVE_END_DATE
AND PPA.EFFECTIVE_DATE  between  PAP.EFFECTIVE_START_DATE  and PAP.EFFECTIVE_END_DATE
and hou.business_group_id =  PPA.business_group_id
and hoi1.organization_id = hou.organization_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi1.ORG_INFORMATION2 = 'Y'
and hoi2.ORG_INFORMATION_CONTEXT='DK_LEGAL_ENTITY_DETAILS'
and hoi2.organization_id =  hoi1.organization_id
and nvl(hoi2.org_information1,0)= nvl2(PAY_DK_TAX_CARD_REQUEST_PKG.get_parameter(legislative_parameters,'LEGAL_EMPLOYER_NAME',null),pay_magtape_generic.get_parameter_value('TRANSFER_CVRNO'),nvl(hoi2.org_information1,0) )
and ppa.EFFECTIVE_DATE BETWEEN hou.DATE_FROM and nvl(hou.DATE_TO, ppa.EFFECTIVE_DATE)
AND SCL.ENABLED_FLAG = 'Y'
AND SCL.SEGMENT1 =to_char(hou.ORGANIZATION_ID);

END PAY_DK_TAX_CARD_REQUEST_PKG;

 

/
