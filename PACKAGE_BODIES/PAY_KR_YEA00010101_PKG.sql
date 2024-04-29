--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA00010101_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA00010101_PKG" as
/* $Header: pykryea0.pkb 120.2 2005/11/24 02:31:57 viagarwa noship $ */
--
procedure yea(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_business_group_id	in number,
	p_yea_info		in out NOCOPY pay_kr_yea_pkg.t_yea_info)
is
	l_addend			number;
	l_multiplier			number;
	l_subtrahend			number;
	l_dummy				number;
	l_net_housing_exp_tax_break	number;
	l_calc_tax_for_stax		number;
	l_cuml_special_exem 	       number default 0 ; -- Adds up all special exemptions given for tracking purpose, for limit on exemptions.
	--
	function calc_tax(p_taxation_base in number) return number
	is
	begin
		if p_taxation_base > 0 then
			l_multiplier	:= to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'CALC_TAX',
							p_col_name		=> 'MULTIPLIER',
							p_row_value		=> to_char(p_taxation_base),
							p_effective_date	=> p_effective_date));
			l_subtrahend	:= to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'CALC_TAX',
							p_col_name		=> 'SUBTRAHEND',
							p_row_value		=> to_char(p_taxation_base),
							p_effective_date	=> p_effective_date));
			return trunc(p_taxation_base * l_multiplier / 100) - l_subtrahend;
		else
			return 0;
		end if;
	end calc_tax;
