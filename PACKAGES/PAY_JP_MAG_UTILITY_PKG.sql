--------------------------------------------------------
--  DDL for Package PAY_JP_MAG_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_MAG_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpmagu.pkh 120.1 2005/06/13 19:55:41 ttagawa noship $ */
--
procedure show_formula_queue;
procedure enqueue_formula(p_formula_id in number);
function dequeue_formula return number;
--
procedure show_contexts;
procedure clear_contexts;
procedure set_context(
	p_context_name		in varchar2,
	p_context_value		in varchar2);
procedure set_context(
	p_context_name		in varchar2,
	p_context_value		in number);
procedure set_context(
	p_context_name		in varchar2,
	p_context_value		in date);
--
procedure show_parameters;
function get_parameter(p_parameter_name in varchar2) return varchar2;
procedure set_parameter(
	p_parameter_name	in varchar2,
	p_parameter_value	in varchar2,
	p_default_value		in varchar2 default ' ');
procedure set_parameter(
	p_parameter_name	in varchar2,
	p_parameter_value	in number,
	p_default_value		in number default 0);
procedure set_parameter(
	p_parameter_name	in varchar2,
	p_parameter_value	in date,
	p_default_value		in date default trunc(sysdate));
--
end pay_jp_mag_utility_pkg;

 

/
