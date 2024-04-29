--------------------------------------------------------
--  DDL for Package Body PA_MAINT_PROJECT_ACCUMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MAINT_PROJECT_ACCUMS" AS
/* $Header: PAACACTB.pls 120.3.12010000.2 2008/08/27 18:24:07 jngeorge ship $ */

-- Change History :
--
-- APR-09-99	S Sanckar	Rollup logic changed
-- APR-12-99    Shanif          Rollup logic modified for Performance improvement
-- MAY-19-00    Mohnish     Included the changes sent by Shanif for fixing bug 1221390, going to GL_PERIOD_STATUSES instead of PA_PERIODS_V for GL impl_opt
-- MAY-19-00    Mohnish     Ported changes for 1265148 from R11.0
--                          Added wbs_level to the 2 cursors Res_accum_Cur and
--                          PA_Txn_Accum_Cur. Added wbs_level to the order by
--                          of both for fixing bug 1265148
--
---
---  15-OCT-2001     jwhite     Changed application_id = 101 to
---                             =pa_period_process_pkg.application_id
---
---   19-Sep-2002    Rajnish    change is made in procedure Process_Txn_Accum.
---                             BUg 2569461: In  all the cursors,in the statment
----                            gps.application_id =decode(x_impl_opt,'PA',275,'GL',pa_period_process_pkg.application_id)
---                             275 is replaced with
---                              decode(x_impl_opt,'PA',decode(PA_Period_Process_PKG.Use_Same_PA_GL_Period,'Y',
---                                 pa_period_process_pkg.application_id,'N',275),'GL',pa_period_process_pkg.application_id)
---  29-nov-2002    sramesh    Added the profile option check pa:debug for the pa_debug calls
--
--   16-JAN-2003     jwhite    Bug#2753251
--                             Problem Description:
--                               1) The comparative period processing logic in this
--                                  package did not make a distinction as to  whether
--                                  summarization was processing for GL or PA periods.
--
--                                  The logic simply matched the GL and PA periods for the
--                                  pa_txn_accum record to the current reporting period. If EITHER
--                                  period equated to the current reportintg period, PTD
--                                  amounts were processed.
--
--                               2) Using transaction import for December 2001 data, the client accidently
--                                  created data with a PA period of 'DEC-2002'. The current reporting period
--                                  was also 'DEC-2002'. So, 2001-year amounts were being summarized
--                                  into the DEC-2002 PTD balance.
--
--                               3) Since loading legacy data may generate the situation created in
--                                  item #2 with regular frequency, the package code should handle this
--                                  corner case.
--
--                              Resolution Description:
--                                This bug fix uses the IN-parameter X_impl_opt to make
--                                a distinction between GL and PA period
--                                processing.
--
---   06-May-2003   sacgupta    Bug 2834359. Change are done in procedure Process_Txn_Accum.
--                              TO_NUMBER(SUBSTR(USERENV('CLIENT_INFO'),1,10)) is passed as value in the
--                              call to the package function PA_Period_Process_PKG.Use_Same_PA_GL_Period
--                              in all the cursors.
--
--    08-Oct-2003   gjain       Bug 3147957: Replaced the usage of TO_NUMBER(SUBSTR(USERENV('CLIENT_INFO'),1,10))
--                              with cursor parameter p_org_id. This paramter is passed on the basis of valus returned
--                              by LTRIM(RTRIM(SUBSTR(USERENV('CLIENT_INFO'),1,10)))
--   03-may-2004    dkala       Added migration_code <> 'N'.
--   07-Mar-2004    sacupta     Bug 4195598. Cursors Res_accum_Cur and PA_Txn_Accum_Cur are modified
--                              in procedure PROCESS_TXN_ACCUM. The reference to GL_PERIOD_STATUSES
--                              table is replaced by GL_PERIODS. Accordingly the condition to join
--                              this table with PA_IMPLEMENTATIONS has changed. Now period_set_name
--                              and period_type is used to join GL_PERIODS and PA_IMPLIMENTATIONS
--                              table as against application_id and set_of_books_id that was used
--                              previously to join GL_PERIOD_STATUSES with PA_IMPLEMENTAIONS.
--                              Refer bug for further details.
--
--   05-Aug-2005   sacgupta	   Bug 4532088. Added trunc to the condition trunc(gps.END_DATE) <= x_current_end_date
--                             in procedure Process_Txn_Accum, cursors Res_accum_Cur and PA_Txn_Accum_Cur
--   30-Sep-2005   pkanupar     Bug4631058: In the procedure PROCESS_TXN_ACCUM, in the cursors Res_accum_Cur
--                              and PA_Txn_Accum_Cur, removed the check for 'PERIOD_TYPE' between GL_PERIODS
--                              and PA_IMPLIMENTATIONS.
--   16-Feb-2006   djoseph      Bug 5019025 : In the procedure PROCESS_TXN_ACCUM, in the cursors Res_accum_Cur
--                              and PA_Txn_Accum_Cur, removed the decode that was used to join the period_name
--                              based on the value of x_impl_opt.
--   20-feb-2006   degupta      To port the changes done in 11i file v115.23 to v115.25
--  27-AUG-2008 jngeorge  Bug 6511571: Removed the incorrect fix done for Bug# 5019025
--
TYPE resource_list_id_tabtype IS
TABLE OF PA_RESOURCE_LIST_ASSIGNMENTS.RESOURCE_LIST_ID%TYPE
INDEX BY BINARY_INTEGER;

P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */


  Procedure Process_Txn_Accum  (X_project_id in Number,
                                X_impl_opt  In Varchar2,
                                x_Proj_accum_id   in Number,
                                x_current_period in Varchar2,
                                x_prev_period    in Varchar2,
                                x_current_year   in Number,
                                x_prev_accum_period in Varchar2,
                                x_current_start_date In Date,
                                x_current_end_date  In Date,
				x_actual_cost_flag  In Varchar2,
				x_revenue_flag  In Varchar2,
				x_commitments_flag  In Varchar2,
                                x_resource_list_id  In Number,
                                x_err_stack     In Out NOCOPY Varchar2,
                                x_err_stage     In Out NOCOPY Varchar2,
                                x_err_code      In Out NOCOPY Number ) Is

-- This procedure reads the PA_TXN_ACCUM table and processes all transactions

  -- x_resource_list_id resource_list_id_tabtype;

  v_noof_tasks 		   Number := 0;
  V_task_array 		   task_id_tabtype;

  Curr_task_id 			NUMBER := -99;
  Curr_rlmid 			NUMBER := -99;
  Curr_rlid                     NUMBER := 0;
  Curr_rid                      NUMBER := 0;
  Curr_rlaid                    NUMBER := 0;
  Prev_parent_id                NUMBER := 0;
  Curr_parent_id                NUMBER := 0;
  curr_res_task                 NUMBER := 0;
  create_actuals                VARCHAR2(1) := 'N';
  create_commit                 VARCHAR2(1) := 'N';
  create_wbs_actuals                VARCHAR2(1) := 'N';
  create_wbs_commit                 VARCHAR2(1) := 'N';

  V_Old_Stack       		Varchar2(630);
  x_quantity        		NUMBER :=0;
  x_cmt_quantity        	NUMBER :=0;
  x_billable_quantity 		NUMBER :=0;

  Fetch_task 			BOOLEAN := True;
  Fetch_res  			BOOLEAN := True;

  x_dummy_var			VARCHAR2(1) := NULL;
  V_accum_id			NUMBER	    := 0;
  x_paa_flag			VARCHAR2(1) := 'Y';
  x_pac_flag			VARCHAR2(1) := 'Y';
  x_res_task                    Number := 0;

-- This cursor fetches all resource lists which have already been accumulated
-- for the project.

  CURSOR Reslist_assgmt_Cur is
  Select Distinct
  Resource_list_id
  FROM
  PA_RESOURCE_LIST_ASSIGNMENTS
  WHERE Project_id = X_project_id;

/* Commented the cursor for bug 4195598
-- This cursor fetches the Resource Accum Details

 CURSOR Res_accum_Cur(p_org_id NUMBER) IS --Added p_org_id parameter to the cursor for bug 3147957
 SELECT
  PTA.TXN_ACCUM_ID,
  nvl(PT.parent_task_id,PT.task_id) parent_task_id,
  PTA.TASK_ID task_id,
  PTA.PA_PERIOD,
  PTA.GL_PERIOD,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_REVENUE,0),NVL(PTA.I_TOT_REVENUE,0)) I_TOT_REVENUE,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_RAW_COST,0),NVL(PTA.I_TOT_RAW_COST,0)) I_TOT_RAW_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BURDENED_COST,0),NVL(PTA.I_TOT_BURDENED_COST,0)) I_TOT_BURDENED_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_QUANTITY,0),NVL(PTA.I_TOT_QUANTITY,0)) I_TOT_QUANTITY,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_LABOR_HOURS,0),NVL(PTA.I_TOT_LABOR_HOURS,0)) I_TOT_LABOR_HOURS,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_RAW_COST,0),NVL(PTA.I_TOT_BILLABLE_RAW_COST,0)) I_TOT_BILLABLE_RAW_COST ,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_BURDENED_COST,0),NVL(PTA.I_TOT_BILLABLE_BURDENED_COST,0)) I_TOT_BILLABLE_BURDENED_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_QUANTITY,0),NVL(PTA.I_TOT_BILLABLE_QUANTITY,0))I_TOT_BILLABLE_QUANTITY,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_LABOR_HOURS,0),NVL(PTA.I_TOT_BILLABLE_LABOR_HOURS,0)) I_TOT_BILLABLE_LABOR_HOURS,
  NVL(PTA.TOT_CMT_RAW_COST,0) TOT_CMT_RAW_COST,
  NVL(PTA.TOT_CMT_BURDENED_COST,0) TOT_CMT_BURDENED_COST,
  NVL(PTA.TOT_CMT_QUANTITY,0) TOT_CMT_QUANTITY,
  PTA.actual_cost_rollup_flag,
  PTA.revenue_rollup_flag,
  PTA.cmt_rollup_flag,
  GPS.PERIOD_YEAR,
  Para.RESOURCE_LIST_ASSIGNMENT_ID,
  Para.RESOURCE_LIST_ID,
  Para.RESOURCE_LIST_MEMBER_ID,
  Para.RESOURCE_ID ,
  Parl.TRACK_AS_LABOR_FLAG,
  Par.ROLLUP_QUANTITY_FLAG ,
  Par.UNIT_OF_MEASURE,
  PT.wbs_level
 FROM
  PA_TXN_ACCUM PTA,
  PA_TASKS PT,
  GL_PERIOD_STATUSES GPS,
  PA_IMPLEMENTATIONS PI,
  PA_RESOURCE_ACCUM_DETAILS Para,
  PA_RESOURCES Par,
  PA_RESOURCE_LIST_MEMBERS Parl
 Where  Parl.resource_list_id = nvl(x_resource_list_id,Parl.resource_list_id) and
        Para.Resource_list_id = Parl.Resource_list_id and
        Para.Resource_list_member_id = Parl.Resource_list_member_id and
        Para.Resource_id  = Par.Resource_Id and
 	PTA.Project_Id = x_project_id and
        nvl(parl.migration_code,'-99') <> 'N' and
       (PTA.ACTUAL_COST_Rollup_flag = DECODE(x_Actual_Cost_Flag,'Y','Y','X')
        OR PTA.REVENUE_Rollup_flag = DECODE(x_revenue_Flag,'Y','Y','X')
	OR PTA.CMT_Rollup_flag = DECODE(x_commitments_Flag,'Y','Y','X')
        OR pa_proj_accum_main.x_summ_process = 'RL') and
--    gps.application_id = decode(x_impl_opt,'PA',275,'GL',pa_period_process_pkg.application_id) and
-----     commented and added for bug 2569461
-- Added TO_NUMBER(SUBSTR(USERENV('CLIENT_INFO'),1,10)) for bug 2834359
-- bug 3147957: Replaced TO_NUMBER(SUBSTR(USERENV('CLIENT_INFO'),1,10)) with p_org_id
      gps.application_id = decode(x_impl_opt,'PA',decode(PA_Period_Process_PKG.Use_Same_PA_GL_Period(p_org_id),'Y',
                                  pa_period_process_pkg.application_id,'N',275),'GL',pa_period_process_pkg.application_id) and
    gps.set_of_books_id = pi.set_of_books_id and
    gps.period_name = decode(x_impl_opt,'PA',PTA.pa_period,'GL',PTA.gl_period) and
	gps.END_DATE <= x_current_end_date and
        PT.task_id = PTA.Task_id and
  	Para.Txn_Accum_id = PTA.Txn_Accum_id
union
 select
  PTA.TXN_ACCUM_ID,
  0 parent_task_id,
  0 task_id,
  PTA.PA_PERIOD,
  PTA.GL_PERIOD,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_REVENUE,0),NVL(PTA.I_TOT_REVENUE,0)) I_TOT_REVENUE,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_RAW_COST,0),NVL(PTA.I_TOT_RAW_COST,0)) I_TOT_RAW_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BURDENED_COST,0),NVL(PTA.I_TOT_BURDENED_COST,0)) I_TOT_BURDENED_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_QUANTITY,0),NVL(PTA.I_TOT_QUANTITY,0)) I_TOT_QUANTITY,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_LABOR_HOURS,0),NVL(PTA.I_TOT_LABOR_HOURS,0)) I_TOT_LABOR_HOURS,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_RAW_COST,0),NVL(PTA.I_TOT_BILLABLE_RAW_COST,0)) I_TOT_BILLABLE_RAW_COST ,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_BURDENED_COST,0),NVL(PTA.I_TOT_BILLABLE_BURDENED_COST,0)) I_TOT_BILLABLE_BURDENED_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_QUANTITY,0),NVL(PTA.I_TOT_BILLABLE_QUANTITY,0))I_TOT_BILLABLE_QUANTITY,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_LABOR_HOURS,0),NVL(PTA.I_TOT_BILLABLE_LABOR_HOURS,0)) I_TOT_BILLABLE_LABOR_HOURS,
  NVL(PTA.TOT_CMT_RAW_COST,0) TOT_CMT_RAW_COST,
  NVL(PTA.TOT_CMT_BURDENED_COST,0) TOT_CMT_BURDENED_COST,
  NVL(PTA.TOT_CMT_QUANTITY,0) TOT_CMT_QUANTITY,
  PTA.actual_cost_rollup_flag,
  PTA.revenue_rollup_flag,
  PTA.cmt_rollup_flag,
  GPS.PERIOD_YEAR,
  Para.RESOURCE_LIST_ASSIGNMENT_ID,
  Para.RESOURCE_LIST_ID,
  Para.RESOURCE_LIST_MEMBER_ID,
  Para.RESOURCE_ID ,
  Parl.TRACK_AS_LABOR_FLAG,
  Par.ROLLUP_QUANTITY_FLAG ,
  Par.UNIT_OF_MEASURE,
  0  wbs_level
 FROM
  PA_TXN_ACCUM PTA,
  GL_PERIOD_STATUSES GPS,
  PA_IMPLEMENTATIONS PI,
  PA_RESOURCE_ACCUM_DETAILS Para,
  PA_RESOURCES Par,
  PA_RESOURCE_LIST_MEMBERS Parl
 Where  Parl.resource_list_id = nvl(x_resource_list_id,Parl.resource_list_id) and
        Para.Resource_list_id = Parl.Resource_list_id and
        Para.Resource_list_member_id = Parl.Resource_list_member_id and
        Para.Resource_id  = Par.Resource_Id and
 	PTA.Project_Id = x_project_id and
        nvl(parl.migration_code,'-99') <> 'N' and
       (PTA.ACTUAL_COST_Rollup_flag = DECODE(x_Actual_Cost_Flag,'Y','Y','X')
        OR PTA.REVENUE_Rollup_flag = DECODE(x_revenue_Flag,'Y','Y','X')
	OR PTA.CMT_Rollup_flag = DECODE(x_commitments_Flag,'Y','Y','X')
        OR pa_proj_accum_main.x_summ_process = 'RL') and
--        gps.application_id = decode(x_impl_opt,'PA',275,'GL',pa_period_process_pkg.application_id) and
--     commented and added for bug 2569461
-- Added TO_NUMBER(SUBSTR(USERENV('CLIENT_INFO'),1,10)) for bug 2834359
-- bug 3147957: Replaced TO_NUMBER(SUBSTR(USERENV('CLIENT_INFO'),1,10)) with p_org_id
        gps.application_id = decode(x_impl_opt,'PA',decode(PA_Period_Process_PKG.Use_Same_PA_GL_Period(p_org_id),'Y',
                                  pa_period_process_pkg.application_id,'N',275),'GL',pa_period_process_pkg.application_id) and
        gps.set_of_books_id = pi.set_of_books_id and
        gps.period_name = decode(x_impl_opt,'PA',PTA.pa_period,'GL',PTA.gl_period) and
	gps.END_DATE <= x_current_end_date and
  	Para.Txn_Accum_id = PTA.Txn_Accum_id
  Order By 2,29,3,24; --Parent_Task_id,WBS_Level,Task_id,Para.Resource_List_Member_id;


 CURSOR PA_Txn_Accum_Cur(p_org_id NUMBER) IS   --Added p_org_id parameter to the cursor for bug 3147957
 SELECT DISTINCT
  PTA.TXN_ACCUM_ID,
  nvl(PT.parent_task_id,nvl(pt.task_id,0)) top_task_id,
  PTA.TASK_ID,
  PTA.PA_PERIOD,
  PTA.GL_PERIOD,
  NVL(PTA.I_TOT_REVENUE,0) I_TOT_REVENUE,
  NVL(PTA.I_TOT_RAW_COST,0) I_TOT_RAW_COST,
  NVL(PTA.I_TOT_BURDENED_COST,0) I_TOT_BURDENED_COST,
  NVL(PTA.I_TOT_QUANTITY,0) I_TOT_QUANTITY,
  NVL(PTA.I_TOT_LABOR_HOURS,0) I_TOT_LABOR_HOURS,
  NVL(PTA.I_TOT_BILLABLE_RAW_COST,0) I_TOT_BILLABLE_RAW_COST ,
  NVL(PTA.I_TOT_BILLABLE_BURDENED_COST,0) I_TOT_BILLABLE_BURDENED_COST,
  NVL(PTA.I_TOT_BILLABLE_QUANTITY,0) I_TOT_BILLABLE_QUANTITY,
  NVL(PTA.I_TOT_BILLABLE_LABOR_HOURS,0) I_TOT_BILLABLE_LABOR_HOURS,
  NVL(PTA.TOT_CMT_RAW_COST,0) TOT_CMT_RAW_COST,
  NVL(PTA.TOT_CMT_BURDENED_COST,0) TOT_CMT_BURDENED_COST,
  NVL(PTA.TOT_CMT_QUANTITY,0) TOT_CMT_QUANTITY,
  PTA.actual_cost_rollup_flag,
  PTA.revenue_rollup_flag,
  PTA.cmt_rollup_flag,
  PTA.UNIT_OF_MEASURE,
  GPS.PERIOD_YEAR,
  nvl(PT.WBS_Level,0)
 FROM
 PA_TXN_ACCUM PTA,
 PA_TASKS PT,
 GL_PERIOD_STATUSES GPS,
 PA_IMPLEMENTATIONS PI
 Where	PTA.Project_Id = x_project_id
 and   PTA.task_id = PT.task_id(+)
 and   (PTA.ACTUAL_COST_Rollup_flag = DECODE(x_Actual_Cost_Flag,'Y','Y','X')
        OR PTA.REVENUE_Rollup_flag = DECODE(x_revenue_Flag,'Y','Y','X')
	OR PTA.CMT_Rollup_flag = DECODE(x_commitments_Flag,'Y','Y','X')
        OR pa_proj_accum_main.x_summ_process = 'RL')
--   and gps.application_id = decode(x_impl_opt,'PA',275,'GL',pa_period_process_pkg.application_id)
-----     commented and added for bug 2569461
-- Added TO_NUMBER(SUBSTR(USERENV('CLIENT_INFO'),1,10)) for bug 2834359
-- bug 3147957: Replaced TO_NUMBER(SUBSTR(USERENV('CLIENT_INFO'),1,10)) with p_org_id
     and gps.application_id = decode(x_impl_opt,'PA',decode(PA_Period_Process_PKG.Use_Same_PA_GL_Period(p_org_id),'Y',
                                  pa_period_process_pkg.application_id,'N',275),'GL',pa_period_process_pkg.application_id)
   and gps.set_of_books_id = pi.set_of_books_id
   and gps.period_name = decode(x_impl_opt,'PA',PTA.pa_period,'GL',PTA.gl_period)
   and gps.END_DATE <= x_current_end_date
 Order By 2,23,3; --Parent_Task_id,WBS_Level,Task_id
*/

 CURSOR Res_accum_Cur IS
 SELECT
  PTA.TXN_ACCUM_ID,
  nvl(PT.parent_task_id,PT.task_id) parent_task_id,
  PTA.TASK_ID task_id,
  PTA.PA_PERIOD,
  PTA.GL_PERIOD,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_REVENUE,0),NVL(PTA.I_TOT_REVENUE,0)) I_TOT_REVENUE,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_RAW_COST,0),NVL(PTA.I_TOT_RAW_COST,0)) I_TOT_RAW_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BURDENED_COST,0),NVL(PTA.I_TOT_BURDENED_COST,0)) I_TOT_BURDENED_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_QUANTITY,0),NVL(PTA.I_TOT_QUANTITY,0)) I_TOT_QUANTITY,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_LABOR_HOURS,0),NVL(PTA.I_TOT_LABOR_HOURS,0)) I_TOT_LABOR_HOURS,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_RAW_COST,0),NVL(PTA.I_TOT_BILLABLE_RAW_COST,0)) I_TOT_BILLABLE_RAW_COST ,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_BURDENED_COST,0),NVL(PTA.I_TOT_BILLABLE_BURDENED_COST,0)) I_TOT_BILLABLE_BURDENED_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_QUANTITY,0),NVL(PTA.I_TOT_BILLABLE_QUANTITY,0))I_TOT_BILLABLE_QUANTITY,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_LABOR_HOURS,0),NVL(PTA.I_TOT_BILLABLE_LABOR_HOURS,0)) I_TOT_BILLABLE_LABOR_HOURS,
  NVL(PTA.TOT_CMT_RAW_COST,0) TOT_CMT_RAW_COST,
  NVL(PTA.TOT_CMT_BURDENED_COST,0) TOT_CMT_BURDENED_COST,
  NVL(PTA.TOT_CMT_QUANTITY,0) TOT_CMT_QUANTITY,
  PTA.actual_cost_rollup_flag,
  PTA.revenue_rollup_flag,
  PTA.cmt_rollup_flag,
  GPS.PERIOD_YEAR,
  Para.RESOURCE_LIST_ASSIGNMENT_ID,
  Para.RESOURCE_LIST_ID,
  Para.RESOURCE_LIST_MEMBER_ID,
  Para.RESOURCE_ID ,
  Parl.TRACK_AS_LABOR_FLAG,
  Par.ROLLUP_QUANTITY_FLAG ,
  Par.UNIT_OF_MEASURE,
  PT.wbs_level
 FROM
  PA_TXN_ACCUM PTA,
  PA_TASKS PT,
  GL_PERIODS GPS,
  PA_IMPLEMENTATIONS PI,
  PA_RESOURCE_ACCUM_DETAILS Para,
  PA_RESOURCES Par,
  PA_RESOURCE_LIST_MEMBERS Parl
 Where  Parl.resource_list_id = nvl(x_resource_list_id,Parl.resource_list_id) and
        Para.Resource_list_id = Parl.Resource_list_id and
        Para.Resource_list_member_id = Parl.Resource_list_member_id and
        Para.Resource_id  = Par.Resource_Id and
 	PTA.Project_Id = x_project_id and
        nvl(parl.migration_code,'-99') <> 'N' and
       (PTA.ACTUAL_COST_Rollup_flag = DECODE(x_Actual_Cost_Flag,'Y','Y','X')
        OR PTA.REVENUE_Rollup_flag = DECODE(x_revenue_Flag,'Y','Y','X')
	OR PTA.CMT_Rollup_flag = DECODE(x_commitments_Flag,'Y','Y','X')
        OR pa_proj_accum_main.x_summ_process = 'RL') and
       gps.period_set_name = pi.period_set_name and
       /* Commented for bug 4631058 gps.period_type = pi.pa_period_type and */
       gps.adjustment_period_flag = 'N' and
       -- Removed the fix done for Bug# 5019025
       gps.period_name = decode(x_impl_opt,'PA',PTA.pa_period,'GL',PTA.gl_period) and
	trunc(gps.END_DATE) <= x_current_end_date and    -- added trunc for the bug 4532088
        PT.task_id = PTA.Task_id and
  	Para.Txn_Accum_id = PTA.Txn_Accum_id
