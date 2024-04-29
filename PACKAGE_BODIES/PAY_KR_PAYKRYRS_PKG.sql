--------------------------------------------------------
--  DDL for Package Body PAY_KR_PAYKRYRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_PAYKRYRS_PKG" as
/* $Header: paykryrs.pkb 120.20.12010000.13 2010/02/23 08:54:55 pnethaga ship $ */

-- Bug 9079478
g_tax		t_element;

------------------------- Education Exp Cursor----------------------------
 cursor per_asg_extra_info_educ_csr(p_assignment_id number, p_year number) is
 select aei_information3
        ,to_number(aei_information4)
   from per_assignment_extra_info
  where assignment_id = p_assignment_id
    and information_type = 'KR_YEA_DPNT_EDUC_TAX_EXEM_INFO'
    and to_date(aei_information1,'rrrr/mm/dd hh24:mi:ss')
        = to_date('31-12-'||to_char(p_year),'dd-mm-rrrr');

------------------------- Education Exp Cursor from 2009----------------------------
-- Bug 9341235
cursor per_asg_extra_info_educ_2009(p_assignment_id number, p_year number) is
select aei_information3
        ,sum(to_number(aei_information4))
   from per_assignment_extra_info
  where assignment_id = p_assignment_id  and
information_type = 'KR_YEA_DPNT_EDUC_TAX_EXEM_INFO'
    and to_date(aei_information1,'rrrr/mm/dd hh24:mi:ss')
        = to_date('31-12-'||to_char(p_year),'dd-mm-rrrr')
group by aei_information5,aei_information3;

------------------------- Housing Exp Cursor----------------------------
 cursor per_asg_extra_info_hou_csr(p_assignment_id number, p_year number) is
 select sum(to_number(aei_information3)) aei_information3
   from per_assignment_extra_info
  where assignment_id = p_assignment_id
    and aei_information2 <> 'HST2'
    and information_type = 'KR_YEA_HOU_EXP_TAX_EXEM_INFO'
    and to_date(aei_information1,'rrrr/mm/dd hh24:mi:ss')
        = to_date('31-12-'||to_char(p_year),'dd-mm-rrrr');

------------------------- Special Exem Cursor----------------------------
 cursor per_asg_extra_info_sp_csr(p_assignment_id number, p_year number) is
 select aei_information5   pers_ins_prem
        ,aei_information6  dis_ins_prem
        ,aei_information7  gen_med_exp
        ,aei_information8  l_med_exp_disabled
        ,aei_information9  l_med_exp_aged
        ,aei_information24 l_med_exp_emp
        ,aei_information15 hou_loan_repay
        ,aei_information17 lt_hou_int_repay
        ,nvl(aei_information18,0)+nvl(aei_information19,0)+nvl(aei_information20,0)
         +nvl(aei_information21,0)+nvl(aei_information22,0)+nvl(aei_information23,0) Donations
        ,aei_information10 emp_educ
        ,aei_information2 hi_prem
        ,aei_information3 ei_prem
        ,aei_information18 p_100p_donation
        ,aei_information19 l_political_since_040312
        ,aei_information20 l_political_before_040312
        ,aei_information23 p_50p_donation
        ,aei_information30 p_30p_donation
        ,aei_information22 p_15p_donation
        ,aei_information27 l_marriage_count
        ,aei_information29 l_reloc_count
        ,aei_information28 l_funeral_count
        ,aei_information26 l_lt_hou_int_repay_gt_15
   from per_assignment_extra_info
  where assignment_id = p_assignment_id
    and information_type = 'KR_YEA_SP_TAX_EXEM_INFO'
    and to_date(aei_information1,'rrrr/mm/dd hh24:mi:ss')
        = to_date('31-12-'||to_char(p_year),'dd-mm-rrrr');

-- Bug 4336742
------------------------- Special Exem2 Cursor----------------------------
 cursor per_asg_extra_info_sp2_csr(p_assignment_id number, p_year number) is
 select aei_information2   emp_occ_trg_exp,
 	aei_information3   med_exp_card,
        aei_information4   l_promotional_fund_don,
        aei_information5   l_religious_don,
        aei_information6   l_other_don,
	aei_information7   l_public_legal_don,		  -- Bug 7508706
	aei_information11  ltci_prem,                      -- Bug 7644535
	aei_information13  l_lt_1500_won_limit		   -- Bug 9079478
   from per_assignment_extra_info
  where assignment_id = p_assignment_id
    and information_type = 'KR_YEA_SP_TAX_EXEM_INFO2'
    and to_date(aei_information1,'rrrr/mm/dd hh24:mi:ss')
        = to_date('31-12-'||to_char(p_year),'dd-mm-rrrr');

-- End of 4336742

------------------------- Other Exemptions Cursor -----------------------
 cursor per_asg_extra_info_othr_csr(p_assignment_id number, p_year number) is
 select aei_information3 pers_pen_prem
        ,aei_information4  pers_pen_sav
        ,aei_information6  inv_part_fin2
	,aei_information25 inv_part_fin3  -- Bug 9079478
        ,aei_information7  emp_crd_exp
        ,aei_information9  dep_crd_exp
        ,aei_information8  emp_stk_opt
        ,aei_information10 emp_crd_drt_exp
        ,aei_information11 dep_crd_drt_exp   -- 4046680
        ,aei_information12 p_tuition_giro
	,aei_information13 cash_receipt	     -- Bug 4336742
        ,aei_information2  p_other_exem_np_prem
	,aei_information15 p_other_exem_pen_prem  -- Bug 6655323
        ,aei_information14 corporate_pension -- Bug 4764823
	,aei_information20 small_bus_install -- Bug 7508706
	,aei_information21 company_related_expense -- Bug 7615517
	,aei_information22 long_term_stck_fund_1yr -- Bug 7615517
	,aei_information23 long_term_stck_fund_2yr -- Bug 7615517
	,aei_information24 long_term_stck_fund_3yr -- Bug 7615517
	,nvl(to_number(aei_information26),0)      -- Bug 9079478
	,nvl(to_number(aei_information27),0)	   -- Bug 9079478
   from per_assignment_extra_info
  where assignment_id = p_assignment_id
    and information_type = 'KR_YEA_TAX_EXEM_INFO'
    and to_date(aei_information1,'rrrr/mm/dd hh24:mi:ss')
        = to_date('31-12-'||to_char(p_year),'dd-mm-rrrr');

