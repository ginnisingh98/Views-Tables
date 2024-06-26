--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA20080101_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA20080101_PKG" as
/* $Header: pykryea7.pkb 120.0.12010000.21 2009/02/11 05:38:57 pnethaga ship $ */
-- Constant
	-- Bug 3966549
	c_20040101 			constant date := fnd_date.canonical_to_date('2004/01/01') ;
	-- End of 3966549
--
-- Bug 3901912
	l_ee_tax_exem                 	number default 0;
        l_dpnt_spouse_tax_exem         	number default 0;
        l_dpnt_tax_exem                	number default 0;
        l_aged_tax_exem                	number default 0;
	-- Bug 3172960
        l_aged_tax_exem1               	number default 0;
	l_fw_fixed_tax_rate	       	number default 0;
	l_fw_income_exem_rate	       	number default 0;
	--
        l_disabled_tax_exem            	number default 0;
        l_female_ee_tax_exem           	number default 0;
        l_addl_child_tax_exem          	number default 0;   -- Bug 5734313
        l_addl_child_tax_exem1          number default 0;   -- Bug 5734313
        l_raising_child_tax_exem       	number default 0;   -- Bug 5756690
	l_new_born_adopted_tax_exem     number default 0;   -- Bug 6705170
        l_pers_ins_prem_tax_exem       	number default 0;
        l_disabled_ins_prem_tax_exem   	number default 0;
        l_med_exp_tax_exem_per         	number default 0;
        l_med_exp_tax_exem_lim         	number default 0;
	-- Bug 3966549
	l_total_med_exp			number default 0 ;
	-- End of 3966549
        l_dpnt_educ_school_type_U      	number default 0;
        l_dpnt_educ_school_type_H      	number default 0;
        l_dpnt_educ_school_type_P      	number default 0;
        l_dpnt_educ_school_type_D      	number default 0;
        l_housinexp_tax_exem_per       	number default 0;
        l_housinsavintype_HST1         	number default 0;
        l_housinsavintype_HST3         	number default 0;
        l_housinsavintype_HST4         	number default 0;
        l_housinexp_tax_exem_lim       	number default 0;
        l_housinexp_tax_exem_lim1      	number default 0;
        l_housinexp_tax_exem_lim2      	number default 0;
        l_political_donation1_lim      	number default 0;
        l_political_donation2_lim      	number default 0;
        l_political_donation3_lim      	number default 0;
        l_political_donation3_per      	number default 0;
        l_donation2_tax_exem_per       	number default 0;
        l_donation3_tax_exem_per       	number default 0;
	l_rel_don_tax_exem_per1		number default 0;  -- Bug 7142612
	l_rel_don_tax_exem_per2   	number default 0;  -- Bug 7142612
	-- Bug 3966549
	l_political_tax_brk_lim2004	number default 0 ;
	l_esoa_tax_exem_per2004		number default 0 ;
	-- End of 3966549
        l_marriage_exem_lim            	number default 0;
        l_funeral_exem_lim             	number default 0;
        l_relocation_exem_lim          	number default 0;
        l_std_sp_tax_exem              	number default 0;
        l_pers_pen_prem_tax_exem_per   	number default 0;
        l_pers_pen_prem_tax_exem_lim   	number default 0;
        l_pers_pen_savintax_exem_lim   	number default 0;
        l_corp_pen_prem_tax_exem_lim   	number default 0;  -- Bug : 4776711
        l_emp_stock_own_plan_exem_lim  	number default 0;
        l_cre_card_exp_tax_exem_per1   	number default 0;
        l_cre_card_exp_tax_exem_per2   	number default 0;
	l_dir_card_exp_tax_exem_per    	number default 0;
        l_cre_card_exp_tax_exem_lim    	number default 0;
	-- Bug 3966549
	l_cre_card_tax_exem_per2004	number default 0 ;
	-- End of 3966549
        l_inv_part_fin1_tax_exem_per   	number default 0;
        l_inv_part_fin2_tax_exem_per   	number default 0;
        l_inv_part_fin1_tax_exem_lim   	number default 0;
        l_inv_part_fin2_tax_exem_lim   	number default 0;
	l_small_bus_install_lim		number default 0; -- Bug 6895093
        l_basic_tax_break              	number default 0;
        l_stock_savintax_break_per     	number default 0;
        l_lt_stk_sav1_tax_break_per    	number default 0;
        l_lt_stk_sav2_tax_break_per    	number default 0;
        l_housinloan_int_repay_per     	number default 0;
        l_annual_itax_per              	number default 0;
        l_annual_stax_per              	number default 0;
        l_housinexp_tax_break          	number default 0;
	l_global_value_flag 		boolean default False;
	l_cuml_special_exem		number default 0 ; -- Adds up all special exemptions given for tracking purpose, for limit on exemptions.
	-- Bug 4119539
	l_fw_inc_exem_res		number default 0 ;
	l_fw_temp			number default 0 ;
	-- End of 4119539
        -- Bug 5083240
        l_fw_contr_taxable              number default 0 ; -- Foreign Worker taxable during contract; numerator for proration factor
        l_fw_contr_fw_inc_exem          number default 0 ; -- Foreign Worker Income Exemption on income during contract for foreign worker
        l_fw_contr_basic_exem           number default 0 ; -- Basic Exemption on taxable income during contract for foreign worker
        l_fw_brk_proration_factor       number default 0 ; -- Proration Factor (Taxable During Contract / Total Taxable)
        -- End of 5083240
        -- Bug 5682450
        l_pol_don_exem_rate_factor      number default 1; -- This factor reflects the change in calculation of tax exemption based on political donation.
        -- End of 5682450
        l_card_exp_not_exempted         number default 0 ; -- Bug 6630135
        l_double_exem_amt               number default 0 ; -- Bug 6630135
	l_type_B_tax_group_pct		number default 0 ; -- Bug 7361372
	l_long_term_stck_fund_1yr_lim number default 0 ; -- Bug 7615517
	l_long_term_stck_fund_2yr_lim number default 0 ; -- Bug 7615517
	l_long_term_stck_fund_3yr_lim number default 0 ; -- Bug 7615517
	l_long_term_stck_fund_1yr_pct number default 0 ; -- Bug 7615517
	l_long_term_stck_fund_2yr_pct number default 0 ; -- Bug 7615517
	l_long_term_stck_fund_3yr_pct number default 0 ; -- Bug 7615517
--
procedure yea(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_business_group_id	in number,
	p_yea_info		in out NOCOPY pay_kr_yea_pkg.t_yea_info,
        p_tax_adj_warning       out    NOCOPY boolean)
is
-- Bug No 3901912
	cursor csr_ovs_def_bal_id
	is
	SELECT pdb.defined_balance_id
	 FROM pay_balance_types        pbt,
	      pay_defined_balances     pdb,
	      pay_balance_dimensions   pbd
	 WHERE pbt.balance_name    like 'Overseas Earnings'
	   and pbt.legislation_code     = 'KR'
           and pbd.legislation_code     = 'KR'
           and pdb.legislation_code     = 'KR'
	   and pbt.balance_type_id      = pdb.balance_type_id
	   and pbd.balance_dimension_id = pdb.balance_dimension_id
	   and pbd.database_item_suffix = '_ASG_YTD';
