--------------------------------------------------------
--  DDL for Package PAY_AU_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_EFT" AUTHID CURRENT_USER as
/* $Header: pyaueft.pkh 120.0.12010000.2 2009/06/16 03:57:05 skshin ship $
**
**  Copyright (c) 2000 Oracle Corporation
**  All Rights Reserved
**
**  EFT direct credit of pay stuff
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  04 JUL 2000  ABAJPAI   N/A       Ashlesh Bajpai
**  07 NOV 2000  ABAJPAI   N/A       Bug No 1485599
**  06 DEC 2000  ABAJPAI   N/A       Bug No 1523311
**  07 Jun 2001 ATRIPATH            Changes made for handling
**                                  debit record entry
**  25 Jun 2001 ATRIPATH             Changed detail cursor to filter out
**				     duplicate records
**  9  Nov 2001 Ragovind  1845869    Changed the Order by clause
**  18 Jun 2002 shoskatt  2421215    For the remitters name, account
**                                   name from the Bank Details Flexfield
**                                   used in the Detail Cursor
**  17 Apr 2003  atripath  2900104  Tuned the c_aba_details cursor
**  29 May 2003 apunekar  2920725   Corrected base tables to support security model
**  25 Jun 2004 srrajago  3603495   Cursor 'c_aba_msg' modified - Performance Fix.
**  06 Jun 2004 srrajago  3603495   Cursor 'c_aba_msg' modified - Performance Fix.
**  15 JUN 2009 skshin    8577918   Modified to make Amount rounded to 2
*/

level_cnt                     number ;

/*
**  Cursor to retrieve Westpac Direct Entry system Header info
*/

/*Bug2920725   Corrected base tables to support security model*/

cursor c_aba_header is
Select
        'RECORD_TYPE=P'
  ,     '0'
  ,      'ACCOUNT_HOLDER_NAME=P'
  ,      oea.segment3
  ,      'BSB_NUMBER=P'
  ,      oea.segment1
  ,      'ACCOUNT_NUMBER=P'
  ,      oea.segment2
  ,      'TRANSACTION_CODE=P'
  ,      popm.pmeth_information8
  ,      'INDICATOR=P'
  ,      nvl(popm.pmeth_information7,'NULL')
  ,      'TRANSACTION_DATE=P'
  ,      to_char(to_date(pay_magtape_generic.get_parameter_value('TRANSACTION_DATE'),'YYYY/MM/DD'),'ddmmyy')
                                                    -- Transaction Date
  ,      'BANK_MNEMONIC_CODE=P'
  ,      popm.pmeth_information1
  ,      'REEL_SEQUENCE_NUMBER=P'
  ,      '01'
  ,      'EFT_USER_NAME=P'
  ,      popm.pmeth_information3
  ,      'EFT_USER_ID=P'
  ,      popm.pmeth_information2
 ,      'FILE_DESCRIPTION=P'
  ,      popm.pmeth_information4
  ,      'INCLUDE_SUMMARY=P'
  ,      popm.pmeth_information9
  ,      'DEBIT_ITEM_AUTHORITY=P'
  ,      NVL(popm.pmeth_information5,'N')
  ,     'PAYROLL_NAME=P'
  ,     NVL(ppf.payroll_name,'Salary/Wages')
  from
         pay_org_payment_methods_f      popm
  ,      pay_external_accounts          oea
  ,      pay_payroll_actions            ppa
  ,      pay_payrolls_f 	        ppf
  where
         ppa.payroll_action_id           =
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    oea.external_account_id         = popm.external_account_id
  and    popm.org_payment_method_id      = ppa.org_payment_method_id
  and    ppa.effective_date between popm.effective_start_date and popm.effective_end_date
  and    ppa.effective_date between ppf.effective_start_date(+)  and ppf.effective_end_date(+)
  and    ppa.payroll_id = ppf.payroll_id(+)
  and exists (
	select
		paa.assignment_action_id
        from
	         per_assignments_f              a
	  ,      per_people_f               p
	  ,      pay_external_accounts          pea
	  ,      pay_pre_payments               ppp
	  ,      pay_assignment_actions         paa
	  ,      pay_personal_payment_methods_f pppm
	where
		  ppp.pre_payment_id              = paa.pre_payment_id
		  and    paa.payroll_action_id           = ppa.payroll_action_id
		  and    pea.external_account_id         = pppm.external_account_id
		  and    pppm.personal_payment_method_id = ppp.personal_payment_method_id
		  and    paa.assignment_id               = a.assignment_id
		  and    a.person_id                     = p.person_id
		  and    ppa.effective_date between pppm.effective_start_date and pppm.effective_end_date
		  and    ppa.effective_date between    a.effective_start_date and    a.effective_end_date
		  and    ppa.effective_date between    p.effective_start_date and    p.effective_end_date
		);


