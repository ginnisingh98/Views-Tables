--------------------------------------------------------
--  DDL for Package PAY_JP_YEA_BAL_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_YEA_BAL_ADJ_PKG" AUTHID CURRENT_USER AS
/* $Header: pyjpyeba.pkh 120.0 2006/02/26 17:04 hikubo noship $ */

FUNCTION get_formula_name
(
	p_business_group_id in varchar2,
	p_payroll_id        in varchar2,
	p_effective_date    in varchar2
) RETURN varchar2;

FUNCTION call_formula
(
	p_business_group_id    in number,
	p_payroll_id           in number,
	p_payroll_action_id    in number,
	p_assignment_id        in number,
	p_assignment_action_id in number,
	p_date_earned          in date,
	p_element_entry_id     in number,
	p_element_type_id      in number
) RETURN number;
--
FUNCTION get_number_value (p_number in number) RETURN number;
--
FUNCTION get_text_value   (p_number in number) RETURN varchar2;
--
FUNCTION get_date_value   (p_number in number) RETURN date;
--
END PAY_JP_YEA_BAL_ADJ_PKG;

 

/
