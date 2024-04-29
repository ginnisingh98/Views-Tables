--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA_PKG" as
/* $Header: pykryea.pkb 120.18.12010000.30 2010/04/05 11:53:39 vaisriva ship $ */
------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
c_00010101	constant date := fnd_date.canonical_to_date('0001/01/01');
c_20020101      constant date := fnd_date.canonical_to_date('2002/01/01');
c_20030101      constant date := fnd_date.canonical_to_date('2003/01/01');
c_20040101      constant date := fnd_date.canonical_to_date('2004/01/01');
c_20050101      constant date := fnd_date.canonical_to_date('2005/01/01');
c_20060101      constant date := fnd_date.canonical_to_date('2006/01/01');
c_20070101      constant date := fnd_date.canonical_to_date('2007/01/01');   -- Bug 5734313
c_20080101      constant date := fnd_date.canonical_to_date('2008/01/01');   -- Bug 6705170
c_20090101      constant date := fnd_date.canonical_to_date('2009/01/01');   -- Bug 7676136
c_20100101      constant date := fnd_date.canonical_to_date('2010/01/01');   -- Bug 9231094
------------------------------------------------------------------------
-- Global Variables
------------------------------------------------------------------------
g_package constant varchar2(31) := '  pay_kr_yea_pkg.';
------------------------------------------------------------------------
-- Defined Balance and Balance Value Cache
------------------------------------------------------------------------
g_balance_value_tab  	pay_balance_pkg.t_balance_value_tab;
g_tax_adj_balance_tab   pay_balance_pkg.t_balance_value_tab;
------------------------------------------------------------------------
-- Bug 8644512
------------------------------------------------------------------------
type t_ntax_rec is record
(
 business_reg_num	varchar2(255),
 ntax_earn_code  varchar2(255),
 ntax_earning	number
);
--
type t_ntax_tab is table of t_ntax_rec index by binary_integer;
--
g_ntax_detail_tbl 	t_ntax_tab;
g_ntax_value_tbl	t_number_tbl;
g_contexts_tab		t_varchar2_tbl;
--
cursor csr_contexts is
       select lookup_code from hr_lookups
        where lookup_type = 'KR_NON_TAXABLE_EARNINGS_CODE'
	and   enabled_flag = 'Y'
	order by 1;
--
------------------------------------------------------------------------
-- Element Cache
------------------------------------------------------------------------
type t_element is record(
	element_type_id		number,
	input_value_id_tbl	hr_entry.number_table,
	input_value_name_tbl	t_varchar2_tbl);
--
g_tax		t_element;
g_itax_adj	t_element;
g_rtax_adj	t_element;
g_stax_adj	t_element;
------------------------------------------------------------------------
-- User Entity Cache
------------------------------------------------------------------------
type t_user_entity_id is record(
	non_resident_flag		number,
	foreign_residency_flag          number, -- Bug 6615356
        fw_fixed_tax_rate               number, -- 3546993
	nationality			number, -- Bug 7595082
	cur_taxable_mth			number,
	cur_taxable_bon			number,
	cur_sp_irreg_bonus		number,
	cur_stck_pur_opt_exec_earn      number, -- Bug 6012258
	cur_esop_withd_earn		number, -- Bug 8644512
	cur_taxable			number,
	cur_non_taxable_ovt		number, -- Bug 8644512
	cur_birth_raising_allowance	number,	-- Bug 8644512
	cur_fw_income_exem		number,	-- Bug 8644512
	prev_taxable_mth		number,
        prev_foreign_wrkr_inc_exem      number, -- Bug 8341054
	prev_taxable_bon		number,
	prev_sp_irreg_bonus		number,
	prev_stck_pur_opt_exec_earn     number, -- Bug 6024342
	prev_birth_raising_allowance	number,	-- Bug 8644512
	prev_esop_withd_earn		number, -- Bug 8644512
	prev_non_taxable_ovt		number, -- Bug 8644512
        prev_taxable			number,
	taxable_mth			number,
	taxable_bon			number,
	sp_irreg_bonus			number,
	stck_pur_opt_exec_earn          number, -- Bug 6024342
	esop_withd_earn			number, -- Bug 8644512
  	research_payment		number, -- Bug 6012258
	taxable				number,
	taxable1			number, --Bug 7615517
	non_taxable_ovs			number,
	non_taxable_ovt			number,
	non_taxable_ovs_frgn		number,	-- Bug 7439803
	non_taxable_oth			number,
	non_rep_non_taxable		number, -- Bug 9079450
	non_taxable			number,
        foreign_worker_income_exem      number, -- 3546993
	basic_income_exem		number,
	taxable_income			number,
	ee_tax_exem			number,
	dpnt_spouse_flag		number,
	dpnt_spouse_tax_exem		number,
	num_of_aged_dpnts		number,
	num_of_adult_dpnts		number,
	num_of_underaged_dpnts		number,
	num_of_dpnts			number,
	dpnt_tax_exem			number,
	num_of_ageds			number,
	-- Bug 3172960
	num_of_super_ageds		number,
	num_of_new_born_adopted         number, -- Bug 6705170
        new_born_adopted_tax_exem       number, -- Bug 6705170
	aged_tax_exem			number,
	num_of_disableds		number,
	disabled_tax_exem		number,
	female_ee_flag			number,
	female_ee_tax_exem		number,
	num_of_children			number,
	child_tax_exem			number,
	num_of_addtl_child		number, -- Bug 6784288
	addl_child_tax_exem             number, -- Bug 5756690
	supp_tax_exem			number,
	hi_prem				number,
	hi_prem_tax_exem		number,
	long_term_ins_prem		number, -- Bug 7164589
	long_term_ins_prem_tax_exem	number, -- Bug 7164589
	ei_prem				number,
	ei_prem_tax_exem		number,
	pers_ins_name			number,
	pers_ins_prem			number,
	pers_ins_prem_tax_exem		number,
	disabled_ins_prem		number,
	disabled_ins_prem_tax_exem	number,
	ins_prem_tax_exem		number,
	med_exp				number,
	med_exp_disabled		number,
	med_exp_aged			number,
	-- Bug 3172960
	med_exp_emp			number,
	max_med_exp_tax_exem		number,
	med_exp_tax_exem		number,
	ee_educ_exp			number,
	spouse_educ_exp			number,
	disabled_educ_exp		number,
	dpnt_educ_exp			number,
	educ_exp_tax_exem		number,
	housing_saving_type		number,
	housing_saving			number,
	housing_purchase_date		number,
	housing_loan_date		number,
	housing_loan_repay		number,
	lt_housing_loan_date		number,
	lt_housing_loan_interest_repay	number,
	lt_housing_loan_date_1		number,
	lt_housing_loan_intr_repay_1	number,
        lt_housing_loan_date_2		number,   -- Bug 8237227
	lt_housing_loan_intr_repay_2	number,   -- Bug 8237227
	max_housing_exp_tax_exem	number,
	housing_exp_tax_exem		number,
	--- Bug 7142620
	housing_saving_exem		number,
	housing_loan_repay_exem	        number,
	lt_housing_loan_intr_exem	number,
	birth_raising_allowance		number,
	--- End of Bug 7142620
	donation1			number,
	political_donation1		number,
	political_donation2		number,
	political_donation3		number,
	donation1_tax_exem		number,
	donation2			number,
        donation3               	number,
        donation4               	number,  -- Bug 7142612
        religious_donation             	number,  -- Bug 7142612
	max_donation2_tax_exem		number,
        max_donation3_tax_exem          number,
	donation2_tax_exem		number,
	donation3_tax_exem		number,
	donation_tax_exem		number,
        marriage_exemption              number,
        funeral_exemption               number,
        relocation_exemption            number,
        marr_fun_relo_exemption         number,
	sp_tax_exem			number,
	std_sp_tax_exem			number,
	np_prem				number,
	np_prem_tax_exem		number,
	pen_prem			number,    -- Bug 6024342
	taxable_income2			number,
	pers_pension_prem		number,
	pers_pension_prem_tax_exem	number,
	-- Bug 4750653
	corp_pension_prem		number,
	corp_pension_prem_tax_exem	number,
	pers_pension_saving		number,
	pers_pension_saving_tax_exem	number,
	invest_partner_fin1		number,
	invest_partner_fin2		number,
        invest_partner_fin3		number,  -- 8237227
	invest_partner_fin_tax_exem	number,
	small_bus_install		number, -- Bug 6895093
	small_bus_install_exem		number, -- Bug 6895093
	credit_card_exp			number,
	credit_card_exp_tax_exem	number,
        emp_stk_own_contri              number,
        emp_stk_own_contri_tax_exem     number,
	taxation_base			number,
	calc_tax			number,
	basic_tax_break			number,
	housing_loan_interest_repay	number,
	housing_exp_tax_break		number,
	stock_saving			number,
	stock_saving_tax_break		number,
	lt_stock_saving1		number,
	lt_stock_saving2		number,
	lt_stock_saving_tax_break	number,
	ovstb_tax_paid_date		number,
	ovstb_territory_code		number,
	ovstb_currency_code		number,
	ovstb_taxable			number,
	ovstb_taxable_subj_tax_break	number,
	ovstb_tax_break_rate		number,
	ovstb_tax_foreign_currency	number,
	ovstb_tax			number,
	ovstb_application_date		number,
	ovstb_submission_date		number,
	ovs_tax_break			number,
	total_tax_break			number,
	fwtb_immigration_purpose	number,
	fwtb_contract_date		number,
	fwtb_expiry_date		number,
	fwtb_application_date		number,
	fwtb_submission_date		number,
	foreign_worker_tax_break1	number,
	foreign_worker_tax_break2	number,
	foreign_worker_tax_break	number,
	annual_itax			number,
	annual_rtax			number,
	annual_stax			number,
	prev_itax			number,
	prev_rtax			number,
	prev_stax			number,
	cur_itax			number,
	cur_rtax			number,
	cur_stax			number,
	itax_adj			number,
	rtax_adj			number,
	stax_adj			number,
	-- Bug 3966549
	don_tax_break2004		number,
	-- End of 3966549
        cash_receipt_expense            number, -- 4738717
	-- Bug 6630135
        tot_med_exp_cards               number,
	med_exp_paid_not_inc_med_exem   number,
	-- End of 6630135
        double_exem_amt                 number, -- 6716401
        tax_grp_bus_reg_num             number, -- Bug 7361372
        tax_grp_name                    number, -- Bug 7361372
	tax_grp_wkpd_from		number,	-- Bug 8644512
	tax_grp_wkpd_to			number,	-- Bug 8644512
	tax_grp_tax_brk_pd_from		number,	-- Bug 8644512
	tax_grp_tax_brk_pd_to		number,	-- Bug 8644512
        tax_grp_taxable_mth             number, -- Bug 7361372
        tax_grp_taxable_bon             number, -- Bug 7361372
        tax_grp_sp_irreg_bonus          number, -- Bug 7361372
        tax_grp_stck_pur_opt_exec_earn  number, -- Bug 7361372
	tax_grp_esop_withd_earn		number, -- Bug 8644512
	tax_grp_esop_withd_earn_ne	number, -- Bug 8644512
        tax_grp_itax  	                number, -- Bug 7361372
        tax_grp_rtax        	        number, -- Bug 7361372
        tax_grp_stax             	number, -- Bug 7361372
        tax_grp_taxable                 number, -- Bug 7361372
        tax_grp_post_tax_deduc          number, -- Bug 7361372
	tax_grp_taxable_mth_ne          number, -- Bug 7508706
        tax_grp_taxable_bon_ne          number, -- Bug 7508706
        tax_grp_sp_irreg_bonus_ne       number, -- Bug 7508706
        tax_grp_stck_pur_ne 		number, -- Bug 7508706
        tax_grp_taxable_ne              number, -- Bug 7508706
	tax_grp_non_taxable_ovt		number, -- Bug 8644512
	tax_grp_bir_raising_allw	number, -- Bug 8644512
	tax_grp_fw_income_exem		number, -- Bug 8644512
	company_related_exp		number, -- Bug 7615517
	long_term_stck_fund_1year	number, -- Bug 7615517
	long_term_stck_fund_2year	number, -- Bug 7615517
	long_term_stck_fund_3year	number, -- Bug 7615517
	long_term_stck_fund_tax_exem	number, -- Bug 7615517
	--
	cur_ntax_G01			number, -- Bug 8644512
	cur_ntax_H01			number, -- Bug 8644512
	cur_ntax_H05			number, -- Bug 8644512
	cur_ntax_H06			number, -- Bug 8644512
	cur_ntax_H07			number, -- Bug 8644512
	cur_ntax_H08			number, -- Bug 8644512
	cur_ntax_H09			number, -- Bug 8644512
	cur_ntax_H10			number, -- Bug 8644512
	cur_ntax_H11			number, -- Bug 8644512
	cur_ntax_H12			number, -- Bug 8644512
	cur_ntax_H13			number, -- Bug 8644512
	cur_ntax_I01			number, -- Bug 8644512
	cur_ntax_K01			number, -- Bug 8644512
	cur_ntax_M01			number, -- Bug 8644512
	cur_ntax_M02			number, -- Bug 8644512
	cur_ntax_M03			number, -- Bug 8644512
	cur_ntax_S01			number, -- Bug 8644512
	cur_ntax_T01			number, -- Bug 8644512
	cur_ntax_Y01			number, -- Bug 8644512
	cur_ntax_Y02			number, -- Bug 8644512
	cur_ntax_Y03			number, -- Bug 8644512
	cur_ntax_Y20			number, -- Bug 8644512
	cur_ntax_Z01			number, -- Bug 8644512
	cur_ntax_frgn_M01		number, -- Bug 8880364
	cur_ntax_frgn_M02		number, -- Bug 8880364
	cur_ntax_frgn_M03		number, -- Bug 8880364
	--
	prev_ntax_G01			number, -- Bug 8644512
	prev_ntax_H01			number, -- Bug 8644512
	prev_ntax_H05			number, -- Bug 8644512
	prev_ntax_H06			number, -- Bug 8644512
	prev_ntax_H07			number, -- Bug 8644512
	prev_ntax_H08			number, -- Bug 8644512
	prev_ntax_H09			number, -- Bug 8644512
	prev_ntax_H10			number, -- Bug 8644512
	prev_ntax_H11			number, -- Bug 8644512
	prev_ntax_H12			number, -- Bug 8644512
	prev_ntax_H13			number, -- Bug 8644512
	prev_ntax_I01			number, -- Bug 8644512
	prev_ntax_K01			number, -- Bug 8644512
	prev_ntax_M01			number, -- Bug 8644512
	prev_ntax_M02			number, -- Bug 8644512
	prev_ntax_M03			number, -- Bug 8644512
	prev_ntax_S01			number, -- Bug 8644512
	prev_ntax_T01			number, -- Bug 8644512
	prev_ntax_Y01			number, -- Bug 8644512
	prev_ntax_Y02			number, -- Bug 8644512
	prev_ntax_Y03			number, -- Bug 8644512
	prev_ntax_Y20			number, -- Bug 8644512
	prev_ntax_Z01			number, -- Bug 8644512
	--
	tax_grp_ntax_G01		number, -- Bug 8644512
	tax_grp_ntax_H01		number, -- Bug 8644512
	tax_grp_ntax_H05		number, -- Bug 8644512
	tax_grp_ntax_H06		number, -- Bug 8644512
	tax_grp_ntax_H07		number, -- Bug 8644512
	tax_grp_ntax_H08		number, -- Bug 8644512
	tax_grp_ntax_H09		number, -- Bug 8644512
	tax_grp_ntax_H10		number, -- Bug 8644512
	tax_grp_ntax_H11		number, -- Bug 8644512
	tax_grp_ntax_H12		number, -- Bug 8644512
	tax_grp_ntax_H13		number, -- Bug 8644512
	tax_grp_ntax_I01		number, -- Bug 8644512
	tax_grp_ntax_K01		number, -- Bug 8644512
	tax_grp_ntax_M01		number, -- Bug 8644512
	tax_grp_ntax_M02		number, -- Bug 8644512
	tax_grp_ntax_M03		number, -- Bug 8644512
	tax_grp_ntax_S01		number, -- Bug 8644512
	tax_grp_ntax_T01		number, -- Bug 8644512
	tax_grp_ntax_Y01		number, -- Bug 8644512
	tax_grp_ntax_Y02		number, -- Bug 8644512
	tax_grp_ntax_Y03		number, -- Bug 8644512
	tax_grp_ntax_Y20		number, -- Bug 8644512
	tax_grp_ntax_Z01		number, -- Bug 8644512
	--
	total_ntax_G01			number, -- Bug 8644512
	total_ntax_H01			number, -- Bug 8644512
	total_ntax_H05			number, -- Bug 8644512
	total_ntax_H06			number, -- Bug 8644512
	total_ntax_H07			number, -- Bug 8644512
	total_ntax_H08			number, -- Bug 8644512
	total_ntax_H09			number, -- Bug 8644512
	total_ntax_H10			number, -- Bug 8644512
	total_ntax_H11			number, -- Bug 8644512
	total_ntax_H12			number, -- Bug 8644512
	total_ntax_H13			number, -- Bug 8644512
	total_ntax_I01			number, -- Bug 8644512
	total_ntax_K01			number, -- Bug 8644512
	total_ntax_M01			number, -- Bug 8644512
	total_ntax_M02			number, -- Bug 8644512
	total_ntax_M03			number, -- Bug 8644512
	total_ntax_S01			number, -- Bug 8644512
	total_ntax_T01			number, -- Bug 8644512
	total_ntax_Y01			number, -- Bug 8644512
	total_ntax_Y02			number, -- Bug 8644512
	total_ntax_Y03			number, -- Bug 8644512
	total_ntax_Y20			number, -- Bug 8644512
	total_ntax_Z01			number, -- Bug 8644512
	--
	cur_total_ntax_earn		number,	-- Bug 8644512
	tax_grp_total_ntax_earn		number, -- Bug 8644512
	--
	smb_income_exem			number, -- Bug 9079450
	cur_smb_days_worked 		number, -- Bug 9079450
	prev_smb_days_worked 		number, -- Bug 9079450
	cur_smb_eligible_income		number, -- Bug 9079450
	prev_smb_eligible_income	number, -- Bug 9079450
	emp_join_prev_year		number,	-- Bug 9079450
	emp_leave_cur_year		number,	-- Bug 9079450
	smb_eligibility_flag		number  -- Bug 9079450
	) ;
--
g_user_entity_id	t_user_entity_id;
------------------------------------------------------------------------
-- PAY_REPORT_FORMAT_ITEMS_F Cache
------------------------------------------------------------------------
type t_archive_item is record(
	report_type		pay_report_format_mappings_f.report_type%TYPE,
	report_qualifier	pay_report_format_mappings_f.report_qualifier%TYPE,
	report_category		pay_report_format_mappings_f.report_category%TYPE,
	effective_date		date,
	archive_item_tbl	t_varchar2_tbl); -- user_entity_id indexed PL/SQL table
g_archive_item	t_archive_item;
------------------------------------------------------------------------
-- Global variable for debugging
------------------------------------------------------------------------
g_debug   constant    boolean  := hr_utility.debug_enabled;
l_pay_periods_per_year constant number := 12;
------------------------------------------------------------------------
function convert_to_rec(
	p_user_entity_id_tbl		in t_number_tbl,
	p_archive_item_value_tbl	in t_varchar2_tbl) return t_yea_info
------------------------------------------------------------------------
is
	l_yea_info			t_yea_info;
	l_archive_item_value_tbl	t_varchar2_tbl;
	----------------------------------------------------------------
	procedure set_archive_item(
		p_user_entity_id	in number,
		p_archive_item_value	in out nocopy varchar2)
	----------------------------------------------------------------
	is
	begin
		if l_archive_item_value_tbl.exists(p_user_entity_id) then
			p_archive_item_value := l_archive_item_value_tbl(p_user_entity_id);
		end if;
	end set_archive_item;
	----------------------------------------------------------------
	procedure set_archive_item(
		p_user_entity_id	in number,
		p_archive_item_value	in out nocopy number)
	----------------------------------------------------------------
	is
	begin
		if l_archive_item_value_tbl.exists(p_user_entity_id) then
			p_archive_item_value := fnd_number.canonical_to_number(l_archive_item_value_tbl(p_user_entity_id)); -- Bug 7149878
		end if;
	end set_archive_item;
	----------------------------------------------------------------
	procedure set_archive_item(
		p_user_entity_id	in number,
		p_archive_item_value	in out nocopy date)
	----------------------------------------------------------------
	is
	begin
		if l_archive_item_value_tbl.exists(p_user_entity_id) then
			p_archive_item_value := fnd_date.canonical_to_date(l_archive_item_value_tbl(p_user_entity_id));
		end if;
	end set_archive_item;
