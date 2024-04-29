--------------------------------------------------------
--  DDL for Package Body PA_PROCESS_ACCUM_COMMITMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROCESS_ACCUM_COMMITMENTS" AS
/* $Header: PACMTSKB.pls 120.2 2005/08/31 11:08:20 vmangulu noship $ */

-- The procedures are called by
-- PA_MAINT_PROJECT_COMMITMENTS.Process_Txn_Accum_Cmt

Procedure   Process_it_yt_pt_tasks_cmt
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_id In Number,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Process_it_yt_pt_tasks_cmt - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.
Recs_processed Number := 0;
V_Accum_id     Number := 0;
V_task_array task_id_tabtype;
v_noof_tasks Number := 0;
other_recs_processed Number := 0;
V_Old_Stack       Varchar2(630);
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_COMMITMENTS.Process_it_yt_pt_tasks_cmt';

      pa_debug.debug(x_err_stack);

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project and task combination. It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              x_task_id,
                              0,
                              other_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + other_recs_processed;

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task combination records
-- and the Project level record (Task id = 0 and Resourcelist member id = 0)

        Update PA_PROJECT_ACCUM_COMMITMENTS  PAA SET
         CMT_RAW_COST_ITD          = CMT_RAW_COST_ITD + X_Raw_Cost,
         CMT_RAW_COST_YTD          = CMT_RAW_COST_YTD + X_Raw_Cost,
         CMT_RAW_COST_PTD          = CMT_RAW_COST_PTD + X_Raw_Cost,
         CMT_BURDENED_COST_ITD     = CMT_BURDENED_COST_ITD + X_Burdened_Cost,
         CMT_BURDENED_COST_YTD     = CMT_BURDENED_COST_YTD + X_Burdened_Cost,
         CMT_BURDENED_COST_PTD     = CMT_BURDENED_COST_PTD + X_Burdened_Cost,
         LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE          = Trunc(Sysdate),
         LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
          UNION select  to_number(X_Proj_accum_id) from sys.dual );
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

-- Initially, the above statement might process just one row,the project level
-- row, since the Project-Task combinations might not have been created.
-- We shall be creating them below.

-- The following procedure would return all the tasks in the given task
-- WBS hierarchy, including the given task, which do not have a header
-- record . The return parameter is an array of records.

         Get_all_higher_tasks_cmt
                              (x_project_id ,
                               X_task_id ,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);

-- If the above procedure had returned any tasks , then we need to insert
-- header record and commitments record. We need to process the tasks one by one
-- since we require the Accum_id for each detail record.
-- Eg: If the given task (the one fetched from PA_TXN_ACCUM) was say
-- 1.1.1, then the first time,    Get_all_higher_tasks would return,
-- 1.1.1, 1.1,  and 1. We create three header records and three detail records
-- in the Project_accum_commitments table. The next time , if the given task
-- is 1.1.2, the Get_all_higher_tasks would return only 1.1.2, since
-- 1.1 and 1 are already available in the Pa_project_accum_headers. Those
-- two records would have been processed by the Update statements.

    IF v_noof_tasks > 0 Then
       For i in 1..v_noof_tasks LOOP
        Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
        From sys.Dual;
        PA_MAINT_PROJECT_ACCUMS.Insert_Headers_tasks (X_project_id,
                              v_task_array(i),
                              x_current_period,
                              v_accum_id,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

       Recs_processed := Recs_processed + 1;
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,X_Raw_Cost,0,X_Raw_Cost,
        X_Burdened_Cost,X_Burdened_Cost,0,X_Burdened_Cost,
        0,0,0,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;

    END IF;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
   When Others Then
   x_err_code := SQLCODE;
   RAISE;

End Process_it_yt_pt_tasks_cmt;

Procedure   Process_it_yt_pp_tasks_cmt
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_id In Number,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Process_it_yt_pp_tasks_cmt - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

Recs_processed Number := 0;
V_Accum_id     Number := 0;
V_task_array task_id_tabtype;
v_noof_tasks Number := 0;
other_recs_processed Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_COMMITMENTS.Process_it_yt_pp_tasks_cmt';


      pa_debug.debug(x_err_stack);

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project and task combination. It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              x_task_id,
                              0,
                              other_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + other_recs_processed;

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task combination records
-- and the Project level record (Task id = 0 and Resourcelist member id = 0)

        Update PA_PROJECT_ACCUM_COMMITMENTS  PAA SET
         CMT_RAW_COST_ITD          = CMT_RAW_COST_ITD + X_Raw_Cost,
         CMT_RAW_COST_YTD          = CMT_RAW_COST_YTD + X_Raw_Cost,
         CMT_RAW_COST_PP           = CMT_RAW_COST_PP + X_Raw_Cost,
         CMT_BURDENED_COST_ITD     = CMT_BURDENED_COST_ITD + X_Burdened_Cost,
         CMT_BURDENED_COST_YTD     = CMT_BURDENED_COST_YTD + X_Burdened_Cost,
         CMT_BURDENED_COST_PP      = CMT_BURDENED_COST_PP + X_Burdened_Cost,
         LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE          = Trunc(Sysdate),
         LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
          UNION select  to_number(X_Proj_accum_id) from sys.dual );
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

