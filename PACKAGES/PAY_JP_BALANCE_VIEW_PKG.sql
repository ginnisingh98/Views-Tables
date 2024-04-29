--------------------------------------------------------
--  DDL for Package PAY_JP_BALANCE_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_BALANCE_VIEW_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpbalv.pkh 120.0 2006/04/24 00:03 ttagawa noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< get_value (date mode) >-------------------------|
-- ----------------------------------------------------------------------------
function get_value(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_defined_balance_id	in number,
	p_dimension_level	in varchar2,
	p_date_type		in varchar2,
	p_period_type		in varchar2,
	p_start_date_code	in varchar2,
	p_dimension_name	in varchar2,
	p_original_entry_id	in number default null) return number;
-- ----------------------------------------------------------------------------
-- |------------------------< get_value (date mode) >-------------------------|
-- ----------------------------------------------------------------------------
function get_value(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_defined_balance_id	in number,
	p_original_entry_id	in number default null) return number;
-- ----------------------------------------------------------------------------
-- |------------------------< get_value (date mode) >-------------------------|
-- ----------------------------------------------------------------------------
function get_value(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_balance_type_id	in number,
	p_dimension_name	in varchar2,
	p_business_group_id	in number,
	p_original_entry_id	in number default null) return number;
-- ----------------------------------------------------------------------------
-- |-----------------------< get_value (action mode) >------------------------|
-- ----------------------------------------------------------------------------
function get_value(
	p_assignment_action_id	in number,
	p_balance_type_id	in number,
	p_dimension_name	in varchar2,
	p_business_group_id	in number,
	p_original_entry_id	in number default null) return number;
--
end pay_jp_balance_view_pkg;

 

/