union
 select
  PTA.TXN_ACCUM_ID,
  0 parent_task_id,
  0 task_id,
  PTA.PA_PERIOD,
  PTA.GL_PERIOD,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_REVENUE,0),NVL(PTA.I_TOT_REVENUE,0)) I_TOT_REVENUE,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_RAW_COST,0),NVL(PTA.I_TOT_RAW_COST,0)) I_TOT_RAW_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BURDENED_COST,0),NVL(PTA.I_TOT_BURDENED_COST,0)) I_TOT_BURDENED_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_QUANTITY,0),NVL(PTA.I_TOT_QUANTITY,0)) I_TOT_QUANTITY,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_LABOR_HOURS,0),NVL(PTA.I_TOT_LABOR_HOURS,0)) I_TOT_LABOR_HOURS,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_RAW_COST,0),NVL(PTA.I_TOT_BILLABLE_RAW_COST,0)) I_TOT_BILLABLE_RAW_COST ,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_BURDENED_COST,0),NVL(PTA.I_TOT_BILLABLE_BURDENED_COST,0)) I_TOT_BILLABLE_BURDENED_COST,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_QUANTITY,0),NVL(PTA.I_TOT_BILLABLE_QUANTITY,0))I_TOT_BILLABLE_QUANTITY,
  decode(pa_proj_accum_main.x_summ_process,'RL',NVL(PTA.TOT_BILLABLE_LABOR_HOURS,0),NVL(PTA.I_TOT_BILLABLE_LABOR_HOURS,0)) I_TOT_BILLABLE_LABOR_HOURS,
  NVL(PTA.TOT_CMT_RAW_COST,0) TOT_CMT_RAW_COST,
  NVL(PTA.TOT_CMT_BURDENED_COST,0) TOT_CMT_BURDENED_COST,
  NVL(PTA.TOT_CMT_QUANTITY,0) TOT_CMT_QUANTITY,
  PTA.actual_cost_rollup_flag,
  PTA.revenue_rollup_flag,
  PTA.cmt_rollup_flag,
  GPS.PERIOD_YEAR,
  Para.RESOURCE_LIST_ASSIGNMENT_ID,
  Para.RESOURCE_LIST_ID,
  Para.RESOURCE_LIST_MEMBER_ID,
  Para.RESOURCE_ID ,
  Parl.TRACK_AS_LABOR_FLAG,
  Par.ROLLUP_QUANTITY_FLAG ,
  Par.UNIT_OF_MEASURE,
  0  wbs_level
 FROM
  PA_TXN_ACCUM PTA,
  GL_PERIODS GPS,
  PA_IMPLEMENTATIONS PI,
  PA_RESOURCE_ACCUM_DETAILS Para,
  PA_RESOURCES Par,
  PA_RESOURCE_LIST_MEMBERS Parl
 Where  Parl.resource_list_id = nvl(x_resource_list_id,Parl.resource_list_id) and
        Para.Resource_list_id = Parl.Resource_list_id and
        Para.Resource_list_member_id = Parl.Resource_list_member_id and
        Para.Resource_id  = Par.Resource_Id and
 	PTA.Project_Id = x_project_id and
        nvl(parl.migration_code,'-99') <> 'N' and
       (PTA.ACTUAL_COST_Rollup_flag = DECODE(x_Actual_Cost_Flag,'Y','Y','X')
        OR PTA.REVENUE_Rollup_flag = DECODE(x_revenue_Flag,'Y','Y','X')
	OR PTA.CMT_Rollup_flag = DECODE(x_commitments_Flag,'Y','Y','X')
        OR pa_proj_accum_main.x_summ_process = 'RL') and
       gps.period_set_name = pi.period_set_name and
       /* Commented for bug 4631058 gps.period_type = pi.pa_period_type and */
       gps.adjustment_period_flag = 'N' and
       -- Removed the fix done for Bug# 5019025
        gps.period_name = decode(x_impl_opt,'PA',PTA.pa_period,'GL',PTA.gl_period) and
	trunc(gps.END_DATE) <= x_current_end_date and -- added trunc for the bug 4532088
  	Para.Txn_Accum_id = PTA.Txn_Accum_id
  Order By 2,29,3,24; --Parent_Task_id,WBS_Level,Task_id,Para.Resource_List_Member_id;


 CURSOR PA_Txn_Accum_Cur IS
 SELECT DISTINCT
  PTA.TXN_ACCUM_ID,
  nvl(PT.parent_task_id,nvl(pt.task_id,0)) top_task_id,
  PTA.TASK_ID,
  PTA.PA_PERIOD,
  PTA.GL_PERIOD,
  NVL(PTA.I_TOT_REVENUE,0) I_TOT_REVENUE,
  NVL(PTA.I_TOT_RAW_COST,0) I_TOT_RAW_COST,
  NVL(PTA.I_TOT_BURDENED_COST,0) I_TOT_BURDENED_COST,
  NVL(PTA.I_TOT_QUANTITY,0) I_TOT_QUANTITY,
  NVL(PTA.I_TOT_LABOR_HOURS,0) I_TOT_LABOR_HOURS,
  NVL(PTA.I_TOT_BILLABLE_RAW_COST,0) I_TOT_BILLABLE_RAW_COST ,
  NVL(PTA.I_TOT_BILLABLE_BURDENED_COST,0) I_TOT_BILLABLE_BURDENED_COST,
  NVL(PTA.I_TOT_BILLABLE_QUANTITY,0) I_TOT_BILLABLE_QUANTITY,
  NVL(PTA.I_TOT_BILLABLE_LABOR_HOURS,0) I_TOT_BILLABLE_LABOR_HOURS,
  NVL(PTA.TOT_CMT_RAW_COST,0) TOT_CMT_RAW_COST,
  NVL(PTA.TOT_CMT_BURDENED_COST,0) TOT_CMT_BURDENED_COST,
  NVL(PTA.TOT_CMT_QUANTITY,0) TOT_CMT_QUANTITY,
  PTA.actual_cost_rollup_flag,
  PTA.revenue_rollup_flag,
  PTA.cmt_rollup_flag,
  PTA.UNIT_OF_MEASURE,
  GPS.PERIOD_YEAR,
  nvl(PT.WBS_Level,0)
 FROM
 PA_TXN_ACCUM PTA,
 PA_TASKS PT,
 GL_PERIODS GPS,
 PA_IMPLEMENTATIONS PI
 Where	PTA.Project_Id = x_project_id
 and   PTA.task_id = PT.task_id(+)
 and   (PTA.ACTUAL_COST_Rollup_flag = DECODE(x_Actual_Cost_Flag,'Y','Y','X')
        OR PTA.REVENUE_Rollup_flag = DECODE(x_revenue_Flag,'Y','Y','X')
	OR PTA.CMT_Rollup_flag = DECODE(x_commitments_Flag,'Y','Y','X')
        OR pa_proj_accum_main.x_summ_process = 'RL')
   and gps.period_set_name = pi.period_set_name
   /* Commented for bug 4631058 and gps.period_type = pi.pa_period_type */
   and gps.adjustment_period_flag = 'N'
   -- Removed the fix done for Bug# 5019025
   and gps.period_name = decode(x_impl_opt,'PA',PTA.pa_period,'GL',PTA.gl_period)
   and trunc(gps.END_DATE) <= x_current_end_date    -- added trunc for the bug 4532088
 Order By 2,23,3; --Parent_Task_id,WBS_Level,Task_id

  x_txn_accum_rec 		PA_Txn_Accum_Cur%ROWTYPE;
  x_res_accum_rec 		Res_accum_Cur%ROWTYPE;
  /* Code Addition for bug 3147957 begins */
  l_client_info                 varchar2(20);
  l_org_id                      NUMBER;
  /* Code Addition for bug 3147957 ends */
 Begin

    V_Old_Stack := x_err_stack;
    x_err_stack :=
    x_err_stack ||'->PA_MAINT_PROJECT_ACCUMS.Process_Txn_Accum';
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    pa_debug.debug(x_err_stack);
    END IF;

    /* Commented for bug 4195598
    -- Code addition for bug 3147957 begins
    l_client_info := null;
    l_client_info := LTRIM(RTRIM(SUBSTR(USERENV('CLIENT_INFO'),1,10)));

    if l_client_info is null then
       l_org_id := null;
    else
       l_org_id := TO_NUMBER(l_client_info);
    end if;
    -- Code addition for bug 3147957 ends   */

    initialize_parent_level;
    initialize_task_level;
    initialize_project_level;

/* Modified for bug 4195598
    OPEN Res_Accum_Cur(l_org_id); -- Bug3147957: Added parameter l_org_id
    OPEN PA_Txn_Accum_Cur(l_org_id); -- Bug3147957: Added parameter l_org_id
*/
    OPEN Res_Accum_Cur;
    OPEN PA_Txn_Accum_Cur;
    LOOP

 	IF Fetch_Task = True THEN
	   Fetch PA_Txn_Accum_Cur INTO x_txn_accum_rec;
	END IF;

	Fetch_Task := True;

	IF (x_txn_accum_rec.task_id = curr_task_id OR curr_task_id = -99)
          AND (PA_Txn_Accum_Cur%FOUND) then

            If (x_txn_accum_rec.actual_cost_rollup_flag = 'Y' and
                x_actual_cost_flag = 'Y') or
               (x_txn_accum_rec.revenue_rollup_flag = 'Y' and
                x_revenue_flag = 'Y') then
                    create_actuals := 'Y';
                    create_wbs_actuals := 'Y';
            end if;
            If x_txn_accum_rec.cmt_rollup_flag = 'Y' and
               x_commitments_flag = 'Y' then
                    create_commit := 'Y';
                    create_wbs_commit := 'Y';
            end if;
           --   Fetched period = current period
           --  (Update only ITD,YTD and PTD figures)-
           --    Task level figures without resources

                   IF (x_commitments_flag = 'Y' and
                       x_txn_accum_rec.cmt_rollup_flag = 'Y' and
                       pa_proj_accum_main.x_summ_process <> 'RL') THEN

                        New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
                                NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);
                        New_cmt_burd_cost_ytd := New_cmt_burd_cost_ytd +
                                NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);
                        New_cmt_burd_cost_ptd := New_cmt_burd_cost_ptd +
                                NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);

                        New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
                                NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);
                        New_cmt_raw_cost_ytd := New_cmt_raw_cost_ytd +
                                NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);
                        New_cmt_raw_cost_ptd := New_cmt_raw_cost_ptd +
                                NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);

                   END IF;

 -- Bug 2753251, jwhite, 16-JAN-2003: Original Code -----------------------

/*
                IF ((x_txn_accum_rec.PA_PERIOD =  x_current_period ) OR
                   (x_txn_accum_rec.GL_PERIOD = x_current_period )) AND
                    pa_proj_accum_main.x_summ_process <> 'RL' THEN
*/
      --New logic implemented for the bug 2753251
             IF ((x_txn_accum_rec.PA_PERIOD =  x_current_period AND X_impl_opt = 'PA' ) OR
                   (x_txn_accum_rec.GL_PERIOD = x_current_period AND X_impl_opt = 'GL')) AND
                    pa_proj_accum_main.x_summ_process <> 'RL'
               THEN


  -- bug 2753251 ------------------------------------------------------------

		    IF x_actual_cost_flag = 'Y' and
                       x_txn_accum_rec.actual_cost_rollup_flag = 'Y' THEN

  			New_raw_cost_itd := New_raw_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_ytd := New_raw_cost_ytd +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_ptd := New_raw_cost_ptd +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);

  			New_burd_cost_itd := New_burd_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_ytd := New_burd_cost_ytd +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_ptd := New_burd_cost_ptd +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);

  			New_bill_raw_cost_itd := New_bill_raw_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_ytd := New_bill_raw_cost_ytd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_ptd := New_bill_raw_cost_ptd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);

  			New_bill_burd_cost_itd := New_bill_burd_cost_itd +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_ytd := New_bill_burd_cost_ytd +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_ptd := New_bill_burd_cost_ptd +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);

  			New_labor_hours_itd := New_labor_hours_itd +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_ytd := New_labor_hours_ytd +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_ptd := New_labor_hours_ptd +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);

  			New_bill_labor_hours_itd := New_bill_labor_hours_itd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_ytd := New_bill_labor_hours_ytd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_ptd := New_bill_labor_hours_ptd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);

		   END IF;

              /*   IF x_commitments_flag = 'Y' and
                      x_txn_accum_rec.cmt_rollup_flag = 'Y' THEN

  			New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_ytd := New_cmt_burd_cost_ytd +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_ptd := New_cmt_burd_cost_ptd +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);

  			New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_ytd := New_cmt_raw_cost_ytd +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_ptd := New_cmt_raw_cost_ptd +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);

		   END IF; */

		   IF x_revenue_flag = 'Y' and
                      x_txn_accum_rec.revenue_rollup_flag = 'Y' THEN

  			New_revenue_itd := New_revenue_itd +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_ytd	:= New_revenue_ytd +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_ptd	:= New_revenue_ptd +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);
		  END IF;

  -- Bug 2753251, jwhite, 16-JAN-2003: Original Code -----------------------

