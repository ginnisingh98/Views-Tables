--------------------------------------------------------
--  DDL for Package PAY_IE_ADVANCE_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_ADVANCE_PAY" AUTHID CURRENT_USER as
/* $Header: pyieadvpay.pkh 115.1 2003/11/18 03:21:35 srkotwal noship $ */
   Function adv_payment_skip_rule(p_element_entry_id Number,
                                  p_date_earned date,
                                  p_payroll_action_id Number)
   return varchar2;
end pay_ie_advance_pay;

 

/