begin
	------------------------------------------------------------------------
	-- Re-construct above PL/SQL table to user_entity_id indexed PL/SQL table.
	------------------------------------------------------------------------
	for i in 1..p_user_entity_id_tbl.count loop
		l_archive_item_value_tbl(p_user_entity_id_tbl(i)) := p_archive_item_value_tbl(i);
	end loop;
	------------------------------------------------------------------------
	-- Convert user_entity_id indexed PL/SQL table to PL/SQL record
	------------------------------------------------------------------------
	set_archive_item(g_user_entity_id.non_resident_flag, l_yea_info.non_resident_flag);
	set_archive_item(g_user_entity_id.foreign_residency_flag, l_yea_info.foreign_residency_flag); -- Bug 6615356
	set_archive_item(g_user_entity_id.fw_fixed_tax_rate, l_yea_info.fixed_tax_rate); -- 3546993
	set_archive_item(g_user_entity_id.nationality, l_yea_info.nationality); -- Bug 7595082
	set_archive_item(g_user_entity_id.cur_taxable_mth, l_yea_info.cur_taxable_mth);
	set_archive_item(g_user_entity_id.cur_taxable_bon, l_yea_info.cur_taxable_bon);
	set_archive_item(g_user_entity_id.cur_sp_irreg_bonus, l_yea_info.cur_sp_irreg_bonus);
	set_archive_item(g_user_entity_id.cur_taxable, l_yea_info.cur_taxable);
	set_archive_item(g_user_entity_id.cur_non_taxable_ovt, l_yea_info.cur_non_taxable_ovt);		-- Bug 8644512
	set_archive_item(g_user_entity_id.prev_non_taxable_ovt, l_yea_info.prev_non_taxable_ovt);	-- Bug 8644512
	set_archive_item(g_user_entity_id.cur_fw_income_exem, l_yea_info.cur_fw_income_exem);		-- Bug 8644512
	set_archive_item(g_user_entity_id.prev_taxable_mth, l_yea_info.prev_taxable_mth);
	set_archive_item(g_user_entity_id.prev_taxable_bon, l_yea_info.prev_taxable_bon);
	set_archive_item(g_user_entity_id.prev_sp_irreg_bonus, l_yea_info.prev_sp_irreg_bonus);
	set_archive_item(g_user_entity_id.prev_foreign_wrkr_inc_exem, l_yea_info.prev_foreign_wrkr_inc_exem); -- Bug 8341054
	--Bug 6024342
	set_archive_item(g_user_entity_id.prev_stck_pur_opt_exec_earn, l_yea_info.prev_stck_pur_opt_exec_earn);
	--
	-- Bug 8644512
	set_archive_item(g_user_entity_id.prev_esop_withd_earn,l_yea_info.prev_esop_withd_earn);
	set_archive_item(g_user_entity_id.cur_esop_withd_earn,l_yea_info.cur_esop_withd_earn);
	set_archive_item(g_user_entity_id.esop_withd_earn,l_yea_info.esop_withd_earn);
	--
	-- bug 6012258
	set_archive_item(g_user_entity_id.cur_stck_pur_opt_exec_earn, l_yea_info.cur_stck_pur_opt_exec_earn);
	set_archive_item(g_user_entity_id.research_payment, l_yea_info.research_payment);
	--
	-- Bug 6024342
	set_archive_item(g_user_entity_id.stck_pur_opt_exec_earn, l_yea_info.stck_pur_opt_exec_earn);
	--
	set_archive_item(g_user_entity_id.prev_taxable, l_yea_info.prev_taxable);
	set_archive_item(g_user_entity_id.taxable_mth, l_yea_info.taxable_mth);
	set_archive_item(g_user_entity_id.taxable_bon, l_yea_info.taxable_bon);
	set_archive_item(g_user_entity_id.sp_irreg_bonus, l_yea_info.sp_irreg_bonus);
	set_archive_item(g_user_entity_id.taxable, l_yea_info.taxable);
	set_archive_item(g_user_entity_id.taxable1, l_yea_info.taxable1); --Bug 7615517
	set_archive_item(g_user_entity_id.non_taxable_ovs, l_yea_info.non_taxable_ovs);
	set_archive_item(g_user_entity_id.non_taxable_ovt, l_yea_info.non_taxable_ovt);
	-- Bug 7439803
	set_archive_item(g_user_entity_id.non_taxable_ovs_frgn, l_yea_info.non_taxable_ovs_frgn);
	--
	set_archive_item(g_user_entity_id.non_taxable_oth, l_yea_info.non_taxable_oth);
	set_archive_item(g_user_entity_id.non_rep_non_taxable, l_yea_info.non_rep_non_taxable); -- Bug 9079450
	set_archive_item(g_user_entity_id.non_taxable, l_yea_info.non_taxable);
	set_archive_item(g_user_entity_id.foreign_worker_income_exem, l_yea_info.foreign_worker_income_exem);  -- 3546993
	set_archive_item(g_user_entity_id.basic_income_exem, l_yea_info.basic_income_exem);
	set_archive_item(g_user_entity_id.taxable_income, l_yea_info.taxable_income);
	set_archive_item(g_user_entity_id.ee_tax_exem, l_yea_info.ee_tax_exem);
	set_archive_item(g_user_entity_id.dpnt_spouse_flag, l_yea_info.dpnt_spouse_flag);
	set_archive_item(g_user_entity_id.dpnt_spouse_tax_exem, l_yea_info.dpnt_spouse_tax_exem);
	set_archive_item(g_user_entity_id.num_of_aged_dpnts, l_yea_info.num_of_aged_dpnts);
	set_archive_item(g_user_entity_id.num_of_adult_dpnts, l_yea_info.num_of_adult_dpnts);
	set_archive_item(g_user_entity_id.num_of_underaged_dpnts, l_yea_info.num_of_underaged_dpnts);
	set_archive_item(g_user_entity_id.num_of_dpnts, l_yea_info.num_of_dpnts);
	set_archive_item(g_user_entity_id.dpnt_tax_exem, l_yea_info.dpnt_tax_exem);
	set_archive_item(g_user_entity_id.num_of_ageds, l_yea_info.num_of_ageds);
	-- Bug 3172960
	set_archive_item(g_user_entity_id.num_of_super_ageds, l_yea_info.num_of_super_ageds);
	-- Bug 6705170
        set_archive_item(g_user_entity_id.num_of_new_born_adopted, l_yea_info.num_of_new_born_adopted);
        set_archive_item(g_user_entity_id.new_born_adopted_tax_exem, l_yea_info.new_born_adopted_tax_exem);
	--
	-- Bug 6784288
        set_archive_item(g_user_entity_id.num_of_addtl_child, l_yea_info.num_of_addtl_child);
	--
	set_archive_item(g_user_entity_id.aged_tax_exem, l_yea_info.aged_tax_exem);
	set_archive_item(g_user_entity_id.num_of_disableds, l_yea_info.num_of_disableds);
	set_archive_item(g_user_entity_id.disabled_tax_exem, l_yea_info.disabled_tax_exem);
	set_archive_item(g_user_entity_id.female_ee_flag, l_yea_info.female_ee_flag);
	set_archive_item(g_user_entity_id.female_ee_tax_exem, l_yea_info.female_ee_tax_exem);
	set_archive_item(g_user_entity_id.num_of_children, l_yea_info.num_of_children);
	set_archive_item(g_user_entity_id.child_tax_exem, l_yea_info.child_tax_exem);
	-- Bug 5756690
	set_archive_item(g_user_entity_id.addl_child_tax_exem, l_yea_info.addl_child_tax_exem);
	set_archive_item(g_user_entity_id.supp_tax_exem, l_yea_info.supp_tax_exem);
	set_archive_item(g_user_entity_id.hi_prem, l_yea_info.hi_prem);
	set_archive_item(g_user_entity_id.hi_prem_tax_exem, l_yea_info.hi_prem_tax_exem);
	-- Bug 7164589
	set_archive_item(g_user_entity_id.long_term_ins_prem, l_yea_info.long_term_ins_prem);
	set_archive_item(g_user_entity_id.long_term_ins_prem_tax_exem, l_yea_info.long_term_ins_prem_tax_exem);
	-- End of Bug 7164589
	set_archive_item(g_user_entity_id.ei_prem, l_yea_info.ei_prem);
	set_archive_item(g_user_entity_id.ei_prem_tax_exem, l_yea_info.ei_prem_tax_exem);
	set_archive_item(g_user_entity_id.pers_ins_name, l_yea_info.pers_ins_name);
	set_archive_item(g_user_entity_id.pers_ins_prem, l_yea_info.pers_ins_prem);
	set_archive_item(g_user_entity_id.pers_ins_prem_tax_exem, l_yea_info.pers_ins_prem_tax_exem);
	set_archive_item(g_user_entity_id.disabled_ins_prem, l_yea_info.disabled_ins_prem);
	set_archive_item(g_user_entity_id.disabled_ins_prem_tax_exem, l_yea_info.disabled_ins_prem_tax_exem);
	set_archive_item(g_user_entity_id.ins_prem_tax_exem, l_yea_info.ins_prem_tax_exem);
	set_archive_item(g_user_entity_id.med_exp, l_yea_info.med_exp);
	set_archive_item(g_user_entity_id.med_exp_disabled, l_yea_info.med_exp_disabled);
	set_archive_item(g_user_entity_id.med_exp_aged, l_yea_info.med_exp_aged);
	-- Bug 3172960
	set_archive_item(g_user_entity_id.med_exp_emp, l_yea_info.med_exp_emp);
	set_archive_item(g_user_entity_id.max_med_exp_tax_exem, l_yea_info.max_med_exp_tax_exem);
	set_archive_item(g_user_entity_id.med_exp_tax_exem, l_yea_info.med_exp_tax_exem);
	set_archive_item(g_user_entity_id.ee_educ_exp, l_yea_info.ee_educ_exp);
	set_archive_item(g_user_entity_id.spouse_educ_exp, l_yea_info.spouse_educ_exp);
	set_archive_item(g_user_entity_id.disabled_educ_exp, l_yea_info.disabled_educ_exp);
	set_archive_item(g_user_entity_id.dpnt_educ_exp, l_yea_info.dpnt_educ_exp);
	set_archive_item(g_user_entity_id.educ_exp_tax_exem, l_yea_info.educ_exp_tax_exem);
	set_archive_item(g_user_entity_id.housing_saving_type, l_yea_info.housing_saving_type);
	set_archive_item(g_user_entity_id.housing_saving, l_yea_info.housing_saving);
	set_archive_item(g_user_entity_id.housing_purchase_date, l_yea_info.housing_purchase_date);
	set_archive_item(g_user_entity_id.housing_loan_date, l_yea_info.housing_loan_date);
	set_archive_item(g_user_entity_id.housing_loan_repay, l_yea_info.housing_loan_repay);
	set_archive_item(g_user_entity_id.lt_housing_loan_date, l_yea_info.lt_housing_loan_date);
	set_archive_item(g_user_entity_id.lt_housing_loan_interest_repay, l_yea_info.lt_housing_loan_interest_repay);
	set_archive_item(g_user_entity_id.max_housing_exp_tax_exem, l_yea_info.max_housing_exp_tax_exem);
	set_archive_item(g_user_entity_id.housing_exp_tax_exem, l_yea_info.housing_exp_tax_exem);
	set_archive_item(g_user_entity_id.donation1, l_yea_info.donation1);
	set_archive_item(g_user_entity_id.political_donation1, l_yea_info.political_donation1);
	set_archive_item(g_user_entity_id.political_donation2, l_yea_info.political_donation2);
	set_archive_item(g_user_entity_id.political_donation3, l_yea_info.political_donation3);
	set_archive_item(g_user_entity_id.donation1_tax_exem, l_yea_info.donation1_tax_exem);
	set_archive_item(g_user_entity_id.donation2, l_yea_info.donation2);
	set_archive_item(g_user_entity_id.donation3, l_yea_info.donation3);
	set_archive_item(g_user_entity_id.donation4, l_yea_info.donation4);  -- Bug 7142612
	set_archive_item(g_user_entity_id.religious_donation, l_yea_info.religious_donation);  -- Bug 7142612
	set_archive_item(g_user_entity_id.max_donation2_tax_exem, l_yea_info.max_donation2_tax_exem);
	set_archive_item(g_user_entity_id.max_donation3_tax_exem, l_yea_info.max_donation3_tax_exem);
	set_archive_item(g_user_entity_id.donation2_tax_exem, l_yea_info.donation2_tax_exem);
	set_archive_item(g_user_entity_id.donation3_tax_exem, l_yea_info.donation3_tax_exem);
	set_archive_item(g_user_entity_id.donation_tax_exem, l_yea_info.donation_tax_exem);
	-- Bug 3966549
	set_archive_item(g_user_entity_id.don_tax_break2004, l_yea_info.don_tax_break2004) ;
	-- End of 3966549
        set_archive_item(g_user_entity_id.marriage_exemption, l_yea_info.marriage_exemption);
        set_archive_item(g_user_entity_id.funeral_exemption, l_yea_info.funeral_exemption);
        set_archive_item(g_user_entity_id.relocation_exemption, l_yea_info.relocation_exemption);
        set_archive_item(g_user_entity_id.marr_fun_relo_exemption, l_yea_info.marr_fun_relo_exemption);
	set_archive_item(g_user_entity_id.sp_tax_exem, l_yea_info.sp_tax_exem);
	-- Bug 7142620
	set_archive_item(g_user_entity_id.housing_saving_exem, l_yea_info.housing_saving_exem);
	set_archive_item(g_user_entity_id.housing_loan_repay_exem, l_yea_info.housing_loan_repay_exem);
	set_archive_item(g_user_entity_id.lt_housing_loan_intr_exem, l_yea_info.lt_housing_loan_intr_exem);
	set_archive_item(g_user_entity_id.birth_raising_allowance,l_yea_info.birth_raising_allowance);
	set_archive_item(g_user_entity_id.cur_birth_raising_allowance,l_yea_info.cur_birth_raising_allowance); -- Bug 8644512
	set_archive_item(g_user_entity_id.prev_birth_raising_allowance,l_yea_info.prev_birth_raising_allowance); -- Bug 8644512
	--End of 7142620
	set_archive_item(g_user_entity_id.std_sp_tax_exem, l_yea_info.std_sp_tax_exem);
	set_archive_item(g_user_entity_id.np_prem, l_yea_info.np_prem);
	set_archive_item(g_user_entity_id.np_prem_tax_exem, l_yea_info.np_prem_tax_exem);
	-- Bug 6024342
	set_archive_item(g_user_entity_id.pen_prem, l_yea_info.pen_prem);
	--
	set_archive_item(g_user_entity_id.taxable_income2, l_yea_info.taxable_income2);
	set_archive_item(g_user_entity_id.pers_pension_prem, l_yea_info.pers_pension_prem);
	set_archive_item(g_user_entity_id.pers_pension_prem_tax_exem, l_yea_info.pers_pension_prem_tax_exem);
	-- Bug 4750653
	set_archive_item(g_user_entity_id.corp_pension_prem, l_yea_info.corp_pension_prem);
	set_archive_item(g_user_entity_id.corp_pension_prem_tax_exem, l_yea_info.corp_pension_prem_tax_exem);
	-- End of Bug 4750653
	set_archive_item(g_user_entity_id.pers_pension_saving, l_yea_info.pers_pension_saving);
	set_archive_item(g_user_entity_id.pers_pension_saving_tax_exem, l_yea_info.pers_pension_saving_tax_exem);
	set_archive_item(g_user_entity_id.invest_partner_fin1, l_yea_info.invest_partner_fin1);
	set_archive_item(g_user_entity_id.invest_partner_fin2, l_yea_info.invest_partner_fin2);
       	set_archive_item(g_user_entity_id.invest_partner_fin3, l_yea_info.invest_partner_fin3);  -- Bug 8237227
	set_archive_item(g_user_entity_id.invest_partner_fin_tax_exem, l_yea_info.invest_partner_fin_tax_exem);
	-- Bug 6895093
	set_archive_item(g_user_entity_id.small_bus_install, l_yea_info.small_bus_install);
	set_archive_item(g_user_entity_id.small_bus_install_exem, l_yea_info.small_bus_install_exem);
	-- End of Bug 6895093
	set_archive_item(g_user_entity_id.credit_card_exp, l_yea_info.credit_card_exp);
	set_archive_item(g_user_entity_id.credit_card_exp_tax_exem, l_yea_info.credit_card_exp_tax_exem);
        set_archive_item(g_user_entity_id.emp_stk_own_contri, l_yea_info.emp_stk_own_contri);
        set_archive_item(g_user_entity_id.emp_stk_own_contri_tax_exem, l_yea_info.emp_stk_own_contri_tax_exem);
	set_archive_item(g_user_entity_id.taxation_base, l_yea_info.taxation_base);
	set_archive_item(g_user_entity_id.calc_tax, l_yea_info.calc_tax);
	set_archive_item(g_user_entity_id.basic_tax_break, l_yea_info.basic_tax_break);
	set_archive_item(g_user_entity_id.housing_loan_interest_repay, l_yea_info.housing_loan_interest_repay);
	set_archive_item(g_user_entity_id.housing_exp_tax_break, l_yea_info.housing_exp_tax_break);
	set_archive_item(g_user_entity_id.stock_saving, l_yea_info.stock_saving);
	set_archive_item(g_user_entity_id.stock_saving_tax_break, l_yea_info.stock_saving_tax_break);
	set_archive_item(g_user_entity_id.lt_stock_saving1, l_yea_info.lt_stock_saving1);
	set_archive_item(g_user_entity_id.lt_stock_saving2, l_yea_info.lt_stock_saving2);
	set_archive_item(g_user_entity_id.lt_stock_saving_tax_break, l_yea_info.lt_stock_saving_tax_break);
	set_archive_item(g_user_entity_id.ovstb_tax_paid_date, l_yea_info.ovstb_tax_paid_date);
	set_archive_item(g_user_entity_id.ovstb_territory_code, l_yea_info.ovstb_territory_code);
	set_archive_item(g_user_entity_id.ovstb_currency_code, l_yea_info.ovstb_currency_code);
	set_archive_item(g_user_entity_id.ovstb_taxable, l_yea_info.ovstb_taxable);
	set_archive_item(g_user_entity_id.ovstb_taxable_subj_tax_break, l_yea_info.ovstb_taxable_subj_tax_break);
	set_archive_item(g_user_entity_id.ovstb_tax_break_rate, l_yea_info.ovstb_tax_break_rate);
	set_archive_item(g_user_entity_id.ovstb_tax_foreign_currency, l_yea_info.ovstb_tax_foreign_currency);
	set_archive_item(g_user_entity_id.ovstb_tax, l_yea_info.ovstb_tax);
	set_archive_item(g_user_entity_id.ovstb_application_date, l_yea_info.ovstb_application_date);
	set_archive_item(g_user_entity_id.ovstb_submission_date, l_yea_info.ovstb_submission_date);
	set_archive_item(g_user_entity_id.ovs_tax_break, l_yea_info.ovs_tax_break);
	set_archive_item(g_user_entity_id.total_tax_break, l_yea_info.total_tax_break);
	set_archive_item(g_user_entity_id.fwtb_immigration_purpose, l_yea_info.fwtb_immigration_purpose);
	set_archive_item(g_user_entity_id.fwtb_contract_date, l_yea_info.fwtb_contract_date);
	set_archive_item(g_user_entity_id.fwtb_expiry_date, l_yea_info.fwtb_expiry_date);
	set_archive_item(g_user_entity_id.fwtb_application_date, l_yea_info.fwtb_application_date);
	set_archive_item(g_user_entity_id.fwtb_submission_date, l_yea_info.fwtb_submission_date);
	set_archive_item(g_user_entity_id.foreign_worker_tax_break1, l_yea_info.foreign_worker_tax_break1);
	set_archive_item(g_user_entity_id.foreign_worker_tax_break2, l_yea_info.foreign_worker_tax_break2);
	set_archive_item(g_user_entity_id.foreign_worker_tax_break, l_yea_info.foreign_worker_tax_break);
	set_archive_item(g_user_entity_id.annual_itax, l_yea_info.annual_itax);
	set_archive_item(g_user_entity_id.annual_rtax, l_yea_info.annual_rtax);
	set_archive_item(g_user_entity_id.annual_stax, l_yea_info.annual_stax);
	set_archive_item(g_user_entity_id.prev_itax, l_yea_info.prev_itax);
	set_archive_item(g_user_entity_id.prev_rtax, l_yea_info.prev_rtax);
	set_archive_item(g_user_entity_id.prev_stax, l_yea_info.prev_stax);
	set_archive_item(g_user_entity_id.cur_itax, l_yea_info.cur_itax);
	set_archive_item(g_user_entity_id.cur_rtax, l_yea_info.cur_rtax);
	set_archive_item(g_user_entity_id.cur_stax, l_yea_info.cur_stax);
	set_archive_item(g_user_entity_id.itax_adj, l_yea_info.itax_adj);
	set_archive_item(g_user_entity_id.rtax_adj, l_yea_info.rtax_adj);
	set_archive_item(g_user_entity_id.stax_adj, l_yea_info.stax_adj);
	--
        -- Bug 6630135
        set_archive_item(g_user_entity_id.tot_med_exp_cards,l_yea_info.tot_med_exp_cards);
        set_archive_item(g_user_entity_id.med_exp_paid_not_inc_med_exem,l_yea_info.med_exp_paid_not_inc_med_exem);
        -- End of Bug 6630135
        -- Bug 6716401
        set_archive_item(g_user_entity_id.double_exem_amt,l_yea_info.double_exem_amt);
        -- End of Bug 6716401
        -- Bug 7361372
        set_archive_item(g_user_entity_id.tax_grp_bus_reg_num,l_yea_info.tax_grp_bus_reg_num);
        set_archive_item(g_user_entity_id.tax_grp_name,l_yea_info.tax_grp_name);
	-- Bug 8644512
	set_archive_item(g_user_entity_id.tax_grp_wkpd_from,l_yea_info.tax_grp_wkpd_from);
	set_archive_item(g_user_entity_id.tax_grp_wkpd_to,l_yea_info.tax_grp_wkpd_to);
	set_archive_item(g_user_entity_id.tax_grp_tax_brk_pd_from,l_yea_info.tax_grp_tax_brk_pd_from);
	set_archive_item(g_user_entity_id.tax_grp_tax_brk_pd_to,l_yea_info.tax_grp_tax_brk_pd_to);
	--
        set_archive_item(g_user_entity_id.tax_grp_taxable_mth,l_yea_info.tax_grp_taxable_mth);
        set_archive_item(g_user_entity_id.tax_grp_taxable_bon,l_yea_info.tax_grp_taxable_bon);
        set_archive_item(g_user_entity_id.tax_grp_sp_irreg_bonus,l_yea_info.tax_grp_sp_irreg_bonus);
        set_archive_item(g_user_entity_id.tax_grp_stck_pur_opt_exec_earn,l_yea_info.tax_grp_stck_pur_opt_exec_earn);
	-- Bug 8644512
	set_archive_item(g_user_entity_id.tax_grp_esop_withd_earn,l_yea_info.tax_grp_esop_withd_earn);
	--
        set_archive_item(g_user_entity_id.tax_grp_itax,l_yea_info.tax_grp_itax);
        set_archive_item(g_user_entity_id.tax_grp_rtax,l_yea_info.tax_grp_rtax);
        set_archive_item(g_user_entity_id.tax_grp_stax,l_yea_info.tax_grp_stax);
        set_archive_item(g_user_entity_id.tax_grp_taxable,l_yea_info.tax_grp_taxable);
        set_archive_item(g_user_entity_id.tax_grp_post_tax_deduc,l_yea_info.tax_grp_post_tax_deduc);
        -- End of Bug 7361372
	-- Bug 7508706
	set_archive_item(g_user_entity_id.tax_grp_taxable_mth_ne,l_yea_info.tax_grp_taxable_mth_ne);
        set_archive_item(g_user_entity_id.tax_grp_taxable_bon_ne,l_yea_info.tax_grp_taxable_bon_ne);
        set_archive_item(g_user_entity_id.tax_grp_sp_irreg_bonus_ne,l_yea_info.tax_grp_sp_irreg_bonus_ne);
        set_archive_item(g_user_entity_id.tax_grp_stck_pur_ne,l_yea_info.tax_grp_stck_pur_ne);
	-- Bug 8644512
	set_archive_item(g_user_entity_id.tax_grp_esop_withd_earn_ne,l_yea_info.tax_grp_esop_withd_earn_ne);
	set_archive_item(g_user_entity_id.tax_grp_non_taxable_ovt,l_yea_info.tax_grp_non_taxable_ovt);
	set_archive_item(g_user_entity_id.tax_grp_bir_raising_allw,l_yea_info.tax_grp_bir_raising_allw);
	set_archive_item(g_user_entity_id.tax_grp_fw_income_exem,l_yea_info.tax_grp_fw_income_exem);
	--
        set_archive_item(g_user_entity_id.tax_grp_taxable_ne,l_yea_info.tax_grp_taxable_ne);
	-- End of Bug 7508706
	-- Bug 7615517
	set_archive_item(g_user_entity_id.company_related_exp,l_yea_info.company_related_exp);
	set_archive_item(g_user_entity_id.long_term_stck_fund_1year,l_yea_info.long_term_stck_fund_1year);
	set_archive_item(g_user_entity_id.long_term_stck_fund_2year,l_yea_info.long_term_stck_fund_2year);
	set_archive_item(g_user_entity_id.long_term_stck_fund_3year,l_yea_info.long_term_stck_fund_3year);
	set_archive_item(g_user_entity_id.long_term_stck_fund_tax_exem,l_yea_info.long_term_stck_fund_tax_exem);
	-- End of bug 7615517
	--
	-- Bug 8644512
	set_archive_item(g_user_entity_id.cur_ntax_G01,l_yea_info.cur_ntax_G01);
	set_archive_item(g_user_entity_id.cur_ntax_H01,l_yea_info.cur_ntax_H01);
	set_archive_item(g_user_entity_id.cur_ntax_H05,l_yea_info.cur_ntax_H05);
	set_archive_item(g_user_entity_id.cur_ntax_H06,l_yea_info.cur_ntax_H06);
	set_archive_item(g_user_entity_id.cur_ntax_H07,l_yea_info.cur_ntax_H07);
	set_archive_item(g_user_entity_id.cur_ntax_H08,l_yea_info.cur_ntax_H08);
	set_archive_item(g_user_entity_id.cur_ntax_H09,l_yea_info.cur_ntax_H09);
	set_archive_item(g_user_entity_id.cur_ntax_H10,l_yea_info.cur_ntax_H10);
	set_archive_item(g_user_entity_id.cur_ntax_H11,l_yea_info.cur_ntax_H11);
	set_archive_item(g_user_entity_id.cur_ntax_H12,l_yea_info.cur_ntax_H12);
	set_archive_item(g_user_entity_id.cur_ntax_H13,l_yea_info.cur_ntax_H13);
	set_archive_item(g_user_entity_id.cur_ntax_I01,l_yea_info.cur_ntax_I01);
	set_archive_item(g_user_entity_id.cur_ntax_K01,l_yea_info.cur_ntax_K01);
	set_archive_item(g_user_entity_id.cur_ntax_M01,l_yea_info.cur_ntax_M01);
	set_archive_item(g_user_entity_id.cur_ntax_M02,l_yea_info.cur_ntax_M02);
	set_archive_item(g_user_entity_id.cur_ntax_M03,l_yea_info.cur_ntax_M03);
	set_archive_item(g_user_entity_id.cur_ntax_S01,l_yea_info.cur_ntax_S01);
	set_archive_item(g_user_entity_id.cur_ntax_T01,l_yea_info.cur_ntax_T01);
	set_archive_item(g_user_entity_id.cur_ntax_Y01,l_yea_info.cur_ntax_Y01);
	set_archive_item(g_user_entity_id.cur_ntax_Y02,l_yea_info.cur_ntax_Y02);
	set_archive_item(g_user_entity_id.cur_ntax_Y03,l_yea_info.cur_ntax_Y03);
	set_archive_item(g_user_entity_id.cur_ntax_Y20,l_yea_info.cur_ntax_Y20);
	set_archive_item(g_user_entity_id.cur_ntax_Z01,l_yea_info.cur_ntax_Z01);
	set_archive_item(g_user_entity_id.cur_ntax_frgn_M01,l_yea_info.cur_ntax_frgn_M01); /* Bug 8880364 */
	set_archive_item(g_user_entity_id.cur_ntax_frgn_M02,l_yea_info.cur_ntax_frgn_M02); /* Bug 8880364 */
	set_archive_item(g_user_entity_id.cur_ntax_frgn_M03,l_yea_info.cur_ntax_frgn_M03); /* Bug 8880364 */
	--
	set_archive_item(g_user_entity_id.prev_ntax_G01,l_yea_info.prev_ntax_G01);
	set_archive_item(g_user_entity_id.prev_ntax_H01,l_yea_info.prev_ntax_H01);
	set_archive_item(g_user_entity_id.prev_ntax_H05,l_yea_info.prev_ntax_H05);
	set_archive_item(g_user_entity_id.prev_ntax_H06,l_yea_info.prev_ntax_H06);
	set_archive_item(g_user_entity_id.prev_ntax_H07,l_yea_info.prev_ntax_H07);
	set_archive_item(g_user_entity_id.prev_ntax_H08,l_yea_info.prev_ntax_H08);
	set_archive_item(g_user_entity_id.prev_ntax_H09,l_yea_info.prev_ntax_H09);
	set_archive_item(g_user_entity_id.prev_ntax_H10,l_yea_info.prev_ntax_H10);
	set_archive_item(g_user_entity_id.prev_ntax_H11,l_yea_info.prev_ntax_H11);
	set_archive_item(g_user_entity_id.prev_ntax_H12,l_yea_info.prev_ntax_H12);
	set_archive_item(g_user_entity_id.prev_ntax_H13,l_yea_info.prev_ntax_H13);
	set_archive_item(g_user_entity_id.prev_ntax_I01,l_yea_info.prev_ntax_I01);
	set_archive_item(g_user_entity_id.prev_ntax_K01,l_yea_info.prev_ntax_K01);
	set_archive_item(g_user_entity_id.prev_ntax_M01,l_yea_info.prev_ntax_M01);
	set_archive_item(g_user_entity_id.prev_ntax_M02,l_yea_info.prev_ntax_M02);
	set_archive_item(g_user_entity_id.prev_ntax_M03,l_yea_info.prev_ntax_M03);
	set_archive_item(g_user_entity_id.prev_ntax_S01,l_yea_info.prev_ntax_S01);
	set_archive_item(g_user_entity_id.prev_ntax_T01,l_yea_info.prev_ntax_T01);
	set_archive_item(g_user_entity_id.prev_ntax_Y01,l_yea_info.prev_ntax_Y01);
	set_archive_item(g_user_entity_id.prev_ntax_Y02,l_yea_info.prev_ntax_Y02);
	set_archive_item(g_user_entity_id.prev_ntax_Y03,l_yea_info.prev_ntax_Y03);
	set_archive_item(g_user_entity_id.prev_ntax_Y20,l_yea_info.prev_ntax_Y20);
	set_archive_item(g_user_entity_id.prev_ntax_Z01,l_yea_info.prev_ntax_Z01);
	--
	set_archive_item(g_user_entity_id.tax_grp_ntax_G01,l_yea_info.tax_grp_ntax_G01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H01,l_yea_info.tax_grp_ntax_H01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H05,l_yea_info.tax_grp_ntax_H05);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H06,l_yea_info.tax_grp_ntax_H06);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H07,l_yea_info.tax_grp_ntax_H07);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H08,l_yea_info.tax_grp_ntax_H08);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H09,l_yea_info.tax_grp_ntax_H09);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H10,l_yea_info.tax_grp_ntax_H10);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H11,l_yea_info.tax_grp_ntax_H11);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H12,l_yea_info.tax_grp_ntax_H12);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H13,l_yea_info.tax_grp_ntax_H13);
	set_archive_item(g_user_entity_id.tax_grp_ntax_I01,l_yea_info.tax_grp_ntax_I01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_K01,l_yea_info.tax_grp_ntax_K01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_M01,l_yea_info.tax_grp_ntax_M01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_M02,l_yea_info.tax_grp_ntax_M02);
	set_archive_item(g_user_entity_id.tax_grp_ntax_M03,l_yea_info.tax_grp_ntax_M03);
	set_archive_item(g_user_entity_id.tax_grp_ntax_S01,l_yea_info.tax_grp_ntax_S01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_T01,l_yea_info.tax_grp_ntax_T01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_Y01,l_yea_info.tax_grp_ntax_Y01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_Y02,l_yea_info.tax_grp_ntax_Y02);
	set_archive_item(g_user_entity_id.tax_grp_ntax_Y03,l_yea_info.tax_grp_ntax_Y03);
	set_archive_item(g_user_entity_id.tax_grp_ntax_Y20,l_yea_info.tax_grp_ntax_Y20);
	set_archive_item(g_user_entity_id.tax_grp_ntax_Z01,l_yea_info.tax_grp_ntax_Z01);
	--
	set_archive_item(g_user_entity_id.total_ntax_G01,l_yea_info.total_ntax_G01);
	set_archive_item(g_user_entity_id.total_ntax_H01,l_yea_info.total_ntax_H01);
	set_archive_item(g_user_entity_id.total_ntax_H05,l_yea_info.total_ntax_H05);
	set_archive_item(g_user_entity_id.total_ntax_H06,l_yea_info.total_ntax_H06);
	set_archive_item(g_user_entity_id.total_ntax_H07,l_yea_info.total_ntax_H07);
	set_archive_item(g_user_entity_id.total_ntax_H08,l_yea_info.total_ntax_H08);
	set_archive_item(g_user_entity_id.total_ntax_H09,l_yea_info.total_ntax_H09);
	set_archive_item(g_user_entity_id.total_ntax_H10,l_yea_info.total_ntax_H10);
	set_archive_item(g_user_entity_id.total_ntax_H11,l_yea_info.total_ntax_H11);
	set_archive_item(g_user_entity_id.total_ntax_H12,l_yea_info.total_ntax_H12);
	set_archive_item(g_user_entity_id.total_ntax_H13,l_yea_info.total_ntax_H13);
	set_archive_item(g_user_entity_id.total_ntax_I01,l_yea_info.total_ntax_I01);
	set_archive_item(g_user_entity_id.total_ntax_K01,l_yea_info.total_ntax_K01);
	set_archive_item(g_user_entity_id.total_ntax_M01,l_yea_info.total_ntax_M01);
	set_archive_item(g_user_entity_id.total_ntax_M02,l_yea_info.total_ntax_M02);
	set_archive_item(g_user_entity_id.total_ntax_M03,l_yea_info.total_ntax_M03);
	set_archive_item(g_user_entity_id.total_ntax_S01,l_yea_info.total_ntax_S01);
	set_archive_item(g_user_entity_id.total_ntax_T01,l_yea_info.total_ntax_T01);
	set_archive_item(g_user_entity_id.total_ntax_Y01,l_yea_info.total_ntax_Y01);
	set_archive_item(g_user_entity_id.total_ntax_Y02,l_yea_info.total_ntax_Y02);
	set_archive_item(g_user_entity_id.total_ntax_Y03,l_yea_info.total_ntax_Y03);
	set_archive_item(g_user_entity_id.total_ntax_Y20,l_yea_info.total_ntax_Y20);
	set_archive_item(g_user_entity_id.total_ntax_Z01,l_yea_info.total_ntax_Z01);
	--
	set_archive_item(g_user_entity_id.cur_total_ntax_earn,l_yea_info.cur_total_ntax_earn);
	set_archive_item(g_user_entity_id.tax_grp_total_ntax_earn,l_yea_info.tax_grp_total_ntax_earn);
	--
	set_archive_item(g_user_entity_id.smb_income_exem,l_yea_info.smb_income_exem); -- Bug 9079450
	set_archive_item(g_user_entity_id.cur_smb_days_worked,l_yea_info.cur_smb_days_worked);		 -- Bug 9079450
	set_archive_item(g_user_entity_id.prev_smb_days_worked,l_yea_info.prev_smb_days_worked); 	 -- Bug 9079450
	set_archive_item(g_user_entity_id.cur_smb_eligible_income,l_yea_info.cur_smb_eligible_income);	 -- Bug 9079450
	set_archive_item(g_user_entity_id.prev_smb_eligible_income,l_yea_info.prev_smb_eligible_income); -- Bug 9079450
	set_archive_item(g_user_entity_id.emp_join_prev_year,l_yea_info.emp_join_prev_year);	  	 -- Bug 9079450
	set_archive_item(g_user_entity_id.emp_leave_cur_year,l_yea_info.emp_leave_cur_year);	  	 -- Bug 9079450
	set_archive_item(g_user_entity_id.smb_eligibility_flag,l_yea_info.smb_eligibility_flag);	 -- Bug 9079450
	--
	-- End of bug 8644512

	return l_yea_info;
end convert_to_rec;
------------------------------------------------------------------------
procedure convert_to_tbl(
	p_report_type			in varchar2,
	p_report_qualifier		in varchar2,
	p_report_category		in varchar2,
	p_effective_date		in date,
	p_yea_info			in t_yea_info,
	p_user_entity_id_tbl		out nocopy t_number_tbl,
	p_archive_item_value_tbl	out nocopy t_varchar2_tbl)
------------------------------------------------------------------------
is
	l_user_entity_id_tbl		t_number_tbl;
	----------------------------------------------------------------
	procedure set_archive_item(
		p_user_entity_id	in number,
		p_archive_item_value	in varchar2)
	----------------------------------------------------------------
	is
		l_index	number;
	begin
		--------------------------------------------------------
		-- If ARCHIVE_ITEM is available in current report_type
		--------------------------------------------------------
		if g_archive_item.archive_item_tbl.exists(p_user_entity_id) then
			l_index := p_user_entity_id_tbl.count + 1;
			p_user_entity_id_tbl(l_index)     := p_user_entity_id;
			p_archive_item_value_tbl(l_index) := p_archive_item_value;
		end if;
	end set_archive_item;
	----------------------------------------------------------------
	procedure set_archive_item(
		p_user_entity_id	in number,
		p_archive_item_value	in number)
	----------------------------------------------------------------
	is
	begin
		set_archive_item(p_user_entity_id, to_char(p_archive_item_value));
	end set_archive_item;
	----------------------------------------------------------------
	procedure set_archive_item(
		p_user_entity_id	in number,
		p_archive_item_value	in date)
	----------------------------------------------------------------
	is
	begin
		set_archive_item(p_user_entity_id, fnd_date.date_to_canonical(p_archive_item_value));
	end set_archive_item;