/*
                ELSIF  --    Fetched period = Previous period
            	      ((x_txn_accum_rec.PA_PERIOD = x_prev_period )
        	       OR (x_txn_accum_rec.GL_PERIOD = x_prev_period ))
                        AND pa_proj_accum_main.x_summ_process <> 'RL' THEN

*/

                ELSIF  --    Fetched period = Previous period
            	      ((x_txn_accum_rec.PA_PERIOD = x_prev_period AND X_impl_opt = 'PA')
        	       OR (x_txn_accum_rec.GL_PERIOD = x_prev_period AND X_impl_opt = 'GL'))
                        AND pa_proj_accum_main.x_summ_process <> 'RL'
                     THEN


  -- bug 2753251 -----------------------------------------------------------

		--   Fetched period=previous period and fetched year=currentyear
		--   (Update only ITD,YTD and PP figures )- Task level figures
		--    without resources

             	      IF x_txn_accum_rec.PERIOD_YEAR = x_current_year THEN

			IF x_actual_cost_flag = 'Y' and
                           x_txn_accum_rec.actual_cost_rollup_flag = 'Y' THEN

  			New_raw_cost_itd := New_raw_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_ytd := New_raw_cost_ytd +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_pp := New_raw_cost_pp +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);

  			New_burd_cost_itd := New_burd_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_ytd := New_burd_cost_ytd +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_pp := New_burd_cost_pp +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);

  			New_labor_hours_itd := New_labor_hours_itd +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_ytd := New_labor_hours_ytd +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_pp := New_labor_hours_pp +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);

  			New_bill_raw_cost_itd := New_bill_raw_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_ytd := New_bill_raw_cost_ytd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_pp := New_bill_raw_cost_pp +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);

  			New_bill_burd_cost_itd := New_bill_burd_cost_itd +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_ytd := New_bill_burd_cost_ytd +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_pp := New_bill_burd_cost_pp +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);

  			New_bill_labor_hours_itd := New_bill_labor_hours_itd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_ytd := New_bill_labor_hours_ytd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_pp := New_bill_labor_hours_pp +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);

			END IF;

			IF x_revenue_flag = 'Y' and
                           x_txn_accum_rec.revenue_rollup_flag = 'Y' THEN

  			New_revenue_itd := New_revenue_itd +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_ytd	:= New_revenue_ytd +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_pp	:= New_revenue_pp +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);
			END IF;

	/*		IF x_commitments_flag = 'Y' and
                           x_txn_accum_rec.cmt_rollup_flag = 'Y' THEN

  			New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_ytd := New_cmt_raw_cost_ytd +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_pp  := New_cmt_raw_cost_pp  +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);

  			New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_ytd := New_cmt_burd_cost_ytd +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_pp  := New_cmt_burd_cost_pp  +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);

		  	END IF; */

            	      ELSE

			--   Fetched period = previous period but
			--   fetched year <> current year
			--  (Update only ITD and PP figures )-Task level
			--   figures without resources

			IF x_actual_cost_flag = 'Y' and
                           x_txn_accum_rec.actual_cost_rollup_flag = 'Y' THEN

  			New_raw_cost_itd := New_raw_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_pp  := New_raw_cost_pp  +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);

  			New_burd_cost_itd := New_burd_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_pp  := New_burd_cost_pp  +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);

  			New_labor_hours_itd := New_labor_hours_itd +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_pp  := New_labor_hours_pp  +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);

  			New_bill_raw_cost_itd := New_bill_raw_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_pp  := New_bill_raw_cost_pp  +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);

  			New_bill_burd_cost_itd := New_bill_burd_cost_itd +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_pp  := New_bill_burd_cost_pp  +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);

  			New_bill_labor_hours_itd := New_bill_labor_hours_itd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_pp  := New_bill_labor_hours_pp  +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);

			END IF;

	/*		IF x_commitments_flag = 'Y' and
                           x_txn_accum_rec.cmt_rollup_flag = 'Y' THEN

  			New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_pp  := New_cmt_raw_cost_pp  +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);

  			New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_pp  := New_cmt_burd_cost_pp  +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);

			END IF; */

			IF x_revenue_flag = 'Y' and
                           x_txn_accum_rec.revenue_rollup_flag = 'Y' THEN

  			New_revenue_itd := New_revenue_itd +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_pp 	:= New_revenue_pp  +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);

			END IF;

           	      END IF; --If x_txn_accum_rec.PERIOD_YEAR = x_current_year
          	ELSE

		--   Fetched period <> current or previous period but fetched
		--   year = current year
		--   (Update only ITD and YTD figures)- Task level
		--   figures without resources

             	     IF x_txn_accum_rec.PERIOD_YEAR = x_current_year
                        and pa_proj_accum_main.x_summ_process <> 'RL' Then

			IF x_actual_cost_flag = 'Y' and
                           x_txn_accum_rec.actual_cost_rollup_flag = 'Y' THEN

  			New_raw_cost_itd := New_raw_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_ytd := New_raw_cost_ytd +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);

  			New_burd_cost_itd := New_burd_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_ytd := New_burd_cost_ytd +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);

  			New_labor_hours_itd := New_labor_hours_itd +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_ytd := New_labor_hours_ytd +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);

  			New_bill_raw_cost_itd := New_bill_raw_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_ytd := New_bill_raw_cost_ytd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);

  			New_bill_burd_cost_itd := New_bill_burd_cost_itd +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_ytd := New_bill_burd_cost_ytd +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);

  			New_bill_labor_hours_itd := New_bill_labor_hours_itd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_ytd := New_bill_labor_hours_ytd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);

			END IF;

	/*		IF x_commitments_flag = 'Y' and
                           x_txn_accum_rec.cmt_rollup_flag = 'Y' THEN

  			New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_ytd := New_cmt_raw_cost_ytd +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);

  			New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_ytd := New_cmt_burd_cost_ytd +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);

			END IF; */

			IF x_revenue_flag = 'Y' and
                           x_txn_accum_rec.revenue_rollup_flag = 'Y' THEN

  			New_revenue_itd := New_revenue_itd +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_ytd	:= New_revenue_ytd +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);

			END IF;

             	     ELSE

		--   Fetched period <> current or previous period
		--   and fetched year <>
		--   current year (Update only ITD figures )-
		--   Task level figures without resources
                       If pa_proj_accum_main.x_summ_process <> 'RL' then
			IF x_actual_cost_flag = 'Y' and
                           x_txn_accum_rec.actual_cost_rollup_flag = 'Y' THEN

  			New_raw_cost_itd := New_raw_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_RAW_COST,0);
  			New_burd_cost_itd := New_burd_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_BURDENED_COST,0);
  			New_labor_hours_itd := New_labor_hours_itd +
				NVL(x_txn_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_bill_raw_cost_itd := New_bill_raw_cost_itd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_burd_cost_itd := New_bill_burd_cost_itd +
			   NVL(x_txn_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_labor_hours_itd := New_bill_labor_hours_itd +
				NVL(x_txn_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);

			END IF;

			IF x_revenue_flag = 'Y' and
                           x_txn_accum_rec.revenue_rollup_flag = 'Y' THEN

  			New_revenue_itd := New_revenue_itd +
				NVL(x_txn_accum_rec.I_TOT_REVENUE,0);
			END IF;

	/*		IF x_commitments_flag = 'Y' and
                           x_txn_accum_rec.cmt_rollup_flag = 'Y' THEN

  			New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
				NVL(x_txn_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
				NVL(x_txn_accum_rec.TOT_CMT_BURDENED_COST,0);

			END IF; */
                      end if;

            	     END IF;

         	END IF;

        ELSE     -- for task_id = curr_task_id or curr_task_id = -99 condition

		-- Store the value onto variables to be later updated on Project
		-- Level (task = 0 and rlmid = 0) record.
             if pa_proj_accum_main.x_summ_process <> 'RL' then
	        add_project_amounts;
             end if;

             if (x_txn_accum_rec.top_task_id <> curr_parent_id and
                curr_parent_id > 0)or
                pa_txn_accum_cur%notfound then
                add_parent_amounts;
   		Get_all_higher_tasks
			(x_project_id ,
                         curr_task_id ,
			 0,             -- resource_list_member_id
                         v_task_array,
                         v_noof_tasks,
                         x_err_stack,
                         x_err_stage,
                         x_err_code);
              if (pa_proj_accum_main.x_summ_process <> 'RL' and curr_parent_id > 0) then
 		Check_Accum_res_tasks
			( x_project_id ,
               		  curr_task_id,
			  x_Proj_Accum_id,
			  x_current_period,
                          0,
                          0,
                          0,
                          0,
                          create_actuals,
                          create_commit,
               	          x_err_stack ,
                       	  x_err_stage ,
                       	  x_err_code  );

   		If v_noof_tasks > 0 Then
       		   For i in 2..v_noof_tasks LOOP
 			Check_Accum_WBS
				( x_project_id ,
                       		  v_task_array(i),
				  x_Proj_Accum_id,
				  x_current_period,
                                  0,
                                  0,
                                  0,
                                  0,
                                  create_wbs_actuals,
                                  create_wbs_commit,
                       		  x_err_stack ,
                       		  x_err_stage ,
                       		  x_err_code  );

		   End LOOP;
		End If;
               end if;

                initialize_task_level;
                initialize_parent_level;
                create_commit := 'N';
                create_actuals := 'N';
                create_wbs_actuals := 'N';
                create_wbs_commit := 'N';

		Fetch_Task := False;
                prev_parent_id := curr_parent_id;

           	LOOP
                     if curr_rlmid = -99 then
                           curr_res_task := 0;
                     end if;
		     IF Fetch_Res = True THEN
			FETCH Res_Accum_Cur INTO x_Res_Accum_rec;
			--EXIT WHEN Res_Accum_Cur%NOTFOUND;
		     END IF;

		     Fetch_Res := True;

		     IF x_Res_Accum_rec.Task_id = curr_res_task AND Res_Accum_Cur%FOUND THEN

			IF x_Res_Accum_rec.resource_list_member_id = curr_rlmid OR
			   curr_rlmid = -99 THEN
----------------------------
            If (x_res_accum_rec.actual_cost_rollup_flag = 'Y' and
                x_actual_cost_flag = 'Y') or
               (x_res_accum_rec.revenue_rollup_flag = 'Y' and
                x_revenue_flag = 'Y') or
               (pa_proj_accum_main.x_summ_process = 'RL') then
                    create_actuals := 'Y';
            end if;
            If (x_res_accum_rec.cmt_rollup_flag = 'Y' and x_commitments_flag = 'Y')
                or pa_proj_accum_main.x_summ_process = 'RL' then
                    create_commit := 'Y';
            end if;
                        curr_rlmid := x_res_accum_rec.resource_list_member_id;
                        curr_rid   := x_res_accum_rec.resource_id;
                        curr_rlid  := x_res_accum_rec.resource_list_id;
                        curr_rlaid := x_res_accum_rec.resource_list_assignment_id;
----------------------------

           	     	   IF ( x_Res_Accum_Rec.rollup_Quantity_flag = 'Y') THEN
              	                x_quantity := x_res_accum_rec.I_TOT_QUANTITY;
              	                x_cmt_quantity :=
					x_res_accum_rec.TOT_CMT_QUANTITY;
                   	        x_billable_quantity :=
					x_res_accum_rec.I_TOT_BILLABLE_QUANTITY;
           	     	   ELSE
              	                x_quantity := 0;
              	          	x_billable_quantity :=0;
           	    	  END IF;
--------------------------------------------------------------------------
--   Add amounts for a Project, Task and Resource combination
--------------------------------------------------------------------------
           	--   Fetched period = current period
           	--  (Update only ITD,YTD and PTD figures)-
           	--    Task level figures without resources
                        IF (x_commitments_flag = 'Y' and
                           x_res_accum_rec.cmt_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

                        New_cmt_quantity_itd := New_cmt_quantity_itd
                                                + x_cmt_quantity;
                        New_cmt_quantity_ytd := New_cmt_quantity_ytd
                                                + x_cmt_quantity;
                        New_cmt_quantity_ptd := New_cmt_quantity_ptd
                                                + x_cmt_quantity;

                        New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
                                NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);
                        New_cmt_raw_cost_ytd := New_cmt_raw_cost_ytd +
                                NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);
                        New_cmt_raw_cost_ptd := New_cmt_raw_cost_ptd +
                                NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);

                        New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
                                NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);
                        New_cmt_burd_cost_ytd := New_cmt_burd_cost_ytd +
                                NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);
                        New_cmt_burd_cost_ptd := New_cmt_burd_cost_ptd +
                                NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);

                        END IF;

-- Bug 2753251, jwhite, 16-JAN-2003: Original Code -----------------------

/*

                IF (x_res_accum_rec.PA_PERIOD =  x_current_period ) OR
                   (x_res_accum_rec.GL_PERIOD = x_current_period ) THEN

*/


               IF (x_res_accum_rec.PA_PERIOD =  x_current_period AND X_impl_opt = 'PA') OR
                   (x_res_accum_rec.GL_PERIOD = x_current_period AND X_impl_opt = 'GL' )
                 THEN


 -- bug 2753251 -----------------------------------------------------------


			IF (x_actual_cost_flag = 'Y' and
                           x_res_accum_rec.actual_cost_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_raw_cost_itd := New_raw_cost_itd +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_ytd := New_raw_cost_ytd +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_ptd := New_raw_cost_ptd +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);

  			New_quantity_itd := New_quantity_itd + x_quantity;
  			New_quantity_ytd := New_quantity_ytd + x_quantity;
  			New_quantity_ptd := New_quantity_ptd + x_quantity;

  			New_bill_quantity_itd := New_bill_quantity_itd +
						 x_billable_quantity;
  			New_bill_quantity_ytd := New_bill_quantity_ytd +
						 x_billable_quantity;
  			New_bill_quantity_ptd := New_bill_quantity_ptd +
						 x_billable_quantity;

  			New_burd_cost_itd := New_burd_cost_itd +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_ytd := New_burd_cost_ytd +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_ptd := New_burd_cost_ptd +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);

  			New_labor_hours_itd := New_labor_hours_itd +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_ytd := New_labor_hours_ytd +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_ptd := New_labor_hours_ptd +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);

  			New_bill_raw_cost_itd := New_bill_raw_cost_itd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_ytd := New_bill_raw_cost_ytd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_ptd := New_bill_raw_cost_ptd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);

  			New_bill_burd_cost_itd := New_bill_burd_cost_itd +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_ytd := New_bill_burd_cost_ytd +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_ptd := New_bill_burd_cost_ptd +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);

  			New_bill_labor_hours_itd := New_bill_labor_hours_itd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_ytd := New_bill_labor_hours_ytd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_ptd := New_bill_labor_hours_ptd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);

			END IF;

			IF (x_revenue_flag = 'Y' and
                           x_res_accum_rec.revenue_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_revenue_itd := New_revenue_itd +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_ytd	:= New_revenue_ytd +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_ptd	:= New_revenue_ptd +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);

			END IF;

	/*		IF (x_commitments_flag = 'Y' and
                           x_res_accum_rec.cmt_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_cmt_quantity_itd := New_cmt_quantity_itd
						+ x_cmt_quantity;
  			New_cmt_quantity_ytd := New_cmt_quantity_ytd
						+ x_cmt_quantity;
  			New_cmt_quantity_ptd := New_cmt_quantity_ptd
						+ x_cmt_quantity;

  			New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_ytd := New_cmt_raw_cost_ytd +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_ptd := New_cmt_raw_cost_ptd +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);

  			New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_ytd := New_cmt_burd_cost_ytd +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_ptd := New_cmt_burd_cost_ptd +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);

              		END IF; */

                ELSIF  --    Fetched period = Previous period

-- Bug 2753251, jwhite, 16-JAN-2003: Original Code -----------------------

/*
            	      (x_res_accum_rec.PA_PERIOD = x_prev_period )
        	       OR (x_res_accum_rec.GL_PERIOD = x_prev_period ) THEN
*/

          	      (x_res_accum_rec.PA_PERIOD = x_prev_period AND X_impl_opt = 'PA')
        	       OR (x_res_accum_rec.GL_PERIOD = x_prev_period AND X_impl_opt = 'GL' )
                        THEN


