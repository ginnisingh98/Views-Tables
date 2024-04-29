--------------------------------------------------------
--  DDL for Package Body PA_PROCESS_ACCUM_CMT_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROCESS_ACCUM_CMT_RES" AS
/* $Header: PACMTREB.pls 120.2 2005/08/31 11:08:16 vmangulu noship $ */

Procedure   Process_it_yt_pt_cmt_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_qty_flag In Varchar2,
                                 x_unit_of_measure In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- Process_it_yt_pt_cmt_res   - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

CURSOR Proj_Res_level_Cur IS
SELECT Project_Accum_Id
FROM
PA_PROJECT_ACCUM_HEADERS
WHERE Project_id = X_project_id
AND   Task_Id = 0
AND Resource_list_Member_id = X_resource_list_member_id;

V_task_array task_id_tabtype;
Recs_processed       Number := 0;
V_Accum_id           Number := 0;
v_noof_tasks         Number := 0;
V_Qty                Number := 0;
Res_Recs_processed   Number := 0;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_CMT_RES.Process_it_yt_pt_cmt_res';

      pa_debug.debug(x_err_stack);

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project,task and resource combination.It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              x_task_id,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project and Resource combination. It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              0,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

-- Quantity would be rolledup only if the Rollup_Quantity_flag against the
-- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Qty := X_Quantity;
        Else
            V_Qty := 0;
        End If;


