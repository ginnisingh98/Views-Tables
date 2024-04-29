--------------------------------------------------------
--  DDL for Package Body PSP_PAYTRN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PAYTRN" AS
/* $Header: PSPPIPLB.pls 120.28.12010000.7 2010/04/10 04:43:11 amakrish ship $ */

--	Introduced the following for bug fix 2916848
g_precision		NUMBER;
g_ext_precision		NUMBER;
--	End of bug fix 2916848

--	Introduced the following for bug fix 3107800
g_bg_currency_code	psp_payroll_controls.currency_code%TYPE;
g_sob_currency_code	gl_sets_of_books.currency_code%TYPE;
g_exchange_rate_type	psp_payroll_controls.exchange_rate_type%TYPE;
g_uom			VARCHAR2(1);
g_entry_date_earned	DATE;
g_effective_start_date  DATE;  -- LD Added
g_effective_end_date    DATE;  -- LD Added
g_ignore_date_earned    VARCHAR(1); -- Bug 6046087
--	End of bug fix 3107800

l_payroll_id	number(9);	--- made this global for 3922347
PROCEDURE IMPORT_PAYTRANS(ERRBUF out NOCOPY varchar2,
				RETCODE out NOCOPY varchar2,
				p_period_type IN VARCHAR2 ,
					p_time_period_id IN NUMBER,
			p_business_group_id	IN	NUMBER,	-- Introduced for bug fix 3098050
			p_set_of_books_id	IN	NUMBER)	-- Introduced for bug fix 3098050
IS

-- Get Payroll start date , end date, payroll id
-- from per_time_periods_f based on time period id

CURSOR	get_payroll_id_csr is
SELECT	start_date, end_date, payroll_id
FROM	per_time_periods
WHERE	time_period_id = p_time_period_id ;

-- Declare variables for above cursor

l_start_date	date;
l_end_date	date;
l_total_num_rec		NUMBER DEFAULT 0;

/*****	Commented the following cursor for bug fix 3098050
CURSOR	get_set_of_books_csr is
SELECT	distinct(gl_set_of_books_id),business_group_id
FROM	pay_payrolls_f
WHERE	payroll_id = l_payroll_id and
	((l_start_date between effective_start_date and effective_end_date) or
	(l_end_date	between effective_start_date and effective_end_date) or
	(l_start_date <= effective_start_date and l_end_date >= effective_end_date))
	and gl_set_of_books_id is not null;
	end of comment for bug fix 3098050	*****/

/******************************************************************************************
The last check on gl_set_of_books added in lieu of multi-org responsiblity check
*******************************************************************************************

CURSOR	get_gl_flex_maps_csr is
SELECT	distinct(gl_set_of_books_id)
FROM	pay_payroll_gl_flex_maps
WHERE	payroll_id = l_payroll_id;


**************************************************************************************************
 The above cursor, and the following two profiles
 no longer required as we already have the sob id

l_profile_sob_id number (15);
l_profile_bg_id number(15);
l_set_of_books_id number(15);
************************************************************************************************/

l_resp_business_group_id number(15) DEFAULT p_business_group_id;	-- Defaulted parameter for bug fix 3098050
l_resp_set_of_books_id number (15) DEFAULT p_set_of_books_id;	-- Defaulted parameter for bug fix 3098050

-- Error Handling variables

l_error_api_name		varchar2(2000);
l_return_status			varchar2(1);
l_msg_count			number;
l_msg_data			varchar2(2000);
l_msg_index_out			number;
--
l_api_name			varchar2(30)	:= 'PSP_PAYTRN';
l_subline_message		varchar2(200);
l_TGL_REVB_ACC_DATE		varchar2(80); -- added for 3108109
l_TGL_DATE_USED		varchar2(80); -- added for 3108109
l_prev_accounting_date	date := to_date('01/01/1900','dd/mm/yyyy');	-- added for 3108109
l_action_parameter_group   VARCHAR2(30)  := psp_general.get_specific_profile('ACTION_PARAMETER_GROUPS'); -- added for bug 6661707
NO_COST_DATA_FOUND   EXCEPTION;
--- added following 2 cursors for 3108109
--- modified the below 2 cursors for bug 6661707

cursor get_tgl_date_used is
select nvl(parameter_value, 'P') parameter_value
from PAY_ACTION_PARAMETER_VALUES
where parameter_name = 'TGL_DATE_USED'
and action_parameter_group_id = l_action_parameter_group;

cursor get_tgl_revb_acc_date is
select nvl(parameter_value, 'P') parameter_value
from PAY_ACTION_PARAMETER_VALUES
where parameter_name = 'TGL_REVB_ACC_DATE'
and action_parameter_group_id = l_action_parameter_group;

/* to select all costed record for quickpay/ regular pay for a particular timeperiod . This would replace both the
get payroll actions cursor and get assignment actions cursor

*/
 CURSOR get_payroll_assig_actions_csr is
 select paa2.assignment_id, paa2.assignment_action_id ,
 	ppa2.payroll_id, ppa2.payroll_action_id, ppa1.effective_date,
 	ppa1.date_earned, ppa2.time_period_id,
 	ppa2.pay_advice_date ,
 	decode(ppa1.action_type,'V',decode(l_TGL_REVB_ACC_DATE,'C',ppa2.effective_date,
 						ppa1.effective_date),
 		decode(l_TGL_DATE_USED,'E',ppa1.date_earned,
 						ppa1.effective_date)) accounting_date
  from pay_payroll_actions ppa1, pay_assignment_actions paa1,
 	pay_payroll_actions ppa2,
 	pay_assignment_actions paa2
  where ppa1.payroll_id= l_payroll_id
 	and ppa1.date_earned between l_start_date and l_end_date
 	and ppa1.action_type IN ('R','Q','V') -- regular run, quick_pay, reversals
 	and ppa1.payroll_action_id = paa1.payroll_action_id
 	and EXISTS	(SELECT /*+ use_nl(PAI1) */ pai1.locked_action_id
 		FROM	pay_action_interlocks pai1
 		WHERE	paa1.assignment_action_id = pai1.locked_action_id
 			and pai1.locking_action_id = paa2.assignment_action_id)	-- End of changes for bug fix 3263333
 	and paa2.payroll_action_id = ppa2.payroll_action_id
 	and ppa2.action_type = 'C'
 	and ppa2.action_status='C'
 and exists (select assignment_action_id from pay_costs where
 assignment_action_id=paa2.assignment_action_id)
 UNION
 -- broke the decode for bug 6409008
 /* Now for 'B'*/
 (select paa1.assignment_id, paa1.assignment_action_id,
 	ppa1.payroll_id, ppa1.payroll_action_id, ppa1.effective_date, ppa1.date_earned,
 	ppa1.time_period_id, ppa1.pay_advice_date ,
 	decode(ppa2.action_type,'B',decode(l_TGL_REVB_ACC_DATE,'C',ppa1.effective_date,
 						ppa2.effective_date),
 		decode(l_TGL_DATE_USED,'E',ppa2.date_earned,
 						ppa2.effective_date)) accounting_date
  from pay_payroll_actions ppa1, pay_assignment_actions paa1,
 	pay_payroll_actions ppa2,
 	pay_assignment_actions paa2
 where   ppa2.action_type = 'B'
         and ppa2.date_earned between l_start_date and l_end_date
 	and ppa2.payroll_id=l_payroll_id
 	and ppa1.action_type='C' and
 	ppa1.action_status='C'
 	and ppa1.payroll_action_id=paa1.payroll_action_id
 	and EXISTS	(SELECT /*+ use_nl(PAI1) */ pai1.locked_action_id
 			FROM	pay_action_interlocks pai1
 			WHERE	paa1.assignment_action_id=pai1.locking_action_id
 				and pai1.locked_action_id = paa2.assignment_action_id)	-- End of changes for bug fix 3263333
 	and paa2.payroll_action_id = ppa2.payroll_action_id
 	and ppa2.action_type not in ('R','Q' ,'F','V')
 and exists
 (select assignment_action_id from pay_costs where assignment_action_id=paa1.assignment_action_id))
 UNION
 /* Now for '0' etc: */
 (select paa1.assignment_id, paa1.assignment_action_id,
 	ppa1.payroll_id, ppa1.payroll_action_id, ppa1.effective_date, ppa1.date_earned,
 	ppa1.time_period_id, ppa1.pay_advice_date ,
 	decode(ppa2.action_type,'B',decode(l_TGL_REVB_ACC_DATE,'C',ppa1.effective_date,
 						ppa2.effective_date),
 		decode(l_TGL_DATE_USED,'E',ppa2.date_earned,
 						ppa2.effective_date)) accounting_date
  from pay_payroll_actions ppa1, pay_assignment_actions paa1,
 	pay_payroll_actions ppa2,
 	pay_assignment_actions paa2
  where  ppa2.action_type <> 'B'
         and ppa1.effective_date between l_start_date and l_end_date
 	and ppa2.payroll_id=l_payroll_id
 	and ppa1.action_type='C' and
 	ppa1.action_status='C'
 	and ppa1.payroll_action_id=paa1.payroll_action_id
 	and EXISTS	(SELECT /*+ use_nl(PAI1) */ pai1.locked_action_id
 			FROM	pay_action_interlocks pai1
 			WHERE	paa1.assignment_action_id=pai1.locking_action_id
 				and pai1.locked_action_id = paa2.assignment_action_id)	-- End of changes for bug fix 3263333
 	and paa2.payroll_action_id = ppa2.payroll_action_id
 	and ppa2.action_type not in ('R','Q' ,'F','V')
 and exists
 (select assignment_action_id from pay_costs where assignment_action_id=paa1.assignment_action_id))
 order by 9 desc, 7 desc, 2 desc;   -- Bug 7116131;

/*added end*/

g_payroll_asg_rec get_payroll_assig_actions_csr%ROWTYPE;




/*
 The following two cursors commented out NOCOPY in lieu of bug fix#1004191





-- Get all transactions from pay_payroll_actions
--	based on effective_date between payroll_start_date
--	and payroll_end_date
CURSOR get_payroll_actions_csr is
SELECT payroll_id,
	payroll_action_id,
	effective_date,
	date_earned,
	time_period_id,
	pay_advice_date
FROM	PAY_PAYROLL_ACTIONS
WHERE	effective_date between l_start_date and l_end_date and
	payroll_id = l_payroll_id and
	action_type in ('R','Q') and action_status = 'C';
 action type changed from 'C' to (R. Q) to fix bug 1004191


--Declare a record for above cursor

g_payroll_rec get_payroll_actions_csr%ROWTYPE;

-- Get all transactions from pay_assignment_actions
--		based on payroll_action_id we got from payroll
--		actions we got from payroll actions cursor


CURSOR get_assignment_actions_csr is
SELECT a.assignment_id,
	a.assignment_action_id,
	b.person_id
FROM	PAY_ASSIGNMENT_ACTIONS a,
	PER_ASSIGNMENTS_F b
WHERE	a.payroll_action_id = g_payroll_rec.payroll_action_id
	and a.action_status = 'C'
	and (a.assignment_id = b.assignment_id and
	((l_start_date between effective_start_date and effective_end_date) or
	(l_end_date	between effective_start_date and effective_end_date) or
	(l_start_date <= effective_start_date and l_end_date >= effective_end_date)))
	and a.assignment_action_id in (select distinct(assignment_action_id) from pay_costs)
	order by a.assignment_id;


	check on effective date changed
	g_payroll_rec.effective_date between b.effective_start_date and b.effective_end_date)
 restriction on assignment_action id in selecting only those employees for whom arecord exists in pay_costs table:-
 fixed by Subha, :- Caltech
*/
--Declare variables for above cursor

l_assignment_id		PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ID%TYPE;
l_assignment_action_id	number		:= 0;
l_person_id		number		:= 0;
l_employee_name		varchar2(240);
l_cur_rec number;

CURSOR get_pay_costs_csr is
SELECT	a.cost_id,		--- REgular run results
	a.costed_value,
	a.debit_or_credit,
	a.balance_or_cost,
	a.cost_allocation_keyflex_id,
	b.element_type_id,
	DECODE(piv.uom, 'M', d.output_currency_code, 'STAT') output_currency_code,
	b.start_date,
	b.end_date,
	paya.date_earned,
	paya.action_type action_type,
	ptp.start_date tp_start_date,
	ptp.end_date tp_end_date,
	ptp.time_period_id,
	NVL(b.element_entry_id, (SELECT element_entry_id FROM pay_run_results prr where prr.run_result_id = b.source_id)) source_id
FROM	PAY_COSTS a, PAY_RUN_RESULTS b, PSP_ELEMENT_TYPES c, PAY_ELEMENT_TYPES_F d,
	pay_assignment_actions asga, pay_payroll_actions paya, per_time_periods ptp,
	pay_input_values_f piv
WHERE	a.assignment_action_id	= l_assignment_action_id and
	SUBSTR(piv.uom, 1, 1) IN ('M', g_uom) AND
	not exists ( select null
			from pay_element_entries_f pee
			where pee.element_entry_id = b.source_id and
				pee.creator_type in ('RR','EE')) and
	a.balance_or_cost = 'C' and
	NVL(a.costed_value,0) <> 0 and
	a.run_result_id = b.run_result_id and
	a.input_value_id = piv.input_value_id and
	c.business_group_id = l_resp_business_group_id and
	c.set_of_books_id = l_resp_set_of_books_id and
	( b.element_type_id = c.element_type_id and
	(c.start_date_active between l_start_date and l_end_date or
	nvl( c.end_date_active,to_date('4712/12/31' , 'YYYY/MM/DD'))	between l_start_date and l_end_date or
	(c.start_date_active <= l_start_date
	and nvl(c.end_date_active, to_date('4712/12/31' , 'YYYY/MM/DD')) >= l_end_date))) and
	b.element_type_id = d.element_type_id and
	(g_payroll_asg_rec.effective_date between d.effective_start_date and d.effective_end_date)
	and b.assignment_action_id = asga.assignment_action_id
	and paya.payroll_action_id = asga.payroll_action_id
	and ptp.payroll_id = l_payroll_id
	and paya.date_earned between ptp.start_date and ptp.end_date
union all
SELECT	a.cost_id,	--- retro run results
	a.costed_value,
	a.debit_or_credit,
	a.balance_or_cost,
	a.cost_allocation_keyflex_id,
	b.element_type_id,
	DECODE(piv.uom, 'M', d.output_currency_code, 'STAT') output_currency_code,
	b.start_date,
	b.end_date,
	paya.date_earned,
	'L' action_type,	---- retro
	ptp.start_date tp_start_date,
	ptp.end_date tp_end_date,
	ptp.time_period_id,
	NVL(b.element_entry_id, (SELECT element_entry_id FROM pay_run_results prr where prr.run_result_id = b.source_id)) source_id
FROM	PAY_COSTS a, PAY_RUN_RESULTS b, PSP_ELEMENT_TYPES c, PAY_ELEMENT_TYPES_F d,
	pay_assignment_actions asga, pay_payroll_actions paya, per_time_periods ptp,
	pay_input_values_f piv
WHERE	a.assignment_action_id	= l_assignment_action_id and
	SUBSTR(piv.uom, 1, 1) IN ('M', g_uom) AND
	exists ( select null
			from pay_element_entries_f pee
		where pee.element_entry_id = b.source_id and
				pee.creator_type in ('RR','EE')) and
	a.balance_or_cost = 'C' and
	NVL(a.costed_value,0) <> 0 and
	a.run_result_id = b.run_result_id and
	a.input_value_id = piv.input_value_id and
	c.business_group_id = l_resp_business_group_id and
	c.set_of_books_id = l_resp_set_of_books_id and
	( b.element_type_id = c.element_type_id and
	(c.start_date_active between l_start_date and l_end_date or
	nvl( c.end_date_active,to_date('4712/12/31' , 'YYYY/MM/DD'))	between l_start_date and l_end_date or
	(c.start_date_active <= l_start_date
	and nvl(c.end_date_active, to_date('4712/12/31' , 'YYYY/MM/DD')) >= l_end_date))) and
	b.element_type_id = d.element_type_id and
	(g_payroll_asg_rec.effective_date between d.effective_start_date and d.effective_end_date)
	and b.assignment_action_id = asga.assignment_action_id
	and paya.payroll_action_id = asga.payroll_action_id
	and ptp.payroll_id = l_payroll_id
	and b.end_date between ptp.start_date and ptp.end_date
order by time_period_id desc , 15 asc;

g_pay_costs_rec get_pay_costs_csr%ROWTYPE;

CURSOR check_payroll_lines_csr is
SELECT cost_id
FROM	PSP_PAYROLL_LINES
WHERE	cost_id = g_pay_costs_rec.cost_id;

--Declare variable for above cursor

l_cost_id	number(15)	:= 0;
l_line_id	number(9)	:= 0;

CURSOR get_difference_csr is
SELECT sum(pay_amount)
FROM	psp_payroll_sub_lines
WHERE	payroll_line_id = l_line_id;

l_subline_sum	NUMBER	:= 0;	-- Corrected to NUMBER from NUMBER(22, 2) for bug fix 2916848

CURSOR get_clearing_account_csr is
SELECT reversing_gl_ccid
FROM	psp_clearing_account
where set_of_books_id=l_resp_set_of_books_id
and business_group_id=l_resp_business_group_id
and payroll_id = l_payroll_id; -- Added for bug 5592964

/***************************************************************************************************

 Added the above checks on bg and sob for multi-org implementation

****************************************************************************************************/

l_clearing_account	number(15)	:= 0;

-- Default variables

l_payroll_source varchar2(30)	DEFAULT 'PAY';
l_rollback_flag varchar2(1)	DEFAULT 'N';
l_rollback_date date		DEFAULT NULL;
l_status_code	varchar2(1)	DEFAULT 'N';
l_balance_amount	NUMBER	DEFAULT 0;	-- Corrected to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_total_salary		NUMBER	DEFAULT 0;	-- Corrected to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_array_count integer;

-- Local variables

l_record_count number	:= 0;
l_rec_count	number		:= 0;
l_counter	number	:= 0;
-- reduced the precision to 2 digits to fix 2470954
--l_total_debit	NUMBER	:= 0;	-- Corrected to NUMBER from NUMBER(22, 2) for bug fix 2916848
--l_debit_count	number(9)	:= 0;
--l_total_credit	NUMBER	:= 0;	-- Corrected to NUMBER from NUMBER(22, 2) for bug fix 2916848
--l_credit_count	number(9)	:= 0;
l_payroll_line_amount	NUMBER	:= 0;	-- Corrected to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_payroll_sub_lines_amount NUMBER := 0;	-- Corrected to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_export_id	number(9):=NULL	;
l_gl_ccid	number(15)	:= 0;
x_rowid		varchar2(30)	:= NULL;
--Bug 1994421 : Zero Work Days Build -Introduced the new variable :lveerubh
l_reason	VARCHAR2(35)	DEFAULT	NULL;

/* User Defined Exception */
ZERO_WORK_DAYS EXCEPTION;
l_return_value		VARCHAR2(30); --Added for bug 2056877.
no_profile_exists		EXCEPTION;	--Added for bug 2056877.
no_val_date_matches	EXCEPTION;	--Added for bug 2056877.
no_global_acct_exists	EXCEPTION;	--Added for bug 2056877.
l_organization_account_id	NUMBER(9);		--Added for bug 2056877.
l_gms_posting_date		date;	-- for 2426343

--	Introduced the following for bug fix 2916848
/*
CURSOR	proration_option_cur IS
SELECT	pcv_information1
FROM	pqp_configuration_values pcv
WHERE	pcv.business_group_id = l_resp_business_group_id
AND	pcv_information_category = 'PSP_PRORATION';
*/

CURSOR	get_legislation_code_cur IS
SELECT	legislation_code
FROM	per_business_groups
WHERE	business_group_id = l_resp_business_group_id;

--l_proration_option	pqp_configuration_values.pcv_information1%TYPE;
l_legislation_code	per_business_groups.legislation_code%TYPE;
l_exchange_rate_type	psp_payroll_controls.exchange_rate_type%TYPE;
l_prev_currency_code	psp_payroll_controls.currency_code%TYPE;

TYPE v_num_array		IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE v_currency_code		IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
TYPE v_amount_array is table of NUMBER(15,5) INDEX by BINARY_INTEGER;

time_period_id_a v_num_array;
payroll_control_id_a v_num_array;
currency_code_a v_currency_code; -- Bug 6468271

l_parent_control_id number;
l_prev_time_period_id number;
l_period_name varchar2(500);
l_action_type varchar2(500);
l_asg_count integer;

l_prev_start_date date;
l_prev_end_date	date;

TYPE payroll_control_array is RECORD	(r_payroll_control_id	v_num_array,
					r_currency_code		v_currency_code,
					r_tot_dr	v_num_array,
					r_tot_cr	v_num_array,
					r_dr_amount v_amount_array,
					r_cr_amount v_amount_array,
					r_precision v_num_array,
					r_ext_precision v_num_array );

r_payroll_control_array payroll_control_array;
--	End of bug fix 2916848

--	Introduced the following for bug fix 3107800
CURSOR	sob_currency_code_cur IS
SELECT	currency_code
FROM	gl_sets_of_books gsob
WHERE	set_of_books_id = l_resp_set_of_books_id;
--	End of bug fix 3107800
l_run_id integer;
 cursor get_import_summary is
 select cnt_asg,
	fvl.meaning action_name,
	ptp.period_name,
	parent_payroll_control_id
	from (select count(distinct ppl.assignment_id) cnt_asg,
		ppl.payroll_action_type,
		ppc.time_period_id,
		ppc.parent_payroll_control_id
		from psp_payroll_controls ppc,
		psp_payroll_lines ppl
		where ppc.run_id = l_run_id
		and ppc.payroll_control_id = ppl.payroll_control_id
		group by ppl.payroll_action_type, ppc.time_period_id, ppc.parent_payroll_control_id) kount,
	fnd_lookup_values_vl fvl,
	per_time_periods ptp
 where kount.payroll_action_type = fvl.lookup_code
	and fvl.lookup_type = 'ACTION_TYPE'
	and sysdate between nvl(fvl.start_date_active,fnd_date.canonical_to_date('2000/01/31')) and nvl(fvl.end_date_active, fnd_date.canonical_to_date('4000/01/31'))
	and kount.time_period_id = ptp.time_period_id
	order by parent_payroll_control_id desc, ptp.time_period_id asc;
l_master_period_message varchar2(4000);
 cursor get_master_rec_mesg is
	select message_text
	from fnd_new_messages
	where application_id = 8403
	and message_name = 'PSP_IMP_INDICATE_MASTER'
	and language_code = userenv('LANG');
 cursor get_import_summary_heading is
 select meaning
	from fnd_lookup_values_vl
	where lookup_code in ('LABEL1_IMP_SUM', 'LABEL2_IMP_SUM', 'LABEL3_IMP_SUM', 'LABEL4_IMP_SUM')
	and lookup_type = 'PSP_MESSAGE_TEXT'
	and sysdate between start_date_active and nvl(end_date_active, fnd_date.canonical_to_date('4000/01/31'))
order by lookup_code;
l_count integer;
l_temp_heading varchar2(1000);
l_heading varchar2(1000);
-- Added for bug 5592964
l_gl_value VARCHAR2(1000);
l_clearing_account_value VARCHAR2(1000);

CURSOR	ee_date_earned_cur IS
SELECT	effective_start_date, effective_end_date,date_earned  --LD Dev
FROM	pay_element_entries_f
WHERE	element_entry_id = g_pay_costs_rec.source_id;

CURSOR	emphours_config_cur IS
SELECT	DECODE(pcv_information1, 'Y', 'H', 'M') employee_hours
FROM	pqp_configuration_values
WHERE	pcv_information_category = 'PSP_IMPORT_EMPLOYEE_HOURS'
AND	legislation_code IS NULL
AND	NVL(business_group_id, p_business_group_id) = p_business_group_id;

CURSOR	ee_ci_mapping_cur IS
SELECT	pcv_information1,
	pcv_information2,
	pcv_information3,
	pcv_information4,
	pcv_information5,
	pcv_information6
FROM	pqp_configuration_values
WHERE	pcv_information_category = 'PSP_ELEMENT_ENTRY_CI_MAPPING'
AND	legislation_code IS NULL
AND	NVL(business_group_id, p_business_group_id) = p_business_group_id;


/* Introduced Ignore date earned in element entries configuration type and the flexfield is named
   PSP_USE_DATE_EARNED, If the config type value = Y, then ignore date earned, else use date earned
   value */

CURSOR	ignore_date_earned_cur IS
SELECT	nvl(pcv_information1,'Y')    --6779790
FROM	pqp_configuration_values
WHERE	pcv_information_category = 'PSP_USE_DATE_EARNED'
AND	legislation_code IS NULL
AND	NVL(business_group_id, p_business_group_id) = p_business_group_id;   -- Bug 6046087

l_column_count			NUMBER;
l_gl_column			VARCHAR2(30);
l_pt_column			VARCHAR2(30);
l_tk_column			VARCHAR2(30);
l_aw_column			VARCHAR2(30);
l_eo_column			VARCHAR2(30);
l_et_column			VARCHAR2(30);
l_or_gl_ccid			NUMBER(15);
l_or_project_id			NUMBER(15);
l_or_task_id			NUMBER(15);
l_or_award_id			NUMBER(15);
l_or_expenditure_org_id		NUMBER(15);
l_or_expenditure_org_name	VARCHAR2(240);
l_or_expenditure_type		VARCHAR2(30);
l_project_number		VARCHAR2(30);
l_task_number			VARCHAR2(30);
l_award_number			VARCHAR2(30);
l_org_id			NUMBER(15);
l_value				VARCHAR2(240);
l_table				VARCHAR2(240);

CURSOR	exp_org_cur IS
SELECT	name
FROM	hr_all_organization_units hou
WHERE	organization_id = l_or_expenditure_org_id;

CURSOR	project_id_cur IS
SELECT	segment1
FROM	pa_projects_all
WHERE	project_id = l_or_project_id;

CURSOR	org_id_cur IS
SELECT	org_id
FROM	pa_projects_all
WHERE	project_id = l_or_project_id;

CURSOR	task_id_cur IS
SELECT	task_number
FROM	pa_tasks
WHERE	task_id = l_or_task_id;

CURSOR	award_id_cur IS
SELECT	award_number
FROM	gms_awards_all
WHERE	award_id = l_or_award_id;

CURSOR	expenditure_type_cur IS
SELECT	expenditure_type
FROM	pa_expenditure_types
WHERE	expenditure_type = l_or_expenditure_type;

BEGIN

 FND_MSG_PUB.Initialize;
 ---hr_utility.trace_on('Y','IMPORT-1');
 fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||  '	Import process started');
 hr_utility.trace('	Entering IMPORT_PAYTRANS');


