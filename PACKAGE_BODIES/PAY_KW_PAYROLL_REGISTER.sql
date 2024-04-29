--------------------------------------------------------
--  DDL for Package Body PAY_KW_PAYROLL_REGISTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_PAYROLL_REGISTER" AS
/* $Header: pykwpyrg.pkb 120.8.12010000.3 2008/12/10 07:45:50 bkeshary ship $ */
lg_format_mask varchar2(50);
----------------------------------------------------------
  PROCEDURE set_currency_mask
    (p_business_group_id IN NUMBER) IS
    /* Cursor to retrieve Currency */
    CURSOR csr_currency IS
    SELECT org_information10
    FROM   hr_organization_information
    WHERE  organization_id = p_business_group_id
    AND    org_information_context = 'Business Group Information';
    l_currency VARCHAR2(40);
  BEGIN
    OPEN csr_currency;
    FETCH csr_currency into l_currency;
    CLOSE csr_currency;
    lg_format_mask := FND_CURRENCY.GET_FORMAT_MASK(l_currency,40);
  END set_currency_mask;
----------------------------------------------------------
PROCEDURE GET_PAYROLL_REGISTER_DATA (    				p_report IN varchar2,
									p_organization_id IN number,
				                                  	p_org_structure_version_id IN number,
				                                  	p_payroll_id IN number,
									p_effective_char_date IN varchar2,
									p_sort_order1 IN varchar2,
									p_sort_order2 In varchar2,
									p_sort_order3 IN varchar2,
									l_xfdf_blob OUT NOCOPY BLOB)
 IS
TYPE rec_orgs IS RECORD (org_name varchar2(240),payroll_id number(9));
TYPE tab_orgs IS TABLE OF rec_orgs INDEX BY BINARY_INTEGER;
tab_org_data	tab_orgs;
tab_org_data_init tab_orgs;
TYPE rec_det IS RECORD       ( r_assact_id	number(15),
				r_org_pay_id	number(9),
				r_full_name	varchar2(240),
				r_emp_no	varchar2(240),
				r_org_name	varchar2(240),
				r_position	varchar2(240),
				r_title		varchar2(30),
				r_first_name 	varchar2(150),
				r_family_name 	varchar2(150),
				r_payroll_name	varchar2(80),
				r_nationality	varchar2(30),
				r_cost_center   varchar2(2000),
				r_job		varchar2(240),
				r_ytd_earning	varchar2(40),
				r_ytd_deduction	varchar2(40));
TYPE tab_dets IS TABLE OF rec_det INDEX BY BINARY_INTEGER;
tab_dets_data tab_dets;
tab_dets_data_init tab_dets;
TYPE rec_earn IS RECORD       ( r_payact_earn_id	number(15),
				  r_assact_earn_id     	number(15),
				  r_earn_narrative		varchar2(240),
				  r_earn_numeric_value 	varchar2(40),
				  r_earn_element_type	varchar2(30));
TYPE tab_earn IS TABLE OF rec_earn INDEX BY BINARY_INTEGER;
tab_earn_data tab_earn;
tab_earn_data_init tab_earn;
TYPE rec_ded IS RECORD         ( r_payact_ded_id	number(15),
				  r_assact_ded_id     	number(15),
				  r_ded_narrative		varchar2(240),
				  r_ded_numeric_value 	varchar2(40),
				  r_ded_element_type	varchar2(30));
TYPE tab_ded IS TABLE OF rec_ded INDEX BY BINARY_INTEGER;
tab_ded_data tab_ded;
tab_ded_data_init tab_ded;
TYPE rec_paymeth IS RECORD   ( r_org_paymeth_name	varchar2(240),
				  r_bank_name 		varchar2(240),
				  r_branch_name	varchar2(240),
				  r_account_number	varchar2(240),
				  r_amount		varchar2(40),
				  r_act_con_id		number(15),
				  r_pay_status		varchar2(240));
TYPE tab_paymeth IS TABLE OF rec_paymeth INDEX BY BINARY_INTEGER;
tab_paymeth_data tab_paymeth;
tab_paymeth_data_init tab_paymeth;
TYPE rec_pyrl_sum IS RECORD (payroll_id number(9));
TYPE tab_sum IS TABLE OF rec_pyrl_sum INDEX BY BINARY_INTEGER;
tab_sum_data	tab_sum;
tab_sum_data_init tab_sum;
l_org_count 	number :=1;
l_temp_count	number := 1;
p_org_id_child number(9);
i	number := 1;
j	number := 1;
k	number := 1;
l	number := 1;
m	number := 1;
t 	number := 1;
f	number := 1;
l_ret number;
l_w_indicator number := 0;
l_parent_id number;
l_err       number := 0;
l_emp_count       number := 0;
l_org_condition LONG;
l_order_by  varchar2(2000);
statem LONG;
sql_cur number;
ignore number;
l_v1 varchar2(240);
l_v2 varchar2(240);
p_org_child_id number;
p_effective_date date;
l_header_payroll_name  varchar2(240);
emp_earn_sum 	number(12,3):=0;
emp_ded_sum 	number(12,3):=0;
org_ded_sum_try 	number:=0;
org_ded_sum_1 	number:=0;
org_tot_pay 	number:=0;
org_ded_sum_tot 	number:=0;
org_earn_sum_tot 	number:=0;
--org_earn_sum_last	number(12,3) :=0;
org_earn_sum_last	varchar2(40);
--org_ded_sum_last	number(12,3) :=0;
org_ded_sum_last	varchar2(40);
l_sum_flag 	number:=0;
l_order_1 varchar2(30);
l_order_2 varchar2(30);
l_order_3 varchar2(30);
l_header_pyrl_name varchar2(240);
l_header_organization_name varchar2(240);
l_org_bg_id	number;
l_pay_bg_id	number;

l_e_temp_sum 		number;
l_e_tot_sum 		number;
l_e_arch_assact_1	number;
l_d_temp_sum 		number;
l_d_tot_sum 		number;
l_d_arch_assact_1	number;


/* SELECTS BUSINESS GROUP ID FOR ORGANIZATION SPECIFIED */
CURSOR csr_get_bg_id_org (l_org_id number) IS
select business_group_id
from hr_all_organization_units
where  ORGANIZATION_ID = l_org_id;
/* SELECTS BUSINESS GROUP ID FROM THE PAYROLL SPECIFIED */
CURSOR csr_get_bg_id_pay (l_payroll_id number , l_effective_date date) IS
select business_group_id
from pay_all_payrolls_f
where  payroll_id = l_payroll_id
AND trunc(l_effective_date,'MM') between trunc(effective_start_date,'MM') and effective_end_date;
/* SELECTS PAYROLL NAME FOR HEADER */
CURSOR csr_get_payroll_name(l_pyrl_id number , l_eff_date date) IS
select payroll_name
from pay_all_payrolls_f
where PAYROLL_ID = l_pyrl_id
and l_eff_date between effective_start_date and effective_end_date;
/* SELECTS ORGANIZATION NAME FOR HEADER */
CURSOR csr_get_organization_name (l_org_id number) IS
select name
from hr_all_organization_units
where  ORGANIZATION_ID = l_org_id;
/* SELECTS ORGANIZATIONS COMING UNDER A PAYROLL */
/* Modifyig the cursor for performance issue for Bug 7632337 */
/*CURSOR csr_get_orgs_for_payroll (l_payroll_id number , l_effective_date date) is
SELECT        distinct pai_emp.action_information15 organization
		  ,ppf.payroll_id
FROM         per_time_periods ptp
            ,pay_action_information pai_emp
            ,pay_assignment_actions paa1
            ,pay_action_interlocks lck
            ,pay_payroll_actions ppa1
		,pay_all_payrolls_f ppf
WHERE  ptp.payroll_id = l_payroll_id
AND    ptp.time_period_id = pai_emp.action_information16
AND    pai_emp.action_context_type = 'AAP'
AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
AND    lck.locking_action_id = pai_emp.action_context_id
AND    lck.locked_action_id = paa1.assignment_action_id
AND    paa1.payroll_action_id = ppa1.payroll_action_id
AND    ppa1.action_type in ('R','Q')
AND    ppa1.action_status = 'C'
AND    paa1.action_status = 'C'
AND    ptp.end_date = l_effective_date
AND    ppf.payroll_id = ptp.payroll_id
AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date; */

CURSOR csr_get_orgs_for_payroll (l_payroll_id number , l_effective_date date) is
SELECT        distinct pai_emp.action_information15 organization
		        ,ppf.payroll_id
FROM         per_time_periods ptp
            ,pay_action_information pai_emp
            ,pay_assignment_actions paa1
            ,pay_payroll_actions ppa1
		,pay_all_payrolls_f ppf
WHERE  ptp.payroll_id = l_payroll_id
AND    ptp.time_period_id = pai_emp.action_information16
AND    pai_emp.action_context_type = 'AAP'
AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
AND    pai_emp.action_context_id = paa1.assignment_action_id
AND    paa1.payroll_action_id = ppa1.payroll_action_id
AND    ppa1.action_type = 'X'
and    ppa1.report_type = 'KW_ARCHIVE'
AND    ppa1.action_status = 'C'
AND    paa1.action_status = 'C'
AND    ptp.end_date = l_effective_date
AND    ppf.payroll_id = ptp.payroll_id
AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date;
/* CURSOR ONE */
/* Modifyig the cursor for performance issue for Bug 7632337 */
/*cursor csr_condition_one(l_organization_id number ,l_org_structure_version_id number,l_parent_id number, l_effective_date date ) is
SELECT  distinct pai_emp.action_information15 organization
					,ppf.payroll_id
				FROM	 per_time_periods ptp
			            ,pay_action_information pai_emp
			            ,pay_assignment_actions paa1
		      	      ,pay_action_interlocks lck
		            	,pay_payroll_actions ppa1
					,pay_all_payrolls_f ppf
 				WHERE  ptp.time_period_id = pai_emp.action_information16
					AND    pai_emp.action_context_type = 'AAP'
					AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
					AND    lck.locking_action_id = pai_emp.action_context_id
					AND    lck.locked_action_id = paa1.assignment_action_id
					AND    paa1.payroll_action_id = ppa1.payroll_action_id
					AND    ppa1.action_type in ('R','Q')
					AND    ppa1.action_status = 'C'
					AND    paa1.action_status = 'C'
					AND    ptp.end_date = l_effective_date
					AND    ppf.payroll_id = ptp.payroll_id
					AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
					AND 	 pai_emp.action_information2  in (select to_char(pose.organization_id_child)
											   from per_org_structure_elements pose
											   connect by pose.organization_id_parent =
											   prior pose.organization_id_child
											   and pose.org_structure_version_id =
											   to_char (l_org_structure_version_id)
											   start with pose.organization_id_parent =
											   to_char(nvl(l_organization_id,l_parent_id))
											   and pose.org_structure_version_id =
												 to_char(l_org_structure_version_id)
											   union select  to_char(nvl(l_organization_id,l_parent_id))
												   from sys.dual) ; */
