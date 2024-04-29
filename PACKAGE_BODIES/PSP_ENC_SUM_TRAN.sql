--------------------------------------------------------
--  DDL for Package Body PSP_ENC_SUM_TRAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ENC_SUM_TRAN" AS
/* $Header: PSPENSTB.pls 120.13 2007/07/19 09:23:08 amakrish noship $ */

--	##########################################################################
--	This procedure initiates the encumbrance summarization processes gl/ogm
--	##########################################################################
g_control_rec_found VARCHAR2(10) := 'TRUE';
l_phase_status      number := 0 ;
g_fatal number;
g_payroll_action_id number; /* Bug 2030232 */

g_currency_code VARCHAR(15); -- for Bug 2478000 Qubec fix

g_susp_prob varchar2(5) :=  NULL;    --- 2479579

g_insert_str	varchar2(5000);	-- Introduced for bug fix 3233373
g_warning_message	VARCHAR2(5000);

g_dff_grouping_option	CHAR(1);		-- Introduced for bug fix 2908859

g_def_end_date	DATE;

g_precision		NUMBER;
g_ext_precision	NUMBER;
g_suspense_failed	VARCHAR2(15);
g_process_complete	BOOLEAN;
g_sa_autopop		BOOLEAN;

PROCEDURE	move_rej_lines_to_arch (p_payroll_action_id	IN	NUMBER);

PROCEDURE create_sum_lines	(p_payroll_action_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2);

PROCEDURE update_hierarchy_dates (p_payroll_action_id	IN	NUMBER,
					p_return_status		OUT NOCOPY	VARCHAR2);

PROCEDURE	add_st_warnings(p_start_date	IN	DATE	DEFAULT NULL,
						p_end_date			IN	DATE	DEFAULT NULL,
						p_assignment_id		IN	NUMBER	DEFAULT NULL,
						p_payroll_id		IN	NUMBER	DEFAULT NULL,
						p_element_type_id	IN	NUMBER	DEFAULT NULL,
						p_gl_ccid			IN	NUMBER	DEFAULT NULL,
						p_project_id		IN	NUMBER	DEFAULT NULL,
						p_task_id			IN	NUMBER	DEFAULT NULL,
						p_award_id			IN	NUMBER	DEFAULT NULL,
						p_exp_org_id		IN	NUMBER	DEFAULT NULL,
						p_exp_type			IN	VARCHAR2	DEFAULT NULL,
						p_effective_date	IN	DATE	DEFAULT NULL,
						p_error_status		IN	VARCHAR2	DEFAULT NULL);

PROCEDURE log_st_warnings;

TYPE t_num_15_type 	IS TABLE OF NUMBER(15) 		INDEX BY BINARY_INTEGER;
TYPE t_varchar_50_type 	IS TABLE OF VARCHAR2(50) 	INDEX BY BINARY_INTEGER;
TYPE t_varchar_150_type	IS TABLE OF VARCHAR2(150) 	INDEX BY BINARY_INTEGER;
TYPE t_num_10d2_type 	IS TABLE OF NUMBER	 	INDEX BY BINARY_INTEGER;
TYPE t_date_type 	IS TABLE OF DATE 		INDEX BY BINARY_INTEGER;

TYPE r_enc_rec IS RECORD
	(assignment_id		t_num_15_type,
	payroll_id			t_num_15_type,
	element_type_id		t_num_15_type,
	hierarchy_code		t_varchar_50_type,
	gl_ccid				t_num_15_type,
	project_id			t_num_15_type,
	task_id				t_num_15_type,
	award_id			t_num_15_type,
	exp_org_id			t_num_15_type,
	exp_type			t_varchar_50_type,
	enc_start_date		t_date_type,
	enc_end_date		t_date_type);

t_enc_lines			r_enc_rec;
t_enc_nlines		r_enc_rec;

TYPE r_asg_rec IS RECORD
	(assignment_id		t_num_15_type,
	payroll_id			t_num_15_type);

l_asgs			r_asg_rec;

TYPE r_enc_susp_rec IS RECORD
	(row_id					t_num_15_type,
	encumbrance_amount		t_num_10d2_type,
	enc_start_date			t_date_type,
	enc_end_date			t_date_type);
t_enc_susp_lines	r_enc_susp_rec;

TYPE r_warning_rec IS RECORD
	(start_date		t_date_type,
	end_date		t_date_type,
	assignment_id	t_num_15_type,
	payroll_id		t_num_15_type,
	element_type_id	t_num_15_type,
	gl_ccid			t_num_15_type,
	project_id		t_num_15_type,
	task_id			t_num_15_type,
	award_id		t_num_15_type,
	exp_org_id		t_num_15_type,
	exp_type		t_varchar_150_type,
	effective_date	t_date_type,
	error_status	t_varchar_150_type);
st_warnings		r_warning_rec;

PROCEDURE enc_sum_trans(errbuf	           OUT NOCOPY VARCHAR2,
                        retcode	           OUT NOCOPY VARCHAR2,
                        p_payroll_action_id	    IN NUMBER,
			p_business_group_id IN NUMBER,
			p_set_of_books_id   IN NUMBER) IS

l_return_status			VARCHAR2(1);
l_msg_count				NUMBER;
l_msg_data				VARCHAR2(2000);
l_liq_check				NUMBER;
l_gl_check				NUMBER;
l_gms_check				NUMBER;
l_last_update_date		DATE;
l_last_updated_by		NUMBER;
l_last_updated_login	NUMBER;
l_request_id			NUMBER;
l_sa_autopop			VARCHAR2(1);

CURSOR	autopop_config_cur IS
SELECT	pcv_information7 suspense_account
FROM	pqp_configuration_values
WHERE	pcv_information_category = 'PSP_ENABLE_AUTOPOPULATION'
AND	legislation_code IS NULL
AND	NVL(business_group_id, p_business_group_id) = p_business_group_id
ORDER BY business_group_id;

CURSOR	liq_check_cur IS
SELECT	COUNT(1)
FROM	psp_enc_processes
WHERE	payroll_action_id = p_payroll_action_id
AND	process_phase = 'liquidate';

CURSOR	st_asgs_cur IS
SELECT	DISTINCT assignment_id,
	payroll_id
FROM	psp_enc_summary_lines pesl
WHERE	payroll_action_id = p_payroll_action_id
AND	superceded_line_id IS NULL
AND	status_code = 'N';

CURSOR	def_end_date_cur IS
SELECT	peed.period_end_date
FROM	psp_enc_end_dates peed
WHERE	peed.business_group_id = p_business_group_id
AND	peed.set_of_books_id   = p_set_of_books_id
AND	peed.default_org_flag  = 'Y';

CURSOR	check_gl_lines IS
SELECT	COUNT(1)
FROM	psp_enc_summary_lines
WHERE	payroll_action_id = p_payroll_action_id
AND	superceded_line_id IS NULL
AND	gl_code_combination_id IS NOT NULL
AND	status_code = 'N';

