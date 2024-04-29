--------------------------------------------------------
--  DDL for Package PAY_HK_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_EFT" AUTHID CURRENT_USER as
/* $Header: pyhkeft.pkh 115.9 2003/09/08 07:19:39 avenkatk ship $
**
**  Copyright (c) 2000 Oracle Corporation
**  All Rights Reserved
**
**  EFT auto pay
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  14 FEB 2001 ATRIPATH N/A       Amit Tripathi
**  27 AUG 2002 NANURADH 2525527   Changed cursor c_hsbc_hex_data.
**                                 Second_party_identifier is set to AssignmentID instead of HKID/passport no
**  11 Oct 2002 NANURADH 2600691   Added a new column 'National Identifier' in cursor c_hsbc_hex_data
**  14 Nov 2002 NANURADH 2666955   Changed length of Passport Number
**  16 Dec 2002 VGSRINIV 2600691   Modified cursor c_hsbc_hex_data.
**                                 Second_party_identifier is set to employee number.
**                                 Removed the National Identifier column in cursor c_hsbc_hex_data
**  29 May 2003 KAVERMA  2920731   Replaced table per_all_people_f by
**                                 secured view per_people_f
**  08 Sep 2003 AVENKATK 3131759   Modified cursor c_hsbc_hex_data.
**                                 Added date track check for Organizational payment method
*/

level_cnt                     number ;

/********************************************************
*  	Cursor to fetch header record information	*
********************************************************/

cursor c_hsbc_hex_header is
 Select
    	      	'AUTOPLAN_CODE=P'
	,     		'F'
    	,      	'ACCOUNT_NUMBER=P'
    	,       	oea.segment2 ||lpad(substr(oea.SEGMENT3,1,9),9,' ')
    	,     	'PAYMENT_CODE=P'
	,      		NVL(popm.pmeth_information1,'NULL_VALUE')
        ,      	'FIRST_PARTY_REFERENCE=P'
        , 		pay_magtape_generic.get_parameter_value('FIRST_PARTY_REFERENCE')
	,      	'VALUE_DATE=P'
	,       	to_char(to_date(pay_magtape_generic.get_parameter_value('TRANSACTION_DATE'),'YYYY/MM/DD'),'ddmmyy')
	,       'INPUT_MEDIUM=P'
	,      		'K'
	,      	'FILE_NAME=P'
	,       	'********'
	,      	'RECORDS_IN_BATCH=P'
	,      		decode(sign(99999 - COUNT(*)),1, to_char(COUNT(*)),'NULL_VALUE')
	,      	'MONETARY_TOTAL_BATCH=P'
	,      		decode(sign(9999999999 - SUM(ppp.VALUE * 100)),1,
				to_char(SUM(ppp.VALUE * 100)),'NULL_VALUE')
	,      	'OVERFLOW_COUNT=P'
	,      		decode(sign(99999 - COUNT(*)),-1, to_char(COUNT(*)),'NULL_VALUE')
	,      'OVERFLOW_AMOUNT=P'
	,      		decode(sign(9999999999 - SUM(ppp.VALUE * 100)),-1,
				to_char(SUM(ppp.VALUE * 100)),'NULL_VALUE')
	,      'CENTRE_CODE=P'
	,      		'1'
        ,	'TRANSFER_HEAD_FLAG=P'
        ,	'Not_Printed'
  from
         pay_org_payment_methods_f      popm
  ,      pay_external_accounts          oea
  ,      pay_personal_payment_methods_f pppm
  ,      pay_external_accounts          pea
  ,      pay_pre_payments               ppp
  ,      pay_assignment_actions         paa
  ,      pay_payroll_actions            ppa
  ,      per_assignments_f              a
  ,      per_people_f                   p
  where
         paa.payroll_action_id           =
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    ppp.pre_payment_id              = paa.pre_payment_id
  and    paa.payroll_action_id           = ppa.payroll_action_id
  and    oea.external_account_id         = popm.external_account_id
  and    popm.org_payment_method_id      = ppp.org_payment_method_id
  and    pea.external_account_id         = pppm.external_account_id
  and    pppm.personal_payment_method_id = ppp.personal_payment_method_id
  and    paa.assignment_id               = a.assignment_id
  and    a.person_id                     = p.person_id
  and    ppa.effective_date between popm.effective_start_date and popm.effective_end_date
  and    ppa.effective_date between pppm.effective_start_date and pppm.effective_end_date
  and    ppa.effective_date between    a.effective_start_date and    a.effective_end_date
  and    ppa.effective_date between    p.effective_start_date and    p.effective_end_date
