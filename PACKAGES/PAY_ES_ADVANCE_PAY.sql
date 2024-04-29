--------------------------------------------------------
--  DDL for Package PAY_ES_ADVANCE_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_ADVANCE_PAY" AUTHID CURRENT_USER AS
/* $Header: pyesapay.pkh 120.0 2005/06/03 06:47:22 appldev noship $ */
   FUNCTION adv_payment_skip_rule(p_element_entry_id NUMBER,
                                  p_date_earned DATE,
                                  p_payroll_action_id NUMBER) RETURN VARCHAR2;
END pay_es_advance_pay;

 

/