begin
	if p_report_type = g_archive_item.report_type
	and p_report_qualifier = g_archive_item.report_qualifier
	and p_report_category = g_archive_item.report_category
	and p_effective_date = g_archive_item.effective_date then
		null;
	else
		------------------------------------------------------------------------
		-- Refresh PAY_REPORT_FORMAT_ITEMS_F cache information
		------------------------------------------------------------------------
		select	user_entity_id
		bulk collect into
			l_user_entity_id_tbl
		from	pay_report_format_items_f
		where	report_type = p_report_type
		and	report_qualifier = p_report_qualifier
		and	report_category = p_report_category
		and	p_effective_date
			between effective_start_date and effective_end_date;
		-----------------------------------------------------------------------
		g_archive_item.report_type	:= p_report_type;
		g_archive_item.report_qualifier	:= p_report_qualifier;
		g_archive_item.report_category	:= p_report_category;
		g_archive_item.effective_date	:= p_effective_date;
		------------------------------------------------------------------------
		-- Re-construct above PL/SQL table to user_entity_id indexed PL/SQL table.
		------------------------------------------------------------------------
		g_archive_item.archive_item_tbl.delete;
		for i in 1..l_user_entity_id_tbl.count loop
			g_archive_item.archive_item_tbl(l_user_entity_id_tbl(i)) := null;
		end loop;
	end if;
	--
	set_archive_item(g_user_entity_id.non_resident_flag, p_yea_info.non_resident_flag);
	set_archive_item(g_user_entity_id.foreign_residency_flag, p_yea_info.foreign_residency_flag); -- Bug 6615356
	set_archive_item(g_user_entity_id.fw_fixed_tax_rate, p_yea_info.fixed_tax_rate); -- 3546993
	set_archive_item(g_user_entity_id.nationality, p_yea_info.nationality); -- Bug 7595082
	set_archive_item(g_user_entity_id.cur_taxable_mth, p_yea_info.cur_taxable_mth);
	set_archive_item(g_user_entity_id.cur_taxable_bon, p_yea_info.cur_taxable_bon);
	set_archive_item(g_user_entity_id.cur_sp_irreg_bonus, p_yea_info.cur_sp_irreg_bonus);
	set_archive_item(g_user_entity_id.cur_taxable, p_yea_info.cur_taxable);
	set_archive_item(g_user_entity_id.cur_non_taxable_ovt, p_yea_info.cur_non_taxable_ovt);		-- Bug 8644512
	set_archive_item(g_user_entity_id.prev_non_taxable_ovt, p_yea_info.prev_non_taxable_ovt);	-- Bug 8644512
	set_archive_item(g_user_entity_id.cur_fw_income_exem, p_yea_info.cur_fw_income_exem);		-- Bug 8644512
	--
	if p_yea_info.prev_termination_date_tbl.count > 0 then
		set_archive_item(g_user_entity_id.prev_taxable_mth, p_yea_info.prev_taxable_mth);
		set_archive_item(g_user_entity_id.prev_taxable_bon, p_yea_info.prev_taxable_bon);
		set_archive_item(g_user_entity_id.prev_sp_irreg_bonus, p_yea_info.prev_sp_irreg_bonus);
		--Bug 6024342
		set_archive_item(g_user_entity_id.prev_stck_pur_opt_exec_earn, p_yea_info.prev_stck_pur_opt_exec_earn);
		--
		-- Bug 8644512
		set_archive_item(g_user_entity_id.prev_esop_withd_earn,p_yea_info.prev_esop_withd_earn);
		--
		set_archive_item(g_user_entity_id.prev_taxable, p_yea_info.prev_taxable);
		set_archive_item(g_user_entity_id.prev_itax, p_yea_info.prev_itax);
		set_archive_item(g_user_entity_id.prev_rtax, p_yea_info.prev_rtax);
		set_archive_item(g_user_entity_id.prev_stax, p_yea_info.prev_stax);
		set_archive_item(g_user_entity_id.prev_foreign_wrkr_inc_exem,p_yea_info.prev_foreign_wrkr_inc_exem); -- Bug 8341054
	end if;
	--
	-- bug 6012258
	set_archive_item(g_user_entity_id.cur_stck_pur_opt_exec_earn, p_yea_info.cur_stck_pur_opt_exec_earn);
	-- Bug 8644512
	set_archive_item(g_user_entity_id.cur_esop_withd_earn,p_yea_info.cur_esop_withd_earn);
	set_archive_item(g_user_entity_id.esop_withd_earn,p_yea_info.esop_withd_earn);
	--
	set_archive_item(g_user_entity_id.research_payment, p_yea_info.research_payment);
	--
	set_archive_item(g_user_entity_id.taxable_mth, p_yea_info.taxable_mth);
	set_archive_item(g_user_entity_id.taxable_bon, p_yea_info.taxable_bon);
	set_archive_item(g_user_entity_id.sp_irreg_bonus, p_yea_info.sp_irreg_bonus);
	-- Bug 6024342
	set_archive_item(g_user_entity_id.stck_pur_opt_exec_earn, p_yea_info.stck_pur_opt_exec_earn);
	--
	set_archive_item(g_user_entity_id.taxable, p_yea_info.taxable);
	set_archive_item(g_user_entity_id.taxable1, p_yea_info.taxable1); --Bug 7615517
	set_archive_item(g_user_entity_id.non_taxable_ovs, p_yea_info.non_taxable_ovs);
	set_archive_item(g_user_entity_id.non_taxable_ovt, p_yea_info.non_taxable_ovt);
	-- Bug 7439803
	set_archive_item(g_user_entity_id.non_taxable_ovs_frgn, p_yea_info.non_taxable_ovs_frgn);
	--
	set_archive_item(g_user_entity_id.non_taxable_oth, p_yea_info.non_taxable_oth);
	set_archive_item(g_user_entity_id.non_rep_non_taxable, p_yea_info.non_rep_non_taxable); -- Bug 9079450
	set_archive_item(g_user_entity_id.non_taxable, p_yea_info.non_taxable);
	set_archive_item(g_user_entity_id.foreign_worker_income_exem, p_yea_info.foreign_worker_income_exem);  --3546993
	set_archive_item(g_user_entity_id.basic_income_exem, p_yea_info.basic_income_exem);
	set_archive_item(g_user_entity_id.taxable_income, p_yea_info.taxable_income);
	set_archive_item(g_user_entity_id.ee_tax_exem, p_yea_info.ee_tax_exem);
	set_archive_item(g_user_entity_id.dpnt_spouse_flag, p_yea_info.dpnt_spouse_flag);
	set_archive_item(g_user_entity_id.dpnt_spouse_tax_exem, p_yea_info.dpnt_spouse_tax_exem);
	set_archive_item(g_user_entity_id.num_of_aged_dpnts, p_yea_info.num_of_aged_dpnts);
	set_archive_item(g_user_entity_id.num_of_adult_dpnts, p_yea_info.num_of_adult_dpnts);
	set_archive_item(g_user_entity_id.num_of_underaged_dpnts, p_yea_info.num_of_underaged_dpnts);
	set_archive_item(g_user_entity_id.num_of_dpnts, p_yea_info.num_of_dpnts);
	set_archive_item(g_user_entity_id.dpnt_tax_exem, p_yea_info.dpnt_tax_exem);
	set_archive_item(g_user_entity_id.num_of_ageds, p_yea_info.num_of_ageds);
	-- Bug 3172960
	set_archive_item(g_user_entity_id.num_of_super_ageds, p_yea_info.num_of_super_ageds);
	-- Bug 6705170
        set_archive_item(g_user_entity_id.num_of_new_born_adopted, p_yea_info.num_of_new_born_adopted);
        set_archive_item(g_user_entity_id.new_born_adopted_tax_exem, p_yea_info.new_born_adopted_tax_exem);
	--
	-- Bug 7142620
	set_archive_item(g_user_entity_id.housing_saving_exem, p_yea_info.housing_saving_exem);
	set_archive_item(g_user_entity_id.housing_loan_repay_exem, p_yea_info.housing_loan_repay_exem);
	set_archive_item(g_user_entity_id.lt_housing_loan_intr_exem, p_yea_info.lt_housing_loan_intr_exem);
	set_archive_item(g_user_entity_id.birth_raising_allowance,p_yea_info.birth_raising_allowance);
	set_archive_item(g_user_entity_id.cur_birth_raising_allowance,p_yea_info.cur_birth_raising_allowance); -- Bug 8644512
	set_archive_item(g_user_entity_id.prev_birth_raising_allowance,p_yea_info.prev_birth_raising_allowance); -- Bug 8644512
	-- End of Bug 7142620
	-- Bug 6784288
        set_archive_item(g_user_entity_id.num_of_addtl_child, p_yea_info.num_of_addtl_child);
	--
	set_archive_item(g_user_entity_id.aged_tax_exem, p_yea_info.aged_tax_exem);
	set_archive_item(g_user_entity_id.num_of_disableds, p_yea_info.num_of_disableds);
	set_archive_item(g_user_entity_id.disabled_tax_exem, p_yea_info.disabled_tax_exem);
	set_archive_item(g_user_entity_id.female_ee_flag, p_yea_info.female_ee_flag);
	set_archive_item(g_user_entity_id.female_ee_tax_exem, p_yea_info.female_ee_tax_exem);
	set_archive_item(g_user_entity_id.num_of_children, p_yea_info.num_of_children);
	set_archive_item(g_user_entity_id.child_tax_exem, p_yea_info.child_tax_exem);
	-- Bug 5756690
	set_archive_item(g_user_entity_id.addl_child_tax_exem, p_yea_info.addl_child_tax_exem);
	set_archive_item(g_user_entity_id.supp_tax_exem, p_yea_info.supp_tax_exem);
	set_archive_item(g_user_entity_id.hi_prem, p_yea_info.hi_prem);
	set_archive_item(g_user_entity_id.hi_prem_tax_exem, p_yea_info.hi_prem_tax_exem);
	-- Bug 7164589
	set_archive_item(g_user_entity_id.long_term_ins_prem, p_yea_info.long_term_ins_prem);
	set_archive_item(g_user_entity_id.long_term_ins_prem_tax_exem, p_yea_info.long_term_ins_prem_tax_exem);
	-- End of Bug 7164589
	set_archive_item(g_user_entity_id.ei_prem, p_yea_info.ei_prem);
	set_archive_item(g_user_entity_id.ei_prem_tax_exem, p_yea_info.ei_prem_tax_exem);
	set_archive_item(g_user_entity_id.pers_ins_name, p_yea_info.pers_ins_name);
	set_archive_item(g_user_entity_id.pers_ins_prem, p_yea_info.pers_ins_prem);
	set_archive_item(g_user_entity_id.pers_ins_prem_tax_exem, p_yea_info.pers_ins_prem_tax_exem);
	set_archive_item(g_user_entity_id.disabled_ins_prem, p_yea_info.disabled_ins_prem);
	set_archive_item(g_user_entity_id.disabled_ins_prem_tax_exem, p_yea_info.disabled_ins_prem_tax_exem);
	set_archive_item(g_user_entity_id.ins_prem_tax_exem, p_yea_info.ins_prem_tax_exem);
	set_archive_item(g_user_entity_id.med_exp, p_yea_info.med_exp);
	set_archive_item(g_user_entity_id.med_exp_disabled, p_yea_info.med_exp_disabled);
	set_archive_item(g_user_entity_id.med_exp_aged, p_yea_info.med_exp_aged);
	-- Bug 3172960
	set_archive_item(g_user_entity_id.med_exp_emp, p_yea_info.med_exp_emp);
	set_archive_item(g_user_entity_id.max_med_exp_tax_exem, p_yea_info.max_med_exp_tax_exem);
	set_archive_item(g_user_entity_id.med_exp_tax_exem, p_yea_info.med_exp_tax_exem);
	set_archive_item(g_user_entity_id.ee_educ_exp, p_yea_info.ee_educ_exp);
	set_archive_item(g_user_entity_id.spouse_educ_exp, p_yea_info.spouse_educ_exp);
	set_archive_item(g_user_entity_id.disabled_educ_exp, p_yea_info.disabled_educ_exp);
	set_archive_item(g_user_entity_id.dpnt_educ_exp, p_yea_info.dpnt_educ_exp);
	set_archive_item(g_user_entity_id.educ_exp_tax_exem, p_yea_info.educ_exp_tax_exem);
	set_archive_item(g_user_entity_id.housing_saving_type, p_yea_info.housing_saving_type);
	set_archive_item(g_user_entity_id.housing_saving, p_yea_info.housing_saving);
	set_archive_item(g_user_entity_id.housing_purchase_date, p_yea_info.housing_purchase_date);
	set_archive_item(g_user_entity_id.housing_loan_date, p_yea_info.housing_loan_date);
	set_archive_item(g_user_entity_id.housing_loan_repay, p_yea_info.housing_loan_repay);
	set_archive_item(g_user_entity_id.lt_housing_loan_date, p_yea_info.lt_housing_loan_date);
	set_archive_item(g_user_entity_id.lt_housing_loan_interest_repay, p_yea_info.lt_housing_loan_interest_repay);
	set_archive_item(g_user_entity_id.lt_housing_loan_date_1, p_yea_info.lt_housing_loan_date_1);
	set_archive_item(g_user_entity_id.lt_housing_loan_intr_repay_1, p_yea_info.lt_housing_loan_intr_repay_1);
       	set_archive_item(g_user_entity_id.lt_housing_loan_date_2, p_yea_info.lt_housing_loan_date_2);    -- Bug 8237227
        set_archive_item(g_user_entity_id.lt_housing_loan_intr_repay_2, p_yea_info.lt_housing_loan_intr_repay_2); -- Bug 8237227
	set_archive_item(g_user_entity_id.max_housing_exp_tax_exem, p_yea_info.max_housing_exp_tax_exem);
	set_archive_item(g_user_entity_id.housing_exp_tax_exem, p_yea_info.housing_exp_tax_exem);
	set_archive_item(g_user_entity_id.donation1, p_yea_info.donation1);
	set_archive_item(g_user_entity_id.political_donation1, p_yea_info.political_donation1);
	set_archive_item(g_user_entity_id.political_donation2, p_yea_info.political_donation2);
	set_archive_item(g_user_entity_id.political_donation3, p_yea_info.political_donation3);
	set_archive_item(g_user_entity_id.donation1_tax_exem, p_yea_info.donation1_tax_exem);
	set_archive_item(g_user_entity_id.donation2, p_yea_info.donation2);
        set_archive_item(g_user_entity_id.donation3, p_yea_info.donation3);
        set_archive_item(g_user_entity_id.donation4, p_yea_info.donation4);  -- Bug 7142612
	set_archive_item(g_user_entity_id.religious_donation, p_yea_info.religious_donation);  -- Bug 7142612
	set_archive_item(g_user_entity_id.max_donation2_tax_exem, p_yea_info.max_donation2_tax_exem);
	set_archive_item(g_user_entity_id.max_donation3_tax_exem, p_yea_info.max_donation3_tax_exem);
	set_archive_item(g_user_entity_id.donation2_tax_exem, p_yea_info.donation2_tax_exem);
	set_archive_item(g_user_entity_id.donation3_tax_exem, p_yea_info.donation3_tax_exem);
	set_archive_item(g_user_entity_id.donation_tax_exem, p_yea_info.donation_tax_exem);
	-- Bug 3966549
	set_archive_item(g_user_entity_id.don_tax_break2004, p_yea_info.don_tax_break2004) ;
	-- End of 3966549
	set_archive_item(g_user_entity_id.marriage_exemption, p_yea_info.marriage_exemption);
	set_archive_item(g_user_entity_id.funeral_exemption, p_yea_info.funeral_exemption);
	set_archive_item(g_user_entity_id.relocation_exemption, p_yea_info.relocation_exemption);
	set_archive_item(g_user_entity_id.marr_fun_relo_exemption, p_yea_info.marr_fun_relo_exemption);
	set_archive_item(g_user_entity_id.sp_tax_exem, p_yea_info.sp_tax_exem);
	set_archive_item(g_user_entity_id.std_sp_tax_exem, p_yea_info.std_sp_tax_exem);
	set_archive_item(g_user_entity_id.np_prem, p_yea_info.np_prem);
	set_archive_item(g_user_entity_id.np_prem_tax_exem, p_yea_info.np_prem_tax_exem);
	-- Bug 6024342
	set_archive_item(g_user_entity_id.pen_prem, p_yea_info.pen_prem);
	--
	set_archive_item(g_user_entity_id.taxable_income2, p_yea_info.taxable_income2);
	set_archive_item(g_user_entity_id.pers_pension_prem, p_yea_info.pers_pension_prem);
	set_archive_item(g_user_entity_id.pers_pension_prem_tax_exem, p_yea_info.pers_pension_prem_tax_exem);
	-- Bug 4750653
	set_archive_item(g_user_entity_id.corp_pension_prem, p_yea_info.corp_pension_prem);
	set_archive_item(g_user_entity_id.corp_pension_prem_tax_exem, p_yea_info.corp_pension_prem_tax_exem);
	--End of Bug 4750653
	set_archive_item(g_user_entity_id.pers_pension_saving, p_yea_info.pers_pension_saving);
	set_archive_item(g_user_entity_id.pers_pension_saving_tax_exem, p_yea_info.pers_pension_saving_tax_exem);
	set_archive_item(g_user_entity_id.invest_partner_fin1, p_yea_info.invest_partner_fin1);
	set_archive_item(g_user_entity_id.invest_partner_fin2, p_yea_info.invest_partner_fin2);
        set_archive_item(g_user_entity_id.invest_partner_fin3, p_yea_info.invest_partner_fin3);   -- Bug 8237227
	set_archive_item(g_user_entity_id.invest_partner_fin_tax_exem, p_yea_info.invest_partner_fin_tax_exem);
	-- Bug 6895093
	set_archive_item(g_user_entity_id.small_bus_install, p_yea_info.small_bus_install);
	set_archive_item(g_user_entity_id.small_bus_install_exem, p_yea_info.small_bus_install_exem);
	-- End of Bug 6895093
	set_archive_item(g_user_entity_id.credit_card_exp, p_yea_info.credit_card_exp);
	set_archive_item(g_user_entity_id.credit_card_exp_tax_exem, p_yea_info.credit_card_exp_tax_exem);
	--
        -- Bug 3201332
	-- Bug 3374792 added nvl
        set_archive_item(g_user_entity_id.emp_stk_own_contri, p_yea_info.emp_stk_own_contri + nvl(p_yea_info.fw_educ_expense,0) + nvl(p_yea_info.fw_house_rent,0));
	set_archive_item(g_user_entity_id.emp_stk_own_contri_tax_exem, p_yea_info.emp_stk_own_contri_tax_exem);
	set_archive_item(g_user_entity_id.taxation_base, p_yea_info.taxation_base);
	set_archive_item(g_user_entity_id.calc_tax, p_yea_info.calc_tax);
	set_archive_item(g_user_entity_id.basic_tax_break, p_yea_info.basic_tax_break);
	set_archive_item(g_user_entity_id.housing_loan_interest_repay, p_yea_info.housing_loan_interest_repay);
	set_archive_item(g_user_entity_id.housing_exp_tax_break, p_yea_info.housing_exp_tax_break);
	set_archive_item(g_user_entity_id.stock_saving, p_yea_info.stock_saving);
	set_archive_item(g_user_entity_id.stock_saving_tax_break, p_yea_info.stock_saving_tax_break);
	set_archive_item(g_user_entity_id.lt_stock_saving1, p_yea_info.lt_stock_saving1);
	set_archive_item(g_user_entity_id.lt_stock_saving2, p_yea_info.lt_stock_saving2);
	set_archive_item(g_user_entity_id.lt_stock_saving_tax_break, p_yea_info.lt_stock_saving_tax_break);
	--
	if p_yea_info.ovstb_tax_paid_date is not null then
		set_archive_item(g_user_entity_id.ovstb_tax_paid_date, p_yea_info.ovstb_tax_paid_date);
		set_archive_item(g_user_entity_id.ovstb_territory_code, p_yea_info.ovstb_territory_code);
		set_archive_item(g_user_entity_id.ovstb_currency_code, p_yea_info.ovstb_currency_code);
		set_archive_item(g_user_entity_id.ovstb_taxable, p_yea_info.ovstb_taxable);
		set_archive_item(g_user_entity_id.ovstb_taxable_subj_tax_break, p_yea_info.ovstb_taxable_subj_tax_break);
		set_archive_item(g_user_entity_id.ovstb_tax_break_rate, p_yea_info.ovstb_tax_break_rate);
		set_archive_item(g_user_entity_id.ovstb_tax_foreign_currency, p_yea_info.ovstb_tax_foreign_currency);
		set_archive_item(g_user_entity_id.ovstb_tax, p_yea_info.ovstb_tax);
		set_archive_item(g_user_entity_id.ovstb_application_date, p_yea_info.ovstb_application_date);
		set_archive_item(g_user_entity_id.ovstb_submission_date, p_yea_info.ovstb_submission_date);
		set_archive_item(g_user_entity_id.ovs_tax_break, p_yea_info.ovs_tax_break);
	end if;
	--
	set_archive_item(g_user_entity_id.total_tax_break, p_yea_info.total_tax_break);
	--
	if p_yea_info.fwtb_immigration_purpose is not null then
		set_archive_item(g_user_entity_id.fwtb_immigration_purpose, p_yea_info.fwtb_immigration_purpose);
		set_archive_item(g_user_entity_id.fwtb_contract_date, p_yea_info.fwtb_contract_date);
		set_archive_item(g_user_entity_id.fwtb_expiry_date, p_yea_info.fwtb_expiry_date);
		set_archive_item(g_user_entity_id.fwtb_application_date, p_yea_info.fwtb_application_date);
		set_archive_item(g_user_entity_id.fwtb_submission_date, p_yea_info.fwtb_submission_date);
		set_archive_item(g_user_entity_id.foreign_worker_tax_break1, p_yea_info.foreign_worker_tax_break1);
		set_archive_item(g_user_entity_id.foreign_worker_tax_break2, p_yea_info.foreign_worker_tax_break2);
		set_archive_item(g_user_entity_id.foreign_worker_tax_break, p_yea_info.foreign_worker_tax_break);
	end if;
	--
	set_archive_item(g_user_entity_id.annual_itax, p_yea_info.annual_itax);
	set_archive_item(g_user_entity_id.annual_rtax, p_yea_info.annual_rtax);
	set_archive_item(g_user_entity_id.annual_stax, p_yea_info.annual_stax);
	set_archive_item(g_user_entity_id.cur_itax, p_yea_info.cur_itax);
	set_archive_item(g_user_entity_id.cur_rtax, p_yea_info.cur_rtax);
	set_archive_item(g_user_entity_id.cur_stax, p_yea_info.cur_stax);
	set_archive_item(g_user_entity_id.itax_adj, p_yea_info.itax_adj);
	set_archive_item(g_user_entity_id.rtax_adj, p_yea_info.rtax_adj);
	set_archive_item(g_user_entity_id.stax_adj, p_yea_info.stax_adj);
        -- 4738717
        set_archive_item(g_user_entity_id.cash_receipt_expense, p_yea_info.cash_receipt_exp2005);
        -- Bug 6630135
        set_archive_item(g_user_entity_id.tot_med_exp_cards,p_yea_info.tot_med_exp_cards);
        set_archive_item(g_user_entity_id.med_exp_paid_not_inc_med_exem,p_yea_info.med_exp_paid_not_inc_med_exem);
        -- End of Bug 6630135
        -- Bug 6716401
        set_archive_item(g_user_entity_id.double_exem_amt,p_yea_info.double_exem_amt);
        -- End of Bug 6716401
        -- Bug 7361372
	if p_yea_info.tax_grp_bus_reg_num is not null then
	        set_archive_item(g_user_entity_id.tax_grp_bus_reg_num,p_yea_info.tax_grp_bus_reg_num);
 	        set_archive_item(g_user_entity_id.tax_grp_name,p_yea_info.tax_grp_name);
		-- Bug 8644512
		set_archive_item(g_user_entity_id.tax_grp_wkpd_from,p_yea_info.tax_grp_wkpd_from);
		set_archive_item(g_user_entity_id.tax_grp_wkpd_to,p_yea_info.tax_grp_wkpd_to);
		set_archive_item(g_user_entity_id.tax_grp_tax_brk_pd_from,p_yea_info.tax_grp_tax_brk_pd_from);
		set_archive_item(g_user_entity_id.tax_grp_tax_brk_pd_to,p_yea_info.tax_grp_tax_brk_pd_to);
		--
        	set_archive_item(g_user_entity_id.tax_grp_taxable_mth,p_yea_info.tax_grp_taxable_mth);
        	set_archive_item(g_user_entity_id.tax_grp_taxable_bon,p_yea_info.tax_grp_taxable_bon);
        	set_archive_item(g_user_entity_id.tax_grp_sp_irreg_bonus,p_yea_info.tax_grp_sp_irreg_bonus);
        	set_archive_item(g_user_entity_id.tax_grp_stck_pur_opt_exec_earn,p_yea_info.tax_grp_stck_pur_opt_exec_earn);
		-- Bug 8644512
		set_archive_item(g_user_entity_id.tax_grp_esop_withd_earn,p_yea_info.tax_grp_esop_withd_earn);
		set_archive_item(g_user_entity_id.tax_grp_non_taxable_ovt,p_yea_info.tax_grp_non_taxable_ovt);
		set_archive_item(g_user_entity_id.tax_grp_bir_raising_allw,p_yea_info.tax_grp_bir_raising_allw);
		set_archive_item(g_user_entity_id.tax_grp_fw_income_exem,p_yea_info.tax_grp_fw_income_exem);
		--
        	set_archive_item(g_user_entity_id.tax_grp_itax,p_yea_info.tax_grp_itax);
        	set_archive_item(g_user_entity_id.tax_grp_rtax,p_yea_info.tax_grp_rtax);
        	set_archive_item(g_user_entity_id.tax_grp_stax,p_yea_info.tax_grp_stax);
        	set_archive_item(g_user_entity_id.tax_grp_taxable,p_yea_info.tax_grp_taxable);
        	set_archive_item(g_user_entity_id.tax_grp_post_tax_deduc,p_yea_info.tax_grp_post_tax_deduc);
	-- Bug 7508706
	set_archive_item(g_user_entity_id.tax_grp_taxable_mth_ne,p_yea_info.tax_grp_taxable_mth_ne);
        set_archive_item(g_user_entity_id.tax_grp_taxable_bon_ne,p_yea_info.tax_grp_taxable_bon_ne);
        set_archive_item(g_user_entity_id.tax_grp_sp_irreg_bonus_ne,p_yea_info.tax_grp_sp_irreg_bonus_ne);
        set_archive_item(g_user_entity_id.tax_grp_stck_pur_ne,p_yea_info.tax_grp_stck_pur_ne);
	-- Bug 8644512
	set_archive_item(g_user_entity_id.tax_grp_esop_withd_earn_ne,p_yea_info.tax_grp_esop_withd_earn_ne);
	--
       	set_archive_item(g_user_entity_id.tax_grp_taxable_ne,p_yea_info.tax_grp_taxable_ne);
	-- End of Bug 7508706
	end if;
        -- End of Bug 7361372
	-- Bug 7615517
		set_archive_item(g_user_entity_id.company_related_exp,p_yea_info.company_related_exp);
		set_archive_item(g_user_entity_id.long_term_stck_fund_1year,p_yea_info.long_term_stck_fund_1year);
		set_archive_item(g_user_entity_id.long_term_stck_fund_2year,p_yea_info.long_term_stck_fund_2year);
		set_archive_item(g_user_entity_id.long_term_stck_fund_3year,p_yea_info.long_term_stck_fund_3year);
		set_archive_item(g_user_entity_id.long_term_stck_fund_tax_exem,p_yea_info.long_term_stck_fund_tax_exem);
	-- End of bug 7615517
	--
	-- Bug 8644512
	set_archive_item(g_user_entity_id.cur_ntax_G01,p_yea_info.cur_ntax_G01);
	set_archive_item(g_user_entity_id.cur_ntax_H01,p_yea_info.cur_ntax_H01);
	set_archive_item(g_user_entity_id.cur_ntax_H05,p_yea_info.cur_ntax_H05);
	set_archive_item(g_user_entity_id.cur_ntax_H06,p_yea_info.cur_ntax_H06);
	set_archive_item(g_user_entity_id.cur_ntax_H07,p_yea_info.cur_ntax_H07);
	set_archive_item(g_user_entity_id.cur_ntax_H08,p_yea_info.cur_ntax_H08);
	set_archive_item(g_user_entity_id.cur_ntax_H09,p_yea_info.cur_ntax_H09);
	set_archive_item(g_user_entity_id.cur_ntax_H10,p_yea_info.cur_ntax_H10);
	set_archive_item(g_user_entity_id.cur_ntax_H11,p_yea_info.cur_ntax_H11);
	set_archive_item(g_user_entity_id.cur_ntax_H12,p_yea_info.cur_ntax_H12);
	set_archive_item(g_user_entity_id.cur_ntax_H13,p_yea_info.cur_ntax_H13);
	set_archive_item(g_user_entity_id.cur_ntax_I01,p_yea_info.cur_ntax_I01);
	set_archive_item(g_user_entity_id.cur_ntax_K01,p_yea_info.cur_ntax_K01);
	set_archive_item(g_user_entity_id.cur_ntax_M01,p_yea_info.cur_ntax_M01);
	set_archive_item(g_user_entity_id.cur_ntax_M02,p_yea_info.cur_ntax_M02);
	set_archive_item(g_user_entity_id.cur_ntax_M03,p_yea_info.cur_ntax_M03);
	set_archive_item(g_user_entity_id.cur_ntax_S01,p_yea_info.cur_ntax_S01);
	set_archive_item(g_user_entity_id.cur_ntax_T01,p_yea_info.cur_ntax_T01);
	set_archive_item(g_user_entity_id.cur_ntax_Y01,p_yea_info.cur_ntax_Y01);
	set_archive_item(g_user_entity_id.cur_ntax_Y02,p_yea_info.cur_ntax_Y02);
	set_archive_item(g_user_entity_id.cur_ntax_Y03,p_yea_info.cur_ntax_Y03);
	set_archive_item(g_user_entity_id.cur_ntax_Y20,p_yea_info.cur_ntax_Y20);
	set_archive_item(g_user_entity_id.cur_ntax_Z01,p_yea_info.cur_ntax_Z01);
	set_archive_item(g_user_entity_id.cur_ntax_frgn_M01,p_yea_info.cur_ntax_frgn_M01); /* Bug 8880364 */
	set_archive_item(g_user_entity_id.cur_ntax_frgn_M02,p_yea_info.cur_ntax_frgn_M02); /* Bug 8880364 */
	set_archive_item(g_user_entity_id.cur_ntax_frgn_M03,p_yea_info.cur_ntax_frgn_M03); /* Bug 8880364 */
	--
	set_archive_item(g_user_entity_id.prev_ntax_G01,p_yea_info.prev_ntax_G01);
	set_archive_item(g_user_entity_id.prev_ntax_H01,p_yea_info.prev_ntax_H01);
	set_archive_item(g_user_entity_id.prev_ntax_H05,p_yea_info.prev_ntax_H05);
	set_archive_item(g_user_entity_id.prev_ntax_H06,p_yea_info.prev_ntax_H06);
	set_archive_item(g_user_entity_id.prev_ntax_H07,p_yea_info.prev_ntax_H07);
	set_archive_item(g_user_entity_id.prev_ntax_H08,p_yea_info.prev_ntax_H08);
	set_archive_item(g_user_entity_id.prev_ntax_H09,p_yea_info.prev_ntax_H09);
	set_archive_item(g_user_entity_id.prev_ntax_H10,p_yea_info.prev_ntax_H10);
	set_archive_item(g_user_entity_id.prev_ntax_H11,p_yea_info.prev_ntax_H11);
	set_archive_item(g_user_entity_id.prev_ntax_H12,p_yea_info.prev_ntax_H12);
	set_archive_item(g_user_entity_id.prev_ntax_H13,p_yea_info.prev_ntax_H13);
	set_archive_item(g_user_entity_id.prev_ntax_I01,p_yea_info.prev_ntax_I01);
	set_archive_item(g_user_entity_id.prev_ntax_K01,p_yea_info.prev_ntax_K01);
	set_archive_item(g_user_entity_id.prev_ntax_M01,p_yea_info.prev_ntax_M01);
	set_archive_item(g_user_entity_id.prev_ntax_M02,p_yea_info.prev_ntax_M02);
	set_archive_item(g_user_entity_id.prev_ntax_M03,p_yea_info.prev_ntax_M03);
	set_archive_item(g_user_entity_id.prev_ntax_S01,p_yea_info.prev_ntax_S01);
	set_archive_item(g_user_entity_id.prev_ntax_T01,p_yea_info.prev_ntax_T01);
	set_archive_item(g_user_entity_id.prev_ntax_Y01,p_yea_info.prev_ntax_Y01);
	set_archive_item(g_user_entity_id.prev_ntax_Y02,p_yea_info.prev_ntax_Y02);
	set_archive_item(g_user_entity_id.prev_ntax_Y03,p_yea_info.prev_ntax_Y03);
	set_archive_item(g_user_entity_id.prev_ntax_Y20,p_yea_info.prev_ntax_Y20);
	set_archive_item(g_user_entity_id.prev_ntax_Z01,p_yea_info.prev_ntax_Z01);
	--
	set_archive_item(g_user_entity_id.tax_grp_ntax_G01,p_yea_info.tax_grp_ntax_G01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H01,p_yea_info.tax_grp_ntax_H01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H05,p_yea_info.tax_grp_ntax_H05);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H06,p_yea_info.tax_grp_ntax_H06);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H07,p_yea_info.tax_grp_ntax_H07);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H08,p_yea_info.tax_grp_ntax_H08);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H09,p_yea_info.tax_grp_ntax_H09);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H10,p_yea_info.tax_grp_ntax_H10);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H11,p_yea_info.tax_grp_ntax_H11);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H12,p_yea_info.tax_grp_ntax_H12);
	set_archive_item(g_user_entity_id.tax_grp_ntax_H13,p_yea_info.tax_grp_ntax_H13);
	set_archive_item(g_user_entity_id.tax_grp_ntax_I01,p_yea_info.tax_grp_ntax_I01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_K01,p_yea_info.tax_grp_ntax_K01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_M01,p_yea_info.tax_grp_ntax_M01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_M02,p_yea_info.tax_grp_ntax_M02);
	set_archive_item(g_user_entity_id.tax_grp_ntax_M03,p_yea_info.tax_grp_ntax_M03);
	set_archive_item(g_user_entity_id.tax_grp_ntax_S01,p_yea_info.tax_grp_ntax_S01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_T01,p_yea_info.tax_grp_ntax_T01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_Y01,p_yea_info.tax_grp_ntax_Y01);
	set_archive_item(g_user_entity_id.tax_grp_ntax_Y02,p_yea_info.tax_grp_ntax_Y02);
	set_archive_item(g_user_entity_id.tax_grp_ntax_Y03,p_yea_info.tax_grp_ntax_Y03);
	set_archive_item(g_user_entity_id.tax_grp_ntax_Y20,p_yea_info.tax_grp_ntax_Y20);
	set_archive_item(g_user_entity_id.tax_grp_ntax_Z01,p_yea_info.tax_grp_ntax_Z01);
	--
	set_archive_item(g_user_entity_id.total_ntax_G01,p_yea_info.total_ntax_G01);
	set_archive_item(g_user_entity_id.total_ntax_H01,p_yea_info.total_ntax_H01);
	set_archive_item(g_user_entity_id.total_ntax_H05,p_yea_info.total_ntax_H05);
	set_archive_item(g_user_entity_id.total_ntax_H06,p_yea_info.total_ntax_H06);
	set_archive_item(g_user_entity_id.total_ntax_H07,p_yea_info.total_ntax_H07);
	set_archive_item(g_user_entity_id.total_ntax_H08,p_yea_info.total_ntax_H08);
	set_archive_item(g_user_entity_id.total_ntax_H09,p_yea_info.total_ntax_H09);
	set_archive_item(g_user_entity_id.total_ntax_H10,p_yea_info.total_ntax_H10);
	set_archive_item(g_user_entity_id.total_ntax_H11,p_yea_info.total_ntax_H11);
	set_archive_item(g_user_entity_id.total_ntax_H12,p_yea_info.total_ntax_H12);
	set_archive_item(g_user_entity_id.total_ntax_H13,p_yea_info.total_ntax_H13);
	set_archive_item(g_user_entity_id.total_ntax_I01,p_yea_info.total_ntax_I01);
	set_archive_item(g_user_entity_id.total_ntax_K01,p_yea_info.total_ntax_K01);
	set_archive_item(g_user_entity_id.total_ntax_M01,p_yea_info.total_ntax_M01);
	set_archive_item(g_user_entity_id.total_ntax_M02,p_yea_info.total_ntax_M02);
	set_archive_item(g_user_entity_id.total_ntax_M03,p_yea_info.total_ntax_M03);
	set_archive_item(g_user_entity_id.total_ntax_S01,p_yea_info.total_ntax_S01);
	set_archive_item(g_user_entity_id.total_ntax_T01,p_yea_info.total_ntax_T01);
	set_archive_item(g_user_entity_id.total_ntax_Y01,p_yea_info.total_ntax_Y01);
	set_archive_item(g_user_entity_id.total_ntax_Y02,p_yea_info.total_ntax_Y02);
	set_archive_item(g_user_entity_id.total_ntax_Y03,p_yea_info.total_ntax_Y03);
	set_archive_item(g_user_entity_id.total_ntax_Y20,p_yea_info.total_ntax_Y20);
	set_archive_item(g_user_entity_id.total_ntax_Z01,p_yea_info.total_ntax_Z01);
	--
	set_archive_item(g_user_entity_id.cur_total_ntax_earn,p_yea_info.cur_total_ntax_earn);
	set_archive_item(g_user_entity_id.tax_grp_total_ntax_earn,p_yea_info.tax_grp_total_ntax_earn);
	set_archive_item(g_user_entity_id.smb_income_exem,p_yea_info.smb_income_exem); -- Bug 9079450
	set_archive_item(g_user_entity_id.cur_smb_days_worked,p_yea_info.cur_smb_days_worked);		 -- Bug 9079450
	set_archive_item(g_user_entity_id.prev_smb_days_worked,p_yea_info.prev_smb_days_worked); 	 -- Bug 9079450
	set_archive_item(g_user_entity_id.cur_smb_eligible_income,p_yea_info.cur_smb_eligible_income);	 -- Bug 9079450
	set_archive_item(g_user_entity_id.prev_smb_eligible_income,p_yea_info.prev_smb_eligible_income); -- Bug 9079450
	set_archive_item(g_user_entity_id.emp_join_prev_year,p_yea_info.emp_join_prev_year);	  	 -- Bug 9079450
	set_archive_item(g_user_entity_id.emp_leave_cur_year,p_yea_info.emp_leave_cur_year);	  	 -- Bug 9079450
	set_archive_item(g_user_entity_id.smb_eligibility_flag,p_yea_info.smb_eligibility_flag);	 -- Bug 9079450
	--
	-- End of Bug 8644512

end convert_to_tbl;
------------------------------------------------------------------------
-- Bug 7361372
procedure tax_group_info(
        p_assignment_id		 in number,
	p_effective_date	 in date,
	p_bus_reg_num            out nocopy varchar2,
	p_tax_grp_name           out nocopy varchar2,
	p_wkpd_from		 out nocopy date,	-- Bug 8644512
	p_wkpd_to		 out nocopy date,	-- Bug 8644512
	p_tax_brk_pd_from	 out nocopy date,	-- Bug 8644512
	p_tax_brk_pd_to		 out nocopy date,	-- Bug 8644512
	p_taxable_mth            out nocopy number,
	p_taxable_bon            out nocopy number,
	p_sp_irreg_bonus         out nocopy number,
	p_stck_pur_opt_exec_earn out nocopy number,
	p_esop_withd_earn	 out nocopy number,	-- Bug 8644512
	p_taxable_mth_ne         out nocopy number,	-- Bug 7508706
	p_taxable_bon_ne         out nocopy number,	-- Bug 7508706
	p_sp_irreg_bonus_ne      out nocopy number,	-- Bug 7508706
	p_stck_pur_ne 		 out nocopy number,	-- Bug 7508706
	p_esop_withd_earn_ne	 out nocopy number,	-- Bug 8644512
	p_non_taxable_ovt	 out nocopy number,	-- Bug 8644512
	p_bir_raising_allw	 out nocopy number,	-- Bug 8644512
	p_fw_income_exem	 out nocopy number,	-- Bug 8644512
	p_itax  	         out nocopy number,
	p_rtax           	 out nocopy number,
	p_stax           	 out nocopy number,
	p_tax_grp_ntax_G01	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_H01	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_H05	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_H06	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_H07	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_H08	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_H09	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_H10	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_H11	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_H12	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_H13	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_I01	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_K01	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_M01	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_M02	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_M03	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_S01	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_T01	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_Y01	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_Y02	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_Y03	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_Y20	 out nocopy number,	-- Bug 8644512
	p_tax_grp_ntax_Z01	 out nocopy number	-- Bug 8644512
)
------------------------------------------------------------------------
is
        cursor csr_aei is
                select 	hr_ni_chk_pkg.chk_nat_id_format(aei_information2, 'DDD-DD-DDDDD'),
                	aei_information3,
			fnd_date.canonical_to_date(aei_information15),	-- Bug 8644512
			fnd_date.canonical_to_date(aei_information16),	-- Bug 8644512
			fnd_date.canonical_to_date(aei_information17),	-- Bug 8644512
			fnd_date.canonical_to_date(aei_information18),	-- Bug 8644512
                	nvl(to_number(aei_information4), 0),
		        nvl(to_number(aei_information5), 0),
			nvl(to_number(aei_information6), 0),
			nvl(to_number(aei_information7), 0),
			nvl(to_number(aei_information19), 0),	-- Bug 8644512
			nvl(to_number(aei_information8), 0),
			nvl(to_number(aei_information9), 0),
			nvl(to_number(aei_information10), 0),
			nvl(to_number(aei_information11), 0),	-- Bug 7508706
			nvl(to_number(aei_information12), 0),	-- Bug 7508706
			nvl(to_number(aei_information13), 0),	-- Bug 7508706
			nvl(to_number(aei_information14), 0),	-- Bug 7508706
			nvl(to_number(aei_information20), 0),	-- Bug 8644512
			nvl(to_number(aei_information21), 0),	-- Bug 8644512
			nvl(to_number(aei_information22), 0),	-- Bug 8644512
			nvl(to_number(aei_information23), 0)	-- Bug 8644512
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_TAX_GROUP_INFO'
		and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');

begin
	open csr_aei;
	fetch csr_aei into
	  p_bus_reg_num,
	  p_tax_grp_name,
	  p_wkpd_from,			-- Bug 8644512
	  p_wkpd_to,			-- Bug 8644512
	  p_tax_brk_pd_from,		-- Bug 8644512
	  p_tax_brk_pd_to,		-- Bug 8644512
	  p_taxable_mth,
	  p_taxable_bon,
	  p_sp_irreg_bonus,
	  p_stck_pur_opt_exec_earn,
	  p_esop_withd_earn,		-- Bug 8644512
	  p_itax,
	  p_rtax,
	  p_stax,
	  p_taxable_mth_ne,	-- Bug 7508706
	  p_taxable_bon_ne,	-- Bug 7508706
	  p_sp_irreg_bonus_ne,	-- Bug 7508706
	  p_stck_pur_ne,	-- Bug 7508706
	  p_esop_withd_earn_ne,	-- Bug 8644512
	  p_non_taxable_ovt,	-- Bug 8644512
	  p_bir_raising_allw,	-- Bug 8644512
	  p_fw_income_exem;	-- Bug 8644512
	close csr_aei;
	--
	-- Bug 9539550
	--
	if p_effective_date >= c_20100101 then
	   if p_fw_income_exem is not null then
	      p_fw_income_exem := 0;
	   end if;
	end if;
	--
	--
	-- Bug 8644512
	--
	for rec in 1..g_contexts_tab.count loop
	    g_ntax_value_tbl(rec)	:= 0;
	end loop;
	--
	for i in 1..g_ntax_detail_tbl.count loop
	--
      		if g_ntax_detail_tbl(i).business_reg_num = p_bus_reg_num then
        	--
                	for k in 1..g_contexts_tab.count loop
                	--
	   	    		if g_contexts_tab(k) = g_ntax_detail_tbl(i).ntax_earn_code then
	   	    		--
	   	       			g_ntax_value_tbl(k) := g_ntax_detail_tbl(i).ntax_earning;
	   	    		--
	   	    		end if;
	   		--
	        	end loop;
	   	--
	   	End if;
	--
	end loop;
	--
	p_tax_grp_ntax_G01 := g_ntax_value_tbl(1);
	p_tax_grp_ntax_H01 := g_ntax_value_tbl(2);
	p_tax_grp_ntax_H05 := g_ntax_value_tbl(3);
	p_tax_grp_ntax_H06 := g_ntax_value_tbl(4);
	p_tax_grp_ntax_H07 := g_ntax_value_tbl(5);
	p_tax_grp_ntax_H08 := g_ntax_value_tbl(6);
	p_tax_grp_ntax_H09 := g_ntax_value_tbl(7);
	p_tax_grp_ntax_H10 := g_ntax_value_tbl(8);
	p_tax_grp_ntax_H11 := g_ntax_value_tbl(9);
	p_tax_grp_ntax_H12 := g_ntax_value_tbl(10);
	p_tax_grp_ntax_H13 := g_ntax_value_tbl(11);
	p_tax_grp_ntax_I01 := g_ntax_value_tbl(12);
	p_tax_grp_ntax_K01 := g_ntax_value_tbl(13);
	p_tax_grp_ntax_M01 := g_ntax_value_tbl(14);
	p_tax_grp_ntax_M02 := g_ntax_value_tbl(15);
	p_tax_grp_ntax_M03 := g_ntax_value_tbl(16);
	p_tax_grp_ntax_S01 := g_ntax_value_tbl(17);
	p_tax_grp_ntax_T01 := g_ntax_value_tbl(18);
	p_tax_grp_ntax_Y01 := g_ntax_value_tbl(19);
	p_tax_grp_ntax_Y02 := g_ntax_value_tbl(20);
	p_tax_grp_ntax_Y03 := g_ntax_value_tbl(21);
	p_tax_grp_ntax_Y20 := g_ntax_value_tbl(22);
	p_tax_grp_ntax_Z01 := g_ntax_value_tbl(23);
	--
end tax_group_info;
-- End of Bug 7361372
------------------------------------------------------------------------
procedure prev_er_info(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_hire_date_tbl		out nocopy t_date_tbl,		-- Bug 8644512
	p_termination_date_tbl	out nocopy t_date_tbl,
	p_corp_name_tbl		out nocopy t_varchar2_tbl,
	p_bp_number_tbl		out nocopy t_varchar2_tbl,
	p_tax_brk_pd_from_tbl	out nocopy t_date_tbl,		-- Bug 8644512
	p_tax_brk_pd_to_tbl	out nocopy t_date_tbl,		-- Bug 8644512
	p_taxable_mth_tbl	out nocopy t_number_tbl,
	p_taxable_bon_tbl	out nocopy t_number_tbl,
	p_sp_irreg_bonus_tbl	out nocopy t_number_tbl,
	p_stck_pur_opt_exec_earn_tbl out nocopy t_number_tbl,  -- Bug 6024342
	p_non_taxable_ovs_tbl	out nocopy t_number_tbl,
	p_non_taxable_ovt_tbl	out nocopy t_number_tbl,
	p_non_taxable_oth_tbl	out nocopy t_number_tbl,
	p_hi_prem_tbl		out nocopy t_number_tbl,
	p_ltci_prem_tbl		out nocopy t_number_tbl,  -- Bug 7260606
	p_ei_prem_tbl		out nocopy t_number_tbl,
	p_np_prem_tbl		out nocopy t_number_tbl,
	p_pen_prem_tbl		out nocopy t_number_tbl,  -- Bug 6024342
	p_separation_pension_tbl out nocopy t_number_tbl,  -- Bug 7508706
	p_itax_tbl		out nocopy t_number_tbl,
	p_rtax_tbl		out nocopy t_number_tbl,
	p_stax_tbl		out nocopy t_number_tbl,
	p_research_payment_tbl	out nocopy t_number_tbl,        -- Bug 8341054
	p_bir_raising_allowance_tbl out nocopy t_number_tbl,    -- Bug 8341054
	p_foreign_worker_exem_tbl out nocopy t_number_tbl,      -- Bug 8341054
	p_esop_withd_earn_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_G01_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_H01_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_H05_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_H06_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_H07_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_H08_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_H09_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_H10_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_H11_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_H12_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_H13_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_I01_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_K01_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_M01_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_M02_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_M03_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_S01_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_T01_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_Y01_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_Y02_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_Y03_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_Y20_tbl	out nocopy t_number_tbl,	-- Bug 8644512
	p_prev_ntax_Z01_tbl	out nocopy t_number_tbl		-- Bug 8644512
)
------------------------------------------------------------------------
is
	cursor csr_aei is
		select	fnd_date.canonical_to_date(aei_information23) aei23,	-- Bug 8644512
			fnd_date.canonical_to_date(aei_information1) aei1,
			aei_information2 aei2,
			hr_ni_chk_pkg.chk_nat_id_format(aei_information3, 'DDD-DD-DDDDD') aei3,
			fnd_date.canonical_to_date(aei_information24) aei24,	-- Bug 8644512
			fnd_date.canonical_to_date(aei_information25) aei25,	-- Bug 8644512
			nvl(to_number(aei_information4), 0) aei4,
			nvl(to_number(aei_information5), 0) aei5,
			nvl(to_number(aei_information6), 0) aei6,
			nvl(to_number(aei_information7), 0) aei7,
			nvl(to_number(aei_information8), 0) aei8,
			nvl(to_number(aei_information9), 0) aei9,
			nvl(to_number(aei_information10), 0) aei10,
			nvl(to_number(aei_information18), 0) aei18,   -- Bug 7260606
			nvl(to_number(aei_information11), 0) aei11,
			nvl(to_number(aei_information12), 0) aei12,
			nvl(to_number(aei_information13), 0) aei13,
			nvl(to_number(aei_information14), 0) aei14,
			nvl(to_number(aei_information15), 0) aei15,
			nvl(to_number(aei_information16), 0) aei16,	-- Bug 6024342
			nvl(to_number(aei_information17), 0) aei17,   -- Bug 6024342
			nvl(to_number(aei_information19), 0) aei19,	-- Bug 7508706
			nvl(to_number(aei_information20), 0) aei20,	-- Bug 8341054
			nvl(to_number(aei_information21), 0) aei21,	-- Bug 8341054
			nvl(to_number(aei_information22), 0) aei22,	-- Bug 8341054
			nvl(to_number(aei_information26), 0) aei26	-- Bug 8644512
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_PREV_ER_INFO'
		and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY')
		order by 1;
	cnt number;
begin
	-- Bug 8644512
	--
	cnt := 1;
	for i in csr_aei loop
		p_hire_date_tbl(cnt)			:= i.aei23;	-- Bug 8644512
		p_termination_date_tbl(cnt)		:= i.aei1;
		p_corp_name_tbl(cnt)			:= i.aei2;
		p_bp_number_tbl(cnt)			:= i.aei3;
		p_tax_brk_pd_from_tbl(cnt)		:= i.aei24;	-- Bug 8644512
		p_tax_brk_pd_to_tbl(cnt)		:= i.aei25;	-- Bug 8644512
		p_taxable_mth_tbl(cnt)			:= i.aei4;
		p_taxable_bon_tbl(cnt)			:= i.aei5;
		p_sp_irreg_bonus_tbl(cnt)		:= i.aei6;
		p_non_taxable_ovs_tbl(cnt)		:= i.aei7;
		p_non_taxable_ovt_tbl(cnt)		:= i.aei8;
		p_non_taxable_oth_tbl(cnt)		:= i.aei9;
		p_hi_prem_tbl(cnt)			:= i.aei10;
		p_ltci_prem_tbl(cnt)			:= i.aei18;	-- Bug 7260606
		p_ei_prem_tbl(cnt)			:= i.aei11;
		p_np_prem_tbl(cnt)			:= i.aei12;
		p_itax_tbl(cnt)				:= i.aei13;
		p_rtax_tbl(cnt)				:= i.aei14;
		p_stax_tbl(cnt)				:= i.aei15;
		p_pen_prem_tbl(cnt)			:= i.aei16;	-- Bug 6024342
		p_stck_pur_opt_exec_earn_tbl(cnt)	:= i.aei17;	-- Bug 6024342
		p_separation_pension_tbl(cnt)		:= i.aei19;	-- Bug 7508706
		p_research_payment_tbl(cnt)		:= i.aei20;     -- Bug 8341054
		p_bir_raising_allowance_tbl(cnt)	:= i.aei21;   	-- Bug 8341054
		--
		-- Bug 9539550
		--
		if p_effective_date >= c_20100101 then
                   p_foreign_worker_exem_tbl(cnt)	:= 0;
		else
                   p_foreign_worker_exem_tbl(cnt)	:= i.aei22;    	-- Bug 8341054
		end if;
		--
		p_esop_withd_earn_tbl(cnt)		:= i.aei26;	-- Bug 8644512

		--
		for rec in 1..g_contexts_tab.count loop
		    g_ntax_value_tbl(rec)	:= 0;
		end loop;
		--
		for j in 1..g_ntax_detail_tbl.count loop
		--
            		if g_ntax_detail_tbl(j).business_reg_num = p_bp_number_tbl(cnt) then
            		--
                		for k in 1..g_contexts_tab.count loop
                		--
	   	    			if g_contexts_tab(k) = g_ntax_detail_tbl(j).ntax_earn_code then
	   	    			--
	   	       				g_ntax_value_tbl(k) := g_ntax_detail_tbl(j).ntax_earning;
	   	    			--
	   	    			end if;
	   			--
	        		end loop;
	   		--
	   		End if;
		--
		end loop;
		--
		--
		p_prev_ntax_G01_tbl(cnt) := g_ntax_value_tbl(1);
		p_prev_ntax_H01_tbl(cnt) := g_ntax_value_tbl(2);
		p_prev_ntax_H05_tbl(cnt) := g_ntax_value_tbl(3);
		p_prev_ntax_H06_tbl(cnt) := g_ntax_value_tbl(4);
		p_prev_ntax_H07_tbl(cnt) := g_ntax_value_tbl(5);
		p_prev_ntax_H08_tbl(cnt) := g_ntax_value_tbl(6);
		p_prev_ntax_H09_tbl(cnt) := g_ntax_value_tbl(7);
		p_prev_ntax_H10_tbl(cnt) := g_ntax_value_tbl(8);
		p_prev_ntax_H11_tbl(cnt) := g_ntax_value_tbl(9);
		p_prev_ntax_H12_tbl(cnt) := g_ntax_value_tbl(10);
		p_prev_ntax_H13_tbl(cnt) := g_ntax_value_tbl(11);
		p_prev_ntax_I01_tbl(cnt) := g_ntax_value_tbl(12);
		p_prev_ntax_K01_tbl(cnt) := g_ntax_value_tbl(13);
		p_prev_ntax_M01_tbl(cnt) := g_ntax_value_tbl(14);
		p_prev_ntax_M02_tbl(cnt) := g_ntax_value_tbl(15);
		p_prev_ntax_M03_tbl(cnt) := g_ntax_value_tbl(16);
		p_prev_ntax_S01_tbl(cnt) := g_ntax_value_tbl(17);
		p_prev_ntax_T01_tbl(cnt) := g_ntax_value_tbl(18);
		p_prev_ntax_Y01_tbl(cnt) := g_ntax_value_tbl(19);
		p_prev_ntax_Y02_tbl(cnt) := g_ntax_value_tbl(20);
		p_prev_ntax_Y03_tbl(cnt) := g_ntax_value_tbl(21);
		p_prev_ntax_Y20_tbl(cnt) := g_ntax_value_tbl(22);
		p_prev_ntax_Z01_tbl(cnt) := g_ntax_value_tbl(23);
	--
	cnt := cnt + 1;
	end loop;
