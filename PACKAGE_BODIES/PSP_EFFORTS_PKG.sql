--------------------------------------------------------
--  DDL for Package Body PSP_EFFORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_EFFORTS_PKG" AS
/* $Header: PSPEREFB.pls 120.2.12010000.2 2008/08/05 10:11:27 ubhat ship $ */
/***********************************************************************************
**     NAME: psp_efforts_pkg
** CONTENTS: Package Body  for psp_efforts_pkg
**  PURPOSE: This Package Body contains two procedures .
**           1. PROCEDURE crt
**              This procedure takes in as input the various input criteria
**              entered by the user during Effort Report Creation. The input
**              criteria are then matched with the actual disbursements of labor
**              charges from the Distribution Lines and the actual efforts based
**              on a person , against all his assignments, for a period range, is
**              summarized and added to Effort Report Tables. The procedure
**              also does lot of bookkeeping like updating Distribution Lines,
**              retrieving GL and POETA values from appropriate tables, checking
**              active element types and so on. This procedure also populates an
**              Error Table for Effort Report Already processed. This procedure
**              is run by Concurrent Manager.
**
**           2. PROCEDURE INIT_WORKFLOW
**              This procedure is to initiate workflow process. This procedure fetches
**              all Report Ids for a given template id and Initiates workflow process
**              for each report id
**
**    NOTES:  Workflow : Added by Venkat.
**            Enhanced Workflow: Added by Shu Lei.
**    AUTHOR: Abhijit Prasad
**
**   History
**   Ravindra Cheruvu	26-JUL-1999	Included the auto-pop details : gl_ccid and expenditure_type.
**   Ravindra Cheruvu	06-Aug-1999	Changed the code for cursor t_warning_report_exists to
**					handle a rejected ER.
**					Now it checks for status 'R' also and allows to create
**					a new ER for the person.
**   Dinesh Dubey       12-Jul-2001     Perf. Fixes for bug 1874615
**   Subha Ramachandran 23-AUG-2001     Functional Fixes for Bug 1952627
**   Ritesh Kumar       12-SEP-2001	Bug fix:1988747. Added additional conditions to t_all_PERSON_id
**                                      cursor to take care of gl, project, award and exp org submission
**					conditions when creating an effort report.
**   Subha Ramachandran 10-Jul-02       Bug fix 2307100
**   Dinesh Dubey       30-Dec-2002     Modified for bug 2624259.
**   Tulasi Krishna     17-Apr-2003     Modified for Bug fix 2892637.
**	spchakra	02-Sep-2003	Bug 3098050: Introduced BG/SOB columns.
**	spchakra	14-Nov-2003	Bug 3063762: Commented out POTEA/GL check on distributions
**					as its for filtering persons only.
**      vdharmap        11-Apr-2006     Bug 5080403: autopop for suspense.
**	amakrish        29-Apr-2008     Bug 7004679   Added wf_engine.setitemowner
************************************************************************************
***********************************************************************************/
   FUNCTION p_template_exists(a_template_id IN NUMBER)
   --- Function To Check whether Template Exists.
   RETURN NUMBER IS
   BEGIN
      SELECT *
      INTO g_template_row
      FROM psp_effort_report_templates
      WHERE template_id = a_template_id;
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(-1);
   END;
   ---
   FUNCTION p_project_exists(a_template_id IN NUMBER,t_project_id IN NUMBER)
   RETURN NUMBER IS
      t_dummy CHAR(1);
   BEGIN
      BEGIN
         SELECT 'x'
         INTO t_dummy
         FROM psp_template_projects
         WHERE template_id = a_template_id AND
               ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(0);
      END;
      ---
      SELECT 'x'
      INTO t_dummy
      FROM psp_template_projects
      WHERE template_id = a_template_id AND
            project_id = t_project_id;
      RETURN(1);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(2);
   END;
   ---
   FUNCTION p_award_exists(a_template_id IN NUMBER, t_award_id IN NUMBER)
   RETURN NUMBER IS
      t_dummy CHAR(1);
   BEGIN
      BEGIN
         SELECT 'x'
         INTO t_dummy
         FROM psp_template_awards
         WHERE template_id = a_template_id AND
               ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(0);
      END;
      ---
      SELECT 'x'
      INTO t_dummy
      FROM psp_template_awards
      WHERE template_id = a_template_id AND
            award_id = t_award_id;
      RETURN(1);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(2);
   END;
   ---
FUNCTION p_org_exists(a_template_id IN NUMBER, t_expenditure_organization_id IN NUMBER)
   RETURN NUMBER IS
      t_dummy CHAR(1);
   BEGIN
      BEGIN
         SELECT 'x'
         INTO t_dummy
         FROM psp_template_organizations
         WHERE template_id = a_template_id AND
               ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(0);
      END;
      ---
      SELECT 'x'
      INTO t_dummy
      FROM psp_template_organizations
      WHERE template_id = a_template_id AND
            expenditure_organization_id = t_expenditure_organization_id;
      RETURN(1);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(2);
   END;
   ---
   FUNCTION p_get_POETA(template_id1 IN NUMBER,person_id1 IN NUMBER, ssdseo IN g_ssdseo%ROWTYPE)
   RETURN g_gl_poeta%ROWTYPE IS
      t_poeta     g_gl_poeta%ROWTYPE;
   BEGIN
      BEGIN
         SELECT gl_code_combination_id,
            project_id,
            expenditure_organization_id,
            expenditure_type,
            task_id,
            award_id
         INTO t_poeta
         FROM psp_organization_accounts
         WHERE organization_account_id = NVL(ssdseo.suspense_org_account_id,-955);
         RETURN(t_poeta);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;
      ---
      IF ssdseo.suspense_org_account_id IS NOT NULL THEN
      --   dbms_output.put_line('Account Reference For Suspense_org_account_id = ' ||  ssdseo.suspense_org_account_id || ' Not Found');
         log_errors(template_id1,person_id1, 'Account Reference For Suspense_org_account_id = ' ||
                      to_char(ssdseo.suspense_org_account_id )|| ' Not Found.',NULL,NULL);
      END IF;
      ---
      BEGIN
         SELECT gl_code_combination_id,
            project_id,
            expenditure_organization_id,
            expenditure_type,
            task_id,
            award_id
         INTO t_poeta
         FROM psp_organization_accounts
         WHERE organization_account_id = NVL(ssdseo.default_org_account_id,-955);
         RETURN(t_poeta);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;
      ---
      BEGIN
         SELECT gl_code_combination_id,
            project_id,
            expenditure_organization_id,
            expenditure_type,
            task_id,
            award_id
         INTO t_poeta
         FROM psp_schedule_lines
         WHERE schedule_line_id = NVL(ssdseo.schedule_line_id,-955);
         RETURN(t_poeta);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;
      ---
      BEGIN
         SELECT gl_code_combination_id,
            project_id,
            expenditure_organization_id,
            expenditure_type,
            task_id,
            award_id
         INTO t_poeta
         FROM psp_element_type_accounts
         WHERE element_account_id = NVL(ssdseo.element_account_id,-955);
         RETURN(t_poeta);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;
      ---
      BEGIN
         SELECT gl_code_combination_id,
            project_id,
            expenditure_organization_id,
            expenditure_type,
            task_id,
            award_id
         INTO t_poeta
         FROM psp_default_labor_schedules
         WHERE org_schedule_id = NVL(ssdseo.org_schedule_id,-955);
         RETURN(t_poeta);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(t_poeta);
      END;
      ---
   EXCEPTION
      WHEN OTHERS THEN
         --dbms_output.put_line('POETA retrieval failed');
         FND_MESSAGE.set_name('PSP','PSP_EFFORTS_PKG.CRT_POETA_FAIL');
         log_errors(template_id1,person_id1,'GL_POETA Selection Criteria failed' ,NULL,NULL);
         ---RAISE FND_API.g_exc_unexpected_error;
   END;
   -----
   FUNCTION p_element_exists(element_type_id1 IN NUMBER,dist_dt1 IN DATE,
				p_business_group_id	IN	NUMBER,	-- Introduced for bug fix 3098050
				p_set_of_books_id	IN	NUMBER)	-- Introduced for bug fix 3098050
   RETURN NUMBER IS
      t_dummy CHAR(1);
   BEGIN
      BEGIN
         SELECT 'x'
         INTO t_dummy
         FROM psp_effort_report_elements
         WHERE element_type_id = element_type_id1