------------------------- Tax Breaks Cursor ----------------------------
 cursor per_asg_extra_info_break_csr(p_assignment_id number, p_year number) is
 select aei_information2 hou_loan_int_repay
        ,aei_information4 lt_stk_sav1
        ,aei_information5 lt_stk_sav2
   from per_assignment_extra_info
  where assignment_id = p_assignment_id
    and information_type = 'KR_YEA_TAX_BREAK_INFO'
    and to_date(aei_information1,'rrrr/mm/dd hh24:mi:ss')
        = to_date('31-12-'||to_char(p_year),'dd-mm-rrrr');

------------------------- FW Info Cursor -------------------------------
 cursor per_asg_extra_info_fw_csr(p_assignment_id number, p_year number) is
 select nvl(aei_information2,0) + nvl(aei_information3,0)
   from per_assignment_extra_info
  where assignment_id = p_assignment_id
    and information_type = 'KR_YEA_FW_TAX_EXEM_INFO'
    and to_date(aei_information1,'rrrr/mm/dd hh24:mi:ss')
        = to_date('31-12-'||to_char(p_year),'dd-mm-rrrr');

------------------------- Overseas Tax Cursor --------------------------
 cursor per_asg_extra_info_ovs_csr(p_assignment_id number, p_year number) is
 select aei_information7  p_ovs_tax_paid_fc,
        aei_information8  p_ovs_tax_paid_lc,
	hr_general.decode_territory(aei_information2) p_ovs_country,
	to_char(fnd_date.canonical_to_date(aei_information1) , 'YYYY.MM.DD') p_ovs_paid_date,
	to_char(fnd_date.canonical_to_date(aei_information10), 'YYYY.MM.DD') p_ovs_submit_date,
	aei_information11 p_ovs_location,
	aei_information12 p_ovs_period,
	aei_information13 p_ovs_title
   from per_assignment_extra_info
  where assignment_id = p_assignment_id
    and information_type = 'KR_YEA_OVS_TAX_BREAK_INFO'
    and to_char(fnd_date.canonical_to_date(aei_information1), 'YYYY')= p_year;

------------------------- FW Tax Break Cursor --------------------------
 cursor csr_fw_tax_break(p_assignment_id number, p_year number) is
 select aei_information1     p_immigration_purpose,
        to_char(fnd_date.canonical_to_date(aei_information2) , 'YYYY.MM.DD') p_fw_contract_date,
        to_char(fnd_date.canonical_to_date(aei_information3) , 'YYYY.MM.DD') p_fw_expiry_date,
        to_char(fnd_date.canonical_to_date(aei_information5) , 'YYYY.MM.DD') p_fw_application_date,
        to_char(fnd_date.canonical_to_date(aei_information6) , 'YYYY.MM.DD') p_fw_submit_date
   from per_assignment_extra_info
  where assignment_id = p_assignment_id
    and information_type = 'KR_YEA_FW_TAX_BREAK_INFO'
    and p_year between to_char(fnd_date.canonical_to_date(aei_information2), 'YYYY')
	           and to_char(fnd_date.canonical_to_date(aei_information3), 'YYYY');

------------------------- Prev Employer Cursor --------------------------
 cursor csr_prev_employer_info(p_assignment_id number, p_year number) is
 select sum(nvl(aei_information10,0)) p_total_hi_prem,
        sum(nvl(aei_information11,0)) p_total_ei_prem,
        sum(nvl(aei_information12,0)) p_total_np_prem,
        sum(nvl(aei_information16,0)) p_total_pen_prem,       /* Bug 6655323 */
	sum(nvl(aei_information19,0)) p_total_sep_pension,     /* Bug 7508706 */
	sum(nvl(aei_information18,0)) p_total_ltci_prem       /* Bug 7644535 */
   from per_assignment_extra_info
  where assignment_id = p_assignment_id
    and information_type = 'KR_YEA_PREV_ER_INFO'
    and to_char(fnd_date.canonical_to_date(aei_information1), 'YYYY')= p_year;

------------------------- Dependent Expense Information ------------------
-- Bug 5726158
 cursor csr_dpnt_expense_info(p_assignment_id number, p_effective_date date) is
 select sum(nvl(cei_information1,0) + nvl(cei_information2,0)) l_dpnt_pers_ins,
        sum(nvl(cei_information10,0) + nvl(cei_information11,0)) l_dpnt_dis_ins,
        sum(nvl(cei_information7,0) + nvl(cei_information8,0)) l_dpnt_cards_exp,
        sum(nvl(cei_information9,0)) l_dpnt_cash_exp
   from pay_kr_cont_details_v        pkc,
        per_contact_extra_info_f     cei            -- Bug 5879106
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
							pkc.cont_information11,   -- Bug 7661820
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

-------------------Element Input Values------------------------------

cursor csr_ee (p_element_type_id number,p_assignment_id number,p_year number) is
		select
			peev.input_value_id,
			peev.screen_entry_value
		from	pay_element_entry_values_f  peev,
			pay_element_entries_f	    pee,
			pay_element_links_f	    pel
		where	pel.element_type_id = p_element_type_id
		and	p_year
			between to_number(to_char(pel.effective_start_date,'YYYY'))
			and to_number(to_char(pel.effective_end_date,'YYYY'))
		and	pee.element_link_id = pel.element_link_id
		and	pee.assignment_id = p_assignment_id
		and	nvl(pee.entry_type, 'E') = 'E'
		and	p_year	between
			to_number(to_char(pee.effective_start_date,'YYYY'))
			and to_number(to_char(pee.effective_end_date,'YYYY'))
		and	peev.element_entry_id = pee.element_entry_id
		and	peev.effective_start_date = pee.effective_start_date
		and	peev.effective_end_date = pee.effective_end_date
			order by peev.input_value_id;