end prev_er_info;
------------------------------------------------------------------------
-- Bug 8644512
------------------------------------------------------------------------
procedure ntax_earnings(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_ntax_detail_tbl	out nocopy t_ntax_tab)
is
--
	cursor csr_ntax_details is
	select 	aei_information4 bus_reg_num,
		aei_information2 code,
		nvl(aei_information5,0) value
	from 	per_assignment_extra_info
	where	assignment_id = p_assignment_id
	and	information_type = 'KR_YEA_NON_TAXABLE_EARN_DETAIL'
	and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY')
	order by 1;

	j number;
--
begin
--
	j := 1;
	for i in csr_ntax_details loop
	      p_ntax_detail_tbl(j).business_reg_num := i.bus_reg_num;
	      p_ntax_detail_tbl(j).ntax_earn_code   := i.code;
	      p_ntax_detail_tbl(j).ntax_earning     := i.value;
	      j := j + 1;
	end loop;

end ntax_earnings;
--
------------------------------------------------------------------------
procedure sp_tax_exem_info(
	p_assignment_id			in number,
	p_effective_date		in date,
	p_hi_prem			in out nocopy number,
	p_ltci_prem			in out nocopy number, -- Bug 7260606
	p_ei_prem			in out nocopy number,
	p_pers_ins_name			in out nocopy varchar2,
	p_pers_ins_prem			in out nocopy number,
	p_disabled_ins_prem		in out nocopy number,
	p_med_exp			in out nocopy number,
        p_med_exp_card_emp              in out nocopy number, -- Bug 4704848
	p_med_exp_disabled		in out nocopy number,
	p_med_exp_aged			in out nocopy number,
	p_ee_educ_exp			in out nocopy number,
	p_ee_occupation_educ_exp2005 	in out nocopy number, -- Bug 3971542
	p_housing_purchase_date		in out nocopy date,
	p_housing_loan_date		in out nocopy date,
	p_housing_loan_repay		in out nocopy number,
	p_lt_housing_loan_date		in out nocopy date,
	p_lt_housing_loan_intr_repay	in out nocopy number,
	p_lt_housing_loan_date_1	in out nocopy date,
	p_lt_housing_loan_intr_repay_1	in out nocopy number,
        p_lt_housing_loan_date_2	in out nocopy date,      -- Bug 8237227
        p_lt_housing_loan_intr_repay_2	in out nocopy number,    -- Bug 8237227
	p_donation1			in out nocopy number,
	p_political_donation1		in out nocopy number,
	p_political_donation2		in out nocopy number,
	p_political_donation3		in out nocopy number,
	p_donation2			in out nocopy number,
	p_donation3			in out nocopy number,
	p_donation4			in out nocopy number,  -- Bug 7142612: Public Legal Entity Donation Trust
	p_religious_donation		in out nocopy number,  -- Bug 7142612: Religious Donation
	-- Bug 3966549
	p_esoa_don2004			in out nocopy number,
	-- End of 3966549
        p_marriage_exemption            in out nocopy varchar2,
        p_funeral_exemption             in out nocopy varchar2,
        p_relocation_exemption          in out nocopy varchar2,
	-- Bug 3172960
	p_med_exp_emp			in out nocopy number)
------------------------------------------------------------------------
is
	l_promotional_fund_donation	NUMBER	:= 0 ;
	l_religious_donation		NUMBER	:= 0 ;
	-- Bug 5255234
	l_dpnt_pers_ins_nts		NUMBER	:= 0 ;
	l_dpnt_pers_ins_oth		NUMBER	:= 0 ;
	-- Bug 5667762
	l_dpnt_dis_ins_nts		NUMBER	:= 0 ;
	l_dpnt_dis_ins_oth		NUMBER	:= 0 ;
        l_chk_box_med_tot_det           VARCHAR2(1);  -- Bug 6737106
        l_med_det_emp_tot               NUMBER  := 0; -- Bug 6737106
        l_med_det_dis_tot               NUMBER  := 0; -- Bug 6737106
        l_med_det_aged_tot              NUMBER  := 0; -- Bug 6737106
        l_med_det_dep_tot               NUMBER  := 0; -- Bug 6737106

	cursor csr_aei is
		select	nvl(to_number(aei_information2), 0),
			nvl(to_number(aei_information3), 0),
			aei_information4,
			nvl(to_number(aei_information5), 0),
			nvl(to_number(aei_information6), 0),
			nvl(to_number(aei_information7), 0),
			nvl(to_number(aei_information8), 0),
			nvl(to_number(aei_information9), 0),
			nvl(to_number(aei_information10), 0),
			fnd_date.canonical_to_date(aei_information13),
			fnd_date.canonical_to_date(aei_information14),
			nvl(to_number(aei_information15), 0),
			fnd_date.canonical_to_date(aei_information16),
			nvl(to_number(aei_information17), 0),
			fnd_date.canonical_to_date(aei_information25),
			nvl(to_number(aei_information26), 0),
			nvl(to_number(aei_information18), 0),
			nvl(to_number(aei_information19), 0),
			nvl(to_number(aei_information20), 0),
			nvl(to_number(aei_information21), 0),
			nvl(to_number(aei_information22), 0),
			nvl(to_number(aei_information23), 0),
			-- Bug 3966549
			nvl(to_number(aei_information30), 0), -- ESOA Donation
			-- End of 3966549
			aei_information27,
			aei_information28,
			aei_information29,
			-- Bug 3172960
			nvl(to_number(aei_information24), 0)
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_SP_TAX_EXEM_INFO'
		and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');

	cursor csr_aei2 is
		select	nvl(to_number(aei_information2), 0) -- Bug 3971542 Employee's occupational training (educational) expense
                       ,nvl(to_number(aei_information3), 0) -- Bug 4704848
	               ,nvl(to_number(aei_information4), 0)
	               ,nvl(to_number(aei_information5), 0)
		       ,nvl(aei_information10,'N')           -- Bug 6737106 Check Box Medical Total and Details
		       ,nvl(to_number(aei_information11), 0) -- Bug 7260606
		       ,nvl(to_number(aei_information7), 0)  -- Bug 7142612: Public Legal Entity Donation Trust
                       ,fnd_date.canonical_to_date(aei_information12)  -- Bug 8237227
                       ,nvl(to_number(aei_information13), 0)  -- Bug 8237227
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_SP_TAX_EXEM_INFO2'
		and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');

	--
	-- Bug 5255234 Cursor to get the dependent Insurnace Expenses.
	--
        -- Bug 5879106
	cursor csr_get_dpnt_insurance_prem is
	 select sum(cei_information1),
		sum(cei_information2),
		sum(cei_information10),
		sum(cei_information11)
	   from pay_kr_cont_details_v pkc,
		per_contact_extra_info_f cei
	  where assignment_id = p_assignment_id
	    -- Bug 5879106
	    and cei.information_type(+) = 'KR_DPNT_EXPENSE_INFO'
	    and cei.contact_relationship_id(+) = pkc.contact_relationship_id
	    and to_char(cei.effective_start_date(+), 'YYYY') = to_char(p_effective_date, 'YYYY')
	    --
	    and  p_effective_date between emp_start_date and emp_end_date
	    and  p_effective_date between cont_start_date and cont_end_date
	    and  p_effective_date between nvl(ADDRESS_START_DATE,p_effective_date) and nvl(ADDRESS_END_DATE, p_effective_date)
	    and  p_effective_date between nvl(pkc.date_start, p_effective_date)
				     and decode(pkc.cont_information9, 'D', trunc(add_months(nvl(pkc.date_end, p_effective_date),12),'YYYY')-1, nvl(pkc.date_end, p_effective_date) )
	    and  pay_kr_ff_functions_pkg.is_exempted_dependent( pkc.contact_type,
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
								cei.contact_extra_info_id
							       ) = 'Y';

/* Bug 6737106 Added cursor csr_aei3 to get Detailed Information from 'KR_YEA_DETAIL_MEDICAL_EXP_INFO' */
      	cursor csr_aei3 is
        select nvl(sum(decode(aei_information7,0,(nvl(aei_information3,0) + nvl(aei_information11,0)))),0) --  Employee Total
              ,nvl(sum(decode(aei_information7,0,0,decode(aei_information9,'A',(nvl(aei_information3,0) + nvl(aei_information11,0))))),0) -- Disabled Total
              --
              -- Bug 9079450: The medical expense exemption for aged dependents
              --              will be given if age is 65 or older.
              ,nvl(sum(decode(aei_information7,0,0,decode(aei_information9,'B',
                                 decode(sign(to_char(p_effective_date, 'YYYY')-2008),1,
                                    decode(pay_kr_ff_functions_pkg.aged_flag(aei_information8, fnd_date.canonical_to_date(to_char(p_effective_date, 'YYYY')||'/12/31')),'Y', (nvl(aei_information3,0) + nvl(aei_information11,0)),0
                                          ),(nvl(aei_information3,0) + nvl(aei_information11,0))
                                        )
                                                         )
                             )
                       ),0
                   ) -- Aged Total
	      ,nvl(sum(decode(aei_information9,'A',0,'B',0,
                             decode(aei_information7,0,0,(nvl(aei_information3,0) + nvl(aei_information11,0))))),0) -- Dependent Total
	from per_assignment_extra_info
	where assignment_id = p_assignment_id
	and information_type = 'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
	and trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
begin
	open csr_aei;
	fetch csr_aei into
		p_hi_prem,
		p_ei_prem,
		p_pers_ins_name,
		p_pers_ins_prem,
		p_disabled_ins_prem,
		p_med_exp,
		p_med_exp_disabled,
		p_med_exp_aged,
		p_ee_educ_exp,
		p_housing_purchase_date,
		p_housing_loan_date,
		p_housing_loan_repay,
		p_lt_housing_loan_date,
		p_lt_housing_loan_intr_repay,
		p_lt_housing_loan_date_1,
		p_lt_housing_loan_intr_repay_1,
		p_donation1,
		p_political_donation1,
		p_political_donation2,
		p_political_donation3,
		p_donation2,
		p_donation3,
		-- Bug 3966549
		p_esoa_don2004,
		-- End of 3966549
                p_marriage_exemption,
                p_funeral_exemption,
                p_relocation_exemption,
		-- Bug 3172960
		p_med_exp_emp;
	close csr_aei;

	open  csr_aei2 ;
	fetch csr_aei2 into
		p_ee_occupation_educ_exp2005  -- Bug 3971542
               ,p_med_exp_card_emp
	       ,l_promotional_fund_donation
	       ,l_religious_donation
	       ,l_chk_box_med_tot_det        -- Bug 6737106
	       ,p_ltci_prem                  -- Bug 7260606
	       ,p_donation4                 -- Bug 7142612: Public Legal Entity Donation Trust
               ,p_lt_housing_loan_date_2      -- Bug 8237227
 	       ,p_lt_housing_loan_intr_repay_2;  -- Bug 8237227
	close csr_aei2 ;

/* Bug 6737106 Added cursor csr_aei3 to get Detailed Information from 'KR_YEA_DETAIL_MEDICAL_EXP_INFO' */

      	   open csr_aei3;
	   fetch csr_aei3
	   into l_med_det_emp_tot,
	        l_med_det_dis_tot,
		l_med_det_aged_tot,
                l_med_det_dep_tot ;
           close csr_aei3;

        if (nvl(l_med_det_emp_tot,0) > 0) or (nvl(l_med_det_dis_tot,0) > 0) or (nvl(l_med_det_aged_tot,0) > 0) or (nvl(l_med_det_dep_tot,0) > 0) then
            if l_chk_box_med_tot_det ='Y' then

	     p_med_exp_emp      := p_med_exp_emp + l_med_det_emp_tot;
             p_med_exp_disabled := p_med_exp_disabled + l_med_det_dis_tot;
             p_med_exp_aged     := p_med_exp_aged + l_med_det_aged_tot;
             p_med_exp          := p_med_exp + l_med_det_dep_tot;

            else
	     p_med_exp_emp      := l_med_det_emp_tot;
             p_med_exp_disabled := l_med_det_dis_tot;
             p_med_exp_aged     := l_med_det_aged_tot;
             p_med_exp          := l_med_det_dep_tot;
            end if;
	end if;
/*End Bug 6737106 */
	-- Bug 5255234
	open csr_get_dpnt_insurance_prem;
	fetch csr_get_dpnt_insurance_prem into l_dpnt_pers_ins_nts,l_dpnt_pers_ins_oth
                                              ,l_dpnt_dis_ins_nts,l_dpnt_dis_ins_oth ;
	close csr_get_dpnt_insurance_prem;

	-- Bug 5667762
	-- Dependent Insurance Expense amounts are now classified as Personal Insurance
	-- and Disabled Insurance. Therefore they are no more added to Health Insurance Premium.

	-- p_hi_prem := p_hi_prem + nvl(l_dpnt_ins_nts,0) + nvl(l_dpnt_ins_oth,0);

	p_pers_ins_prem := p_pers_ins_prem + nvl(l_dpnt_pers_ins_nts,0) + nvl(l_dpnt_pers_ins_oth,0);
	p_disabled_ins_prem := p_disabled_ins_prem + nvl(l_dpnt_dis_ins_nts,0) + nvl(l_dpnt_dis_ins_oth,0);

        ------------------------------------------------------------------------
	-- Bug : 4776711
        -- Since Promotional fund donation receives 100% exeption,it is added to the
	-- Statutory donation. Religious donation receives 10% exemption,it is
	-- added with Specified donation.
        ------------------------------------------------------------------------
        p_donation1 := nvl(p_donation1,0) + nvl(l_promotional_fund_donation,0);
        p_donation2 := nvl(p_donation2,0) + nvl(l_religious_donation,0);
	p_religious_donation := nvl(l_religious_donation,0);           --Bug 7142612
end sp_tax_exem_info;
------------------------------------------------------------------------
procedure dpnt_educ_tax_exem_info(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_contact_name_tbl	out nocopy t_varchar2_tbl,	-- Bug 9079450
	p_contact_ni_tbl	out nocopy t_varchar2_tbl,	-- Bug 9079450
	p_contact_type_tbl	out nocopy t_varchar2_tbl,
	p_school_type_tbl	out nocopy t_varchar2_tbl,
	p_exp_tbl		out nocopy t_number_tbl)
------------------------------------------------------------------------
is
	cursor csr_aei is
		select	aei_information2,
			aei_information3,
			sum(nvl(to_number(aei_information4), 0)),	  -- Bug 9348911
			aei_information7,	-- Bug 9079450: Contact Name
			aei_information5 	-- Bug 9079450: Contact National Identifier
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_DPNT_EDUC_TAX_EXEM_INFO'
		and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY')
                group by aei_information5,aei_information7,aei_information3,aei_information2;  -- Bug 9348911
begin
	open csr_aei;
	fetch csr_aei bulk collect into
		p_contact_type_tbl,
		p_school_type_tbl,
		p_exp_tbl,
		p_contact_name_tbl,	-- Bug 9079450
		p_contact_ni_tbl;	-- Bug 9079450
	close csr_aei;
end dpnt_educ_tax_exem_info;
------------------------------------------------------------------------
/* Changes for Bug 3201332 */
------------------------------------------------------------------------
procedure fw_tax_exem_info(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_educ_expense		out nocopy number,
	p_house_rent		out nocopy number)
------------------------------------------------------------------------
is
	cursor csr_aei is
		select	nvl(to_number(aei_information2), 0),
			nvl(to_number(aei_information3), 0)
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_FW_TAX_EXEM_INFO'
		and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
begin
	open csr_aei;
	fetch csr_aei into
		p_educ_expense,
		p_house_rent;
	close csr_aei;
end fw_tax_exem_info;
------------------------------------------------------------------------
/* Changes for Bug 2523481 */

procedure hous_exp_tax_exem_info(
	p_assignment_id		in number,
	p_effective_date	in date,
	p_saving_type_tbl	out nocopy t_varchar2_tbl,
	p_saving_tbl		out nocopy t_number_tbl)
------------------------------------------------------------------------
is
	cursor csr_aei is
		select	aei_information2,
			nvl(to_number(aei_information3), 0)
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_HOU_EXP_TAX_EXEM_INFO'
		and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
begin
	open csr_aei;
	fetch csr_aei bulk collect into
		p_saving_type_tbl,
		p_saving_tbl;
	close csr_aei;
end hous_exp_tax_exem_info;
------------------------------------------------------------------------
procedure tax_exem_info(
	p_assignment_id			in number,
	p_effective_date		in date,
	p_np_prem			in out nocopy number,
	p_pen_prem			in out nocopy number, -- Bug 6024342
	p_pers_pension_prem		in out nocopy number,
	p_corp_pension_prem             in out nocopy number, -- Bug : 4750653
	p_pers_pension_saving		in out nocopy number,
	p_invest_partner_fin1		in out nocopy number,
	p_invest_partner_fin2		in out nocopy number,
        p_invest_partner_fin3		in out nocopy number, -- Bug 8237227
	p_small_bus_install		in out nocopy number, -- Bug 6895093
	p_credit_card_exp		in out nocopy number,
        p_direct_card_exp		in out nocopy number,
	-- Bug 3966549
	p_emp_cre_card_direct_exp2004	in out nocopy number,
	p_dpnt_cre_card_dir_exp2004	in out nocopy number,
	p_giro_tuition_paid_exp2004	in out nocopy number,
	-- End of 3966549
	-- Bug No 3506168
	p_cash_receipt_exp2005          in out nocopy number,
	--
        p_emp_stk_own_contri    	in out nocopy number,
	--Bug 6630135
        p_tot_med_exp_cards     	in out nocopy number,
        p_dpnt_med_exp_cards    	in out nocopy number,
	--End of Bug 6630135
	-- Bug 7615517
	p_company_related_exp		in out nocopy number,
	p_long_term_stck_fund_1year	in out nocopy number,
	p_long_term_stck_fund_2year	in out nocopy number,
	p_long_term_stck_fund_3year	in out nocopy number,
	p_cur_smb_days_worked		in out nocopy number,	-- Bug 9079450
	p_prev_smb_days_worked		in out nocopy number,	-- Bug 9079450
	p_emp_join_prev_year		in out nocopy varchar2,	-- Bug 9079450
	p_emp_leave_cur_year		in out nocopy varchar2,	-- Bug 9079450
	p_smb_eligibility_flag		in out nocopy varchar2	-- Bug 9079450
	-- End of Bug 7615517
	)
------------------------------------------------------------------------
is
	-- Bug 5255234
	l_dpnt_card_nts		NUMBER;
	l_dpnt_card_oth		NUMBER;
	l_dpnt_cash_nts		NUMBER;
	l_business_group_id 	NUMBER; -- Bug 9079450

	cursor csr_aei is
		select	nvl(to_number(aei_information2), 0),
			nvl(to_number(aei_information3), 0),
			nvl(to_number(aei_information14), 0), -- Bug 4750653
			nvl(to_number(aei_information4), 0),
			nvl(to_number(aei_information5), 0),
			nvl(to_number(aei_information6), 0),
                        nvl(to_number(aei_information25), 0),  -- Bug 8237227
                        -- Modified for Bug# 2706537
			nvl(to_number(aei_information7), 0) + nvl(to_number(aei_information9), 0),
	                -- Added for fix 2879008
			-- Bug 3966549
			-- Added second term for Bug 3966549
			nvl(to_number(aei_information10),0) + nvl(to_number(aei_information11), 0), -- employee's direct payment + dependents' direct payments
			nvl(to_number(aei_information7), 0) + nvl(to_number(aei_information10), 0), -- emp credit card + emp direct card
			nvl(to_number(aei_information9), 0) + nvl(to_number(aei_information11), 0), -- dpdnt credit card + dpdnt direct card
			nvl(to_number(aei_information12), 0), -- giro tuition paid
			-- End of 3966549
			-- Bug No 3506168
			nvl(to_number(aei_information13), 0), -- Cash Receipt expenses
			--
                        nvl(to_number(aei_information8), 0),
			nvl(to_number(aei_information15), 0),
			nvl(to_number(aei_information16), 0), -- Total Medical Expense Paid in Cards Bug 6630135
			nvl(to_number(aei_information17), 0), -- Medical Expense Paid in Cards For Dependents who are not eligible for Basic Exemption Bug 6630135
			nvl(to_number(aei_information20), 0), -- Small Business Installment Amount Bug 6895093
			nvl(to_number(aei_information21), 0), -- Bug 7615517: Company Related Expense
			nvl(to_number(aei_information22), 0), -- Bug 7615517: Long Term Stock Fund for 1st Year
			nvl(to_number(aei_information23), 0), -- Bug 7615517: Long Term Stock Fund for 2nd Year
			nvl(to_number(aei_information24), 0), -- Bug 7615517: Long Term Stock Fund for 3rd Year
			nvl(to_number(aei_information26), 0), -- Bug 9079450: Working Days for the Current Period
			nvl(to_number(aei_information27), 0)  -- Bug 9079450: Working Days for the Previous Period
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_TAX_EXEM_INFO'
		and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');

	-- Bug 9079450
	cursor csr_get_join_leave_info is
		Select decode(sign(to_number(to_char(pds.date_start,'YYYY')) -
                       (to_number(to_char(p_effective_date,'YYYY'))-1)),1,'X',0,'Y','N') Joined_last_year,
                       decode(sign(to_number(to_char(nvl(pds.actual_termination_date,fnd_date.canonical_to_date('4712/12/31')),'YYYY')) -
                       to_number(to_char(p_effective_date,'YYYY'))),1,'N',0,'Y','X') Leaving_cur_year,
			asg.business_group_id bus_grp_id
		from	per_periods_of_service	pds,
			per_assignments_f	asg
		where	asg.assignment_id = p_assignment_id
		and	p_effective_date between asg.effective_start_date and asg.effective_end_date
		and	pds.period_of_service_id = asg.period_of_service_id;
	--
	cursor csr_get_smb_eligibility_flag(p_business_group_id in number) is
		select
        		nvl(hoi.org_information1,'N')
		from 	hr_all_organization_units hou,
        		hr_organization_information hoi
		where 	hoi.organization_id = hou.organization_id
		and 	hou.business_group_id = p_business_group_id
		and 	hoi.org_information_context = 'KR_YEA_ER_SMB_ELIGIBILITY_INFO';
	--
	-- End of Bug 9079450
	--
	--Bug 5255234
        -- Bug 5879106
	cursor csr_get_dpnt_card_expense is
		select  nvl(sum(cei_information7),0), -- Dependent Cards(NTS) Expense
			nvl(sum(cei_information8),0), -- Dependent Cards(Other) Expense
			nvl(sum(cei_information9),0) -- Dependent Cash(NTS) Expense
		  from  pay_kr_cont_details_v pkc,
			per_contact_extra_info_f cei
		  where assignment_id = p_assignment_id
		    -- Bug 5879106
		    and cei.information_type(+) = 'KR_DPNT_EXPENSE_INFO'
		    and cei.contact_relationship_id(+) = pkc.contact_relationship_id
		    and to_char(cei.effective_start_date(+), 'YYYY') = to_char(p_effective_date, 'YYYY')
		    --
		    and  p_effective_date between emp_start_date and emp_end_date
		    and  p_effective_date between cont_start_date and cont_end_date
		    and  p_effective_date between nvl(ADDRESS_START_DATE,p_effective_date) and nvl(ADDRESS_END_DATE, p_effective_date)
		    and  p_effective_date between nvl(pkc.date_start, p_effective_date)
					     and decode(pkc.cont_information9, 'D', trunc(add_months(nvl(pkc.date_end, p_effective_date),12),'YYYY')-1, nvl(pkc.date_end, p_effective_date) )
		    and  pay_kr_ff_functions_pkg.is_exempted_dependent( pkc.contact_type,
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
									cei.contact_extra_info_id
								       ) = 'Y';
begin
	open csr_aei;
	fetch csr_aei into
		p_np_prem,
		p_pers_pension_prem,
		p_corp_pension_prem, -- Bug : 4750653
		p_pers_pension_saving,
		p_invest_partner_fin1,
		p_invest_partner_fin2,
                p_invest_partner_fin3,  -- Bug 8237227
		p_credit_card_exp,
		p_direct_card_exp,
		-- Bug 3966549
		p_emp_cre_card_direct_exp2004,
		p_dpnt_cre_card_dir_exp2004,
		p_giro_tuition_paid_exp2004,
		-- End of bug 3966549
		-- Bug No 3506168
                p_cash_receipt_exp2005,
		--
                p_emp_stk_own_contri,
		p_pen_prem,  			-- Bug 6024342
                p_tot_med_exp_cards,            -- Bug 6630135
                p_dpnt_med_exp_cards,           -- Bug 6630135
		p_small_bus_install,		-- Bug 6895093
		p_company_related_exp,		-- Bug 7615517
		p_long_term_stck_fund_1year,	-- Bug 7615517
		p_long_term_stck_fund_2year,	-- Bug 7615517
		p_long_term_stck_fund_3year,	-- Bug 7615517
		p_cur_smb_days_worked,		-- Bug 9079450
		p_prev_smb_days_worked;		-- Bug 9079450
	close csr_aei;
	--
	-- Bug 9079450
	open csr_get_join_leave_info;
	fetch csr_get_join_leave_info into p_emp_join_prev_year, p_emp_leave_cur_year,l_business_group_id;
	close csr_get_join_leave_info;
	--
	open csr_get_smb_eligibility_flag(l_business_group_id);
	fetch csr_get_smb_eligibility_flag into p_smb_eligibility_flag;
	if csr_get_smb_eligibility_flag%NOTFOUND then
	   p_smb_eligibility_flag := 'N';
	end if;
	close csr_get_smb_eligibility_flag;
	--
	-- End of Bug 9079450
	--
	-- Bug 5255234
	-- Get Dependent Information from Contact Extra Information
	-- and consolidate with the corresponding Employee Expenses
	open csr_get_dpnt_card_expense;
	fetch csr_get_dpnt_card_expense into l_dpnt_card_nts,
					     l_dpnt_card_oth,
					     l_dpnt_cash_nts;
	close csr_get_dpnt_card_expense;
	--
	p_dpnt_cre_card_dir_exp2004 := p_dpnt_cre_card_dir_exp2004 + nvl(l_dpnt_card_nts,0) + nvl(l_dpnt_card_oth,0);
	p_credit_card_exp := p_credit_card_exp + nvl(l_dpnt_card_nts,0) + nvl(l_dpnt_card_oth,0);
	p_cash_receipt_exp2005 := p_cash_receipt_exp2005 + nvl(l_dpnt_cash_nts,0);

end tax_exem_info;
------------------------------------------------------------------------
procedure tax_break_info(
	p_assignment_id			in number,
	p_effective_date		in date,
	p_housing_loan_interest_repay	in out nocopy number,
	p_stock_saving			in out nocopy number,
	p_lt_stock_saving1		in out nocopy number,
	p_lt_stock_saving2		in out nocopy number)
------------------------------------------------------------------------
is
	cursor csr_aei is
		select  nvl(to_number(aei_information2), 0),
			nvl(to_number(aei_information3), 0),
			nvl(to_number(aei_information4), 0),
			nvl(to_number(aei_information5), 0)
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_TAX_BREAK_INFO'
		and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
begin
	open csr_aei;
	fetch csr_aei into
		p_housing_loan_interest_repay,
		p_stock_saving,
		p_lt_stock_saving1,
		p_lt_stock_saving2;
	close csr_aei;
end tax_break_info;
------------------------------------------------------------------------
procedure ovs_tax_break_info(
	p_assignment_id			in number,
	p_effective_date		in date,
	p_tax_paid_date			in out nocopy date,
	p_territory_code		in out nocopy varchar2,
	p_currency_code			in out nocopy varchar2,
	p_taxable			in out nocopy number,
	p_taxable_subj_tax_break	in out nocopy number,
	p_tax_break_rate		in out nocopy number,
	p_tax_foreign_currency		in out nocopy number,
	p_tax				in out nocopy number,
	p_application_date		in out nocopy date,
	p_submission_date		in out nocopy date)
------------------------------------------------------------------------
is
	cursor csr_aei is
		select	fnd_date.canonical_to_date(aei_information1),
			aei_information2,
			aei_information3,
			nvl(to_number(aei_information4), 0),
			nvl(to_number(aei_information5), 0),
			nvl(to_number(aei_information6), 0),
			nvl(to_number(aei_information7), 0),
			nvl(to_number(aei_information8), 0),
			fnd_date.canonical_to_date(aei_information9),
			fnd_date.canonical_to_date(aei_information10)
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_OVS_TAX_BREAK_INFO'
		and	trunc(fnd_date.canonical_to_date(aei_information1), 'YYYY') = trunc(p_effective_date, 'YYYY');
begin
	open csr_aei;
	fetch csr_aei into
		p_tax_paid_date,
		p_territory_code,
		p_currency_code,
		p_taxable,
		p_taxable_subj_tax_break,
		p_tax_break_rate,
		p_tax_foreign_currency,
		p_tax,
		p_application_date,
		p_submission_date;
	close csr_aei;
end ovs_tax_break_info;
------------------------------------------------------------------------
-- Bug 5083240: Updated to calculate earnings during contract, new
--              parameters p_assignment_action_id, p_contr_taxable_earn,
--              p_contr_non_taxable_earn
------------------------------------------------------------------------
procedure fw_tax_break_info(
        p_assignment_action_id          in number,
	p_assignment_id			in number,
	p_effective_date		in date,
	p_immigration_purpose		in out nocopy varchar2,
	p_contract_date			in out nocopy date,
	p_expiry_date			in out nocopy date,
	p_application_date		in out nocopy date,
	p_submission_date		in out nocopy date,
        p_contr_taxable_earn            in out nocopy number,
        p_contr_non_taxable_earn        in out nocopy number)
------------------------------------------------------------------------
is
	cursor csr_aei is
		select	aei_information1,
			fnd_date.canonical_to_date(aei_information2),
			fnd_date.canonical_to_date(aei_information3),
			fnd_date.canonical_to_date(aei_information5),
			fnd_date.canonical_to_date(aei_information6)
		from	per_assignment_extra_info
		where	assignment_id = p_assignment_id
		and	information_type = 'KR_YEA_FW_TAX_BREAK_INFO'
		and	p_effective_date between -- Bug 5083240: Consider end date to be last day of contract_expiry_date year
                                fnd_date.canonical_to_date(aei_information2)
                                and (add_months(trunc(fnd_date.canonical_to_date(aei_information3), 'YYYY'), 12) - 1) ;
        --
        --
        cursor csr_fw_contract_earn(
                p_contr_start_date date,
                p_contr_expiry_date date,
		l_fw_tax_duration number
        ) is
                select  BAL_TYPE.balance_name,
                        nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale), 0)
                from    pay_balance_feeds_f             FEED,
                        pay_balance_types               BAL_TYPE,
                        pay_run_result_values           TARGET,
                        pay_run_results                 RR,
                        pay_payroll_actions             PACT,
                        pay_assignment_actions          ASSACT,
                        pay_payroll_actions             BACT,
                        pay_assignment_actions          BAL_ASSACT,
                        pay_run_types_f                 RTYPE
                where   BAL_ASSACT.assignment_action_id         = p_assignment_action_id
                        and BAL_TYPE.balance_name               in ('TOTAL_TAXABLE_EARNINGS', 'TOTAL_NON_TAXABLE_EARNINGS')
                        and BAL_TYPE.legislation_code           = 'KR'
                        and FEED.balance_type_id                = BAL_TYPE.balance_type_id
                        and BACT.payroll_action_id              = BAL_ASSACT.payroll_action_id
                        and ASSACT.assignment_id                = BAL_ASSACT.assignment_id
                        and ASSACT.action_sequence              <= BAL_ASSACT.action_sequence
                        and PACT.payroll_action_id              = ASSACT.payroll_action_id
                        and trunc(PACT.effective_date, 'YYYY')  = trunc(BACT.effective_date, 'YYYY')
                        and PACT.effective_date                 between p_contr_start_date
                                                                and
                                                                (add_months(trunc(p_contr_expiry_date, 'MONTH'), 1) - 1 )
			and  months_between(PACT.effective_date,p_contr_start_date)/l_pay_periods_per_year < l_fw_tax_duration
                        and (
                                RTYPE.run_type_name             = 'MTH'
                                or
                                RTYPE.run_type_name             like 'BON\_%' escape '\'
                        )
                        and RTYPE.legislation_code              = 'KR'
                        and PACT.effective_date                 between RTYPE.effective_start_date
                                                                and RTYPE.effective_end_date
                        and PACT.run_type_id                    = RTYPE.run_type_id
                        and RR.assignment_action_id             = ASSACT.assignment_action_id
                        and RR.status                           in ('P', 'PA')
                        and TARGET.run_result_id                = RR.run_result_id
                        and nvl(TARGET.result_value, '0')       <> '0'
                        and FEED.input_value_id                 = TARGET.input_value_id
                        and PACT.effective_date                 between FEED.effective_start_date
                                                                and
                                                                FEED.effective_end_date
                group by
                        BAL_TYPE.balance_name ;
        --
	l_bal_name      pay_balance_types.balance_name%type ;
        l_bal_value     number ;
	l_fw_tax_reduction_duration  number;
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
        --
        p_contr_taxable_earn := 0 ;
        p_contr_non_taxable_earn := 0 ;
        p_immigration_purpose := null ;
	l_fw_tax_reduction_duration := 0;
        --
	open  csr_aei;
	fetch csr_aei into
		p_immigration_purpose,
		p_contract_date,
		p_expiry_date,
		p_application_date,
		p_submission_date;
	close csr_aei;
        --
	-- Bug 9231094
        if p_immigration_purpose is not null then

	l_fw_tax_reduction_duration     := get_globalvalue('KR_FW_TAX_REDUCTION_DURATION',p_contract_date);

                l_bal_name := 'DUMMY' ;
                l_bal_value := 0 ;

		open csr_fw_contract_earn(
                        p_contr_start_date      => p_contract_date,
                        p_contr_expiry_date     => p_expiry_date,
			l_fw_tax_duration	=> l_fw_tax_reduction_duration
                ) ;
                --
                loop

                        fetch csr_fw_contract_earn into l_bal_name, l_bal_value ;
                        exit when csr_fw_contract_earn%notfound ;

                        if l_bal_name = 'TOTAL_TAXABLE_EARNINGS' then
                                p_contr_taxable_earn := l_bal_value ;
                        elsif l_bal_name = 'TOTAL_NON_TAXABLE_EARNINGS' then
                                p_contr_non_taxable_earn := l_bal_value ;
                        end if ;
                        l_bal_name := 'DUMMY' ;
                        l_bal_value := 0 ;
                end loop ;
                --
                close csr_fw_contract_earn ;
                --
        end if ;
        --
end fw_tax_break_info;
------------------------------------------------------------------------
procedure yea_info(
	p_assignment_id			in number,
	p_assignment_action_id		in number,
	p_effective_date		in date,
	p_business_group_id		in number,
	p_payroll_id 			in number,
	p_yea_info			out nocopy t_yea_info,
	p_taxable_earnings_warning	out nocopy boolean,
	p_taxable_income_warning	out nocopy boolean,
	p_taxation_base_warning		out nocopy boolean,
	p_calc_tax_warning		out nocopy boolean,
	p_itax_warning			out nocopy boolean,
	p_rtax_warning			out nocopy boolean,
        -- Bug 2878937
        p_tax_adj_warning               out nocopy boolean)
------------------------------------------------------------------------
is
	l_dummy				number;
	l_index				number;
	l_assignment_action_id		number;
	l_prev_asg_act_id		number;		-- Bug 9079450
	l_cur_sp_irreg_bonus_mth	number := 0;
	l_cur_sp_irreg_bonus_bon	number := 0;
	l_cur_taxable_mth		number := 0;
	l_cur_taxable_bon		number := 0;
	l_hi_prem			number := 0;
	l_ltci_prem			number := 0;  -- Bug 7260606
	l_ei_prem			number := 0;
	l_np_prem			number := 0;
	l_pen_prem			number := 0;  -- Bug 6024342
	-- Bug 4750653
	l_corp_pension_prem_bal_value   number := 0;
	-- Bug 3201332
	l_ni				varchar2(14);
	l_stock_pur_opt_exec_earn_mth   number := 0;
	l_stock_pur_opt_exec_earn_bon   number := 0;
	l_research_payment_mth		number := 0;
	l_research_payment_bon		number := 0;
	l_birth_raising_allowance_bon	 number := 0; --Bug 7142620
	l_birth_raising_allowance_mth	 number := 0; --Bug 7142620
	l_corp_pension_prem		number := 0; -- bug 7508706

	cursor csr_assact(l_effective_date in date) is
		select
			paa.assignment_action_id
		from	pay_payroll_actions	ppa,
			pay_assignment_actions	paa
		where	paa.assignment_id 	= p_assignment_id
		and	paa.source_action_id 	is null
		and     ppa.business_group_id 	= p_business_group_id
		and     ppa.payroll_id        	= p_payroll_id
		and	ppa.payroll_action_id 	= paa.payroll_action_id
		and	ppa.action_type 	in ('B', 'I', 'V', 'R', 'Q')
		and     paa.assignment_action_id <> p_assignment_action_id
		and	ppa.effective_date	between trunc(l_effective_date, 'YYYY') and l_effective_date
		order by paa.action_sequence desc;

	l_input_value_id_tbl		t_number_tbl;
	l_screen_entry_value_tbl	t_varchar2_tbl;

	cursor csr_ee(p_element_type_id number) is
		select
			peev.input_value_id,
			peev.screen_entry_value
		from	pay_element_entry_values_f  peev,
			pay_element_entries_f	    pee,
			pay_element_links_f	    pel
		where	pel.element_type_id = p_element_type_id
		and	p_effective_date
			between pel.effective_start_date and pel.effective_end_date
		and	pee.element_link_id = pel.element_link_id
		and	pee.assignment_id = p_assignment_id
		and	nvl(pee.entry_type, 'E') = 'E'
		and	p_effective_date
			between pee.effective_start_date and pee.effective_end_date
		and	peev.element_entry_id = pee.element_entry_id
		and	peev.effective_start_date = pee.effective_start_date
		and	peev.effective_end_date = pee.effective_end_date
			order by peev.input_value_id; -- Bug 7142620
	-- Bug 3172960
	Cursor csr_fixed_tax_rate
	IS
		Select aei_information1
		  From per_assignment_extra_info
		 Where assignment_id = p_assignment_id
		   And information_type = 'KR_YEA_FOREIGN_WORKER_TAX';
