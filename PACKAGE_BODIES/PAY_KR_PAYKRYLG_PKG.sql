--------------------------------------------------------
--  DDL for Package Body PAY_KR_PAYKRYLG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_PAYKRYLG_PKG" as
/* $Header: paykrylg.pkb 120.5.12010000.7 2010/01/19 16:54:41 pnethaga ship $ */
--
-- Global Variables
--
type t_defined_balance_id is record(
        taxable_mth                 number,
        taxable_bon                 number,
        sp_irreg_bonus_mth          number,
        sp_irreg_bonus_bon          number,
        stck_pur_opt_exec_earn_mth  number,   -- Bug 6470526
        stck_pur_opt_exec_earn_bon  number,   -- Bug 6470526
        itax_mth                    number,
        itax_bon                    number,
        rtax_mth                    number,
        rtax_bon                    number,
        stax_mth                    number,
        stax_bon                    number,
        non_taxable_ovs_mth         number,
        non_taxable_ovs_bon         number,
        non_taxable_ovt_mth         number,
        non_taxable_ovt_bon         number,
        research_payment_mth        number,    -- Bug 6470526
        research_payment_bon        number,    -- Bug 6470526
        non_taxable_mth             number,
        non_taxable_bon             number,
	non_taxable_ovs_frgn_mth    number,  -- Bug 7439803
	non_taxable_ovs_frgn_bon    number,  -- Bug 7439803
	birth_raise_allow_mth       number,  -- Bug 7439803
	birth_raise_allow_bon       number,  -- Bug 7439803
	ltci_prem_mth		    number,  -- Bug 7439803
	ltci_prem_bon		    number,  -- Bug 7439803
        fw_tax_break_mth            number,    --3546994
        fw_tax_break_bon            number,
	-- Bug 4322981
	np_prem_mth		    number,
	hi_prem_mth		    number,
	ei_prem_mth		    number,
	donation_mth		    number,
	np_prem_bon		    number,
	hi_prem_bon		    number,
	addl_non_tax_mth	    number, -- Bug 5999074
	addl_non_tax_bon	    number,
	ei_prem_bon		    number,
	donation_bon		    number,
	-- End of 4322981
	-- Start of bug 8880364
	esop_with_drawn_mth	    number,
	esop_with_drawn_bon         number,
	rsrch_pay_ntax_H06_mth      number,
	rsrch_pay_ntax_H06_bon      number,
	rsrch_pay_ntax_H07_mth      number,
	rsrch_pay_ntax_H07_bon      number,
	rsrch_pay_ntax_H08_mth      number,
	rsrch_pay_ntax_H08_bon      number,
	rsrch_pay_ntax_H09_mth      number,
	rsrch_pay_ntax_H09_bon      number,
	rsrch_pay_ntax_H10_mth      number,
	rsrch_pay_ntax_H10_bon      number,
	non_tax_earn_H11_mth	  number,
	non_tax_earn_H11_bon	  number,
	non_tax_earn_G01_mth	  number,
	non_tax_earn_G01_bon	  number,
	non_tax_earn_H12_mth	  number,
	non_tax_earn_H12_bon	  number,
	non_tax_earn_H01_mth	  number,
	non_tax_earn_H01_bon	  number,
	non_tax_earn_H13_mth	  number,
	non_tax_earn_H13_bon	  number,
	non_tax_earn_K01_mth	  number,
	non_tax_earn_K01_bon	  number,
	non_tax_earn_S01_mth	  number,
	non_tax_earn_S01_bon	  number,
	non_tax_earn_Y01_bon	  number,
	non_tax_earn_Y01_mth	  number,
	non_tax_earn_Y02_bon	  number,
	non_tax_earn_Y02_mth	  number,
	non_tax_earn_Y03_bon	  number,
	non_tax_earn_Y03_mth	  number,
	non_tax_earn_Y20_bon	  number,
	non_tax_earn_Y20_mth	  number,
	non_tax_earn_Z01_bon	  number,
	non_tax_earn_Z01_mth	  number,
	non_tax_earn_T01_mth	  number,
	non_tax_earn_T01_bon	  number,
	non_tax_earn_H05_mth	  number,
	non_tax_earn_H05_bon	  number,
	non_tax_earn_I01_mth	  number,
	non_tax_earn_I01_bon	  number,
	non_tax_earn_M01_mth      number,
	non_tax_earn_M01_bon      number,
	non_tax_earn_M02_mth      number,
	non_tax_earn_M02_bon      number,
	non_tax_earn_M03_mth      number,
	non_tax_earn_M03_bon      number,
	non_tax_earn_frgn_M01_mth      number,
	non_tax_earn_frgn_M01_bon number,
	non_tax_earn_frgn_M02_mth number,
	non_tax_earn_frgn_M02_bon number,
	non_tax_earn_frgn_M03_mth number,
	non_tax_earn_frgn_M03_bon number


);   --3546994
g_defined_balance_id    t_defined_balance_id;
------------------------------------------------------------------------
procedure data(
        p_assignment_action_id          in number,
        p_taxable                       out nocopy number,
	p_nationality			out nocopy varchar2, -- Bug 7595082
	p_fw_fixed_tax_rate		out nocopy varchar2, -- Bug 7595082
        p_basic_income_exem             out nocopy number,
        p_taxable_income                out nocopy number,
        p_ee_tax_exem                   out nocopy number,
        p_dpnt_spouse_flag              out nocopy varchar2,
        p_dpnt_spouse_tax_exem          out nocopy number,
        p_num_of_underaged_dpnts        out nocopy number,
        p_num_of_aged_dpnts             out nocopy number,
        p_dpnt_tax_exem                 out nocopy number,
        p_num_of_ageds                  out nocopy number,
        p_aged_tax_exem                 out nocopy number,
        p_num_of_disableds              out nocopy number,
        p_disabled_tax_exem             out nocopy number,
        p_female_ee_flag                out nocopy varchar2,
        p_female_ee_tax_exem            out nocopy number,
        p_num_of_children               out nocopy number,
        p_child_tax_exem                out nocopy number,
        p_supp_tax_exem                 out nocopy number,
        p_hi_prem                       out nocopy number,
        p_ei_prem                       out nocopy number,
        p_pers_ins_name                 out nocopy varchar2,
        p_pers_ins_prem                 out nocopy number,
        p_disabled_ins_prem             out nocopy number,
        p_ins_prem_tax_exem             out nocopy number,
        p_med_exp                       out nocopy number,
        p_med_exp_aged                  out nocopy number,
        p_med_exp_disabled              out nocopy number,
        p_max_med_exp_tax_exem          out nocopy number,
        p_med_exp_tax_exem              out nocopy number,
        p_ee_educ_exp                   out nocopy number,
        p_spouse_educ_exp               out nocopy number,
        p_disabled_educ_exp             out nocopy number,
        p_dpnt_educ_exp                 out nocopy number,
        p_educ_exp_tax_exem             out nocopy number,
        p_housing_saving_type_meaning   out nocopy varchar2,
        p_housing_saving                out nocopy number,
        p_housing_purchase_date         out nocopy date,
        p_housing_loan_date             out nocopy date,
        p_housing_loan_repay            out nocopy number,
        p_lt_housing_loan_date          out nocopy date,
        p_lt_housing_loan_int_repay     out nocopy number,
        p_max_housing_exp_tax_exem      out nocopy number,
        p_housing_exp_tax_exem          out nocopy number,
        p_donation1_tax_exem            out nocopy number,
        p_donation2                     out nocopy number,
        p_max_donation2_tax_exem        out nocopy number,
        p_donation2_tax_exem            out nocopy number,
        p_donation_tax_exem             out nocopy number,
        p_sp_tax_exem                   out nocopy number,
        p_std_sp_tax_exem               out nocopy number,
        p_np_prem                       out nocopy number,
        p_np_prem_tax_exem              out nocopy number,
        p_pers_pension_prem_tax         out nocopy number,
        p_pers_pension_saving_tax       out nocopy number,
        p_invest_partner_fin_tax        out nocopy number,
        p_credit_card_exp_tax           out nocopy number,
        p_emp_st_own_plan_cont          out nocopy number,
        p_pers_pension_prem_tax_exem    out nocopy number,
        p_pers_pension_saving_tax_exem  out nocopy number,
        p_invest_partner_fin_tax_exem   out nocopy number,
        p_credit_card_exp_tax_exem      out nocopy number,
        p_emp_st_own_plan_cont_exem     out nocopy number,
        p_taxation_base                 out nocopy number,
        p_calc_tax                      out nocopy number,
        p_basic_tax_break               out nocopy number,
        p_housing_exp_tax_break         out nocopy number,
        p_stock_saving_tax_break        out nocopy number,
        p_ovstb_territory_short_name    out nocopy varchar2,
        p_ovstb_tax_paid_date           out nocopy date,
        p_ovstb_tax_foreign_currency    out nocopy number,
        p_ovstb_tax                     out nocopy number,
        p_ovstb_application_date        out nocopy date,
        p_ovstb_submission_date         out nocopy date,
        p_ovs_tax_break                 out nocopy number,
        p_lt_stock_saving_tax_break     out nocopy number,
        p_total_tax_break               out nocopy number,
        p_fwtb_immigration_purpose      out nocopy varchar2,
        p_fwtb_contract_date            out nocopy date,
        p_fwtb_expiry_date              out nocopy date,
        p_fwtb_application_date         out nocopy date,
        p_fwtb_submission_date          out nocopy date,
        p_foreign_worker_tax_break1     out nocopy number,
        p_foreign_worker_tax_break2     out nocopy number,
        p_annual_itax                   out nocopy number,
        p_annual_rtax                   out nocopy number,
        p_annual_stax                   out nocopy number,
        p_prev_itax                     out nocopy number,
        p_prev_rtax                     out nocopy number,
        p_prev_stax                     out nocopy number,
        p_cur_annual_itax               out nocopy number,
        p_cur_annual_rtax               out nocopy number,
        p_cur_annual_stax               out nocopy number,
        p_cur_itax                      out nocopy number,
        p_cur_rtax                      out nocopy number,
        p_cur_stax                      out nocopy number,
        p_itax_adj                      out nocopy number,
        p_itax_refund                   out nocopy number,
        p_rtax_adj                      out nocopy number,
        p_rtax_refund                   out nocopy number,
        p_stax_adj                      out nocopy number,
        p_stax_refund                   out nocopy number,
        p_effective_date1               out nocopy date,
        p_taxable_mth1                  out nocopy number,
        p_taxable_bon1                  out nocopy number,
        p_sp_irreg_bonus1               out nocopy number,
        p_taxable1                      out nocopy number,
        p_itax1                         out nocopy number,
        p_rtax1                         out nocopy number,
        p_stax1                         out nocopy number,
	-- Bug 4322981
	p_np_dedc1			out nocopy number,
	p_hi_dedc1			out nocopy number,
	p_ei_dedc1			out nocopy number,
	p_donation_dedc1		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs1              out nocopy number,
        p_non_taxable_ovt1              out nocopy number,
        p_non_taxable_oth1              out nocopy number,
        p_effective_date2               out nocopy date,
        p_taxable_mth2                  out nocopy number,
        p_taxable_bon2                  out nocopy number,
        p_sp_irreg_bonus2               out nocopy number,
        p_taxable2                      out nocopy number,
        p_itax2                         out nocopy number,
        p_rtax2                         out nocopy number,
        p_stax2                         out nocopy number,
	-- Bug 4322981
	p_np_dedc2			out nocopy number,
	p_hi_dedc2			out nocopy number,
	p_ei_dedc2			out nocopy number,
	p_donation_dedc2		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs2              out nocopy number,
        p_non_taxable_ovt2              out nocopy number,
        p_non_taxable_oth2              out nocopy number,
        p_effective_date3               out nocopy date,
        p_taxable_mth3                  out nocopy number,
        p_taxable_bon3                  out nocopy number,
        p_sp_irreg_bonus3               out nocopy number,
        p_taxable3                      out nocopy number,
        p_itax3                         out nocopy number,
        p_rtax3                         out nocopy number,
        p_stax3                         out nocopy number,
	-- Bug 4322981
	p_np_dedc3			out nocopy number,
	p_hi_dedc3			out nocopy number,
	p_ei_dedc3			out nocopy number,
	p_donation_dedc3		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs3              out nocopy number,
        p_non_taxable_ovt3              out nocopy number,
        p_non_taxable_oth3              out nocopy number,
        p_effective_date4               out nocopy date,
        p_taxable_mth4                  out nocopy number,
        p_taxable_bon4                  out nocopy number,
        p_sp_irreg_bonus4               out nocopy number,
        p_taxable4                      out nocopy number,
        p_itax4                         out nocopy number,
        p_rtax4                         out nocopy number,
        p_stax4                         out nocopy number,
	-- Bug 4322981
	p_np_dedc4			out nocopy number,
	p_hi_dedc4			out nocopy number,
	p_ei_dedc4			out nocopy number,
	p_donation_dedc4		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs4              out nocopy number,
        p_non_taxable_ovt4              out nocopy number,
        p_non_taxable_oth4              out nocopy number,
        p_effective_date5               out nocopy date,
        p_taxable_mth5                  out nocopy number,
        p_taxable_bon5                  out nocopy number,
        p_sp_irreg_bonus5               out nocopy number,
        p_taxable5                      out nocopy number,
        p_itax5                         out nocopy number,
        p_rtax5                         out nocopy number,
        p_stax5                         out nocopy number,
	-- Bug 4322981
	p_np_dedc5			out nocopy number,
	p_hi_dedc5			out nocopy number,
	p_ei_dedc5			out nocopy number,
	p_donation_dedc5		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs5              out nocopy number,
        p_non_taxable_ovt5              out nocopy number,
        p_non_taxable_oth5              out nocopy number,
        p_effective_date6               out nocopy date,
        p_taxable_mth6                  out nocopy number,
        p_taxable_bon6                  out nocopy number,
        p_sp_irreg_bonus6               out nocopy number,
        p_taxable6                      out nocopy number,
        p_itax6                         out nocopy number,
        p_rtax6                         out nocopy number,
        p_stax6                         out nocopy number,
	-- Bug 4322981
	p_np_dedc6			out nocopy number,
	p_hi_dedc6			out nocopy number,
	p_ei_dedc6			out nocopy number,
	p_donation_dedc6		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs6              out nocopy number,
        p_non_taxable_ovt6              out nocopy number,
        p_non_taxable_oth6              out nocopy number,
        p_effective_date7               out nocopy date,
        p_taxable_mth7                  out nocopy number,
        p_taxable_bon7                  out nocopy number,
        p_sp_irreg_bonus7               out nocopy number,
        p_taxable7                      out nocopy number,
        p_itax7                         out nocopy number,
        p_rtax7                         out nocopy number,
        p_stax7                         out nocopy number,
	-- Bug 4322981
	p_np_dedc7			out nocopy number,
	p_hi_dedc7			out nocopy number,
	p_ei_dedc7			out nocopy number,
	p_donation_dedc7		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs7              out nocopy number,
        p_non_taxable_ovt7              out nocopy number,
        p_non_taxable_oth7              out nocopy number,
        p_effective_date8               out nocopy date,
        p_taxable_mth8                  out nocopy number,
        p_taxable_bon8                  out nocopy number,
        p_sp_irreg_bonus8               out nocopy number,
        p_taxable8                      out nocopy number,
        p_itax8                         out nocopy number,
        p_rtax8                         out nocopy number,
        p_stax8                         out nocopy number,
	-- Bug 4322981
	p_np_dedc8			out nocopy number,
	p_hi_dedc8			out nocopy number,
	p_ei_dedc8			out nocopy number,
	p_donation_dedc8		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs8              out nocopy number,
        p_non_taxable_ovt8              out nocopy number,
        p_non_taxable_oth8              out nocopy number,
        p_effective_date9               out nocopy date,
        p_taxable_mth9                  out nocopy number,
        p_taxable_bon9                  out nocopy number,
        p_sp_irreg_bonus9               out nocopy number,
        p_taxable9                      out nocopy number,
        p_itax9                         out nocopy number,
        p_rtax9                         out nocopy number,
        p_stax9                         out nocopy number,
	-- Bug 4322981
	p_np_dedc9			out nocopy number,
	p_hi_dedc9			out nocopy number,
	p_ei_dedc9			out nocopy number,
	p_donation_dedc9		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs9              out nocopy number,
        p_non_taxable_ovt9              out nocopy number,
        p_non_taxable_oth9              out nocopy number,
        p_effective_date10              out nocopy date,
        p_taxable_mth10                 out nocopy number,
        p_taxable_bon10                 out nocopy number,
        p_sp_irreg_bonus10              out nocopy number,
        p_taxable10                     out nocopy number,
        p_itax10                        out nocopy number,
        p_rtax10                        out nocopy number,
        p_stax10                        out nocopy number,
	-- Bug 4322981
	p_np_dedc10			out nocopy number,
	p_hi_dedc10			out nocopy number,
	p_ei_dedc10			out nocopy number,
	p_donation_dedc10		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs10             out nocopy number,
        p_non_taxable_ovt10             out nocopy number,
        p_non_taxable_oth10             out nocopy number,
        p_effective_date11              out nocopy date,
        p_taxable_mth11                 out nocopy number,
        p_taxable_bon11                 out nocopy number,
        p_sp_irreg_bonus11              out nocopy number,
        p_taxable11                     out nocopy number,
        p_itax11                        out nocopy number,
        p_rtax11                        out nocopy number,
        p_stax11                        out nocopy number,
	-- Bug 4322981
	p_np_dedc11			out nocopy number,
	p_hi_dedc11			out nocopy number,
	p_ei_dedc11			out nocopy number,
	p_donation_dedc11		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs11             out nocopy number,
        p_non_taxable_ovt11             out nocopy number,
        p_non_taxable_oth11             out nocopy number,
        p_effective_date12              out nocopy date,
        p_taxable_mth12                 out nocopy number,
        p_taxable_bon12                 out nocopy number,
        p_sp_irreg_bonus12              out nocopy number,
        p_taxable12                     out nocopy number,
        p_itax12                        out nocopy number,
        p_rtax12                        out nocopy number,
        p_stax12                        out nocopy number,
	-- Bug 4322981
	p_np_dedc12			out nocopy number,
	p_hi_dedc12			out nocopy number,
	p_ei_dedc12			out nocopy number,
	p_donation_dedc12		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs12             out nocopy number,
        p_non_taxable_ovt12             out nocopy number,
        p_non_taxable_oth12             out nocopy number,
        p_taxable_mth13                 out nocopy number,
        p_taxable_bon13                 out nocopy number,
        p_sp_irreg_bonus13              out nocopy number,
        p_taxable13                     out nocopy number,
        p_itax13                        out nocopy number,
        p_rtax13                        out nocopy number,
        p_stax13                        out nocopy number,
	-- Bug 4322981
	p_np_dedc13			out nocopy number,
	p_hi_dedc13			out nocopy number,
	p_ei_dedc13			out nocopy number,
	p_donation_dedc13		out nocopy number,
	-- End of 4322981
        p_non_taxable_ovs13             out nocopy number,
        p_non_taxable_ovt13             out nocopy number,
        p_non_taxable_oth13             out nocopy number,
	--  3546994
        p_dependent_count               out nocopy number,
        p_fw_tax_break1                 out nocopy number,
        p_fw_tax_break2                 out nocopy number,
        p_fw_tax_break3                 out nocopy number,
        p_fw_tax_break4                 out nocopy number,
        p_fw_tax_break5                 out nocopy number,
        p_fw_tax_break6                 out nocopy number,
        p_fw_tax_break7                 out nocopy number,
        p_fw_tax_break8                 out nocopy number,
        p_fw_tax_break9                 out nocopy number,
        p_fw_tax_break10                out nocopy number,
        p_fw_tax_break11                out nocopy number,
        p_fw_tax_break12                out nocopy number,
        p_fw_tax_break13                out nocopy number, -- Bug 7439803
        -- Bug 6470526: 2007 YEA Ledger Statutory Updates
        p_stck_pur_opt_exec_earn1       out nocopy number,
        p_stck_pur_opt_exec_earn2       out nocopy number,
        p_stck_pur_opt_exec_earn3       out nocopy number,
        p_stck_pur_opt_exec_earn4       out nocopy number,
        p_stck_pur_opt_exec_earn5       out nocopy number,
        p_stck_pur_opt_exec_earn6       out nocopy number,
        p_stck_pur_opt_exec_earn7       out nocopy number,
        p_stck_pur_opt_exec_earn8       out nocopy number,
        p_stck_pur_opt_exec_earn9       out nocopy number,
        p_stck_pur_opt_exec_earn10      out nocopy number,
        p_stck_pur_opt_exec_earn11      out nocopy number,
        p_stck_pur_opt_exec_earn12      out nocopy number,
        p_stck_pur_opt_exec_earn13      out nocopy number,
        p_research_payment1             out nocopy number,
        p_research_payment2             out nocopy number,
        p_research_payment3             out nocopy number,
        p_research_payment4             out nocopy number,
        p_research_payment5             out nocopy number,
        p_research_payment6             out nocopy number,
        p_research_payment7             out nocopy number,
        p_research_payment8             out nocopy number,
        p_research_payment9             out nocopy number,
        p_research_payment10            out nocopy number,
        p_research_payment11            out nocopy number,
        p_research_payment12            out nocopy number,
        p_research_payment13            out nocopy number,
        -- End of Bug 6470526
	-- Bug 7439803: 2008 YEA Ledger Statutory Updates
	p_non_taxable_ovs_frgn1		out nocopy number,
	p_non_taxable_ovs_frgn2		out nocopy number,
	p_non_taxable_ovs_frgn3		out nocopy number,
	p_non_taxable_ovs_frgn4		out nocopy number,
	p_non_taxable_ovs_frgn5		out nocopy number,
	p_non_taxable_ovs_frgn6		out nocopy number,
	p_non_taxable_ovs_frgn7		out nocopy number,
	p_non_taxable_ovs_frgn8		out nocopy number,
	p_non_taxable_ovs_frgn9		out nocopy number,
	p_non_taxable_ovs_frgn10	out nocopy number,
	p_non_taxable_ovs_frgn11	out nocopy number,
	p_non_taxable_ovs_frgn12	out nocopy number,
	p_non_taxable_ovs_frgn13	out nocopy number,
	p_birth_raising_allow1		out nocopy number,
	p_birth_raising_allow2		out nocopy number,
	p_birth_raising_allow3		out nocopy number,
	p_birth_raising_allow4		out nocopy number,
	p_birth_raising_allow5		out nocopy number,
	p_birth_raising_allow6		out nocopy number,
	p_birth_raising_allow7		out nocopy number,
	p_birth_raising_allow8		out nocopy number,
	p_birth_raising_allow9		out nocopy number,
	p_birth_raising_allow10		out nocopy number,
	p_birth_raising_allow11		out nocopy number,
	p_birth_raising_allow12		out nocopy number,
	p_birth_raising_allow13		out nocopy number,
	p_fw_income_exem1		out nocopy number,
	p_fw_income_exem2		out nocopy number,
	p_fw_income_exem3		out nocopy number,
	p_fw_income_exem4		out nocopy number,
	p_fw_income_exem5		out nocopy number,
	p_fw_income_exem6		out nocopy number,
	p_fw_income_exem7		out nocopy number,
	p_fw_income_exem8		out nocopy number,
	p_fw_income_exem9		out nocopy number,
	p_fw_income_exem10		out nocopy number,
	p_fw_income_exem11		out nocopy number,
	p_fw_income_exem12		out nocopy number,
	p_fw_income_exem13		out nocopy number,
 	-- End of Bug 7439803
	-- Start of bug 8880364: 2009 YEA Ledger Updates
	p_esop_with_drawn1		out nocopy number,
	p_esop_with_drawn2		out nocopy number,
	p_esop_with_drawn3		out nocopy number,
	p_esop_with_drawn4		out nocopy number,
	p_esop_with_drawn5		out nocopy number,
	p_esop_with_drawn6		out nocopy number,
	p_esop_with_drawn7		out nocopy number,
	p_esop_with_drawn8		out nocopy number,
	p_esop_with_drawn9		out nocopy number,
	p_esop_with_drawn10		out nocopy number,
	p_esop_with_drawn11		out nocopy number,
	p_esop_with_drawn12		out nocopy number,
	p_esop_with_drawn13		out nocopy number,
	p_non_tax_18_earn1		out nocopy number,
	p_non_tax_18_earn2		out nocopy number,
	p_non_tax_18_earn3		out nocopy number,
	p_non_tax_18_earn4		out nocopy number,
	p_non_tax_18_earn5		out nocopy number,
	p_non_tax_18_earn6		out nocopy number,
	p_non_tax_18_earn7		out nocopy number,
	p_non_tax_18_earn8		out nocopy number,
	p_non_tax_18_earn9		out nocopy number,
	p_non_tax_18_earn10		out nocopy number,
	p_non_tax_18_earn11		out nocopy number,
	p_non_tax_18_earn12		out nocopy number,
	p_non_tax_18_earn13		out nocopy number,
	p_non_tax_19_earn1		out nocopy number,
	p_non_tax_19_earn2		out nocopy number,
	p_non_tax_19_earn3		out nocopy number,
	p_non_tax_19_earn4		out nocopy number,
	p_non_tax_19_earn5		out nocopy number,
	p_non_tax_19_earn6		out nocopy number,
	p_non_tax_19_earn7		out nocopy number,
	p_non_tax_19_earn8		out nocopy number,
	p_non_tax_19_earn9		out nocopy number,
	p_non_tax_19_earn10		out nocopy number,
	p_non_tax_19_earn11		out nocopy number,
	p_non_tax_19_earn12		out nocopy number,
	p_non_tax_19_earn13		out nocopy number,
	p_non_tax_20_earn1		out nocopy number,
	p_non_tax_20_earn2		out nocopy number,
	p_non_tax_20_earn3		out nocopy number,
	p_non_tax_20_earn4		out nocopy number,
	p_non_tax_20_earn5		out nocopy number,
	p_non_tax_20_earn6		out nocopy number,
	p_non_tax_20_earn7		out nocopy number,
	p_non_tax_20_earn8		out nocopy number,
	p_non_tax_20_earn9		out nocopy number,
	p_non_tax_20_earn10		out nocopy number,
	p_non_tax_20_earn11		out nocopy number,
	p_non_tax_20_earn12		out nocopy number,
	p_non_tax_20_earn13		out nocopy number,
	p_non_taxable1			out nocopy number,
	p_non_taxable2			out nocopy number,
	p_non_taxable3			out nocopy number,
	p_non_taxable4			out nocopy number,
	p_non_taxable5			out nocopy number,
	p_non_taxable6			out nocopy number,
	p_non_taxable7			out nocopy number,
	p_non_taxable8			out nocopy number,
	p_non_taxable9			out nocopy number,
	p_non_taxable10			out nocopy number,
	p_non_taxable11			out nocopy number,
	p_non_taxable12			out nocopy number,
	p_non_taxable13			out nocopy number

)
------------------------------------------------------------------------
is
        l_yea_info      		pay_kr_yea_pkg.t_yea_info;
        l_month         		number;
        l_dependent_spouse_count 	Number;  --  3546994
	l_bal_adj_assact 		pay_assignment_actions.assignment_action_id%type ; -- Bug 4261844
        --
	-- Bug 4261844: Get the balance adjustment action (sequenced) from the archival (unsequenced) assact
	--		p_assignment_action_id...
	cursor csr_bal_adj_assact is
		select
			pai.locked_action_id	bal_adj_assact
		from
			pay_action_interlocks 	pai,
			pay_assignment_actions 	paa,
			pay_payroll_actions 	ppa
		where
			pai.locking_action_id 		= p_assignment_action_id
			and paa.assignment_action_id 	= pai.locked_action_id
			and paa.action_status 		= 'C'
			and paa.payroll_action_id 	= ppa.payroll_action_id
			and ppa.action_type 		= 'B'
			and pay_kr_ff_functions_pkg.get_legislative_parameter(ppa.payroll_action_id, 'REPORT_TYPE', null)
							= 'YEA' ;
	--
	-- Bug 4261844: ... and use it to get the monthly runs.
        cursor csr_assact(p_bal_adj_assact  pay_assignment_actions.assignment_action_id%type)
	is
                select
                        paa2.assignment_action_id,
                        ppa2.effective_date
                from    pay_payroll_actions     ppa2,
                        pay_assignment_actions  paa2,
                        pay_payroll_actions     ppa,
                        pay_assignment_actions  paa
                where   paa.assignment_action_id = p_bal_adj_assact
                and     ppa.payroll_action_id = paa.payroll_action_id
                and     paa2.assignment_id = paa.assignment_id
                and     paa2.action_sequence < paa.action_sequence
                and     paa2.source_action_id is null
                and     ppa2.payroll_action_id = paa2.payroll_action_id
                and     ( ppa2.action_type in ('I', 'R', 'Q', 'V') or ( ppa2.action_type ='B'  and  nvl(pay_core_utils.get_parameter('REPORT_TYPE',ppa2.legislative_parameters),'XYZ') <> 'YEA'))
                and     trunc(ppa2.effective_date, 'YYYY') = trunc(ppa.effective_date, 'YYYY')
                order by paa2.action_sequence desc;
	-- End of 4261844
        --
	-----------------------------------------------------------------------------------
	-- Bug 7439803: 2008 YEA Ledger Statutory Updates
	function get_globalvalue(p_glbvar in varchar2,p_process_date in date) return number
	-----------------------------------------------------------------------------------
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
	end get_globalvalue;
	------------------------------------------------------------------------
        procedure payment_details(
                p_assact                 in number,
                p_date_paid              in date,
                p_effective_date         in out nocopy date,
                p_taxable_mth            in out nocopy number,
                p_taxable_bon            in out nocopy number,
                p_sp_irreg_bonus         in out nocopy number,
                p_stck_pur_opt_exec_earn in out nocopy number,  -- Bug 6470526
		p_esop_with_drawn	 in out nocopy number,  -- Bug 8880364
                p_taxable                in out nocopy number,
                p_itax                   in out nocopy number,
                p_rtax                   in out nocopy number,
                p_stax                   in out nocopy number,
		-- Bug 4322981
		p_np_dedc		 in out nocopy number,
		p_hi_dedc		 in out nocopy number,
		p_ei_dedc		 in out nocopy number,
		p_donation_dedc		 in out nocopy number,
		-- End of 4322981
                p_non_taxable_ovs        in out nocopy number,
                p_non_taxable_ovt        in out nocopy number,
                p_research_payment       in out nocopy number,  -- Bug 6470526
                p_non_taxable_oth        in out nocopy number,
                p_fw_tax_break           in out nocopy number,   --3546994
		p_non_taxable_ovs_frgn   in out nocopy number,  -- Bug 7439803
		p_birth_raise_allow	 in out nocopy number,	-- Bug 7439803
		p_fw_income_exem	 in out nocopy number,  -- Bug 7439803
		-- start of bug 8880364
		p_non_tax_18_earn	 in out nocopy number,
		p_non_tax_19_earn	 in out nocopy number,
		p_non_tax_20_earn	 in out nocopy number,
		p_non_taxable		 in out nocopy number )
        is
		-----------------------------------
		-- Bug 3223825
		-- Pl/sql table declaration
		-----------------------------------
		t_balance_batch         pay_balance_pkg.t_balance_value_tab;

                l_taxable_mth                number;
                l_taxable_bon                number;
                l_sp_irreg_bonus_mth         number;
                l_sp_irreg_bonus_bon         number;
		l_fw_income_exem_rate	     number default 0;  -- Bug 7439803
        begin
                if p_effective_date is null then
                        p_effective_date        := p_date_paid;



			------------------------------------------
                        -- Bug 3223825
                        --populate values into plsql table
			------------------------------------------
                        t_balance_batch(1).defined_balance_id  := g_defined_balance_id.taxable_mth;
			t_balance_batch(2).defined_balance_id  := g_defined_balance_id.taxable_bon;
			t_balance_batch(3).defined_balance_id  := g_defined_balance_id.sp_irreg_bonus_mth;
			t_balance_batch(4).defined_balance_id  := g_defined_balance_id.sp_irreg_bonus_bon;
			t_balance_batch(5).defined_balance_id  := g_defined_balance_id.itax_mth;
			t_balance_batch(6).defined_balance_id  := g_defined_balance_id.itax_bon;
			t_balance_batch(7).defined_balance_id  := g_defined_balance_id.rtax_mth;
			t_balance_batch(8).defined_balance_id  := g_defined_balance_id.rtax_bon;
			t_balance_batch(9).defined_balance_id  := g_defined_balance_id.stax_mth;
			t_balance_batch(10).defined_balance_id := g_defined_balance_id.stax_bon;
			t_balance_batch(11).defined_balance_id := g_defined_balance_id.non_taxable_ovs_mth;
			t_balance_batch(12).defined_balance_id := g_defined_balance_id.non_taxable_ovs_bon;
			t_balance_batch(13).defined_balance_id := g_defined_balance_id.non_taxable_ovt_mth;
			t_balance_batch(14).defined_balance_id := g_defined_balance_id.non_taxable_ovt_bon;
			t_balance_batch(15).defined_balance_id := g_defined_balance_id.non_taxable_mth;
			t_balance_batch(16).defined_balance_id := g_defined_balance_id.non_taxable_bon;
			t_balance_batch(17).defined_balance_id := g_defined_balance_id.fw_tax_break_mth; --3546994
			t_balance_batch(18).defined_balance_id := g_defined_balance_id.fw_tax_break_bon; --3546994
			-- Bug 4322981
			t_balance_batch(19).defined_balance_id := g_defined_balance_id.np_prem_mth ;
			t_balance_batch(20).defined_balance_id := g_defined_balance_id.np_prem_bon ;
			t_balance_batch(21).defined_balance_id := g_defined_balance_id.hi_prem_mth ;
			t_balance_batch(22).defined_balance_id := g_defined_balance_id.hi_prem_bon ;
			t_balance_batch(23).defined_balance_id := g_defined_balance_id.ei_prem_mth ;
			t_balance_batch(24).defined_balance_id := g_defined_balance_id.ei_prem_bon ;
			t_balance_batch(25).defined_balance_id := g_defined_balance_id.donation_mth ;
			t_balance_batch(26).defined_balance_id := g_defined_balance_id.donation_bon ;
			-- End of 4322981
			-- Bug 5684037
			t_balance_batch(27).defined_balance_id := g_defined_balance_id.addl_non_tax_mth ;
			t_balance_batch(28).defined_balance_id := g_defined_balance_id.addl_non_tax_bon ;
			-- Bug 5999074 Rolled back changes for 5684037. Replaced with a single balance
			-- Additional Other Non-Taxable Earnings
			-- End of Bug 5684037
                        -- Bug 6470526: 2007 YEA Ledger Statutory Updates
                        t_balance_batch(29).defined_balance_id := g_defined_balance_id.stck_pur_opt_exec_earn_mth;
                        t_balance_batch(30).defined_balance_id := g_defined_balance_id.stck_pur_opt_exec_earn_bon;
                        t_balance_batch(31).defined_balance_id := g_defined_balance_id.research_payment_mth;
                        t_balance_batch(32).defined_balance_id := g_defined_balance_id.research_payment_bon;
                        -- End of Bug 6470526
			-- Bug 7439803: 2008 YEA Ledger Statutory Updates
			t_balance_batch(33).defined_balance_id := g_defined_balance_id.non_taxable_ovs_frgn_mth;
			t_balance_batch(34).defined_balance_id := g_defined_balance_id.non_taxable_ovs_frgn_bon;
			t_balance_batch(35).defined_balance_id := g_defined_balance_id.birth_raise_allow_mth;
			t_balance_batch(36).defined_balance_id := g_defined_balance_id.birth_raise_allow_bon;
			t_balance_batch(37).defined_balance_id := g_defined_balance_id.ltci_prem_mth;
			t_balance_batch(38).defined_balance_id := g_defined_balance_id.ltci_prem_bon;
			--End of Bug 7439803
			-- Bug 8880364: 2009 YEA ledger Updates
			t_balance_batch(39).defined_balance_id := g_defined_balance_id.esop_with_drawn_mth;
			t_balance_batch(40).defined_balance_id := g_defined_balance_id.esop_with_drawn_bon;
			t_balance_batch(41).defined_balance_id := g_defined_balance_id.rsrch_pay_ntax_H06_mth;
			t_balance_batch(42).defined_balance_id := g_defined_balance_id.rsrch_pay_ntax_H06_bon;
			t_balance_batch(43).defined_balance_id := g_defined_balance_id.rsrch_pay_ntax_H07_mth;
			t_balance_batch(44).defined_balance_id := g_defined_balance_id.rsrch_pay_ntax_H07_bon;
			t_balance_batch(45).defined_balance_id := g_defined_balance_id.rsrch_pay_ntax_H08_mth;
			t_balance_batch(46).defined_balance_id := g_defined_balance_id.rsrch_pay_ntax_H08_bon;
			t_balance_batch(47).defined_balance_id := g_defined_balance_id.rsrch_pay_ntax_H09_mth;
			t_balance_batch(48).defined_balance_id := g_defined_balance_id.rsrch_pay_ntax_H09_bon;
			t_balance_batch(49).defined_balance_id := g_defined_balance_id.rsrch_pay_ntax_H10_mth;
			t_balance_batch(50).defined_balance_id := g_defined_balance_id.rsrch_pay_ntax_H10_bon;
			t_balance_batch(51).defined_balance_id := g_defined_balance_id.non_tax_earn_G01_mth;
			t_balance_batch(52).defined_balance_id := g_defined_balance_id.non_tax_earn_G01_bon;
			t_balance_batch(53).defined_balance_id := g_defined_balance_id.non_tax_earn_H11_mth;
			t_balance_batch(54).defined_balance_id := g_defined_balance_id.non_tax_earn_H11_bon;

			t_balance_batch(55).defined_balance_id := g_defined_balance_id.non_tax_earn_H12_mth;
			t_balance_batch(56).defined_balance_id := g_defined_balance_id.non_tax_earn_H12_bon;
			t_balance_batch(57).defined_balance_id := g_defined_balance_id.non_tax_earn_H13_mth;
			t_balance_batch(58).defined_balance_id := g_defined_balance_id.non_tax_earn_H13_bon;
			t_balance_batch(59).defined_balance_id := g_defined_balance_id.non_tax_earn_H01_mth;
			t_balance_batch(60).defined_balance_id := g_defined_balance_id.non_tax_earn_H01_bon;
			t_balance_batch(61).defined_balance_id := g_defined_balance_id.non_tax_earn_K01_mth;
			t_balance_batch(62).defined_balance_id := g_defined_balance_id.non_tax_earn_K01_bon;
			t_balance_batch(63).defined_balance_id := g_defined_balance_id.non_tax_earn_S01_mth;
			t_balance_batch(64).defined_balance_id := g_defined_balance_id.non_tax_earn_S01_bon;
			t_balance_batch(65).defined_balance_id := g_defined_balance_id.non_tax_earn_Y01_mth;
			t_balance_batch(66).defined_balance_id := g_defined_balance_id.non_tax_earn_Y01_bon;
			t_balance_batch(67).defined_balance_id := g_defined_balance_id.non_tax_earn_Y02_mth;
			t_balance_batch(68).defined_balance_id := g_defined_balance_id.non_tax_earn_Y02_bon;
			t_balance_batch(69).defined_balance_id := g_defined_balance_id.non_tax_earn_Y03_mth;
			t_balance_batch(70).defined_balance_id := g_defined_balance_id.non_tax_earn_Y03_bon;
			t_balance_batch(71).defined_balance_id := g_defined_balance_id.non_tax_earn_Y20_mth;
			t_balance_batch(72).defined_balance_id := g_defined_balance_id.non_tax_earn_Y20_bon;
			t_balance_batch(73).defined_balance_id := g_defined_balance_id.non_tax_earn_Z01_mth;
			t_balance_batch(74).defined_balance_id := g_defined_balance_id.non_tax_earn_Z01_bon;
			t_balance_batch(75).defined_balance_id := g_defined_balance_id.non_tax_earn_T01_mth;
			t_balance_batch(76).defined_balance_id := g_defined_balance_id.non_tax_earn_T01_bon;
			t_balance_batch(77).defined_balance_id := g_defined_balance_id.non_tax_earn_H05_mth;
			t_balance_batch(78).defined_balance_id := g_defined_balance_id.non_tax_earn_H05_bon;
			t_balance_batch(79).defined_balance_id := g_defined_balance_id.non_tax_earn_I01_mth;
			t_balance_batch(80).defined_balance_id := g_defined_balance_id.non_tax_earn_I01_bon;
			t_balance_batch(81).defined_balance_id := g_defined_balance_id.non_tax_earn_M01_mth;
			t_balance_batch(82).defined_balance_id := g_defined_balance_id.non_tax_earn_M01_bon;
			t_balance_batch(83).defined_balance_id := g_defined_balance_id.non_tax_earn_M02_mth;
			t_balance_batch(84).defined_balance_id := g_defined_balance_id.non_tax_earn_M02_bon;
			t_balance_batch(85).defined_balance_id := g_defined_balance_id.non_tax_earn_M03_mth;
			t_balance_batch(86).defined_balance_id := g_defined_balance_id.non_tax_earn_M03_bon;
			t_balance_batch(87).defined_balance_id := g_defined_balance_id.non_tax_earn_frgn_M01_mth;
			t_balance_batch(88).defined_balance_id := g_defined_balance_id.non_tax_earn_frgn_M01_bon;
			t_balance_batch(89).defined_balance_id := g_defined_balance_id.non_tax_earn_frgn_M02_mth;
			t_balance_batch(90).defined_balance_id := g_defined_balance_id.non_tax_earn_frgn_M02_bon;
			t_balance_batch(91).defined_balance_id := g_defined_balance_id.non_tax_earn_frgn_M03_mth;
			t_balance_batch(92).defined_balance_id := g_defined_balance_id.non_tax_earn_frgn_M03_bon;

 			----------------------------------------------
                        --Bug 3223825
                        --batch get_value call
			----------------------------------------------
			pay_balance_pkg.get_value(p_assact,t_balance_batch,FALSE,FALSE);
 			--
			l_fw_income_exem_rate   := get_globalvalue('KR_FOREIGN_WORKER_INCOME_EXEM_RATE',p_date_paid); -- Bug 7439803
			--
                        l_taxable_mth           := t_balance_batch(1).balance_value;
                        l_taxable_bon           := t_balance_batch(2).balance_value;
                        l_sp_irreg_bonus_mth    := t_balance_batch(3).balance_value;
                        l_sp_irreg_bonus_bon    := t_balance_batch(4).balance_value;
                        p_taxable_mth           := l_taxable_mth - l_sp_irreg_bonus_mth;
                        p_taxable_bon           := l_taxable_bon - l_sp_irreg_bonus_bon;
                        p_sp_irreg_bonus        := l_sp_irreg_bonus_mth + l_sp_irreg_bonus_bon;
                        --
                        -- Bug 6470526: 2007 YEA Ledger Statutory Updates
                        p_stck_pur_opt_exec_earn := t_balance_batch(29).balance_value
                                                  + t_balance_batch(30).balance_value;

			if to_number(to_char(p_date_paid,'YYYY')) < 2009 then
                        p_research_payment       := t_balance_batch(31).balance_value
                                                  + t_balance_batch(32).balance_value;
			else
			p_research_payment	:= t_balance_batch(41).balance_value
                                                  + t_balance_batch(42).balance_value
						  + t_balance_batch(43).balance_value
                                                  + t_balance_batch(44).balance_value
						  + t_balance_batch(45).balance_value
                                                  + t_balance_batch(46).balance_value
						  + t_balance_batch(47).balance_value
                                                  + t_balance_batch(48).balance_value
						  + t_balance_batch(49).balance_value
                                                  + t_balance_batch(50).balance_value;
			end if;
			p_esop_with_drawn	:= t_balance_batch(39).balance_value
                                                 + t_balance_batch(40).balance_value;
                        p_taxable               := p_taxable_mth
                                                 + p_taxable_bon
                                                 + p_sp_irreg_bonus
                                                 + p_stck_pur_opt_exec_earn
						 + p_esop_with_drawn; -- Bug 9280894
                        -- End of Bug 6470526
                        --
                        p_itax                  := t_balance_batch(5).balance_value
                                                 + t_balance_batch(6).balance_value;
                        p_rtax                  := t_balance_batch(7).balance_value
                                                 + t_balance_batch(8).balance_value;
                        p_stax                  := t_balance_batch(9).balance_value
                                                 + t_balance_batch(10).balance_value;
			p_non_taxable_ovt       := t_balance_batch(13).balance_value
                                                 + t_balance_batch(14).balance_value;
			-- Bug 8880364
			if to_number(to_char(p_date_paid,'YYYY')) < 2009 then
                        p_non_taxable_ovs       := t_balance_batch(11).balance_value
                                                 + t_balance_batch(12).balance_value;
                        p_non_taxable_ovs_frgn  := t_balance_batch(33).balance_value
                                                 + t_balance_batch(34).balance_value;   -- Bug 7439803
			else
			 p_non_taxable_ovs       := t_balance_batch(81).balance_value
                                                 + t_balance_batch(82).balance_value
						 + t_balance_batch(83).balance_value
                                                 + t_balance_batch(84).balance_value
						 + t_balance_batch(85).balance_value
                                                 + t_balance_batch(86).balance_value;
			 p_non_taxable_ovs_frgn  := t_balance_batch(87).balance_value
                                                 + t_balance_batch(88).balance_value
						 + t_balance_batch(89).balance_value
                                                 + t_balance_batch(90).balance_value
						 + t_balance_batch(91).balance_value
                                                 + t_balance_batch(92).balance_value;
			end if;

			p_birth_raise_allow	:= t_balance_batch(35).balance_value
                                                 + t_balance_batch(36).balance_value;   -- Bug 7439803
			-- Bug 7595082
			-- Bug 8880364
			p_non_tax_18_earn       := t_balance_batch(51).balance_value
                                                 + t_balance_batch(52).balance_value;
			p_non_tax_19_earn	:= t_balance_batch(53).balance_value
                                                 + t_balance_batch(54).balance_value;
			p_non_tax_20_earn       := t_balance_batch(55).balance_value
						   + t_balance_batch(56).balance_value
						   + t_balance_batch(57).balance_value
						   + t_balance_batch(58).balance_value
						   + t_balance_batch(59).balance_value
						   + t_balance_batch(60).balance_value
						   + t_balance_batch(61).balance_value
						   + t_balance_batch(62).balance_value
						   + t_balance_batch(63).balance_value
						   + t_balance_batch(64).balance_value
						   + t_balance_batch(65).balance_value
						   + t_balance_batch(66).balance_value
						   + t_balance_batch(67).balance_value
						   + t_balance_batch(68).balance_value
						   + t_balance_batch(69).balance_value
						   + t_balance_batch(70).balance_value
						   + t_balance_batch(71).balance_value
						   + t_balance_batch(72).balance_value
						   + t_balance_batch(73).balance_value
						   + t_balance_batch(74).balance_value
						   + t_balance_batch(75).balance_value
						   + t_balance_batch(76).balance_value
						   + t_balance_batch(77).balance_value
						   + t_balance_batch(78).balance_value
						   + t_balance_batch(79).balance_value
						   + t_balance_batch(80).balance_value;

			-- End of bug 8880364
			if p_nationality ='F' and  p_fw_fixed_tax_rate <> 'Y' then
				p_fw_income_exem  := greatest(trunc
					                     (p_taxable * l_fw_income_exem_rate),0);   -- Bug 7439803
			else
				p_fw_income_exem  := 0;
			end if;
			--
			if to_number(to_char(p_date_paid,'YYYY')) < 2009 then

                        p_non_taxable_oth       := t_balance_batch(15).balance_value
                                                 + t_balance_batch(16).balance_value
                                                 + t_balance_batch(27).balance_value    -- Bug 5684037
                                                 + t_balance_batch(28).balance_value
                                                 - p_non_taxable_ovs
                                                 - p_non_taxable_ovt
						 - p_birth_raise_allow
						 - p_non_taxable_ovs_frgn ;   -- Bug 7439803

			else
			 p_non_taxable_oth       := t_balance_batch(27).balance_value    -- Bug 9079478
                                                 + t_balance_batch(28).balance_value;
			 p_non_taxable		:= p_non_taxable_ovs
                                                 + p_non_taxable_ovt
						 + p_birth_raise_allow
						 + p_non_taxable_ovs_frgn
						 + p_non_tax_18_earn
						 + p_non_tax_19_earn
						 + p_non_tax_20_earn
						 + p_research_payment
						 + p_fw_income_exem
						 + p_non_taxable_oth;


			end if;


                        p_fw_tax_break          := t_balance_batch(17).balance_value    --3546994
                                                 + t_balance_batch(18).balance_value;   --3546994
			-- Bug 4322981
			p_np_dedc		:= t_balance_batch(19).balance_value
						 + t_balance_batch(20).balance_value ;
			p_hi_dedc		:= t_balance_batch(21).balance_value
						 + t_balance_batch(22).balance_value
						 + t_balance_batch(37).balance_value
						 + t_balance_batch(38).balance_value ; -- Bug 7439803
			p_ei_dedc		:= t_balance_batch(23).balance_value
						 + t_balance_batch(24).balance_value ;
			p_donation_dedc		:= t_balance_batch(25).balance_value
						 + t_balance_batch(26).balance_value ;
			-- End of 4322981
                        --
                        -- Index 13th indicates total amount
                        -- If no assacts are detected, total is also "NULL" value.
                        --
                        p_taxable_mth13         := nvl(p_taxable_mth13, 0) + p_taxable_mth;
                        p_taxable_bon13         := nvl(p_taxable_bon13, 0) + p_taxable_bon;
                        p_sp_irreg_bonus13      := nvl(p_sp_irreg_bonus13, 0) + p_sp_irreg_bonus;
                        p_taxable13             := nvl(p_taxable13, 0) + p_taxable;
                        p_itax13                := nvl(p_itax13, 0) + p_itax;
                        p_rtax13                := nvl(p_rtax13, 0) + p_rtax;
                        p_stax13                := nvl(p_stax13, 0) + p_stax;
                        p_non_taxable_ovs13     := nvl(p_non_taxable_ovs13, 0) + p_non_taxable_ovs;
                        p_non_taxable_ovt13     := nvl(p_non_taxable_ovt13, 0) + p_non_taxable_ovt;
			p_non_taxable_ovs_frgn13 := nvl(p_non_taxable_ovs_frgn13, 0) + p_non_taxable_ovs_frgn;  -- Bug 7439803
			p_birth_raising_allow13 := nvl(p_birth_raising_allow13, 0) + p_birth_raise_allow;   	-- Bug 7439803
			p_fw_income_exem13	:= nvl(p_fw_income_exem13, 0) + p_fw_income_exem;   		-- Bug 7439803
			p_fw_tax_break13	:= nvl(p_fw_tax_break13, 0) + p_fw_tax_break; 			-- Bug 7439803
                        p_non_taxable_oth13     := nvl(p_non_taxable_oth13, 0) + p_non_taxable_oth;
			-- Bug 4322981
			p_np_dedc13		:= nvl(p_np_dedc13, 0) + p_np_dedc ;
			p_hi_dedc13		:= nvl(p_hi_dedc13, 0) + p_hi_dedc ;
			p_ei_dedc13		:= nvl(p_ei_dedc13, 0) + p_ei_dedc ;
			p_donation_dedc13	:= nvl(p_donation_dedc13, 0) + p_donation_dedc ;
			-- End of 4322981
                        --
                        -- Bug 6470526: 2007 YEA Ledger Statutory Updates
                        p_stck_pur_opt_exec_earn13 := nvl(p_stck_pur_opt_exec_earn13, 0) + p_stck_pur_opt_exec_earn ;
                        p_research_payment13       := nvl(p_research_payment13, 0) + p_research_payment ;
                        -- End of Bug 6470526
			-- Bug 8880364
			p_esop_with_drawn13	   := nvl(p_esop_with_drawn13,0) + p_esop_with_drawn ;
			p_non_tax_18_earn13	   := nvl(p_non_tax_18_earn13,0) + p_non_tax_18_earn;
			p_non_tax_19_earn13	   := nvl(p_non_tax_19_earn13,0) + p_non_tax_19_earn;
			p_non_tax_20_earn13	   := nvl(p_non_tax_20_earn13,0) + p_non_tax_20_earn;
			p_non_taxable13		   := nvl(p_non_taxable13, 0) + p_non_taxable;
                end if;
        end payment_details;