cursor csr_condition_one(l_organization_id number ,l_org_structure_version_id number,l_parent_id number, l_effective_date date ) is
SELECT  distinct pai_emp.action_information15 organization
					,ppf.payroll_id
				FROM	 per_time_periods ptp
			            ,pay_action_information pai_emp
			            ,pay_assignment_actions paa1
		            	,pay_payroll_actions ppa1
					,pay_all_payrolls_f ppf
 				WHERE  ptp.time_period_id = pai_emp.action_information16
					AND    pai_emp.action_context_type = 'AAP'
					AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
					AND    pai_emp.action_context_id = paa1.assignment_action_id
					AND    paa1.payroll_action_id = ppa1.payroll_action_id
					AND    ppa1.action_type = 'X'
					AND    ppa1.report_type = 'KW_ARCHIVE'
					AND    ppa1.action_status = 'C'
					AND    paa1.action_status = 'C'
					AND    ptp.end_date = l_effective_date
					AND    ppf.payroll_id = ptp.payroll_id
					AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
					AND 	 pai_emp.action_information2  in (select to_char(pose.organization_id_child)
											   from per_org_structure_elements pose
											   connect by pose.organization_id_parent =
											   prior pose.organization_id_child
											   and pose.org_structure_version_id =
											   to_char (l_org_structure_version_id)
											   start with pose.organization_id_parent =
											   to_char(nvl(l_organization_id,l_parent_id))
											   and pose.org_structure_version_id =
												 to_char(l_org_structure_version_id)
											   union select  to_char(nvl(l_organization_id,l_parent_id))
												   from sys.dual) ;
/* Modifyig the cursor for performance issue for Bug 7632337 */
/*cursor csr_condition_two(l_organization_id number , l_effective_date date)  is
SELECT  distinct pai_emp.action_information15 organization
					,ppf.payroll_id
				FROM	 per_time_periods ptp
			            ,pay_action_information pai_emp
			            ,pay_assignment_actions paa1
		      	      ,pay_action_interlocks lck
		            	,pay_payroll_actions ppa1
					,pay_all_payrolls_f ppf
 				WHERE  ptp.time_period_id = pai_emp.action_information16
					AND    pai_emp.action_context_type = 'AAP'
					AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
					AND    lck.locking_action_id = pai_emp.action_context_id
					AND    lck.locked_action_id = paa1.assignment_action_id
					AND    paa1.payroll_action_id = ppa1.payroll_action_id
					AND    ppa1.action_type in ('R','Q')
					AND    ppa1.action_status = 'C'
					AND    paa1.action_status = 'C'
					AND    ptp.end_date = l_effective_date
					AND    ppf.payroll_id = ptp.payroll_id
					AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
					AND 	 pai_emp.action_information2 = l_organization_id; */
cursor csr_condition_two(l_organization_id number , l_effective_date date)  is
SELECT  distinct pai_emp.action_information15 organization
					,ppf.payroll_id
				FROM	 per_time_periods ptp
			            ,pay_action_information pai_emp
			            ,pay_assignment_actions paa1
		            	,pay_payroll_actions ppa1
					,pay_all_payrolls_f ppf
 				WHERE  ptp.time_period_id = pai_emp.action_information16
					AND    pai_emp.action_context_type = 'AAP'
					AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
                                        AND    pai_emp.action_context_id = paa1.assignment_action_id
					AND    paa1.payroll_action_id = ppa1.payroll_action_id
					AND    ppa1.action_type = 'X'
					AND    ppa1.report_type = 'KW_ARCHIVE'
					AND    ppa1.action_status = 'C'
					AND    paa1.action_status = 'C'
					AND    ptp.end_date = l_effective_date
					AND    ppf.payroll_id = ptp.payroll_id
					AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
					AND 	 pai_emp.action_information2 = l_organization_id;
/* Modifyig the cursor for performance issue for Bug 7632337 */
/* It looks like dummy cursor as it has conditions 1=2 */
/*cursor csr_condition_three(l_effective_date date)  is
SELECT  distinct pai_emp.action_information15 organization
					,ppf.payroll_id
				FROM	 per_time_periods ptp
			            ,pay_action_information pai_emp
			            ,pay_assignment_actions paa1
		      	      ,pay_action_interlocks lck
		            	,pay_payroll_actions ppa1
					,pay_all_payrolls_f ppf
 				WHERE  ptp.time_period_id = pai_emp.action_information16
					AND    pai_emp.action_context_type = 'AAP'
					AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
					AND    lck.locking_action_id = pai_emp.action_context_id
					AND    lck.locked_action_id = paa1.assignment_action_id
					AND    paa1.payroll_action_id = ppa1.payroll_action_id
					AND    ppa1.action_type in ('R','Q')
					AND    ppa1.action_status = 'C'
					AND    paa1.action_status = 'C'
					AND    ptp.end_date = l_effective_date
					AND    ppf.payroll_id = ptp.payroll_id
					AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
					AND	 1 = 2; */
cursor csr_condition_three(l_effective_date date)  is
SELECT  '123' organization
					,'213' payroll_id
				FROM	 dual
				where  1 = 2;
/* CURSOR TO GET PAYROLL IDS DISTINCT */
/* Modifyig the cursor for performance issue for Bug 7632337 */
/*cursor csr_distinct_pyrl(l_organization_id number ,l_org_structure_version_id number,l_parent_id number, l_effective_date date ) is
SELECT  distinct ppf.payroll_id
				FROM	 per_time_periods ptp
			            ,pay_action_information pai_emp
			            ,pay_assignment_actions paa1
		      	      ,pay_action_interlocks lck
		            	,pay_payroll_actions ppa1
					,pay_all_payrolls_f ppf
 				WHERE  ptp.time_period_id = pai_emp.action_information16
					AND    pai_emp.action_context_type = 'AAP'
					AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
					AND    lck.locking_action_id = pai_emp.action_context_id
					AND    lck.locked_action_id = paa1.assignment_action_id
					AND    paa1.payroll_action_id = ppa1.payroll_action_id
					AND    ppa1.action_type in ('R','Q')
					AND    ppa1.action_status = 'C'
					AND    paa1.action_status = 'C'
					AND    ptp.end_date = l_effective_date
					AND    ppf.payroll_id = ptp.payroll_id
					AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
					AND 	 pai_emp.action_information2  in (select to_char(pose.organization_id_child)
											   from per_org_structure_elements pose
											   connect by pose.organization_id_parent =
											   prior pose.organization_id_child
											   and pose.org_structure_version_id =
											   to_char (l_org_structure_version_id)
											   start with pose.organization_id_parent =
											   to_char(nvl(l_organization_id,l_parent_id))
											   and pose.org_structure_version_id =
												 to_char(l_org_structure_version_id)
											   union select  to_char(nvl(l_organization_id,l_parent_id))
												   from sys.dual) ; */
cursor csr_distinct_pyrl(l_organization_id number ,l_org_structure_version_id number,l_parent_id number, l_effective_date date ) is
     SELECT  distinct ppf.payroll_id
				FROM	 per_time_periods ptp
			            ,pay_action_information pai_emp
			            ,pay_assignment_actions paa1
		            	,pay_payroll_actions ppa1
					,pay_all_payrolls_f ppf
 				WHERE  ptp.time_period_id = pai_emp.action_information16
					AND    pai_emp.action_context_type = 'AAP'
					AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
					AND    pai_emp.action_context_id = paa1.assignment_action_id
					AND    paa1.payroll_action_id = ppa1.payroll_action_id
					AND    ppa1.action_type = 'X'
					AND    ppa1.report_type = 'KW_ARCHIVE'
					AND    ppa1.action_status = 'C'
					AND    paa1.action_status = 'C'
					AND    ptp.end_date = l_effective_date
					AND    ppf.payroll_id = ptp.payroll_id
					AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
					AND 	 pai_emp.action_information2  in (select to_char(pose.organization_id_child)
											   from per_org_structure_elements pose
											   connect by pose.organization_id_parent =
											   prior pose.organization_id_child
											   and pose.org_structure_version_id =
											   to_char (l_org_structure_version_id)
											   start with pose.organization_id_parent =
											   to_char(nvl(l_organization_id,l_parent_id))
											   and pose.org_structure_version_id =
												 to_char(l_org_structure_version_id)
											   union select  to_char(nvl(l_organization_id,l_parent_id))
												   from sys.dual) ;
/* CURSOR TO GET PAYROLL IDS DISTINCT FOR ORGANIZATION */
cursor csr_org_only_distinct_pyrl(l_organization_id number , l_effective_date date)  is
SELECT  distinct ppf.payroll_id
				FROM	 per_time_periods ptp
			            ,pay_action_information pai_emp
  			            ,pay_assignment_actions paa1
		      	      ,pay_action_interlocks lck
		            	,pay_payroll_actions ppa1
					,pay_all_payrolls_f ppf
 				WHERE  ptp.time_period_id = pai_emp.action_information16
					AND    pai_emp.action_context_type = 'AAP'
					AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
					AND    lck.locking_action_id = pai_emp.action_context_id
					AND    lck.locked_action_id = paa1.assignment_action_id
					AND    paa1.payroll_action_id = ppa1.payroll_action_id
					AND    ppa1.action_type in ('R','Q')
					AND    ppa1.action_status = 'C'
					AND    paa1.action_status = 'C'
					AND    ptp.end_date = l_effective_date
					AND    ppf.payroll_id = ptp.payroll_id
					AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
					AND 	 pai_emp.action_information2 = l_organization_id;
/* Cursor to tune the condition one sql performance */
Cursor csr_cond_1_tune (l_org_structure_version_id number,l_organization_id number, l_parent_id number) is
select to_char(pose.organization_id_child)
from per_org_structure_elements pose
connect by pose.organization_id_parent =
prior pose.organization_id_child
and pose.org_structure_version_id = to_char (l_org_structure_version_id)
start with pose.organization_id_parent = to_char(nvl(l_organization_id,l_parent_id))
and pose.org_structure_version_id = to_char(l_org_structure_version_id)
union select to_char(nvl(l_organization_id,l_parent_id)) from sys.dual;
/* SELECTS DATA FOR A GIVEN ORGANIZATION AND A PAYROLL  COMBINATION */
/* Modifyig the cursor for performance issue for Bug 7632337 */
/*CURSOR csr_get_details (l_payroll_id number , l_effective_date date,  l_org_name varchar2,p_order_1 varchar2,p_order_2 varchar2,p_order_3 varchar2) Is
SELECT       distinct pai_emp.action_context_id arch_assact
             ,to_char(ptp.payroll_id) org_pay
             ,pai_emp.action_information1 full_name
             ,pai_emp.action_information10
             ,pai_emp.action_information15 organization
             ,pai_emp.action_information19 position
             ,pai_emp.action_information5 cost_center
             ,pai_emp.action_information9 nationality
             ,pai_emp.action_information17 job
             ,pai_emp1.action_information9 title
             ,pai_emp1.action_information10
             ,pai_emp1.action_information11
             ,ppf.payroll_name
             ,nvl(pai_emp1.action_information13,0) ytd_earning
             ,nvl(pai_emp1.action_information4,0) ytd_deduction
FROM        per_time_periods ptp
            ,pay_action_information pai_emp
            ,pay_action_information pai_emp1
            ,pay_assignment_actions paa1
            ,pay_action_interlocks lck
            ,pay_payroll_actions ppa1
            ,pay_all_payrolls_f ppf
WHERE  ptp.payroll_id = l_payroll_id
AND    ptp.time_period_id = pai_emp.action_information16
AND    pai_emp.action_context_id = pai_emp1.action_context_id
AND    pai_emp.action_context_type = 'AAP'
AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
AND    pai_emp.action_information15 = l_org_name
AND    pai_emp1.action_context_type = 'AAP'
AND    pai_emp1.action_information_category(+) = 'ADDL EMPLOYEE DETAILS'
AND    lck.locking_action_id = pai_emp.action_context_id
AND    lck.locked_action_id = paa1.assignment_action_id
AND    paa1.payroll_action_id = ppa1.payroll_action_id
AND    ppa1.action_type in ('R','Q')
AND    ppa1.action_status = 'C'
AND    paa1.action_status = 'C'
AND    ptp.end_date = l_effective_date
AND    ppf.payroll_id = ptp.payroll_id
AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
ORDER BY decode(p_order_1,'first_name',pai_emp1.action_information10,'employee_number',pai_emp.action_information10,'family_name',pai_emp1.action_information11),
	 decode(p_order_2,'first_name',pai_emp1.action_information10,'employee_number',pai_emp.action_information10,'family_name',pai_emp1.action_information11,null,1),
	 decode(p_order_3,'first_name',pai_emp1.action_information10,'employee_number',pai_emp.action_information10,'family_name',pai_emp1.action_information11,null,1); */