/*******************************************************************************************

 These profiles no longer required as we pick up on basis of timeperiod


Changed from PSP profile to GL profile for 11i	:- Subha	03/Feb/2000
Added check on HR profile :- Business_Group_Id

 l_profile_sob_id	:= FND_PROFILE.VALUE('PSP_SET_OF_BOOKS');

 l_profile_sob_id := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
 l_profile_bg_id := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
************************************************************************************************/

--- added following two cursor s for 3108109
open get_tgl_date_used;
fetch get_tgl_date_used into l_TGL_DATE_USED;
if get_tgl_date_used%NOTFOUND then
 l_TGL_DATE_USED := 'P';
end if;
close get_tgl_date_used;

open get_tgl_revb_acc_date;
fetch get_tgl_revb_acc_date into l_TGL_REVB_ACC_DATE;
if get_tgl_revb_acc_date%NOTFOUND then
 l_TGL_REVB_ACC_DATE := 'P';
end if;
close get_tgl_revb_acc_date;

fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||  '	l_TGL_REVB_ACC_DATE, l_TGL_DATE_USED='||l_TGL_REVB_ACC_DATE ||','|| l_TGL_DATE_USED);

-- open get_payroll_dates_csr;
-- fetch get_payroll_dates_csr into l_set_of_books_id, l_start_date, l_end_date, l_payroll_id;

 open get_payroll_id_csr ;

	fetch get_payroll_id_csr into l_start_date, l_end_date, l_payroll_id;

 if get_payroll_id_csr%NOTFOUND then
	FND_MESSAGE.SET_NAME('PSP','PSP_INVALID_PERIOD');
	fnd_msg_pub.add;
	close get_payroll_id_csr;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 end if;

 close get_payroll_id_csr ;

fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||  '	l_start_date, l_end_date, l_payroll_id='||l_start_date ||','|| l_end_date ||','|| l_payroll_id);

/*****	Commented the following for bug fix 3098050
	Following portion had been commented as henceforth from this bug fix onwards, BG/SOB values would
	be passed as parameters to the corresponding concurrenct request.
 open get_set_of_books_csr ;
 loop
	fetch get_set_of_books_csr into l_resp_set_of_books_id ,l_resp_business_group_id;
	EXIT WHEN get_set_of_books_csr%NOTFOUND ;
	l_record_count := l_record_count + 1;
	if l_record_count > 1 then
	FND_MESSAGE.SET_NAME('PSP','PSP_INVALID_NO_OF_BOOKS');
	fnd_msg_pub.add;
	close get_set_of_books_csr;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	end if;
 end loop;
 close get_set_of_books_csr;

 open get_set_of_books_csr ;
 fetch get_set_of_books_csr into l_resp_set_of_books_id ,l_resp_business_group_id;
 if get_set_of_books_csr%NOTFOUND then
	FND_MESSAGE.SET_NAME('PSP','PSP_NO_SET_OF_BOOKS');
	fnd_msg_pub.add;
	close get_set_of_books_csr;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 elsif NVL(l_resp_set_of_books_id, 0) = 0 then
	FND_MESSAGE.SET_NAME('PSP','PSP_PI_NO_SOB_FOR_PAYROLL');
	fnd_msg_pub.add;
	close get_set_of_books_csr;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 end if;

 close get_set_of_books_csr;
	End of comment for bug fix 3098050	*****/

--	Introduced the following for bug fix 3107800
	g_bg_currency_code := psp_general.get_currency_code(l_resp_business_group_id);

	OPEN sob_currency_code_cur;
	FETCH sob_currency_code_cur INTO g_sob_currency_code;
	CLOSE sob_currency_code_cur;
--	End of bug fix 3107800

	OPEN emphours_config_cur;
	FETCH emphours_config_cur INTO g_uom;
	CLOSE emphours_config_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||  '	g_sob_currency_code, g_uom ='||g_sob_currency_code ||','|| g_uom );

	OPEN ee_ci_mapping_cur;
	FETCH ee_ci_mapping_cur INTO l_gl_column, l_pt_column, l_tk_column, l_aw_column, l_eo_column, l_et_column;
	CLOSE ee_ci_mapping_cur;

	-- Bug 6046087
	OPEN ignore_date_earned_cur;
	FETCH ignore_date_earned_cur INTO g_ignore_date_earned;
	CLOSE ignore_date_earned_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||  '	g_ignore_date_earned = '||g_ignore_date_earned);

	l_column_count := 0;
	IF (l_pt_column IS NOT NULL) THEN
		l_column_count := l_column_count + 1;
	END IF;

	IF (l_tk_column IS NOT NULL) THEN
		l_column_count := l_column_count + 1;
	END IF;

	IF (l_eo_column IS NOT NULL) THEN
		l_column_count := l_column_count + 1;
	END IF;

	IF (l_et_column IS NOT NULL) THEN
		l_column_count := l_column_count + 1;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||  '	l_column_count ='||l_column_count );

	IF (l_column_count > 1) AND (l_column_count < 4) THEN
		fnd_message.set_name('PSP', 'PSP_EE_INCOMPLETE_CI');
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


--	Introduced the following for bug fix 2916848
/*
	OPEN proration_option_cur;
	FETCH proration_option_cur INTO l_proration_option;
	IF (proration_option_cur%NOTFOUND) THEN
		l_proration_option := 'PAY';
		OPEN get_legislation_code_cur;
		FETCH get_legislation_code_cur INTO l_legislation_code;
		CLOSE get_legislation_code_cur;
		IF (l_legislation_code = 'US') THEN
			l_proration_option := 'PSP';
		END IF;
	END IF;
	CLOSE proration_option_cur;

*/

--	End of bug fix 2916848

-- Verify clearing account in psp_clearing_accounts
--	if not found or is 0 exit with error.

 open get_clearing_account_csr;
 fetch get_clearing_account_csr into l_clearing_account;
 if get_clearing_account_csr%NOTFOUND or l_clearing_account = 0 then
	FND_MESSAGE.SET_NAME('PSP','PSP_NO_CLEARING_ACCOUNT');
	fnd_msg_pub.add;
	close get_clearing_account_csr;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 end if;
 close get_clearing_account_csr;

 fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||  '	l_clearing_account ='||l_clearing_account );

	/* Following code is added for bug 2056877 ,Added validation for generic suspense account */
		l_return_value := psp_general.find_global_suspense(l_end_date,
							l_resp_business_group_id,
							l_resp_set_of_books_id,
							l_organization_account_id );
		/* --------------------------------------------------------------------
			Valid return values are
			PROFILE_VAL_DATE_MATCHES	Profile and Value and Date matching 'G'
			NO_PROFILE_EXISTS		No Profile
			NO_VAL_DATE_MATCHES		Profile and Either Value/date do not
						match with 'G'
			NO_GLOBAL_ACCT_EXISTS	No 'G' exists
			---------------------------------------------------------------------- */
			IF l_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
		NULL;
		ELSIF l_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
				RAISE no_global_acct_exists;
		ELSIF l_return_value = 'NO_VAL_DATE_MATCHES' THEN
			RAISE no_val_date_matches;
		ELSIF l_return_value = 'NO_PROFILE_EXISTS' THEN
			RAISE no_profile_exists;
		END IF; -- Bug 2056877.
 g_start_date	:= l_start_date;
 g_end_date	:= l_end_date;

 /* Commented as this code serves no purpose
 --dbms_output.PUT_LINE('................1');
 open get_payroll_assig_actions_csr;
 fetch get_payroll_assig_actions_csr into g_payroll_asg_rec;

 IF get_payroll_assig_actions_csr%NOTFOUND then
	raise NO_DATA_FOUND;
	close get_payroll_assig_actions_csr;
 END IF;
 close get_payroll_assig_actions_csr;    */

 SELECT psp_st_run_id_s.nextval
 INTO l_run_id
 FROM dual;

	open get_payroll_assig_actions_csr;

	fetch get_payroll_assig_actions_csr into g_payroll_asg_rec;
			l_assignment_id:=g_payroll_asg_rec.assignment_id;
			l_assignment_action_id:=g_payroll_asg_rec.assignment_action_id;
	if get_payroll_assig_actions_csr%NOTFOUND then
		raise NO_DATA_FOUND;
		close get_payroll_assig_actions_csr;
	end if;
	close get_payroll_assig_actions_csr;

	open get_payroll_assig_actions_csr;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||  '       **************************************************************');
	hr_utility.trace('       **************************************************************');

	LOOP

	fetch get_payroll_assig_actions_csr into g_payroll_asg_rec;
			l_assignment_id:=g_payroll_asg_rec.assignment_id;
			l_assignment_action_id:=g_payroll_asg_rec.assignment_action_id;

		SELECT	DISTINCT person_id
		INTO	l_person_id
		FROM	per_all_assignments_f
		WHERE	assignment_id = l_assignment_id;



	EXIT WHEN get_payroll_assig_actions_csr%NOTFOUND;	-- Exit when last record is reached
	BEGIN
-- moving calendar logic to LOOP of get_pay_costs_csr




	-- Get all transactions from pay_costs table based on
		-- assignment_action_id we got from assignment actions


		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||  '	l_assigment_id, l_assignment_action_id, p_time_period_id = '||l_assignment_id||','||
			l_assignment_action_id||','||p_time_period_id);

		hr_utility.trace('l_assignment_id = '||l_assignment_id);
		hr_utility.trace('l_assignment_action_id = '||l_assignment_action_id);
		hr_utility.trace('p_time_period_id = '||p_time_period_id);
		hr_utility.trace('g_payroll_asg_rec.effective_date = '||g_payroll_asg_rec.effective_date);

		OPEN get_pay_costs_csr;
		FETCH get_pay_costs_csr into g_pay_costs_rec;
		IF get_pay_costs_csr%NOTFOUND then
		hr_utility.trace('	get_pay_costs_csr NO_DATA_FOUND l_assignment_action_id = '||l_assignment_action_id);
		raise NO_COST_DATA_FOUND;
		close get_pay_costs_csr;
		END IF;
		close get_pay_costs_csr;
		l_prev_time_period_id := null;
		l_prev_start_date := TO_DATE('1','j');
		l_prev_end_date := TO_DATE('1','j');

		hr_utility.trace('	opening get_pay_costs_csr for l_assignment_action_id = '||l_assignment_action_id);

		OPEN get_pay_costs_csr;
		LOOP   --LOOP1 begin
		BEGIN
		fetch get_pay_costs_csr into g_pay_costs_rec;
		EXIT WHEN get_pay_costs_csr%NOTFOUND ;

		hr_utility.trace('	NEXT loop iteration');
		hr_utility.trace('	old value g_entry_date_earned: ' || to_char(g_entry_date_earned,'DD-MON-YYYY'));
		hr_utility.trace('	g_pay_costs_rec.source_id: ' || to_char(g_pay_costs_rec.source_id));

		hr_utility.trace('***************Printing values************');
		hr_utility.trace('g_pay_costs_rec.cost_id = '||g_pay_costs_rec.cost_id);
		hr_utility.trace('g_pay_costs_rec.costed_value = '||g_pay_costs_rec.costed_value);
		hr_utility.trace('g_pay_costs_rec.debit_or_credit = '||g_pay_costs_rec.debit_or_credit);
		hr_utility.trace('g_pay_costs_rec.balance_or_cost = '||g_pay_costs_rec.balance_or_cost);
		hr_utility.trace('g_pay_costs_rec.cost_allocation_keyflex_id = '||g_pay_costs_rec.cost_allocation_keyflex_id);
		hr_utility.trace('g_pay_costs_rec.element_type_id = '||g_pay_costs_rec.element_type_id);
		hr_utility.trace('g_pay_costs_rec.output_currency_code = '||g_pay_costs_rec.output_currency_code);
		hr_utility.trace('g_pay_costs_rec.start_date = '||g_pay_costs_rec.start_date);
		hr_utility.trace('g_pay_costs_rec.end_date = '||g_pay_costs_rec.end_date);
		hr_utility.trace('g_pay_costs_rec.date_earned = '||g_pay_costs_rec.date_earned);
		hr_utility.trace('g_pay_costs_rec.action_type = '||g_pay_costs_rec.action_type);
		hr_utility.trace('g_pay_costs_rec.tp_start_date = '||g_pay_costs_rec.tp_start_date);
		hr_utility.trace('g_pay_costs_rec.tp_end_date = '||g_pay_costs_rec.tp_end_date);
		hr_utility.trace('g_pay_costs_rec.time_period_id = '||g_pay_costs_rec.time_period_id);
		hr_utility.trace('g_pay_costs_rec.source_id = '||g_pay_costs_rec.source_id);
		hr_utility.trace('***************Continue************');


		g_entry_date_earned := NULL;

		hr_utility.trace('	set to null - g_entry_date_earned: ' || to_char(g_entry_date_earned,'DD-MON-YYYY'));

		OPEN ee_date_earned_cur;
		FETCH ee_date_earned_cur INTO g_effective_start_date, g_effective_end_date, g_entry_date_earned; -- LD Added
		CLOSE ee_date_earned_cur;

		hr_utility.trace('	after cursor g_effective_start_date: ' || to_char(g_effective_start_date,'DD-MON-YYYY'));
		hr_utility.trace('	after cursor g_effective_end_date: ' || to_char(g_effective_end_date,'DD-MON-YYYY'));
		hr_utility.trace('	after cursor g_entry_date_earned: ' || to_char(g_entry_date_earned,'DD-MON-YYYY'));
		hr_utility.trace('	g_pay_costs_rec.date_earned: ' || to_char(g_pay_costs_rec.date_earned,'DD-MON-YYYY'));

		/* Commented for bug 6046087
		-- Bug 5642002: get the element date if available
		g_start_date := NVL(NVL(g_entry_date_earned, g_pay_costs_rec.start_date), g_pay_costs_rec.tp_start_date);
		g_end_date := NVL(NVL(g_entry_date_earned, g_pay_costs_rec.end_date), g_pay_costs_rec.tp_end_date);
		*/

		-- Introduced the following IF - END IF for Bug 6046087
		IF (g_ignore_date_earned = 'Y') THEN
		   g_start_date := 	 g_pay_costs_rec.tp_start_date;
		   g_end_date   :=	 g_pay_costs_rec.tp_end_date;

		   hr_utility.trace('IF	cost_id, start_Date,
		   			end_Date, tp_id , action_type='||g_pay_costs_rec.cost_id||','||
		   			g_pay_costs_rec.tp_start_date||','||g_pay_costs_rec.tp_end_date||','||
					g_pay_costs_rec.time_period_id||','||g_pay_costs_rec.action_type);

		ELSE
		   -- Moved the following statement inside ELSE clause for bug 8993953 to avoid overrides
  		   g_pay_costs_rec.date_earned := NVL(g_entry_date_earned, g_pay_costs_rec.date_earned);

		   hr_utility.trace('	after nvl condition g_pay_costs_rec.date_earned: ' || to_char(g_pay_costs_rec.date_earned,'DD-MON-YYYY'));

	           g_start_date := NVL(NVL(g_entry_date_earned, g_pay_costs_rec.start_date), g_pay_costs_rec.tp_start_date);
		   g_end_date := NVL(NVL(g_entry_date_earned, g_pay_costs_rec.end_date), g_pay_costs_rec.tp_end_date);

	           hr_utility.trace('ELSE	cost_id, start_Date,
					end_Date, tp_id , action_type='||g_pay_costs_rec.cost_id||','||
					g_pay_costs_rec.tp_start_date||','||g_pay_costs_rec.tp_end_date||','||
					g_pay_costs_rec.time_period_id||','||g_pay_costs_rec.action_type);
	        END IF;

	        hr_utility.trace('	g_start_date ' || to_char(g_start_date,'DD-MON-YYYY'));
	        hr_utility.trace('	g_end_date ' || to_char(g_end_date,'DD-MON-YYYY'));


		l_or_gl_ccid := NULL;
		l_or_project_id := NULL;
		l_or_task_id := NULL;
		l_or_award_id := NULL;
		l_or_expenditure_org_id := NULL;
		l_or_expenditure_type := NULL;

		IF ((l_gl_column IS NOT NULL) AND (l_pt_column IS NOT NULL)) THEN
			IF (l_aw_column IS NOT NULL) THEN
				BEGIN
					EXECUTE IMMEDIATE 'SELECT ' || l_gl_column || ', ' || l_pt_column || ', ' ||
						l_tk_column || ', ' || l_aw_column || ', ' || l_eo_column || ', ' || l_et_column ||
						' FROM	pay_element_entries_f WHERE element_entry_id = ' || g_pay_costs_rec.source_id ||
						' AND :g_date_earned BETWEEN effective_start_date AND effective_end_date'
					INTO l_or_gl_ccid, l_or_project_id, l_or_task_id, l_or_award_id, l_or_expenditure_org_id, l_or_expenditure_type
					USING g_pay_costs_rec.date_earned;
				EXCEPTION
					WHEN OTHERS THEN
						hr_utility.trace('	No Element Entry record found');
				END;
			ELSE
				BEGIN
					EXECUTE IMMEDIATE 'SELECT ' || l_gl_column || ', ' || l_pt_column || ', ' ||
						l_tk_column || ', ' || l_eo_column || ', ' || l_et_column ||
						' FROM	pay_element_entries_f WHERE element_entry_id = ' || g_pay_costs_rec.source_id ||
						' AND :g_date_earned BETWEEN effective_start_date AND effective_end_date'
					INTO l_or_gl_ccid, l_or_project_id, l_or_task_id, l_or_expenditure_org_id, l_or_expenditure_type
					USING g_pay_costs_rec.date_earned;
				EXCEPTION
					WHEN OTHERS THEN
						hr_utility.trace('	No Element Entry record found');
				END;
			END IF;
		ELSIF (l_gl_column IS NOT NULL) THEN
			BEGIN
				EXECUTE IMMEDIATE 'SELECT ' || l_gl_column ||
				' FROM	pay_element_entries_f WHERE element_entry_id = ' || g_pay_costs_rec.source_id ||
				' AND :g_date_earned BETWEEN effective_start_date AND effective_end_date'
				INTO l_or_gl_ccid
				USING g_pay_costs_rec.date_earned;
			EXCEPTION
				WHEN OTHERS THEN
					hr_utility.trace('	No Element Entry record found');
			END;
		ELSIF (l_pt_column IS NOT NULL) THEN
			IF (l_aw_column IS NOT NULL) THEN
				BEGIN
					EXECUTE IMMEDIATE 'SELECT ' || l_pt_column || ', ' || l_tk_column || ', ' ||
						l_aw_column || ', ' || l_eo_column || ', ' || l_et_column ||
						' FROM	pay_element_entries_f WHERE element_entry_id = ' ||
						g_pay_costs_rec.source_id ||
						' AND :g_date_earned BETWEEN effective_start_date AND effective_end_date'
					INTO l_or_project_id, l_or_task_id, l_or_award_id, l_or_expenditure_org_id, l_or_expenditure_type
					USING g_pay_costs_rec.date_earned;
				EXCEPTION
					WHEN OTHERS THEN
						hr_utility.trace('	No Element Entry record found');
				END;
			ELSE
				BEGIN
					EXECUTE IMMEDIATE 'SELECT ' || l_pt_column || ', ' || l_tk_column || ', ' ||
						l_eo_column || ', ' || l_et_column ||
						' FROM	pay_element_entries_f WHERE element_entry_id = ' ||
						g_pay_costs_rec.source_id ||
						' AND :g_date_earned BETWEEN effective_start_date AND effective_end_date'
					INTO l_or_project_id, l_or_task_id, l_or_expenditure_org_id, l_or_expenditure_type
					USING g_pay_costs_rec.date_earned;
				EXCEPTION
					WHEN OTHERS THEN
						hr_utility.trace('	No Element Entry record found');
				END;
			END IF;
		END IF;

		IF (l_or_project_id IS NOT NULL) THEN
			OPEN exp_org_cur;
			FETCH exp_org_cur INTO l_or_expenditure_org_name;
			IF (exp_org_cur%NOTFOUND) THEN
				SELECT	full_name
				INTO	l_employee_name
				FROM	per_people_f
				WHERE	person_id = l_person_id
				AND	g_pay_costs_rec.date_earned BETWEEN effective_start_date AND effective_end_date;
				l_value := 'Organization Id = ' || TO_CHAR(l_or_expenditure_org_id);
				l_table := 'HR_ORGANIZATION_UNITS';
				fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
				fnd_message.set_token('VALUE', l_value);
				fnd_message.set_token('TABLE', l_table);
				fnd_message.set_token('BATCH_NAME', NULL);
				fnd_message.set_token('PERSON_NAME', l_employee_name);
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			CLOSE exp_org_cur;

			OPEN project_id_cur;
			FETCH project_id_cur INTO l_project_number;
			IF (project_id_cur%NOTFOUND) THEN
				SELECT	full_name
				INTO	l_employee_name
				FROM	per_people_f
				WHERE	person_id = l_person_id
				AND	g_pay_costs_rec.date_earned BETWEEN effective_start_date AND effective_end_date;
				l_value := 'Project Id = ' || TO_CHAR(l_or_project_id);
				l_table := 'PA_PROJECTS_ALL';
				fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
				fnd_message.set_token('VALUE',l_value);
				fnd_message.set_token('TABLE',l_table);
				fnd_message.set_token('BATCH_NAME', NULL);
				fnd_message.set_token('PERSON_NAME', l_employee_name);
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			CLOSE project_id_cur;

			OPEN org_id_cur;
			FETCH org_id_cur INTO l_org_id;
			IF (org_id_cur%NOTFOUND) THEN
				SELECT	full_name
				INTO	l_employee_name
				FROM	per_people_f
				WHERE	person_id = l_person_id
				AND	g_pay_costs_rec.date_earned BETWEEN effective_start_date AND effective_end_date;
				l_value := 'Project Id = ' || TO_CHAR(l_or_project_id);
				l_table := 'PA_PROJECTS_ALL';
				fnd_message.set_name('PSP','PSP_ORG_VALUE_NOT_FOUND');
				fnd_message.set_token('VALUE',l_value);
				fnd_message.set_token('TABLE',l_table);
				fnd_message.set_token('BATCH_NAME', NULL);
				fnd_message.set_token('PERSON_NAME', l_employee_name);
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			CLOSE org_id_cur;

			OPEN task_id_cur;
			FETCH task_id_cur INTO l_task_number;
			IF (task_id_cur%NOTFOUND) THEN
				SELECT	full_name
				INTO	l_employee_name
				FROM	per_people_f
				WHERE	person_id = l_person_id
				AND	g_pay_costs_rec.date_earned BETWEEN effective_start_date AND effective_end_date;
				l_value := 'TaskId = ' || TO_CHAR(l_or_task_id);
				l_table := 'PA_TASKS';
				fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
				fnd_message.set_token('VALUE',l_value);
				fnd_message.set_token('TABLE',l_table);
				fnd_message.set_token('BATCH_NAME', NULL);
				fnd_message.set_token('PERSON_NAME', l_employee_name);
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			CLOSE task_id_cur;

			IF (l_or_award_id IS NOT NULL) THEN
				OPEN award_id_cur;
				FETCH award_id_cur INTO l_award_number;
				IF (award_id_cur%NOTFOUND) THEN
					SELECT	full_name
					INTO	l_employee_name
					FROM	per_people_f
					WHERE	person_id = l_person_id
					AND	g_pay_costs_rec.date_earned BETWEEN effective_start_date AND effective_end_date;
					l_value := 'Award Id = ' || TO_CHAR(l_or_award_id);
					l_table := 'GMS_AWARDS_ALL';
					fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
					fnd_message.set_token('VALUE',l_value);
					fnd_message.set_token('TABLE',l_table);
				fnd_message.set_token('BATCH_NAME', NULL);
				fnd_message.set_token('PERSON_NAME', l_employee_name);
					fnd_msg_pub.add;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
				CLOSE award_id_cur;
			END IF;

			OPEN expenditure_type_cur;
			FETCH expenditure_type_cur INTO l_award_number;
			IF (expenditure_type_cur%NOTFOUND) THEN
				SELECT	full_name
				INTO	l_employee_name
				FROM	per_people_f
				WHERE	person_id = l_person_id
				AND	g_pay_costs_rec.date_earned BETWEEN effective_start_date AND effective_end_date;
				l_value := 'Expenditure Type = ' || l_or_expenditure_type;
				l_table := 'PA_EXPENDITURE_TYPES';
				fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
				fnd_message.set_token('VALUE',l_value);
				fnd_message.set_token('TABLE',l_table);
				fnd_message.set_token('BATCH_NAME', NULL);
				fnd_message.set_token('PERSON_NAME', l_employee_name);
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			CLOSE expenditure_type_cur;
		END IF;

		--- recreate the calendar for reversal time period
		if g_pay_costs_rec.time_period_id <> nvl(l_prev_time_period_id, -1) OR
		g_start_date <> l_prev_start_date OR
		g_end_date <> l_prev_end_date
		then
		hr_utility.trace('	CHANGE IN TIME PERIOD ');
		l_prev_time_period_id := g_pay_costs_rec.time_period_id;
		l_prev_start_date := g_start_date;
		l_prev_end_date := g_end_date;

		-- Create an working calander (array) for this transaction.
		-- Array contains no of rows that is equal to no. of days that payroll period has.
		-- Each row will have either 'Y' if that day is working day or 'N' if
		-- that day is non-working day
		-- moved the calendar code inside the get_pay_costs cursor for handling of payroll reversals
--		CREATE_WORKING_CALENDAR;
		create_working_calendar(l_assignment_id);
		g_no_of_person_work_days	:= g_no_of_work_days;

	-- This procedure looks into per_assignments_f for assignment
	-- end date. If the assignment end date falls in to the payroll period,
	-- it updates the array rows with 'N' for the rows after the assignment end date.

		hr_utility.trace('	UPDATE_WCAL_ASG_END_DATE');
		UPDATE_WCAL_ASG_END_DATE(X_ASSIGNMENT_ID	=> l_assignment_id,
					X_RETURN_STATUS	=> l_return_status);
		if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
		l_error_api_name	:= 'UPDATE_WCAL_ASG_END_DATE : ';
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;

		hr_utility.trace('	UPDATE_WCAL_ASG_BEGIN_DATE');
		UPDATE_WCAL_ASG_BEGIN_DATE(X_ASSIGNMENT_ID	=> l_assignment_id,
					X_RETURN_STATUS	=> l_return_status);
		if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
		l_error_api_name	:= 'UPDATE_WCAL_ASG_BEGIN_DATE : ';
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;

