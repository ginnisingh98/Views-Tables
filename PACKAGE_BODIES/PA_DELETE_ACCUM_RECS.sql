--------------------------------------------------------
--  DDL for Package Body PA_DELETE_ACCUM_RECS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DELETE_ACCUM_RECS" AS
/* $Header: PAACDELB.pls 120.2 2005/09/26 15:12:32 jwhite noship $ */


-- This procedure deletes records from PA_PROJECT_ACCUM_COMMITMENTS
--
--
--Note:
--
--     With the advent of the Project-List application, the Copy_Project
--     PA_ACCUM_PROJ_LIST.Insert_Accum procedure inserts project-level
--     commitment records.
--
--
--     Project-level records are NOT deleted by this procedure. Instead, they are initialized
--     to zero amounts and NULL varchar2 columns. The corresponding lower-level records are
--     deleted, however.
--
--
--History:
--      xx-xxx-xxxx     who?            - Created
--
--      23-OCT-2002     jwhite          - Bug 2633920
--                                        Add logic to INIT, NOT Delete
--                                        project-level Project-List commitment records.
--
--
--
Procedure Delete_Project_Commitments (x_project_Id In Number,
                                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code      In Out NOCOPY Number ) Is --File.Sql.39 bug 4440895


        V_Old_Stack          Varchar2(630);
        tot_recs_processed   Number;

        l_Prj_Lvl_Accum_Id   NUMBER         := NULL;
        l_msg_count          NUMBER         := NULL;
        l_msg_data           VARCHAR2(2000) := NULL;
        l_return_status      VARCHAR2(1)    := NULL;


Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_DELETE_ACCUM_RECS.Delete_Project_Commitments';
      x_err_code  := 0;
      x_err_stage := 'Deleting PA_PROJECT_ACCUM_COMMITMENTS';
      tot_recs_processed := 0;

      pa_debug.debug(x_err_stack);


      -- Get the Project-Level Project Accum Id.
      --   Note: No error processing for this procedure as none expected
      PA_DELETE_ACCUM_RECS.Get_Prj_Lvl_Accum_Id (p_project_id     => x_project_Id
                                 , x_Prj_Lvl_Accum_Id             => l_Prj_Lvl_Accum_Id
                                 , x_msg_count                    => l_msg_count
                                 , x_msg_data                     => l_msg_data
                                 , x_return_status                => l_return_status);


      Loop

          -- Except for the Project-Level Record, Purge ALL Other Commitment Records --------------

          Delete From PA_PROJECT_ACCUM_COMMITMENTS PAC
          Where PAC.Project_Accum_id IN
                            (Select  Project_Accum_id
                             from    PA_PROJECT_ACCUM_HEADERS PAH
                             Where   PAH.Project_Id = x_project_id
                             and     PAH.project_accum_id <> l_Prj_Lvl_Accum_Id -- Skip project-level record
                             )
          AND  rownum <= pa_proj_accum_main.x_commit_size;
          if sql%rowcount < pa_proj_accum_main.x_commit_size then
                  /*    Commented for Bug 2984871 Commit;*/
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
                  Commit;
                  exit;
          else
                  /*    Commented for Bug 2984871 Commit;*/
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
                  Commit;
          end if;
      End loop;


      -- Initialize the Project-Level Commitments Records to Zeros/NULLs -----------

      UPDATE pa_project_accum_commitments SET
      CMT_RAW_COST_ITD = 0
      ,CMT_RAW_COST_YTD = 0
      ,CMT_RAW_COST_PP = 0
      ,CMT_RAW_COST_PTD = 0
      ,CMT_BURDENED_COST_ITD = 0
      ,CMT_BURDENED_COST_YTD = 0
      ,CMT_BURDENED_COST_PP = 0
      ,CMT_BURDENED_COST_PTD = 0
      ,CMT_QUANTITY_ITD = 0
      ,CMT_QUANTITY_YTD = 0
      ,CMT_QUANTITY_PP = 0
      ,CMT_QUANTITY_PTD = 0
      ,CMT_UNIT_OF_MEASURE = NULL
      ,REQUEST_ID = pa_proj_accum_main.x_request_id
      ,LAST_UPDATED_BY = pa_proj_accum_main.x_last_updated_by
      ,LAST_UPDATE_DATE = Trunc(sysdate)
      ,LAST_UPDATE_LOGIN = pa_proj_accum_main.x_last_update_login
      WHERE Project_Accum_id = l_Prj_Lvl_Accum_Id;


      COMMIT;


      pa_debug.debug('Number of Records Deleted = '|| TO_CHAR(tot_recs_processed));

      -- Restore the old x_err_stack;
      x_err_stack := V_Old_Stack;