-- bug 2753251 -----------------------------------------------------------

		--    Fetched period = previous period and fetched
		--    year = current year
		--   (Update only ITD,YTD and PP figures )- Task level figures
		--    without resources

             	      IF x_res_accum_rec.PERIOD_YEAR = x_current_year THEN

			IF (x_actual_cost_flag = 'Y' and
                           x_res_accum_rec.actual_cost_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_raw_cost_itd := New_raw_cost_itd +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_ytd := New_raw_cost_ytd +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_pp := New_raw_cost_pp +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);

  			New_quantity_itd := New_quantity_itd + x_quantity;
  			New_quantity_ytd := New_quantity_ytd + x_quantity;
  			New_quantity_pp  := New_quantity_pp  + x_quantity;

  			New_bill_quantity_itd := New_bill_quantity_itd +
						 x_billable_quantity;
  			New_bill_quantity_ytd := New_bill_quantity_ytd +
						 x_billable_quantity;
  			New_bill_quantity_pp  := New_bill_quantity_pp  +
						 x_billable_quantity;

  			New_burd_cost_itd := New_burd_cost_itd +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_ytd := New_burd_cost_ytd +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_pp := New_burd_cost_pp +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);

  			New_labor_hours_itd := New_labor_hours_itd +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_ytd := New_labor_hours_ytd +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_pp := New_labor_hours_pp +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);

  			New_bill_raw_cost_itd := New_bill_raw_cost_itd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_ytd := New_bill_raw_cost_ytd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_pp := New_bill_raw_cost_pp +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);

  			New_bill_burd_cost_itd := New_bill_burd_cost_itd +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_ytd := New_bill_burd_cost_ytd +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_pp := New_bill_burd_cost_pp +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);

  			New_bill_labor_hours_itd := New_bill_labor_hours_itd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_ytd := New_bill_labor_hours_ytd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_pp := New_bill_labor_hours_pp +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);

			END IF;

			IF (x_revenue_flag = 'Y' and
                           x_res_accum_rec.revenue_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_revenue_itd := New_revenue_itd +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_ytd	:= New_revenue_ytd +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_pp	:= New_revenue_pp +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);

			END IF;

	/*		IF (x_commitments_flag = 'Y' and
                           x_res_accum_rec.cmt_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_cmt_quantity_itd := New_cmt_quantity_itd +
						 x_cmt_quantity;
  			New_cmt_quantity_ytd := New_cmt_quantity_ytd +
						 x_cmt_quantity;
  			New_cmt_quantity_pp  := New_cmt_quantity_pp  +
						 x_cmt_quantity;

  			New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_ytd := New_cmt_raw_cost_ytd +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_pp  := New_cmt_raw_cost_pp  +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);

  			New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_ytd := New_cmt_burd_cost_ytd +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_pp  := New_cmt_burd_cost_pp  +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);

			END IF; */

     	      ELSE

			--   Fetched period = previous period but
			--   fetched year <> current year
			--  (Update only ITD and PP figures )-Task level
			--   figures without resources

			IF (x_actual_cost_flag = 'Y' and
                           x_res_accum_rec.actual_cost_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_raw_cost_itd := New_raw_cost_itd +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_pp  := New_raw_cost_pp  +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);

  			New_quantity_itd := New_quantity_itd + x_quantity;
  			New_quantity_pp  := New_quantity_pp  + x_quantity;

  			New_bill_quantity_itd := New_bill_quantity_itd +
						 x_billable_quantity;
  			New_bill_quantity_pp  := New_bill_quantity_pp  +
						 x_billable_quantity;

  			New_burd_cost_itd := New_burd_cost_itd +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_pp  := New_burd_cost_pp  +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);

  			New_labor_hours_itd := New_labor_hours_itd +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_pp  := New_labor_hours_pp  +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);

  			New_bill_raw_cost_itd := New_bill_raw_cost_itd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_pp  := New_bill_raw_cost_pp  +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);

  			New_bill_burd_cost_itd := New_bill_burd_cost_itd +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_pp  := New_bill_burd_cost_pp  +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);

  			New_bill_labor_hours_itd := New_bill_labor_hours_itd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_pp  := New_bill_labor_hours_pp  +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);

			END IF;

			IF (x_revenue_flag = 'Y' and
                           x_res_accum_rec.revenue_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_revenue_itd := New_revenue_itd +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_pp 	:= New_revenue_pp  +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);

			END IF;

	/*		IF (x_commitments_flag = 'Y' and
                           x_res_accum_rec.cmt_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_cmt_quantity_itd := New_cmt_quantity_itd +
						 x_cmt_quantity;
  			New_cmt_quantity_pp  := New_cmt_quantity_pp  +
						 x_cmt_quantity;

  			New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_pp  := New_cmt_raw_cost_pp  +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);

  			New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_pp  := New_cmt_burd_cost_pp  +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);

			END IF; */

           	      END IF; -- If x_txn_accum_rec.PERIOD_YEAR = x_current_year
          	ELSE

		--   Fetched period <> current or previous period but fetched
		--   year = current year
		--   (Update only ITD and YTD figures)- Task level
		--   figures without resources

             	     IF x_res_accum_rec.PERIOD_YEAR = x_current_year Then

			IF (x_actual_cost_flag = 'Y' and
                           x_res_accum_rec.actual_cost_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_raw_cost_itd := New_raw_cost_itd +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);
  			New_raw_cost_ytd := New_raw_cost_ytd +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);

  			New_quantity_itd := New_quantity_itd + x_quantity;
  			New_quantity_ytd := New_quantity_ytd + x_quantity;

  			New_bill_quantity_itd := New_bill_quantity_itd +
						 x_billable_quantity;
  			New_bill_quantity_ytd := New_bill_quantity_ytd +
						 x_billable_quantity;

  			New_burd_cost_itd := New_burd_cost_itd +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);
  			New_burd_cost_ytd := New_burd_cost_ytd +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);

  			New_labor_hours_itd := New_labor_hours_itd +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_labor_hours_ytd := New_labor_hours_ytd +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);

  			New_bill_raw_cost_itd := New_bill_raw_cost_itd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_raw_cost_ytd := New_bill_raw_cost_ytd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);

  			New_bill_burd_cost_itd := New_bill_burd_cost_itd +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_burd_cost_ytd := New_bill_burd_cost_ytd +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);

  			New_bill_labor_hours_itd := New_bill_labor_hours_itd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
  			New_bill_labor_hours_ytd := New_bill_labor_hours_ytd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);
			END IF;

			IF (x_revenue_flag = 'Y' and
                           x_res_accum_rec.revenue_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_revenue_itd := New_revenue_itd +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);
  			New_revenue_ytd	:= New_revenue_ytd +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);

			END IF;

	/*		IF (x_commitments_flag = 'Y' and
                           x_res_accum_rec.cmt_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_cmt_quantity_itd := New_cmt_quantity_itd +
						x_cmt_quantity;
  			New_cmt_quantity_ytd := New_cmt_quantity_ytd +
						x_cmt_quantity;

  			New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_raw_cost_ytd := New_cmt_raw_cost_ytd +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);

  			New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);
  			New_cmt_burd_cost_ytd := New_cmt_burd_cost_ytd +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);
			END IF; */

             	     ELSE

		--   Fetched period <> current or previous period
		--   and fetched year <>
		--   current year (Update only ITD figures )-
		--   Task level figures without resources

			IF (x_actual_cost_flag = 'Y' and
                           x_res_accum_rec.actual_cost_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_raw_cost_itd := New_raw_cost_itd +
				NVL(x_res_accum_rec.I_TOT_RAW_COST,0);
  			New_quantity_itd := New_quantity_itd + x_quantity;
  			New_bill_quantity_itd := New_bill_quantity_itd +
						 x_billable_quantity;
  			New_burd_cost_itd := New_burd_cost_itd +
				NVL(x_res_accum_rec.I_TOT_BURDENED_COST,0);
  			New_labor_hours_itd := New_labor_hours_itd +
				NVL(x_res_accum_rec.I_TOT_LABOR_HOURS,0);
  			New_bill_raw_cost_itd := New_bill_raw_cost_itd +
				NVL(x_res_accum_rec.I_TOT_BILLABLE_RAW_COST,0);
  			New_bill_burd_cost_itd := New_bill_burd_cost_itd +
			   NVL(x_res_accum_rec.I_TOT_BILLABLE_BURDENED_COST,0);
  			New_bill_labor_hours_itd := New_bill_labor_hours_itd +
			NVL(x_res_accum_rec.I_TOT_BILLABLE_LABOR_HOURS,0);

			END IF;

			IF (x_revenue_flag = 'Y' and
                           x_res_accum_rec.revenue_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_revenue_itd := New_revenue_itd +
				NVL(x_res_accum_rec.I_TOT_REVENUE,0);

			END IF;

	/*		IF (x_commitments_flag = 'Y' and
                           x_res_accum_rec.cmt_rollup_flag = 'Y') or
                           pa_proj_accum_main.x_summ_process = 'RL' THEN

  			New_cmt_quantity_itd := New_cmt_quantity_itd +
						 x_cmt_quantity;
  			New_cmt_raw_cost_itd := New_cmt_raw_cost_itd +
				NVL(x_res_accum_rec.TOT_CMT_RAW_COST,0);
  			New_cmt_burd_cost_itd := New_cmt_burd_cost_itd +
				NVL(x_res_accum_rec.TOT_CMT_BURDENED_COST,0);

			END IF; */

            	     END IF;

         	END IF;

--------------------------------------------------------------------------
--   End of Add amounts for a Project, Task and Resource combination
--------------------------------------------------------------------------

			ELSE
                           If x_res_accum_rec.task_id = 0 then
                             Check_Accum_Res_Tasks
                                 ( x_project_id,
                                   0,
                                   x_Proj_Accum_id,
                                   x_current_period,
                                   curr_rlid,
                                   curr_rlmid,
                                   curr_rid,
                                   curr_rlaid,
                                   create_actuals,
                                   create_commit,
                                   x_err_stack,
                                   x_err_stage,
                                   x_err_code );
                          else
                           if curr_parent_id = x_res_accum_rec.task_id then
                               Check_accum_res_tasks
                                ( x_project_id,
                                  x_res_accum_rec.task_id,
                                  x_Proj_Accum_id,
                                  x_current_period,
                                   curr_rlid,
                                   curr_rlmid,
                                   curr_rid,
                                   curr_rlaid,
                                   create_actuals,
                                   create_commit,
                                  x_err_stack,
                                  x_err_stage,
                                  x_err_code );
                           else
   			   If v_noof_tasks > 0 Then
                             v_task_array(1) := x_res_accum_rec.task_id;
       		   	     For i in 1..v_noof_tasks LOOP

 				Check_Accum_Res_Tasks
			         ( x_project_id,
                               	   v_task_array(i),
				   x_Proj_Accum_id,
				   x_current_period,
                                   curr_rlid,
                                   curr_rlmid,
                                   curr_rid,
                                   curr_rlaid,
                                   create_actuals,
                                   create_commit,
                               	   x_err_stack,
                               	   x_err_stage,
                               	   x_err_code );

			     END LOOP;
			   END IF;
                          end if;
                         end if;

                        initialize_task_level;
                        create_actuals := 'N';
                        create_commit := 'N';
                        Fetch_res := FALSE;

			END IF;

		     ELSE
                        if curr_res_task = 0 then
                              Check_Accum_Res_Tasks
                                 ( x_project_id,
                                   0,
                                   x_Proj_Accum_id,
                                   x_current_period,
                                   curr_rlid,
                                   curr_rlmid,
                                   curr_rid,
                                   curr_rlaid,
                                   create_actuals,
                                   create_commit,
                                   x_err_stack,
                                   x_err_stage,
                                   x_err_code );
                       else
                       If curr_parent_id = curr_res_task then
                             Check_Accum_Res_Tasks
                              ( x_project_id,
                                  curr_res_task,
                                  x_Proj_Accum_id,
                                  x_current_period,
                                   curr_rlid,
                                   curr_rlmid,
                                   curr_rid,
                                   curr_rlaid,
                                   create_actuals,
                                   create_commit,
                                  x_err_stack,
                                  x_err_stage,
                                  x_err_code );
                        else
                           if v_noof_tasks > 0 then
                           v_task_array(1) := curr_res_task;
       		   	   For i in 1..v_noof_tasks LOOP
 			     Check_Accum_Res_Tasks
				( x_project_id,
                                  v_task_array(i),
				  x_Proj_Accum_id,
				  x_current_period,
                                   curr_rlid,
                                   curr_rlmid,
                                   curr_rid,
                                   curr_rlaid,
                                   create_actuals,
                                   create_commit,
                                  x_err_stack,
                                  x_err_stage,
                                  x_err_code );
			   END LOOP;
                          end if;
			END IF;
                       end if;
			-- Initialize amount variables
                        initialize_task_level;

                        create_actuals := 'N';
                        create_commit := 'N';
		 	Fetch_res := False;
		 	curr_rlmid := x_Res_Accum_rec.resource_list_member_id;

                       if curr_res_task = 0 and
                          x_res_accum_rec.parent_task_id <> 0 then
                          curr_parent_id := prev_parent_id;
                       end if;

	                curr_res_task := x_res_accum_rec.task_id;
		    if x_res_accum_rec.parent_task_id <> curr_parent_id then
			  exit;
		    end if;
                    exit when res_accum_cur%notfound;
	    END IF;
	    Curr_rlmid := x_Res_Accum_rec.resource_list_member_id;
	    curr_res_task := x_res_accum_rec.task_id;
           END LOOP; -- End of x_Res_Accum_rec in Res_accum_Cur LOOP
          else
             --- create task level record
                      if pa_proj_accum_main.x_summ_process <> 'RL' and
                         curr_parent_id <> 0 then
 			     Check_Accum_Res_Tasks
				( x_project_id,
                                  curr_task_id,
				  x_Proj_Accum_id,
				  x_current_period,
                                  0,
                                  0,
                                  0,
                                  0,
                                  create_actuals,
                                  create_commit,
                                  x_err_stack,
                                  x_err_stage,
                                  x_err_code );
                      end if;
             --- add amounts in parent_level
             if curr_parent_id > 0 and curr_parent_id <> curr_task_id then
                            add_parent_amounts;
             end if;
             initialize_task_level;
             create_actuals := 'N';
             create_commit :=  'N';
             fetch_task := False;
         end if;

	END IF;
      Exit when PA_TXN_ACCUM_CUR%NOTFOUND;
	Curr_task_id := x_Txn_Accum_rec.Task_id;
        Curr_parent_id := x_txn_accum_rec.top_task_id;

-- After processing the records, Update the PA_TXN_ACCUM , modifying  the
      if pa_proj_accum_main.x_summ_process <> 'RL' then
    	Update PA_TXN_ACCUM Set
        	TOT_REVENUE   	  = NVL(TOT_REVENUE,0) + NVL(I_TOT_REVENUE,0),
        	TOT_RAW_COST  	  = NVL(TOT_RAW_COST,0) + NVL(I_TOT_RAW_COST,0),
        	TOT_BURDENED_COST = NVL(TOT_BURDENED_COST,0) +
              		            NVL(I_TOT_BURDENED_COST,0),
        	TOT_LABOR_HOURS   = NVL(TOT_LABOR_HOURS,0) +
               		            NVL(I_TOT_LABOR_HOURS,0),
        	TOT_QUANTITY      = NVL(TOT_QUANTITY,0) + NVL(I_TOT_QUANTITY,0),
        	TOT_BILLABLE_QUANTITY = NVL(TOT_BILLABLE_QUANTITY,0) +
               		            NVL(I_TOT_BILLABLE_QUANTITY,0),
        	TOT_BILLABLE_RAW_COST = NVL(TOT_BILLABLE_RAW_COST,0) +
               		            NVL(I_TOT_BILLABLE_RAW_COST,0),
        	TOT_BILLABLE_BURDENED_COST = NVL(TOT_BILLABLE_BURDENED_COST,0) +
               	                    NVL(I_TOT_BILLABLE_BURDENED_COST,0),
        	TOT_BILLABLE_LABOR_HOURS = NVL(TOT_BILLABLE_LABOR_HOURS,0) +
                                    NVL(I_TOT_BILLABLE_LABOR_HOURS,0),
        	I_TOT_REVENUE         		= 0,
        	I_TOT_RAW_COST        		= 0,
        	I_TOT_BURDENED_COST   		= 0,
        	I_TOT_LABOR_HOURS     		= 0,
        	I_TOT_QUANTITY        		= 0,
        	I_TOT_BILLABLE_QUANTITY		= 0,
        	I_TOT_BILLABLE_RAW_COST		= 0,
        	I_TOT_BILLABLE_BURDENED_COST	= 0,
        	I_TOT_BILLABLE_LABOR_HOURS	= 0,
        	ACTUAL_COST_ROLLUP_FLAG   	= decode(x_actual_cost_flag,'Y','N',actual_cost_rollup_flag),
        	REVENUE_ROLLUP_FLAG             = decode(x_revenue_flag,'Y','N',revenue_rollup_flag),
		CMT_ROLLUP_FLAG 		= decode(x_commitments_flag,'Y','N',cmt_rollup_flag),
       		last_updated_by        = pa_proj_accum_main.x_last_updated_by,
       		last_update_date       = SYSDATE,
       		request_id             = pa_proj_accum_main.x_request_id,
       		program_application_id =
				pa_proj_accum_main.x_program_application_id,
       		program_id             = pa_proj_accum_main.x_program_id,
       		program_update_date    = SYSDATE
                Where  TXN_ACCUM_ID = x_txn_accum_rec.txn_accum_id;
       end if;
    END LOOP; -- End of x_Txn_Accum_rec in PA_Txn_Accum_cur LOOP

    CLOSE PA_Txn_Accum_Cur;
    CLOSE res_accum_cur;
    -- Update pa_project_accum_actuals project level records
     if (x_actual_cost_flag = 'Y' or x_revenue_flag = 'Y')
                   and pa_proj_accum_main.x_summ_process <> 'RL' then
	      UPDATE Pa_Project_Accum_actuals PAA SET
		    Raw_cost_itd = nvl(raw_cost_itd,0) + Tsk_raw_cost_itd,
		    Raw_cost_ytd = nvl(raw_cost_ytd,0) + Tsk_raw_cost_ytd,
		    Raw_cost_pp  = nvl(raw_cost_pp,0) + Tsk_raw_cost_pp,
		    Raw_cost_ptd = nvl(raw_cost_ptd,0) + Tsk_raw_cost_ptd,
		    billable_raw_cost_itd = nvl(billable_raw_cost_itd,0) +
                                        Tsk_bill_raw_cost_itd,
		    billable_raw_cost_ytd = nvl(billable_raw_cost_ytd,0) +
                                        Tsk_bill_raw_cost_ytd,
		    billable_raw_cost_pp  = nvl(billable_raw_cost_pp,0) +
                                        Tsk_bill_raw_cost_pp,
		    billable_raw_cost_ptd = nvl(billable_raw_cost_ptd,0) +
                                        Tsk_bill_raw_cost_ptd,
		    burdened_cost_itd = nvl(burdened_cost_itd,0) +
                                    Tsk_burd_cost_itd,
		    burdened_cost_ytd = nvl(burdened_cost_ytd,0) + Tsk_burd_cost_ytd,
		    burdened_cost_pp  = nvl(burdened_cost_pp,0) + Tsk_burd_cost_pp,
		    burdened_cost_ptd = nvl(burdened_cost_ptd,0) + Tsk_burd_cost_ptd,
		    billable_burdened_cost_itd = nvl(billable_burdened_cost_itd,0) + Tsk_bill_burd_cost_itd,
		    billable_burdened_cost_ytd = nvl(billable_burdened_cost_ytd,0) + Tsk_bill_burd_cost_ytd,
		    billable_burdened_cost_pp  = nvl(billable_burdened_cost_pp,0) + Tsk_bill_burd_cost_pp,
		    billable_burdened_cost_ptd = nvl(billable_burdened_cost_ptd,0) + Tsk_bill_burd_cost_ptd,
		    quantity_itd = nvl(quantity_itd,0) + Tsk_quantity_itd,
		    quantity_ytd = nvl(quantity_ytd,0) + Tsk_quantity_ytd,
		    quantity_pp  = nvl(quantity_pp,0) + Tsk_quantity_pp,
		    quantity_ptd = nvl(quantity_ptd,0) + Tsk_quantity_ptd,
		    labor_hours_itd = nvl(labor_hours_itd,0) + Tsk_labor_hours_itd,
		    labor_hours_ytd = nvl(labor_hours_ytd,0) + Tsk_labor_hours_ytd,
		    labor_hours_pp  = nvl(labor_hours_pp,0) + Tsk_labor_hours_pp,
		    labor_hours_ptd = nvl(labor_hours_ptd,0) + Tsk_labor_hours_ptd,
		    billable_quantity_itd = nvl(billable_quantity_itd,0) + Tsk_bill_quantity_itd,
		    billable_quantity_ytd = nvl(billable_quantity_ytd,0) + Tsk_bill_quantity_ytd,
		    billable_quantity_pp  = nvl(billable_quantity_pp,0) + Tsk_bill_quantity_pp,
		    billable_quantity_ptd = nvl(billable_quantity_ptd,0) + Tsk_bill_quantity_ptd,
		    billable_labor_hours_itd = nvl(billable_labor_hours_itd,0) + Tsk_bill_labor_hours_itd,
		    billable_labor_hours_ytd = nvl(billable_labor_hours_ytd,0) + Tsk_bill_labor_hours_ytd,
		    billable_labor_hours_pp  = nvl(billable_labor_hours_pp,0) + Tsk_bill_labor_hours_pp,
		    billable_labor_hours_ptd = nvl(billable_labor_hours_ptd,0) + Tsk_bill_labor_hours_ptd,
		    revenue_itd = nvl(revenue_itd,0) + Tsk_revenue_itd,
		    revenue_ytd = nvl(revenue_ytd,0) + Tsk_revenue_ytd,
		    revenue_pp  = nvl(revenue_pp,0) + Tsk_revenue_pp,
		    revenue_ptd = nvl(revenue_ptd,0) + Tsk_revenue_ptd,
        	    txn_unit_of_measure = NULL,
		    request_id = pa_proj_accum_main.x_request_id,
		    last_updated_by = pa_proj_accum_main.x_last_updated_by,
		    last_update_date = Trunc(sysdate),
        	    creation_date = Trunc(Sysdate),
		    created_by = pa_proj_accum_main.x_created_by,
		    last_update_login = pa_proj_accum_main.x_last_update_login
              Where PAA.Project_Accum_id     In
             (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
              Where Pah.Project_id = x_project_id and
              pah.Resource_list_member_id = 0 and
              Pah.Task_id = 0);
      if sql%notfound then

            Select project_accum_id into v_accum_id
              from pa_project_accum_headers
             where project_id = x_project_id
               and task_id = 0
               and resource_list_member_id = 0;

       	   Insert into PA_PROJECT_ACCUM_ACTUALS (
       	    PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
       	    BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
       	    BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
       	    BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
       	    BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
       	    BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
       	    QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
       	    LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
       	    BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
       	    BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
       	    BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
       	    REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
       	    REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,
	    CREATED_BY,LAST_UPDATE_LOGIN)
	    Values (V_Accum_id,
		    Tsk_raw_cost_itd,
		    Tsk_raw_cost_ytd,
		    Tsk_raw_cost_pp,
		    Tsk_raw_cost_ptd,
		    Tsk_bill_raw_cost_itd,
		    Tsk_bill_raw_cost_ytd,
		    Tsk_bill_raw_cost_pp,
		    Tsk_bill_raw_cost_ptd,
		    Tsk_burd_cost_itd,
		    Tsk_burd_cost_ytd,
		    Tsk_burd_cost_pp,
		    Tsk_burd_cost_ptd,
		    Tsk_bill_burd_cost_itd,
		    Tsk_bill_burd_cost_ytd,
		    Tsk_bill_burd_cost_pp,
		    Tsk_bill_burd_cost_ptd,
		    Tsk_quantity_itd,
		    Tsk_quantity_ytd,
		    Tsk_quantity_pp,
		    Tsk_quantity_ptd,
		    Tsk_labor_hours_itd,
		    Tsk_labor_hours_ytd,
		    Tsk_labor_hours_pp,
		    Tsk_labor_hours_ptd,
		    Tsk_bill_quantity_itd,
		    Tsk_bill_quantity_ytd,
		    Tsk_bill_quantity_pp,
		    Tsk_bill_quantity_ptd,
		    Tsk_bill_labor_hours_itd,
		    Tsk_bill_labor_hours_ytd,
		    Tsk_bill_labor_hours_pp,
		    Tsk_bill_labor_hours_ptd,
		    Tsk_revenue_itd,
		    Tsk_revenue_ytd,
		    Tsk_revenue_pp,
		    Tsk_revenue_ptd,
        	    NULL,
		    pa_proj_accum_main.x_request_id,
		    pa_proj_accum_main.x_last_updated_by,
		    Trunc(sysdate),
        	    Trunc(Sysdate),
		    pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login);
      end if;
     end if;
     if x_commitments_flag = 'Y' and pa_proj_accum_main.x_summ_process <> 'RL' then
	      UPDATE Pa_Project_Accum_Commitments PAA SET
		    Cmt_Raw_cost_itd = nvl(Cmt_Raw_cost_itd,0) + Tsk_cmt_raw_cost_itd,
		    Cmt_Raw_cost_ytd = nvl(Cmt_Raw_cost_ytd,0) + Tsk_cmt_raw_cost_ytd,
		    Cmt_Raw_cost_pp  = nvl(Cmt_Raw_cost_pp,0) + Tsk_cmt_raw_cost_pp,
		    Cmt_Raw_cost_ptd = nvl(Cmt_Raw_cost_ptd,0) + Tsk_cmt_raw_cost_ptd,
		    Cmt_burdened_cost_itd = nvl(Cmt_burdened_cost_itd,0) + Tsk_cmt_burd_cost_itd,
		    Cmt_burdened_cost_ytd = nvl(Cmt_burdened_cost_ytd,0) + Tsk_cmt_burd_cost_ytd,
		    Cmt_burdened_cost_pp  = nvl(Cmt_burdened_cost_pp,0) + Tsk_cmt_burd_cost_pp,
		    Cmt_burdened_cost_ptd = nvl(Cmt_burdened_cost_ptd,0) + Tsk_cmt_burd_cost_ptd,
		    Cmt_quantity_itd = nvl(Cmt_quantity_itd,0) + Tsk_cmt_quantity_itd,
		    Cmt_quantity_ytd = nvl(Cmt_quantity_ytd,0) + Tsk_cmt_quantity_ytd,
		    Cmt_quantity_pp  = nvl(Cmt_quantity_pp,0) + Tsk_cmt_quantity_pp,
		    Cmt_quantity_ptd = nvl(Cmt_quantity_ptd,0) + Tsk_cmt_quantity_ptd,
        	    cmt_unit_of_measure = NULL,
		    request_id = pa_proj_accum_main.x_request_id,
		    last_updated_by = pa_proj_accum_main.x_last_updated_by,
		    last_update_date = Trunc(sysdate),
        	    creation_date = Trunc(Sysdate),
		    created_by = pa_proj_accum_main.x_created_by,
		    last_update_login = pa_proj_accum_main.x_last_update_login
              Where PAA.Project_Accum_id     In
             (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
              Where Pah.Project_id = x_project_id and
              pah.Resource_list_member_id = 0 and
              Pah.Task_id = 0);

            If sql%notfound then

            Select project_accum_id into v_accum_id
              from pa_project_accum_headers
             where project_id = x_project_id
               and task_id = 0
               and resource_list_member_id = 0;

       	    Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       	    PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
            CMT_RAW_COST_PTD,
            CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
            CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       	    CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       	    CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       	    CMT_UNIT_OF_MEASURE,
       	    LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       	    LAST_UPDATE_LOGIN)
	    Values (V_Accum_id,
       		    Tsk_cmt_raw_cost_itd,
       		    Tsk_cmt_raw_cost_ytd,
       		    Tsk_cmt_raw_cost_pp,
       		    Tsk_cmt_raw_cost_ptd,
       		    Tsk_cmt_burd_cost_itd,
       		    Tsk_cmt_burd_cost_ytd,
       		    Tsk_cmt_burd_cost_pp,
       		    Tsk_cmt_burd_cost_ptd,
       		    Tsk_cmt_quantity_itd,
       		    Tsk_cmt_quantity_ytd,
       		    Tsk_cmt_quantity_pp,
       		    Tsk_cmt_quantity_ptd,
		    NULL,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        	    Trunc(Sysdate),pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login);
            end if;
        end if;
         update pa_resource_list_assignments
            set resource_list_accumulated_flag = 'Y'
          where project_id = x_project_id
                and resource_list_id = nvl(x_resource_list_id,resource_list_id);
    -- Restore the old x_err_stack;

    x_err_stack := V_Old_Stack;

  Exception
   When Others Then
     x_err_code := SQLCODE;
     RAISE;
 End Process_Txn_Accum ;


 Procedure Check_Accum_Res_Tasks ( x_project_id In Number,
                                  x_task_id    In Number,
				  x_Proj_Accum_id In Number,
				  x_current_period In VARCHAR2,
                                  x_resource_list_id in Number,
                                  x_resource_list_Member_id in Number,
                                  x_resource_id in Number,
                                  x_resource_list_assignment_id in Number,
                                  x_create_actuals in varchar2,
                                  x_create_commit  in varchar2,
                                  x_err_stack     In Out NOCOPY Varchar2,
                                  x_err_stage     In Out NOCOPY Varchar2,
                                  x_err_code      In Out NOCOPY Number ) IS

 x_dummy_var	VARCHAR2(1) := NULL;
 V_accum_id	NUMBER	    := 0;
 V_old_stack    VARCHAR2(630);
 x_paa_flag	VARCHAR2(1) := 'Y';
 x_pac_flag	VARCHAR2(1) := 'Y';

 BEGIN

    V_Old_Stack := x_err_stack;
    x_err_stack :=
    x_err_stack ||'->PA_MAINT_PROJECT_ACCUMS.Check_Accum_Res_Tasks';
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    pa_debug.debug(x_err_stack);
    END IF;
   If x_create_actuals = 'Y' or x_create_commit = 'Y' then
    BEGIN
	SELECT	project_accum_id INTO V_accum_id
	FROM	Pa_Project_Accum_Headers PAH
	WHERE	PAH.Project_id = x_project_id
	AND	PAH.Task_id    = x_task_id
	AND     PAH.Resource_List_Member_id = x_resource_list_member_id;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
	   From Dual;

           Insert into PA_PROJECT_ACCUM_HEADERS
           (PROJECT_ACCUM_ID,PROJECT_ID,TASK_ID,ACCUM_PERIOD,RESOURCE_ID,
            RESOURCE_LIST_ID,RESOURCE_LIST_ASSIGNMENT_ID,
            RESOURCE_LIST_MEMBER_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,
            REQUEST_ID,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN )
            Values (v_accum_id,X_project_id,x_task_id,
                    x_current_period,
                    x_resource_id,x_resource_list_id,
                    x_resource_list_assignment_id,x_resource_list_Member_id,
                    pa_proj_accum_main.x_last_updated_by,
		    Trunc(sysdate),pa_proj_accum_main.x_request_id,
		    trunc(sysdate),
                    pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login );

          If x_create_actuals = 'Y' then
       	   Insert into PA_PROJECT_ACCUM_ACTUALS (
       	    PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
       	    BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
       	    BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
       	    BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
       	    BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
       	    BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
       	    QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
       	    LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
       	    BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
       	    BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
       	    BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
       	    REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
       	    REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,
	    CREATED_BY,LAST_UPDATE_LOGIN)
	    Values (V_Accum_id,
		    New_raw_cost_itd,
		    New_raw_cost_ytd,
		    New_raw_cost_pp,
		    New_raw_cost_ptd,
		    New_bill_raw_cost_itd,
		    New_bill_raw_cost_ytd,
		    New_bill_raw_cost_pp,
		    New_bill_raw_cost_ptd,
		    New_burd_cost_itd,
		    New_burd_cost_ytd,
		    New_burd_cost_pp,
		    New_burd_cost_ptd,
		    New_bill_burd_cost_itd,
		    New_bill_burd_cost_ytd,
		    New_bill_burd_cost_pp,
		    New_bill_burd_cost_ptd,
		    New_quantity_itd,
		    New_quantity_ytd,
		    New_quantity_pp,
		    New_quantity_ptd,
		    New_labor_hours_itd,
		    New_labor_hours_ytd,
		    New_labor_hours_pp,
		    New_labor_hours_ptd,
		    New_bill_quantity_itd,
		    New_bill_quantity_ytd,
		    New_bill_quantity_pp,
		    New_bill_quantity_ptd,
		    New_bill_labor_hours_itd,
		    New_bill_labor_hours_ytd,
		    New_bill_labor_hours_pp,
		    New_bill_labor_hours_ptd,
		    New_revenue_itd,
		    New_revenue_ytd,
		    New_revenue_pp,
		    New_revenue_ptd,
        	    NULL,
		    pa_proj_accum_main.x_request_id,
		    pa_proj_accum_main.x_last_updated_by,
		    Trunc(sysdate),
        	    Trunc(Sysdate),
		    pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login);
            end if;
            If x_create_commit = 'Y' then
       	    Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       	    PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
            CMT_RAW_COST_PTD,
            CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
            CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       	    CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       	    CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       	    CMT_UNIT_OF_MEASURE,
       	    LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       	    LAST_UPDATE_LOGIN)
	    Values (V_Accum_id,
       		    New_cmt_raw_cost_itd,
       		    New_cmt_raw_cost_ytd,
       		    New_cmt_raw_cost_pp,
       		    New_cmt_raw_cost_ptd,
       		    New_cmt_burd_cost_itd,
       		    New_cmt_burd_cost_ytd,
       		    New_cmt_burd_cost_pp,
       		    New_cmt_burd_cost_ptd,
       		    New_cmt_quantity_itd,
       		    New_cmt_quantity_ytd,
       		    New_cmt_quantity_pp,
       		    New_cmt_quantity_ptd,
		    NULL,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        	    Trunc(Sysdate),pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login);
            end if;
	    x_paa_flag := 'N';
	    x_pac_flag := 'N';

    END;

    IF x_paa_flag = 'Y' and x_create_actuals = 'Y' THEN

    BEGIN

	      UPDATE Pa_Project_Accum_actuals PAA SET
		    Raw_cost_itd = nvl(Raw_cost_itd,0) + New_raw_cost_itd,
		    Raw_cost_ytd = nvl(Raw_cost_ytd,0) + New_raw_cost_ytd,
		    Raw_cost_pp  = nvl(Raw_cost_pp,0) + New_raw_cost_pp,
		    Raw_cost_ptd = nvl(Raw_cost_ptd,0) + New_raw_cost_ptd,
		    billable_raw_cost_itd = nvl(billable_raw_cost_itd,0) + New_bill_raw_cost_itd,
		    billable_raw_cost_ytd = nvl(billable_raw_cost_ytd,0) + New_bill_raw_cost_ytd,
		    billable_raw_cost_pp  = nvl(billable_raw_cost_pp,0) + New_bill_raw_cost_pp,
		    billable_raw_cost_ptd = nvl(billable_raw_cost_ptd,0) + New_bill_raw_cost_ptd,
		    burdened_cost_itd = nvl(burdened_cost_itd,0) + New_burd_cost_itd,
		    burdened_cost_ytd = nvl(burdened_cost_ytd,0) + New_burd_cost_ytd,
		    burdened_cost_pp  = nvl(burdened_cost_pp,0) + New_burd_cost_pp,
		    burdened_cost_ptd = nvl(burdened_cost_ptd,0) + New_burd_cost_ptd,
		    billable_burdened_cost_itd = nvl(billable_burdened_cost_itd,0) + New_bill_burd_cost_itd,
		    billable_burdened_cost_ytd = nvl(billable_burdened_cost_ytd,0) + New_bill_burd_cost_ytd,
		    billable_burdened_cost_pp  = nvl(billable_burdened_cost_pp,0) + New_bill_burd_cost_pp,
		    billable_burdened_cost_ptd = nvl(billable_burdened_cost_ptd,0) + New_bill_burd_cost_ptd,
		    quantity_itd = nvl(quantity_itd,0) + New_quantity_itd,
		    quantity_ytd = nvl(quantity_ytd,0) + New_quantity_ytd,
		    quantity_pp  = nvl(quantity_pp,0) + New_quantity_pp,
		    quantity_ptd = nvl(quantity_ptd,0) + New_quantity_ptd,
		    labor_hours_itd = nvl(labor_hours_itd,0) + New_labor_hours_itd,
		    labor_hours_ytd = nvl(labor_hours_ytd,0) + New_labor_hours_ytd,
		    labor_hours_pp  = nvl(labor_hours_pp,0) + New_labor_hours_pp,
		    labor_hours_ptd = nvl(labor_hours_ptd,0) + New_labor_hours_ptd,
		    billable_quantity_itd = nvl(billable_quantity_itd,0) + New_bill_quantity_itd,
		    billable_quantity_ytd = nvl(billable_quantity_ytd,0) + New_bill_quantity_ytd,
		    billable_quantity_pp  = nvl(billable_quantity_pp,0) + New_bill_quantity_pp,
		    billable_quantity_ptd = nvl(billable_quantity_ptd,0) + New_bill_quantity_ptd,
		    billable_labor_hours_itd = nvl(billable_labor_hours_itd,0) + New_bill_labor_hours_itd,
		    billable_labor_hours_ytd = nvl(billable_labor_hours_ytd,0) + New_bill_labor_hours_ytd,
		    billable_labor_hours_pp  = nvl(billable_labor_hours_pp,0) + New_bill_labor_hours_pp,
		    billable_labor_hours_ptd = nvl(billable_labor_hours_ptd,0) + New_bill_labor_hours_ptd,
		    revenue_itd = nvl(revenue_itd,0) + New_revenue_itd,
		    revenue_ytd = nvl(revenue_ytd,0) + New_revenue_ytd,
		    revenue_pp  = nvl(revenue_pp,0) + New_revenue_pp,
		    revenue_ptd = nvl(revenue_ptd,0) + New_revenue_ptd,
        	    txn_unit_of_measure = NULL,
		    request_id = pa_proj_accum_main.x_request_id,
		    last_updated_by = pa_proj_accum_main.x_last_updated_by,
		    last_update_date = Trunc(sysdate),
        	    creation_date = Trunc(Sysdate),
		    created_by = pa_proj_accum_main.x_created_by,
		    last_update_login = pa_proj_accum_main.x_last_update_login
               Where PAA.Project_Accum_id = v_accum_id;

   if sql%notfound then
       	   Insert into PA_PROJECT_ACCUM_ACTUALS (
       	    PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
       	    BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
       	    BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
       	    BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
       	    BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
       	    BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
       	    QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
       	    LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
       	    BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
       	    BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
       	    BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
       	    REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
       	    REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,
	    CREATED_BY,LAST_UPDATE_LOGIN)
	    Values (V_Accum_id,
		    New_raw_cost_itd,
		    New_raw_cost_ytd,
		    New_raw_cost_pp,
		    New_raw_cost_ptd,
		    New_bill_raw_cost_itd,
		    New_bill_raw_cost_ytd,
		    New_bill_raw_cost_pp,
		    New_bill_raw_cost_ptd,
		    New_burd_cost_itd,
		    New_burd_cost_ytd,
		    New_burd_cost_pp,
		    New_burd_cost_ptd,
		    New_bill_burd_cost_itd,
		    New_bill_burd_cost_ytd,
		    New_bill_burd_cost_pp,
		    New_bill_burd_cost_ptd,
		    New_quantity_itd,
		    New_quantity_ytd,
		    New_quantity_pp,
		    New_quantity_ptd,
		    New_labor_hours_itd,
		    New_labor_hours_ytd,
		    New_labor_hours_pp,
		    New_labor_hours_ptd,
		    New_bill_quantity_itd,
		    New_bill_quantity_ytd,
		    New_bill_quantity_pp,
		    New_bill_quantity_ptd,
		    New_bill_labor_hours_itd,
		    New_bill_labor_hours_ytd,
		    New_bill_labor_hours_pp,
		    New_bill_labor_hours_ptd,
		    New_revenue_itd,
		    New_revenue_ytd,
		    New_revenue_pp,
		    New_revenue_ptd,
        	    NULL,
		    pa_proj_accum_main.x_request_id,
		    pa_proj_accum_main.x_last_updated_by,
		    Trunc(sysdate),
        	    Trunc(Sysdate),
		    pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login);
   end if;

    END;

    END IF;

    IF x_pac_flag = 'Y' and x_create_commit = 'Y' THEN

    BEGIN

	      UPDATE Pa_Project_Accum_Commitments PAA SET
		    Cmt_Raw_cost_itd = nvl(Cmt_Raw_cost_itd,0) + New_cmt_raw_cost_itd,
		    Cmt_Raw_cost_ytd = nvl(Cmt_Raw_cost_ytd,0) + New_cmt_raw_cost_ytd,
		    Cmt_Raw_cost_pp  = nvl(Cmt_Raw_cost_pp,0) + New_cmt_raw_cost_pp,
		    Cmt_Raw_cost_ptd = nvl(Cmt_Raw_cost_ptd,0) + New_cmt_raw_cost_ptd,
		    Cmt_burdened_cost_itd = nvl(Cmt_burdened_cost_itd,0) + New_cmt_burd_cost_itd,
		    Cmt_burdened_cost_ytd = nvl(Cmt_burdened_cost_ytd,0) + New_cmt_burd_cost_ytd,
		    Cmt_burdened_cost_pp  = nvl(Cmt_burdened_cost_pp,0) + New_cmt_burd_cost_pp,
		    Cmt_burdened_cost_ptd = nvl(Cmt_burdened_cost_ptd,0) + New_cmt_burd_cost_ptd,
		    Cmt_quantity_itd = nvl(Cmt_quantity_itd,0) + New_cmt_quantity_itd,
		    Cmt_quantity_ytd = nvl(Cmt_quantity_ytd,0) + New_cmt_quantity_ytd,
		    Cmt_quantity_pp  = nvl(Cmt_quantity_pp,0) + New_cmt_quantity_pp,
		    Cmt_quantity_ptd = nvl(Cmt_quantity_ptd,0) + New_cmt_quantity_ptd,
        	    cmt_unit_of_measure = NULL,
		    request_id = pa_proj_accum_main.x_request_id,
		    last_updated_by = pa_proj_accum_main.x_last_updated_by,
		    last_update_date = Trunc(sysdate),
        	    creation_date = Trunc(Sysdate),
		    created_by = pa_proj_accum_main.x_created_by,
		    last_update_login = pa_proj_accum_main.x_last_update_login
              Where PAA.Project_Accum_id = v_accum_id;

       if sql%notfound then
       	    Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       	    PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
            CMT_RAW_COST_PTD,
            CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
            CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       	    CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       	    CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       	    CMT_UNIT_OF_MEASURE,
       	    LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       	    LAST_UPDATE_LOGIN)
	    Values (V_Accum_id,
       		    New_cmt_raw_cost_itd,
       		    New_cmt_raw_cost_ytd,
       		    New_cmt_raw_cost_pp,
       		    New_cmt_raw_cost_ptd,
       		    New_cmt_burd_cost_itd,
       		    New_cmt_burd_cost_ytd,
       		    New_cmt_burd_cost_pp,
       		    New_cmt_burd_cost_ptd,
       		    New_cmt_quantity_itd,
       		    New_cmt_quantity_ytd,
       		    New_cmt_quantity_pp,
       		    New_cmt_quantity_ptd,
		    NULL,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        	    Trunc(Sysdate),pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login);
     end if;
    END ;

    END IF;
 End if;
    x_err_stack := V_Old_Stack;

