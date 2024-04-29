--------------------------------------------------------
--  DDL for Package Body PSP_ADJ_DRIVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ADJ_DRIVER" AS
/* $Header: PSPLDTRB.pls 120.10.12010000.6 2009/10/13 05:36:04 amakrish ship $ */

g_error_api_path VARCHAR2(2000);
g_run_id NUMBER(9) := 0;
--**************************************************
g_constraint_violation CONSTANT VARCHAR2(1) := 'V';
--**************************************************

g_precision     NUMBER; -- Introduced this variable to store precision for bug fix 2916848
--	Introduced following variable to store extended precision for bug fix 2916848, currently this value
--	isn't used in this procedure. This variable is introduced as the common routine to fetch currency
--	precision returns this value as well.
g_ext_precision NUMBER;

g_dff_grouping_option	CHAR(1);			-- Introduced for bug fix 2908859

----------P R O C E D U R E: LOAD_TABLE -------------------------------
--
--
--  Purpose:   This procedure is called by the QUERY FIND screen of the
--		   distribution transfers form.  The purpose is to select
--		   distribution lines from the following 3 tables that match
--		   the query find selection criteria.
--
--		   1. PSP_DISTRIUTION_LINES_HISTORY (lines taht have not been adjusted)
--		   2. PSP_PRE_GEN_DIST_LINES_HISTORY (pre generated lines that have
--								  not been adjusted)
--		   3. PSP_ADJUSTMENT_LINES_HISTORY (lines that have been adjusted)
--
-- 		   For each line found, a call is made to the procedure
--		   insert_update_sumlines to summarize the line by unique
--		   GL/POETA information for display to the user.
--
----------------------------------------------------------------------------------

PROCEDURE load_table(errbuf  			OUT NOCOPY VARCHAR2,
                     retcode 			OUT NOCOPY VARCHAR2,
                     p_person_id 		IN NUMBER,
                     p_assignment_id 		IN NUMBER,
                     --p_element_type_id	IN NUMBER,  commented for DA-ENH
                     p_begin_date 		IN DATE,
                     p_end_date 		IN DATE,
                     p_adjust_by                IN VARCHAR2, --- added for DA-ENH
                     p_currency_code            IN VARCHAR2,	-- Introduced for bug fix 2916848
		     p_run_id 			IN NUMBER,
		     p_business_group_id	IN Number,
		     p_set_of_books_id		IN Number) IS

/* This cursor selects from three different tables.

   For the table psp_distribution_lines_history, if
   suspense account information is present, then a join
   to the suspense table is used to get the GL or POETA
   account information. Otherwise, the information
   is found from element account, schedule line,
   default labor schedule, or default org account tables.

   For the tables psp_pre_gen_dist_lines_history
   and psp_adjustment_lines_history, account information
   is taken from suspense account if present, otherwise
   it is taken from the line. */

--Introduced the EXISTS clause of adjust='Y'  for Bug 2860013
   CURSOR lines_c1(p_person_id IN NUMBER,
               p_assignment_id IN NUMBER,
               p_begin_date IN DATE,
               p_end_date IN DATE) IS
    SELECT ppl.element_type_id,   --- added this and line below for DA-ENH
          pegl.element_group_id,	-- Modified to inline query column for bug fix 3658235
	  psl.gl_code_combination_id,
          psl.project_id,
          psl.expenditure_organization_id,
          psl.expenditure_type,
          psl.task_id,
          psl.award_id,
          pdl.distribution_date,
          ROUND(pdl.distribution_amount, g_precision),	-- Introduced ROUND() for bug fix 2916848
	  --- pdl.gl_project_flag, commented for DA-ENH
          pdl.distribution_line_id  distribution_line_id,
          ppl.dr_cr_flag,
          'D' tab_flag ,
         --Added the following  3 new columns : For bug fix 2252881
	 pdl.effective_date,
	 psl.time_period_id,
	 psl.payroll_control_id,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', psl.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', psl.attribute10, NULL) attribute10
   FROM
          psp_distribution_lines_history  pdl,
          psp_payroll_lines               ppl,
          psp_payroll_sub_lines           ppsl,
          psp_summary_lines               psl,
          --psp_group_element_list          pgel, --- added for DA-ENH Modified to inline query for bug 3658235
          (SELECT	peg.element_group_id, pgel.element_type_id
	  FROM	psp_element_groups peg, psp_group_element_list pgel
	  WHERE	business_group_id = p_business_group_id
	  AND	set_of_books_id = p_set_of_books_id
	  AND	peg.element_group_id (+) = pgel.element_group_id
          and (p_begin_date between peg.start_date_active and peg.end_date_active		-- Bug 8970980
               OR p_end_date  between peg.start_date_active and peg.end_date_active  ))	    pegl,-- Introduced for bug fix 3098050
	  psp_payroll_controls		  ppc	-- Introduced for bug fix 2916848
   WHERE
          psl.person_id         = p_person_id
   AND	  psl.summary_line_id   = pdl.summary_line_id
   AND	  psl.assignment_id     = p_assignment_id
   AND    psl.business_group_id = p_business_group_id
   AND    psl.set_of_books_id    = p_set_of_books_id
   AND    pdl.distribution_date between p_begin_date and p_end_date
   AND    pegl.element_type_id(+) = ppl.element_type_id  --- added for DA-ENH
--	Introduced BG/SOB check on psp_element_groups for bug fix 3098050
   --AND	  peg.element_group_id(+) = pgel.element_group_id
--   AND	  NVL(peg.business_group_id, p_business_group_id) = p_business_group_id	-- Introduced NVL for bug fix 3145038, Commented for 3658235
--   AND	  NVL(peg.set_of_books_id, p_set_of_books_id) = p_set_of_books_id	-- Introduced NVL for bug fix 3145038, Commented for 3658235
   AND    pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
   AND    ppsl.payroll_line_id = ppl.payroll_line_id
--	Introduced the following for bug fix 2916848
   AND	  ppc.payroll_control_id = ppl.payroll_control_id
   AND	  ppc.currency_code = p_currency_code
--	End of bug fix 2916848
   AND    pdl.reversal_entry_flag is NULL
   AND    pdl.adjustment_batch_name is null
   AND EXISTS	(SELECT	1
		 FROM	psp_element_types pet
		 WHERE	pet.element_type_id = ppl.element_type_id
		 AND	pet.adjust = 'Y'
--	Introduced BG/SOB check fopr bug fix 3098050
		AND	pet.business_group_id = p_business_group_id
		AND	pet.set_of_books_id = p_set_of_books_id)
for update of reversal_entry_flag nowait ;

--Introduced the EXISTS clause of adjust='Y'  for Bug 2860013
CURSOR lines_c2(p_person_id IN NUMBER,
               p_assignment_id IN NUMBER,
               p_begin_date IN DATE,
               p_end_date IN DATE) IS
SELECT    ppg.element_type_id,    -- added this line and line below for DA-ENH
          pegl.element_group_id,	-- Modified to inline query column for bug 3658235
          decode(ppg.suspense_org_account_id, NULL, ppg.gl_code_combination_id,
              nvl(ppg.suspense_auto_glccid, pos.gl_code_combination_id)) gl_code_combination_id,
          decode(ppg.suspense_org_account_id, NULL, ppg.project_id,
              pos.project_id) project_id,
          decode(ppg.suspense_org_account_id, NULL, ppg.expenditure_organization_id,
              pos.expenditure_organization_id) expenditure_organization_id,
          decode(ppg.suspense_org_account_id, NULL, ppg.expenditure_type,
              nvl(ppg.suspense_auto_exp_type, pos.expenditure_type)) expenditure_type,
          decode(ppg.suspense_org_account_id, NULL, ppg.task_id,
              pos.task_id) task_id,
          decode(ppg.suspense_org_account_id, NULL, ppg.award_id,
              pos.award_id) award_id,
          ppg.distribution_date,
          ROUND(ppg.distribution_amount, g_precision),	-- Introduced ROUND() for bug fix 2916848
          ppg.pre_gen_dist_line_id distribution_line_id,
          ppg.dr_cr_flag,
          'P' tab_flag ,
        --Added the following  3 new columns : For bug fix 2252881
	 ppg.effective_date,
	 ppg.time_period_id,
	 ppg.payroll_control_id ,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute_category, pos.attribute_category), NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute1, pos.attribute1), NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute2, pos.attribute2), NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute3, pos.attribute3), NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute4, pos.attribute4), NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute5, pos.attribute5), NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute6, pos.attribute6), NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute7, pos.attribute7), NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute8, pos.attribute8), NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute9, pos.attribute9), NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute10, pos.attribute10), NULL) attribute10
   FROM
          psp_pre_gen_dist_lines_history  ppg,
          psp_organization_accounts  pos ,
          --psp_group_element_list pgel, --- added for DA-ENH Modified to inline query for bug fix 3658235
          (SELECT	peg.element_group_id, pgel.element_type_id
	  FROM	psp_element_groups peg, psp_group_element_list pgel
	  WHERE	business_group_id = p_business_group_id
	  AND	set_of_books_id = p_set_of_books_id
	  AND	peg.element_group_id (+) = pgel.element_group_id
      and (p_begin_date between peg.start_date_active and peg.end_date_active		-- Bug 8970980
               OR p_end_date  between peg.start_date_active and peg.end_date_active))	    pegl,	-- Introduced for bug fix 3098050
	  psp_payroll_controls ppc	-- Introduced for bug fix 2916848
   WHERE
   	  ppg.assignment_id = p_assignment_id
   AND    ppg.distribution_date between p_begin_date and p_end_date
   AND	  ppg.business_group_id = p_business_group_id
   AND    ppg.set_of_books_id   = p_set_of_books_id
--	Introduced the following for bug fix 2916848
   AND	  ppc.payroll_control_id = ppg.payroll_control_id
   AND	  ppc.currency_code = p_currency_code
--	End of bug fix 2916848
   AND    pegl.element_type_id(+) = ppg.element_type_id  -- added for DA-ENH
--	Introduced BG/SOB check on psp_element_groups for bug fix 3098050
   --AND	  peg.element_group_id(+) = pgel.element_group_id
--   AND	  NVL(peg.business_group_id, p_business_group_id) = p_business_group_id	-- Introduced NVL for bug fix 3145038, Commented for bug 3658235
--   AND	  NVL(peg.set_of_books_id, p_set_of_books_id) = p_set_of_books_id	-- Introduced NVL for bug fix 3145038, Commented for bug 3658235
   AND    ppg.status_code = 'A'
   AND    ppg.reversal_entry_flag is NULL
   AND    ppg.suspense_org_account_id = pos.organization_account_id(+)
   AND    ppg.adjustment_batch_name is null
   AND EXISTS	(SELECT	1
		 FROM	psp_element_types pet
		 WHERE	pet.element_type_id = ppg.element_type_id
		 AND	pet.adjust = 'Y'
--	Introduced BG/SOB check fopr bug fix 3098050
		AND	pet.business_group_id = p_business_group_id
		AND	pet.set_of_books_id = p_set_of_books_id)
  for update of reversal_entry_flag nowait;

--Introduced the EXISTS clause of adjust='Y'  for Bug 2860013
CURSOR lines_c3(p_person_id IN NUMBER,
               p_assignment_id IN NUMBER,
               p_begin_date IN DATE,
               p_end_date IN DATE) IS
SELECT    pal.element_type_id, --- for DA-ENH
          pegl.element_group_id, -- added for DA-ENH	Modified to inline query column for bug 3658235
          pal.gl_code_combination_id,
          pal.project_id,
          pal.expenditure_organization_id,
          pal.expenditure_type,
          pal.task_id,
          pal.award_id,
          pal.distribution_date,
          ROUND(pal.distribution_amount, g_precision),	-- Introduced for bug fix 2916848
          pal.adjustment_line_id distribution_line_id,
          dr_cr_flag, /* changed from 'D',  Bug 1976999 */
          'A' tab_flag ,
	 pal.effective_date,
	 pal.time_period_id,
	 pal.payroll_control_id ,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', pal.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute10, NULL) attribute10
   FROM
          psp_adjustment_lines_history  pal,
          --psp_group_element_list pgel,  --- added table for DA-ENH Modified to inline query for bug fix 3658235
          (SELECT	peg.element_group_id, pgel.element_type_id
	  FROM	psp_element_groups peg, psp_group_element_list pgel
	  WHERE	business_group_id = p_business_group_id
	  AND	set_of_books_id = p_set_of_books_id
	  AND	peg.element_group_id (+) = pgel.element_group_id
      and (p_begin_date between peg.start_date_active and peg.end_date_active		-- Bug 8970980
               OR p_end_date  between peg.start_date_active and peg.end_date_active))	    pegl,  -- Introduced for bug fix 3098050
	  psp_payroll_controls ppc	-- Introduced for bug fix 2916848
   WHERE
   	  pal.assignment_id = p_assignment_id
   AND    pal.distribution_date between p_begin_date and p_end_date
   AND	  pal.business_group_id = p_business_group_id
   AND    pal.set_of_books_id   = p_set_of_books_id
--	Introduced the following for bug fix 2916848
   AND	  ppc.payroll_control_id = pal.payroll_control_id
   AND	  ppc.currency_code = p_currency_code
--	End of bug fix 2916848
   AND    pegl.element_type_id(+) = pal.element_type_id
--	Introduced BG/SOB check on psp_element_groups for bug fix 3098050
   --AND	  peg.element_group_id(+) = pgel.element_group_id
--   AND	  NVL(peg.business_group_id, p_business_group_id) = p_business_group_id	-- Introduced NVL for bug fix 3145038, Commented for bug 3658235
--   AND	  NVL(peg.set_of_books_id, p_set_of_books_id) = p_set_of_books_id	-- Introduced NVL for bug fix 3145038, Commented for bug 3658235
   AND    pal.status_code = 'A'
   AND    NVL(pal.original_line_flag,'N') ='N'
   AND    pal.reversal_entry_flag is NULL
   AND   pal.adjustment_batch_name is null
   AND EXISTS	(SELECT	1
 		 FROM	psp_element_types pet
		 WHERE	pet.element_type_id = pal.element_type_id
		AND	pet.adjust = 'Y'
--	Introduced BG/SOB check fopr bug fix 3098050
		AND	pet.business_group_id = p_business_group_id
		AND	pet.set_of_books_id = p_set_of_books_id)
  for update of reversal_entry_flag nowait ;

  l_element_type_id               number := 0; -- added for DA-ENH
  l_loop_count                   INTEGER :=0;
  l_group_id                     INTEGER :=0;
  l_gl_code_combination_id       NUMBER(15);
  l_project_id			 NUMBER(15);
  l_expenditure_organization_id  NUMBER(15);
  l_expenditure_type             VARCHAR2(30);
  l_task_id                      NUMBER(15);
  l_award_id                     NUMBER(15);
  l_distribution_date		   DATE;
--  l_distribution_amount	   NUMBER(20, 2);  --Bug 2698256.	Commented as part bug fix 2916848
  l_gl_project_flag		   VARCHAR2(1);
  l_distribution_line_id         NUMBER(10);
  l_dr_cr_flag                 VARCHAR2(1);
  l_tab_flag			 VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_msg_count  NUMBER;
  l_msg_data   VARCHAR2(2000);
  pop_gl_ccid                   NUMBER(15);
  pop_exp_type                  VARCHAR2(30);

  no_records_found EXCEPTION;

  IN_USE_EXCEPTION		EXCEPTION;
  PRAGMA EXCEPTION_INIT (IN_USE_EXCEPTION, -54); /* Bug 1609502 */

 TYPE t_num_15_type      IS TABLE OF NUMBER(15)          INDEX BY BINARY_INTEGER;
 TYPE t_varchar_30_type  IS TABLE OF VARCHAR2(30)        INDEX BY BINARY_INTEGER;
 TYPE t_varchar_150_type  IS TABLE OF VARCHAR2(150)	INDEX BY BINARY_INTEGER;	-- Introduced for bug fix 2908859
 TYPE t_varchar_1_type   IS TABLE OF VARCHAR2(1)         INDEX BY BINARY_INTEGER;
 TYPE t_date_type        IS TABLE OF DATE                INDEX BY BINARY_INTEGER;
--	Changed the datatype defn for the following type for bug fix 2916848 from (15, 2) to 30
 TYPE t_number_type    IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;

 type temp_orig_line_rec is record
 ( array_element_type_id      t_num_15_type,
   array_element_group_id     t_num_15_type,
   array_glccid               t_num_15_type,
   array_project_id           t_num_15_type,
   array_exp_org_id           t_num_15_type,
   array_exp_type             t_varchar_30_type,
   array_task_id              t_num_15_type,
   array_award_id             t_num_15_type,
   array_distribution_date    t_date_type,
   array_distribution_amount  t_number_type,		-- Corrected column type defn for bug fix 2916848
   array_distribution_line_id t_num_15_type,
   array_dr_cr_flag           t_varchar_1_type,
   array_tab_flag             t_varchar_1_type,
   array_effective_date       t_date_type,
   array_time_period_id       t_num_15_type,
   array_payroll_control_id   t_num_15_type,
	array_attribute_category	t_varchar_30_type,
	array_attribute1		t_varchar_150_type,
	array_attribute2		t_varchar_150_type,
	array_attribute3		t_varchar_150_type,
	array_attribute4		t_varchar_150_type,
	array_attribute5		t_varchar_150_type,
	array_attribute6		t_varchar_150_type,
	array_attribute7		t_varchar_150_type,
	array_attribute8		t_varchar_150_type,
	array_attribute9		t_varchar_150_type,
	array_attribute10		t_varchar_150_type);

 orig_line_rec   temp_orig_line_rec;

 cursor temp_orig_sumline_E is
            SELECT ELEMENT_TYPE_ID,
                   GL_CODE_COMBINATION_ID,
                   PROJECT_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   EXPENDITURE_TYPE,
                   TASK_ID,
                   AWARD_ID,
