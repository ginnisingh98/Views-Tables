--------------------------------------------------------
--  DDL for Package Body PSP_ENC_PRE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ENC_PRE_PROCESS" AS
/* $Header: PSPENPPB.pls 120.4 2008/04/16 13:38:53 amakrish noship $ */

PROCEDURE update_global_earning_elements
				(p_pre_process_mode		IN	VARCHAR2,
				p_payroll_id			IN	NUMBER,
				p_business_group_id		IN	NUMBER,
				p_set_of_books_id		IN	NUMBER,
				p_max_pay_date			IN	DATE,
				p_return_status			OUT NOCOPY	VARCHAR2);

PROCEDURE update_schedules	(p_pre_process_mode		IN	VARCHAR2,
				p_payroll_id			IN	NUMBER,
				p_business_group_id		IN	NUMBER,
				p_set_of_books_id		IN	NUMBER,
				p_max_pay_date			IN	DATE,
				p_return_status			OUT NOCOPY	VARCHAR2);

PROCEDURE update_default_susp_accounts
				(p_pre_process_mode		IN	VARCHAR2,
				p_payroll_id			IN	NUMBER,
				p_business_group_id		IN	NUMBER,
				p_set_of_books_id		IN	NUMBER,
				p_max_pay_date			IN	DATE,
				p_return_status			OUT NOCOPY	VARCHAR2);


PROCEDURE update_default_labor_schedules
				(p_pre_process_mode		IN	VARCHAR2,
				p_payroll_id			IN	NUMBER,
				p_business_group_id		IN	NUMBER,
				p_set_of_books_id		IN	NUMBER,
				p_max_pay_date			IN	DATE,
				p_return_status			OUT NOCOPY	VARCHAR2);

/*****	Commented as part of bug fix 33957169
PROCEDURE validate_poeta	(p_project_id			IN	NUMBER,
				p_task_id			IN	NUMBER,
				p_award_id			IN	NUMBER,
				p_expenditure_type		IN	VARCHAR2,
				p_expenditure_organization_id	IN	NUMBER,
				p_payroll_id			IN	NUMBER,
				p_start_date			OUT NOCOPY	DATE,
				p_end_date			OUT NOCOPY	DATE,
				p_return_status			OUT NOCOPY	VARCHAR2);
	End of comment for bug fix 3957169	*****/

PROCEDURE insert_changed_assignments
				(p_change_type			IN	VARCHAR2,
				p_reference_id			IN	NUMBER		DEFAULT NULL,
				p_action_type			IN	VARCHAR2	DEFAULT NULL,
				p_return_status			OUT NOCOPY	VARCHAR2);

PROCEDURE validate_transaction_controls
				(p_project_id			IN	NUMBER,
				p_payroll_id			IN	NUMBER,
				p_return_status			OUT NOCOPY	VARCHAR2);

/*	Global Variables	*/
TYPE v_line_id		IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE v_project_id	IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE v_task_id		IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE v_exp_org		IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE v_exp_type		IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE v_award_id		IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE v_start_dt		IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE v_end_dt		IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE v_payroll_id	IS TABLE OF NUMBER(9) INDEX BY BINARY_INTEGER;
TYPE v_assignment_id	IS TABLE OF NUMBER(10) INDEX BY BINARY_INTEGER;

g_request_id		NUMBER DEFAULT fnd_global.conc_request_id;
g_error_api_path	VARCHAR2(230);

g_total_num_rec		NUMBER DEFAULT 0;

g_final_start_date	DATE;
g_final_end_date	DATE;

g_package_name		VARCHAR2(31)	DEFAULT 'PSP_ENC_PRE_PROCESS.';

TYPE asg_id_array is RECORD	(r_asg_id			v_assignment_id,
				r_payroll_id			v_payroll_id);

r_asg_id_array asg_id_array;