EXCEPTION
   When Others Then
     x_err_code := SQLCODE;
     RAISE;

 END Check_Accum_res_tasks;


 Procedure Check_Accum_wbs ( x_project_id In Number,
                                  x_task_id    In Number,
				  x_Proj_Accum_id In Number,
				  x_current_period In VARCHAR2,
                                  x_resource_list_id in Number,
                                  x_resource_list_Member_id in Number,
                                  x_resource_id in Number,
                                  x_resource_list_assignment_id in Number,
                                  x_create_wbs_actuals in varchar2,
                                  x_create_wbs_commit  in varchar2,
                                  x_err_stack     In Out NOCOPY Varchar2,
                                  x_err_stage     In Out NOCOPY Varchar2,
                                  x_err_code      In Out NOCOPY Number ) IS

 x_dummy_var	VARCHAR2(1) := NULL;
 V_accum_id	NUMBER	    := 0;
 V_old_stack    VARCHAR2(630);
 x_paa_flag	VARCHAR2(1) := 'Y';
 x_pac_flag	VARCHAR2(1) := 'Y';

 BEGIN

    V_Old_Stack := x_err_stack;
    x_err_stack :=
    x_err_stack ||'->PA_MAINT_PROJECT_ACCUMS.Check_Accum_WBS';
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    pa_debug.debug(x_err_stack);
    END IF;
   If x_create_wbs_actuals = 'Y' or x_create_wbs_commit = 'Y' then
    BEGIN
	SELECT	project_accum_id INTO V_accum_id
	FROM	Pa_Project_Accum_Headers PAH
	WHERE	PAH.Project_id = x_project_id
	AND	PAH.Task_id    = x_task_id
	AND     PAH.Resource_List_Member_id = x_resource_list_member_id;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
	   From Dual;

           Insert into PA_PROJECT_ACCUM_HEADERS
           (PROJECT_ACCUM_ID,PROJECT_ID,TASK_ID,ACCUM_PERIOD,RESOURCE_ID,
            RESOURCE_LIST_ID,RESOURCE_LIST_ASSIGNMENT_ID,
            RESOURCE_LIST_MEMBER_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,
            REQUEST_ID,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN )
            Values (v_accum_id,X_project_id,x_task_id,
                    x_current_period,
                    x_resource_id,x_resource_list_id,
                    x_resource_list_assignment_id,x_resource_list_Member_id,
                    pa_proj_accum_main.x_last_updated_by,
		    Trunc(sysdate),pa_proj_accum_main.x_request_id,
		    trunc(sysdate),
                    pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login );

          If x_create_wbs_actuals = 'Y' then
       	   Insert into PA_PROJECT_ACCUM_ACTUALS (
       	    PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
       	    BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
       	    BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
       	    BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
       	    BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
       	    BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
       	    QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
       	    LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
       	    BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
       	    BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
       	    BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
       	    REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
       	    REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,
	    CREATED_BY,LAST_UPDATE_LOGIN)
	    Values (V_Accum_id,
		    Prt_raw_cost_itd,
		    Prt_raw_cost_ytd,
		    Prt_raw_cost_pp,
		    Prt_raw_cost_ptd,
		    Prt_bill_raw_cost_itd,
		    Prt_bill_raw_cost_ytd,
		    Prt_bill_raw_cost_pp,
		    Prt_bill_raw_cost_ptd,
		    Prt_burd_cost_itd,
		    Prt_burd_cost_ytd,
		    Prt_burd_cost_pp,
		    Prt_burd_cost_ptd,
		    Prt_bill_burd_cost_itd,
		    Prt_bill_burd_cost_ytd,
		    Prt_bill_burd_cost_pp,
		    Prt_bill_burd_cost_ptd,
		    Prt_quantity_itd,
		    Prt_quantity_ytd,
		    Prt_quantity_pp,
		    Prt_quantity_ptd,
		    Prt_labor_hours_itd,
		    Prt_labor_hours_ytd,
		    Prt_labor_hours_pp,
		    Prt_labor_hours_ptd,
		    Prt_bill_quantity_itd,
		    Prt_bill_quantity_ytd,
		    Prt_bill_quantity_pp,
		    Prt_bill_quantity_ptd,
		    Prt_bill_labor_hours_itd,
		    Prt_bill_labor_hours_ytd,
		    Prt_bill_labor_hours_pp,
		    Prt_bill_labor_hours_ptd,
		    Prt_revenue_itd,
		    Prt_revenue_ytd,
		    Prt_revenue_pp,
		    Prt_revenue_ptd,
        	    NULL,
		    pa_proj_accum_main.x_request_id,
		    pa_proj_accum_main.x_last_updated_by,
		    Trunc(sysdate),
        	    Trunc(Sysdate),
		    pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login);
            end if;
            If x_create_wbs_commit = 'Y' then
       	    Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       	    PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
            CMT_RAW_COST_PTD,
            CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
            CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       	    CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       	    CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       	    CMT_UNIT_OF_MEASURE,
       	    LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       	    LAST_UPDATE_LOGIN)
	    Values (V_Accum_id,
       		    Prt_cmt_raw_cost_itd,
       		    Prt_cmt_raw_cost_ytd,
       		    Prt_cmt_raw_cost_pp,
       		    Prt_cmt_raw_cost_ptd,
       		    Prt_cmt_burd_cost_itd,
       		    Prt_cmt_burd_cost_ytd,
       		    Prt_cmt_burd_cost_pp,
       		    Prt_cmt_burd_cost_ptd,
       		    Prt_cmt_quantity_itd,
       		    Prt_cmt_quantity_ytd,
       		    Prt_cmt_quantity_pp,
       		    Prt_cmt_quantity_ptd,
		    NULL,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        	    Trunc(Sysdate),pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login);
            end if;
	    x_paa_flag := 'N';
	    x_pac_flag := 'N';

    END;

    IF x_paa_flag = 'Y' and x_create_wbs_actuals = 'Y' THEN

    BEGIN

	      UPDATE Pa_Project_Accum_actuals PAA SET
		    Raw_cost_itd = nvl(Raw_cost_itd,0) + Prt_raw_cost_itd,
		    Raw_cost_ytd = nvl(Raw_cost_ytd,0) + Prt_raw_cost_ytd,
		    Raw_cost_pp  = nvl(Raw_cost_pp,0) + Prt_raw_cost_pp,
		    Raw_cost_ptd = nvl(Raw_cost_ptd,0) + Prt_raw_cost_ptd,
		    billable_raw_cost_itd = nvl(billable_raw_cost_itd,0) + Prt_bill_raw_cost_itd,
		    billable_raw_cost_ytd = nvl(billable_raw_cost_ytd,0) + Prt_bill_raw_cost_ytd,
		    billable_raw_cost_pp  = nvl(billable_raw_cost_pp,0) + Prt_bill_raw_cost_pp,
		    billable_raw_cost_ptd = nvl(billable_raw_cost_ptd,0) + Prt_bill_raw_cost_ptd,
		    burdened_cost_itd = nvl(burdened_cost_itd,0) + Prt_burd_cost_itd,
		    burdened_cost_ytd = nvl(burdened_cost_ytd,0) + Prt_burd_cost_ytd,
		    burdened_cost_pp  = nvl(burdened_cost_pp,0) + Prt_burd_cost_pp,
		    burdened_cost_ptd = nvl(burdened_cost_ptd,0) + Prt_burd_cost_ptd,
		    billable_burdened_cost_itd = nvl(billable_burdened_cost_itd,0) + Prt_bill_burd_cost_itd,
		    billable_burdened_cost_ytd = nvl(billable_burdened_cost_ytd,0) + Prt_bill_burd_cost_ytd,
		    billable_burdened_cost_pp  = nvl(billable_burdened_cost_pp,0) + Prt_bill_burd_cost_pp,
		    billable_burdened_cost_ptd = nvl(billable_burdened_cost_ptd,0) + Prt_bill_burd_cost_ptd,
		    quantity_itd = nvl(quantity_itd,0) + Prt_quantity_itd,
		    quantity_ytd = nvl(quantity_ytd,0) + Prt_quantity_ytd,
		    quantity_pp  = nvl(quantity_pp,0) + Prt_quantity_pp,
		    quantity_ptd = nvl(quantity_ptd,0) + Prt_quantity_ptd,
		    labor_hours_itd = nvl(labor_hours_itd,0) + Prt_labor_hours_itd,
		    labor_hours_ytd = nvl(labor_hours_ytd,0) + Prt_labor_hours_ytd,
		    labor_hours_pp  = nvl(labor_hours_pp,0) + Prt_labor_hours_pp,
		    labor_hours_ptd = nvl(labor_hours_ptd,0) + Prt_labor_hours_ptd,
		    billable_quantity_itd = nvl(billable_quantity_itd,0) + Prt_bill_quantity_itd,
		    billable_quantity_ytd = nvl(billable_quantity_ytd,0) + Prt_bill_quantity_ytd,
		    billable_quantity_pp  = nvl(billable_quantity_pp,0) + Prt_bill_quantity_pp,
		    billable_quantity_ptd = nvl(billable_quantity_ptd,0) + Prt_bill_quantity_ptd,
		    billable_labor_hours_itd = nvl(billable_labor_hours_itd,0) + Prt_bill_labor_hours_itd,
		    billable_labor_hours_ytd = nvl(billable_labor_hours_ytd,0) + Prt_bill_labor_hours_ytd,
		    billable_labor_hours_pp  = nvl(billable_labor_hours_pp,0) + Prt_bill_labor_hours_pp,
		    billable_labor_hours_ptd = nvl(billable_labor_hours_ptd,0) + Prt_bill_labor_hours_ptd,
		    revenue_itd = nvl(revenue_itd,0) + Prt_revenue_itd,
		    revenue_ytd = nvl(revenue_ytd,0) + Prt_revenue_ytd,
		    revenue_pp  = nvl(revenue_pp,0) + Prt_revenue_pp,
		    revenue_ptd = nvl(revenue_ptd,0) + Prt_revenue_ptd,
        	    txn_unit_of_measure = NULL,
		    request_id = pa_proj_accum_main.x_request_id,
		    last_updated_by = pa_proj_accum_main.x_last_updated_by,
		    last_update_date = Trunc(sysdate),
        	    creation_date = Trunc(Sysdate),
		    created_by = pa_proj_accum_main.x_created_by,
		    last_update_login = pa_proj_accum_main.x_last_update_login
               Where PAA.Project_Accum_id = v_accum_id;

   if sql%notfound then
       	   Insert into PA_PROJECT_ACCUM_ACTUALS (
       	    PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
       	    BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
       	    BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
       	    BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
       	    BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
       	    BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
       	    QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
       	    LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
       	    BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
       	    BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
       	    BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
       	    REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
       	    REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,
	    CREATED_BY,LAST_UPDATE_LOGIN)
	    Values (V_Accum_id,
		    Prt_raw_cost_itd,
		    Prt_raw_cost_ytd,
		    Prt_raw_cost_pp,
		    Prt_raw_cost_ptd,
		    Prt_bill_raw_cost_itd,
		    Prt_bill_raw_cost_ytd,
		    Prt_bill_raw_cost_pp,
		    Prt_bill_raw_cost_ptd,
		    Prt_burd_cost_itd,
		    Prt_burd_cost_ytd,
		    Prt_burd_cost_pp,
		    Prt_burd_cost_ptd,
		    Prt_bill_burd_cost_itd,
		    Prt_bill_burd_cost_ytd,
		    Prt_bill_burd_cost_pp,
		    Prt_bill_burd_cost_ptd,
		    Prt_quantity_itd,
		    Prt_quantity_ytd,
		    Prt_quantity_pp,
		    Prt_quantity_ptd,
		    Prt_labor_hours_itd,
		    Prt_labor_hours_ytd,
		    Prt_labor_hours_pp,
		    Prt_labor_hours_ptd,
		    Prt_bill_quantity_itd,
		    Prt_bill_quantity_ytd,
		    Prt_bill_quantity_pp,
		    Prt_bill_quantity_ptd,
		    Prt_bill_labor_hours_itd,
		    Prt_bill_labor_hours_ytd,
		    Prt_bill_labor_hours_pp,
		    Prt_bill_labor_hours_ptd,
		    Prt_revenue_itd,
		    Prt_revenue_ytd,
		    Prt_revenue_pp,
		    Prt_revenue_ptd,
        	    NULL,
		    pa_proj_accum_main.x_request_id,
		    pa_proj_accum_main.x_last_updated_by,
		    Trunc(sysdate),
        	    Trunc(Sysdate),
		    pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login);
   end if;

    END;

    END IF;

    IF x_pac_flag = 'Y' and x_create_wbs_commit = 'Y' THEN

    BEGIN

	      UPDATE Pa_Project_Accum_Commitments PAA SET
		    Cmt_Raw_cost_itd = nvl(Cmt_Raw_cost_itd,0) + Prt_cmt_raw_cost_itd,
		    Cmt_Raw_cost_ytd = nvl(Cmt_Raw_cost_ytd,0) + Prt_cmt_raw_cost_ytd,
		    Cmt_Raw_cost_pp  = nvl(Cmt_Raw_cost_pp,0) + Prt_cmt_raw_cost_pp,
		    Cmt_Raw_cost_ptd = nvl(Cmt_Raw_cost_ptd,0) + Prt_cmt_raw_cost_ptd,
		    Cmt_burdened_cost_itd = nvl(Cmt_burdened_cost_itd,0) + Prt_cmt_burd_cost_itd,
		    Cmt_burdened_cost_ytd = nvl(Cmt_burdened_cost_ytd,0) + Prt_cmt_burd_cost_ytd,
		    Cmt_burdened_cost_pp  = nvl(Cmt_burdened_cost_pp,0) + Prt_cmt_burd_cost_pp,
		    Cmt_burdened_cost_ptd = nvl(Cmt_burdened_cost_ptd,0) + Prt_cmt_burd_cost_ptd,
		    Cmt_quantity_itd = nvl(Cmt_quantity_itd,0) + Prt_cmt_quantity_itd,
		    Cmt_quantity_ytd = nvl(Cmt_quantity_ytd,0) + Prt_cmt_quantity_ytd,
		    Cmt_quantity_pp  = nvl(Cmt_quantity_pp,0) + Prt_cmt_quantity_pp,
		    Cmt_quantity_ptd = nvl(Cmt_quantity_ptd,0) + Prt_cmt_quantity_ptd,
        	    cmt_unit_of_measure = NULL,
		    request_id = pa_proj_accum_main.x_request_id,
		    last_updated_by = pa_proj_accum_main.x_last_updated_by,
		    last_update_date = Trunc(sysdate),
        	    creation_date = Trunc(Sysdate),
		    created_by = pa_proj_accum_main.x_created_by,
		    last_update_login = pa_proj_accum_main.x_last_update_login
              Where PAA.Project_Accum_id = v_accum_id;

       if sql%notfound then
       	    Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       	    PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
            CMT_RAW_COST_PTD,
            CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
            CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       	    CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       	    CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       	    CMT_UNIT_OF_MEASURE,
       	    LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       	    LAST_UPDATE_LOGIN)
	    Values (V_Accum_id,
       		    Prt_cmt_raw_cost_itd,
       		    Prt_cmt_raw_cost_ytd,
       		    Prt_cmt_raw_cost_pp,
       		    Prt_cmt_raw_cost_ptd,
       		    Prt_cmt_burd_cost_itd,
       		    Prt_cmt_burd_cost_ytd,
       		    Prt_cmt_burd_cost_pp,
       		    Prt_cmt_burd_cost_ptd,
       		    Prt_cmt_quantity_itd,
       		    Prt_cmt_quantity_ytd,
       		    Prt_cmt_quantity_pp,
       		    Prt_cmt_quantity_ptd,
		    NULL,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        	    Trunc(Sysdate),pa_proj_accum_main.x_created_by,
		    pa_proj_accum_main.x_last_update_login);
     end if;
    END ;

    END IF;
 End if;
    x_err_stack := V_Old_Stack;

