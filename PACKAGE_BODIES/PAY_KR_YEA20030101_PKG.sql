--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA20030101_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA20030101_PKG" as
/* $Header: pykryea2.pkb 120.3 2006/12/21 06:54:09 pdesu noship $ */
--
procedure yea(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_business_group_id	in number,
	p_yea_info		in out NOCOPY pay_kr_yea_pkg.t_yea_info,
        p_tax_adj_warning       out    NOCOPY boolean)
is
 -- Bug # :  2706312
cursor csr_ovs_def_bal_id
is
SELECT pdb.defined_balance_id
 FROM pay_balance_types        pbt,
      pay_defined_balances     pdb,
      pay_balance_dimensions   pbd
 WHERE pbt.balance_name    like 'Overseas Earnings'
   and pbt.legislation_code     = 'KR'
   and pbt.balance_type_id      = pdb.balance_type_id
   and pbd.balance_dimension_id = pdb.balance_dimension_id
   and pbd.database_item_suffix = '_ASG_YTD';

l_ovs_earnings_bal  number:=0;
l_ovs_def_bal_id    pay_defined_balances.defined_balance_id%TYPE;

	l_addend		       number;
	l_multiplier		       number;
	l_subtrahend		       number;
	l_dummy			       number;
	l_net_housing_exp_tax_break    number;
	l_calc_tax_for_stax	       number;
        --
        l_ee_tax_exem                  number default 0;
        l_dpnt_spouse_tax_exem         number default 0;
        l_dpnt_tax_exem                number default 0;
        l_aged_tax_exem                number default 0;
        l_disabled_tax_exem            number default 0;
        l_female_ee_tax_exem           number default 0;
        l_num_of_children              number default 0;
        l_supp_tax_exem_single         number default 0;
        l_supp_tax_exem_1_dpnt         number default 0;
        l_pers_ins_prem_tax_exem       number default 0;
        l_disabled_ins_prem_tax_exem   number default 0;
        l_med_exp_tax_exem_per         number default 0;
        l_med_exp_tax_exem_lim         number default 0;
        l_dpnt_educ_school_type_U      number default 0;
        l_dpnt_educ_school_type_H      number default 0;
        l_dpnt_educ_school_type_P      number default 0;
        l_dpnt_educ_school_type_D      number default 0;
        l_housinexp_tax_exem_per       number default 0;
        l_housinsavintype_HST1         number default 0;
        l_housinsavintype_HST2         number default 0;
        l_housinsavintype_HST3         number default 0;
        l_housinsavintype_HST4         number default 0;
        l_housinexp_tax_exem_lim       number default 0;
        l_housinexp_tax_exem_lim1      number default 0;
        l_political_donation1_lim      number default 0;
        l_political_donation2_lim      number default 0;
        l_political_donation3_lim      number default 0;
        l_political_donation3_per      number default 0;
        l_donation2_tax_exem_per       number default 0;
        l_donation3_tax_exem_per       number default 0;
        l_std_sp_tax_exem              number default 0;
        l_pers_pen_prem_tax_exem_per   number default 0;
        l_pers_pen_prem_tax_exem_lim   number default 0;
        l_pers_pen_savintax_exem_lim   number default 0;
        l_emp_stock_own_plan_exem_lim  number default 0;
        l_cre_card_exp_tax_exem_per1   number default 0;
        l_cre_card_exp_tax_exem_per2   number default 0;
	l_dir_card_exp_tax_exem_per    number default 0;
        l_cre_card_exp_tax_exem_lim    number default 0;
        l_inv_part_fin1_tax_exem_per   number default 0;
        l_inv_part_fin2_tax_exem_per   number default 0;
        l_inv_part_fin1_tax_exem_lim   number default 0;
        l_inv_part_fin2_tax_exem_lim   number default 0;
        l_basic_tax_break              number default 0;
        l_stock_savintax_break_per     number default 0;
        l_lt_stk_sav1_tax_break_per    number default 0;
        l_lt_stk_sav2_tax_break_per    number default 0;
        l_housinloan_int_repay_per     number default 0;
        l_annual_itax_per              number default 0;
        l_annual_stax_per              number default 0;
        l_housinexp_tax_break          number default 0;
	l_cuml_special_exem 	       number default 0 ; -- Adds up all special exemptions given for tracking purpose, for limit on exemptions.
        ------------------------------------------------
        -- Bug 3174643
        ------------------------------------------------
        l_available_tax_break          number default 0;
        ------------------------------------------------
        -- Bug 3201332
        ------------------------------------------------
        l_fw_tax_exem_per              number default 0;

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
        --
        function get_globalvalue(p_glbvar in varchar2,p_process_date in date) return number
        is
          --
          cursor csr_ff_global
          is
          select to_number(glb.global_value,'99999999999999999999.99999') -- Bug 5726158
          from   ff_globals_f glb
          where glb.global_name = p_glbvar
          and   p_process_date between glb.effective_start_date and glb.effective_end_date;
          --
          l_glbvalue number default 0;
        begin
          Open csr_ff_global;
          fetch csr_ff_global into l_glbvalue;
          close csr_ff_global;
          --
          if l_glbvalue is null then
             l_glbvalue := 0;
          end if;
          --
          return l_glbvalue;
        end;
        --

