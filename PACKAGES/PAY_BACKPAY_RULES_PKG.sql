--------------------------------------------------------
--  DDL for Package PAY_BACKPAY_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BACKPAY_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: pybkr01t.pkh 115.0 99/07/17 05:45:44 porting ship $ */
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--
-- Standard Insert procedure
--
procedure insert_row(
	p_row_id		IN OUT varchar2,
	p_defined_balance_id	number,
	p_input_value_id	number,
	p_backpay_set_id	number);
--
-- Standard delete procedure
--
procedure delete_row(p_row_id	varchar2);
--
--
--
-- Standard lock procedure
--
procedure lock_row(
	p_row_id		varchar2,
	p_defined_balance_id	number,
	p_input_value_id	number,
	p_backpay_set_id	number);
--
-- Standard update procedure.
-- N.B. Not currrently used as updates are not permitted in PAYWSDBS.
--
procedure update_row(
	p_row_id		varchar2,
	p_defined_balance_id	number,
	p_input_value_id	number,
	p_backpay_set_id	number);
--
procedure std_insert_checks(
	p_backpay_set_id	number,
	p_balance_type_id	number,
	p_input_value_id	number);
--
procedure chk_overlap_bal_feeds(
	p_backpay_set_id 	number);
--
END PAY_BACKPAY_RULES_PKG;

 

/