CURSOR csr_get_details (l_payroll_id number , l_effective_date date,  l_org_name varchar2,p_order_1 varchar2,p_order_2 varchar2,p_order_3 varchar2) Is
SELECT       distinct pai_emp.action_context_id arch_assact
             ,to_char(ptp.payroll_id) org_pay
             ,pai_emp.action_information1 full_name
             ,pai_emp.action_information10
             ,pai_emp.action_information15 organization
             ,pai_emp.action_information19 position
             ,pai_emp1.action_information7 cost_center
             ,pai_emp.action_information9 nationality
             ,pai_emp.action_information17 job
             ,pai_emp1.action_information9 title
             ,pai_emp1.action_information6
             ,pai_emp1.action_information11
             ,ppf.payroll_name
             ,nvl(pai_emp1.action_information13,0) ytd_earning
             ,nvl(pai_emp1.action_information4,0) ytd_deduction
FROM         per_time_periods ptp
            ,pay_action_information pai_emp
            ,pay_action_information pai_emp1
            ,pay_assignment_actions paa1
            ,pay_payroll_actions ppa1
            ,pay_all_payrolls_f ppf
WHERE  ptp.payroll_id = l_payroll_id
AND    ptp.time_period_id = pai_emp.action_information16
AND    pai_emp.action_context_id = pai_emp1.action_context_id
AND    pai_emp.action_context_type = 'AAP'
AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
AND    pai_emp.action_information15 = l_org_name
AND    pai_emp1.action_context_type = 'AAP'
AND    pai_emp1.action_information_category(+) = 'ADDL EMPLOYEE DETAILS'
AND    ptp.end_date = l_effective_date
AND    pai_emp.action_context_id = paa1.assignment_action_id
AND    paa1.payroll_action_id = ppa1.payroll_action_id
AND    ppa1.action_type = 'X'
and    ppa1.report_type = 'KW_ARCHIVE'
AND    ppa1.action_status = 'C'
AND    paa1.action_status = 'C'
AND    ppf.payroll_id = ptp.payroll_id
AND    l_effective_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
ORDER BY decode(p_order_1,'first_name',pai_emp1.action_information6,'employee_number',pai_emp.action_information10,'family_name',pai_emp1.action_information11),
	 decode(p_order_2,'first_name',pai_emp1.action_information6,'employee_number',pai_emp.action_information10,'family_name',pai_emp1.action_information11,null,1),
	 decode(p_order_3,'first_name',pai_emp1.action_information6,'employee_number',pai_emp.action_information10,'family_name',pai_emp1.action_information11,null,1);
/* SELECT ELEMENTS AND DEDUCTIONS DETAILS */
CURSOR csr_get_earn_det (l_assact_id number) IS
/*The select statement is changed for fixing bug 6081731
SELECT   pai_ele.action_context_id arch_payact
              ,pay_v.action_context_id arch_assact
              ,pay_v.narrative earn_element
              ,pay_v.numeric_value earn_value
             ,pai_ele.action_information7
FROM    pay_action_information pai_ele
             ,pay_emea_paymnts_action_info_v pay_v
             ,pay_assignment_actions paa
WHERE    paa.assignment_action_id = l_assact_id
AND	 paa.payroll_action_id = pai_ele.action_context_id
AND      pai_ele.action_context_type = 'PA'
AND      pai_ele.action_information_category = 'EMEA ELEMENT DEFINITION'
AND      pai_ele.action_information7 IN ('E')
AND      pay_v.action_context_id = paa.assignment_action_id
AND      pay_v.narrative = pai_ele.action_information4
AND      pay_v.payment_type NOT IN ('F');*/
SELECT   ppa.payroll_action_id arch_payact
         ,paa2.assignment_action_id arch_assact
         ,pai.action_information4 earn_element
         ,pet.result_value earn_value
         ,pai.action_information7
FROM
  pay_action_interlocks lck,
  pay_assignment_actions paa1,
  pay_assignment_actions paa2,
  pay_payroll_actions ppa,
  pay_action_information pai,
  pay_emea_payment_values_v pet
WHERE
  lck.locked_action_id = paa1.assignment_action_id AND
  paa1.source_action_id IS NULL AND
  paa1.payroll_action_id = ppa.payroll_action_id AND
  ppa.action_type IN ('P','U') AND
  ppa.payroll_action_id = NVL (pai.action_information1,ppa.payroll_action_id) AND
  pai.action_context_type = 'PA' AND
  pai.action_information_category = 'EMEA ELEMENT DEFINITION' AND
  paa1.assignment_action_id = pet.assignment_action_id AND
  pet.element_type_id = pai.action_information2 AND
  pet.input_value_id = pai.action_information3 AND
  lck.locking_action_id = paa2.assignment_action_id AND
  paa2.payroll_action_id = pai.action_context_id AND
  pai.action_information5 NOT IN ('F') AND
  pai.action_information7 IN ('E') AND
  paa2.assignment_action_id = l_assact_id;

CURSOR csr_get_ded_det (l_assact_id number) IS
/*SELECT   pai_ele.action_context_id arch_payact
              ,pay_v.action_context_id arch_assact
              ,pay_v.narrative ded_element
             ,pay_v.numeric_value ded_value
             ,pai_ele.action_information7
FROM    pay_action_information pai_ele
             ,pay_emea_paymnts_action_info_v pay_v
             ,pay_assignment_actions paa
WHERE  	 paa.assignment_action_id= l_assact_id
AND      paa.payroll_action_id = pai_ele.action_context_id
AND      pai_ele.action_context_type = 'PA'
AND      pai_ele.action_information_category = 'EMEA ELEMENT DEFINITION'
AND      pai_ele.action_information7 IN ('D')
AND      pay_v.action_context_id = paa.assignment_action_id
AND      pay_v.narrative = pai_ele.action_information4
AND      pay_v.payment_type NOT IN ('F');*/
SELECT   ppa.payroll_action_id arch_payact
         ,paa2.assignment_action_id arch_assact
         ,pai.action_information4 ded_element
         ,pet.result_value ded_value
         ,pai.action_information7
FROM
  pay_action_interlocks lck,
  pay_assignment_actions paa1,
  pay_assignment_actions paa2,
  pay_payroll_actions ppa,
  pay_action_information pai,
  pay_emea_payment_values_v pet
WHERE
  lck.locked_action_id = paa1.assignment_action_id AND
  paa1.source_action_id IS NULL AND
  paa1.payroll_action_id = ppa.payroll_action_id AND
  ppa.action_type IN ('P','U') AND
  ppa.payroll_action_id = NVL (pai.action_information1,ppa.payroll_action_id) AND
  pai.action_context_type = 'PA' AND
  pai.action_information_category = 'EMEA ELEMENT DEFINITION' AND
  paa1.assignment_action_id = pet.assignment_action_id AND
  pet.element_type_id = pai.action_information2 AND
  pet.input_value_id = pai.action_information3 AND
  lck.locking_action_id = paa2.assignment_action_id AND
  paa2.payroll_action_id = pai.action_context_id AND
  pai.action_information5 NOT IN ('F') AND
  pai.action_information7 IN ('D') AND
  paa2.assignment_action_id = l_assact_id;



/* SELECT PAYMENT METHOD DETAILS */
CURSOR csr_get_paymeth_det (l_assact_id number) IS
SELECT        pen.org_payment_method_name
             ,pen.segment1 bank_name
             ,pen.segment2 branch_name
             ,pen.segment4 account_number
             ,pen.value pay_amount
             ,pen.action_context_id
             ,pay_assignment_actions_pkg.get_payment_status(paa.assignment_action_id,ppp.pre_payment_id) status
FROM          pay_emp_net_dist_action_info_v pen
             ,pay_action_interlocks pai
             ,pay_assignment_actions paa
             ,pay_payroll_actions ppa
             ,pay_pre_payments ppp
WHERE    pen.action_context_id = l_assact_id
AND      pen.action_context_id = pai.locking_action_id
AND      pai.locked_action_id =  paa.assignment_action_id
AND      paa.payroll_action_id = ppa.payroll_action_id
AND      ppa.action_type in ('P','U')
AND      ppa.action_status = 'C'
AND      paa.assignment_action_id = ppp.assignment_action_id
AND    (ppp.personal_payment_method_id = pen.personal_payment_method_id
            OR ppp.org_payment_method_id = pen.org_payment_method_id )
ORDER BY status, pay_amount;
/* Cursor to get the sum of the Earnings for particular payroll for summary */
/*CURSOR csr_get_sum_earn_summary (l_org_name varchar2 , l_payroll_id number , l_effective_date date) IS
SELECT   sum(pay_v.numeric_value)
FROM    pay_action_information pai_ele
             ,pay_emea_paymnts_action_info_v pay_v
             ,pay_assignment_actions paa
WHERE    paa.payroll_action_id = pai_ele.action_context_id
AND      pai_ele.action_context_type = 'PA'
AND      pai_ele.action_information_category = 'EMEA ELEMENT DEFINITION'
AND      pai_ele.action_information7 IN ('E')
AND      pay_v.action_context_id = paa.assignment_action_id
AND      pay_v.narrative = pai_ele.action_information4
AND      pay_v.payment_type NOT IN ('F')
AND    paa.assignment_action_id in (SELECT        pai_emp.action_context_id arch_assact
FROM          per_time_periods ptp
            ,pay_action_information pai_emp
            ,pay_assignment_actions paa1
            ,pay_action_interlocks lck
            ,pay_payroll_actions ppa1
WHERE  ptp.payroll_id = l_payroll_id
AND    ptp.time_period_id = pai_emp.action_information16
AND    pai_emp.action_context_type = 'AAP'
AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
AND    pai_emp.action_information15 = l_org_name
AND    lck.locking_action_id = pai_emp.action_context_id
AND    lck.locked_action_id = paa1.assignment_action_id
AND    paa1.payroll_action_id = ppa1.payroll_action_id
AND    ppa1.action_type in ('R','Q')
AND    ppa1.action_status = 'C'
AND    paa1.action_status = 'C'
AND    ptp.end_date = l_effective_date);*/
CURSOR csr_get_sum_earn (l_org_structure_version_id number,
                                l_organization_id number , l_payroll_id number , l_effective_date date) IS
SELECT   sum(pay_v.numeric_value)
FROM    pay_action_information pai_ele
             ,pay_emea_paymnts_action_info_v pay_v
             ,pay_assignment_actions paa
