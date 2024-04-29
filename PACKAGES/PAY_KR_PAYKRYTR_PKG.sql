--------------------------------------------------------
--  DDL for Package PAY_KR_PAYKRYTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_PAYKRYTR_PKG" AUTHID CURRENT_USER as
/* $Header: paykrytr.pkh 120.7.12010000.10 2009/12/04 11:49:31 pnethaga ship $ */
------------------------------------------------------------------------
procedure data(
	p_assignment_action_id		in number,
	p_person_id			out nocopy number,   -- Bug 6012258
	p_resident_type			out nocopy varchar2,
	p_nationality_type		out nocopy varchar2,
	p_fw_fixed_tax_rate             out nocopy varchar2, -- 3546993
	p_emp_start_date		out nocopy date,	-- Bug 8644512
	p_period_start_date		out nocopy date,
	p_period_end_date		out nocopy date,
	p_fwtb_contract_date		out nocopy date,
	p_fwtb_expiry_date		out nocopy date,
	p_cur_taxable_mth		out nocopy number,
	p_cur_taxable_bon		out nocopy number,
	p_cur_sp_irreg_bonus		out nocopy number,
	p_cur_stck_pur_opt_exec_earn    out nocopy number,  -- bug 6012258
	p_cur_esop_withd_earn		out nocopy number,  -- Bug 8644512
	p_cur_taxable			out nocopy number,
	p_cur_non_taxable_ovt		out nocopy number, -- Bug 8644512
	p_cur_birth_raising_allowance	out nocopy number, -- Bug 8644512
	p_cur_fw_income_exem		out nocopy number, -- Bug 8644512
	p_prev_hire_date1		out nocopy date,	-- Bug 8644512
	p_prev_termination_date1	out nocopy date,	-- Bug 8644512
	p_prev_tax_brk_pd_from1		out nocopy date,	-- Bug 8644512
	p_prev_tax_brk_pd_to1		out nocopy date,	-- Bug 8644512
	p_prev_corp_name1		out nocopy varchar2,
	p_prev_bp_number1		out nocopy varchar2,
	p_prev_taxable_mth1		out nocopy number,
	p_prev_taxable_bon1		out nocopy number,
	p_prev_sp_irreg_bonus1		out nocopy number,
	p_prev_stck_pur_opt_exec_earn1  out nocopy number,  -- Bug 6024342
	p_prev_esop_withd_earn1		out nocopy number,  -- Bug 8644512
	p_prev_non_taxable_ovt1		out nocopy number,  -- Bug 8644512
	p_prev_bir_raising_allw1	out nocopy number,  -- Bug 8644512
	p_prev_fw_income_exem1		out nocopy number,  -- Bug 8644512
	p_prev_taxable1			out nocopy number,
	p_prev_hire_date2		out nocopy date,	-- Bug 8644512
	p_prev_termination_date2	out nocopy date,	-- Bug 8644512
	p_prev_tax_brk_pd_from2		out nocopy date,	-- Bug 8644512
	p_prev_tax_brk_pd_to2		out nocopy date,	-- Bug 8644512
	p_prev_corp_name2		out nocopy varchar2,
	p_prev_bp_number2		out nocopy varchar2,
	p_prev_taxable_mth2		out nocopy number,
	p_prev_taxable_bon2		out nocopy number,
	p_prev_sp_irreg_bonus2		out nocopy number,
	p_prev_stck_pur_opt_exec_earn2  out nocopy number,  -- Bug 6024342
	p_prev_esop_withd_earn2		out nocopy number,  -- Bug 8644512
	p_prev_non_taxable_ovt2		out nocopy number,  -- Bug 8644512
	p_prev_bir_raising_allw2	out nocopy number,  -- Bug 8644512
	p_prev_fw_income_exem2		out nocopy number,  -- Bug 8644512
	p_prev_taxable2			out nocopy number,
	p_taxable_mth			out nocopy number,
	p_taxable_bon			out nocopy number,
	p_sp_irreg_bonus		out nocopy number,
	p_stck_pur_opt_exec_earn        out nocopy number,  -- bug 6024342
	p_esop_withd_earn		out nocopy number,  -- Bug 8644512
	p_research_payment		out nocopy number,  -- bug 6012258
	p_taxable			out nocopy number,
	p_taxable1			out nocopy number,  -- Bug 7615517
	p_non_taxable_ovs		out nocopy number,
	p_non_taxable_ovt		out nocopy number,
	p_non_taxable_oth		out nocopy number,
	p_non_taxable			out nocopy number,
	p_foreign_worker_tax_exem	out nocopy number,  -- 3546993
	p_basic_income_exem		out nocopy number,
	p_taxable_income		out nocopy number,
	p_ee_tax_exem			out nocopy number,
	p_dpnt_spouse_tax_exem		out nocopy number,
	p_num_of_dpnts			out nocopy number,
	p_dpnt_tax_exem			out nocopy number,
	p_num_of_ageds			out nocopy number,
	p_aged_tax_exem			out nocopy number,
	p_num_of_disableds		out nocopy number,
	p_disabled_tax_exem		out nocopy number,
	p_female_ee_tax_exem		out nocopy number,
	p_num_of_children		out nocopy number,
	--- Bug 7142620
	p_housing_loan_repay_exem	out nocopy number,
	p_housing_saving_exem		out nocopy number,
	p_lt_housing_loan_intr_exem	out nocopy number,
	p_birth_raising_allowance	out nocopy number,
	p_num_of_new_born_adopted	out nocopy number,
	p_new_born_adopted_tax_exem	out nocopy number,
	--- End of  Bug 7142620
	p_long_term_stck_fund_tax_exem  out nocopy number,  -- Bug 7615517
	p_num_of_underaged_dpnts	out nocopy number,  -- Bug 6024342
	p_child_tax_exem		out nocopy number,
	p_num_of_addtl_child		out nocopy number,  -- Bug 6784288
	p_addl_child_tax_exem		out nocopy number,  -- bug 6012258
	p_supp_tax_exem			out nocopy number,
	p_ins_prem_tax_exem		out nocopy number,
	p_med_exp_tax_exem		out nocopy number,
	p_educ_exp_tax_exem		out nocopy number,
	p_donation_tax_exem		out nocopy number,
	p_marr_fun_relo_exem		out nocopy number,  -- 3402025
	p_sp_tax_exem			out nocopy number,
	p_std_sp_tax_exem		out nocopy number,
	p_np_prem_tax_exem		out nocopy number,
	p_pension_premium		out nocopy number,	-- Bug 6024342
	p_taxable_income2		out nocopy number,
	p_pers_pension_prem_tax_exem	out nocopy number,
	p_corp_pension_prem_tax_exem	out nocopy number,  -- 4750653
	p_pers_pension_saving_tax_exem	out nocopy number,
	p_invest_partner_fin_tax_exem	out nocopy number,
	p_credit_card_exp_tax_exem	out nocopy number,
	p_emp_st_own_plan_cont_exem     out nocopy number,
	p_small_bus_install_exem    	out nocopy number,	-- Bug 6895093
	p_hi_prem			out nocopy number,   	-- Bug 6895093
        p_ltci_prem                     out nocopy number,      -- Bug 7260606
	p_ei_prem			out nocopy number,   	-- Bug 6895093
	p_np_prem			out nocopy number,   	-- Bug 6895093
	p_non_rep_non_taxable           out nocopy number,      -- Bug 9079478
	p_smb_income_exem               out nocopy number,      -- Bug 9079478
	p_taxation_base			out nocopy number,
	p_calc_tax			out nocopy number,
	p_basic_tax_break		out nocopy number,
	p_housing_exp_tax_break		out nocopy number,
	p_stock_saving_tax_break	out nocopy number,
	p_ovs_tax_break			out nocopy number,
	p_don_tax_break			out nocopy number,  -- 3966549
	p_lt_stock_saving_tax_break	out nocopy number,
	p_total_tax_break		out nocopy number,
	p_foreign_worker_tax_break1	out nocopy number,
	p_foreign_worker_tax_break2	out nocopy number,
	p_foreign_worker_tax_break	out nocopy number,
	p_annual_itax			out nocopy number,
	p_annual_stax			out nocopy number,
	p_annual_rtax			out nocopy number,
	p_annual_tax			out nocopy number,
	p_prev_itax			out nocopy number,
	p_prev_stax			out nocopy number,
	p_prev_rtax			out nocopy number,
	p_prev_tax			out nocopy number,
	p_cur_itax			out nocopy number,
	p_cur_stax			out nocopy number,
	p_cur_rtax			out nocopy number,
	p_cur_tax			out nocopy number,
	p_itax_adj			out nocopy number,
	p_stax_adj			out nocopy number,
	p_rtax_adj			out nocopy number,
	p_tax_adj			out nocopy number,
	p_cash_receipt_expense          out nocopy number, -- 4289780
	p_emp_ins_exp_nts		out nocopy number, -- 5190884
	p_emp_tot_ins_exp		out nocopy number, -- Bug 5667762
	p_emp_med_exp_nts		out nocopy number,
	p_emp_med_exp_oth		out nocopy number,
	p_emp_educ_exp_nts		out nocopy number,
	p_emp_educ_exp_oth		out nocopy number,
	p_emp_card_exp_nts		out nocopy number,
	p_emp_card_exp_oth		out nocopy number,
	p_emp_cash_exp_nts		out nocopy number,
	p_emp_don_exp_nts		out nocopy number,
	p_emp_don_exp_oth		out nocopy number,
	p_double_exem_amt               out nocopy number,   -- Bug 6716401
        p_tax_grp_bus_reg_num           out nocopy varchar2,   -- Bug 7361372
        p_tax_grp_name                  out nocopy varchar2,   -- Bug 7361372
	p_tax_grp_wkpd_from		out nocopy date,	-- Bug 8644512
	p_tax_grp_wkpd_to		out nocopy date,	-- Bug 8644512
	p_tax_grp_tax_brk_pd_from	out nocopy date,	-- Bug 8644512
	p_tax_grp_tax_brk_pd_to		out nocopy date,	-- Bug 8644512
        p_tax_grp_taxable_mth           out nocopy number,   -- Bug 7361372
        p_tax_grp_taxable_bon           out nocopy number,   -- Bug 7361372
        p_tax_grp_sp_irreg_bonus        out nocopy number,   -- Bug 7361372
        p_tax_stck_pur_opt_exec_earn 	out nocopy number,   -- Bug 7361372
	p_tax_grp_esop_withd_earn	out nocopy number,   -- Bug 8644512
        p_tax_grp_taxable               out nocopy number,   -- Bug 7361372
	p_tax_grp_non_taxable_ovt	out nocopy number,   -- Bug 8644512
	p_tax_grp_bir_raising_allw	out nocopy number,   -- Bug 8644512
	p_tax_grp_fw_income_exem	out nocopy number,   -- Bug 8644512
        p_tax_grp_post_tax_deduc        out nocopy number,   -- Bug 7361372
	--
	p_total_ntax_G01	out nocopy number,   -- Bug 8644512
	p_total_ntax_H01	out nocopy number,   -- Bug 8644512
	p_total_ntax_H05	out nocopy number,   -- Bug 8644512
	p_total_ntax_H06	out nocopy number,   -- Bug 8644512
	p_total_ntax_H07	out nocopy number,   -- Bug 8644512
	p_total_ntax_H08	out nocopy number,   -- Bug 8644512
	p_total_ntax_H09	out nocopy number,   -- Bug 8644512
	p_total_ntax_H10	out nocopy number,   -- Bug 8644512
	p_total_ntax_H11	out nocopy number,   -- Bug 8644512
	p_total_ntax_H12	out nocopy number,   -- Bug 8644512
	p_total_ntax_H13	out nocopy number,   -- Bug 8644512
	p_total_ntax_I01	out nocopy number,   -- Bug 8644512
	p_total_ntax_K01	out nocopy number,   -- Bug 8644512
	p_total_ntax_M01	out nocopy number,   -- Bug 8644512
	p_total_ntax_M02	out nocopy number,   -- Bug 8644512
	p_total_ntax_M03	out nocopy number,   -- Bug 8644512
	p_total_ntax_S01	out nocopy number,   -- Bug 8644512
	p_total_ntax_T01	out nocopy number,   -- Bug 8644512
	p_total_ntax_Y01	out nocopy number,   -- Bug 8644512
	p_total_ntax_Y02	out nocopy number,   -- Bug 8644512
	p_total_ntax_Y03	out nocopy number,   -- Bug 8644512
	p_total_ntax_Y20	out nocopy number,   -- Bug 8644512
	p_total_ntax_Z01	out nocopy number,   -- Bug 8644512
	--
	p_cur_ntax_G01		out nocopy number,   -- Bug 8644512
	p_cur_ntax_H01		out nocopy number,   -- Bug 8644512
	p_cur_ntax_H05		out nocopy number,   -- Bug 8644512
	p_cur_ntax_H06		out nocopy number,   -- Bug 8644512
	p_cur_ntax_H07		out nocopy number,   -- Bug 8644512
	p_cur_ntax_H08		out nocopy number,   -- Bug 8644512
	p_cur_ntax_H09		out nocopy number,   -- Bug 8644512
	p_cur_ntax_H10		out nocopy number,   -- Bug 8644512
	p_cur_ntax_H11		out nocopy number,   -- Bug 8644512
	p_cur_ntax_H12		out nocopy number,   -- Bug 8644512
	p_cur_ntax_H13		out nocopy number,   -- Bug 8644512
	p_cur_ntax_I01		out nocopy number,   -- Bug 8644512
	p_cur_ntax_K01		out nocopy number,   -- Bug 8644512
	p_cur_ntax_M01		out nocopy number,   -- Bug 8644512
	p_cur_ntax_M02		out nocopy number,   -- Bug 8644512
	p_cur_ntax_M03		out nocopy number,   -- Bug 8644512
	p_cur_ntax_S01		out nocopy number,   -- Bug 8644512
	p_cur_ntax_T01		out nocopy number,   -- Bug 8644512
	p_cur_ntax_Y01		out nocopy number,   -- Bug 8644512
	p_cur_ntax_Y02		out nocopy number,   -- Bug 8644512
	p_cur_ntax_Y03		out nocopy number,   -- Bug 8644512
	p_cur_ntax_Y20		out nocopy number,   -- Bug 8644512
	p_cur_ntax_Z01		out nocopy number,   -- Bug 8644512
	--
	p_tax_grp_ntax_G01	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_H01	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_H05	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_H06	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_H07	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_H08	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_H09	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_H10	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_H11	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_H12	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_H13	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_I01	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_K01	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_M01	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_M02	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_M03	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_S01	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_T01	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_Y01	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_Y02	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_Y03	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_Y20	out nocopy number,   -- Bug 8644512
	p_tax_grp_ntax_Z01	out nocopy number,   -- Bug 8644512
	--
	p_prev1_ntax_G01	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_H01	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_H05	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_H06	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_H07	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_H08	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_H09	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_H10	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_H11	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_H12	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_H13	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_I01	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_K01	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_M01	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_M02	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_M03	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_S01	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_T01	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_Y01	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_Y02	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_Y03	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_Y20	out nocopy number,   -- Bug 8644512
	p_prev1_ntax_Z01	out nocopy number,   -- Bug 8644512
	--
	p_prev2_ntax_G01	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_H01	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_H05	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_H06	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_H07	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_H08	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_H09	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_H10	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_H11	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_H12	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_H13	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_I01	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_K01	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_M01	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_M02	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_M03	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_S01	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_T01	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_Y01	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_Y02	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_Y03	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_Y20	out nocopy number,   -- Bug 8644512
	p_prev2_ntax_Z01	out nocopy number,   -- Bug 8644512
	--
	p_cur_total_ntax_earn	out nocopy number,   -- Bug 8644512
	p_tax_grp_total_ntax_earn out nocopy number, -- Bug 8644512
	p_prev1_total_ntax_earn	out nocopy number,   -- Bug 8644512
	p_prev2_total_ntax_earn	out nocopy number,   -- Bug 8644512
	--
	p_prev1_bus_reg_num	out nocopy varchar2, -- Bug 8644512
	p_prev1_itax		out nocopy number,   -- Bug 8644512
	p_prev1_rtax		out nocopy number,   -- Bug 8644512
	p_prev1_stax		out nocopy number,   -- Bug 8644512
	p_prev1_total_tax	out nocopy number,   -- Bug 8644512
	p_prev2_bus_reg_num	out nocopy varchar2, -- Bug 8644512
	p_prev2_itax		out nocopy number,   -- Bug 8644512
	p_prev2_rtax		out nocopy number,   -- Bug 8644512
	p_prev2_stax		out nocopy number,   -- Bug 8644512
	p_prev2_total_tax	out nocopy number,   -- Bug 8644512
	p_prev3_bus_reg_num	out nocopy varchar2, -- Bug 8644512
	p_prev3_itax		out nocopy number,   -- Bug 8644512
	p_prev3_rtax		out nocopy number,   -- Bug 8644512
	p_prev3_stax		out nocopy number,   -- Bug 8644512
	p_prev3_total_tax	out nocopy number,   -- Bug 8644512
	p_prev4_bus_reg_num	out nocopy varchar2, -- Bug 8644512
	p_prev4_itax		out nocopy number,   -- Bug 8644512
	p_prev4_rtax		out nocopy number,   -- Bug 8644512
	p_prev4_stax		out nocopy number,   -- Bug 8644512
	p_prev4_total_tax	out nocopy number,   -- Bug 8644512
	p_prev5_bus_reg_num	out nocopy varchar2, -- Bug 8644512
	p_prev5_itax		out nocopy number,   -- Bug 8644512
	p_prev5_rtax		out nocopy number,   -- Bug 8644512
	p_prev5_stax		out nocopy number,   -- Bug 8644512
	p_prev5_total_tax	out nocopy number);  -- Bug 8644512

end pay_kr_paykrytr_pkg;

/