-- If the above procedure had returned any tasks , then we need to insert
-- header record and commitments record. We need to process the tasks one by one
-- since we require the Accum_id for each detail record.
-- Eg: If the given task (the one fetched from PA_TXN_ACCUM) was say
-- 1.1.1, then the first time,    Get_all_higher_tasks would return,
-- 1.1.1, 1.1,  and 1. We create three header records and three detail records
-- in the Project_accum_commitments table. The next time , if the given task
-- is 1.1.2, the Get_all_higher_tasks would return only 1.1.2, since
-- 1.1 and 1 are already available in the Pa_project_accum_headers. Those
-- two records would have been processed by the Update statements.

         Get_all_higher_tasks_cmt (
                              x_project_id ,
                               X_task_id ,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);

    If v_noof_tasks > 0 Then
       For i in 1..v_noof_tasks LOOP
        Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
        From sys.Dual;
        PA_MAINT_PROJECT_ACCUMS.Insert_Headers_tasks (X_project_id,
                              v_task_array(i),
                              x_current_period,
                              v_accum_id,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

       Recs_processed := Recs_processed + 1;
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,X_Raw_Cost,X_Raw_Cost,0,
        X_Burdened_Cost,X_Burdened_Cost,
        X_Burdened_Cost,0,
        0,0,
        0,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;

    End If;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
   When Others Then
   x_err_code := SQLCODE;
   RAISE;

End Process_it_yt_pp_tasks_cmt;

Procedure   Process_it_pp_tasks_cmt
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_id In Number,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- Process_it_pp_tasks_cmt   -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

Recs_processed Number := 0;
V_Accum_id     Number := 0;
V_task_array task_id_tabtype;
v_noof_tasks Number := 0;
other_recs_processed Number := 0;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_COMMITMENTS.Process_it_pp_tasks_cmt';

      pa_debug.debug(x_err_stack);

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project and task combination. It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              x_task_id,
                              0,
                              other_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + other_recs_processed;

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task combination records
-- and the Project level record (Task id = 0 and Resourcelist member id = 0)

        Update PA_PROJECT_ACCUM_COMMITMENTS  PAA SET
         CMT_RAW_COST_ITD          = CMT_RAW_COST_ITD + X_Raw_Cost,
         CMT_RAW_COST_PP           = CMT_RAW_COST_PP + X_Raw_Cost,
         CMT_BURDENED_COST_ITD     = CMT_BURDENED_COST_ITD + X_Burdened_Cost,
         CMT_BURDENED_COST_PP      = CMT_BURDENED_COST_PP + X_Burdened_Cost,
         LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE          = Trunc(Sysdate),
         LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
          UNION select  to_number(X_Proj_accum_id) from sys.dual );
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

-- Initially, the above statement might process just one row,the project level
-- row, since the Project-Task combinations might not have been created.
-- We shall be creating them below.

-- The following procedure would return all the tasks in the given task
-- WBS hierarchy, including the given task, which do not have a header
-- record . The return parameter is an array of records.

         Get_all_higher_tasks_cmt (
                               x_project_id ,
                               X_task_id ,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);