PROCEDURE poeta_pre_process	(p_pre_process_mode	IN	VARCHAR2,
				p_payroll_id		IN	NUMBER,
				p_business_group_id	IN	NUMBER,
				p_set_of_books_id	IN	NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_operating_unit	VARCHAR2(30);
l_pa_gms_install_option	VARCHAR2(30);
l_max_pay_date		DATE;

l_business_group_id	NUMBER(15);
l_set_of_books_id	NUMBER(15);

--	Introduced the following for bug fix 3434626
l_proc_name		VARCHAR2(61)	DEFAULT g_package_name || 'POETA_PRE_PROCESS';
l_proc_step		NUMBER(20, 10)	DEFAULT 0;
--	End of changes for bug fix 3434626

/*	Cursor for selecting maximum payroll date of the payroll */
CURSOR	payroll_date_cur IS
SELECT	max(date_earned) from pay_payroll_actions
WHERE	payroll_id = p_payroll_id
AND	action_type = 'R'
AND	action_status = 'C';

/*	This cursor is declared to pass a minimum of time period date,
	if no payroll is processed for that payroll */
CURSOR	min_start_dt_cur IS
SELECT	min(start_date)
FROM	per_time_periods
WHERE	payroll_id = p_payroll_id;

BEGIN
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Entering ' || l_proc_name);
	hr_utility.trace('p_pre_process_mode: ' || p_pre_process_mode ||
		' p_payroll_id: ' || fnd_number.number_to_canonical(p_payroll_id) ||
		' p_business_group_id: ' || fnd_number.number_to_canonical(p_business_group_id) ||
		' p_set_of_books_id: ' || fnd_number.number_to_canonical(p_set_of_books_id));

	l_proc_step := 10;
--	End of Changes for bug fix 3434626
	/* Validation for GMS install option */
	psp_general.multiorg_client_info	(l_set_of_books_id,
						l_business_group_id,
						l_operating_unit,
						l_pa_gms_install_option);

	IF l_pa_gms_install_option <>'PA_GMS' THEN
		p_return_status := fnd_api.g_ret_sts_success;
		RETURN;
	END IF;

--	Introduced the following for bug fix 3434626
	hr_utility.trace('l_business_group_id: ' || fnd_number.number_to_canonical(l_business_group_id) ||
		' l_set_of_books_id: ' || fnd_number.number_to_canonical(l_set_of_books_id) ||
		' l_operating_unit: ' || fnd_number.number_to_canonical(l_operating_unit) ||
		' l_pa_gms_install_option: ' || l_pa_gms_install_option);

	l_proc_step := 20;
--	End of changes for bug fix 3434626

        -- Code chages for bug 4203036
        -- To delete all the unwanted records in poeta pre-process
        delete from psp_enc_changed_assignments a
        where  exists
	       (select 1 from per_all_assignments_f  b
                where  b.assignment_id = a.assignment_id
                and b.effective_end_date = to_date('31-12-4712','DD-MM-RRRR'))
	 and   a.chk_asg_end_date_flag = 'Y';
	 -- End of code chages  4203036

	OPEN payroll_date_cur;
	FETCH payroll_date_cur into l_max_pay_date;
	IF (l_max_pay_date IS NULL) THEN
		OPEN min_start_dt_cur;
		FETCH min_start_dt_cur into l_max_pay_date;
		CLOSE min_start_dt_cur;
	END IF;
	CLOSE payroll_date_cur;



--	Introduced the following for bug fix 3434626
	hr_utility.trace('l_max_pay_date: ' || fnd_date.date_to_canonical(l_max_pay_date));

	l_proc_step := 30;
--	End of bug fix 3434626

	update_global_earning_elements	(p_pre_process_mode	=>	p_pre_process_mode,
					p_payroll_id		=>	p_payroll_id,
					p_business_group_id	=>	p_business_group_id,
					p_set_of_books_id	=>	p_set_of_books_id,
					p_max_pay_date		=>	l_max_pay_date,
					p_return_status		=>	p_return_status);

	IF p_return_status <> fnd_api.g_ret_sts_success THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_proc_step := 40;	-- Introduced for bug fix 3434626

	update_schedules	(p_pre_process_mode	=>	p_pre_process_mode,
				p_payroll_id		=>	p_payroll_id,
				p_business_group_id	=>	p_business_group_id,
				p_set_of_books_id	=>	p_set_of_books_id,
				p_max_pay_date		=>	l_max_pay_date,
				p_return_status		=>	p_return_status);

	IF p_return_status <> fnd_api.g_ret_sts_success THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_proc_step := 50;	-- Introduced for bug fix 3434626

	update_default_labor_schedules	(p_pre_process_mode	=>	p_pre_process_mode,
					p_payroll_id		=>	p_payroll_id,
					p_business_group_id	=>	p_business_group_id,
					p_set_of_books_id	=>	p_set_of_books_id,
					p_max_pay_date		=>	l_max_pay_date,
					p_return_status		=>	p_return_status);

	IF p_return_status <> fnd_api.g_ret_sts_success THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_proc_step := 60;	-- Introduced for bug fix 3434626

	update_default_susp_accounts	(p_pre_process_mode	=>	p_pre_process_mode,
					p_payroll_id		=>	p_payroll_id,
					p_business_group_id	=>	p_business_group_id,
					p_set_of_books_id	=>	p_set_of_books_id,
					p_max_pay_date		=>	l_max_pay_date,
					p_return_status		=>	p_return_status);

	IF p_return_status <> fnd_api.g_ret_sts_success THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_proc_step := 70;	-- Introduced for bug fix 3434626

	COMMIT;
	p_return_status := fnd_api.g_ret_sts_success;


--	Introduced the following for bug fix 3434626
	hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := SUBSTR(g_error_api_path,1,30);
		fnd_msg_pub.add_exc_msg('PSP_ENC_PRE_PROCESS',g_error_api_path);
                psp_message_s.print_error(p_mode=>FND_FILE.LOG,
                                          p_print_header=>FND_API.G_TRUE);
                -- bug fix 2597666
		p_return_status := fnd_api.g_ret_sts_unexp_error;
--	Introduced the following for bug fix 3434626
		hr_utility.trace(fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		hr_utility.trace('Leaving ' || l_proc_name);
--	End of changed for bug fix 3434626
END poeta_pre_process;

/****************************************************************************************************
	Procedure Name:	UPDATE_GLOBAL_EARNING_ELEMENTS
	Purpose:	This procedure is called in the main procedure and used for updating poeta
			dates in psp_element_type_accounts for poeta CI It inserts assignments in
			psp_enc_changed_assignments if the poeta dates are different from previous
			poeta dates and assignments exists in psp_enc_lines_history table.
****************************************************************************************************/

PROCEDURE update_global_earning_elements	(p_pre_process_mode	IN	VARCHAR2,
						p_payroll_id		IN	NUMBER,
						p_business_group_id	IN	NUMBER,
						p_set_of_books_id	IN	NUMBER,
						p_max_pay_date		IN	DATE,
						p_return_status		OUT NOCOPY	VARCHAR2)
IS

TYPE global_lines_rec is RECORD (
	r_global_line_id		v_line_id,
	r_project_id			v_project_id,
	r_task_id			v_task_id,
	r_expenditure_organization_id	v_exp_org,
	r_expenditure_type		v_exp_type,
	r_award_id			v_award_id,
	r_start_date_active		v_start_dt,
	r_end_date_active		v_end_dt,
	r_poeta_start_date		v_start_dt,
	r_poeta_end_date		v_end_dt);

r_global_control_rec	global_lines_rec;

l_prev_project_id			NUMBER(15)	DEFAULT -1;
l_prev_task_id				NUMBER(15)	DEFAULT -1;
l_prev_award_id				NUMBER(15)	DEFAULT -1;
l_prev_exp_organization_id		NUMBER(15)	DEFAULT -1;
l_prev_expenditure_type			VARCHAR2(30)	DEFAULT '-1';
l_prev_tx_project_id			NUMBER(15)	DEFAULT -1;

--	Introduced for bug fix 3434626
l_proc_name		VARCHAR2(61)	DEFAULT g_package_name || 'UPDATE_GLOBAL_EARNING_ELEMENTS';
l_proc_step		NUMBER(20, 10)	DEFAULT 0;
--	End of changes for bug fix 3434626

CURSOR	element_account_cur IS
SELECT	peta.element_account_id,
	peta.project_id,
	peta.task_id,
	peta.expenditure_organization_id,
	peta.expenditure_type,
	peta.award_id,
	peta.start_date_active,
	peta.end_date_active,
	NVL(peta.poeta_start_date, TO_DATE('01-01-1800', 'DD-MM-YYYY')) poeta_start_date,
	NVL(peta.poeta_end_date,TO_DATE('31-12-4712', 'DD-MM-YYYY')) poeta_end_date
FROM	psp_element_type_accounts peta
WHERE	peta.gl_code_combination_id is NULL
AND	peta.end_date_active >= p_max_pay_date
AND	peta.business_group_id = p_business_group_id
AND	peta.set_of_books_id = p_set_of_books_id
ORDER BY 2,3,4,5,6;

CURSOR	assignment_payroll_cur(j number) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh
WHERE	pelh.element_account_id = r_global_control_rec.r_global_line_id (j)
AND	pelh.suspense_org_account_id is NULL
AND	pelh.change_flag = 'N';

BEGIN
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Entering ' || l_proc_name);
	hr_utility.trace('p_pre_process_mode: ' || p_pre_process_mode ||
		' p_payroll_id: ' || fnd_number.number_to_canonical(p_payroll_id) ||
		' p_business_group_id: ' || fnd_number.number_to_canonical(p_business_group_id) ||
		' p_set_of_books_id: ' || fnd_number.number_to_canonical(p_set_of_books_id) ||
		' p_max_pay_date: ' || fnd_date.date_to_canonical(p_max_pay_date));

	l_proc_step := 10;	-- Introduced for bug fix 3434626
--	End of bug fix 3434626

	/* Opening element_account_cur to fetch poeta for element_type_accounts */
	OPEN element_account_cur;
	FETCH element_account_cur BULK COLLECT INTO
		r_global_control_rec.r_global_line_id,
		r_global_control_rec.r_project_id,
		r_global_control_rec.r_task_id,
		r_global_control_rec.r_expenditure_organization_id,
		r_global_control_rec.r_expenditure_type,
		r_global_control_rec.r_award_id,
		r_global_control_rec.r_start_date_active,
		r_global_control_rec.r_end_date_active,
		r_global_control_rec.r_poeta_start_date,
		r_global_control_rec.r_poeta_end_date;
	CLOSE element_account_cur;

	g_total_num_rec := r_global_control_rec.r_global_line_id.count;

	FOR i IN 1.. g_total_num_rec
	LOOP
--	Introduced the following for bug fix 3434626
		hr_utility.trace('i: ' || fnd_number.number_to_canonical(i) ||
			' r_global_control_rec.r_global_line_id: ' || fnd_number.number_to_canonical(r_global_control_rec.r_global_line_id(i)) ||
			' r_global_control_rec.r_project_id(i): ' || fnd_number.number_to_canonical(r_global_control_rec.r_project_id(i)) ||
			' r_global_control_rec.r_award_id(i): ' || fnd_number.number_to_canonical(r_global_control_rec.r_award_id(i)) ||
			' r_global_control_rec.r_task_id(i): ' || fnd_number.number_to_canonical(r_global_control_rec.r_task_id(i)) ||
			' r_global_control_rec.r_expenditure_organization_id(i): ' || fnd_number.number_to_canonical(r_global_control_rec.r_expenditure_organization_id(i)) ||
			' r_global_control_rec.r_poeta_start_date(i): ' || fnd_date.date_to_canonical(r_global_control_rec.r_poeta_start_date(i)) ||
			' r_global_control_rec.r_poeta_end_date(i): ' || fnd_date.date_to_canonical(r_global_control_rec.r_poeta_end_date(i)) ||
			' r_global_control_rec.r_expenditure_type(i): ' || r_global_control_rec.r_expenditure_type(i) ||
			' l_prev_project_id: ' || fnd_number.number_to_canonical(l_prev_project_id) ||
			' l_prev_award_id: ' || fnd_number.number_to_canonical(l_prev_award_id) ||
			' l_prev_task_id: ' || fnd_number.number_to_canonical(l_prev_task_id) ||
			' l_prev_exp_organization_id: ' || fnd_number.number_to_canonical(l_prev_exp_organization_id) ||
			' l_prev_expenditure_type: ' || l_prev_expenditure_type);

		l_proc_step := 20;
--	End of bug fix 3434626

		IF ((r_global_control_rec.r_project_id(i) <> l_prev_project_id) OR
			(r_global_control_rec.r_expenditure_organization_id(i) <>
				l_prev_exp_organization_id) OR
			(r_global_control_rec.r_task_id(i) <> l_prev_task_id) OR
			(r_global_control_rec.r_award_id(i) <> l_prev_award_id) OR
			(r_global_control_rec.r_expenditure_type(i) <> l_prev_expenditure_type)) THEN
			validate_poeta (p_project_id	=>	r_global_control_rec.r_project_id(i),
				p_task_id		=>	r_global_control_rec.r_task_id(i),
				p_award_id		=>	r_global_control_rec.r_award_id(i),
				p_expenditure_type	=>	r_global_control_rec.r_expenditure_type(i),
				p_expenditure_organization_id	=>	r_global_control_rec.r_expenditure_organization_id(i),
				p_payroll_id		=>	p_payroll_id,
				p_start_date		=>	g_final_start_date,
				p_end_date		=>	g_final_end_date,
				p_return_status		=>	p_return_status);
			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

--	Introduced for bug fix 3434626
			hr_utility.trace('l_poeta_start_date: ' || fnd_date.date_to_canonical(g_final_start_date) ||
				' l_poeta_end_date: ' || fnd_date.date_to_canonical(g_final_end_date));
			l_proc_step := 30;
--	End of bug fix 3434626

			l_prev_project_id := r_global_control_rec.r_project_id(i);
			l_prev_task_id := r_global_control_rec.r_task_id(i);
			l_prev_award_id := r_global_control_rec.r_award_id(i);
			l_prev_exp_organization_id :=
				r_global_control_rec.r_expenditure_organization_id(i);
			l_prev_expenditure_type := r_global_control_rec.r_expenditure_type(i);
		END IF;
		/* Verifying whether current poeta dates are different from previous poeta dates */
		IF (r_global_control_rec.r_poeta_start_date(i) <> g_final_start_date)
			OR	(r_global_control_rec.r_poeta_end_date(i) <> g_final_end_date) THEN
			r_global_control_rec.r_poeta_start_date(i) := g_final_start_date;
			r_global_control_rec.r_poeta_end_date(i) := g_final_end_date;

			IF (p_pre_process_mode = 'R') THEN
				/* Opening the cursor to fetch payroll_id and assignment_id into
				respective payroll_id and assignment_id arrays */
				OPEN assignment_payroll_cur(i);
				FETCH assignment_payroll_cur BULK COLLECT INTO
					r_asg_id_array.r_asg_id, r_asg_id_array.r_payroll_id;
				CLOSE assignment_payroll_cur;

--	Introduced for bug fix 3434626
				hr_utility.trace('r_asg_id_array.r_asg_id.count: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.count));
				l_proc_step := 40;
--	End of bug fix 3434626

				/* Insert assignments (exists in psp_enc_lines_history and poeta dates
				are changed) into psp_enc_changed_assignments */
				IF r_asg_id_array.r_asg_id.count<>0 THEN
					insert_changed_assignments	(p_change_type =>	'PT',
						p_return_status =>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
				END IF;
			END IF;
		ELSE
			l_proc_step := 50;	-- Introduced for bug fix 3434626
			IF (p_pre_process_mode = 'R') THEN
				IF r_global_control_rec.r_project_id(i) <> l_prev_tx_project_id THEN
					validate_transaction_controls
						(p_project_id	=>	r_global_control_rec.r_project_id(i),
						p_payroll_id	=>	p_payroll_id,
						p_return_status	=>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
					l_prev_tx_project_id := r_global_control_rec.r_project_id(i);
				END IF;
			END IF;

		END IF;
	END LOOP;

	l_proc_step := 60;	-- Introduced for bug fix 3434626

	/* Updating poeta dates in psp_element_type_accounts */
	FORALL i in 1 .. g_total_num_rec
	UPDATE	psp_element_type_accounts
	SET	poeta_start_date = r_global_control_rec.r_poeta_start_date(i),
		poeta_end_date = r_global_control_rec.r_poeta_end_date(i)
	WHERE	element_account_id = r_global_control_rec.r_global_line_id(i);

	p_return_status := fnd_api.g_ret_sts_success;

--	Introduced for bug fix 3434626
	hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := SUBSTR('UPDT_GLBL:'||g_error_api_path,1,30);
                -- bug fix 2597666
		p_return_status := fnd_api.g_ret_sts_unexp_error;
--	Introduced for bug fix 3434626
		hr_utility.trace(fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
END update_global_earning_elements;

/****************************************************************************************************
	Procedure Name:	UPDATE_SCHEDULES
	Purpose:	This procedure is called in the main procedure and used for updating poeta
			dates psp_schedule_lines for poeta CI. It inserts assignments in
			psp_enc_changed_assignments if the poeta dates are different from previous
			poeta dates and assignments exist in psp_enc_lines_history table.
****************************************************************************************************/

PROCEDURE update_schedules	(p_pre_process_mode	IN	VARCHAR2,
				p_payroll_id		IN	NUMBER,
				p_business_group_id	IN	NUMBER,
				p_set_of_books_id	IN	NUMBER,
				p_max_pay_date		IN	DATE,
				p_return_status		OUT NOCOPY	VARCHAR2)
IS

TYPE schedule_lines_rec is RECORD (
	r_assignment_id			v_assignment_id,
	r_payroll_id			v_payroll_id,
	r_schedule_line_id		v_line_id,
	r_project_id			v_project_id,
	r_task_id			v_task_id,
	r_expenditure_organization_id	v_exp_org,
	r_expenditure_type		v_exp_type,
	r_award_id			v_award_id,
	r_schedule_begin_date		v_start_dt,
	r_schedule_end_date		v_end_dt,
	r_poeta_start_date		v_start_dt,
	r_poeta_end_date		v_end_dt);

r_schedule_control_rec	schedule_lines_rec;


l_prev_project_id			NUMBER(15)	DEFAULT -1;
l_prev_task_id				NUMBER(15)	DEFAULT -1;
l_prev_award_id				NUMBER(15)	DEFAULT -1;
l_prev_exp_organization_id		NUMBER(15)	DEFAULT -1;
l_prev_expenditure_type			VARCHAR2(30)	DEFAULT '-1';
l_prev_tx_project_id			NUMBER(15)	DEFAULT -1;

j	NUMBER DEFAULT 1;

--	Introduced for bug fix 3434626
l_proc_name		VARCHAR2(61)	DEFAULT g_package_name || 'UPDATE_SCHEDULES';
l_proc_step		NUMBER(20, 10)	DEFAULT 0;
--	End of changes for bug fix 3434626

CURSOR	schedule_line_cur IS
SELECT	psh.assignment_id,
	paf.payroll_id,
	psl.schedule_line_id,
	psl.project_id,
	psl.task_id,
	psl.expenditure_organization_id,
	psl.expenditure_type,
	psl.award_id,
	psl.schedule_begin_date,
	psl.schedule_end_date,
	NVL(psl.poeta_start_date,TO_DATE('01-01-1800', 'DD-MM-YYYY')) poeta_start_date,
	NVL(psl.poeta_end_date,TO_DATE('31-12-4712', 'DD-MM-YYYY')) poeta_start_date
FROM	psp_schedule_hierarchy psh,
	psp_schedule_lines	psl	,
	per_assignments_f	paf
WHERE	psl.business_group_id = p_business_group_id
AND	psl.set_of_books_id = p_set_of_books_id
AND	psl.schedule_hierarchy_id = psh.schedule_hierarchy_id
AND	psl.schedule_end_date >= p_max_pay_date
AND	psl.gl_code_combination_id IS NULL
AND	psh.assignment_id = paf.assignment_id
AND	psl.schedule_begin_date <=  paf.effective_end_date
AND	psl.schedule_end_date >= paf.effective_start_date
AND	paf.period_of_service_id IS NOT NULL
and paf.payroll_id = p_payroll_id   --bug fix 2597666	Modified NOT NULL check to current payroll check for bug fix 3099540
AND	paf.effective_end_date >= p_max_pay_date	-- Introduced for bug fix 3099540 Corrected for bug fix 3434626
ORDER BY 4,5,6,7,8;

BEGIN
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Entering ' || l_proc_name);
	hr_utility.trace('p_pre_process_mode: ' || p_pre_process_mode ||
		' p_payroll_id: ' || fnd_number.number_to_canonical(p_payroll_id) ||
		' p_business_group_id: ' || fnd_number.number_to_canonical(p_business_group_id) ||
		' p_set_of_books_id: ' || fnd_number.number_to_canonical(p_set_of_books_id) ||
		' p_max_pay_date: ' || fnd_date.date_to_canonical(p_max_pay_date));

	l_proc_step := 10;	-- Introduced for bug fix 3434626
--	End of bug fix 3434626

	/* Opening schedule_line_cur to fetch poeta for schedule_lines */
	OPEN schedule_line_cur;
	FETCH	schedule_line_cur BULK COLLECT INTO
		r_schedule_control_rec.r_assignment_id,
		r_schedule_control_rec.r_payroll_id,
		r_schedule_control_rec.r_schedule_line_id,
		r_schedule_control_rec.r_project_id,
		r_schedule_control_rec.r_task_id,
		r_schedule_control_rec.r_expenditure_organization_id,
		r_schedule_control_rec.r_expenditure_type,
		r_schedule_control_rec.r_award_id,
		r_schedule_control_rec.r_schedule_begin_date,
		r_schedule_control_rec.r_schedule_end_date,
		r_schedule_control_rec.r_poeta_start_date,
		r_schedule_control_rec.r_poeta_end_date;
	CLOSE schedule_line_cur;

	g_total_num_rec := r_schedule_control_rec.r_schedule_line_id.count;

	FOR i IN 1..g_total_num_rec
	LOOP
--	Introduced the following for bug fix 3434626
		hr_utility.trace('i: ' || fnd_number.number_to_canonical(i) ||
			' r_schedule_control_rec.r_schedule_line_id: ' || fnd_number.number_to_canonical(r_schedule_control_rec.r_schedule_line_id(i)) ||
			' r_schedule_control_rec.r_project_id(i): ' || fnd_number.number_to_canonical(r_schedule_control_rec.r_project_id(i)) ||
			' r_schedule_control_rec.r_award_id(i): ' || fnd_number.number_to_canonical(r_schedule_control_rec.r_award_id(i)) ||
			' r_schedule_control_rec.r_task_id(i): ' || fnd_number.number_to_canonical(r_schedule_control_rec.r_task_id(i)) ||
			' r_schedule_control_rec.r_expenditure_organization_id(i): ' || fnd_number.number_to_canonical(r_schedule_control_rec.r_expenditure_organization_id(i)) ||
			' r_schedule_control_rec.r_poeta_start_date(i): ' || fnd_date.date_to_canonical(r_schedule_control_rec.r_poeta_start_date(i)) ||
			' r_schedule_control_rec.r_poeta_end_date(i): ' || fnd_date.date_to_canonical(r_schedule_control_rec.r_poeta_end_date(i)) ||
			' r_schedule_control_rec.r_expenditure_type(i): ' || r_schedule_control_rec.r_expenditure_type(i) ||
			' l_prev_project_id: ' || fnd_number.number_to_canonical(l_prev_project_id) ||
			' l_prev_award_id: ' || fnd_number.number_to_canonical(l_prev_award_id) ||
			' l_prev_task_id: ' || fnd_number.number_to_canonical(l_prev_task_id) ||
			' l_prev_exp_organization_id: ' || fnd_number.number_to_canonical(l_prev_exp_organization_id) ||
			' l_prev_expenditure_type: ' || l_prev_expenditure_type);

		l_proc_step := 20;
--	End of bug fix 3434626

		IF ((r_schedule_control_rec.r_project_id(i) <> l_prev_project_id) OR
			(r_schedule_control_rec.r_expenditure_organization_id(i) <>
				l_prev_exp_organization_id) OR
			(r_schedule_control_rec.r_task_id(i) <> l_prev_task_id) OR
			(r_schedule_control_rec.r_award_id(i) <> l_prev_award_id) OR
			(r_schedule_control_rec.r_expenditure_type(i) <> l_prev_expenditure_type)) THEN

			/* Validating and fetching poeta dates */
			validate_poeta (p_project_id	=>	r_schedule_control_rec.r_project_id(i),
				p_task_id		=>	r_schedule_control_rec.r_task_id(i),
				p_award_id		=>	r_schedule_control_rec.r_award_id(i),
				p_expenditure_type	=>	r_schedule_control_rec.r_expenditure_type(i),
				p_expenditure_organization_id	=>	r_schedule_control_rec.r_expenditure_organization_id(i),
				p_payroll_id		=>	p_payroll_id,
				p_start_date		=>	g_final_start_date,
				p_end_date		=>	g_final_end_date,
				p_return_status		=>	p_return_status);

			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

--	Introduced for bug fix 3434626
			hr_utility.trace('l_poeta_start_date: ' || fnd_date.date_to_canonical(g_final_start_date) ||
				' l_poeta_end_date: ' || fnd_date.date_to_canonical(g_final_end_date));
			l_proc_step := 30;
--	End of bug fix 3434626

			l_prev_project_id := r_schedule_control_rec.r_project_id(i);
			l_prev_task_id := r_schedule_control_rec.r_task_id(i);
			l_prev_award_id := r_schedule_control_rec.r_award_id(i);
			l_prev_exp_organization_id :=
				r_schedule_control_rec.r_expenditure_organization_id(i);
			l_prev_expenditure_type := r_schedule_control_rec.r_expenditure_type(i);
		END IF;

		/* Verifying whether current poeta dates are different from previous poeta dates */
		IF (r_schedule_control_rec.r_poeta_start_date(i) <> g_final_start_date)
			OR (r_schedule_control_rec.r_poeta_end_date(i) <> g_final_end_date) THEN
			r_schedule_control_rec.r_poeta_start_date(i) := g_final_start_date;
			r_schedule_control_rec.r_poeta_end_date(i) := g_final_end_date;
			IF (p_pre_process_mode = 'R') THEN
				r_asg_id_array.r_asg_id(j) := r_schedule_control_rec.r_assignment_id(i);
				r_asg_id_array.r_payroll_id(j) := r_schedule_control_rec.r_payroll_id(i);
				j := j+1;
			END IF;
--	Introduced for bug fix 3434626
			hr_utility.trace('j: ' || fnd_number.number_to_canonical(j));
			l_proc_step := 40;
--	End of bug fix 3434626

		ELSE
			IF (p_pre_process_mode = 'R') THEN
				IF r_schedule_control_rec.r_project_id(i)<> l_prev_tx_project_id THEN
--	Introduced for bug fix 3434626
					l_proc_step := 50;
--	End of bug fix 3434626

                                      IF j>1 then
		                          insert_changed_assignments	(p_change_type =>	'PT',
						p_return_status =>	p_return_status);
                         		IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
			                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                                          j:=1;

                                      END IF;       -- bug fix  2597666

--	Introduced for bug fix 3434626
					l_proc_step := 60;
--	End of bug fix 3434626

					validate_transaction_controls
						(p_project_id	=>	r_schedule_control_rec.r_project_id(i),
						p_payroll_id	=>	p_payroll_id,
						p_return_status	=>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
					l_prev_tx_project_id := r_schedule_control_rec.r_project_id(i);
				END IF;
			END IF;
		END IF;
	END LOOP;

--	Introduced for bug fix 3434626
	l_proc_step := 70;
--	End of bug fix 3434626

	/* Updating poeta dates in psp_schedule_lines */
	FORALL i in 1 .. g_total_num_rec
	UPDATE	psp_schedule_lines
	SET	poeta_end_date = r_schedule_control_rec.r_poeta_end_date(i),
		poeta_start_date = r_schedule_control_rec.r_poeta_start_date(i)
	WHERE	schedule_line_id = r_schedule_control_rec.r_schedule_line_id(i);

--	Introduced for bug fix 3434626
	l_proc_step := 80;
--	End of bug fix 3434626

	IF (p_pre_process_mode = 'R') THEN
		/* Inserting into psp_enc_changed_assignments */
              IF j> 1  then   -- bug fix 2597666
		insert_changed_assignments	(p_change_type =>	'PT',
						p_return_status =>	p_return_status);
		IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
              END IF;
	END IF;

	p_return_status := fnd_api.g_ret_sts_success;

--	Introduced for bug fix 3434626
	l_proc_step := 80;
	hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
EXCEPTION
	WHEN OTHERS THEN
	        g_error_api_path := SUBSTR('UPDT_SCHDLS:'||g_error_api_path,1,30);
                 -- bug fix 2597666
		p_return_status := fnd_api.g_ret_sts_unexp_error;
--	Introduced for bug fix 3434626
		hr_utility.trace(fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
END update_schedules;

/****************************************************************************************************
	Procedure Name:	update_default_labor_schedules
	Purpose:	This procedure is called in the main procedure and used for updating poeta
			dates in psp_org_default_labor_schedules table for poeta CI. It inserts
			assignments in psp_enc_changed_assignments table if the poeta dates are
			different from previous poeta dates and assignments exists in
			psp_enc_lines_history table.
****************************************************************************************************/

PROCEDURE update_default_labor_schedules	(p_pre_process_mode	IN	VARCHAR2,
						p_payroll_id		IN	NUMBER,
						p_business_group_id	IN	NUMBER,
						p_set_of_books_id	IN	NUMBER,
						p_max_pay_date		IN	DATE,
						p_return_status		OUT NOCOPY	VARCHAR2)
IS

TYPE ls_lines_rec is RECORD (
	r_org_schedule_id		v_line_id,
	r_project_id			v_project_id,
	r_task_id			v_task_id,
	r_expenditure_organization_id	v_exp_org,
	r_expenditure_type		v_exp_type,
	r_award_id			v_award_id,
	r_start_date_active		v_start_dt,
	r_end_date_active		v_end_dt,
	r_poeta_start_date		v_start_dt,
	r_poeta_end_date		v_end_dt);
r_ls_control_rec		ls_lines_rec;

l_prev_project_id			NUMBER(15)	DEFAULT -1;
l_prev_task_id				NUMBER(15)	DEFAULT -1;
l_prev_award_id				NUMBER(15)	DEFAULT -1;
l_prev_exp_organization_id		NUMBER(15)	DEFAULT -1;
l_prev_expenditure_type			VARCHAR2(30)	DEFAULT '-1';
l_prev_tx_project_id			NUMBER(15)	DEFAULT -1;

/* Cursor will select distinct poeta combinations from psp_default_labor_schedules for a payroll. */
CURSOR	org_labor_schedule_cur IS
SELECT	pdls.org_schedule_id,
	pdls.project_id,
	pdls.task_id,
	pdls.expenditure_organization_id,
	pdls.expenditure_type,
	pdls.award_id,
	pdls.schedule_begin_date,
	pdls.schedule_end_date,
	NVL(pdls.poeta_start_date,TO_DATE('01-01-1800', 'DD-MM-YYYY')) poeta_start_date,
	NVL(pdls.poeta_end_date,TO_DATE('31-12-4712', 'DD-MM-YYYY')) poeta_end_date
FROM	psp_default_labor_schedules pdls
WHERE	pdls.business_group_id = p_business_group_id
AND	pdls.set_of_books_id = p_set_of_books_id
AND	pdls.gl_code_combination_id IS NULL
AND	pdls.schedule_end_date >= p_max_pay_date
ORDER BY 2,3,4,5,6;

CURSOR	assignment_payroll_cur(j number) IS
SELECT	DISTINCT pelh.assignment_id,pelh.payroll_id
FROM	psp_enc_lines_history pelh
--	Modified default_org_account_id to org_schedule_id for bug 2334434
WHERE	pelh.org_schedule_id = r_ls_control_rec.r_org_schedule_id (j)
AND	pelh.suspense_org_account_id IS NULL
AND	pelh.change_flag = 'N';

--      Introduced for bug fix 3434626
l_proc_name		VARCHAR2(61)	DEFAULT g_package_name || 'UPDATE_DEFAULT_LABOR_SCHEDULES';
l_proc_step		NUMBER(20, 10)	DEFAULT 0;
--      End of changes for bug fix 3434626

BEGIN
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Entering ' || l_proc_name);
	hr_utility.trace('p_pre_process_mode: ' || p_pre_process_mode ||
		' p_payroll_id: ' || fnd_number.number_to_canonical(p_payroll_id) ||
		' p_business_group_id: ' || fnd_number.number_to_canonical(p_business_group_id) ||
		' p_set_of_books_id: ' || fnd_number.number_to_canonical(p_set_of_books_id) ||
		' p_max_pay_date: ' || fnd_date.date_to_canonical(p_max_pay_date));

	l_proc_step := 10;	-- Introduced for bug fix 3434626
--	End of bug fix 3434626

	/* Fetching distinct poeta combinations from psp_org_default_labor_schedules table*/
	OPEN org_labor_schedule_cur;
	FETCH org_labor_schedule_cur BULK COLLECT INTO
		r_ls_control_rec.r_org_schedule_id,
		r_ls_control_rec.r_project_id,
		r_ls_control_rec.r_task_id,
		r_ls_control_rec.r_expenditure_organization_id,
		r_ls_control_rec.r_expenditure_type,
		r_ls_control_rec.r_award_id,
		r_ls_control_rec.r_start_date_active,
		r_ls_control_rec.r_end_date_active,
		r_ls_control_rec.r_poeta_start_date,
		r_ls_control_rec.r_poeta_end_date;
	CLOSE org_labor_schedule_cur;
	g_total_num_rec := r_ls_control_rec.r_org_schedule_id.count;

	FOR i IN 1..g_total_num_rec
	LOOP
--	Introduced the following for bug fix 3434626
	hr_utility.trace('i: ' || fnd_number.number_to_canonical(i) ||
			' r_ls_control_rec.r_schedule_line_id: ' || fnd_number.number_to_canonical(r_ls_control_rec.r_org_schedule_id(i)) ||
			' r_ls_control_rec.r_project_id(i): ' || fnd_number.number_to_canonical(r_ls_control_rec.r_project_id(i)) ||
			' r_ls_control_rec.r_award_id(i): ' || fnd_number.number_to_canonical(r_ls_control_rec.r_award_id(i)) ||
			' r_ls_control_rec.r_task_id(i): ' || fnd_number.number_to_canonical(r_ls_control_rec.r_task_id(i)) ||
			' r_ls_control_rec.r_expenditure_organization_id(i): ' || fnd_number.number_to_canonical(r_ls_control_rec.r_expenditure_organization_id(i)) ||
			' r_ls_control_rec.r_poeta_start_date(i): ' || fnd_date.date_to_canonical(r_ls_control_rec.r_poeta_start_date(i)) ||
			' r_ls_control_rec.r_poeta_end_date(i): ' || fnd_date.date_to_canonical(r_ls_control_rec.r_poeta_end_date(i)) ||
			' r_ls_control_rec.r_expenditure_type(i): ' || r_ls_control_rec.r_expenditure_type(i) ||
			' l_prev_project_id: ' || fnd_number.number_to_canonical(l_prev_project_id) ||
			' l_prev_award_id: ' || fnd_number.number_to_canonical(l_prev_award_id) ||
			' l_prev_task_id: ' || fnd_number.number_to_canonical(l_prev_task_id) ||
			' l_prev_exp_organization_id: ' || fnd_number.number_to_canonical(l_prev_exp_organization_id) ||
			' l_prev_expenditure_type: ' || l_prev_expenditure_type);

		l_proc_step := 20;
--	End of bug fix 3434626

		IF ((r_ls_control_rec.r_project_id(i) <> l_prev_project_id) OR
			(r_ls_control_rec.r_expenditure_organization_id(i) <> l_prev_exp_organization_id) OR
			(r_ls_control_rec.r_task_id(i) <> l_prev_task_id) OR
			(r_ls_control_rec.r_award_id(i) <> l_prev_award_id) OR
			(r_ls_control_rec.r_expenditure_type(i) <> l_prev_expenditure_type)) THEN

			/* Validating and fetching poeta dates */
			validate_poeta (p_project_id	=>	r_ls_control_rec.r_project_id(i),
				p_task_id		=>	r_ls_control_rec.r_task_id(i),
				p_award_id		=>	r_ls_control_rec.r_award_id(i),
				p_expenditure_type	=>	r_ls_control_rec.r_expenditure_type(i),
				p_expenditure_organization_id	=>	r_ls_control_rec.r_expenditure_organization_id(i),
				p_payroll_id		=>	p_payroll_id,
				p_start_date		=>	g_final_start_date,
				p_end_date		=>	g_final_end_date,
				p_return_status		=>	p_return_status);

			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

--	Introduced for bug fix 3434626
			hr_utility.trace('l_poeta_start_date: ' || fnd_date.date_to_canonical(g_final_start_date) ||
				' l_poeta_end_date: ' || fnd_date.date_to_canonical(g_final_end_date));
			l_proc_step := 30;
--	End of bug fix 3434626

			l_prev_project_id := r_ls_control_rec.r_project_id(i);
			l_prev_task_id := r_ls_control_rec.r_task_id(i);
			l_prev_award_id := r_ls_control_rec.r_award_id(i);
			l_prev_exp_organization_id := r_ls_control_rec.r_expenditure_organization_id(i);
			l_prev_expenditure_type := r_ls_control_rec.r_expenditure_type(i);
		END IF;

		/* Verifying whether poeta dates are different from previous dates */
		IF (r_ls_control_rec.r_poeta_start_date(i) <> g_final_start_date)
			OR (r_ls_control_rec.r_poeta_end_date(i) <> g_final_end_date) THEN
			r_ls_control_rec.r_poeta_start_date(i) := g_final_start_date;
			r_ls_control_rec.r_poeta_end_date(i) := g_final_end_date;

			IF (p_pre_process_mode = 'R') THEN
				/* Opening the cursor to fetch payroll_id and assignment_id into
				respective payroll_id and assignment_id arrays */
				OPEN assignment_payroll_cur(i);
				FETCH assignment_payroll_cur BULK COLLECT INTO r_asg_id_array.r_asg_id,
					r_asg_id_array.r_payroll_id;
				CLOSE	assignment_payroll_cur;

--	Introduced for bug fix 3434626
				hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
				l_proc_step := 40;
--	End of bug fix 3434626
				/* Insert assignments (exists in psp_enc_lines_history and poeta dates are
				changed) into psp_enc_changed_assignments table*/
				IF r_asg_id_array.r_asg_id.count<>0 THEN
					insert_changed_assignments	(p_change_type	=>	'PT',
							p_return_status	=>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
				END IF;
			END IF;
		ELSE
			IF (p_pre_process_mode = 'R') THEN
--	Introduced for bug fix 3434626
				l_proc_step := 50;
--	End of bug fix 3434626
				IF r_ls_control_rec.r_project_id(i) <> l_prev_tx_project_id THEN
					validate_transaction_controls
						(p_project_id	=>	r_ls_control_rec.r_project_id(i),
						p_payroll_id	=>	p_payroll_id,
						p_return_status	=>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
					l_prev_tx_project_id := r_ls_control_rec.r_project_id(i);
				END IF;
			END IF;
		END IF;
	END LOOP;

--	Introduced for bug fix 3434626
	l_proc_step := 60;
--	End of bug fix 3434626

	/*Updating poeta dates in psp_default_labor_schedule table */
	FORALL i in 1 .. g_total_num_rec
	UPDATE psp_default_labor_schedules
	SET	poeta_end_date = r_ls_control_rec.r_poeta_end_date(i),
		poeta_start_date = r_ls_control_rec.r_poeta_start_date(i)
	WHERE	org_schedule_id = r_ls_control_rec.r_org_schedule_id(i);

	p_return_status := fnd_api.g_ret_sts_success;

--	Introduced for bug fix 3434626
	l_proc_step := 70;
	hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := SUBSTR('UPDT_DFLT_LBR_SCHD:'||g_error_api_path,1,30);
                 -- bug fix 2597666
		p_return_status := fnd_api.g_ret_sts_unexp_error;
--	Introduced for bug fix 3434626
		hr_utility.trace(fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
END update_default_labor_schedules;

/****************************************************************************************************
	Procedure Name:	UPDATE_DEFAULT_SUSP_ACCOUNTS
	Purpose:	This procedure is called in the main procedure and used for updating poeta
			dates in psp_organization_accounts for poeta CI. It inserts assignments in
			psp_enc_changed_assignments table if the poeta dates are different from
			previous poeta dates and assignments exists in psp_enc_lines_history
			table.
****************************************************************************************************/

PROCEDURE update_default_susp_accounts	(p_pre_process_mode	IN	VARCHAR2,
					p_payroll_id		IN	NUMBER,
					p_business_group_id	IN	NUMBER,
					p_set_of_books_id	IN	NUMBER,
					p_max_pay_date		IN	DATE,
					p_return_status		OUT NOCOPY	VARCHAR2)
IS

TYPE susp_lines_rec is RECORD
	(r_organization_account_id	v_line_id,
	r_project_id			v_project_id,
	r_task_id			v_task_id,
	r_expenditure_organization_id	v_exp_org,
	r_expenditure_type		v_exp_type,
	r_award_id			v_award_id,
	r_start_date_active		v_start_dt,
	r_end_date_active		v_end_dt,
	r_poeta_start_date		v_start_dt,
	r_poeta_end_date		v_end_dt);

r_susp_control_rec	susp_lines_rec;

l_prev_project_id			NUMBER(15)	DEFAULT -1;
l_prev_task_id				NUMBER(15)	DEFAULT -1;
l_prev_award_id				NUMBER(15)	DEFAULT -1;
l_prev_exp_organization_id		NUMBER(15)	DEFAULT -1;
l_prev_expenditure_type			VARCHAR2(30)	DEFAULT '-1';
l_prev_tx_project_id			NUMBER(15)	DEFAULT -1;

CURSOR	suspense_account_cur IS
SELECT	poa.organization_account_id,
	poa.project_id,
	poa.task_id,
	poa.expenditure_organization_id,
	poa.expenditure_type,
	poa.award_id,
	poa.start_date_active,
	poa.end_date_active,
	NVL(poa.poeta_start_date,TO_DATE('01-01-1800', 'DD-MM-YYYY')) poeta_start_date,
	NVL(poa.poeta_end_date,TO_DATE('31-12-4712', 'DD-MM-YYYY')) poeta_end_date
FROM	psp_organization_accounts	poa
WHERE	poa.gl_code_combination_id IS NULL
AND	poa.end_date_active >= p_max_pay_date
AND	poa.business_group_id = p_business_group_id
AND	poa.set_of_books_id = p_set_of_books_id
ORDER BY 2,3,4,5,6;

CURSOR	assignment_payroll_cur(j number) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh
WHERE	NVL(suspense_org_account_id, default_org_account_id) = r_susp_control_rec.r_organization_account_id (j)
AND	pelh.change_flag = 'N';

--	Introduced for bug fix 3434626
l_proc_name		VARCHAR2(61)	DEFAULT g_package_name || 'UPDATE_DEFAULT_SUSP_ACCOUNTS';
l_proc_step		NUMBER(20, 10)	DEFAULT 0;
--	End of changes for bug fix 3434626
BEGIN
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Entering ' || l_proc_name);
	hr_utility.trace('p_pre_process_mode: ' || p_pre_process_mode ||
		' p_payroll_id: ' || fnd_number.number_to_canonical(p_payroll_id) ||
		' p_business_group_id: ' || fnd_number.number_to_canonical(p_business_group_id) ||
		' p_set_of_books_id: ' || fnd_number.number_to_canonical(p_set_of_books_id) ||
		' p_max_pay_date: ' || fnd_date.date_to_canonical(p_max_pay_date));

	l_proc_step := 10;      -- Introduced for bug fix 3434626
--	End of bug fix 3434626

	/* Opening suspense account cur to fetch poeta lines*/
	OPEN suspense_account_cur;
	FETCH suspense_account_cur BULK COLLECT INTO
		r_susp_control_rec.r_organization_account_id,
		r_susp_control_rec.r_project_id,
		r_susp_control_rec.r_task_id,
		r_susp_control_rec.r_expenditure_organization_id,
		r_susp_control_rec.r_expenditure_type,
		r_susp_control_rec.r_award_id,
		r_susp_control_rec.r_start_date_active,
		r_susp_control_rec.r_end_date_active,
		r_susp_control_rec.r_poeta_start_date,
		r_susp_control_rec.r_poeta_end_date;
	CLOSE suspense_account_cur;
	g_total_num_rec := r_susp_control_rec.r_organization_account_id.count;

	FOR i IN 1..g_total_num_rec
	LOOP
--	Introduced the following for bug fix 3434626
		hr_utility.trace('i: ' || fnd_number.number_to_canonical(i) ||
			' r_susp_control_rec.r_schedule_line_id: ' || fnd_number.number_to_canonical(r_susp_control_rec.r_organization_account_id(i)) ||
			' r_susp_control_rec.r_project_id(i): ' || fnd_number.number_to_canonical(r_susp_control_rec.r_project_id(i)) ||
			' r_susp_control_rec.r_award_id(i): ' || fnd_number.number_to_canonical(r_susp_control_rec.r_award_id(i)) ||
			' r_susp_control_rec.r_task_id(i): ' || fnd_number.number_to_canonical(r_susp_control_rec.r_task_id(i)) ||
			' r_susp_control_rec.r_expenditure_organization_id(i): ' || fnd_number.number_to_canonical(r_susp_control_rec.r_expenditure_organization_id(i)) ||
			' r_susp_control_rec.r_poeta_start_date(i): ' || fnd_date.date_to_canonical(r_susp_control_rec.r_poeta_start_date(i)) ||
			' r_susp_control_rec.r_poeta_end_date(i): ' || fnd_date.date_to_canonical(r_susp_control_rec.r_poeta_end_date(i)) ||
			' r_susp_control_rec.r_expenditure_type(i): ' || r_susp_control_rec.r_expenditure_type(i) ||
			' l_prev_project_id: ' || fnd_number.number_to_canonical(l_prev_project_id) ||
			' l_prev_award_id: ' || fnd_number.number_to_canonical(l_prev_award_id) ||
			' l_prev_task_id: ' || fnd_number.number_to_canonical(l_prev_task_id) ||
			' l_prev_exp_organization_id: ' || fnd_number.number_to_canonical(l_prev_exp_organization_id) ||
			' l_prev_expenditure_type: ' || l_prev_expenditure_type);

		l_proc_step := 20;
--	End of bug fix 3434626

		IF ((r_susp_control_rec.r_project_id(i) <> l_prev_project_id) OR
			(r_susp_control_rec.r_expenditure_organization_id(i) <> l_prev_exp_organization_id) OR
			(r_susp_control_rec.r_task_id(i) <> l_prev_task_id) OR
			(r_susp_control_rec.r_award_id(i) <> l_prev_award_id) OR
			(r_susp_control_rec.r_expenditure_type(i) <> l_prev_expenditure_type)) THEN

			/* Validating and fetching poeta dates*/
			validate_poeta (p_project_id	=>	r_susp_control_rec.r_project_id(i),
				p_task_id		=>	r_susp_control_rec.r_task_id(i),
				p_award_id		=>	r_susp_control_rec.r_award_id(i),
				p_expenditure_type	=>	r_susp_control_rec.r_expenditure_type(i),
				p_expenditure_organization_id	=>	r_susp_control_rec.r_expenditure_organization_id(i),
				p_payroll_id		=>	p_payroll_id,
				p_start_date		=>	g_final_start_date,
				p_end_date		=>	g_final_end_date,
				p_return_status		=>	p_return_status);

			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

--	Introduced for bug fix 3434626
			hr_utility.trace('l_poeta_start_date: ' || fnd_date.date_to_canonical(g_final_start_date) ||
				' l_poeta_end_date: ' || fnd_date.date_to_canonical(g_final_end_date));
			l_proc_step := 30;
--	End of bug fix 3434626

			l_prev_project_id := r_susp_control_rec.r_project_id(i);
			l_prev_task_id := r_susp_control_rec.r_task_id(i);
			l_prev_award_id := r_susp_control_rec.r_award_id(i);
			l_prev_exp_organization_id := r_susp_control_rec.r_expenditure_organization_id(i);
			l_prev_expenditure_type := r_susp_control_rec.r_expenditure_type(i);
		END IF;


		/* Checking whether poeta dates are different from previous dates */
		IF	(r_susp_control_rec.r_poeta_start_date(i) <>g_final_start_date)
			OR (r_susp_control_rec.r_poeta_end_date(i) <> g_final_end_date) THEN
			r_susp_control_rec.r_poeta_end_date(i) := g_final_end_date;
			r_susp_control_rec.r_poeta_start_date(i) := g_final_start_date;

			IF (p_pre_process_mode = 'R') THEN
				/* Opening the cursor to fetch payroll_id and assignment_id into respective
				payroll_id and assignment_id arrays */
				OPEN assignment_payroll_cur(i);
				FETCH assignment_payroll_cur BULK COLLECT INTO r_asg_id_array.r_asg_id,
					r_asg_id_array.r_payroll_id;
				CLOSE assignment_payroll_cur;

--	Introduced for bug fix 3434626
				hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
				l_proc_step := 40;
--	End of bug fix 3434626

				/* Insert assignments (exists in psp_enc_lines_history and poeta dates are
				changed) into psp_enc_changed_assignments table	*/
				IF r_asg_id_array.r_asg_id.count<>0 THEN
					insert_changed_assignments	(p_change_type =>	'PT',
						p_return_status =>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
				END IF;
			END IF;
		ELSE
			IF (p_pre_process_mode = 'R') THEN
--	Introduced for bug fix 3434626
				l_proc_step := 50;
--	End of bug fix 3434626

				IF r_susp_control_rec.r_project_id(i) <> l_prev_tx_project_id THEN
					validate_transaction_controls
						(p_project_id	=>	r_susp_control_rec.r_project_id(i),
						p_payroll_id	=>	p_payroll_id,
						p_return_status	=>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
					l_prev_tx_project_id := r_susp_control_rec.r_project_id(i);
				END IF;
			END IF;
		END IF;
	END LOOP;

--	Introduced for bug fix 3434626
	l_proc_step := 60;
--	End of bug fix 3434626

	/* Updating poeta dates in psp_organization_accounts */
	FORALL i IN 1 .. g_total_num_rec
	UPDATE	psp_organization_accounts
	SET	poeta_end_date = r_susp_control_rec.r_poeta_end_date(i),
		poeta_start_date = r_susp_control_rec.r_poeta_start_date(i)
	WHERE	organization_account_id = r_susp_control_rec.r_organization_account_id(i);

	p_return_status := fnd_api.g_ret_sts_success;

--	Introduced for bug fix 3434626
	l_proc_step := 70;
	hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := SUBSTR('UPDT_DFLT_SSP_ACCNT:'||g_error_api_path,1,30);
                 -- bug fix 2597666
		p_return_status := fnd_api.g_ret_sts_unexp_error;
--	Introduced for bug fix 3434626
		hr_utility.trace(fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
END update_default_susp_accounts;

/****************************************************************************************************
	Procedure Name:	VALIDATE_POETA
	Purpose:	This procedure is used to perform date invariant and date variant validations
			on poeta. After validation it fetches correct poeta start and end date that
			is made use of by other procedures to update respective schedule lines.
			Further certain date variant checks are taken care by date invariant
			validations.

	Additional Information:
		Project_info_cur takes care of project - task link, project status, chargeable_flag etc.
		Award_info_cur takes care of award and project link, award is active and other
			award related validations
		Expenditure_type_info_cur takes care of validation for expenditure types
		Exp_org_cur takes care of expenditure organization validations
****************************************************************************************************/

PROCEDURE validate_poeta	(p_project_id			IN	NUMBER,
				p_task_id			IN	NUMBER,
				p_award_id			IN	NUMBER,
				p_expenditure_type		IN	VARCHAR2,
				p_expenditure_organization_id	IN	NUMBER,
				p_payroll_id			IN	NUMBER,
				p_start_date			OUT NOCOPY	DATE,
				p_end_date			OUT NOCOPY	DATE,
				p_return_status			OUT NOCOPY	VARCHAR2)
IS
l_proj_start_date	DATE DEFAULT fnd_date.canonical_to_date('1800/01/01');
l_proj_end_date		DATE DEFAULT fnd_date.canonical_to_date('4712/12/31');
l_task_start_date	DATE DEFAULT fnd_date.canonical_to_date('1800/01/01');
l_task_end_date		DATE DEFAULT fnd_date.canonical_to_date('4712/12/31');
l_award_start_date	DATE DEFAULT fnd_date.canonical_to_date('1800/01/01');
l_award_end_date	DATE DEFAULT fnd_date.canonical_to_date('4712/12/31');
l_exp_type_start_date	DATE DEFAULT fnd_date.canonical_to_date('1800/01/01');
l_exp_type_end_date	DATE DEFAULT fnd_date.canonical_to_date('4712/12/31');
l_exp_org_start_date	DATE DEFAULT fnd_date.canonical_to_date('1800/01/01');
l_exp_org_end_date	DATE DEFAULT fnd_date.canonical_to_date('4712/12/31');
l_allowable_schedule_id	NUMBER(15);
l_proj_status_code	VARCHAR2(30);
l_enabled_flag		VARCHAR2(1);
l_enc_cr_date		DATE;
l_exp_type		VARCHAR2(30);
l_labor_enc_start_date	DATE;
l_labor_enc_end_date	DATE;

/* Cursor is used to fetch project and task dates and to validate project and task*/
CURSOR	project_info_cur IS
SELECT	ppa.project_status_code,
	NVL(ppa.start_date, TO_DATE('1800/01/01', 'YYYY/MM/DD')),
	NVL(ppa.completion_date, TO_DATE('4712/12/31', 'YYYY/MM/DD')),
	NVL(pt.start_date, TO_DATE('1800/01/01', 'YYYY/MM/DD')),
	NVL(pt.completion_date, TO_DATE('4712/12/31', 'YYYY/MM/DD'))
FROM	pa_tasks pt,
	pa_projects_all ppa
WHERE	pt.task_id = p_task_id
AND	ppa.project_id = pt.project_id
AND	ppa.project_id = p_project_id
AND	ppa.project_status_code <> 'CLOSED'
AND	pt.chargeable_flag = 'Y';

/* Cursor is used to fetch award dates and to validate award */
CURSOR	award_info_cur IS
SELECT	NVL(gaw.preaward_date, NVL(gaw.start_date_active, TO_DATE('1800/01/01', 'YYYY/MM/DD'))),
	NVL(gaw.end_date_active, TO_DATE('4712/12/31', 'YYYY/MM/DD')),
	allowable_schedule_id
FROM	gms_awards_all gaw,  --6957888
	gms_summary_project_fundings gspf,
	gms_installments gi,
	gms_budget_versions gbv,
	pa_tasks pt
WHERE	gaw.award_id = p_award_id
AND	gbv.project_id = p_project_id
AND	pt.task_id = p_task_id
AND	gbv.budget_status_code = 'B'
AND	gaw.status <>'CLOSED'
AND	gspf.project_id = gbv.project_id
AND	((gspf.task_id = pt.task_id) OR (gspf.task_id IS NULL) OR (gspf.task_id = pt.top_task_id))
AND	gi.installment_id = gspf.installment_id
AND	gi.award_id = gaw.award_id
AND	gaw.award_template_flag = 'DEFERRED';

/* Cursor is used to fetch expenditure type date and to validate expenditure type */
CURSOR	expenditure_type_info_cur IS
SELECT	NVL(pet.start_date_active, TO_DATE('1800/01/01', 'YYYY/MM/DD')),
	NVL(pet.end_date_active, TO_DATE('4712/12/31', 'YYYY/MM/DD'))
FROM	gms_allowable_expenditures gae,
	pa_expenditure_types pet
WHERE	pet.expenditure_type = p_expenditure_type
AND	gae.expenditure_type = pet.expenditure_type
AND	gae.allowability_schedule_id = l_allowable_schedule_id;

/* Cursor is used to fetch exp org date and to validate exp org	*/
CURSOR	exp_org_cur IS
SELECT	NVL(poe.date_from, TO_DATE('1800/01/01', 'YYYY/MM/DD')),
	NVL(poe.date_to, TO_DATE('4712/12/31', 'YYYY/MM/DD'))
FROM	pa_organizations_expend_v poe
WHERE	poe.organization_id = p_expenditure_organization_id;

/* Cursor to validate enabled_flag from pa_project_status_controls */
CURSOR	project_status_csr IS
SELECT	ppsc.enabled_flag
FROM	pa_project_status_controls ppsc
WHERE	ppsc.project_status_code = l_proj_status_code
AND	ppsc.action_code = 'NEW_TXNS';

--	Introduced for bug fix 3434626
l_proc_name		VARCHAR2(61)	DEFAULT g_package_name || 'VALIDATE_POETA';
l_proc_step		NUMBER(20, 10)	DEFAULT 0;
--	End of changes for bug fix 3434626
BEGIN
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Entering ' || l_proc_name);
	hr_utility.trace('p_project_id: ' || fnd_number.number_to_canonical(p_project_id) ||
		' p_award_id: ' || fnd_number.number_to_canonical(p_award_id) ||
		' p_task_id: ' || fnd_number.number_to_canonical(p_task_id) ||
		' p_expenditure_organization_id: ' || fnd_number.number_to_canonical(p_expenditure_organization_id) ||
		' p_expenditure_type: ' || p_expenditure_type ||
		' p_payroll_id: ' || fnd_number.number_to_canonical(p_payroll_id) ||
		' p_start_date: ' || fnd_date.date_to_canonical(p_start_date) ||
		' p_end_date: ' || fnd_date.date_to_canonical(p_end_date));

	l_proc_step := 10;
--	End of bug fix 3434626

	p_return_status := fnd_api.g_ret_sts_success;
	OPEN project_info_cur ;
	FETCH project_info_cur into l_proj_status_code,
		l_proj_start_date,l_proj_end_date,l_task_start_date,l_task_end_date;
	IF project_info_cur%NOTFOUND THEN
		p_start_date := fnd_date.canonical_to_date('1800/01/01');
		p_end_date := fnd_date.canonical_to_date('1800/01/31');
		CLOSE project_info_cur;
--	Introduced the following for bug fix 3434626
		hr_utility.trace('p_start_date: ' || fnd_date.date_to_canonical(p_start_date) ||
			' p_end_date: ' || fnd_date.date_to_canonical(p_end_date));

		l_proc_step := 20;
--	End of bug fix 3434626

		RETURN;
	END IF;
	CLOSE project_info_cur;

--	Introduced the following for bug fix 3434626
	l_proc_step := 30;
--	End of bug fix 3434626

	/*Validation for enabled_flag */
	OPEN project_status_csr;
	FETCH project_status_csr INTO l_enabled_flag;
	IF (project_status_csr %NOTFOUND) OR (l_enabled_flag = 'N') THEN
		p_start_date := fnd_date.canonical_to_date('1800/01/01');
		p_end_date := fnd_date.canonical_to_date('1800/01/31');
		CLOSE project_status_csr;
--	Introduced the following for bug fix 3434626
		hr_utility.trace('p_start_date: ' || fnd_date.date_to_canonical(p_start_date) ||
			' p_end_date: ' || fnd_date.date_to_canonical(p_end_date));

		l_proc_step := 40;
--	End of bug fix 3434626

		RETURN;
	END IF;
	CLOSE project_status_csr;

--	Introduced the following for bug fix 3434626
	l_proc_step := 50;
--	End of bug fix 3434626

	OPEN award_info_cur;
	FETCH award_info_cur into l_award_start_date,l_award_end_date,l_allowable_schedule_id;
	IF award_info_cur%NOTFOUND then
		p_start_date := fnd_date.canonical_to_date('1800/01/01');
		p_end_date := fnd_date.canonical_to_date('1800/01/31');
		CLOSE award_info_cur;
--	Introduced the following for bug fix 3434626
	hr_utility.trace('p_start_date: ' || fnd_date.date_to_canonical(p_start_date) ||
		' p_end_date: ' || fnd_date.date_to_canonical(p_end_date));

	l_proc_step := 60;
--	End of bug fix 3434626

		RETURN;
	END IF;
	CLOSE award_info_cur;

--	Introduced the following for bug fix 3434626
	l_proc_step := 70;
--	End of bug fix 3434626

	OPEN expenditure_type_info_cur;
	FETCH expenditure_type_info_cur into l_exp_type_start_date,l_exp_type_end_date;
	IF expenditure_type_info_cur %NOTFOUND THEN
		p_start_date := fnd_date.canonical_to_date('1800/01/01');
		p_end_date := fnd_date.canonical_to_date('1800/01/31');
		CLOSE expenditure_type_info_cur;
		RETURN;
--	Introduced the following for bug fix 3434626
	hr_utility.trace('p_start_date: ' || fnd_date.date_to_canonical(p_start_date) ||
		' p_end_date: ' || fnd_date.date_to_canonical(p_end_date));

	l_proc_step := 80;
--	End of bug fix 3434626

	END IF;
	CLOSE expenditure_type_info_cur;

--	Introduced the following for bug fix 3434626
	l_proc_step := 90;
--	End of bug fix 3434626

	OPEN exp_org_cur;
	FETCH exp_org_cur into l_exp_org_start_date,l_exp_org_end_date;
	IF exp_org_cur% NOTFOUND THEN
		p_start_date := fnd_date.canonical_to_date('1800/01/01');
		p_end_date := fnd_date.canonical_to_date('1800/01/31');
		CLOSE exp_org_cur;
--	Introduced the following for bug fix 3434626
	hr_utility.trace('p_start_date: ' || fnd_date.date_to_canonical(p_start_date) ||
		' p_end_date: ' || fnd_date.date_to_canonical(p_end_date));

	l_proc_step := 100;
--	End of bug fix 3434626

		RETURN;
	END IF;
	CLOSE exp_org_cur;

--	Introduced the following for bug fix 3434626
	l_proc_step := 110;
--	End of bug fix 3434626

	psp_st_ext.get_labor_enc_dates(p_project_id,
				p_task_id,
				p_award_id,
				p_expenditure_type,
				p_expenditure_organization_id,
				p_payroll_id,
				l_labor_enc_start_date,
				l_labor_enc_end_date);
	l_labor_enc_start_date := NVL(l_labor_enc_start_date, fnd_date.canonical_to_date('1800/01/01'));
	l_labor_enc_end_date := NVL(l_labor_enc_end_date, fnd_date.canonical_to_date('4712/12/31'));
	hr_utility.trace('l_labor_enc_start_date: ' || fnd_date.date_to_canonical(l_labor_enc_start_date) ||
		' l_labor_enc_end_date: ' || fnd_date.date_to_canonical(l_labor_enc_end_date));

	p_end_date := LEAST	(l_proj_end_date,
				l_task_end_date,
				l_award_end_date,
				l_exp_type_end_date,
				l_exp_org_end_date,
				l_labor_enc_end_date);
	p_start_date := GREATEST	(l_proj_start_date,
					l_task_start_date,
					l_award_start_date,
					l_exp_type_start_date,
					l_exp_org_start_date,
					l_labor_enc_start_date);

--	Introduced the following for bug fix 3434626
	hr_utility.trace('p_start_date: ' || fnd_date.date_to_canonical(p_start_date) ||
		' p_end_date: ' || fnd_date.date_to_canonical(p_end_date));

	l_proc_step := 120;
--	End of bug fix 3434626

	p_return_status := fnd_api.g_ret_sts_success;

--	Introduced for bug fix 3434626
	hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := SUBSTR('VALIDATE_POETA:'||g_error_api_path,1,30);
                 -- bug fix 2597666
		p_return_status := fnd_api.g_ret_sts_unexp_error;
--	Introduced for bug fix 3434626
		hr_utility.trace(fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		hr_utility.trace('Leaving ' || l_proc_name);
--	End of bug fix 3434626
END validate_poeta;

/****************************************************************************************************
	Procedure Name:	VALIDATE_TRANSACTION_CONTROLS
	Purpose:	This Procedure is used to log assignments for those records which modified in
			pa_transaction_controls after the last creation date of encumbrance for a
			payroll.
****************************************************************************************************/

PROCEDURE validate_transaction_controls	(p_project_id	IN	NUMBER,
					p_payroll_id	IN	NUMBER,
					p_return_status OUT NOCOPY	VARCHAR2)
IS

l_enc_cr_date		DATE;

/*CURSOR for selecting maximum creation date from psp_enc_controls for which lines are not liquidated*/
CURSOR	max_create_dt_cur IS
SELECT	max(pec.creation_date)
FROM	PSP_ENC_CONTROLS pec
WHERE	pec.payroll_id = p_payroll_id
AND	pec.action_code IN ('I', 'N', 'P');	-- Replaced <> 'L' with IN clause for bug fix 3099540

/* CURSOR to verify modification in pa_trancation_controls after the last creation date */
CURSOR	patc_change_cur IS
SELECT	patc.project_id
FROM	pa_transaction_controls patc
WHERE	patc.project_id = p_project_id
AND	patc.last_update_date > l_enc_cr_date
AND	rownum = 1;

/*	CURSOR to find all assignments that were modified after last enc creation date in
	pa_transaction_controls	*/
CURSOR	tx_control_asg_cur IS
SELECT	pelh.assignment_id, p_payroll_id
FROM	psp_enc_lines_history pelh
WHERE	pelh.project_id = p_project_id
AND	pelh.payroll_id = p_payroll_id
AND     pelh.change_flag = 'N' --Added for bug 2334434
GROUP BY pelh.assignment_id,p_payroll_id;

l_project_id	NUMBER(10);

--	Introduced for bug fix 3434626
l_proc_name		VARCHAR2(61)	DEFAULT g_package_name || 'VALIDATE_TRANSACTION_CONTROLS';
l_proc_step		NUMBER(20, 10)	DEFAULT 0;
--	End of changes for bug fix 3434626

BEGIN
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Entering ' || l_proc_name);
	hr_utility.trace('p_project_id: ' || fnd_number.number_to_canonical(p_project_id) ||
		' p_payroll_id: ' || fnd_number.number_to_canonical(p_payroll_id));

        l_proc_step := 10;
--      End of bug fix 3434626

	/* Opening the cursor to fetch maximum creation date for a particular payroll for which
	lines are not liquidated */
	OPEN max_create_dt_cur;
	FETCH max_create_dt_cur INTO l_enc_cr_date;
	CLOSE max_create_dt_cur;

--	Introduced the following for bug fix 3434626
	hr_utility.trace('l_enc_cr_date: ' || fnd_date.date_to_canonical(l_enc_cr_date));

        l_proc_step := 20;
--      End of bug fix 3434626

	/* All the assignments for which records are modified in pa_transaction_controls after the
	last creation date will logged into psp_enc_changed_assignments for a particular payroll; */

	IF l_enc_cr_date IS NOT NULL THEN
		OPEN patc_change_cur;
		FETCH patc_change_cur INTO l_project_id;
		CLOSE patc_change_cur;

--	Introduced the following for bug fix 3434626
		hr_utility.trace('l_project_id: ' || fnd_number.number_to_canonical(l_project_id));

        	l_proc_step := 30;
--      End of bug fix 3434626

		IF l_project_id IS NOT NULL THEN
			OPEN tx_control_asg_cur;
			FETCH tx_control_asg_cur BULK COLLECT INTO r_asg_id_array.r_asg_id,
				r_asg_id_array.r_payroll_id;
			CLOSE tx_control_asg_cur;

--	Introduced the following for bug fix 3434626
			hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));

        		l_proc_step := 40;
--      End of bug fix 3434626

			IF r_asg_id_array.r_asg_id.count<>0 THEN
				insert_changed_assignments	(p_change_type =>	'TC',
					p_return_status =>	p_return_status);
				IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;
			END IF;
		END IF;
	END IF;

--	Introduced the following for bug fix 3434626
	l_proc_step := 50;
--	End of bug fix 3434626

	p_return_status := fnd_api.g_ret_sts_success;

--	Introduced the following for bug fix 3434626
	hr_utility.trace('Leaving ' || l_proc_name);
--      End of bug fix 3434626

EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := SUBSTR('VLDT_TRNSCTN_CNTRLS:'||g_error_api_path,1,30);
                 -- bug fix 2597666
		p_return_status := fnd_api.g_ret_sts_unexp_error;
--      Introduced the following for bug fix 3434626
               	hr_utility.trace(fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		hr_utility.trace('Leaving ' || l_proc_name);
--      End of changed for bug fix 3434626
END validate_transaction_controls;

/****************************************************************************************************
	Procedure Name:	INSERT_CHANGED_ASSIGNMENTS
	Purpose:	This Procedure inserts identified assignments into psp_enc_changed_assignments
			table.
****************************************************************************************************/

PROCEDURE insert_changed_assignments	(p_change_type	IN	VARCHAR2,
					p_reference_id	IN	NUMBER		DEFAULT	NULL,
					p_action_type	IN	VARCHAR2	DEFAULT	NULL,
					p_return_status	OUT NOCOPY	VARCHAR2)
IS
--	Introduced for bug fix 3434626
l_proc_name		VARCHAR2(61)	DEFAULT g_package_name || 'INSERT_CHANGED_ASSIGNMENTS';
l_proc_step		NUMBER(20, 10)	DEFAULT 10;
--	End of changes for bug fix 3434626
BEGIN
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Entering ' || l_proc_name);
	hr_utility.trace('p_change_type ' || p_change_type || ' p_action_type ' || p_action_type ||
		' p_reference_id: ' || fnd_number.number_to_canonical(p_reference_id) ||
		' r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

	FORALL k in 1 .. r_asg_id_array.r_asg_id.count
	INSERT INTO PSP_ENC_CHANGED_ASSIGNMENTS
		(request_id, assignment_id, payroll_id,
		change_type, processed_flag, reference_id, action_type)
	VALUES	(g_request_id, r_asg_id_array.r_asg_id(k), r_asg_id_array.r_payroll_id(k),
		p_change_type, NULL, p_reference_id, p_action_type);

	r_asg_id_array.r_asg_id.delete; -- clear the array
	r_asg_id_array.r_payroll_id.delete;

	p_return_status := fnd_api.g_ret_sts_success;
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Leaving ' || l_proc_name);
--	End of changed for bug fix 3434626
EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := SUBSTR('INSERT_CHANGED_ASSIGNMENTS:'||g_error_api_path,1,30);
                 -- bug fix 2597666
		p_return_status := fnd_api.g_ret_sts_unexp_error;
--	Introduced the following for bug fix 3434626
		hr_utility.trace(fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		hr_utility.trace('Leaving ' || l_proc_name);
--	End of changed for bug fix 3434626
END insert_changed_assignments;

/****************************************************************************************************
	Procedure Name:	LABOR_SCHEDULE_PRE_PROCESS
	Purpose:	This procedure identifies the assignments that have to be processed during the
			Update run because of the changes in LS other than employee level and as well
			as in Enumbrance Payroll selection, Element selection forms.
****************************************************************************************************/

PROCEDURE labor_schedule_pre_process	(p_enc_line_type	IN	VARCHAR2,
					p_payroll_id		IN	NUMBER,
					p_return_status		OUT NOCOPY	VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_generic_suspense	NUMBER(15) DEFAULT fnd_profile.value('PSP_GLOBAL_SUSP_ACC_ORG');
l_default_account	VARCHAR2(15) DEFAULT fnd_profile.value('PSP_DEFAULT_ACCOUNT');
l_default_schedule	VARCHAR2(15) DEFAULT fnd_profile.value('PSP_DEFAULT_SCHEDULE');

TYPE v_reference_id IS TABLE OF NUMBER(15);
TYPE v_reference_field IS TABLE OF VARCHAR2(30);
TYPE v_change_type IS TABLE OF VARCHAR2(2);
TYPE v_action_type IS TABLE OF VARCHAR2(2);
TYPE reference_id_array is RECORD
	(r_reference_id		v_reference_id,
	r_reference_field	v_reference_field,
	r_change_type		v_change_type,
	r_action_type		v_action_type);
r_reference_id_array	reference_id_array;

/*	Following cursor finds out NOCOPY the distinct set of changes	*/
CURSOR	enc_changed_schedule_cur IS
SELECT	DISTINCT reference_id,
	pecs.reference_field,
	pecs.change_type,
	DECODE(action_type, 'D', 'U', action_type) action_type
FROM	psp_enc_changed_schedules pecs;

/*	Following cursor finds out NOCOPY assignments affected by changes to Org Default LS	*/
CURSOR	assignment_payroll_ds_upd_cur(p_reference_id NUMBER) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh
WHERE	pelh.change_flag  = 'N'
AND	pelh.org_schedule_id = p_reference_id;

/*	Following cursor finds out NOCOPY assignments affected by changes to Org Default Account	*/
CURSOR	assignment_payroll_da_upd_cur (p_reference_id NUMBER) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh
WHERE	pelh.default_org_account_id = p_reference_id
AND	pelh.change_flag  = 'N' ; --Added for bug 2334434;

/*	Following cursor finds out NOCOPY assignments affected by changes to Org Suspense Account
	Same query is used for GS updates, hence this cursor will be reused	*/
CURSOR	assignment_payroll_sa_upd_cur (p_reference_id NUMBER) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh
WHERE	pelh.change_flag  = 'N'
AND	pelh.suspense_org_account_id = p_reference_id;

/*	Following cursor finds out NOCOPY assignments affected by changes to Global Earning Elements	*/
CURSOR	assignment_payroll_ge_upd_cur (p_reference_id NUMBER) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh
WHERE	pelh.change_flag  = 'N'
AND	pelh.element_account_id = p_reference_id;

/*	Following cursor finds out NOCOPY assignments affected by changes to Enc Payroll Assignments	*/
CURSOR	assignment_payroll_ex_upd_cur (p_reference_id NUMBER) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh
WHERE	pelh.change_flag  = 'N'
AND	pelh.assignment_id = p_reference_id;

/*	Following cursor finds out NOCOPY impacted assignments for new Global Earning Elements	*/
CURSOR	global_element_insert_cur (p_reference_id NUMBER) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh
WHERE	pelh.enc_element_type_id = p_reference_id
AND	pelh.element_account_id IS NULL
AND	pelh.change_flag  = 'N';

/*	Following cursor finds all assignments impacted because of Org. Default LS Inserts	*/
CURSOR	org_ds_insert_cur (p_reference_id NUMBER) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh,
	per_assignments_f paf
WHERE	pelh.schedule_line_id IS NULL
AND	pelh.element_account_id IS NULL
AND	pelh.change_flag  = 'N'
AND	pelh.assignment_id = paf.assignment_id
AND	paf.organization_id = p_reference_id
/* Following code is modified for bug 2345584 */
AND	(default_reason_code IN(3,1)
	OR	suspense_reason_code IN('LDM_NO_CI_FOUND','LDM_BAL_NOT_100_PERCENT'));

/*	Following cursor would identify assignments impacted by Org. Default Account Inserts	*/
CURSOR	org_da_insert_cur (p_reference_id NUMBER) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh,
	per_assignments_f paf
WHERE	pelh.suspense_org_account_id IS NOT NULL
AND	pelh.suspense_reason_code IN ('LDM_NO_CI_FOUND', 'LDM_BAL_NOT_100_PERCENT')
AND	paf.organization_id = p_reference_id
AND	pelh.assignment_id = paf.assignment_id
AND	pelh.change_flag  = 'N';

/*	Following cursor finds out NOCOPY assignments impacted because of Org. Suspense Accounts	*/
CURSOR	org_sa_insert_cur (p_reference_id NUMBER) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh,
	per_assignments_f paf,
	psp_organization_accounts poa
WHERE	pelh.suspense_org_account_id = poa.organization_account_id
AND	poa.organization_id = l_generic_suspense
AND	pelh.change_flag  = 'N'
AND	pelh.assignment_id = paf.assignment_id
AND	paf.organization_id = p_reference_id;

--	Introduced the following for bug fix 3426871
l_period_end_date	DATE;
l_prev_enc_end_date	DATE;

CURSOR	default_end_date_cur (p_reference_id IN NUMBER) IS
SELECT	period_end_date,
	prev_enc_end_date
FROM	psp_enc_end_dates peed
WHERE	peed.enc_end_date_id = p_reference_id;

CURSOR	default_end_date_dec_cur IS
SELECT	DISTINCT
	assignment_id,
	payroll_id
FROM	psp_enc_lines_history pelh
--	psp_enc_end_dates peed			Commented for bug fix 4507892
WHERE	pelh.change_flag = 'N'
AND	pelh.encumbrance_date > l_period_end_date;
--	End of bug fix 3426871

/*	Following cursor finds out NOCOPY assignments affected by Default Org. End Date changes	*/
--CURSOR	default_org_end_date_asg_cur (p_reference_id NUMBER) IS		Commented for bug fix 3426871
--	Removed p_reference_id  for bug fix 3426871
CURSOR	default_org_end_date_asg_cur IS
SELECT	DISTINCT	--Added distinct for bug 2664991.
	pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh,
	psp_default_labor_schedules pdls,
	psp_schedule_lines psl,
	psp_element_type_accounts peta,
	per_assignments_f paf
--	psp_enc_end_dates peed			Commented for bug fix 3426871
--WHERE	peed.enc_end_date_id = p_reference_id	Commented for bug fix 3426871
WHERE	pelh.assignment_id = paf.assignment_id
AND	pelh.change_flag  = 'N'
AND	pelh.gl_code_combination_id IS NULL
AND	pelh.encumbrance_date = (SELECT MIN(pelhin.encumbrance_date)
				FROM	psp_enc_lines_history pelhin
				WHERE	pelhin.assignment_id = pelh.assignment_id
--				AND	pelhin.encumbrance_date > peed.period_end_date)
--				AND	pelhin.encumbrance_date > peed.prev_enc_end_date) --Added for bug 2396983. Commented for bug 3426871
				AND	pelhin.encumbrance_date > l_prev_enc_end_date) --	Introduced for bug fix 3426871
AND	pelh.org_schedule_id = pdls.org_schedule_id (+)
AND	pelh.element_account_id = peta.element_account_id (+)
AND	pelh.schedule_line_id = psl.schedule_line_id (+)
AND	pelh.encumbrance_date BETWEEN paf.effective_start_date AND paf.effective_end_date  --Added for Bug 2675446
GROUP BY pelh.assignment_id, pelh.payroll_id,
	 pelh.enc_element_type_id --Added for bug 2664991.
HAVING	SUM(NVL(pdls.schedule_percent, 0) + NVL(psl.schedule_percent, 0) + NVL(peta.percent, 0)) <> 100
AND	SUM(NVL(pdls.schedule_percent, 0) + NVL(psl.schedule_percent, 0) + NVL(peta.percent, 0)) > 0;

--For Bug fix 2370841:Following cursor finds out NOCOPY assignments affected by Enc element Selection changes
CURSOR	element_ed_ins_upd_cur (p_reference_id NUMBER) IS
SELECT	DISTINCT pelh.assignment_id,
	pelh.payroll_id
FROM	psp_enc_lines_history pelh
WHERE	pelh.change_flag  = 'N'
AND	pelh.enc_element_type_id = p_reference_id;
--End of bug fix 2370841

--	Introduced for bug fix 3434626
l_proc_name		VARCHAR2(61)	DEFAULT g_package_name || 'LABOR_SCHEDULE_PRE_PROCESS';
l_proc_step		NUMBER(20, 10)	DEFAULT 0;
--	End of changes for bug fix 3434626
BEGIN
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Entering ' || l_proc_name);
	hr_utility.trace('p_enc_line_type: ' || p_enc_line_type || ' p_payroll_id: ' || fnd_number.number_to_canonical(p_payroll_id));

	l_proc_step := 10;
--      End of bug fix 3434626

	IF (p_enc_line_type = 'Q') THEN
		UPDATE	psp_enc_changed_assignments peca
		SET	request_id	=	g_request_id
		WHERE	peca.payroll_id = p_payroll_id
		AND	change_type IN ('AS', 'ET', 'LS', 'QU');

		p_return_status := fnd_api.g_ret_sts_success;
--	Introduced the following for bug fix 3434626
		hr_utility.trace('Leaving: ' || l_proc_name);
--	End of changed for bug fix 3434626

		RETURN;
	ELSE
		UPDATE	psp_enc_changed_assignments peca
		SET	request_id = g_request_id
		WHERE	peca.payroll_id = p_payroll_id;

--	Introduced the following for bug fix 3434626
		l_proc_step := 20;
--	End of bug fix 3434626
	END IF;

--	Introduced the following for bug fix 3434626
	l_proc_step := 30;
--	End of bug fix 3434626

	OPEN enc_changed_schedule_cur;
	FETCH enc_changed_schedule_cur
		BULK COLLECT INTO r_reference_id_array.r_reference_id,
		r_reference_id_array.r_reference_field, r_reference_id_array.r_change_type,
		r_reference_id_array.r_action_type;
	CLOSE enc_changed_schedule_cur;

--	Introduced the following for bug fix 3434626
	hr_utility.trace('r_reference_id_array.r_reference_id.COUNT: ' || fnd_number.number_to_canonical(r_reference_id_array.r_reference_id.COUNT));

	l_proc_step := 40;
--      End of bug fix 3434626

	FOR I in 1 .. r_reference_id_array.r_reference_id.COUNT
	LOOP
--	Introduced the following for bug fix 3434626
		hr_utility.trace('I: ' || fnd_number.number_to_canonical(I) ||
			' r_reference_id_array.r_reference_id(I): ' || fnd_number.number_to_canonical(r_reference_id_array.r_reference_id(I)) ||
			' r_reference_id_array.r_reference_field(I): ' || r_reference_id_array.r_reference_field(I) ||
			' r_reference_id_array.r_change_type(I): ' || r_reference_id_array.r_change_type(I) ||
			' r_reference_id_array.r_action_type(I): ' || r_reference_id_array.r_action_type(I));

		l_proc_step := 50 + (I/100000);
--      End of bug fix 3434626

/*		Verifying assignments affected by Org Default Account Changes	*/
		IF (r_reference_id_array.r_change_type(i) = 'DA') AND
			(r_reference_id_array.r_action_type(i) = 'U') THEN
			l_proc_step := 60 + (I/100000);		-- Introduced for bug fix 3434626

			IF (l_default_account = 'Y') THEN
				OPEN assignment_payroll_da_upd_cur(r_reference_id_array.r_reference_id(i));
					FETCH assignment_payroll_da_upd_cur
					BULK COLLECT INTO r_asg_id_array.r_asg_id, r_asg_id_array.r_payroll_id;
					CLOSE assignment_payroll_da_upd_cur;

--	Introduced the following for bug fix 3434626
					hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

					insert_changed_assignments(p_change_type =>	'DA',
						p_reference_id	=>	r_reference_id_array.r_reference_id(i),
						p_action_type	=>	r_reference_id_array.r_action_type(i),
						p_return_status	=>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE fnd_api.g_exc_unexpected_error;
					END IF;
			END IF;
/*		Verifying Org. Default Account Inserts	*/
		ELSIF (r_reference_id_array.r_change_type(i) = 'DA') AND
			(r_reference_id_array.r_action_type(i) = 'I') THEN
			l_proc_step := 70 + (I/100000);		-- Introduced for bug fix 3434626

			IF (l_default_account = 'Y') THEN
				OPEN org_da_insert_cur(r_reference_id_array.r_reference_id(i));
					FETCH org_da_insert_cur
						BULK COLLECT INTO r_asg_id_array.r_asg_id,
						r_asg_id_array.r_payroll_id;
				CLOSE org_da_insert_cur;

--	Introduced the following for bug fix 3434626
				hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

					insert_changed_assignments(p_change_type =>	'DA',
						p_reference_id	=>	r_reference_id_array.r_reference_id(i),
						p_action_type	=>	r_reference_id_array.r_action_type(i),
						p_return_status	=>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE fnd_api.g_exc_unexpected_error;
					END IF;
			END IF;

/*		Verifying assignments affected by Org Suspense Account Changes
		This section also takes care of GS updates	*/
		ELSIF (r_reference_id_array.r_change_type(i) IN ('GS', 'SA')) AND
			(r_reference_id_array.r_action_type(i) = 'U') THEN
			l_proc_step := 80 + (I/100000);		-- Introduced for bug fix 3434626
			OPEN assignment_payroll_sa_upd_cur(r_reference_id_array.r_reference_id(i));
				FETCH assignment_payroll_sa_upd_cur
					BULK COLLECT INTO r_asg_id_array.r_asg_id,
					r_asg_id_array.r_payroll_id;
			CLOSE assignment_payroll_sa_upd_cur;

--	Introduced the following for bug fix 3434626
			hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

				insert_changed_assignments(p_change_type =>	r_reference_id_array.r_change_type(i),
					p_reference_id	=>	r_reference_id_array.r_reference_id(i),
					p_action_type	=>	r_reference_id_array.r_action_type(i),
					p_return_status	=>	p_return_status);
				IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
					RAISE fnd_api.g_exc_unexpected_error;
				END IF;

/*		Verifying Org. Suspense Account Inserts	*/
		ELSIF (r_reference_id_array.r_change_type(i) = 'SA') AND
			(r_reference_id_array.r_action_type(i) = 'I') THEN
			l_proc_step := 90 + (I/100000);		-- Introduced for bug fix 3434626
			OPEN org_sa_insert_cur(r_reference_id_array.r_reference_id(i));
				FETCH org_sa_insert_cur
					BULK COLLECT INTO r_asg_id_array.r_asg_id,
					r_asg_id_array.r_payroll_id;
			CLOSE org_sa_insert_cur;

--	Introduced the following for bug fix 3434626
			hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

				insert_changed_assignments(p_change_type =>	'SA',
					p_reference_id	=>	r_reference_id_array.r_reference_id(i),
					p_action_type	=>	r_reference_id_array.r_action_type(i),
					p_return_status	=>	p_return_status);
				IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
					RAISE fnd_api.g_exc_unexpected_error;
				END IF;

/*		Verifying assignments affected by Org Default LS Changes	*/
		ELSIF (r_reference_id_array.r_change_type(i) = 'DS') AND
			(r_reference_id_array.r_action_type(i) = 'U') THEN
			l_proc_step := 100 + (I/100000);		-- Introduced for bug fix 3434626
			IF (l_default_schedule = 'Y') THEN
				OPEN assignment_payroll_ds_upd_cur(r_reference_id_array.r_reference_id(i));
					FETCH assignment_payroll_ds_upd_cur
						BULK COLLECT INTO r_asg_id_array.r_asg_id,
						r_asg_id_array.r_payroll_id;
				CLOSE assignment_payroll_ds_upd_cur;
--	Introduced the following for bug fix 3434626
			hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

					insert_changed_assignments(p_change_type =>	'DS',
						p_reference_id	=>	r_reference_id_array.r_reference_id(i),
						p_action_type	=>	r_reference_id_array.r_action_type(i),
						p_return_status	=>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE fnd_api.g_exc_unexpected_error;
					END IF;
			END IF;

/*		Verifying Org Default LS Inserts	*/
		ELSIF (r_reference_id_array.r_change_type(i) = 'DS') AND
			(r_reference_id_array.r_action_type(i) = 'I') THEN
			IF (l_default_schedule = 'Y') THEN
			l_proc_step := 110 + (I/100000);		-- Introduced for bug fix 3434626
				OPEN org_ds_insert_cur(r_reference_id_array.r_reference_id(i));
					FETCH org_ds_insert_cur
						BULK COLLECT INTO r_asg_id_array.r_asg_id,
						r_asg_id_array.r_payroll_id;
				CLOSE org_ds_insert_cur;

--	Introduced the following for bug fix 3434626
				hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

					insert_changed_assignments(p_change_type =>	'DS',
						p_reference_id	=>	r_reference_id_array.r_reference_id(i),
						p_action_type	=>	r_reference_id_array.r_action_type(i),
						p_return_status	=>	p_return_status);
					IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
						RAISE fnd_api.g_exc_unexpected_error;
					END IF;
			END IF;

/*		Verifying assignments affected by Global Earning Elements Changes	*/
		ELSIF (r_reference_id_array.r_change_type(i) = 'GE') AND
			(r_reference_id_array.r_action_type(i) = 'U') THEN
			l_proc_step := 120 + (I/100000);		-- Introduced for bug fix 3434626
			OPEN assignment_payroll_ge_upd_cur(r_reference_id_array.r_reference_id(i));
				FETCH assignment_payroll_ge_upd_cur
					BULK COLLECT INTO r_asg_id_array.r_asg_id,
					r_asg_id_array.r_payroll_id;
			CLOSE assignment_payroll_ge_upd_cur;
--	Introduced the following for bug fix 3434626
			hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

				insert_changed_assignments(p_change_type =>	'GE',
					p_reference_id	=>	r_reference_id_array.r_reference_id(i),
					p_action_type	=>	r_reference_id_array.r_action_type(i),
					p_return_status	=>	p_return_status);
				IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
					RAISE fnd_api.g_exc_unexpected_error;
				END IF;

/*		Verifying Global Earning Elements Inserts	*/
		ELSIF (r_reference_id_array.r_change_type(i) = 'GE') AND
			(r_reference_id_array.r_action_type(i) = 'I') THEN
			l_proc_step := 130 + (I/100000);		-- Introduced for bug fix 3434626
			OPEN global_element_insert_cur(r_reference_id_array.r_reference_id(i));
				FETCH global_element_insert_cur
					BULK COLLECT INTO r_asg_id_array.r_asg_id,
					r_asg_id_array.r_payroll_id;
			CLOSE global_element_insert_cur;
--	Introduced the following for bug fix 3434626
			hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

				insert_changed_assignments(p_change_type =>	'GE',
					p_reference_id	=>	r_reference_id_array.r_reference_id(i),
					p_action_type	=>	r_reference_id_array.r_action_type(i),
					p_return_status	=>	p_return_status);
				IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
					RAISE fnd_api.g_exc_unexpected_error;
				END IF;

/*		Verifying assignments affected by Enc Payroll Assignments Changes	*/
		ELSIF (r_reference_id_array.r_change_type(i) = 'EX') THEN
			l_proc_step := 140 + (I/100000);		-- Introduced for bug fix 3434626
			OPEN assignment_payroll_ex_upd_cur(r_reference_id_array.r_reference_id(i));
				FETCH assignment_payroll_ex_upd_cur
					BULK COLLECT INTO r_asg_id_array.r_asg_id,
					r_asg_id_array.r_payroll_id;
			CLOSE assignment_payroll_ex_upd_cur;
--	Introduced the following for bug fix 3434626
			hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

				insert_changed_assignments(p_change_type =>	'EX',
					p_reference_id	=>	r_reference_id_array.r_reference_id(i),
					p_action_type	=>	r_reference_id_array.r_action_type(i),
					p_return_status	=>	p_return_status);
				IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
					RAISE fnd_api.g_exc_unexpected_error;
				END IF;

/*		Verifying assignments affected by Default Org End Date Changes	*/
		ELSIF (r_reference_id_array.r_change_type(i) = 'OE') THEN
			l_proc_step := 150 + (I/100000);		-- Introduced for bug fix 3434626
--	Introduced the following for bug fix 3426871
			OPEN default_end_date_cur(r_reference_id_array.r_reference_id(i));
			FETCH default_end_date_cur INTO l_period_end_date, l_prev_enc_end_date;
			CLOSE default_end_date_cur;

			IF (l_period_end_date < l_prev_enc_end_date) THEN
				OPEN default_end_date_dec_cur;
				FETCH default_end_date_dec_cur
					BULK COLLECT INTO r_asg_id_array.r_asg_id,
					r_asg_id_array.r_payroll_id;
				CLOSE default_end_date_dec_cur;
			ELSE
--	End of bug fix 3426871
--				OPEN	default_org_end_date_asg_cur(r_reference_id_array.r_reference_id(i));	Commented for bug 3426871
				OPEN	default_org_end_date_asg_cur;	-- Introduced for bug fix 3426871
				FETCH default_org_end_date_asg_cur
					BULK COLLECT INTO r_asg_id_array.r_asg_id,
					r_asg_id_array.r_payroll_id;
				CLOSE default_org_end_date_asg_cur;
			END IF;	-- Introduced for bug fix 3426871

--	Introduced the following for bug fix 3434626
			hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

			insert_changed_assignments(p_change_type =>	'OE',
				p_reference_id	=>	r_reference_id_array.r_reference_id(i),
				p_action_type	=>	r_reference_id_array.r_action_type(i),
				p_return_status	=>	p_return_status);
			IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_unexpected_error;
			END IF;

---For Bug fix:2370841-Verifying assignments affected by Element Selection  Changes
		ELSIF (r_reference_id_array.r_change_type(i) = 'ED') THEN
			l_proc_step := 160 + (I/100000);		-- Introduced for bug fix 3434626
			OPEN	element_ed_ins_upd_cur(r_reference_id_array.r_reference_id(i));
				FETCH element_ed_ins_upd_cur
				BULK COLLECT INTO 	r_asg_id_array.r_asg_id,
					  		r_asg_id_array.r_payroll_id;
			CLOSE element_ed_ins_upd_cur;

--	Introduced the following for bug fix 3434626
			hr_utility.trace('r_asg_id_array.r_asg_id.COUNT: ' || fnd_number.number_to_canonical(r_asg_id_array.r_asg_id.COUNT));
--      End of bug fix 3434626

			insert_changed_assignments(p_change_type =>	'ED',
				p_reference_id	=>	r_reference_id_array.r_reference_id(i),
				p_action_type	=>	r_reference_id_array.r_action_type(i),
				p_return_status	=>	p_return_status);
			IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
				RAISE fnd_api.g_exc_unexpected_error;
			END IF;
--End of Changes for the bug fix
		END IF;
	END LOOP;	--	End of Enc Change Schedules loop

	l_proc_step := 170;		-- Introduced for bug fix 3434626

	FORALL I IN 1 .. r_reference_id_array.r_reference_id.COUNT
	INSERT INTO psp_enc_changed_sch_history
		(request_id, reference_id,
		change_type, action_type,
		reference_field)
	VALUES	(g_request_id, r_reference_id_array.r_reference_id(i),
		r_reference_id_array.r_change_type(i), r_reference_id_array.r_action_type(i),
		r_reference_id_array.r_reference_field(i));

	l_proc_step := 180;		-- Introduced for bug fix 3434626

	r_reference_id_array.r_reference_id.DELETE;
	r_reference_id_array.r_change_type.DELETE;
	r_reference_id_array.r_reference_field.DELETE;
	r_reference_id_array.r_action_type.DELETE;

	DELETE	psp_enc_changed_schedules;

	l_proc_step := 190;		-- Introduced for bug fix 3434626

	COMMIT;

	l_proc_step := 200;		-- Introduced for bug fix 3434626

	p_return_status := fnd_api.g_ret_sts_success;
--	Introduced the following for bug fix 3434626
	hr_utility.trace('Leaving: ' || l_proc_name);
--	End of changed for bug fix 3434626
EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := 'PSP_ENC_PRE_PROCESS : LABOR_SCHEDULE_PRE_PROCESS';
		fnd_msg_pub.add_exc_msg('PSP_ENC_PRE_PROCESS', 'LABOR_SCHEDULE_PRE_PROCESS');
		ROLLBACK;
		p_return_status := fnd_api.g_ret_sts_unexp_error;
--	Introduced the following for bug fix 3434626
		hr_utility.trace(fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		hr_utility.trace('Leaving: ' || l_proc_name);
--	End of changed for bug fix 3434626
END labor_schedule_pre_process;

END psp_enc_pre_process;

/