--	Introduced BG/SOB check for bug fix 3098050
	AND	business_group_id = p_business_group_id
	AND	set_of_books_id = p_set_of_books_id
	AND	NVL(use_in_effort_report,'N') = 'Y'
	AND	ROWNUM = 1;
         g_element_flag := 'Y';
         RETURN(0);
      EXCEPTION
          WHEN OTHERS THEN
             RETURN(-6);
      END;
   END;
   ---
   FUNCTION p_effort_details_exists(effort_report_id1 IN NUMBER, version_number1 IN NUMBER)
   RETURN NUMBER IS
      t_dummy CHAR(1);
   BEGIN
      BEGIN
         SELECT 'x'
         INTO t_dummy
         FROM psp_effort_report_details
         WHERE effort_report_id = effort_report_id1 AND
               version_num = version_number1 AND
               ROWNUM = 1;
         RETURN(0);
      EXCEPTION
          WHEN OTHERS THEN
             RETURN(-7);
      END;
   END;
   ---
   PROCEDURE p_old_adhoc_delete(template_id1 IN NUMBER, person_id1 IN NUMBER,
                                begin_date1 IN DATE, end_date1 IN DATE)
   --- The following private procedure checks to see whether an earlier Adhoc report(s) exists
   --- for a given Adhoc report, with an exact match of Person_id, Start date And End
   --- Date. If, yes, it deletes all record(s) from all concerned tables.
   IS
      CURSOR t_old_templates(template_id2 IN NUMBER, person_id2 IN NUMBER,
                             begin_date2 IN DATE, end_date2 IN DATE) IS
         SELECT distinct E.template_id
         FROM PSP_EFFORT_REPORTS E,PSP_EFFORT_REPORT_TEMPLATES T
         WHERE E.person_id = person_id2 AND
               E.template_id = T.template_id AND
               begin_date2 = T.begin_date AND
               end_date2 = T.end_date AND
               T.report_type = 'A'
         MINUS
         SELECT template_id2
         FROM DUAL;
      t_old_template_id    NUMBER(15);
   BEGIN
      OPEN t_old_templates(template_id1,person_id1,begin_date1,end_date1);
         LOOP
           FETCH t_old_templates INTO t_old_template_id;
           EXIT WHEN t_old_templates%NOTFOUND;
              BEGIN
                 PSP_TEMPLATE_AWARDS_PKG.delete_row(t_old_template_id);
                 IF (SQL%NOTFOUND) THEN
                     NULL;
                 END IF;
                 PSP_TEMPLATE_PROJECTS_PKG.delete_row(t_old_template_id);
                 IF (SQL%NOTFOUND) THEN
                     NULL;
                 END IF;
                 PSP_TEMPLATE_ORGANIZATIONS_PKG.delete_row(t_old_template_id);
                 IF (SQL%NOTFOUND) THEN
                     NULL;
                 END IF;
                 PSP_EFT_REPORT_TEMPLATES_PKG.delete_row(t_old_template_id);
                 IF (SQL%NOTFOUND) THEN
                     NULL;
                 END IF;
                 DELETE FROM PSP_EFFORT_REPORT_DETAILS D
                 WHERE exists ( SELECT 'x'
                                FROM PSP_EFFORT_REPORTS R
                                WHERE R.effort_report_id = D.effort_report_id AND
                                      R.version_num = D.version_num AND
                                      template_id = t_old_template_id );
                 IF (SQL%NOTFOUND) THEN
                     NULL;
                 END IF;
                 DELETE FROM PSP_EFFORT_REPORTS
                 WHERE template_id = t_old_template_id;
                 IF (SQL%NOTFOUND) THEN
                     NULL;
                 END IF;
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    NULL;
              END;
         END LOOP;
      CLOSE t_old_templates;
   END;
   ---
   ---
   FUNCTION p_sync_details(effort_report_id1 IN NUMBER,version_num1 IN NUMBER,
                           assignment_id1 IN NUMBER,element_type_id1 IN NUMBER,
                           gl_poeta1 IN g_gl_poeta%ROWTYPE, total_amount1 IN NUMBER)
   ---   The following private function checks to see if combination of person, date range,
   ---   Assignment, element type, GL, POETA already exists, for a particular version. If yes,
   ---   the function adds distribution amount already fetched from Distribution lines to
   ---   the TOTAL_AMOUNT column of PSP_EFFORT_REPORT_DETAILS, instead of creating a new row.
   RETURN NUMBER IS
   BEGIN
      BEGIN
         SELECT *
         INTO g_details_row
         FROM psp_effort_report_details
         WHERE effort_report_id = effort_report_id1 AND
               version_num = version_num1 AND
               assignment_id = assignment_id1 AND
               element_type_id = element_type_id1 AND
               NVL(gl_code_combination_id,-99) = NVL(gl_poeta1.gl_code_combination_id,-99) AND
               NVL(project_id,-99) = NVL(gl_poeta1.project_id,-99) AND
               NVL(expenditure_organization_id,-99) = NVL(gl_poeta1.expenditure_organization_id,-99) AND
               NVL(expenditure_type,'-99') = NVL(gl_poeta1.expenditure_type,'-99') AND
               NVL(task_id,-99) = NVL(gl_poeta1.task_id,-99) AND
               NVL(award_id,-99) = NVL(gl_poeta1.award_id,-99) AND
               ROWNUM = 1;
         ---
         g_details_row.TOTAL_AMOUNT := g_details_row.TOTAL_AMOUNT + total_amount1;
         ---
         UPDATE PSP_EFFORT_REPORT_DETAILS
         SET total_amount = g_details_row.TOTAL_AMOUNT
         WHERE effort_report_id = g_details_row.effort_report_id AND
               version_num = g_details_row.version_num AND
               effort_report_line_num = g_details_row.effort_report_line_num;
         IF (SQL%NOTFOUND) THEN
            NULL;
         END IF;
         ---
         RETURN(-1);
      EXCEPTION WHEN NO_DATA_FOUND THEN
         RETURN(0);
      END;
   END;
   ---
   PROCEDURE log_errors(template_id1 IN NUMBER,person_id1 IN NUMBER,errmsg VARCHAR2,
                          effort_report_id1 IN NUMBER, version_num1 IN NUMBER)
   ---  Error Logging Procedure
   IS
   BEGIN
      INSERT INTO PSP_EFFORT_ERRORS(template_id,person_id,message,prev_effort_report_id,
      prev_version_num) values (template_id1,person_id1,errmsg,effort_report_id1,version_num1);