-- If the above procedure had returned any tasks , then we need to insert
-- header record and commitments record. We need to process the tasks one by one
-- since we require the Accum_id for each detail record.
-- Eg: If the given task (the one fetched from PA_TXN_ACCUM) was say
-- 1.1.1, then the first time,    Get_all_higher_tasks would return,
-- 1.1.1, 1.1,  and 1. We create three header records and three detail records
-- in the Project_accum_commitments table. The next time , if the given task
-- is 1.1.2, the Get_all_higher_tasks would return only 1.1.2, since
-- 1.1 and 1 are already available in the Pa_project_accum_headers. Those
-- two records would have been processed by the Update statements.

    If v_noof_tasks > 0 Then
       For i in 1..v_noof_tasks LOOP
        Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
        From sys.Dual;
        PA_MAINT_PROJECT_ACCUMS.Insert_Headers_tasks (X_project_id,
                              v_task_array(i),
                              x_current_period,
                              v_accum_id,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

       Recs_processed := Recs_processed + 1;
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,0,X_Raw_Cost,0,
        X_Burdened_Cost,0,X_Burdened_Cost,0,
        0,0,0,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;
    End If;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
    x_recs_processed := Recs_processed;

Exception
   When Others Then
   x_err_code := SQLCODE;
   RAISE;

End Process_it_pp_tasks_cmt;

Procedure   Process_it_yt_tasks_cmt
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_id In Number,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- Process_it_yt_tasks_cmt   -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

Recs_processed Number := 0;
V_Accum_id     Number := 0;
V_task_array task_id_tabtype;
v_noof_tasks Number := 0;
other_recs_processed Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_COMMITMENTS.Process_it_yt_tasks_cmt';

      pa_debug.debug(x_err_stack);

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project and task combination. It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              x_task_id,
                              0,
                              other_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + other_recs_processed;

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task combination records
-- and the Project level record (Task id = 0 and Resourcelist member id = 0)

        Update PA_PROJECT_ACCUM_COMMITMENTS  PAA SET
         CMT_RAW_COST_ITD          = CMT_RAW_COST_ITD + X_Raw_Cost,
         CMT_RAW_COST_YTD          = CMT_RAW_COST_YTD + X_Raw_Cost,
         CMT_BURDENED_COST_ITD     = CMT_BURDENED_COST_ITD + X_Burdened_Cost,
         CMT_BURDENED_COST_YTD     = CMT_BURDENED_COST_YTD + X_Burdened_Cost,
         LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE          = Trunc(Sysdate),
         LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
          UNION select  to_number(X_Proj_accum_id) from sys.dual );
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

-- Initially, the above statement might process just one row,the project level
-- row, since the Project-Task combinations might not have been created.
-- We shall be creating them below.

-- The following procedure would return all the tasks in the given task
-- WBS hierarchy, including the given task, which do not have a header
-- record . The return parameter is an array of records.

         Get_all_higher_tasks_cmt (
                               x_project_id ,
                               X_task_id ,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);


-- If the above procedure had returned any tasks , then we need to insert
-- header record and commitments record. We need to process the tasks one by one
-- since we require the Accum_id for each detail record.
-- Eg: If the given task (the one fetched from PA_TXN_ACCUM) was say
-- 1.1.1, then the first time,    Get_all_higher_tasks would return,
-- 1.1.1, 1.1,  and 1. We create three header records and three detail records
-- in the Project_accum_commitments table. The next time , if the given task
-- is 1.1.2, the Get_all_higher_tasks would return only 1.1.2, since
-- 1.1 and 1 are already available in the Pa_project_accum_headers. Those
-- two records would have been processed by the Update statements.

    If v_noof_tasks > 0 Then
       For i in 1..v_noof_tasks LOOP
        Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
        From sys.Dual;
        PA_MAINT_PROJECT_ACCUMS.Insert_Headers_tasks (X_project_id,
                              v_task_array(i),
                              x_current_period,
                              v_accum_id,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

       Recs_processed := Recs_processed + 1;
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,X_Raw_Cost,0,0,
        X_Burdened_Cost,X_Burdened_Cost,0,0,
        0,0,0,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;

    End If;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
   When Others Then
   x_err_code := SQLCODE;
   RAISE;

End Process_it_yt_tasks_cmt;

Procedure   Process_it_tasks_cmt
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_id In Number,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- Process_it_tasks_cmt      -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.
Recs_processed Number := 0;
V_Accum_id     Number := 0;
V_task_array task_id_tabtype;
v_noof_tasks Number := 0;
other_recs_processed Number := 0;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_COMMITMENTS.Process_it_tasks_cmt';

      pa_debug.debug(x_err_stack);

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project and task combination. It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              x_task_id,
                              0,
                              other_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + other_recs_processed;

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task combination records
-- and the Project level record (Task id = 0 and Resourcelist member id = 0)

        Update PA_PROJECT_ACCUM_COMMITMENTS  PAA SET
         CMT_RAW_COST_ITD           = CMT_RAW_COST_ITD + X_Raw_Cost,
         CMT_BURDENED_COST_ITD      = CMT_BURDENED_COST_ITD + X_Burdened_Cost,
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
          UNION select  to_number(X_Proj_accum_id) from sys.dual );
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