begin
	--
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',10);
	end if;
	--
	------------------------------------------------------------------------
	-- Derive Resident/Non-resident Information from element entry.
	------------------------------------------------------------------------
	open csr_ee(g_tax.element_type_id);
	fetch csr_ee bulk collect into l_input_value_id_tbl, l_screen_entry_value_tbl;
	close csr_ee;
	p_yea_info.non_resident_flag := nvl(l_screen_entry_value_tbl(1), 'N');

	/* Bug 6716506 */
	begin

	p_yea_info.foreign_residency_flag := nvl(l_screen_entry_value_tbl(2), 'N');

	exception
	when no_data_found then
        p_yea_info.foreign_residency_flag := 'N';
	end;
	/* End of Bug 6716506 */
	--
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',15);
	end if;
	------------------------------------------------------------------------
	-- Bug 3201332 Derive Nationality from national identifier
	-- Bug 3172960 Calling pay_kr_ff_functions_pkg for nationality
	-- Bug 6615356 Modified logic for Korean/Foreigner
	------------------------------------------------------------------------
	if (pay_kr_ff_functions_pkg.ni_nationality(p_assignment_id, p_effective_date) = 'F' or p_yea_info.foreign_residency_flag = 'Y') then
	p_yea_info.nationality := 'F';
	else
        p_yea_info.nationality := 'K';
	end if;
	--
	if p_yea_info.nationality = 'F' then

	   OPEN csr_fixed_tax_rate;
	   FETCH csr_fixed_tax_rate INTO p_yea_info.fixed_tax_rate;

	   if csr_fixed_tax_rate%NOTFOUND then
	      p_yea_info.fixed_tax_rate := 'N';
	   end if;

	   CLOSE csr_fixed_tax_rate;
	end if;
	--
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',20);
	end if;
	--
	------------------------------------------------------------------------
	-- Get latest assignment action in previous calendar year.
	------------------------------------------------------------------------
	open csr_assact((trunc(p_effective_date,'YYYY')-1));
	fetch csr_assact into l_prev_asg_act_id;
	if csr_assact%FOUND then
		p_yea_info.prev_smb_eligible_income := pay_balance_pkg.get_value (
				 			p_defined_balance_id => g_balance_value_tab(88).defined_balance_id,
				 			p_assignment_action_id => l_prev_asg_act_id)
						     + pay_balance_pkg.get_value (
				 			p_defined_balance_id => g_balance_value_tab(89).defined_balance_id,
				 			p_assignment_action_id => l_prev_asg_act_id);
	end if;
	close csr_assact;
	------------------------------------------------------------------------
	-- Get latest assignment action in this calendar year.
	------------------------------------------------------------------------
	open csr_assact(p_effective_date);
	fetch csr_assact into l_assignment_action_id;
	if csr_assact%FOUND then
		--
		if g_debug then
		   hr_utility.trace('l_assignment_action_id '||to_char(l_assignment_action_id));
		end if;
		--
		------------------------------------------------------------------------
		-- Current Employer's Information
		-- Modified for Batch balance retrival, fix 3039649
		------------------------------------------------------------------------
		for i in 1..g_balance_value_tab.count loop
			g_balance_value_tab(i).balance_value := null;
		end loop;
		--
		pay_balance_pkg.get_value ( p_assignment_action_id => l_assignment_action_id
		                           ,p_defined_balance_lst => g_balance_value_tab );
		--
		if g_debug then
			hr_utility.set_location('pay_kr_yea_pkg.yea_info.',30);
		end if;
		-- End of bug 8644512
		--
		p_yea_info.cur_ntax_frgn_M01	:= g_balance_value_tab(82).balance_value
						 + g_balance_value_tab(83).balance_value; -- Bug 8880364
		p_yea_info.cur_ntax_frgn_M02	:= g_balance_value_tab(84).balance_value
						 + g_balance_value_tab(85).balance_value; -- Bug 8880364
		p_yea_info.cur_ntax_frgn_M03	:= g_balance_value_tab(86).balance_value
						 + g_balance_value_tab(87).balance_value; -- Bug 8880364
		--
		-- Bug 8644512
		--
		p_yea_info.cur_ntax_G01	:= g_balance_value_tab(36).balance_value + g_balance_value_tab(37).balance_value;
		p_yea_info.cur_ntax_H01	:= g_balance_value_tab(38).balance_value + g_balance_value_tab(39).balance_value;
		p_yea_info.cur_ntax_H05	:= g_balance_value_tab(40).balance_value + g_balance_value_tab(41).balance_value;
		p_yea_info.cur_ntax_H06	:= g_balance_value_tab(42).balance_value + g_balance_value_tab(43).balance_value;
		p_yea_info.cur_ntax_H07	:= g_balance_value_tab(44).balance_value + g_balance_value_tab(45).balance_value;
		p_yea_info.cur_ntax_H08	:= g_balance_value_tab(46).balance_value + g_balance_value_tab(47).balance_value;
		p_yea_info.cur_ntax_H09	:= g_balance_value_tab(48).balance_value + g_balance_value_tab(49).balance_value;
		p_yea_info.cur_ntax_H10	:= g_balance_value_tab(50).balance_value + g_balance_value_tab(51).balance_value;
		p_yea_info.cur_ntax_H11	:= g_balance_value_tab(52).balance_value + g_balance_value_tab(53).balance_value;
		p_yea_info.cur_ntax_H12	:= g_balance_value_tab(54).balance_value + g_balance_value_tab(55).balance_value;
		p_yea_info.cur_ntax_H13	:= g_balance_value_tab(56).balance_value + g_balance_value_tab(57).balance_value;
		p_yea_info.cur_ntax_I01	:= g_balance_value_tab(58).balance_value + g_balance_value_tab(59).balance_value;
		p_yea_info.cur_ntax_K01	:= g_balance_value_tab(60).balance_value + g_balance_value_tab(61).balance_value;
		p_yea_info.cur_ntax_M01	:= g_balance_value_tab(62).balance_value + g_balance_value_tab(63).balance_value;
		p_yea_info.cur_ntax_M02	:= g_balance_value_tab(64).balance_value + g_balance_value_tab(65).balance_value;
		p_yea_info.cur_ntax_M03	:= g_balance_value_tab(66).balance_value + g_balance_value_tab(67).balance_value;
		p_yea_info.cur_ntax_S01	:= g_balance_value_tab(68).balance_value + g_balance_value_tab(69).balance_value;
		p_yea_info.cur_ntax_T01	:= g_balance_value_tab(70).balance_value + g_balance_value_tab(71).balance_value;
		p_yea_info.cur_ntax_Y01	:= g_balance_value_tab(72).balance_value + g_balance_value_tab(73).balance_value;
		p_yea_info.cur_ntax_Y02	:= g_balance_value_tab(74).balance_value + g_balance_value_tab(75).balance_value;
		p_yea_info.cur_ntax_Y03	:= g_balance_value_tab(76).balance_value + g_balance_value_tab(77).balance_value;
		p_yea_info.cur_ntax_Y20	:= g_balance_value_tab(78).balance_value + g_balance_value_tab(79).balance_value;
		p_yea_info.cur_ntax_Z01	:= g_balance_value_tab(80).balance_value + g_balance_value_tab(81).balance_value;
		--
		p_yea_info.cur_smb_eligible_income	:= g_balance_value_tab(88).balance_value
							 + g_balance_value_tab(89).balance_value;	-- Bug 9079450
		--
		l_cur_sp_irreg_bonus_mth	:= g_balance_value_tab(1).balance_value;
		l_cur_sp_irreg_bonus_bon	:= g_balance_value_tab(2).balance_value;
		l_cur_taxable_mth		:= g_balance_value_tab(3).balance_value;
		l_cur_taxable_bon		:= g_balance_value_tab(4).balance_value;
		p_yea_info.cur_taxable_mth	:= l_cur_taxable_mth - l_cur_sp_irreg_bonus_mth;
		p_yea_info.cur_taxable_bon	:= l_cur_taxable_bon - l_cur_sp_irreg_bonus_bon;
		p_yea_info.cur_sp_irreg_bonus	:= l_cur_sp_irreg_bonus_mth + l_cur_sp_irreg_bonus_bon;
		p_yea_info.non_taxable_ovs	:= g_balance_value_tab(7).balance_value
						 + g_balance_value_tab(8).balance_value;
		p_yea_info.non_taxable_ovt	:= g_balance_value_tab(9).balance_value
						 + g_balance_value_tab(10).balance_value;
		p_yea_info.cur_non_taxable_ovt	:= p_yea_info.non_taxable_ovt;			-- Bug 8644512
		p_yea_info.non_taxable_ovs_frgn	:= g_balance_value_tab(32).balance_value
						 + g_balance_value_tab(33).balance_value; -- Bug 7439803
		--
		-- Bug 8644512
		if p_effective_date >= c_20090101 then
		  p_yea_info.non_taxable_oth	:= 0;
		  p_yea_info.non_rep_non_taxable := g_balance_value_tab(22).balance_value
						  + g_balance_value_tab(23).balance_value; -- Bug 9079450
		--
		elsif p_effective_date >= c_20060101 and p_effective_date < c_20090101 then
                  p_yea_info.non_taxable_oth	:= g_balance_value_tab(5).balance_value
						 + g_balance_value_tab(6).balance_value
						 + g_balance_value_tab(22).balance_value -- Bug 5756699
						 + g_balance_value_tab(23).balance_value
						 - p_yea_info.non_taxable_ovs
						 - p_yea_info.non_taxable_ovt
						 - g_balance_value_tab(30).balance_value -- Bug 7142620
						 - g_balance_value_tab(31).balance_value -- Bug 7142620
						 - p_yea_info.non_taxable_ovs_frgn;      -- Bug 7439803
		else
                  p_yea_info.non_taxable_oth	:= g_balance_value_tab(5).balance_value
						 + g_balance_value_tab(6).balance_value
						 - p_yea_info.non_taxable_ovs
						 - p_yea_info.non_taxable_ovt
						 - p_yea_info.non_taxable_ovs_frgn;      -- Bug 7439803
		end if;
		--
		-- bug 6012258
		l_stock_pur_opt_exec_earn_mth   := g_balance_value_tab(24).balance_value;
		l_stock_pur_opt_exec_earn_bon   := g_balance_value_tab(25).balance_value;
		l_research_payment_mth		:= g_balance_value_tab(26).balance_value;
		l_research_payment_bon		:= g_balance_value_tab(27).balance_value;
		p_yea_info.cur_stck_pur_opt_exec_earn := l_stock_pur_opt_exec_earn_mth + l_stock_pur_opt_exec_earn_bon;
		p_yea_info.research_payment        := l_research_payment_mth + l_research_payment_bon;
		-- Bug 7142620
		l_birth_raising_allowance_mth	:= g_balance_value_tab(30).balance_value;
		l_birth_raising_allowance_bon	:= g_balance_value_tab(31).balance_value;
		p_yea_info.birth_raising_allowance := l_birth_raising_allowance_mth +  l_birth_raising_allowance_bon ;
		p_yea_info.cur_birth_raising_allowance := p_yea_info.birth_raising_allowance;
		--End of Bug 7142620
                --
		-- Bug 8644512
		p_yea_info.cur_esop_withd_earn	:= g_balance_value_tab(34).balance_value
						 + g_balance_value_tab(35).balance_value;
		--
		p_yea_info.hi_prem		:= greatest(nvl(g_balance_value_tab(11).balance_value,0),0); -- Bug 6726096
		p_yea_info.ei_prem		:= greatest(nvl(g_balance_value_tab(12).balance_value,0),0); -- Bug 6726096
		p_yea_info.np_prem		:= g_balance_value_tab(13).balance_value;
		p_yea_info.pen_prem		:= g_balance_value_tab(28).balance_value;    -- Bug 6024342
		--
		p_yea_info.long_term_ins_prem := greatest(nvl(g_balance_value_tab(29).balance_value,0),0); -- Bug 7164589
		--
                -- need to add Adjustment Amounts because now run_type for YEA process is not MTH
                --
		p_yea_info.cur_itax		:= g_balance_value_tab(14).balance_value
						 + g_balance_value_tab(15).balance_value;
		p_yea_info.cur_rtax		:= g_balance_value_tab(16).balance_value
						 + g_balance_value_tab(17).balance_value;
		p_yea_info.cur_stax		:= g_balance_value_tab(18).balance_value
						 + g_balance_value_tab(19).balance_value;
		-- Added for bug 3201332
		p_yea_info.monthly_reg_earning	:= g_balance_value_tab(20).balance_value;
                --
		--
		-- Bug : 4750653
		l_corp_pension_prem_bal_value    := g_balance_value_tab(21).balance_value+
		                                   p_yea_info.corp_pension_prem;
		--
                if g_debug then
                   hr_utility.trace('p_yea_info.cur_itax '||to_char(p_yea_info.cur_itax));
                   hr_utility.trace('p_yea_info.cur_rtax '||to_char(p_yea_info.cur_rtax));
                   hr_utility.trace('p_yea_info.cur_stax '||to_char(p_yea_info.cur_stax));
                end if;
                --
	end if;
	close csr_assact;
	------------------------------------------------------------------------
	-- Derive Dependent Information.
	-- This code will be changed in the near future by using PER_CONTACT_RELATIONSHIPS.
	------------------------------------------------------------------------
	--
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',40);
	end if;
	--
	l_dummy := pay_kr_ff_functions_pkg.get_dependent_info(
			p_assignment_id			=> p_assignment_id,
			p_date_earned			=> p_effective_date,
			p_non_resident_flag		=> p_yea_info.non_resident_flag,
			p_dpnt_spouse_flag		=> p_yea_info.dpnt_spouse_flag,
			p_num_of_aged_dpnts		=> p_yea_info.num_of_aged_dpnts,
			p_num_of_adult_dpnts		=> p_yea_info.num_of_adult_dpnts,
			p_num_of_underaged_dpnts	=> p_yea_info.num_of_underaged_dpnts,
			p_num_of_dpnts			=> p_yea_info.num_of_dpnts,
			p_num_of_ageds			=> p_yea_info.num_of_ageds,
			p_num_of_disableds		=> p_yea_info.num_of_disableds,
			p_female_ee_flag		=> p_yea_info.female_ee_flag,
			p_num_of_children		=> p_yea_info.num_of_children,
			-- Bug 3172960
			p_num_of_super_ageds		=> p_yea_info.num_of_super_ageds,
			-- Bug 6705170
			p_num_of_new_born_adopted       => p_yea_info.num_of_new_born_adopted,
			-- Bug 6784288
			p_num_of_addtl_child            => p_yea_info.num_of_addtl_child);
	------------------------------------------------------------------------
	-- Derive YEA Information from assignment EIT.
	------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',50);
	end if;
	--
	------------------------------------------------------------------------
	-- Bug 8644512
	------------------------------------------------------------------------
	ntax_earnings(
		p_assignment_id		=> p_assignment_id,
		p_effective_date	=> p_effective_date,
		p_ntax_detail_tbl	=> g_ntax_detail_tbl
		);
	------------------------------------------------------------------------
	-- Previous Employers' Information
	------------------------------------------------------------------------
	prev_er_info(
		p_assignment_id			=> p_assignment_id,
		p_effective_date		=> p_effective_date,
		p_hire_date_tbl			=> p_yea_info.prev_hire_date_tbl,		-- Bug 8644512
		p_termination_date_tbl		=> p_yea_info.prev_termination_date_tbl,
		p_corp_name_tbl			=> p_yea_info.prev_corp_name_tbl,
		p_bp_number_tbl			=> p_yea_info.prev_bp_number_tbl,
		p_tax_brk_pd_from_tbl		=> p_yea_info.prev_tax_brk_pd_from_tbl,		-- Bug 8644512
		p_tax_brk_pd_to_tbl		=> p_yea_info.prev_tax_brk_pd_to_tbl,		-- Bug 8644512
		p_taxable_mth_tbl		=> p_yea_info.prev_taxable_mth_tbl,
		p_taxable_bon_tbl		=> p_yea_info.prev_taxable_bon_tbl,
		p_sp_irreg_bonus_tbl		=> p_yea_info.prev_sp_irreg_bonus_tbl,
		p_stck_pur_opt_exec_earn_tbl    => p_yea_info.prev_stck_pur_opt_exe_earn_tbl,	-- Bug 6024342
		p_non_taxable_ovs_tbl		=> p_yea_info.prev_non_taxable_ovs_tbl,
		p_non_taxable_ovt_tbl		=> p_yea_info.prev_non_taxable_ovt_tbl,
		p_non_taxable_oth_tbl		=> p_yea_info.prev_non_taxable_oth_tbl,
		p_hi_prem_tbl			=> p_yea_info.prev_hi_prem_tbl,
		p_ltci_prem_tbl			=> p_yea_info.prev_ltci_prem_tbl,  -- Bug 7260606
		p_ei_prem_tbl			=> p_yea_info.prev_ei_prem_tbl,
		p_np_prem_tbl			=> p_yea_info.prev_np_prem_tbl,
		p_pen_prem_tbl			=> p_yea_info.prev_pen_prem_tbl,	-- Bug 6024342
		p_separation_pension_tbl	=> p_yea_info.prev_separation_pension_tbl, 	-- Bug 7508706
		p_itax_tbl			=> p_yea_info.prev_itax_tbl,
		p_rtax_tbl			=> p_yea_info.prev_rtax_tbl,
		p_stax_tbl			=> p_yea_info.prev_stax_tbl,
		p_research_payment_tbl          => p_yea_info.prev_research_payment_tbl,         -- Bug 8341054
		p_bir_raising_allowance_tbl     => p_yea_info.prev_bir_raising_allowance_tbl,      -- Bug 8341054
		p_foreign_worker_exem_tbl       => p_yea_info.prev_foreign_wrkr_inc_exem_tbl,      -- Bug 8341054
		p_esop_withd_earn_tbl		=> p_yea_info.prev_esop_withd_earn_tbl,		-- Bug 8644512
		p_prev_ntax_G01_tbl		=> p_yea_info.prev_ntax_G01_tbl,	-- Bug 8644512
		p_prev_ntax_H01_tbl		=> p_yea_info.prev_ntax_H01_tbl,	-- Bug 8644512
		p_prev_ntax_H05_tbl		=> p_yea_info.prev_ntax_H05_tbl,	-- Bug 8644512
		p_prev_ntax_H06_tbl		=> p_yea_info.prev_ntax_H06_tbl,	-- Bug 8644512
		p_prev_ntax_H07_tbl		=> p_yea_info.prev_ntax_H07_tbl,	-- Bug 8644512
		p_prev_ntax_H08_tbl		=> p_yea_info.prev_ntax_H08_tbl,	-- Bug 8644512
		p_prev_ntax_H09_tbl		=> p_yea_info.prev_ntax_H09_tbl,	-- Bug 8644512
		p_prev_ntax_H10_tbl		=> p_yea_info.prev_ntax_H10_tbl,	-- Bug 8644512
		p_prev_ntax_H11_tbl		=> p_yea_info.prev_ntax_H11_tbl,	-- Bug 8644512
		p_prev_ntax_H12_tbl		=> p_yea_info.prev_ntax_H12_tbl,	-- Bug 8644512
		p_prev_ntax_H13_tbl		=> p_yea_info.prev_ntax_H13_tbl,	-- Bug 8644512
		p_prev_ntax_I01_tbl		=> p_yea_info.prev_ntax_I01_tbl,	-- Bug 8644512
		p_prev_ntax_K01_tbl		=> p_yea_info.prev_ntax_K01_tbl,	-- Bug 8644512
		p_prev_ntax_M01_tbl		=> p_yea_info.prev_ntax_M01_tbl,	-- Bug 8644512
		p_prev_ntax_M02_tbl		=> p_yea_info.prev_ntax_M02_tbl,	-- Bug 8644512
		p_prev_ntax_M03_tbl		=> p_yea_info.prev_ntax_M03_tbl,	-- Bug 8644512
		p_prev_ntax_S01_tbl		=> p_yea_info.prev_ntax_S01_tbl,	-- Bug 8644512
		p_prev_ntax_T01_tbl		=> p_yea_info.prev_ntax_T01_tbl,	-- Bug 8644512
		p_prev_ntax_Y01_tbl		=> p_yea_info.prev_ntax_Y01_tbl,	-- Bug 8644512
		p_prev_ntax_Y02_tbl		=> p_yea_info.prev_ntax_Y02_tbl,	-- Bug 8644512
		p_prev_ntax_Y03_tbl		=> p_yea_info.prev_ntax_Y03_tbl,	-- Bug 8644512
		p_prev_ntax_Y20_tbl		=> p_yea_info.prev_ntax_Y20_tbl,	-- Bug 8644512
		p_prev_ntax_Z01_tbl		=> p_yea_info.prev_ntax_Z01_tbl		-- Bug 8644512
		);
	for i in 1..p_yea_info.prev_termination_date_tbl.count loop
		p_yea_info.prev_taxable_mth	:= p_yea_info.prev_taxable_mth + p_yea_info.prev_taxable_mth_tbl(i);
		p_yea_info.prev_taxable_bon	:= p_yea_info.prev_taxable_bon + p_yea_info.prev_taxable_bon_tbl(i);
		p_yea_info.prev_sp_irreg_bonus	:= p_yea_info.prev_sp_irreg_bonus + p_yea_info.prev_sp_irreg_bonus_tbl(i);
		-- Bug 6024342
		p_yea_info.prev_stck_pur_opt_exec_earn := p_yea_info.prev_stck_pur_opt_exec_earn + p_yea_info.prev_stck_pur_opt_exe_earn_tbl(i);
		--
		p_yea_info.non_taxable_ovs	:= p_yea_info.non_taxable_ovs + p_yea_info.prev_non_taxable_ovs_tbl(i);
		p_yea_info.prev_non_taxable_ovt	:= nvl(p_yea_info.prev_non_taxable_ovt,0) + p_yea_info.prev_non_taxable_ovt_tbl(i);
		p_yea_info.non_taxable_oth	:= nvl(p_yea_info.non_taxable_oth,0) + p_yea_info.prev_non_taxable_oth_tbl(i);
		p_yea_info.hi_prem		:= p_yea_info.hi_prem + p_yea_info.prev_hi_prem_tbl(i);
		p_yea_info.long_term_ins_prem	:= p_yea_info.long_term_ins_prem + p_yea_info.prev_ltci_prem_tbl(i); -- Bug 7260606
		p_yea_info.ei_prem		:= p_yea_info.ei_prem + p_yea_info.prev_ei_prem_tbl(i);
		p_yea_info.np_prem		:= p_yea_info.np_prem + p_yea_info.prev_np_prem_tbl(i);
		p_yea_info.pen_prem		:= p_yea_info.pen_prem + p_yea_info.prev_pen_prem_tbl(i);  -- Bug 6024342
		p_yea_info.corp_pension_prem    := p_yea_info.corp_pension_prem + p_yea_info.prev_separation_pension_tbl(i); -- Bug 7508706
		p_yea_info.prev_itax		:= p_yea_info.prev_itax + p_yea_info.prev_itax_tbl(i);
		p_yea_info.prev_rtax		:= p_yea_info.prev_rtax + p_yea_info.prev_rtax_tbl(i);
		p_yea_info.prev_stax		:= p_yea_info.prev_stax + p_yea_info.prev_stax_tbl(i);
                p_yea_info.research_payment     := p_yea_info.research_payment + p_yea_info.prev_research_payment_tbl(i);                -- Bug 8341054
		p_yea_info.prev_birth_raising_allowance := nvl(p_yea_info.prev_birth_raising_allowance,0) + p_yea_info.prev_bir_raising_allowance_tbl(i); -- Bug 8341054
		p_yea_info.prev_foreign_wrkr_inc_exem := nvl(p_yea_info.prev_foreign_wrkr_inc_exem,0) + p_yea_info.prev_foreign_wrkr_inc_exem_tbl(i);
		p_yea_info.prev_esop_withd_earn	:= nvl(p_yea_info.prev_esop_withd_earn,0) + p_yea_info.prev_esop_withd_earn_tbl(i); -- Bug 8644512
		--
		-- Bug 8644512
		--
		p_yea_info.prev_ntax_G01	:= nvl(p_yea_info.prev_ntax_G01,0) + p_yea_info.prev_ntax_G01_tbl(i);
		p_yea_info.prev_ntax_H01	:= nvl(p_yea_info.prev_ntax_H01,0) + p_yea_info.prev_ntax_H01_tbl(i);
		p_yea_info.prev_ntax_H05	:= nvl(p_yea_info.prev_ntax_H05,0) + p_yea_info.prev_ntax_H05_tbl(i);
		p_yea_info.prev_ntax_H06	:= nvl(p_yea_info.prev_ntax_H06,0) + p_yea_info.prev_ntax_H06_tbl(i);
		p_yea_info.prev_ntax_H07	:= nvl(p_yea_info.prev_ntax_H07,0) + p_yea_info.prev_ntax_H07_tbl(i);
		p_yea_info.prev_ntax_H08	:= nvl(p_yea_info.prev_ntax_H08,0) + p_yea_info.prev_ntax_H08_tbl(i);
		p_yea_info.prev_ntax_H09	:= nvl(p_yea_info.prev_ntax_H09,0) + p_yea_info.prev_ntax_H09_tbl(i);
		p_yea_info.prev_ntax_H10	:= nvl(p_yea_info.prev_ntax_H10,0) + p_yea_info.prev_ntax_H10_tbl(i);
		p_yea_info.prev_ntax_H11	:= nvl(p_yea_info.prev_ntax_H11,0) + p_yea_info.prev_ntax_H11_tbl(i);
		p_yea_info.prev_ntax_H12	:= nvl(p_yea_info.prev_ntax_H12,0) + p_yea_info.prev_ntax_H12_tbl(i);
		p_yea_info.prev_ntax_H13	:= nvl(p_yea_info.prev_ntax_H13,0) + p_yea_info.prev_ntax_H13_tbl(i);
		p_yea_info.prev_ntax_I01	:= nvl(p_yea_info.prev_ntax_I01,0) + p_yea_info.prev_ntax_I01_tbl(i);
		p_yea_info.prev_ntax_K01	:= nvl(p_yea_info.prev_ntax_K01,0) + p_yea_info.prev_ntax_K01_tbl(i);
		p_yea_info.prev_ntax_M01	:= nvl(p_yea_info.prev_ntax_M01,0) + p_yea_info.prev_ntax_M01_tbl(i);
		p_yea_info.prev_ntax_M02	:= nvl(p_yea_info.prev_ntax_M02,0) + p_yea_info.prev_ntax_M02_tbl(i);
		p_yea_info.prev_ntax_M03	:= nvl(p_yea_info.prev_ntax_M03,0) + p_yea_info.prev_ntax_M03_tbl(i);
		p_yea_info.prev_ntax_S01	:= nvl(p_yea_info.prev_ntax_S01,0) + p_yea_info.prev_ntax_S01_tbl(i);
		p_yea_info.prev_ntax_T01	:= nvl(p_yea_info.prev_ntax_T01,0) + p_yea_info.prev_ntax_T01_tbl(i);
		p_yea_info.prev_ntax_Y01	:= nvl(p_yea_info.prev_ntax_Y01,0) + p_yea_info.prev_ntax_Y01_tbl(i);
		p_yea_info.prev_ntax_Y02	:= nvl(p_yea_info.prev_ntax_Y02,0) + p_yea_info.prev_ntax_Y02_tbl(i);
		p_yea_info.prev_ntax_Y03	:= nvl(p_yea_info.prev_ntax_Y03,0) + p_yea_info.prev_ntax_Y03_tbl(i);
		p_yea_info.prev_ntax_Y20	:= nvl(p_yea_info.prev_ntax_Y20,0) + p_yea_info.prev_ntax_Y20_tbl(i);
		p_yea_info.prev_ntax_Z01	:= nvl(p_yea_info.prev_ntax_Z01,0) + p_yea_info.prev_ntax_Z01_tbl(i);
		--
	end loop;
	------------------------------------------------------------------------
	-- Bug 7361372: Tax Group Information
	------------------------------------------------------------------------
	tax_group_info(
	        p_assignment_id		 => p_assignment_id,
		p_effective_date	 => p_effective_date,
		p_bus_reg_num            => p_yea_info.tax_grp_bus_reg_num,
		p_tax_grp_name           => p_yea_info.tax_grp_name,
		p_wkpd_from		 => p_yea_info.tax_grp_wkpd_from,		-- Bug 8644512
		p_wkpd_to		 => p_yea_info.tax_grp_wkpd_to,			-- Bug 8644512
		p_tax_brk_pd_from	 => p_yea_info.tax_grp_tax_brk_pd_from,		-- Bug 8644512
		p_tax_brk_pd_to		 => p_yea_info.tax_grp_tax_brk_pd_to,		-- Bug 8644512
		p_taxable_mth            => p_yea_info.tax_grp_taxable_mth,
		p_taxable_bon            => p_yea_info.tax_grp_taxable_bon,
		p_sp_irreg_bonus         => p_yea_info.tax_grp_sp_irreg_bonus,
		p_stck_pur_opt_exec_earn => p_yea_info.tax_grp_stck_pur_opt_exec_earn,
		p_esop_withd_earn	 => p_yea_info.tax_grp_esop_withd_earn,		-- Bug 8644512
		p_taxable_mth_ne         => p_yea_info.tax_grp_taxable_mth_ne,		-- Bug 7508706
		p_taxable_bon_ne         => p_yea_info.tax_grp_taxable_bon_ne,		-- Bug 7508706
		p_sp_irreg_bonus_ne      => p_yea_info.tax_grp_sp_irreg_bonus_ne,	-- Bug 7508706
		p_stck_pur_ne 		 => p_yea_info.tax_grp_stck_pur_ne,		-- Bug 7508706
		p_esop_withd_earn_ne	 => p_yea_info.tax_grp_esop_withd_earn_ne,	-- Bug 8644512
		p_non_taxable_ovt	 => p_yea_info.tax_grp_non_taxable_ovt,		-- Bug 8644512
		p_bir_raising_allw	 => p_yea_info.tax_grp_bir_raising_allw,	-- Bug 8644512
		p_fw_income_exem	 => p_yea_info.tax_grp_fw_income_exem,		-- Bug 8644512
		p_itax             	 => p_yea_info.tax_grp_itax,
		p_rtax           	 => p_yea_info.tax_grp_rtax,
		p_stax            	 => p_yea_info.tax_grp_stax,
		p_tax_grp_ntax_G01	=> p_yea_info.tax_grp_ntax_G01,	-- Bug 8644512
		p_tax_grp_ntax_H01	=> p_yea_info.tax_grp_ntax_H01,	-- Bug 8644512
		p_tax_grp_ntax_H05	=> p_yea_info.tax_grp_ntax_H05,	-- Bug 8644512
		p_tax_grp_ntax_H06	=> p_yea_info.tax_grp_ntax_H06,	-- Bug 8644512
		p_tax_grp_ntax_H07	=> p_yea_info.tax_grp_ntax_H07,	-- Bug 8644512
		p_tax_grp_ntax_H08	=> p_yea_info.tax_grp_ntax_H08,	-- Bug 8644512
		p_tax_grp_ntax_H09	=> p_yea_info.tax_grp_ntax_H09,	-- Bug 8644512
		p_tax_grp_ntax_H10	=> p_yea_info.tax_grp_ntax_H10,	-- Bug 8644512
		p_tax_grp_ntax_H11	=> p_yea_info.tax_grp_ntax_H11,	-- Bug 8644512
		p_tax_grp_ntax_H12	=> p_yea_info.tax_grp_ntax_H12,	-- Bug 8644512
		p_tax_grp_ntax_H13	=> p_yea_info.tax_grp_ntax_H13,	-- Bug 8644512
		p_tax_grp_ntax_I01	=> p_yea_info.tax_grp_ntax_I01,	-- Bug 8644512
		p_tax_grp_ntax_K01	=> p_yea_info.tax_grp_ntax_K01,	-- Bug 8644512
		p_tax_grp_ntax_M01	=> p_yea_info.tax_grp_ntax_M01,	-- Bug 8644512
		p_tax_grp_ntax_M02	=> p_yea_info.tax_grp_ntax_M02,	-- Bug 8644512
		p_tax_grp_ntax_M03	=> p_yea_info.tax_grp_ntax_M03,	-- Bug 8644512
		p_tax_grp_ntax_S01	=> p_yea_info.tax_grp_ntax_S01,	-- Bug 8644512
		p_tax_grp_ntax_T01	=> p_yea_info.tax_grp_ntax_T01,	-- Bug 8644512
		p_tax_grp_ntax_Y01	=> p_yea_info.tax_grp_ntax_Y01,	-- Bug 8644512
		p_tax_grp_ntax_Y02	=> p_yea_info.tax_grp_ntax_Y02,	-- Bug 8644512
		p_tax_grp_ntax_Y03	=> p_yea_info.tax_grp_ntax_Y03,	-- Bug 8644512
		p_tax_grp_ntax_Y20	=> p_yea_info.tax_grp_ntax_Y20,	-- Bug 8644512
		p_tax_grp_ntax_Z01	=> p_yea_info.tax_grp_ntax_Z01);-- Bug 8644512
	--
	-----------------------------------------------------------------------
	-- Bug 8644512: Total Non Taxable Earnings
	-----------------------------------------------------------------------
		p_yea_info.non_taxable_ovt	:= p_yea_info.non_taxable_ovt
						 + nvl(p_yea_info.prev_non_taxable_ovt,0)
						 + nvl(p_yea_info.tax_grp_non_taxable_ovt,0);
		p_yea_info.birth_raising_allowance := p_yea_info.birth_raising_allowance
						    + nvl(p_yea_info.prev_birth_raising_allowance,0)
						    + nvl(p_yea_info.tax_grp_bir_raising_allw,0);

		p_yea_info.foreign_worker_income_exem := nvl(p_yea_info.prev_foreign_wrkr_inc_exem,0)
						+ nvl(p_yea_info.tax_grp_fw_income_exem,0);
		--
		-- Bug 8644512
		p_yea_info.total_ntax_G01	:= nvl(p_yea_info.cur_ntax_G01,0) + nvl(p_yea_info.prev_ntax_G01,0) + nvl(p_yea_info.tax_grp_ntax_G01,0);
		p_yea_info.total_ntax_H01	:= nvl(p_yea_info.cur_ntax_H01,0) + nvl(p_yea_info.prev_ntax_H01,0) + nvl(p_yea_info.tax_grp_ntax_H01,0);
		p_yea_info.total_ntax_H05	:= nvl(p_yea_info.cur_ntax_H05,0) + nvl(p_yea_info.prev_ntax_H05,0) + nvl(p_yea_info.tax_grp_ntax_H05,0);
		p_yea_info.total_ntax_H06	:= nvl(p_yea_info.cur_ntax_H06,0) + nvl(p_yea_info.prev_ntax_H06,0) + nvl(p_yea_info.tax_grp_ntax_H06,0);
		p_yea_info.total_ntax_H07	:= nvl(p_yea_info.cur_ntax_H07,0) + nvl(p_yea_info.prev_ntax_H07,0) + nvl(p_yea_info.tax_grp_ntax_H07,0);
		p_yea_info.total_ntax_H08	:= nvl(p_yea_info.cur_ntax_H08,0) + nvl(p_yea_info.prev_ntax_H08,0) + nvl(p_yea_info.tax_grp_ntax_H08,0);
		p_yea_info.total_ntax_H09	:= nvl(p_yea_info.cur_ntax_H09,0) + nvl(p_yea_info.prev_ntax_H09,0) + nvl(p_yea_info.tax_grp_ntax_H09,0);
		p_yea_info.total_ntax_H10	:= nvl(p_yea_info.cur_ntax_H10,0) + nvl(p_yea_info.prev_ntax_H10,0) + nvl(p_yea_info.tax_grp_ntax_H10,0);
		p_yea_info.total_ntax_H11	:= nvl(p_yea_info.cur_ntax_H11,0) + nvl(p_yea_info.prev_ntax_H11,0) + nvl(p_yea_info.tax_grp_ntax_H11,0);
		p_yea_info.total_ntax_H12	:= nvl(p_yea_info.cur_ntax_H12,0) + nvl(p_yea_info.prev_ntax_H12,0) + nvl(p_yea_info.tax_grp_ntax_H12,0);
		p_yea_info.total_ntax_H13	:= nvl(p_yea_info.cur_ntax_H13,0) + nvl(p_yea_info.prev_ntax_H13,0) + nvl(p_yea_info.tax_grp_ntax_H13,0);
		p_yea_info.total_ntax_I01	:= nvl(p_yea_info.cur_ntax_I01,0) + nvl(p_yea_info.prev_ntax_I01,0) + nvl(p_yea_info.tax_grp_ntax_I01,0);
		p_yea_info.total_ntax_K01	:= nvl(p_yea_info.cur_ntax_K01,0) + nvl(p_yea_info.prev_ntax_K01,0) + nvl(p_yea_info.tax_grp_ntax_K01,0);
		p_yea_info.total_ntax_M01	:= nvl(p_yea_info.cur_ntax_M01,0) + nvl(p_yea_info.cur_ntax_frgn_M01,0) + nvl(p_yea_info.prev_ntax_M01,0) + nvl(p_yea_info.tax_grp_ntax_M01,0);
		p_yea_info.total_ntax_M02	:= nvl(p_yea_info.cur_ntax_M02,0) + nvl(p_yea_info.cur_ntax_frgn_M02,0) + nvl(p_yea_info.prev_ntax_M02,0) + nvl(p_yea_info.tax_grp_ntax_M02,0);
		p_yea_info.total_ntax_M03	:= nvl(p_yea_info.cur_ntax_M03,0) + nvl(p_yea_info.cur_ntax_frgn_M03,0) + nvl(p_yea_info.prev_ntax_M03,0) + nvl(p_yea_info.tax_grp_ntax_M03,0);
		p_yea_info.total_ntax_S01	:= nvl(p_yea_info.cur_ntax_S01,0) + nvl(p_yea_info.prev_ntax_S01,0) + nvl(p_yea_info.tax_grp_ntax_S01,0);
		p_yea_info.total_ntax_T01	:= nvl(p_yea_info.cur_ntax_T01,0) + nvl(p_yea_info.prev_ntax_T01,0) + nvl(p_yea_info.tax_grp_ntax_T01,0);
		p_yea_info.total_ntax_Y01	:= nvl(p_yea_info.cur_ntax_Y01,0) + nvl(p_yea_info.prev_ntax_Y01,0) + nvl(p_yea_info.tax_grp_ntax_Y01,0);
		p_yea_info.total_ntax_Y02	:= nvl(p_yea_info.cur_ntax_Y02,0) + nvl(p_yea_info.prev_ntax_Y02,0) + nvl(p_yea_info.tax_grp_ntax_Y02,0);
		p_yea_info.total_ntax_Y03	:= nvl(p_yea_info.cur_ntax_Y03,0) + nvl(p_yea_info.prev_ntax_Y03,0) + nvl(p_yea_info.tax_grp_ntax_Y03,0);
		p_yea_info.total_ntax_Y20	:= nvl(p_yea_info.cur_ntax_Y20,0) + nvl(p_yea_info.prev_ntax_Y20,0) + nvl(p_yea_info.tax_grp_ntax_Y20,0);
		p_yea_info.total_ntax_Z01	:= nvl(p_yea_info.cur_ntax_Z01,0) + nvl(p_yea_info.prev_ntax_Z01,0) + nvl(p_yea_info.tax_grp_ntax_Z01,0);
		--
		p_yea_info.cur_total_ntax_earn	:= nvl(p_yea_info.cur_ntax_G01,0)
					 	+ nvl(p_yea_info.cur_ntax_H01,0)
					 	+ nvl(p_yea_info.cur_ntax_H05,0)
					 	+ nvl(p_yea_info.cur_ntax_H06,0)
					 	+ nvl(p_yea_info.cur_ntax_H07,0)
						+ nvl(p_yea_info.cur_ntax_H08,0)
					 	+ nvl(p_yea_info.cur_ntax_H09,0)
					 	+ nvl(p_yea_info.cur_ntax_H10,0)
					 	+ nvl(p_yea_info.cur_ntax_H11,0)
					 	+ nvl(p_yea_info.cur_ntax_H12,0)
					 	+ nvl(p_yea_info.cur_ntax_H13,0)
					 	+ nvl(p_yea_info.cur_ntax_I01,0)
					 	+ nvl(p_yea_info.cur_ntax_K01,0)
					 	+ nvl(p_yea_info.cur_ntax_M01,0)
					 	+ nvl(p_yea_info.cur_ntax_M02,0)
					 	+ nvl(p_yea_info.cur_ntax_M03,0)
					 	+ nvl(p_yea_info.cur_ntax_S01,0)
					 	+ nvl(p_yea_info.cur_ntax_T01,0)
					 	+ nvl(p_yea_info.cur_ntax_Y01,0)
					 	+ nvl(p_yea_info.cur_ntax_Y02,0)
					 	+ nvl(p_yea_info.cur_ntax_Y03,0)
					 	+ nvl(p_yea_info.cur_ntax_Y20,0)
					 	+ nvl(p_yea_info.cur_ntax_Z01,0)
						+ nvl(p_yea_info.cur_non_taxable_ovt,0)
						+ nvl(p_yea_info.cur_birth_raising_allowance,0)
						+ nvl(p_yea_info.cur_ntax_frgn_M01,0)
						+ nvl(p_yea_info.cur_ntax_frgn_M02,0)
						+ nvl(p_yea_info.cur_ntax_frgn_M03,0);
		--
		p_yea_info.tax_grp_total_ntax_earn	:= nvl(p_yea_info.tax_grp_ntax_G01,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_H01,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_H05,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_H06,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_H07,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_H08,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_H09,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_H10,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_H11,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_H12,0)
							+ nvl(p_yea_info.tax_grp_ntax_H13,0)
							+ nvl(p_yea_info.tax_grp_ntax_I01,0)
							+ nvl(p_yea_info.tax_grp_ntax_K01,0)
							+ nvl(p_yea_info.tax_grp_ntax_M01,0)
							+ nvl(p_yea_info.tax_grp_ntax_M02,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_M03,0)
							+ nvl(p_yea_info.tax_grp_ntax_S01,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_T01,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_Y01,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_Y02,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_Y03,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_Y20,0)
					 		+ nvl(p_yea_info.tax_grp_ntax_Z01,0)
							+ nvl(p_yea_info.tax_grp_non_taxable_ovt,0)
							+ nvl(p_yea_info.tax_grp_bir_raising_allw,0)
							+ nvl(p_yea_info.tax_grp_fw_income_exem,0);
		--

	------------------------------------------------------------------------
	-- Special Tax Exemption Information
	------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',60);
	end if;
	--
	sp_tax_exem_info(
		p_assignment_id			=> p_assignment_id,
		p_effective_date		=> p_effective_date,
		p_hi_prem			=> l_hi_prem,
		p_ltci_prem			=> l_ltci_prem, -- Bug 7260606
		p_ei_prem			=> l_ei_prem,
		p_pers_ins_name			=> p_yea_info.pers_ins_name,
		p_pers_ins_prem			=> p_yea_info.pers_ins_prem,
		p_disabled_ins_prem		=> p_yea_info.disabled_ins_prem,
		p_med_exp			=> p_yea_info.med_exp,
		p_med_exp_card_emp	        => p_yea_info.med_exp_card_emp,
		p_med_exp_disabled		=> p_yea_info.med_exp_disabled,
		p_med_exp_aged			=> p_yea_info.med_exp_aged,
		p_ee_educ_exp			=> p_yea_info.ee_educ_exp,
		p_ee_occupation_educ_exp2005 	=> p_yea_info.ee_occupation_educ_exp2005, -- Bug 3971542
		p_housing_purchase_date		=> p_yea_info.housing_purchase_date,
		p_housing_loan_date		=> p_yea_info.housing_loan_date,
		p_housing_loan_repay		=> p_yea_info.housing_loan_repay,
		p_lt_housing_loan_date		=> p_yea_info.lt_housing_loan_date,
		p_lt_housing_loan_intr_repay	=> p_yea_info.lt_housing_loan_interest_repay,
		p_lt_housing_loan_date_1        => p_yea_info.lt_housing_loan_date_1,
		p_lt_housing_loan_intr_repay_1	=> p_yea_info.lt_housing_loan_intr_repay_1,
                p_lt_housing_loan_date_2	=> p_yea_info.lt_housing_loan_date_2,      -- Bug 8237227
                p_lt_housing_loan_intr_repay_2	=> p_yea_info.lt_housing_loan_intr_repay_2,    -- Bug 8237227
		p_donation1			=> p_yea_info.donation1,
		p_political_donation1		=> p_yea_info.political_donation1,
		p_political_donation2		=> p_yea_info.political_donation2,
		p_political_donation3		=> p_yea_info.political_donation3,
		p_donation2			=> p_yea_info.donation2,
                p_donation3			=> p_yea_info.donation3,
                p_donation4			=> p_yea_info.donation4, -- Bug 7142612: Public Legal Entity Donation Trust
		p_religious_donation		=> p_yea_info.religious_donation, -- Bug 7142612: Religious Donation
		-- Bug 3966549
		p_esoa_don2004			=> p_yea_info.esoa_don2004,
		-- End of 3966549
                p_marriage_exemption            => p_yea_info.marriage_exemption,
                p_funeral_exemption             => p_yea_info.funeral_exemption,
                p_relocation_exemption          => p_yea_info.relocation_exemption,
		-- Bug 3172960
		p_med_exp_emp			=> p_yea_info.med_exp_emp);
        ------------------------------------------------------------------------
	p_yea_info.hi_prem := p_yea_info.hi_prem + l_hi_prem;
	p_yea_info.long_term_ins_prem := p_yea_info.long_term_ins_prem + l_ltci_prem; -- Bug 7260606
	p_yea_info.ei_prem := p_yea_info.ei_prem + l_ei_prem;
	------------------------------------------------------------------------
	-- Dependent Education Expense Tax Exemption Information
	------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',70);
	end if;
	--
	dpnt_educ_tax_exem_info(
		p_assignment_id			=> p_assignment_id,
		p_effective_date		=> p_effective_date,
		p_contact_name_tbl		=> p_yea_info.dpnt_educ_contact_name_tbl,	-- Bug 9079450
		p_contact_ni_tbl		=> p_yea_info.dpnt_educ_contact_ni_tbl,		-- Bug 9079450
		p_contact_type_tbl		=> p_yea_info.dpnt_educ_contact_type_tbl,
		p_school_type_tbl		=> p_yea_info.dpnt_educ_school_type_tbl,
		p_exp_tbl			=> p_yea_info.dpnt_educ_exp_tbl);
	------------------------------------------------------------------------
	-- Changes for Bug 3201332
	-- Foreign Worker PreTax Deduction Information
	------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',75);
	end if;
	--
	fw_tax_exem_info(
		p_assignment_id			=> p_assignment_id,
		p_effective_date		=> p_effective_date,
		p_educ_expense			=> p_yea_info.fw_educ_expense,
		p_house_rent			=> p_yea_info.fw_house_rent);
        ------------------------------------------------------------------------
	-- Housing Expenses Tax Exemption
        -- Changed for Bug 2523481
        ------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',80);
	end if;
	--
        hous_exp_tax_exem_info(
	        p_assignment_id         => p_assignment_id,
        	p_effective_date	=> p_effective_date,
	        p_saving_type_tbl	=> p_yea_info.housing_saving_type_tbl,
	        p_saving_tbl		=> p_yea_info.housing_saving_tbl);
	------------------------------------------------------------------------
	-- Tax Exemption Information
	-- Direct card expenses introduced for fix 2879008
	------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',90);
	end if;
	--
	tax_exem_info(
		p_assignment_id			=> p_assignment_id,
		p_effective_date		=> p_effective_date,
		p_np_prem			=> l_np_prem,
		p_pen_prem			=> l_pen_prem,  		 -- Bug 6024342
		p_pers_pension_prem		=> p_yea_info.pers_pension_prem,
		p_corp_pension_prem		=> l_corp_pension_prem,		-- bug 7508706
		p_pers_pension_saving		=> p_yea_info.pers_pension_saving,
		p_invest_partner_fin1		=> p_yea_info.invest_partner_fin1,
		p_invest_partner_fin2		=> p_yea_info.invest_partner_fin2,
		p_invest_partner_fin3		=> p_yea_info.invest_partner_fin3,   -- Bug 8237227
		p_small_bus_install		=> p_yea_info.small_bus_install,  -- Bug 6895093
		p_credit_card_exp		=> p_yea_info.credit_card_exp,
		p_direct_card_exp               => p_yea_info.direct_card_exp,
		-- Bug 3966549
		p_emp_cre_card_direct_exp2004	=> p_yea_info.emp_cre_card_direct_exp2004,
		p_dpnt_cre_card_dir_exp2004 	=> p_yea_info.dpnt_cre_card_direct_exp2004,
		p_giro_tuition_paid_exp2004	=> p_yea_info.giro_tuition_paid_exp2004,
                -- Bug 3506168
                p_cash_receipt_exp2005          => p_yea_info.cash_receipt_exp2005,
		--
		-- End of 3966549
                p_emp_stk_own_contri            => p_yea_info.emp_stk_own_contri,
		-- Bug 6630135
		p_tot_med_exp_cards             => p_yea_info.tot_med_exp_cards,
                p_dpnt_med_exp_cards            => p_yea_info.dpnt_med_exp_cards,
                -- End of Bug 6630135
		-- Bug 7615517
		p_company_related_exp		=> p_yea_info.company_related_exp,
		p_long_term_stck_fund_1year	=> p_yea_info.long_term_stck_fund_1year,
		p_long_term_stck_fund_2year	=> p_yea_info.long_term_stck_fund_2year,
		p_long_term_stck_fund_3year	=> p_yea_info.long_term_stck_fund_3year,
		p_cur_smb_days_worked		=> p_yea_info.cur_smb_days_worked,	-- Bug 9079450
		p_prev_smb_days_worked		=> p_yea_info.prev_smb_days_worked,	-- Bug 9079450
		p_emp_join_prev_year		=> p_yea_info.emp_join_prev_year,	-- Bug 9079450
		p_emp_leave_cur_year		=> p_yea_info.emp_leave_cur_year,	-- Bug 9079450
		p_smb_eligibility_flag		=> p_yea_info.smb_eligibility_flag	-- Bug 9079450
		-- End of Bug 7615517
		);
        ------------------------------------------------------------------------
	p_yea_info.np_prem	       := p_yea_info.np_prem + l_np_prem;
	p_yea_info.pen_prem	       := p_yea_info.pen_prem + l_pen_prem;	-- Bug 6024342
        p_yea_info.corp_pension_prem   := p_yea_info.corp_pension_prem
					+ l_corp_pension_prem 			-- Bug 7508706
					+ l_corp_pension_prem_bal_value;  -- Bug 4750653
	------------------------------------------------------------------------
	-- Tax Break Information
	------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',100);
	end if;
	--
	tax_break_info(
		p_assignment_id			=> p_assignment_id,
		p_effective_date		=> p_effective_date,
		p_housing_loan_interest_repay	=> p_yea_info.housing_loan_interest_repay,
		p_stock_saving			=> p_yea_info.stock_saving,
		p_lt_stock_saving1		=> p_yea_info.lt_stock_saving1,
		p_lt_stock_saving2		=> p_yea_info.lt_stock_saving2);
	------------------------------------------------------------------------
	-- Overseas Tax Break Information
	------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',110);
	end if;
	--
	ovs_tax_break_info(
		p_assignment_id			=> p_assignment_id,
		p_effective_date		=> p_effective_date,
		p_tax_paid_date			=> p_yea_info.ovstb_tax_paid_date,
		p_territory_code		=> p_yea_info.ovstb_territory_code,
		p_currency_code			=> p_yea_info.ovstb_currency_code,
		p_taxable			=> p_yea_info.ovstb_taxable,
		p_taxable_subj_tax_break	=> p_yea_info.ovstb_taxable_subj_tax_break,
		p_tax_break_rate		=> p_yea_info.ovstb_tax_break_rate,
		p_tax_foreign_currency		=> p_yea_info.ovstb_tax_foreign_currency,
		p_tax				=> p_yea_info.ovstb_tax,
		p_application_date		=> p_yea_info.ovstb_application_date,
		p_submission_date		=> p_yea_info.ovstb_submission_date);
	--
	-- 2311505
	--
	p_yea_info.cur_taxable_mth := p_yea_info.cur_taxable_mth
				    + p_yea_info.ovstb_taxable
				    - trunc(p_yea_info.ovstb_taxable_subj_tax_break * p_yea_info.ovstb_tax_break_rate / 100);
	------------------------------------------------------------------------
	-- Foreign Worker Tax Break Information
	------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',120);
	end if;
	--
        -- Bug 5083240: Update call for new parameters p_assignment_action_id, p_contr_taxable_earn, and p_contr_non_taxable_earn
	fw_tax_break_info(
                p_assignment_action_id          => p_assignment_action_id,
		p_assignment_id			=> p_assignment_id,
		p_effective_date		=> p_effective_date,
		p_immigration_purpose		=> p_yea_info.fwtb_immigration_purpose,
		p_contract_date			=> p_yea_info.fwtb_contract_date,
		p_expiry_date			=> p_yea_info.fwtb_expiry_date,
		p_application_date		=> p_yea_info.fwtb_application_date,
		p_submission_date		=> p_yea_info.fwtb_submission_date,
                p_contr_taxable_earn            => p_yea_info.fw_contr_taxable_earn,
                p_contr_non_taxable_earn        => p_yea_info.fw_contr_non_taxable_earn);
        -- End of 5083240
	--

	-- Bug 6012258, Bug 8644512
	p_yea_info.cur_taxable		:= p_yea_info.cur_taxable_mth + p_yea_info.cur_taxable_bon
					 + p_yea_info.cur_sp_irreg_bonus + p_yea_info.cur_stck_pur_opt_exec_earn
					 + nvl(p_yea_info.cur_esop_withd_earn,0);
	--
	-- Bug 6024342, Bug 8644512
	p_yea_info.prev_taxable		:= nvl(p_yea_info.prev_taxable_mth,0) + nvl(p_yea_info.prev_taxable_bon,0)
					 + nvl(p_yea_info.prev_sp_irreg_bonus,0) + nvl(p_yea_info.prev_stck_pur_opt_exec_earn,0)
					 + nvl(p_yea_info.prev_esop_withd_earn,0);
	--
	-- Bug 7361372, Bug 8644512
	p_yea_info.tax_grp_taxable      := nvl(p_yea_info.tax_grp_taxable_mth,0) + nvl(p_yea_info.tax_grp_taxable_bon,0)
					 + nvl(p_yea_info.tax_grp_sp_irreg_bonus,0) + nvl(p_yea_info.tax_grp_stck_pur_opt_exec_earn,0)
					 + nvl(p_yea_info.tax_grp_esop_withd_earn,0);
	-- Bug 7508706, Bug 8644512
	p_yea_info.tax_grp_taxable_ne   := nvl(p_yea_info.tax_grp_taxable_mth_ne,0) + nvl(p_yea_info.tax_grp_taxable_bon_ne,0)
					 + nvl(p_yea_info.tax_grp_sp_irreg_bonus_ne,0) + nvl(p_yea_info.tax_grp_stck_pur_ne,0)
					 + nvl(p_yea_info.tax_grp_esop_withd_earn_ne,0);
	--
	p_yea_info.taxable_mth		:= p_yea_info.cur_taxable_mth + p_yea_info.prev_taxable_mth
					 + nvl(p_yea_info.tax_grp_taxable_mth,0) + nvl(p_yea_info.tax_grp_taxable_mth_ne,0);
	p_yea_info.taxable_bon		:= p_yea_info.cur_taxable_bon + p_yea_info.prev_taxable_bon
					 + nvl(p_yea_info.tax_grp_taxable_bon,0) + nvl(p_yea_info.tax_grp_taxable_bon_ne,0);
	p_yea_info.sp_irreg_bonus	:= p_yea_info.cur_sp_irreg_bonus + p_yea_info.prev_sp_irreg_bonus
					 + nvl(p_yea_info.tax_grp_sp_irreg_bonus,0) + nvl(p_yea_info.tax_grp_sp_irreg_bonus_ne,0);
	p_yea_info.stck_pur_opt_exec_earn := p_yea_info.cur_stck_pur_opt_exec_earn + p_yea_info.prev_stck_pur_opt_exec_earn
					  + nvl(p_yea_info.tax_grp_stck_pur_opt_exec_earn,0) + nvl(p_yea_info.tax_grp_stck_pur_ne,0);
	-- Bug 8644512
	p_yea_info.esop_withd_earn	:= nvl(p_yea_info.cur_esop_withd_earn,0) + nvl(p_yea_info.prev_esop_withd_earn,0)
					 + nvl(p_yea_info.tax_grp_esop_withd_earn,0) + nvl(p_yea_info.tax_grp_esop_withd_earn_ne,0);
	--
	p_yea_info.taxable		:= p_yea_info.cur_taxable + p_yea_info.prev_taxable
 					 + nvl(p_yea_info.tax_grp_taxable,0) + nvl(p_yea_info.tax_grp_taxable_ne,0);
	p_yea_info.taxable1             := p_yea_info.taxable; -- bug 7615517
	-- Bug 6012258
	-- End of Bug 7361372,7508706
	--
	-- Bug 8644512
	if p_effective_date >= c_20090101 then
	p_yea_info.non_taxable_oth	:= 0;
	p_yea_info.non_taxable		:= p_yea_info.non_taxable_ovt
					 + p_yea_info.birth_raising_allowance
	                                 + p_yea_info.foreign_worker_income_exem
					 + nvl(p_yea_info.total_ntax_G01,0)
					 + nvl(p_yea_info.total_ntax_H01,0)
					 + nvl(p_yea_info.total_ntax_H05,0)
					 + nvl(p_yea_info.total_ntax_H06,0)
					 + nvl(p_yea_info.total_ntax_H07,0)
					 + nvl(p_yea_info.total_ntax_H08,0)
					 + nvl(p_yea_info.total_ntax_H09,0)
					 + nvl(p_yea_info.total_ntax_H10,0)
					 + nvl(p_yea_info.total_ntax_H11,0)
					 + nvl(p_yea_info.total_ntax_H12,0)
					 + nvl(p_yea_info.total_ntax_H13,0)
					 + nvl(p_yea_info.total_ntax_I01,0)
					 + nvl(p_yea_info.total_ntax_K01,0)
					 + nvl(p_yea_info.total_ntax_M01,0)
					 + nvl(p_yea_info.total_ntax_M02,0)
					 + nvl(p_yea_info.total_ntax_M03,0)
					 + nvl(p_yea_info.total_ntax_S01,0)
					 + nvl(p_yea_info.total_ntax_T01,0)
					 + nvl(p_yea_info.total_ntax_Y01,0)
					 + nvl(p_yea_info.total_ntax_Y02,0)
					 + nvl(p_yea_info.total_ntax_Y03,0)
					 + nvl(p_yea_info.total_ntax_Y20,0)
					 + nvl(p_yea_info.total_ntax_Z01,0);
	else
	p_yea_info.non_taxable		:= p_yea_info.non_taxable_ovs
					 + p_yea_info.non_taxable_ovt
					 + p_yea_info.non_taxable_ovs_frgn     -- Bug 7439803
					 + p_yea_info.non_taxable_oth
					 + p_yea_info.research_payment
					 + p_yea_info.birth_raising_allowance -- Bug 7142620
	                                 + nvl(p_yea_info.prev_foreign_wrkr_inc_exem,0)  -- Bug 8341054
					 + nvl(p_yea_info.tax_grp_fw_income_exem,0);  -- Bug 8644512
	end if;
	--
	------------------------------------------------------------------------
	-- Derive Tax Exemption, Tax Break, Tax Adjustment etc.
	-- which depends on effective_date.
	------------------------------------------------------------------------
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.yea_info.',130);
	end if;
	--
	-- Bug 7676136
        --
        if p_effective_date >= c_20100101 then
                pay_kr_yea20100101_pkg.yea(
			p_assignment_id		=> p_assignment_id,
			p_effective_date	=> p_effective_date,
			p_business_group_id	=> p_business_group_id,
			p_yea_info		=> p_yea_info,
                        p_tax_adj_warning       => p_tax_adj_warning);
	--

	elsif p_effective_date >= c_20090101 then
                pay_kr_yea20090101_pkg.yea(
			p_assignment_id		=> p_assignment_id,
			p_effective_date	=> p_effective_date,
			p_business_group_id	=> p_business_group_id,
			p_yea_info		=> p_yea_info,
                        p_tax_adj_warning       => p_tax_adj_warning);
	--
	-- Bug 6705170
        --
        elsif p_effective_date >= c_20080101 then
                pay_kr_yea20080101_pkg.yea(
			p_assignment_id		=> p_assignment_id,
			p_effective_date	=> p_effective_date,
			p_business_group_id	=> p_business_group_id,
			p_yea_info		=> p_yea_info,
                        p_tax_adj_warning       => p_tax_adj_warning);
        --
        -- Bug 5734313
        --
        elsif p_effective_date >= c_20070101 then
                pay_kr_yea20070101_pkg.yea(
			p_assignment_id		=> p_assignment_id,
			p_effective_date	=> p_effective_date,
			p_business_group_id	=> p_business_group_id,
			p_yea_info		=> p_yea_info,
                        p_tax_adj_warning       => p_tax_adj_warning);
        --
        elsif p_effective_date >= c_20060101 then
                pay_kr_yea20060101_pkg.yea(
			p_assignment_id		=> p_assignment_id,
			p_effective_date	=> p_effective_date,
			p_business_group_id	=> p_business_group_id,
			p_yea_info		=> p_yea_info,
                        p_tax_adj_warning       => p_tax_adj_warning);

	elsif p_effective_date >= c_20050101 then
                pay_kr_yea20050101_pkg.yea(
			p_assignment_id		=> p_assignment_id,
			p_effective_date	=> p_effective_date,
			p_business_group_id	=> p_business_group_id,
			p_yea_info		=> p_yea_info,
                        p_tax_adj_warning       => p_tax_adj_warning);

        elsif p_effective_date >= c_20040101 then
                pay_kr_yea20040101_pkg.yea(
			p_assignment_id		=> p_assignment_id,
			p_effective_date	=> p_effective_date,
			p_business_group_id	=> p_business_group_id,
			p_yea_info		=> p_yea_info,
                        p_tax_adj_warning       => p_tax_adj_warning);

	elsif p_effective_date >= c_20030101 then
		pay_kr_yea20030101_pkg.yea(
			p_assignment_id		=> p_assignment_id,
			p_effective_date	=> p_effective_date,
			p_business_group_id	=> p_business_group_id,
			p_yea_info		=> p_yea_info,
                        p_tax_adj_warning       => p_tax_adj_warning);

	elsif p_effective_date >= c_20020101 then
		pay_kr_yea20020101_pkg.yea(
			p_assignment_id		=> p_assignment_id,
			p_effective_date	=> p_effective_date,
			p_business_group_id	=> p_business_group_id,
			p_yea_info		=> p_yea_info,
                        -- Bug 2878937
                        p_tax_adj_warning       => p_tax_adj_warning);

        elsif p_effective_date >= c_00010101 then
		pay_kr_yea00010101_pkg.yea(
			p_assignment_id		=> p_assignment_id,
			p_effective_date	=> p_effective_date,
			p_business_group_id	=> p_business_group_id,
			p_yea_info		=> p_yea_info);
	end if;
        ---------------
        if g_debug then
        	hr_utility.trace('=====================================================');
        	hr_utility.trace('Current Taxable : '||to_char(p_yea_info.cur_taxable));
        	hr_utility.trace('Previous Taxable : '||to_char(p_yea_info.prev_taxable));
		hr_utility.trace('Taxable : '||to_char(p_yea_info.taxable1)); --Bug 7615517
        	hr_utility.trace('Total Taxable : '||to_char(p_yea_info.taxable));
        	hr_utility.trace('Income Tax : '||to_char(p_yea_info.cur_itax));
        	hr_utility.trace('Resident Tax : '||to_char(p_yea_info.cur_itax));
        	hr_utility.trace('Income Tax Adjustment : '||to_char(p_yea_info.itax_adj));
        	hr_utility.trace('Resident Tax Adjustment : '||to_char(p_yea_info.rtax_adj));
        	hr_utility.trace('=====================================================');
        end if;
        ----------------
        ------------------------------------------------------------------------
	-- Setup output warnings
	------------------------------------------------------------------------
	p_taxable_earnings_warning	:= false;
	p_taxable_income_warning	:= false;
	p_taxation_base_warning		:= false;
	p_calc_tax_warning		:= false;
	p_itax_warning			:= false;
	p_rtax_warning			:= false;
	if p_yea_info.taxable <= 0 then
		p_taxable_earnings_warning := true;
	else
		if p_yea_info.taxable_income = 0 then
			p_taxable_income_warning := true;
		else
			if p_yea_info.taxation_base = 0 then
				p_taxation_base_warning := true;
			else
				if p_yea_info.calc_tax = 0 then
					p_calc_tax_warning := true;
				end if;
			end if;
		end if;
	end if;
	if p_yea_info.annual_itax = 0 then
		p_itax_warning := true;
	end if;
	if p_yea_info.annual_rtax = 0 then
		p_rtax_warning := true;
	end if;
