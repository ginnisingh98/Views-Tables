--------------------------------------------------------
--  DDL for Package PAY_JP_DEF_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_DEF_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pyjpdefc.pkh 120.0.12000000.1 2007/01/17 21:35:59 appldev noship $ */
--
-- Procedures for ARCHIVE process
--
procedure initialization_code(p_payroll_action_id in number);
procedure range_code(
	p_payroll_action_id		in number,
	p_sqlstr			out nocopy varchar2);
procedure assignment_action_code(
	p_payroll_action_id		in number,
	p_start_person_id		in number,
	p_end_person_id			in number,
	p_chunk_number			in number);
procedure archive_assact(
	p_assignment_action_id		in number,
	p_effective_date		in date);
procedure deinitialization_code(p_payroll_action_id in number);
--
end pay_jp_def_archive;

 

/