WHERE    paa.payroll_action_id = pai_ele.action_context_id
AND      pai_ele.action_context_type = 'PA'
AND      pai_ele.action_information_category = 'EMEA ELEMENT DEFINITION'
AND      pai_ele.action_information7 IN ('E')
AND      pay_v.action_context_id = paa.assignment_action_id
AND      pay_v.narrative = pai_ele.action_information4
AND      pay_v.payment_type NOT IN ('F')
AND    paa.assignment_action_id in (SELECT        pai_emp.action_context_id arch_assact
FROM          per_time_periods ptp
            ,pay_action_information pai_emp
            ,pay_assignment_actions paa1
            ,pay_action_interlocks lck
            ,pay_payroll_actions ppa1
WHERE  ptp.payroll_id = l_payroll_id
AND    ptp.time_period_id = pai_emp.action_information16
AND    pai_emp.action_context_type = 'AAP'
AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
AND 	 pai_emp.action_information2  in (select to_char(pose.organization_id_child)
					   from per_org_structure_elements pose
					   connect by pose.organization_id_parent =
					   prior pose.organization_id_child
					   and pose.org_structure_version_id =
					   to_char (l_org_structure_version_id)
					   start with pose.organization_id_parent =  to_char(l_organization_id)
					   and pose.org_structure_version_id = to_char(l_org_structure_version_id)
					   union select  to_char(l_organization_id) from sys.dual)
/*AND    pai_emp.action_information15 = l_org_name*/
AND    lck.locking_action_id = pai_emp.action_context_id
AND    lck.locked_action_id = paa1.assignment_action_id
AND    paa1.payroll_action_id = ppa1.payroll_action_id
AND    ppa1.action_type in ('R','Q')
AND    ppa1.action_status = 'C'
AND    paa1.action_status = 'C'
AND    ptp.end_date = l_effective_date);
/****Cursor split into 2 for fixing performance bug
CURSOR csr_get_sum_earn_only_org (l_organization_id number , l_payroll_id number , l_effective_date date) IS
--*******Fixed during performance bugs*****
SELECT   sum(pay_v.numeric_value)
FROM    pay_assignment_actions paa
        ,per_time_periods ptp
        ,pay_assignment_actions paa1
        ,pay_action_interlocks lck
        ,pay_payroll_actions ppa1
        ,pay_action_information pai_ele
        ,pay_action_information pai_emp
        ,pay_emea_paymnts_action_info_v pay_v
WHERE    paa.payroll_action_id = pai_ele.action_context_id
AND      pai_ele.action_context_type = 'PA'
AND      pai_ele.action_information_category = 'EMEA ELEMENT DEFINITION'
AND      pai_ele.action_information7 IN ('E')
AND      pay_v.action_context_id = paa.assignment_action_id
AND      pay_v.narrative = pai_ele.action_information4
AND      pay_v.payment_type NOT IN ('F')
AND    paa.assignment_action_id = pai_emp.action_context_id
AND    ptp.payroll_id = l_payroll_id
AND    ptp.time_period_id = pai_emp.action_information16
AND    pai_emp.action_context_type = 'AAP'
AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
AND      pai_emp.action_information2  = l_organization_id
--AND    pai_emp.action_information15 = l_org_name
AND    lck.locking_action_id = pai_emp.action_context_id
AND    lck.locked_action_id = paa1.assignment_action_id
AND    paa1.payroll_action_id = ppa1.payroll_action_id
AND    ppa1.action_type in ('R','Q')
AND    ppa1.action_status = 'C'
AND    paa1.action_status = 'C'
AND    ptp.end_date = l_effective_date;
--***** End of fixed during performance bugs ****
*/

CURSOR csr_seoo_split_1 (l_organization_id number , l_payroll_id number , l_effective_date date) IS
select pai_emp.action_context_id arch_assact
from per_time_periods ptp
,pay_action_information pai_emp
,pay_assignment_actions paa1
,pay_action_interlocks lck
,pay_payroll_actions ppa1
where ptp.payroll_id = l_payroll_id
and ptp.time_period_id = pai_emp.action_information16
and pai_emp.action_context_type = 'AAP'
and pai_emp.action_information_category = 'EMPLOYEE DETAILS'
and pai_emp.action_information2 = l_organization_id
/*and pai_emp.action_information15 = l_org_name*/
and lck.locking_action_id = pai_emp.action_context_id
and lck.locked_action_id = paa1.assignment_action_id
and paa1.payroll_action_id = ppa1.payroll_action_id
and ptp.payroll_id = ppa1.payroll_id
and ppa1.action_type in ('R','Q')
and ppa1.action_status = 'C'
and paa1.action_status = 'C'
and ptp.end_date = l_effective_date;
CURSOR csr_seoo_split_2 (l_arch_assact number) IS
select SUM(pay_v.numeric_value)
from pay_action_information pai_ele
,pay_emea_paymnts_action_info_v pay_v
,pay_assignment_actions paa
where paa.payroll_action_id = pai_ele.action_context_id
and pai_ele.action_context_type = 'PA'
and pai_ele.action_information_category = 'EMEA ELEMENT DEFINITION'
and pai_ele.action_information7 in ('E')
and pay_v.action_context_id = paa.assignment_action_id
and pay_v.narrative = pai_ele.action_information4
and pay_v.payment_type not in ('F')
and paa.assignment_action_id = l_arch_assact;



/* Cursor to get the sum of the Deductions for particular payroll for summary */
--CURSOR csr_get_sum_ded_summary (l_org_name varchar2 , l_payroll_id number , l_effective_date date) IS
CURSOR csr_get_sum_ded (l_org_structure_version_id number,
                                l_organization_id number , l_payroll_id number , l_effective_date date) IS
SELECT   sum(pay_v.numeric_value)
FROM    pay_action_information pai_ele
             ,pay_emea_paymnts_action_info_v pay_v
             ,pay_assignment_actions paa
WHERE    paa.payroll_action_id = pai_ele.action_context_id
AND      pai_ele.action_context_type = 'PA'
AND      pai_ele.action_information_category = 'EMEA ELEMENT DEFINITION'
AND      pai_ele.action_information7 IN ('D')
AND      pay_v.action_context_id = paa.assignment_action_id
AND      pay_v.narrative = pai_ele.action_information4
AND      pay_v.payment_type NOT IN ('F')
AND    paa.assignment_action_id in (SELECT        pai_emp.action_context_id arch_assact
FROM          per_time_periods ptp
            ,pay_action_information pai_emp
            ,pay_assignment_actions paa1
            ,pay_action_interlocks lck
            ,pay_payroll_actions ppa1
WHERE  ptp.payroll_id = l_payroll_id
AND    ptp.time_period_id = pai_emp.action_information16
AND    pai_emp.action_context_type = 'AAP'
AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
AND 	 pai_emp.action_information2  in (select to_char(pose.organization_id_child)
					   from per_org_structure_elements pose
					   connect by pose.organization_id_parent =
					   prior pose.organization_id_child
					   and pose.org_structure_version_id =
					   to_char (l_org_structure_version_id)
					   start with pose.organization_id_parent =  to_char(l_organization_id)
					   and pose.org_structure_version_id = to_char(l_org_structure_version_id)
					   union select  to_char(l_organization_id) from sys.dual)
/*AND    pai_emp.action_information15 = l_org_name*/
AND    lck.locking_action_id = pai_emp.action_context_id
AND    lck.locked_action_id = paa1.assignment_action_id
AND    paa1.payroll_action_id = ppa1.payroll_action_id
AND    ppa1.action_type in ('R','Q')
AND    ppa1.action_status = 'C'
AND    paa1.action_status = 'C'
AND    ptp.end_date = l_effective_date);
/****Cursor split into 2 for fixing performance bug
CURSOR csr_get_sum_ded_only_org (l_organization_id number , l_payroll_id number , l_effective_date date) IS
--******* Fixed during performance bugs*******
SELECT  sum(pay_v.numeric_value)
FROM    pay_assignment_actions paa
        ,per_time_periods ptp
        ,pay_assignment_actions paa1
        ,pay_action_interlocks lck
        ,pay_payroll_actions ppa1
        ,pay_action_information pai_ele
        ,pay_action_information pai_emp
        ,pay_emea_paymnts_action_info_v pay_v
WHERE    paa.payroll_action_id = pai_ele.action_context_id
AND      pai_ele.action_context_type = 'PA'
AND      pai_ele.action_information_category = 'EMEA ELEMENT DEFINITION'
AND      pai_ele.action_information7 IN ('D')
AND      pay_v.action_context_id = paa.assignment_action_id
AND      pay_v.narrative = pai_ele.action_information4
AND      pay_v.payment_type NOT IN ('F')
AND    paa.assignment_action_id = pai_emp.action_context_id
AND    ptp.payroll_id = l_payroll_id
AND    ptp.time_period_id = pai_emp.action_information16
AND    pai_emp.action_context_type = 'AAP'
AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
AND      pai_emp.action_information2  = l_organization_id
--AND    pai_emp.action_information15 = l_org_name
AND    lck.locking_action_id = pai_emp.action_context_id
AND    lck.locked_action_id = paa1.assignment_action_id
AND    paa1.payroll_action_id = ppa1.payroll_action_id
AND    ppa1.action_type in ('R','Q')
AND    ppa1.action_status = 'C'
AND    paa1.action_status = 'C'
AND    ptp.end_date = l_effective_date;
--********** End of fixed during performance bugs ********
*/

CURSOR csr_sdoo_split_1 (l_organization_id number , l_payroll_id number , l_effective_date date) IS
select pai_emp.action_context_id arch_assact
from per_time_periods ptp
,pay_action_information pai_emp
,pay_assignment_actions paa1
,pay_action_interlocks lck
,pay_payroll_actions ppa1
where ptp.payroll_id = l_payroll_id
and ptp.time_period_id = pai_emp.action_information16
and pai_emp.action_context_type = 'AAP'
and pai_emp.action_information_category = 'EMPLOYEE DETAILS'
and pai_emp.action_information2 = l_organization_id
/*and pai_emp.action_information15 = l_org_name*/
and lck.locking_action_id = pai_emp.action_context_id
and lck.locked_action_id = paa1.assignment_action_id
and paa1.payroll_action_id = ppa1.payroll_action_id
and ptp.payroll_id = ppa1.payroll_id
and ppa1.action_type in ('R','Q')
and ppa1.action_status = 'C'
and paa1.action_status = 'C'
and ptp.end_date = l_effective_date;
CURSOR csr_sdoo_split_2 (l_arch_assact number) IS
select SUM(pay_v.numeric_value)
from pay_action_information pai_ele
,pay_emea_paymnts_action_info_v pay_v
,pay_assignment_actions paa
where paa.payroll_action_id = pai_ele.action_context_id
and pai_ele.action_context_type = 'PA'
and pai_ele.action_information_category = 'EMEA ELEMENT DEFINITION'
and pai_ele.action_information7 in ('D')
and pay_v.action_context_id = paa.assignment_action_id
and pay_v.narrative = pai_ele.action_information4
and pay_v.payment_type not in ('F')
and paa.assignment_action_id = l_arch_assact;


begin
p_effective_date := to_date(p_effective_char_date,'YYYY/MM/DD HH24:MI:SS');
vXMLtable.DELETE;
vXMLTable_summary.DELETE;
vCtr_summary :=1;
vCtr :=1;
if p_sort_order1 = 'EMP_NO' then
	l_order_1 := 'employee_number';
elsif p_sort_order1 = 'EMP_FIRST' then
	l_order_1 := 'first_name';
else
	l_order_1 := 'family_name';
end if;
if p_sort_order2 = 'EMP_NO' then
	l_order_2 := 'employee_number';
elsif p_sort_order2 = 'EMP_FIRST' then
	l_order_2 := 'first_name';
elsif p_sort_order2 = 'EMP_FAMILY' then
	l_order_2 := 'family_name';
else
	l_order_2 := null;
end if;
if p_sort_order3 = 'EMP_NO' then
	l_order_3 := 'employee_number';
elsif p_sort_order3 = 'EMP_FIRST' then
	l_order_3 := 'first_name';