---------------------------------------------------------------------------------
cursor csr_get_join_leave_info (p_assignment_id number, p_effective_date date) is
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
-----------------------------------------------------------------------
	--
	cursor csr_get_smb_eligibility_flag(p_business_group_id in number) is
		select
        		nvl(hoi.org_information1,'N')
		from 	hr_all_organization_units hou,
        		hr_organization_information hoi
		where 	hoi.organization_id = hou.organization_id
		and 	hou.business_group_id = p_business_group_id
		and 	hoi.org_information_context = 'KR_YEA_ER_SMB_ELIGIBILITY_INFO';
-- End of Bug 9079478
------------------------------------------------------------------------------------
cursor csr_wkpd (p_assignment_id number,p_year number) is
		select
			per.person_id,                  -- bug 6012258
			pds.date_start,
			pds.actual_termination_date
		from	per_people_f	        per,
			per_periods_of_service	pds,
			per_assignments_f	asg
		where
			asg.assignment_id = p_assignment_id
		and	p_year	between
			to_number(to_char(asg.effective_start_date,'YYYY'))
			and to_number(to_char(asg.effective_end_date,'YYYY'))
		and	pds.period_of_service_id = asg.period_of_service_id
		and	per.person_id = pds.person_id
		and	p_year between
		        to_number(to_char(per.effective_start_date,'YYYY'))
			and to_number(to_char(per.effective_end_date,'YYYY'));
l_rec	csr_wkpd%ROWTYPE;
---------------------- Function to get the YTD balance -----------------------

function get_balance_value( p_assignment_id    number,
                            p_year             number,
                            p_ytd_balance_name varchar2) return number
is

    cursor csr_defined_bal_id is
    select pdb.defined_balance_id
    from pay_balance_types pbt,
	 pay_balance_dimensions dim,
	 pay_defined_balances pdb
    where pbt.legislation_code   = 'KR'
    and pbt.balance_name         = p_ytd_balance_name
    and dim.legislation_code     = 'KR'
    and dim.dimension_name       = '_ASG_YTD'
    and pdb.legislation_code     = 'KR'
    and pdb.BALANCE_DIMENSION_ID = dim.BALANCE_DIMENSION_ID
    and pdb.BALANCE_TYPE_ID      = pbt.balance_type_id;

    l_dim_id            number;
    l_year_end_date     date;
    l_bal_value         number;

begin
    l_dim_id         := null;
    l_bal_value      := null;
    l_year_end_date  := to_date('3112'||to_char(p_year),'ddmmrrrr');

    open csr_defined_bal_id;
    fetch csr_defined_bal_id into l_dim_id;
    close csr_defined_bal_id;
  begin
  -- bug 9079478
    l_bal_value := pay_balance_pkg.get_value(l_dim_id,
                                             p_assignment_id,
                                             l_year_end_date);
   exception
   when others then
   l_bal_value := 0;
   end;

    return l_bal_value;
end get_balance_value;

-- Bug 9079478
----------------------------------------------------------------------
function element(p_element_name	in varchar2) return t_element

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
----------------------------------------------------------------------

--------------------------------------------------------------------------------
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
	---------------Working Period---------------------
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
	p_15p_donation			out nocopy number,  -- Bug 7508706
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
        p_hi_prem_main			out nocopy number,
	p_ltci_prem_main		out nocopy number,       /* Bug 7644535 */
        p_corp_pension                  out nocopy number,          --4764823
        p_emp_ins_included              out nocopy varchar2,
        p_emp_med_included              out nocopy varchar2,
        p_emp_edu_included              out nocopy varchar2,
        p_emp_card_included             out nocopy varchar2,
	p_ovs_earn			out nocopy number,       /* Bug 9079478 */
	p_smb_income_exem               out nocopy number
	)
is
    l_edu_p_count         number;
    l_edu_h_count         number;
    l_edu_u_count         number;
    l_edu_d_count         number;
    l_edu_type            varchar2(5);
    l_edu_exp             number;
    l_emp_occ_trg_exp	  number ; -- Bug 4336742
    l_emp_crd_drt_exp     number;
    l_dep_crd_drt_exp     number;   -- 4046680
    l_marriage_count      number;
    l_reloc_count	  number;
    l_funeral_count	  number;
    l_med_exp_disabled    number;
    l_med_exp_aged	  number;
    l_med_exp_emp    	  number;
    l_political_since_040312	 number;
    l_political_before_040312	 number;
    l_dummy                      number;
    l_corp_pension               number;
    l_corp_pension_bal           number;
    l_promotional_fund_don       number;
    l_religious_don              number;
    l_other_don                  number;
    l_15p_donation               number;  -- Bug 7508706
    -- Bug 5726158
    l_dpnt_pers_ins		 number;
    l_dpnt_dis_ins		 number;
    l_dpnt_cards_exp		 number;
    l_dpnt_cash_exp		 number;
    l_public_legal_don		 number;  -- Bug 7508706
    l_tax_law_don		 number;  -- Bug 7508706
    -- Bug 9079478
    l_non_resident_flag          varchar2(10);
    l_input_value_id_tbl	 t_number_tbl;
    l_screen_entry_value_tbl	 t_varchar2_tbl;
    l_ovs_earn_bal		 number;
    l_period_start_date          date;
    l_er_smb_prev_earn           number;
    l_er_smb_cur_earn		 number;
    p_smb_eligibility_flag	 varchar2(1);
    p_cur_smb_days_worked        number;
    p_prev_smb_days_worked       number;
    p_emp_join_prev_year         varchar2(1);
    p_emp_leave_cur_year         varchar2(1);
    l_business_group_id          number;

