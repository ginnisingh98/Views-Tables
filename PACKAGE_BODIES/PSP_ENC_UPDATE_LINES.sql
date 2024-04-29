--------------------------------------------------------
--  DDL for Package Body PSP_ENC_UPDATE_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ENC_UPDATE_LINES" AS
/* $Header: PSPENUPB.pls 120.3 2006/02/22 05:16:55 spchakra noship $ */

-- Global Variable for referring REquest ID through out the package, Introduce for bug 2259310
g_request_id	NUMBER DEFAULT fnd_global.conc_request_id;
g_liquidate_flag varchar2(1); --- 3953230

Procedure Update_Enc_lines (errbuf 	    out NOCOPY varchar2,
                            retcode 	    out NOCOPY	varchar2,
                            p_payroll_id    IN	Number,
                            p_enc_line_type IN	VARCHAR2,
                            p_business_group_id IN Number,
                            p_set_of_books_id IN Number) IS
BEGIN
	NULL;
END;

Procedure verify_changes (p_payroll_id IN  NUMBER,
                          p_business_group_id IN NUMBER,
                          p_set_of_books_id IN NUMBER,
                          p_enc_line_type IN VARCHAR2, --Added for bug 2143723.
                          l_retcode      OUT NOCOPY VARCHAR2) IS
BEGIN
	NULL;
END;

PROCEDURE  move_qkupd_rec_to_hist( p_payroll_id	IN	NUMBER,
	   			     p_enc_line_type	IN	VARCHAR2,
			             p_business_group_id IN    NUMBER,
				     p_set_of_books_id   IN    NUMBER,
				     p_return_status	OUT NOCOPY	VARCHAR2) IS
BEGIN
	NULL;
END;

PROCEDURE  cleanup_on_success	( p_enc_line_type 	IN 	VARCHAR2,
                                  p_payroll_id  	IN 	NUMBER,
                                  p_business_group_id 	IN 	NUMBER,
                                  p_set_of_books_id 	IN 	NUMBER,
                                  p_invalid_suspense 	IN	VARCHAR2,
                                  p_return_status	OUT NOCOPY 	VARCHAR2) IS
BEGIN
	NULL;
END;

PROCEDURE ROLLBACK_REJECTED_ASG (p_payroll_id in integer,
                                 p_action_type in varchar2,
                                 p_gms_batch_name in varchar2,
                                 p_accepted_group_id in integer,
                                 p_rejected_group_id in integer,
                                 p_run_id      in integer,
                                 p_business_group_id in integer,
                                 p_set_of_books_id   in integer,
                                 p_return_status out nocopy varchar2) IS
BEGIN
	NULL;
END;