EXCEPTION
   When Others Then
     x_err_code := SQLCODE;
     RAISE;

 END Check_Accum_wbs;

-- This procedure           - For the given Task Id returns all the
--                          higher level tasks in the WBS (including the given
--                          task) which are not in PA_PROJECT_ACCUM_HEADERS
--                          (Tasks with the given Resource )

Procedure   Get_all_higher_tasks     (x_project_id in Number,
                                      x_task_id in Number,
                                      x_resource_list_member_id In Number,
                                      x_task_array  Out NOCOPY task_id_tabtype,
                                      x_noof_tasks Out NOCOPY number,
                                      x_err_stack     In Out NOCOPY Varchar2,
                                      x_err_stage     In Out NOCOPY Varchar2,
                                      x_err_code      In Out NOCOPY Number ) IS

CURSOR  Tasks_Cur IS
SELECT  task_id
FROM
pa_tasks pt
WHERE project_id = x_project_id
 start with task_id = x_task_id
 connect by prior parent_task_id = task_id;

v_noof_tasks         Number := 0;
V_Old_Stack       Varchar2(630);
Task_Rec Tasks_Cur%ROWTYPE;
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack||'->PA_PROCESS_ACCUM_ACTUALS_RES.Get_all_higher_tasks';
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.debug(x_err_stack);
END IF;
      For Task_Rec IN Tasks_Cur LOOP
          V_noof_tasks := v_noof_tasks + 1;
          x_task_array(v_noof_tasks) := Task_Rec.Task_id;

      END LOOP;

      x_noof_tasks := v_noof_tasks;

      -- Restore the old x_err_stack;

      x_err_stack := V_Old_Stack;

Exception
   When Others Then
     x_err_code := SQLCODE;

end Get_all_higher_tasks;

Procedure Insert_Headers_tasks (X_project_id In Number,
                                x_task_id In Number,
                                x_current_period In Varchar2,
                                x_accum_id In Number,
                                x_err_stack     In Out NOCOPY Varchar2,
                                x_err_stage     In Out NOCOPY Varchar2,
                                x_err_code      In Out NOCOPY Number ) IS
-- Insert_Headers_tasks  - Inserts Header records in the
--                         PA_PROJECT_ACCUM_HEADERS table
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=

      x_err_stack||'->PA_PROCESS_ACCUM_ACTUALS.Insert_Headers_tasks';
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.debug(x_err_stack);
      END IF;

        Insert into PA_PROJECT_ACCUM_HEADERS
        (PROJECT_ACCUM_ID,PROJECT_ID,TASK_ID,ACCUM_PERIOD,RESOURCE_ID,
         RESOURCE_LIST_ID,RESOURCE_LIST_ASSIGNMENT_ID,
         RESOURCE_LIST_MEMBER_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,
         CREATION_DATE,REQUEST_ID,CREATED_BY,LAST_UPDATE_LOGIN )
         Values (x_Accum_id,X_project_id,x_task_id,
                 x_current_period,
                 0,0,0,0,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),trunc(sysdate),
                 pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);

--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
     when dup_val_on_index then
        null;
     When Others Then
     x_err_code := SQLCODE;
     RAISE;

End Insert_Headers_tasks;

-- This procedure creates the records in pa_project_accum_actuals
-- for all the task break down hierarachy

Procedure   create_accum_actuals
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_current_period In Varchar2,
                                 x_Recs_processed Out NOCOPY Number,
                                 x_err_stack     In Out NOCOPY Varchar2,
                                 x_err_stage     In Out NOCOPY Varchar2,
                                 x_err_code      In Out NOCOPY Number )
IS

Recs_processed Number := 0;
V_Accum_id     Number := 0;
V_task_array task_id_tabtype;
v_noof_tasks Number := 0;
v_err_code Number := 0;
other_recs_processed Number := 0;
V_Old_Stack       Varchar2(630);
Begin
   V_Old_Stack := x_err_stack;
   x_err_stack :=
   x_err_stack||'->PA_PROCESS_ACCUM_ACTUALS.create_accum_actuals';
   -- This checks for Actuals record in PA_PROJECT_ACCUM_ACTUALS for this
   -- project and task combination. It is possible that there might be a
   -- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
   -- no corresponding detail record. The procedure called below,will
   -- check for the existence of the detail records and if not available
   -- would create it.

   pa_accum_utils.Check_Actuals_Details
                             (x_project_id,
                              x_task_id,
                              0,
                              other_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

   Recs_processed := Recs_processed + other_recs_processed;

   -- The following procedure would return all the tasks in the given task
   -- WBS hierarchy, including the given task, which do not have a header
   -- record . The return parameter is an array of records.

   Get_all_higher_tasks
			(x_project_id ,
                         x_task_id ,
			 0,             -- resource_list_member_id
                         v_task_array,
                         v_noof_tasks,
                         x_err_stack,
                         x_err_stage,
                         x_err_code);

   -- If the above procedure had returned any tasks , then we need to insert
   -- header record and actuals record. We need to process the tasks one by one
   -- since we require the Accum_id for each detail record.
   -- Eg: If the given task (the one fetched from PA_TXN_ACCUM) was say
   -- 1.1.1, then the first time,    Get_all_higher_tasks would return,
   -- 1.1.1, 1.1,  and 1. We create three header records and three detail records
   -- in the Project_accum_actuals table. The next time , if the given task
   -- is 1.1.2, the Get_all_higher_tasks would return only 1.1.2, since
   -- 1.1 and 1 are already available in the Pa_project_accum_headers. Those
   -- two records would have been processed by the Update statements.

   If v_noof_tasks > 0 Then
       For i in 1..v_noof_tasks LOOP
        Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
        From Dual;
        Insert_Headers_tasks
			     (X_project_id,
                              v_task_array(i),
                              x_current_period,
                              v_accum_id,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

       Recs_processed := Recs_processed + 1;
       Insert into PA_PROJECT_ACCUM_ACTUALS (
       PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
       BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
       BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
       BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
       BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
       BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
       QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
       LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
       BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
       BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
       BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
       REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,0,0,0,0,
        0,0,0,0,
        0,0,
        0,0,0,
        0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,
        0,0,0,0,
        0,0,NULL,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;

    End If;
    x_recs_processed := Recs_processed;
    x_err_stack := V_Old_Stack;

EXCEPTION
    When Others then
    x_err_code := SQLCODE;
    RAISE;
END create_accum_actuals;

-- This procedure creates records in HEADERS/ACTUALS table for
-- task/resource_list_member_id combination

Procedure   create_accum_actuals_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_current_period In Varchar2,
                                 X_Recs_processed Out NOCOPY Number,
                                 x_err_stack     In Out NOCOPY Varchar2,
                                 x_err_stage     In Out NOCOPY Varchar2,
                                 x_err_code      In Out NOCOPY Number ) IS

CURSOR Proj_Res_level_Cur IS
SELECT Project_Accum_Id
FROM
PA_PROJECT_ACCUM_HEADERS
WHERE Project_id = X_project_id
AND Task_Id = 0
AND Resource_list_Member_id = X_resource_list_member_id;

Recs_processed Number := 0;
V_Accum_id     Number := 0;
V_task_array task_id_tabtype;
v_noof_tasks Number := 0;
Res_Recs_processed Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      X_err_stack ||'-PA_MAINT_PROJECT_ACCUM.create_accum_actual_res';
      -- This checks for Actuals record in PA_PROJECT_ACCUM_ACTUALS for this
      -- project,task and resource combination.It is possible that there might be a
      -- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
      -- no corresponding detail record. The procedure called below,will
      -- check for the existence of the detail records and if not available
      -- would create it.

        PA_ACCUM_UTILS.Check_Actuals_Details
                             (x_project_id,
                              x_task_id,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);
        Recs_processed := Recs_processed + Res_recs_processed;

        -- This checks for Actuals record in PA_PROJECT_ACCUM_ACTUALS for this
        -- project and Resource combination. It is possible that there might be a
        -- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
        -- no corresponding detail record. The procedure called below,will
        -- check for the existence of the detail records and if not available
        -- would create it.

        PA_ACCUM_UTILS.Check_Actuals_Details
                             (x_project_id,
                              0,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);
        Recs_processed := Recs_processed + Res_recs_processed;

        -- The following procedure would return all the tasks in the given task
        -- WBS hierarchy, including the given task, which do not have a header
        -- record . The return parameter is an array of records.

        v_noof_tasks := 0;

        Get_all_higher_tasks  (x_project_id ,
                               x_task_id ,
                               x_resource_list_member_id,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);

-- If the above procedure had returned any tasks , then we need to insert
-- header record and actuals record. We need to process the tasks one by one
-- since we require the Accum_id for each detail record.
-- Eg: If the given task (the one fetched from PA_TXN_ACCUM) was say
-- 1.1.1, then the first time,    Get_all_higher_tasks would return,
-- 1.1.1, 1.1,  and 1. We create three header records and three detail records
-- in the Project_accum_actuals table. The next time , if the given task
-- is 1.1.2, the Get_all_higher_tasks would return only 1.1.2, since
-- 1.1 and 1 are already available in the Pa_project_accum_headers. Those
-- two records would have been processed by the Update statements.

    If v_noof_tasks > 0 Then
       For i in 1..v_noof_tasks LOOP
        Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
        From Dual;
        PA_process_accum_actuals_res.insert_headers_res
			     (x_project_id,
                              v_task_array(i),
                              x_resource_list_id ,
                              x_resource_list_Member_id ,
                              x_resource_id ,
                              x_resource_list_assignment_id ,
                              x_current_period,
                              v_accum_id,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);
       Recs_processed := Recs_processed + 1;

       Insert into PA_PROJECT_ACCUM_ACTUALS (
       PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
       BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
       BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
       BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
       BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
       BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
       QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
       LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
       BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
       BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
       BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
       REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,0,0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,
        0,0,0,
        0,0,0,0,
        0,NULL,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;
    End If;
-- This will check for the Project-Resource combination in the Header records
-- and if not present create the Header and Detail records for Actuals
    Open Proj_Res_level_Cur;
    Fetch Proj_Res_level_Cur Into V_Accum_Id;
    IF Proj_Res_level_Cur%NOTFOUND Then
       Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
       From Dual;
       PA_process_accum_actuals_res.insert_headers_res
                          (x_project_id,
                           0,
                           x_resource_list_id ,
                           x_resource_list_Member_id ,
                           x_resource_id ,
                           x_resource_list_assignment_id ,
                           x_current_period,
                           v_accum_id,
                           x_err_stack,
                           x_err_stage,
                           x_err_code);

       Recs_processed := Recs_processed + 1;
       Insert into PA_PROJECT_ACCUM_ACTUALS (
       PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
       BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
       BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
       BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
       BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
       BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
       QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
       LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
       BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
       BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
       BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
       REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,0,0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,
        0,0,0,
        0,0,0,0,
        0,NULL,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
    END IF;
    Close Proj_Res_level_Cur;
    x_recs_processed := Recs_processed;

    --  Restore the old x_err_stack;

    x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End create_accum_actuals_res;


-- This Procedure Initializes the figures in the PA_PROJECT_ACCUM_ACTUALS
-- Table. The Initialization will happen in case the current period is
-- greater than the previously accumulated period. The procedure would
-- be called only if the run-mod is 'I' (Incremental) .

  Procedure Initialize_actuals (x_project_id  In Number,
                                x_accum_id    In Number,
                                x_impl_opt    In Varchar2,
                                x_Current_period In Varchar2,
                                x_Prev_period    In Varchar2,
                                x_Prev_Accum_period In Varchar2,
                                x_Current_year  In Number,
                                x_Prev_year     In Number,
                                x_prev_accum_year In Number,
                                x_current_start_date In Date,
                                x_current_end_date In Date,
                                x_prev_start_date In Date,
                                x_prev_end_date In Date,
                                x_prev_accum_start_date In Date,
                                x_prev_accum_end_date In Date,
                                x_err_stack     In Out NOCOPY Varchar2,
                                x_err_stage     In Out NOCOPY Varchar2,
                                x_err_code      In Out NOCOPY Number ) Is

V_Accum_period    Varchar2(20);
V_Accum_id  Number := 0;
V_Old_Stack       Varchar2(630);

 Begin
-- If previously accumulated period and current period are the same or
-- there has been no accumulations so far , then do nothing.
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_MAINT_PROJECT_ACCUMS.Initialize_actuals';
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.debug(x_err_stack);
      END IF;

-- If current period > previously accumulated period
--   If previously accumuated period = previous period (the one previous
--   to the current period ),
--       If current year > year pertaining to the previously accumulated year
--         Then Initialize as follows
--         YTD = 0,PP = PTD, PTD = 0
--       Elsif current year = previously accumulated year,
--         Then Initialize as follows
--         PP = PTD, PTD = 0
--      End If
--   Elsif previously accumulated period <> previous period
--    Then
--       If current year > year pertaining to the previously accumulated year
--         Then Initialize as follows
--         YTD = 0,PP = 0, PTD = 0
--       Elsif current year = previously accumulated year,
--         Then Initialize as follows
--         PP = 0, PTD = 0
--      End If
--  End If


      If x_current_start_date > x_prev_accum_start_date then
        If X_prev_period = x_prev_accum_period then
            If x_current_year >  x_prev_accum_year then
               Update PA_PROJECT_ACCUM_ACTUALS SET
               RAW_COST_YTD          = 0,
               RAW_COST_PP = RAW_COST_PTD,
               RAW_COST_PTD = 0,
               BILLABLE_RAW_COST_YTD = 0,
               BILLABLE_RAW_COST_PP =BILLABLE_RAW_COST_PTD,
               BILLABLE_RAW_COST_PTD = 0,BURDENED_COST_YTD = 0,
               BURDENED_COST_PP      = BURDENED_COST_PTD,
               BURDENED_COST_PTD = 0,
               BILLABLE_BURDENED_COST_YTD = 0,
               BILLABLE_BURDENED_COST_PP = BILLABLE_BURDENED_COST_PTD,
               BILLABLE_BURDENED_COST_PTD = 0,QUANTITY_YTD = 0,
               QUANTITY_PP = QUANTITY_PTD,
               QUANTITY_PTD  = 0,LABOR_HOURS_YTD = 0,
               LABOR_HOURS_PP = LABOR_HOURS_PTD,
               LABOR_HOURS_PTD = 0,BILLABLE_QUANTITY_YTD = 0,
               BILLABLE_QUANTITY_PP = BILLABLE_QUANTITY_PTD,
               BILLABLE_QUANTITY_PTD = 0,
               BILLABLE_LABOR_HOURS_YTD = 0,
               BILLABLE_LABOR_HOURS_PP = BILLABLE_LABOR_HOURS_PTD,
               BILLABLE_LABOR_HOURS_PTD = 0,REVENUE_YTD = 0,
               REVENUE_PP = REVENUE_PTD,REVENUE_PTD = 0,
               LAST_UPDATED_BY = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE = trunc(sysdate),
               LAST_UPDATE_LOGIN = pa_proj_accum_main.x_last_update_login
               Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
                PAH.Project_Id = x_project_id);
            Else
               Update PA_PROJECT_ACCUM_ACTUALS SET
               RAW_COST_PP   = RAW_COST_PTD,
               RAW_COST_PTD   = 0,
               BILLABLE_RAW_COST_PP  = BILLABLE_RAW_COST_PTD,
               BILLABLE_RAW_COST_PTD = 0,
               BURDENED_COST_PP      = BURDENED_COST_PTD,
               BURDENED_COST_PTD   = 0,
               BILLABLE_BURDENED_COST_PP  = BILLABLE_BURDENED_COST_PTD,
               BILLABLE_BURDENED_COST_PTD = 0,
               QUANTITY_PP           = QUANTITY_PTD,
               QUANTITY_PTD          = 0,
               LABOR_HOURS_PP        = LABOR_HOURS_PTD,
               LABOR_HOURS_PTD       = 0,
               BILLABLE_QUANTITY_PP  = BILLABLE_QUANTITY_PTD,
               BILLABLE_QUANTITY_PTD = 0,
               BILLABLE_LABOR_HOURS_PP = BILLABLE_LABOR_HOURS_PTD,
               BILLABLE_LABOR_HOURS_PTD  = 0,
               REVENUE_PP            = REVENUE_PTD,
               REVENUE_PTD           = 0,
               LAST_UPDATED_BY       = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE      = trunc(sysdate),
               LAST_UPDATE_LOGIN     = pa_proj_accum_main.x_last_update_login
               Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
                PAH.Project_Id = x_project_id);
            End If;
        ElsIf X_prev_start_date > x_prev_accum_start_date then
            If x_current_year >  x_prev_accum_year then
               Update PA_PROJECT_ACCUM_ACTUALS SET
               RAW_COST_YTD = 0,RAW_COST_PP = 0,
               RAW_COST_PTD = 0,
               BILLABLE_RAW_COST_YTD = 0,
               BILLABLE_RAW_COST_PP =0,
               BILLABLE_RAW_COST_PTD = 0,BURDENED_COST_YTD = 0,
               BURDENED_COST_PP      = 0,
               BURDENED_COST_PTD = 0,
               BILLABLE_BURDENED_COST_YTD = 0,
               BILLABLE_BURDENED_COST_PP = 0,
               BILLABLE_BURDENED_COST_PTD = 0,QUANTITY_YTD = 0,
               QUANTITY_PP = 0,
               QUANTITY_PTD  = 0,LABOR_HOURS_YTD = 0,
               LABOR_HOURS_PP = 0,
               LABOR_HOURS_PTD = 0,BILLABLE_QUANTITY_YTD = 0,
               BILLABLE_QUANTITY_PP = 0,
               BILLABLE_QUANTITY_PTD = 0,
               BILLABLE_LABOR_HOURS_YTD = 0,
               BILLABLE_LABOR_HOURS_PP = 0,
               BILLABLE_LABOR_HOURS_PTD = 0,REVENUE_YTD = 0,
               REVENUE_PP = 0,REVENUE_PTD = 0,
               LAST_UPDATED_BY = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE = trunc(sysdate),
               LAST_UPDATE_LOGIN = pa_proj_accum_main.x_last_update_login
               Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
                PAH.Project_Id = x_project_id);
            Else
               Update PA_PROJECT_ACCUM_ACTUALS SET
               RAW_COST_PP   = 0,
               RAW_COST_PTD   = 0,
               BILLABLE_RAW_COST_PP  = 0,
               BILLABLE_RAW_COST_PTD = 0,
               BURDENED_COST_PP      = 0,
               BURDENED_COST_PTD   = 0,
               BILLABLE_BURDENED_COST_PP  = 0,
               BILLABLE_BURDENED_COST_PTD = 0,
               QUANTITY_PP           = 0,
               QUANTITY_PTD          = 0,
               LABOR_HOURS_PP        = 0,
               LABOR_HOURS_PTD       = 0,
               BILLABLE_QUANTITY_PP  = 0,
               BILLABLE_QUANTITY_PTD = 0,
               BILLABLE_LABOR_HOURS_PP = 0,
               BILLABLE_LABOR_HOURS_PTD  = 0,
               REVENUE_PP            = 0,
               REVENUE_PTD           = 0,
               LAST_UPDATED_BY       = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE      = trunc(sysdate),
               LAST_UPDATE_LOGIN     = pa_proj_accum_main.x_last_update_login
               Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
                PAH.Project_Id = x_project_id);
            End If;
          End If;
        End If;