begin
        --
        -- Derive YEA result
        --
	 l_yea_info := pay_kr_yea_pkg.yea_info(p_assignment_action_id);
        --
        -- Taxable Earnings
        --
        p_taxable                       := l_yea_info.taxable;
	--Bug 7595082
	p_nationality			:= l_yea_info.nationality;
	p_fw_fixed_tax_rate		:= l_yea_info.fixed_tax_rate;
	--
	--
        -- Basic Income Exemption
        --
        p_basic_income_exem             := l_yea_info.basic_income_exem;
        p_taxable_income                := l_yea_info.taxable_income;
        --
        -- Basic Tax Exemption
        --
        p_ee_tax_exem                   := l_yea_info.ee_tax_exem;
        p_dpnt_spouse_flag              := l_yea_info.dpnt_spouse_flag;
        p_dpnt_spouse_tax_exem          := l_yea_info.dpnt_spouse_tax_exem;
        p_num_of_underaged_dpnts        := l_yea_info.num_of_underaged_dpnts;
        p_num_of_aged_dpnts             := l_yea_info.num_of_adult_dpnts + l_yea_info.num_of_aged_dpnts;
        p_dpnt_tax_exem                 := l_yea_info.dpnt_tax_exem;
        --
        -- Additional Tax Exemption
        --
        p_num_of_ageds                  := l_yea_info.num_of_ageds;
        p_aged_tax_exem                 := l_yea_info.aged_tax_exem;
        p_num_of_disableds              := l_yea_info.num_of_disableds;
        p_disabled_tax_exem             := l_yea_info.disabled_tax_exem;
        p_female_ee_flag                := l_yea_info.female_ee_flag;
        p_female_ee_tax_exem            := l_yea_info.female_ee_tax_exem;
        p_num_of_children               := l_yea_info.num_of_children;
        p_child_tax_exem                := l_yea_info.child_tax_exem;
        p_supp_tax_exem                 := l_yea_info.supp_tax_exem;
        --
        -- Special Tax Exemption
        --
        p_hi_prem                       := l_yea_info.hi_prem;
        p_ei_prem                       := l_yea_info.ei_prem;
        p_pers_ins_name                 := l_yea_info.pers_ins_name;
        p_pers_ins_prem                 := l_yea_info.pers_ins_prem;
        p_disabled_ins_prem             := l_yea_info.disabled_ins_prem;
        p_ins_prem_tax_exem             := l_yea_info.ins_prem_tax_exem;
        --
        p_med_exp                       := l_yea_info.med_exp;
        p_med_exp_aged                  := l_yea_info.med_exp_aged;
        p_med_exp_disabled              := l_yea_info.med_exp_disabled;
        p_max_med_exp_tax_exem          := l_yea_info.max_med_exp_tax_exem;
        p_med_exp_tax_exem              := l_yea_info.med_exp_tax_exem;
        --
        p_ee_educ_exp                   := l_yea_info.ee_educ_exp;
        p_spouse_educ_exp               := l_yea_info.spouse_educ_exp;
        p_disabled_educ_exp             := l_yea_info.disabled_educ_exp;
        p_dpnt_educ_exp                 := l_yea_info.dpnt_educ_exp;
        p_educ_exp_tax_exem             := l_yea_info.educ_exp_tax_exem;
        --
        p_housing_saving_type_meaning   := hr_general.decode_lookup('KR_HOUSING_SAVING_TYPE', l_yea_info.housing_saving_type);
        p_housing_saving                := l_yea_info.housing_saving;
        p_housing_purchase_date         := l_yea_info.housing_purchase_date;
        p_housing_loan_date             := l_yea_info.housing_loan_date;
        p_housing_loan_repay            := l_yea_info.housing_loan_repay;
        p_lt_housing_loan_date          := l_yea_info.lt_housing_loan_date;
        p_lt_housing_loan_int_repay     := l_yea_info.lt_housing_loan_interest_repay;
        p_max_housing_exp_tax_exem      := l_yea_info.max_housing_exp_tax_exem;
        p_housing_exp_tax_exem          := l_yea_info.housing_exp_tax_exem;
        --
        -- source modified for Bug2821759
        p_donation1_tax_exem            := l_yea_info.donation1 + l_yea_info.political_donation1 + l_yea_info.political_donation2 + l_yea_info.political_donation3;
        p_donation2                     := l_yea_info.donation2 + l_yea_info.donation3;
        p_max_donation2_tax_exem        := l_yea_info.max_donation2_tax_exem + l_yea_info.max_donation3_tax_exem;
        p_donation2_tax_exem            := l_yea_info.donation2_tax_exem + l_yea_info.donation3_tax_exem;
        p_donation_tax_exem             := l_yea_info.donation_tax_exem;
        --
        p_sp_tax_exem                   := l_yea_info.sp_tax_exem;
        p_std_sp_tax_exem               := l_yea_info.std_sp_tax_exem;
        --
        -- National Pension Premium Tax Exemption
        --
        p_np_prem                       := l_yea_info.np_prem;
        p_np_prem_tax_exem              := l_yea_info.np_prem_tax_exem;
        --
        -- Other Tax Exemptions
        -- source modified for Bug2821759
        p_pers_pension_prem_tax         := l_yea_info.pers_pension_prem;
        p_pers_pension_saving_tax       := l_yea_info.pers_pension_saving;
        p_invest_partner_fin_tax        := l_yea_info.invest_partner_fin1 + l_yea_info.invest_partner_fin2;
        p_credit_card_exp_tax           := l_yea_info.credit_card_exp;
        p_emp_st_own_plan_cont          := l_yea_info.emp_stk_own_contri;

        p_pers_pension_prem_tax_exem    := l_yea_info.pers_pension_prem_tax_exem;
        p_pers_pension_saving_tax_exem  := l_yea_info.pers_pension_saving_tax_exem;
        p_invest_partner_fin_tax_exem   := l_yea_info.invest_partner_fin_tax_exem;
        p_credit_card_exp_tax_exem      := l_yea_info.credit_card_exp_tax_exem;
        p_emp_st_own_plan_cont_exem     := l_yea_info.emp_stk_own_contri_tax_exem;
        --
        -- Calculated Tax
        --
        p_taxation_base                 := l_yea_info.taxation_base;
        p_calc_tax                      := l_yea_info.calc_tax;
        --
        -- Tax Breaks
        --
        p_basic_tax_break               := l_yea_info.basic_tax_break;
        p_housing_exp_tax_break         := l_yea_info.housing_exp_tax_break;
        p_stock_saving_tax_break        := l_yea_info.stock_saving_tax_break;
        --
        if l_yea_info.ovstb_tax_paid_date is not null then
                p_ovstb_territory_short_name := hr_general.decode_territory(l_yea_info.ovstb_territory_code);
                p_ovstb_tax_paid_date           := l_yea_info.ovstb_tax_paid_date;
                p_ovstb_tax_foreign_currency    := l_yea_info.ovstb_tax_foreign_currency;
                p_ovstb_tax                     := l_yea_info.ovstb_tax;
                p_ovstb_application_date        := l_yea_info.ovstb_application_date;
                p_ovstb_submission_date         := l_yea_info.ovstb_submission_date;
        end if;
        p_ovs_tax_break                 := l_yea_info.ovs_tax_break;
        --
        p_lt_stock_saving_tax_break     := l_yea_info.lt_stock_saving_tax_break;
        p_total_tax_break               := l_yea_info.total_tax_break;
        --
        -- Foreign Worker Tax Break
        --
        if l_yea_info.fwtb_immigration_purpose is not null then
                p_fwtb_immigration_purpose      := l_yea_info.fwtb_immigration_purpose;
                p_fwtb_contract_date            := l_yea_info.fwtb_contract_date;
                p_fwtb_expiry_date              := l_yea_info.fwtb_expiry_date;
                p_fwtb_application_date         := l_yea_info.fwtb_application_date;
                p_fwtb_submission_date          := l_yea_info.fwtb_submission_date;
        end if;
        p_foreign_worker_tax_break1     := l_yea_info.foreign_worker_tax_break1;
        p_foreign_worker_tax_break2     := l_yea_info.foreign_worker_tax_break2;
        --
        -- Tax
        -- Rtax calculation included for bug 2577751
        --
        p_annual_itax           := l_yea_info.annual_itax;
        p_annual_rtax           := l_yea_info.annual_rtax;
        p_annual_stax           := l_yea_info.annual_stax;
        p_prev_itax             := l_yea_info.prev_itax;
        p_prev_rtax             := l_yea_info.prev_rtax;
        p_prev_stax             := l_yea_info.prev_stax;
        p_cur_annual_itax       := p_annual_itax - p_prev_itax;
        p_cur_annual_rtax       := p_annual_rtax - p_prev_rtax;
        p_cur_annual_stax       := p_annual_stax - p_prev_stax;
        p_cur_itax              := l_yea_info.cur_itax;
        p_cur_rtax              := l_yea_info.cur_rtax;
        p_cur_stax              := l_yea_info.cur_stax;
        if l_yea_info.itax_adj >= 0 then
                p_itax_adj      := l_yea_info.itax_adj;
                p_itax_refund   := 0;
        else
                p_itax_adj      := 0;
                p_itax_refund   := abs(l_yea_info.itax_adj);
        end if;
        --
        -- rtax calculation included for bug 2577751
        --
        if l_yea_info.rtax_adj >= 0 then
                p_rtax_adj      := l_yea_info.rtax_adj;
                p_rtax_refund   := 0;
        else
                p_rtax_adj      := 0;
                p_rtax_refund   := abs(l_yea_info.rtax_adj);
        end if;
        if l_yea_info.stax_adj >= 0 then
                p_stax_adj      := l_yea_info.stax_adj;
                p_stax_refund   := 0;
        else
                p_stax_adj      := 0;
                p_stax_refund   := abs(l_yea_info.stax_adj);
        end if;
        --
        -- Derive annual payment details
        --