-- This procedure looks into per_assignments_f for assignment
-- status. If the assignment status is 'Suspend' or 'Terminate' for any of the days
-- in the payroll period, it updates the working calendar array with 'N' for those days.

		hr_utility.trace('	UPDATE_WCAL_ASG_STATUS');
		UPDATE_WCAL_ASG_STATUS(X_ASSIGNMENT_ID	=> l_assignment_id,
					X_RETURN_STATUS	=> l_return_status);
		if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
		l_error_api_name	:= 'UPDATE_WCAL_ASG_STATUS : ';
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;
		hr_utility.trace('	AFTER UPDATE_WCAL_ASG_STATUS');
		begin
		l_export_id := null;

		for i in 1..time_period_id_a.count
		loop
			hr_utility.trace('	KKKK='||i);
		        if (g_pay_costs_rec.time_period_id = time_period_id_a(i)
		                    AND g_pay_costs_rec.output_currency_code = currency_code_a(i))  -- Bug 6468271
		        then
		           hr_utility.trace('	KXyy='||i);
		           l_export_id := payroll_control_id_a(i);
		           hr_utility.trace('	KXzy='||i);
		        end if;
		end loop;

		exception
		when others then
			l_period_name := sqlerrm;
			hr_utility.trace('	KKKK'||l_period_name);


		end;
		hr_utility.trace('	AFTER SET l_export_id');
	end if;

		hr_utility.trace('	Found cost record Cost_id, costed_value =' ||g_pay_costs_rec.cost_id||','||g_pay_costs_rec.costed_value);
-- Bug 1994421 : Zero Work Days Build - Assigned values to variables for processing non active assignments -lveerubh
		g_non_active_flag	:=	'N';
		g_hire_zero_Work_days	:=	'N';
		g_all_holiday_zero_work_days := 'N';
/* New procedure added for continuing if zero work days :- Caltech, Yale :- subha */

		/*IF ((g_entry_date_earned IS NULL) or (g_ignore_date_earned = 'Y')) THEN  -- Bug 6046087*/  --6779790
			CHECK_ZERO_WORK_DAYS(	X_ASSIGNMENT_ID => l_assignment_id,
					X_COSTED_VALUE => g_pay_costs_rec.costed_value,
					x_start_date	=> TRUNC(g_start_date),   --Bug 6046087
					x_end_date	=> TRUNC(g_end_date),   --Bug 6046087
					X_RETURN_STATUS => l_return_status);

			if l_return_status <> FND_API.G_RET_STS_SUCCESS then
				l_error_api_name := 'CHECK_ZERO_WORK_DAYS : ';
				RAISE ZERO_WORK_DAYS;
			end if;
		/*END IF;*/

		hr_utility.trace('	Before opening check_payroll_lines_csr');
		OPEN check_payroll_lines_csr;
		FETCH check_payroll_lines_csr into l_cost_id;

		hr_utility.trace('	After check_payroll_lines_csr - l_cost_id = '||l_cost_id);

		IF check_payroll_lines_csr%NOTFOUND then

			hr_utility.trace('	check_payroll_lines_csr%NOTFOUND');

			l_counter	:= l_counter + 1;

		---hr_utility.trace('	No data found in payroll_lines ');
		-- If first record insert a record in psp_payroll_controls


	hr_utility.trace('	l_counter = '||l_counter);
	IF l_counter > 0 then
--	Introduced for bug fix 2916848

                hr_utility.trace('	l_prev_currency_code, g_pay_costs_rec.output_currency_code  = '||l_prev_currency_code||','||
			g_pay_costs_rec.output_currency_code);
-- Commented this if condition for bug 9435225
--		IF nvl(l_prev_currency_code,g_pay_costs_rec.output_currency_code) <> g_pay_costs_rec.output_currency_code THEN
			l_prev_currency_code := g_pay_costs_rec.output_currency_code;
			l_export_id := NULL;
			FOR i IN 1..r_payroll_control_array.r_payroll_control_id.COUNT
			LOOP
				IF (r_payroll_control_array.r_currency_code(i) = l_prev_currency_code) THEN
					l_export_id := r_payroll_control_array.r_payroll_control_id(i);
					g_precision:= r_payroll_control_array.r_precision(i);
					g_ext_precision:= r_payroll_control_array.r_ext_precision(i);

					l_cur_rec:=i;

			EXIT;

				END IF;
			END LOOP;
--		END IF;

--	Introduced the following for bug fix 3107800
			IF (g_pay_costs_rec.output_currency_code = g_bg_currency_code AND
				g_bg_currency_code = g_sob_currency_code) THEN
				l_exchange_rate_type := NULL;
			ELSE
			l_exchange_rate_type := g_exchange_rate_type;
			IF (g_exchange_rate_type IS NULL OR
				l_prev_accounting_date <> g_payroll_asg_rec.accounting_date) THEN
				g_exchange_rate_type := hruserdt.get_table_value
					(p_bus_group_id	=>	l_resp_business_group_id,
					p_table_name		=>	'EXCHANGE_RATE_TYPES',
					p_col_name		=>	'Conversion Rate Type',
					p_row_value		=>	'PAY',
					p_effective_date	=>	g_payroll_asg_rec.accounting_date);
				l_prev_accounting_date := g_payroll_asg_rec.accounting_date; -- 3108109
				l_exchange_rate_type := g_exchange_rate_type;
			END IF;
			END IF;
--	End of bug fix 3107800

		IF (l_export_id IS NULL) THEN
--		End of bug fix 2916848

		SELECT PSP_PAYROLL_CONTROLS_S.NEXTVAL into l_export_id
			FROM DUAL;

			l_total_num_rec:= l_total_num_rec + 1;
			l_cur_rec:= l_total_num_rec;

			psp_general.get_currency_precision(g_pay_costs_rec.output_currency_code,
							g_precision,
						g_ext_precision);

			r_payroll_control_array.r_currency_code(l_cur_rec) := g_pay_costs_rec.output_currency_code;

			r_payroll_control_array.r_payroll_control_id(l_cur_rec) := l_export_id;

			r_payroll_control_array.r_tot_dr(l_cur_rec) := 0;
			r_payroll_control_array.r_tot_cr(l_cur_rec) := 0;
			r_payroll_control_array.r_cr_amount(l_cur_rec) := 0;
			r_payroll_control_array.r_dr_amount(l_cur_rec) := 0;
			r_payroll_control_array.r_precision(l_cur_rec):= g_precision;
			r_payroll_control_array.r_ext_precision(l_cur_rec):=g_ext_precision;


			l_prev_currency_code := g_pay_costs_rec.output_currency_code;


			PSP_PAYROLL_CONTROLS_PKG.INSERT_ROW(
				X_ROWID		=>	x_rowid,
				X_PAYROLL_CONTROL_ID	=>	l_export_id,
				X_PAYROLL_ACTION_ID	=>	g_payroll_asg_rec.payroll_action_id,
				X_PAYROLL_SOURCE_CODE	=>	l_payroll_source,
					X_SOURCE_TYPE		=>	'O',
				X_PAYROLL_ID		=>	l_payroll_id,
				X_TIME_PERIOD_ID	=> g_pay_costs_rec.time_period_id,
				X_BATCH_NAME		=>	NULL,
				X_NUMBER_OF_CR		=>	0,
				X_NUMBER_OF_DR		=>	0,
				X_TOTAL_DR_AMOUNT	=>	0,
				X_TOTAL_CR_AMOUNT	=>	0,
				X_SUBLINES_DR_AMOUNT	=>	NULL,
				X_SUBLINES_CR_AMOUNT	=>	NULL,
				X_DIST_CR_AMOUNT	=>	NULL,
				X_DIST_DR_AMOUNT	=>	NULL,
				X_OGM_DR_AMOUNT		=>	NULL,
				X_OGM_CR_AMOUNT		=>	NULL,
				X_GL_DR_AMOUNT		=>	NULL,
				X_GL_CR_AMOUNT		=>	NULL,
				X_STATUS_CODE		=>	l_status_code,
				X_MODE				=>	'R' ,
				X_GL_POSTING_OVERRIDE_DATE => NULL,
				X_GMS_POSTING_OVERRIDE_DATE => NULL,
				X_SET_OF_BOOKS_ID		=>l_resp_set_of_books_id,
				X_BUSINESS_GROUP_ID	=> l_resp_business_group_id ,
				X_GL_PHASE		=> NULL,
				X_GMS_PHASE		=> NULL,
				X_ADJ_SUM_BATCH_NAME	=> NULL,
--	Introduced the following for bug fix 2916848
				x_currency_code		=>	g_pay_costs_rec.output_currency_code,
				x_exchange_rate_type	=>	null,
				x_parent_payroll_control_id	=> l_parent_control_id);	--- exch rate =null for 3108109

			l_array_count := nvl(time_period_id_a.count,0) + 1;
			time_period_id_a(l_array_count) := g_pay_costs_rec.time_period_id;
			payroll_control_id_a(l_array_count ) := l_export_id;
			currency_code_a(l_array_count) := g_pay_costs_rec.output_currency_code; -- Bug 6468271

			update psp_payroll_controls
			set run_id = l_run_id
			where payroll_control_id = l_export_id;
		end if;
	END IF;	-- Introduced for bug fix 2916848
		if l_parent_control_id is null then
			l_parent_control_id := l_export_id;
		end if;


			PSP_GENERAL.GET_GL_CCID(
			P_PAYROLL_ID			=> l_payroll_id,
			P_SET_OF_BOOKS_ID		=> l_resp_set_of_books_id,
			P_COST_KEYFLEX_ID		=> g_pay_costs_rec.cost_allocation_keyflex_id,
			X_GL_CCID			=> l_gl_ccid);

		IF l_gl_ccid = 0 or l_gl_ccid IS NULL then
		l_error_api_name	:= 'GET_GL_CCID : ';
		fnd_message.set_name('PSP','PSP_NO_GL_FOR_COSTING');
		fnd_message.set_token('COST_ID', g_pay_costs_rec.cost_allocation_keyflex_id);
		fnd_msg_pub.add;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_gl_ccid <> l_clearing_account then
		l_gl_value := psp_general.get_gl_values(l_resp_set_of_books_id, l_gl_ccid);
		l_clearing_account_value := psp_general.get_gl_values(l_resp_set_of_books_id, l_clearing_account);
		l_error_api_name	:= 'GET_GL_CCID : ';
		fnd_message.set_name('PSP','PSP_CLEARING_ACCT_MISMATCH');
		fnd_message.set_token('GL_ACCOUNT', l_gl_value);
		fnd_message.set_token('CLEARING', l_clearing_account_value);
		fnd_msg_pub.add;
		hr_utility.trace('	fail kff ='|| g_pay_costs_rec.cost_allocation_keyflex_id);
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		hr_utility.trace('	pass kff ='|| g_pay_costs_rec.cost_allocation_keyflex_id);

		SELECT PSP_PAYROLL_LINES_S.NEXTVAL into l_line_id
		FROM DUAL;
		x_rowid := NULL;

 -- intro this IF-ENDIF and changed the next IF stmt to check gms_posting_date for 2426343

 hr_utility.trace('g_non_active_flag = '||g_non_active_flag);
 If g_non_active_flag = 'Y' then
	-- date earned will be the max date any child sub line can take as effective date.

	l_gms_posting_date := g_pay_costs_rec.date_earned;
	hr_utility.trace('l_gms_posting_date = '||l_gms_posting_date);

	psp_general.get_gms_effective_date(l_person_id, l_gms_posting_date);
	hr_utility.trace('After proc call - l_gms_posting_date = '||l_gms_posting_date);

	IF l_gms_posting_date is null then

	hr_utility.trace('l_gms_posting_date is null');

	hr_utility.trace('l_person_id = '||l_person_id);
	hr_utility.trace('g_pay_costs_rec.date_earned = '||g_pay_costs_rec.date_earned);

	hr_utility.trace('I might fail now');

	select distinct substr(full_name,1,50)
	into l_employee_name
	from per_people_f
	where person_id = l_person_id and
		g_pay_costs_rec.date_earned between effective_start_date and effective_end_date;

	hr_utility.trace('Am i successful');

	FND_MESSAGE.Set_Name('PSP', 'PSP_PI_PRMRY_ASG_INACTIVE');
	FND_MESSAGE.set_token('Employee',l_employee_name);
	FND_MSG_PUB.ADD;
	g_non_active_flag := 'E'; --ERROR, skip this assg, bcos not a single day it is active
	END IF;
 END IF;

	hr_utility.trace('-pass 10');

/* For Bug 1994421 - Zero Work Days Build :
 To process the non active assignments the new procedure Create_sline_term_employee is called
 A assignment is non active if the g_non_active_flag or g_hire_zero_work_days are 'Y'
 -lveerubh
*/
	IF g_non_active_flag <> 'E' then	-- introduced for 2426343
	IF	g_non_active_flag = 'Y' OR	g_hire_zero_work_days = 'Y'	OR g_all_holiday_zero_work_days = 'Y'	THEN

 --Insert a single line into psp_payroll_lines

 	hr_utility.trace('-pass 20');

	PSP_PAYROLL_LINES_PKG.INSERT_ROW (
			X_ROWID			=> x_rowid,
			X_PAYROLL_LINE_ID		=> l_line_id ,
			X_PAYROLL_CONTROL_ID		=> l_export_id ,
			X_SET_OF_BOOKS_ID		=> l_resp_set_of_books_id ,
			X_ASSIGNMENT_ID		=> l_assignment_id ,
			X_PERSON_ID			=> l_person_id ,
			X_COST_ID			=> g_pay_costs_rec.cost_id,
			X_ELEMENT_TYPE_ID		=> g_pay_costs_rec.element_type_id,
			X_PAY_AMOUNT			=> g_pay_costs_rec.costed_value ,
			X_STATUS_CODE			=> l_status_code ,
			X_EFFECTIVE_DATE		=> g_payroll_asg_rec.accounting_date,
			X_ACCOUNTING_DATE		=> g_payroll_asg_rec.accounting_date, --added for
			X_EXCHANGE_RATE_TYPE		=> l_exchange_rate_type,		-- 3108109
			X_CHECK_DATE			=> g_payroll_asg_rec.pay_advice_date,
			X_EARNED_DATE			=> g_pay_costs_rec.date_earned,
			X_COST_ALLOCATION_KEYFLEX_ID	=> g_pay_costs_rec.cost_allocation_keyflex_id,
			X_GL_CODE_COMBINATION_ID	=> l_gl_ccid,
			X_BALANCE_AMOUNT		=> l_balance_amount,
			X_DR_CR_FLAG			=> g_pay_costs_rec.debit_or_credit,
			X_MODE			=> 'R',
			X_PAYROLL_ACTION_TYPE		=> g_pay_costs_rec.action_type,
			X_OR_GL_CODE_COMBINATION_ID	=> l_or_gl_ccid,
			X_OR_PROJECT_ID			=> l_or_project_id,
			X_OR_TASK_ID			=> l_or_task_id,
			X_OR_AWARD_ID			=> l_or_award_id,
			X_OR_EXPENDITURE_ORG_ID		=> l_or_expenditure_org_id,
			X_OR_EXPENDITURE_TYPE		=> l_or_expenditure_type);

-- The following code is required as psp_payroll_controls will be updated with the total debit and credit amount
	hr_utility.trace('-pass 30');

	IF g_pay_costs_rec.debit_or_credit = 'D' then
		r_payroll_control_array.r_tot_dr(l_cur_rec)
		:= r_payroll_control_array.r_tot_dr(l_cur_rec) +1;

		r_payroll_control_array.r_dr_amount(l_cur_rec) :=
			r_payroll_control_array.r_dr_amount(l_cur_rec) + g_pay_costs_rec.costed_value;

	ELSE
		r_payroll_control_array.r_tot_cr(l_cur_rec)
		:= r_payroll_control_array.r_tot_cr(l_cur_rec) +1;

		r_payroll_control_array.r_cr_amount(l_cur_rec) :=
		r_payroll_control_array.r_cr_amount(l_cur_rec) + g_pay_costs_rec.costed_value;

	END IF;

	hr_utility.trace('-pass 40');

-- write single sub-line in PSP_PAYROLL_SUB_LINES

	IF	g_non_active_flag	= 'Y' THEN
		l_reason := 'NON_ACTIVE_ASSIGNMENT';
	ELSIF g_hire_zero_work_days	= 'Y' THEN
		l_reason := 'ASG_START_LAST_NON_WORK_DAY';
	ELSIF g_all_holiday_zero_work_days = 'Y' THEN
		l_reason := 'ELEMENT_ENTRY_FOR_SAT_SUN_ONLY';
	END IF;

	CREATE_SLINE_TERM_EMP( X_PAYROLL_LINE_ID	=> l_line_id,
				X_REASON		=> l_reason,
				X_RETURN_STATUS	=> l_return_status);

	IF l_return_status	<> FND_API.G_RET_STS_SUCCESS then
				l_error_api_name	:= 'CREATE_SLINE_TERM_EMP'||' '||l_reason;
				Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

 ELSE
---End of changes made for Non active assignments: Done as part of Bug 1994421 -Zero Work Days Build -lveerubh

	hr_utility.trace('-pass 50');

		PSP_PAYROLL_LINES_PKG.INSERT_ROW (
			X_ROWID			=> x_rowid,
			X_PAYROLL_LINE_ID		=> l_line_id ,
			X_PAYROLL_CONTROL_ID		=> l_export_id ,
			X_SET_OF_BOOKS_ID		=> l_resp_set_of_books_id ,
			X_ASSIGNMENT_ID		=> l_assignment_id ,
			X_PERSON_ID			=> l_person_id ,
			X_COST_ID			=> g_pay_costs_rec.cost_id,
			X_ELEMENT_TYPE_ID		=> g_pay_costs_rec.element_type_id,
			X_PAY_AMOUNT			=> g_pay_costs_rec.costed_value ,
			X_STATUS_CODE		=> l_status_code ,
			X_EFFECTIVE_DATE		=> g_payroll_asg_rec.effective_date,
			X_ACCOUNTING_DATE		=> g_payroll_asg_rec.accounting_date, --added for
			X_EXCHANGE_RATE_TYPE		=> l_exchange_rate_type,		-- 3108109
			X_CHECK_DATE			=> g_payroll_asg_rec.pay_advice_date,
			X_EARNED_DATE		=> g_pay_costs_rec.date_earned,
			X_COST_ALLOCATION_KEYFLEX_ID	=> g_pay_costs_rec.cost_allocation_keyflex_id,
			X_GL_CODE_COMBINATION_ID	=> l_gl_ccid,
			X_BALANCE_AMOUNT		=> l_balance_amount,
			X_DR_CR_FLAG			=> g_pay_costs_rec.debit_or_credit,
			X_MODE			=> 'R',
			X_PAYROLL_ACTION_TYPE		=> g_pay_costs_rec.action_type,
			X_OR_GL_CODE_COMBINATION_ID	=> l_or_gl_ccid,
			X_OR_PROJECT_ID			=> l_or_project_id,
			X_OR_TASK_ID			=> l_or_task_id,
			X_OR_AWARD_ID			=> l_or_award_id,
			X_OR_EXPENDITURE_ORG_ID		=> l_or_expenditure_org_id,
			X_OR_EXPENDITURE_TYPE		=> l_or_expenditure_type);

--	IF (l_proration_option = 'PSP' or g_pay_costs_rec.start_date IS NULL) THEN	-- Introduced for bug fix 2916848

	---IF g_pay_costs_rec.start_date IS NULL THEN ... commented for 4897071

	hr_utility.trace('-pass 60');

		CREATE_DAILY_RATE_CALENDAR(
				X_ASSIGNMENT_ID		=> l_assignment_id,
				X_time_period_id		=> p_time_period_id,
				X_ELEMENT_TYPE_ID	=> g_pay_costs_rec.element_type_id,
				X_RETURN_STATUS		=> l_return_status);
		IF l_return_status	<> FND_API.G_RET_STS_SUCCESS then
		l_error_api_name	:= 'CREATE_DAILY_RATE_CALENDAR : ';
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;


-- Sum up the salary from daily calendar array
-- compare the salary amount we got from pay costs table
-- if it is different, calculate the difference amount

		CALCULATE_BALANCE_AMOUNT(X_PAY_AMOUNT		=> g_pay_costs_rec.costed_value,
					X_BALANCE_AMOUNT	=> l_balance_amount,
					X_RETURN_STATUS	=> l_return_status);
		if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
		l_error_api_name	:= 'CREATE_BALANCE_AMOUNT : ';
		--dbms_output.PUT_LINE('...CREATE_BALANCE_AMOUNT :');
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;

/* commented for 4897071
--	Introduced the following for bug fix 2916848
	ELSE
		create_prorate_calendar
			(p_start_date		=>	g_pay_costs_rec.start_date,
			p_end_date		=>	g_pay_costs_rec.end_date,
			p_pay_amount		=>	g_pay_costs_rec.costed_value,
			p_payroll_line_id	=>	l_line_id,
			p_balance_amount	=>	l_balance_amount,
			p_return_status		=>	l_return_status);
		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			l_error_api_name	:= 'CREATE_PRORATE_CALENDAR : ';
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;


	END IF;
*/

	UPDATE PSP_PAYROLL_LINES set balance_amount=l_balance_amount where payroll_line_id=l_line_id;

--	End of bug fix 2916848

		IF g_pay_costs_rec.debit_or_credit = 'D' then

				r_payroll_control_array.r_tot_dr(l_cur_rec):=
			r_payroll_control_array.r_tot_dr(l_cur_rec) +1;
			r_payroll_control_array.r_dr_amount(l_cur_rec) :=
			r_payroll_control_array.r_dr_amount(l_cur_rec) +
			g_pay_costs_rec.costed_value;

		ELSE

			r_payroll_control_array.r_tot_cr(l_cur_rec):=
			r_payroll_control_array.r_tot_cr(l_cur_rec) +1;

			r_payroll_control_array.r_cr_amount(l_cur_rec) :=
			r_payroll_control_array.r_cr_amount(l_cur_rec) +
			g_pay_costs_rec.costed_value;

		END IF;

-- If salary change happens during the payroll period
--	write two sub-lines in PSP_PAYROLL_SUB_LINES
--	table
-- else
--	write single sub-line in PSP_PAYROLL_SUB_LINES
--	table
-- end if;

---	IF (l_proration_option = 'PSP' or g_pay_costs_rec.start_date is null ) THEN	-- Introduced for bug fix 2916848

--- IF g_pay_costs_rec.start_date IS NULL then .. commented for 4897071
		/*Bug 5642002: Added parameters x_start_date and x_end_date */
			CREATE_SLINE_SALARY_CHANGE (X_PAYROLL_LINE_ID	=> l_line_id,
						x_start_date		=> TRUNC(g_start_date), -- Bug 6046087
						x_end_date		=> TRUNC(g_end_date),   -- Bug 6046087
						X_RETURN_STATUS		=> l_return_status);


			IF l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_SALARY_CHANGE : ';
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

 ----END IF;	-- Introduced for bug fix 2916848

-- if assignment starts during pay period then
--	update sub-line start date with assignment start
--	date.
-- If assignment ends during pay period then
--	update sub-line end date with assignment end
--	date.

			CREATE_SLINE_ASG_CHANGE (X_PAYROLL_LINE_ID		=> l_line_id,
						X_ASSIGNMENT_ID		=> l_assignment_id,
						X_RETURN_STATUS		=> l_return_status);
			if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_ASG_CHANGE : ';
				----dbms_output.PUT_LINE('...CREATE_SLINE_ASG_CHANGE :');
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;


-- Looks in to per_assignments_f for assignment statuses either
-- 'Suspend' or 'Terminate' during the pay period.
-- If found then split the sub-line in to two sub-lines and
-- delete the existing sub-line.

			CREATE_SLINE_ASG_STATUS_CHANGE (X_PAYROLL_LINE_ID		=> l_line_id,
								X_ASSIGNMENT_ID		=> l_assignment_id,
							X_BALANCE_AMOUNT		=> l_balance_amount,
							X_RETURN_STATUS		=> l_return_status);
			if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_ASG_STATUS_CHANGE : ';
				----dbms_output.PUT_LINE('...CREATE_SLINE_ASG_STATUS_CHANGE :');
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;


-- Looks into per_periods_of_service for ending employment.
-- If found then split the sub-line in to two sub-lines and
-- delete the existing sub-line.

			CREATE_SLINE_EMP_END_DATE(X_PAYROLL_LINE_ID		=> l_line_id,
						X_PERSON_ID		=> l_person_id,
						X_RETURN_STATUS		=> l_return_status);
			if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_EMP_END_DATE : ';
				----dbms_output.PUT_LINE('...CREATE_SLINE_EMP_END_DATE :');
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;

-- Looks into per_assignments_f for Organization change during the pay period.
-- If found split the sub-line into two sub-lines and delete the existing sub-line.

			CREATE_SLINE_ORG_CHANGE(X_PAYROLL_LINE_ID		=> l_line_id,
						X_ASSIGNMENT_ID		=> l_assignment_id,
						X_BALANCE_AMOUNT		=> l_balance_amount,
						X_RETURN_STATUS		=> l_return_status);
			if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_ORG_CHANGE : ';
				----dbms_output.PUT_LINE('...CREATE_SLINE_ORG_CHANGE :');
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;


-- Looks into per_assignments_f for Job change during the pay period.
-- If found split the sub-line into two sub-lines and delete the existing sub-line.


			CREATE_SLINE_JOB_CHANGE(X_PAYROLL_LINE_ID		=> l_line_id,
						X_ASSIGNMENT_ID		=> l_assignment_id,
						X_BALANCE_AMOUNT		=> l_balance_amount,
						X_RETURN_STATUS		=> l_return_status);

			if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_JOB_CHANGE : ';
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;


-- Looks into per_assignments_f for Position change during the pay period.
-- If found split the sub-line into two sub-lines and delete the existing sub-line.

			CREATE_SLINE_POSITION_CHANGE(X_PAYROLL_LINE_ID		=> l_line_id,
						X_ASSIGNMENT_ID		=> l_assignment_id,
						X_BALANCE_AMOUNT		=> l_balance_amount,
						X_RETURN_STATUS		=> l_return_status);

			if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_POSITION_CHANGE : ';
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;

/* New Procedures added for splitting sublines by garde and people group */


			CREATE_SLINE_GRADE_CHANGE(X_PAYROLL_LINE_ID		=> l_line_id,
						X_ASSIGNMENT_ID		=> l_assignment_id,
						X_BALANCE_AMOUNT		=> l_balance_amount,
						X_RETURN_STATUS		=> l_return_status);

			if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_GRADE_CHANGE : ';
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;




			CREATE_SLINE_PPGROUP_CHANGE(X_PAYROLL_LINE_ID		=> l_line_id,
						X_ASSIGNMENT_ID		=> l_assignment_id,
						X_BALANCE_AMOUNT		=> l_balance_amount,
						X_RETURN_STATUS		=> l_return_status);

			if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_PPGROUP_CHANGE : ';
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;



