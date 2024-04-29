--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_PKG" AUTHID CURRENT_USER as
/* $Header: pykryea.pkh 120.10.12010000.19 2010/02/04 12:04:06 vaisriva ship $ */
------------------------------------------------------------------------
type t_number_tbl is table of number index by binary_integer;
type t_varchar2_tbl is table of varchar2(255) index by binary_integer;
type t_date_tbl is table of date index by binary_integer;
------------------------------------------------------------------------
type t_yea_info is record(
	non_resident_flag		varchar2(1) default 'N',
	-- Bug 6615356
	foreign_residency_flag          varchar2(1) default 'N',
	------------------------------------------------------------------------
	-- Bug 3201332 Nationality
	------------------------------------------------------------------------
	nationality                     varchar2(1) default 'K',
	-- Bug 3172960
	fixed_tax_rate			varchar2(1) default 'N',
	------------------------------------------------------------------------
	-- Current Employer's Information
	------------------------------------------------------------------------
	cur_taxable_mth			number default 0,
	cur_taxable_bon			number default 0,
	cur_sp_irreg_bonus		number default 0,
	cur_stck_pur_opt_exec_earn      number default 0, -- Bug 6012258
	cur_esop_withd_earn		number default 0, -- Bug 8644512
	cur_taxable			number default 0,
	cur_non_taxable_ovs		number default 0, -- Bug 8644512
	cur_non_taxable_ovt		number default 0, -- Bug 8644512
	cur_birth_raising_allowance	number default 0, -- Bug 8644512
	cur_fw_income_exem		number default 0, -- Bug 8644512
	------------------------------------------------------------------------
	-- Previous Employers' Information
	------------------------------------------------------------------------
	prev_hire_date_tbl		t_date_tbl,	-- Bug 8644512
	prev_termination_date_tbl	t_date_tbl,
	prev_corp_name_tbl		t_varchar2_tbl,
	prev_bp_number_tbl		t_varchar2_tbl,
	prev_tax_brk_pd_from_tbl	t_date_tbl,	-- Bug 8644512
	prev_tax_brk_pd_to_tbl		t_date_tbl,	-- Bug 8644512
	prev_taxable_mth_tbl		t_number_tbl,
	prev_taxable_bon_tbl		t_number_tbl,
	prev_sp_irreg_bonus_tbl		t_number_tbl,
	prev_stck_pur_opt_exe_earn_tbl  t_number_tbl, -- Bug 6024342
	prev_esop_withd_earn_tbl	t_number_tbl, -- Bug 8644512
	prev_non_taxable_ovs_tbl	t_number_tbl,
	prev_non_taxable_ovt_tbl	t_number_tbl,
	prev_non_taxable_oth_tbl	t_number_tbl,
	prev_hi_prem_tbl		t_number_tbl,
	prev_ltci_prem_tbl		t_number_tbl, -- Bug 7260606
	prev_ei_prem_tbl		t_number_tbl,
	prev_np_prem_tbl		t_number_tbl,
	prev_pen_prem_tbl		t_number_tbl, -- Bug 6024342
	prev_separation_pension_tbl	t_number_tbl, -- Bug 7508706
	prev_itax_tbl			t_number_tbl,
	prev_rtax_tbl			t_number_tbl,
	prev_stax_tbl			t_number_tbl,
	prev_research_payment_tbl       t_number_tbl,         -- Bug 8341054
        prev_bir_raising_allowance_tbl  t_number_tbl,        -- Bug 8341054
        prev_foreign_wrkr_inc_exem_tbl  t_number_tbl,         -- Bug 8341054
	--
	prev_taxable_mth		number default 0,
	prev_taxable_bon		number default 0,
	prev_sp_irreg_bonus		number default 0,
	prev_stck_pur_opt_exec_earn	number default 0, -- Bug 6024342
	prev_esop_withd_earn		number default 0, -- Bug 8644512
	prev_birth_raising_allowance	number default 0, -- Bug 8644512
	prev_non_taxable_ovt		number default 0, -- Bug 8644512
	prev_taxable			number default 0,
	prev_foreign_wrkr_inc_exem      number default 0, -- Bug 8341054
	------------------------------------------------------------------------
	-- Annual Earnings
	------------------------------------------------------------------------
	taxable_mth			number default 0,
	taxable_bon			number default 0,
	sp_irreg_bonus			number default 0,
	-- Bug 6024342
	stck_pur_opt_exec_earn          number default 0,
	--
	esop_withd_earn			number default 0, -- Bug 8644512
	-- Bug 6012258
  	research_payment		number default 0,
	--
	-- Bug 7142620
	birth_raising_allowance		number default 0,
	--
	taxable				number default 0,
	taxable1			number default 0, -- Bug 7615517
	non_taxable_ovs			number default 0,
	non_taxable_ovt			number default 0,
	non_taxable_ovs_frgn		number default 0, -- Bug 7439803
	non_taxable_oth			number default 0,
	non_rep_non_taxable		number default 0, -- Bug 9079450
	non_taxable			number default 0,
	------------------------------------------------------------------------
	-- Monthly Regular Earnings -- Bus 3201332
	------------------------------------------------------------------------
	monthly_reg_earning		number default 0,
	------------------------------------------------------------------------
	-- Bug 3172960 Foreign Worker Income Exemption
	------------------------------------------------------------------------
	foreign_worker_income_exem	number default 0,
	------------------------------------------------------------------------
	-- Basic Income Exemption
	------------------------------------------------------------------------
	basic_income_exem		number default 0,
	------------------------------------------------------------------------
	-- Taxable Income
	------------------------------------------------------------------------
	taxable_income			number default 0,
	------------------------------------------------------------------------
	-- Employee Tax Exemption
	------------------------------------------------------------------------
	ee_tax_exem			number default 0,
	------------------------------------------------------------------------
	-- Dependent Tax Exemption
	------------------------------------------------------------------------
	dpnt_spouse_flag		varchar2(1) default 'N',
	dpnt_spouse_tax_exem		number default 0,
	num_of_aged_dpnts		number default 0,
	num_of_adult_dpnts		number default 0,
	num_of_underaged_dpnts		number default 0,
	num_of_dpnts			number default 0,
	dpnt_tax_exem			number default 0,
	num_of_ageds			number default 0,
	-- Bug 3172960
	num_of_super_ageds		number default 0,
	--
	num_of_new_born_adopted         number default 0, -- Bug 6705170
        new_born_adopted_tax_exem       number default 0, -- Bug 6705170
	--
	num_of_addtl_child		number default 0, -- Bug 6784288
	--
	aged_tax_exem			number default 0,
	num_of_disableds		number default 0,
	disabled_tax_exem		number default 0,
	female_ee_flag			varchar2(1) default 'N',
	female_ee_tax_exem		number default 0,
	num_of_children			number default 0,
	child_tax_exem			number default 0,
	-- Bug 5756690
	addl_child_tax_exem		number default 0,
	supp_tax_exem			number default 0,
	------------------------------------------------------------------------
	-- Insurance Premium Tax Exemption
	------------------------------------------------------------------------
	hi_prem				number default 0,
	hi_prem_tax_exem		number default 0,
	long_term_ins_prem		number default 0, -- Bug 7164589
	long_term_ins_prem_tax_exem	number default 0, -- Bug 7164589
	ei_prem				number default 0,
	ei_prem_tax_exem		number default 0,
	pers_ins_name			varchar2(150),
	pers_ins_prem			number default 0,
	pers_ins_prem_tax_exem		number default 0,
	disabled_ins_prem		number default 0,
	disabled_ins_prem_tax_exem	number default 0,
	ins_prem_tax_exem		number default 0,
	------------------------------------------------------------------------
	-- Medical Expense Tax Exemption
	------------------------------------------------------------------------
	med_exp				number default 0,
        med_exp_card_emp	        number default 0,
	med_exp_disabled		number default 0,
	med_exp_aged			number default 0,
	-- Bug 3172960
	med_exp_emp			number default 0,
	max_med_exp_tax_exem		number default 0,
	med_exp_tax_exem		number default 0,
	--
	-- Bug 3966549
	reg_med_exp_tax_exem2004	number default 0,
	add_med_exp_tax_exem2004	number default 0,
	-- End of 3966549
	--
	------------------------------------------------------------------------
	-- Education Expense Tax Exemption
	------------------------------------------------------------------------
	ee_educ_exp			number default 0,
	-- Bug 3971542
	ee_occupation_educ_exp2005	number default 0,
	-- End of 3971542
	dpnt_educ_contact_type_tbl	t_varchar2_tbl,
	dpnt_educ_school_type_tbl	t_varchar2_tbl,
	dpnt_educ_exp_tbl		t_number_tbl,
	dpnt_educ_contact_name_tbl	t_varchar2_tbl,		-- Bug 9079450
	dpnt_educ_contact_ni_tbl	t_varchar2_tbl,		-- Bug 9079450
	spouse_educ_exp			number default 0,
	disabled_educ_exp		number default 0,
	dpnt_educ_exp			number default 0,
	educ_exp_tax_exem		number default 0,
	------------------------------------------------------------------------
	-- Bug 3201332 Foreign Worker Special Pre-Tax Deduction
	------------------------------------------------------------------------
	fw_educ_expense			number default 0,
	fw_house_rent			number default 0,
	------------------------------------------------------------------------
	-- Housing Expense Tax Exemption
	------------------------------------------------------------------------
        /* Changes for Bug 2523481 */
        --
	housing_saving_type_tbl		        t_varchar2_tbl,
	housing_saving_tbl	        	t_number_tbl,
        housing_saving_type                     varchar2(30),
        housing_saving                          number default 0,
        --
	housing_purchase_date		        date,
	housing_loan_date		        date,
	housing_loan_repay		        number default 0,
        --
	lt_housing_loan_date		        date,
	lt_housing_loan_interest_repay          number default 0,
        --
	lt_housing_loan_date_1		        date,
	lt_housing_loan_intr_repay_1	        number default 0,
        --
        -- Bug 8237227
        lt_housing_loan_date_2		        date,
        lt_housing_loan_intr_repay_2	        number default 0,
        --
	max_housing_exp_tax_exem	        number default 0,
	housing_exp_tax_exem		        number default 0,
	-- Bug 7142620
	housing_saving_exem			number default 0,
	housing_loan_repay_exem		number default 0,
	lt_housing_loan_intr_exem		number default 0,
	-- End of Bug 7142620
	------------------------------------------------------------------------
	-- Donation Tax Exemption (Political and ESOA)
	------------------------------------------------------------------------
	donation1			number default 0,
	political_donation1		number default 0,
	political_donation2		number default 0,
	political_donation3		number default 0,
	donation1_tax_exem		number default 0,
	donation2			number default 0,
        donation3                       number default 0,
        donation4                       number default 0,  -- Bug 7142612
	religious_donation		number default 0,  -- Bug 7142612
	max_donation2_tax_exem		number default 0,
        max_donation3_tax_exem		number default 0,
	donation2_tax_exem		number default 0,
        donation3_tax_exem              number default 0,
	donation_tax_exem		number default 0,
	--
	-- Bug 3966549
	esoa_don2004			number default 0,
	max_esoa_don_tax_exem2004	number default 0,
	esoa_don_tax_exem2004		number default 0,
	don_tax_break2004		number default 0,
	-- End of 3966549
	--
	------------------------------------------------------------------------
	-- Marriage, Funeral and Relocation  Tax Exemption
	------------------------------------------------------------------------
	marriage_exemption		varchar2(15),
	funeral_exemption		varchar2(15),
	relocation_exemption	        varchar2(15),
	marr_fun_relo_exemption    	number default 0,
	------------------------------------------------------------------------
	-- Special Tax Exemption
	------------------------------------------------------------------------
	sp_tax_exem			number default 0,
	std_sp_tax_exem			number default 0,
	------------------------------------------------------------------------
	-- National Pension Premium Tax Exemption
	------------------------------------------------------------------------
	np_prem				number default 0,
	np_prem_tax_exem		number default 0,
	------------------------------------------------------------------------
	-- Pension Premium
	------------------------------------------------------------------------
	pen_prem			number default 0,	-- Bug 6024342
	------------------------------------------------------------------------
	-- Taxable Income2
	------------------------------------------------------------------------
	taxable_income2			number default 0,
	------------------------------------------------------------------------
	-- Tax Exemption
	------------------------------------------------------------------------
	pers_pension_prem		number default 0,
	pers_pension_prem_tax_exem	number default 0,
	-- Bug 4750653
	corp_pension_prem		number default 0,
	corp_pension_prem_tax_exem	number default 0,
	--
        emp_st_own_plan_cont            number default 0,
        emp_st_own_plan_cont_exem       number default 0,
	pers_pension_saving		number default 0,
	pers_pension_saving_tax_exem	number default 0,
	invest_partner_fin1		number default 0,
	invest_partner_fin2		number default 0,
        invest_partner_fin3		number default 0,  -- Bug 8237227
	invest_partner_fin_tax_exem	number default 0,
	small_bus_install		number default 0, -- Bug 6895093
	small_bus_install_exem		number default 0, -- Bug 6895093
	credit_card_exp			number default 0,
	direct_card_exp                 number default 0,
	total_credit_card_exp           number default 0,
	credit_card_exp_tax_exem	number default 0,
        direct_card_exp_tax_exem        number default 0,
	total_credit_card_exp_tax_exem  number default 0,
        emp_stk_own_contri              number default 0,
        emp_stk_own_contri_tax_exem     number default 0,
	--
	-- Bug 3966549
	emp_cre_card_direct_exp2004	number default 0,
	dpnt_cre_card_direct_exp2004	number default 0,
	giro_tuition_paid_exp2004	number default 0,
	-- End of 3966549

	-- Bug 3506168
	cash_receipt_exp2005            number default 0,
	--
	------------------------------------------------------------------------
	-- Taxation Base
	------------------------------------------------------------------------
	taxation_base			number default 0,
	------------------------------------------------------------------------
	-- Calculated Tax
	------------------------------------------------------------------------
	calc_tax			number default 0,
	------------------------------------------------------------------------
	-- Tax Break Information
	------------------------------------------------------------------------
	basic_tax_break			number default 0,
	housing_loan_interest_repay	number default 0,
	housing_exp_tax_break		number default 0,
	stock_saving			number default 0,
	stock_saving_tax_break		number default 0,
	lt_stock_saving1		number default 0,
	lt_stock_saving2		number default 0,
	lt_stock_saving_tax_break	number default 0,
	--
	ovstb_tax_paid_date		date,
	ovstb_territory_code		fnd_territories.territory_code%TYPE,
	ovstb_currency_code		fnd_currencies.currency_code%TYPE,
	ovstb_taxable			number default 0,
	ovstb_taxable_subj_tax_break	number default 0,
	ovstb_tax_break_rate		number default 0,
	ovstb_tax_foreign_currency	number default 0,
	ovstb_tax			number default 0,
	ovstb_application_date		date,
	ovstb_submission_date		date,
	ovs_tax_break			number default 0,
	--
	total_tax_break			number default 0,
	--
	fwtb_immigration_purpose	varchar2(1),
	fwtb_contract_date		date,
	fwtb_expiry_date		date,
	fwtb_application_date		date,
	fwtb_submission_date		date,
	foreign_worker_tax_break1	number default 0,
	foreign_worker_tax_break2	number default 0,
	foreign_worker_tax_break	number default 0,
	------------------------------------------------------------------------
	-- Tax
	------------------------------------------------------------------------
	annual_itax			number default 0,
	annual_rtax			number default 0,
	annual_stax			number default 0,
	prev_itax			number default 0,
	prev_rtax			number default 0,
	prev_stax			number default 0,
	cur_itax			number default 0,
	cur_rtax			number default 0,
	cur_stax			number default 0,
	itax_adj			number default 0,
	rtax_adj			number default 0,
	stax_adj			number default 0,
        fw_contr_taxable_earn           number default 0,    -- Bug 5083240
        fw_contr_non_taxable_earn       number default 0,    -- Bug 5083240
	tot_med_exp_cards               number default 0,    -- Bug 6630135
	dpnt_med_exp_cards              number default 0,     -- Bug 6630135
	med_exp_paid_not_inc_med_exem   number default 0,     -- Bug 6630135
	double_exem_amt                 number default 0,     -- Bug 6716401
	------------------------------------------------------------------------
	-- Tax Group Info
	------------------------------------------------------------------------
        tax_grp_bus_reg_num             varchar2(12), -- Bug 7361372
        tax_grp_name                    varchar2(150), -- Bug 7361372
	tax_grp_wkpd_from		date,		  -- Bug 8644512
	tax_grp_wkpd_to			date,		  -- Bug 8644512
	tax_grp_tax_brk_pd_from		date,		  -- Bug 8644512
	tax_grp_tax_brk_pd_to		date,		  -- Bug 8644512
        tax_grp_taxable_mth             number default 0, -- Bug 7361372
        tax_grp_taxable_bon             number default 0, -- Bug 7361372
        tax_grp_sp_irreg_bonus          number default 0, -- Bug 7361372
        tax_grp_stck_pur_opt_exec_earn  number default 0, -- Bug 7361372
	tax_grp_esop_withd_earn		number default 0, -- Bug 8644512
        tax_grp_itax      	        number default 0, -- Bug 7361372
        tax_grp_rtax      	        number default 0, -- Bug 7361372
        tax_grp_stax       	        number default 0, -- Bug 7361372
        tax_grp_taxable                 number default 0, -- Bug 7361372
        tax_grp_post_tax_deduc          number default 0, -- Bug 7361372
	tax_grp_taxable_mth_ne          number default 0, -- Bug 7508706
        tax_grp_taxable_bon_ne          number default 0, -- Bug 7508706
        tax_grp_sp_irreg_bonus_ne       number default 0, -- Bug 7508706
	tax_grp_esop_withd_earn_ne	number default 0, -- Bug 8644512
        tax_grp_stck_pur_ne 		number default 0, -- Bug 7508706
        tax_grp_taxable_ne              number default 0, -- Bug 7508706
	tax_grp_non_taxable_ovt		number default 0, -- Bug 8644512
	tax_grp_bir_raising_allw	number default 0, -- Bug 8644512
	tax_grp_fw_income_exem		number default 0, -- Bug 8644512
	company_related_exp		number default 0, -- Bug 7615517
	long_term_stck_fund_1year	number default 0, -- Bug 7615517
	long_term_stck_fund_2year	number default 0, -- Bug 7615517
	long_term_stck_fund_3year	number default 0, -- Bug 7615517
	long_term_stck_fund_tax_exem	number default 0,  -- Bug 7615517
	--
	cur_ntax_G01      	        number default 0, -- Bug  8644512
	cur_ntax_H01      	        number default 0, -- Bug  8644512
	cur_ntax_H05      	        number default 0, -- Bug  8644512
	cur_ntax_H06      	        number default 0, -- Bug  8644512
	cur_ntax_H07      	        number default 0, -- Bug  8644512
	cur_ntax_H08      	        number default 0, -- Bug  8644512
	cur_ntax_H09      	        number default 0, -- Bug  8644512
	cur_ntax_H10      	        number default 0, -- Bug  8644512
	cur_ntax_H11      	        number default 0, -- Bug  8644512
	cur_ntax_H12      	        number default 0, -- Bug  8644512
	cur_ntax_H13      	        number default 0, -- Bug  8644512
	cur_ntax_I01      	        number default 0, -- Bug  8644512
	cur_ntax_K01      	        number default 0, -- Bug  8644512
	cur_ntax_M01      	        number default 0, -- Bug  8644512
	cur_ntax_M02      	        number default 0, -- Bug  8644512
	cur_ntax_M03      	        number default 0, -- Bug  8644512
	cur_ntax_S01      	        number default 0, -- Bug  8644512
	cur_ntax_T01      	        number default 0, -- Bug  8644512
	cur_ntax_Y01      	        number default 0, -- Bug  8644512
	cur_ntax_Y02      	        number default 0, -- Bug  8644512
	cur_ntax_Y03      	        number default 0, -- Bug  8644512
	cur_ntax_Y20      	        number default 0, -- Bug  8644512
	cur_ntax_Z01      	        number default 0, -- Bug  8644512
	-- Bug 8880364
	cur_ntax_frgn_M01      	        number default 0,
	cur_ntax_frgn_M02      	        number default 0,
	cur_ntax_frgn_M03      	        number default 0,
	--
	prev_ntax_G01			number default 0, -- Bug 8644512
	prev_ntax_H01			number default 0, -- Bug 8644512
	prev_ntax_H05			number default 0, -- Bug 8644512
	prev_ntax_H06			number default 0, -- Bug 8644512
	prev_ntax_H07			number default 0, -- Bug 8644512
	prev_ntax_H08			number default 0, -- Bug 8644512
	prev_ntax_H09			number default 0, -- Bug 8644512
	prev_ntax_H10			number default 0, -- Bug 8644512
	prev_ntax_H11			number default 0, -- Bug 8644512
	prev_ntax_H12			number default 0, -- Bug 8644512
	prev_ntax_H13			number default 0, -- Bug 8644512
	prev_ntax_I01			number default 0, -- Bug 8644512
	prev_ntax_K01			number default 0, -- Bug 8644512
	prev_ntax_M01			number default 0, -- Bug 8644512
	prev_ntax_M02			number default 0, -- Bug 8644512
	prev_ntax_M03			number default 0, -- Bug 8644512
	prev_ntax_S01			number default 0, -- Bug 8644512
	prev_ntax_T01			number default 0, -- Bug 8644512
	prev_ntax_Y01			number default 0, -- Bug 8644512
	prev_ntax_Y02			number default 0, -- Bug 8644512
	prev_ntax_Y03			number default 0, -- Bug 8644512
	prev_ntax_Y20			number default 0, -- Bug 8644512
	prev_ntax_Z01			number default 0, -- Bug 8644512
	--
	tax_grp_ntax_G01		number default 0, -- Bug 8644512
	tax_grp_ntax_H01		number default 0, -- Bug 8644512
	tax_grp_ntax_H05		number default 0, -- Bug 8644512
	tax_grp_ntax_H06		number default 0, -- Bug 8644512
	tax_grp_ntax_H07		number default 0, -- Bug 8644512
	tax_grp_ntax_H08		number default 0, -- Bug 8644512
	tax_grp_ntax_H09		number default 0, -- Bug 8644512
	tax_grp_ntax_H10		number default 0, -- Bug 8644512
	tax_grp_ntax_H11		number default 0, -- Bug 8644512
	tax_grp_ntax_H12		number default 0, -- Bug 8644512
	tax_grp_ntax_H13		number default 0, -- Bug 8644512
	tax_grp_ntax_I01		number default 0, -- Bug 8644512
	tax_grp_ntax_K01		number default 0, -- Bug 8644512
	tax_grp_ntax_M01		number default 0, -- Bug 8644512
	tax_grp_ntax_M02		number default 0, -- Bug 8644512
	tax_grp_ntax_M03		number default 0, -- Bug 8644512
	tax_grp_ntax_S01		number default 0, -- Bug 8644512
	tax_grp_ntax_T01		number default 0, -- Bug 8644512
	tax_grp_ntax_Y01		number default 0, -- Bug 8644512
	tax_grp_ntax_Y02		number default 0, -- Bug 8644512
	tax_grp_ntax_Y03		number default 0, -- Bug 8644512
	tax_grp_ntax_Y20		number default 0, -- Bug 8644512
	tax_grp_ntax_Z01		number default 0, -- Bug 8644512
	--
	prev_ntax_G01_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_H01_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_H05_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_H06_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_H07_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_H08_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_H09_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_H10_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_H11_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_H12_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_H13_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_I01_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_K01_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_M01_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_M02_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_M03_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_S01_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_T01_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_Y01_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_Y02_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_Y03_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_Y20_tbl		t_number_tbl,	-- Bug 8644512
	prev_ntax_Z01_tbl		t_number_tbl, 	-- Bug 8644512
	--
	total_ntax_G01			number default 0, -- Bug 8644512
	total_ntax_H01			number default 0, -- Bug 8644512
	total_ntax_H05			number default 0, -- Bug 8644512
	total_ntax_H06			number default 0, -- Bug 8644512
	total_ntax_H07			number default 0, -- Bug 8644512
	total_ntax_H08			number default 0, -- Bug 8644512
	total_ntax_H09			number default 0, -- Bug 8644512
	total_ntax_H10			number default 0, -- Bug 8644512
	total_ntax_H11			number default 0, -- Bug 8644512
	total_ntax_H12			number default 0, -- Bug 8644512
	total_ntax_H13			number default 0, -- Bug 8644512
	total_ntax_I01			number default 0, -- Bug 8644512
	total_ntax_K01			number default 0, -- Bug 8644512
	total_ntax_M01			number default 0, -- Bug 8644512
	total_ntax_M02			number default 0, -- Bug 8644512
	total_ntax_M03			number default 0, -- Bug 8644512
	total_ntax_S01			number default 0, -- Bug 8644512
	total_ntax_T01			number default 0, -- Bug 8644512
	total_ntax_Y01			number default 0, -- Bug 8644512
	total_ntax_Y02			number default 0, -- Bug 8644512
	total_ntax_Y03			number default 0, -- Bug 8644512
	total_ntax_Y20			number default 0, -- Bug 8644512
	total_ntax_Z01			number default 0, -- Bug 8644512
	--
	cur_total_ntax_earn		number default 0, -- Bug 8644512
	tax_grp_total_ntax_earn		number default 0, -- Bug 8644512
	smb_income_exem			number default 0, -- Bug 9079450
	cur_smb_days_worked 		number default 0, -- Bug 9079450
	prev_smb_days_worked 		number default 0, -- Bug 9079450
	cur_smb_eligible_income		number default 0, -- Bug 9079450
	prev_smb_eligible_income	number default 0, -- Bug 9079450
	emp_join_prev_year		varchar2(1),	  -- Bug 9079450
	emp_leave_cur_year		varchar2(1),	  -- Bug 9079450
	smb_eligibility_flag		varchar2(1)	  -- Bug 9079450
	);
