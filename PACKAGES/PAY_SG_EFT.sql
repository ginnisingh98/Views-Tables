--------------------------------------------------------
--  DDL for Package PAY_SG_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_EFT" AUTHID CURRENT_USER as
/* $Header: pysgeft.pkh 120.1.12010000.3 2008/09/12 12:19:39 lnagaraj ship $
**
**  Copyright (c) 2000 Oracle Corporation
**  All Rights Reserved
**
**  Singapore EFT direct credit of pay (IBG format)
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  30 OCT 2000 nrobolas   SGD0013     Created
**  28 NOV 2000 nrobolas               Added REPLACE function
**  29 NOV 2000 nrobolas               The advice cursor now looks up
**                                     the bank id from hr_lookups.
**  29 NOV 2000 nrobolas               Streamline the Control record cursor.
**  19 DEC 2000 aalvarez   1530569     added where exists clause in cursor
**                                     c_ibg_control
**  21 NOV 2001 shoskatt   2115345     The order by clause in the advice cursor
**                                     has been changed. Amount has been ordered by
**                                     ascending value
**  04 JAN 2002 shoskatt   2168489     The Control cursor has been changed to retrieve
**                                     account name
**  01 MAR 2002 shoskatt   2240758     Included the Check File Syntax
**  24 APR 2002 Ragovind   2343261     Changed the cursor c_ibg_advice to get full Bank_name.
**  05 JUN 2002 jkarouza   2405428     Changed the cursor c_ibg_advice to modify Account Number
**                                     as required in Bug 2405428
**  30 NOB 2002 jkarouza   2689220     Changed cursor c_ibg_controlk to modify Account Number
**                                     as required in Bug 2405428 for bug 2689220.
**  21 Jan 2003 apunekar   2762569     Fixed for Bank Code 7302
**  07 Feb 2003 nanuradh   2788865     Added date track check for Organizational payment method
**  10 Feb 2003 nanuradh   2793695     cursor c_ibg_advice is modified to fetch first 20
**                                     characters of employee_name
**  11 Mar 2003 apunekar   2843503     Modified cursor c_ibg_advice and c_ibg_control for POSB bank .
**  28 May 2003 nanuradh   2920732     Modified the package to use the secured views instead of base tables.
**  17 DEC 2004 agore      4072941     removed function sequence_number
**                                     Instead referred pay_sg_ibg_s.nextval directly in cursor query
**  14 FEB 2007 snimmala   5749324     Included ppa.payroll_action_id join in the cursor c_ibg_advice
**                                     to resolve performance issue.
**  04 AUG 2008 jalin      7296560     Modified to get TRAN_CODE from parameter
*/


level_cnt           number ;

/*
**  Cursor to retrieve IBG Direct Deposit system control record info
*/