--                 DR_CR_FLAG, Commented for Bug 3625667
                   DECODE(sign(SUM(DECODE(dr_cr_flag, 'C', - distribution_amount, distribution_amount))),-1,'C','D')  DR_CR_FLAG,
                   SUM(DECODE(dr_cr_flag, 'C', - distribution_amount, distribution_amount)),
                   RUN_ID,
                   SET_OF_BOOKS_ID,
                   BUSINESS_GROUP_ID,
		DECODE(g_dff_grouping_option, 'Y', attribute_category, NULL) attribute_category,
		DECODE(g_dff_grouping_option, 'Y', attribute1, NULL) attribute1,
		DECODE(g_dff_grouping_option, 'Y', attribute2, NULL) attribute2,
		DECODE(g_dff_grouping_option, 'Y', attribute3, NULL) attribute3,
		DECODE(g_dff_grouping_option, 'Y', attribute4, NULL) attribute4,
		DECODE(g_dff_grouping_option, 'Y', attribute5, NULL) attribute5,
		DECODE(g_dff_grouping_option, 'Y', attribute6, NULL) attribute6,
		DECODE(g_dff_grouping_option, 'Y', attribute7, NULL) attribute7,
		DECODE(g_dff_grouping_option, 'Y', attribute8, NULL) attribute8,
		DECODE(g_dff_grouping_option, 'Y', attribute9, NULL) attribute9,
		DECODE(g_dff_grouping_option, 'Y', attribute10, NULL) attribute10
          from PSP_TEMP_ORIG_LINES
          where RUN_ID = g_run_id
         group by  RUN_ID,
                   SET_OF_BOOKS_ID,
                   BUSINESS_GROUP_ID,
                   ELEMENT_TYPE_ID,
                   GL_CODE_COMBINATION_ID,
                   PROJECT_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   EXPENDITURE_TYPE,
                   TASK_ID,
                   AWARD_ID,
                -- DR_CR_FLAG, Commented for Bug   3625667
			DECODE(g_dff_grouping_option, 'Y', attribute_category, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute1, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute2, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute3, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute4, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute5, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute6, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute7, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute8, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute9, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute10, NULL);

 cursor temp_orig_sumline_G is
           SELECT ELEMENT_GROUP_ID,
                   GL_CODE_COMBINATION_ID,
                   PROJECT_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   EXPENDITURE_TYPE,
                   TASK_ID,
                   AWARD_ID,
               --  DR_CR_FLAG, Commented for Bug 3625667
                   DECODE(sign(SUM(DECODE(dr_cr_flag, 'C', - distribution_amount, distribution_amount))),-1,'C','D')  DR_CR_FLAG,
                   SUM(DECODE(dr_cr_flag, 'C', - distribution_amount, distribution_amount)),
                   RUN_ID,
                   SET_OF_BOOKS_ID,
                   BUSINESS_GROUP_ID,
		DECODE(g_dff_grouping_option, 'Y', attribute_category, NULL) attribute_category,
		DECODE(g_dff_grouping_option, 'Y', attribute1, NULL) attribute1,
		DECODE(g_dff_grouping_option, 'Y', attribute2, NULL) attribute2,
		DECODE(g_dff_grouping_option, 'Y', attribute3, NULL) attribute3,
		DECODE(g_dff_grouping_option, 'Y', attribute4, NULL) attribute4,
		DECODE(g_dff_grouping_option, 'Y', attribute5, NULL) attribute5,
		DECODE(g_dff_grouping_option, 'Y', attribute6, NULL) attribute6,
		DECODE(g_dff_grouping_option, 'Y', attribute7, NULL) attribute7,
		DECODE(g_dff_grouping_option, 'Y', attribute8, NULL) attribute8,
		DECODE(g_dff_grouping_option, 'Y', attribute9, NULL) attribute9,
		DECODE(g_dff_grouping_option, 'Y', attribute10, NULL) attribute10
          from PSP_TEMP_ORIG_LINES
        where RUN_ID = g_run_id
            and element_group_id IS NOT NULL
         group by   RUN_ID,
                   SET_OF_BOOKS_ID,
                   BUSINESS_GROUP_ID,
                   ELEMENT_GROUP_ID,
                   GL_CODE_COMBINATION_ID,
                   PROJECT_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   EXPENDITURE_TYPE,
                   TASK_ID,
                   AWARD_ID,
         --        DR_CR_FLAG, Commented for bug 3625667
			DECODE(g_dff_grouping_option, 'Y', attribute_category, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute1, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute2, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute3, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute4, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute5, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute6, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute7, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute8, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute9, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute10, NULL);

  cursor temp_orig_sumline_A is
         select GL_CODE_COMBINATION_ID,
                   PROJECT_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   EXPENDITURE_TYPE,
                   TASK_ID,
                   AWARD_ID,
               --  DR_CR_FLAG, Commented for bug 3625667
                   DECODE(sign(SUM(DECODE(dr_cr_flag, 'C', - distribution_amount, distribution_amount))),-1,'C','D')  DR_CR_FLAG,
                   SUM(DECODE(dr_cr_flag, 'C', - distribution_amount, distribution_amount)),
                   RUN_ID,
                   SET_OF_BOOKS_ID,
                   BUSINESS_GROUP_ID,
		DECODE(g_dff_grouping_option, 'Y', attribute_category, NULL) attribute_category,
		DECODE(g_dff_grouping_option, 'Y', attribute1, NULL) attribute1,
		DECODE(g_dff_grouping_option, 'Y', attribute2, NULL) attribute2,
		DECODE(g_dff_grouping_option, 'Y', attribute3, NULL) attribute3,
		DECODE(g_dff_grouping_option, 'Y', attribute4, NULL) attribute4,
		DECODE(g_dff_grouping_option, 'Y', attribute5, NULL) attribute5,
		DECODE(g_dff_grouping_option, 'Y', attribute6, NULL) attribute6,
		DECODE(g_dff_grouping_option, 'Y', attribute7, NULL) attribute7,
		DECODE(g_dff_grouping_option, 'Y', attribute8, NULL) attribute8,
		DECODE(g_dff_grouping_option, 'Y', attribute9, NULL) attribute9,
		DECODE(g_dff_grouping_option, 'Y', attribute10, NULL) attribute10
          from PSP_TEMP_ORIG_LINES
          where RUN_ID = g_run_id
         group by   RUN_ID,
                   SET_OF_BOOKS_ID,
                   BUSINESS_GROUP_ID,
                   GL_CODE_COMBINATION_ID,
                   PROJECT_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   EXPENDITURE_TYPE,
                   TASK_ID,
                   AWARD_ID,
             --    DR_CR_FLAG, Commented for Bug 3625667
			DECODE(g_dff_grouping_option, 'Y', attribute_category, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute1, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute2, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute3, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute4, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute5, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute6, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute7, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute8, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute9, NULL),
			DECODE(g_dff_grouping_option, 'Y', attribute10, NULL);

 type temp_orig_sumline_rec is record
 ( array_element_type_id      t_num_15_type,
   array_element_group_id     t_num_15_type,
   array_glccid               t_num_15_type,
   array_project_id           t_num_15_type,
   array_exp_org_id           t_num_15_type,
   array_exp_type             t_varchar_30_type,
   array_task_id              t_num_15_type,
   array_award_id             t_num_15_type,
   array_dr_cr_flag           t_varchar_1_type,
   array_distribution_sum     t_number_type,		-- Corrected column type defn for bug fix 2916848
   array_run_id               t_num_15_type,
   array_set_of_books_id      t_num_15_type,
   array_business_group_id    t_num_15_type,
   array_acct_group_id        t_num_15_type,
	array_attribute_category	t_varchar_30_type,
	array_attribute1		t_varchar_150_type,
	array_attribute2		t_varchar_150_type,
	array_attribute3		t_varchar_150_type,
	array_attribute4		t_varchar_150_type,
	array_attribute5		t_varchar_150_type,
	array_attribute6		t_varchar_150_type,
	array_attribute7		t_varchar_150_type,
	array_attribute8		t_varchar_150_type,
	array_attribute9		t_varchar_150_type,
	array_attribute10		t_varchar_150_type);

   orig_sumline_rec   temp_orig_sumline_rec;
BEGIN

   g_error_api_path := '';
   fnd_msg_pub.initialize;
   errbuf := '';
   g_run_id := p_run_id;

	psp_general.get_currency_precision(p_currency_code, g_precision, g_ext_precision);	-- Introduced for bug fix 2916848

	g_dff_grouping_option := psp_general.get_act_dff_grouping_option(p_business_group_id);	-- Introduced for bug fix 2908859

   open lines_c1(p_person_id,p_assignment_id,p_begin_date,p_end_date);
   fetch lines_c1 bulk collect into
     orig_line_rec.array_element_type_id,
     orig_line_rec.array_element_group_id,
     orig_line_rec.array_glccid,
     orig_line_rec.array_project_id,
     orig_line_rec.array_exp_org_id,
     orig_line_rec.array_exp_type,
     orig_line_rec.array_task_id,
     orig_line_rec.array_award_id,
     orig_line_rec.array_distribution_date,
     orig_line_rec.array_distribution_amount,
     orig_line_rec.array_distribution_line_id,
     orig_line_rec.array_dr_cr_flag,
     orig_line_rec.array_tab_flag,
     orig_line_rec.array_effective_date,
     orig_line_rec.array_time_period_id,
     orig_line_rec.array_payroll_control_id,
	orig_line_rec.array_attribute_category,			-- Introduced DFF columns for bug fix 2908859
	orig_line_rec.array_attribute1,
	orig_line_rec.array_attribute2,
	orig_line_rec.array_attribute3,
	orig_line_rec.array_attribute4,
	orig_line_rec.array_attribute5,
	orig_line_rec.array_attribute6,
	orig_line_rec.array_attribute7,
	orig_line_rec.array_attribute8,
	orig_line_rec.array_attribute9,
	orig_line_rec.array_attribute10;

   close lines_c1;

   if orig_line_rec.array_distribution_line_id.count > 0 then
    l_loop_count := l_loop_count + orig_line_rec.array_distribution_line_id.count;
    FORALL i IN 1..orig_line_rec.array_distribution_line_id.count
      insert into psp_temp_orig_lines(
         element_type_id,
         element_group_id,
         gl_code_combination_id,
         project_id,
         expenditure_organization_id,
         expenditure_type,
         task_id,
         award_id,
         orig_distribution_date,
         distribution_amount,
         orig_line_id,
         dr_cr_flag,
         orig_source_type,
         effective_date,
         time_period_id,
         payroll_control_id,
         run_id,
         business_group_id,
         set_of_books_id,
	attribute_category,				-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10)
      values
         (orig_line_rec.array_element_type_id(i),
          orig_line_rec.array_element_group_id(i),
          orig_line_rec.array_glccid(i),
          orig_line_rec.array_project_id(i),
          orig_line_rec.array_exp_org_id(i),
          orig_line_rec.array_exp_type(i),
          orig_line_rec.array_task_id(i),
          orig_line_rec.array_award_id(i),
          orig_line_rec.array_distribution_date(i),
          orig_line_rec.array_distribution_amount(i),
          orig_line_rec.array_distribution_line_id(i),
          orig_line_rec.array_dr_cr_flag(i),
          orig_line_rec.array_tab_flag(i),
          orig_line_rec.array_effective_date(i),
          orig_line_rec.array_time_period_id(i),
          orig_line_rec.array_payroll_control_id(i),
          g_run_id,
          p_business_group_id,
          p_set_of_books_id,
          orig_line_rec.array_attribute_category(i),		-- Introduced DFF columns for bug fix 2908859
          orig_line_rec.array_attribute1(i),
          orig_line_rec.array_attribute2(i),
          orig_line_rec.array_attribute3(i),
          orig_line_rec.array_attribute4(i),
          orig_line_rec.array_attribute5(i),
          orig_line_rec.array_attribute6(i),
          orig_line_rec.array_attribute7(i),
          orig_line_rec.array_attribute8(i),
          orig_line_rec.array_attribute9(i),
          orig_line_rec.array_attribute10(i));

    /* flush all arrays */
    orig_line_rec.array_element_type_id .delete;
    orig_line_rec.array_element_group_id .delete;
    orig_line_rec.array_glccid .delete;
    orig_line_rec.array_project_id .delete;
    orig_line_rec.array_exp_org_id .delete;
    orig_line_rec.array_exp_type .delete;
    orig_line_rec.array_task_id .delete;
    orig_line_rec.array_award_id .delete;
    orig_line_rec.array_distribution_date .delete;
    orig_line_rec.array_distribution_amount .delete;
    orig_line_rec.array_distribution_line_id .delete;
    orig_line_rec.array_dr_cr_flag .delete;
    orig_line_rec.array_tab_flag .delete;
    orig_line_rec.array_effective_date .delete;
    orig_line_rec.array_time_period_id .delete;
    orig_line_rec.array_payroll_control_id .delete;
    orig_line_rec.array_attribute_category.delete;		-- Introduced for bug fix 2908859
    orig_line_rec.array_attribute1.delete;
    orig_line_rec.array_attribute2.delete;
    orig_line_rec.array_attribute3.delete;
    orig_line_rec.array_attribute4.delete;
    orig_line_rec.array_attribute5.delete;
    orig_line_rec.array_attribute6.delete;
    orig_line_rec.array_attribute7.delete;
    orig_line_rec.array_attribute8.delete;
    orig_line_rec.array_attribute9.delete;
    orig_line_rec.array_attribute10.delete;
   end if;

   open lines_c2(p_person_id,p_assignment_id,p_begin_date,p_end_date);
   fetch lines_c2 bulk collect into
     orig_line_rec.array_element_type_id,
     orig_line_rec.array_element_group_id,
     orig_line_rec.array_glccid,
     orig_line_rec.array_project_id,
     orig_line_rec.array_exp_org_id,
     orig_line_rec.array_exp_type,
     orig_line_rec.array_task_id,
     orig_line_rec.array_award_id,
     orig_line_rec.array_distribution_date,
     orig_line_rec.array_distribution_amount,
     orig_line_rec.array_distribution_line_id,
     orig_line_rec.array_dr_cr_flag,
     orig_line_rec.array_tab_flag,
     orig_line_rec.array_effective_date,
     orig_line_rec.array_time_period_id,
     orig_line_rec.array_payroll_control_id,
	orig_line_rec.array_attribute_category,			-- Introduced DFF columns for bug fix 2908859
	orig_line_rec.array_attribute1,
	orig_line_rec.array_attribute2,
	orig_line_rec.array_attribute3,
	orig_line_rec.array_attribute4,
	orig_line_rec.array_attribute5,
	orig_line_rec.array_attribute6,
	orig_line_rec.array_attribute7,
	orig_line_rec.array_attribute8,
	orig_line_rec.array_attribute9,
	orig_line_rec.array_attribute10;

   close lines_c2;

   if orig_line_rec.array_distribution_line_id.count > 0 then
    l_loop_count := l_loop_count + orig_line_rec.array_distribution_line_id.count;
    FORALL i IN 1..orig_line_rec.array_distribution_line_id.count
      insert into psp_temp_orig_lines(
         element_type_id,
         element_group_id,
         gl_code_combination_id,
         project_id,
         expenditure_organization_id,
         expenditure_type,
         task_id,
         award_id,
         orig_distribution_date,
         distribution_amount,
         orig_line_id,
         dr_cr_flag,
         orig_source_type,
         effective_date,
         time_period_id,
         payroll_control_id,
         run_id,
         business_group_id,
         set_of_books_id,
	attribute_category,				-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10)
      values
         (orig_line_rec.array_element_type_id(i),
          orig_line_rec.array_element_group_id(i),
          orig_line_rec.array_glccid(i),
          orig_line_rec.array_project_id(i),
          orig_line_rec.array_exp_org_id(i),
          orig_line_rec.array_exp_type(i),
          orig_line_rec.array_task_id(i),
          orig_line_rec.array_award_id(i),
          orig_line_rec.array_distribution_date(i),
          orig_line_rec.array_distribution_amount(i),
          orig_line_rec.array_distribution_line_id(i),
          orig_line_rec.array_dr_cr_flag(i),
          orig_line_rec.array_tab_flag(i),
          orig_line_rec.array_effective_date(i),
          orig_line_rec.array_time_period_id(i),
          orig_line_rec.array_payroll_control_id(i),
          g_run_id,
          p_business_group_id,
          p_set_of_books_id,
          orig_line_rec.array_attribute_category(i),		-- Introduced DFF columns for bug fix 2908859
          orig_line_rec.array_attribute1(i),
          orig_line_rec.array_attribute2(i),
          orig_line_rec.array_attribute3(i),
          orig_line_rec.array_attribute4(i),
          orig_line_rec.array_attribute5(i),
          orig_line_rec.array_attribute6(i),
          orig_line_rec.array_attribute7(i),
          orig_line_rec.array_attribute8(i),
          orig_line_rec.array_attribute9(i),
          orig_line_rec.array_attribute10(i));

    /* flush all arrays */
    orig_line_rec.array_element_type_id .delete;
    orig_line_rec.array_element_group_id .delete;
    orig_line_rec.array_glccid .delete;
    orig_line_rec.array_project_id .delete;
    orig_line_rec.array_exp_org_id .delete;
    orig_line_rec.array_exp_type .delete;
    orig_line_rec.array_task_id .delete;
    orig_line_rec.array_award_id .delete;
    orig_line_rec.array_distribution_date .delete;
    orig_line_rec.array_distribution_amount .delete;
    orig_line_rec.array_distribution_line_id .delete;
    orig_line_rec.array_dr_cr_flag .delete;
    orig_line_rec.array_tab_flag .delete;
    orig_line_rec.array_effective_date .delete;
    orig_line_rec.array_time_period_id .delete;
    orig_line_rec.array_payroll_control_id .delete;
    orig_line_rec.array_attribute_category.delete;		-- Introduced for bug fix 2908859
    orig_line_rec.array_attribute1.delete;
    orig_line_rec.array_attribute2.delete;
    orig_line_rec.array_attribute3.delete;
    orig_line_rec.array_attribute4.delete;
    orig_line_rec.array_attribute5.delete;
    orig_line_rec.array_attribute6.delete;
    orig_line_rec.array_attribute7.delete;
    orig_line_rec.array_attribute8.delete;
    orig_line_rec.array_attribute9.delete;
    orig_line_rec.array_attribute10.delete;
  end if;

   open lines_c3(p_person_id,p_assignment_id,p_begin_date,p_end_date);
   fetch lines_c3 bulk collect into
     orig_line_rec.array_element_type_id,
     orig_line_rec.array_element_group_id,
     orig_line_rec.array_glccid,
     orig_line_rec.array_project_id,
     orig_line_rec.array_exp_org_id,
     orig_line_rec.array_exp_type,
     orig_line_rec.array_task_id,
     orig_line_rec.array_award_id,
     orig_line_rec.array_distribution_date,
     orig_line_rec.array_distribution_amount,
     orig_line_rec.array_distribution_line_id,
     orig_line_rec.array_dr_cr_flag,
     orig_line_rec.array_tab_flag,
     orig_line_rec.array_effective_date,
     orig_line_rec.array_time_period_id,
     orig_line_rec.array_payroll_control_id,
	orig_line_rec.array_attribute_category,			-- Introduced DFF columns for bug fix 2908859
	orig_line_rec.array_attribute1,
	orig_line_rec.array_attribute2,
	orig_line_rec.array_attribute3,
	orig_line_rec.array_attribute4,
	orig_line_rec.array_attribute5,
	orig_line_rec.array_attribute6,
	orig_line_rec.array_attribute7,
	orig_line_rec.array_attribute8,
	orig_line_rec.array_attribute9,
	orig_line_rec.array_attribute10;

   close lines_c3;

   if orig_line_rec.array_distribution_line_id.count > 0 then
    l_loop_count := l_loop_count + orig_line_rec.array_distribution_line_id.count;
    FORALL i IN 1..orig_line_rec.array_distribution_line_id.count
      insert into psp_temp_orig_lines(
         element_type_id,
         element_group_id,
         gl_code_combination_id,
         project_id,
         expenditure_organization_id,
         expenditure_type,
         task_id,
         award_id,
         orig_distribution_date,
         distribution_amount,
         orig_line_id,
         dr_cr_flag,
         orig_source_type,
         effective_date,
         time_period_id,
         payroll_control_id,
         run_id,
         business_group_id,
         set_of_books_id,
	attribute_category,				-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10)
      values
         (orig_line_rec.array_element_type_id(i),
          orig_line_rec.array_element_group_id(i),
          orig_line_rec.array_glccid(i),
          orig_line_rec.array_project_id(i),
          orig_line_rec.array_exp_org_id(i),
          orig_line_rec.array_exp_type(i),
          orig_line_rec.array_task_id(i),
          orig_line_rec.array_award_id(i),
          orig_line_rec.array_distribution_date(i),
          orig_line_rec.array_distribution_amount(i),
          orig_line_rec.array_distribution_line_id(i),
          orig_line_rec.array_dr_cr_flag(i),
          orig_line_rec.array_tab_flag(i),
          orig_line_rec.array_effective_date(i),
          orig_line_rec.array_time_period_id(i),
          orig_line_rec.array_payroll_control_id(i),
          g_run_id,
          p_business_group_id,
          p_set_of_books_id,
          orig_line_rec.array_attribute_category(i),		-- Introduced DFF columns for bug fix 2908859
          orig_line_rec.array_attribute1(i),
          orig_line_rec.array_attribute2(i),
          orig_line_rec.array_attribute3(i),
          orig_line_rec.array_attribute4(i),
          orig_line_rec.array_attribute5(i),
          orig_line_rec.array_attribute6(i),
          orig_line_rec.array_attribute7(i),
          orig_line_rec.array_attribute8(i),
          orig_line_rec.array_attribute9(i),
          orig_line_rec.array_attribute10(i));

    /* flush all arrays */
    orig_line_rec.array_element_type_id .delete;
    orig_line_rec.array_element_group_id .delete;
    orig_line_rec.array_glccid .delete;
    orig_line_rec.array_project_id .delete;
    orig_line_rec.array_exp_org_id .delete;
    orig_line_rec.array_exp_type .delete;
    orig_line_rec.array_task_id .delete;
    orig_line_rec.array_award_id .delete;
    orig_line_rec.array_distribution_date .delete;
    orig_line_rec.array_distribution_amount .delete;
    orig_line_rec.array_distribution_line_id .delete;
    orig_line_rec.array_dr_cr_flag .delete;
    orig_line_rec.array_tab_flag .delete;
    orig_line_rec.array_effective_date .delete;
    orig_line_rec.array_time_period_id .delete;
    orig_line_rec.array_payroll_control_id .delete;
    orig_line_rec.array_attribute_category.delete;		-- Introduced for bug fix 2908859
    orig_line_rec.array_attribute1.delete;
    orig_line_rec.array_attribute2.delete;
    orig_line_rec.array_attribute3.delete;
    orig_line_rec.array_attribute4.delete;
    orig_line_rec.array_attribute5.delete;
    orig_line_rec.array_attribute6.delete;
    orig_line_rec.array_attribute7.delete;
    orig_line_rec.array_attribute8.delete;
    orig_line_rec.array_attribute9.delete;
    orig_line_rec.array_attribute10.delete;
  end if;

  if l_loop_count = 0 then
       RAISE NO_RECORDS_FOUND;
  end if;

  if l_loop_count  >  0 then
      if p_adjust_by = 'E' then
          open  temp_orig_sumline_E;
          fetch temp_orig_sumline_E bulk collect into
              orig_sumline_rec.array_element_type_id,
              orig_sumline_rec.array_glccid,
              orig_sumline_rec.array_project_id,
              orig_sumline_rec.array_exp_org_id,
              orig_sumline_rec.array_exp_type,
              orig_sumline_rec.array_task_id,
              orig_sumline_rec.array_award_id,
              orig_sumline_rec.array_dr_cr_flag,
              orig_sumline_rec.array_distribution_sum,
              orig_sumline_rec.array_run_id,
              orig_sumline_rec.array_set_of_books_id,
              orig_sumline_rec.array_business_group_id,
		orig_sumline_rec.array_attribute_category,		-- Introduced DFF columns for bug fix 2908859
		orig_sumline_rec.array_attribute1,
		orig_sumline_rec.array_attribute2,
		orig_sumline_rec.array_attribute3,
		orig_sumline_rec.array_attribute4,
		orig_sumline_rec.array_attribute5,
		orig_sumline_rec.array_attribute6,
		orig_sumline_rec.array_attribute7,
		orig_sumline_rec.array_attribute8,
		orig_sumline_rec.array_attribute9,
		orig_sumline_rec.array_attribute10;
           close temp_orig_sumline_E;

            for k in 1..orig_sumline_rec.array_run_id.count
            loop
              orig_sumline_rec.array_acct_group_id(k):= k;
            end loop;

            forall k in 1..orig_sumline_rec.array_run_id.count
              insert into  PSP_TEMP_ORIG_SUMLINES (
                           ELEMENT_TYPE_ID,
                           GL_CODE_COMBINATION_ID,
                           PROJECT_ID,
                           EXPENDITURE_ORGANIZATION_ID,
                           EXPENDITURE_TYPE,
                           TASK_ID,
                           AWARD_ID,
                           DR_CR_FLAG,
                           DISTRIBUTION_SUM,
                           RUN_ID,
                           SET_OF_BOOKS_ID,
                           BUSINESS_GROUP_ID,
                           ACCT_GROUP_ID,
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
			attribute10)
                values ( orig_sumline_rec.array_element_type_id(k),
                         orig_sumline_rec.array_glccid(k),
                         orig_sumline_rec.array_project_id(k),
                         orig_sumline_rec.array_exp_org_id(k),
                         orig_sumline_rec.array_exp_type(k),
                         orig_sumline_rec.array_task_id(k),
                         orig_sumline_rec.array_award_id(k),
                         orig_sumline_rec.array_dr_cr_flag(k),
                         orig_sumline_rec.array_distribution_sum(k),
                         orig_sumline_rec.array_run_id(k),
                         orig_sumline_rec.array_set_of_books_id(k),
                         orig_sumline_rec.array_business_group_id(k),
                         orig_sumline_rec.array_acct_group_id(k),
                         orig_sumline_rec.array_attribute_category(k),
			orig_sumline_rec.array_attribute1(k),
			orig_sumline_rec.array_attribute2(k),
			orig_sumline_rec.array_attribute3(k),
			orig_sumline_rec.array_attribute4(k),
			orig_sumline_rec.array_attribute5(k),
			orig_sumline_rec.array_attribute6(k),
			orig_sumline_rec.array_attribute7(k),
			orig_sumline_rec.array_attribute8(k),
			orig_sumline_rec.array_attribute9(k),
			orig_sumline_rec.array_attribute10(k));

       Update psp_temp_orig_lines  LINE
       set  LINE.acct_group_id = (select  MAS.acct_group_id
                          from psp_temp_orig_sumlines MAS
                          where MAS.run_id = g_run_id and
                            nvl(MAS.element_type_id,-9) = nvl(LINE.element_type_id,-9) and
                      --    MAS.dr_cr_flag = LINE.dr_cr_flag and   Commented for Bug 3625667
                            nvl(MAS.gl_code_combination_id,-9) =
                                                 nvl(LINE.gl_code_combination_id,-9) and
                            nvl(MAS.project_id,-9)= nvl(LINE.project_id,-9) and
                            nvl(MAS.task_id,-9) = nvl(LINE.task_id,-9) and
                            nvl(MAS.expenditure_organization_id,-9) =
                            nvl(LINE.expenditure_organization_id,-9) and
                            nvl(MAS.award_id, -9) = nvl(LINE.award_id, -9) and
                               (MAS.expenditure_type = LINE.expenditure_type  or
                               (MAS.expenditure_type  is null and  LINE.expenditure_type is null))
			AND	(NVL(mas.attribute_category, 'NULL') = NVL(line.attribute_category, 'NULL'))	-- Introduced DFF column check for bug fix 2908859
			AND	(NVL(mas.attribute1, 'NULL') = NVL(line.attribute1, 'NULL'))
			AND	(NVL(mas.attribute2, 'NULL') = NVL(line.attribute2, 'NULL'))
			AND	(NVL(mas.attribute3, 'NULL') = NVL(line.attribute3, 'NULL'))
			AND	(NVL(mas.attribute4, 'NULL') = NVL(line.attribute4, 'NULL'))
			AND	(NVL(mas.attribute5, 'NULL') = NVL(line.attribute5, 'NULL'))
			AND	(NVL(mas.attribute6, 'NULL') = NVL(line.attribute6, 'NULL'))
			AND	(NVL(mas.attribute7, 'NULL') = NVL(line.attribute7, 'NULL'))
			AND	(NVL(mas.attribute8, 'NULL') = NVL(line.attribute8, 'NULL'))
			AND	(NVL(mas.attribute9, 'NULL') = NVL(line.attribute9, 'NULL'))
			AND	(NVL(mas.attribute10, 'NULL') = NVL(line.attribute10, 'NULL')))
      where LINE.run_id = g_run_id;


      elsif p_adjust_by = 'G' then
          open  temp_orig_sumline_G;
          fetch temp_orig_sumline_G bulk collect into
              orig_sumline_rec.array_element_group_id,
              orig_sumline_rec.array_glccid,
              orig_sumline_rec.array_project_id,
              orig_sumline_rec.array_exp_org_id,
              orig_sumline_rec.array_exp_type,
              orig_sumline_rec.array_task_id,
              orig_sumline_rec.array_award_id,
              orig_sumline_rec.array_dr_cr_flag,
              orig_sumline_rec.array_distribution_sum,
              orig_sumline_rec.array_run_id,
              orig_sumline_rec.array_set_of_books_id,
              orig_sumline_rec.array_business_group_id,
		orig_sumline_rec.array_attribute_category,		-- Introduced DFF columns for bug fix 2908859
		orig_sumline_rec.array_attribute1,
		orig_sumline_rec.array_attribute2,
		orig_sumline_rec.array_attribute3,
		orig_sumline_rec.array_attribute4,
		orig_sumline_rec.array_attribute5,
		orig_sumline_rec.array_attribute6,
		orig_sumline_rec.array_attribute7,
		orig_sumline_rec.array_attribute8,
		orig_sumline_rec.array_attribute9,
		orig_sumline_rec.array_attribute10;
           close temp_orig_sumline_G;

           for k in 1..orig_sumline_rec.array_run_id.count
           loop
             orig_sumline_rec.array_acct_group_id(k):= k;
           end loop;

           forall k in 1..orig_sumline_rec.array_run_id.count
              insert into  PSP_TEMP_ORIG_SUMLINES (
                           ELEMENT_GROUP_ID,
                           GL_CODE_COMBINATION_ID,
                           PROJECT_ID,
                           EXPENDITURE_ORGANIZATION_ID,
                           EXPENDITURE_TYPE,
                           TASK_ID,
                           AWARD_ID,
                           DR_CR_FLAG,
                           DISTRIBUTION_SUM,
                           RUN_ID,
                           SET_OF_BOOKS_ID,
                           BUSINESS_GROUP_ID,
                           ACCT_GROUP_ID,
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
			attribute10)
                values ( orig_sumline_rec.array_element_group_id(k),
                         orig_sumline_rec.array_glccid(k),
                         orig_sumline_rec.array_project_id(k),
                         orig_sumline_rec.array_exp_org_id(k),
                         orig_sumline_rec.array_exp_type(k),
                         orig_sumline_rec.array_task_id(k),
                         orig_sumline_rec.array_award_id(k),
                         orig_sumline_rec.array_dr_cr_flag(k),
                         orig_sumline_rec.array_distribution_sum(k),
                         orig_sumline_rec.array_run_id(k),
                         orig_sumline_rec.array_set_of_books_id(k),
                         orig_sumline_rec.array_business_group_id(k),
                         orig_sumline_rec.array_acct_group_id(k),
                         orig_sumline_rec.array_attribute_category(k),
			orig_sumline_rec.array_attribute1(k),
			orig_sumline_rec.array_attribute2(k),
			orig_sumline_rec.array_attribute3(k),
			orig_sumline_rec.array_attribute4(k),
			orig_sumline_rec.array_attribute5(k),
			orig_sumline_rec.array_attribute6(k),
			orig_sumline_rec.array_attribute7(k),
			orig_sumline_rec.array_attribute8(k),
			orig_sumline_rec.array_attribute9(k),
			orig_sumline_rec.array_attribute10(k));
       Update psp_temp_orig_lines  LINE
       set  LINE.acct_group_id = (select  MAS.acct_group_id
                          from psp_temp_orig_sumlines MAS
                          where MAS.run_id = g_run_id and
                            nvl(MAS.element_group_id,-9) = nvl(LINE.element_group_id,-9) and
                       --   MAS.dr_cr_flag = LINE.dr_cr_flag and Commented for Bug 3625667
                            nvl(MAS.gl_code_combination_id,-9) =
                                                 nvl(LINE.gl_code_combination_id,-9) and
                            nvl(MAS.project_id,-9)= nvl(LINE.project_id,-9) and
                            nvl(MAS.task_id,-9) = nvl(LINE.task_id,-9) and
                            nvl(MAS.expenditure_organization_id,-9) =
                            nvl(LINE.expenditure_organization_id,-9) and
                            nvl(MAS.award_id, -9) = nvl(LINE.award_id, -9) and
                               (MAS.expenditure_type = LINE.expenditure_type  or
                               (MAS.expenditure_type  is null and  LINE.expenditure_type is null))
			AND	(NVL(mas.attribute_category, 'NULL') = NVL(line.attribute_category, 'NULL'))	-- Introduced DFF column check for bug fix 2908859
			AND	(NVL(mas.attribute1, 'NULL') = NVL(line.attribute1, 'NULL'))
			AND	(NVL(mas.attribute2, 'NULL') = NVL(line.attribute2, 'NULL'))
			AND	(NVL(mas.attribute3, 'NULL') = NVL(line.attribute3, 'NULL'))
			AND	(NVL(mas.attribute4, 'NULL') = NVL(line.attribute4, 'NULL'))
			AND	(NVL(mas.attribute5, 'NULL') = NVL(line.attribute5, 'NULL'))
			AND	(NVL(mas.attribute6, 'NULL') = NVL(line.attribute6, 'NULL'))
			AND	(NVL(mas.attribute7, 'NULL') = NVL(line.attribute7, 'NULL'))
			AND	(NVL(mas.attribute8, 'NULL') = NVL(line.attribute8, 'NULL'))
			AND	(NVL(mas.attribute9, 'NULL') = NVL(line.attribute9, 'NULL'))
			AND	(NVL(mas.attribute10, 'NULL') = NVL(line.attribute10, 'NULL')))
      where LINE.run_id = g_run_id;


      else   --- at assignment level
          open  temp_orig_sumline_A;
          fetch temp_orig_sumline_A bulk collect into
              orig_sumline_rec.array_glccid,
              orig_sumline_rec.array_project_id,
              orig_sumline_rec.array_exp_org_id,
              orig_sumline_rec.array_exp_type,
              orig_sumline_rec.array_task_id,
              orig_sumline_rec.array_award_id,
              orig_sumline_rec.array_dr_cr_flag,
              orig_sumline_rec.array_distribution_sum,
              orig_sumline_rec.array_run_id,
              orig_sumline_rec.array_set_of_books_id,
              orig_sumline_rec.array_business_group_id,
		orig_sumline_rec.array_attribute_category,		-- Introduced DFF columns for bug fix 2908859
		orig_sumline_rec.array_attribute1,
		orig_sumline_rec.array_attribute2,
		orig_sumline_rec.array_attribute3,
		orig_sumline_rec.array_attribute4,
		orig_sumline_rec.array_attribute5,
		orig_sumline_rec.array_attribute6,
		orig_sumline_rec.array_attribute7,
		orig_sumline_rec.array_attribute8,
		orig_sumline_rec.array_attribute9,
		orig_sumline_rec.array_attribute10;
           close temp_orig_sumline_A;

            for k in 1..orig_sumline_rec.array_run_id.count
            loop
              orig_sumline_rec.array_acct_group_id(k):= k;
            end loop;

           forall k in 1..orig_sumline_rec.array_run_id.count
              insert into  PSP_TEMP_ORIG_SUMLINES (
                           GL_CODE_COMBINATION_ID,
                           PROJECT_ID,
                           EXPENDITURE_ORGANIZATION_ID,
                           EXPENDITURE_TYPE,
                           TASK_ID,
                           AWARD_ID,
                           DR_CR_FLAG,
                           DISTRIBUTION_SUM,
                           RUN_ID,
                           SET_OF_BOOKS_ID,
                           BUSINESS_GROUP_ID,
                           ACCT_GROUP_ID,
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
			attribute10)
                values ( orig_sumline_rec.array_glccid(k),
                         orig_sumline_rec.array_project_id(k),
                         orig_sumline_rec.array_exp_org_id(k),
                         orig_sumline_rec.array_exp_type(k),
                         orig_sumline_rec.array_task_id(k),
                         orig_sumline_rec.array_award_id(k),
                         orig_sumline_rec.array_dr_cr_flag(k),
                         orig_sumline_rec.array_distribution_sum(k),
                         orig_sumline_rec.array_run_id(k),
                         orig_sumline_rec.array_set_of_books_id(k),
                         orig_sumline_rec.array_business_group_id(k),
                         orig_sumline_rec.array_acct_group_id(k),
                         orig_sumline_rec.array_attribute_category(k),
			orig_sumline_rec.array_attribute1(k),
			orig_sumline_rec.array_attribute2(k),
			orig_sumline_rec.array_attribute3(k),
			orig_sumline_rec.array_attribute4(k),
			orig_sumline_rec.array_attribute5(k),
			orig_sumline_rec.array_attribute6(k),
			orig_sumline_rec.array_attribute7(k),
			orig_sumline_rec.array_attribute8(k),
			orig_sumline_rec.array_attribute9(k),
			orig_sumline_rec.array_attribute10(k));


   Update psp_temp_orig_lines  LINE
   set  LINE.acct_group_id = (select  MAS.acct_group_id
                          from psp_temp_orig_sumlines MAS
                          where MAS.run_id = g_run_id and
                   --     MAS.dr_cr_flag = LINE.dr_cr_flag and Commented for bug 3625667
                            nvl(MAS.gl_code_combination_id,-9) =
                                                 nvl(LINE.gl_code_combination_id,-9) and
                            nvl(MAS.project_id,-9)= nvl(LINE.project_id,-9) and
                            nvl(MAS.task_id,-9) = nvl(LINE.task_id,-9) and
                            nvl(MAS.expenditure_organization_id,-9) =
                            nvl(LINE.expenditure_organization_id,-9) and
                            nvl(MAS.award_id, -9) = nvl(LINE.award_id, -9) and
                               (MAS.expenditure_type = LINE.expenditure_type  or
                               (MAS.expenditure_type  is null and  LINE.expenditure_type is null))
			AND	(NVL(mas.attribute_category, 'NULL') = NVL(line.attribute_category, 'NULL'))	-- Introduced DFF column check for bug fix 2908859
			AND	(NVL(mas.attribute1, 'NULL') = NVL(line.attribute1, 'NULL'))
			AND	(NVL(mas.attribute2, 'NULL') = NVL(line.attribute2, 'NULL'))
			AND	(NVL(mas.attribute3, 'NULL') = NVL(line.attribute3, 'NULL'))
			AND	(NVL(mas.attribute4, 'NULL') = NVL(line.attribute4, 'NULL'))
			AND	(NVL(mas.attribute5, 'NULL') = NVL(line.attribute5, 'NULL'))
			AND	(NVL(mas.attribute6, 'NULL') = NVL(line.attribute6, 'NULL'))
			AND	(NVL(mas.attribute7, 'NULL') = NVL(line.attribute7, 'NULL'))
			AND	(NVL(mas.attribute8, 'NULL') = NVL(line.attribute8, 'NULL'))
			AND	(NVL(mas.attribute9, 'NULL') = NVL(line.attribute9, 'NULL'))
			AND	(NVL(mas.attribute10, 'NULL') = NVL(line.attribute10, 'NULL')))
 where LINE.run_id = g_run_id;
      end if;

    -- flush arrays
   orig_sumline_rec.array_element_type_id.delete;
   orig_sumline_rec.array_element_group_id.delete;
   orig_sumline_rec.array_glccid.delete;
   orig_sumline_rec.array_project_id.delete;
   orig_sumline_rec.array_exp_org_id.delete;
   orig_sumline_rec.array_exp_type.delete;
   orig_sumline_rec.array_task_id.delete;
   orig_sumline_rec.array_award_id.delete;
   orig_sumline_rec.array_dr_cr_flag.delete;
   orig_sumline_rec.array_distribution_sum.delete;
   orig_sumline_rec.array_run_id.delete;
   orig_sumline_rec.array_set_of_books_id.delete;
   orig_sumline_rec.array_business_group_id.delete;
   orig_sumline_rec.array_acct_group_id.delete;
   orig_sumline_rec.array_attribute_category.delete;
   orig_sumline_rec.array_attribute1.delete;
   orig_sumline_rec.array_attribute2.delete;
   orig_sumline_rec.array_attribute3.delete;
   orig_sumline_rec.array_attribute4.delete;
   orig_sumline_rec.array_attribute5.delete;
   orig_sumline_rec.array_attribute6.delete;
   orig_sumline_rec.array_attribute7.delete;
   orig_sumline_rec.array_attribute8.delete;
   orig_sumline_rec.array_attribute9.delete;
   orig_sumline_rec.array_attribute10.delete;


