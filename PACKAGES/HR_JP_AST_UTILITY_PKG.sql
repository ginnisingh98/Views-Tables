--------------------------------------------------------
--  DDL for Package HR_JP_AST_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JP_AST_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: hrjpastu.pkh 120.0.12010000.1 2008/10/14 08:16:10 keyazawa noship $ */
--
-- Type Definition
--
type t_number_tbl is table of number index by binary_integer;
type t_varchar2_tbl is table of varchar2(255) index by binary_integer;
type t_date_tbl is table of date index by binary_integer;
type t_asg_rec is record(
	assignment_id_tbl	t_number_tbl,
	effective_date_tbl	t_date_tbl,
	assignment_number_tbl	t_varchar2_tbl,
	full_name_tbl		t_varchar2_tbl);
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_assignment_set_name >------------------------|
-- ----------------------------------------------------------------------------
procedure chk_assignment_set_name(
	p_assignment_set_name		in varchar2,
	p_business_group_id		in number);
-- ----------------------------------------------------------------------------
-- |----------------------------< create_asg_set >----------------------------|
-- ----------------------------------------------------------------------------
procedure create_asg_set(
	p_assignment_set_name		in varchar2,
	p_business_group_id		in number,
	p_payroll_id			in number,
	p_assignment_set_id	 out nocopy number);
-- ----------------------------------------------------------------------------
-- |--------------------< create_asg_set_with_request_id >--------------------|
-- ----------------------------------------------------------------------------
procedure create_asg_set_with_request_id(
	p_prefix			in varchar2,
	p_business_group_id		in number,
	p_payroll_id			in number,
	p_assignment_set_id	 out nocopy number,
	p_assignment_set_name	 out nocopy varchar2);
-- ----------------------------------------------------------------------------
-- |--------------------------< create_asg_set_amd >--------------------------|
-- ----------------------------------------------------------------------------
procedure create_asg_set_amd(
	p_assignment_set_id		in number,
	p_assignment_id			in number,
	p_include_or_exclude		in varchar2);
-- ----------------------------------------------------------------------------
-- |-----------------------< get_assignment_set_info >------------------------|
-- ----------------------------------------------------------------------------
procedure get_assignment_set_info(
	p_assignment_set_id	in number,
	p_formula_id		out nocopy number,
	p_amendment_type	out nocopy varchar2);
-- ----------------------------------------------------------------------------
-- |--------------------------< amendment_validate >--------------------------|
-- ----------------------------------------------------------------------------
function amendment_validate(
	p_assignment_set_id	in number,
	p_assignment_id		in number) return varchar2;
-- ----------------------------------------------------------------------------
-- |---------------------------< formula_validate >---------------------------|
-- ----------------------------------------------------------------------------
function formula_validate(
	p_formula_id			in number,
	p_assignment_id			in number,
	p_effective_date		in date,
	p_populate_fs			in boolean default false) return boolean;
-- ----------------------------------------------------------------------------
-- |------------------------< assignment_set_validate >------------------------|
-- ----------------------------------------------------------------------------
function assignment_set_validate(
	p_assignment_set_id	in number,
	p_assignment_id		in number,
	p_effective_date	in date,
	p_populate_fs_flag	in varchar2 default 'N') return varchar2;
-- ----------------------------------------------------------------------------
-- |-------------------------------< pay_asgs >-------------------------------|
-- ----------------------------------------------------------------------------
procedure pay_asgs(
	p_payroll_id			in number,
	p_effective_date		in date,
	p_start_date			in date,
	p_end_date			in date,
	p_assignment_set_id		in number,
	p_asg_rec		 out nocopy t_asg_rec);
--
end hr_jp_ast_utility_pkg;

/