begin
----------------------------- Education Expenses ---------------------------
    l_edu_p_count := 0;
    l_edu_h_count := 0;
    l_edu_u_count := 0;
    l_edu_d_count := 0;
    p_edu_exp_p   := null;
    p_edu_exp_h   := null;
    p_edu_exp_u   := null;
    p_edu_exp_d   := null;
    p_hou_exp     := null;

    if (p_year < 2009) then
    open per_asg_extra_info_educ_csr(p_assignment_id, p_year);

    loop

	fetch per_asg_extra_info_educ_csr
	into l_edu_type, l_edu_exp;

	exit when per_asg_extra_info_educ_csr%NOTFOUND;

	if l_edu_type = 'P' then
	    p_edu_exp_p := nvl(p_edu_exp_p,0) + l_edu_exp;
	    l_edu_p_count := l_edu_p_count + 1;
	elsif l_edu_type = 'H' then
	    p_edu_exp_h := nvl(p_edu_exp_h,0) + l_edu_exp;
	    l_edu_h_count := l_edu_h_count + 1;
	elsif l_edu_type = 'U' then
	    p_edu_exp_u := nvl(p_edu_exp_u,0) + l_edu_exp;
	    l_edu_u_count := l_edu_u_count + 1;
	elsif l_edu_type = 'D' then
	    p_edu_exp_d := nvl(p_edu_exp_d,0) + l_edu_exp;
	    l_edu_d_count := l_edu_d_count + 1;
	end if;

    end loop;
        if per_asg_extra_info_educ_csr%ISOPEN then
        close per_asg_extra_info_educ_csr;
	end if;
  else
       -- Bug 9341235
        open per_asg_extra_info_educ_2009(p_assignment_id, p_year);
        loop
	fetch per_asg_extra_info_educ_2009
	into l_edu_type, l_edu_exp;

	exit when per_asg_extra_info_educ_2009%NOTFOUND;

	if l_edu_type = 'P' then
	    p_edu_exp_p := nvl(p_edu_exp_p,0) + l_edu_exp;
	    l_edu_p_count := l_edu_p_count + 1;
	elsif l_edu_type = 'H' then
	    p_edu_exp_h := nvl(p_edu_exp_h,0) + l_edu_exp;
	    l_edu_h_count := l_edu_h_count + 1;
	elsif l_edu_type = 'U' then
	    p_edu_exp_u := nvl(p_edu_exp_u,0) + l_edu_exp;
	    l_edu_u_count := l_edu_u_count + 1;
	elsif l_edu_type = 'D' then
	    p_edu_exp_d := nvl(p_edu_exp_d,0) + l_edu_exp;
	    l_edu_d_count := l_edu_d_count + 1;
	end if;

    end loop;

        if per_asg_extra_info_educ_2009%ISOPEN then
        close per_asg_extra_info_educ_2009;
	end if;
   end if;
-- End of Bug 9341235

    p_edu_p_count := l_edu_p_count;
    p_edu_h_count := l_edu_h_count;
    p_edu_u_count := l_edu_u_count;
    p_edu_d_count := l_edu_d_count;



---------------------------- Housing Saving Total ----------------------------
    open per_asg_extra_info_hou_csr(p_assignment_id, p_year);
    fetch per_asg_extra_info_hou_csr into p_hou_exp;
    close per_asg_extra_info_hou_csr;

---------------------------- Special Exems -----------------------------------
    open per_asg_extra_info_sp_csr(p_assignment_id, p_year);
    fetch per_asg_extra_info_sp_csr
    into p_pers_ins_prem
	,p_dis_ins_prem
	,p_gen_med_exp
	,l_med_exp_disabled
	,l_med_exp_aged
	,l_med_exp_emp
	,p_hou_loan_repay
	,p_lt_hou_int_repay
	,p_donations
	,p_emp_educ
	,p_sp_prem_hi_sub
	,p_sp_prem_ei_sub
	,p_100p_donation
	,l_political_since_040312
	,l_political_before_040312
	,l_tax_law_don		-- Bug 7508706
	,p_30p_donation
	,l_15p_donation		-- Bug 7508706
	,l_marriage_count
	,l_reloc_count
	,l_funeral_count
	,p_lt_hou_int_repay_gt_15;

    close per_asg_extra_info_sp_csr;

    -- Bug 5726158
    open csr_dpnt_expense_info(p_assignment_id, to_date('3112'||to_char(p_year), 'DDMMYYYY'));
    fetch csr_dpnt_expense_info into l_dpnt_pers_ins,
				     l_dpnt_dis_ins,
				     l_dpnt_cards_exp,
				     l_dpnt_cash_exp;
    close csr_dpnt_expense_info;
    p_pers_ins_prem := nvl(p_pers_ins_prem,0) + nvl(l_dpnt_pers_ins,0);
    p_dis_ins_prem := nvl(p_dis_ins_prem,0) + nvl(l_dpnt_dis_ins,0);

    -- End of Bug 5726158


    -- Bug 4336742
    open per_asg_extra_info_sp2_csr(p_assignment_id, p_year) ;
    fetch per_asg_extra_info_sp2_csr into l_emp_occ_trg_exp,
                                          p_med_exp_card,
                                          l_promotional_fund_don,
                                          l_religious_don,
                                          l_other_don,
					  l_public_legal_don,  	-- Bug 7508706
					  p_sp_prem_ltci_sub,   -- Bug 7644535
					  p_lt_1500_won_limit;  -- Bug 9079478
    close per_asg_extra_info_sp2_csr ;

    if p_emp_educ is null and l_emp_occ_trg_exp is null then
    	p_emp_educ := null ;
    else
    	p_emp_educ := nvl(p_emp_educ, 0) + nvl(l_emp_occ_trg_exp, 0) ;
    end if ;

    -- End of 4336742

    p_edu_exp_total     := nvl(p_emp_educ,0) +
                           nvl(p_edu_exp_p,0) +
		           nvl(p_edu_exp_h,0) +
		           nvl(p_edu_exp_u,0) +
		           nvl(p_edu_exp_d,0);

    -- sum should be null if all values are null
    if (p_emp_educ  is null and
    	p_edu_exp_p is null and
    	p_edu_exp_h is null and
    	p_edu_exp_u is null and
    	p_edu_exp_u is null) then
    	    p_edu_exp_total := null;
    end if;

    p_emp_aged_dis_med_exp := nvl(l_med_exp_disabled,0 )+
    			      nvl(l_med_exp_aged    ,0) +
    			      nvl(l_med_exp_emp     ,0) ;


    -- sum should be null if all values are null
    if (l_med_exp_disabled is null and
    	l_med_exp_aged     is null and
    	l_med_exp_emp      is null) then
    	    p_emp_aged_dis_med_exp := null;
    end if;



    p_marr_reloc_funr_exem := null;


    p_marr_reloc_funr_exem := 1000000 * ( nvl(l_marriage_count,0) +
    					  nvl(l_reloc_count   ,0) +
    					  nvl(l_funeral_count ,0) );
    -- sum should be null if all values are null
    if (l_marriage_count is null and
    	l_reloc_count    is null and
    	l_funeral_count  is null) then
    	    p_marr_reloc_funr_exem := null;
    end if;

    -- calculate political donation
    p_political_donation  := Least(100000, nvl(l_political_since_040312,0) );
    p_political_100p      := nvl(l_political_before_040312,0);     -- Bug 9079478
    l_dummy               := nvl(l_promotional_fund_don,0) +
                             nvl(p_100p_donation,0) +
                             nvl(l_political_since_040312,0 ) +
                             nvl(l_political_before_040312,0) - p_political_donation;

    -- sum should be null if all values are null
   if( l_promotional_fund_don    is null and
       p_100p_donation           is null and
       l_political_since_040312  is null and
       l_political_before_040312 is null) then
           p_100p_donation := null;
   else
           p_100p_donation := l_dummy;
   end if;

   -- calculate 10 percent donations
   p_10p_donation := l_religious_don;
   p_15p_donation := l_15p_donation;

   -- Bug 7508706
   l_dummy := nvl(l_public_legal_don,0) + nvl(l_tax_law_don,0);
   if (l_public_legal_don is null and l_tax_law_don is null) then
	p_50p_donation := null;
   else
	p_50p_donation := l_dummy;
   end if;
   --
   if l_political_since_040312 is null then
      p_political_donation  :=  null;
   end if;