--           Update Pa_project_accum_Headers Set
--             Accum_Period = x_current_period
--             where Project_Id = X_Project_id;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others then
       x_err_code := SQLCODE;
       RAISE;
End Initialize_actuals;

-- This Procedure Initializes the figures in the PA_PROJECT_ACCUM_BUDGETS
-- Table. The Initialization will happen in case the current period is
-- greater than the previously accumulated period. The procedure would
-- be called only if the run-mod is 'I' (Incremental) .Also,the initialization
-- would be done only for those budget-types which are not being
-- run now.

  Procedure Initialize_budgets (X_project_id  In Number,
                                x_accum_id    In Number,
                                x_impl_opt    In Varchar2,
                                x_budget_type In Varchar2,
                                x_Current_period In Varchar2,
                                x_Prev_period    In Varchar2,
                                x_Prev_Accum_period In Varchar2,
                                x_Current_year  In Number,
                                x_Prev_year     In Number,
                                x_prev_accum_year In Number,
                                x_current_start_date In Date,
                                x_current_end_date In Date,
                                x_prev_start_date In Date,
                                x_prev_end_date In Date,
                                x_prev_accum_start_date In Date,
                                x_prev_accum_end_date In Date,
                                x_err_stack     In Out NOCOPY Varchar2,
                                x_err_stage     In Out NOCOPY Varchar2,
                                x_err_code      In Out NOCOPY Number ) Is

V_Old_Stack       Varchar2(630);

 Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_MAINT_PROJECT_ACCUMS.Initialize_budgets';
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.debug(x_err_stack);
      END IF;

-- If current period > previously accumulated period
--   If previously accumuated period = previous period (the one previous
--   to the current period ),
--       If current year > year pertaining to the previously accumulated year
--         Then Initialize as follows
--         YTD = 0,PP = PTD, PTD = 0
--       Elsif current year = previously accumulated year,
--         Then Initialize as follows
--         PP = PTD, PTD = 0
--      End If
--   Elsif previously accumulated period <> previous period
--    Then
--       If current year > year pertaining to the previously accumulated year
--         Then Initialize as follows
--         YTD = 0,PP = 0, PTD = 0
--       Elsif current year = previously accumulated year,
--         Then Initialize as follows
--         PP = 0, PTD = 0
--      End If
--  End If


      If x_current_start_date > x_prev_accum_start_date then
        If X_prev_period = x_prev_accum_period then
            If x_current_year >  x_prev_accum_year then
               Update PA_PROJECT_ACCUM_BUDGETS SET
               BASE_RAW_COST_YTD          = 0,
               BASE_RAW_COST_PP           = BASE_RAW_COST_PTD,
               BASE_RAW_COST_PTD          = 0,
               ORIG_RAW_COST_YTD          = 0,
               ORIG_RAW_COST_PP           = ORIG_RAW_COST_PTD,
               ORIG_RAW_COST_PTD          = 0,
               BASE_BURDENED_COST_YTD     = 0,
               BASE_BURDENED_COST_PP      = BASE_BURDENED_COST_PTD,
               BASE_BURDENED_COST_PTD     = 0,
               ORIG_BURDENED_COST_YTD     = 0,
               ORIG_BURDENED_COST_PP      = ORIG_BURDENED_COST_PTD,
               ORIG_BURDENED_COST_PTD     = 0,
               BASE_QUANTITY_YTD          = 0,
               BASE_QUANTITY_PP           = BASE_QUANTITY_PTD,
               BASE_QUANTITY_PTD          = 0,
               ORIG_QUANTITY_YTD          = 0,
               ORIG_QUANTITY_PP           = ORIG_QUANTITY_PTD,
               ORIG_QUANTITY_PTD          = 0,
               BASE_LABOR_HOURS_YTD       = 0,
               BASE_LABOR_HOURS_PP        = BASE_LABOR_HOURS_PTD,
               BASE_LABOR_HOURS_PTD       = 0,
               ORIG_LABOR_HOURS_YTD       = 0,
               ORIG_LABOR_HOURS_PP        = ORIG_LABOR_HOURS_PTD,
               ORIG_LABOR_HOURS_PTD       = 0,
               BASE_REVENUE_YTD           = 0,
               BASE_REVENUE_PP            = BASE_REVENUE_PTD,
               BASE_REVENUE_PTD           = 0,
               LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE           = trunc(sysdate),
               LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
               Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
                PAH.Project_Id = x_project_id) And
                Budget_Type_Code <> Nvl(x_budget_type,'00');
            Else
               Update PA_PROJECT_ACCUM_BUDGETS SET
               BASE_RAW_COST_PP           = BASE_RAW_COST_PTD,
               BASE_RAW_COST_PTD          = 0,
               ORIG_RAW_COST_PP           = ORIG_RAW_COST_PTD,
               ORIG_RAW_COST_PTD          = 0,
               BASE_BURDENED_COST_PP      = BASE_BURDENED_COST_PTD,
               BASE_BURDENED_COST_PTD     = 0,
               ORIG_BURDENED_COST_PP      = ORIG_BURDENED_COST_PTD,
               ORIG_BURDENED_COST_PTD     = 0,
               BASE_QUANTITY_PP           = BASE_QUANTITY_PTD,
               BASE_QUANTITY_PTD          = 0,
               ORIG_QUANTITY_PP           = ORIG_QUANTITY_PTD,
               ORIG_QUANTITY_PTD          = 0,
               BASE_LABOR_HOURS_PP        = BASE_LABOR_HOURS_PTD,
               BASE_LABOR_HOURS_PTD       = 0,
               ORIG_LABOR_HOURS_PP        = ORIG_LABOR_HOURS_PTD,
               ORIG_LABOR_HOURS_PTD       = 0,
               BASE_REVENUE_PP            = BASE_REVENUE_PTD,
               BASE_REVENUE_PTD           = 0,
               LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE           = trunc(sysdate),
               LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
              Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
                PAH.Project_Id = x_project_id) And
                Budget_Type_Code <> Nvl(x_budget_type,'00');
            End If;
        ElsIf X_prev_start_date > x_prev_accum_start_date then
            If x_current_year >  x_prev_accum_year then
              Update PA_PROJECT_ACCUM_BUDGETS SET
               BASE_RAW_COST_YTD          = 0,
               BASE_RAW_COST_PP           = 0,
               BASE_RAW_COST_PTD          = 0,
               ORIG_RAW_COST_YTD          = 0,
               ORIG_RAW_COST_PP           = 0,
               ORIG_RAW_COST_PTD          = 0,
               BASE_BURDENED_COST_YTD     = 0,
               BASE_BURDENED_COST_PP      = 0,
               BASE_BURDENED_COST_PTD     = 0,
               ORIG_BURDENED_COST_YTD     = 0,
               ORIG_BURDENED_COST_PP      = 0,
               ORIG_BURDENED_COST_PTD     = 0,
               BASE_QUANTITY_YTD          = 0,
               BASE_QUANTITY_PP           = 0,
               BASE_QUANTITY_PTD          = 0,
               ORIG_QUANTITY_YTD          = 0,
               ORIG_QUANTITY_PP           = 0,
               ORIG_QUANTITY_PTD          = 0,
               BASE_LABOR_HOURS_YTD       = 0,
               BASE_LABOR_HOURS_PP        = 0,
               BASE_LABOR_HOURS_PTD       = 0,
               ORIG_LABOR_HOURS_YTD       = 0,
               ORIG_LABOR_HOURS_PP        = 0,
               ORIG_LABOR_HOURS_PTD       = 0,
               BASE_REVENUE_YTD           = 0,
               BASE_REVENUE_PP            = 0,
               BASE_REVENUE_PTD           = 0,
               LAST_UPDATED_BY = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE = trunc(sysdate),
               LAST_UPDATE_LOGIN = pa_proj_accum_main.x_last_update_login
              Where Project_Accum_id IN
              (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
              PAH.Project_Id = x_project_id) And
              Budget_Type_Code <> Nvl(x_budget_type,'00');
            Else
              Update PA_PROJECT_ACCUM_BUDGETS SET
               BASE_RAW_COST_PP          = 0,
               BASE_RAW_COST_PTD         = 0,
               ORIG_RAW_COST_PP          = 0,
               ORIG_RAW_COST_PTD         = 0,
               BASE_BURDENED_COST_PP     = 0,
               BASE_BURDENED_COST_PTD    = 0,
               ORIG_BURDENED_COST_PP     = 0,
               ORIG_BURDENED_COST_PTD    = 0,
               BASE_QUANTITY_PP          = 0,
               BASE_QUANTITY_PTD         = 0,
               ORIG_QUANTITY_PP          = 0,
               ORIG_QUANTITY_PTD         = 0,
               BASE_LABOR_HOURS_PP       = 0,
               BASE_LABOR_HOURS_PTD      = 0,
               ORIG_LABOR_HOURS_PP       = 0,
               ORIG_LABOR_HOURS_PTD      = 0,
               BASE_REVENUE_PP           = 0,
               BASE_REVENUE_PTD          = 0,
               LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE          = trunc(sysdate),
               LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
              Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
               PAH.Project_Id = x_project_id) And
               Budget_Type_Code <> Nvl(x_budget_type,'00');
            End If;
          End If;
        End If;
        --- Since Period has changed,and budget figures have been initialized
        --- we have to make the current budget version as not accumulated
        --- so that they get picked up , when next time budget is run

           Update Pa_Budget_Versions
           Set Resource_Accumulated_Flag ='N'
           Where Current_Flag = 'Y'
           And Project_id = x_project_id
           AND Budget_type_code <> nvl(x_budget_type,'00');

--      Restore the old x_err_stack;
        x_err_stack := V_Old_Stack;
Exception
  When Others then
       x_err_code := SQLCODE;
       RAISE;
End Initialize_budgets;

-- This Procedure Initializes the figures in the PA_PROJECT_ACCUM_COMMITMENTS
-- Table. The Initialization will happen in case the current period is
-- greater than the previously accumulated period. The procedure would
-- be called only if the run-mode is 'I' (Incremental) .

  Procedure Initialize_commitments
                               (x_project_id  In Number,
                                x_accum_id    In Number,
                                x_impl_opt    In Varchar2,
                                x_Current_period In Varchar2,
                                x_Prev_period    In Varchar2,
                                x_Prev_Accum_period In Varchar2,
                                x_Current_year  In Number,
                                x_Prev_year     In Number,
                                x_prev_accum_year In Number,
                                x_current_start_date In Date,
                                x_current_end_date In Date,
                                x_prev_start_date In Date,
                                x_prev_end_date In Date,
                                x_prev_accum_start_date In Date,
                                x_prev_accum_end_date In Date,
                                x_err_stack     In Out NOCOPY Varchar2,
                                x_err_stage     In Out NOCOPY Varchar2,
                                x_err_code      In Out NOCOPY Number ) Is

V_Old_Stack       Varchar2(630);

 Begin
-- If previously accumulated period and current period are the same or
-- there has been no accumulations so far , then do nothing.
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_MAINT_PROJECT_ACCUMS.Initialize_commitments';
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.debug(x_err_stack);
      END IF;

-- If current period > previously accumulated period
--   If previously accumuated period = previous period (the one previous
--   to the current period ),
--       If current year > year pertaining to the previously accumulated year
--         Then Initialize as follows
--         YTD = 0,PP = PTD, PTD = 0
--       Elsif current year = previously accumulated year,
--         Then Initialize as follows
--         PP = PTD, PTD = 0
--      End If
--   Elsif previously accumulated period <> previous period
--    Then
--       If current year > year pertaining to the previously accumulated year
--         Then Initialize as follows
--         YTD = 0,PP = 0, PTD = 0
--       Elsif current year = previously accumulated year,
--         Then Initialize as follows
--         PP = 0, PTD = 0
--      End If
--  End If


      If x_current_start_date > x_prev_accum_start_date then
        If X_prev_period = x_prev_accum_period then
            If x_current_year >  x_prev_accum_year then
              Update PA_PROJECT_ACCUM_COMMITMENTS SET
               CMT_RAW_COST_YTD          = 0,
               CMT_RAW_COST_PP           = CMT_RAW_COST_PTD,
               CMT_RAW_COST_PTD          = 0,
               CMT_BURDENED_COST_YTD     = 0,
               CMT_BURDENED_COST_PP      = CMT_BURDENED_COST_PTD,
               CMT_BURDENED_COST_PTD     = 0,
               CMT_QUANTITY_YTD          = 0,
               CMT_QUANTITY_PP           = CMT_QUANTITY_PTD,
               CMT_QUANTITY_PTD          = 0,
               LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE          = trunc(sysdate),
               LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
              Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
               PAH.Project_Id = x_project_id);
            Else
              Update PA_PROJECT_ACCUM_COMMITMENTS SET
               CMT_RAW_COST_PP           = CMT_RAW_COST_PTD,
               CMT_RAW_COST_PTD          = 0,
               CMT_BURDENED_COST_PP      = CMT_BURDENED_COST_PTD,
               CMT_BURDENED_COST_PTD     = 0,
               CMT_QUANTITY_PP           = CMT_QUANTITY_PTD,
               CMT_QUANTITY_PTD          = 0,
               LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE          = trunc(sysdate),
               LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
              Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
               PAH.Project_Id = x_project_id);
            End If;
        ElsIf X_prev_start_date > x_prev_accum_start_date then
            If x_current_year >  x_prev_accum_year then
              Update PA_PROJECT_ACCUM_COMMITMENTS SET
               CMT_RAW_COST_YTD          = 0,
               CMT_RAW_COST_PP           = 0,
               CMT_RAW_COST_PTD          = 0,
               CMT_BURDENED_COST_YTD     = 0,
               CMT_BURDENED_COST_PP      = 0,
               CMT_BURDENED_COST_PTD     = 0,
               CMT_QUANTITY_YTD          = 0,
               CMT_QUANTITY_PP           = 0,
               CMT_QUANTITY_PTD          = 0,
               LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE          = trunc(sysdate),
               LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
              Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
               PAH.Project_Id = x_project_id);
            Else
              Update PA_PROJECT_ACCUM_COMMITMENTS SET
               CMT_RAW_COST_PP           = 0,
               CMT_RAW_COST_PTD          = 0,
               CMT_BURDENED_COST_PP      = 0,
               CMT_BURDENED_COST_PTD     = 0,
               CMT_QUANTITY_PP           = 0,
               CMT_QUANTITY_PTD          = 0,
               LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
               LAST_UPDATE_DATE          = trunc(sysdate),
               LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
              Where Project_Accum_id IN
               (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
               PAH.Project_Id = x_project_id);
            End If;
          End If;
        End If;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
When Others then
     x_err_code := SQLCODE;
     RAISE;