-- enumerated the INSERT list for bug fix 2307100
      ---
      UPDATE PSP_EFFORT_REPORT_TEMPLATES
      SET error_date_time = SYSDATE
      WHERE template_id = template_id1;
      ---
      IF (SQL%NOTFOUND) THEN
         NULL;
      END IF;
      ---
   END;
   ---
   ---
   ---   MAIN FUNCTION
   ---   The following concept is included.
   ---                              Report Hdr        Report Dtls          Effort Errors
   ---    ADHOC    N                    1                  M                    0
   ---    ADHOC    W                    1                  M                    1
   ---    NORMAL   N                    1                  M                    0
   ---    NORMAL   W                    0                  0                    1
   ---
   ---
   PROCEDURE crt(errbuf OUT NOCOPY VARCHAR2,
		 retcode OUT NOCOPY NUMBER,
		 a_template_id IN NUMBER,
		 p_business_group_id IN VARCHAR2,
		 p_set_of_books_id IN VARCHAR2)
   IS

      CURSOR t_DIST (person_id1 NUMBER, sdate DATE, edate DATE) IS
      /* This cursor is based on PST_DISTRIBUTION_LINES_HISTORY ,PSP_PRE_GEN_DIST_LINES_HISTORY and
         PSP_ADJUSTMENT_LINES_HISTORY */
      /*commented out and replaced by new cursor for perf. fix bug 1874615 -- ddubey 12-JUl-2001.
         SELECT D.distribution_line_id,        --- N(10)
                L.person_id person_id,         --- N(9)
                L.assignment_id assignment_id, --- N(9)
                L.element_type_id,             --- N(9)
                D.distribution_date,           --- Date
                NVL(D.distribution_amount,0) distribution_amount,     --- N(22)
                D.effort_report_id,            --- N(9)
                D.status_code,                 --- N(9)
                ---D.version_num,              --- N(9)
                NVL(AUTO_GL_CODE_COMBINATION_ID, TO_NUMBER(NULL)) gl_code_combination_id, -- Ravindra
                TO_NUMBER(NULL) project_id,
                TO_NUMBER(NULL) expenditure_organization_id,
                NVL(AUTO_EXPENDITURE_TYPE, NULL) expenditure_type, -- Ravindra
                TO_NUMBER(NULL) task_id,
                TO_NUMBER(NULL) award_id,
                D.schedule_line_id,         --- N(9)
                D.summary_line_id,          --- N(10)
                D.default_org_account_id,   --- N(9)
                D.suspense_org_account_id,  --- N(9)
                element_account_id,         --- N(9)
                org_schedule_id,            --- N(9)
                'distribution_lines' source
         FROM   psp_distribution_lines_history D,psp_payroll_sub_lines S, psp_payroll_lines L
         WHERE  D.payroll_sub_line_id = S.payroll_sub_line_id AND
                S.payroll_line_id = L.payroll_line_id AND
                D.distribution_DATE between sdate AND edate AND
                L.person_id = person_id1 AND
                NVL(include_in_er_flag,'Y') = 'Y' AND
                NVL(reversal_entry_flag,'N') = 'N'
         UNION
         SELECT pre_gen_dist_line_id,
                person_id,                   --- N(9)
                assignment_id,               --- N(9)
                element_type_id,
                distribution_date,
                NVL(distribution_amount,0),  --- N(22)
                effort_report_id,
                status_code,
                gl_code_combination_id,
                project_id,
                expenditure_organization_id,
                expenditure_type,
                task_id,
                award_id,
                TO_NUMBER(NULL),           --- N(9)
                TO_NUMBER(NULL),           --- N(10)
                TO_NUMBER(NULL),           --- N(9)
                TO_NUMBER(NULL),           --- N(9)
                TO_NUMBER(NULL),           --- N(9)
                TO_NUMBER(NULL),           --- N(9)
                'pre_gen_dist_lines'
         FROM   psp_pre_gen_dist_lines_history
         WHERE  distribution_date between sdate AND edate AND
                person_id = person_id1 AND
                NVL(include_in_er_flag,'Y') = 'Y' AND
                NVL(reversal_entry_flag,'N') = 'N'
         UNION
         SELECT adjustment_line_id,
                person_id,                   --- N(9)
                assignment_id,               --- N(9)
                element_type_id,
                distribution_date,
                NVL(distribution_amount,0),  --- N(22)
                effort_report_id,
                status_code,
                gl_code_combination_id,
                project_id,
                expenditure_organization_id,
                expenditure_type,
                task_id,
                award_id,
                TO_NUMBER(NULL),           --- N(9)
                TO_NUMBER(NULL),           --- N(10)
                TO_NUMBER(NULL),           --- N(9)
                TO_NUMBER(NULL),           --- N(9)
                TO_NUMBER(NULL),           --- N(9)
                TO_NUMBER(NULL),           --- N(9)
                'adjustment_lines'
         FROM   psp_adjustment_lines_history
         WHERE  distribution_date between sdate AND edate AND
                person_id = person_id1 AND
                NVL(include_in_er_flag,'Y') = 'Y' AND
                NVL(reversal_entry_flag,'N') = 'N'
         ---ORDER BY person_id,assignment_id;  Rel 11 Requirement
         ORDER BY 2,3;                                        */
	SELECT pdlh.distribution_line_id,
	psl.person_id,
	psl.assignment_id,
	ppl.element_type_id,
	pdlh.distribution_date,
	decode(ppl.dr_cr_flag, 'C', NVL(-pdlh.distribution_amount,0),
nvl(pdlh.distribution_amount,0))distribution_amount,  -- bug fix 1952627
	pdlh.effort_report_id,
	pdlh.status_code,
	psl.gl_code_combination_id, ---NVL(AUTO_GL_CODE_COMBINATION_ID, TO_NUMBER(NULL)) gl_code_combination_id,
	psl.project_id, ---TO_NUMBER(NULL) project_id,   commented for 5080403
	psl.expenditure_organization_id, ----TO_NUMBER(NULL) expenditure_organization_id,
	psl.expenditure_type, ----NVL(AUTO_EXPENDITURE_TYPE, NULL) expenditure_type,
	psl.task_id, ---TO_NUMBER(NULL) task_id,
	psl.award_id, ---TO_NUMBER(NULL) award_id,
	pdlh.schedule_line_id,
	pdlh.summary_line_id,
	pdlh.default_org_account_id,
	pdlh.suspense_org_account_id,
	element_account_id,
	org_schedule_id,
	'distribution_lines' source
	FROM    psp_distribution_lines_history pdlh,
       	        psp_payroll_sub_lines pps,
         	psp_payroll_lines ppl,
	 	psp_summary_lines psl
         WHERE
                psl.person_id = person_id1 AND
	  	pdlh.summary_line_id = psl.summary_line_id AND
  		psl.status_code||''='A' and
                pdlh.distribution_DATE between sdate  AND edate
                and NVL(pdlh.include_in_er_flag,'Y') = 'Y' AND
                NVL(pdlh.reversal_entry_flag,'N') = 'N' AND
		pdlh.adjustment_batch_name is null
        and 	pdlh.payroll_sub_line_id= pps.payroll_sub_line_id
        and 	pps.payroll_line_id=ppl.payroll_line_id
         UNION
         SELECT ppgh.pre_gen_dist_line_id,
                ppgh.person_id,
                ppgh.assignment_id,
                ppgh.element_type_id,
                ppgh.distribution_date,
              decode(ppgh.dr_cr_flag,'C',  NVL(-ppgh.distribution_amount,0),
                   nvl(ppgh.distribution_amount,0))distribution_amount,-- bug fix 1952627
                ppgh.effort_report_id,
                ppgh.status_code,
                psl.gl_code_combination_id,    --- changed from ppgh prefix to
                                              ---psl.. for this line and below 4 lines... for 5080403
                psl.project_id,
                psl.expenditure_organization_id,
                psl.expenditure_type,
                psl.task_id,
                psl.award_id,
                TO_NUMBER(NULL),
                TO_NUMBER(NULL),
                TO_NUMBER(NULL),
                TO_NUMBER(NULL),
                TO_NUMBER(NULL),
                TO_NUMBER(NULL),
                'pre_gen_dist_lines'
         FROM   psp_pre_gen_dist_lines_history ppgh,
                psp_summary_lines psl
         WHERE
                psl.person_id=person_id1 and
                ppgh.summary_line_id=psl.summary_line_id
 	        and psl.status_code||''='A' and
          	ppgh.distribution_date between sdate AND edate  AND
                NVL(ppgh.include_in_er_flag,'Y') = 'Y' AND
                NVL(ppgh.reversal_entry_flag,'N') = 'N' AND
		ppgh.adjustment_batch_name is null
         UNION
         SELECT palh.adjustment_line_id,
                palh.person_id,
                palh.assignment_id,
                palh.element_type_id,
                palh.distribution_date,
                decode(palh.dr_cr_flag, 'C',NVL(-palh.distribution_amount,0),
          NVL(palh.distribution_amount, 0))distribution_amount, -- bug fix 1952627
                palh.effort_report_id,
                palh.status_code,
                palh.gl_code_combination_id,
                palh.project_id,
                palh.expenditure_organization_id,
                palh.expenditure_type,
                palh.task_id,
                palh.award_id,
                TO_NUMBER(NULL),
                TO_NUMBER(NULL),
                TO_NUMBER(NULL),
                TO_NUMBER(NULL),
                TO_NUMBER(NULL),
                TO_NUMBER(NULL),
                'adjustment_lines'
         FROM   psp_adjustment_lines_history palh,
                psp_summary_lines psl
         WHERE
           psl.person_id=person_id1 and
           palh.summary_line_id=psl.summary_line_id and
	   psl.status_code||''='A' and
           palh.distribution_date between sdate AND edate  AND
           NVL(palh.include_in_er_flag,'Y') = 'Y' AND
           NVL(palh.reversal_entry_flag,'N') = 'N' AND
	   nvl(original_line_flag, 'N') = 'N'
           and palh.adjustment_batch_name is null
         ORDER BY 2,3;
      t_DIST_row    t_DIST%ROWTYPE;
      ---
      -- This cursor finds list of all the persons in a people group, or under a supervisor
      -- or charged to a particular gl account, project, award or expenditure organization
      -- for a given effort report period
      --
      CURSOR t_all_person_id  IS
       /* replaced by new cursor for perf. fix for bug 1874615
         SELECT distinct F.person_id,to_date(NULL) effective_start_date,to_date(NULL) effective_end_date
         FROM  psp_effort_report_templates E,
               per_assignments_f F
         WHERE NVL(E.people_group_id, NVL(F.people_group_id,-99)) = NVL(F.people_group_id,-99) AND
                NVL(E.supervisor_id, NVL(F.supervisor_id,-99)) = NVL(F.supervisor_id,-99) AND
                E.template_id = a_template_id AND
                E.person_id IS NULL AND
                exists (SELECT 'x'
                        FROM PSP_DISTRIBUTION_COMBO_V V
                        WHERE V.person_id = F.person_id AND
                              V.distribution_date between E.begin_date and E.end_date )
         UNION
         SELECT P.person_id,P.effective_start_date,P.effective_end_date
         FROM psp_effort_report_templates P
         WHERE template_id = a_template_id AND
               P.person_id IS NOT NULL AND
               exists (SELECT 'x'
                       FROM PSP_DISTRIBUTION_COMBO_V V
                       WHERE V.person_id = P.person_id AND
                             V.distribution_date between P.begin_date and P.end_date ); */
 	SELECT DISTINCT
 	 psl.person_id,
	 to_date(NULL)
         effective_start_date,
	to_date(NULL) effective_end_date
         FROM
               per_all_assignments_f paf,
               psp_Summary_lines psl,
               psp_effort_report_templates pet
         WHERE
	(pet.template_id=a_template_id and
	pet.person_id is null and
        (
	   ((paf.people_group_id        = pet.people_group_id
	OR paf.supervisor_id          = pet.supervisor_id)
-- Added for Bug Fix 2892637  by tbalacha
 AND (paf.effective_start_date <= pet.end_date AND paf.effective_end_date >= pet.begin_date))
--End of code for Bug 2892637
        -- Start bug fix:1988747 by Ritesh on Sep 12, 2001
        OR psl.gl_code_combination_id = pet.gl_code_combination_id
        OR psl.project_id IN (SELECT project_id FROM psp_template_projects
			      WHERE  template_id = a_template_id)
        OR psl.award_id IN (SELECT award_id FROM psp_template_awards
			    WHERE  template_id = a_template_id)
        OR psl.expenditure_organization_id IN (SELECT expenditure_organization_id FROM psp_template_organizations
						WHERE template_id = a_template_id)
        -- End bug fix:1988747
        )
	and
	psl.person_id =paf.person_id
        AND paf.assignment_type ='E'   --Added for bug 2624259.
	and psl.status_code||''='A'
	and
      exists
	(
		SELECT summary_line_id
		FROM psp_distribution_lines_history pdlh
		WHERE
		pdlh.summary_line_id=psl.summary_line_id and
		pdlh.distribution_date
		between
		pet.begin_date
		and
		pet.end_date
		and nvl(INCLUDE_IN_ER_FLAG,'Y')='Y' and
		nvl(REVERSAL_ENTRY_FLAG,'N')='N'
		UNION ALL
		SELECT summary_line_id
		FROM  psp_adjustment_lineS_history palh
          	 WHERE
		palh.summary_line_id=psl.summary_line_id and
		palh.distribution_date
   		BETWEEN pet.begin_date  AND pet.end_date
		and nvl(INCLUDE_IN_ER_FLAG,'Y')='Y' and
		nvl(REVERSAL_ENTRY_FLAG,'N')='N'
		UNION ALL
		SELECT summary_line_id
		FROM psp_pre_gen_dist_lines_history ppgh where
		ppgh.summary_line_id=psl.summary_line_id and
		ppgh.distribution_date
  		BETWEEN pet.begin_date  AND pet.end_date
		and nvl(INCLUDE_IN_ER_FLAG,'Y')='Y' and
		nvl(REVERSAL_ENTRY_FLAG,'N')='N'))

	UNION

	SELECT
	pet.person_id,
	pet.effective_start_date,
	pet.effective_end_date
	FROM psp_Summary_lines psl,
	psp_effort_report_templates pet
         WHERE
	pet.template_id=a_template_id and
	pet.person_id=psl.person_id and
	pet.person_id is not null
	and psl.status_code||''='A'
	and exists
	(
		SELECT summary_line_id
		FROM psp_distribution_lines_history pdlh
		WHERE
		pdlh.summary_line_id=psl.summary_line_id and
		pdlh.distribution_date
		BETWEEN
		pet.begin_date
		and
		pet.end_date
		and nvl(INCLUDE_IN_ER_FLAG,'Y')='Y' and
		nvl(REVERSAL_ENTRY_FLAG,'N')='N'
		UNION ALL
		SELECT summary_line_id
		FROM psp_adjustment_lines_history palh
		WHERE
		palh.summary_line_id=psl.summary_line_id and
		palh.distribution_date
  		BETWEEN pet.begin_date  and pet.end_date
		and nvl(INCLUDE_IN_ER_FLAG,'Y')='Y' and
		nvl(REVERSAL_ENTRY_FLAG,'N')='N'
		UNION ALL
		SELECT summary_line_id
		FROM psp_pre_gen_dist_lines_history ppgh
		WHERE
		ppgh.summary_line_id=psl.summary_line_id and
		ppgh.distribution_date
  	 	BETWEEN pet.begin_date  AND pet.end_date
		and nvl(INCLUDE_IN_ER_FLAG,'Y')='Y' and
		nvl(REVERSAL_ENTRY_FLAG,'N')='N');
        ----
      CURSOR determine_version_num(person_id1 IN NUMBER,begin_date1 IN DATE,
                                   end_date1 IN DATE,report_type1 IN VARCHAR2) IS
          SELECT version_num + 1,effort_report_id ----NVL(MAX(version_num) + 1,1)
          FROM psp_effort_reports P, psp_effort_report_templates T
          WHERE P.person_id = person_id1 AND ---person_id has no effective dt in Assignments
                P.template_id = T.template_id AND
                ((begin_date1 BETWEEN T.begin_date AND T.end_date) OR
                 (end_date1 BETWEEN T.begin_date AND T.end_date) OR
                 (begin_date1 <= T.begin_date AND end_date1 >= T.end_date)) AND
                T.report_type = report_type1
          ORDER BY version_num + 1 DESC;
      ----
      CURSOR t_warning_report_exists(person_id1 IN NUMBER,begin_date1 IN DATE, end_date1 IN DATE) IS
          SELECT decode(upper(status_code),'S','N','R', 'N', 'W'),
                 E.effort_report_id,E.version_num
          ---INTO t_status_code,t_prev_effort_report_id,t_prev_version_num
          FROM PSP_EFFORT_REPORTS E, PSP_EFFORT_REPORT_TEMPLATES T
          WHERE E.person_id = person_id1 AND        --- person_id has no effective dt in Assignments
              ((begin_date1 BETWEEN T.begin_date AND T.end_date) OR
               (end_date1 BETWEEN T.begin_date AND T.end_date) OR
               (begin_date1 <= T.begin_date AND end_date1 >= T.end_date)) AND
                E.template_id = T.template_id AND
                ---g_template_row.report_type = 'N' AND
                T.report_type = 'N'
          ORDER BY status_code;
      ---
      CURSOR t_get_no_csr IS
         SELECT COUNT(*)
         FROM   psp_effort_reports
         WHERE  template_id = a_template_id;
      ---
       CURSOR t_errors IS
         SELECT message
         FROM PSP_EFFORT_ERRORS
         WHERE template_id = a_template_id AND
               person_id = 0
         UNION
         SELECT message
         FROM PSP_EFFORT_ERRORS
         WHERE template_id = a_template_id AND
               message not like 'Effort Rep%' AND
               message not like 'Status Code%';
      ---
      t_dummy                    VARCHAR2(1);
      t_no_records	         NUMBER(6);
      t_rowid                    VARCHAR2(30);
      t_reqid                    NUMBER(15);
      t_prev_effort_report_id    NUMBER(9);
      t_version_number           NUMBER(2);
      t_prev_version_num         NUMBER(2);
      t_effort_report_id         NUMBER(9);
      t_effort_report_line_num   NUMBER(15);
      t_authorized_person_id     NUMBER(15);
      t_status_code              VARCHAR2(30);
      t_ERROR_set                VARCHAR2(1);
      t_total_errors             NUMBER(2);
      t_message                  VARCHAR2(255);
      t_project                  NUMBER(2);
      t_award                    NUMBER(2);
      t_org                      NUMBER(2);
      nc                         NUMBER;
      errbuf1                    VARCHAR2(1999);
      NO_GL_MATCHES_FOUND        EXCEPTION;
      NO_POETA_MATCHES_FOUND     EXCEPTION;
      ELEMENT_TYPE_NO_INCLUDE    EXCEPTION;
      STATUS_CODE_IS_T           EXCEPTION;
      ---

   BEGIN