elsif p_sort_order3 = 'EMP_FAMILY' then
	l_order_3 := 'family_name';
else
	l_order_3 := null;
end if;
open csr_get_payroll_name(p_payroll_id , p_effective_date);
fetch csr_get_payroll_name into l_header_pyrl_name;
close csr_get_payroll_name;
open csr_get_organization_name(p_organization_id);
fetch csr_get_organization_name into l_header_organization_name;
close csr_get_organization_name;
vXMLTable(vCtr).TagName := 'page_number_label';
vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAGE_NUMBER_LABEL');
vCtr := vCtr + 1;
vXMLTable(vCtr).TagName := 'of_label';
vXMLTable(vCtr).TagValue :=get_lookup_meaning('KW_FORM_LABELS','OF_LABEL');
vCtr := vCtr + 1;
If p_payroll_id is null then
open csr_get_bg_id_org(p_organization_id);
fetch csr_get_bg_id_org into l_org_bg_id;
close csr_get_bg_id_org;
set_currency_mask(l_org_bg_id);
	if p_org_structure_version_id is not null then
		if p_organization_id is null then
      		begin
			select distinct pose.organization_id_parent
			into   l_parent_id
			from   per_org_structure_elements pose
			where  pose.org_structure_version_id = p_org_structure_version_id
			and pose.organization_id_parent not in (select pose1.organization_id_child
            							from per_org_structure_elements pose1
									where pose1.org_structure_version_id = p_org_structure_version_id);
			exception
				when others then
				l_err := 1;
			end;
		end if;
		if l_err = 0 then
			/* CONDITION ONE */
					i:=1;
					f:=1;
					open csr_condition_one (p_organization_id ,p_org_structure_version_id,l_parent_id,p_effective_date );
					fetch csr_condition_one  into tab_org_data_init(i).org_name,tab_org_data_init(i).payroll_id;
					if csr_condition_one %notfound then
						close csr_condition_one;
					else
						close csr_condition_one ;
						open csr_condition_one (p_organization_id , p_org_structure_version_id,l_parent_id ,p_effective_date);
						loop
							fetch csr_condition_one  into tab_org_data(i).org_name,tab_org_data(i).payroll_id;
							i := i + 1;
							if csr_condition_one%notfound then
								close csr_condition_one;
								EXIT;
							end if;
						end loop;
					end if;
					open csr_distinct_pyrl (p_organization_id ,p_org_structure_version_id,l_parent_id,p_effective_date );
					fetch csr_distinct_pyrl  into tab_sum_data_init(f).payroll_id;
					if csr_distinct_pyrl %notfound then
						close csr_distinct_pyrl;
					else
						close csr_distinct_pyrl ;
						open csr_distinct_pyrl (p_organization_id , p_org_structure_version_id,l_parent_id ,p_effective_date);
						loop
							fetch csr_distinct_pyrl  into tab_sum_data(f).payroll_id;
							f := f + 1;
							if csr_distinct_pyrl%notfound then
								close csr_distinct_pyrl;
								EXIT;
							end if;
						end loop;
					end if;
		else
			/* CONDITION TWO */
			i:=1;
			f:=1;
			open csr_condition_two (p_organization_id ,p_effective_date);
			fetch csr_condition_two  into tab_org_data_init(i).org_name,tab_org_data_init(i).payroll_id;
			if csr_condition_two %notfound then
				close csr_condition_two;
			else
				close csr_condition_two ;
				open csr_condition_two (p_organization_id ,p_effective_date);
				loop
					fetch csr_condition_two  into tab_org_data(i).org_name,tab_org_data(i).payroll_id;
					i := i + 1;
					if csr_condition_two%notfound then
						close csr_condition_two;
						EXIT;
					end if;
				end loop;
			end if;
			open csr_org_only_distinct_pyrl (p_organization_id ,p_effective_date);
			fetch csr_org_only_distinct_pyrl  into tab_sum_data_init(f).payroll_id;
			if csr_org_only_distinct_pyrl %notfound then
				close csr_org_only_distinct_pyrl;
			else
				close csr_org_only_distinct_pyrl ;
				open csr_org_only_distinct_pyrl (p_organization_id ,p_effective_date);
				loop
					fetch csr_org_only_distinct_pyrl  into tab_sum_data(f).payroll_id;
					f := f + 1;
					if csr_org_only_distinct_pyrl%notfound then
						close csr_org_only_distinct_pyrl;
						EXIT;
					end if;
				end loop;
			end if;
		end if;
	elsif p_organization_id is null then
	       /* CONDITION THREE */
		i:=1;
			open csr_condition_three (p_effective_date);
			fetch csr_condition_three  into tab_org_data_init(i).org_name,tab_org_data_init(i).payroll_id;
			if csr_condition_three %notfound then
				close csr_condition_three;
			else
				close csr_condition_three ;
				open csr_condition_three (p_effective_date);
				loop
					fetch csr_condition_three  into tab_org_data(i).org_name,tab_org_data(i).payroll_id;
					i := i + 1;
					if csr_condition_three%notfound then
						close csr_condition_three;
						EXIT;
					end if;
				end loop;
			end if;
	else
		/* CONDITION TWO */
		i:=1;
		f:=1;
			open csr_condition_two (p_organization_id ,p_effective_date);
			fetch csr_condition_two  into tab_org_data_init(i).org_name,tab_org_data_init(i).payroll_id;
			if csr_condition_two %notfound then
				close csr_condition_two;
			else
				close csr_condition_two ;
				open csr_condition_two (p_organization_id ,p_effective_date);
				loop
					fetch csr_condition_two  into tab_org_data(i).org_name,tab_org_data(i).payroll_id;
					i := i + 1;
					if csr_condition_two%notfound then
						close csr_condition_two;
						EXIT;
					end if;
				end loop;
			end if;
			open csr_org_only_distinct_pyrl (p_organization_id ,p_effective_date);
			fetch csr_org_only_distinct_pyrl  into tab_sum_data_init(f).payroll_id;
			if csr_org_only_distinct_pyrl %notfound then
				close csr_org_only_distinct_pyrl;
			else
				close csr_org_only_distinct_pyrl ;
				open csr_org_only_distinct_pyrl (p_organization_id ,p_effective_date);
				loop
					fetch csr_org_only_distinct_pyrl  into tab_sum_data(f).payroll_id;
					f := f + 1;
					if csr_org_only_distinct_pyrl%notfound then
						close csr_org_only_distinct_pyrl;
						EXIT;
					end if;
				end loop;
			end if;

	end if;
ELSE
open csr_get_bg_id_pay(p_payroll_id , p_effective_date);
fetch csr_get_bg_id_pay into l_pay_bg_id;
close csr_get_bg_id_pay;
set_currency_mask(l_pay_bg_id);
	i:=1;
	open csr_get_orgs_for_payroll (p_payroll_id , p_effective_date);
	fetch csr_get_orgs_for_payroll into tab_org_data_init(i).org_name,tab_org_data_init(i).payroll_id;
	if csr_get_orgs_for_payroll%notfound then
		close csr_get_orgs_for_payroll ;
	else
		close csr_get_orgs_for_payroll ;
		open csr_get_orgs_for_payroll (p_payroll_id , p_effective_date);
		loop
			fetch csr_get_orgs_for_payroll into tab_org_data(i).org_name,tab_org_data(i).payroll_id;
			if csr_get_orgs_for_payroll%notfound then
				close csr_get_orgs_for_payroll ;
				EXIT;
			end if;
			i := i + 1;
		end loop;
	end if;