-- Get profile value of profile 'PSP_FTE_OPTIONS'
-- If the value is 'Budget_Values' don't do anything
-- else look for the fte change in per_assignments_f.
-- If found split the sub-line into two sub-lines and delete the existing sub-line.
		/* Commented for Bug 4055483

			CREATE_SLINE_FTE_CHANGE(X_PAYROLL_LINE_ID		=> l_line_id,
						X_ASSIGNMENT_ID		=> l_assignment_id,
						X_BALANCE_AMOUNT		=> l_balance_amount,
						X_RETURN_STATUS		=> l_return_status);

			if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_FTE_CHANGE : ';
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;
		End of code changes for bug 4055483 */

			CREATE_SLINE_BUDGET_CHANGE(X_PAYROLL_LINE_ID		=> l_line_id,
						X_ASSIGNMENT_ID		=> l_assignment_id,
						X_BALANCE_AMOUNT		=> l_balance_amount,
						X_RETURN_STATUS		=> l_return_status);

			if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
			l_error_api_name	:= 'CREATE_SLINE_BUDGET_CHANGE : ';
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;

		hr_utility.trace('	Opening get_difference_csr cursor');

--		Insert rounding routine here
		open get_difference_csr;
		fetch get_difference_csr into l_subline_sum;
		if get_difference_csr%NOTFOUND then
		l_error_api_name	:= 'PSP_PAYTRN : error at GET_DIFFERECE_CSR';
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;
		close get_difference_csr;
-- Added daily rate not equal to 0 to where clause to fix bug no 89157
		if (NVL(to_number(g_pay_costs_rec.costed_value),0) - NVL(l_subline_sum,0)) <> 0 then
		update psp_payroll_sub_lines
			set pay_amount = pay_amount + (NVL(to_number(g_pay_costs_rec.costed_value),0) - NVL(l_subline_sum,0))
		where payroll_line_id = l_line_id and
			NVL(daily_rate,0) <> 0 and
			pay_amount <> 0 and	--- rounding difference to nonzero amount .. 4670588
			rownum = 1;
		if SQL%NOTFOUND then
			l_error_api_name	:= 'PSP_PAYTRN : error while updating subline for rounding';
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;
		end if;

		end if;
		end if; -- for g_non_active_flag <> E for 2426343

-- Bug 1994421 : Zero Work Days Build - Closing the Non active assignment IF ENDIF :lveerubh
	END IF;
		close check_payroll_lines_csr;

/* Added to let the program continue with next record if zero work days is encountered for any assignment	*/
		EXCEPTION
			WHEN ZERO_WORK_DAYS then

			retcode:= FND_API.G_RET_STS_SUCCESS;

		END;
		END LOOP; -- LOOP1 end
		close get_pay_costs_csr;

		EXCEPTION

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
			rollback;
			retcode := 2;


			psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_TRUE
					);

			return;
		WHEN NO_COST_DATA_FOUND then
			close get_pay_costs_csr;
				hr_utility.trace('-exception 10- sqlerrm = '||sqlerrm);

			IF check_payroll_lines_csr%ISOPEN THEN
			  hr_utility.trace('-exception 10-  close check_payroll_lines_csr');
			  close check_payroll_lines_csr;
			END IF;

		select distinct substr(full_name,1,50) into l_employee_name from per_people_f
		--where person_id = l_person_id; /* Tar#12269298 WVU */
		where person_id = l_person_id and
		effective_start_date = (select max(effective_start_date ) from per_people_f where
		person_id=l_person_id);
/* Changed in lieu of caltech's reporting, that an employee terminated on the last day was not getting paid


			sysdate between effective_start_date and effective_end_date;
*/

			hr_utility.trace('-inside exception 10-');

			FND_MESSAGE.Set_Name('PSP', 'PSP_PI_NO_COSTING_EMP');
			FND_MESSAGE.set_token('Employee',l_employee_name);
			FND_MSG_PUB.ADD;

			retcode:= FND_API.G_RET_STS_SUCCESS;

			WHEN OTHERS then
			retcode := 2;

			rollback;

			hr_utility.trace('	Process failed here');
			hr_utility.trace('-exception 20- sqlerrm = '||sqlerrm);

			psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_TRUE
					);


			return;
		END;
		END LOOP;
		close get_payroll_assig_actions_csr;

/* The follwing code commented out NOCOPY in lieu of bug fix 1004191 Subha
*/
payroll_control_id_a.delete;
time_period_id_a.delete;
currency_code_a.delete; -- Bug 6468271

	hr_utility.trace('	Finally Updating psp_payroll_controls');

	FORALL k in 1 .. l_total_num_rec
	UPDATE	psp_payroll_controls
		set number_of_cr = r_payroll_Control_array.r_tot_cr(k),
		number_of_dr = r_payroll_Control_array.r_tot_dr(k),
		total_dr_amount = r_payroll_control_array.r_dr_amount(k),
		total_cr_amount	=r_payroll_control_array.r_cr_amount(k)
	WHERE	payroll_control_id = r_payroll_control_array.r_payroll_control_id(k);

--end if;


	FORALL k in 1 .. l_total_num_rec
	update psp_payroll_controls
		set sublines_dr_amount = ( select sum(pay_amount)
					from	psp_payroll_sub_lines
						where payroll_line_id in (
						select payroll_line_id
						from	psp_payroll_lines
							where payroll_control_id =
							r_payroll_control_array.r_payroll_control_id(k)
								and dr_cr_flag = 'D')),
		sublines_cr_amount = ( select sum(pay_amount)
					from	psp_payroll_sub_lines
						where payroll_line_id in (
						select payroll_line_id
						from	psp_payroll_lines
							where payroll_control_id = r_payroll_control_array.r_payroll_control_id(k) and
							dr_cr_flag = 'C'))
		where payroll_control_id	= r_payroll_control_array.r_payroll_control_id(K);

	IF sql%NOTFOUND then
		fnd_msg_pub.add_exc_msg('PSP_PAYTRN','Error while Updating Sublines Total in Payroll Controls ');
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF l_total_num_rec=0 then
		fnd_message.set_name('PSP','PSP_PI_NO_PAYROLL_TRXN');
		fnd_msg_pub.add;

	ELSE

 --- Delete the record of arrays

	r_payroll_control_array.r_payroll_control_id.DELETE;
	r_payroll_control_array.r_currency_code.DELETE;
	r_payroll_control_array.r_tot_dr.DELETE;
	r_payroll_control_array.r_tot_cr.DELETE;
	r_payroll_control_array.r_dr_amount.DELETE;
	r_payroll_control_array.r_cr_amount.DELETE;
	r_payroll_control_array.r_precision.DELETE;
	r_payroll_control_array.r_ext_precision.DELETE;


	END IF;

	/* added by subha to always print the success message when the program terminates successfully */

	fnd_file.put_line(fnd_file.log,'********************************************************');

	fnd_message.set_name('PSP','PSP_PROGRAM_SUCCESS') ;
	fnd_msg_pub.add;
	retcode:= FND_API.G_RET_STS_SUCCESS;

	COMMIT;

		psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_FALSE);

	fnd_file.put_line(fnd_file.log,'********************************************************');
	fnd_file.put_line(fnd_file.log, '');

	l_count := 0;
	l_heading := null;
	hr_utility.trace('	before get_import_summary_heading');
	fnd_file.put_line(fnd_file.log, ' ');
	fnd_file.put_line(fnd_file.log, ' ');
	fnd_file.put_line(fnd_file.log, ' ');
	open get_import_summary_heading;
	loop
	fetch get_import_summary_heading into l_temp_heading;
	if get_import_summary_heading%notfound then
		close get_import_summary_heading;
		exit;
	end if;
	if l_count = 0 then
		fnd_file.put_line(fnd_file.log, l_temp_heading||':');
		fnd_file.put_line(fnd_file.log, ' ');
		l_count := l_count + 1;
	else
		if l_count = 1 then
		l_heading := l_heading || rpad(l_temp_heading,38)||' ';
		elsif l_count = 2 then
		l_heading := l_heading || rpad(l_temp_heading,20)||' ';
		elsif l_count = 3 then
		l_heading := l_heading || l_temp_heading;
		end if;
		l_count := l_count + 1;
	end if;
	end loop;
	open get_master_rec_mesg;
	fetch get_master_rec_mesg into l_master_period_message;
	close get_master_rec_mesg;
	fnd_file.put_line(fnd_file.log, l_master_period_message);
	fnd_file.put_line(fnd_file.log, l_heading);
	fnd_file.put_line(fnd_file.log, '------------------------------------------------------------------------------');

	open get_import_summary;
	loop
	fetch get_import_summary into l_asg_count, l_action_type, l_period_name, l_parent_control_id;
	if get_import_summary%notfound then
		close get_import_summary;
		exit;
	end if;
	if l_parent_control_id is null then
		fnd_file.put_line(fnd_file.log, rpad(l_period_name,38) ||' '|| rpad(l_action_type,22)||' '|| lpad(l_asg_count, 10));
	else
		fnd_file.put_line(fnd_file.log,'	'|| rpad(l_period_name,34) ||' '|| rpad(l_action_type,22)||' '|| lpad(l_asg_count, 10));
	end if;
	end loop;


	fnd_file.put_line(fnd_file.log, '------------------------------------------------------------------------------');
	fnd_file.put_line(fnd_file.log, '');
	fnd_file.put_line(fnd_file.log, '');
	fnd_file.put_line(fnd_file.log, '');
        hr_utility.trace('	Leaving IMPORT_PAYTRANS');

	EXCEPTION
	WHEN NO_DATA_FOUND then
		close get_payroll_assig_actions_csr;
		fnd_message.set_name('PSP','PSP_PI_NO_PAYROLL_TRXN');
		fnd_msg_pub.add;
		fnd_message.set_name('PSP','PSP_PROGRAM_SUCCESS') ;
		fnd_msg_pub.add;
		retcode:= FND_API.G_RET_STS_SUCCESS;


		psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_FALSE);
		return;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
		retcode := 2;
		rollback;


		psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_TRUE
					);

		return;
	/* Added Exceptions for bug 2056877 */
		WHEN NO_PROFILE_EXISTS THEN
		fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
		fnd_msg_pub.add;
		psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_TRUE);
		retcode := 2;


	WHEN NO_VAL_DATE_MATCHES THEN
	fnd_message.set_name('PSP','PSP_IMP_NO_VAL_DATE_MATCHES');
	fnd_message.set_token('PAYROLL_DATE',l_end_date);
	fnd_msg_pub.add;
	psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_TRUE);
	retcode := 2;

	WHEN NO_GLOBAL_ACCT_EXISTS THEN
	-- commented the below line and replaced it with the next line, fix done is fixing the gscc warning on not to use chr(x)
	-- instead use fnd_global.local_chr(x)
	--errbuf	:= l_error_api_name || chr(10) || l_msg_data || chr(10);
	errbuf	:= l_error_api_name || fnd_global.local_chr(10) || l_msg_data || fnd_global.local_chr(10);
	fnd_message.set_name('PSP','PSP_IMP_NO_GLOBAL_ACCT_EXISTS');
	fnd_message.set_token('PAYROLL_DATE',l_end_date);
	fnd_msg_pub.add;
	psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_TRUE);
	retcode := 2; --End of Modification for Bug 2056877.

	WHEN OTHERS then
		retcode := 2;
		rollback;
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','IMPORT_PAY_TRNS');


		psp_message_s.print_error(p_mode=>FND_FILE.log,
					p_print_header=>FND_API.G_TRUE
					);

		return;
	END;


/*****	Commented for Work Schedules enh.
-------------------------------CREATE_WORKING_CALENDAR---------------------------------------
PROCEDURE create_working_calendar IS

i		number(9)	:= 0;
l_low_date	date	:= trunc(g_start_date);
l_high_date	date	:= trunc(g_end_date);

begin
 g_no_of_days		:= 0;
 g_no_of_work_days	:= 0;

 ----dbms_output.put_line('Entered Proceduer create_working_calendar..');
 while l_low_date <= l_high_date loop
	g_no_of_days := g_no_of_days + 1;
	/ *Bug 5557724: to_char(some_date,'D') returns a number indicating the weekday. However, for a given date, this number
	returned varies with NLS_TERRITORY. So replaced it with to_char(some_date,'DY') that gives the abbreviated day. * /
	if to_char(l_low_date, 'DY', 'nls_date_language=english') NOT IN ('SUN', 'SAT') then
		work_calendar(g_no_of_days)	:= 'Y';
		g_no_of_work_days		:= g_no_of_work_days + 1;
	else
		work_calendar(g_no_of_days)	:= 'N';
	end if;
	-- ----dbms_output.PUT_LINE('Day ...Value ... ' || to_char(g_no_of_days) || ' ' || work_calendar(g_no_of_days));
	l_low_date := l_low_date + 1;
 end loop;

end;
	End of comment for work schedules enh.	*****/

PROCEDURE create_working_calendar (p_assignment_id	IN	NUMBER) IS
CURSOR	business_days_cur IS
SELECT	DECODE(psp_general.business_days(g_start_date + (ROWNUM-1), g_start_date + (ROWNUM-1), p_assignment_id), 1, 'Y', 'N')
FROM	DUAL
CONNECT BY 1=1
AND	ROWNUM <= (g_end_date + 1) - g_start_date;
BEGIN
	OPEN business_days_cur;
	FETCH business_days_cur BULK COLLECT INTO work_calendar;
	CLOSE business_days_cur;

	g_no_of_work_days := psp_general.business_days(g_start_date, g_end_date, p_assignment_id);
	g_no_of_days := work_calendar.COUNT;

	IF ((g_start_date = g_end_date) AND (NVL(g_entry_date_earned,g_start_date) = g_start_date)) THEN
		g_no_of_work_days := 1;
		work_calendar(1) := 'Y';
	END IF;
END create_working_calendar;

--------------------------UPDATE_WCAL_ASG_END_DATE------------------------------
--
PROCEDURE update_wcal_asg_end_date(x_assignment_id IN NUMBER,
					x_return_status OUT NOCOPY VARCHAR2) IS

/* CURSOR get_asg_end_date_csr IS
SELECT effective_end_date
FROM	per_assignments_f
WHERE assignment_id	= x_assignment_id and
	effective_end_date = (select max(effective_end_date) from per_assignments_f
				where effective_end_date between g_start_date and
					g_end_date);
*/
CURSOR get_asg_end_date_csr IS
SELECT max(effective_end_date)
FROM	per_assignments_f
WHERE assignment_id	= x_assignment_id
--	Introduced the following condition for bug fix 2439207
AND	assignment_type = 'E';

l_end_date	date;
i		number(9)	:= 0;
begin
 ----dbms_output.put_line('Entered Proceduer update_wcal_asg_end_date..');
 open get_asg_end_date_csr;
 fetch get_asg_end_date_csr into l_end_date;
 if get_asg_end_date_csr%FOUND then
	if trunc(l_end_date) >= trunc(g_start_date) and
	trunc(l_end_date) <= trunc(g_end_date) then
	------dbms_output.put_line('Entered IF..');
-- In order to take of terminated date .... plus one has been changed to plus two
	i	:= (trunc(l_end_date) - trunc(g_start_date)) + 2;
	while i <= g_no_of_days loop
		if work_calendar(i) = 'Y' then
		g_no_of_person_work_days	:= g_no_of_person_work_days - 1;
		work_calendar(i) := 'N';
		------dbms_output.put_line('Work Calendar ' || to_char(i) || '	N ');
		end if;
		i	:= i + 1;
	end loop;
	end if;
 end if;
 close get_asg_end_date_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 return;
EXCEPTION
 WHEN OTHERS then
	------dbms_output.put_line('When others Error...........');
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','UPDATE_WCAL_ASG_END_DATE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;

end;

--------------------------UPDATE_WCAL_ASG_BEGIN_DATE------------------------------
--
PROCEDURE update_wcal_asg_begin_date(x_assignment_id IN NUMBER,
					x_return_status OUT NOCOPY VARCHAR2) IS

/* CURSOR get_asg_end_date_csr IS
SELECT effective_end_date
FROM	per_assignments_f
WHERE assignment_id	= x_assignment_id and
	effective_end_date = (select max(effective_end_date) from per_assignments_f
				where effective_end_date between g_start_date and
					g_end_date);


CURSOR get_asg_begin_date_csr IS
SELECT min(date_start)
FROM	per_periods_of_service
WHERE	person_id = x_person_id and
	(date_start between g_start_date and g_end_date) ;
*/

---- removed cursor begin_date_mid_payroll_csr for 4670588
-- that cusor had a check effective_start_date between g_Start_date and
 ----- g_end_date, that was causing the problem
CURSOR get_asg_begin_date_csr IS
SELECT min(effective_start_date)
FROM	per_assignments_f
WHERE	assignment_id = x_assignment_id
AND	payroll_id = l_payroll_id	-- 3922347
--	Introduced the following condition for bug fix 2439207
AND	assignment_type = 'E';

l_begin_date	date;
i		number(9)	:= 1;
n		number(9)	:= 0;

/*
l_begin_date	date		:= g_start_date;
i		number(9)	:= 0;
n		number(9)	:= 0;
*/

begin
 hr_utility.trace('	assignment_id = '||x_assignment_id);
	l_begin_date := null;

 ----dbms_output.put_line('Entered Proceduer update_wcal_asg_begin_date..');
 open get_asg_begin_date_csr;
 fetch get_asg_begin_date_csr into l_begin_date;
 close get_asg_begin_date_csr;
 ---hr_utility.trace('	asg begin date = '||l_begin_date);
 ---hr_utility.trace('	g date = '||g_start_date||','||g_end_date);
	/*
	if trunc(l_begin_date) != trunc(g_start_date) then
	----dbms_output.put_line('Entered IF..');
	n	:= (trunc(l_begin_date) - trunc(g_start_date)) ;
	FOR i in 1..n	loop
		if work_calendar(i) = 'Y' then
		g_no_of_person_work_days	:= g_no_of_person_work_days - 1;
		work_calendar(i) := 'N';
		----dbms_output.put_line('Work Calendar ' || to_char(i) || '	N ');
		end if; -- Work_calendar(i)
	end loop;
	end if;
*/


--Changed by Subha to fix Caltech's problem of incorrect daily rate calculation

if l_begin_date is not null then
	-- ------dbms_output.put_line('after open cursor');
	if trunc(l_begin_date) >= trunc(g_start_date) and
	trunc(l_begin_date) <= trunc(g_end_date) then
	n:= (trunc(l_begin_date)-trunc(g_start_date)) + 1;

	while i < n loop
		if work_calendar(i)='Y' then
		g_no_of_person_work_days:= g_no_of_person_work_days - 1;
		work_calendar(i):= 'N';
		hr_utility.trace('	i = N, i = '||i);
		-- ------dbms_output.put_line('Work Calendar' ||to_char(i)||' N');
		end if;
		i:= i+1;
	end loop;
	end if;
end if;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 return;
EXCEPTION
 WHEN OTHERS then
	-- ------dbms_output.put_line('When others Error...........'||SUBSTR(SQLERRM,1,200));
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','UPDATE_WCAL_ASG_BEGIN_DATE',SUBSTR(SQLERRM,1,100));
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;

end;