end if;
   retcode := 0;

EXCEPTION
   WHEN IN_USE_EXCEPTION THEN
      retcode := 3;

   WHEN NO_RECORDS_FOUND THEN
      retcode := 1;

   WHEN OTHERS THEN
      g_error_api_path := 'LOAD_TABLE:'||g_error_api_path;
      fnd_msg_pub.get(p_msg_index     =>  FND_MSG_PUB.G_FIRST,
                      p_encoded       =>  FND_API.G_FALSE,
                      p_data          =>  l_msg_data,
                      p_msg_index_out =>  l_msg_count);
      errbuf := l_msg_data || fnd_global.local_chr(10) || g_error_api_path;
      retcode := 2;
END;

----------P R O C E D U R E: GET_APPROVAL_HEADER -------------------------------
--
--
--  Purpose:   This procedure is called by the find batched screen in the
--	         distribution transfers approval form.
--		   The purpose is to retrieve the display only header information
--		   in the approval form for the batch name the user selects in
--		   the find batches screen.
--
----------------------------------------------------------------------------------

PROCEDURE get_approval_header(errbuf  			OUT NOCOPY VARCHAR2,
                              retcode 			OUT NOCOPY VARCHAR2,
		              p_batch_name 		IN VARCHAR2,
			      p_business_group_id	IN  NUMBER,
			      p_set_of_books_id		IN  NUMBER,
			      l_full_name 		OUT NOCOPY VARCHAR2,
			      l_employee_number 	OUT NOCOPY VARCHAR2,
			      l_assignment_number 	OUT NOCOPY VARCHAR2,
                              l_assignment_organization OUT NOCOPY VARCHAR2, --added for DA-ENH
			      l_begin_date 		OUT NOCOPY DATE,
			      l_end_date 		OUT NOCOPY DATE,
			      l_currency_code 		OUT NOCOPY VARCHAR2,	-- Introduced for Bug fix 2916848
 			      l_batch_comments 		OUT NOCOPY VARCHAR2) IS


l_person_id             NUMBER;
l_assignment_id		NUMBER;
l_element_type_id		NUMBER;

CURSOR app_dates_c is

SELECT
       person_id,
       assignment_id,
       min(distribution_date),
       max(distribution_date)
FROM
       psp_adjustment_lines
WHERE
       batch_name = p_batch_name
   and business_group_id = p_business_group_id
   and set_of_books_id   = p_set_of_books_id
GROUP BY
       person_id,assignment_id;


CURSOR app_header_c is
/* changed the cursor select for DA-ENH  */
/*****	Modified the following cursor defn for R12 performance fixes (bug 4507892)
 select distinct ppf.full_name,
        ppf.employee_number,
        pas.assignment_number
 from per_people_f ppf,
      per_assignments_f pas
 where ppf.person_id = l_person_id and
       pas.assignment_id = l_assignment_id;
	end of comment for bug fix 4507892	*****/
--	New cursor defn for bug fix 4507892
SELECT	DISTINCT ppf.full_name,
	ppf.employee_number,
	paf.assignment_number
FROM	per_people_f ppf,
	per_assignments_f paf
WHERE	ppf.person_id = l_person_id
AND	paf.person_id = ppf.person_id
AND	paf.assignment_id = l_assignment_id;

CURSOR app_comments_c is
SELECT comments ,
	currency_code	-- Introduced this for bug fix 2916848
FROM   psp_adjustment_control_table
WHERE  adjustment_batch_name = p_batch_name;


l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);

-- new cursor for DA-ENH


CURSOR	assign_org_name_cur IS
SELECT	name
FROM	hr_all_organization_units haou,
	per_assignments_f paf
WHERE	haou.organization_id = paf.organization_id
AND	paf.assignment_id = l_assignment_id
AND	TRUNC(SYSDATE) BETWEEN paf.effective_start_date AND paf.effective_end_date;



BEGIN

  g_error_api_path := '';
  fnd_msg_pub.initialize;
  errbuf := '';
  open app_dates_c;
  fetch app_dates_c into
    l_person_id,
    l_assignment_id,
    l_begin_date,
    l_end_date;
  if app_dates_c%NOTFOUND then
    close app_dates_c;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  else
    close app_dates_c;
  end if;

  open app_header_c;
  fetch app_header_c into
    l_full_name,
    l_employee_number,
    l_assignment_number;
  if app_header_c%NOTFOUND then
    close app_header_c;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  else
    close app_header_c;
  end if;

  open assign_org_name_cur;
  fetch assign_org_name_cur into l_assignment_organization;
  close assign_org_name_cur;

  open app_comments_c;
  fetch app_comments_c into
    l_batch_comments, l_currency_code;	-- Introduced currency_code for bug fix 2916848
  if app_comments_c%NOTFOUND then
    close app_comments_c;
    l_batch_comments :='No comments found.';
  else
    close app_comments_c;
  end if;

retcode := 0;

