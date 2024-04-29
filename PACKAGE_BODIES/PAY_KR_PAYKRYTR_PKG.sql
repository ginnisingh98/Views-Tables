--------------------------------------------------------
--  DDL for Package Body PAY_KR_PAYKRYTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_PAYKRYTR_PKG" as
/* $Header: paykrytr.pkb 120.22.12010000.20 2010/02/11 11:19:08 pnethaga ship $ */
------------------------------------------------------------------------
procedure data(
	p_assignment_action_id		in number,
	p_person_id			out nocopy number,		-- bug 6012258
	p_resident_type			out nocopy varchar2,
	p_nationality_type		out nocopy varchar2,
	p_fw_fixed_tax_rate		out nocopy varchar2, -- 3546993
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
	p_prev_hire_date1		out nocopy date,   -- Bug 8644512
	p_prev_termination_date1	out nocopy date,   -- Bug 8644512
	p_prev_tax_brk_pd_from1		out nocopy date,   -- Bug 8644512
	p_prev_tax_brk_pd_to1		out nocopy date,   -- Bug 8644512
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
	p_prev_stck_pur_opt_exec_earn2  out nocopy number,   -- Bug 6024342
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
	p_taxable1                      out nocopy number,   -- bug 7615517
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
	p_marr_fun_relo_exem		out nocopy number,       -- bug 3402025
	p_sp_tax_exem			out nocopy number,
	p_std_sp_tax_exem		out nocopy number,
	p_np_prem_tax_exem		out nocopy number,
	p_pension_premium		out nocopy number,	-- Bug 6024342
	p_taxable_income2		out nocopy number,
	p_pers_pension_prem_tax_exem	out nocopy number,
	p_corp_pension_prem_tax_exem	out nocopy number,	 -- Bug 4750653
	p_pers_pension_saving_tax_exem	out nocopy number,
	p_invest_partner_fin_tax_exem	out nocopy number,
	p_credit_card_exp_tax_exem	out nocopy number,
	p_emp_st_own_plan_cont_exem     out nocopy number,
	p_small_bus_install_exem	out nocopy number, 	 -- Bug 6895093
	p_hi_prem			out nocopy number,   	 -- Bug 6895093
        p_ltci_prem                     out nocopy number,       -- Bug 7260606
	p_ei_prem			out nocopy number,   	 -- Bug 6895093
	p_np_prem			out nocopy number,   	 -- Bug 6895093
	p_non_rep_non_taxable		out nocopy number,       -- Bug 9079478
	p_smb_income_exem               out nocopy number,       -- Bug 9079478
	p_taxation_base			out nocopy number,
	p_calc_tax			out nocopy number,
	p_basic_tax_break		out nocopy number,
	p_housing_exp_tax_break		out nocopy number,
	p_stock_saving_tax_break	out nocopy number,
	p_ovs_tax_break			out nocopy number,
	p_don_tax_break			out nocopy number, -- Bug 3966549
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
	p_cash_receipt_expense          out nocopy number,   -- 4289780
	p_emp_ins_exp_nts		out nocopy number,   -- 5190884
	p_emp_tot_ins_exp		out nocopy number,
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
	p_tax_grp_total_ntax_earn out nocopy number,   -- Bug 8644512
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
	p_prev5_total_tax	out nocopy number)   -- Bug 8644512
------------------------------------------------------------------------
is
	l_yea_info	pay_kr_yea_pkg.t_yea_info;
	cursor csr is
		select	hr_ni_chk_pkg.chk_nat_id_format(per.national_identifier, 'DDDDDD-DDDDDDD') NATIONAL_IDENTIFIER,
			per.person_id,                  -- bug 6012258
			pds.date_start,
			pds.actual_termination_date,
			ppa.effective_date
		from	per_people_f	        per,
			per_periods_of_service	pds,
			per_assignments_f	asg,
			pay_payroll_actions	ppa,
			pay_assignment_actions	paa
		where	paa.assignment_action_id = p_assignment_action_id
		and	ppa.payroll_action_id = paa.payroll_action_id
		and	asg.assignment_id = paa.assignment_id
		and	ppa.effective_date
			between asg.effective_start_date and asg.effective_end_date
		and	pds.period_of_service_id = asg.period_of_service_id
		and	per.person_id = pds.person_id
		and	ppa.effective_date
			between per.effective_start_date and per.effective_end_date;
	l_rec	csr%ROWTYPE;

        -- 4289780
        cursor csr_cash_receipt is
        select to_number(pi.aei_information13) "Cash Receipt"
        from per_assignment_extra_info  pi,
             pay_assignment_actions     paa,
             pay_payroll_actions        ppa
        where paa.assignment_action_id    = p_assignment_action_id
        and ppa.payroll_action_id         = paa.payroll_action_id
        and pi.assignment_id              = paa.assignment_id
        and pi.information_type           = 'KR_YEA_TAX_EXEM_INFO'
        and trunc(fnd_date.canonical_to_date(pi.aei_information1), 'YYYY')
                                          = trunc(ppa.effective_date, 'YYYY');

	--5190884
	cursor csr_emp_exp_details is
	select aei_information2 emp_med_exp_nts,
               aei_information3 emp_educ_exp_nts,
               aei_information4 emp_card_exp_nts,
               aei_information5 emp_don_exp_nts,
               aei_information6 emp_ins_exp_nts -- Bug 5667762
	from per_assignment_extra_info pei,
	     pay_assignment_actions    paa,
	     pay_payroll_actions       ppa
	where paa.assignment_action_id   = p_assignment_action_id
	and ppa.payroll_action_id         = paa.payroll_action_id
	and pei.assignment_id             = paa.assignment_id
        and pei.information_type	  = 'KR_YEA_EMP_EXPENSE_DETAILS'
        and trunc(fnd_date.canonical_to_date(pei.aei_information1), 'YYYY')
                                          = trunc(ppa.effective_date, 'YYYY');

	cursor csr_get_emp_exp_amount is
        select nvl(to_number(aei_information18), 0) + nvl(to_number(aei_information19), 0) +
               nvl(to_number(aei_information20), 0) + nvl(to_number(aei_information22), 0) +
	       nvl(to_number(aei_information23), 0) + nvl(to_number(aei_information30), 0)
        from per_assignment_extra_info  pi,
             pay_assignment_actions     paa,
             pay_payroll_actions        ppa
        where paa.assignment_action_id    = p_assignment_action_id
        and ppa.payroll_action_id         = paa.payroll_action_id
        and pi.assignment_id              = paa.assignment_id
        and pi.information_type           = 'KR_YEA_SP_TAX_EXEM_INFO'
        and trunc(fnd_date.canonical_to_date(pi.aei_information1), 'YYYY')
                                          = trunc(ppa.effective_date, 'YYYY');

	cursor csr_get_emp_card_expense is
        select nvl(to_number(aei_information7), 0) + nvl(to_number(aei_information10), 0)
               + nvl(to_number(aei_information12), 0)
        from per_assignment_extra_info  pi,
             pay_assignment_actions     paa,
             pay_payroll_actions        ppa
        where paa.assignment_action_id    = p_assignment_action_id
        and ppa.payroll_action_id         = paa.payroll_action_id
        and pi.assignment_id              = paa.assignment_id
        and pi.information_type           = 'KR_YEA_TAX_EXEM_INFO'
        and trunc(fnd_date.canonical_to_date(pi.aei_information1), 'YYYY')
                                          = trunc(ppa.effective_date, 'YYYY');

	cursor csr_get_emp_don_educ_details is
        select nvl(to_number(aei_information4), 0) +
               nvl(to_number(aei_information5), 0) +
               nvl(to_number(aei_information6), 0) +
               nvl(to_number(aei_information7), 0),
               nvl(to_number(aei_information8), 0),
	       nvl(to_number(aei_information2),0)
        from per_assignment_extra_info  pi,
             pay_assignment_actions     paa,
             pay_payroll_actions        ppa
        where paa.assignment_action_id    = p_assignment_action_id
        and ppa.payroll_action_id         = paa.payroll_action_id
        and pi.assignment_id              = paa.assignment_id
        and pi.information_type           = 'KR_YEA_SP_TAX_EXEM_INFO2'
        and trunc(fnd_date.canonical_to_date(pi.aei_information1), 'YYYY')
                                          = trunc(ppa.effective_date, 'YYYY');

        -- Bug 5726158
	cursor csr_asg_details is
	 select paa.assignment_id, ppa.effective_date
	   from pay_payroll_actions ppa,
	        pay_assignment_actions paa
	  where paa.assignment_action_id = p_assignment_action_id
	    and ppa.payroll_action_id = paa.payroll_action_id;
	--
	l_asg_details csr_asg_details%rowtype;
	--
	cursor csr_get_dpnt_cash_exp(p_assignment_id number, p_effective_date date) is
	select sum(nvl(to_number(cei.cei_information9),0))
	 from pay_kr_cont_details_v      pkc,
              per_contact_extra_info_f   cei    -- Bug 5879106
	where pkc.assignment_id        = p_assignment_id
          and p_effective_date between emp_start_date and emp_end_date
          and p_effective_date between cont_start_date and cont_end_date
	  and cei.information_type(+) = 'KR_DPNT_EXPENSE_INFO'
	  and cei.contact_relationship_id(+) = pkc.contact_relationship_id
	  and to_char(cei.effective_start_date(+), 'YYYY') = to_char(p_effective_date, 'YYYY')
	  and  p_effective_date between nvl(ADDRESS_START_DATE, p_effective_date) and nvl(ADDRESS_END_DATE, p_effective_date)
	  and  p_effective_date between nvl(pkc.date_start, p_effective_date)
			     and decode(pkc.cont_information9, 'D', trunc(add_months(nvl(pkc.date_end, p_effective_date),12),'YYYY')-1, nvl(pkc.date_end, p_effective_date) )
	  and  pay_kr_ff_functions_pkg.is_exempted_dependent(   pkc.contact_type,
								pkc.cont_information11,  -- Bug 7661820
								pkc.national_identifier,
								pkc.cont_information2,
								pkc.cont_information3,
								pkc.cont_information4,
								pkc.cont_information7,
								pkc.cont_information8,
								p_effective_date,
								pkc.cont_information10,
								pkc.cont_information12,
								pkc.cont_information13,
								pkc.cont_information14,
								cei.contact_extra_info_id(+)
	    					             ) = 'Y';