-- Initially, the above statement might process just one row,the project level
-- row, since the Project-Task combinations might not have been created.
-- We shall be creating them below.

-- The following procedure would return all the tasks in the given task
-- WBS hierarchy, including the given task, which do not have a header
-- record . The return parameter is an array of records.

         Get_all_higher_tasks_cmt (
                               x_project_id ,
                               X_task_id ,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);


-- If the above procedure had returned any tasks , then we need to insert
-- header record and commitments record. We need to process the tasks one by one
-- since we require the Accum_id for each detail record.
-- Eg: If the given task (the one fetched from PA_TXN_ACCUM) was say
-- 1.1.1, then the first time,    Get_all_higher_tasks would return,
-- 1.1.1, 1.1,  and 1. We create three header records and three detail records
-- in the Project_accum_commitments table. The next time , if the given task
-- is 1.1.2, the Get_all_higher_tasks would return only 1.1.2, since
-- 1.1 and 1 are already available in the Pa_project_accum_headers. Those
-- two records would have been processed by the Update statements.

    If v_noof_tasks > 0 Then
       For i in 1..v_noof_tasks LOOP
        Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
        From sys.Dual;
        PA_MAINT_PROJECT_ACCUMS.Insert_Headers_tasks (X_project_id,
                              v_task_array(i),
                              x_current_period,
                              v_accum_id,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

       Recs_processed := Recs_processed + 1;
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,0,0,0,
        X_Burdened_Cost,0,0,0,
        0,0,0,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;

    End If;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
   When Others Then
   x_err_code := SQLCODE;
   RAISE;

End Process_it_tasks_cmt;

Procedure   Get_all_higher_tasks_cmt (x_project_id in Number,
                                      X_task_id in Number,
                                      x_task_array  Out NOCOPY task_id_tabtype, --File.Sql.39 bug 4440895
                                      x_noof_tasks Out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- This procedure returns all those tasks from PA_TASKS, which do not
-- have a record in PA_PROJECT_ACCUM_HEADERS table, with Resource_List_member_id
-- (Project-task level numbers without resources )

CURSOR  Tasks_Cur IS
SELECT task_id
FROM pa_tasks pt
WHERE project_id = x_project_id
AND NOT EXISTS
(SELECT 'x'
 FROM
 pa_project_accum_headers pah
 WHERE pah.project_id = X_project_id
 AND pah.task_id = pt.task_id
 AND pah.resource_list_member_id = 0)
 START WITH task_id = x_task_id
 CONNECT BY PRIOR parent_task_id = task_id;

v_noof_tasks         Number := 0;

V_Old_Stack       Varchar2(630);
Task_Rec Tasks_Cur%ROWTYPE;
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_COMMITMENTS.Get_all_higher_tasks_cmt';
      For Task_Rec IN Tasks_Cur LOOP
          v_noof_tasks := v_noof_tasks + 1;
          x_task_array(v_noof_tasks) := Task_Rec.Task_id;

      END LOOP;

      x_noof_tasks := v_noof_tasks;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;

Exception
   When Others Then
     x_err_code := SQLCODE;
     RAISE;

end Get_all_higher_tasks_cmt;

END   PA_PROCESS_ACCUM_COMMITMENTS;

/