--      dbms_output.enable(1000000);
      IF p_template_exists(a_template_id) <> 0 THEN
         log_errors(a_template_id,0,'Template '||TO_CHAR(a_template_id) || ' Does Not Exist',0,0);
         ---RAISE FND_API.g_exc_unexpected_error;
      END IF;
      ---
      ---
      FOR t_PERS_rec IN t_all_person_id LOOP
         --- Check if a Normal Effort report has already been taken for that Template period,
         --- For that person.
         t_status_code := NULL;
         OPEN t_warning_report_exists(t_PERS_rec.person_id ,g_template_row.begin_date,
                                      g_template_row.end_date);
            FETCH t_warning_report_exists INTO t_status_code,t_prev_effort_report_id,t_prev_version_num;
         CLOSE t_warning_report_exists;
         ---
        /*
         SELECT decode(upper(status_code),'S','N','W'),
                E.effort_report_id,E.version_num
         INTO t_status_code,t_prev_effort_report_id,t_prev_version_num
         FROM PSP_EFFORT_REPORTS E, PSP_EFFORT_REPORT_TEMPLATES T
         WHERE E.person_id = t_PERS_rec.person_id AND  --- person_id has no effective dt in Assignments
             ((g_template_row.begin_date BETWEEN T.begin_date AND T.end_date) OR
              (g_template_row.end_date BETWEEN T.begin_date AND T.end_date) OR
              (g_template_row.begin_date <= T.begin_date AND g_template_row.end_date >= T.end_date)) AND
               E.template_id = T.template_id AND
               ---g_template_row.report_type = 'N' AND
               T.report_type = 'N' AND
               ROWNUM = 1;
        */
         IF t_status_code IS NOT NULL THEN
            ---
            ---  If , For A Given Adhoc Report, old Adhoc Report(s) Exists For An Exact Match Of
            ---  Person_id, Report Begin And End Dates, delete all corresponding row(s), from
            ---  all concerned tables.
            ---
            IF g_template_row.report_type = 'A' THEN
               p_old_adhoc_delete(a_template_id,t_PERS_rec.person_id,
                                  g_template_row.begin_date,g_template_row.end_date);
            END IF;
            ---
            IF t_status_code = 'W' THEN
               --- Set the Warning Flag to 'Y', if any one of the status code was not 'N'ew.
               t_ERROR_set := 'Y';
            END IF;
            ---
            --- Generate Warning Reports For Normal And Adhoc Both. 4/28/98
            ---
            FND_MESSAGE.set_name('PSP','PSP_EFT_REPORT_EXISTS');
            FND_MESSAGE.set_token('PERSID', to_char(t_PERS_rec.person_id));
            FND_MESSAGE.set_token('ASSIGN', to_char(t_DIST_row.assignment_id));
            FND_MESSAGE.set_token('DISTDT', to_char(t_DIST_row.distribution_date,'MM/DD/YY'));
            FND_MESSAGE.set_token('REPID',to_char(t_DIST_row.effort_report_id));
            log_errors(a_template_id,t_PERS_rec.person_id,FND_MESSAGE.GET,
                       t_prev_effort_report_id,t_prev_version_num);
         ELSE
            t_status_code := 'N';     --- See High Level Design Doc.
         END IF;
         ---
         --- Insert One row in PSP_EFFORT_REPORTS for each person selected.
         --- Increment Version No. by 1 if for a given person and date range, there is an
         --- existing report . Do Not Create new records , if the report type is (N)ormal
         --- and the status is 'W'arning.  */
         ---
         IF NOT(g_template_row.report_type = 'N' AND t_status_code = 'W') THEN
            t_version_number := 1;
            OPEN determine_version_num(t_PERS_rec.person_id,g_template_row.begin_date,
                                       g_template_row.end_date,g_template_row.report_type);
               FETCH determine_version_num INTO t_version_number,t_effort_report_id;
            CLOSE determine_version_num;
            ----
            ----
            IF t_version_number = 1 THEN
               SELECT psp_effort_reports_s.NEXTVAL
               INTO t_effort_report_id
               FROM DUAL;
            END IF;
            ---
            PSP_EFFORT_REPORTS_PKG.insert_row (
               t_rowid,
               t_effort_report_id,                        --- in NUMBER,
               t_version_number,                          --- in NUMBER,
               t_PERS_rec.person_id,                      --- in NUMBER,
               t_PERS_rec.effective_start_date,
               t_PERS_rec.effective_end_date,
               SYSDATE,                                   --- X_VERSION_CREATION_DATE in DATE,
               NULL,                                      --- X_VERSION_REASON_CODE in VARCHAR2,
               NULL,                                      --- X_MESSAGE_ID
               NULL,                                      --- X_REPORT_COMMENT in VARCHAR2,
               SYSDATE,
               t_status_code,                             --- X_STATUS_CODE in VARCHAR2,
               a_template_id,
               t_prev_effort_report_id,
	       p_business_group_id,
	       p_set_of_books_id,
               'R');
         END IF;
         ---
         /* Open Distribution Line Cursor and Select rows for given criterias  */
         ---
         OPEN t_DIST(t_PERS_rec.person_id,g_template_row.begin_date,g_template_row.end_date);
            LOOP
               FETCH t_DIST INTO t_DIST_row;
                  EXIT WHEN t_DIST%NOTFOUND;
                g_dist_flag := 'Y';
                --- Derive POETA logic