End Initialize_commitments;

Procedure Initialize_task_level is
begin
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    pa_debug.debug('Initialize_task_level');
    END IF;
		-- Initialize amount variables
  			New_raw_cost_itd	:= 0;
  			New_raw_cost_ytd	:= 0;
  			New_raw_cost_ptd	:= 0;
  			New_raw_cost_pp 	:= 0;

  			New_quantity_itd	:= 0;
  			New_quantity_ytd	:= 0;
  			New_quantity_ptd	:= 0;
  			New_quantity_pp 	:= 0;

  			New_cmt_quantity_itd	:= 0;
  			New_cmt_quantity_ytd	:= 0;
  			New_cmt_quantity_ptd	:= 0;
  			New_cmt_quantity_pp 	:= 0;

  			New_bill_quantity_itd	:= 0;
  			New_bill_quantity_ytd	:= 0;
  			New_bill_quantity_ptd	:= 0;
  			New_bill_quantity_pp 	:= 0;

	  		New_cmt_raw_cost_itd	:= 0;
  			New_cmt_raw_cost_ytd	:= 0;
  			New_cmt_raw_cost_ptd	:= 0;
  			New_cmt_raw_cost_pp 	:= 0;

  			New_burd_cost_itd	:= 0;
  			New_burd_cost_ytd	:= 0;
  			New_burd_cost_ptd	:= 0;
  			New_burd_cost_pp 	:= 0;

  			New_cmt_burd_cost_itd	:= 0;
  			New_cmt_burd_cost_ytd	:= 0;
  			New_cmt_burd_cost_ptd	:= 0;
  			New_cmt_burd_cost_pp    := 0;

  			New_labor_hours_itd	:= 0;
  			New_labor_hours_ytd	:= 0;
  			New_labor_hours_ptd	:= 0;
  			New_labor_hours_pp 	:= 0;

  			New_revenue_itd		:= 0;
  			New_revenue_ytd		:= 0;
  			New_revenue_ptd		:= 0;
  			New_revenue_pp 		:= 0;

  			New_bill_raw_cost_itd	:= 0;
  			New_bill_raw_cost_ytd	:= 0;
  			New_bill_raw_cost_ptd	:= 0;
  			New_bill_raw_cost_pp 	:= 0;

  			New_bill_burd_cost_itd	:= 0;
  			New_bill_burd_cost_ytd	:= 0;
  			New_bill_burd_cost_ptd	:= 0;
  			New_bill_burd_cost_pp 	:= 0;

  			New_bill_labor_hours_itd:= 0;
  			New_bill_labor_hours_ytd:= 0;
  			New_bill_labor_hours_ptd:= 0;
  			New_bill_labor_hours_pp	:= 0;

end initialize_task_level;

Procedure Initialize_parent_level is
begin
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    pa_debug.debug('Initialize_parent_level');
    END IF;
		-- Initialize amount variables
  			Prt_raw_cost_itd	:= 0;
  			Prt_raw_cost_ytd	:= 0;
  			Prt_raw_cost_ptd	:= 0;
  			Prt_raw_cost_pp 	:= 0;

  			Prt_quantity_itd	:= 0;
  			Prt_quantity_ytd	:= 0;
  			Prt_quantity_ptd	:= 0;
  			Prt_quantity_pp 	:= 0;

  			Prt_cmt_quantity_itd	:= 0;
  			Prt_cmt_quantity_ytd	:= 0;
  			Prt_cmt_quantity_ptd	:= 0;
  			Prt_cmt_quantity_pp 	:= 0;

  			Prt_bill_quantity_itd	:= 0;
  			Prt_bill_quantity_ytd	:= 0;
  			Prt_bill_quantity_ptd	:= 0;
  			Prt_bill_quantity_pp 	:= 0;

	  		Prt_cmt_raw_cost_itd	:= 0;
  			Prt_cmt_raw_cost_ytd	:= 0;
  			Prt_cmt_raw_cost_ptd	:= 0;
  			Prt_cmt_raw_cost_pp 	:= 0;

  			Prt_burd_cost_itd	:= 0;
  			Prt_burd_cost_ytd	:= 0;
  			Prt_burd_cost_ptd	:= 0;
  			Prt_burd_cost_pp 	:= 0;

  			Prt_cmt_burd_cost_itd	:= 0;
  			Prt_cmt_burd_cost_ytd	:= 0;
  			Prt_cmt_burd_cost_ptd	:= 0;
  			Prt_cmt_burd_cost_pp    := 0;

  			Prt_labor_hours_itd	:= 0;
  			Prt_labor_hours_ytd	:= 0;
  			Prt_labor_hours_ptd	:= 0;
  			Prt_labor_hours_pp 	:= 0;

  			Prt_revenue_itd		:= 0;
  			Prt_revenue_ytd		:= 0;
  			Prt_revenue_ptd		:= 0;
  			Prt_revenue_pp 		:= 0;

  			Prt_bill_raw_cost_itd	:= 0;
  			Prt_bill_raw_cost_ytd	:= 0;
  			Prt_bill_raw_cost_ptd	:= 0;
  			Prt_bill_raw_cost_pp 	:= 0;

  			Prt_bill_burd_cost_itd	:= 0;
  			Prt_bill_burd_cost_ytd	:= 0;
  			Prt_bill_burd_cost_ptd	:= 0;
  			Prt_bill_burd_cost_pp 	:= 0;

  			Prt_bill_labor_hours_itd:= 0;
  			Prt_bill_labor_hours_ytd:= 0;
  			Prt_bill_labor_hours_ptd:= 0;
  			Prt_bill_labor_hours_pp	:= 0;
end initialize_parent_level;

Procedure Initialize_project_level is
begin
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    pa_debug.debug('Initialize_project_level');
    END IF;
		-- Initialize amount variables
  			Tsk_raw_cost_itd	:= 0;
  			Tsk_raw_cost_ytd	:= 0;
  			Tsk_raw_cost_ptd	:= 0;
  			Tsk_raw_cost_pp 	:= 0;

  			Tsk_quantity_itd	:= 0;
  			Tsk_quantity_ytd	:= 0;
  			Tsk_quantity_ptd	:= 0;
  			Tsk_quantity_pp 	:= 0;

  			Tsk_cmt_quantity_itd	:= 0;
  			Tsk_cmt_quantity_ytd	:= 0;
  			Tsk_cmt_quantity_ptd	:= 0;
  			Tsk_cmt_quantity_pp 	:= 0;

  			Tsk_bill_quantity_itd	:= 0;
  			Tsk_bill_quantity_ytd	:= 0;
  			Tsk_bill_quantity_ptd	:= 0;
  			Tsk_bill_quantity_pp 	:= 0;

	  		Tsk_cmt_raw_cost_itd	:= 0;
  			Tsk_cmt_raw_cost_ytd	:= 0;
  			Tsk_cmt_raw_cost_ptd	:= 0;
  			Tsk_cmt_raw_cost_pp 	:= 0;

  			Tsk_burd_cost_itd	:= 0;
  			Tsk_burd_cost_ytd	:= 0;
  			Tsk_burd_cost_ptd	:= 0;
  			Tsk_burd_cost_pp 	:= 0;

  			Tsk_cmt_burd_cost_itd	:= 0;
  			Tsk_cmt_burd_cost_ytd	:= 0;
  			Tsk_cmt_burd_cost_ptd	:= 0;
  			Tsk_cmt_burd_cost_pp    := 0;

  			Tsk_labor_hours_itd	:= 0;
  			Tsk_labor_hours_ytd	:= 0;
  			Tsk_labor_hours_ptd	:= 0;
  			Tsk_labor_hours_pp 	:= 0;

  			Tsk_revenue_itd		:= 0;
  			Tsk_revenue_ytd		:= 0;
  			Tsk_revenue_ptd		:= 0;
  			Tsk_revenue_pp 		:= 0;

  			Tsk_bill_raw_cost_itd	:= 0;
  			Tsk_bill_raw_cost_ytd	:= 0;
  			Tsk_bill_raw_cost_ptd	:= 0;
  			Tsk_bill_raw_cost_pp 	:= 0;

  			Tsk_bill_burd_cost_itd	:= 0;
  			Tsk_bill_burd_cost_ytd	:= 0;
  			Tsk_bill_burd_cost_ptd	:= 0;
  			Tsk_bill_burd_cost_pp 	:= 0;

  			Tsk_bill_labor_hours_itd:= 0;
  			Tsk_bill_labor_hours_ytd:= 0;
  			Tsk_bill_labor_hours_ptd:= 0;
  			Tsk_bill_labor_hours_pp	:= 0;
end initialize_project_level;

Procedure Add_Project_Amounts is
begin
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    pa_debug.debug('Add_Project_Amount');
    END IF;
  		Tsk_raw_cost_itd	:= Tsk_raw_cost_itd +
					   New_raw_cost_itd;
  		Tsk_raw_cost_ytd	:= Tsk_raw_cost_ytd +
					   New_raw_cost_ytd;
  		Tsk_raw_cost_ptd	:= Tsk_raw_cost_ptd +
					   New_raw_cost_ptd;
  		Tsk_raw_cost_pp 	:= Tsk_raw_cost_pp +
					   New_raw_cost_pp;

  		Tsk_quantity_itd	:= Tsk_quantity_itd +
					   New_quantity_itd;
  		Tsk_quantity_ytd	:= Tsk_quantity_ytd +
					   New_quantity_ytd;
  		Tsk_quantity_ptd	:= Tsk_quantity_ptd +
					   New_quantity_ptd;
  		Tsk_quantity_pp 	:= Tsk_quantity_pp +
					   New_quantity_pp;

  		Tsk_bill_quantity_itd	:= Tsk_bill_quantity_itd +
					   New_bill_quantity_itd;
 	 	Tsk_bill_quantity_ytd	:= Tsk_bill_quantity_ytd +
					   New_bill_quantity_ytd;
 	 	Tsk_bill_quantity_ptd	:= Tsk_bill_quantity_ptd +
					   New_bill_quantity_ptd;
 	 	Tsk_bill_quantity_pp 	:= Tsk_bill_quantity_pp +
					   New_bill_quantity_pp;

  		Tsk_cmt_raw_cost_itd	:= Tsk_cmt_raw_cost_itd +
					   New_cmt_raw_cost_itd;
 	 	Tsk_cmt_raw_cost_ytd	:= Tsk_cmt_raw_cost_ytd +
					   New_cmt_raw_cost_ytd;
 	 	Tsk_cmt_raw_cost_ptd	:= Tsk_cmt_raw_cost_ptd +
					   New_cmt_raw_cost_ptd;
  		Tsk_cmt_raw_cost_pp 	:= Tsk_cmt_raw_cost_pp +
					   New_cmt_raw_cost_pp;

  		Tsk_burd_cost_itd	:= Tsk_burd_cost_itd +
					   New_burd_cost_itd;
 	 	Tsk_burd_cost_ytd	:= Tsk_burd_cost_ytd +
					   New_burd_cost_ytd;
 	 	Tsk_burd_cost_ptd	:= Tsk_burd_cost_ptd +
					   New_burd_cost_ptd;
 	 	Tsk_burd_cost_pp 	:= Tsk_burd_cost_pp +
					   New_burd_cost_pp;

  		Tsk_cmt_burd_cost_itd	:= Tsk_cmt_burd_cost_itd +
					   New_cmt_burd_cost_itd;
 	 	Tsk_cmt_burd_cost_ytd	:= Tsk_cmt_burd_cost_ytd +
					   New_cmt_burd_cost_ytd;
 	 	Tsk_cmt_burd_cost_ptd	:= Tsk_cmt_burd_cost_ptd +
					   New_cmt_burd_cost_ptd;
 	 	Tsk_cmt_burd_cost_pp 	:= Tsk_cmt_burd_cost_pp +
					   New_cmt_burd_cost_pp;

  		Tsk_labor_hours_itd	:= Tsk_labor_hours_itd +
					   New_labor_hours_itd;
 	 	Tsk_labor_hours_ytd	:= Tsk_labor_hours_ytd +
					   New_labor_hours_ytd;
 	 	Tsk_labor_hours_ptd	:= Tsk_labor_hours_ptd +
					   New_labor_hours_ptd;
 	 	Tsk_labor_hours_pp 	:= Tsk_labor_hours_pp+
					   New_labor_hours_pp;

  		Tsk_revenue_itd		:= Tsk_revenue_itd +
					   New_revenue_itd;
 	 	Tsk_revenue_ytd		:= Tsk_revenue_ytd +
					   New_revenue_ytd;
	  	Tsk_revenue_ptd		:= Tsk_revenue_ptd +
					   New_revenue_ptd;
 	 	Tsk_revenue_pp 		:= Tsk_revenue_pp +
					   New_revenue_pp;

  		Tsk_bill_raw_cost_itd	:= Tsk_bill_raw_cost_itd +
					   New_bill_raw_cost_itd;
 	 	Tsk_bill_raw_cost_ytd	:= Tsk_bill_raw_cost_ytd +
					   New_bill_raw_cost_ytd;
 	 	Tsk_bill_raw_cost_ptd	:= Tsk_bill_raw_cost_ptd +
					   New_bill_raw_cost_ptd;
  		Tsk_bill_raw_cost_pp 	:= Tsk_bill_raw_cost_pp +
					   New_bill_raw_cost_pp;

  		Tsk_bill_burd_cost_itd	:= Tsk_bill_burd_cost_itd +
					   New_bill_burd_cost_itd;
 	 	Tsk_bill_burd_cost_ytd	:= Tsk_bill_burd_cost_ytd +
					   New_bill_burd_cost_ytd;
  		Tsk_bill_burd_cost_ptd	:= Tsk_bill_burd_cost_ptd +
					   New_bill_burd_cost_ptd;
  		Tsk_bill_burd_cost_pp 	:= Tsk_bill_burd_cost_pp +
					   New_bill_burd_cost_pp;

  		Tsk_bill_labor_hours_itd :=Tsk_bill_labor_hours_itd +
					   New_bill_labor_hours_itd;
  		Tsk_bill_labor_hours_ytd :=Tsk_bill_labor_hours_ytd +
					   New_bill_labor_hours_ytd;
  		Tsk_bill_labor_hours_ptd :=Tsk_bill_labor_hours_ptd +
					   New_bill_labor_hours_ptd;
  		Tsk_bill_labor_hours_pp	 :=Tsk_bill_labor_hours_pp +
					   New_bill_labor_hours_pp;

  		Tsk_cmt_quantity_itd	:= Tsk_cmt_quantity_itd +
					   New_cmt_quantity_itd;
  		Tsk_cmt_quantity_ytd	:= Tsk_cmt_quantity_ytd +
					   New_cmt_quantity_ytd;
  		Tsk_cmt_quantity_ptd	:= Tsk_cmt_quantity_ptd +
					   New_cmt_quantity_ptd;
  		Tsk_cmt_quantity_pp 	:= Tsk_cmt_quantity_pp +
					   New_cmt_quantity_pp;
end add_project_amounts;

Procedure add_parent_amounts is
begin
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    pa_debug.debug('Add_parent_amounts');
    END IF;
  		Prt_raw_cost_itd	:= Prt_raw_cost_itd +
					   New_raw_cost_itd;
  		Prt_raw_cost_ytd	:= Prt_raw_cost_ytd +
					   New_raw_cost_ytd;
  		Prt_raw_cost_ptd	:= Prt_raw_cost_ptd +
					   New_raw_cost_ptd;
  		Prt_raw_cost_pp 	:= Prt_raw_cost_pp +
					   New_raw_cost_pp;

  		Prt_quantity_itd	:= Prt_quantity_itd +
					   New_quantity_itd;
  		Prt_quantity_ytd	:= Prt_quantity_ytd +
					   New_quantity_ytd;
  		Prt_quantity_ptd	:= Prt_quantity_ptd +
					   New_quantity_ptd;
  		Prt_quantity_pp 	:= Prt_quantity_pp +
					   New_quantity_pp;

  		Prt_bill_quantity_itd	:= Prt_bill_quantity_itd +
					   New_bill_quantity_itd;
 	 	Prt_bill_quantity_ytd	:= Prt_bill_quantity_ytd +
					   New_bill_quantity_ytd;
 	 	Prt_bill_quantity_ptd	:= Prt_bill_quantity_ptd +
					   New_bill_quantity_ptd;
 	 	Prt_bill_quantity_pp 	:= Prt_bill_quantity_pp +
					   New_bill_quantity_pp;

  		Prt_cmt_raw_cost_itd	:= Prt_cmt_raw_cost_itd +
					   New_cmt_raw_cost_itd;
 	 	Prt_cmt_raw_cost_ytd	:= Prt_cmt_raw_cost_ytd +
					   New_cmt_raw_cost_ytd;
 	 	Prt_cmt_raw_cost_ptd	:= Prt_cmt_raw_cost_ptd +
					   New_cmt_raw_cost_ptd;
  		Prt_cmt_raw_cost_pp 	:= Prt_cmt_raw_cost_pp +
					   New_cmt_raw_cost_pp;

  		Prt_burd_cost_itd	:= Prt_burd_cost_itd +
					   New_burd_cost_itd;
 	 	Prt_burd_cost_ytd	:= Prt_burd_cost_ytd +
					   New_burd_cost_ytd;
 	 	Prt_burd_cost_ptd	:= Prt_burd_cost_ptd +
					   New_burd_cost_ptd;
 	 	Prt_burd_cost_pp 	:= Prt_burd_cost_pp +
					   New_burd_cost_pp;

  		Prt_cmt_burd_cost_itd	:= Prt_cmt_burd_cost_itd +
					   New_cmt_burd_cost_itd;
 	 	Prt_cmt_burd_cost_ytd	:= Prt_cmt_burd_cost_ytd +
					   New_cmt_burd_cost_ytd;
 	 	Prt_cmt_burd_cost_ptd	:= Prt_cmt_burd_cost_ptd +
					   New_cmt_burd_cost_ptd;
 	 	Prt_cmt_burd_cost_pp 	:= Prt_cmt_burd_cost_pp +
					   New_cmt_burd_cost_pp;

  		Prt_labor_hours_itd	:= Prt_labor_hours_itd +
					   New_labor_hours_itd;
 	 	Prt_labor_hours_ytd	:= Prt_labor_hours_ytd +
					   New_labor_hours_ytd;
 	 	Prt_labor_hours_ptd	:= Prt_labor_hours_ptd +
					   New_labor_hours_ptd;
 	 	Prt_labor_hours_pp 	:= Prt_labor_hours_pp+
					   New_labor_hours_pp;

  		Prt_revenue_itd		:= Prt_revenue_itd +
					   New_revenue_itd;
 	 	Prt_revenue_ytd		:= Prt_revenue_ytd +
					   New_revenue_ytd;
	  	Prt_revenue_ptd		:= Prt_revenue_ptd +
					   New_revenue_ptd;
 	 	Prt_revenue_pp 		:= Prt_revenue_pp +
					   New_revenue_pp;

  		Prt_bill_raw_cost_itd	:= Prt_bill_raw_cost_itd +
					   New_bill_raw_cost_itd;
 	 	Prt_bill_raw_cost_ytd	:= Prt_bill_raw_cost_ytd +
					   New_bill_raw_cost_ytd;
 	 	Prt_bill_raw_cost_ptd	:= Prt_bill_raw_cost_ptd +
					   New_bill_raw_cost_ptd;
  		Prt_bill_raw_cost_pp 	:= Prt_bill_raw_cost_pp +
					   New_bill_raw_cost_pp;

  		Prt_bill_burd_cost_itd	:= Prt_bill_burd_cost_itd +
					   New_bill_burd_cost_itd;
 	 	Prt_bill_burd_cost_ytd	:= Prt_bill_burd_cost_ytd +
					   New_bill_burd_cost_ytd;
  		Prt_bill_burd_cost_ptd	:= Prt_bill_burd_cost_ptd +
					   New_bill_burd_cost_ptd;
  		Prt_bill_burd_cost_pp 	:= Prt_bill_burd_cost_pp +
					   New_bill_burd_cost_pp;

  		Prt_bill_labor_hours_itd :=Prt_bill_labor_hours_itd +
					   New_bill_labor_hours_itd;
  		Prt_bill_labor_hours_ytd :=Prt_bill_labor_hours_ytd +
					   New_bill_labor_hours_ytd;
  		Prt_bill_labor_hours_ptd :=Prt_bill_labor_hours_ptd +
					   New_bill_labor_hours_ptd;
  		Prt_bill_labor_hours_pp	 :=Prt_bill_labor_hours_pp +
					   New_bill_labor_hours_pp;

  		Prt_cmt_quantity_itd	:= Prt_cmt_quantity_itd +
					   New_cmt_quantity_itd;
  		Prt_cmt_quantity_ytd	:= Prt_cmt_quantity_ytd +
					   New_cmt_quantity_ytd;
  		Prt_cmt_quantity_ptd	:= Prt_cmt_quantity_ptd +
					   New_cmt_quantity_ptd;
  		Prt_cmt_quantity_pp 	:= Prt_cmt_quantity_pp +
					   New_cmt_quantity_pp;
end add_parent_amounts;
End PA_MAINT_PROJECT_ACCUMS;

/
