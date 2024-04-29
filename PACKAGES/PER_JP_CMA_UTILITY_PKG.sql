--------------------------------------------------------
--  DDL for Package PER_JP_CMA_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_CMA_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: pejpcmau.pkh 120.0.12000000.2 2007/04/05 08:13:32 ttagawa ship $ */
--
-- Type Definitions
--
type cma_rec is record(
	non_taxable_amount	number,
	mtr_non_taxable_amount	number,
	taxable_amount		number,
	mtr_taxable_amount	number,
	si_wage			number,
	mtr_si_wage		number,
	si_wage_adj		number,
	mtr_si_wage_adj		number,
	si_fixed_wage		number,
	ui_wage_adj		number,
	multiple_entry_warning	boolean);
-- ----------------------------------------------------------------------------
-- |--------------------------< bg_cma_formula_id >---------------------------|
-- ----------------------------------------------------------------------------
function bg_cma_formula_id(p_business_group_id in number) return varchar2;
-- ----------------------------------------------------------------------------
-- |---------------------------< calc_car_amount >----------------------------|
-- ----------------------------------------------------------------------------
procedure calc_car_amount(
	p_formula_id		in number,
	p_business_group_id	in number,
	p_assignment_id		in number,
	p_effective_date	in date,
	p_ev_rec_tbl		in pay_jp_entries_pkg.ev_rec_tbl,
	p_attribute_tbl		in pay_jp_entries_pkg.attribute_tbl,
	p_outputs		out nocopy varchar2,
	p_val_returned		out nocopy boolean);
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_cma_info >-----------------------------|
-- ----------------------------------------------------------------------------
procedure get_cma_info(
	p_business_group_id		in number,
	p_assignment_id			in number,
	p_payment_date			in date, -- bug 4029525
	p_effective_date		in date,
	p_non_taxable_limit_1mth	in number,
	p_cma_rec			out nocopy cma_rec,
	p_record_exist			out nocopy boolean);
--
end per_jp_cma_utility_pkg;

 

/