--
	l_ovs_earnings_bal  number:=0;
	l_ovs_def_bal_id    pay_defined_balances.defined_balance_id%TYPE;

	l_addend		       number;
	l_multiplier		       number;
	l_subtrahend		       number;
	l_dummy			       number;
	l_net_housing_exp_tax_break    number;
	l_calc_tax_for_stax	       number;
        --
        --  Bug No 3901912 moved variables to package initialisation section

        l_available_tax_break          number default 0;
	l_ameeg_med_exem	       number default 0;

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
        ----------------------------------------------------------------------------+
	-- Bug no 3901912
	if l_global_value_flag <> TRUE then
		l_ee_tax_exem                 	:= get_globalvalue('KR_YEA_EE_TAX_EXEM',p_effective_date);
		l_dpnt_spouse_tax_exem        	:= get_globalvalue('KR_YEA_DPNT_SPOUSE_TAX_EXEM',p_effective_date);
		l_dpnt_tax_exem               	:= get_globalvalue('KR_YEA_DPNT_TAX_EXEM',p_effective_date);
		l_aged_tax_exem               	:= get_globalvalue('KR_YEA_AGED_TAX_EXEM',p_effective_date);
		-- Bug 3172960
		l_aged_tax_exem1              	:= get_globalvalue('KR_YEA_AGED_TAX_EXEM1',p_effective_date);
		--
		l_disabled_tax_exem           	:= get_globalvalue('KR_YEA_DISABLED_TAX_EXEM',p_effective_date);
		l_female_ee_tax_exem          	:= get_globalvalue('KR_YEA_FEMALE_EE_TAX_EXEM',p_effective_date);
		l_addl_child_tax_exem           := get_globalvalue('CHILD_TAX_EXEM',p_effective_date);             -- Bug 5734313
                l_addl_child_tax_exem1          := get_globalvalue('CHILD_TAX_EXEM1',p_effective_date);            -- Bug 5734313
                l_raising_child_tax_exem        := get_globalvalue('KR_YEA_NUM_OF_CHILDREN',p_effective_date);             -- Bug 5756690
		-- Bug 6705170
		l_new_born_adopted_tax_exem     := get_globalvalue('NEW_BORN_ADOPTED_CHILD_TAX_EXEM',p_effective_date);
		--
		l_pers_ins_prem_tax_exem      	:= get_globalvalue('KR_YEA_PERS_INS_PREM_TAX_EXEM',p_effective_date);
		l_disabled_ins_prem_tax_exem  	:= get_globalvalue('KR_YEA_DISABLED_INS_PREM_TAX_EXEM',p_effective_date);
		l_med_exp_tax_exem_per        	:= get_globalvalue('KR_YEA_MED_EXP_TAX_EXEM_PER',p_effective_date);
		l_med_exp_tax_exem_lim        	:= get_globalvalue('KR_YEA_MED_EXP_TAX_EXEM_LIM',p_effective_date);
		l_dpnt_educ_school_type_U     	:= get_globalvalue('KR_YEA_DPNT_EDUC_SCHOOL_TYPE_U',p_effective_date);
		l_dpnt_educ_school_type_H     	:= get_globalvalue('KR_YEA_DPNT_EDUC_SCHOOL_TYPE_H',p_effective_date);
		l_dpnt_educ_school_type_P     	:= get_globalvalue('KR_YEA_DPNT_EDUC_SCHOOL_TYPE_P',p_effective_date);
		l_dpnt_educ_school_type_D     	:= get_globalvalue('KR_YEA_DPNT_EDUC_SCHOOL_TYPE_D',p_effective_date);
		l_housinexp_tax_exem_per      	:= get_globalvalue('KR_YEA_HOUSINEXP_TAX_EXEM_PER',p_effective_date);
		l_housinsavintype_HST1        	:= get_globalvalue('KR_YEA_HOUSINSAVINTYPE_HST1',p_effective_date);
		-- Bug 5731165
		-- Removed code for HST2
		l_housinsavintype_HST3        	:= get_globalvalue('KR_YEA_HOUSINSAVINTYPE_HST3',p_effective_date);
		l_housinsavintype_HST4        	:= get_globalvalue('KR_YEA_HOUSINSAVINTYPE_HST4',p_effective_date);
		l_housinexp_tax_exem_lim      	:= get_globalvalue('KR_YEA_HOUSINEXP_TAX_EXEM_LIM',p_effective_date);
		l_housinexp_tax_exem_lim1     	:= get_globalvalue('KR_YEA_HOUSINEXP_TAX_EXEM_LIM1',p_effective_date);
		l_housinexp_tax_exem_lim2     	:= get_globalvalue('KR_YEA_HOUSINEXP_TAX_EXEM_LIM2',p_effective_date);
		l_political_donation1_lim     	:= get_globalvalue('KR_YEA_POLITICAL_DONATION1_LIM',p_effective_date);
		l_political_donation2_lim     	:= get_globalvalue('KR_YEA_POLITICAL_DONATION2_LIM',p_effective_date);
		l_political_donation3_lim     	:= get_globalvalue('KR_YEA_POLITICAL_DONATION3_LIM',p_effective_date);
		l_political_donation3_per     	:= get_globalvalue('KR_YEA_POLITICAL_DONATION3_PER',p_effective_date);
		l_donation2_tax_exem_per      	:= get_globalvalue('KR_YEA_DONATION2_TAX_EXEM_PER',p_effective_date);
		-- Bug 7142612
		l_rel_don_tax_exem_per1		:= get_globalvalue('KR_YEA_RELIGIOUS_DONATION_TAX_EXEM_PER1',p_effective_date);
		l_rel_don_tax_exem_per2		:= get_globalvalue('KR_YEA_RELIGIOUS_DONATION_TAX_EXEM_PER2',p_effective_date);
		-- End of Bug 7142612
		l_donation3_tax_exem_per      	:= get_globalvalue('KR_YEA_DONATION3_TAX_EXEM_PER',p_effective_date);
		-- Bug 3966549
		l_political_tax_brk_lim2004	:= get_globalvalue('KR_YEA_POLITICAL_DONATION_TAX_BREAK_LIM', p_effective_date) ;
		l_esoa_tax_exem_per2004		:= get_globalvalue('KR_YEA_ESOA_DONATION_TAX_EXEM_PER', p_effective_date) ;
		-- End of 3966549

		l_marriage_exem_lim           	:= get_globalvalue('KR_YEA_MARRIAGE_EXEM_LIM',p_effective_date);
		l_funeral_exem_lim            	:= get_globalvalue('KR_YEA_FUNERAL_EXEM_LIM',p_effective_date);
		l_relocation_exem_lim         	:= get_globalvalue('KR_YEA_RELOCATION_EXEM_LIM',p_effective_date);
		l_std_sp_tax_exem             	:= get_globalvalue('KR_YEA_STD_SP_TAX_EXEM',p_effective_date);
		l_pers_pen_prem_tax_exem_per  	:= get_globalvalue('KR_YEA_PERS_PENSION_PREM_TAX_EXEM_PER',p_effective_date);
		l_pers_pen_prem_tax_exem_lim  	:= get_globalvalue('KR_YEA_PERS_PENSION_PREM_TAX_EXEM_LIM',p_effective_date);
		-- Bug : 4776711
		l_corp_pen_prem_tax_exem_lim  	:= get_globalvalue('KR_YEA_CORP_PENSION_PREM_TAX_EXEM_LIM',p_effective_date);
		-- End of Bug 4776711
		l_pers_pen_savintax_exem_lim  	:= get_globalvalue('KR_YEA_PERS_PENSION_SAVINTAX_EXEM_LIM',p_effective_date);
		l_emp_stock_own_plan_exem_lim 	:= get_globalvalue('KR_YEA_EMP_STOCK_OWN_PLAN_EXEM_LIM',p_effective_date);
		l_cre_card_exp_tax_exem_per1  	:= get_globalvalue('KR_YEA_CREDIT_CARD_EXP_TAX_EXEM_PER1',p_effective_date);
		l_cre_card_exp_tax_exem_per2  	:= get_globalvalue('KR_YEA_CREDIT_CARD_EXP_TAX_EXEM_PER2',p_effective_date);
		l_dir_card_exp_tax_exem_per   	:= get_globalvalue('KR_YEA_DIRECT_CARD_EXP_TAX_EXEM_PER',p_effective_date);
		l_cre_card_exp_tax_exem_lim   	:= get_globalvalue('KR_YEA_CREDIT_CARD_EXP_TAX_EXEM_LIM',p_effective_date);
		-- Bug 3966549
		l_cre_card_tax_exem_per2004	:= get_globalvalue('KR_YEA_CREDIT_CARD_EXP_2004_TAX_EXEM_PER',p_effective_date);
		-- End of 3966549
		l_inv_part_fin1_tax_exem_per  	:= get_globalvalue('KR_YEA_INVEST_PARTNER_FIN1_TAX_EXEM_PER',p_effective_date);
		l_inv_part_fin2_tax_exem_per  	:= get_globalvalue('KR_YEA_INVEST_PARTNER_FIN2_TAX_EXEM_PER',p_effective_date);
		l_inv_part_fin1_tax_exem_lim  	:= get_globalvalue('KR_YEA_INVEST_PARTNER_FIN1_TAX_EXEM_LIM',p_effective_date);
		l_inv_part_fin2_tax_exem_lim  	:= get_globalvalue('KR_YEA_INVEST_PARTNER_FIN2_TAX_EXEM_LIM',p_effective_date);
		-- Bug 6895093
		l_small_bus_install_lim		:= get_globalvalue('KR_YEA_SMALL_BUS_INSTALL_LIM',p_effective_date);
		-- End of Bug 6895093
		l_basic_tax_break             	:= get_globalvalue('KR_YEA_BASIC_TAX_BREAK',p_effective_date);
		l_stock_savintax_break_per    	:= get_globalvalue('KR_YEA_STOCK_SAVINTAX_BREAK_PER',p_effective_date);
		l_lt_stk_sav1_tax_break_per   	:= get_globalvalue('KR_YEA_LT_STOCK_SAVING1_TAX_BREAK_PER',p_effective_date);
		l_lt_stk_sav2_tax_break_per   	:= get_globalvalue('KR_YEA_LT_STOCK_SAVING2_TAX_BREAK_PER',p_effective_date);
		l_housinloan_int_repay_per    	:= get_globalvalue('KR_YEA_HOUSINLOAN_INTEREST_REPAY_PER',p_effective_date);
		l_annual_itax_per             	:= get_globalvalue('KR_YEA_ANNUAL_ITAX_PER',p_effective_date);
		l_annual_stax_per             	:= get_globalvalue('KR_YEA_ANNUAL_STAX_PER',p_effective_date);
		l_housinexp_tax_break         	:= get_globalvalue('KR_YEA_HOUSINEXP_TAX_BREAK',p_effective_date);
		-- Bug 3172960
		l_fw_income_exem_rate         	:= get_globalvalue('KR_FOREIGN_WORKER_INCOME_EXEM_RATE',p_effective_date);
		l_fw_fixed_tax_rate           	:= get_globalvalue('KR_FOREIGN_WORKER_FIXED_TAX_RATE',p_effective_date);
		--
		-- Bug 7361372
		l_type_B_tax_group_pct		:= get_globalvalue('KR_YEA_TYPE_B_TAX_GROUP_PCT',p_effective_date);
		--
		-- Bug 7615517
		l_long_term_stck_fund_1yr_lim := get_globalvalue('KR_YEA_LONG_TERM_STCK_FUND_1YEAR_LIM',p_effective_date);
		l_long_term_stck_fund_2yr_lim := get_globalvalue('KR_YEA_LONG_TERM_STCK_FUND_2YEAR_LIM',p_effective_date);
		l_long_term_stck_fund_3yr_lim := get_globalvalue('KR_YEA_LONG_TERM_STCK_FUND_3YEAR_LIM',p_effective_date);
		l_long_term_stck_fund_1yr_pct := get_globalvalue('KR_YEA_LONG_TERM_STCK_FUND_1YEAR_PCT',p_effective_date);
		l_long_term_stck_fund_2yr_pct := get_globalvalue('KR_YEA_LONG_TERM_STCK_FUND_2YEAR_PCT',p_effective_date);
		l_long_term_stck_fund_3yr_pct := get_globalvalue('KR_YEA_LONG_TERM_STCK_FUND_3YEAR_PCT',p_effective_date);
		-- End of Bug 7615517
		-- Bug 5682450
		l_pol_don_exem_rate_factor      := get_globalvalue ('KR_YEA_POLITICAL_DONATION_EXEM_FAC', p_effective_date);
		-- End of 5682450
		l_global_value_flag           	:= TRUE;
	End if;
	l_card_exp_not_exempted := 0 ; -- Bug 6763554
	--
	p_tax_adj_warning             := false;
	-- Bug 3172960
	if (p_yea_info.nationality = 'F' and p_yea_info.fixed_tax_rate = 'Y') then
		--
		p_yea_info.taxable            := p_yea_info.taxable + p_yea_info.non_taxable;
                p_yea_info.taxable_income     := p_yea_info.taxable;
                p_yea_info.taxable_income2    := p_yea_info.taxable;
		p_yea_info.taxation_base      := p_yea_info.taxable;
		--
		p_yea_info.calc_tax := greatest(trunc(p_yea_info.taxation_base * l_fw_fixed_tax_rate),0);
		--
		p_yea_info.num_of_dpnts := 0;
		p_yea_info.num_of_ageds := 0;
		p_yea_info.num_of_super_ageds := 0;
		p_yea_info.num_of_disableds := 0;
		p_yea_info.num_of_children := 0;
		--
		/*
		Bug 7615517
		-- Bug 4149947: Add total non taxable into current monthly earnings, and respective totals
		p_yea_info.cur_taxable_mth 	:= p_yea_info.cur_taxable_mth 	+ p_yea_info.non_taxable ;
		p_yea_info.cur_taxable 		:= p_yea_info.cur_taxable 	+ p_yea_info.non_taxable ;
		p_yea_info.taxable_mth 		:= p_yea_info.taxable_mth 	+ p_yea_info.non_taxable ;
		End of Bug 7615517
		*/
		-- End of 4149947
		--
		-- Bug 4156004
		/* Bug 7142612: Displaying all Non Taxable Earnings components
		p_yea_info.non_taxable_ovs 		:= 0 ;
		p_yea_info.non_taxable_ovt 		:= 0 ;
		p_yea_info.non_taxable_ovs_frgn 	:= 0 ; -- Bug 7439803
		p_yea_info.research_payment		:= 0 ; -- Bug 7439803
		p_yea_info.birth_raising_allowance 	:= 0 ; -- Bug 7439803
		p_yea_info.foreign_worker_income_exem	:= 0 ; -- Bug 7439803
		-- End of 4156004
		--
		-- Bug 4119539: Make all non-taxables = 0
		p_yea_info.non_taxable_oth := 0 ;
		p_yea_info.non_taxable := 0 ;
		-- End of 4119539
		*/
		--
                -- Bug 5083240: Removed logic to calculate tax break, as it is
                --              not applicable to fixed rate cases
                ----------------------------------------------------------------
                -- Annual Tax
                ----------------------------------------------------------------
                p_yea_info.annual_itax := greatest(p_yea_info.calc_tax, 0);
                p_yea_info.annual_rtax := trunc(p_yea_info.annual_itax * l_annual_itax_per,0);
	else
		-- Bug 3172960
		if p_yea_info.nationality = 'F' then
		        -- Bug 6666723
			p_yea_info.foreign_worker_income_exem := greatest(trunc(p_yea_info.taxable * l_fw_income_exem_rate),0);
			--
			if p_yea_info.foreign_worker_income_exem > 0 then
				p_yea_info.taxable := greatest(p_yea_info.taxable - p_yea_info.foreign_worker_income_exem, 0);
				--
				-- Bug 4119539
				l_fw_inc_exem_res 		:= p_yea_info.foreign_worker_income_exem ;
				p_yea_info.non_taxable		:= p_yea_info.non_taxable + p_yea_info.foreign_worker_income_exem ;
				l_fw_inc_exem_res 		:= p_yea_info.foreign_worker_income_exem ;
				--
				/*
				-- Bug 7615517
				l_fw_temp 			:= greatest(p_yea_info.cur_taxable_mth - l_fw_inc_exem_res, 0) ;
				l_fw_inc_exem_res 		:= greatest(l_fw_inc_exem_res - p_yea_info.cur_taxable_mth, 0) ;
				p_yea_info.taxable_mth		:= greatest(p_yea_info.taxable_mth + l_fw_temp - p_yea_info.cur_taxable_mth, 0) ;
				p_yea_info.cur_taxable_mth 	:= l_fw_temp ;
				--
				l_fw_temp 			:= greatest(p_yea_info.cur_taxable_bon - l_fw_inc_exem_res, 0) ;
				l_fw_inc_exem_res 		:= greatest(l_fw_inc_exem_res - p_yea_info.cur_taxable_bon, 0) ;
				p_yea_info.taxable_bon		:= greatest(p_yea_info.taxable_bon + l_fw_temp - p_yea_info.cur_taxable_bon, 0) ;
				p_yea_info.cur_taxable_bon	:= l_fw_temp ;
				--
				l_fw_temp 			:= greatest(p_yea_info.cur_sp_irreg_bonus - l_fw_inc_exem_res, 0) ;
				p_yea_info.sp_irreg_bonus	:= greatest(p_yea_info.sp_irreg_bonus + l_fw_temp - p_yea_info.cur_sp_irreg_bonus, 0) ;
				p_yea_info.cur_sp_irreg_bonus 	:= l_fw_temp ;

				--
				p_yea_info.cur_taxable		:= greatest(p_yea_info.cur_taxable - p_yea_info.foreign_worker_income_exem, 0) ;
				--
				-- End of 4119539
				-- End of Bug 7615517
				*/
			end if;
		end if;
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
		end if;
		if p_yea_info.num_of_dpnts > 0 then
			p_yea_info.dpnt_tax_exem := p_yea_info.num_of_dpnts * l_dpnt_tax_exem;
			p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.dpnt_tax_exem;
		end if;
		if p_yea_info.num_of_ageds > 0 then
			p_yea_info.aged_tax_exem := p_yea_info.num_of_ageds * l_aged_tax_exem;
		end if;
		-- Bug 3172960
		if p_yea_info.num_of_super_ageds > 0 then
			p_yea_info.aged_tax_exem := p_yea_info.aged_tax_exem + p_yea_info.num_of_super_ageds * l_aged_tax_exem1;
		end if;
		p_yea_info.num_of_ageds := nvl(p_yea_info.num_of_ageds, 0) + nvl(p_yea_info.num_of_super_ageds, 0);
		p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.aged_tax_exem;
		--
		if p_yea_info.num_of_disableds > 0 then
			p_yea_info.disabled_tax_exem := p_yea_info.num_of_disableds * l_disabled_tax_exem;
			p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.disabled_tax_exem;
		end if;
		if p_yea_info.female_ee_flag = 'Y' then
			p_yea_info.female_ee_tax_exem := l_female_ee_tax_exem;
			p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.female_ee_tax_exem;
		end if;
		-- Bug 5756690
		if p_yea_info.num_of_children > 0 then
			p_yea_info.child_tax_exem := p_yea_info.num_of_children * l_raising_child_tax_exem;
			p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.child_tax_exem;
		end if;
		-- End of Bug 5756690
		--
		-- Bug 6705170: New Exemption For New Born Baby Or Adopted Child
		if p_yea_info.num_of_new_born_adopted > 0 then
			p_yea_info.new_born_adopted_tax_exem := p_yea_info.num_of_new_born_adopted * l_new_born_adopted_tax_exem;
			p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.new_born_adopted_tax_exem;
		end if;
		--End of Bug 6705170
		--
                -- Bug 5734313
                -- Bug 6784288
		if p_yea_info.num_of_addtl_child > 2 then
			p_yea_info.addl_child_tax_exem := l_addl_child_tax_exem + ((p_yea_info.num_of_addtl_child - 2) * l_addl_child_tax_exem1);
			p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.addl_child_tax_exem;
                elsif p_yea_info.num_of_addtl_child = 2 then
			p_yea_info.addl_child_tax_exem := l_addl_child_tax_exem;
			p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.addl_child_tax_exem;
		end if;
                --
		----------------------------------------------------------------
		-- Supplemental Tax Exemption
		----------------------------------------------------------------
                /* Bug 5734313 : Obsoleted code for Supplemental Tax Exemption */
		----------------------------------------------------------------
		-- Special Tax Exemption
		----------------------------------------------------------------
                l_cuml_special_exem := 0;  -- Bug 4709683

		if p_yea_info.non_resident_flag = 'N' then
			--
			-- Insurance Premium Tax Exemption
			--
			if p_yea_info.hi_prem > 0 then
				p_yea_info.hi_prem_tax_exem := p_yea_info.hi_prem;
			end if;
			-- Bug 7164589
			if p_yea_info.long_term_ins_prem > 0 then
				p_yea_info.long_term_ins_prem_tax_exem := p_yea_info.long_term_ins_prem;
			end if;
			-- End of Bug 7164589
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
						      + p_yea_info.long_term_ins_prem_tax_exem   -- Bug 7164589
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
			-- End of 4119483
			-- Bug 3971542
			l_cuml_special_exem := l_cuml_special_exem + p_yea_info.ins_prem_tax_exem ;
			-- End of 3971542
			--

			----------------------------------------------------------------
			-- Medical Expense Tax Exemption
			-- Bug 3172960
			-- Bug 3966549: Assigned new fields
			--               p_yea_info.reg_med_exp_tax_exem2004, and
			--               p_yea_info.add_med_exp_tax_exem2004.
			--               Changed calculation for reg. and additional
			--               medical exp. tax exemption.
			----------------------------------------------------------------
			l_total_med_exp        	:= p_yea_info.med_exp + p_yea_info.med_exp_disabled + p_yea_info.med_exp_aged + p_yea_info.med_exp_emp;
			l_ameeg_med_exem 	:= p_yea_info.med_exp_disabled + p_yea_info.med_exp_aged + p_yea_info.med_exp_emp;
			--
			if l_total_med_exp > 0 then
				-- Calculate reg. med. expense exem.
				l_dummy := l_total_med_exp - trunc(greatest(p_yea_info.taxable, 0) * l_med_exp_tax_exem_per) ;
				if l_dummy > 0 then
					-- Calculate reg. med. exp. exem.
					p_yea_info.reg_med_exp_tax_exem2004 := least(l_dummy, l_med_exp_tax_exem_lim) ;
					-- To calculate additional med. exp. exem.
					l_dummy := l_dummy - l_med_exp_tax_exem_lim ;
				else
					p_yea_info.reg_med_exp_tax_exem2004 := 0 ;
				end if;
				if l_dummy < 0 then
					l_dummy := 0 ;
				end if ;
				-- Calculate additional med. exp. exem.
				p_yea_info.add_med_exp_tax_exem2004 := trunc( least(l_ameeg_med_exem, l_dummy) ) ;
				p_yea_info.med_exp_tax_exem	:= p_yea_info.reg_med_exp_tax_exem2004 + p_yea_info.add_med_exp_tax_exem2004 ;
				-- Bug 4119483: Apply upper limit based on cumulative special exemption
				p_yea_info.med_exp_tax_exem := least(
									p_yea_info.med_exp_tax_exem,
									greatest(
										0,
										p_yea_info.taxable_income2 - l_cuml_special_exem
									)
								) ;
				-- End of 4119483

				-- Start of Bug 6630135
				l_card_exp_not_exempted :=0;
				if p_yea_info.tot_med_exp_cards > 0 then
					l_card_exp_not_exempted := l_total_med_exp - p_yea_info.med_exp_tax_exem;
				end if;
                                -- End of Bug 6630135

				-- Bug 3971542
				l_cuml_special_exem := l_cuml_special_exem + p_yea_info.med_exp_tax_exem ;
				-- End of 3971542
			end if;
			-- End of 3966549
			--
			----------------------------------------------------------------
			-- Education Expense Tax Exemption
			----------------------------------------------------------------
			p_yea_info.educ_exp_tax_exem := p_yea_info.ee_educ_exp;

			-- Bug 4119483: Removed limit check on occupational education expense as it is not considered/displayed
			--              individually anywhere.
			--              Also, p_yea_info.educ_exp_tax_exem may still change. Hence, updated value of educ_exp_tax_exem
			--              would be added to l_cuml_special_exem later.
			--
			p_yea_info.educ_exp_tax_exem := p_yea_info.educ_exp_tax_exem + p_yea_info.ee_occupation_educ_exp2005 ;

			-- End of 3971542
			for i in 1..p_yea_info.dpnt_educ_contact_type_tbl.count loop
				if p_yea_info.dpnt_educ_school_type_tbl(i) = 'U' then
					l_dummy := l_dpnt_educ_school_type_U;
				elsif p_yea_info.dpnt_educ_school_type_tbl(i) = 'H' then
					l_dummy := l_dpnt_educ_school_type_H;
				elsif p_yea_info.dpnt_educ_school_type_tbl(i) = 'P' then
					l_dummy := l_dpnt_educ_school_type_P;
				elsif p_yea_info.dpnt_educ_school_type_tbl(i) = 'D' then
					l_dummy := l_dpnt_educ_school_type_D ;
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
			-- Apply upper limit based on cumulative special exemption
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
			----------------------------------------------------------------
			-- Housing Expense Tax Exemption
			----------------------------------------------------------------
			l_dummy := 0;
			for i in 1..p_yea_info.housing_saving_tbl.count loop
				if p_yea_info.housing_saving_type_tbl(i) <> 'HST2' then -- 5731165
					l_dummy := l_dummy + p_yea_info.housing_saving_tbl(i);
                                end if;
			end loop;
			if l_dummy > 0
			   or p_yea_info.housing_loan_repay > 0
			   or p_yea_info.lt_housing_loan_interest_repay > 0
			   or p_yea_info.lt_housing_loan_intr_repay_1 > 0       then
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
				       -- Bug 5731165
				       -- Removed code for Housing Saving Type2
				       elsif p_yea_info.housing_saving_type_tbl(i) = 'HST2' then --Bug 5741382
					     l_dummy := 0;
				       elsif p_yea_info.housing_saving_type_tbl(i) = 'HST3' then
					     l_dummy := p_yea_info.housing_saving_tbl(i);
				       elsif p_yea_info.housing_saving_type_tbl(i) = 'HST4' then
					     l_dummy := p_yea_info.housing_saving_tbl(i);
				       end if;
				       --
				       p_yea_info.housing_saving := p_yea_info.housing_saving + l_dummy;
				       --
				end loop;

                                p_yea_info.max_housing_exp_tax_exem := 0;
                                 p_yea_info.housing_exp_tax_exem := 0;

                                --
                                -- Start of Bug -- 7142620
				p_yea_info.housing_loan_repay_exem := 0;
				p_yea_info.lt_housing_loan_intr_exem := 0;
				-----------------------------------------------------------------------------------------
				--Removed code  of  housing Expense  exemption calculation
				-----------------------------------------------------------------------------------------
				-----------------------------------------------------------------------------------------
				--Housing Loan Repay Exemption --Bug 7142620
				-----------------------------------------------------------------------------------------

				if p_yea_info.housing_loan_repay >0	then

				p_yea_info.housing_loan_repay_exem  :=  least(greatest(p_yea_info.taxable_income2 - l_cuml_special_exem,0), least(l_housinexp_tax_exem_lim,
														p_yea_info.housing_loan_repay * l_housinexp_tax_exem_per));
                               	 p_yea_info.housing_exp_tax_exem := p_yea_info.housing_exp_tax_exem + p_yea_info.housing_loan_repay_exem;
					end if;
				-- End of Bug -- 7142620

				-----------------------------------------------------------------------------------------
				--Long Term Housing Interest Repay Exemption
				-----------------------------------------------------------------------------------------
                                -- Long term loan due less then 15 years
                                --
				-- Bug 3966549 : Added date check
                                if p_yea_info.lt_housing_loan_interest_repay > 0 and p_yea_info.lt_housing_loan_date < c_20040101 then
				-- End of 3966549
                                  --  Start of Bug --7142620
				  -- Bug 7692554
				   p_yea_info.max_housing_exp_tax_exem := p_yea_info.housing_loan_repay_exem + p_yea_info.lt_housing_loan_interest_repay;
                                   p_yea_info.lt_housing_loan_intr_exem := least(p_yea_info.max_housing_exp_tax_exem,l_housinexp_tax_exem_lim1);
				   p_yea_info.lt_housing_loan_intr_exem := greatest(p_yea_info.lt_housing_loan_intr_exem - p_yea_info.housing_loan_repay_exem ,0);
				 -- End of Bug -- 7142620

                                end if;

                                -- Long term loan due greater then 15 years
                                --
                                if p_yea_info.lt_housing_loan_intr_repay_1  > 0 then
                                 -- Start of  Bug -- 7142620
				 -- Bug 7692554
				p_yea_info.max_housing_exp_tax_exem := p_yea_info.lt_housing_loan_intr_exem + p_yea_info.housing_loan_repay_exem + p_yea_info.lt_housing_loan_intr_repay_1 ;
				p_yea_info.lt_housing_loan_intr_exem := least(p_yea_info.max_housing_exp_tax_exem,l_housinexp_tax_exem_lim2);
				p_yea_info.lt_housing_loan_intr_exem := greatest(p_yea_info.lt_housing_loan_intr_exem - p_yea_info.housing_loan_repay_exem ,0);
				--End of Bug --7142620
                                end if;

                             	--
				-- Bug 4119483: Apply upper limit based on cumulative special exemption
				--Start of  Bug -- 7142620
				-- Bug 7692554
				p_yea_info.lt_housing_loan_intr_exem := least(p_yea_info.lt_housing_loan_intr_exem ,greatest(0,p_yea_info.taxable_income2 -
													(l_cuml_special_exem + p_yea_info.housing_loan_repay_exem)));
				p_yea_info.housing_exp_tax_exem := p_yea_info.housing_exp_tax_exem + p_yea_info.lt_housing_loan_intr_exem;
				p_yea_info.housing_exp_tax_exem  := trunc(p_yea_info.housing_exp_tax_exem);
				p_yea_info.lt_housing_loan_intr_exem := trunc(p_yea_info.lt_housing_loan_intr_exem);
				p_yea_info.housing_loan_repay_exem  := trunc(p_yea_info.housing_loan_repay_exem );
				--End of Bug --7142620
				--
				l_cuml_special_exem := l_cuml_special_exem + p_yea_info.housing_exp_tax_exem ;
				-- End of 4119483
			end if;

			-----------------------------------------------------------------
			-- Donation Tax Exemption
			-- Bug 3966549: Modified calculation for statutory donation
			--               exemption. Added code to calculate tax break
			--               and ESOA donation exemption details. Included
			--               ESOA component in the total political exemption
			--               amount.
			-----------------------------------------------------------------
			--
			-- Calculate for Statutory Donation

			p_yea_info.donation1_tax_exem := p_yea_info.donation1;
			if p_yea_info.political_donation1 > 0 then
				p_yea_info.donation1_tax_exem := p_yea_info.donation1_tax_exem + greatest(p_yea_info.political_donation1 - l_political_tax_brk_lim2004, 0);
			end if;
			if p_yea_info.political_donation2 > 0 then
				p_yea_info.donation1_tax_exem := p_yea_info.donation1_tax_exem + p_yea_info.political_donation2 ;
			end if;
			--
			-- Calculate Tax Break for Political Donation
			-- Bug 5682450: Updated Political Donation Tax Break
			p_yea_info.don_tax_break2004 := (greatest(0, p_yea_info.political_donation1) - greatest(0, p_yea_info.political_donation1 - l_political_tax_brk_lim2004 )) / l_pol_don_exem_rate_factor ;
			-- End of 5682450
			--
			-- Calculate for Special Donation
			--  Bug 7142612: Added Public Legal Entity Donation Trust to Tax Law Amount
			if (p_yea_info.donation3 + p_yea_info.donation4) > 0 then
				if p_yea_info.taxable_income > p_yea_info.donation1_tax_exem then
					p_yea_info.max_donation3_tax_exem := trunc((p_yea_info.taxable_income - p_yea_info.donation1_tax_exem) * l_donation3_tax_exem_per);
					p_yea_info.donation3_tax_exem := least((p_yea_info.donation3 + p_yea_info.donation4), p_yea_info.max_donation3_tax_exem);
				end if;
			end if;
			--
			-- Calculate for ESOA Donation
			if p_yea_info.esoa_don2004 > 0 then
				if p_yea_info.taxable_income > (p_yea_info.donation1_tax_exem + p_yea_info.donation3_tax_exem) then
					p_yea_info.max_esoa_don_tax_exem2004 := trunc( (p_yea_info.taxable_income - p_yea_info.donation1_tax_exem - p_yea_info.donation3_tax_exem) * l_esoa_tax_exem_per2004 ) ;
					p_yea_info.esoa_don_tax_exem2004 := least(p_yea_info.esoa_don2004, p_yea_info.max_esoa_don_tax_exem2004 ) ;
				end if ;
			end if ;
			--
			-- Calculate for Specified and Religious Donation
			-- Bug 7142612
			if p_yea_info.religious_donation > 0 then
				if p_yea_info.taxable_income > ( p_yea_info.donation1_tax_exem
								+ p_yea_info.donation3_tax_exem
								+ p_yea_info.esoa_don_tax_exem2004 ) then
					p_yea_info.max_donation2_tax_exem := trunc(
								(p_yea_info.taxable_income
								- p_yea_info.donation1_tax_exem
								- p_yea_info.donation3_tax_exem
								- p_yea_info.esoa_don_tax_exem2004 ) * l_rel_don_tax_exem_per1)
								+ least(trunc(
								(p_yea_info.taxable_income
								- p_yea_info.donation1_tax_exem
								- p_yea_info.donation3_tax_exem
								- p_yea_info.esoa_don_tax_exem2004 ) * l_rel_don_tax_exem_per2),
								(p_yea_info.donation2 - p_yea_info.religious_donation));
					p_yea_info.donation2_tax_exem := least(p_yea_info.donation2, p_yea_info.max_donation2_tax_exem);
				end if;
			else
				if p_yea_info.donation2 > 0 then
					if p_yea_info.taxable_income > ( p_yea_info.donation1_tax_exem
									+ p_yea_info.donation3_tax_exem
									+ p_yea_info.esoa_don_tax_exem2004 ) then
					p_yea_info.max_donation2_tax_exem := trunc(
								(p_yea_info.taxable_income - p_yea_info.donation1_tax_exem
								- p_yea_info.donation3_tax_exem
								- p_yea_info.esoa_don_tax_exem2004 ) * l_donation2_tax_exem_per);
					p_yea_info.donation2_tax_exem := least(p_yea_info.donation2, p_yea_info.max_donation2_tax_exem);
					end if;
				end if;
			end if;
			-- End of Bug 7142612
			-- Now calculate total political donation income exemption
			p_yea_info.donation_tax_exem := p_yea_info.donation1_tax_exem + p_yea_info.donation2_tax_exem + p_yea_info.donation3_tax_exem + p_yea_info.esoa_don_tax_exem2004 ;
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
			-- End of 3966549
			--

			----------------------------------------------------------------
			-- Marriage, Funeral and Relocation Tax Exemption
			----------------------------------------------------------------
                        p_yea_info.marr_fun_relo_exemption := 0;
                        if p_yea_info.taxable < 25000000 then

                           -- Bug 3901802 Modified for multiple occasions
                           --
                           p_yea_info.marr_fun_relo_exemption :=
                                           ( nvl(to_number(p_yea_info.marriage_exemption),0)   * l_marriage_exem_lim) +
                                           ( nvl(to_number(p_yea_info.funeral_exemption),0)    * l_funeral_exem_lim)  +
                                           ( nvl(to_number(p_yea_info.relocation_exemption),0) * l_relocation_exem_lim);

                           -- income exemption available
			   l_dummy  := (p_yea_info.taxable_income2) -
                                                ( p_yea_info.ins_prem_tax_exem
						+ p_yea_info.med_exp_tax_exem
						+ p_yea_info.educ_exp_tax_exem
						+ p_yea_info.housing_exp_tax_exem
						+ p_yea_info.donation_tax_exem);
                           l_dummy := greatest(l_dummy,0);
                           p_yea_info.marr_fun_relo_exemption := trunc(least(p_yea_info.marr_fun_relo_exemption,
                                                                          l_dummy));

			  --
			  -- Bug 4119483: Apply upper limit based on cumulative special exemption
			  p_yea_info.marr_fun_relo_exemption := least(
								  p_yea_info.marr_fun_relo_exemption,
								  greatest(
									  0,
									  p_yea_info.taxable_income2 - l_cuml_special_exem
								)
							) ;
			  --
			  l_cuml_special_exem := l_cuml_special_exem + p_yea_info.marr_fun_relo_exemption ;
			  -- End of 4119483
                        end if;

			----------------------------------------------------------------
			-- Special Tax Exemption
			----------------------------------------------------------------
			p_yea_info.sp_tax_exem := p_yea_info.ins_prem_tax_exem
						+ p_yea_info.med_exp_tax_exem
						+ p_yea_info.educ_exp_tax_exem
						+ p_yea_info.housing_exp_tax_exem
						+ p_yea_info.donation_tax_exem
                                                + p_yea_info.marr_fun_relo_exemption;

			if p_yea_info.sp_tax_exem < l_std_sp_tax_exem then
				p_yea_info.sp_tax_exem		:= 0;
				p_yea_info.std_sp_tax_exem	:= l_std_sp_tax_exem;
			end if;
			p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.sp_tax_exem - p_yea_info.std_sp_tax_exem;

			----------------------------------------------------------------
			--  Pension Premium Tax Exemption Bug 6843245
			----------------------------------------------------------------
			if p_yea_info.pen_prem > 0 then
				p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.pen_prem;
			end if;
			----------------------------------------------------------------
			-- National Pension Premium Tax Exemption
			----------------------------------------------------------------
			if p_yea_info.np_prem > 0 then
				p_yea_info.np_prem_tax_exem := p_yea_info.np_prem;
				p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.np_prem_tax_exem;
			end if;
			----------------------------------------------------------------
			-- Bug : 4776711
			-- Corporate Pension Premium Tax Exemption
			-- Bug 6852749
			-- p_yea_info.corp_pension_prem_tax_exem is now deducted from p_yea_info.taxable_income2 and not p_yea_info.taxation_base
			----------------------------------------------------------------
			if p_yea_info.corp_pension_prem > 0 then

			  if p_yea_info.pers_pension_saving > 0 then
			     p_yea_info.pers_pension_saving_tax_exem := least(p_yea_info.pers_pension_saving, l_pers_pen_savintax_exem_lim);
                          end if;
			        p_yea_info.corp_pension_prem_tax_exem := least(p_yea_info.corp_pension_prem+p_yea_info.pers_pension_saving,l_corp_pen_prem_tax_exem_lim)- nvl(p_yea_info.pers_pension_saving_tax_exem,0);
			        if p_yea_info.corp_pension_prem_tax_exem < 0 then
			           p_yea_info.corp_pension_prem_tax_exem := 0;
			        end if;
			        p_yea_info.taxable_income2 := p_yea_info.taxable_income2 - p_yea_info.corp_pension_prem_tax_exem;
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
			-- Small Business Installment Tax Exemption Bug 6895093
			----------------------------------------------------------------
			if p_yea_info.small_bus_install > 0 then
				p_yea_info.small_bus_install_exem := least(p_yea_info.small_bus_install, least(greatest(p_yea_info.taxation_base,0),l_small_bus_install_lim));
			p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.small_bus_install_exem;
			else
				p_yea_info.small_bus_install_exem := 0;
			end if;
			-----------------------------------------------------------------------------------------
			-- Housing Saving Exemption -- Bug  7142620
			-----------------------------------------------------------------------------------------
			if p_yea_info.housing_saving >0 then
			-- Bug 8240892

			  p_yea_info.housing_saving_exem := least(greatest(p_yea_info.taxation_base,0) ,
				   least(l_housinexp_tax_exem_lim - nvl(p_yea_info.housing_loan_repay_exem,0), p_yea_info.housing_saving * l_housinexp_tax_exem_per ));

			if p_yea_info.lt_housing_loan_interest_repay > 0 and p_yea_info.lt_housing_loan_date < c_20040101 then
			    p_yea_info.housing_saving_exem := least(greatest(p_yea_info.taxation_base,0) ,
				   least(l_housinexp_tax_exem_lim1 - nvl(p_yea_info.housing_loan_repay_exem,0) - nvl(p_yea_info.lt_housing_loan_intr_exem,0),
				         l_housinexp_tax_exem_lim - nvl(p_yea_info.housing_loan_repay_exem,0), p_yea_info.housing_saving * l_housinexp_tax_exem_per ));
			 end if;

			if p_yea_info.lt_housing_loan_intr_repay_1  > 0 then
				p_yea_info.housing_saving_exem := least(greatest(p_yea_info.taxation_base,0) ,
				   least(l_housinexp_tax_exem_lim2 - nvl(p_yea_info.housing_loan_repay_exem,0) - nvl(p_yea_info.lt_housing_loan_intr_exem,0),
				         l_housinexp_tax_exem_lim - nvl(p_yea_info.housing_loan_repay_exem,0), p_yea_info.housing_saving * l_housinexp_tax_exem_per ));
			end if;

			p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.housing_saving_exem;
			else
				p_yea_info.housing_saving_exem := 0;
			end if;
			----------------------------------------------------------------
			-- Investment Partnership Financing Tax Exemption
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
			----------------------------------------------------------------
			-- Credit Card Expense Tax Exem
			-- Bug 3966549: Now differentiate between employee's and
			--              dependents' direct payments. Also use new
			--              global value
			--              (KR_YEA_CREDIT_CARD_EXP_2004_TAX_EXEM) to
			--              calculate max. exemption amount.
                        -- Bug 3506168: Added cash receipt expenses.
			----------------------------------------------------------------
                        ----------------------------------------------------------------
			-- Bug 6630135 Amount that needs to be excluded from cards exemption
			--              (Double Exemption amount to be excluded)
			--            = Total medical expense amount paid in cards (p_yea_info.tot_med_exp_cards)
			--             - Medical Expense Paid (both cards and cash) but not included in medical expense exemption (l_card_exp_not_exempted -- Calculated in Medical Exemption)
			--             - Medical Expense Paid in cards for the Dependent who are not eligible for Basic Exemption ((p_yea_info.dpnt_med_exp_cards)
                        ----------------------------------------------------------------

                        p_yea_info.med_exp_paid_not_inc_med_exem := nvl(l_card_exp_not_exempted,0);
                        l_double_exem_amt := 0 ;
                       -- Bug 7668422 Double Exemption is allowed for medical expense paid in cards
                        /*
                        -- Start Bug 6685443 added if condition  below
                        if nvl(p_yea_info.tot_med_exp_cards,0) >= trunc(greatest(p_yea_info.taxable, 0) * l_med_exp_tax_exem_per) then

			    if nvl(l_card_exp_not_exempted,0) > 0 then
                                   l_double_exem_amt := greatest((nvl(p_yea_info.tot_med_exp_cards,0) - nvl(l_card_exp_not_exempted,0) - nvl(p_yea_info.dpnt_med_exp_cards,0)),0);
                             elsif nvl(l_card_exp_not_exempted,0) = 0 then
                                   l_double_exem_amt := 0 ;
			     end if;
			else
                        l_double_exem_amt := 0 ;
			end if;
                         -- End Bug 6685443
                         -- End of Bug 6630135
                         -- Bug 6716401
                        */
			p_yea_info.double_exem_amt := l_double_exem_amt;
                         -- End of Bug 6716401
			-- Bug 7615517: Updated Total Credit Card amount for Company Related Expenses
			p_yea_info.total_credit_card_exp :=p_yea_info.emp_cre_card_direct_exp2004
							   + p_yea_info.dpnt_cre_card_direct_exp2004
			                                   + p_yea_info.giro_tuition_paid_exp2004
							   + p_yea_info.cash_receipt_exp2005
							   - p_yea_info.company_related_exp ;
                                                                                                                                                                       -- Bug 7668422
							--  - l_double_exem_amt ; -- Bug 5682131 l_double_exem_amt added for Bug 6630135
			if p_yea_info.total_credit_card_exp > 0 then
				-- After the statement below, l_dummy holds the total credit card expense subject to exemption
				l_dummy := p_yea_info.total_credit_card_exp - (greatest(p_yea_info.taxable, 0) * l_cre_card_exp_tax_exem_per1);
				--
				if l_dummy > 0 then
					p_yea_info.credit_card_exp_tax_exem := (l_dummy * ( p_yea_info.credit_card_exp / p_yea_info.total_credit_card_exp ));
					p_yea_info.direct_card_exp_tax_exem := (l_dummy * ( p_yea_info.direct_card_exp / p_yea_info.total_credit_card_exp ));
					--
					-- After statement below, l_dummy holds maximum exemption amount
					l_dummy := l_dummy * l_cre_card_tax_exem_per2004 ;
					--
					-- End of 3966549
					--
					-- Bug 3089512 Consider the 20% of Taxable Earnings for Credit card exemption.
					p_yea_info.total_credit_card_exp_tax_exem := trunc(least(l_dummy ,(p_yea_info.taxable * l_cre_card_exp_tax_exem_per2), l_cre_card_exp_tax_exem_lim));
					p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.total_credit_card_exp_tax_exem;
					--
					-- Collect total credit card exemption into p_yea_info.credit_card_exp_tax_exem
					-- for keeping compatibility with package pay_kr_yea20020101_pkg
					-- These are used to display data in YEA result form and YEA reports
					--
					p_yea_info.credit_card_exp_tax_exem := p_yea_info.total_credit_card_exp_tax_exem;
				end if;
				-- Collect total credit card expenses into p_yea_info.credit_card_exp
				p_yea_info.credit_card_exp := p_yea_info.total_credit_card_exp;
				--
			end if;
			----------------------------------------------------------------
			-- Employee Stock Ownership Plan Contribution Tax Exemption
			----------------------------------------------------------------
			if p_yea_info.emp_stk_own_contri > 0 then
				p_yea_info.emp_stk_own_contri_tax_exem :=
						least(p_yea_info.emp_stk_own_contri, l_emp_stock_own_plan_exem_lim);
				p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.emp_stk_own_contri_tax_exem;
			end if;
			----------------------------------------------------------------
			-- Bug 7615517: Long Term Stock Fund Tax Exemption
			----------------------------------------------------------------
			if ((p_yea_info.long_term_stck_fund_1year > 0)
			   or (p_yea_info.long_term_stck_fund_2year > 0)
			   or (p_yea_info.long_term_stck_fund_3year > 0)) then
			      p_yea_info.long_term_stck_fund_tax_exem
			      := (least(greatest(p_yea_info.long_term_stck_fund_1year,0), l_long_term_stck_fund_1yr_lim)*l_long_term_stck_fund_1yr_pct)
			       + (least(greatest(p_yea_info.long_term_stck_fund_2year,0), l_long_term_stck_fund_2yr_lim)*l_long_term_stck_fund_2yr_pct)
			       + (least(greatest(p_yea_info.long_term_stck_fund_3year,0), l_long_term_stck_fund_3yr_lim)*l_long_term_stck_fund_3yr_pct);
			      p_yea_info.long_term_stck_fund_tax_exem := least(p_yea_info.long_term_stck_fund_tax_exem, greatest(p_yea_info.taxation_base,0));
			      p_yea_info.taxation_base := p_yea_info.taxation_base - p_yea_info.long_term_stck_fund_tax_exem;
			else
			      p_yea_info.long_term_stck_fund_tax_exem := 0;
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
		else
			l_dummy := 0;
		end if;
		--
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
			p_yea_info.basic_tax_break := least(p_yea_info.basic_tax_break, l_available_tax_break);
			l_available_tax_break      := l_available_tax_break - p_yea_info.basic_tax_break;
			--
			p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.basic_tax_break;
		end if;
		--
		----------------------------------------------------------------
		-- Bug 7361372: Type B Tax Group Tax Break
		----------------------------------------------------------------
		if p_yea_info.calc_tax > 0 and p_yea_info.taxable > 0 then
		     if p_yea_info.tax_grp_taxable > 0 then
		       p_yea_info.tax_grp_post_tax_deduc := (p_yea_info.calc_tax * (p_yea_info.tax_grp_taxable / p_yea_info.taxable)) * l_type_B_tax_group_pct;
                       --
                       p_yea_info.tax_grp_post_tax_deduc := least(p_yea_info.tax_grp_post_tax_deduc,l_available_tax_break);
		       l_available_tax_break         	 := l_available_tax_break - p_yea_info.tax_grp_post_tax_deduc;
      		       --
		       p_yea_info.total_tax_break 	 := p_yea_info.total_tax_break + p_yea_info.tax_grp_post_tax_deduc;
		     else
		       p_yea_info.tax_grp_post_tax_deduc := 0;
		     end if;
		end if;
		--
		----------------------------------------------------------------
		if p_yea_info.non_resident_flag = 'N' then
			--
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
			   --
			   open  csr_ovs_def_bal_id;
			   fetch csr_ovs_def_bal_id into l_ovs_def_bal_id;
			   --
			   if csr_ovs_def_bal_id%found then
			      --
			      l_ovs_earnings_bal:= pay_balance_pkg.get_value
						       (p_defined_balance_id   => l_ovs_def_bal_id
						       ,p_assignment_id        => p_assignment_id
						       ,p_virtual_date         => p_effective_date
						       ,p_always_get_db_item   => FALSE);
			   end if;
			   close csr_ovs_def_bal_id;
			   --
			   p_yea_info.ovstb_taxable := p_yea_info.ovstb_taxable + l_ovs_earnings_bal;
				l_dummy := trunc(p_yea_info.calc_tax * greatest((p_yea_info.ovstb_taxable  - trunc(p_yea_info.ovstb_taxable_subj_tax_break * p_yea_info.ovstb_tax_break_rate / 100)), 0) / p_yea_info.taxable);
				p_yea_info.ovs_tax_break := least(p_yea_info.ovstb_tax, l_dummy);
				--
				p_yea_info.ovs_tax_break := least(p_yea_info.ovs_tax_break, l_available_tax_break);
				l_available_tax_break    := l_available_tax_break - p_yea_info.ovs_tax_break;
				--
				p_yea_info.total_tax_break := p_yea_info.total_tax_break + p_yea_info.ovs_tax_break;
			end if;
		end if;
		----------------------------------------------------------------
		-- Political Donation Tax Break
		-- Bug 3966549
		----------------------------------------------------------------
		if p_yea_info.non_resident_flag = 'N' then
			p_yea_info.don_tax_break2004 	:= least(p_yea_info.don_tax_break2004, l_available_tax_break) ;
			--
			l_available_tax_break 		:= l_available_tax_break      - p_yea_info.don_tax_break2004 ;
			p_yea_info.total_tax_break	:= p_yea_info.total_tax_break + p_yea_info.don_tax_break2004 ;
		end if ;
		-- End of 3966549
		----------------------------------------------------------------
		-- Foreign Worker Tax Break and set Annual Tax to "0"
		----------------------------------------------------------------
                -- Bug 5083240
		if p_yea_info.nationality = 'F'
                and p_yea_info.fixed_tax_rate = 'N'
                and p_yea_info.fwtb_immigration_purpose is not null then
                        l_fw_contr_fw_inc_exem := 0 ;
                        l_fw_contr_taxable := 0 ;
                        l_fw_contr_basic_exem := 0 ;
                        l_fw_brk_proration_factor := 0 ;

                        -- Deduct foreign worker income exemption
                        l_fw_contr_fw_inc_exem := greatest(trunc(((p_yea_info.fw_contr_taxable_earn + p_yea_info.fw_contr_non_taxable_earn) * l_fw_income_exem_rate), 0), 0) ;
                        if l_fw_contr_fw_inc_exem > 0 then
                                l_fw_contr_taxable := greatest(p_yea_info.fw_contr_taxable_earn - l_fw_contr_fw_inc_exem, 0) ;
                                p_yea_info.fw_contr_non_taxable_earn := p_yea_info.fw_contr_non_taxable_earn + l_fw_contr_fw_inc_exem ;
                        end if ;

                        -- Deduct basic exemption on taxable income calculated till now
                        if l_fw_contr_taxable > 0 then
                                l_addend := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'BASIC_INCOME_EXEM',
							p_col_name		=> 'ADDEND',
							p_row_value		=> to_char(l_fw_contr_taxable),
							p_effective_date	=> p_effective_date));
                                l_multiplier := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'BASIC_INCOME_EXEM',
							p_col_name		=> 'MULTIPLIER',
							p_row_value		=> to_char(l_fw_contr_taxable),
							p_effective_date	=> p_effective_date));
                                l_subtrahend := to_number(hruserdt.get_table_value(
							p_bus_group_id		=> p_business_group_id,
							p_table_name		=> 'BASIC_INCOME_EXEM',
							p_col_name		=> 'SUBTRAHEND',
							p_row_value		=> to_char(l_fw_contr_taxable),
							p_effective_date	=> p_effective_date));

                                l_fw_contr_basic_exem := l_addend + trunc(l_multiplier/100 * (l_fw_contr_taxable - l_subtrahend)) ;
                                l_fw_contr_taxable := l_fw_contr_taxable - l_fw_contr_basic_exem ;
                        end if ;

                        -- Now calculate the proration factor
                        l_fw_brk_proration_factor := (l_fw_contr_taxable/p_yea_info.taxable_income) ;

                        -- Prorate tax breaks
                        p_yea_info.foreign_worker_tax_break := greatest(trunc((p_yea_info.calc_tax * l_fw_brk_proration_factor), 0), 0) ;
                        p_yea_info.annual_itax := greatest(p_yea_info.calc_tax - p_yea_info.foreign_worker_tax_break, 0) ;
                        p_yea_info.annual_rtax := trunc(p_yea_info.annual_itax * l_annual_itax_per, 0) ;
                        -- End of 5083240

			p_yea_info.annual_stax := 0;

                        p_yea_info.basic_tax_break       := 0;
                        p_yea_info.housing_exp_tax_break := 0;
                        p_yea_info.ovs_tax_break         := 0;
                        p_yea_info.don_tax_break2004     := 0;
                        p_yea_info.total_tax_break       := 0;

			if p_yea_info.fwtb_immigration_purpose = 'G' then
				p_yea_info.foreign_worker_tax_break1 := p_yea_info.foreign_worker_tax_break;
			else
				p_yea_info.foreign_worker_tax_break2 := p_yea_info.foreign_worker_tax_break;
			end if;
		else
			----------------------------------------------------------------
			-- Annual Tax
			----------------------------------------------------------------
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
	end if; -- nationality
	----------------------------------------------------------------
	-- Calculate Tax Adjustment
        -- Truncating the last Won digit after the final calculation of annual_itax , annual_rtax and annual_stax.
	----------------------------------------------------------------
	-- Bug 7676136: Added NVL clause for the Type B Tax Group fields
	p_yea_info.itax_adj := trunc(p_yea_info.annual_itax - p_yea_info.prev_itax - nvl(p_yea_info.tax_grp_itax,0) - p_yea_info.cur_itax,-1);
	p_yea_info.rtax_adj := trunc(p_yea_info.annual_rtax - p_yea_info.prev_rtax - nvl(p_yea_info.tax_grp_rtax,0) - p_yea_info.cur_rtax,-1);
	p_yea_info.stax_adj := trunc(p_yea_info.annual_stax - p_yea_info.prev_stax - nvl(p_yea_info.tax_grp_stax,0) - p_yea_info.cur_stax,-1);
        --
        if p_yea_info.itax_adj >= 0 and p_yea_info.itax_adj < 1000 then
             p_yea_info.itax_adj := 0;
             p_yea_info.rtax_adj := 0;
             p_yea_info.stax_adj := 0;
             p_tax_adj_warning   := TRUE;
        end if;
end yea;
--
end pay_kr_yea20080101_pkg;

/
