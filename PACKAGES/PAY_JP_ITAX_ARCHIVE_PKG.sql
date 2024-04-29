--------------------------------------------------------
--  DDL for Package PAY_JP_ITAX_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_ITAX_ARCHIVE_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpiarc.pkh 120.5.12010000.1 2008/07/27 22:59:14 appldev ship $ */
--
procedure initialization_code(p_payroll_action_id in number);
--
procedure range_code(
	p_payroll_action_id	in number,
	p_sqlstr		out nocopy varchar2);
--
procedure assignment_action_code (
	p_payroll_action_id	in number,
	p_start_person_id	in number,
	p_end_person_id		in number,
	p_chunk			in number);
--
procedure archive_code (
	p_assignment_action_id	in number,
	p_effective_date	in date);
--
procedure deinitialization_code(p_payroll_action_id in number);
--
end pay_jp_itax_archive_pkg;

/