begin
	----------------------------------------------------------------
	-- Basic Income Exemption
	-- Taxable Income
	----------------------------------------------------------------
	if p_yea_info.taxable > 0 then
		l_addend	:= to_number(hruserdt.get_table_value(
						p_bus_group_id		=> p_business_group_id,
						p_table_name		=> 'BASIC_INCOME_EXEM',
						p_col_name		=> 'ADDEND',
						p_row_value		=> to_char(p_yea_info.taxable),
						p_effective_date	=> p_effective_date));
		l_multiplier	:= to_number(hruserdt.get_table_value(
						p_bus_group_id		=> p_business_group_id,
						p_table_name		=> 'BASIC_INCOME_EXEM',
						p_col_name		=> 'MULTIPLIER',
						p_row_value		=> to_char(p_yea_info.taxable),
						p_effective_date	=> p_effective_date));
		l_subtrahend	:= to_number(hruserdt.get_table_value(
						p_bus_group_id		=> p_business_group_id,
						p_table_name		=> 'BASIC_INCOME_EXEM',
						p_col_name		=> 'SUBTRAHEND',
						p_row_value		=> to_char(p_yea_info.taxable),
						p_effective_date	=> p_effective_date));
		p_yea_info.basic_income_exem := l_addend + trunc(l_multiplier / 100 * (p_yea_info.taxable - l_subtrahend));
		p_yea_info.taxable_income := p_yea_info.taxable - p_yea_info.basic_income_exem;
	end if;
	p_yea_info.taxable_income2 := p_yea_info.taxable_income;
	----------------------------------------------------------------
	-- Employee Tax Exemption
	----------------------------------------------------------------
	p_yea_info.ee_tax_exem := 1000000;
	p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.ee_tax_exem;
	----------------------------------------------------------------
	-- Dependent Tax Exemption
	----------------------------------------------------------------
	if p_yea_info.dpnt_spouse_flag = 'Y' then
		p_yea_info.dpnt_spouse_tax_exem := 1000000;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.dpnt_spouse_tax_exem;
		l_dummy := 1;
	else
		l_dummy := 0;
	end if;
	if p_yea_info.num_of_dpnts > 0 then
		p_yea_info.dpnt_tax_exem := p_yea_info.num_of_dpnts * 1000000;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.dpnt_tax_exem;
		l_dummy := l_dummy + p_yea_info.num_of_dpnts;
	end if;
	if p_yea_info.num_of_ageds > 0 then
		p_yea_info.aged_tax_exem := p_yea_info.num_of_ageds * 500000;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.aged_tax_exem;
	end if;
	if p_yea_info.num_of_disableds > 0 then
		p_yea_info.disabled_tax_exem := p_yea_info.num_of_disableds * 500000;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.disabled_tax_exem;
	end if;
	if p_yea_info.female_ee_flag = 'Y' then
		p_yea_info.female_ee_tax_exem := 500000;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.female_ee_tax_exem;
	end if;
	if p_yea_info.num_of_children > 0 then
		p_yea_info.child_tax_exem := p_yea_info.num_of_children * 500000;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.child_tax_exem;
	end if;
	----------------------------------------------------------------
	-- Supplemental Tax Exemption
	----------------------------------------------------------------
	if l_dummy <= 1 then
		if l_dummy = 0 then
			p_yea_info.supp_tax_exem := 1000000;
		elsif l_dummy = 1 then
			p_yea_info.supp_tax_exem := 500000;
		end if;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.supp_tax_exem;
	end if;
	----------------------------------------------------------------
	-- Special Tax Exemption
	----------------------------------------------------------------
	l_cuml_special_exem := 0;  --Bug 4709683
	if p_yea_info.non_resident_flag = 'N' then
		--
		-- Insurance Premium Tax Exemption
		--
		if p_yea_info.hi_prem > 0 then
			p_yea_info.hi_prem_tax_exem := p_yea_info.hi_prem;
		end if;
		if p_yea_info.ei_prem > 0 then
			p_yea_info.ei_prem_tax_exem := p_yea_info.ei_prem;
		end if;
		if p_yea_info.pers_ins_prem > 0 then
			p_yea_info.pers_ins_prem_tax_exem := least(p_yea_info.pers_ins_prem, 700000);
		end if;
		if p_yea_info.disabled_ins_prem > 0 then
			p_yea_info.disabled_ins_prem_tax_exem := least(p_yea_info.disabled_ins_prem, 1000000);
		end if;
		p_yea_info.ins_prem_tax_exem := p_yea_info.hi_prem_tax_exem
					      + p_yea_info.ei_prem_tax_exem
					      + p_yea_info.pers_ins_prem_tax_exem
					      + p_yea_info.disabled_ins_prem_tax_exem;

		-- Bug 4119483: Apply upper limit based on cumulative special exemption
		p_yea_info.ins_prem_tax_exem := least(
							p_yea_info.ins_prem_tax_exem,
							greatest(
								0,
								p_yea_info.taxable_income2 - l_cuml_special_exem
							)
						) ;

		l_cuml_special_exem := l_cuml_special_exem + p_yea_info.ins_prem_tax_exem ;
		-- End of 4119483

		--
		-- Medical Expense Tax Exemption
		--
		l_dummy := p_yea_info.med_exp + p_yea_info.med_exp_disabled + p_yea_info.med_exp_aged;
		if l_dummy > 0 then
			l_dummy := l_dummy - trunc(greatest(p_yea_info.taxable, 0) * 0.03);
			if l_dummy > 0 then
				p_yea_info.max_med_exp_tax_exem := least(p_yea_info.med_exp_disabled + p_yea_info.med_exp_aged, l_dummy - 3000000);
				p_yea_info.med_exp_tax_exem := 3000000 + p_yea_info.max_med_exp_tax_exem;
			end if;
		end if;
		-- Bug 4119483: Apply upper limit based on cumulative special exemption
		p_yea_info.med_exp_tax_exem := least(
							p_yea_info.med_exp_tax_exem,
							greatest(
								0,
								p_yea_info.taxable_income2 - l_cuml_special_exem
							)
						) ;

		l_cuml_special_exem := l_cuml_special_exem + p_yea_info.med_exp_tax_exem ;
		-- End of 4119483
		--
		-- Education Expense Tax Exemption
		--
		p_yea_info.educ_exp_tax_exem := p_yea_info.ee_educ_exp;
		for i in 1..p_yea_info.dpnt_educ_contact_type_tbl.count loop
			if p_yea_info.dpnt_educ_school_type_tbl(i) = 'U' then
				l_dummy := 3000000;
			elsif p_yea_info.dpnt_educ_school_type_tbl(i) = 'H' then
				l_dummy := 1500000;
			elsif p_yea_info.dpnt_educ_school_type_tbl(i) = 'P' then
				l_dummy := 1000000;
			end if;
			p_yea_info.educ_exp_tax_exem := p_yea_info.educ_exp_tax_exem + least(p_yea_info.dpnt_educ_exp_tbl(i), l_dummy);
			if p_yea_info.dpnt_educ_contact_type_tbl(i) = 'S' then
				p_yea_info.spouse_educ_exp := p_yea_info.spouse_educ_exp + p_yea_info.dpnt_educ_exp_tbl(i);
			else
				p_yea_info.dpnt_educ_exp := p_yea_info.dpnt_educ_exp + p_yea_info.dpnt_educ_exp_tbl(i);
			end if;
		end loop;
		--
		-- Bug 4119483: Apply upper limit based on cumulative special exemption
		p_yea_info.educ_exp_tax_exem := least(
							p_yea_info.educ_exp_tax_exem,
							greatest(
								0,
								p_yea_info.taxable_income2 - l_cuml_special_exem
							)
						) ;
		--
		l_cuml_special_exem := l_cuml_special_exem + p_yea_info.educ_exp_tax_exem ;
		-- End of 4119483
		--
		-- Housing Expense Tax Exemption
		--
		if p_yea_info.housing_saving > 0
		or p_yea_info.housing_loan_repay > 0
		or p_yea_info.lt_housing_loan_interest_repay > 0 then
			p_yea_info.max_housing_exp_tax_exem := trunc((p_yea_info.housing_saving + p_yea_info.housing_loan_repay) * 0.4)
							     + p_yea_info.lt_housing_loan_interest_repay;
			p_yea_info.housing_exp_tax_exem := least(p_yea_info.max_housing_exp_tax_exem, 3000000);
			--
			-- Bug 4119483: Apply upper limit based on cumulative special exemption
			p_yea_info.housing_exp_tax_exem := least(
								p_yea_info.housing_exp_tax_exem,
								greatest(
									0,
									p_yea_info.taxable_income2 - l_cuml_special_exem
								)
							) ;
			--
			l_cuml_special_exem := l_cuml_special_exem + p_yea_info.housing_exp_tax_exem ;
			-- End of 4119483
		end if;
		--
		-- Donation Tax Exemption
		--
		p_yea_info.donation1_tax_exem := p_yea_info.donation1;
		if p_yea_info.political_donation1 > 0 then
			p_yea_info.donation1_tax_exem := p_yea_info.donation1_tax_exem + least(p_yea_info.political_donation1, 100000000);
		end if;
		if p_yea_info.political_donation2 > 0 then
			p_yea_info.donation1_tax_exem := p_yea_info.donation1_tax_exem + least(p_yea_info.political_donation2, 20000000);
		end if;
		if p_yea_info.political_donation3 > 0 then
			p_yea_info.donation1_tax_exem := p_yea_info.donation1_tax_exem + least(p_yea_info.political_donation3,
								greatest(trunc(greatest(p_yea_info.taxable, 0) * 0.03), 100000000));
		end if;
		if p_yea_info.donation2 > 0 then
			if p_yea_info.taxable > p_yea_info.donation1_tax_exem then
				p_yea_info.max_donation2_tax_exem := trunc((p_yea_info.taxable - p_yea_info.donation1_tax_exem) * 0.1);
				p_yea_info.donation2_tax_exem := least(p_yea_info.donation2, p_yea_info.max_donation2_tax_exem);
			end if;
		end if;
		p_yea_info.donation_tax_exem := p_yea_info.donation1_tax_exem + p_yea_info.donation2_tax_exem;
		--
		-- Bug 4119483: Apply upper limit based on cumulative special exemption
		p_yea_info.donation_tax_exem := least(
							p_yea_info.donation_tax_exem,
							greatest(
								0,
								p_yea_info.taxable_income2 - l_cuml_special_exem
							)
						) ;
		--
		l_cuml_special_exem := l_cuml_special_exem + p_yea_info.donation_tax_exem ;
		-- End of 4119483
		--
		--
		-- Special Tax Exemption
		--
		p_yea_info.sp_tax_exem := p_yea_info.ins_prem_tax_exem
					+ p_yea_info.med_exp_tax_exem
					+ p_yea_info.educ_exp_tax_exem
					+ p_yea_info.housing_exp_tax_exem
					+ p_yea_info.donation_tax_exem;
		if p_yea_info.sp_tax_exem < 600000 then
			p_yea_info.sp_tax_exem		:= 0;
			p_yea_info.std_sp_tax_exem	:= 600000;
		end if;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.sp_tax_exem - p_yea_info.std_sp_tax_exem;
	end if;
	----------------------------------------------------------------
	-- National Pension Premium Tax Exemption
	----------------------------------------------------------------
	if p_yea_info.np_prem > 0 then
		p_yea_info.np_prem_tax_exem := p_yea_info.np_prem;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.np_prem_tax_exem;
	end if;
	----------------------------------------------------------------
	-- Taxable Income2
	----------------------------------------------------------------
	p_yea_info.taxable_income2 := greatest(p_yea_info.taxable_income2, 0);
	p_yea_info.taxation_base := p_yea_info.taxable_income2;
	--
	if p_yea_info.non_resident_flag = 'N' then
		----------------------------------------------------------------
		-- Personal Pension Premium Tax Exemption
		----------------------------------------------------------------
		if p_yea_info.pers_pension_prem > 0 then
			p_yea_info.pers_pension_prem_tax_exem := least(trunc(p_yea_info.pers_pension_prem * 0.4), 720000);
			p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.pers_pension_prem_tax_exem;
		end if;
		----------------------------------------------------------------
		-- Personal Pension Saving Tax Exemption
		----------------------------------------------------------------
		if p_yea_info.pers_pension_saving > 0 then
			p_yea_info.pers_pension_saving_tax_exem := least(p_yea_info.pers_pension_saving, 2400000);
			p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.pers_pension_saving_tax_exem;
		end if;
		----------------------------------------------------------------
		-- Credit Card Expense Tax Exem
		----------------------------------------------------------------
		if p_yea_info.credit_card_exp > 0 then
			l_dummy := p_yea_info.credit_card_exp - trunc(greatest(p_yea_info.taxable, 0) * 0.1);
			if l_dummy > 0 then
				p_yea_info.credit_card_exp_tax_exem := least(trunc(l_dummy * 0.2), 5000000);
				p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.credit_card_exp_tax_exem;
			end if;
		end if;
		----------------------------------------------------------------
		-- Investment Partnership Financing Tax Exemption
		----------------------------------------------------------------
		if p_yea_info.invest_partner_fin1 > 0
		or p_yea_info.invest_partner_fin2 > 0 then
			if p_yea_info.taxable > 0 then
				p_yea_info.invest_partner_fin_tax_exem := least(trunc(p_yea_info.invest_partner_fin1 * 0.2) + trunc(p_yea_info.invest_partner_fin2 * 0.3),
										trunc((p_yea_info.taxable) * 0.7));
				/* Calculated Tax using Taxation Base without Investment Partnership Financing Tax Exemption */
				l_calc_tax_for_stax := calc_tax(p_yea_info.taxation_base);
				p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.invest_partner_fin_tax_exem;
			end if;
		end if;
	end if;
	----------------------------------------------------------------
	-- Taxation Base
	----------------------------------------------------------------
	p_yea_info.taxation_base := greatest(p_yea_info.taxation_base, 0);
	----------------------------------------------------------------
	-- Calculated Tax
	----------------------------------------------------------------
	p_yea_info.calc_tax := calc_tax(p_yea_info.taxation_base);
	----------------------------------------------------------------
	-- Basic Tax Break
	--   This tax break is based on "Estimated Calculated Tax
	--   based on Taxable Earnings without Special Irregular Bonus".
	----------------------------------------------------------------
	if p_yea_info.calc_tax > 0 and p_yea_info.taxable > 0 then
		l_dummy := trunc( p_yea_info.calc_tax
				* (p_yea_info.taxable - p_yea_info.sp_irreg_bonus)
				/ p_yea_info.taxable);
	else
		l_dummy := 0;
	end if;
	--
	if l_dummy > 0 then
		l_addend	:= to_number(hruserdt.get_table_value(
						p_bus_group_id		=> p_business_group_id,
						p_table_name		=> 'BASIC_TAX_BREAK',
						p_col_name		=> 'ADDEND',
						p_row_value		=> to_char(l_dummy),
						p_effective_date	=> p_effective_date));
		l_subtrahend	:= to_number(hruserdt.get_table_value(
						p_bus_group_id		=> p_business_group_id,
						p_table_name		=> 'BASIC_TAX_BREAK',
						p_col_name		=> 'SUBTRAHEND',
						p_row_value		=> to_char(l_dummy),
						p_effective_date	=> p_effective_date));
		l_multiplier	:= to_number(hruserdt.get_table_value(
						p_bus_group_id		=> p_business_group_id,
						p_table_name		=> 'BASIC_TAX_BREAK',
						p_col_name		=> 'MULTIPLIER',
						p_row_value		=> to_char(l_dummy),
						p_effective_date	=> p_effective_date));
		p_yea_info.basic_tax_break := least(trunc(l_addend + trunc((l_dummy - l_subtrahend) * l_multiplier / 100)), 400000);
		p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.basic_tax_break;
	end if;
	--
	if p_yea_info.non_resident_flag = 'N' then
		----------------------------------------------------------------
		-- Stock Saving Tax Break
		----------------------------------------------------------------
		if p_yea_info.stock_saving > 0 then
			p_yea_info.stock_saving_tax_break := trunc(p_yea_info.stock_saving * 0.05);
			p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.stock_saving_tax_break;
		end if;
		----------------------------------------------------------------
		-- Longterm Stock Saving1 Tax Break
		----------------------------------------------------------------
		if p_yea_info.lt_stock_saving1 > 0 then
			p_yea_info.lt_stock_saving_tax_break := trunc(p_yea_info.lt_stock_saving1 * 0.05);
			p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.lt_stock_saving_tax_break;
		end if;
		----------------------------------------------------------------
		-- Longterm Stock Saving2 Tax Break
		----------------------------------------------------------------
		if p_yea_info.lt_stock_saving2 > 0 then
			p_yea_info.lt_stock_saving_tax_break := p_yea_info.lt_stock_saving_tax_break + trunc(p_yea_info.lt_stock_saving2 * 0.07);
			p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.lt_stock_saving_tax_break;
		end if;
		----------------------------------------------------------------
		-- Housing Expense Tax Break
		----------------------------------------------------------------
		if p_yea_info.housing_loan_interest_repay > 0 then
			p_yea_info.housing_exp_tax_break := trunc(p_yea_info.housing_loan_interest_repay * 0.3);
			/* Need the actual housing loan interest tax break for special tax calculation */
			if p_yea_info.total_tax_break < p_yea_info.calc_tax then
				l_net_housing_exp_tax_break := least(p_yea_info.housing_exp_tax_break, p_yea_info.calc_tax - p_yea_info.total_tax_break);
			end if;
			p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.housing_exp_tax_break;
		end if;
	end if;
	----------------------------------------------------------------
	-- Overseas Tax Break
	----------------------------------------------------------------
	if p_yea_info.ovstb_tax_paid_date is not null then
		if p_yea_info.taxable_income > 0 then
			--
			-- Calculate Maximum Tax Break allowed in this calendar year.
			--
			l_dummy := trunc(p_yea_info.calc_tax
						* greatest((p_yea_info.ovstb_taxable - trunc(p_yea_info.ovstb_taxable_subj_tax_break * p_yea_info.ovstb_tax_break_rate / 100)), 0)
						/ p_yea_info.taxable
					);
			p_yea_info.ovs_tax_break := least(p_yea_info.ovstb_tax, l_dummy);
			p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.ovs_tax_break;
		end if;
	end if;
	----------------------------------------------------------------
	-- Foreign Worker Tax Break and set Annual Tax to "0"
	----------------------------------------------------------------
	if p_yea_info.fwtb_immigration_purpose is not null then
		p_yea_info.foreign_worker_tax_break := p_yea_info.calc_tax;
		p_yea_info.annual_itax := 0;
		p_yea_info.annual_rtax := 0;
		p_yea_info.annual_stax := 0;
		if p_yea_info.fwtb_immigration_purpose = 'G' then
			p_yea_info.foreign_worker_tax_break1 := p_yea_info.foreign_worker_tax_break;
		else
			p_yea_info.foreign_worker_tax_break2 := p_yea_info.foreign_worker_tax_break;
		end if;
	else
		----------------------------------------------------------------
		-- Annual Tax
		----------------------------------------------------------------
		p_yea_info.annual_itax := trunc(greatest(p_yea_info.calc_tax - p_yea_info.total_tax_break, 0), -1);
		p_yea_info.annual_rtax := trunc(p_yea_info.annual_itax * 0.1, -1);
		if l_calc_tax_for_stax > 0 then
			p_yea_info.annual_stax := trunc((l_calc_tax_for_stax - p_yea_info.calc_tax) * 0.2);
		end if;
		if l_net_housing_exp_tax_break > 0 then
			p_yea_info.annual_stax := p_yea_info.annual_stax + trunc(l_net_housing_exp_tax_break * 0.2);
		end if;
		p_yea_info.annual_stax := trunc(p_yea_info.annual_stax, -1);
	end if;
	----------------------------------------------------------------
	-- Calculate Tax Adjustment
	----------------------------------------------------------------
	p_yea_info.itax_adj := p_yea_info.annual_itax - p_yea_info.prev_itax - p_yea_info.cur_itax;
	p_yea_info.rtax_adj := p_yea_info.annual_rtax - p_yea_info.prev_rtax - p_yea_info.cur_rtax;
	p_yea_info.stax_adj := p_yea_info.annual_stax - p_yea_info.prev_stax - p_yea_info.cur_stax;

end yea;
--
end pay_kr_yea00010101_pkg;

/
