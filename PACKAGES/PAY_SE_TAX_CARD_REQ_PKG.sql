--------------------------------------------------------
--  DDL for Package PAY_SE_TAX_CARD_REQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_TAX_CARD_REQ_PKG" AUTHID CURRENT_USER as
/* $Header: pysetaxr.pkh 120.1.12010000.3 2009/10/13 10:32:33 vijranga ship $ */

level_cnt NUMBER;

FUNCTION  get_parameter (
          p_parameter_string  in varchar2
         ,p_token             in varchar2
         ,p_segment_number    in number default null) RETURN varchar2;

PROCEDURE range_code(
          p_payroll_action_id IN  NUMBER,
          p_sqlstr            OUT NOCOPY VARCHAR2);


PROCEDURE assignment_action_code(
          pactid    IN NUMBER,
          stperson  IN NUMBER,
          endperson IN NUMBER,
          chunk     IN NUMBER);

/********************************************************
*   Cursor to fetch Body record information		*
********************************************************/
CURSOR CSR_SE_HEAD
IS select 		'ORG_NUM=P',	 	  RPAD(hoi2.org_information2,12)       /*ORGNRF*/
		,'REQUEST_DATE=P',	  to_char(fnd_date.CANONICAL_TO_DATE(PAY_SE_TAX_CARD_REQ_PKG.get_parameter(ppa.legislative_parameters, 'EFFECTIVE_DATE')), 'YYYYMMDD')     /*DATUMF*/
		,'TIME_STAMP=P',	  to_char(fnd_date.CANONICAL_TO_DATE(PAY_SE_TAX_CARD_REQ_PKG.get_parameter(ppa.legislative_parameters, 'EFFECTIVE_DATE')),'HH24MISS')           /*KLOCKF*/
		,'EMPLOYER_NAME=P',	  RPAD(NVL(substr(ou.name,1,30),' '),30,' ')							/*NAMNF*/
		,'CONTACT_PERSON=P',      RPAD(NVL(substr(hoi3.org_information3,1,30),' '),30,' ') /*AVDF */
		,'ADDRESS1=P',		  RPAD(NVL(substr(HL.ADDRESS_LINE_1||decode(HL.ADDRESS_LINE_1,NULL,'',',')|| HL.ADDRESS_LINE_2|| decode(HL.ADDRESS_LINE_2,NULL,'',',') ||HL.ADDRESS_LINE_3,1,30),' '),30,' ') /*ADRF*/
		-- Bug#8849455 fix Added space between 3 and 4 digits in postal code
		,'POSTAL_CODE=P',	  RPAD(NVL(substr(hl.Postal_code,1,3)||' '||substr(hl.Postal_code,4,2),' '),7,' ') /*PONRF*/
		,'POST_OFFICE=P',	  RPAD(nvl(substr(hr_general.DECODE_LOOKUP('SE_POSTAL_CODE',HL.POSTAL_CODE),7,16),' '),15,' ')				/*ORTAF*/
		,'PHONE=P',		  RPAD(NVL(substr(hoi4.org_information3,1,10),' '),10,' ')												 /*TELEF*/
          		,'TEST_RUN=P',        DECODE(pay_se_tax_card_req_pkg.get_parameter(ppa.legislative_parameters, 'TEST_RUN'),'Y','T',' ')
from
     PAY_PAYROLL_ACTIONS  ppa
    ,hr_organization_units        ou
    ,hr_organization_information  hoi1
    ,hr_organization_information  hoi2
    ,hr_organization_information  hoi3
    ,hr_organization_information  hoi4
    ,HR_LOCATIONS_ALL HL
where ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
AND ou.organization_id =  PAY_SE_TAX_CARD_REQ_PKG.get_parameter(ppa.legislative_parameters, 'REQUESTING_ORG')
and ou.business_group_id  = ppa.business_group_id
AND hoi1.organization_id  = ou.organization_id
AND hoi1.ORG_INFORMATION_CONTEXT='CLASS'
AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
AND hoi2.organization_id = ou.organization_id
AND hoi2.organization_id =  hoi1.organization_id
AND hoi2.ORG_INFORMATION_CONTEXT = 'SE_LEGAL_EMPLOYER_DETAILS'
AND hoi3.organization_id = ou.organization_id
AND hoi3.ORG_INFORMATION_CONTEXT = 'SE_ORG_CONTACT_DETAILS'
AND hoi3.org_information_id = (select min(hoi22.org_information_id)
                               from
                               hr_organization_information  hoi11
                              ,hr_organization_information  hoi22
                               where
                               hoi11.organization_id = PAY_SE_TAX_CARD_REQ_PKG.get_parameter(ppa.legislative_parameters, 'REQUESTING_ORG')
                               AND hoi11.ORG_INFORMATION_CONTEXT='CLASS'
	     AND hoi11.org_information1 = 'HR_LEGAL_EMPLOYER'
                               AND hoi22.organization_id =  hoi11.organization_id
                               AND hoi22.ORG_INFORMATION_CONTEXT = 'SE_ORG_CONTACT_DETAILS'
                               AND hoi22.org_information1='PERSON'
                                )