begin

        ----------------------------------------------------------------------------+
        -- Populating Local variables with Global values
        --
        ----------------------------------------------------------------------------+
             l_ee_tax_exem                 := get_globalvalue('KR_YEA_EE_TAX_EXEM',p_effective_date);
             l_dpnt_spouse_tax_exem        := get_globalvalue('KR_YEA_DPNT_SPOUSE_TAX_EXEM',p_effective_date);
             l_dpnt_tax_exem               := get_globalvalue('KR_YEA_DPNT_TAX_EXEM',p_effective_date);
             l_aged_tax_exem               := get_globalvalue('KR_YEA_AGED_TAX_EXEM',p_effective_date);
             l_disabled_tax_exem           := get_globalvalue('KR_YEA_DISABLED_TAX_EXEM',p_effective_date);
             l_female_ee_tax_exem          := get_globalvalue('KR_YEA_FEMALE_EE_TAX_EXEM',p_effective_date);
             l_num_of_children             := get_globalvalue('KR_YEA_NUM_OF_CHILDREN',p_effective_date);
             l_supp_tax_exem_single        := get_globalvalue('KR_YEA_SUPP_TAX_EXEM_SINGLE',p_effective_date);
             l_supp_tax_exem_1_dpnt        := get_globalvalue('KR_YEA_SUPP_TAX_EXEM_1_DPNT',p_effective_date);
             l_pers_ins_prem_tax_exem      := get_globalvalue('KR_YEA_PERS_INS_PREM_TAX_EXEM',p_effective_date);
             l_disabled_ins_prem_tax_exem  := get_globalvalue('KR_YEA_DISABLED_INS_PREM_TAX_EXEM',p_effective_date);
             l_med_exp_tax_exem_per        := get_globalvalue('KR_YEA_MED_EXP_TAX_EXEM_PER',p_effective_date);
             l_med_exp_tax_exem_lim        := get_globalvalue('KR_YEA_MED_EXP_TAX_EXEM_LIM',p_effective_date);
             l_dpnt_educ_school_type_U     := get_globalvalue('KR_YEA_DPNT_EDUC_SCHOOL_TYPE_U',p_effective_date);
             l_dpnt_educ_school_type_H     := get_globalvalue('KR_YEA_DPNT_EDUC_SCHOOL_TYPE_H',p_effective_date);
             l_dpnt_educ_school_type_P     := get_globalvalue('KR_YEA_DPNT_EDUC_SCHOOL_TYPE_P',p_effective_date);
             l_dpnt_educ_school_type_D     := get_globalvalue('KR_YEA_DPNT_EDUC_SCHOOL_TYPE_D',p_effective_date);
             l_housinexp_tax_exem_per      := get_globalvalue('KR_YEA_HOUSINEXP_TAX_EXEM_PER',p_effective_date);
             l_housinsavintype_HST1        := get_globalvalue('KR_YEA_HOUSINSAVINTYPE_HST1',p_effective_date);
             l_housinsavintype_HST2        := get_globalvalue('KR_YEA_HOUSINSAVINTYPE_HST2',p_effective_date);
             l_housinsavintype_HST3        := get_globalvalue('KR_YEA_HOUSINSAVINTYPE_HST3',p_effective_date);
             l_housinsavintype_HST4        := get_globalvalue('KR_YEA_HOUSINSAVINTYPE_HST4',p_effective_date);
             l_housinexp_tax_exem_lim      := get_globalvalue('KR_YEA_HOUSINEXP_TAX_EXEM_LIM',p_effective_date);
             l_housinexp_tax_exem_lim1     := get_globalvalue('KR_YEA_HOUSINEXP_TAX_EXEM_LIM1',p_effective_date);
             l_political_donation1_lim     := get_globalvalue('KR_YEA_POLITICAL_DONATION1_LIM',p_effective_date);
             l_political_donation2_lim     := get_globalvalue('KR_YEA_POLITICAL_DONATION2_LIM',p_effective_date);
             l_political_donation3_lim     := get_globalvalue('KR_YEA_POLITICAL_DONATION3_LIM',p_effective_date);
             l_political_donation3_per     := get_globalvalue('KR_YEA_POLITICAL_DONATION3_PER',p_effective_date);
             l_donation2_tax_exem_per      := get_globalvalue('KR_YEA_DONATION2_TAX_EXEM_PER',p_effective_date);
             l_donation3_tax_exem_per      := get_globalvalue('KR_YEA_DONATION3_TAX_EXEM_PER',p_effective_date);
             l_std_sp_tax_exem             := get_globalvalue('KR_YEA_STD_SP_TAX_EXEM',p_effective_date);
             l_pers_pen_prem_tax_exem_per  := get_globalvalue('KR_YEA_PERS_PENSION_PREM_TAX_EXEM_PER',p_effective_date);
             l_pers_pen_prem_tax_exem_lim  := get_globalvalue('KR_YEA_PERS_PENSION_PREM_TAX_EXEM_LIM',p_effective_date);
             l_pers_pen_savintax_exem_lim  := get_globalvalue('KR_YEA_PERS_PENSION_SAVINTAX_EXEM_LIM',p_effective_date);
             l_emp_stock_own_plan_exem_lim := get_globalvalue('KR_YEA_EMP_STOCK_OWN_PLAN_EXEM_LIM',p_effective_date);
             l_cre_card_exp_tax_exem_per1  := get_globalvalue('KR_YEA_CREDIT_CARD_EXP_TAX_EXEM_PER1',p_effective_date);
             l_cre_card_exp_tax_exem_per2  := get_globalvalue('KR_YEA_CREDIT_CARD_EXP_TAX_EXEM_PER2',p_effective_date);
	     l_dir_card_exp_tax_exem_per   := get_globalvalue('KR_YEA_DIRECT_CARD_EXP_TAX_EXEM_PER',p_effective_date);
             l_cre_card_exp_tax_exem_lim   := get_globalvalue('KR_YEA_CREDIT_CARD_EXP_TAX_EXEM_LIM',p_effective_date);
             l_inv_part_fin1_tax_exem_per  := get_globalvalue('KR_YEA_INVEST_PARTNER_FIN1_TAX_EXEM_PER',p_effective_date);
             l_inv_part_fin2_tax_exem_per  := get_globalvalue('KR_YEA_INVEST_PARTNER_FIN2_TAX_EXEM_PER',p_effective_date);
             l_inv_part_fin1_tax_exem_lim  := get_globalvalue('KR_YEA_INVEST_PARTNER_FIN1_TAX_EXEM_LIM',p_effective_date);
             l_inv_part_fin2_tax_exem_lim  := get_globalvalue('KR_YEA_INVEST_PARTNER_FIN2_TAX_EXEM_LIM',p_effective_date);
             l_basic_tax_break             := get_globalvalue('KR_YEA_BASIC_TAX_BREAK',p_effective_date);
             l_stock_savintax_break_per    := get_globalvalue('KR_YEA_STOCK_SAVINTAX_BREAK_PER',p_effective_date);
             l_lt_stk_sav1_tax_break_per   := get_globalvalue('KR_YEA_LT_STOCK_SAVING1_TAX_BREAK_PER',p_effective_date);
             l_lt_stk_sav2_tax_break_per   := get_globalvalue('KR_YEA_LT_STOCK_SAVING2_TAX_BREAK_PER',p_effective_date);
             l_housinloan_int_repay_per    := get_globalvalue('KR_YEA_HOUSINLOAN_INTEREST_REPAY_PER',p_effective_date);
             l_annual_itax_per             := get_globalvalue('KR_YEA_ANNUAL_ITAX_PER',p_effective_date);
             l_annual_stax_per             := get_globalvalue('KR_YEA_ANNUAL_STAX_PER',p_effective_date);
             l_housinexp_tax_break         := get_globalvalue('KR_YEA_HOUSINEXP_TAX_BREAK',p_effective_date);
             -- Bug 3201332
             l_fw_tax_exem_per             := get_globalvalue('KR_YEA_FW_TAX_EXEM_PER',p_effective_date);
             -- Bug 2878937
             p_tax_adj_warning             := false;
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
	p_yea_info.ee_tax_exem := l_ee_tax_exem;
	p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.ee_tax_exem;
	----------------------------------------------------------------
	-- Dependent Tax Exemption
	----------------------------------------------------------------
	if p_yea_info.dpnt_spouse_flag = 'Y' then
		p_yea_info.dpnt_spouse_tax_exem := l_dpnt_spouse_tax_exem;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.dpnt_spouse_tax_exem;
		l_dummy := 1;
	else
		l_dummy := 0;
	end if;
	if p_yea_info.num_of_dpnts > 0 then
		p_yea_info.dpnt_tax_exem := p_yea_info.num_of_dpnts * l_dpnt_tax_exem;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.dpnt_tax_exem;
		l_dummy := l_dummy + p_yea_info.num_of_dpnts;
	end if;
	if p_yea_info.num_of_ageds > 0 then
		p_yea_info.aged_tax_exem := p_yea_info.num_of_ageds * l_aged_tax_exem;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.aged_tax_exem;
	end if;
	if p_yea_info.num_of_disableds > 0 then
		p_yea_info.disabled_tax_exem := p_yea_info.num_of_disableds * l_disabled_tax_exem;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.disabled_tax_exem;
	end if;
	if p_yea_info.female_ee_flag = 'Y' then
		p_yea_info.female_ee_tax_exem := l_female_ee_tax_exem;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.female_ee_tax_exem;
	end if;
	if p_yea_info.num_of_children > 0 then
		p_yea_info.child_tax_exem := p_yea_info.num_of_children * l_num_of_children;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.child_tax_exem;
	end if;
	----------------------------------------------------------------
	-- Supplemental Tax Exemption
	----------------------------------------------------------------
	if l_dummy <= 1 then
		if l_dummy = 0 then
			p_yea_info.supp_tax_exem := l_supp_tax_exem_single;
		elsif l_dummy = 1 then
			p_yea_info.supp_tax_exem := l_supp_tax_exem_1_dpnt;
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
			p_yea_info.pers_ins_prem_tax_exem := least(p_yea_info.pers_ins_prem, l_pers_ins_prem_tax_exem );
		end if;
		if p_yea_info.disabled_ins_prem > 0 then
			p_yea_info.disabled_ins_prem_tax_exem := least(p_yea_info.disabled_ins_prem, l_disabled_ins_prem_tax_exem);
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

	        ----------------------------------------------------------------
		-- Medical Expense Tax Exemption
		-- Tax Exemption Calculation Modified for Bug No 2508354
         	----------------------------------------------------------------
		l_dummy := p_yea_info.med_exp + p_yea_info.med_exp_disabled + p_yea_info.med_exp_aged;
		if l_dummy > 0 then
			l_dummy := l_dummy - trunc(greatest(p_yea_info.taxable, 0) * l_med_exp_tax_exem_per);
			if l_dummy > 0 then
                             if l_dummy < l_med_exp_tax_exem_lim  then
                                   p_yea_info.med_exp_tax_exem := l_dummy;
                             elsif (l_dummy >= l_med_exp_tax_exem_lim ) and ((p_yea_info.med_exp_disabled + p_yea_info.med_exp_aged)=0) then
                                   p_yea_info.med_exp_tax_exem := l_med_exp_tax_exem_lim ;
                             else
				   p_yea_info.max_med_exp_tax_exem := least(p_yea_info.med_exp_disabled + p_yea_info.med_exp_aged, l_dummy - l_med_exp_tax_exem_lim);
				   p_yea_info.med_exp_tax_exem := l_med_exp_tax_exem_lim + p_yea_info.max_med_exp_tax_exem;
                             end if;
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

	        ----------------------------------------------------------------
                --  Bug 3201332 Education and Housing Exemptions are not applied for foreign employees
	        ----------------------------------------------------------------
	        if p_yea_info.nationality = 'K' then
			----------------------------------------------------------------
			-- Education Expense Tax Exemption
			-- Tax Exemption Calculation Modified for Bug No 2508354
			----------------------------------------------------------------
			p_yea_info.educ_exp_tax_exem := p_yea_info.ee_educ_exp;
			for i in 1..p_yea_info.dpnt_educ_contact_type_tbl.count loop
				if p_yea_info.dpnt_educ_school_type_tbl(i) = 'U' then
					l_dummy := l_dpnt_educ_school_type_U;
				elsif p_yea_info.dpnt_educ_school_type_tbl(i) = 'H' then
					l_dummy := l_dpnt_educ_school_type_H;
				elsif p_yea_info.dpnt_educ_school_type_tbl(i) = 'P' then
					l_dummy := l_dpnt_educ_school_type_P;
				elsif p_yea_info.dpnt_educ_school_type_tbl(i) = 'D' then
					l_dummy := l_dpnt_educ_school_type_D ;
				--
				-- Tax Exemption Calculation Modified for Bug No 2577751 (Calculated Education Expenses for disableds)
				--
					p_yea_info.disabled_educ_exp := p_yea_info.disabled_educ_exp + p_yea_info.dpnt_educ_exp_tbl(i);
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
		end if; ------------ nationality = 'K' ---------------
		----------------------------------------------------------------
		-- Housing Expense Tax Exemption
		-- Tax Exemption calculation modified for Bug No 2523481
		-- Tax Exemption calculation modified for Bug No 2879008
		----------------------------------------------------------------
		-- Bug 3199255. Reinitialized variable l_dummy
		----------------------------------------------------------------
		l_dummy := 0;
		for i in 1..p_yea_info.housing_saving_tbl.count loop
			l_dummy := l_dummy + p_yea_info.housing_saving_tbl(i);
		end loop;
		if l_dummy > 0
		   or p_yea_info.housing_loan_repay > 0
		   or p_yea_info.lt_housing_loan_interest_repay > 0 then
			for i in 1..p_yea_info.housing_saving_tbl.count loop
			       if i = 1 then
				     p_yea_info.housing_saving_type := p_yea_info.housing_saving_type_tbl(i);
			       end if;
			       if p_yea_info.housing_saving_type_tbl(i) = 'HST1' then
				     if p_yea_info.housing_saving_tbl(i) < l_housinsavintype_HST1 then
					    l_dummy := p_yea_info.housing_saving_tbl(i);
				     else
					    l_dummy := l_housinsavintype_HST1;
				     end if;
			       elsif p_yea_info.housing_saving_type_tbl(i) = 'HST2' then
				     if p_yea_info.housing_saving_tbl(i) < l_housinsavintype_HST2 then
					    l_dummy := p_yea_info.housing_saving_tbl(i);
				     else
					    l_dummy := l_housinsavintype_HST2;
				     end if;
			       elsif p_yea_info.housing_saving_type_tbl(i) = 'HST3' then
				     l_dummy := p_yea_info.housing_saving_tbl(i);
			       elsif p_yea_info.housing_saving_type_tbl(i) = 'HST4' then
				     l_dummy := p_yea_info.housing_saving_tbl(i);
			       end if;
			       --
			       p_yea_info.housing_saving := p_yea_info.housing_saving + l_dummy;
			       --
			end loop;
			--
			-- Condition added for fix 2879008
			--
			l_dummy := p_yea_info.housing_saving + p_yea_info.housing_loan_repay;
			if p_yea_info.lt_housing_loan_interest_repay = 0 then
				p_yea_info.max_housing_exp_tax_exem := trunc( l_dummy * l_housinexp_tax_exem_per );
				p_yea_info.housing_exp_tax_exem := least(p_yea_info.max_housing_exp_tax_exem, l_housinexp_tax_exem_lim);
			else
				-- Bug fix 3377122
   				p_yea_info.max_housing_exp_tax_exem := trunc(
										least(
											(l_dummy * l_housinexp_tax_exem_per),
											l_housinexp_tax_exem_lim
										)
									)
      							     		+ p_yea_info.lt_housing_loan_interest_repay;

   				p_yea_info.housing_exp_tax_exem     := least(
										p_yea_info.max_housing_exp_tax_exem,
										l_housinexp_tax_exem_lim1
									);
			end if;
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
	        ----------------------------------------------------------------
		-- Donation Tax Exemption
		-- MOdified for Bug 2581461
                -- Replaced every instance of p_yea_info.taxable with p_yea_info.taxable_income
	        ----------------------------------------------------------------
		p_yea_info.donation1_tax_exem := p_yea_info.donation1;
		if p_yea_info.political_donation1 > 0 then
			p_yea_info.donation1_tax_exem := p_yea_info.donation1_tax_exem + least(p_yea_info.political_donation1, l_political_donation1_lim);
		end if;
		if p_yea_info.political_donation2 > 0 then
			p_yea_info.donation1_tax_exem := p_yea_info.donation1_tax_exem + least(p_yea_info.political_donation2, l_political_donation2_lim);
		end if;
		if p_yea_info.political_donation3 > 0 then
			p_yea_info.donation1_tax_exem := p_yea_info.donation1_tax_exem + least(p_yea_info.political_donation3,
								greatest(trunc(greatest(p_yea_info.taxable_income, 0) * l_political_donation3_per), l_political_donation3_lim));
		end if;
		if p_yea_info.donation3 > 0 then
			if p_yea_info.taxable_income > p_yea_info.donation1_tax_exem then
				p_yea_info.max_donation3_tax_exem := trunc((p_yea_info.taxable_income - p_yea_info.donation1_tax_exem) * l_donation3_tax_exem_per);
				p_yea_info.donation3_tax_exem := least(p_yea_info.donation3, p_yea_info.max_donation3_tax_exem);
			end if;
		end if;
                if p_yea_info.donation2 > 0 then
                  if p_yea_info.taxable_income > ( p_yea_info.donation1_tax_exem + p_yea_info.donation3_tax_exem) then
				p_yea_info.max_donation2_tax_exem := trunc((p_yea_info.taxable_income - p_yea_info.donation1_tax_exem - p_yea_info.donation3_tax_exem ) * l_donation2_tax_exem_per);
				p_yea_info.donation2_tax_exem := least(p_yea_info.donation2, p_yea_info.max_donation2_tax_exem);
			end if;
		end if;
		p_yea_info.donation_tax_exem := p_yea_info.donation1_tax_exem + p_yea_info.donation2_tax_exem + p_yea_info.donation3_tax_exem;
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
	        ----------------------------------------------------------------
		-- Special Tax Exemption
	        ----------------------------------------------------------------
		p_yea_info.sp_tax_exem := p_yea_info.ins_prem_tax_exem
					+ p_yea_info.med_exp_tax_exem
					+ p_yea_info.educ_exp_tax_exem
					+ p_yea_info.housing_exp_tax_exem
					+ p_yea_info.donation_tax_exem;
		if p_yea_info.sp_tax_exem < l_std_sp_tax_exem then
			p_yea_info.sp_tax_exem		:= 0;
			p_yea_info.std_sp_tax_exem	:= l_std_sp_tax_exem;
		end if;
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.sp_tax_exem - p_yea_info.std_sp_tax_exem;
                ----------------------------------------------------------------
	        -- National Pension Premium Tax Exemption
	        -- Bug 2878936 : National Pension Exemption is given only to residents
	        ----------------------------------------------------------------
	        if p_yea_info.np_prem > 0 then
		        p_yea_info.np_prem_tax_exem := p_yea_info.np_prem;
		        p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.np_prem_tax_exem;
  	        end if;
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
			p_yea_info.pers_pension_prem_tax_exem := least(trunc(p_yea_info.pers_pension_prem * l_pers_pen_prem_tax_exem_per), l_pers_pen_prem_tax_exem_lim);
			p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.pers_pension_prem_tax_exem;
		end if;
		----------------------------------------------------------------
		-- Personal Pension Saving Tax Exemption
		----------------------------------------------------------------
		if p_yea_info.pers_pension_saving > 0 then
			p_yea_info.pers_pension_saving_tax_exem := least(p_yea_info.pers_pension_saving, l_pers_pen_savintax_exem_lim);
			p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.pers_pension_saving_tax_exem;
		end if;
		----------------------------------------------------------------
		-- Employee Stock Ownership Plan Contribution Tax Exemption
		----------------------------------------------------------------
		if p_yea_info.emp_stk_own_contri > 0 then
			p_yea_info.emp_stk_own_contri_tax_exem := least(p_yea_info.emp_stk_own_contri, l_emp_stock_own_plan_exem_lim);
			p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.emp_stk_own_contri_tax_exem;
		end if;

		----------------------------------------------------------------
		-- Credit Card Expense Tax Exem
		-- Introduced direct_card_exp for fix 2879008
		----------------------------------------------------------------
		p_yea_info.total_credit_card_exp := p_yea_info.credit_card_exp + p_yea_info.direct_card_exp;
		if p_yea_info.total_credit_card_exp > 0 then
		        l_dummy := p_yea_info.total_credit_card_exp - trunc(greatest(p_yea_info.taxable, 0) * l_cre_card_exp_tax_exem_per1);
			if l_dummy > 0 then
			        p_yea_info.credit_card_exp_tax_exem := trunc(l_dummy * ( p_yea_info.credit_card_exp / p_yea_info.total_credit_card_exp ));
  			        p_yea_info.direct_card_exp_tax_exem := trunc(l_dummy * ( p_yea_info.direct_card_exp / p_yea_info.total_credit_card_exp ));
				--
				l_dummy := trunc(p_yea_info.credit_card_exp_tax_exem * l_cre_card_exp_tax_exem_per2)
				           + trunc(p_yea_info.direct_card_exp_tax_exem * l_dir_card_exp_tax_exem_per);

				-- Bug 3089512 Consider the 20% of Taxable Earnings for Credit card exemption.
				p_yea_info.total_credit_card_exp_tax_exem := trunc(least(l_dummy ,(p_yea_info.taxable *l_cre_card_exp_tax_exem_per2), l_cre_card_exp_tax_exem_lim));
				p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.total_credit_card_exp_tax_exem;
				--
				-- Collect total credit card exemption into p_yea_info.credit_card_exp_tax_exem
				-- for keeping compatibility with package pay_kr_yea20020101_pkg
				-- These are used to display data in YEA result form and YEA reports
				--
                                p_yea_info.credit_card_exp_tax_exem := p_yea_info.total_credit_card_exp_tax_exem;
			end if;
			-- Collect total credit card expenses into p_yea_info.credit_card_exp
			-- This statement moved outside IF, for bug 3047370
			--
			p_yea_info.credit_card_exp := p_yea_info.total_credit_card_exp;
			--
		end if;
		----------------------------------------------------------------
		-- Investment Partnership Financing Tax Exemption
		-- MOdified for Bug 2581461
                -- Replaced every instance of p_yea_info.taxable with p_yea_info.taxable_income
                -- Modified for 2617486
                --
		----------------------------------------------------------------
		if p_yea_info.invest_partner_fin1 > 0
		or p_yea_info.invest_partner_fin2 > 0 then
			if p_yea_info.taxable_income > 0 then
				p_yea_info.invest_partner_fin_tax_exem := least(trunc(p_yea_info.invest_partner_fin1 * l_inv_part_fin1_tax_exem_per),
                                                                                trunc(p_yea_info.taxable_income * l_inv_part_fin1_tax_exem_lim));
				p_yea_info.invest_partner_fin_tax_exem := p_yea_info.invest_partner_fin_tax_exem +
                                                                          least(trunc(p_yea_info.invest_partner_fin2 * l_inv_part_fin2_tax_exem_per),
                                                                                trunc(p_yea_info.taxable_income * l_inv_part_fin2_tax_exem_lim));
				/* Calculated Tax using Taxation Base without Investment Partnership Financing Tax Exemption */
				l_calc_tax_for_stax := calc_tax(p_yea_info.taxation_base);
				p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.invest_partner_fin_tax_exem;
			end if;
		end if;
		--
		/* Bug 3201332 */
		if p_yea_info.nationality = 'F' then
			l_dummy := p_yea_info.fw_educ_expense + p_yea_info.fw_house_rent;
			if l_dummy > 0 then
				l_dummy := least( trunc(l_fw_tax_exem_per * (p_yea_info.monthly_reg_earning - l_dummy)), l_dummy);
				-- Bug 3352964
				if l_dummy > 0 then
					p_yea_info.emp_stk_own_contri_tax_exem := p_yea_info.emp_stk_own_contri_tax_exem + l_dummy;
					p_yea_info.taxation_base := p_yea_info.taxation_base - l_dummy;
				end if;
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
		l_dummy := trunc( p_yea_info.calc_tax);