/*****	Commented for bug fix 3434626
--Following cursor is added to convert select stmt into a cursor, Enh .Quick Update Design.
 uncommented for bug fix 3684930 *** /
CURSOR 	c_unsummarized_lines IS
SELECT  DISTINCT  action_code
FROM   	psp_enc_controls
WHERE  	action_code = 'N'
AND     payroll_id=p_payroll_id;

/ * Following cursors are added for Enh. Restart Update Enc Proces * /
CURSOR inprogress_count_cur IS
--SELECT count(*)		Commented for bug fix 3434626
SELECT DISTINCT action_code
FROM   psp_enc_controls
WHERE  action_type in ('U','N','Q')
AND    action_code IN ('IU' , 'IC')	-- Introduced 'IC' check for bug fix 3434626
/ * action code = 'IU' means Failure due to db crash * /
AND    payroll_id = p_payroll_id
AND    business_group_id = p_business_group_id
AND    set_of_books_id = p_set_of_books_id
ORDER BY action_code DESC;	-- Introduced for bug fix 3434626

/ *****	Changed the following cursor for bug fix 3434626
CURSOR	action_type_inprogress IS
SELECT	NVL(action_type, p_enc_line_type)
FROM	psp_enc_controls
WHERE	action_code = 'IC'
AND	payroll_id = p_payroll_id
AND	business_group_id = p_business_group_id
AND	set_of_books_id = p_set_of_books_id
AND	rownum = 1; 	End of comment for bug fix 3434626	***** /

CURSOR	action_type_inprogress IS
SELECT	processed_flag
FROM	psp_enc_changed_assignments peca
WHERE	processed_flag IS NOT NULL
AND	payroll_id = p_payroll_id
AND	ROWNUM = 1;
--	End of changes for bug fix 3434626

--Modifying the cursor for Bug 2345813 : Introducing assignment_id check in the cursor
CURSOR	 count_change_flag IS
SELECT	 count(change_flag)
FROM 	 psp_enc_lines_history pelh,
	 psp_enc_changed_assignments peca
WHERE 	 pelh.change_flag	= 'N'
AND   	 pelh.payroll_id 	=  p_payroll_id
AND	 rownum			= 1
AND	 pelh.assignment_id 	=  peca.assignment_id
AND      peca.payroll_id 	= p_payroll_id
AND      peca.request_id 	IS NOT NULL
AND     ((p_enc_line_type 	= 'Q'  AND     peca.change_type	IN ('LS', 'ET', 'AS', 'QU'))
OR      p_enc_line_type 	= 'U');

l_errbuf			VARCHAR2(2000);
l_retcode	  		VARCHAR2(30);
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
l_success			VARCHAR2(1) DEFAULT 'F';
l_success_code			VARCHAR2(200);
l_action_code			VARCHAR2(1);
l_chg_count                     NUMBER DEFAULT	0;
l_new_line_count                NUMBER DEFAULT	0;

/ * Following Variables are added for Enh. Restart Update Enc Process * /
--l_inprogress_count              NUMBER DEFAULT  -1; 	-- Added for Restart, count in-progress control recs	Commented for bug fix 3434626
l_inprogress_actioncode		CHAR(2);	-- Introduced for bug fixs 3434626
l_create_inprogress             NUMBER  DEFAULT   0;  	 /* count of inprogress create control records
                                                            action code = 'IC' * /
l_enc_line_type                 VARCHAR2(1) DEFAULT  p_enc_line_type;  / * to derive Q or U for restart purposes * /
l_enc_line_type_dsc		VARCHAR2(80);
--	Introduced the following for bug fix 3434626
CURSOR	enc_line_type_cur IS
SELECT	meaning
FROM	fnd_lookups
WHERE	lookup_type = 'PSP_ENC_LINE_TYPES'
AND	lookup_code = l_enc_line_type;
--	End of bug fix 3434626

--	Introduced the following for bg fix 4625734
l_liquidate_request_id	NUMBER(15);
l_person_id		NUMBER(15);
l_full_name		VARCHAR2(240);
l_termination_date	DATE;

CURSOR	emp_term_inprogress_cur IS
SELECT	DISTINCT liquidate_request_id
FROM	psp_enc_controls
WHERE	payroll_id = p_payroll_id
AND	action_code = 'IT';

CURSOR	get_term_employee_cur IS
SELECT	TO_NUMBER(argument3),
	fnd_date.canonical_to_date(fnd_date.date_to_canonical(argument4))
FROM	fnd_concurrent_requests
WHERE	request_id = l_liquidate_request_id;

CURSOR	get_full_name_cur IS
SELECT	full_name
FROM	per_people_f
WHERE	person_id = l_person_id
AND	l_termination_date BETWEEN effective_start_date and effective_end_date;
--	End of changes for bug fix 4625734
BEGIN
----hr_utility.trace_on('Y','ENC');
--	Introduced the following for bg fix 4625734
	OPEN emp_term_inprogress_cur;
	FETCH emp_term_inprogress_cur INTO l_liquidate_request_id;
	CLOSE emp_term_inprogress_cur;

	IF (NVL(l_liquidate_request_id, 0) > 0) THEN
		OPEN get_term_employee_cur;
		FETCH get_term_employee_cur INTO l_person_id, l_termination_date;
		CLOSE get_term_employee_cur;

		OPEN get_full_name_cur;
		FETCH get_full_name_cur INTO l_full_name;
		CLOSE get_full_name_cur;

		fnd_message.set_name('PSP', 'PSP_ENC_LIQ_TERM_EMP_PENDING');
		fnd_message.set_token('PERSON', l_full_name);
		fnd_message.set_token('TERMDATE', l_termination_date);
		fnd_msg_pub.add;
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;
--	End of changes for bug fix 4625734
 	 / * Following code is added for Enh.Restart Update Process.  * /
   	OPEN  inprogress_count_cur;
        FETCH inprogress_count_cur INTO l_inprogress_actioncode;	-- Changed to actioncode for bug fix 3434626
--  	CLOSE inprogress_count_cur;	Commented for bug fix 3434626

	IF (inprogress_count_cur%FOUND) THEN	-- Introduced for bug fix 3434626
   	OPEN action_type_inprogress;
  	 FETCH action_type_inprogress INTO l_enc_line_type;
   	CLOSE action_type_inprogress;

--	Introduced for bug fix 3434626
	IF (l_enc_line_type <> p_enc_line_type) THEN
		OPEN enc_line_type_cur;
		FETCH enc_line_type_cur INTO l_enc_line_type_dsc;
		CLOSE enc_line_type_cur;

		fnd_message.set_name('PSP', 'PSP_ENC_SUBMIT_CORRECT_PROCESS');
		fnd_message.set_token('LINE_TYPE', l_enc_line_type_dsc);
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
--	End of changes for bug fix 3434626

/ *****	Commented for bug fix 3434626
   	IF action_type_inprogress%NOTFOUND THEN
  		IF   l_inprogress_count >0 	THEN
 	     		-- this case should not arise unless some data corruption
            		 g_error_api_path := 'No_create_rec_found'||g_error_api_path;
                         fnd_msg_pub.add_exc_msg('PSP_ENC_UPDATE_LINES',g_error_api_path);   --- added this line for 2444657
      	     		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      		END IF;
   	ELSE
	End of bug fix 3434626	***** /
--	Introduced for bug fix 3434626
	l_create_inprogress := -1;
	IF (l_inprogress_actioncode = 'IC') THEN
   		l_create_inprogress := 1;
	END IF;
--	End of changes for bug fix 3434626

	END IF;		-- Introduced for bug fix 3434626
  	CLOSE inprogress_count_cur;	-- Introduced for bug fix 3434626

	IF l_create_inprogress = 0 then
--	Introduced thr following for bug fix 3434626
		UPDATE	psp_enc_changed_assignments
		SET	processed_flag = p_enc_line_type
		WHERE	payroll_id = p_payroll_id
		AND	p_enc_line_type = 'U'
			OR	(	p_enc_line_type = 'Q'
				AND	change_type IN ('AS', 'LS', 'ET', 'QU'));
--	End of bug fix 3434626

                       / **  re-introduced following check for 3684930 ** /
                        OPEN c_unsummarized_lines;
                        FETCH c_unsummarized_lines INTO l_action_code;
                        IF c_unsummarized_lines%FOUND THEN
                             fnd_message.Set_name('PSP','PSP_ENC_NO_LIN_UPD');
                             fnd_msg_pub.add;
                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

	      			 psp_enc_create_lines.create_enc_lines (errbuf        		=>  l_errbuf,
						      			retcode       	 	=>  l_retcode,
						     			p_payroll_id    	=>   p_payroll_id,
						        		p_enc_line_type 	=>   p_enc_line_type,
						       			p_business_group_id 	=>   p_business_group_id,
						        		p_set_of_books_id       =>   p_set_of_books_id);
            	    		IF (l_retcode <> FND_API.G_RET_STS_SUCCESS ) THEN
                		 	g_error_api_path := 'CREATE_ENC_LINES:'||g_error_api_path;
                 		 	fnd_message.set_name ('PSP','PSP_ENC_ENCUMBRANCE_FAILED');
                 		 	fnd_msg_pub.add;
               				/ * commented following proc Restart Update Enc process * /
               				/ * clean_up_when_error; * /
   		                	psp_message_s.print_error(P_MODE => FND_FILE.LOG,
                  			p_print_header => FND_API.G_TRUE);
--                 	 		CLOSE c_unsummarized_lines;	Commented for bug fix 3434626
                 	 		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            			END IF;
		l_create_inprogress := 1;	-- Introduced fro bug fix 3434626
--         		 END IF;	Commented for bug fix 3434626

END IF;   / * create_inprogress_count ,Enh. Restart Update Encumbrance Proecss * /

--   IF  l_inprogress_count = 0 then        Commented for bug fix 3434626
	IF (l_create_inprogress = 1) THEN

   -- Gathering Statistics for Bug 3821553.
      begin
       FND_STATS.Gather_Table_Stats(ownname => 'PSP',
                                    tabname => 'PSP_ENC_CONTROLS');

       FND_STATS.Gather_Table_Stats(ownname => 'PSP',
                                    tabname => 'PSP_ENC_LINES');

       FND_STATS.Gather_Table_Stats(ownname => 'PSP',
                                    tabname => 'PSP_ENC_LINES_HISTORY');

      exception
       when others then
        null;

      end;
   -- End of gather statistics for Bug 3821553
   -- no control  records in limbo due to previous failed run.
   -- If create is successful call the verify program with payroll_id
       	  verify_changes(p_payroll_id,
		  	p_business_group_id ,
   			p_set_of_books_id,
  			-- p_enc_line_type,
  			l_enc_line_type,
  			/ * changed p_enc_line_type to l_enc_line_type for Restart * /
  			l_retcode);

   		IF (l_retcode <> FND_API.G_RET_STS_SUCCESS )	THEN
 	 		fnd_message.set_name ('PSP','PSP_ENC_VERIFY_FAILED');
        	 	fnd_msg_pub.add;
         		/ * commented following proc Restart Update Enc process * /
        	 	/ * clean_up_when_error; * /
     			 psp_message_s.print_error(p_mode => FND_FILE.LOG,
		 	 p_print_header => FND_API.G_TRUE);
     			 g_error_api_path := 'VERIFY_CHANGES:'||g_error_api_path;
                 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  		END IF;
  END IF;
---- 3953230
If nvl(g_liquidate_flag ,'N') = 'Y' then
   l_chg_count := 1;
else
-- Call the liquidate program with payroll_id and action_type = 'U'
 OPEN count_change_flag ;
 FETCH count_change_flag INTO l_chg_count;
 CLOSE count_change_flag;
end if;
  IF l_chg_count <> 0 THEN

   -- Introduced the folowing code for Bug 3821553
   -- did a gather statistics on PSP_ENC_LINES table

  begin
       FND_STATS.Gather_Table_Stats(ownname => 'PSP',
                                    tabname => 'PSP_ENC_LINES_HISTORY');


      exception
       when others then
        null;

  end;

 -- End of Code changes for Bug 3821553

          psp_enc_liq_tran.enc_liq_trans(ERRBUF      	        => l_errbuf,
                                         RETCODE       		=> l_retcode,
                                         P_PAYROLL_ID  		=> p_payroll_id,
                                     	/ * changed p_action_type to l_enc_line_type for restart * /
                                	 p_action_type  	=>  l_enc_line_type,
                                         P_Business_group_id 	=> p_business_group_id,
                                         p_Set_of_books_id      => p_set_of_books_id);
   	--   Check for success of the liquidation program
                IF (l_retcode NOT IN ('1', FND_API.G_RET_STS_SUCCESS)) THEN	--	 Introduced retcode '1' check for Enh. 2768298
			 / * commented following line for update Restart * /
  	  		/ *  clean_up_when_error; * /
   	  		g_error_api_path := 'ENC_LIQ_TRAN:'||g_error_api_path;
     	  		psp_message_s.print_error(p_mode => FND_FILE.LOG,p_print_header => FND_API.G_TRUE);
          		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      		END IF;
  ELSE      / *  l_chg_count = 0 * /
            / * If liquidation doesn't fire, call the house keeping step explicitly * /
            	      cleanup_on_success(p_enc_line_type ,
                                	p_payroll_id ,
                                	p_business_group_id,
                                	p_set_of_books_id,
                                	'N',          --- invalid suspense send 'N'
                                	l_retcode);
           	IF (l_retcode <> FND_API.G_RET_STS_SUCCESS ) THEN
               		g_error_api_path := 'cleanup_on_sucess'||g_error_api_path;
              		psp_message_s.print_error(p_mode => FND_FILE.LOG,
	        	p_print_header => FND_API.G_TRUE);
                	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          	ELSE
   	             COMMIT;
          	END IF;
  END IF;
--	psp_message_s.print_success;
--	Replaced Success printing message for Enh. 2768298 removal of suspense posting in enc. Liquidation
	IF (l_retcode = '1') THEN
		retcode := 1;
		psp_message_s.print_error(p_mode		=>	FND_FILE.LOG,
					  p_print_header	=>	FND_API.G_FALSE);
	ELSE
		psp_message_s.print_success;
	END IF;
--	End of changes for Enh. 2768298 Removal of suspense posting in Enc. Liquidation

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		g_error_api_path := 'UPDATE_ENC_LINES:'||g_error_api_path;
     		fnd_msg_pub.add_exc_msg('PSP_ENC_UPDATE_LINES',g_error_api_path || sqlerrm);
     		l_retcode := fnd_api.g_ret_sts_unexp_error;
		retcode := 2;
--	Introduced the following for bug fix 3434626
		psp_message_s.print_error(p_mode		=>	FND_FILE.LOG,
					  p_print_header	=>	FND_API.G_FALSE);
--	End of bug fix 3434626
	WHEN OTHERS THEN
		g_error_api_path := 'UPDATE_ENC_LINES:'||g_error_api_path||' UNEXPECTED ERROR';
     		fnd_msg_pub.add_exc_msg('PSP_ENC_UPDATE_LINES',g_error_api_path || sqlerrm);
     		l_retcode := fnd_api.g_ret_sts_unexp_error;
		retcode := 2;
--	Introduced the following for bug fix 3434626
		psp_message_s.print_error(p_mode		=>	FND_FILE.LOG,
					  p_print_header	=>	FND_API.G_FALSE);
--	End of bug fix 3434626
end update_enc_lines;


/ * Change History ***********************************************************************************

Who             When            What
ddubey         07-Mar-2002	Procedure verify_changes is re written for Enh. Encumbrance
			        Redesign-Pre Process Bug #2259310.Introdced Bulk Update For
			        1. Marking chage_flag ='U'for unchanged lines in psp_enc_lines_history
			        2. Marking change_flag ='N' for unmodfied lines in psp_enc_lines_history,
			           which are having same summary_line_id as modified lines.

				Introduced Bulk Delete to delete newly created lines in psp_enc_lines
				where the corresponding history lines are flagged as unmodified
				i.e change_flag ='U'.

lveerubh	07-May-2002	Introduced Deletion of controls when there are no corresponding lines present-Bug 2359599
***************************************************************************************************** /

Procedure verify_changes(p_payroll_id 		IN 	NUMBER,
			 p_business_group_id 	IN 	NUMBER,
			 p_set_of_books_id 	IN 	NUMBER,
			 p_enc_line_type 	IN	VARCHAR2,
			 l_retcode 		OUT NOCOPY 	VARCHAR2) IS

	CURSOR	new_control_recs IS
	SELECT	enc_control_id,
		time_period_id
	FROM	psp_enc_controls
	WHERE	payroll_id = p_payroll_id
	AND	action_code = 'IC';

        / * Commented for Bug 3821553

	TYPE	enc_control_id_tl IS
	TABLE OF psp_enc_controls.enc_control_id%TYPE
	INDEX BY BINARY_INTEGER;
	l_enc_control_id_tl enc_control_id_tl;

	TYPE	time_period_id_tl IS
	TABLE OF psp_enc_controls.time_period_id%TYPE
	INDEX BY BINARY_INTEGER;
	l_time_period_id_tl  time_period_id_tl;

        End of Commenting for Bug 3821553* /

	l_grouping_option	CHAR(1);	-- Introduced for bug fix 2908859

         / * Introduced the following for Bug 3821553 * /
         TYPE  time_period_id_tl IS
        TABLE OF psp_enc_lines.time_period_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_time_period_id_tl  time_period_id_tl;

        TYPE  encumbrance_date_tl IS
        TABLE OF psp_enc_lines.encumbrance_date%TYPE
        INDEX BY BINARY_INTEGER;
        l_encumbrance_date_tl  encumbrance_date_tl;

        TYPE  dr_cr_flag_tl IS
        TABLE OF psp_enc_lines.dr_cr_flag%TYPE
        INDEX BY BINARY_INTEGER;
        l_dr_cr_flag_tl  dr_cr_flag_tl;


        TYPE  encumbrance_amount_tl IS
        TABLE OF psp_enc_lines.encumbrance_amount%TYPE
        INDEX BY BINARY_INTEGER;
        l_encumbrance_amount_tl  encumbrance_amount_tl;

        TYPE  gl_project_flag_tl IS
        TABLE OF psp_enc_lines.gl_project_flag%TYPE
        INDEX BY BINARY_INTEGER;
        l_gl_project_flag_tl  gl_project_flag_tl;

       TYPE  schedule_line_id_tl IS
        TABLE OF psp_enc_lines.schedule_line_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_schedule_line_id_tl  schedule_line_id_tl;

        TYPE  org_schedule_id_tl IS
        TABLE OF psp_enc_lines.org_schedule_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_org_schedule_id_tl  org_schedule_id_tl;

        TYPE  default_org_account_id_tl IS
        TABLE OF psp_enc_lines.default_org_account_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_default_org_account_id_tl  default_org_account_id_tl;

        TYPE  suspense_org_account_id_tl IS
        TABLE OF psp_enc_lines.suspense_org_account_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_suspense_org_account_id_tl  suspense_org_account_id_tl;


        TYPE  element_account_id_tl IS
        TABLE OF psp_enc_lines.element_account_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_element_account_id_tl  element_account_id_tl;



        TYPE  project_id_tl IS
        TABLE OF psp_enc_lines.project_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_project_id_tl  project_id_tl;

        TYPE  task_id_tl IS
        TABLE OF psp_enc_lines.task_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_task_id_tl  task_id_tl;



        TYPE  award_id_tl IS
        TABLE OF psp_enc_lines.award_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_award_id_tl  award_id_tl;

        TYPE  expenditure_type_tl IS
        TABLE OF psp_enc_lines.expenditure_type%TYPE
        INDEX BY BINARY_INTEGER;
        l_expenditure_type_tl  expenditure_type_tl;

        TYPE  exp_organization_id_tl IS
        TABLE OF psp_enc_lines.expenditure_organization_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_exp_organization_id_tl  exp_organization_id_tl;

        TYPE  gl_code_combination_id_tl IS
        TABLE OF psp_enc_lines.gl_code_combination_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_gl_code_combination_id_tl  gl_code_combination_id_tl;


        TYPE  assignment_id_tl IS
        TABLE OF psp_enc_lines.assignment_id%TYPE
        INDEX BY BINARY_INTEGER;
        l_assignment_id_tl  assignment_id_tl;

        TYPE  attribute1_tl IS
        TABLE OF psp_enc_lines.attribute1%TYPE
        INDEX BY BINARY_INTEGER;
        l_attribute1_tl  attribute1_tl;


        TYPE  attribute2_tl IS
        TABLE OF psp_enc_lines.attribute2%TYPE
        INDEX BY BINARY_INTEGER;
        l_attribute2_tl  attribute2_tl;

        TYPE  attribute3_tl IS
        TABLE OF psp_enc_lines.attribute3%TYPE
        INDEX BY BINARY_INTEGER;
        l_attribute3_tl  attribute3_tl;

        TYPE  attribute4_tl IS
        TABLE OF psp_enc_lines.attribute4%TYPE
        INDEX BY BINARY_INTEGER;
        l_attribute4_tl  attribute4_tl;

        TYPE  attribute5_tl IS
        TABLE OF psp_enc_lines.attribute5%TYPE
        INDEX BY BINARY_INTEGER;
        l_attribute5_tl  attribute5_tl;

        TYPE  attribute6_tl IS
        TABLE OF psp_enc_lines.attribute6%TYPE
        INDEX BY BINARY_INTEGER;
        l_attribute6_tl  attribute6_tl;

        TYPE  attribute7_tl IS
        TABLE OF psp_enc_lines.attribute7%TYPE
        INDEX BY BINARY_INTEGER;
        l_attribute7_tl  attribute7_tl;

        TYPE  attribute8_tl IS
        TABLE OF psp_enc_lines.attribute8%TYPE
        INDEX BY BINARY_INTEGER;
        l_attribute8_tl  attribute8_tl;

        TYPE  attribute9_tl IS
        TABLE OF psp_enc_lines.attribute9%TYPE
        INDEX BY BINARY_INTEGER;
        l_attribute9_tl  attribute9_tl;

        TYPE  attribute10_tl IS
        TABLE OF psp_enc_lines.attribute10%TYPE
        INDEX BY BINARY_INTEGER;
        l_attribute10_tl  attribute10_tl;

        -- new cursor for fetching enc lines

        cursor  enc_lines_cur is
	SELECT distinct pel.time_period_id,
	pel.encumbrance_date,
	pel.dr_cr_flag,
	pel.encumbrance_amount,
	pel.gl_project_flag,
	NVL(pel.schedule_line_id,-99),
	NVL(pel.org_schedule_id, -99),
	NVL(pel.default_org_account_id, -99),
	NVL(pel.suspense_org_account_id, -99),
	NVL(pel.element_account_id, -99),
	NVL(project_id, -99),
	NVL(pel.task_id, -99),
	NVL(pel.award_id, -99),
	NVL(pel.expenditure_type, '-99'),
	NVL(pel.expenditure_organization_id, -99),
	NVL(pel.gl_code_combination_id, -99),
	pel.assignment_id,
        NVL(pel.attribute1,-99),
        NVL(pel.attribute2,-99),
        NVL(pel.attribute3,-99),
        NVL(pel.attribute4,-99),
        NVL(pel.attribute5,-99),
        NVL(pel.attribute6,-99),
        NVL(pel.attribute7,-99),
        NVL(pel.attribute8,-99),
        NVL(pel.attribute9,-99),
        NVL(pel.attribute10,-99)
  	FROM psp_enc_lines pel
	WHERE   enc_control_id in  (Select enc_control_id
        FROM    psp_enc_controls pec
        WHERE   payroll_id = p_payroll_id
	AND	pec.enc_control_id = pel.enc_control_id
	AND     action_code = 'IC');

        -- New cursor for fetching enc_lines_history

        cursor enc_lines_history_cur is
 	SELECT distinct pelh.time_period_id ,
	pelh.encumbrance_date ,
	pelh.dr_cr_flag,
	pelh.encumbrance_amount ,
	pelh.gl_project_flag,
	NVL(pelh.schedule_line_id,-99) ,
	NVL(pelh.org_schedule_id, -99) ,
	NVL(pelh.default_org_account_id, -99),
	NVL(pelh.suspense_org_account_id, -99),
	NVL(pelh.element_account_id, -99) ,
	NVL(pelh.project_id, -99),
	NVL(pelh.task_id, -99) ,
	NVL(pelh.award_id, -99),
	NVL(pelh.expenditure_type, '-99') ,
	NVL(pelh.expenditure_organization_id, -99) ,
	NVL(pelh.gl_code_combination_id, -99),
	pelh.assignment_id,
        NVL(pelh.attribute1,-99),
        NVL(pelh.attribute2,-99),
        NVL(pelh.attribute3,-99),
        NVL(pelh.attribute4,-99),
        NVL(pelh.attribute5,-99),
        NVL(pelh.attribute6,-99),
        NVL(pelh.attribute7,-99),
        NVL(pelh.attribute8,-99),
        NVL(pelh.attribute9,-99),
        NVL(pelh.attribute10,-99)
	FROM	psp_enc_lines_history pelh
	where	pelh.change_flag = 'U'
	AND     payroll_id = p_payroll_id;




     / * Enc of code changes for 3821553 * /



	BEGIN
		l_grouping_option := psp_general.get_enc_dff_grouping_option(p_business_group_id);	-- Introduced for bug fix 2908859

                / * Commenting out this cursor For Bug 3821553
		OPEN new_control_recs;
		LOOP
			FETCH new_control_recs BULK COLLECT INTO l_enc_control_id_tl, l_time_period_id_tl;
			EXIT WHEN new_control_recs%NOTFOUND;
		END LOOP;
		CLOSE new_control_recs;
                 End of Commenting for Bug 3821553 * /

               / * Introduced the following cursor to replace the existing control records cursor * /
               / * Introduced for Bug 3821553 * /
  		OPEN  enc_lines_cur;
                   FETCH enc_lines_cur BULK COLLECT INTO
                   l_time_period_id_tl,l_encumbrance_date_tl,l_dr_cr_flag_tl,l_encumbrance_amount_tl
                   ,l_gl_project_flag_tl,l_schedule_line_id_tl,l_org_schedule_id_tl,l_default_org_account_id_tl,
                   l_suspense_org_account_id_tl,l_element_account_id_tl,l_project_id_tl,l_task_id_tl,l_award_id_tl,
                   l_expenditure_type_tl,l_exp_organization_id_tl,l_gl_code_combination_id_tl,l_assignment_id_tl,
                   l_attribute1_tl,l_attribute2_tl,l_attribute3_tl,l_attribute4_tl,l_attribute5_tl,
                   l_attribute6_tl,l_attribute7_tl,l_attribute8_tl,l_attribute9_tl,l_attribute10_tl;
                 CLOSE  enc_lines_cur;

               / * End of code changes for Bug 3821553 * /



		/ * Following BULK update identifies all newly lines that are unchanged from the
		earlier line created in history. * /
                / * Commenting for  Bug 3821553

		IF (l_grouping_option = 'N') THEN	-- Introduced IF for bug fix 2908859
			FORALL i IN 1 .. l_enc_control_id_tl.COUNT
			UPDATE	psp_enc_lines_history pelh
			SET	change_flag='U'
			WHERE	pelh.assignment_id IN (SELECT	peca.assignment_id
						FROM	psp_enc_changed_assignments peca
						WHERE	peca.payroll_id = p_payroll_id
				--		AND	peca.request_id = g_request_id) commented for bug 2330057
                                        	AND     peca.request_id IS NOT NULL)
			AND	time_period_id = l_time_period_id_tl(i)
			AND	change_flag = 'N'
			AND	EXISTS (SELECT	1
					FROM	psp_enc_lines pel
					WHERE	pel.enc_control_id = l_enc_control_id_tl(i)
					AND	pel.time_period_id = l_time_period_id_tl(i)
					AND	pel.change_flag = 'N'
					AND	pelh.encumbrance_date = pel.encumbrance_date
					AND	pelh.dr_cr_flag = pel.dr_cr_flag
					AND	pelh.encumbrance_amount = pel.encumbrance_amount
					AND	pelh.gl_project_flag = pel.gl_project_flag
					AND	NVL(pelh.schedule_line_id,-99) = NVL(pel.schedule_line_id,-99)
					AND	NVL(pelh.org_schedule_id, -99) = NVL(pel.org_schedule_id, -99)
					AND	NVL(pelh.default_org_account_id, -99) = NVL(pel.default_org_account_id, -99)
					AND	NVL(pelh.suspense_org_account_id, -99) = NVL(pel.suspense_org_account_id, -99)
					AND	NVL(pelh.element_account_id, -99) = NVL(pel.element_account_id, -99)
					AND	NVL(pelh.project_id, -99) = NVL(project_id, -99)
					AND	NVL(pelh.task_id, -99) = NVL(pel.task_id, -99)
					AND	NVL(pelh.award_id, -99) = NVL(pel.award_id, -99)
					AND	NVL(pelh.expenditure_type, '-99') = NVL(pel.expenditure_type, '-99')
					AND	NVL(pelh.expenditure_organization_id, -99) = NVL(pel.expenditure_organization_id, -99)
					AND	NVL(pelh.gl_code_combination_id, -99) = NVL(pel.gl_code_combination_id, -99)
                                	AND     pelh.assignment_id = pel.assignment_id);   ----added for 3230387
			ELSE			-- Introduced ELSE portion for bug fix 2908859
				FORALL i IN 1 .. l_enc_control_id_tl.COUNT
				UPDATE psp_enc_lines_history pelh
				SET	change_flag='U'
				WHERE	pelh.assignment_id IN (SELECT	peca.assignment_id
							FROM	psp_enc_changed_assignments peca
							WHERE	peca.payroll_id = p_payroll_id
							AND	peca.request_id IS NOT NULL)
				AND	time_period_id = l_time_period_id_tl(i)
				AND	change_flag = 'N'
				AND	EXISTS (SELECT 1
						FROM	psp_enc_lines pel
						WHERE	pel.enc_control_id = l_enc_control_id_tl(i)
						AND	pel.time_period_id = l_time_period_id_tl(i)
						AND	pel.change_flag = 'N'
						AND	pelh.encumbrance_date = pel.encumbrance_date
						AND	pelh.dr_cr_flag = pel.dr_cr_flag
						AND	pelh.encumbrance_amount = pel.encumbrance_amount
						AND	pelh.gl_project_flag = pel.gl_project_flag
						AND	NVL(pelh.schedule_line_id,-99) = NVL(pel.schedule_line_id,-99)
						AND	NVL(pelh.org_schedule_id, -99) = NVL(pel.org_schedule_id, -99)
						AND	NVL(pelh.default_org_account_id, -99) = NVL(pel.default_org_account_id, -99)
						AND	NVL(pelh.suspense_org_account_id, -99) = NVL(pel.suspense_org_account_id, -99)
						AND	NVL(pelh.element_account_id, -99) = NVL(pel.element_account_id, -99)
						AND	NVL(pelh.project_id, -99) = NVL(project_id, -99)
						AND	NVL(pelh.task_id, -99) = NVL(pel.task_id, -99)
						AND	NVL(pelh.award_id, -99) = NVL(pel.award_id, -99)
						AND	NVL(pelh.expenditure_type, '-99') = NVL(pel.expenditure_type, '-99')
						AND	NVL(pelh.expenditure_organization_id, -99) = NVL(pel.expenditure_organization_id, -99)
						AND	NVL(pelh.gl_code_combination_id, -99) = NVL(pel.gl_code_combination_id, -99)
						AND	NVL(pelh.attribute_category, 'NULL') = NVL(pel.attribute_category, 'NULL')
						AND	NVL(pelh.attribute1, 'NULL') = NVL(pel.attribute1, 'NULL')
						AND	NVL(pelh.attribute2, 'NULL') = NVL(pel.attribute2, 'NULL')
						AND	NVL(pelh.attribute3, 'NULL') = NVL(pel.attribute3, 'NULL')
						AND	NVL(pelh.attribute4, 'NULL') = NVL(pel.attribute4, 'NULL')
						AND	NVL(pelh.attribute5, 'NULL') = NVL(pel.attribute5, 'NULL')
						AND	NVL(pelh.attribute6, 'NULL') = NVL(pel.attribute6, 'NULL')
						AND	NVL(pelh.attribute7, 'NULL') = NVL(pel.attribute7, 'NULL')
						AND	NVL(pelh.attribute8, 'NULL') = NVL(pel.attribute8, 'NULL')
						AND	NVL(pelh.attribute9, 'NULL') = NVL(pel.attribute9, 'NULL')
						AND	NVL(pelh.attribute10, 'NULL') = NVL(pel.attribute10, 'NULL')
						AND	pelh.assignment_id = pel.assignment_id);
			END IF;

	          End of Commenting for Bug 3821553 * /

                  -- Introduced for Bug 3821553
                  hr_utility.trace('l_grouping_option = '|| l_grouping_option);
                  IF (l_grouping_option = 'N') THEN	-- Introduced IF for bug fix 2908859

                  FORALL i IN 1 .. l_time_period_id_tl.COUNT
                  UPDATE  psp_enc_lines_history pelh
                  SET     change_flag='U'
                  WHERE   time_period_id = l_time_period_id_tl(i)
                  AND     change_flag = 'N'
                  AND     pelh.encumbrance_date = l_encumbrance_date_tl(I)
                  AND     pelh.dr_cr_flag = l_dr_cr_flag_tl(I)
                  AND     pelh.encumbrance_amount = l_encumbrance_amount_tl(I)
                  AND     pelh.gl_project_flag = l_gl_project_flag_tl(I)
                  AND     NVL(pelh.schedule_line_id,-99) = l_schedule_line_id_tl(I)
                  AND     NVL(pelh.org_schedule_id, -99) = l_org_schedule_id_tl(I)
                  AND     NVL(pelh.default_org_account_id, -99) = l_default_org_account_id_tl(I)
                  AND     NVL(pelh.suspense_org_account_id, -99) = l_suspense_org_account_id_tl(I)
                  AND     NVL(pelh.element_account_id, -99) = l_element_account_id_tl(I)
                  AND     NVL(pelh.project_id, -99) = l_project_id_tl(I)
                  AND     NVL(pelh.task_id, -99) = l_task_id_tl(i)
                  AND     NVL(pelh.award_id, -99) = l_award_id_tl(i)
                  AND     NVL(pelh.expenditure_type, '-99') = l_expenditure_type_tl(I)
                  AND     NVL(pelh.expenditure_organization_id, -99) = l_exp_organization_id_tl(i)
                  AND     NVL(pelh.gl_code_combination_id, -99) = l_gl_code_combination_id_tl(i)
                  AND     pelh.assignment_id = l_assignment_id_tl(i);

                 Else

                  FORALL i IN 1 .. l_time_period_id_tl.COUNT
                  UPDATE  psp_enc_lines_history pelh
                  SET     change_flag='U'
                  WHERE   time_period_id = l_time_period_id_tl(i)
                  AND     change_flag = 'N'
                  AND     pelh.encumbrance_date = l_encumbrance_date_tl(I)
                  AND     pelh.dr_cr_flag = l_dr_cr_flag_tl(I)
                  AND     pelh.encumbrance_amount = l_encumbrance_amount_tl(I)
                  AND     pelh.gl_project_flag = l_gl_project_flag_tl(I)
                  AND     NVL(pelh.schedule_line_id,-99) = l_schedule_line_id_tl(I)
                  AND     NVL(pelh.org_schedule_id, -99) = l_org_schedule_id_tl(I)
                  AND     NVL(pelh.default_org_account_id, -99) = l_default_org_account_id_tl(I)
                  AND     NVL(pelh.suspense_org_account_id, -99) = l_suspense_org_account_id_tl(I)
                  AND     NVL(pelh.element_account_id, -99) = l_element_account_id_tl(I)
                  AND     NVL(pelh.project_id, -99) = l_project_id_tl(I)
                  AND     NVL(pelh.task_id, -99) = l_task_id_tl(i)
                  AND     NVL(pelh.award_id, -99) = l_award_id_tl(i)
                  AND     NVL(pelh.expenditure_type, '-99') = l_expenditure_type_tl(I)
                  AND     NVL(pelh.expenditure_organization_id, -99) = l_exp_organization_id_tl(i)
                  AND     NVL(pelh.gl_code_combination_id, -99) = l_gl_code_combination_id_tl(i)
                  AND     pelh.assignment_id = l_assignment_id_tl(i)
                        -- removed nvl on rhs and changed NULL to -99 on lhs for 4072324
                  AND     NVL(pelh.attribute1, '-99') = l_attribute1_tl(i)
		  AND	  NVL(pelh.attribute2, '-99') = l_attribute2_tl(i)
		  AND	  NVL(pelh.attribute3, '-99') = l_attribute3_tl(i)
		  AND	  NVL(pelh.attribute4, '-99') = l_attribute4_tl(i)
		  AND	  NVL(pelh.attribute5, '-99') = l_attribute5_tl(i)
		  AND	  NVL(pelh.attribute6, '-99') = l_attribute6_tl(i)
		  AND	  NVL(pelh.attribute7, '-99') = l_attribute7_tl(i)
		  AND	  NVL(pelh.attribute8, '-99') = l_attribute8_tl(i)
		  AND	  NVL(pelh.attribute9, '-99') = l_attribute9_tl(i)
		  AND	  NVL(pelh.attribute10, '-99') = l_attribute10_tl(i);

                 End if ;


                -- Introduced the following for Bug fix 3821553
		begin
		   FND_STATS.Gather_Table_Stats(ownname => 'PSP',
                                    tabname => 'PSP_ENC_LINES_HISTORY');

      		exception
      		 when others then
        	  null;
      		end;

		/ * If more than one history line are summarized into one summary line, then if any one
 		   of the history line is marked for liquidation then the remaining set of history lines have to be
		   liquidated as their summary line is going to be liquidated (gets superceded). * /


--		FORALL i IN 1 .. l_enc_control_id_tl.COUNT   Commented for Bug 3821553
                FORALL i IN 1 .. l_time_period_id_tl.COUNT -- Introduced for Bug 3821553
		UPDATE	psp_enc_lines_history pelh
		SET	change_flag='N'
		WHERE	enc_summary_line_id in	(SELECT enc_summary_line_id
						FROM	psp_enc_lines_history
						WHERE	change_flag = 'N'
						AND	time_period_id = l_time_period_id_tl(i))
		AND	change_flag='U'
		AND	time_period_id=l_time_period_id_tl(i);

                --- 3953230
                if sql%rowcount > 0 then
                   if g_liquidate_flag is null then
                        g_liquidate_flag := 'Y' ;
                   end if;
                 end if;

                -- Introduced the follwing for bug 3821553


                 l_time_period_id_tl.delete;
                 l_encumbrance_date_tl.delete;
                 l_dr_cr_flag_tl.delete;
                 l_encumbrance_amount_tl.delete;
                 l_gl_project_flag_tl.delete;
                 l_schedule_line_id_tl.delete;
                 l_org_schedule_id_tl.delete;
                 l_default_org_account_id_tl.delete;
                 l_suspense_org_account_id_tl.delete;
                 l_element_account_id_tl.delete;
                 l_project_id_tl.delete;
                 l_task_id_tl.delete;
                 l_award_id_tl.delete;
                 l_expenditure_type_tl.delete;
                 l_exp_organization_id_tl.delete;
                 l_gl_code_combination_id_tl.delete;
                 l_assignment_id_tl.delete;
                 l_attribute1_tl.delete;
                 l_attribute2_tl.delete;
                 l_attribute3_tl.delete;
                 l_attribute4_tl.delete;
                 l_attribute5_tl.delete;
                 l_attribute6_tl.delete;
                 l_attribute7_tl.delete;
                 l_attribute8_tl.delete;
                 l_attribute9_tl.delete;
                 l_attribute10_tl.delete;

                 OPEN  enc_lines_history_cur;
                   FETCH enc_lines_history_cur BULK COLLECT INTO
                   l_time_period_id_tl,l_encumbrance_date_tl,l_dr_cr_flag_tl,l_encumbrance_amount_tl
                   ,l_gl_project_flag_tl,l_schedule_line_id_tl,l_org_schedule_id_tl,l_default_org_account_id_tl,
                   l_suspense_org_account_id_tl,l_element_account_id_tl,l_project_id_tl,l_task_id_tl,l_award_id_tl,
                   l_expenditure_type_tl,l_exp_organization_id_tl,l_gl_code_combination_id_tl,l_assignment_id_tl,
                   l_attribute1_tl,l_attribute2_tl,l_attribute3_tl,l_attribute4_tl,l_attribute5_tl,
                   l_attribute6_tl,l_attribute7_tl,l_attribute8_tl,l_attribute9_tl,l_attribute10_tl;
                 CLOSE  enc_lines_history_cur;


		/ * Delete all those duplicate lines in psp_enc_lines that need not be summarized.	* /
                / * Commenting the code for Bug 3821553
		IF (l_grouping_option = 'N') THEN	-- Introduced IF for bug fix 2908859
			FORALL i IN 1 .. l_enc_control_id_tl.COUNT
			DELETE	psp_enc_lines pel
			WHERE	time_period_id = l_time_period_id_tl(i)
			AND	change_flag = 'N'
			AND	EXISTS	(SELECT	1
					FROM	psp_enc_lines_history pelh
--				WHERE	pelh.enc_control_id = l_enc_control_id_tl(i)
					WHERE	pelh.time_period_id = l_time_period_id_tl(i)
					AND	pelh.change_flag = 'U'
					AND	pelh.encumbrance_date = pel.encumbrance_date
					AND	pelh.dr_cr_flag = pel.dr_cr_flag
					AND	pelh.encumbrance_amount = pel.encumbrance_amount
					AND	pelh.gl_project_flag = pel.gl_project_flag
					AND	NVL(pelh.schedule_line_id,-99) = NVL(pel.schedule_line_id,-99)
					AND	NVL(pelh.org_schedule_id, -99) = NVL(pel.org_schedule_id, -99)
					AND	NVL(pelh.default_org_account_id, -99) = NVL(pel.default_org_account_id, -99)
					AND	NVL(pelh.suspense_org_account_id, -99) = NVL(pel.suspense_org_account_id, -99)
					AND	NVL(pelh.element_account_id, -99) = NVL(pel.element_account_id, -99)
					AND	NVL(pelh.project_id, -99) = NVL(project_id, -99)
					AND	NVL(pelh.task_id, -99) = NVL(pel.task_id, -99)
					AND	NVL(pelh.award_id, -99) = NVL(pel.award_id, -99)
					AND	NVL(pelh.expenditure_type, '-99') = NVL(pel.expenditure_type, '-99')
					AND	NVL(pelh.expenditure_organization_id, -99) = NVL(pel.expenditure_organization_id, -99)
					AND	NVL(pelh.gl_code_combination_id, -99) = NVL(pel.gl_code_combination_id, -99)
                                	AND     pel.assignment_id = pelh.assignment_id);    --- 3230387
			ELSE			-- Introduced ELSE portion for bug fix 2908859
				FORALL i IN 1 .. l_enc_control_id_tl.COUNT
				DELETE psp_enc_lines pel
				WHERE	time_period_id = l_time_period_id_tl(i)
				AND	change_flag = 'N'
				AND	EXISTS (SELECT 1
						FROM	psp_enc_lines_history pelh
						WHERE	pelh.time_period_id = l_time_period_id_tl(i)
						AND	pelh.change_flag = 'U'
						AND	pelh.encumbrance_date = pel.encumbrance_date
						AND	pelh.dr_cr_flag = pel.dr_cr_flag
						AND	pelh.encumbrance_amount = pel.encumbrance_amount
						AND	pelh.gl_project_flag = pel.gl_project_flag
						AND	NVL(pelh.schedule_line_id,-99) = NVL(pel.schedule_line_id,-99)
						AND	NVL(pelh.org_schedule_id, -99) = NVL(pel.org_schedule_id, -99)
						AND	NVL(pelh.default_org_account_id, -99) = NVL(pel.default_org_account_id, -99)
						AND	NVL(pelh.suspense_org_account_id, -99) = NVL(pel.suspense_org_account_id, -99)
						AND	NVL(pelh.element_account_id, -99) = NVL(pel.element_account_id, -99)
						AND	NVL(pelh.project_id, -99) = NVL(project_id, -99)
						AND	NVL(pelh.task_id, -99) = NVL(pel.task_id, -99)
						AND	NVL(pelh.award_id, -99) = NVL(pel.award_id, -99)
						AND	NVL(pelh.expenditure_type, '-99') = NVL(pel.expenditure_type, '-99')
						AND	NVL(pelh.expenditure_organization_id, -99) = NVL(pel.expenditure_organization_id, -99)
						AND	NVL(pelh.gl_code_combination_id, -99) = NVL(pel.gl_code_combination_id, -99)
						AND	NVL(pelh.attribute_category, 'NULL') = NVL(pel.attribute_category, 'NULL')
						AND	NVL(pelh.attribute1, 'NULL') = NVL(pel.attribute1, 'NULL')
						AND	NVL(pelh.attribute2, 'NULL') = NVL(pel.attribute2, 'NULL')
						AND	NVL(pelh.attribute3, 'NULL') = NVL(pel.attribute3, 'NULL')
						AND	NVL(pelh.attribute4, 'NULL') = NVL(pel.attribute4, 'NULL')
						AND	NVL(pelh.attribute5, 'NULL') = NVL(pel.attribute5, 'NULL')
						AND	NVL(pelh.attribute6, 'NULL') = NVL(pel.attribute6, 'NULL')
						AND	NVL(pelh.attribute7, 'NULL') = NVL(pel.attribute7, 'NULL')
						AND	NVL(pelh.attribute8, 'NULL') = NVL(pel.attribute8, 'NULL')
						AND	NVL(pelh.attribute9, 'NULL') = NVL(pel.attribute9, 'NULL')
						AND	NVL(pelh.attribute10, 'NULL') = NVL(pel.attribute10, 'NULL')
						AND	pel.assignment_id = pelh.assignment_id);
			END IF;
                     End of Commenting the code for Bug 3821553 * /

                     -- Introduced the following for Bug 3821553

                     IF (l_grouping_option = 'N') THEN	-- Introduced IF for bug fix 2908859

                       FORALL i IN 1 .. l_time_period_id_tl.COUNT
                       DELETE	psp_enc_lines pel
		       WHERE	time_period_id = l_time_period_id_tl(i)
		       AND	pel.change_flag = 'N'
		       AND	pel.encumbrance_date = l_encumbrance_date_tl(i)
      		       AND	pel.dr_cr_flag = l_dr_cr_flag_tl(i)
		       AND	pel.encumbrance_amount = l_encumbrance_amount_tl(i)
		       AND	pel.gl_project_flag = l_gl_project_flag_tl(i)
		       AND	NVL(pel.schedule_line_id,-99) = l_schedule_line_id_tl(i)
		       AND	NVL(pel.org_schedule_id, -99) = l_org_schedule_id_tl(i)
		       AND	NVL(pel.default_org_account_id, -99) = l_default_org_account_id_tl(i)
		       AND	NVL(pel.suspense_org_account_id, -99) = l_suspense_org_account_id_tl(i)
		       AND	NVL(pel.element_account_id, -99) = l_element_account_id_tl(i)
		       AND	NVL(pel.project_id, -99) = l_project_id_tl(I)
		       AND	NVL(pel.task_id, -99) = l_task_id_tl(i)
		       AND	NVL(pel.award_id, -99) = l_award_id_tl(i)
		       AND	NVL(pel.expenditure_type, '-99') = l_expenditure_type_tl(i)
		       AND	NVL(pel.expenditure_organization_id, -99) = l_exp_organization_id_tl(i)
		       AND	NVL(pel.gl_code_combination_id, -99) = l_gl_code_combination_id_tl(i)
                       AND      pel.assignment_id = l_assignment_id_tl(i);

                     Else

                       FORALL i IN 1 .. l_time_period_id_tl.COUNT
                       DELETE	psp_enc_lines pel
		       WHERE	time_period_id = l_time_period_id_tl(i)
		       AND	pel.change_flag = 'N'
		       AND	pel.encumbrance_date = l_encumbrance_date_tl(i)
      		       AND	pel.dr_cr_flag = l_dr_cr_flag_tl(i)
		       AND	pel.encumbrance_amount = l_encumbrance_amount_tl(i)
		       AND	pel.gl_project_flag = l_gl_project_flag_tl(i)
		       AND	NVL(pel.schedule_line_id,-99) = l_schedule_line_id_tl(i)
		       AND	NVL(pel.org_schedule_id, -99) = l_org_schedule_id_tl(i)
		       AND	NVL(pel.default_org_account_id, -99) = l_default_org_account_id_tl(i)
		       AND	NVL(pel.suspense_org_account_id, -99) = l_suspense_org_account_id_tl(i)
		       AND	NVL(pel.element_account_id, -99) = l_element_account_id_tl(i)
		       AND	NVL(pel.project_id, -99) = l_project_id_tl(I)
		       AND	NVL(pel.task_id, -99) = l_task_id_tl(i)
		       AND	NVL(pel.award_id, -99) = l_award_id_tl(i)
		       AND	NVL(pel.expenditure_type, '-99') = l_expenditure_type_tl(i)
		       AND	NVL(pel.expenditure_organization_id, -99) = l_exp_organization_id_tl(i)
		       AND	NVL(pel.gl_code_combination_id, -99) = l_gl_code_combination_id_tl(i)
                       AND      pel.assignment_id = l_assignment_id_tl(i)
                       -- removed nvl on rhs, not necessary.. for 4072324
                       AND      NVL(pel.attribute1, '-99') = l_attribute1_tl(i)
                       AND	NVL(pel.attribute2, '-99') = l_attribute2_tl(i)
		       AND	NVL(pel.attribute3, '-99') = l_attribute3_tl(i)
		       AND	NVL(pel.attribute4, '-99') = l_attribute4_tl(i)
		       AND	NVL(pel.attribute5, '-99') = l_attribute5_tl(i)
		       AND	NVL(pel.attribute6, '-99') = l_attribute6_tl(i)
		       AND	NVL(pel.attribute7, '-99') = l_attribute7_tl(i)
		       AND	NVL(pel.attribute8, '-99') = l_attribute8_tl(i)
		       AND	NVL(pel.attribute9, '-99') = l_attribute9_tl(i)
		       AND	NVL(pel.attribute10, '-99') = l_attribute10_tl(i);

                     End If ;

                 -- Introduced the following for bug 3821553

                 l_time_period_id_tl.delete;
                 l_encumbrance_date_tl.delete;
                 l_dr_cr_flag_tl.delete;
                 l_encumbrance_amount_tl.delete;
                 l_gl_project_flag_tl.delete;
                 l_schedule_line_id_tl.delete;
                 l_org_schedule_id_tl.delete;
                 l_default_org_account_id_tl.delete;
                 l_suspense_org_account_id_tl.delete;
                 l_element_account_id_tl.delete;
                 l_project_id_tl.delete;
                 l_task_id_tl.delete;
                 l_award_id_tl.delete;
                 l_expenditure_type_tl.delete;
                 l_exp_organization_id_tl.delete;
                 l_gl_code_combination_id_tl.delete;
                 l_assignment_id_tl.delete;
                 l_attribute1_tl.delete;
                 l_attribute2_tl.delete;
                 l_attribute3_tl.delete;
                 l_attribute4_tl.delete;
                 l_attribute5_tl.delete;
                 l_attribute6_tl.delete;
                 l_attribute7_tl.delete;
                 l_attribute8_tl.delete;
                 l_attribute9_tl.delete;
                 l_attribute10_tl.delete;

		----For Bug 2359599 : Deleting the Controls when no lines exists
				DELETE  FROM psp_enc_controls pec
				WHERE   pec.action_type 	IN 	('U','Q')
				AND 	pec.action_code 	=	'IC'
				AND 	pec.payroll_id 		= 	p_payroll_id
				AND 	 NOT EXISTS (	SELECT 	1
							FROM  	psp_enc_lines pel
							WHERE   pel.enc_control_id = pec.enc_control_id);


	l_retcode := FND_API.G_RET_STS_SUCCESS;
	EXCEPTION
		WHEN OTHERS THEN
			g_error_api_path := SUBSTR('VERIFY_CHANGES:'||g_error_api_path,1,230);
	    		fnd_msg_pub.add_exc_msg('PSP_ENC_UPDATE_LINES','VERIFY_CHANGES');
	     		l_retcode := fnd_api.g_ret_sts_unexp_error;
	END verify_changes;

/ *************************************************************************************************
Created By	: ddubey

Date Created By : 19-Dec-2001

Purpose		:
This procedure has been introduced for the Bug 2110930 -Quick Update Encumbrance Enhancement.
The procedure shall be invoked in Q (quick update) or U (update) mode to move the processed
assignments to history

Know limitations, enhancements or remarks

Change History

Who             When            What
ddubey         21-Dec-01       Created
ddubey	       07-Mar-02       Re Engineered the procedure for Enh. Encumbrance Re design
			       Pre process,Bug #2259310.

************************************************************************************************* /
  PROCEDURE  move_qkupd_rec_to_hist( p_payroll_id	 IN	NUMBER,
	   			     p_enc_line_type	 IN	VARCHAR2,
	   			     p_business_group_id IN     NUMBER,
                                     p_set_of_books_id   IN     NUMBER,
				     p_return_status	OUT NOCOPY	VARCHAR2)
  IS
	/ *	Commented the following for big fix 2324917
		Cursor to dislay no of assignments processed by update
  	CURSOR	get_no_asg_to_move IS
	SELECT	COUNT(DISTINCT peca.assignment_id)
	FROM	psp_enc_changed_assignments peca
	WHERE	peca.request_id = g_request_id;

	l_no_of_asg      	NUMBER  DEFAULT  0;	End of bug fix 2324917	* /

	l_global_user_id	NUMBER DEFAULT fnd_global.user_id;
	l_reqid			NUMBER DEFAULT 0;

	BEGIN
		/ * Moving records to psp_enc_changed_asg_history table .Also inserting concurrent request_id
		   into history for debugging purpose * /
		INSERT INTO     psp_enc_changed_asg_history
					(request_id, assignment_id, payroll_id, change_type,processing_module, created_by
					,creation_date, processed_flag, reference_id, action_type)
				SELECT	g_request_id, peca.assignment_id, peca.payroll_id, peca.change_type,
					p_enc_line_type, l_global_user_id, SYSDATE, NULL, NVL(peca.reference_id, 0),
					NVL(peca.action_type, p_enc_line_type)
				FROM	psp_enc_changed_assignments peca
			--	WHERE	peca.request_id = g_request_id; commented as a part of bug 2330057
                              --Following code is added as a part of bug fix 2334434.
                                WHERE   payroll_id =p_payroll_id
                                AND     peca.request_id IS NOT NULL
				AND	(	(p_enc_line_type = 'Q'
						AND	peca.change_type IN ('LS', 'ET', 'AS', 'QU'))
					OR	p_enc_line_type = 'U');

		/ * Deleting records from psp_enc_changed_assignments table  * /
		DELETE		psp_enc_changed_assignments peca
	--	WHERE		peca.request_id	=g_request_id; commented as a part of bug 2330057
		/ * Following code is added for bug 2330057 * /
                WHERE  		peca.payroll_id=p_payroll_id
	        AND	        peca.request_id IS NOT NULL;

		/ *	Introduced the following for bug fix 2324917	* /
		l_reqid := fnd_request.submit_request('PSP', 'PSPENASG', NULL, NULL, NULL, g_request_id);

		/ *	Commented for bug fix 2324917, no message to be displayed in the log
		IF p_enc_line_type ='Q' THEN
			OPEN get_no_asg_to_move;
			FETCH get_no_asg_to_move INTO l_no_of_asg;
			CLOSE get_no_asg_to_move;

			/ * Displaying no of records moved to history in quick update mode * /
			fnd_message.set_name('PSP','PSP_ENC_NUM_ASG');
			fnd_message.set_token('NUM_ASG',l_no_of_asg);
			fnd_msg_pub.add;
			psp_message_s.print_error(p_mode		=>	FND_FILE.LOG,
						  p_print_header	=>	FND_API.G_FALSE);
		END IF;		End of bug fix 2324917	* /

		p_return_status := fnd_api.g_ret_sts_success;

       EXCEPTION
		WHEN OTHERS THEN
     		 g_error_api_path := SUBSTR('MOVE_QKUPD_REC_TO_HIST:'||g_error_api_path,1,230);
     		 fnd_msg_pub.add_exc_msg('PSP_ENC_UPDATE_LINES','MOVE_QKUPD_REC_TO_HIST');
      	 	 p_return_status := fnd_api.g_ret_sts_unexp_error;
      END move_qkupd_rec_to_hist;


/ *************************************************************
The following procedure is added for Enh. Resstart Update Encumbrance process
Created By	: ddubey

Date Created By : 16-Jan-01

Change History

Who             When            What
ddubey         16-jan-2001      Created

**************************************************************** /
procedure cleanup_on_success	( p_enc_line_type in varchar2,
                                  p_payroll_id    in number,
                                  p_business_group_id in number,
                                  p_set_of_books_id in number,
                                  p_invalid_suspense in Varchar2,
                                  p_return_status out NOCOPY varchar2) is

/ ***************************************************************************
For Bug 2359599 : Controls are deleted in the Verify changes procedure
       CURSOR	pending_enc_lines_cur Is
       SELECT	count(*)
       FROM	psp_enc_lines
       WHERE	payroll_id = p_payroll_id
       AND	rownum = 1;
       l_new_line_count integer;
****************************************************************************** /

       l_retcode varchar2(1);
       Begin

       IF       p_enc_line_type IN ('Q', 'U') and p_invalid_suspense = 'N' then
	        -- Restart Update Enc related change.
/ ***************************************************************************
For Bug 2359599 : Controls are deleted in the Verify changes procedure
                OPEN	pending_enc_lines_cur;
		FETCH	pending_enc_lines_cur INTO l_new_line_count;
		CLOSE	pending_enc_lines_cur;


               IF  l_new_line_count=0 then
                   DELETE FROM psp_Enc_controls
                   WHERE action_type = p_enc_line_type
                   AND	 payroll_id  = p_payroll_id
                   AND	 action_code='IC';
               END IF;
*************************************************************************************** /
          -- After liquidation, identify and update the liquidated records and mark the unchanged records to 'N'
          -- to be picked up in a subsequent update run
	  --Modified the Update statement to include the assignment_id check for Bug 2345813
                    UPDATE  psp_enc_lines_history pelh
                    SET     pelh.change_flag='L'
                    WHERE   pelh.change_flag='N'
                    AND     pelh.payroll_id = p_payroll_id
		--  AND	   EXISTS            (SELECT   1  Commented for Bug 3821553
                    and    pelh.assignment_id in (SELECT peca.assignment_id -- Introduced for bug 3821553
                      	  	              FROM    psp_enc_changed_assignments peca
                       		              WHERE   peca.payroll_id = p_payroll_id
--                       		              AND     pelh.assignment_id = peca.assignment_id Commented for Bug 3821553
                       		              AND     peca.request_id IS NOT NULL
          				      AND     ((p_enc_line_type = 'Q'
                                                	AND     peca.change_type IN ('LS', 'ET', 'AS', 'QU'))
                                        		OR      p_enc_line_type = 'U'));

          --update psp_enc_lines_history set change_flag='N' where change_flag='U';
	            UPDATE	psp_enc_lines_history
		    SET  	change_flag = 'N'
   		    WHERE	change_flag = 'U'
		    AND		payroll_id = p_payroll_id;


        / *  IF p_enc_line_type in ('Q', 'U')  THEN     Commented becos this check is alread done above * /
                 move_qkupd_rec_to_hist(p_payroll_id,
                                        p_enc_line_type,
                                        p_business_group_id,
                                        p_set_of_books_id,
					l_retcode);
                          IF  l_retcode <> fnd_api.g_ret_sts_success THEN
                                  g_error_api_path := 'MOVE_QKUPD_REC_TO_HIST:'||g_error_api_path;
                                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          END IF;
          	/ * New code added for restart update process * /
          	 UPDATE psp_enc_controls
          	 SET    action_code = 'N'
          	 WHERE  action_code = 'IC'
          	 AND    payroll_id = p_payroll_id
          	 AND    set_of_books_id = p_set_of_books_id
          	 AND    business_group_id = p_business_group_id;
   	    END IF;
        p_return_status := fnd_api.g_ret_sts_success;
    EXCEPTION
    WHEN OTHERS THEN
                 g_error_api_path := substr('CLEANUP_ON_SUCCESS:'||g_error_api_path,1,230);
                 fnd_msg_pub.add_exc_msg('PSP_ENC_UPDATE_LINES',g_error_api_path);
                 l_retcode := fnd_api.g_ret_sts_unexp_error;
   END cleanup_on_success;

 --- added the procedure for 3473294
PROCEDURE ROLLBACK_REJECTED_ASG (p_payroll_id in integer,
                                 p_action_type in varchar2,
                                 p_gms_batch_name in varchar2,
                                 p_accepted_group_id in integer,
                                 p_rejected_group_id in integer,
                                 p_run_id      in integer,
                                 p_business_group_id in integer,
                                 p_set_of_books_id in integer,
                                 p_return_status out nocopy varchar2) is

        l_global_user_id        NUMBER DEFAULT fnd_global.user_id;
        l_reqid                 NUMBER DEFAULT 0;

   --- update the totals of the new controls, to reflect purging of enc lines
    cursor get_new_control_totals is
    SELECT LINE.enc_control_id,
           count(decode(LINE.dr_cr_flag, 'D', 'x',null))  number_of_dr,
           count(decode(LINE.dr_cr_flag, 'C', 'x', null)) number_of_cr,
           sum(decode(LINE.dr_cr_flag,'D',LINE.encumbrance_amount,0)) total_dr_amount ,
           sum(decode(LINE.dr_cr_flag,'C',LINE.encumbrance_amount,0)) total_cr_amount,
           sum(decode(LINE.dr_cr_flag,'D',decode(LINE.gl_project_flag,'G',LINE.encumbrance_amount,0),0)) gl_dr_amount,
           sum(decode(LINE.dr_cr_flag,'C',decode(LINE.gl_project_flag,'G',LINE.encumbrance_amount,0),0)) gl_cr_amount,
           sum(decode(LINE.dr_cr_flag,'D',decode(LINE.gl_project_flag,'P',LINE.encumbrance_amount,0),0)) ogm_dr_amount,
           sum(decode(LINE.dr_cr_flag,'C',decode(LINE.gl_project_flag,'P',LINE.encumbrance_amount,0),0)) ogm_cr_amount
      FROM  psp_enc_lines LINE
      WHERE LINE.assignment_id in (SELECT assignment_id FROM psp_enc_changed_assignments peca
                                   WHERE peca.payroll_id=p_payroll_id
                                     AND peca.request_id IS NOT NULL
                                     AND (p_action_type = 'U' or  peca.change_type IN ('LS', 'ET', 'AS', 'QU')))
       AND LINE.enc_control_id in (SELECT CTRL2.enc_control_id FROM psp_enc_controls CTRL2
                                    WHERE CTRL2.action_code = 'IC' and CTRL2.payroll_id = p_payroll_id)
      GROUP BY LINE.enc_control_id;

      control_rec get_new_control_totals%rowtype;
begin

  UPDATE psp_enc_lines_history pelh
     SET pelh.change_flag='L'
   WHERE pelh.change_flag='N'
     AND pelh.payroll_id = p_payroll_id
     AND pelh.enc_summary_line_id in
            (select superceded_line_id
               from psp_enc_summary_lines
              where status_code = 'L'
                and ((gms_batch_name is not null  and p_gms_batch_name is not null and gms_batch_name = p_gms_batch_name)
                 or (group_id is not null and p_accepted_group_id is not null and group_id = p_accepted_group_id))
                 and enc_control_id in
                      (select enc_control_id
                         from psp_enc_controls
                        where run_id = p_run_id
                          and action_code in ('P','L')));

    --update psp_enc_lines_history set change_flag='N' where change_flag='U';
    UPDATE psp_enc_lines_history
       SET change_flag = 'N'
     WHERE change_flag = 'U'
       AND payroll_id = p_payroll_id;

  INSERT INTO psp_enc_changed_asg_history
       (request_id, assignment_id, payroll_id, change_type,processing_module, created_by
       ,creation_date, processed_flag, reference_id, action_type)
    SELECT  g_request_id, peca.assignment_id, peca.payroll_id, peca.change_type,
        p_action_type, l_global_user_id, SYSDATE, NULL, NVL(peca.reference_id, 0),
         NVL(peca.action_type, p_action_type)
     FROM psp_enc_changed_assignments peca
     WHERE payroll_id =p_payroll_id
       AND peca.request_id IS NOT NULL
       AND  ((p_action_type = 'Q' AND  peca.change_type IN ('LS', 'ET', 'AS', 'QU'))
             OR  p_action_type = 'U')
       AND peca.assignment_id NOT IN
           (  select distinct assignment_id
              from psp_enc_summary_lines
              where status_code = 'R'
              and ((gms_batch_name is not null  and p_gms_batch_name is not null and gms_batch_name = p_gms_batch_name)
              or (group_id is not null  and p_rejected_group_id is not null and group_id = p_rejected_group_id))
                 and enc_control_id in
                    (select enc_control_id
                     from psp_enc_controls
                      where run_id = p_run_id
                        and action_code in ('P','L')));

    DELETE psp_enc_changed_assignments peca
     WHERE peca.payroll_id=p_payroll_id
       AND peca.request_id IS NOT NULL
       AND  ((p_action_type = 'Q' AND  peca.change_type IN ('LS', 'ET', 'AS', 'QU'))
        OR  p_action_type = 'U')
       AND peca.assignment_id NOT IN
            (select distinct assignment_id
               from psp_enc_summary_lines
              where status_code = 'R'
                and ((gms_batch_name is not null and p_gms_batch_name is not null and gms_batch_name = p_gms_batch_name)
                    or (group_id is not null and  p_rejected_group_id is not null and p_rejected_group_id = group_id))
                and enc_control_id in
                    (select enc_control_id
                     from psp_enc_controls
                      where run_id = p_run_id
                       and action_code in ('P','L')))  ;

   open get_new_control_totals;
   loop
     fetch get_new_control_totals into control_rec;
     if get_new_Control_totals%notfound then
          close get_new_control_totals;
          exit;
     end if;

     update psp_enc_controls
        set number_of_dr= number_of_dr - control_rec.number_of_dr,
            number_of_cr = number_of_cr - control_rec.number_of_cr,
            total_dr_amount= total_dr_amount - control_rec.total_dr_amount,
            total_cr_amount= total_cr_amount - control_rec.total_cr_amount,
            gl_dr_amount = gl_dr_amount -control_rec.gl_dr_amount,
            gl_cr_amount = gl_cr_amount -control_rec.gl_cr_amount,
            ogm_dr_amount= ogm_dr_amount - control_rec.ogm_dr_amount,
            ogm_cr_amount= ogm_cr_amount - control_rec.ogm_cr_amount
       where enc_control_id  = control_rec.enc_control_id;
    end loop;

    DELETE psp_enc_lines LINE
    WHERE  LINE.assignment_id in (SELECT assignment_id FROM psp_enc_changed_assignments peca
                                   WHERE peca.payroll_id=p_payroll_id
                                     AND peca.request_id IS NOT NULL
                                     AND (p_action_type = 'U' or peca.change_type IN ('LS', 'ET', 'AS', 'QU')))
       AND LINE.enc_control_id in (SELECT CTRL2.enc_control_id
                                      FROM psp_enc_controls CTRL2
                                     WHERE  CTRL2.action_code = 'IC' and CTRL2.payroll_id = p_payroll_id);


    DELETE psp_enc_controls CTRL
     WHERE CTRL.action_code = 'IC'
       AND CTRL.payroll_id = p_payroll_id
       AND NOT EXISTS ( SELECT 1
                        FROM psp_enc_lines LINE
                        WHERE LINE.enc_control_id = CTRL.enc_control_id);


                 UPDATE psp_enc_controls
                 SET    action_code = 'N'
                 WHERE  action_code = 'IC'
                 AND    payroll_id = p_payroll_id
                 AND    set_of_books_id = p_set_of_books_id
                 AND    business_group_id = p_business_group_id;

     l_reqid := fnd_request.submit_request('PSP', 'PSPENASG', NULL, NULL, NULL, g_request_id);
        p_return_status := fnd_api.g_ret_sts_success;

exception
   when others then
      fnd_msg_pub.add_exc_msg('PSP_ENC_UPDATE_LINES','ROLLBACK_REJECTED_ASG');
      fnd_msg_pub.add;
end;
	End of comment of for Creatwe and Update multi-thread	*****/
END psp_enc_update_lines;

/