/*
--------------------------UPDATE_WCAL_ASG_BEGIN_DATE------------------------------
--
PROCEDURE update_wcal_asg_begin_date(x_person_id IN NUMBER,
					x_return_status OUT NOCOPY VARCHAR2) IS

 CURSOR get_asg_end_date_csr IS
SELECT effective_end_date
FROM	per_assignments_f
WHERE assignment_id	= x_assignment_id and
	effective_end_date = (select max(effective_end_date) from per_assignments_f
				where effective_end_date between g_start_date and
					g_end_date);


CURSOR get_asg_begin_date_csr IS
SELECT min(date_start)
FROM	per_periods_of_service
WHERE	person_id = x_person_id and
		(date_start between g_start_date and g_end_date) ;

l_begin_date	date;
i		number(9)	:= 0;
n		number(9)	:= 0;
begin
 ----dbms_output.put_line('Entered Proceduer update_wcal_asg_begin_date..');
 open get_asg_begin_date_csr;
 fetch get_asg_begin_date_csr into l_begin_date;
 if get_asg_begin_date_csr%FOUND then
	if trunc(l_begin_date) >= trunc(g_start_date) and
	trunc(l_begin_date) <= trunc(g_end_date) then
	----dbms_output.put_line('Entered IF..');
-- In order to take of terminated date .... plus one has been changed to plus two
	n	:= (trunc(l_begin_date) - trunc(g_start_date)) ;
	FOR i in 1..n	loop
		if work_calendar(i) = 'Y' then
		g_no_of_person_work_days	:= g_no_of_person_work_days - 1;
		work_calendar(i) := 'N';
		----dbms_output.put_line('Work Calendar ' || to_char(i) || '	N ');
		end if;
--		i	:= i + 1;
	end loop;
	end if;
 end if;
 close get_asg_begin_date_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 return;
EXCEPTION
 WHEN OTHERS then
	----dbms_output.put_line('When others Error...........');
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','UPDATE_WCAL_ASG_BEGIN_DATE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;

end;
*/
---------------------------UPDATE_WCAL_ASG_STATUS-----------------------------------
--
PROCEDURE	UPDATE_WCAL_ASG_STATUS(x_assignment_id IN NUMBER,
					x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR get_asg_status_csr IS
SELECT	effective_start_date,	effective_end_date
FROM	per_assignments_f
WHERE	assignment_id = x_assignment_id and
	(g_start_date between effective_start_date and effective_end_date or
	g_end_date	between effective_start_date and effective_end_date or
	(g_start_date <= effective_start_date and	g_end_date >= effective_end_date )) and
	assignment_status_type_id in (select assignment_status_type_id
					from per_assignment_status_types
					where per_system_status in ('SUSP_ASSIGN','TERM_ASSIGN') );

l_start_date	date;
l_end_date	date;
i		number(9)	:= 0;
i2		number(9)	:= 0;

begin
 ----dbms_output.put_line('Entered Proceduer update_wcal_asg_status..');
 open get_asg_status_csr;
 LOOP
	fetch get_asg_status_csr into l_start_date,l_end_date;
	EXIT WHEN get_asg_status_csr%NOTFOUND;
	if trunc(l_start_date) <= trunc(g_start_date) then
	l_start_date := trunc(g_start_date);
	else
	l_start_date := trunc(l_start_date);
	end if;

	if trunc(l_end_date) >= trunc(g_end_date) then
	l_end_date	:= trunc(g_end_date);
	else
	l_end_date	:= trunc(l_end_date);
	end if;
	i	:= (l_start_date - g_start_date) + 1;
	i2	:= (l_end_date	- g_start_date) + 1;
	while i <= i2 loop
	if work_calendar(i) = 'Y' then
	g_no_of_person_work_days	:= g_no_of_person_work_days - 1;
	work_calendar(i) := 'N';
	--	----dbms_output.put_line('Work Calendar ' || to_char(i) || '	N ');
	end if;
	i	:= i + 1;
	end loop;
 END LOOP;
 close get_asg_status_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 return;
 EXCEPTION
	WHEN OTHERS then
	close get_asg_status_csr;
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','UPDATE_WCAL_ASG_STATUS');
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	return;
end UPDATE_WCAL_ASG_STATUS;
--
----------------------CREATE_DAILY_RATE_CALENDAR---------------------------
PROCEDURE	CREATE_DAILY_RATE_CALENDAR(x_assignment_id	IN NUMBER,
					x_time_period_id	IN NUMBER,
					x_element_type_id	IN NUMBER,
					x_return_status		OUT NOCOPY VARCHAR2) IS

-- Get salary details from per_pay_proposals
/*
CURSOR get_proposal_csr is
SELECT distinct proposed_salary, previous_salary,
	change_date,last_change_date,pay_basis
FROM	per_pay_proposals_v
WHERE assignment_id	= x_assignment_id and
	element_type_id = x_element_type_id and
	approved='Y' and
	change_date between (trunc(g_start_date)+1) and g_end_date
ORDER BY change_date;


get_proposal_rec get_proposal_csr%ROWTYPE;

*/

CURSOR get_proposal_csr is
select ppp.proposed_salary_n proposed_salary, ppp.change_date, ppb.pay_basis
 from per_pay_proposals ppp,
	pay_input_values_f piv,
	per_pay_bases ppb,
	per_all_assignments_f paf
 where paf.assignment_id = x_assignment_id
 and ppp.change_date between paf.effective_start_date and
paf.effective_end_date
 and paf.pay_basis_id = ppb.pay_basis_id
 and ppp.assignment_id = x_assignment_id
 and piv.element_type_id = x_element_type_id
 and ppp.approved = 'Y'
 --and ppp.change_date <= :g_start_date
 and ppp.change_date between (trunc(g_Start_date)+1) and g_end_date
 --and ppb.pay_basis_id = :p_pay_basis_id
 and ppb.input_value_id = piv.input_value_id
 and ppp.change_date
	between piv.effective_start_date and piv.effective_end_date
 order by ppp.change_date ;

get_proposal_rec get_proposal_csr%ROWTYPE;



CURSOR get_proposal_prevsal_csr(p_change_date in date ) is
select ppp.proposed_salary_n previous_salary, ppp.change_date last_change_date
 from per_pay_proposals ppp,
	pay_input_values_f piv,
	per_pay_bases ppb,
	per_all_assignments_f paf
 where paf.assignment_id = x_assignment_id
 and ppp.change_date between paf.effective_start_date and
paf.effective_end_date
 and paf.pay_basis_id = ppb.pay_basis_id
 and ppp.assignment_id = x_assignment_id
 and piv.element_type_id = x_element_type_id
and ppp.approved = 'Y'
--and ppp.change_date between (trunc(g_Start_date)+1) and g_end_date
 and ppp.change_date < p_change_date
 --and ppb.pay_basis_id = :p_pay_basis_id
 and ppb.input_value_id = piv.input_value_id
 and ppp.change_date
	between piv.effective_start_date and piv.effective_end_date
 order by ppp.change_date desc;

get_proposal_prevsal_rec get_proposal_prevsal_csr%ROWTYPE;

/*
CURSOR get_previous_proposal_csr is
SELECT distinct proposed_salary, change_date, pay_basis
FROM	per_pay_proposals_v
WHERE assignment_id	= x_assignment_id and
	element_type_id = x_element_type_id and
	change_date <= g_start_date and
	approved = 'Y' order by change_date desc ;
-- and
--	change_date = (select max(change_date)
--			from per_pay_proposals_v
--			where assignment_id = x_assignment_id and
--				change_date <= g_start_date and approved = 'Y');
*/

CURSOR get_previous_proposal_csr is
select ppp.proposed_salary_n proposed_salary, ppp.change_date, ppb.pay_basis
 from per_pay_proposals ppp,
	pay_input_values_f piv,
	per_pay_bases ppb,
	per_all_assignments_f paf
 where paf.assignment_id =x_assignment_id
 and ppp.change_date between paf.effective_start_date and
paf.effective_end_date
 and paf.pay_basis_id = ppb.pay_basis_id
 and ppp.assignment_id = x_assignment_id
 and piv.element_type_id = x_element_type_id
 and ppp.approved = 'Y'
 --and ppp.change_date <= :g_start_date
 and ppp.change_date =
		(select max(change_date)
		from per_pay_proposals ppp1
		where ppp1.assignment_id = x_assignment_id
		and ppp1.approved = 'Y'
		and ppp1.change_date <= g_start_date)
 --and ppb.pay_basis_id = :p_pay_basis_id
 and ppb.input_value_id = piv.input_value_id
 and ppp.change_date
	between piv.effective_start_date and piv.effective_end_date
 order by ppp.change_date desc;
get_previous_proposal_rec get_previous_proposal_csr%ROWTYPE;



CURSOR	get_no_per_fiscal_year_csr is
SELECT number_per_fiscal_year
FROM	per_time_period_types
WHERE	period_type = (select period_type from per_time_periods
			where time_period_id = x_time_period_id);

--
l_no_fiscal_year	number		:= 0;
l_daily_rate		NUMBER	:= 0;	-- Corrected datatype to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_change_start_date	date		:= NULL;
l_previous_salary	NUMBER	:= 0;	-- Corrected datatype to NUMBER from NUMBER(22, 2) for bug fix 2916848
i			number(3)	:= 0;
j number(3)				:=0 ;	-- new variable for bug fix 2426329
-- Added the following variable to fix assignment start date is in between
-- payroll period
l_non_working_day_flag	number := 0;
--

Begin
 --dbms_output.put_line('Entered Proceduer create_daily_rate_calendar..');
 --dbms_output.PUT_LINE(' Just entered... ' );
-- --dbms_output.PUT_LINE(' time period id ' || to_char(x_time_period_id));
----dbms_output.put_line('assignment_id '||to_char(x_assignment_id));
----dbms_output.put_line('element type id '||to_char(x_element_type_id));
----dbms_output.put_line('g_start_date '||to_char(g_start_date,'YYYY/MM/DD HH24:MI:SS'));
----dbms_output.put_line('g_end_date '||to_char(g_end_date,'YYYY/MM/DD HH24:MI:SS'));


 open get_no_per_fiscal_year_csr;
 --dbms_output.PUT_LINE(' open get_proposal_csr; ' );
 fetch get_no_per_fiscal_year_csr into l_no_fiscal_year;
 --dbms_output.PUT_LINE(' Just entered... ' );
 if get_no_per_fiscal_year_csr%NOTFOUND then
	FND_MESSAGE.Set_Name('PSP', 'PSP_PI_NO_PERIOD_TYPES');
	FND_MESSAGE.Set_Token('TIME_PERIOD_ID',x_time_period_id);
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 end if;
 close get_no_per_fiscal_year_csr;
 --dbms_output.PUT_LINE('No. of periods for fiscal year...	' || to_char(l_no_fiscal_year));
 l_change_start_date	:= trunc(g_start_date);
	--dbms_output.put_line('before get_proposal_Cusror');

 open get_proposal_csr;
 fetch get_proposal_csr into get_proposal_rec;
 if get_proposal_csr%NOTFOUND then
	--dbms_output.put_line('no data found');
	close get_proposal_csr;
	raise NO_DATA_FOUND;
 end if;
 close get_proposal_csr;

 open get_proposal_csr;
 --dbms_output.PUT_LINE(' after open get_proposal_csr; ' );
 --dbms_output.PUT_LINE(' Assignment ID	' || to_char(x_assignment_id));
 --dbms_output.PUT_LINE(' element_type_id ' || to_char(x_element_type_id));
 --dbms_output.PUT_LINE(' time period id ' || to_char(x_time_period_id));

 loop
	fetch get_proposal_csr into get_proposal_rec;
	--dbms_output.PUT_LINE('fetch get_proposal_csr into get_proposal_rec' );

	EXIT WHEN get_proposal_csr%NOTFOUND;
	l_non_working_day_flag := 0;


 open get_proposal_prevsal_csr(get_proposal_rec.change_date);
 fetch get_proposal_prevsal_csr into get_proposal_prevsal_rec;
 if get_proposal_prevsal_csr%NOTFOUND then
	--dbms_output.put_line('no data found');
null;
	-- close get_proposal_prevsal_csr;
 --	raise NO_DATA_FOUND;
-- exit;
 end if;
 close get_proposal_prevsal_csr;
	--dbms_output.PUT_LINE(' There is a record in per_pay_proposals' );
	----dbms_output.PUT_LINE('Proposed Salary	' || get_proposal_rec.proposed_salary);
	----dbms_output.PUT_LINE('Previous Salary	' || get_proposal_prevsal_rec.previous_salary);
	----dbms_output.PUT_LINE('Change Date	' || to_char(get_proposal_rec.change_date,'YYYY/MM/DD'));
	--dbms_output.PUT_LINE('L Change Date	' || to_char(get_proposal_rec.last_change_date,'YYYY/MM/DD'));

	i := ( trunc(l_change_start_date) - trunc(g_start_date) ) + 1;
	----dbms_output.PUT_LINE('i	............' || to_char(i));

-- Added the following if statement to fix the bug no. 710248, 710257
	if i < 1 then
	i := 1;
	end if;

	j:= i; -- bug fix 2426329
	----dbms_output.PUT_LINE('i	............' || to_char(i));
	if NVL(get_proposal_rec.pay_basis,' ') = 'ANNUAL' then
	--dbms_output.PUT_LINE('Pay basis ANNUAL	');
	--dbms_output.PUT_LINE('Salary	' || get_proposal_rec.previous_salary);
	if NVL(to_number(get_proposal_prevsal_rec.previous_salary),0) = 0 then
	l_previous_salary	:= 0.00;
	l_non_working_day_flag := 1;
	else
	l_previous_salary	:= to_number(get_proposal_prevsal_rec.previous_salary) / l_no_fiscal_year;
	end if;
	----dbms_output.PUT_LINE('Previous salary	' || to_char(l_previous_salary));
	elsif NVL(get_proposal_rec.pay_basis,' ') = 'MONTHLY' then
	--dbms_output.PUT_LINE('Pay basis MONTHLY	');
	if NVL(to_number(get_proposal_prevsal_rec.previous_salary),0) = 0 then
	l_previous_salary	:= 0.00;
	l_non_working_day_flag := 1;
	else
	l_previous_salary	:= (to_number(get_proposal_prevsal_rec.previous_salary) * 12) / l_no_fiscal_year;
	end if;
	else

	if NVL(to_number(get_proposal_prevsal_rec.previous_salary),0) = 0 then
	l_previous_salary	:= 0.00;
	l_non_working_day_flag := 1;

	end if;	-- added for bug fix 2426329

	while j <= g_no_of_days loop	-- changed to j for bug fix 2426329
		daily_calendar(j) := 0.00;
		j	:= j + 1;
	end loop;

	--	exit;	commented out NOCOPY for bug fix 2426329
	end if;
-- Changed if NVL(l_daily_rate) to if NVL(l_previous_salary) in order to fix Bug No. 709900
	if NVL(l_previous_salary,0) <> 0.00 then

	l_daily_rate	:= round((l_previous_salary / g_no_of_work_days), g_ext_precision);
	else
	l_daily_rate	:= 0.00;
	end if;
	----dbms_output.PUT_LINE( 'Daily Rate ' || to_char(l_daily_rate));

	while trunc(l_change_start_date) < trunc(get_proposal_rec.change_date) loop
	if work_calendar(i)	= 'Y' then
	if l_non_working_day_flag = 1 then
-- flag is 1 means no salary for this period
		work_calendar(i) := 'N';
		daily_calendar(i) := 0.00;
--		daily_calendar(i) := NVL(l_daily_rate,0.00);
	else
	daily_calendar(i) := NVL(l_daily_rate,0.00);
	end if;
	else
	daily_calendar(i) := 0.00;
	end if;
	i	:= i + 1;
	----dbms_output.PUT_LINE('i	............' || to_char(i));
	l_change_start_date := trunc(l_change_start_date) + 1;
	----dbms_output.PUT_LINE('i	............' || to_char(l_change_start_date));
	end loop;
	l_change_start_date	:= trunc(get_proposal_rec.change_date);
 end loop;
 ----dbms_output.PUT_LINE( 'Just Crossed end loop ');

 if NVL(get_proposal_rec.pay_basis,' ') = 'ANNUAL' then
	if NVL(to_number(get_proposal_rec.proposed_salary),0) = 0 then
	l_previous_salary	:= 0.00;
	else
	l_previous_salary	:= to_number(get_proposal_rec.proposed_salary) / l_no_fiscal_year;
	end if;
 elsif NVL(get_proposal_rec.pay_basis,' ') = 'MONTHLY' then
	if NVL(to_number(get_proposal_rec.proposed_salary),0) = 0 then
		l_previous_salary	:= 0.00;
	else
	l_previous_salary	:= (to_number(get_proposal_rec.proposed_salary) * 12) / l_no_fiscal_year;
	end if;
 else
	l_previous_salary	:= 0.00;
 end if;
 --dbms_output.PUT_LINE( 'L Previous Salary ' || to_char(l_previous_salary));
 if NVL(l_previous_salary,0) <> 0.00 then

	l_daily_rate	:= round((l_previous_salary / g_no_of_work_days), g_ext_precision);

 else
	l_daily_rate	:= 0.00;
 end if;
 ----dbms_output.PUT_LINE( 'L daily rate ' || to_char(l_daily_rate));
 i := ( trunc(l_change_start_date) - trunc(g_start_date) ) + 1;
 ----dbms_output.PUT_LINE('i	............' || to_char(i));

 while l_change_start_date <= trunc(g_end_date) loop
	if work_calendar(i)	= 'Y' then
	daily_calendar(i) := l_daily_rate;
	else
	daily_calendar(i) := 0.00;
	end if;
	i	:= i + 1;
	--dbms_output.PUT_LINE('i	............' || to_char(i));
	l_change_start_date := l_change_start_date + 1;
	--dbms_output.PUT_LINE('i	............' || to_char(l_change_start_date,'YYYY/MM/DD HH24:MI:SS'));
 end loop;

 close get_proposal_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 EXCEPTION
	WHEN NO_DATA_FOUND then
	begin
	i := 1;
	--dbms_output.PUT_LINE( '	When no_data_found' );
	open get_previous_proposal_csr;
	fetch get_previous_proposal_csr into get_previous_proposal_rec;
	if get_previous_proposal_csr%NOTFOUND then
	for i in 1..g_no_of_days loop
		daily_calendar(i) := 0.00;
	end loop;
	else
	begin
	--dbms_output.PUT_LINE( '	else of if get_previous_proposal_csr%NOTFOUND then' );
		if NVL(get_previous_proposal_rec.pay_basis,' ') = 'ANNUAL' then
		if NVL(to_number(get_previous_proposal_rec.proposed_salary),0) = 0 then
		l_previous_salary	:= 0.00;
		else
		l_previous_salary	:= to_number(get_previous_proposal_rec.proposed_salary) / l_no_fiscal_year;
		end if;
	elsif NVL(get_previous_proposal_rec.pay_basis,' ') = 'MONTHLY' then
		if NVL(to_number(get_previous_proposal_rec.proposed_salary),0) = 0 then
		l_previous_salary	:= 0.00;
		else
		l_previous_salary	:= (to_number(get_previous_proposal_rec.proposed_salary) * 12) / l_no_fiscal_year;
		end if;
		else
		while i <= g_no_of_days loop
		daily_calendar(i) := 0.00;
		i	:= i + 1;
		end loop;
		l_previous_salary	:= 0.00;
		end if;
		if NVL(l_previous_salary,0) <> 0.00 then
		l_daily_rate	:= ROUND((l_previous_salary / g_no_of_work_days), g_ext_precision);	-- Introduced g_ext_precision for bug fix 2916848
		else
		l_daily_rate	:= 0.00;
		end if;
		for i in 1..g_no_of_days loop
		if work_calendar(i)	= 'Y' then
			daily_calendar(i) := l_daily_rate;
		else
			daily_calendar(i) := 0.00;
		end if;
		--dbms_output.PUT_LINE( 'Daily Rate	i ' || to_char(i) || ' ' || to_char(daily_calendar(i)));
		end loop;
		end;
	end if;
	end;
	--dbms_output.PUT_LINE( 'Daily Rate	' || to_char(l_daily_rate));
	--dbms_output.PUT_LINE( 'Previous Salary ' || to_char(l_previous_salary));
	close get_previous_proposal_csr;
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_DAILY_RATE_CALENDAR');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_DAILY_RATE_CALENDAR');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;

end create_daily_rate_calendar;
----------------CALCULATE_BALANCE_AMOUNT--------------------------------
--
PROCEDURE CALCULATE_BALANCE_AMOUNT(x_pay_amount IN NUMBER,
					x_balance_amount OUT NOCOPY NUMBER,
				x_return_status OUT NOCOPY VARCHAR2) IS
i		number(4)	:= 0;
l_total_salary	number(22,2)	:= 0.00;

begin

 ----dbms_output.PUT_LINE(' Just entered calculate_balance_amount proc... ' );
 ----dbms_output.PUT_LINE('g_no_of_days ' || to_char(g_no_of_days));
 hr_utility.trace('	Entering CALCULATE_BALANCE_AMOUNT');

 for i in 1..g_no_of_days loop
	----dbms_output.PUT_LINE('Daily Amount ' || to_char(i) || ' ' || to_char(daily_calendar(i)));
	l_total_salary	:= l_total_salary + daily_calendar(i);
 end loop;

 ----dbms_output.PUT_LINE(' l_total_salary ... ' || to_char(l_total_salary) );
 ----dbms_output.PUT_LINE(' Crossed for loop ... ' );


 if round(l_total_salary, g_precision) <> round(x_pay_amount, g_precision) then	-- corrected rounding off precision to currency precision for bug fix 2916848
	x_balance_amount	:= x_pay_amount - l_total_salary;
 else
	x_balance_amount	:= 0.00;
 end if;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;

 hr_utility.trace('	Leaving CALCULATE_BALANCE_AMOUNT');

EXCEPTION
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CALCULATE_BALANCE_AMOUNT');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;

end calculate_balance_amount;
--------------CREATE_SLINE_SALARY_CHANGE-----------------------------------
--
/*Bug 5642002: Added parameters x_start_date and x_end_date */
PROCEDURE CREATE_SLINE_SALARY_CHANGE (x_payroll_line_id IN NUMBER,
					x_start_date	IN DATE,
					x_end_date	IN DATE,
					x_return_status OUT NOCOPY VARCHAR2) IS


CURSOR get_payroll_line_csr IS
SELECT *
FROM	psp_payroll_lines
WHERE payroll_line_id	= x_payroll_line_id;

g_payroll_line_rec get_payroll_line_csr%ROWTYPE;


--SELECT change_date, previous_salary, proposed_salary
/*

CURSOR get_proposal_csr is
SELECT proposed_salary,
 previous_salary,
 change_date,
 last_change_date,
 pay_basis
FROM	per_pay_proposals_v
WHERE assignment_id = g_payroll_line_rec.assignment_id and
	element_type_id = g_payroll_line_rec.element_type_id and
	approved = 'Y' and
	change_date between (trunc(g_start_date)+1) and g_end_date
ORDER BY change_date;
*/



CURSOR get_proposal_csr is
select distinct ppp.proposed_salary_n proposed_salary, ppp.change_date
 from per_pay_proposals ppp,
	pay_input_values_f piv,
	per_pay_bases ppb,
	per_all_assignments_f paf
 where paf.assignment_id = g_payroll_line_rec.assignment_id
 and ppp.change_date between paf.effective_start_date and
paf.effective_end_date
 and paf.pay_basis_id = ppb.pay_basis_id
 and ppp.assignment_id = g_payroll_line_rec.assignment_id
 and piv.element_type_id = g_payroll_line_rec.element_type_id
and ppp.approved = 'Y'
 --and ppp.change_date <= :g_start_date
 and ppp.change_date between (trunc(g_start_date)+1) and g_end_date
 --and ppb.pay_basis_id = :p_pay_basis_id
 and ppb.input_value_id = piv.input_value_id
 and ppp.change_date
	between piv.effective_start_date and piv.effective_end_date
 order by ppp.change_date;

get_proposal_rec get_proposal_csr%ROWTYPE;



CURSOR get_proposal_prevsal_csr(p_change_date in date ) is
select ppp.proposed_salary_n previous_salary, ppp.change_date last_change_date
 from per_pay_proposals ppp,
	pay_input_values_f piv,
	per_pay_bases ppb,
	per_all_assignments_f paf
 where paf.assignment_id = g_payroll_line_rec.assignment_id
 and ppp.change_date between paf.effective_start_date and
paf.effective_end_date
 and paf.pay_basis_id = ppb.pay_basis_id
 and ppp.assignment_id = g_payroll_line_rec.assignment_id
 and piv.element_type_id = g_payroll_line_rec.element_type_id
 and ppp.approved = 'Y'
 --and ppp.change_date <= :g_start_date
-- and ppp.change_date between (trunc(g_start_date)+1) and g_end_date
and ppp.change_date < p_change_date
 --and ppb.pay_basis_id = :p_pay_basis_id
 and ppb.input_value_id = piv.input_value_id
 and ppp.change_date
	between piv.effective_start_date and piv.effective_end_date
 order by ppp.change_date desc;

get_proposal_prevsal_rec get_proposal_prevsal_csr%ROWTYPE;


l_change_date		date;
l_salary		NUMBER	:= 0;	-- Changed Datatype to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_proposed_salary	NUMBER	:= 0;	-- Changed Datatype to NUMBER from NUMBER(22, 2) for bug fix 2916848
--l_proposed_salary	varchar2(30);

l_pay_basis1		varchar2(30):=NULL;
l_last_change_date1 date;
/*

CURSOR get_previous_proposal_csr is
SELECT change_date, proposed_salary
FROM	per_pay_proposals_v
WHERE	assignment_id = g_payroll_line_rec.assignment_id and
	element_type_id	= g_payroll_line_rec.element_type_id and
	change_date <= g_start_date and
	approved = 'Y' and
	change_date = (select max(change_date) from per_pay_proposals_v
			where assignment_id = g_payroll_line_rec.assignment_id and
			change_date <= g_start_date and approved = 'Y')
ORDER BY change_date;

CURSOR get_previous_proposal_csr is
SELECT proposed_salary, change_date,pay_basis
FROM	per_pay_proposals_v
WHERE	assignment_id = g_payroll_line_rec.assignment_id and
	element_type_id	= g_payroll_line_rec.element_type_id and
	change_date <= g_start_date and
	approved = 'Y'
	order by change_date desc;
*/

CURSOR get_previous_proposal_csr is
select ppp.proposed_salary_n proposed_salary, ppp.change_date, ppb.pay_basis
 from per_pay_proposals ppp,
	pay_input_values_f piv,
	per_pay_bases ppb,
	per_all_assignments_f paf
 where paf.assignment_id =g_payroll_line_rec.assignment_id
 and ppp.change_date between paf.effective_start_date and
paf.effective_end_date
 and paf.pay_basis_id = ppb.pay_basis_id
 and ppp.assignment_id = g_payroll_line_rec.assignment_id
 and piv.element_type_id = g_payroll_line_rec.element_type_id
 and ppp.approved = 'Y'
 --and ppp.change_date <= :g_start_date
 and ppp.change_date =
		(select max(change_date)
		from per_pay_proposals ppp1
		where ppp1.assignment_id = g_payroll_line_rec.assignment_id
		and ppp1.approved = 'Y'
		and ppp1.change_date <= g_start_date)
 --and ppb.pay_basis_id = :p_pay_basis_id
 and ppb.input_value_id = piv.input_value_id
 and ppp.change_date
	between piv.effective_start_date and piv.effective_end_date
 order by ppp.change_date desc;
get_previous_proposal_rec get_previous_proposal_csr%ROWTYPE;

--
i			number(3)	:= 0;
l_rowid			varchar2(20)	:= NULL;
l_sub_line_start_date	date;
l_sub_line_end_date	date;
l_sub_line_id		number(9)	:= 0;
l_array_begin		number(4)	:= 0;
l_array_end		number(4)	:= 0;
l_rate_salary		NUMBER	:= 0;	-- Changed Datatype to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_balance_salary	NUMBER	:= 0;	-- Changed Datatype to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_daily_rate		NUMBER	:= 0;	-- Changed Datatype to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_total_daily_rate	NUMBER	:= 0;	-- Changed Datatype to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_daily_balance	NUMBER	:= 0;	-- Changed Datatype to NUMBER from NUMBER(22, 2) for bug fix 2916848
l_work_days		number(4)	:= 0;
l_total_work_days	number(3)	:= 0;
l_paybasis varchar2(30);

--
BEGIN
 hr_utility.trace('	Entering CREATE_SLINE_SALARY_CHANGE');
 hr_utility.trace('	X_Payroll_line_id ...' || to_char(x_payroll_line_id));
 open get_payroll_line_csr;
 fetch get_payroll_line_csr into g_payroll_line_rec;
 if get_payroll_line_csr%NOTFOUND then
	fnd_message.set_name('PSP', 'PSP_NO_PAYROLL_LINES');
	fnd_msg_pub.add;
	close get_payroll_line_csr;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 end if;
 close get_payroll_line_csr;
 ---hr_utility.trace('	Pay amount ..	' || to_char(g_payroll_line_rec.pay_amount));
 ---hr_utility.trace('	Balance amount .. ' || to_char(g_payroll_line_rec.balance_amount));

 l_sub_line_start_date	:= trunc(g_start_date);

 if round(g_payroll_line_rec.balance_amount, g_precision) <> 0.00 then	-- Modified rounding precision to currency precision for bug fix 2916848
-- Added to fix Assignment start_date in payroll period
	for i in 1..g_no_of_days loop
	if work_calendar(i) = 'Y' then
		l_total_work_days	:= l_total_work_days + 1;
	end if;
	end loop;
	l_daily_balance	:= round((g_payroll_line_rec.balance_amount / l_total_work_days), g_ext_precision);
 else
	l_daily_balance	:= 0.00;
 end if;
 ---hr_utility.trace('	Daily Balance..	' || to_char(l_daily_balance));
 ---hr_utility.trace('	Assignment_id ..	' || to_char(g_payroll_line_rec.assignment_id));
 ---hr_utility.trace('	Element type_id .. ' || to_char(g_payroll_line_rec.element_type_id));
 ---hr_utility.trace('	G_start_date	.. ' || to_char(g_start_date,'YYYY/MM/DD HH24:MI:SS'));
 ---hr_utility.trace('	G_end_date	..	' || to_char(g_end_date,'YYYY/MM/DD HH24:MI:SS'));

 open get_proposal_csr;
 --fetch geto _proposal_csr into l_change_date, l_salary, l_proposed_salary;
 fetch get_proposal_csr into
	l_proposed_salary, l_change_date;
	-- l_proposed_salary, l_salary, l_change_date;
 -- l_last_change_date1, l_pay_basis1;

 ---hr_utility.trace('	Just After fetch get_proposal l_change_date '||to_char(l_change_date) );
 ---hr_utility.trace('	Just After fetch get_proposal l_proposed_sal '||to_char(l_proposed_salary) );
 if get_proposal_csr%NOTFOUND then
	close get_proposal_csr;
	raise NO_DATA_FOUND;
 end if;
 close get_proposal_csr;

 hr_utility.trace('	Just crossed NOTFOUND if' );

 open get_proposal_csr;
 loop
	hr_utility.trace('	Just entered Loop ' );
--	fetch get_proposal_csr into l_change_date, l_salary, l_proposed_salary;


 fetch get_proposal_csr into
	l_proposed_salary, l_change_date;
--	l_proposed_salary, l_salary, l_change_date,
 --	l_last_change_date1, l_pay_basis1;

	EXIT WHEN get_proposal_csr%NOTFOUND;
---	hr_utility.trace('	After Exit When' );

	---hr_utility.trace('	proposed salary inside loop '||to_char(l_proposed_salary));
	---hr_utility.trace('	change_date is inside loop '||to_char(l_change_date));

 open get_proposal_prevsal_csr(l_change_date);
 fetch get_proposal_prevsal_csr into get_proposal_prevsal_rec;
 if get_proposal_prevsal_csr%NOTFOUND then
 ---	hr_utility.trace('	no data found');
 --	close get_proposal_prevsal_csr;
 --	raise NO_DATA_FOUND;
--exit;
	null;
 end if;
 close get_proposal_prevsal_csr;

	l_salary:=nvl(get_proposal_prevsal_rec.previous_salary, 0);
 ---hr_utility.trace('	 sal from previous '||to_char(l_salary));



	l_work_days		:= 0;
	l_rate_salary	:= 0.00;
	l_array_begin	:= (trunc(l_sub_line_start_date) - trunc(g_start_date)) + 1;
	hr_utility.trace('	l_arry_begin .......' || to_char(l_array_begin));
	l_array_end		:= (trunc(l_change_date) - trunc(g_start_date));
	l_sub_line_end_date	:= trunc(l_change_date) - 1;
	hr_utility.trace('	i......... ' || to_char(i));
	for i in l_array_begin..l_array_end loop
	l_rate_salary	:= l_rate_salary + daily_calendar(i);
