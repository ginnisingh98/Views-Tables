--------------------------------------------------------
--  DDL for Package PAY_JP_GET_MONTH_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_GET_MONTH_BALANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: pyjpgmbl.pkh 115.1 99/10/12 02:17:18 porting ship $ */
	FUNCTION get_month_balance(
		p_business_group_id	NUMBER,
		p_assignment_id		NUMBER,
		p_balance_name		VARCHAR2,
		p_months_prior		NUMBER)
	RETURN NUMBER;
--	pragma restrict_references (get_month_balance, WNDS, WNPS);
--
	FUNCTION get_month_adjustments(
		p_business_group_id	NUMBER,
		p_assignment_id		NUMBER,
		p_balance_name		VARCHAR2,
		p_months_prior		NUMBER)
        RETURN NUMBER;
--	pragma restrict_references (get_month_adjustments, WNDS, WNPS);
END pay_jp_get_month_balance_pkg;


 

/