---------------------------- Other Exems -----------------------------------
    open per_asg_extra_info_othr_csr(p_assignment_id, p_year);
    fetch per_asg_extra_info_othr_csr
    into p_pers_pen_prem
	,p_pers_pen_sav
	,p_inv_part_fin2
	,p_inv_part_fin3  -- Bug 9079478
	,p_emp_crd_exp
	,p_dep_crd_exp
	,p_emp_stk_opt
	,l_emp_crd_drt_exp
	,l_dep_crd_drt_exp
	,p_tuition_giro
	,p_cash_receipt  -- Bug 4336742
	,p_other_exem_np_prem
	,p_other_exem_pen_prem  -- Bug 6655323
        ,l_corp_pension -- Bug 4764823
	,p_small_bus_install -- Bug 7508706
	,p_company_related_exp -- Bug 7615517
	,p_long_term_stck_fund_1yr -- Bug 7615517
	,p_long_term_stck_fund_2yr -- Bug 7615517
	,p_long_term_stck_fund_3yr -- Bug 7615517
	,p_cur_smb_days_worked     -- Bug 9079478
	,p_prev_smb_days_worked;   -- Bug 9079478

    close per_asg_extra_info_othr_csr;

    -- 4046680: emp credit/direct exp
    l_dummy        := nvl(p_emp_crd_exp,0) + nvl(l_emp_crd_drt_exp,0);
    if ( p_emp_crd_exp     is null and
         l_emp_crd_drt_exp is null ) then
              p_emp_crd_exp   := null;
    else
              p_emp_crd_exp   := l_dummy;
    end if;

    -- 4046680: dep credit/direct exp
    l_dummy        := nvl(p_dep_crd_exp,0) + nvl(l_dep_crd_drt_exp,0);
        if ( p_dep_crd_exp     is null and
             l_dep_crd_drt_exp is null ) then
                  p_dep_crd_exp   := null;
        else
                  p_dep_crd_exp   := l_dummy;
    end if;

    -- Bug 5726158
    p_dep_crd_exp := nvl(p_dep_crd_exp,0)+ nvl(l_dpnt_cards_exp,0);
    p_cash_receipt := nvl(p_cash_receipt,0) + nvl(l_dpnt_cash_exp,0);
    -- End of Bug 5726158

---------------------------- Tax Breaks  -----------------------------------
    open per_asg_extra_info_break_csr(p_assignment_id, p_year);
    fetch per_asg_extra_info_break_csr
    into p_hou_loan_int_repay_break
    	,p_lt_stk_sav1
    	,p_lt_stk_sav2;

    close per_asg_extra_info_break_csr;

---------------------------- FW Info  --------------------------------------
    open per_asg_extra_info_fw_csr(p_assignment_id, p_year);
    fetch per_asg_extra_info_fw_csr into p_emp_fw_exp;

    close per_asg_extra_info_fw_csr; ---#### no more used

---------------------------- Ovs Tax Break ---------------------------------
    open per_asg_extra_info_ovs_csr(p_assignment_id, p_year);
    fetch per_asg_extra_info_ovs_csr
    into p_ovs_tax_paid_fc,
    	 p_ovs_tax_paid_lc,
    	 p_ovs_country,
    	 p_ovs_paid_date,
    	 p_ovs_submit_date,
    	 p_ovs_location,
    	 p_ovs_period,
    	 p_ovs_title;

    close per_asg_extra_info_ovs_csr;

---------------------------- FW Tax Break ---------------------------------
    open csr_fw_tax_break(p_assignment_id, p_year);
    fetch csr_fw_tax_break
    into p_immigration_purpose,
    	 p_fw_contract_date,
    	 p_fw_expiry_date,
    	 p_fw_application_date,
    	 p_fw_submit_date ;

    close csr_fw_tax_break;

---------------------------- Prev Employer Info ---------------------------
    open csr_prev_employer_info(p_assignment_id, p_year);
    fetch csr_prev_employer_info
    into p_total_hi_prem,
    	 p_total_ei_prem,
    	 p_total_np_prem,
	 p_total_pen_prem,    /* Bug 6655323 */
	 p_total_sep_pension, /* bug 7508706 */
	  p_total_ltci_prem;   /* Bug 7644535 */

    close csr_prev_employer_info;

