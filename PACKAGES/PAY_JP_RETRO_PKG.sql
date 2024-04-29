--------------------------------------------------------
--  DDL for Package PAY_JP_RETRO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_RETRO_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpretr.pkh 120.1 2005/09/05 19:08:52 hikubo noship $ */
	--
-------------------------------------------------------------
	FUNCTION get_retropayments
-------------------------------------------------------------
	(
		p_assignment_id in number,
		p_date_earned   in date
	) RETURN number;
	--
-------------------------------------------------------------
	FUNCTION GET_PLSQL_GLOBAL
-------------------------------------------------------------
	(
		p_global_name in varchar2,
		p_mth_ago     in number,
		p_type        in varchar2
	) return number;
--	PRAGMA RESTRICT_REFERENCES (get_plsql_global, WNDS, WNPS);
	--
-------------------------------------------------------------
	FUNCTION get_retro_mth
-------------------------------------------------------------
	(
		p_mth_ago in number
	) RETURN number;
	--
-------------------------------------------------------------
	FUNCTION get_first_retro_amt
-------------------------------------------------------------
	RETURN number;
	--
-------------------------------------------------------------
	FUNCTION get_first_retro_mth
-------------------------------------------------------------
	RETURN number;
	--
-------------------------------------------------------------
	FUNCTION get_last_assact
-------------------------------------------------------------
	(
		p_assignment_id       IN NUMBER,
		p_effective_date_from IN DATE,
		p_effective_date_to   IN DATE
	) RETURN NUMBER;
	--
-------------------------------------------------------------
	FUNCTION balance_fetch
-------------------------------------------------------------
	(
		p_assignment_id  in number,
		p_item_name      in varchar2,
		p_effective_date in date
	) RETURN number;
	--
-------------------------------------------------------------
	FUNCTION get_balance_value
-------------------------------------------------------------
	(
		p_business_group_id    IN NUMBER,
		p_item_name            IN VARCHAR2,
		p_assignment_action_id IN NUMBER
	) RETURN NUMBER;
	--
END;

 

/
