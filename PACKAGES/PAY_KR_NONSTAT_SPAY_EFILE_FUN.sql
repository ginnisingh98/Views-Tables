--------------------------------------------------------
--  DDL for Package PAY_KR_NONSTAT_SPAY_EFILE_FUN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_NONSTAT_SPAY_EFILE_FUN" AUTHID CURRENT_USER as
/*$Header: pykrnspen.pkh 120.0.12010000.2 2009/01/16 13:05:45 vaisriva ship $ */

/*************************************************************************
 * Function that count the Previous Employers.
 *************************************************************************/
function get_prev_emp_count (p_assignment_action_id IN Number) return Number;

/*************************************************************************
 * Bug 7712932: Function to return the Statutory/Non-Statutory Separation
 * Pay Overseas Tax Break values.
 *************************************************************************/
 FUNCTION get_sep_pay_ovr_tax_brk(
		p_assignment_action_id 	in number,
		p_assignment_id		in number,
		p_type 			in varchar2) return number;

end pay_kr_nonstat_spay_efile_fun;

/