-- commented the following line and added it in the following if
-- the reason is if the last date is non working day, in sub lines
-- it is writing daily rate as 0
--	l_daily_rate	:= daily_calendar(i);
	if work_calendar(i) = 'Y' then
		l_work_days	:= l_work_days + 1;
	l_daily_rate	:= daily_calendar(i);
	end if;
	end loop;

	if round(g_payroll_line_rec.balance_amount, g_precision) <> 0.00 then	-- Modified rounding precision to currency precision for bug fix 2916848
	-- l_balance_salary	:= l_daily_balance * l_work_days ;

	l_balance_salary := round(l_daily_balance * l_work_days, g_precision);	-- bug 3109943
	else
	l_balance_salary := 0.00;
	end if;

	---hr_utility.trace('	Daily Balance ..' || to_char(l_daily_balance));
	---hr_utility.trace('	Rate Salary ..' || to_char(l_rate_salary));
	hr_utility.trace('	Balance Salary ..' || to_char(l_balance_salary));
	if round((l_rate_salary + l_balance_salary),0) = 0 then
	l_total_daily_rate := 0.00;
	else
	l_total_daily_rate := l_daily_rate + l_daily_balance;
	end if;
	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
	FROM DUAL;
	---hr_utility.trace('	Sub line		' || to_char(l_sub_line_id));
	hr_utility.trace('	inserting into Sublines -1');
	if l_total_daily_Rate > 0 then

	PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_sub_line_start_date,
			X_SUB_LINE_END_DATE		=> l_sub_line_end_date,
			X_REASON_CODE			=> 'SALARY_CHANGE',
			X_PAY_AMOUNT			=> round((l_rate_salary + l_balance_salary), g_precision),	-- bug 3109943
			X_DAILY_RATE			=> l_total_daily_rate,
			X_SALARY_USED			=> NVL(l_salary,0),
			X_CURRENT_SALARY		=> NVL(l_salary,0),
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> NULL,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> NULL,
			X_ASSIGNMENT_BEGIN_DATE		=> NULL,
			X_ASSIGNMENT_END_DATE		=> NULL,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R' );
	hr_utility.trace('	Crossed Insert rec into sub lines');

	l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'SALARY_CHANGE',
			X_PARENT_LINE_ID		=> l_sub_line_id,
			X_MODE				=> 'R');
	end if;

	l_sub_line_start_date	:= trunc(l_change_date);
 end loop;

	l_work_days		:= 0;
	l_rate_salary	:= 0.00;
	l_array_begin	:= (trunc(l_sub_line_start_date) - trunc(g_start_date)) + 1;
	l_array_end		:= (trunc(g_end_date) - trunc(g_start_date)) + 1;
	for i in l_array_begin..l_array_end loop
	l_rate_salary	:= l_rate_salary + daily_calendar(i);
	if work_calendar(i) = 'Y' then
		l_work_days	:= l_work_days + 1;
		l_daily_rate	:= daily_calendar(i);
	end if;
	end loop;

	if round(g_payroll_line_rec.balance_amount, g_precision) <> 0.00 then	-- Modified rounding precision to currency precision for bug fix 2916848
	-- l_balance_salary	:= l_daily_balance * l_work_days ;
	l_balance_salary	:= round((l_daily_balance * l_work_days), g_precision) ;	-- bug fix 3109943
	else
	l_balance_salary := 0.00;
	end if;
	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
	FROM DUAL;
	----hr_utility.trace('	Before Insert rec into sub lines 2');
	hr_utility.trace('	inserting into Sublines -2');
	PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_sub_line_start_date,
			X_SUB_LINE_END_DATE		=> trunc(g_end_date),
			X_REASON_CODE			=> 'SALARY_CHANGE',
			X_PAY_AMOUNT			=> round((l_rate_salary + l_balance_salary), g_precision), -- bug 3109943
			X_DAILY_RATE			=> l_daily_rate + l_daily_balance,
			X_SALARY_USED			=> NVL(l_proposed_salary,0),
			X_CURRENT_SALARY		=> NVL(l_proposed_salary,0),
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> NULL,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> NULL,
			X_ASSIGNMENT_BEGIN_DATE		=> NULL,
			X_ASSIGNMENT_END_DATE		=> NULL,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R' );
	----hr_utility.trace('	Sub line		' || to_char(l_sub_line_id));
	----hr_utility.trace('	Crossed Insert rec into sub lines 2');
	l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'SALARY_CHANGE',
			X_PARENT_LINE_ID		=> l_sub_line_id,
			X_MODE				=> 'R');

 close get_proposal_csr;

 hr_utility.trace('	Leaving CREATE_SLINE_SALARY_CHANGE');


 EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
--	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_DAILY_RATE_CALENDAR');	Commented for bug fix 2439207
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_SALARY_CHANGE');	-- Introduced for bug 2439207
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN NO_DATA_FOUND then
	begin
	----hr_utility.trace('	Entered NO_DATA_FOUND');

	open get_previous_proposal_csr;
	----hr_utility.trace('	After open cursor');
	fetch get_previous_proposal_csr into l_salary, l_change_date, l_paybasis;
	----hr_utility.trace('	After fetch cursor');
	if get_previous_proposal_csr%NOTFOUND then
	----hr_utility.trace('	Entered if NOTFOUND');
	----hr_utility.trace('	Pay amount	' || to_char(g_payroll_line_rec.pay_amount));
	----hr_utility.trace('	Person work days ' || to_char(g_no_of_person_work_days));
	----hr_utility.trace('	Balance amount	' || to_char(g_payroll_line_rec.balance_amount));

	l_daily_rate	:= round((g_payroll_line_rec.pay_amount / g_no_of_person_work_days), g_ext_precision);

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id FROM DUAL;
	----hr_utility.trace('	Before Insert rec into sub lines 3');
		----hr_utility.trace('	Subline id	' || to_char(l_sub_line_id));
		----hr_utility.trace('	line id	' || to_char(x_payroll_line_id) );
		----hr_utility.trace('	line start date ' || to_char(l_sub_line_start_date,'YYYY/MM/DD HH24:MI:SS'));

		----hr_utility.trace('	line end date	' || to_char(g_end_date,'YYYY/MM/DD HH24:MI:SS'));
		----hr_utility.trace('	Daily rate	' || to_char(g_end_date,'YYYY/MM/DD HH24:MI:SS'));
			l_salary:=0;
 hr_utility.trace('	inserting into Sublines -3');
	PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> TRUNC(NVL(x_start_date,l_sub_line_start_date)),
			X_SUB_LINE_END_DATE		=> TRUNC(NVL(x_end_date,g_end_date)),
			X_REASON_CODE			=> 'NO_SALARY_CHANGE',
			X_PAY_AMOUNT			=> g_payroll_line_rec.pay_amount,
			X_DAILY_RATE			=> l_daily_rate,
			X_SALARY_USED			=> NVL(l_salary,0),
			X_CURRENT_SALARY		=> NULL,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> NULL,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> NULL,
			X_ASSIGNMENT_BEGIN_DATE		=> NULL,
			X_ASSIGNMENT_END_DATE		=> NULL,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R' );
	----dbms_output.PUT_LINE('After Insert rec into sub lines 3');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'NO_SALARY_CHANGE',
			X_PARENT_LINE_ID		=> l_sub_line_id,
			X_MODE				=> 'R');
	----dbms_output.PUT_LINE('After Insert rec into sub line reason 3');

	else
	begin
		----dbms_output.PUT_LINE('Entered else of if %NOTFOUND ');
		l_rate_salary	:= NVL(g_payroll_line_rec.pay_amount,0);
		for i in 1..g_no_of_days loop
		if daily_calendar(i) <> 0 then
		l_daily_rate	:= daily_calendar(i);
		exit;
		end if;

	end loop;

		l_balance_salary	:= round(NVL(g_payroll_line_rec.balance_amount,0), g_precision);	-- Modified rounding precision to currency precision for bug fix 2916848
		----dbms_output.PUT_LINE('Balance Amount ' || to_char(round(g_payroll_line_rec.balance_amount,2)));
		----dbms_output.PUT_LINE('Balance Salary ' || to_char(l_balance_salary));
		----dbms_output.PUT_LINE('Daily	Balance ' || to_char(l_daily_balance));

		----dbms_output.PUT_LINE('Before Insert record ');
		----dbms_output.PUT_LINE('Subline id	' || to_char(l_sub_line_id));
		----dbms_output.PUT_LINE('line id	' || to_char(x_payroll_line_id) );
		----dbms_output.PUT_LINE('line start date ' || to_char(l_sub_line_start_date));

		----dbms_output.PUT_LINE('line end date	' || to_char(l_sub_line_end_date));
		----dbms_output.PUT_LINE('l_rate_salary	' || to_char(l_rate_salary));
		----dbms_output.PUT_LINE('l_balance_salary ' || to_char(l_balance_salary));
		----dbms_output.PUT_LINE('Daily rate	' || to_char(l_daily_rate+l_daily_balance));
		----dbms_output.PUT_LINE('salary Used	' || to_char(l_salary));

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
		FROM DUAL;
 hr_utility.trace('	inserting into Sublines -5');
		PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> TRUNC(NVL(x_start_date,g_start_date)),
			X_SUB_LINE_END_DATE		=> TRUNC(NVL(x_end_date,g_end_date)),
			X_REASON_CODE			=> 'NO_SALARY_CHANGE',
			X_PAY_AMOUNT			=> l_rate_salary ,
			X_DAILY_RATE			=> l_daily_rate + l_daily_balance,
			X_SALARY_USED			=> NVL(l_salary,0),
			X_CURRENT_SALARY		=> NVL(l_salary,0),
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> NULL,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> NULL,
			X_ASSIGNMENT_BEGIN_DATE		=> NULL,
			X_ASSIGNMENT_END_DATE		=> NULL,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R' );
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'NO_SALARY_CHANGE',
			X_PARENT_LINE_ID		=> l_sub_line_id,
			X_MODE				=> 'R');
		----dbms_output.PUT_LINE('After Insert record ');
		end;
	end if;
	end;
 	hr_utility.trace('	Leaving CREATE_SLINE_SALARY_CHANGE');
	close get_previous_proposal_csr;

	WHEN OTHERS then

	hr_utility.trace('	Failing with the OTHERS exception');
	----dbms_output.PUT_LINE('Error Num : ' || to_char(SQLCODE) || 'Err Msg : ' || SUBSTR(SQLERRM,1,100));
--	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_DAILY_RATE_CALENDAR');	Commented for bug fix 2439207
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_SALARY_CHANGE');	-- Introduced for bug 2439207
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;

end CREATE_SLINE_SALARY_CHANGE;

---------------------CREATE_SLINE_ASG_CHANGE--------------------------------
--
PROCEDURE CREATE_SLINE_ASG_CHANGE (x_payroll_line_id IN NUMBER,
					x_assignment_id	IN NUMBER,
					x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR get_asg_begin_date_csr IS
SELECT effective_start_date
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id and
	effective_start_date between (trunc(g_start_date)+1) and g_end_date and
	effective_start_date = (select min(effective_start_date)
				from per_assignments_f
				where assignment_id = x_assignment_id
				AND	assignment_type ='E' ); --Added for bug 2624259.

l_start_date	date;

CURSOR get_asg_end_date_csr IS
SELECT effective_end_date
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id and
	effective_end_date between g_start_date and (trunc(g_end_date) - 1) and
	effective_end_date = (select max(effective_end_date)
				from per_assignments_f
				where assignment_id = x_assignment_id);
l_end_date	date;

CURSOR get_sublines_csr IS
SELECT *
FROM	psp_payroll_sub_lines
WHERE payroll_line_id = x_payroll_line_id and
	l_start_date between sub_line_start_date and sub_line_end_date;

g_sublines_rec get_sublines_csr%ROWTYPE;


begin

hr_utility.trace('	Entering CREATE_SLINE_ASG_CHANGE');
 ----dbms_output.put_line('Entered Proceduer create_sline_asg_change..');
 open get_asg_begin_date_csr;
 fetch get_asg_begin_date_csr into l_start_date;
 if get_asg_begin_date_csr%FOUND then
	open get_sublines_csr;
	fetch get_sublines_csr into g_sublines_rec;
	if get_sublines_csr%FOUND then
	UPDATE psp_payroll_sub_lines
		SET sub_line_start_date	= trunc(l_start_date),
		reason_code		= 'ASSG_BEGIN_DATE',
		assignment_begin_date = trunc(l_start_date)
	WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
	----dbms_output.put_line('Updated sub line with new begin date');
	end if;
	close get_sublines_csr;
 end if;
 close get_asg_begin_date_csr;

 open get_asg_end_date_csr;
 fetch get_asg_end_date_csr into l_end_date;
 if get_asg_end_date_csr%FOUND then
	l_start_date	:= trunc(l_end_date);
	open get_sublines_csr;
	fetch get_sublines_csr into g_sublines_rec;
	if get_sublines_csr%FOUND then
	UPDATE psp_payroll_sub_lines
		SET sub_line_end_date	= trunc(l_start_date),
		reason_code		= 'ASSG_END_DATE',
		assignment_end_date = trunc(l_start_date)
	WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
	----dbms_output.put_line('Updated sub line with new end date');
	end if;
	close get_sublines_csr;
 end if;
 close get_asg_end_date_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;

 hr_utility.trace('	Leaving CREATE_SLINE_ASG_CHANGE');

EXCEPTION
	WHEN OTHERS then
	close get_asg_end_date_csr;
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_ASG_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;

end CREATE_SLINE_ASG_CHANGE;


-----------------------CREATE_SLINE_ASG_STATUS_CHANGE------------------------
--
PROCEDURE CREATE_SLINE_ASG_STATUS_CHANGE (x_payroll_line_id IN NUMBER,
					x_assignment_id	IN NUMBER,
					x_balance_amount IN NUMBER,
					x_return_status OUT NOCOPY VARCHAR2) IS
CURSOR get_asg_status_csr IS
SELECT effective_start_date,	effective_end_date
FROM	per_assignments_f
WHERE	assignment_id = x_assignment_id and
	(g_start_date between effective_start_date and effective_end_date or
	g_end_date	between effective_start_date and effective_end_date or
	(g_start_date <= effective_start_date and	g_end_date >= effective_end_date )) and
	assignment_status_type_id in (select assignment_status_type_id
					from per_assignment_status_types
					where per_system_status in ('SUSP_ASSIGN','TERM_ASSIGN') )
ORDER BY effective_start_date;

l_start_date	date;
l_end_date	date;

CURSOR get_sublines_csr IS
SELECT *
FROM	psp_payroll_sub_lines
WHERE payroll_line_id = x_payroll_line_id and
	(l_start_date between sub_line_start_date and sub_line_end_date or
	l_end_date	between sub_line_start_date and sub_line_end_date);
-- or
--	(g_start_date <= sub_line_start_date and	g_end_date >= sub_line_end_date ));

g_sublines_rec get_sublines_csr%ROWTYPE;

l_sub_line_id	number(9)	:= 0;
l_rowid		varchar2(20);
l_tmp_start_date	date;
l_tmp_end_date		date;
i		number(9)	:= 0;
i2		number(9)	:= 0;
l_amount	number(22,2)	:= 0;
l_no_of_days	number(3)	:= 0;
l_total_work_days number(3) := 0;

begin

 hr_utility.trace('	Entering CREATE_SLINE_ASG_STATUS_CHANGE');
 ----dbms_output.put_line('Entered Proceduer create_sline_asg_status_change..');
 for i in 1..g_no_of_days loop
	if work_calendar(i) = 'Y' then
	l_total_work_days := l_total_work_days + 1;
	end if;
 end loop;

 open get_asg_status_csr;
 LOOP
	fetch get_asg_status_csr into l_start_date,l_end_date;
	----dbms_output.put_line('After fetch get_asg_status_csr and Before Exit......');
	EXIT WHEN get_asg_status_csr%NOTFOUND;
	----dbms_output.put_line('After Exit......');
	begin
	open get_sublines_csr;
	LOOP
	----dbms_output.put_line('Before fetch get_sublines_csr and Before Exit......');
	fetch get_sublines_csr into g_sublines_rec;
	EXIT WHEN get_sublines_csr%NOTFOUND;
	----dbms_output.put_line('After fetch get_sublines_csr and Before Exit......');
	if (l_start_date <= g_sublines_rec.sub_line_start_date and
		l_end_date	>= g_sublines_rec.sub_line_end_date)
	then
		----dbms_output.put_line('Entered 1st if ..');
		UPDATE psp_payroll_sub_lines
		SET	pay_amount	= 0.00,
		daily_rate	= 0.00,
		reason_code = 'ASSG_STATUS_CHANGE'
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
	elsif (l_start_date > g_sublines_rec.sub_line_start_date and
		l_end_date >= g_sublines_rec.sub_line_end_date)
		then
		begin
		----dbms_output.put_line('Entered 2nd if ..');
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_start_date) - 1;
		i		:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / l_total_work_days)), g_precision);
		end if;
--		----dbms_output.put_line('Entered 3rd if ..');

			SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -6');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate ,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> NULL,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> NULL,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');
		----dbms_output.put_line('After creating sub line (1)..');

		l_tmp_start_date	:= trunc(l_start_date);
		l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
hr_utility.trace('	inserting into Sublines -7');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> 0.00,
			X_DAILY_RATE			=> 0.00,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> l_tmp_start_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> NULL,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R') ;
		----dbms_output.put_line('After creating sub line (2)..');
		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
	end;
	elsif (l_start_date = g_sublines_rec.sub_line_start_date and
		l_end_date	< g_sublines_rec.sub_line_end_date) then
		begin
		----dbms_output.put_line('Entered 3rd if..');

		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_end_date);
		SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -8');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> 0.00,
			X_DAILY_RATE			=> 0.00,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> l_tmp_end_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> NULL,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');
		----dbms_output.put_line('After creating sub line (1)..');

		l_tmp_start_date	:= trunc(l_end_date) + 1;
		l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
		i		:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / l_total_work_days)), g_precision);
		end if;
			SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -10');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate ,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> NULL,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> l_tmp_start_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');
		----dbms_output.put_line('After creating sub line (2)..');
		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
	end;
	elsif (l_start_date > g_sublines_rec.sub_line_start_date and
		l_end_date	< g_sublines_rec.sub_line_end_date) then
		begin
		----dbms_output.put_line('Entered 4th if ..');
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_start_date) - 1;
		i		:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / l_total_work_days)), g_precision);
		end if;
			SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -12');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate ,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> l_tmp_end_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> l_tmp_start_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');
		----dbms_output.put_line('After 1st Insert ..');
		l_tmp_start_date	:= trunc(l_start_date);
		l_tmp_end_date	:= trunc(l_end_date) ;
		SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -13');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> 0.00,
			X_DAILY_RATE			=> 0.00,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> NULL,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> l_tmp_start_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> trunc(l_tmp_end_date) + 1,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');
		----dbms_output.put_line('After 2nd Insert ..');
		l_tmp_start_date	:= trunc(l_end_date) + 1;
		l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
		i		:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / l_total_work_days)), g_precision);

		end if;
		SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -14');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate ,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> NULL,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> l_tmp_start_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');
		----dbms_output.put_line('After 3rd Insert ..');

		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
	end;
	elsif (l_start_date = g_sublines_rec.sub_line_end_date and
		l_end_date	> g_sublines_rec.sub_line_end_date) then
	begin
		----dbms_output.put_line('Entered 5th if ..');
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc((g_sublines_rec.sub_line_end_date) - 1);

		i		:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / l_total_work_days)), g_precision);
		end if;
			SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
hr_utility.trace('	inserting into Sublines -15');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate ,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> l_tmp_end_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> l_tmp_start_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_end_date);
		l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);

		SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
		FROM DUAL;
 hr_utility.trace('	inserting into Sublines -17');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> 0.00,
			X_DAILY_RATE			=> 0.00 ,
			X_SALARY_USED			=> 0.00,
			X_CURRENT_SALARY		=> NULL,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> l_tmp_end_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> l_tmp_start_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');
		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
			elsif (l_start_date < g_sublines_rec.sub_line_start_date and
		l_end_date	< g_sublines_rec.sub_line_end_date) then
		begin
		----dbms_output.put_line('Entered 6th if ..');
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_end_date);

		SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
		FROM DUAL;
 hr_utility.trace('	inserting into Sublines -19');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> 0.00,
			X_DAILY_RATE			=> 0.00 ,
			X_SALARY_USED			=> 0.00,
			X_CURRENT_SALARY		=> NULL,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> l_tmp_end_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> l_tmp_start_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');
		l_tmp_start_date	:= trunc((l_end_date)+ 1);
		l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);

		i		:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / l_total_work_days)), g_precision);
		end if;
			SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -21');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate ,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> l_tmp_end_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> l_tmp_start_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> 'ASSG_STATUS_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');
		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	end if;
	end loop;
	close get_sublines_csr;
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	EXCEPTION
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_ASG_STATUS_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	close get_sublines_csr;
 end;
 END LOOP;
 close get_asg_status_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;

  hr_utility.trace('	Leaving CREATE_SLINE_ASG_STATUS_CHANGE');
 EXCEPTION
	WHEN NO_DATA_FOUND then
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	close get_asg_status_csr;

	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_ASG_STATUS_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	close get_asg_status_csr;

end create_sline_asg_status_change;

-------------------------_SLINE_EMP_END_DATE------------------------
PROCEDURE CREATE_SLINE_EMP_END_DATE (x_payroll_line_id IN NUMBER,
					x_person_id	IN NUMBER,
					x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR check_service_period_begin_csr IS
SELECT date_start
FROM	per_periods_of_service
WHERE	person_id = x_person_id and
		(date_start between g_start_date and g_end_date) ;

l_date_start			date;

CURSOR check_service_period_end_csr IS
SELECT actual_termination_date
FROM	per_periods_of_service
WHERE	person_id = x_person_id and
		(date_start between g_start_date and g_end_date) ;

l_actual_termination_date	date;
l_tmp_date			date;

CURSOR get_sublines_csr IS
SELECT *
FROM	psp_payroll_sub_lines
WHERE	payroll_line_id = x_payroll_line_id and
	l_tmp_date between sub_line_start_date and sub_line_end_date;

g_sublines_rec get_sublines_csr%ROWTYPE;


l_tmp_start_date	date;
l_tmp_end_date		date;
l_rowid			varchar2(20);
l_sub_line_id		number(9);

begin
 ----dbms_output.put_line('Entered Proceduer create_sline_emp_end_date..');

 hr_utility.trace('	Entering CREATE_SLINE_EMP_END_DATE');

 open check_service_period_begin_csr;
 LOOP
	fetch check_service_period_begin_csr into l_date_start;
	EXIT WHEN check_service_period_begin_csr%NOTFOUND;
	l_tmp_date	:= trunc(l_date_start);
	open get_sublines_csr;
	LOOP
	fetch get_sublines_csr into g_sublines_rec;
	EXIT WHEN get_sublines_csr%NOTFOUND;
	if l_date_start > g_sublines_rec.sub_line_start_date then
	l_tmp_end_date	:= trunc(l_date_start) - 1;
	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -22');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> g_sublines_rec.sub_line_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'EMP_BEGIN_DATE',
			X_PAY_AMOUNT			=> 0.00,
			X_DAILY_RATE			=> 0.00 ,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> l_tmp_end_date,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'EMP_BEGIN_DATE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

	l_tmp_start_date	:= trunc(l_date_start);
	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -25');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> g_sublines_rec.sub_line_end_date,
			X_REASON_CODE			=> 'EMP_BEGIN_DATE',
			X_PAY_AMOUNT			=> g_sublines_rec.pay_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> l_tmp_start_date,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'EMP_BEGIN_DATE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
	end if;
	END LOOP;
	close get_sublines_csr;
 END LOOP;
 close check_service_period_begin_csr;

 open check_service_period_end_csr;
 LOOP
	fetch check_service_period_end_csr into l_actual_termination_date;
	EXIT WHEN check_service_period_end_csr%NOTFOUND;
	l_tmp_date	:= trunc(l_actual_termination_date);
	open get_sublines_csr;
	LOOP
	fetch get_sublines_csr into g_sublines_rec;
	EXIT WHEN get_sublines_csr%NOTFOUND;
	if l_actual_termination_date < g_sublines_rec.sub_line_end_date then
	l_tmp_end_date	:= trunc(l_actual_termination_date) - 1;
	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -28');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> g_sublines_rec.sub_line_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'EMP_END_DATE',
			X_PAY_AMOUNT			=> g_sublines_rec.pay_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> l_tmp_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'EMP_END_DATE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

	l_tmp_start_date	:= trunc(l_actual_termination_date);
	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -30');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> g_sublines_rec.sub_line_end_date,
			X_REASON_CODE			=> 'EMP_END_DATE',
			X_PAY_AMOUNT			=> 0.00,
			X_DAILY_RATE			=> 0.00,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> l_tmp_start_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'EMP_END_DATE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;

	end if;
	END LOOP;
	close get_sublines_csr;	-- bug fix 2806589

 END LOOP;
 close check_service_period_end_csr;	-- bug fix 2806589
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;

 hr_utility.trace('	Leaving CREATE_SLINE_EMP_END_DATE');

 EXCEPTION
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_EMP_END_DATE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
end create_sline_emp_end_date;
------------------------------CREATE_SLINE_ORG_CHANGE-------------------
---
PROCEDURE CREATE_SLINE_ORG_CHANGE(X_PAYROLL_LINE_ID IN NUMBER,
					X_ASSIGNMENT_ID	IN NUMBER,
					X_BALANCE_AMOUNT IN NUMBER,
					X_RETURN_STATUS OUT NOCOPY VARCHAR2) IS
CURSOR get_old_org_csr IS
SELECT effective_start_date, organization_id
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id and
	effective_start_date < g_start_date and
	effective_start_date = (select max(effective_start_date) from per_assignments_f
		where assignment_id = x_assignment_id
		AND assignment_type ='E' --Added for bug 2624259.
		AND effective_start_date < g_start_date);

l_effective_start_date	date;
l_old_org_id		number(9);

CURSOR get_assg_csr IS
SELECT effective_start_date, effective_end_date, organization_id
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id
	AND assignment_type ='E' --Added for bug 2624259.
	AND
	(g_start_date between effective_start_date and effective_end_date or
	g_end_date	between effective_start_date and effective_end_date or
	(g_start_date <= effective_start_date and g_end_date >= effective_end_date ))
order by effective_start_date;

l_current_start_date	date;
l_current_end_date	date;
l_new_org_id		number(9);

CURSOR get_sublines_csr IS
SELECT *
FROM	psp_payroll_sub_lines
WHERE payroll_line_id	= x_payroll_line_id and
	((sub_line_start_date between l_current_start_date and l_current_end_date) or
	(sub_line_end_date	between l_current_start_date and l_current_end_date) or
	(sub_line_start_date <= l_current_start_date and sub_line_end_date >= l_current_end_date))
order by sub_line_start_date;

g_sublines_rec get_sublines_csr%ROWTYPE;

l_tmp_start_date	date;
l_tmp_end_date		date;
l_rowid			varchar2(20);
l_sub_line_id		number(9);
i		number(9)	:= 0;
i2		number(9)	:= 0;
l_amount	number(22,2)	:= 0;
l_no_of_days	number(3)	:= 0;


begin

hr_utility.trace('	Entering CREATE_SLINE_ORG_CHANGE');

 ----dbms_output.put_line('Entered Procedure create_sline_org_change');
 open get_old_org_csr;
 ----dbms_output.put_line('Before fetch of get_old_org_csr...');
 fetch get_old_org_csr into l_effective_start_date, l_old_org_id;
 if get_old_org_csr%NOTFOUND then
	l_old_org_id	:= 0;
 end if;

 ----dbms_output.put_line('Before open get_assg_csr...');
 open get_assg_csr;
 LOOP
	----dbms_output.put_line('Before fetch get_assg_csr...');
	fetch get_assg_csr into l_current_start_date, l_current_end_date, l_new_org_id;
	EXIT WHEN get_assg_csr%NOTFOUND;
	----dbms_output.put_line('After fetch get_assg_csr...');
	if l_old_org_id = 0 or l_old_org_id = l_new_org_id then
	l_old_org_id	:= l_new_org_id;
	else
	begin
	----dbms_output.put_line('Before open get_sublines_csr...');
	open get_sublines_csr;
	----dbms_output.put_line('Before loop get_sublines_csr...');
	LOOP
	fetch get_sublines_csr into g_sublines_rec;
	EXIT WHEN get_sublines_csr%NOTFOUND;
	----dbms_output.put_line('After loop get_sublines_csr...');
	if ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
		UPDATE psp_payroll_sub_lines
			set organization_id = l_new_org_id
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
			l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
			l_tmp_end_date	:= trunc(l_current_start_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -32');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> g_sublines_rec.sub_line_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> l_old_org_id,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -33');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> l_new_org_id,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date)) then
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_end_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -34');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> l_new_org_id,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -35');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> l_old_org_id,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	else
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_start_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -37');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> l_old_org_id,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(l_current_end_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -39');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> l_new_org_id,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -42');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> l_old_org_id,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'ORG_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	end if;
	l_old_org_id	:= l_new_org_id;
	END LOOP;
	close get_sublines_csr;
	end;
	end if;
 END LOOP;
 close get_assg_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;

 hr_utility.trace('	Leaving CREATE_SLINE_ORG_CHANGE');

 EXCEPTION
	WHEN NO_DATA_FOUND then
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	close get_assg_csr;
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_ORG_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	close get_assg_csr;

