--------------------------------------------------------
--  DDL for Package PAY_FR_PAY_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_PAY_FILE" AUTHID CURRENT_USER as
/* $Header: pyfrpfcr.pkh 115.4 2002/10/15 18:28:20 aparkes ship $
**
**  Copyright (c) 2000 Oracle Corporation
**  All Rights Reserved
**
**  French Payment Output File
**
**  Change List
**  ===========
**
**  Date        Author   Version Bug      Description
**  -----------+--------+-------+--------+-----------------------------
**  22 Nov 2001 anprasad                  Created
**  19 Feb 2002 khicks           2231637  added dbdrv lines
**  15 Oct 2002 aparkes  115.4   2610927  Cursor changes
*/


level_cnt number;

/********************************************************
*  	Cursor to fetch header record information	*
********************************************************/


cursor fr_payfile_header is
  select  'TRANSFER_PROCESS_DATE=P',       /* Input parameter */
                 to_char(ppa.overriding_dd_date, 'DD/MM/YYYY'),
          'DATE_EARNED=C',                 /* Context value for DB items */
                to_char(ppa.effective_date, 'YYYY/MM/DD HH24:MI:SS'),
          'ORG_PAY_METHOD_ID=C',           /* Context value for DB items */
                ppa.org_payment_method_id,
          'BUSINESS_GROUP_ID=C', ppa.business_group_id
  from  pay_payroll_actions       ppa
  where ppa.payroll_action_id =
       pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');


/********************************************************
*  	Cursor to fetch body record information		*
********************************************************/

cursor fr_payfile_body is
 select    'TRANSFER_VALUE=P',             /* Value for field Amount in body record */
              ppp.value * 100,
           'PER_PAY_METHOD_ID=C',          /* Context value for DB items */
              ppp.personal_payment_method_id,
           'TAX_UNIT_ID=C', paa.tax_unit_id,
           'ASSIGNMENT_ACTION_ID=P', paa.assignment_action_id
 from   per_assignments_f            pa,
        per_people_f                 per,
        pay_pre_payments             ppp,
        pay_assignment_actions       paa,
        pay_payroll_actions          ppa
 where  paa.payroll_action_id          =
          pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
   and  paa.pre_payment_id             = ppp.pre_payment_id
   and  paa.payroll_action_id          = ppa.payroll_action_id
   and  paa.assignment_id              = pa.assignment_id
   and  pa.person_id                   = per.person_id
   and  ppa.effective_date between pa.effective_start_date and pa.effective_end_date
   and  ppa.effective_date between per.effective_start_date and per.effective_end_date
order by decode(pay_magtape_generic.get_parameter_value('SET_ORDER_BY'),
                                   'NAME', per.order_name,
                                   'NUMBER', per.employee_number, null);

FUNCTION get_payers_id (p_opm_id      in number,
                        P_bg_id       in number,
                        P_date_earned in date)
                        return varchar2;

FUNCTION valid_org (p_estab_id in number) return varchar2;

end pay_fr_pay_file;

 

/