END IF;
If tab_org_data.count <>0 then
	For i in tab_org_data.first..tab_org_data.last
	LOOP
		if i = tab_org_data.first then
			/*if l_w_indicator = 2 then
				l_w_indicator := 0;
			end if;*/
			open csr_get_payroll_name (tab_org_data(i).payroll_id,p_effective_date);
			fetch csr_get_payroll_name into l_header_pyrl_name;
			close csr_get_payroll_name;
			l_header_organization_name := tab_org_data(i).org_name;
			vXMLTable(vCtr).TagName := 'payroll_register_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_REGISTER_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_start_date_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PERIOD_START_DATE_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_start_date_value';
			vXMLTable(vCtr).TagValue := trunc(p_effective_date,'MM');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_end_date_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PERIOD_END_DATE_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_end_date_value';
			vXMLTable(vCtr).TagValue := last_day(p_effective_date);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'date_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','DATE_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'date_value';
			vXMLTable(vCtr).TagValue := p_effective_date;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'organization_value';
			vXMLTable(vCtr).TagValue := l_header_organization_name;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'organization_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'payroll_name_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_NAME_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'payroll_name_value';
			vXMLTable(vCtr).TagValue := nvl(l_header_pyrl_name,' ');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'Employee_data_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','EMPLOYEE_DATA_LABEL');
			vCtr := vCtr + 1;
		elsif tab_org_data(i).org_name<>tab_org_data(i-1).org_name or tab_org_data(i).payroll_id<>tab_org_data(i-1).payroll_id then
				if l_emp_count <>0 then
					vXMLTable(vCtr).TagName := 'break_dummy';
					vXMLTable(vCtr).TagValue := '   ';
					vCtr := vCtr + 1;
				end if;
					l_emp_count := 0;
					l_w_indicator := 0;
			open csr_get_payroll_name (tab_org_data(i).payroll_id,p_effective_date);
			fetch csr_get_payroll_name into l_header_pyrl_name;
			close csr_get_payroll_name;
			l_header_organization_name := tab_org_data(i).org_name;
			vXMLTable(vCtr).TagName := 'payroll_register_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_REGISTER_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_start_date_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PERIOD_START_DATE_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_start_date_value';
			vXMLTable(vCtr).TagValue := trunc(p_effective_date,'MM');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_end_date_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PERIOD_END_DATE_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_end_date_value';
			vXMLTable(vCtr).TagValue := last_day(p_effective_date);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'date_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','DATE_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'date_value';
			vXMLTable(vCtr).TagValue := p_effective_date;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'organization_value';
			vXMLTable(vCtr).TagValue := l_header_organization_name;
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'organization_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'payroll_name_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_NAME_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'payroll_name_value';
			vXMLTable(vCtr).TagValue := nvl(l_header_pyrl_name,' ');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'Employee_data_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','EMPLOYEE_DATA_LABEL');
			vCtr := vCtr + 1;
		end if;
			open csr_get_details (tab_org_data(i).payroll_id, p_effective_date , tab_org_data(i).org_name , l_order_1 , l_order_2 , l_order_3);
			fetch csr_get_details into tab_dets_data_init(j).r_assact_id,
				tab_dets_data_init(j).r_org_pay_id,tab_dets_data_init(j).r_full_name,tab_dets_data_init(j).r_emp_no,
				tab_dets_data_init(j).r_org_name,tab_dets_data_init(j).r_position,tab_dets_data_init(j).r_cost_center,
				tab_dets_data_init(j).r_nationality,tab_dets_data_init(j).r_job,tab_dets_data_init(j).r_title,
				tab_dets_data_init(j).r_first_name ,tab_dets_data_init(j).r_family_name ,
				tab_dets_data_init(j).r_payroll_name,tab_dets_data_init(j).r_ytd_earning,tab_dets_data_init(j).r_ytd_deduction;
			If csr_get_details % notfound then
				close csr_get_details;
			else
				j := 1;
				close csr_get_details;
				open csr_get_details (tab_org_data(i).payroll_id,p_effective_date,tab_org_data(i).org_name, l_order_1 , l_order_2 , l_order_3);
				LOOP
					if  l_w_indicator = 2 then
							l_w_indicator := 0;
						if l_emp_count <>0 then /***************???????????????????????***************/
						open csr_get_payroll_name (tab_org_data(i).payroll_id,p_effective_date);
						fetch csr_get_payroll_name into l_header_pyrl_name;
						close csr_get_payroll_name;
						l_header_organization_name := tab_org_data(i).org_name;
						vXMLTable(vCtr).TagName := 'payroll_register_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_REGISTER_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'period_start_date_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PERIOD_START_DATE_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'period_start_date_value';
						vXMLTable(vCtr).TagValue := trunc(p_effective_date,'MM');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'period_end_date_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PERIOD_END_DATE_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'period_end_date_value';
						vXMLTable(vCtr).TagValue := last_day(p_effective_date);
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'date_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','DATE_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'date_value';
						vXMLTable(vCtr).TagValue := p_effective_date;
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'organization_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'organization_value';
						vXMLTable(vCtr).TagValue := l_header_organization_name;
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'payroll_name_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_NAME_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'payroll_name_value';
						vXMLTable(vCtr).TagValue := nvl(l_header_pyrl_name,' ');
						vCtr := vCtr + 1;
					end if; /*******????????????????????????????????**********/
						/*
						vXMLTable(vCtr).TagName := 'Employee_data_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','EMPLOYEE_DATA_LABEL');
						vCtr := vCtr + 1;
						*/
					end if;
					fetch csr_get_details into tab_dets_data(j).r_assact_id,
					tab_dets_data(j).r_org_pay_id,tab_dets_data(j).r_full_name,tab_dets_data(j).r_emp_no,
					tab_dets_data(j).r_org_name,tab_dets_data(j).r_position,tab_dets_data(j).r_cost_center,
					tab_dets_data(j).r_nationality,tab_dets_data(j).r_job,tab_dets_data(j).r_title,
					tab_dets_data(j).r_first_name ,tab_dets_data(j).r_family_name ,tab_dets_data(j).r_payroll_name,
					tab_dets_data(j).r_ytd_earning,tab_dets_data(j).r_ytd_deduction;
				exit when csr_get_details%notfound;
					/* POPULATE THE XML for emp details*/
					vXMLTable(vCtr).TagName := 'employee_name_label';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','EMPLOYEE_NAME_LABEL');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'employee_name_value';
					vXMLTable(vCtr).TagValue := nvl(substr(tab_dets_data(j).r_full_name,1,120),' ');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'ul_1';
					vXMLTable(vCtr).TagValue := '-      -';
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'alternate_name_label';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','ALTERNATE_NAME_LABEL');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'alternate_name_value';
					vXMLTable(vCtr).TagValue := substr((tab_dets_data(j).r_first_name || ' '||tab_dets_data(j).r_family_name),1,120) ;
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'cost_center_label';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','COST_CENTER_LABEL');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'cost_center_value';
					vXMLTable(vCtr).TagValue := tab_dets_data(j).r_cost_center;
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'organization_name_label';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_NAME_LABEL');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'organization_name_value';
					vXMLTable(vCtr).TagValue := nvl(tab_dets_data(j).r_org_name,' ');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'nationality_label';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','NATIONALITY_LABEL');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'nationality_value';
					vXMLTable(vCtr).TagValue := nvl(tab_dets_data(j).r_nationality,' ');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'job_label';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','JOB_LABEL_PYRG');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'job_value';
					vXMLTable(vCtr).TagValue := nvl(tab_dets_data(j).r_job,' ');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'position_label';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','POSITION_LABEL');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'position_value';
					vXMLTable(vCtr).TagValue := nvl(tab_dets_data(j).r_position,' ');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'employee_number_label';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','EMPLOYEE_NUMBER_PYRG');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'employee_number_value';
					vXMLTable(vCtr).TagValue := tab_dets_data(j).r_emp_no;
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'ul_2';
					vXMLTable(vCtr).TagValue := '-      -';
					vCtr := vCtr + 1;
					/* END POPULATE THE XML for emp details*/
					open csr_get_earn_det (tab_dets_data(j).r_assact_id);
					fetch csr_get_earn_det into tab_earn_data_init(k).r_payact_earn_id,
						tab_earn_data_init(k).r_assact_earn_id,tab_earn_data_init(k).r_earn_narrative,
						tab_earn_data_init(k).r_earn_numeric_value ,tab_earn_data_init(k).r_earn_element_type;
					If csr_get_earn_det % notfound then
						close csr_get_earn_det;
					else
						k := 1;
							vXMLTable(vCtr).TagName := 'earnings_label';
							vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','EARNINGS_LABEL');
							vCtr := vCtr + 1;
							vXMLTable(vCtr).TagName := 'amount_e_label';
							vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','AMOUNT_E_LABEL');
							vCtr := vCtr + 1;
						close csr_get_earn_det;
						open csr_get_earn_det(tab_dets_data(j).r_assact_id);
						LOOP
							fetch csr_get_earn_det into tab_earn_data(k).r_payact_earn_id,
							tab_earn_data(k).r_assact_earn_id,tab_earn_data(k).r_earn_narrative,
							tab_earn_data(k).r_earn_numeric_value ,tab_earn_data(k).r_earn_element_type;
						exit when csr_get_earn_det % notfound;
						emp_earn_sum := emp_earn_sum + nvl(to_number(tab_earn_data(k).r_earn_numeric_value,'FM9999999999999999999999990D000'),0);
							/* POPULATE THE XML for earnings details */
						/* END POPULATE THE XML for earnings details*/
							k := k + 1;
						END LOOP;
						close csr_get_earn_det;
					end if;
					open csr_get_ded_det (tab_dets_data(j).r_assact_id);
					fetch csr_get_ded_det into tab_ded_data_init(l).r_payact_ded_id,
						tab_ded_data_init(l).r_assact_ded_id,tab_ded_data_init(l).r_ded_narrative,
						tab_ded_data_init(l).r_ded_numeric_value ,tab_ded_data_init(l).r_ded_element_type;
					If csr_get_ded_det % notfound then
						close csr_get_ded_det;
					else
						l := 1;
						close csr_get_ded_det;
						open csr_get_ded_det(tab_dets_data(j).r_assact_id);
							vXMLTable(vCtr).TagName := 'deductions_label';
							vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','DEDUCTIONS_LABEL');
							vCtr := vCtr + 1;
							vXMLTable(vCtr).TagName := 'amount_d_label';
							vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','AMOUNT_E_LABEL');
							vCtr := vCtr + 1;
						LOOP
							fetch csr_get_ded_det into tab_ded_data(l).r_payact_ded_id,
							tab_ded_data(l).r_assact_ded_id,tab_ded_data(l).r_ded_narrative,
							tab_ded_data(l).r_ded_numeric_value ,tab_ded_data(l).r_ded_element_type;
						exit when csr_get_ded_det % notfound;
						emp_ded_sum := emp_ded_sum + nvl(to_number(tab_ded_data(l).r_ded_numeric_value,'FM9999999999999999999999990D000'),0);
							/* POPULATE THE XML for deductions details */
							/*END  POPULATE THE XML for deductions details */
							l := l + 1;
						END LOOP;
						close csr_get_ded_det;
					end if;
					if nvl(tab_ded_data.count,0) > nvl(tab_earn_data.count,0) then
						t := 1 ;
						if nvl(tab_earn_data.count,0) > 0 then
						For k in tab_earn_data.first..tab_earn_data.last
						LOOP
							if tab_dets_data(j).r_assact_id = tab_earn_data(k).r_assact_earn_id and tab_dets_data(j).r_assact_id = tab_ded_data(k).r_assact_ded_id then
								vXMLTable(vCtr).TagName := 'earnings_narrative';
								vXMLTable(vCtr).TagValue :=nvl( tab_earn_data(k).r_earn_narrative,' ');
								vCtr := vCtr + 1;
								vXMLTable(vCtr).TagName := 'earnings_value';
								--vXMLTable(vCtr).TagValue := to_char(tab_earn_data(k).r_earn_numeric_value,lg_format_mask);
								vXMLTable(vCtr).TagValue := to_char(to_number(tab_earn_data(k).r_earn_numeric_value),lg_format_mask);
								vCtr := vCtr + 1;
							IF upper(tab_ded_data(k).r_ded_narrative) <> upper('Social Insurance') then
								vXMLTable(vCtr).TagName := 'deductions_narrative';
								vXMLTable(vCtr).TagValue := nvl(tab_ded_data(k).r_ded_narrative,' ');
								vCtr := vCtr + 1;
								vXMLTable(vCtr).TagName := 'deductions_value';
								--vXMLTable(vCtr).TagValue :=to_char(tab_ded_data(k).r_ded_numeric_value,lg_format_mask);
								vXMLTable(vCtr).TagValue := to_char(to_number(tab_ded_data(k).r_ded_numeric_value),lg_format_mask);
								vCtr := vCtr + 1;
							END IF;
								t := t + 1;
							else
								EXIT;
							end if;
						END LOOP;
						end if;
							--if tab_earn_data.count > 0 then
							FOR k in /*tab_earn_data.last+1*/t..nvl(tab_ded_data.last,t)
							LOOP
							IF nvl(tab_ded_data.count,0) > 0 THEN
							if tab_dets_data(j).r_assact_id = tab_ded_data(k).r_assact_ded_id then
							IF upper(tab_ded_data(k).r_ded_narrative) <> upper('Social Insurance') then
							vXMLTable(vCtr).TagName := 'deductions_narrative';
							vXMLTable(vCtr).TagValue :=nvl( tab_ded_data(k).r_ded_narrative,' ');
							vCtr := vCtr + 1;
							vXMLTable(vCtr).TagName := 'deductions_value';
							--vXMLTable(vCtr).TagValue := to_char(tab_ded_data(k).r_ded_numeric_value,lg_format_mask);
							vXMLTable(vCtr).TagValue := to_char(to_number(nvl(tab_ded_data(k).r_ded_numeric_value,0)),lg_format_mask);
							vCtr := vCtr + 1;
							--org_ded_sum_try := org_ded_sum_try + tab_ded_data(k).r_ded_numeric_value;
							END IF;
							end if;
							END IF;
							END LOOP;
							--end if;
					elsif nvl(tab_ded_data.count,0) <= nvl(tab_earn_data.count,0) then
						t:=1;
						if nvl(tab_ded_data.count,0) > 0 then
							For k in nvl(tab_ded_data.first,0)..nvl(tab_ded_data.last,0)
							LOOP
								if tab_dets_data(j).r_assact_id = tab_earn_data(k).r_assact_earn_id and tab_dets_data(j).r_assact_id = tab_ded_data(k).r_assact_ded_id then
									vXMLTable(vCtr).TagName := 'earnings_narrative';
									vXMLTable(vCtr).TagValue :=nvl( tab_earn_data(k).r_earn_narrative,' ');
									vCtr := vCtr + 1;
									vXMLTable(vCtr).TagName := 'earnings_value';
									--vXMLTable(vCtr).TagValue := to_char(tab_earn_data(k).r_earn_numeric_value,lg_format_mask);
									vXMLTable(vCtr).TagValue := to_char(to_number(nvl(tab_earn_data(k).r_earn_numeric_value,0)),lg_format_mask);
									vCtr := vCtr + 1;
								IF upper(tab_ded_data(k).r_ded_narrative) <> upper('Social Insurance') then
									vXMLTable(vCtr).TagName := 'deductions_narrative';
									vXMLTable(vCtr).TagValue := nvl(tab_ded_data(k).r_ded_narrative,' ');
									vCtr := vCtr + 1;
									vXMLTable(vCtr).TagName := 'deductions_value';
									--vXMLTable(vCtr).TagValue :=to_char(tab_ded_data(k).r_ded_numeric_value,lg_format_mask);
									vXMLTable(vCtr).TagValue := to_char(to_number(nvl(tab_ded_data(k).r_ded_numeric_value,0)),lg_format_mask);
									vCtr := vCtr + 1;
								END IF;
									t:=t+1;
								else
									EXIT;
								end if;
							END LOOP;
						end if;
							--if tab_ded_data.count > 0 then
							FOR k in /*tab_ded_data.last+1*/t..nvl(tab_earn_data.last,t)
							LOOP
							IF nvl(tab_earn_data.count,0) > 0 THEN
								if tab_dets_data(j).r_assact_id = tab_earn_data(k).r_assact_earn_id then
									vXMLTable(vCtr).TagName := 'earnings_narrative';
									vXMLTable(vCtr).TagValue :=nvl( tab_earn_data(k).r_earn_narrative,' ');
									vCtr := vCtr + 1;
									vXMLTable(vCtr).TagName := 'earnings_value';
									--vXMLTable(vCtr).TagValue := to_char(tab_earn_data(k).r_earn_numeric_value,lg_format_mask);
									vXMLTable(vCtr).TagValue := to_char(to_number(nvl(tab_earn_data(k).r_earn_numeric_value,0)),lg_format_mask);
									vCtr := vCtr + 1;
								end if;
							END IF;
							END LOOP;
							--end if;
					end if;
					vXMLTable(vCtr).TagName := 'total_earnings_label';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TOTAL_EARNINGS_LABEL');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'total_amount_value';
					vXMLTable(vCtr).TagValue := to_char(emp_earn_sum,lg_format_mask);
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'total_deductions_label';
					vXMLTable(vCtr).TagValue :=get_lookup_meaning('KW_FORM_LABELS','TOTAL_DEDUCTIONS_LABEL');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'total_deductions_value';
					vXMLTable(vCtr).TagValue := to_char(emp_ded_sum,lg_format_mask);
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'net_pay_label_emp';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','NET_PAY_LABEL_EMP');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'net_pay_value_emp';
					vXMLTable(vCtr).TagValue := to_char((emp_earn_sum - emp_ded_sum),lg_format_mask);
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'YTD_earnings';
					vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','YTD_EARNINGS');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'YTD_earning_value';
					--vXMLTable(vCtr).TagValue := to_char(nvl(tab_dets_data(j).r_ytd_earning,0),lg_format_mask);
					vXMLTable(vCtr).TagValue := nvl(tab_dets_data(j).r_ytd_earning,0);
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'YTD_deduction';
					vXMLTable(vCtr).TagValue :=get_lookup_meaning('KW_FORM_LABELS','YTD_DEDUCTION');
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'YTD_deduction_value';
					--vXMLTable(vCtr).TagValue := to_char(nvl(tab_dets_data(j).r_ytd_deduction,0),lg_format_mask);
					vXMLTable(vCtr).TagValue := nvl(tab_dets_data(j).r_ytd_deduction,0);
					vCtr := vCtr + 1;
 					open csr_get_paymeth_det(tab_dets_data(j).r_assact_id);
					fetch csr_get_paymeth_det into tab_paymeth_data_init(m).r_org_paymeth_name,
					tab_paymeth_data_init(m).r_bank_name ,tab_paymeth_data_init(m).r_branch_name,
					tab_paymeth_data_init(m).r_account_number,tab_paymeth_data_init(m).r_amount,
					tab_paymeth_data_init(m).r_act_con_id,tab_paymeth_data_init(m).r_pay_status;
					If csr_get_paymeth_det%notfound then
						close csr_get_paymeth_det;
					else
						m := 1;
						close csr_get_paymeth_det;
						open csr_get_paymeth_det(tab_dets_data(j).r_assact_id);
							/* POPULATE THE XML for payment method details */
						vXMLTable(vCtr).TagName := 'pay_method_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAY_METHOD_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'status_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','STATUS_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'bank_name_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','BANK_NAME_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'branch_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','BRANCH_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'account_number_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','ACCOUNT_NUMBER_LABEL');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'amount_label';
						vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','AMOUNT_E_LABEL');
						vCtr := vCtr + 1;
						LOOP
							fetch csr_get_paymeth_det into tab_paymeth_data(m).r_org_paymeth_name,
							tab_paymeth_data(m).r_bank_name ,tab_paymeth_data(m).r_branch_name,
							tab_paymeth_data(m).r_account_number,tab_paymeth_data(m).r_amount,
							tab_paymeth_data(m).r_act_con_id,tab_paymeth_data(m).r_pay_status;
						exit when csr_get_paymeth_det%notfound;
						vXMLTable(vCtr).TagName := 'pay_method_value';
						vXMLTable(vCtr).TagValue := nvl(tab_paymeth_data(m).r_org_paymeth_name,' ');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'status_value';
						vXMLTable(vCtr).TagValue := nvl(tab_paymeth_data(m).r_pay_status,' ');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'bank_name_value';
						vXMLTable(vCtr).TagValue := nvl(tab_paymeth_data(m).r_bank_name ,' ');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'branch_value';
						vXMLTable(vCtr).TagValue := nvl(tab_paymeth_data(m).r_branch_name,' ');
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'account_number_value';
						vXMLTable(vCtr).TagValue :=tab_paymeth_data(m).r_account_number;
						vCtr := vCtr + 1;
						vXMLTable(vCtr).TagName := 'amount_value';
						--vXMLTable(vCtr).TagValue :=to_char(tab_paymeth_data(m).r_amount,lg_format_mask);
						vXMLTable(vCtr).TagValue := to_char(to_number(tab_paymeth_data(m).r_amount),lg_format_mask);
						vCtr := vCtr + 1;
							/* END POPULATE THE XML for payment method details */
							m := m + 1;
						END LOOP;
						close csr_get_paymeth_det;
					end if;
					vXMLTable(vCtr).TagName := 'break_line1';
					vXMLTable(vCtr).TagValue := '-      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      - ';
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'break_line2';
					vXMLTable(vCtr).TagValue := '-      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      - ';
					vCtr := vCtr + 1;
				l_emp_count := l_emp_count+1;
				l_w_indicator := l_w_indicator + 1;
				if l_emp_count = 2  then
					vXMLTable(vCtr).TagName := 'break_dummy';
					vXMLTable(vCtr).TagValue := '   ';
					vCtr := vCtr + 1;
					l_emp_count := 0;
				end if;
				emp_earn_sum := 0;
				emp_ded_sum := 0;