Exception
  When Others Then
    x_err_code := SQLCODE;
    RAISE;
End Delete_Project_Commitments;

-- This procedure deletes records from PA_PROJECT_ACCUM_BUDGETS after
-- ensuring that the current Budget version has not been accumulated.
--
--
--Note:
--
--     With the advent of the Project-List application, the Copy_Project
--     PA_ACCUM_PROJ_LIST.Insert_Accum procedure inserts project-level
--     'AC' and 'AR' budget_type_code budget records.
--
--     Also, with the advent of the FP model, AC/AR budget records may be inserted
--     for approved cost and revenue plan types.
--
--     AC/AR records are NOT deleted by this procedure. Instead, they are initialized
--     to zero amounts and NULL varchar2 columns. The corresponding lower-level records are
--     deleted, however.
--
--     If x_budget_Type_Code is specified, then it is primarily for r11.5.7 Budget Type processing,
--       BUT PLEASE NOTE the following:
--
--       1) If the passed value is 'AC' or 'AR', then AC/AR records, whether created for
--          a r11.5.7 Budget or FP model will be processed.
--
--       2) Otherwise, only matching r11.5.7 budget records will be processed.
--
--
--
--History:
--      xx-xxx-xxxx     who?            - Created
--
--      26-SEP-2002     jwhite          - Converted to support both r11.5.7 Budget and FP models.
--                                        If the x_budget_Type_Code is NULL,
--                                          THEN purge ALL qaulifying budget and FP records.
--                                        ELSE
--                                          only purge x_budget_Type_Code budget_type records.
--
--      23-OCT-2002     jwhite          - Bug 2633920
--                                        Add logic to INIT, NOT Delete
--                                        project-level Project-List budget records.
--
--      16-SEP-2005     jwhite          - Bug bug 4583454
--                                        Agumented purge functionality for "budget_type_code" support
--                                        of the following Financial Plan types:
--                                        1) PRIMARY_COST_FORECAST_FLAG = FC
--                                        2) PRIMARY_REV_FORECAST_FLAG  = FR
--
--

Procedure Delete_Project_Budgets     (x_project_Id In Number,
                                      x_budget_Type_Code In Varchar2,
                                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code      In Out NOCOPY Number ) Is --File.Sql.39 bug 4440895




-- Use this Cursor to Retrieve the following:
--
-- 1) The specified r11.5.7 budget_type_code
--
-- 2) The FP model entities corresponding to r11.5.7 x_budget_type_code in ('AC', 'AR')
--
-- 3) A-L-L r11.5.7 Budget and FP Model budget records
--
-- Please Note:
--  Unlike the summarization pa_project_accum_budgets INSERT logic, this cursor logic does NOT need
--  to consider as many cases for the FP Model for the following reasons:
--
--  1) This logic simply deletes records. It is not concerned with double-counting amounts.
--
--  2) If to_char(fin_plan_type_id) returns a value that has
--     NOT been previously inserted as budget record, then the delete will simply not purge anything
--     for that cursor record. No harm.
--
--