-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_COMMITMENTS  PAA SET
         CMT_RAW_COST_ITD      = CMT_RAW_COST_ITD + X_Raw_Cost,
         CMT_RAW_COST_YTD      = CMT_RAW_COST_YTD + X_Raw_Cost,
         CMT_RAW_COST_PTD      = CMT_RAW_COST_PTD + X_Raw_Cost,
         CMT_BURDENED_COST_ITD     = CMT_BURDENED_COST_ITD + X_Burdened_Cost,
         CMT_BURDENED_COST_YTD     = CMT_BURDENED_COST_YTD + X_Burdened_Cost,
         CMT_BURDENED_COST_PTD     = CMT_BURDENED_COST_PTD + X_Burdened_Cost,
         CMT_QUANTITY_ITD          = CMT_QUANTITY_ITD + V_Qty,
         CMT_QUANTITY_YTD          = CMT_QUANTITY_YTD + V_Qty,
         CMT_QUANTITY_PTD          = CMT_QUANTITY_PTD + V_Qty,
         LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE          = Trunc(Sysdate),
         LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in ( select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

-- Initially, the above statement might not Update any rows
-- since the Project-Task-Resource combinations or
-- Project-Resource combinations might not have been created.
-- We shall be creating them below.
-- The following procedure would return all the tasks in the given task
-- WBS hierarchy, including the given task, which do not have a header
-- record . The return parameter is an array of records.

        v_noof_tasks := 0;
         Get_all_higher_tasks_cmt_res (x_project_id ,
                               X_task_id ,
                               x_resource_list_member_id,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);


-- If the above procedure had returned any tasks , then we need to insert
-- header record and commitments record.We need to process the tasks one by one
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
        Select PA_PROJECT_ACCUM_HEADERS_S.Nextval
        into V_Accum_id
        From Dual;
        PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res
                             (X_project_id,
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
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,
       CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,X_Raw_Cost,0,X_Raw_Cost,
        X_Burdened_Cost,X_Burdened_Cost,
        0,X_Burdened_Cost,
        V_Qty,V_Qty,0,V_Qty,
        X_Unit_Of_Measure,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;
    End If;

-- This will check for the Project-Resource combination in the Header records
-- and if not present create the Header and Detail records for commitments

    Open Proj_Res_level_Cur;
    Fetch Proj_Res_level_Cur Into V_Accum_Id;
    If Proj_Res_level_Cur%NOTFOUND Then
       Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
       From Dual;
       PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res
                          (X_project_id,
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
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,
       CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,X_Raw_Cost,0,X_Raw_Cost,
        X_Burdened_Cost,X_Burdened_Cost,
        0,X_Burdened_Cost,
        V_Qty,V_Qty,0,V_Qty,
        X_Unit_Of_Measure,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
    End If;
    Close Proj_Res_level_Cur;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_it_yt_pt_cmt_res;

Procedure   Process_it_yt_pp_cmt_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_qty_flag In Varchar2,
                                 x_unit_of_measure In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- Process_it_yt_pp_cmt_res   - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.  The Project-Resource records
--                          are also created/updated.

CURSOR Proj_Res_level_Cur IS
SELECT Project_Accum_Id
FROM
PA_PROJECT_ACCUM_HEADERS
WHERE Project_id = X_project_id
AND Task_Id = 0
AND Resource_list_Member_id = X_resource_list_member_id;

V_task_array task_id_tabtype;
Recs_processed          Number := 0;
V_Accum_id              Number := 0;
v_noof_tasks            Number := 0;
V_Qty                   Number := 0;
Res_Recs_processed      Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_CMT_RES.Process_it_yt_pp_cmt_res';

      pa_debug.debug(x_err_stack);

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project,task and resource combination.It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              x_task_id,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project and Resource combination. It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              0,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

-- Quantity would be rolledup only if the Rollup_Quantity_flag against the
-- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Qty := X_Quantity;
        Else
            V_Qty := 0;
        End If;


-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_COMMITMENTS  PAA SET
         CMT_RAW_COST_ITD          = CMT_RAW_COST_ITD + X_Raw_Cost,
         CMT_RAW_COST_YTD          = CMT_RAW_COST_YTD + X_Raw_Cost,
         CMT_RAW_COST_PP           = CMT_RAW_COST_PP + X_Raw_Cost,
         CMT_BURDENED_COST_ITD     = CMT_BURDENED_COST_ITD + X_Burdened_Cost,
         CMT_BURDENED_COST_YTD     = CMT_BURDENED_COST_YTD + X_Burdened_Cost,
         CMT_BURDENED_COST_PP      = CMT_BURDENED_COST_PP + X_Burdened_Cost,
         CMT_QUANTITY_ITD          = CMT_QUANTITY_ITD + V_Qty,
         CMT_QUANTITY_YTD          = CMT_QUANTITY_YTD + V_Qty,
         CMT_QUANTITY_PP           = CMT_QUANTITY_PP + V_Qty,
         LAST_UPDATED_BY           = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE          = Trunc(Sysdate),
         LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

-- Initially, the above statement might not Update any rows
-- since the Project-Task-Resource combinations or
-- Project-Resource combinations might not have been created.
-- We shall be creating them below.
-- The following procedure would return all the tasks in the given task
-- WBS hierarchy, including the given task, which do not have a header
-- record . The return parameter is an array of records.

        v_noof_tasks := 0;
         Get_all_higher_tasks_cmt_res (x_project_id ,
                               X_task_id ,
                               x_resource_list_member_id,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);


-- If the above procedure had returned any tasks , then we need to insert
-- header record and commitments record.We need to process the tasks one by one
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
        From Dual;
        PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res
                             (X_project_id,
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
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,
       CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,X_Raw_Cost,X_Raw_Cost,0,
        X_Burdened_Cost,X_Burdened_Cost,
        X_Burdened_Cost,0,
        V_Qty,V_Qty,V_Qty,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;
    End If;

-- This will check for the Project-Resource combination in the Header records
-- and if not present create the Header and Detail records for commitments

    Open Proj_Res_level_Cur;
    Fetch Proj_Res_level_Cur Into V_Accum_Id;
    If Proj_Res_level_Cur%NOTFOUND Then
       Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
       From Dual;
       PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res
                          (X_project_id,
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

       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,
       CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,X_Raw_Cost,X_Raw_Cost,0,
        X_Burdened_Cost,X_Burdened_Cost,
        X_Burdened_Cost,0,
        V_Qty,V_Qty,V_Qty,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
    End If;
    Close Proj_Res_level_Cur;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;

Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_it_yt_pp_cmt_res;

Procedure   Process_it_pp_cmt_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_qty_flag In Varchar2,
                                 x_unit_of_measure In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Process_it_pp_cmt_res     -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

CURSOR Proj_Res_level_Cur IS
SELECT Project_Accum_Id
FROM
PA_PROJECT_ACCUM_HEADERS
WHERE Project_id = X_project_id
AND Task_Id = 0
AND Resource_list_Member_id = X_resource_list_member_id;

V_task_array           task_id_tabtype;
Recs_processed         Number := 0;
V_Accum_id             Number := 0;
v_noof_tasks           Number := 0;
V_Qty                  Number := 0;
Res_Recs_processed     Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_CMT_RES.Process_it_pp_cmt_res';

      pa_debug.debug(x_err_stack);

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project,task and resource combination.It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              x_task_id,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project and Resource combination. It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              0,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

-- Quantity would be rolledup only if the Rollup_Quantity_flag against the
-- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Qty := X_Quantity;
        Else
            V_Qty := 0;
        End If;



-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_COMMITMENTS  PAA SET
         CMT_RAW_COST_ITD        = CMT_RAW_COST_ITD + X_Raw_Cost,
         CMT_RAW_COST_PP         = CMT_RAW_COST_PP + X_Raw_Cost,
         CMT_BURDENED_COST_ITD   = CMT_BURDENED_COST_ITD + X_Burdened_Cost,
         CMT_BURDENED_COST_PP    = CMT_BURDENED_COST_PP + X_Burdened_Cost,
         CMT_QUANTITY_ITD        = CMT_QUANTITY_ITD + V_Qty,
         CMT_QUANTITY_PP         = CMT_QUANTITY_PP + V_Qty,
         LAST_UPDATED_BY         = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE        = Trunc(Sysdate),
         LAST_UPDATE_LOGIN       = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In

        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         Recs_processed := Recs_processed + SQL%ROWCOUNT;
         v_noof_tasks := 0;

-- Initially, the above statement might not Update any rows
-- since the Project-Task-Resource combinations or
-- Project-Resource combinations might not have been created.
-- We shall be creating them below.
-- The following procedure would return all the tasks in the given task
-- WBS hierarchy, including the given task, which do not have a header
-- record . The return parameter is an array of records.

         Get_all_higher_tasks_cmt_res (x_project_id ,
                               X_task_id ,
                               x_resource_list_member_id,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);


-- If the above procedure had returned any tasks , then we need to insert
-- header record and commitments record.We need to process the tasks one by one
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
        From Dual;
        PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res
                             (X_project_id,
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
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,
       CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,0,X_Raw_Cost,0,
        X_Burdened_Cost,0,
        X_Burdened_Cost,0,
        V_Qty,0,V_Qty,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;
    End If;

-- This will check for the Project-Resource combination in the Header records
-- and if not present create the Header and Detail records for commitments

    Open Proj_Res_level_Cur;
    Fetch Proj_Res_level_Cur Into V_Accum_Id;
    If Proj_Res_level_Cur%NOTFOUND Then
       Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
       From Dual;
       PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res
                             (X_project_id,
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
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,
       CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,0,X_Raw_Cost,0,
       X_Burdened_Cost,0,
       X_Burdened_Cost,0,
       V_Qty,0,V_Qty,0,
       X_Unit_Of_Measure,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
       Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
       Recs_processed := Recs_processed + 1;
     End If;

     Close Proj_Res_level_Cur;
     x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;

Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE ;
End Process_it_pp_cmt_res;

Procedure   Process_it_yt_cmt_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_qty_flag In Varchar2,
                                 x_unit_of_measure In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Process_it_yt_cmt_res     -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

CURSOR Proj_Res_level_Cur IS
SELECT Project_Accum_Id
FROM
PA_PROJECT_ACCUM_HEADERS
WHERE Project_id = X_project_id
AND Task_Id = 0
AND Resource_list_Member_id = X_resource_list_member_id;

V_task_array task_id_tabtype;
Recs_processed       Number := 0;
V_Accum_id           Number := 0;
v_noof_tasks         Number := 0;
V_Qty                Number := 0;
Res_Recs_processed   Number := 0;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_CMT_RES.Process_it_yt_cmt_res';

      pa_debug.debug(x_err_stack);

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project,task and resource combination.It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              x_task_id,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project and Resource combination. It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              0,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

-- Quantity would be rolledup only if the Rollup_Quantity_flag against the
-- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Qty := X_Quantity;
        Else
            V_Qty := 0;
        End If;


-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_COMMITMENTS  PAA SET
         CMT_RAW_COST_ITD         = CMT_RAW_COST_ITD + X_Raw_Cost,
         CMT_RAW_COST_YTD         = CMT_RAW_COST_YTD + X_Raw_Cost,
         CMT_BURDENED_COST_ITD    = CMT_BURDENED_COST_ITD + X_Burdened_Cost,
         CMT_BURDENED_COST_YTD    = CMT_BURDENED_COST_YTD + X_Burdened_Cost,
         CMT_QUANTITY_ITD         = CMT_QUANTITY_ITD + V_Qty,
         CMT_QUANTITY_YTD         = CMT_QUANTITY_YTD + V_Qty,
         LAST_UPDATED_BY          = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE         = Trunc(Sysdate),
         LAST_UPDATE_LOGIN        = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

-- Initially, the above statement might not Update any rows
-- since the Project-Task-Resource combinations or
-- Project-Resource combinations might not have been created.
-- We shall be creating them below.
-- The following procedure would return all the tasks in the given task
-- WBS hierarchy, including the given task, which do not have a header
-- record . The return parameter is an array of records.

        v_noof_tasks := 0;
        Get_all_higher_tasks_cmt_res (x_project_id ,
                               X_task_id ,
                               x_resource_list_member_id,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);


-- If the above procedure had returned any tasks , then we need to insert
-- header record and commitments record.We need to process the tasks one by one
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
        From Dual;
        PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res
                             (X_project_id,
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
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,
       CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,X_Raw_Cost,0,0,
        X_Burdened_Cost,X_Burdened_Cost,
        0,0,
        V_Qty,V_Qty,0,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;
    End If;

-- This will check for the Project-Resource combination in the Header records
-- and if not present create the Header and Detail records for commitments

    Open Proj_Res_level_Cur;
    Fetch Proj_Res_level_Cur Into V_Accum_Id;
    If Proj_Res_level_Cur%NOTFOUND Then
       Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
       From Dual;
       PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res
                          (X_project_id,
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
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,
       CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,X_Raw_Cost,0,0,
        X_Burdened_Cost,X_Burdened_Cost,
        0,0,
        V_Qty,V_Qty,0,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
    End If;
    Close Proj_Res_level_Cur;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;
              x_err_stack := V_Old_Stack;

Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_it_yt_cmt_res;

Procedure   Process_it_cmt_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_qty_flag In Varchar2,
                                 x_unit_of_measure In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Process_it_cmt_res        -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

CURSOR Proj_Res_level_Cur IS
SELECT Project_Accum_Id
FROM
PA_PROJECT_ACCUM_HEADERS
WHERE Project_id = X_project_id
AND Task_Id = 0
AND Resource_list_Member_id = X_resource_list_member_id;

Recs_processed        Number := 0;
V_Accum_id            Number := 0;
V_task_array          task_id_tabtype;
v_noof_tasks          Number := 0;
V_Qty                 Number := 0;
Res_Recs_processed    Number := 0;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_CMT_RES.Process_it_cmt_res';

      pa_debug.debug(x_err_stack);

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project,task and resource combination.It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              x_task_id,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

-- This checks for Commitments record in PA_PROJECT_ACCUM_COMMITMENTS for this
-- project and Resource combination. It is possible that there might be a
-- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
-- no corresponding detail record. The procedure called below,will
-- check for the existence of the detail records and if not available
-- would create it.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              0,
                              x_resource_list_Member_id,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

-- Quantity would be rolledup only if the Rollup_Quantity_flag against the
-- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Qty := X_Quantity;
        Else
            V_Qty := 0;
        End If;


-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_COMMITMENTS  PAA SET
         CMT_RAW_COST_ITD          = CMT_RAW_COST_ITD + X_Raw_Cost,
         CMT_BURDENED_COST_ITD     = CMT_BURDENED_COST_ITD + X_Burdened_Cost,
         CMT_QUANTITY_ITD          = CMT_QUANTITY_ITD + V_Qty,
         LAST_UPDATE_DATE          = Trunc(Sysdate),
         LAST_UPDATE_LOGIN         = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

-- Initially, the above statement might not Update any rows
-- since the Project-Task-Resource combinations or
-- Project-Resource combinations might not have been created.
-- We shall be creating them below.
-- The following procedure would return all the tasks in the given task
-- WBS hierarchy, including the given task, which do not have a header
-- record . The return parameter is an array of records.

         v_noof_tasks := 0;
         Get_all_higher_tasks_cmt_res (x_project_id ,
                               X_task_id ,
                               x_resource_list_member_id,
                               v_task_array,
                               v_noof_tasks,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);


-- If the above procedure had returned any tasks , then we need to insert
-- header record and commitments record.We need to process the tasks one by one
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
        From Dual;
        PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res
                             (X_project_id,
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
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,
       CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,0,0,0,
        X_Burdened_Cost,0,0,0,
        V_Qty,0,0,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;
    End If;

-- This will check for the Project-Resource combination in the Header records
-- and if not present create the Header and Detail records for commitments

    Open Proj_Res_level_Cur;
    Fetch Proj_Res_level_Cur Into V_Accum_Id;
    If Proj_Res_level_Cur%NOTFOUND Then
       Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
       From Dual;
       PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res
                             (X_project_id,
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
       Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,
       CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,X_Raw_Cost,0,0,0,
        X_Burdened_Cost,0,0,0,
        V_Qty,0,0,0,
        X_Unit_Of_Measure,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
    End If;
    Close Proj_Res_level_Cur;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE ;
End Process_it_cmt_res;

Procedure  Get_all_higher_tasks_cmt_res (x_project_id in Number,
                                      X_task_id in Number,
                                      x_resource_list_member_id In Number,
                                      x_task_array  Out NOCOPY task_id_tabtype, --File.Sql.39 bug 4440895
                                      x_noof_tasks Out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- Get_all_higher_tasks_cmt_res  -  For the given Task Id returns all the
--                          higher level tasks in the WBS (including the given
--                          task) which are not in PA_PROJECT_ACCUM_HEADERS
--                          (Tasks with the given Resource )

CURSOR  Tasks_Cur IS
SELECT task_id
FROM pa_tasks pt
WHERE project_id = x_project_id
AND NOT EXISTS
(SELECT 'x'
 FROM
 pa_project_accum_headers pah
 WHERE pah.project_id = x_project_id
 AND pah.task_id = pt.task_id
 AND pah.resource_list_member_id = x_resource_list_member_id)
 START WITH task_id = x_task_id
 CONNECT BY PRIOR parent_task_id = task_id;

v_noof_tasks         Number := 0;
Task_Rec Tasks_Cur%ROWTYPE;

V_Old_Stack       Varchar2(630);
Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_CMT_RES.Get_all_higher_tasks_cmt_res';

      pa_debug.debug(x_err_stack);

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
     RAISE ;
end Get_all_higher_tasks_cmt_res;

END PA_PROCESS_ACCUM_CMT_RES;

/