AND hoi3.org_information1='PERSON'
AND hoi4.organization_id = ou.organization_id
AND hoi4.ORG_INFORMATION_CONTEXT = 'SE_ORG_CONTACT_DETAILS'
AND hoi4.org_information1='PHONE'
AND ou.Location_id  = HL.Location_id (+) ;


CURSOR CSR_SE_BODY is select  /*+ INDEX(scl, HR_SOFT_CODING_KEYFLEX_PK) */  'ORG_NUM=P', RPAD(hoi2.org_information2,12),
       'PERSON_NUM=P', RPAD((TO_CHAR(pap.DATE_OF_BIRTH,'CC')-2)||REPLACE(PAP.NATIONAL_IDENTIFIER,'-',''),12)
FROM    HR_ORGANIZATION_INFORMATION hoi1
      , HR_ORGANIZATION_INFORMATION hoi2
      , HR_ORGANIZATION_INFORMATION hoi3
      , HR_ORGANIZATION_INFORMATION hoi4
   , PAY_LEGISLATION_RULES plr
      , HR_SOFT_CODING_KEYFLEX scl
      , PER_ALL_PEOPLE_F pap
      , PER_ALL_ASSIGNMENTS_F paa
      , PAY_PAYROLL_ACTIONS ppa
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and hoi1.organization_id = decode(pay_se_tax_card_req_pkg.get_parameter(ppa.legislative_parameters, 'REQUEST_FOR'),'ALL_ORG',hoi1.organization_id,pay_se_tax_card_req_pkg.get_parameter(ppa.legislative_parameters, 'REQUESTING_ORG'))
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi2.organization_id =  hoi1.organization_id
and hoi2.ORG_INFORMATION_CONTEXT='SE_LEGAL_EMPLOYER_DETAILS'
and hoi2.organization_id = hoi3.organization_id
and hoi3.ORG_INFORMATION_CONTEXT = 'SE_LOCAL_UNITS'
and hoi3.org_information1= hoi4.organization_id
and hoi4.ORG_INFORMATION_CONTEXT='CLASS'
and hoi4.org_information1='SE_LOCAL_UNIT'
and scl.id_flex_num = plr.rule_mode
and plr.legislation_code = 'SE'
and plr.rule_type = 'S'
and scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
and to_char(hoi4.organization_id) = scl.segment2
and paa.person_id = pap.person_id
and ppa.effective_date BETWEEN paa.effective_start_date and paa.effective_end_date
and ppa.effective_date BETWEEN pap.effective_start_date and pap.effective_end_date
and (paa.assignment_id,scl.segment2)
in
( SELECT /*+ INDEX(sck, HR_SOFT_CODING_KEYFLEX_PK) */  min(paaf.assignment_id),sck.segment2
  FROM
	 per_all_people_f papf
 	,per_all_assignments_f paaf
  	,HR_SOFT_CODING_KEYFLEX sck
	,HR_ORGANIZATION_INFORMATION hroi
	WHERE paaf.person_id = papf.person_id
	and paaf.BUSINESS_GROUP_ID = ppa.BUSINESS_GROUP_ID
	and ppa.effective_date BETWEEN paaf.effective_start_date and paaf.effective_end_date
	and ppa.effective_date BETWEEN papf.effective_start_date and papf.effective_end_date
	AND sck.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id
	and sck.id_flex_num = plr.rule_mode
	and sck.enabled_flag='Y'
	AND hroi.organization_id =decode(pay_se_tax_card_req_pkg.get_parameter(ppa.legislative_parameters, 'REQUEST_FOR'),'ALL_ORG',hoi1.organization_id,pay_se_tax_card_req_pkg.get_parameter(ppa.legislative_parameters, 'REQUESTING_ORG'))
	AND hroi.ORG_INFORMATION_CONTEXT = 'SE_LOCAL_UNITS'
 	AND hroi.org_information1  =  sck.segment2
	group by sck.segment2,paaf.person_id
		)
		order by  hoi1.organization_id;

END PAY_SE_TAX_CARD_REQ_PKG;

/