---------------------------- Get YTD Balances ---------------------------
    -- Bug 4446381: Added nvl checks, so that even if no values for premium fields
    --		    are entered in the YEA Information form, the balance values
    --		    show up in the reclaim sheet
    --
    p_np_prem_main  	:= nvl(get_balance_value(p_assignment_id, p_year,'NP_PREM_EE'), 0)
                           + nvl(p_other_exem_np_prem, 0) ;
    -- Sum is null if all components are null
    if get_balance_value(p_assignment_id, p_year,'NP_PREM_EE') is null
      and p_other_exem_np_prem is null
      then
      	p_np_prem_main := null ;
    end if ;
    -- Bug 6655323
    p_pen_prem_main  := nvl(get_balance_value(p_assignment_id, p_year,'Pension Premium'), 0)
                           + nvl(p_other_exem_pen_prem, 0);
    -- Sum is null if all components are null
    if get_balance_value(p_assignment_id, p_year,'Pension Premium') is null
      and p_other_exem_pen_prem is null
      then
      	p_pen_prem_main := null ;
    end if ;
    --
    p_ei_prem_main	:= nvl(get_balance_value(p_assignment_id, p_year,'EI_PREM'), 0)
                           + nvl(p_sp_prem_ei_sub, 0) ;
    -- Sum is null if all components are null
    if get_balance_value(p_assignment_id, p_year,'EI_PREM') is null
      and p_sp_prem_ei_sub is null
      then
      	p_ei_prem_main := null ;
    end if ;
      -- Bug 7644535
    p_ltci_prem_main	:= nvl(get_balance_value(p_assignment_id, p_year,'LTCI_PREM_EE'), 0)
                           + nvl(p_sp_prem_ltci_sub, 0) ;
    -- Sum is null if all components are null
    if get_balance_value(p_assignment_id, p_year,'LTCI_PREM_EE') is null
      and p_sp_prem_ltci_sub is null
      then
      	p_ltci_prem_main := null ;
    end if ;

    p_hi_prem_main	:= nvl(get_balance_value(p_assignment_id, p_year,'HI_PREM_EE'), 0)
                           + nvl(p_sp_prem_hi_sub, 0) ;
    -- Sum is null if all components are null
    if get_balance_value(p_assignment_id, p_year,'HI_PREM_EE') is null
      and p_sp_prem_hi_sub is null
      then
      	p_hi_prem_main := null ;
    end if ;

    -- 4863731
    l_corp_pension_bal := get_balance_value(p_assignment_id, p_year,'CORPORATE_PENSION');
    p_corp_pension     := nvl(l_corp_pension_bal,0) + nvl(l_corp_pension,0);
    if l_corp_pension_bal is null and
       l_corp_pension     is null then

       p_corp_pension := null;

    end if;
      -- End of 4446381
    -- Bug 9079478
    l_ovs_earn_bal := get_balance_value(p_assignment_id, p_year,'Overseas Earnings');
    p_ovs_earn     := nvl(l_ovs_earn_bal, 0);
   l_er_smb_prev_earn  := nvl(get_balance_value(p_assignment_id, p_year-1,'EARN_FOR_ER_SMB_EXEM'),0);
   l_er_smb_cur_earn := nvl(get_balance_value(p_assignment_id, p_year,'EARN_FOR_ER_SMB_EXEM'),0);


------------------- Set Ins,Med,Edu,Card flags -------------------
    p_emp_ins_included  := null;
    p_emp_med_included  := null;
    p_emp_edu_included  := null;
    p_emp_card_included := null;

    -- ins included
    if p_pers_ins_prem  > 0 or p_dis_ins_prem > 0  then
        p_emp_ins_included := 'O';
    end if;

    -- med included
    if l_med_exp_emp > 0 then
        p_emp_med_included := 'O';
    end if;

    -- edu included
    if p_emp_educ > 0 then
        p_emp_edu_included := 'O';
    end if;

    -- card included
    if p_emp_crd_exp > 0 or p_tuition_giro > 0 or p_cash_receipt > 0 then
        p_emp_card_included := 'O';
    end if;

-- Bug 9079478
g_tax := element('TAX');
open csr_ee(g_tax.element_type_id,p_assignment_id, p_year);
   fetch csr_ee bulk collect into l_input_value_id_tbl, l_screen_entry_value_tbl;
close csr_ee;
   l_non_resident_flag := nvl(l_screen_entry_value_tbl(1), 'N');

if l_non_resident_flag = 'Y' then
		p_resident_type := 'N';
	else
		p_resident_type := 'R';
end if;
open csr_wkpd (p_assignment_id, p_year);
fetch csr_wkpd into l_rec;
close csr_wkpd;

	l_period_start_date	:= to_date('0101'||to_char(p_year),'ddmmrrrr');
	p_period_end_date	:= add_months(l_period_start_date, 12) - 1;
	l_period_start_date	:= greatest(l_period_start_date, l_rec.date_start);
	--
	p_emp_start_date        := l_period_start_date;
	if l_rec.actual_termination_date < p_period_end_date then
		p_period_end_date := l_rec.actual_termination_date;
	end if;

 open csr_get_join_leave_info(p_assignment_id, to_date('3112'||to_char(p_year), 'DDMMYYYY'));
	fetch csr_get_join_leave_info into p_emp_join_prev_year, p_emp_leave_cur_year,l_business_group_id;
	close csr_get_join_leave_info;

open csr_get_smb_eligibility_flag(l_business_group_id);
	fetch csr_get_smb_eligibility_flag into p_smb_eligibility_flag;
	if csr_get_smb_eligibility_flag%NOTFOUND then
	   p_smb_eligibility_flag := 'N';
	end if;
p_smb_income_exem := 0;
if (p_smb_eligibility_flag = 'Y') then

	   if (nvl(p_cur_smb_days_worked,0) = 0
				or nvl(p_prev_smb_days_worked,0) = 0
				or p_emp_join_prev_year = 'X'
				or p_emp_leave_cur_year = 'X') then
				p_smb_income_exem := 0;
	  else
	  if p_emp_join_prev_year = 'Y' then
		  l_er_smb_cur_earn  := l_er_smb_cur_earn
					* (p_prev_smb_days_worked / p_cur_smb_days_worked);
	  end if;
	  if p_emp_leave_cur_year = 'Y' then
	   l_er_smb_prev_earn := l_er_smb_prev_earn
				* (p_cur_smb_days_worked / p_prev_smb_days_worked);
	  end if;
	--
	p_smb_income_exem := greatest(trunc(l_er_smb_prev_earn - l_er_smb_cur_earn),0) ;
	end if;
