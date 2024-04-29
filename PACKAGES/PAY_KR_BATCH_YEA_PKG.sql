--------------------------------------------------------
--  DDL for Package PAY_KR_BATCH_YEA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_BATCH_YEA_PKG" AUTHID CURRENT_USER as
/* $Header: pykrbyea.pkh 115.5 2003/08/25 00:10:53 viagarwa noship $ */
--------------------------------------------------------------------------------
procedure range_code(
		p_payroll_action_id	in number,
		p_sqlstr		out NOCOPY varchar2);
--------------------------------------------------------------------------------
procedure initialization_code(p_payroll_action_id in number);
--------------------------------------------------------------------------------
procedure assignment_action_code(
		p_payroll_action_id	in number,
		p_start_person_id	in number,
		p_end_person_id		in number,
		p_chunk_number		in number);
--------------------------------------------------------------------------------
procedure reyea_assignment_action_code(
		p_payroll_action_id	in number,
		p_start_person_id	in number,
		p_end_person_id		in number,
		p_chunk_number		in number);
--------------------------------------------------------------------------------
procedure archive_code(
		p_assignment_action_id	in number,
		p_effective_date	in date);
--------------------------------------------------------------------------------
end pay_kr_batch_yea_pkg;

 

/