EXCEPTION
 WHEN OTHERS THEN
      g_error_api_path := 'GET_APPROVAL_HEADER:'||g_error_api_path;
      fnd_msg_pub.get(p_msg_index     =>  FND_MSG_PUB.G_FIRST,
                      p_encoded       =>  FND_API.G_FALSE,
                      p_data          =>  l_msg_data,
                      p_msg_index_out =>  l_msg_count);
      errbuf := l_msg_data || fnd_global.local_chr(10) || g_error_api_path;
      retcode := 2;

END;
--------------------------------------------------------------------


----------P R O C E D U R E: LOAD_APPROVAL_TABLE -------------------------------
--
--
--  Purpose:   This procedure is called by the find batches screen of the
--		   distribution transfers approval form. The purpose is to
--		   select adjusted lines waiting approval for a particular batch
--		   name.  For each line selected, the line is passed to the
--		   procedure approval_sumlines to sum the line by unique
--		   GL/POETA account with other lines in the same batch.
--
----------------------------------------------------------------------------------

PROCEDURE load_approval_table(errbuf  			OUT NOCOPY VARCHAR2,
                              retcode 			OUT NOCOPY VARCHAR2,
			      p_batch_name 		IN VARCHAR2,
			      p_run_id 			IN NUMBER,
			      p_business_group_id	IN Number,
			      p_set_of_books_id		IN NUMBER) IS

  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);

  no_records_found EXCEPTION;

-- added following variable and cursor for DA-ENH
  l_adjust_by varchar2(1);
  cursor show_elements is
  select adjust_by
  from psp_adjustment_control_table
  where adjustment_batch_name = p_batch_name;

--	Introduced the following for bug fix 2890110
	CURSOR	adj_set_cur IS
	SELECT	adj_set_number, SUM(distribution_sum)
	FROM	psp_temp_dest_sumlines ptdl
	WHERE	ptdl.run_id = p_run_id
	AND	ptdl.business_group_id = p_business_group_id
	AND	ptdl.set_of_books_id = p_set_of_books_id
	AND	ptdl.dr_cr_flag = 'D'
	GROUP BY adj_set_number;

	l_adj_set_number	NUMBER;
	l_adj_set_total		NUMBER;	-- Corrected width from (15, 2) to 30 for bug fix 2916848
--	End of bug fix 2890110
-- added for 4992668
l_dff_grouping_option   varchar2(1) DEFAULT psp_general.get_act_dff_grouping_option(p_business_group_id);

BEGIN

   g_error_api_path := '';
   fnd_msg_pub.initialize;
   errbuf := '';
   g_run_id := p_run_id;
if l_dff_grouping_option = 'Y' then
-- added for DA-ENH
    open show_elements;
     fetch show_elements into l_adjust_by;
     close show_elements;
    if l_adjust_by = 'E' then
       INSERT into psp_temp_dest_sumlines (
             acct_group_id,       --- added four fields for DA-ENH
             adj_set_number,
             original_line_flag,
           line_number,
           element_type_id,
	gl_code_combination_id,
 	project_id,
 	expenditure_organization_id,
 	expenditure_type,
	task_id,
	award_id,
	dr_cr_flag,
 	distribution_sum,
	distribution_percent,
	run_id,
 	set_of_books_id,
 	business_group_id,
	attribute_category,				-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10)
  SELECT
	MIN(ROWNUM),           --- added for DA-ENH
          adj_set_number,           --- added for DA-ENH
          original_line_flag,        --- moved from below for DA-ENH...
          line_number,                 --- added for DA-ENH
         element_type_id,               --- added for DA-ENH
          gl_code_combination_id,
          project_id,
          expenditure_organization_id,
          expenditure_type,
          task_id,
          award_id,
--        dr_cr_flag, Commented for Bug 3625667
          DECODE(sign(sum(decode(dr_cr_flag, 'D',distribution_amount, -distribution_amount))),-1,'C','D') dr_cr_flag,
          sum(decode(dr_cr_flag, 'D',distribution_amount, -distribution_amount)),
          percent,                             ---- added for DA-ENH
          p_run_id,
          p_set_of_books_id,
         p_business_group_id,
	attribute_category,				-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10
FROM  psp_adjustment_lines
WHERE  batch_name = p_batch_name
    and   business_group_id = p_business_group_id
    and   set_of_books_id   = p_set_of_books_id
GROUP by adj_set_number,
         original_line_flag,
          line_number,
          element_type_id,
          gl_code_combination_id,
          project_id,
          expenditure_organization_id,
          expenditure_type,
          task_id,
          award_id,
--        dr_cr_flag,   Commented for Bug 3625667
          percent,
	attribute_category,				-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10;
elsif l_adjust_by = 'G' then
        INSERT into psp_temp_dest_sumlines (
             acct_group_id,       --- added four fields for DA-ENH
                  adj_set_number,
                  original_line_flag,
                   line_number,
                   element_group_id,
	gl_code_combination_id,
 	project_id,
 	expenditure_organization_id,
 	expenditure_type,
	task_id,
	award_id,
	dr_cr_flag,
 	distribution_sum,
	distribution_percent,
	run_id,
 	set_of_books_id,
 	business_group_id,
	attribute_category,				-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10)
  SELECT
	MIN(ROWNUM),           --- added for DA-ENH
          a.adj_set_number,           --- added for DA-ENH
          a.original_line_flag,        --- moved from below for DA-ENH...
          a.line_number,                 --- added for DA-ENH
         b.element_group_id,               --- added for DA-ENH
          a.gl_code_combination_id,
          a.project_id,
          a.expenditure_organization_id,
          a.expenditure_type,
          a.task_id,
          a.award_id,
--        a.dr_cr_flag, Commented for bug 3625667
          decode(sign(sum(decode(a.dr_cr_flag, 'D',distribution_amount, -distribution_amount))),-1,'C','D') dr_cr_flag,
          sum(decode(dr_cr_flag, 'D',distribution_amount, -distribution_amount)),
          a.percent,                             ---- added for DA-ENH
          p_run_id,
          p_set_of_books_id,
         p_business_group_id,
	a.attribute_category,				-- Introduced DFF columns for bug fix 2908859
	a.attribute1,
	a.attribute2,
	a.attribute3,
	a.attribute4,
	a.attribute5,
	a.attribute6,
	a.attribute7,
	a.attribute8,
	a.attribute9,
	a.attribute10
FROM  psp_adjustment_lines a,
      psp_group_element_list b
WHERE  a.batch_name = p_batch_name
    and   a.business_group_id = p_business_group_id
    and   a.set_of_books_id   = p_set_of_books_id
    and   b.element_type_id(+) = a.element_type_id
GROUP by a.adj_set_number,
         a.original_line_flag,
          a.line_number,
          b.element_group_id,
          a.gl_code_combination_id,
          a.project_id,
          a.expenditure_organization_id,
          a.expenditure_type,
          a.task_id,
          a.award_id,
     --   a.dr_cr_flag, Commented for bug 3625667
          a.percent,
	a.attribute_category,				-- Introduced DFF columns for bug fix 2908859
	a.attribute1,
	a.attribute2,
	a.attribute3,
	a.attribute4,
	a.attribute5,
	a.attribute6,
	a.attribute7,
	a.attribute8,
	a.attribute9,
	a.attribute10;
else
  INSERT into psp_temp_dest_sumlines (
             acct_group_id,       --- added four fields for DA-ENH
                  adj_set_number,
                  original_line_flag,
                   line_number,
	gl_code_combination_id,
 	project_id,
 	expenditure_organization_id,
 	expenditure_type,
	task_id,
	award_id,
	dr_cr_flag,
 	distribution_sum,
	distribution_percent,
	run_id,
 	set_of_books_id,
 	business_group_id,
	attribute_category,				-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10)
 SELECT
	MIN(ROWNUM),           --- added for DA-ENH
          adj_set_number,           --- added for DA-ENH
          original_line_flag,        --- moved from below for DA-ENH...
          line_number,                 --- added for DA-ENH
          gl_code_combination_id,
          project_id,
          expenditure_organization_id,
          expenditure_type,
          task_id,
          award_id,
--        dr_cr_flag, Commented for Bug 3625667
          decode(sign(sum(decode(dr_cr_flag, 'D',distribution_amount, -distribution_amount))),-1,'C','D') dr_cr_flag,
          sum(decode(dr_cr_flag, 'D',distribution_amount, -distribution_amount)),
          percent,                             ---- added for DA-ENH
          p_run_id,
          p_set_of_books_id,
         p_business_group_id,
	attribute_category,				-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10
FROM  psp_adjustment_lines
WHERE  batch_name = p_batch_name
    and   business_group_id = p_business_group_id
    and   set_of_books_id   = p_set_of_books_id
GROUP by adj_set_number,
         original_line_flag,
          line_number,
          gl_code_combination_id,
          project_id,
          expenditure_organization_id,
          expenditure_type,
          task_id,
          award_id,
   --     dr_cr_flag, Commented for Bug 3625667
          percent,
	attribute_category,				-- Introduced DFF columns for bug fix 2908859
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10;
end if;
else   ---- l_dff option = 'N'
    open show_elements;
     fetch show_elements into l_adjust_by;
     close show_elements;
    if l_adjust_by = 'E' then
       INSERT into psp_temp_dest_sumlines (
             acct_group_id,       --- added four fields for DA-ENH
             adj_set_number,
             original_line_flag,
           line_number,
           element_type_id,
	gl_code_combination_id,
 	project_id,
 	expenditure_organization_id,
 	expenditure_type,
	task_id,
	award_id,
	dr_cr_flag,
 	distribution_sum,
	distribution_percent,
	run_id,
 	set_of_books_id,
 	business_group_id)
  SELECT
	MIN(ROWNUM),           --- added for DA-ENH
          adj_set_number,           --- added for DA-ENH
          original_line_flag,        --- moved from below for DA-ENH...
          line_number,                 --- added for DA-ENH
         element_type_id,               --- added for DA-ENH
          gl_code_combination_id,
          project_id,
          expenditure_organization_id,
          expenditure_type,
          task_id,
          award_id,
--        dr_cr_flag, Commented for Bug 3625667
          DECODE(sign(sum(decode(dr_cr_flag, 'D',distribution_amount, -distribution_amount))),-1,'C','D') dr_cr_flag,
          sum(decode(dr_cr_flag, 'D',distribution_amount, -distribution_amount)),
          percent,                             ---- added for DA-ENH
          p_run_id,
          p_set_of_books_id,
         p_business_group_id
FROM  psp_adjustment_lines
WHERE  batch_name = p_batch_name
    and   business_group_id = p_business_group_id
    and   set_of_books_id   = p_set_of_books_id
GROUP by adj_set_number,
         original_line_flag,
          line_number,
          element_type_id,
          gl_code_combination_id,
          project_id,
          expenditure_organization_id,
          expenditure_type,
          task_id,
          award_id,
--        dr_cr_flag,   Commented for Bug 3625667
          percent;
elsif l_adjust_by = 'G' then
        INSERT into psp_temp_dest_sumlines (
             acct_group_id,       --- added four fields for DA-ENH
                  adj_set_number,
                  original_line_flag,
                   line_number,
                   element_group_id,
	gl_code_combination_id,
 	project_id,
 	expenditure_organization_id,
 	expenditure_type,
	task_id,
	award_id,
	dr_cr_flag,
 	distribution_sum,
	distribution_percent,
	run_id,
 	set_of_books_id,
 	business_group_id)
  SELECT
	MIN(ROWNUM),           --- added for DA-ENH
          a.adj_set_number,           --- added for DA-ENH
          a.original_line_flag,        --- moved from below for DA-ENH...
          a.line_number,                 --- added for DA-ENH
         b.element_group_id,               --- added for DA-ENH
          a.gl_code_combination_id,
          a.project_id,
          a.expenditure_organization_id,
          a.expenditure_type,
          a.task_id,
          a.award_id,
--        a.dr_cr_flag, Commented for bug 3625667
          decode(sign(sum(decode(a.dr_cr_flag, 'D',distribution_amount, -distribution_amount))),-1,'C','D') dr_cr_flag,
          sum(decode(dr_cr_flag, 'D',distribution_amount, -distribution_amount)),
          a.percent,                             ---- added for DA-ENH
          p_run_id,
          p_set_of_books_id,
         p_business_group_id
FROM  psp_adjustment_lines a,
      psp_group_element_list b
WHERE  a.batch_name = p_batch_name
    and   a.business_group_id = p_business_group_id
    and   a.set_of_books_id   = p_set_of_books_id
    and   b.element_type_id(+) = a.element_type_id
GROUP by a.adj_set_number,
         a.original_line_flag,
          a.line_number,
          b.element_group_id,
          a.gl_code_combination_id,
          a.project_id,
          a.expenditure_organization_id,
          a.expenditure_type,
          a.task_id,
          a.award_id,
     --   a.dr_cr_flag, Commented for bug 3625667
          a.percent;
else
  INSERT into psp_temp_dest_sumlines (
             acct_group_id,       --- added four fields for DA-ENH
                  adj_set_number,
                  original_line_flag,
                   line_number,
	gl_code_combination_id,
 	project_id,
 	expenditure_organization_id,
 	expenditure_type,
	task_id,
	award_id,
	dr_cr_flag,
 	distribution_sum,
	distribution_percent,
	run_id,
 	set_of_books_id,
 	business_group_id)
 SELECT
	MIN(ROWNUM),           --- added for DA-ENH
          adj_set_number,           --- added for DA-ENH
          original_line_flag,        --- moved from below for DA-ENH...
          line_number,                 --- added for DA-ENH
          gl_code_combination_id,
          project_id,
          expenditure_organization_id,
          expenditure_type,
          task_id,
          award_id,
--        dr_cr_flag, Commented for Bug 3625667
          decode(sign(sum(decode(dr_cr_flag, 'D',distribution_amount, -distribution_amount))),-1,'C','D') dr_cr_flag,
          sum(decode(dr_cr_flag, 'D',distribution_amount, -distribution_amount)),
          percent,                             ---- added for DA-ENH
          p_run_id,
          p_set_of_books_id,
         p_business_group_id
FROM  psp_adjustment_lines
WHERE  batch_name = p_batch_name
    and   business_group_id = p_business_group_id
    and   set_of_books_id   = p_set_of_books_id
GROUP by adj_set_number,
         original_line_flag,
          line_number,
          gl_code_combination_id,
          project_id,
          expenditure_organization_id,
          expenditure_type,
          task_id,
          award_id,
   --     dr_cr_flag, Commented for Bug 3625667
          percent;
 end if;
end if;
if sql%rowcount = 0 then
    raise no_records_found;
end if;
----- New code ends here for DA-ENH

--	Introduced for bug fix 2890110
	OPEN adj_set_cur;
	LOOP
		FETCH adj_set_cur INTO l_adj_set_number, l_adj_set_total;
		EXIT WHEN adj_set_cur%NOTFOUND;
                --- changed g_precision to 2.. below...for 4992668
		UPDATE	psp_temp_dest_sumlines ptdl
		SET	distribution_percent = (ROUND((100 * ABS(distribution_sum) / l_adj_set_total), 2))
		WHERE	ptdl.run_id = p_run_id
		AND	ptdl.business_group_id = p_business_group_id
		AND	ptdl.set_of_books_id   = p_set_of_books_id
		AND	ptdl.adj_set_number = l_adj_set_number;
	END LOOP;
	CLOSE adj_set_cur;
	UPDATE	psp_temp_dest_sumlines ptdl
	SET	distribution_percent = (-1 * distribution_percent)
	WHERE	ptdl.run_id = p_run_id
	AND	ptdl.business_group_id = p_business_group_id
	AND	ptdl.set_of_books_id   = p_set_of_books_id
	AND	ptdl.dr_cr_flag = 'C';
--	End of bug fix 2890110

  --- bug 4992668
   psp_wf_adj_custom.dff_for_approver(p_batch_name,
                             p_run_id,
                             p_business_group_id,
                             p_set_of_books_id);

   retcode := 0;
EXCEPTION
   WHEN NO_RECORDS_FOUND THEN
      retcode := 1;

   WHEN OTHERS THEN
      g_error_api_path := 'LOAD_TABLE:'||g_error_api_path;
      fnd_msg_pub.get(p_msg_index     =>  FND_MSG_PUB.G_FIRST,
                      p_encoded       =>  FND_API.G_FALSE,
                      p_data          =>  l_msg_data,
                      p_msg_index_out =>  l_msg_count);
      errbuf := l_msg_data || fnd_global.local_chr(10) || g_error_api_path;
      retcode := 2;
END;
-------------------------------------------------------------



----------P R O C E D U R E: INSERT_ADJ_LINES -------------------------------
--
--
--  Purpose:   This procedure is called by procedure generate_lines described below.
--		   The purpose is to insert lines into the table psp_adjustment_lines.
--		   These lines are both the reversal and adjusted lines.
--
----------------------------------------------------------------------------------

procedure insert_adj_lines(p_person_id        		IN NUMBER,
 		           p_assignment_id    		IN NUMBER,
		           p_element_type_id  		IN NUMBER,
                           p_batch_name       		IN VARCHAR2,
		           p_distribution_date  	IN DATE,
			   p_effective_date   		IN DATE,
			   p_distribution_amount  	IN NUMBER,
		           p_dr_cr_flag  		IN VARCHAR2,
			   p_payroll_control_id  	IN NUMBER,
			   p_time_period_id  		IN NUMBER,
		           p_status_code  		IN VARCHAR2,
		           p_set_of_books_id  		IN NUMBER,
			   p_gl_code_combination_id  	IN NUMBER,
			   p_project_id  		IN NUMBER,
 			   p_expenditure_organization_id  	IN NUMBER,
 			   p_expenditure_type  		IN VARCHAR2,
			   p_task_id  			IN NUMBER,
			   p_award_id  			IN NUMBER,
			   p_reversal_entry_flag  	IN VARCHAR2,
   			   p_original_line_flag   	IN VARCHAR2,
			   p_distribution_percent 	In NUMBER,
			   p_orig_source_type 		IN VARCHAR2,
		           p_orig_line_id  		IN NUMBER,
			   p_business_group_id		IN NUMBER,
			   p_return_status  		OUT NOCOPY VARCHAR2)  IS
   begin

       insert into psp_adjustment_lines(adjustment_line_id,
					person_id,
					assignment_id,
					element_type_id,
					distribution_date,
					effective_date,
					distribution_amount,
					dr_cr_flag,
					payroll_control_id,
					source_type,
					source_code,
					time_period_id,
					batch_name,
					status_code,
					set_of_books_id,
					gl_code_combination_id,
					project_id,
					expenditure_organization_id,
					expenditure_type,
					task_id,
					award_id,
					suspense_org_account_id,
					suspense_reason_code,
					effort_report_id,
					version_num,
					summary_line_id,
					reversal_entry_flag,
				      original_line_flag,
					user_defined_field,
					percent,
					orig_source_type,
					orig_line_id,
					business_group_id,
					attribute_category,
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
					attribute11,
					attribute12,
					attribute13,
					attribute14,
					attribute15,
					last_update_date,
					last_updated_by,
					last_update_login,
					created_by,
					creation_date)
			         values(psp_adjustment_lines_s.nextval,
					p_person_id,
					p_assignment_id,
					p_element_type_id,
					p_distribution_date,
					p_effective_date,
					p_distribution_amount,
					p_dr_cr_flag,
					p_payroll_control_id,
					'A',
					'Adjustments',
					p_time_period_id,
					p_batch_name,
					p_status_code,
					p_set_of_books_id,
					p_gl_code_combination_id,
					p_project_id,
					p_expenditure_organization_id,
					p_expenditure_type,
					p_task_id,
					p_award_id,
					null,
					null,
					null,
					null,
					null,
					p_reversal_entry_flag,
					p_original_line_flag,
					null,
					p_distribution_percent,
					p_orig_source_type,
					p_orig_line_id,
					p_business_group_id,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					sysdate,
					fnd_global.user_id,
					fnd_global.login_id,
					fnd_global.user_id,
					sysdate);
      p_return_status := fnd_api.g_ret_sts_success;

   EXCEPTION
      WHEN OTHERS THEN
         g_error_api_path := 'INSERT_ADJ_LINES:Batch Name '||p_batch_name||':'||g_error_api_path;
         p_return_status := fnd_api.g_ret_sts_unexp_error;

   end;
--------------------------------------------------------------------


----------P R O C E D U R E: INSERT_ADJUSTMENT_CONTROL -------------------------------
--
--
--  Purpose:   This procedure is called by procedure generate_lines described below.
--		   The purpose is to insert a new line in the psp_adjustment_control_table
--	         for the batch name created by the user in the distribution transfers
--		   form.
--
----------------------------------------------------------------------------------

procedure insert_adjustment_control(p_batch_name IN VARCHAR2,
						p_batch_comments IN VARCHAR2,
						p_return_status OUT NOCOPY VARCHAR2,
						p_gl_posting_override_date IN DATE DEFAULT NULL,
						-- Fixed 1087529
						p_person_id                IN NUMBER,
                                                p_assignment_id            IN NUMBER,
                                              --  p_element_type_id          IN NUMBER, commented for DA-ENH
                                                p_distribution_start_date  IN DATE,
                                                p_distribution_end_date    IN DATE,
                                                p_currency_code		   IN VARCHAR2,	-- Introduced for bug fix 2916848
						p_business_group_id 	   IN NUMBER,
						p_set_of_books_id	   IN NUMBER,
                                                p_adjust_by                IN VARCHAR2) is