end create_sline_org_change;

-----------------------CREATE_SLINE_JOB_CHANGE--------------------
--
PROCEDURE CREATE_SLINE_JOB_CHANGE(X_PAYROLL_LINE_ID IN NUMBER,
					X_ASSIGNMENT_ID	IN NUMBER,
					X_BALANCE_AMOUNT IN NUMBER,
					X_RETURN_STATUS OUT NOCOPY VARCHAR2) IS
CURSOR get_old_job_csr IS
SELECT effective_start_date, job_id
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id and
	effective_start_date < g_start_date and
	effective_start_date = (select max(effective_start_date) from per_assignments_f
		where assignment_id = x_assignment_id
		AND assignment_type ='E' --Added for bug 2624259.
		AND effective_start_date < g_start_date);

l_effective_start_date	date;
l_old_job_id		number(9);

CURSOR get_assg_csr IS
SELECT effective_start_date, effective_end_date, job_id
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id
	AND assignment_type ='E' --Added for bug 2624259.
	AND
	(g_start_date between effective_start_date and effective_end_date or
	g_end_date	between effective_start_date and effective_end_date or
	(g_start_date <= effective_start_date and g_end_date >= effective_end_date ))
order by effective_start_date;

l_current_start_date	date;
l_current_end_date	date;
l_new_job_id		number(9);

CURSOR get_sublines_csr IS
SELECT *
FROM	psp_payroll_sub_lines
WHERE payroll_line_id	= x_payroll_line_id and
	((sub_line_start_date between l_current_start_date and l_current_end_date) or
	(sub_line_end_date	between l_current_start_date and l_current_end_date) or
	(sub_line_start_date <= l_current_start_date and sub_line_end_date >= l_current_end_date))
order by sub_line_start_date;

g_sublines_rec get_sublines_csr%ROWTYPE;

l_tmp_start_date	date;
l_tmp_end_date		date;
l_rowid			varchar2(20);
l_sub_line_id		number(9);
i		number(9)	:= 0;
i2		number(9)	:= 0;
l_amount	number(22,2)	:= 0;
l_no_of_days	number(3)	:= 0;


begin

hr_utility.trace('	Entering CREATE_SLINE_JOB_CHANGE');

 open get_old_job_csr;
 fetch get_old_job_csr into l_effective_start_date, l_old_job_id;
 if get_old_job_csr%NOTFOUND then
	l_old_job_id	:= 0;
 end if;

 open get_assg_csr;
 LOOP
	fetch get_assg_csr into l_current_start_date, l_current_end_date, l_new_job_id;
	EXIT WHEN get_assg_csr%NOTFOUND;
	if NVL(l_old_job_id,0) = 0 or NVL(l_old_job_id,0) = NVL(l_new_job_id,0) then
	l_old_job_id	:= l_new_job_id;
	else
	begin
	open get_sublines_csr;
	LOOP
	fetch get_sublines_csr into g_sublines_rec;
	EXIT WHEN get_sublines_csr%NOTFOUND;
	if ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
		UPDATE psp_payroll_sub_lines
			set job_id = l_new_job_id
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
			l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
			l_tmp_end_date	:= trunc(l_current_start_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -52');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> g_sublines_rec.sub_line_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> l_old_job_id,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -62');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> l_new_job_id,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R' );


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date)) then
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_end_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -92');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> l_new_job_id,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -102');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> l_old_job_id,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R' );


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	else
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_start_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -202');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> l_old_job_id,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(l_current_end_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -302');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> l_new_job_id,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -402');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> l_old_job_id,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'JOB_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	end if;
	l_old_job_id	:= l_new_job_id;
	END LOOP;
	close get_sublines_csr;
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	EXCEPTION
	WHEN NO_DATA_FOUND then
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	close get_sublines_csr;
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_JOB_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	close get_sublines_csr;
	end;
	end if;
 END LOOP;
 close get_assg_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 hr_utility.trace('	Leaving CREATE_SLINE_JOB_CHANGE');
 EXCEPTION
	WHEN NO_DATA_FOUND then
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	close get_assg_csr;
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_JOB_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	close get_assg_csr;
end create_sline_job_change;
--------------------------------CREATE_SLINE_POSITION_CHANGE--------------
---
PROCEDURE CREATE_SLINE_POSITION_CHANGE(X_PAYROLL_LINE_ID IN NUMBER,
					X_ASSIGNMENT_ID	IN NUMBER,
					X_BALANCE_AMOUNT IN NUMBER,
					X_RETURN_STATUS OUT NOCOPY VARCHAR2) IS
CURSOR get_old_position_csr IS
SELECT effective_start_date, position_id
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id and
	effective_start_date < g_start_date and
	effective_start_date = (select max(effective_start_date) from per_assignments_f
		where assignment_id = x_assignment_id
		AND assignment_type ='E' --Added for bug 2624259.
		AND effective_start_date < g_start_date);

l_effective_start_date		date;
l_old_position_id		number(15);	-- Bug 2231410 : Increased the lenght of position_id column from 9 to 15

CURSOR get_assg_csr IS
SELECT effective_start_date, effective_end_date, position_id
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id
	AND assignment_type ='E' --Added for bug 2624259.
	AND
	(g_start_date between effective_start_date and effective_end_date or
	g_end_date	between effective_start_date and effective_end_date or
	(g_start_date <= effective_start_date and g_end_date >= effective_end_date ))
order by effective_start_date;

l_current_start_date	date;
l_current_end_date	date;
l_new_position_id		number(15); -- Bug 2231410 : Increased the lenght of position_id column from 9 to 15

CURSOR get_sublines_csr IS
SELECT *
FROM	psp_payroll_sub_lines
WHERE payroll_line_id	= x_payroll_line_id and
	((sub_line_start_date between l_current_start_date and l_current_end_date) or
	(sub_line_end_date	between l_current_start_date and l_current_end_date) or
	(sub_line_start_date <= l_current_start_date and sub_line_end_date >= l_current_end_date))
order by sub_line_start_date;

g_sublines_rec get_sublines_csr%ROWTYPE;

l_tmp_start_date	date;
l_tmp_end_date		date;
l_rowid			varchar2(20);
l_sub_line_id		number(9);
i		number(9)	:= 0;
i2		number(9)	:= 0;
l_amount	number(22,2)	:= 0;
l_no_of_days	number(3)	:= 0;


begin

 hr_utility.trace('	Entering CREATE_SLINE_POSITION_CHANGE');

 open get_old_position_csr;
 fetch get_old_position_csr into l_effective_start_date, l_old_position_id;
 if get_old_position_csr%NOTFOUND then
	l_old_position_id	:= 0;
 end if;

 open get_assg_csr;
 LOOP
	fetch get_assg_csr into l_current_start_date, l_current_end_date, l_new_position_id;
	EXIT WHEN get_assg_csr%NOTFOUND;
	if NVL(l_old_position_id,0) = 0 or NVL(l_old_position_id,0) = NVL(l_new_position_id,0) then
	l_old_position_id	:= l_new_position_id;
	else
	begin
	open get_sublines_csr;
	LOOP
	fetch get_sublines_csr into g_sublines_rec;
	EXIT WHEN get_sublines_csr%NOTFOUND;
	if ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
		UPDATE psp_payroll_sub_lines
			set position_id = l_new_position_id
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
			l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
			l_tmp_end_date	:= trunc(l_current_start_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -502');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> g_sublines_rec.sub_line_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> l_old_position_id,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -502');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> l_new_position_id,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date)) then
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_end_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -702');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> l_new_position_id,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -802');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> l_old_position_id,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R' );


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	else
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_start_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -902');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> l_old_position_id,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(l_current_end_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)),g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -802');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> l_new_position_id,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -1002');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> l_old_position_id,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'POSITION_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	end if;
	l_old_position_id	:= l_new_position_id;
	END LOOP;
	close get_sublines_csr;
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	EXCEPTION
	WHEN NO_DATA_FOUND then
		x_return_status	:= FND_API.G_RET_STS_SUCCESS;
		close get_sublines_csr;
	WHEN OTHERS then
		fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_POSITION_CHANGE');
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		close get_sublines_csr;
	end;
	end if;
 END LOOP;
 close get_assg_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 hr_utility.trace('	Leaving CREATE_SLINE_POSITION_CHANGE');
 EXCEPTION
	WHEN NO_DATA_FOUND then
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	close get_assg_csr;
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_POSITION_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	close get_assg_csr;

end create_sline_position_change;




PROCEDURE CREATE_SLINE_GRADE_CHANGE(X_PAYROLL_LINE_ID IN NUMBER,
					X_ASSIGNMENT_ID	IN NUMBER,
					X_BALANCE_AMOUNT IN NUMBER,
					X_RETURN_STATUS OUT NOCOPY VARCHAR2) IS
CURSOR get_old_grade_csr IS
SELECT effective_start_date, grade_id
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id and
	effective_start_date < g_start_date and
	effective_start_date = (select max(effective_start_date) from per_assignments_f
		where assignment_id = x_assignment_id
		AND	assignment_type ='E' --Added for bug 2624259.
		AND	effective_start_date < g_start_date);

l_effective_start_date		date;
l_old_grade_id		number(9);

CURSOR get_assg_csr IS
SELECT effective_start_date, effective_end_date, grade_id
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id
	AND assignment_type ='E'	--Added for bug 2624259.
	AND
	(g_start_date between effective_start_date and effective_end_date or
	g_end_date	between effective_start_date and effective_end_date or
	(g_start_date <= effective_start_date and g_end_date >= effective_end_date ))
order by effective_start_date;

l_current_start_date	date;
l_current_end_date	date;
l_new_grade_id		number(9);

CURSOR get_sublines_csr IS
SELECT *
FROM	psp_payroll_sub_lines
WHERE payroll_line_id	= x_payroll_line_id and
	((sub_line_start_date between l_current_start_date and l_current_end_date) or
	(sub_line_end_date	between l_current_start_date and l_current_end_date) or
	(sub_line_start_date <= l_current_start_date and sub_line_end_date >= l_current_end_date))
order by sub_line_start_date;

g_sublines_rec get_sublines_csr%ROWTYPE;

l_tmp_start_date	date;
l_tmp_end_date		date;
l_rowid			varchar2(20);
l_sub_line_id		number(9);
i		number(9)	:= 0;
i2		number(9)	:= 0;
l_amount	number(22,2)	:= 0;
l_no_of_days	number(3)	:= 0;


begin
 hr_utility.trace('	Entering CREATE_SLINE_GRADE_CHANGE');
 open get_old_grade_csr;
 fetch get_old_grade_csr into l_effective_start_date, l_old_grade_id;
 if get_old_grade_csr%NOTFOUND then
	l_old_grade_id	:= 0;
 end if;

 open get_assg_csr;
 LOOP
	fetch get_assg_csr into l_current_start_date, l_current_end_date, l_new_grade_id;
	EXIT WHEN get_assg_csr%NOTFOUND;
	if NVL(l_old_grade_id,0) = 0 or NVL(l_old_grade_id,0) = NVL(l_new_grade_id,0) then
	l_old_grade_id	:= l_new_grade_id;
	else
	begin
	open get_sublines_csr;
	LOOP
	fetch get_sublines_csr into g_sublines_rec;
	EXIT WHEN get_sublines_csr%NOTFOUND;
	if ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
		UPDATE psp_payroll_sub_lines
			set grade_id = l_new_grade_id
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
			l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
			l_tmp_end_date	:= trunc(l_current_start_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2002');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> g_sublines_rec.sub_line_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=>g_sublines_rec.position_id,
			X_GRADE_ID			=> l_old_grade_id,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -3002');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=>g_sublines_rec.position_id,
			X_GRADE_ID			=> l_new_grade_id,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date)) then
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_end_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount, g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -4002');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=>g_sublines_rec.position_id,
			X_GRADE_ID			=> l_new_grade_id,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -5002');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=>g_sublines_rec.position_id,
			X_GRADE_ID			=> l_old_grade_id,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R' );


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	else
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_start_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount, g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -6002');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=>g_sublines_rec.position_id,
			X_GRADE_ID			=> l_old_grade_id,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(l_current_end_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -7002');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> l_new_grade_id,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -8002');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> l_old_grade_id,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'GRADE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	end if;
	l_old_grade_id	:= l_new_grade_id;
	END LOOP;
	close get_sublines_csr;
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	hr_utility.trace('	Leaving CREATE_SLINE_GRADE_CHANGE');
	EXCEPTION
	WHEN NO_DATA_FOUND then
		x_return_status	:= FND_API.G_RET_STS_SUCCESS;
		close get_sublines_csr;
	WHEN OTHERS then
		fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_GRADE_CHANGE');
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		close get_sublines_csr;
	end;
	end if;
 END LOOP;
 close get_assg_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 EXCEPTION
	WHEN NO_DATA_FOUND then
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	close get_assg_csr;
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_GRADE_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	close get_assg_csr;

end create_sline_grade_change;




/* new Procedure to split subline by people group added	*/

--------------------------------CREATE_SLINE_PPGROUP_CHANGE--------------
---
PROCEDURE CREATE_SLINE_PPGROUP_CHANGE(X_PAYROLL_LINE_ID IN NUMBER,
					X_ASSIGNMENT_ID	IN NUMBER,
					X_BALANCE_AMOUNT IN NUMBER,
					X_RETURN_STATUS OUT NOCOPY VARCHAR2) IS
CURSOR get_old_ppgroup_csr IS
SELECT effective_start_date, people_group_id
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id and
	effective_start_date < g_start_date and
	effective_start_date = (select max(effective_start_date) from per_assignments_f
		where assignment_id = x_assignment_id
		AND	assignment_type ='E'	--Added for bug 2624259.
		AND	effective_start_date < g_start_date);

l_effective_start_date		date;
l_old_ppgroup_id		number(9);

CURSOR get_assg_csr IS
SELECT effective_start_date, effective_end_date, people_group_id
FROM	per_assignments_f
WHERE assignment_id = x_assignment_id
	AND assignment_type ='E'	--Added for bug 2624259.
	AND
	(g_start_date between effective_start_date and effective_end_date or
	g_end_date	between effective_start_date and effective_end_date or
	(g_start_date <= effective_start_date and g_end_date >= effective_end_date ))
order by effective_start_date;

l_current_start_date	date;
l_current_end_date	date;
l_new_ppgroup_id		number(9);

CURSOR get_sublines_csr IS
SELECT *
FROM	psp_payroll_sub_lines
WHERE payroll_line_id	= x_payroll_line_id and
	((sub_line_start_date between l_current_start_date and l_current_end_date) or
	(sub_line_end_date	between l_current_start_date and l_current_end_date) or
	(sub_line_start_date <= l_current_start_date and sub_line_end_date >= l_current_end_date))
order by sub_line_start_date;

g_sublines_rec get_sublines_csr%ROWTYPE;

l_tmp_start_date	date;
l_tmp_end_date		date;
l_rowid			varchar2(20);
l_sub_line_id		number(9);
i		number(9)	:= 0;
i2		number(9)	:= 0;
l_amount	number(22,2)	:= 0;
l_no_of_days	number(3)	:= 0;


begin
 hr_utility.trace('	Entering CREATE_SLINE_PPGROUP_CHANGE');
 open get_old_ppgroup_csr;
 fetch get_old_ppgroup_csr into l_effective_start_date, l_old_ppgroup_id;
 if get_old_ppgroup_csr%NOTFOUND then
	l_old_ppgroup_id	:= 0;
 end if;

 open get_assg_csr;
 LOOP
	fetch get_assg_csr into l_current_start_date, l_current_end_date, l_new_ppgroup_id;
	EXIT WHEN get_assg_csr%NOTFOUND;
	if NVL(l_old_ppgroup_id,0) = 0 or NVL(l_old_ppgroup_id,0) = NVL(l_new_ppgroup_id,0) then
	l_old_ppgroup_id	:= l_new_ppgroup_id;
	else
	begin
	open get_sublines_csr;
	LOOP
	fetch get_sublines_csr into g_sublines_rec;
	EXIT WHEN get_sublines_csr%NOTFOUND;
	if ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
		UPDATE psp_payroll_sub_lines
			set people_group_id = l_new_ppgroup_id
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
			l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
			l_tmp_end_date	:= trunc(l_current_start_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -9002');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> g_sublines_rec.sub_line_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> l_old_ppgroup_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2Y');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> l_new_ppgroup_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date)) then
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_end_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount, g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2OX');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> l_new_ppgroup_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2LXL');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> l_old_ppgroup_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'PPGROUP_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R' );


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	else
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_start_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount, g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2UIORA');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> l_old_ppgroup_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(l_current_end_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2JADF');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> l_new_ppgroup_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -299ek');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> l_old_ppgroup_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'PEOPLE_GROUP_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	end if;
	l_old_ppgroup_id	:= l_new_ppgroup_id;
	END LOOP;
	close get_sublines_csr;
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	EXCEPTION
	WHEN NO_DATA_FOUND then
		x_return_status	:= FND_API.G_RET_STS_SUCCESS;
		close get_sublines_csr;
	WHEN OTHERS then
		fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_POSITION_CHANGE');
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		close get_sublines_csr;
	end;
	end if;
 END LOOP;
 close get_assg_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 hr_utility.trace('	Leaving CREATE_SLINE_PPGROUP_CHANGE');
 EXCEPTION
	WHEN NO_DATA_FOUND then
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	close get_assg_csr;
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_PPGROUP_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	close get_assg_csr;

end create_sline_ppgroup_change;








---------------------------------CREATE_SLINE_FTE_CHANGE---------------------
---
PROCEDURE CREATE_SLINE_FTE_CHANGE(X_PAYROLL_LINE_ID IN NUMBER,
					X_ASSIGNMENT_ID	IN NUMBER,
					X_BALANCE_AMOUNT IN NUMBER,
					X_RETURN_STATUS OUT NOCOPY VARCHAR2) IS
l_current_start_date	date;
l_current_end_date	date;
l_new_fte		number(22,2);

CURSOR get_sublines_csr IS
SELECT *
FROM	psp_payroll_sub_lines
WHERE payroll_line_id	= x_payroll_line_id and
	((sub_line_start_date between l_current_start_date and l_current_end_date) or
	(sub_line_end_date	between l_current_start_date and l_current_end_date) or
	(sub_line_start_date <= l_current_start_date and sub_line_end_date >= l_current_end_date))
order by sub_line_start_date;

g_sublines_rec get_sublines_csr%ROWTYPE;


l_tmp_start_date	date;
l_tmp_end_date		date;
l_rowid			varchar2(20);
l_sub_line_id		number(9);
i			number(9)	:= 0;
i2			number(9)	:= 0;
l_amount		number(22,2)	:= 0;
l_no_of_days		number(3)	:= 0;
l_fte_option_value	varchar2(30);
l_fte_value		varchar2(30);
l_cur_handle		integer ;
l_total_rows		integer		:= 0;
l_old_fte		number(22,2)	:= 0;
l_new_fte_temp	VARCHAR2(150);	-- new added for Bug 2023920
l_old_fte_temp	VARCHAR2(150);	-- new added for Bug 2023920

begin
hr_utility.trace('	Entering CREATE_SLINE_FTE_CHANGE');
-- l_fte_option_value	:= FND_PROFILE.VALue('PSP_FTE_OPTIONS');
 l_fte_option_value :=psp_general.get_specific_profile('PSP_FTE_OPTIONS');
 if NVL(l_fte_option_value,' ') = 'BUDGET_VALUES' or l_fte_option_value IS NULL then
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	return;
 end if;
 ----dbms_output.PUT_LINE('Crossed First if of FTE Change... '|| l_fte_option_value );
-- l_fte_value	:= FND_PROFILE.VALUE('PSP_FTE_ATTRIBUTE');
	l_fte_value:=psp_general.get_specific_profile('PSP_FTE_ATTRIBUTE');
 if l_fte_value IS NULL then
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	return;
 end if;
 ----dbms_output.PUT_LINE('Crossed Second if of FTE Change...' || l_fte_value);
 l_cur_handle := dbms_sql.open_cursor;

 --Added assignment_type ='E' check for bug 2624259.
 dbms_sql.parse(l_cur_handle,'SELECT ' || l_fte_value || ' FROM per_assignments_f WHERE assignment_id = ' ||
		to_char(x_assignment_id) || ' and effective_start_date = (select max(effective_start_date)' ||
		' from per_assignments_f where assignment_id = ' || to_char(x_assignment_id)		||
		' AND assignment_type = '||''''||'E'||''''						||
		' and effective_start_date < (select min(effective_start_date) from	per_assignments_f '	||
		' where assignment_id = ' || to_char(x_assignment_id)					||
		' AND assignment_type = '||''''||'E'||''''						||
		' and (( :g_start_date '									||
		' between effective_start_date and effective_end_date) or ( :g_end_date between '	||
		' effective_start_date and effective_end_date) or ( :g_start_date <= effective_start_date' ||
		' and :g_end_date >= effective_end_date )) ))',dbms_sql.V7);

 dbms_sql.bind_variable(l_cur_handle,'g_start_date', g_start_date);
 dbms_sql.bind_variable(l_cur_handle,'g_end_date', g_end_date);
	dbms_sql.define_column(l_cur_handle,1,l_old_fte_temp,150);
-- above added for bug fix 2023920
--
 l_total_rows := dbms_sql.execute_and_fetch(l_cur_handle);
 ----dbms_output.PUT_LINE('Crossed First dbms_sql.execute of FTE Change...');

/*
 if NVL(l_total_rows,0)	= 0 then
	l_old_fte	:= 0;
 else
	dbms_sql.column_value(l_cur_handle,1,l_old_fte);
 end if;
 Commenting out NOCOPY per bug fix 2023920

*/
	dbms_sql.column_value(l_cur_handle,1,l_old_fte_temp); -- added new for bug fix 2022500
	l_old_fte:= to_number(nvl(l_old_fte_temp,0));	-- 2023920

	l_old_fte:=nvl(l_old_fte_temp,0); -- 2023920

 dbms_sql.close_cursor(l_cur_handle);



--

 l_cur_handle := dbms_sql.open_cursor;

	--Added assignment_type ='E' for bug 2624259.
 dbms_sql.parse(l_cur_handle,'SELECT effective_start_date, effective_end_date, ' || l_fte_value	||
		' FROM	per_assignments_f WHERE assignment_id = ' || to_char(x_assignment_id)	||
		' AND assignment_type = '||''''||'E'||''''						||
		' and (:g_start_date between effective_start_date and effective_end_date or '	||
			':g_end_date between effective_start_date and effective_end_date or (:g_start_date '	||
		' <= effective_start_date and :g_end_date >= effective_end_date )) order by '		||
		' effective_start_date ',dbms_sql.V7);

 dbms_sql.bind_variable(l_cur_handle,'g_start_date', g_start_date);
 dbms_sql.bind_variable(l_cur_handle,'g_end_date', g_end_date);
--
/* new added to define columns for above cursor 2023920*/

 dbms_sql.define_column(l_cur_handle, 1, l_current_Start_date);
 dbms_sql.define_column(l_cur_handle, 2, l_current_end_date);
 dbms_sql.define_column(l_cur_handle, 3, l_new_fte_temp,150);

 l_total_rows := dbms_sql.execute(l_cur_handle);
/*

 Not Required -- Commented out NOCOPY per bug fix 2023920


 ----dbms_output.PUT_LINE('Crossed First dbms_sql.execute of FTE Change...');

 if NVL(l_total_rows,0)	= 0 then
	l_old_fte	:= 0;
 else
	dbms_sql.column_value(l_cur_handle,1,l_old_fte);
 end if;

 dbms_sql.close_cursor(l_cur_handle);
*/
--
 while dbms_sql.fetch_rows(l_cur_handle) > 0
 LOOP
	----dbms_output.PUT_LINE('Entered into fetch LOOP of FTE Change...');
	dbms_sql.column_value(l_cur_handle,1,l_current_start_date);
	dbms_sql.column_value(l_cur_handle,2,l_current_end_date);
	dbms_sql.column_value(l_cur_handle,3,l_new_fte_temp); -- new added 2023920
	l_new_fte:=to_number(nvl(l_new_fte_temp,0)); -- 2023920