Cursor  Budget_ver_cur
IS
SELECT  PAB.budget_type_code  budget_type_code
FROM
(
SELECT pabv.budget_type_code   budget_type_code
FROM PA_BUDGET_VERSIONS PABV
WHERE  pabv.Project_id = x_project_id
AND pabv.Current_Flag = 'Y'
AND pabv.Resource_Accumulated_Flag = 'N'
and pabv.budget_type_code IS NOT NULL                  -- r11.5.7 Budget Model
and pabv.Budget_type_code = nvl(x_budget_type_code, pabv.Budget_type_code)
UNION ALL
SELECT  to_char(fin_plan_type_id)  budget_type_code
FROM PA_BUDGET_VERSIONS PABV
WHERE  pabv.Project_id = x_project_id
AND pabv.Current_Flag = 'Y'
AND pabv.Resource_Accumulated_Flag = 'N'
and pabv.budget_type_code IS NULL                      -- Strictly FP model, NO AC/AR budget_type_codes
and x_budget_type_code IS NULL
UNION ALL
SELECT  'AC'   budget_type_code
FROM PA_BUDGET_VERSIONS PABV
WHERE  pabv.Project_id = x_project_id
AND pabv.Current_Flag = 'Y'
AND pabv.Resource_Accumulated_Flag = 'N'
and pabv.budget_type_code IS NULL                      -- FP model, Approved Cost
and nvl(pabv.approved_cost_plan_type_flag, 'N') = 'Y'
and 'AC' = nvl(x_budget_type_code, 'AC')
UNION ALL
SELECT  'AR'   budget_type_code
FROM PA_BUDGET_VERSIONS PABV
WHERE  pabv.Project_id = x_project_id
AND pabv.Current_Flag = 'Y'
AND pabv.Resource_Accumulated_Flag = 'N'
and pabv.budget_type_code IS NULL                       -- FP model, Approved Revenue
and nvl(pabv.approved_rev_plan_type_flag, 'N') = 'Y'
and 'AR' = nvl(x_budget_type_code, 'AR')
UNION ALL
SELECT  'FC'   budget_type_code
FROM PA_BUDGET_VERSIONS PABV
WHERE  pabv.Project_id = x_project_id
AND pabv.Current_Flag = 'Y'
AND pabv.Resource_Accumulated_Flag = 'N'
and pabv.budget_type_code IS NULL                      -- FP model, PRIMARY FORECAST Cost
and nvl(pabv.primary_cost_forecast_flag, 'N') = 'Y'
and 'FC' = nvl(x_budget_type_code, 'FC')
UNION ALL
SELECT  'FR'   budget_type_code
FROM PA_BUDGET_VERSIONS PABV
WHERE  pabv.Project_id = x_project_id
AND pabv.Current_Flag = 'Y'
AND pabv.Resource_Accumulated_Flag = 'N'
and pabv.budget_type_code IS NULL                       -- FP model, PRIMARY FORECAST Revenue
and nvl(pabv.primary_rev_forecast_flag, 'N') = 'Y'
and 'FR' = nvl(x_budget_type_code, 'FR')
) PAB;


        V_Old_Stack          Varchar2(630);
        budget_ver_rec       Budget_ver_cur%ROWTYPE;

        l_Prj_Lvl_Accum_Id   NUMBER         := NULL;
        l_msg_count          NUMBER         := NULL;
        l_msg_data           VARCHAR2(2000) := NULL;
        l_return_status      VARCHAR2(1)    := NULL;