if tab_ded_data.count > 0 then
FOR i in tab_ded_data.first..tab_ded_data.last
LOOP
org_ded_sum_tot := org_ded_sum_tot + nvl(to_number(tab_ded_data(i).r_ded_numeric_value,'FM9999999999999999999999990D000'),0);
END LOOP;
end if;
if tab_earn_data.count > 0 then
FOR i in tab_earn_data.first..tab_earn_data.last
LOOP
org_earn_sum_tot := org_earn_sum_tot + nvl(to_number(tab_earn_data(i).r_earn_numeric_value,'FM9999999999999999999999990D000'),0);
END LOOP;
end if;
				tab_earn_data.delete;
				tab_ded_data .delete;
				j := j + 1;
				END LOOP;
			end if;
			close 	csr_get_details;
	END LOOP;
end if;
				if l_emp_count <> 0  then
					vXMLTable(vCtr).TagName := 'break_dummy';
					vXMLTable(vCtr).TagValue := '   ';
					vCtr := vCtr + 1;
				end if;
/******************/
			vXMLTable(vCtr).TagName := 'payroll_register_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_REGISTER_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_start_date_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PERIOD_START_DATE_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_start_date_value';
			vXMLTable(vCtr).TagValue := trunc(p_effective_date,'MM');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_end_date_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PERIOD_END_DATE_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'period_end_date_value';
			vXMLTable(vCtr).TagValue := last_day(p_effective_date);
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'date_label';
			vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','DATE_LABEL');
			vCtr := vCtr + 1;
			vXMLTable(vCtr).TagName := 'date_value';
			vXMLTable(vCtr).TagValue := p_effective_date;
			vCtr := vCtr + 1;