begin

    insert into psp_adjustment_control_table(
					adjustment_batch_name,
					comments,
					gl_posting_override_date,
					last_update_date,
					last_updated_by,
					last_update_login,
					created_by,
					creation_date,
					person_id,
                                        assignment_id,
                                        ---element_type_id,  commented for DA-ENH
                                        distribution_start_date,
                                        distribution_end_date,
                                        currency_code,	-- Introduced for bug fix 2916848
					business_group_id,
					set_of_books_id,
                                        adjust_by) --- added for DA-ENH
					values(
					p_batch_name,
					p_batch_comments,
					p_gl_posting_override_date,
					sysdate,
					fnd_global.user_id,
					fnd_global.login_id,
					fnd_global.user_id,
					sysdate,
					p_person_id,
                                        p_assignment_id,
                                        --- p_element_type_id, commented for DA-ENH
                                        p_distribution_start_date,
                                        p_distribution_end_date,
                                        p_currency_code,	-- Introduced for bug fix 2916848
					p_business_group_id,
					p_set_of_books_id,
                                        p_adjust_by);    --- added for DA-ENH
     p_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
--************************************************************
   WHEN DUP_VAL_ON_INDEX THEN
      p_return_status := g_constraint_violation;
--************************************************************

   WHEN OTHERS THEN
      g_error_api_path := 'INSERT_ADJUSTMENT_CONTROL:Batch Name '||p_batch_name||':'||g_error_api_path;
      p_return_status := fnd_api.g_ret_sts_unexp_error;
end;
-----------------------------------------------------------------------


----------P R O C E D U R E: UPDATE_ADJUSTMENT_CONTROL -------------------------------
--
--
--  Purpose:   This procedure is called by the distributions transfers
--		   approval form after the approver submits the batch to the summarize
--		   and transfer concurrent process.  The purpose is to update
--		   the psp_adjustment_control_table with the approver id
--		   of the approver of the batch.
--
--
----------------------------------------------------------------------------------

procedure update_adjustment_ctrl_comment(errbuf  		OUT NOCOPY VARCHAR2,
                                         retcode 		OUT NOCOPY VARCHAR2,
			                 p_batch_name 		IN VARCHAR2,
                                         p_comments 		IN VARCHAR2)
IS

   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(2000);

begin
    g_error_api_path := '';
    fnd_msg_pub.initialize;
    errbuf := '';
    update psp_adjustment_control_table
    set comments      = p_comments,
        approver_id   = FND_GLOBAL.USER_ID,  -- 1087529
        approval_date = SYSDATE              -- Added to fix bug 1661405. approval_date is a new column added to the table
    where adjustment_batch_name = p_batch_name;

--Modified by Rashmi to update psp_payroll_control table.
    update psp_payroll_controls set status_code = 'N'
    where batch_name = p_batch_name  and source_type = 'A'
    and status_code = 'C';

    commit;
    retcode := 0;

EXCEPTION
WHEN OTHERS THEN
      g_error_api_path := 'UPDATE_ADJUSTMENT_CONTROL:'||g_error_api_path;
      fnd_msg_pub.get(p_msg_index     =>  FND_MSG_PUB.G_FIRST,
                      p_encoded       =>  FND_API.G_FALSE,
                      p_data          =>  l_msg_data,
                      p_msg_index_out =>  l_msg_count);
      errbuf := l_msg_data || fnd_global.local_chr(10) || g_error_api_path;
      retcode := 2;

end;
---------------------------------------------------------------------------------


----------P R O C E D U R E: UPDATE_PAYROLL_CONTROL -------------------------------
--
--
--  Purpose:   This procedure is called by procedure generate_lines described below.
--		   The purpose is to insert a record into psp_payroll_controls for
--		   every time_period_id that exists within the time frame of the
--		   adjusted lines for the batch.  The psp_adjustment_lines table is
--		   updated with the new payroll_control_id for the time_period_id.
--
----------------------------------------------------------------------------------

procedure update_payroll_control(p_batch_name 			IN VARCHAR2,
			         p_payroll_control_id 		IN NUMBER,
				 p_business_group_id		IN NUMBER,
				 p_set_of_books_id		IN NUMBER,
				 p_currency_code		IN VARCHAR2,	-- Introduced for bug fix 2916848
				 p_return_status 		OUT NOCOPY VARCHAR2,
				 p_gl_posting_override_date 	IN DATE DEFAULT NULL) is

l_payroll_control_id  NUMBER(10);
l_time_period_id      NUMBER(15);
l_tot_dr              NUMBER;
l_tot_cr              NUMBER;
l_payroll_id          NUMBER; /* Bug 1677534 */


cursor time_periods_c is
select distinct palh.time_period_id
from   psp_adjustment_lines palh
where  palh.batch_name = p_batch_name
and    palh.business_group_id = p_business_group_id
and    palh.set_of_books_id   = p_set_of_books_id;


/*********************************************
For Bug 2252881 : Modifying the Cusor tot_dr_c to include tot_cr_c conitions also
 and to be able to select both teh DR amount and cr amount
cursor tot_dr_c is
select sum(distribution_amount)
from   psp_adjustment_lines
where  batch_name = p_batch_name
and    time_period_id = l_time_period_id
and    dr_cr_flag = 'D'
and    business_group_id = p_business_group_id
and    set_of_books_id   = p_set_of_books_id
group by batch_name, time_period_id, dr_cr_flag;

cursor tot_cr_c is
select sum(distribution_amount)
from   psp_adjustment_lines
where  batch_name = p_batch_name
and    time_period_id = l_time_period_id
and    dr_cr_flag = 'C'
and    business_group_id = p_business_group_id
and    set_of_books_id   = p_set_of_books_id
group by batch_name, time_period_id, dr_cr_flag;
*******************************************/
CURSOR tot_dr_c
IS
SELECT SUM(DECODE(pal.dr_cr_flag,'D',pal.distribution_amount,0)) l_total_dr,
       SUM(DECODE(pal.dr_cr_flag,'C',pal.distribution_amount,0)) l_total_cr
FROM   psp_adjustment_lines pal
WHERE  pal.batch_name 		= p_batch_name
and    pal.time_period_id 	= l_time_period_id;

/* Bug 1677534 */
cursor get_payroll_id is
select payroll_id
from per_time_periods
where time_period_id = l_time_period_id;

begin

	open time_periods_c;
      fetch time_periods_c into l_time_period_id;
      if time_periods_c%NOTFOUND then
         close time_periods_c;
	   g_error_api_path := 'Error opening cursor time_periods_c: '||g_error_api_path;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;


      open tot_dr_c;
      fetch tot_dr_c into l_tot_dr,l_tot_cr;
    --  if tot_dr_c%NOTFOUND then --Commented for bug 2252881
         close tot_dr_c;
/*****************************
Commented for Bug 2252881 : Both the credit and debit amount are being selected in the cursor tot_dr_c
         l_tot_dr := 0;
      else
         close tot_dr_c;
      end if;

      open tot_cr_c;
      fetch tot_cr_c into l_tot_cr;
      if tot_cr_c%NOTFOUND then
         close tot_cr_c;
         l_tot_cr := 0;
      else
         close tot_cr_c;
      end if;
******************************/

/* Bug 1677534 */
open get_payroll_id;
fetch get_payroll_id into l_payroll_id;
close get_payroll_id;

--Modified the code by Rashmi to assign status = 'C' (for Creation).

      insert into psp_payroll_controls(
					payroll_control_id,
					payroll_action_id,
					payroll_source_code,
					source_type,
					payroll_id,
					time_period_id,
					batch_name,
					dist_dr_amount,
					dist_cr_amount,
					status_code,
					last_update_date,
					last_updated_by,
					last_update_login,
					created_by,
					creation_date,
					run_id,
					GL_POSTING_OVERRIDE_DATE,
                                        GMS_POSTING_OVERRIDE_DATE,
					business_group_id,
					set_of_books_id,
--	Introduced for bug fix 2916848
					currency_code,
					exchange_rate_type)
					values(
					p_payroll_control_id,
					1,
					'Adjustments',
					'A',
					l_payroll_id,    /* 1,  --Bug 1677534 */
					l_time_period_id,
					p_batch_name,
					l_tot_dr,
					l_tot_cr,
					'C',
					sysdate,
					fnd_global.user_id,
					fnd_global.login_id,
					fnd_global.user_id,
					sysdate,
					null,
					p_gl_posting_override_date,
					null,
					p_business_group_id,
					p_set_of_books_id,
--	Introduced for bug fix 2916848
					p_currency_code,
					null);

       loop
       fetch time_periods_c into l_time_period_id;
       if time_periods_c%NOTFOUND then
          close time_periods_c;
          exit;
       end if;

	 open tot_dr_c;
       fetch tot_dr_c into l_tot_dr,l_tot_cr;
      --if tot_dr_c%NOTFOUND then : Commented for bug 2252881
         close tot_dr_c;
/******************************************
For Bug 2252881 : Commented as the Total Credit and Debit amount is obtained from the cursor tot_dr_c
         l_tot_dr := 0;
       else
         close tot_dr_c;
       end if;

       open tot_cr_c;
       fetch tot_cr_c into l_tot_cr;
       if tot_cr_c%NOTFOUND then
         close tot_cr_c;
         l_tot_cr := 0;
       else
         close tot_cr_c;
       end if;
       **********************************************/

/* Bug 1677534 */
open get_payroll_id;
fetch get_payroll_id into l_payroll_id;
close get_payroll_id;

--Modified the code by Rashmi to assign status = 'C' (for Creation).

       select psp_payroll_controls_s.nextval into l_payroll_control_id from dual;
       insert into psp_payroll_controls(
					payroll_control_id,
					payroll_action_id,
					payroll_source_code,
					source_type,
					payroll_id,
					time_period_id,
					batch_name,
					dist_dr_amount,
					dist_cr_amount,
					status_code,
					last_update_date,
					last_updated_by,
					last_update_login,
					created_by,
					creation_date,
					run_id,
					GL_POSTING_OVERRIDE_DATE,
                                        GMS_POSTING_OVERRIDE_DATE,
					business_group_id,
					set_of_books_id,
--	Introduced for bug fix 2916848
					currency_code,
					exchange_rate_type)
					values(
					l_payroll_control_id,
					1,
					'Adjustments',
					'A',
					l_payroll_id,    /* 1,  --Bug 1677534 */
					l_time_period_id,
					p_batch_name,
					l_tot_dr,
					l_tot_cr,
					'C',
					sysdate,
					fnd_global.user_id,
					fnd_global.login_id,
					fnd_global.user_id,
					sysdate,
					null,
					p_gl_posting_override_date,
					null,
					p_business_group_id,
					p_set_of_books_id,
--	Introduced for bug fix 2916848
					p_currency_code,
					null);

       update psp_adjustment_lines
	 set payroll_control_id = l_payroll_control_id
       where time_period_id = l_time_period_id
       and batch_name = p_batch_name
       and business_group_id = p_business_group_id
	and set_of_books_id = p_set_of_books_id;
       IF SQL%NOTFOUND THEN
         close time_periods_c;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	end loop;

   p_return_status := fnd_api.g_ret_sts_success;

   EXCEPTION
      WHEN OTHERS THEN
         g_error_api_path := 'UPDATE_PAYROLL_CONTROL:Batch Name '||p_batch_name||':'||g_error_api_path;
         p_return_status := fnd_api.g_ret_sts_unexp_error;
end;
--------------------------------------------------------------------------------


----------P R O C E D U R E: UPDATE_EFFORT_REPORTS -------------------------------
--
--
--  Purpose:   This procedure is called by procedure generate_lines described below.
--		   The purpose is to update the table psp_effort_reports with a
--		   status code of 'S' for superceded for those effort reports with
--		   distribution lines that have beenadjusted.
--
----------------------------------------------------------------------------------

procedure update_effort_reports(p_batch_name 		IN VARCHAR2,
				p_business_group_id	IN	NUMBER,
				p_set_of_books_id	IN 	NUMBER,
			        p_return_status 	OUT NOCOPY VARCHAR2) is
/***	Commented the following for bug fix 2724110
l_per_id      NUMBER(9);
l_dist_date   DATE;
l_template_id NUMBER(9);
l_begin_date  DATE;
l_end_date    DATE;

-- Modified for bug 1886429,added one more condition in cursor
-- to filter the person_id on the basis of effort report element_type_id
-- on 24-Jul-2001,by ddubey.


cursor adj_effort_c is
select distinct person_id, distribution_date
from   psp_adjustment_lines
where  batch_name = p_batch_name
and    business_group_id = p_business_group_id
and    set_of_books_id   = p_set_of_books_id
and    element_type_id in (select element_type_id from psp_effort_report_elements
                           where use_in_effort_report='Y');

/ *****************************************************************
Commenting the following cursor for Bug fix :2252881:

cursor effort_reports_c(p_per_id IN NUMBER) is
select template_id
from   psp_effort_reports
where  person_id = p_per_id;
***************************************************************
** Fixed Bug 1021852
***************************************************************
cursor effort_reports_c(p_per_id IN NUMBER) is
select per.template_id
from   psp_effort_reports per
where  per.person_id = p_per_id
and    per.business_group_id = p_business_group_id
and    per.set_of_books_id   = p_set_of_books_id
and    per.template_id in (select pert.template_id
                           from psp_effort_report_templates pert
                           where pert.report_type = 'N'
                          --  and   pert.person_id = p_per_id
			   and   pert.business_group_id = p_business_group_id
			   and   pert.set_of_books_id   = p_set_of_books_id);

cursor effort_templates_c(p_template_id IN NUMBER) is
select begin_date, end_date
from   psp_effort_report_templates
where  template_id = p_template_id and
       report_type='N'
 and   business_group_id = p_business_group_id
 and   set_of_books_id   = p_set_of_books_id;
************************************************************End of comment for bug 2252881 * /

/ * Following cursor is modified for bug 2252881 * /
CURSOR effort_reports_c(p_per_id NUMBER)
IS
SELECT  pert.template_id, pert.begin_date, pert.end_date
FROM	psp_effort_report_templates pert
WHERE   pert.report_type ='N'
AND	pert.template_id IN(
			SELECT  per.template_id
			FROM	psp_effort_reports per
			WHERE	per.person_id = p_per_id
			AND	per.business_group_id = p_business_group_id
			AND	per.set_of_books_id   = p_set_of_books_id
			);
	End of comment for bug fix 2724110	***/
begin
/***	Commented for bug fix 2724110
	open adj_effort_c; loop
        fetch adj_effort_c into l_per_id,
		       		  l_dist_date;
        if adj_effort_c%NOTFOUND then
           close adj_effort_c;
           exit;
        end if;

        open effort_reports_c(l_per_id); loop
          fetch effort_reports_c into l_template_id,l_begin_date,l_end_date;
          if effort_reports_c%NOTFOUND then
             close effort_reports_c;
	       exit;
          end if;
   / **********************
	  Commented as the begin and end date has been obtained from the effort_reports_c : For bug 2252881
          open effort_templates_c(l_template_id);
          fetch effort_templates_c into l_begin_date,
						    l_end_date;
          if effort_templates_c%NOTFOUND then
             close effort_templates_c;
             g_error_api_path := 'Error opening cursor effort_templates_c: '||g_error_api_path;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    end if;
  ******************************************* /

          if l_dist_date between l_begin_date and l_end_date then
             / *************************************************************************** /
             / *04/27/99 Shu Lei Distribution Adjustment Enhanced Workflow               * /
             / *                 Record the status code in previous_status_code before   * /
             / *                 updating status_code to "S".                            * /
             / *************************************************************************** /
	     UPDATE psp_effort_reports
             SET    previous_status_code = status_code
             WHERE  person_id = l_per_id
             AND    template_id = l_template_id;

             update psp_effort_reports
             set status_code = 'S'
             where person_id = l_per_id
             and template_id = l_template_id;
          end if;
          --close effort_templates_c; :For bug 2252881


        end loop;  / * effort_reports_c * /
      end loop;    / * adj_effort_c * /
	end of comment for bug fix 2724110	***/

--	Introduced the following for bug fix 2724110
	UPDATE	psp_effort_reports per
	SET	per.previous_status_code = per.status_code,
		per.status_code = 'S'
	WHERE	per.status_code <> 'S'
	AND	per.business_group_id = p_business_group_id
	AND	per.set_of_books_id = p_set_of_books_id
	AND	(per.person_id, per.template_id) IN
			(SELECT	pal.person_id, pert.template_id
			FROM	psp_effort_report_templates pert,
				psp_effort_reports per2,
				psp_adjustment_lines pal
			WHERE	pal.batch_name = p_batch_name
			AND	pal.business_group_id = p_business_group_id
			AND	pal.set_of_books_id = p_set_of_books_id
			AND	pert.business_group_id = p_business_group_id
			AND	pert.set_of_books_id = p_set_of_books_id
			AND	pert.template_id = per2.template_id
			AND	pert.report_type = 'N'
			AND	per2.person_id = pal.person_id
			AND	pal.distribution_date BETWEEN pert.begin_date
			AND	pert.end_date
			AND	pal.element_type_id IN
					(SELECT	pere.element_type_id
					FROM	psp_effort_report_elements pere
					WHERE	pere.use_in_effort_report = 'Y'));
--	End of bug fix 2724110
   p_return_status := fnd_api.g_ret_sts_success;

   EXCEPTION
      WHEN OTHERS THEN
         g_error_api_path := 'UPDATE_EFFORT_REPORTS:Batch Name '||p_batch_name||':'||g_error_api_path;
         p_return_status := fnd_api.g_ret_sts_unexp_error;
end;
--------------------------------------------------------------------------------



----------P R O C E D U R E: GENERATE_LINES -------------------------------
--
--
--  Purpose:   This procedure is called by the submit process of the distribution
--		   transfers form.  The purpose is to create reversal lines and new
--	         adjusted lines from the distribution amounts/percents specified
--	         by the user in the adjusted lines block of distribution transfers
--		   form.
--		   Reversal lines are generated first, and then new adjusted lines
--	         are created. A call is made to insert_adj_lines to insert
--		   the lines in psp_adjustment_lines table.
--
--
----------------------------------------------------------------------------------

procedure generate_lines(errbuf  			OUT NOCOPY VARCHAR2,
                         retcode 			OUT NOCOPY VARCHAR2,
                         p_person_id       		IN NUMBER,
                         p_assignment_id   		IN NUMBER,
                         --p_element_type_id 		IN NUMBER, commented for DA-ENH
                         p_batch_name      		IN VARCHAR2,
			 p_batch_comments  		IN VARCHAR2,
                         p_run_id          		IN NUMBER,
			 p_gl_posting_override_date 	IN DATE ,
			 p_distribution_start_date      IN DATE,
                         p_distribution_end_date        IN DATE,
			 p_business_group_id		IN NUMBER,
			 p_set_of_books_id		IN NUMBER,
			 p_employee_full_name		IN VARCHAR2,
			 p_assignment_number		IN VARCHAR2,
			 ---p_earnings_element		IN VARCHAR2, commented for DA-ENH
			 p_time_out			IN NUMBER,
                         p_adjust_by                    IN VARCHAR2,
--	Introduced for bug fix 2916848
                         p_currency_code                IN VARCHAR2,
-- Introduced the following parameters for Bug 3548388
			 p_defer_autopop_param          IN VARCHAR2,
                         p_begin_date                   IN DATE,
                         p_adjustment_line_id           OUT NOCOPY NUMBER,
                         p_element_status               OUT NOCOPY VARCHAR2)