end yea_info;
------------------------------------------------------------------------
function yea_info(
	p_assignment_action_id		in number) return t_yea_info
------------------------------------------------------------------------
is
	l_assignment_id			number;
	l_effective_date		date;
	l_user_entity_id_tbl		t_number_tbl;
	l_archive_item_value_tbl	t_varchar2_tbl;
	l_yea_info			t_yea_info;
	--
	cursor csr_archive is
		select
			u.user_entity_id,
			a.value
		from	pay_report_format_items_f	i,
			ff_database_items		d,
			ff_user_entities		u,
			ff_archive_items		a,
			pay_payroll_actions		ppa,
			pay_assignment_actions		paa
		where	paa.assignment_action_id = p_assignment_action_id
		and	ppa.payroll_action_id = paa.payroll_action_id
		and	a.context1 = paa.assignment_action_id
		and	a.value is not null
		and	u.user_entity_id = a.user_entity_id
		and	d.user_entity_id = u.user_entity_id
		--
		-- Default value for data type number is "0" in t_yea_info
		--
		and	decode(a.value, '0', decode(d.data_type, 'N', 'N', 'Y'), 'Y') = 'Y'
		and	i.report_type = nvl(ppa.report_type, u.user_entity_name)
		and	i.report_qualifier = ppa.report_qualifier
		and	i.report_category = ppa.report_category
		and	i.user_entity_id = u.user_entity_id
		and	ppa.effective_date
			between i.effective_start_date and i.effective_end_date
		order by i.display_sequence;
begin
	select	paa.assignment_id,
		ppa.effective_date
	into	l_assignment_id,
		l_effective_date
	from	pay_payroll_actions	ppa,
		pay_assignment_actions	paa
	where	paa.assignment_action_id = p_assignment_action_id
	and	ppa.payroll_action_id = paa.payroll_action_id;
	--
	-- Bulk collect archive items. Bulk collect is for better performance.
	--
	open csr_archive;
	fetch csr_archive bulk collect into l_user_entity_id_tbl, l_archive_item_value_tbl;
	close csr_archive;
	--
	l_yea_info := convert_to_rec(
			p_user_entity_id_tbl		=> l_user_entity_id_tbl,
			p_archive_item_value_tbl	=> l_archive_item_value_tbl);
	------------------------------------------------------------------------
	-- Bug 8644512
	------------------------------------------------------------------------
	ntax_earnings(
		p_assignment_id		=> l_assignment_id,
		p_effective_date	=> l_effective_date,
		p_ntax_detail_tbl	=> g_ntax_detail_tbl
		);
	------------------------------------------------------------------------
	-- Previous Employers' Information
	------------------------------------------------------------------------
	prev_er_info(
		p_assignment_id			=> l_assignment_id,
		p_effective_date		=> l_effective_date,
		p_hire_date_tbl			=> l_yea_info.prev_hire_date_tbl,		-- Bug 8644512
		p_termination_date_tbl		=> l_yea_info.prev_termination_date_tbl,
		p_corp_name_tbl			=> l_yea_info.prev_corp_name_tbl,
		p_bp_number_tbl			=> l_yea_info.prev_bp_number_tbl,
		p_tax_brk_pd_from_tbl		=> l_yea_info.prev_tax_brk_pd_from_tbl,		-- Bug 8644512
		p_tax_brk_pd_to_tbl		=> l_yea_info.prev_tax_brk_pd_to_tbl,		-- Bug 8644512
		p_taxable_mth_tbl		=> l_yea_info.prev_taxable_mth_tbl,
		p_taxable_bon_tbl		=> l_yea_info.prev_taxable_bon_tbl,
		p_sp_irreg_bonus_tbl		=> l_yea_info.prev_sp_irreg_bonus_tbl,
		p_stck_pur_opt_exec_earn_tbl	=> l_yea_info.prev_stck_pur_opt_exe_earn_tbl,  -- Bug 6024342
		p_non_taxable_ovs_tbl		=> l_yea_info.prev_non_taxable_ovs_tbl,
		p_non_taxable_ovt_tbl		=> l_yea_info.prev_non_taxable_ovt_tbl,
		p_non_taxable_oth_tbl		=> l_yea_info.prev_non_taxable_oth_tbl,
		p_hi_prem_tbl			=> l_yea_info.prev_hi_prem_tbl,
		p_ltci_prem_tbl			=> l_yea_info.prev_ltci_prem_tbl,  -- Bug 7260606
		p_ei_prem_tbl			=> l_yea_info.prev_ei_prem_tbl,
		p_np_prem_tbl			=> l_yea_info.prev_np_prem_tbl,
		p_pen_prem_tbl			=> l_yea_info.prev_pen_prem_tbl,     --  Bug 6024342
		p_separation_pension_tbl	=> l_yea_info.prev_separation_pension_tbl, 	-- Bug 7508706
		p_itax_tbl			=> l_yea_info.prev_itax_tbl,
		p_rtax_tbl			=> l_yea_info.prev_rtax_tbl,
		p_stax_tbl			=> l_yea_info.prev_stax_tbl,
		p_research_payment_tbl         =>  l_yea_info.prev_research_payment_tbl,         -- Bug 8341054
		p_bir_raising_allowance_tbl     => l_yea_info.prev_bir_raising_allowance_tbl,    -- Bug 8341054
		p_foreign_worker_exem_tbl       => l_yea_info.prev_foreign_wrkr_inc_exem_tbl,      -- Bug 8341054
		p_esop_withd_earn_tbl		=> l_yea_info.prev_esop_withd_earn_tbl,		-- Bug 8644512
		p_prev_ntax_G01_tbl		=> l_yea_info.prev_ntax_G01_tbl,	-- Bug 8644512
		p_prev_ntax_H01_tbl		=> l_yea_info.prev_ntax_H01_tbl,	-- Bug 8644512
		p_prev_ntax_H05_tbl		=> l_yea_info.prev_ntax_H05_tbl,	-- Bug 8644512
		p_prev_ntax_H06_tbl		=> l_yea_info.prev_ntax_H06_tbl,	-- Bug 8644512
		p_prev_ntax_H07_tbl		=> l_yea_info.prev_ntax_H07_tbl,	-- Bug 8644512
		p_prev_ntax_H08_tbl		=> l_yea_info.prev_ntax_H08_tbl,	-- Bug 8644512
		p_prev_ntax_H09_tbl		=> l_yea_info.prev_ntax_H09_tbl,	-- Bug 8644512
		p_prev_ntax_H10_tbl		=> l_yea_info.prev_ntax_H10_tbl,	-- Bug 8644512
		p_prev_ntax_H11_tbl		=> l_yea_info.prev_ntax_H11_tbl,	-- Bug 8644512
		p_prev_ntax_H12_tbl		=> l_yea_info.prev_ntax_H12_tbl,	-- Bug 8644512
		p_prev_ntax_H13_tbl		=> l_yea_info.prev_ntax_H13_tbl,	-- Bug 8644512
		p_prev_ntax_I01_tbl		=> l_yea_info.prev_ntax_I01_tbl,	-- Bug 8644512
		p_prev_ntax_K01_tbl		=> l_yea_info.prev_ntax_K01_tbl,	-- Bug 8644512
		p_prev_ntax_M01_tbl		=> l_yea_info.prev_ntax_M01_tbl,	-- Bug 8644512
		p_prev_ntax_M02_tbl		=> l_yea_info.prev_ntax_M02_tbl,	-- Bug 8644512
		p_prev_ntax_M03_tbl		=> l_yea_info.prev_ntax_M03_tbl,	-- Bug 8644512
		p_prev_ntax_S01_tbl		=> l_yea_info.prev_ntax_S01_tbl,	-- Bug 8644512
		p_prev_ntax_T01_tbl		=> l_yea_info.prev_ntax_T01_tbl,	-- Bug 8644512
		p_prev_ntax_Y01_tbl		=> l_yea_info.prev_ntax_Y01_tbl,	-- Bug 8644512
		p_prev_ntax_Y02_tbl		=> l_yea_info.prev_ntax_Y02_tbl,	-- Bug 8644512
		p_prev_ntax_Y03_tbl		=> l_yea_info.prev_ntax_Y03_tbl,	-- Bug 8644512
		p_prev_ntax_Y20_tbl		=> l_yea_info.prev_ntax_Y20_tbl,	-- Bug 8644512
		p_prev_ntax_Z01_tbl		=> l_yea_info.prev_ntax_Z01_tbl		-- Bug 8644512
		);
	------------------------------------------------------------------------
	-- Dependent Education Expense Tax Exemption Information
	------------------------------------------------------------------------
	dpnt_educ_tax_exem_info(
		p_assignment_id			=> l_assignment_id,
		p_effective_date		=> l_effective_date,
		p_contact_name_tbl		=> l_yea_info.dpnt_educ_contact_name_tbl,	-- Bug 9079450
		p_contact_ni_tbl		=> l_yea_info.dpnt_educ_contact_ni_tbl,		-- Bug 9079450
		p_contact_type_tbl		=> l_yea_info.dpnt_educ_contact_type_tbl,
		p_school_type_tbl		=> l_yea_info.dpnt_educ_school_type_tbl,
		p_exp_tbl			=> l_yea_info.dpnt_educ_exp_tbl);
	--
	return l_yea_info;
end yea_info;
--------------------------------------------------------------------------------
procedure chk_assignment_id(
		p_business_group_id	in number,
		p_assignment_id		in number,
		p_bal_asg_action_id	in number,
		p_effective_date	in date,
		p_payroll_id		in number,
		p_report_category	in varchar2,
		p_error                 out nocopy varchar2)