CURSOR	check_gms_lines IS
SELECT	COUNT(1)
FROM	psp_enc_summary_lines
WHERE	payroll_action_id = p_payroll_action_id
AND	superceded_line_id IS NULL
AND	award_id IS NOT NULL
AND	status_code = 'N';
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering enc_sum_trans p_payroll_action_id: ' || p_payroll_action_id || '
	p_business_group_id: ' || p_business_group_id || '
	p_set_of_books_id: ' || p_set_of_books_id);

   g_error_api_path := '';
   fnd_msg_pub.initialize;
   psp_general.TRANSACTION_CHANGE_PURGEBLE;  --2431917
   g_business_group_id := p_business_group_id;
   g_set_of_books_id := p_set_of_books_id;
   g_payroll_action_id      := p_payroll_action_id; /* for Bug 2030232 */

	g_currency_code := psp_general.get_currency_code(p_business_group_id);-- For bug 2478000 Qubec fix

	psp_general.get_currency_precision(g_currency_code, g_precision, g_ext_precision);

	g_dff_grouping_option := psp_general.get_enc_dff_grouping_option(p_business_group_id);	-- Introduced for bug fix 2908859
	g_suspense_failed := 'FALSE';
	g_process_complete := TRUE;

	OPEN autopop_config_cur;
	FETCH autopop_config_cur INTO l_sa_autopop;
	IF (autopop_config_cur%ROWCOUNT = 0) THEN
		l_sa_autopop := 'N';
	END IF;
	CLOSE autopop_config_cur;

	g_sa_autopop := FALSE;
	IF (l_sa_autopop = 'Y') THEN
		g_sa_autopop := TRUE;
	END IF;

	OPEN def_end_date_cur;
	FETCH def_end_date_cur INTO g_def_end_date;
	CLOSE def_end_date_cur;

	l_last_update_date := SYSDATE;
	l_last_updated_by := NVL(FND_GLOBAL.USER_ID, -1);
	l_last_updated_login := NVL(FND_GLOBAL.LOGIN_ID, -1);
	l_request_id := fnd_global.conc_request_id;

	INSERT INTO psp_enc_processes
		(request_id,			process_code,			payroll_action_id,
		process_status,			process_phase,			business_group_id,
		set_of_books_id,		creation_date,			created_by,
		last_update_date,		last_updated_by,	last_update_login)
	SELECT	l_request_id,		'ST',				p_payroll_action_id,
			'I',				process_phase,		p_business_group_id,
			p_set_of_books_id,	l_last_update_date,	l_last_updated_by,
			l_last_update_date,	l_last_updated_by,	l_last_updated_login
	FROM	psp_enc_processes pep
	WHERE	process_code IN ('CEL', 'LET')
	AND		payroll_action_id = p_payroll_action_id
	AND		NOT EXISTS	(SELECT	1
						FROM	psp_enc_processes pep2
						WHERE	pep2.payroll_action_id = p_payroll_action_id
						AND		pep2.process_code = 'ST');

	UPDATE	psp_enc_processes
	SET		process_status = 'S',
			process_phase = 'completed'
	WHERE	payroll_action_id = p_payroll_action_id
	AND		process_code IN ('CEL', 'LET');
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated original and current process status in psp_enc_processes');

	OPEN st_asgs_cur;
	FETCH st_asgs_cur BULK COLLECT INTO l_asgs.assignment_id, l_asgs.payroll_id;
	CLOSE st_asgs_cur;

	move_rej_lines_to_arch(p_payroll_action_id);

	OPEN liq_check_cur;
	FETCH liq_check_cur INTO l_liq_check;
	CLOSE liq_check_cur;

	IF (l_liq_check > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_enc_liq_tran.enc_liq_trans');
		psp_enc_liq_tran.enc_liq_trans(p_payroll_action_id, p_business_group_id, p_set_of_books_id, l_return_status);

		IF l_return_status NOT IN (fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_success) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After psp_enc_liq_tran.enc_liq_trans');
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling enc_batch_begin');
   	enc_batch_begin(p_payroll_action_id, l_return_status);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After enc_batch_begin');

	IF g_control_rec_found = 'FALSE' THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling enc_batch_end');
		enc_batch_end(p_payroll_action_id, l_return_status);

		IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After enc_batch_end');
		retcode := FND_API.G_RET_STS_SUCCESS;

            psp_message_s.print_error(p_mode=>FND_FILE.log,
                                      p_print_header=>FND_API.G_FALSE);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving enc_sum_trans p_payroll_action_id: ' || p_payroll_action_id || '
	p_business_group_id: ' || p_business_group_id || '
	p_set_of_books_id: ' || p_set_of_books_id);
          PSP_MESSAGE_S.Print_success;
	  return;
    END IF;

-- Enh  2505778  LD, GMS Integration with PQH

     if fnd_profile.value('PSP_ENC_ENABLE_PQH') ='Y' then
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling pqh_psp_integration.relieve_budget_commitments');
        pqh_psp_integration.relieve_budget_commitments( 'S', l_return_status);
        If l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	  	fnd_message.set_name('PSP','PSP_ENC_PQH_ERROR');
		fnd_msg_pub.add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After pqh_psp_integration.relieve_budget_commitments');
     end if;

    -- FIRST NORMAL RUN
    -- initiate the gl encumbrance summarization and transfer
    -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      -- 2968684 added params to following proc
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_st_ext.summary_ext_encumber');
        psp_st_ext.summary_ext_encumber(p_payroll_action_id ,
                                        p_business_group_id,
                                        p_set_of_books_id);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After psp_st_ext.summary_ext_encumber');
    END IF;

	OPEN check_gl_lines;
	FETCH check_gl_lines INTO l_gl_check;
	CLOSE check_gl_lines;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_gl_check: ' || l_gl_check);

	IF (l_gl_check > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling tr_to_gl_int');
		tr_to_gl_int(p_payroll_action_id, l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After tr_to_gl_int');
	END IF;

     -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      -- 2968684 added params to following proc
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_st_ext.summary_ext_encumber');
        psp_st_ext.summary_ext_encumber(p_payroll_action_id ,
                                        p_business_group_id,
                                        p_set_of_books_id);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After psp_st_ext.summary_ext_encumber');
    END IF;

    -- initiate the ogm encumbrance summarization and transfer
	OPEN check_gms_lines;
	FETCH check_gms_lines INTO l_gms_check;
	CLOSE check_gms_lines;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_gms_check: ' || l_gms_check);

	IF (l_gms_check > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling tr_to_gms_int');
		tr_to_gms_int(p_payroll_action_id, l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After tr_to_gms_int');
	END IF;

    -- SECOND RUN TO TAKE CARE OF TIE-BACK
    -- initiate the suspense lines summarization
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling create_sum_lines');
    create_sum_lines(p_payroll_action_id, l_return_status);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After create_sum_lines');

        -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      -- 2968684 added params to following proc
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_st_ext.summary_ext_encumber');
        psp_st_ext.summary_ext_encumber(p_payroll_action_id ,
                                        p_business_group_id,
                                        p_set_of_books_id);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After psp_st_ext.summary_ext_encumber');
    END IF;

	OPEN check_gl_lines;
	FETCH check_gl_lines INTO l_gl_check;
	CLOSE check_gl_lines;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_gl_check: ' || l_gl_check);

	IF (l_gl_check > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling tr_to_gl_int');
		tr_to_gl_int(p_payroll_action_id, l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After tr_to_gl_int');
	END IF;

    -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      -- 2968684 added params to following proc
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_st_ext.summary_ext_encumber');
        psp_st_ext.summary_ext_encumber(p_payroll_action_id ,
                                        p_business_group_id,
                                        p_set_of_books_id);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After psp_st_ext.summary_ext_encumber');
    END IF;

	OPEN check_gms_lines;
	FETCH check_gms_lines INTO l_gms_check;
	CLOSE check_gms_lines;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_gms_check: ' || l_gms_check);

	IF (l_gms_check > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling tr_to_gms_int');
		tr_to_gms_int(p_payroll_action_id, l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After tr_to_gms_int');
	END IF;

	g_suspense_failed := 'TRUE';
	DELETE	psp_enc_summary_lines
	WHERE	payroll_action_id = p_payroll_action_id
	AND	superceded_line_id IS NULL
	AND	status_code = 'N';
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted un-imported summary lines (' || SQL%ROWCOUNT || ')');

	UPDATE	psp_enc_lines
	SET	suspense_org_account_id = NULL,
		gl_code_combination_id = orig_gl_code_combination_id,
		project_id = orig_project_id,
		task_id = orig_task_id,
		award_id = orig_award_id,
		expenditure_organization_id = orig_expenditure_org_id,
		expenditure_type = orig_expenditure_type,
		gl_project_flag = decode(orig_gl_code_combination_id,NULL,'P','G'),
		encumbrance_date = prev_effective_date
	WHERE	payroll_action_id = p_payroll_action_id
	AND		suspense_reason_code like 'ES:%';

	UPDATE	psp_enc_lines
	SET	orig_gl_code_combination_id = NULL,
		orig_project_id = NULL,
		orig_task_id = NULL,
		orig_award_id = NULL,
		orig_expenditure_org_id = NULL,
		orig_expenditure_type = NULL,
		suspense_reason_code = NULL
	WHERE	suspense_reason_code like 'ES:%'
	AND		payroll_action_id = p_payroll_action_id;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Reverted un-imported suspense postings posted in this process (' || SQL%ROWCOUNT || ')');

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling create_sum_lines');
    create_sum_lines(p_payroll_action_id, l_return_status);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After create_sum_lines');

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling enc_batch_end');
    enc_batch_end(p_payroll_action_id, l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After enc_batch_end');
	retcode := FND_API.G_RET_STS_SUCCESS;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving enc_sum_trans p_payroll_action_id: ' || p_payroll_action_id || '
	p_business_group_id: ' || p_business_group_id || '
	p_set_of_books_id: ' || p_set_of_books_id);
          PSP_MESSAGE_S.Print_success;
 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;   --Introduced as part of bug fix 1776606
      g_error_api_path := 'ENC_SUM_TRANS:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','ENC_SUM_TRANS');
      retcode := 2;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving enc_sum_trans p_payroll_action_id: ' || p_payroll_action_id || '
	p_business_group_id: ' || p_business_group_id || '
	p_set_of_books_id: ' || p_set_of_books_id);
          psp_message_s.print_error(p_mode => FND_FILE.LOG,
                                  p_print_header => FND_API.G_TRUE);
          return;

    WHEN OTHERS THEN
      ROLLBACK;   --Introduced as part of bug fix 1776606
      g_error_api_path := 'ENC_SUM_TRANS:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','ENC_SUM_TRANS');
      retcode := 2;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving enc_sum_trans p_payroll_action_id: ' || p_payroll_action_id || '
	p_business_group_id: ' || p_business_group_id || '
	p_set_of_books_id: ' || p_set_of_books_id);
          psp_message_s.print_error(p_mode => FND_FILE.LOG,
                                  p_print_header => FND_API.G_TRUE);
          return;
  END;

--	##########################################################################
--	This procedure begins the encumbrance summarization process
--	This procedure generates a RUN_ID and updates PSP_ENC_CONTROLS table with
--	the RUN_ID and sets the ACTION_CODE = 'I' where
--	ACTION_TYPE in ('N', 'Q', 'U') and ACTION_CODE = 'N'
--	Included 'Q' for Quick Update Enh. 2143723
--	##########################################################################

 PROCEDURE enc_batch_begin(p_payroll_action_id IN NUMBER,
			p_return_status  OUT NOCOPY VARCHAR2
			) IS

CURSOR	enc_control_cur IS
SELECT	enc_control_id,
	payroll_id,
	time_period_id
FROM 	psp_enc_controls
WHERE	payroll_action_id = p_payroll_action_id
--   	WHERE  	payroll_id = nvl(p_payroll_id, payroll_id)
AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
AND	action_type IN ('N', 'Q', 'U') -- Included 'Q' for Quick Upd. Enh. 2143723
AND	action_code in ('N','I')   --- 2444657
AND	business_group_id = g_business_group_id
AND	set_of_books_id = g_set_of_books_id;

enc_control_rec		enc_control_cur%ROWTYPE;
l_bg_id			NUMBER := g_business_group_id;
BEGIN
	SELECT psp_st_run_id_s.nextval INTO g_run_id FROM dual;

	OPEN enc_control_cur;
	LOOP
		FETCH enc_control_cur INTO enc_control_rec;
		IF enc_control_cur%rowcount = 0 THEN
			g_control_rec_found := 'FALSE';
			fnd_message.set_name('PSP','PSP_ENC_NO_SUMM_REC_FOUND');
			fnd_msg_pub.add;
		--			p_return_status	:= fnd_api.g_ret_sts_unexp_error;
--   for bug fix 1868338 -- Subha
			p_return_status	:= fnd_api.g_ret_sts_success;
			CLOSE enc_control_cur;
			EXIT;
		END IF;
		IF enc_control_cur%NOTFOUND THEN
			CLOSE enc_control_cur;
			p_return_status	:= fnd_api.g_ret_sts_success;
			EXIT;
		END IF;

		UPDATE psp_enc_controls
		SET action_code = 'I',
		run_id = g_run_id
		WHERE enc_control_id = enc_control_rec.enc_control_id
		AND time_period_id = enc_control_rec.time_period_id;
	END LOOP;
EXCEPTION
/* Introduced as part of bug fix #1776606 */
	when others then
		g_error_api_path := 'ENC_BATCH_BEGIN:'||g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','ENC_BATCH_BEGIN');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		RAISE;
END;
--	##########################################################################
--	This procedure ends the encumbrance summarization process

--      This procedure updates the table PSP_ENC_CONTROLS with ACTION_CODE = 'P',
--      if the program is completed with a return code of success and if the
--      return code is failed it updates ACTION_CODE = 'N'.

--	When the program returns a failure status, it also updates PSP_ENC_LINES
--	with STATUS_CODE = 'N' and PSP_ENC_SUMMARY_LINES with STATUS_CODE = 'R'

--	##########################################################################

PROCEDURE enc_batch_end	(p_payroll_action_id IN NUMBER,
			p_return_status  OUT NOCOPY VARCHAR2) IS
CURSOR	pending_line_cur IS
SELECT	COUNT(1)
FROM	psp_enc_summary_lines pesl
WHERE	pesl.payroll_action_id = p_payroll_action_id
AND	pesl.status_code = 'N';

CURSOR	check_enc_lines IS
SELECT	COUNT(1)
FROM	psp_enc_lines
WHERE	payroll_action_id = p_payroll_action_id
AND		enc_start_date <= g_def_end_date;

l_pending_line_count	NUMBER;
l_enc_lines_cnt			NUMBER;
l_return_status			VARCHAR2(1);
BEGIN
	update_hierarchy_dates(p_payroll_action_id	=>	p_payroll_action_id,
				p_return_status		=>	l_return_status);

	IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;

	log_st_warnings;

	IF (g_process_complete) THEN
		OPEN check_enc_lines;
		FETCH check_enc_lines INTO l_enc_lines_cnt;
		CLOSE check_enc_lines;

		IF (l_enc_lines_cnt = 0) THEN
			DELETE	psp_enc_lines
			WHERE	payroll_action_id = p_payroll_action_id;
		END IF;

		move_rej_lines_to_arch(p_payroll_action_id);
	END IF;

	UPDATE	psp_enc_controls pec
	SET	action_code = 'P'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl
				WHERE	pesl.payroll_action_id = p_payroll_action_id
				AND	pesl.enc_control_id = pec.enc_control_id
				AND	pesl.status_code = 'N');
	IF (SQL%ROWCOUNT > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated action_code to ''P''');
	END IF;

	UPDATE	psp_enc_processes
	SET	process_status = 'P', process_phase = 'completed'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	process_code = 'ST'
	AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl
				WHERE	pesl.payroll_action_id = p_payroll_action_id
				AND	pesl.status_code = 'N');
	IF (SQL%ROWCOUNT > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase to completed as no summarize and transfer is required');
	END IF;

	UPDATE	psp_enc_processes
	SET	process_phase = 'summarize_transfer'
	WHERE	payroll_action_id = p_payroll_action_id
	AND		process_code = 'ST'
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_lines pel
			WHERE	pel.payroll_action_id = p_payroll_action_id);
	IF (SQL%ROWCOUNT > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase to summarize and transfer re-processing');
	END IF;

	UPDATE	psp_enc_processes
	SET	process_phase = 'liquidate'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	process_code = 'ST'
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.payroll_action_id = p_payroll_action_id
			AND	pesl.status_code = 'N'
			AND	pesl.superceded_line_id IS NOT NULL);
	IF (SQL%ROWCOUNT > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase to liquidate for liquidation re-processing');
	END IF;

	UPDATE	psp_enc_process_assignments pepa
	SET	assignment_status = 'P'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl
				WHERE	pesl.payroll_action_id = p_payroll_action_id
				AND	pesl.assignment_id = pepa.assignment_id
				AND	pesl.payroll_id = pepa.payroll_id
				AND	pesl.status_code = 'N');
	IF (SQL%ROWCOUNT > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated assignment_status to processed for summarized and transferred assignments');
	END IF;

	UPDATE	psp_enc_process_assignments pepa
	SET	assignment_status = 'S'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.payroll_action_id = p_payroll_action_id
			AND	pesl.assignment_id = pepa.assignment_id
			AND	pesl.payroll_id = pepa.payroll_id
			AND	pesl.status_code = 'N'
			AND	pesl.superceded_line_id IS NULL);
	IF (SQL%ROWCOUNT > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated assignment_status to summarize and transfer for assignments to be summarized and transferred');
	END IF;

	UPDATE	psp_enc_process_assignments pepa
	SET	assignment_status = 'L'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.payroll_action_id = p_payroll_action_id
			AND	pesl.assignment_id = pepa.assignment_id
			AND	pesl.payroll_id = pepa.payroll_id
			AND	pesl.status_code = 'N'
			AND	pesl.superceded_line_id IS NOT NULL);
	IF (SQL%ROWCOUNT > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated assignment_status to liquidate for assignments to be liquidated');
	END IF;

  	COMMIT;

	OPEN pending_line_cur;
	FETCH pending_line_cur INTO l_pending_line_count;
	CLOSE pending_line_cur;

	IF (l_pending_line_count > 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Need to re-process');
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;
	p_return_status	:= fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := 'ENC_BATCH_END:'||g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','ENC_BATCH_END');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END enc_batch_end;

/*****	Commented for Create and Update multi thread enh.
 PROCEDURE enc_batch_end(p_payroll_action_id IN NUMBER,
		p_return_status  OUT NOCOPY VARCHAR2
			) IS

   	CURSOR 	enc_control_cur IS
   	SELECT 	enc_control_id,
          	payroll_id,
          	time_period_id,
            gl_phase,
            gms_phase
   	FROM   	psp_enc_controls
   	WHERE 	payroll_action_id = p_payroll_action_id
--   	WHERE 	payroll_id = nvl(p_payroll_id, payroll_id)
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type IN ('N', 'Q', 'U') -- Included 'Q' for Quick Upd. Enh. 2143723.
   	AND    	action_code = 'I'
   	AND    	run_id = nvl(g_run_id, run_id)
   	AND	business_group_id = g_business_group_id
	AND	set_of_books_id = g_set_of_books_id;

   	CURSOR 	new_enc_summary_lines_cur(P_ENC_CONTROL_ID  IN  NUMBER) IS
   	SELECT 	enc_summary_line_id
   	FROM 	psp_enc_summary_lines
   	WHERE 	enc_control_id = p_enc_control_id
   	AND   	status_code = 'N';

   	enc_control_rec		enc_control_cur%ROWTYPE;
   	 / * Included as part of Bug fix #1776606 * /
   	CURSOR  gl_gms_line_count_cur IS
   	SELECT  count(*)
     	FROM 	psp_enc_lines  pel
--      	,psp_enc_controls    pec
     	WHERE pel.enc_control_id=  enc_control_rec.enc_control_id
     	AND pel.time_period_id =   enc_control_rec.time_period_id
        AND pel.encumbrance_amount<>0
	AND pel.business_group_id = g_business_group_id
	AND pel.set_of_books_id = g_set_of_books_id;

   	l_status_code		VARCHAR2(1);
   	/ * Commented as part of Bug fix #1776606 * /
--   	l_o_enc_sum			NUMBER;
   	l_enc_summary_line_id		NUMBER(10);
 	l_bg_id			NUMBER := g_business_group_id;
 	/ * Included as part of Bug fix #1776606 * /
   	l_line_count   		        NUMBER(10);

	BEGIN

 		OPEN enc_control_cur;
  		LOOP

   			FETCH enc_control_cur INTO enc_control_rec;
   			IF enc_control_cur%NOTFOUND THEN
     			CLOSE enc_control_cur;
     			EXIT;

   			END IF;

   -- This part is used to mark the status_code of non-transferred summary lines to 'R'
   -- and mark the corresponding status_code of encumbrance lines back to 'N'

            IF (enc_control_rec.gl_phase is null and enc_control_rec.gms_phase is null) then
                rollback;
            / * ELSIF (enc_control_rec.gl_phase = 'Transfer' or enc_control_rec.gms_phase = 'Transfer') then
                update psp_enc_controls
                   set action_code = 'I'
                 where enc_control_id = enc_control_rec.enc_control_id; * / --- commented for 2479579
            ELSE

                UPDATE 	psp_enc_summary_lines
    			SET 	status_code = 'R'
    			WHERE 	enc_control_id = enc_control_rec.enc_control_id
    			AND 	status_code = 'N';

   -- This part is used to delete the rejected summary lines, mark the status_code
   -- in psp_enc_controls to 'P' or 'N'
                / * Commented as part of bug fix #1776606
       		SELECT 	nvl(sum(encumbrance_amount),0)
     		INTO 	l_o_enc_sum
     		FROM 	psp_enc_lines  pel
--          		,psp_enc_controls    pec
     		WHERE pel.enc_control_id = enc_control_rec.enc_control_id
     		AND pel.time_period_id = enc_control_rec.time_period_id
		AND pel.business_group_id = g_business_group_id
		AND pel.set_of_books_id = g_set_of_books_id;  * /

		OPEN gl_gms_line_count_cur;
		FETCH gl_gms_line_count_cur INTO l_line_count;
		CLOSE gl_gms_line_count_cur;

		/ * Included as part of bug fix #1776606 * /
		IF l_line_count = 0 THEN
                        / * commented for 2445196: preserving this lines useful for debugging purposes
			DELETE 	FROM psp_enc_summary_lines
        		WHERE 	enc_control_id = enc_control_rec.enc_control_id
        		AND 	status_code = 'R'; * /

			UPDATE 	psp_enc_controls
        		SET 	action_code = 'P',
            			run_id = NULL
        		WHERE 	enc_control_id = enc_control_rec.enc_control_id;

     		ELSE
			UPDATE 	psp_enc_controls
        		SET 	action_code = 'N',
            			run_id = NULL
        		WHERE 	enc_control_id = enc_control_rec.enc_control_id;
               END IF;
                / * Commented as part of Bug fix #1776606 * /
	/ *	IF l_o_enc_sum = 0 THEN
			DELETE 	FROM psp_enc_summary_lines
        		WHERE 	enc_control_id = enc_control_rec.enc_control_id
        		AND 	status_code = 'R';

			UPDATE 	psp_enc_controls
        		SET 	action_code = 'P',
            			run_id = NULL
        		WHERE 	enc_control_id = enc_control_rec.enc_control_id;

     		ELSE
			UPDATE 	psp_enc_controls
        		SET 	action_code = 'N',
            			run_id = NULL
        		WHERE 	enc_control_id = enc_control_rec.enc_control_id;
              END IF;   * /
       END IF; -- IF PHASES ARE OTHER THAN NULL OR TRANSFER
     END LOOP;

	UPDATE	psp_enc_processes
	SET		process_status = 'P', process_phase = 'completed'
	WHERE	payroll_action_id = p_payroll_action_id
	AND		NOT EXISTS	(SELECT	1
						FROM	psp_enc_summary_lines pesl
						WHERE	pesl.payroll_action_id = p_payroll_action_id
						AND		pesl.status_code = 'N');
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase to completed as no summarize and transfer is required');

	UPDATE	psp_enc_processes
	SET		process_phase = 'summarize_transfer'
	WHERE	payroll_action_id = p_payroll_action_id
	AND		EXISTS	(SELECT	1
						FROM	psp_enc_summary_lines pesl
						WHERE	pesl.payroll_action_id = p_payroll_action_id
						AND		pesl.status_code = 'N'
						AND		pesl.superceded_line_id IS NULL);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase to summarize and transfer re-processing');

	UPDATE	psp_enc_processes
	SET		process_phase = 'liquidate'
	WHERE	payroll_action_id = p_payroll_action_id
	AND		EXISTS	(SELECT	1
						FROM	psp_enc_summary_lines pesl
						WHERE	pesl.payroll_action_id = p_payroll_action_id
						AND		pesl.status_code = 'N'
						AND		pesl.superceded_line_id IS NOT NULL);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase to liquidate for liqduidation re-processing');

  	COMMIT;
	p_return_status	:= fnd_api.g_ret_sts_success;
 EXCEPTION
	/ * Introduced as part of Bug fix #1776606 * /
	WHEN others then
     		g_error_api_path := 'ENC_BATCH_END:'||g_error_api_path;
	        fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','ENC_BATCH_END');
     		p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;
	End of comment for Create and Update multi thread enh.	*****/

--	##########################################################################
--	This procedure summarizes all the lines from psp_enc_lines
--		and inserts the summarized lines into psp_enc_summary_lines

--	Depending on the setup options, this procedure groups transactions from
--	PSP_ENC_LINES and inserts the summarized lines into PSP_ENC_SUMMARY_LINES

--	There are two setup options in PSP_ENC_SETUP_OPTIONS table called 'TIME_BASED_SUMM'
--	and 'CI_BASED_SUMM_GL' on which the procedure depends.

--	If the 'TIME_BASED_SUMM' = 1 and 'CI_BASED_SUMM_GL' = 3
--	then the summarization is done upto the assignment level for each time period

--	If the 'TIME_BASED_SUMM' = 1 and 'CI_BASED_SUMM_GL' = 2
--	then the summarization is done upto the employee level for each time period

--	If the 'TIME_BASED_SUMM' = 1 and 'CI_BASED_SUMM_GL' = 1
--	then the summarization is done upto the code combination level for each time period

--	If the 'TIME_BASED_SUMM' = 2 and 'CI_BASED_SUMM_GL' = 3
--	then the summarization is done upto the assignment level for each GL period

--	If the 'TIME_BASED_SUMM' = 2 and 'CI_BASED_SUMM_GL' = 2
--	then the summarization is done upto the employee level for each GL period

--	If the 'TIME_BASED_SUMM' = 2 and 'CI_BASED_SUMM_GL' = 1
--	then the summarization is done upto the code combination level for each GL period

--	##########################################################################

/*****	Commented for Create and Update multi thread enh.
PROCEDURE create_gl_enc_sum_lines(p_payroll_id IN NUMBER,
			p_return_status	OUT NOCOPY  VARCHAR2
				) IS

	CURSOR 	enc_control_cur IS
   	SELECT 	enc_control_id,
          	payroll_id,
          	time_period_id
   	FROM   	psp_enc_controls
   	WHERE 	payroll_id = nvl(p_payroll_id, payroll_id)
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type IN ('N', 'Q', 'U') -- Included 'Q' for Quick Upd. Enh. 2143723.
   	AND    	action_code = 'I'
   	AND    	run_id = g_run_id
   	AND	business_group_id = g_business_group_id
	AND	set_of_books_id = g_set_of_books_id
        AND     (gl_phase is null or gl_phase = 'TieBack');    --- 2444657

   	CURSOR 	enc_sum_lines_p1_cur(p_enc_control_id	IN  NUMBER) IS
   	SELECT
--		ptp.end_date eff_dt,  bug fix 1971612
                pel.encumbrance_date eff_dt,
		pel.dr_cr_flag,
		sum(pel.encumbrance_amount) sum_amt,
		pel.gl_project_flag,
		pel.person_id,
		pel.assignment_id,
--		pel.gl_code_combination_id gl_ccid  Commented out for Bug 3194807
--		sob.set_of_books_id,
/ * Uncommented the decode statement for Bug 3194807 * /
		decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id) gl_ccid,
--		Introduced DFF columns for bug fix 2908859
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute_category, pos.attribute_category), NULL) attribute_category,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute1, pos.attribute1), NULL) attribute1,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute2, pos.attribute2), NULL) attribute2,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute3, pos.attribute3), NULL) attribute3,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute4, pos.attribute4), NULL) attribute4,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute5, pos.attribute5), NULL) attribute5,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute6, pos.attribute6), NULL) attribute6,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute7, pos.attribute7), NULL) attribute7,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute8, pos.attribute8), NULL) attribute8,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute9, pos.attribute9), NULL) attribute9,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute10, pos.attribute10), NULL) attribute10
   	FROM		PSP_ENC_LINES  		PEL,
			PER_TIME_PERIODS	PTP,
--			,GL_SETS_OF_BOOKS SOB,
--			GL_CODE_COMBINATIONS GCC,
			PSP_ORGANIZATION_ACCOUNTS POS
   	WHERE 		PEL.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
--	AND		PEL.ENCUMBRANCE_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
--         Commented out for bug fix 1971612
	AND		PEL.GL_PROJECT_FLAG = 'G'
   	AND		PEL.ENCUMBRANCE_AMOUNT <> 0
	AND		PEL.ENC_CONTROL_ID = p_enc_control_id
--	AND		pel.gl_code_combination_id = gcc.code_combination_id
--   	AND		gcc.chart_of_accounts_id = sob.chart_of_accounts_id
   	AND		pel.suspense_org_account_id = pos.organization_account_id(+)
	GROUP BY
    --	ptp.end_date, -- for bug fix 1971612
                        pel.encumbrance_date,
			pel.person_id,
			pel.assignment_id,
			pel.dr_cr_flag,
			pel.gl_project_flag,
--			pel.gl_code_combination_id; Commented out for Bug 3194807
--			sob.set_of_books_id,
			DECODE(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id),
--		Introduced DFF columns for bug fix 2908859
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute_category, pos.attribute_category), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute1, pos.attribute1), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute2, pos.attribute2), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute3, pos.attribute3), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute4, pos.attribute4), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute5, pos.attribute5), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute6, pos.attribute6), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute7, pos.attribute7), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute8, pos.attribute8), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute9, pos.attribute9), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute10, pos.attribute10), NULL);
/ *	Commented the following Cursors as part of Enh. 2143723
	CURSOR 	enc_sum_lines_p2_cur(p_enc_control_id	IN  NUMBER) IS
   	SELECT
  ---	ptp.end_date eff_dt,   for bug fix 1971612
                pel.encumbrance_date eff_dt,
		pel.dr_cr_flag,
		sum(pel.encumbrance_amount) sum_amt,
		pel.gl_project_flag,
		pel.person_id,
		pel.gl_code_combination_id gl_ccid
--		sob.set_of_books_id,
--		decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id) gl_ccid
   	FROM		PSP_ENC_LINES  		PEL,
			PER_TIME_PERIODS	PTP
--			,GL_SETS_OF_BOOKS SOB,
--			GL_CODE_COMBINATIONS GCC,
--			PSP_ORGANIZATION_ACCOUNTS POS
   	WHERE 		PEL.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
--	AND		PEL.ENCUMBRANCE_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
--         Commented out for bug fix 1971612
	AND		PEL.GL_PROJECT_FLAG = 'G'
   	AND		PEL.ENCUMBRANCE_AMOUNT <> 0
	AND		PEL.ENC_CONTROL_ID = p_enc_control_id
--   	AND 		pel.gl_code_combination_id = gcc.code_combination_id
--   	AND		gcc.chart_of_accounts_id = sob.chart_of_accounts_id
--   	AND		pel.suspense_org_account_id = pos.organization_account_id(+)
	GROUP BY
      --	ptp.end_date,   for bug fix 1971612
                        pel.encumbrance_date,
			pel.person_id,
			pel.dr_cr_flag,
			pel.gl_project_flag,
			pel.gl_code_combination_id;
--			,sob.set_of_books_id,
--			decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id);

	CURSOR 	enc_sum_lines_p3_cur(p_enc_control_id	IN  NUMBER) IS
   	SELECT
--	ptp.end_date eff_dt,    for bug fix 1971612
                pel.encumbrance_date eff_dt,
		pel.dr_cr_flag,
		sum(pel.encumbrance_amount) sum_amt,
		pel.gl_project_flag,
		pel.gl_code_combination_id gl_ccid
--		sob.set_of_books_id,
--		decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id) gl_ccid
   	FROM		PSP_ENC_LINES  		PEL,
			PER_TIME_PERIODS	PTP
--			,GL_SETS_OF_BOOKS SOB,
--			GL_CODE_COMBINATIONS GCC,
--			PSP_ORGANIZATION_ACCOUNTS POS
   	WHERE 		PEL.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
--	AND		PEL.ENCUMBRANCE_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
--         Commented out for bug fix 1971612
	AND		PEL.GL_PROJECT_FLAG = 'G'
   	AND		PEL.ENCUMBRANCE_AMOUNT <> 0
	AND		PEL.ENC_CONTROL_ID = p_enc_control_id
--   	AND		pel.suspense_org_account_id = pos.organization_account_id(+)
	GROUP BY
--	ptp.end_date,   for bug fix 1971612
                        pel.encumbrance_date,
			pel.dr_cr_flag,
			pel.gl_project_flag,
			pel.gl_code_combination_id;
--			,sob.set_of_books_id,
--			decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id);

End of Enh. fix 2143723 *** /

/ ******************************************************************************


The Summarize by Gl period option is obsoleted
per bug fix 1971612 /bug 1831493

	CURSOR 	enc_sum_lines_g1_cur(p_enc_control_id	IN  NUMBER) IS
   	SELECT 	glp.end_date eff_dt,
		pel.dr_cr_flag,
		sum(pel.encumbrance_amount) sum_amt,
		pel.gl_project_flag,
		pel.person_id,
		pel.assignment_id,
		pel.gl_code_combination_id gl_ccid
--		,sob.set_of_books_id,
--		decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id) gl_ccid
   	FROM		PSP_ENC_LINES  		PEL,
			GL_PERIODS	GLP,
			GL_SETS_OF_BOOKS SOB,
--			,GL_CODE_COMBINATIONS GCC,
--			PSP_ORGANIZATION_ACCOUNTS POS
   	WHERE		sob.accounted_period_type = glp.period_type
	AND		sob.set_of_books_id = g_set_of_books_id
   	AND 		PEL.GL_PROJECT_FLAG = 'G'
   	AND		PEL.ENCUMBRANCE_AMOUNT <> 0
	AND		PEL.ENC_CONTROL_ID = p_enc_control_id
	AND		PEL.ENCUMBRANCE_DATE BETWEEN GLP.START_DATE AND GLP.END_DATE
   	AND 		pel.gl_code_combination_id = gcc.code_combination_id
--   	AND		gcc.chart_of_accounts_id = sob.chart_of_accounts_id
--	AND		pel.suspense_org_account_id = pos.organization_account_id(+)
	GROUP BY	sob.set_of_books_id,
			glp.end_date,
			pel.person_id,
			pel.assignment_id,
			pel.dr_cr_flag,
			pel.gl_project_flag,
			pel.gl_code_combination_id;
--			decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id);

	CURSOR 	enc_sum_lines_g2_cur(p_enc_control_id	IN  NUMBER) IS
   	SELECT 	sob.set_of_books_id,
		glp.end_date eff_dt,
		pel.dr_cr_flag,
		sum(pel.encumbrance_amount) sum_amt,
		pel.gl_project_flag,
		pel.person_id,
		pel.gl_code_combination_id gl_ccid
--		,decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id) gl_ccid
   	FROM		PSP_ENC_LINES  		PEL,
			GL_PERIODS	GLP,
			GL_SETS_OF_BOOKS SOB
--			,GL_CODE_COMBINATIONS GCC,
--			PSP_ORGANIZATION_ACCOUNTS POS
	WHERE		sob.set_of_books_id = g_set_of_books_id
   	AND		sob.accounted_period_type = glp.period_type
   	AND 		PEL.GL_PROJECT_FLAG = 'G'
   	AND		PEL.ENCUMBRANCE_AMOUNT <> 0
	AND		PEL.ENC_CONTROL_ID = p_enc_control_id
	AND		PEL.ENCUMBRANCE_DATE BETWEEN GLP.START_DATE AND GLP.END_DATE
--	AND		pel.suspense_org_account_id = pos.organization_account_id(+)
--   	AND 		pel.gl_code_combination_id = gcc.code_combination_id
--   	AND		gcc.chart_of_accounts_id = sob.chart_of_accounts_id
	GROUP BY	sob.set_of_books_id,
			glp.end_date,
			pel.person_id,
			pel.dr_cr_flag,
			pel.gl_project_flag,
			pel.gl_code_combination_id;
--			decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id);

	CURSOR 	enc_sum_lines_g3_cur(p_enc_control_id	IN  NUMBER) IS
   	SELECT 	sob.set_of_books_id,
		glp.end_date eff_dt,
		pel.dr_cr_flag,
		sum(pel.encumbrance_amount) sum_amt,
		pel.gl_project_flag,
		pel.gl_code_combination_id gl_ccid
--		,decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id) gl_ccid
   	FROM		PSP_ENC_LINES  		PEL,
			GL_PERIODS	GLP,
			GL_SETS_OF_BOOKS SOB
--			,GL_CODE_COMBINATIONS GCC,
--			PSP_ORGANIZATION_ACCOUNTS POS
	WHERE		sob.set_of_books_id = g_set_of_books_id
   	AND		sob.accounted_period_type = glp.period_type
   	AND 		PEL.GL_PROJECT_FLAG = 'G'
   	AND		PEL.ENCUMBRANCE_AMOUNT <> 0
	AND		PEL.ENC_CONTROL_ID = p_enc_control_id
	AND		PEL.ENCUMBRANCE_DATE BETWEEN GLP.START_DATE AND GLP.END_DATE
--   	AND 		pel.gl_code_combination_id = gcc.code_combination_id
--   	AND		gcc.chart_of_accounts_id = sob.chart_of_accounts_id
--	AND		pel.suspense_org_account_id = pos.organization_account_id(+)
	GROUP BY	sob.set_of_books_id,
			glp.end_date,
			pel.dr_cr_flag,
			pel.gl_project_flag,
			pel.gl_code_combination_id;
--			,decode(suspense_org_account_id, null, pel.gl_code_combination_id, pos.gl_code_combination_id);

	l_time_para_value		VARCHAR2(1);
	l_gl_para_value			VARCHAR2(1);
	commented above variables as part of enh. Quick Upd. Enc., bug 2143723

************************************************************************************** /

	enc_sum_lines_p1_rec		enc_sum_lines_p1_cur%ROWTYPE;

/ ***********************************************************************************
	Commented cursors p2_cur and p3_cur as part of Enh. 2143723

	enc_sum_lines_p2_rec		enc_sum_lines_p2_cur%ROWTYPE;
	enc_sum_lines_p3_rec		enc_sum_lines_p3_cur%ROWTYPE;
	enc_sum_lines_g1_rec		enc_sum_lines_g1_cur%ROWTYPE;
	enc_sum_lines_g2_rec		enc_sum_lines_g2_cur%ROWTYPE;
	enc_sum_lines_g3_rec		enc_sum_lines_g3_cur%ROWTYPE;


 Commented out as part of bug fix 1971612/1831493 --gl period option obsolete
*************************************************************************************** /

	l_bg_id				NUMBER(15) := g_business_group_id;
	l_set_of_books_id		NUMBER(15);
	l_enc_summary_line_id		NUMBER(10);
	l_return_status			VARCHAR2(10);
	enc_control_rec			enc_control_cur%ROWTYPE;
   	l_error			VARCHAR2(100);
	l_product		VARCHAR2(3);
	l_gl_ccid	NUMBER(15);
BEGIN
 --insert_into_psp_stout( 'create gl_enc_sum_lines' );
/ *	Commenting out the following code as Enc. Sum. and Tr. will not be based on Setup options
	but based on Person, Assignment and CI for each time period for Enh. 2143723
	BEGIN
 	SELECT 	parameter_value
 	INTO	l_time_para_value
 	FROM	psp_enc_setup_options
 	WHERE	setup_parameter = 'TIME_BASED_SUMM'
	AND	business_group_id = l_bg_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_error := 'TIME_BASED_SUMM';
		l_product := 'PSP';
		fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
		fnd_message.set_token('ERROR',l_error);
		fnd_message.set_token('PRODUCT',l_product);
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

  	BEGIN
	SELECT 	parameter_value
	INTO	l_gl_para_value
	FROM	psp_enc_setup_options
	WHERE	setup_parameter = 'CI_BASED_SUMM_GL'
	AND	business_group_id = l_bg_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_error := 'CI_BASED_SUMM_GL';
		l_product := 'PSP';
		fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
		fnd_message.set_token('ERROR',l_error);
		fnd_message.set_token('PRODUCT',l_product);
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

     	IF	l_time_para_value = '1' and l_gl_para_value = '3' THEN

End of Enh. fix 2143723	* /

	OPEN enc_control_cur;
  	LOOP
     	    	FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

		OPEN enc_sum_lines_p1_cur(enc_control_rec.enc_control_id);
		LOOP
			FETCH enc_sum_lines_p1_cur INTO enc_sum_lines_p1_rec;
			IF enc_sum_lines_p1_cur%ROWCOUNT = 0 THEN
			  CLOSE enc_sum_lines_p1_cur;
			  EXIT;
    			ELSIF enc_sum_lines_p1_cur%NOTFOUND THEN
                	   update psp_enc_controls
                   	      set gl_phase = 'Summarize' ---NULL ... for 2444657
                 	    where enc_control_id = enc_control_rec.enc_control_id;
       			CLOSE enc_sum_lines_p1_cur;
       			EXIT;
     			END IF;

			insert_into_enc_sum_lines(
							l_enc_summary_line_id,
							l_bg_id,
							enc_control_rec.enc_control_id,
							enc_control_rec.time_period_id,
							enc_sum_lines_p1_rec.person_id,
							enc_sum_lines_p1_rec.assignment_id,
                					enc_sum_lines_p1_rec.eff_dt,
--							enc_sum_lines_p1_rec.set_of_books_id,
							g_set_of_books_id,
							enc_sum_lines_p1_rec.gl_ccid,
							NULL,
 							NULL,
 							NULL,
 							NULL,
 							NULL,
 							enc_sum_lines_p1_rec.sum_amt,
 							enc_sum_lines_p1_rec.dr_cr_flag,
							'N',
							enc_control_rec.payroll_id,
 							NULL,
							enc_sum_lines_p1_rec.gl_project_flag,
							enc_sum_lines_p1_rec.attribute_category,	-- Introduced DFF columns for bug fix 2908859
							enc_sum_lines_p1_rec.attribute1,
							enc_sum_lines_p1_rec.attribute2,
							enc_sum_lines_p1_rec.attribute3,
							enc_sum_lines_p1_rec.attribute4,
							enc_sum_lines_p1_rec.attribute5,
							enc_sum_lines_p1_rec.attribute6,
							enc_sum_lines_p1_rec.attribute7,
							enc_sum_lines_p1_rec.attribute8,
							enc_sum_lines_p1_rec.attribute9,
							enc_sum_lines_p1_rec.attribute10,
							l_return_status);

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			IF (g_dff_grouping_option = 'N') THEN	-- Introduced for bug fix 2908859
				UPDATE 	psp_enc_lines
         			SET 	enc_summary_line_id = l_enc_summary_line_id
         			WHERE 	enc_control_id = enc_control_rec.enc_control_id
         			AND	payroll_id = enc_control_rec.payroll_id
				AND	time_period_id = enc_control_rec.time_period_id
         			AND	person_id = enc_sum_lines_p1_rec.person_id
         			AND	assignment_id = enc_sum_lines_p1_rec.assignment_id
         			AND	dr_cr_flag = enc_sum_lines_p1_rec.dr_cr_flag
         			AND	gl_project_flag = enc_sum_lines_p1_rec.gl_project_flag
                        	AND     trunc(encumbrance_date) = trunc(enc_sum_lines_p1_rec.eff_dt)  --- added for 3462452
--	Enhanced the following check to accomodate suspense postings done in this process for bug fix 3194807.
--                        ANd gl_code_combination_id =enc_sum_lines_p1_rec.gl_ccid;
				AND	(	(suspense_org_account_id IS NOT NULL
						AND	suspense_reason_code like 'ES:%'
						AND	EXISTS	(SELECT	1	FROM psp_organization_accounts poa
								WHERE	poa.organization_account_id = suspense_org_account_id
								AND	poa.gl_code_combination_id = enc_sum_lines_p1_rec.gl_ccid))
					OR	gl_code_combination_id = enc_sum_lines_p1_rec.gl_ccid);
--	Introduced ELSE portion for bug fix 2908859
			ELSE
				UPDATE 	psp_enc_lines
         			SET 	enc_summary_line_id = l_enc_summary_line_id
         			WHERE 	enc_control_id = enc_control_rec.enc_control_id
         			AND	payroll_id = enc_control_rec.payroll_id
				AND	time_period_id = enc_control_rec.time_period_id
         			AND	person_id = enc_sum_lines_p1_rec.person_id
         			AND	assignment_id = enc_sum_lines_p1_rec.assignment_id
         			AND	dr_cr_flag = enc_sum_lines_p1_rec.dr_cr_flag
         			AND	gl_project_flag = enc_sum_lines_p1_rec.gl_project_flag
                        	AND     trunc(encumbrance_date) = trunc(enc_sum_lines_p1_rec.eff_dt)  --- added for 3462452
				AND	(	(suspense_org_account_id IS NOT NULL
						AND	suspense_reason_code like 'ES:%'
						AND	EXISTS	(SELECT	1	FROM psp_organization_accounts poa
								WHERE	poa.organization_account_id = suspense_org_account_id
								AND	poa.gl_code_combination_id = enc_sum_lines_p1_rec.gl_ccid
								AND	NVL(poa.attribute_category, 'NULL') =
									NVL(enc_sum_lines_p1_rec.attribute_category, 'NULL')
								AND	NVL(poa.attribute1, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute1, 'NULL')
								AND	NVL(poa.attribute2, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute2, 'NULL')
								AND	NVL(poa.attribute3, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute3, 'NULL')
								AND	NVL(poa.attribute4, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute4, 'NULL')
								AND	NVL(poa.attribute5, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute5, 'NULL')
								AND	NVL(poa.attribute6, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute6, 'NULL')
								AND	NVL(poa.attribute7, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute7, 'NULL')
								AND	NVL(poa.attribute8, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute8, 'NULL')
								AND	NVL(poa.attribute9, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute9, 'NULL')
								AND	NVL(poa.attribute10, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute10, 'NULL')))
					OR (	gl_code_combination_id = enc_sum_lines_p1_rec.gl_ccid
						AND	NVL(attribute_category, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute_category, 'NULL')
						AND	NVL(attribute1, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute1, 'NULL')
						AND	NVL(attribute2, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute2, 'NULL')
						AND	NVL(attribute3, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute3, 'NULL')
						AND	NVL(attribute4, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute4, 'NULL')
						AND	NVL(attribute5, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute5, 'NULL')
						AND	NVL(attribute6, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute6, 'NULL')
						AND	NVL(attribute7, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute7, 'NULL')
						AND	NVL(attribute8, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute8, 'NULL')
						AND	NVL(attribute9, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute9, 'NULL')
						AND	NVL(attribute10, 'NULL') = NVL(enc_sum_lines_p1_rec.attribute10, 'NULL')));
--	Introduced ELSE portion for bug fix 2908859
			END IF;
/ *  added the check on gl_code_combination_id since group by clause has it * /

		END LOOP;

	END LOOP;

/ *	Commenting the following as Enc Sum. and Tr. options is now obsolete for Enh. 2143723

	ELSIF	l_time_para_value = '1' and l_gl_para_value = '2' THEN
	OPEN enc_control_cur;
  	LOOP
    	FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

		OPEN enc_sum_lines_p2_cur(enc_control_rec.enc_control_id);
		LOOP
     			FETCH enc_sum_lines_p2_cur INTO enc_sum_lines_p2_rec;
			IF enc_sum_lines_p2_cur%ROWCOUNT = 0 THEN
			  CLOSE enc_sum_lines_p2_cur;
			  EXIT;
    			ELSIF enc_sum_lines_p2_cur%NOTFOUND THEN
                	   update psp_enc_controls
                   	      set gl_phase = 'Summarize' ---NULL  for 2444657
                 	    where enc_control_id = enc_control_rec.enc_control_id;
       			CLOSE enc_sum_lines_p2_cur;
       			EXIT;
     			END IF;
					insert_into_enc_sum_lines(
							l_enc_summary_line_id,
							l_bg_id,
							enc_control_rec.enc_control_id,
							enc_control_rec.time_period_id,
							enc_sum_lines_p2_rec.person_id,
							NULL,
                					enc_sum_lines_p2_rec.eff_dt,
--							enc_sum_lines_p2_rec.set_of_books_id,
							g_set_of_books_id,
							enc_sum_lines_p2_rec.gl_ccid,
							NULL,
 							NULL,
 							NULL,
 							NULL,
 							NULL,
 							enc_sum_lines_p2_rec.sum_amt,
 							enc_sum_lines_p2_rec.dr_cr_flag,
							'N',
							enc_control_rec.payroll_id,
 							NULL,
							enc_sum_lines_p2_rec.gl_project_flag,
							l_return_status);

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			UPDATE 	psp_enc_lines
         		SET 	enc_summary_line_id = l_enc_summary_line_id
         		WHERE 	enc_control_id = enc_control_rec.enc_control_id
         		AND	payroll_id = enc_control_rec.payroll_id
			ANd	time_period_id = enc_control_rec.time_period_id
--                       added check on gl_ccid - subha 22 Mar
			AND	gl_code_combination_id = enc_sum_lines_p2_rec.gl_ccid
         		AND	person_id = enc_sum_lines_p2_rec.person_id
         		AND	dr_cr_flag = enc_sum_lines_p2_rec.dr_cr_flag
         		AND	gl_project_flag = enc_sum_lines_p2_rec.gl_project_flag;

     		END LOOP;

	END LOOP;
	ELSIF	l_time_para_value = '1' and l_gl_para_value = '1' THEN
	OPEN enc_control_cur;
  	LOOP
     	    	FETCH enc_control_cur INTO enc_control_rec;

   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

		OPEN enc_sum_lines_p3_cur(enc_control_rec.enc_control_id);
		LOOP
			FETCH enc_sum_lines_p3_cur INTO enc_sum_lines_p3_rec;
			IF enc_sum_lines_p3_cur%ROWCOUNT = 0 THEN
			  CLOSE enc_sum_lines_p3_cur;
			  EXIT;
    			ELSIF enc_sum_lines_p3_cur%NOTFOUND THEN
                	   update psp_enc_controls
                   	      set gl_phase = 'Summarize' ---NULL commented for 2444657
                 	    where enc_control_id = enc_control_rec.enc_control_id;
       			CLOSE enc_sum_lines_p3_cur;
       			EXIT;
     			END IF;
				insert_into_enc_sum_lines(
							l_enc_summary_line_id,
							l_bg_id,
							enc_control_rec.enc_control_id,
							enc_control_rec.time_period_id,
							NULL,
							NULL,
							enc_sum_lines_p3_rec.eff_dt,
--							enc_sum_lines_p3_rec.set_of_books_id,
							g_set_of_books_id,
							enc_sum_lines_p3_rec.gl_ccid,
							NULL,
 							NULL,
 							NULL,
 							NULL,
 							NULL,
 							enc_sum_lines_p3_rec.sum_amt,
 							enc_sum_lines_p3_rec.dr_cr_flag,
							'N',
							enc_control_rec.payroll_id,
 							NULL,
							enc_sum_lines_p3_rec.gl_project_flag,
							l_return_status);

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			UPDATE 	psp_enc_lines
         		SET 	enc_summary_line_id = l_enc_summary_line_id
         		WHERE 	enc_control_id = enc_control_rec.enc_control_id
			AND	time_period_id = enc_control_rec.time_period_id
			AND	payroll_id = enc_control_rec.payroll_id
         		AND	dr_cr_flag = enc_sum_lines_p3_rec.dr_cr_flag
         		AND	gl_code_combination_id = enc_sum_lines_p3_rec.gl_ccid
         		AND	gl_project_flag = enc_sum_lines_p3_rec.gl_project_flag;

     		END LOOP;

	END LOOP;

/ *

 This code is obsolete and the summarize by gl_period option is no longer supported  refer bug 1831493


	ELSIF	l_time_para_value = '2' and l_gl_para_value = '3' THEN
	OPEN enc_control_cur;
  	LOOP
     	    	FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

		OPEN enc_sum_lines_g1_cur(enc_control_rec.enc_control_id);
		LOOP
			FETCH enc_sum_lines_g1_cur INTO enc_sum_lines_g1_rec;
			IF enc_sum_lines_g1_cur%ROWCOUNT = 0 THEN
			  CLOSE enc_sum_lines_g1_cur;
			  EXIT;
    			ELSIF enc_sum_lines_g1_cur%NOTFOUND THEN
                	   update psp_enc_controls
                   	      set gl_phase = 'Summarize' --- replaced NULL for 2444657
                 	    where enc_control_id = enc_control_rec.enc_control_id;
       			CLOSE enc_sum_lines_g1_cur;
       			EXIT;
     			END IF;
			insert_into_enc_sum_lines(
							l_enc_summary_line_id,
							l_bg_id,
							enc_control_rec.enc_control_id,
							enc_control_rec.time_period_id,
							enc_sum_lines_g1_rec.person_id,
							enc_sum_lines_g1_rec.assignment_id,
                					enc_sum_lines_g1_rec.eff_dt,
							g_set_of_books_id,
							enc_sum_lines_g1_rec.gl_ccid,
							NULL,
 							NULL,
 							NULL,
 							NULL,
 							NULL,
 							enc_sum_lines_g1_rec.sum_amt,
 							enc_sum_lines_g1_rec.dr_cr_flag,
							'N',
							enc_control_rec.payroll_id,
 							NULL,
							enc_sum_lines_g1_rec.gl_project_flag,
							l_return_status);

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			UPDATE 	psp_enc_lines
         		SET 	enc_summary_line_id = l_enc_summary_line_id
         		WHERE 	enc_control_id = enc_control_rec.enc_control_id
			AND	time_period_id = enc_control_rec.time_period_id
			AND	payroll_id = enc_control_rec.payroll_id
         		AND	person_id = enc_sum_lines_g1_rec.person_id
         		AND	assignment_id = enc_sum_lines_g1_rec.assignment_id
         		AND	dr_cr_flag = enc_sum_lines_g1_rec.dr_cr_flag
         		AND	gl_code_combination_id = enc_sum_lines_g1_rec.gl_ccid
         		AND	gl_project_flag = enc_sum_lines_g1_rec.gl_project_flag;

		END LOOP;

	END LOOP;
	ELSIF	l_time_para_value = '2' and l_gl_para_value = '2' THEN
	OPEN enc_control_cur;
  	LOOP
     	    	FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

		OPEN enc_sum_lines_g2_cur(enc_control_rec.enc_control_id);
		LOOP
     			FETCH enc_sum_lines_g2_cur INTO enc_sum_lines_g2_rec;
			IF enc_sum_lines_g2_cur%ROWCOUNT = 0 THEN
			  CLOSE enc_sum_lines_g2_cur;
			  EXIT;
    			ELSIF enc_sum_lines_g2_cur%NOTFOUND THEN
                	   update psp_enc_controls
                   	      set gl_phase = 'Summarize'  ---replaced NULL  for 2444657
                 	    where enc_control_id = enc_control_rec.enc_control_id;
       			CLOSE enc_sum_lines_g2_cur;
       			EXIT;
     			END IF;

			insert_into_enc_sum_lines(
							l_enc_summary_line_id,
							l_bg_id,
							enc_control_rec.enc_control_id,
							enc_control_rec.time_period_id,
							enc_sum_lines_g2_rec.person_id,
							NULL,
                					enc_sum_lines_g2_rec.eff_dt,
							enc_sum_lines_g2_rec.set_of_books_id,
							enc_sum_lines_g2_rec.gl_ccid,
							NULL,
 							NULL,
 							NULL,
 							NULL,
 							NULL,
 							enc_sum_lines_g2_rec.sum_amt,
 							enc_sum_lines_g2_rec.dr_cr_flag,
							'N',
							enc_control_rec.payroll_id,
 							NULL,
							enc_sum_lines_g2_rec.gl_project_flag,
							l_return_status);

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			UPDATE 	psp_enc_lines
         		SET 	enc_summary_line_id = l_enc_summary_line_id
         		WHERE 	enc_control_id = enc_control_rec.enc_control_id
         		AND	payroll_id = enc_control_rec.payroll_id
			AND	time_period_id = enc_control_rec.time_period_id
         		AND	person_id = enc_sum_lines_g2_rec.person_id
         		AND	dr_cr_flag = enc_sum_lines_g2_rec.dr_cr_flag
         		AND	gl_code_combination_id = enc_sum_lines_g2_rec.gl_ccid
         		AND	gl_project_flag = enc_sum_lines_g2_rec.gl_project_flag;

   		END LOOP;

	END LOOP;
	ELSIF	l_time_para_value = '2' and l_gl_para_value = '1' THEN
	OPEN enc_control_cur;
  	LOOP
     	    	FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

		OPEN enc_sum_lines_g3_cur(enc_control_rec.enc_control_id);
		LOOP
     			FETCH enc_sum_lines_g3_cur INTO enc_sum_lines_g3_rec;
			IF enc_sum_lines_g3_cur%ROWCOUNT = 0 THEN
			  CLOSE enc_sum_lines_g3_cur;
			  EXIT;
    			ELSIF enc_sum_lines_g3_cur%NOTFOUND THEN
                	   update psp_enc_controls
                   	      set gl_phase =  'Summarize' -- replaced NULL for 2444657
                 	    where enc_control_id = enc_control_rec.enc_control_id;
       			CLOSE enc_sum_lines_g3_cur;
       			EXIT;
     			END IF;

        		insert_into_enc_sum_lines(
							l_enc_summary_line_id,
							l_bg_id,
							enc_control_rec.enc_control_id,
							enc_control_rec.time_period_id,
							NULL,
							NULL,
							enc_sum_lines_g3_rec.eff_dt,
							enc_sum_lines_g3_rec.set_of_books_id,
							enc_sum_lines_g3_rec.gl_ccid,
							NULL,
 							NULL,
 							NULL,
 							NULL,
 							NULL,
 							enc_sum_lines_g3_rec.sum_amt,
 							enc_sum_lines_g3_rec.dr_cr_flag,
							'N',
							enc_control_rec.payroll_id,
 							NULL,
							enc_sum_lines_g3_rec.gl_project_flag,
							l_return_status);

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			UPDATE 	psp_enc_lines
         		SET 	enc_summary_line_id = l_enc_summary_line_id
         		WHERE 	enc_control_id = enc_control_rec.enc_control_id
         		AND	payroll_id = enc_control_rec.payroll_id
			AND	time_period_id = enc_control_rec.time_period_id
         		AND	dr_cr_flag = enc_sum_lines_g3_rec.dr_cr_flag
         	AND	gl_code_combination_id = enc_sum_lines_g3_rec.gl_ccid
         		AND	gl_project_flag = enc_sum_lines_g3_rec.gl_project_flag;

     		END LOOP;

     	END LOOP;

	END IF; -- Commented this END IF as part of Enh. 2143723
*************************************************************************************************** /

	p_return_status	:= fnd_api.g_ret_sts_success;

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     		g_error_api_path := 'CREATE_GL_ENC_SUM_LINES:'||g_error_api_path;
     		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','ENC_SUM_TRANS');
      		p_return_status := fnd_api.g_ret_sts_unexp_error;
	WHEN OTHERS THEN
     		g_error_api_path := 'CREATE_GL_ENC_SUM_LINES:'||g_error_api_path;
     		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','CREATE_GL_ENC_SUM_LINES');
     		p_return_status := fnd_api.g_ret_sts_unexp_error;
END;
	End of comment for Create and Update enh.	*****/

--	##########################################################################
--	This procedure inserts records into psp_enc_summary_lines
--	##########################################################################

PROCEDURE insert_into_enc_sum_lines(
				p_enc_summary_line_id	OUT NOCOPY NUMBER,
				p_business_group_id	IN  NUMBER,
				p_enc_control_id	IN  NUMBER,
				p_time_period_id	IN  NUMBER,
				p_person_id		IN  NUMBER,
				p_assignment_id		IN  NUMBER,
				p_effective_date	IN  DATE,
				p_set_of_books_id	IN  NUMBER,
				p_gl_code_combination_id IN  NUMBER,
				p_project_id		IN  NUMBER,
				p_expenditure_organization_id IN  NUMBER,
				p_expenditure_type	IN  VARCHAR2,
				p_task_id		IN  NUMBER,
				p_award_id		IN  NUMBER,
				p_summary_amount	IN  NUMBER,
				p_dr_cr_flag		IN  VARCHAR2,
				p_status_code		IN  VARCHAR2,
				p_payroll_id		IN  NUMBER,
				p_gl_period_id		IN  NUMBER,
				p_gl_project_flag	IN  VARCHAR2,
				p_attribute_category	IN	VARCHAR2,	-- Introduced DFF columns for bug fix 2908859
				p_attribute1		IN	VARCHAR2,
				p_attribute2		IN	VARCHAR2,
				p_attribute3		IN	VARCHAR2,
				p_attribute4		IN	VARCHAR2,
				p_attribute5		IN	VARCHAR2,
				p_attribute6		IN	VARCHAR2,
				p_attribute7		IN	VARCHAR2,
				p_attribute8		IN	VARCHAR2,
				p_attribute9		IN	VARCHAR2,
				p_attribute10		IN	VARCHAR2,
				p_return_status		OUT NOCOPY  VARCHAR2
				) IS
BEGIN
	SELECT PSP_ENC_SUMMARY_LINES_S.NEXTVAL
    	INTO P_ENC_SUMMARY_LINE_ID
    	FROM DUAL;
    		INSERT INTO PSP_ENC_SUMMARY_LINES(
						ENC_SUMMARY_LINE_ID,
						BUSINESS_GROUP_ID,
						ENC_CONTROL_ID,
						TIME_PERIOD_ID,
						PERSON_ID,
						ASSIGNMENT_ID,
						EFFECTIVE_DATE,
						SET_OF_BOOKS_ID,
						GL_CODE_COMBINATION_ID,
						PROJECT_ID,
						EXPENDITURE_ORGANIZATION_ID,
						EXPENDITURE_TYPE,
						TASK_ID,
						AWARD_ID,
						SUMMARY_AMOUNT,
						DR_CR_FLAG,
						STATUS_CODE,
						PAYROLL_ID,
						GL_PERIOD_ID,
						GL_PROJECT_FLAG,
						ATTRIBUTE_CATEGORY,		-- Introduced DFF columns for bug fix 2908859
						ATTRIBUTE1,
						ATTRIBUTE2,
						ATTRIBUTE3,
						ATTRIBUTE4,
						ATTRIBUTE5,
						ATTRIBUTE6,
						ATTRIBUTE7,
						ATTRIBUTE8,
						ATTRIBUTE9,
						ATTRIBUTE10,
						LAST_UPDATE_DATE,
						LAST_UPDATED_BY,
						LAST_UPDATE_LOGIN,
						CREATED_BY,
						CREATION_DATE)
    					VALUES(
						p_enc_summary_line_id,
						p_business_group_id,
						p_enc_control_id,
						p_time_period_id,
						nvl(p_person_id,NULL),
						nvl(p_assignment_id,NULL),
						p_effective_date,
						p_set_of_books_id,
						p_gl_code_combination_id,
						p_project_id,
						p_expenditure_organization_id,
						p_expenditure_type,
						p_task_id,
						p_award_id,
						p_summary_amount,
						p_dr_cr_flag,
						p_status_code,
						p_payroll_id,
						p_gl_period_id,
						p_gl_project_flag,
						p_attribute_category,		-- Introduced DFF columns for bug fix 2908859
						p_attribute1,
						p_attribute2,
						p_attribute3,
						p_attribute4,
						p_attribute5,
						p_attribute6,
						p_attribute7,
						p_attribute8,
						p_attribute9,
						p_attribute10,
						SYSDATE,
						FND_GLOBAL.USER_ID,
						FND_GLOBAL.LOGIN_ID,
						FND_GLOBAL.USER_ID,
						SYSDATE);
		p_return_status	:= fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
     		g_error_api_path := 'INSERT_INTO_ENC_SUM_LINES:'||g_error_api_path;
     		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','INSERT_INTO_ENC_SUM_LINES');
     		p_return_status := fnd_api.g_ret_sts_unexp_error;
END;

--	##########################################################################
--	This procedure transfers the summarized lines from psp_enc_summary_lines
--		with gl_project_flag = 'G' to gl_interface

--	This procedure transfers the summarized lines from PSP_ENC_SUMMARY_LINES table
--	to GL_INTERFACE table and kicks off the JOURNAL IMPORT program in GL and sends
--	ENC_CONTROL_ID and END_DATE for the relevant TIME_PERIOD_ID
--	and GROUP_ID into the tie back procedure
--	##########################################################################
/******	Commented for Create and Update multi thread enh.
PROCEDURE tr_to_gl_int(p_payroll_id IN NUMBER,
			p_return_status	OUT NOCOPY  VARCHAR2
			) IS

	CURSOR 	enc_control_cur IS
   	SELECT 	enc_control_id,
          	payroll_id,
		time_period_id,
                gl_phase                       --- added for 2444657
   	FROM   	psp_enc_controls
   	WHERE 	payroll_id = nvl(p_payroll_id, payroll_id)
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type IN ('N', 'Q', 'U') -- Included 'Q' for Quick Upd. Enh. 2143723.
   	AND    	action_code = 'I'
   	AND    	run_id = g_run_id
   	AND	business_group_id = g_business_group_id
	AND	set_of_books_id = g_set_of_books_id
        AND     gl_phase in ('Summarize', 'Transfer');

	CURSOR	int_cur(l_enc_control_id IN NUMBER) IS
	SELECT	pesl.enc_summary_line_id,
		pesl.effective_date,
		pesl.gl_code_combination_id,
		pesl.summary_amount,
		pesl.dr_cr_flag,
		pesl.set_of_books_id,
	  pesl.time_period_id,
	  pesl.attribute1,
          pesl.attribute2,
          pesl.attribute3,
          pesl.attribute4,
          pesl.attribute5,
          pesl.attribute6,
          pesl.attribute7,
          pesl.attribute8,
          pesl.attribute9,
          pesl.attribute10,
          pesl.attribute11,
          pesl.attribute12,
          pesl.attribute13,
          pesl.attribute14,
          pesl.attribute15,
          pesl.attribute16,
          pesl.attribute17,
          pesl.attribute18,
          pesl.attribute19,
          pesl.attribute20,
          pesl.attribute21,
          pesl.attribute22,
          pesl.attribute23,
          pesl.attribute24,
          pesl.attribute25,
          pesl.attribute26,
          pesl.attribute27,
          pesl.attribute28,
          pesl.attribute29,
          pesl.attribute30
	FROM	psp_enc_summary_lines pesl
	WHERE 	pesl.status_code = 'N'
	AND	pesl.enc_control_id = l_enc_control_id
	AND	pesl.payroll_id = p_payroll_id
	AND	pesl.gl_code_combination_id is NOT NULL;

	enc_control_rec		enc_control_cur%ROWTYPE;
	int_rec			int_cur%ROWTYPE;

	l_bg_id			NUMBER(15) := g_business_group_id;
	l_sob_id		NUMBER(15);
	l_status		VARCHAR2(50);
	l_acc_date		DATE;
	l_user_je_cat	 	VARCHAR2(25);
	l_user_je_source	VARCHAR2(25);
	l_period_name		VARCHAR2(35);
	l_period_end_dt		DATE;
	l_enc_type_id		NUMBER(15);
	l_ent_dr		NUMBER;
	l_ent_cr		NUMBER;
	l_group_id		NUMBER;
	l_int_run_id		NUMBER;
	l_ref1			VARCHAR2(100);
	l_ref4			VARCHAR2(100);

	l_return_status		VARCHAR2(10);
	req_id			NUMBER(15);
	call_status		BOOLEAN;
	rphase			VARCHAR2(30);
	rstatus			VARCHAR2(30);
	dphase			VARCHAR2(30);
	dstatus			VARCHAR2(30);
	message			VARCHAR2(240);
	p_errbuf		VARCHAR2(32767);
	p_retcode		VARCHAR2(32767);
	return_back		EXCEPTION;
	l_rec_count		NUMBER := 0;
	l_error			VARCHAR2(100);
	l_product		VARCHAR2(3);
	l_value			VARCHAR2(200);
	l_table			VARCHAR2(100);
	l_rec_no 		number := 0;
        / * Following variable is added for Enh.Encumbrance Redesign Prorata * /

    	l_summarization_option VARCHAR2 (1) :=  nvl (fnd_profile.value('PSP_ENABLE_ENC_SUMM_GL'),'N');

	TYPE GL_TIE_RECTYPE IS RECORD (
		R_CONTROL_ID	NUMBER,
		R_END_DATE	DATE,
                R_GROUP_ID      NUMBER);   ---- added group_id for 2444657, Summ. and Transfer will scoop all
                                           --- controls with 'I', 'N'. Those with 'N' will have
                                       -- new group_id, where as once with 'I' have old group_id


	GL_TIE_REC	GL_TIE_RECTYPE;

	TYPE GL_TIE_TABTYPE IS TABLE OF GL_TIE_REC%TYPE
		INDEX BY BINARY_INTEGER;

	GL_TIE_TAB	GL_TIE_TABTYPE;

--	Introduced the following for bug fix 4507892
	TYPE t_number_15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
	TYPE r_enc_control_rec IS RECORD (enc_control_id	t_number_15_type);
	r_enc_controls	r_enc_control_rec;

	CURSOR	enc_control_id_cur IS
	SELECT	DISTINCT enc_control_id
	FROM	psp_enc_summary_lines
	WHERE	group_id = l_group_id;
--	End of changes for bug fix 4507892
BEGIN
	gl_tie_tab.delete;

	gl_je_source(	l_user_je_source,
			l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	gl_je_cat(	l_user_je_cat,
			l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	enc_type(	l_enc_type_id,
			l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	SELECT 	gl_interface_control_s.nextval
	INTO	l_group_id
	FROM 	dual;

	OPEN enc_control_cur;
  	LOOP
   		FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

/ *	Moved this portion of the code outside the loop so as to take care of control record
	with no child records, Fixed as part of Enh. 2143723 (base bug 2124607).
		l_rec_no := l_rec_no +1;

		gl_tie_tab(l_rec_no).r_control_id := enc_control_rec.enc_control_id;

		UPDATE	psp_enc_summary_lines
		SET	group_id = l_group_id
		WHERE	status_code = 'N'
		AND	gl_code_combination_id is NOT NULL
		AND	enc_control_id = enc_control_rec.enc_control_id;
End of enh. fix 2143723	* /

-- For Bug 2478000
-- The following was commented
/ *
		BEGIN
			SELECT	currency_code
			INTO	l_cur_code
			FROM 	gl_sets_of_books
			WHERE	set_of_books_id = g_set_of_books_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			l_error := 'CURRENCY CODE';
			l_product := 'GL';
			fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
			fnd_message.set_token('ERROR',l_error);
			fnd_message.set_token('PRODUCT',l_product);
			fnd_msg_pub.add;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END;  * /

--End of bug 2478000

		BEGIN
			SELECT	period_name, end_date
			INTO	l_period_name, l_period_end_dt
			FROM 	per_time_periods
			WHERE	time_period_id = enc_control_rec.time_period_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			l_value := 'time period id =';
			l_table := 'PER_TIME_PERIODS';
			fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE','l_value');
			fnd_message.set_token('TABLE','l_table');
			fnd_msg_pub.add;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END;

		---l_rec_count := 0; --  commented for 2444657
             if enc_control_rec.gl_phase = 'Summarize' then   ---2444657
		OPEN int_cur (enc_control_rec.enc_control_id);
		---l_rec_count := 0;
		LOOP
			FETCH int_cur into int_rec;
			IF int_cur%NOTFOUND THEN
			CLOSE int_cur;
			EXIT;
			END IF;

		l_sob_id := int_rec.set_of_books_id;

			l_ref1          :=      l_period_name;
       		         l_ref4          :=      'LD ENCUMBRANCE';

			l_rec_count 	:=	l_rec_count + 1;

			IF int_rec.dr_cr_flag = 'D' THEN
				l_ent_dr	:=	int_rec.summary_amount;
				l_ent_cr	:=	NULL;
			ELSIF int_rec.dr_cr_flag = 'C' THEN
				l_ent_dr	:=	NULL;
				l_ent_cr	:=	int_rec.summary_amount;
			END IF;

				insert_into_gl_int(
						INT_REC.SET_OF_BOOKS_ID,
						INT_REC.EFFECTIVE_DATE,
						G_CURRENCY_CODE,
                				L_USER_JE_CAT,
						L_USER_JE_SOURCE,
						L_ENC_TYPE_ID,
		    				INT_REC.GL_CODE_COMBINATION_ID,
						L_ENT_DR,
						L_ENT_CR,
                				L_GROUP_ID,
						L_REF1,
						L_REF1,
						L_REF4,
                				'E:' || INT_REC.ENC_SUMMARY_LINE_ID,
	                			L_REF4,
						INT_REC.ATTRIBUTE1,
						INT_REC.ATTRIBUTE2,
                				INT_REC.ATTRIBUTE3,
						INT_REC.ATTRIBUTE4,
                				INT_REC.ATTRIBUTE5,
						INT_REC.ATTRIBUTE6,
		    				INT_REC.ATTRIBUTE7,
						INT_REC.ATTRIBUTE8,
                				INT_REC.ATTRIBUTE9,
						INT_REC.ATTRIBUTE10,
                				INT_REC.ATTRIBUTE11,
						INT_REC.ATTRIBUTE12,
                				INT_REC.ATTRIBUTE13,
						INT_REC.ATTRIBUTE14,
                				INT_REC.ATTRIBUTE15,
						INT_REC.ATTRIBUTE16,
		    				INT_REC.ATTRIBUTE17,
						INT_REC.ATTRIBUTE18,
                				INT_REC.ATTRIBUTE19,
						INT_REC.ATTRIBUTE20,
                				INT_REC.ATTRIBUTE21,
						INT_REC.ATTRIBUTE22,
                				INT_REC.ATTRIBUTE23,
						INT_REC.ATTRIBUTE24,
                				INT_REC.ATTRIBUTE25,
						INT_REC.ATTRIBUTE26,
		    				INT_REC.ATTRIBUTE27,
						INT_REC.ATTRIBUTE28,
                				INT_REC.ATTRIBUTE29,
						INT_REC.ATTRIBUTE30,
                				L_RETURN_STATUS);

       			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       			END IF;
		END LOOP;	--int_cur loop
            end if;           --- 2444657
		/ * Commented out as part of bug fix #2142865
		gl_tie_tab(l_rec_no).r_end_date := l_period_end_dt;* /
--		Introduced the following as part of Enh. 2143723 (base bug 2124607)
--		(Code moved from inside int_cur loop to here)
		IF enc_control_rec.gl_phase = 'Summarize'  THEN
			UPDATE	psp_enc_summary_lines
			SET	group_id = l_group_id
			WHERE   status_code = 'N'
			AND     gl_code_combination_id is NOT NULL
			AND     enc_control_id = enc_control_rec.enc_control_id;
                        if sql%rowcount > 0 then --- 2444657
			  l_rec_no := l_rec_no +1;
			  gl_tie_tab(l_rec_no).r_control_id := enc_control_rec.enc_control_id;
			  gl_tie_tab(l_rec_no).r_end_date := l_period_end_dt;
                          gl_tie_tab(l_rec_no).r_group_id := l_group_id; --- added for 2444657
                        end if;
                ELSE
			l_rec_no := l_rec_no +1;
                        gl_tie_tab(l_rec_no).r_control_id := enc_control_rec.enc_control_id;
			gl_tie_tab(l_rec_no).r_end_date := l_period_end_dt;
                        select group_id
                        into gl_tie_tab(l_rec_no).r_group_id
                        from psp_enc_summary_lines
                        where gl_code_combination_id is NOT NULL
                          AND enc_control_id = enc_control_rec.enc_control_id
                          AND rownum =1;
		END IF;

           	END LOOP;	-- enc_cur

     		IF l_rec_count > 0 THEN    --- replaced l_rec_no with l_rec_count ..2444657

     		SELECT 	GL_JOURNAL_IMPORT_S.NEXTVAL
     		INTO 	l_int_run_id
     		FROM 	dual;

     			insert into gl_interface_control(
         					je_source_name,
        					status,
      						interface_run_id,
        					group_id,
                  				set_of_books_id)
       					VALUES (
                  				l_user_je_source,
         					'S',
                  				l_int_run_id,
                  				l_group_id,
                  				l_sob_id
          	       				);
-- Commented out the commit as we commit after submitting the request, 11i

--     	 COMMIT;
     			req_id := fnd_request.submit_request(
	    							'SQLGL',
         							'GLLEZL',
         							'',
         							'',
         							FALSE,
           							to_char(l_int_run_id),
            							to_char(l_sob_id),
           							'N',
          							'',
            							'',
          							l_summarization_option, --Added for Enh. Enc Redesign, Bug #2259310.
           							'W');	-- Changed 'n' to 'W' for bug fix 2908859

     		IF req_id = 0 THEN

       		fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
       		fnd_msg_pub.add;
       		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     		ELSE
/ *****	Converted the following UPDATE to BULK for R12 performance fixes
            UPDATE psp_enc_controls
               SET gl_phase = 'Transfer'
             WHERE enc_control_id in (select distinct enc_control_id
                                        from psp_enc_summary_lines
                                       where group_id = l_group_id);
	End of comment for bug fix 4507892	***** /

--	Introduced the following for bug fix 4507892
		OPEN enc_control_id_cur;
		FETCH enc_control_id_cur BULK COLLECT INTO r_enc_controls.enc_control_id;
		CLOSE enc_control_id_cur;

		FORALL I IN 1..r_enc_controls.enc_control_id.COUNT
		UPDATE	psp_enc_controls
		SET	gl_phase = 'Transfer'
		WHERE	enc_control_id = r_enc_controls.enc_control_id(I);

		r_enc_controls.enc_control_id.DELETE;
--	End of changes for bug fix 4507892

       		COMMIT;
      		call_status := fnd_concurrent.wait_for_request(req_id, 20, 0,
                rphase, rstatus, dphase, dstatus, message);

       			IF call_status = FALSE then
         		   fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
         		   fnd_msg_pub.add;
         		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       			END IF;
     		END IF;
		END IF;	-- l_rec_count > 0    --- moved from below ... for 2444657

		for i in 1..gl_tie_tab.count
		loop
		        / * Commented as part of bug fix #1776606
     			gl_enc_tie_back(gl_tie_tab(i).r_control_id,
			gl_tie_tab(i).r_end_date, l_group_id, g_business_group_id, g_set_of_books_id, l_return_status);  * /

			/ * Included as part of Bug fix # 1776606 * /
     			gl_enc_tie_back(gl_tie_tab(i).r_control_id,
			gl_tie_tab(i).r_end_date,
                        gl_tie_tab(i).r_group_id,  --- replaced l_group_id for 2444657,
                         g_business_group_id, g_set_of_books_id, 'N',
			 l_return_status);
     		       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	        	END IF;

		end loop;
/ *
     		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     		END IF;
 -- moved inside the loop

 For Bug fix 1776606
* /

 --- added this wrapper loop on delete gl_interface for 2444657
  --- this is to ensure that all interface recs are purged, incase
  -- the previous Ssummarize and Transfer did not
 for i in 1..gl_tie_tab.count
 loop
   if gl_tie_tab(i).r_group_id is not null then
    delete gl_interface
    where group_id = gl_tie_tab(i).r_group_id
    and user_je_source_name = l_user_je_source
    and set_of_books_id = l_sob_id;

        for k in 1..gl_tie_tab.count
        loop
          if gl_tie_tab(i).r_group_id = gl_tie_tab(k).r_group_id and
             i <> k then
               gl_tie_tab(k).r_group_id := null;
          end if;
        end loop;

        gl_tie_tab(i).r_group_id := null;
    end if;
 end loop;
     COMMIT; -- moved the commit from above for 2479579
    if g_susp_prob = 'Y' then   -- introduced this IF stmnt for 2479579
         enc_batch_end(g_payroll_action_id,
                       l_return_status);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

   p_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     	g_error_api_path := 'TR_TO_GL_INT:'||g_error_api_path;
     	p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN RETURN_BACK THEN
     	p_return_status := fnd_api.g_ret_sts_success;

   WHEN OTHERS THEN
     	g_error_api_path := 'TR_TO_GL_INT:'||g_error_api_path;
     	fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','TR_TO_GL_INT');
     	p_return_status := fnd_api.g_ret_sts_unexp_error;
END;
	End of comment for Create and Update multi thread enh.	*****/

--	Introduced the following modified tr_to_gl_int procedure for Create and Update multi thread enh.
PROCEDURE tr_to_gl_int( p_payroll_action_id	IN		NUMBER,
			p_return_status		OUT NOCOPY	VARCHAR2) IS
l_user_je_cat	 	VARCHAR2(25);
l_user_je_source	VARCHAR2(25);
l_enc_type_id		NUMBER(15);
l_group_id		NUMBER;
l_int_run_id		NUMBER;
l_return_status		VARCHAR2(10);
req_id			NUMBER(15);
call_status		BOOLEAN;
rphase			VARCHAR2(30);
rstatus			VARCHAR2(30);
dphase			VARCHAR2(30);
dstatus			VARCHAR2(30);
message			VARCHAR2(240);
l_tie_back_failed	VARCHAR2(1);
l_summarization_option VARCHAR2 (1);

TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

TYPE r_enc_controls_rec IS RECORD (enc_control_id	t_number_15);
r_enc_controls	r_enc_controls_rec;

TYPE r_group_rec IS RECORD (group_id	t_number_15);
r_groups	r_group_rec;

l_created_by	NUMBER(15);

CURSOR	gl_group_id_cur IS
SELECT	DISTINCT group_id
FROM	psp_enc_summary_lines pesl
WHERE	payroll_action_id = p_payroll_action_id
AND	status_code = 'N'
AND	superceded_line_id IS NULL
AND	gl_code_combination_id IS NOT NULL;

CURSOR	enc_control_id_cur IS
SELECT	enc_control_id
FROM	psp_enc_controls
WHERE	payroll_action_id = p_payroll_action_id;
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering Transfer to GL Interface');

	l_created_by := fnd_global.user_id;
	l_tie_back_failed := NULL;
	l_summarization_option :=  NVL(fnd_profile.value('PSP_ENABLE_ENC_SUMM_GL'),'N');

	gl_je_source(	l_user_je_source,
			l_return_status);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_user_je_source: ' || l_user_je_source);

	gl_je_cat(	l_user_je_cat,
			l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_user_je_cat: ' || l_user_je_cat);

	enc_type(	l_enc_type_id,
			l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_enc_type_id: ' || l_enc_type_id);

	SELECT 	gl_interface_control_s.nextval
	INTO	l_group_id
	FROM 	dual;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_group_id: ' || l_group_id);

	UPDATE	psp_enc_summary_lines pesl
	SET	group_id = l_group_id
	WHERE 	status_code = 'N'
	AND	gl_code_combination_id IS NOT NULL
	AND	group_id IS NULL
	AND	superceded_line_id IS NULL
	AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl2
				WHERE	pesl2.payroll_action_id = p_payroll_action_id
				AND	pesl2.assignment_id = pesl.assignment_id
				AND	pesl2.time_period_id = pesl.time_period_id
				AND	pesl2.status_code IN ('N', 'R')
				AND	pesl2.superceded_line_id IS NOT NULL)
	AND	payroll_action_id = p_payroll_action_id;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated group_id in psp_enc_summary_lines for new liquidation lines');

	INSERT INTO gl_interface
		(status,		set_of_books_id,		accounting_date,
		currency_code,		date_created,			created_by,
		actual_flag,		user_je_category_name,		user_je_source_name,
		encumbrance_type_id,	code_combination_id,		entered_dr,
		entered_cr,		group_id,			reference1,
		reference2,		reference4,			reference6,
		reference10,		attribute1,			attribute2,
		attribute3,		attribute4,			attribute5,
		attribute6,		attribute7,			attribute8,
		attribute9,		attribute10,			attribute11,
		attribute12,		attribute13,			attribute14,
		attribute15,		attribute16,			attribute17,
		attribute18,		attribute19,			attribute20,
		reference21,		reference22,			reference23,
		reference24,		reference25,			reference26,
		reference27,		reference28,			reference29,
		reference30)
	SELECT	'NEW',			pesl.set_of_books_id,		pesl.effective_date,
		DECODE(pec.uom, 'M', g_currency_code, 'STAT'),	SYSDATE,	l_created_by,
		'E',			l_user_je_cat,			l_user_je_source,
		l_enc_type_id,		pesl.gl_code_combination_id,
			TO_NUMBER(DECODE(dr_cr_flag, 'D', pesl.summary_amount, NULL)) debit_amount,
		TO_NUMBER(DECODE(dr_cr_flag, 'C', pesl.summary_amount, NULL)) credit_amount,
					l_group_id,			pesl.enc_control_id,
		pesl.enc_control_id,	'LD ENCUMBRANCE',		'E:' || pesl.enc_summary_line_id,
		'LD ENCUMBRANCE',	pesl.attribute1,		pesl.attribute2,
		pesl.attribute3,	pesl.attribute4,		pesl.attribute5,
		pesl.attribute6,	pesl.attribute7,		pesl.attribute8,
		pesl.attribute9,	pesl.attribute10,		pesl.attribute11,
		pesl.attribute12,	pesl.attribute13,		pesl.attribute14,
		pesl.attribute15,	pesl.attribute16,		pesl.attribute17,
		pesl.attribute18,	pesl.attribute19,		pesl.attribute20,
		pesl.attribute21,	pesl.attribute22,		pesl.attribute23,
		pesl.attribute24,	pesl.attribute25,		pesl.attribute26,
		pesl.attribute27,	pesl.attribute28,		pesl.attribute29,
		pesl.attribute30
	FROM	psp_enc_summary_lines pesl,
		psp_enc_controls pec
	WHERE	pec.enc_control_id = pesl.enc_control_id
	AND	pec.payroll_action_id = p_payroll_action_id
	AND	pesl.status_code = 'N'
	AND	pesl.gl_code_combination_id is NOT NULL
	AND	pesl.superceded_line_id IS NULL
	AND	pesl.group_id = l_group_id
	AND	pesl.payroll_action_id = p_payroll_action_id;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Number of records inserted into GL_INTERFACE: ' || SQL%ROWCOUNT);

	IF (SQL%ROWCOUNT > 0) THEN
		SELECT 	GL_JOURNAL_IMPORT_S.NEXTVAL
		INTO 	l_int_run_id
		FROM 	DUAL;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_int_run_id: ' || l_int_run_id);

		INSERT INTO gl_interface_control
			(je_source_name,	status,		interface_run_id,
			group_id,		set_of_books_id)
		VALUES (l_user_je_source,	'S',		l_int_run_id,
			l_group_id,		g_set_of_books_id);

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Inserted control record into gl_interface_control');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Before submitting Journal Import');

		req_id := fnd_request.submit_request(	'SQLGL',
							'GLLEZL',
							'',
							'',
							FALSE,
							TO_CHAR(l_int_run_id),
							TO_CHAR(g_set_of_books_id),
							'N',
							'',
							'',
							l_summarization_option,
							'W');

		IF req_id = 0 THEN
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Journal Import submission failed');
			fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
			fnd_msg_pub.add;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSE
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Submitted Journal Import (req_id: ' || req_id || ')');
			OPEN enc_control_id_cur;
			FETCH enc_control_id_cur BULK COLLECT INTO r_enc_controls.enc_control_id;
			CLOSE enc_control_id_cur;

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_enc_controls.enc_control_id.COUNT: ' || r_enc_controls.enc_control_id.COUNT);

			FORALL I IN 1..r_enc_controls.enc_control_id.COUNT
			UPDATE	psp_enc_controls
			SET	gl_phase = 'Transfer'
			WHERE	enc_control_id = r_enc_controls.enc_control_id(I);

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated gl_phase to ''Transfer'' in psp_enc_controls');

			r_enc_controls.enc_control_id.DELETE;

			COMMIT;

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling gather_table_stats for psp_enc_summary_lines');
			fnd_stats.gather_table_stats('PSP', 'PSP_ENC_SUMMARY_LINES');
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed gather_table_stats for psp_enc_summary_lines');

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Waiting for Journal Import request to complete');

			call_status := fnd_concurrent.wait_for_request(req_id, 10, 0, rphase, rstatus, dphase, dstatus, message);

			IF call_status = FALSE THEN
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Journal Import failed');
				fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Journal Import completed');
		END IF;
	END IF;

	OPEN gl_group_id_cur;
	FETCH gl_group_id_cur BULK COLLECT INTO r_groups.group_id;
	CLOSE gl_group_id_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_groups.group_id.COUNT: ' || r_groups.group_id.COUNT);

	FOR recno IN 1..r_groups.group_id.COUNT
	LOOP
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling gl_enc_tie_back for group_id: ' || r_groups.group_id(recno));

		gl_enc_tie_back(p_payroll_action_id,
						r_groups.group_id(recno),
						g_business_group_id,
						g_set_of_books_id,
						'N',
						l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	gl_enc_tie_back failed for group_id: ' || r_groups.group_id(recno));
		ELSE
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	gl_enc_tie_back successful for group_id: ' || r_groups.group_id(recno));
		END IF;
	END LOOP;

	FORALL recno IN 1..r_groups.group_id.COUNT
	DELETE	gl_interface
	WHERE	group_id = r_groups.group_id(recno)
	AND	user_je_source_name = l_user_je_source
	AND	set_of_books_id = g_set_of_books_id;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted groups from gl_interface for which gl_enc_tie_back is complete');

	FORALL recno IN 1..r_groups.group_id.COUNT
	UPDATE	psp_enc_summary_lines
	SET	group_id = NULL
	WHERE	group_id = r_groups.group_id(recno)
	AND	status_code = 'N';

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Set the un-imported summary lines to New status');

	COMMIT;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	COMMITted gl_enc_tie_back');

	p_return_status := fnd_api.g_ret_sts_success;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving TR_TO_GL_INT');
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		g_error_api_path := 'TR_TO_GL_INT:'||g_error_api_path;
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving TR_TO_GL_INT');
	WHEN OTHERS THEN
		g_error_api_path := 'TR_TO_GL_INT:'||g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','TR_TO_GL_INT');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving TR_TO_GL_INT');
END tr_to_gl_int;
--	End of changes for Create and Update multi thread enh.

--	##########################################################################
--	This procedure retrieves the user_je_source_name from gl_je_sources
--	##########################################################################

PROCEDURE gl_je_source(	P_USER_JE_SOURCE_NAME  OUT NOCOPY  VARCHAR2,
                        P_RETURN_STATUS        OUT NOCOPY  VARCHAR2) IS
   l_error	VARCHAR2(100);
   l_product	VARCHAR2(3);
 BEGIN
   SELECT user_je_source_name
   INTO   p_user_je_source_name
   FROM   gl_je_sources
   WHERE  je_source_name = 'OLD';
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   l_error := 'JE SOURCES = OLD';
   l_product := 'GL';
   fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
   fnd_message.set_token('ERROR',l_error);
   fnd_message.set_token('PRODUCT',l_product);
   fnd_msg_pub.add;
   p_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    g_error_api_path := 'gl_je_source:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('psp_enc_sum_tran','gl_je_source');
    p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

--	##########################################################################
--	This procedure retrieves the user_je_category_name from gl_je_categories
--	##########################################################################

PROCEDURE gl_je_cat(	P_USER_JE_CATEGORY_NAME  OUT NOCOPY  VARCHAR2,
                        P_RETURN_STATUS          OUT NOCOPY  VARCHAR2) IS
   l_error	VARCHAR2(100);
   l_product	VARCHAR2(3);
 BEGIN
   SELECT user_je_category_name
   INTO   p_user_je_category_name
   FROM   gl_je_categories
   WHERE  je_category_name = 'OLD';
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   l_error := 'JE CATEGORY = OLD';
   l_product := 'GL';
   fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
   fnd_message.set_token('ERROR',l_error);
   fnd_message.set_token('PRODUCT',l_product);
   fnd_msg_pub.add;
   p_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    g_error_api_path := 'gl_je_cat:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('psp_enc_sum_tran','gl_je_cat');
    p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

--	##########################################################################
--	This procedure retrieves the encumbrance_type_id from gl_encumbrance_types
--	##########################################################################

PROCEDURE enc_type(	P_ENCUMBRANCE_TYPE_ID  OUT NOCOPY  VARCHAR2,
                        P_RETURN_STATUS        OUT NOCOPY  VARCHAR2) IS
   l_error	VARCHAR2(100);
   l_product	VARCHAR2(3);

 BEGIN
   SELECT encumbrance_type_id
   INTO   p_encumbrance_type_id
   FROM   gl_encumbrance_types
   WHERE  encumbrance_type = 'OLD'
   AND    enabled_flag = 'Y';

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   l_error := 'ENCUMBRANCE TYPE = OLD';
   l_product := 'GL';
   fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
   fnd_message.set_token('ERROR',l_error);
   fnd_message.set_token('PRODUCT',l_product);
   fnd_msg_pub.add;
   p_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    g_error_api_path := 'enc_type:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('psp_enc_sum_tran','enc_type');
    p_return_status := fnd_api.g_ret_sts_unexp_error;

END;

--	##########################################################################
--	This procedure ties back all the transactions posted into Oracle General Ledger
--		with Oracle Labor Distribution where the journal import is successful.
--	In case of failure the transactions in Oracle Labor Distribution are turned
--		back into their original state.
--	##########################################################################

/*****	Commented for Create and Update multi thread enh.
PROCEDURE       gl_enc_tie_back(
                p_enc_control_id        IN  NUMBER,
                p_period_end_date       IN  DATE,
                p_group_id              IN  NUMBER,
                p_business_group_id     IN  NUMBER,
                p_set_of_books_id       IN  NUMBER,
                p_mode			IN  VARCHAR2,   -- Included as part of Bug fix #1776606s
		p_return_status		OUT NOCOPY VARCHAR2
				)IS
/ *
   CURSOR enc_control_cur IS
   SELECT enc_control_id,
          time_period_id
     FROM psp_enc_controls
    WHERE payroll_id = nvl(p_payroll_id, payroll_id)
	  AND (total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	  AND action_type IN ('N', 'Q', 'U') -- Included 'Q' for Quick Upd. Enh. 2143723.
   	  AND action_code = 'I'
   	  AND run_id = nvl(g_run_id, run_id)
      AND gl_phase = 'Transfer'
   	  AND business_group_id = nvl(g_business_group_id, business_group_id)
	  AND set_of_books_id = nvl(g_set_of_books_id, set_of_books_id);
* /
   CURSOR gl_tie_back_success_cur IS
   SELECT enc_summary_line_id,
          dr_cr_flag,
	  summary_amount
   FROM   psp_enc_summary_lines
   WHERE  group_id = p_group_id
   and enc_control_id = p_enc_control_id;


   CURSOR gl_tie_back_reject_cur IS
   SELECT status,
          reference6
   FROM   gl_interface
   WHERE  user_je_source_name = 'OLD'
     AND  set_of_books_id = p_set_of_books_id
     AND  group_id = p_group_id
     AND  reference6 IN (SELECT 'E:' || enc_summary_line_id -- Introduced for bug fix 3953230
                         FROM  psp_enc_summary_lines pesl
                         WHERE pesl.enc_control_id = p_enc_control_id);

   CURSOR assign_susp_ac_cur(P_ENC_LINE_ID	IN	NUMBER) IS
   SELECT pel.rowid,
          pel.encumbrance_date,
          pel.suspense_org_account_id
   FROM   psp_enc_lines pel
   WHERE  pel.enc_summary_line_id = p_enc_line_id
   and enc_control_id=p_enc_control_id ;  -- this added to fix suspense ac postings
-- bug fix 1671938

-- Get the Organization details ...

   CURSOR get_susp_org_cur(P_ORG_ID	IN	VARCHAR2) IS
   SELECT hou.organization_id, hou.name, poa.gl_code_combination_id
     FROM hr_all_organization_units hou, psp_organization_accounts poa
    WHERE hou.organization_id = poa.organization_id
      AND poa.business_group_id = p_business_group_id
      AND poa.set_of_books_id = p_set_of_books_id
      AND poa.organization_account_id = p_org_id;
/ *
   CURSOR get_org_id_cur(P_LINE_ID	IN	NUMBER) IS
   SELECT hou.organization_id, hou.name
   FROM   hr_all_organization_units hou,
  	      per_assignments_f paf,
          psp_enc_lines pel
   WHERE  pel.enc_summary_line_id = p_line_id
   AND    pel.assignment_id = paf.assignment_id
   AND    pel.encumbrance_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    paf.organization_id = hou.organization_id
   AND    pel.encumbrance_date between
		  hou.date_from and nvl(hou.date_to,pel.encumbrance_date);
* /


   CURSOR get_org_id_cur(P_ROWID IN ROWID) IS
   SELECT hou.organization_id, hou.name
   FROM   hr_all_organization_units hou,
  	      per_assignments_f paf,
          psp_enc_lines pel
   WHERE
-- pel.enc_summary_line_id = p_line_id
    pel.rowid=p_rowid
   AND    pel.assignment_id = paf.assignment_id
   AND    pel.encumbrance_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    paf.organization_id = hou.organization_id
   AND    pel.encumbrance_date between
		  hou.date_from and nvl(hou.date_to,pel.encumbrance_date);

-- bug fix 1671938
  l_orig_org_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
  l_orig_org_id			number;

-- End of Get org id cursor  Ravindra
/ *
   CURSOR assign_susp_ac_cur(P_ENC_SUMMARY_LINE_ID	IN	NUMBER) IS
   SELECT hou.name,
          hou.organization_id,
          pel.rowid,
          pel.assignment_id,
          pel.encumbrance_date,
          pel.suspense_org_account_id,
          pel.gl_code_combination_id
   FROM   hr_organization_units hou,
          per_assignments_f paf,
          psp_enc_lines pel
   WHERE  pel.enc_summary_line_id = p_enc_summary_line_id
   AND    pel.assignment_id = paf.assignment_id
   AND    pel.encumbrance_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    paf.organization_id = hou.organization_id
   AND	  pel.business_group_id = g_business_group_id
   AND	  pel.set_of_books_id = g_set_of_books_id
   AND    pel.encumbrance_date between hou.date_from and nvl(hou.date_to,pel.encumbrance_date);
* /

   CURSOR org_susp_ac_cur(P_ORGANIZATION_ID	IN	NUMBER,
                          P_ENCUMBRANCE_DATE	IN	DATE) IS
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
	  poa.expenditure_organization_id,
	  poa.expenditure_type,
          poa.award_id,
	  poa.task_id
   FROM   psp_organization_accounts poa
   WHERE  poa.organization_id = p_organization_id
   AND	  poa.business_group_id = p_business_group_id
   AND	  poa.set_of_books_id = p_set_of_books_id
   AND    poa.account_type_code = 'S'
   AND    p_encumbrance_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_encumbrance_date);

-- CURSOR global_susp_ac_cur(P_ENCUMBRANCE_DATE	IN	DATE) IS
   CURSOR global_susp_ac_cur(P_ORGANIZATION_ACCOUNT_ID  IN	NUMBER) IS  --BUG 2056877
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
	  poa.expenditure_organization_id,
	  poa.expenditure_type,
          poa.award_id,
	  poa.task_id
   FROM   psp_organization_accounts poa
   WHERE
       / * poa.account_type_code = 'G'
   AND	  poa.business_group_id = p_business_group_id
   AND	  poa.set_of_books_id = p_set_of_books_id
   AND    p_distribution_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_distribution_date);  Bug 2056877.* /
         organization_account_id = p_organization_account_id; --Added for bug 2056877.
   l_organization_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
   l_organization_id		NUMBER(15);
   l_rowid				ROWID;
   l_assignment_id		NUMBER(9);
   l_encumbrance_date		DATE;
   l_suspense_org_account_id  NUMBER(9);
   l_lines_glccid			NUMBER(15);
   l_organization_account_id	NUMBER(9);
   l_susp_glccid			NUMBER(15);
   l_project_id			NUMBER(15);
   l_expenditure_organization_id NUMBER(15);
   l_expenditure_type		VARCHAR2(30);
   l_award_id			NUMBER(15);
   l_task_id			NUMBER(15);
   l_status				VARCHAR2(50);
   l_reference6			VARCHAR2(100);
   l_enc_ref			VARCHAR2(100);
   l_cnt_gl_interface		NUMBER;
   l_enc_summary_line_id		NUMBER(10);
   l_gl_project_flag		VARCHAR2(1);
   l_suspense_ac_failed		VARCHAR2(1) := 'N';
   l_suspense_ac_not_found	VARCHAR2(1) := 'N';
   l_susp_ac_found		VARCHAR2(10) := 'TRUE';
   l_summary_amount		NUMBER;
   l_dr_summary_amount		NUMBER := 0;
   l_cr_summary_amount		NUMBER := 0;
   l_dr_cr_flag			VARCHAR2(1);
   l_effective_date		DATE;
   x_susp_failed_org_name	hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
   x_susp_failed_status		VARCHAR2(50);
   x_susp_failed_date		DATE;
   x_lines_glccid			NUMBER(15);
   x_susp_nf_org_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
   x_susp_nf_date			DATE;
   l_return_status		VARCHAR2(10);
   l_group_id               NUMBER:=p_group_id;  -- bug fix 1570575
   l_rec_cnt                NUMBER := 0;
	x	varchar2(2000);
   l_return_value               VARCHAR2(30); --Added for bug 2056877.
   no_profile_exists            EXCEPTION;    --Added for bug 2056877.
   no_val_date_matches          EXCEPTION;    --Added for bug 2056877.
   no_global_acct_exists        EXCEPTION;    --Added for bug 2056877.
   l_susp_exception varchar2(50) := NULL; -- 2479579



 FUNCTION PROCESS_COMPLETE RETURN BOOLEAN IS
  l_cnt     NUMBER := 0;
  l_status  VARCHAR2(30);
 begin
   select count(*)
     into l_cnt
     from gl_interface
    where user_je_source_name = 'OLD'
      and set_of_books_id = p_set_of_books_id
      and group_id = p_group_id
      and status = 'NEW';

   if l_cnt = 0 then
     return TRUE;
   elsif l_cnt > 0 then
-- -------------------------------------------------------------------------------------------
-- If status = 'NEW' then the journal import process did not kick off
-- for some reason. Return FALSE in this case. So cleanup the tables and try to transfer
-- again after summarization in the second pass.
-- -------------------------------------------------------------------------------------------

     delete from gl_interface
      where user_je_source_name = 'OLD'
        and set_of_books_id = p_set_of_books_id
        and group_id = p_group_id;

     delete from psp_enc_summary_lines
      where group_id = p_group_id
	and enc_control_id = p_enc_control_id;

     return FALSE;
   end if;

 exception
 when others then
      return TRUE;
 end PROCESS_COMPLETE;

 BEGIN

   IF (PROCESS_COMPLETE) THEN

   SELECT count(*)
     INTO l_cnt_gl_interface
     FROM gl_interface
    WHERE user_je_source_name = 'OLD'
      AND set_of_books_id = p_set_of_books_id
      AND group_id = p_group_id;

   IF l_cnt_gl_interface > 0 THEN
     / * Start bug#2142865 Moved the code after loop to above * /
     UPDATE psp_enc_controls
     SET gl_phase = 'TieBack'
     WHERE  run_id = g_run_id;
     / * End bug#2142865 * /
     OPEN gl_tie_back_reject_cur;
     LOOP
       FETCH gl_tie_back_reject_cur INTO l_status,l_enc_ref;
	   IF gl_tie_back_reject_cur%NOTFOUND THEN
         CLOSE gl_tie_back_reject_cur;
         EXIT;
       END IF;

       l_reference6 := substr(l_enc_ref, 3);

       UPDATE 	psp_enc_summary_lines
       SET 	interface_status = l_status,
		status_code = 'R'
       WHERE 	enc_summary_line_id = to_number(l_reference6);

       OPEN assign_susp_ac_cur(to_number(l_reference6));
       LOOP
         FETCH assign_susp_ac_cur INTO l_rowid, l_encumbrance_date,l_suspense_org_account_id;

         IF assign_susp_ac_cur%NOTFOUND THEN
           CLOSE assign_susp_ac_cur;
           EXIT;
         END IF;

 	       if l_suspense_org_account_id is not null  then
	         OPEN get_susp_org_cur(l_suspense_org_account_id);
	         FETCH get_susp_org_cur into l_organization_id, l_organization_name,
				                         l_lines_glccid;
	         CLOSE get_susp_org_cur;
	       end if;

/ * --- This is not needed as the enc lines are always in status 'N'
* /

         IF l_status = 'P' OR substr(l_status,1,1) = 'W'  THEN
             null;
---  fIx for bug 1671938/1888408

/ *
	        UPDATE psp_enc_lines
            SET status_code = 'N'
            WHERE rowid = l_rowid;
	-- if the suspense a/c failed,update the status of the whole batch and display the error

	 ELSIF l_suspense_org_account_id IS NOT NULL AND  *** /

	 ELSIF l_suspense_org_account_id IS NOT NULL AND
               (l_status <> 'P' OR substr(l_status,1,1) <> 'W')  THEN
	   x_susp_failed_org_name := l_organization_name;
           x_susp_failed_status   := l_status;
           x_susp_failed_date     := l_encumbrance_date;
           l_suspense_ac_failed := 'Y';

/ *        Commented the following for Bug 3194807

	    UPDATE psp_enc_lines
            SET suspense_reason_code = l_status,
                status_code = 'N'
            WHERE rowid = l_rowid;

* /

         ELSE

           l_susp_ac_found := 'TRUE';

	       OPEN get_org_id_cur(l_rowid);
	       FETCH get_org_id_cur into l_orig_org_id, l_orig_org_name;
               close get_org_id_cur;

           OPEN org_susp_ac_cur(l_orig_org_id,l_encumbrance_date);
           FETCH org_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,
			l_expenditure_organization_id, l_expenditure_type, l_award_id,l_task_id;

--           OPEN org_susp_ac_cur(l_organization_id,l_encumbrance_date);
--           FETCH org_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,l_award_id, l_task_id;
           IF org_susp_ac_cur%NOTFOUND  THEN
           / * Following code is added for bug 2056877 ,Added validation for generic suspense account * /
              l_return_value := psp_general.find_global_suspense(l_encumbrance_date,
							  p_business_group_id,
                                                          p_set_of_books_id,
                                                          l_organization_account_id );
      	  / * --------------------------------------------------------------------
      	   Valid return values are
      	   PROFILE_VAL_DATE_MATCHES       Profile and Value and Date matching 'G'
      	   NO_PROFILE_EXISTS              No Profile
       	   NO_VAL_DATE_MATCHES            Profile and Either Value/date do not
            		                  match with 'G'
   	   NO_GLOBAL_ACCT_EXISTS          No 'G' exists
     	    ---------------------------------------------------------------------- * /
              / * start added for  bug # 2142865 * /
	   / *    IF l_return_value <> 'PROFILE_VAL_DATE_MATCHES' THEN
	        IF p_mode='N' THEN
	          enc_batch_end(g_payroll_id ,l_return_status);
	        END IF;
	       END IF ;    commented for  2479579 * /
             / * end for bug # 2142865 * /

              IF l_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
           ----	 OPEN global_susp_ac_cur(l_encumbrance_date);
                 OPEN global_susp_ac_cur(l_organization_account_id); --Bug 2056877
            	 FETCH global_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,
		 l_expenditure_organization_id, l_expenditure_type, l_award_id, l_task_id;

           	 IF global_susp_ac_cur%NOTFOUND THEN
	      	  / *	l_susp_ac_found := 'FALSE';
              		l_suspense_ac_not_found := 'Y';
              		x_susp_nf_org_name := l_orig_org_name;
             		x_susp_nf_date     := l_encumbrance_date;  Commented for bug 2056877 * /
                        -- commented following line and added two new lines for 2479579
             		-- RAISE no_global_acct_exists; --Added for bug 2056877
                         l_suspense_ac_not_found := 'Y';
                         l_susp_ac_found := 'NO_G_AC';
           	 END IF;
            	 CLOSE global_susp_ac_cur;
             ELSIF l_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
    		     -- RAISE no_global_acct_exists; commented this line and added two new lines for 2479579
                     l_suspense_ac_not_found := 'Y';
                     l_susp_ac_found := 'NO_G_AC';
             ELSIF l_return_value = 'NO_VAL_DATE_MATCHES' THEN
         	    -- RAISE no_val_date_matches; commented this line and added two new lines for 2479579
                     l_suspense_ac_not_found := 'Y';
                     l_susp_ac_found := 'NO_DT_MCH';
             ELSIF l_return_value = 'NO_PROFILE_EXISTS' THEN
         	    -- RAISE no_profile_exists; commented this line and added two new lines for 2479579
                         l_suspense_ac_not_found := 'Y';
                         l_susp_ac_found := 'NO_PROFL';
             END IF; -- Bug 2056877.
         END IF;
         CLOSE org_susp_ac_cur;

           IF l_susp_ac_found = 'TRUE' THEN

             IF l_susp_glccid IS NOT NULL THEN
               l_gl_project_flag := 'G';
               l_effective_date := p_period_end_date;
             ELSE
               l_gl_project_flag := 'P';

               psp_general.poeta_effective_date(l_encumbrance_date,
                                    l_project_id,
                                    l_award_id,
                                    l_task_id,
                                    l_effective_date,
                                    l_return_status);
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 --dbms_output.put_line('poeta call failed     ');
                   --insert_into_psp_stout( 'poeta call failed      ');
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

             END IF;

             -- assign the organization suspense account and gl status
  / * For Bug  fix 3194807 * /

	      UPDATE 	psp_enc_lines
	      SET   	prev_effective_date =  encumbrance_date
	      WHERE	rowid = l_rowid;
  / * End of changes for Bug fix 3194807 * /

	      UPDATE psp_enc_lines
              SET suspense_org_account_id = l_organization_account_id,
                  suspense_reason_code = 'ES:' || l_status,
                  gl_project_flag = l_gl_project_flag,
--                encumbrance_date = l_encumbrance_date, for Bug 3194807
		  encumbrance_date = l_effective_date,
/ *	Commented for Bug fix 3194807
		  schedule_line_id = null,
		  org_schedule_id = null,
		  default_org_account_id = null,
		  element_account_id = null,
		  gl_code_combination_id = decode(l_gl_project_flag, 'P', null, l_susp_glccid),
		  project_id = decode(l_gl_project_flag, 'P', l_project_id, null),
		  expenditure_organization_id = decode(l_gl_project_flag, 'P', l_expenditure_organization_id, null),
		  expenditure_type = decode(l_gl_project_flag, 'P', l_expenditure_type, null),
		  task_id = decode(l_gl_project_flag, 'P', l_task_id, null),
		  award_id = decode(l_gl_project_flag, 'P', l_award_id, null), commented for bug 3194807 * /
                  status_code = 'N'
              WHERE rowid = l_rowid;
           ELSE -- 2479579 added this else stmnt
                l_susp_exception := l_susp_ac_found;
           END IF;
         END IF;
       END LOOP;
     END LOOP;
      / * Commented as a part of bug#2142865
        Moved the same code up
      UPDATE psp_enc_controls
		SET gl_phase = 'TieBack'
      WHERE enc_control_id = p_enc_control_id;* /
/ * GL encumbrance does not have reversal lines: bug 2030232
     IF l_reversal_ac_failed = 'Y' THEN
       fnd_message.set_name('PSP','PSP_GL_REVERSE_AC_REJECT');
       fnd_message.set_token('GLCCID',x_lines_glccid);
       fnd_msg_pub.add;
       -- Included the following check as part of Bug fix #1776606 --
       IF p_mode = 'N' THEN
       	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;
* /

     IF l_suspense_ac_failed = 'Y' THEN
       g_susp_prob := 'Y';     -- for 2479579
       fnd_message.set_name('PSP','PSP_TR_GL_SUSP_AC_REJECT');
       fnd_message.set_token('ORG_NAME',x_susp_failed_org_name);
       fnd_message.set_token('PAYROLL_DATE',x_susp_failed_date);
       fnd_message.set_token('ERROR_MSG',x_susp_failed_status);
       fnd_msg_pub.add;


       / * Added the following for Bug 3194807 * /

	UPDATE 	psp_enc_lines
	SET	suspense_org_account_id = NULL,
		suspense_reason_code = NULL,
		gl_project_flag = decode(gl_code_combination_id,NULL,'P','G'),
		encumbrance_date = prev_effective_date
	WHERE 	suspense_reason_code like 'ES:%'
	AND	enc_summary_line_id
		IN (SELECT enc_summary_line_id
		    FROM   psp_enc_summary_lines
	 	    WHERE  enc_control_id = p_enc_control_id);


	/ * End of code changes for Bug 3194807 * /

     END IF;
    -- uncommented for 2479579, which was earlier commented   for bug # 2142865
     IF l_suspense_ac_not_found = 'Y' THEN
        g_susp_prob := 'Y';     -- for 2479579
       / * commented this message stack for 2479579
       fnd_message.set_name('PSP','PSP_LD_SUSPENSE_AC_NOT_EXIST');
       fnd_message.set_token('ORG_NAME',x_susp_nf_org_name);
       fnd_message.set_token('PAYROLL_DATE',x_susp_nf_date);
       fnd_msg_pub.add; * /
        ---added following if stmnt for 2479579
        IF    l_susp_exception = 'NO_G_AC' then
            RAISE no_global_acct_exists;
        ELSIF l_susp_exception = 'NO_DT_MCH' then
             RAISE no_val_date_matches;
        ELSIF l_susp_exception = 'NO_PROFL' then
              RAISE no_profile_exists;
        END IF;

     END IF;

   ELSIF l_cnt_gl_interface = 0 THEN
     --
     OPEN gl_tie_back_success_cur;
     LOOP
       FETCH gl_tie_back_success_cur INTO l_enc_summary_line_id,
       l_dr_cr_flag,l_summary_amount;
       IF gl_tie_back_success_cur%NOTFOUND THEN
         CLOSE gl_tie_back_success_cur;
         EXIT;
       END IF;

       l_rec_cnt := l_rec_cnt + 1;
       -- update records in psp_enc_summary_lines as 'A'
       UPDATE psp_enc_summary_lines
       SET status_code = 'A'
       WHERE enc_summary_line_id = l_enc_summary_line_id;

       IF l_dr_cr_flag = 'D' THEN
         l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
       ELSIF l_dr_cr_flag = 'C' THEN
         l_cr_summary_amount := l_cr_summary_amount + l_summary_amount;
       END IF;

         UPDATE psp_enc_lines
            SET status_code = 'A'
	  WHERE enc_summary_line_id = l_enc_summary_line_id
	    AND enc_control_id = p_enc_control_id;

/ * Introduced this cursor for Bug fix 3194807 * /
        UPDATE 	psp_enc_lines
	SET	gl_code_combination_id =	(SELECT	poa.gl_code_combination_id
                                          	FROM	psp_organization_accounts poa
                                          	where	poa.organization_account_id = suspense_org_account_id),
		project_id = NULL,
                task_id  = NULL,
                award_id = NULL,
                expenditure_organization_id = NULL,
                expenditure_type = NULL
          WHERE	enc_summary_line_id = l_enc_summary_line_id
	  AND	suspense_reason_code LIKE 'ES:%';
/ * End of code Changes for Bug fix  3194807 * /


         -- move the transferred records to psp_enc_lines_history
	 -- Added enc_start_date ,enc_end_date columns for Enh. Enc Redesign Prorata,Bug #2259310.
	-- Introduced DFF columns for bug fix 2908859
         INSERT INTO psp_enc_lines_history
         (enc_line_id,business_group_id,enc_element_type_id,encumbrance_date,
          dr_cr_flag,encumbrance_amount,status_code,enc_line_type,schedule_line_id,org_schedule_id,
	  default_org_account_id,suspense_org_account_id,element_account_id,gl_project_flag,
	  enc_summary_line_id,person_id,assignment_id,award_id,task_id,expenditure_type,
	  expenditure_organization_id,project_id,gl_code_combination_id,time_period_id,payroll_id,
	  set_of_books_id,default_reason_code,suspense_reason_code,enc_control_id,change_flag,last_update_date,
	  last_updated_by,last_update_login,created_by,creation_date,enc_start_date,enc_end_date,
	attribute_category,	attribute1,		attribute2,		attribute3,
	attribute4,		attribute5,		attribute6,		attribute7,
	attribute8,		attribute9,		attribute10)
         SELECT enc_line_id,business_group_id,enc_element_type_id,encumbrance_date,
          dr_cr_flag,encumbrance_amount,status_code,enc_line_type,schedule_line_id,org_schedule_id,
	  default_org_account_id,suspense_org_account_id,element_account_id,gl_project_flag,
	  enc_summary_line_id,person_id,assignment_id,award_id,task_id,expenditure_type,
	  expenditure_organization_id,project_id,gl_code_combination_id,time_period_id,payroll_id,
	  set_of_books_id,default_reason_code,suspense_reason_code,enc_control_id,change_flag,last_update_date,
	  last_updated_by,last_update_login,created_by,creation_date,enc_start_date,enc_end_date,
	attribute_category,	attribute1,		attribute2,		attribute3,
	attribute4,		attribute5,		attribute6,		attribute7,
	attribute8,		attribute9,		attribute10
         FROM psp_enc_lines
         WHERE status_code = 'A'
         AND enc_summary_line_id = l_enc_summary_line_id
	 AND enc_control_id = p_enc_control_id;

         DELETE FROM psp_enc_lines
         WHERE status_code = 'A'
         AND enc_summary_line_id = l_enc_summary_line_id
	 AND enc_control_id = p_enc_control_id;

     END LOOP;

     UPDATE psp_enc_controls
	SET summ_gl_dr_amount = l_dr_summary_amount,
            summ_gl_cr_amount = l_cr_summary_amount,
            gl_phase = 'TieBack'
      WHERE enc_control_id = p_enc_control_id;
       l_rec_cnt := 0;
   END IF;
--   END LOOP; -- ENC_CONTROL_CUR
   END IF; -- If (PROCESS_COMPLETE)
   p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	g_error_api_path := 'GL_ENC_TIE_BACK:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   / * Added Exceptions for bug 2056877 * /
   WHEN NO_PROFILE_EXISTS THEN
      g_error_api_path := SUBSTR('GL_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
      fnd_msg_pub.add;
     -- p_return_status := fnd_api.g_ret_sts_unexp_error;  commented and intro success for 2479579
      p_return_status := fnd_api.g_ret_sts_success;

   WHEN NO_VAL_DATE_MATCHES THEN
      g_error_api_path := SUBSTR('GL_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_VAL_DATE_MATCHES');
      fnd_message.set_token('ORG_NAME',l_orig_org_name);
      fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
      fnd_msg_pub.add;
     -- p_return_status := fnd_api.g_ret_sts_unexp_error;  commented and intro success for 2479579
      p_return_status := fnd_api.g_ret_sts_success;

   WHEN NO_GLOBAL_ACCT_EXISTS THEN
      g_error_api_path := SUBSTR('GL_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_GLOBAL_ACCT_EXISTS');
      fnd_message.set_token('ORG_NAME',l_orig_org_name);
      fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
      fnd_msg_pub.add;
     -- p_return_status := fnd_api.g_ret_sts_unexp_error;  commented and intro success for 2479579
      p_return_status := fnd_api.g_ret_sts_success;

   WHEN OTHERS THEN
      g_error_api_path := 'GL_ENC_TIE_BACK:'||g_error_api_path;
	fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','GL_ENC_TIE_BACK');
      p_return_status := fnd_api.g_ret_sts_unexp_error;

END;
	End of comment for Create and Update multi thread enh.	*****/

--	Introduced the following modified gl_enc_tie_back procedure for Create and Update multi thread enh.
PROCEDURE gl_enc_tie_back(	p_payroll_action_id	IN		NUMBER,
				p_group_id		IN		NUMBER,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_mode			IN		VARCHAR2,
				p_return_status		OUT NOCOPY	VARCHAR2) IS
CURSOR	int_count_cur IS
SELECT	COUNT(1)
FROM	gl_interface
WHERE	user_je_source_name = 'OLD'
AND	set_of_books_id = p_set_of_books_id
AND	group_id = p_group_id;

CURSOR	gl_tie_back_success_cur IS
SELECT	enc_summary_line_id,
	enc_control_id,
	dr_cr_flag,
	summary_amount
FROM	psp_enc_summary_lines
WHERE	group_id = p_group_id;

CURSOR	gl_tie_back_reject_cur IS
SELECT	status,
	TO_NUMBER(trim(substr(reference6,3)))
FROM	gl_interface
WHERE	user_je_source_name = 'OLD'
AND	set_of_books_id = p_set_of_books_id
AND	group_id = p_group_id;

CURSOR	assign_susp_ac_cur IS
SELECT	pel.rowid,
	pel.encumbrance_date,
	pel.enc_start_date,
	pel.enc_end_date,
	pel.assignment_id,
	pel.payroll_id,
	pel.enc_element_type_id,
	pel.gl_code_combination_id,
	pel.suspense_org_account_id,
	pesl.interface_status,
	ptp.end_date
FROM	psp_enc_lines pel,
	psp_enc_summary_lines pesl,
	per_time_periods ptp
WHERE	pel.payroll_action_id = p_payroll_action_id
AND	pel.enc_summary_line_id = pesl.enc_summary_line_id
AND	pesl.payroll_action_id = p_payroll_action_id
AND	pesl.status_code = 'R'
AND	pesl.group_id = p_group_id
AND	ptp.time_period_id = pel.time_period_id
ORDER BY 5, 6, 7, 8, 3;

CURSOR	get_susp_org_cur(P_ORG_ID	IN	VARCHAR2) IS
SELECT	hou.organization_id, hou.name, poa.gl_code_combination_id
FROM	hr_all_organization_units hou,
	psp_organization_accounts poa
WHERE	hou.organization_id = poa.organization_id
AND	poa.business_group_id = p_business_group_id
AND	poa.set_of_books_id = p_set_of_books_id
AND	poa.organization_account_id = p_org_id;

CURSOR	get_org_id_cur(P_ROWID IN ROWID) IS
SELECT	hou.organization_id, hou.name
FROM	hr_all_organization_units hou,
	per_assignments_f paf,
	psp_enc_lines pel
WHERE	pel.rowid=p_rowid
AND	pel.assignment_id = paf.assignment_id
AND	pel.encumbrance_date BETWEEN paf.effective_start_date AND paf.effective_end_date
AND	paf.organization_id = hou.organization_id
AND	pel.encumbrance_date BETWEEN hou.date_from AND NVL(hou.date_to, pel.encumbrance_date);

CURSOR	org_susp_ac_cur(P_ORGANIZATION_ID	IN	NUMBER,
                          P_ENCUMBRANCE_DATE	IN	DATE) IS
SELECT	poa.organization_account_id,
	poa.gl_code_combination_id,
	poa.project_id,
	poa.expenditure_organization_id,
	poa.expenditure_type,
	poa.award_id,
	poa.task_id
FROM	psp_organization_accounts poa
WHERE	poa.organization_id = p_organization_id
AND	poa.business_group_id = p_business_group_id
AND	poa.set_of_books_id = p_set_of_books_id
AND	poa.account_type_code = 'S'
AND	p_encumbrance_date BETWEEN poa.start_date_active AND NVL(poa.end_date_active, p_encumbrance_date);

CURSOR	global_susp_ac_cur(P_ORGANIZATION_ACCOUNT_ID IN NUMBER) IS
SELECT	poa.organization_account_id,
	poa.gl_code_combination_id,
	poa.project_id,
	poa.expenditure_organization_id,
	poa.expenditure_type,
	poa.award_id,
	poa.task_id
FROM	psp_organization_accounts poa
WHERE	organization_account_id = p_organization_account_id;

l_encumbrance_date			DATE;
l_lines_glccid				NUMBER(15);
l_organization_account_id	NUMBER(9);
l_susp_glccid				NUMBER(15);
l_orig_org_name				hr_all_organization_units_tl.name%TYPE;
l_orig_org_id				NUMBER(15);
l_cnt_gl_interface			NUMBER;
l_gl_project_flag			VARCHAR2(1);
l_suspense_ac_failed		VARCHAR2(1);
l_suspense_ac_not_found		VARCHAR2(1);
l_susp_ac_found				VARCHAR2(10);
l_organization_name			hr_all_organization_units_tl.name%TYPE;
l_organization_id			NUMBER(15);
l_return_value				VARCHAR2(30);
l_effective_date			DATE;
no_profile_exists			EXCEPTION;
no_val_date_matches			EXCEPTION;
no_global_acct_exists		EXCEPTION;
l_susp_exception			VARCHAR2(50);
l_project_id				NUMBER(15);
l_expenditure_organization_id	NUMBER(15);
l_expenditure_type			VARCHAR2(30);
l_award_id					NUMBER(15);
l_task_id					NUMBER(15);
l_return_status				VARCHAR2(1);

TYPE t_rowid IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE t_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_char_300 IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;

TYPE r_interface_rec IS RECORD
	(status			t_char_300,
	enc_summary_line_id	t_number_15,
	dr_cr_flag		t_char_300,
	summary_amount		t_number,
	enc_control_id		t_number_15);
r_interface	r_interface_rec;

TYPE r_suspense_ac_rec IS RECORD
	(row_id					t_rowid,
	encumbrance_date		t_date,
	enc_start_date			t_date,
	enc_end_date			t_date,
	assignment_id			t_number_15,
	element_type_id			t_number_15,
	payroll_id				t_number_15,
	gl_code_combination_id	t_number_15,
	suspense_org_account_id	t_number_15,
	interface_status		t_char_300,
	end_date				t_date);
r_suspense_ac	r_suspense_ac_rec;

FUNCTION PROCESS_COMPLETE RETURN BOOLEAN IS
l_cnt	NUMBER;
CURSOR	int_count_cur IS
SELECT	COUNT(1)
FROM	gl_interface
WHERE	user_je_source_name = 'OLD'
AND	set_of_books_id = p_set_of_books_id
AND	group_id = p_group_id
AND	status = 'NEW';

TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

TYPE r_enc_control_rec IS RECORD
	(enc_control_id	t_number_15);
r_enc_controls	r_enc_control_rec;

TYPE r_superceded_line_rec IS RECORD (superceded_line_id	t_number_15);
r_superceded_lines	r_superceded_line_rec;

CURSOR	enc_controls_cur IS
SELECT	DISTINCT enc_control_id
FROM	psp_enc_summary_lines
WHERE	group_id = p_group_id;
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering GL_ENC_TIE_BACK.PROCESS_COMPLETE');

	OPEN int_count_cur;
	FETCH int_count_cur INTO l_cnt;
	CLOSE int_count_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_cnt: ' || l_cnt);

	IF l_cnt = 0 THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK.PROCESS_COMPLETE');
		RETURN TRUE;
	ELSIF l_cnt > 0 THEN
		DELETE FROM gl_interface
		WHERE	user_je_source_name = 'OLD'
		AND	set_of_books_id = p_set_of_books_id
		AND	group_id = p_group_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted from gl_interface');
		DELETE FROM psp_enc_summary_lines
		WHERE	group_id = p_group_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted from psp_enc_summary_lines');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK.PROCESS_COMPLETE');
		RETURN FALSE;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK.PROCESS_COMPLETE');
		RETURN TRUE;
END	PROCESS_COMPLETE;

BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering GL_ENC_TIE_BACK procedure');
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	p_group_id: ' || p_group_id);
	l_suspense_ac_failed := 'N';
	l_susp_ac_found := 'TRUE';
	l_susp_exception := NULL;
	l_suspense_ac_not_found := 'N';

	IF (PROCESS_COMPLETE) THEN
		OPEN int_count_cur;
		FETCH int_count_cur INTO l_cnt_gl_interface;
		CLOSE int_count_cur;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_cnt_gl_interface: ' || l_cnt_gl_interface);

		IF (l_cnt_gl_interface > 0) THEN
			OPEN gl_tie_back_reject_cur;
			FETCH gl_tie_back_reject_cur BULK COLLECT INTO r_interface.status, r_interface.enc_summary_line_id;
			CLOSE gl_tie_back_reject_cur;

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_interface.status.COUNT: ' || r_interface.status.COUNT);

			FORALL recno IN 1..r_interface.status.COUNT
			UPDATE	psp_enc_summary_lines
			SET	interface_status = r_interface.status(recno),
				status_code = 'R'
			WHERE	enc_summary_line_id = r_interface.enc_summary_line_id(recno)
			AND	r_interface.status(recno) <> 'P'
			AND	SUBSTR(r_interface.status(recno), 1, 1) <> 'W';

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated rejected lines status in psp_enc_summary_lines');

			OPEN assign_susp_ac_cur;
			FETCH assign_susp_ac_cur BULK COLLECT INTO r_suspense_ac.row_id, r_suspense_ac.encumbrance_date,
				r_suspense_ac.enc_start_date, r_suspense_ac.enc_end_date, r_suspense_ac.assignment_id,
				r_suspense_ac.payroll_id, r_suspense_ac.element_type_id,
				r_suspense_ac.gl_code_combination_id, r_suspense_ac.suspense_org_account_id,
				r_suspense_ac.interface_status, r_suspense_ac.end_date;
			CLOSE assign_susp_ac_cur;

			FOR recno IN 1..r_suspense_ac.row_id.COUNT
			LOOP
				IF r_suspense_ac.suspense_org_account_id(recno) IS NOT NULL THEN
					OPEN get_susp_org_cur(r_suspense_ac.suspense_org_account_id(recno));
					FETCH get_susp_org_cur INTO l_organization_id, l_organization_name, l_lines_glccid;
					CLOSE get_susp_org_cur;

					l_suspense_ac_failed	:= 'Y';
					g_susp_prob := 'Y';
					fnd_message.set_name('PSP', 'PSP_TR_GL_SUSP_AC_REJECT');
					fnd_message.set_token('ORG_NAME', l_organization_name);
					fnd_message.set_token('PAYROLL_DATE', r_suspense_ac.encumbrance_date(recno));
					fnd_message.set_token('ERROR_MSG', r_suspense_ac.interface_status(recno));
					fnd_msg_pub.add;
				ELSE
					l_susp_ac_found := 'TRUE';

					OPEN get_org_id_cur(r_suspense_ac.row_id(recno));
					FETCH get_org_id_cur INTO l_orig_org_id, l_orig_org_name;
					CLOSE get_org_id_cur;

					OPEN org_susp_ac_cur(l_orig_org_id, r_suspense_ac.encumbrance_date(recno));
					FETCH org_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,
						l_expenditure_organization_id, l_expenditure_type, l_award_id, l_task_id;

					IF org_susp_ac_cur%NOTFOUND THEN
						l_return_value := psp_general.find_global_suspense(r_suspense_ac.encumbrance_date(recno),
								p_business_group_id,
								p_set_of_books_id,
								l_organization_account_id);

						IF l_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
							OPEN global_susp_ac_cur(l_organization_account_id);
							FETCH global_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,
								l_expenditure_organization_id, l_expenditure_type, l_award_id, l_task_id;

							IF global_susp_ac_cur%NOTFOUND THEN
								l_encumbrance_date := r_suspense_ac.encumbrance_date(recno);
								l_suspense_ac_not_found := 'Y';
								l_susp_ac_found := 'NO_G_AC';
							END IF;
							CLOSE global_susp_ac_cur;
						ELSIF l_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
							l_encumbrance_date := r_suspense_ac.encumbrance_date(recno);
							l_suspense_ac_not_found := 'Y';
							l_susp_ac_found := 'NO_G_AC';
						ELSIF l_return_value = 'NO_VAL_DATE_MATCHES' THEN
							l_encumbrance_date := r_suspense_ac.encumbrance_date(recno);
							l_suspense_ac_not_found := 'Y';
							l_susp_ac_found := 'NO_DT_MCH';
						ELSIF l_return_value = 'NO_PROFILE_EXISTS' THEN
							l_encumbrance_date := r_suspense_ac.encumbrance_date(recno);
							l_suspense_ac_not_found := 'Y';
							l_susp_ac_found := 'NO_PROFL';
						END IF;
					END IF;
					CLOSE org_susp_ac_cur;

					IF l_susp_ac_found = 'TRUE' THEN
						IF l_susp_glccid IS NOT NULL THEN
							l_gl_project_flag := 'G';
							l_effective_date := r_suspense_ac.end_date(recno);
						ELSE
							l_gl_project_flag := 'P';
							psp_general.poeta_effective_date(r_suspense_ac.encumbrance_date(recno),
								l_project_id, l_award_id, l_task_id, l_effective_date,
								l_return_status);
							IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
								RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
							END IF;
						END IF;

						UPDATE	psp_enc_lines
						SET	prev_effective_date = encumbrance_date,
							orig_gl_code_combination_id = gl_code_combination_id,
							orig_project_id = project_id,
							orig_task_id = task_id,
							orig_award_id = award_id,
							orig_expenditure_org_id = expenditure_organization_id,
							orig_expenditure_type = expenditure_type
						WHERE	rowid = r_suspense_ac.row_id(recno)
						AND		enc_start_date <= g_def_end_date;

						UPDATE	psp_enc_lines
						SET	suspense_org_account_id = l_organization_account_id,
							gl_code_combination_id = l_susp_glccid,
							project_id = l_project_id,
							task_id = l_task_id,
							award_id = l_award_id,
							expenditure_organization_id = l_expenditure_organization_id,
							expenditure_type = l_expenditure_type,
							suspense_reason_code = 'ES:' || r_suspense_ac.interface_status(recno),
							gl_project_flag = l_gl_project_flag,
							encumbrance_date = l_effective_date,
							status_code = 'N'
						WHERE	rowid = r_suspense_ac.row_id(recno)
						AND		enc_start_date <= g_def_end_date;

						add_st_warnings(p_assignment_id	=>	r_suspense_ac.assignment_id(recno),
								p_payroll_id		=>	r_suspense_ac.payroll_id(recno),
								p_element_type_id	=>	r_suspense_ac.element_type_id(recno),
								p_start_date		=>	r_suspense_ac.enc_start_date(recno),
								p_end_date			=>	r_suspense_ac.enc_end_date(recno),
								p_effective_date	=>	r_suspense_ac.encumbrance_date(recno),
								p_gl_ccid			=>	r_suspense_ac.gl_code_combination_id(recno),
								p_error_status		=>	r_suspense_ac.interface_status(recno));
					ELSE
						l_susp_exception := l_susp_ac_found;
					END IF;
				END IF;
			END LOOP;

			IF l_suspense_ac_failed = 'Y' THEN
				UPDATE	psp_enc_lines
				SET	suspense_org_account_id = NULL,
					gl_code_combination_id = orig_gl_code_combination_id,
					project_id = orig_project_id,
					task_id = orig_task_id,
					award_id = orig_award_id,
					expenditure_organization_id = orig_expenditure_org_id,
					expenditure_type = orig_expenditure_type,
					gl_project_flag = decode(orig_gl_code_combination_id,NULL,'P','G'),
					encumbrance_date = prev_effective_date
				WHERE	suspense_reason_code like 'ES:%'
				AND	enc_summary_line_id IN	(SELECT	enc_summary_line_id
								FROM	psp_enc_summary_lines pesl
								WHERE	pesl.payroll_action_id = p_payroll_action_id
								AND	pesl.group_id = p_group_id
								AND	status_code = 'R');
				UPDATE	psp_enc_lines
				SET	orig_gl_code_combination_id = NULL,
					orig_project_id = NULL,
					orig_task_id = NULL,
					orig_award_id = NULL,
					orig_expenditure_org_id = NULL,
					orig_expenditure_type = NULL,
					suspense_reason_code = NULL
				WHERE	suspense_reason_code like 'ES:%'
				AND	enc_summary_line_id IN	(SELECT	enc_summary_line_id
								FROM	psp_enc_summary_lines pesl
								WHERE	pesl.payroll_action_id = p_payroll_action_id
								AND	pesl.group_id = p_group_id
								AND	status_code = 'R');
			END IF;

			IF l_suspense_ac_not_found = 'Y' THEN
				g_susp_prob := 'Y';
				IF l_susp_exception = 'NO_G_AC' THEN
					RAISE no_global_acct_exists;
				ELSIF l_susp_exception = 'NO_DT_MCH' THEN
					RAISE no_val_date_matches;
				ELSIF l_susp_exception = 'NO_PROFL' THEN
					RAISE no_profile_exists;
				END IF;
			END IF;

			FORALL recno IN 1..r_interface.status.COUNT
			UPDATE	psp_enc_controls
			SET	gl_phase = 'TieBack'
			WHERE	enc_control_id IN	(SELECT	pesl.enc_control_id
							FROM	psp_enc_summary_lines pesl
							WHERE	pesl.enc_summary_line_id = r_interface.enc_summary_line_id(recno));

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	TieBack SQL%ROWCOUNT: ' || SQL%ROWCOUNT);

			FORALL recno IN 1..r_interface.status.COUNT
			UPDATE	psp_enc_controls
			SET	gl_phase = 'Summarize'
			WHERE	enc_control_id IN	(SELECT	pesl.enc_control_id
							FROM	psp_enc_summary_lines pesl
							WHERE	pesl.enc_summary_line_id = r_interface.enc_summary_line_id(recno)
							AND	pesl.status_code = 'N');

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Summarize SQL%ROWCOUNT: ' || SQL%ROWCOUNT);
		ELSIF (l_cnt_gl_interface = 0) THEN
			OPEN gl_tie_back_success_cur;
			FETCH gl_tie_back_success_cur BULK COLLECT INTO r_interface.enc_summary_line_id, r_interface.enc_control_id, r_interface.dr_cr_flag, r_interface.summary_amount;
			CLOSE gl_tie_back_success_cur;

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_interface.enc_summary_line_id.COUNT: ' || r_interface.enc_summary_line_id.COUNT);

			FORALL recno IN 1..r_interface.enc_summary_line_id.COUNT
			UPDATE	psp_enc_summary_lines
			SET	status_code = 'A'
			WHERE	enc_summary_line_id = r_interface.enc_summary_line_id(recno);

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated status_code to ''A'' in psp_enc_summary_lines');

			FORALL recno IN 1..r_interface.enc_summary_line_id.COUNT
			INSERT INTO psp_enc_lines_history
				(enc_line_id,			business_group_id,	enc_element_type_id,	encumbrance_date,
				dr_cr_flag,			encumbrance_amount,	status_code,		enc_line_type,
				schedule_line_id,		org_schedule_id,	default_org_account_id,	suspense_org_account_id,
				element_account_id,		gl_project_flag,	enc_summary_line_id,	person_id,
				assignment_id,			award_id,		task_id,		expenditure_type,
				expenditure_organization_id,	project_id,		gl_code_combination_id,	time_period_id,
				payroll_id,			set_of_books_id,	default_reason_code,	suspense_reason_code,
				enc_control_id,			change_flag,		last_update_date,	last_updated_by,
				last_update_login,		created_by,		creation_date,		enc_start_date,
				enc_end_date,			attribute_category,	attribute1,		attribute2,
				attribute3,			attribute4,		attribute5,		attribute6,
				attribute7,			attribute8,		attribute9,		attribute10,
				payroll_action_id,	hierarchy_code,	hierarchy_start_date,	hierarchy_end_date,
				orig_gl_code_combination_id,	orig_project_id,	orig_task_id,	orig_award_id,
				orig_expenditure_org_id,		orig_expenditure_type)
			SELECT	enc_line_id,			business_group_id,	enc_element_type_id,	encumbrance_date,
				dr_cr_flag,			encumbrance_amount,	'A',		enc_line_type,
				schedule_line_id,		org_schedule_id,	default_org_account_id,	suspense_org_account_id,
				element_account_id,		gl_project_flag,	enc_summary_line_id,	person_id,
				assignment_id,			award_id,		task_id,		expenditure_type,
				expenditure_organization_id,	project_id,		gl_code_combination_id,	time_period_id,
				payroll_id,			set_of_books_id,	default_reason_code,	suspense_reason_code,
				enc_control_id,			change_flag,		last_update_date,	last_updated_by,
				last_update_login,		created_by,		creation_date,		enc_start_date,
				enc_end_date,			attribute_category,	attribute1,		attribute2,
				attribute3,			attribute4,		attribute5,		attribute6,
				attribute7,			attribute8,		attribute9,		attribute10,
				payroll_action_id,	hierarchy_code,	hierarchy_start_date,	hierarchy_end_date,
				orig_gl_code_combination_id,	orig_project_id,	orig_task_id,	orig_award_id,
				orig_expenditure_org_id,		orig_expenditure_type
			FROM	psp_enc_lines
			WHERE	enc_summary_line_id = r_interface.enc_summary_line_id(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Copied successfully summarized and transferred lines into psp_enc_lines_history');

			FORALL recno IN 1..r_interface.enc_summary_line_id.COUNT
			DELETE FROM psp_enc_lines
			WHERE	enc_summary_line_id = r_interface.enc_summary_line_id(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted lines from psp_enc_lines that are summarized and trasnferred to target systems');

			FORALL recno IN 1..r_interface.enc_control_id.COUNT
			UPDATE	psp_enc_controls pec
			SET	gl_phase = 'TieBack',
				summ_gl_dr_amount = NVL(summ_gl_dr_amount, 0) + DECODE(r_interface.dr_cr_flag(recno), 'D', r_interface.summary_amount(recno), 0),
				summ_gl_cr_amount = NVL(summ_gl_cr_amount, 0) + DECODE(r_interface.dr_cr_flag(recno), 'C', r_interface.summary_amount(recno), 0)
			WHERE	enc_control_id = r_interface.enc_control_id(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated gl_phase, summ_gl_dr_amount, summ_gl_cr_amount in psp_enc_controls');
		END IF;
	ELSE
		g_process_complete := FALSE;
	END IF;

	p_return_status := fnd_api.g_ret_sts_success;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK');
EXCEPTION
	WHEN NO_PROFILE_EXISTS THEN
		g_error_api_path := SUBSTR('GL_ENC_TIE_BACK:'||g_error_api_path,1,230);
		fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
		fnd_msg_pub.add;
		p_return_status := fnd_api.g_ret_sts_success;
	WHEN NO_VAL_DATE_MATCHES THEN
		g_error_api_path := SUBSTR('GL_ENC_TIE_BACK:'||g_error_api_path,1,230);
		fnd_message.set_name('PSP','PSP_NO_VAL_DATE_MATCHES');
		fnd_message.set_token('ORG_NAME',l_orig_org_name);
		fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
		fnd_msg_pub.add;
		p_return_status := fnd_api.g_ret_sts_success;
	WHEN NO_GLOBAL_ACCT_EXISTS THEN
		g_error_api_path := SUBSTR('GL_ENC_TIE_BACK:'||g_error_api_path,1,230);
		fnd_message.set_name('PSP','PSP_NO_GLOBAL_ACCT_EXISTS');
		fnd_message.set_token('ORG_NAME',l_orig_org_name);
		fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
		fnd_msg_pub.add;
		p_return_status := fnd_api.g_ret_sts_success;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		g_error_api_path := 'GL_ENC_TIE_BACK:'||g_error_api_path;
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK');
	WHEN OTHERS THEN
		g_error_api_path := 'GL_ENC_TIE_BACK:'||g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','GL_ENC_TIE_BACK');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK');
END gl_enc_tie_back;
--	End of changes for Create and Update multi thread enh.

--	##########################################################################
--	This procedure inserts data into gl_interface
--	##########################################################################


PROCEDURE insert_into_gl_int (
			P_SET_OF_BOOKS_ID 		IN	NUMBER,
			P_ACCOUNTING_DATE			IN	DATE,
			P_CURRENCY_CODE			IN	VARCHAR2,
			P_USER_JE_CATEGORY_NAME		IN	VARCHAR2,
			P_USER_JE_SOURCE_NAME		IN	VARCHAR2,
			P_ENCUMBRANCE_TYPE_ID		IN	NUMBER,
			P_CODE_COMBINATION_ID		IN	NUMBER,
			P_ENTERED_DR			IN	NUMBER,
			P_ENTERED_CR			IN	NUMBER,
			P_GROUP_ID				IN	NUMBER,
			P_REFERENCE1			IN	VARCHAR2,
			P_REFERENCE2			IN	VARCHAR2,
			P_REFERENCE4			IN	VARCHAR2,
			P_REFERENCE6			IN	VARCHAR2,
			P_REFERENCE10			IN	VARCHAR2,
			P_ATTRIBUTE1			IN	VARCHAR2,
			P_ATTRIBUTE2			IN	VARCHAR2,
			P_ATTRIBUTE3			IN	VARCHAR2,
			P_ATTRIBUTE4			IN	VARCHAR2,
			P_ATTRIBUTE5			IN	VARCHAR2,
			P_ATTRIBUTE6			IN	VARCHAR2,
			P_ATTRIBUTE7			IN	VARCHAR2,
			P_ATTRIBUTE8			IN	VARCHAR2,
			P_ATTRIBUTE9			IN	VARCHAR2,
			P_ATTRIBUTE10			IN	VARCHAR2,
			P_ATTRIBUTE11			IN	VARCHAR2,
			P_ATTRIBUTE12			IN	VARCHAR2,
			P_ATTRIBUTE13			IN	VARCHAR2,
			P_ATTRIBUTE14			IN	VARCHAR2,
			P_ATTRIBUTE15			IN	VARCHAR2,
			P_ATTRIBUTE16			IN	VARCHAR2,
			P_ATTRIBUTE17			IN	VARCHAR2,
			P_ATTRIBUTE18			IN	VARCHAR2,
			P_ATTRIBUTE19			IN	VARCHAR2,
			P_ATTRIBUTE20			IN	VARCHAR2,
			P_ATTRIBUTE21			IN	VARCHAR2,
			P_ATTRIBUTE22			IN	VARCHAR2,
			P_ATTRIBUTE23			IN	VARCHAR2,
			P_ATTRIBUTE24			IN	VARCHAR2,
			P_ATTRIBUTE25			IN	VARCHAR2,
			P_ATTRIBUTE26			IN	VARCHAR2,
			P_ATTRIBUTE27			IN	VARCHAR2,
			P_ATTRIBUTE28			IN	VARCHAR2,
			P_ATTRIBUTE29			IN	VARCHAR2,
			P_ATTRIBUTE30			IN	VARCHAR2,
			P_RETURN_STATUS			OUT NOCOPY	VARCHAR2) IS
 BEGIN

   INSERT INTO GL_INTERFACE(
	STATUS,
	SET_OF_BOOKS_ID,
	ACCOUNTING_DATE,
	CURRENCY_CODE,
	DATE_CREATED,
	CREATED_BY,
	ACTUAL_FLAG,
	USER_JE_CATEGORY_NAME,
	USER_JE_SOURCE_NAME,
	ENCUMBRANCE_TYPE_ID,
	CODE_COMBINATION_ID,
	ENTERED_DR,
	ENTERED_CR,
	GROUP_ID,
	REFERENCE1,
	REFERENCE2,
	REFERENCE4,
	REFERENCE6,
	REFERENCE10,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	ATTRIBUTE16,
	ATTRIBUTE17,
	ATTRIBUTE18,
	ATTRIBUTE19,
	ATTRIBUTE20,
	REFERENCE21,
	REFERENCE22,
	REFERENCE23,
	REFERENCE24,
	REFERENCE25,
	REFERENCE26,
	REFERENCE27,
	REFERENCE28,
	REFERENCE29,
	REFERENCE30)
   VALUES(
	'NEW',
	P_SET_OF_BOOKS_ID,
	P_ACCOUNTING_DATE,
	P_CURRENCY_CODE,
	SYSDATE,
	FND_GLOBAL.USER_ID,
	'E',
	P_USER_JE_CATEGORY_NAME,
	P_USER_JE_SOURCE_NAME,
	P_ENCUMBRANCE_TYPE_ID,
	P_CODE_COMBINATION_ID,
	P_ENTERED_DR,
	P_ENTERED_CR,
	P_GROUP_ID,
	P_REFERENCE1,
	P_REFERENCE2,
	P_REFERENCE4,
	P_REFERENCE6,
	P_REFERENCE10,
	P_ATTRIBUTE1,
	P_ATTRIBUTE2,
	P_ATTRIBUTE3,
	P_ATTRIBUTE4,
	P_ATTRIBUTE5,
	P_ATTRIBUTE6,
	P_ATTRIBUTE7,
	P_ATTRIBUTE8,
	P_ATTRIBUTE9,
	P_ATTRIBUTE10,
	P_ATTRIBUTE11,
	P_ATTRIBUTE12,
	P_ATTRIBUTE13,
	P_ATTRIBUTE14,
	P_ATTRIBUTE15,
	P_ATTRIBUTE16,
	P_ATTRIBUTE17,
	P_ATTRIBUTE18,
	P_ATTRIBUTE19,
	P_ATTRIBUTE20,
	P_ATTRIBUTE21,
	P_ATTRIBUTE22,
	P_ATTRIBUTE23,
	P_ATTRIBUTE24,
	P_ATTRIBUTE25,
	P_ATTRIBUTE26,
	P_ATTRIBUTE27,
	P_ATTRIBUTE28,
	P_ATTRIBUTE29,
	P_ATTRIBUTE30);

    p_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
   --   dbms_output.put_line('Error while inserting into gl_interface..........');
      g_error_api_path := 'insert_into_gl_int:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('psp_enc_sum_tran','insert_into_gl_int');
      p_return_status := fnd_api.g_ret_sts_unexp_error;


END;

--	##########################################################################
--	This procedure summarizes all the lines from psp_enc_lines
--		where gl_project_flag = 'P' and inserts the summarized lines
--			into psp_enc_summary_lines

--	Depending on the setup options, this procedure groups transactions from
--	PSP_ENC_LINES and inserts the summarized lines into PSP_ENC_SUMMARY_LINES

--	There are two setup options in PSP_ENC_SETUP_OPTIONS table called 'TIME_BASED_SUMM'
--	and 'CI_BASED_SUMM_OGM' on which the procedure depends.

--	If the 'TIME_BASED_SUMM' = 1 and 'CI_BASED_SUMM_OGM' = 1
--	then the summarization is done upto the employee level for each time period

--	If the 'TIME_BASED_SUMM' = 2 and 'CI_BASED_SUMM_OGM' = 1
--	then the summarization is done upto the employee level for each GL period

--	##########################################################################

/****	Commented for Create and Update Multi thread
PROCEDURE create_gms_enc_sum_lines(	p_payroll_id IN NUMBER,
					p_return_status	OUT NOCOPY  VARCHAR2
					) IS

	CURSOR 	enc_control_cur IS
   	SELECT 	enc_control_id,
          	payroll_id,
          	time_period_id
   	FROM   	psp_enc_controls
   	WHERE 	payroll_id = nvl(p_payroll_id, payroll_id)
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type IN ('N', 'Q', 'U') -- Included 'Q' for Quick Upd. Enh. 2143723.
   	AND    	action_code = 'I'
   	AND    	run_id = g_run_id
   	AND	business_group_id = g_business_group_id
	AND	set_of_books_id = g_set_of_books_id
        AND     (gms_phase is null or gms_phase = 'TieBack');    --- 2444657

   	CURSOR 	enc_sum_lines_p_cur(
					p_enc_control_id	IN  NUMBER
					)IS
   	SELECT
--	ptp.end_date eff_dt,   for bug fix 1971612
                pel.encumbrance_date eff_dt,
		pel.dr_cr_flag,
		sum(pel.encumbrance_amount) sum_amt,
		pel.gl_project_flag,
		pel.person_id,
		pel.assignment_id,	-- Included for Enh. 2143723
		decode(suspense_org_account_id,NULL,pel.project_id,poa.project_id) project_id,
		decode(suspense_org_account_id,NULL,pel.task_id,poa.task_id) task_id ,
		decode(suspense_org_account_id,NULL,pel.award_id,poa.award_id)award_id ,
		decode(suspense_org_account_id,NULL,pel.expenditure_type,poa.expenditure_type) expenditure_type ,
		decode(suspense_org_account_id,NULL,pel.expenditure_organization_id,poa.expenditure_organization_id)
		expenditure_organization_id,
--		Introduced DFF columns for bug fix 2908859
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute_category, poa.attribute_category), NULL) attribute_category,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute1, poa.attribute1), NULL) attribute1,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute2, poa.attribute2), NULL) attribute2,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute3, poa.attribute3), NULL) attribute3,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute4, poa.attribute4), NULL) attribute4,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute5, poa.attribute5), NULL) attribute5,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute6, poa.attribute6), NULL) attribute6,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute7, poa.attribute7), NULL) attribute7,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute8, poa.attribute8), NULL) attribute8,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute9, poa.attribute9), NULL) attribute9,
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute10, poa.attribute10), NULL) attribute10
/ *		pel.project_id,
		pel.task_id,
		pel.award_id,
		pel.expenditure_type,
		pel.expenditure_organization_id * /
--		,pai.set_of_books_id
   	FROM		PSP_ENC_LINES  		PEL,
			PER_TIME_PERIODS	PTP,
			PSP_ORGANIZATION_ACCOUNTS POA
--			,PA_IMPLEMENTATIONS_ALL	PAI
   	WHERE 		PEL.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
--	AND		PEL.ENCUMBRANCE_DATE BETWEEN PTP.START_DATE AND PTP.END_DATE
--         Commented out for bug fix 1971612
	AND		PEL.GL_PROJECT_FLAG = 'P'
   	AND		PEL.ENCUMBRANCE_AMOUNT <> 0
	AND		PEL.ENC_CONTROL_ID = p_enc_control_id
--	Refined the following condition for bug fix 3233373
	AND		(	(suspense_org_account_id IS NULL AND PEL.AWARD_ID IS NOT NULL)
			OR	(poa.award_id IS NOT NULL))
--	End of bug fix 3233373
	AND		PEL.SUSPENSE_ORG_ACCOUNT_ID = POA.ORGANIZATION_ACCOUNT_ID(+)
--   	AND 		PEL.BUSINESS_GROUP_ID = PAI.BUSINESS_GROUP_ID
--	AND		PAI.SET_OF_BOOKS_ID = g_set_of_books_id
	GROUP BY
--	ptp.end_date,
                        pel.encumbrance_date,
--			pel.project_id,
--			pel.task_id,
--			pel.award_id,
--			pel.expenditure_type,
--			pel.expenditure_organization_id,
			DECODE(suspense_org_account_id,NULL,pel.project_id,poa.project_id),
	                DECODE(suspense_org_account_id,NULL,pel.task_id,poa.task_id),
        	        DECODE(suspense_org_account_id,NULL,pel.award_id,poa.award_id) ,
                	DECODE(suspense_org_account_id,NULL,pel.expenditure_type,poa.expenditure_type) ,
                	DECODE(suspense_org_account_id,NULL,pel.expenditure_organization_id,poa.expenditure_organization_id),
			pel.person_id,
			pel.assignment_id,	-- Included for Enh. 2143723
			pel.dr_cr_flag,
			pel.gl_project_flag,
--		Introduced DFF columns for bug fix 2908859
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute_category, poa.attribute_category), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute1, poa.attribute1), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute2, poa.attribute2), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute3, poa.attribute3), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute4, poa.attribute4), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute5, poa.attribute5), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute6, poa.attribute6), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute7, poa.attribute7), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute8, poa.attribute8), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute9, poa.attribute9), NULL),
		DECODE(g_dff_grouping_option, 'Y', DECODE(suspense_org_account_id, NULL, pel.attribute10, poa.attribute10), NULL);
--			,pai.set_of_books_id;

/ *
Code commented  out as this  is obsolete now
 Bug fix 1971612/1831493

	CURSOR 	enc_sum_lines_g_cur(
					p_enc_control_id	IN  NUMBER
					) IS
   	SELECT 	glp.end_date eff_dt,
		pel.dr_cr_flag,
		sum(pel.encumbrance_amount) sum_amt,
		pel.gl_project_flag,
		pel.person_id,
		pel.project_id,
		pel.task_id,
		pel.award_id,
		pel.expenditure_type,
		pel.expenditure_organization_id,
		pai.set_of_books_id
   	FROM		PSP_ENC_LINES  		PEL,
			GL_PERIODS		GLP,
			PA_IMPLEMENTATIONS_ALL	PAI
   	WHERE 		PEL.BUSINESS_GROUP_ID = PAI.BUSINESS_GROUP_ID
   	AND		GLP.PERIOD_TYPE = PAI.PA_PERIOD_TYPE
   	AND 		PEL.ENCUMBRANCE_DATE BETWEEN GLP.START_DATE AND GLP.END_DATE
	AND		PEL.GL_PROJECT_FLAG = 'P'
   	AND		PEL.ENCUMBRANCE_AMOUNT <> 0
	AND		PEL.ENC_CONTROL_ID = p_enc_control_id
	AND		PAI.SET_OF_BOOKS_ID = g_set_of_books_id
	AND		PEL.AWARD_ID IS NOT NULL
	GROUP BY	glp.end_date,
			pel.project_id,
			pel.task_id,
			pel.award_id,
			pel.expenditure_type,
			pel.expenditure_organization_id,
			pel.person_id,
			pel.dr_cr_flag,
			pel.gl_project_flag,
			pai.set_of_books_id;


	l_time_para_value		VARCHAR2(1);
	l_ogm_para_value			VARCHAR2(1);

	commented the above variable as part of Enh. 2143723
* /

	l_bg_id				NUMBER := g_business_group_id;
	enc_control_rec			enc_control_cur%ROWTYPE;
     	enc_sum_lines_p_rec		enc_sum_lines_p_cur%ROWTYPE;

/**************************************************************************
	enc_sum_lines_g_rec		enc_sum_lines_g_cur%ROWTYPE;

 Bug fix 1971613 /Bug 1831493
***************************************************************************** /

	l_enc_summary_line_id		NUMBER(10);
	l_return_status			VARCHAR2(10);
	l_error			VARCHAR2(100);
	l_product		VARCHAR2(3);

BEGIN

/ *	Commented the following code as Enc. Sum. and Tr. setup options are obsolete as part of Enh. 2143723

	BEGIN
	SELECT 	parameter_value
 	INTO	l_time_para_value
 	FROM	psp_enc_setup_options
 	WHERE	setup_parameter = 'TIME_BASED_SUMM'
	AND	business_group_id = l_bg_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_error := 'TIME_BASED_SUMM';
		l_product := 'PSP';
		fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
		fnd_message.set_token('ERROR',l_error);
		fnd_message.set_token('PRODUCT',l_product);
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

	BEGIN
	SELECT 	parameter_value
	INTO	l_ogm_para_value
	FROM	psp_enc_setup_options
	WHERE	setup_parameter = 'CI_BASED_SUMM_OGM'
	AND	business_group_id = l_bg_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_error := 'CI_BASED_SUMM_OGM';
		l_product := 'PSP';
		fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
		fnd_message.set_token('ERROR',l_error);
		fnd_message.set_token('PRODUCT',l_product);
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

     	IF	l_time_para_value = '1' and l_ogm_para_value = '1' THEN
End of Enh. fix 2143723	* /

	OPEN enc_control_cur;
  	LOOP
   		FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

		OPEN enc_sum_lines_p_cur(enc_control_rec.enc_control_id);
		LOOP
			FETCH enc_sum_lines_p_cur INTO enc_sum_lines_p_rec;
    			IF enc_sum_lines_p_cur%ROWCOUNT = 0  THEN
       			CLOSE enc_sum_lines_p_cur;
       			EXIT;
			ELSIF enc_sum_lines_p_cur%NOTFOUND THEN
                	   update psp_enc_controls
                   	      set gms_phase = 'Summarize'  ---NULL commented for 2444657
                 	    where enc_control_id = enc_control_rec.enc_control_id;
       			CLOSE enc_sum_lines_p_cur;
       			EXIT;
     			END IF;

			IF enc_sum_lines_p_rec.dr_cr_flag = 'C' THEN
				enc_sum_lines_p_rec.sum_amt := 0 - enc_sum_lines_p_rec.sum_amt;
			END IF;
    				insert_into_enc_sum_lines(
							l_enc_summary_line_id,
							L_BG_ID,
							enc_control_rec.enc_control_id,
							enc_control_rec.time_period_id,
							enc_sum_lines_p_rec.person_id,
							enc_sum_lines_p_rec.assignment_id, --Included for Enh. 2143723
                					enc_sum_lines_p_rec.eff_dt,
--							enc_sum_lines_p_rec.set_of_books_id,
							g_set_of_books_id,
							NULL,
 							enc_sum_lines_p_rec.project_id,
 							enc_sum_lines_p_rec.expenditure_organization_id,
 							enc_sum_lines_p_rec.expenditure_type,
							enc_sum_lines_p_rec.task_id,
 							enc_sum_lines_p_rec.award_id,
 							enc_sum_lines_p_rec.sum_amt,
 							enc_sum_lines_p_rec.dr_cr_flag,
							'N',
							enc_control_rec.payroll_id,
 							NULL,
							enc_sum_lines_p_rec.gl_project_flag,
							enc_sum_lines_p_rec.attribute_category,	-- Introduced DFF columns for bug fix 2908859
							enc_sum_lines_p_rec.attribute1,
							enc_sum_lines_p_rec.attribute2,
							enc_sum_lines_p_rec.attribute3,
							enc_sum_lines_p_rec.attribute4,
							enc_sum_lines_p_rec.attribute5,
							enc_sum_lines_p_rec.attribute6,
							enc_sum_lines_p_rec.attribute7,
							enc_sum_lines_p_rec.attribute8,
							enc_sum_lines_p_rec.attribute9,
							enc_sum_lines_p_rec.attribute10,
							p_return_status);
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			IF (g_dff_grouping_option = 'N') THEN	-- Introduced for bug fix 2908859
				UPDATE 	psp_enc_lines
         			SET 	enc_summary_line_id = l_enc_summary_line_id
         			WHERE 	-- project_id = enc_sum_lines_p_rec.project_id	Commented for bug fix 3194807
--	Introduced the suspense_org_account verification for bug fix 3194807
					(	(suspense_org_account_id IS NOT NULL
						AND	suspense_reason_code like 'ES:%'
						AND	EXISTS	(SELECT	1	FROM psp_organization_accounts poa
								WHERE	poa.organization_account_id = suspense_org_account_id
								AND	poa.project_id = enc_sum_lines_p_rec.project_id
								AND	poa.task_id = enc_sum_lines_p_rec.task_id
								AND	poa.expenditure_organization_id = enc_sum_lines_p_rec.expenditure_organization_id
								AND	poa.expenditure_type = enc_sum_lines_p_rec.expenditure_type
								AND	poa.award_id = enc_sum_lines_p_rec.award_id))
					OR	(project_id = enc_sum_lines_p_rec.project_id
						AND	task_id = enc_sum_lines_p_rec.task_id
						AND	expenditure_organization_id = enc_sum_lines_p_rec.expenditure_organization_id
						AND	expenditure_type = enc_sum_lines_p_rec.expenditure_type
						AND	award_id = enc_sum_lines_p_rec.award_id))
--         		AND	task_id = enc_sum_lines_p_rec.task_id	Commented for bug fix 3194807
				AND	enc_control_id = enc_control_rec.enc_control_id
				AND	time_period_id = enc_control_rec.time_period_id
	--         		AND	award_id = enc_sum_lines_p_rec.award_id	Commented for bug fix 3194807
--         		AND	expenditure_type = enc_sum_lines_p_rec.expenditure_type	Commented for bug fix 3194807
--         		AND	expenditure_organization_id = enc_sum_lines_p_rec.expenditure_organization_id	Commented for bug fix 3194807
         			AND	person_id = enc_sum_lines_p_rec.person_id
--	Included the following chek for Enh. 2143723
         			AND	assignment_id = enc_sum_lines_p_rec.assignment_id
         			AND	dr_cr_flag = enc_sum_lines_p_rec.dr_cr_flag
         			AND	gl_project_flag = enc_sum_lines_p_rec.gl_project_flag
                        	AND     trunc(encumbrance_date) = trunc(enc_sum_lines_p_rec.eff_dt);   ---- bug 3462452
		--	AND	set_of_books_id = enc_sum_lines_p_rec.set_of_books_id;
--	Introduced ELSE portion for bug fix 2908859
			ELSE
				UPDATE 	psp_enc_lines
         			SET 	enc_summary_line_id = l_enc_summary_line_id
         			WHERE 	enc_control_id = enc_control_rec.enc_control_id
         			AND	payroll_id = enc_control_rec.payroll_id
				AND	time_period_id = enc_control_rec.time_period_id
         			AND	person_id = enc_sum_lines_p_rec.person_id
         			AND	assignment_id = enc_sum_lines_p_rec.assignment_id
         			AND	dr_cr_flag = enc_sum_lines_p_rec.dr_cr_flag
         			AND	gl_project_flag = enc_sum_lines_p_rec.gl_project_flag
                        	AND     trunc(encumbrance_date) = trunc(enc_sum_lines_p_rec.eff_dt)  --- added for 3462452
				AND	(	(suspense_org_account_id IS NOT NULL
						AND	suspense_reason_code like 'ES:%'
						AND	EXISTS	(SELECT	1	FROM psp_organization_accounts poa
								WHERE	poa.organization_account_id = suspense_org_account_id
								AND	poa.project_id = enc_sum_lines_p_rec.project_id
								AND	poa.task_id = enc_sum_lines_p_rec.task_id
								AND	poa.expenditure_organization_id = enc_sum_lines_p_rec.expenditure_organization_id
								AND	poa.expenditure_type = enc_sum_lines_p_rec.expenditure_type
								AND	poa.award_id = enc_sum_lines_p_rec.award_id
								AND	NVL(poa.attribute_category, 'NULL') =
									NVL(enc_sum_lines_p_rec.attribute_category, 'NULL')
								AND	NVL(poa.attribute1, 'NULL') = NVL(enc_sum_lines_p_rec.attribute1, 'NULL')
								AND	NVL(poa.attribute2, 'NULL') = NVL(enc_sum_lines_p_rec.attribute2, 'NULL')
								AND	NVL(poa.attribute3, 'NULL') = NVL(enc_sum_lines_p_rec.attribute3, 'NULL')
								AND	NVL(poa.attribute4, 'NULL') = NVL(enc_sum_lines_p_rec.attribute4, 'NULL')
								AND	NVL(poa.attribute5, 'NULL') = NVL(enc_sum_lines_p_rec.attribute5, 'NULL')
								AND	NVL(poa.attribute6, 'NULL') = NVL(enc_sum_lines_p_rec.attribute6, 'NULL')
								AND	NVL(poa.attribute7, 'NULL') = NVL(enc_sum_lines_p_rec.attribute7, 'NULL')
								AND	NVL(poa.attribute8, 'NULL') = NVL(enc_sum_lines_p_rec.attribute8, 'NULL')
								AND	NVL(poa.attribute9, 'NULL') = NVL(enc_sum_lines_p_rec.attribute9, 'NULL')
								AND	NVL(poa.attribute10, 'NULL') = NVL(enc_sum_lines_p_rec.attribute10, 'NULL')))
					OR (	project_id = enc_sum_lines_p_rec.project_id
						AND	task_id = enc_sum_lines_p_rec.task_id
						AND	expenditure_organization_id = enc_sum_lines_p_rec.expenditure_organization_id
						AND	expenditure_type = enc_sum_lines_p_rec.expenditure_type
						AND	award_id = enc_sum_lines_p_rec.award_id
						AND	NVL(attribute_category, 'NULL') = NVL(enc_sum_lines_p_rec.attribute_category, 'NULL')
						AND	NVL(attribute1, 'NULL') = NVL(enc_sum_lines_p_rec.attribute1, 'NULL')
						AND	NVL(attribute2, 'NULL') = NVL(enc_sum_lines_p_rec.attribute2, 'NULL')
						AND	NVL(attribute3, 'NULL') = NVL(enc_sum_lines_p_rec.attribute3, 'NULL')
						AND	NVL(attribute4, 'NULL') = NVL(enc_sum_lines_p_rec.attribute4, 'NULL')
						AND	NVL(attribute5, 'NULL') = NVL(enc_sum_lines_p_rec.attribute5, 'NULL')
						AND	NVL(attribute6, 'NULL') = NVL(enc_sum_lines_p_rec.attribute6, 'NULL')
						AND	NVL(attribute7, 'NULL') = NVL(enc_sum_lines_p_rec.attribute7, 'NULL')
						AND	NVL(attribute8, 'NULL') = NVL(enc_sum_lines_p_rec.attribute8, 'NULL')
						AND	NVL(attribute9, 'NULL') = NVL(enc_sum_lines_p_rec.attribute9, 'NULL')
						AND	NVL(attribute10, 'NULL') = NVL(enc_sum_lines_p_rec.attribute10, 'NULL')));
--	Introduced ELSE portion for bug fix 2908859
			END IF;
     		END LOOP;

	END LOOP;


/ *********************************************************************************************

 THe Summarize  by gl _period option is obsolete nad no longer supported  , refer bug
	ELSIF	l_time_para_value = '2' and l_ogm_para_value = '1' THEN

	OPEN enc_control_cur;
  	LOOP
   		FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

		OPEN enc_sum_lines_g_cur(enc_control_rec.enc_control_id);
		LOOP
     			FETCH enc_sum_lines_g_cur INTO enc_sum_lines_g_rec;
			IF enc_sum_lines_g_cur%ROWCOUNT = 0 THEN
			  CLOSE enc_sum_lines_g_cur;
			  EXIT;
     			ELSIF enc_sum_lines_g_cur%NOTFOUND THEN
                	   update psp_enc_controls
                   	      set gms_phase = NULL
                 	    where enc_control_id = enc_control_rec.enc_control_id;
       			CLOSE enc_sum_lines_g_cur;
       			EXIT;
     			END IF;
   				insert_into_enc_sum_lines(
							l_enc_summary_line_id,
							l_bg_id,
							enc_control_rec.enc_control_id,
							enc_control_rec.time_period_id,
							enc_sum_lines_g_rec.person_id,
                					NULL,
                					enc_sum_lines_g_rec.eff_dt,
							enc_sum_lines_g_rec.set_of_books_id,
							NULL,
							enc_sum_lines_g_rec.project_id,
 							enc_sum_lines_g_rec.expenditure_organization_id,
 							enc_sum_lines_g_rec.expenditure_type,
 							enc_sum_lines_g_rec.task_id,
 							enc_sum_lines_g_rec.award_id,
 							enc_sum_lines_g_rec.sum_amt,
 							enc_sum_lines_g_rec.dr_cr_flag,
							'N',
							enc_control_rec.payroll_id,
 							NULL,
							enc_sum_lines_g_rec.gl_project_flag,
							l_return_status);
     				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			UPDATE 	psp_enc_lines
         		SET 	enc_summary_line_id = l_enc_summary_line_id
         		WHERE 	project_id = enc_sum_lines_g_rec.project_id
         		AND	task_id = enc_sum_lines_g_rec.task_id
			AND	enc_control_id = enc_control_rec.enc_control_id
			AND	time_period_id = enc_control_rec.time_period_id
         		AND	award_id = enc_sum_lines_g_rec.award_id
         		AND	expenditure_type = enc_sum_lines_g_rec.expenditure_type
         		AND	expenditure_organization_id = enc_sum_lines_g_rec.expenditure_organization_id
         		AND	person_id = enc_sum_lines_g_rec.person_id
         		AND	dr_cr_flag = enc_sum_lines_g_rec.dr_cr_flag
         		AND	gl_project_flag = enc_sum_lines_g_rec.gl_project_flag;
			--AND	set_of_books_id = enc_sum_lines_g_rec.set_of_books_id;
       		END LOOP;

	END LOOP;
	END IF; Commented this END IF as part of Enh. 2143723
********************************************************************************** /

	--COMMIT;
	p_return_status	:= fnd_api.g_ret_sts_success;

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     		g_error_api_path := 'CREATE_GMS_ENC_SUM_LINES:'||g_error_api_path;
     		p_return_status := fnd_api.g_ret_sts_unexp_error;

	WHEN OTHERS THEN
     		g_error_api_path := 'CREATE_GMS_ENC_SUM_LINES:'||g_error_api_path;
     		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','CREATE_GMS_ENC_SUM_LINES');
     		p_return_status := fnd_api.g_ret_sts_unexp_error;

END;
	End of comment for Create and Update multi thread	*****/

--	##########################################################################
--	This procedure transfers summarized lines from psp_enc_summary_lines
--		with gl_project_flag = 'P' to pa_transaction_interface

--	This procedure transfers lines from PSP_ENC_SUMMARY_LINES into PA_TRANSACTION_INTERFACE,
--	kicks off the TRANSACTION IMPORT program in GMS and sends ENC_CONTROL_ID, END_DATE for
--	the relevant TIME_PERIOD_ID and GMS_BATCH_NAME into the tie back procedure.
--	##########################################################################
--	Introduced the following modified procedure for Create and Update multi thread
PROCEDURE tr_to_gms_int(p_payroll_action_id    IN NUMBER,
			p_return_status	OUT NOCOPY  VARCHAR2) IS
l_tr_source			VARCHAR2(30);
l_exp_end_dt			DATE;
l_return_status			VARCHAR2(50);
req_id				NUMBER(15);
call_status			BOOLEAN;
rphase				VARCHAR2(30);
rstatus				VARCHAR2(30);
dphase				VARCHAR2(30);
dstatus				VARCHAR2(30);
message				VARCHAR2(240);
p_errbuf			VARCHAR2(32767);
p_retcode			VARCHAR2(32767);
return_back			EXCEPTION;
l_rec_count			NUMBER;
l_error				VARCHAR2(100);
l_product			VARCHAR2(3);
l_value				VARCHAR2(200);
l_table				VARCHAR2(100);
l_rec_no			NUMBER;
l_effective_date		DATE;
l_tie_back_failed		VARCHAR2(1);
l_gms_batch_name		VARCHAR2(10);
l_raise_error			BOOLEAN;

CURSOR	int_cur IS
SELECT	pa_txn_interface_s.NEXTVAL,
	pesl.enc_summary_line_id,
	pesl.effective_date,
	pesl.time_period_id,
	pesl.person_id,
	pesl.project_id,
	pesl.task_id,
	pesl.award_id,
	pesl.expenditure_type,
	pesl.expenditure_organization_id,
	DECODE(pec.uom, 'M', g_currency_code, 'STAT') currency_code,
	TO_NUMBER(DECODE(pec.uom, 'H', pesl.summary_amount, 1)) quantity,
	TO_NUMBER(DECODE(pec.uom, 'M', pesl.summary_amount, 0)) summary_amount,
	pesl.dr_cr_flag,
	pesl.attribute2,
	pesl.attribute3,
	pesl.attribute6,
	pesl.attribute7,
	pesl.attribute8,
	pesl.attribute9,
	pesl.attribute10,
	pesl.expenditure_item_id,
	hou.name exp_org_name,
	ppa.segment1 project_number,
	ppa.org_id operating_unit,
	pt.task_number,
	TO_CHAR(pesl.enc_control_id) || ':' || ptp.period_name expenditure_comment,
	ptp.period_name,
	ptp.end_date,
	pesl.effective_date,
	pesl.gms_batch_name,
	DECODE(pec.uom, 'H', DECODE(SIGN(summary_amount), -1, 'Y')) unmatched_nve_txn_flag  --6242618
FROM	psp_enc_summary_lines pesl,
	hr_organization_units hou,
	pa_projects_all ppa,
	pa_tasks pt,
	per_time_periods ptp,
	psp_enc_controls pec
WHERE 	pec.payroll_action_id = p_payroll_action_id
AND	pec.enc_control_id = pesl.enc_control_id
AND	pesl.status_code = 'N'
AND	pesl.gl_code_combination_id IS NULL
AND	pesl.award_id IS NOT NULL
AND	pesl.superceded_line_id IS NULL
AND	pesl.expenditure_organization_id = hou.organization_id (+)
AND	pesl.project_id = ppa.project_id (+)
AND	pesl.task_id = pt.task_id (+)
AND	pesl.time_period_id = ptp.time_period_id
AND	gms_batch_name IS NOT NULL;

TYPE GMS_TIE_RECTYPE IS RECORD
	(R_CONTROL_ID		NUMBER,
	R_END_DATE		DATE,
	R_GMS_BATCH_NAME	VARCHAR2(80));

GMS_TIE_REC     GMS_TIE_RECTYPE;

TYPE GMS_TIE_TABTYPE IS TABLE OF GMS_TIE_REC%TYPE INDEX BY BINARY_INTEGER;

GMS_TIE_TAB     GMS_TIE_TABTYPE;
gms_rec		gms_transaction_interface_all%ROWTYPE;
l_txn_source	varchar2(30);
l_gms_transaction_source VARCHAR2(30);
l_org_id	NUMBER(15);
l_txn_interface_id	NUMBER;
l_gms_install	BOOLEAN	DEFAULT	gms_install.enabled;

TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_char_300 IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;
TYPE t_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE r_enc_control_rec IS RECORD (enc_control_id	t_number_15);
r_enc_controls	r_enc_control_rec;

CURSOR	enc_control_id_cur IS
SELECT	DISTINCT enc_control_id
FROM	psp_enc_summary_lines
WHERE	payroll_action_id = p_payroll_action_id
AND	superceded_line_id IS NULL
AND	gms_batch_name IS NOT NULL;

CURSOR	transaction_source_cur IS
SELECT	transaction_source
FROM	pa_transaction_sources
WHERE	transaction_source = 'GOLDE';

CURSOR	gms_batch_name_cur IS
SELECT	DISTINCT gms_batch_name
FROM	psp_enc_summary_lines pesl
WHERE	payroll_action_id = p_payroll_action_id
AND	status_code = 'N'
AND	superceded_line_id IS NULL
AND	gl_code_combination_id IS NULL;

CURSOR	employee_number_cur IS
SELECT	DISTINCT pesl.person_id,
	papf.employee_number
FROM	per_all_people_f papf,
	psp_enc_summary_lines pesl
WHERE	pesl.payroll_action_id = p_payroll_action_id
AND	papf.person_id = pesl.person_id
AND	pesl.superceded_line_id IS NULL
AND	pesl.gms_batch_name IS NOT NULL
AND	pesl.effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date;

TYPE r_gms_batch_rec IS RECORD (gms_batch_name	t_char_300);
r_gms_batch	r_gms_batch_rec;

TYPE t_person IS RECORD
	(person_id	t_number_15,
	employee_number	t_char_300);
r_person	t_person;

TYPE t_interface IS RECORD
	(txn_interface_id		t_number_15,
	enc_summary_line_id		t_number_15,
	effective_date			t_date,
	time_period_id			t_number_15,
	person_id			t_number_15,
	project_id			t_number_15,
	task_id				t_number_15,
	award_id			t_number_15,
	expenditure_type		t_char_300,
	expenditure_organization_id	t_number_15,
	currency_code			t_char_300,
	quantity			t_number,
	summary_amount			t_number,
	unmatched_nve_txn_flag		t_char_300,
	dr_cr_flag			t_char_300,
	attribute2			t_char_300,
	attribute3			t_char_300,
	attribute6			t_char_300,
	attribute7			t_char_300,
	attribute8			t_char_300,
	attribute9			t_char_300,
	attribute10			t_char_300,
	expenditure_item_id		t_number_15,
	employee_number			t_char_300,
	exp_org_name			t_char_300,
	project_number			t_char_300,
	operating_unit			t_char_300,
	task_number			t_char_300,
	expenditure_comment		t_char_300,
	period_name			t_char_300,
	end_date			t_date,
	gms_overriding_date		t_date,
	exp_end_date			t_date,
	gms_batch_name                  t_char_300);

r_interface	t_interface;

 -- R12 MOAC Uptake
TYPE org_id_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
org_id_tab    org_id_type;

TYPE gms_batch_name_type IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
gms_batch_name_tab gms_batch_name_type;

TYPE req_id_TYPE is TABLE OF 	NUMBER(15) INDEX BY BINARY_INTEGER;
req_id_tab req_id_TYPE;

TYPE call_status_TYPE IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
call_status_tab call_status_TYPE;

CURSOR	operating_unit_csr IS
SELECT	DISTINCT org_id
FROM	psp_enc_summary_lines
WHERE	status_code = 'N'
AND	gl_code_combination_id IS NULL
AND	gms_batch_name IS NULL
AND	payroll_action_id = p_payroll_action_id;

BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering TR_TO_GMS_INT');

	l_tie_back_failed:= NULL;
	l_rec_no := 0;
	l_rec_count := 0;

	IF (l_gms_install) THEN
		OPEN transaction_source_cur;
		FETCH transaction_source_cur INTO l_gms_transaction_source;
		CLOSE transaction_source_cur;

		IF (l_gms_transaction_source IS NULL) THEN
			fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
			fnd_message.set_token('ERROR','TRANSACTION SOURCE = GOLDE');
			fnd_message.set_token('PRODUCT','GMS');
			fnd_msg_pub.add;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	 -- R12 MOAC Uptake
	org_id_tab.delete;
	gms_batch_name_tab.delete;
	req_id_tab.delete;
	call_status_tab.delete;

	OPEN operating_unit_csr;
	FETCH operating_unit_csr BULK COLLECT INTO org_id_tab;
	CLOSE operating_unit_csr;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	org_id_tab.COUNT: ' || org_id_tab.COUNT);

	FOR I in 1..org_id_tab.COUNT
	LOOP
		SELECT	TO_CHAR(psp_gms_batch_name_s.NEXTVAL)
		INTO	gms_batch_name_tab(i)
		FROM	DUAL;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	gms_batch_name_tab(' || I || '): ' || gms_batch_name_tab(i));
	END LOOP;


	FORALL I IN 1..org_id_tab.count
	UPDATE	psp_enc_summary_lines pesl
	SET	gms_batch_name = gms_batch_name_tab(i)
	WHERE	status_code = 'N'
	AND	gl_code_combination_id IS NULL
	AND	gms_batch_name IS NULL
	ANd	superceded_line_id IS NULL
	AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl2
				WHERE	pesl2.payroll_action_id = p_payroll_action_id
				AND	pesl2.assignment_id = pesl.assignment_id
				AND	pesl2.time_period_id = pesl.time_period_id
				AND	pesl2.status_code IN ('N', 'R')
				AND	pesl2.superceded_line_id IS NOT NULL)
	AND	payroll_action_id = p_payroll_action_id
	AND     org_id = org_id_tab(i);

	OPEN int_cur;
	FETCH int_cur BULK COLLECT INTO r_interface.txn_interface_id,	r_interface.enc_summary_line_id,
		r_interface.effective_date,		r_interface.time_period_id,
		r_interface.person_id,			r_interface.project_id,
		r_interface.task_id,			r_interface.award_id,
		r_interface.expenditure_type,		r_interface.expenditure_organization_id,
		r_interface.currency_code,		r_interface.quantity,
		r_interface.summary_amount,		r_interface.dr_cr_flag,
		r_interface.attribute2,			r_interface.attribute3,
		r_interface.attribute6,			r_interface.attribute7,
		r_interface.attribute8,			r_interface.attribute9,
		r_interface.attribute10,		r_interface.expenditure_item_id,
		r_interface.exp_org_name,		r_interface.project_number,
		r_interface.operating_unit,		r_interface.task_number,
		r_interface.expenditure_comment,	r_interface.period_name,
		r_interface.end_date,			r_interface.gms_overriding_date,
		r_interface.gms_batch_name,r_interface.unmatched_nve_txn_flag;
	CLOSE int_cur;

/*
	FOR I IN 1..r_interface.txn_interface_id.count
	LOOP
		FOR J IN 1..org_id_tab.count
		LOOP
			IF org_id_tab(J) = r_interface.operating_unit(I) THEN
				r_interface.gms_batch_name(I) := gms_batch_name_tab(J);
				EXIT;
			END IF;
		END LOOP;
	END LOOP;
*/

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_interface.txn_interface_id.COUNT: ' || r_interface.txn_interface_id.COUNT);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Verifying interface records for errors');

	OPEN employee_number_cur;
	FETCH employee_number_cur BULK COLLECT INTO r_person.person_id, r_person.employee_number;
	CLOSE employee_number_cur;

	l_raise_error := FALSE;
	FOR recno IN 1..r_interface.txn_interface_id.COUNT
	LOOP
		FOR emp_recno IN 1..r_person.person_id.COUNT
		LOOP
			IF (r_interface.person_id(recno) = r_person.person_id(emp_recno)) THEN
				r_interface.employee_number(recno) := r_person.employee_number(emp_recno);
				EXIT;
			END IF;
		END LOOP;

		IF r_interface.employee_number(recno) IS NULL THEN
			fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE', 'person_id: ' || r_interface.person_id(recno));
			fnd_message.set_token('TABLE', 'PER_PEOPLE_F');
			fnd_msg_pub.add;
			l_raise_error := TRUE;
		END IF;

		IF r_interface.exp_org_name(recno) IS NULL THEN
			fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE', 'org_id: ' || r_interface.expenditure_organization_id(recno));
			fnd_message.set_token('TABLE', 'HR_ORGANIZATION_UNITS');
			fnd_msg_pub.add;
			l_raise_error := TRUE;
		END IF;

		IF r_interface.operating_unit(recno) IS NULL THEN
			fnd_message.set_name('PSP','PSP_ORG_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE', 'project_id: ' || r_interface.project_id(recno));
			fnd_message.set_token('TABLE', 'PA_PROJECTS_ALL');
			fnd_msg_pub.add;
			l_raise_error := TRUE;
		END IF;

		IF r_interface.project_number(recno) IS NULL THEN
			fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE', 'project_id: ' || r_interface.project_id(recno));
			fnd_message.set_token('TABLE', 'PA_PROJECTS_ALL');
			fnd_msg_pub.add;
			l_raise_error := TRUE;
		END IF;

		IF r_interface.task_number(recno) IS NULL THEN
			fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE', 'task_id: ' || r_interface.task_id(recno));
			fnd_message.set_token('TABLE', 'PA_TASKS');
			fnd_msg_pub.add;
			l_raise_error := TRUE;
		END IF;
	END LOOP;

	IF l_raise_error THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Interface records have errors');
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed interface records for errors');
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Computing PA week ending date(s)');

	FOR recno IN 1..r_interface.txn_interface_id.COUNT
	LOOP
		psp_general.get_gms_effective_date(r_interface.person_id(recno), r_interface.gms_overriding_date(recno));
		-- set the context to single to call pa_utils function
		mo_global.set_policy_context('S', r_interface.operating_unit(recno) );
		r_interface.exp_end_date(recno) := pa_utils.getweekending(r_interface.gms_overriding_date(recno));
	END LOOP;
	-- set the context again to multiple
	mo_global.set_policy_context('M', null);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed computation of PA week ending date(s)');

	FORALL recno IN 1..r_interface.txn_interface_id.COUNT
	UPDATE	psp_enc_summary_lines pesl
	SET	gms_posting_override_date = r_interface.gms_overriding_date(recno)
	WHERE	pesl.enc_summary_line_id = r_interface.enc_summary_line_id(recno)
	AND	TRUNC(r_interface.effective_date(recno)) <> TRUNC(r_interface.gms_overriding_date(recno));

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated GMS Override Date');

	FORALL recno IN 1..r_interface.txn_interface_id.COUNT
	INSERT INTO pa_transaction_interface_all
		(txn_interface_id,				transaction_source,
		batch_name,					expenditure_ending_date,
		employee_number,				organization_name,
		expenditure_item_date,				project_number,
		task_number,					expenditure_type,
		quantity,					raw_cost,
		expenditure_comment,				transaction_status_code,
		orig_transaction_reference,			org_id,
		denom_currency_code,				denom_raw_cost,
		attribute1,					attribute2,
		attribute3,					attribute6,
		attribute7,					attribute8,
		attribute9,					attribute10,
		person_business_group_id,unmatched_negative_txn_flag)
	VALUES	(r_interface.txn_interface_id(recno),		l_gms_transaction_source,
		r_interface.gms_batch_name(recno),		r_interface.exp_end_date(recno),
		r_interface.employee_number(recno),		r_interface.exp_org_name(recno),
		r_interface.gms_overriding_date(recno),		r_interface.project_number(recno),
		r_interface.task_number(recno),			r_interface.expenditure_type(recno),
		1,						r_interface.summary_amount(recno),
		r_interface.expenditure_comment(recno),		'P',
		'E:' || r_interface.enc_summary_line_id(recno),	r_interface.operating_unit(recno),
		g_currency_code,				r_interface.summary_amount(recno),
		NULL,						NULL,
		r_interface.attribute3(recno),			r_interface.attribute6(recno),
		r_interface.attribute7(recno),			r_interface.attribute8(recno),
		r_interface.attribute9(recno),			r_interface.attribute10(recno),
		g_business_group_id,r_interface.unmatched_nve_txn_flag(recno));

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Inserted into pa_transaction_interface_all');

	FOR recno IN 1..r_interface.txn_interface_id.COUNT
	LOOP
		GMS_REC.TXN_INTERFACE_ID		:= r_interface.txn_interface_id(recno);
		GMS_REC.BATCH_NAME			:= r_interface.gms_batch_name(recno);
		GMS_REC.TRANSACTION_SOURCE		:= l_gms_transaction_source;
		GMS_REC.EXPENDITURE_ENDING_DATE		:= r_interface.exp_end_date(recno);
		GMS_REC.EXPENDITURE_ITEM_DATE		:= r_interface.effective_date(recno);
		GMS_REC.PROJECT_NUMBER			:= r_interface.project_number(recno);
		GMS_REC.TASK_NUMBER			:= r_interface.task_number(recno);
		GMS_REC.AWARD_ID			:= r_interface.award_id(recno);
		GMS_REC.EXPENDITURE_TYPE		:= r_interface.expenditure_type(recno);
		GMS_REC.TRANSACTION_STATUS_CODE		:= 'P';
		GMS_REC.ORIG_TRANSACTION_REFERENCE	:= 'E:'|| r_interface.enc_summary_line_id(recno);
		GMS_REC.ORG_ID				:= r_interface.operating_unit(recno);
		GMS_REC.SYSTEM_LINKAGE			:= NULL;
		GMS_REC.USER_TRANSACTION_SOURCE		:= NULL;
		GMS_REC.TRANSACTION_TYPE		:= NULL;
		GMS_REC.BURDENABLE_RAW_COST		:= r_interface.summary_amount(recno);
		GMS_REC.FUNDING_PATTERN_ID		:= NULL;
		GMS_REC.ORIGINAL_ENCUMBRANCE_ITEM_ID	:= r_interface.expenditure_item_id(recno);

		gms_transactions_pub.LOAD_GMS_XFACE_API(gms_rec, l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			fnd_message.set_name('PSP','PSP_GMS_XFACE_FAILED');
			fnd_msg_pub.add;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END LOOP;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Inserted into gms_transaction_interface_all');
	IF r_interface.txn_interface_id.COUNT > 0 THEN

		FOR request_counter IN 1..org_id_tab.count
		LOOP
			-- set the context to single to call submit_request
			mo_global.set_policy_context('S', org_id_tab(request_counter) );
			fnd_request.set_org_id (org_id_tab(request_counter) );

			req_id_tab(request_counter) := fnd_request.submit_request
					('PA',
					'PAXTRTRX',
					NULL,
					NULL,
					FALSE,
					l_gms_transaction_source,
					gms_batch_name_tab(request_counter));

			IF req_id_tab(request_counter) = 0 THEN
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Submission of Transaction Import Failed');
				fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSE
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Submitted Transaction Import');

				OPEN enc_control_id_cur;
				FETCH enc_control_id_cur BULK COLLECT INTO r_enc_controls.enc_control_id;
				CLOSE enc_control_id_cur;

				FORALL I IN 1..r_enc_controls.enc_control_id.COUNT
				UPDATE	psp_enc_controls
				SET	gms_phase = 'Transfer'
				WHERE	enc_control_id = r_enc_controls.enc_control_id(I);

				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated gms_phase to ''Transfer'' in psp_enc_controls SQL%ROWCOUNT: ' || SQL%ROWCOUNT);

				r_enc_controls.enc_control_id.DELETE;
			END IF;
		END LOOP;
       		COMMIT;
		-- set the context again to multiple
		mo_global.set_policy_context('M', null);

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling gather_table_stats for psp_enc_summary_lines');
		fnd_stats.gather_table_stats('PSP', 'PSP_ENC_SUMMARY_LINES');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed gather_table_stats for psp_enc_summary_lines');

		FOR I IN 1..org_id_tab.count
		LOOP
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Waiting for comlpetion of Transaction Import');
       			call_status := fnd_concurrent.wait_for_request(req_id_tab(I), 10, 0, rphase, rstatus, dphase, dstatus, message);

			IF call_status = FALSE then
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Transaction Import failed');
				fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Transaction Import completed');
		END LOOP;
	END IF;

	OPEN gms_batch_name_cur;
	FETCH gms_batch_name_cur BULK COLLECT INTO r_gms_batch.gms_batch_name;
	CLOSE gms_batch_name_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_gms_batch.gms_batch_name.COUNT: ' || r_gms_batch.gms_batch_name.COUNT);

	FOR recno IN 1..r_gms_batch.gms_batch_name.COUNT
	LOOP
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling gms_enc_tie_back for gms_batch_name: ' || r_gms_batch.gms_batch_name(recno));
		gms_enc_tie_back(p_payroll_action_id,
				r_gms_batch.gms_batch_name(recno),
				g_business_group_id,
				g_set_of_books_id,
				l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	gms_enc_tie_back failed for gms_batch_name: ' || r_gms_batch.gms_batch_name(recno));
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	gms_enc_tie_back successful for gms_batch_name: ' || r_gms_batch.gms_batch_name(recno));
	END LOOP;

	FORALL recno IN 1..r_gms_batch.gms_batch_name.COUNT
	UPDATE	psp_enc_summary_lines pesl
	SET	(pesl.expenditure_id, pesl.expenditure_item_id, pesl.expenditure_ending_date,
		pesl.txn_interface_id, pesl.interface_id) =
			(SELECT	ptxn.expenditure_id, ptxn.expenditure_item_id, ptxn.expenditure_ending_date,
				ptxn.txn_interface_id, ptxn.interface_id
			FROM	pa_transaction_interface_all ptxn
			WHERE	ptxn.transaction_source = 'GOLDE'
			AND	ptxn.batch_name = r_gms_batch.gms_batch_name(recno)
			AND	ptxn.orig_transaction_reference = 'E:' || TO_CHAR(pesl.enc_summary_line_id))
	WHERE	pesl.gms_batch_name = r_gms_batch.gms_batch_name(recno);

	FORALL recno IN 1..r_gms_batch.gms_batch_name.COUNT
	DELETE	pa_transaction_interface_all
	WHERE	batch_name = r_gms_batch.gms_batch_name(recno)
	AND	transaction_source = 'GOLDE';

	FORALL recno IN 1..r_gms_batch.gms_batch_name.COUNT
	DELETE	gms_transaction_interface_all
	WHERE	batch_name = r_gms_batch.gms_batch_name(recno)
	AND	transaction_source = 'GOLDE';

	FORALL recno IN 1..r_gms_batch.gms_batch_name.COUNT
	UPDATE	psp_enc_summary_lines
	SET	gms_batch_name = NULL
	WHERE	gms_batch_name = r_gms_batch.gms_batch_name(recno)
	AND	status_code = 'N';

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Set the un-imported summary lines to New status');

	COMMIT;

	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		g_error_api_path := 'TR_TO_GMS_INT:'||g_error_api_path;
		p_return_status := fnd_api.g_ret_sts_unexp_error;

	WHEN RETURN_BACK THEN
		p_return_status := fnd_api.g_ret_sts_success;

	WHEN OTHERS THEN
		g_error_api_path := 'TR_TO_GMS_INT:'||g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','TR_TO_GMS_INT');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END	tr_to_gms_int;
--	End of comment for Create and Update multi thread

--	##########################################################################
--	This procedure ties back all the transactions posted into Oracle Grants Mgmt.
--		with Oracle Labor Distribution where the import is successful.
--	In case of failure the transactions in Oracle Labor Distribution are turned
--		back into their original state.
--	##########################################################################

/*****	Commented for Create and Update multi thread enh.
PROCEDURE gms_enc_tie_back( p_enc_control_id	IN  NUMBER,
			    p_period_end_date   IN  DATE,
                            p_gms_batch_name	IN  VARCHAR2,
                            p_business_group_id IN  NUMBER,
                            p_set_of_books_id   IN  NUMBER,
                            p_mode		IN  VARCHAR2,   -- Included as part of Bug fix #1776606
                            p_return_status     OUT NOCOPY  VARCHAR2) IS

   CURSOR gms_tie_back_success_cur IS
   SELECT enc_summary_line_id,
          dr_cr_flag,
	  summary_amount
   FROM   psp_enc_summary_lines
   WHERE  gms_batch_name = p_gms_batch_name
   and    enc_control_id = p_enc_control_id;

   CURSOR gms_tie_back_reject_cur IS
   SELECT nvl(transaction_rejection_code,'P'),
          orig_transaction_reference,
          transaction_status_code
   FROM   pa_transaction_interface_all
   WHERE  transaction_source = 'GOLDE'
     AND  batch_name = p_gms_batch_name
      AND  orig_transaction_reference IN (SELECT 'E:' || enc_summary_line_id --added subqry for 3953230
                                            FROM  psp_enc_summary_lines pesl
                                           WHERE  pesl.enc_control_id = p_enc_control_id);

   CURSOR assign_susp_ac_cur(P_ENC_LINE_ID	IN	NUMBER) IS
   SELECT pel.rowid,
          pel.encumbrance_date,
          pel.suspense_org_account_id
   FROM   psp_enc_lines pel
   WHERE  pel.enc_summary_line_id = p_enc_line_id
   and    pel.enc_control_id=p_enc_control_id;
-- bUg fix 1671938

-- Get the Organization details ...

   CURSOR get_susp_org_cur(P_ORG_ID	IN	VARCHAR2) IS
   SELECT hou.organization_id, hou.name
     FROM hr_all_organization_units hou, psp_organization_accounts poa
    WHERE hou.organization_id = poa.organization_id
      AND poa.business_group_id = p_business_group_id
      AND poa.set_of_books_id = p_set_of_books_id
      AND poa.organization_account_id = p_org_id;
/ *
   CURSOR get_org_id_cur(P_LINE_ID	IN	NUMBER) IS
   SELECT hou.organization_id, hou.name
   FROM   hr_all_organization_units hou,
  	      per_assignments_f paf,
          psp_enc_lines pel
   WHERE  pel.enc_summary_line_id = p_line_id
   AND    pel.assignment_id = paf.assignment_id
   AND    pel.encumbrance_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    paf.organization_id = hou.organization_id
   AND    pel.encumbrance_date between
		  hou.date_from and nvl(hou.date_to,pel.encumbrance_date);
-- bUg fIx 1671938
* /

   CURSOR get_org_id_cur(P_ROWID IN ROWID) IS
   SELECT hou.organization_id, hou.name
   FROM   hr_all_organization_units hou,
  	      per_assignments_f paf,
          psp_enc_lines pel
   WHERE
-- pel.enc_summary_line_id = p_line_id
   pel.rowid=p_rowid
   AND    pel.assignment_id = paf.assignment_id
   AND    pel.encumbrance_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    paf.organization_id = hou.organization_id
   AND    pel.encumbrance_date between
		  hou.date_from and nvl(hou.date_to,pel.encumbrance_date);



  l_orig_org_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
  l_orig_org_id			number;

-- End of Get org id cursor  Ravindra
/ *   CURSOR assign_susp_ac_cur(P_ENC_SUMMARY_LINE_ID	IN	NUMBER) IS
   SELECT hou.name,
          hou.organization_id,
          pel.rowid,
          pel.assignment_id,
          pel.encumbrance_date,
          pel.suspense_org_account_id
   FROM   hr_organization_units hou,
          per_assignments_f paf,
          psp_enc_lines pel,
   WHERE  pel.enc_summary_line_id = p_enc_summary_line_id
   AND    pel.assignment_id = paf.assignment_id
   AND    pel.encumbrance_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND	  pel.business_group_id = g_business_group_id
   AND	  pel.set_of_books_id = g_set_of_books_id
   AND    paf.organization_id = hou.organization_id;
* /

   CURSOR org_susp_ac_cur(P_ORGANIZATION_ID	IN	NUMBER,
                          P_ENCUMBRANCE_DATE	IN	DATE) IS
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
	  poa.expenditure_organization_id,
	  poa.expenditure_type,
          poa.award_id,
	  poa.task_id
   FROM   psp_organization_accounts poa
   WHERE  poa.organization_id = p_organization_id
   AND	  poa.business_group_id = p_business_group_id
   AND	  poa.set_of_books_id = p_set_of_books_id
   AND    poa.account_type_code = 'S'
--   AND	  poa.award_id is not null   for Bug Fix 1776606
   AND    p_encumbrance_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_encumbrance_date);

-- CURSOR global_susp_ac_cur(P_ENCUMBRANCE_DATE	IN	DATE) IS
   CURSOR global_susp_ac_cur(P_ORGANIZATION_ACCOUNT_ID	IN	NUMBER) IS --BUG 2056877.
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
	  poa.expenditure_organization_id,
	  poa.expenditure_type,
          poa.award_id,
	  poa.task_id
   FROM   psp_organization_accounts poa
   WHERE
    / *    poa.account_type_code = 'G'
     AND  poa.business_group_id = p_business_group_id
     AND  poa.set_of_books_id = p_set_of_books_id
--   AND  poa.award_id is not null    For Bug fix 1776606
     AND    p_encumbrance_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_encumbrance_date); Bug 2056877 * /
          organization_account_id = p_organization_account_id;   --Added for bug 2056877.


   l_organization_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
   l_organization_id		NUMBER(15);
   l_rowid				ROWID;
   l_assignment_id		NUMBER(9);
   l_encumbrance_date		DATE;
   l_suspense_org_account_id  NUMBER(9);

   l_organization_account_id	NUMBER(9);
   l_gl_code_combination_id   NUMBER(15);
   l_project_id			NUMBER(15);
   l_expenditure_organization_id NUMBER(15);
   l_expenditure_type		VARCHAR2(30);
   l_award_id			NUMBER(15);
   l_task_id			NUMBER(15);
   l_cnt_gms_interface		NUMBER;
   l_enc_summary_line_id		NUMBER(10);
   l_gl_project_flag		VARCHAR2(1);
   l_suspense_ac_failed		VARCHAR2(1) := 'N';
   l_suspense_ac_not_found	VARCHAR2(1) := 'N';
   l_susp_ac_found		VARCHAR2(10) := 'TRUE';
   l_summary_amount		NUMBER;
   l_dr_summary_amount		NUMBER := 0;
   l_cr_summary_amount		NUMBER := 0;
   l_dr_cr_flag			VARCHAR2(1);
   l_trx_status_code		VARCHAR2(2); / * Bug 2030232:Gms bug 1961436 * /
   l_trx_reject_code		VARCHAR2(30);
   l_orig_trx_reference		VARCHAR2(30);
   l_enc_ref			VARCHAR2(30);
   l_effective_date		DATE;

   x_susp_failed_org_name	hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
   x_susp_failed_reject_code	VARCHAR2(30);
   x_susp_failed_date		DATE;
   x_susp_nf_org_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
   x_susp_nf_date		DATE;
   l_return_status		VARCHAR2(10);
   l_no_run			NUMBER;
   l_susp_glccid		NUMBER(15);
   l_no_complete		NUMBER;
   l_return_value               VARCHAR2(30);  --Added for bug 2056877.
   no_profile_exists            EXCEPTION;     --Added for bug 2056877.
   no_val_date_matches          EXCEPTION;     --Added for bug 2056877.
   no_global_acct_exists        EXCEPTION;     --Added for bug 2056877.
   l_susp_exception  varchar2(50);       -- added for 2479579


 FUNCTION PROCESS_COMPLETE RETURN VARCHAR2 IS
    l_cnt       NUMBER;
    l_status    VARCHAR2(30);
 begin

   select count(*), transaction_status_code
     into l_cnt, l_status
     from pa_transaction_interface_all
    where transaction_source = 'GOLDE'
      and batch_name = (select distinct gms_batch_name
                          from psp_enc_summary_lines
                         where enc_control_id = p_enc_control_id
                           and gms_batch_name is not null)
      and transaction_status_code in ('P', 'I')
    group by transaction_status_code  ;

   if l_cnt = 0 then
     return 'COMPLETE';
   elsif l_cnt > 0 then
     if l_status = 'P' then

-- -------------------------------------------------------------------------------------------
-- If transaction_status_code = 'P' then the transaction import process did not kick off
-- for some reason. Return 'NOT_RUN' in this case. So cleanup the tables and try to transfer
-- again after summarization in the second pass.
-- -------------------------------------------------------------------------------------------

        delete from pa_transaction_interface_all
         where transaction_source = 'GOLDE'
           and batch_name = p_gms_batch_name;

        delete from gms_transaction_interface_all
         where transaction_source = 'GOLDE'
           and batch_name = p_gms_batch_name;

        delete from psp_enc_summary_lines
         where gms_batch_name = p_gms_batch_name
           and enc_control_id = p_enc_control_id;

        return 'NOT_RUN';

     elsif l_status = 'I' then

-- -------------------------------------------------------------------------------------------
-- If transaction_status_code = 'I' then the transaction import process did not complete
-- the Post Processing extension. So return 'NOT_COMPLETE' in this case. User needs to complete
-- this process by running the transaction import manually and re-start the LD process.
-- -------------------------------------------------------------------------------------------

        return 'NOT_COMPLETE';

     end if;
   end if;

 exception
 when others then
   return 'COMPLETE';
 end PROCESS_COMPLETE;

 BEGIN

   if (PROCESS_COMPLETE not in ('NOT_COMPLETE', 'NOT_RUN')) then

   SELECT count(*)
     INTO l_cnt_gms_interface
     FROM pa_transaction_interface_all
    WHERE transaction_source = 'GOLDE'
      AND batch_name = p_gms_batch_name
      AND transaction_status_code in ('R', 'PI', 'PR', 'PO');

   IF l_cnt_gms_interface > 0 THEN
     / * Start bug#2142865 Added  the code to update the gms_phase * /
     UPDATE psp_enc_controls
     SET gms_phase = 'TieBack'
     WHERE  run_id = g_run_id;
     / * End bug#2142865 * /
     OPEN gms_tie_back_reject_cur;
     LOOP               --loop1 count in pa_tr_int > 1
       FETCH gms_tie_back_reject_cur INTO l_trx_reject_code, l_enc_ref, l_trx_status_code;
       IF gms_tie_back_reject_cur%NOTFOUND THEN
         CLOSE gms_tie_back_reject_cur;
         EXIT;
       END IF;

	l_orig_trx_reference := substr(l_enc_ref, 3);

      IF l_trx_status_code in ('R', 'PI', 'PR', 'PO') THEN
         UPDATE psp_enc_summary_lines
       SET interface_status = l_trx_reject_code, status_code = 'R'
       WHERE enc_summary_line_id = to_number(l_orig_trx_reference);
      ELSIF l_trx_status_code = 'A' THEN
        UPDATE psp_enc_summary_lines
        SET interface_status = l_trx_reject_code, status_code = 'A'
        WHERE enc_summary_line_id = to_number(l_orig_trx_reference);
      -- END IF;

	SELECT summary_amount, dr_cr_flag
	INTO l_summary_amount, l_dr_cr_flag
	FROM psp_enc_summary_lines
	WHERE enc_summary_line_id = to_number(l_orig_trx_reference);

	IF l_dr_cr_flag = 'D' THEN
	 l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
	 ELSIF l_dr_cr_flag = 'C' THEN
	 l_cr_summary_amount := l_cr_summary_amount - l_summary_amount;
	 END IF;

	END IF;

       OPEN assign_susp_ac_cur(l_orig_trx_reference);
       LOOP		--loop2		assign suspense account

         FETCH assign_susp_ac_cur INTO l_rowid, l_encumbrance_date, l_suspense_org_account_id;

         IF assign_susp_ac_cur%NOTFOUND THEN
           CLOSE assign_susp_ac_cur;
           EXIT;
         END IF;

     IF l_trx_status_code = 'A'  THEN

	    UPDATE psp_enc_lines
            SET status_code = 'A'
            WHERE rowid = l_rowid;

            -- move the transferred records to psp_enc_lines_history
           -- Added enc_start_date ,enc_end_date columns for Enh. Enc Redesign Prorata,Bug #2259310
         --dbms_output.put_line('moving rec into enc lines hist');
       	     --insert_into_psp_stout( 'moving rec into enc lines hist');
	-- Introduced DFF columns for bug fix 2908859
         INSERT INTO psp_enc_lines_history
         (enc_line_id,business_group_id,enc_element_type_id,encumbrance_date,
          dr_cr_flag,encumbrance_amount,status_code,enc_line_type,schedule_line_id,org_schedule_id,
	  default_org_account_id,suspense_org_account_id,element_account_id,gl_project_flag,
	  enc_summary_line_id,person_id,assignment_id,award_id,task_id,expenditure_type,
	  expenditure_organization_id,project_id,gl_code_combination_id,time_period_id,payroll_id,
	  set_of_books_id,default_reason_code,suspense_reason_code,enc_control_id,change_flag,last_update_date,
	  last_updated_by,last_update_login,created_by,creation_date,enc_start_date,enc_end_date,
	attribute_category,	attribute1,		attribute2,		attribute3,
	attribute4,		attribute5,		attribute6,		attribute7,
	attribute8,		attribute9,		attribute10)
         SELECT enc_line_id,business_group_id,enc_element_type_id,encumbrance_date,
          dr_cr_flag,encumbrance_amount,status_code,enc_line_type,schedule_line_id,org_schedule_id,
	  default_org_account_id,suspense_org_account_id,element_account_id,gl_project_flag,
	  enc_summary_line_id,person_id,assignment_id,award_id,task_id,expenditure_type,
	  expenditure_organization_id,project_id,gl_code_combination_id,time_period_id,payroll_id,
	  set_of_books_id,default_reason_code,suspense_reason_code,enc_control_id,change_flag,last_update_date,
	  last_updated_by,last_update_login,created_by,creation_date,enc_start_date,enc_end_date,
	attribute_category,	attribute1,		attribute2,		attribute3,
	attribute4,		attribute5,		attribute6,		attribute7,
	attribute8,		attribute9,		attribute10
         FROM psp_enc_lines
         WHERE status_code = 'A'
         AND  enc_summary_line_id = to_number(l_orig_trx_reference)
	 AND  enc_control_id = p_enc_control_id;

         DELETE FROM psp_enc_lines
         WHERE status_code = 'A'
         AND enc_summary_line_id = to_number(l_orig_trx_reference)
	 AND enc_control_id = p_enc_control_id;

/ **************************************************************************************
For Bug 2290051 - Commenting out purging of Interface tables for accepted Summary Lines
--    purge the interface tables for Accepted summary lines

	 DELETE from pa_transaction_interface_all
	  where transaction_source = 'GOLDE'
	    and batch_name = p_gms_batch_name
	    and transaction_status_code = 'A'
	    and orig_transaction_reference =  l_enc_ref;

	 DELETE from gms_transaction_interface_all
	  where transaction_source = 'GOLDE'
	    and batch_name = p_gms_batch_name
	    and transaction_status_code = 'A'
	    and orig_transaction_reference = l_enc_ref;

**************************************************************************************** /

           -- if a suspense a/c failed,update the status of the whole batch and display the error

	  ELSIF l_suspense_org_account_id IS NOT NULL AND l_trx_status_code <> 'A'  THEN

	    OPEN get_susp_org_cur(l_suspense_org_account_id);
	    FETCH get_susp_org_cur into l_organization_id, l_organization_name;
	    CLOSE get_susp_org_cur;

           x_susp_failed_org_name    := l_organization_name;
           x_susp_failed_reject_code := l_trx_reject_code;
           x_susp_failed_date        := l_encumbrance_date;
           l_suspense_ac_failed := 'Y';


   / *Commented for Bug 3914807
	    UPDATE psp_enc_lines
            SET suspense_reason_code = 'ES:' || l_trx_reject_code,
                status_code = 'N'
            WHERE rowid = l_rowid; * /

         ELSE
           l_susp_ac_found := 'TRUE';
	       OPEN get_org_id_cur(l_rowid);
	       FETCH get_org_id_cur into l_orig_org_id, l_orig_org_name;

	   --    IF get_org_id_cur%NOTFOUND then
	           CLOSE get_org_id_cur;
	    --   END IF;

           OPEN org_susp_ac_cur(l_orig_org_id, l_encumbrance_date);
           FETCH org_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id, l_expenditure_organization_id, l_expenditure_type, l_award_id,l_task_id;

           IF org_susp_ac_cur%NOTFOUND  THEN
		/ * Following code is added for bug 2056877 ,Added validation for generic suspense account * /
		l_return_value := psp_general.find_global_suspense(l_encumbrance_date,
							  p_business_group_id,
                                                          p_set_of_books_id,
                                                          l_organization_account_id);
      	  / * --------------------------------------------------------------------
      	   Valid return values are
      	   PROFILE_VAL_DATE_MATCHES       Profile and Value and Date matching 'G'
      	   NO_PROFILE_EXISTS              No Profile
       	   NO_VAL_DATE_MATCHES            Profile and Either Value/date do not
            		                  match with 'G'
   	   NO_GLOBAL_ACCT_EXISTS          No 'G' exists
     	    ---------------------------------------------------------------------- * /
               / *start Added for Bug#2142685. * /
               / * IF  l_return_value <> 'PROFILE_VAL_DATE_MATCHES' THEN
                 IF p_mode='N' THEN
                    enc_batch_end(g_payroll_id,l_return_status);
                 END IF;
               END IF;    2479579 * /
	       / * End Bug#2142865 * /
               IF  l_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
            	--	OPEN global_susp_ac_cur(l_encumbrance_date);
            	 	OPEN global_susp_ac_cur(l_organization_account_id); -- Bug 2056877.
            		FETCH global_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,
	    		l_project_id, l_expenditure_organization_id, l_expenditure_type, l_award_id,l_task_id;
           		    IF global_susp_ac_cur%NOTFOUND THEN
              		     / *	  l_susp_ac_found := 'FALSE';
	            		  l_suspense_ac_not_found := 'Y';
           		          x_susp_nf_org_name := l_orig_org_name;
              		          x_susp_nf_date     := l_encumbrance_date;  Bug 2056877* /
                                   -- added following two lines for 2479579
                                   l_suspense_ac_not_found := 'Y';
                                   l_susp_ac_found := 'NO_G_AC';
           		    END IF;
            		CLOSE global_susp_ac_cur;
                ELSIF l_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
                     -- RAISE no_global_acct_exists; commented this line and added two new lines for 2479579
                     l_suspense_ac_not_found := 'Y';
                     l_susp_ac_found := 'NO_G_AC';
                ELSIF l_return_value = 'NO_VAL_DATE_MATCHES' THEN
                    -- RAISE no_val_date_matches; commented this line and added two new lines for 2479579
                     l_suspense_ac_not_found := 'Y';
                     l_susp_ac_found := 'NO_DT_MCH';
                 ELSIF l_return_value = 'NO_PROFILE_EXISTS' THEN
                    -- RAISE no_profile_exists; commented this line and added two new lines for 2479579
                         l_suspense_ac_not_found := 'Y';
                         l_susp_ac_found := 'NO_PROFL';
               END IF; -- Bug 2056877.
           END IF;
           CLOSE org_susp_ac_cur;


           IF l_susp_ac_found = 'TRUE' THEN

             --CLOSE org_susp_ac_cur;
            IF l_susp_glccid IS NOT NULL THEN
              l_gl_project_flag := 'G';
              l_effective_date := p_period_end_date;
            ELSE
              l_gl_project_flag := 'P';
              psp_general.poeta_effective_date(l_encumbrance_date,
                                   l_project_id,
                                   l_award_id,
                                   l_task_id,
                                   l_effective_date,
                                   l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

            END IF;
	/ * For Bug fix 3194807 * /

	     UPDATE 	psp_enc_lines
	     SET	prev_effective_date = encumbrance_date
	     WHERE	rowid = l_rowid;
	/ * End of Bug fix 3198407 * /

             UPDATE psp_enc_lines
              SET suspense_org_account_id = l_organization_account_id,
                  suspense_reason_code = 'ES:' || l_trx_reject_code,
                  gl_project_flag = l_gl_project_flag,
--		  encumbrance_date = l_encumbrance_date, Commented for Bug 3194807
                  encumbrance_date = l_effective_date,
/ *Commented for Bug 3194807
		  schedule_line_id = null,
		  org_schedule_id = null,
		  default_org_account_id = null,
		  element_account_id = null,
		  gl_code_combination_id = decode(l_gl_project_flag, 'P', null, l_susp_glccid),
		  project_id = decode(l_gl_project_flag, 'P', l_project_id, null),
		  expenditure_organization_id = decode(l_gl_project_flag, 'P', l_expenditure_organization_id, null),
		  expenditure_type = decode(l_gl_project_flag, 'P', l_expenditure_type, null),
		  task_id = decode(l_gl_project_flag, 'P', l_task_id, null),
		  award_id = decode(l_gl_project_flag, 'P', l_award_id, null), * /
                  status_code = 'N'
              WHERE rowid = l_rowid;
            else -- 2479579
              l_susp_exception := l_susp_ac_found;
            END IF;
         END IF;

       END LOOP;	--end loop2 assign suspense account
     END LOOP;		-- end loop1

    UPDATE psp_enc_controls
       SET summ_ogm_dr_amount = l_dr_summary_amount,
           summ_ogm_cr_amount = l_cr_summary_amount
         --gms_phase = 'TieBack' Commented for Bug#2142865 , same moved above
     WHERE enc_control_id = p_enc_control_id;

     --COMMIT;

     IF l_suspense_ac_failed = 'Y' THEN
       g_susp_prob := 'Y';     -- for 2479579
       fnd_message.set_name('PSP','PSP_TR_GMS_SUSP_AC_REJECT');
       fnd_message.set_token('ORG_NAME',x_susp_failed_org_name);
       fnd_message.set_token('PAYROLL_DATE',x_susp_failed_date);
       fnd_message.set_token('ERROR_MSG',x_susp_failed_reject_code);
       fnd_msg_pub.add;


	 / * Added the following for Bug 3194807 * /

        UPDATE  psp_enc_lines
        SET     suspense_org_account_id = NULL,
                suspense_reason_code = NULL,
                gl_project_flag = decode(gl_code_combination_id,NULL,'P','G'),
	 	encumbrance_date = prev_effective_date
        WHERE   suspense_reason_code like 'ES:%'
        AND     enc_summary_line_id
                IN (SELECT enc_summary_line_id
                    FROM   psp_enc_summary_lines
                    WHERE  enc_control_id = p_enc_control_id);


        / * End of code changes for Bug 3194807 * /

     END IF;


       -- uncommented for 2479579, which was earlier commented   for bug # 2142865
     IF l_suspense_ac_not_found = 'Y' THEN
       g_susp_prob := 'Y';     -- for 2479579
       / * commented this message stack for 2479579
       fnd_message.set_name('PSP','PSP_LD_SUSPENSE_AC_NOT_EXIST');
       fnd_message.set_token('ORG_NAME',x_susp_nf_org_name);
       fnd_message.set_token('PAYROLL_DATE',x_susp_nf_date);
       fnd_msg_pub.add; * /
       / * Included the following check as part of Bug fix #1776606 * /
        ---added following if stmnt for 2479579
        IF    l_susp_exception = 'NO_G_AC' then
            RAISE no_global_acct_exists;
        ELSIF l_susp_exception = 'NO_DT_MCH' then
             RAISE no_val_date_matches;
        ELSIF l_susp_exception = 'NO_PROFL' then
             RAISE no_profile_exists;
        END IF;

     END IF;


   ELSIF l_cnt_gms_interface = 0 THEN

     OPEN gms_tie_back_success_cur;
     LOOP
       FETCH gms_tie_back_success_cur INTO l_enc_summary_line_id,
        l_dr_cr_flag,l_summary_amount;

       IF gms_tie_back_success_cur%NOTFOUND THEN
         CLOSE gms_tie_back_success_cur;
         EXIT;
       END IF;
       -- update records in psp_summary_lines as 'A'

       UPDATE psp_enc_summary_lines
       SET status_code = 'A'
       WHERE enc_summary_line_id = l_enc_summary_line_id;

       IF l_dr_cr_flag = 'D' THEN
         l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
       ELSIF l_dr_cr_flag = 'C' THEN
         -- credit is marked as -ve for posting to Oracle Projects
         l_cr_summary_amount := l_cr_summary_amount - l_summary_amount;
       END IF;

	 UPDATE psp_enc_lines
            SET status_code = 'A'
          WHERE enc_summary_line_id = l_enc_summary_line_id
	    AND enc_control_id = p_enc_control_id;

         / * Introduced this cursor for Bug fix 3194807 * /

          UPDATE psp_enc_lines
          SET   (gl_code_combination_id,project_id,task_id,award_id,expenditure_organization_id,expenditure_type)
		= (select NULL,poa.project_id,poa.task_id,poa.award_id,poa.expenditure_organization_id,poa.expenditure_type
                   from   psp_organization_accounts poa
                   where  poa.organization_account_id = suspense_org_account_id
		   and 	  enc_summary_line_id = l_enc_summary_line_id)
	  WHERE enc_summary_line_id= l_enc_summary_line_id
	  AND   suspense_reason_code like 'ES:%';


	/ * End of code Changes for Bug fix  3194807 * /


	  -- move the transferred records to psp_enc_lines_history
	  -- Added enc_start_date ,enc_end_date columns for Enh. Enc Redesign Prorata,Bug #2259310
	-- Introduced DFF columns for bug fix 2908859
         INSERT INTO psp_enc_lines_history
         (enc_line_id,business_group_id,enc_element_type_id,encumbrance_date,
          dr_cr_flag,encumbrance_amount,status_code,enc_line_type,schedule_line_id,org_schedule_id,
	  default_org_account_id,suspense_org_account_id,element_account_id,gl_project_flag,
	  enc_summary_line_id,person_id,assignment_id,award_id,task_id,expenditure_type,
	  expenditure_organization_id,project_id,gl_code_combination_id,time_period_id,payroll_id,
	  set_of_books_id,default_reason_code,suspense_reason_code,enc_control_id,change_flag,last_update_date,
	  last_updated_by,last_update_login,created_by,creation_date,enc_start_date,enc_end_date,
	attribute_category,	attribute1,		attribute2,		attribute3,
	attribute4,		attribute5,		attribute6,		attribute7,
	attribute8,		attribute9,		attribute10)
         SELECT enc_line_id,business_group_id,enc_element_type_id,encumbrance_date,
          dr_cr_flag,encumbrance_amount,status_code,enc_line_type,schedule_line_id,org_schedule_id,
	  default_org_account_id,suspense_org_account_id,element_account_id,gl_project_flag,
	  enc_summary_line_id,person_id,assignment_id,award_id,task_id,expenditure_type,
	  expenditure_organization_id,project_id,gl_code_combination_id,time_period_id,payroll_id,
	  set_of_books_id,default_reason_code,suspense_reason_code,enc_control_id,change_flag,last_update_date,
	  last_updated_by,last_update_login,created_by,creation_date,enc_start_date,enc_end_date,
	attribute_category,	attribute1,		attribute2,		attribute3,
	attribute4,		attribute5,		attribute6,		attribute7,
	attribute8,		attribute9,		attribute10
         FROM psp_enc_lines
         WHERE status_code = 'A'
         AND  enc_summary_line_id = l_enc_summary_line_id
	 AND  enc_control_id = p_enc_control_id;

         DELETE FROM psp_enc_lines
         WHERE status_code = 'A'
         AND enc_summary_line_id = l_enc_summary_line_id
	 AND enc_control_id = p_enc_control_id;

         -- commented For Bug 2290051
	 / * DELETE from pa_transaction_interface_all
	  where transaction_source = 'GOLDE'
	    and batch_name = p_gms_batch_name
	    and transaction_status_code = 'A'
	    and orig_transaction_reference =  'E:' || to_char(l_enc_summary_line_id);

	 DELETE from gms_transaction_interface_all
	  where transaction_source = 'GOLDE'
	    and batch_name = p_gms_batch_name
	    and transaction_status_code = 'A'
	    and orig_transaction_reference =  'E:' || to_char(l_enc_summary_line_id); * /
     END LOOP;

    UPDATE psp_enc_controls
       SET summ_ogm_dr_amount = l_dr_summary_amount,
           summ_ogm_cr_amount = l_cr_summary_amount,
           gms_phase = 'TieBack'
     WHERE enc_control_id = p_enc_control_id;

   END IF;
   END IF; -- IF (PROCESS_COMPLETE)

   p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'GMS_ENC_TIE_BACK:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   / * Added Exceptions for bug 2056877 * /
   WHEN NO_PROFILE_EXISTS THEN
      g_error_api_path := SUBSTR('GMS_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
      fnd_msg_pub.add;
      --p_return_status := fnd_api.g_ret_sts_unexp_error; commented and intro success for 2479579
   p_return_status := fnd_api.g_ret_sts_success;

   WHEN NO_VAL_DATE_MATCHES THEN
      g_error_api_path := SUBSTR('GMS_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_VAL_DATE_MATCHES');
      fnd_message.set_token('ORG_NAME',l_orig_org_name);
      fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
      fnd_msg_pub.add;
      --p_return_status := fnd_api.g_ret_sts_unexp_error;  commented and intro success for 2479579
   p_return_status := fnd_api.g_ret_sts_success;

   WHEN NO_GLOBAL_ACCT_EXISTS THEN
      g_error_api_path := SUBSTR('GMS_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_GLOBAL_ACCT_EXISTS');
      fnd_message.set_token('ORG_NAME',l_orig_org_name);
      fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
      fnd_msg_pub.add;
     -- p_return_status := fnd_api.g_ret_sts_unexp_error;  commented and intro success for 2479579
   p_return_status := fnd_api.g_ret_sts_success;

   WHEN OTHERS THEN
      g_error_api_path := 'GMS_ENC_TIE_BACK:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','GMS_ENC_TIE_BACK');
      p_return_status := fnd_api.g_ret_sts_unexp_error;

END;
	End of comment for Create and Update multi thread enh.	*****/
--	Introduced the following modified gms_enc_tie_back procedure for Create and Update multi thread enh.
PROCEDURE gms_enc_tie_back(	p_payroll_action_id	IN		NUMBER,
				p_gms_batch_name	IN		VARCHAR2,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2) IS
CURSOR	gms_tie_back_success_cur IS
SELECT	enc_control_id,
	enc_summary_line_id,
	dr_cr_flag,
	TO_NUMBER(DECODE(dr_cr_flag, 'C', -summary_amount, summary_amount)) summary_amount
FROM	psp_enc_summary_lines
WHERE	gms_batch_name = p_gms_batch_name;

CURSOR	gms_tie_back_reject_cur IS
SELECT	NVL(transaction_rejection_code,'P'),
	TO_NUMBER(SUBSTR(orig_transaction_reference, 3)),
	transaction_status_code
FROM	pa_transaction_interface_all
WHERE	transaction_source = 'GOLDE'
AND	batch_name = p_gms_batch_name;

CURSOR	assign_susp_ac_cur IS
SELECT	pel.rowid,
	pel.encumbrance_date,
	pel.enc_start_date,
	pel.enc_end_date,
	pel.person_id,
	pel.assignment_id,
	pel.payroll_id,
	pel.enc_element_type_id,
	pel.project_id,
	pel.task_id,
	pel.award_id,
	pel.expenditure_organization_id,
	pel.expenditure_type,
	pel.suspense_org_account_id,
	pesl.interface_status,
	ptp.end_date
FROM	psp_enc_lines pel,
	psp_enc_summary_lines pesl,
	per_time_periods ptp
WHERE	pel.payroll_action_id = p_payroll_action_id
AND	pel.enc_summary_line_id = pesl.enc_summary_line_id
AND	pesl.payroll_action_id = p_payroll_action_id
AND	pesl.status_code = 'R'
AND	pesl.gms_batch_name = p_gms_batch_name
AND	ptp.time_period_id = pel.time_period_id
ORDER BY 5, 6, 7, 8, 9, 10, 11, 12, 3;

CURSOR	get_susp_org_cur(P_ORG_ID	IN	VARCHAR2) IS
SELECT	hou.organization_id, hou.name, poa.gl_code_combination_id
FROM	hr_all_organization_units hou,
	psp_organization_accounts poa
WHERE	hou.organization_id = poa.organization_id
AND	poa.business_group_id = p_business_group_id
AND	poa.set_of_books_id = p_set_of_books_id
AND	poa.organization_account_id = p_org_id;

CURSOR	get_org_id_cur(P_ROWID IN ROWID) IS
SELECT	hou.organization_id, hou.name
FROM	hr_all_organization_units hou,
	per_assignments_f paf,
	psp_enc_lines pel
WHERE	pel.rowid=p_rowid
AND	pel.assignment_id = paf.assignment_id
AND	pel.encumbrance_date BETWEEN paf.effective_start_date AND paf.effective_end_date
AND	paf.organization_id = hou.organization_id
AND	pel.encumbrance_date BETWEEN hou.date_from AND NVL(hou.date_to, pel.encumbrance_date);

CURSOR	org_susp_ac_cur(P_ORGANIZATION_ID	IN	NUMBER,
                          P_ENCUMBRANCE_DATE	IN	DATE) IS
SELECT	poa.organization_account_id,
	poa.gl_code_combination_id,
	poa.project_id,
	poa.expenditure_organization_id,
	poa.expenditure_type,
	poa.award_id,
	poa.task_id
FROM	psp_organization_accounts poa
WHERE	poa.organization_id = p_organization_id
AND	poa.business_group_id = p_business_group_id
AND	poa.set_of_books_id = p_set_of_books_id
AND	poa.account_type_code = 'S'
AND	p_encumbrance_date BETWEEN poa.start_date_active AND NVL(poa.end_date_active, p_encumbrance_date);

CURSOR	global_susp_ac_cur(P_ORGANIZATION_ACCOUNT_ID IN NUMBER) IS
SELECT	poa.organization_account_id,
	poa.gl_code_combination_id,
	poa.project_id,
	poa.expenditure_organization_id,
	poa.expenditure_type,
	poa.award_id,
	poa.task_id
FROM	psp_organization_accounts poa
WHERE	organization_account_id = p_organization_account_id;

CURSOR	txn_interface_count_cur IS
SELECT	COUNT(1)
FROM	pa_transaction_interface_all
WHERE	transaction_source = 'GOLDE'
AND	batch_name = p_gms_batch_name
AND	transaction_status_code in ('R', 'PI', 'PO', 'PR');

CURSOR	get_success_recs_cur IS
SELECT	enc_control_id,
	enc_summary_line_id,
	dr_cr_flag,
	TO_NUMBER(DECODE(dr_cr_flag, 'C', -summary_amount, summary_amount)) summary_amount
FROM	psp_enc_summary_lines
WHERE	gms_batch_name = p_gms_batch_name
AND	status_code = 'A';

l_encumbrance_date				DATE;
l_lines_glccid					NUMBER(15);
l_organization_account_id		NUMBER(9);
l_susp_glccid					NUMBER(15);
l_new_gl_code_combination_id	NUMBER(15);
l_orig_org_name					hr_all_organization_units_tl.name%TYPE;
l_orig_org_id					NUMBER(15);
l_cnt_gl_interface				NUMBER;
l_autopop_status				VARCHAR2(1);
l_gl_project_flag				VARCHAR2(1);
l_suspense_ac_failed			VARCHAR2(1);
l_suspense_ac_not_found			VARCHAR2(1);
l_susp_ac_found					VARCHAR2(10);
l_organization_name				hr_all_organization_units_tl.name%TYPE;
l_organization_id				NUMBER(15);
l_return_value					VARCHAR2(30);
l_autopop_error					VARCHAR2(30);
l_effective_date				DATE;
no_profile_exists				EXCEPTION;
no_val_date_matches				EXCEPTION;
no_global_acct_exists			EXCEPTION;
suspense_autopop_failed			EXCEPTION;
l_susp_exception				VARCHAR2(50);
l_project_id					NUMBER(15);
l_expenditure_organization_id	NUMBER(15);
l_expenditure_type				VARCHAR2(30);
l_new_expenditure_type			VARCHAR2(30);
l_award_id						NUMBER(15);
l_task_id						NUMBER(15);
l_return_status					VARCHAR2(1);
l_cnt_gms_interface				NUMBER;
l_project_number				pa_projects_all.segment1%TYPE;
l_task_number					pa_tasks.task_number%TYPE;
l_award_number					gms_awards_all.award_number%TYPE;
l_exp_org_name					hr_organization_units.name%TYPE;
l_gl_description				VARCHAR2(4000);

CURSOR	project_number_cur IS
SELECT	SEGMENT1
FROM	pa_projects_all
WHERE	project_id = l_project_id;

CURSOR	award_number_cur IS
SELECT	award_number
FROM	gms_awards_all
WHERE	award_id = l_award_id;

CURSOR	task_number_cur Is
SELECT	task_number
FROM	pa_tasks
WHERE	task_id = l_task_id;

CURSOR	exp_org_name_cur IS
SELECT	name
FROM	hr_organization_units
WHERE	organization_id = l_expenditure_organization_id;

TYPE t_rowid IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE t_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_char_300 IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;

TYPE r_tieback_rec IS RECORD
	(enc_summary_line_id	t_number_15,
	enc_control_id		t_number_15,
	reason_code		t_char_300,
	txn_status_code		t_char_300,
	dr_cr_flag		t_char_300,
	summary_amount		t_number);

r_reject_recs	r_tieback_rec;
r_success_recs	r_tieback_rec;

TYPE r_interface_rec IS RECORD
	(status			t_char_300,
	enc_summary_line_id	t_number_15,
	dr_cr_flag		t_char_300,
	summary_amount		t_number,
	enc_control_id		t_number_15);
r_interface	r_interface_rec;

TYPE r_suspense_ac_rec IS RECORD
	(row_id					t_rowid,
	encumbrance_date		t_date,
	enc_start_date			t_date,
	enc_end_date			t_date,
	person_id				t_number_15,
	assignment_id			t_number_15,
	element_type_id			t_number_15,
	payroll_id				t_number_15,
	project_id				t_number_15,
	task_id					t_number_15,
	award_id				t_number_15,
	expenditure_organization_id	t_number_15,
	expenditure_type		t_char_300,
	suspense_org_account_id	t_number_15,
	interface_status		t_char_300,
	end_date				t_date);
r_suspense_ac	r_suspense_ac_rec;

FUNCTION PROCESS_COMPLETE RETURN BOOLEAN IS
l_cnt	NUMBER;
l_status	VARCHAR2(30);

TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE r_superceded_line_rec IS RECORD (superceded_line_id	t_number_15);
r_superceded_lines	r_superceded_line_rec;

CURSOR	transaction_status_cur IS
SELECT	COUNT(*),
	transaction_status_code
FROM	pa_transaction_interface_all
WHERE	transaction_source='GOLDE'
AND	batch_name = p_gms_batch_name
AND	transaction_Status_code in ('P','I')
GROUP BY transaction_status_code;
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering GMS_ENC_TIE_BACK.PROCESS_COMPLETE');

	OPEN transaction_status_cur;
	FETCH transaction_status_cur INTO l_cnt, l_status;
	IF (transaction_status_cur%ROWCOUNT = 0) THEN
		l_cnt := 0;
	END IF;
	CLOSE transaction_status_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_cnt: ' || l_cnt);

	IF l_cnt = 0 THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK.PROCESS_COMPLETE');
		RETURN TRUE;
	ELSIF l_cnt > 0 THEN
		IF l_status = 'P' THEN
			DELETE FROM pa_transaction_interface_all
			WHERE	transaction_source = 'GOLDE'
			AND	batch_name = p_gms_batch_name;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted from pa_trancsaction_interface_all');

			DELETE FROM gms_transaction_interface_all
			WHERE	transaction_source = 'GOLDE'
			AND	batch_name = p_gms_batch_name;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted from gms_trancsaction_interface_all');

			DELETE FROM psp_enc_summary_lines
			WHERE	gms_batch_name = p_gms_batch_name;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted from psp_enc_summary_lines');

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK.PROCESS_COMPLETE');
			RETURN FALSE;
		ELSIF l_status = 'I' THEN
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK.PROCESS_COMPLETE');
			RETURN FALSE;
		END IF;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		RETURN TRUE;
END	PROCESS_COMPLETE;
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering GMS_ENC_TIE_BACK');

	IF (PROCESS_COMPLETE) THEN
		OPEN txn_interface_count_cur;
		FETCH txn_interface_count_cur INTO l_cnt_gms_interface;
		CLOSE txn_interface_count_cur;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_cnt_gms_interface: ' || l_cnt_gms_interface);

		IF l_cnt_gms_interface > 0 THEN
			OPEN gms_tie_back_reject_cur;
			FETCH gms_tie_back_reject_cur BULK COLLECT INTO r_reject_recs.reason_code, r_reject_recs.enc_summary_line_id,
				r_reject_recs.txn_status_code;
			CLOSE gms_tie_back_reject_cur;

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_reject_recs.enc_summary_line_id.COUNT: ' || r_reject_recs.enc_summary_line_id.COUNT);

			FORALL recno IN 1..r_reject_recs.enc_summary_line_id.COUNT
			UPDATE	psp_enc_summary_lines
			SET	interface_status = r_reject_recs.reason_code(recno),
				status_code = 'R'
			WHERE	enc_summary_line_id = r_reject_recs.enc_summary_line_id(recno)
			AND	r_reject_recs.txn_status_code(recno) IN ('R', 'PI', 'PO', 'PR');

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated interface_status with reject reason code in psp_enc_summary_lines');

			FORALL recno IN 1..r_reject_recs.enc_summary_line_id.COUNT
			UPDATE	psp_enc_summary_lines
			SET	interface_status = r_reject_recs.reason_code(recno),
				status_code = 'A'
			WHERE	enc_summary_line_id = r_reject_recs.enc_summary_line_id(recno)
			AND	r_reject_recs.txn_status_code(recno) = 'A';

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated status_code to ''A'' for accepted records in psp_enc_summary_lines');

			OPEN get_success_recs_cur;
			FETCH get_success_recs_cur BULK COLLECT INTO r_success_recs.enc_control_id, r_success_recs.enc_summary_line_id,
				r_success_recs.dr_cr_flag, r_success_recs.summary_amount;
			CLOSE get_success_recs_cur;

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_success_recs.enc_summary_line_id.COUNT: ' || r_success_recs.enc_summary_line_id.COUNT);

			FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
			INSERT INTO psp_enc_lines_history
				(enc_line_id,			business_group_id,	enc_element_type_id,	encumbrance_date,
				dr_cr_flag,			encumbrance_amount,	status_code,		enc_line_type,
				schedule_line_id,		org_schedule_id,	default_org_account_id,	suspense_org_account_id,
				element_account_id,		gl_project_flag,	enc_summary_line_id,	person_id,
				assignment_id,			award_id,		task_id,		expenditure_type,
				expenditure_organization_id,	project_id,		gl_code_combination_id,	time_period_id,
				payroll_id,			set_of_books_id,	default_reason_code,	suspense_reason_code,
				enc_control_id,			change_flag,		last_update_date,	last_updated_by,
				last_update_login,		created_by,		creation_date,		enc_start_date,
				enc_end_date,			attribute_category,	attribute1,		attribute2,
				attribute3,			attribute4,		attribute5,		attribute6,
				attribute7,			attribute8,		attribute9,		attribute10,
				payroll_action_id,	hierarchy_code,	hierarchy_start_date,	hierarchy_end_date,
				orig_gl_code_combination_id,	orig_project_id,	orig_task_id,	orig_award_id,
				orig_expenditure_org_id,		orig_expenditure_type)
			SELECT	enc_line_id,			business_group_id,	enc_element_type_id,	encumbrance_date,
				dr_cr_flag,			encumbrance_amount,	'A',		enc_line_type,
				schedule_line_id,		org_schedule_id,	default_org_account_id,	suspense_org_account_id,
				element_account_id,		gl_project_flag,	enc_summary_line_id,	person_id,
				assignment_id,			award_id,		task_id,		expenditure_type,
				expenditure_organization_id,	project_id,		gl_code_combination_id,	time_period_id,
				payroll_id,			set_of_books_id,	default_reason_code,	suspense_reason_code,
				enc_control_id,			change_flag,		last_update_date,	last_updated_by,
				last_update_login,		created_by,		creation_date,		enc_start_date,
				enc_end_date,			attribute_category,	attribute1,		attribute2,
				attribute3,			attribute4,		attribute5,		attribute6,
				attribute7,			attribute8,		attribute9,		attribute10,
				payroll_action_id,	hierarchy_code,	hierarchy_start_date,	hierarchy_end_date,
				orig_gl_code_combination_id,	orig_project_id,	orig_task_id,	orig_award_id,
				orig_expenditure_org_id,		orig_expenditure_type
			FROM	psp_enc_lines
			WHERE	enc_summary_line_id = r_success_recs.enc_summary_line_id(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Copied successfully summarized and transferred lines into psp_enc_lines_history');

			FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
			DELETE FROM psp_enc_lines
			WHERE	enc_summary_line_id = r_success_recs.enc_summary_line_id(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted lines from psp_enc_lines that are summarized and trasnferred to target systems');

			OPEN assign_susp_ac_cur;
			FETCH assign_susp_ac_cur BULK COLLECT INTO r_suspense_ac.row_id, r_suspense_ac.encumbrance_date,
				r_suspense_ac.enc_start_date, r_suspense_ac.enc_end_date, r_suspense_ac.person_id,
				r_suspense_ac.assignment_id, r_suspense_ac.payroll_id, r_suspense_ac.element_type_id,
				r_suspense_ac.project_id, r_suspense_ac.task_id, r_suspense_ac.award_id,
				r_suspense_ac.expenditure_organization_id, r_suspense_ac.expenditure_type,
				r_suspense_ac.suspense_org_account_id, r_suspense_ac.interface_status,
				r_suspense_ac.end_date;
			CLOSE assign_susp_ac_cur;

			FOR recno IN 1..r_suspense_ac.row_id.COUNT
			LOOP
				IF r_suspense_ac.suspense_org_account_id(recno) IS NOT NULL THEN
					OPEN get_susp_org_cur(r_suspense_ac.suspense_org_account_id(recno));
					FETCH get_susp_org_cur INTO l_organization_id, l_organization_name, l_lines_glccid;
					CLOSE get_susp_org_cur;

					l_suspense_ac_failed	:= 'Y';
					g_susp_prob := 'Y';
					fnd_message.set_name('PSP', 'PSP_TR_GMS_SUSP_AC_REJECT');
					fnd_message.set_token('ORG_NAME', l_organization_name);
					fnd_message.set_token('PAYROLL_DATE', r_suspense_ac.encumbrance_date(recno));
					fnd_message.set_token('ERROR_MSG', r_suspense_ac.interface_status(recno));
					fnd_msg_pub.add;
				ELSE
					l_susp_ac_found := 'TRUE';

					OPEN get_org_id_cur(r_suspense_ac.row_id(recno));
					FETCH get_org_id_cur INTO l_orig_org_id, l_orig_org_name;
					CLOSE get_org_id_cur;

					OPEN org_susp_ac_cur(l_orig_org_id, r_suspense_ac.encumbrance_date(recno));
					FETCH org_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,
						l_expenditure_organization_id, l_expenditure_type, l_award_id, l_task_id;

					IF org_susp_ac_cur%NOTFOUND THEN
						l_return_value := psp_general.find_global_suspense(r_suspense_ac.encumbrance_date(recno),
								p_business_group_id,
								p_set_of_books_id,
								l_organization_account_id);

						IF l_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
							OPEN global_susp_ac_cur(l_organization_account_id);
							FETCH global_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,
								l_expenditure_organization_id, l_expenditure_type, l_award_id, l_task_id;

							IF global_susp_ac_cur%NOTFOUND THEN
								l_encumbrance_date := r_suspense_ac.encumbrance_date(recno);
								l_suspense_ac_not_found := 'Y';
								l_susp_ac_found := 'NO_G_AC';
							END IF;
							CLOSE global_susp_ac_cur;
						ELSIF l_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
							l_encumbrance_date := r_suspense_ac.encumbrance_date(recno);
							l_suspense_ac_not_found := 'Y';
							l_susp_ac_found := 'NO_G_AC';
						ELSIF l_return_value = 'NO_VAL_DATE_MATCHES' THEN
							l_encumbrance_date := r_suspense_ac.encumbrance_date(recno);
							l_suspense_ac_not_found := 'Y';
							l_susp_ac_found := 'NO_DT_MCH';
						ELSIF l_return_value = 'NO_PROFILE_EXISTS' THEN
							l_encumbrance_date := r_suspense_ac.encumbrance_date(recno);
							l_suspense_ac_not_found := 'Y';
							l_susp_ac_found := 'NO_PROFL';
						END IF;
					END IF;
					CLOSE org_susp_ac_cur;

					IF l_susp_ac_found = 'TRUE' THEN
						IF l_susp_glccid IS NOT NULL THEN
							l_gl_project_flag := 'G';
							l_effective_date := r_suspense_ac.end_date(recno);

							IF (g_sa_autopop) THEN
								psp_autopop.main(p_acct_type		=> 'N',
									p_person_id			=> r_suspense_ac.person_id(recno),
									p_assignment_id			=> r_suspense_ac.assignment_id(recno),
									p_element_type_id		=> r_suspense_ac.element_type_id(recno),
									p_project_id			=> l_project_id,
									p_expenditure_organization_id	=> l_expenditure_organization_id,
									p_task_id			=> l_task_id,
									p_award_id			=> l_award_id,
									p_expenditure_type		=> l_expenditure_type,
									p_gl_code_combination_id	=> l_susp_glccid,
									p_payroll_date			=> l_effective_date,
									p_set_of_books_id		=> g_set_of_books_id,
									p_business_group_id		=> g_business_group_id,
									ret_expenditure_type		=> l_new_expenditure_type,
									ret_gl_code_combination_id	=> l_new_gl_code_combination_id,
									retcode				=> l_autopop_status);

								IF (l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
									(l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
									l_susp_exception := 'AUTOPOP';
									l_suspense_ac_not_found := 'Y';
									l_autopop_error := 'AUTO_POP_EXP_ERROR';
									IF (l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
										l_autopop_error := 'AUTO_POP_NO_VALUE';
									END IF;
									l_gl_description := psp_general.get_gl_values(g_set_of_books_id, l_susp_glccid);
									fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_AUTOPOP');
									fnd_message.set_token('START_DATE', l_effective_date);
									fnd_message.set_token('END_DATE', l_effective_date);
									fnd_message.set_token('GL', l_gl_description);
									fnd_message.set_token('AUTOPOP_STATUS', l_autopop_error);
									g_warning_message := fnd_message.get;
									fnd_file.put_line(fnd_file.log, g_warning_message);
								ELSE
									l_susp_glccid := l_new_gl_code_combination_id;
								END IF;
							END IF;
						ELSE
							l_gl_project_flag := 'P';
							psp_general.poeta_effective_date(r_suspense_ac.encumbrance_date(recno),
								l_project_id, l_award_id, l_task_id, l_effective_date,
								l_return_status);
							IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
								RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
							END IF;
							IF (g_sa_autopop) THEN
								psp_autopop.main(p_acct_type		=> 'E',
									p_person_id			=> r_suspense_ac.person_id(recno),
									p_assignment_id			=> r_suspense_ac.assignment_id(recno),
									p_element_type_id		=> r_suspense_ac.element_type_id(recno),
									p_project_id			=> l_project_id,
									p_expenditure_organization_id	=> l_expenditure_organization_id,
									p_task_id			=> l_task_id,
									p_award_id			=> l_award_id,
									p_expenditure_type		=> l_expenditure_type,
									p_gl_code_combination_id	=> l_susp_glccid,
									p_payroll_date			=> l_effective_date,
									p_set_of_books_id		=> g_set_of_books_id,
									p_business_group_id		=> g_business_group_id,
									ret_expenditure_type		=> l_new_expenditure_type,
									ret_gl_code_combination_id	=> l_new_gl_code_combination_id,
									retcode				=> l_autopop_status);

								IF (l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
									(l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
									l_susp_exception := 'AUTOPOP';
									l_suspense_ac_not_found := 'Y';
									l_autopop_error := 'AUTO_POP_EXP_ERROR';
									IF (l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
										l_autopop_error := 'AUTO_POP_NO_VALUE';
									END IF;
									OPEN project_number_cur;
									FETCH project_number_cur INTO l_project_number;
									CLOSE project_number_cur;

									OPEN award_number_cur;
									FETCH award_number_cur INTO l_award_number;
									CLOSE award_number_cur;

									OPEN task_number_cur;
									FETCH task_number_cur INTO l_task_number;
									CLOSE task_number_cur;

									OPEN exp_org_name_cur;
									FETCH exp_org_name_cur INTO l_exp_org_name;
									CLOSE exp_org_name_cur;

									fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_AP_PATEO');
									fnd_message.set_token('START_DATE', l_effective_date);
									fnd_message.set_token('END_DATE', l_effective_date);
									fnd_message.set_token('PJ', l_project_number);
									fnd_message.set_token('TK', l_task_number);
									fnd_message.set_token('AW', l_award_number);
									fnd_message.set_token('EO', l_exp_org_name);
									fnd_message.set_token('ET', l_expenditure_type);
									fnd_message.set_token('AUTOPOP_STATUS', l_autopop_error);
									g_warning_message := fnd_message.get;
									fnd_file.put_line(fnd_file.log, g_warning_message);
								ELSE
									l_expenditure_type := l_new_expenditure_type;
								END IF;
							END IF;
						END IF;

						UPDATE	psp_enc_lines
						SET	prev_effective_date = encumbrance_date,
							prev_enc_end_date = enc_end_date,
							prev_encumbrance_amount = encumbrance_amount,
							orig_gl_code_combination_id = gl_code_combination_id,
							orig_project_id = project_id,
							orig_task_id = task_id,
							orig_award_id = award_id,
							orig_expenditure_org_id = expenditure_organization_id,
							orig_expenditure_type = expenditure_type
						WHERE	rowid = r_suspense_ac.row_id(recno);

						UPDATE	psp_enc_lines
						SET	suspense_org_account_id = l_organization_account_id,
							gl_code_combination_id = l_susp_glccid,
							project_id = l_project_id,
							task_id = l_task_id,
							award_id = l_award_id,
							expenditure_organization_id = l_expenditure_organization_id,
							expenditure_type = l_expenditure_type,
							suspense_reason_code = 'ES:' || r_suspense_ac.interface_status(recno),
							gl_project_flag = l_gl_project_flag,
							encumbrance_date = l_effective_date,
							enc_end_date = LEAST(enc_end_date, g_def_end_date),
							encumbrance_amount = (encumbrance_amount * (psp_general.business_days(enc_start_date, LEAST(enc_end_date, g_def_end_date)) / psp_general.business_days(enc_start_date, enc_end_date))),
							status_code = 'N'
						WHERE	rowid = r_suspense_ac.row_id(recno);

						add_st_warnings(p_assignment_id	=>	r_suspense_ac.assignment_id(recno),
								p_payroll_id		=>	r_suspense_ac.payroll_id(recno),
								p_element_type_id	=>	r_suspense_ac.element_type_id(recno),
								p_start_date		=>	r_suspense_ac.enc_start_date(recno),
								p_end_date			=>	r_suspense_ac.enc_end_date(recno),
								p_effective_date	=>	r_suspense_ac.encumbrance_date(recno),
								p_project_id		=>	r_suspense_ac.project_id(recno),
								p_task_id			=>	r_suspense_ac.task_id(recno),
								p_award_id			=>	r_suspense_ac.award_id(recno),
								p_exp_org_id		=>	r_suspense_ac.expenditure_organization_id(recno),
								p_exp_type			=>	r_suspense_ac.expenditure_type(recno),
								p_error_status		=>	r_suspense_ac.interface_status(recno));
					ELSE
						l_susp_exception := l_susp_ac_found;
					END IF;
				END IF;
			END LOOP;

			IF l_suspense_ac_failed = 'Y' THEN
				UPDATE	psp_enc_lines
				SET	suspense_org_account_id = NULL,
					gl_code_combination_id = orig_gl_code_combination_id,
					project_id = orig_project_id,
					task_id = orig_task_id,
					award_id = orig_award_id,
					expenditure_organization_id = orig_expenditure_org_id,
					expenditure_type = orig_expenditure_type,
					gl_project_flag = decode(orig_gl_code_combination_id,NULL,'P','G'),
					encumbrance_date = prev_effective_date,
					enc_end_date = NVL(prev_enc_end_date, enc_end_date),
					encumbrance_amount = NVL(prev_encumbrance_amount, encumbrance_amount)
				WHERE	suspense_reason_code like 'ES:%'
				AND	enc_summary_line_id IN	(SELECT	enc_summary_line_id
								FROM	psp_enc_summary_lines pesl
								WHERE	pesl.payroll_action_id = p_payroll_action_id
								AND	pesl.gms_batch_name = p_gms_batch_name
								AND	status_code = 'R');
				UPDATE	psp_enc_lines
				SET	orig_gl_code_combination_id = NULL,
					orig_project_id = NULL,
					orig_task_id = NULL,
					orig_award_id = NULL,
					orig_expenditure_org_id = NULL,
					orig_expenditure_type = NULL,
					suspense_reason_code = NULL,
					prev_enc_end_date = NULL,
					prev_encumbrance_amount = NULL
				WHERE	suspense_reason_code like 'ES:%'
				AND	enc_summary_line_id IN	(SELECT	enc_summary_line_id
								FROM	psp_enc_summary_lines pesl
								WHERE	pesl.payroll_action_id = p_payroll_action_id
								AND	pesl.gms_batch_name = p_gms_batch_name
								AND	status_code = 'R');
			END IF;

			IF l_suspense_ac_not_found = 'Y' THEN
				g_susp_prob := 'Y';
				IF l_susp_exception = 'NO_G_AC' THEN
					RAISE no_global_acct_exists;
				ELSIF l_susp_exception = 'NO_DT_MCH' THEN
					RAISE no_val_date_matches;
				ELSIF l_susp_exception = 'NO_PROFL' THEN
					RAISE no_profile_exists;
				ELSIF l_susp_exception = 'AUTOPOP' THEN
					RAISE suspense_autopop_failed;
				END IF;
			END IF;

			FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
			UPDATE	psp_enc_controls pec
			SET	summ_ogm_dr_amount = NVL(pec.summ_ogm_dr_amount, 0) + DECODE(r_success_recs.dr_cr_flag(recno), 'D', r_success_recs.summary_amount(recno), 0),
				summ_ogm_cr_amount = NVL(pec.summ_ogm_cr_amount, 0) + DECODE(r_success_recs.dr_cr_flag(recno), 'C', r_success_recs.summary_amount(recno), 0)
			WHERE	enc_control_id = r_success_recs.enc_control_id(recno);

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Update summ_ogm_cr_amount, summ_ogm_dr_amount in psp_enc_controls');

			r_reject_recs.enc_summary_line_id.DELETE;
			r_reject_recs.enc_control_id.DELETE;
			r_reject_recs.reason_code.DELETE;
			r_reject_recs.txn_status_code.DELETE;
			r_success_recs.enc_summary_line_id.DELETE;
			r_success_recs.enc_control_id.DELETE;
			r_success_recs.reason_code.DELETE;
			r_success_recs.txn_status_code.DELETE;
		ELSIF l_cnt_gms_interface = 0 THEN
			OPEN gms_tie_back_success_cur;
			FETCH gms_tie_back_success_cur BULK COLLECT INTO r_success_recs.enc_control_id, r_success_recs.enc_summary_line_id,
				r_success_recs.dr_cr_flag, r_success_recs.summary_amount;
			CLOSE gms_tie_back_success_cur;

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_success_recs.enc_summary_line_id.COUNT: ' || r_success_recs.enc_summary_line_id.COUNT);

			FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
			UPDATE	psp_enc_summary_lines
			SET	status_code = 'A'
			WHERE	enc_summary_line_id = r_success_recs.enc_summary_line_id(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated status_code to ''A'' in psp_enc_summary_lines');

			FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
			INSERT INTO psp_enc_lines_history
				(enc_line_id,			business_group_id,	enc_element_type_id,	encumbrance_date,
				dr_cr_flag,			encumbrance_amount,	status_code,		enc_line_type,
				schedule_line_id,		org_schedule_id,	default_org_account_id,	suspense_org_account_id,
				element_account_id,		gl_project_flag,	enc_summary_line_id,	person_id,
				assignment_id,			award_id,		task_id,		expenditure_type,
				expenditure_organization_id,	project_id,		gl_code_combination_id,	time_period_id,
				payroll_id,			set_of_books_id,	default_reason_code,	suspense_reason_code,
				enc_control_id,			change_flag,		last_update_date,	last_updated_by,
				last_update_login,		created_by,		creation_date,		enc_start_date,
				enc_end_date,			attribute_category,	attribute1,		attribute2,
				attribute3,			attribute4,		attribute5,		attribute6,
				attribute7,			attribute8,		attribute9,		attribute10,
				payroll_action_id,	hierarchy_code,	hierarchy_start_date,	hierarchy_end_date)
			SELECT	enc_line_id,			business_group_id,	enc_element_type_id,	encumbrance_date,
				dr_cr_flag,			encumbrance_amount,	'A',		enc_line_type,
				schedule_line_id,		org_schedule_id,	default_org_account_id,	suspense_org_account_id,
				element_account_id,		gl_project_flag,	enc_summary_line_id,	person_id,
				assignment_id,			award_id,		task_id,		expenditure_type,
				expenditure_organization_id,	project_id,		gl_code_combination_id,	time_period_id,
				payroll_id,			set_of_books_id,	default_reason_code,	suspense_reason_code,
				enc_control_id,			change_flag,		last_update_date,	last_updated_by,
				last_update_login,		created_by,		creation_date,		enc_start_date,
				enc_end_date,			attribute_category,	attribute1,		attribute2,
				attribute3,			attribute4,		attribute5,		attribute6,
				attribute7,			attribute8,		attribute9,		attribute10,
				payroll_action_id,	hierarchy_code,	hierarchy_start_date,	hierarchy_end_date
			FROM	psp_enc_lines
			WHERE	enc_summary_line_id = r_success_recs.enc_summary_line_id(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Copied successfully summarized and transferred lines into psp_enc_lines_history');

			FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
			DELETE FROM psp_enc_lines
			WHERE	enc_summary_line_id = r_success_recs.enc_summary_line_id(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted lines from psp_enc_lines that are summarized and trasnferred to target systems');

			FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
			UPDATE	psp_enc_controls pec
			SET	gms_phase = 'TieBack',
				summ_ogm_dr_amount = NVL(pec.summ_ogm_dr_amount, 0) + DECODE(r_success_recs.dr_cr_flag(recno), 'D', r_success_recs.summary_amount(recno), 0),
				summ_ogm_cr_amount = NVL(pec.summ_ogm_cr_amount, 0) + DECODE(r_success_recs.dr_cr_flag(recno), 'C', r_success_recs.summary_amount(recno), 0)
			WHERE	enc_control_id = r_success_recs.enc_control_id(recno);

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated summ_ogm_cr_amount, summ_ogm_dr_amount, gms_phase in psp_enc_controls');

			r_success_recs.enc_summary_line_id.DELETE;
			r_success_recs.enc_control_id.DELETE;
			r_success_recs.reason_code.DELETE;
			r_success_recs.txn_status_code.DELETE;
		END IF;
	ELSE
		g_process_complete := FALSE;
	END IF;

	p_return_status := fnd_api.g_ret_sts_success;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK');
EXCEPTION
	WHEN NO_PROFILE_EXISTS THEN
		g_error_api_path := SUBSTR('GMS_ENC_TIE_BACK:'||g_error_api_path,1,230);
		fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
		fnd_msg_pub.add;
		p_return_status := fnd_api.g_ret_sts_success;
	WHEN NO_VAL_DATE_MATCHES THEN
		g_error_api_path := SUBSTR('GMS_ENC_TIE_BACK:'||g_error_api_path,1,230);
		fnd_message.set_name('PSP','PSP_NO_VAL_DATE_MATCHES');
		fnd_message.set_token('ORG_NAME',l_orig_org_name);
		fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
		fnd_msg_pub.add;
		p_return_status := fnd_api.g_ret_sts_success;
	WHEN NO_GLOBAL_ACCT_EXISTS THEN
		g_error_api_path := SUBSTR('GMS_ENC_TIE_BACK:'||g_error_api_path,1,230);
		fnd_message.set_name('PSP','PSP_NO_GLOBAL_ACCT_EXISTS');
		fnd_message.set_token('ORG_NAME',l_orig_org_name);
		fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
		fnd_msg_pub.add;
		p_return_status := fnd_api.g_ret_sts_success;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		g_error_api_path := 'GMS_ENC_TIE_BACK:'||g_error_api_path;
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK');
	WHEN OTHERS THEN
		g_error_api_path := 'GMS_ENC_TIE_BACK:'||g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','GMS_ENC_TIE_BACK');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK');
END	gms_enc_tie_back;
--	End of changes for Create and Update multi thread enh.

PROCEDURE create_sum_lines	(p_payroll_action_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2) IS
l_last_updated_by	NUMBER(15);
l_last_update_login	NUMBER(15);

CURSOR	sum_lines_cur IS
SELECT	pel.enc_control_id,
	pel.time_period_id,
	pel.person_id,
	pel.assignment_id,
	pel.payroll_id,
	pel.encumbrance_date,
	pel.gl_code_combination_id,
	pel.project_id,
	pel.task_id,
	pel.award_id,
	pel.expenditure_type,
	pel.expenditure_organization_id,
	SUM(pel.encumbrance_amount),
	pel.dr_cr_flag,
	pel.gl_project_flag,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute_category, NULL) attribute_category,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute10, NULL) attribute10,
	pa.org_id
FROM	PSP_ENC_LINES pel,
	pa_projects_all pa
WHERE 	pel.ENCUMBRANCE_AMOUNT <> 0
AND	pel.payroll_action_id = p_payroll_action_id
AND	(g_suspense_failed = 'TRUE' OR pel.suspense_reason_code LIKE 'ES:%')
AND	(g_suspense_failed = 'TRUE' OR enc_start_date <= g_def_end_date)
AND	pa.project_id (+) = pel.project_id
GROUP BY	pel.enc_control_id,
	pel.time_period_id,
	pel.person_id,
	pel.assignment_id,
	pel.payroll_id,
	pel.encumbrance_date,
	pel.gl_code_combination_id,
	pel.project_id,
	pel.task_id,
	pel.award_id,
	pel.expenditure_type,
	pel.expenditure_organization_id,
	pel.dr_cr_flag,
	pel.gl_project_flag,
	DECODE(g_dff_grouping_option, 'Y', pel.attribute_category, NULL),
	DECODE(g_dff_grouping_option, 'Y', pel.attribute1, NULL),
	DECODE(g_dff_grouping_option, 'Y', pel.attribute2, NULL),
	DECODE(g_dff_grouping_option, 'Y', pel.attribute3, NULL),
	DECODE(g_dff_grouping_option, 'Y', pel.attribute4, NULL),
	DECODE(g_dff_grouping_option, 'Y', pel.attribute5, NULL),
	DECODE(g_dff_grouping_option, 'Y', pel.attribute6, NULL),
	DECODE(g_dff_grouping_option, 'Y', pel.attribute7, NULL),
	DECODE(g_dff_grouping_option, 'Y', pel.attribute8, NULL),
	DECODE(g_dff_grouping_option, 'Y', pel.attribute9, NULL),
	DECODE(g_dff_grouping_option, 'Y', pel.attribute10, NULL),
	pa.org_id;

TYPE sum_lines_rec is RECORD
	(enc_summary_line_id		t_num_15_type,
	enc_control_id			t_num_15_type,
	time_period_id			t_num_15_type,
	person_id			t_num_15_type,
	assignment_id			t_num_15_type,
	payroll_id			t_num_15_type,
	effective_date			t_date_type,
	gl_code_combination_id		t_num_15_type,
	project_id			t_num_15_type,
	task_id				t_num_15_type,
	award_id			t_num_15_type,
	expenditure_organization_id	t_num_15_type,
	expenditure_type		t_varchar_50_type,
	summary_amount			t_num_10d2_type,
	dr_cr_flag			t_varchar_50_type,
	gl_project_flag			t_varchar_50_type,
	attribute_category		t_varchar_50_type,
	attribute1			t_varchar_150_type,
	attribute2			t_varchar_150_type,
	attribute3			t_varchar_150_type,
	attribute4			t_varchar_150_type,
	attribute5			t_varchar_150_type,
	attribute6			t_varchar_150_type,
	attribute7			t_varchar_150_type,
	attribute8			t_varchar_150_type,
	attribute9			t_varchar_150_type,
	attribute10			t_varchar_150_type,
	org_id				t_num_15_type);
t_sum_lines		sum_lines_rec;
BEGIN
	l_last_updated_by := fnd_global.user_id;
	l_last_update_login := fnd_global.login_id;

	OPEN sum_lines_cur;
	FETCH sum_lines_cur BULK COLLECT INTO t_sum_lines.enc_control_id,
		t_sum_lines.time_period_id,			t_sum_lines.person_id,
		t_sum_lines.assignment_id,			t_sum_lines.payroll_id,
		t_sum_lines.effective_date,			t_sum_lines.gl_code_combination_id,
		t_sum_lines.project_id,				t_sum_lines.task_id,
		t_sum_lines.award_id,				t_sum_lines.expenditure_type,
		t_sum_lines.expenditure_organization_id,	t_sum_lines.summary_amount,
		t_sum_lines.dr_cr_flag,				t_sum_lines.gl_project_flag,
		t_sum_lines.attribute_category,			t_sum_lines.attribute1,
		t_sum_lines.attribute2,				t_sum_lines.attribute3,
		t_sum_lines.attribute4,				t_sum_lines.attribute5,
		t_sum_lines.attribute6,				t_sum_lines.attribute7,
		t_sum_lines.attribute8,				t_sum_lines.attribute9,
		t_sum_lines.attribute10,			t_sum_lines.org_id;
	CLOSE sum_lines_cur;

	FOR recno IN 1..t_sum_lines.enc_control_id.COUNT
	LOOP
		SELECT psp_enc_summary_lines_s.NEXTVAL INTO t_sum_lines.enc_summary_line_id(recno) FROM DUAL;
	END LOOP;

	FORALL recno IN 1..t_sum_lines.enc_control_id.COUNT
	INSERT INTO psp_enc_summary_lines
		(enc_summary_line_id,		business_group_id,	enc_control_id,
		time_period_id,			person_id,		assignment_id,
		effective_date,			set_of_books_id,	gl_code_combination_id,
		project_id,			task_id,		award_id,
		expenditure_organization_id,	expenditure_type,	summary_amount,
		dr_cr_flag,			status_code,		payroll_id,
		gl_project_flag,
		attribute_category,		attribute1,		attribute2,
		attribute3,			attribute4,		attribute5,
		attribute6,			attribute7,		attribute8,
		attribute9,			attribute10,		org_id,
		payroll_action_id,		last_update_date,	last_updated_by,
		last_update_login,		created_by,		creation_date)
	VALUES	(t_sum_lines.enc_summary_line_id(recno),	g_business_group_id,
		t_sum_lines.enc_control_id(recno),		t_sum_lines.time_period_id(recno),
		t_sum_lines.person_id(recno),			t_sum_lines.assignment_id(recno),
		t_sum_lines.effective_date(recno),		g_set_of_books_id,
		t_sum_lines.gl_code_combination_id(recno),	t_sum_lines.project_id(recno),
		t_sum_lines.task_id(recno),			t_sum_lines.award_id(recno),
		t_sum_lines.expenditure_organization_id(recno),	t_sum_lines.expenditure_type(recno),
		t_sum_lines.summary_amount(recno),		t_sum_lines.dr_cr_flag(recno),
		'N',		t_sum_lines.payroll_id(recno),	t_sum_lines.gl_project_flag(recno),
		t_sum_lines.attribute_category(recno),		t_sum_lines.attribute1(recno),
		t_sum_lines.attribute2(recno),			t_sum_lines.attribute3(recno),
		t_sum_lines.attribute4(recno),			t_sum_lines.attribute5(recno),
		t_sum_lines.attribute6(recno),			t_sum_lines.attribute7(recno),
		t_sum_lines.attribute8(recno),			t_sum_lines.attribute9(recno),
		t_sum_lines.attribute10(recno),			t_sum_lines.org_id(recno),
		p_payroll_action_id,				SYSDATE,
		l_last_updated_by,				l_last_update_login,
		l_last_updated_by,				SYSDATE);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	No of Summary lines created (t_sum_lines.enc_control_id.COUNT): ' || t_sum_lines.enc_control_id.COUNT);

	IF (g_dff_grouping_option = 'Y') THEN
		FORALL recno IN 1..t_sum_lines.enc_summary_line_id.COUNT
		UPDATE	psp_enc_lines pel
		SET	enc_summary_line_id =	t_sum_lines.enc_summary_line_id(recno)
		WHERE	payroll_action_id = p_payroll_action_id
		AND	pel.enc_control_id = t_sum_lines.enc_control_id(recno)
		AND	pel.time_period_id = t_sum_lines.time_period_id(recno)
		AND	pel.person_id = t_sum_lines.person_id(recno)
		AND	pel.encumbrance_date = t_sum_lines.effective_date(recno)
		AND	NVL(pel.gl_code_combination_id, -99) = NVL(t_sum_lines.gl_code_combination_id(recno), -99)
		AND	NVL(pel.project_id, -99) = NVL(t_sum_lines.project_id(recno), -99)
		AND	NVL(pel.task_id, -99) = NVL(t_sum_lines.task_id(recno), -99)
		AND	NVL(pel.award_id, -99) = NVL(t_sum_lines.award_id(recno), -99)
		AND	NVL(pel.expenditure_type, 'NULL') = NVL(t_sum_lines.expenditure_type(recno), 'NULL')
		AND	NVL(pel.expenditure_organization_id, -99) = NVL(t_sum_lines.expenditure_organization_id(recno), -99)
		AND	pel.dr_cr_flag = t_sum_lines.dr_cr_flag(recno)
		AND	pel.gl_project_flag = t_sum_lines.gl_project_flag(recno)
		AND	NVL(pel.attribute_category, 'NULL') = NVL(t_sum_lines.attribute_category(recno), 'NULL')
		AND	NVL(pel.attribute1, 'NULL') = NVL(t_sum_lines.attribute1(recno), 'NULL')
		AND	NVL(pel.attribute2, 'NULL') = NVL(t_sum_lines.attribute2(recno), 'NULL')
		AND	NVL(pel.attribute3, 'NULL') = NVL(t_sum_lines.attribute3(recno), 'NULL')
		AND	NVL(pel.attribute4, 'NULL') = NVL(t_sum_lines.attribute4(recno), 'NULL')
		AND	NVL(pel.attribute5, 'NULL') = NVL(t_sum_lines.attribute5(recno), 'NULL')
		AND	NVL(pel.attribute6, 'NULL') = NVL(t_sum_lines.attribute6(recno), 'NULL')
		AND	NVL(pel.attribute7, 'NULL') = NVL(t_sum_lines.attribute7(recno), 'NULL')
		AND	NVL(pel.attribute8, 'NULL') = NVL(t_sum_lines.attribute8(recno), 'NULL')
		AND	NVL(pel.attribute9, 'NULL') = NVL(t_sum_lines.attribute9(recno), 'NULL')
		AND	NVL(pel.attribute10, 'NULL') = NVL(t_sum_lines.attribute10(recno), 'NULL');
	ELSE
		FORALL recno IN 1..t_sum_lines.enc_summary_line_id.COUNT
		UPDATE	psp_enc_lines pel
		SET	enc_summary_line_id =	t_sum_lines.enc_summary_line_id(recno)
		WHERE	payroll_action_id = p_payroll_action_id
		AND	pel.enc_control_id = t_sum_lines.enc_control_id(recno)
		AND	pel.time_period_id = t_sum_lines.time_period_id(recno)
		AND	pel.person_id = t_sum_lines.person_id(recno)
		AND	pel.encumbrance_date = t_sum_lines.effective_date(recno)
		AND	NVL(pel.gl_code_combination_id, -99) = NVL(t_sum_lines.gl_code_combination_id(recno), -99)
		AND	NVL(pel.project_id, -99) = NVL(t_sum_lines.project_id(recno), -99)
		AND	NVL(pel.task_id, -99) = NVL(t_sum_lines.task_id(recno), -99)
		AND	NVL(pel.award_id, -99) = NVL(t_sum_lines.award_id(recno), -99)
		AND	NVL(pel.expenditure_type, 'NULL') = NVL(t_sum_lines.expenditure_type(recno), 'NULL')
		AND	NVL(pel.expenditure_organization_id, -99) = NVL(t_sum_lines.expenditure_organization_id(recno), -99)
		AND	pel.dr_cr_flag = t_sum_lines.dr_cr_flag(recno)
		AND	pel.gl_project_flag = t_sum_lines.gl_project_flag(recno);
	END IF;
	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := SUBSTR('CREATE_SUM_LINES:' || g_error_api_path,1,230);
		fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN', 'CREATE_SUM_LINES');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END create_sum_lines;

PROCEDURE update_hierarchy_dates (p_payroll_action_id	IN	NUMBER,
					p_return_status		OUT NOCOPY	VARCHAR2) IS
CURSOR	hierarchy_dates_cur (p_assignment_id	IN	NUMBER,
							p_payroll_id		IN	NUMBER) IS
SELECT	DISTINCT enc_element_type_id,
	hierarchy_code,
	NVL(gl_code_combination_id, -99),
	NVL(project_id, -99),
	NVL(task_id, -99),
	NVL(award_id, -99),
	NVL(expenditure_organization_id, -99),
	NVL(expenditure_type, '-99'),
	enc_start_date,
	enc_end_date
FROM	psp_enc_lines_history pelh
WHERE	change_flag = 'N'
AND	assignment_id = p_assignment_id
AND	payroll_id = p_payroll_id
ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

l_nlines_counter	NUMBER(15);
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering UPDATE_HIERARCHY_DATES');
	l_nlines_counter := 0;

	FOR asg_no IN 1..l_asgs.payroll_id.COUNT
	LOOP
		UPDATE	psp_enc_lines_history pelh
		SET	change_flag = 'N'
		WHERE	EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl
				WHERE	pesl.enc_summary_line_id = pelh.enc_summary_line_id
				AND	status_code = 'A')
		AND	assignment_id = l_asgs.assignment_id(asg_no)
		AND	payroll_id = l_asgs.payroll_id(asg_no);

		UPDATE	psp_enc_lines_history pelh
		SET	hierarchy_code = 'SA'
		WHERE	change_flag = 'N'
		AND	hierarchy_code <> 'SA'
		AND	suspense_org_account_id IS NOT NULL
		AND	assignment_id = l_asgs.assignment_id(asg_no)
		AND	payroll_id = l_asgs.payroll_id(asg_no);

		OPEN hierarchy_dates_cur(l_asgs.assignment_id(asg_no),
					l_asgs.payroll_id(asg_no));
		FETCH hierarchy_dates_cur BULK COLLECT INTO t_enc_lines.element_type_id,
			t_enc_lines.hierarchy_code,	t_enc_lines.gl_ccid,	t_enc_lines.project_id,
			t_enc_lines.task_id,		t_enc_lines.award_id,	t_enc_lines.exp_org_id,
			t_enc_lines.exp_type,		t_enc_lines.enc_start_date, t_enc_lines.enc_end_date;
		CLOSE hierarchy_dates_cur;

		IF (t_enc_lines.element_type_id.COUNT > 0) THEN
			l_nlines_counter := l_nlines_counter + 1;
			t_enc_nlines.assignment_id(l_nlines_counter) := l_asgs.assignment_id(asg_no);
			t_enc_nlines.payroll_id(l_nlines_counter) := l_asgs.payroll_id(asg_no);
			t_enc_nlines.element_type_id(l_nlines_counter) := t_enc_lines.element_type_id(1);
			t_enc_nlines.hierarchy_code(l_nlines_counter) := t_enc_lines.hierarchy_code(1);
			t_enc_nlines.gl_ccid(l_nlines_counter) := t_enc_lines.gl_ccid(1);
			t_enc_nlines.project_id(l_nlines_counter) := t_enc_lines.project_id(1);
			t_enc_nlines.task_id(l_nlines_counter) := t_enc_lines.task_id(1);
			t_enc_nlines.award_id(l_nlines_counter) := t_enc_lines.award_id(1);
			t_enc_nlines.exp_org_id(l_nlines_counter) := t_enc_lines.exp_org_id(1);
			t_enc_nlines.exp_type(l_nlines_counter) := t_enc_lines.exp_type(1);
			t_enc_nlines.enc_start_date(l_nlines_counter) := t_enc_lines.enc_start_date(1);
			t_enc_nlines.enc_end_date(l_nlines_counter) := t_enc_lines.enc_end_date(1);
			FOR recno IN 2..t_enc_lines.element_type_id.COUNT
			LOOP
				IF (t_enc_lines.element_type_id(recno) = t_enc_lines.element_type_id(recno-1) AND
					t_enc_lines.hierarchy_code(recno) = t_enc_lines.hierarchy_code(recno-1) AND
					t_enc_lines.gl_ccid(recno) = t_enc_lines.gl_ccid(recno-1) AND
					t_enc_lines.project_id(recno) = t_enc_lines.project_id(recno-1) AND
					t_enc_lines.task_id(recno) = t_enc_lines.task_id(recno-1) AND
					t_enc_lines.award_id(recno) = t_enc_lines.award_id(recno-1) AND
					t_enc_lines.exp_org_id(recno) = t_enc_lines.exp_org_id(recno-1) AND
					t_enc_lines.exp_type(recno) = t_enc_lines.exp_type(recno-1) AND
					t_enc_lines.enc_start_date(recno) -1 <= t_enc_lines.enc_end_date(recno-1)) THEN
					t_enc_nlines.enc_end_date(l_nlines_counter) := GREATEST(t_enc_lines.enc_end_date(recno), t_enc_lines.enc_end_date(recno-1));
				ELSE
					l_nlines_counter := l_nlines_counter + 1;
					t_enc_nlines.assignment_id(l_nlines_counter) := l_asgs.assignment_id(asg_no);
					t_enc_nlines.payroll_id(l_nlines_counter) := l_asgs.payroll_id(asg_no);
					t_enc_nlines.element_type_id(l_nlines_counter) := t_enc_lines.element_type_id(recno);
					t_enc_nlines.hierarchy_code(l_nlines_counter) := t_enc_lines.hierarchy_code(recno);
					t_enc_nlines.gl_ccid(l_nlines_counter) := t_enc_lines.gl_ccid(recno);
					t_enc_nlines.project_id(l_nlines_counter) := t_enc_lines.project_id(recno);
					t_enc_nlines.task_id(l_nlines_counter) := t_enc_lines.task_id(recno);
					t_enc_nlines.award_id(l_nlines_counter) := t_enc_lines.award_id(recno);
					t_enc_nlines.exp_org_id(l_nlines_counter) := t_enc_lines.exp_org_id(recno);
					t_enc_nlines.exp_type(l_nlines_counter) := t_enc_lines.exp_type(recno);
					t_enc_nlines.enc_start_date(l_nlines_counter) := t_enc_lines.enc_start_date(recno);
					t_enc_nlines.enc_end_date(l_nlines_counter) := t_enc_lines.enc_end_date(recno);
				END IF;
			END LOOP;
		END IF;

		t_enc_lines.assignment_id.DELETE;
		t_enc_lines.payroll_id.DELETE;
		t_enc_lines.element_type_id.DELETE;
		t_enc_lines.hierarchy_code.DELETE;
		t_enc_lines.gl_ccid.DELETE;
		t_enc_lines.project_id.DELETE;
		t_enc_lines.task_id.DELETE;
		t_enc_lines.award_id.DELETE;
		t_enc_lines.exp_org_id.DELETE;
		t_enc_lines.exp_type.DELETE;
		t_enc_lines.enc_start_date.DELETE;
		t_enc_lines.enc_end_date.DELETE;
	END LOOP;

	FOR recno IN 1..t_enc_nlines.element_type_id.COUNT
	LOOP
		IF (t_enc_nlines.gl_ccid(recno) = -99) THEN
			t_enc_nlines.gl_ccid(recno) := NULL;
		ELSE
			t_enc_nlines.project_id(recno) := NULL;
			t_enc_nlines.task_id(recno) := NULL;
			t_enc_nlines.award_id(recno) := NULL;
			t_enc_nlines.exp_org_id(recno) := NULL;
			t_enc_nlines.exp_type(recno) := NULL;
		END IF;
	END LOOP;

	FORALL recno IN 1..t_enc_nlines.element_type_id.COUNT
	UPDATE	psp_enc_lines_history
	SET	hierarchy_start_date = t_enc_nlines.enc_start_date(recno),
		hierarchy_end_date = t_enc_nlines.enc_end_date(recno)
	WHERE	assignment_id = t_enc_nlines.assignment_id(recno)
	AND	payroll_id = t_enc_nlines.payroll_id(recno)
	AND	change_flag = 'N'
	AND	enc_element_type_id = t_enc_nlines.element_type_id(recno)
	AND	hierarchy_code = t_enc_nlines.hierarchy_code(recno)
	AND	(	(	gl_code_combination_id IS NOT NULL
			AND	gl_code_combination_id = t_enc_nlines.gl_ccid(recno))
		OR	(	project_id = t_enc_nlines.project_id(recno)
			AND	task_id = t_enc_nlines.task_id(recno)
			AND	award_id = t_enc_nlines.award_id(recno)
			AND	expenditure_organization_id = t_enc_nlines.exp_org_id(recno)
			AND	expenditure_type = t_enc_nlines.exp_type(recno)))
	AND	enc_start_date <= t_enc_nlines.enc_end_date(recno)
	AND	enc_end_date >= t_enc_nlines.enc_start_date(recno);

	p_return_status := fnd_api.g_ret_sts_success;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving UPDATE_HIERARCHY_DATES');
EXCEPTION
	WHEN OTHERS THEN
        g_error_api_path := SUBSTR(' UPDATE_HIERARCHY_DATES:'||g_error_api_path,1,230);
        fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN', ' UPDATE_HIERARCHY_DATES');
        p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, 'SQLCODE: ' || SQLCODE || ' SQLERRM: ' || SQLERRM);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving UPDATE_HIERARCHY_DATES');
END update_hierarchy_dates;

PROCEDURE log_st_warnings IS
l_request_id			NUMBER(15);
l_person_id				NUMBER(15);
l_organization_id		NUMBER(15);
l_assignment_number		per_all_assignments_f.assignment_number%TYPE;
l_payroll_name			pay_all_payrolls_f.payroll_name%TYPE;
l_full_name				per_all_people_f.full_name%TYPE;
l_organization_name		hr_organization_units.name%TYPE;
l_element_name			pay_element_types_f.element_name%TYPE;
l_project_number		pa_projects_all.segment1%TYPE;
l_task_number			pa_tasks.task_number%TYPE;
l_award_number			gms_awards_all.award_number%TYPE;
l_exp_org_name			hr_organization_units.name%TYPE;
l_gl_description		VARCHAR2(4000);
l_return_status			VARCHAR2(1);

CURSOR	asg_number_cur (p_assignment_id		IN	NUMBER,
						p_payroll_id		IN	NUMBER,
						p_effective_date	IN	DATE) IS
SELECT	assignment_number,
	person_id,
	organization_id
FROM	per_all_assignments_f
WHERE	assignment_id = p_assignment_id
AND	payroll_id = p_payroll_id
AND	effective_end_date >= p_effective_date
AND	ROWNUM = 1;

CURSOR	payroll_name_cur (p_payroll_id IN NUMBER) IS
SELECT	payroll_name
FROM	pay_all_payrolls_f
WHERE	payroll_id = p_payroll_id
AND	business_group_id = g_business_group_id
AND	gl_set_of_books_id = g_set_of_books_id;

CURSOR	person_name_cur (p_effective_date IN DATE) IS
SELECT	full_name
FROM	per_all_people_f
WHERE	person_id = l_person_id
AND	effective_end_date >= p_effective_date
AND	ROWNUM = 1;

CURSOR	org_name_cur IS
SELECT	name
FROM	hr_organization_units
WHERE	organization_id = l_organization_id;

CURSOR	project_number_cur (p_project_id IN NUMBER) IS
SELECT	SEGMENT1
FROM	pa_projects_all
WHERE	project_id = p_project_id;

CURSOR	award_number_cur (p_award_id IN NUMBER) IS
SELECT	award_number
FROM	gms_awards_all
WHERE	award_id = p_award_id;

CURSOR	task_number_cur (p_task_id IN NUMBER) IS
SELECT	task_number
FROM	pa_tasks
WHERE	task_id = p_task_id;

CURSOR	exp_org_name_cur (p_expenditure_org_id IN NUMBER) IS
SELECT	name
FROM	hr_organization_units
WHERE	organization_id = p_expenditure_org_id;

CURSOR	element_name_cur (p_element_type_id IN NUMBER) IS
SELECT	element_name
FROM	pay_element_types_f
WHERE	element_type_id = p_element_type_id
AND		ROWNUM = 1;
BEGIN
	l_request_id := fnd_global.conc_request_id;

	FOR recno IN 1..st_warnings.assignment_id.COUNT
	LOOP
		OPEN asg_number_cur(st_warnings.assignment_id(recno), st_warnings.payroll_id(recno), st_warnings.start_date(recno));
		FETCH asg_number_cur INTO l_assignment_number, l_person_id, l_organization_id;
		CLOSE asg_number_cur;

		OPEN payroll_name_cur(st_warnings.payroll_id(recno));
		FETCH payroll_name_cur INTO l_payroll_name;
		CLOSE payroll_name_cur;

		OPEN person_name_cur(st_warnings.start_date(recno));
		FETCH person_name_cur INTO l_full_name;
		CLOSE person_name_cur;

		OPEN org_name_cur;
		FETCH org_name_cur INTO l_organization_name;
		CLOSE org_name_cur;

		OPEN element_name_cur(st_warnings.element_type_id(recno));
		FETCH element_name_cur INTO l_element_name;
		CLOSE element_name_cur;

		IF (st_warnings.project_id(recno) IS NOT NULL) THEN
			OPEN project_number_cur(st_warnings.project_id(recno));
			FETCH project_number_cur INTO l_project_number;
			CLOSE project_number_cur;

			OPEN award_number_cur(st_warnings.award_id(recno));
			FETCH award_number_cur INTO l_award_number;
			CLOSE award_number_cur;

			OPEN task_number_cur(st_warnings.task_id(recno));
			FETCH task_number_cur INTO l_task_number;
			CLOSE task_number_cur;

			OPEN exp_org_name_cur(st_warnings.exp_org_id(recno));
			FETCH exp_org_name_cur INTO l_exp_org_name;
			CLOSE exp_org_name_cur;

			fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_INV_PATEO');
			fnd_message.set_token('PJ', l_project_number);
			fnd_message.set_token('TK', l_task_number);
			fnd_message.set_token('AW', l_award_number);
			fnd_message.set_token('EO', l_exp_org_name);
			fnd_message.set_token('ET', st_warnings.exp_type(recno));
			fnd_message.set_token('START_DATE', st_warnings.start_date(recno));
			fnd_message.set_token('END_DATE', st_warnings.end_date(recno));
			fnd_message.set_token('EFFECTIVE_DATE', st_warnings.effective_date(recno));
			fnd_message.set_token('ERROR_STATUS', st_warnings.error_status(recno));
			g_warning_message := fnd_message.get;
		ELSE
			l_gl_description := psp_general.get_gl_description(g_set_of_books_id, st_warnings.gl_ccid(recno));

			fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_INV_GL');
			fnd_message.set_token('GL', l_gl_description);
			fnd_message.set_token('START_DATE', st_warnings.start_date(recno));
			fnd_message.set_token('END_DATE', st_warnings.end_date(recno));
			fnd_message.set_token('EFFECTIVE_DATE', st_warnings.effective_date(recno));
			fnd_message.set_token('ERROR_STATUS', st_warnings.error_status(recno));
			g_warning_message := fnd_message.get;
		END IF;

		psp_general.add_report_error
				(p_request_id		=>	l_request_id,
				p_message_level		=>	'W',
				p_source_id			=>	st_warnings.assignment_id(recno),
				p_source_name		=>	l_assignment_number,
				p_parent_source_id	=>	l_person_id,
				p_parent_source_name	=>	l_full_name,
				p_error_message		=>	g_warning_message,
				p_payroll_action_id	=>	g_payroll_action_id,
				p_value1			=>	st_warnings.payroll_id(recno),
				p_information1		=>	l_payroll_name,
				p_value2			=>	l_organization_id,
				p_value3			=>	st_warnings.element_type_id(recno),
				p_information2		=>	l_organization_name,
				p_information3		=>	l_element_name,
				p_information4		=>	fnd_date.date_to_canonical(st_warnings.start_date(recno)),
				p_information5		=>	fnd_date.date_to_canonical(st_warnings.end_date(recno)),
				p_information6		=>	'SA',
				p_return_status		=>	l_return_status);
	END LOOP;
END log_st_warnings;

PROCEDURE	add_st_warnings(p_start_date	IN	DATE	DEFAULT NULL,
						p_end_date			IN	DATE	DEFAULT NULL,
						p_assignment_id		IN	NUMBER	DEFAULT NULL,
						p_payroll_id		IN	NUMBER	DEFAULT NULL,
						p_element_type_id	IN	NUMBER	DEFAULT NULL,
						p_gl_ccid			IN	NUMBER	DEFAULT NULL,
						p_project_id		IN	NUMBER	DEFAULT NULL,
						p_task_id			IN	NUMBER	DEFAULT NULL,
						p_award_id			IN	NUMBER	DEFAULT NULL,
						p_exp_org_id		IN	NUMBER	DEFAULT NULL,
						p_exp_type			IN	VARCHAR2	DEFAULT NULL,
						p_effective_date	IN	DATE	DEFAULT NULL,
						p_error_status		IN	VARCHAR2	DEFAULT NULL) IS
l_warning_ind		NUMBER(15);
BEGIN
	l_warning_ind := st_warnings.start_date.COUNT;
	fnd_file.put_line(fnd_file.log, 'Entering add_st_warnings');
	hr_utility.trace('p_start_date: ' || p_start_date || ' p_end_date: ' || p_end_date ||
		' p_assignment_id: ' || p_assignment_id || ' p_payroll_id: ' || p_payroll_id ||
		' p_element_type_id: ' || p_element_type_id || ' p_gl_ccid: ' || p_gl_ccid ||
		' p_project_id: ' || p_project_id || ' p_task_id: ' || p_task_id ||
		' p_award_id:' || p_award_id || ' p_exp_org_id: ' || p_exp_org_id ||
		' p_exp_type: ' || p_exp_type || ' p_effective_date: ' || p_effective_date ||
		' p_error_status: ' || p_error_status);

	IF (p_project_id IS NOT NULL) THEN
		LOOP
			EXIT WHEN l_warning_ind = 0;
			EXIT WHEN ((	(st_warnings.end_date(l_warning_ind) = (p_start_date -1) OR
							(	(st_warnings.end_date(l_warning_ind) >= p_start_date) AND
								(st_warnings.start_date(l_warning_ind) <= p_end_date)))) AND
				(st_warnings.assignment_id(l_warning_ind) = p_assignment_id) AND
				(st_warnings.payroll_id(l_warning_ind) = p_payroll_id) AND
				(st_warnings.element_type_id(l_warning_ind) = p_element_type_id) AND
				(st_warnings.project_id(l_warning_ind) = p_project_id) AND
				(st_warnings.task_id(l_warning_ind) = p_task_id) AND
				(st_warnings.award_id(l_warning_ind) = p_award_id) AND
				(st_warnings.exp_org_id(l_warning_ind) = p_exp_org_id) AND
				(st_warnings.exp_type(l_warning_ind) = p_exp_type) AND
				(st_warnings.error_status(l_warning_ind) = p_error_status));
			l_warning_ind := l_warning_ind - 1;
		END LOOP;
	ELSE
		LOOP
			EXIT WHEN l_warning_ind = 0;
			EXIT WHEN ((	(st_warnings.end_date(l_warning_ind) = (p_start_date -1) OR
							(	(st_warnings.end_date(l_warning_ind) >= p_start_date) AND
								(st_warnings.start_date(l_warning_ind) <= p_end_date)))) AND
				(st_warnings.gl_ccid(l_warning_ind) = p_gl_ccid) AND
				(st_warnings.error_status(l_warning_ind) = p_error_status));
			l_warning_ind := l_warning_ind - 1;
		END LOOP;
	END IF;

	IF (l_warning_ind = 0) THEN
		l_warning_ind := st_warnings.start_date.COUNT + 1;
		st_warnings.start_date(l_warning_ind) := p_start_date;
		st_warnings.end_date(l_warning_ind) := p_end_date;
		st_warnings.assignment_id(l_warning_ind) := p_assignment_id;
		st_warnings.payroll_id(l_warning_ind) := p_payroll_id;
		st_warnings.element_type_id(l_warning_ind) := p_element_type_id;
		st_warnings.gl_ccid(l_warning_ind) := p_gl_ccid;
		st_warnings.project_id(l_warning_ind) := p_project_id;
		st_warnings.task_id(l_warning_ind) := p_task_id;
		st_warnings.award_id(l_warning_ind) := p_award_id;
		st_warnings.exp_org_id(l_warning_ind) := p_exp_org_id;
		st_warnings.exp_type(l_warning_ind) := p_exp_type;
		st_warnings.effective_date(l_warning_ind) := p_effective_date;
		st_warnings.error_status(l_warning_ind) := p_error_status;
	ELSE
		st_warnings.end_date(l_warning_ind) := p_end_date;
		st_warnings.effective_date(l_warning_ind) := p_effective_date;
	END IF;

	hr_utility.trace('st_warnings.start_date.COUNT: ' || st_warnings.start_date.COUNT);
	fnd_file.put_line(fnd_file.log, 'Leaving add_st_warnings');
END	add_st_warnings;

PROCEDURE	move_rej_lines_to_arch (p_payroll_action_id	IN	NUMBER) IS
BEGIN
	INSERT	INTO PSP_ENC_SUMMARY_LINES_ARCH
		(enc_summary_line_id,		business_group_id,		gms_batch_name,
		time_period_id,			person_id,			assignment_id,
		effective_date,			set_of_books_id,		gl_code_combination_id,
		project_id,			expenditure_organization_id,	expenditure_type,
		task_id,			award_id,			summary_amount,
		dr_cr_flag,			group_id,			interface_status,
		payroll_id,			gl_period_id,			gl_project_flag,
		attribute_category,		attribute1,			attribute2,
		attribute3,			attribute4,			attribute5,
		attribute6,			attribute7,			attribute8,
		attribute9,			attribute10,			attribute11,
		attribute12,			attribute13,			attribute14,
		attribute15,			attribute16,			attribute17,
		attribute18,			attribute19,			attribute20,
		attribute21,			attribute22,			attribute23,
		attribute24,			attribute25,			attribute26,
		attribute27,			attribute28,			attribute29,
		attribute30,			reject_reason_code,		enc_control_id,
		status_code,			last_update_date,		last_updated_by,
		last_update_login,		created_by,			creation_date,
		suspense_org_account_id,	superceded_line_id,		gms_posting_override_date,
		gl_posting_override_date,	expenditure_id,			expenditure_item_id,
		expenditure_ending_date,	interface_id,			txn_interface_id,
		payroll_action_id,		liquidate_request_id,		proposed_termination_date,
		update_flag)
	SELECT	enc_summary_line_id,		business_group_id,		gms_batch_name,
		time_period_id,			person_id,			assignment_id,
		effective_date,			set_of_books_id,		gl_code_combination_id,
		project_id,			expenditure_organization_id,	expenditure_type,
		task_id,			award_id,			summary_amount,
		dr_cr_flag,			group_id,			interface_status,
		payroll_id,			gl_period_id,			gl_project_flag,
		attribute_category,		attribute1,			attribute2,
		attribute3,			attribute4,			attribute5,
		attribute6,			attribute7,			attribute8,
		attribute9,			attribute10,			attribute11,
		attribute12,			attribute13,			attribute14,
		attribute15,			attribute16,			attribute17,
		attribute18,			attribute19,			attribute20,
		attribute21,			attribute22,			attribute23,
		attribute24,			attribute25,			attribute26,
		attribute27,			attribute28,			attribute29,
		attribute30,			reject_reason_code,		enc_control_id,
		status_code,			last_update_date,		last_updated_by,
		last_update_login,		created_by,			creation_date,
		suspense_org_account_id,	superceded_line_id,		gms_posting_override_date,
		gl_posting_override_date,	expenditure_id,			expenditure_item_id,
		expenditure_ending_date,	interface_id,			txn_interface_id,
		payroll_action_id,		liquidate_request_id,		proposed_termination_date,
		update_flag
	FROM	psp_enc_summary_lines
	WHERE	payroll_action_id = p_payroll_action_id
	AND	status_code = 'R';

	IF (SQL%ROWCOUNT > 0) THEN
		fnd_file.put_line(fnd_file.log, 'Moved rejected lines (if any) to archival table as they are no longer useful');
	END IF;

	DELETE	psp_enc_summary_lines
	WHERE	payroll_action_id = p_payroll_action_id
	AND	status_code = 'R';

END move_rej_lines_to_arch;
END psp_enc_sum_tran;

/