/*  --- commentee for 5080403
                IF t_DIST_row.source = 'distribution_lines' THEN
                   g_ssdseo_row.schedule_line_id := t_DIST_row.schedule_line_id;
                   g_ssdseo_row.default_org_account_id := t_DIST_row.default_org_account_id;
                   g_ssdseo_row.suspense_org_account_id := t_DIST_row.suspense_org_account_id;
                   g_ssdseo_row.element_account_id := t_DIST_row.element_account_id;
                   g_ssdseo_row.org_schedule_id := t_DIST_row.org_schedule_id;
                   ---
                   ----g_poeta_row := p_get_POETA(a_template_id,t_PERS_rec.person_id,g_ssdseo_row);  commented for 5080403


 --    Bug fix 4511284
                 If g_poeta_row.gl_code_combination_id is not null then
                    g_poeta_row.gl_code_combination_id:= nvl(t_DIST_row.gl_code_combination_id,g_poeta_row.gl_code_combination_id);
                 ELSE
                   g_poeta_row.expenditure_type:= nvl(t_DIST_row.expenditure_type,g_poeta_row.expenditure_type);
                 END IF;
-- End of Bug fix 4511284


                ELSE */
                   g_poeta_row.gl_code_combination_id := t_DIST_row.gl_code_combination_id;
                   g_poeta_row.project_id := t_DIST_row.project_id;
                   g_poeta_row.expenditure_organization_id := t_DIST_row.expenditure_organization_id;
                   g_poeta_row.expenditure_type := t_DIST_row.expenditure_type;
                   g_poeta_row.task_id := t_DIST_row.task_id;
                   g_poeta_row.award_id := t_DIST_row.award_id;
                ----END IF; commented for 5080403
                ---
                --- Check Whether Status Code In Distribution Lines = 'T'.
                --- Check From psp_element_types whether to include Element Type Or Not.
                --- Do matching of GL, POETA with templates
                BEGIN
                   --- If The Status Code In Distribution Lines Is T, Then Generate Warning
                   --- Report For That Person.
                   IF NVL(t_DIST_row.status_code,'0') = 'T' THEN
                      DELETE FROM PSP_EFFORT_REPORTS
                      WHERE person_id = t_PERS_rec.person_id AND
                            template_id = a_template_id;
                      IF (SQL%NOTFOUND) THEN
                         NULL;
                      END IF;
                      ---
                      BEGIN
                         SELECT 'x'
                         INTO t_dummy
                         FROM PSP_EFFORT_ERRORS
                         WHERE template_id = a_template_id AND
                               person_id = t_PERS_rec.person_id AND
                               ROWNUM = 1;
                      EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            log_errors(a_template_id,t_PERS_rec.person_id,
                                         'Status Code = T ',NULL,NULL);
                      END;
                      RAISE STATUS_CODE_IS_T;
                   END IF;
                   ---