--------------------------------------------------------------------------------
is
	l_proc	constant  varchar2(61) := g_package || 'chk_assignment_id';
	l_business_group_id	number;
	l_esd			date;
	l_eed			date;
	l_payroll_id		number;

	cursor csr_asg is
		select
			pa.business_group_id,
			pa.effective_start_date,
			pa.effective_end_date,
			pa.payroll_id
		from	per_assignments_f	pa
		where	pa.assignment_id = p_assignment_id
		and	pa.assignment_type = 'E'
		and	pa.effective_start_date <= p_effective_date
		and	pa.effective_end_date >= trunc(p_effective_date, 'YYYY')
		order by pa.effective_start_date desc
		for update of pa.assignment_id;

	l_exists		varchar2(1);

	cursor csr_incomplete_exists is
		select
			'Y'
		from	dual
		where	exists(
				select	null
				from	pay_action_classifications	pac,
					pay_payroll_actions		ppa,
					pay_assignment_actions		paa
				where	paa.assignment_id = p_assignment_id
				and	paa.action_status not in ('C', 'S') -- Bug 4442484: A 'S'kipped assact is not an errored one
				and     paa.assignment_action_id <> p_bal_asg_action_id
				and	paa.source_action_id is null
				and	ppa.payroll_action_id = paa.payroll_action_id
				and	ppa.effective_date <= p_effective_date
				and	pac.action_type = ppa.action_type
				and	pac.classification_name = 'SEQUENCED');

	l_effective_date	date;

	cursor csr_archive_exists
	is
	   select  ppa.effective_date
	     from  pay_payroll_actions			ppa,
		   pay_assignment_actions		paa
	    where  paa.assignment_id    	 =  p_assignment_id
	      and  ppa.payroll_action_id	 =  paa.payroll_action_id
	      and  paa.source_action_id 	 is null
	      and  ppa.action_type      	 IN ('X','B')
	      and  ppa.report_type 		 = 'YEA'
	      and  ppa.report_qualifier		 = 'KR'
	      and  ppa.report_category		 IN ('N','I')
	      and  trunc(ppa.effective_date, 'YYYY') = trunc(p_effective_date, 'YYYY')
	    order by paa.action_sequence desc;

	cursor csr_bal_adj_exists(p_payroll_id pay_payroll_actions.payroll_id%type)
	is
	   select  ppa.effective_date
	     from  pay_payroll_actions			ppa,
		   pay_assignment_actions		paa
	    where  paa.assignment_id    	 =  p_assignment_id
	      and  ppa.payroll_action_id	 =  paa.payroll_action_id
              and  ppa.payroll_id                =  p_payroll_id -- Bug 5045110
	      and  paa.assignment_action_id      <> p_bal_asg_action_id
	      and  paa.source_action_id 	 is null
	      and  ppa.action_type      	 =  'B'
	      and  pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'REPORT_TYPE', null) = 'YEA'
	      and  pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'REPORT_QUALIFIER', null) = 'KR'
	      and  pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'REPORT_CATEGORY', null) IN ('N','I')
	      and  ppa.effective_date            between trunc(p_effective_date, 'YYYY')
                                                 and (trunc(add_months(p_effective_date, 12), 'YYYY') - 1) -- Bug 5045110
	    order by paa.action_sequence desc;

begin
	--
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.chk_assignment_id.',10);
	end if;
	--
	hr_api.mandatory_arg_error(
		p_api_name		=> l_proc,
		p_argument		=> 'business_group_id',
		p_argument_value	=> p_business_group_id);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_proc,
		p_argument		=> 'assignment_id',
		p_argument_value	=> p_assignment_id);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_proc,
		p_argument		=> 'effective_date',
		p_argument_value	=> p_effective_date);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_proc,
		p_argument		=> 'payroll_id',
		p_argument_value	=> p_payroll_id);
	hr_api.mandatory_arg_error(
		p_api_name		=> l_proc,
		p_argument		=> 'report_category',
		p_argument_value	=> p_report_category);
	--
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.chk_assignment_id.',20);
	end if;
	--
	open csr_asg;
	fetch csr_asg into l_business_group_id, l_esd, l_eed, l_payroll_id;

	if csr_asg%NOTFOUND then
		--
		close csr_asg;
		--
		if g_debug then
			hr_utility.set_location('pay_kr_yea_pkg.chk_assignment_id.',30);
		end if;
		--
		fnd_message.set_name('PAY', 'PAY_KR_INV_ASG');
		p_error := fnd_message.get;
		return;
	else
		--
		close csr_asg;
		--
		if g_debug then
			hr_utility.set_location('pay_kr_yea_pkg.chk_assignment_id.',40);
		end if;
		--
		--
		-- Business Group Validation
		--
		if l_business_group_id <> p_business_group_id then
			fnd_message.set_name('PAY', 'PAY_KR_INV_ASG_BG');
			p_error := fnd_message.get;
			return;
		end if;
		--
		-- Effective Date Validation
		--
		if p_effective_date not between l_esd and l_eed then
			fnd_message.set_name('PAY', 'PAY_KR_INV_ASG');
			p_error := fnd_message.get;
			return;
		end if;
		--
		-- Payroll Validation
		--
		if l_payroll_id <> p_payroll_id then
			fnd_message.set_name('PAY', 'PAY_KR_INV_ASG_PAYROLL');
			p_error := fnd_message.get;
			return;
		end if;
	end if;
	--
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.chk_assignment_id.',50);
	end if;
	------------------------------------------------------------------------
	-- If invalid assacts exist before effective_date, raise error.
	------------------------------------------------------------------------
	open csr_incomplete_exists;
	fetch csr_incomplete_exists into l_exists;

	if csr_incomplete_exists%FOUND then
		close csr_incomplete_exists;
		fnd_message.set_name('PAY', 'PAY_KR_INCOMP_ASSACT_EXISTS');
		p_error := fnd_message.get;
		return;
	end if;
	--
	if csr_incomplete_exists%ISOPEN then
		close csr_incomplete_exists;
	end if;
	--
	if g_debug then
		hr_utility.set_location('pay_kr_yea_pkg.chk_assignment_id.',60);
	end if;
	------------------------------------------------------------------------
	-- YEA Type Validation
	------------------------------------------------------------------------
	open  csr_archive_exists;
	fetch csr_archive_exists into l_effective_date;

	if csr_archive_exists%FOUND then
		--
		if g_debug then
			hr_utility.set_location('pay_kr_yea_pkg.chk_assignment_id.',70);
		end if;
		--
		close csr_archive_exists;

		if l_effective_date > p_effective_date then
			fnd_message.set_name('PAY', 'PAY_KR_YEA_ALREADY_PROCESSED');
			fnd_message.set_token('EFFECTIVE_DATE', fnd_date.date_to_displaydate(l_effective_date));
			p_error := fnd_message.get;
			return;
		else
			if p_report_category in ('N', 'I') then
				fnd_message.set_name('PAY', 'PAY_KR_RUN_REYEA_NOT_YEA');
				p_error := fnd_message.get;
				return;
			end if;
		end if;
	else
		--
		if g_debug then
			hr_utility.set_location('pay_kr_yea_pkg.chk_assignment_id.',80);
		end if;
		--
		close csr_archive_exists;

		open  csr_bal_adj_exists(l_payroll_id) ;
		fetch csr_bal_adj_exists into l_effective_date;

		if csr_bal_adj_exists%FOUND then

			close csr_bal_adj_exists;
			fnd_message.set_name('PAY', 'PAY_KR_ROLLBACK_BAL_ADJ');
			p_error := fnd_message.get;
			return;
		else
			close csr_bal_adj_exists;

			if p_report_category = 'R' then
				fnd_message.set_name('PAY', 'PAY_KR_RUN_YEA_NOT_REYEA');
				p_error := fnd_message.get;
				return;
			end if;
		end if;
	end if;

end chk_assignment_id;
--------------------------------------------------------------------------------
procedure process_assignment(
	p_validate		in boolean,
	p_business_group_id	in number,
	p_assignment_id		in number,
	p_assignment_action_id  in number,
	p_bal_asg_action_id	in number,
	p_report_type		in out nocopy varchar2,
	p_report_qualifier	in out nocopy varchar2,
	p_report_category	in out nocopy varchar2,
	p_effective_date	in out nocopy date,
	p_payroll_id		in out nocopy number,
	p_consolidation_set_id	in out nocopy number,
        p_archive_type_used     in out nocopy varchar2)  -- Bug 5036734
--------------------------------------------------------------------------------
is
	l_yea_info			t_yea_info;
	l_taxable_earnings_warning	boolean;
	l_taxable_income_warning	boolean;
	l_taxation_base_warning		boolean;
	l_calc_tax_warning		boolean;
	l_itax_warning			boolean;
	l_rtax_warning			boolean;
        -- Bug 2878937
        l_tax_adj_warning               boolean;
	l_entry_value_tbl		hr_entry.varchar2_table;
	l_user_entity_id_tbl		t_number_tbl;
	l_archive_item_value_tbl	t_varchar2_tbl;
	l_message_level_tbl		t_varchar2_tbl;
	l_message_text_tbl		t_varchar2_tbl;
	--------------------------------------------------------------------------------
	procedure set_message(
		p_condition			in boolean,
		p_message_level			in varchar2,
		p_application_short_name	in varchar2,
		p_message_name			in varchar2,
		p_token_name1			in varchar2,
		p_token_value1			in varchar2)
	--------------------------------------------------------------------------------
	is
		l_index	number;
	begin
		if p_condition then
			l_index := l_message_level_tbl.count + 1;
			fnd_message.set_name(p_application_short_name, p_message_name);
			if p_token_name1 is not null then
				fnd_message.set_token(p_token_name1, p_token_value1);
			end if;
			l_message_level_tbl(l_index) := p_message_level;
			l_message_text_tbl(l_index)  := fnd_message.get;
		end if;
	end set_message;
begin
	------------------------------------------------------------------------
	-- Process YEA
	------------------------------------------------------------------------
	if g_debug then
	   hr_utility.trace('Running YEA ..........................................');
	end if;
	--
	yea_info(
		p_assignment_id			=> p_assignment_id,
		p_assignment_action_id		=> p_bal_asg_action_id,
		p_effective_date		=> p_effective_date,
		p_business_group_id		=> p_business_group_id,
		p_payroll_id         		=> p_payroll_id,
		p_yea_info			=> l_yea_info,
		p_taxable_earnings_warning	=> l_taxable_earnings_warning,
		p_taxable_income_warning	=> l_taxable_income_warning,
		p_taxation_base_warning		=> l_taxation_base_warning,
		p_calc_tax_warning		=> l_calc_tax_warning,
		p_itax_warning			=> l_itax_warning,
		p_rtax_warning			=> l_rtax_warning,
                p_tax_adj_warning               => l_tax_adj_warning);

        --
        if g_debug then
	        hr_utility.trace('p_yea_info.cur_itax '||to_char(l_yea_info.cur_itax));
	        hr_utility.trace('p_yea_info.cur_rtax '||to_char(l_yea_info.cur_rtax));
	        hr_utility.trace('p_yea_info.cur_stax '||to_char(l_yea_info.cur_stax));
	        hr_utility.trace('p_yea_info.itax_adj '||to_char(l_yea_info.itax_adj));
	        hr_utility.trace('p_yea_info.rtax_adj '||to_char(l_yea_info.rtax_adj));
	        hr_utility.trace('p_yea_info.stax_adj '||to_char(l_yea_info.stax_adj));
           hr_utility.trace('Checking Balance...........');
        end if;
	--
	pay_balance_pkg.get_value ( p_assignment_action_id => p_bal_asg_action_id
	                           ,p_defined_balance_lst  => g_tax_adj_balance_tab );
	--
        if g_debug then
           hr_utility.trace('Balance Value of itax_adj = '||to_char(g_tax_adj_balance_tab(1).balance_value));
           hr_utility.trace('Balance Value of rtax_adj = '||to_char(g_tax_adj_balance_tab(2).balance_value));
           hr_utility.trace('Balance Value of stax_adj = '||to_char(g_tax_adj_balance_tab(3).balance_value));
        end if;
        -----------------------------------------------------------------------
        if g_tax_adj_balance_tab(1).balance_value <> l_yea_info.itax_adj OR
           g_tax_adj_balance_tab(2).balance_value <> l_yea_info.rtax_adj OR
           g_tax_adj_balance_tab(3).balance_value <> l_yea_info.stax_adj
        then
		--
		if g_debug then
			hr_utility.trace('Incorrect Balance Adjustment amount');
		end if;
		--
		fnd_message.set_name('PAY', 'PAY_KR_INCORRECT_ADJ_AMT');
		fnd_message.set_token('ASSIGNMENT_ID', p_assignment_id);
		--
		insert into pay_message_lines(
			LINE_SEQUENCE,
			PAYROLL_ID,
			MESSAGE_LEVEL,
			SOURCE_ID,
			SOURCE_TYPE,
			LINE_TEXT)
		values( pay_message_lines_s.nextval,
			p_payroll_id,
			'F',
			p_assignment_action_id,
			'A',
			fnd_message.get);
		--
		fnd_message.raise_error;
        else
		--
		if g_debug then
			hr_utility.trace('Archiving...................');
		end if;
		------------------------------------------------------------------------
		-- Convert from YEA result from record variable to PL/SQL table.
		------------------------------------------------------------------------
		convert_to_tbl(
			p_report_type                   => p_report_type,
			p_report_qualifier              => p_report_qualifier,
			p_report_category               => p_report_category,
			p_effective_date                => p_effective_date,
			p_yea_info                      => l_yea_info,
			p_user_entity_id_tbl            => l_user_entity_id_tbl,
			p_archive_item_value_tbl        => l_archive_item_value_tbl);
		--
                -- Bug 5036734 : Need to delete archive records while retrying
                --               an archive process that used AAC archive type
                if p_archive_type_used <> 'AAP' then  -- old archive, delete manually.

                    delete from ff_archive_items
                    where CONTEXT1 = p_assignment_action_id
                    and ARCHIVE_TYPE = 'AAC';

                end if;

		------------------------------------------------------------------------
		-- Insert into FF_ARCHIVE_ITEMS
		------------------------------------------------------------------------
		forall i in 1..l_user_entity_id_tbl.count
			insert into ff_archive_items(
				ARCHIVE_ITEM_ID,
				USER_ENTITY_ID,
				CONTEXT1,
				VALUE,
				ARCHIVE_TYPE)
			values( ff_archive_items_s.nextval,
				l_user_entity_id_tbl(i),
				p_assignment_action_id,
				l_archive_item_value_tbl(i),
                                p_archive_type_used);  -- Bug 5036734
		--
		------------------------------------------------------------------------
		-- Convert message information to PL/SQL table.
		------------------------------------------------------------------------
		--
		set_message(l_taxable_earnings_warning, 'W', 'PAY', 'PAY_KR_NGTV_TAXABLE_EARNINGS', 'TAXABLE_EARNINGS', to_char(l_yea_info.taxable));
		set_message(l_taxable_income_warning, 'I', 'PAY', 'PAY_KR_TAXABLE_INCOME_ZERO',null,null);
		set_message(l_taxation_base_warning, 'I', 'PAY', 'PAY_KR_TAXATION_BASE_ZERO',null,null);
		set_message(l_calc_tax_warning, 'I', 'PAY', 'PAY_KR_CALC_TAX_ZERO',null,null);
		set_message(l_itax_warning, 'I', 'PAY', 'PAY_KR_ITAX_ZERO',null,null);
		set_message(l_rtax_warning, 'I', 'PAY', 'PAY_KR_RTAX_ZERO',null,null);
		set_message(l_tax_adj_warning, 'I', 'PAY', 'PAY_KR_ADJ_LESS_THAN_THOUSAND', null, null);

		--
		------------------------------------------------------------------------
		-- Insert into PAY_MESSAGE_LINES
		------------------------------------------------------------------------
		forall i in 1..l_message_level_tbl.count
			insert into pay_message_lines(
				LINE_SEQUENCE,
				PAYROLL_ID,
				MESSAGE_LEVEL,
				SOURCE_ID,
				SOURCE_TYPE,
				LINE_TEXT)
			values( pay_message_lines_s.nextval,
				p_payroll_id,
				l_message_level_tbl(i),
				p_assignment_action_id,
				'A',
				l_message_text_tbl(i));
		--
        end if;

exception
	when hr_api.validate_enabled then
		fnd_message.raise_error;
end process_assignment;
--
---------------------------------------------------------------------------------------------------------------
-- New function added to get the adj amount and feed it to ITAX_ADJ,RTAX_ADJ,STAX_ADJ elements
-- using formula results
---------------------------------------------------------------------------------------------------------------
function calculate_adjustment(
           p_assignment_id                 in pay_assignment_actions.assignment_id%type,
           p_business_group_id             in pay_payroll_actions.business_group_id%type,
           p_effective_date                in pay_payroll_actions.effective_date%type,
           p_payroll_action_id             in pay_payroll_actions.payroll_action_id%type,
           p_assignment_action_id          in pay_assignment_actions.assignment_action_id%type,
           p_itax_adj                      out nocopy number,
           p_rtax_adj                      out nocopy number,
           p_stax_adj                      out nocopy number,
           p_error                         out nocopy varchar2
           ) return number
---------------------------------------------------------------------------------------------------------------
is
  l_yea_info                             t_yea_info;
  l_tax_adj_warning                      boolean;
  l_taxable_earnings_warning             boolean;
  l_taxable_income_warning               boolean;
  l_taxation_base_warning                boolean;
  l_calc_tax_warning                     boolean;
  l_itax_warning                         boolean;
  l_rtax_warning                         boolean;
  l_return                               number;
  ------------------------------------------------------------------------------
  cursor csr_pact
  IS
   select  pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'REPORT_CATEGORY', null) report_category
          ,ppa.element_type_id       element_type_id
          ,ppa.payroll_id            payroll_id
     from  pay_payroll_actions ppa
    where  ppa.payroll_action_id     = p_payroll_action_id;
    -------------------------------------------
    r_pact          csr_pact%rowtype;
    -------------------------------------------
begin
   --
   hr_api.validate_bus_grp_id(p_business_group_id);
   --
   if g_debug then
      hr_utility.trace('Assignment Id: '||to_char(p_assignment_id)||' Payroll Action Id: '||to_char(p_payroll_action_id));
      hr_utility.trace('Effective Date: '||to_char(p_effective_date)||' Business Group Id: '||to_char(p_business_group_id));
   end if;
   --
   open  csr_pact;
   fetch csr_pact into r_pact;
   close csr_pact;
   --
   if g_debug then
        hr_utility.trace('Checking Assignment');
   end if;
   ------------------------------------------------------------------------
   -- Assignment validation
   ------------------------------------------------------------------------
   chk_assignment_id(
		p_business_group_id	=> p_business_group_id,
		p_assignment_id		=> p_assignment_id,
		p_bal_asg_action_id	=> p_assignment_action_id,
		p_effective_date	=> p_effective_date,
		p_payroll_id		=> r_pact.payroll_id,
		p_report_category	=> r_pact.report_category,
		p_error                 => p_error);
   --
   if g_debug then
	hr_utility.trace('After checking assignment');
   end if;
   --
   if p_error is not null then
        return 1;  -- failure
   else
           --
	   if g_debug then
	      hr_utility.trace('Calculating Adjustments');
	   end if;
	   --
	   -------------------------------------------------------------------------
	   -- Calculate Tax Adjustments
	   -------------------------------------------------------------------------
	   yea_info(p_assignment_id             => p_assignment_id,
		    p_assignment_action_id      => p_assignment_action_id,
		    p_effective_date            => p_effective_date,
		    p_business_group_id         => p_business_group_id,
		    p_payroll_id         	=> r_pact.payroll_id,
		    p_yea_info                  => l_yea_info,
		    p_taxable_earnings_warning  => l_taxable_earnings_warning,
		    p_taxable_income_warning    => l_taxable_income_warning,
		    p_taxation_base_warning     => l_taxation_base_warning,
		    p_calc_tax_warning          => l_calc_tax_warning,
		    p_itax_warning              => l_itax_warning,
		    p_rtax_warning              => l_rtax_warning,
		    p_tax_adj_warning           => l_tax_adj_warning);


	   p_itax_adj := l_yea_info.itax_adj;
	   p_rtax_adj := l_yea_info.rtax_adj;
	   p_stax_adj := l_yea_info.stax_adj;

	   if g_debug then
	      hr_utility.trace('p_itax_adj '||to_char(p_itax_adj));
	      hr_utility.trace('p_rtax_adj '||to_char(p_rtax_adj));
	      hr_utility.trace('p_stax_adj '||to_char(p_stax_adj));
	   end if;

	   return 0; -- success
   end if;
   --
