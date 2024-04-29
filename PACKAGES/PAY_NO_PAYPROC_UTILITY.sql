--------------------------------------------------------
--  DDL for Package PAY_NO_PAYPROC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_PAYPROC_UTILITY" AUTHID CURRENT_USER AS
/* $Header: pynopprocu.pkh 120.0 2005/05/29 10:52:35 appldev noship $ */

 level_cnt NUMBER;

FUNCTION get_parameter(p_payroll_action_id   NUMBER,
                       p_token_name         VARCHAR2)
			RETURN VARCHAR2;

FUNCTION get_payment_method_id(
                               p_payroll_id  number,
			       p_effective_date  date
                             ) return number;

FUNCTION get_payment_invoice_or_mass  (
                             p_personal_method_id  in number,
			     p_payroll_id in number,
			     p_effective_date in date
                             ) return number;

FUNCTION get_account_no   (
                             p_personal_method_id  in number,
			     p_payroll_id in number,
			     p_effective_date in date
                             ) return number;

end  PAY_NO_PAYPROC_UTILITY;

 

/