------------------------------------------------------------------------
procedure yea_info(
	p_assignment_id			in number,
	p_assignment_action_id		in number,
	p_effective_date		in date,
	p_business_group_id		in number,
	p_payroll_id         		in number,
	p_yea_info			out nocopy t_yea_info,
	p_taxable_earnings_warning	out nocopy boolean,
	p_taxable_income_warning	out nocopy boolean,
	p_taxation_base_warning		out nocopy boolean,
	p_calc_tax_warning		out nocopy boolean,
	p_itax_warning			out nocopy boolean,
	p_rtax_warning			out nocopy boolean,
        -- Bug 2878937
        p_tax_adj_warning               out nocopy boolean);
------------------------------------------------------------------------
function yea_info(
	p_assignment_action_id		in number) return t_yea_info;
------------------------------------------------------------------------
procedure process_assignment(
	p_validate			in boolean default false,
	p_business_group_id		in number,
	p_assignment_id			in number,
	p_assignment_action_id		in number,
	p_bal_asg_action_id		in number,
	p_report_type			in out nocopy varchar2,
	p_report_qualifier		in out nocopy varchar2,
	p_report_category		in out nocopy varchar2,
	p_effective_date		in out nocopy date,
	p_payroll_id			in out nocopy number,
	p_consolidation_set_id		in out nocopy number,
        p_archive_type_used             in out nocopy varchar2);   --5036734
--------------------------------------------------------------------------------
function calculate_adjustment(
        p_assignment_id                 in pay_assignment_actions.assignment_id%type,
        p_business_group_id             in pay_payroll_actions.business_group_id%type,
        p_effective_date                in pay_payroll_actions.effective_date%type,
        p_payroll_action_id             in pay_payroll_actions.payroll_action_id%type,
        p_assignment_action_id          in pay_assignment_actions.assignment_action_id%type,
        p_itax_adj                      out nocopy number,
        p_rtax_adj                      out nocopy number,
        p_stax_adj                      out nocopy number,
        p_error                         out nocopy varchar2) return number;
--------------------------------------------------------------------------------
end pay_kr_yea_pkg;

/