IS

   l_return_status                    VARCHAR2(1);
   l_msg_count                        NUMBER;
   l_msg_data                         VARCHAR2(2000);
   l_wf_ret_status		      NUMBER;
   l_payroll_control_id               integer;

   /* Introduced the Following variables for Bug 3548388 */

   l_gl_code_combination_id 	NUMBER;
   l_expenditure_type 		VARCHAR2(30);
   l_dummy_var 			NUMBER(10);
   l_ret_code 			VARCHAR2(1);

   l_patc_status 		VARCHAR2(50);
   l_billable_flag 		VARCHAR2(1);
   l_msg_app			VARCHAR2(2000);
   l_msg_type			VARCHAR2(2000);
   l_msg_token1			VARCHAR2(2000);
   l_msg_token2			VARCHAR2(2000);
   l_msg_token3			VARCHAR2(2000);
   l_award_status		VARCHAR2(2000);

   l_chart_of_accts	 	VARCHAR2(20);
   l_struc_num 		        NUMBER;		-- :=psp_general.find_chart_of_accts(p_set_of_books_id,l_chart_of_accts); commented for bug fix 3892097
   l_segs		 	VARCHAR2(2000);

   Inv_autopop_element  	Exception;
   Invalid_ptoe      		Exception;
   Invalid_ptoea    		Exception;
   Invalid_gl			Exception;

 -- to be removed
   p_element_name 		varchar2(30);



   /* End of Bug 3548388 */



   no_records_found  EXCEPTION;
   workflow_failed   EXCEPTION;  -- Added for workflow
   counter        NUMBER;

   e_constraint_violation EXCEPTION;

   --- ADDED following two cursors to check batch integrity .... for DA-ENH
   ---- Element wise net must be zero for the batch

  l_element_name varchar2(80);
  l_element_type_id number;
  l_integrity_count integer;

   cursor check_batch_integrity(p_batch_name varchar2) is
   select count(*), element_type_id
   from psp_adjustment_lines
   where batch_name = p_batch_name
   group by element_type_id
   having sum(decode(dr_cr_flag,'D',distribution_amount,-distribution_amount)) <> 0;

  cursor get_element_name is
  select element_name
  from pay_element_types
  where element_type_id = l_element_type_id;

  batch_net_not_zero exception;
   ----------- DA-ENH


  /* Added following cursor and PL/SQL tables to improve performance  for DA-ENH */
  cursor adj_matrix is
  select PTDS.adj_set_number,
           PTOS.element_type_id,
           PTOS.time_period_id,
           Sum(decode (PTOS.dr_cr_flag, 'D',  PTOS.distribution_amount,
                                             -PTOS.distribution_amount))
  from psp_temp_dest_sumlines PTDS,
       psp_temp_orig_lines PTOS
  where PTDS.original_line_flag = 'Y'
     and PTDS.acct_group_id = PTOS.acct_group_id
     and PTDS.run_id = g_run_id
     and PTOS.run_id = g_run_id
  group by PTDS.adj_set_number,
           PTOS.element_type_id,
           PTOS.time_period_id;

  cursor sline_ideal_amnt_matrix is
  select adj_set_number,
           time_period_id,
           element_type_id,
           line_number,
           sum(decode(dr_cr_flag, 'D', round(distribution_amount, g_precision),
                                      -round(distribution_amount, g_precision))),   --|>actual amnt
           round(sum(decode(dr_cr_flag, 'D', distribution_amount,
                                            -distribution_amount)) -
                 sum(decode(dr_cr_flag, 'D',round(distribution_amount, g_precision),      --|>delta amnt =
                                           -round(distribution_amount, g_precision))), g_precision), --  unrounded amnt - act amnt
           max(adjustment_line_id)
   from psp_adjustment_lines
   where batch_name = p_batch_name and
       original_line_flag = 'N'
   group by adj_set_number, time_period_id, element_type_id, line_number;

  cursor sline_actual_amnt_matrix is
  select adj_set_number,
           element_type_id,
           time_period_id,
           sum(decode(dr_cr_flag, 'D', distribution_amount,
                                      -distribution_amount)),
           max(adjustment_line_id),
           0                                   --- delta sum
  from psp_adjustment_lines
  where original_line_flag = 'N' and
      batch_name = p_batch_name
  group by adj_set_number, element_type_id, time_period_id;


 TYPE t_num_15_type      IS TABLE OF NUMBER(15)          INDEX BY BINARY_INTEGER;
 TYPE t_num_type         IS TABLE OF NUMBER              INDEX BY BINARY_INTEGER;
--	Changed the datatype from (15, 2) to 30 for bug fix 2916848
 TYPE t_number_type    IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;

 type ideal_amnt_matrix_rec is record
 (adj_set_number   t_num_15_type,
  time_period_id   t_num_15_type,
  element_type_id  t_num_15_type,
  sline_number     t_num_15_type,   -- calling sline becos of grouping
  distribution_sum t_number_type,	-- Corrected column type defn for bug fix 2916848
  delta_sum        t_number_type,	-- Corrected column type defn for bug fix 2916848
  adjustment_sline_id t_num_15_type);

  r_sline_ideal_amnt_matrix ideal_amnt_matrix_rec;

  type adj_matrix_rec is record
  (adj_set_number t_num_15_type,
   time_period_id t_num_15_type,
   element_type_id t_num_15_type,
   distribution_sum t_number_type);	-- Corrected column type defn for bug fix 2916848

  r_adj_matrix adj_matrix_rec;

  type actual_amnt_matrix is record
   (adj_set_number t_num_15_type,
    time_period_id t_num_15_type,
    element_type_id t_num_15_type,
    distribution_sum t_number_type,	-- Corrected column type defn for bug fix 2916848
    adjustment_sline_id t_num_15_type,
    delta_sum        t_number_type);	-- Corrected column type defn for bug fix 2916848

   r_sline_actual_amnt_matrix actual_amnt_matrix;

  --- added for bug fix 3470916
  --- this cursor is to get difference amounts from the RHS amounts and
  --- the generated new adjustment lines.
  cursor get_dest_diff is
  select sum(decode(LINE.dr_cr_flag,'D',LINE.distribution_amount,
                                -LINE.distribution_amount)) amount,
         DEST.distribution_sum,
         LINE.adj_set_number,
         LINE.line_number
    from psp_adjustment_lines   LINE,
         psp_temp_dest_sumlines DEST
   where LINE.batch_name = p_batch_name and
         LINE.original_line_flag = 'N' and
         DEST.run_id = p_run_id and
         DEST.original_line_flag = 'N' and
         DEST.adj_set_number = LINE.adj_set_number and
         DEST.line_number = LINE.line_number
   group by LINE.adj_set_number, LINE.line_number, DEST.distribution_sum;

   r_dest_diff get_dest_diff%rowtype;
   --- 3776353  removed max on eleement type, time period, added asc
   cursor get_max_element(p_adj_set_number in integer,
                          p_adj_line_number in integer) is
   select element_type_id,
          time_period_id
   from psp_adjustment_lines
   where batch_name = p_batch_name
     and original_line_flag = 'N'
     and adj_set_number = p_adj_set_number
     and line_number = p_adj_line_number
    order by element_type_id, time_period_id desc;

   r_element_tp get_max_element%rowtype;
   l_prev_adj_set number :=null;


/* Start of Changes for Supercencebased on migration to new OAf Effort Reporting */


   l_migration_status BOOLEAN:= psp_general.is_effort_report_migrated;


/* End of Changes for Supercencebased on migration to new OAf Effort Reporting */



   /* Introduced the following for Bug 3548388 */

   TYPE t_varchar_30_type  IS TABLE OF VARCHAR2(30)        INDEX BY BINARY_INTEGER;
   TYPE t_varchar_1_type   IS TABLE OF VARCHAR2(1)         INDEX BY BINARY_INTEGER;
   TYPE t_date_type        IS TABLE OF DATE                INDEX BY BINARY_INTEGER;

   type deferred_autopop_array is record
 ( array_element_type_id     t_number_type,
   array_glccid              t_num_15_type,
   array_project_id          t_num_15_type,
   array_exp_org_id          t_num_15_type,
   array_exp_type            t_varchar_30_type,
   array_task_id             t_num_15_type,
   array_award_id            t_num_15_type
   );



  deferred_autopop_rec    deferred_autopop_array;
  final_autopop_rec     deferred_autopop_array;
  l_count  number :=0;



 cursor autopop_defer_cur
 is
 select element_type_id,
	gl_code_combination_id,
	project_id,
	expenditure_organization_id,
	expenditure_type,
	task_id,
	award_id
 from   psp_adjustment_lines
 where  batch_name = p_batch_name
 and    original_line_flag <> 'Y'
 and    set_of_books_id = p_set_of_books_id
 and    business_group_id = p_business_group_id
 Group by  element_type_id,
	   gl_code_combination_id,
           project_id,
           expenditure_organization_id,
           expenditure_type,
           task_id,
           award_id ;


 /*  cursor to check the list of distinct effective dates  for element type id and  poeta  combination */

 cursor  pa_check_effectivedate (p_element_type_id  NUMBER,
				 p_project_id  NUMBER,
                             	 p_task_id  NUMBER,
				 p_award_id  NUMBER,
                                 p_expenditure_organization_id  NUMBER,
                           	 p_expenditure_type  VARCHAR2)
 is
 select  effective_date ,
	 adjustment_line_id
 from    psp_adjustment_lines
 where   element_type_id = p_element_type_id
 and	 project_id = p_project_id
 and 	 expenditure_organization_id = p_expenditure_organization_id
 and	 expenditure_type = p_expenditure_type
 and	 task_id = p_task_id
 and     award_id = p_award_id
 and     business_group_id = p_business_group_id
 and     set_of_books_id = p_set_of_books_id
 and     batch_name = p_batch_name
 and     original_line_flag <> 'Y'
 group  by  effective_date,
	    adjustment_line_id;


  type  l_effective_date  is table of  psp_adjustment_lines.effective_date%type INDEX BY BINARY_INTEGER;
  type  l_adj_line_id is table of psp_adjustment_lines.adjustment_line_id%type INDEX BY BINARY_INTEGER;
  type effective_date_rec is record
  (r_effective_date     l_effective_date,
   r_adj_line_id        l_adj_line_id);

 effective_date_array  effective_date_rec ;




  /* End of bug 3548388 */

 -- Introduced for Bug fix 3741272

CURSOR l_exp_org_csr(p_eff_date date, p_exp_org_id Number)
IS
SELECT 'x'
FROM psp_organizations_expend_v
WHERE organization_id = p_exp_org_id
and trunc(p_eff_date) between date_from and nvl(date_to,trunc(p_eff_date));

l_dummy  VARCHAR2(1);

-- End of changes for Bug fix 3741272

TYPE t_number_15_type	IS TABLE OF NUMBER(15)	INDEX BY BINARY_INTEGER;
TYPE t_char_1_type	IS TABLE OF CHAR(1)	INDEX BY BINARY_INTEGER;

TYPE orig_line_rec is record
	(orig_line_id		t_number_15_type,
	orig_source_type	t_char_1_type);
r_orig_lines	orig_line_rec;

CURSOR	orig_line_id_cur IS
SELECT	orig_line_id,
	orig_source_type
FROM	psp_adjustment_lines
WHERE	payroll_control_id = l_payroll_control_id;

-- Bug 6634876
CURSOR  net_batch_sum_cur IS
SELECT  sum(decode(dr_cr_flag,'D',distribution_amount,-distribution_amount)) amount
FROM    psp_adjustment_lines
WHERE   batch_name = p_batch_name;

r_net_zero_diff   net_batch_sum_cur%rowtype;

begin

      hr_utility.trace('**************************************************');
      hr_utility.trace('LD Debugging Starts');
      hr_utility.trace('Entering GENERATE_LINES procedure');

      hr_utility.trace('Procedure IN Parameters Starts ');

      hr_utility.trace('p_person_id = '||p_person_id);
      hr_utility.trace('p_assignment_id = '||p_assignment_id);
      hr_utility.trace('p_batch_name = '||p_batch_name);
      hr_utility.trace('p_batch_comments = '||p_batch_comments);
      hr_utility.trace('p_run_id = '||p_run_id);
      hr_utility.trace('p_gl_posting_override_date = '||p_gl_posting_override_date);
      hr_utility.trace('p_distribution_start_date = '||p_distribution_start_date);
      hr_utility.trace('p_distribution_end_date = '||p_distribution_end_date);
      hr_utility.trace('p_business_group_id = '||p_business_group_id);
      hr_utility.trace('p_set_of_books_id = '||p_set_of_books_id);
      hr_utility.trace('p_employee_full_name = '||p_employee_full_name);
      hr_utility.trace('p_assignment_number = '||p_assignment_number);
      hr_utility.trace('p_time_out = '||p_time_out);
      hr_utility.trace('p_adjust_by = '||p_adjust_by);
      hr_utility.trace('p_currency_code = '||p_currency_code);
      hr_utility.trace('p_defer_autopop_param = '||p_defer_autopop_param);
      hr_utility.trace('p_begin_date = '||p_begin_date);

      hr_utility.trace('Procedure IN Parameters Ends ');

      g_error_api_path := '';
      fnd_msg_pub.initialize;
      errbuf := '';
      retcode := 0;
      counter := 1;

	l_struc_num := psp_general.find_chart_of_accts(p_set_of_books_id,l_chart_of_accts);

      select psp_payroll_controls_s.nextval into l_payroll_control_id from dual;

      hr_utility.trace('l_payroll_control_id = '||l_payroll_control_id);
      hr_utility.trace('Inserting into PSP_ADJUSTMENT_CONTROL_TABLE : batch = '||p_batch_name);

     insert_adjustment_control(p_batch_name,
			       p_batch_comments,
			       l_return_status,
			       p_gl_posting_override_date,
                               p_person_id,
                               p_assignment_id,
                                ---p_element_type_id, replaced with NULL for DA-ENH
                               p_distribution_start_date,
                               p_distribution_end_date,
				p_currency_code,	-- Introduced for bug fix 2916848
			       p_business_group_id,
			       p_set_of_books_id,
                               p_adjust_by); --- added param for DA-ENH

     IF l_return_status = g_constraint_violation THEN
        RAISE e_constraint_violation;
     ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   --Reversal Lines Generation

   hr_utility.trace('Inserting into PSP_ADJUSTMENT_LINES - 10');

     insert into psp_adjustment_lines(adjustment_line_id,
			person_id,
			assignment_id,
			element_type_id,
			distribution_date,
			effective_date,
			distribution_amount,
			dr_cr_flag,
			payroll_control_id,
			source_type,
			source_code,
			time_period_id,
			batch_name,
			status_code,
			set_of_books_id,
			gl_code_combination_id,
			project_id,
			expenditure_organization_id,
			expenditure_type,
			task_id,
			award_id,
			reversal_entry_flag,
			original_line_flag,
			user_defined_field,
			percent,
			orig_source_type,
			orig_line_id,
			business_group_id,
                        adj_set_number,   --- new column for DA-ENH
			last_update_date,
			last_updated_by,
			last_update_login,
			created_by,
			creation_date,
                        line_number, --- new column for DA-ENH
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
			attribute10)
  select psp_adjustment_lines_s.nextval,
     p_person_id,
     p_assignment_id,
     ptol.element_type_id,
     ptol.orig_distribution_date,
      ptol.effective_date,
     ptol.distribution_amount,
     decode(ptol.dr_cr_flag,'D','C','D'),  -- reverse the dr_cr_flag
     l_payroll_control_id,
     'A',
      'Adjustments',
      ptol.time_period_id,
       p_batch_name,
       'N',
        p_set_of_books_id,
      ptds.gl_code_combination_id,
      ptds.project_id,
      ptds.expenditure_organization_id,
      ptds.expenditure_type,
      ptds.task_id, ptds.award_id,
       null, -- reversal entry flag.
       'Y',    -- original line flag
       null,
      ptds.distribution_percent,
      ptol.orig_source_type,
      ptol.orig_line_id,
      p_business_group_id,
      ptds.adj_set_number,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id,
      fnd_global.user_id,
      sysdate,
      ptds.line_number,
	ptds.attribute_category,			-- Introduced DFF columns for bug fix 2908859
	ptds.attribute1,
	ptds.attribute2,
	ptds.attribute3,
	ptds.attribute4,
	ptds.attribute5,
	ptds.attribute6,
	ptds.attribute7,
	ptds.attribute8,
	ptds.attribute9,
	ptds.attribute10
     from   psp_temp_orig_lines ptol, psp_temp_dest_sumlines ptds
     where  ptol.business_group_id = p_business_group_id
     and    ptol.set_of_books_id = p_set_of_books_id
     and    ptol.business_group_id = ptds.business_group_id
     and    ptol.set_of_books_id = ptds.set_of_books_id
     and    ptol.acct_group_id = ptds.acct_group_id
     and    ptds.original_line_flag = 'Y'
     and    ptol.run_id = p_run_id
     and    ptds.run_id = ptol.run_id;

        if  sql%rowcount = 0 then
           g_error_api_path := 'No records found in reversal lines:'||g_error_api_path;
           raise NO_RECORDS_FOUND;
         end if;

  hr_utility.trace('Inserted into PSP_ADJUSTMENT_LINES - 10');

/*****	Converted the following update statements into BULK update for R12 performance fixes (bug 4507892)
  UPDATE psp_distribution_lines_history
  SET 	adjustment_batch_name = p_batch_name
  WHERE	distribution_line_id  in ( select  orig_line_id
                                   from psp_adjustment_lines
                                   where payroll_control_id = l_payroll_control_id
                                   and orig_source_type = 'D');

   UPDATE psp_pre_gen_dist_lines_history
   SET    adjustment_batch_name = p_batch_name
   WHERE  pre_gen_dist_line_id in ( select  orig_line_id
                                    from psp_adjustment_lines
                                    where payroll_control_id = l_payroll_control_id
                                    and orig_source_type = 'P');


   UPDATE  psp_adjustment_lines_history
   SET     adjustment_batch_name = p_batch_name
   WHERE   adjustment_line_id in ( select  orig_line_id
                                   from psp_adjustment_lines
                                   where payroll_control_id = l_payroll_control_id
                                     and orig_source_type = 'A');
     ---end of code changes for reversal line generation DA-ENH
	End of comment for bug fix 4507892	*****/

--	Introduced the following for bug fix 4507892

	hr_utility.trace('Calling ORIG_LINE_ID_CUR cursor');
	OPEN orig_line_id_cur;
	FETCH orig_line_id_cur BULK COLLECT INTO r_orig_lines.orig_line_id, r_orig_lines.orig_source_type;
	CLOSE orig_line_id_cur;

	hr_utility.trace('r_orig_lines.orig_line_id.COUNT = '||r_orig_lines.orig_line_id.COUNT);

	FORALL I IN 1..r_orig_lines.orig_line_id.COUNT
	UPDATE	psp_distribution_lines_history
	SET	adjustment_batch_name = p_batch_name
	WHERE	distribution_line_id = r_orig_lines.orig_line_id(I)
	AND	r_orig_lines.orig_source_type(I) = 'D';

	FORALL I IN 1..r_orig_lines.orig_line_id.COUNT
	UPDATE	psp_pre_gen_dist_lines_history
	SET	adjustment_batch_name = p_batch_name
	WHERE	pre_gen_dist_line_id = r_orig_lines.orig_line_id(I)
	AND	r_orig_lines.orig_source_type(I) = 'P';

	FORALL I IN 1..r_orig_lines.orig_line_id.COUNT
	UPDATE	psp_adjustment_lines_history
	SET	adjustment_batch_name = p_batch_name
	WHERE	adjustment_line_id = r_orig_lines.orig_line_id(I)
	AND	r_orig_lines.orig_source_type(I) = 'A';

	r_orig_lines.orig_line_id.DELETE;
	r_orig_lines.orig_source_type.DELETE;
--	End of changes for bug fix 4507892

	hr_utility.trace('Completed BULK updates');

     ----- Insert statement to generate new adj lines.
     hr_utility.trace('Inserting into PSP_ADJUSTMENT_LINES - 20');

     insert into psp_adjustment_lines
              (adjustment_line_id,
			person_id,
			assignment_id,
			element_type_id,
			distribution_date,
			effective_date,
			distribution_amount,
			dr_cr_flag,
			payroll_control_id,
			source_type,
			source_code,
			time_period_id,
			batch_name,
			status_code,
			set_of_books_id,
			gl_code_combination_id,
			project_id,
			expenditure_organization_id,
			expenditure_type,
			task_id,
			award_id,
			reversal_entry_flag,
			original_line_flag,
			user_defined_field,
			percent,
			orig_source_type,
			orig_line_id,
			business_group_id,
                        adj_set_number,   --- new column for DA-ENH
			last_update_date,
			last_updated_by,
			last_update_login,
			created_by,
			creation_date,
                        line_number,
			attribute_category,		-- Introduced DFF columns for bug fix 2908859
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10) --- new column for DA-ENH
   select psp_adjustment_lines_s.nextval,
          p_person_id,
          p_assignment_id,
          LINES.element_type_id,
          LINES.orig_distribution_date,
--           LINES.effective_date,			Commented for bug fix 3927570
--	Introduced the following for bug fix 3892097
          fnd_date.canonical_to_date(DECODE(trans_type.transaction_type_count,
		1, fnd_date.date_to_canonical(LINES.effective_date),
		DECODE(dest.gl_code_combination_id,
			NULL, fnd_date.date_to_canonical(lines.orig_distribution_date),
			fnd_date.date_to_canonical(ptp.end_date)))) effective_date,
--	End of changes for bug fix 3927570
          LINES.distribution_amount * DEST.distribution_percent/100, ------- unrounded, unlimited precision DA_ENH
          LINES.dr_cr_flag,
          l_payroll_control_id,
          'A',
           'Adjustments',
           LINES.time_period_id,
            p_batch_name,
            'N',
             p_set_of_books_id,
           DEST.gl_code_combination_id,
           DEST.project_id,
           DEST.expenditure_organization_id,
           DEST.expenditure_type,
           DEST.task_id,
            DEST.award_id,
            null, -- reversal entry flag.
            'N',    -- original line flag
            null,
           DEST.distribution_percent,
          LINES.orig_source_type,
           LINES.orig_line_id,
           p_business_group_id,
           DEST.adj_set_number,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id,
           fnd_global.user_id,
           sysdate,
           DEST.line_number,
	dest.attribute_category,		--Introduced DFF columns for bug fix 2908859
	dest.attribute1,
	dest.attribute2,
	dest.attribute3,
	dest.attribute4,
	dest.attribute5,
	dest.attribute6,
	dest.attribute7,
	dest.attribute8,
	dest.attribute9,
	dest.attribute10
     from psp_temp_dest_sumlines ORIG,
         psp_temp_dest_sumlines  DEST,
         psp_temp_orig_lines  LINES,
--	Introduced the following for bug fix 3892097
		per_time_periods ptp,
		(SELECT	adj_set_number,
			COUNT(DISTINCT DECODE(gl_code_combination_id, NULL, 'P', 'G')) transaction_type_count
		FROM	psp_temp_dest_sumlines ptds
		WHERE	ptds.run_id = g_run_id
		GROUP BY adj_set_number) trans_type
--	End of changes for bug fix 3892097
     where ORIG.run_id = g_run_id and
            DEST.run_id = g_run_id and
            LINES.run_id = g_run_id and
--	Introduced the following for bug fix 3892097
		ptp.time_period_id = lines.time_period_id AND
		dest.adj_set_number = trans_type.adj_set_number AND