/*
	if NVL(l_old_fte,0) = 0 o
 commented out NOCOPY as part of bug fix 2023920

*/


 if NVL(l_old_fte,0) = NVL(l_new_fte,0) then
	l_old_fte	:= l_new_fte;
	else
	begin
	open get_sublines_csr;
	LOOP
	fetch get_sublines_csr into g_sublines_rec;
	EXIT WHEN get_sublines_csr%NOTFOUND;

	if ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
		UPDATE psp_payroll_sub_lines
		set fte = l_new_fte
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_start_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
		end loop;

		if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

		SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
				FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2kdfd');
		PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> g_sublines_rec.sub_line_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_old_fte,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

			SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2LKJL:JL');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_new_fte,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
			l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');
			DELETE psp_payroll_sub_lines
			WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date)) then
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_end_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount, g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

		SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2UUUUUUAA');
		PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_new_fte,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

			SELECT PSP_PAYROLL_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2KKKKK');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_old_fte,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
			l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


			DELETE psp_payroll_sub_lines
			WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
		else
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_start_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

		SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2OOOPP888');
		PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_old_fte,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
			l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(l_current_end_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

			SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -27777MMMN');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_new_fte,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
			l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

			SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2EEEERRSS');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_old_fte,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
			l_rowid	:=	NULL;
			PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


			DELETE psp_payroll_sub_lines
			WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	end if;
	l_old_fte	:= l_new_fte;
	END LOOP;
	close get_sublines_csr;
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	EXCEPTION
	WHEN OTHERS then
		fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_FTE_CHANGE');
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		close get_sublines_csr;
	end;
	end if;

	END LOOP;
	dbms_sql.close_cursor(l_cur_handle);
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	hr_utility.trace('	Leaving CREATE_SLINE_FTE_CHANGE');
	EXCEPTION
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_FTE_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	dbms_sql.close_cursor(l_cur_handle);

end create_sline_fte_change;

--------------------------------CREATE_SLINE_BUDGET_CHANGE--------------
---
PROCEDURE CREATE_SLINE_BUDGET_CHANGE(X_PAYROLL_LINE_ID IN NUMBER,
					X_ASSIGNMENT_ID	IN NUMBER,
					X_BALANCE_AMOUNT IN NUMBER,
					X_RETURN_STATUS OUT NOCOPY VARCHAR2) IS
CURSOR get_old_budget_csr IS
SELECT effective_start_date, value
-- FROM	per_assignment_budget_values Comented for bug 4055483
FROM	per_assignment_budget_values_f
WHERE assignment_id = x_assignment_id and unit = 'FTE' and
	effective_start_date =
		(select max(effective_start_date) -- from per_assignment_budget_values Commented for bug 4055483
		from per_assignment_budget_values_f
		where assignment_id = x_assignment_id and	unit = 'FTE' and
		effective_start_date < (select min(effective_start_date)
					--from	per_assignment_budget_values Commented for bug 4055483
						from	per_assignment_budget_values_f
						where assignment_id = x_assignment_id and
						unit = 'FTE' and
						((g_start_date between effective_start_date and effective_end_date) or
						(g_end_date	between effective_start_date and effective_end_date) or
					(g_start_date <= effective_start_date and g_end_date >= effective_end_date )) ));

l_effective_start_date		date;
--l_old_value		number(9); Commented for Bug 4055483
l_old_value		per_assignment_budget_values_f.value%type;

CURSOR get_assg_csr IS
SELECT effective_start_date, effective_end_date, value
-- FROM	per_assignment_budget_values Commented for Bug 4055483
FROM	per_assignment_budget_values_f
WHERE assignment_id = x_assignment_id and unit = 'FTE' and
	(g_start_date between effective_start_date and effective_end_date or
	g_end_date	between effective_start_date and effective_end_date or
	(g_start_date <= effective_start_date and g_end_date >= effective_end_date ))
order by effective_start_date;

l_current_start_date	date;
l_current_end_date	date;
--l_new_value		number(9);Commented for Bug 4055483
l_new_value		per_assignment_budget_values_f.value%type;

CURSOR get_sublines_csr IS
SELECT *
FROM	psp_payroll_sub_lines
WHERE payroll_line_id	= x_payroll_line_id and
	((sub_line_start_date between l_current_start_date and l_current_end_date) or
	(sub_line_end_date	between l_current_start_date and l_current_end_date) or
	(sub_line_start_date >= l_current_start_date and sub_line_end_date >= l_current_end_date))
order by sub_line_start_date;

g_sublines_rec get_sublines_csr%ROWTYPE;

l_tmp_start_date	date;
l_tmp_end_date		date;
l_rowid			varchar2(20);
l_sub_line_id		number(9);
i		number(9)	:= 0;
i2		number(9)	:= 0;
l_amount	number(22,2)	:= 0;
l_no_of_days	number(3)	:= 0;
l_fte_option_value varchar2(30);


begin
 -- l_fte_option_value	:= FND_PROFILE.value('PSP_FTE_OPTIONS');
 --	l_fte_option_value:= psp_general.get_specific_profile('PSP_FTE_OPTIONS'); Commented for bug 4055483
 /*
 Commented for Bug 4055483
 if l_fte_option_value IS NULL or l_fte_option_value <> 'BUDGET_VALUES' then
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	return;
 end if;
 */

 hr_utility.trace('	Entering CREATE_SLINE_BUDGET_CHANGE');
 open get_old_budget_csr;
 fetch get_old_budget_csr into l_effective_start_date, l_old_value;
 if get_old_budget_csr%NOTFOUND then
	l_old_value	:= 0;
 end if;

 open get_assg_csr;
 LOOP
	fetch get_assg_csr into l_current_start_date, l_current_end_date, l_new_value;
	EXIT WHEN get_assg_csr%NOTFOUND;
	if NVL(l_old_value,0) = 0 or NVL(l_old_value,0) = NVL(l_new_value,0) then
	l_old_value	:= l_new_value;
	else
	begin
	open get_sublines_csr;
	LOOP
	fetch get_sublines_csr into g_sublines_rec;
	EXIT WHEN get_sublines_csr%NOTFOUND;
	if ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
		UPDATE psp_payroll_sub_lines
			set fte = l_new_value
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	= g_sublines_rec.sub_line_end_date) or
		(l_current_start_date > g_sublines_rec.sub_line_start_date and
		l_current_end_date	> g_sublines_rec.sub_line_end_date)) then
		begin
			l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
			l_tmp_end_date	:= trunc(l_current_start_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2WWWEEERR');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> g_sublines_rec.sub_line_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_old_value,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -29999*****888');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_new_value,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	elsif ((l_current_start_date = g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date) or
		(l_current_start_date < g_sublines_rec.sub_line_start_date and
		l_current_end_date	< g_sublines_rec.sub_line_end_date)) then
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_end_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount, g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2DDDDDD');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_new_value,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2UKOSO');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_old_value,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R' );


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	else
		begin
		l_tmp_start_date	:= trunc(g_sublines_rec.sub_line_start_date);
		l_tmp_end_date	:= trunc(l_current_start_date) - 1;
		i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
		i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
		l_no_of_days	:= 0;
		l_amount	:= 0.00;
		while i <= i2 loop
		l_amount	:= l_amount + daily_calendar(i);
		if work_calendar(i)	= 'Y' then
			l_no_of_days	:= l_no_of_days + 1;
		end if;
		i	:= i + 1;
		end loop;

		if round(x_balance_amount,g_precision) <> 0.00 then
		l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
		end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2JYUPA');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_old_value,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_start_date);
			l_tmp_end_date	:= trunc(l_current_end_date) - 1;
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount, g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2NBMM');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_new_value,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');

			l_tmp_start_date	:= trunc(l_current_end_date);
			l_tmp_end_date	:= trunc(g_sublines_rec.sub_line_end_date);
			i	:= (trunc(l_tmp_start_date) - trunc(g_start_date)) + 1;
			i2	:= (trunc(l_tmp_end_date)	- trunc(g_start_date)) + 1;
			l_no_of_days	:= 0;
			l_amount	:= 0.00;
			while i <= i2 loop
			l_amount	:= l_amount + daily_calendar(i);
			if work_calendar(i)	= 'Y' then
				l_no_of_days	:= l_no_of_days + 1;
			end if;
			i	:= i + 1;
			end loop;

			if round(x_balance_amount,g_precision) <> 0.00 then
			l_amount	:= l_amount + round((x_balance_amount * (l_no_of_days / g_no_of_person_work_days)), g_precision);
			end if;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id
			FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2TOPP');
			PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> l_tmp_start_date,
			X_SUB_LINE_END_DATE		=> l_tmp_end_date,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PAY_AMOUNT			=> l_amount,
			X_DAILY_RATE			=> g_sublines_rec.daily_rate,
			X_SALARY_USED			=> g_sublines_rec.salary_used,
			X_CURRENT_SALARY		=> g_sublines_rec.current_salary,
			X_FTE				=> l_old_value,
			X_ORGANIZATION_ID		=> g_sublines_rec.organization_id,
			X_JOB_ID			=> g_sublines_rec.job_id,
			X_POSITION_ID			=> g_sublines_rec.position_id,
			X_GRADE_ID			=> g_sublines_rec.grade_id,
			X_PEOPLE_GRP_ID		=> g_sublines_rec.people_group_id,
			X_EMPLOYMENT_BEGIN_DATE		=> g_sublines_rec.employment_begin_date,
			X_EMPLOYMENT_END_DATE		=> g_sublines_rec.employment_end_date,
			X_EMPLOYEE_STATUS_INACTIVE_DAT	=> g_sublines_rec.employee_status_inactive_date,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> g_sublines_rec.employee_status_active_date,
			X_ASSIGNMENT_BEGIN_DATE		=> g_sublines_rec.assignment_begin_date,
			X_ASSIGNMENT_END_DATE		=> g_sublines_rec.assignment_end_date,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE				=> 'R');
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID				=> l_rowid,
			X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
			X_REASON_CODE			=> 'FTE_CHANGE',
			X_PARENT_LINE_ID		=> g_sublines_rec.payroll_sub_line_id,
			X_MODE				=> 'R');


		DELETE psp_payroll_sub_lines
		WHERE payroll_sub_line_id = g_sublines_rec.payroll_sub_line_id;
		end;
	end if;
	l_old_value		:= l_new_value;
	END LOOP;
	close get_sublines_csr;
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	EXCEPTION
	WHEN NO_DATA_FOUND then
		x_return_status	:= FND_API.G_RET_STS_SUCCESS;
		close get_sublines_csr;
	WHEN OTHERS then
		fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_BUDGET_CHANGE');
		x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
		close get_sublines_csr;
	end;
	end if;
 END LOOP;
 close get_assg_csr;
 x_return_status	:= FND_API.G_RET_STS_SUCCESS;
 hr_utility.trace('	Leaving CREATE_SLINE_BUDGET_CHANGE');
 EXCEPTION
	WHEN NO_DATA_FOUND then
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	close get_assg_csr;
	WHEN OTHERS then
	fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_SLINE_BUDGET_CHANGE');
	x_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	close get_assg_csr;

end create_sline_budget_change;


/**********************************************************************************
HISTORY
WHO		WHEN		WHAT
Lveerubh	15-SEP-2001	Added checks to identify Non active assignments
				as part of Bug 1994421-Zero Work Days Build
*************************************************************************************/
PROCEDURE CHECK_ZERO_WORK_DAYS(x_assignment_id IN NUMBER,
				x_costed_value IN NUMBER,
				x_start_date	IN DATE,		-- Bug 5642002: Added parameter
				x_end_date	IN DATE,		-- Bug 5642002: Added parameter
				x_return_status OUT NOCOPY varchar2) IS
l_assignment_number varchar2(30);

--Bug 1994421 : Zero Work Days Build : New select to identify non active assignment :lveerubh
l_count_asg_active		NUMBER(4);
l_effective_start_date	DATE;

CURSOR non_active_asg_csr IS
SELECT	count(*)
FROM	per_assignments_f paf,
	per_assignment_status_types	past
WHERE	assignment_id			=		x_assignment_id
AND	g_start_date			<=		effective_end_date
AND	g_end_date			>=		effective_start_date
AND	past.assignment_status_type_id =		paf.assignment_status_type_id
AND	past.per_system_status	NOT IN	('ACTIVE_ASSIGN');

CURSOR hire_zero_days_csr IS
SELECT	min(paf.effective_start_date)
FROM	per_assignments_f	paf
WHERE	paf.assignment_id	=	x_assignment_id
AND	assignment_type	=	'E'	--Added for bug 2624259.
AND	g_start_date		<=	paf.effective_end_date
AND	g_end_date		>=	paf.effective_start_date
AND	payroll_id = l_payroll_id; ---3922347

BEGIN

	hr_utility.trace('	Entering CHECK_ZERO_WORK_DAYS');
	hr_utility.trace('	 zero work days check asg, g_no_of_person_workdays= '||x_assignment_id||','||g_no_of_person_work_days);
	IF g_no_of_person_work_days <= 0 then

/* The following code is added for the enhancement Zero Work days .This code addition will identify the
	non active assignments and assignments which have started on the last day of payroll , which is a non working day
 : Done as part of Bug 1994421 - Zero Work Days Build -lveerubh */

	OPEN	non_active_asg_csr;
	FETCH	non_active_asg_csr	INTO	l_count_asg_active;
	CLOSE	non_active_asg_csr;

	IF	l_count_asg_active > 0 THEN
		hr_utility.trace('	 assignment_id l_count_asg_active > 0 asg = '||x_assignment_id);
		g_non_active_flag :=	'Y';
		x_return_status:=FND_API.G_RET_STS_SUCCESS;
		return;
	END IF;

	OPEN	hire_zero_days_csr;
	FETCH	hire_zero_days_csr	INTO	l_effective_start_date;
	CLOSE	hire_zero_days_csr;

	/*Bug 5557724: to_char(some_date,'D') returns a number indicating the weekday. However, for a given date, this number
	returned varies with NLS_TERRITORY. So replaced it with to_char(some_date,'DY') that gives the abbreviated day. */
--	IF	to_char(l_effective_start_date,'DY', 'nls_date_language=english') IN ('SUN','SAT') THEN
	IF (psp_general.business_days(l_effective_start_date, l_effective_start_date, x_assignment_id) = 0) THEN
		hr_utility.trace('	 assignment starts in non working day = '||x_assignment_id);
		g_hire_zero_work_days	:=	'Y';
		x_return_status:=FND_API.G_RET_STS_SUCCESS;
		return;
	END IF;
-- End of the changes -lveerubh

/*Bug 5642002: Added element only on Sat Sun condition*/
	IF trunc(x_end_date) - trunc(x_start_date) <= 1 AND psp_general.business_days(trunc(x_start_date), trunc(x_end_date)) <= 0 THEN
		g_all_holiday_zero_work_days := 'Y';
		x_return_status:=FND_API.G_RET_STS_SUCCESS;
		return;
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	x_return_status:=FND_API.G_RET_STS_SUCCESS;

	hr_utility.trace('	Leaving CHECK_ZERO_WORK_DAYS');

	EXCEPTION
	WHEN OTHERS then
	------dbms_output.put_line('Check_zero_work_days.....'||x_assignment_id||' '||x_costed_value);
		select assignment_number into l_assignment_number from per_assignments_f where assignment_id =x_assignment_id
		and effective_start_date=(select max(effective_start_date) from per_assignments_f where
		assignment_id=x_assignment_id);
		fnd_message.set_name('PSP','PSP_ZERO_WORK_DAYS');
		fnd_message.set_token('ASSIGNMENT_NO',l_assignment_number);
		fnd_message.set_token('LINE_AMT',x_costed_value );
		fnd_msg_pub.add;

	--	fnd_msg_pub.add_exc_msg('PSP-PAYTRN','CHECK_ZERO_WORK_DAYS','Assg_ID '||x_assignment_id||' Amt '||x_costed_value);
	x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

	END check_zero_work_days;

/***************************************************************************************************
Created By	:	lveerubh

Date Created By :	15-SEP-2001

Purpose	:	Bug 1994421 -Zero Work Days Build

Know limitations, enhancements or remarks

Change History

Who			When		What
lveerubh		15-SEP-2001	Creating the procedure
					This procedure inserts a single line
					into psp_payroll_lines and psp_payroll_sub_lines
					with sub line start date and sub line end date
					as date earned
amakrish		01-Apr-2008     Changed the sub line start date and sub line end date
					to be least of date earned or payroll period end date
					for bug 6886237

***************************************************************************************************/
PROCEDURE	CREATE_SLINE_TERM_EMP ( x_payroll_line_id	IN	NUMBER,
					x_reason		IN	VARCHAR2,
					x_return_status	OUT NOCOPY	VARCHAR2)
IS
l_sub_line_id	NUMBER(10);
l_rowid	VARCHAR2(20);

CURSOR get_payroll_line_csr
IS
SELECT *
FROM	psp_payroll_lines ppl
WHERE	ppl.payroll_line_id	=	x_payroll_line_id;

g_payroll_line_rec	get_payroll_line_csr%ROWTYPE;
l_tp_end_date           per_time_periods.end_date%TYPE;  -- BUG 6886237
BEGIN

	hr_utility.trace('	Entering CREATE_SLINE_TERM_EMP');
	OPEN	get_payroll_line_csr;
	FETCH	get_payroll_line_csr INTO	g_payroll_line_rec;
	CLOSE	get_payroll_line_csr;

	/*Bug 6886237*/
	SELECT end_date
	INTO l_tp_end_date
	FROM per_time_periods
	WHERE time_period_id = (select time_period_id from psp_payroll_controls
	                        where payroll_control_id = (select payroll_control_id from
	                                                    psp_payroll_lines
	                                                    where payroll_line_id = x_payroll_line_id));

-- Inserting into PSP_SUB_LINES
	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id FROM DUAL;
 hr_utility.trace('	inserting into Sublines -2UISISI');
	PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
			X_ROWID			=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_PAYROLL_LINE_ID		=> x_payroll_line_id,
			X_SUB_LINE_START_DATE		=> least(trunc(g_payroll_line_rec.effective_Date), trunc(l_tp_end_date)),  /*Bug 6886237*/
			X_SUB_LINE_END_DATE		=> least(trunc(g_payroll_line_rec.effective_Date), trunc(l_tp_end_date)),  /*Bug 6886237*/
			X_REASON_CODE			=> x_reason,
			X_PAY_AMOUNT			=> g_payroll_line_rec.pay_amount,
			X_DAILY_RATE			=> g_payroll_line_rec.pay_amount,
			X_SALARY_USED			=> g_payroll_line_rec.pay_amount,
			X_CURRENT_SALARY		=> NULL,
			X_FTE				=> NULL,
			X_ORGANIZATION_ID		=> NULL,
			X_JOB_ID			=> NULL,
			X_POSITION_ID			=> NULL,
			X_GRADE_ID			=> NULL,
			X_PEOPLE_GRP_ID		=> NULL,
			X_EMPLOYMENT_BEGIN_DATE	=> NULL,
			X_EMPLOYMENT_END_DATE		=> NULL,
			X_EMPLOYEE_STATUS_INACTIVE_DAT => NULL,
			X_EMPLOYEE_STATUS_ACTIVE_DATE	=> NULL,
			X_ASSIGNMENT_BEGIN_DATE	=> NULL,
			X_ASSIGNMENT_END_DATE		=> NULL,
			x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
			x_attribute1			=> NULL,
			x_attribute2			=> NULL,
			x_attribute3			=> NULL,
			x_attribute4			=> NULL,
			x_attribute5			=> NULL,
			x_attribute6			=> NULL,
			x_attribute7			=> NULL,
			x_attribute8			=> NULL,
			x_attribute9			=> NULL,
			x_attribute10			=> NULL,
			X_MODE			=> 'R' );

--Inserting into PSP_SUB_LINES_REASONS
		l_rowid	:=	NULL;
		PSP_SUB_LINE_REASONS_PKG.INSERT_ROW (
			X_ROWID			=> l_rowid,
			X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
			X_REASON_CODE			=> x_reason,
			X_PARENT_LINE_ID		=> l_sub_line_id,
			X_MODE			=> 'R');
		x_return_status := FND_API.G_RET_STS_SUCCESS;

		hr_utility.trace('	Leaving CREATE_SLINE_TERM_EMP');

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	FND_MSG_PUB.ADD_EXC_MSG('PSP_PAYTRN','CREATE_SLINE_TERM_EMP');
	x_return_status	:=	FND_API.G_RET_STS_UNEXP_ERROR;
 WHEN OTHERS THEN
	FND_MSG_PUB.ADD_EXC_MSG('PSP_PAYTRN','CREATE_SLINE_TERM_EMP');
	x_return_status	:=	FND_API.G_RET_STS_UNEXP_ERROR;

END create_sline_term_emp;
--======================= End of procedure =================

--	Introduced the following procedure for bug fix 2916848
--	Procedure:	CREATE_PRORATE_CALENDAR
--	Purpose:	When User selects Payroll Proration preference for Import Payroll process
--			This procedure is called instead of the default create_prorate_calendar procedure.
--			Payroll proration instead of LD prorating based on salary basis.

PROCEDURE create_prorate_calendar	(p_start_date		IN	DATE,
					p_end_date		IN	DATE,
					p_pay_amount		IN	NUMBER,
					p_payroll_line_id	IN	NUMBER,
					p_balance_amount	OUT NOCOPY NUMBER,
					p_return_status		OUT NOCOPY VARCHAR2) IS
l_daily_rate		NUMBER;
l_daily_balance		NUMBER;
l_final_daily_rate	NUMBER;
l_total_salary		NUMBER;
l_final_salary		NUMBER;
l_balance_amount	NUMBER;
l_start_date		DATE;
l_end_date		DATE;
i			NUMBER;
j			NUMBER;
l_non_working_day_flag	NUMBER;
l_business_days		NUMBER;
l_sub_line_id		NUMBER;
l_payroll_line_id	NUMBER;
l_rowid			VARCHAR2(20);
l_element_name		pay_element_types_f.element_name%TYPE;
l_temp_start_date	DATE;
l_temp_end_date		DATE;

BEGIN
	hr_utility.trace('	Entering Create Prorate Calendar st_dt, end_dt, pay_amnt, payroll_line_id, balnce_amt ='||
	p_start_date ||','|| p_end_date||','|| p_pay_amount||','|| p_payroll_line_id ||','|| p_balance_amount);
	hr_utility.trace('	g_st_dt, g_end_dt =' ||g_start_date ||','|| g_end_date);
	l_non_working_day_flag := 0;
	l_start_date := p_start_date;
	l_end_date := p_end_date;

	IF (((TRUNC(g_end_date) - TRUNC(l_end_date))) < 0) THEN
		l_end_date := g_end_date;
	END IF;

	i := (TRUNC(l_start_date) - TRUNC(g_start_date)) + 1;
	IF (i < 1) THEN
		i := 1;
		l_start_date := g_start_date;
	END IF;
	hr_utility.trace('	l_st_dt, l_end_dt =' ||l_start_date ||','|| l_end_date);
	l_business_days := psp_general.business_days(l_start_date, l_end_date);
	hr_utility.trace('	l_business_days , g_no_of_days='|| l_business_days||','||g_no_of_days);

	IF (l_business_days = 0) THEN
		l_non_working_day_flag := 1;
		l_business_days := 1;
	END IF;

	j := i;

	WHILE (j <= g_no_of_days)
	LOOP
		hr_utility.trace('	 daily rate 0.0 for j=' ||j);
		daily_calendar(j) := 0.00;
		j := j + 1;
	END LOOP;

	l_daily_rate	:= 0.00;
	IF (NVL(p_pay_amount, 0) <> 0.00) THEN
		l_daily_rate := p_pay_amount;
		hr_utility.trace('	 p_pay_amount, l_daily_rate=' ||l_daily_rate);
		IF (l_non_working_day_flag = 0) THEN
			l_daily_rate := ROUND((p_pay_amount / l_business_days), g_ext_precision);
			hr_utility.trace('	 l_non_working_day_flag = 0 , l_daily_rate=' ||l_daily_rate);
		END IF;
	END IF;

	l_total_salary := 0.00;

	l_temp_start_date:=l_start_date;
	l_temp_end_date:=l_end_date;

	WHILE TRUNC(l_temp_start_date) <= TRUNC(l_temp_end_date)
	LOOP
		daily_calendar(i) := 0.00;
		IF (work_calendar(i) = 'Y') THEN
			daily_calendar(i) := l_daily_rate;
			IF (l_non_working_day_flag = 1) THEN
				work_calendar(i) := 'N';
				daily_calendar(i) := 0.00;
			END IF;
		END IF;
		l_temp_start_date := TRUNC(l_temp_start_date) + 1;
		l_total_salary := l_total_salary + daily_calendar(i);
		i := i + 1;

	END LOOP;

	-- zero work days, (no business days between stdate and enddate)..bug 4670588
	if l_non_working_day_flag = 1 then -- (means no work days and hence all daily
					-- rates in array are zero)
		l_total_Salary	:= p_pay_amount;
		l_end_date := l_start_date;
	end if;

	l_final_daily_rate := l_daily_rate;
	hr_utility.trace('	l_total__salary = '||l_total_salary);
	l_final_salary := ROUND(l_total_salary, g_precision);
	hr_utility.trace('	l_final_salary = '||l_final_salary);
	l_balance_amount :=0.0;


	IF l_final_salary <> ROUND(p_pay_amount, g_precision) THEN
		l_balance_amount := p_pay_amount - l_final_salary;
		hr_utility.trace('	l_balance_amount = '||l_balance_amount);
		l_daily_balance := ROUND((l_balance_amount / l_business_days), g_ext_precision);
		hr_utility.trace('	l_daily_balance = '||l_daily_balance);
		l_final_daily_rate := l_final_daily_rate + l_daily_balance;
		hr_utility.trace('	l_finally_daily_rate 2= '||l_final_daily_rate);
		l_final_salary := round((l_total_salary + l_balance_amount), g_precision);
		hr_utility.trace('	l_finally_salary 2= '||l_final_salary);
	END IF;

	SELECT PSP_PAYROLL_SUB_LINES_S.NEXTVAL into l_sub_line_id FROM DUAL;

 hr_utility.trace('	inserting into Sublines -2LLLLLLLALALAL');
	PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW
		(X_ROWID			=> l_rowid,
		X_PAYROLL_SUB_LINE_ID		=> l_sub_line_id,
		X_PAYROLL_LINE_ID		=> p_payroll_line_id,
		X_SUB_LINE_START_DATE		=> l_start_date,
		X_SUB_LINE_END_DATE		=> l_end_date,
		X_REASON_CODE			=> 'SALARY_CHANGE',
		X_PAY_AMOUNT			=> l_final_salary,
		X_DAILY_RATE			=> l_final_daily_rate,
		X_SALARY_USED			=> l_final_salary,
		X_CURRENT_SALARY		=> l_final_salary,
		X_FTE				=> NULL,
		X_ORGANIZATION_ID		=> NULL,
		X_JOB_ID			=> NULL,
		X_POSITION_ID			=> NULL,
		X_GRADE_ID			=> NULL,
		X_PEOPLE_GRP_ID			=> NULL,
		X_EMPLOYMENT_BEGIN_DATE		=> NULL,
		X_EMPLOYMENT_END_DATE		=> NULL,
		X_EMPLOYEE_STATUS_INACTIVE_DAT	=> NULL,
		X_EMPLOYEE_STATUS_ACTIVE_DATE	=> NULL,
		X_ASSIGNMENT_BEGIN_DATE		=> NULL,
		X_ASSIGNMENT_END_DATE		=> NULL,
		x_attribute_category		=> NULL,		-- Introduced DFF parameters for bug fix 2908859
		x_attribute1			=> NULL,
		x_attribute2			=> NULL,
		x_attribute3			=> NULL,
		x_attribute4			=> NULL,
		x_attribute5			=> NULL,
		x_attribute6			=> NULL,
		x_attribute7			=> NULL,
		x_attribute8			=> NULL,
		x_attribute9			=> NULL,
		x_attribute10			=> NULL,
		X_MODE				=> 'R' );

	l_rowid := NULL;

	PSP_SUB_LINE_REASONS_PKG.INSERT_ROW
		(X_ROWID		=> l_rowid,
		X_PAYROLL_SUB_LINE_ID	=> l_sub_line_id,
		X_REASON_CODE		=> 'SALARY_CHANGE',
		X_PARENT_LINE_ID	=> l_sub_line_id,
		X_MODE			=> 'R');

	p_balance_amount :=l_balance_amount;
	p_return_status	:= FND_API.G_RET_STS_SUCCESS;
 hr_utility.trace('	Leaving CREATE PRORATE CALENDAR');
EXCEPTION
	WHEN fnd_api.g_exc_unexpected_error THEN
		fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_PRORATE_CALENDAR');
		p_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg('PSP_PAYTRN','CREATE_PRORATE_CALENDAR');
		p_return_status	:= FND_API.G_RET_STS_UNEXP_ERROR;
END create_prorate_calendar;

END PSP_PAYTRN; -- End of Package Body

/
