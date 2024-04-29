--------------------------------------------------------
--  DDL for Package PAY_DIRECT_DEPOSIT_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DIRECT_DEPOSIT_XML" AUTHID CURRENT_USER as
/* $Header: payddxml.pkh 120.3 2006/02/10 12:13 vpandya noship $ */

/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : pay_direct_deposit_xml
    Package File Name   : payddxml.pkh

    Description : Used for Direct Deposit Extract

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sodhingr      20-Jul-2005 115.0           Initial Version
    vmehta        16-Sep-2005 115.1           Modified the cursor so that the
                                              dates are stored in canonical
                                              format.
    sdahiya       20-Dec-2005 115.2           Dynamically fetch IANA charset
                                              to identify XML encoding.
    sdahiya       22-Dec-2005 115.3           Removed XML header information.
                                              PYUGEN will generate XML headers.
    vpandya       10-Feb-2006 115.4   5032348 Changed cursor c_get_details
                                              added alias payroll_action_id
                                              column as this column has newly
                                              been created for
                                              pay_pre_payments table also.
    ========================================================================*/

  CURSOR main_block  IS
    SELECT 'ROOT_XML_TAG=P',
           '<DIRECT_DEPOSIT>'
    FROM dual;


  CURSOR c_get_header IS
   select distinct 'PAYROLL_ACTION_ID=C',ppa.payroll_action_id,
                   'TRANSFER_PAYROLL_ACTION_ID=P',ppa.payroll_action_id,
                   'TRANSFER_DD_DATE=P',
                         fnd_date.date_to_canonical(nvl(overriding_dd_date
                                                         ,ppa.effective_date)),
                   'TRANSFER_BUSINESS_GROUP_ID=P',business_group_id,
                   'TRANSFER_EFFECTIVE_DATE=P',
                         fnd_date.date_to_canonical(ppa.effective_date),
                   'TRANSFER_ORG_PAY_METHOD=P',ppa.org_payment_method_id
   from pay_payroll_actions ppa
   where ppa.payroll_action_id =
                 pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
  --and ppa.payroll_action_id = paa.payroll_action_id
   --group by tax_unit_id,ppa.payroll_action_id, ppa.effective_date,
   --ppa.org_payment_method_id;



  CURSOR c_get_details IS
   SELECT 'TRANSFER_ACT_ID=P',paa.assignment_action_id,
          'TRANSFER_ASSIGNMENT_ID=P', assignment_id,
          'TRANSFER_PERSONAL_PAY_METH=P',ppp.personal_payment_method_id,
          'TRANSFER_PRE_PAY_ID=P',ppp.pre_payment_id,
          'TRANSFER_PREPAY_ASG_ACT=P',ppp.assignment_action_id,
          'DEPOSIT_AMOUNT=P', ppp.value
      FROM pay_assignment_actions paa
          ,pay_pre_payments ppp
     WHERE paa.payroll_action_id = pay_magtape_generic.get_parameter_value(
                                                'PAYROLL_ACTION_ID')
     and   paa.pre_payment_id = ppp.pre_payment_id;

  CURSOR c_get_asg_action IS
    SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
    FROM DUAL;


   PROCEDURE get_headers ;
   PROCEDURE generate_xml;
   PROCEDURE get_deposit_header;
   PROCEDURE get_footers;
   PROCEDURE get_deposit_footer;

   level_cnt   NUMBER :=0;

END pay_direct_deposit_xml;

 

/