/*
**  Cursor to retrieve Westpac Direct Entry system Details info
*/
/* Bug #2421215 - For the remitters name, account name of the Bank Details FF has been used instead of Organization Name */
/*Bug2920725   Corrected base tables to support security model*/
cursor c_aba_detail is
  select
         'RECORD_TYPE=P'
  ,     '1'
  ,      'ACCOUNT_HOLDER_NAME=P'
  ,      pea.segment3
  ,      'BSB_NUMBER=P'
  ,      pea.segment1
  ,      'ACCOUNT_NUMBER=P'
  ,      pea.segment2
  ,      'USER_BSB_NUMBER=P'
  ,      oea.segment1
  ,      'USER_ACCOUNT_NUMBER=P'
  ,      oea.segment2
  ,      'TRANSACTION_CODE=P'
  ,      popm.pmeth_information8
  ,      'INDICATOR=P'
  ,      decode(popm.pmeth_information7,Null,' ','O',' ',popm.pmeth_information7)
  ,      'AMOUNT=P'
  ,      to_char(round(ppp.value,2)*100) /*bug8577918*/
  ,      'LODGEMENT_REFERENCE=P'
  ,      a.assignment_number
  ,      'REMITTER_NAME=P'
  ,      oea.segment3
  ,      'WITHHOLDING_TAX_AMOUNT=P'
  ,      '0'
  ,	 'ASSIGNMENT_ACTION_ID=P'
  ,	 paa.ASSIGNMENT_ACTION_ID
  from
           pay_org_payment_methods_f      popm
    ,      pay_external_accounts          oea
    ,      pay_personal_payment_methods_f pppm
    ,      pay_external_accounts          pea
    ,      pay_pre_payments               ppp
    ,      pay_assignment_actions         paa
    ,      pay_payroll_actions            ppa
    ,      per_assignments_f              a  /*bug 2900104*/
    ,      per_people_f                   p
 where  ppa.payroll_action_id           = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID') /*bug 2900104*/
    and    paa.payroll_action_id           = ppa.payroll_action_id
    and    ppp.pre_payment_id              = paa.pre_payment_id
    and    popm.org_payment_method_id      = ppp.org_payment_method_id
    and    oea.external_account_id         = popm.external_account_id
    and    pppm.personal_payment_method_id = ppp.personal_payment_method_id
    and    pea.external_account_id         = pppm.external_account_id
    and    paa.assignment_id               = a.assignment_id
    and    pppm.org_payment_method_id      = ppp.org_payment_method_id
    and    a.person_id                     = p.person_id
    and    ppa.effective_date between pppm.effective_start_date and pppm.effective_end_date
    and    ppa.effective_date between    a.effective_start_date and    a.effective_end_date
    and    ppa.effective_date between    p.effective_start_date and    p.effective_end_date
    and    ppa.effective_date between    popm.effective_start_date and    popm.effective_end_date
  order by decode(pay_magtape_generic.get_parameter_value('SORT_SEQUENCE'),'N',nvl(p.order_name,p.full_name),'B', pea.segment1 )
;
/*
**  Cursor to retrieve Westpac Direct Entry system control info
*/
/* Bug No: 3603495 - Performance fix in the following cursor. Introduced pay_payroll_actions and its join */
cursor c_aba_msg is
  select
  	'SOURCE_ID=P'
  ,	source_id
  ,	'SOURCE_TYPE=P'
  ,	source_type
  ,	'LINE_TEXT=P'
  ,	line_text
  ,	'TRANSFER_HEAD_FLAG=P'
    ,	decode(rownum,1,'Not_Printed','Printed')
  from
  	pay_message_lines m,
  	pay_assignment_actions a,
        pay_payroll_actions ppa,
        (SELECT pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID') payroll_action_id FROM dual WHERE rownum=1) ppas
  where
  	ppa.payroll_action_id = ppas.payroll_action_id
      and a.payroll_action_id = ppa.payroll_action_id
      and
  	a.assignment_action_id = m.source_id
      and
  	m.source_type = 'A';
end ;

/