group by 	oea.segment1
 	,	oea.segment2 ||lpad(substr(oea.SEGMENT3,1,9),9,' ')
	,      	popm.pmeth_information1
  	,       oea.segment4
	,       to_char(to_date(pay_magtape_generic.get_parameter_value('TRANSACTION_DATE'),'YYYY/MM/DD'),'ddmmyy')
   	,      	nvl(popm.pmeth_information7,'NULL')
   	,      	to_char(to_date(pay_magtape_generic.get_parameter_value('TRANSACTION_DATE'),'YYYY/MM/DD'),'ddmmyy')
   	,      	popm.pmeth_information1
   	,      	popm.pmeth_information3
   	,      	popm.pmeth_information2
   	,      	popm.pmeth_information4
   	,      	popm.pmeth_information9
 ;


/********************************************************
*  	Cursor to fetch data record information		*
********************************************************/

cursor c_hsbc_hex_data is
 select
         'SECOND_PARTY_IDENTIFIER=P'
  ,     	p.employee_number                          -- Bug 2600691
  ,      'BANK_ACCOUNT_NAME=P'
  ,      	pea.SEGMENT4
  ,      'BANK_NUMBER=P'
  ,      	pea.segment1
  , 	 'BRANCH_NUMBER=P'
  ,		pea.segment2
  ,      'ACCOUNT_NUMBER=P'
  ,      	substr(pea.SEGMENT3,1,9)
  ,      'AMOUNT=P'
  ,      	LPAD(TO_CHAR(ppp.VALUE * 100),10,'0')      -- amount
  ,	 'VALUE_DATE=P'
  ,		'NULL_VALUE' -- 4 blank spaces
  ,	 'SECOND_PARTY_IDENTIFIER_CONTD=P'
  ,		'NULL_VALUE'  -- 6 blank spaces            -- Bug 2525527
  ,	 'SECOND_PARTY_REFERENCE=P'
  , 	 	'NULL_VALUE' -- 12 blank spaces
  ,	'TRANSFER_HEAD_FLAG_P='
  ,	'Not_Printed'
  from
         pay_org_payment_methods_f      popm
  ,      pay_external_accounts          oea
  ,      pay_personal_payment_methods_f pppm
  ,      pay_external_accounts          pea
  ,      pay_pre_payments               ppp
  ,      pay_assignment_actions         paa
  ,      pay_payroll_actions            ppa
  ,      per_assignments_f              a
  ,      per_people_f                   p
  where
         paa.payroll_action_id           =
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    ppp.pre_payment_id              = paa.pre_payment_id
  and    paa.payroll_action_id           = ppa.payroll_action_id
  and    oea.external_account_id         = popm.external_account_id
  and    popm.org_payment_method_id      = ppp.org_payment_method_id
  and    pea.external_account_id         = pppm.external_account_id
  and    pppm.personal_payment_method_id = ppp.personal_payment_method_id
  and    paa.assignment_id               = a.assignment_id
  and    a.person_id                     = p.person_id
  and    paa.payroll_action_id = ppa.payroll_action_id
  and    ppa.effective_date between pppm.effective_start_date and pppm.effective_end_date
  and    ppa.effective_date between    a.effective_start_date and    a.effective_end_date
  and    ppa.effective_date between    p.effective_start_date and    p.effective_end_date
  and    ppa.effective_date between popm.effective_start_date and popm.effective_end_date
  order by decode(pay_magtape_generic.get_parameter_value('SORT_SEQUENCE'),'N',
        	pea.SEGMENT4,'B', pea.segment2)
;

end pay_hk_eft;

 

/