l_emp_ins_exp_nts	NUMBER := 0;
l_emp_med_exp_nts	NUMBER := 0;
l_emp_educ_exp_nts	NUMBER := 0;
l_emp_card_exp_nts	NUMBER := 0;
l_emp_don_exp_nts	NUMBER := 0;
l_card_expense_total	NUMBER := 0;
--Bug 5308995
l_don_amount1		NUMBER := 0;
l_don_amount2		NUMBER := 0;
l_don_tax_break2004	NUMBER := 0;
l_emp_occu_trng		NUMBER := 0;
l_dpnt_cash_exp		NUMBER := 0;
l_emp_cash_exp          NUMBER := 0; -- Bug 5726158
l_dpnt_don_total	NUMBER := 0; -- Bug 7142612
l_period_start_date     DATE;
l_period_end_date       DATE;

begin
	open csr;
	fetch csr into l_rec;
	close csr;

	-- 4289780
	open csr_cash_receipt;
	fetch csr_cash_receipt into l_emp_cash_exp;
	close csr_cash_receipt;

	-- 5190884
	--
	-- Retrieve all the Employee Expense Details
	--
	open csr_emp_exp_details;
	fetch csr_emp_exp_details into  l_emp_med_exp_nts,
					l_emp_educ_exp_nts,
					l_emp_card_exp_nts,
					l_emp_don_exp_nts,
					l_emp_ins_exp_nts;
	open csr_get_emp_exp_amount;
	fetch csr_get_emp_exp_amount into l_don_amount1;
	close csr_get_emp_exp_amount;
	--
	open csr_get_emp_card_expense;
	fetch csr_get_emp_card_expense into l_card_expense_total;
	close csr_get_emp_card_expense;
	--
	open csr_get_emp_don_educ_details;
	fetch csr_get_emp_don_educ_details into l_don_amount2,l_dpnt_don_total,l_emp_occu_trng;
	close csr_get_emp_don_educ_details;

	-- Bug 5726158
	open csr_asg_details;
	fetch csr_asg_details into l_asg_details;
	close csr_asg_details;

	open csr_get_dpnt_cash_exp(l_asg_details.assignment_id, l_asg_details.effective_date);
	fetch csr_get_dpnt_cash_exp into l_dpnt_cash_exp;
	close csr_get_dpnt_cash_exp;

	p_cash_receipt_expense := nvl(l_emp_cash_exp,0) + nvl(l_dpnt_cash_exp,0);

	--
	-- Derive YEA results
	--
	l_yea_info := pay_kr_yea_pkg.yea_info(p_assignment_action_id);
	--
	-- Employee Basic Information
	--
	if l_yea_info.non_resident_flag = 'Y' then
		p_resident_type := 'N';
	else
		p_resident_type := 'R';
	end if;
	/* Bug 6779649: New logic for Korean/Foreigner Identification */
	if ((substr(l_rec.national_identifier, 8, 1) between 5 and 8) or (l_yea_info.foreign_residency_flag = 'Y')) then
		p_nationality_type := 'F';
	else
		p_nationality_type := 'K';
	end if;
	p_fwtb_contract_date	:= l_yea_info.fwtb_contract_date;
	p_fwtb_expiry_date	:= l_yea_info.fwtb_expiry_date;

        -- Foreign worket fixed tax rate
        --
	if l_yea_info.fixed_tax_rate = 'Y' then
		p_fw_fixed_tax_rate := 'Y';
	else
		p_fw_fixed_tax_rate := 'N';
	end if;

	--
	-- Taxable Earnings
	--
	p_cur_taxable_mth	:= l_yea_info.cur_taxable_mth;
	p_cur_taxable_bon	:= l_yea_info.cur_taxable_bon;
	p_cur_sp_irreg_bonus	:= l_yea_info.cur_sp_irreg_bonus;
	p_cur_stck_pur_opt_exec_earn := l_yea_info.cur_stck_pur_opt_exec_earn;	-- Bug 6012258
	p_cur_esop_withd_earn	:= l_yea_info.cur_esop_withd_earn;		-- Bug 8644512
	p_cur_taxable		:= l_yea_info.cur_taxable;
	p_cur_non_taxable_ovt	:= l_yea_info.cur_non_taxable_ovt;	-- Bug 8644512
	p_cur_birth_raising_allowance	:= l_yea_info.cur_birth_raising_allowance;	-- Bug 8644512
	p_cur_fw_income_exem	:= l_yea_info.cur_fw_income_exem;	-- Bug 8644512
	--
	-- Previous Employers' Information
	--
	for i in 1..l_yea_info.prev_termination_date_tbl.count loop
		if l_yea_info.prev_bp_number_tbl(i) = '0' then
			fnd_message.set_encoded('Invalid Business Registration Number for Previous Employer');
			fnd_message.raise_error;
		end if;
		--
		if i = 1 then
			-- Bug 8644512
			p_prev1_bus_reg_num	:= l_yea_info.prev_bp_number_tbl(i);
			p_prev1_itax		:= l_yea_info.prev_itax_tbl(i);
			p_prev1_rtax		:= l_yea_info.prev_rtax_tbl(i);
			p_prev1_stax		:= l_yea_info.prev_stax_tbl(i);
			p_prev1_total_tax	:= nvl(p_prev1_itax,0) + nvl(p_prev1_rtax,0) + nvl(p_prev1_stax,0);
			--
			p_prev_corp_name1	:= l_yea_info.prev_corp_name_tbl(i);
			p_prev_bp_number1	:= l_yea_info.prev_bp_number_tbl(i);
			-- Bug 8644512
			p_prev_hire_date1	:= l_yea_info.prev_hire_date_tbl(i);
			p_prev_termination_date1:= l_yea_info.prev_termination_date_tbl(i);
			p_prev_tax_brk_pd_from1	:= l_yea_info.prev_tax_brk_pd_from_tbl(i);
			p_prev_tax_brk_pd_to1	:= l_yea_info.prev_tax_brk_pd_to_tbl(i);
			--
			p_prev_taxable_mth1	:= l_yea_info.prev_taxable_mth_tbl(i);
			p_prev_taxable_bon1	:= l_yea_info.prev_taxable_bon_tbl(i);
			p_prev_sp_irreg_bonus1	:= l_yea_info.prev_sp_irreg_bonus_tbl(i);
			p_prev_stck_pur_opt_exec_earn1 := l_yea_info.prev_stck_pur_opt_exe_earn_tbl(i);  -- Bug 6024342
			p_prev_esop_withd_earn1	:= l_yea_info.prev_esop_withd_earn_tbl(i); -- Bug 8644512
			p_prev_taxable1		:= l_yea_info.prev_taxable_mth_tbl(i)
						+  l_yea_info.prev_taxable_bon_tbl(i)
						+  l_yea_info.prev_sp_irreg_bonus_tbl(i)
						+  l_yea_info.prev_stck_pur_opt_exe_earn_tbl(i)
						+  l_yea_info.prev_esop_withd_earn_tbl(i); -- Bug 8644512
			p_prev_non_taxable_ovt1	:= l_yea_info.prev_non_taxable_ovt_tbl(i); -- Bug 8644512
			p_prev_bir_raising_allw1:= l_yea_info.prev_bir_raising_allowance_tbl(i); -- Bug 8644512
			p_prev_fw_income_exem1	:= l_yea_info.prev_foreign_wrkr_inc_exem_tbl(i); -- Bug 8644512
			--
			-- Bug 8644512
			--
			p_prev1_ntax_G01	:= l_yea_info.prev_ntax_G01_tbl(i);
			p_prev1_ntax_H01	:= l_yea_info.prev_ntax_H01_tbl(i);
			p_prev1_ntax_H05	:= l_yea_info.prev_ntax_H05_tbl(i);
			p_prev1_ntax_H06	:= l_yea_info.prev_ntax_H06_tbl(i);
			p_prev1_ntax_H07	:= l_yea_info.prev_ntax_H07_tbl(i);
			p_prev1_ntax_H08	:= l_yea_info.prev_ntax_H08_tbl(i);
			p_prev1_ntax_H09	:= l_yea_info.prev_ntax_H09_tbl(i);
			p_prev1_ntax_H10	:= l_yea_info.prev_ntax_H10_tbl(i);
			p_prev1_ntax_H11	:= l_yea_info.prev_ntax_H11_tbl(i);
			p_prev1_ntax_H12	:= l_yea_info.prev_ntax_H12_tbl(i);
			p_prev1_ntax_H13	:= l_yea_info.prev_ntax_H13_tbl(i);
			p_prev1_ntax_I01	:= l_yea_info.prev_ntax_I01_tbl(i);
			p_prev1_ntax_K01	:= l_yea_info.prev_ntax_K01_tbl(i);
			p_prev1_ntax_M01	:= l_yea_info.prev_ntax_M01_tbl(i);
			p_prev1_ntax_M02	:= l_yea_info.prev_ntax_M02_tbl(i);
			p_prev1_ntax_M03	:= l_yea_info.prev_ntax_M03_tbl(i);
			p_prev1_ntax_S01	:= l_yea_info.prev_ntax_S01_tbl(i);
			p_prev1_ntax_T01	:= l_yea_info.prev_ntax_T01_tbl(i);
			p_prev1_ntax_Y01	:= l_yea_info.prev_ntax_Y01_tbl(i);
			p_prev1_ntax_Y02	:= l_yea_info.prev_ntax_Y02_tbl(i);
			p_prev1_ntax_Y03	:= l_yea_info.prev_ntax_Y03_tbl(i);
			p_prev1_ntax_Y20	:= l_yea_info.prev_ntax_Y20_tbl(i);
			p_prev1_ntax_Z01	:= l_yea_info.prev_ntax_Z01_tbl(i);
			--
			p_prev1_total_ntax_earn	:= p_prev1_ntax_G01
						+ p_prev1_ntax_H01
						+ p_prev1_ntax_H05
						+ p_prev1_ntax_H06
						+ p_prev1_ntax_H07
						+ p_prev1_ntax_H08
						+ p_prev1_ntax_H09
						+ p_prev1_ntax_H10
						+ p_prev1_ntax_H11
						+ p_prev1_ntax_H12
						+ p_prev1_ntax_H13
						+ p_prev1_ntax_I01
						+ p_prev1_ntax_K01
						+ p_prev1_ntax_M01
						+ p_prev1_ntax_M02
						+ p_prev1_ntax_M03
						+ p_prev1_ntax_S01
						+ p_prev1_ntax_T01
						+ p_prev1_ntax_Y01
						+ p_prev1_ntax_Y02
						+ p_prev1_ntax_Y03
						+ p_prev1_ntax_Y20
						+ p_prev1_ntax_Z01
						+ p_prev_non_taxable_ovt1
						+ p_prev_bir_raising_allw1
						+ p_prev_fw_income_exem1;

		else
			if i = 2 then
				-- Bug 8644512
				if nvl(p_prev1_total_tax,0) > 0 then
				p_prev2_bus_reg_num	:= l_yea_info.prev_bp_number_tbl(i);
				p_prev2_itax		:= l_yea_info.prev_itax_tbl(i);
				p_prev2_rtax		:= l_yea_info.prev_rtax_tbl(i);
				p_prev2_stax		:= l_yea_info.prev_stax_tbl(i);
				p_prev2_total_tax	:= nvl(p_prev2_itax,0) + nvl(p_prev2_rtax,0) + nvl(p_prev2_stax,0);
				else
				p_prev1_bus_reg_num	:= l_yea_info.prev_bp_number_tbl(i);
				p_prev1_itax		:= l_yea_info.prev_itax_tbl(i);
				p_prev1_rtax		:= l_yea_info.prev_rtax_tbl(i);
				p_prev1_stax		:= l_yea_info.prev_stax_tbl(i);
				p_prev1_total_tax	:= nvl(p_prev1_itax,0) + nvl(p_prev1_rtax,0) + nvl(p_prev1_stax,0);
				end if;
				--
				p_prev_corp_name2	:= l_yea_info.prev_corp_name_tbl(i);
				p_prev_bp_number2	:= l_yea_info.prev_bp_number_tbl(i);
				p_prev_hire_date2	:= l_yea_info.prev_hire_date_tbl(i);
				p_prev_termination_date2:= l_yea_info.prev_termination_date_tbl(i);
				p_prev_tax_brk_pd_from2	:= l_yea_info.prev_tax_brk_pd_from_tbl(i);
				p_prev_tax_brk_pd_to2	:= l_yea_info.prev_tax_brk_pd_to_tbl(i);
			end if;
			if i = 3 then
				-- Bug 8644512
				if nvl(p_prev1_total_tax,0) > 0 then
				   if nvl(p_prev2_total_tax,0) > 0 then
					p_prev3_bus_reg_num	:= l_yea_info.prev_bp_number_tbl(i);
					p_prev3_itax		:= l_yea_info.prev_itax_tbl(i);
					p_prev3_rtax		:= l_yea_info.prev_rtax_tbl(i);
					p_prev3_stax		:= l_yea_info.prev_stax_tbl(i);
					p_prev3_total_tax	:= nvl(p_prev3_itax,0) + nvl(p_prev3_rtax,0) + nvl(p_prev3_stax,0);
					--
				   else
					p_prev2_bus_reg_num	:= l_yea_info.prev_bp_number_tbl(i);
					p_prev2_itax		:= l_yea_info.prev_itax_tbl(i);
					p_prev2_rtax		:= l_yea_info.prev_rtax_tbl(i);
					p_prev2_stax		:= l_yea_info.prev_stax_tbl(i);
					p_prev2_total_tax	:= nvl(p_prev2_itax,0) + nvl(p_prev2_rtax,0) + nvl(p_prev2_stax,0);
				   end if;
				else
					p_prev1_bus_reg_num	:= l_yea_info.prev_bp_number_tbl(i);
					p_prev1_itax		:= l_yea_info.prev_itax_tbl(i);
					p_prev1_rtax		:= l_yea_info.prev_rtax_tbl(i);
					p_prev1_stax		:= l_yea_info.prev_stax_tbl(i);
					p_prev1_total_tax	:= nvl(p_prev1_itax,0) + nvl(p_prev1_rtax,0) + nvl(p_prev1_stax,0);
				end if;
			end if;
			if i = 4 then
				-- Bug 8644512
				if nvl(p_prev1_total_tax,0) > 0 then
				   if nvl(p_prev2_total_tax,0) > 0 then
				      if nvl(p_prev3_total_tax,0) > 0 then
					p_prev4_bus_reg_num	:= l_yea_info.prev_bp_number_tbl(i);
					p_prev4_itax		:= l_yea_info.prev_itax_tbl(i);
					p_prev4_rtax		:= l_yea_info.prev_rtax_tbl(i);
					p_prev4_stax		:= l_yea_info.prev_stax_tbl(i);
					p_prev4_total_tax	:= nvl(p_prev4_itax,0) + nvl(p_prev4_rtax,0) + nvl(p_prev4_stax,0);
				      else
					p_prev3_bus_reg_num	:= l_yea_info.prev_bp_number_tbl(i);
					p_prev3_itax		:= l_yea_info.prev_itax_tbl(i);
					p_prev3_rtax		:= l_yea_info.prev_rtax_tbl(i);
					p_prev3_stax		:= l_yea_info.prev_stax_tbl(i);
					p_prev3_total_tax	:= nvl(p_prev3_itax,0) + nvl(p_prev3_rtax,0) + nvl(p_prev3_stax,0);
					--
				      end if;
				   else
					p_prev2_bus_reg_num	:= l_yea_info.prev_bp_number_tbl(i);
					p_prev2_itax		:= l_yea_info.prev_itax_tbl(i);
					p_prev2_rtax		:= l_yea_info.prev_rtax_tbl(i);
					p_prev2_stax		:= l_yea_info.prev_stax_tbl(i);
					p_prev2_total_tax	:= nvl(p_prev2_itax,0) + nvl(p_prev2_rtax,0) + nvl(p_prev2_stax,0);
				   end if;
				else
					p_prev1_bus_reg_num	:= l_yea_info.prev_bp_number_tbl(i);
					p_prev1_itax		:= l_yea_info.prev_itax_tbl(i);
					p_prev1_rtax		:= l_yea_info.prev_rtax_tbl(i);
					p_prev1_stax		:= l_yea_info.prev_stax_tbl(i);
					p_prev1_total_tax	:= nvl(p_prev1_itax,0) + nvl(p_prev1_rtax,0) + nvl(p_prev1_stax,0);
				end if;
				--
			end if;
			p_prev_taxable_mth2	:= nvl(p_prev_taxable_mth2, 0) + l_yea_info.prev_taxable_mth_tbl(i);
			p_prev_taxable_bon2	:= nvl(p_prev_taxable_bon2, 0) + l_yea_info.prev_taxable_bon_tbl(i);
			p_prev_sp_irreg_bonus2	:= nvl(p_prev_sp_irreg_bonus2, 0) + l_yea_info.prev_sp_irreg_bonus_tbl(i);
			p_prev_stck_pur_opt_exec_earn2 :=nvl(p_prev_stck_pur_opt_exec_earn2, 0)
    							 + l_yea_info.prev_stck_pur_opt_exe_earn_tbl(i);  -- Bug 6024342
			p_prev_esop_withd_earn2	:= nvl(p_prev_esop_withd_earn2,0)
						 + l_yea_info.prev_esop_withd_earn_tbl(i); -- Bug 8644512
			p_prev_taxable2		:= nvl(p_prev_taxable2, 0) + l_yea_info.prev_taxable_mth_tbl(i)
									   + l_yea_info.prev_taxable_bon_tbl(i)
									   + l_yea_info.prev_sp_irreg_bonus_tbl(i)
									   + l_yea_info.prev_stck_pur_opt_exe_earn_tbl(i)
									   + l_yea_info.prev_esop_withd_earn_tbl(i); -- Bug 8644512
			p_prev_non_taxable_ovt2	:= nvl(p_prev_non_taxable_ovt2,0)
						+ l_yea_info.prev_non_taxable_ovt_tbl(i); -- Bug 8644512
			p_prev_bir_raising_allw2:= nvl(p_prev_bir_raising_allw2,0)
						+ l_yea_info.prev_bir_raising_allowance_tbl(i); -- Bug 8644512
			p_prev_fw_income_exem2	:= nvl(p_prev_fw_income_exem2,0)
						+ l_yea_info.prev_foreign_wrkr_inc_exem_tbl(i); -- Bug 8644512
			--
			-- Bug 8644512
			--
			p_prev2_ntax_G01	:= nvl(p_prev2_ntax_G01,0) + l_yea_info.prev_ntax_G01_tbl(i);
			p_prev2_ntax_H01	:= nvl(p_prev2_ntax_H01,0) + l_yea_info.prev_ntax_H01_tbl(i);
			p_prev2_ntax_H05	:= nvl(p_prev2_ntax_H05,0) + l_yea_info.prev_ntax_H05_tbl(i);
			p_prev2_ntax_H06	:= nvl(p_prev2_ntax_H06,0) + l_yea_info.prev_ntax_H06_tbl(i);
			p_prev2_ntax_H07	:= nvl(p_prev2_ntax_H07,0) + l_yea_info.prev_ntax_H07_tbl(i);
			p_prev2_ntax_H08	:= nvl(p_prev2_ntax_H08,0) + l_yea_info.prev_ntax_H08_tbl(i);
			p_prev2_ntax_H09	:= nvl(p_prev2_ntax_H09,0) + l_yea_info.prev_ntax_H09_tbl(i);
			p_prev2_ntax_H10	:= nvl(p_prev2_ntax_H10,0) + l_yea_info.prev_ntax_H10_tbl(i);
			p_prev2_ntax_H11	:= nvl(p_prev2_ntax_H11,0) + l_yea_info.prev_ntax_H11_tbl(i);
			p_prev2_ntax_H12	:= nvl(p_prev2_ntax_H12,0) + l_yea_info.prev_ntax_H12_tbl(i);
			p_prev2_ntax_H13	:= nvl(p_prev2_ntax_H13,0) + l_yea_info.prev_ntax_H13_tbl(i);
			p_prev2_ntax_I01	:= nvl(p_prev2_ntax_I01,0) + l_yea_info.prev_ntax_I01_tbl(i);
			p_prev2_ntax_K01	:= nvl(p_prev2_ntax_K01,0) + l_yea_info.prev_ntax_K01_tbl(i);
			p_prev2_ntax_M01	:= nvl(p_prev2_ntax_M01,0) + l_yea_info.prev_ntax_M01_tbl(i);
			p_prev2_ntax_M02	:= nvl(p_prev2_ntax_M02,0) + l_yea_info.prev_ntax_M02_tbl(i);
			p_prev2_ntax_M03	:= nvl(p_prev2_ntax_M03,0) + l_yea_info.prev_ntax_M03_tbl(i);
			p_prev2_ntax_S01	:= nvl(p_prev2_ntax_S01,0) + l_yea_info.prev_ntax_S01_tbl(i);
			p_prev2_ntax_T01	:= nvl(p_prev2_ntax_T01,0) + l_yea_info.prev_ntax_T01_tbl(i);
			p_prev2_ntax_Y01	:= nvl(p_prev2_ntax_Y01,0) + l_yea_info.prev_ntax_Y01_tbl(i);
			p_prev2_ntax_Y02	:= nvl(p_prev2_ntax_Y02,0) + l_yea_info.prev_ntax_Y02_tbl(i);
			p_prev2_ntax_Y03	:= nvl(p_prev2_ntax_Y03,0) + l_yea_info.prev_ntax_Y03_tbl(i);
			p_prev2_ntax_Y20	:= nvl(p_prev2_ntax_Y20,0) + l_yea_info.prev_ntax_Y20_tbl(i);
			p_prev2_ntax_Z01	:= nvl(p_prev2_ntax_Z01,0) + l_yea_info.prev_ntax_Z01_tbl(i);
			--
			p_prev2_total_ntax_earn	:= p_prev2_ntax_G01
						+ p_prev2_ntax_H01
						+ p_prev2_ntax_H05
						+ p_prev2_ntax_H06
						+ p_prev2_ntax_H07
						+ p_prev2_ntax_H08
						+ p_prev2_ntax_H09
						+ p_prev2_ntax_H10
						+ p_prev2_ntax_H11
						+ p_prev2_ntax_H12
						+ p_prev2_ntax_H13
						+ p_prev2_ntax_I01
						+ p_prev2_ntax_K01
						+ p_prev2_ntax_M01
						+ p_prev2_ntax_M02
						+ p_prev2_ntax_M03
						+ p_prev2_ntax_S01
						+ p_prev2_ntax_T01
						+ p_prev2_ntax_Y01
						+ p_prev2_ntax_Y02
						+ p_prev2_ntax_Y03
						+ p_prev2_ntax_Y20
						+ p_prev2_ntax_Z01
						+ p_prev_non_taxable_ovt2
						+ p_prev_bir_raising_allw2
						+ p_prev_fw_income_exem2;
			--
		end if;
	end loop;
	--
	--------------------------------------------------------------------------------------
	-- Bug 7361372: Type B Tax Group Information
	--------------------------------------------------------------------------------------
	if l_yea_info.tax_grp_bus_reg_num is not null then
		p_tax_grp_bus_reg_num 			:= l_yea_info.tax_grp_bus_reg_num;
        	p_tax_grp_name   			:= l_yea_info.tax_grp_name;
		-- Bug 8644512
		p_tax_grp_wkpd_from			:= l_yea_info.tax_grp_wkpd_from;
		p_tax_grp_wkpd_to			:= l_yea_info.tax_grp_wkpd_to;
		p_tax_grp_tax_brk_pd_from		:= l_yea_info.tax_grp_tax_brk_pd_from;
		p_tax_grp_tax_brk_pd_to			:= l_yea_info.tax_grp_tax_brk_pd_to;
		--
		-- Bug 7508706
        	p_tax_grp_taxable_mth  	     := nvl(l_yea_info.tax_grp_taxable_mth,0) + nvl(l_yea_info.tax_grp_taxable_mth_ne,0);
        	p_tax_grp_taxable_bon  	     := nvl(l_yea_info.tax_grp_taxable_bon,0) + nvl(l_yea_info.tax_grp_taxable_bon_ne,0);
        	p_tax_grp_sp_irreg_bonus     := nvl(l_yea_info.tax_grp_sp_irreg_bonus,0) + nvl(l_yea_info.tax_grp_sp_irreg_bonus_ne,0);
        	p_tax_stck_pur_opt_exec_earn := nvl(l_yea_info.tax_grp_stck_pur_opt_exec_earn,0) + nvl(l_yea_info.tax_grp_stck_pur_ne,0);
		--  Bug 8644512
		p_tax_grp_esop_withd_earn    := nvl(l_yea_info.tax_grp_esop_withd_earn,0) + nvl(l_yea_info.tax_grp_esop_withd_earn_ne,0);
		--
        	p_tax_grp_taxable    	     := nvl(l_yea_info.tax_grp_taxable,0) + nvl(l_yea_info.tax_grp_taxable_ne,0);
		-- End of Bug 7508706
		-- Bug 8644512
		p_tax_grp_non_taxable_ovt	:= l_yea_info.tax_grp_non_taxable_ovt;	-- Bug 8644512
		p_tax_grp_bir_raising_allw	:= l_yea_info.tax_grp_bir_raising_allw;	-- Bug 8644512
		p_tax_grp_fw_income_exem	:= l_yea_info.tax_grp_fw_income_exem;	-- Bug 8644512
		--
		p_tax_grp_ntax_G01		:= l_yea_info.tax_grp_ntax_G01;
		p_tax_grp_ntax_H01		:= l_yea_info.tax_grp_ntax_H01;
		p_tax_grp_ntax_H05		:= l_yea_info.tax_grp_ntax_H05;
		p_tax_grp_ntax_H06		:= l_yea_info.tax_grp_ntax_H06;
		p_tax_grp_ntax_H07		:= l_yea_info.tax_grp_ntax_H07;
		p_tax_grp_ntax_H08		:= l_yea_info.tax_grp_ntax_H08;
		p_tax_grp_ntax_H09		:= l_yea_info.tax_grp_ntax_H09;
		p_tax_grp_ntax_H10		:= l_yea_info.tax_grp_ntax_H10;
		p_tax_grp_ntax_H11		:= l_yea_info.tax_grp_ntax_H11;
		p_tax_grp_ntax_H12		:= l_yea_info.tax_grp_ntax_H12;
		p_tax_grp_ntax_H13		:= l_yea_info.tax_grp_ntax_H13;
		p_tax_grp_ntax_I01		:= l_yea_info.tax_grp_ntax_I01;
		p_tax_grp_ntax_K01		:= l_yea_info.tax_grp_ntax_K01;
		p_tax_grp_ntax_M01		:= l_yea_info.tax_grp_ntax_M01;
		p_tax_grp_ntax_M02		:= l_yea_info.tax_grp_ntax_M02;
		p_tax_grp_ntax_M03		:= l_yea_info.tax_grp_ntax_M03;
		p_tax_grp_ntax_S01		:= l_yea_info.tax_grp_ntax_S01;
		p_tax_grp_ntax_T01		:= l_yea_info.tax_grp_ntax_T01;
		p_tax_grp_ntax_Y01		:= l_yea_info.tax_grp_ntax_Y01;
		p_tax_grp_ntax_Y02		:= l_yea_info.tax_grp_ntax_Y02;
		p_tax_grp_ntax_Y03		:= l_yea_info.tax_grp_ntax_Y03;
		p_tax_grp_ntax_Y20		:= l_yea_info.tax_grp_ntax_Y20;
		p_tax_grp_ntax_Z01		:= l_yea_info.tax_grp_ntax_Z01;
		--
		p_tax_grp_total_ntax_earn	:= l_yea_info.tax_grp_total_ntax_earn;
		--
	end if;
        	p_tax_grp_post_tax_deduc 	:= l_yea_info.tax_grp_post_tax_deduc;
	-- End of Bug 7361372
	--------------------------------------------------------------------------------------
	-- Bug 6012258
	p_research_payment	  := l_yea_info.research_payment;
	p_person_id 		  := l_rec.person_id;
	--
	p_birth_raising_allowance := l_yea_info.birth_raising_allowance; -- Bug 7142620
	p_taxable_mth		  := l_yea_info.taxable_mth;
	p_taxable_bon		  := l_yea_info.taxable_bon;
	p_sp_irreg_bonus	  := l_yea_info.sp_irreg_bonus;
	p_stck_pur_opt_exec_earn  := l_yea_info.stck_pur_opt_exec_earn;
	p_esop_withd_earn	  := l_yea_info.esop_withd_earn;	-- Bug 8644512
	p_taxable		  := l_yea_info.taxable;
	p_taxable1                := l_yea_info.taxable1; -- Bug 7615517
	--
	--
	-- Non-taxable Earnings
	--
	-- Bug 8644512
	--
	p_total_ntax_G01	:= l_yea_info.total_ntax_G01;
	p_total_ntax_H01	:= l_yea_info.total_ntax_H01;
	p_total_ntax_H05	:= l_yea_info.total_ntax_H05;
	p_total_ntax_H06	:= l_yea_info.total_ntax_H06;
	p_total_ntax_H07	:= l_yea_info.total_ntax_H07;
	p_total_ntax_H08	:= l_yea_info.total_ntax_H08;
	p_total_ntax_H09	:= l_yea_info.total_ntax_H09;
	p_total_ntax_H10	:= l_yea_info.total_ntax_H10;
	p_total_ntax_H11	:= l_yea_info.total_ntax_H11;
	p_total_ntax_H12	:= l_yea_info.total_ntax_H12;
	p_total_ntax_H13	:= l_yea_info.total_ntax_H13;
	p_total_ntax_I01	:= l_yea_info.total_ntax_I01;
	p_total_ntax_K01	:= l_yea_info.total_ntax_K01;
	p_total_ntax_M01	:= l_yea_info.total_ntax_M01;
	p_total_ntax_M02	:= l_yea_info.total_ntax_M02;
	p_total_ntax_M03	:= l_yea_info.total_ntax_M03;
	p_total_ntax_S01	:= l_yea_info.total_ntax_S01;
	p_total_ntax_T01	:= l_yea_info.total_ntax_T01;
	p_total_ntax_Y01	:= l_yea_info.total_ntax_Y01;
	p_total_ntax_Y02	:= l_yea_info.total_ntax_Y02;
	p_total_ntax_Y03	:= l_yea_info.total_ntax_Y03;
	p_total_ntax_Y20	:= l_yea_info.total_ntax_Y20;
	p_total_ntax_Z01	:= l_yea_info.total_ntax_Z01;
	--
	p_cur_ntax_G01		:= l_yea_info.cur_ntax_G01;
	p_cur_ntax_H01		:= l_yea_info.cur_ntax_H01;
	p_cur_ntax_H05		:= l_yea_info.cur_ntax_H05;
	p_cur_ntax_H06		:= l_yea_info.cur_ntax_H06;
	p_cur_ntax_H07		:= l_yea_info.cur_ntax_H07;
	p_cur_ntax_H08		:= l_yea_info.cur_ntax_H08;
	p_cur_ntax_H09		:= l_yea_info.cur_ntax_H09;
	p_cur_ntax_H10		:= l_yea_info.cur_ntax_H10;
	p_cur_ntax_H11		:= l_yea_info.cur_ntax_H11;
	p_cur_ntax_H12		:= l_yea_info.cur_ntax_H12;
	p_cur_ntax_H13		:= l_yea_info.cur_ntax_H13;
	p_cur_ntax_I01		:= l_yea_info.cur_ntax_I01;
	p_cur_ntax_K01		:= l_yea_info.cur_ntax_K01;
	p_cur_ntax_M01		:= l_yea_info.cur_ntax_M01 + l_yea_info.cur_ntax_frgn_M01 ;
	p_cur_ntax_M02		:= l_yea_info.cur_ntax_M02 + l_yea_info.cur_ntax_frgn_M02;
	p_cur_ntax_M03		:= l_yea_info.cur_ntax_M03 + l_yea_info.cur_ntax_frgn_M03;
	p_cur_ntax_S01		:= l_yea_info.cur_ntax_S01;
	p_cur_ntax_T01		:= l_yea_info.cur_ntax_T01;
	p_cur_ntax_Y01		:= l_yea_info.cur_ntax_Y01;
	p_cur_ntax_Y02		:= l_yea_info.cur_ntax_Y02;
	p_cur_ntax_Y03		:= l_yea_info.cur_ntax_Y03;
	p_cur_ntax_Y20		:= l_yea_info.cur_ntax_Y20;
	p_cur_ntax_Z01		:= l_yea_info.cur_ntax_Z01;
	--
	p_cur_total_ntax_earn 	:= l_yea_info.cur_total_ntax_earn;
	--
	if nvl(p_prev1_total_tax,0) > 0 then
	   if nvl(p_prev2_total_tax,0) > 0 then
	      if nvl(p_prev3_total_tax,0) > 0 then
	         if nvl(p_prev4_total_tax,0) > 0 then
		    p_prev5_bus_reg_num	:= l_yea_info.tax_grp_bus_reg_num;
	            p_prev5_itax	:= l_yea_info.tax_grp_itax;
	            p_prev5_rtax	:= l_yea_info.tax_grp_rtax;
	            p_prev5_stax	:= l_yea_info.tax_grp_stax;
	            p_prev5_total_tax	:= nvl(p_prev5_itax,0) + nvl(p_prev5_rtax,0) + nvl(p_prev5_stax,0);
		 else
		    p_prev4_bus_reg_num	:= l_yea_info.tax_grp_bus_reg_num;
	            p_prev4_itax	:= l_yea_info.tax_grp_itax;
	            p_prev4_rtax	:= l_yea_info.tax_grp_rtax;
	            p_prev4_stax	:= l_yea_info.tax_grp_stax;
	            p_prev4_total_tax	:= nvl(p_prev4_itax,0) + nvl(p_prev4_rtax,0) + nvl(p_prev4_stax,0);
		 end if;
	      else
		    p_prev3_bus_reg_num	:= l_yea_info.tax_grp_bus_reg_num;
	            p_prev3_itax	:= l_yea_info.tax_grp_itax;
	            p_prev3_rtax	:= l_yea_info.tax_grp_rtax;
	            p_prev3_stax	:= l_yea_info.tax_grp_stax;
	            p_prev3_total_tax	:= nvl(p_prev3_itax,0) + nvl(p_prev3_rtax,0) + nvl(p_prev3_stax,0);
	      end if;
	   else
		    p_prev2_bus_reg_num	:= l_yea_info.tax_grp_bus_reg_num;
	            p_prev2_itax	:= l_yea_info.tax_grp_itax;
	            p_prev2_rtax	:= l_yea_info.tax_grp_rtax;
	            p_prev2_stax	:= l_yea_info.tax_grp_stax;
	            p_prev2_total_tax	:= nvl(p_prev2_itax,0) + nvl(p_prev2_rtax,0) + nvl(p_prev2_stax,0);
           end if;
	else
		    p_prev1_bus_reg_num	:= l_yea_info.tax_grp_bus_reg_num;
	            p_prev1_itax	:= l_yea_info.tax_grp_itax;
	            p_prev1_rtax	:= l_yea_info.tax_grp_rtax;
	            p_prev1_stax	:= l_yea_info.tax_grp_stax;
	            p_prev1_total_tax	:= nvl(p_prev1_itax,0) + nvl(p_prev1_rtax,0) + nvl(p_prev1_stax,0);
        end if;
	--
	p_non_taxable_ovs	:= l_yea_info.non_taxable_ovs + l_yea_info.non_taxable_ovs_frgn; -- Bug 7439803
	p_non_taxable_ovt	:= l_yea_info.non_taxable_ovt;
	p_non_taxable_oth	:= l_yea_info.non_taxable_oth;
	p_non_taxable		:= l_yea_info.non_taxable;

        -- Bug 9336934
	--
	l_period_start_date	:= trunc(l_rec.effective_date, 'YYYY');
	l_period_end_date	:= add_months(l_period_start_date, 12) - 1;
        p_period_start_date     := l_period_start_date;
	p_period_end_date       := l_period_end_date;
	p_period_start_date	:= greatest(p_period_start_date, l_rec.date_start);
	-- Bug 8644512
	p_emp_start_date	:= l_rec.date_start;
	--
	if l_rec.actual_termination_date < p_period_end_date then
		p_period_end_date := l_rec.actual_termination_date;
	end if;
	if  nvl(p_prev_hire_date1,l_period_start_date) < l_period_start_date then
	    p_prev_hire_date1 := l_period_start_date;
	end if;

	if  nvl(p_prev_hire_date2,l_period_start_date) < l_period_start_date then
	    p_prev_hire_date2 := l_period_start_date;
	end if;

	if nvl(p_tax_grp_wkpd_from,l_period_start_date) < l_period_start_date then
	     p_tax_grp_wkpd_from := l_period_start_date;
	end if;

        if nvl(p_prev_termination_date1,l_period_end_date) > l_period_end_date then
	   p_prev_termination_date1 := l_period_end_date;
	end if;

	if nvl(p_prev_termination_date2,l_period_end_date) > l_period_end_date then
	   p_prev_termination_date2 := l_period_end_date;
	end if;

	if nvl(p_tax_grp_wkpd_to,l_period_end_date) > l_period_end_date then
	   p_tax_grp_wkpd_to := l_period_end_date;
	end if;

	if nvl(p_prev_tax_brk_pd_from1,l_period_start_date) < l_period_start_date then
	    p_prev_tax_brk_pd_from1 := l_period_start_date;
	end if;

	if nvl(p_prev_tax_brk_pd_from2,l_period_start_date) < l_period_start_date then
	    p_prev_tax_brk_pd_from2 := l_period_start_date;
	end if;

	if nvl(p_tax_grp_tax_brk_pd_from,l_period_start_date) < l_period_start_date then
	    p_tax_grp_tax_brk_pd_from := l_period_start_date;
	end if;

	if nvl(p_prev_tax_brk_pd_to1,l_period_end_date) > l_period_end_date then
	   p_prev_tax_brk_pd_to1 := l_period_end_date;
	end if;

        if nvl(p_prev_tax_brk_pd_to2,l_period_end_date) > l_period_end_date then
	   p_prev_tax_brk_pd_to2 := l_period_end_date;
	end if;

	if nvl(p_tax_grp_tax_brk_pd_to,l_period_end_date) > l_period_end_date then
	   p_tax_grp_tax_brk_pd_to := l_period_end_date;
	 end if;
	-- End of Bug 9336934
	--
        -- Foreign worker income exem
        --
        p_foreign_worker_tax_exem := l_yea_info.foreign_worker_income_exem;
        --
	/*
	Bug No: 3546993
	Modified Non-Taxable Earnings depending on Nationality
	and Fixed Tax Rate Flag. Archived values are not changed.
	*/

	/* Bug No: 3546993 */

	-- Basic Income Exemption
	--
	p_basic_income_exem	:= l_yea_info.basic_income_exem;
	p_taxable_income	:= l_yea_info.taxable_income;
	--
	-- Basic Tax Exemption
	--
	p_ee_tax_exem		:= l_yea_info.ee_tax_exem;
	p_dpnt_spouse_tax_exem	:= l_yea_info.dpnt_spouse_tax_exem;
	p_num_of_dpnts		:= l_yea_info.num_of_dpnts;
	p_dpnt_tax_exem		:= l_yea_info.dpnt_tax_exem;
	--
	-- Additional Tax Exemption
	--
	p_num_of_ageds		:= l_yea_info.num_of_ageds;
	p_aged_tax_exem		:= l_yea_info.aged_tax_exem;
	p_num_of_disableds	:= l_yea_info.num_of_disableds;
	p_disabled_tax_exem	:= l_yea_info.disabled_tax_exem;
	p_female_ee_tax_exem	:= l_yea_info.female_ee_tax_exem;
	p_num_of_children	:= l_yea_info.num_of_children;
	p_child_tax_exem	:= l_yea_info.child_tax_exem;
	p_new_born_adopted_tax_exem	:=l_yea_info.new_born_adopted_tax_exem;----Bug 7142620
	p_num_of_new_born_adopted	:=l_yea_info.num_of_new_born_adopted; ----- Bug 7142620
	p_num_of_addtl_child    := l_yea_info.num_of_addtl_child;      -- Bug 6784288
	p_addl_child_tax_exem	:= l_yea_info.addl_child_tax_exem;     -- Bug 6012258
	p_supp_tax_exem		:= l_yea_info.supp_tax_exem;
	p_num_of_underaged_dpnts := l_yea_info.num_of_underaged_dpnts; -- Bug 6024342
	--
	-- Special Tax Exemption
	--
	p_ins_prem_tax_exem	:= l_yea_info.ins_prem_tax_exem;
	p_med_exp_tax_exem	:= l_yea_info.med_exp_tax_exem;
	p_educ_exp_tax_exem	:= l_yea_info.educ_exp_tax_exem;
	p_housing_loan_repay_exem := l_yea_info.housing_loan_repay_exem; --- Bug 7142620
	p_lt_housing_loan_intr_exem  := l_yea_info.lt_housing_loan_intr_exem;  --- Bug 7142620
	p_donation_tax_exem	:= l_yea_info.donation_tax_exem;
        p_marr_fun_relo_exem    := l_yea_info.marr_fun_relo_exemption;
	p_sp_tax_exem		:= l_yea_info.sp_tax_exem;
	p_std_sp_tax_exem	:= l_yea_info.std_sp_tax_exem;
	--
	-- National Pension Premium Tax Exemption
	--
	p_np_prem_tax_exem	:= l_yea_info.np_prem_tax_exem;
	p_taxable_income2	:= l_yea_info.taxable_income2;
	--
	-- Pension Premium
	--
	p_pension_premium	:= l_yea_info.pen_prem;	-- Bug 6024342
	--
	-- Other Tax Exemptions
	--
	p_pers_pension_prem_tax_exem	:= l_yea_info.pers_pension_prem_tax_exem;
	p_corp_pension_prem_tax_exem	:= l_yea_info.corp_pension_prem_tax_exem;
	p_pers_pension_saving_tax_exem	:= l_yea_info.pers_pension_saving_tax_exem;
	p_invest_partner_fin_tax_exem	:= l_yea_info.invest_partner_fin_tax_exem;
	p_credit_card_exp_tax_exem	:= l_yea_info.credit_card_exp_tax_exem;
	p_emp_st_own_plan_cont_exem  	:= l_yea_info.emp_stk_own_contri_tax_exem;
	p_small_bus_install_exem	:= l_yea_info.small_bus_install_exem;		-- Bug 6895093
	p_housing_saving_exem           := l_yea_info.housing_saving_exem; -- Bug 7142620
	p_long_term_stck_fund_tax_exem  := l_yea_info.long_term_stck_fund_tax_exem; -- Bug 7615517
	--
	p_non_rep_non_taxable           := l_yea_info.non_rep_non_taxable; -- Bug 9079478
	p_smb_income_exem               := l_yea_info.smb_income_exem; -- Bug 9079478
	-- Bug 6895093
	-- Premium Details
	--
	p_hi_prem			:= l_yea_info.hi_prem_tax_exem;
	p_ei_prem			:= l_yea_info.ei_prem_tax_exem;
	p_np_prem			:= l_yea_info.np_prem_tax_exem;
	--
        p_ltci_prem                     := l_yea_info.long_term_ins_prem_tax_exem; -- Bug 7260606
        --
	-- Bug : 5190884
	-- Employee Expense Details
	--
	p_emp_med_exp_nts		:= nvl(l_emp_med_exp_nts,0);
	p_emp_educ_exp_nts		:= nvl(l_emp_educ_exp_nts,0);
	p_emp_card_exp_nts		:= nvl(l_emp_card_exp_nts,0);
	p_emp_don_exp_nts		:= nvl(l_emp_don_exp_nts,0);
	p_emp_ins_exp_nts		:= nvl(l_emp_ins_exp_nts,0); -- Bug 5667762
	--
	p_emp_tot_ins_exp		:= ( l_yea_info.hi_prem + l_yea_info.long_term_ins_prem
                                            +l_yea_info.ei_prem + l_yea_info.pers_ins_prem
                                            + l_yea_info.disabled_ins_prem);        -- Bug 7260606
	p_emp_med_exp_oth		:=   l_yea_info.med_exp_emp - p_emp_med_exp_nts;
        -- Bug : 5745179
        --
	l_don_tax_break2004		:= pay_kr_yea_form_pkg.get_donation_tax_break(fnd_date.date_to_canonical(l_rec.effective_date), l_yea_info.political_donation1);
	--
        p_emp_don_exp_oth		:= ( nvl(l_don_amount1,0) + nvl(l_don_amount2,0) - nvl(l_don_tax_break2004,0))
                                          - nvl(p_emp_don_exp_nts,0) - nvl(l_dpnt_don_total,0);
	p_emp_educ_exp_oth		:= ( l_yea_info.ee_educ_exp + l_emp_occu_trng ) - p_emp_educ_exp_nts;
	p_emp_card_exp_oth		:= l_card_expense_total - p_emp_card_exp_nts;
	p_emp_cash_exp_nts		:= nvl(l_emp_cash_exp,0);

        -- Double Exemption Amount Bug 6716401
	p_double_exem_amt               :=  l_yea_info.double_exem_amt;

	--
	-- Calculated Tax
	--
	p_taxation_base			:= l_yea_info.taxation_base;
	p_calc_tax			:= l_yea_info.calc_tax;
	p_basic_tax_break		:= l_yea_info.basic_tax_break;
	p_housing_exp_tax_break		:= l_yea_info.housing_exp_tax_break;
	p_stock_saving_tax_break	:= l_yea_info.stock_saving_tax_break;
	p_ovs_tax_break			:= l_yea_info.ovs_tax_break;
	p_lt_stock_saving_tax_break	:= l_yea_info.lt_stock_saving_tax_break;
	p_total_tax_break		:= l_yea_info.total_tax_break;
	-- Bug 3966549
	p_don_tax_break			:= l_yea_info.don_tax_break2004 ;
	-- End of 3966549
	--
	-- Foreign Worker Tax Break
	--
	p_foreign_worker_tax_break1	:= l_yea_info.foreign_worker_tax_break1;
	p_foreign_worker_tax_break2	:= l_yea_info.foreign_worker_tax_break2;
	p_foreign_worker_tax_break	:= l_yea_info.foreign_worker_tax_break;

	-- Tax
	--
	p_annual_itax	:= l_yea_info.annual_itax;
	p_annual_stax	:= l_yea_info.annual_stax;
	p_annual_rtax	:= l_yea_info.annual_rtax;
	p_annual_tax	:= p_annual_itax + p_annual_stax + p_annual_rtax;
	p_prev_itax	:= l_yea_info.prev_itax + l_yea_info.tax_grp_itax; -- Bug 7361372
	p_prev_stax	:= l_yea_info.prev_stax + l_yea_info.tax_grp_stax; -- Bug 7361372, Bug 7759357
	p_prev_rtax	:= l_yea_info.prev_rtax + l_yea_info.tax_grp_rtax; -- Bug 7361372, Bug 7759357
	p_prev_tax	:= p_prev_itax + p_prev_stax + p_prev_rtax;
	p_cur_itax	:= l_yea_info.cur_itax;
	p_cur_stax	:= l_yea_info.cur_stax;
	p_cur_rtax	:= l_yea_info.cur_rtax;
	p_cur_tax	:= p_cur_itax + p_cur_stax + p_cur_rtax;
	p_itax_adj	:= l_yea_info.itax_adj;
	p_stax_adj	:= l_yea_info.stax_adj;
	p_rtax_adj	:= l_yea_info.rtax_adj;
	p_tax_adj	:= p_itax_adj + p_stax_adj + p_rtax_adj;

end data;
end pay_kr_paykrytr_pkg;

/