/******************/
			l_sum_flag := l_sum_flag + 1 ;
			if p_payroll_id is null then
				/********* Summary Organization Region *********/
				/*
				vXMLTable(vCtr).TagName := 'payroll_register_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_REGISTER_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'period_start_date_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PERIOD_START_DATE_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'period_start_date_value';
				vXMLTable(vCtr).TagValue := trunc(p_effective_date,'MM');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'period_end_date_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PERIOD_END_DATE_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'period_end_date_value';
				vXMLTable(vCtr).TagValue := last_day(p_effective_date);
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'date_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','DATE_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'date_value';
				vXMLTable(vCtr).TagValue := p_effective_date;
				vCtr := vCtr + 1;
				*/
				vXMLTable(vCtr).TagName := 'organization_summary_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_SUMMARY_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'organization_name_summary_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_NAME_SUM_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'organization_name_summary_value';
				vXMLTable(vCtr).TagValue := nvl(l_header_organization_name,' ');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_earnings_s_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TOTAL_EARNINGS_S_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_earnings_s_value';
				vXMLTable(vCtr).TagValue := to_char(org_earn_sum_tot,lg_format_mask);
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_deductions_s_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TOTAL_DEDUCTIONS_S_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_deductions_s_value';
				vXMLTable(vCtr).TagValue := to_char(org_ded_sum_tot,lg_format_mask);
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_pay_s_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TOTAL_PAY_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_pay_s_value';
				vXMLTable(vCtr).TagValue := to_char((org_earn_sum_tot - org_ded_sum_tot),lg_format_mask);
				vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'break_line3';
					vXMLTable(vCtr).TagValue := '-      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      - ';
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'break_line4';
					vXMLTable(vCtr).TagValue := '-      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      - ';
					vCtr := vCtr + 1;
				/********* Summary Payroll Region *********/
				vXMLTable(vCtr).TagName := 'payroll_summary';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_SUMMARY');
				vCtr := vCtr + 1;
		if nvl(tab_sum_data.count,0) > 0 then
			FOR i in tab_sum_data.first..tab_sum_data.last
			LOOP
				open csr_get_payroll_name (tab_sum_data(i).payroll_id, p_effective_date);
				fetch csr_get_payroll_name into l_header_pyrl_name;
				close csr_get_payroll_name;
				IF p_org_structure_version_id IS NOT NULL THEN
				  open csr_get_sum_earn (p_org_structure_version_id, p_organization_id, tab_sum_data(i).payroll_id, p_effective_date);
				  fetch csr_get_sum_earn into org_earn_sum_last;
				  close csr_get_sum_earn;
				ELSE
				  /*open csr_get_sum_earn_only_org (p_organization_id , tab_sum_data(i).payroll_id, p_effective_date);
				  fetch csr_get_sum_earn_only_org into org_earn_sum_last;
				  close csr_get_sum_earn_only_org;*/
				  l_e_temp_sum := 0;
				  l_e_tot_sum := 0;
                                                                                                          l_e_arch_assact_1 := NULL;
				  OPEN csr_seoo_split_1 (p_organization_id , tab_sum_data(i).payroll_id, p_effective_date);
				  LOOP
				    FETCH csr_seoo_split_1 INTO l_e_arch_assact_1;
				    IF csr_seoo_split_1%NOTFOUND then
				      CLOSE csr_seoo_split_1;
				      EXIT;
				    END IF;
				    IF l_e_arch_assact_1 IS NOT NULL THEN
				      OPEN csr_seoo_split_2(l_e_arch_assact_1);
				      FETCH csr_seoo_split_2 INTO l_e_temp_sum;
				      CLOSE csr_seoo_split_2;
				      l_e_tot_sum := l_e_tot_sum + l_e_temp_sum;
				      l_e_temp_sum := 0;
				    END IF;
				  END LOOP;
				  org_earn_sum_last := TO_CHAR(l_e_tot_sum);
                                                                                                        END IF;
				IF p_org_structure_version_id IS NOT NULL THEN
				  open csr_get_sum_ded (p_org_structure_version_id, p_organization_id, tab_sum_data(i).payroll_id, p_effective_date);
				  fetch csr_get_sum_ded into org_ded_sum_last;
				  close csr_get_sum_ded;
				ELSE
				  /*open csr_get_sum_ded_only_org (p_organization_id , tab_sum_data(i).payroll_id, p_effective_date);
				  fetch csr_get_sum_ded_only_org into org_ded_sum_last;
				  close csr_get_sum_ded_only_org;*/
				  l_d_temp_sum := 0;
				  l_d_tot_sum := 0;
                                                                                                          l_d_arch_assact_1 := NULL;
				  OPEN csr_sdoo_split_1(p_organization_id , tab_sum_data(i).payroll_id, p_effective_date);
				  LOOP
				    FETCH csr_sdoo_split_1 INTO l_d_arch_assact_1;
				    IF csr_sdoo_split_1%NOTFOUND THEN
				      CLOSE csr_sdoo_split_1;
				      EXIT;
				    END IF;
				    IF l_d_arch_assact_1 IS NOT NULL THEN
				      OPEN csr_sdoo_split_2(l_d_arch_assact_1);
				      FETCH csr_sdoo_split_2 INTO l_d_temp_sum;
				      CLOSE csr_sdoo_split_2;
				      l_d_tot_sum := l_d_tot_sum + l_d_temp_sum;
				      l_d_temp_sum := 0;
				    END IF;
				  END LOOP;
				  org_ded_sum_last := to_char(l_d_tot_sum);
                                                                                                        END IF;
				vXMLTable(vCtr).TagName := 'payroll_summary_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_SUMMARY_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'payroll_summary_value';
				vXMLTable(vCtr).TagValue := nvl(l_header_pyrl_name,' ');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_earnings_p_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TOTAL_EARNINGS_S_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_earnings_p_value';
				--vXMLTable(vCtr).TagValue := org_earn_sum_last;
				vXMLTable(vCtr).TagValue := to_char(to_number(org_earn_sum_last),lg_format_mask);
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_deductions_p_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TOTAL_DEDUCTIONS_S_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_deductions_p_value';
				--vXMLTable(vCtr).TagValue := to_char(org_ded_sum_last,lg_format_mask);
				vXMLTable(vCtr).TagValue := to_char(to_number(org_ded_sum_last),lg_format_mask);
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_pay_p_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TOTAL_PAY_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_pay_p_value';
				vXMLTable(vCtr).TagValue := to_char(to_number((org_earn_sum_last- org_ded_sum_last)),lg_format_mask);
				vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'break_line5';
					vXMLTable(vCtr).TagValue := '-      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      - ';
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'break_line6';
					vXMLTable(vCtr).TagValue := '-      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      - ';
					vCtr := vCtr + 1;
			END LOOP;
		end if;
			end if;
			if p_payroll_id is not null then
				/********* Summary Payroll Region *********/
				vXMLTable(vCtr).TagName := 'payroll_summary';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_SUMMARY');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'payroll_summary_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','PAYROLL_SUMMARY_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'payroll_summary_value';
				vXMLTable(vCtr).TagValue := nvl(l_header_pyrl_name,' ');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_earnings_p_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TOTAL_EARNINGS_S_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_earnings_p_value';
				vXMLTable(vCtr).TagValue := to_char(org_earn_sum_tot,lg_format_mask);
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_deductions_p_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TOTAL_DEDUCTIONS_S_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_deductions_p_value';
				vXMLTable(vCtr).TagValue := to_char(org_ded_sum_tot,lg_format_mask);
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_pay_p_label';
				vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TOTAL_PAY_LABEL');
				vCtr := vCtr + 1;
				vXMLTable(vCtr).TagName := 'total_pay_p_value';
				vXMLTable(vCtr).TagValue := to_char((org_earn_sum_tot- org_ded_sum_tot),lg_format_mask);
				vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'break_line5';
					vXMLTable(vCtr).TagValue := '-      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      - ';
					vCtr := vCtr + 1;
					vXMLTable(vCtr).TagName := 'break_line6';
					vXMLTable(vCtr).TagValue := '-      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      - ';
					vCtr := vCtr + 1;
			end if;
WritetoCLOB(p_report,l_xfdf_blob);
END GET_PAYROLL_REGISTER_DATA;
------------------------------------------------
----------------------------------------------
PROCEDURE WritetoCLOB (p_report in varchar2,
        p_xfdf_blob out nocopy blob)
IS
l_xfdf_string clob;
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(240);
l_str9 varchar2(240);
begin
hr_utility.set_location('Entered Procedure Write to clob ',100);
	l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
	       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields> ' ;
	l_str2 := '<field name="';
	l_str3 := '">';
	l_str4 := '<value>' ;
	l_str5 := '</value> </field>' ;
	l_str6 := '</fields> </xfdf>';
	l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
		       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields>
       			 </fields> </xfdf>';
	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
	if p_report = 'MAIN' then
		if vXMLTable.count > 0 then
			dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
        		FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
        			l_str8 := vXMLTable(ctr_table).TagName;
	        		l_str9 := vXMLTable(ctr_table).TagValue;
        			if (l_str9 is not null) then
				        /* Added CDATA to handle special characters Bug No:6685975 */
					l_str9 := '<![CDATA['||l_str9||']]>';
					dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
					dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
					dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
					dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
					dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
				elsif (l_str9 is null and l_str8 is not null) then
					dbms_lob.writeAppend(l_xfdf_string,length(l_str2),l_str2);
					dbms_lob.writeAppend(l_xfdf_string,length(l_str8),l_str8);
					dbms_lob.writeAppend(l_xfdf_string,length(l_str3),l_str3);
					dbms_lob.writeAppend(l_xfdf_string,length(l_str4),l_str4);
					dbms_lob.writeAppend(l_xfdf_string,length(l_str5),l_str5);
				else
				null;
				end if;
			END LOOP;
			dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
		else
			dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
		end if;
	else
		if vXMLTable_summary.count > 0 then
			dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
        		FOR ctr_table IN vXMLTable_summary.FIRST .. vXMLTable_summary.LAST LOOP
        			l_str8 := vXMLTable_summary(ctr_table).TagName;
	        		l_str9 := vXMLTable_summary(ctr_table).TagValue;
        			if (l_str9 is not null) then
				        /* Added CDATA to handle special characters Bug No:6685975 */
					l_str9 := '<![CDATA['||l_str9||']]>';
					dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
					dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
					dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
					dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
					dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
					dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
				elsif (l_str9 is null and l_str8 is not null) then
					dbms_lob.writeAppend(l_xfdf_string,length(l_str2),l_str2);
					dbms_lob.writeAppend(l_xfdf_string,length(l_str8),l_str8);
					dbms_lob.writeAppend(l_xfdf_string,length(l_str3),l_str3);
					dbms_lob.writeAppend(l_xfdf_string,length(l_str4),l_str4);
					dbms_lob.writeAppend(l_xfdf_string,length(l_str5),l_str5);
				else
				null;
				end if;
			END LOOP;
			dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
		else
			dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
		end if;
	end if;
	DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
	clob_to_blob(l_xfdf_string,p_xfdf_blob);
	hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
	--return p_xfdf_blob;
	EXCEPTION
		WHEN OTHERS then
	        HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	        HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;
----------------------------------------------------------------
Procedure  clob_to_blob(p_clob clob,
                          p_blob IN OUT NOCOPY Blob)
  is
    l_length_clob number;
    l_offset pls_integer;
    l_varchar_buffer varchar2(32767);
    l_raw_buffer raw(32767);
    l_buffer_len number:= 20000;
    l_chunk_len number;
    l_blob blob;
    g_nls_db_char varchar2(60);

    l_raw_buffer_len pls_integer;
    l_blob_offset    pls_integer := 1;

  begin
  	hr_utility.set_location('Entered Procedure clob to blob',120);
        select userenv('LANGUAGE') into g_nls_db_char from dual;
  	l_length_clob := dbms_lob.getlength(p_clob);
	l_offset := 1;
	while l_length_clob > 0 loop
		hr_utility.trace('l_length_clob '|| l_length_clob);
		if l_length_clob < l_buffer_len then
			l_chunk_len := l_length_clob;
		else
                        l_chunk_len := l_buffer_len;
		end if;
		DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
        	--l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
                l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char);
                l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char));

        	hr_utility.trace('l_varchar_buffer '|| l_varchar_buffer);
                --dbms_lob.write(p_blob,l_chunk_len, l_offset, l_raw_buffer);
                dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
                l_blob_offset := l_blob_offset + l_raw_buffer_len;

            	l_offset := l_offset + l_chunk_len;
	        l_length_clob := l_length_clob - l_chunk_len;
                hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
	end loop;
	hr_utility.set_location('Finished Procedure clob to blob ',130);
  end;

----------------------------------------------------------------
Procedure fetch_pdf_blob
	(p_report in varchar2,p_pdf_blob OUT NOCOPY blob)
IS
	BEGIN
		If p_report = 'MAIN' then
		/*Changing thequery for performance issue for bug 7632337 */
                /* trying to use FND_LOBS_N1  index */
			/*SELECT file_data
			INTO   p_pdf_blob
			FROM   fnd_lobs
			WHERE  file_id = (SELECT MAX(file_id)
			                  FROM    fnd_lobs
                	                         WHERE   file_name like '%PAY_PRG_ar_KW.pdf'); */
			SELECT file_data
			INTO   p_pdf_blob
			FROM   fnd_lobs
			WHERE  file_id =
			  ( SELECT MAX(file_id)
			  from FND_LOBS
			  WHERE PROGRAM_NAME = 'PAY_PRG_ar_KW.pdf'
			  and   program_tag= 'TMP:XDO:XDOTMPLATE1:SEED'
			  and   nvl(EXPIRATION_DATE ,trunc(sysdate)) = trunc(sysdate)
			  );
/*             	Else
        		SELECT file_data
			INTO   p_pdf_blob
			FROM   fnd_lobs
			WHERE  file_id = (SELECT MAX(file_id)
			                  FROM    fnd_lobs
                	                         WHERE   file_name like '%PAY_PRG_SUMMARY_ar_KW.pdf');*/
            	End If;
	EXCEPTION
        	when no_data_found then
              	null;
END fetch_pdf_blob;
-----------------------------------------------------------------
  FUNCTION get_lookup_meaning
    (p_lookup_type varchar2
    ,p_lookup_code varchar2)
    RETURN VARCHAR2 IS
    CURSOR csr_lookup IS
    select meaning
    from   hr_lookups
    where  lookup_type = p_lookup_type
    and    lookup_code = p_lookup_code;
    l_meaning hr_lookups.meaning%type;
  BEGIN
    OPEN csr_lookup;
    FETCH csr_lookup INTO l_Meaning;
    CLOSE csr_lookup;
    RETURN l_meaning;
  END get_lookup_meaning;
-----------------------------------------------------------------
END PAY_KW_PAYROLL_REGISTER ;

/
