--------------------------------------------------------
--  DDL for Package DK_CONSUMED_ENTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DK_CONSUMED_ENTRY" AUTHID CURRENT_USER as
 /* $Header: pydkconsum.pkh 120.0.12010000.3 2009/10/28 12:20:39 knadhan noship $ */


FUNCTION consumed_entry_spl (
				p_date_earned	IN DATE,
				p_payroll_id	IN NUMBER,
				p_asg_id	IN NUMBER) RETURN VARCHAR2;

FUNCTION consumed_entry_indirect (	p_date_earned	IN DATE,
				p_payroll_id	IN NUMBER,
				p_ele_entry_id	IN NUMBER
				) RETURN VARCHAR2;

END DK_CONSUMED_ENTRY;

/
