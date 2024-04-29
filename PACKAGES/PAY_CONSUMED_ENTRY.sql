--------------------------------------------------------
--  DDL for Package PAY_CONSUMED_ENTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CONSUMED_ENTRY" AUTHID CURRENT_USER as
/* $Header: pyconsum.pkh 115.2 99/07/17 05:53:34 porting ship  $ */


FUNCTION consumed_entry (
				p_date_earned	IN DATE,
				p_payroll_id	IN NUMBER,
				p_ele_entry_id	IN NUMBER) RETURN VARCHAR2;

end pay_consumed_entry;

 

/