Begin

   V_Old_Stack := x_err_stack;
   x_err_stack :=
   x_err_stack ||'->PA_DELETE_ACCUM_RECS.Delete_Project_Budgets';
   x_err_code  := 0;
   x_err_stage := 'deleteing pa_project_accum_budgets';

   pa_debug.debug(x_err_stack);


   -- Get the Project-Level Project Accum Id.
   --   Note: No error processing for this procedure as none expected
   PA_DELETE_ACCUM_RECS.Get_Prj_Lvl_Accum_Id (p_project_id     => x_project_Id
                                 , x_Prj_Lvl_Accum_Id             => l_Prj_Lvl_Accum_Id
                                 , x_msg_count                    => l_msg_count
                                 , x_msg_data                     => l_msg_data
                                 , x_return_status                => l_return_status);



    FOR Budget_ver_rec IN Budget_ver_cur

     LOOP

      IF (Budget_ver_rec.budget_type_code IN ('AC', 'AR')
          )
        THEN
        -- Project-List AC/AR Required Budget Types -------------


           -- Except for the AC and AR Project-Level records, Purge ALL Other Records
           -- because specified tasks/resources may have changed
           -- since last baseline.

           Delete From PA_PROJECT_ACCUM_BUDGETS
           Where  Budget_Type_Code = Budget_ver_rec.budget_type_code
           and Project_Accum_id IN
                      (Select  Project_Accum_id
                       from    PA_PROJECT_ACCUM_HEADERS PAH
                       Where   PAH.Project_Id = x_project_id
                       and     PAH.project_accum_id <> l_Prj_Lvl_Accum_Id -- Skip project-level records
                       );

           -- INIT AC/AR Project-Level Budget Record to Zeros/NULLs ----------

           UPDATE pa_project_accum_budgets SET
           BASE_RAW_COST_ITD = 0
           ,BASE_RAW_COST_YTD = 0
           ,BASE_RAW_COST_PP = 0
           ,BASE_RAW_COST_PTD = 0
           ,BASE_BURDENED_COST_ITD = 0
           ,BASE_BURDENED_COST_YTD = 0
           ,BASE_BURDENED_COST_PP = 0
           ,BASE_BURDENED_COST_PTD = 0
           ,ORIG_RAW_COST_ITD = 0
           ,ORIG_RAW_COST_YTD = 0
           ,ORIG_RAW_COST_PP = 0
           ,ORIG_RAW_COST_PTD = 0
           ,ORIG_BURDENED_COST_ITD = 0
           ,ORIG_BURDENED_COST_YTD = 0
           ,ORIG_BURDENED_COST_PP = 0
           ,ORIG_BURDENED_COST_PTD = 0
           ,BASE_QUANTITY_ITD = 0
           ,BASE_QUANTITY_YTD = 0
           ,BASE_QUANTITY_PP = 0
           ,BASE_QUANTITY_PTD = 0
           ,ORIG_QUANTITY_ITD = 0
           ,ORIG_QUANTITY_YTD = 0
           ,ORIG_QUANTITY_PP = 0
           ,ORIG_QUANTITY_PTD = 0
           ,BASE_LABOR_HOURS_ITD = 0
           ,BASE_LABOR_HOURS_YTD = 0
           ,BASE_LABOR_HOURS_PP = 0
           ,BASE_LABOR_HOURS_PTD = 0
           ,ORIG_LABOR_HOURS_ITD = 0
           ,ORIG_LABOR_HOURS_YTD = 0
           ,ORIG_LABOR_HOURS_PP = 0
           ,ORIG_LABOR_HOURS_PTD = 0
           ,BASE_REVENUE_ITD = 0
           ,BASE_REVENUE_YTD = 0
           ,BASE_REVENUE_PP = 0
           ,BASE_REVENUE_PTD = 0
           ,ORIG_REVENUE_ITD = 0
           ,ORIG_REVENUE_YTD = 0
           ,ORIG_REVENUE_PP = 0
           ,ORIG_REVENUE_PTD = 0
           ,BASE_UNIT_OF_MEASURE = NULL
           ,ORIG_UNIT_OF_MEASURE = NULL
           ,BASE_RAW_COST_TOT = 0
           ,BASE_BURDENED_COST_TOT = 0
           ,ORIG_RAW_COST_TOT = 0
           ,ORIG_BURDENED_COST_TOT = 0
           ,BASE_REVENUE_TOT = 0
           ,ORIG_REVENUE_TOT = 0
           ,BASE_LABOR_HOURS_TOT = 0
           ,ORIG_LABOR_HOURS_TOT = 0
           ,BASE_QUANTITY_TOT = 0
           ,ORIG_QUANTITY_TOT = 0
           ,REQUEST_ID = pa_proj_accum_main.x_request_id
           ,LAST_UPDATED_BY = pa_proj_accum_main.x_last_updated_by
           ,LAST_UPDATE_DATE = Trunc(sysdate)
           ,LAST_UPDATE_LOGIN = pa_proj_accum_main.x_last_update_login
           WHERE  Budget_Type_Code = Budget_ver_rec.budget_type_code
           AND Project_Accum_id = l_Prj_Lvl_Accum_Id;


      ELSE

           -- Purge ALL r11.5.7 Budget and/or FP Budget Records

           Delete From PA_PROJECT_ACCUM_BUDGETS
           Where  Budget_Type_Code = Budget_ver_rec.budget_type_code
           and Project_Accum_id IN
                      (Select  Project_Accum_id
                       from    PA_PROJECT_ACCUM_HEADERS PAH
                       Where   PAH.Project_Id = x_project_id
                       );


      END IF; -- AC/AR Project List Budget Type


      /* Bug 2984871: Commented the commit and added it after the debug call
      Commit;*/
      pa_debug.debug('Number of Records Deleted = '|| TO_CHAR(SQL%ROWCOUNT));
      Commit;

     END LOOP;



   -- Restore the old x_err_stack;
   x_err_stack := V_Old_Stack;