--	Introduced BG/SOB parameters in p_element_exists call for bug fix 3098050
                   IF p_element_exists(t_DIST_row.element_type_id,t_DIST_row.distribution_date,
				p_business_group_id, p_set_of_books_id) <> 0 THEN
                      RAISE ELEMENT_TYPE_NO_INCLUDE;
                   END IF;
                   ----

/*****	Commented the following for bug fix 3063762, as POETA/GL check is for filtering persons and not distributions.
                   IF g_template_row.gl_code_combination_id IS NOT NULL THEN    -- TEMPLATE   DIST   RESULT
                      IF NOT(NVL(g_template_row.gl_code_combination_id,         --   NULL     NULL   Select
                             NVL(g_poeta_row.gl_code_combination_id,-99)) =     --   NULL    Value   Select
                             NVL(g_poeta_row.gl_code_combination_id,-99)) THEN  --  Value     NULL  NoSelect
                                                                                --   Value =  Value   Select
                         RAISE NO_GL_MATCHES_FOUND;                             --   Value <> Value NoSelect
                      END IF;
                   ---
                   ELSE
                      t_project := p_project_exists(a_template_id,g_poeta_row.project_id);
                      t_award := p_award_exists(a_template_id,g_poeta_row.award_id);
                      t_org := p_org_exists(a_template_id,g_poeta_row.expenditure_organization_id) ;
                      ----
                      IF NOT ((t_project = 0 AND t_org = 0 AND t_award = 0) OR
                              (t_project = 1 AND t_org = 0 AND t_award = 0) OR
                              (t_project = 0 AND t_org = 1 AND t_award = 0) OR
                              (t_project = 0 AND t_org = 0 AND t_award = 1) OR
                              (t_project = 1 AND t_org = 1 AND t_award = 0) OR
                              (t_project = 0 AND t_org = 1 AND t_award = 1) OR
                              (t_project = 1 AND t_org = 0 AND t_award = 1) OR
                              (t_project = 1 AND t_org = 1 AND t_award = 1))THEN
                         RAISE NO_POETA_MATCHES_FOUND;
                      END IF;
                   END IF;

	End of bug fix 3063762	*****/

                   ---
                   ---
                   --- Check to see whether Effort Report Already taken
                   ---
                   IF t_DIST_row.effort_report_id IS NOT NULL THEN
                      ----
                      --- Do Not use PSP_EFFORT_REPORTS_PKG.update_row Table Handler For The
                      --- Following Update Statement , as it has a implicit COMMIT, used by
                      --- PSPERCER Form.
                      ---
                      UPDATE psp_effort_reports
                      SET prev_effort_report_id = t_DIST_row.effort_report_id
                      WHERE effort_report_id = t_effort_report_id AND
                            version_num = t_version_number;
                      ---
                      IF (SQL%NOTFOUND) THEN
                         NULL;
                      END IF;
                   END IF;
                   ---
                   --- Insert in  psp_effort_report_details rows which passed the criteria
                   ---
                   IF p_sync_details(t_effort_report_id,t_version_number,
                                     t_DIST_row.assignment_id,t_DIST_row.element_type_id,
                                     g_poeta_row,
                                     t_DIST_row.distribution_amount) <> 0 THEN
                      RAISE NO_DATA_FOUND;
                   END IF;