end if;
 -- End of Bug 9079478
end data;

---------------Prodecure to fetch Employee Expense Amounts------------------
-- Bug # 5446051
procedure EMP_EXPENSE_DETAILS   (p_emp_assignment_id in number
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
				,p_emp_don_exp_oth   out nocopy number)
is

   cursor sp_tax_exem_info is
   select (nvl(aei_information2,0) + nvl(aei_information3,0) +
           nvl(aei_information5,0) + nvl(aei_information6,0))   --Insurance total -- Bug 5726158
          ,nvl(aei_information24,0) 		                --Medical Exem Total
  	  ,nvl(aei_information10,0)		                --Education Exem Total1
	  ,(nvl(aei_information18,0)
           + nvl(aei_information19,0)
           + nvl(aei_information20,0)
           + nvl(aei_information22,0)
           + nvl(aei_information23,0)
           + nvl(aei_information30,0))  	                  --Donation Total1
	  ,nvl(aei_information19,0)			          --Political_donation
	  ,nvl(aei_information1,fnd_date.date_to_canonical(to_date('31-12-'||to_char(p_year),'dd-mm-rrrr')))	--Effective Date
     from per_assignment_extra_info
    where ASSIGNMENT_ID=p_emp_assignment_id
      and information_type = 'KR_YEA_SP_TAX_EXEM_INFO'
      and to_char(fnd_date.canonical_to_date(aei_information1), 'YYYY') = p_year;

   cursor sp_tax_exem_info2 is
   select nvl(aei_information2,0)			--Education Exem Total2
          ,(nvl(aei_information4,0)
            +nvl(aei_information5,0)
            +nvl(aei_information6,0)
	    +nvl(aei_information7,0))		        -- Bug 7508706: Donation Total2
	  ,nvl(aei_information8,0)			-- Bug 7508706: Total Dependent Donation Expense
	  ,nvl(aei_information11, 0)                    -- Bug 7644535: LTCI premium
	  ,nvl(aei_information10,'N')                   -- Bug 9381801: Medical Total and Details Flag
     from per_assignment_extra_info
    where ASSIGNMENT_ID=p_emp_assignment_id
      and information_type = 'KR_YEA_SP_TAX_EXEM_INFO2'
      and to_char(fnd_date.canonical_to_date(aei_information1), 'YYYY') = p_year;

   cursor tax_exem_info is
   select (nvl(aei_information10,0)
           +nvl(aei_information7,0)
           +nvl(aei_information12,0))		 	--Card Total
          ,nvl(aei_information13,0)			--Cash Total
     from per_assignment_extra_info
    where ASSIGNMENT_ID=p_emp_assignment_id
      and information_type = 'KR_YEA_TAX_EXEM_INFO'
      and to_char(fnd_date.canonical_to_date(aei_information1), 'YYYY') = p_year;

   cursor csr_get_ins_bal(p_balance_name in varchar2,
			  p_dimension_name in varchar2) is
   select defined_balance_id
     from pay_defined_balances   pdb
          ,pay_balance_types      pbt
          ,pay_balance_dimensions pbd
    where pbt.balance_type_id = pdb.balance_type_id
      and pdb.balance_dimension_id = pbd.balance_dimension_id
      and pbt.balance_name = p_balance_name
      and pbd.dimension_name = p_dimension_name
      and pdb.legislation_code = 'KR';

   cursor emp_exp is
   select aei_information2					--Medical NTS
          ,aei_information3					--Education NTS
          ,aei_information4					--Cards NTS
          ,aei_information5					--Donation NTS
          ,aei_information6                                     --Insurance NTS -- Bug 5726158
     from per_assignment_extra_info
    where ASSIGNMENT_ID=p_emp_assignment_id
      and information_type = 'KR_YEA_EMP_EXPENSE_DETAILS'
      and to_char(fnd_date.canonical_to_date(aei_information1), 'YYYY') = p_year;

  -- Bug 9381801
  cursor medical_emp_totals    is
  select
  nvl(sum(decode(aei_information7, '0', nvl(aei_information3,0) + nvl(aei_information11,0), 0)),0) employee
  from per_assignment_extra_info pai
  where pai.assignment_id = p_emp_assignment_id
  and pai.information_type = 'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
  and to_char(fnd_date.canonical_to_date(aei_information1), 'YYYY') = p_year;


-- Local Variables

   l_hi_prem_bal	NUMBER;
   l_ei_prem_bal	NUMBER;
   l_ltci_prem_bal      NUMBER; -- Bug 7644535
   l_prev_ltci_prem     NUMBER; -- Bug 7644535
   l_ltci_bal_id	NUMBER; -- Bug 7644535
   l_prev_hi_prem       NUMBER; -- Bug 5735177
   l_prev_ei_prem       NUMBER;
   l_prev_np_prem       NUMBER;
   l_prev_pen_prem      NUMBER;    /* Bug 6655323 */
   l_hi_bal_id		NUMBER;
   l_ei_bal_id		NUMBER;
   l_virtual_date 	DATE := to_date('31-12-'||to_char(p_year),'dd-mm-rrrr');
   l_don_tax_break	NUMBER;
   l_ins_total          NUMBER;
   l_ins_oth		number;
   l_med_exem_total	number;
   l_edu_exem_total1	number;
   l_don_total1		number;
   l_edu_exem_total2	number;
   l_don_total2		number;
   l_card_total		number;
   l_cash_total		number;
   l_ins_nts		number;
   l_med_nts		number;
   l_edu_nts		number;
   l_card_nts		number;
   l_don_nts 		number;
   l_effective_date	varchar2(20);
   l_political_donation number;
   l_tot_dpnt_don_exp   number;  -- Bug 7508706
   l_prev_sep_pension   number;  -- Bug 7508706
   l_ltci_prem          number;  -- Bug 7644535
   l_med_flag           varchar2(1); -- Bug 9381801
   l_med_total          number;   -- Bug 9381801