/* Calculate total no of dependents including spouse
   and the employee himself - Bug No: 3546994        */
		if nvl(l_yea_info.dpnt_spouse_flag,'N') = 'Y' then
		    l_dependent_spouse_count := 1;
		else
		    l_dependent_spouse_count := 0;
		end if;
		p_dependent_count       := l_yea_info.num_of_underaged_dpnts
                                 + l_yea_info.num_of_adult_dpnts
                                 + l_yea_info.num_of_aged_dpnts
                                 + l_dependent_spouse_count       -- include spouse
                                 + 1;                             -- include employee
-- 3546994
	-- Bug 4261844: Get the balance adjustment action
	open 	csr_bal_adj_assact ;
	fetch 	csr_bal_adj_assact into l_bal_adj_assact ;
	close 	csr_bal_adj_assact ;

	if l_bal_adj_assact is null then
		l_bal_adj_assact := p_assignment_action_id ;
	end if ;

        for l_rec in csr_assact(l_bal_adj_assact) loop
                l_month := to_number(to_char(l_rec.effective_date, 'MM'));
                if l_month = 1 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date1,
                                p_taxable_mth           => p_taxable_mth1,
                                p_taxable_bon           => p_taxable_bon1,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus1,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn1,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn1,          -- Bug 8880364
                                p_taxable               => p_taxable1,
                                p_itax                  => p_itax1,
                                p_rtax                  => p_rtax1,
                                p_stax                  => p_stax1,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc1,
				p_hi_dedc		=> p_hi_dedc1,
				p_ei_dedc		=> p_ei_dedc1,
				p_donation_dedc		=> p_donation_dedc1,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs1,
                                p_non_taxable_ovt       => p_non_taxable_ovt1,
                                p_research_payment      => p_research_payment1,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth1,
                                p_fw_tax_break          => p_fw_tax_break1,    -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn1, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow1,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem1, 	    -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn1,
				p_non_tax_19_earn	=> p_non_tax_19_earn1,
				p_non_tax_20_earn	=> p_non_tax_20_earn1,
				p_non_taxable		=> p_non_taxable1);
                elsif l_month = 2 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date2,
                                p_taxable_mth           => p_taxable_mth2,
                                p_taxable_bon           => p_taxable_bon2,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus2,
				p_esop_with_drawn       => p_esop_with_drawn2,          -- Bug 8880364
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn2,   -- Bug 6470526
                                p_taxable               => p_taxable2,
                                p_itax                  => p_itax2,
                                p_rtax                  => p_rtax2,
                                p_stax                  => p_stax2,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc2,
				p_hi_dedc		=> p_hi_dedc2,
				p_ei_dedc		=> p_ei_dedc2,
				p_donation_dedc		=> p_donation_dedc2,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs2,
                                p_non_taxable_ovt       => p_non_taxable_ovt2,
                                p_research_payment      => p_research_payment2,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth2,
                                p_fw_tax_break          => p_fw_tax_break2,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn2, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow2,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem2, 	    -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn2,
				p_non_tax_19_earn	=> p_non_tax_19_earn2,
				p_non_tax_20_earn	=> p_non_tax_20_earn2,
				p_non_taxable		=> p_non_taxable2);
                elsif l_month = 3 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date3,
                                p_taxable_mth           => p_taxable_mth3,
                                p_taxable_bon           => p_taxable_bon3,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus3,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn3,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn3,          -- Bug 8880364
                                p_taxable               => p_taxable3,
                                p_itax                  => p_itax3,
                                p_rtax                  => p_rtax3,
                                p_stax                  => p_stax3,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc3,
				p_hi_dedc		=> p_hi_dedc3,
				p_ei_dedc		=> p_ei_dedc3,
				p_donation_dedc		=> p_donation_dedc3,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs3,
                                p_non_taxable_ovt       => p_non_taxable_ovt3,
                                p_research_payment      => p_research_payment3,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth3,
                                p_fw_tax_break          => p_fw_tax_break3,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn3, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow3,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem3, 	    -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn3,
				p_non_tax_19_earn	=> p_non_tax_19_earn3,
				p_non_tax_20_earn	=> p_non_tax_20_earn3,
				p_non_taxable		=> p_non_taxable3);
                elsif l_month = 4 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date4,
                                p_taxable_mth           => p_taxable_mth4,
                                p_taxable_bon           => p_taxable_bon4,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus4,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn4,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn4,          -- Bug 8880364
                                p_taxable               => p_taxable4,
                                p_itax                  => p_itax4,
                                p_rtax                  => p_rtax4,
                                p_stax                  => p_stax4,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc4,
				p_hi_dedc		=> p_hi_dedc4,
				p_ei_dedc		=> p_ei_dedc4,
				p_donation_dedc		=> p_donation_dedc4,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs4,
                                p_non_taxable_ovt       => p_non_taxable_ovt4,
                                p_research_payment      => p_research_payment4,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth4,
                                p_fw_tax_break          => p_fw_tax_break4,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn4, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow4,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem4, 	    -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn4,
				p_non_tax_19_earn	=> p_non_tax_19_earn4,
				p_non_tax_20_earn	=> p_non_tax_20_earn4,
				p_non_taxable		=> p_non_taxable4);
                elsif l_month = 5 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date5,
                                p_taxable_mth           => p_taxable_mth5,
                                p_taxable_bon           => p_taxable_bon5,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus5,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn5,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn5,          -- Bug 8880364
                                p_taxable               => p_taxable5,
                                p_itax                  => p_itax5,
                                p_rtax                  => p_rtax5,
                                p_stax                  => p_stax5,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc5,
				p_hi_dedc		=> p_hi_dedc5,
				p_ei_dedc		=> p_ei_dedc5,
				p_donation_dedc		=> p_donation_dedc5,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs5,
                                p_non_taxable_ovt       => p_non_taxable_ovt5,
                                p_research_payment      => p_research_payment5,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth5,
                                p_fw_tax_break          => p_fw_tax_break5,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn5, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow5,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem5, 	    -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn5,
				p_non_tax_19_earn	=> p_non_tax_19_earn5,
				p_non_tax_20_earn	=> p_non_tax_20_earn5,
				p_non_taxable		=> p_non_taxable5);
                elsif l_month = 6 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date6,
                                p_taxable_mth           => p_taxable_mth6,
                                p_taxable_bon           => p_taxable_bon6,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus6,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn6,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn6,          -- Bug 8880364
                                p_taxable               => p_taxable6,
                                p_itax                  => p_itax6,
                                p_rtax                  => p_rtax6,
                                p_stax                  => p_stax6,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc6,
				p_hi_dedc		=> p_hi_dedc6,
				p_ei_dedc		=> p_ei_dedc6,
				p_donation_dedc		=> p_donation_dedc6,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs6,
                                p_non_taxable_ovt       => p_non_taxable_ovt6,
                                p_research_payment      => p_research_payment6,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth6,
                                p_fw_tax_break          => p_fw_tax_break6,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn6, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow6,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem6, 	    -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn6,
				p_non_tax_19_earn	=> p_non_tax_19_earn6,
				p_non_tax_20_earn	=> p_non_tax_20_earn6,
				p_non_taxable		=> p_non_taxable6);
                elsif l_month = 7 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date7,
                                p_taxable_mth           => p_taxable_mth7,
                                p_taxable_bon           => p_taxable_bon7,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus7,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn7,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn7,          -- Bug 8880364
                                p_taxable               => p_taxable7,
                                p_itax                  => p_itax7,
                                p_rtax                  => p_rtax7,
                                p_stax                  => p_stax7,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc7,
				p_hi_dedc		=> p_hi_dedc7,
				p_ei_dedc		=> p_ei_dedc7,
				p_donation_dedc		=> p_donation_dedc7,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs7,
                                p_non_taxable_ovt       => p_non_taxable_ovt7,
                                p_research_payment      => p_research_payment7,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth7,
                                p_fw_tax_break          => p_fw_tax_break7,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn7, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow7,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem7,	    -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn7,
				p_non_tax_19_earn	=> p_non_tax_19_earn7,
				p_non_tax_20_earn	=> p_non_tax_20_earn7,
				p_non_taxable		=> p_non_taxable7);
                elsif l_month = 8 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date8,
                                p_taxable_mth           => p_taxable_mth8,
                                p_taxable_bon           => p_taxable_bon8,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus8,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn8,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn8,          -- Bug 8880364
                                p_taxable               => p_taxable8,
                                p_itax                  => p_itax8,
                                p_rtax                  => p_rtax8,
                                p_stax                  => p_stax8,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc8,
				p_hi_dedc		=> p_hi_dedc8,
				p_ei_dedc		=> p_ei_dedc8,
				p_donation_dedc		=> p_donation_dedc8,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs8,
                                p_non_taxable_ovt       => p_non_taxable_ovt8,
                                p_research_payment      => p_research_payment8,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth8,
                                p_fw_tax_break          => p_fw_tax_break8,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn8, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow8,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem8, 	    -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn8,
				p_non_tax_19_earn	=> p_non_tax_19_earn8,
				p_non_tax_20_earn	=> p_non_tax_20_earn8,
				p_non_taxable		=> p_non_taxable8);
                elsif l_month = 9 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date9,
                                p_taxable_mth           => p_taxable_mth9,
                                p_taxable_bon           => p_taxable_bon9,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus9,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn9,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn9,          -- Bug 8880364
                                p_taxable               => p_taxable9,
                                p_itax                  => p_itax9,
                                p_rtax                  => p_rtax9,
                                p_stax                  => p_stax9,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc9,
				p_hi_dedc		=> p_hi_dedc9,
				p_ei_dedc		=> p_ei_dedc9,
				p_donation_dedc		=> p_donation_dedc9,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs9,
                                p_non_taxable_ovt       => p_non_taxable_ovt9,
                                p_research_payment      => p_research_payment9,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth9,
                                p_fw_tax_break          => p_fw_tax_break9,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn9, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow9,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem9, 	    -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn9,
				p_non_tax_19_earn	=> p_non_tax_19_earn9,
				p_non_tax_20_earn	=> p_non_tax_20_earn9,
				p_non_taxable		=> p_non_taxable9);
                elsif l_month = 10 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date10,
                                p_taxable_mth           => p_taxable_mth10,
                                p_taxable_bon           => p_taxable_bon10,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus10,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn10,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn10,          -- Bug 8880364
                                p_taxable               => p_taxable10,
                                p_itax                  => p_itax10,
                                p_rtax                  => p_rtax10,
                                p_stax                  => p_stax10,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc10,
				p_hi_dedc		=> p_hi_dedc10,
				p_ei_dedc		=> p_ei_dedc10,
				p_donation_dedc		=> p_donation_dedc10,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs10,
                                p_non_taxable_ovt       => p_non_taxable_ovt10,
                                p_research_payment      => p_research_payment10,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth10,
                                p_fw_tax_break          => p_fw_tax_break10,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn10, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow10,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem10,      -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn10,
				p_non_tax_19_earn	=> p_non_tax_19_earn10,
				p_non_tax_20_earn	=> p_non_tax_20_earn10,
				p_non_taxable		=> p_non_taxable10);
                elsif l_month = 11 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date11,
                                p_taxable_mth           => p_taxable_mth11,
                                p_taxable_bon           => p_taxable_bon11,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus11,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn11,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn11,          -- Bug 8880364
                                p_taxable               => p_taxable11,
                                p_itax                  => p_itax11,
                                p_rtax                  => p_rtax11,
                                p_stax                  => p_stax11,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc11,
				p_hi_dedc		=> p_hi_dedc11,
				p_ei_dedc		=> p_ei_dedc11,
				p_donation_dedc		=> p_donation_dedc11,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs11,
                                p_non_taxable_ovt       => p_non_taxable_ovt11,
                                p_research_payment      => p_research_payment11,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth11,
                                p_fw_tax_break          => p_fw_tax_break11,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn11, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow11,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem11,      -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn11,
				p_non_tax_19_earn	=> p_non_tax_19_earn11,
				p_non_tax_20_earn	=> p_non_tax_20_earn11,
				p_non_taxable		=> p_non_taxable11);
                elsif l_month = 12 then
                        payment_details(
                                p_assact                => l_rec.assignment_action_id,
                                p_date_paid             => l_rec.effective_date,
                                p_effective_date        => p_effective_date12,
                                p_taxable_mth           => p_taxable_mth12,
                                p_taxable_bon           => p_taxable_bon12,
                                p_sp_irreg_bonus        => p_sp_irreg_bonus12,
                                p_stck_pur_opt_exec_earn => p_stck_pur_opt_exec_earn12,   -- Bug 6470526
				p_esop_with_drawn       => p_esop_with_drawn12,          -- Bug 8880364
                                p_taxable               => p_taxable12,
                                p_itax                  => p_itax12,
                                p_rtax                  => p_rtax12,
                                p_stax                  => p_stax12,
				-- Bug 4322981
				p_np_dedc		=> p_np_dedc12,
				p_hi_dedc		=> p_hi_dedc12,
				p_ei_dedc		=> p_ei_dedc12,
				p_donation_dedc		=> p_donation_dedc12,
				-- End of 4322981
                                p_non_taxable_ovs       => p_non_taxable_ovs12,
                                p_non_taxable_ovt       => p_non_taxable_ovt12,
                                p_research_payment      => p_research_payment12,     -- Bug 6470526
                                p_non_taxable_oth       => p_non_taxable_oth12,
                                p_fw_tax_break          => p_fw_tax_break12,   -- 3546994
				p_non_taxable_ovs_frgn  => p_non_taxable_ovs_frgn12, -- Bug 7439803
				p_birth_raise_allow	=> p_birth_raising_allow12,  -- Bug 7439803
				p_fw_income_exem	=> p_fw_income_exem12,      -- Bug 7439803
				p_non_tax_18_earn	=> p_non_tax_18_earn12,
				p_non_tax_19_earn	=> p_non_tax_19_earn12,
				p_non_tax_20_earn	=> p_non_tax_20_earn12,
				p_non_taxable		=> p_non_taxable12);
                end if;
        end loop;