/*
if g_poeta_row.project_id is  not null  then
--dbms_output.put_line('GL='||to_char(g_poeta_row.gl_code_combination_id)||
                     'P='||to_char(g_poeta_row.project_id) ||
                     'O='||to_char(g_poeta_row.expenditure_organization_id)||
                     'E='|| g_poeta_row.expenditure_type ||
                     'T='|| to_char(g_poeta_row.task_id) ||
                     'A='||to_char(g_poeta_row.award_id) ||
                      'PERSON='||t_pers_rec.person_id ||
                      'source='||t_dist_row.source ||
                       'dist_id='||t_dist_row.distribution_line_id);
end if;
*/
                   ---
                   --- Do not create rows in Report Details, if the report type is (N)ormal
                   --- and status_code is 'W'arning.
                   ---
                   IF NOT(g_template_row.report_type = 'N' AND t_status_code = 'W') THEN
                      SELECT NVL(MAX(effort_report_line_num) + 1,1)
                      INTO t_effort_report_line_num
                      FROM psp_effort_report_details
                      WHERE effort_report_id = t_effort_report_id AND
                            version_num = t_version_number;
                      ---
                      PSP_EFFORT_REPORT_DETAILS_PKG.insert_row (
                         t_rowid,                                 --- in out NOCOPY VARCHAR2,
                         t_effort_report_id,                      --- in NUMBER,
                         t_version_number,                        --- in NUMBER,
                         t_effort_report_line_num,                --- in NUMBER,
                         t_DIST_row.assignment_id,                --- in NUMBER,
                         t_DIST_row.element_type_id,
                         g_poeta_row.gl_code_combination_id,      --- in NUMBER,
                         g_poeta_row.project_id,                  --- in NUMBER,
                         g_poeta_row.expenditure_organization_id, --- in NUMBER,
                         g_poeta_row.expenditure_type,            --- X_EXPENDITURE_TYPE in VARCHAR2,
                         g_poeta_row.task_id,                     --- X_TASK_ID in NUMBER,
                         g_poeta_row.award_id,                    --- in NUMBER,
                         t_DIST_row.distribution_amount,          --- in NUMBER,
                         'R');
                   END IF;
                   ---
                   IF t_DIST_row.source = 'distribution_lines' and g_template_row.report_type = 'N' THEN
                      UPDATE psp_distribution_lines_history
                      SET effort_report_id = NVL(t_effort_report_id,t_prev_effort_report_id)
                      WHERE distribution_line_id = t_DIST_row.distribution_line_id;
                   ELSIF t_DIST_row.source = 'pre_gen_dist_lines' and g_template_row.report_type = 'N' THEN
                      UPDATE psp_pre_gen_dist_lines_history
                      SET effort_report_id = NVL(t_effort_report_id,t_prev_effort_report_id)
                      WHERE pre_gen_dist_line_id = t_DIST_row.distribution_line_id;
                   ELSIF t_DIST_row.source = 'adjustment_lines' and g_template_row.report_type = 'N' THEN
                      UPDATE psp_adjustment_lines_history
                      SET effort_report_id = NVL(t_effort_report_id,t_prev_effort_report_id)
                      WHERE adjustment_line_id = t_DIST_row.distribution_line_id;
                   END IF;
                   ---
                   IF (SQL%NOTFOUND) THEN
                      NULL;
                   END IF;
                   ---
                EXCEPTION
                   WHEN ELEMENT_TYPE_NO_INCLUDE THEN
                      --dbms_output.put_line('ELEMENT_TYPE_NO_INCLUDE Exception Raised');
                  NULL;
                   WHEN NO_DATA_FOUND THEN
                   --   dbms_output.put_line('NO_DATA_FOUND Exception Raised');
                   NULL;
                   WHEN NO_GL_MATCHES_FOUND THEN
                    --  dbms_output.put_line('NO_GL_MATCHES_FOUND Exception Raised');
                   NULL;
                   WHEN NO_POETA_MATCHES_FOUND THEN
                    --  dbms_output.put_line('NO_POETA_MATCHES_FOUND Exception Raised');
                   NULL;
                   WHEN STATUS_CODE_IS_T THEN
                  --    dbms_output.put_line('STATUS_CODE_IS_T Exception Raised');
                  NULL;
                END;
            END LOOP;
         CLOSE t_DIST;
         ---
         --- Delete Header in case there were no details selected for a row in PSP_EFFORT_REPORTS
         ---
         IF p_effort_details_exists(t_effort_report_id,t_version_number) = -7 THEN
            DELETE FROM PSP_EFFORT_REPORTS
            WHERE effort_report_id = t_effort_report_id AND
                  version_num = t_version_number;
            IF (SQL%NOTFOUND) THEN
               NULL;
            END IF;
         END IF;
         ---
      END LOOP;
      ---
      --- Logging All Errors Encountered into ERRBUF.
      ---
      OPEN t_errors;
         LOOP
            FETCH t_errors INTO t_message;
            EXIT WHEN t_errors%NOTFOUND;
            IF NVL(length(errbuf1),0) <= 1700 THEN
               errbuf1 := SUBSTR((errbuf1 ||fnd_global.local_chr(10) || t_message),1,1700);
            END IF;
         END LOOP;
      CLOSE t_errors;
      ---
      ---   Report Errors :::
      ---
      IF NVL(length(errbuf1),0) <> 0 THEN
         errbuf := SUBSTR(errbuf1,1,230); --- More than 230 , it gives value error
         retcode := 2;                    --- in Oracle Applications.
         RETURN;
      ELSIF g_element_flag = 'N' AND g_dist_flag = 'Y' THEN
         FND_MESSAGE.set_name('PSP','PSP_NO_MATCHING_ELEMENTS');
         errbuf1 := FND_MESSAGE.get;
         errbuf := SUBSTR(errbuf1,1,230); --- More than 230 , it gives value error
     --dbms_output.put_line('The Element Type(s) Are Not Set Up in PSP_EFFORT_REPORT_ELEMENTS' );
         retcode := 2;
         ---RETURN;
      ELSIF g_dist_flag = 'N' THEN
         FND_MESSAGE.set_name('PSP','PSP_NO_DISTRIBUTIONS');
         errbuf1 := FND_MESSAGE.get;
         errbuf := SUBSTR(errbuf1,1,230); --- More than 230 , it gives value error
         --dbms_output.put_line('No Distribution Lines were picked up for chosen criteria' );
         retcode := 2;
         ---RETURN;
      ELSE
         retcode := 0;
      END IF;
      ---
      COMMIT;
      ---
      ---  Submit Warning Report Program Concurrent Request.
      ---
      IF NVL(t_ERROR_set,'N') = 'Y' THEN
         t_reqid := FND_REQUEST.submit_request('PSP',
                                               'PSPERERR',NULL,NULL,NULL,
                                                a_template_id);
         --dbms_output.put_line('Warning Report Kicked...');
      END IF;
      ---
      ---  Initiate Workflow  ::: Introduced by Venkat.
      ---
      OPEN t_get_no_csr;
         FETCH t_get_no_csr INTO t_no_records;
         IF t_get_no_csr%NOTFOUND or NVL(t_no_records,0) = 0 then
            NULL;
         ELSE
            IF NVL(g_template_row.enable_workflow_flag,'N') = 'Y' THEN