cursor c_ibg_control is
Select   'RECORD_TYPE=P'
  ,      '0'
  ,      'VALUE_DATE=P'
  ,      pay_magtape_generic.get_parameter_value('TRANSACTION_DATE')
  ,      'O_BANK_NO=P'
  ,      decode(sign((ses.effective_date)
        - to_date('31/12/2001','dd/mm/yyyy')-1),-1,hrl.meaning,decode(lookup_code,'POSB',7171,hrl.meaning))/*bug2843503*/
  ,      'O_BRANCH_NO=P'
  ,      oea.segment6
  ,      'O_ACCOUNT_NO=P'
  ,      decode(hrl.meaning, '7117', replace(substr(oea.segment1,4),'-',null),
                             '7232', replace(substr(oea.segment1,4),'-',null),
                             '7339', replace(substr(oea.segment1,4),'-',null),
                             '7357', replace(substr(oea.segment1,3),'-',null),
                             '7302', replace((substr(oea.segment1,1,1) ||
                                                      substr(oea.segment1,5)),'-',null),/*Bug#2762569*/
                             replace(oea.segment1,'-',null))
  ,      'O_ACCOUNT_NAME=P'
  ,      oea.segment2
  ,      'ORG_NAME=P'
  ,      nvl(o.name,'NULL VALUE')
  ,      'SEQ_NO=P'
  ,      pay_sg_ibg_s.nextval
  ,      'COMPANY_ID=P'
  ,      popm.pmeth_information1
  ,      'PAY_METHOD=P'
  ,      popm.org_payment_method_name
  from   pay_org_payment_methods_f      popm
   ,	fnd_sessions ses
  ,      pay_external_accounts          oea
  ,      pay_payroll_actions            ppa
  ,      hr_organization_units          o
  ,      hr_lookups                     hrl
  where  ppa.payroll_action_id           =
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    oea.external_account_id         = popm.external_account_id
  and session_id = userenv('sessionid')
  and    ppa.business_group_id           = o.organization_id
  and    hrl.lookup_code                 = oea.segment4
  and    popm.org_payment_method_id      = ppa.org_payment_method_id
  and    hrl.lookup_type                 = 'SG_BANK_CODE'
  and    ppa.effective_date between popm.effective_start_date and popm.effective_end_date
  and exists (
	select
		paa.assignment_action_id
        from
	         per_assignments_f              a
	  ,      per_people_f                   p    /* Bug# 2920732 */
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
** Cursor to retrieve IBG Direct Deposit System payment info
*/

  cursor c_ibg_advice is
  Select  'RECORD_TYPE=P'
    ,     '1'
    ,     'R_BANK_NO=P'
    ,      decode(sign((ses.effective_date)
        - to_date('31/12/2001','dd/mm/yyyy')-1),-1,hrl.meaning,decode(lookup_code,'POSB',7171,hrl.meaning))/*Bug2843503*/
    ,     'R_BRANCH_NO=P'
    ,      decode(hrl.meaning, '9812', '081',
			       pea.segment6)
    ,     'R_ACCOUNT_NO=P'
    ,      decode(hrl.meaning, '7117', replace(substr(pea.segment1,4),'-',null),
                               '7232', replace(substr(pea.segment1,4),'-',null),
                               '7339', replace(substr(pea.segment1,4),'-',null),
                               '7357', replace(substr(pea.segment1,3),'-',null),
                               '7302', replace((substr(pea.segment1,1,1) ||
                                                        substr(pea.segment1,5)),'-',null),/*Bug#2762569*/
                               replace(pea.segment1,'-',null))
    ,     'R_ACCOUNT_NAME=P'
    ,      substr(pea.segment2,1,20)
    ,     'TRAN_CODE=P'
    ,      NVL(pay_magtape_generic.get_parameter_value('TRANSACTION_CODE'),'22')
    ,     'PAY_AMOUNT=P'
    ,      to_char(NVL(ppp.value,0)*100) a_amount
    ,     'NRIC=P'
    ,      nvl(substr(p.national_identifier,1,9),' ')
    ,     'EMPLOYEE_NAME=P'
    ,      substr(p.full_name,1,20)      /* Bug # 2793695 */
    ,     'EMPLOYEE_NO=P'
    ,      NVL(SUBSTR(p.employee_number,1,10), 'NULL VALUE')
    ,	   'BANK_NAME=P'
    ,      NVL(pea.segment5, 'NULL VALUE') /* Bug#2342361 */
  from
           pay_org_payment_methods_f      popm
    ,      pay_external_accounts          oea
    ,      pay_personal_payment_methods_f pppm
    ,      pay_external_accounts          pea
    ,      pay_pre_payments               ppp
    ,      pay_assignment_actions         paa
    ,      pay_payroll_actions            ppa
    ,      per_assignments_f              a
    ,      per_people_f                   p   /* Bug# 2920732 */
    ,      hr_organization_units          o
    ,      hr_lookups                     hrl
    ,      fnd_sessions ses
  where
         paa.payroll_action_id           =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    ppa.payroll_action_id           =
             pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID') /* Bug#5749324 */
  and    ses.session_id = userenv('sessionid')
  and    ppp.pre_payment_id              = paa.pre_payment_id
  and    paa.payroll_action_id           = ppa.payroll_action_id
  and    oea.external_account_id         = popm.external_account_id
  and    popm.org_payment_method_id      = ppp.org_payment_method_id
  and    pea.external_account_id         = pppm.external_account_id
  and    pppm.personal_payment_method_id = ppp.personal_payment_method_id
  and    paa.assignment_id               = a.assignment_id
  and    a.person_id                     = p.person_id
  and    a.business_group_id             = o.organization_id
  and    hrl.lookup_code                 = pea.segment4
  and    hrl.lookup_type                 = 'SG_BANK_CODE'
  and    o.name                          = pay_magtape_generic.get_parameter_value('ORG_NAME')
  and    popm.org_payment_method_name    = pay_magtape_generic.get_parameter_value('PAY_METHOD')
  and    ppa.effective_date between pppm.effective_start_date and pppm.effective_end_date
  and    ppa.effective_date between a.effective_start_date and a.effective_end_date
  and    ppa.effective_date between p.effective_start_date and p.effective_end_date
  and    ppa.effective_date between popm.effective_start_date and popm.effective_end_date   /* Bug : 2788865 */
  order by decode(sign(1-nvl(ppp.value,0)),1,999999999999,ppp.value) asc, p.full_name asc;
End ;

/