/* Bug# 3402001 -  Removed deduction of sp_rreg_bonus  */

/*				 * (p_yea_info.taxable - p_yea_info.sp_irreg_bonus)
				/ p_yea_info.taxable); */
	else
		l_dummy := 0;
	end if;
	-- Bug 3174643
	l_available_tax_break := p_yea_info.calc_tax;
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
		p_yea_info.basic_tax_break := least(trunc(l_addend + trunc((l_dummy - l_subtrahend) * l_multiplier / 100)), l_basic_tax_break);
		--
		-- Bug 3174643
		--
		p_yea_info.basic_tax_break := least(p_yea_info.basic_tax_break, l_available_tax_break);
		l_available_tax_break      := l_available_tax_break - p_yea_info.basic_tax_break;
		--
		p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.basic_tax_break;
	end if;
	--
	if p_yea_info.non_resident_flag = 'N' then
		----------------------------------------------------------------
		-- Longterm Stock Saving1 and saving2 Tax Break
                -- Modified for Bug 2581461
                --
		----------------------------------------------------------------
		if p_yea_info.lt_stock_saving1 > 0
                or p_yea_info.lt_stock_saving2 > 0 then
			p_yea_info.lt_stock_saving_tax_break := trunc(p_yea_info.lt_stock_saving1 * l_lt_stk_sav1_tax_break_per);
			p_yea_info.lt_stock_saving_tax_break := p_yea_info.lt_stock_saving_tax_break + trunc(p_yea_info.lt_stock_saving2 * l_lt_stk_sav2_tax_break_per);
			--
			-- Bug 3174643
			--
			p_yea_info.lt_stock_saving_tax_break := least(p_yea_info.lt_stock_saving_tax_break, l_available_tax_break);
			l_available_tax_break                := l_available_tax_break - p_yea_info.lt_stock_saving_tax_break;
			--
			p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.lt_stock_saving_tax_break;
		end if;
		----------------------------------------------------------------
		-- Housing Expense Tax Break
		----------------------------------------------------------------
		if p_yea_info.housing_loan_interest_repay > 0 then
			p_yea_info.housing_exp_tax_break := trunc(p_yea_info.housing_loan_interest_repay * l_housinloan_int_repay_per);
			/* Need the actual housing loan interest tax break for special tax calculation */
			if p_yea_info.total_tax_break < p_yea_info.calc_tax then
				l_net_housing_exp_tax_break := least(p_yea_info.housing_exp_tax_break, p_yea_info.calc_tax - p_yea_info.total_tax_break);
			end if;
			--
			-- Bug 3174643
			--
			p_yea_info.housing_exp_tax_break := least(p_yea_info.housing_exp_tax_break, l_available_tax_break);
			l_available_tax_break            := l_available_tax_break - p_yea_info.housing_exp_tax_break;
			--
			p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.housing_exp_tax_break;
		end if;
	end if;
	----------------------------------------------------------------
	-- Overseas Tax Break
	----------------------------------------------------------------
	if p_yea_info.ovstb_tax_paid_date is not null then
		if p_yea_info.taxable_income > 0 then

                   -- Bug # 2706312

                   open  csr_ovs_def_bal_id;
                   fetch csr_ovs_def_bal_id into l_ovs_def_bal_id;

                   if csr_ovs_def_bal_id%found then

                      l_ovs_earnings_bal:= pay_balance_pkg.get_value
                                               (p_defined_balance_id   => l_ovs_def_bal_id
                                               ,p_assignment_id        => p_assignment_id
                                               ,p_virtual_date         => p_effective_date
                                               ,p_always_get_db_item   => FALSE);
                   end if;
                   close csr_ovs_def_bal_id;

                   p_yea_info.ovstb_taxable := p_yea_info.ovstb_taxable + l_ovs_earnings_bal;
                   --
                   -- Calculate Maximum Tax Break allowed in this calendar year.
                   --

                        l_dummy := trunc(p_yea_info.calc_tax * greatest((p_yea_info.ovstb_taxable  - trunc(p_yea_info.ovstb_taxable_subj_tax_break * p_yea_info.ovstb_tax_break_rate / 100)), 0) / p_yea_info.taxable);
			p_yea_info.ovs_tax_break := least(p_yea_info.ovstb_tax, l_dummy);
			--
			-- Bug 3174643
			--
			p_yea_info.ovs_tax_break := least(p_yea_info.ovs_tax_break, l_available_tax_break);
			l_available_tax_break    := l_available_tax_break - p_yea_info.ovs_tax_break;
			--
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
		-- Bug # 2767493
		if p_yea_info.total_tax_break > p_yea_info.calc_tax then
		       p_yea_info.total_tax_break := p_yea_info.calc_tax;
		end if;
		--
		p_yea_info.annual_itax := trunc(greatest(p_yea_info.calc_tax - p_yea_info.total_tax_break, 0),0);
		p_yea_info.annual_rtax := trunc(p_yea_info.annual_itax * l_annual_itax_per,0);
		if l_calc_tax_for_stax > 0 then
			p_yea_info.annual_stax := trunc((l_calc_tax_for_stax - p_yea_info.calc_tax) * l_annual_stax_per);
		end if;
		if l_net_housing_exp_tax_break > 0 then
			p_yea_info.annual_stax := p_yea_info.annual_stax + trunc(l_net_housing_exp_tax_break * l_housinexp_tax_break);
		end if;
		p_yea_info.annual_stax := trunc(p_yea_info.annual_stax,0);
	end if;
	----------------------------------------------------------------
	-- Calculate Tax Adjustment
        -- Bug 2605158 : truncating the last Won digit after the final
	-- calculation of annual_itax , annual_rtax and annual_stax.
	----------------------------------------------------------------
	p_yea_info.itax_adj := trunc(p_yea_info.annual_itax - p_yea_info.prev_itax - p_yea_info.cur_itax,-1);
	p_yea_info.rtax_adj := trunc(p_yea_info.annual_rtax - p_yea_info.prev_rtax - p_yea_info.cur_rtax,-1);
	p_yea_info.stax_adj := trunc(p_yea_info.annual_stax - p_yea_info.prev_stax - p_yea_info.cur_stax,-1);
        -- Bug 2878937
        if p_yea_info.itax_adj >= 0 and p_yea_info.itax_adj < 1000 then
             p_yea_info.itax_adj := 0;
             p_yea_info.rtax_adj := 0;
             p_yea_info.stax_adj := 0;
             p_tax_adj_warning   := TRUE;
        end if;
end yea;
--
end pay_kr_yea20030101_pkg;

/