begin
	 open csr_get_ins_bal('HI_PREM_EE','_ASG_YTD');
  	fetch csr_get_ins_bal into l_hi_bal_id;
   	close csr_get_ins_bal;

   	 open csr_get_ins_bal('EI_PREM','_ASG_YTD');
	fetch csr_get_ins_bal into l_ei_bal_id;
	close csr_get_ins_bal;
	 -- Bug 7644535
	open csr_get_ins_bal('LTCI_PREM_EE','_ASG_YTD');
	fetch csr_get_ins_bal into l_ltci_bal_id;
	close csr_get_ins_bal;

   	----------------------------------------------------------------------
	-- Get the balance values of HI_PREM_EE_ASG_YTD and EI_PREM_ASG_YTD
	-- and LTCI_PREM_EE_ASG_YTD
   	----------------------------------------------------------------------
	l_hi_prem_bal := pay_balance_pkg.get_value( l_hi_bal_id,
	  					    p_emp_assignment_id,
						    l_virtual_date);

	l_ei_prem_bal := pay_balance_pkg.get_value (l_ei_bal_id,
						    p_emp_assignment_id,
						    l_virtual_date);
	-- Bug 7644535
	l_ltci_prem_bal := pay_balance_pkg.get_value (l_ltci_bal_id,
						    p_emp_assignment_id,
						    l_virtual_date);
	-- Bug 5735177
	open csr_prev_employer_info(p_emp_assignment_id,p_year);
	fetch csr_prev_employer_info into l_prev_hi_prem, l_prev_ei_prem, l_prev_np_prem,
	                                  l_prev_pen_prem, l_prev_sep_pension, l_prev_ltci_prem; -- Bug 7508706,7644535
        close csr_prev_employer_info;

	 open sp_tax_exem_info;
	fetch sp_tax_exem_info into l_ins_total,
				    l_med_exem_total,
				    l_edu_exem_total1,
				    l_don_total1,
				    l_political_donation,
				    l_effective_date;
	close sp_tax_exem_info;
	-- bug 5726158

	 open sp_tax_exem_info2;
	fetch sp_tax_exem_info2 into l_edu_exem_total2,
				     l_don_total2,
				     l_tot_dpnt_don_exp,  -- Bug 7508706
				      l_ltci_prem,        -- Bug 7644535
				      l_med_flag;         -- Bug 9381801
	close sp_tax_exem_info2;

	l_ins_total := nvl(l_ins_total,0) + greatest(l_hi_prem_bal,0) + greatest(l_ei_prem_bal,0)
                     + greatest(l_ltci_prem_bal,0) + nvl(l_ltci_prem,0) + nvl(l_prev_hi_prem,0)
                     + nvl(l_prev_ei_prem,0) + nvl(l_prev_ltci_prem,0); -- Bug 7644535, Bug 8298522

	 open tax_exem_info;
	fetch tax_exem_info into l_card_total,
				 l_cash_total;
	close tax_exem_info;

	 open emp_exp;
	fetch emp_exp into l_med_nts,
			   l_edu_nts,
			   l_card_nts,
			   l_don_nts,
		           l_ins_nts;
	close emp_exp;

	l_don_tax_break := pay_kr_yea_form_pkg.get_donation_tax_break(l_effective_date,l_political_donation);
        -- Bug 9381801
	open medical_emp_totals;
	fetch medical_emp_totals into l_med_total;
	close medical_emp_totals;

	p_emp_ins_exp_nts := nvl(l_ins_nts,0); -- Bug 5726158
	p_emp_ins_exp_oth  := nvl(l_ins_total,0) - nvl(l_ins_nts,0);
        p_emp_med_exp_nts  := nvl(l_med_nts,0);

	if l_med_flag = 'N' then
	p_emp_med_exp_oth  := nvl(l_med_exem_total,0)
			      - nvl(l_med_nts,0);
	else
        p_emp_med_exp_oth  := nvl(l_med_exem_total,0) + nvl(l_med_total,0) - nvl(l_med_nts,0) ;

	end if;

	p_emp_edu_exp_nts  := nvl(l_edu_nts,0);
	p_emp_edu_exp_oth  := (nvl(l_edu_exem_total1,0)
			      + nvl(l_edu_exem_total2,0))
			      - nvl(l_edu_nts,0);

	p_emp_card_exp_nts := nvl(l_card_nts,0);
	p_emp_card_exp_oth := nvl(l_card_total,0)
			      - nvl(l_card_nts,0);

	p_emp_cash_exp_nts := nvl(l_cash_total,0);

	p_emp_don_exp_nts  := nvl(l_don_nts,0);
	p_emp_don_exp_oth  := (nvl(l_don_total1,0)
			      + nvl(l_don_total2,0))
			      - (nvl(l_don_tax_break,0) + nvl(l_don_nts,0) + nvl(l_tot_dpnt_don_exp,0));  -- Bug 7508706

end;
-- End of Bug # 5446051
-- Bug 5654127
-------------------------------------------------------------------------------------
Function EMP_EXPENSE_DETAILS   (p_assignment_id in number      -- Bug 5856504
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
				,p_emp_don_exp_oth   out nocopy number) return number
-------------------------------------------------------------------------------------
is
p_emp_assignment_id number;                                    -- Bug 5856504
begin
p_emp_assignment_id := p_assignment_id;                        -- Bug 5856504
EMP_EXPENSE_DETAILS (p_emp_assignment_id
			        ,p_year
				,p_emp_ins_exp_nts
				,p_emp_ins_exp_oth
				,p_emp_med_exp_nts
				,p_emp_med_exp_oth
				,p_emp_edu_exp_nts
				,p_emp_edu_exp_oth
				,p_emp_card_exp_nts
				,p_emp_card_exp_oth
				,p_emp_cash_exp_nts
				,p_emp_don_exp_nts
				,p_emp_don_exp_oth);
return 1;
end;
-- End of 5654127

end pay_kr_paykryrs_pkg;

/
