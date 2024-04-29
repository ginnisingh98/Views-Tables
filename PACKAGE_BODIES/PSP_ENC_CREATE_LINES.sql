--------------------------------------------------------
--  DDL for Package Body PSP_ENC_CREATE_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ENC_CREATE_LINES" AS
/* $Header: PSPENLNB.pls 120.60.12010000.7 2008/11/05 10:20:08 amakrish ship $ */

--For Enh Bug 2259310 -Changed the name of the procedure and
--the parameter from 100_percent_end_date to enc_org_end_Date

  Procedure Obtain_Enc_Org_End_Date
				(
				p_enc_org_end_date 		OUT NOCOPY 	DATE,
				p_business_group_id		IN	NUMBER,
				p_set_of_books_id		IN	NUMBER,
				p_return_status 		OUT NOCOPY 	VARCHAR2);

--For Enh Bug 2259310
--Redefined the parameter listing for the procedure
---Renamed the procedure name from OBTAIN_ENC_PERIOD_EXTN to OBTAIN_ENC_POETA_END_DATE

  Procedure Obtain_Enc_Poeta_End_Date
  			       (p_ls_start_date		IN	DATE,
				p_ls_end_date		IN	DATE,
				p_poeta_end_date	IN	DATE,
				p_enc_end_date		OUT NOCOPY	DATE,
				p_return_status		OUT NOCOPY	VARCHAR2);

PROCEDURE create_lines(	p_assignment_id 	IN NUMBER,
			p_payroll_id 		IN NUMBER,
		        p_element_type_id 	IN NUMBER,
			p_last_paid_date 	IN DATE,
			p_return_status		OUT NOCOPY VARCHAR2);

--For Enh Bug 2259310 -Added new parameters.
  PROCEDURE insert_into_enc_lines(
			L_ENC_ELEMENT_TYPE_ID 		IN 	NUMBER,
			L_ENCUMBRANCE_DATE 		IN 	DATE,
			L_DR_CR_FLAG 			IN 	VARCHAR2,
			L_ENCUMBRANCE_AMOUNT 		IN 	NUMBER,
			L_ENC_LINE_TYPE 		IN 	VARCHAR2,
 			L_SCHEDULE_LINE_ID 		IN 	NUMBER,
			L_ORG_SCHEDULE_ID		IN 	NUMBER,
			L_DEFAULT_ORG_ACCOUNT_ID 	IN 	NUMBER,
        		L_SUSPENSE_ORG_ACCOUNT_ID 	IN 	NUMBER,
			L_ELEMENT_ACCOUNT_ID 		IN 	NUMBER,
        		L_GL_PROJECT_FLAG 		IN 	VARCHAR2,
			L_PERSON_ID 			IN 	NUMBER,
			L_ASSIGNMENT_ID 		IN 	NUMBER,
			L_AWARD_ID 			IN 	NUMBER,
			L_TASK_ID 			IN 	NUMBER,
			L_EXPENDITURE_TYPE 		IN 	VARCHAR2,
			L_EXPENDITURE_ORGANIZATION_ID 	IN 	NUMBER,
			L_PROJECT_ID 			IN	NUMBER,
			L_GL_CODE_COMBINATION_ID 	IN 	NUMBER,
			L_TIME_PERIOD_ID 		IN 	NUMBER,
			L_PAYROLL_ID 			IN 	NUMBER,
			l_business_group_id		IN	NUMBER,
			L_SET_OF_BOOKS_ID 		IN 	NUMBER,
			L_SUSPENSE_REASON_CODE		IN 	VARCHAR2,
        		L_DEFAULT_REASON_CODE 		IN 	VARCHAR2,
                        L_CHANGE_FLAG                   IN      VARCHAR2,
			L_ENC_START_DATE		IN	DATE,	--Added the new parameter
			L_ENC_END_DATE			IN	DATE,	--Added the new parameter
			p_attribute_category		IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
			p_attribute1			IN	VARCHAR2,
			p_attribute2			IN	VARCHAR2,
			p_attribute3			IN	VARCHAR2,
			p_attribute4			IN	VARCHAR2,
			p_attribute5			IN	VARCHAR2,
			p_attribute6			IN	VARCHAR2,
			p_attribute7			IN	VARCHAR2,
			p_attribute8			IN	VARCHAR2,
			p_attribute9			IN	VARCHAR2,
			p_attribute10			IN	VARCHAR2,
			p_orig_gl_code_combination_id	IN	NUMBER,
			p_orig_project_id		IN	NUMBER,
			p_orig_task_id			IN	NUMBER,
			p_orig_award_id			IN	NUMBER,
			p_orig_expenditure_org_id	IN	NUMBER,
			p_orig_expenditure_type		IN	VARCHAR2,
			p_hierarchy_code		IN	VARCHAR2,
			p_return_status 		OUT NOCOPY 	VARCHAR2);

PROCEDURE Create_Controls(p_payroll_action_id		 IN	NUMBER,
			    p_payroll_id		 IN	NUMBER,
			    p_time_period_id		 IN	NUMBER,
			    p_business_group_id		 IN	NUMBER,
			    p_set_of_books_id		 IN  	NUMBER,
			    p_enc_control_id		 OUT NOCOPY	NUMBER,
			    p_return_status		 OUT NOCOPY	VARCHAR2);

TYPE  poeta_gl_hier_rectype IS RECORD
	(
	R_ENC_START_DATE 	DATE,
	R_ENC_END_DATE  	DATE,
	R_AMOUNT		NUMBER,-- Changed Datatype from number(15,2) to number For Bug 2916848
	R_SUSP_FLAG		VARCHAR2(1)  DEFAULT 'N'
	);

r_poeta_gl_hier  	poeta_gl_hier_rectype;
TYPE r_poeta_gl_hier_tab  IS TABLE OF r_poeta_gl_hier%TYPE INDEX BY BINARY_INTEGER;
--t_poeta_gl_hier_array 	r_poeta_gl_hier_tab;

--For Enh Bug 2259310 -Added new Procedures
 Procedure determine_pro_rata_dates ( p_assignment_id		IN	NUMBER,
 			p_ls_start_date		IN	DATE,
 			p_ls_end_date		IN	DATE,
 			p_poeta_start_date	IN	DATE,
 			p_poeta_end_date	IN	DATE,
 			p_asg_start_date	IN	DATE,
 			p_asg_end_date		IN	DATE,
 			p_asg_amount		IN 	NUMBER,
			p_poeta_gl_hier_array		IN OUT NOCOPY 	r_poeta_gl_hier_tab,
 			p_return_status		OUT NOCOPY	VARCHAR2);

 Procedure insert_enc_lines_from_arrays(
 			p_payroll_id		IN	NUMBER,
 			p_business_group_id	IN	NUMBER,
 			p_set_of_books_id	IN	NUMBER,
 			p_enc_line_type		IN	VARCHAR2,
 			p_return_status		OUT NOCOPY	VARCHAR2);

--	Introduced the following for bug fix 3462452
PROCEDURE sub_slice_asg_chunk	(p_assignment_id	IN		NUMBER,
				p_element_type_id	IN		NUMBER,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2);
--	End of bug fix 3462452

PROCEDURE verify_changes(p_payroll_id		IN 	NUMBER,
			 p_assignment_id	IN 	NUMBER,
			 p_business_group_id	IN 	NUMBER,
			 p_set_of_books_id	IN 	NUMBER,
			 p_enc_line_type	IN	VARCHAR2,
			 l_retcode		OUT NOCOPY 	VARCHAR2);

PROCEDURE create_liq_lines	(p_payroll_action_id	IN		NUMBER,
				p_payroll_id		IN		NUMBER,
				p_assignment_id		IN		NUMBER,
				p_enc_begin_date	IN		DATE,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2);

PROCEDURE create_sum_lines	(p_payroll_action_id	IN		NUMBER,
				p_payroll_id		IN		NUMBER,
				p_assignment_id		IN		NUMBER,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2);

PROCEDURE enc_pre_process	(p_payroll_action_id	IN		NUMBER,
				p_payroll_id		IN		NUMBER,
				p_process_mode		IN		VARCHAR2,
				p_return_status		OUT NOCOPY	VARCHAR2);

PROCEDURE load_sch_hierarchy	(p_assignment_id	IN		NUMBER,
				p_payroll_id		IN		NUMBER,
				p_element_type_id	IN		NUMBER,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2);

PROCEDURE	add_cel_warnings(p_start_date	IN	DATE	DEFAULT NULL,
						p_end_date			IN	DATE	DEFAULT NULL,
						p_hierarchy_code	IN	VARCHAR2	DEFAULT NULL,
						p_warning_code		IN	VARCHAR2	DEFAULT NULL,
						p_gl_ccid			IN	NUMBER	DEFAULT NULL,
						p_project_id		IN	NUMBER	DEFAULT NULL,
						p_task_id			IN	NUMBER	DEFAULT NULL,
						p_award_id			IN	NUMBER	DEFAULT NULL,
						p_exp_org_id		IN	NUMBER	DEFAULT NULL,
						p_exp_type			IN	VARCHAR2	DEFAULT NULL,
						p_effective_date	IN	DATE	DEFAULT NULL,
						p_error_status		IN	VARCHAR2	DEFAULT NULL,
						p_percent			IN	NUMBER	DEFAULT NULL);

PROCEDURE	delete_previous_error_log(p_assignment_id	IN	NUMBER,
								p_payroll_id	IN	NUMBER,
								p_payroll_action_id	IN	NUMBER);

PROCEDURE update_hierarchy_dates (p_assignment_id	IN	NUMBER,
					p_payroll_id		IN	NUMBER,
					p_payroll_action_id	IN	NUMBER,
					p_return_status		OUT NOCOPY	VARCHAR2);

PROCEDURE clear_sch_hierarchy;

  -- Define Global Variables
  g_Eff_Date_Value NUMBER;
  g_Org_def_labor_schedule VARCHAR2(3) 	DEFAULT psp_general.get_specific_profile('PSP_DEFAULT_SCHEDULE');
  g_Org_def_account VARCHAR2(3) 	DEFAULT psp_general.get_specific_profile('PSP_DEFAULT_ACCOUNT');
  g_dr_cr_flag VARCHAR2(1);	/*  DEFAULT 'D'; commented for 2530853 */
  g_enc_line_type VARCHAR2(1);
  g_business_group_id NUMBER;
  g_set_of_books_id NUMBER;
  g_error_api_path VARCHAR2(230);
  g_msg VARCHAR2(230);
  g_dr_ctr		NUMBER DEFAULT 0; -- Keep track of no of Dr transactions
  g_cr_ctr		NUMBER DEFAULT 0;  -- Keep track of no of Cr transactions
g_ge_pointer		NUMBER;
g_et_pointer		NUMBER;
g_ec_pointer		NUMBER;
g_asg_pointer		NUMBER;
g_odls_pointer		NUMBER;
g_da_pointer		NUMBER;
g_sa_pointer		NUMBER;
g_error_message		VARCHAR2(4000);
g_warning_message	VARCHAR2(4000);

 -------For Enh Bug 2259310 : Added new variables----------------------------------------
  g_enc_org_end_date	DATE;
  g_enc_lines_counter	NUMBER  DEFAULT 1;
  g_currency_code	PSP_PAYROLL_CONTROLS.CURRENCY_CODE%TYPE; -- For Bug 2916848 Ilo Mrc Ehnc.
  g_precision		NUMBER; -- For Bug 2916848 Ilo Mrc Ehnc.
  g_ext_precision	NUMBER;  -- For Bug  2916848 Ilo Mrc Ehnc.

--	Introduced the following for bug fix 3462452
--g_debug		BOOLEAN		DEFAULT hr_utility.debug_enabled;
g_package_name	VARCHAR2(31) 	DEFAULT 'PSP_ENC_CREATE_LINES.';
--	End of bug fix 3462452

g_dff_grouping_option	CHAR(1);		-- Introduced for bug fix 2908859
g_request_id			NUMBER(15);
g_payroll_action_id		NUMBER(15);
g_actual_term_date		DATE;
g_ge_autopop			VARCHAR2(1);
g_et_autopop			VARCHAR2(1);
g_eg_autopop			VARCHAR2(1);
g_as_autopop			VARCHAR2(1);
g_ds_autopop			VARCHAR2(1);
g_da_autopop			VARCHAR2(1);
g_sa_autopop			VARCHAR2(1);
g_orig_pointer			NUMBER(15);
g_pateo_end_date		DATE;
g_employee_hours		VARCHAR2(1);
g_uom				VARCHAR2(1);
g_exchange_rate_type		VARCHAR2(30);

/******************************************
t_num_15_type 		: Used for declaring array of numbers with width 15. It covers the columns with length 9, 10 and 15.
t_num_10d2_type 	: Used for declaring array of numbers with width (10,2).
t_varchar_50_type	: Used for declaring array of varchar2 with width 50. It covers the columns with length 1, 2, 30 and 50.
t_date_type 		: Used for declaring array of  dates
*******************************************/
TYPE t_num_15_type 	IS TABLE OF NUMBER(15) 		INDEX BY BINARY_INTEGER;
TYPE t_varchar_50_type 	IS TABLE OF VARCHAR2(50) 	INDEX BY BINARY_INTEGER;
TYPE t_varchar_150_type	IS TABLE OF VARCHAR2(150) 	INDEX BY BINARY_INTEGER;	-- Introduced for bug fix 2908859
TYPE t_num_10d2_type 	IS TABLE OF NUMBER	 	INDEX BY BINARY_INTEGER;
-- Changed datatype to Number from number(15,2)of variable  t_num_10d2_type for bug 2916848 Ilo Mrc Ehnc
TYPE t_date_type 	IS TABLE OF DATE 		INDEX BY BINARY_INTEGER;
TYPE t_num_15d2_type	IS TABLE OF NUMBER       	INDEX BY BINARY_INTEGER;
-- Changed datatype to Number from number(15,2)of variable  t_num_15d2_type for bug 2916848 Ilo Mrc Ehnc.

TYPE enc_period_rectype IS RECORD
(
r_period_ind		t_num_15_type,		-- period indicator used for fetching asg chunk start and end date
r_period_start_date 	t_date_type,
r_period_end_date  	t_date_type,
r_asg_start_date	t_date_type,
r_asg_end_date		t_date_type,
r_effective_date		t_date_type,
r_time_period_id	t_num_15_type,
r_process_flag		t_varchar_50_type,	-- Introduced for bug fix 3462452
--	Introduced the following for bug fix 3488734
r_schedule_percent	t_num_15d2_type,		-- balance percent to be posted for this asg chunk
r_encumbrance_amount	t_num_15d2_type,		-- encumbrance amount for that assignment chunk
r_period_amount		t_num_15d2_type,		-- encumbrance amount for that payroll period
r_reason_code		t_varchar_50_type);

r_enc_period  enc_period_rectype;

TYPE r_orig_ci IS RECORD
	(gl_code_combination_id		t_num_15_type,
	project_id			t_num_15_type,
	task_id				t_num_15_type,
	award_id			t_num_15_type,
	expenditure_organization_id	t_num_15_type,
	expenditure_type		t_varchar_50_type);

orig_ci		r_orig_ci;

TYPE  enc_lines_rec_col IS RECORD
	(
	R_ENC_ELEMENT_TYPE_ID 		t_num_15_type,
	R_ENCUMBRANCE_DATE		t_date_type,
	R_DR_CR_FLAG 			t_varchar_50_type,
	R_ENCUMBRANCE_AMOUNT 		t_num_10d2_type,
	R_ENC_LINE_TYPE          	t_varchar_50_type,
	R_SCHEDULE_LINE_ID              t_num_15_type,
	R_ORG_SCHEDULE_ID               t_num_15_type,
	R_DEFAULT_ORG_ACCOUNT_ID        t_num_15_type,
	R_SUSPENSE_ORG_ACCOUNT_ID       t_num_15_type,
	R_ELEMENT_ACCOUNT_ID            t_num_15_type,
	R_GL_PROJECT_FLAG    		t_varchar_50_type,
	R_PERSON_ID                   	t_num_15_type,
	R_ASSIGNMENT_ID         	t_num_15_type,
	R_AWARD_ID                      t_num_15_type,
	R_TASK_ID                       t_num_15_type,
	R_EXPENDITURE_TYPE              t_varchar_50_type,
	R_EXPENDITURE_ORGANIZATION_ID   t_num_15_type,
	R_PROJECT_ID                    t_num_15_type,
	R_GL_CODE_COMBINATION_ID        t_num_15_type,
	R_TIME_PERIOD_ID         	t_num_15_type,
	R_DEFAULT_REASON_CODE           t_varchar_50_type,
	R_SUSPENSE_REASON_CODE          t_varchar_50_type,
	R_ENC_CONTROL_ID      		t_num_15_type,
	R_CHANGE_FLAG                   t_varchar_50_type,
	R_ENC_START_DATE		t_date_type,
	R_ENC_END_DATE			t_date_type,
	r_attribute_category		t_varchar_50_type,		-- Introduced DFF variables for bug fix 2908859
	r_attribute1			t_varchar_150_type,
	r_attribute2			t_varchar_150_type,
	r_attribute3			t_varchar_150_type,
	r_attribute4			t_varchar_150_type,
	r_attribute5			t_varchar_150_type,
	r_attribute6			t_varchar_150_type,
	r_attribute7			t_varchar_150_type,
	r_attribute8			t_varchar_150_type,
	r_attribute9			t_varchar_150_type,
	r_attribute10			t_varchar_150_type,
	r_ORIG_GL_CODE_COMBINATION_ID   t_num_15_type,
	r_ORIG_PROJECT_ID               t_num_15_type,
	r_ORIG_AWARD_ID                 t_num_15_type,
	r_ORIG_TASK_ID                  t_num_15_type,
	r_ORIG_EXPENDITURE_TYPE         t_varchar_50_type,
	r_ORIG_EXPENDITURE_ORG_ID	t_num_15_type,
	r_hierarchy_code		t_varchar_50_type,
	r_hierarchy_start_date		t_date_type,
	r_hierarchy_end_date		t_date_type
	);
	t_enc_lines_array  enc_lines_rec_col;
	t_enc_lines_array2  enc_lines_rec_col;

----For Enh Bug 2259310 Enc Control tab has been converted from array of records to Records of array for using
----bulk binding features of Oracle 8i.

 TYPE ENC_CONTROL_RECTYPE IS RECORD (
	R_TIME_PERIOD_ID		t_num_15_type,
	R_ENC_CONTROL_ID		t_num_15_type,
	R_NO_OF_DR			t_num_15_type,
	R_NO_OF_CR			t_num_15_type,
	R_TOTAL_DR_AMOUNT		t_num_15d2_type,
	R_TOTAL_CR_AMOUNT		t_num_15d2_type,
	R_GL_DR_AMOUNT			t_num_15d2_type,
	R_GL_CR_AMOUNT			t_num_15d2_type,
	R_OGM_DR_AMOUNT			t_num_15d2_type,
	R_OGM_CR_AMOUNT			t_num_15d2_type,
	R_UOM                           t_varchar_50_type);

  ENC_CONTROL_TAB ENC_CONTROL_RECTYPE;

TYPE r_schedule_line_type IS RECORD
	(line_account_id		t_num_15_type,
	gl_code_combination_id		t_num_15_type,
	project_id			t_num_15_type,
	task_id				t_num_15_type,
	award_id			t_num_15_type,
	expenditure_type		t_varchar_150_type,
	expenditure_organization_id	t_num_15_type,
	start_date_active		t_date_type,
	end_date_active			t_date_type,
	poeta_start_date		t_date_type,
	poeta_end_date			t_date_type,
	percent				t_num_10d2_type,
	attribute_category		t_varchar_150_type,
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
	acct_type			t_varchar_150_type);
r_gee		r_schedule_line_type;
r_et		r_schedule_line_type;
r_ec		r_schedule_line_type;
r_asg		r_schedule_line_type;
r_odls		r_schedule_line_type;
r_da		r_schedule_line_type;
r_sa		r_schedule_line_type;

TYPE r_warning_rec IS RECORD
	(start_date	t_date_type,
	end_date	t_date_type,
	hierarchy_code	t_varchar_50_type,
	warning_code	t_varchar_150_type,
	gl_ccid		t_num_15_type,
	project_id	t_num_15_type,
	task_id		t_num_15_type,
	award_id	t_num_15_type,
	exp_org_id	t_num_15_type,
	exp_type	t_varchar_150_type,
	effective_date	t_date_type,
	error_status	t_varchar_150_type,
	percent		t_num_10d2_type);
cel_warnings		r_warning_rec;

/* Following variables are added for bug 2374680 */
  g_assignment_number     VARCHAR2(30);
  g_employee_number       VARCHAR2(30);

/* Following procedure is added for bug 2374680. */
   PROCEDURE Get_assign_number
          (p_assignment_id                IN  NUMBER,
           p_effective_date	          IN  DATE,
           p_assignment_number            OUT NOCOPY VARCHAR2,
           p_employee_number              OUT NOCOPY VARCHAR2 ) IS

  CURSOR assign_num_cur IS
    SELECT paf.assignment_number,
     ppf.employee_number
     FROM
     per_assignments_f paf,per_people_f ppf
     WHERE paf.assignment_id =p_assignment_id
     AND   paf.person_id =ppf.person_id
     AND   p_effective_date between paf.effective_start_date and paf.effective_end_date
     AND   p_effective_date between ppf.effective_start_date and ppf.effective_end_date;

BEGIN
    OPEN assign_num_cur;
    FETCH assign_num_cur INTO p_assignment_number,p_employee_number;
    CLOSE assign_num_cur;

END get_assign_number;

---------------------- O B T A I N  ENC ORG  E N D  D A T E -----------------------

Procedure obtain_enc_org_end_date(	p_enc_org_end_date 		OUT NOCOPY 	DATE,
				      	p_business_group_id		IN	NUMBER,
				      	p_set_of_books_id		IN	NUMBER,
				      	p_return_status 		OUT NOCOPY 	VARCHAR2) IS
/*****************************************************************************
This procedure calculates the 100% time period end date by finding the end date. It
picks the latest date from the table.
The end-date is returned through the OUT variable.
--Added new column peed.enc_end_date_id for Enhancement ENC redesign
--For Bug 2259310 : Changed the name of the procedure and variables and an update statement has been added
As part of the same enhancement the form has been changed. There is no longer organization for which the end date
is obtained.
******************************************************************************/

  CURSOR time_pct_def_cur
  IS
  SELECT peed.period_end_date,
  	 peed.enc_end_date_id,
	NVL(peed.prev_enc_end_date, fnd_date.canonical_to_date('4712/12/31')) prev_enc_end_date
  FROM   psp_enc_end_dates peed
  WHERE
--- removed sysdate check for  Bug fix 2597666
    peed.business_group_id = p_business_group_id
  AND    peed.set_of_books_id   = p_set_of_books_id
  AND	 peed.default_org_flag  = 'Y';

  l_count NUMBER :=0;
--For Enhancement Enc Redesign :Bug 2259310 Added the following variable and cursors
  l_enc_end_date_id  NUMBER;
l_prev_enc_end_date	DATE;

 CURSOR c_cnt_default_org
 IS
 SELECT COUNT(1)
 FROM	psp_enc_end_dates peed
 WHERE
-- removed sysdate check for Bug Fix 2597666
peed.business_group_id = p_business_group_id
 AND	peed.set_of_books_id   = p_set_of_books_id
 AND	peed.default_org_flag= 'Y';


Begin
     p_enc_org_end_date := NULL;
  -- check for Generic Encumbrance Period

	p_return_status := fnd_api.g_ret_sts_success;

  	-- moved the select to Cursor
	OPEN c_cnt_default_org;
	FETCH c_cnt_default_org INTO l_count;
	CLOSE c_cnt_default_org;

	IF l_count = 0 THEN
	 	fnd_message.set_name('PSP', 'PSP_ENC_GEN_PERIOD_NOT_FOUND');
	  	fnd_msg_pub.add;
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	   OPEN time_pct_def_cur;
	   FETCH time_pct_def_cur INTO p_enc_org_end_date, l_enc_end_date_id, l_prev_enc_end_date;
		IF ( time_pct_def_cur%ROWCOUNT> 1) THEN
		  p_enc_org_end_date := NULL;
		  fnd_message.set_name('PSP', 'PSP_ENC_MUL_END_DATES');
		  fnd_msg_pub.add;
			g_error_message := fnd_message.get;
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	   CLOSE time_pct_def_cur;

--For Enhancement Enc Redesign:Bug 2259310 : Updating the Organization End date
	IF (l_prev_enc_end_date <> p_enc_org_end_date) THEN
		UPDATE	psp_enc_end_dates peed
		SET	peed.prev_enc_end_date = p_enc_org_end_date
		WHERE	peed.enc_end_date_id   = l_enc_end_date_id;
	END IF;
Exception

  WHEN OTHERS THEN
	IF (g_error_message IS NULL) THEN
		g_error_message := 'OBTAIN_ENC_ORG_END_DATE: ' || SQLERRM;
	END IF;
	fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', 'OBTAIN_ENC_ORG_END_DATE');
	p_return_status := fnd_api.g_ret_sts_unexp_error;
	return;
End obtain_enc_org_end_date;

---------------------- O B T A I N  E N C  P O E T A E N D D A T E -----------------------
-- Enhancement Enc Redesign : Renamed Obtain_enc_period_extn to Obtain_enc_peota_end_date
-- For Enhancement Enc Redesign :Bug 2259310 : The procedure determines the Encumbrance end date
-- when the CI is POETA, i.e the date
-- till which the POETA shall be encumbered. It is called from the Hierarchies.

Procedure obtain_enc_poeta_end_date (	p_ls_start_date		IN	DATE,
					p_ls_end_date		IN	DATE,
					p_poeta_end_date 	IN	DATE,
					p_enc_end_date		OUT NOCOPY	DATE, --Is used for Enc End date
					p_return_status 	OUT NOCOPY	VARCHAR2
      				    )
IS
l_enc_end_date 	DATE	DEFAULT g_enc_org_end_date;
BEGIN

	/* Enc End date Changes*/
	IF p_ls_start_date <= g_enc_org_end_date THEN
		IF p_ls_end_date <= g_enc_org_end_date	THEN
        		l_enc_end_date:=	g_enc_org_end_date;
		ELSE
			IF p_ls_end_date < p_poeta_end_date THEN
          	 		 l_enc_end_date :=	p_ls_end_date;
			ELSIF p_ls_end_date >=	p_poeta_end_date   AND p_poeta_end_date > g_enc_org_end_date THEN
            			 l_enc_end_date:=	p_poeta_end_date;
           		END IF;
		END IF;
	ELSE
		l_enc_end_date := NULL;
	END IF;
 		--Assigning values to the out parameters
	p_enc_end_date := LEAST(l_enc_end_date, NVL(g_actual_term_date, l_enc_end_date));
	p_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
WHEN OTHERS THEN
	IF (g_error_message IS NULL) THEN
		g_error_message := 'OBTAIN_ENC_POETA_END_DATE: ' || SQLERRM;
	END IF;
        g_error_api_path := SUBSTR(' OBTAIN_ENC_POETA_END_DATE:'||g_error_api_path,1,230);
        fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', ' OBTAIN_ENC_POETA_END_DATE ');
        p_return_status := fnd_api.g_ret_sts_unexp_error;
END obtain_enc_poeta_end_date;




---------------------- D E T E R M I N E  E N C  A M O U N T -----------------------
/***********************************************************************************************
  This procedures calculates the Encumbrance Amount for a particular assignment
  and Earnings Element. The parameters accepted are the Assignment ID and the
  Element_Type_ID and active assignment chunks dates
  that are to be used for calculating the encumbrance amount.
  The function does the following:
    -- Checks if the Element_Type_ID refers to the REGULAR SALARY seeded element.
    -- If it does, then obtain the amount from the Salary Administration (in Oracle Apps)
       window. If there is no amount specified in the salary administration window, then
       proceed to next step. If there is an amount, then it pro-rates the amount to
       the window period of the active assignment chunk dates.
    -- If the earnings element is not REGULAR SALARY, then call the userhook. Whatever
       amount is returned by userhook is considered as the pro-rated amount for the
       assignment dates.
   --IF no amount is returned by the userhook then go to the Element
     entries window (in Oracle Apps). Obtain the amount specified against
     the earnings element and then it pro-rates the amount to
     the window period of the active assignment chunk dates.

Logic for Regular Salary element:
  -- First, I will check if the element has a value in the PER_PAY_PROPOSALS.
  -- If it does, then I will return the encumbrance amount on a per payroll period basis.
  -- If the amount has not been defined, then I will look into the PAY_PAYWSMEE_ELEMENT_ENTRIES
  -- table to obtain the amount.

 -- Obtain the number of pay periods in a fiscal year. This will then be used to divide the
 -- annual salary to arrive at the salary per pay period.

-- Salary information present and the number of periods per fiscal year is greater than zero.
-- Hence, calculate the amount per pay period.
-- When the proposed salary is an hourly wage. Multiply this by 8 hours a day, 5 days a week, and 48 weeks in a year
--For Enhancement Enc Redesign, Bug 2259310, Prorating the Amount
********************************************************************************************************/

--	Implemented the following logic for determine_enc_amount procedure as part of bug fix 3488734
PROCEDURE determine_enc_amount	(p_person_id		IN NUMBER,
				p_assignment_id		IN NUMBER,
				p_element_type_id	IN NUMBER,
				p_payroll_id		IN NUMBER,
				p_business_group_id	IN NUMBER,
				p_set_of_books_id	IN NUMBER,
				p_return_status		OUT NOCOPY VARCHAR2) IS

TYPE salary_proposal_rectype IS RECORD
	(r_change_date			t_date_type,
	r_proposed_salary		t_num_15d2_type,
	r_pay_basis			t_varchar_50_type,
	r_pay_annualization_factor	t_num_15_type,
	r_effective_start_date		t_date_type,
	r_effective_end_date		t_date_type);

r_salary_proposal		salary_proposal_rectype;

TYPE element_entry_rectype IS RECORD
	(r_element_start_date	t_date_type,
	r_element_end_date	t_date_type,
	r_pay_amount		t_num_15d2_type);

r_element_entry		element_entry_rectype;

l_min_start_date	DATE	DEFAULT r_enc_period.r_asg_start_date(1);
l_max_end_date		DATE	DEFAULT r_enc_period.r_asg_end_date(r_enc_period.r_asg_end_date.COUNT);

--	Introduced the following for bug fix 3673723
TYPE element_period_amount IS RECORD
	(r_time_period_id		t_num_15_type,
	r_period_amount			t_num_15d2_type);

r_element_period_amount	element_period_amount;

CURSOR	element_period_amount_cur IS
SELECT	time_period_id,
	SUM(period_amount)
FROM	(SELECT ((MAX(fnd_number.canonical_to_number(NVL(peev.screen_entry_value, 0))) *
			SUM(psp_general.business_days(	GREATEST(ptp.start_date, paf.effective_start_date, peev.effective_start_date),
							LEAST(ptp.end_date, paf.effective_end_date, peev.effective_end_date),p_assignment_id)) ) /
			DECODE(psp_general.business_days(MAX(ptp.start_date), MAX(ptp.end_date),p_assignment_id), 0, 1,
					psp_general.business_days(MAX(ptp.start_date), MAX(ptp.end_date),p_assignment_id)) ) period_amount,
		ptp.time_period_id
	FROM	pay_element_entry_values_f peev,
		pay_input_values_f piv,
		pay_element_entries_f pee,
		pay_element_links_f pel,
		pay_element_types_f pet,
		psp_enc_elements peel,
		per_assignments_f paf,
		per_assignment_status_types past,
		per_time_periods ptp
	WHERE	peev.element_entry_id		=	pee.element_entry_id
	AND	peev.effective_start_date	<=	paf.effective_end_date
	AND	peev.effective_end_date		>=	paf.effective_start_date
	AND	pel.element_link_id		=	pee.element_link_id
	AND	pel.element_type_id		=	p_element_type_id
	AND	pel.effective_start_date	<=	paf.effective_end_date
	AND	pel.effective_end_date		>=	paf.effective_start_date
	AND	pet.effective_start_date	<=	paf.effective_end_date
	AND	pet.effective_end_date		>=	paf.effective_start_date
	AND	pee.assignment_id		=	p_assignment_id
	AND	pee.effective_start_date	<=	paf.effective_end_date
	AND	pee.effective_end_date		>=	paf.effective_start_date
	AND	peev.input_value_id		=	piv.input_value_id
	AND	piv.input_value_id		=	peel.input_value_id
	AND	pet.element_type_id		=	p_element_type_id
	AND	piv.effective_start_date	<=	paf.effective_end_date
	AND	piv.effective_end_date		>=	paf.effective_start_date
	AND	piv.effective_start_date	<=	peev.effective_end_date
	AND	piv.effective_end_date		>=	peev.effective_start_date
	AND	pee.effective_start_date	<=	peev.effective_end_date
	AND	pee.effective_end_date		>=	peev.effective_start_date
	AND	ptp.start_date			<=	paf.effective_end_date
	AND	ptp.end_date			>=	paf.effective_start_date
	AND	pel.effective_start_date	<=	pee.effective_end_date
	AND	pel.effective_end_date		>=	pee.effective_start_date
	AND	pet.effective_start_date	<=	pel.effective_end_date
	AND	pet.effective_end_date		>=	pel.effective_start_date
	AND	paf.assignment_id		=	p_assignment_id
	AND	paf.effective_start_date	<=	l_max_end_date
	AND	paf.effective_end_date		>=	l_min_start_date
	AND	past.assignment_status_type_id	=	paf.assignment_status_type_id
	AND	past.per_system_status		=	'ACTIVE_ASSIGN'
	AND	pel.business_group_id		=	p_business_group_id
	AND	peel.business_group_id		=	p_business_group_id
	AND	peel.set_of_books_id		=	p_set_of_books_id
	AND	ptp.payroll_id			=	p_payroll_id
	AND	ptp.time_period_id		>=	r_enc_period.r_time_period_id(1)
        AND     SUBSTR(piv.uom, 1, 1)		=	g_uom
	GROUP BY ptp.time_period_id,
		peev.effective_start_date,
		peev.effective_end_date)
GROUP BY time_period_id;
--	End of changes for bug fix 3673723

CURSOR get_proposal_salary_csr IS
SELECT	ppp.change_date,
	ppp.proposed_salary_n proposed_salary,
	NVL(ppb.pay_basis, ' ') pay_basis,
	ppb.pay_annualization_factor,
	paf.effective_start_date,
	paf.effective_end_date
FROM	per_pay_proposals ppp,
	pay_input_values_f piv,
	per_pay_bases ppb,
	per_all_assignments_f paf,
	per_assignment_status_types past
WHERE	paf.assignment_id =p_assignment_id
AND	(	ppp.change_date BETWEEN paf.effective_start_date AND paf.effective_end_date
	OR	ppp.change_date =	(SELECT	MAX(ppp1.change_date)
					FROM	per_pay_proposals ppp1
					WHERE	ppp1.assignment_id = p_assignment_id
					AND	ppp1.approved = 'Y'
					AND	ppp1.change_date <= paf.effective_start_date))
AND	paf.pay_basis_id = ppb.pay_basis_id
AND	ppp.assignment_id = p_assignment_id
AND     past.assignment_status_type_id = paf.assignment_status_type_id
AND	past.per_system_status = 'ACTIVE_ASSIGN'
AND	piv.element_type_id +0 = p_element_type_id
AND	ppp.approved = 'Y'
AND	((ppp.change_date >= (SELECT	NVL(MAX(ppp1.change_date), l_min_start_date)
				FROM	per_pay_proposals ppp1
				WHERE	ppp1.assignment_id = p_assignment_id
				AND	ppp1.approved = 'Y'
				AND	ppp1.change_date <= l_min_start_date))
AND	(ppp.change_date <=	(SELECT	NVL(MIN(ppp1.change_date), l_max_end_date + 1)
					FROM	per_pay_proposals ppp1
					WHERE	ppp1.assignment_id = p_assignment_id
					AND	ppp1.approved = 'Y'
					AND	ppp1.change_date >= l_max_end_date)))
AND	ppb.input_value_id = piv.input_value_id
AND	ppp.change_date BETWEEN piv.effective_start_date AND piv.effective_end_date
ORDER BY paf.effective_end_date DESC, ppp.change_date DESC;

CURSOR	get_no_per_fiscal_year_csr IS
SELECT	number_per_fiscal_year
FROM	per_time_period_types ptpt
WHERE	period_type = (SELECT	ppf.period_type
			FROM	pay_payrolls_f ppf
			WHERE	ppf.payroll_id = p_payroll_id
/* Added for Bug 3869766 */
			AND	rownum = 1);

CURSOR	get_element_entry IS
SELECT	DISTINCT GREATEST(paf.effective_start_date, peev.effective_start_date) element_start_date,
	LEAST(paf.effective_end_date, peev.effective_end_date) element_end_date,
	fnd_number.canonical_to_number(NVL(peev.screen_entry_value, 0)) pay_amount
FROM	pay_element_entry_values_f peev,
	pay_input_values_f piv,
	pay_element_entries_f pee,
	pay_element_links_f pel,
	pay_element_types_f pet,
	psp_enc_elements peel,
	per_assignments_f paf,
	per_assignment_status_types past
WHERE	peev.element_entry_id		=	pee.element_entry_id
AND	peev.effective_start_date	<=	paf.effective_end_date
AND	peev.effective_end_date		>=	paf.effective_start_date
AND	pel.element_link_id		=	pee.element_link_id
AND	pel.element_type_id		=	p_element_type_id
AND	pel.effective_start_date	<=	paf.effective_end_date
AND	pel.effective_end_date		>=	paf.effective_start_date
AND	pet.effective_start_date	<=	paf.effective_end_date
AND	pet.effective_end_date		>=	paf.effective_start_date
AND	pee.assignment_id		=	p_assignment_id
AND	pee.effective_start_date	<=	paf.effective_end_date
AND	pee.effective_end_date		>=	paf.effective_start_date
AND	peev.input_value_id		=	piv.input_value_id
AND	piv.input_value_id		=	peel.input_value_id
AND	pet.element_type_id		=	p_element_type_id
AND	piv.effective_start_date	<=	paf.effective_end_date
AND	piv.effective_end_date		>=	paf.effective_start_date
AND	piv.effective_start_date	<=	peev.effective_end_date
AND	piv.effective_end_date		>=	peev.effective_start_date
AND	pee.effective_start_date	<=	peev.effective_end_date
AND	pee.effective_end_date		>=	peev.effective_start_date
AND	pel.effective_start_date	<=	pee.effective_end_date
AND	pel.effective_end_date		>=	pee.effective_start_date
AND	pet.effective_start_date	<=	pel.effective_end_date
AND	pet.effective_end_date		>=	pel.effective_start_date
AND	paf.assignment_id		=	p_assignment_id
AND	paf.effective_start_date	<=	l_max_end_date
AND	paf.effective_end_date		>=	l_min_start_date
AND     past.assignment_status_type_id	=	paf.assignment_status_type_id
AND	past.per_system_status		=	'ACTIVE_ASSIGN'
AND	SUBSTR(piv.uom, 1, 1)		=	g_uom
AND	pel.business_group_id		=	p_business_group_id
AND	peel.business_group_id		=	p_business_group_id
AND	peel.set_of_books_id		=	p_set_of_books_id ;

CURSOR	get_input_formula_cur IS
SELECT	NVL(input_value_id, -1),
		formula_id
FROM	psp_enc_elements pee
WHERE	element_type_id = p_element_type_id
AND	(	formula_id IS NOT NULL
	OR	EXISTS	(SELECT	1
			FROM	pay_input_values_f piv
			WHERE	piv.input_value_id = pee.input_value_id
			AND	SUBSTR(piv.uom, 1, 1) = g_uom));

l_num_per_fiscal_year		NUMBER;
l_time_period_id		NUMBER;
l_enc_amount			NUMBER;
l_pay_amount			NUMBER;
l_period_enc_amount		NUMBER;
l_element_start_date		DATE;
l_element_end_date		DATE;
l_start_date			DATE;
l_end_date			DATE;
l_period_start_date		DATE;
l_period_end_date		DATE;
l_asg_start_date		DATE;
l_asg_end_date			DATE;
l_bus_working_days		NUMBER DEFAULT 0;
l_bus_days_in_sched		NUMBER DEFAULT 0;
l_temp_salary			NUMBER DEFAULT 0;
l_change_date			DATE;
l_inputs			ff_exec.inputs_t;
l_outputs			ff_exec.outputs_t;
l_input_value_id		NUMBER(15);
l_formula_id			NUMBER(15);

--	Introduced for bug fix 3551561
l_change_end_date		DATE	DEFAULT fnd_date.canonical_to_date('4712/12/31');
l_prev_change_end_date		DATE;
l_prev_change_date		DATE;
--	End of bug fix 3551561
l_annualization_factor		NUMBER;
l_pay_basis			VARCHAR2(30);
l_prev_time_period_id		NUMBER DEFAULT -1;
l_period_counter		NUMBER;		-- Introduced for bug fix 3673723
l_tmp_counter			NUMBER;
l_calculate_period_amt		BOOLEAN;
l_effective_date		DATE;

DIVIDE_BY_ZERO EXCEPTION;

l_proc_name		VARCHAR2(61) DEFAULT g_package_name || 'DETERMINE_ENC_AMOUNT';
l_proc_step		NUMBER(20, 10);

t_ff_start_date		t_date_type;
t_ff_end_date		t_date_type;

CURSOR	formula_date_cur IS
SELECT	GREATEST(pee.effective_start_date, paf.effective_start_date, ff.effective_start_date) start_date,
	LEAST(pee.effective_end_date, paf.effective_end_date, ff.effective_end_date) end_date
FROM	ff_formulas_f ff,
	per_assignments_f paf,
	pay_element_entries_f pee
WHERE	formula_id = l_formula_id
AND	paf.assignment_id = p_assignment_id
AND	pee.assignment_id = p_assignment_id
AND	pee.element_type_id = p_element_type_id
AND	paf.effective_start_date <= l_max_end_date
AND	paf.effective_end_date >= l_min_start_date
AND	pee.effective_start_date <= l_max_end_date
AND	pee.effective_end_date >= l_min_start_date
AND	ff.effective_start_date <= l_max_end_date
AND	ff.effective_end_date >= l_min_start_date
AND	paf.effective_start_date <= pee.effective_end_date
AND	paf.effective_end_date >= pee.effective_start_date
AND	paf.effective_start_date <= ff.effective_end_date
AND	paf.effective_end_date >= ff.effective_start_date
AND	pee.effective_start_date <= ff.effective_end_date
AND	pee.effective_end_date >= ff.effective_start_date;

BEGIN
	l_proc_step:= 10;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Entering ' || l_proc_name);
	hr_utility.trace('p_assignment_id: ' || fnd_number.number_to_canonical(p_assignment_id) ||
		' p_element_type_id: ' || fnd_number.number_to_canonical(p_element_type_id) ||
		' p_payroll_id: ' || fnd_number.number_to_canonical(p_payroll_id) ||
		' p_business_group_id: ' || fnd_number.number_to_canonical(p_business_group_id) ||
		' p_set_of_books_id: ' || fnd_number.number_to_canonical(p_set_of_books_id) ||
		' l_bus_working_days: ' || fnd_number.number_to_canonical(l_bus_working_days) ||
		' r_enc_period.r_time_period_id.COUNT: ' || fnd_number.number_to_canonical(r_enc_period.r_time_period_id.COUNT));

	IF (r_enc_period.r_time_period_id.COUNT = 0) THEN
		RETURN;
	END IF;

	l_proc_step:= 20;
	l_calculate_period_amt := TRUE;

	OPEN get_input_formula_cur;
	FETCH get_input_formula_cur INTO l_input_value_id, l_formula_id;
	CLOSE get_input_formula_cur;

	IF (l_formula_id IS NOT NULL) THEN
		OPEN formula_date_cur;
		FETCH formula_date_cur BULK COLLECT INTO t_ff_start_date, t_ff_end_date;
		CLOSE formula_date_cur;

		hr_utility.trace('t_ff_start_date.COUNT: ' || t_ff_start_date.COUNT);
	END IF;

	OPEN get_no_per_fiscal_year_csr;
	FETCH get_no_per_fiscal_year_csr INTO l_num_per_fiscal_year;
	IF get_no_per_fiscal_year_csr%NOTFOUND THEN
		l_num_per_fiscal_year := 0;
	END IF;
	CLOSE get_no_per_fiscal_year_csr;

	l_proc_step:= 30;

	OPEN get_proposal_salary_csr;
	FETCH get_proposal_salary_csr BULK COLLECT INTO r_salary_proposal.r_change_date, r_salary_proposal.r_proposed_salary,
			r_salary_proposal.r_pay_basis, r_salary_proposal.r_pay_annualization_factor,
			r_salary_proposal.r_effective_start_date, r_salary_proposal.r_effective_end_date;
	CLOSE get_proposal_salary_csr;

	l_proc_step:= 40;

	OPEN get_element_entry;
	FETCH get_element_entry BULK COLLECT INTO r_element_entry.r_element_start_date, r_element_entry.r_element_end_date,
			r_element_entry.r_pay_amount;
	CLOSE get_element_entry;

	l_proc_step:= 50;

	hr_utility.trace('l_num_per_fiscal_year: ' || fnd_number.number_to_canonical(l_num_per_fiscal_year) ||
		' r_salary_proposal.r_change_date.COUNT: ' || fnd_number.number_to_canonical(r_salary_proposal.r_change_date.COUNT) ||
		' r_element_entry.r_element_start_date.COUNT: ' || fnd_number.number_to_canonical(r_element_entry.r_element_start_date.COUNT));
	hr_utility.trace('Calculating Assignment Chunk Amounts...');

	FOR I IN 1..r_enc_period.r_time_period_id.COUNT
	LOOP
		IF (r_enc_period.r_process_flag(I) <> 'I') THEN
			l_period_start_date := r_enc_period.r_period_start_date(I);
			l_period_end_date := r_enc_period.r_period_end_date(I);
			l_asg_start_date := r_enc_period.r_asg_start_date(I);
			l_asg_end_date := r_enc_period.r_asg_end_date(I);
			l_end_date := l_asg_end_date;
			l_bus_working_days := psp_general.business_days(l_period_start_date, l_period_end_date,p_assignment_id);
			l_enc_amount := 0;
			l_proc_step:= 60 + (I / 100000);

			hr_utility.trace('I: ' || fnd_number.number_to_canonical(I) ||
				' l_period_start_date: ' || fnd_date.date_to_canonical(l_period_start_date) ||
				' l_period_end_date: ' || fnd_date.date_to_canonical(l_period_end_date) ||
				' l_asg_start_date: ' || fnd_date.date_to_canonical(l_asg_start_date) ||
				' l_asg_end_date: ' || fnd_date.date_to_canonical(l_asg_end_date) ||
				' l_bus_working_days: ' || fnd_number.number_to_canonical(l_bus_working_days));

			IF (l_bus_working_days = 0) THEN
				fnd_message.set_name('PSP', 'PSP_ENC_ZERO_WORK_DAYS_PERIOD');
				fnd_message.set_token('START_DATE', l_period_start_date);
				fnd_message.set_token('END_DATE', l_period_end_date);
				g_error_message := fnd_message.get;
				RAISE DIVIDE_BY_ZERO;
			END IF;

			l_enc_amount := psp_st_ext.get_enc_amount (p_assignment_id	=>	p_assignment_id,
									p_element_type_id		=>	p_element_type_id,
									p_time_period_id		=>	r_enc_period.r_time_period_id(I),
									p_asg_start_date		=>	l_asg_start_date,
									p_asg_end_date		=>	l_asg_end_date);
			hr_utility.trace('l_enc_amount: ' || fnd_number.number_to_canonical(l_enc_amount));

			IF (l_enc_amount = 0) THEN
				IF (l_formula_id IS NOT NULL) THEN
					IF (	(t_ff_start_date.COUNT > 0) AND
						(l_asg_start_date <= t_ff_end_date(t_ff_end_date.COUNT)) AND
						(l_asg_end_date >= t_ff_start_date(1))) THEN
						FOR ff_recno IN 1..t_ff_start_date.COUNT
						LOOP
							l_asg_start_date := r_enc_period.r_asg_start_date(I);
							l_asg_end_date := r_enc_period.r_asg_end_date(I);
							hr_utility.trace('l_asg_start_date: ' || l_asg_start_date || ' l_asg_end_date: ' || l_asg_end_date || ' t_ff_start_date(ff_recno): ' || t_ff_start_date(ff_recno) || ' t_ff_end_date(ff_recno): ' || t_ff_end_date(ff_recno));
							IF l_asg_start_date <= t_ff_end_date(ff_recno) AND
								l_asg_end_date >= t_ff_start_date(ff_recno) THEN
								l_asg_start_date := GREATEST(l_asg_start_date, t_ff_start_date(ff_recno));
								l_asg_end_date := LEAST(l_asg_end_date, t_ff_end_date(ff_recno));
								l_inputs.DELETE;
								l_outputs.DELETE;

								ff_exec.init_formula(l_formula_id, l_asg_start_date, l_inputs,l_outputs);
								hr_utility.trace('Initiated Formula l_asg_start_date: ' || fnd_date.date_to_canonical(l_asg_start_date) || ' l_asg_end_date: ' || fnd_date.date_to_canonical(l_asg_end_date));

								hr_utility.trace('l_inputs.COUNT: ' || l_inputs.COUNT);
								FOR recno IN 1..l_inputs.COUNT
								LOOP
									IF (l_inputs(recno).name ='PERSON_ID') THEN
										l_inputs(recno).value := fnd_number.number_to_canonical(p_person_id);
										hr_utility.trace('Assigned person_id');
									ELSIF (l_inputs(recno).name ='ASSIGNMENT_ID') THEN
										l_inputs(recno).value := fnd_number.number_to_canonical(p_assignment_id);
										hr_utility.trace('Assigned assignment_id');
									ELSIF l_inputs(recno).name='ELEMENT_TYPE_ID' THEN
										l_inputs(recno).value := fnd_number.number_to_canonical(p_element_type_id);
										hr_utility.trace('Assigned element_type_id');
									ELSIF l_inputs(recno).name='PAYROLL_ID' THEN
										l_inputs(recno).value := fnd_number.number_to_canonical(p_payroll_id);
										hr_utility.trace('Assigned payroll_id');
									ELSIF l_inputs(recno).name='TIME_PERIOD_ID' THEN
										l_inputs(recno).value := fnd_number.number_to_canonical(r_enc_period.r_time_period_id(I));
										hr_utility.trace('Assigned time_period_id');
									ELSIF l_inputs(recno).name='ASG_START_DATE' THEN
										l_inputs(recno).value := fnd_date.date_to_canonical(l_asg_start_date);
										hr_utility.trace('Assigned asg_start_date');
									ELSIF l_inputs(recno).name='ASG_END_DATE' THEN
										l_inputs(recno).value := fnd_date.date_to_canonical(l_asg_end_date);
										hr_utility.trace('Assigned asg_end_date');
									ELSIF l_inputs(recno).name='BUS_DAYS_IN_CHUNK' THEN
										l_inputs(recno).value := fnd_number.number_to_canonical(psp_general.business_days(l_asg_start_date, l_asg_end_date,p_assignment_id));
										hr_utility.trace('Assigned business days in chunk');
									ELSIF l_inputs(recno).name='PERIOD_START_DATE' THEN
										l_inputs(recno).value := fnd_date.date_to_canonical(l_period_start_date);
										hr_utility.trace('Assigned period_start_date');
									ELSIF l_inputs(recno).name='PERIOD_END_DATE' THEN
										l_inputs(recno).value := fnd_date.date_to_canonical(l_period_end_date);
										hr_utility.trace('Assigned period_end_date');
									ELSIF l_inputs(recno).name='BUS_DAYS_IN_PERIOD' THEN
										l_inputs(recno).value := fnd_number.number_to_canonical(psp_general.business_days(l_period_start_date, l_period_end_date,p_assignment_id));
										hr_utility.trace('Assigned business days in period');
									ELSIF l_inputs(recno).name='UOM' THEN
										l_inputs(recno).value := g_uom;
										hr_utility.trace('Assigned UOM');

									END IF;
								END LOOP;

								hr_utility.trace('Before executing fast formula');
								ff_exec.run_formula(l_inputs, l_outputs);
								l_enc_amount := l_enc_amount + fnd_number.canonical_to_number(l_outputs(1).value);   -- Bug 7536024
								hr_utility.trace('After executing fast formula; l_enc_amount: ' || l_enc_amount);
							END IF;
						END LOOP;
					END IF;
					l_calculate_period_amt := FALSE;
					l_proc_step:= 90;
				ELSE
					IF (psp_general.business_days(l_asg_start_date, l_asg_end_date,p_assignment_id) > 0) THEN
						FOR J IN 1..r_salary_proposal.r_change_date.COUNT
						LOOP
							IF (l_asg_start_date <= r_salary_proposal.r_effective_end_date(J) AND
								l_asg_end_date >= r_salary_proposal.r_effective_start_date(J)) THEN
								l_change_date := r_salary_proposal.r_change_date(J);
								l_end_date := LEAST(l_end_date, l_asg_end_date);
								l_temp_salary := r_salary_proposal.r_proposed_salary(J);
								l_annualization_factor := r_salary_proposal.r_pay_annualization_factor(J);
								l_pay_basis := r_salary_proposal.r_pay_basis(J);
								l_proc_step:= 70 + (J / 100000);

								hr_utility.trace('J: ' || fnd_number.number_to_canonical(J) ||
									' l_change_date: ' || fnd_date.date_to_canonical(l_change_date) ||
									' l_temp_salary: ' || fnd_number.number_to_canonical(l_temp_salary) ||
									' l_annualization_factor: ' || fnd_number.number_to_canonical(l_annualization_factor) ||
									' l_pay_basis: ' || l_pay_basis);

								IF (l_change_date <= l_end_date) THEN
									IF (l_num_per_fiscal_year <> 0 AND (l_pay_basis IN ('ANNUAL','MONTHLY','HOURLY'))) THEN
										l_temp_salary := round((l_temp_salary * l_annualization_factor / l_num_per_fiscal_year), g_ext_precision);
									END IF;

									l_start_date := GREATEST(l_change_date, l_asg_start_date);
									l_bus_days_in_sched := NVL(PSP_GENERAL.BUSINESS_DAYS(l_start_date, l_end_date,p_assignment_id), 0);
									l_enc_amount := l_enc_amount + ROUND(((l_temp_salary * l_bus_days_in_sched) / ( l_bus_working_days )), g_ext_precision);

									hr_utility.trace('l_start_date: ' || fnd_date.date_to_canonical(l_start_date) ||
										' l_end_date: ' || fnd_date.date_to_canonical(l_end_date) ||
										' l_bus_days_in_sched: ' || fnd_number.number_to_canonical(l_bus_days_in_sched) ||
										' l_enc_amount: ' || fnd_number.number_to_canonical(l_enc_amount));

									l_end_date := GREATEST(l_start_date, l_change_date) - 1;

									EXIT WHEN l_change_date < l_asg_start_date;
								END IF;
							END IF;
						END LOOP;

						l_proc_step:= 80;

						IF l_enc_amount = 0 THEN
							FOR J IN 1..r_element_entry.r_element_start_date.COUNT
							LOOP
								l_element_start_date := r_element_entry.r_element_start_date(J);
								l_element_end_date := r_element_entry.r_element_end_date(J);
								l_pay_amount := r_element_entry.r_pay_amount(J);
								l_proc_step:= 100 + (J / 100000);

								IF (l_element_end_date >= l_asg_start_date) AND (l_element_start_date <= l_asg_end_date) THEN
									l_start_date := GREATEST(l_asg_start_date, l_element_start_date);
									l_end_date := LEAST(l_asg_end_date, l_element_end_date);
									l_bus_days_in_sched := NVL(PSP_GENERAL.BUSINESS_DAYS(l_start_date, l_end_date,p_assignment_id), 0);
									l_enc_amount := l_enc_amount + ROUND(((l_pay_amount * l_bus_days_in_sched)/( l_bus_working_days )),g_ext_precision);
								END IF;

								hr_utility.trace('l_element_start_date: ' || fnd_date.date_to_canonical(l_element_start_date) ||
									' l_element_end_date: ' || fnd_date.date_to_canonical(l_element_end_date) ||
									' l_pay_amount: ' || fnd_number.number_to_canonical(l_pay_amount) ||
									' l_start_date: ' || fnd_date.date_to_canonical(l_start_date) ||
									' l_end_date: ' || fnd_date.date_to_canonical(l_end_date) ||
									' l_bus_days_in_sched: ' || fnd_number.number_to_canonical(l_bus_days_in_sched) ||
									' l_enc_amount: ' || fnd_number.number_to_canonical(l_enc_amount));

								EXIT WHEN l_element_start_date > l_asg_end_date;
							END LOOP;
						END IF;
					ELSE
						l_enc_amount := 0;
					END IF;
				END IF;
			ELSE
				l_calculate_period_amt := FALSE;
			END IF;
			IF (r_enc_period.r_process_flag(I) IN ('DA', 'SA')) THEN
				r_enc_period.r_encumbrance_amount(I) := r_enc_period.r_encumbrance_amount(I) + ROUND(((l_enc_amount * r_enc_period.r_schedule_percent(I))/100), g_ext_precision);
			ELSE
				r_enc_period.r_encumbrance_amount(I) := r_enc_period.r_encumbrance_amount(I) + ROUND(l_enc_amount, g_ext_precision);
			END IF;
		ELSE
			r_enc_period.r_encumbrance_amount(I) := 0;
		END IF;
	END LOOP;

	l_proc_step:= 110;
	hr_utility.trace('Calculating Period Amounts...');

	IF (l_calculate_period_amt) THEN
--	Modified period amount calculation for bug fix 3673723
--	For element entry value based period amount calculation, changed to time period reference.
--	Introduced the following for bug fix 3673723
		OPEN element_period_amount_cur;
		FETCH element_period_amount_cur BULK COLLECT INTO r_element_period_amount.r_time_period_id, r_element_period_amount.r_period_amount;
		CLOSE element_period_amount_cur;
--	End of changes for bug fix 3673723

		FOR I IN 1..r_enc_period.r_time_period_id.COUNT
		LOOP
			l_time_period_id := r_enc_period.r_time_period_id(I);
			l_proc_step:= 120 + (I / 100000);

			IF (l_time_period_id <> l_prev_time_period_id) THEN
				l_period_start_date := r_enc_period.r_period_start_date(I);
				l_period_end_date := r_enc_period.r_period_end_date(I);
				l_change_end_date := l_period_end_date;
				l_enc_amount := 0;
				l_bus_working_days := psp_general.business_days(l_period_start_date, l_period_end_date,p_assignment_id);
				l_end_date := l_period_end_date;
				l_period_counter := 0;

				hr_utility.trace('I: ' || fnd_number.number_to_canonical(I) ||
					' l_period_start_date: ' || fnd_date.date_to_canonical(l_period_start_date) ||
					' l_period_end_date: ' || fnd_date.date_to_canonical(l_period_end_date) ||
					' l_bus_working_days: ' || fnd_number.number_to_canonical(l_bus_working_days));

				IF (l_bus_working_days > 0) THEN
					FOR J IN 1..r_salary_proposal.r_change_date.COUNT
					LOOP
						IF (J > l_period_counter) THEN		-- Introduced for bug fix 3673723
							l_change_date := r_salary_proposal.r_change_date(J);

--	Introduced for bug fix 3551561
							IF (J > 1) THEN
								l_change_end_date := l_prev_change_date - 1;
								IF (l_change_end_date < l_change_date) THEN
									l_change_end_date := l_prev_change_end_date;
								END IF;
							END IF;
--	End of changes for bug fix 3551561

							l_end_date := LEAST(l_end_date, r_salary_proposal.r_effective_end_date(J), l_period_end_date);
							l_temp_salary := r_salary_proposal.r_proposed_salary(J);
							l_annualization_factor := r_salary_proposal.r_pay_annualization_factor(J);
							l_pay_basis := r_salary_proposal.r_pay_basis(J);
							l_proc_step:= 130 + (J / 100000);

							hr_utility.trace('J: ' || fnd_number.number_to_canonical(J) ||
								' l_change_date: ' || fnd_date.date_to_canonical(l_change_date) ||
								' l_change_end_date: ' || fnd_date.date_to_canonical(l_change_end_date) ||
								' l_temp_salary: ' || fnd_number.number_to_canonical(l_temp_salary) ||
								' l_annualization_factor: ' || fnd_number.number_to_canonical(l_annualization_factor) ||
								' l_pay_basis: ' || l_pay_basis);

--					IF (l_change_date <= l_end_date) THEN	Commented for bug fix 3551561
							IF (l_change_end_date >= l_period_start_date) AND (l_change_date <= l_period_end_date) THEN
								IF (l_num_per_fiscal_year <> 0 AND (l_pay_basis IN ('ANNUAL','MONTHLY','HOURLY'))) THEN
									l_temp_salary := round((l_temp_salary * l_annualization_factor / l_num_per_fiscal_year), g_ext_precision);
								END IF;

/*****	Commented for bug fix 3551561
						l_start_date := GREATEST(l_change_date, r_salary_proposal.r_effective_start_date(J), l_period_start_date);
						l_bus_days_in_sched := NVL(PSP_GENERAL.BUSINESS_DAYS(l_start_date, l_end_date), 0);
						l_enc_amount := l_enc_amount + ROUND(((l_temp_salary * l_bus_days_in_sched) / ( l_bus_working_days )), g_ext_precision);
	End of comment for bug fix 3551561	*****/
--	Introduced for bug fix 3551561

								l_bus_days_in_sched := 0;
								l_period_counter := J;
								LOOP		-- Introduced for bug fix 3673723
									l_start_date := GREATEST(l_period_start_date,
									r_salary_proposal.r_effective_start_date(l_period_counter), l_change_date);
									l_end_date := LEAST(l_period_end_date,
									r_salary_proposal.r_effective_end_date(l_period_counter), l_change_end_date);
									l_bus_days_in_sched := l_bus_days_in_sched + NVL(psp_general.business_days(l_start_date, l_end_date,p_assignment_id), 0);
									EXIT WHEN l_period_counter = r_salary_proposal.r_change_date.COUNT;
									EXIT WHEN l_change_date <> r_salary_proposal.r_change_date(l_period_counter + 1);
									l_period_counter := l_period_counter + 1;
								END LOOP;	-- Introduced for bug fix 3673723

								l_enc_amount := l_enc_amount + ROUND(((l_temp_salary * l_bus_days_in_sched)/( l_bus_working_days )), g_ext_precision);
--	End of changes for bug fix 3551561
								hr_utility.trace('l_start_date: ' || fnd_date.date_to_canonical(l_start_date) ||
									' l_end_date: ' || fnd_date.date_to_canonical(l_end_date) ||
									' l_bus_days_in_sched: ' || fnd_number.number_to_canonical(l_bus_days_in_sched) ||
									' l_enc_amount: ' || fnd_number.number_to_canonical(l_enc_amount));
--						l_end_date := GREATEST(l_start_date, l_change_date) - 1;	Commented for bug fix 3551561
								l_prev_change_end_date := l_change_end_date;
							END IF;
							l_prev_change_date := l_change_date;
							EXIT WHEN l_change_end_date < l_period_start_date;	-- Modified to change_end_date for bug fix 3551561
						END IF;		-- Introduced for bug fix 3673723 (J > l_period_counter condn.)
					END LOOP;

					l_proc_step:= 150;

--	Introduced the following for bug fix 3673723
					IF (l_enc_amount = 0) THEN
						FOR J IN 1..r_element_period_amount.r_time_period_id.COUNT
						LOOP
							IF (r_element_period_amount.r_time_period_id (J) = l_time_period_id) THEN
								l_enc_amount := r_element_period_amount.r_period_amount(J);
								EXIT;
							END IF;
						END LOOP;
					END IF;
--	End of changes for bug fix 3673723

					r_enc_period.r_period_amount(I) := ROUND(l_enc_amount, g_ext_precision);
				ELSE
					r_enc_period.r_period_amount(I) := 0;
				END IF;
				l_prev_time_period_id := l_time_period_id;
			ELSE
				r_enc_period.r_period_amount(I) := r_enc_period.r_period_amount(I - 1);
			END IF;
		END LOOP;
	ELSE
		hr_utility.trace('Period amounts based on formula/user hook amounts');
		l_enc_amount := 0;
		l_period_counter := 1;
		l_tmp_counter := 1;
		LOOP
			EXIT WHEN l_tmp_counter > r_enc_period.r_time_period_id.COUNT;
			hr_utility.trace('l_tmp_counter: ' || l_tmp_counter || ' EM: ' || r_enc_period.r_encumbrance_amount(l_tmp_counter));
			IF (l_tmp_counter = 1) THEN
				l_time_period_id := r_enc_period.r_time_period_id(l_tmp_counter);
			END IF;
			IF (r_enc_period.r_time_period_id(l_tmp_counter) = l_time_period_id) THEN
				IF (r_enc_period.r_schedule_percent(l_tmp_counter) IN (0, 100)) THEN
					l_enc_amount := l_enc_amount + r_enc_period.r_encumbrance_amount(l_tmp_counter);
				END IF;
			ELSE
				r_element_period_amount.r_period_amount(l_period_counter) := l_enc_amount;
				r_element_period_amount.r_time_period_id(l_period_counter) := l_time_period_id;
				l_enc_amount := 0;
				IF (r_enc_period.r_schedule_percent(l_tmp_counter) IN (0, 100)) THEN
					l_enc_amount := r_enc_period.r_encumbrance_amount(l_tmp_counter);
				END IF;
				l_time_period_id := r_enc_period.r_time_period_id(l_tmp_counter);
				l_period_counter := l_period_counter + 1;
			END IF;
			IF (l_tmp_counter = r_enc_period.r_time_period_id.COUNT) THEN
				r_element_period_amount.r_period_amount(l_period_counter) := l_enc_amount;
				r_element_period_amount.r_time_period_id(l_period_counter) := l_time_period_id;
			END IF;
			l_tmp_counter := l_tmp_counter + 1;
		END LOOP;
		l_period_counter := 1;
		FOR J IN 1..r_enc_period.r_time_period_id.COUNT
		LOOP
			hr_utility.trace('l_period_counter: ' || l_period_counter);
			IF (r_enc_period.r_time_period_id(J) <> r_element_period_amount.r_time_period_id(l_period_counter)) THEN
				l_period_counter := l_period_counter + 1;
			END IF;
			r_enc_period.r_period_amount(J) := r_element_period_amount.r_period_amount(l_period_counter);
		END LOOP;
	END IF;

	l_proc_step:= 170;

	hr_utility.trace('Dumping Assignment Chunks after determining Assignment chunk and Period chunk amounts');
	hr_utility.trace(LPAD('Chunk Pointer', 13, ' ') || '	' ||
		LPAD('Time Period Id', 14, ' ') || '	' || RPAD('Period Start Date', 17, ' ') || '	' ||
		RPAD('Period End Date', 15, ' ') || '	' || RPAD('Asg Start Date', 14, ' ') || '	' ||
		RPAD('Asg End Date', 12, ' ') || '	' || RPAD('Effective Date', 14, ' ') || '	' ||
		RPAD('Process Flag', 12, ' ') || '	' || LPAD('Schedule Percent', 16, ' ') || '	' ||
		LPAD('Encumbrance Amount', 18, ' ') || '	' || LPAD('Period Amount', 18, ' ') || '	' ||
		RPAD('Reason Code', 50, ' '));

	hr_utility.trace(LPAD('-', 13, '-') || '	' ||
		LPAD('-', 14, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || LPAD('-', 16, '-') || '	' ||
		LPAD('-', 18, '-') || '	' || LPAD('-', 18, '-') || '	' ||
		RPAD('-', 50, '-'));

	FOR recno IN 1..r_enc_period.r_time_period_id.COUNT
	LOOP
		hr_utility.trace(LPAD(recno, 13, ' ') || '	' ||
			LPAD(r_enc_period.r_time_period_id(recno), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_period_start_date(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_period_end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_asg_start_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_asg_end_date(recno), 'DD-MON-RRRR'), 12, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_effective_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(r_enc_period.r_process_flag(recno), 12, ' ') || '	' ||
			LPAD(r_enc_period.r_schedule_percent(recno), 16, ' ') || '	' ||
			LPAD(r_enc_period.r_encumbrance_amount(recno), 18, ' ') || '	' ||
			LPAD(r_enc_period.r_period_amount(recno), 18, ' ') || '	' ||
			RPAD(r_enc_period.r_reason_code(recno), 50, ' '));
	END LOOP;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Leaving ' || l_proc_name);

	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN DIVIDE_BY_ZERO THEN
		fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', ' DETERMINE_ENC_AMOUNT ');
		fnd_file.put_line(fnd_file.log, fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ' || l_proc_name);
		p_return_status := fnd_api.g_ret_sts_unexp_error;
	WHEN OTHERS THEN
		IF (g_error_message IS NULL) THEN
			g_error_message := l_proc_name || ': ' || SQLERRM;
		END IF;
		fnd_msg_pub.add_exc_msg('PSP', 'DETERMINE_ENC_AMOUNT');
		fnd_file.put_line(fnd_file.log, fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ' || l_proc_name);
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END determine_enc_amount;
--	End of changes for bug fix 3488734

---------------------- C R E A T E  L I N E S -------------------------------------

/*************************************************************************
This procedure accepts the Assignment ID, Last Payroll Run date, Max. Encumbrance Date, Earnings Amount,
Element Type ID as input parameters. This procedure determines the different accounts that need to be
charged and the amounts that need to be charged until a particular Date. The logic
used to arrive at the charging instructions is derived from CREATE_DISTRIBUTION_LINES
in Oracle Labor Distribution.
Finally, the procedure creates encumbrance lines in PSP_ENC_LINES.
*************************************************************************/

/**********************************************************************************
					CODING LOGIC
--> Retrieve the date ranges for which encumbrance has to be done:
	--When Called in Create Mode all time periods beyond the max. encumbrance period are considered.
	--When called in Update/Quick Update Mode periods between last payroll run date and max. encumbered date
	  for that assignment are considered.
       --All the  active assignment chunks are Bulk Collected inot r_enc_period RECORD.
--> Next, go through a loop (for each record of r_enc_period) to calculate the encumbrance amount for each active assignment chunk within a period
	in the payroll.
	--> For each active assignment chunk, calculate the daily rate (from Encumbrance amount and business days)
	--> Then, go through a loop to find the schedule for that assignment chunk by going through the schedule
		hierarchy.
		--> Once the schedule has been determined, then create encumbrance lines
	--> Exit out of the First Loop when the assignment start date > Enumbrance End date Calculated within each
	    Hierarchy for each CI. For GL Encumrbance End date = Org. Default End Date for POETA it is computed
	    thorugh procedure Obtain_Enc_Poeta_Enc_date.
--> Close First Loop


***********************************************************************************/

PROCEDURE create_lines(	p_assignment_id 	IN NUMBER,
			p_payroll_id 		IN NUMBER,
		        p_element_type_id 	IN NUMBER,
			p_last_paid_date 	IN DATE,
			p_return_status		OUT NOCOPY VARCHAR2) IS
CURSOR	enc_period_cur IS
SELECT  ptp.time_period_id,
	ptp.start_date,
	ptp.end_date,
	GREATEST(ptp.start_date, paf.effective_start_date),
	LEAST(ptp.end_date, paf.effective_end_date),
	DECODE(g_Eff_Date_Value,	1, ptp.end_date,
					2, ptp.start_date,
					3, ptp.regular_payment_date,
					4, ptp.default_dd_date,
					5, ptp.cut_off_date) effective_date,
	'Y',
	0,
	NULL
FROM	per_time_periods ptp,
	per_all_assignments_f paf,
	per_assignment_status_types past
WHERE	ptp.payroll_id = p_payroll_id
AND 	paf.assignment_id = p_assignment_id
AND	ptp.start_date <= paf.effective_end_date
AND	ptp.end_date >= paf.effective_start_date
AND	past.assignment_status_type_id = paf.assignment_status_type_id
AND	past.per_system_status = 'ACTIVE_ASSIGN'
AND	paf.payroll_id=p_payroll_id
AND	ptp.start_date >= p_last_paid_date
AND	paf.effective_start_date <= g_enc_org_end_date
AND	(g_actual_term_date IS NULL OR ptp.start_date <= g_actual_term_date)
AND	(g_pateo_end_date IS NULL OR ptp.start_date <= g_pateo_end_date)
ORDER BY 1, 4;

CURSOR	c_person_id IS
SELECT	paf.person_id
FROM	per_all_assignments_f paf
WHERE   paf.assignment_id =p_assignment_id
AND	ROWNUM=1;

l_project_number		pa_projects_all.segment1%TYPE;
l_task_number			pa_tasks.task_number%TYPE;
l_award_number			gms_awards_all.award_number%TYPE;
l_exp_org_name			hr_organization_units.name%TYPE;
l_gl_description		VARCHAR2(4000);
l_time_period_id 		NUMBER;
l_return_status 			VARCHAR2(1);
l_person_id 			NUMBER;
l_effective_date	 	DATE;
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
l_period_start_date		DATE;
l_period_end_date		DATE;
l_earnings_amount		NUMBER;
l_asg_start_date 		DATE;
l_asg_end_date   		DATE;
l_process_flag			VARCHAR2(10);
r_enc_period_tmp		enc_period_rectype;
l_prev_time_period_id		NUMBER;
l_enc_element_type_id		NUMBER;
l_period_ind			NUMBER;
l_running_total			NUMBER;
l_prev_enc_lines_counter	NUMBER;
l_proc_name			VARCHAR2(61);
l_proc_step			NUMBER(20, 10);
l_schedule_line_id		NUMBER(15);
l_element_account_id		NUMBER(15);
l_org_schedule_id		NUMBER(15);
l_default_account_id		NUMBER(15);
l_suspense_account_id		NUMBER(15);
l_gl_code_combination_id	NUMBER(15);
l_project_id			NUMBER(15);
l_task_id			NUMBER(15);
l_award_id			NUMBER(15);
l_expenditure_type		VARCHAR2(30);
l_expenditure_org_id		NUMBER(15);
l_orig_gl_code_combination_id	NUMBER(15);
l_orig_project_id			NUMBER(15);
l_orig_task_id			NUMBER(15);
l_orig_award_id			NUMBER(15);
l_orig_expenditure_type		VARCHAR2(30);
l_orig_expenditure_org_id		NUMBER(15);
l_attribute_category		VARCHAR2(30);
l_attribute1			VARCHAR2(150);
l_attribute2			VARCHAR2(150);
l_attribute3			VARCHAR2(150);
l_attribute4			VARCHAR2(150);
l_attribute5			VARCHAR2(150);
l_attribute6			VARCHAR2(150);
l_attribute7			VARCHAR2(150);
l_attribute8			VARCHAR2(150);
l_attribute9			VARCHAR2(150);
l_attribute10			VARCHAR2(150);
l_reason_code			VARCHAR2(50);
l_schedule_percent		NUMBER;
l_dist_amount			NUMBER;
l_bus_days_in_chunk		NUMBER;
l_start_date_active		DATE;
l_end_date_active		DATE;
l_poeta_start_date		DATE;
l_poeta_end_date		DATE;
no_global_acct_exists		EXCEPTION;
suspense_ac_invalid		EXCEPTION;
suspense_autopop_failed		EXCEPTION;
l_autopop_status		VARCHAR2(1);
l_autopop_error			VARCHAR2(50);
l_new_expenditure_type		VARCHAR2(30);
l_new_gl_code_combination_id	NUMBER(15);
l_acct_type			VARCHAR2(1);
l_orig_pointer			NUMBER(15);
l_chunk_pointer			NUMBER(15);
l_enc_period_count		NUMBER(15);
l_organization_id		NUMBER(15);
l_ignore_start			NUMBER(15);
l_ignore_end			NUMBER(15);
l_organization_name		VARCHAR2(240);
l_min_start_date		DATE;
l_max_end_date			DATE;

CURSOR	asg_number_cur IS
SELECT	organization_id
FROM	per_all_assignments_f
WHERE	assignment_id = p_assignment_id
AND		payroll_id = p_payroll_id
AND		effective_end_date >= l_asg_start_date
AND		ROWNUM = 1;

CURSOR	org_name_cur IS
SELECT	name
FROM	hr_organization_units
WHERE	organization_id = l_organization_id;

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
WHERE	organization_id = l_expenditure_org_id;

PROCEDURE process_all_hier	(p_chunk_pointer		IN	NUMBER,
				p_asg_start_date		IN	DATE,
				p_asg_end_date			IN	DATE,
				p_encumbrance_amount		IN	NUMBER,
				p_process_flag			IN	VARCHAR2) IS
l_da_reason_code		VARCHAR2(50);
l_sa_reason_code		VARCHAR2(50);
l_gl_project_flag		VARCHAR2(1);
l_linkage_status		VARCHAR2(50);
l_patc_status			VARCHAR2(50);
l_billable_flag			VARCHAR2(1);
l_bus_days_in_period		NUMBER;
l_bus_days_in_sched		NUMBER;
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
l_msg_app			VARCHAR2(2000);
l_msg_type			VARCHAR2(2000);
l_msg_token1			VARCHAR2(2000);
l_msg_token2			VARCHAR2(2000);
l_msg_token3			VARCHAR2(2000);
l_award_status			VARCHAR2(2000);
l_last_enc_date			DATE;
l_daily_rate			NUMBER;
t_poeta_gl_hier_array		r_poeta_gl_hier_tab;
l_org_id			NUMBER(15);
BEGIN
	IF (p_process_flag = 'DA') THEN
		l_da_reason_code := l_reason_code;
	END IF;

	IF (p_process_flag = 'SA') THEN
		l_sa_reason_code := l_reason_code;
	END IF;

	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Entering process_all_hier');
	hr_utility.trace('	p_chunk_pointer: ' || p_chunk_pointer ||
		' p_asg_start_date: ' || TO_CHAR(p_asg_start_date, 'DD-MON-RRRR') ||
		' p_asg_end_date: ' || TO_CHAR(p_asg_end_date, 'DD-MON-RRRR') ||
		' p_process_flag: ' || p_process_flag);

	l_last_enc_date := NVL(g_actual_term_date, g_enc_org_end_date);

	IF ((p_process_flag <> 'SA') AND (l_project_id IS NOT NULL)) THEN
		l_patc_status   := NULL;
		l_linkage_status:= NULL;
		l_billable_flag := NULL;
		l_award_status := NULL;

		obtain_enc_poeta_end_date (p_ls_start_date  => l_start_date_active,
			p_ls_end_date    => l_end_date_active,
			p_poeta_end_date => l_poeta_end_date,
			p_enc_end_date   => l_last_enc_date,
			p_return_status  => l_return_status);
		IF l_return_status <> fnd_api.g_ret_sts_success THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;
	hr_utility.trace('	l_last_enc_date: ' || TO_CHAR(l_last_enc_date, 'DD-MON-RRRR'));

	IF (r_enc_period.r_asg_start_date(p_chunk_pointer) <= l_last_enc_date) THEN
		l_start_date_active := GREATEST(l_start_date_active, p_asg_start_date);
		l_end_date_active := LEAST(l_end_date_active, p_asg_end_date, l_last_enc_date);
		l_daily_rate := round((r_enc_period.r_encumbrance_amount(p_chunk_pointer) * l_schedule_percent/100),g_ext_precision);
		l_daily_rate := NVL(p_encumbrance_amount, l_daily_rate);
		hr_utility.trace('	l_start_date_active: ' || TO_CHAR(l_start_date_active, 'DD-MON-RRRR') ||
			' l_end_date_active: ' || TO_CHAR(l_end_date_active, 'DD-MON-RRRR') ||
			' l_poeta_start_date: ' || TO_CHAR(l_poeta_start_date, 'DD-MON-RRRR') ||
			' l_poeta_end_date: ' || TO_CHAR(l_poeta_end_date, 'DD-MON-RRRR') ||
			' l_daily_rate: ' || l_daily_rate);
		determine_pro_rata_dates	(p_assignment_id	=> p_assignment_id,
		                                 p_ls_start_date	=> l_start_date_active,
						p_ls_end_date		=> l_end_date_active,
						p_poeta_start_date	=> l_poeta_start_date,
						p_poeta_end_date	=> l_poeta_end_date,
						p_asg_start_date	=> p_asg_start_date,
						p_asg_end_date		=> p_asg_end_date,
						p_asg_amount		=> l_daily_rate,
						p_poeta_gl_hier_array	=> t_poeta_gl_hier_array,
						p_return_status		=> l_return_status);
		IF  l_return_status <> fnd_api.g_ret_sts_success THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		hr_utility.trace('	t_poeta_gl_hier_array.COUNT: ' || t_poeta_gl_hier_array.COUNT);
		FOR I IN 1..t_poeta_gl_hier_array.COUNT
		LOOP
			hr_utility.trace('	t_poeta_gl_hier_array(' || I || ').r_enc_start_date: ' || TO_CHAR(t_poeta_gl_hier_array(I).r_enc_start_date, 'DD-MON-RRRR') ||
				' t_poeta_gl_hier_array(' || I || ').r_enc_end_date: ' || TO_CHAR(t_poeta_gl_hier_array(I).r_enc_end_date, 'DD-MON-RRRR') ||
				' t_poeta_gl_hier_array(' || I || ').r_amount: ' || t_poeta_gl_hier_array(I).r_amount ||
				' t_poeta_gl_hier_array(' || I || ').r_susp_flag: ' || t_poeta_gl_hier_array(I).r_susp_flag);
			IF t_poeta_gl_hier_array(I).r_susp_flag <> 'Y' THEN
	   			l_dist_amount     := t_poeta_gl_hier_array(I).r_amount;
				l_effective_date  := r_enc_period.r_effective_date(p_chunk_pointer);
				l_gl_project_flag := 'G';

				IF l_gl_code_combination_id IS NOT NULL THEN
					insert_into_enc_lines(
						p_element_type_id,
						l_effective_date,
						g_dr_cr_flag ,
						ROUND(l_dist_amount, g_precision),
						g_enc_line_type,
						l_schedule_line_id,
						l_org_schedule_id,
						l_default_account_id,
						l_suspense_account_id,
						l_element_account_id,
						l_gl_project_flag,
						l_person_id,
						p_assignment_id,
						l_award_id,
						l_task_id,
						l_expenditure_type,
						l_expenditure_org_id,
						l_project_id,
						l_gl_code_combination_id,
						r_enc_period.r_time_period_id(p_chunk_pointer),
						p_payroll_id,
						g_business_group_id,
						g_set_of_books_id,
						l_sa_reason_code,
						l_da_reason_code,
						'N',
						t_poeta_gl_hier_array(i).r_enc_start_date,
						t_poeta_gl_hier_array(i).r_enc_end_date,
						l_attribute_category,
						l_attribute1,
						l_attribute2,
						l_attribute3,
						l_attribute4,
						l_attribute5,
						l_attribute6,
						l_attribute7,
						l_attribute8,
						l_attribute9,
						l_attribute10,
						l_orig_gl_code_combination_id,
						l_orig_project_id,
						l_orig_task_id,
						l_orig_award_id,
						l_orig_expenditure_org_id,
						l_orig_expenditure_type,
						l_process_flag,
						l_return_status);
					IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
				ELSE
					psp_general.poeta_effective_date (t_poeta_gl_hier_array(I).r_enc_end_date,
						l_project_id,
						l_award_id,
						l_task_id,
						l_effective_date,
						l_return_status);
					IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
						fnd_message.set_name('PSP', 'PSP_POETA_EFFECTIVE_DATE_ERROR');
						g_error_message := fnd_message.get;
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;

					-- R12 moac uptake. Set the MOAC Context to Single
					l_org_id := psp_general.get_transaction_org_id( l_project_id, l_expenditure_org_id);
					mo_global.set_policy_context('S', l_org_id);

					pa_transactions_pub.validate_transaction
						(x_project_id 		=> l_project_id,
						x_task_id		=> l_task_id,
						x_ei_date		=> l_effective_date,
						x_expenditure_type	=> l_expenditure_type,
						x_non_labor_resource	=> NULL,
						x_person_id		=> l_person_id,
						x_incurred_by_org_id	=> l_expenditure_org_id,
						x_calling_module	=> 'PSPENLNB',
						x_msg_application	=> l_msg_app,
						x_msg_type		=> l_msg_type,
						x_msg_token1		=> l_msg_token1,
						x_msg_token2		=> l_msg_token2,
						x_msg_token3		=> l_msg_token3,
						x_msg_count		=> l_msg_count,
						x_msg_data		=> l_patc_status,
						x_billable_flag		=> l_billable_flag,
						p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


					IF l_patc_status IS NULL THEN
						gms_transactions_pub.validate_transaction
							(l_project_id,
							l_task_id,
							l_award_id,
							l_expenditure_type,
							l_effective_date,
							'PSPENLNB',
							l_award_status);

						IF l_award_status IS NOT NULL THEN
							l_patc_status  := SUBSTR(l_award_status,1,50);
						END IF;
					END IF;
					-- Set the MOAC Context to Multiple
					mo_global.set_policy_context('M', null);

					IF (l_patc_status IS NOT NULL ) THEN
						IF (p_process_flag = 'SA') THEN
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

							IF (l_patc_status IS NOT NULL) THEN
								fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_INV_PATEO');
								fnd_message.set_token('PJ', l_project_number);
								fnd_message.set_token('TK', l_task_number);
								fnd_message.set_token('AW', l_award_number);
								fnd_message.set_token('EO', l_exp_org_name);
								fnd_message.set_token('ET', l_expenditure_type);
								fnd_message.set_token('START_DATE', t_poeta_gl_hier_array(i).r_enc_start_date);
								fnd_message.set_token('END_DATE', t_poeta_gl_hier_array(i).r_enc_end_date);
								fnd_message.set_token('ERROR_STATUS', l_patc_status);
							ELSE
								fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_END_PATEO');
								fnd_message.set_token('PJ', l_project_number);
								fnd_message.set_token('TK', l_task_number);
								fnd_message.set_token('AW', l_award_number);
								fnd_message.set_token('EO', l_exp_org_name);
								fnd_message.set_token('ET', l_expenditure_type);
								fnd_message.set_token('START_DATE', t_poeta_gl_hier_array(i).r_enc_start_date);
								fnd_message.set_token('END_DATE', t_poeta_gl_hier_array(i).r_enc_end_date);
								fnd_message.set_token('EFFECTIVE_DATE', l_poeta_end_date);
							END IF;
							g_error_message := fnd_message.get;
							fnd_file.put_line(fnd_file.log, g_error_message);
							RAISE SUSPENSE_AC_INVALID;
						END IF;

						IF ((t_poeta_gl_hier_array(I).r_enc_start_date <= g_enc_org_end_date) AND
							(psp_general.business_days(t_poeta_gl_hier_array(I).r_enc_start_date,
								t_poeta_gl_hier_array(I).r_enc_end_date) > 0)) THEN
							orig_ci.gl_code_combination_id(g_orig_pointer) := l_gl_code_combination_id;
							orig_ci.project_id(g_orig_pointer) := l_project_id;
							orig_ci.task_id(g_orig_pointer) := l_task_id;
							orig_ci.award_id(g_orig_pointer) := l_award_id;
							orig_ci.expenditure_organization_id(g_orig_pointer) := l_expenditure_org_id;
							orig_ci.expenditure_type(g_orig_pointer) := l_expenditure_type;
							g_orig_pointer := g_orig_pointer + 1;
							l_enc_period_count := r_enc_period.r_time_period_id.COUNT + 1;
							r_enc_period.r_period_ind(l_enc_period_count) := r_enc_period.r_period_ind(p_chunk_pointer);
							r_enc_period.r_period_start_date(l_enc_period_count) := r_enc_period.r_period_start_date(p_chunk_pointer);
							r_enc_period.r_period_end_date(l_enc_period_count) := r_enc_period.r_period_end_date(p_chunk_pointer);
							r_enc_period.r_asg_start_date(l_enc_period_count) := t_poeta_gl_hier_array(I).r_enc_start_date;
							r_enc_period.r_asg_end_date(l_enc_period_count) := t_poeta_gl_hier_array(I).r_enc_end_date;
							r_enc_period.r_effective_date(l_enc_period_count) := r_enc_period.r_effective_date(p_chunk_pointer);
							r_enc_period.r_time_period_id(l_enc_period_count) := r_enc_period.r_time_period_id(p_chunk_pointer);
							r_enc_period.r_process_flag(l_enc_period_count) := 'SA';
							r_enc_period.r_schedule_percent(l_enc_period_count) := 100;
							r_enc_period.r_encumbrance_amount(l_enc_period_count) :=
								ROUND(((l_daily_rate  * psp_general.business_days(t_poeta_gl_hier_array(I).r_enc_start_date, LEAST(t_poeta_gl_hier_array(I).r_enc_end_date, g_enc_org_end_date),p_assignment_id)) /
									psp_general.business_days(t_poeta_gl_hier_array(I).r_enc_start_date, t_poeta_gl_hier_array(I).r_enc_end_date,p_assignment_id)),g_ext_precision);
							r_enc_period.r_period_amount(l_enc_period_count) := r_enc_period.r_period_amount(p_chunk_pointer);
							r_enc_period.r_reason_code(l_enc_period_count) := l_patc_status;
						END IF;
						add_cel_warnings(p_start_date	=>	t_poeta_gl_hier_array(I).r_enc_start_date,
							p_end_date		=>	t_poeta_gl_hier_array(I).r_enc_end_date,
							p_hierarchy_code	=>	'SA',
							p_warning_code		=>	'INVALID_CI',
							p_project_id		=>	l_project_id,
							p_task_id		=>	l_task_id,
							p_award_id		=>	l_award_id,
							p_exp_org_id		=>	l_expenditure_org_id,
							p_exp_type		=>	l_expenditure_type,
							p_effective_date	=>	l_poeta_end_date,
							p_error_status		=>	l_patc_status);
					ELSE
						l_gl_project_flag := 'P';
						insert_into_enc_lines
							(p_element_type_id,
							l_effective_date,
							g_dr_cr_flag,
							ROUND(l_dist_amount,g_precision),
							g_enc_line_type,
							l_schedule_line_id,
							l_org_schedule_id,
							l_default_account_id,
							l_suspense_account_id,
							l_element_account_id,
							l_gl_project_flag,
							l_person_id,
							p_assignment_id,
							l_award_id,
							l_task_id,
							l_expenditure_type,
							l_expenditure_org_id,
							l_project_id,
							l_gl_code_combination_id,
							r_enc_period.r_time_period_id(p_chunk_pointer),
							p_payroll_id,
							g_business_group_id,
							g_set_of_books_id,
							l_sa_reason_code,
							l_da_reason_code,
							'N',
							t_poeta_gl_hier_array(i).r_enc_start_date,
							t_poeta_gl_hier_array(i).r_enc_end_date,
							l_attribute_category,
							l_attribute1,
							l_attribute2,
							l_attribute3,
							l_attribute4,
							l_attribute5,
							l_attribute6,
							l_attribute7,
							l_attribute8,
							l_attribute9,
							l_attribute10,
							l_orig_gl_code_combination_id,
							l_orig_project_id,
							l_orig_task_id,
							l_orig_award_id,
							l_orig_expenditure_org_id,
							l_orig_expenditure_type,
							l_process_flag,
							l_return_status);
						IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
						END IF;
					END IF;
				END IF;
			ELSE
				l_dist_amount     := t_poeta_gl_hier_array(i).r_amount;

				psp_general.poeta_effective_date (t_poeta_gl_hier_array(I).r_enc_end_date,
					l_project_id,
					l_award_id,
					l_task_id,
					l_effective_date,
					l_return_status);
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					fnd_message.set_name('PSP', 'PSP_POETA_EFFECTIVE_DATE_ERROR');
					g_error_message := fnd_message.get;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

				-- R12 moac uptake. Set the MOAC Context to Single
				l_org_id := psp_general.get_transaction_org_id( l_project_id, l_expenditure_org_id);
				mo_global.set_policy_context('S', l_org_id);

				pa_transactions_pub.validate_transaction
					(x_project_id 		=> l_project_id,
					x_task_id		=> l_task_id,
					x_ei_date		=> t_poeta_gl_hier_array(I).r_enc_end_date,
					x_expenditure_type	=> l_expenditure_type,
					x_non_labor_resource	=> NULL,
					x_person_id		=> l_person_id,
					x_incurred_by_org_id	=> l_expenditure_org_id,
					x_calling_module	=> 'PSPENLNB',
					x_msg_application	=> l_msg_app,
					x_msg_type		=> l_msg_type,
					x_msg_token1		=> l_msg_token1,
					x_msg_token2		=> l_msg_token2,
					x_msg_token3		=> l_msg_token3,
					x_msg_count		=> l_msg_count,
					x_msg_data		=> l_patc_status,
					x_billable_flag		=> l_billable_flag,
					p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


				IF l_patc_status IS NULL THEN
					gms_transactions_pub.validate_transaction
						(l_project_id,
						l_task_id,
						l_award_id,
						l_expenditure_type,
						t_poeta_gl_hier_array(I).r_enc_end_date,
						'PSPENLNB',
						l_award_status);

					IF l_award_status IS NOT NULL THEN
						l_patc_status  := SUBSTR(l_award_status,1,50);
					END IF;
				END IF;
				-- Set the MOAC Context to Multiple
				mo_global.set_policy_context('M', null);

				IF (p_process_flag = 'SA') THEN
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

					IF (l_patc_status IS NOT NULL) THEN
						fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_INV_PATEO');
						fnd_message.set_token('PJ', l_project_number);
						fnd_message.set_token('TK', l_task_number);
						fnd_message.set_token('AW', l_award_number);
						fnd_message.set_token('EO', l_exp_org_name);
						fnd_message.set_token('ET', l_expenditure_type);
						fnd_message.set_token('START_DATE', t_poeta_gl_hier_array(i).r_enc_start_date);
						fnd_message.set_token('END_DATE', t_poeta_gl_hier_array(i).r_enc_end_date);
						fnd_message.set_token('ERROR_STATUS', l_patc_status);
					ELSE
						fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_END_PATEO');
						fnd_message.set_token('PJ', l_project_number);
						fnd_message.set_token('TK', l_task_number);
						fnd_message.set_token('AW', l_award_number);
						fnd_message.set_token('EO', l_exp_org_name);
						fnd_message.set_token('ET', l_expenditure_type);
						fnd_message.set_token('START_DATE', t_poeta_gl_hier_array(i).r_enc_start_date);
						fnd_message.set_token('END_DATE', t_poeta_gl_hier_array(i).r_enc_end_date);
						fnd_message.set_token('EFFECTIVE_DATE', l_poeta_end_date);
					END IF;
					g_error_message := fnd_message.get;
					fnd_file.put_line(fnd_file.log, g_error_message);
					RAISE SUSPENSE_AC_INVALID;
				END IF;

				IF ((t_poeta_gl_hier_array(I).r_enc_start_date <= g_enc_org_end_date) AND
					(psp_general.business_days(t_poeta_gl_hier_array(I).r_enc_start_date,
						t_poeta_gl_hier_array(I).r_enc_end_date,p_assignment_id) > 0)) THEN
					orig_ci.gl_code_combination_id(g_orig_pointer) := l_gl_code_combination_id;
					orig_ci.project_id(g_orig_pointer) := l_project_id;
					orig_ci.task_id(g_orig_pointer) := l_task_id;
					orig_ci.award_id(g_orig_pointer) := l_award_id;
					orig_ci.expenditure_organization_id(g_orig_pointer) := l_expenditure_org_id;
					orig_ci.expenditure_type(g_orig_pointer) := l_expenditure_type;
					g_orig_pointer := g_orig_pointer + 1;
					l_enc_period_count := r_enc_period.r_time_period_id.COUNT + 1;
					r_enc_period.r_period_ind(l_enc_period_count) := r_enc_period.r_period_ind(p_chunk_pointer);
					r_enc_period.r_period_start_date(l_enc_period_count) := r_enc_period.r_period_start_date(p_chunk_pointer);
					r_enc_period.r_period_end_date(l_enc_period_count) := r_enc_period.r_period_end_date(p_chunk_pointer);
					r_enc_period.r_asg_start_date(l_enc_period_count) := t_poeta_gl_hier_array(I).r_enc_start_date;
					r_enc_period.r_asg_end_date(l_enc_period_count) := LEAST(t_poeta_gl_hier_array(I).r_enc_end_date, g_enc_org_end_date);
					r_enc_period.r_effective_date(l_enc_period_count) := r_enc_period.r_effective_date(p_chunk_pointer);
					r_enc_period.r_time_period_id(l_enc_period_count) := r_enc_period.r_time_period_id(p_chunk_pointer);
					r_enc_period.r_process_flag(l_enc_period_count) := 'SA';
					r_enc_period.r_schedule_percent(l_enc_period_count) := 100;
					r_enc_period.r_encumbrance_amount(l_enc_period_count) :=
						ROUND(((l_daily_rate  * psp_general.business_days(t_poeta_gl_hier_array(I).r_enc_start_date, LEAST(t_poeta_gl_hier_array(I).r_enc_end_date, g_enc_org_end_date),p_assignment_id)) /
							psp_general.business_days(t_poeta_gl_hier_array(I).r_enc_start_date, t_poeta_gl_hier_array(I).r_enc_end_date,p_assignment_id)),g_ext_precision);
					r_enc_period.r_period_amount(l_enc_period_count) := r_enc_period.r_period_amount(p_chunk_pointer);
					r_enc_period.r_reason_code(l_enc_period_count) := l_patc_status;
				END IF;

				add_cel_warnings(p_start_date	=>	t_poeta_gl_hier_array(I).r_enc_start_date,
					p_end_date		=>	t_poeta_gl_hier_array(I).r_enc_end_date,
					p_hierarchy_code	=>	'SA',
					p_warning_code		=>	'INVALID_CI',
					p_project_id		=>	l_project_id,
					p_task_id		=>	l_task_id,
					p_award_id		=>	l_award_id,
					p_exp_org_id		=>	l_expenditure_org_id,
					p_exp_type		=>	l_expenditure_type,
					p_effective_date	=>	l_poeta_end_date,
					p_error_status		=>	l_patc_status);
			END IF;
		END LOOP;
	END IF;
	t_poeta_gl_hier_array.DELETE;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Leaving process_all_hier');
END process_all_hier;

PROCEDURE log_gl_hours_message IS
BEGIN
	add_cel_warnings(p_start_date	=>	l_asg_start_date,
		p_hierarchy_code	=>	'GL',
		p_end_date		=>	l_asg_end_date,
		p_warning_code		=>	'GL',
		p_percent		=>	ROUND(((l_earnings_amount*l_schedule_percent)/100), g_precision));
END log_gl_hours_message;

BEGIN
	l_proc_step := 10;
	l_proc_name := 'CREATE_LINES';

	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Entering ' || l_proc_name);
	hr_utility.trace('p_assignment_id: ' || fnd_number.number_to_canonical(p_assignment_id) ||
		' p_payroll_id: ' || fnd_number.number_to_canonical(p_payroll_id) ||
		' p_element_type_id: ' || fnd_number.number_to_canonical(p_element_type_id) ||
		' p_last_paid_date: ' || fnd_date.date_to_canonical(p_last_paid_date));

	p_return_status := fnd_api.g_ret_sts_success;

	OPEN c_person_id;
	FETCH c_person_id INTO l_person_id;
	CLOSE c_person_id;

	hr_utility.trace('l_person_id: ' || fnd_number.number_to_canonical(l_person_id));
	l_proc_step := 20;
	g_pateo_end_date := NULL;

	OPEN enc_period_cur;
	FETCH enc_period_cur BULK COLLECT INTO r_enc_period.r_time_period_id,
		r_enc_period.r_period_start_date,	r_enc_period.r_period_end_date,
		r_enc_period.r_asg_start_date,		r_enc_period.r_asg_end_date,
		r_enc_period.r_effective_date,		r_enc_period.r_process_flag,
		r_enc_period.r_schedule_percent,	r_enc_period.r_reason_code;
	CLOSE 	enc_period_cur;

	hr_utility.trace('r_enc_period.r_time_period_id.COUNT: ' || fnd_number.number_to_canonical(r_enc_period.r_time_period_id.COUNT));
	l_proc_step := 30;

	IF (r_enc_period.r_time_period_id.COUNT > 0) THEN
		load_sch_hierarchy(p_assignment_id, p_payroll_id, p_element_type_id, g_business_group_id, g_set_of_books_id, p_return_status);
		IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
	END IF;

	OPEN enc_period_cur;
	FETCH enc_period_cur BULK COLLECT INTO r_enc_period.r_time_period_id,
		r_enc_period.r_period_start_date,	r_enc_period.r_period_end_date,
		r_enc_period.r_asg_start_date,		r_enc_period.r_asg_end_date,
		r_enc_period.r_effective_date,		r_enc_period.r_process_flag,
		r_enc_period.r_schedule_percent,	r_enc_period.r_reason_code;
	CLOSE 	enc_period_cur;

	hr_utility.trace('Cutting down periods beyond MAX(poeta_end_date); r_enc_period.r_time_period_id.COUNT: ' || fnd_number.number_to_canonical(r_enc_period.r_time_period_id.COUNT));

	l_proc_step := 40;

	IF (r_enc_period.r_time_period_id.COUNT > 0) THEN
		sub_slice_asg_chunk(p_assignment_id, p_element_type_id, g_business_group_id, g_set_of_books_id, p_return_status);
		IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
	END IF;

	hr_utility.trace('r_enc_period.r_time_period_id.COUNT: ' || fnd_number.number_to_canonical(r_enc_period.r_time_period_id.COUNT));
	l_proc_step := 50;

	IF (r_enc_period.r_time_period_id.COUNT > 0) THEN
		determine_enc_amount(p_person_id	 =>	l_person_id,
			     p_assignment_id	 =>	p_assignment_id,
			     p_element_type_id	 =>	p_element_type_id,
			     p_business_group_id =>	g_business_group_id,
			     p_set_of_books_id   =>	g_set_of_books_id,
			     p_payroll_id	 =>	p_payroll_id,
			     p_return_status	 =>	l_return_status);
		IF l_return_status <> fnd_api.g_ret_sts_success THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
	END IF;

	l_proc_step := 60;
	g_et_pointer := 1;
	g_ec_pointer := 1;
	g_asg_pointer := 1;
	g_ge_pointer := 1;
	g_odls_pointer := 1;
	g_da_pointer := 1;
	g_sa_pointer := 1;
	g_orig_pointer := 1;
	l_orig_pointer := 1;
	l_chunk_pointer := 1;
	l_prev_enc_lines_counter := t_enc_lines_array.r_time_period_id.COUNT + 1;
	l_min_start_date := fnd_date.canonical_to_date('1800/01/01');
	l_max_end_date := LEAST(NVL(g_actual_term_date, g_enc_org_end_date), g_enc_org_end_date);
	l_ignore_start := -1;
	l_ignore_end := -1;

	IF (r_enc_period.r_asg_end_date.COUNT > 0) THEN
		l_min_start_date := r_enc_period.r_asg_start_date(1);
		l_max_end_date := LEAST(r_enc_period.r_asg_end_date(r_enc_period.r_asg_end_date.COUNT),
					l_max_end_date);

		IF (	(l_min_start_date > r_enc_period.r_period_start_date(1)) AND
			(psp_general.business_days(r_enc_period.r_period_start_date(1),
				r_enc_period.r_period_end_date(1),p_assignment_id) <>
				psp_general.business_days(l_min_start_date,
					r_enc_period.r_period_end_date(1),p_assignment_id))) THEN
			l_ignore_start := r_enc_period.r_time_period_id(1);
		END IF;

		IF (	(l_max_end_date < r_enc_period.r_period_end_date(r_enc_period.r_asg_end_date.COUNT)) AND
			(psp_general.business_days(r_enc_period.r_period_start_date(r_enc_period.r_asg_end_date.COUNT),
				r_enc_period.r_period_end_date(r_enc_period.r_asg_end_date.COUNT)) <>
				psp_general.business_days(r_enc_period.r_period_start_date(r_enc_period.r_asg_end_date.COUNT), l_max_end_date))) THEN
			l_ignore_end := r_enc_period.r_time_period_id(r_enc_period.r_asg_end_date.COUNT);
		END IF;
		hr_utility.trace('l_ignore_start: ' || l_ignore_start);
		hr_utility.trace('l_ignore_end: ' || l_ignore_end);
	END IF;

	LOOP
		EXIT WHEN (l_chunk_pointer > r_enc_period.r_time_period_id.COUNT);
		l_asg_start_date := r_enc_period.r_asg_start_date(l_chunk_pointer);
		l_asg_end_date := r_enc_period.r_asg_end_date(l_chunk_pointer);
		l_period_start_date := r_enc_period.r_period_start_date(l_chunk_pointer);
		l_period_end_date := r_enc_period.r_period_end_date(l_chunk_pointer);
		l_time_period_id := r_enc_period.r_time_period_id(l_chunk_pointer);
		l_process_flag := r_enc_period.r_process_flag(l_chunk_pointer);
		l_earnings_amount := r_enc_period.r_encumbrance_amount(l_chunk_pointer);
		l_period_ind := r_enc_period.r_period_ind(l_chunk_pointer);
		l_effective_date := r_enc_period.r_effective_date(l_chunk_pointer);
		l_reason_code := r_enc_period.r_reason_code(l_chunk_pointer);

		l_bus_days_in_chunk :=  psp_general.business_days(l_asg_start_date, l_asg_end_date,p_assignment_id);
		l_dist_amount := 0;
		l_schedule_line_id := NULL;
		l_org_schedule_id := NULL;
		l_element_account_id := NULL;
		l_default_account_id := NULL;
		l_suspense_account_id := NULL;

		hr_utility.trace('Processing chunk: CP: ' || l_chunk_pointer || ' TP: ' || l_time_period_id ||
		' PSD: ' || TO_CHAR(l_period_start_date, 'DD-MON-RRRR') || ' PED: ' || TO_CHAR(l_period_end_date, 'DD-MON-RRRR') ||
		' ASD: ' || TO_CHAR(l_asg_start_date, 'DD-MON-RRRR') || ' AED: ' || TO_CHAR(l_asg_end_date, 'DD-MON-RRRR') ||
		' PF: ' || l_process_flag || ' EA: ' || l_earnings_amount || ' ED: ' || TO_CHAR(l_effective_date, 'DD-MON-RRRR') ||
		' BD: ' || l_bus_days_in_chunk);

		hr_utility.trace('l_chunk_pointer: ' || fnd_number.number_to_canonical(l_chunk_pointer) ||
			' l_asg_start_date: ' || fnd_date.date_to_canonical(l_asg_start_date) ||
			' l_asg_end_date: ' || fnd_date.date_to_canonical(l_asg_end_date) ||
			' l_period_start_date: ' || fnd_date.date_to_canonical(l_period_start_date) ||
			' l_period_end_date: ' || fnd_date.date_to_canonical(l_period_end_date) ||
			' l_effective_date: ' || fnd_date.date_to_canonical(l_effective_date) ||
			' l_time_period_id: ' || fnd_number.number_to_canonical(l_time_period_id) ||
			' l_prev_time_period_id: ' || fnd_number.number_to_canonical(l_prev_time_period_id) ||
			' l_process_flag: ' || l_process_flag ||
			' l_earnings_amount: ' || fnd_number.number_to_canonical(l_earnings_amount) ||
			' r_enc_period.r_period_amount(l_chunk_pointer): ' || fnd_number.number_to_canonical(r_enc_period.r_period_amount(l_chunk_pointer)) ||
			' l_period_ind: ' || fnd_number.number_to_canonical(l_period_ind) ||
			' g_enc_lines_counter: ' || fnd_number.number_to_canonical(g_enc_lines_counter));

		l_proc_step := 70 + (l_chunk_pointer / 100000);

		IF (l_earnings_amount <> 0) AND (l_bus_days_in_chunk > 0) THEN
			IF (l_process_flag = 'ET') THEN
				FOR recno IN 1..r_et.line_account_id.COUNT
				LOOP
					IF ((l_asg_start_date <= r_et.end_date_active(recno))
						AND (l_asg_end_date >= r_et.start_date_active(recno))) THEN
						g_et_pointer := recno;
						l_schedule_line_id := r_et.line_account_id(recno);
						l_gl_code_combination_id := r_et.gl_code_combination_id(recno);
						l_project_id := r_et.project_id(recno);
						l_task_id := r_et.task_id(recno);
						l_award_id := r_et.award_id(recno);
						l_schedule_percent := r_et.percent(recno);
						l_expenditure_type := r_et.expenditure_type(recno);
						l_expenditure_org_id := r_et.expenditure_organization_id(recno);
						l_start_date_active := r_et.start_date_active(recno);
						l_end_date_active := r_et.end_date_active(recno);
						l_poeta_start_date := r_et.poeta_start_date(recno);
						l_poeta_end_date := r_et.poeta_end_date(recno);
						l_attribute_category := r_et.attribute_category(recno);
						l_attribute1 := r_et.attribute1(recno);
						l_attribute2 := r_et.attribute2(recno);
						l_attribute3 := r_et.attribute3(recno);
						l_attribute4 := r_et.attribute4(recno);
						l_attribute5 := r_et.attribute5(recno);
						l_attribute6 := r_et.attribute6(recno);
						l_attribute7 := r_et.attribute7(recno);
						l_attribute8 := r_et.attribute8(recno);
						l_attribute9 := r_et.attribute9(recno);
						l_attribute10 := r_et.attribute10(recno);
						l_acct_type := r_et.acct_type(recno);

						IF (g_uom = 'H' AND l_gl_code_combination_id IS NOT NULL) THEN
							log_gl_hours_message;
						ELSE

						IF (g_et_autopop = 'Y') THEN
							psp_autopop.main(p_acct_type		=> l_acct_type,
								p_person_id			=> l_person_id,
								p_assignment_id			=> p_assignment_id,
								p_element_type_id		=> p_element_type_id,
								p_project_id			=> l_project_id,
								p_expenditure_organization_id	=> l_expenditure_org_id,
								p_task_id			=> l_task_id,
								p_award_id			=> l_award_id,
								p_expenditure_type		=> l_expenditure_type,
								p_gl_code_combination_id	=> l_gl_code_combination_id,
                                                                p_payroll_date                  => l_asg_end_date,  --- replaced l_effective_date..5592784
								p_set_of_books_id		=> g_set_of_books_id,
								p_business_group_id		=> g_business_group_id,
								ret_expenditure_type		=> l_new_expenditure_type,
								ret_gl_code_combination_id	=> l_new_gl_code_combination_id,
								retcode				=> l_autopop_status);

							IF (l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
								(l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
								l_autopop_error := 'AUTO_POP_EXP_ERROR';
								IF (l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
									l_autopop_error := 'AUTO_POP_NO_VALUE';
								END IF;
								IF (l_asg_start_date <= g_enc_org_end_date) THEN
									orig_ci.gl_code_combination_id(g_orig_pointer) := l_gl_code_combination_id;
									orig_ci.project_id(g_orig_pointer) := l_project_id;
									orig_ci.task_id(g_orig_pointer) := l_task_id;
									orig_ci.award_id(g_orig_pointer) := l_award_id;
									orig_ci.expenditure_organization_id(g_orig_pointer) := l_expenditure_org_id;
									orig_ci.expenditure_type(g_orig_pointer) := l_expenditure_type;
									g_orig_pointer := g_orig_pointer + 1;
									l_enc_period_count := r_enc_period.r_time_period_id.COUNT + 1;
									r_enc_period.r_period_ind(l_enc_period_count) := r_enc_period.r_period_ind(l_chunk_pointer);
									r_enc_period.r_period_start_date(l_enc_period_count) := r_enc_period.r_period_start_date(l_chunk_pointer);
									r_enc_period.r_period_end_date(l_enc_period_count) := r_enc_period.r_period_end_date(l_chunk_pointer);
									r_enc_period.r_asg_start_date(l_enc_period_count) := r_enc_period.r_asg_start_date(l_chunk_pointer);
									r_enc_period.r_asg_end_date(l_enc_period_count) := LEAST(r_enc_period.r_asg_end_date(l_chunk_pointer), g_enc_org_end_date);
									r_enc_period.r_effective_date(l_enc_period_count) := r_enc_period.r_effective_date(l_chunk_pointer);
									r_enc_period.r_time_period_id(l_enc_period_count) := r_enc_period.r_time_period_id(l_chunk_pointer);
									r_enc_period.r_process_flag(l_enc_period_count) := 'SA';
									r_enc_period.r_schedule_percent(l_enc_period_count) := 100;
									r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND(r_enc_period.r_encumbrance_amount(l_chunk_pointer) *
										(psp_general.business_days(l_asg_start_date, r_enc_period.r_asg_end_date(l_enc_period_count)) / l_bus_days_in_chunk));
									r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND((r_enc_period.r_encumbrance_amount(l_chunk_pointer) * l_schedule_percent/100),g_ext_precision);
									r_enc_period.r_period_amount(l_enc_period_count) := r_enc_period.r_period_amount(l_chunk_pointer);
									r_enc_period.r_reason_code(l_enc_period_count) := l_autopop_error;
								END IF;
								add_cel_warnings(p_start_date	=>	r_enc_period.r_asg_start_date(l_chunk_pointer),
									p_hierarchy_code	=>	'SA',
									p_end_date		=>	r_enc_period.r_asg_end_date(l_chunk_pointer),
									p_warning_code	=>	'AUTOPOP',
									p_gl_ccid			=>	l_gl_code_combination_id,
									p_project_id		=>	l_project_id,
									p_task_id			=>	l_task_id,
									p_award_id			=>	l_award_id,
									p_exp_org_id		=>	l_expenditure_org_id,
									p_exp_type			=>	l_expenditure_type,
									p_effective_date	=>	l_effective_date,
									p_error_status	=>	l_autopop_error);
								hr_utility.trace('Posting to suspense account');
							ELSE
								IF (l_acct_type = 'E') THEN
									psp_enc_pre_process.validate_poeta (p_project_id		=>	l_project_id,
										p_task_id			=>	l_task_id,
										p_award_id			=>	l_award_id,
										p_expenditure_type		=>	l_new_expenditure_type,
										p_expenditure_organization_id	=>	l_expenditure_org_id,
										p_payroll_id			=>	p_payroll_id,
										p_start_date			=>	l_poeta_start_date,
										p_end_date			=>	l_poeta_end_date,
										p_return_status			=>	p_return_status);
									IF p_return_status <> fnd_api.g_ret_sts_success THEN
										RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
									END IF;
									l_expenditure_type := l_new_expenditure_type;
								ELSE
									l_gl_code_combination_id := l_new_gl_code_combination_id;
								END IF;
								process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
							END IF;
						ELSE
							process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
						END IF;
					END IF;
				   END IF;
				END LOOP;
			ELSIF (l_process_flag = 'EG') THEN
				FOR recno IN 1..r_ec.line_account_id.COUNT
				LOOP
					IF ((l_asg_start_date <= r_ec.end_date_active(recno))
						AND (l_asg_end_date >= r_ec.start_date_active(recno))) THEN
						g_ec_pointer := recno;
						l_schedule_line_id := r_ec.line_account_id(recno);
						l_gl_code_combination_id := r_ec.gl_code_combination_id(recno);
						l_project_id := r_ec.project_id(recno);
						l_task_id := r_ec.task_id(recno);
						l_award_id := r_ec.award_id(recno);
						l_schedule_percent := r_ec.percent(recno);
						l_expenditure_type := r_ec.expenditure_type(recno);
						l_expenditure_org_id := r_ec.expenditure_organization_id(recno);
						l_start_date_active := r_ec.start_date_active(recno);
						l_end_date_active := r_ec.end_date_active(recno);
						l_poeta_start_date := r_ec.poeta_start_date(recno);
						l_poeta_end_date := r_ec.poeta_end_date(recno);
						l_attribute_category := r_ec.attribute_category(recno);
						l_attribute1 := r_ec.attribute1(recno);
						l_attribute2 := r_ec.attribute2(recno);
						l_attribute3 := r_ec.attribute3(recno);
						l_attribute4 := r_ec.attribute4(recno);
						l_attribute5 := r_ec.attribute5(recno);
						l_attribute6 := r_ec.attribute6(recno);
						l_attribute7 := r_ec.attribute7(recno);
						l_attribute8 := r_ec.attribute8(recno);
						l_attribute9 := r_ec.attribute9(recno);
						l_attribute10 := r_ec.attribute10(recno);
						l_acct_type := r_ec.acct_type(recno);

						IF (g_uom = 'H' AND l_gl_code_combination_id IS NOT NULL) THEN
							log_gl_hours_message;
						ELSE
  						 IF (g_eg_autopop = 'Y') THEN
							psp_autopop.main(p_acct_type		=> l_acct_type,
								p_person_id			=> l_person_id,
								p_assignment_id			=> p_assignment_id,
								p_element_type_id		=> p_element_type_id,
								p_project_id			=> l_project_id,
								p_expenditure_organization_id	=> l_expenditure_org_id,
								p_task_id			=> l_task_id,
								p_award_id			=> l_award_id,
								p_expenditure_type		=> l_expenditure_type,
								p_gl_code_combination_id	=> l_gl_code_combination_id,
                                                                p_payroll_date                  => l_asg_end_date,  --- replaced l_effective_date..5592784
								p_set_of_books_id		=> g_set_of_books_id,
								p_business_group_id		=> g_business_group_id,
								ret_expenditure_type		=> l_new_expenditure_type,
								ret_gl_code_combination_id	=> l_new_gl_code_combination_id,
								retcode				=> l_autopop_status);

							IF (l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
								(l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
								l_autopop_error := 'AUTO_POP_EXP_ERROR';
								IF (l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
									l_autopop_error := 'AUTO_POP_NO_VALUE';
								END IF;
								IF (l_asg_start_date <= g_enc_org_end_date) THEN
									orig_ci.gl_code_combination_id(g_orig_pointer) := l_gl_code_combination_id;
									orig_ci.project_id(g_orig_pointer) := l_project_id;
									orig_ci.task_id(g_orig_pointer) := l_task_id;
									orig_ci.award_id(g_orig_pointer) := l_award_id;
									orig_ci.expenditure_organization_id(g_orig_pointer) := l_expenditure_org_id;
									orig_ci.expenditure_type(g_orig_pointer) := l_expenditure_type;
									g_orig_pointer := g_orig_pointer + 1;
									l_enc_period_count := r_enc_period.r_time_period_id.COUNT + 1;
									r_enc_period.r_period_ind(l_enc_period_count) := r_enc_period.r_period_ind(l_chunk_pointer);
									r_enc_period.r_period_start_date(l_enc_period_count) := r_enc_period.r_period_start_date(l_chunk_pointer);
									r_enc_period.r_period_end_date(l_enc_period_count) := r_enc_period.r_period_end_date(l_chunk_pointer);
									r_enc_period.r_asg_start_date(l_enc_period_count) := r_enc_period.r_asg_start_date(l_chunk_pointer);
									r_enc_period.r_asg_end_date(l_enc_period_count) := LEAST(r_enc_period.r_asg_end_date(l_chunk_pointer), g_enc_org_end_date);
									r_enc_period.r_effective_date(l_enc_period_count) := r_enc_period.r_effective_date(l_chunk_pointer);
									r_enc_period.r_time_period_id(l_enc_period_count) := r_enc_period.r_time_period_id(l_chunk_pointer);
									r_enc_period.r_process_flag(l_enc_period_count) := 'SA';
									r_enc_period.r_schedule_percent(l_enc_period_count) := 100;
									r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND(r_enc_period.r_encumbrance_amount(l_chunk_pointer) *
										(psp_general.business_days(l_asg_start_date, r_enc_period.r_asg_end_date(l_enc_period_count)) / l_bus_days_in_chunk));
									r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND((r_enc_period.r_encumbrance_amount(l_chunk_pointer) * l_schedule_percent/100),g_ext_precision);
									r_enc_period.r_period_amount(l_enc_period_count) := r_enc_period.r_period_amount(l_chunk_pointer);
									r_enc_period.r_reason_code(l_enc_period_count) := l_autopop_error;
								END IF;
								add_cel_warnings(p_start_date	=>	r_enc_period.r_asg_start_date(l_chunk_pointer),
									p_hierarchy_code	=>	'SA',
									p_end_date		=>	r_enc_period.r_asg_end_date(l_chunk_pointer),
									p_warning_code	=>	'AUTOPOP',
									p_gl_ccid			=>	l_gl_code_combination_id,
									p_project_id		=>	l_project_id,
									p_task_id			=>	l_task_id,
									p_award_id			=>	l_award_id,
									p_exp_org_id		=>	l_expenditure_org_id,
									p_exp_type			=>	l_expenditure_type,
									p_effective_date	=>	l_effective_date,
									p_error_status	=>	l_autopop_error);
								hr_utility.trace('Posting to suspense account');
							ELSE
								IF (l_acct_type = 'E') THEN
									psp_enc_pre_process.validate_poeta (p_project_id		=>	l_project_id,
										p_task_id			=>	l_task_id,
										p_award_id			=>	l_award_id,
										p_expenditure_type		=>	l_new_expenditure_type,
										p_expenditure_organization_id	=>	l_expenditure_org_id,
										p_payroll_id			=>	p_payroll_id,
										p_start_date			=>	l_poeta_start_date,
										p_end_date			=>	l_poeta_end_date,
										p_return_status			=>	p_return_status);
									IF p_return_status <> fnd_api.g_ret_sts_success THEN
										RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
									END IF;
									l_expenditure_type := l_new_expenditure_type;
								ELSE
									l_gl_code_combination_id := l_new_gl_code_combination_id;
								END IF;
								process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
							END IF;
						ELSE
							process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
						END IF;
					 END IF;
				   END IF;
				END LOOP;
			ELSIF (l_process_flag = 'A') THEN
				FOR recno IN 1..r_asg.line_account_id.COUNT
				LOOP
					 IF ((l_asg_start_date <= r_asg.end_date_active(recno))
						AND (l_asg_end_date >= r_asg.start_date_active(recno))) THEN
						g_asg_pointer := recno;
						l_schedule_line_id := r_asg.line_account_id(recno);
						l_gl_code_combination_id := r_asg.gl_code_combination_id(recno);
						l_project_id := r_asg.project_id(recno);
						l_task_id := r_asg.task_id(recno);
						l_award_id := r_asg.award_id(recno);
						l_schedule_percent := r_asg.percent(recno);
						l_expenditure_type := r_asg.expenditure_type(recno);
						l_expenditure_org_id := r_asg.expenditure_organization_id(recno);
						l_start_date_active := r_asg.start_date_active(recno);
						l_end_date_active := r_asg.end_date_active(recno);
						l_poeta_start_date := r_asg.poeta_start_date(recno);
						l_poeta_end_date := r_asg.poeta_end_date(recno);
						l_attribute_category := r_asg.attribute_category(recno);
						l_attribute1 := r_asg.attribute1(recno);
						l_attribute2 := r_asg.attribute2(recno);
						l_attribute3 := r_asg.attribute3(recno);
						l_attribute4 := r_asg.attribute4(recno);
						l_attribute5 := r_asg.attribute5(recno);
						l_attribute6 := r_asg.attribute6(recno);
						l_attribute7 := r_asg.attribute7(recno);
						l_attribute8 := r_asg.attribute8(recno);
						l_attribute9 := r_asg.attribute9(recno);
						l_attribute10 := r_asg.attribute10(recno);
						l_acct_type := r_asg.acct_type(recno);

						IF (g_uom = 'H' AND l_gl_code_combination_id IS NOT NULL) THEN
							log_gl_hours_message;
						ELSE
  						 IF (g_as_autopop = 'Y') THEN
							psp_autopop.main(p_acct_type		=> l_acct_type,
								p_person_id			=> l_person_id,
								p_assignment_id			=> p_assignment_id,
								p_element_type_id		=> p_element_type_id,
								p_project_id			=> l_project_id,
								p_expenditure_organization_id	=> l_expenditure_org_id,
								p_task_id			=> l_task_id,
								p_award_id			=> l_award_id,
								p_expenditure_type		=> l_expenditure_type,
								p_gl_code_combination_id	=> l_gl_code_combination_id,
                                                                p_payroll_date                  => l_asg_end_date,  --- replaced l_effective_date..5592784
								p_set_of_books_id		=> g_set_of_books_id,
								p_business_group_id		=> g_business_group_id,
								ret_expenditure_type		=> l_new_expenditure_type,
								ret_gl_code_combination_id	=> l_new_gl_code_combination_id,
								retcode				=> l_autopop_status);

							IF (l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
								(l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
								l_autopop_error := 'AUTO_POP_EXP_ERROR';
								IF (l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
									l_autopop_error := 'AUTO_POP_NO_VALUE';
								END IF;
								IF (l_asg_start_date <= g_enc_org_end_date) THEN
									orig_ci.gl_code_combination_id(g_orig_pointer) := l_gl_code_combination_id;
									orig_ci.project_id(g_orig_pointer) := l_project_id;
									orig_ci.task_id(g_orig_pointer) := l_task_id;
									orig_ci.award_id(g_orig_pointer) := l_award_id;
									orig_ci.expenditure_organization_id(g_orig_pointer) := l_expenditure_org_id;
									orig_ci.expenditure_type(g_orig_pointer) := l_expenditure_type;
									g_orig_pointer := g_orig_pointer + 1;
									l_enc_period_count := r_enc_period.r_time_period_id.COUNT + 1;
									r_enc_period.r_period_ind(l_enc_period_count) := r_enc_period.r_period_ind(l_chunk_pointer);
									r_enc_period.r_period_start_date(l_enc_period_count) := r_enc_period.r_period_start_date(l_chunk_pointer);
									r_enc_period.r_period_end_date(l_enc_period_count) := r_enc_period.r_period_end_date(l_chunk_pointer);
									r_enc_period.r_asg_start_date(l_enc_period_count) := r_enc_period.r_asg_start_date(l_chunk_pointer);
									r_enc_period.r_asg_end_date(l_enc_period_count) := LEAST(r_enc_period.r_asg_end_date(l_chunk_pointer), g_enc_org_end_date);
									r_enc_period.r_effective_date(l_enc_period_count) := r_enc_period.r_effective_date(l_chunk_pointer);
									r_enc_period.r_time_period_id(l_enc_period_count) := r_enc_period.r_time_period_id(l_chunk_pointer);
									r_enc_period.r_process_flag(l_enc_period_count) := 'SA';
									r_enc_period.r_schedule_percent(l_enc_period_count) := 100;
									r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND(r_enc_period.r_encumbrance_amount(l_chunk_pointer) *
										(psp_general.business_days(l_asg_start_date, r_enc_period.r_asg_end_date(l_enc_period_count)) / l_bus_days_in_chunk));
									r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND((r_enc_period.r_encumbrance_amount(l_chunk_pointer) * l_schedule_percent/100),g_ext_precision);
									r_enc_period.r_period_amount(l_enc_period_count) := r_enc_period.r_period_amount(l_chunk_pointer);
									r_enc_period.r_reason_code(l_enc_period_count) := l_autopop_error;
								END IF;
								add_cel_warnings(p_start_date	=>	r_enc_period.r_asg_start_date(l_chunk_pointer),
									p_hierarchy_code	=>	'SA',
									p_end_date		=>	r_enc_period.r_asg_end_date(l_chunk_pointer),
									p_warning_code	=>	'AUTOPOP',
									p_gl_ccid			=>	l_gl_code_combination_id,
									p_project_id		=>	l_project_id,
									p_task_id			=>	l_task_id,
									p_award_id			=>	l_award_id,
									p_exp_org_id		=>	l_expenditure_org_id,
									p_exp_type			=>	l_expenditure_type,
									p_effective_date	=>	l_effective_date,
									p_error_status	=>	l_autopop_error);
								hr_utility.trace('Posting to suspense account');
							ELSE
								IF (l_acct_type = 'E') THEN
									psp_enc_pre_process.validate_poeta (p_project_id		=>	l_project_id,
										p_task_id			=>	l_task_id,
										p_award_id			=>	l_award_id,
										p_expenditure_type		=>	l_new_expenditure_type,
										p_expenditure_organization_id	=>	l_expenditure_org_id,
										p_payroll_id			=>	p_payroll_id,
										p_start_date			=>	l_poeta_start_date,
										p_end_date			=>	l_poeta_end_date,
										p_return_status			=>	p_return_status);
									IF p_return_status <> fnd_api.g_ret_sts_success THEN
										RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
									END IF;
									l_expenditure_type := l_new_expenditure_type;
								ELSE
									l_gl_code_combination_id := l_new_gl_code_combination_id;
								END IF;
								process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
							END IF;
						ELSE
							process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
						END IF;
					END IF;
				   End IF;
				END LOOP;
			ELSIF (l_process_flag = 'GE') THEN
				FOR recno IN 1..r_gee.line_account_id.COUNT
				LOOP
					g_ge_pointer := recno;
					EXIT WHEN ((l_asg_start_date <= r_gee.end_date_active(recno))
						AND (l_asg_end_date >= r_gee.start_date_active(recno)));
				END LOOP;
				FOR recno IN g_ge_pointer..r_gee.line_account_id.COUNT
				LOOP
					EXIT WHEN (NOT ((l_asg_start_date <= r_gee.end_date_active(recno))
						AND (l_asg_end_date >= r_gee.start_date_active(recno))));

					g_ge_pointer := recno;
					l_element_account_id := r_gee.line_account_id(recno);
					l_gl_code_combination_id := r_gee.gl_code_combination_id(recno);
					l_project_id := r_gee.project_id(recno);
					l_task_id := r_gee.task_id(recno);
					l_award_id := r_gee.award_id(recno);
					l_schedule_percent := r_gee.percent(recno);
					l_expenditure_type := r_gee.expenditure_type(recno);
					l_expenditure_org_id := r_gee.expenditure_organization_id(recno);
					l_start_date_active := r_gee.start_date_active(recno);
					l_end_date_active := r_gee.end_date_active(recno);
					l_poeta_start_date := r_gee.poeta_start_date(recno);
					l_poeta_end_date := r_gee.poeta_end_date(recno);
					l_attribute_category := r_gee.attribute_category(recno);
					l_attribute1 := r_gee.attribute1(recno);
					l_attribute2 := r_gee.attribute2(recno);
					l_attribute3 := r_gee.attribute3(recno);
					l_attribute4 := r_gee.attribute4(recno);
					l_attribute5 := r_gee.attribute5(recno);
					l_attribute6 := r_gee.attribute6(recno);
					l_attribute7 := r_gee.attribute7(recno);
					l_attribute8 := r_gee.attribute8(recno);
					l_attribute9 := r_gee.attribute9(recno);
					l_attribute10 := r_gee.attribute10(recno);
					l_acct_type := r_gee.acct_type(recno);

					IF (g_uom = 'H' AND l_gl_code_combination_id IS NOT NULL) THEN
						log_gl_hours_message;
					ELSE

						IF (g_ge_autopop = 'Y') THEN
							psp_autopop.main(p_acct_type		=> l_acct_type,
							p_person_id			=> l_person_id,
							p_assignment_id			=> p_assignment_id,
							p_element_type_id		=> p_element_type_id,
							p_project_id			=> l_project_id,
							p_expenditure_organization_id	=> l_expenditure_org_id,
							p_task_id			=> l_task_id,
							p_award_id			=> l_award_id,
							p_expenditure_type		=> l_expenditure_type,
							p_gl_code_combination_id	=> l_gl_code_combination_id,
                                                        p_payroll_date                  => l_asg_end_date,  --- replaced l_effective_date..5592784
							p_set_of_books_id		=> g_set_of_books_id,
							p_business_group_id		=> g_business_group_id,
							ret_expenditure_type		=> l_new_expenditure_type,
							ret_gl_code_combination_id	=> l_new_gl_code_combination_id,
							retcode				=> l_autopop_status);

						IF (l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
							(l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
							l_autopop_error := 'AUTO_POP_EXP_ERROR';
							IF (l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
								l_autopop_error := 'AUTO_POP_NO_VALUE';
							END IF;
							IF (l_asg_start_date <= g_enc_org_end_date) THEN
								orig_ci.gl_code_combination_id(g_orig_pointer) := l_gl_code_combination_id;
								orig_ci.project_id(g_orig_pointer) := l_project_id;
								orig_ci.task_id(g_orig_pointer) := l_task_id;
								orig_ci.award_id(g_orig_pointer) := l_award_id;
								orig_ci.expenditure_organization_id(g_orig_pointer) := l_expenditure_org_id;
								orig_ci.expenditure_type(g_orig_pointer) := l_expenditure_type;
								g_orig_pointer := g_orig_pointer + 1;
								l_enc_period_count := r_enc_period.r_time_period_id.COUNT + 1;
								r_enc_period.r_period_ind(l_enc_period_count) := r_enc_period.r_period_ind(l_chunk_pointer);
								r_enc_period.r_period_start_date(l_enc_period_count) := r_enc_period.r_period_start_date(l_chunk_pointer);
								r_enc_period.r_period_end_date(l_enc_period_count) := r_enc_period.r_period_end_date(l_chunk_pointer);
								r_enc_period.r_asg_start_date(l_enc_period_count) := r_enc_period.r_asg_start_date(l_chunk_pointer);
								r_enc_period.r_asg_end_date(l_enc_period_count) := LEAST(r_enc_period.r_asg_end_date(l_chunk_pointer), g_enc_org_end_date);
								r_enc_period.r_effective_date(l_enc_period_count) := r_enc_period.r_effective_date(l_chunk_pointer);
								r_enc_period.r_time_period_id(l_enc_period_count) := r_enc_period.r_time_period_id(l_chunk_pointer);
								r_enc_period.r_process_flag(l_enc_period_count) := 'SA';
								r_enc_period.r_schedule_percent(l_enc_period_count) := 100;
								r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND(r_enc_period.r_encumbrance_amount(l_chunk_pointer) *
									(psp_general.business_days(l_asg_start_date, r_enc_period.r_asg_end_date(l_enc_period_count)) / l_bus_days_in_chunk));
								r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND((r_enc_period.r_encumbrance_amount(l_chunk_pointer) * l_schedule_percent/100),g_ext_precision);
								r_enc_period.r_period_amount(l_enc_period_count) := r_enc_period.r_period_amount(l_chunk_pointer);
								r_enc_period.r_reason_code(l_enc_period_count) := l_autopop_error;
							END IF;
							add_cel_warnings(p_start_date	=>	r_enc_period.r_asg_start_date(l_chunk_pointer),
								p_hierarchy_code	=>	'SA',
								p_end_date		=>	r_enc_period.r_asg_end_date(l_chunk_pointer),
								p_warning_code	=>	'AUTOPOP',
								p_gl_ccid			=>	l_gl_code_combination_id,
								p_project_id		=>	l_project_id,
								p_task_id			=>	l_task_id,
								p_award_id			=>	l_award_id,
								p_exp_org_id		=>	l_expenditure_org_id,
								p_exp_type			=>	l_expenditure_type,
								p_effective_date	=>	l_effective_date,
								p_error_status	=>	l_autopop_error);
							hr_utility.trace('Posting to suspense account');
						ELSE
							IF (l_acct_type = 'E') THEN
								psp_enc_pre_process.validate_poeta (p_project_id		=>	l_project_id,
									p_task_id			=>	l_task_id,
									p_award_id			=>	l_award_id,
									p_expenditure_type		=>	l_new_expenditure_type,
									p_expenditure_organization_id	=>	l_expenditure_org_id,
									p_payroll_id			=>	p_payroll_id,
									p_start_date			=>	l_poeta_start_date,
									p_end_date			=>	l_poeta_end_date,
									p_return_status			=>	p_return_status);
								IF p_return_status <> fnd_api.g_ret_sts_success THEN
									RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
								END IF;
								l_expenditure_type := l_new_expenditure_type;
							ELSE
								l_gl_code_combination_id := l_new_gl_code_combination_id;
							END IF;
							process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
						END IF;
					ELSE
						process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
					END IF;
                                  END IF;
				END LOOP;
			ELSIF (l_process_flag = 'DS') THEN
				FOR recno IN 1..r_odls.line_account_id.COUNT
				LOOP
					g_odls_pointer := recno;
					EXIT WHEN ((l_asg_start_date <= r_odls.end_date_active(recno))
						AND (l_asg_end_date >= r_odls.start_date_active(recno)));
				END LOOP;
				FOR recno IN g_odls_pointer..r_odls.line_account_id.COUNT
				LOOP
					EXIT WHEN (NOT ((l_asg_start_date <= r_odls.end_date_active(recno))
						AND (l_asg_end_date >= r_odls.start_date_active(recno))));

					g_odls_pointer := recno;
					l_org_schedule_id := r_odls.line_account_id(recno);
					l_gl_code_combination_id := r_odls.gl_code_combination_id(recno);
					l_project_id := r_odls.project_id(recno);
					l_task_id := r_odls.task_id(recno);
					l_award_id := r_odls.award_id(recno);
					l_schedule_percent := r_odls.percent(recno);
					l_expenditure_type := r_odls.expenditure_type(recno);
					l_expenditure_org_id := r_odls.expenditure_organization_id(recno);
					l_start_date_active := r_odls.start_date_active(recno);
					l_end_date_active := r_odls.end_date_active(recno);
					l_poeta_start_date := r_odls.poeta_start_date(recno);
					l_poeta_end_date := r_odls.poeta_end_date(recno);
					l_attribute_category := r_odls.attribute_category(recno);
					l_attribute1 := r_odls.attribute1(recno);
					l_attribute2 := r_odls.attribute2(recno);
					l_attribute3 := r_odls.attribute3(recno);
					l_attribute4 := r_odls.attribute4(recno);
					l_attribute5 := r_odls.attribute5(recno);
					l_attribute6 := r_odls.attribute6(recno);
					l_attribute7 := r_odls.attribute7(recno);
					l_attribute8 := r_odls.attribute8(recno);
					l_attribute9 := r_odls.attribute9(recno);
					l_attribute10 := r_odls.attribute10(recno);
					l_acct_type := r_odls.acct_type(recno);

					IF (g_uom = 'H' AND l_gl_code_combination_id IS NOT NULL) THEN
						log_gl_hours_message;
					ELSE
						IF (g_ds_autopop = 'Y') THEN
							psp_autopop.main(p_acct_type		=> l_acct_type,
							p_person_id			=> l_person_id,
							p_assignment_id			=> p_assignment_id,
							p_element_type_id		=> p_element_type_id,
							p_project_id			=> l_project_id,
							p_expenditure_organization_id	=> l_expenditure_org_id,
							p_task_id			=> l_task_id,
							p_award_id			=> l_award_id,
							p_expenditure_type		=> l_expenditure_type,
							p_gl_code_combination_id	=> l_gl_code_combination_id,
                                                        p_payroll_date                  => l_asg_end_date,  --- replaced l_effective_date..5592784
							p_set_of_books_id		=> g_set_of_books_id,
							p_business_group_id		=> g_business_group_id,
							ret_expenditure_type		=> l_new_expenditure_type,
							ret_gl_code_combination_id	=> l_new_gl_code_combination_id,
							retcode				=> l_autopop_status);

						IF (l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
							(l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
							l_autopop_error := 'AUTO_POP_EXP_ERROR';
							IF (l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
								l_autopop_error := 'AUTO_POP_NO_VALUE';
							END IF;
							IF (l_asg_start_date <= g_enc_org_end_date) THEN
								orig_ci.gl_code_combination_id(g_orig_pointer) := l_gl_code_combination_id;
								orig_ci.project_id(g_orig_pointer) := l_project_id;
								orig_ci.task_id(g_orig_pointer) := l_task_id;
								orig_ci.award_id(g_orig_pointer) := l_award_id;
								orig_ci.expenditure_organization_id(g_orig_pointer) := l_expenditure_org_id;
								orig_ci.expenditure_type(g_orig_pointer) := l_expenditure_type;
								g_orig_pointer := g_orig_pointer + 1;
								l_enc_period_count := r_enc_period.r_time_period_id.COUNT + 1;
								r_enc_period.r_period_ind(l_enc_period_count) := r_enc_period.r_period_ind(l_chunk_pointer);
								r_enc_period.r_period_start_date(l_enc_period_count) := r_enc_period.r_period_start_date(l_chunk_pointer);
								r_enc_period.r_period_end_date(l_enc_period_count) := r_enc_period.r_period_end_date(l_chunk_pointer);
								r_enc_period.r_asg_start_date(l_enc_period_count) := r_enc_period.r_asg_start_date(l_chunk_pointer);
								r_enc_period.r_asg_end_date(l_enc_period_count) := LEAST(r_enc_period.r_asg_end_date(l_chunk_pointer), g_enc_org_end_date);
								r_enc_period.r_effective_date(l_enc_period_count) := r_enc_period.r_effective_date(l_chunk_pointer);
								r_enc_period.r_time_period_id(l_enc_period_count) := r_enc_period.r_time_period_id(l_chunk_pointer);
								r_enc_period.r_process_flag(l_enc_period_count) := 'SA';
								r_enc_period.r_schedule_percent(l_enc_period_count) := 100;
								r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND(r_enc_period.r_encumbrance_amount(l_chunk_pointer) *
									(psp_general.business_days(l_asg_start_date, r_enc_period.r_asg_end_date(l_enc_period_count)) / l_bus_days_in_chunk));
								r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND((r_enc_period.r_encumbrance_amount(l_chunk_pointer) * l_schedule_percent/100),g_ext_precision);
								r_enc_period.r_period_amount(l_enc_period_count) := r_enc_period.r_period_amount(l_chunk_pointer);
								r_enc_period.r_reason_code(l_enc_period_count) := l_autopop_error;
							END IF;
							add_cel_warnings(p_start_date	=>	r_enc_period.r_asg_start_date(l_chunk_pointer),
								p_hierarchy_code	=>	'SA',
								p_end_date		=>	r_enc_period.r_asg_end_date(l_chunk_pointer),
								p_warning_code	=>	'AUTOPOP',
								p_gl_ccid			=>	l_gl_code_combination_id,
								p_project_id		=>	l_project_id,
								p_task_id			=>	l_task_id,
								p_award_id			=>	l_award_id,
								p_exp_org_id		=>	l_expenditure_org_id,
								p_exp_type			=>	l_expenditure_type,
								p_effective_date	=>	l_effective_date,
								p_error_status	=>	l_autopop_error);
							hr_utility.trace('Posting to suspense account');
						ELSE
							IF (l_acct_type = 'E') THEN
								psp_enc_pre_process.validate_poeta (p_project_id		=>	l_project_id,
									p_task_id			=>	l_task_id,
									p_award_id			=>	l_award_id,
									p_expenditure_type		=>	l_new_expenditure_type,
									p_expenditure_organization_id	=>	l_expenditure_org_id,
									p_payroll_id			=>	p_payroll_id,
									p_start_date			=>	l_poeta_start_date,
									p_end_date			=>	l_poeta_end_date,
									p_return_status			=>	p_return_status);
								IF p_return_status <> fnd_api.g_ret_sts_success THEN
									RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
								END IF;
								l_expenditure_type := l_new_expenditure_type;
							ELSE
								l_gl_code_combination_id := l_new_gl_code_combination_id;
							END IF;
							process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
						END IF;
					ELSE
						process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
					END IF;
                                   END IF;
				END LOOP;
			ELSIF (l_process_flag = 'DA') THEN
				FOR recno IN 1..r_da.line_account_id.COUNT
				LOOP
					g_da_pointer := recno;
					EXIT WHEN ((l_asg_start_date <= r_da.end_date_active(recno))
						AND (l_asg_end_date >= r_da.start_date_active(recno)));
				END LOOP;

				FOR recno IN g_da_pointer..r_da.line_account_id.COUNT
				LOOP
					EXIT WHEN (NOT ((l_asg_start_date <= r_da.end_date_active(recno))
						AND (l_asg_end_date >= r_da.start_date_active(recno))));

					g_da_pointer := recno;
					l_default_account_id := r_da.line_account_id(recno);
					l_gl_code_combination_id := r_da.gl_code_combination_id(recno);
					l_project_id := r_da.project_id(recno);
					l_task_id := r_da.task_id(recno);
					l_award_id := r_da.award_id(recno);
					l_schedule_percent := r_da.percent(recno);
					l_expenditure_type := r_da.expenditure_type(recno);
					l_expenditure_org_id := r_da.expenditure_organization_id(recno);
					l_start_date_active := r_da.start_date_active(recno);
					l_end_date_active := r_da.end_date_active(recno);
					l_poeta_start_date := r_da.poeta_start_date(recno);
					l_poeta_end_date := r_da.poeta_end_date(recno);
					l_attribute_category := r_da.attribute_category(recno);
					l_attribute1 := r_da.attribute1(recno);
					l_attribute2 := r_da.attribute2(recno);
					l_attribute3 := r_da.attribute3(recno);
					l_attribute4 := r_da.attribute4(recno);
					l_attribute5 := r_da.attribute5(recno);
					l_attribute6 := r_da.attribute6(recno);
					l_attribute7 := r_da.attribute7(recno);
					l_attribute8 := r_da.attribute8(recno);
					l_attribute9 := r_da.attribute9(recno);
					l_attribute10 := r_da.attribute10(recno);
					l_acct_type := r_da.acct_type(recno);

					IF (g_uom = 'H' AND l_gl_code_combination_id IS NOT NULL) THEN
						log_gl_hours_message;
					ELSE

						IF (g_da_autopop = 'Y') THEN
							psp_autopop.main(p_acct_type		=> l_acct_type,
							p_person_id			=> l_person_id,
							p_assignment_id			=> p_assignment_id,
							p_element_type_id		=> p_element_type_id,
							p_project_id			=> l_project_id,
							p_expenditure_organization_id	=> l_expenditure_org_id,
							p_task_id			=> l_task_id,
							p_award_id			=> l_award_id,
							p_expenditure_type		=> l_expenditure_type,
							p_gl_code_combination_id	=> l_gl_code_combination_id,
                                                        p_payroll_date                  => l_asg_end_date,  --- replaced l_effective_date..5592784
							p_set_of_books_id		=> g_set_of_books_id,
							p_business_group_id		=> g_business_group_id,
							ret_expenditure_type		=> l_new_expenditure_type,
							ret_gl_code_combination_id	=> l_new_gl_code_combination_id,
							retcode				=> l_autopop_status);

						IF (l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
							(l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
							l_autopop_error := 'AUTO_POP_EXP_ERROR';
							IF (l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
								l_autopop_error := 'AUTO_POP_NO_VALUE';
							END IF;
							IF (l_asg_start_date <= g_enc_org_end_date) THEN
								orig_ci.gl_code_combination_id(g_orig_pointer) := l_gl_code_combination_id;
								orig_ci.project_id(g_orig_pointer) := l_project_id;
								orig_ci.task_id(g_orig_pointer) := l_task_id;
								orig_ci.award_id(g_orig_pointer) := l_award_id;
								orig_ci.expenditure_organization_id(g_orig_pointer) := l_expenditure_org_id;
								orig_ci.expenditure_type(g_orig_pointer) := l_expenditure_type;
								g_orig_pointer := g_orig_pointer + 1;
								l_enc_period_count := r_enc_period.r_time_period_id.COUNT + 1;
								r_enc_period.r_period_ind(l_enc_period_count) := r_enc_period.r_period_ind(l_chunk_pointer);
								r_enc_period.r_period_start_date(l_enc_period_count) := r_enc_period.r_period_start_date(l_chunk_pointer);
								r_enc_period.r_period_end_date(l_enc_period_count) := r_enc_period.r_period_end_date(l_chunk_pointer);
								r_enc_period.r_asg_start_date(l_enc_period_count) := LEAST(r_enc_period.r_asg_start_date(l_chunk_pointer), g_enc_org_end_date);
								r_enc_period.r_asg_end_date(l_enc_period_count) := r_enc_period.r_asg_end_date(l_chunk_pointer);
								r_enc_period.r_effective_date(l_enc_period_count) := r_enc_period.r_effective_date(l_chunk_pointer);
								r_enc_period.r_time_period_id(l_enc_period_count) := r_enc_period.r_time_period_id(l_chunk_pointer);
								r_enc_period.r_process_flag(l_enc_period_count) := 'SA';
								r_enc_period.r_schedule_percent(l_enc_period_count) := 100;
								r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND(r_enc_period.r_encumbrance_amount(l_chunk_pointer) *
									(psp_general.business_days(l_asg_start_date, r_enc_period.r_asg_end_date(l_enc_period_count)) / l_bus_days_in_chunk));
								r_enc_period.r_encumbrance_amount(l_enc_period_count) := ROUND((r_enc_period.r_encumbrance_amount(l_chunk_pointer) * l_schedule_percent/100),g_ext_precision);
								r_enc_period.r_period_amount(l_enc_period_count) := r_enc_period.r_period_amount(l_chunk_pointer);
								r_enc_period.r_reason_code(l_enc_period_count) := l_autopop_error;
							END IF;
							add_cel_warnings(p_start_date	=>	r_enc_period.r_asg_start_date(l_chunk_pointer),
								p_hierarchy_code	=>	'SA',
								p_end_date		=>	r_enc_period.r_asg_end_date(l_chunk_pointer),
								p_warning_code	=>	'AUTOPOP',
								p_gl_ccid			=>	l_gl_code_combination_id,
								p_project_id		=>	l_project_id,
								p_task_id			=>	l_task_id,
								p_award_id			=>	l_award_id,
								p_exp_org_id		=>	l_expenditure_org_id,
								p_exp_type			=>	l_expenditure_type,
								p_effective_date	=>	l_effective_date,
								p_error_status	=>	l_autopop_error);
							hr_utility.trace('Posting to suspense account');
						ELSE
							IF (l_acct_type = 'E') THEN
								psp_enc_pre_process.validate_poeta (p_project_id		=>	l_project_id,
									p_task_id			=>	l_task_id,
									p_award_id			=>	l_award_id,
									p_expenditure_type		=>	l_new_expenditure_type,
									p_expenditure_organization_id	=>	l_expenditure_org_id,
									p_payroll_id			=>	p_payroll_id,
									p_start_date			=>	l_poeta_start_date,
									p_end_date			=>	l_poeta_end_date,
									p_return_status			=>	p_return_status);
								IF p_return_status <> fnd_api.g_ret_sts_success THEN
									RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
								END IF;
								l_expenditure_type := l_new_expenditure_type;
							ELSE
								l_gl_code_combination_id := l_new_gl_code_combination_id;
							END IF;
							process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
						END IF;
					ELSE
						process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
					END IF;
                                  END IF;
				END LOOP;
			ELSIF (l_process_flag = 'SA') THEN
				IF (l_reason_code NOT IN ('LDM_BAL_NOT_100_PERCENT', 'LDM_NO_CI_FOUND')) THEN
					l_orig_gl_code_combination_id := orig_ci.gl_code_combination_id(l_orig_pointer);
					l_orig_project_id := orig_ci.project_id(l_orig_pointer);
					l_orig_task_id := orig_ci.task_id(l_orig_pointer);
					l_orig_award_id := orig_ci.award_id(l_orig_pointer);
					l_orig_expenditure_org_id := orig_ci.expenditure_organization_id(l_orig_pointer);
					l_orig_expenditure_type := orig_ci.expenditure_type(l_orig_pointer);
					l_orig_pointer := l_orig_pointer + 1;
				END IF;

				FOR recno IN 1..r_sa.line_account_id.COUNT
				LOOP
					g_sa_pointer := recno;
					EXIT WHEN ((l_asg_start_date <= r_sa.end_date_active(recno))
						AND (l_asg_end_date >= r_sa.start_date_active(recno)));
					IF ((recno = r_sa.line_account_id.COUNT) AND
						(l_asg_start_date <= g_enc_org_end_date)) THEN
						OPEN asg_number_cur;
						FETCH asg_number_cur INTO l_organization_id;
						CLOSE asg_number_cur;

						OPEN org_name_cur;
						FETCH org_name_cur INTO l_organization_name;
						CLOSE org_name_cur;

						fnd_message.set_name('PSP', 'PSP_LD_SUSPENSE_AC_NOT_EXIST');
						fnd_message.set_token('ORG_NAME', l_organization_name);
						fnd_message.set_token('PAYROLL_DATE', l_asg_start_date);
						g_error_message := fnd_message.get;
						RAISE no_global_acct_exists;
					END IF;
				END LOOP;

				FOR recno IN g_sa_pointer..r_sa.line_account_id.COUNT
				LOOP
					EXIT WHEN (NOT ((l_asg_start_date <= r_sa.end_date_active(recno))
						AND (l_asg_end_date >= r_sa.start_date_active(recno))));

					g_sa_pointer := recno;
					l_suspense_account_id := r_sa.line_account_id(recno);
					l_gl_code_combination_id := r_sa.gl_code_combination_id(recno);
					l_project_id := r_sa.project_id(recno);
					l_task_id := r_sa.task_id(recno);
					l_award_id := r_sa.award_id(recno);
					l_schedule_percent := r_sa.percent(recno);
					l_expenditure_type := r_sa.expenditure_type(recno);
					l_expenditure_org_id := r_sa.expenditure_organization_id(recno);
					l_start_date_active := r_sa.start_date_active(recno);
					l_end_date_active := r_sa.end_date_active(recno);
					l_poeta_start_date := r_sa.poeta_start_date(recno);
					l_poeta_end_date := r_sa.poeta_end_date(recno);
					l_attribute_category := r_sa.attribute_category(recno);
					l_attribute1 := r_sa.attribute1(recno);
					l_attribute2 := r_sa.attribute2(recno);
					l_attribute3 := r_sa.attribute3(recno);
					l_attribute4 := r_sa.attribute4(recno);
					l_attribute5 := r_sa.attribute5(recno);
					l_attribute6 := r_sa.attribute6(recno);
					l_attribute7 := r_sa.attribute7(recno);
					l_attribute8 := r_sa.attribute8(recno);
					l_attribute9 := r_sa.attribute9(recno);
					l_attribute10 := r_sa.attribute10(recno);
					l_acct_type := r_sa.acct_type(recno);

					IF (g_uom = 'H' AND l_gl_code_combination_id IS NOT NULL) THEN
						log_gl_hours_message;
					ELSE

						IF (g_sa_autopop = 'Y') THEN
							psp_autopop.main(p_acct_type		=> l_acct_type,
							p_person_id			=> l_person_id,
							p_assignment_id			=> p_assignment_id,
							p_element_type_id		=> p_element_type_id,
							p_project_id			=> l_project_id,
							p_expenditure_organization_id	=> l_expenditure_org_id,
							p_task_id			=> l_task_id,
							p_award_id			=> l_award_id,
							p_expenditure_type		=> l_expenditure_type,
							p_gl_code_combination_id	=> l_gl_code_combination_id,
                                                        p_payroll_date                  => l_asg_end_date,  --- replaced l_effective_date..5592784
							p_set_of_books_id		=> g_set_of_books_id,
							p_business_group_id		=> g_business_group_id,
							ret_expenditure_type		=> l_new_expenditure_type,
							ret_gl_code_combination_id	=> l_new_gl_code_combination_id,
							retcode				=> l_autopop_status);

						IF (l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
							(l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
							l_autopop_error := 'AUTO_POP_EXP_ERROR';
							IF (l_autopop_status = FND_API.G_RET_STS_ERROR) THEN
								l_autopop_error := 'AUTO_POP_NO_VALUE';
							END IF;
							IF (l_acct_type = 'E') THEN
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

								fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_INV_PATEO');
								fnd_message.set_token('PJ', l_project_number);
								fnd_message.set_token('TK', l_task_number);
								fnd_message.set_token('AW', l_award_number);
								fnd_message.set_token('EO', l_exp_org_name);
								fnd_message.set_token('ET', l_expenditure_type);
							ELSE
								l_gl_description := psp_general.get_gl_values(g_set_of_books_id, l_gl_code_combination_id);
								fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_INV_GL');
								fnd_message.set_token('GL', l_gl_description);
							END IF;
							fnd_message.set_token('START_DATE', l_asg_start_date);
							fnd_message.set_token('END_DATE', l_asg_end_date);
							fnd_message.set_token('ERROR_STATUS', l_autopop_error);
							g_error_message := fnd_message.get;
							RAISE SUSPENSE_AUTOPOP_FAILED;
						ELSE
							IF (l_acct_type = 'E') THEN
								psp_enc_pre_process.validate_poeta (p_project_id		=>	l_project_id,
									p_task_id			=>	l_task_id,
									p_award_id			=>	l_award_id,
									p_expenditure_type		=>	l_new_expenditure_type,
									p_expenditure_organization_id	=>	l_expenditure_org_id,
									p_payroll_id			=>	p_payroll_id,
									p_start_date			=>	l_poeta_start_date,
									p_end_date			=>	l_poeta_end_date,
									p_return_status			=>	p_return_status);
								IF p_return_status <> fnd_api.g_ret_sts_success THEN
									RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
								END IF;
								l_expenditure_type := l_new_expenditure_type;
							ELSE
								l_gl_code_combination_id := l_new_gl_code_combination_id;
							END IF;
							process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
						END IF;
					ELSE
						process_all_hier(l_chunk_pointer, l_asg_start_date, l_asg_end_date, NULL, l_process_flag);
					END IF;
				    END IF;
				END LOOP;
			ELSIF (l_process_flag = 'I') THEN
				hr_utility.trace('Ignoring chunk starting beyond org end date');
			END IF;
		END IF;

		l_chunk_pointer := l_chunk_pointer + 1;
	END LOOP;

	orig_ci.gl_code_combination_id.DELETE;
	orig_ci.project_id.DELETE;
	orig_ci.task_id.DELETE;
	orig_ci.award_id.DELETE;
	orig_ci.expenditure_organization_id.DELETE;
	orig_ci.expenditure_type.DELETE;

	hr_utility.trace('Prev Enc Lines: ' || l_prev_enc_lines_counter);
	hr_utility.trace('G Enc Lines: ' || g_enc_lines_counter);
	hr_utility.trace('Enc Lines: ' || t_enc_lines_array.r_time_period_id.COUNT);
	l_time_period_id := -1;
	IF ((g_enc_lines_counter - l_prev_enc_lines_counter) > 0) THEN
		FOR recno IN 1..r_enc_period.r_time_period_id.COUNT
		LOOP
			IF (l_time_period_id <> r_enc_period.r_time_period_id(recno)) AND
				(r_enc_period.r_time_period_id(recno) NOT IN (l_ignore_start, l_ignore_end)) AND
				(g_enc_org_end_date > r_enc_period.r_period_start_date(recno)) THEN
				l_proc_step := 90 + (recno / 100000);
				l_running_total := 0;
				l_chunk_pointer := 1;
				l_time_period_id := r_enc_period.r_time_period_id(recno);
				FOR recno2 IN l_prev_enc_lines_counter..(g_enc_lines_counter-1)
				LOOP
					l_proc_step := 100 + (recno2 / 100000);
					IF (t_enc_lines_array.r_time_period_id(recno2) = l_time_period_id) THEN
						l_running_total := l_running_total + t_enc_lines_array.r_encumbrance_amount(recno2);
						l_chunk_pointer := recno2;
						hr_utility.trace('Encumbrance Amount: ' || t_enc_lines_array.r_encumbrance_amount(recno2));
					END IF;
				END LOOP;

				IF (l_running_total > 0) AND (l_running_total <> r_enc_period.r_period_amount(recno)) THEN
					t_enc_lines_array.r_encumbrance_amount(l_chunk_pointer) :=
						t_enc_lines_array.r_encumbrance_amount(l_chunk_pointer) +
						(r_enc_period.r_period_amount(recno) - l_running_total);
				END IF;

				hr_utility.trace('l_time_period_id: ' || l_time_period_id ||
					' l_running_total: ' || fnd_number.number_to_canonical(l_running_total) ||
					' r_enc_period.r_period_amount(recno): ' || fnd_number.number_to_canonical(r_enc_period.r_period_amount(recno)) ||
					' t_enc_lines_array.r_encumbrance_amount(l_chunk_pointer): ' || fnd_number.number_to_canonical(t_enc_lines_array.r_encumbrance_amount(l_chunk_pointer)));
			END IF;
		END LOOP;
	END IF;

	r_enc_period.r_time_period_id.DELETE;
	r_enc_period.r_period_start_date.DELETE;
	r_enc_period.r_period_end_date.DELETE;
	r_enc_period.r_asg_start_date.DELETE;
	r_enc_period.r_asg_end_date.DELETE;
	r_enc_period.r_process_flag.DELETE;
	r_enc_period.r_period_ind.DELETE;
	r_enc_period.r_schedule_percent.DELETE;
	r_enc_period.r_encumbrance_amount.DELETE;
	r_enc_period.r_period_amount.DELETE;
	r_enc_period.r_reason_code.DELETE;

	l_proc_step := 210;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Leaving ' || l_proc_name);
EXCEPTION
	WHEN suspense_autopop_failed THEN
		fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', 'CREATE_LINES ');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, 'l_reason_code: ' || l_reason_code);
		fnd_file.put_line(fnd_file.log, fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ' || l_proc_name);
	WHEN OTHERS THEN
		IF (g_error_message IS NULL) THEN
			g_error_message := l_proc_name || ': ' || SQLERRM;
		END IF;
		fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', 'CREATE_LINES');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ' || l_proc_name);
END create_lines;

---------------------- I N S E R T   S T A T E M E N T  ------------------------------------
 PROCEDURE insert_into_enc_lines(
 		L_ENC_ELEMENT_TYPE_ID		IN	NUMBER,
		L_ENCUMBRANCE_DATE		IN	DATE,
		L_DR_CR_FLAG			IN 	VARCHAR2,
 		L_ENCUMBRANCE_AMOUNT		IN	NUMBER,
 		L_ENC_LINE_TYPE			IN	VARCHAR2,
 		L_SCHEDULE_LINE_ID		IN	NUMBER,
 		L_ORG_SCHEDULE_ID		IN	NUMBER,
		L_DEFAULT_ORG_ACCOUNT_ID	IN	NUMBER,
            	L_SUSPENSE_ORG_ACCOUNT_ID	IN	NUMBER,
 		L_ELEMENT_ACCOUNT_ID		IN	NUMBER,
            	L_GL_PROJECT_FLAG		IN	VARCHAR2,
		L_PERSON_ID			IN 	NUMBER,
		L_ASSIGNMENT_ID			IN	NUMBER,
		L_AWARD_ID			IN 	NUMBER,
		L_TASK_ID			IN 	NUMBER,
		L_EXPENDITURE_TYPE		IN	VARCHAR2,
		L_EXPENDITURE_ORGANIZATION_ID	IN	NUMBER,
		L_PROJECT_ID			IN	NUMBER,
		L_GL_CODE_COMBINATION_ID	IN	NUMBER,
		L_TIME_PERIOD_ID		IN	NUMBER,
		L_PAYROLL_ID			IN	NUMBER,
		L_BUSINESS_GROUP_ID		IN	NUMBER,
		L_SET_OF_BOOKS_ID		IN	NUMBER,
  		L_SUSPENSE_REASON_CODE		IN	VARCHAR2,
            	L_DEFAULT_REASON_CODE		IN	VARCHAR2,
                L_CHANGE_FLAG                   IN      VARCHAR2,
                L_ENC_START_DATE		IN	DATE,
                L_ENC_END_DATE			IN	DATE,
		p_attribute_category		IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
		p_attribute1			IN	VARCHAR2,
		p_attribute2			IN	VARCHAR2,
		p_attribute3			IN	VARCHAR2,
		p_attribute4			IN	VARCHAR2,
		p_attribute5			IN	VARCHAR2,
		p_attribute6			IN	VARCHAR2,
		p_attribute7			IN	VARCHAR2,
		p_attribute8			IN	VARCHAR2,
		p_attribute9			IN	VARCHAR2,
		p_attribute10			IN	VARCHAR2,
		p_orig_gl_code_combination_id	IN	NUMBER,
		p_orig_project_id		IN	NUMBER,
		p_orig_task_id			IN	NUMBER,
		p_orig_award_id			IN	NUMBER,
		p_orig_expenditure_org_id	IN	NUMBER,
		p_orig_expenditure_type		IN	VARCHAR2,
		p_hierarchy_code		IN	VARCHAR2,
            	p_return_status              	OUT NOCOPY     VARCHAR2) IS
	l_enc_line_id 		NUMBER;
	l_row_id 		VARCHAR2(30);
	i			NUMBER := 0;
	l_time_period_id_found  VARCHAR2(10) := 'FALSE';
	l_rec_no		NUMBER := 0;
	l_enc_control_id	NUMBER;
	l_return_status		VARCHAR2(1);
 BEGIN
--For Enh. Bug 2259310 : Changed the enc_control_tab from array of records to records of array and hence the change
--in the way each element of record to be accessed.
--Instead of calling INSERT_ROW of PSP_ENC_LINES for each CI of an assignment, all the lines are collated into an
--array for an assignment and inserted using Oracle 8i feature

/* added to skip creation of lines with zero dollars  Bug 1671971:- Subha */
 IF l_encumbrance_amount <> 0 THEN

	  -- The following code is used to populate number_of_dr,number_of_cr,total_dr_amount,
	  -- total_cr_amount,gl_dr_amount,gl_cr_amount,ogm_dr_amount,ogm_cr_amount of
	  -- psp_enc_controls table.

	  -- Check for dr_cr_flag and increment the counter and amount accordingly.
	     FOR I IN 1..enc_control_tab.r_enc_control_id.COUNT
	     loop
		IF (enc_control_tab.r_time_period_id(i) = l_time_period_id
          	    AND enc_control_tab.r_uom(i) = g_uom) THEN
		   l_time_period_id_found := 'TRUE';
		   l_rec_no := i;
		   l_enc_control_id := enc_control_tab.r_enc_control_id(l_rec_no);
		   EXIT;
	        end if;
	     end loop;

		IF l_time_period_id_found = 'FALSE' THEN
			create_controls(g_payroll_action_id, l_payroll_id,
			    l_time_period_id, l_business_group_id, l_set_of_books_id,
			    l_enc_control_id, l_return_status);

			l_rec_no := enc_control_tab.r_enc_control_id.COUNT + 1;
			enc_control_tab.r_time_period_id(l_rec_no) := l_time_period_id;
			enc_control_tab.r_uom(l_rec_no) := g_uom;
/*****	Commented the following for Create and Update multi thread enh.
		   -- Get a number for enc control id
     		 BEGIN
			SELECT psp_enc_controls_s.nextval
			INTO   l_enc_control_id
			FROM   DUAL;
     		END;
	End of comment for Create and Update multi thread enh.	*****/
			enc_control_tab.r_enc_control_id(l_rec_no) := l_enc_control_id;
			enc_control_tab.r_no_of_dr(l_rec_no) := 0;
			enc_control_tab.r_total_dr_amount(l_rec_no) := 0;
			enc_control_tab.r_gl_dr_amount(l_rec_no) := 0;
			enc_control_tab.r_ogm_dr_amount(l_rec_no) :=0;
			enc_control_tab.r_no_of_cr(l_rec_no) :=0;
			enc_control_tab.r_total_cr_amount(l_rec_no) := 0;
			enc_control_tab.r_gl_cr_amount(l_rec_no) := 0;
			enc_control_tab.r_ogm_cr_amount(l_rec_no) :=0;
		END IF;

    IF l_dr_cr_flag = 'D' THEN
		g_dr_ctr := NVL(g_dr_ctr,0) + 1;
		enc_control_tab.r_no_of_dr(l_rec_no) := NVL(enc_control_tab.r_no_of_dr(l_rec_no),0) + 1;
enc_control_tab.r_total_dr_amount(l_rec_no) := NVL(enc_control_tab.r_total_dr_amount(l_rec_no),0) + NVL(l_encumbrance_amount,0);

	 	IF l_gl_project_flag = 'G' THEN
enc_control_tab.r_gl_dr_amount(l_rec_no) := NVL(enc_control_tab.r_gl_dr_amount(l_rec_no),0) + NVL(l_encumbrance_amount,0);
	 	ELSIF l_gl_project_flag = 'P' THEN
enc_control_tab.r_ogm_dr_amount(l_rec_no) := NVL(enc_control_tab.r_ogm_dr_amount(l_rec_no),0) + NVL(l_encumbrance_amount,0);
		END IF;

     ELSIF l_dr_cr_flag = 'C'  THEN
		g_cr_ctr := NVL(g_cr_ctr,0) + 1;
enc_control_tab.r_no_of_cr(l_rec_no) := NVL(enc_control_tab.r_no_of_cr(l_rec_no),0) + 1;
enc_control_tab.r_total_cr_amount(l_rec_no) := NVL(enc_control_tab.r_total_cr_amount(l_rec_no),0) + NVL(l_encumbrance_amount,0);

	 	IF l_gl_project_flag = 'G' THEN
enc_control_tab.r_gl_cr_amount(l_rec_no) := NVL(enc_control_tab.r_gl_cr_amount(l_rec_no),0) + NVL(l_encumbrance_amount,0);
	 	ELSIF l_gl_project_flag = 'P' THEN
enc_control_tab.r_ogm_cr_amount(l_rec_no) := NVL(enc_control_tab.r_ogm_cr_amount(l_rec_no),0) + NVL(l_encumbrance_amount,0);
		END IF;
      END IF;

--Introduced For Enh. Bug 2259310
	-- Insert into enc lines record
	t_enc_lines_array.r_enc_element_type_id(g_enc_lines_counter)		:= l_enc_element_type_id;
	t_enc_lines_array.r_encumbrance_date(g_enc_lines_counter) 		:= l_encumbrance_date;
	t_enc_lines_array.r_dr_cr_flag(g_enc_lines_counter)			:= l_dr_cr_flag;
	t_enc_lines_array.r_encumbrance_amount(g_enc_lines_counter)		:= l_encumbrance_amount;
	t_enc_lines_array.r_enc_line_type(g_enc_lines_counter) 			:= l_enc_line_type;
	t_enc_lines_array.r_schedule_line_id(g_enc_lines_counter)		:= l_schedule_line_id;
	t_enc_lines_array.r_org_schedule_id(g_enc_lines_counter)		:= l_org_schedule_id;
	t_enc_lines_array.r_default_org_account_id(g_enc_lines_counter)		:= l_default_org_account_id;
	t_enc_lines_array.r_suspense_org_account_id(g_enc_lines_counter)	:= l_suspense_org_account_id;
	t_enc_lines_array.r_element_account_id(g_enc_lines_counter)		:= l_element_account_id;
	t_enc_lines_array.r_gl_project_flag(g_enc_lines_counter)		:= l_gl_project_flag;
	t_enc_lines_array.r_person_id(g_enc_lines_counter)			:= l_person_id;
	t_enc_lines_array.r_assignment_id(g_enc_lines_counter)			:= l_assignment_id;
	t_enc_lines_array.r_award_id(g_enc_lines_counter)			:= l_award_id;
	t_enc_lines_array.r_task_id(g_enc_lines_counter)			:= l_task_id;
	t_enc_lines_array.r_expenditure_type(g_enc_lines_counter)		:= l_expenditure_type;
	t_enc_lines_array.r_expenditure_organization_id(g_enc_lines_counter)	:= l_expenditure_organization_id;
	t_enc_lines_array.r_project_id(g_enc_lines_counter) 			:= l_project_id;
	t_enc_lines_array.r_gl_code_combination_id(g_enc_lines_counter)		:= l_gl_code_combination_id;
	t_enc_lines_array.r_time_period_id(g_enc_lines_counter)			:= l_time_period_id;
	t_enc_lines_array.r_default_reason_code(g_enc_lines_counter)		:= l_default_reason_code;
	t_enc_lines_array.r_suspense_reason_code(g_enc_lines_counter)		:= l_suspense_reason_code;
	t_enc_lines_array.r_enc_control_id(g_enc_lines_counter)			:= l_enc_control_id;
	t_enc_lines_array.r_change_flag(g_enc_lines_counter)			:= l_change_flag;
	t_enc_lines_array.r_enc_start_date(g_enc_lines_counter)			:= l_enc_start_date;
	t_enc_lines_array.r_enc_end_date(g_enc_lines_counter)			:= l_enc_end_date;
	t_enc_lines_array.r_attribute_category(g_enc_lines_counter)		:= NVL(p_attribute_category, 'NULL_VALUE');	-- Introduced DFF columns for bug fix 2908859
	t_enc_lines_array.r_attribute1(g_enc_lines_counter)			:= NVL(p_attribute1, 'NULL_VALUE');
	t_enc_lines_array.r_attribute2(g_enc_lines_counter)			:= NVL(p_attribute2, 'NULL_VALUE');
	t_enc_lines_array.r_attribute3(g_enc_lines_counter)			:= NVL(p_attribute3, 'NULL_VALUE');
	t_enc_lines_array.r_attribute4(g_enc_lines_counter)			:= NVL(p_attribute4, 'NULL_VALUE');
	t_enc_lines_array.r_attribute5(g_enc_lines_counter)			:= NVL(p_attribute5, 'NULL_VALUE');
	t_enc_lines_array.r_attribute6(g_enc_lines_counter)			:= NVL(p_attribute6, 'NULL_VALUE');
	t_enc_lines_array.r_attribute7(g_enc_lines_counter)			:= NVL(p_attribute7, 'NULL_VALUE');
	t_enc_lines_array.r_attribute8(g_enc_lines_counter)			:= NVL(p_attribute8, 'NULL_VALUE');
	t_enc_lines_array.r_attribute9(g_enc_lines_counter)			:= NVL(p_attribute9, 'NULL_VALUE');
	t_enc_lines_array.r_attribute10(g_enc_lines_counter)			:= NVL(p_attribute10, 'NULL_VALUE');
	t_enc_lines_array.r_orig_gl_code_combination_id(g_enc_lines_counter)	:= p_orig_gl_code_combination_id;
	t_enc_lines_array.r_orig_project_id(g_enc_lines_counter) 		:= p_orig_project_id;
	t_enc_lines_array.r_orig_award_id(g_enc_lines_counter)			:= p_orig_award_id;
	t_enc_lines_array.r_orig_task_id(g_enc_lines_counter)			:= p_orig_task_id;
	t_enc_lines_array.r_orig_expenditure_type(g_enc_lines_counter)		:= p_orig_expenditure_type;
	t_enc_lines_array.r_orig_expenditure_org_id(g_enc_lines_counter)	:= p_orig_expenditure_org_id;
	t_enc_lines_array.r_hierarchy_code(g_enc_lines_counter)	:= p_hierarchy_code;

	g_enc_lines_counter := g_enc_lines_counter +1;
END IF;  /* skip inserting lines of zero dollars */
          p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		IF (g_error_message IS NULL) THEN
			g_error_message := 'INSERT_INTO_ENC_LINES: ' || SQLERRM;
		END IF;
		fnd_msg_pub.add_exc_msg('PSP_ENC_LINES','INSERT_INTO_ENC_LINES');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END insert_into_enc_lines;

--------------------------- INSERT INTO CONTROL TABLES  --------------------------------------
PROCEDURE Create_Controls(p_payroll_action_id		 IN	NUMBER,
			    p_payroll_id		 IN	NUMBER,
			    p_time_period_id		 IN	NUMBER,
			    p_business_group_id		 IN	NUMBER,
			    p_set_of_books_id		 IN  	NUMBER,
			    p_enc_control_id		 OUT NOCOPY	NUMBER,
			    p_return_status		 OUT NOCOPY	VARCHAR2) IS

	l_action_code   		VARCHAR2(2);-- 	DEFAULT 'N';
--Added the following variables for the Enhancement -Enc Redesign: Enh. Bug 2259310
	l_batch_name 			VARCHAR2(30)    DEFAULT 'ENC'||TO_CHAR(TRUNC(SYSDATE));
	l_last_update_date		DATE 		DEFAULT SYSDATE;
	l_last_updated_by		NUMBER 		DEFAULT NVL(FND_GLOBAL.USER_ID, -1);
	l_last_updated_login		NUMBER		DEFAULT	NVL(FND_GLOBAL.LOGIN_ID, -1);
CURSOR	get_enc_control_id_cur IS
SELECT	enc_control_id
FROM	psp_enc_controls
WHERE	payroll_action_id = p_payroll_action_id
AND	payroll_id = p_payroll_id
AND	time_period_id = p_time_period_id
AND	uom = g_uom;
BEGIN
    /* Added IF conditon below for Restart update/Quick Update  Encumbrance Lines Enh. */
--     IF g_enc_line_type IN ('U','Q') THEN
        l_action_code := 'IC';
--     END IF;

	OPEN get_enc_control_id_cur;
	FETCH get_enc_control_id_cur INTO p_enc_control_id;
	CLOSE get_enc_control_id_cur;

--	FORALL  i IN 1 ..enc_control_tab.r_time_period_id.COUNT
	IF (p_enc_control_id IS NULL) THEN
		SELECT	psp_enc_controls_s.NEXTVAL INTO p_enc_control_id FROM DUAL;

		INSERT INTO PSP_ENC_CONTROLS
			(time_period_id,			enc_control_id,
			number_of_dr,				number_of_cr,
			total_dr_amount,			total_cr_amount,
			gl_dr_amount,				gl_cr_amount,
			ogm_dr_amount,				ogm_cr_amount,
			payroll_id,				set_of_books_id,
			encumbrance_date,			action_code,
			last_update_date,			last_updated_by,
			creation_date,				created_by,
			last_update_login,			batch_name,
			business_group_id,			action_type,
			payroll_action_id,			uom)
		VALUES	(p_time_period_id,		p_enc_control_id,
				0,						0,
				0,						0,
				0,						0,
				0,						0,
				p_payroll_id,			p_set_of_books_id,
				l_last_update_date,		l_action_code,
				l_last_update_date,		l_last_updated_by,
				l_last_update_date,		l_last_updated_by,
				l_last_updated_login,	l_batch_name,
				p_business_group_id,	'U',
		        p_payroll_action_id,		g_uom);
/*	Commented for Create and Update multi thread enh.
		VALUES	(enc_control_tab.R_TIME_PERIOD_ID(i),	enc_control_tab.R_ENC_CONTROL_ID(i),
			enc_control_tab.R_NO_OF_DR(i),		enc_control_tab.R_NO_OF_CR(i),
			round(enc_control_tab.R_TOTAL_DR_AMOUNT(i),g_precision),-- intoduced Rounding for Bug 2916848 Ilo Ehnc.
			round(enc_control_tab.R_TOTAL_CR_AMOUNT(i),g_precision),-- intoduced Rounding for Bug 2916848 Ilo Ehnc.
			round(enc_control_tab.R_GL_DR_AMOUNT(i),g_precision),-- intoduced Rounding for Bug 2916848 Ilo Ehnc.
			round(enc_control_tab.R_GL_CR_AMOUNT(i),g_precision),-- intoduced Rounding for Bug 2916848 Ilo Ehnc.
			round(enc_control_tab.R_OGM_DR_AMOUNT(i),g_precision),-- intoduced Rounding for Bug 2916848 Ilo Ehnc.
			round(enc_control_tab.R_OGM_CR_AMOUNT(i),g_precision),-- intoduced Rounding for Bug 2916848 Ilo Ehnc.
			p_payroll_id,				p_set_of_books_id,
			l_last_update_date,			l_action_code,
			l_last_update_date,			l_last_updated_by,
			l_last_update_date,			l_last_updated_by,
			l_last_updated_login,			l_batch_name,
			p_business_group_id,			g_enc_line_type,
	        p_payroll_action_id);
	End of comment for Create and Update Multi thread enh.	*****/
	END IF;

	enc_control_tab.r_time_period_id.delete;
	enc_control_tab.r_enc_control_id.delete;
	enc_control_tab.r_no_of_dr.delete;
	enc_control_tab.r_no_of_cr.delete;
	enc_control_tab.r_total_dr_amount.delete;
	enc_control_tab.r_total_cr_amount.delete;
	enc_control_tab.r_gl_dr_amount.delete;
	enc_control_tab.r_gl_cr_amount.delete;
	enc_control_tab.r_ogm_dr_amount.delete;
	enc_control_tab.r_ogm_cr_amount.delete;
	enc_control_tab.r_uom.delete;

	COMMIT;
	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		IF (g_error_message IS NULL) THEN
			g_error_message := 'CREATE_CONTROLS: ' || SQLERRM;
		END IF;
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_message.set_name('PSP','PSP_ENC_INSERT_CONTROLS');
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END create_controls;

/**********************************************************
Created By: lveerubh

Date Created By:08-MAR-2002

Purpose: To Determine the Prorata dates. This procedure is called from each of the hierachy.
	  It determines the spilt of the active assignment chunk into Suspense posting and Schdedule posting
	  And for each such dates arrived calculates the pro-rated amount. All the dates along with amount and
	  flag to indicate suspense posting is populated in an array t_peot_gl_hier_array.
         Introduced as part of Enhnacement Enc Redesign : Bug 2259310.

Who		When 		What
lveerubh	08-MAR-2002	Created the procedure
lveerubh	20-APR-2002	For Bug 2317856
***************************************************************/
PROCEDURE determine_pro_rata_dates (		p_assignment_id		IN	NUMBER,
						p_ls_start_date		IN	DATE,
						p_ls_end_date		IN	DATE,
						p_poeta_start_date	IN	DATE,
						p_poeta_end_date	IN	DATE,
						p_asg_start_date	IN	DATE,
						p_asg_end_date 		IN	DATE,
						p_asg_amount		IN 	NUMBER,
						p_poeta_gl_hier_array		IN OUT NOCOPY 	r_poeta_gl_hier_tab,
						p_return_status		OUT NOCOPY 	VARCHAR2
       				  )
IS

-- p_ls_start_date : GREATEST(Labor Schedule Start date , Assignment start date)
-- p_ls_end_date   : LEAST(Labor Schedule End date , Assignment end date)

l_start_date date := p_ls_start_date;
l_end_date  date  := p_ls_end_date;
i NUMBER := 1;
l_bus_days_in_period NUMBER;
l_bus_days_in_schedules NUMBER;
l_susp_date   DATE  DEFAULT fnd_date.canonical_to_date('1800/01/01');


DIVIDE_BY_ZERO  EXCEPTION;

BEGIN
/************
The procedure has been functionally changed for bug 2317856
--Step 1:
--Obtain the start date = MAX (labor schedule start date, poeta start date) and
--end date = min (labor schedule end date, poeta end date).
--Note here that assignment start date and assignment end date checks are not being considered
--for the following reason:
--The posting to Enc lines has to be for the entire period of active assignment chunk.
--Hence this procedure is calculating the date rage for which the POETA or GL needs to be posted
--with the active assignment chunk.
******************/

--For Bug 2317856
--Frame of reference would be asg start date and asg end date
--No suspense postings for part which does not have LS or after which LS ends
--IF poeta ends before l_start_date then period for which the LS is applicable within asg. chunk shall go to suspense
--l_start_date and l_end_date are equivalent to greatest of ASD and LSD , least of AED and LED respectively.

--For Bug 2317856 :
--1.Adding the extra check of poeta_end_date <l_start_date
--2. Changed the p_asg_start_date and p_asg_end_date to l_start_date and l_end_date respectively
--3. As the amount needs to be prorated hence cannot return in the IF or ELSIF
--4. Moved the subslicing of l_start_Date and l_end_date periods into IF -ELSIF-ELSE condition. Thus moving the
--   END IF down.
--For Bug 2325710 : Introduced the p_poeta_start_date > l_end_date condition for suspense posting
IF ((p_poeta_start_date = l_susp_date)  OR  (p_poeta_end_date <l_start_date ) OR (p_poeta_start_date > l_end_date)) THEN
		p_poeta_gl_hier_array(i).r_amount 		:= round(p_asg_amount,g_ext_precision);
		-- Introduced rounding for Bug 2916848 Ilo Mrc Ehnc
		p_poeta_gl_hier_array(i).r_enc_start_date 	:= l_start_date;
		p_poeta_gl_hier_array(i).r_enc_end_date		:= l_end_date;
		p_poeta_gl_hier_array(i).r_susp_flag 		:= 'Y';
/*******************************************
		p_return_status 				:= fnd_api.g_ret_sts_success;
		RETURN;
END IF;
IF l_start_date < NVL(p_poeta_start_date,l_start_date) THEN
		l_start_date := NVL(p_poeta_start_date,l_start_date);
END IF;

	--End Date
IF l_end_date  >  NVL(p_poeta_end_date,l_end_date) THEN
		l_end_date := NVL(p_poeta_end_date,l_end_date);
END IF;
IF p_asg_start_date  <  l_start_date THEN  --(ASD <PSD )
		t_poeta_gl_hier_array(i).r_enc_start_date 		:= p_asg_start_date;
		t_poeta_gl_hier_array(i).r_enc_end_date			:= l_start_date-1;
		t_poeta_gl_hier_array(i).r_susp_flag 			:= 'Y';
		i := i+1;
        IF l_end_date <  p_asg_end_date THEN -- (PED<AED)
		t_poeta_gl_hier_array(i).r_enc_start_date 	:= l_start_date;
		t_poeta_gl_hier_array(i).r_enc_end_date 	:=  l_end_date ;
		i := i +1;
		t_poeta_gl_hier_array(i).r_enc_start_date 	:= l_end_date+1;
		t_poeta_gl_hier_array(i).r_enc_end_date 	:=  p_asg_end_date ;
		t_poeta_gl_hier_array(i).r_susp_flag 		:= 'Y';
	 ELSE-- (AED<=PED)
		t_poeta_gl_hier_array(i).r_enc_start_date := l_start_date;
		t_poeta_gl_hier_array(i).r_enc_end_date :=  p_asg_end_date ;
        END IF;
ELSE --(ASD>= PSD)
         	t_poeta_gl_hier_array(i).r_enc_start_date := p_asg_start_date;
         IF l_end_date < p_asg_end_date THEN  --(PED<AED)
		t_poeta_gl_hier_array(i).r_enc_end_date :=  l_end_date ;
		i := i +1;
		t_poeta_gl_hier_array(i).r_enc_start_date := l_end_date+1;
		t_poeta_gl_hier_array(i).r_enc_end_date :=  p_asg_end_date ;
		t_poeta_gl_hier_array(i).r_susp_flag := 'Y';
	 ELSE --(AED<= PED)
		t_poeta_gl_hier_array(i).r_enc_end_date :=  p_asg_end_date ;
        END IF;
END IF;
*****************************************/
--Introduced for GL Validation -2317856
ELSIF (p_poeta_start_date IS NULL) THEN
		p_poeta_gl_hier_array(i).r_amount 		:= round(p_asg_amount,g_ext_precision);
		-- Introduced rounding for bug 2916848 Ilo Mrc Ehnc.
		p_poeta_gl_hier_array(i).r_enc_start_date 	:= l_start_date;
		p_poeta_gl_hier_array(i).r_enc_end_date		:= l_end_date;
		p_poeta_gl_hier_array(i).r_susp_flag		:= 'N';	-- Introduced for bug fix 3085980
ELSE
/**Populating the t_poeta_gl_hier_array for using in the schedule hierarchy - FOR POETA processing **/
--For Bug 2317856
--1. Changed p_asg_start_date to l_start_date and p_asg_end_date to l_end_date
--2. l_start_daet and l_end_Date are compared with POETA start and end date respectively
-- Where SD : GREATEST(Labor Schedule Start date , Assignment start date)
--       ED: LEAST(Labor Schedule End date , Assignment end date)
--	 PSD :POETA start date, PED:POETA End date

  IF l_start_date  <  p_poeta_start_date THEN  --(SD <PSD )
		p_poeta_gl_hier_array(i).r_enc_start_date 		:= l_start_date;
		p_poeta_gl_hier_array(i).r_enc_end_date			:= p_poeta_start_date-1;
		p_poeta_gl_hier_array(i).r_susp_flag 			:= 'Y';
		i := i+1;
        IF l_end_date >  p_poeta_end_date THEN -- (PED<ED)
		p_poeta_gl_hier_array(i).r_enc_start_date 	:=  p_poeta_start_date;
		p_poeta_gl_hier_array(i).r_enc_end_date 	:=  p_poeta_end_date ;
		p_poeta_gl_hier_array(i).r_susp_flag		:= 'N';	-- Introduced for bug fix 3085980
		i := i +1;
		p_poeta_gl_hier_array(i).r_enc_start_date 	:=  p_poeta_end_date+1;
		p_poeta_gl_hier_array(i).r_enc_end_date 	:=  l_end_date ;
		p_poeta_gl_hier_array(i).r_susp_flag 		:= 'Y';
	 ELSE-- (ED<=PED)
		p_poeta_gl_hier_array(i).r_enc_start_date 	:= p_poeta_start_date;
		p_poeta_gl_hier_array(i).r_enc_end_date   	:= l_end_date ;
		p_poeta_gl_hier_array(i).r_susp_flag		:= 'N';	-- Introduced for bug fix 3085980
        END IF;
   ELSE --(SD>= PSD)
         	p_poeta_gl_hier_array(i).r_enc_start_date 	:= l_start_date;
		p_poeta_gl_hier_array(i).r_susp_flag		:= 'N';	-- Introduced for bug fix 3085980
         IF l_end_date > p_poeta_end_date THEN  --(PED<ED)
		p_poeta_gl_hier_array(i).r_enc_end_date 	:=  p_poeta_end_date ;
		i := i +1;
		p_poeta_gl_hier_array(i).r_enc_start_date 	:= p_poeta_end_date+1;
		p_poeta_gl_hier_array(i).r_enc_end_date 	:= l_end_date ;
		p_poeta_gl_hier_array(i).r_susp_flag 		:= 'Y';
	 ELSE --(ED<= PED)
		p_poeta_gl_hier_array(i).r_enc_end_date 	:=  l_end_date ;
        END IF;
  END IF;
END IF; --Main IF :2317856

l_bus_days_in_period := PSP_GENERAL.BUSINESS_DAYS(p_asg_start_date, p_asg_end_date,p_assignment_id);
IF l_bus_days_in_period = 0 THEN
		fnd_message.set_name('PSP', 'PSP_ENC_ZERO_WORK_DAYS_PERIOD');
		fnd_message.set_token('START_DATE', p_asg_start_date);
		fnd_message.set_token('END_DATE', p_asg_end_date);
		g_error_message := fnd_message.get;
		RAISE DIVIDE_BY_ZERO;
END IF;

For  j in 1 .. p_poeta_gl_hier_array.COUNT
LOOP
l_bus_days_in_schedules := PSP_GENERAL.BUSINESS_DAYS(p_poeta_gl_hier_array(j).r_enc_start_date, p_poeta_gl_hier_array(j).r_enc_end_date,p_assignment_id);
		p_poeta_gl_hier_array(j).r_amount :=
				round(((p_asg_amount  * l_bus_days_in_schedules) / l_bus_days_in_period),g_ext_precision);
		-- Introduced rounding for Bug 2916848 Ilo Mrc Ehnc.
END LOOP;
p_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
WHEN DIVIDE_BY_ZERO THEN
        g_error_api_path := SUBSTR(' DETERMINE_PRO_RATA_DATES'||g_error_api_path,1,230);
        fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', ' DETERMINE_PRO_RATA_DATES ');
        p_return_status := fnd_api.g_ret_sts_unexp_error;

WHEN OTHERS THEN
	IF (g_error_message IS NULL) THEN
		g_error_message := 'DETERMINE_PRO_RATA_DATES: ' || SQLERRM;
	END IF;
        g_error_api_path := SUBSTR(' DETERMINE_PRO_RATA_DATES'||g_error_api_path,1,230);
        fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', ' DETERMINE_PRO_RATA_DATES ');
        p_return_status := fnd_api.g_ret_sts_unexp_error;

END determine_pro_rata_dates;

/**************************************************************************************************************************
Created By: lveerubh

Date Created By:08-MAR-2002

Purpose: To insert into psp_enc_lines from Array. This procedure has been introduced to bulk insert
	 into psp_enc_lines from the record of collection t_enc_lines_array.
         Introduced as part of Enhnacement Enc Redesign : Bug 2259310.
Who		When 		What
lveerubh	08-MAR-2002	Created the procedure
********************************************************************************************************************************/
 PROCEDURE 	insert_enc_lines_from_arrays( 	p_payroll_id		 IN	NUMBER,
						p_business_group_id	 IN	NUMBER,
						p_set_of_books_id	 IN  	NUMBER,
						p_enc_line_type		 IN	VARCHAR2,
						p_return_status		 OUT NOCOPY	VARCHAR2)
IS
l_last_update_date		DATE 	DEFAULT SYSDATE;
l_last_updated_by		NUMBER  DEFAULT NVL(FND_GLOBAL.USER_ID, -1);
l_last_update_login		NUMBER 	DEFAULT NVL(FND_GLOBAL.LOGIN_ID, -1);
BEGIN
FORALL i IN 1 .. t_enc_lines_array2.r_enc_element_type_id.COUNT
	insert into psp_enc_lines
	(
	enc_element_type_id,
	enc_line_id,
	business_group_id,
	encumbrance_date,
	dr_cr_flag,
	encumbrance_amount,
	enc_line_type,
	schedule_line_id,
	org_schedule_id,
	default_org_account_id,
	suspense_org_account_id,
	element_account_id,
	gl_project_flag,
	person_id,
	assignment_id,
	award_id,
	task_id,
	expenditure_type,
	expenditure_organization_id,
	project_id,
	gl_code_combination_id,
	time_period_id,
	payroll_id,
	set_of_books_id,
	default_reason_code,
	suspense_reason_code,
	status_code,
	enc_control_id,
	change_flag,
	enc_start_date,
	enc_end_date,
	last_update_date,
	last_updated_by,
	last_update_login,
	created_by,
	creation_date,
	attribute_category,			-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	payroll_action_id,
	orig_gl_code_combination_id,
	orig_project_id,
	orig_task_id,
	orig_award_id,
	orig_expenditure_org_id,
	orig_expenditure_type,
	hierarchy_code
	)
	values (
	t_enc_lines_array2.r_enc_element_type_id(i)
	,PSP_ENC_LINES_S.NEXTVAL
	,p_business_group_id
	, t_enc_lines_array2.r_encumbrance_date(i)
	, t_enc_lines_array2.r_dr_cr_flag(i)
	,round( t_enc_lines_array2.r_encumbrance_amount(i),g_precision) -- introduced rounding for BUg 2916848 Ilo Ehnc.
	, t_enc_lines_array2.r_enc_line_type(i)
	, t_enc_lines_array2.r_schedule_line_id(i)
	, t_enc_lines_array2.r_org_schedule_id(i)
	, t_enc_lines_array2.r_default_org_account_id(i)
	, t_enc_lines_array2.r_suspense_org_account_id(i)
	, t_enc_lines_array2.r_element_account_id(i)
	, t_enc_lines_array2.r_gl_project_flag(i)
	, t_enc_lines_array2.r_person_id(i)
	, t_enc_lines_array2.r_assignment_id(i)
	, t_enc_lines_array2.r_award_id(i)
	, t_enc_lines_array2.r_task_id(i)
	, t_enc_lines_array2.r_expenditure_type(i)
	, t_enc_lines_array2.r_expenditure_organization_id(i)
	, t_enc_lines_array2.r_project_id(i)
	, t_enc_lines_array2.r_gl_code_combination_id(i)
	, t_enc_lines_array2.r_time_period_id(i)
	, p_payroll_id
	, p_set_of_books_id
	, t_enc_lines_array2.r_default_reason_code(i)
	, t_enc_lines_array2.r_suspense_reason_code(i)
	, p_enc_line_type    --status_code
	, t_enc_lines_array2.r_enc_control_id(i)
	, t_enc_lines_array2.r_change_flag(i)
	, t_enc_lines_array2.r_enc_start_date(i)
	, t_enc_lines_array2.r_enc_end_date(i)
	, l_last_update_date
	, l_last_updated_by
	, l_last_update_login
	, l_last_updated_by
	, l_last_update_date
	, DECODE(t_enc_lines_array2.r_attribute_category(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute_category(i))
	, DECODE(t_enc_lines_array2.r_attribute1(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute1(i))
	, DECODE(t_enc_lines_array2.r_attribute2(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute2(i))
	, DECODE(t_enc_lines_array2.r_attribute3(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute3(i))
	, DECODE(t_enc_lines_array2.r_attribute4(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute4(i))
	, DECODE(t_enc_lines_array2.r_attribute5(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute5(i))
	, DECODE(t_enc_lines_array2.r_attribute6(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute6(i))
	, DECODE(t_enc_lines_array2.r_attribute7(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute7(i))
	, DECODE(t_enc_lines_array2.r_attribute8(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute8(i))
	, DECODE(t_enc_lines_array2.r_attribute9(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute9(i))
	, DECODE(t_enc_lines_array2.r_attribute10(i), 'NULL_VALUE', NULL, t_enc_lines_array2.r_attribute10(i))
	, g_payroll_action_id
	, t_enc_lines_array2.r_orig_gl_code_combination_id(i)
	, t_enc_lines_array2.r_orig_project_id(i)
	, t_enc_lines_array2.r_orig_task_id(i)
	, t_enc_lines_array2.r_orig_award_id(i)
	, t_enc_lines_array2.r_orig_expenditure_org_id(i)
	, t_enc_lines_array2.r_orig_expenditure_type(i)
	, t_enc_lines_array2.r_hierarchy_code(i)
	);

	DELETE	psp_enc_lines
	WHERE	payroll_id = p_payroll_id
	AND	business_group_id = p_business_group_id
	AND	set_of_books_id = p_set_of_books_id
	AND	encumbrance_amount = 0;

	t_enc_lines_array2.r_enc_element_type_id.delete;
	t_enc_lines_array2.r_encumbrance_date.delete;
	t_enc_lines_array2.r_dr_cr_flag.delete;
	t_enc_lines_array2.r_encumbrance_amount.delete;
	t_enc_lines_array2.r_enc_line_type.delete;
	t_enc_lines_array2.r_schedule_line_id.delete;
	t_enc_lines_array2.r_org_schedule_id.delete;
	t_enc_lines_array2.r_default_org_account_id.delete;
	t_enc_lines_array2.r_suspense_org_account_id.delete;
	t_enc_lines_array2.r_element_account_id.delete;
	t_enc_lines_array2.r_gl_project_flag.delete;
	t_enc_lines_array2.r_person_id.delete;
	t_enc_lines_array2.r_assignment_id.delete;
	t_enc_lines_array2.r_award_id.delete;
	t_enc_lines_array2.r_task_id.delete;
	t_enc_lines_array2.r_expenditure_type.delete;
	t_enc_lines_array2.r_expenditure_organization_id.delete;
	t_enc_lines_array2.r_project_id.delete;
	t_enc_lines_array2.r_gl_code_combination_id.delete;
	t_enc_lines_array2.r_time_period_id.delete;
	t_enc_lines_array2.r_default_reason_code.delete;
	t_enc_lines_array2.r_suspense_reason_code.delete;
	t_enc_lines_array2.r_enc_control_id.delete;
	t_enc_lines_array2.r_change_flag.delete;
	t_enc_lines_array2.r_enc_start_date.delete;
	t_enc_lines_array2.r_enc_end_date.delete;
	t_enc_lines_array2.r_attribute_category.delete;
	t_enc_lines_array2.r_attribute1.delete;
	t_enc_lines_array2.r_attribute2.delete;
	t_enc_lines_array2.r_attribute3.delete;
	t_enc_lines_array2.r_attribute4.delete;
	t_enc_lines_array2.r_attribute5.delete;
	t_enc_lines_array2.r_attribute6.delete;
	t_enc_lines_array2.r_attribute7.delete;
	t_enc_lines_array2.r_attribute8.delete;
	t_enc_lines_array2.r_attribute9.delete;
	t_enc_lines_array2.r_attribute10.delete;
	t_enc_lines_array2.r_orig_gl_code_combination_id.delete;
	t_enc_lines_array2.r_orig_project_id.delete;
	t_enc_lines_array2.r_orig_award_id.delete;
	t_enc_lines_array2.r_orig_task_id.delete;
	t_enc_lines_array2.r_orig_expenditure_type.delete;
	t_enc_lines_array2.r_orig_expenditure_org_id.delete;
	t_enc_lines_array2.r_hierarchy_code.delete;

p_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
WHEN OTHERS THEN
	IF (g_error_message IS NULL) THEN
		g_error_message := 'INSERT_ENC_LINES_FROM_ARRAYS: ' || SQLERRM;
	END IF;
        g_error_api_path := SUBSTR(' INSERT_ENC_LINES_FROM_ARRAYS:'||g_error_api_path,1,230);
        fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', ' INSERT_ENC_LINES_FROM_ARRAYS');
        p_return_status := fnd_api.g_ret_sts_unexp_error;
END insert_enc_lines_from_arrays;

--	Introduced the following procedure for bug fix 3462452
PROCEDURE sub_slice_asg_chunk	(p_assignment_id	IN		NUMBER,
				p_element_type_id	IN		NUMBER,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2) IS
TYPE r_sch_hier_type IS RECORD
	(start_date		t_date_type,
	end_date		t_date_type,
	schedule_percent	t_num_15_type);
r_sch_rec	r_sch_hier_type;

l_return_status			VARCHAR2(1);
l_start_date			DATE;
l_end_date			DATE;
l_min_start_date		DATE DEFAULT r_enc_period.r_asg_start_date(1);
l_max_end_date			DATE DEFAULT r_enc_period.r_asg_end_date(r_enc_period.r_asg_end_date.COUNT);
l_schedule_percent		NUMBER;
l_new_start_date		DATE;
l_new_end_date			DATE;
l_process_flag			VARCHAR2(10);
l_period_start_date		DATE;
l_period_end_date		DATE;
l_asg_start_date		DATE;
l_asg_end_date			DATE;
l_rec_no			NUMBER	DEFAULT 1;
l_sub_slice_counter		NUMBER;
l_run_id			NUMBER;
l_period_count			NUMBER;
l_schedule_hierarchy_id		NUMBER;
l_sch_pointer			NUMBER;
l_proc_name			VARCHAR2(61) DEFAULT g_package_name || 'SUB_SLICE_ASG_CHUNK';
l_reason_code			VARCHAR2(50);
l_proc_step			NUMBER(20,10);

r_enc_period_tmp1	enc_period_rectype;

--CURSOR	global_element_cur	(p_period_start_date	IN	DATE,
--				p_period_end_date	IN	DATE,
--				p_asg_start_date	IN	DATE,
--				p_asg_end_date		IN	DATE) IS
CURSOR	global_element_cur IS
SELECT	GREATEST(l_min_start_date, start_date_active) start_date_active,
	LEAST(l_max_end_date, end_date_active)	 end_date_active,
	SUM(percent) schedule_percent
FROM	psp_element_type_accounts
WHERE	business_group_id = p_business_group_id
AND	set_of_books_id = p_set_of_books_id
AND	element_type_id = p_element_type_id
AND	(	gl_code_combination_id IS NOT NULL
	OR	award_id IS NOT NULL)
AND	start_date_active <= l_max_end_date
AND	end_date_active >= l_min_start_date
GROUP BY GREATEST(l_min_start_date, start_date_active),
	LEAST(l_max_end_date, end_date_active)
ORDER BY start_date_active;

--CURSOR	odls_cur	(p_asg_start_date	IN	DATE,
--			p_asg_end_date		IN	DATE) IS
CURSOR	odls_cur IS
SELECT  GREATEST(l_min_start_date, paf.effective_start_date, schedule_begin_date) schedule_begin_date,
        LEAST(l_max_end_date, paf.effective_end_date, schedule_end_date) schedule_end_date,
	SUM(schedule_percent) schedule_percent
FROM	per_assignments_f paf,
	psp_default_labor_schedules pdls
WHERE	paf.assignment_id = p_assignment_id
AND	l_min_start_date <= paf.effective_end_date
AND	l_max_end_date >= paf.effective_start_date
AND	paf.organization_id = pdls.organization_id
AND	pdls.business_group_id = p_business_group_id
AND	pdls.set_of_books_id = p_set_of_books_id
AND	(	gl_code_combination_id IS NOT NULL
	OR	award_id IS NOT NULL)
AND	schedule_begin_date <= l_max_end_date
AND	schedule_end_date >= l_min_start_date
GROUP BY  GREATEST(l_min_start_date, paf.effective_start_date, schedule_begin_date),
        LEAST(l_max_end_date, paf.effective_end_date, schedule_end_date)
ORDER BY 1;

CURSOR	ls_hier_cur (p_scheduling_types_code IN VARCHAR2) IS
SELECT	psh.schedule_hierarchy_id
FROM	psp_schedule_hierarchy psh
WHERE	psh.business_group_id = p_business_group_id
AND	psh.set_of_books_id = p_set_of_books_id
AND	psh.scheduling_types_code = p_scheduling_types_code
AND	(	(p_scheduling_types_code = 'ET' AND psh.element_type_id = p_element_type_id)
	OR	(p_scheduling_types_code = 'A'))
AND	psh.assignment_id = p_assignment_id;

/*****	Modified the following cursor for 11510_CU2 consolidated performance fixes.
CURSOR	eg_hier_cur IS
SELECT	DISTINCT schedule_hierarchy_id
FROM	psp_schedule_hierarchy psh,
	psp_element_groups peg,
	psp_group_element_list pgel
WHERE	psh.business_group_id = p_business_group_id
AND	psh.set_of_books_id = p_set_of_books_id
AND	peg.business_group_id = p_business_group_id
AND	peg.set_of_books_id = p_set_of_books_id
AND	psh.scheduling_types_code = 'EG'
AND	psh.element_group_id = peg.element_group_id
AND	peg.end_date_active >= r_enc_period.r_period_start_date(1)
AND	peg.start_date_active <= r_enc_period.r_period_end_date(l_period_count)
AND	pgel.element_type_id = p_element_type_id
AND	psh.assignment_id = p_assignment_id;
	End of comment for 11510_CU2 consloidated performance fixes.	*****/

--	Modified cursor for 11510_CU2 consloidated performance fixes.
CURSOR	eg_hier_cur IS
SELECT	schedule_hierarchy_id
FROM	psp_schedule_hierarchy psh
WHERE	EXISTS	(SELECT	1
		FROM	psp_element_groups peg,
			psp_group_element_list pgel
		WHERE	peg.business_group_id = p_business_group_id
		AND	peg.set_of_books_id = p_set_of_books_id
		AND	peg.end_date_active >= r_enc_period.r_period_start_date(1)
		AND	peg.start_date_active <= r_enc_period.r_period_end_date(l_period_count)
		AND	peg.element_group_id = psh.element_group_id
		AND	pgel.element_type_id = p_element_type_id)
AND	psh.business_group_id = p_business_group_id
AND	psh.set_of_books_id = p_set_of_books_id
AND	psh.scheduling_types_code = 'EG'
AND	psh.assignment_id = p_assignment_id;


CURSOR	ls_matrix_cur IS
SELECT	GREATEST(l_min_start_date, period_start_date) period_start_date,
	LEAST(l_max_end_date, period_end_date) period_end_date,
	SUM(period_schedule_percent) schedule_percent
FROM	psp_matrix_driver pmd
WHERE	run_id = l_run_id
AND	period_start_date <= l_max_end_date
AND	period_end_date >= l_min_start_date
GROUP BY GREATEST(l_min_start_date, period_start_date),
	LEAST(l_max_end_date, period_end_date)
ORDER BY 1;

CURSOR	eg_matrix_cur IS
SELECT	GREATEST(l_min_start_date, peg.start_date_active, period_start_date) period_start_date,
	LEAST(l_max_end_date, peg.end_date_active, period_end_date) period_end_date,
	SUM(period_schedule_percent) schedule_percent
FROM	psp_matrix_driver pmd,
	psp_schedule_lines psl,
	psp_schedule_hierarchy psh,
	psp_element_groups peg
WHERE	run_id = l_run_id
AND	psl.schedule_line_id = pmd.schedule_line_id
AND	psl.schedule_hierarchy_id = psh.schedule_hierarchy_id
AND	psh.element_group_id = peg.element_group_id
AND	peg.start_date_active <= l_max_end_date
AND	peg.end_date_active >= l_min_start_date
AND	period_start_date <= l_max_end_date
AND	period_end_date >= l_min_start_date
AND	(	gl_code_combination_id IS NOT NULL
	OR	award_id IS NOT NULL)
GROUP BY GREATEST(l_min_start_date, peg.start_date_active, period_start_date),
	LEAST(l_max_end_date, peg.end_date_active, period_end_date)
ORDER BY 1;

--	Introduced the following for bug fix 3970852
TYPE    t_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE    t_char IS TABLE OF CHAR INDEX BY BINARY_INTEGER;
initial_dates	t_date;
date_type	t_char;

TYPE schedule_chunk_rec IS RECORD
	(schedule_begin_date	t_date,
	schedule_end_date	t_date);
schedule_chunk	schedule_chunk_rec;

CURSOR	sched_lines(schedule_hierarchy_id NUMBER) IS
SELECT	schedule_line_id l_id,
	schedule_begin_date sbd,
	schedule_end_date sed,
	schedule_percent sp
FROM	psp_schedule_lines
WHERE	schedule_hierarchy_id = schedule_hierarchy_id
AND	(	gl_code_combination_id IS NOT NULL
	OR	award_id IS NOT NULL)
AND	schedule_end_date >= l_min_start_date
AND	schedule_begin_date <= l_max_end_date;

CURSOR	dates(p_schedule_hierarchy_id NUMBER) IS
SELECT	schedule_begin_date dat , 'B'
FROM	psp_schedule_lines
WHERE	schedule_hierarchy_id = p_schedule_hierarchy_id
AND	(	gl_code_combination_id IS NOT NULL
	OR	award_id IS NOT NULL)
AND	schedule_end_date >= l_min_start_date
AND	schedule_begin_date <= l_max_end_date
UNION
SELECT	schedule_end_date dat , 'E'
FROM	psp_schedule_lines
WHERE	schedule_hierarchy_id = p_schedule_hierarchy_id
AND	(	gl_code_combination_id IS NOT NULL
	OR	award_id IS NOT NULL)
AND	schedule_end_date >= l_min_start_date
AND	schedule_begin_date <= l_max_end_date
ORDER BY        1, 2 ;

recno	INTEGER;
--	End of bug fix 3970852
BEGIN
	psp_matrix_driver_pkg.set_runid;
	l_run_id := psp_matrix_driver_pkg.get_run_id;

	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Entering ' || l_proc_name);
	hr_utility.trace('p_assignment_id: ' || fnd_number.number_to_canonical(p_assignment_id) ||
		' p_element_type_id: ' || fnd_number.number_to_canonical(p_element_type_id) ||
		' p_business_group_id: ' || fnd_number.number_to_canonical(p_business_group_id) ||
		' p_set_of_books_id: ' || fnd_number.number_to_canonical(p_set_of_books_id) ||
		' r_enc_period.r_time_period_id.COUNT: ' || fnd_number.number_to_canonical(r_enc_period.r_time_period_id.COUNT));
	hr_utility.trace('Dumping Assignment Chunk Before Global Element Processing ...');
	hr_utility.trace(LPAD('Chunk Pointer', 13, ' ') || '	' ||
		LPAD('Time Period Id', 14, ' ') || '	' || RPAD('Period Start Date', 17, ' ') || '	' ||
		RPAD('Period End Date', 15, ' ') || '	' || RPAD('Asg Start Date', 14, ' ') || '	' ||
		RPAD('Asg End Date', 12, ' ') || '	' || RPAD('Effective Date', 14, ' ') || '	' ||
		RPAD('Process Flag', 12, ' ') || '	' || LPAD('Schedule Percent', 16, ' ') || '	' ||
		RPAD('Reason Code', 50, ' '));

	hr_utility.trace(LPAD('-', 13, '-') || '	' ||
		LPAD('-', 14, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || LPAD('-', 16, '-') || '	' ||
		RPAD('-', 50, '-'));

	FOR recno IN 1..r_enc_period.r_time_period_id.COUNT
	LOOP
		hr_utility.trace(LPAD(recno, 13, ' ') || '	' ||
			LPAD(r_enc_period.r_time_period_id(recno), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_period_start_date(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_period_end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_asg_start_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_asg_end_date(recno), 'DD-MON-RRRR'), 12, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_effective_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(r_enc_period.r_process_flag(recno), 12, ' ') || '	' ||
			LPAD(r_enc_period.r_schedule_percent(recno), 16, ' ') || '	' ||
			RPAD(r_enc_period.r_reason_code(recno), 50, ' '));
	END LOOP;
	hr_utility.trace('Global Element Processing');

	l_proc_step := 10;
	l_sch_pointer := 1;

	OPEN global_element_cur;
	FETCH global_element_cur BULK COLLECT INTO r_sch_rec.start_date, r_sch_rec.end_date, r_sch_rec.schedule_percent;
	CLOSE global_element_cur;

	hr_utility.trace('r_sch_rec.start_date.COUNT: ' || r_sch_rec.start_date.COUNT);
	hr_utility.trace('Schedule Chunk Details');
	hr_utility.trace(RPAD('Start Date', 15, ' ') || '	' ||
		RPAD('End Date', 15, ' ') || '	' || LPAD('Schedule Percent', 16, ' '));

	hr_utility.trace(RPAD('-', 15, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 16, '-'));

	FOR recno IN 1..r_sch_rec.start_date.COUNT
	LOOP
		hr_utility.trace(RPAD(TO_CHAR(r_sch_rec.start_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_sch_rec.end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			LPAD(r_sch_rec.schedule_percent(recno), 16, ' '));
	END LOOP;

	FOR I IN 1..r_enc_period.r_time_period_id.COUNT
	LOOP
		l_period_start_date := r_enc_period.r_period_start_date(I);
		l_period_end_date := r_enc_period.r_period_end_date(I);
		l_asg_start_date := r_enc_period.r_asg_start_date(I);
		l_asg_end_date := r_enc_period.r_asg_end_date(I);
		l_sub_slice_counter := 1;
		l_proc_step := 20 + (I / 100000);

		hr_utility.trace('I: ' || fnd_number.number_to_canonical(I) ||
			' l_period_start_date: ' || fnd_date.date_to_canonical(l_period_start_date) ||
			' l_period_end_date: ' || fnd_date.date_to_canonical(l_period_end_date) ||
			' l_asg_start_date: ' || fnd_date.date_to_canonical(l_asg_start_date) ||
			' l_asg_end_date: ' || fnd_date.date_to_canonical(l_asg_end_date) ||
			' r_enc_period.r_time_period_id(I): ' || fnd_number.number_to_canonical(r_enc_period.r_time_period_id(I)) ||
			' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no));

		IF (r_sch_rec.end_date.COUNT > 0) THEN
			FOR ge_recno IN l_sch_pointer..r_sch_rec.start_date.COUNT
			LOOP
				l_start_date:= r_sch_rec.start_date(ge_recno);
				l_end_date:= r_sch_rec.end_date(ge_recno);
				l_schedule_percent:= r_sch_rec.schedule_percent(ge_recno);
				l_proc_step := 30 + (ge_recno / 100000);
--			OPEN global_element_cur(l_period_start_date, l_period_end_date, l_asg_start_date, l_asg_end_date);
--			FETCH global_element_cur INTO l_start_date, l_end_date, l_schedule_percent;

				hr_utility.trace('l_sub_slice_counter: ' || fnd_number.number_to_canonical(l_sub_slice_counter) ||
					' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no) ||
					' l_start_date: ' || fnd_date.date_to_canonical(l_start_date)  ||
					' l_end_date: ' || fnd_date.date_to_canonical(l_end_date) ||
					' l_schedule_percent: ' || fnd_number.number_to_canonical(l_schedule_percent));
--				hr_utility.trace('global_element_cur%ROWCOUNT: ' || fnd_number.number_to_canonical(global_element_cur%ROWCOUNT));

--			IF (global_element_cur%NOTFOUND) THEN
				IF (l_start_date > l_asg_end_date) THEN
					r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
					r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
					r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
					r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
					r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
					r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
					r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
					r_enc_period_tmp1.r_process_flag(l_rec_no) := 'Y';
					r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
					r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
					l_rec_no := l_rec_no + 1;
					EXIT;
				END IF;
--				CLOSE global_element_cur;
--				EXIT;
--			END IF;
--			CLOSE global_element_cur;

				IF (l_end_date >= l_asg_start_date) AND (l_start_date <= l_asg_end_date) THEN
					IF (l_asg_start_date = l_start_date AND l_asg_end_date = l_end_date) THEN
						r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
						r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
						r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
						r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
						r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
						r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
						r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
						r_enc_period_tmp1.r_process_flag(l_rec_no) := 'GE';
						r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
						r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
						l_rec_no := l_rec_no + 1;
						IF (l_schedule_percent < 100) THEN
							r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'BAL';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
						END IF;
						EXIT;
					ELSE
						IF (l_start_date > GREATEST(l_period_start_date, l_asg_start_date)) THEN
							l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date);
							l_new_end_date := l_start_date - 1;
							r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'Y';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							l_asg_start_date := l_start_date;
						END IF;

						IF (l_end_date < LEAST(l_period_end_date, l_asg_end_date)) THEN
							l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date, l_start_date);
							l_new_end_date := l_end_date;
							r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'GE';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							IF (l_schedule_percent < 100) THEN
								r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'BAL';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
							l_asg_start_date := l_end_date + 1;
							IF (ge_recno = r_sch_rec.start_date.COUNT) AND
								(l_asg_start_date <= l_asg_end_date) THEN
								r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'Y';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
						ELSE
							r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'GE';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							IF (l_schedule_percent < 100) THEN
								r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'BAL';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
							l_asg_start_date := l_end_date + 1;
						END IF;
					END IF;
					l_sub_slice_counter := 2;
				ELSE
					IF (ge_recno = r_sch_rec.start_date.COUNT) THEN
						r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
						r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
						r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
						r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
						r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
						r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
						r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
						r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
						r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
						r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
						l_rec_no := l_rec_no + 1;
					END IF;
				END IF;
				l_sch_pointer := ge_recno;
				EXIT WHEN l_asg_start_date > l_asg_end_date;
			END LOOP;
		ELSE
			r_enc_period_tmp1.r_period_ind(l_rec_no) := I;
			r_enc_period_tmp1.r_period_start_date(l_rec_no) := r_enc_period.r_period_start_date(I);
			r_enc_period_tmp1.r_period_end_date(l_rec_no) := r_enc_period.r_period_end_date(I);
			r_enc_period_tmp1.r_asg_start_date(l_rec_no) := r_enc_period.r_asg_start_date(I);
			r_enc_period_tmp1.r_asg_end_date(l_rec_no) := r_enc_period.r_asg_end_date(I);
			r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
			r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
			r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
			r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
			r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
			l_rec_no := l_rec_no + 1;
		END IF;
	END LOOP;

	r_sch_rec.start_date.delete;
	r_sch_rec.end_date.delete;
	r_sch_rec.schedule_percent.delete;
	r_enc_period.r_time_period_id.DELETE;
	r_enc_period.r_period_start_date.DELETE;
	r_enc_period.r_period_end_date.DELETE;
	r_enc_period.r_asg_start_date.DELETE;
	r_enc_period.r_asg_end_date.DELETE;
	r_enc_period.r_process_flag.DELETE;
	r_enc_period.r_period_ind.DELETE;
	r_enc_period.r_schedule_percent.DELETE;
	r_enc_period.r_encumbrance_amount.DELETE;
	r_enc_period.r_period_amount.DELETE;
	r_enc_period.r_reason_code.DELETE;
	r_enc_period.r_effective_date.DELETE;
	l_rec_no := 1;
	l_proc_step := 40;

	hr_utility.trace('Dumping Assignment Chunk After Global Element Processing ...');
	hr_utility.trace(LPAD('Chunk Pointer', 13, ' ') || '	' ||
		LPAD('Time Period Id', 14, ' ') || '	' || RPAD('Period Start Date', 17, ' ') || '	' ||
		RPAD('Period End Date', 15, ' ') || '	' || RPAD('Asg Start Date', 14, ' ') || '	' ||
		RPAD('Asg End Date', 12, ' ') || '	' || RPAD('Effective Date', 14, ' ') || '	' ||
		RPAD('Process Flag', 12, ' ') || '	' || LPAD('Schedule Percent', 16, ' ') || '	' ||
		RPAD('Reason Code', 50, ' '));

	hr_utility.trace(LPAD('-', 13, '-') || '	' ||
		LPAD('-', 14, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || LPAD('-', 16, '-') || '	' ||
		RPAD('-', 50, '-'));

	FOR recno IN 1..r_enc_period_tmp1.r_time_period_id.COUNT
	LOOP
		hr_utility.trace(LPAD(recno, 13, ' ') || '	' ||
			LPAD(r_enc_period_tmp1.r_time_period_id(recno), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period_tmp1.r_period_start_date(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period_tmp1.r_period_end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period_tmp1.r_asg_start_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period_tmp1.r_asg_end_date(recno), 'DD-MON-RRRR'), 12, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period_tmp1.r_effective_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(r_enc_period_tmp1.r_process_flag(recno), 12, ' ') || '	' ||
			LPAD(r_enc_period_tmp1.r_schedule_percent(recno), 16, ' ') || '	' ||
			RPAD(r_enc_period_tmp1.r_reason_code(recno), 50, ' '));
	END LOOP;
	hr_utility.trace('Element Type Processing ...');

	OPEN ls_hier_cur('ET');
	FETCH ls_hier_cur INTO l_schedule_hierarchy_id;
	CLOSE ls_hier_cur;

/*****	Commented for bug fix 3970852 to resolve issues when schedule dates equal default end date
	psp_matrix_driver_pkg.clear_table('REFRESH');
	psp_matrix_driver_pkg.purge_table;
	psp_matrix_driver_pkg.load_table(l_schedule_hierarchy_id);

	DELETE	psp_matrix_driver
	WHERE	run_id = l_run_id
	AND	(period_start_date > l_max_end_date
		OR period_end_date < l_min_start_date
		OR period_schedule_percent = 0);

	UPDATE	psp_matrix_driver pmd
	SET	period_end_date = period_end_date - 1
	WHERE	run_id = l_run_id
	AND	period_start_date < period_end_date
	AND	period_start_date = (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
	AND	EXISTS (SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
			AND	psl1.schedule_begin_date = pmd.period_end_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);

	UPDATE	psp_matrix_driver pmd
	SET	period_end_date = period_end_date - 1
	WHERE	run_id = l_run_id
	AND	period_start_date < period_end_date
	AND	NOT (NOT EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
			AND	psl1.schedule_begin_date = pmd.period_end_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_end_date = pmd.period_end_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id))
	AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);

	UPDATE	psp_matrix_driver pmd
	SET	period_start_date = period_start_date + 1
	WHERE	run_id = l_run_id
	AND	period_start_date < period_end_date
	AND	NOT EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_begin_date = pmd.period_start_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
	AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);

	UPDATE	psp_matrix_driver pmd
	SET	period_start_date = period_start_date + 1
	WHERE	run_id = l_run_id
	AND	period_start_date < period_end_date
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_begin_date = pmd.period_start_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
			AND	psl1.schedule_end_date = pmd.period_start_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
	AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);
	End of comment for bug fix 3970852	*****/

--	Introduced the following to prepare schedule chunk dates instead of load_table for bug fix 3970852
	recno := 1;

	OPEN dates(l_schedule_hierarchy_id);
	FETCH dates BULK COLLECT INTO initial_dates, date_type;
	CLOSE dates;

	FOR rowno IN 1..(initial_dates.COUNT - 1)
	LOOP
		IF (date_type(rowno) = 'B' AND date_type(rowno+1) = 'B') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno);
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1) - 1;
			recno := recno+1;
		ELSIF (date_type(rowno) = 'B' AND date_type(rowno+1) = 'E') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno);
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1);
			recno := recno+1;
		ELSIF (date_type(rowno) = 'E' AND date_type(rowno+1) = 'E') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno) + 1;
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1);
			recno := recno+1;
		ELSIF (date_type(rowno) = 'E' AND date_type(rowno+1) = 'B') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno) + 1;
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1) -1;
			recno := recno+1;
		END IF;
	END LOOP;

	FORALL rowno IN 1..schedule_chunk.schedule_begin_date.COUNT
	INSERT INTO psp_matrix_driver
		(RUN_ID,					SCHEDULE_LINE_ID,
		PERIOD_START_DATE,
		PERIOD_END_DATE,
		PERIOD_SCHEDULE_PERCENT)
	SELECT 	l_run_id,	schedule_line_id,
		GREATEST(l_min_start_date, schedule_chunk.schedule_begin_date(rowno)),
		LEAST(l_max_end_date, schedule_chunk.schedule_end_date(rowno)),
		schedule_percent
	FROM	psp_schedule_lines psl
	WHERE	schedule_hierarchy_id = l_schedule_hierarchy_id
	AND	schedule_end_date >= l_min_start_date
	AND	schedule_begin_date <= l_max_end_date
	AND	(	gl_code_combination_id IS NOT NULL
		OR	award_id IS NOT NULL)
	AND	psl.schedule_begin_date <= schedule_chunk.schedule_end_date(rowno)
	AND	psl.schedule_end_date >= schedule_chunk.schedule_begin_date(rowno);

	initial_dates.delete;
	date_type.delete;
	schedule_chunk.schedule_end_date.delete;
	schedule_chunk.schedule_begin_date.delete;
--	End of bug fix 3970852

	l_sch_pointer := 1;
	OPEN ls_matrix_cur;
	FETCH ls_matrix_cur BULK COLLECT INTO r_sch_rec.start_date, r_sch_rec.end_date, r_sch_rec.schedule_percent;
	CLOSE ls_matrix_cur;

	hr_utility.trace('r_sch_rec.start_date.COUNT: ' || r_sch_rec.start_date.COUNT);
	hr_utility.trace('Schedule Chunk Details');
	hr_utility.trace(RPAD('Start Date', 15, ' ') || '	' ||
		RPAD('End Date', 15, ' ') || '	' || LPAD('Schedule Percent', 16, ' '));
	hr_utility.trace(RPAD('-', 15, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 16, '-'));

	FOR recno IN 1..r_sch_rec.start_date.COUNT
	LOOP
		hr_utility.trace(RPAD(TO_CHAR(r_sch_rec.start_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_sch_rec.end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			LPAD(r_sch_rec.schedule_percent(recno), 16, ' '));
	END LOOP;

	FOR I IN 1..r_enc_period_tmp1.r_time_period_id.COUNT
	LOOP
		l_period_start_date := r_enc_period_tmp1.r_period_start_date(I);
		l_period_end_date := r_enc_period_tmp1.r_period_end_date(I);
		l_asg_start_date := r_enc_period_tmp1.r_asg_start_date(I);
		l_asg_end_date := r_enc_period_tmp1.r_asg_end_date(I);
		l_process_flag := r_enc_period_tmp1.r_process_flag(I);
		l_sub_slice_counter := 1;
		l_proc_step := 50 + (I / 100000);

		hr_utility.trace('I: ' || fnd_number.number_to_canonical(I) ||
			' l_period_start_date: ' || fnd_date.date_to_canonical(l_period_start_date) ||
			' l_period_end_date: ' || fnd_date.date_to_canonical(l_period_end_date) ||
			' l_asg_start_date: ' || fnd_date.date_to_canonical(l_asg_start_date) ||
			' l_asg_end_date: ' || fnd_date.date_to_canonical(l_asg_end_date) ||
			' r_enc_period_tmp1.r_time_period_id(I): ' || fnd_number.number_to_canonical(r_enc_period_tmp1.r_time_period_id(I)) ||
			' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no));

		IF (l_process_flag = 'Y') AND (r_sch_rec.end_date.COUNT > 0) THEN
			FOR et_recno IN l_sch_pointer..r_sch_rec.start_date.COUNT
			LOOP
				l_start_date:= r_sch_rec.start_date(et_recno);
				l_end_date:= r_sch_rec.end_date(et_recno);
				l_schedule_percent:= r_sch_rec.schedule_percent(et_recno);
				l_proc_step := 60 + (et_recno / 100000);

				hr_utility.trace(' l_sub_slice_counter: ' || fnd_number.number_to_canonical(l_sub_slice_counter) ||
					' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no) ||
					' l_start_date: ' || fnd_date.date_to_canonical(l_start_date) ||
					' l_end_date: ' || fnd_date.date_to_canonical(l_end_date) ||
					' l_schedule_percent: ' || fnd_number.number_to_canonical(l_schedule_percent));

--				OPEN ls_matrix_cur;
--				FETCH ls_matrix_cur INTO l_start_date, l_end_date, l_schedule_percent;
--				IF (ls_matrix_cur%NOTFOUND) THEN
				IF (l_start_date > l_asg_end_date) THEN
					r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
					r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
					r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
					r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
					r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
					r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
					r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
					r_enc_period.r_process_flag(l_rec_no) := 'Y';
					r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
					r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
					l_rec_no := l_rec_no + 1;
					EXIT;
				END IF;
--					CLOSE ls_matrix_cur;
--					EXIT;
--				END IF;
--				CLOSE ls_matrix_cur;

				IF (l_end_date >= l_asg_start_date) AND (l_start_date <= l_asg_end_date) THEN
					IF (l_asg_start_date = l_start_date AND l_asg_end_date = l_end_date) THEN
						r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
						r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
						r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
						r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
						r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
						r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
						r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
						r_enc_period.r_process_flag(l_rec_no) := 'ET';
						r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
						r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
						l_rec_no := l_rec_no + 1;
						IF (l_schedule_percent < 100) THEN
							r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
							r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
							r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
							r_enc_period.r_process_flag(l_rec_no) := 'BAL';
							r_enc_period.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
							r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
						END IF;
						EXIT;
					ELSE
						IF (l_start_date > GREATEST(l_period_start_date, l_asg_start_date)) THEN
							l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date);
							l_new_end_date := l_start_date - 1;
							r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
							r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period.r_asg_start_date(l_rec_no) := l_new_start_date;
							r_enc_period.r_asg_end_date(l_rec_no) := l_new_end_date;
							r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
							r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
							r_enc_period.r_process_flag(l_rec_no) := 'Y';
							r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
							r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							l_asg_start_date := l_start_date;
						END IF;

						IF (l_end_date < LEAST(l_period_end_date, l_asg_end_date)) THEN
							l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date, l_start_date);
							l_new_end_date := l_end_date;
							r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
							r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period.r_asg_start_date(l_rec_no) := l_new_start_date;
							r_enc_period.r_asg_end_date(l_rec_no) := l_new_end_date;
							r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
							r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
							r_enc_period.r_process_flag(l_rec_no) := 'ET';
							r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
							r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							IF (l_schedule_percent < 100) THEN
								r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
								r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period.r_asg_start_date(l_rec_no) := l_new_start_date;
								r_enc_period.r_asg_end_date(l_rec_no) := l_new_end_date;
								r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
								r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
								r_enc_period.r_process_flag(l_rec_no) := 'BAL';
								r_enc_period.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
								r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
							l_asg_start_date := l_end_date + 1;
							IF (et_recno = r_sch_rec.start_date.COUNT) AND
								(l_asg_start_date <= l_asg_end_date) THEN
								r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
								r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
								r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
								r_enc_period.r_process_flag(l_rec_no) := 'Y';
								r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
								r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
						ELSE
							r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
							r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
							r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
							r_enc_period.r_process_flag(l_rec_no) := 'ET';
							r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
							r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							IF (l_schedule_percent < 100) THEN
								r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
								r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
								r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
								r_enc_period.r_process_flag(l_rec_no) := 'BAL';
								r_enc_period.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
								r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
							l_asg_start_date := l_end_date + 1;
						END IF;
					END IF;
					l_sub_slice_counter := 2;
				ELSE
					IF (et_recno = r_sch_rec.start_date.COUNT) THEN
						r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
						r_enc_period.r_period_start_date(l_rec_no) := r_enc_period_tmp1.r_period_start_date(I);
						r_enc_period.r_period_end_date(l_rec_no) := r_enc_period_tmp1.r_period_end_date(I);
						r_enc_period.r_asg_start_date(l_rec_no) := r_enc_period_tmp1.r_asg_start_date(I);
						r_enc_period.r_asg_end_date(l_rec_no) := r_enc_period_tmp1.r_asg_end_date(I);
						r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
						r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
						r_enc_period.r_process_flag(l_rec_no) := r_enc_period_tmp1.r_process_flag(I);
						r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
						r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
						l_rec_no := l_rec_no + 1;
					END IF;
				END IF;
				l_sch_pointer := et_recno;
				EXIT WHEN l_asg_start_date > l_asg_end_date;
			END LOOP;
		ELSE
			r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
			r_enc_period.r_period_start_date(l_rec_no) := r_enc_period_tmp1.r_period_start_date(I);
			r_enc_period.r_period_end_date(l_rec_no) := r_enc_period_tmp1.r_period_end_date(I);
			r_enc_period.r_asg_start_date(l_rec_no) := r_enc_period_tmp1.r_asg_start_date(I);
			r_enc_period.r_asg_end_date(l_rec_no) := r_enc_period_tmp1.r_asg_end_date(I);
			r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
			r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
			r_enc_period.r_process_flag(l_rec_no) := r_enc_period_tmp1.r_process_flag(I);
			r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
			r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
			l_rec_no := l_rec_no + 1;
		END IF;
	END LOOP;

	r_sch_rec.start_date.delete;
	r_sch_rec.end_date.delete;
	r_sch_rec.schedule_percent.delete;
	r_enc_period_tmp1.r_time_period_id.DELETE;
	r_enc_period_tmp1.r_period_start_date.DELETE;
	r_enc_period_tmp1.r_period_end_date.DELETE;
	r_enc_period_tmp1.r_asg_start_date.DELETE;
	r_enc_period_tmp1.r_asg_end_date.DELETE;
	r_enc_period_tmp1.r_process_flag.DELETE;
	r_enc_period_tmp1.r_period_ind.DELETE;
	r_enc_period_tmp1.r_schedule_percent.DELETE;
	r_enc_period_tmp1.r_encumbrance_amount.DELETE;
	r_enc_period_tmp1.r_period_amount.DELETE;
	r_enc_period_tmp1.r_reason_code.DELETE;
	r_enc_period_tmp1.r_effective_date.DELETE;
	l_rec_no := 1;
	l_proc_step := 70;

	hr_utility.trace('Dumping Assignment Chunk After Element Type Processing ...');
	hr_utility.trace(LPAD('Chunk Pointer', 13, ' ') || '	' ||
		LPAD('Time Period Id', 14, ' ') || '	' || RPAD('Period Start Date', 17, ' ') || '	' ||
		RPAD('Period End Date', 15, ' ') || '	' || RPAD('Asg Start Date', 14, ' ') || '	' ||
		RPAD('Asg End Date', 12, ' ') || '	' || RPAD('Effective Date', 14, ' ') || '	' ||
		RPAD('Process Flag', 12, ' ') || '	' || LPAD('Schedule Percent', 16, ' ') || '	' ||
		RPAD('Reason Code', 50, ' '));
	hr_utility.trace(LPAD('-', 13, '-') || '	' ||
		LPAD('-', 14, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || LPAD('-', 16, '-') || '	' ||
		RPAD('-', 50, '-'));

	FOR recno IN 1..r_enc_period.r_time_period_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_enc_period.r_period_ind(recno), 13, ' ') || '	' ||
			LPAD(r_enc_period.r_time_period_id(recno), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_period_start_date(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_period_end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_asg_start_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_asg_end_date(recno), 'DD-MON-RRRR'), 12, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_effective_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(r_enc_period.r_process_flag(recno), 12, ' ') || '	' ||
			LPAD(r_enc_period.r_schedule_percent(recno), 16, ' ') || '	' ||
			RPAD(r_enc_period.r_reason_code(recno), 50, ' '));
	END LOOP;
	hr_utility.trace('Element Group Processing ...');

	psp_matrix_driver_pkg.clear_table('REFRESH');
	psp_matrix_driver_pkg.purge_table;
	l_period_count := r_enc_period.r_time_period_id.COUNT;
	OPEN eg_hier_cur;
	LOOP
		FETCH eg_hier_cur INTO l_schedule_hierarchy_id;
		EXIT WHEN eg_hier_cur%NOTFOUND;

/*****	Commented for bug fix 3970852 to resolve issues when schedule dates equal default end date
		psp_matrix_driver_pkg.load_table(l_schedule_hierarchy_id);

		DELETE	psp_matrix_driver
		WHERE	run_id = l_run_id
		AND	(period_start_date > l_max_end_date
			OR period_end_date < l_min_start_date
			OR period_schedule_percent = 0);

		UPDATE	psp_matrix_driver pmd
		SET	period_end_date = period_end_date - 1
		WHERE	run_id = l_run_id
		AND	period_start_date < period_end_date
		AND	period_start_date = (SELECT	MIN(psl1.schedule_begin_date)
				FROM	psp_schedule_lines psl1
				WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
		AND	EXISTS (SELECT	1
				FROM	psp_schedule_lines psl1
				WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
				AND	psl1.schedule_begin_date = pmd.period_end_date
				AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);

		UPDATE	psp_matrix_driver pmd
		SET	period_end_date = period_end_date - 1
		WHERE	run_id = l_run_id
		AND	period_start_date < period_end_date
		AND	NOT (NOT EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
			AND	psl1.schedule_begin_date = pmd.period_end_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
		AND	EXISTS	(SELECT	1
				FROM	psp_schedule_lines psl1
				WHERE	psl1.schedule_end_date = pmd.period_end_date
				AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id))
		AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
				FROM	psp_schedule_lines psl1
				WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);

		UPDATE	psp_matrix_driver pmd
		SET	period_start_date = period_start_date + 1
		WHERE	run_id = l_run_id
		AND	period_start_date < period_end_date
		AND	NOT EXISTS	(SELECT	1
				FROM	psp_schedule_lines psl1
				WHERE	psl1.schedule_begin_date = pmd.period_start_date
				AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
		AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
				FROM	psp_schedule_lines psl1
				WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);

		UPDATE	psp_matrix_driver pmd
		SET	period_start_date = period_start_date + 1
		WHERE	run_id = l_run_id
		AND	period_start_date < period_end_date
		AND	EXISTS	(SELECT	1
				FROM	psp_schedule_lines psl1
				WHERE	psl1.schedule_begin_date = pmd.period_start_date
				AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
		AND	EXISTS	(SELECT	1
				FROM	psp_schedule_lines psl1
				WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
				AND	psl1.schedule_end_date = pmd.period_start_date
				AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
		AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
				FROM	psp_schedule_lines psl1
				WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);
	End of comment for bug fix 3970852	*****/

--	Introduced the following to prepare schedule chunk dates instead of load_table for bug fix 3970852
	recno := 1;

	OPEN dates(l_schedule_hierarchy_id);
	FETCH dates BULK COLLECT INTO initial_dates, date_type;
	CLOSE dates;

	FOR rowno IN 1..(initial_dates.COUNT - 1)
	LOOP
		IF (date_type(rowno) = 'B' AND date_type(rowno+1) = 'B') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno);
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1) - 1;
			recno := recno+1;
		ELSIF (date_type(rowno) = 'B' AND date_type(rowno+1) = 'E') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno);
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1);
			recno := recno+1;
		ELSIF (date_type(rowno) = 'E' AND date_type(rowno+1) = 'E') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno) + 1;
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1);
			recno := recno+1;
		ELSIF (date_type(rowno) = 'E' AND date_type(rowno+1) = 'B') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno) + 1;
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1) -1;
			recno := recno+1;
		END IF;
	END LOOP;

	FORALL rowno IN 1..schedule_chunk.schedule_begin_date.COUNT
	INSERT INTO psp_matrix_driver
		(RUN_ID,					SCHEDULE_LINE_ID,
		PERIOD_START_DATE,
		PERIOD_END_DATE,
		PERIOD_SCHEDULE_PERCENT)
	SELECT 	l_run_id,	schedule_line_id,
		GREATEST(l_min_start_date, schedule_chunk.schedule_begin_date(rowno)),
		LEAST(l_max_end_date, schedule_chunk.schedule_end_date(rowno)),
		schedule_percent
	FROM	psp_schedule_lines psl
	WHERE	schedule_hierarchy_id = l_schedule_hierarchy_id
	AND	schedule_end_date >= l_min_start_date
	AND	schedule_begin_date <= l_max_end_date
	AND	(	gl_code_combination_id IS NOT NULL
		OR	award_id IS NOT NULL)
	AND	psl.schedule_begin_date <= schedule_chunk.schedule_end_date(rowno)
	AND	psl.schedule_end_date >= schedule_chunk.schedule_begin_date(rowno);

	initial_dates.delete;
	date_type.delete;
	schedule_chunk.schedule_end_date.delete;
	schedule_chunk.schedule_begin_date.delete;
--	End of bug fix 3970852
	END LOOP;
	CLOSE eg_hier_cur;

	l_sch_pointer := 1;
	OPEN eg_matrix_cur;
	FETCH eg_matrix_cur BULK COLLECT INTO r_sch_rec.start_date, r_sch_rec.end_date, r_sch_rec.schedule_percent;
	CLOSE eg_matrix_cur;

	hr_utility.trace('r_sch_rec.start_date.COUNT: ' || r_sch_rec.start_date.COUNT);
	hr_utility.trace('Schedule Chunk Details');
	hr_utility.trace(RPAD('Start Date', 15, ' ') || '	' ||
		RPAD('End Date', 15, ' ') || '	' || LPAD('Schedule Percent', 16, ' '));
	hr_utility.trace(RPAD('-', 15, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 16, '-'));

	FOR recno IN 1..r_sch_rec.start_date.COUNT
	LOOP
		hr_utility.trace(RPAD(TO_CHAR(r_sch_rec.start_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_sch_rec.end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			LPAD(r_sch_rec.schedule_percent(recno), 16, ' '));
	END LOOP;

	FOR I IN 1..r_enc_period.r_time_period_id.COUNT
	LOOP
		l_period_start_date := r_enc_period.r_period_start_date(I);
		l_period_end_date := r_enc_period.r_period_end_date(I);
		l_asg_start_date := r_enc_period.r_asg_start_date(I);
		l_asg_end_date := r_enc_period.r_asg_end_date(I);
		l_process_flag := r_enc_period.r_process_flag(I);
		l_sub_slice_counter := 1;
		l_proc_step := 80 + (I / 100000);

		hr_utility.trace('I: ' || fnd_number.number_to_canonical(I) ||
			' l_period_start_date: ' || fnd_date.date_to_canonical(l_period_start_date) ||
			' l_period_end_date: ' || fnd_date.date_to_canonical(l_period_end_date) ||
			' l_asg_start_date: ' || fnd_date.date_to_canonical(l_asg_start_date) ||
			' l_asg_end_date: ' || fnd_date.date_to_canonical(l_asg_end_date) ||
			' r_enc_period.r_time_period_id(I): ' || fnd_number.number_to_canonical(r_enc_period.r_time_period_id(I)) ||
			' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no));

		IF (l_process_flag = 'Y') AND (r_sch_rec.end_date.COUNT > 0) THEN
			FOR eg_recno IN l_sch_pointer..r_sch_rec.start_date.COUNT
			LOOP
				l_start_date:= r_sch_rec.start_date(eg_recno);
				l_end_date:= r_sch_rec.end_date(eg_recno);
				l_schedule_percent:= r_sch_rec.schedule_percent(eg_recno);
				l_proc_step := 90 + (eg_recno / 100000);

				hr_utility.trace(' l_sub_slice_counter: ' || fnd_number.number_to_canonical(l_sub_slice_counter) ||
					' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no) ||
					' l_start_date: ' || fnd_date.date_to_canonical(l_start_date) ||
					' l_end_date: ' || fnd_date.date_to_canonical(l_end_date) ||
					' l_schedule_percent: ' || fnd_number.number_to_canonical(l_schedule_percent));

--				OPEN eg_matrix_cur;
--				FETCH eg_matrix_cur INTO l_start_date, l_end_date, l_schedule_percent;
--				IF (eg_matrix_cur%NOTFOUND) THEN
				IF (l_start_date > l_asg_end_date) THEN
					r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
					r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
					r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
					r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
					r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
					r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
					r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
					r_enc_period_tmp1.r_process_flag(l_rec_no) := 'Y';
					r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
					r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
					l_rec_no := l_rec_no + 1;
					EXIT;
				END IF;
--					CLOSE eg_matrix_cur;
--					EXIT;
--				END IF;
--				CLOSE eg_matrix_cur;

				IF (l_end_date >= l_asg_start_date) AND (l_start_date <= l_asg_end_date) THEN
					IF (l_asg_start_date = l_start_date AND l_asg_end_date = l_end_date) THEN
						r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
						r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
						r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
						r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
						r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
						r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
						r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
						r_enc_period_tmp1.r_process_flag(l_rec_no) := 'EG';
						r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
						r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
						l_rec_no := l_rec_no + 1;
						IF (l_schedule_percent < 100) THEN
							r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'BAL';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
						END IF;
						EXIT;
					ELSE
						IF (l_start_date > GREATEST(l_period_start_date, l_asg_start_date)) THEN
							l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date);
							l_new_end_date := l_start_date - 1;
							r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'Y';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							l_asg_start_date := l_start_date;
						END IF;

						IF (l_end_date < LEAST(l_period_end_date, l_asg_end_date)) THEN
							l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date, l_start_date);
							l_new_end_date := l_end_date;
							r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'EG';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							IF (l_schedule_percent < 100) THEN
								r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'BAL';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
							l_asg_start_date := l_end_date + 1;
							IF (eg_recno = r_sch_rec.start_date.COUNT) AND
								(l_asg_start_date <= l_asg_end_date) THEN
								r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'Y';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
						ELSE
							r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'EG';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							IF (l_schedule_percent < 100) THEN
								r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'BAL';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
							l_asg_start_date := l_end_date + 1;
						END IF;
					END IF;
					l_sub_slice_counter := 2;
				ELSE
					IF (eg_recno = r_sch_rec.start_date.COUNT) THEN
						r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
						r_enc_period_tmp1.r_period_start_date(l_rec_no) := r_enc_period.r_period_start_date(I);
						r_enc_period_tmp1.r_period_end_date(l_rec_no) := r_enc_period.r_period_end_date(I);
						r_enc_period_tmp1.r_asg_start_date(l_rec_no) := r_enc_period.r_asg_start_date(I);
						r_enc_period_tmp1.r_asg_end_date(l_rec_no) := r_enc_period.r_asg_end_date(I);
						r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
						r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
						r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
						r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
						r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
						l_rec_no := l_rec_no + 1;
					END IF;
				END IF;
				l_sch_pointer := eg_recno;
				EXIT WHEN l_asg_start_date > l_asg_end_date;
			END LOOP;
		ELSE
			r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
			r_enc_period_tmp1.r_period_start_date(l_rec_no) := r_enc_period.r_period_start_date(I);
			r_enc_period_tmp1.r_period_end_date(l_rec_no) := r_enc_period.r_period_end_date(I);
			r_enc_period_tmp1.r_asg_start_date(l_rec_no) := r_enc_period.r_asg_start_date(I);
			r_enc_period_tmp1.r_asg_end_date(l_rec_no) := r_enc_period.r_asg_end_date(I);
			r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
			r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
			r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
			r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
			r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
			l_rec_no := l_rec_no + 1;
		END IF;
	END LOOP;

	r_enc_period.r_time_period_id.DELETE;
	r_enc_period.r_period_start_date.DELETE;
	r_enc_period.r_period_end_date.DELETE;
	r_enc_period.r_asg_start_date.DELETE;
	r_enc_period.r_asg_end_date.DELETE;
	r_enc_period.r_process_flag.DELETE;
	r_enc_period.r_period_ind.DELETE;
	r_enc_period.r_schedule_percent.DELETE;
	r_enc_period.r_encumbrance_amount.DELETE;
	r_enc_period.r_period_amount.DELETE;
	r_enc_period.r_reason_code.DELETE;
	r_enc_period.r_effective_date.DELETE;
	l_rec_no := 1;
	l_proc_step := 100;

	hr_utility.trace('Dumping Assignment Chunk After Element Group Processing ...');
	hr_utility.trace(LPAD('Chunk Pointer', 13, ' ') || '	' ||
		LPAD('Time Period Id', 14, ' ') || '	' || RPAD('Period Start Date', 17, ' ') || '	' ||
		RPAD('Period End Date', 15, ' ') || '	' || RPAD('Asg Start Date', 14, ' ') || '	' ||
		RPAD('Asg End Date', 12, ' ') || '	' || RPAD('Effective Date', 14, ' ') || '	' ||
		RPAD('Process Flag', 12, ' ') || '	' || LPAD('Schedule Percent', 16, ' ') || '	' ||
		RPAD('Reason Code', 50, ' '));
	hr_utility.trace(LPAD('-', 13, '-') || '	' ||
		LPAD('-', 14, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || LPAD('-', 16, '-') || '	' ||
		RPAD('-', 50, '-'));

	FOR recno IN 1..r_enc_period_tmp1.r_time_period_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_enc_period_tmp1.r_period_ind(recno), 13, ' ') || '	' ||
			LPAD(r_enc_period_tmp1.r_time_period_id(recno), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period_tmp1.r_period_start_date(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period_tmp1.r_period_end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period_tmp1.r_asg_start_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period_tmp1.r_asg_end_date(recno), 'DD-MON-RRRR'), 12, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period_tmp1.r_effective_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(r_enc_period_tmp1.r_process_flag(recno), 12, ' ') || '	' ||
			LPAD(r_enc_period_tmp1.r_schedule_percent(recno), 16, ' ') || '	' ||
			RPAD(r_enc_period_tmp1.r_reason_code(recno), 50, ' '));
	END LOOP;
	hr_utility.trace('Assignment Processing ...');

	psp_matrix_driver_pkg.clear_table('REFRESH');
	psp_matrix_driver_pkg.purge_table;
	l_period_count := r_enc_period.r_time_period_id.COUNT;
	OPEN ls_hier_cur('A');
	FETCH ls_hier_cur INTO l_schedule_hierarchy_id;
	CLOSE ls_hier_cur;

/*****	Commented for bug fix 3970852 to resolve issues when schedule dates equal default end date
	psp_matrix_driver_pkg.clear_table('REFRESH');
	psp_matrix_driver_pkg.purge_table;
	psp_matrix_driver_pkg.load_table(l_schedule_hierarchy_id);

	DELETE	psp_matrix_driver
	WHERE	run_id = l_run_id
	AND	(period_start_date > l_max_end_date
		OR period_end_date < l_min_start_date
		OR period_schedule_percent = 0);

	UPDATE	psp_matrix_driver pmd
	SET	period_end_date = period_end_date - 1
	WHERE	run_id = l_run_id
	AND	period_start_date < period_end_date
	AND	period_start_date = (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
	AND	EXISTS (SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
			AND	psl1.schedule_begin_date = pmd.period_end_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);

	UPDATE	psp_matrix_driver pmd
	SET	period_end_date = period_end_date - 1
	WHERE	run_id = l_run_id
	AND	period_start_date < period_end_date
	AND	NOT (NOT EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
			AND	psl1.schedule_begin_date = pmd.period_end_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_end_date = pmd.period_end_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id))
	AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);

	UPDATE	psp_matrix_driver pmd
	SET	period_start_date = period_start_date + 1
	WHERE	run_id = l_run_id
	AND	period_start_date < period_end_date
	AND	NOT EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_begin_date = pmd.period_start_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
	AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);

	UPDATE	psp_matrix_driver pmd
	SET	period_start_date = period_start_date + 1
	WHERE	run_id = l_run_id
	AND	period_start_date < period_end_date
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_begin_date = pmd.period_start_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
			AND	psl1.schedule_end_date = pmd.period_start_date
			AND	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id)
	AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = l_schedule_hierarchy_id);
	End of comment for bug fix 3970852	*****/

--	Introduced the following to prepare schedule chunk dates instead of load_table for bug fix 3970852
	recno := 1;

	OPEN dates(l_schedule_hierarchy_id);
	FETCH dates BULK COLLECT INTO initial_dates, date_type;
	CLOSE dates;

	FOR rowno IN 1..(initial_dates.COUNT - 1)
	LOOP
		IF (date_type(rowno) = 'B' AND date_type(rowno+1) = 'B') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno);
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1) - 1;
			recno := recno+1;
		ELSIF (date_type(rowno) = 'B' AND date_type(rowno+1) = 'E') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno);
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1);
			recno := recno+1;
		ELSIF (date_type(rowno) = 'E' AND date_type(rowno+1) = 'E') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno) + 1;
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1);
			recno := recno+1;
		ELSIF (date_type(rowno) = 'E' AND date_type(rowno+1) = 'B') THEN
			schedule_chunk.schedule_begin_date(recno) := initial_dates(rowno) + 1;
			schedule_chunk.schedule_end_date(recno) := initial_dates(rowno+1) -1;
			recno := recno+1;
		END IF;
	END LOOP;

	FORALL rowno IN 1..schedule_chunk.schedule_begin_date.COUNT
	INSERT INTO psp_matrix_driver
		(RUN_ID,					SCHEDULE_LINE_ID,
		PERIOD_START_DATE,			PERIOD_END_DATE,
		PERIOD_SCHEDULE_PERCENT)
	SELECT 	l_run_id,	schedule_line_id,
		GREATEST(l_min_start_date, schedule_chunk.schedule_begin_date(rowno)),
		LEAST(l_max_end_date, schedule_chunk.schedule_end_date(rowno)),
		schedule_percent
	FROM	psp_schedule_lines psl
	WHERE	schedule_hierarchy_id = l_schedule_hierarchy_id
	AND	schedule_end_date >= l_min_start_date
	AND	schedule_begin_date <= l_max_end_date
	AND	(	gl_code_combination_id IS NOT NULL
		OR	award_id IS NOT NULL)
	AND	psl.schedule_begin_date <= schedule_chunk.schedule_end_date(rowno)
	AND	psl.schedule_end_date >= schedule_chunk.schedule_begin_date(rowno);

	initial_dates.delete;
	date_type.delete;
	schedule_chunk.schedule_end_date.delete;
	schedule_chunk.schedule_begin_date.delete;
--	End of bug fix 3970852

	l_sch_pointer := 1;
	OPEN ls_matrix_cur;
	FETCH ls_matrix_cur BULK COLLECT INTO r_sch_rec.start_date, r_sch_rec.end_date, r_sch_rec.schedule_percent;
	CLOSE ls_matrix_cur;

	hr_utility.trace('r_sch_rec.start_date.COUNT: ' || r_sch_rec.start_date.COUNT);
	hr_utility.trace('Schedule Chunk Details');
	hr_utility.trace(RPAD('Start Date', 15, ' ') || '	' ||
		RPAD('End Date', 15, ' ') || '	' || LPAD('Schedule Percent', 16, ' '));

	hr_utility.trace(RPAD('-', 15, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 16, '-'));

	FOR recno IN 1..r_sch_rec.start_date.COUNT
	LOOP
		hr_utility.trace(RPAD(TO_CHAR(r_sch_rec.start_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_sch_rec.end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			LPAD(r_sch_rec.schedule_percent(recno), 16, ' '));
	END LOOP;

	FOR I IN 1..r_enc_period_tmp1.r_time_period_id.COUNT
	LOOP
		l_period_start_date := r_enc_period_tmp1.r_period_start_date(I);
		l_period_end_date := r_enc_period_tmp1.r_period_end_date(I);
		l_asg_start_date := r_enc_period_tmp1.r_asg_start_date(I);
		l_asg_end_date := r_enc_period_tmp1.r_asg_end_date(I);
		l_process_flag := r_enc_period_tmp1.r_process_flag(I);
		l_sub_slice_counter := 1;
		l_proc_step := 110 + (I / 100000);

		hr_utility.trace('I: ' || fnd_number.number_to_canonical(I) ||
			' l_period_start_date: ' || fnd_date.date_to_canonical(l_period_start_date) ||
			' l_period_end_date: ' || fnd_date.date_to_canonical(l_period_end_date) ||
			' l_asg_start_date: ' || fnd_date.date_to_canonical(l_asg_start_date) ||
			' l_asg_end_date: ' || fnd_date.date_to_canonical(l_asg_end_date) ||
			' r_enc_period_tmp1.r_time_period_id(I): ' || fnd_number.number_to_canonical(r_enc_period_tmp1.r_time_period_id(I)) ||
			' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no));

		IF (l_process_flag = 'Y') AND (r_sch_rec.end_date.COUNT > 0) THEN
			FOR asg_recno IN l_sch_pointer..r_sch_rec.start_date.COUNT
			LOOP
				l_start_date:= r_sch_rec.start_date(asg_recno);
				l_end_date:= r_sch_rec.end_date(asg_recno);
				l_schedule_percent:= r_sch_rec.schedule_percent(asg_recno);
				l_proc_step := 120 + (l_rec_no / 100000);

				hr_utility.trace(' l_sub_slice_counter: ' || fnd_number.number_to_canonical(l_sub_slice_counter) ||
					' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no) ||
					' l_start_date: ' || fnd_date.date_to_canonical(l_start_date) ||
					' l_end_date: ' || fnd_date.date_to_canonical(l_end_date) ||
					' l_schedule_percent: ' || fnd_number.number_to_canonical(l_schedule_percent));
--				OPEN ls_matrix_cur;
--				FETCH ls_matrix_cur INTO l_start_date, l_end_date, l_schedule_percent;
--				IF (ls_matrix_cur%NOTFOUND) THEN
				IF (l_start_date > l_asg_end_date) THEN
					r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
					r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
					r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
					r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
					r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
					r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
					r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
					r_enc_period.r_process_flag(l_rec_no) := 'Y';
					r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
					r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
					l_rec_no := l_rec_no + 1;
					EXIT;
				END IF;
--					CLOSE ls_matrix_cur;
--					EXIT;
--				END IF;
--				CLOSE ls_matrix_cur;

				IF (l_end_date >= l_asg_start_date) AND (l_start_date <= l_asg_end_date) THEN
					IF (l_asg_start_date = l_start_date AND l_asg_end_date = l_end_date) THEN
						r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
						r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
						r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
						r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
						r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
						r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
						r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
						r_enc_period.r_process_flag(l_rec_no) := 'A';
						r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
						r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
						l_rec_no := l_rec_no + 1;
						IF (l_schedule_percent < 100) THEN
							r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
							r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
							r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
							r_enc_period.r_process_flag(l_rec_no) := 'BAL';
							r_enc_period.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
							r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
						END IF;
						EXIT;
					ELSE
						IF (l_start_date > GREATEST(l_period_start_date, l_asg_start_date)) THEN
							l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date);
							l_new_end_date := l_start_date - 1;
							r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
							r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period.r_asg_start_date(l_rec_no) := l_new_start_date;
							r_enc_period.r_asg_end_date(l_rec_no) := l_new_end_date;
							r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
							r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
							r_enc_period.r_process_flag(l_rec_no) := 'Y';
							r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
							r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							l_asg_start_date := l_start_date;
						END IF;

						IF (l_end_date < LEAST(l_period_end_date, l_asg_end_date)) THEN
							l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date, l_start_date);
							l_new_end_date := l_end_date;
							r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
							r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period.r_asg_start_date(l_rec_no) := l_new_start_date;
							r_enc_period.r_asg_end_date(l_rec_no) := l_new_end_date;
							r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
							r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
							r_enc_period.r_process_flag(l_rec_no) := 'A';
							r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
							r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							IF (l_schedule_percent < 100) THEN
								r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
								r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period.r_asg_start_date(l_rec_no) := l_new_start_date;
								r_enc_period.r_asg_end_date(l_rec_no) := l_new_end_date;
								r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
								r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
								r_enc_period.r_process_flag(l_rec_no) := 'BAL';
								r_enc_period.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
								r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
							l_asg_start_date := l_end_date + 1;
							IF (asg_recno = r_sch_rec.start_date.COUNT) AND
								(l_asg_start_date <= l_asg_end_date) THEN
								r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
								r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
								r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
								r_enc_period.r_process_flag(l_rec_no) := 'Y';
								r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
								r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
						ELSE
							r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
							r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
							r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
							r_enc_period.r_process_flag(l_rec_no) := 'A';
							r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
							r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							IF (l_schedule_percent < 100) THEN
								r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
								r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
								r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
								r_enc_period.r_process_flag(l_rec_no) := 'BAL';
								r_enc_period.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
								r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
							l_asg_start_date := l_end_date + 1;
						END IF;
					END IF;
					l_sub_slice_counter := 2;
				ELSE
					IF (asg_recno = r_sch_rec.start_date.COUNT) THEN
						r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
						r_enc_period.r_period_start_date(l_rec_no) := r_enc_period_tmp1.r_period_start_date(I);
						r_enc_period.r_period_end_date(l_rec_no) := r_enc_period_tmp1.r_period_end_date(I);
						r_enc_period.r_asg_start_date(l_rec_no) := r_enc_period_tmp1.r_asg_start_date(I);
						r_enc_period.r_asg_end_date(l_rec_no) := r_enc_period_tmp1.r_asg_end_date(I);
						r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
						r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
						r_enc_period.r_process_flag(l_rec_no) := r_enc_period_tmp1.r_process_flag(I);
						r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
						r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
						l_rec_no := l_rec_no + 1;
					END IF;
				END IF;
				l_sch_pointer := asg_recno;
				EXIT WHEN l_asg_start_date > l_asg_end_date;
			END LOOP;
		ELSE
			r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
			r_enc_period.r_period_start_date(l_rec_no) := r_enc_period_tmp1.r_period_start_date(I);
			r_enc_period.r_period_end_date(l_rec_no) := r_enc_period_tmp1.r_period_end_date(I);
			r_enc_period.r_asg_start_date(l_rec_no) := r_enc_period_tmp1.r_asg_start_date(I);
			r_enc_period.r_asg_end_date(l_rec_no) := r_enc_period_tmp1.r_asg_end_date(I);
			r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
			r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
			r_enc_period.r_process_flag(l_rec_no) := r_enc_period_tmp1.r_process_flag(I);
			r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
			r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
			l_rec_no := l_rec_no + 1;
		END IF;
	END LOOP;

	r_sch_rec.start_date.delete;
	r_sch_rec.end_date.delete;
	r_sch_rec.schedule_percent.delete;
	r_enc_period_tmp1.r_time_period_id.DELETE;
	r_enc_period_tmp1.r_period_start_date.DELETE;
	r_enc_period_tmp1.r_period_end_date.DELETE;
	r_enc_period_tmp1.r_asg_start_date.DELETE;
	r_enc_period_tmp1.r_asg_end_date.DELETE;
	r_enc_period_tmp1.r_process_flag.DELETE;
	r_enc_period_tmp1.r_period_ind.DELETE;
	r_enc_period_tmp1.r_schedule_percent.DELETE;
	r_enc_period_tmp1.r_encumbrance_amount.DELETE;
	r_enc_period_tmp1.r_period_amount.DELETE;
	r_enc_period_tmp1.r_reason_code.DELETE;
	r_enc_period_tmp1.r_effective_date.DELETE;
	l_rec_no := 1;
	l_proc_step := 130;

--	psp_matrix_driver_pkg.clear_table('REFRESH');		Commented for bug fix 3970852
--	psp_matrix_driver_pkg.purge_table;			Commented for bug fix 3970852

	hr_utility.trace('Dumping Assignment Chunk After Assignment Processing ...');
	hr_utility.trace(LPAD('Chunk Pointer', 13, ' ') || '	' ||
		LPAD('Time Period Id', 14, ' ') || '	' || RPAD('Period Start Date', 17, ' ') || '	' ||
		RPAD('Period End Date', 15, ' ') || '	' || RPAD('Asg Start Date', 14, ' ') || '	' ||
		RPAD('Asg End Date', 12, ' ') || '	' || RPAD('Effective Date', 14, ' ') || '	' ||
		RPAD('Process Flag', 12, ' ') || '	' || LPAD('Schedule Percent', 16, ' ') || '	' ||
		RPAD('Reason Code', 50, ' '));
	hr_utility.trace(LPAD('-', 13, '-') || '	' ||
		LPAD('-', 14, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || LPAD('-', 16, '-') || '	' ||
		RPAD('-', 50, '-'));

	FOR recno IN 1..r_enc_period.r_time_period_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_enc_period.r_period_ind(recno), 13, ' ') || '	' ||
			LPAD(r_enc_period.r_time_period_id(recno), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_period_start_date(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_period_end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_asg_start_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_asg_end_date(recno), 'DD-MON-RRRR'), 12, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_effective_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(r_enc_period.r_process_flag(recno), 12, ' ') || '	' ||
			LPAD(r_enc_period.r_schedule_percent(recno), 16, ' ') || '	' ||
			RPAD(r_enc_period.r_reason_code(recno), 50, ' '));
	END LOOP;

	IF (g_org_def_labor_schedule = 'Y') THEN
		hr_utility.trace('Organization Default LS Processing');

		l_sch_pointer := 1;
		OPEN odls_cur;
		FETCH odls_cur BULK COLLECT INTO r_sch_rec.start_date, r_sch_rec.end_date, r_sch_rec.schedule_percent;
		CLOSE odls_cur;

		hr_utility.trace('r_sch_rec.start_date.COUNT: ' || r_sch_rec.start_date.COUNT);
		hr_utility.trace('Schedule Chunk Details');
		hr_utility.trace(RPAD('Start Date', 15, ' ') || '	' ||
			RPAD('End Date', 15, ' ') || '	' || LPAD('Schedule Percent', 16, ' '));
		hr_utility.trace(RPAD('-', 15, '-') || '	' ||
			RPAD('-', 15, '-') || '	' || RPAD('-', 16, '-'));

		FOR recno IN 1..r_sch_rec.start_date.COUNT
		LOOP
			hr_utility.trace(RPAD(TO_CHAR(r_sch_rec.start_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
				RPAD(TO_CHAR(r_sch_rec.end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
				LPAD(r_sch_rec.schedule_percent(recno), 16, ' '));
		END LOOP;

		FOR I IN 1..r_enc_period.r_time_period_id.COUNT
		LOOP
			l_period_start_date := r_enc_period.r_period_start_date(I);
			l_period_end_date := r_enc_period.r_period_end_date(I);
			l_asg_start_date := r_enc_period.r_asg_start_date(I);
			l_asg_end_date := r_enc_period.r_asg_end_date(I);
			l_process_flag := r_enc_period.r_process_flag(I);
			l_sub_slice_counter := 1;
			l_proc_step := 150 + (I / 100000);

			hr_utility.trace('I: ' || fnd_number.number_to_canonical(I) ||
				' l_period_start_date: ' || fnd_date.date_to_canonical(l_period_start_date) ||
				' l_period_end_date: ' || fnd_date.date_to_canonical(l_period_end_date) ||
				' l_asg_start_date: ' || fnd_date.date_to_canonical(l_asg_start_date) ||
				' l_asg_end_date: ' || fnd_date.date_to_canonical(l_asg_end_date) ||
				' r_enc_period.r_time_period_id(I): ' || fnd_number.number_to_canonical(r_enc_period.r_time_period_id(I)) ||
				' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no));

			IF (l_process_flag = 'Y') AND (r_sch_rec.end_date.COUNT > 0) THEN
				FOR odls_recno IN l_sch_pointer..r_sch_rec.start_date.COUNT
				LOOP
					l_start_date:= r_sch_rec.start_date(odls_recno);
					l_end_date:= r_sch_rec.end_date(odls_recno);
					l_schedule_percent:= r_sch_rec.schedule_percent(odls_recno);
					l_proc_step := 160 + (l_rec_no / 100000);
--					OPEN odls_cur(l_asg_start_date, l_asg_end_date);
--					FETCH odls_cur INTO l_start_date, l_end_date, l_schedule_percent;

					hr_utility.trace('l_sub_slice_counter: ' || fnd_number.number_to_canonical(l_sub_slice_counter) ||
						' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no) ||
						' l_start_date: ' || fnd_date.date_to_canonical(l_start_date) ||
						' l_end_date: ' || fnd_date.date_to_canonical(l_end_date) ||
						' l_schedule_percent: ' || fnd_number.number_to_canonical(l_schedule_percent));
--						hr_utility.trace('odls_cur%ROWCOUNT: ' || fnd_number.number_to_canonical(odls_cur%ROWCOUNT));

--					IF (odls_cur%NOTFOUND) THEN
					IF (l_start_date > l_asg_end_date) THEN
						r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
						r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
						r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
						r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
						r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
						r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
						r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
						r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
						r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
						r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
						l_rec_no := l_rec_no + 1;
						EXIT;
					END IF;
--						CLOSE odls_cur;
--						EXIT;
--					END IF;
--					CLOSE odls_cur;

					IF (l_end_date >= l_asg_start_date) AND (l_start_date <= l_asg_end_date) THEN
						IF (l_asg_start_date = l_start_date AND l_asg_end_date = l_end_date) THEN
							r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'DS';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
							IF (l_schedule_percent < 100) THEN
								r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'BAL';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
							END IF;
							EXIT;
						ELSE
							IF (l_start_date > GREATEST(l_period_start_date, l_asg_start_date)) THEN
								l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date);
								l_new_end_date := l_start_date - 1;
								r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'Y';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
								l_asg_start_date := l_start_date;
							END IF;

							IF (l_end_date < LEAST(l_period_end_date, l_asg_end_date)) THEN
								l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date, l_start_date);
								l_new_end_date := l_end_date;
								r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'DS';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
								IF (l_schedule_percent < 100) THEN
									r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
									r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
									r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
									r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
									r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
									r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
									r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
									r_enc_period_tmp1.r_process_flag(l_rec_no) := 'BAL';
									r_enc_period_tmp1.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
									r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
									l_rec_no := l_rec_no + 1;
								END IF;
								l_asg_start_date := l_end_date + 1;
								IF (odls_recno = r_sch_rec.start_date.COUNT) AND
									(l_asg_start_date <= l_asg_end_date) THEN
									r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
									r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
									r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
									r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
									r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
									r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
									r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
									r_enc_period_tmp1.r_process_flag(l_rec_no) := 'Y';
									r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
									r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
									l_rec_no := l_rec_no + 1;
								END IF;
/*****	Commented the following code for bug fix 3672723 as it was causing duplicate posting for same assignment chunks
							r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'Y';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
							l_rec_no := l_rec_no + 1;
	End of Comment for bug fix 3673723	*****/
							ELSE
								r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'DS';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
								IF (l_schedule_percent < 100) THEN
									r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
									r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
									r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
									r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
									r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
									r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
									r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
									r_enc_period_tmp1.r_process_flag(l_rec_no) := 'BAL';
									r_enc_period_tmp1.r_schedule_percent(l_rec_no) := 100 - l_schedule_percent;
									r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
									l_rec_no := l_rec_no + 1;
								END IF;
								l_asg_start_date := l_end_date + 1;
							END IF;
						END IF;
						l_sub_slice_counter := 2;
					ELSE
						IF (odls_recno = r_sch_rec.start_date.COUNT) THEN
							r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := r_enc_period.r_period_start_date(I);
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := r_enc_period.r_period_end_date(I);
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := r_enc_period.r_asg_start_date(I);
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := r_enc_period.r_asg_end_date(I);
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
						END IF;
					END IF;
					l_sch_pointer := odls_recno;
					EXIT WHEN l_asg_start_date > l_asg_end_date;
				END LOOP;
			ELSE
				r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
				r_enc_period_tmp1.r_period_start_date(l_rec_no) := r_enc_period.r_period_start_date(I);
				r_enc_period_tmp1.r_period_end_date(l_rec_no) := r_enc_period.r_period_end_date(I);
				r_enc_period_tmp1.r_asg_start_date(l_rec_no) := r_enc_period.r_asg_start_date(I);
				r_enc_period_tmp1.r_asg_end_date(l_rec_no) := r_enc_period.r_asg_end_date(I);
				r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
				r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
				r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
				r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
				r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
				l_rec_no := l_rec_no + 1;
			END IF;
		END LOOP;

		r_sch_rec.start_date.delete;
		r_sch_rec.end_date.delete;
		r_sch_rec.schedule_percent.delete;
		r_enc_period.r_time_period_id.DELETE;
		r_enc_period.r_period_start_date.DELETE;
		r_enc_period.r_period_end_date.DELETE;
		r_enc_period.r_asg_start_date.DELETE;
		r_enc_period.r_asg_end_date.DELETE;
		r_enc_period.r_process_flag.DELETE;
		r_enc_period.r_period_ind.DELETE;
		r_enc_period.r_schedule_percent.DELETE;
		r_enc_period.r_encumbrance_amount.DELETE;
		r_enc_period.r_period_amount.DELETE;
		r_enc_period.r_reason_code.DELETE;
		r_enc_period.r_effective_date.DELETE;
		l_rec_no := 1;
		l_proc_step := 170;

		hr_utility.trace('Dumping Assignment Chunk After Organization Default Schedules Processing ...');
		hr_utility.trace(LPAD('Chunk Pointer', 13, ' ') || '	' ||
			LPAD('Time Period Id', 14, ' ') || '	' || RPAD('Period Start Date', 17, ' ') || '	' ||
			RPAD('Period End Date', 15, ' ') || '	' || RPAD('Asg Start Date', 14, ' ') || '	' ||
			RPAD('Asg End Date', 12, ' ') || '	' || RPAD('Effective Date', 14, ' ') || '	' ||
			RPAD('Process Flag', 12, ' ') || '	' || LPAD('Schedule Percent', 16, ' ') || '	' ||
			RPAD('Reason Code', 50, ' '));
		hr_utility.trace(LPAD('-', 13, '-') || '	' ||
			LPAD('-', 14, '-') || '	' || RPAD('-', 17, '-') || '	' ||
			RPAD('-', 15, '-') || '	' || RPAD('-', 14, '-') || '	' ||
			RPAD('-', 12, '-') || '	' || RPAD('-', 14, '-') || '	' ||
			RPAD('-', 12, '-') || '	' || LPAD('-', 16, '-') || '	' ||
			RPAD('-', 50, '-'));

		FOR recno IN 1..r_enc_period_tmp1.r_time_period_id.COUNT
		LOOP
			hr_utility.trace(LPAD(r_enc_period_tmp1.r_period_ind(recno), 13, ' ') || '	' ||
				LPAD(r_enc_period_tmp1.r_time_period_id(recno), 14, ' ') || '	' ||
				RPAD(TO_CHAR(r_enc_period_tmp1.r_period_start_date(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
				RPAD(TO_CHAR(r_enc_period_tmp1.r_period_end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
				RPAD(TO_CHAR(r_enc_period_tmp1.r_asg_start_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
				RPAD(TO_CHAR(r_enc_period_tmp1.r_asg_end_date(recno), 'DD-MON-RRRR'), 12, ' ') || '	' ||
				RPAD(TO_CHAR(r_enc_period_tmp1.r_effective_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
				RPAD(r_enc_period_tmp1.r_process_flag(recno), 12, ' ') || '	' ||
				LPAD(r_enc_period_tmp1.r_schedule_percent(recno), 16, ' ') || '	' ||
				RPAD(r_enc_period_tmp1.r_reason_code(recno), 50, ' '));
		END LOOP;

		FOR I IN 1..r_enc_period_tmp1.r_time_period_id.COUNT
		LOOP
			r_enc_period.r_period_ind(I) := r_enc_period_tmp1.r_period_ind(I);
			r_enc_period.r_period_start_date(I) := r_enc_period_tmp1.r_period_start_date(I);
			r_enc_period.r_period_end_date(I) := r_enc_period_tmp1.r_period_end_date(I);
			r_enc_period.r_asg_start_date(I) := r_enc_period_tmp1.r_asg_start_date(I);
			r_enc_period.r_asg_end_date(I) := r_enc_period_tmp1.r_asg_end_date(I);
			r_enc_period.r_time_period_id(I) := r_enc_period_tmp1.r_time_period_id(I);
			r_enc_period.r_effective_date(I) := r_enc_period_tmp1.r_effective_date(I);
			r_enc_period.r_process_flag(I) := r_enc_period_tmp1.r_process_flag(I);
			r_enc_period.r_schedule_percent(I) := r_enc_period_tmp1.r_schedule_percent(I);
			r_enc_period.r_reason_code(I) := r_enc_period_tmp1.r_reason_code(I);
		END LOOP;
	END IF;

	IF (g_org_def_account = 'Y') THEN
		hr_utility.trace('Organization Default Account Processing');

		l_sch_pointer := 1;
		FOR I IN 1..r_enc_period.r_time_period_id.COUNT
		LOOP
			l_period_start_date := r_enc_period.r_period_start_date(I);
			l_period_end_date := r_enc_period.r_period_end_date(I);
			l_asg_start_date := r_enc_period.r_asg_start_date(I);
			l_asg_end_date := r_enc_period.r_asg_end_date(I);
			l_process_flag := r_enc_period.r_process_flag(I);
			l_sub_slice_counter := 1;
			l_proc_step := 180 + (I / 100000);

			hr_utility.trace('I: ' || fnd_number.number_to_canonical(I) ||
				' l_period_start_date: ' || fnd_date.date_to_canonical(l_period_start_date) ||
				' l_period_end_date: ' || fnd_date.date_to_canonical(l_period_end_date) ||
				' l_asg_start_date: ' || fnd_date.date_to_canonical(l_asg_start_date) ||
				' l_asg_end_date: ' || fnd_date.date_to_canonical(l_asg_end_date) ||
				' r_enc_period.r_time_period_id(I): ' || fnd_number.number_to_canonical(r_enc_period.r_time_period_id(I)) ||
				' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no));

			IF (l_process_flag IN ('BAL', 'Y')) AND (r_da.end_date_active.COUNT > 0) THEN
				FOR da_recno IN l_sch_pointer..r_da.start_date_active.COUNT
				LOOP
					l_start_date:= r_da.start_date_active(da_recno);
					l_end_date:= r_da.end_date_active(da_recno);
					IF (l_process_flag = 'BAL') THEN
						l_schedule_percent := r_enc_period.r_schedule_percent(I);
					ELSE
						l_schedule_percent:= r_da.percent(da_recno);
					END IF;
					l_proc_step := 190 + (l_rec_no / 100000);

					hr_utility.trace(' l_sub_slice_counter: ' || fnd_number.number_to_canonical(l_sub_slice_counter) ||
						' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no) ||
						' l_start_date: ' || fnd_date.date_to_canonical(l_start_date) ||
						' l_end_date: ' || fnd_date.date_to_canonical(l_end_date) ||
						' l_schedule_percent: ' || fnd_number.number_to_canonical(l_schedule_percent));

					IF (l_start_date > l_asg_end_date) THEN
						r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
						r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
						r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
						r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
						r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
						r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
						r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
						r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
						r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
						r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
						l_rec_no := l_rec_no + 1;
						EXIT;
					END IF;

					IF (l_end_date >= l_asg_start_date) AND (l_start_date <= l_asg_end_date) THEN
						IF (l_process_flag = 'BAL') THEN
							l_reason_code := '1';
							l_schedule_percent := r_enc_period.r_schedule_percent(I);
							fnd_message.set_name('PSP', 'PSP_DEFAULT_REASON_1');
							fnd_message.set_token('START_DATE', l_asg_start_date);
							fnd_message.set_token('END_DATE', l_asg_end_date);
							fnd_message.set_token('PERCENT', r_enc_period.r_schedule_percent(I));
							g_warning_message := fnd_message.get;
							add_cel_warnings(p_start_date	=>	l_asg_start_date,
								p_hierarchy_code	=>	'DA',
								p_end_date		=>	l_asg_end_date,
								p_warning_code	=>	'BAL',
								p_percent		=>	r_enc_period.r_schedule_percent(I));
						ELSE
							l_reason_code := '3';
							fnd_message.set_name('PSP', 'PSP_DEFAULT_REASON_3');
							fnd_message.set_token('START_DATE', l_asg_start_date);
							fnd_message.set_token('END_DATE', l_asg_end_date);
							g_warning_message := fnd_message.get;
							add_cel_warnings(p_start_date	=>	l_asg_start_date,
								p_hierarchy_code	=>	'DA',
								p_end_date		=>	l_asg_end_date,
								p_warning_code	=>	'NO_CI');
						END IF;
						IF (l_asg_start_date = l_start_date AND l_asg_end_date = l_end_date) THEN
							r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := 'DA';
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := l_schedule_percent;
							r_enc_period_tmp1.r_reason_code(l_rec_no) := l_reason_code;
							l_rec_no := l_rec_no + 1;
						ELSE
							IF (l_start_date > GREATEST(l_period_start_date, l_asg_start_date)) THEN
								l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date);
								l_new_end_date := l_start_date - 1;
								r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
								r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
								l_asg_start_date := l_start_date;
							END IF;

							IF (l_end_date < LEAST(l_period_end_date, l_asg_end_date)) THEN
								l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date, l_start_date);
								l_new_end_date := l_end_date;
								r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_new_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_new_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'DA';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := l_schedule_percent;
								r_enc_period_tmp1.r_reason_code(l_rec_no) := l_reason_code;
								l_rec_no := l_rec_no + 1;
								l_asg_start_date := l_end_date + 1;
								IF (da_recno = r_da.start_date_active.COUNT) AND
									(l_asg_start_date <= l_asg_end_date) THEN
									r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
									r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
									r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
									r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
									r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
									r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
									r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
									r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
									r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
									r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
									l_rec_no := l_rec_no + 1;
								END IF;
							ELSE
								r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
								r_enc_period_tmp1.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period_tmp1.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period_tmp1.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period_tmp1.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
								r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
								r_enc_period_tmp1.r_process_flag(l_rec_no) := 'DA';
								r_enc_period_tmp1.r_schedule_percent(l_rec_no) := l_schedule_percent;
								r_enc_period_tmp1.r_reason_code(l_rec_no) := l_reason_code;
								l_rec_no := l_rec_no + 1;
								l_asg_start_date := l_end_date + 1;
							END IF;
						END IF;
						l_sub_slice_counter := 2;
					ELSE
						IF (da_recno = r_da.start_date_active.COUNT) THEN
							r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
							r_enc_period_tmp1.r_period_start_date(l_rec_no) := r_enc_period.r_period_start_date(I);
							r_enc_period_tmp1.r_period_end_date(l_rec_no) := r_enc_period.r_period_end_date(I);
							r_enc_period_tmp1.r_asg_start_date(l_rec_no) := r_enc_period.r_asg_start_date(I);
							r_enc_period_tmp1.r_asg_end_date(l_rec_no) := r_enc_period.r_asg_end_date(I);
							r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
							r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
							r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
							r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
							r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
						END IF;
					END IF;
					l_sch_pointer := da_recno;
					EXIT WHEN l_asg_start_date > l_asg_end_date;
				END LOOP;
			ELSE
				r_enc_period_tmp1.r_period_ind(l_rec_no) := r_enc_period.r_period_ind(I);
				r_enc_period_tmp1.r_period_start_date(l_rec_no) := r_enc_period.r_period_start_date(I);
				r_enc_period_tmp1.r_period_end_date(l_rec_no) := r_enc_period.r_period_end_date(I);
				r_enc_period_tmp1.r_asg_start_date(l_rec_no) := r_enc_period.r_asg_start_date(I);
				r_enc_period_tmp1.r_asg_end_date(l_rec_no) := r_enc_period.r_asg_end_date(I);
				r_enc_period_tmp1.r_time_period_id(l_rec_no) := r_enc_period.r_time_period_id(I);
				r_enc_period_tmp1.r_effective_date(l_rec_no) := r_enc_period.r_effective_date(I);
				r_enc_period_tmp1.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
				r_enc_period_tmp1.r_schedule_percent(l_rec_no) := r_enc_period.r_schedule_percent(I);
				r_enc_period_tmp1.r_reason_code(l_rec_no) := r_enc_period.r_reason_code(I);
				l_rec_no := l_rec_no + 1;
			END IF;
		END LOOP;
		hr_utility.trace('Dumping Assignment Chunk After Organization Default Account Processing ...');
		hr_utility.trace(LPAD('Chunk Pointer', 13, ' ') || '	' ||
			LPAD('Time Period Id', 14, ' ') || '	' || RPAD('Period Start Date', 17, ' ') || '	' ||
			RPAD('Period End Date', 15, ' ') || '	' || RPAD('Asg Start Date', 14, ' ') || '	' ||
			RPAD('Asg End Date', 12, ' ') || '	' || RPAD('Effective Date', 14, ' ') || '	' ||
			RPAD('Process Flag', 12, ' ') || '	' || LPAD('Schedule Percent', 16, ' ') || '	' ||
			RPAD('Reason Code', 50, ' '));
		hr_utility.trace(LPAD('-', 13, '-') || '	' ||
			LPAD('-', 14, '-') || '	' || RPAD('-', 17, '-') || '	' ||
			RPAD('-', 15, '-') || '	' || RPAD('-', 14, '-') || '	' ||
			RPAD('-', 12, '-') || '	' || RPAD('-', 14, '-') || '	' ||
			RPAD('-', 12, '-') || '	' || LPAD('-', 16, '-') || '	' ||
			RPAD('-', 50, '-'));

		FOR recno IN 1..r_enc_period_tmp1.r_time_period_id.COUNT
		LOOP
			hr_utility.trace(LPAD(r_enc_period_tmp1.r_period_ind(recno), 13, ' ') || '	' ||
				LPAD(r_enc_period_tmp1.r_time_period_id(recno), 14, ' ') || '	' ||
				RPAD(TO_CHAR(r_enc_period_tmp1.r_period_start_date(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
				RPAD(TO_CHAR(r_enc_period_tmp1.r_period_end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
				RPAD(TO_CHAR(r_enc_period_tmp1.r_asg_start_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
				RPAD(TO_CHAR(r_enc_period_tmp1.r_asg_end_date(recno), 'DD-MON-RRRR'), 12, ' ') || '	' ||
				RPAD(TO_CHAR(r_enc_period_tmp1.r_effective_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
				RPAD(r_enc_period_tmp1.r_process_flag(recno), 12, ' ') || '	' ||
				LPAD(r_enc_period_tmp1.r_schedule_percent(recno), 16, ' ') || '	' ||
				RPAD(r_enc_period_tmp1.r_reason_code(recno), 50, ' '));
		END LOOP;
	ELSE
		FOR I IN 1..r_enc_period.r_time_period_id.COUNT
		LOOP
			r_enc_period_tmp1.r_period_ind(I) := r_enc_period.r_period_ind(I);
			r_enc_period_tmp1.r_period_start_date(I) := r_enc_period.r_period_start_date(I);
			r_enc_period_tmp1.r_period_end_date(I) := r_enc_period.r_period_end_date(I);
			r_enc_period_tmp1.r_asg_start_date(I) := r_enc_period.r_asg_start_date(I);
			r_enc_period_tmp1.r_asg_end_date(I) := r_enc_period.r_asg_end_date(I);
			r_enc_period_tmp1.r_time_period_id(I) := r_enc_period.r_time_period_id(I);
			r_enc_period_tmp1.r_process_flag(I) := r_enc_period.r_process_flag(I);
			r_enc_period_tmp1.r_schedule_percent(I) := r_enc_period.r_schedule_percent(I);
			r_enc_period_tmp1.r_reason_code(I) := r_enc_period.r_reason_code(I);
			r_enc_period_tmp1.r_effective_date(I) := r_enc_period.r_effective_date(I);
		END LOOP;
	END IF;

	r_enc_period.r_time_period_id.DELETE;
	r_enc_period.r_period_start_date.DELETE;
	r_enc_period.r_period_end_date.DELETE;
	r_enc_period.r_asg_start_date.DELETE;
	r_enc_period.r_asg_end_date.DELETE;
	r_enc_period.r_process_flag.DELETE;
	r_enc_period.r_period_ind.DELETE;
	r_enc_period.r_schedule_percent.DELETE;
	r_enc_period.r_encumbrance_amount.DELETE;
	r_enc_period.r_period_amount.DELETE;
	r_enc_period.r_reason_code.DELETE;
	r_enc_period.r_effective_date.DELETE;

	l_rec_no := 1;
	l_proc_step := 200;

	hr_utility.trace('Organization Suspense Account Processing');

	l_sch_pointer := 1;
	FOR I IN 1..r_enc_period_tmp1.r_time_period_id.COUNT
	LOOP
		l_period_start_date := r_enc_period_tmp1.r_period_start_date(I);
		l_period_end_date := r_enc_period_tmp1.r_period_end_date(I);
		l_asg_start_date := r_enc_period_tmp1.r_asg_start_date(I);
		l_asg_end_date := r_enc_period_tmp1.r_asg_end_date(I);
		l_process_flag := r_enc_period_tmp1.r_process_flag(I);
		l_sub_slice_counter := 1;
		l_proc_step := 210 + (I / 100000);

		hr_utility.trace('I: ' || fnd_number.number_to_canonical(I) ||
			' l_period_start_date: ' || fnd_date.date_to_canonical(l_period_start_date) ||
			' l_period_end_date: ' || fnd_date.date_to_canonical(l_period_end_date) ||
			' l_asg_start_date: ' || fnd_date.date_to_canonical(l_asg_start_date) ||
			' l_asg_end_date: ' || fnd_date.date_to_canonical(l_asg_end_date) ||
			' r_enc_period_tmp1.r_time_period_id(I): ' || fnd_number.number_to_canonical(r_enc_period_tmp1.r_time_period_id(I)) ||
			' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no));

		IF (l_process_flag IN ('BAL', 'Y')) AND (l_sch_pointer <= r_sa.end_date_active.COUNT) THEN
			IF (l_asg_start_date <= g_enc_org_end_date) THEN
				FOR sa_recno IN l_sch_pointer..r_sa.start_date_active.COUNT
				LOOP
					l_start_date:= r_sa.start_date_active(sa_recno);
					l_end_date:= r_sa.end_date_active(sa_recno);
					IF (l_process_flag = 'BAL') THEN
						l_schedule_percent := r_enc_period_tmp1.r_schedule_percent(I);
					ELSE
						l_schedule_percent:= r_sa.percent(sa_recno);
					END IF;
					l_proc_step := 220 + (l_rec_no / 100000);

					hr_utility.trace('l_sub_slice_counter: ' || fnd_number.number_to_canonical(l_sub_slice_counter) ||
						' l_rec_no: ' || fnd_number.number_to_canonical(l_rec_no) ||
						' l_start_date: ' || fnd_date.date_to_canonical(l_start_date) ||
						' l_end_date: ' || fnd_date.date_to_canonical(l_end_date) ||
						' l_schedule_percent: ' || fnd_number.number_to_canonical(l_schedule_percent));

					IF (r_sa.start_date_active(sa_recno) > l_asg_end_date) THEN
						r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
						r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
						r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
						r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
						r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
						r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
						r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
						r_enc_period.r_process_flag(l_rec_no) := r_enc_period_tmp1.r_process_flag(I);
						r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
						r_enc_period.r_reason_code(l_rec_no) := l_reason_code;
						l_rec_no := l_rec_no + 1;
						EXIT;
					END IF;

					IF (l_end_date >= l_asg_start_date) AND (l_start_date <= l_asg_end_date) THEN
						IF (l_process_flag = 'BAL') THEN
							l_reason_code := 'LDM_BAL_NOT_100_PERCENT';
							add_cel_warnings(p_start_date	=>	l_asg_start_date,
								p_hierarchy_code	=>	'SA',
								p_end_date		=>	l_asg_end_date,
								p_warning_code	=>	'BAL',
								p_percent		=>	r_enc_period_tmp1.r_schedule_percent(I));
						ELSE
							l_reason_code := 'LDM_NO_CI_FOUND';
							add_cel_warnings(p_start_date	=>	l_asg_start_date,
								p_hierarchy_code	=>	'SA',
								p_end_date		=>	l_asg_end_date,
								p_warning_code	=>	'NO_CI');
						END IF;
						IF (l_asg_start_date = l_start_date AND l_asg_end_date = l_end_date) THEN
							r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
							r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
							r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
							r_enc_period.r_process_flag(l_rec_no) := 'SA';
							r_enc_period.r_schedule_percent(l_rec_no) := l_schedule_percent;
							r_enc_period.r_reason_code(l_rec_no) := l_reason_code;
							l_rec_no := l_rec_no + 1;
						ELSE
							IF (l_start_date > GREATEST(l_period_start_date, l_asg_start_date)) THEN
								l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date);
								l_new_end_date := l_start_date - 1;
								r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
								r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period.r_asg_start_date(l_rec_no) := l_new_start_date;
								r_enc_period.r_asg_end_date(l_rec_no) := l_new_end_date;
								r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
								r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
								r_enc_period.r_process_flag(l_rec_no) := l_process_flag;
								r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
								r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
								l_rec_no := l_rec_no + 1;
								l_asg_start_date := l_start_date;
							END IF;
							IF (l_end_date < LEAST(l_period_end_date, l_asg_end_date)) THEN
								l_new_start_date := GREATEST(l_period_start_date, l_asg_start_date, l_start_date);
								l_new_end_date := l_end_date;
								r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
								r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period.r_asg_start_date(l_rec_no) := l_new_start_date;
								r_enc_period.r_asg_end_date(l_rec_no) := l_new_end_date;
								r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
								r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
								r_enc_period.r_process_flag(l_rec_no) := 'SA';
								r_enc_period.r_schedule_percent(l_rec_no) := l_schedule_percent;
								r_enc_period.r_reason_code(l_rec_no) := l_reason_code;
								l_rec_no := l_rec_no + 1;
								l_asg_start_date := l_end_date + 1;
								IF (sa_recno = r_sa.start_date_active.COUNT) AND
									(l_asg_start_date <= l_asg_end_date) THEN
									r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
									r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
									r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
									r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
									r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
									r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
									r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
									r_enc_period.r_process_flag(l_rec_no) := r_enc_period.r_process_flag(I);
									r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
									r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
									l_rec_no := l_rec_no + 1;
								END IF;
							ELSE
								r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
								r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
								r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
								r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
								r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
								r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
								r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
								r_enc_period.r_process_flag(l_rec_no) := 'SA';
								r_enc_period.r_schedule_percent(l_rec_no) := l_schedule_percent;
								r_enc_period.r_reason_code(l_rec_no) := l_reason_code;
								l_rec_no := l_rec_no + 1;
								l_asg_start_date := l_end_date + 1;
							END IF;
						END IF;
						l_sub_slice_counter := 2;
					ELSE
						IF (sa_recno = r_sa.start_date_active.COUNT) THEN
							r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
							r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
							r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
							r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
							r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
							r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
							r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
							r_enc_period.r_process_flag(l_rec_no) := r_enc_period_tmp1.r_process_flag(I);
							r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
							r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
							l_rec_no := l_rec_no + 1;
						END IF;
					END IF;
					l_sch_pointer := sa_recno;
					EXIT WHEN l_asg_start_date > l_asg_end_date;
				END LOOP;
			ELSE
				r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
				r_enc_period.r_period_start_date(l_rec_no) := l_period_start_date;
				r_enc_period.r_period_end_date(l_rec_no) := l_period_end_date;
				r_enc_period.r_asg_start_date(l_rec_no) := l_asg_start_date;
				r_enc_period.r_asg_end_date(l_rec_no) := l_asg_end_date;
				r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
				r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
				r_enc_period.r_process_flag(l_rec_no) := 'I';
				r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
				r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
				l_rec_no := l_rec_no + 1;
			END IF;
		ELSE
			r_enc_period.r_period_ind(l_rec_no) := r_enc_period_tmp1.r_period_ind(I);
			r_enc_period.r_period_start_date(l_rec_no) := r_enc_period_tmp1.r_period_start_date(I);
			r_enc_period.r_period_end_date(l_rec_no) := r_enc_period_tmp1.r_period_end_date(I);
			r_enc_period.r_asg_start_date(l_rec_no) := r_enc_period_tmp1.r_asg_start_date(I);
			r_enc_period.r_asg_end_date(l_rec_no) := r_enc_period_tmp1.r_asg_end_date(I);
			r_enc_period.r_time_period_id(l_rec_no) := r_enc_period_tmp1.r_time_period_id(I);
			r_enc_period.r_effective_date(l_rec_no) := r_enc_period_tmp1.r_effective_date(I);
			r_enc_period.r_process_flag(l_rec_no) := r_enc_period_tmp1.r_process_flag(I);
			r_enc_period.r_schedule_percent(l_rec_no) := r_enc_period_tmp1.r_schedule_percent(I);
			r_enc_period.r_reason_code(l_rec_no) := r_enc_period_tmp1.r_reason_code(I);
			l_rec_no := l_rec_no + 1;
		END IF;
	END LOOP;

	r_enc_period_tmp1.r_time_period_id.DELETE;
	r_enc_period_tmp1.r_period_start_date.DELETE;
	r_enc_period_tmp1.r_period_end_date.DELETE;
	r_enc_period_tmp1.r_asg_start_date.DELETE;
	r_enc_period_tmp1.r_asg_end_date.DELETE;
	r_enc_period_tmp1.r_process_flag.DELETE;
	r_enc_period_tmp1.r_period_ind.DELETE;
	r_enc_period_tmp1.r_schedule_percent.DELETE;
	r_enc_period_tmp1.r_encumbrance_amount.DELETE;
	r_enc_period_tmp1.r_period_amount.DELETE;
	r_enc_period_tmp1.r_reason_code.DELETE;
	r_enc_period_tmp1.r_effective_date.DELETE;
	l_proc_step := 230;

	hr_utility.trace('Dumping Assignment Chunk After Suspense Account Processing ...');
	hr_utility.trace(LPAD('Chunk Pointer', 13, ' ') || '	' ||
		LPAD('Time Period Id', 14, ' ') || '	' || RPAD('Period Start Date', 17, ' ') || '	' ||
		RPAD('Period End Date', 15, ' ') || '	' || RPAD('Asg Start Date', 14, ' ') || '	' ||
		RPAD('Asg End Date', 12, ' ') || '	' || RPAD('Effective Date', 14, ' ') || '	' ||
		RPAD('Process Flag', 12, ' ') || '	' || LPAD('Schedule Percent', 16, ' ') || '	' ||
		RPAD('Reason Code', 50, ' '));
	hr_utility.trace(LPAD('-', 13, '-') || '	' ||
		LPAD('-', 14, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || RPAD('-', 14, '-') || '	' ||
		RPAD('-', 12, '-') || '	' || LPAD('-', 16, '-') || '	' ||
		RPAD('-', 50, '-'));

	FOR recno IN 1..r_enc_period.r_time_period_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_enc_period.r_period_ind(recno), 13, ' ') || '	' ||
			LPAD(r_enc_period.r_time_period_id(recno), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_period_start_date(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_period_end_date(recno), 'DD-MON-RRRR'), 15, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_asg_start_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_asg_end_date(recno), 'DD-MON-RRRR'), 12, ' ') || '	' ||
			RPAD(TO_CHAR(r_enc_period.r_effective_date(recno), 'DD-MON-RRRR'), 14, ' ') || '	' ||
			RPAD(r_enc_period.r_process_flag(recno), 12, ' ') || '	' ||
			LPAD(r_enc_period.r_schedule_percent(recno), 16, ' ') || '	' ||
			RPAD(r_enc_period.r_reason_code(recno), 50, ' '));
			r_enc_period.r_encumbrance_amount(recno) := 0;
	END LOOP;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Leaving ' || l_proc_name);

	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
WHEN OTHERS THEN
	IF (g_error_message IS NULL) THEN
		g_error_message := l_proc_name || ': ' || SQLERRM;
	END IF;
        g_error_api_path := SUBSTR(' SUB_SLICE_ASG_CHUNK:'||g_error_api_path,1,230);
        fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', ' SUB_SLICE_ASG_CHUNK');
        p_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_file.put_line(fnd_file.log, fnd_number.number_to_canonical(l_proc_step) || ': ' || l_proc_name);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ' || l_proc_name);
END sub_slice_asg_chunk;
--	End of bug fix 3462452

PROCEDURE cel_init(p_payroll_action_id IN NUMBER) IS
BEGIN
--    spc_track_cel('Init', NULL, 'Start');
NULL;
--    spc_track_cel('Init', NULL, 'End');
EXCEPTION
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', 'CEL_INIT: SQLCODE: ' || fnd_number.number_to_canonical(SQLCODE) || ' SQLERRM: ' || SQLERRM);
		psp_message_s.print_error(p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_TRUE);
END cel_init;

PROCEDURE cel_range_code	(pactid	IN		NUMBER,
			sqlstr	OUT NOCOPY	VARCHAR2) IS
l_payroll_id			NUMBER(15);
l_process_mode			VARCHAR2(15);
l_process_code			VARCHAR2(15);
l_return_status			VARCHAR2(1);
l_last_update_date		DATE;
l_last_updated_by		NUMBER;
l_last_updated_login		NUMBER;
l_request_id			NUMBER;
l_business_group_id		NUMBER(15);
l_set_of_books_id		NUMBER(15);
NO_UPDATE_REC_FOUND		EXCEPTION;

CURSOR	action_parameters_cur IS
SELECT	fnd_number.canonical_to_number(NVL(argument11, -1)),
	argument12
FROM	fnd_concurrent_requests
WHERE	request_id = l_request_id;

CURSOR	enc_payrolls_cur IS
SELECT	pep.payroll_id
FROM	psp_enc_payrolls pep
WHERE	pep.business_group_id = l_business_group_id
AND		pep.set_of_books_id   = l_set_of_books_id;
BEGIN
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Entering CEL_RANGE_CODE pactid: ' || pactid);

	l_last_update_date := SYSDATE;
	l_last_updated_by := NVL(FND_GLOBAL.USER_ID, -1);
	l_last_updated_login := NVL(FND_GLOBAL.LOGIN_ID, -1);
	l_request_id := fnd_global.conc_request_id;
	l_set_of_books_id :=  FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
	l_business_group_id  := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');

	OPEN action_parameters_cur;
	FETCH action_parameters_cur INTO l_payroll_id, l_process_mode;
	CLOSE action_parameters_cur;

	IF (l_payroll_id = -1) THEN
		l_payroll_id := NULL;
	END IF;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	l_payroll_id: ' || l_payroll_id || '
	process_mode: ' || l_process_mode);

	l_process_code := 'CEL';
	IF (l_process_mode = 'TERMINATE') THEN
		l_process_code := 'LET';
	END IF;

	INSERT INTO psp_enc_processes
		(request_id,		process_code,		payroll_action_id,
		process_status,		process_phase,		business_group_id,
		set_of_books_id,	creation_date,		created_by,
		last_update_date,	last_updated_by,	last_update_login)
	VALUES
		(l_request_id,		l_process_code,		pactid,
		'I',			NULL,			l_business_group_id,
		l_set_of_books_id,	l_last_update_date,	l_last_updated_by,
		l_last_update_date,	l_last_updated_by,	l_last_updated_login);

	IF ((l_payroll_id IS NOT NULL) OR (l_process_mode = 'TERMINATE')) THEN
		enc_pre_process(pactid, l_payroll_id, l_process_mode, l_return_status);

		IF l_return_status <> fnd_api.g_ret_sts_success  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Completed enc_pre_process for l_payroll_id: ' || l_payroll_id || ' process_mode: ' || l_process_mode);
	ELSE
		OPEN enc_payrolls_cur;
		LOOP
			FETCH enc_payrolls_cur INTO l_payroll_id;
			EXIT WHEN enc_payrolls_cur%NOTFOUND;

			enc_pre_process(pactid, l_payroll_id, l_process_mode, l_return_status);
			IF l_return_status <> fnd_api.g_ret_sts_success  THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Completed enc_pre_process for l_payroll_id: ' || l_payroll_id || ' process_mode: ' || l_process_mode);
		END LOOP;
		CLOSE enc_payrolls_cur;
		l_payroll_id := NULL;
	END IF;

	sqlstr := 'SELECT DISTINCT assignment_id FROM psp_enc_changed_assignments WHERE ';
	IF (l_payroll_id IS NOT NULL) THEN
		sqlstr := sqlstr || 'payroll_id = ' || fnd_number.number_to_canonical(l_payroll_id) || ' AND ';
	END IF;

	sqlstr := sqlstr || 'payroll_action_id = :payroll_action_id ORDER BY assignment_id';

	INSERT INTO psp_enc_process_assignments
		(payroll_action_id,		assignment_id,		payroll_id,
		assignment_status,		creation_date,		created_by,
		last_update_date,		last_updated_by,	last_update_login)
	SELECT	DISTINCT pactid,		assignment_id,		payroll_id,
		'I',				l_last_update_date,	l_last_updated_by,
		l_last_update_date,		l_last_updated_by,	l_last_updated_login
	FROM	psp_enc_changed_assignments
	WHERE	payroll_action_id = pactid;

	IF (SQL%ROWCOUNT = 0) THEN
		fnd_message.set_name('PSP', 'PSP_ENC_NO_LIN_UPD');
		g_warning_message := fnd_message.get;
		fnd_file.put_line(fnd_file.log, g_warning_message);
		psp_general.add_report_error
			(p_request_id		=>	l_request_id,
			p_message_level		=>	'N',
			p_source_id		=>	NULL,
			p_source_name		=>	NULL,
			p_error_message		=>	g_warning_message,
			p_payroll_action_id	=>	pactid,
			p_return_status		=>	l_return_status);
		RAISE NO_UPDATE_REC_FOUND;
	END IF;

	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	sqlstr: ' || sqlstr);
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Leaving CEL_RANGE_CODE pactid: ' || pactid);
EXCEPTION
	WHEN NO_UPDATE_REC_FOUND THEN
		psp_message_s.print_error (p_mode => FND_FILE.LOG, p_print_header => FND_API.G_FALSE);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CEL_RANGE_CODE pactid: ' || pactid);
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', 'CEL_RANGE_CODE: SQLCODE: ' || fnd_number.number_to_canonical(SQLCODE) || ' SQLERRM: ' || SQLERRM);
		psp_message_s.print_error(p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_TRUE);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CEL_RANGE_CODE pactid: ' || pactid);
END cel_range_code;

PROCEDURE cel_asg_action_code	(p_pactid	IN	NUMBER,
				start_asg	IN	NUMBER,
				end_asg		IN	NUMBER,
				p_chunk_num	IN	NUMBER) IS
CURSOR	get_assignments_cur IS
SELECT  DISTINCT assignment_id
FROM	psp_enc_changed_assignments
WHERE	assignment_id BETWEEN start_asg AND end_asg
AND	payroll_action_id = p_pactid;

TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
t_asg_array		t_number_15;
l_asg_action_id	NUMBER(15);
BEGIN
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Entering CEL_ASG_ACTION_CODE p_pactid: ' || p_pactid || '
	start_asg: ' || start_asg || '
	end_asg: ' || end_asg || '
	p_chunk_num: ' || p_chunk_num);

	OPEN get_assignments_cur;
	FETCH get_assignments_cur BULK COLLECT INTO t_asg_array;
	CLOSE get_assignments_cur;

	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	t_asg_array.COUNT: ' || t_asg_array.COUNT);
	FOR recno IN 1..t_asg_array.COUNT
	LOOP
		SELECT pay_assignment_actions_s.NEXTVAL INTO l_asg_action_id FROM DUAL;
		hr_nonrun_asact.insact(l_asg_action_id,
					pactid =>       p_pactid,
					chunk =>        p_chunk_num,
					object_id =>    t_asg_array(recno),
					object_type =>      'ASG',
					p_transient_action =>      TRUE);
	END LOOP;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Leaving CEL_ASG_ACTION_CODE payroll_action_id: ' || p_pactid || '
	start_asg: ' || start_asg || '
	end_asg: ' || end_asg || '
	p_chunk_num: ' || p_chunk_num);
END cel_asg_action_code;

PROCEDURE cel_archive	(p_payroll_action_id	IN	NUMBER,
			p_chunk_number		IN	NUMBER) IS
l_business_group_id		NUMBER(15);
l_set_of_books_id		NUMBER(15);
l_assignment_id			NUMBER(15);
l_payroll_id			NUMBER(15);
l_person_id			NUMBER(15);
l_organization_id		NUMBER(15);
l_assignment_number		per_all_assignments_f.assignment_number%TYPE;
l_payroll_name			pay_all_payrolls_f.payroll_name%TYPE;
l_full_name			per_all_people_f.full_name%TYPE;
l_organization_name		hr_organization_units.name%TYPE;
l_process_mode			VARCHAR2(15);
l_enc_begin_date		DATE;
l_min_asg_id			NUMBER(15);
l_max_asg_id			NUMBER(15);
l_enc_period_end_date		DATE;
l_enc_period_date		DATE;
l_element_type_id		NUMBER;
l_element_name			pay_element_types_f.element_name%TYPE;
l_return_status			VARCHAR2(1);
l_enc_org_end_date		DATE;
l_max_enc_date			DATE;
l_enc_create			NUMBER;
l_new_cust			NUMBER;
l_pre_process_mode		VARCHAR2(1);
l_profile_value			BOOLEAN;
l_max_enc_lines_date		DATE;
l_enc_create_lines		NUMBER;
l_max_enc_hist_date		DATE;
l_enclines_check		BOOLEAN;
l_enclines_index		NUMBER;
l_liq_only_count		NUMBER(15);
l_liq_all_count			NUMBER(15);
l_money_value			NUMBER(15);
l_hours_value			NUMBER(15);

CURSOR	payroll_id_cur IS
SELECT	fnd_number.canonical_to_number(NVL(argument11, -1)),
	argument12
FROM	fnd_concurrent_requests fcr,
	psp_enc_processes pep
WHERE	pep.payroll_action_id = p_payroll_action_id
AND	fcr.request_id = pep.request_id;

CURSOR	get_asg_id_cur IS
SELECT	MIN(object_id),
	MAX(object_id)
FROM	pay_temp_object_actions
WHERE	payroll_action_id = p_payroll_action_id
AND		chunk_number = p_chunk_number;

CURSOR	get_payroll_asg_cur IS
SELECT	DISTINCT payroll_id,
	assignment_id,
	change_date
FROM	psp_enc_changed_assignments peca
WHERE	assignment_id BETWEEN l_min_asg_id AND l_max_asg_id
AND	(	(l_process_mode = 'TERMINATE' AND change_type = 'TR')
	OR	(l_process_mode = 'REGULAR' AND change_type <> 'TR'))
AND	payroll_id = NVL(l_payroll_id, payroll_id)
/*AND	NOT EXISTS	(SELECT	1
			FROM	psp_enc_process_assignments pepa
			WHERE	pepa.assignment_id = peca.assignment_id
			AND	pepa.payroll_action_id = p_payroll_action_id
			AND	pepa.assignment_status <> 'B')*/;

CURSOR	earnings_element_cur(p_Assignment_ID NUMBER) IS
SELECT	DISTINCT
	pet.element_type_id,
	pc.costing_debit_or_credit
FROM 	PAY_ELEMENT_ENTRIES_F pee,
	PAY_ELEMENT_LINKS_F pel,
	PAY_ELEMENT_TYPES_F pet,
	PER_ASSIGNMENTS_F pa,
        PAY_ELEMENT_CLASSIFICATIONS pc
WHERE	pee.assignment_id 	= p_assignment_id
AND	pa.assignment_id 	= p_assignment_id
AND	pee.effective_end_date >= pa.effective_start_date
AND	pee.effective_start_date <= pa.effective_end_date
AND	pee.element_link_id = pel.element_link_id
AND	pel.effective_end_date >= pa.effective_start_date
AND	pel.effective_start_date <= pa.effective_end_date
AND	pee.entry_type = 'E'
AND	pel.element_type_id = pet.element_type_id
AND	pet.effective_end_date >= pa.effective_start_date
AND	pet.effective_start_date <=pa.effective_end_date
AND	pel.business_group_id = l_business_group_id
AND	pet.element_type_id IN ( SELECT element_type_id
				 FROM   psp_enc_elements
				 WHERE  business_group_id = l_business_group_id
			 	 AND    set_of_books_id = l_set_of_books_id)
AND	pet.classification_id = pc.classification_id
ORDER BY pet.element_type_id;

CURSOR	c_max_enc_date (p_assignment_id		NUMBER,
			p_element_type_id 	NUMBER,
			p_enc_begin_date  	DATE) IS
SELECT	COUNT(1),
	NVL(MAX(pelh.encumbrance_date),p_enc_begin_date)
FROM	psp_enc_lines_history pelh
WHERE	pelh.assignment_id		= l_assignment_id
AND	pelh.enc_element_type_id	= p_element_type_id
AND	pelh.payroll_id			= l_payroll_id;

/* Bug 5642002: Replaced earned date with period end date */
CURSOR	c_last_pay_run (p_assignment_id NUMBER)IS
SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
FROM	pay_payroll_actions ppa,
        pay_assignment_actions paa,
        per_time_periods ptp
WHERE 	ppa.payroll_action_id = paa.payroll_action_id (+)
AND     ppa.business_group_id 	= l_business_group_id
AND	ppa.payroll_id	= l_payroll_id
AND     NVL(paa.assignment_id, p_assignment_id) = p_assignment_id
AND   	ppa.action_type	IN ( 'R','Q')
AND	NVL(paa.action_status, ppa.action_status) = 'C'
and     ppa.date_earned between ptp.start_date and ptp.end_date
and     ptp.payroll_id = ppa.payroll_id;

CURSOR	c_tp_start_date IS
SELECT	MIN(ptp.start_date)
FROM	per_time_periods ptp
WHERE	ptp.payroll_id	= l_payroll_id;

CURSOR 	c_obtain_eff_date_option IS
SELECT  NVL(parameter_value,1)
FROM  psp_enc_setup_options peso
WHERE peso.setup_parameter 	='EFFECTIVE_DATE'
AND   peso.business_group_id  = l_business_group_id
AND   peso.set_of_books_id 	= l_set_of_books_id;

CURSOR	c_max_enc_lines_date	(p_assignment_id		NUMBER,
			    	  p_element_type_id 		NUMBER,
					  p_enc_begin_date  		DATE) IS
SELECT	COUNT(1), NVL(MAX(pel.encumbrance_date),p_enc_begin_date)
FROM	psp_enc_lines pel
WHERE	pel.enc_element_type_id	= p_element_type_id
AND		pel.assignment_id		= p_assignment_id
AND		pel.payroll_id			= l_payroll_id;

CURSOR	cel_request_id_cur IS
SELECT	request_id
FROM	pay_payroll_actions
WHERE	payroll_action_id = p_payroll_action_id;

CURSOR	asg_number_cur (p_effective_date IN DATE) IS
SELECT	assignment_number,
	person_id,
	organization_id
FROM	per_all_assignments_f
WHERE	assignment_id = l_assignment_id
AND	payroll_id = l_payroll_id
AND	effective_end_date >= p_effective_date
AND	ROWNUM = 1;

CURSOR	payroll_name_cur IS
SELECT	payroll_name
FROM	pay_all_payrolls_f
WHERE	payroll_id = l_payroll_id
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

CURSOR	element_name_cur IS
SELECT	element_name
FROM	pay_element_types_f
WHERE	element_type_id = l_element_type_id
AND	ROWNUM = 1;

CURSOR	emphours_config_cur IS
SELECT	pcv_information2 employee_hours
FROM	pqp_configuration_values
WHERE	pcv_information_category = 'PSP_IMPORT_EMPLOYEE_HOURS'
AND	legislation_code IS NULL
AND	NVL(business_group_id, l_business_group_id) = l_business_group_id;

CURSOR	autopop_config_cur IS
SELECT	pcv_information1 global_element_autopop,
	pcv_information2 element_type_autopop,
	pcv_information3 element_class_autopop,
	pcv_information4 assignment_autopop,
	pcv_information5 default_schedule_autopop,
	pcv_information6 default_account_autopop,
	pcv_information7 suspense_account
FROM	pqp_configuration_values
WHERE	pcv_information_category = 'PSP_ENABLE_AUTOPOPULATION'
AND	legislation_code IS NULL
AND	NVL(business_group_id, l_business_group_id) = l_business_group_id
ORDER BY business_group_id;

CURSOR	liq_only_asg_cur IS
SELECT	COUNT(1)
FROM	psp_enc_changed_assignments
WHERE	assignment_id = l_assignment_id
AND	payroll_id = l_payroll_id
AND	payroll_action_id = p_payroll_action_id
AND	change_type  <> 'LQ';

CURSOR	liq_all_cur IS
SELECT	COUNT(1)
FROM	psp_enc_changed_assignments
WHERE	assignment_id = l_assignment_id
AND	payroll_id = l_payroll_id
AND	payroll_action_id = p_payroll_action_id
AND	change_type  = 'ZZ';

CURSOR	money_value_cur (p_element_type_id IN NUMBER) IS
SELECT	COUNT(1)
FROM	psp_enc_elements pee
WHERE	element_type_id = p_element_type_id
AND	(	formula_id IS NOT NULL
	OR	EXISTS	(SELECT	1
			FROM	pay_input_values_f piv
			WHERE	piv.input_value_id = pee.input_value_id
			AND	SUBSTR(piv.uom, 1, 1) <> 'H'));

CURSOR	hours_value_cur (p_element_type_id IN NUMBER) IS
SELECT	COUNT(1)
FROM	psp_enc_elements pee
WHERE	element_type_id = p_element_type_id
AND	(	formula_id IS NOT NULL
	OR	EXISTS	(SELECT	1
			FROM	pay_input_values_f piv
			WHERE	piv.input_value_id = pee.input_value_id
			AND	SUBSTR(piv.uom, 1, 1) = 'H'));


TYPE payid_tab IS TABLE OF per_all_assignments_f.payroll_id%TYPE INDEX BY BINARY_INTEGER;
TYPE asgid_tab IS TABLE OF per_all_assignments_f.assignment_id%TYPE INDEX BY BINARY_INTEGER;
TYPE term_date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE t_asg_id_rec IS RECORD
	(payroll_array		payid_tab,
	asg_array		asgid_tab,
	term_date_array		term_date_tab);
t_assignments t_asg_id_rec;

TYPE enclinesasg_tab IS TABLE OF psp_enc_lines.assignment_id%TYPE INDEX BY BINARY_INTEGER;
TYPE enclinesele_tab IS TABLE OF psp_enc_lines.enc_element_type_id%TYPE INDEX BY BINARY_INTEGER;
TYPE enclinesdat_tab IS TABLE OF psp_enc_lines.encumbrance_date%TYPE INDEX BY BINARY_INTEGER;
TYPE t_enclines_rec IS RECORD
	(asg_array	enclinesasg_tab,
	ele_array	enclinesele_tab,
	dat_array	enclinesdat_tab);
t_enclines	t_enclines_rec;

PROCEDURE log_cel_warnings IS
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

l_project_number		pa_projects_all.segment1%TYPE;
l_task_number			pa_tasks.task_number%TYPE;
l_award_number			gms_awards_all.award_number%TYPE;
l_exp_org_name			hr_organization_units.name%TYPE;
l_gl_description		VARCHAR2(1000);
BEGIN
	FOR recno IN 1..cel_warnings.start_date.COUNT
	LOOP
		OPEN asg_number_cur(cel_warnings.start_date(recno));
		FETCH asg_number_cur INTO l_assignment_number, l_person_id, l_organization_id;
		CLOSE asg_number_cur;

		OPEN payroll_name_cur;
		FETCH payroll_name_cur INTO l_payroll_name;
		CLOSE payroll_name_cur;

		OPEN person_name_cur(cel_warnings.start_date(recno));
		FETCH person_name_cur INTO l_full_name;
		CLOSE person_name_cur;

		OPEN org_name_cur;
		FETCH org_name_cur INTO l_organization_name;
		CLOSE org_name_cur;

		OPEN element_name_cur;
		FETCH element_name_cur INTO l_element_name;
		CLOSE element_name_cur;

		IF (cel_warnings.warning_code(recno) = 'BAL') THEN
			fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_BALNOT100');
			fnd_message.set_token('START_DATE', cel_warnings.start_date(recno));
			fnd_message.set_token('END_DATE', cel_warnings.end_date(recno));
			fnd_message.set_token('PERCENT', cel_warnings.percent(recno));
			g_warning_message := fnd_message.get;
		ELSIF (cel_warnings.warning_code(recno) = 'GL') THEN
			fnd_message.set_name('PSP', 'PSP_CANNOT_ENC_HOURS_TO_GL');
			fnd_message.set_token('START_DATE', cel_warnings.start_date(recno));
			fnd_message.set_token('END_DATE', cel_warnings.end_date(recno));
			fnd_message.set_token('HOURS', cel_warnings.percent(recno));
			g_warning_message := fnd_message.get;
		ELSIF (cel_warnings.warning_code(recno) = 'AUTOPOP') AND
			(cel_warnings.gl_ccid(recno) IS NOT NULL) THEN
			l_gl_description := psp_general.get_gl_values(g_set_of_books_id, cel_warnings.gl_ccid(recno));
			fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_AUTOPOP');
			fnd_message.set_token('START_DATE', cel_warnings.start_date(recno));
			fnd_message.set_token('END_DATE', cel_warnings.end_date(recno));
			fnd_message.set_token('GL', l_gl_description);
			fnd_message.set_token('AUTOPOP_STATUS', cel_warnings.error_status(recno));
			g_warning_message := fnd_message.get;
		ELSIF (cel_warnings.warning_code(recno) = 'AUTOPOP') AND (cel_warnings.gl_ccid(recno) IS NULL) THEN
			OPEN project_number_cur(cel_warnings.project_id(recno));
			FETCH project_number_cur INTO l_project_number;
			CLOSE project_number_cur;

			OPEN award_number_cur(cel_warnings.award_id(recno));
			FETCH award_number_cur INTO l_award_number;
			CLOSE award_number_cur;

			OPEN task_number_cur(cel_warnings.task_id(recno));
			FETCH task_number_cur INTO l_task_number;
			CLOSE task_number_cur;

			OPEN exp_org_name_cur(cel_warnings.exp_org_id(recno));
			FETCH exp_org_name_cur INTO l_exp_org_name;
			CLOSE exp_org_name_cur;

			fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_AP_PATEO');
			fnd_message.set_token('START_DATE', cel_warnings.start_date(recno));
			fnd_message.set_token('END_DATE', cel_warnings.end_date(recno));
			fnd_message.set_token('PJ', l_project_number);
			fnd_message.set_token('TK', l_task_number);
			fnd_message.set_token('AW', l_award_number);
			fnd_message.set_token('EO', l_exp_org_name);
			fnd_message.set_token('ET', cel_warnings.exp_type(recno));
			fnd_message.set_token('AUTOPOP_STATUS', cel_warnings.error_status(recno));
			g_warning_message := fnd_message.get;
		ELSIF (cel_warnings.warning_code(recno) = 'NO_CI') THEN
			fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_NOCI');
			fnd_message.set_token('START_DATE', cel_warnings.start_date(recno));
			fnd_message.set_token('END_DATE', cel_warnings.end_date(recno));
			g_warning_message := fnd_message.get;
		ELSIF (cel_warnings.warning_code(recno) = 'INVALID_CI') THEN
			OPEN project_number_cur(cel_warnings.project_id(recno));
			FETCH project_number_cur INTO l_project_number;
			CLOSE project_number_cur;

			OPEN award_number_cur(cel_warnings.award_id(recno));
			FETCH award_number_cur INTO l_award_number;
			CLOSE award_number_cur;

			OPEN task_number_cur(cel_warnings.task_id(recno));
			FETCH task_number_cur INTO l_task_number;
			CLOSE task_number_cur;

			OPEN exp_org_name_cur(cel_warnings.exp_org_id(recno));
			FETCH exp_org_name_cur INTO l_exp_org_name;
			CLOSE exp_org_name_cur;

			IF (cel_warnings.error_status(recno) IS NOT NULL) THEN
				fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_INV_PATEO');
				fnd_message.set_token('PJ', l_project_number);
				fnd_message.set_token('TK', l_task_number);
				fnd_message.set_token('AW', l_award_number);
				fnd_message.set_token('EO', l_exp_org_name);
				fnd_message.set_token('ET', cel_warnings.exp_type(recno));
				fnd_message.set_token('START_DATE', cel_warnings.start_date(recno));
				fnd_message.set_token('END_DATE', cel_warnings.end_date(recno));
				fnd_message.set_token('ERROR_STATUS', cel_warnings.error_status(recno));
			ELSE
				fnd_message.set_name('PSP', 'PSP_SUSPENSE_REASON_END_PATEO');
				fnd_message.set_token('PJ', l_project_number);
				fnd_message.set_token('TK', l_task_number);
				fnd_message.set_token('AW', l_award_number);
				fnd_message.set_token('EO', l_exp_org_name);
				fnd_message.set_token('ET', cel_warnings.exp_type(recno));
				fnd_message.set_token('START_DATE', cel_warnings.start_date(recno));
				fnd_message.set_token('END_DATE', cel_warnings.end_date(recno));
				fnd_message.set_token('EFFECTIVE_DATE', cel_warnings.effective_date(recno));
			END IF;
			g_warning_message := fnd_message.get;
		END IF;

		psp_general.add_report_error
			(p_request_id		=>	g_request_id,
			p_message_level		=>	'W',
			p_source_id		=>	l_assignment_id,
			p_source_name		=>	l_assignment_number,
			p_parent_source_id	=>	l_person_id,
			p_parent_source_name	=>	l_full_name,
			p_error_message		=>	g_warning_message,
			p_payroll_action_id	=>	p_payroll_action_id,
			p_value1		=>	l_payroll_id,
			p_information1		=>	l_payroll_name,
			p_value2		=>	l_organization_id,
			p_value3		=>	l_element_type_id,
			p_information2		=>	l_organization_name,
			p_information3		=>	l_element_name,
			p_information4		=>	fnd_date.date_to_canonical(cel_warnings.start_date(recno)),
			p_information5		=>	fnd_date.date_to_canonical(cel_warnings.end_date(recno)),
			p_information6		=>	cel_warnings.hierarchy_code(recno),
			p_information7		=>	cel_warnings.error_status(recno),
			p_return_status		=>	l_return_status);
	END LOOP;
	cel_warnings.start_date.DELETE;
	cel_warnings.end_date.DELETE;
	cel_warnings.warning_code.DELETE;
	cel_warnings.project_id.DELETE;
	cel_warnings.task_id.DELETE;
	cel_warnings.award_id.DELETE;
	cel_warnings.exp_org_id.DELETE;
	cel_warnings.exp_type.DELETE;
	cel_warnings.effective_date.DELETE;
	cel_warnings.error_status.DELETE;
	cel_warnings.percent.DELETE;
END log_cel_warnings;
BEGIN
	SAVEPOINT CEL_ARCHIVE;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering CEL_ARCHIVE (payroll_action_id: ' || p_payroll_action_id || ' chunk_number: ' || p_chunk_number ||')');

	l_set_of_books_id :=  FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
	l_business_group_id  := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
	g_set_of_books_id :=  l_set_of_books_id;
	g_business_group_id  := l_business_group_id;
	g_enc_line_type := 'U';
	g_package_name := 'PSP_ENC_CREATE_LINES.';
	g_payroll_action_id := p_payroll_action_id;
	g_dff_grouping_option := psp_general.get_enc_dff_grouping_option(l_business_group_id);

	OPEN cel_request_id_cur;
	FETCH cel_request_id_cur INTO g_request_id;
	CLOSE cel_request_id_cur;

	OPEN emphours_config_cur;
	FETCH emphours_config_cur INTO g_employee_hours;
	IF (emphours_config_cur%ROWCOUNT = 0) THEN
		g_employee_hours := 'N';
	END IF;
	CLOSE emphours_config_cur;

	OPEN autopop_config_cur;
	FETCH autopop_config_cur INTO g_ge_autopop, g_et_autopop, g_eg_autopop, g_as_autopop, g_ds_autopop, g_da_autopop, g_sa_autopop;
	IF (autopop_config_cur%ROWCOUNT = 0) THEN
		g_ge_autopop := 'N';
		g_et_autopop := 'N';
		g_eg_autopop := 'N';
		g_as_autopop := 'N';
		g_ds_autopop := 'N';
		g_da_autopop := 'N';
		g_sa_autopop := 'N';
	END IF;
	CLOSE autopop_config_cur;

	OPEN  c_obtain_eff_date_option;
	FETCH c_obtain_eff_date_option  INTO  g_Eff_Date_Value;
	CLOSE c_obtain_eff_date_option;

	OPEN payroll_id_cur;
	FETCH payroll_id_cur INTO l_payroll_id, l_process_mode;
	CLOSE payroll_id_cur;
	IF (l_payroll_id = -1) THEN
		l_payroll_id := NULL;
	END IF;

	l_enc_create_lines := 1;
	l_enclines_index := 1;
	l_enc_create := 1;
	l_pre_process_mode:= 'R';
	g_currency_code := psp_general.get_currency_code(l_business_group_id);
	psp_general.get_currency_precision(g_currency_code,g_precision,g_ext_precision);
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	g_enc_line_type: U
		g_request_id: ' || g_request_id || '
		g_payroll_action_id: ' || g_payroll_action_id || '
		g_currency_code: ' || g_currency_code || '
		g_ge_autopop: ' || g_ge_autopop || ' g_et_autopop: ' || g_et_autopop ||
		' g_eg_autopop: ' || g_eg_autopop || ' g_as_autopop: ' || g_as_autopop ||
		' g_ds_autopop: ' || g_ds_autopop || ' g_da_autopop: ' || g_da_autopop ||
		' g_sa_autopop: ' || g_sa_autopop);

	OPEN  c_obtain_eff_date_option;
	FETCH c_obtain_eff_date_option  INTO  g_eff_date_value;
	CLOSE c_obtain_eff_date_option;

	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	g_eff_date_value: ' || g_eff_date_value);

	obtain_enc_org_end_date(p_enc_org_end_date	=>	l_enc_org_end_date,
				p_business_group_id	=>	l_business_group_id,
				p_set_of_books_id	=>	l_set_of_books_id,
				p_return_status		=>	l_return_status);
	IF l_return_status <> fnd_api.g_ret_sts_success	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	g_enc_org_end_date := l_enc_org_end_date ;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	g_enc_org_end_date: ' || fnd_date.date_to_canonical(g_enc_org_end_date));

	OPEN get_asg_id_cur;
	FETCH get_asg_id_cur INTO l_min_asg_id, l_max_asg_id;
	CLOSE get_asg_id_cur;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	l_min_asg_id: ' || l_min_asg_id || ' l_max_asg_id: ' || l_max_asg_id);

	OPEN get_payroll_asg_cur;
	FETCH get_payroll_asg_cur BULK COLLECT INTO t_assignments.payroll_array, t_assignments.asg_array, t_assignments.term_date_array;
	CLOSE get_payroll_asg_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	t_assignments.asg_array.COUNT: ' || t_assignments.asg_array.COUNT);
	FOR recno IN 1 ..t_assignments.asg_array.COUNT
	LOOP
		l_assignment_id := t_assignments.asg_array(recno);
		l_payroll_id := t_assignments.payroll_array(recno);
		g_enc_lines_counter := 1;
		g_actual_term_date := t_assignments.term_date_array(recno);
--		l_enc_begin_date := NULL;

		OPEN liq_only_asg_cur;
		FETCH liq_only_asg_cur INTO l_liq_only_count;
		CLOSE liq_only_asg_cur;

		OPEN liq_all_cur;
		FETCH liq_all_cur INTO l_liq_all_count;
		CLOSE liq_all_cur;

		IF ((l_liq_all_count =0) AND (l_liq_only_count > 0)) THEN
			delete_previous_error_log(p_assignment_id	=>	l_assignment_id,
					p_payroll_id		=>	l_payroll_id,
					p_payroll_action_id	=>	p_payroll_action_id);

/* commented for bug 5581265: Need to consider date earn at each assignment level instead of payroll */
--			IF ((recno = 1) OR (l_payroll_id <> t_assignments.payroll_array(recno-1))) THEN
				l_enc_begin_date := NULL;

				OPEN c_last_pay_run(t_assignments.asg_array(recno));
				FETCH c_last_pay_run INTO l_enc_begin_date;
				CLOSE c_last_pay_run;

				IF l_enc_begin_date IS NULL THEN
					OPEN c_tp_start_date;
					FETCH c_tp_start_date INTO l_enc_begin_date;
					CLOSE c_tp_start_date;
				END IF;
--			END IF;

			OPEN earnings_element_cur(l_assignment_id);
			LOOP
				FETCH earnings_element_cur INTO l_element_type_id, g_dr_cr_flag;
				EXIT WHEN earnings_element_cur%NOTFOUND ;

				OPEN money_value_cur(l_element_type_id);
				FETCH money_value_cur INTO l_money_value;
				CLOSE money_value_cur;

				IF (l_money_value > 0) THEN
				g_uom := 'M';

				OPEN  c_max_enc_date(l_assignment_id, l_element_type_id, l_enc_begin_date);
				FETCH c_max_enc_date INTO l_enc_create, l_max_enc_hist_date;
				CLOSE c_max_enc_date;

				OPEN  c_max_enc_lines_date(l_assignment_id, l_element_type_id, l_enc_begin_date);
				FETCH c_max_enc_lines_date INTO l_enc_create_lines, l_max_enc_lines_date;
				CLOSE c_max_enc_lines_date;

				l_max_enc_date :=  GREATEST(l_max_enc_lines_date, l_max_enc_hist_date);

				IF l_enc_create = 0 AND l_enc_create_lines = 0 THEN
					l_enc_create :=1;
				END IF;
				hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	g_actual_term_date: ' || fnd_date.date_to_canonical(g_actual_term_date) || '
	l_max_enc_date: ' || fnd_date.date_to_canonical(l_max_enc_date) || '
	l_enc_create: ' || l_enc_create);

		  		IF  l_enc_create > 0  THEN
					hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	p_chunk_number: ' || p_chunk_number || '
	p_assignment_id		=>	' || l_assignment_id || '
	p_payroll_id		=>	' || l_payroll_id || '
	p_element_type_id		=>	' || l_element_type_id || '
	p_business_group_id	=>	' || l_business_group_id || '
	p_set_of_books_id		=>	' || l_set_of_books_id || '
	p_last_paid_date		=>	' || l_enc_begin_date || '
	p_max_enc_date		=>	' || l_max_enc_date);
					create_lines( p_assignment_id		=>	l_assignment_id,
						p_payroll_id		=>	l_payroll_id,
						p_element_type_id	=>	l_element_type_id,
--						p_business_group_id	=>	l_business_group_id,
--						p_set_of_books_id	=>	l_set_of_books_id,
		  				p_last_paid_date	=>	l_enc_begin_date,
--			  			p_max_enc_date		=>	l_max_enc_date,
						p_return_status		=>	l_return_status);
					IF l_return_status <> fnd_api.g_ret_sts_success	THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;
					fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed create_lines for l_assignment_id: ' || l_assignment_id || ' payroll_id: ' || l_payroll_id || ' element_type_id: ' || l_element_type_id);
					log_cel_warnings;
				END IF;
			   END IF;
                        IF (g_employee_hours = 'Y') THEN
					OPEN hours_value_cur(l_element_type_id);
					FETCH hours_value_cur INTO l_hours_value;
					CLOSE hours_value_cur;

					IF (l_hours_value > 0) THEN
						g_uom := 'H';
						psp_general.get_currency_precision('STAT',g_precision,g_ext_precision);
						OPEN c_max_enc_date(l_assignment_id, l_element_type_id, l_enc_begin_date);
						FETCH c_max_enc_date INTO l_enc_create, l_max_enc_hist_date;
						CLOSE c_max_enc_date;

						OPEN c_max_enc_lines_date(l_assignment_id, l_element_type_id, l_enc_begin_date);
						FETCH c_max_enc_lines_date INTO l_enc_create_lines, l_max_enc_lines_date;
						CLOSE c_max_enc_lines_date;

						l_max_enc_date := GREATEST(l_max_enc_lines_date, l_max_enc_hist_date);

						IF l_enc_create = 0 AND l_enc_create_lines = 0 THEN
							l_enc_create :=1;
						END IF;
						hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	g_actual_term_date: ' || fnd_date.date_to_canonical(g_actual_term_date) || '
		l_max_enc_date: ' || fnd_date.date_to_canonical(l_max_enc_date) || '
		l_enc_create: ' || l_enc_create);

						IF l_enc_create > 0 THEN
							hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	p_chunk_number: ' || p_chunk_number || '
		p_assignment_id		=>	' || l_assignment_id || '
		p_payroll_id		=>	' || l_payroll_id || '
		p_element_type_id		=>	' || l_element_type_id || '
		p_business_group_id	=>	' || l_business_group_id || '
		p_set_of_books_id		=>	' || l_set_of_books_id || '
		p_last_paid_date		=>	' || l_enc_begin_date || '
		p_max_enc_date		=>	' || l_max_enc_date);
							create_lines( p_assignment_id		=>	l_assignment_id,
								p_payroll_id		=>	l_payroll_id,
								p_element_type_id	=>	l_element_type_id,
	--						p_business_group_id	=>	l_business_group_id,
	--						p_set_of_books_id	=>	l_set_of_books_id,
							p_last_paid_date	=>	l_enc_begin_date,
	--						p_max_enc_date		=>	l_max_enc_date,
								p_return_status		=>	l_return_status);
							IF l_return_status <> fnd_api.g_ret_sts_success	THEN
								RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
							END IF;
							fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed create_lines for l_assignment_id: ' || l_assignment_id || ' payroll_id: ' || l_payroll_id || ' element_type_id: ' || l_element_type_id);
							log_cel_warnings;
						END IF;
					END IF;
				END IF;

	       		END LOOP;

			IF (earnings_element_cur%ROWCOUNT = 0) THEN
				fnd_file.put_line(fnd_file.log, 'No element found for encumbrance.');
			END IF;
			CLOSE earnings_element_cur;

			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	t_enc_lines_array.r_enc_element_type_id.COUNT: ' || t_enc_lines_array.r_enc_element_type_id.COUNT);
			verify_changes(p_payroll_id		=> l_payroll_id,
				p_assignment_id		=> l_assignment_id,
				p_business_group_id	=> l_business_group_id,
				p_set_of_books_id	=> l_set_of_books_id,
				p_enc_line_type		=> 'U',
				l_retcode			=> l_return_status);

			IF l_return_status <> fnd_api.g_ret_sts_success	THEN
				RAISE fnd_api.g_exc_unexpected_error;
			END IF;
			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Completed verify_changes for l_assignment_id: ' || l_assignment_id || ' payroll_id: ' || l_payroll_id);
		ELSE
			IF (l_liq_all_count > 0) THEN
				UPDATE	psp_enc_lines_history pelh
				SET	change_flag = 'N'
				WHERE	assignment_id = l_assignment_id
				AND	payroll_id = l_payroll_id
				AND	change_flag = 'U'
				AND	EXISTS	(SELECT	1
						FROM	psp_enc_summary_lines pesl
						WHERE	pesl.assignment_id = l_assignment_id
						AND	pesl.payroll_id = l_payroll_id
						AND	status_code = 'A'
						AND	pesl.enc_summary_line_id = pelh.enc_summary_line_id);
				hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Updated lines to be liquidated');
				DELETE	psp_enc_changed_assignments
				WHERE	assignment_id = l_assignment_id
				AND	payroll_id = l_payroll_id
				AND	change_type = 'ZZ';
			ELSE
				UPDATE	psp_enc_lines_history pelh
				SET	change_flag = 'N'
				WHERE	assignment_id = l_assignment_id
				AND	payroll_id = l_payroll_id
				AND	change_flag = 'U'
				AND	EXISTS	(SELECT	1
						FROM	psp_enc_summary_lines pesl
						WHERE	pesl.assignment_id = l_assignment_id
						AND	pesl.payroll_id = l_payroll_id
						AND	status_code = 'A'
						AND	pesl.enc_summary_line_id = pelh.enc_summary_line_id
						AND	pesl.effective_date <= (NVL((SELECT	MAX (ptp.end_date)--MAX(ppa.date_earned): Bug 5642002: Replaced earned date with period end date
										FROM	pay_payroll_actions ppa,
										        pay_assignment_actions paa,
										        per_time_periods ptp
										WHERE 	ppa.payroll_action_id = paa.payroll_action_id (+)
										AND     ppa.payroll_id	= l_payroll_id
										AND   	ppa.action_type	IN( 'R','Q')
										AND	NVL(paa.action_status, ppa.action_status) = 'C'
										   and ppa.date_earned between ptp.start_date and ptp.end_date
										   and ptp.payroll_id = ppa.payroll_id),l_enc_begin_date)) );

				hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Updated lines to be liquidated by regular liquidation');
				UPDATE	psp_enc_lines_history pelh
				SET	change_flag = 'U'
				WHERE	assignment_id = l_assignment_id
				AND	payroll_id = l_payroll_id
				AND	change_flag = 'N'
				AND	EXISTS	(SELECT	1
						FROM	psp_enc_summary_lines pesl
						WHERE	pesl.assignment_id = l_assignment_id
						AND	pesl.payroll_id = l_payroll_id
						AND	status_code = 'A'
						AND	pesl.enc_summary_line_id = pelh.enc_summary_line_id
						AND	pesl.effective_date > (NVL((SELECT	MAX (ptp.end_date)--MAX(ppa.date_earned): Bug 5642002: Replaced earned date with period end date
										FROM	pay_payroll_actions ppa,
										        pay_assignment_actions paa,
										        per_time_periods ptp
										WHERE 	ppa.payroll_action_id = paa.payroll_action_id (+)
										AND     ppa.payroll_id	= l_payroll_id
										AND   	ppa.action_type	IN( 'R','Q')
										AND	NVL(paa.action_status, ppa.action_status) = 'C'
											   and ppa.date_earned between ptp.start_date and ptp.end_date
											   and ptp.payroll_id = ppa.payroll_id),l_enc_begin_date)) );

				hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Updated lines not to be liquidated by regular liquidation');
			END IF;
		END IF;

		create_liq_lines	(p_payroll_action_id	=>	p_payroll_action_id,
							p_payroll_id		=> l_payroll_id,
							p_assignment_id		=> l_assignment_id,
							p_enc_begin_date	=> l_enc_begin_date,
							p_business_group_id	=> l_business_group_id,
							p_set_of_books_id	=> l_set_of_books_id,
							p_return_status		=> l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success	THEN
			RAISE fnd_api.g_exc_unexpected_error;
        END IF;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Completed create_liq_lines for l_assignment_id: ' || l_assignment_id || ' payroll_id: ' || l_payroll_id);

		create_sum_lines	(p_payroll_action_id	=>	p_payroll_action_id,
							p_payroll_id		=> l_payroll_id,
							p_assignment_id		=> l_assignment_id,
							p_business_group_id	=> l_business_group_id,
							p_set_of_books_id	=> l_set_of_books_id,
							p_return_status		=> l_return_status);

		IF l_return_status <> fnd_api.g_ret_sts_success	THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Completed create_sum_lines for l_assignment_id: ' || l_assignment_id || ' payroll_id: ' || l_payroll_id);

		update_hierarchy_dates	(p_payroll_action_id	=>	p_payroll_action_id,
							p_payroll_id		=> l_payroll_id,
							p_assignment_id		=> l_assignment_id,
							p_return_status		=> l_return_status);

		IF l_return_status <> fnd_api.g_ret_sts_success	THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
	END LOOP;

	FORALL recno IN 1..t_assignments.asg_array.COUNT
	UPDATE	psp_enc_process_assignments pepa
	SET	assignment_status = 'B'
	WHERE	pepa.payroll_action_id = p_payroll_action_id
	AND	pepa.assignment_id = t_assignments.asg_array(recno)
	AND	pepa.payroll_id = t_assignments.payroll_array(recno)
	AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl
				WHERE	pesl.payroll_action_id = p_payroll_action_id
				AND	pesl.assignment_id = t_assignments.asg_array(recno)
				AND	pesl.payroll_id = t_assignments.payroll_array(recno));

	FORALL recno IN 1..t_assignments.asg_array.COUNT
	UPDATE	psp_enc_process_assignments pepa
	SET	assignment_status = 'S'
	WHERE	pepa.payroll_action_id = p_payroll_action_id
	AND	pepa.assignment_id = t_assignments.asg_array(recno)
	AND	pepa.payroll_id = t_assignments.payroll_array(recno)
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.payroll_action_id = p_payroll_action_id
			AND	pesl.assignment_id = t_assignments.asg_array(recno)
			AND	pesl.payroll_id = t_assignments.payroll_array(recno));

	FORALL recno IN 1..t_assignments.asg_array.COUNT
	UPDATE	psp_enc_process_assignments pepa
	SET	assignment_status = 'L'
	WHERE	pepa.payroll_action_id = p_payroll_action_id
	AND	pepa.assignment_id = t_assignments.asg_array(recno)
	AND	pepa.payroll_id = t_assignments.payroll_array(recno)
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.payroll_action_id = p_payroll_action_id
			AND	pesl.superceded_line_id IS NOT NULL
			AND	pesl.assignment_id = t_assignments.asg_array(recno)
			AND	pesl.payroll_id = t_assignments.payroll_array(recno));

	t_assignments.payroll_array.delete;
	t_assignments.asg_array.delete;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CEL_ARCHIVE (payroll_action_id: ' || p_payroll_action_id || ' chunk_number: ' || p_chunk_number ||')');
EXCEPTION
	WHEN OTHERS THEN
		log_cel_warnings;
		IF (g_error_message IS NOT NULL) THEN
			IF (l_assignment_id IS NOT NULL) THEN
				OPEN asg_number_cur(l_enc_begin_date);
				FETCH asg_number_cur INTO l_assignment_number, l_person_id, l_organization_id;
				CLOSE asg_number_cur;

				OPEN payroll_name_cur;
				FETCH payroll_name_cur INTO l_payroll_name;
				CLOSE payroll_name_cur;

				OPEN person_name_cur(l_enc_begin_date);
				FETCH person_name_cur INTO l_full_name;
				CLOSE person_name_cur;

				OPEN org_name_cur;
				FETCH org_name_cur INTO l_organization_name;
				CLOSE org_name_cur;

				OPEN element_name_cur;
				FETCH element_name_cur INTO l_element_name;
				CLOSE element_name_cur;

				psp_general.add_report_error
					(p_request_id		=>	g_request_id,
					p_message_level		=>	'E',
					p_source_id		=>	l_assignment_id,
					p_source_name		=>	l_assignment_number,
					p_parent_source_id	=>	l_person_id,
					p_parent_source_name	=>	l_full_name,
					p_error_message		=>	g_error_message,
					p_payroll_action_id	=>	p_payroll_action_id,
					p_value1		=>	l_payroll_id,
					p_information1		=>	l_payroll_name,
					p_value2		=>	l_organization_id,
					p_information2		=>	l_organization_name,
					p_value3		=>	l_element_type_id,
					p_information3		=>	l_element_name,
					p_return_status		=>	l_return_status);
			ELSE
				psp_general.add_report_error
					(p_request_id		=>	g_request_id,
					p_message_level		=>	'E',
					p_source_id		=>	NULL,
					p_source_name		=>	NULL,
					p_parent_source_id	=>	NULL,
					p_parent_source_name	=>	NULL,
					p_error_message		=>	g_error_message,
					p_payroll_action_id	=>	p_payroll_action_id,
					p_value1		=>	NULL,
					p_information1		=>	NULL,
					p_return_status		=>	l_return_status);
			END IF;
		END IF;
		fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', 'CEL_ARCHIVE: SQLCODE: ' || fnd_number.number_to_canonical(SQLCODE) || ' SQLERRM: ' || SQLERRM);
		psp_message_s.print_error(p_mode => FND_FILE.LOG, p_print_header => FND_API.G_TRUE);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CEL_ARCHIVE (payroll_action_id: ' || p_payroll_action_id || ' chunk_number: ' || p_chunk_number ||')');
		ROLLBACK TO CEL_ARCHIVE;
		RAISE;
END cel_archive;

procedure cel_deinit(p_payroll_action_id in number) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_last_update_date		DATE;
l_last_updated_by		NUMBER;
l_request_id			NUMBER(15);
l_business_group_id		NUMBER(15);
l_set_of_books_id		NUMBER(15);
l_error_count			NUMBER;
l_process_mode			VARCHAR2(30);
l_process_phase			VARCHAR2(30);
call_status			BOOLEAN;
rphase				VARCHAR2(30);
rstatus				VARCHAR2(30);
dphase				VARCHAR2(30);
dstatus				VARCHAR2(30);
message				VARCHAR2(240);
l_xml_layout			BOOLEAN;
l_st_count			NUMBER(15);

CURSOR	payroll_id_cur IS
SELECT	argument12
FROM	fnd_concurrent_requests fcr,
	psp_enc_processes pep
WHERE	pep.payroll_action_id = p_payroll_action_id
AND	fcr.request_id = pep.request_id;

CURSOR	process_phase_cur IS
SELECT	process_phase
FROM	psp_enc_processes
WHERE	payroll_action_id = p_payroll_action_id
AND	process_code = 'ST';

CURSOR	error_check_cur IS
SELECT  COUNT(1)
FROM	psp_report_errors
WHERE	payroll_action_id = p_payroll_action_id
AND	request_id >= l_request_id
AND	message_level = 'E';

CURSOR	st_count_cur Is
SELECT	COUNT(1)
FROM	psp_enc_summary_lines
WHERE	payroll_action_id = p_payroll_action_id
AND	status_code = 'N';
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering CEL_DEINIT payroll_action_id: ' || p_payroll_action_id);
	l_last_update_date := SYSDATE;
	l_last_updated_by:= NVL(FND_GLOBAL.USER_ID, -1);
	l_request_id := fnd_global.conc_request_id;

	OPEN payroll_id_cur;
	FETCH payroll_id_cur INTO l_process_mode;
	CLOSE payroll_id_cur;

	OPEN process_phase_cur;
	FETCH process_phase_cur INTO l_process_phase;
	CLOSE process_phase_cur;
	l_process_phase := NVL(l_process_phase, 'deinit');

	IF NOT (l_process_mode = 'TERMINATE' AND l_process_phase = 'deinit_st') THEN
		OPEN error_check_cur;
		FETCH error_check_cur INTO l_error_count;
		CLOSE error_check_cur;

		IF (l_error_count > 0) THEN
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Create and Update Encumbrance process has errors. Please review the Run Results Report for more details.');
			l_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
			l_set_of_books_id := fnd_profile.value('GL_SET_OF_BKS_ID');
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Before submitting Encumbrance Run Results Report');
			l_xml_layout := fnd_request.add_layout('PSP','PSPENRSRTF','en','US','PDF');
			l_request_id := fnd_request.submit_request('PSP',
							'PSPENRSLT',
							'',
							'',
							FALSE,
							TO_CHAR(p_payroll_action_id),
							TO_CHAR(fnd_global.conc_request_id),
							TO_CHAR(l_business_group_id),
							TO_CHAR(l_set_of_books_id));

			IF l_request_id = 0 THEN
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Encumbrance Run Results Report submission failed');
				fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			COMMIT;
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		UPDATE	psp_enc_process_assignments pepa
		SET	assignment_status = 'B'
		WHERE	payroll_action_id = p_payroll_action_id
		AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.payroll_action_id = p_payroll_action_id
					AND	pesl.assignment_id = pepa.assignment_id
					AND	pesl.payroll_id = pepa.payroll_id
					AND	pesl.status_code = 'N');

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

		fnd_stats.gather_table_stats('PSP', 'PSP_ENC_CONTROLS');
		fnd_stats.gather_table_stats('PSP', 'PSP_ENC_LINES');
		fnd_stats.gather_table_stats('PSP', 'PSP_ENC_SUMMARY_LINES');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed Gather Statistics');

		DELETE  FROM psp_enc_controls pec
		WHERE   pec.payroll_action_id = p_payroll_action_id
		AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_lines pel
					WHERE	pel.enc_control_id = pec.enc_control_id);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted lines in psp_enc_controls which doesnt have a line in psp_enc_lines');

		UPDATE	psp_enc_controls pec
		SET		(action_code,
				number_of_dr,				number_of_cr,
				total_dr_amount,			total_cr_amount,
				gl_dr_amount,				gl_cr_amount,
				ogm_dr_amount,				ogm_cr_amount) =
				(SELECT	'N',
					SUM(fnd_number.canonical_to_number(DECODE(pel.dr_cr_flag, 'D', 1, 0))), SUM(fnd_number.canonical_to_number(DECODE(pel.dr_cr_flag, 'C', 1, 0))),
					SUM(fnd_number.canonical_to_number(DECODE(pel.dr_cr_flag, 'D', pel.encumbrance_amount, 0))), SUM(fnd_number.canonical_to_number(DECODE(pel.dr_cr_flag, 'C', pel.encumbrance_amount, 0))),
					SUM(fnd_number.canonical_to_number(DECODE(pel.gl_project_flag, 'G', DECODE(pel.dr_cr_flag, 'D', pel.encumbrance_amount, 0), 0))),
					SUM(fnd_number.canonical_to_number(DECODE(pel.gl_project_flag, 'G', DECODE(pel.dr_cr_flag, 'C', pel.encumbrance_amount, 0), 0))),
					SUM(fnd_number.canonical_to_number(DECODE(pel.gl_project_flag, 'P', DECODE(pel.dr_cr_flag, 'D', pel.encumbrance_amount, 0), 0))),
					SUM(fnd_number.canonical_to_number(DECODE(pel.gl_project_flag, 'P', DECODE(pel.dr_cr_flag, 'C', pel.encumbrance_amount, 0), 0)))
				FROM	psp_enc_lines pel
				WHERE	pel.enc_control_id = pec.enc_control_id)
		WHERE	payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated summary columns in psp_enc_controls');

		IF (l_process_mode = 'TERMINATE') THEN
			UPDATE	psp_enc_changed_assignments peca
			SET	payroll_action_id = p_payroll_action_id
			WHERE	EXISTS	(SELECT	1
					FROM	psp_enc_changed_assignments peca2
					WHERE	peca2.assignment_id = peca.assignment_id
					AND	peca2.change_type = 'TR');
		END IF;

		INSERT INTO     psp_enc_changed_asg_history
				(request_id, assignment_id, payroll_id, change_type, processing_module, created_by,
				creation_date, processed_flag, reference_id, action_type, payroll_action_id, change_date)
		SELECT	l_request_id, peca.assignment_id, peca.payroll_id, peca.change_type,
				'U', l_last_updated_by, l_last_update_date, NULL, NVL(peca.reference_id, 0),
				NVL(peca.action_type, 'U'), p_payroll_action_id, change_date
		FROM	psp_enc_changed_assignments peca
		WHERE   payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Copied change assignment records to psp_enc_changed_asg_history');

		DELETE	psp_enc_changed_assignments peca
		WHERE	peca.payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted processed change assignment records in psp_enc_change_assignments');

		UPDATE	psp_enc_processes
		SET	process_status = 'P'
		WHERE	payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_status in psp_enc_processes');

		UPDATE	psp_enc_processes
		SET	process_status = 'B',
			process_phase = 'no_summarize_transfer'
		WHERE	payroll_action_id = p_payroll_action_id
		AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.payroll_action_id = p_payroll_action_id
					AND		pesl.status_code = 'N');

		UPDATE	psp_enc_processes
		SET		process_phase = 'summarize_transfer'
		WHERE	payroll_action_id = p_payroll_action_id
		AND	EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl
				WHERE	pesl.payroll_action_id = p_payroll_action_id
				AND		pesl.status_code = 'N'
				AND		pesl.superceded_line_id IS NULL);

		UPDATE	psp_enc_processes
		SET	process_phase = 'liquidate'
		WHERE	payroll_action_id = p_payroll_action_id
		AND	EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl
				WHERE	pesl.payroll_action_id = p_payroll_action_id
				AND		pesl.status_code = 'N'
				AND		pesl.superceded_line_id is NOT NULL);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase in psp_enc_processes');
	END IF;

	l_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
	l_set_of_books_id := fnd_profile.value('GL_SET_OF_BKS_ID');
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Before submitting Encumbrance Run Results Report');
	l_xml_layout := fnd_request.add_layout('PSP','PSPENRSRTF','en','US','PDF');
	l_request_id := fnd_request.submit_request('PSP',
					'PSPENRSLT',
					'',
					'',
					FALSE,
					TO_CHAR(p_payroll_action_id),
					TO_CHAR(fnd_global.conc_request_id),
					TO_CHAR(l_business_group_id),
					TO_CHAR(l_set_of_books_id));

	IF l_request_id = 0 THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Encumbrance Run Results Report submission failed');
		fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	COMMIT;

	IF (l_process_mode = 'TERMINATE') THEN
		OPEN st_count_cur;
		FETCH st_count_cur INTO l_st_count;
		CLOSE st_count_cur;

		IF (l_st_count > 0) THEN
			l_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
			l_set_of_books_id := fnd_profile.value('GL_SET_OF_BKS_ID');

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Before submitting Encumbrance Summarize and Transfer');
			l_request_id := fnd_request.submit_request('PSP',
							'PSPENSTR',
							'',
							'',
							FALSE,
							TO_CHAR(p_payroll_action_id),
							TO_CHAR(l_business_group_id),
							TO_CHAR(l_set_of_books_id));

			IF l_request_id = 0 THEN
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Encumbrance Summarize and Transfer submission failed');
				fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

			UPDATE	psp_enc_processes
			SET	process_phase = 'deinit_st'
			WHERE	payroll_action_id = p_payroll_action_id
			AND	process_code = 'ST';
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase in psp_enc_processes');

			COMMIT;

			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Waiting for Encumbrance Summarize and Transfer request to complete');
			call_status := fnd_concurrent.wait_for_request(l_request_id, 10, 0, rphase, rstatus, dphase, dstatus, message);

			IF call_status = FALSE THEN
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Encumbrance Summarize and Transfer failed');
				fnd_message.set_name('PSP','PSP_ENC_STR_FAILED');
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Encumbrance Summarize and Transfer completed');
		ELSE
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Encumbrance Summarize and Transfer not required as there arent any new summary lines');
		END IF;
	END IF;

	COMMIT;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CEL_DEINIT payroll_action_id: ' || p_payroll_action_id);
END cel_deinit;

PROCEDURE verify_changes(p_payroll_id		IN 	NUMBER,
			 p_assignment_id	IN 	NUMBER,
			 p_business_group_id	IN 	NUMBER,
			 p_set_of_books_id	IN 	NUMBER,
			 p_enc_line_type	IN	VARCHAR2,
			 l_retcode		OUT NOCOPY 	VARCHAR2) IS
TYPE  time_period_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  encumbrance_date_tl IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE  dr_cr_flag_tl IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE  encumbrance_amount_tl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE  gl_project_flag_tl IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
TYPE  schedule_line_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  org_schedule_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  default_org_account_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  suspense_org_account_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  element_account_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  project_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  task_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  award_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  expenditure_type_tl IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE  exp_organization_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  gl_code_combination_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  attribute_category_tl IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE  attribute_tl IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE  hierarchy_code_tl IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE  enc_summary_line_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE  enc_element_type_id_tl IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

l_time_period_id_tl  time_period_id_tl;
l_encumbrance_date_tl  encumbrance_date_tl;
l_dr_cr_flag_tl  dr_cr_flag_tl;
l_encumbrance_amount_tl  encumbrance_amount_tl;
l_gl_project_flag_tl  gl_project_flag_tl;
l_schedule_line_id_tl  schedule_line_id_tl;
l_org_schedule_id_tl  org_schedule_id_tl;
l_default_org_account_id_tl  default_org_account_id_tl;
l_suspense_org_account_id_tl  suspense_org_account_id_tl;
l_element_account_id_tl  element_account_id_tl;
l_project_id_tl  project_id_tl;
l_task_id_tl  task_id_tl;
l_award_id_tl  award_id_tl;
l_expenditure_type_tl  expenditure_type_tl;
l_exp_organization_id_tl  exp_organization_id_tl;
l_gl_code_combination_id_tl  gl_code_combination_id_tl;
l_attribute_category_tl  attribute_category_tl;
l_attribute1_tl  attribute_tl;
l_attribute2_tl  attribute_tl;
l_attribute3_tl  attribute_tl;
l_attribute4_tl  attribute_tl;
l_attribute5_tl  attribute_tl;
l_attribute6_tl  attribute_tl;
l_attribute7_tl  attribute_tl;
l_attribute8_tl  attribute_tl;
l_attribute9_tl  attribute_tl;
l_attribute10_tl  attribute_tl;
l_default_reason_tl  attribute_tl;
l_suspense_reason_tl  attribute_tl;
l_hierarchy_code_tl	hierarchy_code_tl;
l_enc_summary_line_id_tl	enc_summary_line_id_tl;
l_enc_element_type_id_tl	enc_element_type_id_tl;

CURSOR	enc_lines_history_cur IS
SELECT	DISTINCT pelh.time_period_id ,
	pelh.encumbrance_date ,
	pelh.dr_cr_flag,
	pelh.encumbrance_amount ,
	pelh.gl_project_flag,
	pelh.enc_element_type_id,
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
	NVL(pelh.attribute_category,'NULL_VALUE'),
	NVL(pelh.attribute1, 'NULL_VALUE'),
	NVL(pelh.attribute2, 'NULL_VALUE'),
	NVL(pelh.attribute3, 'NULL_VALUE'),
	NVL(pelh.attribute4, 'NULL_VALUE'),
	NVL(pelh.attribute5, 'NULL_VALUE'),
	NVL(pelh.attribute6, 'NULL_VALUE'),
	NVL(pelh.attribute7, 'NULL_VALUE'),
	NVL(pelh.attribute8, 'NULL_VALUE'),
	NVL(pelh.attribute9, 'NULL_VALUE'),
	NVL(pelh.attribute10, 'NULL_VALUE'),
	NVL(pelh.default_reason_code, 'NULL'),
	NVL(pelh.suspense_reason_code, 'NULL'),
	hierarchy_code
FROM	psp_enc_lines_history pelh
WHERE	pelh.change_flag = 'U'
AND	payroll_id = p_payroll_id
AND	assignment_id = p_assignment_id;

CURSOR	modified_summary_lines_cur IS
SELECT	DISTINCT enc_summary_line_id
FROM	psp_enc_lines_history
WHERE	change_flag = 'N'
AND	payroll_id = p_payroll_id
AND	assignment_id = p_assignment_id;

l_enc_lines_no		NUMBER(15);
l_delete_flag		CHAR(1);
l_return_status		VARCHAR2(1);
BEGIN
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Entering verify_changes
		p_payroll_id: ' || p_payroll_id || ' p_assignment_id: ' || p_assignment_id || '
		p_business_group_id: ' || p_business_group_id || ' p_set_of_books_id: ' || p_set_of_books_id || '
		p_enc_line_type: ' || p_enc_line_type);

	UPDATE	psp_enc_lines_history
	SET	change_flag = 'N'
	WHERE	assignment_id = p_assignment_id
	AND	payroll_id = p_payroll_id
	AND	change_flag = 'U'
	AND	status_code = 'A';

	IF (g_dff_grouping_option = 'N') THEN
		FORALL recno IN 1 .. t_enc_lines_array.r_time_period_id.COUNT
		UPDATE	psp_enc_lines_history pelh
		SET	change_flag='U'
		WHERE	time_period_id = t_enc_lines_array.r_time_period_id(recno)
		AND	change_flag = 'N'
		AND	pelh.encumbrance_date = t_enc_lines_array.r_encumbrance_date(recno)
		AND	pelh.enc_element_type_id = t_enc_lines_array.r_enc_element_type_id(recno)
		AND	pelh.dr_cr_flag = t_enc_lines_array.r_dr_cr_flag(recno)
		AND	pelh.encumbrance_amount = ROUND( t_enc_lines_array.r_encumbrance_amount(recno),g_precision)
		AND	pelh.gl_project_flag = t_enc_lines_array.r_gl_project_flag(recno)
		AND	pelh.hierarchy_code = t_enc_lines_array.r_hierarchy_code(recno)
		AND	NVL(pelh.project_id, -99) = NVL(t_enc_lines_array.r_project_id(recno), -99)
		AND	NVL(pelh.task_id, -99) = NVL(t_enc_lines_array.r_task_id(recno), -99)
		AND	NVL(pelh.award_id, -99) = NVL(t_enc_lines_array.r_award_id(recno), -99)
		AND	NVL(pelh.expenditure_type, '-99') = NVL(t_enc_lines_array.r_expenditure_type(recno), '-99')
		AND	NVL(pelh.expenditure_organization_id, -99) = NVL(t_enc_lines_array.r_expenditure_organization_id(recno), -99)
		AND	NVL(pelh.gl_code_combination_id, -99) = NVL(t_enc_lines_array.r_gl_code_combination_id(recno), -99)
		AND	NVL(suspense_reason_code, 'NULL') = NVL(t_enc_lines_array.r_suspense_reason_code(recno), 'NULL')
		AND	NVL(default_reason_code, 'NULL') = NVL(t_enc_lines_array.r_default_reason_code(recno), 'NULL')
		AND	pelh.assignment_id = p_assignment_id
		AND	pelh.payroll_id = p_payroll_id;
	ELSE
		FORALL recno IN 1 .. t_enc_lines_array.r_time_period_id.COUNT
		UPDATE	psp_enc_lines_history pelh
		SET	change_flag='U'
		WHERE	time_period_id = t_enc_lines_array.r_time_period_id(recno)
		AND	change_flag = 'N'
		AND	pelh.encumbrance_date = t_enc_lines_array.r_encumbrance_date(recno)
		AND	pelh.enc_element_type_id = t_enc_lines_array.r_enc_element_type_id(recno)
		AND	pelh.dr_cr_flag = t_enc_lines_array.r_dr_cr_flag(recno)
		AND	pelh.encumbrance_amount = ROUND( t_enc_lines_array.r_encumbrance_amount(recno),g_precision)
		AND	pelh.gl_project_flag = t_enc_lines_array.r_gl_project_flag(recno)
		AND	pelh.hierarchy_code = t_enc_lines_array.r_hierarchy_code(recno)
		AND	NVL(pelh.project_id, -99) = NVL(t_enc_lines_array.r_project_id(recno), -99)
		AND	NVL(pelh.task_id, -99) = NVL(t_enc_lines_array.r_task_id(recno), -99)
		AND	NVL(pelh.award_id, -99) = NVL(t_enc_lines_array.r_award_id(recno), -99)
		AND	NVL(pelh.expenditure_type, '-99') = NVL(t_enc_lines_array.r_expenditure_type(recno), '-99')
		AND	NVL(pelh.expenditure_organization_id, -99) = NVL(t_enc_lines_array.r_expenditure_organization_id(recno), -99)
		AND	NVL(pelh.gl_code_combination_id, -99) = NVL(t_enc_lines_array.r_gl_code_combination_id(recno), -99)
		AND	NVL(suspense_reason_code, 'NULL') = NVL(t_enc_lines_array.r_suspense_reason_code(recno), 'NULL')
		AND	NVL(default_reason_code, 'NULL') = NVL(t_enc_lines_array.r_default_reason_code(recno), 'NULL')
		AND	pelh.assignment_id = p_assignment_id
		AND	pelh.payroll_id = p_payroll_id
		AND	NVL(pelh.attribute_category, 'NULL_VALUE') = t_enc_lines_array.r_attribute_category(recno)
		AND	NVL(pelh.attribute1, 'NULL_VALUE') = t_enc_lines_array.r_attribute1(recno)
		AND	NVL(pelh.attribute2, 'NULL_VALUE') = t_enc_lines_array.r_attribute2(recno)
		AND	NVL(pelh.attribute3, 'NULL_VALUE') = t_enc_lines_array.r_attribute3(recno)
		AND	NVL(pelh.attribute4, 'NULL_VALUE') = t_enc_lines_array.r_attribute4(recno)
		AND	NVL(pelh.attribute5, 'NULL_VALUE') = t_enc_lines_array.r_attribute5(recno)
		AND	NVL(pelh.attribute6, 'NULL_VALUE') = t_enc_lines_array.r_attribute6(recno)
		AND	NVL(pelh.attribute7, 'NULL_VALUE') = t_enc_lines_array.r_attribute7(recno)
		AND	NVL(pelh.attribute8, 'NULL_VALUE') = t_enc_lines_array.r_attribute8(recno)
		AND	NVL(pelh.attribute9, 'NULL_VALUE') = t_enc_lines_array.r_attribute9(recno)
		AND	NVL(pelh.attribute10, 'NULL_VALUE') = t_enc_lines_array.r_attribute10(recno);
	END IF;

	OPEN modified_summary_lines_cur;
	FETCH modified_summary_lines_cur BULK COLLECT INTO l_enc_summary_line_id_tl;
	CLOSE modified_summary_lines_cur;

	hr_utility.trace('l_enc_summary_line_id_tl.COUNT: ' || l_enc_summary_line_id_tl.COUNT);

	FORALL recno IN 1..l_enc_summary_line_id_tl.COUNT
	UPDATE	psp_enc_lines_history pelh
	SET	change_flag='N'
	WHERE	enc_summary_line_id = l_enc_summary_line_id_tl(recno)
	AND	change_flag='U';

	l_enc_summary_line_id_tl.DELETE;

	OPEN  enc_lines_history_cur;
	FETCH enc_lines_history_cur BULK COLLECT INTO
		l_time_period_id_tl,l_encumbrance_date_tl,l_dr_cr_flag_tl,l_encumbrance_amount_tl,
		l_gl_project_flag_tl,l_enc_element_type_id_tl,l_schedule_line_id_tl,l_org_schedule_id_tl,
		l_default_org_account_id_tl,l_suspense_org_account_id_tl,l_element_account_id_tl,
		l_project_id_tl,l_task_id_tl,l_award_id_tl,l_expenditure_type_tl,l_exp_organization_id_tl,
		l_gl_code_combination_id_tl, l_attribute_category_tl,
		l_attribute1_tl,l_attribute2_tl,l_attribute3_tl,l_attribute4_tl,l_attribute5_tl,
		l_attribute6_tl,l_attribute7_tl,l_attribute8_tl,l_attribute9_tl,l_attribute10_tl,
		l_default_reason_tl, l_suspense_reason_tl, l_hierarchy_code_tl;
	CLOSE  enc_lines_history_cur;

	l_enc_lines_no := 1;
	IF (g_dff_grouping_option = 'N') THEN
		FOR recno1 IN 1..t_enc_lines_array.r_time_period_id.COUNT
		LOOP
			l_delete_flag := 'N';
			FOR recno2 IN 1 .. l_time_period_id_tl.COUNT
			LOOP
				IF (t_enc_lines_array.r_time_period_id(recno1) = l_time_period_id_tl(recno2)
					AND	t_enc_lines_array.r_encumbrance_date(recno1) = l_encumbrance_date_tl(recno2)
					AND	t_enc_lines_array.r_dr_cr_flag(recno1) = l_dr_cr_flag_tl(recno2)
					AND	ROUND(t_enc_lines_array.r_encumbrance_amount(recno1), g_precision) = l_encumbrance_amount_tl(recno2)
					AND	t_enc_lines_array.r_gl_project_flag(recno1) = l_gl_project_flag_tl(recno2)
					AND	t_enc_lines_array.r_enc_element_type_id(recno1) = l_enc_element_type_id_tl(recno2)
					AND	t_enc_lines_array.r_hierarchy_code(recno1) = l_hierarchy_code_tl(recno2)
					AND	NVL(t_enc_lines_array.r_default_reason_code(recno1), 'NULL') = NVL(l_default_reason_tl(recno2), 'NULL')
					AND	NVL(t_enc_lines_array.r_suspense_reason_code(recno1), 'NULL') = NVL(l_suspense_reason_tl(recno2), 'NULL')
					AND	NVL(t_enc_lines_array.r_project_id(recno1), -99) = l_project_id_tl(recno2)
					AND	NVL(t_enc_lines_array.r_task_id(recno1), -99) = l_task_id_tl(recno2)
					AND	NVL(t_enc_lines_array.r_award_id(recno1), -99) = l_award_id_tl(recno2)
					AND	NVL(t_enc_lines_array.r_expenditure_type(recno1), '-99') = l_expenditure_type_tl(recno2)
					AND	NVL(t_enc_lines_array.r_expenditure_organization_id(recno1), -99) = l_exp_organization_id_tl(recno2)
					AND	NVL(t_enc_lines_array.r_gl_code_combination_id(recno1), -99) = l_gl_code_combination_id_tl(recno2)) THEN
					l_delete_flag := 'Y';
					EXIT;
				END IF;
			END LOOP;

			IF (l_delete_flag = 'N') THEN
				t_enc_lines_array2.r_enc_element_type_id(l_enc_lines_no) := t_enc_lines_array.r_enc_element_type_id(recno1);
				t_enc_lines_array2.r_encumbrance_date(l_enc_lines_no) := t_enc_lines_array.r_encumbrance_date(recno1);
				t_enc_lines_array2.r_dr_cr_flag(l_enc_lines_no) := t_enc_lines_array.r_dr_cr_flag(recno1);
				t_enc_lines_array2.r_encumbrance_amount(l_enc_lines_no) := t_enc_lines_array.r_encumbrance_amount(recno1);
				t_enc_lines_array2.r_enc_line_type(l_enc_lines_no) := t_enc_lines_array.r_enc_line_type(recno1);
				t_enc_lines_array2.r_schedule_line_id(l_enc_lines_no) := t_enc_lines_array.r_schedule_line_id(recno1);
				t_enc_lines_array2.r_org_schedule_id(l_enc_lines_no) := t_enc_lines_array.r_org_schedule_id(recno1);
				t_enc_lines_array2.r_default_org_account_id(l_enc_lines_no) := t_enc_lines_array.r_default_org_account_id(recno1);
				t_enc_lines_array2.r_suspense_org_account_id(l_enc_lines_no) := t_enc_lines_array.r_suspense_org_account_id(recno1);
				t_enc_lines_array2.r_element_account_id(l_enc_lines_no) := t_enc_lines_array.r_element_account_id(recno1);
				t_enc_lines_array2.r_gl_project_flag(l_enc_lines_no) := t_enc_lines_array.r_gl_project_flag(recno1);
				t_enc_lines_array2.r_person_id(l_enc_lines_no) := t_enc_lines_array.r_person_id(recno1);
				t_enc_lines_array2.r_assignment_id(l_enc_lines_no) := t_enc_lines_array.r_assignment_id(recno1);
				t_enc_lines_array2.r_award_id(l_enc_lines_no) := t_enc_lines_array.r_award_id(recno1);
				t_enc_lines_array2.r_task_id(l_enc_lines_no) := t_enc_lines_array.r_task_id(recno1);
				t_enc_lines_array2.r_expenditure_type(l_enc_lines_no) := t_enc_lines_array.r_expenditure_type(recno1);
				t_enc_lines_array2.r_expenditure_organization_id(l_enc_lines_no) := t_enc_lines_array.r_expenditure_organization_id(recno1);
				t_enc_lines_array2.r_project_id(l_enc_lines_no) := t_enc_lines_array.r_project_id(recno1);
				t_enc_lines_array2.r_gl_code_combination_id(l_enc_lines_no) := t_enc_lines_array.r_gl_code_combination_id(recno1);
				t_enc_lines_array2.r_time_period_id(l_enc_lines_no) := t_enc_lines_array.r_time_period_id(recno1);
				t_enc_lines_array2.r_default_reason_code(l_enc_lines_no) := t_enc_lines_array.r_default_reason_code(recno1);
				t_enc_lines_array2.r_suspense_reason_code(l_enc_lines_no) := t_enc_lines_array.r_suspense_reason_code(recno1);
				t_enc_lines_array2.r_enc_control_id(l_enc_lines_no) := t_enc_lines_array.r_enc_control_id(recno1);
				t_enc_lines_array2.r_change_flag(l_enc_lines_no) := t_enc_lines_array.r_change_flag(recno1);
				t_enc_lines_array2.r_enc_start_date(l_enc_lines_no) := t_enc_lines_array.r_enc_start_date(recno1);
				t_enc_lines_array2.r_enc_end_date(l_enc_lines_no) := t_enc_lines_array.r_enc_end_date(recno1);
				t_enc_lines_array2.r_attribute_category(l_enc_lines_no) := t_enc_lines_array.r_attribute_category(recno1);
				t_enc_lines_array2.r_attribute1(l_enc_lines_no) := t_enc_lines_array.r_attribute1(recno1);
				t_enc_lines_array2.r_attribute2(l_enc_lines_no) := t_enc_lines_array.r_attribute2(recno1);
				t_enc_lines_array2.r_attribute3(l_enc_lines_no) := t_enc_lines_array.r_attribute3(recno1);
				t_enc_lines_array2.r_attribute4(l_enc_lines_no) := t_enc_lines_array.r_attribute4(recno1);
				t_enc_lines_array2.r_attribute5(l_enc_lines_no) := t_enc_lines_array.r_attribute5(recno1);
				t_enc_lines_array2.r_attribute6(l_enc_lines_no) := t_enc_lines_array.r_attribute6(recno1);
				t_enc_lines_array2.r_attribute7(l_enc_lines_no) := t_enc_lines_array.r_attribute7(recno1);
				t_enc_lines_array2.r_attribute8(l_enc_lines_no) := t_enc_lines_array.r_attribute8(recno1);
				t_enc_lines_array2.r_attribute9(l_enc_lines_no) := t_enc_lines_array.r_attribute9(recno1);
				t_enc_lines_array2.r_attribute10(l_enc_lines_no) := t_enc_lines_array.r_attribute10(recno1);
				t_enc_lines_array2.r_orig_gl_code_combination_id(l_enc_lines_no) := t_enc_lines_array.r_orig_gl_code_combination_id(recno1);
				t_enc_lines_array2.r_orig_project_id(l_enc_lines_no) := t_enc_lines_array.r_orig_project_id(recno1);
				t_enc_lines_array2.r_orig_award_id(l_enc_lines_no) := t_enc_lines_array.r_orig_award_id(recno1);
				t_enc_lines_array2.r_orig_task_id(l_enc_lines_no) := t_enc_lines_array.r_orig_task_id(recno1);
				t_enc_lines_array2.r_orig_expenditure_type(l_enc_lines_no) := t_enc_lines_array.r_orig_expenditure_type(recno1);
				t_enc_lines_array2.r_orig_expenditure_org_id(l_enc_lines_no) := t_enc_lines_array.r_orig_expenditure_org_id(recno1);
				t_enc_lines_array2.r_hierarchy_code(l_enc_lines_no) := t_enc_lines_array.r_hierarchy_code(recno1);
				l_enc_lines_no := l_enc_lines_no + 1;
			END IF;
		END LOOP;
	ELSE
		FOR recno1 IN 1..t_enc_lines_array.r_time_period_id.COUNT
		LOOP
			l_delete_flag := 'N';
			FOR recno2 IN 1 .. l_time_period_id_tl.COUNT
			LOOP
				IF (t_enc_lines_array.r_time_period_id(recno1) = l_time_period_id_tl(recno2)
					AND	t_enc_lines_array.r_encumbrance_date(recno1) = l_encumbrance_date_tl(recno2)
					AND	t_enc_lines_array.r_dr_cr_flag(recno1) = l_dr_cr_flag_tl(recno2)
					AND	t_enc_lines_array.r_enc_element_type_id(recno1) = l_enc_element_type_id_tl(recno2)
					AND	ROUND(t_enc_lines_array.r_encumbrance_amount(recno1), g_precision) = l_encumbrance_amount_tl(recno2)
					AND	t_enc_lines_array.r_gl_project_flag(recno1) = l_gl_project_flag_tl(recno2)
					AND	t_enc_lines_array.r_hierarchy_code(recno1) = l_hierarchy_code_tl(recno2)
					AND	NVL(t_enc_lines_array.r_default_reason_code(recno1), 'NULL') = NVL(l_default_reason_tl(recno2), 'NULL')
					AND	NVL(t_enc_lines_array.r_suspense_reason_code(recno1), 'NULL') = NVL(l_suspense_reason_tl(recno2), 'NULL')
					AND	NVL(t_enc_lines_array.r_project_id(recno1), -99) = l_project_id_tl(recno2)
					AND	NVL(t_enc_lines_array.r_task_id(recno1), -99) = l_task_id_tl(recno2)
					AND	NVL(t_enc_lines_array.r_award_id(recno1), -99) = l_award_id_tl(recno2)
					AND	NVL(t_enc_lines_array.r_expenditure_type(recno1), '-99') = l_expenditure_type_tl(recno2)
					AND	NVL(t_enc_lines_array.r_expenditure_organization_id(recno1), -99) = l_exp_organization_id_tl(recno2)
					AND	NVL(t_enc_lines_array.r_gl_code_combination_id(recno1), -99) = l_gl_code_combination_id_tl(recno2)
					AND	t_enc_lines_array.r_attribute_category(recno1) = l_attribute_category_tl(recno2)
					AND	t_enc_lines_array.r_attribute1(recno1) = l_attribute1_tl(recno2)
					AND	t_enc_lines_array.r_attribute2(recno1) = l_attribute2_tl(recno2)
					AND	t_enc_lines_array.r_attribute3(recno1) = l_attribute3_tl(recno2)
					AND	t_enc_lines_array.r_attribute4(recno1) = l_attribute4_tl(recno2)
					AND	t_enc_lines_array.r_attribute5(recno1) = l_attribute5_tl(recno2)
					AND	t_enc_lines_array.r_attribute6(recno1) = l_attribute6_tl(recno2)
					AND	t_enc_lines_array.r_attribute7(recno1) = l_attribute7_tl(recno2)
					AND	t_enc_lines_array.r_attribute8(recno1) = l_attribute8_tl(recno2)
					AND	t_enc_lines_array.r_attribute9(recno1) = l_attribute9_tl(recno2)
					AND	t_enc_lines_array.r_attribute10(recno1) = l_attribute10_tl(recno2)) THEN
					l_delete_flag := 'Y';
					EXIT;
				END IF;
			END LOOP;

			IF (l_delete_flag = 'N') THEN
				t_enc_lines_array2.r_enc_element_type_id(l_enc_lines_no) := t_enc_lines_array.r_enc_element_type_id(recno1);
				t_enc_lines_array2.r_encumbrance_date(l_enc_lines_no) := t_enc_lines_array.r_encumbrance_date(recno1);
				t_enc_lines_array2.r_dr_cr_flag(l_enc_lines_no) := t_enc_lines_array.r_dr_cr_flag(recno1);
				t_enc_lines_array2.r_encumbrance_amount(l_enc_lines_no) := t_enc_lines_array.r_encumbrance_amount(recno1);
				t_enc_lines_array2.r_enc_line_type(l_enc_lines_no) := t_enc_lines_array.r_enc_line_type(recno1);
				t_enc_lines_array2.r_schedule_line_id(l_enc_lines_no) := t_enc_lines_array.r_schedule_line_id(recno1);
				t_enc_lines_array2.r_org_schedule_id(l_enc_lines_no) := t_enc_lines_array.r_org_schedule_id(recno1);
				t_enc_lines_array2.r_default_org_account_id(l_enc_lines_no) := t_enc_lines_array.r_default_org_account_id(recno1);
				t_enc_lines_array2.r_suspense_org_account_id(l_enc_lines_no) := t_enc_lines_array.r_suspense_org_account_id(recno1);
				t_enc_lines_array2.r_element_account_id(l_enc_lines_no) := t_enc_lines_array.r_element_account_id(recno1);
				t_enc_lines_array2.r_gl_project_flag(l_enc_lines_no) := t_enc_lines_array.r_gl_project_flag(recno1);
				t_enc_lines_array2.r_person_id(l_enc_lines_no) := t_enc_lines_array.r_person_id(recno1);
				t_enc_lines_array2.r_assignment_id(l_enc_lines_no) := t_enc_lines_array.r_assignment_id(recno1);
				t_enc_lines_array2.r_award_id(l_enc_lines_no) := t_enc_lines_array.r_award_id(recno1);
				t_enc_lines_array2.r_task_id(l_enc_lines_no) := t_enc_lines_array.r_task_id(recno1);
				t_enc_lines_array2.r_expenditure_type(l_enc_lines_no) := t_enc_lines_array.r_expenditure_type(recno1);
				t_enc_lines_array2.r_expenditure_organization_id(l_enc_lines_no) := t_enc_lines_array.r_expenditure_organization_id(recno1);
				t_enc_lines_array2.r_project_id(l_enc_lines_no) := t_enc_lines_array.r_project_id(recno1);
				t_enc_lines_array2.r_gl_code_combination_id(l_enc_lines_no) := t_enc_lines_array.r_gl_code_combination_id(recno1);
				t_enc_lines_array2.r_time_period_id(l_enc_lines_no) := t_enc_lines_array.r_time_period_id(recno1);
				t_enc_lines_array2.r_default_reason_code(l_enc_lines_no) := t_enc_lines_array.r_default_reason_code(recno1);
				t_enc_lines_array2.r_suspense_reason_code(l_enc_lines_no) := t_enc_lines_array.r_suspense_reason_code(recno1);
				t_enc_lines_array2.r_enc_control_id(l_enc_lines_no) := t_enc_lines_array.r_enc_control_id(recno1);
				t_enc_lines_array2.r_change_flag(l_enc_lines_no) := t_enc_lines_array.r_change_flag(recno1);
				t_enc_lines_array2.r_enc_start_date(l_enc_lines_no) := t_enc_lines_array.r_enc_start_date(recno1);
				t_enc_lines_array2.r_enc_end_date(l_enc_lines_no) := t_enc_lines_array.r_enc_end_date(recno1);
				t_enc_lines_array2.r_attribute_category(l_enc_lines_no) := t_enc_lines_array.r_attribute_category(recno1);
				t_enc_lines_array2.r_attribute1(l_enc_lines_no) := t_enc_lines_array.r_attribute1(recno1);
				t_enc_lines_array2.r_attribute2(l_enc_lines_no) := t_enc_lines_array.r_attribute2(recno1);
				t_enc_lines_array2.r_attribute3(l_enc_lines_no) := t_enc_lines_array.r_attribute3(recno1);
				t_enc_lines_array2.r_attribute4(l_enc_lines_no) := t_enc_lines_array.r_attribute4(recno1);
				t_enc_lines_array2.r_attribute5(l_enc_lines_no) := t_enc_lines_array.r_attribute5(recno1);
				t_enc_lines_array2.r_attribute6(l_enc_lines_no) := t_enc_lines_array.r_attribute6(recno1);
				t_enc_lines_array2.r_attribute7(l_enc_lines_no) := t_enc_lines_array.r_attribute7(recno1);
				t_enc_lines_array2.r_attribute8(l_enc_lines_no) := t_enc_lines_array.r_attribute8(recno1);
				t_enc_lines_array2.r_attribute9(l_enc_lines_no) := t_enc_lines_array.r_attribute9(recno1);
				t_enc_lines_array2.r_attribute10(l_enc_lines_no) := t_enc_lines_array.r_attribute10(recno1);
				t_enc_lines_array2.r_orig_gl_code_combination_id(l_enc_lines_no) := t_enc_lines_array.r_orig_gl_code_combination_id(recno1);
				t_enc_lines_array2.r_orig_project_id(l_enc_lines_no) := t_enc_lines_array.r_orig_project_id(recno1);
				t_enc_lines_array2.r_orig_award_id(l_enc_lines_no) := t_enc_lines_array.r_orig_award_id(recno1);
				t_enc_lines_array2.r_orig_task_id(l_enc_lines_no) := t_enc_lines_array.r_orig_task_id(recno1);
				t_enc_lines_array2.r_orig_expenditure_type(l_enc_lines_no) := t_enc_lines_array.r_orig_expenditure_type(recno1);
				t_enc_lines_array2.r_orig_expenditure_org_id(l_enc_lines_no) := t_enc_lines_array.r_orig_expenditure_org_id(recno1);
				t_enc_lines_array2.r_hierarchy_code(l_enc_lines_no) := t_enc_lines_array.r_hierarchy_code(recno1);
				l_enc_lines_no := l_enc_lines_no + 1;
			END IF;
		END LOOP;
	END IF;

	t_enc_lines_array.r_enc_element_type_id.DELETE;
	t_enc_lines_array.r_encumbrance_date.DELETE;
	t_enc_lines_array.r_dr_cr_flag.DELETE;
	t_enc_lines_array.r_encumbrance_amount.DELETE;
	t_enc_lines_array.r_enc_line_type.DELETE;
	t_enc_lines_array.r_schedule_line_id.DELETE;
	t_enc_lines_array.r_org_schedule_id.DELETE;
	t_enc_lines_array.r_default_org_account_id.DELETE;
	t_enc_lines_array.r_suspense_org_account_id.DELETE;
	t_enc_lines_array.r_element_account_id.DELETE;
	t_enc_lines_array.r_gl_project_flag.DELETE;
	t_enc_lines_array.r_person_id.DELETE;
	t_enc_lines_array.r_assignment_id.DELETE;
	t_enc_lines_array.r_award_id.DELETE;
	t_enc_lines_array.r_task_id.DELETE;
	t_enc_lines_array.r_expenditure_type.DELETE;
	t_enc_lines_array.r_expenditure_organization_id.DELETE;
	t_enc_lines_array.r_project_id.DELETE;
	t_enc_lines_array.r_gl_code_combination_id.DELETE;
	t_enc_lines_array.r_time_period_id.DELETE;
	t_enc_lines_array.r_default_reason_code.DELETE;
	t_enc_lines_array.r_suspense_reason_code.DELETE;
	t_enc_lines_array.r_enc_control_id.DELETE;
	t_enc_lines_array.r_change_flag.DELETE;
	t_enc_lines_array.r_enc_start_date.DELETE;
	t_enc_lines_array.r_enc_end_date.DELETE;
	t_enc_lines_array.r_attribute_category.DELETE;
	t_enc_lines_array.r_attribute1.DELETE;
	t_enc_lines_array.r_attribute2.DELETE;
	t_enc_lines_array.r_attribute3.DELETE;
	t_enc_lines_array.r_attribute4.DELETE;
	t_enc_lines_array.r_attribute5.DELETE;
	t_enc_lines_array.r_attribute6.DELETE;
	t_enc_lines_array.r_attribute7.DELETE;
	t_enc_lines_array.r_attribute8.DELETE;
	t_enc_lines_array.r_attribute9.DELETE;
	t_enc_lines_array.r_attribute10.DELETE;
	t_enc_lines_array.r_orig_gl_code_combination_id.DELETE;
	t_enc_lines_array.r_orig_project_id.DELETE;
	t_enc_lines_array.r_orig_award_id.DELETE;
	t_enc_lines_array.r_orig_task_id.DELETE;
	t_enc_lines_array.r_orig_expenditure_type.DELETE;
	t_enc_lines_array.r_orig_expenditure_org_id.DELETE;
	t_enc_lines_array.r_hierarchy_code.DELETE;
	t_enc_lines_array.r_hierarchy_start_date.DELETE;
	t_enc_lines_array.r_hierarchy_end_date.DELETE;

	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	t_enc_lines_array2.r_enc_element_type_id.COUNT: ' || t_enc_lines_array2.r_enc_element_type_id.COUNT);

	--IF (t_enc_lines_array2.r_enc_element_type_id.COUNT = 0) THEN
		--delete_previous_error_log(p_assignment_id	=>	p_assignment_id,
				--p_payroll_id		=>	p_payroll_id,
				--p_payroll_action_id	=>	g_payroll_action_id);
	--END IF;

	insert_enc_lines_from_arrays	(p_payroll_id		=>	p_payroll_id,
					p_business_group_id	=>	p_business_group_id,
					p_set_of_books_id	=>	p_set_of_books_id,
					p_enc_line_type		=>	'U',
					p_return_status		=>	l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success	THEN
			RAISE fnd_api.g_exc_unexpected_error;
        END IF;

	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Leaving verify_changes
		p_payroll_id: ' || p_payroll_id || ' p_assignment_id: ' || p_assignment_id || '
		p_business_group_id: ' || p_business_group_id || ' p_set_of_books_id: ' || p_set_of_books_id || '
		p_enc_line_type: ' || p_enc_line_type);
	l_retcode := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
	WHEN OTHERS THEN
		IF (g_error_message IS NULL) THEN
			g_error_message := 'VERIFY_CHANGES: ' || SQLERRM;
		END IF;
		g_error_api_path := SUBSTR('VERIFY_CHANGES:' || g_error_api_path,1,230);
		fnd_msg_pub.add_exc_msg('PSP_ENC_UPDATE_LINES', 'VERIFY_CHANGES');
		l_retcode := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving verify_changes
	p_payroll_id: ' || p_payroll_id || '
	p_assignment_id: ' || p_assignment_id || '
	p_business_group_id: ' || p_business_group_id || '
	p_set_of_books_id: ' || p_set_of_books_id || '
	p_enc_line_type: ' || p_enc_line_type);
END verify_changes;

PROCEDURE create_liq_lines	(p_payroll_action_id	IN		NUMBER,
				p_payroll_id		IN		NUMBER,
				p_assignment_id		IN		NUMBER,
				p_enc_begin_date	IN		DATE,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2) IS
l_last_updated_by	NUMBER(15);
l_last_update_login	NUMBER(15);
BEGIN
	l_last_updated_by := fnd_global.user_id;
	l_last_update_login := fnd_global.login_id;

	INSERT INTO psp_enc_summary_lines
		(enc_summary_line_id,	business_group_id,		set_of_books_id,
		enc_control_id,			time_period_id,			person_id,
		assignment_id,			effective_date,			gl_code_combination_id,
		project_id,				task_id,				award_id,
		expenditure_organization_id,	expenditure_type,
		summary_amount,			dr_cr_flag,			status_code,
		payroll_id,			gl_project_flag,		superceded_line_id,
		attribute_category,		attribute1,			attribute2,
		attribute3,			attribute4,			attribute5,
		attribute6,			attribute7,			attribute8,
		attribute9,			attribute10,			payroll_action_id,
		proposed_termination_date,	last_update_date,		last_updated_by,
		last_update_login,		created_by,			creation_date,
		update_flag,			org_id)
	SELECT	psp_enc_summary_lines_s.NEXTVAL,
		p_business_group_id,
		p_set_of_books_id,
		pesl.enc_control_id,
		pesl.time_period_id,
		pesl.person_id,
		pesl.assignment_id,
		pesl.effective_date,
		pesl.gl_code_combination_id,
		pesl.project_id,
		pesl.task_id,
		pesl.award_id,
		pesl.expenditure_organization_id,
		pesl.expenditure_type,
		DECODE(pesl.gl_project_flag, 'G', pesl.summary_amount, -pesl.summary_amount),
		DECODE(pesl.dr_cr_flag, 'C', 'D', 'D', 'C') dr_cr_flag,
		'N',
		pesl.payroll_id,
		pesl.gl_project_flag,
		pesl.enc_summary_line_id,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute_category, NULL) attribute_category,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute1, NULL) attribute1,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute2, NULL) attribute2,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute3, NULL) attribute3,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute4, NULL) attribute4,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute5, NULL) attribute5,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute6, NULL) attribute6,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute7, NULL) attribute7,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute8, NULL) attribute8,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute9, NULL) attribute9,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute10, NULL) attribute10,
		p_payroll_action_id,
		g_actual_term_date,
		SYSDATE,
		l_last_updated_by,
		l_last_update_login,
		l_last_updated_by,
		SYSDATE,
		DECODE(SIGN(TRUNC(effective_date)-TRUNC(p_enc_begin_date)), 1, 'U', 'L'),
		pesl.org_id
	FROM	psp_enc_summary_lines pesl
	WHERE	pesl.assignment_id = p_assignment_id
	AND	pesl.payroll_id = p_payroll_id
	AND	pesl.status_code = 'A'
	AND	pesl.enc_summary_line_id IN	(SELECT	pelh.enc_summary_line_id
			FROM	psp_enc_lines_history pelh
			WHERE	pelh.change_flag  = 'N'
			AND	pelh.assignment_id = p_assignment_id
			AND	pelh.payroll_id = p_payroll_id);
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	No of liquidation lines created: ' || SQL%ROWCOUNT);

	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		IF (g_error_message IS NULL) THEN
			g_error_message := 'CREATE_LIQ_LINES: ' || SQLERRM;
		END IF;
		g_error_api_path := SUBSTR('CREATE_LIQ_LINES:' || g_error_api_path,1,230);
		fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', 'CREATE_LIQ_LINES');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END create_liq_lines;

PROCEDURE create_sum_lines	(p_payroll_action_id	IN		NUMBER,
				p_payroll_id		IN		NUMBER,
				p_assignment_id		IN		NUMBER,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2) IS
l_last_updated_by	NUMBER(15);
l_last_update_login	NUMBER(15);

CURSOR	sum_lines_cur IS
SELECT	pel.enc_control_id,
		pel.time_period_id,
		pel.person_id,
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
		PSP_ORGANIZATION_ACCOUNTS pos,
		pa_projects_all pa
   	WHERE 	pel.ENCUMBRANCE_AMOUNT <> 0
	AND	pel.assignment_id = p_assignment_id
	AND	pel.payroll_id = p_payroll_id
   	AND	pel.suspense_org_account_id = pos.organization_account_id(+)
	AND	pa.project_id (+) = pel.project_id
	AND	pel.payroll_action_id = p_payroll_action_id
	GROUP BY	pel.enc_control_id,
		pel.time_period_id,
		pel.person_id,
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
	enc_control_id				t_num_15_type,
	time_period_id				t_num_15_type,
	person_id					t_num_15_type,
	effective_date				t_date_type,
	gl_code_combination_id		t_num_15_type,
	project_id					t_num_15_type,
	task_id						t_num_15_type,
	award_id					t_num_15_type,
	expenditure_organization_id	t_num_15_type,
	expenditure_type			t_varchar_50_type,
	summary_amount				t_num_10d2_type,
	dr_cr_flag					t_varchar_50_type,
	gl_project_flag				t_varchar_50_type,
	attribute_category			t_varchar_50_type,
	attribute1					t_varchar_150_type,
	attribute2					t_varchar_150_type,
	attribute3					t_varchar_150_type,
	attribute4					t_varchar_150_type,
	attribute5					t_varchar_150_type,
	attribute6					t_varchar_150_type,
	attribute7					t_varchar_150_type,
	attribute8					t_varchar_150_type,
	attribute9					t_varchar_150_type,
	attribute10					t_varchar_150_type,
	org_id						t_num_15_type);
t_sum_lines		sum_lines_rec;
BEGIN
	l_last_updated_by := fnd_global.user_id;
	l_last_update_login := fnd_global.login_id;

	OPEN sum_lines_cur;
	FETCH sum_lines_cur BULK COLLECT INTO t_sum_lines.enc_control_id,
		t_sum_lines.time_period_id,				t_sum_lines.person_id,
		t_sum_lines.effective_date,				t_sum_lines.gl_code_combination_id,
		t_sum_lines.project_id,					t_sum_lines.task_id,
		t_sum_lines.award_id,					t_sum_lines.expenditure_type,
		t_sum_lines.expenditure_organization_id,t_sum_lines.summary_amount,
		t_sum_lines.dr_cr_flag,					t_sum_lines.gl_project_flag,
		t_sum_lines.attribute_category,			t_sum_lines.attribute1,
		t_sum_lines.attribute2,					t_sum_lines.attribute3,
		t_sum_lines.attribute4,					t_sum_lines.attribute5,
		t_sum_lines.attribute6,					t_sum_lines.attribute7,
		t_sum_lines.attribute8,					t_sum_lines.attribute9,
		t_sum_lines.attribute10,				t_sum_lines.org_id;
	CLOSE sum_lines_cur;

	FOR recno IN 1..t_sum_lines.enc_control_id.COUNT
	LOOP
		SELECT psp_enc_summary_lines_s.NEXTVAL INTO t_sum_lines.enc_summary_line_id(recno) FROM DUAL;
	END LOOP;

	FORALL recno IN 1..t_sum_lines.enc_control_id.COUNT
	INSERT INTO psp_enc_summary_lines
		(enc_summary_line_id,			business_group_id,		enc_control_id,
		time_period_id,					person_id,				assignment_id,
		effective_date,					set_of_books_id,		gl_code_combination_id,
		project_id,						task_id,				award_id,
		expenditure_organization_id,	expenditure_type,		summary_amount,
		dr_cr_flag,						status_code,			payroll_id,
		gl_project_flag,
		attribute_category,				attribute1,				attribute2,
		attribute3,						attribute4,				attribute5,
		attribute6,						attribute7,				attribute8,
		attribute9,						attribute10,			payroll_action_id,
		proposed_termination_date,		last_update_date,		last_updated_by,
		last_update_login,				created_by,				creation_date,
		org_id)
	VALUES	(t_sum_lines.enc_summary_line_id(recno),	p_business_group_id,
		t_sum_lines.enc_control_id(recno),				t_sum_lines.time_period_id(recno),
		t_sum_lines.person_id(recno),					p_assignment_id,
		t_sum_lines.effective_date(recno),				p_set_of_books_id,
		t_sum_lines.gl_code_combination_id(recno),		t_sum_lines.project_id(recno),
		t_sum_lines.task_id(recno),						t_sum_lines.award_id(recno),
		t_sum_lines.expenditure_organization_id(recno),	t_sum_lines.expenditure_type(recno),
		t_sum_lines.summary_amount(recno),				t_sum_lines.dr_cr_flag(recno),
		'N',		p_payroll_id,						t_sum_lines.gl_project_flag(recno),
		t_sum_lines.attribute_category(recno),			t_sum_lines.attribute1(recno),
		t_sum_lines.attribute2(recno),					t_sum_lines.attribute3(recno),
		t_sum_lines.attribute4(recno),					t_sum_lines.attribute5(recno),
		t_sum_lines.attribute6(recno),					t_sum_lines.attribute7(recno),
		t_sum_lines.attribute8(recno),					t_sum_lines.attribute9(recno),
		t_sum_lines.attribute10(recno),					p_payroll_action_id,
		g_actual_term_date,								SYSDATE,
		l_last_updated_by,								l_last_update_login,
		l_last_updated_by,								SYSDATE,
		t_sum_lines.org_id(recno));
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	No of Summary lines created (t_sum_lines.enc_control_id.COUNT): ' || t_sum_lines.enc_control_id.COUNT);

	IF (g_dff_grouping_option = 'Y') THEN
		FORALL recno IN 1..t_sum_lines.enc_summary_line_id.COUNT
		UPDATE	psp_enc_lines pel
		SET		enc_summary_line_id =	t_sum_lines.enc_summary_line_id(recno)
		WHERE	payroll_action_id = p_payroll_action_id
		AND		pel.assignment_id = p_assignment_id
		AND		pel.payroll_id = p_payroll_id
		AND		pel.enc_control_id = t_sum_lines.enc_control_id(recno)
		AND		pel.time_period_id = t_sum_lines.time_period_id(recno)
		AND		pel.person_id = t_sum_lines.person_id(recno)
		AND		pel.encumbrance_date = t_sum_lines.effective_date(recno)
		AND		NVL(pel.gl_code_combination_id, -99) = NVL(t_sum_lines.gl_code_combination_id(recno), -99)
		AND		NVL(pel.project_id, -99) = NVL(t_sum_lines.project_id(recno), -99)
		AND		NVL(pel.task_id, -99) = NVL(t_sum_lines.task_id(recno), -99)
		AND		NVL(pel.award_id, -99) = NVL(t_sum_lines.award_id(recno), -99)
		AND		NVL(pel.expenditure_type, 'NULL') = NVL(t_sum_lines.expenditure_type(recno), 'NULL')
		AND		NVL(pel.expenditure_organization_id, -99) = NVL(t_sum_lines.expenditure_organization_id(recno), -99)
		AND		pel.dr_cr_flag = t_sum_lines.dr_cr_flag(recno)
		AND		pel.gl_project_flag = t_sum_lines.gl_project_flag(recno)
		AND		NVL(pel.attribute_category, 'NULL') = NVL(t_sum_lines.attribute_category(recno), 'NULL')
		AND		NVL(pel.attribute1, 'NULL') = NVL(t_sum_lines.attribute1(recno), 'NULL')
		AND		NVL(pel.attribute2, 'NULL') = NVL(t_sum_lines.attribute2(recno), 'NULL')
		AND		NVL(pel.attribute3, 'NULL') = NVL(t_sum_lines.attribute3(recno), 'NULL')
		AND		NVL(pel.attribute4, 'NULL') = NVL(t_sum_lines.attribute4(recno), 'NULL')
		AND		NVL(pel.attribute5, 'NULL') = NVL(t_sum_lines.attribute5(recno), 'NULL')
		AND		NVL(pel.attribute6, 'NULL') = NVL(t_sum_lines.attribute6(recno), 'NULL')
		AND		NVL(pel.attribute7, 'NULL') = NVL(t_sum_lines.attribute7(recno), 'NULL')
		AND		NVL(pel.attribute8, 'NULL') = NVL(t_sum_lines.attribute8(recno), 'NULL')
		AND		NVL(pel.attribute9, 'NULL') = NVL(t_sum_lines.attribute9(recno), 'NULL')
		AND		NVL(pel.attribute10, 'NULL') = NVL(t_sum_lines.attribute10(recno), 'NULL');
	ELSE
		FORALL recno IN 1..t_sum_lines.enc_summary_line_id.COUNT
		UPDATE	psp_enc_lines pel
		SET		enc_summary_line_id =	t_sum_lines.enc_summary_line_id(recno)
		WHERE	payroll_action_id = p_payroll_action_id
		AND		pel.assignment_id = p_assignment_id
		AND		pel.payroll_id = p_payroll_id
		AND		pel.enc_control_id = t_sum_lines.enc_control_id(recno)
		AND		pel.time_period_id = t_sum_lines.time_period_id(recno)
		AND		pel.person_id = t_sum_lines.person_id(recno)
		AND		pel.encumbrance_date = t_sum_lines.effective_date(recno)
		AND		NVL(pel.gl_code_combination_id, -99) = NVL(t_sum_lines.gl_code_combination_id(recno), -99)
		AND		NVL(pel.project_id, -99) = NVL(t_sum_lines.project_id(recno), -99)
		AND		NVL(pel.task_id, -99) = NVL(t_sum_lines.task_id(recno), -99)
		AND		NVL(pel.award_id, -99) = NVL(t_sum_lines.award_id(recno), -99)
		AND		NVL(pel.expenditure_type, 'NULL') = NVL(t_sum_lines.expenditure_type(recno), 'NULL')
		AND		NVL(pel.expenditure_organization_id, -99) = NVL(t_sum_lines.expenditure_organization_id(recno), -99)
		AND		pel.dr_cr_flag = t_sum_lines.dr_cr_flag(recno)
		AND		pel.gl_project_flag = t_sum_lines.gl_project_flag(recno);
	END IF;
	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		IF (g_error_message IS NULL) THEN
			g_error_message := 'CREATE_SUM_LINES: ' || SQLERRM;
		END IF;
		g_error_api_path := SUBSTR('CREATE_SUM_LINES:' || g_error_api_path,1,230);
		fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', 'CREATE_SUM_LINES');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END create_sum_lines;

PROCEDURE enc_pre_process	(p_payroll_action_id	IN		NUMBER,
				p_payroll_id		IN		NUMBER,
				p_process_mode		IN		VARCHAR2,
				p_return_status		OUT NOCOPY	VARCHAR2) IS
l_new_cust		NUMBER;
l_pre_process_mode	CHAR(1);
l_inc_exc_flag		CHAR(1);
l_business_group_id	NUMBER(15);
l_set_of_books_id	NUMBER(15);
l_request_id		NUMBER(15);
l_count			NUMBER(15);
l_enc_begin_date	DATE;
l_return_status		VARCHAR2(1);
l_assignment_id		NUMBER(15);
l_payroll_action_id	NUMBER(15);
l_payroll_id		NUMBER(15);
l_person_id		NUMBER(15);
l_organization_id	NUMBER(15);
l_assignment_number	per_all_assignments_f.assignment_number%TYPE;
l_payroll_name		pay_all_payrolls_f.payroll_name%TYPE;
l_full_name		per_all_people_f.full_name%TYPE;
l_organization_name	hr_organization_units.name%TYPE;
l_process_description	fnd_concurrent_programs_tl.user_concurrent_program_name%TYPE;
l_process_mode		VARCHAR2(15);
l_person_id1		NUMBER(15);
l_termination_date1	DATE;
l_person_id2		NUMBER(15);
l_termination_date2	DATE;
l_person_id3		NUMBER(15);
l_termination_date3	DATE;
l_person_id4		NUMBER(15);
l_termination_date4	DATE;
l_person_id5		NUMBER(15);
l_termination_date5	DATE;

CURSOR	new_cust_cur IS
SELECT	COUNT(1)
FROM	psp_enc_controls
WHERE	ROWNUM = 1;

CURSOR	action_parameters_cur IS
SELECT	fnd_number.canonical_to_number(NVL(argument13, '-1')),
	fnd_date.canonical_to_date(NVL(argument14, fnd_date.date_to_canonical(TRUNC(SYSDATE)))),
	fnd_number.canonical_to_number(NVL(argument15, '-1')),
	fnd_date.canonical_to_date(NVL(argument16, fnd_date.date_to_canonical(TRUNC(SYSDATE)))),
	fnd_number.canonical_to_number(NVL(argument17, '-1')),
	fnd_date.canonical_to_date(NVL(argument18, fnd_date.date_to_canonical(TRUNC(SYSDATE)))),
	fnd_number.canonical_to_number(NVL(argument19, '-1')),
	fnd_date.canonical_to_date(NVL(argument20, fnd_date.date_to_canonical(TRUNC(SYSDATE)))),
	fnd_number.canonical_to_number(NVL(argument21, '-1')),
	fnd_date.canonical_to_date(NVL(argument22, fnd_date.date_to_canonical(TRUNC(SYSDATE))))
FROM	psp_enc_processes pep,
	fnd_concurrent_requests fcr
WHERE	pep.payroll_action_id = p_payroll_action_id
AND	fcr.request_id = pep.request_id;

CURSOR	enc_payroll_cur IS
SELECT	pep.inc_exc_flag
FROM	psp_enc_payrolls pep
WHERE	pep.payroll_id        = p_payroll_id
AND	pep.business_group_id = l_business_group_id
AND	pep.set_of_books_id   = l_set_of_books_id;

/* Bug 5642002: Replaced earned date with period end date */
CURSOR	c_last_pay_run IS
SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
FROM	pay_payroll_actions ppa,
        pay_assignment_actions paa,
        per_time_periods ptp
WHERE 	ppa.payroll_action_id = paa.payroll_action_id (+)
AND     ppa.business_group_id = l_business_group_id
AND	ppa.payroll_id = p_payroll_id
AND   	ppa.action_type	IN ( 'R','Q')
AND	NVL(paa.action_status, ppa.action_status) = 'C'
and     ppa.date_earned between ptp.start_date and ptp.end_date
and     ptp.payroll_id = ppa.payroll_id;

CURSOR	c_tp_start_date IS
SELECT	MIN(ptp.start_date)
FROM	per_time_periods ptp
WHERE	ptp.payroll_id= p_payroll_id;

CURSOR	asg_number_cur (p_start_date	IN	DATE) IS
SELECT	assignment_number,
	person_id,
	organization_id
FROM	per_all_assignments_f
WHERE	assignment_id = l_assignment_id
AND	payroll_id = NVL(l_payroll_id, p_payroll_id)
AND	effective_end_date >= p_start_date
AND	ROWNUM = 1;

CURSOR	payroll_name_cur IS
SELECT	payroll_name
FROM	pay_all_payrolls_f
WHERE	payroll_id = p_payroll_id
AND	business_group_id = g_business_group_id
AND	gl_set_of_books_id = g_set_of_books_id
AND	ROWNUM = 1;

CURSOR	person_name_cur (p_start_date	IN	DATE) IS
SELECT	full_name
FROM	per_all_people_f
WHERE	person_id = l_person_id
AND	effective_end_date >= p_start_date
AND	ROWNUM = 1;

CURSOR	org_name_cur IS
SELECT	name
FROM	hr_organization_units
WHERE	organization_id = l_organization_id;

CURSOR	process_descr_cur IS
SELECT	pep.request_id || ': ' || fcpt.user_concurrent_program_name
FROM	psp_enc_processes pep,
	fnd_concurrent_requests fcr,
	fnd_concurrent_programs_tl fcpt
WHERE	EXISTS	(SELECT	1
		FROM	psp_enc_summary_lines pesl
		WHERE	pesl.payroll_action_id = pep.payroll_action_id
		AND	pesl.payroll_action_id = l_payroll_action_id)
AND	fcr.request_id = pep.request_id
AND	fcpt.concurrent_program_id = fcr.concurrent_program_id
AND	fcpt.language = USERENV('LANG')
ORDER BY DECODE(pep.process_code, 'LET', 1, 'ST', 2, 3);

CURSOR	in_process_term_cur (p_person_id IN NUMBER) IS
SELECT	DISTINCT assignment_id,
	payroll_id,
	payroll_action_id
FROM	psp_enc_summary_lines pesl
WHERE	pesl.person_id = p_person_id
AND	pesl.status_code = 'N';

CURSOR	in_process_asg_cur IS
SELECT	pepa.assignment_id,
	pepa.payroll_action_id
FROM	psp_enc_process_assignments pepa
WHERE	pepa.payroll_id = p_payroll_id
AND	pepa.assignment_status NOT IN ('B', 'P');

l_prev_enc_end_date   PSP_ENC_END_DATES_V.prev_enc_end_date%TYPE;  -- Bug 7188209

BEGIN
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Entering ENC_PRE_PROCESS
	p_payroll_action_id: ' || p_payroll_action_id || '
	p_payroll_id: ' || p_payroll_id || '
	p_process_mode: ' || p_process_mode);

	l_request_id := FND_GLOBAL. CONC_REQUEST_ID;
	l_set_of_books_id :=  FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
	l_business_group_id  := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	l_request_id: ' || l_request_id ||'
	l_set_of_books_id: ' || l_set_of_books_id || '
	l_business_group_id: ' || l_business_group_id);

	IF (p_process_mode = 'REGULAR') THEN
		OPEN new_cust_cur;
		FETCH new_cust_cur INTO l_new_cust;
		CLOSE new_cust_cur;

		OPEN c_last_pay_run;
		FETCH c_last_pay_run INTO l_enc_begin_date;
		CLOSE c_last_pay_run;

		IF (l_enc_begin_date IS NULL) THEN
			OPEN c_tp_start_date;
			FETCH c_tp_start_date INTO l_enc_begin_date;
			CLOSE c_tp_start_date;
		END IF;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	l_enc_begin_date: ' || fnd_date.date_to_canonical(l_enc_begin_date));

		l_pre_process_mode := 'R';
		IF (l_new_cust = 0 AND psp_general.start_capturing_updates(l_business_group_id) = 'N') THEN
			l_pre_process_mode := 'F';
		END IF;

		psp_enc_pre_process.poeta_pre_process
		 	 	 (p_pre_process_mode	=>	l_pre_process_mode,
				p_payroll_id		=>	p_payroll_id,
				p_business_group_id	=>	l_business_group_id,
				p_set_of_books_id	=>	l_set_of_books_id,
				p_return_status		=>	l_return_status);
		IF l_return_status <> fnd_api.g_ret_sts_success THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Completed psp_enc_pre_process.poeta_pre_process');

		IF (l_pre_process_mode <>'F') THEN
			psp_enc_pre_process.labor_schedule_pre_process
				(p_enc_line_type	=>	'U',
				p_payroll_id	=>	p_payroll_id,
				p_return_status	=>	l_return_status);

			IF l_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Completed psp_enc_pre_process.labor_schedule_pre_process');
		END IF;

		OPEN enc_payroll_cur;
		FETCH enc_payroll_cur INTO l_inc_exc_flag;
		CLOSE enc_payroll_cur;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	l_inc_exc_flag: ' || l_inc_exc_flag);

		-- Bug 7188209
		select prev_enc_end_date into l_prev_enc_end_date
		 from PSP_ENC_END_DATES_V
		 where business_group_id = l_business_group_id
		 and set_of_books_id = l_set_of_books_id;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '				l_prev_enc_end_date = ' || l_prev_enc_end_date);


		IF l_inc_exc_flag = 'Y' THEN

			INSERT INTO psp_enc_changed_assignments
				(request_id, payroll_id, assignment_id, change_type, payroll_action_id)
			SELECT	DISTINCT l_request_id, p_payroll_id, pa.assignment_id, 'CR', p_payroll_action_id
			FROM	per_assignments_f pa
			WHERE	pa.payroll_id = p_payroll_id
			AND	pa.assignment_type = 'E'
			AND	pa.business_group_id = l_business_group_id
			-- AND	pa.effective_end_date >= l_enc_begin_date
			-- Bug 5642002: Replaced last Payroll Process date with last assignment Process date
			AND	pa.effective_end_date >= (NVL((SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
					FROM	pay_payroll_actions ppa,
						pay_assignment_actions paa,
						per_time_periods ptp
					WHERE	paa.assignment_id(+) = pa.assignment_id
					AND	ppa.payroll_action_id = paa.payroll_action_id (+)
					AND	ppa.business_group_id = pa.business_group_id
					AND	ppa.payroll_id = pa.payroll_id
					AND	ppa.action_type	IN ( 'R','Q')
					AND	paa.action_status(+) = 'C'
					and ppa.date_earned between ptp.start_date and ptp.end_date
					and ptp.payroll_id = ppa.payroll_id),l_enc_begin_date))
			AND	NOT EXISTS	(SELECT	pepa.assignment_id
					FROM	psp_enc_payroll_assignments pepa,
						psp_enc_payrolls pep
					WHERE	pepa.enc_payroll_id = pep.enc_payroll_id
					AND	pepa.business_group_id = l_business_group_id
					AND	pepa.set_of_books_id = l_set_of_books_id
					AND	pepa.business_group_id = pep.business_group_id
					AND	pepa.set_of_books_id = pep.set_of_books_id
					AND	pep.payroll_id = p_payroll_id
					AND	pepa.assignment_id = pa.assignment_id)
			AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_changed_assignments peca
					WHERE	peca.assignment_id = pa.assignment_id
					AND	peca.payroll_id = p_payroll_id)
			AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.assignment_id = pa.assignment_id
					AND	pesl.status_code IN ('A', 'N')
					-- Bug 5642002: Replaced last Payroll Process date with last assignment Process date
					AND	pesl.effective_date > (NVL((SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
							FROM	pay_payroll_actions ppa,
								pay_assignment_actions paa,
								per_time_periods ptp
							WHERE	paa.assignment_id(+) = pesl.assignment_id
							AND	ppa.payroll_action_id = paa.payroll_action_id (+)
							AND	ppa.business_group_id = pesl.business_group_id
							AND	ppa.payroll_id = pesl.payroll_id
							AND	ppa.action_type	IN ( 'R','Q')
							AND	paa.action_status(+) = 'C'
							and     ppa.date_earned between ptp.start_date and ptp.end_date
							and     ptp.payroll_id = ppa.payroll_id),l_enc_begin_date))
					AND	pesl.payroll_id = p_payroll_id);

			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '10-A	Inserted ' || SQL%ROWCOUNT || ' assignments into psp_enc_changed_assignments');


--                      Added this INSERT for bug 7188209

			INSERT INTO psp_enc_changed_assignments
				(request_id, payroll_id, assignment_id, change_type, payroll_action_id)
			SELECT	DISTINCT l_request_id, p_payroll_id, pa.assignment_id, 'CR', p_payroll_action_id
			FROM	per_assignments_f pa
			WHERE	pa.payroll_id = p_payroll_id
			AND	pa.assignment_type = 'E'
			AND	pa.business_group_id = l_business_group_id
			AND	pa.effective_end_date >= (NVL((SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
								   FROM	pay_payroll_actions ppa,
								        pay_assignment_actions paa,
								        per_time_periods ptp
								   WHERE paa.assignment_id(+) = pa.assignment_id
								   and ppa.payroll_action_id = paa.payroll_action_id (+)
								   and ppa.business_group_id = pa.business_group_id
								   AND	ppa.payroll_id	= pa.payroll_id
								   AND 	ppa.action_type	IN ( 'R','Q')
								   AND	paa.action_status(+) = 'C'
								   and ppa.date_earned between ptp.start_date and ptp.end_date
								   and ptp.payroll_id = ppa.payroll_id),l_enc_begin_date))
			AND	NOT EXISTS	(SELECT	pepa.assignment_id
					FROM	psp_enc_payroll_assignments pepa,
						psp_enc_payrolls pep
					WHERE	pepa.enc_payroll_id = pep.enc_payroll_id
					AND	pepa.business_group_id = l_business_group_id
					AND	pepa.set_of_books_id = l_set_of_books_id
					AND	pepa.business_group_id = pep.business_group_id
					AND	pepa.set_of_books_id = pep.set_of_books_id
					AND	pep.payroll_id = p_payroll_id
					AND	pepa.assignment_id = pa.assignment_id)
			AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_changed_assignments peca
					WHERE	peca.assignment_id = pa.assignment_id
					AND	peca.payroll_id = p_payroll_id)
			AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.assignment_id = pa.assignment_id
					AND	pesl.status_code IN ('A', 'N')
					AND	pesl.effective_date > l_prev_enc_end_date
					AND	pesl.payroll_id = p_payroll_id);

			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '10-B	Inserted ' || SQL%ROWCOUNT || ' assignments into psp_enc_changed_assignments');

			INSERT INTO psp_enc_changed_assignments
				(request_id, payroll_id, assignment_id, change_type, payroll_action_id)
			SELECT	DISTINCT l_request_id, p_payroll_id, pa.assignment_id, 'ZZ', p_payroll_action_id
			FROM	per_assignments_f pa
			WHERE	pa.payroll_id = p_payroll_id
			AND	pa.assignment_type = 'E'
			AND	pa.business_group_id = l_business_group_id
			AND	pa.effective_end_date >= l_enc_begin_date
			-- Bug 5642002: Replaced last Payroll Process date with last assignment Process date
			AND	pa.effective_end_date >= (NVL((SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
					FROM	pay_payroll_actions ppa,
						pay_assignment_actions paa,
						per_time_periods ptp
					WHERE	paa.assignment_id(+) = pa.assignment_id
					AND	ppa.payroll_action_id = paa.payroll_action_id (+)
					AND	ppa.business_group_id = pa.business_group_id
					AND	ppa.payroll_id = pa.payroll_id
					AND	ppa.action_type	IN ( 'R','Q')
					AND	paa.action_status(+) = 'C'
					and 	ppa.date_earned between ptp.start_date and ptp.end_date
					and 	ptp.payroll_id = ppa.payroll_id),l_enc_begin_date))
			AND	EXISTS	(SELECT	pepa.assignment_id
					FROM	psp_enc_payroll_assignments pepa,
						psp_enc_payrolls pep
					WHERE	pepa.enc_payroll_id = pep.enc_payroll_id
					AND	pepa.business_group_id = l_business_group_id
					AND	pepa.set_of_books_id = l_set_of_books_id
					AND	pepa.business_group_id = pep.business_group_id
					AND	pepa.set_of_books_id = pep.set_of_books_id
					AND	pep.payroll_id = p_payroll_id
					AND	pepa.assignment_id = pa.assignment_id)
			AND	EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.assignment_id = pa.assignment_id
					AND	pesl.status_code  = 'A'
					AND	pesl.payroll_id = p_payroll_id)
			AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.assignment_id = pa.assignment_id
					AND	pesl.status_code = 'N'
					AND	pesl.payroll_id = p_payroll_id);

			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '20	Inserted ' || SQL%ROWCOUNT || ' assignments into psp_enc_changed_assignments');

		ELSE

			INSERT INTO psp_enc_changed_assignments
				(request_id, payroll_id, assignment_id, change_type, payroll_action_id)
			SELECT	DISTINCT l_request_id, p_payroll_id, pa.assignment_id, 'CR', p_payroll_action_id
			FROM	psp_enc_payroll_assignments pepa,
				psp_enc_payrolls  pep,
				per_assignments_f pa
			WHERE	pa.payroll_id          = p_payroll_id
			AND	pepa.business_group_id  = l_business_group_id
			AND	pepa.set_of_books_id    = l_set_of_books_id
			AND	pepa.assignment_id      = pa.assignment_id
			AND	pa.effective_end_date >= l_enc_begin_date
			-- Bug 5642002: Replaced last Payroll Process date with last assignment Process date
			AND	pa.effective_end_date >= (NVL((SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
					FROM	pay_payroll_actions ppa,
						pay_assignment_actions paa,
						per_time_periods ptp
					WHERE	paa.assignment_id(+) = pa.assignment_id
					AND	ppa.payroll_action_id = paa.payroll_action_id (+)
					AND	ppa.business_group_id = pa.business_group_id
					AND	ppa.payroll_id = pa.payroll_id
					AND	ppa.action_type	IN ( 'R','Q')
					AND	paa.action_status(+) = 'C'
					and     ppa.date_earned between ptp.start_date and ptp.end_date
					and 	ptp.payroll_id = ppa.payroll_id),l_enc_begin_date))
			AND	pep.payroll_id          = p_payroll_id
			AND	pep.enc_payroll_id      = pepa.enc_payroll_id
			AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_changed_assignments peca
					WHERE	peca.assignment_id = pepa.assignment_id
					AND	peca.payroll_id = p_payroll_id)
			AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.assignment_id = pa.assignment_id
					AND	pesl.status_code IN ('A', 'N')
					-- Bug 5642002: Replaced last Payroll Process date with last assignment Process date
					AND	pesl.effective_date > (NVL((SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
							FROM	pay_payroll_actions ppa,
								pay_assignment_actions paa,
								per_time_periods ptp
							WHERE	paa.assignment_id(+) = pesl.assignment_id
							AND	ppa.payroll_action_id = paa.payroll_action_id (+)
							AND	ppa.time_period_id = ptp.time_period_id
							AND	ppa.business_group_id = pesl.business_group_id
							AND	ppa.payroll_id = pesl.payroll_id
							AND	ppa.action_type	IN ( 'R','Q')
							AND	paa.action_status(+) = 'C'),l_enc_begin_date)) );

			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '30-A	Inserted ' || SQL%ROWCOUNT || ' assignments into psp_enc_changed_assignments');

--			Added for bug 7188209
			INSERT INTO psp_enc_changed_assignments
				(request_id, payroll_id, assignment_id, change_type, payroll_action_id)
			SELECT	DISTINCT l_request_id, p_payroll_id, pa.assignment_id, 'CR', p_payroll_action_id
			FROM	psp_enc_payroll_assignments pepa,
				psp_enc_payrolls pep,
				per_assignments_f pa
			WHERE	pa.payroll_id	= p_payroll_id
			AND	pepa.business_group_id = l_business_group_id
			AND	pepa.set_of_books_id	= l_set_of_books_id
			AND	pepa.assignment_id	= pa.assignment_id
			AND	pa.effective_end_date >= (NVL((SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
								   FROM	pay_payroll_actions ppa,
									pay_assignment_actions paa,
									per_time_periods ptp
								   WHERE paa.assignment_id(+)= pa.assignment_id
								   and ppa.payroll_action_id = paa.payroll_action_id  (+)
								   and ppa.business_group_id = pa.business_group_id
								   AND ppa.payroll_id	= pa.payroll_id
								   AND ppa.action_type	IN ( 'R','Q')
								   AND paa.action_status(+) = 'C'
								   and ppa.date_earned between ptp.start_date and ptp.end_date
								   and ptp.payroll_id = ppa.payroll_id),l_enc_begin_date))
			AND	pep.payroll_id	= p_payroll_id
			AND	pep.enc_payroll_id	= pepa.enc_payroll_id
			AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_changed_assignments peca
					WHERE	peca.assignment_id = pepa.assignment_id
					AND	peca.payroll_id = p_payroll_id)
			AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.assignment_id = pa.assignment_id
					AND	pesl.status_code IN ('A', 'N')
					AND	pesl.effective_date > l_prev_enc_end_date);

			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '30-B	Inserted ' || SQL%ROWCOUNT || ' assignments into psp_enc_changed_assignments');

			INSERT INTO psp_enc_changed_assignments
				(request_id, payroll_id, assignment_id, change_type, payroll_action_id)
			SELECT	DISTINCT l_request_id, p_payroll_id, pa.assignment_id, 'ZZ', p_payroll_action_id
			FROM	per_assignments_f pa
			WHERE	pa.payroll_id = p_payroll_id
			AND	pa.assignment_type = 'E'
			AND	pa.business_group_id = l_business_group_id
			AND	pa.effective_end_date >= l_enc_begin_date
			-- Bug 5642002: Replaced last Payroll Process date with last assignment Process date
			AND	pa.effective_end_date >= (NVL((SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
					FROM	pay_payroll_actions ppa,
						pay_assignment_actions paa,
						per_time_periods ptp
					WHERE	paa.assignment_id(+) = pa.assignment_id
					AND	ppa.payroll_action_id = paa.payroll_action_id (+)
					AND	ppa.business_group_id = pa.business_group_id
					AND	ppa.payroll_id = pa.payroll_id
					AND	ppa.action_type	IN ( 'R','Q')
					AND	paa.action_status(+) = 'C'
					and 	ppa.date_earned between ptp.start_date and ptp.end_date
					and 	ptp.payroll_id = ppa.payroll_id),l_enc_begin_date))
			AND	NOT EXISTS	(SELECT	pepa.assignment_id
					FROM	psp_enc_payroll_assignments pepa,
						psp_enc_payrolls pep
					WHERE	pepa.enc_payroll_id = pep.enc_payroll_id
					AND	pepa.business_group_id = l_business_group_id
					AND	pepa.set_of_books_id = l_set_of_books_id
					AND	pepa.business_group_id = pep.business_group_id
					AND	pepa.set_of_books_id = pep.set_of_books_id
					AND	pep.payroll_id = p_payroll_id
					AND	pepa.assignment_id = pa.assignment_id)
			AND	EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.assignment_id = pa.assignment_id
					AND	pesl.status_code  = 'A'
					AND	pesl.payroll_id = p_payroll_id)
			AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.assignment_id = pa.assignment_id
					AND	pesl.status_code = 'N'
					AND	pesl.payroll_id = p_payroll_id);
			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '40	Inserted ' || SQL%ROWCOUNT || ' assignments into psp_enc_changed_assignments');
		END IF;

		INSERT INTO psp_enc_changed_assignments
			(request_id, payroll_id, assignment_id, change_type, payroll_action_id)
		SELECT	DISTINCT l_request_id, p_payroll_id, assignment_id, 'LQ', p_payroll_action_id
		FROM	psp_enc_summary_lines pesl
		WHERE	payroll_id = p_payroll_id
		AND	business_group_id = l_business_group_id
		AND	status_code = 'A'
		AND	effective_date <= l_enc_begin_date
			-- Bug 5642002: Replaced last Payroll Process date with last assignment Process date
		AND	pesl.effective_date <= (NVL((SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
				FROM	pay_payroll_actions ppa,
					pay_assignment_actions paa,
					per_time_periods ptp
				WHERE	paa.assignment_id(+) = pesl.assignment_id
				AND	ppa.payroll_action_id = paa.payroll_action_id (+)
				AND	ppa.business_group_id = pesl.business_group_id
				AND	ppa.payroll_id = pesl.payroll_id
				AND	ppa.action_type	IN ( 'R','Q')
				AND	paa.action_status(+) = 'C'
				and 	ppa.date_earned between ptp.start_date and ptp.end_date
				and  	ptp.payroll_id = ppa.payroll_id),l_enc_begin_date))
		AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_changed_assignments peca
				WHERE	peca.assignment_id = pesl.assignment_id
				AND	peca.payroll_id = p_payroll_id)
		AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl2
				WHERE	pesl2.assignment_id = pesl.assignment_id
				AND	pesl2.status_code = 'N'
					-- Bug 5642002: Replaced last Payroll Process date with last assignment Process date
				AND	pesl2.effective_date <= (NVL((SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
						FROM	pay_payroll_actions ppa,
							pay_assignment_actions paa,
							per_time_periods ptp
						WHERE	paa.assignment_id(+) = pesl2.assignment_id
						AND	ppa.payroll_action_id = paa.payroll_action_id (+)
						AND	ppa.business_group_id = pesl2.business_group_id
						AND	ppa.payroll_id = pesl2.payroll_id
						AND	ppa.action_type	IN ( 'R','Q')
						AND	paa.action_status(+) = 'C'
						and 	ppa.date_earned between ptp.start_date and ptp.end_date
						and 	ptp.payroll_id = ppa.payroll_id),l_enc_begin_date))
				AND	pesl2.payroll_id = p_payroll_id);

			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '50	Inserted ' || SQL%ROWCOUNT || ' assignments into psp_enc_changed_assignments');

		UPDATE	psp_enc_changed_assignments peca
		SET	payroll_action_id = p_payroll_action_id
		WHERE	payroll_action_id IS NULL
		AND	payroll_id = NVL(p_payroll_id, payroll_id)
		AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_process_assignments pepa
				WHERE	pepa.assignment_id = peca.assignment_id
				AND	pepa.assignment_status NOT IN ('B', 'P')
				AND	pepa.payroll_id = peca.payroll_id);
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Marked ' || SQL%ROWCOUNT || ' assignments in psp_enc_changed_assignments to be processed by this Create and Update process');

		DELETE FROM psp_enc_changed_assignments
		WHERE payroll_action_id = p_payroll_action_id
		AND   payroll_id = p_payroll_id
		AND   request_id = l_request_id
		and assignment_id IN(SELECT assignment_id from PSP_ENC_PAYROLL_ASSIGNMENT_V
			     	     WHERE payroll_id = p_payroll_id
			     	     AND exclude = 'Y'
			     	     MINUS
			     	     SELECT ASSIGNMENT_ID FROM psp_enc_changed_asg_history
			     	     WHERE payroll_id = p_payroll_id);

		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Deleted ' || SQL%ROWCOUNT || ' fresh excluded assignments in psp_enc_changed_assignments not to be processed by this Create and Update process');

		OPEN in_process_asg_cur;
		LOOP
			FETCH in_process_asg_cur INTO l_assignment_id, l_payroll_action_id;
			EXIT WHEN in_process_asg_cur%NOTFOUND;

			OPEN process_descr_cur;
			FETCH process_descr_cur INTO l_process_description;
			CLOSE process_descr_cur;

			fnd_message.set_name('PSP', 'PSP_ENC_ASG_IN_PROCESS');
			fnd_message.set_token('PROCESS_DESCRIPTION', l_process_description);
			g_warning_message := fnd_message.get;

			OPEN asg_number_cur (l_enc_begin_date);
			FETCH asg_number_cur INTO l_assignment_number, l_person_id, l_organization_id;
			CLOSE asg_number_cur;

			OPEN payroll_name_cur;
			FETCH payroll_name_cur INTO l_payroll_name;
			CLOSE payroll_name_cur;

			OPEN person_name_cur (l_enc_begin_date);
			FETCH person_name_cur INTO l_full_name;
			CLOSE person_name_cur;

			OPEN org_name_cur;
			FETCH org_name_cur INTO l_organization_name;
			CLOSE org_name_cur;

			psp_general.add_report_error
				(p_request_id		=>	l_request_id,
				p_message_level		=>	'N',
				p_source_id		=>	l_assignment_id,
				p_source_name		=>	l_assignment_number,
				p_parent_source_id	=>	l_person_id,
				p_parent_source_name	=>	l_full_name,
				p_error_message		=>	g_warning_message,
				p_payroll_action_id	=>	p_payroll_action_id,
				p_value1		=>	p_payroll_id,
				p_information1		=>	l_payroll_name,
				p_value2		=>	l_organization_id,
				p_information2		=>	l_organization_name,
				p_return_status		=>	l_return_status);
		END LOOP;
		CLOSE in_process_asg_cur;
	ELSE
		OPEN action_parameters_cur;
		FETCH action_parameters_cur INTO l_person_id1, l_termination_date1,
				l_person_id2, l_termination_date2, l_person_id3, l_termination_date3,
				l_person_id4, l_termination_date4, l_person_id5, l_termination_date5;
		CLOSE action_parameters_cur;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	l_person_id1: ' || l_person_id1 || ' l_termination_date1: ' || fnd_date.date_to_canonical(l_termination_date1) || '
	l_person_id2: ' || l_person_id2 || ' l_termination_date2: ' || fnd_date.date_to_canonical(l_termination_date2) || '
	l_person_id3: ' || l_person_id3 || ' l_termination_date3: ' || fnd_date.date_to_canonical(l_termination_date3) || '
	l_person_id4: ' || l_person_id4 || ' l_termination_date4: ' || fnd_date.date_to_canonical(l_termination_date4) || '
	l_person_id5: ' || l_person_id5 || ' l_termination_date5: ' || fnd_date.date_to_canonical(l_termination_date5));

		INSERT INTO PSP_ENC_CHANGED_ASSIGNMENTS
			(request_id, assignment_id, payroll_id, change_type, payroll_action_id, change_date)
		SELECT	DISTINCT l_request_id,
			pesl.assignment_id,
			pesl.payroll_id,
			'TR',
			p_payroll_action_id,
			l_termination_date1
		FROM	psp_enc_summary_lines pesl
		WHERE	pesl.person_id = l_person_id1
		AND	pesl.effective_date >= l_termination_date1
		AND	pesl.award_id IS NOT NULL
		AND	pesl.status_code = 'A'
		AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl2
					WHERE	pesl2.person_id = l_person_id1
				AND	pesl2.status_code = 'N');
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Inserted termination assignments into psp_enc_changed_assignments ' || SQL%ROWCOUNT);
		IF (SQL%ROWCOUNT = 0) THEN
			OPEN in_process_term_cur(l_person_id1);
			LOOP
				FETCH in_process_term_cur INTO l_assignment_id, l_payroll_id, l_payroll_action_id;
				EXIT WHEN in_process_term_cur%NOTFOUND;

				OPEN process_descr_cur;
				FETCH process_descr_cur INTO l_process_description;
				CLOSE process_descr_cur;

				fnd_message.set_name('PSP', 'PSP_ENC_ASG_IN_PROCESS');
				fnd_message.set_token('PROCESS_DESCRIPTION', l_process_description);
				g_warning_message := fnd_message.get;

				OPEN asg_number_cur (l_termination_date1);
				FETCH asg_number_cur INTO l_assignment_number, l_person_id, l_organization_id;
				CLOSE asg_number_cur;

				OPEN payroll_name_cur;
				FETCH payroll_name_cur INTO l_payroll_name;
				CLOSE payroll_name_cur;

				OPEN person_name_cur (l_termination_date1);
				FETCH person_name_cur INTO l_full_name;
				CLOSE person_name_cur;

				OPEN org_name_cur;
				FETCH org_name_cur INTO l_organization_name;
				CLOSE org_name_cur;

				psp_general.add_report_error
					(p_request_id		=>	l_request_id,
					p_message_level		=>	'N',
					p_source_id		=>	l_assignment_id,
					p_source_name		=>	l_assignment_number,
					p_parent_source_id	=>	l_person_id,
					p_parent_source_name	=>	l_full_name,
					p_error_message		=>	g_warning_message,
					p_payroll_action_id	=>	p_payroll_action_id,
					p_value1		=>	l_payroll_id,
					p_information1		=>	l_payroll_name,
					p_value2		=>	l_organization_id,
					p_information2		=>	l_organization_name,
					p_return_status		=>	l_return_status);
			END LOOP;
			CLOSE in_process_term_cur;
		END IF;

		IF (l_person_id2 > 0) THEN
			INSERT INTO PSP_ENC_CHANGED_ASSIGNMENTS
				(request_id, assignment_id, payroll_id, change_type, payroll_action_id, change_date)
			SELECT	DISTINCT l_request_id,
				pesl.assignment_id,
				pesl.payroll_id,
				'TR',
				p_payroll_action_id,
				l_termination_date2
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.person_id = l_person_id2
			AND	pesl.effective_date >= l_termination_date2
			AND	pesl.award_id IS NOT NULL
			AND	pesl.status_code = 'A'
			AND	NOT EXISTS	(SELECT	1
						FROM	psp_enc_summary_lines pesl2
						WHERE	pesl2.person_id = l_person_id2
						AND	pesl2.status_code = 'N');
			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Inserted termination assignments into psp_enc_changed_assignments ' || SQL%ROWCOUNT);
			IF (SQL%ROWCOUNT = 0) THEN
				OPEN in_process_term_cur(l_person_id2);
				LOOP
					FETCH in_process_term_cur INTO l_assignment_id, l_payroll_id, l_payroll_action_id;
					EXIT WHEN in_process_term_cur%NOTFOUND;

					OPEN process_descr_cur;
					FETCH process_descr_cur INTO l_process_description;
					CLOSE process_descr_cur;

					fnd_message.set_name('PSP', 'PSP_ENC_ASG_IN_PROCESS');
					fnd_message.set_token('PROCESS_DESCRIPTION', l_process_description);
					g_warning_message := fnd_message.get;

					OPEN asg_number_cur (l_termination_date2);
					FETCH asg_number_cur INTO l_assignment_number, l_person_id, l_organization_id;
					CLOSE asg_number_cur;

					OPEN payroll_name_cur;
					FETCH payroll_name_cur INTO l_payroll_name;
					CLOSE payroll_name_cur;

					OPEN person_name_cur (l_termination_date2);
					FETCH person_name_cur INTO l_full_name;
					CLOSE person_name_cur;

					OPEN org_name_cur;
					FETCH org_name_cur INTO l_organization_name;
					CLOSE org_name_cur;

					psp_general.add_report_error
						(p_request_id		=>	l_request_id,
						p_message_level		=>	'N',
						p_source_id		=>	l_assignment_id,
						p_source_name		=>	l_assignment_number,
						p_parent_source_id	=>	l_person_id,
						p_parent_source_name	=>	l_full_name,
						p_error_message		=>	g_warning_message,
						p_payroll_action_id	=>	p_payroll_action_id,
						p_value1		=>	l_payroll_id,
						p_information1		=>	l_payroll_name,
						p_value2		=>	l_organization_id,
						p_information2		=>	l_organization_name,
						p_return_status		=>	l_return_status);
				END LOOP;
				CLOSE in_process_term_cur;
			END IF;
		END IF;

		IF (l_person_id3 > 0) THEN
			INSERT INTO PSP_ENC_CHANGED_ASSIGNMENTS
				(request_id, assignment_id, payroll_id, change_type, payroll_action_id, change_date)
			SELECT	DISTINCT l_request_id,
				pesl.assignment_id,
				pesl.payroll_id,
				'TR',
				p_payroll_action_id,
				l_termination_date3
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.person_id = l_person_id3
			AND	pesl.effective_date >= l_termination_date3
			AND	pesl.award_id IS NOT NULL
			AND	pesl.status_code = 'A'
			AND	NOT EXISTS	(SELECT	1
						FROM	psp_enc_summary_lines pesl2
						WHERE	pesl2.person_id = l_person_id3
						AND	pesl2.status_code = 'N');
			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Inserted termination assignments into psp_enc_changed_assignments ' || SQL%ROWCOUNT);
			IF (SQL%ROWCOUNT = 0) THEN
				OPEN in_process_term_cur(l_person_id3);
				LOOP
					FETCH in_process_term_cur INTO l_assignment_id, l_payroll_id, l_payroll_action_id;
					EXIT WHEN in_process_term_cur%NOTFOUND;

					OPEN process_descr_cur;
					FETCH process_descr_cur INTO l_process_description;
					CLOSE process_descr_cur;

					fnd_message.set_name('PSP', 'PSP_ENC_ASG_IN_PROCESS');
					fnd_message.set_token('PROCESS_DESCRIPTION', l_process_description);
					g_warning_message := fnd_message.get;

					OPEN asg_number_cur (l_termination_date3);
					FETCH asg_number_cur INTO l_assignment_number, l_person_id, l_organization_id;
					CLOSE asg_number_cur;

					OPEN payroll_name_cur;
					FETCH payroll_name_cur INTO l_payroll_name;
					CLOSE payroll_name_cur;

					OPEN person_name_cur (l_termination_date3);
					FETCH person_name_cur INTO l_full_name;
					CLOSE person_name_cur;

					OPEN org_name_cur;
					FETCH org_name_cur INTO l_organization_name;
					CLOSE org_name_cur;

					psp_general.add_report_error
						(p_request_id		=>	l_request_id,
						p_message_level		=>	'N',
						p_source_id		=>	l_assignment_id,
						p_source_name		=>	l_assignment_number,
						p_parent_source_id	=>	l_person_id,
						p_parent_source_name	=>	l_full_name,
						p_error_message		=>	g_warning_message,
						p_payroll_action_id	=>	p_payroll_action_id,
						p_value1		=>	l_payroll_id,
						p_information1		=>	l_payroll_name,
						p_value2		=>	l_organization_id,
						p_information2		=>	l_organization_name,
						p_return_status		=>	l_return_status);
				END LOOP;
				CLOSE in_process_term_cur;
			END IF;
		END IF;

		IF (l_person_id4 > 0) THEN
			INSERT INTO PSP_ENC_CHANGED_ASSIGNMENTS
				(request_id, assignment_id, payroll_id, change_type, payroll_action_id, change_date)
			SELECT	DISTINCT l_request_id,
				pesl.assignment_id,
				pesl.payroll_id,
				'TR',
				p_payroll_action_id,
				l_termination_date4
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.person_id = l_person_id4
			AND	pesl.effective_date >= l_termination_date4
			AND	pesl.award_id IS NOT NULL
			AND	pesl.status_code = 'A'
			AND	NOT EXISTS	(SELECT	1
						FROM	psp_enc_summary_lines pesl2
						WHERE	pesl2.person_id = l_person_id4
						AND	pesl2.status_code = 'N');
			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Inserted termination assignments into psp_enc_changed_assignments ' || SQL%ROWCOUNT);
			IF (SQL%ROWCOUNT = 0) THEN
				OPEN in_process_term_cur(l_person_id4);
				LOOP
					FETCH in_process_term_cur INTO l_assignment_id, l_payroll_id, l_payroll_action_id;
					EXIT WHEN in_process_term_cur%NOTFOUND;

					OPEN process_descr_cur;
					FETCH process_descr_cur INTO l_process_description;
					CLOSE process_descr_cur;

					fnd_message.set_name('PSP', 'PSP_ENC_ASG_IN_PROCESS');
					fnd_message.set_token('PROCESS_DESCRIPTION', l_process_description);
					g_warning_message := fnd_message.get;

					OPEN asg_number_cur (l_termination_date4);
					FETCH asg_number_cur INTO l_assignment_number, l_person_id, l_organization_id;
					CLOSE asg_number_cur;

					OPEN payroll_name_cur;
					FETCH payroll_name_cur INTO l_payroll_name;
					CLOSE payroll_name_cur;

					OPEN person_name_cur (l_termination_date4);
					FETCH person_name_cur INTO l_full_name;
					CLOSE person_name_cur;

					OPEN org_name_cur;
					FETCH org_name_cur INTO l_organization_name;
					CLOSE org_name_cur;

					psp_general.add_report_error
						(p_request_id		=>	l_request_id,
						p_message_level		=>	'N',
						p_source_id		=>	l_assignment_id,
						p_source_name		=>	l_assignment_number,
						p_parent_source_id	=>	l_person_id,
						p_parent_source_name	=>	l_full_name,
						p_error_message		=>	g_warning_message,
						p_payroll_action_id	=>	p_payroll_action_id,
						p_value1		=>	l_payroll_id,
						p_information1		=>	l_payroll_name,
						p_value2		=>	l_organization_id,
						p_information2		=>	l_organization_name,
						p_return_status		=>	l_return_status);
				END LOOP;
				CLOSE in_process_term_cur;
			END IF;
		END IF;

		IF (l_person_id5 > 0) THEN
			INSERT INTO PSP_ENC_CHANGED_ASSIGNMENTS
				(request_id, assignment_id, payroll_id, change_type, payroll_action_id, change_date)
			SELECT	DISTINCT l_request_id,
				pesl.assignment_id,
				pesl.payroll_id,
				'TR',
				p_payroll_action_id,
				l_termination_date5
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.person_id = l_person_id5
			AND	pesl.effective_date >= l_termination_date5
			AND	pesl.award_id IS NOT NULL
			AND	pesl.status_code = 'A'
			AND	NOT EXISTS	(SELECT	1
						FROM	psp_enc_summary_lines pesl2
						WHERE	pesl2.person_id = l_person_id5
						AND	pesl2.status_code = 'N');
			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Inserted termination assignments into psp_enc_changed_assignments ' || SQL%ROWCOUNT);
			IF (SQL%ROWCOUNT = 0) THEN
				OPEN in_process_term_cur(l_person_id5);
				LOOP
					FETCH in_process_term_cur INTO l_assignment_id, l_payroll_id, l_payroll_action_id;
					EXIT WHEN in_process_term_cur%NOTFOUND;

					OPEN process_descr_cur;
					FETCH process_descr_cur INTO l_process_description;
					CLOSE process_descr_cur;

					fnd_message.set_name('PSP', 'PSP_ENC_ASG_IN_PROCESS');
					fnd_message.set_token('PROCESS_DESCRIPTION', l_process_description);
					g_warning_message := fnd_message.get;

					OPEN asg_number_cur (l_termination_date5);
					FETCH asg_number_cur INTO l_assignment_number, l_person_id, l_organization_id;
					CLOSE asg_number_cur;

					OPEN payroll_name_cur;
					FETCH payroll_name_cur INTO l_payroll_name;
					CLOSE payroll_name_cur;

					OPEN person_name_cur (l_termination_date5);
					FETCH person_name_cur INTO l_full_name;
					CLOSE person_name_cur;

					OPEN org_name_cur;
					FETCH org_name_cur INTO l_organization_name;
					CLOSE org_name_cur;

					psp_general.add_report_error
						(p_request_id		=>	l_request_id,
						p_message_level		=>	'N',
						p_source_id		=>	l_assignment_id,
						p_source_name		=>	l_assignment_number,
						p_parent_source_id	=>	l_person_id,
						p_parent_source_name	=>	l_full_name,
						p_error_message		=>	g_warning_message,
						p_payroll_action_id	=>	p_payroll_action_id,
						p_value1		=>	l_payroll_id,
						p_information1		=>	l_payroll_name,
						p_value2		=>	l_organization_id,
						p_information2		=>	l_organization_name,
						p_return_status		=>	l_return_status);
				END LOOP;
				CLOSE in_process_term_cur;
			END IF;
		END IF;
	END IF;

	COMMIT;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Leaving ENC_PRE_PROCESS
	p_payroll_action_id: ' || p_payroll_action_id || '
	p_payroll_id: ' || p_payroll_id || '
	p_process_mode: ' || p_process_mode);
	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		IF (g_error_message IS NULL) THEN
			g_error_message := 'PSP_ENC_PROCESS: ' || SQLERRM;
		END IF;
		fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', 'ENC_PRE_PROCESS: SQLCODE: ' || fnd_number.number_to_canonical(SQLCODE) || ' SQLERRM: ' || SQLERRM);
		psp_message_s.print_error(p_mode => FND_FILE.LOG, p_print_header => FND_API.G_TRUE);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ENC_PRE_PROCESS
	p_payroll_action_id: ' || p_payroll_action_id || '
	p_payroll_id: ' || p_payroll_id || '
	p_process_mode: ' || p_process_mode);
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END enc_pre_process;

PROCEDURE rollback_cel	(errbuf			OUT NOCOPY	VARCHAR2,
			retcode			OUT NOCOPY	VARCHAR2,
			p_payroll_action_id	IN		NUMBER,
			p_person_id1		IN		NUMBER,
			p_assignment_id1	IN		NUMBER,
			p_person_id2		IN		NUMBER,
			p_assignment_id2	IN		NUMBER,
			p_person_id3		IN		NUMBER,
			p_assignment_id3	IN		NUMBER,
			p_person_id4		IN		NUMBER,
			p_assignment_id4	IN		NUMBER,
			p_person_id5		IN		NUMBER,
			p_assignment_id5	IN		NUMBER) IS
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE r_superceded_lines_rec IS RECORD
		(enc_summary_line_id		t_number_15);
t_superceded_lines	r_superceded_lines_rec;

l_assignments		t_number_15;
l_assignments_tmp	t_number_15;

l_assignment_id		NUMBER(15);
l_payroll_id		NUMBER(15);
l_asg_counter		NUMBER(15);

CURSOR	asg_cur (p_person_id	IN	NUMBER,
		p_assignment_id	IN	NUMBER) IS
SELECT	DISTINCT pepa.assignment_id
FROM	psp_enc_process_assignments pepa,
	per_all_assignments_f paf
WHERE	pepa.payroll_action_id = p_payroll_action_id
AND	paf.person_id = p_person_id
AND	paf.assignment_id = pepa.assignment_id
AND	(	p_assignment_id IS NULL
	OR	pepa.assignment_id = p_assignment_id);

CURSOR	superceded_line_cur (p_assignment_id IN NUMBER) IS
SELECT	superceded_line_id
FROM	psp_enc_summary_lines pesl
WHERE	pesl.payroll_action_id = p_payroll_action_id
AND	pesl.superceded_line_id IS NOT NULL
AND	assignment_id = p_assignment_id;

l_request_id		NUMBER(15);
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering ROLLBACK_CEL p_payroll_action_id: ' || p_payroll_action_id);
	l_request_id := fnd_global.conc_request_id;

	IF (p_person_id1 IS NULL) THEN
		OPEN superceded_line_cur(NULL);
		FETCH superceded_line_cur BULK COLLECT INTO t_superceded_lines.enc_summary_line_id;
		CLOSE superceded_line_cur;

		FORALL recno IN 1..t_superceded_lines.enc_summary_line_id.COUNT
		UPDATE	psp_enc_lines_history
		SET	change_flag = 'N'
		WHERE	enc_summary_line_id = t_superceded_lines.enc_summary_line_id(recno);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Reverted respective superceded lines in psp_enc_lines_history');

		DELETE	psp_enc_summary_lines
		WHERE	payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted respective lines in psp_enc_summary_lines');

		DELETE	psp_enc_lines
		WHERE	payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted respective lines in psp_enc_lines');

		DELETE	psp_enc_controls
		WHERE	payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted respective lines in psp_enc_controls');

		DELETE	psp_report_errors
		WHERE	payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted respective lines in psp_report_errors');

		UPDATE	psp_enc_processes
		SET	process_status = 'B',
			process_phase = 'rollback'
		WHERE	payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process status to ''Rollback'' in psp_enc_processes');

		UPDATE	psp_enc_process_assignments
		SET	assignment_status = 'B'
		WHERE	payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process status to ''Rollback'' in psp_enc_process_assignments');

		UPDATE	psp_enc_changed_assignments
		SET	payroll_action_id = NULL
		WHERE	payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated payroll_action_id in psp_enc_changed_assignments');

		INSERT INTO psp_enc_changed_assignments
			(request_id, assignment_id, payroll_id, change_type,
			processed_flag, reference_id, action_type, change_date)
		SELECT	l_request_id, pecah.assignment_id, pecah.payroll_id, pecah.change_type,
			NULL, NVL(pecah.reference_id, 0), pecah.action_type, change_date
		FROM	psp_enc_changed_asg_history pecah
		WHERE   payroll_action_id = p_payroll_action_id
		AND	action_type NOT IN ('CR', 'LQ', 'TR');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Copied change assignment records to psp_enc_changed_assignments');

		DELETE	psp_enc_changed_asg_history
		WHERE   payroll_action_id = p_payroll_action_id;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Copied change assignment records to psp_enc_changed_assignments');
	ELSE
		OPEN asg_cur(p_person_id1, p_assignment_id1);
		FETCH asg_cur BULK COLLECT INTO l_assignments;
		CLOSE asg_cur;

		IF (p_person_id2 IS NOT NULL) THEN
			OPEN asg_cur(p_person_id2, p_assignment_id2);
			FETCH asg_cur BULK COLLECT INTO l_assignments_tmp;
			CLOSE asg_cur;

			l_asg_counter := l_assignments.COUNT + 1;
			FOR recno IN 1..l_assignments_tmp.COUNT
			LOOP
				l_assignments(l_asg_counter) := l_assignments_tmp(recno);
				l_asg_counter := l_asg_counter + 1;
			END LOOP;
			l_assignments_tmp.DELETE;
		END IF;

		IF (p_person_id3 IS NOT NULL) THEN
			OPEN asg_cur(p_person_id3, p_assignment_id3);
			FETCH asg_cur BULK COLLECT INTO l_assignments_tmp;
			CLOSE asg_cur;

			l_asg_counter := l_assignments.COUNT + 1;
			FOR recno IN 1..l_assignments_tmp.COUNT
			LOOP
				l_assignments(l_asg_counter) := l_assignments_tmp(recno);
				l_asg_counter := l_asg_counter + 1;
			END LOOP;
			l_assignments_tmp.DELETE;
		END IF;

		IF (p_person_id4 IS NOT NULL) THEN
			OPEN asg_cur(p_person_id4, p_assignment_id4);
			FETCH asg_cur BULK COLLECT INTO l_assignments_tmp;
			CLOSE asg_cur;

			l_asg_counter := l_assignments.COUNT + 1;
			FOR recno IN 1..l_assignments_tmp.COUNT
			LOOP
				l_assignments(l_asg_counter) := l_assignments_tmp(recno);
				l_asg_counter := l_asg_counter + 1;
			END LOOP;
			l_assignments_tmp.DELETE;
		END IF;

		IF (p_person_id5 IS NOT NULL) THEN
			OPEN asg_cur(p_person_id5, p_assignment_id5);
			FETCH asg_cur BULK COLLECT INTO l_assignments_tmp;
			CLOSE asg_cur;

			l_asg_counter := l_assignments.COUNT + 1;
			FOR recno IN 1..l_assignments_tmp.COUNT
			LOOP
				l_assignments(l_asg_counter) := l_assignments_tmp(recno);
				l_asg_counter := l_asg_counter + 1;
			END LOOP;
			l_assignments_tmp.DELETE;
		END IF;

		FOR recno IN 1..l_assignments.COUNT
		LOOP
			OPEN superceded_line_cur(l_assignments(recno));
			FETCH superceded_line_cur BULK COLLECT INTO t_superceded_lines.enc_summary_line_id;
			CLOSE superceded_line_cur;

			FORALL recno IN 1..t_superceded_lines.enc_summary_line_id.COUNT
			UPDATE	psp_enc_lines_history
			SET	change_flag = 'N'
			WHERE	enc_summary_line_id = t_superceded_lines.enc_summary_line_id(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Reverted respective superceded lines in psp_enc_lines_history');

			DELETE	psp_enc_summary_lines
			WHERE	payroll_action_id = p_payroll_action_id
			AND	assignment_id = l_assignments(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted respective lines in psp_enc_summary_lines');

			DELETE	psp_enc_lines
			WHERE	payroll_action_id = p_payroll_action_id
			AND	assignment_id = l_assignments(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted respective lines in psp_enc_lines');

			DELETE	psp_enc_controls pec
			WHERE	payroll_action_id = p_payroll_action_id
			AND	NOT EXISTS	(SELECT	1
						FROM	psp_enc_lines pel
						WHERE	payroll_action_id = p_payroll_action_id
						AND	pel.enc_control_id = pec.enc_control_id);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted respective lines in psp_enc_controls');

			DELETE	psp_report_errors
			WHERE	payroll_action_id = p_payroll_action_id
			AND	source_id = l_assignments(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted respective lines in psp_report_errors');

			UPDATE	psp_enc_process_assignments
			SET	assignment_status = 'B'
			WHERE	payroll_action_id = p_payroll_action_id
			AND	assignment_id = l_assignments(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated assignment status to ''Rollback'' in psp_enc_process_assignments');

			UPDATE	psp_enc_changed_assignments
			SET	payroll_action_id = NULL
			WHERE	payroll_action_id = p_payroll_action_id
			AND	assignment_id = l_assignments(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated payroll_action_id in psp_enc_changed_assignments');

			INSERT INTO     psp_enc_changed_assignments
				(request_id, assignment_id, payroll_id, change_type,
				processed_flag, reference_id, action_type, change_date)
			SELECT	l_request_id, pecah.assignment_id, pecah.payroll_id, pecah.change_type,
				NULL, NVL(pecah.reference_id, 0), pecah.action_type, change_date
			FROM	psp_enc_changed_asg_history pecah
			WHERE   payroll_action_id = p_payroll_action_id
			AND	assignment_id = l_assignments(recno)
			AND	action_type NOT IN ('CR', 'LQ', 'TR');
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Copied change assignment records to psp_enc_changed_assignments');

			DELETE	psp_enc_changed_asg_history
			WHERE   payroll_action_id = p_payroll_action_id
			AND	assignment_id = l_assignments(recno);
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Copied change assignment records to psp_enc_changed_assignments');
		END LOOP;

		UPDATE	psp_enc_processes
		SET	process_status = 'B',
			process_phase = 'rollback'
		WHERE	payroll_action_id = p_payroll_action_id
		AND	NOT EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines
					WHERE	payroll_action_id = p_payroll_action_id);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process status to ''Rollback'' in psp_enc_processes');
	END IF;

	COMMIT;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ROLLBACK_CEL p_payroll_action_id: ' || p_payroll_action_id);
	retcode := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', 'ROLLBACK_CEL: SQLCODE: ' || fnd_number.number_to_canonical(SQLCODE) || ' SQLERRM: ' || SQLERRM);
		psp_message_s.print_error(p_mode => FND_FILE.LOG, p_print_header => FND_API.G_TRUE);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ROLLBACK_CEL p_payroll_action_id: ' || p_payroll_action_id);
		retcode := fnd_api.g_ret_sts_unexp_error;
END	rollback_cel;

PROCEDURE load_sch_hierarchy	(p_assignment_id	IN		NUMBER,
				p_payroll_id		IN		NUMBER,
				p_element_type_id	IN		NUMBER,
				p_business_group_id	IN		NUMBER,
				p_set_of_books_id	IN		NUMBER,
				p_return_status		OUT NOCOPY	VARCHAR2) IS
l_proc_name			VARCHAR2(61) DEFAULT g_package_name || 'LOAD_SCH_HIERARCHY';
l_proc_step			NUMBER(20,10);
r_sa_tmp			r_schedule_line_type;
r_gsa				r_schedule_line_type;
l_min_start_date	DATE;
l_max_end_date		DATE;

CURSOR	global_element_cur IS
SELECT	peta.element_account_id,
	peta.gl_code_combination_id,
	peta.project_id,
	peta.task_id,
	peta.award_id,
	peta.expenditure_type,
	peta.expenditure_organization_id,
	peta.start_date_active,
	peta.end_date_active,
	peta.poeta_start_date,
	peta.poeta_end_date,
	peta.percent,
	DECODE(g_dff_grouping_option, 'Y', peta.attribute_category, NULL),
	DECODE(g_dff_grouping_option, 'Y', peta.attribute1, NULL),
	DECODE(g_dff_grouping_option, 'Y', peta.attribute2, NULL),
	DECODE(g_dff_grouping_option, 'Y', peta.attribute3, NULL),
	DECODE(g_dff_grouping_option, 'Y', peta.attribute4, NULL),
	DECODE(g_dff_grouping_option, 'Y', peta.attribute5, NULL),
	DECODE(g_dff_grouping_option, 'Y', peta.attribute6, NULL),
	DECODE(g_dff_grouping_option, 'Y', peta.attribute7, NULL),
	DECODE(g_dff_grouping_option, 'Y', peta.attribute8, NULL),
	DECODE(g_dff_grouping_option, 'Y', peta.attribute9, NULL),
	DECODE(g_dff_grouping_option, 'Y', peta.attribute10, NULL),
	DECODE(peta.expenditure_type, NULL, 'N', 'E') acct_type
FROM	psp_element_type_accounts peta
WHERE	peta.element_type_id   = p_element_type_id
AND	peta.business_group_id = p_business_group_id
AND	peta.set_of_books_id   = p_set_of_books_id
AND	(	peta.gl_code_combination_id  IS NOT NULL
	OR	peta.award_id IS NOT NULL)
AND	peta.end_date_active >= l_min_start_date
AND	peta.start_date_active <= g_enc_org_end_date
ORDER BY peta.start_date_active, peta.end_date_active;

CURSOR	sch_lines_element_type_cur IS
SELECT	psl.schedule_line_id,
	psl.gl_code_combination_id,
	psl.project_id,
	psl.task_id,
	psl.award_id,
	psl.expenditure_type,
	psl.expenditure_organization_id,
	psl.schedule_begin_date,
	psl.schedule_end_date,
	psl.poeta_start_date,
	psl.poeta_end_date,
	psl.schedule_percent,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute_category, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute1, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute2, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute3, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute4, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute5, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute6, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute7, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute8, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute9, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute10, NULL),
	DECODE(psl.expenditure_type, NULL, 'N', 'E') acct_type
FROM	psp_schedule_hierarchy psh,
	psp_schedule_lines  psl
WHERE	psh.assignment_id = p_assignment_id
AND	psh.element_type_id = p_element_type_id
AND	psh.business_group_id = p_business_group_id
AND	psh.set_of_books_id = p_set_of_books_id
AND	psh.schedule_hierarchy_id = psl.schedule_hierarchy_id
AND	(	psl.gl_code_combination_id IS NOT NULL
	OR	psl.award_id IS NOT NULL )
AND	psl.schedule_begin_date <= g_enc_org_end_date
AND	psl.schedule_end_date >= l_min_start_date
AND	psl.default_flag IS NULL
ORDER BY psl.schedule_begin_date, psl.schedule_end_date;

CURSOR	sch_lines_element_class_cur IS
SELECT	psl.schedule_line_id,
        psl.gl_code_combination_id,
        psl.project_id,
        psl.task_id,
        psl.award_id,
        psl.expenditure_type,
        psl.expenditure_organization_id,
	psl.schedule_begin_date,
	psl.schedule_end_date,
	psl.poeta_start_date,
	psl.poeta_end_date,
	psl.schedule_percent,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute_category, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute1, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute2, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute3, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute4, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute5, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute6, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute7, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute8, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute9, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute10, NULL),
	DECODE(psl.expenditure_type, NULL, 'N', 'E') acct_type
FROM	psp_element_types      pet,
	psp_group_element_list pgel,
	psp_schedule_hierarchy psh,
	psp_schedule_lines    psl
WHERE	pet.element_type_id = p_element_type_id
AND	pet.business_group_id = p_business_group_id
AND	pet.set_of_books_id = p_set_of_books_id
AND	pet.start_date_active <= g_enc_org_end_date
AND	pet.end_date_active >= l_min_start_date
AND	pet.element_type_id = pgel.element_type_id
AND	psh.business_group_id = p_business_group_id
AND	psh.set_of_books_id = p_set_of_books_id
AND	pgel.element_group_id = psh.element_group_id
AND	psh.assignment_id = p_assignment_id
AND	psh.schedule_hierarchy_id = psl.schedule_hierarchy_id
AND	(	psl.gl_code_combination_id  IS NOT NULL
  	  OR	psl.award_id IS NOT NULL)
AND    psl.schedule_begin_date <= pet.end_date_active
AND    psl.schedule_end_date >= pet.start_date_active
AND    psl.default_flag IS NULL
ORDER BY psl.schedule_begin_date, psl.schedule_end_date;

CURSOR	sch_lines_assignment_cur IS
SELECT	psl.schedule_line_id,
        psl.gl_code_combination_id,
        psl.project_id,
        psl.task_id,
        psl.award_id,
        psl.expenditure_type,
        psl.expenditure_organization_id,
	psl.schedule_begin_date,
	psl.schedule_end_date,
	psl.poeta_start_date,
	psl.poeta_end_date,
	psl.schedule_percent,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute_category, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute1, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute2, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute3, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute4, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute5, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute6, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute7, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute8, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute9, NULL),
	DECODE(g_dff_grouping_option, 'Y', psl.attribute10, NULL),
	DECODE(psl.expenditure_type, NULL, 'N', 'E') acct_type
FROM	psp_schedule_hierarchy psh,
	psp_schedule_lines     psl
WHERE	psh.scheduling_types_code = 'A'
AND	psh.element_group_id IS NULL
AND	psh.element_type_id IS NULL
AND	psh.assignment_id = p_assignment_id
AND	psh.business_group_id = p_business_group_id
AND	psh.set_of_books_id   = p_set_of_books_id
AND	psh.schedule_hierarchy_id = psl.schedule_hierarchy_id
AND	(	psl.gl_code_combination_id IS NOT NULL
	OR	psl.award_id IS NOT NULL)
AND	psl.schedule_begin_date <= g_enc_org_end_date
AND	psl.schedule_end_date   >= l_min_start_date
AND	psl.default_flag IS NULL
ORDER BY psl.schedule_begin_date, psl.schedule_end_date;

CURSOR	asg_org_cur IS
SELECT	organization_id,
	effective_start_date,
	NVL(LEAD(effective_start_date - 1) OVER (ORDER BY effective_end_date), LEAST(l_max_end_date, effective_end_date))
FROM	per_assignments_f paf
WHERE	assignment_id = p_assignment_id
AND	payroll_id = p_payroll_id
AND	effective_start_date <= LEAST(l_max_end_date, g_enc_org_end_date)
ANd	effective_end_date >= l_min_start_date
AND	effective_start_date =	(SELECT	MIN(paf2.effective_start_date)
				FROM	per_assignments_f paf2
				WHERE	paf2.assignment_id = p_assignment_id
				AND	paf2.payroll_id = paf.payroll_id
				AND	paf2.organization_id = paf.organization_id
				AND	paf2.effective_start_date >= paf.effective_start_date);

TYPE r_asg_org_type IS RECORD
	(organization_id	t_num_15_type,
	start_date		t_date_type,
	end_date		t_date_type);
r_asg_org	r_asg_org_type;

CURSOR	org_labor_schedule_cur	(p_organization_id	IN	NUMBER,
				p_org_start_date	IN	DATE,
				p_org_end_date		IN	DATE) IS
SELECT	pdls.org_schedule_id,
	pdls.gl_code_combination_id,
	pdls.project_id,
	pdls.task_id,
	pdls.award_id,
	pdls.expenditure_type,
	pdls.expenditure_organization_id,
	GREATEST(pdls.schedule_begin_date, p_org_start_date),
	LEAST(pdls.schedule_end_date, p_org_end_date),
	pdls.poeta_start_date,
	pdls.poeta_end_date,
	pdls.schedule_percent,
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute_category, NULL),
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute1, NULL),
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute2, NULL),
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute3, NULL),
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute4, NULL),
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute5, NULL),
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute6, NULL),
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute7, NULL),
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute8, NULL),
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute9, NULL),
	DECODE(g_dff_grouping_option, 'Y', pdls.attribute10, NULL),
	DECODE(pdls.expenditure_type, NULL, 'N', 'E') acct_type
FROM	psp_default_labor_schedules pdls
WHERE	pdls.business_group_id = p_business_group_id
AND	pdls.set_of_books_id = p_set_of_books_id
AND	pdls.organization_id = p_organization_id
AND	(	pdls.gl_code_combination_id IS NOT NULL
	OR	pdls.award_id IS NOT NULL)
AND	pdls.schedule_begin_date <= p_org_end_date
AND	pdls.schedule_end_date >= p_org_start_date
ORDER BY GREATEST(pdls.schedule_begin_date, p_org_start_date), LEAST(pdls.schedule_end_date, p_org_end_date);

CURSOR	default_account_cur	(p_organization_id	IN	NUMBER,
				p_org_start_date	IN	DATE,
				p_org_end_date		IN	DATE) IS
SELECT	poa.organization_account_id,
	poa.gl_code_combination_id,
	poa.project_id,
	poa.task_id,
	poa.award_id,
	poa.expenditure_type,
	poa.expenditure_organization_id,
	GREATEST(poa.start_date_active, p_org_start_date),
	LEAST(poa.end_date_active, p_org_end_date),
	poa.poeta_start_date,
	poa.poeta_end_date,
	100 percent,
	DECODE(g_dff_grouping_option, 'Y', poa.attribute_category, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute1, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute2, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute3, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute4, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute5, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute6, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute7, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute8, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute9, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute10, NULL),
	DECODE(poa.expenditure_type, NULL, 'N', 'E') acct_type
FROM	psp_organization_accounts poa
WHERE	poa.organization_id = p_organization_id
AND	poa.business_group_id = p_business_group_id
AND	poa.set_of_books_id = p_set_of_books_id
AND	poa.account_type_code = 'D'
AND	poa.start_date_active <= p_org_end_date
AND	poa.end_date_active  >= p_org_start_date
AND	(	poa.gl_code_combination_id IS NOT NULL
	OR	poa.award_id IS NOT NULL)
ORDER BY GREATEST(poa.start_date_active, p_org_start_date), LEAST(poa.end_date_active, p_org_end_date);


CURSOR	suspense_account_cur	(p_organization_id	IN	NUMBER,
				p_org_start_date	IN	DATE,
				p_org_end_date		IN	DATE) IS
SELECT	poa.organization_account_id,
	poa.gl_code_combination_id,
	poa.project_id,
	poa.task_id,
	poa.award_id,
	poa.expenditure_type,
	poa.expenditure_organization_id,
	GREATEST(poa.start_date_active, p_org_start_date),
	LEAST(poa.end_date_active, p_org_end_date),
	poa.poeta_start_date,
	poa.poeta_end_date,
	100 percent,
	DECODE(g_dff_grouping_option, 'Y', poa.attribute_category, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute1, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute2, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute3, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute4, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute5, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute6, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute7, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute8, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute9, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute10, NULL),
	DECODE(poa.expenditure_type, NULL, 'N', 'E') acct_type
FROM	psp_organization_accounts poa
WHERE	poa.organization_id = p_organization_id
AND	poa.business_group_id = p_business_group_id
AND	poa.set_of_books_id = p_set_of_books_id
AND	poa.account_type_code = 'S'
AND	poa.start_date_active <= p_org_end_date
AND	poa.end_date_active  >= p_org_start_date
AND	(	poa.gl_code_combination_id IS NOT NULL
	OR	poa.award_id IS NOT NULL)
ORDER BY GREATEST(poa.start_date_active, p_org_start_date), LEAST(poa.end_date_active, p_org_end_date);


CURSOR	generic_suspense_cur IS
SELECT	poa.organization_account_id,
	poa.gl_code_combination_id,
	poa.project_id,
	poa.task_id,
	poa.award_id,
	poa.expenditure_type,
	poa.expenditure_organization_id,
	poa.start_date_active,
	poa.end_date_active,
	poa.poeta_start_date,
	poa.poeta_end_date,
	100 percent,
	DECODE(g_dff_grouping_option, 'Y', poa.attribute_category, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute1, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute2, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute3, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute4, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute5, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute6, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute7, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute8, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute9, NULL),
	DECODE(g_dff_grouping_option, 'Y', poa.attribute10, NULL),
	DECODE(poa.expenditure_type, NULL, 'N', 'E') acct_type
FROM	psp_organization_accounts poa
WHERE	poa.business_group_id = p_business_group_id
AND	poa.set_of_books_id = p_set_of_books_id
AND	poa.account_type_code = 'G'
AND	poa.start_date_active <= g_enc_org_end_date
AND	poa.end_date_active  >= l_min_start_date
AND	(	poa.gl_code_combination_id IS NOT NULL
	OR	poa.award_id IS NOT NULL)
ORDER BY poa.start_date_active, poa.end_date_active;
BEGIN
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Entering LOAD_SCH_HIERARCHY p_assignment_id: ' || fnd_number.number_to_canonical(p_assignment_id) || '
	p_element_type_id: ' || fnd_number.number_to_canonical(p_element_type_id) || '
	p_business_group_id: ' || fnd_number.number_to_canonical(p_business_group_id) || '
	p_set_of_books_id: ' || fnd_number.number_to_canonical(p_set_of_books_id));

	clear_sch_hierarchy;

	l_min_start_date := r_enc_period.r_asg_start_date(1);
	l_max_end_date := r_enc_period.r_asg_end_date(r_enc_period.r_period_end_date.COUNT);

	OPEN global_element_cur;
	FETCH global_element_cur BULK COLLECT INTO r_gee.line_account_id,
		r_gee.gl_code_combination_id,		r_gee.project_id,
		r_gee.task_id,				r_gee.award_id,
		r_gee.expenditure_type,			r_gee.expenditure_organization_id,
		r_gee.start_date_active,		r_gee.end_date_active,
		r_gee.poeta_start_date,			r_gee.poeta_end_date,
		r_gee.percent,				r_gee.attribute_category,
		r_gee.attribute1,			r_gee.attribute2,
		r_gee.attribute3,			r_gee.attribute4,
		r_gee.attribute5,			r_gee.attribute6,
		r_gee.attribute7,			r_gee.attribute8,
		r_gee.attribute9,			r_gee.attribute10,	r_gee.acct_type;
	CLOSE global_element_cur;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	r_gee.line_account_id.COUNT: ' || r_gee.line_account_id.COUNT);

	OPEN sch_lines_element_type_cur;
	FETCH sch_lines_element_type_cur BULK COLLECT INTO r_et.line_account_id,
		r_et.gl_code_combination_id,		r_et.project_id,
		r_et.task_id,				r_et.award_id,
		r_et.expenditure_type,			r_et.expenditure_organization_id,
		r_et.start_date_active,		r_et.end_date_active,
		r_et.poeta_start_date,			r_et.poeta_end_date,
		r_et.percent,				r_et.attribute_category,
		r_et.attribute1,			r_et.attribute2,
		r_et.attribute3,			r_et.attribute4,
		r_et.attribute5,			r_et.attribute6,
		r_et.attribute7,			r_et.attribute8,
		r_et.attribute9,			r_et.attribute10,	r_et.acct_type;
	CLOSE sch_lines_element_type_cur;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	r_et.line_account_id.COUNT: ' || r_et.line_account_id.COUNT);

	OPEN sch_lines_element_class_cur;
	FETCH sch_lines_element_class_cur BULK COLLECT INTO r_ec.line_account_id,
		r_ec.gl_code_combination_id,		r_ec.project_id,
		r_ec.task_id,				r_ec.award_id,
		r_ec.expenditure_type,			r_ec.expenditure_organization_id,
		r_ec.start_date_active,		r_ec.end_date_active,
		r_ec.poeta_start_date,			r_ec.poeta_end_date,
		r_ec.percent,				r_ec.attribute_category,
		r_ec.attribute1,			r_ec.attribute2,
		r_ec.attribute3,			r_ec.attribute4,
		r_ec.attribute5,			r_ec.attribute6,
		r_ec.attribute7,			r_ec.attribute8,
		r_ec.attribute9,			r_ec.attribute10,	r_ec.acct_type;
	CLOSE sch_lines_element_class_cur;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	r_ec.line_account_id.COUNT: ' || r_ec.line_account_id.COUNT);

	OPEN sch_lines_assignment_cur;
	FETCH sch_lines_assignment_cur BULK COLLECT INTO r_asg.line_account_id,
		r_asg.gl_code_combination_id,		r_asg.project_id,
		r_asg.task_id,				r_asg.award_id,
		r_asg.expenditure_type,			r_asg.expenditure_organization_id,
		r_asg.start_date_active,		r_asg.end_date_active,
		r_asg.poeta_start_date,			r_asg.poeta_end_date,
		r_asg.percent,				r_asg.attribute_category,
		r_asg.attribute1,			r_asg.attribute2,
		r_asg.attribute3,			r_asg.attribute4,
		r_asg.attribute5,			r_asg.attribute6,
		r_asg.attribute7,			r_asg.attribute8,
		r_asg.attribute9,			r_asg.attribute10,	r_asg.acct_type;
	CLOSE sch_lines_assignment_cur;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	r_asg.line_account_id.COUNT: ' || r_asg.line_account_id.COUNT);

	OPEN asg_org_cur;
	FETCH asg_org_cur BULK COLLECT INTO r_asg_org.organization_id, r_asg_org.start_date, r_asg_org.end_date;
	CLOSE asg_org_cur;

	g_odls_pointer := 0;
	g_da_pointer := 0;
	g_sa_pointer := 0;

	FOR recno IN 1..r_asg_org.organization_id.COUNT
	LOOP
		OPEN org_labor_schedule_cur (r_asg_org.organization_id(recno),
			r_asg_org.start_date(recno), r_asg_org.end_date(recno));
		FETCH org_labor_schedule_cur BULK COLLECT INTO r_gsa.line_account_id,
			r_gsa.gl_code_combination_id,		r_gsa.project_id,
			r_gsa.task_id,				r_gsa.award_id,
			r_gsa.expenditure_type,			r_gsa.expenditure_organization_id,
			r_gsa.start_date_active,		r_gsa.end_date_active,
			r_gsa.poeta_start_date,			r_gsa.poeta_end_date,
			r_gsa.percent,				r_gsa.attribute_category,
			r_gsa.attribute1,			r_gsa.attribute2,
			r_gsa.attribute3,			r_gsa.attribute4,
			r_gsa.attribute5,			r_gsa.attribute6,
			r_gsa.attribute7,			r_gsa.attribute8,
			r_gsa.attribute9,			r_gsa.attribute10,	r_gsa.acct_type;
		CLOSE org_labor_schedule_cur;

		FOR recno2 IN 1..r_gsa.line_account_id.COUNT
		LOOP
			g_odls_pointer := g_odls_pointer + 1;
			r_odls.line_account_id(g_odls_pointer) := r_gsa.line_account_id(recno2);
			r_odls.gl_code_combination_id(g_odls_pointer) := r_gsa.gl_code_combination_id(recno2);
			r_odls.project_id(g_odls_pointer) := r_gsa.project_id(recno2);
			r_odls.task_id(g_odls_pointer) := r_gsa.task_id(recno2);
			r_odls.award_id(g_odls_pointer) := r_gsa.award_id(recno2);
			r_odls.expenditure_type(g_odls_pointer) := r_gsa.expenditure_type(recno2);
			r_odls.expenditure_organization_id(g_odls_pointer) := r_gsa.expenditure_organization_id(recno2);
			r_odls.start_date_active(g_odls_pointer) := r_gsa.start_date_active(recno2);
			r_odls.end_date_active(g_odls_pointer) := r_gsa.end_date_active(recno2);
			r_odls.poeta_start_date(g_odls_pointer) := r_gsa.poeta_start_date(recno2);
			r_odls.poeta_end_date(g_odls_pointer) := r_gsa.poeta_end_date(recno2);
			r_odls.percent(g_odls_pointer) := r_gsa.percent(recno2);
			r_odls.attribute_category(g_odls_pointer) := r_gsa.attribute_category(recno2);
			r_odls.attribute1(g_odls_pointer) := r_gsa.attribute1(recno2);
			r_odls.attribute2(g_odls_pointer) := r_gsa.attribute2(recno2);
			r_odls.attribute3(g_odls_pointer) := r_gsa.attribute3(recno2);
			r_odls.attribute4(g_odls_pointer) := r_gsa.attribute4(recno2);
			r_odls.attribute5(g_odls_pointer) := r_gsa.attribute5(recno2);
			r_odls.attribute6(g_odls_pointer) := r_gsa.attribute6(recno2);
			r_odls.attribute7(g_odls_pointer) := r_gsa.attribute7(recno2);
			r_odls.attribute8(g_odls_pointer) := r_gsa.attribute8(recno2);
			r_odls.attribute9(g_odls_pointer) := r_gsa.attribute9(recno2);
			r_odls.attribute10(g_odls_pointer) := r_gsa.attribute10(recno2);
			r_odls.acct_type(g_odls_pointer) := r_gsa.acct_type(recno2);
		END LOOP;

		r_gsa.line_account_id.DELETE;
		r_gsa.gl_code_combination_id.DELETE;
		r_gsa.project_id.DELETE;
		r_gsa.task_id.DELETE;
		r_gsa.award_id.DELETE;
		r_gsa.expenditure_type.DELETE;
		r_gsa.expenditure_organization_id.DELETE;
		r_gsa.start_date_active.DELETE;
		r_gsa.end_date_active.DELETE;
		r_gsa.poeta_start_date.DELETE;
		r_gsa.poeta_end_date.DELETE;
		r_gsa.percent.DELETE;
		r_gsa.attribute_category.DELETE;
		r_gsa.attribute1.DELETE;
		r_gsa.attribute2.DELETE;
		r_gsa.attribute3.DELETE;
		r_gsa.attribute4.DELETE;
		r_gsa.attribute5.DELETE;
		r_gsa.attribute6.DELETE;
		r_gsa.attribute7.DELETE;
		r_gsa.attribute8.DELETE;
		r_gsa.attribute9.DELETE;
		r_gsa.attribute10.DELETE;
		r_gsa.acct_type.DELETE;

		OPEN default_account_cur (r_asg_org.organization_id(recno),
			r_asg_org.start_date(recno), r_asg_org.end_date(recno));
		FETCH default_account_cur BULK COLLECT INTO r_gsa.line_account_id,
			r_gsa.gl_code_combination_id,		r_gsa.project_id,
			r_gsa.task_id,				r_gsa.award_id,
			r_gsa.expenditure_type,			r_gsa.expenditure_organization_id,
			r_gsa.start_date_active,		r_gsa.end_date_active,
			r_gsa.poeta_start_date,			r_gsa.poeta_end_date,
			r_gsa.percent,				r_gsa.attribute_category,
			r_gsa.attribute1,			r_gsa.attribute2,
			r_gsa.attribute3,			r_gsa.attribute4,
			r_gsa.attribute5,			r_gsa.attribute6,
			r_gsa.attribute7,			r_gsa.attribute8,
			r_gsa.attribute9,			r_gsa.attribute10,	r_gsa.acct_type;
		CLOSE default_account_cur;

		FOR recno2 IN 1..r_gsa.line_account_id.COUNT
		LOOP
			g_da_pointer := g_da_pointer + 1;
			r_da.line_account_id(g_da_pointer) := r_gsa.line_account_id(recno2);
			r_da.gl_code_combination_id(g_da_pointer) := r_gsa.gl_code_combination_id(recno2);
			r_da.project_id(g_da_pointer) := r_gsa.project_id(recno2);
			r_da.task_id(g_da_pointer) := r_gsa.task_id(recno2);
			r_da.award_id(g_da_pointer) := r_gsa.award_id(recno2);
			r_da.expenditure_type(g_da_pointer) := r_gsa.expenditure_type(recno2);
			r_da.expenditure_organization_id(g_da_pointer) := r_gsa.expenditure_organization_id(recno2);
			r_da.start_date_active(g_da_pointer) := r_gsa.start_date_active(recno2);
			r_da.end_date_active(g_da_pointer) := r_gsa.end_date_active(recno2);
			r_da.poeta_start_date(g_da_pointer) := r_gsa.poeta_start_date(recno2);
			r_da.poeta_end_date(g_da_pointer) := r_gsa.poeta_end_date(recno2);
			r_da.percent(g_da_pointer) := r_gsa.percent(recno2);
			r_da.attribute_category(g_da_pointer) := r_gsa.attribute_category(recno2);
			r_da.attribute1(g_da_pointer) := r_gsa.attribute1(recno2);
			r_da.attribute2(g_da_pointer) := r_gsa.attribute2(recno2);
			r_da.attribute3(g_da_pointer) := r_gsa.attribute3(recno2);
			r_da.attribute4(g_da_pointer) := r_gsa.attribute4(recno2);
			r_da.attribute5(g_da_pointer) := r_gsa.attribute5(recno2);
			r_da.attribute6(g_da_pointer) := r_gsa.attribute6(recno2);
			r_da.attribute7(g_da_pointer) := r_gsa.attribute7(recno2);
			r_da.attribute8(g_da_pointer) := r_gsa.attribute8(recno2);
			r_da.attribute9(g_da_pointer) := r_gsa.attribute9(recno2);
			r_da.attribute10(g_da_pointer) := r_gsa.attribute10(recno2);
			r_da.acct_type(g_da_pointer) := r_gsa.acct_type(recno2);
		END LOOP;

		r_gsa.line_account_id.DELETE;
		r_gsa.gl_code_combination_id.DELETE;
		r_gsa.project_id.DELETE;
		r_gsa.task_id.DELETE;
		r_gsa.award_id.DELETE;
		r_gsa.expenditure_type.DELETE;
		r_gsa.expenditure_organization_id.DELETE;
		r_gsa.start_date_active.DELETE;
		r_gsa.end_date_active.DELETE;
		r_gsa.poeta_start_date.DELETE;
		r_gsa.poeta_end_date.DELETE;
		r_gsa.percent.DELETE;
		r_gsa.attribute_category.DELETE;
		r_gsa.attribute1.DELETE;
		r_gsa.attribute2.DELETE;
		r_gsa.attribute3.DELETE;
		r_gsa.attribute4.DELETE;
		r_gsa.attribute5.DELETE;
		r_gsa.attribute6.DELETE;
		r_gsa.attribute7.DELETE;
		r_gsa.attribute8.DELETE;
		r_gsa.attribute9.DELETE;
		r_gsa.attribute10.DELETE;
		r_gsa.acct_type.DELETE;

		OPEN suspense_account_cur (r_asg_org.organization_id(recno),
			r_asg_org.start_date(recno), r_asg_org.end_date(recno));
		FETCH suspense_account_cur BULK COLLECT INTO r_gsa.line_account_id,
			r_gsa.gl_code_combination_id,		r_gsa.project_id,
			r_gsa.task_id,				r_gsa.award_id,
			r_gsa.expenditure_type,			r_gsa.expenditure_organization_id,
			r_gsa.start_date_active,		r_gsa.end_date_active,
			r_gsa.poeta_start_date,			r_gsa.poeta_end_date,
			r_gsa.percent,				r_gsa.attribute_category,
			r_gsa.attribute1,			r_gsa.attribute2,
			r_gsa.attribute3,			r_gsa.attribute4,
			r_gsa.attribute5,			r_gsa.attribute6,
			r_gsa.attribute7,			r_gsa.attribute8,
			r_gsa.attribute9,			r_gsa.attribute10,	r_gsa.acct_type;
		CLOSE suspense_account_cur;

		FOR recno2 IN 1..r_gsa.line_account_id.COUNT
		LOOP
			g_sa_pointer := g_sa_pointer + 1;
			r_sa_tmp.line_account_id(g_sa_pointer) := r_gsa.line_account_id(recno2);
			r_sa_tmp.gl_code_combination_id(g_sa_pointer) := r_gsa.gl_code_combination_id(recno2);
			r_sa_tmp.project_id(g_sa_pointer) := r_gsa.project_id(recno2);
			r_sa_tmp.task_id(g_sa_pointer) := r_gsa.task_id(recno2);
			r_sa_tmp.award_id(g_sa_pointer) := r_gsa.award_id(recno2);
			r_sa_tmp.expenditure_type(g_sa_pointer) := r_gsa.expenditure_type(recno2);
			r_sa_tmp.expenditure_organization_id(g_sa_pointer) := r_gsa.expenditure_organization_id(recno2);
			r_sa_tmp.start_date_active(g_sa_pointer) := r_gsa.start_date_active(recno2);
			r_sa_tmp.end_date_active(g_sa_pointer) := r_gsa.end_date_active(recno2);
			r_sa_tmp.poeta_start_date(g_sa_pointer) := r_gsa.poeta_start_date(recno2);
			r_sa_tmp.poeta_end_date(g_sa_pointer) := r_gsa.poeta_end_date(recno2);
			r_sa_tmp.percent(g_sa_pointer) := r_gsa.percent(recno2);
			r_sa_tmp.attribute_category(g_sa_pointer) := r_gsa.attribute_category(recno2);
			r_sa_tmp.attribute1(g_sa_pointer) := r_gsa.attribute1(recno2);
			r_sa_tmp.attribute2(g_sa_pointer) := r_gsa.attribute2(recno2);
			r_sa_tmp.attribute3(g_sa_pointer) := r_gsa.attribute3(recno2);
			r_sa_tmp.attribute4(g_sa_pointer) := r_gsa.attribute4(recno2);
			r_sa_tmp.attribute5(g_sa_pointer) := r_gsa.attribute5(recno2);
			r_sa_tmp.attribute6(g_sa_pointer) := r_gsa.attribute6(recno2);
			r_sa_tmp.attribute7(g_sa_pointer) := r_gsa.attribute7(recno2);
			r_sa_tmp.attribute8(g_sa_pointer) := r_gsa.attribute8(recno2);
			r_sa_tmp.attribute9(g_sa_pointer) := r_gsa.attribute9(recno2);
			r_sa_tmp.attribute10(g_sa_pointer) := r_gsa.attribute10(recno2);
			r_sa_tmp.acct_type(g_sa_pointer) := r_gsa.acct_type(recno2);
		END LOOP;

		r_gsa.line_account_id.DELETE;
		r_gsa.gl_code_combination_id.DELETE;
		r_gsa.project_id.DELETE;
		r_gsa.task_id.DELETE;
		r_gsa.award_id.DELETE;
		r_gsa.expenditure_type.DELETE;
		r_gsa.expenditure_organization_id.DELETE;
		r_gsa.start_date_active.DELETE;
		r_gsa.end_date_active.DELETE;
		r_gsa.poeta_start_date.DELETE;
		r_gsa.poeta_end_date.DELETE;
		r_gsa.percent.DELETE;
		r_gsa.attribute_category.DELETE;
		r_gsa.attribute1.DELETE;
		r_gsa.attribute2.DELETE;
		r_gsa.attribute3.DELETE;
		r_gsa.attribute4.DELETE;
		r_gsa.attribute5.DELETE;
		r_gsa.attribute6.DELETE;
		r_gsa.attribute7.DELETE;
		r_gsa.attribute8.DELETE;
		r_gsa.attribute9.DELETE;
		r_gsa.attribute10.DELETE;
		r_gsa.acct_type.DELETE;
	END LOOP;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	r_odls.line_account_id.COUNT: ' || r_odls.line_account_id.COUNT);
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	r_da.line_account_id.COUNT: ' || r_da.line_account_id.COUNT);
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	r_sa_tmp.line_account_id.COUNT: ' || r_sa_tmp.line_account_id.COUNT);

	IF (r_sa_tmp.line_account_id.COUNT = 0) THEN
		OPEN generic_suspense_cur;
		FETCH generic_suspense_cur BULK COLLECT INTO r_sa.line_account_id,
			r_sa.gl_code_combination_id,		r_sa.project_id,
			r_sa.task_id,				r_sa.award_id,
			r_sa.expenditure_type,			r_sa.expenditure_organization_id,
			r_sa.start_date_active,		r_sa.end_date_active,
			r_sa.poeta_start_date,			r_sa.poeta_end_date,
			r_sa.percent,				r_sa.attribute_category,
			r_sa.attribute1,			r_sa.attribute2,
			r_sa.attribute3,			r_sa.attribute4,
			r_sa.attribute5,			r_sa.attribute6,
			r_sa.attribute7,			r_sa.attribute8,
			r_sa.attribute9,			r_sa.attribute10, r_sa.acct_type;
		CLOSE generic_suspense_cur;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	r_sa.line_account_id.COUNT: ' || r_sa.line_account_id.COUNT);
	ELSE
		OPEN generic_suspense_cur;
		FETCH generic_suspense_cur BULK COLLECT INTO r_gsa.line_account_id,
			r_gsa.gl_code_combination_id,		r_gsa.project_id,
			r_gsa.task_id,				r_gsa.award_id,
			r_gsa.expenditure_type,			r_gsa.expenditure_organization_id,
			r_gsa.start_date_active,		r_gsa.end_date_active,
			r_gsa.poeta_start_date,			r_gsa.poeta_end_date,
			r_gsa.percent,				r_gsa.attribute_category,
			r_gsa.attribute1,			r_gsa.attribute2,
			r_gsa.attribute3,			r_gsa.attribute4,
			r_gsa.attribute5,			r_gsa.attribute6,
			r_gsa.attribute7,			r_gsa.attribute8,
			r_gsa.attribute9,			r_gsa.attribute10,	r_gsa.acct_type;
		CLOSE generic_suspense_cur;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	r_gsa.line_account_id.COUNT: ' || r_gsa.line_account_id.COUNT);

		g_sa_pointer := 0;
		IF (r_sa_tmp.start_date_active(1) >= r_enc_period.r_asg_start_date(1)) THEN
			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) ||
				'	r_sa_tmp.start_date_active(1): ' || r_sa_tmp.start_date_active(1) ||
				' r_enc_period.r_asg_start_date(1): ' || r_enc_period.r_asg_start_date(1));
			FOR gsa_rec_no IN 1..r_gsa.line_account_id.COUNT
			LOOP
				EXIT WHEN r_gsa.start_date_active(gsa_rec_no) >= r_sa_tmp.start_date_active(1);

				g_sa_pointer := g_sa_pointer + 1;
				r_sa.line_account_id(g_sa_pointer) := r_gsa.line_account_id(gsa_rec_no);
				r_sa.gl_code_combination_id(g_sa_pointer) := r_gsa.gl_code_combination_id(gsa_rec_no);
				r_sa.project_id(g_sa_pointer) := r_gsa.project_id(gsa_rec_no);
				r_sa.task_id(g_sa_pointer) := r_gsa.task_id(gsa_rec_no);
				r_sa.award_id(g_sa_pointer) := r_gsa.award_id(gsa_rec_no);
				r_sa.expenditure_type(g_sa_pointer) := r_gsa.expenditure_type(gsa_rec_no);
				r_sa.expenditure_organization_id(g_sa_pointer) := r_gsa.expenditure_organization_id(gsa_rec_no);
				r_sa.start_date_active(g_sa_pointer) := GREATEST(r_gsa.start_date_active(gsa_rec_no), r_enc_period.r_asg_start_date(1));
				r_sa.end_date_active(g_sa_pointer) := LEAST(r_gsa.end_date_active(gsa_rec_no), r_sa_tmp.start_date_active(1)-1);
				r_sa.poeta_start_date(g_sa_pointer) := r_gsa.poeta_start_date(gsa_rec_no);
				r_sa.poeta_end_date(g_sa_pointer) := r_gsa.poeta_end_date(gsa_rec_no);
				r_sa.percent(g_sa_pointer) := r_gsa.percent(gsa_rec_no);
				r_sa.attribute_category(g_sa_pointer) := r_gsa.attribute_category(gsa_rec_no);
				r_sa.attribute1(g_sa_pointer) := r_gsa.attribute1(gsa_rec_no);
				r_sa.attribute2(g_sa_pointer) := r_gsa.attribute2(gsa_rec_no);
				r_sa.attribute3(g_sa_pointer) := r_gsa.attribute3(gsa_rec_no);
				r_sa.attribute4(g_sa_pointer) := r_gsa.attribute4(gsa_rec_no);
				r_sa.attribute5(g_sa_pointer) := r_gsa.attribute5(gsa_rec_no);
				r_sa.attribute6(g_sa_pointer) := r_gsa.attribute6(gsa_rec_no);
				r_sa.attribute7(g_sa_pointer) := r_gsa.attribute7(gsa_rec_no);
				r_sa.attribute8(g_sa_pointer) := r_gsa.attribute8(gsa_rec_no);
				r_sa.attribute9(g_sa_pointer) := r_gsa.attribute9(gsa_rec_no);
				r_sa.attribute10(g_sa_pointer) := r_gsa.attribute10(gsa_rec_no);
				r_sa.acct_type(g_sa_pointer) := r_gsa.acct_type(gsa_rec_no);
			END LOOP;
			hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Identified Generic Suspense Lines for suspense gap before the first suspense line');
		END IF;
		g_sa_pointer := g_sa_pointer + 1;
		r_sa.line_account_id(g_sa_pointer) := r_sa_tmp.line_account_id(1);
		r_sa.gl_code_combination_id(g_sa_pointer) := r_sa_tmp.gl_code_combination_id(1);
		r_sa.project_id(g_sa_pointer) := r_sa_tmp.project_id(1);
		r_sa.task_id(g_sa_pointer) := r_sa_tmp.task_id(1);
		r_sa.award_id(g_sa_pointer) := r_sa_tmp.award_id(1);
		r_sa.expenditure_type(g_sa_pointer) := r_sa_tmp.expenditure_type(1);
		r_sa.expenditure_organization_id(g_sa_pointer) := r_sa_tmp.expenditure_organization_id(1);
		r_sa.start_date_active(g_sa_pointer) := r_sa_tmp.start_date_active(1);
		r_sa.end_date_active(g_sa_pointer) := r_sa_tmp.end_date_active(1);
		r_sa.poeta_start_date(g_sa_pointer) := r_sa_tmp.poeta_start_date(1);
		r_sa.poeta_end_date(g_sa_pointer) := r_sa_tmp.poeta_end_date(1);
		r_sa.percent(g_sa_pointer) := r_sa_tmp.percent(1);
		r_sa.attribute_category(g_sa_pointer) := r_sa_tmp.attribute_category(1);
		r_sa.attribute1(g_sa_pointer) := r_sa_tmp.attribute1(1);
		r_sa.attribute2(g_sa_pointer) := r_sa_tmp.attribute2(1);
		r_sa.attribute3(g_sa_pointer) := r_sa_tmp.attribute3(1);
		r_sa.attribute4(g_sa_pointer) := r_sa_tmp.attribute4(1);
		r_sa.attribute5(g_sa_pointer) := r_sa_tmp.attribute5(1);
		r_sa.attribute6(g_sa_pointer) := r_sa_tmp.attribute6(1);
		r_sa.attribute7(g_sa_pointer) := r_sa_tmp.attribute7(1);
		r_sa.attribute8(g_sa_pointer) := r_sa_tmp.attribute8(1);
		r_sa.attribute9(g_sa_pointer) := r_sa_tmp.attribute9(1);
		r_sa.attribute10(g_sa_pointer) := r_sa_tmp.attribute10(1);
		r_sa.acct_type(g_sa_pointer) := r_sa_tmp.acct_type(1);
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Stamped first suspense line');

		IF (r_sa_tmp.line_account_id.COUNT > 1) THEN
			FOR sa_recno IN 2..r_sa_tmp.line_account_id.COUNT
			LOOP
				IF (r_sa_tmp.start_date_active(sa_recno) > r_sa.end_date_active(g_sa_pointer)+1) THEN
					FOR gsa_rec_no IN 1..r_gsa.line_account_id.COUNT
					LOOP
						EXIT WHEN r_sa.end_date_active(g_sa_pointer)+1 >= r_sa_tmp.start_date_active(sa_recno);
						IF (r_gsa.end_date_active(gsa_rec_no) >= r_sa.end_date_active(g_sa_pointer)+1) THEN
							g_sa_pointer := g_sa_pointer + 1;
							r_sa.line_account_id(g_sa_pointer) := r_gsa.line_account_id(gsa_rec_no);
							r_sa.gl_code_combination_id(g_sa_pointer) := r_gsa.gl_code_combination_id(gsa_rec_no);
							r_sa.project_id(g_sa_pointer) := r_gsa.project_id(gsa_rec_no);
							r_sa.task_id(g_sa_pointer) := r_gsa.task_id(gsa_rec_no);
							r_sa.award_id(g_sa_pointer) := r_gsa.award_id(gsa_rec_no);
							r_sa.expenditure_type(g_sa_pointer) := r_gsa.expenditure_type(gsa_rec_no);
							r_sa.expenditure_organization_id(g_sa_pointer) := r_gsa.expenditure_organization_id(gsa_rec_no);
							r_sa.start_date_active(g_sa_pointer) := GREATEST(r_gsa.start_date_active(gsa_rec_no), r_sa.end_date_active(g_sa_pointer-1)+1);
							r_sa.end_date_active(g_sa_pointer) := LEAST(r_gsa.end_date_active(gsa_rec_no), r_sa_tmp.start_date_active(sa_recno)-1);
							r_sa.poeta_start_date(g_sa_pointer) := r_gsa.poeta_start_date(gsa_rec_no);
							r_sa.poeta_end_date(g_sa_pointer) := r_gsa.poeta_end_date(gsa_rec_no);
							r_sa.percent(g_sa_pointer) := r_gsa.percent(gsa_rec_no);
							r_sa.attribute_category(g_sa_pointer) := r_gsa.attribute_category(gsa_rec_no);
							r_sa.attribute1(g_sa_pointer) := r_gsa.attribute1(gsa_rec_no);
							r_sa.attribute2(g_sa_pointer) := r_gsa.attribute2(gsa_rec_no);
							r_sa.attribute3(g_sa_pointer) := r_gsa.attribute3(gsa_rec_no);
							r_sa.attribute4(g_sa_pointer) := r_gsa.attribute4(gsa_rec_no);
							r_sa.attribute5(g_sa_pointer) := r_gsa.attribute5(gsa_rec_no);
							r_sa.attribute6(g_sa_pointer) := r_gsa.attribute6(gsa_rec_no);
							r_sa.attribute7(g_sa_pointer) := r_gsa.attribute7(gsa_rec_no);
							r_sa.attribute8(g_sa_pointer) := r_gsa.attribute8(gsa_rec_no);
							r_sa.attribute9(g_sa_pointer) := r_gsa.attribute9(gsa_rec_no);
							r_sa.attribute10(g_sa_pointer) := r_gsa.attribute10(gsa_rec_no);
							r_sa.acct_type(g_sa_pointer) := r_gsa.acct_type(gsa_rec_no);
							hr_utility.trace('	Stamped generic suspense line between ' ||
								r_sa.start_date_active(g_sa_pointer) || ' AND ' ||
								r_sa.end_date_active(g_sa_pointer));
						END IF;
					END LOOP;
				END IF;
				hr_utility.trace(' Attempting to stamp org suspense');
				g_sa_pointer := g_sa_pointer + 1;
				r_sa.line_account_id(g_sa_pointer) := r_sa_tmp.line_account_id(sa_recno);
				r_sa.gl_code_combination_id(g_sa_pointer) := r_sa_tmp.gl_code_combination_id(sa_recno);
				r_sa.project_id(g_sa_pointer) := r_sa_tmp.project_id(sa_recno);
				r_sa.task_id(g_sa_pointer) := r_sa_tmp.task_id(sa_recno);
				r_sa.award_id(g_sa_pointer) := r_sa_tmp.award_id(sa_recno);
				r_sa.expenditure_type(g_sa_pointer) := r_sa_tmp.expenditure_type(sa_recno);
				r_sa.expenditure_organization_id(g_sa_pointer) := r_sa_tmp.expenditure_organization_id(sa_recno);
				r_sa.start_date_active(g_sa_pointer) := r_sa_tmp.start_date_active(sa_recno);
				r_sa.end_date_active(g_sa_pointer) := r_sa_tmp.end_date_active(sa_recno);
				r_sa.poeta_start_date(g_sa_pointer) := r_sa_tmp.poeta_start_date(sa_recno);
				r_sa.poeta_end_date(g_sa_pointer) := r_sa_tmp.poeta_end_date(sa_recno);
				r_sa.percent(g_sa_pointer) := r_sa_tmp.percent(sa_recno);
				r_sa.attribute_category(g_sa_pointer) := r_sa_tmp.attribute_category(sa_recno);
				r_sa.attribute1(g_sa_pointer) := r_sa_tmp.attribute1(sa_recno);
				r_sa.attribute2(g_sa_pointer) := r_sa_tmp.attribute2(sa_recno);
				r_sa.attribute3(g_sa_pointer) := r_sa_tmp.attribute3(sa_recno);
				r_sa.attribute4(g_sa_pointer) := r_sa_tmp.attribute4(sa_recno);
				r_sa.attribute5(g_sa_pointer) := r_sa_tmp.attribute5(sa_recno);
				r_sa.attribute6(g_sa_pointer) := r_sa_tmp.attribute6(sa_recno);
				r_sa.attribute7(g_sa_pointer) := r_sa_tmp.attribute7(sa_recno);
				r_sa.attribute8(g_sa_pointer) := r_sa_tmp.attribute8(sa_recno);
				r_sa.attribute9(g_sa_pointer) := r_sa_tmp.attribute9(sa_recno);
				r_sa.attribute10(g_sa_pointer) := r_sa_tmp.attribute10(sa_recno);
				r_sa.acct_type(g_sa_pointer) := r_sa_tmp.acct_type(sa_recno);
				hr_utility.trace('	Stamped org suspense line between ' ||
					r_sa.start_date_active(g_sa_pointer) || ' AND ' || r_sa.end_date_active(g_sa_pointer));
			END LOOP;
		END IF;

		IF (r_sa.end_date_active(g_sa_pointer) < g_enc_org_end_date) THEN
			FOR gsa_rec_no IN 1..r_gsa.line_account_id.COUNT
			LOOP
				IF r_gsa.end_date_active(gsa_rec_no) > r_sa_tmp.end_date_active(r_sa_tmp.end_date_active.COUNT) THEN
					g_sa_pointer := g_sa_pointer + 1;
					r_sa.line_account_id(g_sa_pointer) := r_gsa.line_account_id(gsa_rec_no);
					r_sa.gl_code_combination_id(g_sa_pointer) := r_gsa.gl_code_combination_id(gsa_rec_no);
					r_sa.project_id(g_sa_pointer) := r_gsa.project_id(gsa_rec_no);
					r_sa.task_id(g_sa_pointer) := r_gsa.task_id(gsa_rec_no);
					r_sa.award_id(g_sa_pointer) := r_gsa.award_id(gsa_rec_no);
					r_sa.expenditure_type(g_sa_pointer) := r_gsa.expenditure_type(gsa_rec_no);
					r_sa.expenditure_organization_id(g_sa_pointer) := r_gsa.expenditure_organization_id(gsa_rec_no);
					r_sa.start_date_active(g_sa_pointer) := GREATEST(r_gsa.start_date_active(gsa_rec_no), r_sa_tmp.end_date_active(r_sa_tmp.end_date_active.COUNT)+1);
					r_sa.end_date_active(g_sa_pointer) := LEAST(r_gsa.end_date_active(gsa_rec_no), g_enc_org_end_date);
					r_sa.poeta_start_date(g_sa_pointer) := r_gsa.poeta_start_date(gsa_rec_no);
					r_sa.poeta_end_date(g_sa_pointer) := r_gsa.poeta_end_date(gsa_rec_no);
					r_sa.percent(g_sa_pointer) := r_gsa.percent(gsa_rec_no);
					r_sa.attribute_category(g_sa_pointer) := r_gsa.attribute_category(gsa_rec_no);
					r_sa.attribute1(g_sa_pointer) := r_gsa.attribute1(gsa_rec_no);
					r_sa.attribute2(g_sa_pointer) := r_gsa.attribute2(gsa_rec_no);
					r_sa.attribute3(g_sa_pointer) := r_gsa.attribute3(gsa_rec_no);
					r_sa.attribute4(g_sa_pointer) := r_gsa.attribute4(gsa_rec_no);
					r_sa.attribute5(g_sa_pointer) := r_gsa.attribute5(gsa_rec_no);
					r_sa.attribute6(g_sa_pointer) := r_gsa.attribute6(gsa_rec_no);
					r_sa.attribute7(g_sa_pointer) := r_gsa.attribute7(gsa_rec_no);
					r_sa.attribute8(g_sa_pointer) := r_gsa.attribute8(gsa_rec_no);
					r_sa.attribute9(g_sa_pointer) := r_gsa.attribute9(gsa_rec_no);
					r_sa.attribute10(g_sa_pointer) := r_gsa.attribute10(gsa_rec_no);
					r_sa.acct_type(g_sa_pointer) := r_gsa.acct_type(gsa_rec_no);
				END IF;
			END LOOP;
			r_sa_tmp.line_account_id.DELETE;
			r_sa_tmp.gl_code_combination_id.DELETE;
			r_sa_tmp.project_id.DELETE;
			r_sa_tmp.task_id.DELETE;
			r_sa_tmp.award_id.DELETE;
			r_sa_tmp.expenditure_type.DELETE;
			r_sa_tmp.expenditure_organization_id.DELETE;
			r_sa_tmp.start_date_active.DELETE;
			r_sa_tmp.end_date_active.DELETE;
			r_sa_tmp.poeta_start_date.DELETE;
			r_sa_tmp.poeta_end_date.DELETE;
			r_sa_tmp.percent.DELETE;
			r_sa_tmp.attribute_category.DELETE;
			r_sa_tmp.attribute1.DELETE;
			r_sa_tmp.attribute2.DELETE;
			r_sa_tmp.attribute3.DELETE;
			r_sa_tmp.attribute4.DELETE;
			r_sa_tmp.attribute5.DELETE;
			r_sa_tmp.attribute6.DELETE;
			r_sa_tmp.attribute7.DELETE;
			r_sa_tmp.attribute8.DELETE;
			r_sa_tmp.attribute9.DELETE;
			r_sa_tmp.attribute10.DELETE;
			r_sa_tmp.acct_type.DELETE;
		END IF;
		hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	r_sa.line_account_id.COUNT: ' || r_sa.line_account_id.COUNT);
	END IF;

	r_gsa.line_account_id.DELETE;
	r_gsa.gl_code_combination_id.DELETE;
	r_gsa.project_id.DELETE;
	r_gsa.task_id.DELETE;
	r_gsa.award_id.DELETE;
	r_gsa.expenditure_type.DELETE;
	r_gsa.expenditure_organization_id.DELETE;
	r_gsa.start_date_active.DELETE;
	r_gsa.end_date_active.DELETE;
	r_gsa.poeta_start_date.DELETE;
	r_gsa.poeta_end_date.DELETE;
	r_gsa.percent.DELETE;
	r_gsa.attribute_category.DELETE;
	r_gsa.attribute1.DELETE;
	r_gsa.attribute2.DELETE;
	r_gsa.attribute3.DELETE;
	r_gsa.attribute4.DELETE;
	r_gsa.attribute5.DELETE;
	r_gsa.attribute6.DELETE;
	r_gsa.attribute7.DELETE;
	r_gsa.attribute8.DELETE;
	r_gsa.attribute9.DELETE;
	r_gsa.attribute10.DELETE;
	r_gsa.acct_type.DELETE;

	g_pateo_end_date := fnd_date.canonical_to_date('1800/01/01 00:00:00');

	hr_utility.trace('
Global Element Hierarchy');
	hr_utility.trace(LPAD('Element Account Id', 18, ' ') || '	' ||
		RPAD('Start Date Active', 17, ' ') || '	' || RPAD('End Date Active', 17, ' ') || '	' ||
		RPAD('PATEO Start Date', 17, ' ') || '	' || RPAD('PATEO End Date', 17, ' ') || '	' ||
		LPAD('GL CC Id', 15, ' ') || '	' || LPAD('Project Id', 15, ' ') || '	' ||
		LPAD('Task Id', 15, ' ') || '	' || LPAD('Award Id', 15, ' ') || '	' ||
		LPAD('Expenditure Org Id', 18, ' ') || '	' || RPAD('Expenditure Type', 30, ' ') || '	' ||
		LPAD('Percent', 10, ' '));

	hr_utility.trace(LPAD('-', 18, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 18, '-') || '	' ||
		RPAD('-', 30, '-') || '	' || LPAD('-', 10, '-'));

	FOR recno IN 1..r_gee.line_account_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_gee.line_account_id(recno), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_gee.start_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_gee.end_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_gee.poeta_start_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_gee.poeta_end_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			LPAD(NVL(r_gee.gl_code_combination_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_gee.project_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_gee.task_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_gee.award_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_gee.expenditure_organization_id(recno), '-1'), 18, ' ') || '	' ||
			RPAD(NVL(r_gee.expenditure_type(recno), ' '), 30, ' ') || '	' ||
			LPAD(r_gee.percent(recno), 10, ' '));

		IF (r_gee.expenditure_type(recno) IS NOT NULL) THEN
			psp_enc_pre_process.validate_poeta (p_project_id		=>	r_gee.project_id(recno),
				p_task_id			=>	r_gee.task_id(recno),
				p_award_id			=>	r_gee.award_id(recno),
				p_expenditure_type		=>	r_gee.expenditure_type(recno),
				p_expenditure_organization_id	=>	r_gee.expenditure_organization_id(recno),
				p_payroll_id			=>	p_payroll_id,
				p_start_date			=>	r_gee.poeta_start_date(recno),
				p_end_date			=>	r_gee.poeta_end_date(recno),
				p_return_status			=>	p_return_status);

			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
		g_pateo_end_date := GREATEST(g_pateo_end_date, NVL(r_gee.poeta_end_date(recno), g_pateo_end_date));
	END LOOP;

	hr_utility.trace('
Element Type Hierarchy');
	hr_utility.trace(LPAD('Schedule Line Id', 17, ' ') || '	' ||
		RPAD('Start Date Active', 17, ' ') || '	' || RPAD('End Date Active', 17, ' ') || '	' ||
		RPAD('PATEO Start Date', 17, ' ') || '	' || RPAD('PATEO End Date', 17, ' ') || '	' ||
		LPAD('GL CC Id', 15, ' ') || '	' || LPAD('Project Id', 15, ' ') || '	' ||
		LPAD('Task Id', 15, ' ') || '	' || LPAD('Award Id', 15, ' ') || '	' ||
		LPAD('Expenditure Org Id', 18, ' ') || '	' || RPAD('Expenditure Type', 30, ' ') || '	' ||
		LPAD('Percent', 10, ' '));

	hr_utility.trace(LPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 18, '-') || '	' ||
		RPAD('-', 30, '-') || '	' || LPAD('-', 10, '-'));

	FOR recno IN 1..r_et.line_account_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_et.line_account_id(recno), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_et.start_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_et.end_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_et.poeta_start_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_et.poeta_end_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			LPAD(NVL(r_et.gl_code_combination_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_et.project_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_et.task_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_et.award_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_et.expenditure_organization_id(recno), '-1'), 18, ' ') || '	' ||
			RPAD(NVL(r_et.expenditure_type(recno), ' '), 30, ' ') || '	' ||
			LPAD(r_et.percent(recno), 10, ' '));
		IF (r_et.expenditure_type(recno) IS NOT NULL) THEN
			psp_enc_pre_process.validate_poeta (p_project_id		=>	r_et.project_id(recno),
				p_task_id			=>	r_et.task_id(recno),
				p_award_id			=>	r_et.award_id(recno),
				p_expenditure_type		=>	r_et.expenditure_type(recno),
				p_expenditure_organization_id	=>	r_et.expenditure_organization_id(recno),
				p_payroll_id			=>	p_payroll_id,
				p_start_date			=>	r_et.poeta_start_date(recno),
				p_end_date			=>	r_et.poeta_end_date(recno),
				p_return_status			=>	p_return_status);

			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
		g_pateo_end_date := GREATEST(g_pateo_end_date, NVL(r_et.poeta_end_date(recno), g_pateo_end_date));
	END LOOP;

	hr_utility.trace('
Element Class Hierarchy');
	hr_utility.trace(LPAD('Schedule Line Id', 17, ' ') || '	' ||
		RPAD('Start Date Active', 17, ' ') || '	' || RPAD('End Date Active', 17, ' ') || '	' ||
		RPAD('PATEO Start Date', 17, ' ') || '	' || RPAD('PATEO End Date', 17, ' ') || '	' ||
		LPAD('GL CC Id', 15, ' ') || '	' || LPAD('Project Id', 15, ' ') || '	' ||
		LPAD('Task Id', 15, ' ') || '	' || LPAD('Award Id', 15, ' ') || '	' ||
		LPAD('Expenditure Org Id', 18, ' ') || '	' || RPAD('Expenditure Type', 30, ' ') || '	' ||
		LPAD('Percent', 10, ' '));

	hr_utility.trace(LPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 18, '-') || '	' ||
		RPAD('-', 30, '-') || '	' || LPAD('-', 10, '-'));

	FOR recno IN 1..r_ec.line_account_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_ec.line_account_id(recno), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_ec.start_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_ec.end_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_ec.poeta_start_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_ec.poeta_end_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			LPAD(NVL(r_ec.gl_code_combination_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_ec.project_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_ec.task_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_ec.award_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_ec.expenditure_organization_id(recno), '-1'), 18, ' ') || '	' ||
			RPAD(NVL(r_ec.expenditure_type(recno), ' '), 30, ' ') || '	' ||
			LPAD(r_ec.percent(recno), 10, ' '));
		IF (r_ec.expenditure_type(recno) IS NOT NULL) THEN
			psp_enc_pre_process.validate_poeta (p_project_id		=>	r_ec.project_id(recno),
				p_task_id			=>	r_ec.task_id(recno),
				p_award_id			=>	r_ec.award_id(recno),
				p_expenditure_type		=>	r_ec.expenditure_type(recno),
				p_expenditure_organization_id	=>	r_ec.expenditure_organization_id(recno),
				p_payroll_id			=>	p_payroll_id,
				p_start_date			=>	r_ec.poeta_start_date(recno),
				p_end_date			=>	r_ec.poeta_end_date(recno),
				p_return_status			=>	p_return_status);

			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
		g_pateo_end_date := GREATEST(g_pateo_end_date, NVL(r_ec.poeta_end_date(recno), g_pateo_end_date));
	END LOOP;

	hr_utility.trace('
Assignment Hierarchy');
	hr_utility.trace(LPAD('Schedule Line Id', 17, ' ') || '	' ||
		RPAD('Start Date Active', 17, ' ') || '	' || RPAD('End Date Active', 17, ' ') || '	' ||
		RPAD('PATEO Start Date', 17, ' ') || '	' || RPAD('PATEO End Date', 17, ' ') || '	' ||
		LPAD('GL CC Id', 15, ' ') || '	' || LPAD('Project Id', 15, ' ') || '	' ||
		LPAD('Task Id', 15, ' ') || '	' || LPAD('Award Id', 15, ' ') || '	' ||
		LPAD('Expenditure Org Id', 18, ' ') || '	' || RPAD('Expenditure Type', 30, ' ') || '	' ||
		LPAD('Percent', 10, ' '));

	hr_utility.trace(LPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 18, '-') || '	' ||
		RPAD('-', 30, '-') || '	' || LPAD('-', 10, '-'));

	FOR recno IN 1..r_asg.line_account_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_asg.line_account_id(recno), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_asg.start_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_asg.end_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_asg.poeta_start_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_asg.poeta_end_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			LPAD(NVL(r_asg.gl_code_combination_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_asg.project_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_asg.task_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_asg.award_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_asg.expenditure_organization_id(recno), '-1'), 18, ' ') || '	' ||
			RPAD(NVL(r_asg.expenditure_type(recno), ' '), 30, ' ') || '	' ||
			LPAD(r_asg.percent(recno), 10, ' '));
		IF (r_asg.expenditure_type(recno) IS NOT NULL) THEN
			psp_enc_pre_process.validate_poeta (p_project_id		=>	r_asg.project_id(recno),
				p_task_id			=>	r_asg.task_id(recno),
				p_award_id			=>	r_asg.award_id(recno),
				p_expenditure_type		=>	r_asg.expenditure_type(recno),
				p_expenditure_organization_id	=>	r_asg.expenditure_organization_id(recno),
				p_payroll_id			=>	p_payroll_id,
				p_start_date			=>	r_asg.poeta_start_date(recno),
				p_end_date			=>	r_asg.poeta_end_date(recno),
				p_return_status			=>	p_return_status);

			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
		g_pateo_end_date := GREATEST(g_pateo_end_date, NVL(r_asg.poeta_end_date(recno), g_pateo_end_date));
	END LOOP;

	hr_utility.trace('
Organization Default Schedules Hierarchy');
	hr_utility.trace(LPAD('Schedule Line Id', 17, ' ') || '	' ||
		RPAD('Start Date Active', 17, ' ') || '	' || RPAD('End Date Active', 17, ' ') || '	' ||
		RPAD('PATEO Start Date', 17, ' ') || '	' || RPAD('PATEO End Date', 17, ' ') || '	' ||
		LPAD('GL CC Id', 15, ' ') || '	' || LPAD('Project Id', 15, ' ') || '	' ||
		LPAD('Task Id', 15, ' ') || '	' || LPAD('Award Id', 15, ' ') || '	' ||
		LPAD('Expenditure Org Id', 18, ' ') || '	' || RPAD('Expenditure Type', 30, ' ') || '	' ||
		LPAD('Percent', 10, ' '));

	hr_utility.trace(LPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 18, '-') || '	' ||
		RPAD('-', 30, '-') || '	' || LPAD('-', 10, '-'));

	FOR recno IN 1..r_odls.line_account_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_odls.line_account_id(recno), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_odls.start_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_odls.end_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_odls.poeta_start_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_odls.poeta_end_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			LPAD(NVL(r_odls.gl_code_combination_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_odls.project_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_odls.task_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_odls.award_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_odls.expenditure_organization_id(recno), '-1'), 18, ' ') || '	' ||
			RPAD(NVL(r_odls.expenditure_type(recno), ' '), 30, ' ') || '	' ||
			LPAD(r_odls.percent(recno), 10, ' '));
		IF (r_odls.expenditure_type(recno) IS NOT NULL) THEN
			psp_enc_pre_process.validate_poeta (p_project_id		=>	r_odls.project_id(recno),
				p_task_id			=>	r_odls.task_id(recno),
				p_award_id			=>	r_odls.award_id(recno),
				p_expenditure_type		=>	r_odls.expenditure_type(recno),
				p_expenditure_organization_id	=>	r_odls.expenditure_organization_id(recno),
				p_payroll_id			=>	p_payroll_id,
				p_start_date			=>	r_odls.poeta_start_date(recno),
				p_end_date			=>	r_odls.poeta_end_date(recno),
				p_return_status			=>	p_return_status);

			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
		g_pateo_end_date := GREATEST(g_pateo_end_date, NVL(r_odls.poeta_end_date(recno), g_pateo_end_date));
	END LOOP;

	hr_utility.trace('
Organization Default Account Hierarchy');
	hr_utility.trace(LPAD('Line Account Id', 17, ' ') || '	' ||
		RPAD('Start Date Active', 17, ' ') || '	' || RPAD('End Date Active', 17, ' ') || '	' ||
		RPAD('PATEO Start Date', 17, ' ') || '	' || RPAD('PATEO End Date', 17, ' ') || '	' ||
		LPAD('GL CC Id', 15, ' ') || '	' || LPAD('Project Id', 15, ' ') || '	' ||
		LPAD('Task Id', 15, ' ') || '	' || LPAD('Award Id', 15, ' ') || '	' ||
		LPAD('Expenditure Org Id', 18, ' ') || '	' || RPAD('Expenditure Type', 30, ' ') || '	' ||
		LPAD('Percent', 10, ' '));

	hr_utility.trace(LPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 18, '-') || '	' ||
		RPAD('-', 30, '-') || '	' || LPAD('-', 10, '-'));

	FOR recno IN 1..r_da.line_account_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_da.line_account_id(recno), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_da.start_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_da.end_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_da.poeta_start_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_da.poeta_end_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			LPAD(NVL(r_da.gl_code_combination_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_da.project_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_da.task_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_da.award_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_da.expenditure_organization_id(recno), '-1'), 18, ' ') || '	' ||
			RPAD(NVL(r_da.expenditure_type(recno), ' '), 30, ' ') || '	' ||
			LPAD(r_da.percent(recno), 10, ' '));
		IF (r_da.expenditure_type(recno) IS NOT NULL) THEN
			psp_enc_pre_process.validate_poeta (p_project_id		=>	r_da.project_id(recno),
				p_task_id			=>	r_da.task_id(recno),
				p_award_id			=>	r_da.award_id(recno),
				p_expenditure_type		=>	r_da.expenditure_type(recno),
				p_expenditure_organization_id	=>	r_da.expenditure_organization_id(recno),
				p_payroll_id			=>	p_payroll_id,
				p_start_date			=>	r_da.poeta_start_date(recno),
				p_end_date			=>	r_da.poeta_end_date(recno),
				p_return_status			=>	p_return_status);

			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
		g_pateo_end_date := GREATEST(g_pateo_end_date, NVL(r_da.poeta_end_date(recno), g_pateo_end_date));
	END LOOP;

	hr_utility.trace('
Suspense Account Hierarchy');
	hr_utility.trace(LPAD('Line Account Id', 17, ' ') || '	' ||
		RPAD('Start Date Active', 17, ' ') || '	' || RPAD('End Date Active', 17, ' ') || '	' ||
		RPAD('PATEO Start Date', 17, ' ') || '	' || RPAD('PATEO End Date', 17, ' ') || '	' ||
		LPAD('GL CC Id', 15, ' ') || '	' || LPAD('Project Id', 15, ' ') || '	' ||
		LPAD('Task Id', 15, ' ') || '	' || LPAD('Award Id', 15, ' ') || '	' ||
		LPAD('Expenditure Org Id', 18, ' ') || '	' || RPAD('Expenditure Type', 30, ' ') || '	' ||
		LPAD('Percent', 10, ' '));

	hr_utility.trace(LPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' || RPAD('-', 17, '-') || '	' ||
		RPAD('-', 17, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 18, '-') || '	' ||
		RPAD('-', 30, '-') || '	' || LPAD('-', 10, '-'));

	FOR recno IN 1..r_sa.line_account_id.COUNT
	LOOP
		hr_utility.trace(LPAD(r_sa.line_account_id(recno), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_sa.start_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(TO_CHAR(r_sa.end_date_active(recno), 'DD-MON-RRRR'), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_sa.poeta_start_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			RPAD(NVL(TO_CHAR(r_sa.poeta_end_date(recno), 'DD-MON-RRRR'), ' '), 17, ' ') || '	' ||
			LPAD(NVL(r_sa.gl_code_combination_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_sa.project_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_sa.task_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_sa.award_id(recno), '-1'), 15, ' ') || '	' ||
			LPAD(NVL(r_sa.expenditure_organization_id(recno), '-1'), 18, ' ') || '	' ||
			RPAD(NVL(r_sa.expenditure_type(recno), ' '), 30, ' ') || '	' ||
			LPAD(r_sa.percent(recno), 10, ' '));
		IF (r_sa.expenditure_type(recno) IS NOT NULL) THEN
			psp_enc_pre_process.validate_poeta (p_project_id		=>	r_sa.project_id(recno),
				p_task_id			=>	r_sa.task_id(recno),
				p_award_id			=>	r_sa.award_id(recno),
				p_expenditure_type		=>	r_sa.expenditure_type(recno),
				p_expenditure_organization_id	=>	r_sa.expenditure_organization_id(recno),
				p_payroll_id			=>	p_payroll_id,
				p_start_date			=>	r_sa.poeta_start_date(recno),
				p_end_date			=>	r_sa.poeta_end_date(recno),
				p_return_status			=>	p_return_status);

			IF p_return_status <> fnd_api.g_ret_sts_success THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
		g_pateo_end_date := GREATEST(g_pateo_end_date, NVL(r_sa.poeta_end_date(recno), g_pateo_end_date));
	END LOOP;

	IF ((g_pateo_end_date = fnd_date.canonical_to_date('1800/01/01 00:00:00')) OR
		(g_pateo_end_date < g_enc_org_end_date)) THEN
		g_pateo_end_date := g_enc_org_end_date;
	END IF;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	g_pateo_end_date: ' || TO_CHAR(g_pateo_end_date, 'DD-MON-RRRR'));

	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Leaving LOAD_SCH_HIERARCHY');
	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
WHEN OTHERS THEN
		IF (g_error_message IS NULL) THEN
			g_error_message := 'LOAD_SCH_HIERARCHY: ' || SQLERRM;
		END IF;
        g_error_api_path := SUBSTR(' LOAD_SCH_HIERARCHY:'||g_error_api_path,1,230);
        fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', ' LOAD_SCH_HIERARCHY');
        p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	' || fnd_number.number_to_canonical(l_proc_step) || ':  LOAD_SCH_HIERARCHY');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving LOAD_SCH_HIERARCHY');
END load_sch_hierarchy;

PROCEDURE	add_cel_warnings(p_start_date		IN	DATE		DEFAULT NULL,
				p_end_date		IN	DATE		DEFAULT NULL,
				p_hierarchy_code	IN	VARCHAR2	DEFAULT NULL,
				p_warning_code		IN	VARCHAR2	DEFAULT NULL,
				p_gl_ccid		IN	NUMBER		DEFAULT NULL,
				p_project_id		IN	NUMBER		DEFAULT NULL,
				p_task_id		IN	NUMBER		DEFAULT NULL,
				p_award_id		IN	NUMBER		DEFAULT NULL,
				p_exp_org_id		IN	NUMBER		DEFAULT NULL,
				p_exp_type		IN	VARCHAR2	DEFAULT NULL,
				p_effective_date	IN	DATE		DEFAULT NULL,
				p_error_status		IN	VARCHAR2	DEFAULT NULL,
				p_percent		IN	NUMBER		DEFAULT NULL) IS
l_warning_ind		NUMBER(15);
l_duplicate_ind		NUMBER(15);
BEGIN
	hr_utility.trace('Entering add_cel_warnings');
	l_warning_ind := cel_warnings.start_date.COUNT;
	hr_utility.trace('p_start_date: ' || p_start_date || ' p_end_date: ' || p_end_date ||
		' p_hierarchy_code: ' || p_hierarchy_code || ' p_warning_code: ' || p_warning_code ||
		' p_gl_ccid: ' || p_gl_ccid || ' p_project_id: ' || p_project_id || ' p_task_id: ' || p_task_id ||
		' p_award_id:' || p_award_id || ' p_exp_org_id: ' || p_exp_org_id ||
		' p_exp_type: ' || p_exp_type || ' p_effective_date: ' || p_effective_date ||
		' p_error_status: ' || p_error_status || ' p_percent: ' || p_percent);

	IF (p_warning_code = 'BAL') THEN
		LOOP
			EXIT WHEN l_warning_ind = 0;
			EXIT WHEN ((	(cel_warnings.end_date(l_warning_ind) = (p_start_date -1) OR
						(	(cel_warnings.end_date(l_warning_ind) >= p_start_date) AND
							(cel_warnings.start_date(l_warning_ind) <= p_end_date)))) AND
				(cel_warnings.hierarchy_code(l_warning_ind) = p_hierarchy_code) AND
				(cel_warnings.warning_code(l_warning_ind) = 'BAL') AND
				(cel_warnings.percent(l_warning_ind) = p_percent));
			l_warning_ind := l_warning_ind - 1;
		END LOOP;
		hr_utility.trace('processing bal l_warning_ind: ' || l_warning_ind);

		l_duplicate_ind := cel_warnings.start_date.COUNT;
		LOOP
			EXIT WHEN l_duplicate_ind = 0;
			EXIT WHEN ((	(cel_warnings.end_date(l_duplicate_ind) = (p_start_date -1) OR
						(	(cel_warnings.end_date(l_duplicate_ind) >= p_start_date) AND
							(cel_warnings.start_date(l_duplicate_ind) <= p_end_date)))) AND
				(cel_warnings.hierarchy_code(l_duplicate_ind) <> p_hierarchy_code) AND
				(cel_warnings.warning_code(l_duplicate_ind) = 'BAL') AND
				(cel_warnings.percent(l_duplicate_ind) = p_percent));
			l_duplicate_ind := l_duplicate_ind - 1;
		END LOOP;
		hr_utility.trace('processing bal l_duplicate_ind: ' || l_duplicate_ind);

		IF (l_warning_ind = 0) THEN
			l_warning_ind := cel_warnings.start_date.COUNT + 1;
			cel_warnings.start_date(l_warning_ind) := p_start_date;
			cel_warnings.end_date(l_warning_ind) := p_end_date;
			cel_warnings.hierarchy_code(l_warning_ind) := p_hierarchy_code;
			cel_warnings.warning_code(l_warning_ind) := p_warning_code;
			cel_warnings.gl_ccid(l_warning_ind) := NULL;
			cel_warnings.project_id(l_warning_ind) := NULL;
			cel_warnings.task_id(l_warning_ind) := NULL;
			cel_warnings.award_id(l_warning_ind) := NULL;
			cel_warnings.exp_org_id(l_warning_ind) := NULL;
			cel_warnings.exp_type(l_warning_ind) := NULL;
			cel_warnings.effective_date(l_warning_ind) := NULL;
			cel_warnings.error_status(l_warning_ind) := NULL;
			cel_warnings.percent(l_warning_ind) := p_percent;
		ELSE
			cel_warnings.end_date(l_warning_ind) := p_end_date;
		END IF;

		IF (l_duplicate_ind > 0) THEN
			cel_warnings.end_date(l_duplicate_ind) := p_end_date;
			cel_warnings.start_date(l_warning_ind) := cel_warnings.start_date(l_duplicate_ind);
		END IF;
	ELSIF (p_warning_code = 'NO_CI') THEN
		LOOP
			EXIT WHEN l_warning_ind = 0;
			EXIT WHEN ((	(cel_warnings.end_date(l_warning_ind) = (p_start_date -1) OR
							(	(cel_warnings.end_date(l_warning_ind) >= p_start_date) AND
								(cel_warnings.start_date(l_warning_ind) <= p_end_date)))) AND
				(cel_warnings.hierarchy_code(l_warning_ind) = p_hierarchy_code) AND
				(cel_warnings.warning_code(l_warning_ind) = 'NO_CI'));
			l_warning_ind := l_warning_ind - 1;
		END LOOP;
		hr_utility.trace('processing no_ci l_warning_ind: ' || l_warning_ind);

		l_duplicate_ind := cel_warnings.start_date.COUNT;
		LOOP
			EXIT WHEN l_duplicate_ind = 0;
			EXIT WHEN ((	(cel_warnings.end_date(l_duplicate_ind) = (p_start_date -1) OR
							(	(cel_warnings.end_date(l_duplicate_ind) >= p_start_date) AND
								(cel_warnings.start_date(l_duplicate_ind) <= p_end_date)))) AND
				(cel_warnings.hierarchy_code(l_duplicate_ind) <> p_hierarchy_code) AND
				(cel_warnings.warning_code(l_duplicate_ind) = 'NO_CI'));
			l_duplicate_ind := l_duplicate_ind - 1;
		END LOOP;
		hr_utility.trace('processing no_ci l_duplicate_ind: ' || l_duplicate_ind);

		IF (l_warning_ind = 0) THEN
			l_warning_ind := cel_warnings.start_date.COUNT + 1;
			cel_warnings.start_date(l_warning_ind) := p_start_date;
			cel_warnings.end_date(l_warning_ind) := p_end_date;
			cel_warnings.hierarchy_code(l_warning_ind) := p_hierarchy_code;
			cel_warnings.warning_code(l_warning_ind) := p_warning_code;
			cel_warnings.gl_ccid(l_warning_ind) := NULL;
			cel_warnings.project_id(l_warning_ind) := NULL;
			cel_warnings.task_id(l_warning_ind) := NULL;
			cel_warnings.award_id(l_warning_ind) := NULL;
			cel_warnings.exp_org_id(l_warning_ind) := NULL;
			cel_warnings.exp_type(l_warning_ind) := NULL;
			cel_warnings.effective_date(l_warning_ind) := NULL;
			cel_warnings.error_status(l_warning_ind) := NULL;
			cel_warnings.percent(l_warning_ind) := NULL;
		ELSE
			cel_warnings.end_date(l_warning_ind) := p_end_date;
		END IF;

		IF (l_duplicate_ind > 0) THEN
			cel_warnings.end_date(l_duplicate_ind) := p_end_date;
			cel_warnings.start_date(l_warning_ind) := cel_warnings.start_date(l_duplicate_ind);
		END IF;
	ELSIF (p_warning_code = 'INVALID_CI') THEN
		LOOP
			EXIT WHEN l_warning_ind = 0;
			EXIT WHEN ((	(cel_warnings.end_date(l_warning_ind) = (p_start_date -1) OR
							(	(cel_warnings.end_date(l_warning_ind) >= p_start_date) AND
								(cel_warnings.start_date(l_warning_ind) <= p_end_date)))) AND
				(cel_warnings.hierarchy_code(l_warning_ind) = p_hierarchy_code) AND
				(cel_warnings.warning_code(l_warning_ind) = 'INVALID_CI') AND
				(cel_warnings.project_id(l_warning_ind) = p_project_id) AND
				(cel_warnings.task_id(l_warning_ind) = p_task_id) AND
				(cel_warnings.award_id(l_warning_ind) = p_award_id) AND
				(cel_warnings.exp_org_id(l_warning_ind) = p_exp_org_id) AND
				(cel_warnings.exp_type(l_warning_ind) = p_exp_type) AND
				(NVL(cel_warnings.error_status(l_warning_ind), 'NULL') = NVL(p_error_status, 'NULL')));
			l_warning_ind := l_warning_ind - 1;
		END LOOP;
		hr_utility.trace('processing invalid_ci l_warning_ind: ' || l_warning_ind);

		IF (l_warning_ind = 0) THEN
			l_warning_ind := cel_warnings.start_date.COUNT + 1;
			cel_warnings.start_date(l_warning_ind) := p_start_date;
			cel_warnings.end_date(l_warning_ind) := p_end_date;
			cel_warnings.hierarchy_code(l_warning_ind) := p_hierarchy_code;
			cel_warnings.warning_code(l_warning_ind) := p_warning_code;
			cel_warnings.gl_ccid(l_warning_ind) := NULL;
			cel_warnings.project_id(l_warning_ind) := p_project_id;
			cel_warnings.task_id(l_warning_ind) := p_task_id;
			cel_warnings.award_id(l_warning_ind) := p_award_id;
			cel_warnings.exp_org_id(l_warning_ind) := p_exp_org_id;
			cel_warnings.exp_type(l_warning_ind) := p_exp_type;
			cel_warnings.effective_date(l_warning_ind) := p_effective_date;
			cel_warnings.error_status(l_warning_ind) := p_error_status;
			cel_warnings.percent(l_warning_ind) := NULL;
		ELSE
			cel_warnings.end_date(l_warning_ind) := p_end_date;
		END IF;
	ELSIF (p_warning_code = 'AUTOPOP') AND (p_gl_ccid IS NOT NULL) THEN
		LOOP
			EXIT WHEN l_warning_ind = 0;
			EXIT WHEN ((	(cel_warnings.end_date(l_warning_ind) = (p_start_date -1) OR
							(	(cel_warnings.end_date(l_warning_ind) >= p_start_date) AND
								(cel_warnings.start_date(l_warning_ind) <= p_end_date)))) AND
				(cel_warnings.hierarchy_code(l_warning_ind) = p_hierarchy_code) AND
				(cel_warnings.warning_code(l_warning_ind) = 'AUTOPOP') AND
				(cel_warnings.gl_ccid(l_warning_ind) = p_gl_ccid) AND
				(NVL(cel_warnings.error_status(l_warning_ind), 'NULL') = NVL(p_error_status, 'NULL')));
			l_warning_ind := l_warning_ind - 1;
		END LOOP;
		hr_utility.trace('processing autopop l_warning_ind: ' || l_warning_ind);

		IF (l_warning_ind = 0) THEN
			l_warning_ind := cel_warnings.start_date.COUNT + 1;
			cel_warnings.start_date(l_warning_ind) := p_start_date;
			cel_warnings.end_date(l_warning_ind) := p_end_date;
			cel_warnings.hierarchy_code(l_warning_ind) := p_hierarchy_code;
			cel_warnings.warning_code(l_warning_ind) := p_warning_code;
			cel_warnings.gl_ccid(l_warning_ind) := p_gl_ccid;
			cel_warnings.project_id(l_warning_ind) := NULL;
			cel_warnings.task_id(l_warning_ind) := NULL;
			cel_warnings.award_id(l_warning_ind) := NULL;
			cel_warnings.exp_org_id(l_warning_ind) := NULL;
			cel_warnings.exp_type(l_warning_ind) := NULL;
			cel_warnings.effective_date(l_warning_ind) := NULL;
			cel_warnings.error_status(l_warning_ind) := p_error_status;
			cel_warnings.percent(l_warning_ind) := NULL;
		ELSE
			cel_warnings.end_date(l_warning_ind) := p_end_date;
		END IF;
	ELSIF (p_warning_code = 'AUTOPOP') AND (p_gl_ccid IS NULL) THEN
		LOOP
			EXIT WHEN l_warning_ind = 0;
			EXIT WHEN ((	(cel_warnings.end_date(l_warning_ind) = (p_start_date -1) OR
							(	(cel_warnings.end_date(l_warning_ind) >= p_start_date) AND
								(cel_warnings.start_date(l_warning_ind) <= p_end_date)))) AND
				(cel_warnings.hierarchy_code(l_warning_ind) = p_hierarchy_code) AND
				(cel_warnings.warning_code(l_warning_ind) = 'AUTOPOP') AND
				(cel_warnings.project_id(l_warning_ind) = p_project_id) AND
				(cel_warnings.task_id(l_warning_ind) = p_task_id) AND
				(cel_warnings.award_id(l_warning_ind) = p_award_id) AND
				(cel_warnings.exp_org_id(l_warning_ind) = p_exp_org_id) AND
				(cel_warnings.exp_type(l_warning_ind) = p_exp_type) AND
				(NVL(cel_warnings.error_status(l_warning_ind), 'NULL') = NVL(p_error_status, 'NULL')));
			l_warning_ind := l_warning_ind - 1;
		END LOOP;
		hr_utility.trace('processing autopop l_warning_ind: ' || l_warning_ind);

		IF (l_warning_ind = 0) THEN
			l_warning_ind := cel_warnings.start_date.COUNT + 1;
			cel_warnings.start_date(l_warning_ind) := p_start_date;
			cel_warnings.end_date(l_warning_ind) := p_end_date;
			cel_warnings.hierarchy_code(l_warning_ind) := p_hierarchy_code;
			cel_warnings.warning_code(l_warning_ind) := p_warning_code;
			cel_warnings.gl_ccid(l_warning_ind) := NULL;
			cel_warnings.project_id(l_warning_ind) := p_project_id;
			cel_warnings.task_id(l_warning_ind) := p_task_id;
			cel_warnings.award_id(l_warning_ind) := p_award_id;
			cel_warnings.exp_org_id(l_warning_ind) := p_exp_org_id;
			cel_warnings.exp_type(l_warning_ind) := p_exp_type;
			cel_warnings.effective_date(l_warning_ind) := NULL;
			cel_warnings.error_status(l_warning_ind) := p_error_status;
			cel_warnings.percent(l_warning_ind) := NULL;
		ELSE
			cel_warnings.end_date(l_warning_ind) := p_end_date;
		END IF;
	   ELSIF (p_warning_code = 'GL') THEN
		LOOP
			EXIT WHEN l_warning_ind = 0;
			EXIT WHEN ((	(cel_warnings.end_date(l_warning_ind) = (p_start_date -1) OR
						(	(cel_warnings.end_date(l_warning_ind) >= p_start_date) AND
							(cel_warnings.start_date(l_warning_ind) <= p_end_date)))) AND
				(cel_warnings.hierarchy_code(l_warning_ind) = p_hierarchy_code) AND
				(cel_warnings.warning_code(l_warning_ind) = 'GL'));
			l_warning_ind := l_warning_ind - 1;
		END LOOP;
		hr_utility.trace('processing bal l_warning_ind: ' || l_warning_ind);

		l_duplicate_ind := cel_warnings.start_date.COUNT;
		LOOP
			EXIT WHEN l_duplicate_ind = 0;
			EXIT WHEN ((	(cel_warnings.end_date(l_duplicate_ind) = (p_start_date -1) OR
						(	(cel_warnings.end_date(l_duplicate_ind) >= p_start_date) AND
							(cel_warnings.start_date(l_duplicate_ind) <= p_end_date)))) AND
				(cel_warnings.hierarchy_code(l_duplicate_ind) <> p_hierarchy_code) AND
				(cel_warnings.warning_code(l_duplicate_ind) = 'GL'));
			l_duplicate_ind := l_duplicate_ind - 1;
		END LOOP;
		hr_utility.trace('processing bal l_duplicate_ind: ' || l_duplicate_ind);

		IF (l_warning_ind = 0) THEN
			l_warning_ind := cel_warnings.start_date.COUNT + 1;
			cel_warnings.start_date(l_warning_ind) := p_start_date;
			cel_warnings.end_date(l_warning_ind) := p_end_date;
			cel_warnings.hierarchy_code(l_warning_ind) := p_hierarchy_code;
			cel_warnings.warning_code(l_warning_ind) := p_warning_code;
			cel_warnings.gl_ccid(l_warning_ind) := NULL;
			cel_warnings.project_id(l_warning_ind) := NULL;
			cel_warnings.task_id(l_warning_ind) := NULL;
			cel_warnings.award_id(l_warning_ind) := NULL;
			cel_warnings.exp_org_id(l_warning_ind) := NULL;
			cel_warnings.exp_type(l_warning_ind) := NULL;
			cel_warnings.effective_date(l_warning_ind) := NULL;
			cel_warnings.error_status(l_warning_ind) := NULL;
			cel_warnings.percent(l_warning_ind) := p_percent;
		ELSE
			cel_warnings.end_date(l_warning_ind) := p_end_date;
			cel_warnings.percent(l_warning_ind) := cel_warnings.percent(l_warning_ind) + p_percent;
		END IF;

		IF (l_duplicate_ind > 0) THEN
			cel_warnings.end_date(l_duplicate_ind) := p_end_date;
			cel_warnings.start_date(l_warning_ind) := cel_warnings.start_date(l_duplicate_ind);
			cel_warnings.percent(l_warning_ind) := cel_warnings.percent(l_duplicate_ind) + p_percent;
		END IF;
	END IF;
	hr_utility.trace('cel_warnings.start_date.COUNT: ' || cel_warnings.start_date.COUNT);
	hr_utility.trace('Leaving add_cel_warnings');
END	add_cel_warnings;

PROCEDURE	delete_previous_error_log(p_assignment_id	IN	NUMBER,
					  p_payroll_id	IN	NUMBER,
					  p_payroll_action_id	IN	NUMBER) IS
PRAGMA	AUTONOMOUS_TRANSACTION;
BEGIN
	DELETE	psp_report_errors
	WHERE	source_id = p_assignment_id
	AND		value1 = p_payroll_id
	AND		payroll_action_id = p_payroll_action_id;

	COMMIT;
END	delete_previous_error_log;

PROCEDURE update_hierarchy_dates (p_assignment_id	IN	NUMBER,
					p_payroll_id		IN	NUMBER,
					p_payroll_action_id	IN	NUMBER,
					p_return_status		OUT NOCOPY	VARCHAR2) IS
CURSOR	hierarchy_dates_cur IS
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
FROM	psp_enc_lines
WHERE	payroll_action_id = p_payroll_action_id
AND	assignment_id = p_assignment_id
AND	payroll_id = p_payroll_id
ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

CURSOR	history_dates_cur IS
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
FROM	psp_enc_lines_history
WHERE	assignment_id = p_assignment_id
AND	payroll_id = p_payroll_id
AND	change_flag = 'N'
ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

TYPE r_enc_rec IS RECORD
	(element_type_id	t_num_15_type,
	hierarchy_code		t_varchar_50_type,
	gl_ccid			t_num_15_type,
	project_id		t_num_15_type,
	task_id			t_num_15_type,
	award_id		t_num_15_type,
	exp_org_id		t_num_15_type,
	exp_type		t_varchar_50_type,
	enc_start_date		t_date_type,
	enc_end_date		t_date_type);

t_enc_lines			r_enc_rec;
t_enc_nlines		r_enc_rec;
l_nlines_counter	NUMBER(15);
BEGIN
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Entering UPDATE_HIERARCHY_DATES');
	OPEN hierarchy_dates_cur;
	FETCH hierarchy_dates_cur BULK COLLECT INTO t_enc_lines.element_type_id, t_enc_lines.hierarchy_code,
			t_enc_lines.gl_ccid,		t_enc_lines.project_id,		t_enc_lines.task_id,
			t_enc_lines.award_id,		t_enc_lines.exp_org_id,		t_enc_lines.exp_type,
			t_enc_lines.enc_start_date, t_enc_lines.enc_end_date;
	CLOSE hierarchy_dates_cur;

	IF (t_enc_lines.element_type_id.COUNT > 0) THEN
		t_enc_nlines.element_type_id(1) := t_enc_lines.element_type_id(1);
		t_enc_nlines.hierarchy_code(1) := t_enc_lines.hierarchy_code(1);
		t_enc_nlines.gl_ccid(1) := t_enc_lines.gl_ccid(1);
		t_enc_nlines.project_id(1) := t_enc_lines.project_id(1);
		t_enc_nlines.task_id(1) := t_enc_lines.task_id(1);
		t_enc_nlines.award_id(1) := t_enc_lines.award_id(1);
		t_enc_nlines.exp_org_id(1) := t_enc_lines.exp_org_id(1);
		t_enc_nlines.exp_type(1) := t_enc_lines.exp_type(1);
		t_enc_nlines.enc_start_date(1) := t_enc_lines.enc_start_date(1);
		t_enc_nlines.enc_end_date(1) := t_enc_lines.enc_end_date(1);
		l_nlines_counter := 1;
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
				t_enc_lines.enc_start_date(recno) -1 = t_enc_lines.enc_end_date(recno-1)) THEN
				t_enc_nlines.enc_end_date(l_nlines_counter) := t_enc_lines.enc_end_date(recno);
			ELSE
				l_nlines_counter := l_nlines_counter + 1;
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
		UPDATE	psp_enc_lines
		SET	hierarchy_start_date = t_enc_nlines.enc_start_date(recno),
			hierarchy_end_date = t_enc_nlines.enc_end_date(recno)
		WHERE	payroll_action_id = p_payroll_action_id
		AND	assignment_id = p_assignment_id
		AND	payroll_id = p_payroll_id
		AND	enc_element_type_id = t_enc_nlines.element_type_id(recno)
		AND	hierarchy_code = t_enc_nlines.hierarchy_code(recno)
		AND	gl_code_combination_id IS NOT NULL
		AND	t_enc_nlines.gl_ccid(recno) IS NOT NULL
		AND	gl_code_combination_id = t_enc_nlines.gl_ccid(recno)
		AND	enc_start_date <= t_enc_nlines.enc_end_date(recno)
		AND	enc_end_date >= t_enc_nlines.enc_start_date(recno);

		FORALL recno IN 1..t_enc_nlines.element_type_id.COUNT
		UPDATE	psp_enc_lines
		SET	hierarchy_start_date = t_enc_nlines.enc_start_date(recno),
			hierarchy_end_date = t_enc_nlines.enc_end_date(recno)
		WHERE	payroll_action_id = p_payroll_action_id
		AND	assignment_id = p_assignment_id
		AND	payroll_id = p_payroll_id
		AND	enc_element_type_id = t_enc_nlines.element_type_id(recno)
		AND	hierarchy_code = t_enc_nlines.hierarchy_code(recno)
		AND	award_id IS NOT NULL
		AND	t_enc_nlines.award_id(recno) IS NOT NULL
		AND	project_id = t_enc_nlines.project_id(recno)
		AND	task_id = t_enc_nlines.task_id(recno)
		AND	award_id = t_enc_nlines.award_id(recno)
		AND	expenditure_organization_id = t_enc_nlines.exp_org_id(recno)
		AND	expenditure_type = t_enc_nlines.exp_type(recno)
		AND	enc_start_date <= t_enc_nlines.enc_end_date(recno)
		AND	enc_end_date >= t_enc_nlines.enc_start_date(recno);
	END IF;

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

	t_enc_nlines.element_type_id.DELETE;
	t_enc_nlines.hierarchy_code.DELETE;
	t_enc_nlines.gl_ccid.DELETE;
	t_enc_nlines.project_id.DELETE;
	t_enc_nlines.task_id.DELETE;
	t_enc_nlines.award_id.DELETE;
	t_enc_nlines.exp_org_id.DELETE;
	t_enc_nlines.exp_type.DELETE;
	t_enc_nlines.enc_start_date.DELETE;
	t_enc_nlines.enc_end_date.DELETE;

	OPEN history_dates_cur;
	FETCH history_dates_cur BULK COLLECT INTO t_enc_lines.element_type_id, t_enc_lines.hierarchy_code,
			t_enc_lines.gl_ccid,		t_enc_lines.project_id,		t_enc_lines.task_id,
			t_enc_lines.award_id,		t_enc_lines.exp_org_id,		t_enc_lines.exp_type,
			t_enc_lines.enc_start_date, t_enc_lines.enc_end_date;
	CLOSE history_dates_cur;

	IF (t_enc_lines.element_type_id.COUNT > 0) THEN
		t_enc_nlines.element_type_id(1) := t_enc_lines.element_type_id(1);
		t_enc_nlines.hierarchy_code(1) := t_enc_lines.hierarchy_code(1);
		t_enc_nlines.gl_ccid(1) := t_enc_lines.gl_ccid(1);
		t_enc_nlines.project_id(1) := t_enc_lines.project_id(1);
		t_enc_nlines.task_id(1) := t_enc_lines.task_id(1);
		t_enc_nlines.award_id(1) := t_enc_lines.award_id(1);
		t_enc_nlines.exp_org_id(1) := t_enc_lines.exp_org_id(1);
		t_enc_nlines.exp_type(1) := t_enc_lines.exp_type(1);
		t_enc_nlines.enc_start_date(1) := t_enc_lines.enc_start_date(1);
		t_enc_nlines.enc_end_date(1) := t_enc_lines.enc_end_date(1);
		l_nlines_counter := 1;
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
				t_enc_lines.enc_start_date(recno) -1 = t_enc_lines.enc_end_date(recno-1)) THEN
				t_enc_nlines.enc_end_date(l_nlines_counter) := t_enc_lines.enc_end_date(recno);
			ELSE
				l_nlines_counter := l_nlines_counter + 1;
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
		WHERE	assignment_id = p_assignment_id
		AND	payroll_id = p_payroll_id
		AND	change_flag = 'N'
		AND	enc_element_type_id = t_enc_nlines.element_type_id(recno)
		AND	hierarchy_code = t_enc_nlines.hierarchy_code(recno)
		AND	gl_code_combination_id IS NOT NULL
		AND	t_enc_nlines.gl_ccid(recno) IS NOT NULL
		AND	gl_code_combination_id = t_enc_nlines.gl_ccid(recno)
		AND	enc_start_date <= t_enc_nlines.enc_end_date(recno)
		AND	enc_end_date >= t_enc_nlines.enc_start_date(recno);

		FORALL recno IN 1..t_enc_nlines.element_type_id.COUNT
		UPDATE	psp_enc_lines_history
		SET	hierarchy_start_date = t_enc_nlines.enc_start_date(recno),
			hierarchy_end_date = t_enc_nlines.enc_end_date(recno)
		WHERE	assignment_id = p_assignment_id
		AND	payroll_id = p_payroll_id
		AND	change_flag = 'N'
		AND	enc_element_type_id = t_enc_nlines.element_type_id(recno)
		AND	hierarchy_code = t_enc_nlines.hierarchy_code(recno)
		AND	award_id IS NOT NULL
		AND	t_enc_nlines.award_id(recno) IS NOT NULL
		AND	project_id = t_enc_nlines.project_id(recno)
		AND	task_id = t_enc_nlines.task_id(recno)
		AND	award_id = t_enc_nlines.award_id(recno)
		AND	expenditure_organization_id = t_enc_nlines.exp_org_id(recno)
		AND	expenditure_type = t_enc_nlines.exp_type(recno)
		AND	enc_start_date <= t_enc_nlines.enc_end_date(recno)
		AND	enc_end_date >= t_enc_nlines.enc_start_date(recno);
	END IF;
        p_return_status := fnd_api.g_ret_sts_success;
	hr_utility.trace(fnd_date.date_to_canonical(SYSDATE) || '	Leaving UPDATE_HIERARCHY_DATES');
EXCEPTION
WHEN OTHERS THEN
		IF (g_error_message IS NULL) THEN
			g_error_message := 'UPDATE_HIERARCHY_DATES: ' || SQLERRM;
		END IF;
        g_error_api_path := SUBSTR(' UPDATE_HIERARCHY_DATES:'||g_error_api_path,1,230);
        fnd_msg_pub.add_exc_msg('PSP_ENC_CREATE_LINES', ' UPDATE_HIERARCHY_DATES');
        p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving UPDATE_HIERARCHY_DATES');
END update_hierarchy_dates;

PROCEDURE clear_sch_hierarchy IS
BEGIN
	r_sa.line_account_id.DELETE;
	r_sa.gl_code_combination_id.DELETE;
	r_sa.project_id.DELETE;
	r_sa.task_id.DELETE;
	r_sa.award_id.DELETE;
	r_sa.expenditure_type.DELETE;
	r_sa.expenditure_organization_id.DELETE;
	r_sa.start_date_active.DELETE;
	r_sa.end_date_active.DELETE;
	r_sa.poeta_start_date.DELETE;
	r_sa.poeta_end_date.DELETE;
	r_sa.percent.DELETE;
	r_sa.attribute_category.DELETE;
	r_sa.attribute1.DELETE;
	r_sa.attribute2.DELETE;
	r_sa.attribute3.DELETE;
	r_sa.attribute4.DELETE;
	r_sa.attribute5.DELETE;
	r_sa.attribute6.DELETE;
	r_sa.attribute7.DELETE;
	r_sa.attribute8.DELETE;
	r_sa.attribute9.DELETE;
	r_sa.attribute10.DELETE;
	r_sa.acct_type.DELETE;

	r_da.line_account_id.DELETE;
	r_da.gl_code_combination_id.DELETE;
	r_da.project_id.DELETE;
	r_da.task_id.DELETE;
	r_da.award_id.DELETE;
	r_da.expenditure_type.DELETE;
	r_da.expenditure_organization_id.DELETE;
	r_da.start_date_active.DELETE;
	r_da.end_date_active.DELETE;
	r_da.poeta_start_date.DELETE;
	r_da.poeta_end_date.DELETE;
	r_da.percent.DELETE;
	r_da.attribute_category.DELETE;
	r_da.attribute1.DELETE;
	r_da.attribute2.DELETE;
	r_da.attribute3.DELETE;
	r_da.attribute4.DELETE;
	r_da.attribute5.DELETE;
	r_da.attribute6.DELETE;
	r_da.attribute7.DELETE;
	r_da.attribute8.DELETE;
	r_da.attribute9.DELETE;
	r_da.attribute10.DELETE;
	r_da.acct_type.DELETE;

	r_odls.line_account_id.DELETE;
	r_odls.gl_code_combination_id.DELETE;
	r_odls.project_id.DELETE;
	r_odls.task_id.DELETE;
	r_odls.award_id.DELETE;
	r_odls.expenditure_type.DELETE;
	r_odls.expenditure_organization_id.DELETE;
	r_odls.start_date_active.DELETE;
	r_odls.end_date_active.DELETE;
	r_odls.poeta_start_date.DELETE;
	r_odls.poeta_end_date.DELETE;
	r_odls.percent.DELETE;
	r_odls.attribute_category.DELETE;
	r_odls.attribute1.DELETE;
	r_odls.attribute2.DELETE;
	r_odls.attribute3.DELETE;
	r_odls.attribute4.DELETE;
	r_odls.attribute5.DELETE;
	r_odls.attribute6.DELETE;
	r_odls.attribute7.DELETE;
	r_odls.attribute8.DELETE;
	r_odls.attribute9.DELETE;
	r_odls.attribute10.DELETE;
	r_odls.acct_type.DELETE;

	r_asg.line_account_id.DELETE;
	r_asg.gl_code_combination_id.DELETE;
	r_asg.project_id.DELETE;
	r_asg.task_id.DELETE;
	r_asg.award_id.DELETE;
	r_asg.expenditure_type.DELETE;
	r_asg.expenditure_organization_id.DELETE;
	r_asg.start_date_active.DELETE;
	r_asg.end_date_active.DELETE;
	r_asg.poeta_start_date.DELETE;
	r_asg.poeta_end_date.DELETE;
	r_asg.percent.DELETE;
	r_asg.attribute_category.DELETE;
	r_asg.attribute1.DELETE;
	r_asg.attribute2.DELETE;
	r_asg.attribute3.DELETE;
	r_asg.attribute4.DELETE;
	r_asg.attribute5.DELETE;
	r_asg.attribute6.DELETE;
	r_asg.attribute7.DELETE;
	r_asg.attribute8.DELETE;
	r_asg.attribute9.DELETE;
	r_asg.attribute10.DELETE;
	r_asg.acct_type.DELETE;

	r_ec.line_account_id.DELETE;
	r_ec.gl_code_combination_id.DELETE;
	r_ec.project_id.DELETE;
	r_ec.task_id.DELETE;
	r_ec.award_id.DELETE;
	r_ec.expenditure_type.DELETE;
	r_ec.expenditure_organization_id.DELETE;
	r_ec.start_date_active.DELETE;
	r_ec.end_date_active.DELETE;
	r_ec.poeta_start_date.DELETE;
	r_ec.poeta_end_date.DELETE;
	r_ec.percent.DELETE;
	r_ec.attribute_category.DELETE;
	r_ec.attribute1.DELETE;
	r_ec.attribute2.DELETE;
	r_ec.attribute3.DELETE;
	r_ec.attribute4.DELETE;
	r_ec.attribute5.DELETE;
	r_ec.attribute6.DELETE;
	r_ec.attribute7.DELETE;
	r_ec.attribute8.DELETE;
	r_ec.attribute9.DELETE;
	r_ec.attribute10.DELETE;
	r_ec.acct_type.DELETE;

	r_et.line_account_id.DELETE;
	r_et.gl_code_combination_id.DELETE;
	r_et.project_id.DELETE;
	r_et.task_id.DELETE;
	r_et.award_id.DELETE;
	r_et.expenditure_type.DELETE;
	r_et.expenditure_organization_id.DELETE;
	r_et.start_date_active.DELETE;
	r_et.end_date_active.DELETE;
	r_et.poeta_start_date.DELETE;
	r_et.poeta_end_date.DELETE;
	r_et.percent.DELETE;
	r_et.attribute_category.DELETE;
	r_et.attribute1.DELETE;
	r_et.attribute2.DELETE;
	r_et.attribute3.DELETE;
	r_et.attribute4.DELETE;
	r_et.attribute5.DELETE;
	r_et.attribute6.DELETE;
	r_et.attribute7.DELETE;
	r_et.attribute8.DELETE;
	r_et.attribute9.DELETE;
	r_et.attribute10.DELETE;
	r_et.acct_type.DELETE;

	r_gee.line_account_id.DELETE;
	r_gee.gl_code_combination_id.DELETE;
	r_gee.project_id.DELETE;
	r_gee.task_id.DELETE;
	r_gee.award_id.DELETE;
	r_gee.expenditure_type.DELETE;
	r_gee.expenditure_organization_id.DELETE;
	r_gee.start_date_active.DELETE;
	r_gee.end_date_active.DELETE;
	r_gee.poeta_start_date.DELETE;
	r_gee.poeta_end_date.DELETE;
	r_gee.percent.DELETE;
	r_gee.attribute_category.DELETE;
	r_gee.attribute1.DELETE;
	r_gee.attribute2.DELETE;
	r_gee.attribute3.DELETE;
	r_gee.attribute4.DELETE;
	r_gee.attribute5.DELETE;
	r_gee.attribute6.DELETE;
	r_gee.attribute7.DELETE;
	r_gee.attribute8.DELETE;
	r_gee.attribute9.DELETE;
	r_gee.attribute10.DELETE;
	r_gee.acct_type.DELETE;

END clear_sch_hierarchy;

END PSP_ENC_CREATE_LINES;

/
