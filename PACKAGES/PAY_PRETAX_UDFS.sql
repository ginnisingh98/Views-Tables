--------------------------------------------------------
--  DDL for Package PAY_PRETAX_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PRETAX_UDFS" AUTHID CURRENT_USER AS
/* $Header: pyptxudf.pkh 115.2 99/07/17 06:27:03 porting ship  $ */


FUNCTION pretax_period_type (	p_date_earned	in date,
				p_eletype_id	in number) return varchar2;

FUNCTION pretax_row_type (	p_date_earned	in date,
				p_eletype_id	in number) return varchar2;

FUNCTION pretax_payroll_table (	p_date_earned	in date,
				p_eletype_id	in number) return varchar2;

FUNCTION pretax_ben_ee_contr (	p_date_earned	in date,
				p_eletype_id	in number,
				p_coverage	in varchar2) return number;

FUNCTION pretax_ben_er_contr (	p_date_earned	in date,
				p_eletype_id	in number,
				p_coverage	in varchar2) return number;

END pay_pretax_udfs;

 

/