--------------------------------------------------------------------------------------------------------
--4/15/99	 Shu Lei added.
--If user option PSP:Effort Cert. Enhanced Workflow is YES, then invoke workflow engine, else use the
--old workflow.
--------------------------------------------------------------------------------------------------------
--              dbms_output.put_line('user profile PSP_EFFORT_REPORT_WORKFLOW ='||p_workflow_option);
--              IF (p_workflow_option = 'V1') THEN
--                dbms_output.put_line('Version 1 of Workflow......');
--                nc := INIT_WORKFLOW(a_template_id);
--              ELSIF (p_workflow_option = 'ENHANCED') THEN
--                dbms_output.put_line('Enhanced Workflow......');
 	        nc := psp_wf_eff_pkg.INIT_WORKFLOW(a_template_id);
--	      END IF;
---------------------------------------------------------------------------------------------------------
               IF nc = -1 THEN
                  FND_MESSAGE.set_name('PSP','PSP_WORKFLOW_FAILED');
                  ---errbuf1 := SUBSTR(errbuf1 || chr(10) ||FND_MESSAGE.get,1999);
                  errbuf1 := SUBSTR(FND_MESSAGE.get,1,1999);
                  errbuf :=  SUBSTR(errbuf1,1,230);
                  retcode := 2;
                  --dbms_output.put_line('WorkFlow Process Failed :: NO_DATA_FOUND');
                  RETURN;
               ELSIF nc = -2 THEN
                  FND_MESSAGE.set_name('PSP','PSP_WORKFLOW_FAILED');
                  ---errbuf1 := SUBSTR(errbuf1 || chr(10) ||FND_MESSAGE.get,1999);
                  errbuf1 := SUBSTR(FND_MESSAGE.get,1,1999);
                  errbuf :=  SUBSTR(errbuf1,1,230);
                  retcode := 2;
                  --dbms_output.put_line('Workflow Process Failed :: FATAL ERROR');
                  RETURN;
               END IF;
            END IF;
         END IF;
      CLOSE t_get_no_csr;
   END;
   ---
   ---
   FUNCTION get_gl_description(a_code_combination_id IN NUMBER) RETURN VARCHAR2
   IS
   t_name   VARCHAR2(1000);
   set_of_bks_id	varchar2(15);
   BEGIN
	set_of_bks_id := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
       t_name := PSP_GENERAL.get_gl_description(set_of_bks_id, a_code_combination_id);
       RETURN(t_name);
   END;
   ---
   ---
   FUNCTION INIT_WORKFLOW(a_template_id IN NUMBER)
   --- This procedure is to initiate workflow process
   --- This procedure fetches all reportids for a given template id ad
   --- Initiates workflow process for each report id
   RETURN NUMBER
   IS
   CURSOR get_report_id_csr IS
      SELECT effort_report_id , max(version_num)
      FROM   psp_effort_reports
      WHERE  template_id	= a_template_id
      GROUP BY effort_report_id;

   l_user_name    VARCHAR2(240);  -- Bug 7004679

   l_report_id	NUMBER;
   l_wf_report_id   VARCHAR2(30);
-- Adding these variables and make the effort report id sent to wf unique 08.31.99
   l_report_id1 NUMBER;
   l_max_ver	NUMBER;
--End 8.31.99

   BEGIN
     OPEN get_report_id_csr;
     LOOP
       FETCH get_report_id_csr INTO l_report_id, l_max_ver;
       EXIT WHEN get_report_id_csr%NOTFOUND;
-- 8.31.99
       l_report_id1 := to_char(l_report_id) || to_char(l_max_ver);
       l_wf_report_id 	:= l_report_id1;
-- End 8.31.99

       l_user_name := fnd_global.user_name;   -- Bug 7004679

       wf_engine.createprocess('INF_EMP',
                               l_wf_report_id,
                               'PROC_EMP');

     /*Added for bug 7004679 */
       wf_engine.setitemowner('INF_EMP',
                               l_wf_report_id,
                               l_user_name);


       wf_engine.startprocess('INF_EMP',
                               l_wf_report_id);
     END LOOP;
     CLOSE get_report_id_csr;
     RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(-1);
      WHEN OTHERS THEN
         RETURN(-2);
   END init_workflow;
END;

/
