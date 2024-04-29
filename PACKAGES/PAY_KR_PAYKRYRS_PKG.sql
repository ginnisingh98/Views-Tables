--------------------------------------------------------
--  DDL for Package PAY_KR_PAYKRYRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_PAYKRYRS_PKG" AUTHID CURRENT_USER as
/* $Header: paykryrs.pkh 120.8.12010000.5 2009/12/03 14:13:38 pnethaga ship $ */
------------------------------------------------------------------------
-- Bug 9079478
type t_varchar2_tbl is table of varchar2(255) index by binary_integer;
type t_number_tbl is table of number index by binary_integer;

type t_element is record(
	element_type_id		number,
	input_value_id_tbl	hr_entry.number_table,
	input_value_name_tbl	t_varchar2_tbl);

function get_balance_value( p_assignment_id    number,
                            p_year             number,
                            p_ytd_balance_name varchar2) return number;

procedure data(
	p_assignment_id			in number,
	p_year		                in number,
        ----------------Education Exp--------------------
	p_edu_p_count                   out nocopy number,
	p_edu_h_count                   out nocopy number,
	p_edu_u_count                   out nocopy number,
	p_edu_d_count                   out nocopy number,
	p_edu_exp_p 			out nocopy number,
	p_edu_exp_h 			out nocopy number,
	p_edu_exp_u 			out nocopy number,
	p_edu_exp_d 			out nocopy number,
	p_edu_exp_total                 out nocopy number,
        --------------- Housing Saving Total--------------
        p_hou_exp                       out nocopy number,
	p_resident_type			out nocopy varchar2, -- Bug 9079478
	--------------- Working Period ------------------
	p_emp_start_date             out nocopy date,
	p_period_end_date		out nocopy date,
        --------------- Special Exems --------------------
	p_pers_ins_prem			out nocopy number,
	p_dis_ins_prem			out nocopy number,
	p_gen_med_exp			out nocopy number,
	p_emp_aged_dis_med_exp 		out nocopy number,
	p_med_exp_card			out nocopy number, -- Bug 4336742
	p_hou_loan_repay		out nocopy number,
	p_lt_hou_int_repay		out nocopy number,
	p_lt_1500_won_limit		out nocopy number, -- Bug 9079478
	p_donations			out nocopy number,
	p_emp_educ			out nocopy number,
	p_sp_prem_hi_sub 		out nocopy number,
	p_sp_prem_ltci_sub 	        out nocopy number, -- Bug 7644535
	p_sp_prem_ei_sub        	out nocopy number,
        p_100p_donation			out nocopy number,
        p_50p_donation			out nocopy number,
        p_30p_donation			out nocopy number,
        p_15p_donation			out nocopy number,  	-- Bug 7508706
        p_10p_donation			out nocopy number,
        p_political_donation            out nocopy number,
	p_political_100p		out nocopy number,  -- Bug 9079478
        p_marr_reloc_funr_exem		out nocopy number,
        p_lt_hou_int_repay_gt_15        out nocopy number,
        --------------- Other Exems --------------------
        p_pers_pen_prem			out nocopy number,
        p_pers_pen_sav 			out nocopy number,
        p_inv_part_fin2			out nocopy number,
	p_inv_part_fin3			out nocopy number, -- Bug 9079478
        p_emp_crd_exp			out nocopy number,
	p_dep_crd_exp			out nocopy number,
        p_emp_stk_opt			out nocopy number,
       	p_tuition_giro			out nocopy number,
	p_cash_receipt			out nocopy number, -- Bug 4336742
        p_other_exem_np_prem            out nocopy number,
        p_other_exem_pen_prem           out nocopy number, -- Bug 6655323
	p_small_bus_install		out nocopy number, -- Bug 7508706
	p_company_related_exp		out nocopy number, -- Bug 7615517
	p_long_term_stck_fund_1yr	out nocopy number, -- Bug 7615517
	p_long_term_stck_fund_2yr	out nocopy number, -- Bug 7615517
	p_long_term_stck_fund_3yr	out nocopy number, -- Bug 7615517
	--------------- Tax Breaks -----------------------
        p_hou_loan_int_repay_break	out nocopy number,
        p_lt_stk_sav1			out nocopy number,
        p_lt_stk_sav2			out nocopy number,
        --------------- FW Info --------------------------
        p_emp_fw_exp                    out nocopy number,
        --------------- Ovs Tax Break --------------------
        p_ovs_tax_paid_fc		out nocopy number,
        p_ovs_tax_paid_lc		out nocopy number,
        p_ovs_country			out nocopy varchar2,
        p_ovs_paid_date			out nocopy varchar2,
        p_ovs_submit_date		out nocopy varchar2,
        p_ovs_location			out nocopy varchar2,
        p_ovs_period			out nocopy varchar2,
        p_ovs_title			out nocopy varchar2,
        --------------- FW Tax Break ---------------------
        p_immigration_purpose		out nocopy varchar2,
        p_fw_contract_date		out nocopy varchar2,
        p_fw_expiry_date		out nocopy varchar2,
        p_fw_application_date		out nocopy varchar2,
        p_fw_submit_date      		out nocopy varchar2,
        --------------- Prev Employer Info ---------------
        p_total_hi_prem			out nocopy number,
        p_total_ei_prem			out nocopy number,
        p_total_np_prem			out nocopy number,
        p_total_pen_prem		out nocopy number,        /* Bug 6655323 */
	p_total_sep_pension		out nocopy number,        /* Bug 7508706 */
	p_total_ltci_prem		out nocopy number,        /* Bug 7644535 */
        --------------- Balance Values -------------------
 	p_np_prem_main       		out nocopy number,
 	p_pen_prem_main       		out nocopy number,        /* Bug 6655323 */
        p_ei_prem_main			out nocopy number,
        p_hi_prem_main                  out nocopy number,
	p_ltci_prem_main		out nocopy number,       /* Bug 7644535 */
        p_corp_pension                  out nocopy number,
        p_emp_ins_included              out nocopy varchar2,
        p_emp_med_included              out nocopy varchar2,
        p_emp_edu_included              out nocopy varchar2,
        p_emp_card_included             out nocopy varchar2,
	p_ovs_earn			out nocopy number,      /* Bug 9079478 */
	p_smb_income_exem               out nocopy number
	);

 procedure EMP_EXPENSE_DETAILS (p_emp_assignment_id in number
				 ,p_year 	      in number
				 ,p_emp_ins_exp_nts   out nocopy number
				 ,p_emp_ins_exp_oth   out nocopy number
				 ,p_emp_med_exp_nts   out nocopy number
				 ,p_emp_med_exp_oth   out nocopy number
				 ,p_emp_edu_exp_nts   out nocopy number
				 ,p_emp_edu_exp_oth   out nocopy number
				 ,p_emp_card_exp_nts  out nocopy number
				 ,p_emp_card_exp_oth  out nocopy number
				 ,p_emp_cash_exp_nts  out nocopy number
				 ,p_emp_don_exp_nts   out nocopy number
				 ,p_emp_don_exp_oth   out nocopy number);

/* Bug 5856504 Modified parameter name in the function EMP_EXPENSE_DETAILS */
function EMP_EXPENSE_DETAILS (p_assignment_id in number
				 ,p_year 	      in number
				 ,p_emp_ins_exp_nts   out nocopy number
				 ,p_emp_ins_exp_oth   out nocopy number
				 ,p_emp_med_exp_nts   out nocopy number
				 ,p_emp_med_exp_oth   out nocopy number
				 ,p_emp_edu_exp_nts   out nocopy number
				 ,p_emp_edu_exp_oth   out nocopy number
				 ,p_emp_card_exp_nts  out nocopy number
				 ,p_emp_card_exp_oth  out nocopy number
				 ,p_emp_cash_exp_nts  out nocopy number
				 ,p_emp_don_exp_nts   out nocopy number
				 ,p_emp_don_exp_oth   out nocopy number) return number;

/* Bug 9079478 - Function to get the element type id and input values id of elements */
function element(p_element_name	in varchar2) return t_element;


end pay_kr_paykryrs_pkg;

/