Exception
  When Others Then
    x_err_code := SQLCODE;
    RAISE;
End Delete_Project_Budgets;

-- This procedure deletes records from PA_PROJECT_ACCUM_ACTUALS
--
--
--Note:
--
--     With the advent of the Project-List application, the Copy_Project
--     PA_ACCUM_PROJ_LIST.Insert_Accum procedure inserts project-level
--     actuals records.
--
--
--     Project-level records are NOT deleted by this procedure. Instead, they are initialized
--     to zero amounts and NULL varchar2 columns. The corresponding lower-level records are
--     deleted, however.
--
--
--History:
--      xx-xxx-xxxx     who?            - Created
--
--      23-OCT-2002     jwhite          - Bug 2633920
--                                        Add logic to INIT, NOT Delete
--                                        project-level Project-List actuals records.
--
--
Procedure Delete_Project_Actuals     (x_project_Id In Number,
                                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

        V_Old_Stack            Varchar2(630);
        tot_recs_processed     Number;


        l_Prj_Lvl_Accum_Id   NUMBER         := NULL;
        l_msg_count          NUMBER         := NULL;
        l_msg_data           VARCHAR2(2000) := NULL;
        l_return_status      VARCHAR2(1)    := NULL;

Begin
     V_Old_Stack := x_err_stack;
     x_err_stack :=
     x_err_stack ||'->PA_DELETE_ACCUM_RECS.Delete_Project_Actuals';
     x_err_code  := 0;
     x_err_stage := 'deleting PA_PROJECT_ACCUM_ACTUALS';
     tot_recs_processed := 0;

     pa_debug.debug(x_err_stack);




   -- Get the Project-Level Project Accum Id.
      --   Note: No error processing for this procedure as none expected
      PA_DELETE_ACCUM_RECS.Get_Prj_Lvl_Accum_Id (p_project_id     => x_project_Id
                                 , x_Prj_Lvl_Accum_Id             => l_Prj_Lvl_Accum_Id
                                 , x_msg_count                    => l_msg_count
                                 , x_msg_data                     => l_msg_data
                                 , x_return_status                => l_return_status);



     LOOP

          -- Except for Project-Level Record, Purge ALL Other Commitment Records --------------

          Delete From PA_PROJECT_ACCUM_ACTUALS PAA
          Where PAA.Project_Accum_id IN
                            (Select  Project_Accum_id
                             from    PA_PROJECT_ACCUM_HEADERS PAH
                             Where   PAH.Project_Id = x_project_id
                             and     PAH.project_accum_id <> l_Prj_Lvl_Accum_Id -- Skip project-level records
                             )
          AND  rownum <= pa_proj_accum_main.x_commit_size;
          if sql%rowcount < pa_proj_accum_main.x_commit_size then
                  /*    Commented for Bug 2984871 Commit;*/
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
                  Commit;
                  exit;
          else
                  /*    Commented for Bug 2984871 Commit;*/
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
                  Commit;
          end if;

      End loop;


      -- Initialize the Project-Level Commitments Records to Zeros/NULLs -----------

      UPDATE pa_project_accum_actuals SET
      RAW_COST_ITD = 0
      ,RAW_COST_YTD = 0
      ,RAW_COST_PP = 0
      ,RAW_COST_PTD = 0
      ,BILLABLE_RAW_COST_ITD = 0
      ,BILLABLE_RAW_COST_YTD = 0
      ,BILLABLE_RAW_COST_PP = 0
      ,BILLABLE_RAW_COST_PTD = 0
      ,BURDENED_COST_ITD = 0
      ,BURDENED_COST_YTD = 0
      ,BURDENED_COST_PP = 0
      ,BURDENED_COST_PTD = 0
      ,BILLABLE_BURDENED_COST_ITD = 0
      ,BILLABLE_BURDENED_COST_YTD = 0
      ,BILLABLE_BURDENED_COST_PP = 0
      ,BILLABLE_BURDENED_COST_PTD = 0
      ,QUANTITY_ITD = 0
      ,QUANTITY_YTD = 0
      ,QUANTITY_PP = 0
      ,QUANTITY_PTD = 0
      ,LABOR_HOURS_ITD = 0
      ,LABOR_HOURS_YTD = 0
      ,LABOR_HOURS_PP = 0
      ,LABOR_HOURS_PTD = 0
      ,BILLABLE_QUANTITY_ITD = 0
      ,BILLABLE_QUANTITY_YTD = 0
      ,BILLABLE_QUANTITY_PP = 0
      ,BILLABLE_QUANTITY_PTD = 0
      ,BILLABLE_LABOR_HOURS_ITD = 0
      ,BILLABLE_LABOR_HOURS_YTD = 0
      ,BILLABLE_LABOR_HOURS_PP = 0
      ,BILLABLE_LABOR_HOURS_PTD = 0
      ,REVENUE_ITD = 0
      ,REVENUE_YTD = 0
      ,REVENUE_PP = 0
      ,REVENUE_PTD = 0
      ,TXN_UNIT_OF_MEASURE = NULL
      ,REQUEST_ID = pa_proj_accum_main.x_request_id
      ,LAST_UPDATED_BY = pa_proj_accum_main.x_last_updated_by
      ,LAST_UPDATE_DATE = Trunc(sysdate)
      ,LAST_UPDATE_LOGIN = pa_proj_accum_main.x_last_update_login
      WHERE Project_Accum_id = l_Prj_Lvl_Accum_Id;


      COMMIT;

     pa_debug.debug('Number of Records Deleted = '|| TO_CHAR(tot_recs_processed));
     -- Restore the old x_err_stack;

     x_err_stack := V_Old_Stack;
Exception
  When Others Then
    x_err_code := SQLCODE;
    RAISE;

End Delete_Project_Actuals;

-- This procedure deletes records from the PA_PROJECT_ACCUM_ACTUALS table
-- for the given Resource List
--
-- Note: This procedure does not require modification for Project List
--       functionality.
--

Procedure Delete_Res_List_Actuals      (x_project_id In Number,
                                        x_Resource_list_id In Number,
                                        x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                        x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                        x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


V_Old_Stack          Varchar2(630);
tot_recs_processed   Number;
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_DELETE_ACCUM_RECS.Delete_Res_List_Actuals';
      x_err_code  := 0;
      x_err_stage := 'deleteing PA_PROJECT_ACCUM_ACTUALS';
      tot_recs_processed := 0;
      pa_debug.debug(x_err_stack);

     Loop

         Delete From PA_PROJECT_ACCUM_ACTUALS PAA
         Where Project_Accum_id IN
           (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
            PAH.Project_Id = x_project_id and
            PAH.resource_list_member_id <> 0  and
            PAH.Resource_List_id = NVL(x_Resource_list_id,PAH.Resource_List_id))
        and rownum <= pa_proj_accum_main.x_commit_size;

          if sql%rowcount < pa_proj_accum_main.x_commit_size then
                  /*    Commented for Bug 2984871 Commit;*/
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
		  Commit;
                  exit;
          else
                  /*    Commented for Bug 2984871 Commit;*/
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
		  Commit;
          end if;
      End loop;

     pa_debug.debug('Number of Records Deleted = '|| TO_CHAR(tot_recs_processed));

     -- Restore the old x_err_stack;

     x_err_stack := V_Old_Stack;
Exception
  When Others Then
    x_err_code := SQLCODE;
    RAISE;

End Delete_Res_List_Actuals;

-- This procedure deletes records from PA_PROJECT_ACCUM_COMMITMENTS for the
-- given Resource List
--
-- Note: This procedure does not require modification for Project List
--       functionality.
--

Procedure Delete_Res_List_Commitments (x_project_id In Number,
                                       x_Resource_list_id In Number,
                                       x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


V_Old_Stack           Varchar2(630);
tot_recs_processed    Number;
Begin
     V_Old_Stack := x_err_stack;
     x_err_stack :=
     x_err_stack ||'->PA_DELETE_ACCUM_RECS.Delete_Res_List_Commitments';
     x_err_code  := 0;
     x_err_stage := 'deleting PA_PROJECT_ACCUM_COMMITMENTS';
     tot_recs_processed := 0;

     pa_debug.debug(x_err_stack);

     Loop

         Delete From PA_PROJECT_ACCUM_COMMITMENTS PAC
         Where Project_Accum_id IN
           (Select Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH Where
            PAH.Project_Id = x_project_id and
            PAH.resource_list_member_id <> 0  and
            PAH.Resource_List_id = NVL(x_Resource_list_id,PAH.Resource_List_id))
         and rownum <= pa_proj_accum_main.x_commit_size;

          if sql%rowcount < pa_proj_accum_main.x_commit_size then
                  /*    Commented for Bug 2984871 Commit;*/
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
		  Commit;
                  exit;
          else
                  /*    Commented for Bug 2984871 Commit;*/
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
		  Commit;
          end if;
      End loop;


     pa_debug.debug('Number of Records Deleted = '|| TO_CHAR(tot_recs_processed));

     -- Restore the old x_err_stack;
     x_err_stack := V_Old_Stack;
Exception
  When Others Then
    x_err_code := SQLCODE;
    RAISE;
End Delete_Res_List_Commitments;

-- This procedure deletes records from PA_PROJECT_ACCUM_HEADERS if there
-- are NO corresponding records in ACTUALS,COMMITMENTS and BUDGETS tables
-- for the given project.
--
--
--Note:
--
--     With the advent of the Project-List application, the Copy_Project
--     PA_ACCUM_PROJ_LIST.Insert_Accum procedure inserts project-level
--     actuals records.
--
--     Therefore, PA_PROJECT_ACCUM_HEADER records for lower-level Project-level records are
--     NOT deleted by this procedure.
--
--
--History:
--      xx-xxx-xxxx     who?            - Created
--
--      23-OCT-2002     jwhite          - Bug 2633920
--                                        Add logic to prevent deletion of
--                                        project-level Project-List records.
--
--

Procedure Delete_Project_Accum_Headers (x_project_id In Number,
                                        x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                        x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                        x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


        V_Old_Stack        Varchar2(630);
        tot_recs_processed Number;


        l_Prj_Lvl_Accum_Id   NUMBER         := NULL;
        l_msg_count          NUMBER         := NULL;
        l_msg_data           VARCHAR2(2000) := NULL;
        l_return_status      VARCHAR2(1)    := NULL;

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_DELETE_ACCUM_RECS.Delete_Project_Accum_Headers';
      x_err_code  := 0;
      x_err_stage := 'deleting PA_PROJECT_ACCUM_HEADERS';
      tot_recs_processed := 0;

      pa_debug.debug(x_err_stack);



      -- Get the Project-Level Project Accum Id.
      --   Note: No error processing for this procedure as none expected
      PA_DELETE_ACCUM_RECS.Get_Prj_Lvl_Accum_Id (p_project_id     => x_project_Id
                                 , x_Prj_Lvl_Accum_Id             => l_Prj_Lvl_Accum_Id
                                 , x_msg_count                    => l_msg_count
                                 , x_msg_data                     => l_msg_data
                                 , x_return_status                => l_return_status);


      Loop


      Delete From PA_PROJECT_ACCUM_HEADERS PAH Where
      PAH.Project_Id = x_project_id
      AND PAH.project_accum_id <> l_Prj_Lvl_Accum_Id  -- Don't delete project-level row details.
      AND Not Exists
        (Select 'Yes' from PA_PROJECT_ACCUM_ACTUALS PAA
         Where PAH.PROJECT_ACCUM_ID = PAA.PROJECT_ACCUM_ID)
      AND Not Exists
        (Select 'Yes' from PA_PROJECT_ACCUM_COMMITMENTS PAC
         Where PAH.PROJECT_ACCUM_ID = PAC.PROJECT_ACCUM_ID)
      AND Not Exists
        (Select 'Yes' from PA_PROJECT_ACCUM_BUDGETS PAB
        Where PAH.PROJECT_ACCUM_ID = PAB.PROJECT_ACCUM_ID)
      and rownum <= pa_proj_accum_main.x_commit_size;


          if sql%rowcount < pa_proj_accum_main.x_commit_size then
                  /*    Commented for Bug 2984871 Commit;*/
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
		  Commit;
                  exit;
          else
                  /*    Commented for Bug 2984871 Commit;*/
                  tot_recs_processed := tot_recs_processed + sql%rowcount;
		  Commit;
          end if;
      End loop;

      pa_debug.debug('Number of Records Deleted = '|| TO_CHAR(tot_recs_processed));

      -- Restore the old x_err_stack;

      x_err_stack := V_Old_Stack;
Exception
  When Others Then
    x_err_code := SQLCODE;
    RAISE;

End Delete_Project_Accum_Headers;



-- This procedure returns the project-level project_accum_id for the
-- passed p_project_id IN-parameter.
--
--Called subprograms: None.
--
--Note:
--
--
--History:
--      23-OCT-2002     jwhite          - Created per bug 2633920
--
--
PROCEDURE Get_Prj_Lvl_Accum_Id (p_project_id            IN   NUMBER
                                 , x_Prj_Lvl_Accum_Id   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                                 , x_msg_count          OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                                 , x_msg_data           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                 , x_return_status      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                 ) IS



     l_Prj_Lvl_Accum_Id    pa_project_accum_headers.project_accum_id%TYPE := NULL;


  BEGIN

        -- Assume Success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count     := 0;
        x_msg_data      := NULL;


       IF (p_project_id <> nvl(PA_DELETE_ACCUM_RECS.G_Prj_Lvl_project_id, '-99')
            )
          THEN

            BEGIN

               -- FETCH New Project-Level Project_Accum_Id

               SELECT project_accum_id
               INTO   l_Prj_Lvl_Accum_Id
               FROM   pa_project_accum_headers
               WHERE  project_id = p_project_id
               AND    task_id = 0
               AND    resource_list_member_id = 0;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      l_Prj_Lvl_Accum_Id := -99;

            END;

               -- Store Package Spec Globals for Future Calls to this Procedure.

               PA_DELETE_ACCUM_RECS.G_Prj_Lvl_project_id  := p_project_id;
               PA_DELETE_ACCUM_RECS.G_Prj_Lvl_Accum_Id    := l_Prj_Lvl_Accum_Id;



       END IF;


       -- Return Previously Stored Project-Level Project_Accum_Id

       x_Prj_Lvl_Accum_Id := PA_DELETE_ACCUM_RECS.G_Prj_Lvl_Accum_Id;


    EXCEPTION
    WHEN OTHERS
        THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Add_Exc_Msg
                        (  p_pkg_name           => 'PA_DELETE_ACCUM_RECS'
                        ,  p_procedure_name     => 'GET_PRJ_LVL_ACCUM_ID'
                        ,  p_error_text         => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
         FND_MSG_PUB.Count_And_Get
         (p_count               =>      x_msg_count     ,
          p_data                =>      x_msg_data      );
         RETURN;


END Get_Prj_Lvl_Accum_Id;





End PA_DELETE_ACCUM_RECS;

/