end data;
--------------------------------------------------------
function defined_balance_id(p_user_name in varchar2) return number
--------------------------------------------------------
is
        l_defined_balance_id    number;
begin
        select
                u.creator_id
        into    l_defined_balance_id
        from    ff_user_entities        u,
                ff_database_items       d
        where   d.user_name = p_user_name
        and     u.user_entity_id = d.user_entity_id
        and     u.legislation_code = 'KR'
        and     u.business_group_id is null
        and     u.creator_type = 'B';
        --
        return l_defined_balance_id;
end defined_balance_id;
-----------------------------------------------------------------------------------
-- Bug 7439803: 2008 YEA Ledger Statutory Updates
function get_globalvalue(p_glbvar in varchar2,p_process_date in date) return number
-----------------------------------------------------------------------------------
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
------------------------------------------------------------------------
begin
        g_defined_balance_id.taxable_mth        := defined_balance_id('TOTAL_TAXABLE_EARNINGS_ASG_MTD_MTH');
        g_defined_balance_id.taxable_bon        := defined_balance_id('TOTAL_TAXABLE_EARNINGS_ASG_MTD_BON');
        g_defined_balance_id.sp_irreg_bonus_mth := defined_balance_id('SP_IRREG_BONUS_ASG_MTD_MTH');
        g_defined_balance_id.sp_irreg_bonus_bon := defined_balance_id('SP_IRREG_BONUS_ASG_MTD_BON');
        g_defined_balance_id.itax_mth           := defined_balance_id('ITAX_ASG_MTD_MTH');
        g_defined_balance_id.itax_bon           := defined_balance_id('ITAX_ASG_MTD_BON');
        g_defined_balance_id.rtax_mth           := defined_balance_id('RTAX_ASG_MTD_MTH');
        g_defined_balance_id.rtax_bon           := defined_balance_id('RTAX_ASG_MTD_BON');
        g_defined_balance_id.stax_mth           := defined_balance_id('STAX_ASG_MTD_MTH');
        g_defined_balance_id.stax_bon           := defined_balance_id('STAX_ASG_MTD_BON');
        g_defined_balance_id.non_taxable_ovs_mth:= defined_balance_id('NON_TAXABLE_OVS_EARNINGS_ASG_MTD_MTH');
        g_defined_balance_id.non_taxable_ovs_bon:= defined_balance_id('NON_TAXABLE_OVS_EARNINGS_ASG_MTD_BON');
        g_defined_balance_id.non_taxable_ovt_mth:= defined_balance_id('NON_TAXABLE_OVT_EARNINGS_ASG_MTD_MTH');
        g_defined_balance_id.non_taxable_ovt_bon:= defined_balance_id('NON_TAXABLE_OVT_EARNINGS_ASG_MTD_BON');
        g_defined_balance_id.non_taxable_mth    := defined_balance_id('TOTAL_NON_TAXABLE_EARNINGS_ASG_MTD_MTH');
        g_defined_balance_id.non_taxable_bon    := defined_balance_id('TOTAL_NON_TAXABLE_EARNINGS_ASG_MTD_BON');
        -- 3546994
        g_defined_balance_id.fw_tax_break_mth   := defined_balance_id('FOREIGN_WORKER_TAX_BREAK_ASG_MTD_MTH');
        g_defined_balance_id.fw_tax_break_bon   := defined_balance_id('FOREIGN_WORKER_TAX_BREAK_ASG_MTD_BON');
	-- Bug 4322981
	g_defined_balance_id.np_prem_mth	:= defined_balance_id('NP_PREM_EE_ASG_MTD_MTH') ;
	g_defined_balance_id.np_prem_bon	:= defined_balance_id('NP_PREM_EE_ASG_MTD_BON') ;
	g_defined_balance_id.hi_prem_mth	:= defined_balance_id('HI_PREM_EE_ASG_MTD_MTH') ;
	g_defined_balance_id.hi_prem_bon	:= defined_balance_id('HI_PREM_EE_ASG_MTD_BON') ;
	g_defined_balance_id.ei_prem_mth	:= defined_balance_id('EI_PREM_ASG_MTD_MTH') ;
	g_defined_balance_id.ei_prem_bon	:= defined_balance_id('EI_PREM_ASG_MTD_BON') ;
	g_defined_balance_id.donation_mth	:= defined_balance_id('VOLUNTARY_DONATIONS_ASG_MTD_MTH') ;
	g_defined_balance_id.donation_bon	:= defined_balance_id('VOLUNTARY_DONATIONS_ASG_MTD_BON') ;
	-- End of 4322981
	-- Bug 5684037
	g_defined_balance_id.addl_non_tax_mth	:= defined_balance_id('ADDITIONAL_OTHER_NON_TAXABLE_EARNINGS_ASG_MTD_MTH') ;
	g_defined_balance_id.addl_non_tax_bon	:= defined_balance_id('ADDITIONAL_OTHER_NON_TAXABLE_EARNINGS_ASG_MTD_BON') ;
	-- End of Bug 5684037
        -- Bug 6470526: 2007 YEA Ledger Statutory Updates
        g_defined_balance_id.stck_pur_opt_exec_earn_mth := defined_balance_id('STOCK_PURCHASE_OPTION_EXECUTION_EARNING_ASG_MTD_MTH');
        g_defined_balance_id.stck_pur_opt_exec_earn_bon := defined_balance_id('STOCK_PURCHASE_OPTION_EXECUTION_EARNING_ASG_MTD_BON');
	g_defined_balance_id.research_payment_mth       := defined_balance_id('RESEARCH_PAYMENT_ASG_MTD_MTH');
	g_defined_balance_id.research_payment_bon       := defined_balance_id('RESEARCH_PAYMENT_ASG_MTD_BON');
        -- End of Bug 6470526
	--
	-- Bug 7439803: 2008 YEA Ledger Statutory Updates
	g_defined_balance_id.non_taxable_ovs_frgn_mth	:= defined_balance_id('NON_TAXABLE_OVS_FRGN_EARNINGS_ASG_MTD_MTH');
	g_defined_balance_id.non_taxable_ovs_frgn_bon	:= defined_balance_id('NON_TAXABLE_OVS_FRGN_EARNINGS_ASG_MTD_BON');
	g_defined_balance_id.birth_raise_allow_mth	:= defined_balance_id('BIRTH_RAISING_ALLOWANCE_ASG_MTD_MTH');
	g_defined_balance_id.birth_raise_allow_bon	:= defined_balance_id('BIRTH_RAISING_ALLOWANCE_ASG_MTD_BON');
	g_defined_balance_id.ltci_prem_mth		:= defined_balance_id('LTCI_PREM_EE_ASG_MTD_MTH') ;
	g_defined_balance_id.ltci_prem_bon		:= defined_balance_id('LTCI_PREM_EE_ASG_MTD_BON') ;
	-- End of Bug 7439803
	--
	-- Bug 8880364:2009 YEA Ledger Statutory Updates
	g_defined_balance_id.esop_with_drawn_mth	:= defined_balance_id('ESOP_WITHDRAWAL_EARNINGS_ASG_MTD_MTH') ;
	g_defined_balance_id.esop_with_drawn_bon	:= defined_balance_id('ESOP_WITHDRAWAL_EARNINGS_ASG_MTD_BON') ;
	g_defined_balance_id.rsrch_pay_ntax_H06_mth	:= defined_balance_id('NON_TAXABLE_EARN_H06_ASG_MTD_MTH') ;
	g_defined_balance_id.rsrch_pay_ntax_H06_bon	:= defined_balance_id('NON_TAXABLE_EARN_H06_ASG_MTD_BON') ;
	g_defined_balance_id.rsrch_pay_ntax_H07_mth	:= defined_balance_id('NON_TAXABLE_EARN_H07_ASG_MTD_MTH') ;
        g_defined_balance_id.rsrch_pay_ntax_H07_bon	:= defined_balance_id('NON_TAXABLE_EARN_H07_ASG_MTD_BON') ;
	g_defined_balance_id.rsrch_pay_ntax_H08_mth	:= defined_balance_id('NON_TAXABLE_EARN_H08_ASG_MTD_MTH') ;
	g_defined_balance_id.rsrch_pay_ntax_H08_bon	:= defined_balance_id('NON_TAXABLE_EARN_H08_ASG_MTD_BON') ;
	g_defined_balance_id.rsrch_pay_ntax_H09_mth	:= defined_balance_id('NON_TAXABLE_EARN_H09_ASG_MTD_MTH') ;
	g_defined_balance_id.rsrch_pay_ntax_H09_bon	:= defined_balance_id('NON_TAXABLE_EARN_H09_ASG_MTD_BON') ;
	g_defined_balance_id.rsrch_pay_ntax_H10_mth	:= defined_balance_id('NON_TAXABLE_EARN_H10_ASG_MTD_MTH') ;
        g_defined_balance_id.rsrch_pay_ntax_H10_bon	:= defined_balance_id('NON_TAXABLE_EARN_H10_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_G01_mth	:= defined_balance_id('NON_TAXABLE_EARN_G01_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_G01_bon	:= defined_balance_id('NON_TAXABLE_EARN_G01_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_H11_mth	:= defined_balance_id('NON_TAXABLE_EARN_H11_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_H11_bon	:= defined_balance_id('NON_TAXABLE_EARN_H11_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_H12_mth	:= defined_balance_id('NON_TAXABLE_EARN_H12_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_H12_bon	:= defined_balance_id('NON_TAXABLE_EARN_H12_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_H13_mth	:= defined_balance_id('NON_TAXABLE_EARN_H13_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_H13_bon	:= defined_balance_id('NON_TAXABLE_EARN_H13_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_H01_mth	:= defined_balance_id('NON_TAXABLE_EARN_H01_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_H01_bon	:= defined_balance_id('NON_TAXABLE_EARN_H01_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_K01_mth	:= defined_balance_id('NON_TAXABLE_EARN_K01_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_K01_bon	:= defined_balance_id('NON_TAXABLE_EARN_K01_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_S01_mth	:= defined_balance_id('NON_TAXABLE_EARN_S01_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_S01_bon	:= defined_balance_id('NON_TAXABLE_EARN_S01_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_Y01_bon	:= defined_balance_id('NON_TAXABLE_EARN_Y01_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_Y01_mth	:= defined_balance_id('NON_TAXABLE_EARN_Y01_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_Y02_bon	:= defined_balance_id('NON_TAXABLE_EARN_Y02_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_Y02_mth	:= defined_balance_id('NON_TAXABLE_EARN_Y02_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_Y03_bon	:= defined_balance_id('NON_TAXABLE_EARN_Y03_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_Y03_mth	:= defined_balance_id('NON_TAXABLE_EARN_Y03_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_Y20_bon	:= defined_balance_id('NON_TAXABLE_EARN_Y20_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_Y20_mth	:= defined_balance_id('NON_TAXABLE_EARN_Y20_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_Z01_bon	:= defined_balance_id('NON_TAXABLE_EARN_Z01_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_Z01_mth	:= defined_balance_id('NON_TAXABLE_EARN_Z01_ASG_MTD_MTH') ;
	g_defined_balance_id.non_tax_earn_T01_mth	:= defined_balance_id('NON_TAXABLE_EARN_T01_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_T01_bon	:= defined_balance_id('NON_TAXABLE_EARN_T01_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_H05_mth	:= defined_balance_id('NON_TAXABLE_EARN_H05_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_H05_bon	:= defined_balance_id('NON_TAXABLE_EARN_H05_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_I01_mth	:= defined_balance_id('NON_TAXABLE_EARN_I01_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_I01_bon	:= defined_balance_id('NON_TAXABLE_EARN_I01_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_M01_mth	:= defined_balance_id('NON_TAXABLE_EARN_M01_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_M01_bon	:= defined_balance_id('NON_TAXABLE_EARN_M01_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_M02_mth	:= defined_balance_id('NON_TAXABLE_EARN_M02_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_M02_bon	:= defined_balance_id('NON_TAXABLE_EARN_M02_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_M03_mth	:= defined_balance_id('NON_TAXABLE_EARN_M03_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_M03_bon	:= defined_balance_id('NON_TAXABLE_EARN_M03_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_frgn_M01_mth	:= defined_balance_id('NON_TAXABLE_EARN_FRGN_M01_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_frgn_M01_bon	:= defined_balance_id('NON_TAXABLE_EARN_FRGN_M01_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_frgn_M02_mth	:= defined_balance_id('NON_TAXABLE_EARN_FRGN_M02_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_frgn_M02_bon	:= defined_balance_id('NON_TAXABLE_EARN_FRGN_M02_ASG_MTD_BON') ;
	g_defined_balance_id.non_tax_earn_frgn_M03_mth	:= defined_balance_id('NON_TAXABLE_EARN_FRGN_M03_ASG_MTD_MTH') ;
        g_defined_balance_id.non_tax_earn_frgn_M03_bon	:= defined_balance_id('NON_TAXABLE_EARN_FRGN_M03_ASG_MTD_BON') ;


end pay_kr_paykrylg_pkg;

/