---------------------------------------------------------------------------------------------------------------
end calculate_adjustment;
---------------------------------------------------------------------------------------------------------------
BEGIN
	------------------------------------------------------------------------
	-- Package initialization section
	------------------------------------------------------------------------
	declare
		l_user_entity_id_tbl	t_number_tbl;
		l_user_entity_name_tbl	t_varchar2_tbl;
		--------------------------------------------------------
		function defined_balance_id(p_user_name in varchar2) return number
		--------------------------------------------------------
		is
			l_defined_balance_id	number;
		begin
			select
				u.creator_id
			into	l_defined_balance_id
			from	ff_user_entities	u,
				ff_database_items	d
			where	d.user_name = p_user_name
			and	u.user_entity_id = d.user_entity_id
			and	u.legislation_code = 'KR'
			and	u.business_group_id is null
			and	u.creator_type = 'B';
			--
			return l_defined_balance_id;
		end defined_balance_id;
		--------------------------------------------------------
		function element(p_element_name	in varchar2) return t_element
		--------------------------------------------------------
		is
			l_element	t_element;
		begin
			select
				element_type_id
			into	l_element.element_type_id
			from	pay_element_types_f
			where	element_name = p_element_name
			and	legislation_code = 'KR'
			and	business_group_id is null
			group by element_type_id;
			--
			select
				input_value_id,
				min(name)
			bulk collect into
				l_element.input_value_id_tbl,
				l_element.input_value_name_tbl
			from	pay_input_values_f
			where	element_type_id = l_element.element_type_id
			and	legislation_code = 'KR'
			and	business_group_id is null
			group by input_value_id;
			--
			return l_element;
		end element;
		--------------------------------------------------------
		function user_entity_id(p_user_entity_name in varchar2) return number
		--------------------------------------------------------
		is
			l_index			number;
			l_user_entity_id	number;
		begin
			l_index := l_user_entity_id_tbl.first;
			while l_index is not null loop
				if l_user_entity_name_tbl(l_index) = p_user_entity_name then
					l_user_entity_id := l_user_entity_id_tbl(l_index);
					l_user_entity_id_tbl.delete(l_index);
					l_user_entity_name_tbl.delete(l_index);
					exit;
				end if;
				l_index := l_user_entity_id_tbl.next(l_index);
			end loop;
			--
			if l_user_entity_id is null then
				raise no_data_found;
			end if;
			--
			return l_user_entity_id;
		end user_entity_id;

	begin
	--
	open csr_contexts;
	fetch csr_contexts bulk collect into g_contexts_tab;
	close csr_contexts;
		------------------------------------------------------------------------
		--  Collecting Defined Balance Id into g_balance_value_tab table
		------------------------------------------------------------------------
		g_balance_value_tab(1).defined_balance_id := defined_balance_id('SP_IRREG_BONUS_ASG_YTD_MTH');
		g_balance_value_tab(2).defined_balance_id := defined_balance_id('SP_IRREG_BONUS_ASG_YTD_BON');
		g_balance_value_tab(3).defined_balance_id := defined_balance_id('TOTAL_TAXABLE_EARNINGS_ASG_YTD_MTH');
		g_balance_value_tab(4).defined_balance_id := defined_balance_id('TOTAL_TAXABLE_EARNINGS_ASG_YTD_BON');
		g_balance_value_tab(5).defined_balance_id := defined_balance_id('TOTAL_NON_TAXABLE_EARNINGS_ASG_YTD_MTH');
		g_balance_value_tab(6).defined_balance_id := defined_balance_id('TOTAL_NON_TAXABLE_EARNINGS_ASG_YTD_BON');
		g_balance_value_tab(7).defined_balance_id := defined_balance_id('NON_TAXABLE_OVS_EARNINGS_ASG_YTD_MTH');
		g_balance_value_tab(8).defined_balance_id := defined_balance_id('NON_TAXABLE_OVS_EARNINGS_ASG_YTD_BON');
		g_balance_value_tab(9).defined_balance_id := defined_balance_id('NON_TAXABLE_OVT_EARNINGS_ASG_YTD_MTH');
		g_balance_value_tab(10).defined_balance_id := defined_balance_id('NON_TAXABLE_OVT_EARNINGS_ASG_YTD_BON');
		g_balance_value_tab(11).defined_balance_id := defined_balance_id('HI_PREM_EE_ASG_YTD');
		-- Bug 7164589
		g_balance_value_tab(29).defined_balance_id := defined_balance_id('LTCI_PREM_EE_ASG_YTD');
		-- End of Bug 7164589
		g_balance_value_tab(12).defined_balance_id := defined_balance_id('EI_PREM_ASG_YTD');
		g_balance_value_tab(13).defined_balance_id := defined_balance_id('NP_PREM_EE_ASG_YTD');
		-- Bug 6024342
		g_balance_value_tab(28).defined_balance_id := defined_balance_id('PENSION_PREMIUM_ASG_YTD');
		--
		g_balance_value_tab(14).defined_balance_id := defined_balance_id('ITAX_ASG_YTD_MTH');
		g_balance_value_tab(15).defined_balance_id := defined_balance_id('ITAX_ASG_YTD_BON');
		g_balance_value_tab(16).defined_balance_id := defined_balance_id('RTAX_ASG_YTD_MTH');
		g_balance_value_tab(17).defined_balance_id := defined_balance_id('RTAX_ASG_YTD_BON');
		g_balance_value_tab(18).defined_balance_id := defined_balance_id('STAX_ASG_YTD_MTH');
		g_balance_value_tab(19).defined_balance_id := defined_balance_id('STAX_ASG_YTD_BON');
		-- Bug 3201332
		--Bug 7142620
		g_balance_value_tab(30).defined_balance_id := defined_balance_id('BIRTH_RAISING_ALLOWANCE_ASG_YTD_MTH');
		g_balance_value_tab(31).defined_balance_id := defined_balance_id('BIRTH_RAISING_ALLOWANCE_ASG_YTD_BON');
		--End of Bug 7142620
		-- Bug 7439803
		g_balance_value_tab(32).defined_balance_id := defined_balance_id('NON_TAXABLE_OVS_FRGN_EARNINGS_ASG_YTD_MTH');
		g_balance_value_tab(33).defined_balance_id := defined_balance_id('NON_TAXABLE_OVS_FRGN_EARNINGS_ASG_YTD_BON');
		--
		-- Bug 8644512
		g_balance_value_tab(34).defined_balance_id := defined_balance_id('ESOP_WITHDRAWAL_EARNINGS_ASG_YTD_MTH');
		g_balance_value_tab(35).defined_balance_id := defined_balance_id('ESOP_WITHDRAWAL_EARNINGS_ASG_YTD_BON');
		--
		g_balance_value_tab(20).defined_balance_id := defined_balance_id('MONTHLY_REGULAR_EARNINGS_ASG_YTD');
                -- Added for Bug3021585
		-- Bug 4750653
		g_balance_value_tab(21).defined_balance_id := defined_balance_id('CORPORATE_PENSION_ASG_YTD');
		-- End of Bug 4750653
		-- Bug 5756699
		g_balance_value_tab(22).defined_balance_id := defined_balance_id('ADDITIONAL_OTHER_NON_TAXABLE_EARNINGS_ASG_YTD_MTH');
		g_balance_value_tab(23).defined_balance_id := defined_balance_id('ADDITIONAL_OTHER_NON_TAXABLE_EARNINGS_ASG_YTD_BON');
		-- Bug 6012258
		g_balance_value_tab(24).defined_balance_id := defined_balance_id('STOCK_PURCHASE_OPTION_EXECUTION_EARNING_ASG_YTD_MTH');
		g_balance_value_tab(25).defined_balance_id := defined_balance_id('STOCK_PURCHASE_OPTION_EXECUTION_EARNING_ASG_YTD_BON');
		g_balance_value_tab(26).defined_balance_id := defined_balance_id('RESEARCH_PAYMENT_ASG_YTD_MTH');
		g_balance_value_tab(27).defined_balance_id := defined_balance_id('RESEARCH_PAYMENT_ASG_YTD_BON');
		--End of Bug 6012258
		-- End of Bug 5756699
		g_tax_adj_balance_tab(1).defined_balance_id := defined_balance_id('INCOME_TAX_ADJUSTMENT_ASG_RUN');
		g_tax_adj_balance_tab(2).defined_balance_id := defined_balance_id('RESIDENT_TAX_ADJUSTMENT_ASG_RUN');
		g_tax_adj_balance_tab(3).defined_balance_id := defined_balance_id('SPECIAL_TAX_ADJUSTMENT_ASG_RUN');
		-- Bug 8644512
		g_balance_value_tab(36).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_G01_ASG_YTD_MTH');
		g_balance_value_tab(37).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_G01_ASG_YTD_BON');
		g_balance_value_tab(38).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H01_ASG_YTD_MTH');
		g_balance_value_tab(39).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H01_ASG_YTD_BON');
		g_balance_value_tab(40).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H05_ASG_YTD_MTH');
		g_balance_value_tab(41).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H05_ASG_YTD_BON');
		g_balance_value_tab(42).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H06_ASG_YTD_MTH');
		g_balance_value_tab(43).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H06_ASG_YTD_BON');
		g_balance_value_tab(44).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H07_ASG_YTD_MTH');
		g_balance_value_tab(45).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H07_ASG_YTD_BON');
		g_balance_value_tab(46).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H08_ASG_YTD_MTH');
		g_balance_value_tab(47).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H08_ASG_YTD_BON');
		g_balance_value_tab(48).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H09_ASG_YTD_MTH');
		g_balance_value_tab(49).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H09_ASG_YTD_BON');
		g_balance_value_tab(50).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H10_ASG_YTD_MTH');
		g_balance_value_tab(51).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H10_ASG_YTD_BON');
		g_balance_value_tab(52).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H11_ASG_YTD_MTH');
		g_balance_value_tab(53).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H11_ASG_YTD_BON');
		g_balance_value_tab(54).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H12_ASG_YTD_MTH');
		g_balance_value_tab(55).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H12_ASG_YTD_BON');
		g_balance_value_tab(56).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H13_ASG_YTD_MTH');
		g_balance_value_tab(57).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_H13_ASG_YTD_BON');
		g_balance_value_tab(58).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_I01_ASG_YTD_MTH');
		g_balance_value_tab(59).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_I01_ASG_YTD_BON');
		g_balance_value_tab(60).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_K01_ASG_YTD_MTH');
		g_balance_value_tab(61).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_K01_ASG_YTD_BON');
		g_balance_value_tab(62).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_M01_ASG_YTD_MTH');
		g_balance_value_tab(63).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_M01_ASG_YTD_BON');
		g_balance_value_tab(64).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_M02_ASG_YTD_MTH');
		g_balance_value_tab(65).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_M02_ASG_YTD_BON');
		g_balance_value_tab(66).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_M03_ASG_YTD_MTH');
		g_balance_value_tab(67).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_M03_ASG_YTD_BON');
		g_balance_value_tab(68).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_S01_ASG_YTD_MTH');
		g_balance_value_tab(69).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_S01_ASG_YTD_BON');
		g_balance_value_tab(70).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_T01_ASG_YTD_MTH');
		g_balance_value_tab(71).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_T01_ASG_YTD_BON');
		g_balance_value_tab(72).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_Y01_ASG_YTD_MTH');
		g_balance_value_tab(73).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_Y01_ASG_YTD_BON');
		g_balance_value_tab(74).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_Y02_ASG_YTD_MTH');
		g_balance_value_tab(75).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_Y02_ASG_YTD_BON');
		g_balance_value_tab(76).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_Y03_ASG_YTD_MTH');
		g_balance_value_tab(77).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_Y03_ASG_YTD_BON');
		g_balance_value_tab(78).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_Y20_ASG_YTD_MTH');
		g_balance_value_tab(79).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_Y20_ASG_YTD_BON');
		g_balance_value_tab(80).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_Z01_ASG_YTD_MTH');
		g_balance_value_tab(81).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_Z01_ASG_YTD_BON');
		--
		-- Bug 8880364
		--
		g_balance_value_tab(82).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_FRGN_M01_ASG_YTD_MTH');
		g_balance_value_tab(83).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_FRGN_M01_ASG_YTD_BON');
		g_balance_value_tab(84).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_FRGN_M02_ASG_YTD_MTH');
		g_balance_value_tab(85).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_FRGN_M02_ASG_YTD_BON');
		g_balance_value_tab(86).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_FRGN_M03_ASG_YTD_MTH');
		g_balance_value_tab(87).defined_balance_id := defined_balance_id('NON_TAXABLE_EARN_FRGN_M03_ASG_YTD_BON');
		--
		-- Bug 9079450
		g_balance_value_tab(88).defined_balance_id := defined_balance_id('EARN_FOR_ER_SMB_EXEM_ASG_YTD_MTH');
		g_balance_value_tab(89).defined_balance_id := defined_balance_id('EARN_FOR_ER_SMB_EXEM_ASG_YTD_BON');
		--
		------------------------------------------------------------------------
		-- Element Type ID and Input Value ID
		------------------------------------------------------------------------
		g_tax		:= element('TAX');
		g_itax_adj	:= element('ITAX_ADJ');
		g_rtax_adj	:= element('RTAX_ADJ');
		g_stax_adj	:= element('STAX_ADJ');
		------------------------------------------------------------------------
		-- User Entity ID
		------------------------------------------------------------------------
		-- Load all Extract-type db items.
		------------------------------------------------------------------------
		select
			distinct
			u.user_entity_id,
			u.user_entity_name
		bulk collect into
			l_user_entity_id_tbl,
			l_user_entity_name_tbl
		from	ff_user_entities		u,
			pay_report_format_items_f	i
		where	i.report_type = 'YEA'
		and	i.report_qualifier = 'KR'
		and	u.user_entity_id = i.user_entity_id;
		--
		g_user_entity_id.non_resident_flag		:= user_entity_id('X_YEA_NON_RESIDENT_FLAG');
                g_user_entity_id.foreign_residency_flag		:= user_entity_id('X_YEA_FOREIGN_RESIDENCY_FLAG'); -- Bug 6615356
		g_user_entity_id.fw_fixed_tax_rate		:= user_entity_id('X_FW_FIX_TAX_RATE_ELIGIBILITY');  -- 3546993
		g_user_entity_id.nationality			:= user_entity_id('X_YEA_NATIONALITY');  -- Bug 7595082
		g_user_entity_id.cur_taxable_mth		:= user_entity_id('X_YEA_CUR_TAXABLE_MTH');
		g_user_entity_id.cur_taxable_bon		:= user_entity_id('X_YEA_CUR_TAXABLE_BON');
		g_user_entity_id.cur_sp_irreg_bonus		:= user_entity_id('X_YEA_CUR_SP_IRREG_BONUS');
		g_user_entity_id.cur_taxable			:= user_entity_id('X_YEA_CUR_TAXABLE');
		g_user_entity_id.cur_non_taxable_ovt		:= user_entity_id('X_YEA_CUR_NON_TAXABLE_OVT');	-- Bug 8644512
		g_user_entity_id.cur_fw_income_exem		:= user_entity_id('X_YEA_CUR_FW_INCOME_EXEM');	-- Bug 8644512
		g_user_entity_id.prev_taxable_mth		:= user_entity_id('X_YEA_PREV_TAXABLE_MTH');
		g_user_entity_id.prev_taxable_bon		:= user_entity_id('X_YEA_PREV_TAXABLE_BON');
		g_user_entity_id.prev_sp_irreg_bonus		:= user_entity_id('X_YEA_PREV_SP_IRREG_BONUS');
                g_user_entity_id.prev_foreign_wrkr_inc_exem     := user_entity_id('X_YEA_PREV_FOREIGN_WRKR_INC_EXEM');  -- Bug 8341054
		g_user_entity_id.prev_stck_pur_opt_exec_earn    := user_entity_id('X_YEA_PREV_STCK_PUR_OPT_EXEC_EARN');	-- Bug 6024432
		g_user_entity_id.prev_taxable			:= user_entity_id('X_YEA_PREV_TAXABLE');
		g_user_entity_id.taxable_mth			:= user_entity_id('X_YEA_TAXABLE_MTH');
		g_user_entity_id.taxable_bon			:= user_entity_id('X_YEA_TAXABLE_BON');
		g_user_entity_id.sp_irreg_bonus			:= user_entity_id('X_YEA_SP_IRREG_BONUS');
		-- Bug 6012258
		g_user_entity_id.cur_stck_pur_opt_exec_earn	:= user_entity_id('X_YEA_STOCK_PUR_OPT_EXEC_EARN');
		g_user_entity_id.research_payment		:= user_entity_id('X_YEA_RESEARCH_PAYMENT');
		--
		g_user_entity_id.stck_pur_opt_exec_earn		:= user_entity_id('X_YEA_TOT_STCK_PUR_OPT_EXEC_EARN'); -- Bug 6024432
		g_user_entity_id.taxable			:= user_entity_id('X_YEA_TAXABLE');
		g_user_entity_id.taxable1			:= user_entity_id('X_YEA_TAXABLE1'); --Bug 7615517
		g_user_entity_id.non_taxable_ovs		:= user_entity_id('X_YEA_NON_TAXABLE_OVS');
		g_user_entity_id.non_taxable_ovt		:= user_entity_id('X_YEA_NON_TAXABLE_OVT');
		g_user_entity_id.non_taxable_oth		:= user_entity_id('X_YEA_NON_TAXABLE_OTH');
		g_user_entity_id.non_taxable			:= user_entity_id('X_YEA_NON_TAXABLE');
		g_user_entity_id.foreign_worker_income_exem	:= user_entity_id('X_YEA_FOREIGN_WORKER_INCOME_EXEM');  -- 3546993
		g_user_entity_id.basic_income_exem		:= user_entity_id('X_YEA_BASIC_INCOME_EXEM');
		g_user_entity_id.taxable_income			:= user_entity_id('X_YEA_TAXABLE_INCOME');
		g_user_entity_id.ee_tax_exem			:= user_entity_id('X_YEA_EE_TAX_EXEM');
		g_user_entity_id.dpnt_spouse_flag		:= user_entity_id('X_YEA_DPNT_SPOUSE_FLAG');
		g_user_entity_id.dpnt_spouse_tax_exem		:= user_entity_id('X_YEA_DPNT_SPOUSE_TAX_EXEM');
		g_user_entity_id.num_of_aged_dpnts		:= user_entity_id('X_YEA_NUM_OF_AGED_DPNTS');
		g_user_entity_id.num_of_adult_dpnts		:= user_entity_id('X_YEA_NUM_OF_ADULT_DPNTS');
		g_user_entity_id.num_of_underaged_dpnts		:= user_entity_id('X_YEA_NUM_OF_UNDERAGED_DPNTS');
		g_user_entity_id.num_of_dpnts			:= user_entity_id('X_YEA_NUM_OF_DPNTS');
		g_user_entity_id.dpnt_tax_exem			:= user_entity_id('X_YEA_DPNT_TAX_EXEM');
		g_user_entity_id.num_of_ageds			:= user_entity_id('X_YEA_NUM_OF_AGEDS');
		-- Bug 3172960, 3637372
		g_user_entity_id.num_of_super_ageds		:= user_entity_id('X_YEA_NUM_OF_SUPER_AGEDS');
		-- Bug 6705170
                g_user_entity_id.num_of_new_born_adopted	:= user_entity_id('X_YEA_NUM_OF_NEW_BORN_ADOPTED');
                g_user_entity_id.new_born_adopted_tax_exem	:= user_entity_id('X_YEA_NEW_BORN_ADOPTED_TAX_EXEM');
		--
		-- Bug 6784288
		g_user_entity_id.num_of_addtl_child		:= user_entity_id('X_YEA_NUM_OF_ADDTL_CHILD');
		--
		g_user_entity_id.aged_tax_exem			:= user_entity_id('X_YEA_AGED_TAX_EXEM');
		g_user_entity_id.num_of_disableds		:= user_entity_id('X_YEA_NUM_OF_DISABLEDS');
		g_user_entity_id.disabled_tax_exem		:= user_entity_id('X_YEA_DISABLED_TAX_EXEM');
		g_user_entity_id.female_ee_flag			:= user_entity_id('X_YEA_FEMALE_EE_FLAG');
		g_user_entity_id.female_ee_tax_exem		:= user_entity_id('X_YEA_FEMALE_EE_TAX_EXEM');
		g_user_entity_id.num_of_children		:= user_entity_id('X_YEA_NUM_OF_CHILDREN');
		g_user_entity_id.child_tax_exem			:= user_entity_id('X_YEA_CHILD_TAX_EXEM');
		-- Bug 5756690
		g_user_entity_id.addl_child_tax_exem		:= user_entity_id('X_YEA_ADDITIONAL_CHILD_TAX_EXEM');
		g_user_entity_id.supp_tax_exem			:= user_entity_id('X_YEA_SUPP_TAX_EXEM');
		g_user_entity_id.hi_prem			:= user_entity_id('X_YEA_HI_PREM');
		g_user_entity_id.hi_prem_tax_exem		:= user_entity_id('X_YEA_HI_PREM_TAX_EXEM');
		-- Bug 7164589
		g_user_entity_id.long_term_ins_prem	:= user_entity_id('X_YEA_LTCI_PREM');
		g_user_entity_id.long_term_ins_prem_tax_exem := user_entity_id('X_YEA_LTCI_PREM_TAX_EXEM');
		-- End of Bug 7164589
		g_user_entity_id.ei_prem			:= user_entity_id('X_YEA_EI_PREM');
		g_user_entity_id.ei_prem_tax_exem		:= user_entity_id('X_YEA_EI_PREM_TAX_EXEM');
		g_user_entity_id.pers_ins_name			:= user_entity_id('X_YEA_PERS_INS_NAME');
		g_user_entity_id.pers_ins_prem			:= user_entity_id('X_YEA_PERS_INS_PREM');
		g_user_entity_id.pers_ins_prem_tax_exem		:= user_entity_id('X_YEA_PERS_INS_PREM_TAX_EXEM');
		g_user_entity_id.disabled_ins_prem		:= user_entity_id('X_YEA_DISABLED_INS_PREM');
		g_user_entity_id.disabled_ins_prem_tax_exem	:= user_entity_id('X_YEA_DISABLED_INS_PREM_TAX_EXEM');
		g_user_entity_id.ins_prem_tax_exem		:= user_entity_id('X_YEA_INS_PREM_TAX_EXEM');
		g_user_entity_id.med_exp			:= user_entity_id('X_YEA_MED_EXP');
		g_user_entity_id.med_exp_disabled		:= user_entity_id('X_YEA_MED_EXP_DISABLED');
		g_user_entity_id.med_exp_aged			:= user_entity_id('X_YEA_MED_EXP_AGED');
		-- Bug 3172960, 3637372
		g_user_entity_id.med_exp_emp			:= user_entity_id('X_YEA_MED_EXP_EMP');
		g_user_entity_id.max_med_exp_tax_exem		:= user_entity_id('X_YEA_MAX_MED_EXP_TAX_EXEM');
		g_user_entity_id.med_exp_tax_exem		:= user_entity_id('X_YEA_MED_EXP_TAX_EXEM');
		g_user_entity_id.ee_educ_exp			:= user_entity_id('X_YEA_EE_EDUC_EXP');
		g_user_entity_id.spouse_educ_exp		:= user_entity_id('X_YEA_SPOUSE_EDUC_EXP');
		g_user_entity_id.disabled_educ_exp		:= user_entity_id('X_YEA_DISABLED_EDUC_EXP');
		g_user_entity_id.dpnt_educ_exp			:= user_entity_id('X_YEA_DPNT_EDUC_EXP');
		g_user_entity_id.educ_exp_tax_exem		:= user_entity_id('X_YEA_EDUC_EXP_TAX_EXEM');
		g_user_entity_id.housing_saving_type		:= user_entity_id('X_YEA_HOUSING_SAVING_TYPE');
		g_user_entity_id.housing_saving			:= user_entity_id('X_YEA_HOUSING_SAVING');
		g_user_entity_id.housing_purchase_date		:= user_entity_id('X_YEA_HOUSING_PURCHASE_DATE');
		g_user_entity_id.housing_loan_date		:= user_entity_id('X_YEA_HOUSING_LOAN_DATE');
		g_user_entity_id.housing_loan_repay		:= user_entity_id('X_YEA_HOUSING_LOAN_REPAY');
		g_user_entity_id.lt_housing_loan_date		:= user_entity_id('X_YEA_LT_HOUSING_LOAN_DATE');
		g_user_entity_id.lt_housing_loan_interest_repay	:= user_entity_id('X_YEA_LT_HOUSING_LOAN_INTEREST_REPAY');
		g_user_entity_id.lt_housing_loan_date_1		:= user_entity_id('X_YEA_LT_HOUSING_LOAN_DATE_1');
		g_user_entity_id.lt_housing_loan_intr_repay_1	:= user_entity_id('X_YEA_LT_HOUSING_LOAN_INTEREST_REPAY_1');
                g_user_entity_id.lt_housing_loan_date_2		:= user_entity_id('X_YEA_LT_HOUSING_LOAN_DATE_2');              -- Bug 8237227
                g_user_entity_id.lt_housing_loan_intr_repay_2	:= user_entity_id('X_YEA_LT_HOUSING_LOAN_INTEREST_REPAY_2');    -- Bug 8237227
		g_user_entity_id.max_housing_exp_tax_exem	:= user_entity_id('X_YEA_MAX_HOUSING_EXP_TAX_EXEM');
		g_user_entity_id.housing_exp_tax_exem		:= user_entity_id('X_YEA_HOUSING_EXP_TAX_EXEM');
		g_user_entity_id.birth_raising_allowance	:= user_entity_id('X_YEA_BIRTH_RAISING_ALLOWANCE'); --Bug 7142620
		g_user_entity_id.cur_birth_raising_allowance	:= user_entity_id('X_YEA_CUR_BIRTH_RAISING_ALLOWANCE'); -- Bug 8644512
		g_user_entity_id.housing_saving_exem		:= user_entity_id('X_YEA_HOUSING_SAVING_EXEM'); --Bug  7142620
		g_user_entity_id.housing_loan_repay_exem	:= user_entity_id('X_YEA_HOUSING_LOAN_REPAY_EXEM'); --Bug  7142620
		g_user_entity_id.lt_housing_loan_intr_exem	:= user_entity_id('X_YEA_LT_HOUSING_LOAN_INTR_EXEM'); --Bug  7142620
		g_user_entity_id.donation1			:= user_entity_id('X_YEA_DONATION1');
		g_user_entity_id.political_donation1		:= user_entity_id('X_YEA_POLITICAL_DONATION1');
		g_user_entity_id.political_donation2		:= user_entity_id('X_YEA_POLITICAL_DONATION2');
		g_user_entity_id.political_donation3		:= user_entity_id('X_YEA_POLITICAL_DONATION3');
		g_user_entity_id.donation1_tax_exem		:= user_entity_id('X_YEA_DONATION1_TAX_EXEM');
		g_user_entity_id.donation2			:= user_entity_id('X_YEA_DONATION2');
                g_user_entity_id.donation3                      := user_entity_id('X_YEA_DONATION3');
		-- Bug 7142612: Public Legal Entity Donation Trust
                g_user_entity_id.donation4                      := user_entity_id('X_YEA_DONATION4');
                g_user_entity_id.religious_donation             := user_entity_id('X_YEA_RELIGIOUS_DONATION');
		-- End of Bug 7142612
		g_user_entity_id.max_donation2_tax_exem		:= user_entity_id('X_YEA_MAX_DONATION2_TAX_EXEM');
		g_user_entity_id.max_donation3_tax_exem		:= user_entity_id('X_YEA_MAX_DONATION3_TAX_EXEM');
		g_user_entity_id.donation2_tax_exem		:= user_entity_id('X_YEA_DONATION2_TAX_EXEM');
		g_user_entity_id.donation3_tax_exem		:= user_entity_id('X_YEA_DONATION3_TAX_EXEM');
		g_user_entity_id.donation_tax_exem		:= user_entity_id('X_YEA_DONATION_TAX_EXEM');
		g_user_entity_id.marriage_exemption             := user_entity_id('X_YEA_MARRIAGE_EXEMPTION');
		g_user_entity_id.funeral_exemption              := user_entity_id('X_YEA_FUNERAL_EXEMPTION');
		g_user_entity_id.relocation_exemption           := user_entity_id('X_YEA_RELOCATION_EXEMPTION');
		g_user_entity_id.marr_fun_relo_exemption        := user_entity_id('X_YEA_MARR_FUN_RELO_EXEMPTION');
		g_user_entity_id.sp_tax_exem			:= user_entity_id('X_YEA_SP_TAX_EXEM');
		g_user_entity_id.std_sp_tax_exem		:= user_entity_id('X_YEA_STD_SP_TAX_EXEM');
		g_user_entity_id.np_prem			:= user_entity_id('X_YEA_NP_PREM');
		g_user_entity_id.np_prem_tax_exem		:= user_entity_id('X_YEA_NP_PREM_TAX_EXEM');
		-- Bug 6024342
		g_user_entity_id.pen_prem			:= user_entity_id('X_YEA_PEN_PREM');
		--
		g_user_entity_id.taxable_income2		:= user_entity_id('X_YEA_TAXABLE_INCOME2');
		g_user_entity_id.pers_pension_prem		:= user_entity_id('X_YEA_PERS_PENSION_PREM');
		g_user_entity_id.pers_pension_prem_tax_exem	:= user_entity_id('X_YEA_PERS_PENSION_PREM_TAX_EXEM');
		-- Bug 4750653
		g_user_entity_id.corp_pension_prem		:= user_entity_id('X_YEA_CORP_PENSION_PREM');
		g_user_entity_id.corp_pension_prem_tax_exem	:= user_entity_id('X_YEA_CORP_PENSION_PREM_TAX_EXEM');
		-- end of Bug 4750653
		g_user_entity_id.pers_pension_saving		:= user_entity_id('X_YEA_PERS_PENSION_SAVING');
		g_user_entity_id.pers_pension_saving_tax_exem	:= user_entity_id('X_YEA_PERS_PENSION_SAVING_TAX_EXEM');
		g_user_entity_id.invest_partner_fin1		:= user_entity_id('X_YEA_INVEST_PARTNER_FIN1');
		g_user_entity_id.invest_partner_fin2		:= user_entity_id('X_YEA_INVEST_PARTNER_FIN2');
                g_user_entity_id.invest_partner_fin3		:= user_entity_id('X_YEA_INVEST_PARTNER_FIN3');     -- Bug 8237227
		g_user_entity_id.invest_partner_fin_tax_exem	:= user_entity_id('X_YEA_INVEST_PARTNER_FIN_TAX_EXEM');
		-- Bug 6895093
		g_user_entity_id.small_bus_install		:= user_entity_id('X_YEA_SMALL_BUS_INSTALL');
		g_user_entity_id.small_bus_install_exem		:= user_entity_id('X_YEA_SMALL_BUS_INSTALL_EXEM');
		-- End of Bug 6895093
		g_user_entity_id.credit_card_exp		:= user_entity_id('X_YEA_CREDIT_CARD_EXP');
		g_user_entity_id.credit_card_exp_tax_exem	:= user_entity_id('X_YEA_CREDIT_CARD_EXP_TAX_EXEM');
		g_user_entity_id.emp_stk_own_contri		:= user_entity_id('X_YEA_EMP_STK_OWN_CONTRI');
		g_user_entity_id.emp_stk_own_contri_tax_exem	:= user_entity_id('X_YEA_EMP_STK_OWN_CONTRI_TAX_EXEM');
		g_user_entity_id.taxation_base			:= user_entity_id('X_YEA_TAXATION_BASE');
		g_user_entity_id.calc_tax			:= user_entity_id('X_YEA_CALC_TAX');
		g_user_entity_id.basic_tax_break		:= user_entity_id('X_YEA_BASIC_TAX_BREAK');
		g_user_entity_id.housing_loan_interest_repay	:= user_entity_id('X_YEA_HOUSING_LOAN_INTEREST_REPAY');
		g_user_entity_id.housing_exp_tax_break		:= user_entity_id('X_YEA_HOUSING_EXP_TAX_BREAK');
		g_user_entity_id.stock_saving			:= user_entity_id('X_YEA_STOCK_SAVING');
		g_user_entity_id.stock_saving_tax_break		:= user_entity_id('X_YEA_STOCK_SAVING_TAX_BREAK');
		g_user_entity_id.lt_stock_saving1		:= user_entity_id('X_YEA_LT_STOCK_SAVING1');
		g_user_entity_id.lt_stock_saving2		:= user_entity_id('X_YEA_LT_STOCK_SAVING2');
		g_user_entity_id.lt_stock_saving_tax_break	:= user_entity_id('X_YEA_LT_STOCK_SAVING_TAX_BREAK');
		g_user_entity_id.ovstb_tax_paid_date		:= user_entity_id('X_YEA_OVSTB_TAX_PAID_DATE');
		g_user_entity_id.ovstb_territory_code		:= user_entity_id('X_YEA_OVSTB_TERRITORY_CODE');
		g_user_entity_id.ovstb_currency_code		:= user_entity_id('X_YEA_OVSTB_CURRENCY_CODE');
		g_user_entity_id.ovstb_taxable			:= user_entity_id('X_YEA_OVSTB_TAXABLE');
		g_user_entity_id.ovstb_taxable_subj_tax_break	:= user_entity_id('X_YEA_OVSTB_TAXABLE_SUBJ_TAX_BREAK');
		g_user_entity_id.ovstb_tax_break_rate		:= user_entity_id('X_YEA_OVSTB_TAX_BREAK_RATE');
		g_user_entity_id.ovstb_tax_foreign_currency	:= user_entity_id('X_YEA_OVSTB_TAX_FOREIGN_CURRENCY');
		g_user_entity_id.ovstb_tax			:= user_entity_id('X_YEA_OVSTB_TAX');
		g_user_entity_id.ovstb_application_date		:= user_entity_id('X_YEA_OVSTB_APPLICATION_DATE');
		g_user_entity_id.ovstb_submission_date		:= user_entity_id('X_YEA_OVSTB_SUBMISSION_DATE');
		g_user_entity_id.ovs_tax_break			:= user_entity_id('X_YEA_OVS_TAX_BREAK');
		g_user_entity_id.total_tax_break		:= user_entity_id('X_YEA_TOTAL_TAX_BREAK');
		g_user_entity_id.fwtb_immigration_purpose	:= user_entity_id('X_YEA_FWTB_IMMIGRATION_PURPOSE');
		g_user_entity_id.fwtb_contract_date		:= user_entity_id('X_YEA_FWTB_CONTRACT_DATE');
		g_user_entity_id.fwtb_expiry_date		:= user_entity_id('X_YEA_FWTB_EXPIRY_DATE');
		g_user_entity_id.fwtb_application_date		:= user_entity_id('X_YEA_FWTB_APPLICATION_DATE');
		g_user_entity_id.fwtb_submission_date		:= user_entity_id('X_YEA_FWTB_SUBMISSION_DATE');
		g_user_entity_id.foreign_worker_tax_break1	:= user_entity_id('X_YEA_FOREIGN_WORKER_TAX_BREAK1');
		g_user_entity_id.foreign_worker_tax_break2	:= user_entity_id('X_YEA_FOREIGN_WORKER_TAX_BREAK2');
		g_user_entity_id.foreign_worker_tax_break	:= user_entity_id('X_YEA_FOREIGN_WORKER_TAX_BREAK');
		g_user_entity_id.annual_itax			:= user_entity_id('X_YEA_ANNUAL_ITAX');
		g_user_entity_id.annual_rtax			:= user_entity_id('X_YEA_ANNUAL_RTAX');
		g_user_entity_id.annual_stax			:= user_entity_id('X_YEA_ANNUAL_STAX');
		g_user_entity_id.prev_itax			:= user_entity_id('X_YEA_PREV_ITAX');
		g_user_entity_id.prev_rtax			:= user_entity_id('X_YEA_PREV_RTAX');
		g_user_entity_id.prev_stax			:= user_entity_id('X_YEA_PREV_STAX');
		g_user_entity_id.cur_itax			:= user_entity_id('X_YEA_CUR_ITAX');
		g_user_entity_id.cur_rtax			:= user_entity_id('X_YEA_CUR_RTAX');
		g_user_entity_id.cur_stax			:= user_entity_id('X_YEA_CUR_STAX');
		g_user_entity_id.itax_adj			:= user_entity_id('X_YEA_ITAX_ADJ');
		g_user_entity_id.rtax_adj			:= user_entity_id('X_YEA_RTAX_ADJ');
		g_user_entity_id.stax_adj			:= user_entity_id('X_YEA_STAX_ADJ');
		-- Bug 3966549
		g_user_entity_id.don_tax_break2004		:= user_entity_id('X_YEA_DONATION_TAX_BREAK') ;
		-- End of 3966549
                g_user_entity_id.cash_receipt_expense           := user_entity_id('X_YEA_CASH_RECEIPT_EXPENSE');  -- 4738717
		-- Bug 6630135
		g_user_entity_id.tot_med_exp_cards		:= user_entity_id('X_YEA_TOT_MED_EXP_CARDS') ;
		g_user_entity_id.med_exp_paid_not_inc_med_exem	:= user_entity_id('X_YEA_MED_EXP_PAID_NOT_INC_MED_EXEM') ;
		-- End of 6630135
                --Bug 6716401
		g_user_entity_id.double_exem_amt		:= user_entity_id('X_YEA_DOUBLE_EXEM_AMT') ;
                --End 6716401
                -- Bug 7361372
                g_user_entity_id.tax_grp_bus_reg_num		:= user_entity_id('X_YEA_TAX_GRP_BUS_REG_NUM');
                g_user_entity_id.tax_grp_name			:= user_entity_id('X_YEA_TAX_GRP_NAME');
                g_user_entity_id.tax_grp_taxable_mth		:= user_entity_id('X_YEA_TAX_GRP_TAXABLE_MTH');
                g_user_entity_id.tax_grp_taxable_bon		:= user_entity_id('X_YEA_TAX_GRP_TAXABLE_BON');
                g_user_entity_id.tax_grp_sp_irreg_bonus		:= user_entity_id('X_YEA_TAX_GRP_SP_IRREG_BONUS');
                g_user_entity_id.tax_grp_stck_pur_opt_exec_earn	:= user_entity_id('X_YEA_TAX_GRP_STCK_PUR_OPT_EXEC_EARN');
                g_user_entity_id.tax_grp_itax			:= user_entity_id('X_YEA_TAX_GRP_ITAX');
                g_user_entity_id.tax_grp_rtax			:= user_entity_id('X_YEA_TAX_GRP_RTAX');
                g_user_entity_id.tax_grp_stax			:= user_entity_id('X_YEA_TAX_GRP_STAX');
                g_user_entity_id.tax_grp_taxable		:= user_entity_id('X_YEA_TAX_GRP_TAXABLE');
                g_user_entity_id.tax_grp_post_tax_deduc         := user_entity_id('X_YEA_TAX_GRP_POST_TAX_DEDUC');
                -- End of Bug 7361372
		g_user_entity_id.non_taxable_ovs_frgn		:= user_entity_id('X_YEA_NON_TAXABLE_OVS_FRGN'); -- Bug 7439803
		-- Bug 7508706
		g_user_entity_id.tax_grp_taxable_mth_ne		:= user_entity_id('X_YEA_TAX_GRP_TAXABLE_MTH_NE');
                g_user_entity_id.tax_grp_taxable_bon_ne		:= user_entity_id('X_YEA_TAX_GRP_TAXABLE_BON_NE');
                g_user_entity_id.tax_grp_sp_irreg_bonus_ne	:= user_entity_id('X_YEA_TAX_GRP_SP_IRREG_BONUS_NE');
                g_user_entity_id.tax_grp_stck_pur_ne		:= user_entity_id('X_YEA_TAX_GRP_STCK_PUR_OPT_EXEC_EARN_NE');
                g_user_entity_id.tax_grp_taxable_ne		:= user_entity_id('X_YEA_TAX_GRP_TAXABLE_NE');
		-- End of Bug 7508706
		-- Bug 7615517
		g_user_entity_id.company_related_exp		:= user_entity_id('X_YEA_COMPANY_RELATED_EXPENSE');
		g_user_entity_id.long_term_stck_fund_1year  	:= user_entity_id('X_YEA_LONG_TERM_STOCK_FUND_1YEAR');
		g_user_entity_id.long_term_stck_fund_2year  	:= user_entity_id('X_YEA_LONG_TERM_STOCK_FUND_2YEAR');
		g_user_entity_id.long_term_stck_fund_3year  	:= user_entity_id('X_YEA_LONG_TERM_STOCK_FUND_3YEAR');
		g_user_entity_id.long_term_stck_fund_tax_exem  	:= user_entity_id('X_YEA_LONG_TERM_STOCK_FUND_TAX_EXEM');
		-- End of Bug 7615517
		-- Bug 8644512
		g_user_entity_id.esop_withd_earn		:= user_entity_id('X_YEA_ESOP_WITHD_EARN');
		g_user_entity_id.cur_esop_withd_earn		:= user_entity_id('X_YEA_CUR_ESOP_WITHD_EARN');
		g_user_entity_id.prev_esop_withd_earn		:= user_entity_id('X_YEA_PREV_ESOP_WITHD_EARN');
		g_user_entity_id.tax_grp_wkpd_from		:= user_entity_id('X_YEA_TAX_GRP_WKPD_FROM');
		g_user_entity_id.tax_grp_wkpd_to		:= user_entity_id('X_YEA_TAX_GRP_WKPD_TO');
		g_user_entity_id.tax_grp_tax_brk_pd_from	:= user_entity_id('X_YEA_TAX_GRP_TAX_BRK_PD_FROM');
		g_user_entity_id.tax_grp_tax_brk_pd_to		:= user_entity_id('X_YEA_TAX_GRP_TAX_BRK_PD_TO');
		g_user_entity_id.tax_grp_esop_withd_earn	:= user_entity_id('X_YEA_TAX_GRP_ESOP_WITHD_EARN');
		g_user_entity_id.tax_grp_esop_withd_earn_ne	:= user_entity_id('X_YEA_TAX_GRP_ESOP_WITHD_EARN_NE');
		g_user_entity_id.tax_grp_non_taxable_ovt	:= user_entity_id('X_YEA_TAX_GRP_NON_TAXABLE_OVT');
		g_user_entity_id.tax_grp_bir_raising_allw	:= user_entity_id('X_YEA_TAX_GRP_BIR_RAISING_ALLW');
		g_user_entity_id.tax_grp_fw_income_exem		:= user_entity_id('X_YEA_TAX_GRP_FW_INCOME_EXEM');
		--
		g_user_entity_id.cur_ntax_G01			:= user_entity_id('X_YEA_CUR_NTAX_G01');
		g_user_entity_id.cur_ntax_H01			:= user_entity_id('X_YEA_CUR_NTAX_H01');
		g_user_entity_id.cur_ntax_H05			:= user_entity_id('X_YEA_CUR_NTAX_H05');
		g_user_entity_id.cur_ntax_H06			:= user_entity_id('X_YEA_CUR_NTAX_H06');
		g_user_entity_id.cur_ntax_H07			:= user_entity_id('X_YEA_CUR_NTAX_H07');
		g_user_entity_id.cur_ntax_H08			:= user_entity_id('X_YEA_CUR_NTAX_H08');
		g_user_entity_id.cur_ntax_H09			:= user_entity_id('X_YEA_CUR_NTAX_H09');
		g_user_entity_id.cur_ntax_H10			:= user_entity_id('X_YEA_CUR_NTAX_H10');
		g_user_entity_id.cur_ntax_H11			:= user_entity_id('X_YEA_CUR_NTAX_H11');
		g_user_entity_id.cur_ntax_H12			:= user_entity_id('X_YEA_CUR_NTAX_H12');
		g_user_entity_id.cur_ntax_H13			:= user_entity_id('X_YEA_CUR_NTAX_H13');
		g_user_entity_id.cur_ntax_I01			:= user_entity_id('X_YEA_CUR_NTAX_I01');
		g_user_entity_id.cur_ntax_K01			:= user_entity_id('X_YEA_CUR_NTAX_K01');
		g_user_entity_id.cur_ntax_M01			:= user_entity_id('X_YEA_CUR_NTAX_M01');
		g_user_entity_id.cur_ntax_M02			:= user_entity_id('X_YEA_CUR_NTAX_M02');
		g_user_entity_id.cur_ntax_M03			:= user_entity_id('X_YEA_CUR_NTAX_M03');
		g_user_entity_id.cur_ntax_S01			:= user_entity_id('X_YEA_CUR_NTAX_S01');
		g_user_entity_id.cur_ntax_T01			:= user_entity_id('X_YEA_CUR_NTAX_T01');
		g_user_entity_id.cur_ntax_Y01			:= user_entity_id('X_YEA_CUR_NTAX_Y01');
		g_user_entity_id.cur_ntax_Y02			:= user_entity_id('X_YEA_CUR_NTAX_Y02');
		g_user_entity_id.cur_ntax_Y03			:= user_entity_id('X_YEA_CUR_NTAX_Y03');
		g_user_entity_id.cur_ntax_Y20			:= user_entity_id('X_YEA_CUR_NTAX_Y20');
		g_user_entity_id.cur_ntax_Z01			:= user_entity_id('X_YEA_CUR_NTAX_Z01');
		--
		g_user_entity_id.prev_ntax_G01			:= user_entity_id('X_YEA_PREV_NTAX_G01');
		g_user_entity_id.prev_ntax_H01			:= user_entity_id('X_YEA_PREV_NTAX_H01');
		g_user_entity_id.prev_ntax_H05			:= user_entity_id('X_YEA_PREV_NTAX_H05');
		g_user_entity_id.prev_ntax_H06			:= user_entity_id('X_YEA_PREV_NTAX_H06');
		g_user_entity_id.prev_ntax_H07			:= user_entity_id('X_YEA_PREV_NTAX_H07');
		g_user_entity_id.prev_ntax_H08			:= user_entity_id('X_YEA_PREV_NTAX_H08');
		g_user_entity_id.prev_ntax_H09			:= user_entity_id('X_YEA_PREV_NTAX_H09');
		g_user_entity_id.prev_ntax_H10			:= user_entity_id('X_YEA_PREV_NTAX_H10');
		g_user_entity_id.prev_ntax_H11			:= user_entity_id('X_YEA_PREV_NTAX_H11');
		g_user_entity_id.prev_ntax_H12			:= user_entity_id('X_YEA_PREV_NTAX_H12');
		g_user_entity_id.prev_ntax_H13			:= user_entity_id('X_YEA_PREV_NTAX_H13');
		g_user_entity_id.prev_ntax_I01			:= user_entity_id('X_YEA_PREV_NTAX_I01');
		g_user_entity_id.prev_ntax_K01			:= user_entity_id('X_YEA_PREV_NTAX_K01');
		g_user_entity_id.prev_ntax_M01			:= user_entity_id('X_YEA_PREV_NTAX_M01');
		g_user_entity_id.prev_ntax_M02			:= user_entity_id('X_YEA_PREV_NTAX_M02');
		g_user_entity_id.prev_ntax_M03			:= user_entity_id('X_YEA_PREV_NTAX_M03');
		g_user_entity_id.prev_ntax_S01			:= user_entity_id('X_YEA_PREV_NTAX_S01');
		g_user_entity_id.prev_ntax_T01			:= user_entity_id('X_YEA_PREV_NTAX_T01');
		g_user_entity_id.prev_ntax_Y01			:= user_entity_id('X_YEA_PREV_NTAX_Y01');
		g_user_entity_id.prev_ntax_Y02			:= user_entity_id('X_YEA_PREV_NTAX_Y02');
		g_user_entity_id.prev_ntax_Y03			:= user_entity_id('X_YEA_PREV_NTAX_Y03');
		g_user_entity_id.prev_ntax_Y20			:= user_entity_id('X_YEA_PREV_NTAX_Y20');
		g_user_entity_id.prev_ntax_Z01			:= user_entity_id('X_YEA_PREV_NTAX_Z01');
		--
		g_user_entity_id.tax_grp_ntax_G01		:= user_entity_id('X_YEA_TAX_GRP_NTAX_G01');
		g_user_entity_id.tax_grp_ntax_H01		:= user_entity_id('X_YEA_TAX_GRP_NTAX_H01');
		g_user_entity_id.tax_grp_ntax_H05		:= user_entity_id('X_YEA_TAX_GRP_NTAX_H05');
		g_user_entity_id.tax_grp_ntax_H06		:= user_entity_id('X_YEA_TAX_GRP_NTAX_H06');
		g_user_entity_id.tax_grp_ntax_H07		:= user_entity_id('X_YEA_TAX_GRP_NTAX_H07');
		g_user_entity_id.tax_grp_ntax_H08		:= user_entity_id('X_YEA_TAX_GRP_NTAX_H08');
		g_user_entity_id.tax_grp_ntax_H09		:= user_entity_id('X_YEA_TAX_GRP_NTAX_H09');
		g_user_entity_id.tax_grp_ntax_H10		:= user_entity_id('X_YEA_TAX_GRP_NTAX_H10');
		g_user_entity_id.tax_grp_ntax_H11		:= user_entity_id('X_YEA_TAX_GRP_NTAX_H11');
		g_user_entity_id.tax_grp_ntax_H12		:= user_entity_id('X_YEA_TAX_GRP_NTAX_H12');
		g_user_entity_id.tax_grp_ntax_H13		:= user_entity_id('X_YEA_TAX_GRP_NTAX_H13');
		g_user_entity_id.tax_grp_ntax_I01		:= user_entity_id('X_YEA_TAX_GRP_NTAX_I01');
		g_user_entity_id.tax_grp_ntax_K01		:= user_entity_id('X_YEA_TAX_GRP_NTAX_K01');
		g_user_entity_id.tax_grp_ntax_M01		:= user_entity_id('X_YEA_TAX_GRP_NTAX_M01');
		g_user_entity_id.tax_grp_ntax_M02		:= user_entity_id('X_YEA_TAX_GRP_NTAX_M02');
		g_user_entity_id.tax_grp_ntax_M03		:= user_entity_id('X_YEA_TAX_GRP_NTAX_M03');
		g_user_entity_id.tax_grp_ntax_S01		:= user_entity_id('X_YEA_TAX_GRP_NTAX_S01');
		g_user_entity_id.tax_grp_ntax_T01		:= user_entity_id('X_YEA_TAX_GRP_NTAX_T01');
		g_user_entity_id.tax_grp_ntax_Y01		:= user_entity_id('X_YEA_TAX_GRP_NTAX_Y01');
		g_user_entity_id.tax_grp_ntax_Y02		:= user_entity_id('X_YEA_TAX_GRP_NTAX_Y02');
		g_user_entity_id.tax_grp_ntax_Y03		:= user_entity_id('X_YEA_TAX_GRP_NTAX_Y03');
		g_user_entity_id.tax_grp_ntax_Y20		:= user_entity_id('X_YEA_TAX_GRP_NTAX_Y20');
		g_user_entity_id.tax_grp_ntax_Z01		:= user_entity_id('X_YEA_TAX_GRP_NTAX_Z01');
		--
		g_user_entity_id.prev_birth_raising_allowance	:= user_entity_id('X_YEA_PREV_BIRTH_RAISING_ALLOWANCE');
		g_user_entity_id.prev_non_taxable_ovt		:= user_entity_id('X_YEA_PREV_NON_TAXABLE_OVT');
		--
		g_user_entity_id.total_ntax_G01			:= user_entity_id('X_YEA_TOTAL_NTAX_G01');
		g_user_entity_id.total_ntax_H01			:= user_entity_id('X_YEA_TOTAL_NTAX_H01');
		g_user_entity_id.total_ntax_H05			:= user_entity_id('X_YEA_TOTAL_NTAX_H05');
		g_user_entity_id.total_ntax_H06			:= user_entity_id('X_YEA_TOTAL_NTAX_H06');
		g_user_entity_id.total_ntax_H07			:= user_entity_id('X_YEA_TOTAL_NTAX_H07');
		g_user_entity_id.total_ntax_H08			:= user_entity_id('X_YEA_TOTAL_NTAX_H08');
		g_user_entity_id.total_ntax_H09			:= user_entity_id('X_YEA_TOTAL_NTAX_H09');
		g_user_entity_id.total_ntax_H10			:= user_entity_id('X_YEA_TOTAL_NTAX_H10');
		g_user_entity_id.total_ntax_H11			:= user_entity_id('X_YEA_TOTAL_NTAX_H11');
		g_user_entity_id.total_ntax_H12			:= user_entity_id('X_YEA_TOTAL_NTAX_H12');
		g_user_entity_id.total_ntax_H13			:= user_entity_id('X_YEA_TOTAL_NTAX_H13');
		g_user_entity_id.total_ntax_I01			:= user_entity_id('X_YEA_TOTAL_NTAX_I01');
		g_user_entity_id.total_ntax_K01			:= user_entity_id('X_YEA_TOTAL_NTAX_K01');
		g_user_entity_id.total_ntax_M01			:= user_entity_id('X_YEA_TOTAL_NTAX_M01');
		g_user_entity_id.total_ntax_M02			:= user_entity_id('X_YEA_TOTAL_NTAX_M02');
		g_user_entity_id.total_ntax_M03			:= user_entity_id('X_YEA_TOTAL_NTAX_M03');
		g_user_entity_id.total_ntax_S01			:= user_entity_id('X_YEA_TOTAL_NTAX_S01');
		g_user_entity_id.total_ntax_T01			:= user_entity_id('X_YEA_TOTAL_NTAX_T01');
		g_user_entity_id.total_ntax_Y01			:= user_entity_id('X_YEA_TOTAL_NTAX_Y01');
		g_user_entity_id.total_ntax_Y02			:= user_entity_id('X_YEA_TOTAL_NTAX_Y02');
		g_user_entity_id.total_ntax_Y03			:= user_entity_id('X_YEA_TOTAL_NTAX_Y03');
		g_user_entity_id.total_ntax_Y20			:= user_entity_id('X_YEA_TOTAL_NTAX_Y20');
		g_user_entity_id.total_ntax_Z01			:= user_entity_id('X_YEA_TOTAL_NTAX_Z01');
		--
		g_user_entity_id.cur_total_ntax_earn		:= user_entity_id('X_YEA_CUR_TOTAL_NTAX_EARN');
		g_user_entity_id.tax_grp_total_ntax_earn	:= user_entity_id('X_YEA_TAX_GRP_TOTAL_NTAX_EARN');
		--

		--End of Bug 8644512
		--
		-- Bug 8880364
		g_user_entity_id.cur_ntax_frgn_M01		:= user_entity_id('X_YEA_CUR_NTAX_FRGN_M01');
		g_user_entity_id.cur_ntax_frgn_M02		:= user_entity_id('X_YEA_CUR_NTAX_FRGN_M02');
		g_user_entity_id.cur_ntax_frgn_M03		:= user_entity_id('X_YEA_CUR_NTAX_FRGN_M03');
		--
		g_user_entity_id.non_rep_non_taxable		:= user_entity_id('X_YEA_NON_REP_NON_TAXABLE'); 	-- Bug 9079450
		g_user_entity_id.smb_income_exem		:= user_entity_id('X_YEA_SMB_INCOME_EXEM');		-- Bug 9079450
		g_user_entity_id.cur_smb_days_worked 		:= user_entity_id('X_YEA_CUR_SMB_DAYS_WORKED'); 	-- Bug 9079450
		g_user_entity_id.prev_smb_days_worked 		:= user_entity_id('X_YEA_PREV_SMB_DAYS_WORKED');	-- Bug 9079450
		g_user_entity_id.cur_smb_eligible_income	:= user_entity_id('X_YEA_CUR_SMB_ELIGIBLE_INCOME'); 	-- Bug 9079450
		g_user_entity_id.prev_smb_eligible_income	:= user_entity_id('X_YEA_PREV_SMB_ELIGIBLE_INCOME');  	-- Bug 9079450
		g_user_entity_id.emp_join_prev_year		:= user_entity_id('X_YEA_EMP_JOIN_PREV_YEAR');		-- Bug 9079450
		g_user_entity_id.emp_leave_cur_year		:= user_entity_id('X_YEA_EMP_LEAVE_CUR_YEAR'); 		-- Bug 9079450
		g_user_entity_id.smb_eligibility_flag		:= user_entity_id('X_YEA_SMB_ELIGIBILITY_FLAG');	-- Bug 9079450
		--
	end;
end pay_kr_yea_pkg;

/
