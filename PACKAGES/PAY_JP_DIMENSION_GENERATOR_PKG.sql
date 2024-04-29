--------------------------------------------------------
--  DDL for Package PAY_JP_DIMENSION_GENERATOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_DIMENSION_GENERATOR_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpdimg.pkh 120.0 2006/04/24 00:01 ttagawa noship $ */
--
function start_date(
	p_effective_date	in date,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number) return date;
--
function end_date(
	p_effective_date	in date,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number) return date;
--
procedure create_balance_dimension(
	p_dimension_name	in varchar2,
	p_database_item_suffix	in varchar2,
	p_business_group_id	in number,
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number,
	p_exclude_reversal	in boolean,
	p_balance_dimension_id	out nocopy number,
	p_rebuild_package	in boolean default true);
--
procedure create_balance_dimension(
	errbuf			out nocopy varchar2,
	retcode			out nocopy varchar2,
	p_dimension_name	in varchar2,
	p_database_item_suffix	in varchar2,
	p_business_group_id	in varchar2,
	p_date_type		in varchar2,
	p_reset_date		in varchar2,
	p_frequency_type	in varchar2,
	p_frequency		in varchar2,
	p_exclude_reversal	in varchar2);
--
procedure update_balance_dimension(
	p_balance_dimension_id	in number,
	p_date_type		in varchar2,
	p_reset_date		in date,
	p_frequency_type	in varchar2,
	p_frequency		in number,
	p_exclude_reversal	in boolean,
	p_rebuild_package	in boolean default true);
--
procedure update_balance_dimension(
	errbuf			out nocopy varchar2,
	retcode			out nocopy varchar2,
	p_balance_dimension_id	in varchar2,
	p_date_type		in varchar2,
	p_reset_date		in varchar2,
	p_frequency_type	in varchar2,
	p_frequency		in varchar2,
	p_exclude_reversal	in varchar2);
--
procedure rebuild_package(p_rebuild_dimension in boolean default false);
--
procedure rebuild_package(
	errbuf			out nocopy varchar2,
	retcode			out nocopy varchar2,
	p_rebuild_dimension	in varchar2);
--
end pay_jp_dimension_generator_pkg;

 

/