--	End of changes for bug fix 3892097
            DEST.adj_set_number = ORIG.adj_set_number and
            LINES.acct_group_id = ORIG.acct_group_id and
            nvl(ORIG.original_line_flag,'Y') = 'Y' and
            DEST.original_line_flag = 'N';
 /*    ORDER BY DEST.adj_set_number, DEST.line_number, LINES.time_period_id;
             --- order by  ensures the delta amount will be posted to line of last time periods.
*/
     hr_utility.trace('Inserted into PSP_ADJUSTMENT_LINES - 20');

     hr_utility.trace('g_precision = '||g_precision);
     hr_utility.trace('Bulk Fetch SLINE_IDEAL_AMNT_MATRIX values');

     open sline_ideal_amnt_matrix;
     fetch sline_ideal_amnt_matrix bulk collect into
             r_sline_ideal_amnt_matrix.adj_set_number,
             r_sline_ideal_amnt_matrix.time_period_id,
             r_sline_ideal_amnt_matrix.element_type_id,
             r_sline_ideal_amnt_matrix.sline_number,
             r_sline_ideal_amnt_matrix.distribution_sum,
             r_sline_ideal_amnt_matrix.delta_sum,
             r_sline_ideal_amnt_matrix.adjustment_sline_id;
     close sline_ideal_amnt_matrix;

     hr_utility.trace('Updating the DISTRIBUTION_AMOUNT based on g_precision');

     update psp_adjustment_lines
     set distribution_amount = round(distribution_amount, g_precision)
     where original_line_flag = 'N'and
                 batch_name = p_batch_name;

     forall I in 1..r_sline_ideal_amnt_matrix.adj_set_number.count
     update psp_adjustment_lines
     set distribution_amount = distribution_amount +
             decode(dr_cr_flag,'D', r_sline_ideal_amnt_matrix.delta_sum(i),
                                   -r_sline_ideal_amnt_matrix.delta_sum(i))
     where adjustment_line_id = r_sline_ideal_amnt_matrix.adjustment_sline_id(i);

     r_sline_ideal_amnt_matrix.adj_set_number.delete;
     r_sline_ideal_amnt_matrix.time_period_id.delete;
     r_sline_ideal_amnt_matrix.sline_number.delete;
     r_sline_ideal_amnt_matrix.distribution_sum.delete;
     r_sline_ideal_amnt_matrix.delta_sum.delete;
     r_sline_ideal_amnt_matrix.adjustment_sline_id.delete;

     hr_utility.trace('Bulk Fetch ADJ_MATRIX values');

     open adj_matrix;
     fetch adj_matrix  bulk collect into  r_adj_matrix.adj_set_number,
                                          r_adj_matrix.time_period_id,
                                          r_adj_matrix.element_type_id,
                                          r_adj_matrix.distribution_sum;
     close adj_matrix;

     hr_utility.trace('Bulk Fetch SLINE_ACTUAL_AMNT_MATRIX values');

     open sline_actual_amnt_matrix;
     fetch sline_actual_amnt_matrix bulk collect into
                           r_sline_actual_amnt_matrix.adj_set_number,
                           r_sline_actual_amnt_matrix.time_period_id,
                           r_sline_actual_amnt_matrix.element_type_id,
                           r_sline_actual_amnt_matrix.distribution_sum,
                           r_sline_actual_amnt_matrix.adjustment_sline_id,
                           r_sline_actual_amnt_matrix.delta_sum;

     close sline_actual_amnt_matrix;

     /* Ensure that amount adj set/time period/element wise is in sync with new distributions,
         i.e amount doesnot flow between set to set, it does not flow between element to element,
         does not flow between time period to time period */

     for I in 1.. r_adj_matrix.adj_set_number.count
     loop
         for j in 1..r_sline_actual_amnt_matrix.adj_set_number.count
          loop
                if r_adj_matrix.adj_set_number(i) = r_sline_actual_amnt_matrix.adj_set_number(j) and
                   r_adj_matrix.element_type_id(i)= r_sline_actual_amnt_matrix.element_type_id(j) and
                   r_adj_matrix.time_period_id(i) = r_sline_actual_amnt_matrix.time_period_id(j)
                then
                   r_sline_actual_amnt_matrix.delta_sum(i) :=
                   r_adj_matrix.distribution_sum(i) - r_sline_actual_amnt_matrix.distribution_sum(j);

                   hr_utility.trace('Inside Loop1');
                   hr_utility.trace('r_sline_actual_amnt_matrix.delta_sum(i) = '||r_sline_actual_amnt_matrix.delta_sum(i));

                end if;
           end loop;
     end loop;

     r_adj_matrix. adj_set_number.delete;
     r_adj_matrix.element_type_id.delete;
     r_adj_matrix.distribution_sum.delete;

     forall I in 1.. r_sline_actual_amnt_matrix.adj_set_number.count
            update psp_adjustment_lines
           set distribution_amount = distribution_amount  +
                 decode(dr_cr_flag, 'D', r_sline_actual_amnt_matrix.delta_sum(I),
                  - r_sline_actual_amnt_matrix.delta_sum(I))
           where    adjustment_line_id = r_sline_actual_amnt_matrix.adjustment_sline_id(i);

        r_sline_actual_amnt_matrix.adj_set_number.delete;
        r_sline_actual_amnt_matrix.distribution_sum.delete;
        r_sline_actual_amnt_matrix.adjustment_sline_id.delete;
        r_sline_actual_amnt_matrix.delta_sum.delete;

   --- bug fix 3470916
   -- The net of all differences between RHS amounts in
   -- psp_temp_dest_sumlines and psp_adjustment_lines will be zero.
   --- Logic is that for each dest sumlines, for wich it's sum doesnot equal
   --- the sum of dist amount in psp_adjustment_lines, adjust the difference
   -- to the last line in last time period of the element with max element_type_id
   --- there is no reason for this criteria in particular, but there should
   -- some convention to adjust.

    hr_utility.trace('Opening GET_DEST_DIFF cursor');
    open get_dest_diff;
    loop
       hr_utility.trace('LOOP2');
       fetch get_dest_diff into r_dest_diff;
       if get_dest_diff%notfound then
          close get_dest_diff;
          exit;
       end if;

       hr_utility.trace('r_dest_diff.amount = '||r_dest_diff.amount);
       hr_utility.trace('r_dest_diff.distribution_sum = '||r_dest_diff.distribution_sum);

       if r_dest_diff.amount <> r_dest_diff.distribution_sum  then
           if (nvl(l_prev_adj_set,0) = 0  or l_prev_adj_set <> r_dest_diff.adj_set_number) then
             open get_max_element(r_dest_diff.adj_set_number, r_dest_diff.line_number);
             fetch get_max_element into r_element_tp;
             close get_max_element;
             l_prev_adj_set :=  r_dest_diff.adj_set_number; --- added for 3776353
          end if;

          update psp_adjustment_lines
             set distribution_amount = distribution_amount +
                decode(dr_cr_flag,'D',r_dest_diff.distribution_sum-r_dest_diff.amount,
                                     -r_dest_diff.distribution_sum+r_dest_diff.amount)
          where adjustment_line_id in
                (select max(adjustment_line_id)
                 from psp_adjustment_lines
                 where batch_name = p_batch_name and
                       original_line_flag = 'N' and
                       line_number = r_dest_diff.line_number and
                       adj_set_number = r_dest_diff.adj_set_number and
                       element_type_id = r_element_tp.element_type_id and
                       time_period_id = r_element_tp.time_period_id);

          end if;
      end loop;

       ---- moved the delete from above the loop for 3776353
    delete psp_adjustment_lines
    where distribution_amount = 0
      and batch_name = p_batch_name;

    ---  added for DA-ENH
    --- adj batch integrity check, element wise-net sum must be zero,
    --- if net sum not zero, error buf will contain the first element with problem

    -- Added If-End if for Bug 6634876
    OPEN net_batch_sum_cur;
    FETCH net_batch_sum_cur INTO r_net_zero_diff;
    CLOSE net_batch_sum_cur;

    IF (r_net_zero_diff.amount <> 0)  THEN

    	hr_utility.trace('Opening CHECK_BATCH_INTEGRITY cursor for batch_name = '||p_batch_name);

    	 open check_batch_integrity(p_batch_name);
    	 fetch check_batch_integrity into l_integrity_count, l_element_type_id;
    	 close check_batch_integrity;

    	 hr_utility.trace('l_integrity_count = '||l_integrity_count);
    	 hr_utility.trace('l_element_type_id = '||l_element_type_id);

    	 if l_integrity_count > 0 then
    	     --- shows only the first offending element i.e net amount not zero.
    	    open get_element_name;
    	    fetch get_element_name into l_element_name;
    	    close get_element_name;

    	    hr_utility.trace('l_element_name = '||l_element_name);
    	    hr_utility.trace('Before Raise error');

    	    raise  batch_net_not_zero;

    	    hr_utility.trace('After Raise error');
    	 end if;

     END IF;  -- Added If - End If for bug 6634876


   /* Introduced the following code for Bug 3548388 */

      if (p_defer_autopop_param = 'Y' and ( p_adjust_by ='A' or p_adjust_by = 'G' ))  Then





	       deferred_autopop_rec.array_element_type_id.delete;
               deferred_autopop_rec.array_glccid.delete;
               deferred_autopop_rec.array_project_id.delete;
               deferred_autopop_rec.array_exp_org_id.delete;
               deferred_autopop_rec.array_exp_type.delete;
               deferred_autopop_rec.array_task_id.delete;
               deferred_autopop_rec.array_award_id.delete;

	       final_autopop_rec.array_element_type_id.delete;
	       final_autopop_rec.array_glccid.delete;
	       final_autopop_rec.array_project_id.delete;
	       final_autopop_rec.array_exp_org_id.delete;
	       final_autopop_rec.array_exp_type.delete;
	       final_autopop_rec.array_task_id.delete;
	       final_autopop_rec.array_award_id.delete;


               open autopop_defer_cur;
               fetch autopop_defer_cur bulk collect  into
               deferred_autopop_rec.array_element_type_id,
               deferred_autopop_rec.array_glccid,
               deferred_autopop_rec.array_project_id,
               deferred_autopop_rec.array_exp_org_id,
               deferred_autopop_rec.array_exp_type,
               deferred_autopop_rec.array_task_id,
               deferred_autopop_rec.array_award_id;
               close autopop_defer_cur;

                if (  deferred_autopop_rec.array_element_type_id.count > 0 ) then

                FOR  I IN 1 .. deferred_autopop_rec.array_element_type_id.count
                LOOP

		 l_count:=l_count + 1;
		 l_expenditure_type := NULL;
		 l_gl_code_combination_id :=NULL;
                 l_segs := NULL;

                       If (deferred_autopop_rec.array_project_id(I) IS NOT NULL ) and
                          (deferred_autopop_rec.array_task_id(I) IS  NOT NULL) and
                          (deferred_autopop_rec.array_exp_org_id(I) IS NOT NULL)
                       then

                             psp_autopop.main(p_acct_type => 'E',
              		     p_person_id => p_person_id,
              		     p_assignment_id => p_assignment_id,
              		     p_element_type_id => deferred_autopop_rec.array_element_type_id(i),
              		     p_project_id => deferred_autopop_rec.array_project_id(i),
              		     p_expenditure_organization_id => deferred_autopop_rec.array_exp_org_id(i),
              		     p_task_id => deferred_autopop_rec.array_task_id(i),
              		     p_award_id => deferred_autopop_rec.array_award_id(i),
              		     p_expenditure_type => deferred_autopop_rec.array_exp_type(i),
              	             p_gl_code_combination_id => null,
              		     p_payroll_date => p_begin_date,
			     p_set_of_books_id =>p_set_of_books_id,
              		     p_business_group_id =>p_business_group_id,
              		     ret_expenditure_type => l_expenditure_type,
                             ret_gl_code_combination_id => l_dummy_var,
              		     retcode => l_ret_code);

                          if (l_ret_code  in ('U', 'E') ) then
                            p_adjustment_line_id := NULL;
                            p_element_status:= psp_general.get_element_name
                                            (deferred_autopop_rec.array_element_type_id(i),
                                             trunc(SYSDATE)) ;
                           raise    Inv_autopop_element;
                          end if ;



                        --  Introduced this cursor to check whether poet or poeta validations are valid

                                open pa_check_effectivedate
				     (deferred_autopop_rec.array_element_type_id(i),
                                      deferred_autopop_rec.array_project_id(i) ,
                                      deferred_autopop_rec.array_task_id(i),
				      deferred_autopop_rec.array_award_id(i),
                                      deferred_autopop_rec.array_exp_org_id(i),
                                      deferred_autopop_rec.array_exp_type(i));
                                fetch  pa_check_effectivedate bulk collect into
				       effective_date_array.r_effective_date,
				       effective_date_array.r_adj_line_id;
                                close  pa_check_effectivedate;

                                 for J in 1 .. effective_date_array.r_effective_date.count
                                 loop


                                                l_patc_status := NULL;

                                             	pa_transactions_pub.validate_transaction(
						x_project_id 		=> deferred_autopop_rec.array_project_id(i),
						x_task_id    		=> deferred_autopop_rec.array_task_id(i),
						x_ei_date    		=> effective_date_array.r_effective_date(j),
						x_expenditure_type	=> l_expenditure_type,
					 	x_non_labor_resource	=> null,
						x_person_id		=> p_person_id,
						x_incurred_by_org_id	=> deferred_autopop_rec.array_exp_org_id(i),
						x_calling_module	=> 'PSPAUTOB',
						x_msg_application=> l_msg_app,
						x_msg_type	=> l_msg_type,
						x_msg_token1	=> l_msg_token1,
						x_msg_token2	=> l_msg_token2,
			 			x_msg_token3	=> l_msg_token3,
						x_msg_count	=> l_msg_count,
						x_msg_data	=> l_patc_status,
						x_billable_flag	=> l_billable_flag,
						p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter

                                           -- Introduced for Bug fix 3741272

				          If (l_patc_status = 'PA_EXP_ORG_NOT_ACTIVE'  ) Then

                   			  OPEN l_exp_org_csr(effective_date_array.r_effective_date(j),
                                                             deferred_autopop_rec.array_exp_org_id(i));
                           		  FETCH l_exp_org_csr INTO l_dummy;
			        	  CLOSE l_exp_org_csr;

				             if l_dummy = 'x'  then
                                               l_patc_status:= NULL ;
                                             else
                                               l_patc_status:= 'PA_EXP_ORG_NOT_ACTIVE' ;
                                             end if ;

                                          End if ;
                                          -- End of changes for Bug fix 3741272


					   if l_patc_status is not null then

                                              p_adjustment_line_id := effective_date_array.r_adj_line_id(j);
                                              p_element_status := l_patc_status;
                                              raise Invalid_ptoe;

                                            end if ;

				           if deferred_autopop_rec.array_award_id(i) IS not null
                                           then

                                            	gms_transactions_pub.validate_transaction (
						deferred_autopop_rec.array_project_id(i),
						deferred_autopop_rec.array_task_id(i),
						deferred_autopop_rec.array_award_id(i),
						l_expenditure_type,
						effective_date_array.r_effective_date(j),
						'PSPAUTOB',
						l_award_status);
					   end if;

                                            if l_award_status is not null  then

                                               p_adjustment_line_id := effective_date_array.r_adj_line_id(j);
                                               p_element_status := l_award_status;
                                               raise Invalid_ptoea;

                                            end if;


                                  End loop ;


                         elsif (deferred_autopop_rec.array_glccid(i) IS NOT NULL )
                         then

                             psp_autopop.main(p_acct_type => 'N',
	              	     p_person_id =>p_person_id,
	              	     p_assignment_id => p_assignment_id,
	              	     p_element_type_id =>deferred_autopop_rec.array_element_type_id(i),
	              	     p_project_id =>null ,
	              	     p_expenditure_organization_id => null,
	              	     p_task_id => null,
	              	     p_award_id => null,
              	             p_expenditure_type => null,
              	             p_gl_code_combination_id =>deferred_autopop_rec.array_glccid(i),
              		     p_payroll_date => p_begin_date,
              		     p_set_of_books_id =>p_set_of_books_id,
              		     p_business_group_id =>p_business_group_id,
              		     ret_expenditure_type => l_dummy_var,
                             ret_gl_code_combination_id => l_gl_code_combination_id,
              		     retcode => l_ret_code);

                             if (l_ret_code  in ('U', 'E') ) then
                                p_adjustment_line_id := NULL;
                                p_element_status:= psp_general.get_element_name
                                (deferred_autopop_rec.array_element_type_id(i),
                                 trunc(SYSDATE)) ;
                                 raise    Inv_autopop_element;

                             end if ;


		             if(l_gl_code_combination_id is NOT NULL) then

                               l_segs :=fnd_flex_ext.get_segs(
			       application_short_name =>'SQLGL',
                               key_flex_code          => 'GL#',
		               structure_number       => to_number(l_chart_of_accts),
			       combination_id         =>l_gl_code_combination_id);


                                 if(l_segs is NULL ) then
			    	  p_adjustment_line_id := NULL;
               			  p_element_status:= psp_general.get_element_name
                                  (deferred_autopop_rec.array_element_type_id(i),
                                  trunc(SYSDATE)) ;
               			  raise    Inv_autopop_element;
			         end if ;

                             else

                                  p_adjustment_line_id := NULL;
                                  p_element_status:= psp_general.get_element_name
                                  (deferred_autopop_rec.array_element_type_id(i),
                                  trunc(SYSDATE)) ;
                                  raise    Inv_autopop_element;

                             end if;




		       end if;


	 final_autopop_rec.array_element_type_id(l_count):= deferred_autopop_rec.array_element_type_id(i);
         final_autopop_rec.array_glccid(l_count):= nvl(l_gl_code_combination_id,deferred_autopop_rec.array_glccid(i));
	 final_autopop_rec.array_project_id(l_count):= deferred_autopop_rec.array_project_id(i);
         final_autopop_rec.array_exp_org_id(l_count):= deferred_autopop_rec.array_exp_org_id(i);
         final_autopop_rec.array_exp_type(l_count):= nvl(l_expenditure_type,deferred_autopop_rec.array_exp_type(i));
         final_autopop_rec.array_task_id(l_count) := deferred_autopop_rec.array_task_id(i);
         final_autopop_rec.array_award_id(l_count):= deferred_autopop_rec.array_award_id(i);

	 END LOOP; -- End of Main loop


    FORALL I in 1 .. final_autopop_rec.array_element_type_id.count
    Update      psp_adjustment_lines
    set
    		gl_code_combination_id =  final_autopop_rec.array_glccid(i),
    		project_id = final_autopop_rec.array_project_id(i),
    		expenditure_organization_id = final_autopop_rec.array_exp_org_id(i),
    		expenditure_type  = final_autopop_rec.array_exp_type(i),
    		task_id =  final_autopop_rec.array_task_id(i),
    		award_id =  final_autopop_rec.array_award_id(i)
     Where     Element_type_id = deferred_autopop_rec.array_element_type_id(i)
     And        nvl(gl_code_combination_id,0) =nvl(deferred_autopop_rec.array_glccid(i),0)
     And        nvl(project_id,0) = nvl(deferred_autopop_rec.array_project_id(i),0)
     And        nvl(expenditure_organization_id,0) =nvl(deferred_autopop_rec.array_exp_org_id(i),0)
     And        nvl(expenditure_type,0) = nvl(deferred_autopop_rec.array_exp_type(i),0)
     And        nvl(task_id,0) = nvl(deferred_autopop_rec.array_task_id(i),0)
     And        nvl(award_id,0) =nvl(deferred_autopop_rec.array_award_id(i),0)
     And        batch_name = p_batch_name
     And        business_group_id = p_business_group_id
     And        set_of_books_id = p_set_of_books_id
     AND        original_line_flag <> 'Y'; -- Added for Bug 5013847


  End if; -- End If for (autopop_defer_cur.count > 0) check


  End if; -- end if to for check (p_defer_autopop_param = 'Y')






  /* End of code changes for Bug 3548388 */


/* Start of Code Changes for Supercedence  check based on migration to new OAF EFfort Reporting */

  IF not (l_migration_status) THEN

     update_effort_reports(p_batch_name,
			   p_business_group_id,
			   p_set_of_books_id,
			   l_return_status);
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


  END IF;



/* End  of Code Changes for Supercedence  check based on migration to new OAF EFfort Reporting */



     update_payroll_control(p_batch_name,
                            l_payroll_control_id,
			    p_business_group_id,
			    p_set_of_books_id,
			    p_currency_code,	-- Introduced for bug fix 2916848
				    l_return_status,
				p_gl_posting_override_date);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      delete from psp_temp_orig_lines where run_id = p_run_id;
      delete from psp_temp_orig_sumlines where run_id = p_run_id;
      delete from psp_temp_dest_sumlines where run_id = p_run_id;

      -- 4992668
      psp_wf_adj_custom.prorate_dff_hook(p_batch_name,
                                         p_business_group_id,
                                         p_set_of_books_id);
      -- Start workflow before commiting
	psp_wf_adj_pkg.init_workflow (
				p_batch_name,
				p_person_id,
				p_employee_full_name,
				p_assignment_number,
				 ---p_earnings_element, commented for DA-ENH
				p_distribution_start_date,
				p_distribution_end_date,
				p_currency_code,	-- Introduced for bug fix 2916848
				p_batch_comments,
				p_time_out,
				l_wf_ret_status);
      if l_wf_ret_status = 0
      then
      		commit;
      		retcode := 0;
      else
		raise workflow_failed;
      end if;

   hr_utility.trace('Procedure OUT parameters :-') ;

   hr_utility.trace('OUT errbuf = '||errbuf) ;
   hr_utility.trace('OUT retcode = '||retcode) ;
   hr_utility.trace('OUT p_adjustment_line_id = '||p_adjustment_line_id) ;
   hr_utility.trace('OUT p_element_status = '||p_element_status) ;

   hr_utility.trace('EXIT Leaving GENERATE_LINES procedure') ;
   hr_utility.trace('**************************************************');

   EXCEPTION

   WHEN Inv_autopop_element THEN
    rollback;
    retcode := 7;

  WHEN Invalid_ptoe THEN
   rollback;
   retcode := 8;

  WHEN Invalid_ptoea THEN
   rollback;
   retcode := 9;

  WHEN Invalid_gl THEN
   rollback;
   retcode := 10;

   WHEN e_constraint_violation THEN
      errbuf := 'In table psp_adjustment_control_table, primary key adjustment_batch_name constraint is violated';
      retcode := 4;

   WHEN NO_RECORDS_FOUND THEN
     rollback;
     errbuf := 'No records found:'||g_error_api_path;
     retcode := 5;

   WHEN workflow_failed  THEN
	rollback;
	errbuf := 'Error in Starting WorkFlow';
	retcode := 6;
   WHEN batch_net_not_zero then  --- added this exception for DA-ENH
        rollback;
        errbuf := l_element_name;
        retcode := 1;

        hr_utility.trace('EXCEPTION');
        hr_utility.trace('EXC errbuf = '||errbuf) ;
        hr_utility.trace('EXC retcode = '||retcode) ;
	hr_utility.trace('EXC p_adjustment_line_id = '||p_adjustment_line_id) ;
	hr_utility.trace('EXC p_element_status = '||p_element_status) ;
	hr_utility.trace('EXC l_element_name = '||l_element_name) ;
        hr_utility.trace('EXCEPTION Leaving GENERATE_LINES procedure') ;
        hr_utility.trace('**************************************************');

   WHEN OTHERS THEN
      rollback;
/*****	Commented the following DELETE statements for the following reasons as part of R12 performance fixes (bug 4507892)
	1)	These DELETE statements donot have proper COMMIT logic.
	2)	Doesnt check for proper run_id.
	3)	Non-performant SQLs.
      delete from psp_temp_orig_lines;
      delete from psp_temp_orig_sumlines;
      delete from psp_temp_dest_sumlines;
	End of comment for bug fix 4507892	*****/
      g_error_api_path := 'GENERATE_LINES:'||g_error_api_path||sqlerrm;
      fnd_msg_pub.get(p_msg_index     =>  FND_MSG_PUB.G_FIRST,
                      p_encoded       =>  FND_API.G_FALSE,
                      p_data          =>  l_msg_data,
                      p_msg_index_out =>  l_msg_count);
      errbuf := errbuf || l_msg_data || fnd_global.local_chr(10) || g_error_api_path;
      retcode := 2;

   end generate_lines;

----------P R O C E D U R E: INSERT_PSP_CLEARING_ACCOUNT-------------------------------
--
--
--  Purpose:   This procedure is called by distribution transfers clearing account
--             creation form.  The purpose is to create a clearing account
--             to be used by the summarization and transfer concurrent process
--             to post GL balances to when an original GL account line is
--             transfered to a Project account.
------------------------------------------------------------------------------------

   PROCEDURE insert_psp_clearing_account(errbuf  		OUT NOCOPY VARCHAR2,
                     			 retcode 		OUT NOCOPY VARCHAR2,
                     			 p_reversing_gl_ccid 	IN NUMBER,
                     			 p_comments 		IN VARCHAR2,
					 p_business_group_id    IN NUMBER,
					 p_set_of_books_id   	IN NUMBER,
					 p_payroll_id           IN Number,
				         p_rowid                OUT NOCOPY VARCHAR2) IS

v_count number;
account_exists Exception;
cursor c_existing is
select count(*)
from psp_clearing_account
where BUSINESS_GROUP_ID = p_business_group_id
AND   SET_OF_BOOKS_ID   = p_set_of_books_id
AND   PAYROLL_ID        = p_payroll_id;
begin
	open c_existing ;
	fetch c_existing into v_count ;
	if v_count <>0   then
		close c_existing ;
		raise account_exists;
	end if;
	close c_existing;

         insert into psp_clearing_account(reversing_gl_ccid,
                                        comments,
					business_group_id,
					set_of_books_id,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN,
					CREATED_BY,
					CREATION_DATE,
					PAYROLL_ID)
           			values(p_reversing_gl_ccid,
                  			p_comments,
					p_business_group_id,
					p_set_of_books_id,
                  			sysdate,
					fnd_global.user_id,
					fnd_global.login_id,
					fnd_global.user_id,
					sysdate,
					p_payroll_id) RETURNING rowid into p_rowid;

   EXCEPTION
      WHEN account_exists THEN
        retcode := 2;
      WHEN OTHERS THEN
	errbuf:= 'PSP_ADJ_DRIVER : INSERT_PSP_CLEARING_ACCOUNT' || sqlerrm;
	retcode := -1;
    end insert_psp_clearing_account;
-----------------------------------------------------------------------------------

-----------------------------UPDATE Clearing Account-------------------------------
 PROCEDURE update_psp_clearing_account(errbuf  			OUT NOCOPY VARCHAR2,
                     			retcode 		OUT NOCOPY VARCHAR2,
                     			p_reversing_gl_ccid 	IN NUMBER,
                     			p_comments 		IN VARCHAR2,
				 	p_business_group_id	IN NUMBER,
					p_set_of_books_id	IN NUMBER,
					p_payroll_id            IN Number,
					p_rowid                 IN VARCHAR2) IS

begin

         update psp_clearing_account
         set reversing_gl_ccid = p_reversing_gl_ccid,
              comments         = p_comments,
	      business_group_id = p_business_group_id,
	      set_of_books_id	= p_set_of_books_id,
	      LAST_UPDATE_DATE = sysdate,
	      LAST_UPDATED_BY  = fnd_global.user_id,
              LAST_UPDATE_LOGIN = fnd_global.login_id,
	      payroll_id = p_payroll_id
	where business_group_id = p_business_group_id
         AND   set_of_books_id   = p_set_of_books_id
	 AND   rowid = p_rowid;

   EXCEPTION
      WHEN OTHERS THEN
	errbuf:= 'PSP_ADJ_DRIVER : UPDATE_PSP_CLEARING_ACCOUNT' || sqlerrm;
	retcode := -1;

    end update_psp_clearing_account;
------------------------------------------------------------------------------------

-----------------------------DELETE Clearing Account--------------------------------
PROCEDURE delete_psp_clearing_account(errbuf  			OUT NOCOPY VARCHAR2,
                     			retcode 		OUT NOCOPY VARCHAR2,
                     			p_reversing_gl_ccid 	IN NUMBER,
					p_business_group_id	IN NUMBER,
					p_set_of_books_id	IN NUMBER,
					p_rowid                 IN VARCHAR2) IS


    begin

         delete from psp_clearing_account
         where business_group_id = p_business_group_id
   	 and   set_of_books_id  = p_set_of_books_id
	 and   rowid = p_rowid;

   EXCEPTION
      WHEN OTHERS THEN
	errbuf:= 'PSP_ADJ_DRIVER : DELETE_PSP_CLEARING_ACCOUNT' || sqlerrm;
	retcode := -1;

    end delete_psp_clearing_account;
------------------------------------------------------------------------------------

-------------------------------LOCK Clearing Account--------------------------------

PROCEDURE LOCK_ROW_PSP_CLEARING_ACCOUNT (
  P_BUSINESS_GROUP_ID  IN NUMBER,
  P_SET_OF_BOOKS_ID    IN NUMBER,
  P_REVERSING_GL_CCID  IN NUMBER,
  P_COMMENTS           IN VARCHAR2,
  P_PAYROLL_ID         IN NUMBER
) is
  cursor c1 is select
      BUSINESS_GROUP_ID,
      SET_OF_BOOKS_ID,
      REVERSING_GL_CCID,
      COMMENTS,
      PAYROLL_ID
    from PSP_CLEARING_ACCOUNT
    where business_group_id = p_business_group_id
    and set_of_books_id   = p_set_of_books_id
    and payroll_id = p_payroll_id
    and reversing_gl_ccid = p_reversing_gl_ccid
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID)
      AND (tlinfo.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID)
      AND (tlinfo.REVERSING_GL_CCID = P_REVERSING_GL_CCID)
      AND ((tlinfo.COMMENTS = P_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (P_COMMENTS is null)))
      AND (tlinfo.PAYROLL_ID = P_PAYROLL_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
END LOCK_ROW_PSP_CLEARING_ACCOUNT;
------------------------------------------------------------------------------------

PROCEDURE undo_adjustment(p_batch_name 		IN  	VARCHAR2,
			  p_business_group_id 	IN 	number,
			  p_set_of_books_id   	IN 	number,
			  p_comments		IN	VARCHAR2,
                          errbuf       		OUT NOCOPY 	VARCHAR2,
                          return_code  		OUT NOCOPY 	NUMBER)
IS
     undo_failed_exception EXCEPTION;

     l_orig_line_id	      psp_adjustment_lines.orig_line_id%TYPE;
     l_orig_source_type       psp_adjustment_lines.orig_source_type%TYPE;
     l_report_id              psp_effort_reports.effort_report_id%TYPE;
--	Introduced the following variables for bug fix 2724110
	l_person_id	NUMBER(15);
	l_begin_date	DATE;
	l_end_date	DATE;
	l_batch_count	NUMBER;

     CURSOR get_line_id_csr IS
       SELECT orig_line_id,
	      orig_source_type
       FROM   psp_adjustment_lines
       WHERE  original_line_flag = 'Y'
       AND    batch_name = p_batch_name
       and    business_group_id = p_business_group_id
       and    set_of_books_id   = p_set_of_books_id;

--	Modified the SELECT stmt of the following cursor for bug fix 2724110
	CURSOR get_template_id_csr IS
	SELECT	report.effort_report_id,
		report.person_id,
		min(begin_date),
		max(end_date)
	FROM	psp_effort_reports  report,
		psp_adjustment_lines line,
		psp_effort_report_templates template
	WHERE	line.batch_name = p_batch_name
	AND	report.person_id = line.person_id
	AND	template.template_id = report.template_id
	AND	line.distribution_date BETWEEN template.begin_date AND template.end_date
	AND	template.report_type = 'N'
	AND	report.status_code = 'S'
	GROUP BY report.effort_report_id,
		report.person_id;

/****	Commented the following for bug fix 2724110
       SELECT distinct report.effort_report_id
       FROM   psp_adjustment_lines line,
              psp_effort_reports   report,
              psp_effort_report_templates template
       WHERE  line.business_group_id = p_business_group_id
       and    line.set_of_books_id   = p_set_of_books_id
       and    line.batch_name = p_batch_name
       AND    line.person_id = report.person_id
       and    line.business_group_id = template.business_group_id
       and    line.set_of_books_id   = template.set_of_books_id
       AND    template.template_id = report.template_id
       AND    line.distribution_date BETWEEN template.begin_date AND template.end_date
       AND    template.report_type = 'N';
	End of comment for bug fix	***/

--	Introduced the following cursor for bug fix 2724110
	CURSOR  addl_adj_batch_count_cur(p_person_id	NUMBER,
					p_batch_name	VARCHAR2,
					p_begin_date	DATE,
					p_end_date	DATE) IS
	SELECT	COUNT(1)
	FROM	psp_adjustment_lines pal
	WHERE	person_id = p_person_id
	AND	batch_name <> p_batch_name
	AND	distribution_date BETWEEN p_begin_date AND p_end_date
	AND	EXISTS	(SELECT 1
			FROM    psp_effort_report_elements pere
			WHERE   pere.element_type_id = pal.element_type_id
			AND     pere.use_in_effort_report='Y')
	AND	ROWNUM = 1;

/* Introduced check on migration status before superceding */

   l_migration_status BOOLEAN:= psp_general.is_effort_report_migrated;



BEGIN
      SAVEPOINT undo_adj_savepoint;

     /*---------------------------------------------------------------------*/
     /*1. Update one of the history tables PSP_ADJUSTMENT_LINES_HISTORY or  */
     /*   PSP_PRE_GEN_DIST_LINES_HISTORY or PSP_DISTRIBUTION_LINES_HISTORY  */
     /*   by setting the adjustment_batch_name to NULL.                     */
     /*---------------------------------------------------------------------*/
     OPEN get_line_id_csr;
     LOOP
       FETCH get_line_id_csr INTO l_orig_line_id, l_orig_source_type;
       EXIT WHEN get_line_id_csr%NOTFOUND;
       IF (l_orig_source_type = 'A') THEN
         UPDATE psp_adjustment_lines_history
         SET adjustment_batch_name = NULL
         WHERE adjustment_line_id = l_orig_line_id;
       ELSIF (l_orig_source_type = 'P') THEN
         UPDATE psp_pre_gen_dist_lines_history
         SET adjustment_batch_name = NULL
         WHERE pre_gen_dist_line_id = l_orig_line_id;
       ELSIF (l_orig_source_type = 'D') THEN
         UPDATE psp_distribution_lines_history
         SET adjustment_batch_name = NULL
         WHERE distribution_line_id = l_orig_line_id;
       END IF;
     END LOOP;
     IF (get_line_id_csr%ROWCOUNT = 0) THEN
       errbuf := 'Failed when update history table: no rows found.';
       RAISE undo_failed_exception;
     END IF;
     CLOSE get_line_id_csr;

     /*---------------------------------------------------------------------*/
     /*2. Update table PSP_EFFORT_REPORTS by setting status_code back to    */
     /*   what it is before the batch is created and flush the              */
     /*   previous_status_code column.                                      */
     /*---------------------------------------------------------------------*/
     OPEN get_template_id_csr;
     LOOP
        FETCH get_template_id_csr INTO l_report_id, l_person_id, l_begin_date, l_end_date;	-- Intro. addl variables for bug fix 2724110
        EXIT WHEN get_template_id_csr%NOTFOUND;
--Introduced the folowing code for bug fix 2724110
	OPEN addl_adj_batch_count_cur(l_person_id, p_batch_name, l_begin_date, l_end_date);
	FETCH addl_adj_batch_count_cur INTO l_batch_count;
	CLOSE addl_adj_batch_count_cur;



-- Introduced check on migration status before reverting back superceded ER

 IF not (l_migration_status)  THEN
	IF (l_batch_count = 0) THEN
		UPDATE	psp_effort_reports
		SET	status_code = previous_status_code,
			previous_status_code = NULL
		WHERE	effort_report_id = l_report_id
		AND	previous_status_code IS NOT NULL;
	END IF;
--End of bug fix 2724110


END IF;

/***	Commented for bug fix 2724110
        UPDATE psp_effort_reports
        SET    status_code = previous_status_code
        WHERE  effort_report_id = l_report_id;

        UPDATE psp_effort_reports
        SET    previous_status_code = NULL
        WHERE effort_report_id = l_report_id;
	End of comment for bug fix 2724110	***/
     END LOOP;
     CLOSE get_template_id_csr;

     /*---------------------------------------------------------------------*/
     /*3. Delete the record for the rejected batch from PSP_PAYROLL_CONTROL */
     /*---------------------------------------------------------------------*/
     DELETE FROM psp_payroll_controls
     WHERE  batch_name = p_batch_name
     AND    source_type = 'A';
     IF (SQL%NOTFOUND) THEN
       errbuf := 'Failed when update psp_payroll_control table: no row found.';
       RAISE undo_failed_exception;
     END IF;

     /*---------------------------------------------------------------------*/
     /*4. Delete the distribution lines of the rejected batch from table    */
     /*   PSP_ADJUSTMENT_LINES.                                             */
     /*---------------------------------------------------------------------*/
     DELETE FROM psp_adjustment_lines
     WHERE batch_name = p_batch_name;
     IF (SQL%NOTFOUND) THEN
       errbuf := 'Failed when update psp_adjustment_lines: no row found.';
       RAISE undo_failed_exception;
     END IF;

     /*---------------------------------------------------------------------*/
     /*5. Delete the record for the rejected batch from table               */
     /*   PSP_ADJUSTMENT_CONTROL_TABLE.                                     */
     /*---------------------------------------------------------------------*/
     UPDATE psp_adjustment_control_table
     SET    void = 'Y',
	    comments = p_comments
     WHERE  adjustment_batch_name = p_batch_name;
     IF (SQL%NOTFOUND) THEN
       errbuf := 'Failed when update psp_adjustment_control_table: no row found.';
       RAISE undo_failed_exception;
     END IF;

     COMMIT;
     return_code := 0;

   EXCEPTION
     WHEN undo_failed_exception THEN
        ROLLBACK TO SAVEPOINT undo_adj_savepoint;
        return_code := -1;
--Introduced for Bug 2665152
    WHEN OTHERS THEN
	ROLLBACK TO SAVEPOINT undo_adj_savepoint;
	errbuf:= 'PSP_ADJ_DRIVER : UNDO_ADJUSTMENT';
	return_code := -1;
   END undo_adjustment;
-----------------------------------------------------------------------------


PROCEDURE validate_proj_before_transfer
    (p_run_id  IN NUMBER,
    p_acct_group_id IN NUMBER,
    p_person_id IN NUMBER,
    p_project_id IN NUMBER,
    p_task_id  IN NUMBER,
    p_award_id  IN NUMBER  DEFAULT NULL,
    p_expenditure_type IN VARCHAR2,
    p_expenditure_org_id IN NUMBER,
    p_error_flag OUT nocopy VARCHAR2,
    p_error_status OUT nocopy VARCHAR2,
    p_effective_date OUT nocopy DATE) IS
 l_patc_status VARCHAR2(2000);
 l_award_status VARCHAR2(2000);
 l_billable_flag VARCHAR2(1);
 l_msg_count NUMBER;
 l_msg_app  VARCHAR2(2000);
 l_msg_type  VARCHAR2(2000);
 l_msg_token1 VARCHAR2(2000);
 l_msg_token2 VARCHAR2(2000);
 l_msg_token3 VARCHAR2(2000);

 TYPE t_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
 TYPE eff_date_rec_type IS RECORD (l_effective_date t_date_type);
 r_eff_date_record eff_date_rec_type;

 CURSOR c_orig_values IS
 SELECT MAX(ptol.effective_date)
 FROM psp_temp_orig_lines ptol
 WHERE ptol.acct_group_id = p_acct_group_id
 AND ptol.run_id = p_run_id
 GROUP BY payroll_control_id,
  dr_cr_flag;

-- Introduced for Bug fix 3741272

CURSOR l_exp_org_csr(l_effective_date date)
IS
SELECT 'x'
FROM psp_organizations_expend_v
WHERE organization_id = p_expenditure_org_id
and trunc(l_effective_date) between date_from and nvl(date_to,trunc(l_effective_date));

l_dummy  VARCHAR2(1);

-- End of changes for Bug fix 3741272

 BEGIN
  OPEN c_orig_values ;
  FETCH c_orig_values BULK COLLECT INTO
    r_eff_date_record.l_effective_date;
  CLOSE c_orig_values;

  FOR recno IN 1..r_eff_date_record.l_effective_date.COUNT
  LOOP
   p_error_flag := 'N';
   l_patc_status := NULL;
   l_award_status := NULL;
   pa_transactions_pub.validate_transaction(
    x_project_id => p_project_id,
    x_task_id  => p_task_id,
    x_ei_date  => r_eff_date_record.l_effective_date(recno),
    x_expenditure_type => p_expenditure_type,
    x_non_labor_resource => NULL,
    x_person_id => p_person_id,
    x_incurred_by_org_id => p_expenditure_org_id,
    x_calling_module => 'PSPLDTRF',
    x_msg_application => l_msg_app,
    x_msg_type => l_msg_type,
    x_msg_token1 => l_msg_token1,
    x_msg_token2 => l_msg_token2,
    x_msg_token3 => l_msg_token3,
    x_msg_count => l_msg_count,
    x_msg_data => l_patc_status,
    x_billable_flag => l_billable_flag,
    p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter

   -- Introduced for Bug fix 3741272

    If (l_patc_status = 'PA_EXP_ORG_NOT_ACTIVE'  ) Then

    OPEN l_exp_org_csr(r_eff_date_record.l_effective_date(recno));
    FETCH l_exp_org_csr INTO l_dummy;
    CLOSE l_exp_org_csr;

    if l_dummy = 'x'  then
      l_patc_status:= NULL ;
    else
      l_patc_status:= 'PA_EXP_ORG_NOT_ACTIVE' ;
    end if ;

    End if ;

   -- End of changes for Bug fix 3741272

   IF l_patc_status IS NOT NULL THEN
    p_error_status := l_patc_status;
    p_error_flag := 'P';
    p_effective_date := r_eff_date_record.l_effective_date(recno);
    EXIT;
   END IF;

   IF p_award_id IS NOT NULL and l_patc_status is null THEN
    gms_transactions_pub.validate_transaction (
     p_project_id,
     p_task_id,
     p_award_id,
     p_expenditure_type,
     r_eff_date_record.l_effective_date(recno),
     'PSPLDTRF',
     l_award_status);
   END IF;

   IF l_award_status IS NOT NULL THEN
    p_error_flag := 'A';
    p_error_status := l_award_status;
    p_effective_date := r_eff_date_record.l_effective_date(recno);
    EXIT;
   END IF;
  END LOOP;
 END validate_proj_before_transfer;
END psp_adj_driver;

/
